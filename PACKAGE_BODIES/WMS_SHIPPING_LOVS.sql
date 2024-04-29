--------------------------------------------------------
--  DDL for Package Body WMS_SHIPPING_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_SHIPPING_LOVS" AS
/* $Header: WMSSHPLB.pls 120.3.12010000.5 2009/08/14 14:27:48 pbonthu ship $ */

--  Global constant holding the package name
g_pkg_name CONSTANT VARCHAR2(30) := 'WMS_SHIPPING_LOVS';
g_pkg_version CONSTANT VARCHAR2(100) := '$Header: WMSSHPLB.pls 120.3.12010000.5 2009/08/14 14:27:48 pbonthu ship $';

PROCEDURE Get_LPN_Order_LOV(
  x_order_lov                 OUT NOCOPY t_genref
, p_organization_id           IN         NUMBER
, p_parent_delivery_detail_id IN         NUMBER
, p_order                     IN         VARCHAR2
)IS

BEGIN
   -- Bug4579790

   -- bug 5515230 separeated query based on if p_order is null or not
	 -- to resolve performance issue when doing an open query (null p_order)
	 IF ( p_order IS NULL OR p_order = '%' ) THEN
     OPEN x_order_lov FOR
        SELECT DISTINCT
               wdd.source_header_number
             , wdd.source_header_id
             , otl.name
             , wdd.source_header_type_id
             , party.party_name  --c.customer_name
             , party.party_id    --c.customer_id
             , party.party_number--c.customer_number
          FROM wsh_delivery_details wdd
             , hz_parties party  --ra_customers c
             , hz_cust_accounts cust_acct
             , oe_transaction_types_tl otl
             , wsh_delivery_assignments_v wda
         WHERE wdd.customer_id = party.party_id
           --c.customer_id
           AND cust_acct.party_id = party.party_id
           AND otl.language=userenv('LANG')
           AND otl.transaction_type_id = wdd.source_header_type_id
           AND wdd.organization_id = p_organization_id
           AND wdd.source_code = 'OE'
           AND wdd.date_scheduled is not null
           --AND wdd.released_status  in ('B','R','X')
           AND wda.delivery_detail_id = wdd.delivery_detail_id
           AND wda.parent_delivery_detail_id = p_parent_delivery_detail_id
      ORDER BY 2,1;
   ELSE
   	OPEN x_order_lov FOR
       SELECT DISTINCT
              wdd.source_header_number
            , wdd.source_header_id
            , otl.name
            , wdd.source_header_type_id
            , party.party_name  --c.customer_name
            , party.party_id    --c.customer_id
            , party.party_number--c.customer_number
         FROM wsh_delivery_details wdd
            , hz_parties party  --ra_customers c
            , hz_cust_accounts cust_acct
            , oe_transaction_types_tl otl
            , wsh_delivery_assignments_v wda
        WHERE wdd.customer_id = party.party_id
          --c.customer_id
          AND cust_acct.party_id = party.party_id
          AND otl.language=userenv('LANG')
          AND wdd.source_header_number like (p_order)
          AND otl.transaction_type_id = wdd.source_header_type_id
          AND wdd.organization_id = p_organization_id
          AND wdd.source_code = 'OE'
          AND wdd.date_scheduled is not null
          --AND wdd.released_status  in ('B','R','X')
          AND wda.delivery_detail_id = wdd.delivery_detail_id
          AND wda.parent_delivery_detail_id = p_parent_delivery_detail_id
     ORDER BY 2,1;
   END IF;
END Get_LPN_Order_LOV;

PROCEDURE Get_LPN_Orderline_LOV(
  x_orderline_lov             OUT NOCOPY T_GENREF
, p_organization_id           IN         NUMBER
, p_source_header_id          IN         NUMBER
, p_parent_delivery_detail_id IN         NUMBER
, p_order_line                IN         VARCHAR2
) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
  OPEN x_orderline_lov FOR
    SELECT DISTINCT
           oel.line_id
         , to_char(oel.line_number)||'.'||to_char(oel.shipment_number) ||
           decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
           decode(oel.component_number, null, null,decode(oel.option_number, null,'.',null)||
           '.'||to_char(oel.component_number)) LINE_NUMBER
         , oel.inventory_item_id
         , oel.item_revision
         , oel.PROJECT_ID
         , oel.TASK_ID
         , oel.END_ITEM_UNIT_NUMBER
         , oel.SHIP_TOLERANCE_ABOVE
         , oel.ship_tolerance_below
         , oel.FLOW_STATUS_CODE
         , oel.SHIPPING_INTERFACED_FLAG
         , oel.REQUEST_DATE
         , msik.serial_number_control_code
         , msik.concatenated_segments
         , 0
         , ''
         , 0
         , 0
         , 0
         , 0
         , ''
         , ''
         , ''
         , ''
         , 0
     FROM  oe_order_lines_all oel
         , mtl_system_items_kfv msik
         , wsh_delivery_details wdd
         , wsh_delivery_assignments_v wda
     WHERE oel.ship_from_org_id          = p_organization_id
     AND   oel.header_id                 = p_source_header_id
     AND   oel.item_type_code in ('STANDARD','CONFIG','INCLUDED','OPTION')
     AND   wda.parent_delivery_detail_id = p_parent_delivery_detail_id
     AND   wdd.delivery_detail_id        = wda.delivery_detail_id
     AND   oel.line_id                   = wdd.source_line_id
     AND   msik.inventory_item_id        = oel.inventory_item_id
     AND   msik.organization_id          = oel.ship_from_org_id
     AND   msik.mtl_transactions_enabled_flag <> 'N'
     AND   to_char(oel.line_number)||'.'||to_char(oel.shipment_number) ||
           decode(oel.option_number,NULL,NULL,'.'||to_char(oel.option_number))||
           decode(oel.component_number, null, null,decode(oel.option_number, null, '.',null)||
           '.'||to_char(oel.component_number)) like (p_order_line)
  ORDER BY 1,2;
END Get_LPN_Orderline_LOV;

--Added for Case Picking Project start (8732301)



PROCEDURE Get_Manifest_Order_LOV( x_orderline_lov OUT NOCOPY T_GENREF ,
                                  p_organization_id IN NUMBER ,
                                  p_order_number    IN VARCHAR2,
                                  p_equipment_id     IN NUMBER := NULL,
                                  p_sign_on_emp_id   IN NUMBER,
                                  p_zone             IN VARCHAR2 := NULL) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

        OPEN x_orderline_lov FOR
		SELECT DISTINCT oeh.order_number
		FROM            oe_order_headers_all oeh           ,
			      mtl_sales_orders mso               ,
			      mtl_material_transactions_temp mmtt,
			      -- inlined wms_person_resource_utt_v
			      (SELECT utt_emp.standard_operation_id standard_operation_id,
				      utt_emp.person_id             emp_id               ,
				      utt_eqp.inventory_item_id     eqp_id
			      FROM
				      (SELECT x_utt_res1.standard_operation_id standard_operation_id,
					      x_emp_r.person_id
				      FROM    bom_std_op_resources x_utt_res1,
					      bom_resources r1               ,
					      bom_resource_employees x_emp_r
				      WHERE   x_utt_res1.resource_id = r1.resource_id
					  AND r1.resource_type       = 2
					  AND x_utt_res1.resource_id = x_emp_r.resource_id
				      ) utt_emp                                                     ,
				      (SELECT x_utt_res2.standard_operation_id standard_operation_id,
					      x_eqp_r.inventory_item_id
				      FROM    bom_std_op_resources x_utt_res2,
					      bom_resources r2               ,
					      bom_resource_equipments x_eqp_r
				      WHERE   x_utt_res2.resource_id = r2.resource_id
					  AND r2.resource_type       = 1
					  AND x_utt_res2.resource_id = x_eqp_r.resource_id
				      ) utt_eqp
			      WHERE   utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)
			      ) v                    ,
			      mtl_secondary_inventories sub
		WHERE           mmtt.organization_id       = p_organization_id
			  AND oeh.order_number          LIKE (p_order_number)
			  AND mmtt.transaction_source_id   = mso.sales_order_id
			  AND mso.segment1                 = oeh.order_number
			  AND oeh.order_number NOT IN ( SELECT * FROM    TABLE(WMS_PICKING_PKG.list_order_numbers) )
			  AND v.emp_id                   = p_sign_on_emp_id        -- restrict to sign on employee
			  AND mmtt.standard_operation_id = v.standard_operation_id -- join task to resource view, check if user defined task type match
			  AND mmtt.subinventory_code     = NVL(p_zone, mmtt.subinventory_code)
			  AND NVL(v.eqp_id, -999)        = NVL(p_equipment_id, NVL(v.eqp_id, -999))
			  AND mmtt.subinventory_code     = sub.secondary_inventory_name
			  AND mmtt.organization_id       = sub.organization_id
			  AND (mmtt.wms_task_status      <> 8  OR   mmtt.wms_task_status IS NULL )
			  AND NOT EXISTS ( SELECT 1
						      FROM    wms_dispatched_tasks wdt
						      WHERE   mmtt.transaction_temp_id=wdt.transaction_temp_id
							      AND ( wdt.status > 3 OR v.emp_id  <> wdt.person_id )
					  )
		ORDER BY        1;

END Get_Manifest_Order_LOV;

PROCEDURE Get_Manifest_Pickslip_LOV( x_pickslip_lov OUT NOCOPY T_GENREF ,
                                     p_organization_id  IN NUMBER ,
                                     p_pick_slip_number IN VARCHAR2 ,
                                     p_equipment_id     IN NUMBER := NULL,
                                     p_sign_on_emp_id   IN NUMBER,
                                     p_zone             IN VARCHAR2 := NULL ) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

        OPEN x_pickslip_lov FOR
		SELECT DISTINCT mmtt.pick_slip_number
		FROM            mtl_material_transactions_temp mmtt,
				-- inlined wms_person_resource_utt_v
				(SELECT utt_emp.standard_operation_id standard_operation_id,
					utt_emp.person_id             emp_id               ,
					utt_eqp.inventory_item_id     eqp_id
				FROM
					(SELECT x_utt_res1.standard_operation_id standard_operation_id,
						x_emp_r.person_id
					FROM    bom_std_op_resources x_utt_res1,
						bom_resources r1               ,
						bom_resource_employees x_emp_r
					WHERE   x_utt_res1.resource_id = r1.resource_id
					    AND r1.resource_type       = 2
					    AND x_utt_res1.resource_id = x_emp_r.resource_id
					) utt_emp                                                     ,
					(SELECT x_utt_res2.standard_operation_id standard_operation_id,
						x_eqp_r.inventory_item_id
					FROM    bom_std_op_resources x_utt_res2,
						bom_resources r2               ,
						bom_resource_equipments x_eqp_r
					WHERE   x_utt_res2.resource_id = r2.resource_id
					    AND r2.resource_type       = 1
					    AND x_utt_res2.resource_id = x_eqp_r.resource_id
					) utt_eqp
				WHERE   utt_emp.standard_operation_id = utt_eqp.standard_operation_id(+)
				) v                    ,
				mtl_secondary_inventories sub
		WHERE           v.emp_id                           = p_sign_on_emp_id -- restrict to sign on employee
			    AND mmtt.organization_id               = p_organization_id
			    AND mmtt.standard_operation_id         = v.standard_operation_id -- join task to resource view, check if user defined task type match
			    AND mmtt.subinventory_code             = NVL(p_zone, mmtt.subinventory_code)
			    AND NVL(v.eqp_id, -999)                = NVL(p_equipment_id, NVL(v.eqp_id, -999))
			    AND mmtt.subinventory_code             = sub.secondary_inventory_name
			    AND mmtt.organization_id               = sub.organization_id
			    AND mmtt.parent_line_id                IS NULL -- Added for bulk task
			    AND mmtt.pick_slip_number     LIKE     (p_pick_slip_number)
			    AND mmtt.pick_slip_number     NOT IN   ( SELECT  *  FROM    TABLE(WMS_PICKING_PKG.list_pick_slip_numbers) )
			    AND (mmtt.wms_task_status      <> 8  OR   mmtt.wms_task_status IS NULL )
                            AND mmtt.transaction_action_id          = 28
                            AND mmtt.transaction_source_type_id     IN (2,8)
			    AND NOT EXISTS ( SELECT 1
						      FROM    wms_dispatched_tasks wdt
						      WHERE   mmtt.transaction_temp_id=wdt.transaction_temp_id
							      AND ( wdt.status > 3 OR v.emp_id  <> wdt.person_id )
					    )
		ORDER BY        1;
END Get_Manifest_Pickslip_LOV;


--Added for Case Picking Project end (8732301)



END WMS_SHIPPING_LOVS;

/
