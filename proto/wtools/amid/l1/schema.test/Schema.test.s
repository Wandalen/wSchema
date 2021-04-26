( function _Schema_test_s_( )
{

'use strict';

if( typeof module !== 'undefined' )
{

  const _ = require( '../../../../node_modules/Tools' );
  _.include( 'wTesting' );
  require( '../schema/Include.s' );

}

//

const _ = _global_.wTools;

// --
// context
// --

function grammarPalindrom()
{

  let schema = _.schema.system({ name : 'SchemaTest/grammarPalindrom' });
  let tokensSyntax = _.tokensSyntaxFrom
  ({
    'space'             : /\s+/,
    'name'              : /[a-z_\$][0-9a-z_\$]*/i,
    'sign_plus'         : '+',
    'sign_minus'        : '-',
  });

  schema.defineFromSyntax( tokensSyntax );

  schema
  .define( 'sign_optional' )
  .alternative()
  .extend([ 'sign_plus', 'sign_minus', '❮nothing❯' ]);

  var id = schema.define().composition({ bias : 'right' })
  .extend
  ({
    left : 'exp',
    sign : 'sign_optional',
    right : 'exp',
  })
  .id;
  schema.define( 'exp2' ).container({ type : id });

  schema.define( 'exp' ).alternative({ bias : 'right' })
  .extend([ 'name', 'exp2' ]);

  schema.form();
  return schema;
}

//

function grammarExpression1()
{

  let schema = _.schema.system({ name : 'SchemaTest/grammarExpression1' });
  let tokensSyntax = _.tokensSyntaxFrom
  ({
    'mul'               : '*',
    'plus'              : '+',
    'space'             : /\s+/,
    'name'              : /[a-z_\$][0-9a-z_\$]*/i,
    'number'            : /(?:0x(?:\d|[a-f])+|\d+(?:\.\d+)?(?:e[+-]?\d+)?)/i,
    'parenthes_open'    : '(',
    'parenthes_close'   : ')',
  });

  schema.defineFromSyntax( tokensSyntax );

  schema
  .define( 'factor' )
  .alternative()
  .extend([ 'name', 'number' ]);

  var id = schema.define().composition({ bias : 'right' })
  .extend({ left : 'exp' })
  .extend([ 'mul' ])
  .extend({ right : 'exp' })
  .id;
  schema.define( 'exp_mul' ).container({ type : id });

  var id = schema.define().composition({ bias : 'right' })
  .extend
  ({
    left : 'exp',
    plus : { type : 'plus', including : 0 },
    right : 'exp',
  })
  .id;
  schema.define( 'exp_plus' ).container({ type : id });

  var id = schema.define().composition({ bias : 'right' })
  .extend
  ([
    { type : 'parenthes_open', including : 0 },
    { type : 'exp', name : 'exp' },
    { type : 'parenthes_close', including : 0 },
  ])
  .id;
  schema.define( 'exp_parenthes' ).container({ type : id });

  schema.define( 'exp' ).alternative({ bias : 'right' })
  .extend([ 'factor', 'exp_mul', 'exp_plus', 'exp_parenthes' ]);

  schema.form();
  return schema;
}

//

function grammarExpression2()
{

  /*

    e : = terminal
    nothing := special
    /name := terminal
    /sign_plus := terminal
    /sign_minus := terminal
    /sign_optional := [ /sign_plus /sign_minus nothing ]
    /exp2 := (< /exp /sign_optional /exp )
    /exp := [ /name /exp2 ]

  */

  let schema = _.schema.system({ name : 'SchemaTest/grammarExpression2' });
  let tokensSyntax = _.tokensSyntaxFrom
  ({
    'name'              : /[a-z_\$][0-9a-z_\$]*/i,
    'sign_plus'         : '+',
    'sign_minus'        : '-',
  });

  schema.defineFromSyntax( tokensSyntax );

  schema
  .define( 'sign_optional' )
  .alternative()
  .extend([ 'sign_plus', 'sign_minus' ]);

  schema.define( 'exp2' ).composition({ bias : 'right' })
  .extend([ 'exp', 'sign_optional', 'exp' ]);

  schema
  .define( 'exp' )
  .alternative()
  .extend([ 'name', 'exp2' ]);

  schema.form();
  return schema;
}

//

function grammarOwn()
{
  let schema = _.schema.system({ name : 'SchemaTest/grammarOwn' });
  let tokensSyntax = _.tokensSyntaxFrom
  ({
    'colon_equal'       : ':=',
    'equal'             : '=',
    'left'              : '<-',
    'right'             : '->',
    'multiple_optional' : '?',
    'multiple_any'      : '*',
    'space'             : /\s+/,
    'string_single'     : /'(?:\\\n|\\'|[^'\n])*?'/,
    'name_kind'         : [ 'terminal' ],
    'name_directive'    : [ 'default', 'container' ],
    'name_literal'      : [ 'null', 'true', 'false' ],
    'name_at'           : /@[a-z_\$][0-9a-z_\$]*/i,
    'name_slash'        : /\/[a-z_\$][0-9a-z_\$]*/i,
    'name_clean'        : /[a-z_\$][0-9a-z_\$]*/i,
    'number'            : /(?:0x(?:\d|[a-f])+|\d+(?:\.\d+)?(?:e[+-]?\d+)?)/i,
    'parenthes_open'    : '(',
    'parenthes_close'   : ')',
    'square_open'       : '[',
    'square_close'      : ']',
  });

  schema.defineFromSyntax( tokensSyntax );

  /* */

  schema.define( 'statement_top' ).container({ container : 'map', type : 'statement_top_' });

  schema.define( 'statement_top_' ).composition()
  .extend([ { type : 'statement_top_left', including : true } ])
  .extend
  ({
    multiple : { type : 'multiple_maybe' },
    right : { type : 'statement_top_right' },
  });

  schema.define( 'statement_top_left' ).composition()
  .extend
  ({
    left : { type : 'name_slash' },
    including : { type : 'colon_equal' },
  })

  schema
  .define( 'statement_top_right' )
  .alternative()
  .extend([ 'name_kind', 'name_slash', 'block' ]);

  /* */

  schema.define( 'statement_in' ).container({ container : 'map', type : 'statement_in_' });

  schema.define( 'statement_in_' ).composition()
  .extend([ { type : 'statement_in_left', including : true } ])
  .extend
  ({
    multiple : { type : 'multiple_maybe' },
    right : { type : 'statement_in_right' },
  });

  schema.define( 'statement_in_left' ).composition()
  .extend
  ({
    left : { type : 'name_at' },
    including : { type : 'colon_equal' },
  })

  schema
  .define( 'statement_in_right' )
  .alternative()
  .extend([ 'name_slash', 'block' ]);

  /* */

  schema.define( 'directive' ).container({ type : 'directive_' });

  schema.define( 'directive_' ).composition()
  .extend
  ([
    { type : 'name_directive', including : false },
    { type : 'equal', including : false },
  ])
  .extend
  ({
    value : { type : 'directive_value' },
  });
  schema
  .define( 'directive_value' )
  .alternative()
  .extend([ 'literal', 'name_slash' ]);

  /* */

  schema.define( 'string' ).container({ type : 'string_' });

  schema.define( 'string_' ).composition()
  .extend
  ({
    value : { type : 'string_single' },
    kind : { type : 'string_right' },
  })

  schema.define( 'string_right' ).multiplier({ multiple : [ 0, 1 ], type : 'string_right_' });
  schema.define( 'string_right_' ).composition()
  .extend
  ([
    { type : 'left', including : false },
    { type : 'name_clean', including : true },
  ])

  /* */

  schema
  .define( 'composition' )
  .composition()
  .extend
  ([
    { type : 'parenthes_open', including : false },
    { type : 'block_content', including : true },
    { type : 'parenthes_open', including : false },
  ]);

  schema
  .define( 'alternative' )
  .composition()
  .extend
  ([
    { type : 'square_open', including : false },
    { type : 'block_content', including : true },
    { type : 'square_open', including : false },
  ]);

  schema.define( 'block_content' ).multiplier({ multiple : [ 0, Infinity ], type : 'block_content_' });

  schema
  .define( 'block_content_' )
  .alternative()
  .extend
  ([
    { type : 'statement_in' },
    { type : 'directive' }
  ]);

  schema.define( 'multiple_maybe' ).multiplier({ multiple : [ 0, 1 ], type : 'multiple' });

  schema.define( 'multiple' ).alternative()
  .extend
  ({
    a : { type : 'multiple_optional' },
    b : { type : 'multiple_any' },
  })

  schema
  .define( 'block' )
  .alternative()
  .extend([ 'alternative', 'composition' ]);

  // schema.define( 'name_kind' ).alternative().extend([ 'name_kind_terminal' ]);

  schema
  .define( 'literal' )
  .alternative()
  .extend([ 'name_literal', 'number', 'string' ]);

  schema.form();
  // console.log( schema.exportString({ format : 'grammar' }) );

  /*

  /statement_top :=
  (.
    :=(
      @left := /name_slash
      @including := /colon_equal
    )
    @multiple := ?/multiple
    @right :=
    [
      /name_kind
      /name_slash
      /block
    ]
    container = map
  )

  /statement_in :=
  (.
    := ?(
      @left := ?/name_at
      @including := /colon_equal
    )
    @multiple := ?/multiple
    @right :=
    [
      /name_slash
      /block
    ]
  )

  /multiple := [ /multiple_optional /multiple_any ]

  /directive :=
  (.
    /name_directive
    /equal
    @value := [ /literal /name_slash ]
  )

  /literal :=
  [
    /name_literal
    /number
    /string
  ]

  /string :=
  (.
    @value := /string_single
    @kind :=
    ?(
      /left
      := /name_clean
    )
  )

  /block := [ /alternative /composition ]

  /alternative :=
  (
    /square_open
    := *[ /statement_in /directive ]
    /square_close
  )

  /composition :=
  (
    /parenthes_open
    := *[ /statement_in /directive ]
    /parenthes_close
  )

  /grammar := (. * /statement_top root=1 )

*/

  return schema;
}

// --
// tests
// --

function form( test )
{
  let context = this;

  /* and, or, selector, scalar, identical, has */

  let schema = _.schema.system({ name : 'Schema.test/subtype' });

  schema.define( 'string' ).terminal({ default : '' });

  schema
  .define( 'simple' )
  .composition()
  .extend
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
    test.true( def.product instanceof _.schema.Product );
  }

  test.description = 'expected number of definitions';
  test.identical( _.entity.lengthOf( schema.definitionsMap ), 4 );
  test.identical( _.entity.lengthOf( schema.definitionsArray ), 6 );
  test.identical( _.entity.lengthOf( schema.definitionsToForm2Array ), 0 );
  test.identical( _.entity.lengthOf( schema.definitionsToForm3Array ), 0 );

  test.description = 'no definitions left after finit';
  schema.finit();
  test.identical( _.entity.lengthOf( schema.definitionsMap ), 0 );
  test.identical( _.entity.lengthOf( schema.definitionsArray ), 0 );
  test.identical( _.entity.lengthOf( schema.definitionsToForm2Array ), 0 );
  test.identical( _.entity.lengthOf( schema.definitionsToForm3Array ), 0 );

}

form.description =
`
form produces definitions
finit destroys definitions
`

//

function exportString( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Nodes' });

  schema.define( 'null' ).terminal({ default : _.null });
  schema.define( 'string' ).terminal({ default : '' });
  schema.define( 'number' ).terminal({ default : 0 });
  schema.define( 'boolean' ).terminal({ default : false });
  schema
  .define( 'Identifier' )
  .composition()
  .extend
  ({
    type : { type : 'string' },
    name : { type : 'string' },
  });
  schema
  .define( 'Literal' )
  .composition()
  .extend
  ({
    type : { type : 'string', default : '' },
    value : { type : '[ boolean number string null ]', default : 'null' },
    raw : { type : 'string', default : '' },
  });
  schema
  .define( 'Literal2' )
  .composition()
  .extend
  ({
    type : { type : 'string', default : '' },
    value : '[ boolean number string null ]',
    raw : { type : 'string', default : '' },
  });
  schema
  .define( 'ArrayExpressionElement2' )
  .alternative()
  .fromFields({ default : 'Expression' })
  .extend
  ([
    'Expression',
    _.nothing,
  ]);
  schema
  .define({ name : 'Expression' })
  .alternative()
  .fromFields({ default : 'Identifier' })
  .extend
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
  var got = schema.exportString();
  test.equivalent( got, exp );
  logger.log( got );

  schema.finit();
}

exportString.description =
`
exportString produce nice output
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
  schema
  .define( 'Identifier' )
  .composition()
  .extend
  ({
    type : { type : 'string' },
    name : { type : 'string' },
  });
  schema
  .define( 'Literal' )
  .composition()
  .extend
  ({
    type : { type : 'string', default : '' },
    value : { type : '[ boolean number string null ]', default : 'null' },
    raw : { type : 'string', default : '' },
  });
  schema
  .define( 'Literal2' )
  .composition()
  .extend
  ({
    type : { type : 'string', default : '' },
    value : '[ boolean number string null ]',
    raw : { type : 'string', default : '' },
  });
  schema
  .define( 'ArrayExpressionElement2' )
  .alternative()
  .fromFields({ default : 'Expression' })
  .extend
  ([
    'Expression',
    _.nothing,
  ]);
  schema
  .define({ name : 'Expression' })
  .alternative()
  .fromFields({ default : 'Identifier' })
  .extend
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
  schema
  .define( 'Identifier' )
  .composition()
  .extend
  ({
    type : { type : 'string' },
    name : { type : 'string' },
  });
  schema
  .define( 'Literal' )
  .composition()
  .extend
  ({
    type : { type : 'string', default : '' },
    value : { type : '[ boolean number string null ]', default : 'null' },
    raw : { type : 'string', default : '' },
  });
  schema
  .define( 'ArrayExpression' )
  .composition()
  .extend
  ({
    type : { type : 'string', default : '' },
    elements : { type : '( *ArrayExpressionElement )' },
  });
  schema
  .define( 'ArrayExpressionElement' )
  .alternative()
  .fromFields({ default : _.nothing })
  .extend
  ([
    'Expression',
    _.nothing,
  ]);
  schema
  .define({ name : 'Expression' })
  .alternative()
  .fromFields({ default : 'Identifier' })
  .extend
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

  schema
  .define( 'composition1' )
  .composition()
  .extend
  ([
    { type : 'string' },
    { type : 'null' },
    { type : 'string' },
  ]);

  schema
  .define( 'composition2' )
  .composition()
  .extend
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

  schema
  .define( 'composition1' )
  .composition()
  .extend
  ([
    { name : 'name', type : 'string' },
    { name : 'n', type : 'null' },
    { name : 'value', type : 'string' },
  ]);

  schema
  .define( 'composition2' )
  .composition()
  .extend
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

  schema
  .define( 'composition1' )
  .composition()
  .extend
  ([
    { name : 'name', type : 'string' },
    { type : 'null' },
    { name : 'value', type : 'string' },
  ]);

  schema
  .define( 'composition2' )
  .composition()
  .extend
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

function makeDefaultCompositionsFromString1( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Nodes' });
  let schemaString =
`
  @null := terminal default = null
  @string := terminal default = ''
  @number := terminal default = ' 0 '<-js
  @boolean := terminal default = ' false '<-js
  @alternative1 := [ @number @string ] default = @string
`

  schema.fromString( schemaString );
  schema.form();

  test.case = 'alternative1';
  var exp = '';
  var identifier = schema.definition( 'alternative1' ).makeDefault();
  test.identical( identifier, exp );

  schema.finit();
}

makeDefaultCompositionsFromString1.description =
`
- xxx
`

//

function makeDefaultCompositionsFromString2( test )
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

makeDefaultCompositionsFromString2.description =
`
- making definitions from string produce the same result as making it manually
- forming throw no errors
- both inner and outer compositions put elements in the same array
- auto determining of type of container determines array because inner map has anonymous element
- xxx
`

//

function defineVectorized( test )
{
  let context = this;

  let schema = _.schema.system({ name : 'Nodes' });

  schema
  .define([ 'FunctionDeclaration', 'FunctionExpression', 'ArrowFunctionExpression' ])
  .terminal()
  .fromFields({ default : 'abc' });
  schema.form();

  test.case = 'FunctionExpression';
  var exp = 'abc';
  var identifier = schema.definition( 'FunctionExpression' ).makeDefault();
  test.identical( identifier, exp );

  /* logger.log( schema.exportString() ); */
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

  schema
  .define( 'def1' )
  .label( 'native' )
  .terminal();
  schema
  .define( 'def2' )
  .label({ 'native' : false })
  .terminal({ default : 'abc' });
  schema.define( 'def3' )
  .label([ 'native' ])
  .terminal();
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

  schema
  .define( 'simple' )
  .composition()
  .extend
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

  schema
  .define( 'simple' )
  .composition()
  .extend
  ({
    kind : { type : 'string', default : '' },
    value : { type : 'string', default : '' },
    comments : { type : 'string', subtype : { identical : 'constant' }, default : 'constant2' },
  });

  test.shouldThrowErrorSync( () => schema.form() );

  schema.finit();
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

  schema
  .define( 'simple' )
  .composition()
  .extend
  ({
    kind : { type : 'string', default : '' },
    value : { type : 'string', default : '' },
    comments : { type : 'string', subtype : { identical : 'constant' }, default : 'constant' },
  });

  schema
  .define( 'selector' )
  .composition()
  .supplement( 'simple' )
  .extend
  ({
    kind : { subtype : { identical : 'sel' } },
  });

  schema
  .define( 'scalar' )
  .composition()
  .supplement( 'simple' )
  .extend
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

  logger.log( schema.exportString() );
  schema.finit();
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

  schema
  .define( 'simple' )
  .composition()
  .extend
  ({
    kind : { type : 'string', default : '' },
    value : { type : 'string', default : '' },
    comments : { type : 'string', subtype : { identical : 'constant' }, default : 'constant' },
  });

  schema
  .define( 'selector1' )
  .composition()
  .supplement( 'simple' )
  .extend
  ({
    kind : { subtype : { identical : 'sel1' } },
  });

  schema
  .define( 'selector2' )
  .composition()
  .supplement( 'simple' )
  .extend
  ({
    kind : { subtype : { identical : 'sel2' } },
  });

  schema
  .define( 'scalar' )
  .composition()
  .supplement( 'simple' )
  .extend
  ({
    kind : { type : 'float', subtype : { identical : 13 } },
  });

  schema.form();

  test.case = 'cehck definition::simple definition::selector1';
  var exp = true;
  var structure = { kind : 'sel1', value : 'some value', comments : 'constant' };
  var identifier = schema.definition( 'simple' ).isTypeOf( structure );
  test.identical( identifier, exp );

  logger.log( schema.exportString() );
  schema.finit();
}

isTypeOfStructure.description =
`
- xxx
`

//

function isTypeOfDefinition( test )
{
  let context = this;
  let schema = _.schema.system({ name : 'Schema.test/Specification' });

  schema.define( 'string' ).terminal({ default : '', onCheck : _.schema.predefined.string.is });
  schema.define( 'float' ).terminal({ default : '', onCheck : _.schema.predefined.float.is });

  schema
  .define( 'simple' )
  .composition()
  .extend
  ({
    kind : { type : 'string', default : '' },
    value : { type : 'string', default : '' },
    comments : { type : 'string', subtype : { identical : 'constant' }, default : 'constant' },
  });

  schema
  .define( 'selector1' )
  .composition()
  .supplement( 'simple' )
  .extend
  ({
    kind : { subtype : { identical : 'sel1' } },
  });

  schema
  .define( 'selector2' )
  .composition()
  .supplement( 'simple' )
  .extend
  ({
    kind : { subtype : { identical : 'sel2' } },
  });

  schema
  .define( 'scalar' )
  .composition()
  .supplement( 'simple' )
  .extend
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

  logger.log( schema.exportString() );
  schema.finit();
}

isTypeOfDefinition.description =
`
- xxx
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
        right :
        {
          kind : 'or',
          elements :
          [
            {
              kind : 'scalar',
              value : 'call_expression',
            },
            {
              kind : 'scalar',
              value : 'expression_statement',
            },
          ]
        },
      },
    ],
  }

  /* and, or, has, selector, scalar, identical, has */

  let schema = _.schema.system({ name : 'SchemaTest/Logic' });

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

  schema
  .define( 'element' )
  .alternative()
  .extend([ 'complex', 'simple' ]);

  var exp = 'abc';
  var identifier = schema.definition( 'def2' ).makeDefault();
  test.identical( identifier, exp );

  schema.finit();
}

logic.description =
`
- xxx
`

//

function constructingElements( test )
{
  let context = this;
  let schema = context.grammarExpression1();

  /* */

  test.case = 'exp_mul';
  test.identical( schema.definition( 'exp_mul' ).product.elementProduct().elementsArray.length, 3 );
  test.identical( schema.definition( 'exp_mul' ).product.elementProduct().elementDefinition( 0 ).name, 'exp' );
  test.identical( schema.definition( 'exp_mul' ).product.elementProduct().elementProduct( 0 ).definition.name, 'exp' );
  var exp =
  {
    'type' : 'exp',
    'name' : 'left',
    'index' : 0,
    'including' : true
  }
  test.identical( schema.definition( 'exp_mul' ).product.elementProduct().elementDescriptor( 0 ), exp );
  test.identical( schema.definition( 'exp_mul' ).product.elementProduct().elementDefinition( 1 ).name, 'mul' );
  test.identical( schema.definition( 'exp_mul' ).product.elementProduct().elementProduct( 1 ).definition.name, 'mul' );
  var exp =
  {
    'type' : 'mul',
    'name' : null,
    'index' : 1,
    'including' : false
  }
  test.identical( schema.definition( 'exp_mul' ).product.elementProduct().elementDescriptor( 1 ), exp );
  test.identical( schema.definition( 'exp_mul' ).product.elementProduct().elementDefinition( 2 ).name, 'exp' );
  test.identical( schema.definition( 'exp_mul' ).product.elementProduct().elementProduct( 2 ).definition.name, 'exp' );
  var exp =
  {
    'type' : 'exp',
    'name' : 'right',
    'index' : 2,
    'including' : true
  }
  test.identical( schema.definition( 'exp_mul' ).product.elementProduct().elementDescriptor( 2 ), exp );

  /* */

  test.case = 'exp_plus';
  test.identical( schema.definition( 'exp_plus' ).product.elementProduct().elementsArray.length, 3 );
  test.identical( schema.definition( 'exp_plus' ).product.elementProduct().elementDefinition( 0 ).name, 'exp' );
  test.identical( schema.definition( 'exp_plus' ).product.elementProduct().elementProduct( 0 ).definition.name, 'exp' );
  var exp =
  {
    'type' : 'exp',
    'name' : 'left',
    'index' : 0,
    'including' : true
  }
  test.identical( schema.definition( 'exp_plus' ).product.elementProduct().elementDescriptor( 0 ), exp );
  test.identical( schema.definition( 'exp_plus' ).product.elementProduct().elementDefinition( 1 ).name, 'plus' );
  test.identical( schema.definition( 'exp_plus' ).product.elementProduct().elementProduct( 1 ).definition.name, 'plus' );
  var exp =
  {
    'type' : 'plus',
    'name' : 'plus',
    'index' : 1,
    'including' : false
  }
  test.identical( schema.definition( 'exp_plus' ).product.elementProduct().elementDescriptor( 1 ), exp );
  test.identical( schema.definition( 'exp_plus' ).product.elementProduct().elementDefinition( 2 ).name, 'exp' );
  test.identical( schema.definition( 'exp_plus' ).product.elementProduct().elementProduct( 2 ).definition.name, 'exp' );
  var exp =
  {
    'type' : 'exp',
    'name' : 'right',
    'index' : 2,
    'including' : true
  }
  test.identical( schema.definition( 'exp_plus' ).product.elementProduct().elementDescriptor( 2 ), exp );

  /* */

  test.case = 'exp_parenthes';
  test.identical( schema.definition( 'exp_parenthes' ).product.elementProduct().elementsArray.length, 3 );
  test.identical( schema.definition( 'exp_parenthes' ).product.elementProduct().elementDefinition( 0 ).name, 'parenthes_open' );
  test.identical( schema.definition( 'exp_parenthes' ).product.elementProduct().elementProduct( 0 ).definition.name, 'parenthes_open' );
  var exp =
  {
    'type' : 'parenthes_open',
    'name' : null,
    'index' : 0,
    'including' : false
  }
  test.identical( schema.definition( 'exp_parenthes' ).product.elementProduct().elementDescriptor( 0 ), exp );
  test.identical( schema.definition( 'exp_parenthes' ).product.elementProduct().elementDefinition( 1 ).name, 'exp' );
  test.identical( schema.definition( 'exp_parenthes' ).product.elementProduct().elementProduct( 1 ).definition.name, 'exp' );
  var exp =
  {
    'type' : 'exp',
    'name' : 'exp',
    'index' : 1,
    'including' : true
  }
  test.identical( schema.definition( 'exp_parenthes' ).product.elementProduct().elementDescriptor( 1 ), exp );
  test.identical( schema.definition( 'exp_parenthes' ).product.elementProduct().elementDefinition( 2 ).name, 'parenthes_close' );
  test.identical( schema.definition( 'exp_parenthes' ).product.elementProduct().elementProduct( 2 ).definition.name, 'parenthes_close' );
  var exp =
  {
    'type' : 'parenthes_close',
    'name' : null,
    'index' : 2,
    'including' : false
  }
  test.identical( schema.definition( 'exp_parenthes' ).product.elementProduct().elementDescriptor( 2 ), exp );

  /* */

  schema.finit();
}

constructingElements.description =
`
- several extends create proper elements
- single extend with map creates proper elements
- single extend with array creates proper elements
- several extends, single extend with map and single extend with long produced the same result
`

//

function exportStringExpression1( test )
{
  let context = this;
  let schema = context.grammarExpression1();

  /* */

  test.case = 'optimizing : 1';
  var got = schema.exportString({ format : 'grammar', optimizing : 1 });
  console.log( got );
  var exp =
`schema::SchemaTest/grammarExpression1

  /mul := terminal

  /plus := terminal

  /space := terminal

  /name := terminal

  /number := terminal

  /parenthes_open := terminal

  /parenthes_close := terminal

  /factor :=
  [
    name
    number
  ]

  /exp_mul :=
  (.<
    @left := exp
    mul
    @right := exp
  )

  /exp_plus :=
  (.<
    @left := exp
    plus
    @right := exp
  )

  /exp_parenthes :=
  (.<
    parenthes_open
    @exp := exp
    parenthes_close
  )

  /exp :=
  [<
    factor
    exp_mul
    exp_plus
    exp_parenthes
  ]
`
  test.equivalent( got, exp );

  /* */

  test.case = 'optimizing : 0';
  var got = schema.exportString({ format : 'grammar', optimizing : 0 });
  var exp =
`
schema::SchemaTest/grammarExpression1

  /mul := terminal

  /plus := terminal

  /space := terminal

  /name := terminal

  /number := terminal

  /parenthes_open := terminal

  /parenthes_close := terminal

  /factor :=
  [
    name
    number
  ]

  #11 :=
  (<
    @left := exp
    mul
    @right := exp
  )

  /exp_mul := (. #11 )

  #13 :=
  (<
    @left := exp
    plus
    @right := exp
  )

  /exp_plus := (. #13 )

  #15 :=
  (<
    parenthes_open
    @exp := exp
    parenthes_close
  )

  /exp_parenthes := (. #15 )

  /exp :=
  [<
    factor
    exp_mul
    exp_plus
    exp_parenthes
  ]
`
  test.equivalent( got, exp );

  /* */

  /*

    /mul = terminal
    /plus = terminal
    /space = terminal
    /name = terminal
    /number = terminal
    /parenthes_open = terminal
    /parenthes_close = terminal

    /factor = [ /name /number ]
    /exp_mul = (<. left:=/exp /mul right:=/exp )
    /exp_plus = (<. left:=/exp /plus right:=/exp )
    /exp_parenthes = (. /parenthes_open exp:=/exp /parenthes_close ]
    /exp = [< /factor /exp_mul /exp_plus /exp_parenthes root=true ]

  */

  schema.finit();
}

exportStringExpression1.description =
`
- exportString with option format=grammar returns string of grammar
- option optimizing of exportString merge definitions minimizing grammar
`

//

function exportStringGrammarExpression2( test )
{
  let context = this;
  let schema = context.grammarExpression2();

  /* */

  test.case = 'optimizing : 1';
  var got = schema.exportString({ format : 'grammar', optimizing : 1 });
  console.log( got );
  var exp =
`
schema::SchemaTest/grammarExpression2

  /name := terminal

  /sign_plus := terminal

  /sign_minus := terminal

  /sign_optional :=
  [
    sign_plus
    sign_minus
  ]

  /exp2 :=
  (<
    exp
    sign_optional
    exp
  )

  /exp :=
  [
    name
    exp2
  ]
`
  test.equivalent( got, exp );

  /* */

  test.case = 'optimizing : 0';
  var got = schema.exportString({ format : 'grammar', optimizing : 0 });
  console.log( got );
  var exp =
`
schema::SchemaTest/grammarExpression2

  /name := terminal

  /sign_plus := terminal

  /sign_minus := terminal

  /sign_optional :=
  [
    sign_plus
    sign_minus
  ]

  /exp2 :=
  (<
    exp
    sign_optional
    exp
  )

  /exp :=
  [
    name
    exp2
  ]
`
  test.equivalent( got, exp );

  /* */

  /*

  */

  schema.finit();
}

exportStringGrammarExpression2.description =
`
- exported expression2 as string.grammar looks good
`

//

function exportStringIdExpression2( test )
{
  let context = this;
  let schema = context.grammarExpression2();

  /* */

  test.case = 'basic';
  var got = schema.exportString({ format : 'id', withUniversal : 1 });
  console.log( got );
  var exp =
`
schema::SchemaTest/grammarExpression2
  Universal::/❮singularity❯ := #1
  Universal::/❮edge❯ := #2
  Universal::/❮nothing❯ := #3
  Universal::/❮anything❯ := #4
  Terminal::/name := #5
  Terminal::/sign_plus := #6
  Terminal::/sign_minus := #7
  Alternative::/sign_optional := #8
  Composition::/exp2 := #9
  Alternative::/exp := #10
`
  test.equivalent( got, exp );

  /* */

  schema.finit();
}

exportStringIdExpression2.description =
`
- exported expression2 as string.id looks good
`

//

function exportStringPalindrom( test )
{
  let context = this;
  let schema = context.grammarPalindrom();

  /* */

  var got = schema.exportString({ format : 'grammar', optimizing : 1 });
  console.log( got );
  var exp =
`
schema::SchemaTest/grammarPalindrom

  /space := terminal

  /name := terminal

  /sign_plus := terminal

  /sign_minus := terminal

  /sign_optional :=
  [
    sign_plus
    sign_minus
    ❮nothing❯
  ]

  /exp2 :=
  (.<
    @left := exp
    @sign := sign_optional
    @right := exp
  )

  /exp :=
  [<
    name
    exp2
  ]
`
  test.equivalent( got, exp );

  /* */

  var got = schema.exportString({ format : 'grammar', optimizing : 0 });
  console.log( got );
  var exp =
`
schema::SchemaTest/grammarPalindrom

  /space := terminal

  /name := terminal

  /sign_plus := terminal

  /sign_minus := terminal

  /sign_optional :=
  [
    sign_plus
    sign_minus
    ❮nothing❯
  ]

  #8 :=
  (<
    @left := exp
    @sign := sign_optional
    @right := exp
  )

  /exp2 := (. #8 )

  /exp :=
  [<
    name
    exp2
  ]
`
  test.equivalent( got, exp );

  /* */

  schema.finit();
}

exportStringPalindrom.description =
`
- exportString with option format=grammar returns string of grammar
- option optimizing of exportString merge definitions minimizing grammar
`

//

function parseGrammarPalindrom( test )
{
  let context = this;
  let schema = context.grammarPalindrom();

  /* */

  console.log( schema.exportString({ format : 'grammar', optimizing : 1 }) );

  /* xxx */

  /* */

  schema.finit();
}

parseGrammarPalindrom.description =
`
- xxx
`

//

function parseGrammarOwn( test )
{
  let context = this;
  let schema = context.grammarOwn();

  console.log( schema.exportString({ format : 'grammar' }) );

  /*

  /statement_top :=
  (.
    :=(
      @left := /name_slash
      @including := /colon_equal
    )
    @multiple := ?/multiple
    @right :=
    [
      /name_kind
      /name_slash
      /block
    ]
    container = map
  )

  /statement_in :=
  (.
    := ?(
      @left := ?/name_at
      @including := /colon_equal
    )
    @multiple := ?/multiple
    @right :=
    [
      /name_slash
      /block
    ]
  )

  /multiple := [ /multiple_optional /multiple_any ]

  /directive :=
  (.
    /name_directive
    /equal
    @value := [ /literal /name_slash ]
  )

  /literal :=
  [
    /name_literal
    /number
    /string
  ]

  /string :=
  (.
    @value := /string_single
    @kind :=
    ?(
      /left
      := /name_clean
    )
  )

  /block := [ /alternative /composition ]

  /alternative :=
  (
    /square_open
    := *[ /statement_in /directive ]
    /square_close
  )

  /composition :=
  (
    /parenthes_open
    := *[ /statement_in /directive ]
    /parenthes_close
  )

  /grammar := (. * /statement_top root=1 )

*/

  //

  // ({
  //   'colon_equal'       : ':=',
  //   'equal'             : '=',
  //   'left'              : '<-',
  //   'right'             : '->',
  //   'multiple_optional' : '?',
  //   'multiple_any'      : '*',
  //   'space'             : /\s+/,
  //   'string_single'     : /'(?:\\\n|\\'|[^'\n])*?'/,
  //   'name_kind'         : [ 'terminal' ],
  //   'name_directive'    : [ 'default', 'container' ],
  //   'name_literal'      : [ 'null', 'true', 'false' ],
  //   'name_at'           : /@[a-z_\$][0-9a-z_\$]*/i,
  //   'name_slash'        : /\/[a-z_\$][0-9a-z_\$]*/i,
  //   'name_clean'        : /[a-z_\$][0-9a-z_\$]*/i,
  //   'number'            : /(?:0x(?:\d|[a-f])+|\d+(?:\.\d+)?(?:e[+-]?\d+)?)/i,
  //   'parenthes_open'    : '(',
  //   'parenthes_close'   : ')',
  //   'square_open'       : '[',
  //   'square_close'      : ']',
  // });

}

parseGrammarOwn.description =
`
- xxx
`

// --
// declare
// --

const Proto =
{

  name : 'Tools.mid.Schema',
  silencing : 1,
  routineTimeOut : 30000,

  context :
  {
    grammarPalindrom,
    grammarExpression1,
    grammarExpression2,
    grammarOwn,
  },

  tests :
  {

    form,
    exportString,
    makeDefault,
    // makeDefaultMultiple,
    // makeDefaultCompositionsNotNamedElements,
    // makeDefaultCompositionsNamedElements,
    // makeDefaultCompositionsNamedElementsButOneInner,
    // makeDefaultCompositionsFromString1,
    // makeDefaultCompositionsFromString2,

    defineVectorized,
    label,

    subtype,
    subtypeWrongDefault,
    compositionSpecification,
    isTypeOfStructure,
    // isTypeOfDefinition,
    // logic,

    constructingElements,
    exportStringExpression1,
    exportStringGrammarExpression2,
    exportStringIdExpression2,
    exportStringPalindrom,

    parseGrammarPalindrom,
    parseGrammarOwn,

  },

}

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
