--------------------------------------------------------
--  DDL for Package Body MRP_CL_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_CL_FUNCTION" AS
/* $Header: MRPCLHAB.pls 120.12.12010000.3 2008/08/25 10:48:56 sbyerram ship $ */
-- ===============================================================


   G_BOM_GREATER_THAN_EQUAL_J     NUMBER := 1;

   G_BOM_LESS_THAN_J              NUMBER := 0;

   G_AHL_GREATER_THAN_EQUAL_J     NUMBER := 1;

   G_AHL_LESS_THAN_J              NUMBER := 0;


   G_WSH_GREATER_THAN_EQUAL_J     NUMBER := 1;

   G_WSH_LESS_THAN_J              NUMBER := 0;

   PROCEDURE APPS_INITIALIZE(
                       p_user_name        IN  VARCHAR2,
                       p_resp_name        IN  VARCHAR2,
                       p_application_name IN  VARCHAR2 )
   IS
      lv_application_id    NUMBER;

   BEGIN

     SELECT APPLICATION_ID
       INTO lv_application_id
       FROM FND_APPLICATION_VL
      WHERE APPLICATION_NAME = p_application_name;

     APPS_INITIALIZE (p_user_name,
                      p_resp_name,
                      p_application_name,
                      lv_application_id);

   END APPS_INITIALIZE;

   /* -- Added this procedure to accept application_id instead of application_name */

   PROCEDURE APPS_INITIALIZE(
                       p_user_name        IN  VARCHAR2,
                       p_resp_name        IN  VARCHAR2,
                       p_application_name IN  VARCHAR2,
                       p_application_id   IN  NUMBER )
   IS
      lv_user_id           NUMBER;
      lv_resp_id           NUMBER;
      lv_application_id    NUMBER;
      lv_log_msg           VARCHAR2(500);

   BEGIN

    IF FND_GLOBAL.USER_ID = -1 THEN
       /* if user_id = -1, it means this initialization process is needed */

        BEGIN
            SELECT USER_ID
               INTO lv_user_id
               FROM FND_USER
             WHERE USER_NAME = p_user_name;
        EXCEPTION
         WHEN NO_DATA_FOUND THEN
              raise_application_error (-20001, 'User not defined on Source instance');
        END;

        IF MRP_CL_FUNCTION.validateUser(lv_user_id,MSC_UTIL.TASK_COLL,lv_log_msg) THEN
            MRP_CL_FUNCTION.MSC_Initialize(MSC_UTIL.TASK_COLL,
                                           lv_user_id,
                                           -1, --l_resp_id,
                                           -1 --l_application_id
                                           );
        ELSE
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  lv_log_msg);
            raise_application_error (-20001, lv_log_msg);
        END IF;

     END IF;

   END APPS_INITIALIZE;

   FUNCTION Default_ABC_Assignment_Group ( p_org_id NUMBER)
     RETURN NUMBER IS

     CURSOR c1( ORG_ID NUMBER) IS
     SELECT default_abc_assignment_group
       FROM MRP_PARAMETERS
      WHERE ORGANIZATION_ID = ORG_ID;

     lv_res  NUMBER:= NULL;

   BEGIN

     FOR c_rec IN c1(p_org_id) LOOP

         lv_res:= c_rec.default_abc_assignment_group;

     END LOOP;

     RETURN lv_res;

   END;

FUNCTION mrp_resource_cost(p_item_id in number,
			 p_org_id  in number,
                        p_primary_cost_method in number)
RETURN NUMBER IS

  CURSOR COST_C IS
  SELECT NVL(cst.tl_resource,0)
	+ NVL(cst.tl_overhead,0)
	+ NVL(cst.tl_material_overhead,0)
	+ NVL(cst.tl_outside_processing,0)
  FROM cst_item_costs cst,
       cst_cost_types cct
  WHERE cct.costing_method_type = p_primary_cost_method
    AND cct.cost_type_id = DECODE(p_primary_cost_method,1,1,2,2,1)
    AND cst.cost_type_id = cct.cost_type_id
    AND cst.inventory_item_id = p_item_id
    AND cst.organization_id = p_org_id;

  CURSOR COST_C2 IS
  SELECT NVL(cst.tl_resource,0)
	+ NVL(cst.tl_overhead,0)
	+ NVL(cst.tl_material_overhead,0)
	+ NVL(cst.tl_outside_processing,0)
  FROM cst_cost_types cct,
	cst_item_costs cst
  WHERE cst.cost_type_id = cct.default_cost_type_id
    AND cct.costing_method_type = p_primary_cost_method
    AND cct.cost_type_id = DECODE(p_primary_cost_method,1,1,2,2,1)
    AND cst.inventory_item_id = p_item_id
    AND cst.organization_id = p_org_id;

  l_cost	NUMBER:= NULL;

BEGIN

  OPEN COST_C;
  FETCH COST_C into l_cost;
  CLOSE COST_C;

  IF l_cost IS NULL THEN

  OPEN COST_C2;
  FETCH COST_C2 into l_cost;
  CLOSE COST_C2;

  END IF;

  RETURN(l_cost);

END mrp_resource_cost;


FUNCTION mrp_item_cost(p_item_id in number,
			 p_org_id  in number,
                        p_primary_cost_method in number)
RETURN NUMBER IS

  CURSOR COST_C IS
  SELECT NVL(cst.item_cost,0)
  FROM cst_item_costs cst,
       cst_cost_types cct
  WHERE cct.costing_method_type = p_primary_cost_method
    AND cct.cost_type_id = DECODE(p_primary_cost_method,1,1,2,2,1)
    AND cst.cost_type_id = cct.cost_type_id
    AND cst.inventory_item_id = p_item_id
    AND cst.organization_id = p_org_id;

  CURSOR COST_C2 IS
  SELECT NVL(cst.item_cost,0)
  FROM cst_cost_types cct,
	cst_item_costs cst
  WHERE cst.cost_type_id = cct.default_cost_type_id
    AND cct.costing_method_type = p_primary_cost_method
    AND cct.cost_type_id = DECODE(p_primary_cost_method,1,1,2,2,1)
    AND cst.inventory_item_id = p_item_id
    AND cst.organization_id = p_org_id;

  l_cost	NUMBER:= NULL;

BEGIN

  OPEN COST_C;
  FETCH COST_C into l_cost;
  CLOSE COST_C;

  IF l_cost IS NULL THEN

  OPEN COST_C2;
  FETCH COST_C2 into l_cost;
  CLOSE COST_C2;

  END IF;


  RETURN(l_cost);

END mrp_item_cost;


FUNCTION mrp_item_list_price(arg_item_id in number,
	                     arg_org_id  in number,
                             arg_uom_code in varchar2,
			     arg_process_flag in varchar2,
			     arg_primary_cost_method in number)
 RETURN NUMBER
 IS

/* according to bug 1221049, we use the new cursor definition recommended by
   QP team(product 495).

   CURSOR PRICE_C IS
   SELECT round(list_price,NVL(spl.rounding_factor,2))
     from oe_price_list_lines sopl,
          oe_price_lists spl
   where spl.price_list_id  = arg_price_list_id
   and   sopl.price_list_id  = spl.price_list_id
   and   sopl.inventory_item_id = arg_item_id
   and   nvl(sopl.unit_code,' ') = nvl(arg_uom_code,' ')
   and   sysdate between nvl(sopl.start_date_active, sysdate-1)
		  and nvl(sopl.end_date_active, sysdate+1);
*/

/* For the bug # 2070983, adding + 0 to qpl.list_header_id to avoid the range
 * scan on the index  QP_LIST_LINES_U1, instead it will now do a unique scan
 * on the index QP_LIST_LINES_PK
 */

/* For Bug 2113445, converting rounding factor to follow OM rounding convention
   by multiplying it by -1
*/
   CURSOR PRICE_D ( p_item_id       IN VARCHAR2,
                    p_uom_code      IN VARCHAR2) IS
/*
   select round(operand,-1*(nvl(qplh.rounding_factor,2)))
     from qp_list_headers_b qplh,
          qp_list_lines qpl,
          qp_pricing_attributes qpa
    where qplh.list_header_id = p_price_list_id
      and qpl.list_header_id + 0 = qplh.list_header_id
      and qpl.list_line_id = qpa.list_line_id
      and qpa.product_attribute_context = 'ITEM'
      and qpa.product_attribute = 'PRICING_ATTRIBUTE1'
      and qpa.product_attr_value = p_item_id
      and ( qpa.product_uom_code = p_uom_code
            OR ( qpa.product_uom_code IS NULL
                 AND p_uom_code IS NULL))
      and ( qpl.start_date_active <= sysdate
            OR qpl.start_date_active IS NULL)
      and ( qpl.end_date_active >= sysdate
            OR qpl.end_date_active IS NULL);
*/
/* For Bug 2230228, based on QP Teams suggestion*/
     SELECT ROUND(QPL.OPERAND,-1 * (NVL(QPLH.ROUNDING_FACTOR,2)))
       FROM
         QP_PRICING_ATTRIBUTES QPA  ,
         QP_LIST_LINES QPL,
         QP_LIST_HEADERS_B QPLH
     WHERE QPA.PRICING_PHASE_ID = 1
     AND QPA.QUALIFICATION_IND = 4
     AND QPA.PRODUCT_ATTRIBUTE_CONTEXT = 'ITEM'
     AND QPA.PRODUCT_ATTRIBUTE = 'PRICING_ATTRIBUTE1'
     AND QPA.PRODUCT_ATTR_VALUE = p_item_id
     AND QPA.LIST_HEADER_ID = v_price_list_id
     AND QPL.LIST_LINE_ID = QPA.LIST_LINE_ID
     AND QPL.LIST_HEADER_ID = QPLH.LIST_HEADER_ID
     AND QPA.PRODUCT_UOM_CODE = p_uom_code
     AND (QPL.START_DATE_ACTIVE <= SYSDATE  OR QPL.START_DATE_ACTIVE IS NULL )
     AND (QPL.END_DATE_ACTIVE >= SYSDATE  OR QPL.END_DATE_ACTIVE IS NULL) ;

   CURSOR PRICE_D_NULL_UOM( p_item_id       IN VARCHAR2)
                    IS
     SELECT ROUND(QPL.OPERAND,-1 * (NVL(QPLH.ROUNDING_FACTOR,2)))
       FROM QP_PRICING_ATTRIBUTES QPA  ,
            QP_LIST_LINES QPL,
            QP_LIST_HEADERS_B QPLH
     WHERE QPA.PRICING_PHASE_ID = 1
       AND QPA.QUALIFICATION_IND = 4
       AND QPA.PRODUCT_ATTRIBUTE_CONTEXT = 'ITEM'
       AND QPA.PRODUCT_ATTRIBUTE = 'PRICING_ATTRIBUTE1'
       AND QPA.PRODUCT_ATTR_VALUE = p_item_id
       AND QPA.LIST_HEADER_ID = v_price_list_id
       AND QPL.LIST_LINE_ID = QPA.LIST_LINE_ID
       AND QPL.LIST_HEADER_ID = QPLH.LIST_HEADER_ID
       AND QPA.PRODUCT_UOM_CODE IS NULL
       AND (QPL.START_DATE_ACTIVE <= SYSDATE  OR QPL.START_DATE_ACTIVE IS NULL )
       AND (QPL.END_DATE_ACTIVE >= SYSDATE  OR QPL.END_DATE_ACTIVE IS NULL) ;

	lv_price number:= NULL;
BEGIN

   IF arg_uom_code IS NULL  THEN
      OPEN  PRICE_D_NULL_UOM(arg_item_id);
      FETCH PRICE_D_NULL_UOM into lv_price;
      CLOSE PRICE_D_NULL_UOM;
   ELSE
      OPEN  PRICE_D( arg_item_id, arg_uom_code);
      FETCH PRICE_D into lv_price;
      CLOSE PRICE_D;
   END IF;

  /* OPM Team - OPM INventoryConvergence Project
     OPM will not have separate price lists
   IF (lv_price IS NULL) AND (arg_process_flag = 'Y') THEN
      lv_price:= gmp_aps_output_pkg.retrieve_price_list
                               (arg_item_id,
                                arg_org_id);
   END IF;
   */

   RETURN lv_price;

EXCEPTION

   WHEN OTHERS THEN RETURN NULL;

END mrp_item_list_price;


FUNCTION mrp_item_supp_price(p_item_id in number,
                             p_asl_id  in number)
RETURN NUMBER IS

  CURSOR c_po_line IS
  SELECT  DOCUMENT_HEADER_ID    ,   DOCUMENT_LINE_ID
  FROM    po_asl_documents
  WHERE   asl_id = p_asl_id
    AND   using_organization_id = -1
    AND   DOCUMENT_TYPE_CODE = 'BLANKET'; --??

  CURSOR c_unit_price(c_header_id in number,
                      c_line_id in number) IS
  SELECT NVL(pll.unit_price,0) unit_price
  FROM   po_lines_all pll
  WHERE  po_line_id = c_line_id
  and    po_header_id = c_header_id
  and    item_id = p_item_id
  and    (pll.cancel_date is null OR
          pll.cancel_date >= SYSDATE)
  and    (pll.closed_date is null OR
          pll.closed_date >= SYSDATE)
  and    (pll.expiration_date is null OR
          pll.expiration_date >= SYSDATE);

l_header_id number;
l_line_id number;
l_unit_price number;

BEGIN
l_unit_price := -1;
FOR c_rec in c_po_line
LOOP
   BEGIN
       For c_rec1 in c_unit_price(c_rec.DOCUMENT_HEADER_ID,
                                  c_rec.DOCUMENT_LINE_ID)
       LOOP
          IF c_rec1.unit_price > l_unit_price then
             l_unit_price := c_rec1.unit_price;
          END IF;
       END LOOP;
   END;
END LOOP;
IF l_unit_price = -1 THEN
RETURN (NULL);
ELSE
RETURN(l_unit_price);
END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
    WHEN OTHERS THEN RETURN NULL;
END mrp_item_supp_price;


/* This is being added corresponding to bug : 2062398. */
FUNCTION mrp_rev_cum_yield(p_wip_entity_id  IN NUMBER,
                           p_org_id         IN NUMBER,
                           p_bill_seq_id    IN NUMBER,
                           p_co_prod_supply IN NUMBER)
RETURN NUMBER IS
l_rev_cum          number := 1;
v_split            number;
qty_to_move        number;
curr_op_seq_id     number;
v_curr_op_seq_num  number;

v_sql_stmt1      varchar2(1000);
v_sql_stmt2      varchar2(1000);

BEGIN

     begin

        v_sql_stmt1 :=  ' SELECT bos.Operation_Seq_Num, nvl(bos.reverse_cumulative_yield,1), wo.quantity_waiting_to_move '
                      ||'             , nvl(wo.operation_sequence_id,wo.previous_operation_seq_id) '
                      ||' FROM   MRP_SN_OPR_SEQS bos,                  '
                      ||'        MRP_SN_WOPRS wo                       '
                      ||' WHERE  wo.organization_id =  :p_org_id       '
                      ||' AND    wo.wip_entity_id =  :p_wip_entity_id  '
                      ||' AND    (wo.quantity_in_queue <> 0 OR         '
                      ||'         wo.quantity_running  <> 0 OR         '
                      ||'         wo.quantity_waiting_to_move <> 0)    '
                      ||' AND nvl(wo.operation_sequence_id,wo.previous_operation_seq_id) = bos.operation_sequence_id ';

        EXECUTE IMMEDIATE  v_sql_stmt1
                     INTO  v_curr_op_seq_num, l_rev_cum, qty_to_move, curr_op_seq_id
                    USING  p_org_id, p_wip_entity_id;

     exception
       when others then
             l_rev_cum := l_rev_cum;
     end;

    /* for bug: 2488331 get the RCY of next primary operation from the network, if the job is moved to to_move stage or
         it is jumped to another opern and is in to_move stage */

   IF (qty_to_move <> 0) THEN

       begin
          v_sql_stmt2 :=  ' SELECT   nvl(bos.reverse_cumulative_yield,1)              '
                        ||'  FROM    MRP_SN_OPR_SEQS bos,                             '
                        ||'          MRP_SN_OPR_NETWORKS bon                          '
                        ||' WHERE    bon.from_op_seq_id  =  :curr_op_seq_id           '
                        ||'  AND     bon.to_op_seq_id    =  bos.operation_sequence_id '
                        ||'  AND     bon.transition_type =  1                         ';

          EXECUTE IMMEDIATE  v_sql_stmt2
                       INTO  l_rev_cum
                      USING  curr_op_seq_id;

       exception
           when others then
               l_rev_cum := l_rev_cum;
       end;

   END IF;

     /* if the co-product flag on the job is yes , the apply the co-product split */
   IF (p_co_prod_supply = 1) THEN
       begin
           SELECT  nvl(wsc.split,100)
             INTO  v_split
             FROM  wsm_Co_products wsc
            WHERE  wsc.bill_sequence_id is not null
              AND  wsc.split > 0
              AND  wsc.bill_Sequence_id = p_bill_seq_id;

           v_split := v_split/100;
           l_rev_cum := v_split*l_rev_cum;

       exception
          when others then
             l_rev_cum := l_rev_cum;
       end;

   END IF;

RETURN(l_rev_cum);

EXCEPTION
    WHEN OTHERS THEN
         RETURN 1;

END mrp_rev_cum_yield;


/*This is added to get the reverse cumulative yield for the current operation from the job details */
FUNCTION mrp_jd_rev_cum_yield(p_wip_entity_id  IN NUMBER,
                           p_org_id         IN NUMBER,
                           p_bill_seq_id    IN NUMBER,
                           p_co_prod_supply IN NUMBER)
RETURN NUMBER IS
l_rev_cum          number := 1;
lv_status          number := 0;
v_split            number;
qty_to_move        number;
curr_op_seq_id     number;
v_curr_op_seq_num  number;

v_sql_stmt1      varchar2(1000);
v_sql_stmt2      varchar2(1000);

BEGIN

     begin

     v_sql_stmt1 := ' Select wdj.status_type, decode(wdj.status_type, 1, (select nvl(bos.reverse_cumulative_yield,1) from MRP_SN_LJ_OPRS bos where bos.wip_entity_id = wdj.wip_entity_id and upper(bos.Network_start_end) = ''S''),1) from '
                    ||'  MRP_SN_DSCR_JOBS wdj '
                    ||'  Where wdj.wip_entity_id = :p_wip_entity_id ';

                    EXECUTE IMMEDIATE  v_sql_stmt1
                     INTO  lv_status, l_rev_cum
                    USING  p_wip_entity_id;
      exception
       when others then
             l_rev_cum := l_rev_cum;
     end;

     if lv_status <> 1 then

     begin

        v_sql_stmt1 :=  ' SELECT bos.Operation_Seq_Num, nvl(bos.reverse_cumulative_yield,1), wo.quantity_waiting_to_move '
                      ||'             , nvl(wo.operation_sequence_id,wo.previous_operation_seq_id) '
                      ||' FROM   MRP_SN_LJ_OPRS bos,                  '
                      ||'        MRP_SN_WOPRS wo    '
                      ||' WHERE  wo.organization_id =  :p_org_id       '
                      ||' AND    wo.wip_entity_id =  :p_wip_entity_id  '
                      ||' AND    (wo.quantity_in_queue <> 0 OR         '
                      ||'         wo.quantity_running  <> 0 OR         '
                      ||'         wo.quantity_waiting_to_move <> 0)    '
                      ||' AND    bos.wip_entity_id = wo.wip_entity_id  '
                      ||' AND nvl(wo.operation_sequence_id,wo.previous_operation_seq_id) = bos.operation_sequence_id ';

        EXECUTE IMMEDIATE  v_sql_stmt1
                     INTO  v_curr_op_seq_num, l_rev_cum, qty_to_move, curr_op_seq_id
                    USING  p_org_id, p_wip_entity_id;

     exception
       when others then
             l_rev_cum := l_rev_cum;
     end;

    /* for bug: 2488331 get the RCY of next primary operation from the network, if the job is moved to to_move stage or
         it is jumped to another opern and is in to_move stage */

   IF (qty_to_move <> 0) THEN

       begin
          v_sql_stmt2 :=  ' SELECT   nvl(bos.reverse_cumulative_yield,1)              '
                        ||'  FROM    MRP_SN_LJ_OPRS bos,                             '
                        ||'          MRP_SN_LJ_OPR_NWK bon                          '
                        ||' WHERE    bon.from_op_seq_id  =  :curr_op_seq_id           '
                        ||'  AND     bon.wip_entity_id = :p_wip_entity_id    '
                        ||'  AND     bon.wip_entity_id = bos.wip_entity_id   '
                        ||'  AND     bon.to_op_seq_id    =  bos.operation_sequence_id '
                        ||'  AND     bon.transition_type =  1                         ';

          EXECUTE IMMEDIATE  v_sql_stmt2
                       INTO  l_rev_cum
                      USING  curr_op_seq_id, p_wip_entity_id;

       exception
           when others then
               l_rev_cum := l_rev_cum;
       end;

   END IF;

   END IF;

     /* if the co-product flag on the job is yes , the apply the co-product split */
   IF (p_co_prod_supply = 1) THEN
       begin
           SELECT  nvl(wsc.split,100)
             INTO  v_split
             FROM  wsm_Co_products wsc
            WHERE  wsc.bill_sequence_id is not null
              AND  wsc.split > 0
              AND  wsc.bill_Sequence_id = p_bill_seq_id;

           v_split := v_split/100;
           l_rev_cum := v_split*l_rev_cum;

       exception
          when others then
             l_rev_cum := l_rev_cum;
       end;

   END IF;

RETURN(l_rev_cum);

EXCEPTION
    WHEN OTHERS THEN
         RETURN 1;

END mrp_jd_rev_cum_yield;


/* modified this func to consider the co-product supply for bug:2401445 */
FUNCTION mrp_rev_cum_yield_unreleased(p_wip_entity_id in number,
                                      p_org_id  in number,
                                      p_bill_seq_id   in number,
                                      p_co_prod_supply in number)
RETURN NUMBER IS

   	v_op_seq_num number;
   	v_operation_sequence_id number;
   	x_err_msg varchar2(2000);
   	x_err_code  number;
   	e_user_exception EXCEPTION;
	p_common_routing_sequence_id NUMBER;
        lv_rev_cum number;
        v_routing_seq_id number;

        v_split number;

BEGIN

      lv_rev_cum := 1;
      v_split := 0;

   Begin

      SELECT  nvl(wdj.common_routing_sequence_id,wdj.routing_reference_id)
      into    v_routing_seq_id
      FROM    wip_discrete_jobs wdj
      WHERE   wdj.wip_entity_id  = p_wip_entity_id
      AND     wdj.organization_id = p_org_id;

   Exception
      WHEN NO_DATA_FOUND THEN RETURN 1;
      WHEN OTHERS THEN RETURN 1;

   End;


      WSMPUTIL.find_common_routing(
		p_routing_sequence_id => v_routing_seq_id
		, p_common_routing_sequence_id => p_common_routing_sequence_id
                , x_err_code => x_err_code
                , x_err_msg => x_err_msg
		);

	If x_err_code <> 0 Then
		raise e_user_exception;
	End If;

      WSMPUTIL.find_routing_start( p_common_routing_sequence_id ,
                              v_operation_sequence_id ,
                              x_err_code,
                              x_err_msg);

      Begin
	select reverse_cumulative_yield
	into lv_rev_cum
	from bom_operation_sequences
	where operation_sequence_id = v_operation_sequence_id;

      Exception
        WHEN NO_DATA_FOUND THEN RETURN 1;
        WHEN OTHERS THEN RETURN 1;

      End;

      Begin
         IF (p_co_prod_supply = 1) THEN
           select  wsc.split
             into  v_split
             from  wsm_Co_products wsc
            where  wsc.bill_sequence_id is not null
             and   wsc.split > 0
             and   wsc.bill_Sequence_id = p_bill_seq_id;

           v_split := v_split/100;
           lv_rev_cum := v_split*lv_rev_cum;

         ELSE
           v_split := 0;
           lv_rev_cum := lv_rev_cum;
         END IF;

      Exception
         WHEN OTHERS THEN
           v_split := 0;
           lv_rev_cum := lv_rev_cum;
      END;

   RETURN lv_rev_cum;

EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 1;
    WHEN OTHERS THEN RETURN 1;
END mrp_rev_cum_yield_unreleased;


/*over-loaded the func so that the old ver of view mrp_ap_wip_jobs_v does
  not get invalid during patch application
  This func will not be called in the collections */
FUNCTION mrp_rev_cum_yield(p_wip_entity_id in number,
                             p_org_id  in number)
RETURN NUMBER IS

  CURSOR c_rev_cum IS
      SELECT  bos.reverse_cumulative_yield
      FROM    wip_operations wo,
              bom_operation_sequences bos
      WHERE   wo.wip_entity_id  = p_wip_entity_id
      AND   wo.organization_id = p_org_id
      AND (wo.quantity_in_queue <> 0 or
              wo.quantity_running  <> 0 or
              wo.quantity_waiting_to_move <> 0)
      AND nvl(wo.operation_sequence_id,wo.previous_operation_seq_id) = bos.operation_sequence_id;

l_rev_cum number;

BEGIN
l_rev_cum := 1;
FOR c_rec in c_rev_cum
LOOP
   BEGIN
      l_rev_cum := NVL(c_rec.reverse_cumulative_yield,1);
   END;
END LOOP;
RETURN(l_rev_cum);

EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 1;
    WHEN OTHERS THEN RETURN 1;
END mrp_rev_cum_yield;


/*over-loaded the func so that the old ver of view mrp_ap_wip_jobs_v does
  not get invalid during patch application
  This func will not be called in the collections */
FUNCTION mrp_rev_cum_yield_unreleased(p_wip_entity_id in number,
                             p_org_id  in number)
RETURN NUMBER IS

   	v_op_seq_num number;
   	v_operation_sequence_id number;
   	x_err_msg varchar2(2000);
   	x_err_code  number;
   	e_user_exception EXCEPTION;
	p_common_routing_sequence_id NUMBER;
        lv_rev_cum number;
        v_routing_seq_id number;

BEGIN

      lv_rev_cum := 1;

    Begin

      SELECT  nvl(wdj.common_routing_sequence_id,wdj.routing_reference_id)
      into    v_routing_seq_id
      FROM    wip_discrete_jobs wdj
      WHERE   wdj.wip_entity_id  = p_wip_entity_id
      AND     wdj.organization_id = p_org_id;
   Exception

    WHEN NO_DATA_FOUND THEN RETURN 1;
    WHEN OTHERS THEN RETURN 1;


    End;


      WSMPUTIL.find_common_routing(
		p_routing_sequence_id => v_routing_seq_id
		, p_common_routing_sequence_id => p_common_routing_sequence_id
                , x_err_code => x_err_code
                , x_err_msg => x_err_msg
		);

	If x_err_code <> 0 Then
		raise e_user_exception;
	End If;

      WSMPUTIL.find_routing_start( p_common_routing_sequence_id ,
                              v_operation_sequence_id ,
                              x_err_code,
                              x_err_msg);

      Begin
	select reverse_cumulative_yield
	into lv_rev_cum
	from bom_operation_sequences
	where operation_sequence_id = v_operation_sequence_id;

      Exception

      WHEN NO_DATA_FOUND THEN RETURN 1;
      WHEN OTHERS THEN RETURN 1;

      End;


	return lv_rev_cum;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 1;
    WHEN OTHERS THEN RETURN 1;
END mrp_rev_cum_yield_unreleased;

FUNCTION mrp_day_uom_qty(p_uom_code in varchar2,
                         p_quantity in number)
RETURN NUMBER IS
day_uom boolean;
hour_uom boolean;
lv_day_qty number;
lv_uom_code varchar2(3);
lv_hr_uom_code varchar2(3);
lv_day_uom_code varchar2(3);
lv_hr_conversion_rate number;
lv_day_conversion_rate number;
lv_base_conversion_rate number;

CURSOR get_conversion(user_uom_code varchar2,prf_uom_code varchar2) IS
  SELECT conversion_rate
     FROM  mtl_uom_conversions muc
     WHERE muc.uom_code = user_uom_code
     AND   muc.inventory_item_id = 0
     AND   NVL(muc.disable_date, SYSDATE + 1) > SYSDATE
     AND   EXISTS (SELECT 1 from mtl_units_of_measure_tl b
                     WHERE b.uom_code = prf_uom_code
                     AND b.uom_class = muc.uom_class);

BEGIN
 day_uom := true;
 hour_uom := true;
 lv_day_qty := p_quantity;
 lv_uom_code := p_uom_code;
 lv_hr_uom_code := fnd_profile.value('BOM:HOUR_UOM_CODE');
 lv_day_uom_code := fnd_profile.value('MSC:DAY_UOM_CODE');

     /* If the UOM entered in UI is same as MSC:Day UOM return the same value
       No conversion is neeeded    */
  IF lv_day_uom_code IS NOT NULL THEN
    IF (lv_day_uom_code = lv_uom_code) THEN
      RETURN lv_day_qty;
    END IF;
  END IF;


  IF lv_day_uom_code IS NULL THEN
      day_uom := false;
               /* IF MSC:Day UOM is not set then use Bom:Hour UOM to convert into hours
                    and then re-convert into days   */
  END IF;

  IF day_uom THEN
         /* IF MSC: Day UOM is set, get the conversion rate from user-entered UOM to base UOM */
          OPEN get_conversion(lv_uom_code,lv_day_uom_code);
          FETCH get_conversion INTO lv_base_conversion_rate;

          IF get_conversion%NOTFOUND THEN
              /* If no converision is defined between user defined uom and base UOM
                 do not use MSC: Day UOM, check if BOM:Hour UOM is defined */
              day_uom := false;
              IF get_conversion%ISOPEN THEN CLOSE get_conversion; END IF;

          ELSE
             BEGIN
                    /* get the conversion rate between MSC: Day UOM and the base UOM*/
               SELECT conversion_rate
               INTO   lv_day_conversion_rate
               FROM   mtl_uom_conversions muc
               WHERE  muc.uom_code = lv_day_uom_code
               AND    muc.inventory_item_id = 0
               AND    NVL(muc.disable_date, SYSDATE + 1) > SYSDATE;

               /* get the number of days using above conversions  */
               lv_day_qty := ceil(lv_day_qty * lv_base_conversion_rate / lv_day_conversion_rate);

               IF get_conversion%ISOPEN THEN CLOSE get_conversion; END IF;

               RETURN lv_day_qty;

             EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      day_uom := false;
                      IF get_conversion%ISOPEN THEN CLOSE get_conversion; END IF;

                  WHEN OTHERS THEN
                      day_uom := false;
                      IF get_conversion%ISOPEN THEN CLOSE get_conversion; END IF;

             END;

           END IF;

  END IF;  -- MSC:Day UOM is used for conversion

  IF (day_uom = false) THEN
      /* IF the MSC:Day UOM is not set and Bom:Hour UOM is set and USer UOM is same as Bom:Hour UOM ,
         return the number divided by 24 to convert into days   */
         IF lv_hr_uom_code IS NOT NULL THEN
            IF (lv_hr_uom_code = lv_uom_code) THEN
                lv_day_qty := ceil( lv_day_qty / 24 );
                RETURN lv_day_qty;
            END IF;
         ELSE hour_uom:= FALSE;
         END IF;
    IF hour_uom THEN
       /* IF BOM: Hour UOM is set and for any exception day_uom is false, get the conversion rate
                  from user-entered UOM and base UOM */
       OPEN get_conversion(lv_uom_code,lv_hr_uom_code);
       FETCH get_conversion INTO lv_base_conversion_rate;

         IF get_conversion%NOTFOUND THEN
          /* IF conversion between BOM: Hour UOM and user UOM is not defined,
                 return number/24 to get the number of days  */
             lv_day_qty := ceil( lv_day_qty / 24);
             IF get_conversion%ISOPEN THEN CLOSE get_conversion; END IF;
             RETURN lv_day_qty;
         ELSE
             BEGIN
               /* Get conversion betwwen BOM: Hour UOM  and base UOM */
                SELECT nvl(conversion_rate,1/24)
                INTO   lv_hr_conversion_rate
                FROM   mtl_uom_conversions muc
                WHERE  muc.uom_code = lv_hr_uom_code
                AND    muc.inventory_item_id = 0
                AND    NVL(muc.disable_date, SYSDATE + 1) > SYSDATE;

                 /* get the number of days using conversions   */
                lv_day_qty := ceil(((lv_day_qty * lv_base_conversion_rate)/lv_hr_conversion_rate) / 24);

                IF get_conversion%ISOPEN THEN CLOSE get_conversion; END IF;

                RETURN lv_day_qty;

             EXCEPTION

                WHEN NO_DATA_FOUND THEN
                    IF get_conversion%ISOPEN THEN CLOSE get_conversion; END IF;
                    lv_day_qty := ceil( lv_day_qty / 24);
                    RETURN lv_day_qty;

                WHEN OTHERS THEN
                    IF get_conversion%ISOPEN THEN CLOSE get_conversion; END IF;
                    lv_day_qty := ceil( lv_day_qty / 24);
                    RETURN lv_day_qty;
             END;

          END IF;
     ELSE
         lv_day_qty := ceil( lv_day_qty / 24);
         RETURN lv_day_qty;

     END IF;  -- hour uom cond

  END IF;  -- Hour UOM is used for conversion

IF lv_day_qty = 0 THEN
   lv_day_qty := 1 ;
END IF;

RETURN(lv_day_qty);

EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN ceil(lv_day_qty/24);
    WHEN OTHERS THEN RETURN ceil(lv_day_qty/24);

END mrp_day_uom_qty;
FUNCTION get_primary_quantity(p_org_id in number,
                             p_item_id  in number,
                             p_primary_uom_code  in varchar2)
RETURN NUMBER IS
lv_uom_code varchar2(3);
BEGIN
  BEGIN

     select uom_code
     into   lv_uom_code
     from   mtl_units_of_measure
     where uom_class = v_yield_uom_class
     and base_uom_flag = 'Y';
      EXCEPTION
         WHEN NO_DATA_FOUND THEN return -99999;

  END;
return( inv_convert.inv_um_convert(
      item_id		=> p_item_id,
      precision		=> 9,
      from_quantity     => 1,
      from_unit         => p_primary_uom_code,
      to_unit           => lv_uom_code,
      from_name		=> null,
      to_name	        => null) );

exception
when others then return 1;

END get_primary_quantity;

FUNCTION GET_RESOURCE_OVERHEAD(res_id IN NUMBER, dept_id IN NUMBER,
                              org_id IN NUMBER, res_cost IN NUMBER)
return NUMBER
IS

v_overhead       NUMBER := 0;
BASIS_RESOURCE_UNITS       CONSTANT INTEGER := 3;
BASIS_RESOURCE_VALUE       CONSTANT INTEGER := 4;

CST_FROZEN      CONSTANT INTEGER := 1;

BEGIN

    SELECT NVL(SUM(decode(basis_type,
                      BASIS_RESOURCE_VALUE, res_cost * NVL(rate_or_amount,0),
                                            NVL(rate_or_amount,0)
                      )
                  ),0)
    INTO    v_overhead
    FROM    cst_department_overheads
    WHERE   organization_id = org_id
    AND     department_id = dept_id
    AND     cost_type_id = CST_FROZEN
    AND     basis_type in (BASIS_RESOURCE_VALUE, BASIS_RESOURCE_UNITS)
    AND     overhead_id IN (SELECT  overhead_id
              FROM cst_resource_overheads res
              WHERE res.organization_id =  org_id
              AND res.resource_id = res_id
              AND cost_type_id = CST_FROZEN);

    RETURN v_overhead;

EXCEPTION
    WHEN OTHERS THEN
        v_overhead := 0;
        RETURN v_overhead;

END GET_RESOURCE_OVERHEAD;

/* Check whether bom version is above I. If yes return true else return false.*/
FUNCTION CHECK_BOM_VER
return NUMBER
IS
lv_patch_level VARCHAR2(100);
lv_bom_ver NUMBER;
lv_family_pack VARCHAR2(10);

BEGIN

 	select nvl(fpi.patch_level, 'Not Available')
	into lv_patch_level
        from   fnd_application_vl fav, fnd_product_installations fpi
        where fav.application_id = fpi.application_id and
        fpi.APPLICATION_ID in (702);

        If lv_patch_level = 'Not Available' Then
        return G_BOM_LESS_THAN_J;
        End if;

        lv_family_pack := SUBSTR(lv_patch_level,1,3);

        IF lv_family_pack = '11i' Then

        	lv_bom_ver := ASCII( SUBSTR(lv_patch_level,-1,1) );

        	if lv_bom_ver > 73 Then
        	return G_BOM_GREATER_THAN_EQUAL_J;
        	else
        	return G_BOM_LESS_THAN_J;
        	End if;

        ELSE
        return G_BOM_GREATER_THAN_EQUAL_J;

        END IF;

EXCEPTION
When Others Then return G_BOM_LESS_THAN_J;

END CHECK_BOM_VER;

FUNCTION CHECK_AHL_VER
return NUMBER
IS
lv_retval         BOOLEAN;
lv_dummy1         VARCHAR2(32);
lv_dummy2         VARCHAR2(32);
l_applsys_schema_ahl  VARCHAR2(32);
lv_ahl_exists     NUMBER;

BEGIN

       lv_retval := FND_INSTALLATION.GET_APP_INFO ( 'AHL', lv_dummy1, lv_dummy2, l_applsys_schema_ahl);

 	SELECT count(1) into lv_ahl_exists  FROM all_tab_columns
 	WHERE (OWNER, TABLE_NAME, COLUMN_NAME) in ((l_applsys_schema_ahl, 'AHL_SCHEDULE_MATERIALS', 'COMPLETED_QUANTITY'));

        	IF lv_ahl_exists =1 THEN
        	return G_AHL_GREATER_THAN_EQUAL_J;
        	else
        	return G_AHL_LESS_THAN_J;
        	End if;


EXCEPTION
When Others Then return G_AHL_LESS_THAN_J;

END CHECK_AHL_VER;


FUNCTION GET_CURRENT_OP_SEQ_NUM( p_org_id IN NUMBER
                               , p_wip_entity_id IN NUMBER)
RETURN NUMBER
IS

l_rev_cum          number := 1;
v_split            number;
qty_to_move        number;
curr_op_seq_id     number;
v_curr_op_seq_num  number;

v_sql_stmt1      varchar2(1000);

BEGIN

     begin

        v_sql_stmt1 :=  ' SELECT bos.Operation_Seq_Num, nvl(bos.reverse_cumulative_yield,1), wo.quantity_waiting_to_move '
                      ||'             , nvl(wo.operation_sequence_id,wo.previous_operation_seq_id) '
                      ||' FROM   MRP_SN_OPR_SEQS bos,                  '
                      ||'        MRP_SN_WOPRS wo                       '
                      ||' WHERE  wo.organization_id =  :p_org_id       '
                      ||' AND    wo.wip_entity_id =  :p_wip_entity_id  '
                      ||' AND    (wo.quantity_in_queue <> 0 OR         '
                      ||'         wo.quantity_running  <> 0 OR         '
                      ||'         wo.quantity_waiting_to_move <> 0)    '
                      ||' AND nvl(wo.operation_sequence_id,wo.previous_operation_seq_id) = bos.operation_sequence_id ';

        EXECUTE IMMEDIATE  v_sql_stmt1
                     INTO  v_curr_op_seq_num, l_rev_cum, qty_to_move, curr_op_seq_id
                    USING  p_org_id, p_wip_entity_id;

     exception
       when others then
             return to_number(NULL);
     end;

 RETURN v_curr_op_seq_num;

EXCEPTION
    WHEN OTHERS THEN
        v_curr_op_seq_num := to_number(NULL);
        RETURN v_curr_op_seq_num;

END GET_CURRENT_OP_SEQ_NUM;

/* To get the current routing operation sequence number from job details */
FUNCTION GET_CURRENT_JD_OP_SEQ_NUM( p_org_id IN NUMBER
                               , p_wip_entity_id IN NUMBER)
RETURN NUMBER
IS

v_curr_op_seq_num  number := null;

v_sql_stmt1      varchar2(1000);

BEGIN

     begin

        v_sql_stmt1 :=  ' SELECT wo1.Wsm_Op_Seq_Num '
                      ||' FROM   MRP_SN_WOPRS wo,                      '
                      ||' MRP_SN_WOPRS wo1                             '
                      ||' WHERE  wo.organization_id =  :p_org_id       '
                      ||' AND    wo.wip_entity_id =  :p_wip_entity_id  '
                      ||' AND    (wo.quantity_in_queue <> 0 OR         '
                      ||'         wo.quantity_running  <> 0 OR         '
                      ||'         wo.quantity_waiting_to_move <> 0)    '
                      ||' AND    wo1.wip_entity_id = wo.wip_entity_id  '
                      ||' AND    nvl(wo.operation_sequence_id,wo.previous_operation_seq_id) = wo1.operation_sequence_id'
                      ||' AND    rownum=1';

        EXECUTE IMMEDIATE  v_sql_stmt1
                     INTO  v_curr_op_seq_num
                    USING  p_org_id, p_wip_entity_id;

     exception
       when others then
             return to_number(NULL);
     end;

 RETURN v_curr_op_seq_num;

EXCEPTION
    WHEN OTHERS THEN
        v_curr_op_seq_num := to_number(NULL);
        RETURN v_curr_op_seq_num;

END GET_CURRENT_JD_OP_SEQ_NUM;

FUNCTION GET_CURRENT_JOB_OP_SEQ_NUM( p_org_id IN NUMBER
                               , p_wip_entity_id IN NUMBER)
RETURN NUMBER
IS

v_curr_op_seq_num  number := null;
lv_status number := null;

v_sql_stmt      varchar2(1000);

BEGIN

     begin

     v_sql_stmt := ' Select wdj.status_type from '
                    ||'  MRP_SN_DSCR_JOBS wdj '
                    ||'  Where wdj.wip_entity_id = :p_wip_entity_id ';

                    EXECUTE IMMEDIATE  v_sql_stmt
                     INTO  lv_status
                    USING  p_wip_entity_id;
      exception
       when others then
           return to_number(NULL);
     end;

     If lv_status = 1 Then
     begin

        v_sql_stmt :=  ' SELECT wo.Operation_Seq_Num '
                      ||'             FROM   MRP_SN_WOPRS wo '
                      ||' WHERE  wo.organization_id =  :p_org_id       '
                      ||' AND    wo.wip_entity_id =  :p_wip_entity_id  ';

        EXECUTE IMMEDIATE  v_sql_stmt
                     INTO  v_curr_op_seq_num
                    USING  p_org_id, p_wip_entity_id;

     exception
       when others then
             return to_number(NULL);
     end;

     Else
     begin

        v_sql_stmt :=  ' SELECT wo.Operation_Seq_Num '
                      ||'             FROM   MRP_SN_WOPRS wo '
                      ||' WHERE  wo.organization_id =  :p_org_id       '
                      ||' AND    wo.wip_entity_id =  :p_wip_entity_id  '
                      ||' AND    (wo.quantity_in_queue <> 0 OR         '
                      ||'         wo.quantity_running  <> 0 OR         '
                      ||'         wo.quantity_waiting_to_move <> 0) ' ;

        EXECUTE IMMEDIATE  v_sql_stmt
                     INTO  v_curr_op_seq_num
                    USING  p_org_id, p_wip_entity_id;

     exception
       when others then
             return to_number(NULL);
     end;
     END IF;

 RETURN v_curr_op_seq_num;

EXCEPTION
    WHEN OTHERS THEN
        v_curr_op_seq_num := to_number(NULL);
        RETURN v_curr_op_seq_num;

END GET_CURRENT_JOB_OP_SEQ_NUM;

FUNCTION GET_CURRENT_RTNG_OP_SEQ_NUM( p_org_id IN NUMBER
                               , p_wip_entity_id IN NUMBER)
RETURN NUMBER
IS

v_curr_rtng_op_seq_num  number := 50000;
v_sql_stmt      varchar2(1000);

BEGIN

       v_sql_stmt :=  ' SELECT nvl(wo.wsm_op_seq_num,50000) '
                      ||'             FROM MRP_SN_WOPRS wo '
                      ||' WHERE  wo.organization_id =  :p_org_id       '
                      ||' AND    wo.wip_entity_id =  :p_wip_entity_id  '
                      ||' AND    (wo.quantity_in_queue <> 0 OR         '
                      ||'         wo.quantity_running  <> 0 OR         '
                      ||'         wo.quantity_waiting_to_move <> 0) ' ;


        EXECUTE IMMEDIATE  v_sql_stmt
                     INTO  v_curr_rtng_op_seq_num
                    USING  p_org_id, p_wip_entity_id;


	RETURN v_curr_rtng_op_seq_num;

EXCEPTION
    WHEN OTHERS THEN
        v_curr_rtng_op_seq_num := to_number(NULL);
        RETURN v_curr_rtng_op_seq_num;

END GET_CURRENT_RTNG_OP_SEQ_NUM;

FUNCTION GETWFUSER(ORIG_SYS_ID in varchar2)
RETURN varchar2
IS
p_wf_name varchar2(320);
p_wf_full_name varchar2(1000);
BEGIN
 wf_directory.getusername('PER',orig_sys_id,p_wf_name,p_wf_full_name) ;
 RETURN substr(p_wf_name,1,100);
EXCEPTION
    WHEN OTHERS THEN
        p_wf_name := null;
        RETURN substr(p_wf_name,1,100);
END GETWFUSER;


FUNCTION  GET_ROUTING_SEQ_ID ( p_primary_item_id    IN NUMBER,
                               p_org_id             IN NUMBER,
                               p_alt_ROUTING_DESIG  IN VARCHAR2,
                               p_common_rout_seq_id IN NUMBER)
RETURN NUMBER
IS

v_temp_sql_stmt   varchar2(1000);
v_routing_seq_id    number;

BEGIN

   v_temp_sql_stmt :=   ' SELECT   ROUTING_SEQUENCE_ID  '
                      ||'   FROM   MRP_SN_OPR_RTNS  '
                      ||'  WHERE   ASSEMBLY_ITEM_ID = :p_primary_item_id '
                      ||'    AND   ORGANIZATION_ID = :p_org_id '
                      ||'    AND   nvl(ALTERNATE_ROUTING_DESIGNATOR,''-1'') = :p_alt_ROUTING_DESIG '
                      ||'    AND   COMMON_ROUTING_SEQUENCE_ID = :p_common_rout_seq_id  ';

   EXECUTE IMMEDIATE  v_temp_sql_stmt
                INTO  v_routing_seq_id
               USING  p_primary_item_id ,p_org_id ,p_alt_ROUTING_DESIG ,p_common_rout_seq_id;

   RETURN  v_routing_seq_id;

EXCEPTION
   WHEN OTHERS THEN
       RETURN  to_number(null);

END get_routing_seq_id;

FUNCTION GET_PO_ORIG_NEED_BY_DATE ( p_po_header_id IN NUMBER,
                                    p_po_line_id   IN NUMBER,
                                    p_po_line_location_id IN NUMBER
                                  )
RETURN DATE
IS
l_orig_need_by_date DATE;
v_sql_stmt VARCHAR2(2000);

BEGIN

	v_sql_stmt :=
      ' select need_by_date '
    ||' from ( '
    ||'      SELECT revision_num, '
    ||'             need_by_date, '
    ||'             quantity, '
    ||'             RANK() OVER (PARTITION BY LINE_LOCATION_ID, PO_HEADER_ID,PO_LINE_ID '
    ||'                          order by revision_num) as seqnumber '
    ||'             FROM po_line_locations_archive_all '
    ||'             where PO_HEADER_ID = :p_po_header_id '
    ||'             and   po_line_id = :p_po_line_id '
    ||'             and   line_location_id = :p_po_line_location_id '
    ||'     ) '
    ||'     where  seqnumber = 1 ';

	EXECUTE IMMEDIATE v_sql_stmt INTO l_orig_need_by_date
		USING p_po_header_id,
			  p_po_line_id,
			  p_po_line_location_id;

    return l_orig_need_by_date;

EXCEPTION  WHEN OTHERS THEN
    return null;
END GET_PO_ORIG_NEED_BY_DATE;

FUNCTION GET_PO_ORIG_QUANTITY ( p_po_header_id IN NUMBER,
                                p_po_line_id   IN NUMBER,
                                p_po_line_location_id IN NUMBER
                              )
RETURN NUMBER IS
l_quantity NUMBER ;
v_sql_stmt VARCHAR2(2000);

BEGIN

	v_sql_stmt :=
      ' select quantity '
    ||' from ( '
    ||'      SELECT revision_num,  '
    ||'             need_by_date,  '
    ||'             quantity,      '
    ||'             RANK() OVER (PARTITION BY LINE_LOCATION_ID, PO_HEADER_ID,PO_LINE_ID '
    ||'                          order by revision_num) as seqnumber '
    ||'             FROM po_line_locations_archive_all '
    ||'             where PO_HEADER_ID = :p_po_header_id '
    ||'             and   po_line_id = :p_po_line_id '
    ||'             and   line_location_id = :p_po_line_location_id '
    ||'     ) '
    ||'     where  seqnumber = 1 ';

	EXECUTE IMMEDIATE v_sql_stmt INTO l_quantity
		USING p_po_header_id,
			  p_po_line_id,
			  p_po_line_location_id;

    return l_quantity;

EXCEPTION WHEN OTHERS THEN
    return to_number(NULL);
END GET_PO_ORIG_QUANTITY;

FUNCTION  get_userenv_lang
RETURN varchar2
IS
BEGIN
   RETURN  userenv('LANG');

EXCEPTION
   WHEN OTHERS THEN
       RETURN  'US';
END get_userenv_lang;

FUNCTION  GET_COST_TYPE_ID (   p_org_id             IN NUMBER )
RETURN NUMBER
IS

CURSOR COST_C IS
  SELECT NVL(FND_PROFILE.VALUE('MSC_COST_TYPE'),
  DECODE(cost_org.primary_cost_method,1,1,2,cost_org.AVG_RATES_COST_TYPE_ID,1))
  FROM mtl_parameters org, mtl_parameters cost_org
  WHERE org.cost_organization_id = cost_org.organization_id
  and   org.organization_id = p_org_id;

CURSOR COST_C2 IS
  SELECT NVL(FND_PROFILE.VALUE('MSC_COST_TYPE'),1)
  FROM dual;

  l_cost_type_id	NUMBER:= NULL;

BEGIN

  OPEN COST_C;
  FETCH COST_C into l_cost_type_id;
  CLOSE COST_C;

  IF l_cost_type_id IS NULL THEN
     OPEN COST_C2;
     FETCH COST_C2 into l_cost_type_id;
     CLOSE COST_C2;
  END IF;

  RETURN(l_cost_type_id);

END GET_COST_TYPE_ID ;

FUNCTION  MAP_REGION_TO_SITE (p_last_update_date in DATE)
RETURN NUMBER
IS

Cursor regions_update is
select max(LAST_UPDATE_DATE)
from WSH_REGIONS;

Cursor po_vendors_update(p_date DATE) is
select vendor_site_id
from PO_VENDOR_SITES_ALL
where last_update_date >= p_date and creation_date < p_date;

Cursor all_vendor_sites is
select vendor_site_id,country,state,city,zip
from PO_VENDOR_SITES_ALL;

Cursor new_vendor_sites(p_date DATE) is
select vendor_site_id,country,state,city,zip
from PO_VENDOR_SITES_ALL
where last_update_date >= p_date;

TYPE VendorSiteTblTyp IS TABLE OF PO_VENDOR_SITES_ALL.VENDOR_SITE_ID%TYPE;
TYPE CountryTblTyp    IS TABLE OF PO_VENDOR_SITES_ALL.COUNTRY%TYPE;
TYPE StateTblTyp      IS TABLE OF PO_VENDOR_SITES_ALL.STATE%TYPE;
TYPE CityTblTyp       IS TABLE OF PO_VENDOR_SITES_ALL.CITY%TYPE;
TYPE ZipTblTyp        IS TABLE OF PO_VENDOR_SITES_ALL.ZIP%TYPE;
TYPE NumTblTyp        IS TABLE OF NUMBER;

l_vendor_site_tab   VendorSiteTblTyp ;
l_vendor_site_tab1  VendorSiteTblTyp ;
l_country_tab       CountryTblTyp;
l_state_tab         StateTblTyp;
l_city_tab          CityTblTyp;
l_postal_tab        ZipTblTyp;
l_region_id_tab     NumTblTyp := NumTblTyp();
l_region_type_tab   NumTblTyp := NumTblTyp();
l_zone_level_tab    NumTblTyp := NumTblTyp();

l_regions           WSH_REGIONS_SEARCH_PKG.region_table;

region_last_update  DATE := NULL;
l_status            NUMBER;
lv_sql_stmt         VARCHAR2(8000);
v_current_date      DATE;
v_current_user      NUMBER;



BEGIN

  SELECT SYSDATE,
         FND_GLOBAL.USER_ID
  INTO   v_current_date,
         v_current_user
  FROM   DUAL;

  OPEN regions_update;
    FETCH regions_update into region_last_update;
  CLOSE regions_update;


  IF  region_last_update is NULL THEN
    Return(1);
    NULL;
  END IF;
-- If wsh_regions has undergone change after last Collection, all mappings are re-established.
  IF (p_last_update_date is NULL) OR (region_last_update >= p_last_update_date) THEN
    -- delete mrp_region_sites completely.
    DELETE FROM MRP_REGION_SITES;

    -- Get all vendor sites for re mapping.
    OPEN all_vendor_sites;
    FETCH all_vendor_sites BULK COLLECT
	INTO 	l_vendor_site_tab,
		l_country_tab,
		l_state_tab,
		l_city_tab,
		l_postal_tab;
    CLOSE all_vendor_sites;
  ELSE
    OPEN po_vendors_update (p_last_update_date);
    FETCH po_vendors_update BULK COLLECT
    INTO l_vendor_site_tab1;
    CLOSE po_vendors_update;
    -- bug 5985580

    FOR j IN 1..l_vendor_site_tab1.COUNT LOOP
    BEGIN
        DELETE FROM MRP_REGION_SITES
        where vendor_site_id =l_vendor_site_tab1(j);
    EXCEPTION WHEN OTHERS THEN
        MRP_CL_REFRESH_SNAPSHOT.LOG_DEBUG(SQLERRM);
        MRP_CL_REFRESH_SNAPSHOT.LOG_DEBUG('There was an error in DELETEING Region to Sites');
        NULL;
    END;
    END LOOP;
    --
  -- If wsh_regions has not undergone any change after the last Collection, map only new vendor sites.
    OPEN new_vendor_sites(p_last_update_date);
    FETCH new_vendor_sites BULK COLLECT
	INTO 	l_vendor_site_tab,
		l_country_tab,
		l_state_tab,
		l_city_tab,
		l_postal_tab;
    CLOSE new_vendor_sites;
  END IF;

  FOR i IN 1..l_vendor_site_tab.COUNT LOOP
    BEGIN
      WSH_REGIONS_SEARCH_PKG.Get_All_Region_Matches(
            p_country => null,          	        -- p_country
            p_country_region => null,               	-- p_country_region
            p_state => null,               	        -- p_state
            p_city => l_city_tab(i),             	-- p_city
            p_postal_code_from => l_postal_tab(i),    	-- p_postal_code_from
            p_postal_code_to => l_postal_tab(i),        -- p_postal_code_to
            p_country_code => l_country_tab(i),  	-- p_country_code
            p_country_region_code => null,              -- p_country_region_code
            p_state_code => l_state_tab(i),   		-- p_state_code
            p_city_code => null,               		-- p_city_code
            p_lang_code => userenv('LANG'),           	-- p_lang_code
            p_location_id => null,               	-- p_location_id
            p_zone_flag => 'Y',                 	-- p_zone_flag
            x_status => l_status,
            x_regions => l_regions);

    EXCEPTION WHEN OTHERS THEN
      MRP_CL_REFRESH_SNAPSHOT.LOG_DEBUG(SQLERRM);
      MRP_CL_REFRESH_SNAPSHOT.LOG_DEBUG('There was an error in Get All Region Matches for City '||l_city_tab(i)||' State ' ||l_state_tab(i)||' Country '||l_country_tab(i) );

      NULL;
    END;

  IF l_regions.count > 0 THEN
    l_region_id_tab.EXTEND(l_regions.count);
    l_region_type_tab.EXTEND(l_regions.count);
    l_zone_level_tab.EXTEND(l_regions.count);

      FOR j IN 1..l_regions.COUNT LOOP
        l_region_id_tab(j) := l_regions(j).region_id;
        IF(l_regions(j).region_type = 10) THEN
          l_region_type_tab(j) := (10 * (10 - l_regions(j).zone_level))+ 1;
        ELSE
          l_region_type_tab(j) := (10 * (10 - l_regions(j).zone_level))+ 0;
        END IF;
        l_zone_level_tab(j) := l_regions(j).zone_level;
      END LOOP;
    FORALL k IN 1..l_regions.count
      INSERT INTO MRP_REGION_SITES(region_id,vendor_site_id, region_type, zone_level, last_update_date, last_updated_by, creation_date, created_by)
      VALUES (l_region_id_tab(k), l_vendor_site_tab(i),l_region_type_tab(k),l_zone_level_tab(k), v_current_date, v_current_user, v_current_date, v_current_user);
  END IF;

  END LOOP;
  COMMIT;
  Return(1);


  EXCEPTION WHEN OTHERS THEN
  MRP_CL_REFRESH_SNAPSHOT.LOG_DEBUG(SQLERRM);
  MRP_CL_REFRESH_SNAPSHOT.LOG_DEBUG('There was an error in Mapping Region to Sites');
  Return(0);
END MAP_REGION_TO_SITE ;

FUNCTION get_ship_set_name(p_SHIP_SET_ID in number)
RETURN VARCHAR2
IS
l_set_name VARCHAR2(30);
BEGIN

 IF (p_SHIP_SET_ID is not null) THEN
   select set_name into l_set_name
   from oe_sets
   where set_id=p_SHIP_SET_ID;

   RETURN l_set_name;

 ELSE

        l_set_name := null;
        RETURN l_set_name;

 END IF;

EXCEPTION
  WHEN OTHERS THEN
        l_set_name := null;
        RETURN l_set_name;

END get_ship_set_name;

FUNCTION get_arrival_set_name(p_ARRIVAL_SET_ID in number)
RETURN VARCHAR2
IS
l_set_name VARCHAR2(30);
BEGIN

 IF (p_ARRIVAL_SET_ID is not null) THEN
   select set_name into l_set_name
   from oe_sets
   where set_id=p_ARRIVAL_SET_ID;

   RETURN l_set_name;

 ELSE

        l_set_name := null;
        RETURN l_set_name;

 END IF;

EXCEPTION
  WHEN OTHERS THEN
        l_set_name := null;
        RETURN l_set_name;

END get_arrival_set_name;

/* CMRO Collection Impact */
FUNCTION GET_CMRO_CUSTOMER_ID
RETURN NUMBER IS
     lv_customer_id  NUMBER;
BEGIN

    /* Need to make sure that the AHL Customer Name is based of HZ Parties */
    /* I am settin other global variables in the function hoping and invoking
    *  this function once for each row to avoid the hit 3 times?.
    *  Should not we actually implement this in the Snap Shot?.
    */

   Begin
       lv_customer_id := fnd_profile.value('AHL_APS_CUSTOMER_NAME');
       v_cmro_customer_id := lv_customer_id;

    Exception
        When others then
            lv_customer_id := null;
            Return lv_customer_id ;
    End ;

     RETURN lv_customer_id;

END GET_CMRO_CUSTOMER_ID;

FUNCTION GET_CMRO_SHIP_TO return NUMBER IS
     lv_customer_id  NUMBER;
     lv_cmro_ship_to NUMBER;
BEGIN

   Begin
       lv_customer_id := fnd_profile.value('AHL_APS_CUSTOMER_NAME');

    Exception
        When others then
            lv_customer_id := null;
            Return lv_customer_id ;
    End ;


    Begin
            SELECT
               SITE_USES_ALL.site_use_id SR_TP_SITE_ID
            INTO
                lv_cmro_ship_to
            FROM
               HZ_CUST_ACCT_SITES_ALL ACCT_SITE,
               HZ_CUST_SITE_USES_ALL SITE_USES_ALL,
               HZ_CUST_ACCOUNTS CUST_ACCT,
               HR_ORGANIZATION_INFORMATION O,
               HR_ALL_ORGANIZATION_UNITS_TL OTL
            WHERE OTL.ORGANIZATION_ID = SITE_USES_ALL.ORG_ID
            AND O.ORGANIZATION_ID = OTL.ORGANIZATION_ID
            AND O.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
            AND OTL.LANGUAGE = userenv('LANG')
            AND SITE_USES_ALL.ORG_ID is NOT NULL
            AND SITE_USES_ALL.CUST_ACCT_SITE_ID=ACCT_SITE.CUST_ACCT_SITE_ID
            AND ACCT_SITE.CUST_ACCOUNT_ID = CUST_ACCT.CUST_ACCOUNT_ID
            AND CUST_ACCT.CUST_ACCOUNT_ID = lv_customer_id;

        Exception
            When others then
               lv_cmro_ship_to := null ;
     End ;

     RETURN lv_cmro_ship_to;


END GET_CMRO_SHIP_TO ;


FUNCTION GET_CMRO_BILL_TO return NUMBER IS
     lv_customer_id  NUMBER;
     lv_cmro_bill_to NUMBER;
BEGIN


   Begin
       lv_customer_id := fnd_profile.value('AHL_APS_CUSTOMER_NAME');

    Exception
        When others then
            lv_customer_id := null;
            lv_cmro_bill_to := null;
            Return lv_cmro_bill_to ;
    End ;


    Begin
            SELECT
               SITE_USES_ALL.site_use_id SR_TP_SITE_ID
            INTO
                lv_cmro_bill_to
            FROM
               HZ_CUST_ACCT_SITES_ALL ACCT_SITE,
               HZ_CUST_SITE_USES_ALL SITE_USES_ALL,
               HZ_CUST_ACCOUNTS CUST_ACCT,
               HR_ORGANIZATION_INFORMATION O,
               HR_ALL_ORGANIZATION_UNITS_TL OTL
            WHERE OTL.ORGANIZATION_ID = SITE_USES_ALL.ORG_ID
            AND O.ORGANIZATION_ID = OTL.ORGANIZATION_ID
            AND O.ORG_INFORMATION_CONTEXT = 'Operating Unit Information'
            AND OTL.LANGUAGE = userenv('LANG')
            AND SITE_USES_ALL.ORG_ID is NOT NULL
            AND SITE_USES_ALL.CUST_ACCT_SITE_ID=ACCT_SITE.CUST_ACCT_SITE_ID
            AND ACCT_SITE.CUST_ACCOUNT_ID = CUST_ACCT.CUST_ACCOUNT_ID
            AND CUST_ACCT.CUST_ACCOUNT_ID = lv_customer_id;

        Exception
            When others then
               lv_cmro_bill_to := null ;
     End ;

     RETURN lv_cmro_bill_to;

END GET_CMRO_BILL_TO ;


/* Check whether wsh version is above I. If yes return true else return false.*/
FUNCTION CHECK_WSH_VER
return NUMBER
IS
lv_patch_level VARCHAR2(100);
lv_wsh_ver NUMBER;
lv_family_pack VARCHAR2(10);

BEGIN

 	select nvl(fpi.patch_level, 'Not Available')
	into lv_patch_level
        from   fnd_application_vl fav, fnd_product_installations fpi
        where fav.application_id = fpi.application_id and
        fpi.APPLICATION_ID in (665);

        If lv_patch_level = 'Not Available' Then
        return G_WSH_LESS_THAN_J;
        End if;

        lv_family_pack := SUBSTR(lv_patch_level,1,3);

        IF lv_family_pack = '11i' Then

        	lv_wsh_ver := ASCII( SUBSTR(lv_patch_level,-1,1) );

        	if lv_wsh_ver > 73 Then
        	return G_WSH_GREATER_THAN_EQUAL_J;
        	else
        	return G_WSH_LESS_THAN_J;
        	End if;

        ELSE
        return G_WSH_GREATER_THAN_EQUAL_J;

        END IF;

EXCEPTION
When Others Then return G_WSH_LESS_THAN_J;

END CHECK_WSH_VER;

Procedure SUBMIT_CR
	               ( p_user_name        IN  VARCHAR2,
                     p_resp_name        IN  VARCHAR2,
                     p_application_name IN  VARCHAR2,
                     p_application_id   IN  NUMBER,
                     p_batch_id  IN  NUMBER,
                     p_conc_req_short_name IN varchar2 ,
                     p_conc_req_desc IN  varchar2 ,
                     p_owning_applshort_name IN varchar2,
                     p_load_type IN NUMBER,
                     p_request_id  IN OUT NOCOPY Number) IS

l_request     number;
l_result      BOOLEAN;

    l_user_id            NUMBER;
    lv_log_msg           varchar2(500);

BEGIN

        BEGIN

          SELECT USER_ID
            INTO l_user_id
            FROM FND_USER
           WHERE USER_NAME = p_user_name;

        EXCEPTION
         WHEN NO_DATA_FOUND THEN
              MRP_CL_REFRESH_SNAPSHOT.LOG_DEBUG('Error in launching the concurrent request : NO_USER_DEFINED');
              raise_application_error (-20001, 'NO_USER_DEFINED');
        END;

        IF MRP_CL_FUNCTION.validateUser(l_user_id,MSC_UTIL.TASK_RELEASE,lv_log_msg) THEN
            MRP_CL_FUNCTION.MSC_Initialize(MSC_UTIL.TASK_RELEASE,
                                           l_user_id,
                                           -1, --l_resp_id,
                                           -1 --l_application_id
                                           );
        ELSE
            MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  lv_log_msg);
            raise_application_error (-20001, lv_log_msg);
        END IF;


--=============================================

	l_result := fnd_request.set_mode(TRUE);

	IF p_load_type >0 THEN
 	       	    l_request := FND_REQUEST.SUBMIT_REQUEST
         			           (p_owning_applshort_name,
                          p_conc_req_short_name,
                          p_conc_req_desc,
                          null,
                          FALSE,
                          p_batch_id);
   ELSE
	       	    l_request := FND_REQUEST.SUBMIT_REQUEST
         			            (p_owning_applshort_name,
                           p_conc_req_short_name,
                           p_conc_req_desc,
                           null,
                           FALSE);
  END IF ;

    IF nvl( l_request,0) = 0 THEN
      		MRP_CL_REFRESH_SNAPSHOT.LOG_DEBUG('Error in launching the concurrent request ');
    ELSE
      	            	p_request_id  := l_request;
 		  MRP_CL_REFRESH_SNAPSHOT.LOG_DEBUG('Concurrent Request ID  ' || p_request_id  || '  has been  submitted ');
     END IF;
EXCEPTION
   WHEN OTHERS THEN
   RAISE;

END SUBMIT_CR;

FUNCTION validateUser (pUSERID    IN    NUMBER,
                       pTASK      IN    NUMBER,
                       pMESSAGE   IN OUT NOCOPY  varchar2)
                       return BOOLEAN IS
lv_result NUMBER := 0;
BEGIN
    IF pTASK   = MSC_UTIL.TASK_COLL  THEN

       select 1
         into lv_result
         from   fnd_responsibility resp
               , FND_USER_RESP_GROUPS user_resp
        where resp.responsibility_id = user_resp.responsibility_id
          and resp.application_id = user_resp.responsibility_application_id
          and resp.responsibility_key = 'APS_COLLECTIONS'
          and user_resp.user_id = pUSERID
          and rownum =1 ;

    ELSIF pTASK   = MSC_UTIL.TASK_RELEASE  THEN

       select 1
         into lv_result
         from fnd_responsibility resp,
                FND_USER_RESP_GROUPS user_resp
        where resp.responsibility_id = user_resp.responsibility_id
          and resp.application_id = user_resp.responsibility_application_id
          and resp.responsibility_key = 'APS_RELEASE'
          and user_resp.user_id = pUSERID
          and rownum =1 ;

    END IF;

    IF lv_result = 1 THEN
        RETURN TRUE;
    ELSIF lv_result = 0 THEN
        RETURN FALSE;
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF pTASK   = MSC_UTIL.TASK_COLL  THEN
        pMESSAGE := 'User not defnied or not assigned to the responsibility - ''APS COLLECTIONS''';
       ELSIF pTASK   = MSC_UTIL.TASK_RELEASE  THEN
        pMESSAGE := 'User not defnied or not assigned to the responsibility - ''APS RELEASE''';
       END IF;
       Return FALSE;
    WHEN OTHERS THEN
       pMESSAGE := 'Unable to validate user because of unexpected error';
       RAISE;
END;


PROCEDURE msc_Initialize(pTASK          IN  NUMBER,
                         pUSERID        IN  NUMBER,
                         pRESPID        IN  NUMBER,
                         pAPPLID        IN  NUMBER)  IS

lv_resp_id           NUMBER;
lv_application_id    NUMBER;
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF pTASK   = MSC_UTIL.TASK_COLL  THEN

       select resp.responsibility_id, resp.application_id
         into lv_resp_id, lv_application_id
         from fnd_responsibility resp,
                FND_USER_RESP_GROUPS user_resp
        where resp.responsibility_id = user_resp.responsibility_id
          and resp.application_id = user_resp.responsibility_application_id
          and resp.responsibility_key = 'APS_COLLECTIONS'
          and user_resp.user_id = pUSERID
          and rownum =1 ;

    ELSIF pTASK   = MSC_UTIL.TASK_RELEASE  THEN

       select resp.responsibility_id, resp.application_id
         into lv_resp_id, lv_application_id
         from fnd_responsibility resp,
                FND_USER_RESP_GROUPS user_resp
        where resp.responsibility_id = user_resp.responsibility_id
          and resp.application_id = user_resp.responsibility_application_id
          and resp.responsibility_key = 'APS_RELEASE'
          and user_resp.user_id = pUSERID
          and rownum =1 ;

    ELSIF pTASK   = MSC_UTIL.TASK_USER_DEFINED THEN

        lv_resp_id           := pRESPID;
        lv_application_id    := pAPPLID;

    END IF;

         FND_GLOBAL.APPS_INITIALIZE( pUSERID,
                                     lv_resp_id,
                                     lv_application_id);
commit;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF pTASK   = MSC_UTIL.TASK_COLL  THEN
        raise_application_error (-20001, 'User not defnied or not assigned to the responsibility - ''APS COLLECTIONS''');
       ELSIF pTASK   = MSC_UTIL.TASK_RELEASE  THEN
        raise_application_error (-20001, 'User not defnied or not assigned to the responsibility - ''APS RELEASE''');
       ELSE
        raise_application_error (-20001, 'User not defnied or not assigned to the required responsibility');
       END IF;
    WHEN OTHERS THEN
       MSC_UTIL.LOG_MSG(MSC_UTIL.G_D_STATUS,  'Unable to initialize user because of unexpected error');
       RAISE;
END;

END MRP_CL_FUNCTION;

/
