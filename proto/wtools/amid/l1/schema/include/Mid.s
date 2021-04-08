( function _IncludeMid_s_( )
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( './Base.s' );

  require( '../l1/Namespace.s' );

  require( '../l2/Sys.s' );

  require( '../l3/Predefined.s' );
  require( '../l3/Product.s' );
  require( '../l3/Subtype.s' );

  require( '../l4_product/Scalar.s' );
  require( '../l4_product/Vector.s' );

  require( '../l5_product/Alias.s' );
  require( '../l5_product/Alternative.s' );
  require( '../l5_product/Composition.s' );
  require( '../l5_product/Container.s' );
  require( '../l5_product/Multiplier.s' );
  require( '../l5_product/Terminal.s' );
  require( '../l5_product/Universal.s' );

  require( '../l8/Definition.s' );

}

if( typeof module !== 'undefined' )
module[ 'exports' ] = _global_.wTools;

})();
