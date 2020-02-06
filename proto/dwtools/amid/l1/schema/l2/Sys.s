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
      @including := /colon_equal
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
      @including := /colon_equal
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

//

function _parse1()
{

  let tokensSyntax = _.tokensSyntaxFrom
  ({
    'mul'               : '*',
    'plus'              : '+',
    'space'             : /\s+/,
    'name'              : /[a-z_\$][0-9a-z_\$]*/i,
    'number'            : /(?:0x(?:\d|[a-f])+|\d+(?:\.\d+)?(?:e[+-]?\d+)?)/i,
    'parenthes_open'    : '(',
    'parenthes_close'   : ')',
  });

  // syntaxExtend( 'statement' );

  let nameToId = tokensSyntax.nameToId;

  let tokens = _.strFindAll
  ({
    src : src,
    ins : tokensSyntax,
    tokenizingUnknown : 1,
  });

  tokens = tokens.filter( ( token ) => token.tokenId !== nameToId.space );

  let terms;
  let elements;
  let left;

  varInit();

  let termsStack = [];
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
  }

  debugger;
  termsParse();
  debugger;

  return xxx;

  /* */

  function termsParse()
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

    return terms;
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
    _.arrayAppendArray( elementsStack[ elementsStack.length - 1 ], terms );
    parenthes -= 1;
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
    terms = [];
    elements = [];
    left = null;
  }

  function push()
  {
    termsStack.push( terms );
    elementsStack.push( elements );
    leftStack.push( left );
  }

  function pop()
  {
    terms = termsStack.pop();
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
    terms.push( statement );
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

}

/*
let grammar =
`

  /mul = terminal
  /plus = terminal
  /space = terminal
  /name = terminal
  /number = terminal
  /parenthes_open = terminal
  /parenthes_close = terminal

  /factor = [ /name /number ]
  /exp_mul = (<. /exp /mul /exp )
  /exp_plus = (<. /exp /plus /exp )
  /exp_parenthes = (. /parenthes_open /exp /parenthes_close ]
  /exp = [< /factor /exp_mul /exp_plus /exp_parenthes root=true ]

  //

  /mul = #01
  /plus = #02
  /space = #03
  /name = #04
  /number = #05
  /parenthes_open = #06
  /parenthes_close = #07
  /factor = #08
  /exp_mul = #09
  /exp_plus = #10
  /exp_parenthes = #11
  /exp = #12

  #01 = #01
  #02 = #02
  #03 = #03
  #04 = #04
  #05 = #05
  #06 = #06
  #07 = #07
  #08 = [ #04 #05 ]
  #09 = (<. #12 #01 #12 )
  #10 = (<. #12 #02 #12 )
  #11 = (. #06 #12 #07 ]
  #12 = [< #08 #09 #10 #11 root=true ]

  #10a = (. #12 #02 #12 !&#02 )
=

  a  +  b  +  c
  04 02 04 02 04
   0  1  2  3  4

  |
  04 02 04 02 04
  |
  12 02 12 02 12
  |
  12 02 12
  |
  12

  x 12 02
    02 12 x
x x 12 02 x

=

  (  a  *  (  b  +  c  )  )
  06 04 01 06 04 02 04 07 07
   0  1  2  3  4  5  6  7  8

  |                            0 - 3
  06 04 01 06 04 02 04 07 07
     |
  06 08 01 06 04 02 04 07 07
     |
  06 10 01 06 04 02 04 07 07
     |                         1 - 4
  06 12 01 06 04 02 04 07 07
        |                      2 - 5
  06 12 01 06 04 02 04 07 07
           |                   3 - 6
  06 12 01 06 04 02 04 07 07
              |
  06 12 01 06 08 02 04 07 07
              |
  06 12 01 06 12 02 04 07 07
              |                4 - 7
  06 12 01 06 12 02 04 07 07
                 |             5 - 8
  06 12 01 06 12 02 04 07 07
                    |
  06 12 01 06 12 02 08 07 07
                    |          6 - 9 !
  06 12 01 06 12 02 12 07 07
                       |
  06 12 01 06 12 02 12 07 07

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

    if( !o.withUniversal )
    if( def.kind === def.Kind.universal )
    continue;

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
  withUniversal : 0,
}

//

function exportInfo( o )
{
  let sys = this;
  o = _.routineOptions( exportInfo, arguments );
  _.assert( _.longHas( [ 'dump', 'grammar' ], o.format ) )

  if( o.structure === null )
  o.structure = sys.exportStructure( _.mapOnly( o, sys.exportStructure.defaults ) );
  let result = `schema::${o.structure.name}`;

  for( let d = 0 ; d < o.structure.definitions.length ; d++ )
  {
    let defStructure = o.structure.definitions[ d ];
    let def = sys.definition( defStructure.id );

    let o2 = _.mapExtend( null, o );
    o2.structure = defStructure;
    delete o2.dst;
    let info = def.exportInfo( o2 );

    if( !info )
    continue;

    if( result )
    result += '\n\n';
    result += '  ' + _.strLinesIndentation( info, '  ' );

  }

  return result;
}

exportInfo.defaults =
{
  ... _.mapBut( exportStructure.defaults, [ 'dst' ] ),
  structure : null,
  format : 'dump',
  optimizing : 1,
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
  _parse1,

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
