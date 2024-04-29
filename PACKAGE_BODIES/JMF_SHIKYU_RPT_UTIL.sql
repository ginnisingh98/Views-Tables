--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_RPT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_RPT_UTIL" AS
--$Header: JMFUSKRB.pls 120.7 2006/01/17 15:10:31 vchu noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFUSKRB.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Body file of the utility package for the           |
--|                        Charge Based SHIKYU reports.                       |
--|                                                                           |
--|  FUNCTION/PROCEDURE:   get_item_number                                    |
--|                        get_item_primary_uom_code                          |
--|                        get_item_primary_quantity                          |
--|                        po_uom_convert_p                                   |
--|                        get_min2                                           |
--|                        get_min3                                           |
--|                        rate_exists                                        |
--|                        get_rate                                           |
--|                        convert_amount                                     |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   27-APR-2005          shu  Created.                                      |
--|   21-NOV-2005          shu  add code in po_uom_convert_p as it is use the |
--|                             the 3-character UOM_CODE,not 25-character     |
--|   29-NOV-2005          shu  added uom_to_code function .                  |
--|   29-NOV-2005          shu  modified convert_amount function, using       |
--|                             GL_CURRENCY_API.convert_amount_sql that with  |
--|                             exception handle.                             |
--|   16-DEC-2005          shu  modified debug_output to save information into|
--|                             FND_LOG_MESSAGE table using fnd_log.string    |
--+===========================================================================+

--=============================================
-- GLOBAL VARIABLES
--=============================================

g_fnd_debug   VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');

  --========================================================================
  -- PROCEDURE : get_item_number              PUBLIC
  -- PARAMETERS: p_organization_id            the organization id
  --           : p_inventory_item_id          the item id
  --           : x_item_number                the return item number
  -- COMMENT   : for getting the item flexfield number
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE get_item_number
  ( p_organization_id   IN NUMBER
  , p_inventory_item_id IN NUMBER
  , x_item_number       OUT NOCOPY VARCHAR2
  )
  IS
    --l_val        BOOLEAN;
    l_nseg         NUMBER;
    l_seglist      fnd_flex_key_api.segment_list;
    l_segs1        fnd_flex_ext.segmentarray;
    l_segs2        fnd_flex_ext.segmentarray;
    l_fftype       fnd_flex_key_api.flexfield_type;
    l_ffstru       fnd_flex_key_api.structure_type;
    l_segment_type fnd_flex_key_api.segment_type;
    l_item_number  VARCHAR2(32000);
    l_delim        VARCHAR2(1);
    l_index        NUMBER;
  BEGIN

    fnd_flex_key_api.set_session_mode('customer_data');
    -- find flex field type
    l_fftype := fnd_flex_key_api.find_flexfield('INV'
                                               ,'MSTK');
    -- find flex structure type
    l_ffstru := fnd_flex_key_api.find_structure(l_fftype
                                               ,101);
    -- find segment list for the key flex field
    fnd_flex_key_api.get_segments(l_fftype
                                 ,l_ffstru
                                 ,TRUE
                                 ,l_nseg
                                 ,l_seglist);
    -- get the corresponding clolumn for all segments
    FOR l_loop IN 1 .. l_nseg
    LOOP
      l_segment_type := fnd_flex_key_api.find_segment(l_fftype
                                                     ,l_ffstru
                                                     ,l_seglist(l_loop));
      l_segs2(l_loop) := l_segment_type.column_name;
    END LOOP;

    -- get all segments from the item table
    SELECT segment1
          ,segment2
          ,segment3
          ,segment4
          ,segment5
          ,segment6
          ,segment7
          ,segment8
          ,segment9
          ,segment10
          ,segment11
          ,segment12
          ,segment13
          ,segment14
          ,segment15
          ,segment16
          ,segment17
          ,segment18
          ,segment19
          ,segment20
      INTO l_segs1(1)
          ,l_segs1(2)
          ,l_segs1(3)
          ,l_segs1(4)
          ,l_segs1(5)
          ,l_segs1(6)
          ,l_segs1(7)
          ,l_segs1(8)
          ,l_segs1(9)
          ,l_segs1(10)
          ,l_segs1(11)
          ,l_segs1(12)
          ,l_segs1(13)
          ,l_segs1(14)
          ,l_segs1(15)
          ,l_segs1(16)
          ,l_segs1(17)
          ,l_segs1(18)
          ,l_segs1(19)
          ,l_segs1(20)
      FROM mtl_system_items
     WHERE organization_id = p_organization_id
       AND inventory_item_id = p_inventory_item_id;

    -- get delimiter for segment concatenation
    l_delim := fnd_flex_ext.get_delimiter('INV'
                                         ,'MSTK'
                                         ,101);

    -- concatenate segments based on the order defined by the flex
    -- field structure
    FOR l_loop IN 1 .. l_nseg
    LOOP
      l_index := To_number(Substr(l_segs2(l_loop)
                                 ,8
                                 ,1));
      IF l_loop = 1
      THEN
        l_item_number := l_segs1(l_index);
      ELSE
        l_item_number := l_item_number || l_delim || l_segs1(l_index);
      END IF;
    END LOOP;

    x_item_number := l_item_number;

  EXCEPTION
    WHEN OTHERS THEN
      x_item_number := NULL;

  END get_item_number;

  --========================================================================
  -- FUNCTION  : get_item_number              PUBLIC
  -- PARAMETERS: p_organization_id            the organization id
  --           : p_inventory_item_id          the item id
  -- RETURN    : will return the item number
  -- COMMENT   : for getting the item flexfield number
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_item_number
  ( p_organization_id   IN NUMBER
  , p_inventory_item_id IN NUMBER
  )
  RETURN VARCHAR2
  IS
    --l_val        BOOLEAN;
    l_nseg         NUMBER;
    l_seglist      fnd_flex_key_api.segment_list;
    l_segs1        fnd_flex_ext.segmentarray;
    l_segs2        fnd_flex_ext.segmentarray;
    l_fftype       fnd_flex_key_api.flexfield_type;
    l_ffstru       fnd_flex_key_api.structure_type;
    l_segment_type fnd_flex_key_api.segment_type;
    l_item_number  VARCHAR2(32000);
    l_delim        VARCHAR2(1);
    l_index        NUMBER;
  BEGIN
    fnd_flex_key_api.set_session_mode('customer_data');
    -- find flex field type
    l_fftype := fnd_flex_key_api.find_flexfield('INV'
                                               ,'MSTK');
    -- find flex structure type
    l_ffstru := fnd_flex_key_api.find_structure(l_fftype
                                               ,101);
    -- find segment list for the key flex field
    fnd_flex_key_api.get_segments(l_fftype
                                 ,l_ffstru
                                 ,TRUE
                                 ,l_nseg
                                 ,l_seglist);
    -- get the corresponding clolumn for all segments
    FOR l_loop IN 1 .. l_nseg
    LOOP
      l_segment_type := fnd_flex_key_api.find_segment(l_fftype
                                                     ,l_ffstru
                                                     ,l_seglist(l_loop));
      l_segs2(l_loop) := l_segment_type.column_name;
    END LOOP;

    -- get all segments from the item table
    SELECT segment1
          ,segment2
          ,segment3
          ,segment4
          ,segment5
          ,segment6
          ,segment7
          ,segment8
          ,segment9
          ,segment10
          ,segment11
          ,segment12
          ,segment13
          ,segment14
          ,segment15
          ,segment16
          ,segment17
          ,segment18
          ,segment19
          ,segment20
      INTO l_segs1(1)
          ,l_segs1(2)
          ,l_segs1(3)
          ,l_segs1(4)
          ,l_segs1(5)
          ,l_segs1(6)
          ,l_segs1(7)
          ,l_segs1(8)
          ,l_segs1(9)
          ,l_segs1(10)
          ,l_segs1(11)
          ,l_segs1(12)
          ,l_segs1(13)
          ,l_segs1(14)
          ,l_segs1(15)
          ,l_segs1(16)
          ,l_segs1(17)
          ,l_segs1(18)
          ,l_segs1(19)
          ,l_segs1(20)
      FROM mtl_system_items
     WHERE organization_id = p_organization_id
       AND inventory_item_id = p_inventory_item_id;

    -- get delimiter for segment concatenation
    l_delim := fnd_flex_ext.get_delimiter('INV'
                                         ,'MSTK'
                                         ,101);

    -- concatenate segments based on the order defined by the flex
    -- field structure
    FOR l_loop IN 1 .. l_nseg
    LOOP
      l_index := To_number(Substr(l_segs2(l_loop)
                                 ,8
                                 ,1));
      IF l_loop = 1
      THEN
        l_item_number := l_segs1(l_index);
      ELSE
        l_item_number := l_item_number || l_delim || l_segs1(l_index);
      END IF;
    END LOOP;

    RETURN l_item_number;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

  END get_item_number;

  --========================================================================
  -- FUNCTION  : uom_to_code    PUBLIC
  -- PARAMETERS: p_unit_of_measure  the 25-character unit of measure
  -- RETURN    : will return the 3-character uom code in jmf_shikyu_% tables
  -- COMMENT   : getting the UOM code
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION uom_to_code(p_unit_of_measure IN VARCHAR2) RETURN VARCHAR2 IS
    l_uom_code mtl_units_of_measure_tl.uom_code%TYPE; -- or mtl_units_of_measure_tl.uom_code???
  BEGIN
    --get the uom_code
    BEGIN
      -- get l_from_unit_name
      SELECT UOM_CODE
        INTO l_uom_code
        FROM MTL_UNITS_OF_MEASURE_TL
       WHERE LANGUAGE = USERENV('LANG')
         AND UNIT_OF_MEASURE = p_unit_of_measure;


      EXCEPTION
        WHEN no_data_found THEN
        -- get l_from_unit_name
        SELECT UOM_CODE
          INTO l_uom_code
          FROM MTL_UNITS_OF_MEASURE_TL
         WHERE LANGUAGE = 'US'
           AND UNIT_OF_MEASURE = p_unit_of_measure;
    END;

    RETURN l_uom_code;

  END uom_to_code;

  --========================================================================
  -- FUNCTION  : get_item_primary_uom_code    PUBLIC
  -- PARAMETERS: p_org_id           the organization id
  --           : p_item_id          the item id
  -- RETURN    : will return the primary uom code
  -- COMMENT   : getting the  primary UOM code
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_item_primary_uom_code
  ( p_org_id  IN NUMBER
  , p_item_id IN NUMBER
  )
  RETURN VARCHAR2
  IS
  BEGIN

    RETURN get_item_primary_uom_code(p_org_id           => p_org_id
                                    ,p_item_id          => p_item_id
                                    ,p_current_uom_code => NULL);

  END get_item_primary_uom_code;

  --========================================================================
  -- FUNCTION  : get_item_primary_uom_code    PUBLIC
  -- PARAMETERS: p_org_id           the organization id
  --           : p_item_id          the item id
  --           : p_current_uom_Code current uom_code
  -- RETURN    : will return the primary uom code
  -- COMMENT   : getting the  primary UOM code
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_item_primary_uom_code
  ( p_org_id           IN NUMBER
  , p_item_id          IN NUMBER
  , p_current_uom_code IN VARCHAR2
  )
  RETURN VARCHAR2
  IS
    l_current_uom      mtl_units_of_measure_tl.unit_of_measure%TYPE; -- or mtl_units_of_measure_tl.uom_code???
    l_primary_uom      mtl_units_of_measure_tl.unit_of_measure%TYPE; -- or mtl_units_of_measure_tl.uom_code???
    l_primary_uom_code mtl_units_of_measure_tl.uom_code%TYPE; -- or mtl_units_of_measure_tl.uom_code???
  BEGIN

    IF p_item_id IS NULL
    THEN
      --get the current unit of measure from the given uom_code;
      SELECT unit_of_measure
        INTO l_current_uom
        FROM mtl_units_of_measure_vl
       WHERE uom_code = p_current_uom_code;
    END IF;

    --get the primary UOM
    l_primary_uom := po_uom_s.get_primary_uom(p_item_id
                                             ,p_org_id
                                             ,l_current_uom);

    --get the primary uom_code
    SELECT uom_code
      INTO l_primary_uom_code
      FROM mtl_units_of_measure_vl
     WHERE unit_of_measure = l_primary_uom;

    RETURN l_primary_uom_code;

  END get_item_primary_uom_code;

  --========================================================================
  -- FUNCTION  : get_item_primary_quantity    PUBLIC
  -- PARAMETERS: p_org_id           the organization id
  --           : p_item_id          the item id
  --           : p_current_uom_Code current uom_code
  --           : p_current_qty      current item quantity
  -- RETURN    : will return the quantity for the item using the primary uom
  -- COMMENT   : getting the item quantity using primary UOM
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_item_primary_quantity
  ( p_org_id           IN NUMBER
  , p_item_id          IN NUMBER
  , p_current_uom_code IN VARCHAR2
  , p_current_qty      IN NUMBER
  )
  RETURN NUMBER
  IS
    l_current_uom      mtl_units_of_measure_tl.unit_of_measure%TYPE; -- or mtl_units_of_measure_tl.uom_code???
    l_primary_uom      mtl_units_of_measure_tl.unit_of_measure%TYPE; -- or mtl_units_of_measure_tl.uom_code???
    l_primary_quantity NUMBER;
  BEGIN
    --get the current unit of measure from the given uom_code;
    SELECT unit_of_measure
      INTO l_current_uom
      FROM mtl_units_of_measure_vl
     WHERE uom_code = p_current_uom_code;

    --get the primary UOM
    l_primary_uom := po_uom_s.get_primary_uom(p_item_id
                                             ,p_org_id
                                             ,l_current_uom);

    /*l_primary_uom := get_item_primary_uom_code
    ( p_org_id               => p_org_id
    , p_item_id              => p_item_id
    , p_current_uom_code     => p_current_uom_code
    ) ;*/

    --get the primary quantity
    --po_uom_s.uom_convert(from_quantity, from_uom, item_id, to_uom,  to_quantity)
    po_uom_s.uom_convert(p_current_qty
                        ,l_current_uom
                        ,p_item_id
                        ,l_primary_uom
                        ,l_primary_quantity);

    RETURN l_primary_quantity;  --if l_primary_quantity = -999 means can not find the UOM conversion

  END get_item_primary_quantity;

  --========================================================================
  -- FUNCTION  : po_uom_convert_p    PUBLIC
  -- PARAMETERS: p_from_unit         the 3-character  UOM_CODE of INV.MTL_UNITS_OF_MEASURE_TL
  --           : p_to_unit           the 3-character  UOM_CODE of INV.MTL_UNITS_OF_MEASURE_TL
  --           : p_item_id           the item id
  -- RETURN    :
  --             Created a function po_uom_convert_p which is pure function to be used in
  --                 the where and select clauses of a SQL
  -- COMMENT   :
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION po_uom_convert_p
  ( p_from_unit IN VARCHAR2
  , p_to_unit   IN VARCHAR2
  , p_item_id   IN NUMBER
  )
  RETURN NUMBER
  IS
    l_from_unit_name MTL_UNITS_OF_MEASURE_TL.UNIT_OF_MEASURE%TYPE;
    l_to_unit_name   MTL_UNITS_OF_MEASURE_TL.UNIT_OF_MEASURE%TYPE;
  BEGIN
    BEGIN
      -- get l_from_unit_name
      SELECT UNIT_OF_MEASURE
        INTO l_from_unit_name
        FROM MTL_UNITS_OF_MEASURE_TL
       WHERE LANGUAGE = USERENV('LANG')
         AND UOM_CODE = p_from_unit;
      -- get l_to_unit_name
      SELECT UNIT_OF_MEASURE
        INTO l_to_unit_name
        FROM MTL_UNITS_OF_MEASURE_TL
       WHERE LANGUAGE = USERENV('LANG')
         AND UOM_CODE = p_to_unit;


      EXCEPTION
        WHEN no_data_found THEN
        -- get l_from_unit_name
          SELECT UNIT_OF_MEASURE
            INTO l_from_unit_name
            FROM MTL_UNITS_OF_MEASURE_TL
           WHERE LANGUAGE = 'US'
             AND UOM_CODE = p_from_unit;
        -- get l_to_unit_name
          SELECT UNIT_OF_MEASURE
            INTO l_to_unit_name
            FROM MTL_UNITS_OF_MEASURE_TL
           WHERE LANGUAGE = 'US'
             AND UOM_CODE = p_to_unit;
    END;
    --get the current unit of measure from the given uom_code;
    RETURN PO_UOM_S.po_uom_convert_p(from_unit => l_from_unit_name --the 25-character UNIT_OF_MEASURE
                                    ,to_unit   => l_to_unit_name   --the 25-character UNIT_OF_MEASURE
                                    ,item_id   => p_item_id);

  END po_uom_convert_p;

  --========================================================================
  -- FUNCTION  : get_min2            PUBLIC
  -- PARAMETERS: p_number1          the number1
  --           : p_number2          the number2
  -- RETURN    : return the less one
  -- COMMENT   : getting the less number
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_min2
  ( p_number1 IN NUMBER
  , p_number2 IN NUMBER
  )
  RETURN NUMBER
  IS
  BEGIN
    IF p_number1 < p_number2
    THEN
      RETURN p_number1;
    ELSE
      RETURN p_number2;
    END IF;

  END get_min2;

  --========================================================================
  -- FUNCTION  : get_min3            PUBLIC
  -- PARAMETERS: p_number1          the number1
  --           : p_number2          the number2
  --           : p_number3          the number3
  -- RETURN    : return the less one
  -- COMMENT   : getting the less number
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_min3
  ( p_number1 IN NUMBER
  , p_number2 IN NUMBER
  , p_number3 IN NUMBER
  )
  RETURN NUMBER
  IS
  BEGIN

    RETURN get_min2(get_min2(p_number1
                            ,p_number2)
                   ,p_number3);

  END get_min3;

  --========================================================================
  -- FUNCTION  : rate_exists             PUBLIC
  -- PARAMETERS: p_from_currency    From currency
  --           : p_to_currency    To currency
  --           : p_conversion_date  Conversion date
  --           : p_conversion_type  Conversion type
  -- RETURN    : return the sonversion rate
  -- COMMENT   : reference to the APPS.GL_CURRENCY_API,
  --             Returns 'Y' if there is a conversion rate between the two currencies
  --             for a given conversion date and conversion type;
  --            'N' otherwise.

  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION rate_exists
  (
    p_from_currency   IN VARCHAR2 -- FND_CURRENCIES.currency_code
   ,p_to_currency     IN VARCHAR2
   ,p_conversion_date IN DATE
   ,p_conversion_type IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
  BEGIN

    RETURN GL_CURRENCY_API.rate_exists(x_from_currency   => p_from_currency
                                      ,x_to_currency     => p_to_currency
                                      ,x_conversion_date => p_conversion_date
                                      ,x_conversion_type => p_conversion_type);

  END rate_exists;

  --========================================================================
  -- FUNCTION  : get_rate            PUBLIC
  -- PARAMETERS: p_from_currency    From currency
  --           : p_to_currency    To currency
  --           : p_conversion_date  Conversion date
  --           : p_conversion_type  Conversion type
  -- RETURN    : return the sonversion rate
  -- COMMENT   : reference to the APPS.GL_CURRENCY_API, to get the currency conversion rate
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_rate
  ( p_from_currency   IN VARCHAR2 -- FND_CURRENCIES.currency_code
  , p_to_currency     IN VARCHAR2
  , p_conversion_date IN DATE
  , p_conversion_type IN VARCHAR2 DEFAULT NULL
  )
  RETURN NUMBER
  IS
  BEGIN

    RETURN GL_CURRENCY_API.get_rate(x_from_currency   => p_from_currency
                                   ,x_to_currency     => p_to_currency
                                   ,x_conversion_date => p_conversion_date
                                   ,x_conversion_type => p_conversion_type);

  END get_rate;

  --========================================================================
  -- FUNCTION  : get_rate            PUBLIC
  -- PARAMETERS: p_ledger_id  Set of books id (in R12 set of book will be replaced by ledger)
  --           : p_from_currency    From currency
  --           : p_conversion_date  Conversion date
  --           : p_conversion_type  Conversion type
  -- RETURN    : return the sonversion rate
  -- COMMENT   : reference to the APPS.GL_CURRENCY_API,
  --             Returns the rate between the from currency and the functional
  --             currency of the set of books.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION get_rate
  ( p_ledger_id       IN NUMBER
  , p_from_currency   IN VARCHAR2 -- FND_CURRENCIES.currency_code
  , p_conversion_date IN DATE
  , p_conversion_type IN VARCHAR2 DEFAULT NULL
  )
  RETURN NUMBER
  IS
  BEGIN

    RETURN GL_CURRENCY_API.get_rate(x_set_of_books_id => p_ledger_id
                                   ,x_from_currency   => p_from_currency
                                   ,x_conversion_date => p_conversion_date
                                   ,x_conversion_type => p_conversion_type);

  END get_rate;

  --========================================================================
  -- FUNCTION  : convert_amount             PUBLIC
  -- PARAMETERS: p_from_currency    From currency
  --           : p_to_currency    To currency
  --           : p_conversion_date  Conversion date
  --           : p_conversion_type  Conversion type
  --           : p_amount     Amount to be converted from the from currency
  --                          into the to currency
  -- RETURN    : return the sonversion rate
  -- COMMENT   : reference to the APPS.GL_CURRENCY_API,
  --             Returns the amount converted from the from currency into the
  --             to currency for a given conversion date and conversion type.
  --             The amount returned is rounded to the precision and minimum
  --             account unit of the to currency.
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION convert_amount
  ( p_from_currency   IN VARCHAR2 -- FND_CURRENCIES.currency_code
  , p_to_currency     IN VARCHAR2
  , p_conversion_date IN DATE
  , p_conversion_type IN VARCHAR2 DEFAULT NULL
  , p_amount          IN NUMBER
  )
  RETURN NUMBER
  IS
    l_converted_amount 		NUMBER;

  BEGIN

    /*RETURN GL_CURRENCY_API.convert_amount(x_from_currency   => p_from_currency
                                         ,x_to_currency     => p_to_currency
                                         ,x_conversion_date => p_conversion_date
                                         ,x_conversion_type => p_conversion_type
                                         ,x_amount          => p_amount);*/
    l_converted_amount := GL_CURRENCY_API.convert_amount_sql(x_from_currency   => p_from_currency
                                             ,x_to_currency     => p_to_currency
                                             ,x_conversion_date => p_conversion_date
                                             ,x_conversion_type => p_conversion_type
                                             ,x_amount          => p_amount);
    RETURN l_converted_amount;
  END convert_amount;

  --========================================================================
  -- FUNCTION  : convert_amount             PUBLIC
  -- PARAMETERS: p_ledger_id        Set of books id (in R12 set of book will be replaced by ledger)
  --           : p_from_currency    From currency
  --           : p_conversion_date  Conversion date
  --           : p_conversion_type  Conversion type
  --           : p_amount     Amount to be converted from the from currency
  --                          into the to currency
  -- RETURN    : return the sonversion rate
  -- COMMENT   : reference to the APPS.GL_CURRENCY_API,
  --             Returns the amount converted from the from currency into the
  --             functional currency of that set of books.  The amount returned is
  --             rounded to the precision and minimum account unit of the to currency.

  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  FUNCTION convert_amount
  ( p_ledger_id       IN NUMBER
  , p_from_currency   IN VARCHAR2 -- FND_CURRENCIES.currency_code
  , p_conversion_date IN DATE
  , p_conversion_type IN VARCHAR2 DEFAULT NULL
  , p_amount          IN NUMBER
  )
  RETURN NUMBER
  IS
    l_converted_amount 		NUMBER;

  BEGIN

    /*RETURN GL_CURRENCY_API.convert_amount(x_set_of_books_id => p_ledger_id
                                         ,x_from_currency   => p_from_currency
                                         ,x_conversion_date => p_conversion_date
                                         ,x_conversion_type => p_conversion_type
                                         ,x_amount          => p_amount);*/
    l_converted_amount := GL_CURRENCY_API.convert_amount_sql(x_set_of_books_id => p_ledger_id
                                         ,x_from_currency   => p_from_currency
                                         ,x_conversion_date => p_conversion_date
                                         ,x_conversion_type => p_conversion_type
                                         ,x_amount          => p_amount);
   /*EXCEPTION
     	WHEN NO_RATE THEN
     	  converted_amount := -1;
    	  return( converted_amount );

    	WHEN INVALID_CURRENCY THEN
    	  converted_amount := -2;
     	  return( converted_amount );*/
    RETURN l_converted_amount;
  END convert_amount;

  -- moved to JMF_SHIKYU_UTIL by Vincent as it is generic for all SHIKYU
  --========================================================================
  -- PROCEDURE : debug_output    PUBLIC
  -- PARAMETERS: p_output_to            Identifier of where to output to
  --             p_api_name             the called api name
  --             p_message              the message that need to be output
  -- COMMENT   : the debug output, for using in readonly UT environment
  -- PRE-COND  :
  -- EXCEPTIONS:
  --========================================================================
  PROCEDURE debug_output
  (
    p_output_to IN VARCHAR2
   ,p_api_name  IN VARCHAR2
   ,p_message   IN VARCHAR2
  ) IS
  BEGIN
    --RETURN ;  -- hide the display for hand off demo
    CASE p_output_to
      WHEN 'FND_LOG.STRING' THEN

        IF g_fnd_debug = 'Y' AND
           FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE
        THEN
          fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                        ,p_api_name
                        ,p_message);
        END IF;

      WHEN 'FND_FILE.OUTPUT' THEN
        fnd_file.put_line(fnd_file.OUTPUT
                         ,p_api_name || '.debug_output' || ': ' ||
                          p_message);
      WHEN 'FND_FILE.LOG' THEN
        /*IF g_fnd_debug = 'Y' AND
           FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE
        THEN
          fnd_log.STRING(FND_LOG.LEVEL_PROCEDURE
                        ,p_api_name || '.debug_output'
                        ,p_message);
        END IF;*/
        fnd_file.put_line(fnd_file.LOG
                         ,p_api_name || '.debug_output' || ': ' ||
                          p_message);
         /*--insert into table,for debug only--
         INSERT INTO jmf_shikyu_cfr_rpt_temp
           (rpt_mode
           ,rpt_data_type
           ,attribute10
           ,attribute11
           ,attribute12)
         VALUES
           ('FND_FILE.LOG'
           ,-999
           ,p_api_name
           ,p_message
           ,to_char(SYSDATE,'YYYY-MM-DD HH:MM:SS'));
         COMMIT; */
      ELSE
        NULL;
    END CASE;

  END debug_output;

END JMF_SHIKYU_RPT_UTIL;


/
