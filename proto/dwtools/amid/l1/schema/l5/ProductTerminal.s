( function _ProductTerminal_s_( ) {

'use strict';

//

let _ = _global_.wTools;

//

let Parent = _.schema.Product;
let Self = function wSchemaProductTerminal( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'ProductTerminal';

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
  _.assert( product.onCheck === null || _.routineIs( product.onCheck ), () => `${product.qualifiedName} should have null or routine {- onCheck -}, but has ${_.strType( product.onCheck )}` );

  return true;
}

//

function _makeDefaultAct( it )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;
  return product._makeDefaultFromDefault( it );
}

//

function _isTypeOfStructureAct( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  debugger;
  _.assert( _.routineIs( product.onCheck ), `Terminal ${product.qualifiedName} does not have defined callback onCheck` );
  _.assert( o.definition === def );
  if( !product.onCheck( o ) )
  return false;

  return true;
}

// --
// relations
// --

let Fields =
{
  default : null,
  onCheck : null,
}

let Composes =
{
}

let Aggregates =
{
  default : null,
  onCheck : null,
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
