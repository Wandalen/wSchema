( function _Sys_s_( ) {

'use strict';

//

let _ = _global_.wTools;
let Parent = null;
let Self = function wSchemaSys( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'System';

// --
// inter
// --

function init( o )
{
  let sys = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  _.workpiece.initFields( sys );
  Object.preventExtensions( sys );

  if( o )
  sys.copy( o );

  sys.define( '❮nothing❯' ).universal({ symbol : _.nothing });
  sys.define( '❮anything❯' ).universal({ symbol : _.anything });

}

//

function finit()
{
  let sys = this;

  let definitionsArray = sys.definitionsArray.slice();
  for( let d = 0 ; d < definitionsArray.length ; d++ )
  {
    let def = definitionsArray[ d ];
    def.finit();
  }

  _.assert( _.lengthOf( sys.definitionsMap ) === 0 );
  _.assert( _.lengthOf( sys.definitionsArray ) === 0 );

  _.Copyable.prototype.finit.call( this );
}

//

function form()
{
  let sys = this;

  if( sys.formed )
  return end();

  try
  {
    sys._form();
  }
  catch( err )
  {
    throw _.err( err, `\nFailed to form ${sys.qualifiedName}`, '\n', sys.exportInfo() );
  }

  sys.formed = 1;
  return end();

  function end()
  {
    _.assert( sys.definitionsToForm2Array.length === 0 );
    _.assert( sys.definitionsToForm3Array.length === 0 );
    _.assert( sys.formed === 1 );
    return sys;
  }
}

//

function _form()
{
  let sys = this;

  stage( sys.definitionsToForm2Array, 'form2' );
  stage( sys.definitionsToForm3Array, 'form3' );

  return sys;

  function stage( definitionsToFormArray, formMethodName )
  {

    let wasLength;
    while( definitionsToFormArray.length )
    {

      /* xxx : this condition is not enough.
              gives false positive if was added exactly same number of definitions as delete
      */
      if( wasLength === definitionsToFormArray.length )
      {
        let names = definitionsToFormArray.map( ( def ) => def.name || def.id );
        debugger;
        throw _.err( `Cyclyc dependencies of definitions :: [ ${ names.join( ' ' ) } ]` );
      }

      wasLength = definitionsToFormArray.length;

      let definitionsToForm2Array = definitionsToFormArray.slice();
      for( let d = 0 ; d < definitionsToForm2Array.length ; d++ )
      {
        let def = definitionsToForm2Array[ d ];
        def[ formMethodName ]();
      }

    }

  }

}

//

function define( o )
{
  let sys = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( _.longIs( o ) )
  return sys._definedVectorized( o );

  if( _.strIs( arguments[ 0 ] ) )
  o = { name : arguments[ 0 ] }
  else if( arguments[ 0 ] === undefined )
  o = Object.create( null );
  o.sys = sys;

  let def = _.schema.Definition( o );

  def.preform();

  return def;
}

//

function defineFromSyntax( syntax )
{
  let sys = this;
  let result = [];

  syntax = _.tokensSyntaxFrom( syntax );

  for( let name in syntax.nameToId )
  {
    result.push( sys.define( name ).terminal() );
  }

  for( let name in syntax.alternatives )
  {
    result.push( sys.define( name ).alternative().extend( syntax.alternatives[ name ] ) );
  }

  return sys._definedVectorized( result );
}

//

function _definedVectorized( opts )
{
  let sys = this;

  _.assert( _.longIs( opts ) );
  _.assert( arguments.length === 1 );

  for( let i = 0 ; i < opts.length ; i++ )
  {
    opts[ i ] = sys.define( opts[ i ] ).preform();
  }

  return _.vectorizeAccess( opts );
}

//

function definition( o )
{
  let sys = this;

  _.assert( arguments.length === 1 );

  if( o instanceof _.schema.Definition )
  return o;

  if( o === _.nothing || o === _.anything )
  {
    let def = _.first( sys.definitionsArray, ( def ) =>
    {
      if( !def.opts )
      return;
      if( def.opts.symbol === o )
      return def;
    });
    return def;
  }

  if( _.strIs( arguments[ 0 ] ) )
  o = { name : arguments[ 0 ] }
  else if( _.numberIs( arguments[ 0 ] ) )
  o = { id : arguments[ 0 ] }

  _.assert( _.mapIs( o ) );

  let def;
  if( o.id )
  def = _.first( sys.definitionsArray, o );
  else
  def = sys.definitionsMap[ o.name ];

  _.assert( def instanceof _.schema.Definition, `No definition::${o.name}` );

  return def;
}

definition.defaults =
{
  name : null,
  id : null,
}

//

//

/* let schema/grammar =
`

  @statement :=
  (.
    ?(
      left := ?@name_at
      @colon_equal
    )
    right :=
    [
      @name_kind
      @block
    ]
    default := ?@default
  )

  @default :=
  (.
    @name_directive/default
    @equal
    value := [ @literal @name_at ]
  )

  @literal :=
  [
    @name_literal
    @number
    @string
  ]

  @string :=
  (.
    value := @string_single
    kind :=
    ?(
      @left
      := @name_clean
    )
  )

  @statements := ( *@statement )

  @block := [ @alternative @composition ]

  @alternative :=
  (
    := ?@dot
    @square_open
    := @statements
    @square_close
  )

  @composition :=
  (
    := ?@dot
    @parenthes_open
    := @statements
    @parenthes_close
  )

`
*/

function fromString( src )
{
  let sys = this;
  let tokensSyntax = _.tokensSyntaxFrom
  ({
    'colon_equal'       : ':=',
    'equal'             : '=',
    'left'              : '<-',
    'right'             : '->',
    'multiple_optional' : '?',
    'multiple_any'      : '*',
    'space'             : /\s+/,
    'string_single'     : /'(?:\\\n|\\'|[^'\n])*?'/,
    'name_kind'         : [ 'terminal' ],
    'name_directive'    : [ 'default', 'container' ],
    'name_literal'      : [ 'null', 'true', 'false' ],
    'name_at'           : /@[a-z_\$][0-9a-z_\$]*/i,
    'name_slash'        : /\/[a-z_\$][0-9a-z_\$]*/i,
    'name_clean'        : /[a-z_\$][0-9a-z_\$]*/i,
    'number'            : /(?:0x(?:\d|[a-f])+|\d+(?:\.\d+)?(?:e[+-]?\d+)?)/i,
    'parenthes_open'    : '(',
    'parenthes_close'   : ')',
    'square_open'       : '[',
    'square_close'      : ']',
  });

  syntaxExtend( 'statement' );

  let nameToId = tokensSyntax.nameToId;

  let tokens = _.strFindAll
  ({
    src : src,
    ins : tokensSyntax,
    tokenizingUnknown : 1,
  });

  tokens = tokens.filter( ( token ) => token.tokenId !== nameToId.space );

  let statements;
  let elements;
  let left;

  varInit();

  let statementsStack = [];
  let elementsStack = [];
  let leftStack = [];

  let index = 0;
  let parenthes = 0;
  let square = 0;
  let length = tokens.length;

  let tokenToRoutine =
  {
    [ nameToId.colon_equal ] : tokenColonEqualEncounter,
    [ nameToId[ 'parenthes_open' ] ] : tokenParenthesOpenEncounter,
    [ nameToId[ 'parenthes_close' ] ] : tokenParenthesCloseEncounter,
    [ nameToId[ 'square_open' ] ] : tokenSquareOpenEncounter,
    [ nameToId[ 'square_close' ] ] : tokenSquareCloseEncounter,
  }

  debugger;
  statementsParse();
  debugger;

  return xxx;

  /* */

  function statementsParse()
  {

    while( index < length )
    {
      let token = tokens[ index ];
      let routine = tokenToRoutine[ token.tokenId ];

      if( routine )
      {
        routine();
      }
      else
      {
        elements.push( token );
      }

      if( left === null && elements.length >= 2 )
      {
        left = [];
      }

      if( left && elements.length >= 2 )
      {
        let pre = elements[ elements.length-2 ];
        let cur = elements[ elements.length-1 ];
        if( cur.tokenId === tokensSyntax.nameToId[ 'name_at' ] || cur.kind === 'statement' )
        if( pre.tokenId !== tokensSyntax.nameToId.equal )
        {
          statementAddButOne();
        }
      }

      index += 1;
    }
    debugger;

    statementAddRemainder();

    return statements;
  }

  function tokenColonEqualEncounter()
  {
    if( !left )
    {
      left = elements;
      elements = [];
    }
    else
    {
      statementAddButOne();
    }
  }

  function tokenParenthesOpenEncounter()
  {
    parenthes += 1;
    push();
    varInit();
  }

  function tokenParenthesCloseEncounter()
  {
    _.sure( parenthes >= 1, `Parentheses mismatch at ${codeOf([ statementLeftestToken() , tokens[ index ] ])}` );
    statementAddRemainder();
    _.arrayAppendArray( elementsStack[ elementsStack.length - 1 ], statements );
    parenthes -= 1;
    pop();
  }

  function tokenSquareOpenEncounter()
  {
    square += 1;
    push();
    varInit();
  }

  function tokenSquareCloseEncounter()
  {
    _.sure( square >= 1, `Square mismatch at ${codeOf([ statementLeftestToken() , tokens[ index ] ])}` );
    statementAddRemainder();
    _.arrayAppendArray( elementsStack[ elementsStack.length - 1 ], statements );
    square -= 1;
    pop();
  }

  function tokenEqualEncounter()
  {
    _.sure
    (
      elements[ elements.length-1 ] && elements[ elements.length-1 ].tokenId === nameToId[ 'name_directive/default' ],
      `Expects "default =" at ${codeOf([ statementLeftestToken() , tokens[ index ] ])}`
    );

  }

  function syntaxExtend( name )
  {
    _.assert( tokensSyntax.nameToId[ name ] === undefined );
    let id = tokensSyntax.idToName.length;
    tokensSyntax.nameToId[ name ] = id;
    tokensSyntax.idToName.push( name );
    return id;
  }

  function varInit()
  {
    statements = [];
    elements = [];
    left = null;
  }

  function push()
  {
    statementsStack.push( statements );
    elementsStack.push( elements );
    leftStack.push( left );
  }

  function pop()
  {
    statements = statementsStack.pop();
    elements = elementsStack.pop();
    left = leftStack.pop();
  }

  function statementLeftestToken()
  {
    if( left && left.length )
    return left[ 0 ];
    return tokens[ 0 ];
  }

  function statementAddButOne()
  {
    let elements2 = elements.splice( elements.length-1, 1 );
    statementMake( left, elements );
    left = null;
    elements = elements2;
  }

  function statementAddRemainder()
  {
    if( left )
    {
      statementMake( left, elements );
    }
    else if( elements.length )
    {
      statementMake( [], elements );
    }
  }

  function statementMake( left, right )
  {
    let leftest = left.length ? left[ 0 ] : right[ 0 ];
    let rightest = right.length ? right[ right.length-1 ] : left[ left.length-1 ];
    let statement = Object.create( null );
    statement.left = statementLeft( left );
    statement.right = right;
    statement.type = 'statement';
    statement.tokenId = nameToId.statement;
    statement.range = [ leftest.range[ 0 ], rightest.range[ 0 ] ];
    statements.push( statement );
  }

  function statementLeft( tokens )
  {
    _.sure( tokens.length === 0 || tokens.length === 1, () => `Expects single token on the left of statement, but got ${codeOf( tokens )}` );
    _.sure( tokens.length === 0 || tokens[ 0 ].tokenId === tokensSyntax.nameToId[ 'name_at' ], () => `Expects defined name, but got ${codeOf( tokens )}` );
    if( tokens.length )
    return src.substring( tokens[ 0 ].range[ 0 ]+1, tokens[ 0 ].range[ 1 ]+1 );
    else
    return null;
  }

  function codeOf( tokens )
  {
    _.assert( arguments.length === 1 );
    _.assert( _.longIs( tokens ) );
    _.assert( !!tokens[ 0 ] );
    _.assert( !!tokens[ 0 ].range );
    return src.substring( tokens[ 0 ].range[ 0 ], tokens[ tokens.length-1 ].range[ 1 ] );
  }

  return sys;
}

//

/*
`
  @null := terminal default = null
  @string := terminal default = ''
  @number := terminal default = ' 0 '<-js
  @boolean := terminal default = ' false '<-js
  @alternative1 := [ @number @string ] default = @string
  @composition1 :=
  (
    name := @string
    := null
    value := @string
    container = none
  )
  @container :=
  (.
    id := @number
    comp1 := @composition1
    handle := @number
  )
`
*/

//

/* let parser/grammar =
`

  /statement_top :=
  (.
    :=(
      @left := /name_slash
      @included := /colon_equal
    )
    @multiple := ?/multiple
    @right :=
    [
      /name_kind
      /name_slash
      /block
    ]
    container = map
  )

  /statement_in :=
  (.
    := ?(
      @left := ?/name_at
      @included := /colon_equal
    )
    @multiple := ?/multiple
    @right :=
    [
      /name_slash
      /block
    ]
  )

  /multiple := [ /multiple_optional /multiple_any ]

  /directive :=
  (.
    /name_directive
    /equal
    @value := [ /literal /name_slash ]
  )

  /literal :=
  [
    /name_literal
    /number
    /string
  ]

  /string :=
  (.
    @value := /string_single
    @kind :=
    ?(
      /left
      := /name_clean
    )
  )

  /block := [ /alternative /composition ]

  /alternative :=
  (
    /square_open
    := *[ /statements_in /directive ]
    /square_close
  )

  /composition :=
  (
    /parenthes_open
    := *[ /statements_in /directive ]
    /parenthes_close
  )

  /grammar := (. * /statement_top root=1 )

`
*/

// --
// export
// --

function exportStructure( o )
{
  let sys = this;
  o = _.routineOptions( exportStructure, arguments );

  if( o.dst === null )
  o.dst = Object.create( null );
  o.dst.definitions = o.dst.definitions || [];
  o.dst.name = sys.name;

  for( let d = 0 ; d < sys.definitionsArray.length ; d++ )
  {
    let def = sys.definitionsArray[ d ];

    let o2 = _.mapExtend( null, o );
    delete o2.dst;
    o.dst.definitions.push( def.exportStructure( o2 ) );

  }

  return o.dst;
}

exportStructure.defaults =
{
  dst : null,
  verbosity : 9,
  compacting : 1,
}

//

function exportInfo( o )
{
  let sys = this;
  o = _.routineOptions( exportInfo, arguments );
  _.assert( _.longHas( [ 'info', 'grammar' ], o.format ) )

  debugger;
  if( o.structure === null )
  o.structure = sys.exportStructure( _.mapBut( o, [ 'structure' ] ) );
  let result = `schema::${o.structure.name}`;

  for( let d = 0 ; d < o.structure.definitions.length ; d++ )
  {
    let defStructure = o.structure.definitions[ d ];
    let def = sys.definition( defStructure.id );

    if( result )
    result += '\n\n';

    let o2 = _.mapExtend( null, o );
    o2.structure = defStructure;
    delete o2.dst;
    result += '  ' + _.strLinesIndentation( def.exportInfo( o2 ), '  ' );

  }

  return result;
}

exportInfo.defaults =
{
  ... _.mapBut( exportStructure.defaults, [ 'dst' ] ),
  structure : null,
  format : 'info',
}

//

function _qualifiedNameGet()
{
  let sys = this;
  return `schema::${sys.name || ''}`;
}

// --
// relations
// --

let Composes =
{
  name : null,
}

let Aggregates =
{
}

let Associates =
{
}

let Restricts =
{
  definitionsMap : _.define.own({}),
  definitionsArray : _.define.own([]),
  definitionsToForm2Array : _.define.own([]),
  definitionsToForm3Array : _.define.own([]),
  formed : 0,
  definitionCounter : 0,
}

let Statics =
{
}

let Forbids =
{
}

let Accessors =
{
}

// --
// declare
// --

let Proto =
{

  // inter

  init,
  finit,
  form,
  _form,

  define,
  defineFromSyntax,
  _definedVectorized,
  definition,

  fromString,

  // export

  exportStructure,
  exportInfo,
  _qualifiedNameGet,

  // relation

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
  Forbids,
  Accessors,

}

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );
_.schema[ Self.shortName ] = Self;
if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

})();
