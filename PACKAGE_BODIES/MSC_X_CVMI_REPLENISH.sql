--------------------------------------------------------
--  DDL for Package Body MSC_X_CVMI_REPLENISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_CVMI_REPLENISH" AS
/* $Header: MSCXCFVB.pls 120.3.12010000.2 2009/10/01 10:54:12 sbnaik ship $ */

g_msc_cp_debug VARCHAR2(10) := NVL(FND_PROFILE.VALUE('MSC_CP_DEBUG'), '0');
  SUPPLIER_IS_OEM   number := 1;
  CUSTOMER_IS_OEM   number := 2;

PROCEDURE vmi_replenish_concurrent
  (
    p_replenish_time_fence IN NUMBER DEFAULT 1
    ) IS
      l_supplier_id NUMBER;
      l_supplier_site_id NUMBER;
      l_single_sourcing_flag BOOLEAN;
      l_reorder_point NUMBER;
      l_total_allocated_onhand NUMBER := 0;
      l_validate_supplier NUMBER := 0;
      l_full_lead_time NUMBER;
      l_plan_refresh_number NUMBER;
      l_sce_organization_id NUMBER;
      l_rep_transaction_id NUMBER;


      -- max refresh number from the last netting run
      l_last_max_refresh_number number := -1;
      -- max refresh number in sup_dem_entries currently
      l_curr_max_refresh_number number;
BEGIN

   print_user_info('Start of customer facing VMI engine');

   print_user_info('  Start of calcualte average daily demand');
   MSC_X_CVMI_PLANNING.calculate_average_demand;


   /* get refresh number info */
   -- l_curr_max_refresh_number is the max refresh number in
   -- sup_dem_entries currently

   select NVL(max(last_refresh_number), 0)
     into   l_curr_max_refresh_number
     from   msc_sup_dem_entries
     where  plan_id = -1;

   print_user_info('  Current maximum refresh number = ' || l_curr_max_refresh_number);


   begin


      -- l_last_max_refresh_number is the max refresh number from the
      -- last netting run

	select status
        into l_last_max_refresh_number
        from msc_plan_org_status
        where plan_id = -1
        and   organization_id = -1
        and   sr_instance_id = -1;
        exception
        when no_data_found then
        l_last_max_refresh_number := 0;

	insert into msc_plan_org_status (plan_id,
					  organization_id,
					  sr_instance_id,
					  status,
					  status_date,
					  number1)
	   				  values( CP_PLAN_ID,
		   				-1,
		   				-1,
		   				l_curr_max_refresh_number,
		   				sysdate,
           					 p_replenish_time_fence);




   end;


   BEGIN
	 -- get the next replenishment transaction id
          SELECT msc_sup_dem_entries_s.nextval
            INTO l_rep_transaction_id FROM DUAL;


	  vmi_replenish(l_last_max_refresh_number,
                        p_replenish_time_fence);

	  print_user_info('  Previous max refresh number = ' || l_last_max_refresh_number);
EXCEPTION
   WHEN OTHERS THEN
    print_debug_info('  Error when launch workflow process  = ' || sqlerrm);
   END;


    update  msc_plan_org_status
    set     status = l_curr_max_refresh_number,
            status_date = sysdate
            , number1 = p_replenish_time_fence
    where   plan_id = -1
    and     organization_id = -1
    and     sr_instance_id = -1;

  -- reset vmi refresh flag
  reset_vmi_refresh_flag;

    commit;

    print_user_info('End of customer facing VMI engine');
EXCEPTION
   WHEN OTHERS THEN
      print_debug_info('Error when running customer facing VMI engine = ' || sqlerrm);
      raise;
END vmi_replenish_concurrent;


PROCEDURE generate_replenishment(
l_item_id IN NUMBER,
l_cust_mod_org in number,
l_sr_instance_id IN NUMBER,
l_cust_id IN NUMBER,
l_cust_site_id IN NUMBER,
l_on_hand_qty IN NUMBER,
l_asn_qty IN NUMBER,
l_so_qty IN NUMBER,
l_int_req_qty IN NUMBER,
l_int_so_qty IN NUMBER,
l_repl_qty IN NUMBER,
l_consigned_flag in NUMBER,
l_min_qty in OUT NOCOPY NUMBER,
l_max_qty in OUT NOCOPY NUMBER,
l_min_days in NUMBER,
l_max_days in NUMBER,
l_fixed_order_qty in NUMBER,
l_average_daily_demand in NUMBER,
l_fixed_lot_multiplier in NUMBER,
l_rounding_control_type IN NUMBER,
l_repl_row_found IN NUMBER,
l_old_rep_transaction_id IN NUMBER,
l_oem_company_name in VARCHAR2,
l_customer_name IN VARCHAR2,
l_customer_site_name IN VARCHAR2,
l_item_name IN VARCHAR2,
l_item_description IN VARCHAR2,
l_uom_code IN VARCHAR2,
l_source_org_id IN NUMBER,
l_so_auth_flag IN NUMBER,
l_planner_code IN VARCHAR2, -- l_supplier_contact IN VARCHAR2,
-- l_customer_contact IN VARCHAR2,
l_repl_time_fence IN NUMBER,
l_time_fence_end_date IN DATE,
l_sr_inventory_item_id IN NUMBER,
l_aps_customer_id IN NUMBER,
l_aps_customer_site_id IN NUMBER) IS


l_total_supply NUMBER := 0;
l_supply_shortage NUMBER := 0;
l_order_quantity NUMBER := -1;
fixed_order_flag NUMBER := SYS_NO;
l_rep_transaction_id NUMBER;
l_old_wf_key VARCHAR2(300);
l_wf_status VARCHAR2(50);
l_wf_result VARCHAR2(50);

l_supplier_site_name  varchar2(10);

BEGIN


print_debug_info('  Start of procedure generate_replenishment');

	/* Include/Exclude the ASN flag if auto expire is set to Yes */




	/* Get the total supply which is available */

   print_debug_info('    onhand/ASN/SO/internal requisition/internal SO = '
            || l_on_hand_qty
		    || '/' || l_asn_qty
		    || '/' || l_so_qty
		    || '/' || l_int_req_qty
		    || '/' || l_int_so_qty
		    );

   print_debug_info('    l_average_daily_demand = '
            || l_average_daily_demand
		    );


	if(l_consigned_flag = UNCONSIGNED) then /* unconsigned case */

	   l_total_supply := l_on_hand_qty + l_asn_qty + l_so_qty;

	elsif (l_consigned_flag = CONSIGNED) then /* consigned case */

	   l_total_supply := l_on_hand_qty + l_asn_qty + l_int_req_qty
			     + l_int_so_qty;

	end if;

	if(l_min_qty <> -1) THEN /* min specified using qty */

	   l_supply_shortage := l_min_qty - l_total_supply;


	elsif (l_min_days <> -1)  THEN/* min specified using days */

	   l_supply_shortage := (l_min_days * l_average_daily_demand) -
				l_total_supply;

       l_min_qty := l_min_days * l_average_daily_demand;
       l_max_qty := l_max_days * l_average_daily_demand;

	end if;

   print_debug_info('    total supply/supply shortage = '
            || l_total_supply
		    || '/' || l_supply_shortage
		    );


	/* If there is a shortage apply order modifiers and generate
	   a replenishment */

	if(l_supply_shortage > 0) THEN


	   if(l_fixed_order_qty <> -1) THEN

		l_order_quantity := l_fixed_order_qty;
		fixed_order_flag := SYS_YES;
	   elsif

		(l_max_qty <> -1) THEN

			l_order_quantity := l_max_qty - l_total_supply;


	   	elsif (l_max_days <> -1) THEN

			l_order_quantity := (l_max_days
					* l_average_daily_demand) -
				    (l_total_supply);

	   END IF;


	   /* Add order modifiers for replenishments which were generated
	      using min max methods */

	      if(fixed_order_flag = SYS_NO) THEN

		/* SBALA :  To be added: Apply minimum order qty */

		if(l_fixed_lot_multiplier <> -1)  THEN

		     l_order_quantity := l_fixed_lot_multiplier
              		* CEIL(l_order_quantity/l_fixed_lot_multiplier);

		end if;

	      end if;

       -- check the rounding control flag
       IF ( l_rounding_control_type = 1) THEN

         l_order_quantity :=  CEIL(l_order_quantity);

       END IF;


   print_debug_info('    round control/fixed lot multiplier/ order quantity = '
            || l_rounding_control_type
            || '/' || l_fixed_lot_multiplier
            || '/' || l_order_quantity
		    );

	if(l_order_quantity  < 0) then

		l_order_quantity := 0;

	end if;


	/*----------------------------------------+
        | Get the new replenishment tranaction id |
	+-----------------------------------------*/

        SELECT msc_sup_dem_entries_s.nextval
        INTO l_rep_transaction_id FROM DUAL;


	if(l_repl_row_found = SYS_NO) then

		null;

   print_debug_info('    before insert replenishment record, transaction ID = '
            || l_rep_transaction_id
		    );

	INSERT INTO msc_sup_dem_entries
              (
                 transaction_id
               , plan_id
               , sr_instance_id
               , publisher_id
               , publisher_site_id
               , publisher_name
               , publisher_site_name
               , new_schedule_date
	       , key_date
               , inventory_item_id
               , publisher_order_type
	        , supplier_id
               , supplier_name
               , supplier_site_id
               , supplier_site_name
               , customer_id
               , customer_name
               , customer_site_id
               , customer_site_name
               , new_order_placement_date
               , item_name
	       , owner_item_name
               , customer_item_name
               , supplier_item_name
              , publisher_order_type_desc
              , request_id
              , program_id
              , program_application_id
	      , program_update_date
              , created_by
              , creation_date
              , last_updated_by
              , last_update_date
              , last_update_login
              , uom_code
              , quantity
              , primary_uom
              , primary_quantity
              , tp_uom_code
              , tp_quantity
              , pub_item_description
              , tp_item_description
              , release_status
              , receipt_date
              , quantity_in_process
              , implemented_quantity
              , item_description
              , customer_item_description
              , supplier_item_description
              , owner_item_description
	) VALUES
	(
	  l_rep_transaction_id,
	  CP_PLAN_ID,
	  l_sr_instance_id,
          OEM_COMPANY_ID,
	  -1,
          l_oem_company_name,
	  NULL,
	  sysdate,
	  sysdate,
	  l_item_id,
	  REPLENISHMENT,
	  OEM_COMPANY_ID,
	  l_oem_company_name,
	  NULL,
	  NULL,
	  l_cust_id,
	  l_customer_name,
	  l_cust_site_id,
	  l_customer_site_name,
	  SYSDATE,
	  l_item_name,
	  l_item_name,
	  NULL,
	  l_item_name,
	  msc_x_util.get_lookup_meaning('MSC_X_ORDER_TYPE', REPLENISHMENT),
	  FND_GLOBAL.CONC_REQUEST_ID,  -- request_id
          FND_GLOBAL.CONC_PROGRAM_ID,  -- program_id
          FND_GLOBAL.PROG_APPL_ID,  -- program_application_id
          null,  -- program_update_date
          FND_GLOBAL.USER_ID, -- created_by
          SYSDATE, -- creation_date
          FND_GLOBAL.USER_ID, -- last_updated_by
          SYSDATE, -- last_update_date
          FND_GLOBAL.LOGIN_ID, -- last_update_login
	  l_uom_code,
	  l_order_quantity,
	  l_uom_code,
	  l_order_quantity,
	  l_uom_code,
	  l_order_quantity,
	  l_item_description,
	  l_item_description,
	  UNRELEASED,
	  l_time_fence_end_date, -- Add receipt date
	  0,
	  0,
	  l_item_description,
	  NULL,
	  l_item_description,
	  l_item_description);


   print_debug_info('    number of replenishment record inserted = '
            || SQL%ROWCOUNT
		    );
        else
		/* repl exists, update */
        /* jguo added the following code to abort the previous Workflow
           process */
        -- find the WF key for the previous unclosed Workflow process
	    l_old_wf_key := TO_CHAR(l_item_id)
	    || '-' || TO_CHAR(OEM_COMPANY_ID)
	    || '-' || TO_CHAR(l_aps_customer_id)
	    || '-' || TO_CHAR(l_aps_customer_site_id)
	    || '-' || TO_CHAR(l_old_rep_transaction_id)
	    ;

	    print_debug_info('    old workflow key = ' || l_old_wf_key);

	    -- abort previous unclosed Workflow process for this item/org/supplier
            BEGIN
	       -- get the status of the previous open Workflow process
	       wf_engine.ItemStatus
		 ( itemtype => 'MSCXCFVR'
		   , itemkey  => l_old_wf_key
		   , status    => l_wf_status
		   , result   => l_wf_result
		   );

	       print_debug_info('    status of old workflow process = ' || l_wf_status);
	       IF (l_wf_status = 'ACTIVE') THEN
		  print_debug_info('    abort old workflow process');
		  wf_engine.AbortProcess
		    ( itemtype => 'MSCXCFVR'
		      , itemkey  => l_old_wf_key
		      );
	       END IF;

	    EXCEPTION
	       WHEN OTHERS THEN
		  print_debug_info('    Error when checking status or aborting old workfow process = ' || sqlerrm);
	    END;

   print_debug_info('    before update replenishment record, transaction ID = '
            || l_rep_transaction_id
		    );

	      /* update repl row */

	      UPDATE msc_sup_dem_entries sd
              SET
              transaction_id = l_rep_transaction_id
              , uom_code = l_uom_code
              , quantity = l_order_quantity
              , primary_uom = l_uom_code
              , primary_quantity = l_order_quantity
              , tp_uom_code = l_uom_code
              , tp_quantity = l_order_quantity
              , new_schedule_date = SYSDATE
	      , key_date = SYSDATE
	      , receipt_date = l_time_fence_end_date  --- SBALA
              , release_status = UNRELEASED
              , new_dock_date =  NULL   -- SBALA
              , publisher_name = l_oem_company_name
              , publisher_site_name = NULL
              , supplier_name = l_oem_company_name
              , supplier_site_name = NULL
              , quantity_in_process = 0
              , implemented_quantity = 0
              , last_updated_by = FND_GLOBAL.USER_ID
              , last_update_date = SYSDATE
              , last_update_login = FND_GLOBAL.LOGIN_ID
              , customer_id = l_cust_id
              , customer_name = l_customer_name
              , customer_site_id = l_cust_site_id
              , customer_site_name = l_customer_site_name
              , new_order_placement_date = SYSDATE
              , publisher_order_type_desc =
			msc_x_util.get_lookup_meaning('MSC_X_ORDER_TYPE',
							REPLENISHMENT)
              , pub_item_description = l_item_description
              , tp_item_description = l_item_description
              , item_description = l_item_description
              , customer_item_description = NULL
              , supplier_item_description = l_item_description
              , owner_item_description = l_item_description
	      WHERE transaction_id = l_old_rep_transaction_id
          AND sd.publisher_order_type = REPLENISHMENT
          ;

   print_debug_info('    number of replenishment record updated = '
            || SQL%ROWCOUNT
		    );

	end if;


	/* Add WF call JGUO */


    if (l_consigned_flag = CONSIGNED) then
        if (l_source_org_id <> NOT_EXISTS) and (l_source_org_id is not null) then
              select organization_code
	        into l_supplier_site_name
	        from msc_trading_partners
	       where partner_type = 3
		 and sr_instance_id = l_sr_instance_id
		 and sr_tp_id = l_source_org_id;
              print_debug_info('    Source Org:  '|| l_supplier_site_name);
        end if;
    end if;

		vmi_replenish_wf(l_rep_transaction_id,
				 l_item_id,
				 OEM_COMPANY_ID,
				 null, --- supplier_site_id
				 l_sr_instance_id,
				 l_aps_customer_id, ---- APS ID for customer
				 l_aps_customer_site_id, --- APS ID for customer site
				 l_min_qty,
				 l_max_qty,
				 l_min_days,
				 l_max_days,
				 l_so_auth_flag,
				 l_consigned_flag,
				 l_planner_code, -- l_supplier_contact,
				 -- l_customer_contact,
				 l_item_name, -- supplier item name
				 l_item_description, --- supplier item description
				 l_item_name, --- customer item name
				 l_item_description, -- customer item description
				 l_oem_company_name, --- Supplier name
				 l_supplier_site_name, 		--- Supplier Site Name
				 l_customer_name,
				 l_customer_site_name,
				 l_order_quantity,
				 l_on_hand_qty,
				 l_repl_time_fence,
				 l_time_fence_end_date,
				 l_uom_code,
				 l_source_org_id,
				 l_cust_mod_org,
				 1,
				 l_sr_inventory_item_id);

    else /* Supply shortage <= 0 */

	if(l_repl_row_found = SYS_YES) then /* repl exists, delete */

 print_debug_info('    before delete replenishment record = '
            || l_rep_transaction_id
		    );

	        DELETE FROM  msc_sup_dem_entries sd
		WHERE sd.publisher_id = OEM_COMPANY_ID
              	AND sd.inventory_item_id = l_item_id
              	AND sd.publisher_order_type = REPLENISHMENT
              	AND sd.plan_id = CP_PLAN_ID
              	AND sd.customer_site_id = l_cust_site_id
              	AND sd.customer_id = l_cust_id;

   print_debug_info('    number of replenishment record deleted = '
            || SQL%ROWCOUNT
		    );

	end if;

	END IF;



	commit;

	   print_debug_info('  End of procedure  generate_replenishment');

	END generate_replenishment;

	PROCEDURE set_no_data_items IS
	BEGIN

		null;

	END;


	PROCEDURE vmi_replenish(
	l_last_max_refresh_number IN NUMBER,
	l_repl_time_fence IN NUMBER)
	     IS
	       l_header_id VARCHAR2(200);
	       l_user_id NUMBER := -1;
	       l_return_code VARCHAR2(100);
	       l_err_buf VARCHAR2(100);
	       l_full_lead_time NUMBER;
	       l_supply_shortage NUMBER := 0;
	       l_order_quantity NUMBER := 0;
	       l_reorder_point NUMBER := 0;
	       l_economic_order_quantity NUMBER := 0;
	       l_fixed_order_quantity NUMBER;
	       l_fixed_lot_multiplier NUMBER := 0;
	       l_rounding_control_type NUMBER := 0;
	       l_minimum_order_quantity NUMBER := 0;
	       l_maxmum_order_quantity NUMBER := 0;
	       l_supply NUMBER := 0;
	       l_min_minmax_quantity NUMBER := 0;
	       l_max_minmax_quantity NUMBER := 0;
	       l_allocated_onhand_quantity NUMBER := 0;
	       l_asn_quantity NUMBER := 0;
	       l_requisition_quantity NUMBER:= 0;
	       l_po_quantity NUMBER:= 0;
	       l_replenishment_row NUMBER;
	       l_old_order_quantity NUMBER;
	       l_item_name VARCHAR2(100);
	       l_item_description VARCHAR2(200);
	       l_supplier_item_name VARCHAR2(100);
	       l_customer_uom_code VARCHAR2(10);
	       l_conv_found BOOLEAN := FALSE;
	       l_publisher_order_type_desc VARCHAR2(80);
	       l_shipment_receipt_quantity NUMBER;
	       l_wf_result VARCHAR2(50);
	       l_wf_status VARCHAR2(50);

	       l_min_minmax_days NUMBER;
	       l_max_minmax_days NUMBER;
	       l_average_daily_demand NUMBER;
	       l_vmi_refresh_flag NUMBER;
	       l_intransit_lead_time NUMBER;
	       l_source_site_id NUMBER := -1;
	       l_processing_lead_time NUMBER;

	       l_prev_item_id NUMBER := -1;
	       l_prev_org_id  NUMBER := -1;
	       l_prev_cust_id NUMBER := -1;
	       l_prev_cust_site_id NUMBER := -1;
	       l_prev_consigned_flag NUMBER := -1;
	       l_prev_min_qty NUMBER := -1;
	       l_prev_max_qty NUMBER := -1;
	       l_prev_min_days NUMBER := -1;
	       l_prev_max_days NUMBER := -1;
	       l_prev_fixed_order_qty NUMBER := -1;
	       l_prev_average_daily_demand NUMBER := 0;
	       l_prev_fixed_lot_mult NUMBER := -1;
	       l_prev_rnding_ctrl_ty NUMBER := -1;
           l_prev_sr_instance_id NUMBER := -1;
	       on_hand_qty NUMBER := 0;
	       asn_qty NUMBER := 0;
	       so_qty NUMBER := 0;
	       int_so_qty NUMBER := 0;
	       int_req_qty NUMBER := 0;
	       repl_qty NUMBER := 0;
	       repl_row_found NUMBER := SYS_NO;
           l_old_rep_transaction_id NUMBER := -1; -- jguo
	       l_prev_customer_name  VARCHAR2(1000) := NULL;
	       l_prev_customer_site_name VARCHAR2(40) := NULL;
	       l_prev_item_name VARCHAR2(250) := NULL;
	       l_prev_item_descr VARCHAR2(240) := NULL;
	       l_prev_uom_code VARCHAR2(3) := NULL;
       l_prev_primary_uom VARCHAR2(3) := NULL;
	       l_prev_receipt_date date;
	       l_curr_date DATE;
	       l_prev_asn_exp_flag NUMBER;
	       l_prev_source_org_id NUMBER;
	       l_prev_so_auth_flag NUMBER;
	       l_prev_planner_code VARCHAR2(100); -- l_prev_supplier_contact VARCHAR2(100);
	       -- l_prev_customer_contact VARCHAR2(100);
	       l_prev_sr_item_id NUMBER;
	       l_prev_aps_cust_id NUMBER;
	       l_prev_aps_cust_site_id NUMBER;
	       l_prev_full_lead_time NUMBER;
	       l_prev_preproc_lead_time NUMBER;
	       l_prev_postproc_lead_time NUMBER;
	       l_time_fence_end_date DATE;
	       l_prev_time_fence_end_date DATE;
           l_prev_transaction_id NUMBER := -1;
           l_prev_repl_row_found NUMBER  := SYS_NO;


	       t_item_id 		msc_x_cvmi_replenish.number_arr;
	       t_organization_id 		msc_x_cvmi_replenish.number_arr;
	       t_sr_instance_id		msc_x_cvmi_replenish.number_arr;
	       t_customer_id  		msc_x_cvmi_replenish.number_arr;
	       t_customer_site_id 	msc_x_cvmi_replenish.number_arr;
	       t_pub_order_type		msc_x_cvmi_replenish.number_arr;
	       t_alloc_oh_qty		msc_x_cvmi_replenish.number_arr;
	       t_unalloc_oh_qty		msc_x_cvmi_replenish.number_arr;
	       t_asn_qty		msc_x_cvmi_replenish.number_arr;
	       t_so_qty			msc_x_cvmi_replenish.number_arr;
	       t_int_so_qty		msc_x_cvmi_replenish.number_arr;
	       t_int_req_qty		msc_x_cvmi_replenish.number_arr;
	       t_repl_qty		msc_x_cvmi_replenish.number_arr;
	       t_consigned_flag		msc_x_cvmi_replenish.number_arr;
	       t_minimum_qty		msc_x_cvmi_replenish.number_arr;
	       t_maximum_qty		msc_x_cvmi_replenish.number_arr;
	       t_minimum_days		msc_x_cvmi_replenish.number_arr;
	       t_maximum_days		msc_x_cvmi_replenish.number_arr;
	       t_fixed_order_qty	msc_x_cvmi_replenish.number_arr;
	       t_average_daily_demand   msc_x_cvmi_replenish.number_arr;
	       t_fixed_lot_multiplier	msc_x_cvmi_replenish.number_arr;
	       t_rounding_control_type	msc_x_cvmi_replenish.number_arr;
	       t_order_num		ordernumList   := ordernumList();
	       t_release_num		releasenumList   := releasenumList();
	       t_line_num		linenumList	 := linenumList();
	       t_oem_company_name 	companynameList := companynameList();
	       t_customer_name		companynameList := companynameList();
	       t_customer_site_name	companysitenameList := companysitenameList();
	       t_item_name		itemnameList := itemnameList();
	       t_item_description	itemdescriptionList := itemdescriptionList();
	       t_uom_code 		uomcodeList := uomcodeList();
	       t_primary_uom 		uomcodeList := uomcodeList();
	       t_key_date		date_arr := date_arr();
	       t_receipt_date		date_arr := date_arr();
	       t_asn_exp_flag           msc_x_cvmi_replenish.number_arr;
	       t_source_org_id		msc_x_cvmi_replenish.number_arr;
	       t_so_auth_flag		msc_x_cvmi_replenish.number_arr;
           -- t_supplier_contact       suppliercontactList := suppliercontactList();
	       t_planner_code plannerCodeList := plannerCodeList();
	       -- t_customer_contact 	customercontactList := customercontactList();
	       t_sr_inventory_item_id   msc_x_cvmi_replenish.number_arr;
	       t_aps_customer_id        msc_x_cvmi_replenish.number_arr;
	       t_aps_customer_site_id   msc_x_cvmi_replenish.number_arr;
	       t_full_lead_time		msc_x_cvmi_replenish.number_arr;
	       t_preproc_lead_time 	msc_x_cvmi_replenish.number_arr;
	       t_postproc_lead_time	msc_x_cvmi_replenish.number_arr;
	       l_test  msc_x_cvmi_replenish.number_arr;
	       t_transaction_id		msc_x_cvmi_replenish.number_arr;

	       l_session_id     number;
	       l_return_status  VARCHAR2(1);
	       l_ship_method    varchar2(30);

	       lv_calendar_code    varchar2(14);
	       lv_instance_id      number;
	       lv_offset_days      number;

	       l_conv_rate NUMBER := 1;

	      CURSOR c_sup_dem_quantity(p_last_max_refresh_number NUMBER,
					p_repl_time_fence NUMBER) IS
	      SELECT
		    sup_dem.inventory_item_id,
		    msi.organization_id,
		    mtp.sr_instance_id,
		    nvl(sup_dem.customer_id, sup_dem.publisher_id),
		    nvl(sup_dem.customer_site_id, sup_dem.publisher_site_id),
		    sup_dem.publisher_order_type ,
		    sup_dem.transaction_id,
		    DECODE(sup_dem.publisher_order_type,
			   ALLOCATED_ONHAND, sup_dem.primary_quantity,
			   0),
		    DECODE(nvl(msi.consigned_flag, UNCONSIGNED),
			   UNCONSIGNED, DECODE(sup_dem.publisher_order_type,
					  UNALLOCATED_ONHAND, sup_dem.primary_quantity,
					  0),
			   0),
		    DECODE(sup_dem.publisher_order_type,
			   ASN, sup_dem.primary_quantity,
			   0),
		    DECODE(nvl(msi.consigned_flag, UNCONSIGNED),
			   UNCONSIGNED, DECODE(sup_dem.publisher_order_type,
					  SALES_ORDER,
					  DECODE(nvl(sup_dem.internal_flag, SYS_NO),
						SYS_NO, sup_dem.primary_quantity,
						0),
					  0),
			   0),
		    DECODE(nvl(msi.consigned_flag,UNCONSIGNED),
			   CONSIGNED, DECODE(sup_dem.publisher_order_type,
					  SALES_ORDER,
					  DECODE(sup_dem.internal_flag, SYS_YES,
						 sup_dem.primary_quantity,
						 0),
					  0),
			   0),
		    DECODE(nvl(msi.consigned_flag, UNCONSIGNED),
			   CONSIGNED, DECODE(sup_dem.publisher_order_type,
					  REQUISITION, DECODE(sup_dem.internal_flag,
						SYS_YES, DECODE(
							nvl(sup_dem.link_trans_id,
							    NOT_EXISTS),
							     NOT_EXISTS,
							     sup_dem.primary_quantity,
							     0),
						0),
					   0),
			    0),
		    DECODE(sup_dem.publisher_order_type,
			   REPLENISHMENT, sup_dem.primary_quantity,
			   0),
		    nvl(msi.consigned_flag, UNCONSIGNED),
		    nvl(msi.vmi_minimum_units, -1),
		    nvl(msi.vmi_maximum_units, -1),
		    nvl(msi.vmi_minimum_days, -1),
		    nvl(msi.vmi_maximum_days, -1),
		    nvl(msi.vmi_fixed_order_quantity, -1),
		    -- nvl(msi.average_daily_demand, 0),
		    nvl(mvt.average_daily_demand, 0),
		    nvl(msi.fixed_lot_multiplier, -1),
            nvl(msi.rounding_control_type, -1),
		    nvl(sup_dem.order_number, '-1'),
		    nvl(sup_dem.line_number, '-1'),
		    nvl(sup_dem.release_number, '-1'),
		    sup_dem.key_date,
		    nvl(sup_dem.receipt_date, sup_dem.key_date),
		    oem.company_name,
		    customer.company_name,
		    customer_site.company_site_name,
		    msi.item_name,
		    msi.description,
		    msi.uom_code,
        sup_dem.primary_uom,
		    nvl(msi.asn_autoexpire_flag, SYS_NO),
		    nvl(msi.source_org_id, NOT_EXISTS),
		    msi.so_authorization_flag,
		    msi.planner_code, -- mp.user_name,
		    -- mpc.name,
		    msi.sr_inventory_item_id,
		    mtp.modeled_customer_id,
		    mtp.modeled_customer_site_id,
		    nvl(msi.full_lead_time, 0),
		    nvl(msi.preprocessing_lead_time, 0),
		    nvl(msi.postprocessing_lead_time, 0),
		    1
	      FROM
		   -- msc_partner_contacts mpc,
		   -- msc_planners mp,
		   msc_companies customer,
		   msc_company_sites customer_site,
		   msc_companies oem,
		   msc_system_items msi,
		   msc_sup_dem_entries sup_dem,
		   msc_sup_dem_entries sd,
		   msc_trading_partners mtp,
		   msc_trading_partner_maps map1,
		   msc_trading_partner_maps map2,
		   msc_company_relationships mcr
		   , msc_vmi_temp mvt
		   WHERE
		   --    mpc.partner_type (+)= 2 ---Customer
		   -- AND mpc.sr_instance_id (+)= mtp.sr_instance_id
		   -- AND mpc.partner_site_id (+)= mtp.modeled_customer_site_id
		   -- AND mpc.partner_id (+)= mtp.modeled_customer_id
		   -- AND  mp.planner_code (+)= msi.planner_code
		   -- AND mp.organization_id (+)= msi.organization_id
		   -- AND mp.sr_instance_id (+)= msi.sr_instance_id
		       customer.company_id = customer_site.company_id
		   AND customer_site.company_site_id = map2.company_key
		   AND oem.company_id = mcr.subject_id
		   AND sup_dem.plan_id = sd.plan_id
		   AND sup_dem.inventory_item_id = sd.inventory_item_id
		   AND nvl(sup_dem.customer_id, sup_dem.publisher_id)
				= nvl(sd.customer_id, sd.publisher_id)
		   AND nvl(sup_dem.customer_site_id, sup_dem.publisher_site_id) =
				nvl(sd.customer_site_id,
					sd.publisher_site_id)
		   AND sup_dem.publisher_order_type in
					(UNALLOCATED_ONHAND, ALLOCATED_ONHAND,
					 SALES_ORDER, REQUISITION,
					 ASN,
					 REPLENISHMENT)
		   AND nvl(sup_dem.supplier_id, -1) = DECODE(
					       sup_dem.publisher_order_type,
					       UNALLOCATED_ONHAND, -1,
					       OEM_COMPANY_ID)
		   AND msi.inventory_planning_code = VMI_PLANNING_METHOD
		   AND msi.sr_instance_id = mtp.sr_instance_id
		   AND msi.organization_id = mtp.sr_tp_id
		   AND msi.inventory_item_id = sd.inventory_item_id
		   AND msi.plan_id = CP_PLAN_ID
		   AND mtp.partner_type = 3
		   AND map2.map_type = 3
		   AND map2.tp_key = mtp.modeled_customer_site_id
		   AND map1.map_type = 1
		   AND map1.tp_key = mtp.modeled_customer_id
		   AND map1.company_key = mcr.relationship_id
		   AND mcr.subject_id = OEM_COMPANY_ID
		   AND mcr.relationship_type = CUSTOMER_OF
		   AND nvl(sd.customer_id, -1) <> OEM_COMPANY_ID
		   --bug 8911098, performance issue. Changed Decode-NVL combo to AND-OR as it was leading to costlier path.
		   /*AND DECODE(sd.publisher_order_type, UNALLOCATED_ONHAND,
			      sd.publisher_site_id, sd.customer_site_id) =
							map2.company_key
		   AND DECODE(sd.publisher_order_type,
			      UNALLOCATED_ONHAND, sd.publisher_id,
			      sd.customer_id) = mcr.object_id
		   AND nvl(sd.supplier_id, -1) = DECODE(sd.publisher_order_type,
					       UNALLOCATED_ONHAND, -1,
					       OEM_COMPANY_ID)*/
		   AND ((sd.publisher_order_type = UNALLOCATED_ONHAND
		   		   AND sd.publisher_id = mcr.object_id
		   		   AND sd.publisher_site_id = map2.company_key
		   		   AND sd.supplier_id IS NULL)
		        OR
		        (sd.publisher_order_type <> UNALLOCATED_ONHAND
		   		   AND sd.customer_id = mcr.object_id
		   		   AND sd.customer_site_id = map2.company_key
		   		   AND sd.supplier_id = OEM_COMPANY_ID))
		   AND sd.publisher_order_type in
					(UNALLOCATED_ONHAND, ALLOCATED_ONHAND,
					 SALES_ORDER, REQUISITION,
					 ASN,
					 REPLENISHMENT)
		   AND sd.plan_id = CP_PLAN_ID
		   AND msi.vmi_refresh_flag in (REFRESHED, NOT_REFRESHED)
		   AND nvl(sd.last_refresh_number,-1) >  DECODE(msi.vmi_refresh_flag,
					NOT_REFRESHED,p_last_max_refresh_number,
					-99)
	      and mvt.plan_id = msi.plan_id
	      and mvt.inventory_item_id = msi.inventory_item_id
	      and mvt.organization_id = msi.organization_id
	      and mvt.sr_instance_id = msi.sr_instance_id
          and mvt.vmi_type = 2 -- customer facing vmi
		   UNION /* items with no data */
		   SELECT msi.inventory_item_id,
		          msi.organization_id,
			  msi.sr_instance_id,
			  mcr.object_id,
			  map2.company_key,
			  NOT_EXISTS, ---- no order type
			  0, -- transaction id
			  0, --- alloc on hand qty
			  0, --- unalloc on hand qty
			  0, --- ASN qty
			  0, --- Sales order qty
			  0, ---- int so qty
			  0, ---- int req qty
			  0, --- repl qty
			  nvl(msi.consigned_flag, UNCONSIGNED),
			  nvl(msi.vmi_minimum_units, -1),
			  nvl(msi.vmi_maximum_units, -1),
			  nvl(msi.vmi_minimum_days, -1),
			  nvl(msi.vmi_maximum_days, -1),
			  nvl(msi.vmi_fixed_order_quantity, -1),
			  -- nvl(msi.average_daily_demand, 0),
    		  nvl(mvt.average_daily_demand, 0),
			  nvl(msi.fixed_lot_multiplier, -1),
              NVL(msi.rounding_control_type, -1),
			  NULL, -- order number
			  NULL, -- line number
			  NULL, -- release number,
			  sysdate, --- key date
			  sysdate, ---- receipt date
			  oem.company_name,
			  customer.company_name,
			  customer_site.company_site_name,
			  msi.item_name,
			  msi.description,
			  msi.uom_code,
                  NULL, -- primary_uom
			  nvl(msi.asn_autoexpire_flag, SYS_NO),
			  nvl(msi.source_org_id, NOT_EXISTS),
			  msi.so_authorization_flag,
			  msi.planner_code, -- mp.user_name,
			  -- mpc.name,
			  msi.sr_inventory_item_id,
			  mtp.modeled_customer_id,
			  mtp.modeled_customer_site_id,
			  nvl(msi.full_lead_time, 0),
			  nvl(msi.preprocessing_lead_time, 0),
			  nvl(msi.postprocessing_lead_time, 0),
			  2
		  FROM
		   -- msc_partner_contacts mpc,
		   -- msc_planners mp,
		   msc_companies customer,
		   msc_company_sites customer_site,
		   msc_companies oem,
		   msc_system_items msi,
		   msc_trading_partners mtp,
		   msc_trading_partner_maps map1,
		   msc_trading_partner_maps map2,
		   msc_company_relationships mcr
		   , msc_vmi_temp mvt
		   WHERE
		   -- mpc.partner_type (+)= 2 ---Customer
		   -- AND mpc.sr_instance_id (+)= mtp.sr_instance_id
		   -- AND mpc.partner_site_id (+)= mtp.modeled_customer_site_id
		   -- AND mpc.partner_id (+)= mtp.modeled_customer_id
		   -- AND mp.planner_code (+)= msi.planner_code
		   -- AND mp.organization_id (+)= msi.organization_id
		   -- AND mp.sr_instance_id (+)= msi.sr_instance_id
		       customer.company_id = customer_site.company_id
		   AND customer_site.company_site_id = map2.company_key
		   AND oem.company_id = mcr.subject_id
		   AND map2.map_type = 3
		   AND map2.tp_key = mtp.modeled_customer_site_id
		   AND map1.map_type = 1
		   AND map1.company_key = mcr.relationship_id
		   AND mcr.subject_id = OEM_COMPANY_ID
		   AND mcr.relationship_type = CUSTOMER_OF
		   AND mtp.modeled_customer_id = map1.tp_key
		   AND mtp.modeled_customer_site_id is NOT NULL
		   AND mtp.modeled_customer_id is NOT NULL
		   AND mtp.partner_type = 3
		   AND msi.inventory_planning_code = VMI_PLANNING_METHOD
		   AND msi.sr_instance_id  = mtp.sr_instance_id
		   AND msi.organization_id = mtp.sr_tp_id
		   AND msi.plan_id = CP_PLAN_ID
		   AND 0 = (select count(*) from
			    msc_sup_dem_entries txns
			    where txns.inventory_item_id = msi.inventory_item_id
			    and   txns.plan_id = msi.plan_id
			    and   DECODE(txns.publisher_order_type,
					 UNALLOCATED_ONHAND, txns.publisher_id,
					 txns.customer_id) = mcr.object_id
			    and DECODE(txns.publisher_order_type,
					 UNALLOCATED_ONHAND, txns.publisher_site_id,
					 txns.customer_site_id) = map2.company_key
                AND txns.publisher_order_type IN
                   ( ALLOCATED_ONHAND
                   , UNALLOCATED_ONHAND
                   , REQUISITION
                   , ASN
                   , SALES_ORDER
                   , REPLENISHMENT
                   )
                )
	      and mvt.plan_id = msi.plan_id
	      and mvt.inventory_item_id = msi.inventory_item_id
	      and mvt.organization_id = msi.organization_id
	      and mvt.sr_instance_id = msi.sr_instance_id
          and mvt.vmi_type = 2 -- customer facing vmi
		   ORDER BY 1, 2, 3, 4, 5;

	BEGIN
	   print_user_info('    Start of calculating/creating replenishment');


	  select sysdate into l_curr_date from dual;


	  /*-------------------------------------------+
	  | Call procedure to set the vmi_refresh_flag |
	  | for items with no data.                    |
	  +--------------------------------------------*/

	  set_no_data_items;

	  ---dbms_output.put_line('OPENING_CURSOR');
	  ---dbms_output.put_line('Refresh number = ' || l_last_max_refresh_number);
	  OPEN c_sup_dem_quantity(l_last_max_refresh_number,
				  l_repl_time_fence);


	  ---dbms_output.put_line('FETCHING CURSOR');
	  FETCH c_sup_dem_quantity BULK COLLECT INTO
		t_item_id,
		t_organization_id,
		t_sr_instance_id,
		t_customer_id,
		t_customer_site_id,
		t_pub_order_type,
		t_transaction_id,
		t_alloc_oh_qty,
		t_unalloc_oh_qty,
		t_asn_qty,
		t_so_qty,
		t_int_so_qty,
		t_int_req_qty,
		t_repl_qty,
		t_consigned_flag,
		t_minimum_qty,
		t_maximum_qty,
		t_minimum_days,
		t_maximum_days,
		t_fixed_order_qty,
		t_average_daily_demand,
		t_fixed_lot_multiplier,
        t_rounding_control_type,
		t_order_num,
		t_release_num,
		t_line_num,
		t_key_date,
		t_receipt_date,
		t_oem_company_name,
		t_customer_name,
		t_customer_site_name,
		t_item_name,
		t_item_description,
		t_uom_code,
    t_primary_uom,
		t_asn_exp_flag,
		t_source_org_id,
		t_so_auth_flag,
		t_planner_code, -- t_supplier_contact,
		-- t_customer_contact,
		t_sr_inventory_item_id,
		t_aps_customer_id,
		t_aps_customer_site_id,
		t_full_lead_time,
		t_preproc_lead_time,
		t_postproc_lead_time,
		l_test;

        CLOSE c_sup_dem_quantity;

	  print_debug_info('    Number of transaction records fetched = ' || t_item_id.count);
	  IF(t_item_id.count > 0)  THEN

	  FOR j in 1..t_item_id.COUNT

	  LOOP

		/*-------------------------------------------------------+
		| Get the intransit lead time for shipping the material  |
		| from the shipping org to the customer location	 |
		+--------------------------------------------------------*/

		if((t_item_id(j) <> l_prev_item_id) OR
		   (t_customer_id(j) <> l_prev_cust_id) OR
		   (t_customer_site_id(j) <> l_prev_cust_site_id))  then

			l_intransit_lead_time := 0;



			if((t_consigned_flag(j) = UNCONSIGNED) AND
			   (t_source_org_id(j) <> NOT_EXISTS)) then

			   BEGIN  /* this sql statement to be removed once
				     lead time calc func can handle aps id's */

			   select maps.company_key
			   into l_source_site_id
			   from msc_trading_partner_maps maps,
				msc_trading_partners tp
			   where tp.partner_type = 3
			   and tp.sr_instance_id = t_sr_instance_id(j)
			   and tp.sr_tp_id = t_source_org_id(j)
			   and tp.partner_id = maps.tp_key
			   and maps.map_type = 2;
			   exception when others then null;


			   END;

			   l_intransit_lead_time :=
				MSC_X_UTIL.GET_CUSTOMER_TRANSIT_TIME(
						OEM_COMPANY_ID,
						l_source_site_id,
						t_customer_id(j),
						t_customer_site_id(j));

	  print_debug_info('    source site ID/in transit lead time = '
			  || l_source_site_id
			  || '/' || l_intransit_lead_time
			  );

               elsif ((t_consigned_flag(j) = CONSIGNED)
		  AND (t_source_org_id(j) <> NOT_EXISTS)) then

				   BEGIN
				       select mrp_atp_schedule_temp_s.nextval
				         into l_session_id
					 from dual;

					MSC_ATP_PROC.ATP_Intransit_LT(
						2,                       --- Destination
						l_session_id,            -- session_id
						t_source_org_id(j),      -- from_org_id
						null,                    -- from_loc_id
						null,                    -- from_vendor_site_id
						t_sr_instance_id(j),     -- p_from_instance_id
						t_organization_id(j),    -- p_to_org_id
						null,                    -- p_to_loc_id
						null,                    -- p_to_customer_site_id
						t_sr_instance_id(j),     -- p_to_instance_id
						l_ship_method,           -- p_ship_method
						l_intransit_lead_time,   -- x_intransit_lead_time
						l_return_status          -- x_return_status
					);

                                        if (l_intransit_lead_time is null) then
					     l_intransit_lead_time := 0;
					end if;

					print_debug_info(' in transit lead time = ' || l_intransit_lead_time);
				   EXCEPTION
				       when others then
					   print_user_info('Error in getting Lead Time: '||SQLERRM);

				   END;
		       END IF;

		end if;

			lv_offset_days := t_full_lead_time(j) +
					 t_preproc_lead_time(j) +
					 t_postproc_lead_time(j) +
					 l_intransit_lead_time;

                        begin

				/* Call the API to get the correct Calendar */
				msc_x_util.get_calendar_code(
					     1,                     --OEM
					     t_organization_id(j), -- customer modeled org
					     t_aps_customer_id(j),     --modeled customer
					     t_aps_customer_site_id(j), --modeled customer site id
					     lv_calendar_code,
					     lv_instance_id,
					     2,                        --- TP ids are in APS schema
					     t_sr_instance_id(j),
					     SUPPLIER_IS_OEM);

				print_debug_info(' Calendar/sr_instance_id : '
					      || lv_calendar_code||'/'||lv_instance_id);

				l_time_fence_end_date := MSC_CALENDAR.DATE_OFFSET(
							  lv_calendar_code -- arg_calendar_code IN varchar2,
							, lv_instance_id -- arg_instance_id IN NUMBER,
							, sysdate -- arg_date IN DATE,
							, lv_offset_days -- arg_offset IN NUMBER
							, 99999  --arg_offset_type
							);
			exception
				 when others then
				     print_user_info('Error occurred in getting the Calendar');
				     print_user_info(SQLERRM);

				     l_time_fence_end_date := sysdate + lv_offset_days;

			end;

	  print_debug_info('    time fence end date = '
			  || l_time_fence_end_date
			  );


		/* Determine the ASN quantity based on auto expire flag */
		if((t_pub_order_type(j) = ASN) AND (t_asn_exp_flag(j) = SYS_YES)) then

			if(t_receipt_date(j) < l_curr_date) then

				t_asn_qty(j) := 0;

			end if;

		end if;



		if(t_pub_order_type(j) = REPLENISHMENT) then

		  repl_row_found := SYS_YES; -- jguo
          l_old_rep_transaction_id := t_transaction_id(j);

		end if;


		if(((l_prev_item_id <> t_item_id(j)) OR
		   (l_prev_cust_id <> t_customer_id(j)) OR
		   (l_prev_cust_site_id <> t_customer_site_id(j))) AND
		   ((l_prev_item_id <> -1) AND
		    (l_prev_cust_id <> -1) AND
		    (l_prev_cust_site_id <> -1))) THEN

		    /* Call replenishment logic */


	  print_debug_info('    call replenishment logic api: generate_replenishment');
		    generate_replenishment(l_prev_item_id,
		    l_prev_org_id,
					   l_prev_sr_instance_id,
					   l_prev_cust_id,
					   l_prev_cust_site_id,
					   on_hand_qty,
					   asn_qty,
					   so_qty,
					   int_req_qty,
					   int_so_qty,
					   repl_qty,
					   l_prev_consigned_flag,
					   l_prev_min_qty,
					   l_prev_max_qty,
					   l_prev_min_days,
					   l_prev_max_days,
					   l_prev_fixed_order_qty,
					   l_prev_average_daily_demand,
					   l_prev_fixed_lot_mult,
                       l_prev_rnding_ctrl_ty,
					   l_prev_repl_row_found, -- jguo
                       l_prev_transaction_id,
					   t_oem_company_name(j),
					   l_prev_customer_name,
					   l_prev_customer_site_name,
					   l_prev_item_name,
					   l_prev_item_descr,
					   l_prev_uom_code,
					   l_prev_source_org_id,
					   l_prev_so_auth_flag,
					   l_prev_planner_code, -- l_prev_supplier_contact,
					   -- l_prev_customer_contact,
					   l_repl_time_fence,
					   l_prev_time_fence_end_date,
					   l_prev_sr_item_id,
					   l_prev_aps_cust_id,
					   l_prev_aps_cust_site_id);



	  print_debug_info('    reset supply quantities ...');
		    /* Reset supply quantities */
		    on_hand_qty := 0;
		    asn_qty := 0;
		    so_qty := 0;
		    int_so_qty := 0;
		    int_req_qty := 0;
		    repl_qty := 0;

		    l_prev_repl_row_found := SYS_NO;
            l_prev_transaction_id := -1;

		  end if;

		    /* Reset prev quantities */

	  print_debug_info('    reset provious quantities ...');
		    l_prev_item_id := t_item_id(j);
		    l_prev_org_id := t_organization_id(j);
		    l_prev_sr_instance_id := t_sr_instance_id(j);
		    l_prev_cust_id := t_customer_id(j);
		    l_prev_cust_site_id := t_customer_site_id(j);
		    l_prev_consigned_flag := t_consigned_flag(j);
		    l_prev_min_qty := t_minimum_qty(j);
		    l_prev_max_qty := t_maximum_qty(j);
		    l_prev_min_days := t_minimum_days(j);
		    l_prev_max_days := t_maximum_days(j);
		    l_prev_fixed_order_qty := t_fixed_order_qty(j);
		    l_prev_average_daily_demand := t_average_daily_demand(j);
		    l_prev_fixed_lot_mult := t_fixed_lot_multiplier(j);
		    l_prev_rnding_ctrl_ty := t_rounding_control_type(j);
		    l_prev_customer_name := t_customer_name(j);
		    l_prev_customer_site_name := t_customer_site_name(j);
		    l_prev_item_name := t_item_name(j);
		    l_prev_item_descr := t_item_description(j);
		    l_prev_uom_code := t_uom_code(j);
        l_prev_primary_uom := t_primary_uom(j);
		    l_prev_source_org_id := t_source_org_id(j);
		    l_prev_so_auth_flag := t_so_auth_flag(j);
		    -- l_prev_supplier_contact := t_supplier_contact(j);
		    l_prev_planner_code := t_planner_code(j);
		    -- l_prev_customer_contact := t_customer_contact(j);
		    l_prev_sr_item_id := t_sr_inventory_item_id(j);
		    l_prev_aps_cust_id := t_aps_customer_id(j);
		    l_prev_aps_cust_site_id := t_aps_customer_site_id(j);
		    l_prev_full_lead_time := t_full_lead_time(j);
		    l_prev_preproc_lead_time := t_preproc_lead_time(j);
		    l_prev_postproc_lead_time := t_postproc_lead_time(j);
		    l_prev_time_fence_end_date := l_time_fence_end_date;
            IF (repl_row_found = SYS_YES) THEN
              l_prev_repl_row_found := repl_row_found; -- jguo
              l_prev_transaction_id := l_old_rep_transaction_id;
              repl_row_found := SYS_NO;
              l_old_rep_transaction_id := -1;
            END IF;


		 /*-------------------------------------------------+
		 | Add the quantity to the correct supply bucket    |
		 | if it is the same item			    |
		 +--------------------------------------------------*/

	       l_conv_rate := 1;  --- initialize the conv rate

	       IF (t_uom_code(j) <> t_primary_uom(j)) THEN
		 MSC_X_UTIL.GET_UOM_CONVERSION_RATES( t_primary_uom(j)
						    , t_uom_code(j)
						    , t_item_id(j)
						    , l_conv_found
						    , l_conv_rate
						    );
		  print_debug_info('t_primary_uom/t_uom_code/l_conv_rate:'||t_primary_uom(j)
				      ||'/'||t_uom_code(j)||'/'||l_conv_rate);

	       END IF;

		 if(t_pub_order_type(j) = UNALLOCATED_ONHAND)  THEN

			 on_hand_qty 	:= round((on_hand_qty + t_unalloc_oh_qty(j)*l_conv_rate),6);

		 end if;

		if(t_pub_order_type(j) = ALLOCATED_ONHAND) THEN

			on_hand_qty := round((on_hand_qty + t_alloc_oh_qty(j)*l_conv_rate),6);

		end if;

		if((t_pub_order_type(j) = ASN)  AND
			(TRUNC(NVL(t_receipt_date(j), t_key_date(j))) <= TRUNC(l_time_fence_end_date))) THEN

			asn_qty := round((asn_qty + t_asn_qty(j)*l_conv_rate),6);

		end if;

		if((t_pub_order_type(j) = SALES_ORDER)  AND
			(t_consigned_flag(j) = UNCONSIGNED)  AND
			(TRUNC(NVL(t_receipt_date(j), t_key_date(j))) <= TRUNC(l_time_fence_end_date))) THEN

			so_qty := round((so_qty  + t_so_qty(j)*l_conv_rate),6);


		end if;


		if((t_pub_order_type(j) = SALES_ORDER) AND
			 (t_consigned_flag(j) = CONSIGNED) AND
			 (TRUNC(NVL(t_receipt_date(j), t_key_date(j))) <= TRUNC(l_time_fence_end_date))) THEN

			int_so_qty := round((int_so_qty + t_int_so_qty(j)*l_conv_rate),6);

		end if;

		if((t_pub_order_type(j) = REQUISITION) AND
		    (TRUNC(t_key_date(j)) <= TRUNC(l_time_fence_end_date))) THEN

			int_req_qty := round((int_req_qty + t_int_req_qty(j)*l_conv_rate),6);

		end if;

		if(t_pub_order_type(j) = REPLENISHMENT) THEN

			repl_qty := round((repl_qty + t_repl_qty(j)*l_conv_rate),6);

		end if;



		if(j = t_item_id.count) then


			if ((t_item_id(j) <> -1) AND
			    (t_customer_id(j) <> -1) AND
			    (t_customer_site_id(j) <> -1)) then


	  print_debug_info('    call replenishment logic api for last combination: generate_replenishment');
			   generate_replenishment(t_item_id(j),
					  t_organization_id(j),
					   t_sr_instance_id(j),
					   t_customer_id(j),
					   t_customer_site_id(j),
					   on_hand_qty,
					   asn_qty,
					   so_qty,
					   int_req_qty,
					   int_so_qty,
					   repl_qty,
					   t_consigned_flag(j),
					   t_minimum_qty(j),
					   t_maximum_qty(j),
					   t_minimum_days(j),
					   t_maximum_days(j),
					   t_fixed_order_qty(j),
					   t_average_daily_demand(j),
					   t_fixed_lot_multiplier(j),
                       t_rounding_control_type(j),
					   l_prev_repl_row_found,
                       l_prev_transaction_id,
					   t_oem_company_name(j),
					   t_customer_name(j),
					   t_customer_site_name(j),
					   t_item_name(j),
					   t_item_description(j),
					   t_uom_code(j),
					   t_source_org_id(j),
					   t_so_auth_flag(j),
					   t_planner_code(j), -- t_supplier_contact(j),
					   -- t_customer_contact(j),
					   l_repl_time_fence,
					   l_time_fence_end_date,
					   t_sr_inventory_item_id(j),
					   t_aps_customer_id(j),
					   t_aps_customer_site_id(j)
					);

			end if;

		end if;

	  END LOOP;

	  print_debug_info('  Out of main loop');

	  END IF;

	  print_debug_info('  End of procedure vmi_replenish');

	EXCEPTION
	   WHEN others THEN
	      print_user_info('  Error during replenish process = ' || sqlerrm);
	    /*   wf_core.context('MSC_X_CVMI_REPLENISH', 'vmi_replenish', itemtype, itemkey, actid, funcmode);
	      RAISE; */
	END vmi_replenish;

	  PROCEDURE vmi_reject
	  ( itemtype  in varchar2
	  , itemkey   in varchar2
	  , actid     in number
	  , funcmode  in varchar2
	  , resultout out nocopy varchar2
	  ) IS

	    l_rep_transaction_id NUMBER := wf_engine.GetItemAttrNumber
	    ( itemtype => itemtype
	    , itemkey  => itemkey
	    , aname    => 'REP_TRANSACTION_ID'
	    );

	  BEGIN
	print_debug_info('vmi_reject:000');
	  IF funcmode = 'RUN' THEN

	  print_debug_info('  Start of procedure vmi_reject');
	  -- change the release status of the replenishment record from
	  -- from UNRELEASED to REJECTED
	  UPDATE msc_sup_dem_entries sd
	  SET release_status = REJECTED
	  WHERE sd.transaction_id = l_rep_transaction_id
		    ;

	  print_debug_info('  End of procedure vmi_reject');

	    resultout := 'COMPLETE:vmi_reject_run';
	    RETURN;
	  END IF; -- if "RUN"
	  IF funcmode = 'CANCEL' THEN
	    resultout := 'COMPLETE:vmi_reject_cancel';
	    RETURN;
	  END IF;
	  IF funcmode = 'TIMEOUT' THEN
	    resultout := 'COMPLETE:vmi_timeout';
	    RETURN;
	  END IF;
	  EXCEPTION
	  WHEN OTHERS THEN
	    wf_core.context('MSC_X_REPLENISH', 'vmi_release', itemtype, itemkey, actid, funcmode);
	    RAISE;
	  END vmi_reject;

	PROCEDURE is_auto_release
	  (
	   itemtype  in varchar2
	   , itemkey   in varchar2
	   , actid     in number
	   , funcmode  in varchar2
	   , resultout out nocopy varchar2
	   ) IS


	      l_so_authorization_flag NUMBER :=
		wf_engine.GetItemAttrNumber
		( itemtype => itemtype
		  , itemkey  => itemkey
		  , aname    => 'SO_AUTHORIZATION_FLAG'
		  );



	 BEGIN
	   IF funcmode = 'RUN' THEN

	      IF (NVL(l_so_authorization_flag, -1) <> 1 AND NVL(l_so_authorization_flag, -1) <> 2) THEN
		 resultout := 'COMPLETE:Y';
	       ELSE
		 resultout := 'COMPLETE:N';
	      END IF;
	      RETURN;
	   END IF; -- if "RUN"

	   IF funcmode = 'CANCEL' THEN
	      resultout := 'COMPLETE:is_auto_release_cancel';
	      RETURN;
	   END IF;

	   IF funcmode = 'TIMEOUT' THEN
	      resultout := 'COMPLETE:is_auto_release_error';
	      RETURN;
	   END IF;

	EXCEPTION
	   WHEN OTHERS THEN
	      raise;
	END is_auto_release;

	PROCEDURE Is_Supplier_Approval
	  (
	   itemtype  in varchar2
	   , itemkey   in varchar2
	   , actid     in number
	   , funcmode  in varchar2
	   , resultout out nocopy varchar2
	   ) IS

	      l_so_authorization_flag NUMBER :=
		wf_engine.GetItemAttrNumber
		( itemtype => itemtype
		  , itemkey  => itemkey
		  , aname    => 'SO_AUTHORIZATION_FLAG'
		  );

	 BEGIN
	   IF funcmode = 'RUN' THEN

	      IF (l_so_authorization_flag = 2) THEN
		 resultout := 'COMPLETE:Y';
	       ELSE
		 resultout := 'COMPLETE:N';
	      END IF;
	      RETURN;
	   END IF; -- if "RUN"

	   IF funcmode = 'CANCEL' THEN
	      resultout := 'COMPLETE:is_auto_release_cancel';
	      RETURN;
	   END IF;

	   IF funcmode = 'TIMEOUT' THEN
	      resultout := 'COMPLETE:is_auto_release_error';
	      RETURN;
	   END IF;

	EXCEPTION
	   WHEN OTHERS THEN
	      raise;
	END Is_Supplier_Approval;

	PROCEDURE vmi_release_api
	  (   p_inventory_item_id IN NUMBER
	    , p_sr_instance_id IN NUMBER
	    , p_supplier_id IN NUMBER
	    , p_supplier_site_id IN NUMBER
	    , p_customer_id IN NUMBER
	    , p_customer_site_id IN NUMBER
	    , p_release_quantity IN NUMBER
	    , p_uom IN VARCHAR2
	    , p_sr_inventory_item_id IN NUMBER
	    , p_customer_model_org_id IN NUMBER
	    , p_source_org_id IN NUMBER
	    , p_request_date IN DATE
	    , p_consigned_flag IN NUMBER
	    , p_vmi_release_type IN NUMBER
        , p_item_name VARCHAR2
        , p_item_describtion VARCHAR2
        , p_customer_name VARCHAR2
        , p_customer_site_name VARCHAR2
        , p_uom_code VARCHAR2
		, p_vmi_minimum_units IN OUT NOCOPY NUMBER
		, p_vmi_maximum_units IN OUT NOCOPY NUMBER
		, p_vmi_minimum_days NUMBER
		, p_vmi_maximum_days NUMBER
		, p_average_daily_demand NUMBER
		, p_ORDER_NUMBER  IN VARCHAR2
		, p_RELEASE_NUMBER IN VARCHAR2
		, p_LINE_NUMBER  IN VARCHAR2
		, p_END_ORDER_NUMBER  IN VARCHAR2
		, p_END_ORDER_REL_NUMBER  IN VARCHAR2
		, p_END_ORDER_LINE_NUMBER  IN VARCHAR2
		, p_source_org_name  IN VARCHAR2
		, p_order_type IN VARCHAR2
	    ) IS
	       l_wf_type VARCHAR2(50);
	       l_wf_key VARCHAR2(200);
	       l_wf_process VARCHAR2(50);
	       l_status VARCHAR2(100);
	       l_rep_transaction_id NUMBER;
           l_supplier_contact VARCHAR2(200);
	  BEGIN

	   print_debug_info('  item/sr instance = '
			    || p_inventory_item_id
			    || '/' || p_sr_instance_id
			    );
	   print_debug_info('  supplier/supplier site/customer/customer site = '
		    || p_supplier_id
			    || '/' || p_supplier_site_id
			    || '/' || p_customer_id
			    || '/' || p_customer_site_id
			    );

	   print_user_info('  release quantity/uom/sr item/customer modeled org = '
		    || p_release_quantity
			    || '/' || p_uom
			    || '/' || p_sr_inventory_item_id
			    || '/' || p_customer_model_org_id
			    );

	   print_user_info('  source org/request date/consigned flag/vmi release type = '
		    || p_source_org_id
			    || '/' || p_request_date
			    || '/' || p_consigned_flag
			    || '/' || p_vmi_release_type
			    );

		  SELECT msc_sup_dem_entries_s.nextval
		    INTO l_rep_transaction_id FROM DUAL;
		  -- use item id, supplier id, customer id, customer site id, replenishment
		  -- transaction id to compose a Workflow key, this Workflow key will be used
		  -- by UI code to release the replenishment
		  l_wf_key := TO_CHAR(p_inventory_item_id)
		    || '-' || TO_CHAR(p_supplier_id)
		    || '-' || TO_CHAR(p_customer_id)
		    || '-' || TO_CHAR(p_customer_site_id)
		    || '-' || TO_CHAR(l_rep_transaction_id)
		    ;
		  print_debug_info('    new workflow key = ' || l_wf_key);

	      l_wf_type := 'MSCXCFVR';
		  l_wf_process := 'CUST_FACING_VMI_RELEASE';

		  -- create a Workflow process for the (item/org/supplier)
		  wf_engine.CreateProcess
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , process  => l_wf_process
		      );

		  wf_engine.SetItemAttrNumber
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'INVENTORY_ITEM_ID'
		      , avalue   => p_inventory_item_id
		      );

		  wf_engine.SetItemAttrNumber
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'SR_INSTANCE_ID'
		      , avalue   => p_sr_instance_id
		      );

		  wf_engine.SetItemAttrNumber
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'SUPPLIER_ID'
		      , avalue   => p_supplier_id
		      );

		  wf_engine.SetItemAttrNumber
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'SUPPLIER_SITE_ID'
		      , avalue   => p_supplier_site_id
		      );

		  wf_engine.SetItemAttrNumber
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'CUSTOMER_ID'
		      , avalue   => p_customer_id
		      );

		  wf_engine.SetItemAttrNumber
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'CUSTOMER_SITE_ID'
		      , avalue   => p_customer_site_id
		      );

        IF (p_release_quantity <> -1) THEN
		  wf_engine.SetItemAttrNumber
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'RELEASE_QUANTITY'
		      , avalue   => p_release_quantity
		      );
        END IF;

		  wf_engine.SetItemAttrText
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'UOM_CODE'
		      , avalue   => p_uom
		      );

		  wf_engine.SetItemAttrNumber
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'SR_INVENTORY_ITEM_ID'
		      , avalue   => p_sr_inventory_item_id
		 );
		  wf_engine.SetItemAttrNumber
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'CUSTOMER_ORG_ID'
		      , avalue   => p_customer_model_org_id
		      );

		  wf_engine.SetItemAttrNumber
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'SOURCE_ORG_ID'
		      , avalue   => p_source_org_id
		      );

		  wf_engine.SetItemAttrDate
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'REQUEST_DATE'
		      , avalue   => p_request_date
		      );

		  wf_engine.SetItemAttrDate
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'TIME_FENCE_END_DATE'
		      , avalue   => p_request_date
		      );

		  wf_engine.SetItemAttrNumber
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'CONSIGNED_FLAG'
		      , avalue   => p_consigned_flag
		      );

		  wf_engine.SetItemAttrNumber
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      , aname    => 'VMI_RELEASE_TYPE'
		      , avalue   => p_vmi_release_type
		      );

       BEGIN
		   SELECT mp.user_name
           INTO l_supplier_contact
	       FROM msc_planners mp
	       , msc_system_items msi
	       WHERE msi.plan_id = -1 -- p_plan_id
	       AND msi.organization_id = p_customer_model_org_id
	       AND msi.inventory_item_id = p_inventory_item_id
	       AND msi.sr_instance_id = p_sr_instance_id
	       AND mp.sr_instance_id = msi.sr_instance_id
	       AND mp.organization_id = msi.organization_id
	       AND mp.planner_code = msi.planner_code
           ;
	   print_user_info('  item planner contact name = ' || l_supplier_contact);

    	  wf_engine.SetItemAttrText
	      ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SUPPLIER_CONTACT'
	      , avalue   => l_supplier_contact
	      );

	   IF (p_vmi_minimum_days <> -1)  THEN/* min specified using days */
         p_vmi_minimum_units := p_vmi_minimum_days * p_average_daily_demand;
         p_vmi_maximum_units := p_vmi_maximum_days * p_average_daily_demand;
       END IF;

    IF (p_vmi_minimum_units <> -1) THEN
	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'MINIMUM_QUANTITY'
	      , avalue   => p_vmi_minimum_units
	      );
     END IF;

    IF (p_vmi_maximum_units <> -1) THEN
	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'MAXIMUM_QUANTITY'
	      , avalue   => p_vmi_maximum_units
	      );
    END IF;

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SUPPLIER_ITEM_NAME'
	      , avalue   => p_item_name
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SUPPLIER_ITEM_DESCRIPTION'
	      , avalue   => p_item_describtion
          );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'CUSTOMER_NAME'
	      , avalue   => p_customer_name
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'CUSTOMER_SITE_NAME'
	      , avalue   => p_customer_site_name
	      );

       /* Consigned CVMI Enh : Bug # 4247230. SET  attributes of the WorkFlow for [ Order Number or Line Number
	    or Release Number or End Order Number or End Order Line Number or End Order Release Number  */

   print_debug_info(' p_ORDER_NUMBER = '||p_ORDER_NUMBER||' / p_RELEASE_NUMBER = '||p_RELEASE_NUMBER
    ||' / p_LINE_NUMBER = '||p_LINE_NUMBER);

   print_debug_info(' p_END_ORDER_NUMBER = '||p_END_ORDER_NUMBER||' / p_END_ORDER_REL_NUMBER = '||
     p_END_ORDER_REL_NUMBER||' / p_END_ORDER_LINE_NUMBER = '||p_END_ORDER_LINE_NUMBER);

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'ORDER_NUMBER'
	      , avalue   => p_ORDER_NUMBER
	      );

	wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'RELEASE_NUMBER'
	      , avalue   => p_RELEASE_NUMBER
	      );

	wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'LINE_NUMBER'
	      , avalue   => p_LINE_NUMBER
	      );

	wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'END_ORDER_NUMBER'
	      , avalue   => p_END_ORDER_NUMBER
	      );

	wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'END_ORDER_REL_NUMBER'
	      , avalue   => p_END_ORDER_REL_NUMBER
	      );

	wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'END_ORDER_LINE_NUMBER'
	      , avalue   => p_END_ORDER_LINE_NUMBER
	      );

       print_debug_info('Consigned_flag = '||p_consigned_flag||' /Source_org_name = '|| p_source_org_name
       ||' /Release_quantity = '||p_release_quantity);

                wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SHIP_FROM_ORG_NAME'
	      , avalue   => p_source_org_name
	      );

	     wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'ORDER_TYPE'
	      , avalue   => p_order_type
	      );

       EXCEPTION
         WHEN OTHERS THEN
  	       print_user_info('  Item Planner Contact Name not found, please set it up.');
           -- RAISE;
       END;

		  -- start Workflow process for item/org/supplier
		  print_debug_info('    start workflow process');
		  wf_engine.StartProcess
		    ( itemtype => l_wf_type
		      , itemkey  => l_wf_key
		      );
	    print_user_info('    end of workflow process');

	EXCEPTION
	   WHEN OTHERS THEN
	      print_debug_info('  Error when starting vmi workflow process= ' || sqlerrm);
	      RAISE;
	END vmi_release_api;

	PROCEDURE vmi_release_api_ui
	  ( p_rep_transaction_id IN NUMBER
	  , p_release_quantity IN NUMBER
	  ) IS
	       l_wf_type VARCHAR2(50);
	       l_wf_key VARCHAR2(200);
	       l_wf_process VARCHAR2(50);
	       l_status VARCHAR2(100);

	       l_inventory_item_id NUMBER;
	       l_sr_instance_id NUMBER;
	       l_customer_id NUMBER;
	       l_customer_site_id NUMBER;
	       l_uom VARCHAR2(10);
	       l_sr_inventory_item_id NUMBER;
	       l_customer_org_id NUMBER;
	       l_source_org_id NUMBER;
	       l_request_date DATE;
	       l_consigned_flag NUMBER;
           l_item_name VARCHAR2(200);
           l_item_describtion VARCHAR2(200);
           l_customer_name VARCHAR2(200);
           l_customer_site_name VARCHAR2(200);
           l_uom_code VARCHAR2(20);
		   l_vmi_minimum_units NUMBER;
		   l_vmi_maximum_units NUMBER;
		   l_vmi_minimum_days NUMBER;
		   l_vmi_maximum_days NUMBER;
		   l_average_daily_demand NUMBER;
		   l_source_org_name VARCHAR2(50);

	    CURSOR c_release_attributes
	    ( p_rep_transaction_id IN NUMBER
	    ) IS
	      SELECT
		sd.inventory_item_id
		  , mtp.sr_instance_id
		  , mtp.modeled_customer_id
		  , mtp.modeled_customer_site_id
		  , msi.uom_code
		  , msi.sr_inventory_item_id
	      , msi.organization_id
	      , msi.source_org_id
	      , sd.receipt_date
	      , msi.consigned_flag
          , msi.item_name
          , msi.description
          , sd.customer_name
          , sd.customer_site_name
          , msi.uom_code
		  , nvl(msi.vmi_minimum_units, -1)
		  , nvl(msi.vmi_maximum_units, -1)
		  , nvl(msi.vmi_minimum_days, -1)
		  , nvl(msi.vmi_maximum_days, -1)
		  , nvl(mvt.average_daily_demand, 0)
		  , mtp.partner_name
	      FROM
		   msc_system_items msi,
	       msc_sup_dem_entries sd,
		   msc_trading_partners mtp,
		   msc_trading_partner_maps map1,
		   msc_trading_partner_maps map2,
	       msc_company_relationships mcr
	       , msc_vmi_temp mvt
		   WHERE
		       msi.inventory_planning_code = VMI_PLANNING_METHOD
		   AND msi.sr_instance_id = mtp.sr_instance_id
		   AND msi.organization_id = mtp.sr_tp_id
		   AND msi.inventory_item_id = sd.inventory_item_id
	       AND msi.plan_id = sd.plan_id
		   AND mtp.partner_type = 3
		   AND map2.map_type = 3
		   AND map2.tp_key = mtp.modeled_customer_site_id
		   AND map1.map_type = 1
	       AND map1.tp_key = mtp.modeled_customer_id
	       AND map1.company_key = mcr.relationship_id
		   AND mcr.subject_id = OEM_COMPANY_ID
	       AND mcr.relationship_type = CUSTOMER_OF
	       AND sd.customer_site_id = map2.company_key
	       AND sd.customer_id = mcr.object_id
		   AND sd.transaction_id = p_rep_transaction_id
	       AND sd.sr_instance_id = msi.sr_instance_id
	      and mvt.plan_id = msi.plan_id
	      and mvt.inventory_item_id = msi.inventory_item_id
	      and mvt.organization_id = msi.organization_id
	      and mvt.sr_instance_id = msi.sr_instance_id
          and mvt.vmi_type = 2 -- customer facing vmi
	       ;
	  BEGIN

	   print_debug_info('  replenishment transactioin ID = '
			    || p_rep_transaction_id
			    );

	   OPEN c_release_attributes
	   ( p_rep_transaction_id
	   );
	   FETCH c_release_attributes
	   INTO
		l_inventory_item_id
		  , l_sr_instance_id
		  , l_customer_id
		  , l_customer_site_id
		  , l_uom
		  , l_sr_inventory_item_id
	      , l_customer_org_id
	      , l_source_org_id
	      , l_request_date
	      , l_consigned_flag
          , l_item_name
          , l_item_describtion
          , l_customer_name
          , l_customer_site_name
          , l_uom_code
		  , l_vmi_minimum_units
		  , l_vmi_maximum_units
		  , l_vmi_minimum_days
		  , l_vmi_maximum_days
		  , l_average_daily_demand
		  , l_source_org_name
	      ;

	   IF (c_release_attributes%ROWCOUNT < 1) THEN
	     print_debug_info('  Replenishmente record not found in CP. Can not release.');
	   END IF;
	   CLOSE c_release_attributes;

	   print_debug_info('  customer/customer site = '
			    || l_customer_id
			    || '/' || l_customer_site_id
			    );

	   print_user_info('  release quantity/uom/sr item/customer modeled org = '
		    || p_release_quantity
			    || '/' || l_uom
			    || '/' || l_sr_inventory_item_id
			    || '/' || l_customer_org_id
			    );

	   print_user_info('  source org/request date/consigned flag/vmi release type = '
		    || l_source_org_id
			    || '/' || l_request_date
			    || '/' || l_consigned_flag
			    );

   print_debug_info('    l_average_daily_demand = '
            || l_average_daily_demand||'  source_org_name = '||l_source_org_name
		    );

	  vmi_release_api
	  (   l_inventory_item_id -- IN NUMBER
	    , l_sr_instance_id -- IN NUMBER
	    , OEM_COMPANY_ID -- l_supplier_id -- IN NUMBER
	    , NULL -- l_supplier_site_id -- IN NUMBER
	    , l_customer_id -- IN NUMBER
	    , l_customer_site_id -- IN NUMBER
	    , p_release_quantity -- IN NUMBER
	    , l_uom -- IN VARCHAR2
	    , l_sr_inventory_item_id -- IN NUMBER
	    , l_customer_org_id -- IN NUMBER
	    , l_source_org_id -- IN NUMBER
	    , l_request_date -- IN DATE
	    , l_consigned_flag -- IN NUMBER
	    , 1 --l_vmi_release_type -- IN NUMBER
          , l_item_name
          , l_item_describtion
          , l_customer_name
          , l_customer_site_name
          , l_uom_code
		  , l_vmi_minimum_units
		  , l_vmi_maximum_units
		  , l_vmi_minimum_days
		  , l_vmi_maximum_days
		  , l_average_daily_demand
		  , NULL , NULL , NULL , NULL, NULL, NULL  --Consigned CVMI Enh : Bug # 4247230
		  ,l_source_org_name
		  , 'Replenishment'
	    );

	EXCEPTION
	   WHEN OTHERS THEN
	      print_debug_info('  Error when starting vmi workflow process= ' || sqlerrm);
	      RAISE;
	END vmi_release_api_ui;

	PROCEDURE vmi_release_api_load
	  ( p_header_id IN NUMBER
	  ) IS
	       l_wf_type VARCHAR2(50);
	       l_wf_key VARCHAR2(200);
	       l_wf_process VARCHAR2(50);
	       l_status VARCHAR2(100);

	       l_inventory_item_id NUMBER;
       l_sr_instance_id NUMBER;
       l_customer_id NUMBER;
       l_customer_site_id NUMBER;
       l_uom VARCHAR2(10);
       l_sr_inventory_item_id NUMBER;
       l_customer_org_id NUMBER;
       l_source_org_id NUMBER;
       l_request_date DATE;
       l_consigned_flag NUMBER;
       l_release_quantity NUMBER;
           l_item_name VARCHAR2(200);
           l_item_describtion VARCHAR2(200);
           l_customer_name VARCHAR2(200);
           l_customer_site_name VARCHAR2(200);
           l_uom_code VARCHAR2(20);
		   l_vmi_minimum_units NUMBER;
		   l_vmi_maximum_units NUMBER;
		   l_vmi_minimum_days NUMBER;
		   l_vmi_maximum_days NUMBER;
		   l_average_daily_demand NUMBER;
		   l_ORDER_NUMBER VARCHAR2(240);
	 l_RELEASE_NUMBER VARCHAR2(20);
	 l_LINE_NUMBER  VARCHAR2(20);
	 l_END_ORDER_NUMBER  VARCHAR2(240);
	 l_END_ORDER_REL_NUMBER  VARCHAR2(20);
	 l_END_ORDER_LINE_NUMBER  VARCHAR2(20);
	 l_ship_from_org_name VARCHAR2(50);
	 l_order_type VARCHAR2(50);

    CURSOR c_release_attributes
    ( p_header_id IN NUMBER
    ) IS
      SELECT
        sd.inventory_item_id
	  , mtp.sr_instance_id
	  , mtp.modeled_customer_id
	  , mtp.modeled_customer_site_id
	  , msi.uom_code
	  , msi.sr_inventory_item_id
      , msi.organization_id
      , msi.source_org_id
      , sd.key_date
      , msi.consigned_flag
      , sd.primary_quantity
          , msi.item_name
          , msi.description
         -- , sd.customer_name
         -- , sd.customer_site_name
	 , sd.publisher_name
	    , sd.publisher_site_name
          , msi.uom_code
		  , nvl(msi.vmi_minimum_units, -1)
		  , nvl(msi.vmi_maximum_units, -1)
		  , nvl(msi.vmi_minimum_days, -1)
		  , nvl(msi.vmi_maximum_days, -1)
		  , nvl(mvt.average_daily_demand, 0)
		  , sd.ORDER_NUMBER           --Consigned CVMI Enh
		  , sd.RELEASE_NUMBER
		  , sd.LINE_NUMBER
		  , sd.END_ORDER_NUMBER
		  , sd.END_ORDER_REL_NUMBER
		  , sd.END_ORDER_LINE_NUMBER
		  , mtp.partner_name
		  , sd.publisher_order_type_desc

      FROM
	   msc_system_items msi,
       msc_sup_dem_entries sd,
	   msc_trading_partners mtp,
	   msc_trading_partner_maps map1,
	   msc_trading_partner_maps map2,
       msc_company_relationships mcr
       , msc_vmi_temp mvt
       WHERE
	       msi.inventory_planning_code = VMI_PLANNING_METHOD
	   AND msi.sr_instance_id = mtp.sr_instance_id
	   AND msi.organization_id = mtp.sr_tp_id
	   AND msi.inventory_item_id = sd.inventory_item_id
       AND msi.plan_id = sd.plan_id
	   AND mtp.partner_type = 3
	   AND map2.map_type = 3
	   AND map2.tp_key = mtp.modeled_customer_site_id
	   AND map1.map_type = 1
       AND map1.tp_key = mtp.modeled_customer_id
       AND map1.company_key = mcr.relationship_id
	   AND mcr.subject_id = OEM_COMPANY_ID
       AND mcr.relationship_type = CUSTOMER_OF
       AND sd.publisher_site_id = map2.company_key
       AND sd.publisher_id = mcr.object_id
	   AND sd.ref_header_id = p_header_id
       -- AND sd.sr_instance_id = msi.sr_instance_id
       AND sd.publisher_order_type = CONSUMPTION_ADVICE
       AND sd.primary_quantity > 0
	      and mvt.plan_id = msi.plan_id
	      and mvt.inventory_item_id = msi.inventory_item_id
	      and mvt.organization_id = msi.organization_id
	      and mvt.sr_instance_id = msi.sr_instance_id
          and mvt.vmi_type = 2 -- customer facing vmi
       UNION
       /* added so that Consumption advice load triggers Create/Update  request for
               drp_planned  consigned item also*/
       SELECT
        sd.inventory_item_id
	  , mtp.sr_instance_id
	  , mtp.modeled_customer_id
	  , mtp.modeled_customer_site_id
	  , msi.uom_code
	  , msi.sr_inventory_item_id
          , msi.organization_id
          , msi.source_org_id
	  , sd.key_date
          , msi.consigned_flag
          , sd.primary_quantity
          , msi.item_name
          , msi.description
          , sd.customer_name
          , sd.customer_site_name
          , msi.uom_code
		  ,  -1
		  ,  -1
		  ,  -1
		  ,  -1
		  ,   0
		   , sd.ORDER_NUMBER           --Consigned CVMI Enh
		  , sd.RELEASE_NUMBER
		  , sd.LINE_NUMBER
		  , sd.END_ORDER_NUMBER
		  , sd.END_ORDER_REL_NUMBER
		  , sd.END_ORDER_LINE_NUMBER
		  , mtp.partner_name
		  , sd.publisher_order_type_desc
      FROM
	   msc_system_items msi,
           msc_sup_dem_entries sd,
	   msc_trading_partners mtp,
	   msc_trading_partner_maps map1,
	   msc_trading_partner_maps map2,
           msc_company_relationships mcr
       WHERE
	       msi.inventory_planning_code = VMI_PLANNING_METHOD
	   AND msi.sr_instance_id = mtp.sr_instance_id
	   AND msi.organization_id = mtp.sr_tp_id
	   AND msi.inventory_item_id = sd.inventory_item_id
           AND msi.plan_id = sd.plan_id
	   AND mtp.partner_type = 3
	   AND map2.map_type = 3
	   AND map2.tp_key = mtp.modeled_customer_site_id
	   AND map1.map_type = 1
           AND map1.tp_key = mtp.modeled_customer_id
	   AND map1.company_key = mcr.relationship_id
	   AND mcr.subject_id = OEM_COMPANY_ID
	   AND mcr.relationship_type = CUSTOMER_OF
	   AND sd.publisher_site_id = map2.company_key
	   AND sd.publisher_id = mcr.object_id
	   AND sd.ref_header_id = p_header_id
	   AND sd.publisher_order_type = CONSUMPTION_ADVICE
	   AND sd.primary_quantity > 0
	   AND msi.drp_planned = 1     -- drp planned item
	   AND msi.consigned_flag = 1  -- consigned item
	   AND NOT EXISTS(SELECT mvt.inventory_item_id
	FROM msc_vmi_temp mvt
	WHERE mvt.plan_id = msi.plan_id
	      and mvt.inventory_item_id = msi.inventory_item_id
	      and mvt.organization_id = msi.organization_id
	      and mvt.sr_instance_id = msi.sr_instance_id
              and mvt.vmi_type = 2 )
	;

  BEGIN

   print_debug_info('  sales order header ID = '
		    || p_header_id
		    );

   OPEN c_release_attributes
   ( p_header_id
   );

   LOOP
   FETCH c_release_attributes
   INTO
        l_inventory_item_id
	  , l_sr_instance_id
	  , l_customer_id
	  , l_customer_site_id
	  , l_uom
	  , l_sr_inventory_item_id
      , l_customer_org_id
      , l_source_org_id
      , l_request_date
      , l_consigned_flag
      , l_release_quantity
          , l_item_name
          , l_item_describtion
          , l_customer_name
          , l_customer_site_name
          , l_uom_code
		  , l_vmi_minimum_units
		  , l_vmi_maximum_units
		  , l_vmi_minimum_days
		  , l_vmi_maximum_days
		  , l_average_daily_demand
		  , l_ORDER_NUMBER               --Consigned CVMI Enh : Bug # 4247230
	, l_RELEASE_NUMBER
	, l_LINE_NUMBER
	, l_END_ORDER_NUMBER
	, l_END_ORDER_REL_NUMBER
	, l_END_ORDER_LINE_NUMBER
	, l_ship_from_org_name
	, l_order_type
      ;
   EXIT WHEN c_release_attributes%NOTFOUND;

   print_debug_info('l_inventory_item_id/  customer/ customer site = '
		    ||l_inventory_item_id||'/ '|| l_customer_id
		    || '/ ' || l_customer_site_id
		    );

   print_user_info(' uom/sr item/customer modeled org = '
            || l_uom
		    || '/ ' || l_sr_inventory_item_id
		    || '/ ' || l_customer_org_id
		    );

   print_user_info('  source org/request date/consigned flag/comsumption advice quantity = '
            || l_source_org_id
		    || '/ ' || l_request_date
		    || '/ ' || l_consigned_flag
		    || '/ ' || l_release_quantity
		    );

print_debug_info(' l_vmi_minimum_units/ l_vmi_maximum_units/ l_vmi_minimum_days/ l_vmi_maximum_days = '
                  ||l_vmi_minimum_units||'/ '||l_vmi_maximum_units||'/ '||l_vmi_minimum_days||'/ '||l_vmi_maximum_days) ;

   print_debug_info('    l_average_daily_demand = '
            || l_average_daily_demand||' /Ship_from_org_name = '||l_ship_from_org_name||' /Order_type = '||l_order_type);

   print_debug_info(' l_ORDER_NUMBER = '||l_ORDER_NUMBER||' / l_RELEASE_NUMBER = '||l_RELEASE_NUMBER
    ||' / l_LINE_NUMBER = '||l_LINE_NUMBER);

  print_debug_info(' l_END_ORDER_NUMBER = '||l_END_ORDER_NUMBER||' / l_END_ORDER_REL_NUMBER = '||
     l_END_ORDER_REL_NUMBER||' / l_END_ORDER_LINE_NUMBER = '||l_END_ORDER_LINE_NUMBER);

  vmi_release_api
  (   l_inventory_item_id -- IN NUMBER
    , l_sr_instance_id -- IN NUMBER
    , NULL -- l_supplier_id -- IN NUMBER
    , NULL -- l_supplier_site_id -- IN NUMBER
    , l_customer_id -- IN NUMBER
    , l_customer_site_id -- IN NUMBER
    , l_release_quantity -- IN NUMBER
    , l_uom -- IN VARCHAR2
    , l_sr_inventory_item_id -- IN NUMBER
    , l_customer_org_id -- IN NUMBER
    , l_source_org_id -- IN NUMBER
    , l_request_date -- IN DATE
    , l_consigned_flag -- IN NUMBER
    , 3 --l_vmi_release_type -- IN NUMBER
          , l_item_name
          , l_item_describtion
          , l_customer_name
          , l_customer_site_name
          , l_uom_code
		  , l_vmi_minimum_units
		  , l_vmi_maximum_units
		  , l_vmi_minimum_days
		  , l_vmi_maximum_days
		  , l_average_daily_demand
		  , l_ORDER_NUMBER               --Consigned CVMI Enh : Bug # 4247230
	, l_RELEASE_NUMBER
	, l_LINE_NUMBER
	, l_END_ORDER_NUMBER
	, l_END_ORDER_REL_NUMBER
	, l_END_ORDER_LINE_NUMBER
	, l_ship_from_org_name
	, l_order_type
    );

   END LOOP;

   IF (c_release_attributes%ROWCOUNT < 1) THEN
     print_debug_info('  No records found for header ID ' || p_header_id
                      || '. Can not create sales order for comsuption advice.');
   END IF;
   CLOSE c_release_attributes;

EXCEPTION
   WHEN OTHERS THEN
      print_debug_info('  Error when starting vmi workflow process= ' || sqlerrm);
      RAISE;
END vmi_release_api_load;

PROCEDURE vmi_replenish_wf
  (
      p_rep_transaction_id IN NUMBER
    , p_inventory_item_id IN NUMBER
    , p_supplier_id IN NUMBER
    , p_supplier_site_id IN NUMBER
    , p_sr_instance_id IN NUMBER
    , p_customer_id IN NUMBER
    , p_customer_site_id IN NUMBER
    , p_vmi_minimum_units IN NUMBER
    , p_vmi_maximum_units IN NUMBER
    , p_vmi_minimum_days IN NUMBER
    , p_vmi_maximum_days IN NUMBER
    , p_so_authorization_flag IN NUMBER
    , p_consigned_flag IN NUMBER
    , p_planner_code IN VARCHAR2 -- , p_supplier_contact IN VARCHAR2
    -- , p_customer_contact IN VARCHAR2
    , p_supplier_item_name IN VARCHAR2
    , p_supplier_item_desc IN VARCHAR2
    , p_customer_item_name IN VARCHAR2
    , p_customer_item_desc IN VARCHAR2
    , p_supplier_name IN VARCHAR2
    , p_supplier_site_name IN VARCHAR2
    , p_customer_name IN VARCHAR2
    , p_customer_site_name IN VARCHAR2
    , p_order_quantity IN VARCHAR2
    , p_onhand_quantity IN VARCHAR2
    , p_time_fence_multiplier IN NUMBER
    , p_time_fence_end_date IN VARCHAR2
    , p_uom IN VARCHAR2
    , p_source_so_org_id IN NUMBER
    , p_modeled_customer_org_id IN NUMBER
    , p_vmi_release_type IN NUMBER
    , p_sr_inventory_item_id IN NUMBER
    ) IS
       l_wf_type VARCHAR2(50);
       l_wf_key VARCHAR2(200);
       l_wf_process VARCHAR2(50);
       l_status VARCHAR2(100);
       l_refresh_number NUMBER;

       l_customer_contact msc_partner_contacts.name%TYPE;
       l_supplier_contact msc_planners.user_name%TYPE;

    CURSOR c_customer_contacts (
        p_sr_instance_id NUMBER
      , p_customer_id NUMBER
      , p_customer_site_id NUMBER
      ) IS
      SELECT mpc.name
      FROM msc_partner_contacts mpc
      WHERE mpc.partner_type = 2 ---Customer
	  AND mpc.sr_instance_id = p_sr_instance_id
	  AND mpc.partner_site_id = p_customer_site_id
	  AND mpc.partner_id = p_customer_id
      ORDER BY mpc.name
    ;

    CURSOR c_supplier_contacts
      ( p_sr_instance_id NUMBER
      , p_planner_code VARCHAR2
      , p_modeled_customer_org_id NUMBER
      ) IS
      SELECT mp.user_name
      FROM msc_planners mp
      WHERE mp.planner_code = p_planner_code
      AND mp.organization_id = p_modeled_customer_org_id
      AND mp.sr_instance_id = p_sr_instance_id
      ORDER BY mp.user_name
      ;

BEGIN

   -- l_sce_supplier_site_id := aps_to_sce(p_supplier_site_id, ORGANIZATION_MAPPING, p_sr_instance_id);
   -- l_sce_customer_site_id := aps_to_sce(p_customer_site_id, SITE_MAPPING);
   -- l_sce_customer_id := aps_to_sce(p_customer_id, COMPANY_MAPPING);

   OPEN c_customer_contacts (
        p_sr_instance_id
      , p_customer_id
      , p_customer_site_id
      );

   FETCH c_customer_contacts INTO l_customer_contact;

   CLOSE c_customer_contacts;

   OPEN c_supplier_contacts (
        p_sr_instance_id
      , p_planner_code
      , p_modeled_customer_org_id
      );

   FETCH c_supplier_contacts INTO l_supplier_contact;

   CLOSE c_supplier_contacts;

   print_debug_info('  transaction id/item/instance = '
            || p_rep_transaction_id
		    || '/' || p_inventory_item_id
		    || '/' || p_sr_instance_id
		    );
   print_debug_info('  supplier/supplier site/customer/customer site = '
            || p_supplier_id
		    || '/' || p_supplier_site_id
		    || '/' || p_customer_id
		    || '/' || p_customer_site_id
		    );

   print_user_info('  min unit/max unit/min days/max days = '
            || p_vmi_minimum_units
		    || '/' || p_vmi_maximum_units
		    || '/' || p_vmi_minimum_days
		    || '/' || p_vmi_maximum_days
		    );

   print_user_info('  supplier item/description/customer item/description = '
            || p_supplier_item_name
		    || '/' || p_supplier_item_desc
		    || '/' || p_customer_item_name
		    || '/' || p_customer_item_desc
		    );

   print_user_info('  supplier/supplier site/customer/customer site = '
            || p_supplier_name
		    || '/' || p_supplier_site_name
		    || '/' || p_customer_name
		    || '/' || p_customer_site_name
		    );

   print_user_info('  order quantity/onhand quantity/item planner/customer contact/planner code = '
            || p_order_quantity
		    || '/' || p_onhand_quantity
		    || '/' || l_supplier_contact
		    || '/' || l_customer_contact
		    || '/' || p_planner_code
		    );

   print_user_info('  so authorization/consigned/time fence multiplier/time fence end date = '
            || p_so_authorization_flag
		    || '/' || p_consigned_flag
		    || '/' || p_time_fence_multiplier
		    || '/' || p_time_fence_end_date
		    );


   print_user_info('  UOM/source so org ID/modeled customer org ID = '
            || p_uom
		    || '/' || p_source_so_org_id
            || '/' || p_modeled_customer_org_id
		    );

	  -- use item id, supplier id, customer id, customer site id, replenishment
	  -- transaction id to compose a Workflow key, this Workflow key will be used
	  -- by UI code to release the replenishment
	  l_wf_key := TO_CHAR(p_inventory_item_id)
	    || '-' || TO_CHAR(p_supplier_id)
	    || '-' || TO_CHAR(p_customer_id)
	    || '-' || TO_CHAR(p_customer_site_id)
	    || '-' || TO_CHAR(p_rep_transaction_id)
	    ;
	  print_debug_info('    new workflow key = ' || l_wf_key);

      l_wf_type := 'MSCXCFVR';
	  l_wf_process := 'MSCX_CVMI_REPLENISH';

	  -- create a Workflow process for the (item/org/supplier)
	  wf_engine.CreateProcess
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , process  => l_wf_process
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'REP_TRANSACTION_ID'
	      , avalue   => p_rep_transaction_id
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'INVENTORY_ITEM_ID'
	      , avalue   => p_inventory_item_id
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SR_INSTANCE_ID'
	      , avalue   => p_sr_instance_id
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SUPPLIER_ID'
	      , avalue   => p_supplier_id
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SUPPLIER_SITE_ID'
	      , avalue   => p_supplier_site_id
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'CUSTOMER_ID'
	      , avalue   => p_customer_id
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'CUSTOMER_SITE_ID'
	      , avalue   => p_customer_site_id
	      );

    IF (p_vmi_minimum_units <> -1) THEN
	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'MINIMUM_QUANTITY'
	      , avalue   => p_vmi_minimum_units
	      );
    END IF;

    IF (p_vmi_maximum_units <> -1) THEN
	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'MAXIMUM_QUANTITY'
	      , avalue   => p_vmi_maximum_units
	      );
    END IF;

    IF (p_vmi_minimum_days <> -1) THEN
	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'MINIMUM_DAYS'
	      , avalue   => p_vmi_minimum_days
	      );
    END IF;

    IF (p_vmi_maximum_days <> -1) THEN
	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'MAXIMUM_DAYS'
	      , avalue   => p_vmi_maximum_days
	      );
    END IF;

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SUPPLIER_ITEM_NAME'
	      , avalue   => p_supplier_item_name
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SUPPLIER_ITEM_DESCRIPTION'
	      , avalue   => p_supplier_item_desc
          );
	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SUPPLIER_NAME'
	      , avalue   => p_supplier_name
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SUPPLIER_SITE_NAME'
	      , avalue   => p_supplier_site_name
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'CUSTOMER_NAME'
	      , avalue   => p_customer_name
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'CUSTOMER_SITE_NAME'
	      , avalue   => p_customer_site_name
	      );

    IF (p_order_quantity <> -1) THEN
	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'ORDER_QUANTITY'
	      , avalue   => p_order_quantity
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'RELEASE_QUANTITY'
	      , avalue   => p_order_quantity
	      );
    END IF;

    IF (p_onhand_quantity <> -1) THEN
	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'ONHAND_QUANTITY'
	      , avalue   => p_onhand_quantity
	      );
    END IF;

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SUPPLIER_CONTACT'
	      , avalue   => l_supplier_contact
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'CUSTOMER_CONTACT'
	      , avalue   => l_customer_contact
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SO_AUTHORIZATION_FLAG'
	      , avalue   => p_so_authorization_flag
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'CONSIGNED_FLAG'
	      , avalue   => p_consigned_flag
	      );

	  wf_engine.SetItemAttrDate
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'TIME_FENCE_END_DATE'
	      , avalue   => p_time_fence_end_date
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'UOM_CODE'
	      , avalue   => p_uom
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SOURCE_ORG_ID'
	      , avalue   => p_source_so_org_id
	      );
	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'CUSTOMER_ORG_ID'
	      , avalue   => p_modeled_customer_org_id
	      );
	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'VMI_RELEASE_TYPE'
	      , avalue   => p_vmi_release_type
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SR_INVENTORY_ITEM_ID'
	      , avalue   => p_sr_inventory_item_id
	      );

	  -- start Workflow process for item/org/supplier
	  print_debug_info('    start workflow process');
	  wf_engine.StartProcess
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      );
    print_user_info('    end of workflow process');

EXCEPTION
   WHEN OTHERS THEN
      print_debug_info('  Error when starting vmi workflow process= ' || sqlerrm);
      RAISE;
END vmi_replenish_wf;

  -- reset vmi refresh flag
  PROCEDURE reset_vmi_refresh_flag
    IS

    CURSOR c_forecast_items IS
      SELECT
          msi.plan_id
        , msi.inventory_item_id
        , msi.organization_id
        , msi.sr_instance_id
        , mtp.modeled_customer_id
        , mtp.modeled_customer_site_id
        , msi.forecast_horizon
        , msi.vmi_forecast_type
        , mvt.average_daily_demand
      FROM msc_system_items msi
      , msc_trading_partners mtp
      , msc_vmi_temp mvt
      WHERE msi.inventory_planning_code = 7 -- (?)
      AND msi.organization_id = mtp.sr_tp_id
      AND msi.sr_instance_id = mtp.sr_instance_id
      AND mtp.partner_type = 3 -- org
      AND mtp.modeled_customer_id IS NOT NULL
      AND mtp.modeled_customer_site_id IS NOT NULL
      AND msi.plan_id = -1
	      and mvt.plan_id = msi.plan_id
	      and mvt.inventory_item_id = msi.inventory_item_id
	      and mvt.organization_id = msi.organization_id
	      and mvt.sr_instance_id = msi.sr_instance_id
          and mvt.vmi_type = 2 -- customer facing vmi
      ;

  BEGIN

print_debug_info('  start of reset vmi refresh flag');

    FOR forecast_item IN c_forecast_items LOOP

print_debug_info( '  plan/item/org/instance/customer/customer site = '
                                 || forecast_item.plan_id
                                 || '-' || forecast_item.inventory_item_id
                                 || '-' || forecast_item.organization_id
                                 || '-' || forecast_item.sr_instance_id
                                 || '-' || forecast_item.modeled_customer_id
                                 || '-' || forecast_item.modeled_customer_site_id
                                 );
      UPDATE msc_system_items
        SET vmi_refresh_flag = 0
        WHERE plan_id = forecast_item.plan_id
        AND inventory_item_id = forecast_item.inventory_item_id
        AND organization_id = forecast_item.organization_id
        AND sr_instance_id = forecast_item.sr_instance_id
        ;

print_debug_info( '  average daily demand and vmi refresh flag reset to 0, number of rows updated = '
                                 || SQL%ROWCOUNT
                                 );
    END LOOP; -- c_forecast_items
print_debug_info( '  end of reset vmi refresh flag');
  EXCEPTION
  WHEN OTHERS THEN
print_debug_info('Error in reset vmi refresh flag = ' || sqlerrm);
     RAISE;
  END reset_vmi_refresh_flag;

-- This procesure prints out message to user
  PROCEDURE print_user_info(
    p_user_info IN VARCHAR2
  )IS
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, p_user_info);
    -- dbms_output.put_line(p_user_info); --ut
  EXCEPTION
  WHEN OTHERS THEN
     RAISE;
END print_user_info;

-- This procesure prints out debug information
PROCEDURE print_debug_info(
    p_debug_info IN VARCHAR2
  )IS
  BEGIN
    IF ( g_msc_cp_debug= '1' OR g_msc_cp_debug = '2') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, p_debug_info);
    END IF;
    -- dbms_output.put_line(p_debug_info); --ut
  EXCEPTION
  WHEN OTHERS THEN
     RAISE;
END print_debug_info;

END MSC_X_CVMI_REPLENISH;

/
