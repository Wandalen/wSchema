( function _Universal_s_( )
{

'use strict';

//

const _ = _global_.wTools;

//

const Parent = _.schema.Product;
const Self = wSchemaProductUniversal;
function wSchemaProductUniversal( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'ProductUniversal';

// --
// inter
// --

function _form2()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  _.props.extend( product, def.opts );
  _.assert( _.symbolIs( product.symbol ), 'Expects field {- symbol -}' );

  return true;
}

//

function _makeDefaultAct( it )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;
  it.onElementAdd({ value : _.nothing });
  // return _.nothing;
  // throw _.err( `Cant make default for ${product.qualifiedName}. Universal definitions cant have default value.` );
}

//

function _isTypeOfStructureAct( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  if( product.symbol === product.Symbol.anything )
  {
    return true;
  }
  else if( product.symbol === product.Symbol.nothing )
  {
    return false;
  }
  else _.assert( 0 );

  return false;
}

//

function _exportString( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  _.routine.assertOptions( _exportString, arguments );
  _.assert( o.structure !== null );

  if( o.format === 'dump' || o.format === 'id' )
  {
    return Parent.prototype._exportString.call( this, o );
  }
  else if( o.format === 'grammar' )
  {
    let result;
    if( product.symbol === _.anything )
    result = `${product.grammarName} := ( type = anything )`;
    else
    result = `${product.grammarName} := ( type = nothing )`;
    return result;
  }
  else _.assert( 0 );

}

_exportString.defaults =
{
  ... _.schema.Product.prototype._exportString.defaults,
}

// --
// relations
// --

let Symbols =
{
  anything : _.anything,
  nothing : _.nothing,
}

let Fields =
{
  symbol : null,
}

let Composes =
{
}

let Aggregates =
{
  symbol : null,
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
  Symbols,
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
