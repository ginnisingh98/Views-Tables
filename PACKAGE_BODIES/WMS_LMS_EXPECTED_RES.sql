--------------------------------------------------------
--  DDL for Package Body WMS_LMS_EXPECTED_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_LMS_EXPECTED_RES" AS
/* $Header: WMSLMERB.pls 120.11 2006/11/14 13:41:35 salagars noship $ */

/**
  *   This is a Package that has procedures/functions that
  *   assists in estimating time for various activities like
  *   inbound, outbound, Warehousing Activities
**/


g_version_printed BOOLEAN := FALSE;
g_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

PROCEDURE DEBUG(p_message IN VARCHAR2,
                 p_module   IN VARCHAR2 default 'abc',
                 p_level   IN VARCHAR2 DEFAULT 9) IS
BEGIN

 IF NOT g_version_printed THEN
   INV_TRX_UTIL_PUB.TRACE('$Header: WMSLMERB.pls 120.11 2006/11/14 13:41:35 salagars noship $',g_pkg_name, 9);
   g_version_printed := TRUE;
 END IF;

 INV_TRX_UTIL_PUB.TRACE( P_MESG =>P_MESSAGE
                        ,P_MOD => p_module
                        ,p_level => p_level
                        );
END DEBUG;


--This program populates the WMS_ELS_EXP_RESOURCE table, which is the base requirement
--for Expected Resource Requirements Analysis . WMS_ELS_EXP_RESOURCE table essentially
--has all the information for all future work that is expected in a Warehouse whether
--it is an Inbound, Outbound, Warehousing or Manufacturing activity. Based on this
--information the expected resource requirement will be calculated.
--The following is list if the inputs for populating this table.
--1. Receiving Inbound
--    o  Expected Purchase Order Receipts to be received in the given time frame
--    o  Expected ASN material to be received in the given time frame
--    o  Expected Internal Transfers to be received in the given time frame
--    o  Expected RMAs to be received in the given time frame
--2.  Receiving Inbound
--     o Material that is received, but needs to be putaway
--3. Inventory Accuracy
--   Cycle count tasks outstanding
--4. Outbound Shipping / Manufacturing
--    o  Unreleased / pending / queued / dispatched tasks for Sales orders,
--       manufacturing component picks, and internal orders
--5. Manufacturing Putaways
--6. Pending and outstanding replenishment tasks


PROCEDURE POPULATE_EXPECTED_WORK
                           (  x_return_status     OUT NOCOPY VARCHAR2
                            , x_msg_count         OUT NOCOPY VARCHAR2
                            , x_msg_data          OUT NOCOPY VARCHAR2
                            , p_org_id            IN         NUMBER
                           )IS

 l_num_rows_inserted NUMBER;
 l_num_sql_failed NUMBER;
 ALL_SQL_FAILED Exception;
 g_total_sql    NUMBER;

BEGIN
x_return_status := fnd_api.g_ret_sts_success;
l_num_rows_inserted := 0;
l_num_sql_failed    :=0;
g_total_sql         :=11;

  IF g_debug=1 THEN
    debug('The value of p_org_id '|| p_org_id,'POPULATE_EXPECTED_WORK');
   END IF;
--1. Receiving Inbound
--    o  Expected Purchase Order Receipts to be received in the given time frame
--    o  Expected ASN material to be received in the given time frame
--    o  Expected Internal Transfers to be received in the given time frame
-- The expected work is queried from mtl_supply table for these work sources.
 BEGIN

  IF g_debug=1 THEN
   debug('Before populating work for Inbound(PO,REQ,SHIPMENT) ','POPULATE_EXPECTED_WORK');
  END IF;

  INSERT  INTO  WMS_ELS_EXP_RESOURCE
        (els_exp_resource_id ,
         organization_id,
         activity_id,
         activity_detail_id,
         operation_id,
         document_type,
         source_subinventory,
         transaction_uom ,
         inventory_item_id ,
         quantity,
         source_header_id,
         source_line_id,
         group_id,
         work_scheduled_date,
         last_updated_by,
         last_update_Date,
         last_update_login,
         created_by,
         creation_Date
        )
     select
          WMS_ELS_EXP_RESOURCE_S.NEXTVAL,
          to_organization_id,
          1,--Inbound
          1,--Recieve
          1,--Reciept
          supply_type_code,
          from_subinventory,
          mum.UOM_CODE,
          item_id,
          quantity,
          decode(supply_type_code,
                                  'PO', po_header_id,
                                  'REQ', req_header_id,
                                  'SHIPMENT',shipment_header_id
                 ),
          decode(supply_type_code,
                                  'PO', po_line_id,
                                  'REQ',req_line_id,
                                  'SHIPMENT',shipment_line_id
                ),
          1, --manual and user directed
          receipt_date,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.LOGIN_ID,
          FND_GLOBAL.USER_ID,
          SYSDATE
     from  mtl_supply ms,
           wms_els_parameters wep,
           mtl_units_of_measure_vl mum
    where  to_organization_id = p_org_id
    and    wep.organization_id = to_organization_id
    and    supply_type_code  IN( 'PO','REQ','SHIPMENT')
    and    mum.description = ms.unit_of_measure
     and    receipt_date < ( SYSDATE + decode ( wep.data_period_unit ,
                                              1 ,
                                              wep.data_period_value /24,
                                              2 , wep.data_period_value,
                                              3, (ADD_MONTHS (SYSDATE,
                                                  wep.data_period_value ) - SYSDATE)
                                               )
                           );

  l_num_rows_inserted := SQL%ROWCOUNT;

   IF g_debug=1 THEN
    debug('The no of rows inserted  for inbound(PO,REQ,SHIPMENTS) '|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
   END IF;


 EXCEPTION
 WHEN OTHERS THEN
   IF g_debug=1 THEN
    debug('Exception in populating rows for inbound(PO,REQ,SHIPMENTS) ','POPULATE_EXPECTED_WORK');
   END IF;
  x_return_status := fnd_api.g_ret_sts_error;
  l_num_sql_failed := l_num_sql_failed+1;
  END;


--1. Receiving Inbound
--    o  Expected RMAs to be received in the given time frame
 BEGIN
  IF g_debug=1 THEN
   debug('Before populating work for Inbound(RMA) ','POPULATE_EXPECTED_WORK');
  END IF;

 l_num_rows_inserted := 0;

 insert into WMS_ELS_EXP_RESOURCE
(
   els_exp_resource_id,
   organization_id,
   activity_id,
   activity_detail_id,
   operation_id,
   document_type,
   source_subinventory,
   transaction_uom,
   inventory_item_id,
   quantity,
   source_header_id,
   source_line_id,
   group_id,
   work_scheduled_date,
   last_updated_by,
   last_update_date,
   last_update_login,
   created_by,
   creation_Date
  )
    select wms_els_exp_resource_s.nextval,
    ship_from_org_id,
    1, -- Inbound
    1, -- Recieving
    1, -- Reciept
    'RMA',
    subinventory,
    shipping_quantity_uom,
    inventory_item_id,
    shipping_quantity - shipped_quantity - cancelled_quantity,
    header_id,
    line_id,
    1, -- Manual and user directed
    promise_date,
    FND_GLOBAL.USER_ID,
    SYSDATE,
    FND_GLOBAL.LOGIN_ID,
    FND_GLOBAL.USER_ID,
    SYSDATE
    from oe_order_lines_all,
         wms_els_parameters wep
    where line_category_code like 'RETURN'
    and booked_flag ='Y'
    and cancelled_flag='N'
    and open_flag='Y'
    and flow_status_code not IN('CLOSED' , 'CANCELLED')
    AND flow_status_code = 'AWAITING_RETURN'
    and ship_from_org_id = p_org_id
    and wep.organization_id = ship_from_org_id
    and promise_date < ( SYSDATE + decode ( wep.data_period_unit ,
                                            1 ,
                                            wep.data_period_value /24,
                                            2 ,wep.data_period_value,
                                            3,(ADD_MONTHS (SYSDATE, wep.data_period_value
                                                  ) - SYSDATE)
                                          )
                        );

   l_num_rows_inserted := SQL%ROWCOUNT;

   IF g_debug=1 THEN
    debug('The no of rows inserted  for inbound(RMA) '|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
   END IF;


 EXCEPTION
 WHEN OTHERS THEN

   IF g_debug=1 THEN
    debug('Exception in populating rows for inbound(RMA) ','POPULATE_EXPECTED_WORK');
   END IF;

  x_return_status := fnd_api.g_ret_sts_error;
  l_num_sql_failed := l_num_sql_failed + 1;

  END;

--2.   Inbound Putaway
--     o Material that is received, but needs to be putaway
BEGIN
   IF g_debug=1 THEN
   debug('Before populating work for Inbound Putaway(PO) for DROP ','POPULATE_EXPECTED_WORK');
   END IF;

   l_num_rows_inserted := 0;

INSERT  INTO  WMS_ELS_EXP_RESOURCE
        (els_exp_resource_id ,
         organization_id,
         activity_id,
         activity_detail_id,
         operation_id,
         destination_subinventory,
         destination_locator_id,
         source_header_id,
         source_line_id,
         group_id,
         operation_plan_id,
         last_updated_by,
         last_update_Date,
         last_update_login,
         created_by,
         creation_Date
        )
    select
          WMS_ELS_EXP_RESOURCE_S.NEXTVAL,
          organization_id,
          1,--Inbound
          2,--Putaway
          3,--Drop
          subinventory_code,
          locator_id,
          transaction_header_id,
          transaction_temp_id,
          1, --manual and user directed
          operation_plan_id,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.LOGIN_ID,
          FND_GLOBAL.USER_ID,
          SYSDATE
    from
          mtl_material_transactions_temp
    where organization_id = p_org_id
    and   transaction_type_id = 18
    and   transaction_action_id =27
    and   transaction_source_type_id =1
    AND   wms_task_type IN (2,8)
    and   move_order_line_id IS NULL;


   l_num_rows_inserted := SQL%ROWCOUNT;

   IF g_debug=1 THEN
    debug('The no of rows inserted  for inbound putaway PO '|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
   END IF;


 EXCEPTION
 WHEN OTHERS THEN

   IF g_debug=1 THEN
    debug('Exception in populating rows for inbound putaway PO','POPULATE_EXPECTED_WORK');
   END IF;

  x_return_status := fnd_api.g_ret_sts_error;
  l_num_sql_failed := l_num_sql_failed + 1;

  END;

  --2.   Inbound Putaway (RMA)
--     o Material that is received through RMA, but needs to be putaway
BEGIN
   IF g_debug=1 THEN
   debug('Before populating work for Inbound Putaway for DROP( RMA) ','POPULATE_EXPECTED_WORK');
   END IF;

   l_num_rows_inserted := 0;

INSERT  INTO  WMS_ELS_EXP_RESOURCE
        (els_exp_resource_id ,
         organization_id,
         activity_id,
         activity_detail_id,
         operation_id,
         destination_subinventory,
         destination_locator_id,
         source_header_id,
         source_line_id,
         group_id,
         operation_plan_id,
         last_updated_by,
         last_update_Date,
         last_update_login,
         created_by,
         creation_Date
        )
    select
          WMS_ELS_EXP_RESOURCE_S.NEXTVAL,
          organization_id,
          1,--Inbound
          2,--Putaway
          3,--Drop
          subinventory_code,
          locator_id,
          transaction_header_id,
          transaction_temp_id,
          1, --manual and user directed
          operation_plan_id,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.LOGIN_ID,
          FND_GLOBAL.USER_ID,
          SYSDATE
    from
          mtl_material_transactions_temp
    where organization_id = p_org_id
    and   transaction_type_id = 15
    and   transaction_action_id =27
    and   transaction_source_type_id =12
    AND   wms_task_type IN (2,8)
    and   move_order_line_id IS NULL;


   l_num_rows_inserted := SQL%ROWCOUNT;

   IF g_debug=1 THEN
    debug('The no of rows inserted  for inbound putaway RMA '|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
   END IF;


 EXCEPTION
 WHEN OTHERS THEN

   IF g_debug=1 THEN
    debug('Exception in populating rows for inbound putaway RMA','POPULATE_EXPECTED_WORK');
   END IF;

  x_return_status := fnd_api.g_ret_sts_error;
  l_num_sql_failed := l_num_sql_failed + 1;

  END;

    --2.   Inbound Putaway (Intransit Shipment)
--     o Material that is received through Intransit Shipment, but needs to be putaway
BEGIN
   IF g_debug=1 THEN
   debug('Before populating work for Inbound Putaway for DROP( Intransit Shipment) ','POPULATE_EXPECTED_WORK');
   END IF;

   l_num_rows_inserted := 0;

INSERT  INTO  WMS_ELS_EXP_RESOURCE
        (els_exp_resource_id ,
         organization_id,
         activity_id,
         activity_detail_id,
         operation_id,
         destination_subinventory,
         destination_locator_id,
         source_header_id,
         source_line_id,
         group_id,
         operation_plan_id,
         last_updated_by,
         last_update_Date,
         last_update_login,
         created_by,
         creation_Date
        )
    select
          WMS_ELS_EXP_RESOURCE_S.NEXTVAL,
          organization_id,
          1,--Inbound
          2,--Putaway
          3,--Drop
          subinventory_code,
          locator_id,
          transaction_header_id,
          transaction_temp_id,
          1, --manual and user directed
          operation_plan_id,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.LOGIN_ID,
          FND_GLOBAL.USER_ID,
          SYSDATE
    from
          mtl_material_transactions_temp
    where organization_id = p_org_id
    and   transaction_type_id = 12
    and   transaction_action_id =12
    and   transaction_source_type_id =13
    AND   wms_task_type IN (2,8)
    and   move_order_line_id IS NULL;


   l_num_rows_inserted := SQL%ROWCOUNT;

   IF g_debug=1 THEN
    debug('The no of rows inserted  for inbound putaway Intransit Shipment '|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
   END IF;


 EXCEPTION
 WHEN OTHERS THEN

   IF g_debug=1 THEN
    debug('Exception in populating rows for inbound putaway Intransit Shipment','POPULATE_EXPECTED_WORK');
   END IF;

  x_return_status := fnd_api.g_ret_sts_error;
  l_num_sql_failed := l_num_sql_failed + 1;

  END;

      --2.   Inbound Putaway (Internal Requisition)
--     o Material that is received through Internal Requisition, but needs to be putaway
BEGIN
   IF g_debug=1 THEN
   debug('Before populating work for Inbound Putaway for DROP( Intransit Shipment) ','POPULATE_EXPECTED_WORK');
   END IF;

   l_num_rows_inserted := 0;

INSERT  INTO  WMS_ELS_EXP_RESOURCE
        (els_exp_resource_id ,
         organization_id,
         activity_id,
         activity_detail_id,
         operation_id,
         destination_subinventory,
         destination_locator_id,
         source_header_id,
         source_line_id,
         group_id,
         operation_plan_id,
         last_updated_by,
         last_update_Date,
         last_update_login,
         created_by,
         creation_Date
        )
    select
          WMS_ELS_EXP_RESOURCE_S.NEXTVAL,
          organization_id,
          1,--Inbound
          2,--Putaway
          3,--Drop
          subinventory_code,
          locator_id,
          transaction_header_id,
          transaction_temp_id,
          1, --manual and user directed
          operation_plan_id,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.LOGIN_ID,
          FND_GLOBAL.USER_ID,
          SYSDATE
    from
          mtl_material_transactions_temp
    where organization_id = p_org_id
    and   transaction_type_id = 61
    and   transaction_action_id =12
    and   transaction_source_type_id =7
    AND   wms_task_type IN (2,8)
    and   move_order_line_id IS NULL;


   l_num_rows_inserted := SQL%ROWCOUNT;

   IF g_debug=1 THEN
    debug('The no of rows inserted  for inbound putaway Intransit Shipment '|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
   END IF;


 EXCEPTION
 WHEN OTHERS THEN

   IF g_debug=1 THEN
    debug('Exception in populating rows for inbound putaway Intransit Shipment','POPULATE_EXPECTED_WORK');
   END IF;

  x_return_status := fnd_api.g_ret_sts_error;
  l_num_sql_failed := l_num_sql_failed + 1;

  END;



--5. Manufacturing Putaways
  BEGIN
   IF g_debug=1 THEN
   debug('Before populating work for Manufacturing Putaway DROP ','POPULATE_EXPECTED_WORK');
   END IF;

   l_num_rows_inserted := 0;

   INSERT  INTO  WMS_ELS_EXP_RESOURCE
        (els_exp_resource_id ,
         organization_id,
         activity_id,
         activity_detail_id,
         operation_id,
         destination_subinventory,
         destination_locator_id,
         source_header_id,
         source_line_id,
         group_id,
         last_updated_by,
         last_update_Date,
         last_update_login,
         created_by,
         creation_Date
        )
    select
          WMS_ELS_EXP_RESOURCE_S.NEXTVAL,
          organization_id,
          2,-- Manufacturing
          2,-- putaway
          3,--DROP
          subinventory_code,
          locator_id,
          transaction_header_id,
          transaction_temp_id,
          1, --manual and user directed
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.LOGIN_ID,
          FND_GLOBAL.USER_ID,
          SYSDATE
    from  mtl_material_transactions_temp
    where organization_id = p_org_id
    and   transaction_type_id = 44
    and   transaction_action_id =31
    and   transaction_source_type_id =5
    and   wms_task_type =2;

   l_num_rows_inserted := SQL%ROWCOUNT;

      IF g_debug=1 THEN
      debug('The no of rows inserted  for Manufacturing  putaway DROP'|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
      END IF;


   EXCEPTION
   WHEN OTHERS THEN

      IF g_debug=1 THEN
      debug('Exception in populating rows for Manufacturing Putaway DROP','POPULATE_EXPECTED_WORK');
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      l_num_sql_failed := l_num_sql_failed + 1;

   END;


--3. Inventory Accuracy
--Cycle count tasks outstanding

 BEGIN
   IF g_debug=1 THEN
   debug('Before populating work for Cycle Counting ','POPULATE_EXPECTED_WORK');
   END IF;

   l_num_rows_inserted := 0;
-- removed the join with   mtl_cc_schedule_requests  because the
-- the counting tasks would be in pending state as soon as requests are generated.

    insert into WMS_ELS_EXP_RESOURCE
      (  els_exp_resource_id ,
         organization_id,
         activity_id,
         activity_detail_id,
         operation_id,
         document_type,
         source_subinventory,
         source_locator_id,
         inventory_item_id,
         source_header_id,
         source_line_id,
         group_id,
         last_updated_by,
         last_update_Date,
         last_update_login,
         created_by,
         creation_Date
      )
    select wms_els_exp_resource_s.nextval,
         mcce.organization_id,
         4,-- Warehousing
         5,-- Counting
         4,--Count
         NULL,-- not inbound so document type is NULL
         mcce.Subinventory,
         mcce.locator_id,
         mcce.inventory_item_id,
         mcce.cycle_count_header_id,
         mcce.cycle_count_entry_id,
         1, --Individual and System Directed
         FND_GLOBAL.USER_ID,
         SYSDATE,
         FND_GLOBAL.LOGIN_ID,
         FND_GLOBAL.USER_ID,
         SYSDATE
         from
         mtl_cycle_Count_entries mcce
         WHERE
         mcce.organization_id = p_org_id
         and mcce.entry_status_code in (1,3); -- it is uncounted or for recounting.


   l_num_rows_inserted := SQL%ROWCOUNT;

      IF g_debug=1 THEN
      debug('The no of rows inserted  for Cycle Counting'|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
      END IF;


   EXCEPTION
   WHEN OTHERS THEN

      IF g_debug=1 THEN
      debug('Exception in populating rows for Cycle Counting','POPULATE_EXPECTED_WORK');
      END IF;

      x_return_status := fnd_api.g_ret_sts_error;
      l_num_sql_failed := l_num_sql_failed + 1;

   END;


--4. Outbound Shipping / Manufacturing
--    o  Unreleased / pending  for Sales orders,
--       manufacturing component picks, and internal orders
--6. Pending and outstanding replenishment tasks
-- These are FOR Load Operation

 BEGIN
   IF g_debug=1 THEN
   debug('Before populating LOAD TASKS for Outbound/Relenishment tasks(pending,unreleased) ','POPULATE_EXPECTED_WORK');
   END IF;

   l_num_rows_inserted := 0;

   insert into WMS_ELS_EXP_RESOURCE
   ( els_exp_resource_id ,
     organization_id,
     activity_id,
     activity_detail_id,
     operation_id,
     document_type,
     source_subinventory,
     source_locator_id,
     transaction_uom,
     quantity,
     inventory_item_id,
     source_header_id,
     source_line_id,
     group_id,
     operation_plan_id,
     last_updated_by,
     last_update_Date,
     last_update_login,
     created_by,
     creation_Date
   )
   select wms_els_exp_resource_s.nextval,
          mmtt.organization_id,
       (CASE  when (
                     (    Transaction_Type_Id = 52
                      and Transaction_Action_Id =28
                      and Transaction_Source_Type_Id = 2
                      and Wms_Task_Type =1
                     )
                  OR
                  (     Transaction_Type_Id =53
                    and Transaction_Action_Id =28
                    and Transaction_Source_Type_Id = 8
                    and Wms_Task_Type =1
                  )
               )
               THEN 3
          when  (
                   (    Transaction_Type_Id =64
                    and Transaction_Action_Id =2
                    AND Transaction_Source_Type_Id = 4
                    and Wms_Task_Type =4
                  )
                  OR
                  (     Transaction_Type_Id =64
                    and Transaction_Action_Id =2
                    and Transaction_Source_Type_Id = 4
                    and Wms_Task_Type =5
                  )
                  OR
                  (     Transaction_Type_Id =63
                    and Transaction_Action_Id =1
                    and Transaction_Source_Type_Id = 4
                    and Wms_Task_Type =6
                  )
               )
               THEN 4 -- Warehousing
          when  (
                   (    Transaction_Type_Id =51		-- Pull Type
                    and Transaction_Action_Id =2
                    and Transaction_Source_Type_Id = 13
                    and Wms_Task_Type =1
                  )
		  OR
		  (    Transaction_Type_Id =35		-- Push Type
                    and Transaction_Action_Id =1
                    and Transaction_Source_Type_Id = 5
                    and Wms_Task_Type =1
                  )
               )
               THEN 2 -- Manufacturing*/
       end
      ) activity_id,
      (CASE  when (
                     (   Transaction_Type_Id =52
                     and Transaction_Action_Id =28
                     and Transaction_Source_Type_Id = 2
                     and Wms_Task_Type =1
                  )
                  OR
                  (      Transaction_Type_Id =53
                     and Transaction_Action_Id =28
                     and Transaction_Source_Type_Id = 8
                     and Wms_Task_Type =1
                  )
                  OR
                  (      Transaction_Type_Id =51	-- Pull Type
                     and Transaction_Action_Id =2
                     and Transaction_Source_Type_Id = 13
                     and Wms_Task_Type =1
                   )
		   OR
		  (    Transaction_Type_Id =35		-- Push Type
                    and Transaction_Action_Id =1
                    and Transaction_Source_Type_Id = 5
                    and Wms_Task_Type =1
                  )
               )
               THEN 3-- Picking
           when (     Transaction_Type_Id =64
                  and Transaction_Action_Id =2
                  and Transaction_Source_Type_Id = 4
                  and Wms_Task_Type =4
               )
               THEN 8 -- Replenishment
           when (    Transaction_Type_Id =64
                  and Transaction_Action_Id =2
                  and Transaction_Source_Type_Id = 4
                  and Wms_Task_Type =5
               )
               THEN 7 -- Move order transfer
         when   (     Transaction_Type_Id =63
                  and Transaction_Action_Id =1
                  and Transaction_Source_Type_Id = 4
                  and Wms_Task_Type =6
               )
               THEN 6 -- Move Order Issue
         end
       ) actvity_detail_id,
      (CASE WHEN (     Transaction_Type_Id =63
                  and Transaction_Action_Id =1
                  and Transaction_Source_Type_Id = 4
                  and Wms_Task_Type =6
               )
               THEN 5 -- Issue
            ELSE 2 --Load
           END
      )operation_id,
      NULL,-- not inbound so document type is NULL
      mmtt.subinventory_code,
      mmtt.locator_id,
      (CASE when  allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt.transaction_uom
          end
         ),-- so if LPN is populated we donot need item level information
      (CASE  when  allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt.transaction_quantity
          end
         ),-- so if LPN is populated we donot need item level information
      (CASE  when  allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt.inventory_item_id
          end
         ),-- so if LPN is populated we donot need item level information
      mmtt.transaction_temp_id, -- mmtt.demand_source_header_id, Modified for bug # 5169490
     (CASE WHEN mmtt.demand_source_line is NOT NULL THEN to_number(mmtt.demand_source_line)
           else mmtt.parent_line_id
           end), /*mmtt.demand_source_line, Modified for bug # 5478983(For Bulk Tasks,
            demand_source_line will be NULL. hence, parent_line_id will be populated for BULK tasks) */
      3, --Individual and system directed
      operation_plan_id,
      FND_GLOBAL.USER_ID,
      SYSDATE,
      FND_GLOBAL.LOGIN_ID,
      FND_GLOBAL.USER_ID,
      SYSDATE
from
mtl_material_transactions_temp mmtt
where
    mmtt.organization_id = p_org_id
and
    (
      (    mmtt.transaction_Type_Id = 52
       and mmtt.Transaction_Action_Id =28
       and mmtt.Transaction_Source_Type_Id = 2
       and mmtt.Wms_Task_Type =1
       )
       OR
       (   mmtt.transaction_Type_Id = 53
       and mmtt.Transaction_Action_Id =28
       and mmtt.Transaction_Source_Type_Id = 8
       and mmtt.Wms_Task_Type =1
       )
       OR
       (   mmtt.transaction_Type_Id = 64
       and mmtt.Transaction_Action_Id =2
       and mmtt.Transaction_Source_Type_Id = 4
       and mmtt.Wms_Task_Type =4
       )
       OR
       (   mmtt.transaction_Type_Id = 64
       and mmtt.Transaction_Action_Id =2
       and mmtt.Transaction_Source_Type_Id = 4
       and mmtt.Wms_Task_Type =5
       )
       OR
       (   mmtt.transaction_Type_Id = 63
       and mmtt.Transaction_Action_Id =1
       and mmtt.Transaction_Source_Type_Id = 4
       and mmtt.Wms_Task_Type =6
       )
       OR
       (   mmtt.transaction_Type_Id = 51    -- Pull Type
       and mmtt.Transaction_Action_Id =2
       and mmtt.Transaction_Source_Type_Id = 13
       and mmtt.Wms_Task_Type =1
       )
       OR
       (   mmtt.transaction_Type_Id = 35    -- Push Type
       and mmtt.Transaction_Action_Id =1
       and mmtt.Transaction_Source_Type_Id = 5
       and mmtt.Wms_Task_Type =1
       )
    )
and  mmtt.wms_task_status IN(1,8)
and mmtt.transaction_temp_id = nvl(mmtt.parent_line_id, mmtt.transaction_temp_id); -- Added for bug #5478983

l_num_rows_inserted := SQL%ROWCOUNT;

IF g_debug=1 THEN
debug('The no of rows inserted  for LOAD TASKS Outbound/Relenishment tasks(pending,unreleased)'|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
END IF;


EXCEPTION
WHEN OTHERS THEN

IF g_debug=1 THEN
debug('Exception in populating rows for LOAD TASKS Outbound/Relenishment tasks(pending,unreleased)','POPULATE_EXPECTED_WORK');
END IF;

x_return_status := fnd_api.g_ret_sts_error;
l_num_sql_failed := l_num_sql_failed + 1;

END;


--4. Outbound Shipping / Manufacturing
--    o  Queued/Dispatched for Sales orders,
--       manufacturing component picks, and internal orders
--6. Pending and outstanding replenishment tasks
-- These are FOR Load Operation

 BEGIN
   IF g_debug=1 THEN
   debug('Before populating work for LOAD TASKS Outbound/Relenishment tasks(queued,dispatched) ','POPULATE_EXPECTED_WORK');
   END IF;

   l_num_rows_inserted := 0;

 insert into WMS_ELS_EXP_RESOURCE
   ( els_exp_resource_id ,
     organization_id,
     activity_id,
     activity_detail_id,
     operation_id,
     document_type,
     source_subinventory,
     source_locator_id,
     transaction_uom,
     quantity,
     inventory_item_id,
     source_header_id,
     source_line_id,
     group_id,
     operation_plan_id,
     last_updated_by,
     last_update_Date,
     last_update_login,
     created_by,
     creation_Date
   )
   select wms_els_exp_resource_s.nextval,
          mmtt.organization_id,
       (CASE  when (
                     (    Transaction_Type_Id = 52
                      and Transaction_Action_Id =28
                      and Transaction_Source_Type_Id = 2
                      and Wms_Task_Type =1
                     )
                  OR
                  (     Transaction_Type_Id =53
                    and Transaction_Action_Id =28
                    and Transaction_Source_Type_Id = 8
                    and Wms_Task_Type =1
                  )
               )
               THEN 3
          when  (
                   (    Transaction_Type_Id =64
                    and Transaction_Action_Id =2
                    AND Transaction_Source_Type_Id = 4
                    and Wms_Task_Type =4
                  )
                  OR
                  (     Transaction_Type_Id =64
                    and Transaction_Action_Id =2
                    and Transaction_Source_Type_Id = 4
                    and Wms_Task_Type =5
                  )
                  OR
                  (     Transaction_Type_Id =63
                    and Transaction_Action_Id =1
                    and Transaction_Source_Type_Id = 4
                    and Wms_Task_Type =6
                  )
               )
               THEN 4 -- Warehousing
          when  (
                   (    Transaction_Type_Id =51		-- Pull type
                    and Transaction_Action_Id =2
                    and Transaction_Source_Type_Id = 13
                    and Wms_Task_Type =1
                  )
		  OR
                   (    Transaction_Type_Id =35		-- Push type
                    and Transaction_Action_Id =1
                    and Transaction_Source_Type_Id = 5
                    and Wms_Task_Type =1
                  )

               )
               THEN 2 -- Manufacturing*/
       end
      ) activity_id,
      (CASE  when (
                     (   Transaction_Type_Id =52
                     and Transaction_Action_Id =28
                     and Transaction_Source_Type_Id = 2
                     and Wms_Task_Type =1
                  )
                  OR
                  (      Transaction_Type_Id =53
                     and Transaction_Action_Id =28
                     and Transaction_Source_Type_Id = 8
                     and Wms_Task_Type =1
                  )
                  OR
                  (      Transaction_Type_Id =51	-- Pull Type
                     and Transaction_Action_Id =2
                     and Transaction_Source_Type_Id = 13
                     and Wms_Task_Type =1
                   )
                  OR
                  (      Transaction_Type_Id =35	-- Push type
                     and Transaction_Action_Id =1
                     and Transaction_Source_Type_Id = 5
                     and Wms_Task_Type =1
                   )
               )
               THEN 3-- Picking
           when (     Transaction_Type_Id =64
                  and Transaction_Action_Id =2
                  and Transaction_Source_Type_Id = 4
                  and Wms_Task_Type =4
               )
               THEN 8 -- Replenishment
           when (    Transaction_Type_Id =64
                  and Transaction_Action_Id =2
                  and Transaction_Source_Type_Id = 4
                  and Wms_Task_Type =5
               )
               THEN 7 -- Move order transfer
         when   (     Transaction_Type_Id =63
                  and Transaction_Action_Id =1
                  and Transaction_Source_Type_Id = 4
                  and Wms_Task_Type =6
               )
               THEN 6 -- Move Order Issue
         end
       ) actvity_detail_id,
      (CASE WHEN (    Transaction_Type_Id =63
                  and Transaction_Action_Id =1
                  and Transaction_Source_Type_Id = 4
                  and Wms_Task_Type =6
               )
            THEN 5 -- Issue
            ELSE 2 --Load
       END
      )operation_id,
     NULL,-- not inbound so document type is NULL
      mmtt.subinventory_code,
      mmtt.locator_id,
      (CASE when  allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt.transaction_uom
          end
         ),-- so if LPN is populated we donot need item level information
      (CASE  when  allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt.transaction_quantity
          end
         ),-- so if LPN is populated we donot need item level information
      (CASE  when  allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt.inventory_item_id
          end
         ),-- so if LPN is populated we donot need item level information
      mmtt.transaction_temp_id, -- mmtt.demand_source_header_id, Modified for bug # 5169490
      (CASE WHEN mmtt.demand_source_line is NOT NULL THEN to_number(mmtt.demand_source_line)
           else mmtt.parent_line_id
           end), /*mmtt.demand_source_line, Modified for bug # 5478983(For Bulk Tasks,
            demand_source_line will be NULL. hence, parent_line_id will be populated for BULK tasks) */
      3, --Individual and system directed
      mmtt.operation_plan_id,
      FND_GLOBAL.USER_ID,
      SYSDATE,
      FND_GLOBAL.LOGIN_ID,
      FND_GLOBAL.USER_ID,
      SYSDATE
from
mtl_material_transactions_temp mmtt,
wms_dispatched_tasks wdt
where
    mmtt.organization_id = p_org_id
and
    (
      (    mmtt.transaction_Type_Id = 52
       and mmtt.Transaction_Action_Id =28
       and mmtt.Transaction_Source_Type_Id = 2
       and mmtt.Wms_Task_Type =1
       )
       OR
       (   mmtt.transaction_Type_Id = 53
       and mmtt.Transaction_Action_Id =28
       and mmtt.Transaction_Source_Type_Id = 8
       and mmtt.Wms_Task_Type =1
       )
       OR
       (   mmtt.transaction_Type_Id = 64
       and mmtt.Transaction_Action_Id =2
       and mmtt.Transaction_Source_Type_Id = 4
       and mmtt.Wms_Task_Type =4
       )
       OR
       (   mmtt.transaction_Type_Id = 64
       and mmtt.Transaction_Action_Id =2
       and mmtt.Transaction_Source_Type_Id = 4
       and mmtt.Wms_Task_Type =5
       )
       OR
       (   mmtt.transaction_Type_Id = 63
       and mmtt.Transaction_Action_Id =1
       and mmtt.Transaction_Source_Type_Id = 4
       and mmtt.Wms_Task_Type =6
       )
       OR
       (   mmtt.transaction_Type_Id = 51	--Pull Type
       and mmtt.Transaction_Action_Id =2
       and mmtt.Transaction_Source_Type_Id = 13
       and mmtt.Wms_Task_Type =1
       )
       OR
       (   mmtt.transaction_Type_Id = 35	--Push Type
       and mmtt.Transaction_Action_Id =1
       and mmtt.Transaction_Source_Type_Id = 5
       and mmtt.Wms_Task_Type =1
       )
    )
and (wdt.status IN (2,3) and wdt.transaction_temp_id = mmtt.transaction_temp_id)
and mmtt.transaction_temp_id = nvl(mmtt.parent_line_id, mmtt.transaction_temp_id); -- Added for bug #5478983

l_num_rows_inserted := SQL%ROWCOUNT;

IF g_debug=1 THEN
debug('The no of rows inserted  for LOAD TASKS Outbound/Relenishment tasks(queued,dispatched)'|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
END IF;


EXCEPTION
WHEN OTHERS THEN

IF g_debug=1 THEN
debug('Exception in populating rows for LOAD TASKS Outbound/Relenishment tasks(queued,dispatched)','POPULATE_EXPECTED_WORK');
END IF;

x_return_status := fnd_api.g_ret_sts_error;
l_num_sql_failed := l_num_sql_failed + 1;

END;


--4. Outbound Shipping / Manufacturing
--    o  Unreleased / pending  for Sales orders,
--       manufacturing component picks, and internal orders
--6. Pending and outstanding replenishment tasks
-- These are FOR DROP Operation

 BEGIN
   IF g_debug=1 THEN
   debug('Before populating work for DROP TASKS Outbound/Relenishment tasks(pending,unreleased) ','POPULATE_EXPECTED_WORK');
   END IF;

   l_num_rows_inserted := 0;

   insert into WMS_ELS_EXP_RESOURCE
   ( els_exp_resource_id ,
     organization_id,
     activity_id,
     activity_detail_id,
     operation_id,
     document_type,
     destination_subinventory,
     destination_locator_id,
     transaction_uom,
     quantity,
     inventory_item_id,
     source_header_id,
     source_line_id,
     group_id,
     operation_plan_id,
     last_updated_by,
     last_update_Date,
     last_update_login,
     created_by,
     creation_Date
   )
   select wms_els_exp_resource_s.nextval,
          mmtt.organization_id,
       (CASE  when (
                     (    Transaction_Type_Id = 52
                      and Transaction_Action_Id =28
                      and Transaction_Source_Type_Id = 2
                      and Wms_Task_Type =1
                     )
                  OR
                  (     Transaction_Type_Id =53
                    and Transaction_Action_Id =28
                    and Transaction_Source_Type_Id = 8
                    and Wms_Task_Type =1
                  )
               )
               THEN 3
          when  (
                   (    Transaction_Type_Id =64
                    and Transaction_Action_Id =2
                    AND Transaction_Source_Type_Id = 4
                    and Wms_Task_Type =4
                  )
                  OR
                  (     Transaction_Type_Id =64
                    and Transaction_Action_Id =2
                    and Transaction_Source_Type_Id = 4
                    and Wms_Task_Type =5
                  )
               )
               THEN 4 -- Warehousing
          when  (
                   (    Transaction_Type_Id =51		-- Pull Type
                    and Transaction_Action_Id =2
                    and Transaction_Source_Type_Id = 13
                    and Wms_Task_Type =1
                  )
		  OR
                   (    Transaction_Type_Id =35		-- Push Type
                    and Transaction_Action_Id =1
                    and Transaction_Source_Type_Id = 5
                    and Wms_Task_Type =1
                  )
               )
               THEN 2 -- Manufacturing*/
       end
      ) activity_id,
      (CASE  when (
                     (   Transaction_Type_Id =52
                     and Transaction_Action_Id =28
                     and Transaction_Source_Type_Id = 2
                     and Wms_Task_Type =1
                  )
                  OR
                  (      Transaction_Type_Id =53
                     and Transaction_Action_Id =28
                     and Transaction_Source_Type_Id = 8
                     and Wms_Task_Type =1
                  )
                  OR
                  (      Transaction_Type_Id =51	-- Pull Type
                     and Transaction_Action_Id =2
                     and Transaction_Source_Type_Id = 13
                     and Wms_Task_Type =1
                   )
                  OR
                  (      Transaction_Type_Id =35	-- Push Type
                     and Transaction_Action_Id =1
                     and Transaction_Source_Type_Id = 5
                     and Wms_Task_Type =1
                   )
               )
               THEN 3-- Picking
           when (     Transaction_Type_Id =64
                  and Transaction_Action_Id =2
                  and Transaction_Source_Type_Id = 4
                  and Wms_Task_Type =4
               )
               THEN 8 -- Replenishment
           when (    Transaction_Type_Id =64
                  and Transaction_Action_Id =2
                  and Transaction_Source_Type_Id = 4
                  and Wms_Task_Type =5
               )
               THEN 7 -- Move order transfer
         end
       ) actvity_detail_id,
      3,--Drop(Operation_ID)
      NULL,-- not inbound so document type is NULL
	   mmtt.transfer_subinventory,
	   mmtt.transfer_to_location,
      (CASE when  allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt.transaction_uom
          end
         ),-- so if LPN is populated we donot need item level information
      (CASE  when  allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt.transaction_quantity
          end
         ),-- so if LPN is populated we donot need item level information
      (CASE  when  allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt.inventory_item_id
          end
         ),-- so if LPN is populated we donot need item level information
      mmtt.transaction_temp_id, -- mmtt.demand_source_header_id, Modified for bug # 5169490
      mmtt.demand_source_line,
      3, --Individual and system directed
      mmtt.operation_plan_id,
      FND_GLOBAL.USER_ID,
      SYSDATE,
      FND_GLOBAL.LOGIN_ID,
      FND_GLOBAL.USER_ID,
      SYSDATE
from
mtl_material_transactions_temp mmtt
where
    mmtt.organization_id = p_org_id
and
    (
      (    mmtt.transaction_Type_Id = 52
       and mmtt.Transaction_Action_Id =28
       and mmtt.Transaction_Source_Type_Id = 2
       and mmtt.Wms_Task_Type =1
       )
       OR
       (   mmtt.transaction_Type_Id = 53
       and mmtt.Transaction_Action_Id =28
       and mmtt.Transaction_Source_Type_Id = 8
       and mmtt.Wms_Task_Type =1
       )
       OR
       (   mmtt.transaction_Type_Id = 64
       and mmtt.Transaction_Action_Id =2
       and mmtt.Transaction_Source_Type_Id = 4
       and mmtt.Wms_Task_Type =4
       )
       OR
       (   mmtt.transaction_Type_Id = 64
       and mmtt.Transaction_Action_Id =2
       and mmtt.Transaction_Source_Type_Id = 4
       and mmtt.Wms_Task_Type =5
       )
       OR
       (   mmtt.transaction_Type_Id = 51		-- Pull Type
       and mmtt.Transaction_Action_Id =2
       and mmtt.Transaction_Source_Type_Id = 13
       and mmtt.Wms_Task_Type =1
       )
       OR
       (   mmtt.transaction_Type_Id = 35		--Push Type
       and mmtt.Transaction_Action_Id =1
       and mmtt.Transaction_Source_Type_Id = 5
       and mmtt.Wms_Task_Type =1
       )
    )
and  mmtt.wms_task_status IN(1,8)
and  mmtt.transaction_temp_id <> nvl(mmtt.parent_line_id, -999); -- Added for bug # 5478983

l_num_rows_inserted := SQL%ROWCOUNT;

IF g_debug=1 THEN
debug('The no of rows inserted  for DROP TASKS Outbound/Relenishment tasks(pending,unreleased)'|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
END IF;


EXCEPTION
WHEN OTHERS THEN

IF g_debug=1 THEN
debug('Exception in populating rows for DROP TASKS Outbound/Relenishment tasks(pending,unreleased)','POPULATE_EXPECTED_WORK');
END IF;

x_return_status := fnd_api.g_ret_sts_error;
l_num_sql_failed := l_num_sql_failed + 1;

END;


--4. Outbound Shipping / Manufacturing
--    o  Queued/Dispatched for Sales orders,
--       manufacturing component picks, and internal orders
--6. Pending and outstanding replenishment tasks
-- These are FOR Drop Operation

 BEGIN
   IF g_debug=1 THEN
   debug('Before populating work for DROP TASKS Outbound/Relenishment tasks(queued,dispatched) ','POPULATE_EXPECTED_WORK');
   END IF;

   l_num_rows_inserted := 0;

 insert into WMS_ELS_EXP_RESOURCE
   ( els_exp_resource_id ,
     organization_id,
     activity_id,
     activity_detail_id,
     operation_id,
     document_type,
     destination_subinventory,
     destination_locator_id,
     transaction_uom,
     quantity,
     inventory_item_id,
     source_header_id,
     source_line_id,
     group_id,
     operation_plan_id,
     last_updated_by,
     last_update_Date,
     last_update_login,
     created_by,
     creation_Date
   )
   select wms_els_exp_resource_s.nextval,
          mmtt.organization_id,
       (CASE  when (
                     (    Transaction_Type_Id = 52
                      and Transaction_Action_Id =28
                      and Transaction_Source_Type_Id = 2
                      and Wms_Task_Type =1
                     )
                  OR
                  (     Transaction_Type_Id =53
                    and Transaction_Action_Id =28
                    and Transaction_Source_Type_Id = 8
                    and Wms_Task_Type =1
                  )
               )
               THEN 3
          when  (
                   (    Transaction_Type_Id =64
                    and Transaction_Action_Id =2
                    AND Transaction_Source_Type_Id = 4
                    and Wms_Task_Type =4
                  )
                  OR
                  (     Transaction_Type_Id =64
                    and Transaction_Action_Id =2
                    and Transaction_Source_Type_Id = 4
                    and Wms_Task_Type =5
                  )
               )
               THEN 4 -- Warehousing
          when  (
                   (    Transaction_Type_Id =51		-- Pull Type
                    and Transaction_Action_Id =2
                    and Transaction_Source_Type_Id = 13
                    and Wms_Task_Type =1
                  )
		  OR
                   (    Transaction_Type_Id =35		-- Push Type
                    and Transaction_Action_Id =1
                    and Transaction_Source_Type_Id = 5
                    and Wms_Task_Type =1
                  )
               )
               THEN 2 -- Manufacturing*/
       end
      ) activity_id,
      (CASE  when (
                     (   Transaction_Type_Id =52
                     and Transaction_Action_Id =28
                     and Transaction_Source_Type_Id = 2
                     and Wms_Task_Type =1
                  )
                  OR
                  (      Transaction_Type_Id =53
                     and Transaction_Action_Id =28
                     and Transaction_Source_Type_Id = 8
                     and Wms_Task_Type =1
                  )
                  OR
                  (      Transaction_Type_Id =51		-- Pull Type
                     and Transaction_Action_Id =2
                     and Transaction_Source_Type_Id = 13
                     and Wms_Task_Type =1
                   )
                  OR
                  (      Transaction_Type_Id =35		-- Push type
                     and Transaction_Action_Id =1
                     and Transaction_Source_Type_Id = 5
                     and Wms_Task_Type =1
                   )
               )
               THEN 3-- Picking
           when (     Transaction_Type_Id =64
                  and Transaction_Action_Id =2
                  and Transaction_Source_Type_Id = 4
                  and Wms_Task_Type =4
               )
               THEN 8 -- Replenishment
           when (    Transaction_Type_Id =64
                  and Transaction_Action_Id =2
                  and Transaction_Source_Type_Id = 4
                  and Wms_Task_Type =5
               )
               THEN 7 -- Move order transfer
         end
       ) actvity_detail_id,
      3,--Drop(Operation_ID)
      NULL,-- not inbound so document type is NULL
	   mmtt.transfer_subinventory,
	   mmtt.transfer_to_location,
      (CASE when  allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt.transaction_uom
          end
         ),-- so if LPN is populated we donot need item level information
      (CASE  when  allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt.transaction_quantity
          end
         ),-- so if LPN is populated we donot need item level information
      (CASE  when  allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt.inventory_item_id
          end
         ),-- so if LPN is populated we donot need item level information
      mmtt.transaction_temp_id, -- mmtt.demand_source_header_id, Modified for bug # 5169490
      mmtt.demand_source_line,
      3, --Individual and system directed
      mmtt.operation_plan_id,
      FND_GLOBAL.USER_ID,
      SYSDATE,
      FND_GLOBAL.LOGIN_ID,
      FND_GLOBAL.USER_ID,
      SYSDATE
from
mtl_material_transactions_temp mmtt,
wms_dispatched_tasks wdt
where
    mmtt.organization_id = p_org_id
and
    (
      (    mmtt.transaction_Type_Id = 52
       and mmtt.Transaction_Action_Id =28
       and mmtt.Transaction_Source_Type_Id = 2
       and mmtt.Wms_Task_Type =1
       )
       OR
       (   mmtt.transaction_Type_Id = 53
       and mmtt.Transaction_Action_Id =28
       and mmtt.Transaction_Source_Type_Id = 8
       and mmtt.Wms_Task_Type =1
       )
       OR
       (   mmtt.transaction_Type_Id = 64
       and mmtt.Transaction_Action_Id =2
       and mmtt.Transaction_Source_Type_Id = 4
       and mmtt.Wms_Task_Type =4
       )
       OR
       (   mmtt.transaction_Type_Id = 64
       and mmtt.Transaction_Action_Id =2
       and mmtt.Transaction_Source_Type_Id = 4
       and mmtt.Wms_Task_Type =5
       )
       OR
       (   mmtt.transaction_Type_Id = 51		-- Pull Type
       and mmtt.Transaction_Action_Id =2
       and mmtt.Transaction_Source_Type_Id = 13
       and mmtt.Wms_Task_Type =1
       )
       OR
       (   mmtt.transaction_Type_Id = 35		-- Push Type
       and mmtt.Transaction_Action_Id =1
       and mmtt.Transaction_Source_Type_Id = 5
       and mmtt.Wms_Task_Type =1
       )
    )
and (wdt.status IN (2,3,4) and wdt.transaction_temp_id = mmtt.transaction_temp_id)
and mmtt.parent_line_id is NULL; -- Added for bug # 5478983

l_num_rows_inserted := SQL%ROWCOUNT;

IF g_debug=1 THEN
debug('The no of rows inserted  for DROP TASKS Outbound/Relenishment tasks(queued,dispatched)'|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
END IF;

 /*
  * The following SQL has been added for the bug # 5478983.
  * The SQL will insert the information related to the Bulk drop tasks.
  *
  */

 IF g_debug=1 THEN
   debug('Before populating work for BULK DROP TASKS Outbound/Relenishment tasks(queued,dispatched) ','POPULATE_EXPECTED_WORK');
 END IF;

 l_num_rows_inserted := 0;

 insert into WMS_ELS_EXP_RESOURCE
   ( els_exp_resource_id ,
     organization_id,
     activity_id,
     activity_detail_id,
     operation_id,
     document_type,
     destination_subinventory,
     destination_locator_id,
     transaction_uom,
     quantity,
     inventory_item_id,
     source_header_id,
     source_line_id,
     group_id,
     operation_plan_id,
     last_updated_by,
     last_update_Date,
     last_update_login,
     created_by,
     creation_Date
   )
   select wms_els_exp_resource_s.nextval,
          mmtt2.organization_id,
       (CASE  when (
                     (    mmtt2.Transaction_Type_Id = 52
                      and mmtt2.Transaction_Action_Id =28
                      and mmtt2.Transaction_Source_Type_Id = 2
                      and mmtt2.Wms_Task_Type =1
                     )
                  OR
                  (     mmtt2.Transaction_Type_Id =53
                    and mmtt2.Transaction_Action_Id =28
                    and mmtt2.Transaction_Source_Type_Id = 8
                    and mmtt2.Wms_Task_Type =1
                  )
               )
               THEN 3
          when  (
                   (    mmtt2.Transaction_Type_Id =64
                    and mmtt2.Transaction_Action_Id =2
                    AND mmtt2.Transaction_Source_Type_Id = 4
                    and mmtt2.Wms_Task_Type =4
                  )
                  OR
                  (     mmtt2.Transaction_Type_Id =64
                    and mmtt2.Transaction_Action_Id =2
                    and mmtt2.Transaction_Source_Type_Id = 4
                    and mmtt2.Wms_Task_Type =5
                  )
               )
               THEN 4 -- Warehousing
          when  (
                   (    mmtt2.Transaction_Type_Id =51		-- Pull Type
                    and mmtt2.Transaction_Action_Id =2
                    and mmtt2.Transaction_Source_Type_Id = 13
                    and mmtt2.Wms_Task_Type =1
                  )
		  OR
                   (    mmtt2.Transaction_Type_Id =35		-- Push Type
                    and mmtt2.Transaction_Action_Id =1
                    and mmtt2.Transaction_Source_Type_Id = 5
                    and mmtt2.Wms_Task_Type =1
                  )
               )
               THEN 2 -- Manufacturing*/
       end
      ) activity_id,
      (CASE  when (
                     (   mmtt2.Transaction_Type_Id =52
                     and mmtt2.Transaction_Action_Id =28
                     and mmtt2.Transaction_Source_Type_Id = 2
                     and mmtt2.Wms_Task_Type =1
                  )
                  OR
                  (      mmtt2.Transaction_Type_Id =53
                     and mmtt2.Transaction_Action_Id =28
                     and mmtt2.Transaction_Source_Type_Id = 8
                     and mmtt2.Wms_Task_Type =1
                  )
                  OR
                  (      mmtt2.Transaction_Type_Id =51		-- Pull Type
                     and mmtt2.Transaction_Action_Id =2
                     and mmtt2.Transaction_Source_Type_Id = 13
                     and mmtt2.Wms_Task_Type =1
                   )
                  OR
                  (      mmtt2.Transaction_Type_Id =35		-- Push type
                     and mmtt2.Transaction_Action_Id =1
                     and mmtt2.Transaction_Source_Type_Id = 5
                     and mmtt2.Wms_Task_Type =1
                   )
               )
               THEN 3-- Picking
           when (     mmtt2.Transaction_Type_Id =64
                  and mmtt2.Transaction_Action_Id =2
                  and mmtt2.Transaction_Source_Type_Id = 4
                  and mmtt2.Wms_Task_Type =4
               )
               THEN 8 -- Replenishment
           when (    mmtt2.Transaction_Type_Id =64
                  and mmtt2.Transaction_Action_Id =2
                  and mmtt2.Transaction_Source_Type_Id = 4
                  and mmtt2.Wms_Task_Type =5
               )
               THEN 7 -- Move order transfer
         end
       ) actvity_detail_id,
      3,--Drop(Operation_ID)
      NULL,-- not inbound so document type is NULL
	   mmtt2.transfer_subinventory,
	   mmtt2.transfer_to_location,
      (CASE when  mmtt2.allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt2.transaction_uom
          end
         ),-- so if LPN is populated we donot need item level information
      (CASE  when  mmtt2.allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt2.transaction_quantity
          end
         ),-- so if LPN is populated we donot need item level information
      (CASE  when  mmtt2.allocated_lpn_id IS NOT NULL THEN NULL
             else  mmtt2.inventory_item_id
          end
         ),-- so if LPN is populated we donot need item level information
      mmtt2.transaction_temp_id, -- mmtt.demand_source_header_id, Modified for bug # 5169490
      mmtt2.demand_source_line,
      3, --Individual and system directed
      mmtt2.operation_plan_id,
      FND_GLOBAL.USER_ID,
      SYSDATE,
      FND_GLOBAL.LOGIN_ID,
      FND_GLOBAL.USER_ID,
      SYSDATE
from
mtl_material_transactions_temp mmtt1,
mtl_material_transactions_temp mmtt2,
wms_dispatched_tasks wdt
where
    mmtt1.organization_id = p_org_id
and mmtt2.organization_id = p_org_id
and
    (
      (    mmtt2.transaction_Type_Id = 52
       and mmtt2.Transaction_Action_Id =28
       and mmtt2.Transaction_Source_Type_Id = 2
       and mmtt2.Wms_Task_Type =1
       )
       OR
       (   mmtt2.transaction_Type_Id = 53
       and mmtt2.Transaction_Action_Id =28
       and mmtt2.Transaction_Source_Type_Id = 8
       and mmtt2.Wms_Task_Type =1
       )
       OR
       (   mmtt2.transaction_Type_Id = 64
       and mmtt2.Transaction_Action_Id =2
       and mmtt2.Transaction_Source_Type_Id = 4
       and mmtt2.Wms_Task_Type =4
       )
       OR
       (   mmtt2.transaction_Type_Id = 64
       and mmtt2.Transaction_Action_Id =2
       and mmtt2.Transaction_Source_Type_Id = 4
       and mmtt2.Wms_Task_Type =5
       )
       OR
       (   mmtt2.transaction_Type_Id = 51		-- Pull Type
       and mmtt2.Transaction_Action_Id =2
       and mmtt2.Transaction_Source_Type_Id = 13
       and mmtt2.Wms_Task_Type =1
       )
       OR
       (   mmtt2.transaction_Type_Id = 35		-- Push Type
       and mmtt2.Transaction_Action_Id =1
       and mmtt2.Transaction_Source_Type_Id = 5
       and mmtt2.Wms_Task_Type =1
       )
    )
and (wdt.status IN (2,3,4) and wdt.transaction_temp_id = mmtt1.transaction_temp_id)
and mmtt1.parent_line_id = mmtt2.parent_line_id
and mmtt1.parent_line_id <> mmtt2.transaction_temp_id
and mmtt1.parent_line_id is NOT NULL
and mmtt2.parent_line_id is NOT NULL;

l_num_rows_inserted := SQL%ROWCOUNT;

IF g_debug=1 THEN
  debug('The no of rows inserted  for BULK DROP TASKS Outbound/Relenishment tasks(queued,dispatched)'|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
END IF;


EXCEPTION
WHEN OTHERS THEN

IF g_debug=1 THEN
debug('Exception in populating rows for DROP TASKS Outbound/Relenishment tasks(queued,dispatched)','POPULATE_EXPECTED_WORK');
END IF;

x_return_status := fnd_api.g_ret_sts_error;
l_num_sql_failed := l_num_sql_failed + 1;

END;



--  Inventory Move
--     o Material that is Moved between the inventory locations
BEGIN
   IF g_debug=1 THEN
   debug('Before populating work for Inventory Move for DROP ','POPULATE_EXPECTED_WORK');
   END IF;

   l_num_rows_inserted := 0;

 INSERT  INTO  WMS_ELS_EXP_RESOURCE
        (els_exp_resource_id ,
         organization_id,
         activity_id,
         activity_detail_id,
         operation_id,
         destination_subinventory,
         destination_locator_id,
         transaction_uom,
         quantity,
         inventory_item_id,
         source_header_id,
         source_line_id,
         group_id,
         last_updated_by,
         last_update_Date,
         last_update_login,
         created_by,
         creation_Date
        )
 SELECT WMS_ELS_EXP_RESOURCE_S.NEXTVAL,
        organization_id,
		  activity_id,
		  activity_detail_id,
		  operation_id,
		  destination_subinventory,
		  destination_locator_id,
		  transaction_uom,
		  transaction_quantity,
		  inventory_item_id,
		  source_header_id,
		  source_line_id,
		  group_id,
		  FND_GLOBAL.USER_ID,
        SYSDATE,
        FND_GLOBAL.LOGIN_ID,
        FND_GLOBAL.USER_ID,
        SYSDATE
 FROM
		 (
  SELECT  DISTINCT
          mmtt.transfer_organization organization_id,
          4 activity_id,--Warehousing
          9 activity_detail_id,--Inventory Move
          3 operation_id,--Drop
          mmtt.transfer_subinventory destination_subinventory,
		    mmtt.transfer_to_location  destination_locator_id,
          decode(num_lines,1,mmtt.transaction_uom,NULL)  transaction_uom,
          decode (num_lines,1,mmtt.transaction_quantity,NULL) transaction_quantity,
          decode (num_lines,1,mmtt.inventory_item_id,NULL) inventory_item_id,
		    decode (num_lines,1,mmtt.transaction_header_id,0,NULL,mmtt.transaction_header_id) source_header_id,
          decode (num_lines,1,mmtt.transaction_temp_id,0,NULL,mmtt.lpn_id) source_line_id,
          1 group_id --manual and user directed
	FROM
	(SELECT lpn_id,transfer_to_location,count(*) num_lines
    FROM
	        mtl_material_transactions_temp
    WHERE organization_id = p_org_id
    AND   transaction_type_id = 64
    AND   transaction_action_id =2
    AND   transaction_source_type_id =4
    AND   wms_task_type =2
    GROUP BY lpn_id,transfer_to_location ) tab1, mtl_material_transactions_temp mmtt
	 WHERE  mmtt.lpn_id = tab1.lpn_id
    AND    mmtt.transfer_to_location = tab1.transfer_to_location
	);

   l_num_rows_inserted := SQL%ROWCOUNT;

   IF g_debug=1 THEN
    debug('The no of rows inserted  for Inventory Move DROP '|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
   END IF;


 EXCEPTION
 WHEN OTHERS THEN

   IF g_debug=1 THEN
    debug('Exception in populating rows for Inventory Move DROP','POPULATE_EXPECTED_WORK');
   END IF;

  x_return_status := fnd_api.g_ret_sts_error;
  l_num_sql_failed := l_num_sql_failed + 1;

  END;

--  Staging Move
--

BEGIN
   IF g_debug=1 THEN
   debug('Before populating work for Staging Move for DROP ','POPULATE_EXPECTED_WORK');
   END IF;

   l_num_rows_inserted := 0;


  INSERT  INTO  WMS_ELS_EXP_RESOURCE
        (els_exp_resource_id ,
         organization_id,
         activity_id,
         activity_detail_id,
         operation_id,
         destination_subinventory,
         destination_locator_id,
         transaction_uom,
         quantity,
         inventory_item_id,
         source_header_id,
         source_line_id,
		   operation_plan_id,
         group_id,
         last_updated_by,
         last_update_Date,
         last_update_login,
         created_by,
         creation_Date
        )
 select WMS_ELS_EXP_RESOURCE_S.NEXTVAL,
         organization_id,
		 activity_id,
		 activity_detail_id,
		 operation_id,
		 subinventory_code,
		 locator_id,
		 transaction_uom,
		 transaction_quantity,
		 inventory_item_id,
		 source_header_id,
		 source_line_id,
		 operation_plan_id,
		 group_id,
		 FND_GLOBAL.USER_ID,
       SYSDATE,
       FND_GLOBAL.LOGIN_ID,
       FND_GLOBAL.USER_ID,
       SYSDATE
		 from
		 (
 select  distinct
          mmtt.organization_id organization_id,
          3 activity_id,--Outbound
          4 activity_detail_id,--Staging Move
          3 operation_id,--Drop
          mmtt.subinventory_code subinventory_code,
		    mmtt.locator_id  locator_id,
          decode(num_lines,1,mmtt.transaction_uom,NULL)  transaction_uom,
          decode (num_lines,1,transaction_quantity,NULL) transaction_quantity,
          decode (num_lines,1,inventory_item_id,NULL) inventory_item_id,
		    decode (num_lines,1,transaction_header_id,NULL) source_header_id,
          decode (num_lines,1,transaction_temp_id,NULL) source_line_id,
		    mmtt.operation_plan_id,
          1 group_id --manual and user directed
		  from
	(select content_lpn_id,locator_id,count(*) num_lines from
	 mtl_material_transactions_temp
    where organization_id = p_org_id
    and   transaction_type_id = 2
    and   transaction_action_id =2
    and   transaction_source_type_id =13
    AND   wms_task_type =7
	 group by content_lpn_id,locator_id ) tab1, mtl_material_transactions_temp mmtt
    where  mmtt.content_lpn_id = tab1.content_lpn_id
    and    mmtt.locator_id = tab1.locator_id
	);

  l_num_rows_inserted := SQL%ROWCOUNT;

   IF g_debug=1 THEN
    debug('The no of rows inserted  for Staging Move DROP '|| l_num_rows_inserted,'POPULATE_EXPECTED_WORK');
   END IF;


 EXCEPTION
 WHEN OTHERS THEN

   IF g_debug=1 THEN
    debug('Exception in populating rows for Staging Move DROP','POPULATE_EXPECTED_WORK');
   END IF;

  x_return_status := fnd_api.g_ret_sts_error;
  l_num_sql_failed := l_num_sql_failed + 1;

  END;


IF l_num_sql_failed = g_total_sql THEN
   RAISE ALL_SQL_FAILED;
END IF;

   IF g_debug=1 THEN
    debug('The value of x_return_status '||x_return_status ,'POPULATE_EXPECTED_WORK');
   END IF;

EXCEPTION
WHEN ALL_SQL_FAILED THEN
IF g_debug=1 THEN
   debug('All SQLS failed','POPULATE_EXPECTED_WORK');
   END IF;

 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

 WHEN OTHERS THEN

   IF g_debug=1 THEN
   debug('Unexpected error occured','POPULATE_EXPECTED_WORK');
   END IF;

 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END POPULATE_EXPECTED_WORK;



-- We would do the following in this procedure

--Delete all the rows that are already populated in the WMS_ELS_EXP_RESOURCE for
--that organization. This is done so that no old rows are left in the table and the
--table can be freshly populated with expected work. This also ensures that all the
--tasks and expected work that is already done is flushed out and is not accounted any more.

-- Populate the WMS_ELS_EXP_RESOURCE table with the fresh set of expected work for
--the given data period(populated in the global setup).This will be done by calling
--the program WMS_ELS_EXPECTED_RES. Populate_Expecetd_Work.


-- Do the matching of the rows in WMS_ELS_EXP_RESOURCE table with the setup rows
--in WMS_ELS_INDIVIDUAL_TASKS_B using the where clause for that setup row(dynamic SQL),
--starting with the setup row having the least sequence number. Once a match is found
--stamp the Estimated_time column in WMS_ELS_EXP_RESOURCE  table with the time required
--to complete the transaction. Also stamp the Expecetd_Resource column based on the global
--setup.

-- The parameters p_data_period_unit, p_data_period_value,
--p_Num_work_hrs_day ,p_Utilization_rate will not be directly used in this
-- program. They are being passed in to retain the link that at the time of
-- running the concurrent what was the value of these global parameters

PROCEDURE MATCH_RATE_EXP_RESOURCE (
                                     errbuf             OUT    NOCOPY VARCHAR2
                                   , retcode            OUT    NOCOPY NUMBER
                                   , p_org_id           IN            NUMBER
                                   , p_data_period_unit IN            NUMBER
                                   , p_data_period_value IN           NUMBER
                                   , p_Num_work_hrs_day IN            NUMBER
                                   , p_Utilization_rate IN            NUMBER
                                     )IS


-- cursor to get all the rows in wms_els_individual_tasks_b table
-- for matching

CURSOR c_els_data(l_org_id NUMBER) IS
  SELECT  els_data_id,
          organization_id,
		    activity_id,
		    activity_detail_id,
		    operation_id,
          source_zone_id,
          source_subinventory,
          destination_zone_id,
          destination_subinventory,
          labor_txn_source_id,
          transaction_uom,
          from_quantity,
          to_quantity,
          item_category_id,
          operation_plan_id,
          group_id,
          task_type_id,
          expected_travel_time,
          expected_txn_time,
          expected_idle_time,
          travel_time_threshold,
          num_trx_matched
   FROM wms_els_individual_tasks_b
   WHERE organization_id = l_org_id
   AND history_flag IS NULL
   AND Analysis_id IN (2,4)
   ORDER BY group_id DESC,sequence_number ASC;


l_els_data c_els_data%ROWTYPE;

l_sql VARCHAR2(20000);

l_where_clause VARCHAR2(10000);

l_time_per_day  NUMBER;

c NUMBER;

l_ret BOOLEAN;

l_message VARCHAR2(250);

l_return_status VARCHAR2(1);
l_msg_count VARCHAR2(10);
l_msg_data VARCHAR2(100);
l_update_count NUMBER;

l_total NUMBER;

l_populate_status NUMBER;

l_num_execution_failed NUMBER;

BEGIN

l_populate_status := 0;
l_update_count    := 0;
l_total           := 0;
l_num_execution_failed := 0;


SAVEPOINT l_exp_work_populate;

IF g_debug=1 THEN
 debug('Starting processing for Expected Resource Requiremnt Analysis','MATCH_RATE_EXP_RESOURCE');
END IF;

-- proceed to any processing only is organization is labor enabled.

IF WMS_LMS_UTILS. ORG_LABOR_MGMT_ENABLED(p_org_id) THEN

   -- Insering the data into Global temporary table for the selected organization
   -- Added for the bug # 5169490

   IF g_debug=1 THEN
     debug('Before inserting the data into Global temporary table','MATCH_RATE_EXP_RESOURCE');
   END IF;

   INSERT INTO WMS_ELS_EXP_RESOURCE_GTEMP
       (SELECT els_data_id
             , source_header_id
             , source_line_id
             , activity_id
             , activity_detail_id
             , operation_id
          FROM wms_els_exp_resource
         WHERE organization_id = p_org_id
           AND els_data_id IS NOT NULL);

   IF g_debug=1 THEN
     debug('After inserting the data in Global temporary table','MATCH_RATE_EXP_RESOURCE');
   END IF;

--Delete all the rows that are already populated in the WMS_ELS_EXP_RESOURCE for
--that organization. This is done so that no old rows are left in the table and the
--table can be freshly populated with expected work. This also ensures that all the
--tasks and expected work that is already done is flushed out and is not accounted any more.

DELETE FROM WMS_ELS_EXP_RESOURCE WHERE organization_id = p_org_id;

-- Populate the WMS_ELS_EXP_RESOURCE table with the fresh set of expected work for
--the given data period(populated in the global setup).This will be done by calling
--the program WMS_ELS_EXPECTED_RES. Populate_Expecetd_Work.

           POPULATE_EXPECTED_WORK
                           (   x_return_status       => l_return_status
                              ,x_msg_count           => l_msg_count
                              ,x_msg_data            => l_msg_data
                              ,p_org_id              => p_org_id
                           );

  IF g_debug=1 THEN
   debug('The return status from Populate expected work is '|| l_return_status,'MATCH_RATE_EXP_RESOURCE');
  END IF;

 IF(l_return_status = FND_API.g_ret_sts_error )THEN
  -- Populate this status do that it can be used later for
  -- completeing the program with warning status

  l_populate_status := 1;

  END IF;

  IF(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR )THEN

  --- Dont PROCEED;return error from here itself;
       ROLLBACK TO l_exp_work_populate;
       retcode := 2;
       fnd_message.set_name('WMS', 'WMS_POPULATE_EXP_WORK_ERROR');
       l_message := fnd_message.get;
       l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);
       RETURN;

  END IF;

  -- Added for the bug # 5169490
  -- Update the number of matched transactions in wms_els_individual_tasks_b
  -- i.e, Deduct the matched transaction count for the tasks/record that has been
  -- populated again in wms_els_exp_resource table.

   IF g_debug=1 THEN
     debug('Before updating the data in wms_els_individual_tasks_b table','MATCH_RATE_EXP_RESOURCE');
   END IF;

   UPDATE wms_els_individual_tasks_b weitb
      SET num_trx_matched = num_trx_matched - (SELECT count(weerg.els_data_id)
                                                 FROM wms_els_exp_resource_gtemp weerg
                                                    , wms_els_exp_resource weer
                                                WHERE weerg.source_header_id = weer.source_header_id
                                                  AND weerg.source_line_id = weer.source_line_id
                                                  AND weerg.activity_id = weer.activity_id
                                                  AND weerg.activity_detail_id = weer.activity_detail_id
                                                  AND weerg.operation_id = weer.operation_id
                                                  AND weerg.els_data_id = weitb.els_data_id
                                                  AND weer.organization_id = p_org_id)
    WHERE weitb.organization_id = p_org_id
      AND weitb.analysis_id IN (2, 4); -- Analysis_id should be Work outstanding (4) or both(2) */


   IF g_debug=1 THEN
     debug('After updating the data in wms_els_individual_tasks_b table','MATCH_RATE_EXP_RESOURCE');
   END IF;


-- Now once all this is done Do the matching of the rows in WMS_ELS_EXP_RESOURCE table
--with the setup rows
--in WMS_ELS_INDIVIDUAL_TASKS_B using the where clause built dynamically (dynamic SQL),
--starting with the setup row having the least sequence number. Once a match is found
--stamp the Estimated_time column in WMS_ELS_EXP_RESOURCE  table with the time required
--to complete the transaction. Also stamp the Expecetd_Resource column based on the global
--setup.


OPEN c_els_data(p_org_id);
LOOP
FETCH c_els_data INTO l_els_data;
EXIT WHEN c_els_data%NOTFOUND;

-- flush out v_sql and v_where_clause so that it does not hold any old values

BEGIN

l_where_clause := NULL;

l_sql:=NULL;

IF g_debug=1 THEN
 debug('Check if we have some more rows to process if no exit','MATCH_RATE_EXP_RESOURCE');
END IF;

-- This fuction will return TRUE  if more rows are left non matched after a certain pass of the
--  setup data. It will return FALSE when no more rows are left to process. This fucntion will be
-- used to exit the processing once all rows in wms_els_trx_src are exhaused even before
--  all the rows in setup are exhausted.

IF WMS_LMS_UTILS.UNPROCESSED_ROWS_REMAINING (p_org_id) = 2 THEN
IF g_debug=1 THEN
 debug('No More rows to process so exit','MATCH_RATE_EXP_RESOURCE');
END IF;
EXIT;
END IF;

IF g_debug=1 THEN
 debug('Got some more rows to process so continue with the next setup row','MATCH_RATE_EXP_RESOURCE');
END IF;

IF l_els_data.organization_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND organization_id = :organization_id ';
END IF;

IF l_els_data.activity_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND activity_id = :activity_id ';
END IF;

IF l_els_data.activity_detail_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND activity_detail_id = :activity_detail_id ';
END IF;

IF l_els_data.operation_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND operation_id = :operation_id ';
END IF;


IF l_els_data.source_zone_id IS NOT NULL
THEN
   -- here not only match the zone_id but also if the loactor lies in that zone.
l_where_clause := l_where_clause || ' AND ((source_zone_id = :source_zone_id) '
                                 ||  ' OR ( '
                                 ||         'source_locator_id'
                                 ||  '      IN (select inventory_location_id'
                                 ||  '      from WMS_ZONE_LOCATORS'
                                 ||  '      where zone_id= :source_zone_id AND organization_id = :org_id'
                                 || ' AND '
                                 ||' WMS_LMS_UTILS. ZONE_LABOR_MGMT_ENABLED(:org_id,:source_zone_id)=''Y'''
                                 ||     ')'
                                 ||  ')) ';
END IF;

IF l_els_data.source_subinventory IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND source_subinventory = :source_subinventory ';
END IF;

IF l_els_data.destination_zone_id IS NOT NULL
THEN
   -- here not only match the zone_id but also if the loactor lies in that zone.
l_where_clause := l_where_clause || ' AND ((destination_zone_id = :destination_zone_id)'
                                 ||  ' OR ( '
                                 ||  ' destination_locator_id '
                                 ||  ' IN (select inventory_location_id '
                                 ||  ' from WMS_ZONE_LOCATORS '
                                 ||  ' where zone_id= :destination_zone_id AND organization_id = :org_id'
                                 || ' AND '
                                 ||  ' WMS_LMS_UTILS. ZONE_LABOR_MGMT_ENABLED(:org_id,:destination_zone_id)=''Y'''
                                 ||     ')'
                                 ||  ')) ';
END IF;

IF l_els_data.destination_subinventory IS NOT NULL
THEN
   l_where_clause := l_where_clause ||' AND destination_subinventory = :destination_subinventory ';
END IF;

--This condition check is not neede for Expected Resource Requirement Analysis
-- as for expected work this attribute is not known.

/*IF l_els_data.labor_txn_source_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND labor_txn_source_id = :labor_txn_source_id ';
END IF;
*/

IF l_els_data.transaction_uom IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND transaction_uom = :transaction_uom ';
END IF;

IF l_els_data.from_quantity IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND quantity >= :from_quantity ';
END IF;

IF l_els_data.to_quantity IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND quantity <= :to_quantity ';
END IF;

IF l_els_data.item_category_id IS NOT NULL
THEN
-- here not only match the category_id but also if the item is assigned to that category.
   l_where_clause :=l_where_clause || ' AND (( item_category_id = :item_category_id)'
                                    || ' OR ('
                                    ||  ' inventory_item_id'
                                    ||  ' IN (select inventory_item_id'
                                    ||  ' from MTL_ITEM_CATEGORIES'
                                    ||  ' where category_id= :item_category_id AND organization_id =:org_id'
                                    ||     ')'
                                    ||  ')) ';

END IF;

IF l_els_data.operation_plan_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND operation_plan_id = :operation_plan_id ';
END IF;

--This condition check is not neede for Expected Resource Requirement Analysis
-- as for expected work this attribute is not known.

/*IF l_els_data.group_id IS NOT NULL
THEN
   l_where_clause := l_where_clause || ' AND group_id = :group_id ';
END IF;
*/

l_sql :='UPDATE wms_els_exp_resource SET '
||'  els_data_id = :els_data_id'
||' ,source_zone_id = :source_zone'
||' ,destination_zone_id = :destination_zone'
||' ,item_category_id = :item_category'
||' , unattributed_flag = NULL'
||' ,estimated_time_required = (:expected_travel_time + :expected_txn_time + NVL(:expected_idle_time,0))'
||' ,estimated_resource_required =(:expected_travel_time + :expected_txn_time + NVL(:expected_idle_time,0))'
||                                ' /(:time_per_day*60*60*:utilization_rate/100)'
||'  where els_data_id IS NULL and organization_id = :org_id ';


IF g_debug=1 THEN
 debug('The sql clause constructed','MATCH_RATE_EXP_RESOURCE');
END IF;

--append the where clause
l_sql := l_sql||l_where_clause;

IF g_debug=1 THEN
 debug('The sql clause finally is '|| l_sql,'MATCH_RATE_EXP_RESOURCE');
END IF;

c:= dbms_sql.open_cursor;

IF g_debug=1 THEN
 debug('Opened the cursor for Binding ','MATCH_RATE_EXP_RESOURCE');
END IF;

DBMS_SQL.parse(c, l_sql, DBMS_SQL.native);

IF g_debug=1 THEN
 debug('Starting Binding the variables ','MATCH_RATE_EXP_RESOURCE');
END IF;

DBMS_SQL.bind_variable(c, 'els_data_id', l_els_data.els_data_id);

DBMS_SQL.bind_variable(c, 'source_zone', l_els_data.source_zone_id);

DBMS_SQL.bind_variable(c, 'destination_zone', l_els_data.destination_zone_id);

DBMS_SQL.bind_variable(c, 'item_category', l_els_data.item_category_id);

DBMS_SQL.bind_variable(c, 'expected_txn_time', l_els_data.expected_txn_time);

DBMS_SQL.bind_variable(c, 'expected_travel_time', l_els_data.expected_travel_time);

DBMS_SQL.bind_variable(c, 'expected_idle_time', l_els_data.expected_idle_time);

DBMS_SQL.bind_variable(c, 'time_per_day', p_Num_work_hrs_day);

DBMS_SQL.bind_variable(c, 'utilization_rate', p_Utilization_rate);

DBMS_SQL.bind_variable(c, 'org_id', p_org_id);

IF l_els_data.organization_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'organization_id', l_els_data.organization_id);
END IF;

IF l_els_data.activity_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'activity_id', l_els_data.activity_id);
END IF;

IF l_els_data.activity_detail_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'activity_detail_id', l_els_data.activity_detail_id);
END IF;

IF l_els_data.operation_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'operation_id', l_els_data.operation_id);
END IF;

IF l_els_data.source_zone_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'source_zone_id', l_els_data.source_zone_id);
END IF;

IF l_els_data.source_subinventory IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'source_subinventory', l_els_data.source_subinventory);
END IF;

IF l_els_data.destination_zone_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'destination_zone_id', l_els_data.destination_zone_id);
END IF;

IF l_els_data.destination_subinventory IS NOT NULL
THEN
    DBMS_SQL.bind_variable(c, 'destination_subinventory', l_els_data.destination_subinventory);
END IF;
/*
IF l_els_data.labor_txn_source_id IS NOT NULL
THEN
    DBMS_SQL.bind_variable(c, 'labor_txn_source_id', l_els_data.labor_txn_source_id);
END IF;
*/

IF l_els_data.transaction_uom IS NOT NULL
THEN
    DBMS_SQL.bind_variable(c, 'transaction_uom', l_els_data.transaction_uom);
END IF;

IF l_els_data.from_quantity IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'from_quantity', l_els_data.from_quantity);
END IF;

IF l_els_data.to_quantity IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'to_quantity', l_els_data.to_quantity);
END IF;

IF l_els_data.item_category_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'item_category_id', l_els_data.item_category_id);
END IF;

IF l_els_data.operation_plan_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'operation_plan_id', l_els_data.operation_plan_id);
END IF;

/*
IF l_els_data.group_id IS NOT NULL
THEN
   DBMS_SQL.bind_variable(c, 'group_id', l_els_data.group_id);
END IF;
*/

IF g_debug=1 THEN
 debug('All variables bound '|| l_sql,'MATCH_RATE_EXP_RESOURCE');
END IF;

l_update_count  := DBMS_SQL.EXECUTE(c);

IF g_debug=1 THEN
 debug('SQL executed Number of rows updated '|| l_update_count,'MATCH_RATE_EXP_RESOURCE');
END IF;


--get the row count

l_total := l_update_count + NVL(l_els_data.num_trx_matched,0);

DBMS_SQL.close_cursor(c);

--update the count with newly matched transactions

UPDATE wms_els_individual_tasks_b
SET
num_trx_matched = l_total
WHERE els_data_id = l_els_data.els_data_id;


EXCEPTION
WHEN OTHERS THEN
l_num_execution_failed := l_num_execution_failed +1;
IF g_debug=1 THEN
 debug('Execution failed for the els_data_id  '|| l_els_data.els_data_id,'MATCH_RATE_EXP_RESOURCE');
 debug('Exception occured '|| sqlerrm,'MATCH_RATE_EXP_RESOURCE');
END IF;

END;

END LOOP; -- all els_rows exhausted

-- now update all txns having els_data_id as NULL as non_attributed
l_update_count := NULL;


UPDATE wms_els_exp_resource SET unattributed_flag = 1
WHERE els_data_id IS NULL AND organization_id = p_org_id;

l_update_count := SQL%ROWCOUNT;

IF g_debug=1 THEN
 debug('Number of rows updated as non-standardized '|| l_update_count,'MATCH_RATE_EXP_RESOURCE');
 debug('Value of  l_num_execution_failed '|| l_num_execution_failed,'MATCH_RATE_EXP_RESOURCE');
 debug('Value of  l_populate_status '|| l_populate_status,'MATCH_RATE_EXP_RESOURCE');
END IF;

IF ( l_num_execution_failed = 0 AND l_populate_status = 0 )THEN

retcode := 1;
fnd_message.set_name('WMS', 'WMS_LMS_EXP_RES_SUCCESS');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',l_message);
COMMIT;

ELSIF ( l_num_execution_failed > 0 OR l_populate_status =1 ) THEN

retcode := 3;
fnd_message.set_name('WMS', 'WMS_LMS_EXP_RES_WARN');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',l_message);
COMMIT;
END IF;

ELSE -- org is not labor enabled

retcode := 3;
fnd_message.set_name('WMS', 'WMS_ORG_NOT_LMS_ENABLED');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',l_message);

END IF; -- If org is labor enabled

CLOSE C_ELS_DATA;

EXCEPTION

-- handle exception
WHEN OTHERS THEN
IF g_debug=1 THEN
 debug('Exception occured '|| sqlerrm,'MATCH_RATE_EXP_RESOURCE');
END IF;

IF C_ELS_DATA%ISOPEN THEN
CLOSE C_ELS_DATA;
END IF;

retcode := 2;
fnd_message.set_name('WMS', 'WMS_LMS_EXP_RES_ERROR');
l_message := fnd_message.get;
l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_message);


END MATCH_RATE_EXP_RESOURCE;

END WMS_LMS_EXPECTED_RES;


/
