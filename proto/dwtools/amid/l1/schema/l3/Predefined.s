( function _Predefined_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../IncludeBase.s' );

}

let _ = _global_.wTools;
let Self = _.schema.predefined = _.schema.predefined || Object.create( null );

// --
// inter
// --

function stringIs( it )
{
  return _.strIs( it.src );
}

//

function floatIs( it )
{
  return _.numberIs( it.src );
}

//

function intIs( it )
{
  return _.intIs( it.src );
}

//

function bigIntIs( it )
{
  return _.bigIntIs( it.src );
}

// --
// declare
// --

let string =
{
  is : stringIs,
}

let float =
{
  is : floatIs,
}

let int =
{
  is : intIs,
}

let bigInt =
{
  is : bigIntIs,
}

let Extend =
{

  string,
  float,
  int,
  bigInt,

}

_.mapExtend( Self, Extend );

//

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

})();
