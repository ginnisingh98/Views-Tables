--------------------------------------------------------
--  DDL for Package Body QP_RESOLVE_INCOMPATABILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_RESOLVE_INCOMPATABILITY_PVT" AS
/* $Header: QPXVINCB.pls 120.14.12010000.5 2009/04/09 04:39:38 smuhamme ship $ */

 L_PRICE_LIST_PHASE_ID    CONSTANT NUMBER := 1;
 l_debug VARCHAR2(3) ;

 FUNCTION Precedence_For_List_Line(p_list_header_id NUMBER,
                                   p_list_line_id   NUMBER,
                                   p_incomp_grp_id  VARCHAR2,
                                   p_line_index	    NUMBER,
                                   p_pricing_phase_id NUMBER)
   RETURN NUMBER IS

   v_number number;

   V_QUALIFIER_TYPE 	CONSTANT VARCHAR2(240) := 'QUALIFIER';
/*

INDX,QP_Resolve_Incompatability_PVTRUN.precedence_for_list_line.precedence_for_line_cur,qp_npreq_line_attrs_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.precedence_for_list_line.precedence_for_line_cur,qp_npreq_line_attrs_tmp_N1,ATTRIBUTE_TYPE,2
INDX,QP_Resolve_Incompatability_PVTRUN.precedence_for_list_line.precedence_for_line_cur,qp_npreq_line_attrs_tmp_N1,PRICING_STATUS_CODE,3
INDX,QP_Resolve_Incompatability_PVTRUN.precedence_for_list_line.precedence_for_line_cur,qp_npreq_line_attrs_tmp_N1,LIST_HEADER_ID,4
INDX,QP_Resolve_Incompatability_PVTRUN.precedence_for_list_line.precedence_for_line_cur,qp_npreq_line_attrs_tmp_N1,LIST_LINE_ID,5

UNION
INDX,QP_Resolve_Incompatability_PVTRUN.precedence_for_list_line.precedence_for_line_cur,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.precedence_for_list_line.precedence_for_line_cur,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.precedence_for_list_line.precedence_for_line_cur,qp_npreq_ldets_tmp_N1,PRICING_PHASE_ID,3
INDX,QP_Resolve_Incompatability_PVTRUN.precedence_for_list_line.precedence_for_line_cur,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_HEADER_ID,4
INDX,QP_Resolve_Incompatability_PVTRUN.precedence_for_list_line.precedence_for_line_cur,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5

*/
--Precedence for line cur
-- Pricing Phase Change
   CURSOR precedence_for_line_cur IS
    SELECT nvl(a.QUALIFIER_PRECEDENCE,5000) PRECED
    FROM   qp_npreq_line_attrs_tmp a
    WHERE  a.LIST_LINE_ID = p_list_line_id
    AND    a.LIST_HEADER_ID = p_list_header_id
    AND    a.ATTRIBUTE_TYPE = 'QUALIFIER'
    AND    a.INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
    AND    a.PRICING_PHASE_ID = p_pricing_phase_id
    AND    a.PRICING_STATUS_CODE = 'N'
    AND    a.LINE_INDEX = p_line_index
    UNION
    SELECT nvl(a.PRODUCT_PRECEDENCE,5000) PRECED
    FROM   qp_npreq_ldets_tmp a
    WHERE  a.CREATED_FROM_LIST_LINE_ID = p_list_line_id
    AND    a.CREATED_FROM_LIST_HEADER_ID = p_list_header_id
    AND    a.INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
    AND    a.PRICING_PHASE_ID = p_pricing_phase_id
    AND    a.PRICING_STATUS_CODE = 'N'
    AND    a.LINE_INDEX = p_line_index
    ORDER BY 1;

 BEGIN

    OPEN precedence_for_line_cur;
    FETCH precedence_for_line_cur INTO v_number;
    CLOSE precedence_for_line_cur;

    RETURN v_number;

 END Precedence_For_List_Line;

 -- Used only for precedence processing of price list lines
 PROCEDURE Precedence_For_Price_List_Line(p_line_index	    NUMBER,
                                          p_order_uom_code  VARCHAR2,
                                          p_primary_uom_flag  VARCHAR2,
                                          x_precedence_tbl  OUT NOCOPY precedence_tbl_type,
                                          x_return_status   OUT NOCOPY VARCHAR2,
                                          x_return_status_text OUT NOCOPY VARCHAR2) IS


   CURSOR get_product_details_cur(p_list_line_id number) IS
   SELECT product_uom_code,attribute,value_from inventory_item_id
   FROM   qp_npreq_line_attrs_tmp a
   WHERE  a.LIST_LINE_ID = p_list_line_id
   AND    a.LINE_INDEX = p_line_index
   AND    a.ATTRIBUTE_TYPE = 'PRODUCT'
   AND    a.PRICING_PHASE_ID = 1
   AND    a.PRICING_STATUS_CODE = 'N';

   CURSOR get_inventory_item_id_cur(p_line_index NUMBER) IS
   SELECT value_from
   FROM   qp_npreq_line_attrs_tmp
   WHERE  line_index = p_line_index
   AND    attribute_type = QP_PREQ_GRP.G_PRODUCT_TYPE
   AND    context = 'ITEM'
   AND    attribute = 'PRICING_ATTRIBUTE1'
   AND    pricing_status_code = QP_PREQ_GRP.G_STATUS_UNCHANGED;

   l_product_uom_code VARCHAR2(30);
   l_attribute VARCHAR2(30);
   l_inventory_item_id VARCHAR2(30);
   l_list_line_id NUMBER;

   g_precedence_tbl QP_PREQ_GRP.NUMBER_TYPE;
   g_qual_precedence_tbl QP_PREQ_GRP.NUMBER_TYPE;
   g_list_line_id_tbl QP_PREQ_GRP.NUMBER_TYPE;
   v_number NUMBER;
   v_routine_name CONSTANT VARCHAR2(40) := 'Precedence_For_Price_List_Line';

   type refcur is ref cursor;

   l_precedence_for_line_cur    refcur;

   l_prev_precedence NUMBER := -9999;
   l_prev_qual_precedence NUMBER := -9999;
   v_counter NUMBER := 0;
   l_exit_status VARCHAR2(1) := 'F';
   nROWS number := 1000;

 BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

  IF (p_order_uom_code IS NOT NULL) THEN

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Opening Order Uom Cur : ' || p_order_uom_code);

    END IF;
    -- Method to derive QUAL_PRECED
    --In first select of 2 way UNION , there is a qualifier on primary price list , it will be -99999 as prim pl as high preced
    --In second select of 2 way UNION , if there is no secondary price list , so QUAL_PRECED is defaulted to -99999,since it is
    --coming from primary price list and not secondary price list and it should have more precedence

    -- shulin
    -- uom match comdition is added, when order_uom does not match product uom (uom conversion should happen)
    -- this cursor should not return list_line_id, which will cause UOM conversion not happening
    -- Bug 2490074 Join with qp_npreq_ldets_tmp is added in 1st part of union  to pick only undeleted lines.
    -- Bug 2687089 Commented exists and addded join with qp_npreq_line_attrs_tmp
    OPEN l_precedence_for_line_cur FOR
    SELECT distinct  nvl(a.QUALIFIER_PRECEDENCE,5000) PRECED  , a.LIST_LINE_ID , -99999  QUAL_PRECED
    FROM   qp_npreq_line_attrs_tmp a , qp_npreq_ldets_tmp c  , qp_npreq_line_attrs_tmp b
    WHERE  a.ATTRIBUTE_TYPE = 'QUALIFIER'
    AND    a.INCOMPATABILITY_GRP_CODE = 'EXCL'
    AND    a.PRICING_PHASE_ID = 1
    AND    a.PRICING_STATUS_CODE = 'N'
    AND    a.LINE_INDEX = p_line_index
    AND    b.PRICING_STATUS_CODE = 'N'
    AND    b.LINE_INDEX = p_line_index
    AND    b.INCOMPATABILITY_GRP_CODE = 'EXCL'
    AND    b.PRICING_PHASE_ID = 1
    AND    b.ATTRIBUTE_TYPE = QP_PREQ_GRP.G_PRODUCT_TYPE
    AND    b.PRODUCT_UOM_CODE = p_order_uom_code
    AND    b.LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE
    AND    b.list_line_id = a.LIST_LINE_ID
/*    AND    EXISTS (SELECT 'X'			-- uom match, shulin
                   FROM qp_npreq_line_attrs_tmp b
                   WHERE LINE_INDEX = p_line_index
                   AND   PRICING_STATUS_CODE = 'N'
                   AND   INCOMPATABILITY_GRP_CODE = 'EXCL'
                   AND   PRICING_PHASE_ID = 1
                   AND   ATTRIBUTE_TYPE = QP_PREQ_GRP.G_PRODUCT_TYPE
                   AND   PRODUCT_UOM_CODE = p_order_uom_code
                   AND   LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE
                   AND   a.LIST_LINE_ID = b.LIST_LINE_ID) */
    AND    a.LINE_DETAIL_INDEX = c.LINE_DETAIL_INDEX
    AND    c.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW

    UNION
    SELECT z.PRECED , z.LIST_LINE_ID , z.QUALIFIER_PRECEDENCE QUAL_PRECED
    FROM (
      SELECT /*+ ORDERED USE_NL(b) index(c qp_preq_line_attrs_tmp_N5) rec_exist_with_order_uom_cur */
           nvl(b.PRODUCT_PRECEDENCE,5000) PRECED  , c.LIST_LINE_ID , nvl(c.QUALIFIER_PRECEDENCE,-99999) QUALIFIER_PRECEDENCE
      FROM   qp_npreq_line_attrs_tmp c,qp_npreq_ldets_tmp b
      WHERE  c.PRICING_PHASE_ID = L_PRICE_LIST_PHASE_ID
      AND    c.PRODUCT_UOM_CODE = p_order_uom_code
      AND    c.ATTRIBUTE_TYPE = QP_PREQ_GRP.G_PRODUCT_TYPE
      AND    c.LINE_INDEX = p_line_index
      AND    c.INCOMPATABILITY_GRP_CODE = 'EXCL'
      AND    c.LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE
      AND    c.LINE_DETAIL_INDEX = b.LINE_DETAIL_INDEX
      AND    b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
      AND    c.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
      ORDER BY 3,1) z
     ORDER BY 3,1;
  ELSE

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Opening Primary Uom Cur');

    END IF;
	/* Modified cursor l_precedence_for_line_cur for 2780293 */
    OPEN l_precedence_for_line_cur FOR
    SELECT nvl(a.QUALIFIER_PRECEDENCE,5000) PRECED  , a.LIST_LINE_ID , -99999 QUAL_PRECED
    FROM   qp_npreq_line_attrs_tmp a, qp_npreq_ldets_tmp c, qp_npreq_line_attrs_tmp b
    WHERE  a.ATTRIBUTE_TYPE = 'QUALIFIER'
    AND    a.INCOMPATABILITY_GRP_CODE = 'EXCL'
    AND    a.PRICING_PHASE_ID = 1
    AND    a.PRICING_STATUS_CODE = 'N'
    AND    a.LINE_INDEX = p_line_index
    AND    b.PRICING_STATUS_CODE = 'N'
    AND    b.LINE_INDEX = p_line_index
    AND    b.INCOMPATABILITY_GRP_CODE = 'EXCL'
    AND    b.PRICING_PHASE_ID = 1
    AND    b.ATTRIBUTE_TYPE = QP_PREQ_GRP.G_PRODUCT_TYPE
    AND    b.PRIMARY_UOM_FLAG = QP_PREQ_GRP.G_YES
    AND    b.LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE
    AND    b.list_line_id = a.LIST_LINE_ID
    AND    a.LINE_DETAIL_INDEX = c.LINE_DETAIL_INDEX
    AND    c.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW


    UNION
    SELECT z.PRECED  , z.LIST_LINE_ID , z.QUALIFIER_PRECEDENCE QUAL_PRECED
    FROM(
      SELECT /*+ ORDERED USE_NL(c d) index(b qp_preq_line_attrs_tmp_N5) rec_exist_with_pri_flag_cur */
          nvl(c.PRODUCT_PRECEDENCE,5000) PRECED   , b.LIST_LINE_ID , nvl(b.QUALIFIER_PRECEDENCE ,-99999) QUALIFIER_PRECEDENCE
      FROM   qp_npreq_line_attrs_tmp b,qp_npreq_ldets_tmp c
      WHERE  b.PRIMARY_UOM_FLAG = QP_PREQ_GRP.G_YES
      AND    b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
      AND    b.CONTEXT = 'ITEM'
      AND    b.ATTRIBUTE_TYPE = QP_PREQ_GRP.G_PRODUCT_TYPE
      AND    b.LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE
      AND    b.INCOMPATABILITY_GRP_CODE = 'EXCL'
      AND    b.LINE_INDEX = p_line_index
      AND    b.PRICING_PHASE_ID = L_PRICE_LIST_PHASE_ID
      AND    c.LINE_DETAIL_INDEX = b.LINE_DETAIL_INDEX
      AND    c.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
      ORDER  BY 3,1) z
    ORDER BY 3,1;
  END IF;

LOOP -- Outer Main Loop

   g_precedence_tbl.delete;
   g_qual_precedence_tbl.delete;
   g_list_line_id_tbl.delete;

   FETCH l_precedence_for_line_cur BULK COLLECT INTO g_precedence_tbl,g_list_line_id_tbl,g_qual_precedence_tbl LIMIT nROWS;
   EXIT WHEN g_list_line_id_tbl.count = 0;

  IF (g_list_line_id_tbl.count > 0) THEN

   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug('List Line Table Count: ' || g_list_line_id_tbl.count);

   END IF;
   FOR j in g_list_line_id_tbl.first .. g_list_line_id_tbl.last -- Inner Loop
   LOOP

    IF (v_counter=0) THEN
     l_prev_precedence := g_precedence_tbl(j);
     l_prev_qual_precedence := g_qual_precedence_tbl(j);
    END IF;

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('High Qual Preced Is : ' || g_qual_precedence_tbl(j));
    QP_PREQ_GRP.engine_debug('High Prod Preced Is : ' || g_precedence_tbl(j) || ' List Line Id: ' || g_list_line_id_tbl(j));

    END IF;
    -- Load all list lines with same precedence and if different exit out
    -- On change of either qualifier and product precedence stop
    --Ex: Qual Preced :0 Prod Preced:220
    --    Qual Preced :0 Prod Preced:315 we should not process this record
    IF (l_prev_qual_precedence = g_qual_precedence_tbl(j) and l_prev_precedence = g_precedence_tbl(j)) THEN

       x_precedence_tbl(j).created_from_list_line_id := g_list_line_id_tbl(j);
       x_precedence_tbl(j).product_precedence := g_precedence_tbl(j);
       v_counter := v_counter + 1;

     IF (p_primary_uom_flag IS NOT NULL) THEN -- pri uom cur
        l_product_uom_code := NULL;
        OPEN get_product_details_cur(g_list_line_id_tbl(j));
        FETCH get_product_details_cur INTO l_product_uom_code,l_attribute,l_inventory_item_id;
        CLOSE get_product_details_cur;

        x_precedence_tbl(j).product_uom_code := l_product_uom_code;

      IF (l_attribute <> 'PRICING_ATTRIBUTE1') THEN
        l_inventory_item_id := NULL; -- Reset
        OPEN get_inventory_item_id_cur(p_line_index);
        FETCH get_inventory_item_id_cur INTO l_inventory_item_id;
        CLOSE get_inventory_item_id_cur;

        IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Attribute Is : ' || l_attribute);
        QP_PREQ_GRP.engine_debug('Inventory Item Id For Item Specific : ' || l_inventory_item_id);

        END IF;
       IF (l_inventory_item_id IS NULL) THEN
         IF l_debug = FND_API.G_TRUE THEN
         QP_PREQ_GRP.engine_debug('Could not find Item Specific. Doing generic conversion');
         END IF;
         x_precedence_tbl(j).inventory_item_id := 0;
       ELSE
         x_precedence_tbl(j).inventory_item_id := l_inventory_item_id;
       END IF;

      ELSE -- IF (l_attribute <> 'PRICING_ATTRIBUTE1')
        IF l_debug = FND_API.G_TRUE THEN
        QP_PREQ_GRP.engine_debug('Inventory Item Id For Item: ' || l_inventory_item_id);
        END IF;
        x_precedence_tbl(j).inventory_item_id := l_inventory_item_id;
      END IF; -- IF (l_attribute <> 'PRICING_ATTRIBUTE1')

     END IF; -- (p_primary_uom_flag IS NOT NULL)
    ELSE -- l_prev_precedence = g_precedence_tbl(j)
     IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('Exiting the inner loop after loading the higher precedence list lines');
     END IF;
     l_exit_status := 'T';
     EXIT;  -- Inner Loop
    END IF; -- l_prev_precedence = g_precedence_tbl(j)

   END LOOP;

   IF (l_exit_status = 'T') THEN
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Exiting the outer loop after loading the higher precedence list lines');
    END IF;
    EXIT; -- Outer Main Loop
   END IF;

  END IF; -- G_LIST_LINE_ID_TBL.COUNT > 0

END LOOP; -- Main Loop
CLOSE l_precedence_for_line_cur;

 IF (x_precedence_tbl.COUNT > 0) THEN
  FOR k in x_precedence_tbl.FIRST .. x_precedence_tbl.LAST
  LOOP
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug('PPL List Line Id : ' || x_precedence_tbl(k).created_from_list_line_id);
   QP_PREQ_GRP.engine_debug('PPL Precedence : '   || x_precedence_tbl(k).product_precedence);
   QP_PREQ_GRP.engine_debug('PPL Inventory Item Id: ' || x_precedence_tbl(k).inventory_item_id);
   QP_PREQ_GRP.engine_debug('PPL Product Uom : ' || x_precedence_tbl(k).product_uom_code);
   END IF;
  END LOOP;
 END IF;

 EXCEPTION
  WHEN OTHERS THEN
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug('In Routine Precedence_For_Price_List_Line : ' || SQLERRM);
   END IF;
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_return_status_text := v_routine_name || ' ' || SQLERRM;
 END Precedence_For_Price_List_Line;

Procedure sort_on_precedence(p_sorted_tbl in out Nocopy precedence_tbl_type) Is

h PLS_INTEGER:=1;
i PLS_INTEGER;
j PLS_INTEGER;
N PLS_INTEGER;

l_Sorted_Precedence_Rec		     precedence_rec_type;

Begin
N := p_sorted_tbl.count;
--DBMS_OUTPUT.PUT_LINE('Determining h step size...');

 For k in 1..N Loop
  h:= h*3 + 1;
  exit when h*3 + 1 > N;
 End Loop;

 --DBMS_OUTPUT.PUT_LINE('h: '||h);

 For k in 1..h Loop
  --DBMS_OUTPUT.PUT_LINE('h2:'||h);
  i:= h + 1;
   For i in h+1..N Loop
    l_Sorted_Precedence_Rec := p_sorted_tbl(i);
    j:=i;
    While ((j > h) and (nvl(p_sorted_tbl(j-h).product_precedence, -1) > nvl(l_Sorted_Precedence_Rec.product_precedence,-1)))
    Loop
	p_sorted_tbl(j) := p_sorted_tbl(j-h);
     j:=j-h;
    End Loop;
	p_sorted_tbl(j):=l_Sorted_Precedence_Rec;
   End Loop;
  h:= h/3;
  Exit When h < 1;
 End Loop;

End sort_on_precedence;


 PROCEDURE Update_Invalid_List_Lines(p_incomp_grp_code VARCHAR2,
							  p_line_index NUMBER,
							  p_pricing_phase_id NUMBER,
							  p_status_code VARCHAR2,
                                                          p_status_text VARCHAR2,
							  x_return_status OUT NOCOPY VARCHAR2,
							  x_return_status_text OUT NOCOPY VARCHAR2) AS

   v_routine_name CONSTANT VARCHAR2(240):='Routine:QP_Resolve_Incompatability_PVTRUN.Update_Invalid_List_Lines';
 BEGIN

/*
INDX,QP_Resolve_Incompatability_PVTRUN.update_invalid_list_lines.upd1,qp_npreq_lines_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.update_invalid_list_lines.upd2,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/

  IF p_status_code  IN (QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST,QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV) THEN
   UPDATE qp_npreq_lines_tmp -- upd1
   SET PRICING_STATUS_CODE = p_status_code,
       PRICING_STATUS_TEXT = p_status_text,
       PROCESSED_CODE = NULL -- To prevent big search from hapenning , if failed in mini search due to above reasons
   WHERE LINE_INDEX = p_line_index;
  ELSIF (p_status_code = QP_PREQ_GRP.G_STATUS_INVALID_UOM) THEN
   UPDATE qp_npreq_lines_tmp -- upd2
   SET PROCESSED_CODE = QP_PREQ_GRP.G_STS_LHS_NOT_FOUND,
       PRICING_STATUS_CODE = p_status_code,
       PRICING_STATUS_TEXT = p_status_text
   WHERE LINE_INDEX = p_line_index;
  END IF;

/*
INDX,QP_Resolve_Incompatability_PVTRUN.update_invalid_list_lines.upd3,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.update_invalid_list_lines.upd3,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.update_invalid_list_lines.upd3,qp_npreq_ldets_tmp_N1,PRICING_PHASE_ID,3
*/

  UPDATE qp_npreq_ldets_tmp -- upd3
  SET PRICING_STATUS_CODE = p_status_code
  WHERE INCOMPATABILITY_GRP_CODE = p_incomp_grp_code
  AND   LINE_INDEX = p_line_index
  AND   PRICING_PHASE_ID = p_pricing_phase_id
  AND   PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;

  /* UPDATE qp_npreq_line_attrs_tmp a
  SET    a.PRICING_STATUS_CODE = p_status_code
  WHERE  a.LIST_LINE_ID
   IN (SELECT b.CREATED_FROM_LIST_LINE_ID
        FROM  qp_npreq_ldets_tmp b
        WHERE b.PRICING_STATUS_CODE = p_status_code
        AND   b.PRICING_PHASE_ID = p_pricing_phase_id
        AND   b.INCOMPATABILITY_GRP_CODE = p_incomp_grp_code
        AND   b.LINE_INDEX = p_line_index)
	AND    a.LINE_INDEX = p_line_index;  */

 EXCEPTION
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   x_return_status_text := v_routine_name || ' ' || SQLERRM;
 END Update_Invalid_List_lines;


 PROCEDURE Determine_Pricing_UOM_And_Qty(p_line_index            NUMBER,
					 p_order_uom_code        VARCHAR2,
					 p_order_qty             NUMBER,
					 p_pricing_phase_id      NUMBER,
                                         p_call_big_search       BOOLEAN,
					 x_list_line_id	   OUT NOCOPY NUMBER,
					 x_return_status     OUT NOCOPY VARCHAR2,
					 x_return_status_txt OUT NOCOPY VARCHAR2) IS

/*
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.incomp_cur,qp_npreq_ldets_tmp_N2,PRICING_PHASE_ID,1
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.incomp_cur,qp_npreq_ldets_tmp_N2,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.incomp_cur,qp_npreq_lines_tmp_N2,LINE_INDEX,3
*/
--shulin bug 1829731, add contract_start_date, contract_end_date
--[julin/pricebook] added hint for qp_npreq_ldets_tmp
   CURSOR incomp_cur IS
   SELECT /*+ ORDERED USE_NL(a) INDEX(a QP_PREQ_LDETS_TMP_N2) */
   DISTINCT a.LINE_INDEX , a.INCOMPATABILITY_GRP_CODE ,a.PRICING_STATUS_CODE,b.LINE_UOM_CODE,b.LINE_QUANTITY,
            b.PROCESSING_ORDER,b.UOM_QUANTITY, b.CONTRACT_START_DATE, b.CONTRACT_END_DATE
   FROM   qp_npreq_lines_tmp b , qp_npreq_ldets_tmp a
   WHERE  a.INCOMPATABILITY_GRP_CODE IS NOT NULL
   AND    a.PRICING_PHASE_ID = p_pricing_phase_id
   AND    a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
   AND    a.LINE_INDEX = b.LINE_INDEX
   --AND    b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_UNCHANGED
   ORDER  BY a.LINE_INDEX;

/*
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.get_attribute_count_cur,qp_npreq_line_attrs_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.get_attribute_count_cur,qp_npreq_line_attrs_tmp_N1,ATTRIBUTE_TYPE,2
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.get_attribute_count_cur,qp_npreq_line_attrs_tmp_N1,PRICING_STATUS_CODE,3
*/

   CURSOR get_attribute_count_cur(p_line_index NUMBER , p_list_line_id NUMBER) IS
   SELECT COUNT(*) ATTRIBUTE_COUNT
   FROM   qp_npreq_line_attrs_tmp
   WHERE  LIST_LINE_ID = p_list_line_id
   AND    LINE_INDEX = p_line_index
   AND    ATTRIBUTE_TYPE = QP_PREQ_GRP.G_PRICING_TYPE
   AND    PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;



   v_list_line_id 	       NUMBER;
   v_price_list            VARCHAR2(240);
   v_list_precedence       NUMBER;
   v_primary_uom_code      VARCHAR2(30);
   v_pricing_qty           NUMBER;
   v_inventory_item_id     NUMBER;
   v_uom_rate		       NUMBER;
   v_dup_list_line_id	  NUMBER;
   v_dup_price_list            VARCHAR2(240);
   v_old_precedence        NUMBER;
   v_count 			  NUMBER := 0;
   v_return_status         VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
   v_return_msg		  VARCHAR2(240);
   v_precedence            NUMBER;
   v_counter               NUMBER := 0;
   l_id                    VARCHAR2(30);
   l_status                VARCHAR2(30);
   v_return_status_text    VARCHAR2(200);
   v_list_line_count1      NUMBER;
   v_list_line_count2      NUMBER;
   l_order_uom_code        VARCHAR2(30);
   v_total_count           NUMBER;

   l_validate_qty_rtn_status varchar2(1):= NULL;
   l_output_qty number;
   l_primary_qty number;

   -- shulin bug 1781829 fix
   l_max_decimal_digits PLS_INTEGER := nvl(FND_PROFILE.Value ('QP_INV_DECIMAL_PRECISION'),10);

   --begin shulin bug 1829731, add profile qp_time_uom_conversion
   --l_qp_time_uom_conversion := nvl(FND_PROFILE.Value('QP_TIME_UOM_CONVERSION'), 'STANDARD');
   l_qp_time_uom_conversion VARCHAR2(20) := 'STANDARD'; --jhkuo
   l_oks_qty NUMBER := NULL;
   l_uom_quantity NUMBER := NULL;
   l_sql_stmt varchar2(240) := NULL;
   l_order_qty NUMBER := NULL; -- shu_latest
   -- end shulin bug 1829731
   l_date_passed VARCHAR2(5) := null;
   --introduced for calculating unit_price for service items
   --detailed description of changes in bug 4900095
   l_duration_passed VARCHAR2(1) := null;

   l_precedence_tbl precedence_tbl_type;

   l_old_line_index        NUMBER := -9999;

   v_routine_name CONSTANT VARCHAR2(240):='Routine:QP_Resolve_Incompatability_PVTRUN.Determine_Pricing_UOM_And_Qty';

   l_line_quantity_tbl     QP_PREQ_GRP.NUMBER_TYPE;
   l_line_index_tbl        QP_PREQ_GRP.NUMBER_TYPE;
   l_line_uom_code_tbl     QP_PREQ_GRP.VARCHAR_TYPE;
   l_priced_quantity_tbl   QP_PREQ_GRP.NUMBER_TYPE; --shu_latest
   l_uom_quantity_tbl      QP_PREQ_GRP.NUMBER_TYPE; --shu_latest
   l_order_quantity_tbl    QP_PREQ_GRP.NUMBER_TYPE; --shu_latest
   l_upd_line_index_tbl    QP_PREQ_GRP.NUMBER_TYPE; -- 3773652
   l_upd_priced_qty_tbl    QP_PREQ_GRP.NUMBER_TYPE; -- 3773652

   l_line_quantity_tbl_m   QP_PREQ_GRP.NUMBER_TYPE;
   l_line_index_tbl_m      QP_PREQ_GRP.NUMBER_TYPE;
   l_line_uom_code_tbl_m   QP_PREQ_GRP.VARCHAR_TYPE;
   l_priced_quantity_tbl_m   QP_PREQ_GRP.NUMBER_TYPE; --shu_latest
   l_uom_quantity_tbl_m      QP_PREQ_GRP.NUMBER_TYPE; --shu_latest
   l_order_quantity_tbl_m    QP_PREQ_GRP.NUMBER_TYPE; --shu_latest

   m                       PLS_INTEGER := 1;
   n                       PLS_INTEGER := 1; -- 3773652
   l_list_header_id        NUMBER := -9999;
   lx_list_header_id       NUMBER := -9999;
   l_status_text           VARCHAR2(500); --Increased length from 240 to 500 for  3103800
   l_inventory_item_id     NUMBER;
   x_precedence_tbl        precedence_tbl_type;

   -- [julin/4330147/4335995]
   l_uom_conv_success VARCHAR2(1);

   INVALID_UOM		       EXCEPTION;
   DUPLICATE_PRICE_LIST    EXCEPTION;
   INVALID_UOM_CONVERSION  EXCEPTION;

 BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug( 'Determine_Pricing_UOM');

  QP_PREQ_GRP.engine_debug( 'After Determine_Pricing_UOM');
  QP_PREQ_GRP.engine_debug( 'Pricing Phase Id:'|| p_pricing_phase_id);

  END IF;
  -- shulin
  --IF l_debug = FND_API.G_TRUE THEN
  --QP_PREQ_GRP.engine_debug('QP_TIME_UOM_CONVERSION Profile Setting: ' ||l_qp_time_uom_conversion);
  --END IF;

  FOR i IN incomp_cur
  LOOP

  -- [julin/4330147/4335995]
  l_uom_conv_success := 'Y';

  IF (l_old_line_index <> i.line_index) THEN
   l_precedence_tbl.delete;
   v_count := 0;
   v_list_line_id := NULL;
   l_list_header_id := -9999;
   lx_list_header_id := -9999;
   l_order_uom_code := i.line_uom_code;
   l_old_line_index := i.line_index;
   v_pricing_qty := NULL; -- shulin
   l_oks_qty := NULL; --shulin
   l_uom_quantity := NULL; -- shulin
   l_sql_stmt := NULL; -- shulin
   l_order_qty := i.line_quantity; --shu_latest
  END IF;

  v_counter := 0;
  --m := 1;

   --jhkuo, discontinue profile use for partial period pricing of service items
   IF (i.contract_start_date IS NOT NULL AND i.contract_end_date IS NOT NULL)
   OR i.uom_quantity IS NOT NULL THEN
     l_qp_time_uom_conversion := 'ORACLE_CONTRACTS';
     IF i.uom_quantity IS NOT NULL THEN
       --bug 4900095
       l_duration_passed := 'Y';
     ELSE
       --bug 4900095
       l_duration_passed := 'N';
     END IF;
   ELSE
     l_date_passed := 'NOT ';
     l_qp_time_uom_conversion := 'STANDARD';
       --bug 4900095
     l_duration_passed := 'N';
   END IF;
   IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('Constract start/end dates '||
                               l_date_passed||
                               'passed in ==> qp_time_uom_conversion = '||
                               l_qp_time_uom_conversion);
   END IF;

   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug( 'Determine_Pricing_UOM1');
   QP_PREQ_GRP.engine_debug( I.INCOMPATABILITY_GRP_CODE);
   QP_PREQ_GRP.engine_debug( 'Line Index:'|| i.line_index);

   END IF;
   Precedence_For_Price_List_Line(i.line_index,i.line_uom_code,NULL,l_precedence_tbl,l_status,l_status_text);

   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug( ' Debug Point #0');

   QP_PREQ_GRP.engine_debug('Count : ' || l_precedence_tbl.count);

   END IF;
   -- Sort the table(not needed as it would have only the price list lines with least precedence)
   /* IF (l_precedence_tbl.COUNT > 0 ) THEN
    --sort_on_precedence(l_precedence_tbl, l_precedence_tbl.FIRST, l_precedence_tbl.LAST);
    sort_on_precedence(l_precedence_tbl);
   END IF; */

  IF (l_precedence_tbl.COUNT > 0 ) THEN
   v_total_count := l_precedence_tbl.COUNT;
   v_count := 0;
   v_list_line_count1 := NULL;
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug( 'Precedence Table Count Line : '|| i.line_index ||' Cnt:'|| l_precedence_tbl.count);
   END IF;
   FOR j IN l_precedence_tbl.FIRST .. l_precedence_tbl.LAST
   LOOP
     IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug( 'Determine_Pricing_UOM2');
     END IF;
     IF (v_count = 0) THEN
      v_list_line_id := l_precedence_tbl(j).created_from_list_line_id;
      v_list_precedence := l_precedence_tbl(j).product_precedence;
     END IF;

     IF (v_count > 0 ) THEN

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug( 'Precedence 1 : '|| v_list_precedence);
      QP_PREQ_GRP.engine_debug( 'Precedence 2 : '|| l_precedence_tbl(j).product_precedence);

      END IF;
      -- If precedence matches match pricing attributes count
      IF (v_list_precedence = l_precedence_tbl(j).product_precedence) THEN

       --Reset
       v_list_line_count2 := NULL;

        IF (v_list_line_count1 IS NULL) THEN
	  OPEN get_attribute_count_cur(i.line_index,v_list_line_id); -- For First Line
	  FETCH get_attribute_count_cur INTO v_list_line_count1;
	  CLOSE get_attribute_count_cur;
        END IF;

       IF l_debug = FND_API.G_TRUE THEN
       QP_PREQ_GRP.engine_debug( 'Precedence Matched . Attribute Count1 : ' || v_list_line_id || ' ' || v_list_line_count1);

       END IF;
	  OPEN get_attribute_count_cur(i.line_index,l_precedence_tbl(j).created_from_list_line_id); -- For Second Line
	  FETCH get_attribute_count_cur INTO v_list_line_count2;
	  CLOSE get_attribute_count_cur;

       IF l_debug = FND_API.G_TRUE THEN
       QP_PREQ_GRP.engine_debug( 'Precedence Matched . Attribute Count2 : ' || l_precedence_tbl(j).created_from_list_line_id  || ' ' || v_list_line_count2);

       END IF;
          -- Update the status to duplicate list lines , only after comparing the attribute counts for all list lines
          -- That is why the extra condition v_total_cout = v_count+1
       IF (nvl(v_list_line_count1,0) = nvl(v_list_line_count2,0) and v_total_count = v_count + 1) THEN
	   v_dup_list_line_id := l_precedence_tbl(j).created_from_list_line_id;

	   --begin fix bug 2746019
           --l_status_text := v_list_line_id || ',' || v_dup_list_line_id; --fix bug 2746019
           select name into v_price_list from qp_list_headers_vl where
           list_header_id = (select list_header_id from qp_list_lines
           where list_line_id = v_list_line_id);

           select name into v_dup_price_list from qp_list_headers_vl where
           list_header_id = (select list_header_id from qp_list_lines
           where list_line_id = v_dup_list_line_id);

           FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_PRICE_LIST');
	   FND_MESSAGE.SET_TOKEN('LIST_LINE_ID', v_price_list);
	   FND_MESSAGE.SET_TOKEN('DUP_LIST_LINE_ID', v_dup_price_list);
	   l_status_text:= FND_MESSAGE.GET;
	   -- end fix bug 2746019

	   Update_Invalid_List_Lines(i.INCOMPATABILITY_GRP_CODE,i.line_index,p_pricing_phase_id,
				   QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST,l_status_text, v_return_status,
                                   v_return_status_text);
           GOTO NEXT_LINE;

        --RAISE DUPLICATE_PRICE_LIST;
       ELSE
	   IF (nvl(v_list_line_count1,0) < nvl(v_list_line_count2,0)) THEN
	    v_list_line_id := l_precedence_tbl(j).created_from_list_line_id; -- Second Line should be given
            v_list_line_count1 := v_list_line_count2;
	   END IF;
	  END IF;
      END IF;
     END IF;
     v_count := v_count + 1;
   END LOOP;
  END IF;

    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('List Line Id:' || v_list_line_id);

    END IF;
   IF (v_list_line_id IS NOT NULL) THEN -- Successful in finding pll in order uom
      -- Update all the other list lines to status 'U'
/*
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.upd1,qp_npreq_ldets_tmp_N2,PRICING_PHASE_ID,1
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.upd1,qp_npreq_ldets_tmp_N2,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.upd1,qp_npreq_lines_tmp_N2,LINE_INDEX,3
*/
	UPDATE qp_npreq_ldets_tmp -- upd1
	SET PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_UOM_FAILURE
	WHERE INCOMPATABILITY_GRP_CODE = i.INCOMPATABILITY_GRP_CODE
	AND   LINE_INDEX = i.line_index
	AND   PRICING_PHASE_ID = p_pricing_phase_id
	AND   CREATED_FROM_LIST_LINE_ID <> v_list_line_id
	AND   PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;

	/* UPDATE qp_npreq_line_attrs_tmp a
	SET    a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_UOM_FAILURE
	WHERE  a.LIST_LINE_ID
	 IN (SELECT b.CREATED_FROM_LIST_LINE_ID
				        FROM  qp_npreq_ldets_tmp b
				        WHERE b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_UOM_FAILURE
					   AND   b.PRICING_PHASE_ID = p_pricing_phase_id
					   AND   b.INCOMPATABILITY_GRP_CODE = i.INCOMPATABILITY_GRP_CODE
					   AND   b.CREATED_FROM_LIST_LINE_ID <> v_list_line_id
				        AND   b.LINE_INDEX = i.line_index)
	AND    a.LINE_INDEX = i.line_index;  */

	-- begin shu, fix bug 2453250, no price_list_header_id after big search
/* Commented for bug#2882115
	UPDATE qp_npreq_lines_tmp a
	SET a.price_list_header_id = (SELECT list_header_id from qp_list_lines where list_line_id = v_list_line_id )
	WHERE ( a.price_list_header_id < 0 OR a.price_list_header_id IS NULL)
	AND a.line_index = i.line_index;
*/
	-- end shu fix bug 2453250

	-- begin shulin bug 1829731
        -- use OKS API to calculate pricing_qty based on order_uom if profile set to 'ORACLE_CONTRACTS'
        IF l_debug = FND_API.G_TRUE THEN
       	QP_PREQ_GRP.engine_debug('no uom conversion ...');
        END IF;
       	IF l_qp_time_uom_conversion = 'ORACLE_CONTRACTS' THEN

         IF l_debug = FND_API.G_TRUE THEN
       		QP_PREQ_GRP.engine_debug( 'contract_start_date :' || i.contract_start_date);
       		QP_PREQ_GRP.engine_debug( 'contract_end_date :' || i.contract_end_date);
       		QP_PREQ_GRP.engine_debug( 'line_uom_code/order uom :' || i.line_uom_code); -- order_uom
         END IF;

       		--IF i.contract_start_date IS NOT NULL AND i.contract_end_date IS NOT NULL THEN
                -- OKS_TIME_MEASURES_PUB replaced with OKS_OMINT_PUB in R12
                        /* [julin/4285975/4662388] removing dynamic SQL, unnecessary and causes error
                         * when env language has ',' delimiter
       			l_sql_stmt := 'select ' || nvl(ROUND (OKS_OMINT_PUB.get_quantity (i.contract_start_date, i.contract_end_date, i.line_uom_code, QP_PREQ_GRP.G_CURRENT_USER_OP_UNIT), l_max_decimal_digits), -999999) ||' from dual';
                        IF l_debug = FND_API.G_TRUE THEN
       		          QP_PREQ_GRP.engine_debug('l_sql_stmt:' || l_sql_stmt);
                        END IF; -- end debug
       			execute immediate l_sql_stmt INTO l_oks_qty;
                        */
       		--END IF;
                --bug 4900095
                IF l_duration_passed = 'N' THEN --call OKS API for OKS calls where uom_quantity is passed as null
--                  l_oks_qty := nvl(ROUND (OKS_OMINT_PUB.get_target_quantity (i.contract_start_date, i.contract_end_date, i.line_uom_code, QP_PREQ_GRP.G_CURRENT_USER_OP_UNIT), l_max_decimal_digits), -999999);
                  --bug 4900095
                  l_oks_qty := nvl(round(OKS_OMINT_PUB.get_target_duration(  p_start_date      => i.contract_start_date,
                                 p_end_date        => i.contract_end_date,
                                 p_source_uom      => i.line_uom_code,
                                 p_source_duration => i.uom_quantity,
                                 p_target_uom      => i.line_uom_code,/*Default Month*/
                                 p_org_id          => QP_PREQ_GRP.G_CURRENT_USER_OP_UNIT), l_max_decimal_digits), -999999);
                ELSE
                  l_oks_qty := null;
                END IF;--l_duration_passed = 'N'

              IF l_debug = FND_API.G_TRUE THEN
       		QP_PREQ_GRP.engine_debug('l_oks_qty:' || l_oks_qty);
              END IF; -- end debug
       		-- when contract_start_date or contract_end_date is null, or uom is 'MO' instead of 'MTH', l_oks_qty = 0
       		-- when uom is not time_related or invalid to oks API, i.e. 'EA', 'MI', l_oks_qty = NULL

       		IF (l_oks_qty IS NOT NULL AND l_oks_qty <> -999999)
                --bug 4900095
                and l_duration_passed = 'N' THEN -- oks succeed
       			v_pricing_qty := round(l_oks_qty , l_max_decimal_digits);
       			l_order_qty := v_pricing_qty; -- shu_latest, this is to correct if user enter order_qty not matching the start_date end_date
       			l_uom_quantity :=1;
                  IF l_debug = FND_API.G_TRUE THEN
       			QP_PREQ_GRP.engine_debug('Pric_Qty OKS_API Conv based on Order_UOM :' || v_pricing_qty);
                  END IF; --end debug

       		ELSE -- oks fail, make v_pricing_qty as line_quantity just like STANDARD conversion
       			v_pricing_qty := i.line_quantity; -- STANDARD
       			--l_uom_quantity :=1;
       			l_uom_quantity := nvl(i.uom_quantity, 1); -- to back support OM, SL BUG FOUND
       			-- no need to update l_order_qty, since it has been initialized to i.line_quantity
                      IF l_debug = FND_API.G_TRUE THEN
       			QP_PREQ_GRP.engine_debug('pric_qty same as order_qty :' || v_pricing_qty); --shu 12/26/2001
       			QP_PREQ_GRP.engine_debug('uom_qty passed :' || l_uom_quantity); --shu 12/26/2001
                      END IF; -- end debug

       		END IF; -- END IF (l_oks_qty IS NOT NULL AND l_oks_qty <> 0)
       	ELSE -- l_qp_time_uom_conversion = 'STANDARD' THEN
       		v_pricing_qty := i.line_quantity; -- STANDARD
       		-- no need to update l_order_qty, since it has been initialized to i.line_quantity
       		l_uom_quantity := nvl(i.uom_quantity, 1); -- to back support OM, for case user order 2 of 6 MTH service
         IF l_debug = FND_API.G_TRUE THEN
       		QP_PREQ_GRP.engine_debug('pric_qty same as order_qty :' || v_pricing_qty);
         END IF;
       	END IF;
       	-- end shulin bug 1829731

     -- The followings are used to bulk update at the end of the procedure for no uom conversion cases
     l_line_quantity_tbl(m) := l_order_qty; -- shu_latest
     l_line_index_tbl(m) := i.line_index;
     l_line_uom_code_tbl(m) := i.line_uom_code;
     l_priced_quantity_tbl(m) := v_pricing_qty; --shu_latest
     l_uom_quantity_tbl(m) := l_uom_quantity; --shu_latest
     m := m+1;

     /* no need if bulk update later
     UPDATE qp_npreq_lines_tmp
     SET    PRICED_UOM_CODE = i.line_uom_code,
            PRICED_QUANTITY = v_pricing_qty, -- shulin bug 1829731
            LINE_UOM_CODE = i.line_uom_code, -- order_uom
            LINE_QUANTITY = l_order_qty, -- shu_latest
            UOM_QUANTITY =1
     WHERE  LINE_INDEX = i.line_index;
	*/

	x_list_line_id := v_list_line_id;
   ELSE -- uom conversion cases

    Precedence_For_Price_List_Line(i.line_index,NULL,'Y',l_precedence_tbl,l_status,l_status_text);

    -- Sort the table(not needed as it would have only the price list lines with least precedence)
    /* IF (l_precedence_tbl.COUNT > 0) THEN
     --sort_on_precedence(l_precedence_tbl, l_precedence_tbl.FIRST, l_precedence_tbl.LAST);
     sort_on_precedence(l_precedence_tbl);
    END IF; */

    /* IF (l_precedence_tbl.COUNT > 0) THEN
     FOR j IN l_precedence_tbl.FIRST .. l_precedence_tbl.LAST
     LOOP
      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('List Line Id : ' || l_precedence_tbl(j).created_from_list_line_id);
      QP_PREQ_GRP.engine_debug('Precedence : '   || l_precedence_tbl(j).product_precedence);
      QP_PREQ_GRP.engine_debug('Inventory Item Id: ' || l_precedence_tbl(j).inventory_item_id);
      QP_PREQ_GRP.engine_debug('Product Uom : ' || l_precedence_tbl(j).product_uom_code);
      END IF;
     END LOOP;
    END IF; */

    IF (l_precedence_tbl.COUNT > 0) THEN
        v_total_count := l_precedence_tbl.COUNT;
        v_count := 0;
        v_list_line_count1 := NULL;
   	FOR j IN l_precedence_tbl.FIRST .. l_precedence_tbl.LAST
   	LOOP
 IF l_debug = FND_API.G_TRUE THEN
	QP_PREQ_GRP.engine_debug('pri flag');
 END IF;
        IF (v_count = 0) THEN
         v_list_line_id := l_precedence_tbl(j).created_from_list_line_id;
         v_list_precedence := l_precedence_tbl(j).product_precedence;
         v_primary_uom_code := l_precedence_tbl(j).product_uom_code;
       	 v_inventory_item_id := to_number(l_precedence_tbl(j).inventory_item_id);
        END IF;

       IF (v_count > 0 ) THEN
        IF (v_list_precedence = l_precedence_tbl(j).product_precedence) THEN

         --Reset
         v_list_line_count2 := NULL;

          IF (v_list_line_count1 IS NULL) THEN
	    OPEN get_attribute_count_cur(i.line_index,v_list_line_id); -- For First Line
	    FETCH get_attribute_count_cur INTO v_list_line_count1;
	    CLOSE get_attribute_count_cur;
          END IF;

          IF l_debug = FND_API.G_TRUE THEN
          QP_PREQ_GRP.engine_debug( 'Precedence Matched . Attribute Count Pri1 : ' || v_list_line_id || ' ' || v_list_line_count1);

          END IF;
	    OPEN get_attribute_count_cur(i.line_index,l_precedence_tbl(j).created_from_list_line_id); -- For Second Line
	    FETCH get_attribute_count_cur INTO v_list_line_count2;
	    CLOSE get_attribute_count_cur;

           IF l_debug = FND_API.G_TRUE THEN
             QP_PREQ_GRP.engine_debug( 'Precedence Matched . Attribute Count Pri2 : ' || l_precedence_tbl(j).created_from_list_line_id  || ' ' || v_list_line_count2);

            END IF;
	 IF (nvl(v_list_line_count1,0) = nvl(v_list_line_count2,0) and v_total_count = v_count + 1) THEN

	   v_dup_list_line_id := l_precedence_tbl(j).created_from_list_line_id;

	   --begin fix bug 2746019
           --l_status_text := v_list_line_id || ',' || v_dup_list_line_id; --fix bug 2746019
           select name into v_price_list from qp_list_headers_vl where
           list_header_id = (select list_header_id from qp_list_lines
           where list_line_id = v_list_line_id);

           select name into v_dup_price_list from qp_list_headers_vl where
           list_header_id = (select list_header_id from qp_list_lines
           where list_line_id = v_dup_list_line_id);

           FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_PRICE_LIST');
	   FND_MESSAGE.SET_TOKEN('LIST_LINE_ID', v_price_list);
	   FND_MESSAGE.SET_TOKEN('DUP_LIST_LINE_ID', v_dup_price_list);
	   l_status_text:= FND_MESSAGE.GET;
	   -- end fix bug 2746019

	   Update_Invalid_List_Lines(i.INCOMPATABILITY_GRP_CODE,i.line_index,p_pricing_phase_id,
				   QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST,l_status_text, v_return_status,
                                   v_return_status_text);
           GOTO NEXT_LINE;
           --RAISE DUPLICATE_PRICE_LIST;
         ELSE
	     IF (nvl(v_list_line_count1,0) < nvl(v_list_line_count2,0)) THEN
	      v_list_line_id := l_precedence_tbl(j).created_from_list_line_id; -- Second Line should be given
              v_list_line_count1 := v_list_line_count2;
	     END IF;
	 END IF;
        END IF;
       END IF;
       v_count := v_count + 1;
      END LOOP;
   END IF; -- v_list_line_id IS NOT NULL

 IF l_debug = FND_API.G_TRUE THEN
	QP_PREQ_GRP.engine_debug('Pri Flag List Line Id:' || v_list_line_id);

 END IF;
      IF (v_list_line_id IS NOT NULL) THEN
/*
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.upd2,qp_npreq_ldets_tmp_N2,PRICING_PHASE_ID,1
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.upd2,qp_npreq_ldets_tmp_N2,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.upd2,qp_npreq_lines_tmp_N2,LINE_INDEX,3
*/
	    -- Update all the other list lines to status 'P'
	  UPDATE qp_npreq_ldets_tmp -- upd2
	  SET PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_PRIMARY_UOM_FLAG
 	  WHERE INCOMPATABILITY_GRP_CODE = i.INCOMPATABILITY_GRP_CODE
	  AND   LINE_INDEX = i.line_index
	  AND   PRICING_PHASE_ID = p_pricing_phase_id
	  AND   CREATED_FROM_LIST_LINE_ID <> v_list_line_id
	  AND   PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;


	  /* UPDATE qp_npreq_line_attrs_tmp a
	  SET    a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_PRIMARY_UOM_FLAG
	  WHERE  a.LIST_LINE_ID IN (SELECT b.CREATED_FROM_LIST_LINE_ID
				         FROM  qp_npreq_ldets_tmp b
				         WHERE b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_PRIMARY_UOM_FLAG
					    AND   b.CREATED_FROM_LIST_LINE_ID <> v_list_line_id
				         AND   b.LINE_INDEX = i.line_index)
	  AND    a.LINE_INDEX = i.line_index; */

	/* UPDATE qp_npreq_line_attrs_tmp a
	SET    a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_PRIMARY_UOM_FLAG
	WHERE  a.LIST_LINE_ID
	 IN (SELECT b.CREATED_FROM_LIST_LINE_ID
				        FROM  qp_npreq_ldets_tmp b
				        WHERE b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_PRIMARY_UOM_FLAG
					   AND   b.PRICING_PHASE_ID = p_pricing_phase_id
					   AND   b.INCOMPATABILITY_GRP_CODE = i.INCOMPATABILITY_GRP_CODE
					   AND   b.CREATED_FROM_LIST_LINE_ID <> v_list_line_id
				        AND   b.LINE_INDEX = i.line_index)
	AND    a.LINE_INDEX = i.line_index;  */

	-- begin shu, fix bug 2453250, no price_list_header_id after big search
/* Commented for bug#2882115
	UPDATE qp_npreq_lines_tmp a
	SET a.price_list_header_id = (SELECT list_header_id from qp_list_lines where list_line_id = v_list_line_id )
	WHERE ( a.price_list_header_id < 0 OR a.price_list_header_id IS NULL)
	AND a.line_index = i.line_index;
*/
	-- end shu fix bug 2453250

      IF l_debug = FND_API.G_TRUE THEN
      QP_PREQ_GRP.engine_debug('Data Updated');
      QP_PREQ_GRP.engine_debug('Order Uom:' || i.line_uom_code);
      QP_PREQ_GRP.engine_debug('Prim UOM:' || v_primary_uom_code);
      QP_PREQ_GRP.engine_debug('Inventory Id:' || v_inventory_item_id);
      QP_PREQ_GRP.engine_debug('v_pricing_qty:' || v_pricing_qty);
      END IF;

	-- begin Bug 1829731 fix, shulin
 IF l_debug = FND_API.G_TRUE THEN
	QP_PREQ_GRP.engine_debug('uom conversion...');
 END IF;
	l_uom_quantity := i.uom_quantity; --shu_latest, to back support OM, either from usr input or null
    	-- shulin, do OKS conversion if profile set to 'ORCALE_CONTRACTS'
        IF (l_qp_time_uom_conversion = 'ORACLE_CONTRACTS') THEN  -- do oks conversion

                 IF l_debug = FND_API.G_TRUE THEN
       	       		QP_PREQ_GRP.engine_debug( 'contract_start_date :' || i.contract_start_date);
       			QP_PREQ_GRP.engine_debug( 'contract_end_date :' || i.contract_end_date);
       			QP_PREQ_GRP.engine_debug( 'primary_uom_code :' || v_primary_uom_code);
                        QP_PREQ_GRP.engine_debug('v_pricing_qty:' || v_pricing_qty);
                 END IF;
       			-- when contract_start_date or contract_end_date is null, or uom is 'MO' instead of 'MTH', l_oks_qty = 0
       			-- when uom is not time_related or invalid to oks API, i.e. 'EA', 'MI', l_oks_qty = NULL

       			--IF i.contract_start_date IS NOT NULL AND i.contract_end_date IS NOT NULL THEN
       			-- OKS_TIME_MEASURES_PUB replaced with OKS_OMINT_PUB in R12
                            /* [julin/4285975/4662388] removing dynamic SQL, unnecessary and causes error
                             * when env language has ',' delimiter
                            l_sql_stmt := 'select ' || ROUND (OKS_OMINT_PUB.get_quantity (i.contract_start_date,
                                           i.contract_end_date, v_primary_uom_code, QP_PREQ_GRP.G_CURRENT_USER_OP_UNIT), l_max_decimal_digits) ||' from dual';
       			    execute immediate l_sql_stmt INTO l_oks_qty; -- shulin
                            */
       			--END IF;
--                        l_oks_qty := ROUND (OKS_OMINT_PUB.get_quantity (i.contract_start_date, i.contract_end_date, v_primary_uom_code, QP_PREQ_GRP.G_CURRENT_USER_OP_UNIT), l_max_decimal_digits);
                          --bug 4900095
                          l_oks_qty := nvl(round(OKS_OMINT_PUB.get_target_duration(  p_start_date      => i.contract_start_date,
                                 p_end_date        => i.contract_end_date,
                                 p_source_uom      => i.line_uom_code,
                                 p_source_duration => i.uom_quantity,
                                 p_target_uom      => v_primary_uom_code,/*Default Month*/
                                 p_org_id          => QP_PREQ_GRP.G_CURRENT_USER_OP_UNIT), l_max_decimal_digits), -999999);

              IF l_debug = FND_API.G_TRUE THEN
       		QP_PREQ_GRP.engine_debug('l_oks_qty1:' || l_oks_qty);
              END IF; -- end debug

       			IF (l_oks_qty IS NOT NULL OR l_oks_qty <> 0)
                        --bug 4900095
                        and l_duration_passed = 'N' THEN -- oks succeed

       				-- order_qty is based on odr_uom
                                /* [julin/4285975/4662388] removing dynamic SQL, unnecessary and causes error
                                 * when env language has ',' delimiter
       				l_sql_stmt := 'select ' || ROUND (OKS_OMINT_PUB.get_quantity (i.contract_start_date,
                                              i.contract_end_date, i.line_uom_code, QP_PREQ_GRP.G_CURRENT_USER_OP_UNIT), l_max_decimal_digits) ||' from dual';
       				execute immediate l_sql_stmt INTO l_order_qty; -- shu_latest
                                */
--                                l_order_qty := ROUND (OKS_OMINT_PUB.get_quantity (i.contract_start_date, i.contract_end_date, i.line_uom_code, QP_PREQ_GRP.G_CURRENT_USER_OP_UNIT), l_max_decimal_digits);
                                  --bug 4900095
                                  l_order_qty := nvl(round(OKS_OMINT_PUB.get_target_duration(  p_start_date      => i.contract_start_date,
                                 p_end_date        => i.contract_end_date,
                                 p_source_uom      => i.line_uom_code,
                                 p_source_duration => i.uom_quantity,
                                 p_target_uom      => i.line_uom_code,/*Default Month*/
                                 p_org_id          => QP_PREQ_GRP.G_CURRENT_USER_OP_UNIT), l_max_decimal_digits), -999999);
              IF l_debug = FND_API.G_TRUE THEN
       		QP_PREQ_GRP.engine_debug('l_oks_qty2:' || l_oks_qty);
              END IF; -- end debug

       				v_pricing_qty := round (l_oks_qty , l_max_decimal_digits);

       				l_uom_quantity := 1; --shulin
           IF l_debug = FND_API.G_TRUE THEN
       				QP_PREQ_GRP.engine_debug('OKS_API conversion...');
       				QP_PREQ_GRP.engine_debug('pricing_qty:' || v_pricing_qty);
       				QP_PREQ_GRP.engine_debug('pricing_uom:' || v_primary_uom_code);
       				QP_PREQ_GRP.engine_debug('order_qty:' || l_order_qty);
       				QP_PREQ_GRP.engine_debug('order_uom:' || l_order_uom_code);
       				QP_PREQ_GRP.engine_debug('uom_quantity:' || l_uom_quantity);
           END IF;

                        ELSIF (l_oks_qty <> -999999 AND l_oks_qty <> 0) -- OM/ASO/IBE call for service line duration/uom_quantity is not null
                        --bug 4900095
                        and l_duration_passed = 'Y' THEN
                          l_uom_quantity := l_oks_qty;
    		          v_pricing_qty := ROUND( i.line_quantity * l_oks_qty, l_max_decimal_digits) ; -- nvl is case we only have line_quantity
                          --changed for service pricing
    		          --v_pricing_qty := ROUND( i.line_quantity * l_oks_qty * nvl(i.uom_quantity,1), l_max_decimal_digits) ; -- nvl is case we only have line_quantity
        	          --l_uom_quantity := ROUND( i.uom_quantity * v_uom_rate, l_max_decimal_digits);  -- do not nvl uom_quantity
        	          l_uom_quantity :=1; -- reset to 1, so the unit price by pricing uom does not change
        	          l_order_qty := i.line_quantity;
           IF l_debug = FND_API.G_TRUE THEN
       				QP_PREQ_GRP.engine_debug('OKS_API conversion for OM...');
       				QP_PREQ_GRP.engine_debug('pricing_qty:' || v_pricing_qty);
       				QP_PREQ_GRP.engine_debug('pricing_uom:' || v_primary_uom_code);
       				QP_PREQ_GRP.engine_debug('order_qty:' || l_order_qty);
       				QP_PREQ_GRP.engine_debug('order_uom:' || l_order_uom_code);
       				QP_PREQ_GRP.engine_debug('uom_quantity:' || l_uom_quantity);
           END IF;
       			END IF; --oks succeed
       END IF; -- end profile is ORACLE_CONTRACTS

       -- not 'ORACLE_CONTACTS' or OKS conversion failed, use standard inventory uom conversion
       IF (l_qp_time_uom_conversion = 'STANDARD') OR (l_oks_qty = -999999 OR l_oks_qty = 0) THEN

       		IF (l_qp_time_uom_conversion = 'ORACLE_CONTRACTS') then
          IF l_debug = FND_API.G_TRUE THEN
       			QP_PREQ_GRP.engine_debug('oks conversion had failed...');
          END IF;
       		END IF; -- for debug, to distinglish if it is oks failed case or if profile set to standard case

       		-- Get the conversion rate based on prclist's primary_uom
        	Inv_convert.inv_um_conversion(i.line_uom_code,
					             v_primary_uom_code,
					             v_inventory_item_id,
					             v_uom_rate);
      		IF (v_uom_rate = -99999) THEN
            		l_status_text := 'invalid conversion rate from ' || l_order_uom_code || ' to ' || v_primary_uom_code;
	    		Update_Invalid_List_Lines(i.INCOMPATABILITY_GRP_CODE,i.line_index,p_pricing_phase_id,
				   QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV,l_status_text, v_return_status,
                                   v_return_status_text);
                        -- [julin/4330147/4335995]
                        l_uom_conv_success := 'N';
	    		--RAISE INVALID_UOM_CONVERSION;
	    	ELSE
	    		IF (i.PROCESSING_ORDER <> 2 or i.PROCESSING_ORDER IS NULL ) THEN -- It is not a service line

    				v_pricing_qty := ROUND( i.line_quantity * v_uom_rate, l_max_decimal_digits);
    				l_uom_quantity := 1; --shu_latest
    				l_order_qty := i.line_quantity;
        IF l_debug = FND_API.G_TRUE THEN
    				QP_PREQ_GRP.engine_debug('Standard uom conversion, non-service line...');
       				QP_PREQ_GRP.engine_debug('pricing_qty:' || v_pricing_qty);
       				QP_PREQ_GRP.engine_debug('pricing_uom:' || v_primary_uom_code);
       				QP_PREQ_GRP.engine_debug('order_qty:' || l_order_qty);
       				QP_PREQ_GRP.engine_debug('order_uom:' || l_order_uom_code);
       				QP_PREQ_GRP.engine_debug('uom_quantity:' || l_uom_quantity);
        END IF;

    			ELSE	-- service line, l_uom_quantity matters

    				IF (l_qp_time_uom_conversion = 'ORACLE_CONTRACTS') THEN -- from oks failed case
    					v_pricing_qty := ROUND( i.line_quantity * v_uom_rate, l_max_decimal_digits);
    					l_uom_quantity := 1;
    					l_order_qty := i.line_quantity;
         IF l_debug = FND_API.G_TRUE THEN
    					QP_PREQ_GRP.engine_debug('Standard uom conversion (oks failed), service line...');
       					QP_PREQ_GRP.engine_debug('pricing_qty:' || v_pricing_qty);
       					QP_PREQ_GRP.engine_debug('pricing_uom:' || v_primary_uom_code);
       					QP_PREQ_GRP.engine_debug('order_qty:' || l_order_qty);
       					QP_PREQ_GRP.engine_debug('order_uom:' || l_order_uom_code);
       					QP_PREQ_GRP.engine_debug('uom_quantity:' || l_uom_quantity);
         END IF;

    				ELSE -- from profile being standard case, l_uom_quantity matters for OM
    					-- assuming OM pass l_uom_quantity is converted to order uom like the following
        				-- 1 of 2 YR services, order_uom=YR, l_uom_quantity = 2 (YR)
            IF l_debug = FND_API.G_TRUE THEN
        				QP_PREQ_GRP.engine_debug('uom_quantity from calling application:' || i.uom_quantity);
            END IF;
    					v_pricing_qty := ROUND( i.line_quantity * v_uom_rate * nvl(i.uom_quantity,1), l_max_decimal_digits) ; -- nvl is case we only have line_quantity
        				--l_uom_quantity := ROUND( i.uom_quantity * v_uom_rate, l_max_decimal_digits);  -- do not nvl uom_quantity
        				l_uom_quantity :=1; -- reset to 1, so the unit price by pricing uom does not change
        				l_order_qty := i.line_quantity;

            IF l_debug = FND_API.G_TRUE THEN
        				QP_PREQ_GRP.engine_debug('Standard uom conversion, service line...');
       					QP_PREQ_GRP.engine_debug('pricing_qty:' || v_pricing_qty);
       					QP_PREQ_GRP.engine_debug('pricing_uom:' || v_primary_uom_code);
       					QP_PREQ_GRP.engine_debug('order_qty:' || l_order_qty);
       					QP_PREQ_GRP.engine_debug('order_uom:' || l_order_uom_code);
            END IF;

        			END IF;

        		END IF; -- end if service or non-service line

        	END IF; -- end if v_uom_rate

       END IF; -- end profile is 'STANDARD'


/*
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.upd1,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/
-- do not nvl UOM_QUANTITY when updating UOM_QUANTITY , for a case if uom_quantity is null for a regular line , we could
-- potentially update it to value by nvl'ing it , when uom_quantity is supposed to be null.
-- Ex: 1Ton = 1000Kg , UOM_QUANTITY passed is null . in this case if we nvl(UOM_QUANTITY,1) then the new uom_quantity after the
-- update will be nvl(uom_quantity,1) * 1000(v_uom_rate) = 1000 which is wrong ..  bug# 2028618

        UPDATE qp_npreq_lines_tmp -- upd1
        SET PRICED_UOM_CODE = v_primary_uom_code,
            PRICED_QUANTITY = v_pricing_qty, -- shulin bug 1829731
            LINE_UOM_CODE = l_order_uom_code, -- order_uom, i.line_uom_code
            LINE_QUANTITY = l_order_qty, -- shu_latest
            UOM_QUANTITY = decode(l_duration_passed,
                                  'Y', l_uom_quantity,
                                  'N', uom_quantity,
                                  uom_quantity)
        WHERE  LINE_INDEX = i.line_index;
        x_list_line_id := v_list_line_id;

        -- [julin/4330147/4335995] only update line_attrs when uom conversion successful
        IF (l_uom_conv_success = 'Y') THEN
          -- 3773652
          -- used for bulk update for UOM conversion cases
          l_upd_line_index_tbl(n) := i.line_index;
          l_upd_priced_qty_tbl(n) := v_pricing_qty;
          n := n+1;
        END IF;
       ELSE -- No record found in primary uom and also in order uom,  else IF (v_list_line_id IS NOT NULL)
            l_status_text := 'Could not find a price list in Ordered UOM or Primary UOM';
            IF l_debug = FND_API.G_TRUE THEN
            QP_PREQ_GRP.engine_debug(l_status_text);
            END IF;
	    Update_Invalid_List_Lines(i.INCOMPATABILITY_GRP_CODE,i.line_index,p_pricing_phase_id,
				   QP_PREQ_GRP.G_STATUS_INVALID_UOM,l_status_text, v_return_status,
                                   v_return_status_text);
            GOTO NEXT_LINE;
         -- RAISE INVALID_UOM;
       END IF;
    END IF;

  <<NEXT_LINE>>
   null;
  END LOOP;


/*
INDX,QP_Resolve_Incompatability_PVTRUN.determine_pricing_uom_and_qty.upd2,qp_npreq_lines_tmp_N1,LINE_INDEX,1
*/

  -- Bulk Update, from no uom conversion cases
  FORALL i in 1 .. l_line_index_tbl.COUNT --upd2
     UPDATE qp_npreq_lines_tmp
     SET    PRICED_UOM_CODE = l_line_uom_code_tbl(i), --priced uom is the same as order uom
            PRICED_QUANTITY = l_priced_quantity_tbl(i), -- shu_latest
            LINE_UOM_CODE = l_line_uom_code_tbl(i), -- order uom
            LINE_QUANTITY = l_line_quantity_tbl(i), -- shu_latest
            UOM_QUANTITY = l_uom_quantity_tbl(i) -- shu_latest
     WHERE  LINE_INDEX = l_line_index_tbl(i);

  l_line_uom_code_tbl := l_line_uom_code_tbl_m;
  l_line_quantity_tbl := l_line_quantity_tbl_m;
  l_line_index_tbl := l_line_index_tbl_m;
  l_priced_quantity_tbl := l_priced_quantity_tbl_m; --shu_latest
  l_uom_quantity_tbl := l_uom_quantity_tbl_m; --shu_latest

  -- 3773652
  -- bulk update, from uom conversion cases
  FORALL i in 1..l_upd_line_index_tbl.COUNT
    UPDATE qp_npreq_line_attrs_tmp
    SET    VALUE_FROM = qp_number.number_to_canonical(l_upd_priced_qty_tbl(i))
    WHERE  LINE_INDEX = l_upd_line_index_tbl(i)
    AND    CONTEXT = QP_PREQ_GRP.G_PRIC_VOLUME_CONTEXT
    AND    ATTRIBUTE = QP_PREQ_GRP.G_QUANTITY_ATTRIBUTE
    AND    ATTRIBUTE_TYPE = QP_PREQ_GRP.G_PRICING_TYPE
    AND    PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_UNCHANGED;
  l_upd_line_index_tbl := l_line_index_tbl_m;
  l_upd_priced_qty_tbl := l_priced_quantity_tbl_m;

  IF l_debug = FND_API.G_TRUE THEN
  QP_PREQ_GRP.engine_debug('Incomp Return Status : ' || v_return_status);
  END IF;
  v_return_status := x_return_status;
 EXCEPTION
  WHEN INVALID_UOM_CONVERSION THEN
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug(v_routine_name ||' Invalid Unit of Measure Conversion'|| l_order_uom_code || ','
			    || v_primary_uom_code);
   END IF;
   x_return_status_txt := l_order_uom_code || ',' || v_primary_uom_code;
   v_return_status := QP_PREQ_GRP.G_STATUS_INVALID_UOM_CONV;
   x_return_status := v_return_status;
   x_list_line_id := NULL;
  WHEN DUPLICATE_PRICE_LIST THEN
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug(v_routine_name || ' Duplicate Price List '|| v_list_line_id || ',' || v_dup_list_line_id);
   END IF;
   v_return_msg := v_list_line_id || ',' || v_dup_list_line_id ;
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug(v_return_msg);
   END IF;
   x_return_status_txt := v_return_msg;
   v_return_status := QP_PREQ_GRP.G_STATUS_DUP_PRICE_LIST;
   x_return_status := v_return_status;
   x_list_line_id := NULL;
  WHEN INVALID_UOM THEN
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug(v_routine_name || ' Could not find a price list in Ordered UOM or Primary UOM');
   END IF;
   x_return_status_txt := 'Could not find a price list in Ordered UOM or Primary UOM';
   v_return_status := QP_PREQ_GRP.G_STATUS_INVALID_UOM;
   x_return_status := v_return_status;
   x_list_line_id := NULL;
  WHEN OTHERS THEN
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug(v_routine_name || 'Unexpected Error');
   QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || SQLERRM);
   END IF;
   v_return_status := FND_API.G_RET_STS_ERROR;
   x_return_status := v_return_status;
   x_return_status_txt := v_routine_name || ' ' || SQLERRM;
   x_list_line_id := NULL;
 END Determine_Pricing_UOM_And_Qty;

 PROCEDURE Best_Price_Evaluation(p_list_price 	     NUMBER,
				 p_line_index 	     NUMBER,
				 p_pricing_phase_id  NUMBER,
				 p_incomp_grp_id     VARCHAR2,
                                 p_precedence        NUMBER,   -- Added for bug#2661540
			         p_manual_dis_flag   VARCHAR2,
				 x_list_line_id  OUT NOCOPY NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2) AS


 v_index 		NUMBER := 1;
 v_list_price		NUMBER;
 v_benefit_price	NUMBER;
 v_benefit_percent	NUMBER;
 v_list_line_id	        NUMBER;
 v_request_qty		NUMBER;
 v_return_status        VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
 x_benefit_amount       NUMBER;
 l_return_status        VARCHAR2(30);
 l_return_status_text   VARCHAR2(240);
 l_sign                 NUMBER;
 l_request_qty		NUMBER;
l_line_id               NUMBER; --3244060

 v_routine_name CONSTANT VARCHAR2(240) := 'Routine:QP_Resolve_Incompatability_PVTRUN.Best_Price_Evaluation';

/*
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.get_list_lines_cur,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.get_list_lines_cur,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.get_list_lines_cur,qp_npreq_ldets_tmp_N1,PRICING_PHASE_ID,3
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.get_list_lines_cur,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_HEADER_ID,4

INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.get_list_lines_cur,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.get_list_lines_cur,QP_LIST_LINES_PK,LIST_LINE_ID,1
*/
-- For bug#2661540
 CURSOR  get_list_lines_cur IS
 SELECT b.CREATED_FROM_LIST_HEADER_ID, b.CREATED_FROM_LIST_LINE_ID,b.line_detail_index, --3244060
          b.CREATED_FROM_LIST_LINE_TYPE, b.OPERAND_CALCULATION_CODE, b.OPERAND_VALUE,a.ESTIM_GL_VALUE ,
        a.BENEFIT_PRICE_LIST_LINE_ID,a.PRICE_BREAK_TYPE_CODE,b.LINE_QUANTITY,b.GROUP_QUANTITY,b.GROUP_AMOUNT, --[julin/4240067/4307242]
        b.modifier_level_code
 FROM   QP_LIST_LINES a, qp_npreq_ldets_tmp b, qp_npreq_line_attrs_tmp c
 WHERE  a.LIST_HEADER_ID = b.CREATED_FROM_LIST_HEADER_ID
 AND    a.LIST_LINE_ID   = b.CREATED_FROM_LIST_LINE_ID
 AND    b.CREATED_FROM_LIST_TYPE_CODE not in (QP_PREQ_GRP.G_PRICE_LIST_HEADER,QP_PREQ_GRP.G_AGR_LIST_HEADER)
 AND    b.PRICING_PHASE_ID = p_pricing_phase_id
 AND    b.INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
 AND    b.LINE_INDEX = p_line_index
 AND    b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
 AND    ((b.AUTOMATIC_FLAG = QP_PREQ_GRP.G_YES AND p_manual_dis_flag = QP_PREQ_GRP.G_YES)
         OR p_manual_dis_flag = QP_PREQ_GRP.G_NO)
 AND    c.LIST_LINE_ID(+) = a.LIST_LINE_ID
 AND    c.LIST_HEADER_ID(+) = a.LIST_HEADER_ID
 AND    c.ATTRIBUTE_TYPE(+) = 'QUALIFIER'
 AND    c.INCOMPATABILITY_GRP_CODE(+) = p_incomp_grp_id
 AND    c.PRICING_PHASE_ID(+) = p_pricing_phase_id
 AND    c.PRICING_STATUS_CODE(+) = 'N'
 AND    c.LINE_INDEX(+) = p_line_index
 AND    least(nvl(b.PRODUCT_PRECEDENCE,5000),nvl(c.QUALIFIER_PRECEDENCE,5000)) = nvl(p_precedence, least(nvl(b.PRODUCT_PRECEDENCE,5000),nvl(c.QUALIFIER_PRECEDENCE,5000)));

/* Commented for bug 2661540
 CURSOR  get_list_lines_cur IS
 SELECT b.CREATED_FROM_LIST_HEADER_ID, b.CREATED_FROM_LIST_LINE_ID,
	  b.CREATED_FROM_LIST_LINE_TYPE, b.OPERAND_CALCULATION_CODE, b.OPERAND_VALUE,a.ESTIM_GL_VALUE ,
        a.BENEFIT_PRICE_LIST_LINE_ID,a.PRICE_BREAK_TYPE_CODE,b.GROUP_QUANTITY,b.GROUP_AMOUNT
 FROM   QP_LIST_LINES a, qp_npreq_ldets_tmp b
 WHERE  a.LIST_HEADER_ID = b.CREATED_FROM_LIST_HEADER_ID
 AND    a.LIST_LINE_ID   = b.CREATED_FROM_LIST_LINE_ID
 AND    b.CREATED_FROM_LIST_TYPE_CODE not in (QP_PREQ_GRP.G_PRICE_LIST_HEADER,QP_PREQ_GRP.G_AGR_LIST_HEADER)
 AND    b.PRICING_PHASE_ID = p_pricing_phase_id
 AND    b.INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
 AND    b.LINE_INDEX = p_line_index
 AND    b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
 AND    ((b.AUTOMATIC_FLAG = QP_PREQ_GRP.G_YES AND p_manual_dis_flag = QP_PREQ_GRP.G_YES) OR
		p_manual_dis_flag = QP_PREQ_GRP.G_NO);
*/
/*
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.get_request_qty_cur,qp_npreq_lines_tmp_N1,LINE_INDEX,1*/

 CURSOR get_request_qty_cur IS
 SELECT nvl(PRICED_QUANTITY,LINE_QUANTITY)
 FROM   qp_npreq_lines_tmp
 WHERE  LINE_INDEX = p_line_index;

/*
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.get_list_price_cur,QP_LIST_LINES_PK,LIST_LINE_ID,1
*/

 CURSOR get_list_price_cur(p_list_line_id NUMBER) IS
 SELECT OPERAND
 FROM   QP_LIST_LINES
 WHERE  LIST_LINE_ID = p_list_line_id
 AND    ARITHMETIC_OPERATOR = QP_PREQ_GRP.G_UNIT_PRICE;

/*
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.get_list_lines_in_order,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.get_list_lines_in_order,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.get_list_lines_in_order,qp_npreq_ldets_tmp_N1,PRICING_PHASE_ID,3
*/

-- For bug 2661540
 CURSOR get_list_lines_in_order IS
 SELECT a.CREATED_FROM_LIST_LINE_ID
 FROM   qp_npreq_ldets_tmp a, qp_npreq_line_attrs_tmp b
 WHERE  a.CREATED_FROM_LIST_TYPE_CODE not in (QP_PREQ_GRP.G_PRICE_LIST_HEADER,QP_PREQ_GRP.G_AGR_LIST_HEADER)
 AND    a.PRICING_PHASE_ID = p_pricing_phase_id
 AND    a.INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
 AND    a.LINE_INDEX = p_line_index
 AND    a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
 AND    ((a.AUTOMATIC_FLAG = QP_PREQ_GRP.G_YES AND p_manual_dis_flag = QP_PREQ_GRP.G_YES) OR
                p_manual_dis_flag = QP_PREQ_GRP.G_NO)
 AND    b.LIST_LINE_ID(+) = a.CREATED_FROM_LIST_LINE_ID
 AND    b.LIST_HEADER_ID(+) = a.CREATED_FROM_LIST_HEADER_ID
 AND    b.ATTRIBUTE_TYPE(+) = 'QUALIFIER'
 AND    b.INCOMPATABILITY_GRP_CODE(+) = p_incomp_grp_id
 AND    b.PRICING_PHASE_ID(+) = p_pricing_phase_id
 AND    b.PRICING_STATUS_CODE(+) = 'N'
 AND    b.LINE_INDEX(+) = p_line_index
 AND    least(nvl(a.PRODUCT_PRECEDENCE,5000),nvl(b.QUALIFIER_PRECEDENCE,5000)) = nvl(p_precedence, least(nvl(a.PRODUCT_PRECEDENCE,5000),nvl(b.QUALIFIER_PRECEDENCE,5000)))
 ORDER  BY BEST_PERCENT DESC;

/* Commented for Bug 2661540
 CURSOR get_list_lines_in_order IS
 SELECT CREATED_FROM_LIST_LINE_ID
 FROM   qp_npreq_ldets_tmp
 WHERE  CREATED_FROM_LIST_TYPE_CODE not in (QP_PREQ_GRP.G_PRICE_LIST_HEADER,QP_PREQ_GRP.G_AGR_LIST_HEADER)
 AND    PRICING_PHASE_ID = p_pricing_phase_id
 AND    INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
 AND    LINE_INDEX = p_line_index
 AND    PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
 AND    ((AUTOMATIC_FLAG = QP_PREQ_GRP.G_YES AND p_manual_dis_flag = QP_PREQ_GRP.G_YES) OR
		p_manual_dis_flag = QP_PREQ_GRP.G_NO)
 ORDER  BY BEST_PERCENT DESC;
*/

  --[julin/5456188]
  l_req_value_per_unit NUMBER;
  l_total_value NUMBER;
  l_volume_attribute VARCHAR2(240);
  l_calc_quantity NUMBER;

 BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
  FOR i IN get_list_lines_cur
  LOOP
   /*IF (i.CREATED_FROM_LIST_LINE_TYPE = QP_PREQ_GRP.G_OTHER_ITEM_DISCOUNT) THEN
  IF l_debug = FND_API.G_TRUE THEN
	 QP_PREQ_GRP.engine_debug('Benefit Price List Line Id is Very important: ' || i.BENEFIT_PRICE_LIST_LINE_ID);
  END IF;
	 OPEN  get_list_price_cur(i.BENEFIT_PRICE_LIST_LINE_ID);
      FETCH get_list_price_cur INTO v_list_price;
      CLOSE get_list_price_cur;
 	IF (i.OPERAND_CALCULATION_CODE = QP_PREQ_GRP.G_PERCENT_DISCOUNT) THEN
	  v_benefit_price := (v_list_price) * (i.OPERAND_VALUE / 100);
	ELSIF (i.OPERAND_CALCULATION_CODE = QP_PREQ_GRP.G_AMOUNT_DISCOUNT) THEN
	  v_benefit_price := (v_list_price - i.OPERAND_VALUE);
  	ELSIF (i.OPERAND_CALCULATION_CODE IS NULL) THEN
	  v_benefit_price := v_list_price;
	END IF;		*/
   IF (i.CREATED_FROM_LIST_LINE_TYPE IN (QP_PREQ_GRP.G_ITEM_UPGRADE,QP_PREQ_GRP.G_TERMS_SUBSTITUTION,
                                         QP_PREQ_GRP.G_COUPON_ISSUE,QP_PREQ_GRP.G_OTHER_ITEM_DISCOUNT,
								 QP_PREQ_GRP.G_PROMO_GOODS_DISCOUNT)) THEN
	v_benefit_price := nvl(i.ESTIM_GL_VALUE,0);
   ELSIF (i.CREATED_FROM_LIST_LINE_TYPE IN (QP_PREQ_GRP.G_DISCOUNT,QP_PREQ_GRP.G_SURCHARGE,QP_PREQ_GRP.G_FREIGHT_CHARGE)) THEN

        IF (i.CREATED_FROM_LIST_LINE_TYPE = QP_PREQ_GRP.G_DISCOUNT) THEN
         l_sign := 1;
        ELSE
         l_sign := -1;
        END IF;

 IF l_debug = FND_API.G_TRUE THEN
	QP_PREQ_GRP.engine_debug('List Price For Best Price Eval: ' || p_list_price);

 END IF;

      IF(i.modifier_level_code <> 'ORDER') THEN  -- bug 4234043
 	IF (i.OPERAND_CALCULATION_CODE = QP_PREQ_GRP.G_PERCENT_DISCOUNT) THEN
	  v_benefit_price := l_sign * p_list_price * (i.OPERAND_VALUE / 100);
	ELSIF (i.OPERAND_CALCULATION_CODE = QP_PREQ_GRP.G_AMOUNT_DISCOUNT) THEN
	  v_benefit_price := l_sign * i.OPERAND_VALUE;
	ELSIF (i.OPERAND_CALCULATION_CODE = QP_PREQ_GRP.G_NEWPRICE_DISCOUNT) THEN
          l_sign := 1; -- For NEWPRICE l_sign will always be 1 irrespective of whether it is a discount or surcharge
          v_benefit_price := l_sign * (p_list_price - i.OPERAND_VALUE);
	ELSIF (i.OPERAND_CALCULATION_CODE = QP_PREQ_GRP.G_LUMPSUM_DISCOUNT) THEN
	  OPEN  get_request_qty_cur;
	  FETCH get_request_qty_cur INTO v_request_qty;
	  CLOSE get_request_qty_cur;
          IF (i.modifier_level_code = QP_PREQ_GRP.G_LINE_GROUP) THEN
            l_calc_quantity := nvl(nvl(i.group_quantity, i.group_amount), v_request_qty);
          ELSE
            l_calc_quantity := v_request_qty;
          END IF;
          v_benefit_price := l_sign * i.OPERAND_VALUE/l_calc_quantity;
	END IF;
      ELSE   ---- modifier_level_code='ORDER'
        IF (i.OPERAND_CALCULATION_CODE IN (QP_PREQ_GRP.G_PERCENT_DISCOUNT)) THEN
          v_benefit_price := l_sign * i.OPERAND_VALUE;
	END IF;
      END IF;

   ELSIF (i.CREATED_FROM_LIST_LINE_TYPE = QP_PREQ_GRP.G_PRICE_BREAK_TYPE) THEN

       IF l_debug = FND_API.G_TRUE THEN
       QP_PREQ_GRP.engine_debug('Best Price Eval For Price Break Line Quantity : ' || i.line_quantity); --[julin/4240067/4307242]
       QP_PREQ_GRP.engine_debug('Best Price Eval For Price Break Group Quantity : ' || i.group_quantity);
       QP_PREQ_GRP.engine_debug('Best Price Eval For Price Break Group Amount : ' || i.group_amount);

       END IF;
       --[julin/4240067/4307242] using i.line_quantity
       l_request_qty := nvl(nvl(i.group_quantity,i.group_amount),i.line_quantity);

       IF l_debug = FND_API.G_TRUE THEN
       QP_PREQ_GRP.engine_debug('Best Price Eval For Price Break Qualifier Value : ' || l_request_qty);

       END IF;

        /* Added for 3244060 */
       IF QP_PREQ_GRP.G_PUBLIC_API_CALL_FLAG = 'Y' THEN
           l_line_id :=i.line_detail_index;
       ELSE
           l_line_id :=i.created_from_list_line_id;
       END IF;

       --[julin/5456188] using same price_break_calculation as PPREB, but with no bucket/netamt support
       OPEN  get_request_qty_cur;
       FETCH get_request_qty_cur INTO v_request_qty;
       CLOSE get_request_qty_cur;

       BEGIN
         select pricing_attribute
         into l_volume_attribute
         from qp_pricing_attributes
         where list_line_id = i.created_from_list_line_id
         and pricing_attribute_context = QP_PREQ_GRP.G_PRIC_VOLUME_CONTEXT
         and excluder_flag='N'; --3607956
       EXCEPTION
         When OTHERS Then
           l_volume_attribute := null;
       END;

       IF (i.modifier_level_code IN (QP_PREQ_PUB.G_LINE_LEVEL, QP_PREQ_PUB.G_ORDER_LEVEL)) THEN
         IF l_volume_attribute = QP_PREQ_PUB.G_QUANTITY_ATTRIBUTE THEN
           l_total_value := 0;
           l_req_value_per_unit := v_request_qty;
         ELSE
           l_total_value := i.line_quantity;
           l_req_value_per_unit := v_request_qty;
         END IF;
       ELSE -- linegroup
         IF l_volume_attribute = QP_PREQ_PUB.G_QUANTITY_ATTRIBUTE THEN
           l_total_value := 0;
           l_req_value_per_unit := i.group_quantity;
         ELSE
           l_total_value := i.line_quantity;
           l_req_value_per_unit := i.group_amount;
         END IF;
       END IF;

       QP_Calculate_Price_PUB.Price_Break_Calculation(l_line_id,  --3244060
                                                       i.price_break_type_code,
                                                       p_line_index,
                                                       l_req_value_per_unit,--p_req_value_per_unit
                                                       0,--p_applied_req_value_per_unit, no net amt support here
                                                       l_total_value,--p_total_value
                                                       p_list_price,
                                                       0,--p_line_quantity, not used
                                                       0,--p_bucketed_adjustment, no bucket support here
                                                       'N',--p_bucketed_flag, no bucket support here
                                                       'N',--p_automatic_flag, don't want deletion
                                                       x_benefit_amount,
                                                       l_return_status,
                                                       l_return_status_text);

       IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
        NULL;
       END IF;

       v_benefit_price := x_benefit_amount;
   END IF;

   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug('Benefit Price For Best Price Eval: ' || v_benefit_price);

   END IF;
  IF (i.modifier_level_code <> 'ORDER') THEN --bug 4234043
   IF (p_list_price > 0) THEN
    v_benefit_percent := (nvl(v_benefit_price,0) / p_list_price) * 100;
   ELSE
    v_benefit_percent := 0;
   END IF;
  ELSE  -- bug 4234043
   v_benefit_percent :=v_benefit_price;
  END IF;

   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug('Benefit Percent For Best Price Eval: ' || v_benefit_percent);

   END IF;
/*
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.upd1,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.upd1,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.upd1,qp_npreq_ldets_tmp_N1,PRICING_PHASE_ID,3
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.upd1,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_HEADER_ID,4
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.upd1,qp_npreq_ldets_tmp_N1,CREATED_FROM_LIST_LINE_ID,5
*/
   UPDATE qp_npreq_ldets_tmp -- upd1
   SET    BEST_PERCENT = v_benefit_percent
   WHERE  CREATED_FROM_LIST_HEADER_ID = i.CREATED_FROM_LIST_HEADER_ID
   AND    CREATED_FROM_LIST_LINE_ID = i.CREATED_FROM_LIST_LINE_ID
   AND    PRICING_PHASE_ID = p_pricing_phase_id
   AND    INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
   AND    PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
   AND    LINE_INDEX = p_line_index;

  END LOOP;

   OPEN get_list_lines_in_order;
   FETCH get_list_lines_in_order into v_list_line_id;
   CLOSE get_list_lines_in_order;

/*
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.upd2,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.upd2,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_evaluation.upd2,qp_npreq_ldets_tmp_N1,PRICING_PHASE_ID,3
*/

   UPDATE qp_npreq_ldets_tmp -- upd2
   SET    PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL
   WHERE  CREATED_FROM_LIST_LINE_ID  <> v_list_line_id
   AND    CREATED_FROM_LIST_TYPE_CODE not in (QP_PREQ_GRP.G_PRICE_LIST_HEADER,QP_PREQ_GRP.G_AGR_LIST_HEADER)
   AND    PRICING_PHASE_ID = p_pricing_phase_id
   AND    INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
   AND    LINE_INDEX = p_line_index
   AND    PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;

   /* UPDATE qp_npreq_line_attrs_tmp a
   SET    a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL
   WHERE  a.LIST_LINE_ID IN (SELECT b.CREATED_FROM_LIST_LINE_ID
				    FROM  qp_npreq_ldets_tmp b
				    WHERE b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL
				    AND   b.CREATED_FROM_LIST_LINE_ID <> v_list_line_id
				    AND   b.LINE_INDEX = p_line_index)
   AND    a.LINE_INDEX = p_line_index; */

	/* UPDATE qp_npreq_line_attrs_tmp a
	SET    a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL
	WHERE  a.LIST_LINE_ID
	 IN (SELECT b.CREATED_FROM_LIST_LINE_ID
				        FROM  qp_npreq_ldets_tmp b
				        WHERE b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL
					   AND   b.PRICING_PHASE_ID = p_pricing_phase_id
					   AND   b.INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
					   AND   b.CREATED_FROM_LIST_LINE_ID <> v_list_line_id
				        AND   b.LINE_INDEX = p_line_index)
	AND    a.LINE_INDEX = p_line_index;  */

   x_list_line_id := v_list_line_id;
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug('Best List line Id: ' || v_list_line_id);

   END IF;
   x_return_status := v_return_status; -- SUCCESS

 EXCEPTION
  WHEN OTHERS THEN
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug(v_routine_name || 'Unexpected Error');
   QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || SQLERRM);
   END IF;
   v_return_status := FND_API.G_RET_STS_ERROR;
   x_return_status := v_return_status;
 END Best_Price_Evaluation;

 PROCEDURE Delete_Lines_Complete (p_line_index_tbl      IN QP_PREQ_GRP.NUMBER_TYPE,
                                  p_pricing_status_text IN VARCHAR2,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_return_status_txt   OUT NOCOPY VARCHAR2) AS
 BEGIN
   l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
   IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('deleting lines/ldets/attrs/rltd:'||p_pricing_status_text);
   END IF;

   FORALL i IN p_line_index_tbl.FIRST..p_line_index_tbl.LAST
     UPDATE qp_npreq_lines_tmp
     SET    pricing_status_code = QP_PREQ_PUB.G_NOT_VALID, process_status = QP_PREQ_PUB.G_NOT_VALID
     WHERE  line_index = p_line_index_tbl(i)
            and line_id is null; --bug 7539796
   FORALL i IN p_line_index_tbl.FIRST..p_line_index_tbl.LAST
     UPDATE qp_npreq_ldets_tmp
     SET    PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_DELETED,
            PRICING_STATUS_TEXT = substr(p_pricing_status_text,1,2000)
     WHERE  LINE_INDEX = p_line_index_tbl(i);
   FORALL i IN p_line_index_tbl.FIRST..p_line_index_tbl.LAST
     UPDATE qp_npreq_line_attrs_tmp
     SET    PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_DELETED,
            PRICING_STATUS_TEXT = substr(p_pricing_status_text,1,240)
     WHERE  LINE_INDEX = p_line_index_tbl(i);
   FORALL i IN p_line_index_tbl.FIRST..p_line_index_tbl.LAST
     UPDATE qp_npreq_rltd_lines_tmp
     SET    PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_DELETED,
          PRICING_STATUS_TEXT = substr(p_pricing_status_text,1,240)
     WHERE  RELATED_LINE_INDEX = p_line_index_tbl(i);
 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_return_status_txt := 'Unexpected error in QP_Resolve_Incompatability_PVT.Delete_Lines_Complete: ' || SQLERRM;
 END Delete_Lines_Complete;

 PROCEDURE Delete_Ldets_Complete (p_line_detail_index_tbl      IN QP_PREQ_GRP.NUMBER_TYPE,
                                  p_pricing_status_text IN VARCHAR2,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_return_status_txt   OUT NOCOPY VARCHAR2) AS
 BEGIN
   l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
   IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('deleting ldets/rltd:'||p_pricing_status_text);
   END IF;

   FORALL i IN p_line_detail_index_tbl.FIRST..p_line_detail_index_tbl.LAST
     UPDATE qp_npreq_ldets_tmp a
     SET    PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_DELETED,
            PRICING_STATUS_TEXT = substr(p_pricing_status_text,1,2000)
     WHERE  LINE_DETAIL_INDEX = p_line_detail_index_tbl(i) OR
            EXISTS (SELECT 1 --[julin/4671446] also deleting children ldets
                    FROM   qp_npreq_rltd_lines_tmp
                    WHERE  LINE_DETAIL_INDEX = p_line_detail_index_tbl(i)
                    AND    RELATED_LINE_DETAIL_INDEX = a.LINE_DETAIL_INDEX);
   FORALL i IN p_line_detail_index_tbl.FIRST..p_line_detail_index_tbl.LAST
     UPDATE qp_npreq_rltd_lines_tmp
     SET    PRICING_STATUS_CODE = QP_PREQ_PUB.G_STATUS_DELETED,
            PRICING_STATUS_TEXT = substr(p_pricing_status_text,1,240)
     WHERE  (LINE_DETAIL_INDEX = p_line_detail_index_tbl(i) OR
             RELATED_LINE_DETAIL_INDEX = p_line_detail_index_tbl(i)); --[julin/4671446] also deleting children ldets
 EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_return_status_txt := 'Unexpected error in QP_Resolve_Incompatability_PVT.Delete_Ldets_Complete: ' || SQLERRM;
 END Delete_Ldets_Complete;


 PROCEDURE Delete_Incompatible_Lines(p_pricing_phase_id      NUMBER,
							  p_line_index		      NUMBER,
							  p_incomp_grp_id	      VARCHAR2 := NULL,
							  p_list_line_id	      NUMBER,
							  p_excl_discount	      BOOLEAN,
							  p_manual_dis_flag       VARCHAR2,
							  x_return_status     OUT NOCOPY VARCHAR2) AS


 -- [prarasto/4141235] find loser prg line indexes to be deleted, incompatibility group
 --frontported fix done in 4134088
 CURSOR l_del_prg_lines_grp_cur IS
 SELECT rltd.RELATED_LINE_INDEX
 FROM  qp_npreq_ldets_tmp ldets, qp_npreq_rltd_lines_tmp rltd
 WHERE ldets.INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
 AND   ldets.LINE_INDEX = p_line_index
 AND   ldets.PRICING_PHASE_ID = p_pricing_phase_id
 AND   ldets.CREATED_FROM_LIST_LINE_ID <> p_list_line_id
 AND   ldets.LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE
 AND   ldets.CREATED_FROM_LIST_LINE_TYPE IN (QP_PREQ_GRP.G_PROMO_GOODS_DISCOUNT)
 AND   ldets.CREATED_FROM_LIST_LINE_ID = rltd.LIST_LINE_ID
 AND   rltd.LINE_INDEX = p_line_index;

 -- [prarasto/4141235] find loser prg line indexes to be deleted, incompatibility group
 --frontported fix done in 4134088
 CURSOR l_del_oid_ldets_grp_cur IS
 SELECT rltd.RELATED_LINE_DETAIL_INDEX
 FROM  qp_npreq_ldets_tmp ldets, qp_npreq_rltd_lines_tmp rltd
 WHERE ldets.INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
 AND   ldets.LINE_INDEX = p_line_index
 AND   ldets.PRICING_PHASE_ID = p_pricing_phase_id
 AND   ldets.CREATED_FROM_LIST_LINE_ID <> p_list_line_id
 AND   ldets.LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE
 AND   ldets.CREATED_FROM_LIST_LINE_TYPE IN (QP_PREQ_GRP.G_OTHER_ITEM_DISCOUNT)
 AND   ldets.CREATED_FROM_LIST_LINE_ID = rltd.LIST_LINE_ID
 AND   rltd.LINE_INDEX = p_line_index;

 -- [prarasto/4141235] find loser prg line indexes to be deleted, incompatibility group
 --frontported fix done in 4134088
 CURSOR l_del_prg_lines_excl_cur IS
 SELECT rltd.RELATED_LINE_INDEX
 FROM  qp_npreq_ldets_tmp ldets, qp_npreq_rltd_lines_tmp rltd
 WHERE ldets.LINE_INDEX = p_line_index
 AND   ldets.PRICING_PHASE_ID = p_pricing_phase_id
 AND   ldets.CREATED_FROM_LIST_LINE_ID <> p_list_line_id
 AND   ldets.LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE
 AND   ldets.CREATED_FROM_LIST_LINE_TYPE IN (QP_PREQ_GRP.G_PROMO_GOODS_DISCOUNT)
 AND   ldets.CREATED_FROM_LIST_LINE_ID = rltd.LIST_LINE_ID
 AND   rltd.LINE_INDEX = p_line_index;

 -- [prarasto/4141235] find loser prg line indexes to be deleted, incompatibility group
 --frontported fix done in 4134088
 CURSOR l_del_oid_ldets_excl_cur IS
 SELECT rltd.RELATED_LINE_DETAIL_INDEX
 FROM  qp_npreq_ldets_tmp ldets, qp_npreq_rltd_lines_tmp rltd
 WHERE ldets.LINE_INDEX = p_line_index
 AND   ldets.PRICING_PHASE_ID = p_pricing_phase_id
 AND   ldets.CREATED_FROM_LIST_LINE_ID <> p_list_line_id
 AND   ldets.LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE
 AND   ldets.CREATED_FROM_LIST_LINE_TYPE IN (QP_PREQ_GRP.G_OTHER_ITEM_DISCOUNT)
 AND   ldets.CREATED_FROM_LIST_LINE_ID = rltd.LIST_LINE_ID
 AND   rltd.LINE_INDEX = p_line_index;

 l_del_index_tbl QP_PREQ_GRP.NUMBER_TYPE;

 l_status_code            VARCHAR2(30);
 l_status_text            VARCHAR2(240);

 v_return_status  		    VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
 v_routine_name CONSTANT     VARCHAR2(240):='Routine:QP_Resolve_Incompatability_PVTRUN.Delete_Incompatible_Lines';

 BEGIN
     l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

   IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug('Enter Delete_Incompatible_Lines:'||p_line_index||':'||p_incomp_grp_id||':'||p_list_line_id||':'||p_manual_dis_flag);
   END IF;

     IF (p_manual_dis_flag = QP_PREQ_GRP.G_YES) THEN
	 IF (p_excl_discount = FALSE) THEN

/*
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd1,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd1,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd1,qp_npreq_ldets_tmp_N1,PRICING_PHASE_ID,3
*/

	    	UPDATE qp_npreq_ldets_tmp --upd1
	    	SET PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC
	    	WHERE INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
	    	AND   LINE_INDEX = p_line_index
	    	AND   PRICING_PHASE_ID = p_pricing_phase_id
	    	AND   CREATED_FROM_LIST_LINE_ID <> p_list_line_id
		AND   CREATED_FROM_LIST_LINE_TYPE NOT IN (QP_PREQ_GRP.G_DISCOUNT,QP_PREQ_GRP.G_SURCHARGE)
		AND   LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE -- Don't delete PBH Children any time
	    	AND   PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;

		--Begin Bug No: 7691661
		UPDATE qp_npreq_ldets_tmp
		SET PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC
		WHERE INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
		AND   LINE_INDEX = p_line_index
		AND   PRICING_PHASE_ID = p_pricing_phase_id
		AND   CREATED_FROM_LIST_LINE_ID <> p_list_line_id
		AND   ASK_FOR_FLAG = QP_PREQ_GRP.G_YES
		AND   CREATED_FROM_LIST_LINE_TYPE  IN (QP_PREQ_GRP.G_DISCOUNT,QP_PREQ_GRP.G_SURCHARGE)
		AND   LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE -- Don't delete PBH Children any time
	    	AND   PRICING_STATUS_CODE IN (QP_PREQ_GRP.G_STATUS_NEW,QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL);
		--End Bug No: 7691661


/*
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd2,qp_npreq_ldets_tmp_N3,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd2,qp_npreq_ldets_tmp_N3,PRICING_PHASE_ID,2
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd2,qp_npreq_ldets_tmp_N3,ASK_FOR_FLAG,3
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd2,qp_npreq_ldets_tmp_N3,CREATED_FROM_LIST_LINE_TYPE,4
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd2,qp_npreq_ldets_tmp_N3,PRICING_STATUS_CODE,5
*/

		UPDATE qp_npreq_ldets_tmp --upd2
		SET   PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW,
			 AUTOMATIC_FLAG = QP_PREQ_GRP.G_NO,
		      APPLIED_FLAG = QP_PREQ_GRP.G_NO
		WHERE INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
		AND   LINE_INDEX = p_line_index
		AND   PRICING_PHASE_ID = p_pricing_phase_id
		AND   CREATED_FROM_LIST_LINE_ID <> p_list_line_id
		AND   ASK_FOR_FLAG = QP_PREQ_GRP.G_NO
		AND   CREATED_FROM_LIST_LINE_TYPE  IN (QP_PREQ_GRP.G_DISCOUNT,QP_PREQ_GRP.G_SURCHARGE)
		AND   LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE -- Don't delete PBH Children any time
	    	AND   PRICING_STATUS_CODE IN (QP_PREQ_GRP.G_STATUS_NEW,QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL);

	     /* UPDATE qp_npreq_line_attrs_tmp a
	     SET    a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
	     WHERE  a.LIST_LINE_ID
	      IN (SELECT b.CREATED_FROM_LIST_LINE_ID
			FROM  qp_npreq_ldets_tmp b
	          WHERE b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
		     AND   b.PRICING_PHASE_ID = p_pricing_phase_id
		     AND   b.INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
		     AND   b.CREATED_FROM_LIST_LINE_ID <> p_list_line_id
		     AND   ASK_FOR_FLAG = QP_PREQ_GRP.G_NO
		     AND   b.CREATED_FROM_LIST_LINE_TYPE  IN (QP_PREQ_GRP.G_DISCOUNT,QP_PREQ_GRP.G_SURCHARGE)
		     AND   b.LINE_INDEX = p_line_index)
	     AND   a.LINE_INDEX = p_line_index;  */

	 ELSE
/*
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd3,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd3,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd3,qp_npreq_ldets_tmp_N1,PRICING_PHASE_ID,3
*/

	    	UPDATE qp_npreq_ldets_tmp --upd3
	    	SET PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC
	    	WHERE LINE_INDEX = p_line_index
	    	AND   PRICING_PHASE_ID = p_pricing_phase_id
	    	AND   CREATED_FROM_LIST_LINE_ID <> p_list_line_id
		AND   CREATED_FROM_LIST_LINE_TYPE NOT IN (QP_PREQ_GRP.G_DISCOUNT,QP_PREQ_GRP.G_SURCHARGE)
		AND   LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE -- Don't delete PBH Children any time
	    	AND   PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;

/*
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd4,qp_npreq_ldets_tmp_N3,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd4,qp_npreq_ldets_tmp_N3,PRICING_PHASE_ID,2
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd4,qp_npreq_ldets_tmp_N3,ASK_FOR_FLAG,3
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd4,qp_npreq_ldets_tmp_N3,CREATED_FROM_LIST_LINE_TYPE,4
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd4,qp_npreq_ldets_tmp_N3,PRICING_STATUS_CODE,5
*/
		--Begin Bug No: 7691661
		UPDATE qp_npreq_ldets_tmp
		SET PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC
		WHERE LINE_INDEX = p_line_index
		AND   PRICING_PHASE_ID = p_pricing_phase_id
		AND   CREATED_FROM_LIST_LINE_ID <> p_list_line_id
		AND   ASK_FOR_FLAG = QP_PREQ_GRP.G_YES
		AND   CREATED_FROM_LIST_LINE_TYPE  IN (QP_PREQ_GRP.G_DISCOUNT,QP_PREQ_GRP.G_SURCHARGE)
		AND   LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE -- Don't delete PBH Children any time
	    	AND   PRICING_STATUS_CODE IN (QP_PREQ_GRP.G_STATUS_NEW,QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL);
		--End Bug No: 7691661


		UPDATE qp_npreq_ldets_tmp --upd4
		SET   PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW,
		      AUTOMATIC_FLAG = QP_PREQ_GRP.G_NO,
			 APPLIED_FLAG = QP_PREQ_GRP.G_NO
		WHERE LINE_INDEX = p_line_index
		AND   PRICING_PHASE_ID = p_pricing_phase_id
		AND   CREATED_FROM_LIST_LINE_ID <> p_list_line_id
		AND   ASK_FOR_FLAG = QP_PREQ_GRP.G_NO
		AND   CREATED_FROM_LIST_LINE_TYPE  IN (QP_PREQ_GRP.G_DISCOUNT,QP_PREQ_GRP.G_SURCHARGE)
		AND   LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE -- Don't delete PBH Children any time
	    	AND   PRICING_STATUS_CODE IN (QP_PREQ_GRP.G_STATUS_NEW,QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL);

	     /* UPDATE qp_npreq_line_attrs_tmp a
	     SET    a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
	     WHERE  a.LIST_LINE_ID
	      IN (SELECT b.CREATED_FROM_LIST_LINE_ID
			FROM  qp_npreq_ldets_tmp b
	          WHERE b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
		     AND   b.PRICING_PHASE_ID = p_pricing_phase_id
		     AND   b.INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
		     AND   b.CREATED_FROM_LIST_LINE_ID <> p_list_line_id
		     AND   ASK_FOR_FLAG = QP_PREQ_GRP.G_NO
		     AND   b.CREATED_FROM_LIST_LINE_TYPE  IN (QP_PREQ_GRP.G_DISCOUNT,QP_PREQ_GRP.G_SURCHARGE)
		     AND   b.LINE_INDEX = p_line_index)
	     AND   a.LINE_INDEX = p_line_index;  */

	 END IF; --p_exclusive_discount = TRUE
	ELSE -- Automatic discounts
	 IF (p_excl_discount = FALSE) THEN

/*
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd5,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd5,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.delete_incompatible_lines.upd5,qp_npreq_ldets_tmp_N1,PRICING_PHASE_ID,3
*/

	    	UPDATE qp_npreq_ldets_tmp --upd5
	    	SET PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC
	    	WHERE INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
	    	AND   LINE_INDEX = p_line_index
	    	AND   PRICING_PHASE_ID = p_pricing_phase_id
	    	AND   CREATED_FROM_LIST_LINE_ID <> p_list_line_id
		AND   LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE -- Don't delete PBH Children any time
	    	AND   PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;
	 ELSE
	    	UPDATE qp_npreq_ldets_tmp
	    	SET PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC
	    	WHERE LINE_INDEX = p_line_index
	    	AND   PRICING_PHASE_ID = p_pricing_phase_id
	    	AND   CREATED_FROM_LIST_LINE_ID <> p_list_line_id
		AND   LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE -- Don't delete PBH Children any time
	    	AND   PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;
	 END IF; -- p_exclusive_discount = FALSE
	END IF;

   IF (p_excl_discount = FALSE) THEN

     IF l_debug = FND_API.G_TRUE THEN
       QP_PREQ_GRP.engine_debug('Checking for PRG/OID losers in incompatibility group '||p_incomp_grp_id);
     END IF;

     -- [prarasto/4141235] delete loser prg/oid lines/ldets/attrs/rltd
     --frontported fix done in 41340888
     OPEN l_del_prg_lines_grp_cur;
     FETCH l_del_prg_lines_grp_cur
     BULK COLLECT INTO l_del_index_tbl;
     CLOSE l_del_prg_lines_grp_cur;

     IF (l_del_index_tbl.count > 0) THEN
       Delete_Lines_Complete(l_del_index_tbl, 'PRG DELETED BY INCOMPATIBILITY LOGIC', l_status_code, l_status_text);
     END IF;

     -- [prarasto/4141235] delete loser oid ldets/rltd
     --frontported fix done in 41340888
     OPEN l_del_oid_ldets_grp_cur;
     FETCH l_del_oid_ldets_grp_cur
     BULK COLLECT INTO l_del_index_tbl;
     CLOSE l_del_oid_ldets_grp_cur;

     IF (l_del_index_tbl.count > 0) THEN
       Delete_Ldets_Complete(l_del_index_tbl, 'OID DELETED BY INCOMPATIBILITY LOGIC', l_status_code, l_status_text);
     END IF;

   ELSE

     IF l_debug = FND_API.G_TRUE THEN
       QP_PREQ_GRP.engine_debug('Checking for PRG/OID losers to exclusive group line' );
     END IF;

     -- [prarasto/4141235] delete loser prg/oid lines/ldets/attrs/rltd, exclusive winner
     --frontported fix done in 41340888
     OPEN l_del_prg_lines_excl_cur;
     FETCH l_del_prg_lines_excl_cur
     BULK COLLECT INTO l_del_index_tbl;
     CLOSE l_del_prg_lines_excl_cur;

     IF (l_del_index_tbl.count > 0) THEN
       Delete_Lines_Complete(l_del_index_tbl, 'PRG DELETED BY INCOMPATIBILITY LOGIC', l_status_code, l_status_text);
     END IF;

     -- [prarasto/4141235] delete loser oid ldets/rltd, exclusive winner
     --frontported fix done in 41340888
     OPEN l_del_oid_ldets_excl_cur;
     FETCH l_del_oid_ldets_excl_cur
     BULK COLLECT INTO l_del_index_tbl;
     CLOSE l_del_oid_ldets_excl_cur;

     IF (l_del_index_tbl.count > 0) THEN
       Delete_Ldets_Complete(l_del_index_tbl, 'OID DELETED BY INCOMPATIBILITY LOGIC', l_status_code, l_status_text);
     END IF;

   END IF;

	x_return_status := v_return_status;
 EXCEPTION
    WHEN OTHERS THEN
     IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || SQLERRM);
     END IF;
     v_return_status := FND_API.G_RET_STS_ERROR;
     x_return_status := v_return_status;
 END Delete_Incompatible_Lines;

 PROCEDURE Best_Price_For_Phase(p_list_price 		 NUMBER,
					  	  p_line_index 		 NUMBER,
					  	  p_pricing_phase_id 	 NUMBER,
					  	  x_return_status     OUT NOCOPY VARCHAR2,
					  	  x_return_status_txt OUT NOCOPY VARCHAR2) AS
 -- Index Certificate

/*
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_for_phase.incomp_cur,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_for_phase.incomp_cur,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.best_price_for_phase.incomp_cur,qp_npreq_ldets_tmp_N1,PRICING_PHASE_ID,3
*/

 CURSOR incomp_cur(p_manual_dis_flag VARCHAR2) IS
 SELECT DISTINCT INCOMPATABILITY_GRP_CODE
 FROM   qp_npreq_ldets_tmp
 WHERE  PRICING_PHASE_ID = p_pricing_phase_id
 AND    INCOMPATABILITY_GRP_CODE IS NOT NULL
 AND    LINE_INDEX = p_line_index
 AND    ((AUTOMATIC_FLAG = QP_PREQ_GRP.G_YES AND p_manual_dis_flag = QP_PREQ_GRP.G_YES) OR
	   p_manual_dis_flag = QP_PREQ_GRP.G_NO)
 AND    PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW;


 x_list_line_id	NUMBER;
 v_return_status    VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
 x_ret_status       VARCHAR2(30);
 v_excl_flag        BOOLEAN := FALSE;
 v_manual_dis_flag  VARCHAR2(1) := nvl(QP_PREQ_GRP.G_MANUAL_DISCOUNT_FLAG,'Y');

 INVALID_BEST_PRICE EXCEPTION;

 v_routine_name CONSTANT VARCHAR2(240) := 'Routine:QP_Resolve_Incompatability_PVTRUN.Best_Price_For_Phase';

 BEGIN
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;

   --[julin/4116856] moved deletion of un-asked-for promotions to QP_PREQ_GRP

 /* UPDATE qp_npreq_line_attrs_tmp a
  SET    a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL
  WHERE  a.LIST_LINE_ID IN (SELECT b.CREATED_FROM_LIST_LINE_ID
				        FROM  qp_npreq_ldets_tmp b
				        WHERE b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL
					   AND   b.PRICING_PHASE_ID = p_pricing_phase_id
					   AND   b.ASK_FOR_FLAG = QP_PREQ_GRP.G_YES
				        AND   b.LINE_INDEX = p_line_index)
  AND    a.LINE_INDEX = p_line_index; */

  FOR i IN incomp_cur(v_manual_dis_flag)
  LOOP
   IF (v_excl_flag = FALSE) THEN
    -- Best Price Evaluation
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug('Best Price For Phase .....');
    END IF;
    Best_Price_Evaluation(p_list_price,
					  p_line_index,
				   	  p_pricing_phase_id,
					  i.INCOMPATABILITY_GRP_CODE,
                                          NULL,                        -- Added for bug#2661540
					  v_manual_dis_flag,
					  x_list_line_id,
					  x_ret_status);
    IF (x_ret_status = FND_API.G_RET_STS_ERROR) THEN
     RAISE INVALID_BEST_PRICE;
    END IF;
   END IF;
   -- Incomp_grp_id ='EXCL' has the highest priority(exclusivity)
   IF (i.INCOMPATABILITY_GRP_CODE = QP_PREQ_GRP.G_INCOMP_EXCLUSIVE) THEN
	v_excl_flag := TRUE;
   END IF;
   IF (v_excl_flag = FALSE) THEN
	 Delete_Incompatible_Lines(p_pricing_phase_id,
						 p_line_index,
						 i.INCOMPATABILITY_GRP_CODE,
						 x_list_line_id,
						 v_excl_flag,
						 v_manual_dis_flag,
						 x_ret_status);

   END IF;
  END LOOP;
  IF(v_excl_flag = TRUE) THEN
		Delete_Incompatible_Lines(p_pricing_phase_id,
							 p_line_index,
							 NULL, -- incomp_grp_id
							 x_list_line_id,
							 v_excl_flag,
							 v_manual_dis_flag,
							 x_ret_status);

  END IF;
 EXCEPTION
  WHEN INVALID_BEST_PRICE THEN
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || SQLERRM);
   END IF;
   x_return_status_txt := v_routine_name || ' ' || SQLERRM;
   v_return_status := QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR;
   x_return_status := v_return_status;
  WHEN OTHERS THEN
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug(v_routine_name || 'Unexpected Error');
   QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || SQLERRM);
   END IF;
   v_return_status := FND_API.G_RET_STS_ERROR;
   x_return_status := v_return_status;
 END Best_Price_For_Phase;

 PROCEDURE Resolve_Incompatability(p_pricing_phase_id 		NUMBER,
					     	p_processing_flag 		VARCHAR2,
					     	p_list_price 		     NUMBER,
					     	p_line_index 		     NUMBER,
					     	x_return_status     OUT NOCOPY  VARCHAR2,
					     	x_return_status_txt OUT NOCOPY  VARCHAR2) AS

   -- Index Certificate

/*
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.incomp_cur,qp_npreq_ldets_tmp_N1,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.incomp_cur,qp_npreq_ldets_tmp_N1,PRICING_STATUS_CODE,2
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.incomp_cur,qp_npreq_ldets_tmp_N1,PRICING_PHASE_ID,3
*/

   CURSOR incomp_cur(l_manual_dis_flag VARCHAR2) IS
   SELECT DISTINCT INCOMPATABILITY_GRP_CODE , PRICING_STATUS_CODE
   FROM   qp_npreq_ldets_tmp
   WHERE  PRICING_PHASE_ID = p_pricing_phase_id
   AND    INCOMPATABILITY_GRP_CODE IS NOT NULL
   AND    PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
   AND    ((AUTOMATIC_FLAG = QP_PREQ_GRP.G_YES AND l_manual_dis_flag = QP_PREQ_GRP.G_YES) OR
		l_manual_dis_flag = QP_PREQ_GRP.G_NO)
   AND    LINE_INDEX = p_line_index;

/*
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.each_incomp_cur,qp_npreq_ldets_tmp_N3,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.each_incomp_cur,qp_npreq_ldets_tmp_N3,PRICING_PHASE_ID,2
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.each_incomp_cur,qp_npreq_ldets_tmp_N3,ASK_FOR_FLAG,3

INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.each_incomp_cur,qp_npreq_line_attrs_tmp_N2,PRICING_STATUS_CODE,1
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.each_incomp_cur,qp_npreq_line_attrs_tmp_N2,ATTRIBUTE_TYPE,2
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.each_incomp_cur,qp_npreq_line_attrs_tmp_N2,CONTEXT,3
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.each_incomp_cur,qp_npreq_line_attrs_tmp_N2,ATTRIBUTE,4
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.each_incomp_cur,qp_npreq_line_attrs_tmp_N2,LINE_INDEX,5
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.each_incomp_cur,qp_npreq_line_attrs_tmp_N2,VALUE_FROM,6
*/

--UNION

/*
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.each_incomp_cur,qp_npreq_ldets_tmp_N3,LINE_INDEX,1
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.each_incomp_cur,qp_npreq_ldets_tmp_N3,PRICING_PHASE_ID,2
INDX,QP_Resolve_Incompatability_PVTRUN.resolve_incompatability.each_incomp_cur,qp_npreq_ldets_tmp_N3,ASK_FOR_FLAG,3
*/

   CURSOR each_incomp_cur(p_incomp_grp_id VARCHAR2,l_manual_dis_flag VARCHAR2) IS
   SELECT a.CREATED_FROM_LIST_HEADER_ID,a.CREATED_FROM_LIST_LINE_ID,a.INCOMPATABILITY_GRP_CODE,a.ASK_FOR_FLAG
   FROM qp_npreq_ldets_tmp a
   WHERE EXISTS (SELECT 'X'
                 FROM  qp_npreq_line_attrs_tmp b
                 WHERE a.LINE_INDEX = b.LINE_INDEX
                 AND b.ATTRIBUTE_TYPE = QP_PREQ_GRP.G_QUALIFIER_TYPE
                 AND b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_UNCHANGED
                 AND b.ATTRIBUTE IN (QP_PREQ_GRP.G_QUAL_ATTRIBUTE1,
                                     QP_PREQ_GRP.G_QUAL_ATTRIBUTE2,
                                     QP_PREQ_GRP.G_QUAL_ATTRIBUTE6)
                 AND b.CONTEXT = QP_PREQ_GRP.G_LIST_HEADER_CONTEXT
                 AND b.VALUE_FROM = decode(b.ATTRIBUTE,
                                    QP_PREQ_GRP.G_QUAL_ATTRIBUTE1,to_char(a.CREATED_FROM_LIST_HEADER_ID),
                                    QP_PREQ_GRP.G_QUAL_ATTRIBUTE2,to_char(a.CREATED_FROM_LIST_LINE_ID),
                                    QP_PREQ_GRP.G_QUAL_ATTRIBUTE6,to_char(a.CREATED_FROM_LIST_HEADER_ID)))
   AND a.ASK_FOR_FLAG = QP_PREQ_GRP.G_YES
   AND a.INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
   AND a.PRICING_PHASE_ID = p_pricing_phase_id
   AND a.LINE_INDEX = p_line_index
   AND a.LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE
   AND a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
   AND    ((a.AUTOMATIC_FLAG = QP_PREQ_GRP.G_YES AND l_manual_dis_flag = QP_PREQ_GRP.G_YES) OR
		  l_manual_dis_flag = QP_PREQ_GRP.G_NO)
   UNION
   SELECT a.CREATED_FROM_LIST_HEADER_ID,a.CREATED_FROM_LIST_LINE_ID,a.INCOMPATABILITY_GRP_CODE,'N' ASK_FOR_FLAG
   FROM qp_npreq_ldets_tmp a
   WHERE a.ASK_FOR_FLAG = QP_PREQ_GRP.G_NO -- Removed NVL , expect some issues
   AND a.INCOMPATABILITY_GRP_CODE = p_incomp_grp_id
   AND a.PRICING_PHASE_ID = p_pricing_phase_id
   AND a.LINE_INDEX = p_line_index
   AND a.LINE_DETAIL_TYPE_CODE <> QP_PREQ_GRP.G_CHILD_DETAIL_TYPE
   AND a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_NEW
   AND  ((a.AUTOMATIC_FLAG = QP_PREQ_GRP.G_YES AND l_manual_dis_flag = QP_PREQ_GRP.G_YES) OR
		l_manual_dis_flag = QP_PREQ_GRP.G_NO)
   ORDER BY 4 desc;

   v_this_is_the_list_line_id  NUMBER;
   v_first_list_line_id	      NUMBER;
   v_count                     NUMBER:= 0;
   v_others_flag               BOOLEAN:= TRUE;
   v_high_precedence           NUMBER;
   v_ask_for_flag              VARCHAR2(1);
   v_excl_flag				 BOOLEAN := FALSE;
   v_excl_list_line_id		 NUMBER;
   x_best_list_line_id		 NUMBER;
   x_ret_status  	           VARCHAR2(30);
   v_return_status  		 VARCHAR2(30) := FND_API.G_RET_STS_SUCCESS;
   v_routine_name CONSTANT     VARCHAR2(240):='Routine:QP_Resolve_Incompatability_PVTRUN.Resolve_Incompatability';
   p_manual_dis_flag           VARCHAR2(1) := nvl(QP_PREQ_GRP.G_MANUAL_DISCOUNT_FLAG,'Y');
   v_ask_for_constant          CONSTANT NUMBER := -100000;


   l_precedence_tbl precedence_tbl_type;

   v_precedence                NUMBER;
   v_counter                   NUMBER := 0;

   INVALID_INCOMPATIBILITY	EXCEPTION;
   INVALID_BEST_PRICE 		EXCEPTION;

   BEGIN
   l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
   IF l_debug = FND_API.G_TRUE THEN
   QP_PREQ_GRP.engine_debug ('S1');

   END IF;

   -- [julin/4116856] moved deletion of un-asked-for promotions to QP_PREQ_GRP


   /* UPDATE qp_npreq_line_attrs_tmp a
    SET    a.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC
    WHERE  a.LIST_LINE_ID IN (SELECT b.CREATED_FROM_LIST_LINE_ID
					       FROM  qp_npreq_ldets_tmp b
					       WHERE b.PRICING_STATUS_CODE = QP_PREQ_GRP.G_STATUS_INCOMP_LOGIC
						  AND   b.PRICING_PHASE_ID = p_pricing_phase_id
						  AND   b.ASK_FOR_FLAG = QP_PREQ_GRP.G_YES
					       AND   b.LINE_INDEX = p_line_index)
    AND    a.LINE_INDEX = p_line_index; */


    FOR i IN incomp_cur(p_manual_dis_flag)
    LOOP
    IF l_debug = FND_API.G_TRUE THEN
    QP_PREQ_GRP.engine_debug ('#2');

    END IF;
    l_precedence_tbl.delete;
    v_counter := 0;

     FOR j IN each_incomp_cur(i.INCOMPATABILITY_GRP_CODE,p_manual_dis_flag)
     LOOP
	 v_precedence := Precedence_For_List_Line(j.CREATED_FROM_LIST_HEADER_ID,j.CREATED_FROM_LIST_LINE_ID,
                                                  i.incompatability_grp_code, p_line_index,p_pricing_phase_id);
	  v_counter := v_counter + 1;
       l_precedence_tbl(v_counter).created_from_list_line_id := j.created_from_list_line_id;
       l_precedence_tbl(v_counter).incompatability_grp_code := j.incompatability_grp_code;
       l_precedence_tbl(v_counter).ask_for_flag := j.ask_for_flag;
       l_precedence_tbl(v_counter).original_precedence := v_precedence;
	  IF (j.ask_for_flag = QP_PREQ_GRP.G_YES) THEN
	   v_precedence := v_precedence + v_ask_for_constant;
       END IF;
       l_precedence_tbl(v_counter).product_precedence := v_precedence;
	END LOOP;

	-- Sort the table
    IF (l_precedence_tbl.COUNT > 0 ) THEN
     --sort_on_precedence(l_precedence_tbl, l_precedence_tbl.FIRST, l_precedence_tbl.LAST);
     sort_on_precedence(l_precedence_tbl);
    END IF;

    IF (l_precedence_tbl.COUNT > 0) THEN
     FOR j IN l_precedence_tbl.FIRST .. l_precedence_tbl.LAST
     LOOP
         IF l_debug = FND_API.G_TRUE THEN
         QP_PREQ_GRP.engine_debug ('#3');

         END IF;
	    -- Store the first list_line_id
	    IF (v_count = 0) THEN
		v_first_list_line_id := l_precedence_tbl(j).CREATED_FROM_LIST_LINE_ID;
  IF l_debug = FND_API.G_TRUE THEN
		QP_PREQ_GRP.engine_debug('The First List Line Id : ' || v_first_list_line_id);
		QP_PREQ_GRP.engine_debug('Pricing Status Code: ' || i.pricing_status_code);
  END IF;
		v_high_precedence := l_precedence_tbl(j).ORIGINAL_PRECEDENCE;
		v_ask_for_flag := l_precedence_tbl(j).ASK_FOR_FLAG;
	    END IF;
         IF l_debug = FND_API.G_TRUE THEN
    	    QP_PREQ_GRP.engine_debug ('#4');

         END IF;
	    -- Incomp_grp_id ='EXCL' has the highest priority(exclusivity)
	    IF (i.INCOMPATABILITY_GRP_CODE = QP_PREQ_GRP.G_INCOMP_EXCLUSIVE) THEN
		IF(v_count = 0) THEN
		 	v_this_is_the_list_line_id := l_precedence_tbl(j).CREATED_FROM_LIST_LINE_ID;
			v_excl_list_line_id := l_precedence_tbl(j).CREATED_FROM_LIST_LINE_ID;
		 	--v_others_flag := FALSE;
		 	v_excl_flag := TRUE;
		ELSE  -- If there are multiple list lines in EXCL incomp
		 IF (v_others_flag = TRUE) THEN
     	   	IF (v_high_precedence = l_precedence_tbl(j).ORIGINAL_PRECEDENCE) THEN
			   IF ((v_ask_for_flag = QP_PREQ_GRP.G_YES and l_precedence_tbl(j).ASK_FOR_FLAG = QP_PREQ_GRP.G_YES) OR
				  (v_ask_for_flag = QP_PREQ_GRP.G_NO and l_precedence_tbl(j).ASK_FOR_FLAG = QP_PREQ_GRP.G_NO)) THEN
			     -- Best Price Evaluation
			    IF (p_processing_flag = QP_PREQ_GRP.G_DISCOUNT_PROCESSING) THEN
        IF l_debug = FND_API.G_TRUE THEN
			     QP_PREQ_GRP.engine_debug ('Best Price Evaluation');
        END IF;
				IF (p_list_price IS NOT NULL) THEN
			      Best_Price_Evaluation(p_list_price,
                                                    p_line_index,
                                                    p_pricing_phase_id,
						    i.INCOMPATABILITY_GRP_CODE,
                                                    v_high_precedence,         -- Added for bug#2661540
                                                    p_manual_dis_flag,
                                                    x_best_list_line_id,
						    x_ret_status);
         IF l_debug = FND_API.G_TRUE THEN
			      QP_PREQ_GRP.engine_debug('Successful Best Price Eval');
         END IF;
                     IF x_ret_status in (QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR,FND_API.G_RET_STS_ERROR) THEN
				  RAISE INVALID_BEST_PRICE;
  			      END IF;
			      v_this_is_the_list_line_id := x_best_list_line_id;
				 v_excl_list_line_id := x_best_list_line_id;
			      v_others_flag := FALSE;
				END IF;
			    END IF;
			   ELSIF (v_ask_for_flag=QP_PREQ_GRP.G_NO and l_precedence_tbl(j).ASK_FOR_FLAG = QP_PREQ_GRP.G_YES) THEN
			     v_this_is_the_list_line_id := l_precedence_tbl(j).CREATED_FROM_LIST_LINE_ID;
				v_excl_list_line_id := l_precedence_tbl(j).CREATED_FROM_LIST_LINE_ID;
			     v_others_flag := FALSE;
			   END IF;
		     ELSE
			   IF (v_ask_for_flag = QP_PREQ_GRP.G_NO and l_precedence_tbl(j).ASK_FOR_FLAG = QP_PREQ_GRP.G_YES) THEN
			    v_this_is_the_list_line_id := l_precedence_tbl(j).CREATED_FROM_LIST_LINE_ID;
			    v_excl_list_line_id := l_precedence_tbl(j).CREATED_FROM_LIST_LINE_ID;
			    v_others_flag := FALSE;
			   END IF;
	   	     END IF;
		  END IF;
		END IF;
	    END IF;
         IF l_debug = FND_API.G_TRUE THEN
         QP_PREQ_GRP.engine_debug ('#5');

         END IF;
	    IF (v_others_flag = TRUE and v_excl_flag = FALSE) THEN
      IF l_debug = FND_API.G_TRUE THEN
		    QP_PREQ_GRP.engine_debug('Others_Flag: TRUE');
      END IF;
		    null;
	    ELSE
      IF l_debug = FND_API.G_TRUE THEN
		    QP_PREQ_GRP.engine_debug('Others_Flag: FALSE');
      END IF;
		    null;
	    END IF;
         IF l_debug = FND_API.G_TRUE THEN
         QP_PREQ_GRP.engine_debug ('#6');
	    QP_PREQ_GRP.engine_debug('Count: ' || v_count);

         END IF;
	    IF (v_others_flag = TRUE) THEN
		   -- If it is an asked for promo
 		    IF (v_count > 0) THEN -- Do not compare the first time for the first record
       IF l_debug = FND_API.G_TRUE THEN
		     QP_PREQ_GRP.engine_debug ('Precedence1:' || v_high_precedence);
		     QP_PREQ_GRP.engine_debug ('Precedence2:' || l_precedence_tbl(j).ORIGINAL_PRECEDENCE);
		     QP_PREQ_GRP.engine_debug ('Ask_For_Flag1:' || v_ask_for_flag);
		     QP_PREQ_GRP.engine_debug ('Ask_For_FLag2:' || l_precedence_tbl(j).ASK_FOR_FLAG);
		     QP_PREQ_GRP.engine_debug ('Second List Line Id:' || l_precedence_tbl(j).CREATED_FROM_LIST_LINE_ID);
    		     QP_PREQ_GRP.engine_debug ('#7');
       END IF;
     	   	IF (v_high_precedence = l_precedence_tbl(j).ORIGINAL_PRECEDENCE) THEN
			   IF ((v_ask_for_flag = QP_PREQ_GRP.G_YES and l_precedence_tbl(j).ASK_FOR_FLAG = QP_PREQ_GRP.G_YES) OR
				  (v_ask_for_flag = QP_PREQ_GRP.G_NO and l_precedence_tbl(j).ASK_FOR_FLAG = QP_PREQ_GRP.G_NO)) THEN
			     -- Best Price Evaluation
			    IF (p_processing_flag = QP_PREQ_GRP.G_DISCOUNT_PROCESSING) THEN
        IF l_debug = FND_API.G_TRUE THEN
			     QP_PREQ_GRP.engine_debug ('Best Price Evaluation');
        END IF;
				IF (p_list_price IS NOT NULL) THEN
                                    Best_Price_Evaluation(p_list_price,
                                                          p_line_index,
                                                          p_pricing_phase_id,
					    	          i.INCOMPATABILITY_GRP_CODE,
                                                          v_high_precedence,        -- Added for bug#2661540
                                                          p_manual_dis_flag,
                                                          x_best_list_line_id,
							  x_ret_status);
         IF l_debug = FND_API.G_TRUE THEN
			      QP_PREQ_GRP.engine_debug('Successful Best Price Eval1');
         END IF;
                     IF x_ret_status in (QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR,FND_API.G_RET_STS_ERROR) THEN
				  RAISE INVALID_BEST_PRICE;
  			      END IF;
			      v_this_is_the_list_line_id := x_best_list_line_id;
			      v_others_flag := FALSE;
				END IF;
			    ELSE -- PRICE_LIST
				RAISE INVALID_INCOMPATIBILITY;
			    END IF;
			   ELSIF (v_ask_for_flag=QP_PREQ_GRP.G_NO and l_precedence_tbl(j).ASK_FOR_FLAG = QP_PREQ_GRP.G_YES) THEN
			     v_this_is_the_list_line_id := l_precedence_tbl(j).CREATED_FROM_LIST_LINE_ID;
			     v_others_flag := FALSE;
			   END IF;
		     ELSE
			   IF (v_ask_for_flag = QP_PREQ_GRP.G_NO and l_precedence_tbl(j).ASK_FOR_FLAG = QP_PREQ_GRP.G_YES) THEN
			    v_this_is_the_list_line_id := l_precedence_tbl(j).CREATED_FROM_LIST_LINE_ID;
			    v_others_flag := FALSE;
			   END IF;
	   	     END IF;
		    END IF;
	    END IF;
      IF l_debug = FND_API.G_TRUE THEN
    		QP_PREQ_GRP.engine_debug ('#8');
      END IF;
	    v_count := v_count + 1;
      END LOOP;
     END IF; -- l_precedence_tbl.COUNT > 0

	    v_count := 0; -- Reinit to 0 for an incomp grp id
	    v_others_flag := TRUE;
	    IF (v_this_is_the_list_line_id IS NOT NULL) THEN
		v_first_list_line_id := v_this_is_the_list_line_id;
  IF l_debug = FND_API.G_TRUE THEN
		QP_PREQ_GRP.engine_debug('The List Line Id : ' || v_first_list_line_id);
  END IF;
	    END IF;
	    v_this_is_the_list_line_id := null; -- Reset

     IF l_debug = FND_API.G_TRUE THEN
	    QP_PREQ_GRP.engine_debug('Before Update ......');
	    QP_PREQ_GRP.engine_debug('Incomp Grp Code:' || i.INCOMPATABILITY_GRP_CODE);
	    QP_PREQ_GRP.engine_debug('List Line Id:' || v_first_list_line_id);
	    QP_PREQ_GRP.engine_debug('Pricing Phase Id:' || p_pricing_phase_id);
         QP_PREQ_GRP.engine_debug ('#9');

     END IF;
	    -- Update all the other list lines to status 'I' for each incomp grp
	    IF (v_excl_flag = FALSE) THEN
		 Delete_Incompatible_Lines(p_pricing_phase_id,
							 p_line_index,
							 i.INCOMPATABILITY_GRP_CODE,
							 v_first_list_line_id,
							 v_excl_flag,
							 p_manual_dis_flag,
							 x_ret_status);
	    END IF;
         IF l_debug = FND_API.G_TRUE THEN
    	    QP_PREQ_GRP.engine_debug ('#10');
         END IF;
     END LOOP;
	IF (v_excl_flag = TRUE) THEN
		Delete_Incompatible_Lines(p_pricing_phase_id,
							 p_line_index,
							 NULL, -- incomp_grp_id
							 v_excl_list_line_id,
							 v_excl_flag,
							 p_manual_dis_flag,
							 x_ret_status);
	END IF;
	x_return_status := v_return_status; -- SUCCESS
   EXCEPTION
    WHEN INVALID_INCOMPATIBILITY THEN
     IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug(v_routine_name || ' Multiple Price Lists cannot have same precedence
								  and cannot be asked for');
     END IF;
     x_return_status_txt := v_routine_name || ' Multiple Price Lists cannot have same precedence
								  and cannot be asked for';
     v_return_status := QP_PREQ_GRP.G_STATUS_INVALID_INCOMP;
     x_return_status := v_return_status;
    WHEN INVALID_BEST_PRICE THEN
     IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug(v_routine_name || 'Best Price Evaluation Has Error');
     END IF;
     x_return_status_txt := v_routine_name || 'Best Price Evaluation Has Error';
     v_return_status := QP_PREQ_GRP.G_STATUS_BEST_PRICE_EVAL_ERROR;
     x_return_status := v_return_status;
    WHEN OTHERS THEN
     IF l_debug = FND_API.G_TRUE THEN
     QP_PREQ_GRP.engine_debug(v_routine_name || ' ' || SQLERRM);
     END IF;
     x_return_status_txt := v_routine_name || ' ' || SQLERRM;
     v_return_status := FND_API.G_RET_STS_ERROR;
     x_return_status := v_return_status;
   END Resolve_Incompatability;

END QP_Resolve_Incompatability_PVT ;

/
