--------------------------------------------------------
--  DDL for Package Body MSC_X_REPLENISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_REPLENISH" AS
/* $Header: MSCXSFVB.pls 120.7 2008/02/25 10:38:50 hbinjola ship $ */

g_msc_cp_debug VARCHAR2(10) := NVL(FND_PROFILE.VALUE('MSC_CP_DEBUG'), '0');
  SUPPLIER_IS_OEM   number := 1;
  CUSTOMER_IS_OEM   number := 2;

-- This procedure will be called by Concurrent Program to perform
-- VMI replenishment
PROCEDURE vmi_replenish_wrapper
  ( errbuf OUT NOCOPY VARCHAR2
    , retcode OUT NOCOPY VARCHAR2
    , p_supplier_replenish_flag IN VARCHAR2
    , p_supplier_time_fence IN NUMBER
    , p_customer_replenish_flag IN VARCHAR2
    , p_customer_time_fence IN NUMBER
    ) IS
BEGIN

  -- run the VMI engine
  IF (p_supplier_replenish_flag IN (to_char(1), 'Y')) THEN
    MSC_X_REPLENISH.vmi_replenish_concurrent
    ( p_supplier_time_fence
    );
  END IF;

  IF (p_customer_replenish_flag IN (to_char(1), 'Y')) THEN
    MSC_X_CVMI_REPLENISH.vmi_replenish_concurrent
    ( p_customer_time_fence
    );
  END IF;

EXCEPTION
   WHEN OTHERS THEN
      print_debug_info('Error when running VMI engines = ' || sqlerrm);
      raise;
END vmi_replenish_wrapper;

  -- reset vmi refresh flag
  PROCEDURE reset_vmi_refresh_flag
    IS
    CURSOR c_forecast_items IS
     SELECT DISTINCT
          mis.plan_id
        , mis.inventory_item_id
        , mis.organization_id
        , mis.sr_instance_id
        , mis.supplier_id
        , mis.supplier_site_id
     FROM msc_item_suppliers mis
      WHERE mis.plan_id = -1
      AND mis.vmi_flag = 1
      ;

  BEGIN

print_debug_info('  start of reset_vmi refresh flag');

    FOR forecast_item IN c_forecast_items LOOP

print_debug_info( '  plan/item/org/instance/supplier/supplier site = '
                                 || forecast_item.plan_id
                                 || '/' || forecast_item.inventory_item_id
                                 || '/' || forecast_item.organization_id
                                 || '/' || forecast_item.sr_instance_id
                                 || '/' || forecast_item.supplier_id
                                 || '/' || forecast_item.supplier_site_id
                                 );
      UPDATE msc_item_suppliers
        SET vmi_refresh_flag = 0
        WHERE plan_id = forecast_item.plan_id
        AND inventory_item_id = forecast_item.inventory_item_id
        AND organization_id = forecast_item.organization_id
        AND sr_instance_id = forecast_item.sr_instance_id
        AND supplier_id = forecast_item.supplier_id
        AND supplier_site_id = forecast_item.supplier_site_id
        ;

    END LOOP; -- c_forecast_items
print_debug_info('  end of reset vmi refresh flag');
  EXCEPTION
  WHEN OTHERS THEN
print_debug_info('Error in reset vmi refresh flag = ' || sqlerrm);
     RAISE;
  END reset_vmi_refresh_flag;

-- This procedure will be called by Concurrent Program to perform
-- SCE VMI replenishment
PROCEDURE vmi_replenish_concurrent
  ( p_supplier_time_fence IN NUMBER
    ) IS
      l_supplier_id NUMBER;
      l_supplier_site_id NUMBER;
      l_single_sourcing_flag BOOLEAN;
      l_reorder_point NUMBER;
      l_validate_supplier NUMBER := 0;
      l_full_lead_time NUMBER;
      l_time_fence_end_date DATE;
      l_plan_refresh_number NUMBER;
      l_max_refresh_number NUMBER;
      l_sce_organization_id NUMBER;
      lv_dummy1         varchar2(32) := '';
      lv_dummy2         varchar2(32) := '';
      v_applsys_schema  varchar2(32);
      v_retval          boolean;


      cursor c_netting_items (p_last_max_refresh_number in number) is
         SELECT distinct its.inventory_item_id,
                         its.organization_id,
                         its.plan_id,
                         its.sr_instance_id,
                         its.supplier_id,
                         its.supplier_site_id
         FROM    msc_sup_dem_entries sd1,
           	 msc_item_suppliers its,
	         msc_trading_partners tp,
	         msc_trading_partner_maps map,
	         msc_trading_partner_maps map2,
                 msc_trading_partner_maps map3,
                 msc_company_relationships r
         WHERE   sd1.plan_id = -1
         -- Alloc onhand, po, asn, recpt, req
         AND     sd1.publisher_order_type in (9, 13, 15, 16, 20)
         AND     nvl(sd1.last_refresh_number,-1) >  p_last_max_refresh_number
         AND     sd1.inventory_item_id = its.inventory_item_id
         AND     its.vmi_flag = 1  -- only look at vmi enabled items
         AND	 its.plan_id = sd1.plan_id
         -- get org_id
         AND	 map.map_type = 2
         AND	 map.company_key = sd1.customer_site_id
         AND	 map.tp_key = tp.partner_id
         AND	 tp.partner_type = 3
         AND	 its.organization_id = tp.sr_tp_id
         AND     its.sr_instance_id = tp.sr_instance_id
         -- get supplier_id
         AND     map2.map_type = 1
         AND     map2.company_key = r.relationship_id
         AND     r.subject_id = 1
         AND     r.object_id = sd1.supplier_id
         AND 	 r.relationship_type = 2
         AND	 its.supplier_id = map2.tp_key
         -- get supplier_site_id
         AND	 its.supplier_site_id = map3.tp_key
         AND	 map3.map_type = 3
         AND	 map3.company_key = sd1.supplier_site_id

         UNION

         SELECT distinct its.inventory_item_id,
                         its.organization_id,
                         its.plan_id,
                         its.sr_instance_id,
                         its.supplier_id,
                         its.supplier_site_id
         FROM    msc_sup_dem_entries sd1,
           	 msc_item_suppliers its,
	         msc_trading_partners tp,
	         msc_trading_partner_maps map,
	         msc_trading_partner_maps map2,
                 msc_trading_partner_maps map3,
                 msc_company_relationships r
         WHERE   sd1.plan_id = -1
         -- Alloc onhand, po, asn, recpt, req
         AND     sd1.publisher_order_type in (9, 13, 15, 16, 20)
         -- AND     nvl(sd1.last_refresh_number,-1) >  p_last_max_refresh_number
         AND     sd1.inventory_item_id = its.inventory_item_id
         AND     its.vmi_flag = 1  -- only look at vmi enabled items
         AND	 its.plan_id = sd1.plan_id
         -- get org_id
         AND	 map.map_type = 2
         AND	 map.company_key = sd1.customer_site_id
         AND	 map.tp_key = tp.partner_id
         AND	 tp.partner_type = 3
         AND	 its.organization_id = tp.sr_tp_id
         AND     its.sr_instance_id = tp.sr_instance_id
         -- get supplier_id
         AND     map2.map_type = 1
         AND     map2.company_key = r.relationship_id
         AND     r.subject_id = 1
         AND     r.object_id = sd1.supplier_id
         AND 	 r.relationship_type = 2
         AND	 its.supplier_id = map2.tp_key
         -- get supplier_site_id
         AND	 its.supplier_site_id = map3.tp_key
         AND	 map3.map_type = 3
         AND	 map3.company_key = sd1.supplier_site_id
         -- there is no new data, but average daily demand changed
         AND its.vmi_refresh_flag = 1
         AND (its.replenishment_method = 2 OR its.replenishment_method = 4)
         ;

      --NOTE:  we need to also look at items with
      --enable_vmi_auto_replenish = N to handle the
      --case where someone changes this from Y to N.
      --In this case we need to close out any workflow
      --that may exist as well as delete any old replenishment record

      /* also net vmi items with auto='Y' which have no tx in msc_sup_dem_entries */
      cursor c_netting_items_notx is
        SELECT distinct its.inventory_item_id,
			 its.organization_id,
			 its.plan_id,
			 its.sr_instance_id,
			 its.supplier_id,
			 its.supplier_site_id
	 FROM   msc_item_suppliers its,
	MSC_X_ITEM_SUPPLIERS_GTT iut,
	MSC_X_ITEM_ORGS_GTT iot,
	MSC_X_ITEM_SITES_GTT ist
	 WHERE  its.plan_id = -1
	 AND    its.vmi_flag = 1  -- only look at vmi enabled items
	 AND    its.enable_vmi_auto_replenish_flag = 'Y'
	 AND    its.supplier_id = iut.tp_key
	 AND    its.organization_id = iot.sr_tp_id
	 AND    its.supplier_site_id = ist.tp_key
	 AND NOT EXISTS ( SELECT 1 FROM MSC_SUP_DEM_ENTRIES SD
			   WHERE SD.PLAN_ID = -1
			   AND SD.INVENTORY_ITEM_ID = ITS.INVENTORY_ITEM_ID
			   AND SD.PUBLISHER_ORDER_TYPE IN (9, 13, 15, 16, 20)
			   AND SD.CUSTOMER_SITE_ID = iot.COMPANY_KEY
			   AND SD.SUPPLIER_ID = iut.OBJECT_ID
			   AND SD.SUPPLIER_SITE_ID = ist.COMPANY_KEY) ;

    TYPE netting_item_record IS RECORD
	(
	 inventory_item_id      NUMBER
	 , organization_id      NUMBER
	 , plan_id              NUMBER
	 , sr_instance_id       NUMBER
	 , supplier_id          NUMBER
	 , supplier_site_id     NUMBER
	 );

      netting_item netting_item_record;
      -- max refresh number from the last netting run
      l_last_max_refresh_number number;
      -- max refresh number in sup_dem_entries currently
      l_curr_max_refresh_number number;
BEGIN
   print_user_info('Start of VMI engines');
   print_user_info('Start of VMI replenishment engine');
   print_user_info('Replenish time fence multiplier = ' || p_supplier_time_fence);

  -- run the average daily demand calculation engine
   	MSC_X_PLANNING.calculate_average_demand;

   /* get refresh number info */

   -- l_curr_max_refresh_number is the max refresh number in
   -- sup_dem_entries currently

   select NVL(max(last_refresh_number), 0)
     into   l_curr_max_refresh_number
     from   msc_sup_dem_entries
     where  plan_id = -1;

   print_user_info('Current maximum refresh number = ' || l_curr_max_refresh_number);
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
					  status_date
                      , number1
                      )
	   values( -1,
		   -1,
		   -1,
		   l_curr_max_refresh_number,
		   sysdate
           , p_supplier_time_fence
           );
   end;

   print_user_info('Previous maximum refresh number = ' || l_last_max_refresh_number);

 -- bug 5096476 : Creating index on the fly for performance improvement

  v_retval := FND_INSTALLATION.GET_APP_INFO(
                 'FND', lv_dummy1,lv_dummy2, v_applsys_schema);

   -- performance fix (bug 4898923), create index on msc_item_suppliers for vmi enabled items
   -- create_index_item_sup_vmi (v_applsys_schema);

   -- do netting for each item/org/plan/sr_instance_id/supplier/supplier_site combination

   OPEN c_netting_items (l_last_max_refresh_number);
   print_debug_info('Start of loop through item/org/plan/sr_instance_id/supplier/supplier_site combinations');
   -- loop through each each item/org/plan/sr_instance_id/supplier/supplier_site combination
   LOOP
      FETCH c_netting_items
        INTO netting_item.inventory_item_id
        , netting_item.organization_id
        , netting_item.plan_id
        , netting_item.sr_instance_id
        , netting_item.supplier_id
        , netting_item.supplier_site_id
        ;


      print_debug_info('  ------');
      print_debug_info('  item/organization/plan/sr instance/supplier/supplier site = '
            || netting_item.inventory_item_id
			|| '/' || netting_item.organization_id
			|| '/' || netting_item.plan_id
			|| '/' || netting_item.sr_instance_id
			|| '/' || netting_item.supplier_id
			|| '/' || netting_item.supplier_site_id
			);

      EXIT WHEN c_netting_items%NOTFOUND;

      -- launch replenish workflow process for this item/org/supplier
      BEGIN
      print_debug_info('    start to launch replenishment workflow process');
   	  vmi_replenish_wf
	   ( p_supplier_time_fence
	     , netting_item.inventory_item_id
	     , netting_item.organization_id
	     , netting_item.plan_id
	     , netting_item.sr_instance_id
	     , netting_item.supplier_id
	     , netting_item.supplier_site_id
	     );
      EXCEPTION
	 WHEN OTHERS THEN
	    print_debug_info('    Error when launch workflow process  = ' || sqlerrm);
      END;

   END LOOP; -- item/org/plan/sr_instance_id combination

   print_debug_info('End of loop through item/org/plan/sr_instance_id/supplier/supplier_site combinations');

   CLOSE c_netting_items;

   /* ----- no tx items ----- */

   -- do netting for each item/org/plan/sr_instance_id/supplier/supplier_site combination
   -- which does not have any transactions in msc_sup_dem_entries
temp_tables();
   OPEN c_netting_items_notx;

   print_debug_info('Start of loop for combinations with no transaction data in CP');
   -- loop through each each item/org/plan/sr_instance_id/supplier/supplier_site combination
    LOOP
       FETCH c_netting_items_notx
	 INTO netting_item.inventory_item_id
	 , netting_item.organization_id
	 , netting_item.plan_id
	 , netting_item.sr_instance_id
	 , netting_item.supplier_id
	 , netting_item.supplier_site_id
	 ;

       print_debug_info('  ------');
      print_debug_info( '  item/organization/plan/sr instance/supplier/supplier site = '
            || netting_item.inventory_item_id
			|| '/' || netting_item.organization_id
			|| '/' || netting_item.plan_id
			|| '/' || netting_item.sr_instance_id
			|| '/' || netting_item.supplier_id
			|| '/' || netting_item.supplier_site_id
			);

       EXIT WHEN c_netting_items_notx%NOTFOUND;

       -- launch replenish workflow process for this item/org/supplier
       BEGIN
       print_debug_info('    start to launch replenishment workflow process');
   	   vmi_replenish_wf
	    ( p_supplier_time_fence
	      , netting_item.inventory_item_id
	      , netting_item.organization_id
	      , netting_item.plan_id
	      , netting_item.sr_instance_id
	      , netting_item.supplier_id
	      , netting_item.supplier_site_id
	      );
       EXCEPTION
          WHEN OTHERS THEN
	        print_debug_info('    Error when launch workflow process  = ' || sqlerrm);
       END;

    END LOOP; -- item/org/plan/sr_instance_id combination
    print_debug_info('End of loop for combinations with no transaction data in CP');
    CLOSE c_netting_items_notx;

     -- drop the msc_item_suppliers_n1 index
    --drop_index_item_sup_vmi (v_applsys_schema);

    print_user_info('End of VMI replenishment engine');

    -- call API Compute_VMI_Exceptions to generate VMI exceptions

    print_user_info('============');
    print_user_info('Start of VMI exception engine');

    MSC_X_EX5_PKG.Compute_VMI_Exceptions ( l_last_max_refresh_number
                                         , p_supplier_time_fence
                                         );

    print_user_info('End of VMI exception engine');

    update  msc_plan_org_status
    set     status = l_curr_max_refresh_number,
            status_date = sysdate
            , number1 = p_supplier_time_fence
    where   plan_id = -1
    and     organization_id = -1
    and     sr_instance_id = -1;

  -- reset vmi refresh flag
  reset_vmi_refresh_flag;

    commit;

    print_user_info('End of VMI engines');
EXCEPTION
   WHEN OTHERS THEN
      print_user_info('Error when running VMI engines = ' || sqlerrm);
      raise;
END vmi_replenish_concurrent;


-- This procedure will start the Workflow process for VMI netting and replenishment
PROCEDURE vmi_replenish_wf
  ( p_supplier_time_fence IN NUMBER
    , p_inventory_item_id IN NUMBER
    , p_organization_id IN NUMBER
    , p_plan_id IN NUMBER
    , p_sr_instance_id IN NUMBER
    , p_supplier_id IN NUMBER
    , p_supplier_site_id IN NUMBER
    ) IS
       l_wf_type VARCHAR2(50) := 'MSCXVMIR';
       l_wf_key VARCHAR2(200);
       l_wf_process VARCHAR2(50);
       l_rep_transaction_id NUMBER;
       l_buyer_name VARCHAR2(100);
       l_status VARCHAR2(100);
       l_customer_item_name VARCHAR2(100);
       l_customer_name VARCHAR2(100);
       l_customer_site_name VARCHAR2(100);
       l_supplier_name VARCHAR2(100);
       l_supplier_site_name VARCHAR2(100);
       l_refresh_number NUMBER;
       l_sce_organization_id NUMBER;
       l_sce_supplier_site_id NUMBER;
       l_sce_supplier_id NUMBER;
       l_vmi_replenishment_approval VARCHAR2(30);
       l_vmi_role_name VARCHAR2(100);
       l_vmi_role_display_name VARCHAR2(100);
       l_vmi_role_existing NUMBER;
       l_seller_role_name VARCHAR2(100);
       l_seller_role_display_name VARCHAR2(100);
       l_seller_role_existing NUMBER;

       -- get the seller(supplier) name
       CURSOR c_seller_name
	 (
	  p_partner_id NUMBER
	  , p_partner_site_id NUMBER
	  , p_sr_instance_id NUMBER
	  ) IS
	     SELECT mpc.name
	       FROM MSC_PARTNER_CONTACTS mpc
	       WHERE mpc.partner_id = p_partner_id
	       AND mpc.partner_site_id = p_partner_site_id
	       AND mpc.sr_instance_id = p_sr_instance_id
	       AND mpc.partner_type = 1 -- supplier
	       ;

       -- get the buyer name
       CURSOR c_buyer_name
	 (
	  p_site_id IN NUMBER
	  ) IS
	     SELECT DISTINCT mp.user_name
	       FROM msc_planners mp
	       , msc_system_items msi
	       WHERE msi.plan_id = p_plan_id
	       AND msi.organization_id = p_site_id
	       AND msi.inventory_item_id = p_inventory_item_id
	       AND msi.sr_instance_id = p_sr_instance_id
	       AND mp.sr_instance_id = msi.sr_instance_id
	       AND mp.organization_id = msi.organization_id
	       AND mp.planner_code = msi.planner_code;

       -- get customer item name
       CURSOR c_customer_item_name
	 (
	  p_inventory_item_id IN NUMBER
	  ) IS
	     SELECT msi.item_name
	       FROM msc_system_items msi
	       WHERE msi.plan_id = p_plan_id
	       AND msi.organization_id = p_organization_id
	       AND msi.inventory_item_id = p_inventory_item_id
	       AND msi.sr_instance_id = p_sr_instance_id
	       ;

       -- get company name
       CURSOR c_company_name
	 (
	  p_company_id IN NUMBER
	  ) IS
	     SELECT mc.company_name
	       FROM msc_companies mc
	       WHERE mc.company_id = p_company_id
	       ;

       -- get company site name
       CURSOR c_company_site_name
	 (
	  p_company_id IN NUMBER
	  , p_company_site_id IN NUMBER
	  ) IS
	     SELECT mcs.company_site_name
	       FROM msc_company_sites mcs
	       WHERE mcs.company_id = p_company_id
	       AND mcs.company_site_id = p_company_site_id
	       ;

       -- check if Workflow role already exists
       CURSOR c_wf_role_existing
	 (
	  p_role_name IN VARCHAR2
	  ) IS
	     SELECT count(1)
	       FROM wf_local_roles
	       WHERE name = p_role_name
	       ;

       CURSOR c_vmi_replenishment_approval
	 IS
	    SELECT vmi_replenishment_approval
	      FROM msc_item_suppliers
	      WHERE inventory_item_id = p_inventory_item_id
	      AND organization_id = p_organization_id
	      AND plan_id = p_plan_id
	      AND sr_instance_id = p_sr_instance_id
	      AND supplier_id = p_supplier_id
	      AND supplier_site_id = p_supplier_site_id
	      ORDER BY using_organization_id DESC
	      ;

       cursor c_enable_auto_repl_flag
	 (
	  p_organization_id in number,
	  p_inventory_item_id in number,
	  p_plan_id in number,
	  p_sr_instance_id in number,
	  p_supplier_id in number,
	  p_supplier_site_id in NUMBER
	  ) is
	     SELECT enable_vmi_auto_replenish_flag
	       FROM MSC_ITEM_SUPPLIERS
	       WHERE organization_id = p_organization_id
	       AND inventory_item_id = p_inventory_item_id
	       AND plan_id = p_plan_id
	       AND sr_instance_id = p_sr_instance_id
	       AND supplier_id = p_supplier_id
	       AND supplier_site_id = p_supplier_site_id
	       ORDER BY using_organization_id DESC;

       l_enable_vmi_auto_repl_flag varchar2(1);
       l_del_transaction_id number;
       l_del_repl_record boolean;
       l_del_wf_key varchar2(1000);
       l_wf_status varchar2(50);
       l_wf_result varchar2(50);
       l_del_rowid rowid;
       l_seller_role_seq NUMBER;
       l_vmi_role_seq NUMBER;

BEGIN

   l_sce_organization_id := aps_to_sce(p_organization_id, ORGANIZATION_MAPPING, p_sr_instance_id);
   l_sce_supplier_site_id := aps_to_sce(p_supplier_site_id, SITE_MAPPING);
   l_sce_supplier_id := aps_to_sce(p_supplier_id, COMPANY_MAPPING);

   print_debug_info('    cp ids: organization/supplier/supplier site = '
            || l_sce_organization_id
		    || '/' || l_sce_supplier_id
		    || '/' || l_sce_supplier_site_id
		    );

    /* --------------  Delete old replenishment records ------------------- */
    open c_enable_auto_repl_flag(p_organization_id,
                                 p_inventory_item_id,
                                 p_plan_id,
                                 p_sr_instance_id,
                                 p_supplier_id,
                                 p_supplier_site_id);

    FETCH c_enable_auto_repl_flag INTO l_enable_vmi_auto_repl_flag;
    CLOSE c_enable_auto_repl_flag;

    print_debug_info('    vmi automatic replenishment flag = ' || l_enable_vmi_auto_repl_flag);

    if ((l_enable_vmi_auto_repl_flag = 'N') or
        (l_enable_vmi_auto_repl_flag is null)) then
       -- delete any old repl record that may be around
       -- check if replenishment record exists
       l_del_repl_record := true;
       begin
          SELECT sd.transaction_id, rowid
          INTO l_del_transaction_id, l_del_rowid
          FROM msc_sup_dem_entries sd
          WHERE sd.publisher_site_id = l_sce_organization_id
          AND sd.inventory_item_id = p_inventory_item_id
          AND sd.publisher_order_type = REPLENISHMENT
          AND sd.plan_id = p_plan_id
          AND sd.supplier_id = l_sce_supplier_id
          AND sd.supplier_site_id = l_sce_supplier_site_id;
       exception
          when others then
             l_del_repl_record := false;
       end;

       if (l_del_repl_record) then
          --close any workflow associated with this record
          -- find the WF key for the previous unclosed Workflow process
          l_del_wf_key := TO_CHAR(p_inventory_item_id)
                           || '-' || l_sce_organization_id
                           || '-' || l_sce_supplier_id
                           || '-' || l_sce_supplier_site_id
                           || '-' || TO_CHAR(l_del_transaction_id);

          print_debug_info('    delete obsolete records with workflow key = ' || l_del_wf_key);

          -- abort previous unclosed Workflow process for this item/org/supplier
          BEGIN
             -- get the status of the previous open Workflow process
             wf_engine.ItemStatus
	       ( itemtype => 'MSCXVMIR'
		 , itemkey  => l_del_wf_key
		 , status    => l_wf_status
		 , result   => l_wf_result
		 );

             print_debug_info('    status of the above workflow process = ' || l_wf_status);
             IF (l_wf_status = 'ACTIVE') THEN
                print_debug_info('    abort the obsolete active workflow process');
                wf_engine.AbortProcess
		  ( itemtype => 'MSCXVMIR'
		    , itemkey  => l_del_wf_key
		    );
             END IF;

          EXCEPTION
             WHEN OTHERS THEN
		print_debug_info('    Error when abort obsolete workflow process ' || sqlerrm);
          END;

          /* delete repl record */
		print_debug_info('    delete obsolete replenishment record with transaction id = '
            || l_del_transaction_id);
          DELETE FROM msc_sup_dem_entries
          WHERE ROWID = l_del_rowid;
       end if;
     elsif (l_enable_vmi_auto_repl_flag = 'Y') then
	  -- get the next replenishment transaction id
	  SELECT msc_sup_dem_entries_s.nextval
	    INTO l_rep_transaction_id FROM DUAL;

	  print_debug_info('    new replenishment transaction id = ' || l_rep_transaction_id);

	  -- use org id, supplier id, supplier site id and replenishment id
	  -- to compose a Workflow key, this Workflow key will be used
	  -- to release the replenishment
	  l_wf_key := TO_CHAR(p_inventory_item_id)
	    || '-' || l_sce_organization_id
	    || '-' || l_sce_supplier_id
	    || '-' || l_sce_supplier_site_id
	    || '-' || TO_CHAR(l_rep_transaction_id)
	    ;
	  print_debug_info('    new workflow key = ' || l_wf_key);

	  l_wf_process := 'STATUS_WORKFLOW1';

	  -- create a Workflow process for the (item/org/supplier)
	  wf_engine.CreateProcess
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , process  => l_wf_process
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'REPLENISH_TIME_FENCE'
	      , avalue   => p_supplier_time_fence
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
	      , aname    => 'ORGANIZATION_ID'
	      , avalue   => p_organization_id
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'PLAN_ID'
	      , avalue   => p_plan_id
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
	      , aname    => 'REP_TRANSACTION_ID'
	      , avalue   => l_rep_transaction_id
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SCE_ORGANIZATION_ID'
	      , avalue   => l_sce_organization_id
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SCE_SUPPLIER_SITE_ID'
	      , avalue   => l_sce_supplier_site_id
	      );

	  wf_engine.SetItemAttrNumber
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SCE_SUPPLIER_ID'
	      , avalue   => l_sce_supplier_id
	      );

	  OPEN c_buyer_name(p_organization_id);
	  FETCH c_buyer_name INTO l_buyer_name;
	  CLOSE c_buyer_name;

	  OPEN c_vmi_replenishment_approval;
	  FETCH c_vmi_replenishment_approval INTO l_vmi_replenishment_approval;
	  CLOSE c_vmi_replenishment_approval;

	  print_debug_info('    buyer contact name =  ' || l_buyer_name);
	  print_debug_info('    release approval flag =  ' || l_vmi_replenishment_approval);

	  SELECT msc_x_seller_role_s.NEXTVAL INTO l_seller_role_seq FROM dual;

	  -- start of set up the Workflow role for seller
	  l_seller_role_name := 'MSCX_SELLER_ROLE' || l_seller_role_seq;
	  l_seller_role_display_name := 'VMI Replenishment Approver';

	  -- check if the Workflow role already exists
	  OPEN c_wf_role_existing(l_seller_role_name);
	  FETCH c_wf_role_existing INTO l_seller_role_existing;
	  CLOSE c_wf_role_existing;

	  print_debug_info('    seller workflow role name = ' || l_seller_role_name);
	  IF (l_seller_role_existing <1) THEN -- Workflow row not exists
             BEGIN
		-- create a Ad Hoc Workflow role
		WF_DIRECTORY.createadhocrole
		  (
		   role_name => l_seller_role_name
		   , role_display_name => l_seller_role_display_name
 		   );
	      EXCEPTION
		WHEN OTHERS THEN
		   print_debug_info('    Error when creating seller workflow role = ' || sqlerrm);
	     END;
	  END IF;

	  --Commented out because we append a sequence to the role name
	  --to ensure uniqueness of the set of recipients.
	  /*
          BEGIN
	     -- remove previous WF users from the WF role first
	     WF_DIRECTORY.RemoveUsersFromAdHocRole
	       ( role_name => l_seller_role_name
		 );
	  EXCEPTION
	     WHEN OTHERS THEN
		print_debug_info('  vmi_replenish_wf:222b3: sqlerrm = ' || sqlerrm);
	  END;
	  */

	  -- add contact person name(s) of seller to the WF role
	  FOR seller_names
	    IN c_seller_name(
			     p_supplier_id
			     , p_supplier_site_id
			     , p_sr_instance_id
			     )
	    LOOP
	       print_debug_info('    seller contact name = ' || seller_names.name);
	       IF (seller_names.name IS NOT NULL) THEN
		  WF_DIRECTORY.adduserstoadhocrole
		    (
		     role_name => l_seller_role_name
		     , role_users => seller_names.name
		     );
	       END IF;
	    END LOOP;
	  -- end of set up the Workflow role for seller

	  -- check if need to send notification to both buyer and seller
	  IF (l_vmi_replenishment_approval = 'SUPPLIER_OR_BUYER') THEN
	     SELECT msc_x_vmi_role_s.NEXTVAL INTO l_vmi_role_seq FROM dual;

	     l_vmi_role_name := 'MSCX_VMI_ROLE' || l_vmi_role_seq;
	     l_vmi_role_display_name := 'VMI Replenishment Approver';

	     -- check if the Workflow role already exists
	     OPEN c_wf_role_existing
	       (
		l_vmi_role_name
		);
	     FETCH c_wf_role_existing INTO l_vmi_role_existing;
	     CLOSE c_wf_role_existing;

	     print_debug_info('    approver role name = ' || l_vmi_role_existing);

	     IF (l_vmi_role_existing <1) THEN -- Workflow row not exists
         BEGIN
		   -- create a Ad Hoc Workflow role
		   WF_DIRECTORY.createadhocrole
		     (
		      role_name => l_vmi_role_name
		      , role_display_name => l_vmi_role_display_name
		      );
		EXCEPTION
		   WHEN OTHERS THEN
		      print_debug_info('    Error when creating approver workflow role = ' || sqlerrm);
		END;
	     END IF;

	     --Commented out because we append a sequence to the role name
	     --to ensure uniqueness of the set of recipients.
	     /*
             BEGIN
		-- remove previous WF users from the WF role first
		WF_DIRECTORY.RemoveUsersFromAdHocRole
		  ( role_name => l_vmi_role_name
		    );
	     EXCEPTION
		WHEN OTHERS THEN
		   print_debug_info('  vmi_replenish_wf:222f: sqlerrm = ' || sqlerrm);
	     END;
	     */

	     -- add contact person name of buyer to the WF role
	     print_debug_info('    add buyer contact name to approver role, buyer name = ' || l_buyer_name);
	     IF (l_buyer_name IS NOT NULL) THEN
		WF_DIRECTORY.adduserstoadhocrole
		  (
		   role_name => l_vmi_role_name
		   , role_users => l_buyer_name
		   );
	     END IF;

	     -- add contact person name(s) of seller to the WF role
	     FOR seller_names
	       IN c_seller_name(
				p_supplier_id
				, p_supplier_site_id
				, p_sr_instance_id
				)
	       LOOP
	     print_debug_info('    add seller contact name to approver role, seller name = ' || seller_names.name);
		  IF (seller_names.name IS NOT NULL) THEN
		     WF_DIRECTORY.adduserstoadhocrole
		       (
			role_name => l_vmi_role_name
			, role_users => seller_names.name
			);
		  END IF;
	       END LOOP;
	       -- set the Workflow performer to the Workflow role

	       l_buyer_name := l_vmi_role_name;
	  END IF; -- l_vmi_replenishment_approval

	  OPEN c_customer_item_name(p_inventory_item_id);
	  FETCH c_customer_item_name INTO l_customer_item_name;
	  CLOSE c_customer_item_name;

	  OPEN c_company_name(OEM_COMPANY_ID);
	  FETCH c_company_name INTO l_customer_name;
	  CLOSE c_company_name;

	  OPEN c_company_site_name
	    (
	     OEM_COMPANY_ID
	     , l_sce_organization_id
	     );
	  FETCH c_company_site_name INTO l_customer_site_name;
	  CLOSE c_company_site_name;

	  OPEN c_company_name(l_sce_supplier_id);
	  FETCH c_company_name INTO l_supplier_name;
	  CLOSE c_company_name;

	  OPEN c_company_site_name
	    (
	     l_sce_supplier_id
	     , l_sce_supplier_site_id
	     );
	  FETCH c_company_site_name INTO l_supplier_site_name;
	  CLOSE c_company_site_name;

	  print_user_info('    customer item/customer/customer site/supplier/supplier site = ');
	  print_debug_info('      ' || l_customer_item_name
			   || '/' || l_customer_name
			   || '/' || l_customer_site_name
			   || '/' || l_supplier_name
			   || '/' || l_supplier_site_name
			   );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SELLER_ROLE'
	      , avalue   => l_seller_role_name
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'BUYER_ROLE'
	      , avalue   => l_buyer_name
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'CUSTOMER_ITEM_NAME'
	      , avalue   => l_customer_item_name
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'CUSTOMER_NAME'
	      , avalue   => l_customer_name
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'CUSTOMER_SITE_NAME'
	      , avalue   => l_customer_site_name
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SUPPLIER_NAME'
	      , avalue   => l_supplier_name
	      );

	  wf_engine.SetItemAttrText
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      , aname    => 'SUPPLIER_SITE_NAME'
	      , avalue   => l_supplier_site_name
	      );

	  print_debug_info('    start workflow process');

	  -- start Workflow process for item/org/supplier
	  wf_engine.StartProcess
	    ( itemtype => l_wf_type
	      , itemkey  => l_wf_key
	      );
    END IF;  -- end else delete old repl record
    print_user_info('    end of workflow process');

EXCEPTION
   WHEN OTHERS THEN
      print_debug_info('  Error when starting vmi workflow process= ' || sqlerrm);
      RAISE;
END vmi_replenish_wf;


-- This procedure will be called by the 'Create Replenishment' Workflow
-- activity and will create a VMI replenishment if there is a shortage
-- of supply
PROCEDURE vmi_replenish
  ( itemtype  in varchar2
    , itemkey   in varchar2
    , actid     in number
    , funcmode  in varchar2
    , resultout out nocopy varchar2
    ) IS
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
       l_old_rep_transaction_id NUMBER;
       l_old_order_quantity NUMBER;
       l_old_wf_key VARCHAR2(200);
       l_time_fence_end_date DATE;
       l_item_name VARCHAR2(100);
       l_item_description VARCHAR2(200);
       l_supplier_item_name VARCHAR2(100);
       l_customer_uom_code VARCHAR2(10);
       l_rounding_control_type NUMBER;
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
       l_processing_lead_time NUMBER;
       l_replenishment_method NUMBER;

lv_calendar_code    varchar2(14);
lv_instance_id      number;
l_offset_days       number;

       l_replenish_time_fence NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'REPLENISH_TIME_FENCE'
	   );

       l_auto_release_flag NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'AUTO_RELEASE_FLAG'
	   );

       l_inventory_item_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'INVENTORY_ITEM_ID'
	   );

       l_organization_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'ORGANIZATION_ID'
	   );

       l_plan_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'PLAN_ID'
	   );

       l_sr_instance_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SR_INSTANCE_ID'
	   );

       l_supplier_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SUPPLIER_ID'
	   );

       l_supplier_site_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SUPPLIER_SITE_ID'
	   );

       l_sce_organization_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SCE_ORGANIZATION_ID'
	   );

       l_sce_supplier_site_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SCE_SUPPLIER_SITE_ID'
	   );

       l_sce_supplier_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SCE_SUPPLIER_ID'
	   );

       l_customer_item_name VARCHAR2(100) :=
	 wf_engine.GetItemAttrText
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'CUSTOMER_ITEM_NAME'
	   );

       l_customer_name VARCHAR2(100) :=
	 wf_engine.GetItemAttrText
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'CUSTOMER_NAME'
	   );

       l_customer_site_name VARCHAR2(100) :=
	 wf_engine.GetItemAttrText
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'CUSTOMER_SITE_NAME'
	   );

       l_supplier_name VARCHAR2(100) :=
	 wf_engine.GetItemAttrText
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SUPPLIER_NAME'
	   );

       l_supplier_site_name VARCHAR2(100) :=
	 wf_engine.GetItemAttrText
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SUPPLIER_SITE_NAME'
	   );

       l_rep_transaction_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'REP_TRANSACTION_ID'
	   );

      -- get the sum of ASN quantity during the replenishment
      -- time frame, excluding those ASNs which are already
      -- pegged by Shippment Receipt
      CURSOR c_asn_quantity
	IS
	   SELECT SUM( DECODE( sd.publisher_id
			       , sd.supplier_id, sd.tp_quantity
			       , sd.primary_quantity
			       )
		       )
	     FROM msc_sup_dem_entries sd
	     WHERE sd.inventory_item_id =  l_inventory_item_id
	     AND sd.supplier_site_id = l_sce_supplier_site_id
	     AND sd.supplier_id = l_sce_supplier_id
	     AND sd.plan_id = l_plan_id
	     AND sd.publisher_order_type = ASN
	     AND sd.customer_id = OEM_COMPANY_ID
	     AND sd.customer_site_id = l_sce_organization_id
	     AND sd.RECEIPT_DATE <= l_time_fence_end_date
	     AND sd.vmi_flag = 1
	     ;

      -- get the latest allocated on hand quantity during the replenishment
      -- time window
      CURSOR c_allocated_onhand_quantity
	IS
	   SELECT sd.primary_quantity
	     FROM msc_sup_dem_entries sd
	     WHERE sd.inventory_item_id =  l_inventory_item_id
	     AND sd.publisher_site_id = l_sce_organization_id
	     AND sd.plan_id = l_plan_id
	     AND sd.publisher_order_type = ALLOCATED_ONHAND
	     AND sd.supplier_site_id = l_sce_supplier_site_id
	     AND sd.supplier_id = l_sce_supplier_id
	     AND sd.vmi_flag = 1
	     ORDER BY sd.key_date desc
	     ;

      -- check if there is already replenishment record exists
      CURSOR c_old_replenishment_row IS
	 SELECT sd.transaction_id, sd.primary_quantity
	   FROM msc_sup_dem_entries sd
	   WHERE sd.publisher_site_id = l_sce_organization_id
	   AND sd.inventory_item_id = l_inventory_item_id
	   AND sd.publisher_order_type = REPLENISHMENT
	   AND sd.plan_id = l_plan_id
	   AND sd.supplier_id = l_sce_supplier_id
	   AND sd.supplier_site_id = l_sce_supplier_site_id
	   ;

      -- get the shipment receipt quantity
      CURSOR c_shipment_receipt_quantity IS
	 SELECT SUM(sd.primary_quantity)
	   FROM msc_sup_dem_entries sd
	   WHERE sd.publisher_site_id = l_sce_organization_id
	   AND sd.inventory_item_id = l_inventory_item_id
	   AND sd.publisher_order_type = SHIPMENT_RECEIPT
	   AND sd.plan_id = l_plan_id
	   AND sd.supplier_id = l_sce_supplier_id
	   AND sd.supplier_site_id = l_sce_supplier_site_id
	   AND sd.RECEIPT_DATE <= SYSDATE
	   AND sd.vmi_flag = 1
	   ;

      -- get the requisition quantity
      CURSOR c_requisition_quantity IS
	 SELECT SUM(sd.primary_quantity)
	   FROM msc_sup_dem_entries sd
	   WHERE sd.publisher_site_id = l_sce_organization_id
	   AND sd.inventory_item_id = l_inventory_item_id
	   AND sd.publisher_order_type = REQUISITION
	   AND sd.plan_id = l_plan_id
	   AND sd.supplier_id = l_sce_supplier_id
	   AND sd.supplier_site_id = l_sce_supplier_site_id
--	   AND sd.receipt_date BETWEEN SYSDATE AND l_time_fence_end_date
	   AND TRUNC(sd.receipt_date) <= TRUNC(l_time_fence_end_date)
	   AND sd.vmi_flag = 1
	   ;

      -- get the purchase order quantity
      CURSOR c_po_quantity IS
	 SELECT SUM(sd.primary_quantity)
	   FROM msc_sup_dem_entries sd
	   WHERE sd.publisher_site_id = l_sce_organization_id
	   AND sd.inventory_item_id = l_inventory_item_id
	   AND sd.publisher_order_type = PURCHASE_ORDER
	   AND sd.plan_id = l_plan_id
	   AND sd.supplier_id = l_sce_supplier_id
	   AND sd.supplier_site_id = l_sce_supplier_site_id
--	   AND sd.RECEIPT_DATE BETWEEN SYSDATE AND l_time_fence_end_date
	   AND TRUNC(sd.RECEIPT_DATE) <= TRUNC(l_time_fence_end_date)
	   AND sd.vmi_flag = 1
	   ;

      -- get publisher order type meaning
      CURSOR c_publisher_order_type_desc
	(
	 p_publisher_order_type IN NUMBER
	 ) IS
	    SELECT ml.meaning
	      FROM mfg_lookups ml
	      WHERE lookup_type = 'MSC_X_ORDER_TYPE'
	      AND ml.lookup_code = p_publisher_order_type
	      ;

      -- get (master) item name
      CURSOR c_item_name
	(
	 p_inventory_item_id IN NUMBER
	 ) IS
	    SELECT mi.item_name, mi.description
	      FROM msc_items mi
	      WHERE mi.inventory_item_id = p_inventory_item_id
	      ;

      -- get supplier item name
      CURSOR c_supplier_item_name
	(
	 p_inventory_item_id IN NUMBER
	 , p_plan_id IN NUMBER
	 , p_organization_id IN NUMBER
	 , p_supplier_id IN NUMBER
	 , p_supplier_site_id IN NUMBER
	 , p_sr_instance_id IN NUMBER
	 ) IS
	    SELECT mis.supplier_item_name
	      FROM msc_item_suppliers mis
	      WHERE mis.inventory_item_id = p_inventory_item_id
	      AND mis.organization_id = p_organization_id
	      AND mis.supplier_id = p_supplier_id
	      AND mis.supplier_site_id = p_supplier_site_id
	      AND mis.sr_instance_id = p_sr_instance_id
	      AND mis.plan_id = p_plan_id
	      ORDER BY using_organization_id DESC
	      ;

      CURSOR c_asl_attributes
	(
	 p_inventory_item_id IN NUMBER
	 , p_plan_id IN NUMBER
	 , p_organization_id IN NUMBER
	 , p_supplier_id IN NUMBER
	 , p_supplier_site_id IN NUMBER
	 , p_sr_instance_id IN NUMBER
	 ) IS
	    SELECT mis.fixed_lot_multiplier
	      , mis.minimum_order_quantity
	      , mis.maximum_order_quantity
	      , mis.min_minmax_quantity
	      , mis.max_minmax_quantity
          , mis.min_minmax_days
          , mis.max_minmax_days
          , mis.fixed_order_quantity
          , mvt.average_daily_demand
          , mis.vmi_refresh_flag
          , mis.processing_lead_time
          , mis.replenishment_method
	      FROM msc_item_suppliers mis
	      , msc_vmi_temp mvt
	      WHERE mis.inventory_item_id = p_inventory_item_id
	      AND mis.organization_id = p_organization_id
	      AND mis.plan_id = p_plan_id
	      AND mis.sr_instance_id = p_sr_instance_id
	      AND mis.supplier_site_id = p_supplier_site_id
	      AND mis.supplier_id = p_supplier_id
	      and mvt.plan_id = mis.plan_id
	      and mvt.inventory_item_id = mis.inventory_item_id
	      and mvt.organization_id = mis.organization_id
	      and mvt.sr_instance_id = mis.sr_instance_id
	      and mvt.supplier_site_id = mis.supplier_site_id
	      and mvt.supplier_id = mis.supplier_id
	      and NVL(mvt.using_organization_id, -1) = NVL(mis.using_organization_id, -1)
          and mvt.vmi_type = 1 -- supplier facing vmi
	      ORDER BY mis.using_organization_id DESC
	      ;

     CURSOR c_item_attributes
	 (
	   p_inventory_item_id IN NUMBER
	 , p_plan_id IN NUMBER
	 , p_organization_id IN NUMBER
	 , p_sr_instance_id IN NUMBER
	 ) IS
      SELECT si.uom_code
           , si.rounding_control_type
        FROM msc_system_items si
        WHERE si.inventory_item_id = l_inventory_item_id
        AND si.organization_id = l_organization_id
        AND si.plan_id = l_plan_id
        AND si.sr_instance_id = l_sr_instance_id
        ;

BEGIN
   print_user_info('    start of calculating/creating replenishment');
   print_debug_info('    replenishment transaction id/time fence muptiplier = '
            || l_rep_transaction_id
		    || '/' || l_replenish_time_fence
		    );
   print_debug_info('    item/plan/instance/org/supplier/supplier site/cp org/cp supplier/cp supplier site = ');
   print_debug_info('      ' || l_inventory_item_id
		    || '/' || l_plan_id
		    || '/' || l_sr_instance_id
		    || '/' || l_organization_id
		    || '/' || l_supplier_id
		    || '/' || l_supplier_site_id
		    || '/' || l_sce_organization_id
		    || '/' || l_sce_supplier_id
		    || '/' || l_sce_supplier_site_id
		    );
   print_user_info('    customer item/customer/customer site/supplier/supplier site = ');
   print_user_info('      '|| l_customer_item_name
		    || '/' || l_customer_name
		    || '/' || l_customer_site_name
		    || '/' || l_supplier_name
		    || '/' || l_supplier_site_name
		    );

   IF funcmode = 'RUN' THEN
      OPEN c_publisher_order_type_desc(REPLENISHMENT);
      FETCH c_publisher_order_type_desc INTO l_publisher_order_type_desc;
      CLOSE c_publisher_order_type_desc;

      OPEN c_item_name(l_inventory_item_id);
      FETCH c_item_name INTO l_item_name, l_item_description;
      CLOSE c_item_name;

   print_user_info('    item name/item description = ' || l_item_name || '/' ||l_item_description);

     wf_engine.SetItemAttrText
	( itemtype => itemtype
	  , itemkey  => itemkey
	  , aname    => 'ITEM_NAME'
	  , avalue   => l_item_name
	  );

      wf_engine.SetItemAttrText
	( itemtype => itemtype
	  , itemkey  => itemkey
	  , aname    => 'ITEM_DESCRIPTION'
	  , avalue   => l_item_description
	  );

      OPEN c_supplier_item_name
	(
	 l_inventory_item_id
	 , l_plan_id
	 , l_organization_id
	 , l_supplier_id
	 , l_supplier_site_id
	 , l_sr_instance_id
	 );
      FETCH c_supplier_item_name INTO l_supplier_item_name;
      CLOSE c_supplier_item_name;

      wf_engine.SetItemAttrText
	( itemtype => itemtype
	  , itemkey  => itemkey
	  , aname    => 'SUPPLIER_ITEM_NAME'
	  , avalue   => l_supplier_item_name
	  );

     print_user_info('    supplier item name/order type description = '
          || l_supplier_item_name || '/' ||l_publisher_order_type_desc);

      OPEN c_item_attributes
     (
	   l_inventory_item_id
	 , l_plan_id
	 , l_organization_id
	 , l_sr_instance_id
	 );
      FETCH c_item_attributes
        INTO l_customer_uom_code
           , l_rounding_control_type
           ;
      CLOSE c_item_attributes;

      print_user_info('    customer uom code/rounding control type = '
		       || l_customer_uom_code
               || '/' || l_rounding_control_type
		       );

      -- we always use MIN-MAX planning for all VMI items, regardless of  l_inventory_planning_code,
      -- so we do not check the value of l_inventory_planning_code

      OPEN c_asl_attributes
	(
	 l_inventory_item_id
	 , l_plan_id
	 , l_organization_id
	 , l_supplier_id
	 , l_supplier_site_id
	 , l_sr_instance_id
	 );
      FETCH c_asl_attributes
	INTO l_fixed_lot_multiplier
	, l_minimum_order_quantity
	, l_maxmum_order_quantity
	, l_min_minmax_quantity
	, l_max_minmax_quantity
          , l_min_minmax_days
          , l_max_minmax_days
          , l_fixed_order_quantity
          , l_average_daily_demand
          , l_vmi_refresh_flag
          , l_processing_lead_time
          , l_replenishment_method
	;
      CLOSE c_asl_attributes;

      print_user_info('    minimum quantity/maxmum quantity = '
               || l_min_minmax_quantity
		       || '/' || l_max_minmax_quantity
		       );
      print_user_info('    minimum order quantity/maxmum order quantity/fixed lot multiplier = '
               || l_minimum_order_quantity
		       || '/' || l_maxmum_order_quantity
		       || '/' || l_fixed_lot_multiplier
		       );
      print_user_info('    minimum days/maxmum days/replenishment method = '
               || l_min_minmax_days
		       || '/' || l_max_minmax_days
               || '/' || l_replenishment_method
		       );
      print_user_info('    vmi refresh flag/average daily demand = '
               || l_vmi_refresh_flag
		       || '/' || l_average_daily_demand
		       );
      print_user_info('    fixed order quantity/processing lead time = '
               || l_fixed_order_quantity
		       || '/' || l_processing_lead_time
		       );

      l_intransit_lead_time := MSC_X_UTIL.GET_CUSTOMER_TRANSIT_TIME
            ( p_publisher_id => l_sce_supplier_id,          -- supplier_id
              p_publisher_site_id => l_sce_supplier_site_id,     -- supplier_site_id
              p_customer_id => OEM_COMPANY_ID,           -- OEM
              p_customer_site_id => l_sce_organization_id
            );      -- OEM org

      l_full_lead_time := NVL(l_processing_lead_time, 0) + NVL(l_intransit_lead_time, 0);
      -- calculate the end date of the replenish time window

	  begin

		  /* Call the API to get the correct Calendar */
		 msc_x_util.get_calendar_code(
				     l_supplier_id,
				     l_supplier_site_id,
				     1,                 --- OEM
				     l_organization_id, -- oem Org
				     lv_calendar_code,
				     lv_instance_id,
				     2,                -- TP ids are in terms of APS
				     l_sr_instance_id,
				     CUSTOMER_IS_OEM
				     );
		 print_debug_info(' Calendar/sr_instance_id : ' || lv_calendar_code||'/'||lv_instance_id);

                l_offset_days := NVL(l_replenish_time_fence * l_full_lead_time, 0);
		l_time_fence_end_date := MSC_CALENDAR.DATE_OFFSET(
					  lv_calendar_code -- arg_calendar_code IN varchar2,
					, lv_instance_id -- arg_instance_id IN NUMBER,
					, SYSDATE -- arg_date IN DATE,
					, l_offset_days -- arg_offset IN NUMBER
					, 99999  --arg_offset_type
					);
	  exception
		when others then
		    print_user_info('Error in getting the Calendar Code.');
		    print_user_info(SQLERRM);
	            l_time_fence_end_date := SYSDATE +
				     NVL(l_replenish_time_fence * l_full_lead_time, 0);
	  end;

      print_user_info('    time fence end date/intransit lead time/total lead time = '
        || l_time_fence_end_date
        || '/' || l_intransit_lead_time
        || '/' || l_full_lead_time
        );

      -- check if the replenishment record already exists
      OPEN c_old_replenishment_row;
      FETCH c_old_replenishment_row
        INTO l_old_rep_transaction_id, l_old_order_quantity;

      l_replenishment_row := c_old_replenishment_row%ROWCOUNT;
      CLOSE c_old_replenishment_row;

      print_debug_info('    old transaction id/old order quantity/old replenishment row = '
               || l_old_rep_transaction_id
		       || '/' || l_old_order_quantity
		       || '/' || l_replenishment_row
		       );

      OPEN c_asn_quantity;
      FETCH c_asn_quantity
	   INTO l_asn_quantity;
      CLOSE c_asn_quantity;

      OPEN c_allocated_onhand_quantity;
      FETCH c_allocated_onhand_quantity
        INTO l_allocated_onhand_quantity;
      CLOSE c_allocated_onhand_quantity;

      OPEN c_shipment_receipt_quantity;
      FETCH c_shipment_receipt_quantity
	INTO l_shipment_receipt_quantity;
      CLOSE c_shipment_receipt_quantity;

      OPEN c_requisition_quantity;
      FETCH c_requisition_quantity
	INTO l_requisition_quantity;
      CLOSE c_requisition_quantity;

      OPEN c_po_quantity;
      FETCH c_po_quantity
	INTO l_po_quantity;
      CLOSE c_po_quantity;

      print_user_info('    asn/onhand/receipt/req/po = '
               || l_asn_quantity
		       || '/' || l_allocated_onhand_quantity
		       || '/' || l_shipment_receipt_quantity
		       || '/' || l_requisition_quantity
		       || '/' || l_po_quantity
		       );

      -- we are in the process of changing the formula to calculate total supply,
      -- the follwoing statement may not be accurate.

      -- only count on hand and asn quantity as supply
      -- user will manually change 'requisition' to 'on hand'.
      -- 1. when allocated on hand <> 0
      -- supply = (latest allocated on hand)
      --        + asn + shipment_receipt + req + po.
      -- 2. when allocated on hand = 0
      -- supply = (lastest unallocated on hand)*(allocation_percent)
      --        + (total asn).

      l_supply := NVL(l_allocated_onhand_quantity, 0)
	+ NVL(l_asn_quantity, 0)
	+ NVL(l_shipment_receipt_quantity, 0)
	+ NVL(l_requisition_quantity, 0)
	+ NVL(l_po_quantity, 0)
	;

      print_debug_info('    total supply = ' || l_supply);

      IF (l_replenishment_method = 1 OR l_replenishment_method = 3) THEN
        l_supply_shortage := l_min_minmax_quantity - l_supply;
      ELSE
        l_supply_shortage := l_min_minmax_days * l_average_daily_demand - l_supply;
        l_min_minmax_quantity := l_min_minmax_days * l_average_daily_demand;
        l_max_minmax_quantity := l_max_minmax_days * l_average_daily_demand;

      END IF;

      print_debug_info('    l_supply_shortage = ' || l_supply_shortage);

      IF l_supply_shortage > 0 THEN -- if there is a supply shortage
	 -- apply order modifiers - max, min and fixed lot multiplier
        IF (l_replenishment_method = 3 OR l_replenishment_method = 4) THEN
          l_order_quantity := l_fixed_order_quantity;
        ELSE
          IF (l_replenishment_method = 2) THEN
    	    l_order_quantity := l_max_minmax_days * l_average_daily_demand - l_supply;
          ELSIF (l_replenishment_method = 1) THEN
 	        l_order_quantity := l_max_minmax_quantity - l_supply;
          END IF; -- if l_replenishment_method

          l_order_quantity := GREATEST(NVL(l_minimum_order_quantity, l_order_quantity), l_order_quantity);
	      l_order_quantity := LEAST(NVL(l_maxmum_order_quantity, l_order_quantity), l_order_quantity);

          IF (l_fixed_lot_multiplier IS NOT NULL AND l_fixed_lot_multiplier <> 0) THEN
            l_order_quantity := l_fixed_lot_multiplier
              * CEIL(l_order_quantity/l_fixed_lot_multiplier);
	      END IF; -- if fixed lot multiplier
       END IF; -- if fixed order quantity

       IF (l_rounding_control_type = 1) THEN

         l_order_quantity := CEIL(l_order_quantity);
       END IF;

	 print_debug_info('    l_order_quantity = ' || l_order_quantity);
       IF (l_order_quantity < 0) OR (l_order_quantity IS NULL) THEN
         l_order_quantity := 0;
       END IF;

	 IF (l_replenishment_row = 0 ) THEN
	    print_debug_info('    no old replenishment record, create a new one');

	    -- no replenishment order record exists for this item/org/supplier,
	    -- create a new record
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
	       , inventory_item_id
	       , comments
	       , publisher_order_type
	       , supplier_id
	       , supplier_name
	       , supplier_site_id
	       , supplier_site_name
	       , customer_id
	       , customer_name
	       , customer_site_id
	       , customer_site_name
	      , line_code
	      , bucket_type
	      , order_number
	      , end_order_number
	      , new_dock_date
	      , posting_party_id
	      , new_ship_date
	      , new_order_placement_date
	      , release_number
	      , line_number
	      , end_order_rel_number
	      , end_order_line_number
	      , publisher_address_id
	      , carrier_code
	      , vehicle_number
	      , container_type
	      , container_qty
	      , tracking_number
	      , end_order_type
	      , end_order_publisher_id
	      , ship_to_address
	      , ship_from_party_id
	      , ship_to_party_id
	      , ship_to_party_address_id
	      , ship_from_party_address_id
	      , owning_site_id
	      , owning_site_name
	      , end_order_publisher_site_id
	      , end_order_publisher_site_name
	      , end_order_publisher_name
	      , item_name
	      , owner_item_name
	      , customer_item_name
	      , supplier_item_name
	      , publisher_order_type_desc
	      , tp_order_type_desc
	      , designator
	      , category_name
	      , context
	      , unit_number
	      , ship_method
	      , project_number
	      , task_number
	      , planning_group
	      , ship_from_address
	      , publisher_address
	      , customer_address
	      , supplier_address
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
	      , posting_party_name
	      , new_schedule_end_date
	      , attachment_url
	      , promise_ship_date
	      , inventory_status
	      , release_status
	      , last_refresh_number
	      , serial_number
	      , bill_of_lading_number
	      , bucket_type_desc
	      , ship_from_party_site_id
	      , ship_from_party_name
	      , ship_from_party_site_name
	      , ship_to_party_site_id
	      , ship_to_party_name
	      , ship_to_party_site_name
	      , receipt_date
	      , quantity_in_process
	      , implemented_quantity
	      , vmi_flag
          , item_description
          , customer_item_description
          , supplier_item_description
          , owner_item_description
	      ) VALUES
	      (
	       l_rep_transaction_id
	       , l_plan_id -- plan_id
	       , l_sr_instance_id -- sr_instance_id
	       , OEM_COMPANY_ID -- publisher_id
	       , l_sce_organization_id -- publisher_site_id
	       , l_customer_name -- publisher_name
	       , l_customer_site_name -- publisher_site_name
	       , SYSDATE -- new_schedule_date
	       , l_inventory_item_id -- inventory_item_id
	       , null -- comments
	       , REPLENISHMENT -- publisher_order_type
	       , l_sce_supplier_id -- supplier_id
	       , l_supplier_name -- supplier_name
	       , l_sce_supplier_site_id -- supplier_site_id
	      , l_supplier_site_name -- supplier_site_name
	      , OEM_COMPANY_ID -- customer_id
	      , l_customer_name -- customer_name
	      , l_sce_organization_id -- customer_site_id
	      , l_customer_site_name -- customer_site_name
	      , null -- line_code
	      , null -- bucket_type
	      , null -- order_number
	      , null -- end_order_number
	      , null -- new_dock_date
	      , null -- posting_party_id
	      , null -- new_ship_date
	      , SYSDATE -- new_order_placement_date
	      , null -- release_number
	      , null -- line_number
	      , null -- end_order_rel_number
	      , null -- end_order_line_number
	      , null -- publisher_address_id
	      , null -- carrier_code
	      , null -- vehicle_number
	      , null -- container_type
	      , null -- container_qty
	      , null -- tracking_number
	      , null -- end_order_type
	      , null -- end_order_publisher_id
	      , null -- ship_to_address
	      , null -- ship_from_party_id
	      , null -- ship_to_party_id
	      , null -- ship_to_party_address_id
	      , null -- ship_from_party_address_id
	      , l_supplier_site_id -- owning_site_id
	      , null -- owning_site_name
	      , null -- end_order_publisher_site_id
	      , null -- end_order_publisher_site_name
	      , null -- end_order_publisher_name
	      , l_item_name -- item_name
	      , l_customer_item_name -- owner_item_name
	      , l_customer_item_name -- customer_item_name
	      , l_supplier_item_name -- supplier_item_name
	      , l_publisher_order_type_desc -- publisher_order_type_desc
	      , null -- tp_order_type_desc
	      , null -- designator
	      , null -- category_name
	      , null -- context
	      , null -- unit_number
	      , null -- ship_method
	      , null -- project_number
	      , null -- task_number
	      , null -- planning_group
	      , null -- ship_from_address
	      , null -- publisher_address
	      , null -- customer_address
	      , null -- supplier_address
	      , FND_GLOBAL.CONC_REQUEST_ID -- request_id
	      , FND_GLOBAL.CONC_PROGRAM_ID -- program_id
	      , FND_GLOBAL.PROG_APPL_ID -- program_application_id
	      , null -- program_update_date
	      , FND_GLOBAL.USER_ID -- created_by
	      , SYSDATE -- creation_date
	      , FND_GLOBAL.USER_ID -- last_updated_by
	      , SYSDATE -- last_update_date
	      , FND_GLOBAL.LOGIN_ID -- last_update_login
	      , l_customer_uom_code -- l_customer_uom_code
	      , l_order_quantity -- l_customer_order_quantity
	      , l_customer_uom_code -- primary_uom
	      , l_order_quantity -- l_customer_order_quantity
	      , l_customer_uom_code -- tp_uom_code
	      , l_order_quantity -- tp_quantity
	      , l_item_description -- pub_item_description
	      , l_item_description -- tp_item_description
	      , null -- posting_party_name
	      , null -- new_schedule_end_date
	      , null -- attachment_url
	      , null -- promise_ship_date
	      , null -- inventory_status
	      , UNRELEASED -- release_status
	      , null -- l_last_refresh_number
	      , null -- serial_number
	      , null -- bill_of_lading_number
	      , null -- bucket_type_desc
	      , null -- ship_from_party_site_id
	      , null -- ship_from_party_name
	      , null -- ship_from_party_site_name
	      , null -- ship_to_party_site_id
	      , null -- ship_to_party_name
	      , null -- ship_to_party_site_name
	      , l_time_fence_end_date -- receipt_date
	      , 0 -- quantity_in_process
	      , 0 -- implemented_quantity
	      , 1 -- vmi_flag
          , l_item_description -- item_description
          , l_item_description -- customer_item_description
          , l_item_description -- supplier_item_description
          , l_item_description -- owner_item_description
	      );
	    print_debug_info('    new replenishment record has been created');
	  ELSIF (l_replenishment_row <> 0) THEN -- replenishment record exists
	    print_debug_info('    old replenishment exists');

	    -- find the WF key for the previous unclosed Workflow process
	    l_old_wf_key := TO_CHAR(l_inventory_item_id)
	      || '-' || l_sce_organization_id
	      || '-' || l_sce_supplier_id
	      || '-' || l_sce_supplier_site_id
	      || '-' || TO_CHAR(l_old_rep_transaction_id)
	      ;

	    print_debug_info('    old workflow key = ' || l_old_wf_key);

	    -- abort previous unclosed Workflow process for this item/org/supplier
            BEGIN
	       -- get the status of the previous open Workflow process
	       wf_engine.ItemStatus
		 ( itemtype => 'MSCXVMIR'
		   , itemkey  => l_old_wf_key
		   , status    => l_wf_status
		   , result   => l_wf_result
		   );

	       print_debug_info('    status of old workflow process = ' || l_wf_status);
	       IF (l_wf_status = 'ACTIVE') THEN
		  print_debug_info('    abort old workflow process');
		  wf_engine.AbortProcess
		    ( itemtype => 'MSCXVMIR'
		      , itemkey  => l_old_wf_key
		      );
	       END IF;

	    EXCEPTION
	       WHEN OTHERS THEN
		  print_debug_info('    Error when checking status or aborting old workfow process = ' || sqlerrm);
	    END;

	    -- since replenishment order record exists for this item/org/supplier/supplier site,
	    -- update the existing record
	    UPDATE msc_sup_dem_entries sd
	      SET
	      transaction_id = l_rep_transaction_id
	      , uom_code = l_customer_uom_code
	      , quantity = l_order_quantity -- l_customer_order_quantity
	      , primary_uom = l_customer_uom_code
	      , primary_quantity = l_order_quantity -- l_customer_order_quantity
	      , tp_uom_code = l_customer_uom_code -- l_supplier_uom_code
	      , tp_quantity = l_order_quantity -- l_supplier_order_quantity
	      , sd.new_schedule_date = SYSDATE
	      , sd.release_status = UNRELEASED
	      , sd.new_dock_date = l_time_fence_end_date
	      , sd.publisher_name = l_customer_name
	      , sd.publisher_site_name = l_customer_site_name
	      , sd.supplier_name = l_supplier_name
	      , sd.supplier_site_name = l_supplier_site_name
	      , sd.receipt_date = l_time_fence_end_date
	      , sd.quantity_in_process = 0
	      , sd.implemented_quantity = 0
	      , sd.last_updated_by = FND_GLOBAL.USER_ID
	      , sd.last_update_date = SYSDATE
	      , sd.last_update_login = FND_GLOBAL.LOGIN_ID
	      , sd.customer_id = OEM_COMPANY_ID
	      , sd.customer_name = l_customer_name
	      , sd.customer_site_id = l_sce_organization_id
	      , sd.customer_site_name = l_customer_site_name
	      , sd.new_order_placement_date = SYSDATE
	      , sd.publisher_order_type_desc = l_publisher_order_type_desc
          , sd.vmi_flag = 1
          , sd.pub_item_description = l_item_description
          , sd.tp_item_description = l_item_description
          , sd.item_description = l_item_description
          , sd.customer_item_description = l_item_description
          , sd.supplier_item_description = l_item_description
          , sd.owner_item_description = l_item_description
	      WHERE sd.publisher_site_id = l_sce_organization_id
	      AND sd.inventory_item_id = l_inventory_item_id
	      AND sd.publisher_order_type = REPLENISHMENT
	      AND sd.plan_id = l_plan_id
	      AND sd.supplier_site_id = l_sce_supplier_site_id
	      AND sd.supplier_id = l_sce_supplier_id
	      ;
	    print_debug_info('    updated old replenishment record');

	 END IF; -- IF (l_replenishment_row <> 0)

	 print_debug_info('    set workflow item attributes');

	 wf_engine.SetItemAttrNumber
	   ( itemtype => itemtype
	     , itemkey  => itemkey
	     , aname    => 'ORDER_QUANTITY'
	     , avalue   => l_order_quantity
	     );

	 wf_engine.SetItemAttrNumber
	   ( itemtype => itemtype
	     , itemkey  => itemkey
	     , aname    => 'ALLOCATED_ONHAND_QUANTITY'
	     , avalue   => l_allocated_onhand_quantity
	     );

	 wf_engine.SetItemAttrNumber
	   ( itemtype => itemtype
	     , itemkey  => itemkey
	     , aname    => 'MIN_MINMAX_QUANTITY'
	     , avalue   => l_min_minmax_quantity
	     );

	 wf_engine.SetItemAttrNumber
	   ( itemtype => itemtype
	     , itemkey  => itemkey
	     , aname    => 'MAX_MINMAX_QUANTITY'
	     , avalue   => l_max_minmax_quantity
	     );

	 wf_engine.SetItemAttrText
	   ( itemtype => itemtype
	     , itemkey  => itemkey
	     , aname    => 'CUSTOMER_UOM_CODE'
	     , avalue   => l_customer_uom_code
	     );

	 -- if the supply_shortage is negative, no need to do replenishment,
	 -- abort the Workflow process
       ELSE
       -- ELSIF (l_supply_shortage <= 0) THEN
	    print_debug_info('    no supply shortage, abort the current workflow process');
	    wf_engine.AbortProcess
	      ( itemtype => itemtype
		, itemkey  => itemkey
		);

	    print_debug_info('    current workflow process aborted');

	    IF (l_replenishment_row <> 0) THEN -- replenishment record exists
	       DELETE FROM msc_sup_dem_entries sd
		 WHERE sd.publisher_site_id = l_sce_organization_id
		 AND sd.inventory_item_id = l_inventory_item_id
		 AND sd.publisher_order_type = REPLENISHMENT
		 AND sd.plan_id = l_plan_id
		 AND sd.supplier_site_id = l_sce_supplier_site_id
		 AND sd.supplier_id = l_sce_supplier_id
		 ;
	       print_debug_info('    no supply shortage, old replenishment record deleted');
	    END IF;
      END IF; -- l_supply_shortage = 0

      print_debug_info('    replenishment process completed');

      resultout := 'COMPLETE:vmi_replenish_run';
      print_user_info('    End of calculating/creating replenishment');
      RETURN;
   END IF; -- if "RUN"

   IF funcmode = 'CANCEL' THEN
     resultout := 'COMPLETE:vmi_replenish_cancel';
     print_user_info('    replenishment process canceled');
     RETURN;
   END IF;

   IF funcmode = 'TIMEOUT' THEN
     resultout := 'COMPLETE:vmi_replenish_timeout';
     print_user_info('    replenishment process timed out');
     RETURN;
   END IF;

EXCEPTION
   WHEN others THEN
      print_user_info('    Error during replenish process = ' || sqlerrm);
      wf_core.context('MSC_X_REPLENISH', 'vmi_replenish', itemtype, itemkey, actid, funcmode);
      RAISE;
END vmi_replenish;


-- This procedure will be called by the 'Release Replenishment' Workflow
-- activity and will create a VMI requsition if there is a shortage
-- of supply
PROCEDURE vmi_release
  ( itemtype  in varchar2
    , itemkey   in varchar2
    , actid     in number
    , funcmode  in varchar2
    , resultout out nocopy varchar2
    ) IS
       l_plan_refresh_number NUMBER;
       l_header_id NUMBER;

       l_return_code VARCHAR2(100);
       l_source_system_type VARCHAR2(100);
       l_source_system_name VARCHAR2(100);
       l_err_buf VARCHAR2(100);
       l_curr_return_code VARCHAR2(100);
       l_org_instance VARCHAR2(100);
       l_forecast_name VARCHAR2(100);
       l_updated_return_code VARCHAR2(100);
       l_owning_site_id VARCHAR2(100);
       l_owning_instance NUMBER;
       l_line_number NUMBER;
       l_suplnstatus VARCHAR2(100);
       l_description VARCHAR2(100);
       l_customer_name VARCHAR2(100);
       l_error_msg VARCHAR2(100);
       l_row_status VARCHAR2(100);
       l_mode VARCHAR2(100);
       l_curr_err_buf VARCHAR2(100);
       l_updated_err_buf VARCHAR2(100);
       l_po_group_by_name VARCHAR2(10);
       l_fnd_request_id NUMBER;
       l_sql_statement VARCHAR2(400);
       l_dblink VARCHAR2(128);
       l_loaded_reqs NUMBER;
       l_user_name         VARCHAR2(100):= NULL;
       l_resp_name         VARCHAR2(100):= NULL;
       l_application_name  VARCHAR2(240):= NULL;
       l_user_id           NUMBER;
       l_resp_id           NUMBER;
       l_application_id    NUMBER;
	   l_instance_id	   NUMBER;
	   l_instance_code VARCHAR2(100);
	   l_a2m_dblink VARCHAR2(100);

       l_replenish_time_fence NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'REPLENISH_TIME_FENCE'
	   );

       l_auto_release_flag NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'AUTO_RELEASE_FLAG'
	   );

       l_inventory_item_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'INVENTORY_ITEM_ID'
	   );

       l_organization_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'ORGANIZATION_ID'
	   );

       l_plan_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'PLAN_ID'
	   );

       l_sr_instance_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SR_INSTANCE_ID'
	   );

       l_supplier_site_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SUPPLIER_SITE_ID'
	   );

       l_supplier_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SUPPLIER_ID'
	   );

       l_order_quantity NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'ORDER_QUANTITY'
	   );

       l_customer_uom_code VARCHAR2(100) :=
	 wf_engine.GetItemAttrText
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'CUSTOMER_UOM_CODE'
	   );

       l_rep_transaction_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'REP_TRANSACTION_ID'
	   );

       l_sce_supplier_site_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SCE_SUPPLIER_SITE_ID'
	   );

       l_sce_supplier_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SCE_SUPPLIER_ID'
	   );

       l_sce_organization_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SCE_ORGANIZATION_ID'
	   );

       l_employee_id number;

BEGIN
   print_user_info('  Start of vmi release process');
   print_debug_info('    replenishment transaction id/time fence muptiplier = '
            || l_rep_transaction_id
		    || '/' || l_replenish_time_fence
		    );
   print_debug_info('    item/plan/instance/org/supplier/supplier site/cp org/cp supplier/cp supplier site = ');
   print_debug_info('      ' || l_inventory_item_id
		    || '/' || l_plan_id
		    || '/' || l_sr_instance_id
		    || '/' || l_organization_id
		    || '/' || l_supplier_id
		    || '/' || l_supplier_site_id
		    || '/' || l_sce_organization_id
		    || '/' || l_sce_supplier_id
		    || '/' || l_sce_supplier_site_id
		    );
   print_user_info('    customer item/customer/customer site/supplier/supplier site = ');
/*
   print_user_info('        '|| l_customer_item_name
		    || '/' || l_customer_name
		    || '/' || l_customer_site_name
		    || '/' || l_supplier_name
		    || '/' || l_supplier_site_name
		    );
*/

   IF funcmode = 'RUN' THEN
      IF (l_order_quantity > 0) THEN
  	     print_debug_info('    order quantity = ' || l_order_quantity
			  );

	 SELECT
	   FND_GLOBAL.USER_ID,
	   FND_GLOBAL.USER_NAME,
	   FND_GLOBAL.RESP_NAME,
	   FND_GLOBAL.APPLICATION_NAME
	   INTO l_user_id,
	   l_user_name,
	   l_resp_name,
	   l_application_name
	   FROM dual;

	 print_debug_info('    user ID/user name/responsibility/application = '
              || l_user_id
			  || '/' || l_user_name
			  || '/' || l_resp_name
			  || '/' || l_application_name
			  );

         begin
	    select mp.employee_id
	      into l_employee_id
	      from msc_system_items si,
	      msc_planners mp
	      where si.organization_id = l_organization_id
	      and   si.inventory_item_id = l_inventory_item_id
	      and   si.plan_id = l_plan_id
	      and   si.sr_instance_id = l_sr_instance_id
	      and   mp.sr_instance_id = si.sr_instance_id
	      and   mp.organization_id = si.organization_id
	      and   mp.planner_code = si.planner_code;
	 exception
	    when others then
	       l_employee_id := null;
	 end;

	 print_debug_info('    employee id = ' || l_employee_id);

	 -- insert a row into msc_po_requisitions_interface with status = 'approved'
	 INSERT INTO msc_po_requisitions_interface
	   (
	    -- line_type_id -- Amount or Quantity based  (Bug #4589288)
	     last_updated_by
            , last_update_date
            , last_update_login
            , creation_date
            , created_by
            , item_id
            , quantity
            , need_by_date
            , interface_source_code
            , deliver_to_location_id
            , deliver_to_requestor_id
            , destination_type_code
            , preparer_id
            , source_type_code
            , authorization_status
            , uom_code
            , batch_id
            , charge_account_id
            , group_code
            , item_revision
            , destination_organization_id
            , autosource_flag
            , org_id
            , source_organization_id
            , suggested_vendor_id
            , suggested_vendor_site_id
            , suggested_vendor_site
            , project_id
            , task_id
    	    , end_item_unit_number
            , project_accounting_context
            , sr_instance_id
            , vmi_flag
	   )
	   SELECT
	  -- 1, -- Quantity based
	   si.last_updated_by,
	   SYSDATE, -- last_update_date
	   si.last_update_login,
	   SYSDATE, -- creation_date
	   l_user_id, -- created_by
	   si.sr_inventory_item_id, -- item_id
	   l_order_quantity, -- quantity
	   sd.receipt_date, -- need_by_date
	   'MSC', -- interface_source_code
	   tps2.sr_tp_site_id, -- deliver_to_location_id
	   l_employee_id, --mp.employee_id, -- deliver_to_requestor_id
	   'INVENTORY', -- destination_type_code
	   l_employee_id, --mp.employee_id, -- preparer_id
	   'VENDOR', -- source_type_code
	   'APPROVED', -- authorization_status
	   l_customer_uom_code, -- l_uom_code --si.uom_code,  --
	   NULL, -- batch_id
	   decode(si.inventory_asset_flag,
               'Y', tp.material_account,
               nvl(si.expense_account, tp.expense_account)),
	   si.inventory_item_id, -- group_code
	   si.revision, -- item_revision
	   si.organization_id, -- destination_organization_id
	   'P', -- autosource_flag
	  tp.operating_unit, -- org_id
	   NULL, -- source_organization_id
	   tplid.sr_tp_id,   -- suggested_vendor_id
	   tps.sr_tp_site_id, -- suggested_vendor_site_id
	   tps.tp_site_code, -- suggested_vendor_site
	   NULL, --sd.project_number, -- project_id
	   NULL, --sd.task_number, -- task_id
	   NULL, --sd.unit_number, -- end_item_unit_number
	   NULL, --DECODE(sd.project_number, NULL, 'N', 'Y'), -- project_accounting_context
	   si.sr_instance_id, -- sr_instance_id
	   1  -- vmi_flag
	   FROM msc_sup_dem_entries sd,
	   msc_system_items si,
	   msc_trading_partners tp,
	   msc_tp_id_lid tplid,
	   msc_trading_partner_sites tps,
	   msc_trading_partner_sites tps2
	   , MSC_TP_SITE_ID_LID mtsil
	   WHERE sd.transaction_id = l_rep_transaction_id -- l_req_transaction_id
	   AND sd.publisher_site_id = l_sce_organization_id
	   AND sd.inventory_item_id = l_inventory_item_id
	   AND sd.publisher_order_type = REPLENISHMENT
	   AND sd.plan_id = l_plan_id
	   AND sd.supplier_id = l_sce_supplier_id
	   AND sd.supplier_site_id = l_sce_supplier_site_id
	   AND si.organization_id = l_organization_id
	   AND si.inventory_item_id = sd.inventory_item_id
	   AND si.plan_id = sd.plan_id
	   AND si.sr_instance_id = l_sr_instance_id
	   AND tplid.tp_id = l_supplier_id
	   AND tplid.partner_type = 1
	   AND tplid.sr_instance_id = l_sr_instance_id
	   AND tps.partner_site_id = l_supplier_site_id
	   AND tps.partner_type = 1
	   AND tps.partner_id = tplid.tp_id
	   AND tps2.sr_tp_id = si.organization_id
	   AND tps2.sr_instance_id = l_sr_instance_id
	   AND tps2.partner_type = 3
	   AND tp.sr_tp_id = si.organization_id
           AND tp.sr_instance_id = l_sr_instance_id
	   AND tp.partner_type = 3
	   and mtsil.sr_instance_id = l_sr_instance_id
	   and mtsil.tp_site_id = l_supplier_site_id
	   and mtsil.partner_type = 1 -- supplier ;
	   --AND NVL(mtsil.operating_unit, -1) = NVL(tp.operating_unit, -1)  -- (bug  #4089288)
	  AND mtsil.sr_tp_site_id= tps.sr_tp_site_id --bug 5012357
	   and rownum =1
	   ;

	 IF SQL%ROWCOUNT > 0 THEN
	    l_loaded_reqs := SQL%ROWCOUNT;
	    print_debug_info('    ' || l_loaded_reqs || ' rows inserted into msc_po_requisitions_interface');
	  ELSE
	    l_loaded_reqs := 0;
	    print_debug_info('    no rows inserted into msc_po_requisitions_interface');
	 END IF;

	 if (l_loaded_reqs > 0) then

	    -- call MRP_AP_REL_PLAN_PUB.INITIALIZE to set up initialization
	    -- for pushing requisition to PO
        BEGIN
	       l_po_group_by_name := 'VENDOR';

	       SELECT  DECODE(ai.m2a_dblink,NULL,' ', '@' || ai.m2a_dblink)
	       , instance_id
	       , instance_code
	       , a2m_dblink
		 INTO l_dblink
		 , l_instance_id
		 , l_instance_code
		 , l_a2m_dblink
		 FROM   msc_apps_instances ai
		 WHERE ai.instance_id = l_sr_instance_id;

	       --ut l_dblink := ''; --ut '@apsdev';
	       print_user_info('    call Requisition Import program in source, database link = ' || l_dblink);
		print_debug_info('  destination database instance id/code/link = '
				|| l_instance_id
				|| '/' || l_instance_code
				|| '/' || l_a2m_dblink
				);
	       l_sql_statement :=
		 'BEGIN'
		 ||' MSC_X_VMI_POREQ.LD_PO_REQUISITIONS_INTERFACE1'||l_dblink
		 ||'( :l_user_name,'
		 ||'  :l_application_name,'
		 ||'  :l_resp_name,'
		 ||'  :l_po_group_by_name,'
		 ||'  :l_instance_id,'
		 ||'  :l_instance_code,'
		 ||'  :l_a2m_dblink,'
		 ||'  :l_fnd_request_id);'
		 ||' END;';
/*
	       print_debug_info('    sql to be executed = '
             || l_sql_statement
           );
*/
	       EXECUTE IMMEDIATE l_sql_statement
                 USING IN  l_user_name,
		       IN  l_application_name,
                       IN  l_resp_name,
                       IN  l_po_group_by_name,
                       IN  l_instance_id,
                       IN  l_instance_code,
                       IN  l_a2m_dblink,
                       OUT l_fnd_request_id;

	       print_user_info('    Started Requisition Import concurrent program in database '
			       || l_dblink || ' with request id:' || l_fnd_request_id);
	       commit;

	       -- change the release status of the replenishment record from
	       -- from UNRELEASED to RELEASED

	     UPDATE msc_sup_dem_entries sd
		 SET sd.release_status = RELEASED
		 ,sd.quantity_in_process = l_order_quantity
		 WHERE sd.publisher_site_id = l_sce_organization_id
		 AND sd.inventory_item_id = l_inventory_item_id
		 AND sd.publisher_order_type = REPLENISHMENT
		 AND sd.plan_id = l_plan_id
		 AND sd.supplier_site_id = l_sce_supplier_site_id
		 AND sd.supplier_id = l_sce_supplier_id
		 AND sd.transaction_id = l_rep_transaction_id
		 AND sd.release_status = UNRELEASED;

	       print_debug_info('    updated status of replenishment record to RELEASED');

	    EXCEPTION
	       WHEN OTHERS THEN
		  print_debug_info('    Error when call Requistion Import or update replenishment record = '
                             || sqlerrm
                          );
	    END;

        BEGIN
	     DELETE MSC_PO_REQUISITIONS_INTERFACE
		 WHERE sr_instance_id= l_sr_instance_id;

	       print_debug_info('    deleted related data in MSC_PO_REQUISITIONS_INTERFACE');
	    EXCEPTION
	       WHEN OTHERS THEN
		  print_debug_info('    Error when deleting data in MSC_PO_REQUISITIONS_INTERFACE' || sqlerrm);
	    END;

	 end if; /* (l_loaded_reqs > 0) */

      END IF;
      resultout := 'COMPLETE:vmi_release_run';
	 print_debug_info('  End of vmi workflow release process');
      RETURN;
   END IF; -- if "RUN"

   IF funcmode = 'CANCEL' THEN
      resultout := 'COMPLETE:vmi_release_run_cancel';
  	  print_user_info('    vmi workflow release process canceled');
      RETURN;
   END IF;

   IF funcmode = 'TIMEOUT' THEN
      resultout := 'COMPLETE:vmi_release_run_timeout';
  	  print_user_info('    vmi workflow release process timed out');
      RETURN;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      print_user_info('    Error in the vmi workflow release process = ' || sqlerrm);
      wf_core.context('MSC_X_REPLENISH', 'vmi_release', itemtype, itemkey, actid, funcmode);
      RAISE;
END vmi_release;


-- This function is used to check if an item is a VMI item
FUNCTION is_vmi_item
  (
   p_inventory_item_id IN NUMBER
   , p_organization_id IN NUMBER
   , p_plan_id IN NUMBER
   , p_sr_instance_id IN NUMBER
   , p_supplier_id IN NUMBER DEFAULT NULL
   , p_supplier_site_id IN NUMBER DEFAULT NULL
   ) RETURN BOOLEAN IS

      l_return_result BOOLEAN DEFAULT FALSE;
      l_vmi_flag NUMBER;
      l_vmi_auto_replenish_flag VARCHAR2(100);

      CURSOR c_vmi_flag IS
	 SELECT vmi_flag, enable_vmi_auto_replenish_flag
	   FROM msc_item_suppliers
	   WHERE inventory_item_id = p_inventory_item_id
	   AND organization_id = p_organization_id
	   AND plan_id = p_plan_id
	   AND sr_instance_id = p_sr_instance_id
	   AND supplier_id = NVL(p_supplier_id, supplier_id)
	   AND supplier_site_id = NVL(p_supplier_site_id, supplier_site_id)
	   ORDER BY using_organization_id DESC
	   ;

BEGIN
   -- print_debug_info('is_vmi_item:000');
   OPEN c_vmi_flag;
   FETCH c_vmi_flag
     INTO l_vmi_flag, l_vmi_auto_replenish_flag;
   CLOSE c_vmi_flag;
   print_user_info('    vmi item flag/auto replenish flag = '
     || l_vmi_flag
     || '/' || l_vmi_auto_replenish_flag
     );

   IF (l_vmi_flag = 1 AND l_vmi_auto_replenish_flag = 'Y')THEN
      l_return_result := TRUE;
   END IF;
   -- print_debug_info('is_vmi_item:222');

   RETURN l_return_result;

EXCEPTION
   WHEN OTHERS THEN
      raise;
END is_vmi_item;

-- This function is used to check if an item is a VMI item for manual order entry
FUNCTION is_vmi_item_moe
  (
   p_inventory_item_id IN NUMBER
   , p_organization_id IN NUMBER
   , p_plan_id IN NUMBER
   , p_sr_instance_id IN NUMBER
   , p_supplier_id IN NUMBER DEFAULT NULL
   , p_supplier_site_id IN NUMBER DEFAULT NULL
   ) RETURN BOOLEAN IS

      l_return_result BOOLEAN DEFAULT FALSE;
      l_vmi_flag NUMBER;
      l_vmi_auto_replenish_flag VARCHAR2(100);

      CURSOR c_vmi_flag IS
	 SELECT vmi_flag, enable_vmi_auto_replenish_flag
	   FROM msc_item_suppliers
	   WHERE inventory_item_id = p_inventory_item_id
	   AND organization_id = p_organization_id
	   AND plan_id = p_plan_id
	   AND sr_instance_id = p_sr_instance_id
	   AND supplier_id = NVL(p_supplier_id, supplier_id)
	   AND supplier_site_id = NVL(p_supplier_site_id, supplier_site_id)
	   ORDER BY using_organization_id DESC
	   ;

BEGIN
   -- print_debug_info('is_vmi_item_moe:000');
   OPEN c_vmi_flag;
   FETCH c_vmi_flag
     INTO l_vmi_flag, l_vmi_auto_replenish_flag;
   CLOSE c_vmi_flag;
   -- print_debug_info('is_vmi_item_moe:111');

   print_user_info('    vmi item flag/auto replenish flag = '
     || l_vmi_flag
     || '/' || l_vmi_auto_replenish_flag
     );
   IF (l_vmi_flag = 1)THEN
      l_return_result := TRUE;
   END IF;
   -- print_debug_info('is_vmi_item_moe:222');

   RETURN l_return_result;

EXCEPTION
   WHEN OTHERS THEN
      raise;
END is_vmi_item_moe;


-- This procedure is called by the 'Is Auto Release' Workflow
-- activity
PROCEDURE is_auto_release
  (
   itemtype  in varchar2
   , itemkey   in varchar2
   , actid     in number
   , funcmode  in varchar2
   , resultout out nocopy varchar2
   ) IS

      l_vmi_replenishment_approval VARCHAR2(30);

      l_inventory_item_id NUMBER :=
	wf_engine.GetItemAttrNumber
	( itemtype => itemtype
	  , itemkey  => itemkey
	  , aname    => 'INVENTORY_ITEM_ID'
	  );

      l_organization_id NUMBER :=
	wf_engine.GetItemAttrNumber
	( itemtype => itemtype
	  , itemkey  => itemkey
	  , aname    => 'ORGANIZATION_ID'
	  );

      l_plan_id NUMBER :=
	wf_engine.GetItemAttrNumber
	( itemtype => itemtype
	  , itemkey  => itemkey
	  , aname    => 'PLAN_ID'
	  );

      l_sr_instance_id NUMBER :=
	wf_engine.GetItemAttrNumber
	( itemtype => itemtype
	  , itemkey  => itemkey
	  , aname    => 'SR_INSTANCE_ID'
	  );

      l_supplier_site_id NUMBER :=
	wf_engine.GetItemAttrNumber
	( itemtype => itemtype
	  , itemkey  => itemkey
	  , aname    => 'SUPPLIER_SITE_ID'
	  );

      l_supplier_id NUMBER :=
	wf_engine.GetItemAttrNumber
	( itemtype => itemtype
	  , itemkey  => itemkey
	  , aname    => 'SUPPLIER_ID'
	  );

      CURSOR c_vmi_replenishment_approval IS
	 SELECT vmi_replenishment_approval
	   FROM msc_item_suppliers
	   WHERE inventory_item_id = l_inventory_item_id
	   AND organization_id = l_organization_id
	   AND plan_id = l_plan_id
	   AND sr_instance_id = l_sr_instance_id
	   AND supplier_id = l_supplier_id
	   AND supplier_site_id = l_supplier_site_id
	   ORDER BY using_organization_id DESC
	   ;

BEGIN
   IF funcmode = 'RUN' THEN
      OPEN c_vmi_replenishment_approval;
      FETCH c_vmi_replenishment_approval
	INTO l_vmi_replenishment_approval;
      CLOSE c_vmi_replenishment_approval;

      IF (l_vmi_replenishment_approval = 'NONE') THEN
	 resultout := 'COMPLETE:Y';
       ELSE
	 resultout := 'COMPLETE:N';
      END IF;

   print_debug_info('    vmi release approval method: l_vmi_replenishment_approval = '
     || l_vmi_replenishment_approval
     );

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


-- This procedure is called by the 'Is Seller Approve' Workflow
-- activity
PROCEDURE is_seller_approve
  ( itemtype  in varchar2
    , itemkey   in varchar2
    , actid     in number
    , funcmode  in varchar2
    , resultout out nocopy varchar2
    ) IS

       l_vmi_replenishment_approval VARCHAR2(30);

       l_inventory_item_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'INVENTORY_ITEM_ID'
	   );

       l_organization_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'ORGANIZATION_ID'
	   );

       l_plan_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'PLAN_ID'
	   );

       l_sr_instance_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SR_INSTANCE_ID'
	   );

       l_supplier_site_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SUPPLIER_SITE_ID'
	   );

       l_supplier_id NUMBER :=
	 wf_engine.GetItemAttrNumber
	 ( itemtype => itemtype
	   , itemkey  => itemkey
	   , aname    => 'SUPPLIER_ID'
	   );

       CURSOR c_vmi_replenishment_approval IS
	  SELECT vmi_replenishment_approval
	    FROM msc_item_suppliers
	    WHERE inventory_item_id = l_inventory_item_id
	    AND organization_id = l_organization_id
	    AND plan_id = l_plan_id
	    AND sr_instance_id = l_sr_instance_id
	    AND supplier_id = l_supplier_id
	    AND supplier_site_id = l_supplier_site_id
	    ORDER BY using_organization_id DESC
	    ;

BEGIN
   IF funcmode = 'RUN' THEN
      OPEN c_vmi_replenishment_approval;
      FETCH c_vmi_replenishment_approval
	INTO l_vmi_replenishment_approval;
      CLOSE c_vmi_replenishment_approval;

      IF (l_vmi_replenishment_approval = 'SUPPLIER_OR_BUYER') THEN
	 resultout := 'COMPLETE:Y';
       ELSE
	 resultout := 'COMPLETE:N';
      END IF;

   print_user_info('    vmi release approval method = '
     || l_vmi_replenishment_approval
     );

      RETURN;
   END IF; -- if "RUN"

   IF funcmode = 'CANCEL' THEN
      resultout := 'COMPLETE:is_seller_approve_cancel';
      RETURN;
   END IF;

   IF funcmode = 'TIMEOUT' THEN
      resultout := 'COMPLETE:is_seller_approve_timeout';
      RETURN;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      raise;
END is_seller_approve;


  -- This procedure is called by the 'Reject Replenishment' Workflow
  -- activity and will change the replenishment status from 0 (unrealeased)
  -- to 2 (rejected)
  PROCEDURE vmi_reject
  ( itemtype  in varchar2
  , itemkey   in varchar2
  , actid     in number
  , funcmode  in varchar2
  , resultout out nocopy varchar2
  ) IS
    l_inventory_item_id NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype => itemtype
    , itemkey  => itemkey
    , aname    => 'INVENTORY_ITEM_ID'
    );
    l_organization_id NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype => itemtype
    , itemkey  => itemkey
    , aname    => 'ORGANIZATION_ID'
    );
    l_plan_id NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype => itemtype
    , itemkey  => itemkey
    , aname    => 'PLAN_ID'
    );
    l_sr_instance_id NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype => itemtype
    , itemkey  => itemkey
    , aname    => 'SR_INSTANCE_ID'
    );
    l_sce_supplier_site_id NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype => itemtype
    , itemkey  => itemkey
    , aname    => 'SCE_SUPPLIER_SITE_ID'
    );

    l_sce_supplier_id NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype => itemtype
    , itemkey  => itemkey
    , aname    => 'SCE_SUPPLIER_ID'
    );
    l_sce_organization_id NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype => itemtype
    , itemkey  => itemkey
    , aname    => 'SCE_ORGANIZATION_ID'
    );
    /*
    l_req_transaction_id NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype => itemtype
    , itemkey  => itemkey
    , aname    => 'REQ_TRANSACTION_ID'
    );
    */
    l_rep_transaction_id NUMBER := wf_engine.GetItemAttrNumber
    ( itemtype => itemtype
    , itemkey  => itemkey
    , aname    => 'REP_TRANSACTION_ID'
    );

  BEGIN

  print_debug_info('  Start of vmi workflow reject process');

  IF funcmode = 'RUN' THEN

  -- change the release status of the replenishment record from
  -- from UNRELEASED to REJECTED
  UPDATE msc_sup_dem_entries sd
  SET release_status = REJECTED
  WHERE sd.publisher_site_id = l_sce_organization_id
            AND sd.inventory_item_id = l_inventory_item_id
            AND sd.publisher_order_type = REPLENISHMENT
            AND sd.plan_id = l_plan_id
            AND sd.sr_instance_id = l_sr_instance_id
            AND sd.supplier_site_id = l_sce_supplier_site_id
            AND sd.supplier_id = l_sce_supplier_id
            AND sd.transaction_id = l_rep_transaction_id
            -- AND sd.release_status = UNRELEASED
            ;
    print_debug_info('  End of vmi workflow reject process');

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
    print_debug_info('  Error in vmi workflow reject process = ' || sqlerrm);
    wf_core.context('MSC_X_REPLENISH', 'vmi_release', itemtype, itemkey, actid, funcmode);
    RAISE;
  END vmi_reject;

  -- This function is used to convert APS tp key to SCE company key
  FUNCTION aps_to_sce(
      p_tp_key IN NUMBER
    , p_map_type IN NUMBER
    , p_sr_instance_id IN NUMBER DEFAULT NULL
    ) RETURN NUMBER IS

    l_company_key NUMBER;

    CURSOR c_company_key_1 IS
      SELECT cr.object_id
      FROM msc_trading_partner_maps map
      , msc_company_relationships cr
      WHERE map.map_type = p_map_type
      AND map.tp_key = p_tp_key
      AND map.company_key = cr.relationship_id
      AND cr.relationship_type = 2
      ;

    CURSOR c_company_key_2 IS
      SELECT map.company_key
      FROM msc_trading_partner_maps map
      , msc_trading_partners tp
      WHERE map.map_type = p_map_type
      AND tp.partner_id = map.tp_key
      AND tp.sr_tp_id = p_tp_key
      AND tp.sr_instance_id = p_sr_instance_id
      ;

    CURSOR c_company_key_3 IS
      SELECT  map.company_key
      FROM msc_trading_partner_maps map
      WHERE map.map_type = p_map_type
      AND map.tp_key = p_tp_key
      ;
BEGIN
    IF (p_map_type = COMPANY_MAPPING) THEN -- company
      OPEN c_company_key_1;
      FETCH c_company_key_1 INTO l_company_key;
      CLOSE c_company_key_1;
    END IF;

    IF (p_map_type = ORGANIZATION_MAPPING) THEN -- org
      OPEN c_company_key_2;
      FETCH c_company_key_2 INTO l_company_key;
      CLOSE c_company_key_2;
    END IF;

    IF (p_map_type = SITE_MAPPING) THEN -- site
      OPEN c_company_key_3;
      FETCH c_company_key_3 INTO l_company_key;
      CLOSE c_company_key_3;
    END IF;

 print_debug_info('    p_map_type = ' || p_map_type
                                  || ' p_tp_key = ' || p_tp_key
                                  || ' l_company_key = ' || l_company_key
                                  );
    RETURN l_company_key;
  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END aps_to_sce;

  -- This function is used to convert APS tp key to SCE company key
  FUNCTION sce_to_aps(
      p_company_key IN NUMBER
    , p_map_type IN NUMBER
    ) RETURN NUMBER IS

    l_tp_key NUMBER;

    CURSOR c_tp_key_1 IS
      SELECT map.tp_key
      FROM msc_trading_partner_maps map
      , msc_company_relationships cr
      WHERE map.map_type = p_map_type
      AND cr.object_id = p_company_key
      AND map.company_key = cr.relationship_id
      AND cr.relationship_type = 2
      AND cr.subject_id = OEM_COMPANY_ID
      ;

    CURSOR c_tp_key_2 IS
      SELECT tp.sr_tp_id
      FROM msc_trading_partner_maps map
      , msc_trading_partners tp
      WHERE map.map_type = p_map_type
      AND tp.partner_id = map.tp_key
      AND map.company_key= p_company_key
      ;
      /*AND tp.partner.partner_type = 3*/

    CURSOR c_tp_key_3 IS
      SELECT  map.tp_key
      FROM msc_trading_partner_maps map
      WHERE map.map_type = p_map_type
      AND  map.company_key = p_company_key

      ;
BEGIN
    IF (p_map_type = COMPANY_MAPPING) THEN -- company
      OPEN c_tp_key_1;
      FETCH c_tp_key_1 INTO l_tp_key;
      CLOSE c_tp_key_1;
    END IF;

    IF (p_map_type = ORGANIZATION_MAPPING) THEN -- org
      OPEN c_tp_key_2;
      FETCH c_tp_key_2 INTO l_tp_key;
      CLOSE c_tp_key_2;
    END IF;

    IF (p_map_type = SITE_MAPPING) THEN -- site
      OPEN c_tp_key_3;
      FETCH c_tp_key_3 INTO l_tp_key;
      CLOSE c_tp_key_3;
    END IF;

 print_debug_info('sce_to_aps:000 p_map_type = ' || p_map_type
                                  || ' p_company_key = ' || p_company_key
                                  || ' l_tp_key = ' || l_tp_key
                                  );
    RETURN l_tp_key;

  EXCEPTION
  WHEN OTHERS THEN
     raise;
  END sce_to_aps;

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

  -- This procedure will be called by UI program to manually create
  -- new requisitions
  PROCEDURE create_requisition
  ( p_item_id                   NUMBER
  , p_quantity                 NUMBER
  , p_need_by_date             VARCHAR2
  , p_customer_id                NUMBER
  , p_customer_site_id         NUMBER
  , p_supplier_id                  NUMBER
  , p_supplier_site_id           NUMBER
  , p_uom_code VARCHAR2 DEFAULT NULL
  , p_error_msg    OUT NOCOPY VARCHAR2
  , p_sr_instance_id           NUMBER   DEFAULT NULL
  ) IS
    l_po_group_by_name VARCHAR2(10);
    l_fnd_request_id NUMBER;
    l_sql_statement VARCHAR2(400);
    l_dblink VARCHAR2(128);

    l_need_by_date DATE;
    l_aps_customer_id                NUMBER;
    l_aps_customer_site_id         NUMBER;
    l_aps_supplier_id                  NUMBER;
    l_aps_supplier_site_id            NUMBER;
    l_sr_instance_id NUMBER;
    l_supplier_site_name VARCHAR2(100);

    l_loaded_reqs NUMBER;

    l_user_name         VARCHAR2(100):= NULL;
    l_resp_name         VARCHAR2(100):= NULL;
    l_application_name  VARCHAR2(240):= NULL;

    l_user_id           NUMBER;
    l_resp_id           NUMBER;
    l_application_id    NUMBER;
	   l_instance_id	   NUMBER;
	   l_instance_code VARCHAR2(100);
	   l_a2m_dblink VARCHAR2(100);

    l_user_company_id NUMBER;
    l_customer_uom_code VARCHAR2(3);
    -- l_supplier_uom_code VARCHAR2(3);
    -- l_supplier_vmi_uom_code VARCHAR2(3);
    -- l_uom_code VARCHAR2(10);

    CURSOR c_sr_instance_id IS
      SELECT tp.sr_instance_id
      FROM msc_trading_partner_maps map
      , msc_trading_partners tp
      WHERE map.map_type = ORGANIZATION_MAPPING
      AND tp.partner_id = map.tp_key
      AND  map.company_key= p_customer_site_id
      ;

    -- get company site name
    CURSOR c_company_site_name(
      p_company_id IN NUMBER
    , p_company_site_id IN NUMBER
    ) IS
    SELECT mcs.company_site_name
    FROM msc_company_sites mcs
    WHERE mcs.company_id = p_company_id
    AND mcs.company_site_id = p_company_site_id
    -- AND mcs.sr_instance_id = p_sr_instance_id
    ;

    -- get company site name
    CURSOR c_user_company_id
    IS
    SELECT mcu.company_id
    FROM msc_company_users mcu
    WHERE mcu.user_id = FND_GLOBAL.USER_ID
    ;

    l_employee_id number;

  BEGIN
print_user_info('  Start of creation of requisition process ');
print_debug_info('      item/customer/customer site/supplier/supplier site = ' || p_item_id
                || '/' || p_customer_id
                || '/' || p_customer_site_id
                || '/' || p_supplier_id
                || '/' || p_supplier_site_id
                );
print_user_info('    need by date/uom code = ' || p_need_by_date
                || '/' || p_uom_code
                );

    p_error_msg := null;
    --l_need_by_date := TO_DATE(p_need_by_date, 'DD/MM/YYYY');
      l_need_by_date := TO_DATE(p_need_by_date, NVL(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD/MM/YYYY')); --Bug 4554269

    if (p_supplier_site_id = -1) then
	 /* creation of Internal Reqs.  All TP ids are from APS schema */
	    l_aps_customer_id := p_customer_id;
	    l_aps_customer_site_id := p_customer_site_id;
	    l_aps_supplier_id := p_supplier_id;
	    l_aps_supplier_site_id := null;

            l_sr_instance_id := p_sr_instance_id;
    else
	 /* creation of Purchase Reqs. from MOE  All TP ids are from CP schema */
	    l_aps_customer_id := sce_to_aps(p_customer_id, COMPANY_MAPPING);
	    l_aps_customer_site_id := sce_to_aps(p_customer_site_id, ORGANIZATION_MAPPING);
	    l_aps_supplier_id := sce_to_aps(p_supplier_id, COMPANY_MAPPING);
	    l_aps_supplier_site_id := sce_to_aps(p_supplier_site_id, SITE_MAPPING);

	    select tp.sr_instance_id
	    into l_sr_instance_id
	    from msc_trading_partner_maps maps,
		 msc_trading_partners tp
	    where maps.tp_key = tp.partner_id
	    and maps.company_key = p_customer_site_id
	    and maps.map_type = 2
	    and tp.partner_type = 3;

	    OPEN c_company_site_name(
	      p_supplier_id
	    , p_supplier_site_id
	    );
	    FETCH c_company_site_name INTO l_supplier_site_name;
	    CLOSE c_company_site_name;
	    print_debug_info('create_requisition:000b l_supplier_site_name = ' || l_supplier_site_name);
    end if;

print_debug_info('  l_need_by_date = ' || l_need_by_date);
print_debug_info('  customer/customer site/supplier/supplier site/instance = '
                || '/' || l_aps_customer_id
                || '/' || l_aps_customer_site_id
                || '/' || l_aps_supplier_id
                || '/' || l_aps_supplier_site_id
                || '/' || l_sr_instance_id
                );

   -- this API will only create requistions for VMI items
   IF ( is_vmi_item_moe (
        p_item_id
      , l_aps_customer_site_id
      , VMI_PLAN_ID
      , l_sr_instance_id
      , l_aps_supplier_id
      , l_aps_supplier_site_id
      )
       OR (p_supplier_site_id = -1)   -- Internal requisition for Cust-VMI
   ) THEN

   SELECT
       FND_GLOBAL.USER_ID,
       FND_GLOBAL.USER_NAME,
       FND_GLOBAL.RESP_NAME,
       FND_GLOBAL.APPLICATION_NAME
   INTO l_user_id,
        l_user_name,
        l_resp_name,
        l_application_name
   FROM dual;


print_debug_info('  user ID/user/responsibility/application = '
                || l_user_id
                || '/' || l_user_name
                || '/' || l_resp_name
                || '/' || l_application_name
                );

   BEGIN

      select mp.employee_id
      into l_employee_id
      from msc_system_items si,
           msc_planners mp
      WHERE si.organization_id = l_aps_customer_site_id
      AND si.inventory_item_id = p_item_id
      AND si.plan_id = VMI_PLAN_ID
      AND si.sr_instance_id = l_sr_instance_id
      AND mp.sr_instance_id = si.sr_instance_id
      AND mp.organization_id = si.organization_id
      AND mp.planner_code = si.planner_code;

   exception
      when others then
          l_employee_id := null;
   end;

print_debug_info('  employee ID = ' || l_employee_id);

/* ---- AGM ----- */


print_debug_info('l_aps_customer_site_id : ' ||l_aps_customer_site_id );
print_debug_info('p_item_id : ' ||p_item_id );
    -- insert a row into msc_po_requisitions_interface with status = 'approved'
    INSERT INTO msc_po_requisitions_interface(
             -- line_type_id -- Amount or Quantity based
    	     last_updated_by
            , last_update_date
            , last_update_login
            , creation_date
            , created_by
            , item_id
            , quantity
            , need_by_date
            , interface_source_code
            , deliver_to_location_id
            , deliver_to_requestor_id
            , destination_type_code
            , preparer_id
            , source_type_code
            , authorization_status
            , uom_code
            , batch_id
            , charge_account_id
            , group_code
            , item_revision
            , destination_organization_id
            , autosource_flag
            , org_id
            , source_organization_id
            , suggested_vendor_id
            , suggested_vendor_site_id
            , suggested_vendor_site
            , project_id
            , task_id
	    , end_item_unit_number
            , project_accounting_context
            , sr_instance_id
            , vmi_flag
            )
            SELECT
           -- 1, -- Quantity based
            si.last_updated_by,
            SYSDATE, -- last_update_date
            si.last_update_login,
            SYSDATE, -- creation_date
            l_user_id, -- created_by
            si.sr_inventory_item_id, -- item_id
            p_quantity, -- quantity
            l_need_by_date, -- need_by_date
            'MSC', -- interface_source_code
            tps2.sr_tp_site_id, -- deliver_to_location_id
            l_employee_id, --mp.employee_id, -- deliver_to_requestor_id
            'INVENTORY', -- destination_type_code
            l_employee_id,   --mp.employee_id, -- preparer_id
            'VENDOR', -- source_type_code
            'APPROVED', -- authorization_status
	    nvl(p_uom_code,si.uom_code), ---l_customer_uom_code, -- l_uom_code, --si.uom_code,  --
            to_number(NULL), -- batch_id
            decode(si.inventory_asset_flag,
                   'Y', tp.material_account,
                   nvl(si.expense_account, tp.expense_account)),
            si.inventory_item_id, -- group_code
            si.revision, -- item_revision
            si.organization_id, -- destination_organization_id
            'P', -- autosource_flag
            tp.operating_unit, -- org_id
            to_number(NULL), -- source_organization_id
            tplid.sr_tp_id, -- suggested_vendor_id
            tps.sr_tp_site_id, -- suggested_vendor_site_id
            tps.tp_site_code, -- suggested_vendor_site
            to_number(NULL), -- project_id
            to_number(NULL), -- task_id
  	    to_char(NULL), -- end_item_unit_number
	    to_char(NULL), -- project_accounting_context
            si.sr_instance_id, -- sr_instance_id
            1  -- vmi_flag
            FROM msc_system_items si,
                msc_trading_partners tp,
                 msc_tp_id_lid tplid,
                 msc_trading_partner_sites tps,
                 msc_trading_partner_sites tps2
                 , MSC_TP_SITE_ID_LID mtsil
            WHERE si.organization_id = l_aps_customer_site_id
            AND si.inventory_item_id = p_item_id
            AND si.plan_id = VMI_PLAN_ID
            AND si.sr_instance_id = l_sr_instance_id
           AND tp.sr_tp_id = si.organization_id
            AND tp.sr_instance_id = l_sr_instance_id
	    AND tp.partner_type = 3
            AND tplid.tp_id = l_aps_supplier_id
            AND tplid.partner_type = 1
            AND tplid.sr_instance_id = l_sr_instance_id
            AND tps.partner_site_id = l_aps_supplier_site_id
 	    AND tps.partner_id = l_aps_supplier_id
            AND tps.partner_type = 1
            AND tps2.sr_tp_id = si.organization_id
            AND tps2.sr_instance_id = l_sr_instance_id
            AND tps2.partner_type = 3
            and mtsil.sr_instance_id = l_sr_instance_id
            and mtsil.tp_site_id = l_aps_supplier_site_id
            and mtsil.partner_type = 1 -- supplier
	    --AND NVL(mtsil.operating_unit, -1) = NVL(tp.operating_unit, -1)   -- (bug # 4589288)
	     AND mtsil.sr_tp_site_id= tps.sr_tp_site_id
            and rownum = 1
    UNION ALL
            SELECT
          --  1, -- Quantity based
            si.last_updated_by,
            SYSDATE, -- last_update_date
            si.last_update_login,
            SYSDATE, -- creation_date
            l_user_id, -- created_by
            si.sr_inventory_item_id, -- item_id
            p_quantity, -- quantity
            l_need_by_date, -- need_by_date
            'MSC', -- interface_source_code
            tps.sr_tp_site_id, -- deliver_to_location_id
            l_employee_id, --mp.employee_id, -- deliver_to_requestor_id
            'INVENTORY', -- destination_type_code
            l_employee_id,   --mp.employee_id, -- preparer_id
            'INVENTORY', -- source_type_code
            'APPROVED', -- authorization_status
	    nvl(p_uom_code,si.uom_code), ---l_customer_uom_code, -- l_uom_code, --si.uom_code,  --
            to_number(NULL), -- batch_id
	      decode( si.inventory_asset_flag,
		      'Y', tp.material_account,
		      nvl(si.expense_account, tp.expense_account)),
            --si.expense_account, -- charge_account_id
            si.inventory_item_id, -- group_code
            si.revision, -- item_revision
            si.organization_id, -- destination_organization_id
            'P', -- autosource_flag
            tp.operating_unit, -- tp.operating_unit, -- org_id
            p_supplier_id, -- source_organization_id
            to_number(NULL), -- suggested_vendor_id
            to_number(NULL), -- suggested_vendor_site_id
            to_char(NULL), -- suggested_vendor_site
            to_number(NULL), -- project_id
            to_number(NULL), -- task_id
  	    to_char(NULL), -- end_item_unit_number
	    to_char(NULL), -- project_accounting_context
            si.sr_instance_id, -- sr_instance_id
            2  -- vmi_flag
       FROM msc_system_items si,
            msc_trading_partners tp,
            msc_trading_partner_sites tps
     WHERE si.organization_id = l_aps_customer_site_id
     AND si.inventory_item_id = p_item_id
     AND si.plan_id = VMI_PLAN_ID
     AND si.sr_instance_id = l_sr_instance_id
     AND tp.sr_tp_id = si.organization_id
     AND tp.sr_instance_id = l_sr_instance_id
     AND tp.partner_type = 3
     AND tps.sr_instance_id = tp.sr_instance_id
     AND tps.sr_tp_id = tp.sr_tp_id
     AND tps.partner_type = tp.partner_type
     and si.inventory_planning_code=7 --Bug 4700809, only the CVMI items contain 7 as the value of this flag.
     AND rownum = 1;

    IF SQL%ROWCOUNT > 0 THEN
        l_loaded_reqs := SQL%ROWCOUNT;
        print_debug_info('  inserted into msc_po_requisitions_interface, number of inserted rows = '
                         || l_loaded_reqs);
    ELSE
        l_loaded_reqs := 0;
        print_debug_info('  no record inserted into msc_po_requisitions_interface');
    END IF;

    if (l_loaded_reqs > 0) then

      -- call MRP_AP_REL_PLAN_PUB.INITIALIZE to set up initialization
      -- for pushing requisition to PO
      BEGIN
        l_po_group_by_name := 'VENDOR';

        SELECT  DECODE(ai.m2a_dblink,NULL,' ', '@' || ai.m2a_dblink)
	       , instance_id
	       , instance_code
	       , a2m_dblink
        INTO l_dblink
		 , l_instance_id
		 , l_instance_code
		 , l_a2m_dblink
        FROM   msc_apps_instances ai
        WHERE ai.instance_id = l_sr_instance_id;


        --ut l_dblink := ''; --ut '@apsdev';
print_debug_info('  source database link = ' || l_dblink);
print_debug_info('  destination database instance id/code/link = '
				|| l_instance_id
				|| '/' || l_instance_code
				|| '/' || l_a2m_dblink
				);
        l_sql_statement :=
           'BEGIN'
         ||' MSC_X_VMI_POREQ.LD_PO_REQUISITIONS_INTERFACE1'||l_dblink
                  ||'( :l_user_name,'
                  ||'  :l_application_name,'
                  ||'  :l_resp_name,'
                  ||'  :l_po_group_by_name,'
				  ||'  :l_instance_id,'
				  ||'  :l_instance_code,'
		 		  ||'  :l_a2m_dblink,'
                  ||'  :l_fnd_request_id);'
         ||' END;';

-- print_debug_info('  sql statement to be executed = ' || l_sql_statement);

         EXECUTE IMMEDIATE l_sql_statement
                 USING IN  l_user_name,
                       IN  l_application_name,
                       IN  l_resp_name,
                       IN  l_po_group_by_name,
                       IN  l_instance_id,
                       IN  l_instance_code,
                       IN  l_a2m_dblink,
                       OUT l_fnd_request_id;

print_debug_info('  Requisition Import program called, request ID = ' || l_fnd_request_id);

         commit;

      EXCEPTION
        WHEN OTHERS THEN
           print_debug_info('  Error in manual creation of requisition = ' || sqlerrm);
      END;

      BEGIN
print_debug_info('  delete records in MSC_PO_REQUISITIONS_INTERFACE' || l_fnd_request_id);
          DELETE MSC_PO_REQUISITIONS_INTERFACE --ut
            WHERE sr_instance_id= l_sr_instance_id; --ut
      EXCEPTION
        WHEN OTHERS THEN
print_debug_info('  Error when deleting records in MSC_PO_REQUISITIONS_INTERFACE');
      END;
  END IF;

 END IF; -- is_vmi_item_moe

print_debug_info('  End of manual creation of requisition');
  EXCEPTION
  WHEN OTHERS THEN
print_debug_info('  Error in manual release process' || sqlerrm);
    --RAISE;
  END create_requisition;

PROCEDURE temp_tables
IS
--- Create Temp table for Item Suppliers
l_cnt number;
Begin
-- Delete from MSC_X_ITEM_SUPPLIERS_GTT;
-- Delete from MSC_X_ITEM_ORGS_GTT;
-- Delete from MSC_X_ITEM_SITES_GTT;

		   Insert into MSC_X_ITEM_SUPPLIERS_GTT(
		               object_id,
		               tp_key
		    )
        select distinct r.object_id, map1.tp_key
        from msc_trading_partner_maps map1,
             msc_company_relationships r,
             msc_item_suppliers its
        where map1.map_type = 1
        AND   map1.company_key = r.relationship_id
        AND   map1.tp_key = its.supplier_id
        AND   r.relationship_type = 2
        AND   r.subject_id = 1
        AND   its.plan_id = -1
        AND   its.vmi_flag = 1
        AND   its.enable_vmi_auto_replenish_flag = 'Y';

l_cnt := SQL%ROWCOUNT;
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Rows inserted into msc_item_suppliers_temp: ' || l_cnt);
-- Create Temp table for Item Supplier Orgs

                   Insert into MSC_X_ITEM_ORGS_GTT(
                               company_key,
                               sr_tp_id
                   )
                   select distinct map2.company_key,tp.sr_tp_id
                   from msc_trading_partner_maps map2,
                        msc_trading_partners tp,
                        msc_item_suppliers its
                   where map2.map_type = 2
                   AND   map2.tp_key = tp.partner_id
                   AND   tp.partner_type = 3
                   AND   tp.sr_tp_id = its.organization_id
                   AND   tp.sr_instance_id = its.sr_instance_id
                   AND   its.plan_id = -1
                   AND   its.vmi_flag = 1
                   AND   its.enable_vmi_auto_replenish_flag = 'Y';

 l_cnt := SQL%ROWCOUNT;
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Rows inserted into msc_item_orgs_temp: ' || l_cnt);

-- Create Temp table for Item Supplier Sites

                     Insert into MSC_X_ITEM_SITES_GTT(
                                 company_key,
                                 tp_key
                     )
                     select distinct map3.company_key, map3.tp_key
                     from msc_trading_partner_maps map3,
                          msc_item_suppliers its
                     where map3.map_type = 3
                     AND   map3.tp_key = its.supplier_site_id
                     AND   its.plan_id = -1
                     AND   its.vmi_flag = 1
                     AND   its.enable_vmi_auto_replenish_flag = 'Y';

 l_cnt := SQL%ROWCOUNT;
 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Rows inserted into msc_item_sites_temp: ' || l_cnt);

commit;

EXCEPTION
   WHEN OTHERS THEN
      raise;
END temp_tables;


END MSC_X_REPLENISH;

/
