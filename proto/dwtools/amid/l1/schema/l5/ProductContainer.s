( function _ProductContainer_s_( ) {

'use strict';

//

let _ = _global_.wTools;

//

let Parent = _.schema.Product;
let Self = function wSchemaProductContainer( o )
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

  _.mapExtend( product, def.opts );
  _.assert( _.strDefined( product.type ) || _.numberDefined( product.type ), () => `Container should have name of type definition, but ${def.qualifiedName} does not have` );
  _.assert( _.longHas( [ 'auto', 'array', 'map' ], product.container ) );

  let elementDefinition = sys.definition( product.type );

  //debugger;
  if( elementDefinition.formed < 2 )
  return false;

  if( product.container === 'auto' )
  {
    product.container = elementDefinition.product.containerAutoTypeGet();
  }

  _.assert( _.longHas( [ 'array', 'map' ], product.container ) );

  // _.assert( product.multipliers.length === 0 );
  //
  // if( product.multipliers.length > 1 )
  // throw _.err( `Complex definition can have not more than one * element. ${product.qualifiedName} has ${product.multipliers.length}` );

  // if( product.multipliers.length || _.lengthOf( product.elementsMap ) === 0 )
  if( product.container === 'array' )
  {
    product._makeContainer = product._makeContainerArray;
    product._elementAdd = product._elementAddToArray;
  }
  else
  {
    product._makeContainer = product._makeContainerMap;
    product._elementAdd = product._elementAddToMap;
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

  _.assert( arguments.length === 1 );
  _.assert( product.formed >= 2 );

  let elementDefinition = sys.definition( product.type );
  // debugger;
  let it2 = product._makeDefaultIteration( it );
  // debugger;
  let container = product._makeContainer();
  it2.onElementAdd = onElementAdd;
  let r = elementDefinition.product._makeDefaultAct( it2 );
  _.assert( r === undefined );

  it.onElementAdd({ value : container });

  // function onElementAdd( value )
  // function onElementAdd( elementDefinition, elementDescriptor, result, value )
  function onElementAdd( o )
  {
    _.assert( arguments.length === 1 );
    if( o.value === _.nothing )
    {
      debugger;
      throw _.err( 'Cant add nothing to composition' );
    }
    _.assert( !o.container );
    o.container = container;
    product._elementAdd( o );
    // product._elementAdd( elementDefinition, elementDescriptor, result, value );
  }

  // for( let i = 0 ; i < product.elementsArray.length ; i++ )
  // {
  //   let elementDescriptor = product.elementsArray[ i ];
  //   let elementDefinition = sys.definition( elementDescriptor.type );
  //
  //   _.assert( _.routineIs( elementDefinition.product._makeDefaultAct ), `Definition ${elementDefinition.product.qualifiedName} deos not have method _makeDefaultAct` );
  //
  //   let it2 = product._makeDefaultIteration();
  //   it2.onElementAdd = onElementAdd;
  //   let r = elementDefinition.product._makeDefaultAct( it2 );
  //   _.assert( r === undefined );
  //
  //   function onElementAdd( value )
  //   {
  //     if( value === _.nothing )
  //     {
  //       debugger;
  //       throw _.err( 'Cant add nothing to composition' );
  //     }
  //     product._elementAdd( elementDefinition, elementDescriptor, result, value );
  //   }
  //
  // }
  //
  // it.onElementAdd( result );

}

//

function _makeContainerArray()
{
  return [];
}

//

// function _elementAddToArray( elementDefinition, elementDescriptor, container, value )
function _elementAddToArray( o )
{
  // debugger;
  o.container.push( o.value );
  // container.push( value );
}

//

function _makeContainerMap()
{
  return Object.create( null );
}

//

// function _elementAddToMap( elementDefinition, elementDescriptor, container, value )
function _elementAddToMap( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  _.sure( _.strIs( o.elementDescriptor.name ), `Element should have name to make default, but some elements of ${def.qualifiedName} does not have it` );

  o.container[ o.elementDescriptor.name ] = o.value;
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

  // productor

  _makeDefaultAct,
  _makeContainerArray,
  _elementAddToArray,
  _makeContainerMap,
  _elementAddToMap,

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
