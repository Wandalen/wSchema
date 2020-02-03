( function _ProductAlias_s_( ) {

'use strict';

//

let _ = _global_.wTools;

//

let Parent = _.schema.Product;
let Self = function wSchemaProductAlias( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'ProductAlias';

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
  _.assert( _.strDefined( product.type ) || _.numberDefined( product.type ), () => `Alias should have name of type definition, but ${def.qualifiedName} does not have` );

  if( product.subtype )
  {

    product.subtype = _.schema.Subtype
    ({
      structure : product.subtype,
      definition : def,
    });
    product.subtype.form();

    if( product.subtype.structure.identical !== undefined )
    if( product.default === null )
    product.default = product.subtype.structure.identical;

  }

  return true;
}

//

function _form3()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;
  let opts = _.mapExtend( null, def.opts );

  if( product.subtype )
  {

    debugger;
    let defaultValue = product.makeDefault();
    debugger;
    if( !product.isTypeOfStructure({ src : defaultValue }) )
    {
      debugger;
      throw _.err( `Default ${ _.toStrShort( defaultValue ) } of ${product.qualifiedName} is not subtype of the definition` );
    }

  }

  return true;
}

//

function _makeDefaultAct( it )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;
  return product._makeDefaultSingletone( it );
}

//

function _isTypeOfStructureAct( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  let originalDefinition = sys.definition( product.type );
  let o2 = _.mapExtend( null, o );
  o2.definition = originalDefinition;
  if( !originalDefinition.product._isTypeOfStructureAct( o2 ) )
  return false;

  if( product.subtype )
  if( !product.subtype.isTypeOfStructure( o ) )
  return false;

  return true;
}

// --
// relations
// --

let Fields =
{
  type : null,
  default : null,
  subtype : null,
}

let Composes =
{
}

let Aggregates =
{
  type : null,
  default : null,
  subtype : null,
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
