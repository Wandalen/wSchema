( function _Namespace_s_( )
{

'use strict';

// if( typeof module !== 'undefined' )
// {
//
//   require( '../IncludeBase.s' );
//
// }

const _ = _global_.wTools;
const Self = _.schema = _.schema || Object.create( null );

let vectorize = _.routineDefaults( null, _.vectorize, { vectorizingContainerAdapter : 1, unwrapingContainerAdapter : 0 } );
let vectorizeAll = _.routineDefaults( null, _.vectorizeAll, { vectorizingContainerAdapter : 1, unwrapingContainerAdapter : 0 } );
let vectorizeAny = _.routineDefaults( null, _.vectorizeAny, { vectorizingContainerAdapter : 1, unwrapingContainerAdapter : 0 } );
let vectorizeNone = _.routineDefaults( null, _.vectorizeNone, { vectorizingContainerAdapter : 1, unwrapingContainerAdapter : 0 } )

// --
// inter
// --

function system()
{
  return _.schema.System( ... arguments );
}

// --
// declare
// --

let Restricts =
{

  vectorize,
  vectorizeAll,
  vectorizeAny,
  vectorizeNone,

}

let Extension =
{

  system,

  _ : Restricts,

}

_.props.extend( Self, Extension );

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = _global_.wTools;

})();
