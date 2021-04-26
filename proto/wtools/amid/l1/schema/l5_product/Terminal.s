( function _Terminal_s_( )
{

'use strict';

//

const _ = _global_.wTools;

//

const Parent = _.schema.Product;
const Self = wSchemaProductTerminal;
function wSchemaProductTerminal( o )
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
  let opts = _.props.extend( null, def.opts );

  _.props.extend( product, def.opts );
  _.assert
  (
    product.onCheck === null || _.routineIs( product.onCheck ),
    () => `${product.qualifiedName} should have null or routine {- onCheck -}, but has ${_.entity.strType( product.onCheck )}`
  );

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

  _.assert( _.routineIs( product.onCheck ), `Terminal ${product.qualifiedName} does not have defined callback onCheck` );
  _.assert( o.definition === def );
  if( !product.onCheck( o ) )
  return false;

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

  if( o.format === 'dump' || o.format === 'id' )
  {
    return Parent.prototype._exportString.call( this, o );
  }
  // else if( o.format === 'id' )
  // {
  //   let result = o.name ? def.GrammarNameFor( o.name ) : product.grammarName;
  //   result += ' := ' + def.GrammarNameFor( o.structure.id );
  //   return result;
  // }
  else if( o.format === 'grammar' )
  {
    let result;
    if( product.default === null )
    result = `${product.grammarName} := terminal`;
    else
    result = `${product.grammarName} := ( type = terminal default = ${_.entity.exportString( product.default )} )`;
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
