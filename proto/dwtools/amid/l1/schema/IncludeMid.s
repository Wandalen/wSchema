( function _IncludeMid_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../Tools.s' );

  require( './IncludeBase.s' );

  require( './l1/Namespace.s' );

  require( './l2/Sys.s' );

  require( './l3/Predefined.s' );
  require( './l3/Product.s' );
  require( './l3/Subtype.s' );

  require( './l5/ProductAlias.s' );
  require( './l5/ProductAlternative.s' );
  require( './l5/ProductComposition.s' );
  require( './l5/ProductContainer.s' );
  require( './l5/ProductMultiplier.s' );
  require( './l5/ProductUniversal.s' );
  require( './l5/ProductTerminal.s' );

  require( './l8/Definition.s' );

}

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _global_.wTools;

})();
