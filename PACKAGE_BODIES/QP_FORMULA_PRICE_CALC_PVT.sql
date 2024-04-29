--------------------------------------------------------
--  DDL for Package Body QP_FORMULA_PRICE_CALC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_FORMULA_PRICE_CALC_PVT" AS
/* $Header: QPXVCALB.pls 120.2.12010000.4 2010/03/03 12:56:50 kdurgasi ship $ */

l_debug VARCHAR2(3);
-----------------------------------------------------
/* The following is a customizable Public Function */
-----------------------------------------------------
FUNCTION Get_Custom_Price(p_price_formula_id     IN NUMBER,
                          p_list_price           IN NUMBER,
					 p_price_effective_date IN DATE,
					 p_req_line_attrs_tbl   IN QP_FORMULA_PRICE_CALC_PVT.REQ_LINE_ATTRS_TBL)
RETURN NUMBER
IS
BEGIN
 RETURN NULL;
END;


-----------------------------------------------------------------
-- Wrapper for Get_Custom_Price called by Java Formula Engine
-- Since Java cannot pass in a table of records, use this wrapper
-- to construct table of records from the new INT tables, then
-- call Get_Custom_Price API
-----------------------------------------------------------------
FUNCTION Java_Custom_Price(p_price_formula_id      IN NUMBER,
                           p_list_price            IN NUMBER,
                           p_price_effective_date  IN DATE,
                           p_line_index            IN NUMBER,
                           p_request_id            IN NUMBER)
RETURN NUMBER
IS
  CURSOR req_line_attrs_cur(a_line_index NUMBER)
  IS
    SELECT line_index, attribute_type, context, attribute, value_from value
    FROM   qp_int_line_attrs_t lattr
    WHERE  request_id = p_request_id
    AND    line_index = p_line_index
    AND    attribute_type IN ('PRICING','PRODUCT')
    AND    pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED;

  -- qual cursor
  CURSOR req_line_attrs_qual_cur(a_line_index NUMBER)
  IS
    SELECT line_index, attribute_type, context, attribute, value_from value
    FROM   qp_int_line_attrs_t lattr
    WHERE  request_id = p_request_id
    AND    line_index = p_line_index
    AND    attribute_type IN ('PRICING','PRODUCT','QUALIFIER')
    AND    pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED;

  l_pass_qualifiers      VARCHAR2(10) := FND_PROFILE.VALUE('QP_PASS_QUALIFIERS_TO_GET_CUSTOM');
  l_req_line_attrs_tbl   QP_FORMULA_PRICE_CALC_PVT.REQ_LINE_ATTRS_TBL;
  i                      NUMBER := 1;
BEGIN
  IF nvl(l_pass_qualifiers, 'N') = 'N' THEN
    FOR l_line_attrs_rec IN req_line_attrs_cur(p_line_index) LOOP
      l_req_line_attrs_tbl(i) := l_line_attrs_rec;
      i := i+1;
    END LOOP;
  ELSE
    FOR l_line_attrs_rec IN req_line_attrs_qual_cur(p_line_index) LOOP
      l_req_line_attrs_tbl(i) := l_line_attrs_rec;
      i := i+1;
    END LOOP;
  END IF;

  RETURN QP_CUSTOM.Get_Custom_Price(p_price_formula_id, p_list_price,
                                    p_price_effective_date, l_req_line_attrs_tbl);
END Java_Custom_Price;


-------------------------------------------------------------------
/* The following is a public procedure to parse a formula for
   arithmetic correctness even before substituting the step numbers
   in it with the corresponding values */
-------------------------------------------------------------------
PROCEDURE Parse_Formula(p_formula IN VARCHAR2,
				    x_return_status OUT NOCOPY VARCHAR2)
IS
 l_cursor   INTEGER;

BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;

      EXECUTE IMMEDIATE 'SELECT ' || p_formula || ' FROM DUAL';

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN

	   x_return_status := FND_API.G_RET_STS_ERROR;

	   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
                 fnd_message.set_name('QP','QP_FORMULA_NOT_FOUND');
--	       FND_MSG_PUB.Add;
	   END IF;

--	   RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

--	   RAISE;

    WHEN OTHERS THEN

	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
	       FND_MSG_PUB.Add_Exc_Msg
		  (G_PKG_NAME
		  , 'Parse Formula'
		  );
	   END IF;

--	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Parse_Formula;


-----------------------------------------------------------------------------
-- This function takes a formula string and substitutes the step numbers with
-- corresponding operand values, then evaluates the resulting expression in
-- the SQL engine to produce a result
-----------------------------------------------------------------------------
FUNCTION Select_From_Dual(p_formula       IN VARCHAR2,
                          p_operand_tbl   IN QP_FORMULA_RULES_PVT.T_OPERAND_TBL_TYPE)
RETURN NUMBER
IS
  l_char              VARCHAR2(1) := '';
  l_number            VARCHAR2(2000) := '';
  l_new_formula       VARCHAR2(20000) := '';
  l_select_stmt       VARCHAR2(20000) := '';
  l_component_value   NUMBER := NULL;
  i                   NUMBER;
  l_formula_value     NUMBER;
BEGIN
  FOR i IN 1..LENGTH(p_formula) LOOP
    l_char := SUBSTR(p_formula, i, 1);
    IF (l_char = '0') OR (l_char = '1') OR (l_char = '2') OR (l_char = '3') OR
       (l_char = '4') OR (l_char = '5') OR (l_char = '6') OR (l_char = '7') OR
       (l_char = '8') OR (l_char = '9')
    THEN
      --If retrieved character is a digit
      l_number := l_number || l_char;
      IF i = LENGTH(p_formula) THEN
        BEGIN
          l_component_value := p_operand_tbl(l_number);
        EXCEPTION
        WHEN OTHERS THEN
          l_component_value := null;
        END;
        l_new_formula := l_new_formula||'TO_NUMBER('''||TO_CHAR(l_component_value)||''')';
        l_number := '';
      END IF;
    ELSE -- If character is not a number
      IF l_number IS NOT NULL THEN
        -- Convert number to step_number and append the component value of
        -- that step_number to new_formula
        BEGIN
          l_component_value := p_operand_tbl(l_number);
        EXCEPTION
        WHEN OTHERS THEN
          l_component_value := null;
        END;
        l_new_formula := l_new_formula||'TO_NUMBER('''||TO_CHAR(l_component_value)||''')';
        l_number := '';
      END IF;
      l_new_formula := l_new_formula || l_char;
    END IF;  -- If the character is a number or not
  END LOOP; -- Loop through every character in the Formula String

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Formula is ' || l_new_formula);
  END IF;

  l_select_stmt := 'SELECT '|| l_new_formula || ' FROM DUAL';
  EXECUTE IMMEDIATE l_select_stmt INTO l_formula_value;
  RETURN l_formula_value;
END Select_From_Dual;


-------------------------------------------------------------------
/* The following is a function to calculate the value of a
   formula expression. This function combines the former 2 functions -
   Calculate and Component_Value into one function Calculate.
   This has been introduced as part of Performance Tuning for
   POSCO, post-1806928 (07/23/2001 and after) */
-------------------------------------------------------------------
FUNCTION Calculate (p_price_formula_id      IN  NUMBER,
                    p_list_price            IN  NUMBER,
                    p_price_effective_date  IN  DATE,
                    --p_req_line_attrs_tbl    IN  REQ_LINE_ATTRS_TBL,
                    p_line_index            IN  NUMBER,
                    p_list_line_type_code   IN  VARCHAR2,
                    --Added parameters p_line_index and p_list_line_type_code
                    --and commented out parameter p_req_line_attrs_tbl.
                    --POSCO performance related.
                    x_return_status         OUT NOCOPY VARCHAR2,
                    p_modifier_value        IN  NUMBER default NULL) --mkarya for bug 1906545
RETURN NUMBER
IS

/*
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.formula_lines_cur,QP_PRICE_FORMULA_LINES_U1,PRICE_FORMULA_ID,1
*/
CURSOR formula_lines_cur (a_price_formula_id  NUMBER)
IS
  SELECT step_number, price_formula_line_type_code, numeric_constant,
         pricing_attribute, pricing_attribute_context,
         price_formula_id, price_list_line_id
  FROM   qp_price_formula_lines
  WHERE  price_formula_id = a_price_formula_id;

--Modified factors_cur to incorporate search_ind for pricing_attributes.
--POSCO performance related.
/*
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PRICE_FORMULA_LINES_N1,PRICE_FORMULA_LINE_TYPE_CODE,1
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PRICE_FORMULA_LINES_N1,PRICE_FORMULA_ID,2
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_FACTOR_LIST_ATTRS_N1,LIST_HEADER_ID,1
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,PRICING_STATUS_CODE,1
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,ATTRIBUTE_TYPE,2
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,CONTEXT,3
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,ATTRIBUTE,4
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,LINE_INDEX,5
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PRICING_ATTRIBUTES_N8,LIST_HEADER_ID,1
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PRICING_ATTRIBUTES_N8,PRICING_ATTRIBUTE_CONTEXT,2
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PRICING_ATTRIBUTES_N8,PRICING_ATTRIBUTE,3
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PRICING_ATTRIBUTES_N8,SEARCH_IND,4
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_LIST_LINES_PK,LIST_LINE_ID,5
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PRICING_ATTRIBUTES_N8,PATTERN_VALUE_FROM_POSITIVE,6
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PRICING_ATTRIBUTES_N8,PATTERN_VALUE_TO_POSITIVE,7
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PRICING_ATTRIBUTES_N8,PATTERN_VALUE_FROM_NEGATIVE,8
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.factors_cur,QP_PRICING_ATTRIBUTES_N8,PATTERN_VALUE_TO_NEGATIVE,9
*/
CURSOR factors_cur (a_price_formula_id     NUMBER,
                    a_line_index           NUMBER,
                    a_price_effective_date DATE)
IS
  SELECT /*+ ORDERED index(a QP_PRICING_ATTRIBUTES_N8) index(t qp_preq_line_attrs_frml_tmp_n1) */ -- 9362867
         a.list_header_id, l.list_line_id, l.operand,
         l.start_date_active, l.end_date_active, l.group_count,
         fl.price_formula_id, fl.step_number
  FROM   qp_price_formula_lines fl, qp_factor_list_attrs fla,
         qp_preq_line_attrs_formula_tmp t, qp_pricing_attributes a,
         qp_list_lines l
  WHERE  t.context = a.pricing_attribute_context
  AND    t.attribute = a.pricing_attribute
  AND    fl.price_formula_line_type_code = 'ML'
  AND    t.line_index = a_line_index
  AND    t.attribute_type in ('PRICING','PRODUCT')
  AND    fl.price_formula_id = a_price_formula_id
  AND    t.pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
  AND    fla.list_header_id = fl.price_modifier_list_id
  AND    fla.pricing_attribute_context = t.context
  AND    fla.pricing_attribute =  t.attribute
  AND    a.list_header_id = fla.list_header_id
  AND    a.list_line_id = l.list_line_id
  AND    a.search_ind = 1
  AND    t.value_from between
            a.pattern_value_from_positive and a.pattern_value_to_positive
  AND    a_price_effective_date between                            --3520634 start
         nvl(l.start_date_active,a_price_effective_date) and
         nvl(l.end_date_active,a_price_effective_date)
  UNION  --separate sqls for positive and negative pattern_values for 3520634
  SELECT /*+ ORDERED index(a QP_PRICING_ATTRIBUTES_N10) index(t qp_preq_line_attrs_frml_tmp_n1) */ -- 9362867
         a.list_header_id, l.list_line_id, l.operand,
         l.start_date_active, l.end_date_active, l.group_count,
         fl.price_formula_id, fl.step_number
  FROM   qp_price_formula_lines fl, qp_factor_list_attrs fla,
         qp_preq_line_attrs_formula_tmp t, qp_pricing_attributes a,
         qp_list_lines l
  WHERE  t.context = a.pricing_attribute_context
  AND    t.attribute = a.pricing_attribute
  AND    fl.price_formula_line_type_code = 'ML'
  AND    t.line_index = a_line_index
  AND    t.attribute_type in ('PRICING','PRODUCT')
  AND    fl.price_formula_id = a_price_formula_id
  AND    t.pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
  AND    fla.list_header_id = fl.price_modifier_list_id
  AND    fla.pricing_attribute_context = t.context
  AND    fla.pricing_attribute =  t.attribute
  AND    a.list_header_id = fla.list_header_id
  AND    a.list_line_id = l.list_line_id
  AND    a.search_ind = 1
  AND    t.value_from between
            a.pattern_value_from_negative and a.pattern_value_to_negative
  AND    a_price_effective_date between
         nvl(l.start_date_active,a_price_effective_date) and
         nvl(l.end_date_active,a_price_effective_date)
  ORDER BY 8;  --3520634 end

--Introduced sub_factors_cur to incorporate search_ind for pricing_attributes.
--POSCO performance related.
/*
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_FACTOR_LIST_ATTRS_N1,LIST_HEADER_ID,1
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,PRICING_STATUS_CODE,1
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,ATTRIBUTE_TYPE,2
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,CONTEXT,3
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,ATTRIBUTE,4
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,LINE_INDEX,5
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PRICING_ATTRIBUTES_N8,LIST_HEADER_ID,1
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PRICING_ATTRIBUTES_N8,PRICING_ATTRIBUTE_CONTEXT,2
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PRICING_ATTRIBUTES_N8,PRICING_ATTRIBUTE,3
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PRICING_ATTRIBUTES_N8,SEARCH_IND,4
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PRICING_ATTRIBUTES_N8,LIST_LINE_ID,5
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PRICING_ATTRIBUTES_N8,PATTERN_VALUE_FROM_POSITIVE,6
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PRICING_ATTRIBUTES_N8,PATTERN_VALUE_TO_POSITIVE,7
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PRICING_ATTRIBUTES_N8,PATTERN_VALUE_FROM_NEGATIVE,8
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sub_factors_cur,QP_PRICING_ATTRIBUTES_N8,PATTERN_VALUE_TO_NEGATIVE,9
*/
CURSOR sub_factors_cur (a_price_formula_id     NUMBER,
                        a_line_index           NUMBER,
                        a_price_effective_date DATE,
                        a_list_header_id       NUMBER,
                        a_list_line_id         NUMBER,
                        a_group_count          NUMBER)
IS
  SELECT /*+  index(t QP_PREQ_LINE_ATTRS_FRML_TMP_N1) index(A QP_PRICING_ATTRIBUTES_N2) */ --Bug 7452538 Added index hints
     a.list_line_id     --Bug 8359591 Removing ordered hint
   -- /*+ ordered */ a.list_line_id     --5900728
  FROM   qp_factor_list_attrs fla,
         qp_preq_line_attrs_formula_tmp t, qp_pricing_attributes a
  WHERE  fla.list_header_id = a_list_header_id
  AND    fla.pricing_attribute_context = t.context
  AND    fla.pricing_attribute = t.attribute
  AND    t.context = a.pricing_attribute_context
  AND    t.attribute = a.pricing_attribute
  AND    t.line_index = a_line_index
  AND    t.attribute_type in ('PRICING','PRODUCT')
  AND    t.pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
  AND    a.list_header_id = fla.list_header_id
  AND    a.list_line_id = a_list_line_id
  AND    a.search_ind = 2
   AND(t.value_from BETWEEN a.pattern_value_from_positive
   AND a.pattern_value_to_positive OR t.value_from BETWEEN a.pattern_value_from_negative
   AND a.pattern_value_to_negative)
  GROUP BY a.list_line_id
  HAVING   count(*) = a_group_count;

-- 5900728
--  SELECT /*+ ORDERED index(a QP_PRICING_ATTRIBUTES_N8) */
--         a.list_line_id
--  FROM   qp_factor_list_attrs fla,
--         qp_preq_line_attrs_formula_tmp t, qp_pricing_attributes a
--  WHERE  fla.list_header_id = a_list_header_id
--  AND    fla.pricing_attribute_context = t.context
--  AND    fla.pricing_attribute = t.attribute
--  AND    t.context = a.pricing_attribute_context
--  AND    t.attribute = a.pricing_attribute
--  AND    t.line_index = a_line_index
--  AND    t.attribute_type in ('PRICING','PRODUCT')
--  AND    t.pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
--  AND    a.list_header_id = fla.list_header_id
--  AND    a.list_line_id = a_list_line_id
--  AND    a.search_ind = 2
--  AND    t.value_from between               --3520634 start
--          a.pattern_value_from_positive and a.pattern_value_to_positive
--  GROUP BY a.list_line_id
--  HAVING   count(*) = a_group_count
--UNION   ----separate sqls for positive and negative pattern_values for 3520634
--  SELECT /*+ ORDERED index(a QP_PRICING_ATTRIBUTES_N10) */
--         a.list_line_id
--  FROM   qp_factor_list_attrs fla,
--         qp_preq_line_attrs_formula_tmp t, qp_pricing_attributes a
--  WHERE  fla.list_header_id = a_list_header_id
--  AND    fla.pricing_attribute_context = t.context
--  AND    fla.pricing_attribute = t.attribute
--  AND    t.context = a.pricing_attribute_context
--  AND    t.attribute = a.pricing_attribute
--  AND    t.line_index = a_line_index
--  AND    t.attribute_type in ('PRICING','PRODUCT')
--  AND    t.pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED
--  AND    a.list_header_id = fla.list_header_id
--  AND    a.list_line_id = a_list_line_id
--  AND    a.search_ind = 2
--  AND    t.value_from between
--          a.pattern_value_from_negative and a.pattern_value_to_negative
--  GROUP BY a.list_line_id
--  HAVING   count(*) = a_group_count;  --3520634 end
/*
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.price_formulas_cur,QP_PRICE_FORMULAS_B_PK,PRICE_FORMULA_ID,1
*/
CURSOR price_formulas_cur (a_price_formula_id     NUMBER,
			   a_price_effective_date DATE)
IS
  SELECT formula
  FROM   qp_price_formulas_b
  WHERE  price_formula_id = a_price_formula_id
  AND    (start_date_active IS NULL OR
		start_date_active <= a_price_effective_date)
  AND    (end_date_active IS NULL   OR
		end_date_active >= a_price_effective_date);

--Introduced pra_cur to process formula_line_type of PRA using temp tables
--instead of earlier plsql tables. POSCO performance related.
/*
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.pra_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,PRICING_STATUS_CODE,1
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.pra_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,ATTRIBUTE_TYPE,2
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.pra_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,CONTEXT,3
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.pra_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,ATTRIBUTE,4
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.pra_cur,QP_PREQ_LINE_ATTRS_FRML_TMP_N1,LINE_INDEX,5
*/
CURSOR pra_cur(a_pricing_attribute_context VARCHAR2,
               a_pricing_attribute         VARCHAR2,
               a_line_index                NUMBER)
IS
  SELECT value_from
  FROM   qp_preq_line_attrs_formula_tmp
  WHERE  context = a_pricing_attribute_context
  AND    attribute = a_pricing_attribute
  AND    line_index = a_line_index
  AND    attribute_type in ('PRICING','PRODUCT')
  AND    pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED;

l_pra_rec            pra_cur%ROWTYPE;
l_attr_count         NUMBER := 0;
l_attr_flag          BOOLEAN := FALSE;
l_count              NUMBER := 0;
l_customized         VARCHAR2(1);

l_attribute_id       NUMBER := NULL;
l_start_date_active  date   := NULL;
l_end_date_active    date   := NULL;

l_formula       	VARCHAR2(2000) := '';
/* increased the length of l_formula,l_number and l_new_formula to 2000
   to fix the bug 1539041 */
l_formula_value     NUMBER;
l_no_of_comps       NUMBER := 0;
i                   NUMBER;
j                   NUMBER := 1;

--Added as part of POSCO changes
TYPE Formula_Line_Rec IS RECORD
     (step_number                    NUMBER,
      price_formula_line_type_code   VARCHAR2(10),
      component_value                NUMBER,
      price_formula_id               NUMBER,
      line_index                     NUMBER,
      list_line_type_code            VARCHAR2(30),--of the parent line
      list_header_id                 NUMBER, --populated for factor list steps
      list_line_id                   NUMBER  --populated with factor line id
      );

--Added as part of POSCO changes
TYPE Formula_Line_Tbl_Type IS TABLE OF Formula_Line_Rec INDEX BY BINARY_INTEGER;

--Added as part of POSCO changes
l_formula_line_tbl  Formula_Line_Tbl_Type;

l_req_line_attrs_tbl   QP_FORMULA_PRICE_CALC_PVT.REQ_LINE_ATTRS_TBL;

l_sub_factors_rec      sub_factors_cur%ROWTYPE;
l_old_step_number      NUMBER := -99999999999999;
l_skip_factor          BOOLEAN := FALSE;
l_return_status        VARCHAR2(1);

--Bug 2772214
l_pass_qualifiers varchar2(10) := FND_PROFILE.VALUE('QP_PASS_QUALIFIERS_TO_GET_CUSTOM');

/*
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.req_line_attrs_cur,qp_npreq_line_attrs_tmp_N7,LINE_INDEX,1
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.req_line_attrs_cur,qp_npreq_line_attrs_tmp_N7,ATTRIBUTE_TYPE,2
*/
CURSOR req_line_attrs_cur(a_line_index NUMBER)
IS
  SELECT line_index, attribute_type, context, attribute, value_from value
  --FROM   qp_npreq_line_attrs_tmp
  -- bug2425851
  FROM   qp_preq_line_attrs_formula_tmp
  WHERE  line_index = a_line_index
  AND    attribute_type IN ('PRICING','PRODUCT');

-- Bug 2772214, Added qual cursor
CURSOR req_line_attrs_qual_cur(a_line_index NUMBER)
IS
  SELECT line_index, attribute_type, context, attribute, value_from value
 FROM   qp_preq_line_attrs_formula_tmp
  WHERE  line_index = a_line_index
  AND    attribute_type IN ('PRICING','PRODUCT','QUALIFIER');


l_null_step_number_tbl  Step_Number_Tbl_Type;

 E_FORMULA_NOT_FOUND EXCEPTION;
 E_INVALID_FORMULA EXCEPTION;
 E_FORMULA_COMPONENTS_REQ EXCEPTION;
 E_CUSTOMIZE_GET_CUSTOM_PRICE EXCEPTION;
 E_INVALID_NUMBER EXCEPTION;

l_Operand_Tbl          QP_FORMULA_RULES_PVT.t_Operand_Tbl_Type;

l_formula_start_time NUMBER;
l_formula_end_time   NUMBER;
l_time_difference    NUMBER;
l_formula_name       qp_price_formulas_tl.name%TYPE;

BEGIN

  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  l_formula_start_time := dbms_utility.get_time;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('Start Formula...');
  END IF;

  --added for formula messages
   SELECT name
     INTO l_formula_name
     FROM qp_price_formulas_tl
    WHERE price_formula_id = p_price_formula_id
     AND rownum<2;

  OPEN price_formulas_cur (p_price_formula_id, p_price_effective_date);

  FETCH price_formulas_cur INTO l_formula;

  IF price_formulas_cur%NOTFOUND THEN

           x_return_status := FND_API.G_RET_STS_ERROR;

           IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               RAISE E_FORMULA_NOT_FOUND;
--             FND_MSG_PUB.Add;
           END IF;

  END IF;

  CLOSE price_formulas_cur;

  Parse_Formula (l_formula, l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    x_return_status := l_return_status;
    RAISE E_INVALID_FORMULA;
  END IF;

  --Get the no_of_components in the formula
/*
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sel1,QP_PRICE_FORMULA_LINES_U1,PRICE_FORMULA_ID,1
*/
  SELECT count(*)
  INTO   l_no_of_comps
  FROM   qp_price_formula_lines
  WHERE  price_formula_id = p_price_formula_id;

  IF l_no_of_comps = 0 THEN

         x_return_status := FND_API.G_RET_STS_ERROR;

         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
             RAISE E_FORMULA_COMPONENTS_REQ;
--           FND_MSG_PUB.Add;
         END IF;

  END IF;
--Change flexible mask to mask below for formula pattern use (Bug2195879)
qp_number.canonical_mask :=
              '00999999999999999999999.99999999999999999999999999999999999999';
  --Begin more POSCO changes.
  FOR l_rec IN formula_lines_cur(p_price_formula_id)
  LOOP

    IF l_rec.price_formula_line_type_code = 'NUM' THEN

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Formula Line Type = NUM, Step = '|| l_rec.step_number
                        || ', Value = ' || l_rec.numeric_constant);
      END IF;
      l_formula_line_tbl(l_rec.step_number).component_value :=
                                   l_rec.numeric_constant;

      l_Operand_Tbl(l_rec.step_number) := l_formula_line_tbl(l_rec.step_number).component_value;

      l_formula_line_tbl(l_rec.step_number).step_number := l_rec.step_number;
      l_formula_line_tbl(l_rec.step_number).price_formula_line_type_code :=
                                   l_rec.price_formula_line_type_code;
      l_formula_line_tbl(l_rec.step_number).price_formula_id :=
                                   l_rec.price_formula_id;
      l_formula_line_tbl(l_rec.step_number).line_index := p_line_index;
      l_formula_line_tbl(l_rec.step_number).list_header_id := null;
      l_formula_line_tbl(l_rec.step_number).list_line_id := null;
      l_formula_line_tbl(l_rec.step_number).list_line_type_code :=
                                   p_list_line_type_code;

    ELSIF l_rec.price_formula_line_type_code = 'LP' THEN

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Formula Line Type = LP, Step = ' || l_rec.step_number
                        || ', Value = '|| p_list_price);
      END IF;
      l_formula_line_tbl(l_rec.step_number).component_value := p_list_price;

      l_Operand_Tbl(l_rec.step_number) := l_formula_line_tbl(l_rec.step_number).component_value;

      l_formula_line_tbl(l_rec.step_number).step_number := l_rec.step_number;
      l_formula_line_tbl(l_rec.step_number).price_formula_line_type_code :=
                                   l_rec.price_formula_line_type_code;
      l_formula_line_tbl(l_rec.step_number).price_formula_id :=
                                   l_rec.price_formula_id;
      l_formula_line_tbl(l_rec.step_number).line_index := p_line_index;
      l_formula_line_tbl(l_rec.step_number).list_header_id := null;
      l_formula_line_tbl(l_rec.step_number).list_line_id := null;
      l_formula_line_tbl(l_rec.step_number).list_line_type_code :=
                                   p_list_line_type_code;
      --added for formula messages
      IF p_list_price IS NULL THEN
         l_null_step_number_tbl(l_rec.step_number):= l_rec.step_number;
      END IF;

    ELSIF l_rec.price_formula_line_type_code = 'MV' THEN

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Formula Line Type = MV, Step = ' || l_rec.step_number || ', Value = '|| p_modifier_value);

      END IF;
      l_formula_line_tbl(l_rec.step_number).component_value := p_modifier_value;

      l_Operand_Tbl(l_rec.step_number) := l_formula_line_tbl(l_rec.step_number).component_value;

      l_formula_line_tbl(l_rec.step_number).step_number := l_rec.step_number;
      l_formula_line_tbl(l_rec.step_number).price_formula_line_type_code :=
                                   l_rec.price_formula_line_type_code;
      l_formula_line_tbl(l_rec.step_number).price_formula_id :=
                                   l_rec.price_formula_id;
      l_formula_line_tbl(l_rec.step_number).line_index := p_line_index;
      l_formula_line_tbl(l_rec.step_number).list_header_id := null;
      l_formula_line_tbl(l_rec.step_number).list_line_id := null;
      l_formula_line_tbl(l_rec.step_number).list_line_type_code :=
                                   p_list_line_type_code;
      --added for formula messages
      IF p_modifier_value IS NULL
      THEN
          l_null_step_number_tbl(l_rec.step_number) := l_rec.step_number;
      END IF;

    ELSIF l_rec.price_formula_line_type_code = 'FUNC' THEN

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Formula Line Type = FUNC, Step = ' ||l_rec.step_number);
      END IF;
      l_customized := FND_PROFILE.VALUE('QP_GET_CUSTOM_PRICE_CUSTOMIZED');
      IF l_customized = 'Y' THEN
        IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('l_customized is Y');

        END IF;
        --Populate l_req_line_attrs_tbl
        -- Bug 2772214, Added If condition
       If nvl(l_pass_qualifiers, 'N') = 'N' Then
        FOR l_line_attrs_rec IN req_line_attrs_cur(p_line_index)
        LOOP
          l_req_line_attrs_tbl(j) := l_line_attrs_rec;
          j := j + 1;
        END LOOP;
       Else
        FOR l_line_attrs_rec IN req_line_attrs_qual_cur(p_line_index)
         LOOP
          l_req_line_attrs_tbl(j) := l_line_attrs_rec;
          j := j + 1;
        END LOOP;
       End If;

        --added for formula enhancement by dhgupta 3531890
        l_req_line_attrs_tbl(j).line_index:=p_line_index;
        l_req_line_attrs_tbl(j).attribute_type:=QP_GLOBALS.G_SPECIAL_ATTRIBUTE_TYPE;
        l_req_line_attrs_tbl(j).context:=QP_GLOBALS.G_SPECIAL_CONTEXT;
        l_req_line_attrs_tbl(j).attribute:=QP_GLOBALS.G_SPECIAL_ATTRIBUTE1;
        l_req_line_attrs_tbl(j).value:=l_rec.step_number;
        -- end 3531890

        BEGIN
	qp_debug_util.tstart('GET_CUSTOM_PRICE','Calculating the custom price in Formulas');
        l_formula_line_tbl(l_rec.step_number).component_value :=
                             QP_Custom.Get_Custom_Price(p_price_formula_id,
                                                        p_list_price,
                                                        p_price_effective_date,
                                                        l_req_line_attrs_tbl);
	qp_debug_util.tstop('GET_CUSTOM_PRICE');
        l_Operand_Tbl(l_rec.step_number) := l_formula_line_tbl(l_rec.step_number).component_value;

        l_formula_line_tbl(l_rec.step_number).step_number := l_rec.step_number;
        l_formula_line_tbl(l_rec.step_number).price_formula_line_type_code :=
                                       l_rec.price_formula_line_type_code;
        l_formula_line_tbl(l_rec.step_number).price_formula_id :=
                                       l_rec.price_formula_id;
        l_formula_line_tbl(l_rec.step_number).line_index := p_line_index;
        l_formula_line_tbl(l_rec.step_number).list_header_id := null;
        l_formula_line_tbl(l_rec.step_number).list_line_id := null;
        l_formula_line_tbl(l_rec.step_number).list_line_type_code :=
                                       p_list_line_type_code;

        IF l_formula_line_tbl(l_rec.step_number).component_value  IS NULL
        THEN
            l_null_step_number_tbl(l_rec.step_number) := l_rec.step_number;
        END IF;
        EXCEPTION
         WHEN OTHERS THEN
            l_null_step_number_tbl(l_rec.step_number) := l_rec.step_number;
        END;

      ELSE --If customized = 'N'
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
          RAISE E_CUSTOMIZE_GET_CUSTOM_PRICE;
        END IF;
      END IF;

    ELSIF l_rec.price_formula_line_type_code = 'PRA' THEN

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Formula Line Type = PRA, Step = ' ||l_rec.step_number);

      END IF;
      OPEN  pra_cur(l_rec.pricing_attribute_context, l_rec.pricing_attribute,
                    p_line_index);
      FETCH pra_cur INTO l_pra_rec;

      IF pra_cur%FOUND THEN
        --Return the matching pricing attribute value that is found.
        BEGIN
-- bug 2195879
IF l_debug = FND_API.G_TRUE THEN
QP_PREQ_GRP.engine_debug('l_pra_rec.value_from = '||l_pra_rec.value_from);
END IF;
          l_formula_line_tbl(l_rec.step_number).component_value :=
                qp_number.canonical_to_number(l_pra_rec.value_from);

          l_Operand_Tbl(l_rec.step_number) := l_formula_line_tbl(l_rec.step_number).component_value;

IF l_debug = FND_API.G_TRUE THEN
QP_PREQ_GRP.engine_debug('Just after pra cur value from to number conversion');
END IF;
        EXCEPTION
          WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug('Error converting PRA value to number');
            END IF;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
              RAISE E_INVALID_NUMBER;
            END IF;
        END; -- for Begin block

      ELSE  --If pra_cur%NOTFOUND
        l_formula_line_tbl(l_rec.step_number).component_value := NULL;

        l_Operand_Tbl(l_rec.step_number) := l_formula_line_tbl(l_rec.step_number).component_value;
        l_null_step_number_tbl(l_rec.step_number) := l_rec.step_number;

      END IF; --If pra_cur%FOUND

      CLOSE pra_cur;

      l_formula_line_tbl(l_rec.step_number).step_number := l_rec.step_number;
      l_formula_line_tbl(l_rec.step_number).price_formula_line_type_code :=
                                       l_rec.price_formula_line_type_code;
      l_formula_line_tbl(l_rec.step_number).price_formula_id :=
                                       l_rec.price_formula_id;
      l_formula_line_tbl(l_rec.step_number).line_index := p_line_index;
      l_formula_line_tbl(l_rec.step_number).list_header_id := null;
      l_formula_line_tbl(l_rec.step_number).list_line_id := null;
      l_formula_line_tbl(l_rec.step_number).list_line_type_code :=
                                       p_list_line_type_code;

    ELSIF l_rec.price_formula_line_type_code = 'PLL' THEN

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Formula Line Type = PLL, Step = ' ||l_rec.step_number);
      END IF;
/*
INDX,QP_FORMULA_PRICE_CALC_PVT.calculate.sel2,QP_LIST_LINES_PK,LIST_LINE_ID,1
*/
      BEGIN
        SELECT operand
        INTO   l_formula_line_tbl(l_rec.step_number).component_value
        FROM   qp_list_lines
        WHERE  list_line_id = l_rec.price_list_line_id;

        l_Operand_Tbl(l_rec.step_number) := l_formula_line_tbl(l_rec.step_number).component_value;

      EXCEPTION
        WHEN OTHERS THEN
          l_formula_line_tbl(l_rec.step_number).component_value :=  NULL;

          l_Operand_Tbl(l_rec.step_number) := l_formula_line_tbl(l_rec.step_number).component_value;
          l_null_step_number_tbl(l_rec.step_number) := l_rec.step_number;
      END;

      l_formula_line_tbl(l_rec.step_number).step_number := l_rec.step_number;
      l_formula_line_tbl(l_rec.step_number).price_formula_line_type_code :=
                                       l_rec.price_formula_line_type_code;
      l_formula_line_tbl(l_rec.step_number).price_formula_id :=
                                       l_rec.price_formula_id;
      l_formula_line_tbl(l_rec.step_number).line_index := p_line_index;
      l_formula_line_tbl(l_rec.step_number).list_header_id := null;
      l_formula_line_tbl(l_rec.step_number).list_line_id := null;
      l_formula_line_tbl(l_rec.step_number).list_line_type_code :=
                                       p_list_line_type_code;

    ELSIF l_rec.price_formula_line_type_code = 'ML' THEN

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Formula Line Type = ML, Step = ' ||l_rec.step_number);
      END IF;
      --null; --Do nothing here. All factor lists will be processed together later
      l_Operand_Tbl(l_rec.step_number) :=null;----6726052,7249280 smbalara
      --added for formula messages
      l_null_step_number_tbl(l_rec.step_number) := l_rec.step_number;
    ELSE --if price_formula_line_type_code is not one of the expected values.

      x_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        FND_MESSAGE.SET_NAME('QP','QP_INVALID_FORMULA_LINE_TYPE');
      END IF;

    END IF; -- IF stmt comparing price_formula_line_type_code to various values.
        l_req_line_attrs_tbl.delete; --3531890 attribute were getting accumulated for every step
-- smbalara bug 7188211
--Based on a profile option,formula step values will be inserted into qp_nformula_step_values_tmp
IF QP_PREQ_GRP.G_INSERT_FORMULA_STEP_VALUES = 'Y' THEN
	IF l_debug = FND_API.G_TRUE THEN
	QP_PREQ_GRP.engine_debug('Before populating formula stepvalues temp table');
	QP_PREQ_GRP.engine_debug('Value 1='||l_formula_line_tbl(l_rec.step_number).price_formula_id );
	QP_PREQ_GRP.engine_debug('Value 2='||l_formula_line_tbl(l_rec.step_number).step_number );
	QP_PREQ_GRP.engine_debug('Value 3='||l_formula_line_tbl(l_rec.step_number).component_value );
	QP_PREQ_GRP.engine_debug('Value 4='||l_formula_line_tbl(l_rec.step_number).price_formula_line_type_code );
	QP_PREQ_GRP.engine_debug('Value 5='||l_formula_line_tbl(l_rec.step_number).line_index );
	QP_PREQ_GRP.engine_debug('Value 6='||l_formula_line_tbl(l_rec.step_number).list_line_type_code );
	QP_PREQ_GRP.engine_debug('Value 7='||l_formula_line_tbl(l_rec.step_number).list_header_id );
	QP_PREQ_GRP.engine_debug('Value 8='||l_formula_line_tbl(l_rec.step_number).list_line_id );
	END IF;

          INSERT INTO qp_nformula_step_values_tmp
          (price_formula_id,
           step_number,
           component_value,
           price_formula_line_type_code,
           line_index,
           list_line_type_code,
           list_header_id,
           list_line_id
          )
          VALUES
          (l_formula_line_tbl(l_rec.step_number).price_formula_id,
           l_formula_line_tbl(l_rec.step_number).step_number,
           l_formula_line_tbl(l_rec.step_number).component_value,
           l_formula_line_tbl(l_rec.step_number).price_formula_line_type_code,
           l_formula_line_tbl(l_rec.step_number).line_index,
           l_formula_line_tbl(l_rec.step_number).list_line_type_code,
           l_formula_line_tbl(l_rec.step_number).list_header_id,
           l_formula_line_tbl(l_rec.step_number).list_line_id
          );
	IF l_debug = FND_API.G_TRUE THEN
		QP_PREQ_GRP.engine_debug('After populating formula step values temp table');
	END IF;
END IF;
-- smbalara bug 7188211
END LOOP; --Loop over formula_lines_cur
-- Change mask back to flexible mask
qp_number.canonical_mask :=
              'FM999999999999999999999.9999999999999999999999999999999999999999';

  -- Now Process all Factor Lists in the formula

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('Before populating plsql table of formula lines');

  END IF;
  --Populate l_formula_line_tbl for all factor lists in the formula
  FOR l_factors_rec IN factors_cur (p_price_formula_id, p_line_index,
                                    p_price_effective_date)
  LOOP

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('enter factors_cur loop');

    END IF;
    IF l_skip_factor AND
       l_factors_rec.step_number = l_old_step_number
    THEN
      l_old_step_number := l_factors_rec.step_number;
      GOTO factors_loop;
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('after skip check ');

    END IF;
    l_skip_factor := FALSE;

    --If no attributes with search_ind = 2 then no need to open sub_factors_cur
    IF l_factors_rec.group_count = 0 THEN

      l_formula_line_tbl(l_factors_rec.step_number).component_value :=
                                     l_factors_rec.operand;

      l_Operand_Tbl(l_factors_rec.step_number) := l_formula_line_tbl(l_factors_rec.step_number).component_value;

      l_formula_line_tbl(l_factors_rec.step_number).step_number :=
                                     l_factors_rec.step_number;
      l_formula_line_tbl(l_factors_rec.step_number).price_formula_line_type_code
                                  := 'ML';
      l_formula_line_tbl(l_factors_rec.step_number).price_formula_id :=
                                     l_factors_rec.price_formula_id;
      l_formula_line_tbl(l_factors_rec.step_number).line_index :=
                                     p_line_index;
      l_formula_line_tbl(l_factors_rec.step_number).list_header_id :=
                                     l_factors_rec.list_header_id;
      l_formula_line_tbl(l_factors_rec.step_number).list_line_id :=
                                     l_factors_rec.list_line_id;
      l_formula_line_tbl(l_factors_rec.step_number).list_line_type_code :=
                                     p_list_line_type_code;

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('In factors_cur, step = ' ||l_factors_rec.step_number);

      END IF;
      l_skip_factor := TRUE;

      --added for formula messages
      l_null_step_number_tbl.DELETE(l_factors_rec.step_number);

    ELSE --If l_factors_rec.group_count > 0
      --sub_factors_cur has to be fetched to determine if all attributes match
      OPEN sub_factors_cur(p_price_formula_id,
                           p_line_index,
                           p_price_effective_date,
                           l_factors_rec.list_header_id,
                           l_factors_rec.list_line_id,
                           l_factors_rec.group_count);
      FETCH sub_factors_cur
      INTO  l_sub_factors_rec;

      IF sub_factors_cur%FOUND THEN

        l_formula_line_tbl(l_factors_rec.step_number).component_value :=
                                     l_factors_rec.operand;

        l_Operand_Tbl(l_factors_rec.step_number) := l_formula_line_tbl(l_factors_rec.step_number).component_value;

        l_formula_line_tbl(l_factors_rec.step_number).step_number :=
                                     l_factors_rec.step_number;
        l_formula_line_tbl(l_factors_rec.step_number).price_formula_line_type_code
                                  := 'ML';
        l_formula_line_tbl(l_factors_rec.step_number).price_formula_id :=
                                     l_factors_rec.price_formula_id;
        l_formula_line_tbl(l_factors_rec.step_number).line_index :=
                                     p_line_index;
        l_formula_line_tbl(l_factors_rec.step_number).list_header_id :=
                                     l_factors_rec.list_header_id;
        l_formula_line_tbl(l_factors_rec.step_number).list_line_id :=
                                     l_factors_rec.list_line_id;
        l_formula_line_tbl(l_factors_rec.step_number).list_line_type_code :=
                                     p_list_line_type_code;

        IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('In sub_factors_cur, step = ' ||l_factors_rec.step_number);

        END IF;
        l_skip_factor := TRUE;

        l_null_step_number_tbl.DELETE(l_factors_rec.step_number);
      END IF;--sub_factors_cur%FOUND

      CLOSE sub_factors_cur;

    END IF; --If l_factors_rec.group_count = 0

    l_old_step_number := l_factors_rec.step_number;

    <<factors_loop>>
    null;

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('exit factors_cur loop');

    END IF;
  END LOOP; --Loop over factors_cur

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('After populating plsql table of formula lines');

  END IF;
  --Based on a profile option, loop over plsql table of formula lines to
  --populate qp_nformula_step_values_tmp table
/* commented for bug 7188211 - temp table insert moved above
  IF QP_PREQ_GRP.G_INSERT_FORMULA_STEP_VALUES = 'Y' THEN

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Before populating formula stepvalues temp table');

    END IF;
    i:= l_formula_line_tbl.FIRST; --set loop index to first element in plsql tbl

    WHILE i IS NOT NULL
    LOOP
      BEGIN

        --Insert into temp table only for formulas attached to Price List Lines.
        IF l_formula_line_tbl(i).list_line_type_code = 'PLL'
        THEN

          INSERT INTO qp_nformula_step_values_tmp
          (price_formula_id,
           step_number,
           component_value,
           price_formula_line_type_code,
           line_index,
           list_line_type_code,
           list_header_id,
           list_line_id
          )
          VALUES
          (l_formula_line_tbl(i).price_formula_id,
           l_formula_line_tbl(i).step_number,
           l_formula_line_tbl(i).component_value,
           l_formula_line_tbl(i).price_formula_line_type_code,
           l_formula_line_tbl(i).line_index,
           l_formula_line_tbl(i).list_line_type_code,
           l_formula_line_tbl(i).list_header_id,
           l_formula_line_tbl(i).list_line_id
          );

        END IF; --If list_line_type_code = 'PLL'

      EXCEPTION
        WHEN OTHERS THEN
         IF l_debug = FND_API.G_TRUE THEN
         QP_PREQ_GRP.engine_debug(substr(sqlerrm, 1, 240));
         END IF;
      END;

      i :=  l_formula_line_tbl.NEXT(i);--set i to next notnull position in plsql

    END LOOP; --loop over l_formula_line_tbl

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('After populating formula step values temp table');

    END IF;
  END IF; --If profile option is set
commented for bug 7188211*/
  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('Before Calling - QP_BUILD_FORMULA_RULES.Get_Formula_Values');
  QP_PREQ_GRP.engine_debug('For Formula : '||l_formula);----6726052,7249280 smbalara
  END IF;
  QP_BUILD_FORMULA_RULES.Get_Formula_Values(l_formula,
                                            l_Operand_Tbl,
                                            'G',               --sfiresto
                                            l_formula_value,
                                            l_return_status);

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('After Calling - QP_BUILD_FORMULA_RULES.Get_Formula_Values');

  QP_PREQ_GRP.engine_debug('Return Status from Get_Formula_Values ' || l_return_status);

  END IF;
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) OR (l_formula_value IS NULL) THEN
    l_formula_value := Select_From_Dual(l_formula, l_operand_tbl);

    IF l_formula_value IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        Set_Message( p_price_formula_id     => p_price_formula_id,
                   p_formula_name         => l_formula_name,
                   p_null_step_number_tbl => l_null_step_number_tbl);
        l_null_step_number_tbl.DELETE;
      END IF;
    END IF;

  END IF;

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('Formula evaluated to ' || l_formula_value);

  QP_PREQ_GRP.engine_debug('Formula Return Status ' || l_return_status);

  END IF;
  l_formula_line_tbl.DELETE; --Clear the temp table table

  l_formula_end_time := dbms_utility.get_time;
  l_time_difference := (l_formula_end_time - l_formula_start_time)/100 ;

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('##### Total Time in QP_FORMULA_PRICE_CALC_PVT(in sec) : ' || l_time_difference || ' #####');

  END IF;
  RETURN l_formula_value;
  --End more POSCO changes.

EXCEPTION

WHEN E_FORMULA_NOT_FOUND THEN
x_return_status := FND_API.G_RET_STS_ERROR;
fnd_message.set_name('QP','QP_FORMULA_NOT_FOUND');
fnd_message.set_token('FORMULA_NAME',l_formula_name);
-- Change mask back to flexible mask
qp_number.canonical_mask := 'FM999999999999999999999.9999999999999999999999999999999999999999';
RETURN l_formula_value;

WHEN E_INVALID_FORMULA THEN
x_return_status := FND_API.G_RET_STS_ERROR;
fnd_message.set_name('QP','QP_INVALID_FORMULA');
fnd_message.set_token('FORMULA_NAME',l_formula_name);
-- Change mask back to flexible mask
qp_number.canonical_mask := 'FM999999999999999999999.9999999999999999999999999999999999999999';
RETURN l_formula_value;

WHEN  E_FORMULA_COMPONENTS_REQ THEN
x_return_status := FND_API.G_RET_STS_ERROR;
fnd_message.set_name('QP','QP_FORMULA_COMPONENTS_REQ');
fnd_message.set_token('FORMULA_NAME',l_formula_name);
-- Change mask back to flexible mask
qp_number.canonical_mask := 'FM999999999999999999999.9999999999999999999999999999999999999999';
RETURN l_formula_value;

WHEN  E_CUSTOMIZE_GET_CUSTOM_PRICE THEN
x_return_status := FND_API.G_RET_STS_ERROR;
fnd_message.set_name('QP','QP_CUSTOMIZE_GET_CUSTOM_PRICE');
fnd_message.set_token('FORMULA_NAME',l_formula_name);
-- Change mask back to flexible mask
qp_number.canonical_mask := 'FM999999999999999999999.9999999999999999999999999999999999999999';
RETURN l_formula_value;

WHEN  E_INVALID_NUMBER THEN
x_return_status := FND_API.G_RET_STS_ERROR;
fnd_message.set_name('QP','QP_INVALID_NUMBER');
fnd_message.set_token('FORMULA_NAME',l_formula_name);
-- Change mask back to flexible mask
qp_number.canonical_mask := 'FM999999999999999999999.9999999999999999999999999999999999999999';
RETURN l_formula_value;

    WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
        FND_MESSAGE.SET_NAME('QP','QP_FORMULA_FAILED');
      END IF;
      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Exception '||substr(sqlerrm, 1, 240));
      QP_PREQ_GRP.engine_debug('Exception occurred. Formula value returned is ' ||
                       l_formula_value);
      END IF;

      l_formula_line_tbl.DELETE; --Clear the temp table table

      -- Change mask back to flexible mask
      qp_number.canonical_mask := 'FM999999999999999999999.9999999999999999999999999999999999999999';

      RETURN l_formula_value;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Unexpected Exception '||substr(sqlerrm, 1, 240));
      QP_PREQ_GRP.engine_debug('Exception occurred. Formula value returned is ' ||
                       l_formula_value);

      END IF;
      l_formula_line_tbl.DELETE; --Clear the temp table table

      -- Change mask back to flexible mask
      qp_number.canonical_mask := 'FM999999999999999999999.9999999999999999999999999999999999999999';

      RETURN l_formula_value;

    WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                'Calculate:'||sqlerrm);
      END IF;

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Other Exception '||substr(sqlerrm, 1, 240));
      QP_PREQ_GRP.engine_debug('Exception occurred. Formula value returned is ' ||
                         l_formula_value);

      END IF;
      l_formula_line_tbl.DELETE; --Clear the temp table table

      -- Change mask back to flexible mask
      qp_number.canonical_mask := 'FM999999999999999999999.9999999999999999999999999999999999999999';

      RETURN l_formula_value;

END Calculate;

PROCEDURE Set_Message(p_price_formula_id     IN NUMBER,
                      p_formula_name         IN VARCHAR2,
                      p_null_step_number_tbl IN STEP_NUMBER_TBL_TYPE)

IS

l_price_formula_line_type_code qp_price_formula_lines.price_formula_line_type_code%TYPE;
l_pricing_attribute_context    qp_price_formula_lines.pricing_attribute_context%TYPE;
l_pricing_attribute            qp_price_formula_lines.pricing_attribute%TYPE;
l_all_steps                    VARCHAR2(100);
l_formula_name                 qp_price_formulas_tl.name%TYPE;
l_index                        NUMBER;
l_attribute                    VARCHAR2(80);
--added for display of right message in case of undefined step.
--can be removed once validation is done in formula form.
l_no_of_comps                  NUMBER;
l_formula                      VARCHAR2(2000);
l_count                        NUMBER :=0;
l_char                         VARCHAR2(1) :='';
l_number                       VARCHAR2(2000) :='';

BEGIN

   l_formula_name := p_formula_name;
   --added for display of right message in case of undefined step
   -- query on formula ID instead of name, SQL repos
   SELECT formula into l_formula from qp_price_formulas_b
   WHERE price_formula_id = p_price_formula_id;

  SELECT count(*) into l_no_of_comps from qp_price_formula_lines
   WHERE price_formula_id = p_price_formula_id;

  FOR i IN 1..LENGTH(l_formula) LOOP
    l_char :=SUBSTR(l_formula,i,1);
   IF (l_char = '0') OR (l_char = '1') OR (l_char = '2') OR (l_char = '3')
       OR (l_char = '4') OR (l_char = '5') OR (l_char ='6')
       OR (l_char = '7') OR (l_char = '8') OR (l_char = '9')
   THEN
      l_number :=l_number ||l_char;
       IF (i = LENGTH(l_formula))
        THEN
          l_count :=l_count+1;
          l_number :='';
       END IF;
   ELSE
     IF l_number is NOT NULL
       THEN
         l_count :=l_count+1;
         l_number :='';
     END IF;
   END IF;
 END LOOP;
--added for display of right message in case of undefined step
   IF p_null_step_number_tbl.COUNT = 1 AND l_count = l_no_of_comps
   THEN
     l_index := p_null_step_number_tbl.FIRST;
     SELECT price_formula_line_type_code,
            pricing_attribute_context,
            pricing_attribute
       INTO l_price_formula_line_type_code,
            l_pricing_attribute_context,
            l_pricing_attribute
       FROM qp_price_formula_lines
      WHERE price_formula_id = p_price_formula_id
        AND step_number = l_index;

      IF     l_price_formula_line_type_code = 'LP'
      THEN
         fnd_message.set_name('QP','QP_FORMULA_LIST_PRICE_NULL');

      ELSIF  l_price_formula_line_type_code = 'MV'
      THEN
         fnd_message.set_name('QP','QP_FORMULA_MODIFIER_VALUE_NULL');

      ELSIF  l_price_formula_line_type_code = 'FUNC'
      THEN
         fnd_message.set_name('QP','QP_FORMULA_GET_CUSTOM_PRICE');

      ELSIF  l_price_formula_line_type_code = 'PRA'
      THEN
         SELECT     nvl(SEGMENTS_TL.SEEDED_SEGMENT_NAME,SEGMENTS_TL.USER_SEGMENT_NAME)
         INTO  l_attribute
 	 FROM  qp_segments_b SEGMENTS, qp_prc_contexts_b PCONTEXTS , qp_segments_tl SEGMENTS_TL
		WHERE pcontexts.prc_context_code       =  l_pricing_attribute_context
		AND   segments.segment_mapping_column  =  l_pricing_attribute
		AND   segments.prc_context_id          =  pcontexts.prc_context_id
		AND   segments.segment_id              =  segments_tl.segment_id
                AND   rownum<2;

         fnd_message.set_name('QP','QP_PRICING_ATTRIBUTE_NULL');
         fnd_message.set_token('CONTEXT',l_pricing_attribute_context);
         fnd_message.set_token('ATTRIBUTE',l_attribute);

      ELSIF  l_price_formula_line_type_code = 'PLL'
      THEN
         fnd_message.set_name('QP','QP_PRICE_LIST_LINE_NOT_EXISTS');

      ELSIF  l_price_formula_line_type_code = 'ML'
      THEN
         fnd_message.set_name('QP','QP_FACTOR_LIST_NULL');
      END IF;
      fnd_message.set_token('STEP_NUMBER',l_index);

   ELSIF p_null_step_number_tbl.COUNT>1 AND l_count = l_no_of_comps
   THEN                                        -- more than one step nulling out
      l_index := p_null_step_number_tbl.FIRST;
      WHILE l_index IS NOT NULL
      LOOP
         IF l_index = p_null_step_number_tbl.LAST
         THEN
            l_all_steps := l_all_steps || p_null_step_number_tbl(l_index);
         ELSE
            l_all_steps := l_all_steps || p_null_step_number_tbl(l_index) || ', ';
         END IF;
         l_index := p_null_step_number_tbl.NEXT(l_index);
      END LOOP;
         fnd_message.set_name('QP','QP_NULL_STEP_NUMBER');
         fnd_message.set_token('STEP_NUMBERS',l_all_steps);
   ELSE
         fnd_message.set_name('QP','QP_STEP_NO_UNDEFINED');
   END IF;
   fnd_message.set_token('FORMULA_NAME',l_formula_name);
END Set_Message;


-----------------------------------------------------------------------
-- Wrapper for QP_Build_Formula_Rules.Get_Formula_Values called by Java
-- Formula Engine.  The JDBC call will pass in a serialized string of
-- operands, which this procedure deserializes into a PL/SQL table to
-- pass to Get_Formula_Values
-----------------------------------------------------------------------
PROCEDURE Java_Get_Formula_Values(p_formula          IN VARCHAR2,
                                  p_operands_str     IN VARCHAR2,
                                  p_procedure_type   IN VARCHAR2,
                                  x_formula_value    OUT NOCOPY NUMBER,
                                  x_return_status    OUT NOCOPY VARCHAR2)
IS
  head NUMBER;
  tail NUMBER;
  l_step_num NUMBER;
  l_operand_tbl QP_FORMULA_RULES_PVT.t_Operand_Tbl_Type;
BEGIN
  -- parse the operands string into a table
  -- first read in step number, followed by step values
  -- head and tail indicate start and end positions of search in the string
  head := 0;
  tail := instr(p_operands_str, '|', head+1);
  WHILE tail <> 0
  LOOP
    l_step_num := substr(p_operands_str, head+1, tail-head-1); -- step number
    head := tail;
    tail := instr(p_operands_str, '|', head+1);
    l_operand_tbl(l_step_num) := substr(p_operands_str, head+1, tail-head-1);
    head := tail;
    tail := instr(p_operands_str, '|', head+1);
  END LOOP;

  QP_Build_Formula_Rules.Get_Formula_Values(p_formula, l_operand_tbl, p_procedure_type,
                                            x_formula_value, x_return_status);

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) OR (x_formula_value IS NULL) THEN
    x_formula_value := Select_From_Dual(p_formula, l_operand_tbl);

    IF x_formula_value IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;
  END IF;
END Java_Get_Formula_Values;

END QP_FORMULA_PRICE_CALC_PVT;

/
