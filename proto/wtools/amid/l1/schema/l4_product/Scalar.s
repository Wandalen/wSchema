( function _Scalar_s_( )
{

'use strict';

//

const _ = _global_.wTools;

//

const Parent = _.schema.Product;
const Self = wSchemaProductScalar;
function wSchemaProductScalar( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'ProductScalar';

// --
// helper
// --

function _formUsing()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  let elementDefinition = sys.definition( product.type );
  _.arrayAppendOnce( elementDefinition.product.usedByProducts, product );
  _.arrayAppendOnce( product.usesProducts, elementDefinition.product );

}

//

function elementDefinition()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;
  return sys.definition( product.type );
}

//

function elementProduct()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;
  return sys.definition( product.type ).product;
}

// --
// relations
// --

let Composes =
{
}

let Aggregates =
{
  type : null,
}

let Associates =
{
}

let Restricts =
{
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
// define class
// --

let Proto =
{

  // helper

  _formUsing,

  elementDefinition,
  elementProduct,

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
