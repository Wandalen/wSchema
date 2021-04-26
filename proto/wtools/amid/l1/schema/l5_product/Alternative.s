( function _Alternative_s_( )
{

'use strict';

//

const _ = _global_.wTools;

//

const Parent = _.schema.ProductVector;
const Self = wSchemaProductAlternative;
function wSchemaProductAlternative( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'ProductAlternative';

// --
// inter
// --

function _form2()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  if( !Parent.prototype._form2.apply( product, arguments ) )
  return false;

  _.assert( product.default === null || !!sys.definition( product.default ) );

  return true;
}

//

function _makeDefaultAct( it )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  if( product.default === undefined || product.default === null )
  {
    throw _.err( `${product.qualifiedName} does not have defined {- default -}` );
  }

  let elementDefinition = sys.definition( product.default );

  return elementDefinition.product._makeDefaultAct( it );
}

// --
// exporter
// --

// function exportStructure( o )
// {
//   let product = this;
//   let def = product.definition;
//   let sys = def.sys;
//
//   o = _.routine.options_( exportStructure, arguments );
//
//   Parent.prototype.exportStructure.call( product, o );
//
//   o.dst.elements = [];
//
//   let o2 = _.props.extend( null, o );
//   o2.elements = product.elementsArray;
//   o2.dst = o.dst.elements;
//   product._elementsExportStructure( o2 );
//
//   return o.dst;
// }
//
// exportStructure.defaults =
// {
//   ... Parent.prototype.exportStructure.defaults,
// }
//
// //
//
// function exportString( o )
// {
//   let product = this;
//   let def = product.definition;
//   let sys = def.sys;
//
//   o = _.routine.options_( exportString, arguments );
//
//   let result = Parent.prototype.exportString.call( product, o );
//
//   let o2 = _.props.extend( null, o );
//   o2.structure = product.elementsArray;
//   let result2 = product._elementsExportString( o2 );
//   if( result2 )
//   result += `\n  elements\n${result2}`;
//
//   return result;
// }
//
// exportString.defaults =
// {
//   ... Parent.prototype.exportString.defaults,
// }
//
// //
//
// function _exportString( o )
// {
//   let product = this;
//   let def = product.definition;
//   let sys = def.sys;
//
//   _.routine.options_( _exportString, arguments );
//   _.assert( o.structure !== null );
//
//   return product._exportStringVector( o );
//   // let o2 = _.props.extend( null, o );
//   // o2.opener = '[';
//   // o2.closer = ']';
//   // return product._exportStringVector( o2 );
// }
//
// _exportString.defaults =
// {
//   ... _.schema.Product.prototype._exportString.defaults,
//   // prefix : '',
//   // postfix : '',
// }

//

function _exportStringVector( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  _.routine.options_( _exportStringVector, arguments );

  let o2 = _.props.extend( null, o );
  o2.opener = '[';
  o2.closer = ']';

  return Parent.prototype._exportStringVector.call( product, o2 );
}

_exportStringVector.defaults =
{
  ... Parent.prototype._exportString.defaults,
  prefix : '',
  postfix : '',
}

// --
// relations
// --

let Fields =
{
  ... Parent.Fields,
  default : null,
  // extend : null,
  // supplement : null,
  // bias : null,
}

let Composes =
{
}

let Aggregates =
{
  ... Parent.prototype.Aggregates,
  default : null,
  // elementsMap : null,
  // elementsArray : null,
  // bias : null,
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

  // exporter

  // exportStructure,
  // _exportString,
  _exportStringVector,

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
