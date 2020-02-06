( function _ProductComposition_s_( ) {

'use strict';

//

let _ = _global_.wTools;

//

let Parent = _.schema.Product;
let Self = function wSchemaProductComposition( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'ProductComposition';

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
  _.assert( product.multipliers.length === 0 );

  for( let i = 0 ; i < product.elementsArray.length ; i++ )
  {
    let element = product.elementsArray[ i ];
    let elementDefinition = sys.definition( element.type ).firstNonAlias();
    if( elementDefinition.kind === elementDefinition.Kind.multiplier )
    product.multipliers.push( element );
  }

  return true;
}

//

function _containerAutoTypeGetAct()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  _.assert( product.formed >= 2 );

  if( product.multipliers.length || ( _.lengthOf( product.elementsMap ) < product.elementsArray.length ) )
  return 'array';

  for( let i = 0 ; i < product.elementsArray.length ; i++ )
  {
    let elementDescriptor = product.elementsArray[ i ];
    let elementDefinition = sys.definition( elementDescriptor.type );
    _.assert( !!elementDefinition.product );
    let elementContainerType = elementDefinition.product._containerAutoTypeGetAct();

    _.assert( _.longHas( [ 'array', 'map', null ], elementContainerType ) );

    if( elementContainerType === 'array' )
    return 'array';

  }

  return 'map';
}

// --
// productor
// --

function _makeDefaultAct( it )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;
  // let result = product._makeContainer();
  // let result = it.makeContainer;
  //debugger;

  _.assert( arguments.length === 1 );

  for( let i = 0 ; i < product.elementsArray.length ; i++ )
  {
    let elementDescriptor = product.elementsArray[ i ];
    let elementDefinition = sys.definition( elementDescriptor.type );

    _.assert( _.routineIs( elementDefinition.product._makeDefaultAct ), `Definition ${elementDefinition.product.qualifiedName} deos not have method _makeDefaultAct` );

    let it2 = product._makeDefaultIteration();
    it2.onElementAdd = onElementAdd;
    let r = elementDefinition.product._makeDefaultAct( it2 );
    _.assert( r === undefined );

    // it.onElementAdd( elementDefinition, elementDescriptor, result, value );

    function onElementAdd( o )
    {
      if( o.value === _.nothing )
      {
        debugger;
        throw _.err( 'Cant add nothing to composition' );
      }
      // debugger;
      if( !o.elementDefinition )
      o.elementDefinition = elementDefinition;
      if( !o.elementDescriptor )
      o.elementDescriptor = elementDescriptor;
      it.onElementAdd( o );
      // product._elementAdd( value, elementDefinition, elementDescriptor, result );
    }

    // let it2 = product._makeDefaultIteration();
    // it2.onElementAdd = onElementAdd;
    // let r = elementDefinition.product._makeDefaultAct( it2 );

    // let it2 = product._makeDefaultIteration();
    // it2.onElementAdd = onElementAdd;
    // let r = elementDefinition.product._makeDefaultAct( it2 );
    // _.assert( r === undefined );

    // function onElementAdd( value )
    // {
    //   if( value === _.nothing )
    //   {
    //     debugger;
    //     throw _.err( 'Cant add nothing to composition' );
    //   }
    //   product._elementAdd( elementDefinition, elementDescriptor, result, value );
    // }

  }

  // it.onElementAdd( result );

}

//

function _isTypeOfStructureAct( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  x

  return true;
}

// //
//
// function _isTypeOfDefinitionVariants( o )
// {
//   let product = this;
//   let def = product.definition;
//   let sys = def.sys;
//
//   let t1 = 0;
//   let t2 = 0;
//   let variantsStack = [];
//
//   while( t1 < product.elementsArray.length )
//   {
//     let sup = product.elementsArray[ t1 ];
//
//     let o2 = _.mapExtend( null,  );
//     o2.sup = element1;
//     o2.sub = product.elementsArray.slice( t2 );
//     let variants = element2._isTypeOfDefinitionVariants( o2 );
//
//     if( variants.length === 0 )
//     return false;
//
//     variantsStack.push( variantsStack )
//
//
//
//   }
//
// }
//
// _isTypeOfDefinitionVariants.default =
// {
//   // ... _.schema.Product._isTypeOfDefinitionVariants.defaults,
//   sup : null,
//   sub : null,
// }

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

function _exportInfo( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  _.routineOptions( _exportInfo, arguments );
  _.assert( o.structure !== null );

  return product._exportInfoComplex( o );
  // let o2 = _.mapExtend( null, o );
  // o2.opener = '(';
  // o2.closer = ')';
  // return product._exportInfoComplex( o2 );
}

_exportInfo.defaults =
{
  ... _.schema.Product.prototype._exportInfo.defaults,
  // prefix : '',
  // postfix : '',
}

//

function _exportInfoComplex( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  _.routineOptions( _exportInfoComplex, arguments );

  let o2 = _.mapExtend( null, o );
  o2.opener = '(';
  o2.closer = ')';

  return Parent.prototype._exportInfoComplex.call( product, o2 );
}

_exportInfoComplex.defaults =
{
  ... _exportInfo.defaults,
  prefix : '',
  postfix : '',
}

// --
// relations
// --

let Fields =
{
  extend : null,
  supplement : null,
  bias : null,
}

let Composes =
{
}

let Aggregates =
{
  multipliers : _.define.own( [] ),
  elementsMap : null,
  elementsArray : null,
  bias : null,
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
  multiple : 'multiple',
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

  _containerAutoTypeGetAct,

  // productor

  _makeDefaultAct,
  _isTypeOfStructureAct,

  // exporter

  exportStructure,
  _exportInfo,
  _exportInfoComplex,

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
