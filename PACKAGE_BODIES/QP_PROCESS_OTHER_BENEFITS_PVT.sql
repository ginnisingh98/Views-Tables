--------------------------------------------------------
--  DDL for Package Body QP_PROCESS_OTHER_BENEFITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PROCESS_OTHER_BENEFITS_PVT" AS
/* $Header: QPXVOTHB.pls 120.5.12010000.2 2008/08/18 06:56:55 smuhamme ship $ */
  l_debug VARCHAR2(3);
  PROCEDURE Calculate_Recurring_Quantity(p_list_line_id     	 NUMBER,
                                         p_list_header_id        NUMBER,
                                         p_line_index            NUMBER,
                                         p_benefit_line_id    	 NUMBER,
                                         x_benefit_line_qty   OUT NOCOPY NUMBER,
                                         x_return_status      OUT NOCOPY VARCHAR2,
                                         x_return_status_txt  OUT NOCOPY VARCHAR2) IS
	CURSOR determine_context_cur IS
	 SELECT CONTEXT , ATTRIBUTE
	 FROM   qp_npreq_line_attrs_tmp
	 WHERE  LINE_INDEX = p_line_index
         AND    ATTRIBUTE_TYPE = qp_preq_grp.G_PRICING_TYPE
	 AND    PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW
	 AND    LIST_HEADER_ID = p_list_header_id
	 AND    LIST_LINE_ID = p_list_line_id
	 AND    CONTEXT  = qp_preq_grp.G_PRIC_VOLUME_CONTEXT;

	/*CURSOR get_total_qty_cur(p_pricing_attribute VARCHAR2)  IS
         SELECT a.VALUE_FROM,a.GROUP_QUANTITY,a.GROUP_AMOUNT
	 FROM   qp_npreq_line_attrs_tmp a
	 WHERE  a.LINE_INDEX = p_line_index
	 AND    a.CONTEXT = qp_preq_grp.G_PRIC_VOLUME_CONTEXT
	 AND    a.ATTRIBUTE = p_pricing_attribute
	 AND    a.ATTRIBUTE_TYPE = qp_preq_grp.G_PRICING_TYPE
	 AND    a.PRICING_STATUS_CODE in (qp_preq_grp.G_STATUS_UNCHANGED,qp_preq_grp.G_STATUS_NEW);*/

        CURSOR get_total_qty_cur IS
	 SELECT LINE_QUANTITY,GROUP_QUANTITY,GROUP_AMOUNT
	 FROM   qp_npreq_ldets_tmp
	 WHERE  CREATED_FROM_LIST_LINE_ID = p_list_line_id
	 AND    LINE_INDEX = p_line_index
	 AND    PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW;

	CURSOR get_base_qty_cur(p_pricing_attribute VARCHAR2) IS
	 SELECT a.SETUP_VALUE_FROM , b.CREATED_FROM_LIST_LINE_TYPE,b.OPERAND_VALUE,b.BENEFIT_QTY
	 FROM   qp_npreq_line_attrs_tmp a , qp_npreq_ldets_tmp b
	 WHERE  a.LINE_INDEX = p_line_index
	 AND    a.LINE_INDEX = b.LINE_INDEX
	 AND    a.LIST_LINE_ID = b.CREATED_FROM_LIST_LINE_ID
	 AND    a.CONTEXT = qp_preq_grp.G_PRIC_VOLUME_CONTEXT
	 AND    a.ATTRIBUTE = p_pricing_attribute
	 AND    a.ATTRIBUTE_TYPE = qp_preq_grp.G_PRICING_TYPE
	 AND    a.PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW
	 AND    b.PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW
	 AND    a.LIST_LINE_ID = p_list_line_id
         AND    a.LIST_HEADER_ID = p_list_header_id
         AND    b.created_from_list_line_id = p_list_line_id      -- sql repos
         AND    b.created_from_list_header_id = p_list_header_id; -- sql repos

        CURSOR get_list_line_attrs_cur(p_line_id NUMBER)  IS
        SELECT LIST_LINE_TYPE_CODE,OPERAND,BENEFIT_QTY
        FROM   QP_LIST_LINES
        WHERE  LIST_LINE_ID = p_line_id;

	CURSOR get_modifier_level_code_cur IS
	SELECT MODIFIER_LEVEL_CODE
	FROM   QP_LIST_LINES
	WHERE  LIST_LINE_ID = p_list_line_id;

        v_routine_name CONSTANT VARCHAR2(240):='Routine:QP_Process_Other_Benefits_PVT.Calculate_Recurring_Quantity';

        v_total_base_qty                 NUMBER;
        v_group_qty	                 NUMBER;
        v_group_amount                   NUMBER;
        v_qualifying_qty                 NUMBER;
        v_qualifying_attribute           VARCHAR2(30);
        v_modifier_level_code            VARCHAR2(30);
        v_base_qty                       NUMBER;
        v_list_line_type_code            VARCHAR2(30);
        v_list_line_type                 VARCHAR2(30);
        v_arithmetic_operator            VARCHAR2(30);
        v_operand                        NUMBER;
        v_benefit_qty                    NUMBER;
        v_buy_base_qty                   NUMBER;
        v_pricing_attr_context           VARCHAR2(30);
        v_pricing_attribute              VARCHAR2(30);
        v_return_status	                 VARCHAR2(30);
        l_benefit_qty                    NUMBER;
        v_total_benefit_qty              NUMBER;

        INVALID_CONTEXT                  EXCEPTION;

       BEGIN
        l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF l_debug = FND_API.G_TRUE THEN
         qp_preq_grp.engine_debug ('List Line Id: ' || p_list_line_id);
        END IF;

        OPEN get_modifier_level_code_cur;
        FETCH get_modifier_level_code_cur INTO v_modifier_level_code;
        CLOSE get_modifier_level_code_cur;

        OPEN determine_context_cur;
        FETCH determine_context_cur INTO v_pricing_attr_context , v_pricing_attribute ;
        CLOSE determine_context_cur;

        v_qualifying_attribute := v_pricing_attribute;

        IF (v_pricing_attr_context = qp_preq_grp.G_PRIC_VOLUME_CONTEXT) THEN
         -- shu 2118147, need to fix this, v_group_amount is amt_per_unit
         OPEN  get_total_qty_cur;
         FETCH get_total_qty_cur INTO v_total_base_qty,v_group_qty,v_group_amount ;
         CLOSE get_total_qty_cur;
        ELSE
         IF l_debug = FND_API.G_TRUE THEN
          qp_preq_grp.engine_debug('context : ' || v_pricing_attr_context);
         END IF;
         RAISE INVALID_CONTEXT;
        END IF;

        IF l_debug = FND_API.G_TRUE THEN
         qp_preq_grp.engine_debug('v_total_base_qty: ' || v_total_base_qty);
         qp_preq_grp.engine_debug('v_group_qty: ' ||v_group_qty);
        END IF;

        OPEN  get_base_qty_cur(v_pricing_attribute);
        FETCH get_base_qty_cur INTO v_base_qty ,v_list_line_type_code,v_operand,v_benefit_qty ;
        CLOSE get_base_qty_cur;

        IF l_debug = FND_API.G_TRUE THEN
         qp_preq_grp.engine_debug('Total Setup Qty: ' || v_base_qty);
         qp_preq_grp.engine_debug('Operand: ' || v_operand);
         qp_preq_grp.engine_debug('List Line Type Code: ' || v_list_line_type_code);
        END IF;

        IF (p_benefit_line_id IS NOT NULL) THEN
         OPEN get_list_line_attrs_cur(p_benefit_line_id);
         FETCH get_list_line_attrs_cur INTO v_list_line_type,v_operand,v_benefit_qty;
         CLOSE get_list_line_attrs_cur;
        END IF;

        IF(v_list_line_type_code in(qp_preq_grp.G_DISCOUNT,qp_preq_grp.G_SURCHARGE)) THEN
         l_benefit_Qty := v_operand;
        ELSIF(v_list_line_type_code = qp_preq_grp.G_PROMO_GOODS_DISCOUNT) THEN
         l_benefit_qty := v_benefit_qty;
        ELSIF(v_list_line_type_code = qp_preq_grp.G_COUPON_ISSUE) THEN
         l_benefit_qty := 1; -- Need not look at the benefit part
        END IF;

        -- Determine Qualifying Quantity
        IF (v_modifier_level_code IN ('LINE','ORDER')) THEN
         v_qualifying_qty := v_total_base_qty; --from ldets_tmp.line_quantity
        ELSE
         -- If LINEGROUP
         IF (v_qualifying_attribute = qp_preq_grp.G_QUANTITY_ATTRIBUTE) THEN
          v_qualifying_qty := v_group_qty; --from ldets_tmp.group_quantity
         ELSE
          --v_qualifying_qty := v_group_amount; -- shu 2388011, this is wrong, should be from ldets_tmp.line_quantity
          v_qualifying_qty := v_total_base_qty; -- shu 2388011, --from ldets_tmp.line_quantity
         END IF;
        END IF;
        IF l_debug = FND_API.G_TRUE THEN
         qp_preq_grp.engine_debug('Modifier Level Code: '|| v_modifier_level_code);
	 qp_preq_grp.engine_debug('Qualifying Attribute : ' || v_qualifying_attribute);
	 qp_preq_grp.engine_debug('v_qualifying_qty: ' || v_qualifying_qty);
	 qp_preq_grp.engine_debug('v_base_qty: ' || v_base_qty);
	 qp_preq_grp.engine_debug('l_benefit_qty: ' || l_benefit_qty);
       END IF;
       v_total_benefit_qty :=  TRUNC((v_qualifying_qty / v_base_qty)) * l_benefit_qty;
       IF l_debug = FND_API.G_TRUE THEN
        qp_preq_grp.engine_debug('Total Benefit Qty: ' || v_total_benefit_qty);
       END IF;
       x_benefit_line_qty := v_total_benefit_qty;

  EXCEPTION
   WHEN INVALID_CONTEXT THEN
    IF l_debug = FND_API.G_TRUE THEN
    qp_preq_grp.engine_debug(v_routine_name || ' Invalid Context Specified.. Could Not Calculate Recurring Qty');
    END IF;
    x_return_status_txt := v_routine_name ||' Invalid Context Specified ..Could Not Calculate Recurring Qty';
    v_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status := v_return_status;
    IF l_debug = FND_API.G_TRUE THEN
    qp_preq_grp.engine_debug(x_return_status_txt);
    END IF;
   WHEN OTHERS  THEN
    IF l_debug = FND_API.G_TRUE THEN
    qp_preq_grp.engine_debug(v_routine_name || ' ' || SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_txt := v_routine_name || ' ' || SQLERRM;
  END Calculate_Recurring_Quantity;

PROCEDURE Calculate_Recurring_Quantity(p_pricing_phase_id        NUMBER,
                                       x_return_status      OUT NOCOPY VARCHAR2,
                                       x_return_status_txt  OUT NOCOPY VARCHAR2) IS
v_routine_name CONSTANT VARCHAR2(240):='QP_Process_Other_Benefits_PVT.Calculate_Recurring_Quantity';

CURSOR get_recurring_details_cur IS
SELECT QPLT.LINE_DETAIL_INDEX,
       QPLT.CREATED_FROM_LIST_LINE_ID,
       QPLT.CREATED_FROM_LIST_HEADER_ID,
       QPLT.LINE_INDEX
FROM qp_npreq_ldets_tmp QPLT
WHERE PRICING_PHASE_ID = p_pricing_phase_id
AND QPLT.AUTOMATIC_FLAG = QP_PREQ_GRP.G_YES -- 5632314
AND QPLT.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
AND CREATED_FROM_LIST_LINE_TYPE IN (QP_PREQ_GRP.G_DISCOUNT, QP_PREQ_GRP.G_SURCHARGE, QP_PREQ_GRP.G_FREIGHT_CHARGE)
AND PRICE_BREAK_TYPE_CODE = QP_PREQ_GRP.G_RECURRING_BREAK;

l_line_detail_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_list_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_list_header_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_line_index_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_benefit_line_qty_tbl QP_PREQ_GRP.NUMBER_TYPE;
l_return_status VARCHAR2(240);
l_status_text   VARCHAR2(240);

BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Calculate_Recurring_Quantity-PHASE='||p_pricing_phase_id);
  END IF;

  OPEN get_recurring_details_cur;
  LOOP
    FETCH get_recurring_details_cur BULK COLLECT INTO
      l_line_detail_index_tbl,
      l_list_line_id_tbl,
      l_list_header_id_tbl,
      l_line_index_tbl;
    EXIT WHEN l_line_detail_index_tbl.COUNT = 0;

    FOR I in l_line_detail_index_tbl.first .. l_line_detail_index_tbl.last
    LOOP
      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('In Recurring Routine --- #1');
        QP_PREQ_GRP.engine_debug('List Header Id: ' || l_LIST_HEADER_ID_TBL(I) );
        QP_PREQ_GRP.engine_debug('List Line Id: ' || l_LIST_LINE_ID_TBL(I) );
        QP_PREQ_GRP.engine_debug('List Line Index: ' || l_LINE_INDEX_TBL(I) );
      END IF;

      -- Call Recurring Routine
      QP_Process_Other_Benefits_PVT.Calculate_Recurring_Quantity(
        l_LIST_LINE_ID_TBL(I),
        l_LIST_HEADER_ID_TBL(I),
        l_LINE_INDEX_TBL(I),
        NULL,
        l_benefit_line_qty_tbl(I),
        l_return_status,
        l_status_text);

      IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Return Status Text : ' || l_status_text);
      END IF;

      IF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

    FORALL I IN l_line_detail_index_tbl.first..l_line_detail_index_tbl.last
      UPDATE qp_npreq_ldets_tmp --upd1
      SET operand_value = l_benefit_line_qty_tbl(I)
      WHERE LINE_DETAIL_INDEX = l_line_detail_index_tbl(I);

    IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Updated count: ' || l_line_detail_index_tbl.count);
    END IF;
  END LOOP;

  IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('End Calculate_Recurring_Quantity-PHASE='||p_pricing_phase_id);
  END IF;

EXCEPTION
   WHEN OTHERS THEN
    IF l_debug = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug(v_routine_name || ' ' || SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_txt := v_routine_name || ' ' || SQLERRM;
END Calculate_Recurring_Quantity;

PROCEDURE Process_PRG(p_line_index              NUMBER,
                      p_line_detail_index       NUMBER,
                      p_modifier_level_code     VARCHAR2,
                      p_list_line_id		NUMBER,
                      p_pricing_phase_id    	NUMBER,
                      x_return_status		OUT NOCOPY  VARCHAR2,
                      x_return_status_txt       OUT NOCOPY  VARCHAR2) AS

-- Get the Related Modifier id from qp_rltd_modifiers table
-- Insert a line into the qp_npreq_lines_tmp table for the other item
-- Insert a line into qp_npreq_rltd_lines_tmp
-- Insert a line into qp_npreq_ldets_tmp table for discount on the new line

-- Insert a line into qp_npreq_rltd_lines_tmp
-- Insert a line into qp_npreq_line_attrs_tmp


CURSOR get_related_modifier_id_cur IS
SELECT distinct a.PRICE_BREAK_TYPE_CODE , b.FROM_RLTD_MODIFIER_ID,b.TO_RLTD_MODIFIER_ID,c.LINE_DETAIL_INDEX ,
a.PRICING_PHASE_ID , a.AUTOMATIC_FLAG,a.LIST_HEADER_ID
FROM   QP_LIST_LINES a, QP_RLTD_MODIFIERS b,qp_npreq_ldets_tmp c
WHERE  a.LIST_LINE_ID = b.FROM_RLTD_MODIFIER_ID
AND    a.LIST_LINE_ID = c.CREATED_FROM_LIST_LINE_ID
AND    b.RLTD_MODIFIER_GRP_TYPE = qp_preq_grp.G_BENEFIT_TYPE
AND    c.CREATED_FROM_LIST_LINE_TYPE = qp_preq_grp.G_PROMO_GOODS_DISCOUNT
AND    c.PRICING_PHASE_ID = p_pricing_phase_id
AND    c.LINE_INDEX = p_line_index
AND    a.LIST_LINE_ID = p_list_line_id
AND    c.PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW;

CURSOR get_related_lines_cur(p_related_modifier_id NUMBER) IS
SELECT a.LIST_TYPE_CODE,b.LIST_HEADER_ID,b.LIST_LINE_ID,b.LIST_LINE_TYPE_CODE,
       b.PRICING_GROUP_SEQUENCE, b.ARITHMETIC_OPERATOR,b.OPERAND,b.PRICING_PHASE_ID,
       b.BENEFIT_PRICE_LIST_LINE_ID, b.BENEFIT_UOM_CODE,b.BENEFIT_QTY,b.LIST_PRICE,
       b.PRICE_BREAK_TYPE_CODE,b.AUTOMATIC_FLAG, c.PRODUCT_ATTRIBUTE_CONTEXT, c.PRODUCT_ATTRIBUTE,
       c.PRODUCT_ATTR_VALUE,c.PRODUCT_UOM_CODE , b.ACCRUAL_FLAG,b.MODIFIER_LEVEL_CODE
FROM   QP_LIST_HEADERS_B a ,QP_LIST_LINES b,QP_PRICING_ATTRIBUTES c
WHERE  a.LIST_HEADER_ID = b.LIST_HEADER_ID
AND    b.LIST_LINE_ID =  c.LIST_LINE_ID
AND    b.LIST_LINE_ID= p_related_modifier_id;

CURSOR get_benefit_line_index_cur(p_list_line_id NUMBER, p_line_index NUMBER) IS
SELECT CREATED_FROM_LIST_LINE_ID
FROM   qp_npreq_ldets_tmp c
WHERE  c.CREATED_FROM_LIST_LINE_ID = p_list_line_id
AND    c.PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW
AND    c.LINE_INDEX = p_line_index ;


CURSOR get_list_price_cur(p_line_id NUMBER)  IS
SELECT a.LIST_HEADER_ID,a.LIST_LINE_ID,a.OPERAND,b.ROUNDING_FACTOR
FROM   QP_LIST_LINES a ,QP_LIST_HEADERS_B b
WHERE  a.LIST_LINE_ID = p_line_id
AND    a.LIST_HEADER_ID = b.LIST_HEADER_ID
AND    a.ARITHMETIC_OPERATOR = qp_preq_grp.G_UNIT_PRICE;

CURSOR get_request_type_code_cur IS
SELECT REQUEST_TYPE_CODE
FROM   qp_npreq_lines_tmp
WHERE  LINE_INDEX = p_line_index;

CURSOR get_max_line_index_cur IS
SELECT MAX(LINE_INDEX)
FROM   qp_npreq_lines_tmp;

--removed rownum=1 spgopal to create relation for multiple buys/gets
--for linegroup prg against each qualified line
CURSOR get_rltd_line_detail_index IS
 -- Bug 2979447 - also selected related_list_line_id needed by order capture
 -- Bug 2998770 - removed LINE_INDEX and also added distinct, code merged from trunk version 115.66
 -- Bug 3074630 - ignore the relationships passed by calling application for free good line, join to
 --               qp_npreq_lines_tmp to check the process_status for string FREEGOOD
--SELECT RELATED_LINE_DETAIL_INDEX,LINE_INDEX,RELATED_LINE_INDEX
SELECT distinct RELATED_LINE_DETAIL_INDEX,RELATED_LINE_INDEX -- fix bug 2998770
       ,related_list_line_id -- bug 2979447
FROM   qp_npreq_rltd_lines_tmp a, qp_npreq_lines_tmp b
WHERE  a.LIST_LINE_ID = p_list_line_id
AND    b.line_index = a.related_line_index
AND    (instr(b.PROCESS_STATUS,'FREEGOOD')=0)
AND    a.RELATIONSHIP_TYPE_CODE = qp_preq_grp.G_GENERATED_LINE
AND    a.PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW;
--        AND    ROWNUM = 1;


v_line_index			NUMBER;
v_detail_line_index 		NUMBER;
v_other_item_list_price		NUMBER;
v_other_item_base_qty		NUMBER;
v_list_price			NUMBER;
v_list_header_id		NUMBER;
v_list_line_id			NUMBER;
l_list_line_id                  NUMBER;
v_base_qty			NUMBER;
v_base_uom			VARCHAR2(30);
v_request_type_code		VARCHAR2(30);
x_total_benefit_qty		NUMBER;
x_ret_status			VARCHAR2(30);
x_ret_status_txt		VARCHAR2(240);
v_benefit_exists                BOOLEAN;
v_rounding_factor               NUMBER;
l_rltd_line_detail_index        NUMBER;
v_routine_name CONSTANT VARCHAR2(240) := 'Routine:QP_Process_Other_Benefits.Process_PRG';
BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;
v_benefit_exists := FALSE;

l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

l_rltd_line_detail_index := NULL;

-- Ravi (If it is a LINEGROUP PRG) Then Just create the relationship
-- Get the line detail index of the prg line from qp_npreq_ldets_tmp and then get the rltd_line_detail_index
-- from qp_npreq_rltd_lines_tmp and create a relationship between the line_detail_index and the rltd_line_detail_index
-- If record does not exist go thru the regular prg processing


IF l_debug = FND_API.G_TRUE THEN
 qp_preq_grp.engine_debug('Modifier Level Code: ' || p_modifier_level_code);
END IF;

IF (p_modifier_level_code = 'LINEGROUP') THEN
--       OPEN get_rltd_line_detail_index;
--       FETCH get_rltd_line_detail_index INTO l_rltd_line_detail_index;
--       CLOSE get_rltd_line_detail_index;
--      END IF;--p_modifier_level_code
--changes made by spgopal to insert the relationships for each line
--qualifying for the linegroup modifier

  FOR j IN get_rltd_line_detail_index
  LOOP
    IF l_debug = FND_API.G_TRUE THEN
     qp_preq_grp.engine_debug('Linegroup Related Line Detail Index: ' || j.related_line_detail_index);
    END IF;
    l_rltd_line_detail_index := j.related_line_detail_index;

    INSERT INTO qp_npreq_rltd_lines_tmp
    (REQUEST_TYPE_CODE
    ,LINE_DETAIL_INDEX
    ,RELATIONSHIP_TYPE_CODE
    ,RELATED_LINE_DETAIL_INDEX
    ,PRICING_STATUS_CODE
    ,LIST_LINE_ID
    ,LINE_INDEX
    ,RELATED_LINE_INDEX
    ,related_list_line_id) -- bug 2979447
    VALUES
    (v_request_type_code
    ,p_line_detail_index
    ,qp_preq_grp.G_GENERATED_LINE
    ,j.related_line_detail_index
    ,qp_preq_grp.G_STATUS_NEW
    ,p_list_line_id
    ,p_line_index
    ,j.related_line_index
    ,j.related_list_line_id); -- bug 2979447

    IF l_debug = FND_API.G_TRUE THEN
    qp_preq_grp.engine_debug('Only relationship is getting created'
    ||' for LineGroup discounts');
    qp_preq_grp.engine_debug('New Related Line Detail-Line Detail Created');
    END IF;
  END LOOP;--get_rltd_line_detail_index
END IF;--p_modifier_level_code
--    	ELSE

IF l_rltd_line_detail_index IS NULL THEN

  IF l_debug = FND_API.G_TRUE THEN
   qp_preq_grp.engine_debug('Regular PRG processing');
  END IF;

  OPEN get_max_line_index_cur;
  FETCH get_max_line_index_cur INTO v_line_index;
  CLOSE get_max_line_index_cur;

  v_detail_line_index := qp_preq_grp.G_LINE_DETAIL_INDEX;

  FOR j IN get_related_modifier_id_cur
  LOOP
    FOR i IN get_related_lines_cur(j.TO_RLTD_MODIFIER_ID)
    LOOP
      v_line_index := v_line_index + 1; -- Temporary

      IF (j.PRICE_BREAK_TYPE_CODE = qp_preq_grp.G_RECURRING_BREAK) THEN
        Calculate_Recurring_Quantity(j.FROM_RLTD_MODIFIER_ID,
                                     j.LIST_HEADER_ID,
                                     p_line_index,
                                     j.TO_RLTD_MODIFIER_ID,
                                     x_total_benefit_qty,
                                     x_ret_status,
                                     x_ret_status_txt);
      ELSE--j.PRICE_BREAK_TYPE_CODE
        x_total_benefit_qty := i.BENEFIT_QTY;
      END IF;--j.PRICE_BREAK_TYPE_CODE

      IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_debug = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('Total Benefit Qty:' || x_total_benefit_qty);
      END IF;

      -- Find the Price of the DIS for PRG Line Vivek
      -- Only LIST_PRICE column on BENEFIT_PRICE_LIST_LINE_ID

      IF l_debug = FND_API.G_TRUE THEN
       qp_preq_grp.engine_debug('Benefit Price List Line Id:' || i.BENEFIT_PRICE_LIST_LINE_ID);
      END IF;

      OPEN  get_list_price_cur(i.BENEFIT_PRICE_LIST_LINE_ID);
      FETCH get_list_price_cur
      INTO v_list_header_id,v_list_line_id,v_list_price,v_rounding_factor;
      CLOSE get_list_price_cur;

      IF l_debug = FND_API.G_TRUE THEN
       qp_preq_grp.engine_debug('PRG Line Rounding Factor :' || v_rounding_factor);
      END IF;

      OPEN  get_request_type_code_cur;
      FETCH get_request_type_code_cur INTO v_request_type_code;
      CLOSE get_request_type_code_cur;

      IF l_debug = FND_API.G_TRUE THEN
       qp_preq_grp.engine_debug('List Price of DIS Line:' || v_list_price);
      END IF;

      OPEN get_benefit_line_index_cur(i.LIST_LINE_ID,v_line_index);
      FETCH get_benefit_line_index_cur INTO l_list_line_id;
      CLOSE get_benefit_line_index_cur;

      -- If this adjustment line does not exist against
      -- any PRG Line Index,then create
      -- For other PRG Lines , they will be deleted

      IF (l_list_line_id IS NULL) THEN
        v_benefit_exists := TRUE;

        -- begin shu, side fix bug 2491158,
        -- insert price_list_header_id for generated line
        INSERT INTO qp_npreq_lines_tmp
        (LINE_INDEX
        , PRICE_LIST_HEADER_ID
        , LINE_TYPE_CODE
        , PRICING_EFFECTIVE_DATE
        , LINE_QUANTITY
        , LINE_UOM_CODE
        , CURRENCY_CODE
        , PRICING_STATUS_CODE
        , PROCESSED_FLAG
        , ADJUSTED_UNIT_PRICE
        , PRICE_FLAG
        , UNIT_PRICE
        , REQUEST_TYPE_CODE
        , PRICED_UOM_CODE
        , PRICED_QUANTITY
        , PROCESSED_CODE
        , ROUNDING_FACTOR
        , ROUNDING_FLAG
        --added by spgopal for prg
        , PROCESS_STATUS
        --to create returns of prg to create return for freegood spgopal
        , LINE_CATEGORY)
        SELECT v_line_index
        , v_list_header_id
        , LINE_TYPE_CODE
        , PRICING_EFFECTIVE_DATE
        , x_total_benefit_qty
        , i.BENEFIT_UOM_CODE
        , CURRENCY_CODE
        , qp_preq_grp.G_STATUS_UNCHANGED
        , PROCESSED_FLAG
        , v_list_price
        , qp_preq_grp.G_NO
        , v_list_price
        , REQUEST_TYPE_CODE
        , i.BENEFIT_UOM_CODE
        , x_total_benefit_qty
        , qp_preq_grp.G_BY_ENGINE
        , v_rounding_factor
        , qp_preq_grp.G_YES
        , qp_preq_grp.G_STATUS_NEW
        , LINE_CATEGORY
        FROM   qp_npreq_lines_tmp
        WHERE  LINE_INDEX = p_line_index;

        IF l_debug = FND_API.G_TRUE THEN
         qp_preq_grp.engine_debug('New Line Created');
        END IF;

        -- Ravi remove line to line relationship ie comment out the insert below
        /* INSERT INTO qp_npreq_rltd_lines_tmp(REQUEST_TYPE_CODE, LINE_INDEX,RELATIONSHIP_TYPE_CODE,
        RELATED_LINE_INDEX, PRICING_STATUS_CODE) VALUES
        (v_request_type_code,p_line_index,qp_preq_grp.G_GENERATED_LINE,v_line_index,
        qp_preq_grp.G_STATUS_NEW);
        IF l_debug = FND_API.G_TRUE THEN
        qp_preq_grp.engine_debug('New Line-Line Created');
        END IF; */

        v_detail_line_index := v_detail_line_index + 1; -- Temporary

        -- Create a PLL Line
        INSERT INTO qp_npreq_ldets_tmp
        (LINE_DETAIL_INDEX
        ,LINE_DETAIL_TYPE_CODE
        ,LINE_INDEX
        ,CREATED_FROM_LIST_HEADER_ID
        ,CREATED_FROM_LIST_LINE_ID
        ,CREATED_FROM_LIST_LINE_TYPE
        ,PRICING_GROUP_SEQUENCE
        ,OPERAND_CALCULATION_CODE
        ,OPERAND_VALUE
        ,PROCESSED_FLAG
        ,CREATED_FROM_LIST_TYPE_CODE
        ,PRICING_STATUS_CODE
        ,LINE_QUANTITY
        ,ROUNDING_FACTOR
        ,PROCESS_CODE)
        VALUES
        (v_detail_line_index
        ,qp_preq_grp.G_GENERATED_LINE
        ,v_line_index
        ,v_list_header_id
        ,v_list_line_id
        ,qp_preq_grp.G_PRICE_LIST_TYPE
        ,0
        ,qp_preq_grp.G_UNIT_PRICE
        ,v_list_price
        ,qp_preq_grp.G_NO
        ,qp_preq_grp.G_PRICE_LIST_HEADER
        ,qp_preq_grp.G_STATUS_NEW
        ,x_total_benefit_qty
        ,v_rounding_factor
        ,qp_preq_grp.G_STATUS_NEW);

        IF l_debug = FND_API.G_TRUE THEN
         qp_preq_grp.engine_debug('New PLL Line Created');
        END IF;

        v_detail_line_index := v_detail_line_index + 1; -- Temporary

        -- Create an Adjustment Line
        INSERT INTO qp_npreq_ldets_tmp
        (LINE_DETAIL_INDEX
        ,LINE_DETAIL_TYPE_CODE
        ,LINE_INDEX
        ,CREATED_FROM_LIST_HEADER_ID
        ,CREATED_FROM_LIST_LINE_ID
        ,CREATED_FROM_LIST_LINE_TYPE
        ,PRICING_GROUP_SEQUENCE
        ,OPERAND_CALCULATION_CODE
        ,PRICING_PHASE_ID
        ,OPERAND_VALUE
        ,PROCESSED_FLAG
        ,AUTOMATIC_FLAG
        ,APPLIED_FLAG
        ,ACCRUAL_FLAG
        ,CREATED_FROM_LIST_TYPE_CODE
        ,PRICING_STATUS_CODE
        ,LINE_QUANTITY
        ,PROCESS_CODE
        ,MODIFIER_LEVEL_CODE
	,CALCULATION_CODE)
        VALUES
        (v_detail_line_index
        ,qp_preq_grp.G_GENERATED_LINE
        ,v_line_index
        ,i.LIST_HEADER_ID
        ,i.LIST_LINE_ID
        ,i.LIST_LINE_TYPE_CODE
        ,i.PRICING_GROUP_SEQUENCE
        ,i.ARITHMETIC_OPERATOR
        ,j.PRICING_PHASE_ID
        ,i.OPERAND
        ,qp_preq_grp.G_NO
        ,j.AUTOMATIC_FLAG
        ,qp_preq_grp.G_YES
        ,nvl(i.ACCRUAL_FLAG ,'N')
        ,i.LIST_TYPE_CODE
        ,qp_preq_grp.G_STATUS_NEW
        ,x_total_benefit_qty
        ,qp_preq_grp.G_STATUS_NEW
        ,i.MODIFIER_LEVEL_CODE
        --fix for bug 2988476
	,QP_PREQ_PUB.G_FREEGOOD);

        IF l_debug = FND_API.G_TRUE THEN
         qp_preq_grp.engine_debug('New Adjustment Line Created');
        END IF;

        INSERT INTO qp_npreq_rltd_lines_tmp
        (REQUEST_TYPE_CODE,
        LINE_DETAIL_INDEX,
        RELATIONSHIP_TYPE_CODE,
        RELATED_LINE_DETAIL_INDEX,
        PRICING_STATUS_CODE,
        LIST_LINE_ID,
        -- begin shu,side fix bug 2491158,missing data in qp_npreq_rltd_lines_tmp
        line_index,
        related_line_index,
        related_list_line_id,
        related_list_line_type,
        operand_calculation_code,
        operand,
        qualifier_value
        -- end shu, side fix bug 2491158, missing data in qp_npreq_rltd_lines_tmp
        )
        VALUES
        (v_request_type_code,
        j.LINE_DETAIL_INDEX,
        qp_preq_grp.G_GENERATED_LINE,
        v_detail_line_index,
        qp_preq_grp.G_STATUS_NEW,
        p_list_line_id,
        -- begin shu,side fix bug 2491158,missing data in qp_npreq_rltd_lines_tmp
        p_line_index,
        v_line_index,
        i.LIST_LINE_ID,
        i.LIST_LINE_TYPE_CODE,
        i.ARITHMETIC_OPERATOR,
        i.OPERAND,
        x_total_benefit_qty
        -- end shu, side fix bug 2491158, missing data in qp_npreq_rltd_lines_tmp
        );

        IF l_debug = FND_API.G_TRUE THEN
         qp_preq_grp.engine_debug('New Related Line Detail-Line Detail Created');
        END IF;

        -- Insert into Line Attributes table qp_npreq_line_attrs_tmp
        INSERT INTO qp_npreq_line_attrs_tmp
        (LIST_LINE_ID
        ,LINE_INDEX
        ,line_detail_index
        ,CONTEXT
        ,ATTRIBUTE
        ,VALUE_FROM
        ,SETUP_VALUE_FROM
        ,VALIDATED_FLAG
        ,PRODUCT_UOM_CODE
        ,ATTRIBUTE_LEVEL
        ,ATTRIBUTE_TYPE
        ,PRICING_STATUS_CODE)
        VALUES
        (i.LIST_LINE_ID
        ,v_line_index
        ,v_detail_line_index
        ,qp_preq_grp.G_PRIC_ITEM_CONTEXT
        ,qp_preq_grp.G_PRIC_ATTRIBUTE1
        ,i.PRODUCT_ATTR_VALUE
        ,i.PRODUCT_ATTR_VALUE
        ,qp_preq_grp.G_NO
        ,i.PRODUCT_UOM_CODE
        ,qp_preq_grp.G_LINE_LEVEL
        ,qp_preq_grp.G_PRODUCT_TYPE
        ,qp_preq_grp.G_STATUS_NEW); --Item

        IF l_debug = FND_API.G_TRUE THEN
         qp_preq_grp.engine_debug('New Attribute Line Created');
        END IF;
      END IF; -- l_list_line_id;

      -- Ravi Do not delete the PRG Lines ie uncomment the update below
      -- This is the code to delete the PRG lines which do not have
      -- adjustments/benefits even thou x_qualifier_flag=TRUE

	    /* IF (v_benefit_exists = FALSE) THEN
     	        UPDATE qp_npreq_ldets_tmp --upd1
		SET PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_OTHER_ITEM_BENEFITS
		WHERE PRICING_PHASE_ID = p_pricing_phase_id
		AND   LINE_INDEX = p_line_index
		AND   CREATED_FROM_LIST_LINE_ID = p_list_line_id
		AND   PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW;

                -- This statement can be commented out
		UPDATE qp_npreq_line_attrs_tmp
		SET   PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_OTHER_ITEM_BENEFITS
		WHERE LINE_INDEX = p_line_index
		AND   LIST_LINE_ID = p_list_line_id
		AND   PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW;

	    END IF; */

    END LOOP;--get_related_lines_cur
  END LOOP;--get_related_modifier_id_cur
  qp_preq_grp.G_LINE_DETAIL_INDEX := v_detail_line_index;
END IF;--l_rltd_line_detail_index
EXCEPTION
WHEN OTHERS  THEN
  IF l_debug = FND_API.G_TRUE THEN
  qp_preq_grp.engine_debug(v_routine_name || ' ' || SQLERRM);
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status_txt := v_routine_name || ' ' || SQLERRM;
  IF l_debug = FND_API.G_TRUE THEN
  qp_preq_grp.engine_debug('Process_PRG: ' || SQLERRM);
  END IF;
END Process_PRG;

PROCEDURE Process_OID(p_line_index            NUMBER,
                      p_list_line_id          NUMBER,
                      p_pricing_phase_id      NUMBER,
                      x_return_status     OUT NOCOPY VARCHAR2,
                      x_return_status_txt OUT NOCOPY VARCHAR2) AS

	-- Get the Related Modifier id from qp_rltd_modifiers table
	-- Insert a line into the qp_npreq_lines_tmp table for the other item
	-- Insert a line into qp_npreq_rltd_lines_tmp
	-- Insert a line into qp_npreq_ldets_tmp table for discount on the new line

	-- Insert a line into qp_npreq_rltd_lines_tmp
	-- Insert a line into qp_npreq_line_attrs_tmp


      CURSOR get_related_modifier_id_cur IS
      SELECT distinct a.LIST_LINE_TYPE_CODE,b.FROM_RLTD_MODIFIER_ID,b.TO_RLTD_MODIFIER_ID , c.LINE_DETAIL_INDEX,
             a.PRICING_PHASE_ID , a.AUTOMATIC_FLAG
      FROM   QP_LIST_LINES a, QP_RLTD_MODIFIERS b,qp_npreq_ldets_tmp c
      WHERE  a.LIST_LINE_ID = b.FROM_RLTD_MODIFIER_ID
      AND    a.LIST_LINE_ID = c.CREATED_FROM_LIST_LINE_ID
      AND    b.RLTD_MODIFIER_GRP_TYPE = qp_preq_grp.G_BENEFIT_TYPE
      AND    c.CREATED_FROM_LIST_LINE_TYPE = qp_preq_grp.G_OTHER_ITEM_DISCOUNT
      AND    c.PRICING_PHASE_ID = p_pricing_phase_id
      AND    c.LINE_INDEX = p_line_index
      AND    a.LIST_LINE_ID = p_list_line_id
      AND    c.PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW;

      CURSOR get_related_lines_cur(p_related_modifier_id NUMBER) IS
      SELECT distinct a.LIST_TYPE_CODE,b.LIST_HEADER_ID,b.LIST_LINE_ID,b.LIST_LINE_TYPE_CODE,
             b.PRICING_GROUP_SEQUENCE, b.ARITHMETIC_OPERATOR,b.OPERAND,b.AUTOMATIC_FLAG,
             b.BENEFIT_PRICE_LIST_LINE_ID,b.LIST_PRICE, c.PRODUCT_ATTRIBUTE_CONTEXT,
             c.PRODUCT_ATTRIBUTE,c.PRODUCT_ATTR_VALUE , b.ACCRUAL_FLAG,b.MODIFIER_LEVEL_CODE
      FROM   QP_LIST_HEADERS_B a ,QP_LIST_LINES b, QP_PRICING_ATTRIBUTES c
      WHERE  a.LIST_HEADER_ID = b.LIST_HEADER_ID
      AND    b.LIST_LINE_ID = c.LIST_LINE_ID
      AND    b.LIST_LINE_ID= p_related_modifier_id;

      CURSOR get_benefit_line_index_cur(p_context VARCHAR2,
                                        p_attribute VARCHAR2,
                                        p_value VARCHAR2,
                                        p_list_line_id NUMBER) IS

      -- performance fix for 5573416
      SELECT /*+ ORDERED USE_NL(a)
                 index(b qp_preq_lines_tmp_n2)
                 index(a qp_preq_line_attrs_tmp_n2)
                 get_benefit_line_index_cur */
             distinct a.LINE_INDEX,nvl(b.PRICED_QUANTITY,b.LINE_QUANTITY) LINE_QUANTITY
      FROM   qp_npreq_lines_tmp b , qp_npreq_line_attrs_tmp a
      WHERE  a.LINE_INDEX = b.LINE_INDEX
      AND    a.CONTEXT = p_context
      AND    a.ATTRIBUTE = p_attribute
      AND    a.VALUE_FROM = p_value
      AND    a.ATTRIBUTE_TYPE = qp_preq_grp.G_PRODUCT_TYPE
      AND    a.PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_UNCHANGED
      AND    b.LINE_TYPE_CODE <> qp_preq_grp.G_ORDER_LEVEL
      AND    NOT EXISTS ( SELECT /*+ index(c qp_preq_ldets_tmp_n1) */ 'x'
                          FROM qp_npreq_ldets_tmp c
                          WHERE c.LINE_INDEX = a.LINE_INDEX
                          AND   c.CREATED_FROM_LIST_LINE_ID = p_list_line_id
                          AND   c.PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW);

      CURSOR get_request_type_code_cur IS
      SELECT REQUEST_TYPE_CODE
      FROM   qp_npreq_lines_tmp
      WHERE  LINE_INDEX = p_line_index;

      v_detail_line_index             NUMBER;
      v_other_item_list_price         NUMBER;
      v_other_item_final_price        NUMBER;
      v_other_item_base_qty           NUMBER;
      v_other_item_base_uom           VARCHAR2(30);

      v_list_price                    NUMBER;
      v_base_qty                      NUMBER;
      v_base_uom                      VARCHAR2(30);

      v_other_item_final_qty          NUMBER;
      v_request_type_code             VARCHAR2(30);

      x_qualifier_flag                BOOLEAN;
      x_ret_status                    VARCHAR2(30);
      x_ret_status_txt                VARCHAR2(240);
      v_routine_name CONSTANT         VARCHAR2(240) := 'Routine:QP_Process_Other_Benefits.Process_OID';
      v_benefit_exists                BOOLEAN;

     BEGIN

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      v_benefit_exists := FALSE;

      l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

      OPEN  get_request_type_code_cur;
      FETCH get_request_type_code_cur INTO v_request_type_code;
      CLOSE get_request_type_code_cur;

      v_detail_line_index := qp_preq_grp.G_LINE_DETAIL_INDEX;

      FOR j IN get_related_modifier_id_cur
      LOOP
	  FOR i IN get_related_lines_cur(j.TO_RLTD_MODIFIER_ID)
	  LOOP
           IF l_debug = FND_API.G_TRUE THEN
	    qp_preq_grp.engine_debug('Loop Count');
           END IF;
           IF l_debug = FND_API.G_TRUE THEN
	    qp_preq_grp.engine_debug ('FROM RLTD MODIFIER ID : ' || j.FROM_RLTD_MODIFIER_ID);
	    qp_preq_grp.engine_debug ('TO RLTD MODIFIER ID : ' || j.TO_RLTD_MODIFIER_ID);
           END IF;

	  -- Verify the qualification for the benefit line also
	  Find_Qualification_For_Benefit(p_line_index,
                                         j.TO_RLTD_MODIFIER_ID,
                                         qp_preq_grp.G_BENEFIT_TYPE,
                                         qp_preq_grp.G_OTHER_ITEM_DISCOUNT,
                                         x_qualifier_flag,
                                         x_ret_status,
                                         x_ret_status_txt);

          IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
    	  END IF;

        IF (x_qualifier_flag = TRUE) THEN
         IF l_debug = FND_API.G_TRUE THEN
	  qp_preq_grp.engine_debug('The qualifier flag:' || 'TRUE');
         END IF;
	ELSE

         IF l_debug = FND_API.G_TRUE THEN
	  qp_preq_grp.engine_debug('Failed in Qualification:' || j.TO_RLTD_MODIFIER_ID);
         END IF;

         UPDATE qp_npreq_ldets_tmp --upd1
         SET PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_OTHER_ITEM_BENEFITS
         WHERE PRICING_PHASE_ID = p_pricing_phase_id
         AND   LINE_INDEX = p_line_index
         AND   CREATED_FROM_LIST_LINE_ID = j.FROM_RLTD_MODIFIER_ID
         AND   PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW;

          --This statement is not needed
          /* UPDATE qp_npreq_line_attrs_tmp
          SET PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_OTHER_ITEM_BENEFITS
          WHERE LIST_LINE_ID = j.FROM_RLTD_MODIFIER_ID
          AND   PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW; */

         END IF;


	  IF (x_qualifier_flag = TRUE) THEN

	    -- This cursor below might fetch multiple benefit lines for the combination of context , attribute , value
	    -- against different request line id's
	    -- Then create Same Benefit line against multiple request lines
	    -- Ex: 1 ItemA(OID) 2 ItemB(Benefit) 3 ItemA(OID) 4ItemB(Benefit)
	    -- In this case , the engine would select line index 2 and line index 4 as part of the cursor
	    -- It will insert the same benefit line against line2 and line 4 when processing OID 1
	    -- For OID2 , the cursor would not fetch any records and the v_benefits_exists flag is FALSE and the
	    -- second OID line gets deleted
	    -- Essentially , the second  benefit line is  also because of OID 1

	    FOR m IN get_benefit_line_index_cur
                (i.PRODUCT_ATTRIBUTE_CONTEXT, i.PRODUCT_ATTRIBUTE, i.PRODUCT_ATTR_VALUE,i.LIST_LINE_ID)
            LOOP

             v_benefit_exists := TRUE;
	     v_detail_line_index := v_detail_line_index + 1; -- Temporary

  	     INSERT INTO qp_npreq_ldets_tmp
             (LINE_DETAIL_INDEX,
              LINE_DETAIL_TYPE_CODE,
              LINE_INDEX,
              CREATED_FROM_LIST_HEADER_ID,
              CREATED_FROM_LIST_LINE_ID,
              CREATED_FROM_LIST_LINE_TYPE,
              PRICING_GROUP_SEQUENCE,
              OPERAND_CALCULATION_CODE,
              OPERAND_VALUE,
              PROCESSED_FLAG,
              AUTOMATIC_FLAG,
              APPLIED_FLAG,
              ACCRUAL_FLAG,
              PRICING_PHASE_ID,
              CREATED_FROM_LIST_TYPE_CODE,
              PRICING_STATUS_CODE,
              LINE_QUANTITY,
              PROCESS_CODE,
              MODIFIER_LEVEL_CODE)
	     VALUES
             (v_detail_line_index,
              qp_preq_grp.G_GENERATED_LINE,
              m.line_index,
              i.LIST_HEADER_ID,
              i.LIST_LINE_ID,
              i.LIST_LINE_TYPE_CODE,
              i.PRICING_GROUP_SEQUENCE,
              i.ARITHMETIC_OPERATOR,
              i.OPERAND,
              qp_preq_grp.G_NO,
              j.AUTOMATIC_FLAG,
              qp_preq_grp.G_YES,nvl(i.ACCRUAL_FLAG,'N'),
              j.PRICING_PHASE_ID,
              i.LIST_TYPE_CODE,
              qp_preq_grp.G_STATUS_NEW,
              m.LINE_QUANTITY,
              qp_preq_grp.G_STATUS_NEW,
              i.MODIFIER_LEVEL_CODE);

		-- shu, begin fix bug 2491158
              IF l_debug = FND_API.G_TRUE THEN
		qp_preq_grp.engine_debug ('debug data going to qp_npreq_rltd_lines_tmp .........');
		qp_preq_grp.engine_debug ('OID line_index: '||p_line_index);
		qp_preq_grp.engine_debug ('OID list_line_id: '||p_list_line_id);
		qp_preq_grp.engine_debug ('Benifit line_index: '||m.line_index);
		qp_preq_grp.engine_debug ('Benifit list_line_id: '||i.list_line_id);
		qp_preq_grp.engine_debug ('Benifit list_line_type_code: '||i.list_line_type_code);
		qp_preq_grp.engine_debug ('Benifit OPERAND: '||i.OPERAND);
		qp_preq_grp.engine_debug ('Benifit ARITHMETIC_OPERATOR: '||i.ARITHMETIC_OPERATOR);
		qp_preq_grp.engine_debug ('Benifit LINE_QUANTITY: '||m.LINE_QUANTITY);
              END IF;

	    INSERT INTO qp_npreq_rltd_lines_tmp
		 (REQUEST_TYPE_CODE,
		 LINE_DETAIL_INDEX,
		 RELATIONSHIP_TYPE_CODE,
		 RELATED_LINE_DETAIL_INDEX,
		 PRICING_STATUS_CODE,
		 line_index, 		-- begin shu, fix 2491158, missing data in qp_npreq_rltd_lines_tmp
		 related_line_index,
		 list_line_id,
		 related_list_line_id,
		 related_list_line_type,
		 operand_calculation_code,
		 operand,
		 qualifier_value	-- end shu, fix 2491158, missing data in qp_npreq_rltd_lines_tmp
		 )
		 VALUES
		 (v_request_type_code,
		 j.LINE_DETAIL_INDEX,
		 qp_preq_grp.G_GENERATED_LINE,
		 v_detail_line_index,
		 qp_preq_grp.G_STATUS_NEW,
		 p_line_index,		-- begin shu, fix 2491158, missing data in qp_npreq_rltd_lines_tmp
		 m.line_index,
		 p_list_line_id,
		 i.list_line_id,
		 i.list_line_type_code,
		 i.arithmetic_operator,
		 i.operand,
		 m.line_quantity	-- end shu, fix 2491158, missing data in qp_npreq_rltd_lines_tmp
		 );
		 -- shu, end fix bug 2491158
	    END LOOP;

	    -- This is the code to delete the OID lines which do not have adjustments/benefits even thou
	    -- x_qualifier_flag=TRUE

	--Begin Bug No: 7323590
	/* commented out for bug No: 7323590
	    IF (v_benefit_exists = FALSE) THEN
     	        UPDATE qp_npreq_ldets_tmp --upd2
		SET PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_OTHER_ITEM_BENEFITS
		WHERE PRICING_PHASE_ID = p_pricing_phase_id
		AND   LINE_INDEX = p_line_index
		AND   CREATED_FROM_LIST_LINE_ID = p_list_line_id
		AND   PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW;

                -- This statement is not needed
		/* UPDATE qp_npreq_line_attrs_tmp
		SET PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_OTHER_ITEM_BENEFITS
		WHERE LINE_INDEX = p_line_index
		AND   LIST_LINE_ID = p_list_line_id
		AND   PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW;
	    END IF;
	*/ -- commenting end
	--End Bug No: 7323590
       END IF;
      END LOOP;
     END LOOP;
     qp_preq_grp.G_LINE_DETAIL_INDEX := v_detail_line_index;
  EXCEPTION
    WHEN OTHERS  THEN
    IF l_debug = FND_API.G_TRUE THEN
    qp_preq_grp.engine_debug(v_routine_name || ' ' || SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_txt := v_routine_name || ' ' || SQLERRM;
    IF l_debug = FND_API.G_TRUE THEN
    qp_preq_grp.engine_debug(SQLERRM);
    END IF;
  END Process_OID;

  PROCEDURE Find_Qualification_For_Benefit(p_line_index         NUMBER,
                                           p_list_line_id       NUMBER,
                                           p_rltd_modifier_type VARCHAR2,
                                           p_list_line_type     VARCHAR2,
                                           x_qualified_flag     OUT NOCOPY BOOLEAN,
                                           x_return_status      OUT NOCOPY VARCHAR2,
                                           x_return_status_txt  OUT NOCOPY VARCHAR2) AS

    CURSOR no_rltd_modifiers_in_grp_cur IS
    SELECT RLTD_MODIFIER_GRP_NO,COUNT(*) NO_OF_MODIFIERS_IN_GRP
    FROM   QP_RLTD_MODIFIERS
    WHERE  FROM_RLTD_MODIFIER_ID = p_list_line_id
    AND    RLTD_MODIFIER_GRP_TYPE = p_rltd_modifier_type
    GROUP BY RLTD_MODIFIER_GRP_NO;

    CURSOR rltd_modifiers_cur(p_rltd_grp_no NUMBER) IS
    SELECT a.LIST_LINE_TYPE_CODE , b.TO_RLTD_MODIFIER_ID
    FROM   QP_LIST_LINES a , QP_RLTD_MODIFIERS b
    WHERE  a.LIST_LINE_ID = b.FROM_RLTD_MODIFIER_ID
    AND    b.FROM_RLTD_MODIFIER_ID = p_list_line_id
    AND    b.RLTD_MODIFIER_GRP_TYPE = p_rltd_modifier_type
    AND    b.RLTD_MODIFIER_GRP_NO = p_rltd_grp_no;

    -- bug# 2748723 buy line and additional buy lines should belong to same
    -- line category
    CURSOR check_rltd_mods_passed_cur(p_rltd_modifier_id NUMBER) IS
    -- 10g/R12 performance fixes for 5573393
    SELECT distinct c.LIST_LINE_ID
    FROM   QP_PRICING_ATTRIBUTES c
    WHERE  c.LIST_LINE_ID = p_rltd_modifier_id
    AND    c.PRICING_ATTRIBUTE_CONTEXT IS NULL
    AND EXISTS
           (SELECT /*+ ORDERED NO_UNNEST index(b qp_preq_line_attrs_tmp_n2)
                       index(a qp_preq_lines_tmp_u1)
                       index(d qp_preq_lines_tmp_u1) */ 'X'
            FROM   qp_npreq_line_attrs_tmp b,
                   qp_npreq_lines_tmp a,
                   qp_npreq_lines_tmp d
            WHERE  b.CONTEXT = c.PRODUCT_ATTRIBUTE_CONTEXT
            AND    b.ATTRIBUTE = c.PRODUCT_ATTRIBUTE
            AND    b.VALUE_FROM = c.PRODUCT_ATTR_VALUE
            AND    b.ATTRIBUTE_TYPE = qp_preq_grp.G_PRODUCT_TYPE
            AND    b.PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_UNCHANGED
            AND    a.LINE_INDEX = b.LINE_INDEX
            AND    a.LINE_TYPE_CODE = QP_PREQ_GRP.G_LINE_LEVEL
            AND    instr(a.PROCESS_STATUS, QP_PREQ_PUB.G_FREEGOOD) = 0 -- bug 3006670
            AND    a.PRICED_UOM_CODE = nvl(c.PRODUCT_UOM_CODE, a.PRICED_UOM_CODE)
            AND    d.LINE_INDEX = p_line_index
            AND    d.LINE_TYPE_CODE = QP_PREQ_GRP.G_LINE_LEVEL
            AND    nvl(d.LINE_CATEGORY,'ORDER') = nvl(a.LINE_CATEGORY,'ORDER'))
    UNION
    -- 10g/R12 performance fixes for 5573393
    SELECT distinct a.LIST_LINE_ID -- Index N7 can be replaced with N2
    FROM   QP_PRICING_ATTRIBUTES a
    WHERE  a.LIST_LINE_ID = p_rltd_modifier_id
    AND EXISTS
           (SELECT /*+ ORDERED NO_UNNEST index(b qp_preq_line_attrs_n2)
                       index(d qp_preq_lines_tmp_u1)
                       index(c qp_preq_line_attrs_tmp_n2)
                       index(e qp_preq_lines_tmp_u1) */ 'X'
            FROM   qp_npreq_line_attrs_tmp b,
                   qp_npreq_lines_tmp d,
                   qp_npreq_line_attrs_tmp c,
                   qp_npreq_lines_tmp e
            WHERE  b.CONTEXT = a.PRODUCT_ATTRIBUTE_CONTEXT
            AND    b.ATTRIBUTE = a.PRODUCT_ATTRIBUTE
            AND    b.VALUE_FROM = a.PRODUCT_ATTR_VALUE
            AND    b.ATTRIBUTE_TYPE = qp_preq_grp.G_PRODUCT_TYPE
            AND    b.PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_UNCHANGED
            AND    d.PRICED_UOM_CODE = nvl(a.PRODUCT_UOM_CODE, d.PRICED_UOM_CODE)
            AND    d.LINE_INDEX = b.LINE_INDEX
            AND    d.LINE_TYPE_CODE = QP_PREQ_GRP.G_LINE_LEVEL
            AND    b.LINE_INDEX = c.LINE_INDEX
            AND    instr(d.PROCESS_STATUS, QP_PREQ_PUB.G_FREEGOOD) = 0 -- bug 3006670
            AND    c.CONTEXT = qp_preq_grp.G_PRIC_VOLUME_CONTEXT
            AND    c.CONTEXT = a.PRICING_ATTRIBUTE_CONTEXT
            AND    c.ATTRIBUTE = a.PRICING_ATTRIBUTE
            AND    qp_number.canonical_to_number(c.VALUE_FROM) BETWEEN
                   nvl(a.PRICING_ATTR_VALUE_FROM,qp_number.canonical_to_number(c.VALUE_FROM)) AND
                   nvl(a.PRICING_ATTR_VALUE_TO,qp_number.canonical_to_number(c.VALUE_FROM))
            AND    c.ATTRIBUTE_TYPE = qp_preq_grp.G_PRICING_TYPE
            AND    c.PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_UNCHANGED
            AND    e.LINE_INDEX = p_line_index
            AND    e.LINE_TYPE_CODE = QP_PREQ_GRP.G_LINE_LEVEL
            AND    nvl(e.LINE_CATEGORY,'ORDER') = nvl(d.LINE_CATEGORY,'ORDER'));

    v_count               NUMBER := 0;
    v_qualified_flag      BOOLEAN := FALSE;
    v_to_rltd_modifier_id NUMBER;
    v_no_of_mods_in_grp   NUMBER := 0;

    v_update_flag         BOOLEAN := FALSE;
    v_routine_name        CONSTANT VARCHAR2(240):='Routine:QP_Process_Other_Benefits.Find_Qualification_For_Benefit';
  BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

   IF (p_rltd_modifier_type  = qp_preq_grp.G_QUALIFIER_TYPE) THEN -- Do group checking

    IF l_debug = FND_API.G_TRUE THEN
     qp_preq_grp.engine_debug('QUALIFIER QUALIFICATION');
    END IF;

    FOR i IN no_rltd_modifiers_in_grp_cur
    LOOP
     IF l_debug = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('Group no: ' || i.RLTD_MODIFIER_GRP_NO);
     END IF;

     v_count := 0; --satisfied group cnt re-init on group change -- #2725979

     FOR j IN rltd_modifiers_cur(i.RLTD_MODIFIER_GRP_NO)
     LOOP
      IF l_debug = FND_API.G_TRUE THEN
       qp_preq_grp.engine_debug('To Modifier Id: ' || j.TO_RLTD_MODIFIER_ID);
      END IF;

      FOR k IN check_rltd_mods_passed_cur(j.TO_RLTD_MODIFIER_ID)
      LOOP
       IF l_debug = FND_API.G_TRUE THEN
        qp_preq_grp.engine_debug('Qualification Succeeded for Rltd Modifier:' || j.TO_RLTD_MODIFIER_ID ||
                                 k.list_line_id);
       END IF;

       IF(j.TO_RLTD_MODIFIER_ID = k.LIST_LINE_ID) THEN
         v_count := v_count + 1;
       END IF;

      END LOOP; --k
     END LOOP; --j

     v_no_of_mods_in_grp := i.NO_OF_MODIFIERS_IN_GRP; -- Store the no of modifiers count

     IF l_debug = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('No of modifiers in grp :' || v_no_of_mods_in_grp);
      qp_preq_grp.engine_debug('Count :' || v_count);
     END IF;

     IF(v_no_of_mods_in_grp = v_count) THEN
        v_qualified_flag := TRUE;
        v_update_flag := FALSE;
     ELSE
        v_qualified_flag := FALSE;
        v_update_flag := TRUE;
     END IF;
     x_qualified_flag := v_qualified_flag;
     EXIT WHEN (v_qualified_flag = TRUE); -- What will happen to other groups , once 1 group is valid
    END LOOP; --i

    -- This is the case wherin there is no QUALIFIER Record .. Ex: Buy A , get 20% of B.There is
    -- only BENEFIT line

    IF (v_no_of_mods_in_grp = 0  and v_count = 0 ) THEN
     IF l_debug = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug(v_no_of_mods_in_grp);
      qp_preq_grp.engine_debug(v_count);
     END IF;
     x_qualified_flag := TRUE;
    END IF;
   ELSE -- Benefit -- If there on the order give it

    IF l_debug = FND_API.G_TRUE THEN
     qp_preq_grp.engine_debug('BENEFIT QUALIFICATION');
    END IF;

    FOR k IN check_rltd_mods_passed_cur(p_list_line_id)
    LOOP
     IF l_debug = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('Passed List line id:' || p_list_line_id);
      qp_preq_grp.engine_debug('Matching List Line Id:' || k.list_line_id);
     END IF;

     IF(k.LIST_LINE_ID = p_list_line_id) THEN
      v_count := v_count + 1;
     END IF;
    END LOOP; --k

    IF (v_count > 0) THEN
     v_qualified_flag := TRUE;
     v_update_flag := FALSE;
    ELSE
     v_qualified_flag := FALSE;
     v_update_flag := TRUE;
    END IF;
    x_qualified_flag := v_qualified_flag;
   END IF;

   IF l_debug = FND_API.G_TRUE THEN
    qp_preq_grp.engine_debug('Benefit Record Count:' || v_count);
   END IF;

   IF (v_update_flag = TRUE) THEN
    UPDATE qp_npreq_ldets_tmp --upd1
    SET    PRICING_STATUS_CODE =  qp_preq_grp.G_STATUS_OTHER_ITEM_BENEFITS
    WHERE  CREATED_FROM_LIST_LINE_ID = p_list_line_id;

     -- This statement is not needed
     /* UPDATE qp_npreq_line_attrs_tmp a
        SET    a.PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_OTHER_ITEM_BENEFITS
        WHERE a.LINE_DETAIL_INDEX IN (SELECT b.LINE_DETAIL_INDEX
                                      FROM qp_npreq_ldets_tmp b
                                      WHERE b.CREATED_FROM_LIST_LINE_ID = p_list_line_id); */

    IF l_debug = FND_API.G_TRUE THEN
     qp_preq_grp.engine_debug ('BENEFIT STATUS UPDATED');
    END IF;
   END IF;
   --v_count := 0; -- Reinitialize for each grp(done on change of group earlier)
  EXCEPTION
    WHEN OTHERS  THEN
    IF l_debug = FND_API.G_TRUE THEN
    qp_preq_grp.engine_debug(v_routine_name || ' ' || SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_txt := v_routine_name || ' ' || SQLERRM;
   IF l_debug = FND_API.G_TRUE THEN
   qp_preq_grp.engine_debug ('Error in Proc');
   END IF;
  END Find_Qualification_For_Benefit;

  PROCEDURE Process_Other_Benefits(p_line_index                    NUMBER,
                                   p_pricing_phase_id              NUMBER,
                                   p_pricing_effective_date        DATE,
                                   p_line_quantity                 NUMBER,
                                   p_simulation_flag               VARCHAR2,
                                   x_return_status     OUT NOCOPY  VARCHAR2,
                                   x_return_status_txt OUT NOCOPY  VARCHAR2) AS


  CURSOR get_list_lines_cur IS
  SELECT /*+ index (ldets qp_preq_ldets_tmp_N2) */
  CREATED_FROM_LIST_LINE_ID,CREATED_FROM_LIST_LINE_TYPE,LINE_DETAIL_INDEX , MODIFIER_LEVEL_CODE
  FROM   qp_npreq_ldets_tmp ldets
  WHERE  CREATED_FROM_LIST_LINE_TYPE IN (qp_preq_grp.G_OTHER_ITEM_DISCOUNT, qp_preq_grp.G_PROMO_GOODS_DISCOUNT,
                                         qp_preq_grp.G_COUPON_ISSUE)
  AND    PRICING_PHASE_ID = p_pricing_phase_id
  AND    LINE_INDEX = p_line_index
  AND    ASK_FOR_FLAG IN (qp_preq_grp.G_YES,qp_preq_grp.G_NO)
  AND    PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW;

  x_qualifier_flag BOOLEAN;

  v_routine_name   CONSTANT VARCHAR2(240) := 'Routine:QP_Process_Other_Benefits.Process_Other_Benefits';
  x_ret_status     VARCHAR2(30);
  x_ret_status_txt VARCHAR2(240);

  BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

   FOR i IN get_list_lines_cur
   LOOP

    IF l_debug = FND_API.G_TRUE THEN
     qp_preq_grp.engine_debug('Qualifying List Line Id: ' || i.CREATED_FROM_LIST_LINE_ID);
     qp_preq_grp.engine_debug('List Line Type: ' || i.CREATED_FROM_LIST_LINE_TYPE);
    END IF;

    Find_Qualification_For_Benefit(p_line_index,
                                   i.CREATED_FROM_LIST_LINE_ID,
                                   qp_preq_grp.G_QUALIFIER_TYPE,
                                   i.CREATED_FROM_LIST_LINE_TYPE,
                                   x_qualifier_flag,
                                   x_ret_status,
                                   x_ret_status_txt);

    IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
	 RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (x_qualifier_flag = TRUE) THEN
     IF l_debug = FND_API.G_TRUE THEN
      qp_preq_grp.engine_debug('QUALIFICATION SUCCEDED');
      qp_preq_grp.engine_debug('List Line Type : ' || i.created_from_list_line_type);
     END IF;
     IF (i.CREATED_FROM_LIST_LINE_TYPE = qp_preq_grp.G_OTHER_ITEM_DISCOUNT) THEN
      Process_OID(p_line_index,i.CREATED_FROM_LIST_LINE_ID,p_pricing_phase_id,x_ret_status,x_ret_status_txt);
      IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
      END IF;
     ELSIF (i.CREATED_FROM_LIST_LINE_TYPE = qp_preq_grp.G_PROMO_GOODS_DISCOUNT) THEN
      Process_PRG(p_line_index,i.line_detail_index,i.modifier_level_code,i.CREATED_FROM_LIST_LINE_ID,
                  p_pricing_phase_id,x_ret_status,x_ret_status_txt);
      IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
      END IF;
     ELSIF (i.CREATED_FROM_LIST_LINE_TYPE = qp_preq_grp.G_COUPON_ISSUE)
     AND (qp_preq_grp.G_PUBLIC_API_CALL_FLAG = qp_preq_grp.G_NO
      or (qp_preq_grp.G_PUBLIC_API_CALL_FLAG = qp_preq_grp.G_YES --bug 3859759
          and qp_preq_grp.G_TEMP_TABLE_INSERT_FLAG = qp_preq_grp.G_YES)) THEN
           QP_COUPON_PVT.PROCESS_COUPON_ISSUE(i.line_detail_index,
                                              p_pricing_phase_id,
                                              p_line_quantity,
                                              p_simulation_flag,
                                              x_ret_status,
                                              x_ret_status_txt);

           IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
           END IF;

          /* redeem coupon should not be called here.  Because coupon benefits could be of
             any type, moved to qp_preq_grp package
          QP_COUPON_PVT.REDEEM_COUPONS(p_simulation_flag, x_ret_status, x_ret_status_txt);

          IF(x_ret_status = FND_API.G_RET_STS_ERROR) THEN
		 RAISE FND_API.G_EXC_ERROR;
    	     END IF;
          */

     END IF;
    ELSE
     UPDATE qp_npreq_ldets_tmp --upd1
     SET PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_OTHER_ITEM_BENEFITS
     WHERE PRICING_PHASE_ID = p_pricing_phase_id
     AND   LINE_INDEX = p_line_index
     AND   CREATED_FROM_LIST_LINE_ID = i.CREATED_FROM_LIST_LINE_ID
     AND   PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW;

     -- This statement is not needed
     /* UPDATE qp_npreq_line_attrs_tmp
        SET PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_OTHER_ITEM_BENEFITS
        WHERE LIST_LINE_ID = i.CREATED_FROM_LIST_LINE_ID
        AND   PRICING_STATUS_CODE = qp_preq_grp.G_STATUS_NEW; */
    END IF;
   END LOOP;
  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    IF l_debug = FND_API.G_TRUE THEN
    qp_preq_grp.engine_debug(v_routine_name || ' ' || x_ret_status_txt);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_txt := x_ret_status_txt;
   WHEN OTHERS  THEN
    IF l_debug = FND_API.G_TRUE THEN
    qp_preq_grp.engine_debug(v_routine_name || ' ' || SQLERRM);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_status_txt := v_routine_name || ' ' || SQLERRM;
  END Process_Other_Benefits;
END QP_Process_Other_Benefits_PVT;

/
