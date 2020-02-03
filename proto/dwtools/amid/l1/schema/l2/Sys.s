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
        throw _.err( `Cyclyc dependence of definitions :: [ ${ names.join( ' ' ) } ]` );
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

function fromString( src )
{
  let sys = this;

  var SchemaTokensDefinition = _.tokensDefinitionFrom
  ({
    'colon_equal'       : ':=',
    'equal'             : '=',
    'left'              : '<-',
    'right'             : '->',
    'space'             : /\s+/,
    'string/single'     : /'(?:\\\n|\\'|[^'\n])*?'/,
    'name/special'      : [ 'terminal', 'default', 'null', 'true', 'false' ],
    'name/user'         : /@[a-z_\$][0-9a-z_\$]*/i,
    'number'            : /(?:0x(?:\d|[a-f])+|\d+(?:\.\d+)?(?:e[+-]?\d+)?)/i,
    'parenthes'         : /[\(\)]/,
    'square'            : /[\[\]]/,
    'curly'             : /{[^}]}/,
  });

  let tokens = _.strFindAll
  ({
    src : src,
    ins : SchemaTokensDefinition,
    tokenizingUnknown : 1,
  });

  debugger;

  let statements = statementsParse( 0 );

  debugger;

  return xxx;

  function statementsParse( first )
  {

    let statements = [];
    let parenthesLevel = 0;
    let square = 0;
    let clolnEqualEncountered = 0;

    debugger;
    for( let t = first ; t < tokens.length ; t++ )
    {
      let token = tokens[ t ];
      // if( token.kind ===   )
    }
    debugger;

    return statements;
  }

  return sys;
}

/*
`
  @null := terminal default = null
  @string := terminal default = ''
  @number := terminal default = ' 0 '<-js
  @boolean := terminal default = ' false '<-js
  @alternative1 := [ @number @string default = @string ]
  @composition1 :=
  (
    @name := @string
    := null
    @value := @string
    container = none
  )
  @container :=
  (
    @id := @number
    @comp1 := @composition1
    @handle := @number
    $
  )
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
