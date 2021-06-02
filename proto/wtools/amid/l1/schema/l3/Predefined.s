( function _Predefined_s_( )
{

'use strict';

const _ = _global_.wTools;
_.schema.predefined = _.schema.predefined || Object.create( null );

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

let Extension =
{

  string,
  float,
  int,
  bigInt,

}

/* _.props.extend */Object.assign( _.schema.predefined, Extension );

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = _global_.wTools;

})();
