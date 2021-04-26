( function _Multiplier_s_( )
{

'use strict';

//

const _ = _global_.wTools;

//

const Parent = _.schema.ProductScalar;
const Self = wSchemaProductMultiplier;
function wSchemaProductMultiplier( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'ProductMultiplier';

// --
// inter
// --

function _form2()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;
  let opts = _.props.extend( null, def.opts );

  _.props.extend( product, def.opts );
  _.assert
  (
    _.strDefined( product.type ) || _.numberDefined( product.type ),
    () => `Multiplier should have name of type definition, but ${def.qualifiedName} does not have`
  );

  if( product.multiple === '*' )
  product.multiple = [ 0, Infinity ];

  if( !_.intervalIs( product.multiple ) )
  throw _.err( `Field multiple of ${product.qualifiedName} should be range, but it is not` );

  // product._formUsing();

  return true;
}

//

function _form3()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  product._formUsing();

  return true;
}

// --
// helper
// --

function isRangeAny()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  if( product.multiple[ 0 ] !== 0 )
  return false;
  if( product.multiple[ 1 ] !== Infinity )
  return false;

  return true;
}

//

function isRangeAtLeastOnce()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  if( product.multiple[ 0 ] !== 1 )
  return false;
  if( product.multiple[ 1 ] !== Infinity )
  return false;

  return true;
}

//

function isRangeOptional()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  if( product.multiple[ 0 ] !== 0 )
  return false;
  if( product.multiple[ 1 ] !== 1 )
  return false;

  return true;
}

//

function isRangeOnce()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  if( product.multiple[ 0 ] !== 1 )
  return false;
  if( product.multiple[ 1 ] !== 1 )
  return false;

  return true;
}

// --
// productor
// --

function _makeDefaultAct( it )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  let originalDefinition = sys.definition( def.product.type );
  _.assert( def.product.isRangeAny(), 'not implemented' );

}

//

function _isTypeOfStructureAct( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  throw _.err( 'not implemented' );

  return true;
}

//

function _exportString( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  _.routine.assertOptions( _exportString, arguments );
  _.assert( o.structure !== null );

  if( o.format === 'dump' )
  return Parent.prototype._exportString.call( this, o );

  let result;
  let elementDefinition = sys.definition( def.product.type );

  if( product.isRangeAny() )
  result = `${product.grammarName} := *${elementDefinition.product.grammarName}`;
  else if( product.isRangeAtLeastOnce() )
  result = `${product.grammarName} := +${elementDefinition.product.grammarName}`;
  else if( product.isRangeOptional() )
  result = `${product.grammarName} := ?${elementDefinition.product.grammarName}`;
  else if( product.isRangeOnce() )
  result = `${product.grammarName} := ${elementDefinition.product.grammarName}`;
  else
  result = `${product.grammarName} := ( type = ${elementDefinition.product.grammarName} `
  + `multiple = ${product.multiple[ 0 ]} ${product.multiple[ 1 ]} )`;

  return result;
}

_exportString.defaults =
{
  ... _.schema.Product.prototype._exportString.defaults,
}

// --
// relations
// --

let Fields =
{
  type : null,
  multiple : null,
}

let Composes =
{
}

let Aggregates =
{
  type : null,
  multiple : null,
}

let Associates =
{
}

let Restricts =
{
}

let Statics =
{
  Fields,
}

let Forbids =
{
}

let Accessors =
{
}

// --
// define class
// --

let Proto =
{

  // inter

  _form2,
  _form3,

  // helper

  isRangeAny,
  isRangeAtLeastOnce,
  isRangeOptional,
  isRangeOnce,

  // productor

  _makeDefaultAct,
  _isTypeOfStructureAct,
  _exportString,

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

_.schema[ Self.shortName ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = _global_.wTools;

})();
