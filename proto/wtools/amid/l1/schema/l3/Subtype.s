( function _Subtype_s_( )
{

'use strict';

//

const _ = _global_.wTools;

//

const Parent = null;
const Self = wSchemaSubtype;
function wSchemaSubtype( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Subtype';

// --
// inter
// --

function init( o )
{
  let subtype = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  _.workpiece.initFields( subtype );
  Object.preventExtensions( subtype );

  if( o )
  subtype.copy( o );

}

//

function form()
{
  let subtype = this;
  _.assert( subtype.definition instanceof _.schema.Definition );
  let def = subtype.definition;
  let sys = def.sys;

  _.map.assertHasOnly( subtype.structure, subtype.SubtypeFields );

  return subtype;
}

//

function isTypeOfStructure( o )
{
  let subtype = this;
  let def = subtype.definition;
  let sys = def.sys;

  _.assert( arguments.length === 1 );
  let result = subtype._isTypeOfStructureAct( o );
  _.assert( _.boolIs( result ) );
  return result;
}

//

function _isTypeOfStructureAct( o )
{
  let subtype = this;
  let def = subtype.definition;
  let sys = def.sys;
  return subtype.structure.identical === o.src;
}

// --
// relations
// --

let SubtypeFields =
{
  identical : null,
}

let Composes =
{
  structure : null,
}

let Aggregates =
{
}

let Associates =
{
  definition : null,
}

let Restricts =
{
  formed : 0,
}

let Statics =
{
  SubtypeFields,
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

  init,
  form,
  isTypeOfStructure,
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

_.Copyable.mixin( Self );
_.schema[ Self.shortName ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = _global_.wTools;

})();
