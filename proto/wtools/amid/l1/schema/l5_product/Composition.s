( function _Composition_s_( )
{

'use strict';

//

const _ = _global_.wTools;

//

const Parent = _.schema.ProductVector;
const Self = wSchemaProductComposition;
function wSchemaProductComposition( o )
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

  if( !Parent.prototype._form2.apply( product, arguments ) )
  return false;

  for( let i = 0 ; i < product.elementsArray.length ; i++ )
  {
    let element = product.elementsArray[ i ];
    let elementDefinition = sys.definition( element.type ).firstNonAlias();
    if( elementDefinition.kind === elementDefinition.Kind.multiplier )
    product.multipliers.push( element );
  }

  return true;
}

// --
// helper
// --

function _containerAutoTypeGetAct()
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  _.assert( product.formed >= 2 );

  if( product.multipliers.length || ( _.entity.lengthOf( product.elementsMap ) < product.elementsArray.length ) )
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

  _.assert( arguments.length === 1 );

  for( let i = 0 ; i < product.elementsArray.length ; i++ )
  {
    let elementDescriptor = product.elementsArray[ i ];
    let elementDefinition = sys.definition( elementDescriptor.type );

    _.assert
    (
      _.routineIs( elementDefinition.product._makeDefaultAct ),
      `Definition ${elementDefinition.product.qualifiedName} deos not have method _makeDefaultAct`
    );

    let it2 = product._makeDefaultIteration();
    it2.onElementAdd = onElementAdd;
    let r = elementDefinition.product._makeDefaultAct( it2 );
    _.assert( r === undefined );

  }

  /* - */

  function onElementAdd( o )
  {
    if( o.value === _.nothing )
    {
      throw _.err( 'Cant add nothing to composition' );
    }
    if( !o.elementDefinition )
    o.elementDefinition = elementDefinition;
    if( !o.elementDescriptor )
    o.elementDescriptor = elementDescriptor;
    it.onElementAdd( o );
  }

}

//

function _isTypeOfStructureAct( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  _.assert( 0, 'not implemented' );

  return true;
}

// --
// exporter
// --

// function exportStructure( o )
// {
//   let product = this;
//   let def = product.definition;
//   let sys = def.sys;
//
//   o = _.routine.options_( exportStructure, arguments );
//
//   Parent.prototype.exportStructure.call( product, o );
//
//   o.dst.elements = [];
//
//   let o2 = _.props.extend( null, o );
//   o2.elements = product.elementsArray;
//   o2.dst = o.dst.elements;
//   product._elementsExportStructure( o2 );
//
//   return o.dst;
// }
//
// exportStructure.defaults =
// {
//   ... Parent.prototype.exportStructure.defaults,
// }

//

function _exportStringVector( o )
{
  let product = this;
  let def = product.definition;
  let sys = def.sys;

  _.routine.options_( _exportStringVector, arguments );

  let o2 = _.props.extend( null, o );
  o2.opener = '(';
  o2.closer = ')';

  return Parent.prototype._exportStringVector.call( product, o2 );
}

_exportStringVector.defaults =
{
  ... Parent.prototype._exportString.defaults,
  prefix : '',
  postfix : '',
}

// --
// relations
// --

let Fields =
{
  ... Parent.Fields,
}

let Composes =
{
}

let Aggregates =
{
  ... Parent.prototype.Aggregates,
  multipliers : _.define.own( [] ),
  // elementsMap : null,
  // elementsArray : null,
  // bias : null,
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

  // helper

  _containerAutoTypeGetAct,

  // productor

  _makeDefaultAct,
  _isTypeOfStructureAct,

  // exporter

  // exportStructure,
  // _exportString,
  _exportStringVector,

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
