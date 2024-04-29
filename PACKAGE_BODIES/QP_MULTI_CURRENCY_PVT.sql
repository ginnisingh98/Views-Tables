--------------------------------------------------------
--  DDL for Package Body QP_MULTI_CURRENCY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_MULTI_CURRENCY_PVT" AS
/* $Header: QPXCONVB.pls 120.0.12010000.6 2010/03/29 11:56:20 dnema ship $ */

-- Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_MULTI_CURRENCY_PVT';
l_debug VARCHAR2(3);

-- Procedure to get a value from a given formula
PROCEDURE Process_Formula_API
(
    l_insert_into_tmp		IN VARCHAR2
   ,l_price_formula_id		IN NUMBER
   ,l_operand_value		IN NUMBER
   ,l_pricing_effective_date    IN DATE
   ,l_line_index		IN NUMBER
   ,l_modifier_value		IN NUMBER
   ,l_formula_based_value       OUT NOCOPY NUMBER
   ,l_return_status	        OUT NOCOPY VARCHAR2
)
IS

l_status 		VARCHAR2(1);

--Begin Bug No: 8427852
CURSOR am_attr_cur IS
	SELECT line_index
		, attribute_type
		, context
		, attribute
		, pricing_status_code
		, qp_number.canonical_to_number(value_from)
	FROM qp_npreq_line_attrs_tmp lattr
	WHERE attribute_type IN ('PRICING', 'PRODUCT')
		AND pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
		AND EXISTS (
			SELECT format_type
			FROM fnd_flex_value_sets VSET,
	                    qp_segments_b SEGMENTS, qp_prc_contexts_b PCONTEXTS
        		WHERE vset.flex_value_set_id = segments.user_valueset_id
				AND segments.application_id = 661
               			AND pcontexts.prc_context_type <> 'QUALIFIER'
               			AND pcontexts.prc_context_code = lattr.context
               			AND segments.segment_mapping_column = lattr.attribute
   			        AND segments.prc_context_id = pcontexts.prc_context_id
              			AND vset.format_type = 'N'
	);

CURSOR attr_cur IS
	SELECT line_index
		,attribute_type
		,context
		,attribute
		,pricing_status_code
		,qp_number.canonical_to_number(value_from)
	FROM qp_npreq_line_attrs_tmp 		lattr
	WHERE attribute_type IN ('PRICING', 'PRODUCT')
		AND pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
		AND EXISTS(
			SELECT format_type
			FROM   fnd_flex_value_sets vset
				,fnd_descr_flex_column_usages	dflex
			WHERE  vset.flex_value_set_id = dflex.flex_value_set_id
				AND dflex.application_id = 661
				AND dflex.descriptive_flexfield_name = 'QP_ATTR_DEFNS_PRICING'
				AND dflex.descriptive_flex_context_code = lattr.context
				AND dflex.application_column_name = lattr.attribute
				AND    vset.format_type = 'N'
		);

TYPE Num_Type IS TABLE OF Number INDEX BY BINARY_INTEGER;
TYPE Char_Type IS TABLE OF Varchar2(30) INDEX BY BINARY_INTEGER;

l_line_index_tbl           Num_Type;
l_attribute_type_tbl       Char_Type;
l_context_tbl              Char_Type;
l_attribute_tbl            Char_Type;
l_pricing_status_code_tbl  Char_Type;
l_value_from_tbl           Num_Type;
l_value_from               Number;
l_msg_attribute            VARCHAR2(80);
l_msg_context              VARCHAR2(240);
l_rows  NATURAL := 5000;
--End Bug No: 8427852 scroll down for more changes

BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF l_debug = FND_API.G_TRUE THEN
  qp_preq_grp.engine_debug('QP_MULTI_CURRENCY_PVT.Process_Formula_API - l_insert_into_tmp = '
                                  || l_insert_into_tmp);
  qp_preq_grp.engine_debug('QP_MULTI_CURRENCY_PVT.Process_Formula_API - l_price_formula_id = '
                                  || l_price_formula_id);
  qp_preq_grp.engine_debug('QP_MULTI_CURRENCY_PVT.Process_Formula_API - l_operand_value = '
                                  || l_operand_value);
  qp_preq_grp.engine_debug('QP_MULTI_CURRENCY_PVT.Process_Formula_API - l_pricing_effective_date = '
                                  || l_pricing_effective_date);
  qp_preq_grp.engine_debug('QP_MULTI_CURRENCY_PVT.Process_Formula_API - l_line_index = '
                                  || l_line_index);
  qp_preq_grp.engine_debug('QP_MULTI_CURRENCY_PVT.Process_Formula_API - l_modifier_value = '
                                  || l_modifier_value);
  qp_preq_grp.engine_debug('QP_MULTI_CURRENCY_PVT.Process_Formula_API - l_formula_based_value = '
                                  || l_formula_based_value);
  qp_preq_grp.engine_debug('QP_MULTI_CURRENCY_PVT.Process_Formula_API - l_return_status = '
                                  || l_return_status);

  END IF;

  qp_debug_util.tstart('PROCESS_FORMULA_API', 'PROCESS_FORMULA_API'); --by smuhamme

  l_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_insert_into_tmp = 'Y' THEN

    -- Change flexible mask to mask below for formula pattern use
    /*qp_number.canonical_mask :=
    '00999999999999999999999.99999999999999999999999999999999999999';*/ --Bug No: 8427852

     delete from qp_preq_line_attrs_formula_tmp;

  IF qp_util.attrmgr_installed = 'Y' THEN
    --Begin Bug No: 8427852

    OPEN am_attr_cur;
    qp_number.canonical_mask := 'FM999999999999999999999.9999999999999999999999999999999999999999';
    LOOP
	l_line_index_tbl.delete;
	l_attribute_type_tbl.delete;
	l_context_tbl.delete;
	l_attribute_tbl.delete;
	l_pricing_status_code_tbl.delete;
	l_value_from_tbl.delete;

	FETCH am_attr_cur BULK COLLECT
		INTO l_line_index_tbl, l_attribute_type_tbl, l_context_tbl,
                     l_attribute_tbl, l_pricing_status_code_tbl,
                     l_value_from_tbl
		LIMIT l_rows;
	EXIT WHEN l_line_index_tbl.COUNT = 0;

	qp_number.canonical_mask := '00999999999999999999999.99999999999999999999999999999999999999';

	FORALL i IN l_line_index_tbl.FIRST..l_line_index_tbl.LAST
		INSERT INTO qp_preq_line_attrs_formula_tmp
			(line_index, attribute_type, context,
			 attribute, pricing_status_code, value_from)
		VALUES
			( l_line_index_tbl(i), l_attribute_type_tbl(i), l_context_tbl(i),
			  l_attribute_tbl(i), l_pricing_status_code_tbl(i),
			  qp_number.number_to_canonical(l_value_from_tbl(i))
                );

	qp_number.canonical_mask := 'FM999999999999999999999.9999999999999999999999999999999999999999';
   END LOOP;
   CLOSE am_attr_cur;

   --commented for Bug No: 8427852
    -- Insert request line attributes with datatype = 'N'
/*    INSERT INTO
      qp_preq_line_attrs_formula_tmp
      (
        line_index
       ,attribute_type
       ,context
       ,attribute
       ,pricing_status_code
       ,value_from
      )
      SELECT
        line_index
       ,attribute_type
       ,context
       ,attribute
       ,pricing_status_code
       ,qp_number.number_to_canonical(to_number(value_from))
      FROM
        qp_npreq_line_attrs_tmp 		lattr
      WHERE
        attribute_type IN ('PRICING', 'PRODUCT')
      AND
        pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
      AND
        EXISTS(
               SELECT format_type
               FROM fnd_flex_value_sets VSET,
                    qp_segments_b SEGMENTS, qp_prc_contexts_b PCONTEXTS
               WHERE vset.flex_value_set_id = segments.user_valueset_id
               AND segments.application_id = 661
               AND pcontexts.prc_context_type <> 'QUALIFIER'
               AND pcontexts.prc_context_code = lattr.context
               AND segments.segment_mapping_column = lattr.attribute
               AND segments.prc_context_id = pcontexts.prc_context_id
               AND vset.format_type = 'N'
              );*/
	--End Bug No: 8427852

    -- Insert request line attributes with datatype 'X','Y','C' or null
    INSERT INTO
      qp_preq_line_attrs_formula_tmp
      (
        line_index
       ,attribute_type
       ,context
       ,attribute
       ,pricing_status_code
       ,value_from
      )
      SELECT
        line_index
       ,attribute_type
       ,context
       ,attribute
       ,pricing_status_code
       ,value_from
      FROM
        qp_npreq_line_attrs_tmp 		lattr
      WHERE
        attribute_type IN ('PRICING', 'PRODUCT')
      AND
        pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
      AND
        NOT  EXISTS(
               SELECT format_type
               FROM fnd_flex_value_sets VSET,
                    qp_segments_b SEGMENTS, qp_prc_contexts_b PCONTEXTS
               WHERE vset.flex_value_set_id = segments.user_valueset_id
               AND segments.application_id = 661
               AND pcontexts.prc_context_type <> 'QUALIFIER'
               AND pcontexts.prc_context_code = lattr.context
               AND segments.segment_mapping_column = lattr.attribute
               AND segments.prc_context_id = pcontexts.prc_context_id
               AND vset.format_type = 'N'
              );

  ELSE
    --Begin Bug No: 8427852
    OPEN attr_cur;
    qp_number.canonical_mask := 'FM999999999999999999999.9999999999999999999999999999999999999999';
    LOOP
    	l_line_index_tbl.delete;
	l_attribute_type_tbl.delete;
	l_context_tbl.delete;
	l_attribute_tbl.delete;
	l_pricing_status_code_tbl.delete;
	l_value_from_tbl.delete;

	FETCH attr_cur BULK COLLECT
	INTO l_line_index_tbl, l_attribute_type_tbl, l_context_tbl,
		l_attribute_tbl, l_pricing_status_code_tbl, l_value_from_tbl
	LIMIT l_rows;

	EXIT WHEN l_line_index_tbl.COUNT = 0;

	qp_number.canonical_mask := '00999999999999999999999.99999999999999999999999999999999999999';

	FORALL i IN l_line_index_tbl.FIRST..l_line_index_tbl.LAST
		INSERT INTO qp_preq_line_attrs_formula_tmp
			(line_index, attribute_type, context,
			 attribute, pricing_status_code, value_from)
		VALUES
			( l_line_index_tbl(i), l_attribute_type_tbl(i), l_context_tbl(i),
			  l_attribute_tbl(i), l_pricing_status_code_tbl(i),
			  qp_number.number_to_canonical(l_value_from_tbl(i))
                );

	qp_number.canonical_mask := 'FM999999999999999999999.9999999999999999999999999999999999999999';
    END LOOP;
    CLOSE attr_cur;
    --commented for Bug No: 8427852
    -- Insert request line attributes with datatype = 'N'
    /*INSERT INTO
      qp_preq_line_attrs_formula_tmp
      (
        line_index
       ,attribute_type
       ,context
       ,attribute
       ,pricing_status_code
       ,value_from
      )
      SELECT
        line_index
       ,attribute_type
       ,context
       ,attribute
       ,pricing_status_code
       ,qp_number.number_to_canonical(to_number(value_from))
      FROM
        qp_npreq_line_attrs_tmp 		lattr
      WHERE
        attribute_type IN ('PRICING', 'PRODUCT')
      AND
        pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
      AND
        EXISTS(
               SELECT format_type
               FROM   fnd_flex_value_sets 		vset
                     ,fnd_descr_flex_column_usages	dflex
               WHERE  vset.flex_value_set_id = dflex.flex_value_set_id
               AND    dflex.application_id = 661
               AND    dflex.descriptive_flexfield_name = 'QP_ATTR_DEFNS_PRICING'
               AND    dflex.descriptive_flex_context_code = lattr.context
               AND    dflex.application_column_name = lattr.attribute
               AND    vset.format_type = 'N'
              ) ;*/
     -- AND
     --   NOT EXISTS
     --          (SELECT 'x' FROM qp_preq_line_attrs_formula_tmp
     --          WHERE   line_index = lattr.line_index);
     --End Bug No: 8427852

    -- Insert request line attributes with datatype 'X','Y','C' or null
    INSERT INTO
      qp_preq_line_attrs_formula_tmp
      (
        line_index
       ,attribute_type
       ,context
       ,attribute
       ,pricing_status_code
       ,value_from
      )
      SELECT
        line_index
       ,attribute_type
       ,context
       ,attribute
       ,pricing_status_code
       ,value_from
      FROM
        qp_npreq_line_attrs_tmp 		lattr
      WHERE
        attribute_type IN ('PRICING', 'PRODUCT')
      AND
        pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
      AND
        NOT  EXISTS(
               SELECT format_type
               FROM   fnd_flex_value_sets 		vset
                     ,fnd_descr_flex_column_usages	dflex
               WHERE  vset.flex_value_set_id = dflex.flex_value_set_id
               AND    dflex.application_id = 661
               AND    dflex.descriptive_flexfield_name = 'QP_ATTR_DEFNS_PRICING'
               AND    dflex.descriptive_flex_context_code = lattr.context
               AND    dflex.application_column_name = lattr.attribute
           --    AND    vset.format_type IN ('X','Y','C')
	       AND    vset.format_type = 'N'
              );
      --AND
       -- NOT EXISTS
        --      (SELECT 'x' FROM qp_preq_line_attrs_formula_tmp
         --      WHERE   line_index = lattr.line_index);

    END IF; -- attribute manager installed
      --Change mask back to flexible mask.
      qp_number.canonical_mask :=
      'FM999999999999999999999.9999999999999999999999999999999999999999';

  END IF;


  l_formula_based_value :=
    QP_FORMULA_PRICE_CALC_PVT.Calculate
                ( p_price_formula_id     => l_price_formula_id
                 ,p_list_price       	 => l_operand_value
                 ,p_price_effective_date => l_pricing_effective_date
                 ,p_line_index	         => l_line_index
                 ,p_list_line_type_code  => NULL
                 ,x_return_status        => l_status
                 ,p_modifier_value       => l_modifier_value
                );

    IF l_status <> FND_API.G_RET_STS_SUCCESS THEN

      l_return_status := FND_API.G_RET_STS_ERROR;

    END IF;


  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Formula return status: '||l_status);
    QP_PREQ_GRP.engine_debug('Formula base rate: '|| l_formula_based_value);

  IF l_status IS NULL THEN
    QP_PREQ_GRP.engine_debug('Formula return status is NULL');
    QP_PREQ_GRP.engine_debug('FND_API.G_RET_STS_ERROR: '||FND_API.G_RET_STS_ERROR);
    null;
  END IF;

  END IF;

  qp_debug_util.tstop('PROCESS_FORMULA_API'); --by smuhamme
EXCEPTION

  WHEN OTHERS THEN

    IF l_debug = FND_API.G_TRUE THEN
    qp_preq_grp.engine_debug('QP_MULTI_CURRENCY_PVT.Process_Formula_API - OTHERS exception '
                                  || SQLERRM);
    END IF;
    l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Process_Formula_API;


PROCEDURE Currency_Conversion_API
(   p_user_conversion_rate          IN  NUMBER
   ,p_user_conversion_type          IN  VARCHAR2
   ,p_function_currency		    IN  VARCHAR2
   ,p_rounding_flag		    IN  VARCHAR2
)

IS

l_conversion_rate	NUMBER;
l_operand_value		NUMBER;
l_insert_into_tmp 	VARCHAR2(1);
l_formula_based_value   NUMBER;
l_conversion_date	DATE;

l_process_status	VARCHAR2(1);
l_formula_status	VARCHAR2(1);
l_modifier_value	NUMBER;
l_round_price_status	VARCHAR2(1);

l_user_conversion_type  qp_currency_details.conversion_type%TYPE; --bug 9503901

rows 			NATURAL := 5000;

TYPE line_index_tab         IS TABLE OF qp_npreq_ldets_tmp.line_index%TYPE INDEX BY BINARY_INTEGER;
TYPE line_detail_index_tab  IS TABLE OF qp_npreq_ldets_tmp.line_detail_index%TYPE INDEX BY BINARY_INTEGER;
TYPE operand_value_tab	    IS TABLE OF qp_npreq_ldets_tmp.operand_value%TYPE INDEX BY BINARY_INTEGER;
TYPE operand_calc_code_tab    IS TABLE OF qp_npreq_ldets_tmp.operand_calculation_code%TYPE INDEX BY BINARY_INTEGER;
TYPE base_currency_code_tab     IS TABLE OF qp_npreq_ldets_tmp.base_currency_code%TYPE INDEX BY BINARY_INTEGER;
TYPE pricing_effective_date_tab IS TABLE OF qp_npreq_ldets_tmp.pricing_effective_date%TYPE INDEX BY BINARY_INTEGER;
TYPE currency_header_id_tab     IS TABLE OF qp_currency_details.currency_header_id%TYPE INDEX BY BINARY_INTEGER;
TYPE to_currency_code_tab       IS TABLE OF qp_currency_details.to_currency_code%TYPE INDEX BY BINARY_INTEGER;
TYPE fixed_value_tab            IS TABLE OF qp_currency_details.fixed_value%TYPE INDEX BY BINARY_INTEGER;
TYPE price_formula_id_tab	IS TABLE OF qp_currency_details.price_formula_id%TYPE INDEX BY BINARY_INTEGER;
TYPE conversion_type_tab        IS TABLE OF qp_currency_details.conversion_type%TYPE INDEX BY BINARY_INTEGER;
TYPE conversion_date_type_tab   IS TABLE OF qp_currency_details.conversion_date_type%TYPE INDEX BY BINARY_INTEGER;
TYPE conversion_date_tab        IS TABLE OF qp_currency_details.conversion_date%TYPE INDEX BY BINARY_INTEGER;
TYPE rounding_factor_tab        IS TABLE OF qp_currency_details.rounding_factor%TYPE INDEX BY BINARY_INTEGER;
TYPE markup_operator_tab        IS TABLE OF qp_currency_details.markup_operator%TYPE INDEX BY BINARY_INTEGER;
TYPE markup_value_tab           IS TABLE OF qp_currency_details.markup_value%TYPE INDEX BY BINARY_INTEGER;
TYPE markup_formula_id_tab      IS TABLE OF qp_currency_details.markup_formula_id%TYPE INDEX BY BINARY_INTEGER;
TYPE error_message_tab          IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE status_code_tab		IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE lines_status_code_tab		IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;


line_index_t             line_index_tab;
line_detail_index_t      line_detail_index_tab;
operand_value_t	         operand_value_tab;
base_currency_code_t     base_currency_code_tab;
pricing_effective_date_t pricing_effective_date_tab;
currency_header_id_t     currency_header_id_tab;
to_currency_code_t	 to_currency_code_tab;
fixed_value_t            fixed_value_tab;
price_formula_id_t       price_formula_id_tab;
conversion_type_t        conversion_type_tab;
conversion_date_type_t   conversion_date_type_tab;
conversion_date_t        conversion_date_tab;
rounding_factor_t        rounding_factor_tab;
markup_operator_t        markup_operator_tab;
markup_value_t           markup_value_tab;
markup_formula_id_t      markup_formula_id_tab;

result_operand_value_t	 operand_value_tab;
error_message_t		 error_message_tab;
status_code_t            status_code_tab;
lines_status_code_t            lines_status_code_tab;
operand_calc_code_t	 operand_calc_code_tab;

-- Added operand_calculation_code in ('UNIT_PRICE','BLOCK_PRICE','BREAKUNIT_PRICE') in the where
-- condition. operand_calculation_code in qp_npreq_ldets_tmp is the same as arithmetic_operator in
-- qp_list_lines. This is to not process the currency conversion of service items which have
-- PERCENT_PRICE as the aritmetic operator . This is because the pricing engine computes the
-- price of the parent item after doing the currency conversion and them simply applies the
-- percent price on the parent item's price to compute the price of the service item.

CURSOR c_currency_conversions
IS

  SELECT
    b.line_index
   ,b.line_detail_index
   ,b.operand_value
   ,b.operand_calculation_code
   ,b.base_currency_code
   ,b.pricing_effective_date
   ,a.currency_header_id
   ,a.to_currency_code
   ,a.fixed_value
   ,a.price_formula_id
   ,a.conversion_type
   ,a.conversion_date_type
   ,a.conversion_date
   ,a.rounding_factor
   ,a.markup_operator
   ,a.markup_value
   ,a.markup_formula_id
  FROM
    qp_currency_details a,
    qp_npreq_ldets_tmp   b
    --j_qp_npreq_ldets_tmp b
  WHERE
    	a.currency_header_id = b.currency_header_id
  AND	a.to_currency_code = b.order_currency
  AND   a.currency_detail_id = b.currency_detail_id
  AND   TRUNC(b.pricing_effective_date) >= TRUNC(nvl(a.start_date_active,b.pricing_effective_date))
  AND   TRUNC(b.pricing_effective_date) <= TRUNC(nvl(a.end_date_active, b.pricing_effective_date))
  AND   b.created_from_list_type_code IN ('PRL', 'AGR')
  AND   b.CREATED_FROM_LIST_LINE_TYPE <> 'PBH' ---7681676 PHB line does not have operand_value, so no rounding is required
  AND   b.operand_calculation_code IN ('UNIT_PRICE','BLOCK_PRICE','BREAKUNIT_PRICE')
  AND   b.pricing_status_code = 'N';


BEGIN

	qp_debug_util.tstart('CURRENCY_CONVERSION_API', 'CURRENCY_CONVERSION_API'); --by smuhamme

  --If there is a formula, then need to insert pricing attributes once for each run
l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
IF l_debug = FND_API.G_TRUE THEN
qp_preq_grp.engine_debug('Currency_Conversion_API - Enter');
END IF;

IF l_debug = FND_API.G_TRUE THEN
qp_preq_grp.engine_debug('Currency_Conversion_API - p_user_conversion_rate' || p_user_conversion_rate);
qp_preq_grp.engine_debug('Currency_Conversion_API - p_user_conversion_type' || p_user_conversion_type);
qp_preq_grp.engine_debug('Currency_Conversion_API - p_function_currency' || p_function_currency);
qp_preq_grp.engine_debug('Currency_Conversion_API - p_rounding_flag' || p_rounding_flag);

END IF;

   l_insert_into_tmp := 'Y'; --Bug No. 8323485, performace reason, moved from loop to here

  OPEN c_currency_conversions;

  LOOP

    line_index_t.DELETE;
    line_detail_index_t.DELETE;
    operand_value_t.DELETE;
    operand_calc_code_t.DELETE;
    base_currency_code_t.DELETE;
    pricing_effective_date_t.DELETE;
    currency_header_id_t.DELETE;
    to_currency_code_t.DELETE;
    fixed_value_t.DELETE;
    price_formula_id_t.DELETE;
    conversion_type_t.DELETE;
    conversion_date_type_t.DELETE;
    conversion_date_t.DELETE;
    rounding_factor_t.DELETE;
    markup_operator_t.DELETE;
    markup_value_t.DELETE;
    markup_formula_id_t.DELETE;
    result_operand_value_t.DELETE;
    error_message_t.DELETE;
    status_code_t.DELETE;
    lines_status_code_t.DELETE;

    -- Bulk Fetch 5000 rows each time for performance
    FETCH c_currency_conversions BULK COLLECT INTO
      line_index_t,
      line_detail_index_t,
      operand_value_t,
      operand_calc_code_t,
      base_currency_code_t,
      pricing_effective_date_t,
      currency_header_id_t,
      to_currency_code_t,
      fixed_value_t,
      price_formula_id_t,
      conversion_type_t,
      conversion_date_type_t,
      conversion_date_t,
      rounding_factor_t,
      markup_operator_t,
      markup_value_t,
      markup_formula_id_t
    LIMIT rows;


IF l_debug = FND_API.G_TRUE THEN
qp_preq_grp.engine_debug('Currency_Conversion_API - record count = '||line_index_t.count);
END IF;
    IF line_index_t.count > 0 THEN
    --process every record in this fetch

      FOR J IN line_index_t.FIRST..line_index_t.LAST
      LOOP

      BEGIN

        --l_insert_into_tmp := 'Y';  --moved before the loop, smuhamme bug#8323485

        --l_process_status  := FND_API.G_RET_STS_SUCCESS;

        error_message_t(J) := NULL;

-- status_code_t is used for updating the qp_npreq_ldets_tmp table Bug 2327718

        status_code_t(J) := 'N';

-- Added lines_status_code_t for updating the qp_npreq_lines_tmp table Bug 2327718

        lines_status_code_t(J) := 'UPDATED';

        l_conversion_rate := NULL;
        l_operand_value   := NULL;
	result_operand_value_t(J) := NULL;

IF l_debug = FND_API.G_TRUE THEN
qp_preq_grp.engine_debug('Currency_Conversion_API - conversion_type = '||conversion_type_t(J));

END IF;
        IF conversion_type_t(J) = 'FIXED' THEN

          -- Use the fixed value
          l_conversion_rate := fixed_value_t(J);

          IF l_debug = FND_API.G_TRUE THEN
          qp_preq_grp.engine_debug('Currency_Conversion_API - FIXED l_conversion_rate = '
                                   ||l_conversion_rate);
          END IF;

        ELSIF conversion_type_t(J) = 'TRANSACTION' THEN

          -- Use the conversion type and rate passed from OM
          IF --p_user_conversion_type = 'USER' AND
             p_user_conversion_rate is NOT NULL THEN

            IF p_function_currency = base_currency_code_t(J) THEN

              -- Only when function and base currency are same, use the OM rate

              IF l_debug = FND_API.G_TRUE THEN
              qp_preq_grp.engine_debug('Currency_Conversion_API - TRANSACTION function and base currency same ');
              END IF;

              -- [julin/4099147] integrating apps users expect entered rate to
              -- be from transaction currency to functional currency
              l_conversion_rate := 1/p_user_conversion_rate;
              IF l_debug = FND_API.G_TRUE THEN
              qp_preq_grp.engine_debug('Currency_Conversion_API - TRANSACTION l_conversion_rate = '
                                      ||l_conversion_rate);

              END IF;
            ELSE

              IF l_debug = FND_API.G_TRUE THEN
              qp_preq_grp.engine_debug('Currency_Conversion_API - TRANSACTION function and base currency different ');
              END IF;
              -- Function and base currency not same, raise error
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('QP', 'QP_DIFF_FUNC_AND_BASE_CURR');
                FND_MESSAGE.SET_TOKEN('BASE_CURR', base_currency_code_t(J));
                FND_MESSAGE.SET_TOKEN('FUNC_CURR', p_function_currency);

                error_message_t(J) := FND_MESSAGE.GET;
                status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;
                lines_status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;

              END IF;

              RAISE FND_API.G_EXC_ERROR;

            END IF;

          ELSIF p_user_conversion_type IS NOT NULL THEN
             --   p_user_conversion_type <> 'USER' THEN

IF l_debug = FND_API.G_TRUE THEN
qp_preq_grp.engine_debug('Currency_Conversion_API - x_from_currency = '||base_currency_code_t(J) );
qp_preq_grp.engine_debug('Currency_Conversion_API - x_to_currency = '||  to_currency_code_t(J));
qp_preq_grp.engine_debug('Currency_Conversion_API - x_conversion_date = '|| pricing_effective_date_t(J));
qp_preq_grp.engine_debug('Currency_Conversion_API - x_conversion_type = '|| p_user_conversion_type);

END IF;
            -- use the functional conversion rate defined in GL(from base currency to order currency)
            l_conversion_rate := gl_currency_api.get_rate_sql
                               (
			         x_from_currency => base_currency_code_t(J)
                                ,x_to_currency   => to_currency_code_t(J)
                                ,x_conversion_date  => pricing_effective_date_t(J)
                                ,x_conversion_type  => p_user_conversion_type
                               );

IF l_debug = FND_API.G_TRUE THEN
qp_preq_grp.engine_debug('Currency_Conversion_API - GL l_conversion_rate = '|| l_conversion_rate);
END IF;

            IF l_conversion_rate = -1 THEN

              -- No currency rate found from GL, raise error
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('QP', 'QP_CONV_RATE_NOT_FOUND');
                FND_MESSAGE.SET_TOKEN('FROM_CURR', base_currency_code_t(J));
                FND_MESSAGE.SET_TOKEN('TO_CURR', to_currency_code_t(J));
                FND_MESSAGE.SET_TOKEN('CONV_DATE', pricing_effective_date_t(J));
                FND_MESSAGE.SET_TOKEN('CONV_TYPE', p_user_conversion_type);

                error_message_t(J) := FND_MESSAGE.GET;
                status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;
                lines_status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;

              END IF;

              RAISE FND_API.G_EXC_ERROR;

            ELSIF l_conversion_rate = -2 THEN

              -- Base currency or/and order currency are in valid, raise error
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('QP','QP_INVALID_CURRENCY');

                error_message_t(J) := FND_MESSAGE.GET;
                status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;
                lines_status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;


              END IF;

              RAISE FND_API.G_EXC_ERROR;

            END IF;


          ELSE

            IF l_debug = FND_API.G_TRUE THEN
            qp_preq_grp.engine_debug('Currency_Conversion_API - TRANSACTION no conversion type ');
            END IF;
            -- For 'TRANSACTION' conv, OM did not pass user conversion type, raise error
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

               FND_MESSAGE.SET_NAME('QP', 'QP_NO_USER_CONVTYPE_F_TRANSACT');

               error_message_t(J) := FND_MESSAGE.GET;
               status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;
               lines_status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;

            END IF;


            RAISE FND_API.G_EXC_ERROR;

          END IF;


        ELSIF conversion_type_t(J) = 'FORMULA' THEN

          --Call the process_formula_api to return the calculated value

          l_modifier_value := NULL;

          Process_Formula_API
          (
            l_insert_into_tmp
           ,price_formula_id_t(J)
           ,operand_value_t(J)
           ,pricing_effective_date_t(J)
           ,line_index_t(J)
           ,l_modifier_value
           ,l_formula_based_value
           ,l_formula_status
          );


          IF l_formula_status <> FND_API.G_RET_STS_SUCCESS THEN

            IF l_debug = FND_API.G_TRUE THEN
            qp_preq_grp.engine_debug('Currency_Conversion_API - FORMULA not success');
            END IF;
            -- Formula calculation failed, raise error
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.SET_NAME('QP', 'QP_FORMULA_CALC_FAILURE');

              error_message_t(J) := FND_MESSAGE.GET;
              status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;
              lines_status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;

            END IF;

            RAISE FND_API.G_EXC_ERROR;

          END IF;



          --Reset the insert flag so it only inserts once for each run
          l_insert_into_tmp:= 'N';


          -- Use the rate returned from the formula calculation
          l_conversion_rate := l_formula_based_value;

          IF l_debug = FND_API.G_TRUE THEN
          qp_preq_grp.engine_debug('Currency_Conversion_API - FORMULA l_conversion_rate'
                                   || l_conversion_rate);
          END IF;
          --End of processing conversion type ='FORMULA'

        ELSIF conversion_type_t(J)  IS NULL THEN

          IF l_debug = FND_API.G_TRUE THEN
          qp_preq_grp.engine_debug('Currency_Conversion_API - null conversion type');
          END IF;
           IF to_currency_code_t(J) = base_currency_code_t(J) THEN

          IF l_debug = FND_API.G_TRUE THEN
          qp_preq_grp.engine_debug('Currency_Conversion_API - null conversion type - curr matches');
          END IF;
             --There order currency and base currency are same, the conversion rate is 1

             l_conversion_rate := 1;

           END IF;


        ELSE  --All conversion types other than FIXED, TRANSACTION and FORMULA

          IF conversion_date_type_t(J) = 'FIXED' THEN
            IF l_debug = FND_API.G_TRUE THEN
            qp_preq_grp.engine_debug('Currency_Conversion_API - date type FIXED');
            END IF;
            l_conversion_date := conversion_date_t(J);
          ELSE
            l_conversion_date := pricing_effective_date_t(J);
          END IF;
-- ADDED FOR   BUG 8429593
 IF p_user_conversion_rate is NOT NULL THEN

            IF p_function_currency = base_currency_code_t(J) THEN

              -- Only when function and base currency are same, use the OM rate

              IF l_debug = FND_API.G_TRUE THEN
              qp_preq_grp.engine_debug('Currency_Conversion_API - function and base currency same ');
              END IF;

              l_conversion_rate := 1/p_user_conversion_rate;
              IF l_debug = FND_API.G_TRUE THEN
              qp_preq_grp.engine_debug('Currency_Conversion_API - l_conversion_rate = '
                                      ||l_conversion_rate);

              END IF;
            ELSE

              IF l_debug = FND_API.G_TRUE THEN
              qp_preq_grp.engine_debug('Currency_Conversion_API - function and base currency different ');
              END IF;
              -- Function and base currency not same, raise error
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('QP', 'QP_DIFF_FUNC_AND_BASE_CURR');
                FND_MESSAGE.SET_TOKEN('BASE_CURR', base_currency_code_t(J));
                FND_MESSAGE.SET_TOKEN('FUNC_CURR', p_function_currency);

                error_message_t(J) := FND_MESSAGE.GET;
                status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;
                lines_status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;

              END IF;

              RAISE FND_API.G_EXC_ERROR;

            END IF;

          ELSE

	     --bug 9503901
	     IF p_user_conversion_type IS NOT NULL THEN
	        l_user_conversion_type := p_user_conversion_type;
             ELSE
	        l_user_conversion_type := conversion_type_t(J);
             END IF;

          l_conversion_rate := gl_currency_api.get_rate_sql
                               (
		                 x_from_currency => base_currency_code_t(J)
                                ,x_to_currency   => to_currency_code_t(J)
                                ,x_conversion_date  => l_conversion_date
                                --,x_conversion_type  => conversion_type_t(J) --bug 9503901
				,x_conversion_type  => l_user_conversion_type --bug 9503901
                               );

            IF l_debug = FND_API.G_TRUE THEN
            qp_preq_grp.engine_debug('Currency_Conversion_API - GL2 l_conversion_rate'
                                     || l_conversion_rate);
            END IF;
            IF l_conversion_rate = -1 THEN

              -- No currency rate found from GL, raise error
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('QP', 'QP_CONV_RATE_NOT_FOUND');
                FND_MESSAGE.SET_TOKEN('FROM_CURR', base_currency_code_t(J));
                FND_MESSAGE.SET_TOKEN('TO_CURR', to_currency_code_t(J));
                FND_MESSAGE.SET_TOKEN('CONV_DATE', l_conversion_date);
                FND_MESSAGE.SET_TOKEN('CONV_TYPE', conversion_type_t(J));

                error_message_t(J) := FND_MESSAGE.GET;
                status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;
                lines_status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;

              END IF;

              RAISE FND_API.G_EXC_ERROR;

            ELSIF l_conversion_rate = -2 THEN

              -- Base currency or/and order currency are in valid, raise error
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('QP','QP_INVALID_CURRENCY');

                error_message_t(J) := FND_MESSAGE.GET;
                status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;
                lines_status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;

              END IF;

              RAISE FND_API.G_EXC_ERROR;

            END IF;


         END IF;
END IF ;
         --End of processing of conversion_rate


         IF l_debug = FND_API.G_TRUE THEN
         qp_preq_grp.engine_debug('Currency_Conversion_API - operand_value = '
                                  || operand_value_t(J));
         qp_preq_grp.engine_debug('Currency_Conversion_API - l_conversion_rate = '
                                  || l_conversion_rate);

         END IF;
         -- Bug 2929366 - removed the NVL so that if the operand is null,
         -- after converting it should remain null and error could be raised
         -- "Item and uom is not on the pricelist"
         --result_operand_value_t(J) := NVL(operand_value_t(J), 1) * l_conversion_rate;
         result_operand_value_t(J) := operand_value_t(J) * l_conversion_rate;

         IF l_debug = FND_API.G_TRUE THEN
         qp_preq_grp.engine_debug('Currency_Conversion_API - result_operand_value = '
                                  || result_operand_value_t(J));
         END IF;
         -- Start processing Markup

           IF l_debug = FND_API.G_TRUE THEN
           qp_preq_grp.engine_debug('Currency_Conversion_API - markup_value = '
                                  || markup_value_t(J));
           qp_preq_grp.engine_debug('Currency_Conversion_API - markup_formula_id = '
                                  || markup_formula_id_t(J));
           qp_preq_grp.engine_debug('Currency_Conversion_API - markup_operator = '
                                  || markup_operator_t(J));

           END IF;
         IF markup_value_t(J) IS NOT NULL and markup_formula_id_t(J) IS NULL THEN

           IF markup_operator_t(J) = '%' THEN

             result_operand_value_t(J) := result_operand_value_t(J) +
                                          (result_operand_value_t(J) * (markup_value_t(J) / 100));
             IF l_debug = FND_API.G_TRUE THEN
             qp_preq_grp.engine_debug('Currency_Conversion_API - markup % result_operand_value = '
                                  || result_operand_value_t(J));

             END IF;
           ELSIF markup_operator_t(J) = 'AMT' THEN

             result_operand_value_t(J) := result_operand_value_t(J) + markup_value_t(J);
             IF l_debug = FND_API.G_TRUE THEN
             qp_preq_grp.engine_debug('Currency_Conversion_API - markup AMT result_operand_value = '
                                  || result_operand_value_t(J));
             END IF;

           END IF;

         END IF;



         IF markup_formula_id_t(J) IS NOT NULL THEN
           IF l_debug = FND_API.G_TRUE THEN
           qp_preq_grp.engine_debug('Currency_Conversion_API - markup formula NOT null ');
           END IF;

           --call the process formula API

           Process_Formula_API
           (
             l_insert_into_tmp
            ,markup_formula_id_t(J)
            ,result_operand_value_t(J)
            ,pricing_effective_date_t(J)
            ,line_index_t(J)
            ,markup_value_t(J)
            ,l_formula_based_value
            ,l_formula_status
           );


           IF l_formula_status <> FND_API.G_RET_STS_SUCCESS THEN

           IF l_debug = FND_API.G_TRUE THEN
           qp_preq_grp.engine_debug('Currency_Conversion_API - markup formula fails ');
           END IF;
             -- Formula calculation failed, raise error
             IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                FND_MESSAGE.SET_NAME('QP', 'QP_FORMULA_CALC_FAILURE');

                error_message_t(J) := FND_MESSAGE.GET;
                status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;
                lines_status_code_t(J) := QP_PREQ_GRP.G_STATUS_OTHER_ERRORS;

             END IF;

             RAISE FND_API.G_EXC_ERROR;

           END IF;


           l_insert_into_tmp := 'N';

           IF markup_operator_t(J) = '%' THEN

             result_operand_value_t(J) := result_operand_value_t(J) +
                                         (result_operand_value_t(J) * (l_formula_based_value/100));

             IF l_debug = FND_API.G_TRUE THEN
             qp_preq_grp.engine_debug('Currency_Conversion_API - markup % result_operand_value = '
                                  || result_operand_value_t(J));
             END IF;
           ELSIF markup_operator_t(J) = 'AMT' THEN

             result_operand_value_t(J) := result_operand_value_t(J) + l_formula_based_value;
             IF l_debug = FND_API.G_TRUE THEN
             qp_preq_grp.engine_debug('Currency_Conversion_API - markup AMT result_operand_value = '
                                  || result_operand_value_t(J));

             END IF;
           END IF;

         END IF;   --markup_formula_id_t(J) IS NOT NULL


         -- Call Process Rounding API

         --     l_conversion_rate := l_conversion_rate * Value returned from Rounding;
         if p_rounding_flag = 'Y' then
            IF l_debug = FND_API.G_TRUE THEN
            qp_preq_grp.engine_debug('Currency_Conversion_API - p_rounding_flag = '
                                  || p_rounding_flag);
            END IF;
            qp_util_pub.round_price(
                     P_OPERAND  =>  result_operand_value_t(J)
                     ,P_ROUNDING_FACTOR => rounding_factor_t(J)
                     ,P_USE_MULTI_CURRENCY => 'Y'
                     ,P_PRICE_LIST_ID => NULL
                     ,P_CURRENCY_CODE => NULL
                     ,P_PRICING_EFFECTIVE_DATE => NULL
                     ,X_ROUNDED_OPERAND => result_operand_value_t(J)
                     ,X_STATUS_CODE => l_round_price_status
                     ,p_operand_type   => 'S'
                    );

            IF l_round_price_status <> 'S' THEN
              IF l_debug = FND_API.G_TRUE THEN
              qp_preq_grp.engine_debug('Currency_Conversion_API - round_price fails ');
              END IF;

              -- Formula calculation failed, raise error
              IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                 error_message_t(J) := FND_MESSAGE.GET;
                 status_code_t(J) := FND_API.G_RET_STS_ERROR;
                 lines_status_code_t(J) := FND_API.G_RET_STS_ERROR;

              END IF;

              RAISE FND_API.G_EXC_ERROR;

            END IF;
            IF l_debug = FND_API.G_TRUE THEN
            qp_preq_grp.engine_debug('Currency_Conversion_API - after rounding result_operand_value = '
                                  || result_operand_value_t(J));

            END IF;
         END IF; -- rounding flag

      EXCEPTION

          WHEN FND_API.G_EXC_ERROR THEN
            IF l_debug = FND_API.G_TRUE THEN
            qp_preq_grp.engine_debug('Currency_Conversion_API - handle exception FND_API.G_EXC_ERROR');

            END IF;
            NULL;

          --WHEN OTHERS THEN

          --NULL;

        END;

      END LOOP;

    END IF;   --IF line_index_t.count>0

    IF l_debug = FND_API.G_TRUE THEN
    qp_preq_grp.engine_debug('Currency_Conversion_API - BEFORE updating the temp tables = ');
    qp_preq_grp.engine_debug('Currency_Conversion_API - line_index_t.count' || line_index_t.count);
    END IF;
    --sql statement upd1
    IF line_index_t.count > 0 THEN

      IF l_debug = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('Currency_Conversion_API - updating the temp tables = ');

      END IF;
      FORALL K IN line_index_t.FIRST..line_index_t.LAST

        UPDATE qp_npreq_ldets_tmp
        SET    operand_value       = result_operand_value_t(K)
              ,pricing_status_text = error_message_t(K)
              ,pricing_status_code = status_code_t(K)
        WHERE  line_index        = line_index_t(K)
        AND    line_detail_index = line_detail_index_t(K)
        AND    pricing_status_code = 'N';

      FORALL K IN line_index_t.FIRST..line_index_t.LAST

        UPDATE qp_npreq_lines_tmp
        SET unit_price = decode(operand_calc_code_t(K) , 'LIST_PRICE', result_operand_value_t(K),NULL),
            percent_price = decode(operand_calc_code_t(K) , 'PERCENT_PRICE', result_operand_value_t(K)
                                                          , NULL)
              ,pricing_status_text = error_message_t(K)
              ,pricing_status_code = lines_status_code_t(K)
        WHERE  line_index = line_index_t(K);

    END IF;

    IF l_debug = FND_API.G_TRUE THEN
    qp_preq_grp.engine_debug('Currency_Conversion_API - after updating the temp tables ');

    END IF;
   EXIT WHEN c_currency_conversions%NOTFOUND;

   END LOOP;

   CLOSE c_currency_conversions;

	qp_debug_util.tstop('CURRENCY_CONVERSION_API'); --by smuhamme

EXCEPTION

    /*
     WHEN FND_API.G_EXC_ERROR THEN

       l_process_status := FND_API.G_RET_STS_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

         FND_MESSAGE.SET_NAME('QP','QP_CURR_CONV_EXP_ERROR');

       END IF;
     */
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       l_process_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

         FND_MESSAGE.SET_NAME('QP','QP_CURR_CONV_UNEXPECTED_ERROR');

       END IF;

     WHEN OTHERS THEN

       IF l_debug = FND_API.G_TRUE THEN
       qp_preq_grp.engine_debug('Currency_Conversion_API - OTHERS exception SQLERRM' || SQLERRM);
       END IF;
       l_process_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

         FND_MSG_PUB.Add_Exc_Msg
		  (G_PKG_NAME
		  , 'QP_MULTI_CURRENCY_PVT'
		  );

      END IF;

      IF c_currency_conversions%ISOPEN THEN
        CLOSE c_currency_conversions;
      END IF;

IF l_debug = FND_API.G_TRUE THEN
qp_preq_grp.engine_debug('Currency_Conversion_API - End');
END IF;
END Currency_Conversion_Api;

END QP_MULTI_CURRENCY_PVT;

/
