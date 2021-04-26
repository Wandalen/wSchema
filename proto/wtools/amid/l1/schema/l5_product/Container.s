( function _Container_s_( )
{

'use strict';

//

const _ = _global_.wTools;

//

const Parent = _.schema.ProductScalar;
const Self = wSchemaProductContainer;
function wSchemaProductContainer( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'ProductContainer';

// --
// inter
// --

function _form2()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  if( product.container === null )
  product.container = 'auto';

  _.props.extend( product, def.opts );
  _.assert
  (
    _.strDefined( product.type ) || _.numberDefined( product.type ),
    () => `Container should have name of type definition, but ${def.qualifiedName} does not have`
  );
  _.assert( _.longHas( [ 'auto', 'array', 'map' ], product.container ) );

  return true;
}

//

function _form3()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  _.assert( product.actualContainer === null );

  product.actualContainer = product.container;

  let elementDefinition = sys.definition( product.type );

  _.assert( elementDefinition.formed >= 2 );

  // if( elementDefinition.formed < 2 )
  // return false;

  if( product.actualContainer === 'auto' )
  {
    product.actualContainer = elementDefinition.product.containerAutoTypeGet();
  }

  _.assert( _.longHas( [ 'array', 'map' ], product.actualContainer ) );

  if( product.actualContainer === 'array' )
  {
    product._makeContainer = product._makeContainerArray;
    product._elementAdd = product._elementAddToArray;
  }
  else
  {
    product._makeContainer = product._makeContainerMap;
    product._elementAdd = product._elementAddToMap;
  }

  product._formUsing();

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

  _.assert( arguments.length === 1 );
  _.assert( product.formed >= 2 );

  let elementDefinition = sys.definition( product.type );
  let it2 = product._makeDefaultIteration( it );
  let container = product._makeContainer();
  it2.onElementAdd = onElementAdd;
  let r = elementDefinition.product._makeDefaultAct( it2 );
  _.assert( r === undefined );

  it.onElementAdd({ value : container });

  function onElementAdd( o )
  {
    _.assert( arguments.length === 1 );
    if( o.value === _.nothing )
    {
      throw _.err( 'Cant add nothing to composition' );
    }
    _.assert( !o.container );
    o.container = container;
    product._elementAdd( o );
  }

}

//

function _makeContainerArray()
{
  return [];
}

//

function _elementAddToArray( o )
{
  o.container.push( o.value );
}

//

function _makeContainerMap()
{
  return Object.create( null );
}

//

function _elementAddToMap( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  _.sure
  (
    _.strIs( o.elementDescriptor.name ),
    `Element should have name to make default, but some elements of ${def.qualifiedName} does not have it`
  );

  o.container[ o.elementDescriptor.name ] = o.value;
}

// --
// exporter
// --

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

  let prefix = '';
  let postfix = '';
  if( product.container === 'auto' )
  prefix = '.';
  else
  postfix = 'container = ${product.container} ';

  if( o.optimizing && !elementDefinition.name && elementDefinition.isComplex() )
  {
    let o2 = _.props.extend( null, o );
    o2.prefix = prefix;
    o2.postfix = postfix ? `${postfix}\n` : postfix;
    o2.name = def.name || product.id;
    result = elementDefinition.product._exportStringVector( o2 );
  }
  else
  {
    result = `${product.grammarName} := (${prefix} ${elementDefinition.product.grammarName} ${postfix})`;
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
  container : null,
}

let Composes =
{
}

let Aggregates =
{
  type : null,
  container : null,
}

let Associates =
{
}

let Restricts =
{
  actualContainer : null,
  _makeContainer : null,
  _elementAdd : null,
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
  _makeContainerArray,
  _elementAddToArray,
  _makeContainerMap,
  _elementAddToMap,

  // exporter

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
