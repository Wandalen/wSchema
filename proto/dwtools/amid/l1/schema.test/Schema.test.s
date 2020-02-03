( function _Schema_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../Tools.s' );
  _.include( 'wTesting' );
  require( '../schema/IncludeMid.s' );

}

//

var _ = _global_.wTools;

// --
// tests
// --

function form( test )
{
  let context = this;

  /* and, or, selector, scalar, identical, has */

  let schema = _.schema.system({ name : 'Schema.test/subtype' });

  schema.define( 'string' ).terminal({ default : '' });

  schema.define( 'simple' ).composition().extend
  ({
    kind : { type : 'string', default : '' },
    value : { type : 'string', default : '' },
  });

  schema.form();

  test.description = 'each definition is formed';
  for( let d = 0 ; d < schema.definitionsArray.length ; d++ )
  {
    let def = schema.definitionsArray[ d ];
    test.identical( def.formed, 3 );
    test.is( def.product instanceof _.schema.Product );
  }

  test.description = 'expected number of definitions';
  test.identical( _.lengthOf( schema.definitionsMap ), 4 );
  test.identical( _.lengthOf( schema.definitionsArray ), 6 );
  test.identical( _.lengthOf( schema.definitionsToForm2Array ), 0 );
  test.identical( _.lengthOf( schema.definitionsToForm3Array ), 0 );

  test.description = 'no definitions left after finit';
  schema.finit();
  test.identical( _.lengthOf( schema.definitionsMap ), 0 );
  test.identical( _.lengthOf( schema.definitionsArray ), 0 );
  test.identical( _.lengthOf( schema.definitionsToForm2Array ), 0 );
  test.identical( _.lengthOf( schema.definitionsToForm3Array ), 0 );

}

form.description =
`
form produces definitions
finit destroys definitions
`

//

function exportInfo( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Nodes' });

  schema.define( 'null' ).terminal({ default : _.null });
  schema.define( 'string' ).terminal({ default : '' });
  schema.define( 'number' ).terminal({ default : 0 });
  schema.define( 'boolean' ).terminal({ default : false });
  schema.define( 'Identifier' ).composition().extend
  ({
    type : { type : 'string' },
    name : { type : 'string' },
  });
  schema.define( 'Literal' ).composition().extend
  ({
    type : { type : 'string', default : '' },
    value : { type : '[ boolean number string null ]', default : 'null' },
    raw : { type : 'string', default : '' },
  });
  schema.define( 'Literal2' ).composition().extend
  ({
    type : { type : 'string', default : '' },
    value : '[ boolean number string null ]',
    raw : { type : 'string', default : '' },
  });
  schema.define( 'ArrayExpressionElement2' ).alternative().fromFields({ default : 'Expression' }).extend
  ([
    'Expression',
    _.nothing,
  ]);
  schema.define({ name : 'Expression' }).alternative().fromFields({ default : 'Identifier' }).extend
  ([
    'Identifier',
    'Literal',
  ]);

  schema.form();

  var exp =
`
schema::Nodes

  definition.universal :: ❮nothing❯ ## 1
    symbol : {- Symbol nothing -}

  definition.universal :: ❮anything❯ ## 2
    symbol : {- Symbol anything -}

  definition.terminal :: null ## 3
    default : {- Symbol null -}

  definition.terminal :: string ## 4
    default :

  definition.terminal :: number ## 5
    default : 0

  definition.terminal :: boolean ## 6
    default : false

  definition.composition :: Identifier ## 7
    elements
      string :: type
      string :: name

  definition.composition :: Literal ## 8
    elements
      12 :: type
      13 :: value
      14 :: raw

  definition.composition :: Literal2 ## 9
    elements
      15 :: type
      16 :: value
      17 :: raw

  definition.alternative :: ArrayExpressionElement2 ## 10
    default : Expression
    elements
      Expression ::
      ❮nothing❯ ::

  definition.alternative :: Expression ## 11
    default : Identifier
    elements
      Identifier ::
      Literal ::

  definition.alias ## 12
    type : string
    default :

  definition.alternative ## 13
    default : null
    elements
      boolean ::
      number ::
      string ::
      null ::

  definition.alias ## 14
    type : string
    default :

  definition.alias ## 15
    type : string
    default :

  definition.alternative ## 16
    elements
      boolean ::
      number ::
      string ::
      null ::

  definition.alias ## 17
    type : string
    default :
`
  var got = schema.exportInfo();
  test.equivalent( got, exp );
  logger.log( got );

  schema.finit();
}

exportInfo.description =
`
exportInfo produce nice output
`

//

function makeDefault( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Nodes' });

  schema.define( 'null' ).terminal({ default : _.null });
  schema.define( 'string' ).terminal({ default : '' });
  schema.define( 'number' ).terminal({ default : 0 });
  schema.define( 'boolean' ).terminal({ default : false });
  schema.define( 'Identifier' ).composition().extend
  ({
    type : { type : 'string' },
    name : { type : 'string' },
  });
  schema.define( 'Literal' ).composition().extend
  ({
    type : { type : 'string', default : '' },
    value : { type : '[ boolean number string null ]', default : 'null' },
    raw : { type : 'string', default : '' },
  });
  schema.define( 'Literal2' ).composition().extend
  ({
    type : { type : 'string', default : '' },
    value : '[ boolean number string null ]',
    raw : { type : 'string', default : '' },
  });
  schema.define( 'ArrayExpressionElement2' ).alternative().fromFields({ default : 'Expression' }).extend
  ([
    'Expression',
    _.nothing,
  ]);
  schema.define({ name : 'Expression' }).alternative().fromFields({ default : 'Identifier' }).extend
  ([
    'Identifier',
    'Literal',
  ]);

  schema.form();

  test.case = 'Identifier';
  var exp = { type : '', name : '' };
  var identifier = schema.definition( 'Identifier' ).makeDefault();
  test.identical( identifier, exp );

  test.case = 'Expression';
  var exp = { type : '', name : '' };
  var identifier = schema.definition( 'Expression' ).makeDefault();
  test.identical( identifier, exp );

  test.case = 'Literal';
  var exp = { 'type' : '', 'value' : null, 'raw' : '' };
  var identifier = schema.definition( 'Literal' ).makeDefault();
  test.identical( identifier, exp );

  test.case = 'ArrayExpressionElement2';
  var exp = { 'type' : '', 'name' : '' };
  var identifier = schema.definition( 'ArrayExpressionElement2' ).makeDefault();
  test.identical( identifier, exp );

  schema.finit();
}

makeDefault.description =
`
forming throw no errors
making default produces default structure for alternative, composition and terminal
`

//

function makeDefaultMultiple( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Nodes' });

  schema.define( 'null' ).terminal({ default : _.null });
  schema.define( 'string' ).terminal({ default : '' });
  schema.define( 'number' ).terminal({ default : 0 });
  schema.define( 'boolean' ).terminal({ default : false });
  schema.define( 'Identifier' ).composition().extend
  ({
    type : { type : 'string' },
    name : { type : 'string' },
  });
  schema.define( 'Literal' ).composition().extend
  ({
    type : { type : 'string', default : '' },
    value : { type : '[ boolean number string null ]', default : 'null' },
    raw : { type : 'string', default : '' },
  });
  schema.define( 'ArrayExpression' ).composition().extend
  ({
    type : { type : 'string', default : '' },
    elements : { type : '( *ArrayExpressionElement )' },
  });
  schema.define( 'ArrayExpressionElement' ).alternative().fromFields({ default : _.nothing }).extend
  ([
    'Expression',
    _.nothing,
  ]);
  schema.define({ name : 'Expression' }).alternative().fromFields({ default : 'Identifier' }).extend
  ([
    'Identifier',
    'Literal',
  ]);

  schema.form();

  test.case = 'ArrayExpression';
  var exp = { 'type' : '', 'elements' : [] };
  var identifier = schema.definition( 'ArrayExpression' ).makeDefault();
  test.identical( identifier, exp );

  schema.finit();
}

makeDefaultMultiple.description =
`
- forming throw no errors
- making default produces default structure for multiplier
`

//

function makeDefaultCompositionsNotNamedElements( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Nodes' });

  schema.define( 'null' ).terminal({ default : _.null });
  schema.define( 'string' ).terminal({ default : '' });
  schema.define( 'number' ).terminal({ default : 0 });
  schema.define( 'boolean' ).terminal({ default : false });

  schema.define( 'composition1' ).composition().extend
  ([
    { type : 'string' },
    { type : 'null' },
    { type : 'string' },
  ]);

  schema.define( 'composition2' ).composition().extend
  ([
    { type : 'number' },
    { type : 'composition1' },
    { type : 'number' },
  ]);

  schema.define( 'container' ).container({ container : 'auto', type : 'composition2' });

  schema.form();

  test.case = 'container';
  var exp = [ 0, '', null, '', 0 ];
  var identifier = schema.definition( 'container' ).makeDefault();
  test.identical( identifier, exp );

  schema.finit();
}

makeDefaultCompositionsNotNamedElements.description =
`
- forming throw no errors
- both inner and outer compositions put elements in the same array
`

//

function makeDefaultCompositionsNamedElements( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Nodes' });

  schema.define( 'null' ).terminal({ default : _.null });
  schema.define( 'string' ).terminal({ default : '' });
  schema.define( 'number' ).terminal({ default : 0 });
  schema.define( 'boolean' ).terminal({ default : false });

  schema.define( 'composition1' ).composition().extend
  ([
    { name : 'name', type : 'string' },
    { name : 'n', type : 'null' },
    { name : 'value', type : 'string' },
  ]);

  schema.define( 'composition2' ).composition().extend
  ([
    { name : 'id', type : 'number' },
    { name : 'comp1', type : 'composition1' },
    { name : 'handle', type : 'number' },
  ]);

  schema.define( 'container' ).container({ container : 'auto', type : 'composition2' });

  schema.form();

  test.case = 'container';
  var exp = { id : 0, name : '', n : null, value : '', handle : 0 };
  var identifier = schema.definition( 'container' ).makeDefault();
  test.identical( identifier, exp );

  schema.finit();
}

makeDefaultCompositionsNamedElements.description =
`
- forming throw no errors
- both inner and outer compositions put elements in the same map
- auto determining of type of container determines map, not array
`

//

function makeDefaultCompositionsNamedElementsButOneInner( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Nodes' });

  schema.define( 'null' ).terminal({ default : _.null });
  schema.define( 'string' ).terminal({ default : '' });
  schema.define( 'number' ).terminal({ default : 0 });
  schema.define( 'boolean' ).terminal({ default : false });

  schema.define( 'composition1' ).composition().extend
  ([
    { name : 'name', type : 'string' },
    { type : 'null' },
    { name : 'value', type : 'string' },
  ]);

  schema.define( 'composition2' ).composition().extend
  ([
    { name : 'id', type : 'number' },
    { name : 'comp1', type : 'composition1' },
    { name : 'handle', type : 'number' },
  ]);

  schema.define( 'container' ).container({ container : 'auto', type : 'composition2' });

  schema.form();

  test.case = 'container';
  var exp = [ 0, '', null, '', 0 ];
  var identifier = schema.definition( 'container' ).makeDefault();
  test.identical( identifier, exp );

  schema.finit();
}

makeDefaultCompositionsNamedElementsButOneInner.description =
`
- forming throw no errors
- both inner and outer compositions put elements in the same array
- auto determining of type of container determines array because inner map has anonymous element
`

//

function makeDefaultCompositionsFromString( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Nodes' });
  let schemaString =
`
  @null := terminal default = null
  @string := terminal default = ''
  @number := terminal default = ' 0 '<-js
  @boolean := terminal default = ' false '<-js
  @alternative1 := [ @number @string default = @string ]
  @composition1 :=
  (
    @name := @string
    := null
    @value := @string
    container = none
  )
  @container :=
  (
    @id := @number
    @comp1 := @composition1
    @handle := @number
    $
  )
`

  schema.fromString( schemaString );
  schema.form();

  test.case = 'container';
  var exp = [ 0, '', null, '', 0 ];
  var identifier = schema.definition( 'container' ).makeDefault();
  test.identical( identifier, exp );

  schema.finit();
}

makeDefaultCompositionsFromString.description =
`
- making definitions from string produce the same result as making it manually
- forming throw no errors
- both inner and outer compositions put elements in the same array
- auto determining of type of container determines array because inner map has anonymous element
`

//

function defineVectorized( test )
{
  let context = this;

  let schema = _.schema.system({ name : 'Nodes' });

  schema.define([ 'FunctionDeclaration', 'FunctionExpression', 'ArrowFunctionExpression' ]).terminal().fromFields({ default : 'abc' });
  schema.form();

  test.case = 'FunctionExpression';
  var exp = 'abc';
  var identifier = schema.definition( 'FunctionExpression' ).makeDefault();
  test.identical( identifier, exp );

  /* logger.log( schema.exportInfo() ); */
  schema.finit();
}

defineVectorized.description =
`
define defines multiple definitions for array of names of definitions
`

//

function label( test )
{
  let context = this;

  let schema = _.schema.system({ name : 'Nodes' });

  schema.define( 'def1' ).label( 'native' ).terminal();
  schema.define( 'def2' ).label({ 'native' : false }).terminal({ default : 'abc' });
  schema.define( 'def3' ).label([ 'native' ]).terminal();
  schema.define( 'def4' ).terminal();
  schema.form();

  test.identical( schema.definition( 'def1' ).labels, { native : true } );
  test.identical( schema.definition( 'def2' ).labels, { native : false } );
  test.identical( schema.definition( 'def3' ).labels, { native : true } );
  test.identical( schema.definition( 'def4' ).labels, {} );

  var exp = 'abc';
  var identifier = schema.definition( 'def2' ).makeDefault();
  test.identical( identifier, exp );

  schema.finit();
}

label.description =
`
- define multiple definitions for array of names of definitions
`

//

function subtype( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Schema.test/subtype' });

  schema.define( 'string' ).terminal({ default : '', onCheck : _.schema.predefined.string.is });

  schema.define( 'simple' ).composition().extend
  ({
    kind : { type : 'string', default : '' },
    value : { type : 'string', default : '' },
    comments : { type : 'string', subtype : { identical : 'constant' } },
  });

  schema.form();

  test.case = 'make definition::simple';
  var exp = { 'kind' : '', 'value' : '', 'comments' : 'constant' };
  var got = schema.definition( 'simple' ).makeDefault();
  test.identical( got, exp );

  schema.finit();
  debugger;
}

subtype.description =
`
- indetical of subtype reset default
`

//

function subtypeWrongDefault( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Schema.test/subtype' });

  schema.define( 'string' ).terminal({ default : '', onCheck : _.schema.predefined.string.is });

  schema.define( 'simple' ).composition().extend
  ({
    kind : { type : 'string', default : '' },
    value : { type : 'string', default : '' },
    comments : { type : 'string', subtype : { identical : 'constant' }, default : 'constant2' },
  });

  test.shouldThrowErrorSync( () => schema.form() );

  schema.finit();
  debugger;
}

subtypeWrongDefault.description =
`
- forming of an definition with default wich does not fit subtype throw error on forming
`

//

function compositionSpecification( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Schema.test/Specification' });

  schema.define( 'string' ).terminal({ default : '', onCheck : _.schema.predefined.string.is });
  schema.define( 'float' ).terminal({ default : '', onCheck : _.schema.predefined.float.is });

  schema.define( 'simple' ).composition().extend
  ({
    kind : { type : 'string', default : '' },
    value : { type : 'string', default : '' },
    comments : { type : 'string', subtype : { identical : 'constant' }, default : 'constant' },
  });

  schema.define( 'selector' ).composition().supplement( 'simple' ).extend
  ({
    kind : { subtype : { identical : 'sel' } },
  });

  schema.define( 'scalar' ).composition().supplement( 'simple' ).extend
  ({
    kind : { type : 'float', subtype : { identical : 13 } },
  });

  schema.form();

  test.case = 'make definition::simple';
  var exp = { 'kind' : '', 'value' : '', 'comments' : 'constant' };
  var identifier = schema.definition( 'simple' ).makeDefault();
  test.identical( identifier, exp );

  test.case = 'make definition::selector';
  var exp = { 'kind' : 'sel', 'value' : '', 'comments' : 'constant' };
  var identifier = schema.definition( 'selector' ).makeDefault();
  test.identical( identifier, exp );

  test.case = 'make definition::scalar';
  var exp = { 'kind' : 13, 'value' : '', 'comments' : 'constant' };
  var identifier = schema.definition( 'scalar' ).makeDefault();
  test.identical( identifier, exp );

  logger.log( schema.exportInfo() );
  schema.finit();
  debugger;
}

compositionSpecification.description =
`
- inheritance by extend add new elements
- inheritance by extend replace old elements
- if type of element is not defined then type of original element used if available
`

//

function isTypeOfStructure( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Schema.test/Specification' });

  schema.define( 'string' ).terminal({ default : '', onCheck : _.schema.predefined.string.is });
  schema.define( 'float' ).terminal({ default : '', onCheck : _.schema.predefined.float.is });

  schema.define( 'simple' ).composition().extend
  ({
    kind : { type : 'string', default : '' },
    value : { type : 'string', default : '' },
    comments : { type : 'string', subtype : { identical : 'constant' }, default : 'constant' },
  });

  schema.define( 'selector1' ).composition().supplement( 'simple' ).extend
  ({
    kind : { subtype : { identical : 'sel1' } },
  });

  schema.define( 'selector2' ).composition().supplement( 'simple' ).extend
  ({
    kind : { subtype : { identical : 'sel2' } },
  });

  schema.define( 'scalar' ).composition().supplement( 'simple' ).extend
  ({
    kind : { type : 'float', subtype : { identical : 13 } },
  });

  schema.form();

  test.case = 'cehck definition::simple definition::selector1';
  var exp = true;
  var structure = { kind : 'sel1', value : 'some value', comments : 'constant' };
  debugger;
  var identifier = schema.definition( 'simple' ).isTypeOf( structure );
  test.identical( identifier, exp );

  logger.log( schema.exportInfo() );
  schema.finit();
  debugger;
}

isTypeOfStructure.description =
`
xxx
`

//

function isTypeOfDefinition( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Schema.test/Specification' });

  schema.define( 'string' ).terminal({ default : '', onCheck : _.schema.predefined.string.is });
  schema.define( 'float' ).terminal({ default : '', onCheck : _.schema.predefined.float.is });

  schema.define( 'simple' ).composition().extend
  ({
    kind : { type : 'string', default : '' },
    value : { type : 'string', default : '' },
    comments : { type : 'string', subtype : { identical : 'constant' }, default : 'constant' },
  });

  schema.define( 'selector1' ).composition().supplement( 'simple' ).extend
  ({
    kind : { subtype : { identical : 'sel1' } },
  });

  schema.define( 'selector2' ).composition().supplement( 'simple' ).extend
  ({
    kind : { subtype : { identical : 'sel2' } },
  });

  schema.define( 'scalar' ).composition().supplement( 'simple' ).extend
  ({
    kind : { type : 'float', subtype : { identical : 13 } },
  });

  schema.form();

  // test.case = 'cehck definition::simple definition::simple';
  // var exp = true;
  // var identifier = schema.definition( 'simple' ).isTypeOf( schema.definition( 'simple' ) );
  // test.identical( identifier, exp );

  test.case = 'cehck definition::simple definition::selector1';
  var exp = true;
  var identifier = schema.definition( 'simple' ).isTypeOf( schema.definition( 'selector1' ) );
  test.identical( identifier, exp );

  // test.case = 'cehck definition::simple definition::selector2';
  // var exp = true;
  // var identifier = schema.definition( 'simple' ).isTypeOf( schema.definition( 'selector2' ) );
  // test.identical( identifier, exp );
  //
  // test.case = 'cehck definition::selector1 definition::selector2';
  // var exp = false;
  // var identifier = schema.definition( 'selector1' ).isTypeOf( schema.definition( 'selector2' ) );
  // test.identical( identifier, exp );
  //
  // test.case = 'cehck definition::selector2 definition::selector1';
  // var exp = false;
  // var identifier = schema.definition( 'selector2' ).isTypeOf( schema.definition( 'selector1' ) );
  // test.identical( identifier, exp );
  //
  // test.case = 'cehck definition::scalar definition::selector1';
  // var exp = false;
  // var identifier = schema.definition( 'scalar' ).isTypeOf( schema.definition( 'selector1' ) );
  // test.identical( identifier, exp );
  //
  // test.case = 'cehck definition::selector1 definition::scalar';
  // var exp = false;
  // var identifier = schema.definition( 'selector1' ).isTypeOf( schema.definition( 'scalar' ) );
  // test.identical( identifier, exp );
  //
  // test.case = 'cehck definition::simple definition::scalar';
  // var exp = false;
  // var identifier = schema.definition( 'simple' ).isTypeOf( schema.definition( 'scalar' ) );
  // test.identical( identifier, exp );
  //
  // test.case = 'cehck definition::scalar definition::simple';
  // var exp = false;
  // var identifier = schema.definition( 'scalar' ).isTypeOf( schema.definition( 'simple' ) );
  // test.identical( identifier, exp );

  logger.log( schema.exportInfo() );
  schema.finit();
  debugger;
}

isTypeOfDefinition.description =
`
xxx
`

//

function logic( test )
{
  let context = this;

  let request =
  {
    kind : 'and',
    elements :
    [
      {
        kind : 'has',
        left : { kind : 'selector', value : '@code' },
        right :
        {
          kind : 'and',
          elements :
          [
            {
              kind : 'scalar',
              value : 'test.setsAreIdentical',
            }
          ],
        }
      },
      {
        kind : 'identical',
        left : { kind : 'selector', value : '.../@type' },
        right : { kind : 'or', elements :
        [
          {
            kind : 'scalar',
            value : 'call_expression',
          },
          {
            kind : 'scalar',
            value : 'expression_statement',
          },
        ]},
      },
    ],
  }

  /* and, or, has, selector, scalar, identical, has */

  let schema = _.schema.system({ name : 'Schem.test/Logic' });

  schema.define( 'complex' ).composition
  ({
    kind : { type : 'string', default : '' },
    elements : { type : '( *element )' },
  });

  schema.define( 'simple' ).composition
  ({
    kind : { type : 'string', default : '' },
    value : { type : 'primitive', default : _.null },
  });

  schema.define( 'operator2' ).composition
  ({
    kind : { type : 'string', default : '' },
    left : { type : 'element', default : _.null },
  });

  schema.define( 'element' ).alternative([ 'complex', 'simple' ]);

  var exp = 'abc';
  var identifier = schema.definition( 'def2' ).makeDefault();
  test.identical( identifier, exp );

  schema.finit();
}

logic.description =
`
`

// --
// declare
// --

var Proto =
{

  name : 'Tools.mid.Schema',
  silencing : 1,
  routineTimeOut : 30000,

  context :
  {

  },

  tests :
  {

    form,
    exportInfo,
    makeDefault,
    makeDefaultMultiple,
    makeDefaultCompositionsNotNamedElements,
    makeDefaultCompositionsNamedElements,
    makeDefaultCompositionsNamedElementsButOneInner,
    makeDefaultCompositionsFromString,

    defineVectorized,
    label,

    subtype,
    subtypeWrongDefault,
    compositionSpecification,
    isTypeOfStructure,
    // isTypeOfDefinition,
    // logic,

  },

}

//

var Self = new wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
