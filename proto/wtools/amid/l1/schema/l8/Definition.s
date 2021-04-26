( function _Definition_s_( )
{

'use strict';

//

const _ = _global_.wTools;

//

const Parent = null;
const Self = wSchemaDefinition;
function wSchemaDefinition( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Definition';

// --
// inter
// --

function init( o )
{
  let def = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  _.workpiece.initFields( def );
  Object.preventExtensions( def );

  if( o )
  def.copy( o );

}

//

function finit()
{
  let def = this;
  let sys = def.sys;

  _.assert( !_.workpiece.isFinited( def ) );

  if( def.id )
  {

    if( def.name !== null )
    {
      _.assert( sys.definitionsMap[ def.name ] === def );
      delete sys.definitionsMap[ def.name ];
    }

    _.arrayRemoveOnceStrictly( sys.definitionsArray, def );
    _.arrayRemoveOnce( sys.definitionsToForm2Array, def );
    _.arrayRemoveOnce( sys.definitionsToForm3Array, def );
  }

  _.Copyable.prototype.finit.call( def );
}

//

function preform()
{
  let def = this;

  if( def.formed )
  return def;

  let sys = def.sys;

  _.assert( sys instanceof _.schema.System );
  _.assert( def.name === null || def.IsValidName( def.name ) );

  if( def.name !== null )
  {
    _.sure
    (
      sys.definitionsMap[ def.name ] === undefined || sys.definitionsMap[ def.name ] === def,
      () => `Schema already has ${def.qualifiedName}`
    );
    sys.definitionsMap[ def.name ] = def;
  }

  _.arrayAppendOnceStrictly( sys.definitionsArray, def );
  _.arrayAppendOnceStrictly( sys.definitionsToForm2Array, def );

  sys.definitionCounter += 1;
  def.id = sys.definitionCounter;

  // if( def.id === 14 )
  // debugger;

  def.formed = 1;
  return def;
}

//

function form2()
{
  let def = this;
  let sys = def.sys;

  if( def.formed >= 2 )
  return def;

  _.assert( def.formed === 1 );
  _.assert( def.Kind._first <= def.kind && def.kind <= def.Kind._last, `Structure of ${def.qualifiedName} is not defined` );
  _.assert( def.name === null || def.IsValidName( def.name ) );
  _.assert( _.longIs( def.opts ) || _.mapIs( def.opts ) );

  if( def.name !== null )
  {
    _.sure( sys.definitionsMap[ def.name ] === undefined || sys.definitionsMap[ def.name ] === def );
    sys.definitionsMap[ def.name ] = def;
  }

  def.product = new( def.typeToProductClass() )({ definition : def });
  let formed = def.product.form2();

  if( formed )
  def.formed = 2;
  return def;
}

//

function form3()
{
  let def = this;
  let sys = def.sys;

  if( def.formed >= 3 )
  return def;

  _.assert( def.formed === 2 );
  let formed = def.product.form3();

  if( formed )
  def.formed = 3;
  return def;
}


//

function typeToProductClass( kind )
{
  let def = this;

  if( kind === undefined )
  kind = def.kind;

  _.assert( !!def.KindNameToProduct );
  _.assert( _.routineIs( def.KindNameToProduct[ kind ] ), `No product constructor for product kind ${kind}` );

  return def.KindNameToProduct[ kind ];
}

//

function isComplex()
{
  let def = this;
  _.assert( arguments.length === 0 );
  return def.kind === def.Kind.composition || def.kind === def.Kind.alternative;
}

//

function firstNonAlias()
{
  let def = this;
  let sys = def.sys;
  let result = def;

  while( result.kind === result.Kind.alias && result.type )
  {
    result = sys.definition( result.type );
  }

  return result;
}

//

function IsDefinitionString( defStr )
{

  _.assert( arguments.length === 1 );

  if( !_.strIs( defStr ) )
  return false;

  if( _.strHasAny( defStr, [ '(', '[', '*' ] ) )
  return true;

  return false;
}

//

function IsValidName( str )
{
  _.assert( arguments.length === 1 );

  if( !_.strDefined( str ) )
  return false;

  if( this.IsDefinitionString( str ) )
  return false;

  // if( _.strHas( str, '❮' ) || _.strHas( str, '❯' ) )
  // return false;

  return true;
}

//

function IsNameOrId( src )
{
  _.assert( arguments.length === 1 );

  if( _.strDefined( src ) )
  return true;

  if( _.numberIs( src ) )
  return true;

  return false;
}

//

function fromFields( opts )
{
  let def = this;
  let sys = def.sys;

  _.assert( def.formed === 1 );
  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( opts ) );
  _.map.assertHasOnly( opts, def.typeToProductClass().Fields );

  def.opts = _.props.extend( def.opts, opts );

  // def.opts = def.opts || Object.create( null );
  // if( opts )
  // _.props.extend( def.opts, opts );
  // _.map.assertHasOnly( def.opts, def.typeToProductClass().Fields );

  return def;
}

//

function fromFieldsTolerant( opts )
{
  let def = this;
  let sys = def.sys;

  _.assert( def.formed === 1 );
  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( opts ) );

  def.opts = _.props.extend( def.opts, _.mapOnly_( null, opts, def.typeToProductClass().Fields ) );

  return def;
}

//

function fromDefinitionString( defStr )
{
  let def = this;
  let sys = def.sys;
  let originalDefStr = defStr;
  let result;

  _.assert( def.formed === 1 );
  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( def.kind === null );
  _.assert( def.IsDefinitionString( defStr ) );

  defStr = defStr.trim();

  if( _.strBegins( defStr, '(' ) )
  {
    let isolated = _.strIsolateInside( defStr, '(', ')' );
    if( isolated[ 0 ] !== '' || isolated[ 4 ] !== '' )
    return errThrow();
    if( !isolated[ 1 ] || !isolated[ 3 ] )
    return errThrow();
    let splits = split( isolated[ 2 ] );
    _.assert( splits[ 0 ] !== '*' );
    result = def.composition().extend( splits );
  }
  else if( _.strBegins( defStr, '[' ) )
  {
    _.assert( !_.strHas( defStr, '*' ), 'not implemented' );
    let isolated = _.strIsolateInside( defStr, '[', ']' );
    if( isolated[ 0 ] !== '' || isolated[ 4 ] !== '' )
    return errThrow();
    if( !isolated[ 1 ] || !isolated[ 3 ] )
    return errThrow();
    let splits = split( isolated[ 2 ] );
    result = def.alternative().extend( splits );
  }
  else return errThrow();

  _.assert( def.kind !== null );

  return result;

  function split( src )
  {
    let result = _.strSplit
    ({
      src,
      preservingEmpty : 0,
      preservingQuoting : 0,
      preservingDelimeters : 1,
      stripping : 1,
      quoting : 1,
      delimeter : [ /\s+/, '*' ],
    });
    result = result.filter( ( e ) => !/\s+/.test( e ) );

    result = _.filter_( null, result, ( e, k ) =>
    {
      if( e !== '*' )
      return e;
      _.assert( result.length-1 > k );
      result[ k+1 ] = { multiple : '*', type : result[ k+1 ] };
    });

    return result;
  }

  function errThrow()
  {
    throw _.err( `Failed to parse definition string "${originalDefStr}"` );
  }

}

//

function _definePrimitive( opts, kind )
{
  let def = this;
  let sys = def.sys;

  _.assert( def.formed === 1 );
  _.assert( arguments.length === 2 );
  _.assert( def.kind === null );
  _.assert( opts === undefined || opts === null || _.mapIs( opts ) );

  def.kind = kind;
  def.opts = def.opts || Object.create( null );
  // if( opts )
  // _.props.extend( def.opts, opts );
  // _.map.assertHasOnly( def.opts, def.typeToProductClass().Fields );
  if( opts )
  def.fromFields( opts );

  return def;
}

//

function universal( opts )
{
  let def = this;
  let sys = def.sys;
  _.assert( arguments.length === 0 || arguments.length === 1 );
  def._definePrimitive( opts, def.Kind.universal );
  return def;
}

//

function terminal( opts )
{
  let def = this;
  let sys = def.sys;
  _.assert( arguments.length === 0 || arguments.length === 1 );
  def._definePrimitive( opts, def.Kind.terminal );
  return def;
}

//

function alias( opts )
{
  let def = this;
  let sys = def.sys;
  _.assert( arguments.length === 0 || arguments.length === 1 );
  def._definePrimitive( opts, def.Kind.alias );
  return def;
}


//

function multiplier( opts )
{
  let def = this;
  let sys = def.sys;
  _.assert( arguments.length === 0 || arguments.length === 1 );
  def._definePrimitive( opts, def.Kind.multiplier );
  return def;
}


//

function container( opts )
{
  let def = this;
  let sys = def.sys;
  _.assert( arguments.length === 0 || arguments.length === 1 );
  def._definePrimitive( opts, def.Kind.container );
  return def;
}


//

function _complex()
{
  let def = this;
  let sys = def.sys;

  _.assert( def.formed === 1 );
  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.assert( _.longHas( [ def.Kind.composition, def.Kind.alternative ], def.kind ) );
  _.assert( def.opts === null || _.mapIs( def.opts ) );

  def.opts = def.opts || Object.create( null );

  def.opts.extend = [];
  def.opts.supplement = [];

  // _.map.assertHasOnly( def.opts, def.typeToProductClass().Fields );

  return def;
}

//

function composition( opts )
{
  let def = this;
  let sys = def.sys;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  def.kind = def.Kind.composition;

  def._complex();
  if( opts )
  def.fromFields( opts );

  // _.map.assertHasOnly( def.opts, def.typeToProductClass().Fields );

  return def;
}

//

function alternative( opts )
{
  let def = this;
  let sys = def.sys;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  def.kind = def.Kind.alternative;

  def._complex();
  if( opts )
  def.fromFields( opts );

  // _.map.assertHasOnly( def.opts, def.typeToProductClass().Fields );

  return def;
}

//

function _amend( amend, elements )
{
  let def = this;
  let sys = def.sys;

  _.assert( def.formed === 1 );
  _.assert( arguments.length === 2 );
  _.assert( _.mapIs( elements ) || _.longIs( elements ) || def.IsNameOrId( elements ) );
  _.assert( _.longHas( [ def.Kind.composition, def.Kind.alternative ], def.kind ) );
  _.assert( _.mapIs( def.opts ) );
  _.assert( _.arrayIs( def.opts[ amend ] ) );

  def.opts[ amend ].push( elements );

  return def;
}

//

function extend( elements )
{
  let def = this;
  let sys = def.sys;

  _.assert( arguments.length === 1 );

  def._amend( 'extend', elements );

  return def;
}

//

function supplement( elements )
{
  let def = this;
  let sys = def.sys;

  _.assert( arguments.length === 1 );

  def._amend( 'supplement', elements );

  return def;
}

//

function label( labels )
{
  let def = this;
  let sys = def.sys;

  _.assert( def.formed === 1 );
  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( labels ) || _.longLike( labels ) || _.strIs( labels ) );

  if( _.longLike( labels ) )
  {
    let labels2 = Object.create( null );
    for( let l = 0 ; l < labels.length ; l++ )
    labels2[ labels[ l ] ] = true;
    labels = labels2;
  }
  else if( _.strIs( labels ) )
  {
    let labels2 = Object.create( null );
    labels2[ labels ] = true;
    labels = labels2;
  }

  _.props.extend( def.labels, labels );

  return def;
}

// --
// productor
// --

function makeDefault()
{
  let def = this;
  let sys = def.sys;
  let product = def.product;

  _.assert( def.formed === 3 );
  _.assert( arguments.length === 0, 'Expects no arguments' );

  return product.makeDefault();
}

//

function isTypeOf( src )
{
  let def = this;
  let sys = def.sys;
  let product = def.product;

  _.assert( def.formed === 3 );
  _.assert( arguments.length === 1, 'Expects no arguments' );

  if( src && src instanceof _.schema.Definition )
  return product.isTypeOfDefinition({ src });
  else
  return product.isTypeOfStructure({ src });
}

// --
// exporter
// --

function exportStructure( o )
{
  let def = this;
  let sys = def.sys;
  let product = def.product;

  o = _.routine.options_( exportStructure, arguments );

  if( o.dst === null )
  o.dst = Object.create( null );

  o.dst.name = def.name;
  o.dst.kind = def.KindNameToId.forVal( def.kind );
  o.dst.id = def.id;

  if( !product || product.formed < 2 )
  return o.dst;

  def.product.exportStructure( o );

  return o.dst;
}

exportStructure.defaults =
{
  ... _.schema.System.prototype.exportStructure.defaults,
}

//

function exportString( o )
{
  let def = this;
  let sys = def.sys;
  let product = def.product;

  o = _.routine.options_( exportString, arguments );

  if( o.structure === null )
  o.structure = def.exportStructure( _.mapOnly_( null, o, def.exportStructure.defaults ) );

  if( product && product.formed >= 2 )
  {
    return product.exportString( o );
  }
  else
  {
    let result = def._longNameFromStructure( o.structure );
    let structure = _.mapBut_( null, o.structure, [ 'name', 'kind', 'id' ] );
    if( _.entity.lengthOf( structure ) )
    result += '\n' + _.entity.exportStringNice( structure );
    return result;
  }
}

exportString.defaults =
{
  ... _.schema.System.prototype.exportString.defaults,
  it : null,
}

//

function _qualifiedNameGet()
{
  let def = this;
  return `${def.constructor.shortName}::${def.name || def.id}`;
}

//

function GrammarNameFor( name )
{
  if( _.strIs( name ) )
  return '/' + name;
  else
  return '#' + name;
}

//

function _grammarNameGet()
{
  let def = this;
  return def.GrammarNameFor( def.name || def.id );
}

//

function _longNameFromStructure( structure )
{
  let def = this;
  if( structure.name )
  return `definition.${structure.kind} :: ${structure.name} ## ${structure.id}`;
  else
  return `definition.${structure.kind} ## ${structure.id}`;
}

_longNameFromStructure.defaults =
{
  name : null,
  kind : null,
  id : null,
}

// --
// relations
// --

let Kind =
{
  _first : 1,
  universal : 1,
  terminal : 2,
  alias : 3,
  multiplier : 4,
  container : 5,
  composition : 6,
  alternative : 7,
  _last : 8,
}

let KindNameToId = new _.NameMapper().set( _.mapBut_( null, Kind, { _first : null, _last : null } ) );

let KindNameToProduct =
{
  [ Kind.universal ] : _.schema.ProductUniversal,
  [ Kind.terminal ] : _.schema.ProductTerminal,
  [ Kind.alias ] : _.schema.ProductAlias,
  [ Kind.multiplier ] : _.schema.ProductMultiplier,
  [ Kind.container ] : _.schema.ProductContainer,
  [ Kind.composition ] : _.schema.ProductComposition,
  [ Kind.alternative ] : _.schema.ProductAlternative,
}

let Composes =
{
  name : null,
  kind : null,
}

let Aggregates =
{
  product : null,
  labels : _.define.own({}),
}

let Associates =
{
  sys : null,
}

let Restricts =
{

  formed : 0,
  id : null,

  opts : null,

}

let Statics =
{

  Kind,
  KindNameToId,
  KindNameToProduct,

  IsDefinitionString,
  IsValidName,
  IsNameOrId,
  GrammarNameFor,

}

let Forbids =
{
  elementsMap : 'elementsMap',
  elementsArray : 'elementsArray',
  default : 'default',
  multiple : 'multiple',
}

let Accessors =
{
  grammarName : {},
}

// --
// define class
// --

let Proto =
{

  // inter

  init,
  finit,
  preform,
  form2,
  form3,

  typeToProductClass,
  isComplex,
  firstNonAlias,
  IsDefinitionString,
  IsValidName,
  IsNameOrId,

  fromFields,
  fromFieldsTolerant,
  fromDefinitionString,

  _definePrimitive,
  universal,
  terminal,
  alias,
  multiplier,
  container,

  _complex,
  composition,
  alternative,
  _amend,
  extend,
  supplement,

  label,

  // productor

  makeDefault,
  isTypeOf,

  // exporter

  exportStructure,
  exportString,

  _qualifiedNameGet,
  GrammarNameFor,
  _grammarNameGet,
  _longNameFromStructure,

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
if( typeof module !== 'undefined' )
module[ 'exports' ] = _global_.wTools;

})();
