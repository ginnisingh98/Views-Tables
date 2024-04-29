--------------------------------------------------------
--  DDL for Package Body GML_OPM_OM_CONV_MIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_OPM_OM_CONV_MIG_PKG" AS
/* $Header: GMLCONVB.pls 120.19 2007/02/23 22:09:26 plowe ship $ */

/*===========================================================================================================
--  PROCEDURE:
--   MIGRATE_OPM_OM_OPEN_LINES
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to OPM-OM open order lines
--
--  PARAMETERS:
--    p_migration_run_id   This is used for message logging.
--    p_commit             Commit flag.
--    x_failure_count      count of the failed lines.An out parameter.
--
--  SYNOPSIS:
--
--    MIGRATE_OPM_OM_OPEN_LINES (  p_migration_run_id  IN NUMBER
--                          	, p_commit IN VARCHAR2
--                          	, x_failure_count OUT NUMBER)
--  HISTORY
--=============================================================================================================*/

PROCEDURE Migrate_opm_om_open_lines( p_migration_run_id  IN NUMBER
                                   , p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE
                                   , x_failure_count OUT NOCOPY NUMBER) IS

/* Migration specific variables */
l_failure_count NUMBER := 0;
l_success_count NUMBER := 0;
l_table_name    VARCHAR2(30) DEFAULT NULL;
l_opm_table_name VARCHAR2(30) DEFAULT NULL;


-- Local Variables.
l_msg_count      NUMBER  :=0;
l_msg_data       VARCHAR2(2000);
l_return_status  VARCHAR2(1);
l_IC$DEFAULT_LOCT	VARCHAR2(255)DEFAULT NVL(FND_PROFILE.VALUE('IC$DEFAULT_LOCT'),' ') ;

l_wdd_rec		wsh_delivery_details%rowtype;
l_mo_line_rec		ic_txn_request_lines%rowtype;
l_order_line		oe_order_lines_all%rowtype;
l_ic_mo_header_rec	ic_txn_request_headers%rowtype;
l_mtl_mo_header_rec	INV_Move_Order_PUB.Trohdr_Rec_Type := INV_Move_Order_PUB.G_MISS_TROHDR_REC;
l_mtl_mo_line_rec	INV_Move_Order_PUB.Trolin_Rec_Type; /*(:= INV_Move_Order_PUB.G_MISS_TROLIN_TBL; */

/* MTL Move order header */

 l_trohdr_rec            INV_Move_Order_PUB.Trohdr_Rec_Type := INV_Move_Order_PUB.G_MISS_TROHDR_REC;
 l_trohdr_val_rec        INV_Move_Order_PUB.Trohdr_Val_Rec_Type;
 l_empty_trohdr_rec  INV_MOVE_ORDER_PUB.Trohdr_Rec_Type;

/* MTL Move order line */
 l_trolin_tbl            INV_Move_Order_PUB.Trolin_Tbl_Type;
 l_trolin_val_tbl	 INV_Move_Order_PUB.Trolin_Val_Tbl_Type;
 l_commit                VARCHAR2(1) := FND_API.G_TRUE;
 l_line_num              Number := 0;
 l_order_count           NUMBER := 1;

/* Item Controls */
l_grade_control_flag	VARCHAR2(1);
l_lot_divisible_flag	VARCHAR2(1);
l_opm_noninv_ind    NUMBER := 0; -- 5475003
l_dual_uom_control      NUMBER;
l_primary_uom_code	VARCHAR2(3);
l_secondary_uom_code	VARCHAR2(3);
l_tracking_quantity_ind VARCHAR2(30);
l_lot_control_code	NUMBER;
l_subinventory_ind_flag VARCHAR2(1);
l_lot_no		VARCHAR2(30);
l_sublot_no	 	VARCHAR2(30);
l_locator_id		NUMBER;
l_mo_line_id		NUMBER;
l_mo_header_id		NUMBER;
l_line_status		NUMBER;
l_detail_reservations	NUMBER := 0;

l_inventory_location_id NUMBER := 0;

l_organization_id       number; -- 5574631
l_failure_count1        NUMBER := 0; -- 5574631
l_inventory_item_id     number;   -- 5574631
l_subinventory_code     VARCHAR2(10); -- 5574631
l_to_locator_id		NUMBER;  -- 5601081
l_grouping_rule_id NUMBER; -- 5601081
l_sales_order_id    NUMBER;  -- 5601081
l_delivery_detail_id NUMBER;  -- 5601081
l_line_id NUMBER;   -- 5601081

l_api_return_status	VARCHAR2(1);
l_api_error_code	NUMBER;
l_api_error_msg		VARCHAR2(100);
l_message		VARCHAR2(255);
l_demand_source_type	NUMBER;
l_status 		BOOLEAN;

/* Reservation Related */

l_insert_rsv_rec        inv_reservation_global.mtl_reservation_rec_type; -- Record for inserting reservations
l_qty_reserved		NUMBER;
l_sec_qty_reserved	NUMBER;
l_reservation_id	NUMBER;
l_dummy_sn              inv_reservation_global.serial_number_tbl_type;
l_odm_lot_num        	VARCHAR2(80);
l_parent_lot_num 	VARCHAR2(80);
l_count          	NUMBER;

NON_INV_ITEM            EXCEPTION;


  CURSOR get_open_order_lines IS
  SELECT header_id,
         line_id,
         inventory_item_id,
         ship_from_org_id,
         schedule_status_code,
         'OE' source,
         ordered_quantity qty -- added for debug only
    FROM oe_order_lines_all ol,
         mtl_parameters mtl
   WHERE ol.ship_from_org_id = mtl.organization_id
     AND mtl.process_enabled_flag = 'Y' AND
         NVL(ol.shipping_interfaced_flag,'N')= 'N'
   UNION ALL
    SELECT wdd.source_header_id,
         wdd.source_line_id,
         wdd.inventory_item_id,
         wdd.organization_id,
         to_char(NULL) schedule_status_code,
         'WDD' source,
         0 qty
    FROM wsh_delivery_details wdd,
          mtl_parameters mtl
   WHERE wdd.organization_id = mtl.organization_id
     AND mtl.process_enabled_flag = 'Y'
     AND wdd.released_status in ('B','R','S', 'X'); -- 5475003 need to include status X for non inv items

  CURSOR get_allocations_for_line(p_line_id IN NUMBER) IS
  SELECT *
    FROM ic_tran_pnd
   WHERE doc_type = 'OMSO'
     AND line_id = p_line_id
     AND delete_mark = 0
     AND staged_ind = 0
     AND completed_ind = 0
     AND abs(round(trans_qty,5)) > 0
     AND (lot_id >0 OR location <> l_IC$DEFAULT_LOCT);

  CURSOR get_item_details(p_item_id IN NUMBER, p_organization_id IN NUMBER) IS
  SELECT m.lot_divisible_flag,m.lot_control_code,m.tracking_quantity_ind, ic.NONINV_IND  -- 5475003 rework
	FROM mtl_system_items m, ic_item_mst ic                               -- 5475003 rework
	WHERE inventory_item_id = p_item_id and organization_id = p_organization_id
	AND m.segment1 = ic.item_no;  -- 5475003 rework

  CURSOR get_whse_details(p_whse_code IN VARCHAR2) IS
  SELECT subinventory_ind_flag, organization_id    -- 5574631
    FROM ic_whse_mst
   WHERE whse_code = p_whse_code;

  CURSOR get_locator_id(p_whse_code IN VARCHAR2,p_location IN VARCHAR2) IS
  SELECT locator_id, inventory_location_id   -- 5576431
    FROM ic_loct_mst
   WHERE whse_code = p_whse_code
     AND location = p_location;

  -- 5576431

  CURSOR get_subinv(p_inventory_location_id IN NUMBER) IS
  SELECT subinventory_code
  FROM mtl_item_locations
  WHERE inventory_location_id = p_inventory_location_id;


  CURSOR get_lot_sublot(p_item_id IN NUMBER,p_lot_id IN NUMBER) IS
  SELECT lot_no,sublot_no
    FROM ic_lots_mst
   WHERE item_id = p_item_id
     AND lot_id = p_lot_id;

  CURSOR Get_Mo_Line(p_line_id IN NUMBER) IS
  SELECT *
    FROM ic_txn_request_lines
   WHERE txn_source_line_id = p_line_id
     AND line_status = 7; -- 7 is open , 5 is closed , 9 is cancelled

  CURSOR  get_delivery_details(p_mo_line_id IN NUMBER, p_line_id IN NUMBER) IS
   SELECT delivery_detail_id
     FROM wsh_delivery_details
    WHERE move_order_line_id = p_mo_line_id
      AND source_line_id = p_line_id;

  CURSOR get_move_order_header(p_line_id IN NUMBER) IS
  SELECT h.*
    FROM ic_txn_request_headers h,
         ic_txn_request_lines l
   WHERE l.header_id = h.header_id
     AND l.line_id = p_line_id;

  CURSOR Cur_get_sch_sta_code(p_line_id IN NUMBER) IS
  SELECT schedule_status_code
    FROM oe_order_lines_all
   WHERE line_id = p_line_id;


   --5574631
  CURSOR c_wsh_deliveres (p_line_id in number) is
	  select distinct wda.delivery_id
	  from   wsh_delivery_details wdd,
	         wsh_new_deliveries wnd,
	         wsh_delivery_assignments wda
	  where  wdd.source_line_id = p_line_id
	  and    wdd.delivery_detail_id = wda.delivery_detail_id
	  and    wda.delivery_id = wnd.delivery_id
	  and    wnd.delivery_id is not null;

  -- 5601081
  CURSOR get_shipping_parameters(p_org_id IN number) IS
  SELECT default_stage_locator_id, pick_grouping_rule_id
    FROM wsh_shipping_parameters
   WHERE organization_id = p_org_id;

-- 5601081
  CURSOR get_sales_order_id(p_header_id IN number) IS
  select sales_order_id
  from oe_order_headers_all oe, mtl_sales_orders mtl
  where oe.header_id = p_header_id and mtl.segment1 = oe.order_number;


BEGIN

   /* Begin by logging a message that open order lines migration has started */
   gma_common_logging.gma_migration_central_log (
                  p_run_id      => p_migration_run_id
                , p_log_level   => FND_LOG.LEVEL_PROCEDURE
                , p_app_short_name => 'GML'
                , p_message_token  => 'GML_MIGRATION_TABLE_STARTED'
                , p_table_name  => l_opm_table_name
                , p_context     => 'OPEN_ORDER_LINES');


   /* Get all the open lines to be processed */
   l_table_name := 'MTL_RESERVATIONS';
   l_opm_table_name := 'IC_TRAN_PND';
   GMI_RESERVATION_UTIL.println('START OF GML_OPM_OM_CONV_MIG_PKG.Migrate_opm_om_open_lines  - run_id = ' || p_migration_run_id);
   GMI_RESERVATION_UTIL.Println('IC DEFAULT_LOCT  is    ' || l_IC$DEFAULT_LOCT);

   FOR open_order_line_rec IN get_open_order_lines LOOP
       GMI_RESERVATION_UTIL.println('NNNNn - In get_open_order_lines loop which is the main loop');

      BEGIN
         /* Get the item controls for the order line */
         OPEN get_item_details(open_order_line_rec.inventory_item_id,open_order_line_rec.ship_from_org_id);
         FETCH get_item_details INTO l_lot_divisible_flag,l_lot_control_code,l_tracking_quantity_ind,l_opm_noninv_ind ;
         CLOSE get_item_details;

         GMI_RESERVATION_UTIL.println('after item controls '||'inventory_item_id : '||open_order_line_rec.inventory_item_id);
         GMI_RESERVATION_UTIL.println('l_opm_noninv_ind  : '||l_opm_noninv_ind );
         GMI_RESERVATION_UTIL.println('l_lot_control_code : '||l_lot_control_code);
         GMI_RESERVATION_UTIL.println('ordered_quantity : '||open_order_line_rec.qty);

         IF l_opm_noninv_ind  = 0  THEN -- 5475003 only check allocations if an inventory item (control from ic_item_mst)
		/*  -- NOTA BENE - we do not create move orders either for a non-inventory item in R12 (in 11i OPM we did )  */
	 	/* Are there allocations for this? If so create reservations for these allocations */

         GMI_RESERVATION_UTIL.println('line_id is '|| open_order_line_rec.line_id);
         FOR allocations_for_line_rec IN get_allocations_for_line(open_order_line_rec.line_id)
         LOOP

            BEGIN
               GMI_RESERVATION_UTIL.PrintLn('NNNN In allocations loop');

               /* Fill in the reservation record */
                l_insert_rsv_rec.reservation_id             := NULL; -- cannot know
                l_insert_rsv_rec.requirement_date           := SYSDATE;
                l_insert_rsv_rec.organization_id            := open_order_line_rec.ship_from_org_id;
                l_insert_rsv_rec.inventory_item_id          := open_order_line_rec.inventory_item_id;
                l_insert_rsv_rec.demand_source_type_id      := 2; /* For the Sales Order line */
                l_insert_rsv_rec.demand_source_name         := NULL;
                l_insert_rsv_rec.demand_source_header_id    := allocations_for_line_rec.doc_id; --open_order_line_rec.header_id;
                l_insert_rsv_rec.demand_source_line_id      := open_order_line_rec.line_id;
                l_insert_rsv_rec.demand_source_delivery     := NULL;
                l_insert_rsv_rec.primary_uom_code           := l_primary_uom_code;

                IF (l_tracking_quantity_ind = 'PS') THEN
                   l_insert_rsv_rec.secondary_uom_code         := l_secondary_uom_code;
                END IF;

                l_insert_rsv_rec.primary_uom_id             := NULL;
                l_insert_rsv_rec.secondary_uom_id           := NULL;
                l_insert_rsv_rec.reservation_uom_code       := NULL;
                l_insert_rsv_rec.reservation_uom_id         := NULL;
                l_insert_rsv_rec.reservation_quantity       := NULL;

                l_insert_rsv_rec.primary_reservation_quantity  := abs(trunc(allocations_for_line_rec.trans_qty,5)); -- 5616998

                IF (l_tracking_quantity_ind = 'PS') THEN
                   l_insert_rsv_rec.secondary_reservation_quantity:= abs(trunc(allocations_for_line_rec.trans_qty2,5)); -- 5616998
                ELSE
                   l_insert_rsv_rec.secondary_reservation_quantity := NULL; -- need to initialize this back else will fail
                END IF;

                --l_insert_rsv_rec.grade_code                    := NULL;
                l_insert_rsv_rec.autodetail_group_id           := NULL;
                l_insert_rsv_rec.external_source_code          := NULL;
                l_insert_rsv_rec.external_source_line_id       := NULL;
                l_insert_rsv_rec.supply_source_type_id         := inv_reservation_global.g_source_type_inv;
                l_insert_rsv_rec.supply_source_header_id       := NULL;
                l_insert_rsv_rec.supply_source_line_id         := NULL;
                l_insert_rsv_rec.supply_source_name            := NULL;
                l_insert_rsv_rec.supply_source_line_detail     := NULL;
                l_insert_rsv_rec.revision                      := NULL;

                /* See if the From Whse is mapped as a subinventory -   flag = Y*/
                -- if so, organization_id represents the new organization under which the warehouse is mapped as subinventory.
                OPEN get_whse_details(allocations_for_line_rec.whse_code);
                FETCH get_whse_details INTO l_subinventory_ind_flag, l_organization_id;   -- 5574631
                CLOSE get_whse_details;

                GMI_RESERVATION_UTIL.Println('subinventoryflag for the whse '|| l_subinventory_ind_flag);
                GMI_RESERVATION_UTIL.Println('whse_code '|| allocations_for_line_rec.whse_code);
                -- 5574631 start

                IF l_subinventory_ind_flag = 'Y' then --  5574631

		                GMI_RESERVATION_UTIL.PrintLn(' From Whse is mapped as a subinventory new organization_id is '|| l_organization_id);
		                -- From Whse is mapped as a subinventory, so need to
		                -- 1 update the SO line with new org (open_order_line_rec.ship_from_org_id) ;
		                -- 2 update any delivery details with new org;
		                -- 3 update wsh_new_deliveries  (trips do NOT store orgs) with the new org (all because of GMD's requirements);
		                -- 4 use this new org id for the reservation to be created;
		                -- 5 update any mo lines with new org id   -- 5731584

		                /* need to update the SO line with new org (open_order_line_rec.ship_from_org_id)  */
		               	 GMI_RESERVATION_UTIL.PrintLn(' before update to ship_from_org_id of so line '|| open_order_line_rec.line_id);

		               	 UPDATE oe_order_lines_all
		               	 SET  ship_from_org_id = l_organization_id
		               	 WHERE line_id = open_order_line_rec.line_id;


		                 -- update any OPM mo lines with new org id so that new id will be used for migration down below -- 5731584
		                  -- 5731584 start

		                 UPDATE ic_txn_request_lines
		               	 SET  organization_id = l_organization_id
		               	 WHERE txn_source_line_id = open_order_line_rec.line_id
		               	 AND line_status = 7;
		               	  -- 5731584 end


		               	 GMI_RESERVATION_UTIL.PrintLn(' before INV_OPM_Item_Migration.get_ODM_item ');


		                -- if here , then make sure item is in new org from sub inv - call get odm item to generate
		                -- as per Jatinder Gogna
		                  l_failure_count1 := 0;
		                  INV_OPM_Item_Migration.get_ODM_item (
		          		   p_migration_run_id => p_migration_run_id,
		           		   p_item_id => allocations_for_line_rec.item_id,
		           		   p_organization_id => l_organization_id,
		                	   p_mode => NULL,
		           		   p_commit => FND_API.G_TRUE,
		                	   x_inventory_item_id => l_inventory_item_id,
		                	   x_failure_count => l_failure_count1);

		                 IF (l_failure_count1 > 0) THEN
										-- Log Error
											GMI_RESERVATION_UTIL.PrintLn(' Failed to get discrete item. Item id :'||to_char(allocations_for_line_rec.item_id));
											GMA_COMMON_LOGGING.gma_migration_central_log (
											p_run_id          => p_migration_run_id,
											p_log_level       => FND_LOG.LEVEL_ERROR,
											p_message_token   => 'GMI_MIG_ITEM_MIG_FAILED',
											p_table_name      => 'IC_ITEM_CNV',
											p_context         => 'GET_ODM_ITEM',
											p_param1          => allocations_for_line_rec.item_id,
											p_param2          => l_organization_id,
											p_param3          => NULL,
											p_param4          => NULL,
											p_param5          => NULL,
											p_db_error        => NULL,
											p_app_short_name  => 'GMI');
											l_failure_count := l_failure_count + l_failure_count1;
											raise FND_API.G_EXC_ERROR;
										 END IF; --  IF (l_failure_count1 > 0) THEN

		                 /* possibly multiple delivery details are updated */
			       	update wsh_delivery_details
					set organization_id = l_organization_id
					where source_line_id = open_order_line_rec.line_id;


				GMI_RESERVATION_UTIL.PrintLn(' after update to wsh_delivery_details for organization_id  '|| l_organization_id);
				/* update the deliveries to reflect the new organization */

				FOR wsh1 in c_wsh_deliveres (open_order_line_rec.line_id)
				LOOP
				 GMI_RESERVATION_UTIL.PrintLn(' before update to wsh_delivery_details for organization_id  '|| l_organization_id);

				 update wsh_new_deliveries
	         		 set organization_id = l_organization_id
		       		 where delivery_id = wsh1.delivery_id;

				END LOOP; -- FOR wsh1 in c_wsh_delivery_details(open_order_line_rec.line_id)


		                 l_insert_rsv_rec.organization_id            := l_organization_id;

 		END IF;  -- IF l_subinventory_ind_flag = 'Y' then --

                -- 5574631 end


                GMI_RESERVATION_UTIL.PrintLn('primary_reservation_quantity ' || l_insert_rsv_rec.primary_reservation_quantity );

                l_insert_rsv_rec.subinventory_id            := NULL;
								GMI_RESERVATION_UTIL.Println('location '|| allocations_for_line_rec.location);

                l_locator_id := NULL; -- need to initialize this back else will fail
                l_inventory_location_id := NULL; -- need to initialize this back else will fail

                IF(allocations_for_line_rec.location <> l_IC$DEFAULT_LOCT) THEN

                    OPEN get_locator_id(allocations_for_line_rec.whse_code,allocations_for_line_rec.location);
                    FETCH get_locator_id INTO l_locator_id, l_inventory_location_id; -- use l_inventory_location_id for get_odm_lot as per J Gogna -
                    CLOSE get_locator_id;

                    GMI_RESERVATION_UTIL.Println('location becomes locator_id '|| l_locator_id);
                    -- as per Jatinder Gogna to support part of bug fix 5595222
                    -- Create locator in discrete ( dynamic locator)
                    IF (l_locator_id is NULL) THEN
                       GMI_RESERVATION_UTIL.Println('location (l_locator_id)  was NULL so calling  inv_migrate_process_org.create_location');
                       l_failure_count1 := 0;
		       inv_migrate_process_org.create_location(
				p_migration_run_id => p_migration_run_id,
				p_organization_id => l_organization_id,
				p_subinventory_code => allocations_for_line_rec.whse_code,
				p_location => allocations_for_line_rec.location,
				p_loct_desc => allocations_for_line_rec.location,
				p_start_date_active => sysdate,
				p_commit => FND_API.G_TRUE,
				x_location_id => l_locator_id,
				x_failure_count => l_failure_count1,
				p_segment2 => NULL,
				p_segment3 => NULL,
				p_segment4 => NULL,
				p_segment5 => NULL,
				p_segment6 => NULL,
				p_segment7 => NULL,
				p_segment8 => NULL,
				p_segment9 => NULL,
				p_segment10 => NULL,
				p_segment11 => NULL,
				p_segment12 => NULL,
				p_segment13 => NULL,
				p_segment14 => NULL,
				p_segment15 => NULL,
				p_segment16 => NULL,
				p_segment17 => NULL,
				p_segment18 => NULL,
				p_segment19 => NULL,
				p_segment20 => NULL);

			IF (l_failure_count1 > 0) THEN
			-- Log error
			GMI_RESERVATION_UTIL.Println('Unable to create the locator for dynamic OPM location :' || allocations_for_line_rec.whse_code ||', '||allocations_for_line_rec.location );
			GMA_COMMON_LOGGING.gma_migration_central_log (
				p_run_id          => p_migration_run_id,
				p_log_level       => FND_LOG.LEVEL_ERROR,
				p_message_token   => 'GMI_LOC_CREATION_FAILED',
				p_table_name      => 'IC_LOCT_MST',
				p_context         => 'inv_migrate_process_org.create_location',
				p_param1          => allocations_for_line_rec.whse_code,
				p_param2          => allocations_for_line_rec.location,
				p_param3          => NULL,
				p_param4          => NULL,
				p_param5          => NULL,
				p_db_error        => NULL,
				p_app_short_name  => 'GMI');
			l_failure_count := l_failure_count + l_failure_count1;
			raise FND_API.G_EXC_ERROR;
			END IF; -- IF (l_failure_count1 > 0) THEN
			GMI_RESERVATION_UTIL.Println('after calling  inv_migrate_process_org.create_location -  locator_id '|| l_locator_id);

	     	    END IF;  -- IF (l_locator_id is NULL) THEN


                    l_insert_rsv_rec.locator_id := l_locator_id;

                    -- 5574631 need to get correct subinv for the locator_id just retrieved
                    OPEN get_subinv(l_locator_id);
                    FETCH get_subinv INTO l_subinventory_code;
                    CLOSE get_subinv;
                    l_insert_rsv_rec.subinventory_code := l_subinventory_code;


                ELSE
                    l_insert_rsv_rec.locator_id             := NULL;
                    l_insert_rsv_rec.subinventory_code      := NULL;

                END IF; --  IF(allocations_for_line_rec.location <> 'l_IC$DEFAULT_LOCT') THEN

								GMI_RESERVATION_UTIL.Println('locator_id is '|| l_insert_rsv_rec.locator_id);
                GMI_RESERVATION_UTIL.Println('Before the lot_id if');
                GMI_RESERVATION_UTIL.Println('allocations_for_line_rec.lot id is '|| allocations_for_line_rec.lot_id);

                IF(allocations_for_line_rec.lot_id > 0 ) THEN
         	  GMI_RESERVATION_UTIL.Println('in the lot_id if and lot_id > 0  and  = ' || allocations_for_line_rec.lot_id  );

                  OPEN get_lot_sublot(allocations_for_line_rec.item_id,allocations_for_line_rec.lot_id);
                  FETCH get_lot_sublot INTO l_lot_no,l_sublot_no;
                  CLOSE get_lot_sublot;


                   -- 5574631


               		 INV_OPM_LOT_MIGRATION.GET_ODM_LOT(
			 		        P_MIGRATION_RUN_ID     => p_migration_run_id,
		           			P_INVENTORY_ITEM_ID    => open_order_line_rec.inventory_item_id,
		           			P_LOT_NO               => l_lot_no,
		           			P_SUBLOT_NO            => l_sublot_no,
		           			P_ORGANIZATION_ID      => l_organization_id, -- 5574631 instead of open_order_line_rec.ship_from_org_id,
		           			P_LOCATOR_ID           => l_inventory_location_id, -- 5574631 use instead of l_locator_id
		           			P_COMMIT               => FND_API.G_TRUE,
		           			X_LOT_NUMBER           => l_odm_lot_num,
		           			X_PARENT_LOT_NUMBER    => l_parent_lot_num,
		           			X_FAILURE_COUNT        => l_count
		           			);

	                 GMI_RESERVATION_UTIL.Println('get odm_lot: X_FAILURE_COUNT is '||l_count);

			 IF (l_count > 0)
			     THEN
				-- Log Error
		                GMI_RESERVATION_UTIL.Println('Failed to migrate lot - OPM lot_id  = '|| to_char(allocations_for_line_rec.lot_id));
		        	GMI_RESERVATION_UTIL.Println('Failed to migrate lot - OPM lot_no  = '|| l_lot_no);
				GMA_COMMON_LOGGING.gma_migration_central_log (
					p_run_id          => p_migration_run_id,
					p_log_level       => FND_LOG.LEVEL_ERROR,
					p_message_token   => 'GMI_MIG_LOT_MIG_FAILED',
					p_table_name      => 'IC_LOTS_MST',
					p_context         => 'GET_ODM_LOT',
					p_param1          => l_lot_no,
					p_param2          => INV_GMI_Migration.lot(allocations_for_line_rec.lot_id),
					p_param3          => l_organization_id,
					p_param4          => l_locator_id,
					p_param5          => NULL,
					p_db_error        => NULL,
					p_app_short_name  => 'GMI');
				raise FND_API.G_EXC_ERROR;
			ELSE
			       GMI_RESERVATION_UTIL.Println('get odm_lot succes: l_odm_lot_num is '||l_odm_lot_num);

			END IF;
			--  5574631


            	ELSE
                   -- Check if item is not lot controlled. If not nullify the lot fields.
                   IF l_lot_control_code = 1 THEN
                      l_odm_lot_num := NULL;
                      l_parent_lot_num := NULL;
                   END IF;
             END IF; -- IF(allocations_for_line_rec.lot_id > 0 ) THEN

                 GMI_RESERVATION_UTIL.Println('after the lot_id if');

                 l_insert_rsv_rec.lot_number                    := l_odm_lot_num;
                 l_insert_rsv_rec.lot_number_id                 := NULL;
                 l_insert_rsv_rec.pick_slip_number              := NULL;
                 l_insert_rsv_rec.lpn_id                        := NULL;
                 l_insert_rsv_rec.attribute_category            := NULL;
                 l_insert_rsv_rec.attribute1                    := NULL;
                 l_insert_rsv_rec.attribute2                    := NULL;
                 l_insert_rsv_rec.attribute3                    := NULL;
          			 l_insert_rsv_rec.attribute4                    := NULL;
                 l_insert_rsv_rec.attribute5                    := NULL;
                 l_insert_rsv_rec.attribute6                    := NULL;
                 l_insert_rsv_rec.attribute7                    := NULL;
                 l_insert_rsv_rec.attribute8                    := NULL;
                 l_insert_rsv_rec.attribute9                    := NULL;
                 l_insert_rsv_rec.attribute10                   := NULL;
                 l_insert_rsv_rec.attribute11                   := NULL;
                 l_insert_rsv_rec.attribute12                   := NULL;
                 l_insert_rsv_rec.attribute13                   := NULL;
                 l_insert_rsv_rec.attribute14                   := NULL;
                 l_insert_rsv_rec.attribute15                   := NULL;
                 l_insert_rsv_rec.ship_ready_flag               := 2;
                 l_insert_rsv_rec.detailed_quantity             := 0;


              inv_reservation_pvt.print_rsv_rec(l_insert_rsv_rec);

              GMI_RESERVATION_UTIL.PrintLn('about to call create_reservation');

              fnd_msg_pub.initialize;
              INV_RESERVATION_PUB.create_reservation(
              		p_api_version_number         => 1.0
            		, p_init_msg_lst               => fnd_api.g_false
            		, x_return_status              => l_api_return_status
            		, x_msg_count                  => l_msg_count
            		, x_msg_data                   => l_msg_data
            		, p_rsv_rec                    => l_insert_rsv_rec
            		, p_serial_number              => l_dummy_sn
            		, x_serial_number              => l_dummy_sn
            		, p_partial_reservation_flag   => fnd_api.g_true
            		, p_force_reservation_flag     => fnd_api.g_false
            		, p_validation_flag            => 'Q'
            		, x_quantity_reserved          => l_qty_reserved
            		, x_secondary_quantity_reserved=> l_sec_qty_reserved
            		, x_reservation_id             => l_reservation_id
            		);

                 -- Return an error if the create reservation call failed
                 IF l_api_return_status <> fnd_api.g_ret_sts_success THEN
                     GMI_RESERVATION_UTIL.PrintLn(' Create reservation failed');
                     GMI_RESERVATION_UTIL.PrintLn(l_msg_data);
                     FND_MSG_PUB.Count_AND_GET (p_count => l_msg_count, p_data  => l_msg_data);
		     						 FOR i in 1..l_msg_count LOOP

													GMA_COMMON_LOGGING.gma_migration_central_log (
														p_run_id          => p_migration_run_id,
														p_log_level       => FND_LOG.LEVEL_ERROR,
														p_message_token   => 'GMI_UNEXPECTED_ERROR',
														p_table_name      => 'IC_TRAN_PND',
														p_context         => 'CREATE RESERVATION',
														p_token1	  			=> 'ERROR',
														p_param1          => fnd_msg_pub.get_detail(i, NULL),
														p_param2          => NULL,
														p_param3          => NULL,
														p_param4          => NULL,
														p_param5          => NULL,
														p_db_error        => NULL,
														p_app_short_name  => 'GMI');
											 END LOOP;
								-- insert more comprehensive data into gma log table.

								 	   GMA_COMMON_LOGGING.gma_migration_central_log (
									                p_run_id          => p_migration_run_id,
											p_log_level       => FND_LOG.LEVEL_ERROR,
											p_message_token   => 'GMI_UNEXPECTED_ERROR',
											p_table_name      => 'IC_TRAN_PND',
											p_context         => 'CREATE RESERVATION',
											p_param1          => INV_GMI_Migration.item(allocations_for_line_rec.item_id),
											p_param2          => INV_GMI_Migration.lot(allocations_for_line_rec.lot_id),
											p_param3          => allocations_for_line_rec.whse_code,
											p_param4          => l_insert_rsv_rec.subinventory_code,
											p_param5          => l_insert_rsv_rec.locator_id,
											p_db_error        => NULL,
											p_app_short_name  => 'GMI');

	                    fnd_message.set_name('INV', 'INV_CREATE_RSV_FAILED');
	                    fnd_msg_pub.ADD;
	                    RAISE fnd_api.g_exc_unexpected_error;
                 ELSE
                    GMI_RESERVATION_UTIL.PrintLn(' Create reservation succeeded  - Reservation_id : '|| l_reservation_id);
                    GMI_RESERVATION_UTIL.PrintLn(' l_qty_reserved : '|| l_qty_reserved);
                    GMI_RESERVATION_UTIL.PrintLn(' l_sec_qty_reserved : '|| l_sec_qty_reserved);
                    GMI_RESERVATION_UTIL.PrintLn(' Created at least one detailed reservation ');
                     /* Created atleast one detailed reservation */
                    l_detail_reservations := 1;
                 END IF; -- IF l_api_return_status <> fnd_api.g_ret_sts_success THEN


             EXCEPTION
               --WHEN NON_INV_ITEM THEN
                 -- GMI_RESERVATION_UTIL.PrintLn('Non inventory item..doing nothing');
                 -- NULL;

               WHEN FND_API.g_exc_unexpected_error THEN
								l_failure_count := l_failure_count + 1;


               WHEN OTHERS THEN
                 /* Failure count goes up by 1 */
                 l_failure_count := l_failure_count+1;
                 gma_common_logging.gma_migration_central_log (
                  	p_run_id      => p_migration_run_id
                	, p_log_level   => FND_LOG.LEVEL_UNEXPECTED
                	, p_app_short_name =>'GML'
                	, p_message_token  => 'GML_MIGRATION_DB_ERROR'
                	, p_db_error    => sqlerrm
                	, p_table_name  => 'IC_TRAN_PND'
                	, p_context     => 'TRANSACTIONS');

             END;  /* Begin for allocations loop */

         END LOOP; /* FOR allocations_for_line_rec IN get_allocations_for_line(open_order_line_rec.line_id) */

	 IF( l_detail_reservations = 0 ) THEN

	         /*IF open_order_line_rec.source = 'WDD' THEN
	            Open Cur_get_sch_sta_code;
	            Fetch Cur_get_sch_sta_code into open_order_line_rec.schedule_status_code;
	            Close Cur_get_sch_sta_code;
	         END IF;*/

	           IF(open_order_line_rec.schedule_status_code = 'SCHEDULED' AND l_lot_divisible_flag <> 'Y') THEN
	          /* once this is implemented please uncomment the cuRsor Cur_get_sch_sta_code above */
	          		NULL;
	           END IF;
         END IF;        -- IF( l_detail_reservations = 0 ) THEN

       ELSE
          -- NON INV ITEM
         	GMI_RESERVATION_UTIL.PrintLn('Non inventory item..so doing nothing for reservations or move orders');

       END IF; -- IF l_opm_noninv_ind  = 0 THEN -- 5475003 only check if an inventory item


      /****** If there've not been any detail reservations, create a High Level Reservation depending on Sheduling */

	--- NOTA BENE - we do not create move orders for a non-inventory item in R12 (in 11i OPM did )

      FOR move_order_line_rec IN get_mo_line(open_order_line_rec.line_id)
      LOOP


          BEGIN

          IF l_opm_noninv_ind  = 0  THEN -- -- 5475003 rework 10/19 -  only create Move Orders if an inventory item (control from ic_item_mst)
		/* - we do not create move orders for a non-inventory item in R12 (in 11i OPM we did )  */

            GMI_RESERVATION_UTIL.PrintLn('In move_order_line_rec cursor and this is an inventory item - Sales Order line_id : ic_txn_request_lines line id  '|| to_char(open_order_line_rec.line_id)||':'||to_char(move_order_line_rec.line_id));

            /* Look for the move order header, has an mtl move order header been created for this already? */
            OPEN get_move_order_header (move_order_line_rec.line_id);
            FETCH get_move_order_header INTO l_ic_mo_header_rec;
            CLOSE get_move_order_header;
            GMI_RESERVATION_UTIL.PrintLn('in move order header id and attribute15  '|| to_char(l_ic_mo_header_rec.header_id)||' and '||l_ic_mo_header_rec.attribute15);

            -- need to get location_id and pick_grouping rule_id from wsh_shipping_parameters
            -- for grouping_rule_id for MO header and for to_locator_id for  MO line -- 5601081
            OPEN get_shipping_parameters(move_order_line_rec.organization_id);
            FETCH get_shipping_parameters INTO l_to_locator_id,l_grouping_rule_id;
            CLOSE get_shipping_parameters;
            GMI_RESERVATION_UTIL.PrintLn('shipping params l_to_locator_id = ' || l_to_locator_id );

            IF(l_ic_mo_header_rec.attribute15 IS NOT NULL) THEN

                 --l_mo_header_id := to_number(l_ic_mo_header_rec.header_id); -- 5111050 COMMENTED OUT
                 l_mo_header_id := to_number(l_ic_mo_header_rec.attribute15); -- 5111050

            ELSE /* No move order header exists, create one. */

               GMI_RESERVATION_UTIL.PrintLn('if here then l_ic_mo_header_rec.attribute15 is null');


               l_trohdr_rec     		                   := l_empty_trohdr_rec;
               --not initializing this was causing problems of unique constraints.
               l_trohdr_rec.header_id                  := inv_transfer_order_pvt.get_next_header_id;
               l_trohdr_rec.created_by                 := FND_GLOBAL.user_id;
               l_trohdr_rec.request_number	           := l_ic_mo_header_rec.request_number;
    	       	 l_trohdr_rec.creation_date              := sysdate;
               l_trohdr_rec.date_required              := sysdate;
               l_trohdr_rec.from_subinventory_code     := l_ic_mo_header_rec.from_subinventory_code;
               l_trohdr_rec.header_status     	       := INV_Globals.G_TO_STATUS_PREAPPROVED;
               l_trohdr_rec.last_updated_by            := FND_GLOBAL.user_id;
               l_trohdr_rec.last_update_date           := sysdate;
               l_trohdr_rec.last_update_login          := FND_GLOBAL.login_id;
               l_trohdr_rec.organization_id            := l_ic_mo_header_rec.organization_id;
               l_trohdr_rec.status_date                := sysdate;
               l_trohdr_rec.to_subinventory_code       := l_ic_mo_header_rec.to_subinventory_code;
               --l_trohdr_rec.transaction_type_id      := INV_GLOBALS.G_TYPE_TRANSFER_ORDER_ISSUE; -- not sure of this
               l_trohdr_rec.db_flag                    := FND_API.G_TRUE;
               l_trohdr_rec.operation                  := INV_GLOBALS.G_OPR_CREATE;
               l_trohdr_rec.move_order_type	       		 := INV_GLOBALS.G_MOVE_ORDER_PICK_WAVE; -- 5601081 type changed
               l_trohdr_rec.grouping_rule_id 				   := l_grouping_rule_id ;  -- 5601081
               GMI_RESERVATION_UTIL.PrintLn('before call to INV_Move_Order_PUB.Create_move_order_header');

               fnd_msg_pub.initialize;
               INV_Move_Order_PUB.Create_move_order_header (  p_api_version_number       => 1.0 ,
            		   p_init_msg_list            => 'T',
           	       p_commit                   => FND_API.G_FALSE,
               		 p_return_values => FND_API.G_TRUE,
            		   x_return_status            => l_return_status,
            		   x_msg_count                => l_msg_count,
            		   x_msg_data                 => l_msg_data,
            		   p_trohdr_rec               => l_trohdr_rec,
            		   p_trohdr_val_rec           => l_trohdr_val_rec,
            		   x_trohdr_rec               => l_trohdr_rec,
            		   x_trohdr_val_rec           => l_trohdr_val_rec
         					);

               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     GMI_RESERVATION_UTIL.PrintLn(' Create_move_order_header failed ');
                     GMI_RESERVATION_UTIL.PrintLn(l_msg_data);
                     FND_MSG_PUB.Count_AND_GET (p_count => l_msg_count, p_data  => l_msg_data);
		     						 FOR i in 1..l_msg_count LOOP

													GMA_COMMON_LOGGING.gma_migration_central_log (
														p_run_id          => p_migration_run_id,
														p_log_level       => FND_LOG.LEVEL_ERROR,
														p_message_token   => 'GMI_UNEXPECTED_ERROR',
														p_table_name      => 'mtl_txn_request_headers',
														p_context         => 'Create_move_order_header',
														p_token1	  			=> 'ERROR',
														p_param1          => fnd_msg_pub.get_detail(i, NULL),
														p_param2          => NULL,
														p_param3          => NULL,
														p_param4          => NULL,
														p_param5          => NULL,
														p_db_error        => NULL,
														p_app_short_name  => 'GMI');
										 END LOOP;
								-- insert more comprehensive data into gma log table.

								 	   GMA_COMMON_LOGGING.gma_migration_central_log (
											p_run_id          => p_migration_run_id,
											p_log_level       => FND_LOG.LEVEL_ERROR,
											p_message_token   => 'INV_ERROR_CREATING_MO',
											p_table_name      => 'mtl_txn_request_headers',
											p_context         => 'Create_move_order_header',
											p_param1          => l_ic_mo_header_rec.request_number,
											p_param2          => l_ic_mo_header_rec.organization_id,
											p_param3          => NULL,
											p_param4          => NULL,
											p_param5          => NULL,
											p_db_error        => NULL,
											p_app_short_name  => 'INV');

	                    fnd_message.set_name('INV', 'INV_ERROR_CREATING_MO');
	                    fnd_msg_pub.ADD;
	                    RAISE fnd_api.g_exc_unexpected_error;
                 ELSE
                     GMI_RESERVATION_UTIL.PrintLn(' Create_move_order_header succeeded   - header_id : '|| l_trohdr_rec.header_id);
               			 l_mo_header_id := l_trohdr_rec.header_id;
               			-- only do this if the create move order header above suceeded
                      /* Update attribute15 in ic_txn_request_headers */
			                GMI_RESERVATION_UTIL.PrintLn(' before update to attribute15 of in ic_txn_request_headers: '||to_char(l_trohdr_rec.header_id));

			                UPDATE ic_txn_request_headers
			                SET  attribute15 = to_char(l_trohdr_rec.header_id)
			                WHERE header_id = l_ic_mo_header_rec.header_id;

			                GMI_RESERVATION_UTIL.PrintLn(' after update to attribute15 of in ic_txn_request_headers');

               END IF; -- IF l_api_return_status <> fnd_api.g_ret_sts_success THEN

              END IF; -- IF(l_ic_mo_header_rec.attribute15 IS NOT NULL) THEN

              /* Now Create a line  */
             GMI_RESERVATION_UTIL.PrintLn(' Now for lines - ic_txn_request_lines attribute15: '||move_order_line_rec.attribute15);

              IF(move_order_line_rec.attribute15 IS NOT NULL) THEN
                 l_mo_line_id := to_number(move_order_line_rec.attribute15);

              ELSE /* Create a move order line  */

             	GMI_RESERVATION_UTIL.PrintLn('debug messages start for create move order line ********************************');
             	GMI_RESERVATION_UTIL.PrintLn('ic_txn_request_lines attribute15  = null ');
 	      	GMI_RESERVATION_UTIL.PrintLn('l_trohdr_rec.header_id : '|| l_trohdr_rec.header_id);
 	      	GMI_RESERVATION_UTIL.PrintLn('l_mo_header_id : '|| l_mo_header_id);
 	      	GMI_RESERVATION_UTIL.PrintLn('from_subinventory_code : '|| move_order_line_rec.from_subinventory_code);
 	      	GMI_RESERVATION_UTIL.PrintLn('inventory_item_id : '|| move_order_line_rec.inventory_item_id);
 	      	GMI_RESERVATION_UTIL.PrintLn('line_number : '|| l_line_num);
 	      	GMI_RESERVATION_UTIL.PrintLn('organization_id : '|| move_order_line_rec.organization_id);
 	      	GMI_RESERVATION_UTIL.PrintLn('quantity : '|| move_order_line_rec.quantity);
 		GMI_RESERVATION_UTIL.PrintLn('secondary_quantity : '|| move_order_line_rec.secondary_quantity);
 		GMI_RESERVATION_UTIL.PrintLn('to_subinventory_code : '|| move_order_line_rec.to_subinventory_code);
 		GMI_RESERVATION_UTIL.PrintLn('uom_code : '|| move_order_line_rec.uom_code);
 		GMI_RESERVATION_UTIL.PrintLn('secondary_uom : '|| move_order_line_rec.secondary_uom_code);
 		GMI_RESERVATION_UTIL.PrintLn('grade_code  : '|| move_order_line_rec.qc_grade);
 		GMI_RESERVATION_UTIL.PrintLn('secondary_quantity_delivered  : '|| move_order_line_rec.secondary_quantity_delivered);
 		GMI_RESERVATION_UTIL.PrintLn('secondary_quantity_detailed  : '|| move_order_line_rec.secondary_quantity_detailed);

 	           -- need to get sales_order_id from mtl_sales_orders for this order to populate field txn_source_id -- 5601081

 	           OPEN  get_sales_order_id (open_order_line_rec.header_id);
             FETCH get_sales_order_id INTO l_sales_order_id;
             CLOSE get_sales_order_id;
             GMI_RESERVATION_UTIL.PrintLn('l_sales_order_id : '|| l_sales_order_id);

             begin
              -- need to get delivery_detail_id  from wsh_delivery_details for this old ic MO in order to populate field txn_source_line_detail_id -- 5601081
             OPEN get_delivery_details(move_order_line_rec.line_id,open_order_line_rec.line_id);
 	           FETCH get_delivery_details INTO l_delivery_detail_id;
             CLOSE get_delivery_details;
 		         EXCEPTION
               WHEN OTHERS THEN

               GMI_RESERVATION_UTIL.PrintLn(' no data found for delivery details before create MO line so' );
               GMI_RESERVATION_UTIL.PrintLn('not erroring out here');
               NULL;

 	     end;

 	       GMI_RESERVATION_UTIL.PrintLn('l_delivery_detail_id : '|| l_delivery_detail_id);

               l_line_num := l_line_num + 1;
   	       --l_trolin_tbl(l_order_count).header_id        := l_trohdr_rec.header_id; --  5111050 commented out
   	       l_trolin_tbl(l_order_count).header_id          := l_mo_header_id;  --  5111050 5474923
   	       l_trolin_tbl(l_order_count).created_by         := FND_GLOBAL.USER_ID;
   	       l_trolin_tbl(l_order_count).creation_date      := sysdate;
   	       l_trolin_tbl(l_order_count).date_required      := sysdate;
   	       l_trolin_tbl(l_order_count).from_subinventory_code     := move_order_line_rec.from_subinventory_code;
               l_trolin_tbl(l_order_count).inventory_item_id  := move_order_line_rec.inventory_item_id;
               l_trolin_tbl(l_order_count).last_updated_by    := FND_GLOBAL.USER_ID;
   	       l_trolin_tbl(l_order_count).last_update_date   := sysdate;
               l_trolin_tbl(l_order_count).last_update_login  := FND_GLOBAL.LOGIN_ID;
   	       l_trolin_tbl(l_order_count).line_id            := FND_API.G_MISS_NUM;
   	       l_trolin_tbl(l_order_count).line_number        := l_line_num;
   	       l_trolin_tbl(l_order_count).line_status        := INV_Globals.G_TO_STATUS_PREAPPROVED;
   	       l_trolin_tbl(l_order_count).organization_id    := move_order_line_rec.organization_id; -- pal this needs to be right if suborg mapping
   	       l_trolin_tbl(l_order_count).quantity           := move_order_line_rec.quantity;
   	       l_trolin_tbl(l_order_count).quantity_delivered := 0; --move_order_line_rec.quantity_delivered; -- 5601081
   	       l_trolin_tbl(l_order_count).quantity_detailed  := 0; --move_order_line_rec.quantity_detailed; -- 5601081
   	       l_trolin_tbl(l_order_count).secondary_quantity := move_order_line_rec.secondary_quantity;
   	       l_trolin_tbl(l_order_count).secondary_quantity_delivered := 0; --move_order_line_rec.secondary_quantity_delivered; -- 5601081
   	       l_trolin_tbl(l_order_count).secondary_quantity_detailed := 0; -- move_order_line_rec.secondary_quantity_detailed; -- 5601081
   	       l_trolin_tbl(l_order_count).to_locator_id      := l_to_locator_id; -- 5601081

   	       l_trolin_tbl(l_order_count).status_date        := sysdate;
   	       l_trolin_tbl(l_order_count).to_subinventory_code   := move_order_line_rec.to_subinventory_code;
    	       l_trolin_tbl(l_order_count).uom_code           := move_order_line_rec.uom_code;
    	       l_trolin_tbl(l_order_count).secondary_uom      := move_order_line_rec.secondary_uom_code;

    	       l_trolin_tbl(l_order_count).transaction_type_id := move_order_line_rec.transaction_type_id; -- 5601081
    	       l_trolin_tbl(l_order_count).transaction_source_type_id :=  2; -- 5601081
    	       l_trolin_tbl(l_order_count).txn_source_line_id  :=  open_order_line_rec.line_id; --  5601081
    	       l_trolin_tbl(l_order_count).txn_source_id  :=  l_sales_order_id; --  5601081
    	       l_trolin_tbl(l_order_count).txn_source_line_detail_id  :=  l_delivery_detail_id; --  5601081

    	       l_trolin_tbl(l_order_count).grade_code         :=  move_order_line_rec.qc_grade; --  5703365

               l_trolin_tbl(l_order_count).db_flag            := FND_API.G_TRUE;
   	       l_trolin_tbl(l_order_count).operation          := INV_GLOBALS.G_OPR_CREATE;


	         fnd_msg_pub.initialize;
	         INV_Move_Order_PUB.Create_Move_Order_Lines (
								p_api_version_number       => 1.0 ,
	           	 	p_init_msg_list            => 'T',
	           	 	p_commit                   => FND_API.G_FALSE,
	           	 	x_return_status            => l_return_status,
	           	 	x_msg_count                => l_msg_count,
	           	 	x_msg_data                 => l_msg_data,
	           	 	p_trolin_tbl               => l_trolin_tbl,
	           	 	p_trolin_val_tbl           => l_trolin_val_tbl,
	           	 	x_trolin_tbl               => l_trolin_tbl,
	           	 	x_trolin_val_tbl           => l_trolin_val_tbl);

           IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     GMI_RESERVATION_UTIL.PrintLn(' Create_Move_Order_Lines failed ');
                     GMI_RESERVATION_UTIL.PrintLn(l_msg_data);
                     FND_MSG_PUB.Count_AND_GET (p_count => l_msg_count, p_data  => l_msg_data);
		     						 FOR i in 1..l_msg_count LOOP

													GMA_COMMON_LOGGING.gma_migration_central_log (
														p_run_id          => p_migration_run_id,
														p_log_level       => FND_LOG.LEVEL_ERROR,
														p_message_token   => 'GMI_UNEXPECTED_ERROR',
														p_table_name      => 'mtl_txn_request_lines',
														p_context         => 'Create_Move_Order_Lines',
														p_token1	  			=> 'ERROR',
														p_param1          => fnd_msg_pub.get_detail(i, NULL),
														p_param2          => NULL,
														p_param3          => NULL,
														p_param4          => NULL,
														p_param5          => NULL,
														p_db_error        => NULL,
														p_app_short_name  => 'GMI');
										 END LOOP;
								-- insert more comprehensive data into gma log table.

								 	   GMA_COMMON_LOGGING.gma_migration_central_log (
											p_run_id          => p_migration_run_id,
											p_log_level       => FND_LOG.LEVEL_ERROR,
											p_message_token   => 'INV_ERROR_CREATING_MO',
											p_table_name      => 'mtl_txn_request_lines',
											p_context         => 'Create_Move_Order_Lines',
											p_param1          => l_mo_header_id,
											p_param2          => move_order_line_rec.inventory_item_id,
											p_param3          => open_order_line_rec.line_id,
											p_param4          => NULL,
											p_param5          => NULL,
											p_db_error        => NULL,
											p_app_short_name  => 'INV');

	                    fnd_message.set_name('INV', 'INV_ERROR_CREATING_MO');
	                    fnd_msg_pub.ADD;
	                    RAISE fnd_api.g_exc_unexpected_error;
                 ELSE
                    GMI_RESERVATION_UTIL.PrintLn(' Create_move_order_lines succeeded   - line_id : '|| to_char(l_trolin_tbl(l_order_count).line_id));

                   /* Update OPM move order line attribute15 */

                 l_mo_line_id := l_trolin_tbl(l_order_count).line_id;

                 GMI_RESERVATION_UTIL.PrintLn(' before update of ic_txn_request_lines to attribute15 to line: '||to_char(l_mo_line_id));

                 UPDATE ic_txn_request_lines
                    SET attribute15 = to_char(l_trolin_tbl(l_order_count).line_id)
                  WHERE  line_id = move_order_line_rec.line_id;

                 GMI_RESERVATION_UTIL.PrintLn(' after update to ic_txn_request_lines to attribute15 to line: '||to_char(l_mo_line_id));

                    l_line_id := l_trolin_tbl(l_order_count).line_id;
                  --  5601081 rework
                  --  need to populate to_locator_id as Create_move_order_line API
									--  is not honoring to_locator_id input for MOL

                 UPDATE mtl_txn_request_lines
                    SET to_locator_id = l_to_locator_id
                  WHERE  line_id = l_line_id;
                 GMI_RESERVATION_UTIL.PrintLn(' newly created move_order_line :-' || l_line_id);
                 GMI_RESERVATION_UTIL.PrintLn(' locator_id updated to :- ' ||  l_to_locator_id);

                 END IF; -- IF l_return_status <> fnd_api.g_ret_sts_success THEN




               END IF;  -- IF(move_order_line_rec.attribute15 IS NOT NULL) THEN

              ELSE
                  /* do not create discrete move order as this item is non inventory item. */
                  NULL;
              END IF; -- IF l_opm_noninv_ind  = 0  THEN -- 5475003 rework 10/19

               /* UPDATE the WSH_DELIVERY_DETAILS with this new move order info */
                 GMI_RESERVATION_UTIL.PrintLn(' before update of wsh_delivery_detail for move order line id');

              -- need to incororate this into fix for non inv items and MOs

               FOR delivery_detail_rec IN get_delivery_details(move_order_line_rec.line_id,open_order_line_rec.line_id)
               LOOP
                  GMI_RESERVATION_UTIL.PrintLn(' in loop to update wsh_delivery_detail delivery_detail_rec.delivery_detail_id '||to_char(delivery_detail_rec.delivery_detail_id));
                  GMI_RESERVATION_UTIL.PrintLn(' in loop to update wsh_delivery_detail old ic_txn_request_lines line_id  '||to_char(move_order_line_rec.line_id));
                  GMI_RESERVATION_UTIL.PrintLn(' in loop to update wsh_delivery_detail open_order_line_rec.line_id '||to_char(open_order_line_rec.line_id));
                  GMI_RESERVATION_UTIL.PrintLn(' in loop to update wsh_delivery_detail l_opm_noninv_ind  '||to_char(l_opm_noninv_ind ));

                  --  if non_inv item need to set dd to staged 5475003
                  IF l_opm_noninv_ind  = 1 THEN  -- 5475003 rework - if here then this is non inventory item (as per OPM)
                  UPDATE wsh_delivery_details
                     SET released_status = 'Y', -- 5475003
                     picked_quantity = move_order_line_rec.quantity, -- 5475003
                     picked_quantity2 = move_order_line_rec.secondary_quantity       -- 5475003
                   WHERE delivery_detail_id = delivery_detail_rec.delivery_detail_id;

                  ELSE
                  UPDATE wsh_delivery_details
                     SET move_order_line_id  = l_mo_line_id
                    WHERE delivery_detail_id = delivery_detail_rec.delivery_detail_id;

                  END IF; --  IF l_opm_noninv_ind  = 1  THEN  -- 5475003


                  GMI_RESERVATION_UTIL.PrintLn(' in loop after update');

               END LOOP; /* FOR delivery_detail_rec IN get_delivery_details(move_order_line_rec.line_id,open_order_line_rec.line_id) */

            EXCEPTION
               WHEN OTHERS THEN

               GMI_RESERVATION_UTIL.PrintLn(' in When Others of move order loop :  sqlerrm '||sqlerrm);
               GMI_RESERVATION_UTIL.PrintLn(' NULL so not erroring out here in move order loop');

               NULL;

            END; /* Begin for Move Order Loop */


           END LOOP; /* FOR move_order_line_rec IN get_mo_line(open_order_line_rec.line_id) */


        EXCEPTION
            WHEN OTHERS THEN
            NULL;
        END; /* Begin for open_order_line_rec Loop */

      END LOOP;  /* FOR open_order_line_rec IN get_open_order_lines LOOP */

      GMI_RESERVATION_UTIL.println('END OF GML_OPM_OM_CONV_MIG_PKG.Migrate_opm_om_open_lines OM MIGRATION RUN ');

      /* End by logging a message that the migration has been succesful IF SO */

      if L_FAILURE_COUNT < 1  THEN
      gma_common_logging.gma_migration_central_log (
                  p_run_id      => p_migration_run_id
                , p_log_level   => FND_LOG.LEVEL_PROCEDURE
                , p_app_short_name => 'GML'
                , p_message_token  => 'GML_MIGRATION_TABLE_SUCCESS'
                , p_table_name  => NULL
                , p_context     => 'OPEN_ORDER_LINES'
                , p_param1      => l_success_count
                , p_param2      => l_failure_count );
      else

        gma_common_logging.gma_migration_central_log (
                  p_run_id      => p_migration_run_id
                , p_log_level   => FND_LOG.LEVEL_PROCEDURE
                , p_app_short_name => 'GML'
                , p_message_token  => 'GML_MIGRATION_TABLE_FAILURE'
                , p_table_name  => NULL
                , p_context     => 'OPEN_ORDER_LINES'
                , p_param1      => l_success_count
                , p_param2      => l_failure_count );
      end if; -- if L_FAILURE_COUNT < 1  THEN

       --Lets save the changes now based on the commit parameter
      IF p_commit = FND_API.G_TRUE THEN
        COMMIT;
      END IF;



EXCEPTION
  WHEN OTHERS THEN
      gma_common_logging.gma_migration_central_log (
        p_run_id        => p_migration_run_id
        , p_log_level   => FND_LOG.LEVEL_UNEXPECTED
        , p_app_short_name =>'GML'
        , p_message_token  => 'GML_MIGRATION_DB_ERROR'
        , p_db_error    => sqlerrm
        , p_table_name  => NULL
        , p_context     => 'OPEN_ORDER_LINES');

END Migrate_opm_om_open_lines;

END GML_OPM_OM_CONV_MIG_PKG;


/
