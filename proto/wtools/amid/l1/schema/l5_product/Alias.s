( function _Alias_s_( )
{

'use strict';

//

const _ = _global_.wTools;

//

const Parent = _.schema.ProductScalar;
const Self = wSchemaProductAlias;
function wSchemaProductAlias( o )
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
  let opts = _.props.extend( null, def.opts );

  _.props.extend( product, def.opts );
  _.assert
  (
    _.strDefined( product.type ) || _.numberDefined( product.type ),
    () => `Alias should have name of type definition, but ${def.qualifiedName} does not have`
  );

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

  // product._formUsing();

  return true;
}

//

function _form3()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;
  let opts = _.props.extend( null, def.opts );

  // debugger;
  product._formUsing();

  if( product.subtype )
  {

    let defaultValue = product.makeDefault();
    if( !product.isTypeOfStructure({ src : defaultValue }) )
    {
      throw _.err
      (
        `Default ${ _.entity.exportStringDiagnosticShallow( defaultValue ) } of ${product.qualifiedName} is not subtype of the definition`
      );
    }

  }

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
  return product._makeDefaultSingletone( it );
}

//

function _isTypeOfStructureAct( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  let originalDefinition = sys.definition( product.type );
  let o2 = _.props.extend( null, o );
  o2.definition = originalDefinition;
  if( !originalDefinition.product._isTypeOfStructureAct( o2 ) )
  return false;

  if( product.subtype )
  if( !product.subtype.isTypeOfStructure( o ) )
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

  if( o.format === 'dump' )
  return Parent.prototype._exportString.call( this, o );

  let result;
  let elementDefinition = sys.definition( def.product.type );

  if( product.default === null && product.subtype === null )
  {
    result = `${product.grammarName} := ${elementDefinition.product.grammarName}`;
  }
  else
  {
    _.assert( product.subtype === null, 'not tested' );
    result = `${product.grammarName} := ( ${elementDefinition.product.grammarName}`;
    if( product.default !== null )
    result += ` default = ${_.entity.exportString( product.default )}`;
    if( product.subtype !== null )
    result += ` subtype = ${_.entity.exportString( product.subtype )}`;
    result += ` )`;
  }

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
