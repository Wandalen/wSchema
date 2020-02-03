( function _ProductAlternative_s_( ) {

'use strict';

//

let _ = _global_.wTools;

//

let Parent = _.schema.Product;
let Self = function wSchemaProductAlternative( o )
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

  if( !product._formComplex() )
  return false;

  _.mapExtend( product, _.mapBut( def.opts, { extend : null, supplement : null } ) );

  _.assert( product.default === null || !!sys.definition( product.default ) );

  return true;
}

//

function _makeDefaultAct( it )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  debugger;
  if( product.default === undefined || product.default === null )
  {
    debugger;
    throw _.err( `${product.qualifiedName} does not have defined {- default -}` );
  }

  let elementDefinition = sys.definition( product.default );

  return elementDefinition.product._makeDefaultAct( it );
}

// --
// exporter
// --

function exportStructure( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  o = _.routineOptions( exportStructure, arguments );

  Parent.prototype.exportStructure.call( product, o );

  o.dst.elements = [];

  let o2 = _.mapExtend( null, o );
  o2.elements = product.elementsArray;
  o2.dst = o.dst.elements;
  product._elementsExportStructure( o2 );

  return o.dst;
}

exportStructure.defaults =
{
  ... Parent.prototype.exportStructure.defaults,
}

//

function exportInfo( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  o = _.routineOptions( exportInfo, arguments );

  let result = Parent.prototype.exportInfo.call( product, o );

  let o2 = _.mapExtend( null, o );
  o2.structure = product.elementsArray;
  let result2 = product._elementsExportInfo( o2 );
  if( result2 )
  result += `\n  elements\n${result2}`;

  return result;
}

exportInfo.defaults =
{
  ... Parent.prototype.exportInfo.defaults,
}

// --
// relations
// --

let Fields =
{
  default : null,
  extend : null,
  supplement : null,
}

let Composes =
{
}

let Aggregates =
{
  default : null,
  elementsMap : null,
  elementsArray : null,
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

  exportStructure,
  exportInfo,

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
