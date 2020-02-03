( function _ProductMultiplier_s_( ) {

'use strict';

//

let _ = _global_.wTools;

//

let Parent = _.schema.Product;
let Self = function wSchemaProductMultiplier( o )
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
  let opts = _.mapExtend( null, def.opts );

  _.mapExtend( product, def.opts );
  _.assert( _.strDefined( product.type ) || _.numberDefined( product.type ), () => `Multiplier should have name of type definition, but ${def.qualifiedName} does not have` );

  if( product.multiple === '*' )
  product.multiple = [ 0, Infinity ];

  if( !_.rangeIs( product.multiple ) )
  throw _.err( `Field multiple of ${product.qualifiedName} should be range, but it is not` );

  return true;
}

//

function _makeDefaultAct( it )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;
  // debugger;

  let originalDefinition = sys.definition( def.product.type );
  _.assert( def.product.isAnyRange(), 'not implemented' );

  // debugger;
  // it.onElementAdd( _.nothing );

  // if( originalDefinition.kind !== originalDefinition.Kind.universal || value !== _.nothing )
  // if( value !== _.nothing )
  // throw _.err( 'Cant make default for varied-length compisition with not ❮nothing❯ as default element' );

  // debugger;
  // return _.nothing;

  // _.assert( _.routineIs( elementDefinition.product._makeDefaultAct ), `Definition ${elementDefinition.product.qualifiedName} deos not have method _makeDefaultAct` );
  // let value = elementDefinition.product._makeDefaultAct();

  // throw _.err( 'Should not be called. Implementation of _makeDefaultAct for the definition of container of it' );
  // return product._makeDefaultSingletone();
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

function isAnyRange()
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
  _makeDefaultAct,
  _isTypeOfStructureAct,

  isAnyRange,

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
if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

})();
