--------------------------------------------------------
--  DDL for Package Body MSC_X_EX5_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_EX5_PKG" AS
/* $Header: MSCXEX5B.pls 120.5 2008/02/25 10:40:20 hbinjola ship $ */

g_msc_cp_debug VARCHAR2(10) := NVL(FND_PROFILE.VALUE('MSC_CP_DEBUG'), '0');

------------------------------------------------------------------------------------------
--COMPUTE_VMI_EXCEPTIONS
------------------------------------------------------------------------------------------
PROCEDURE Compute_VMI_Exceptions ( p_refresh_number IN Number
                                 , p_replenish_time_fence IN NUMBER
                                 ) IS
--item_max and item_min are the minimum and maximum values
--setup for the supplier item.
l_item_max        		Number;
l_item_min        		Number;
l_exception_type 		Number;
l_exception_group 		Number;
l_generate_complement		Boolean;
l_obs_exception			Number;
l_exc_generated			Number;
l_supplier_id   		Number;
l_supplier_site_id     		Number;
l_customer_id   		Number;
l_customer_site_id       	Number;
l_publisher_id			Number;
l_publisher_site_id		Number;
l_item_id			Number;
l_item_name			msc_sup_dem_entries.item_name%type;
l_item_desc			msc_sup_dem_entries.item_description%type;
l_publisher_name		msc_sup_dem_entries.publisher_name%type;
l_publisher_site_name		msc_sup_dem_entries.publisher_site_name%type;
l_supplier_name			msc_sup_dem_entries.supplier_name%type;
l_supplier_site_name		msc_sup_dem_entries.supplier_site_name%type;
l_supplier_item_name		msc_sup_dem_entries.supplier_item_name%type;
l_supplier_item_desc		msc_sup_dem_entries.supplier_item_description%type;
l_customer_name			msc_sup_dem_entries.customer_name%type;
l_customer_site_name		msc_sup_dem_entries.customer_site_name%type;
l_customer_item_name		msc_sup_dem_entries.customer_item_name%type;
l_customer_item_desc		msc_sup_dem_entries.customer_item_description%type;
l_exception_type_name		fnd_lookup_values.meaning%type;
l_exception_group_name		fnd_lookup_values.meaning%type;
l_total_supply                  NUMBER;
l_lead_time                     NUMBER;
l_time_fence_end_date           DATE;
l_asn_quantity                  NUMBER;
l_allocated_onhand_quantity     NUMBER;
l_shipment_receipt_quantity     NUMBER;
l_requisition_quantity          NUMBER;
l_po_quantity                   NUMBER;
l_total_onorder                 NUMBER;
l_errbuf		        Varchar2(1000);
l_retnum		        Number;
l_automatic_allowed_flag        VARCHAR2(10);
l_aps_organization_id           NUMBER;
l_aps_supplier_id               NUMBER;
l_aps_supplier_site_id          NUMBER;
l_sr_instance_id                NUMBER;

         l_min_minmax_days  NUMBER;
         l_max_minmax_days NUMBER;
         l_fixed_order_quantity NUMBER;
         l_average_daily_demand NUMBER;
         l_vmi_refresh_flag NUMBER;
		 l_lower_limit_quantity NUMBER;
	     l_upper_limit_quantity NUMBER;
         l_replenishment_method  NUMBER;
 l_row_ret BOOLEAN;

--=================================================================
-- Group 2: Material Shortage
-- Group 7: Excess exceptions
--=================================================================
----------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- 2.5 VMI item shortage at customer site, replenishment required (supplier centric): exception_9
-- 7.5 VMI item excess at customer site (supplier centric) : exception_29
--------------------------------------------------------------------------------------
--The cursor  fetches the distinct customer-item combinations
--for the viewer, where the viewer is the supplier in the VMI plan. Note
--that in VMI plans supplier posts intransit (ASN) quantities.
--supplier centric
--Bug 5666318
CURSOR exception_9_29(p_refresh_number in Number) IS
SELECT distinct sd.customer_id,
	sd.customer_site_id,
        sd.supplier_id,
        sd.supplier_site_id,
        sd.inventory_item_id,
        itm.organization_id,
        itm.supplier_id,
        itm.supplier_site_id,
        itm.sr_instance_id
FROM     msc_sup_dem_entries_v sd,
	msc_item_suppliers itm,
	MSC_X_ITEM_SUPPLIERS_GTT iut,
	MSC_X_ITEM_ORGS_GTT iot,
	MSC_X_ITEM_SITES_GTT ist
WHERE   sd.plan_id = MSC_X_NETTING_PKG.G_PLAN_ID
AND     sd.publisher_order_type = 15 -- ASN
AND     sd.vmi_flag = 1
AND	sd.customer_site_id = iot.company_key
AND     sd.supplier_id = iut.object_id
AND	sd.supplier_site_id = ist.company_key
AND	itm.inventory_item_id = sd.inventory_item_id
--AND     nvl(sd.last_refresh_number,-1) >  nvl(p_refresh_number,-1)
AND     itm.vmi_flag = 1
AND     NVL(itm.enable_vmi_auto_replenish_flag, 'N') = 'N'
AND     sd.plan_id = itm.plan_id
AND     ( (nvl(sd.last_refresh_number,-1) >  nvl(p_refresh_number,-1)) or
          (itm.vmi_refresh_flag = 1
	   AND (itm.replenishment_method = 2 OR itm.replenishment_method = 4)
	  )
	)

UNION  /* Bug 3737298 : added UNION so that VMI Engine generates MATERIAL SHORTAGE Exception even
      if there does not exist any data in msc_sup_dem_entries. */

SELECT distinct 1 ,
        iot.company_key ,
	iut.object_id ,
	ist.company_key,
	itm.inventory_item_id ,
	itm.organization_id,
        itm.supplier_id,
        itm.supplier_site_id,
        itm.sr_instance_id
FROM  msc_item_suppliers itm,
      msc_trading_partners tp2 ,
      msc_trading_partner_sites tps,
	MSC_X_ITEM_SUPPLIERS_GTT iut,
	MSC_X_ITEM_ORGS_GTT iot,
	MSC_X_ITEM_SITES_GTT ist
WHERE   itm.plan_id = MSC_X_NETTING_PKG.G_PLAN_ID
AND     itm.organization_id = iot.sr_tp_id
AND     itm.supplier_id = iut.tp_key
AND     iut.tp_key = tp2.partner_id
AND     tp2.sr_instance_id = itm.sr_instance_id
AND     tp2.partner_type = 1
AND     tps.partner_id = tp2.partner_id
AND     tps.sr_instance_id = tp2.sr_instance_id
AND	tp2.partner_type = tps.partner_type
AND     itm.supplier_site_id = ist.tp_key
AND     ist.tp_key = tps.partner_site_id
--and    ( itm.supplier_site_id is not null or rownum = 1)
AND     itm.vmi_flag = 1
AND     NVL(itm.enable_vmi_auto_replenish_flag, 'N') = 'N'
AND     itm.inventory_item_id NOT IN (	select distinct sd.inventory_item_id
				      	FROM msc_sup_dem_entries_v sd,
					     msc_item_suppliers itm,
					     MSC_X_ITEM_SUPPLIERS_GTT iut,
					     MSC_X_ITEM_ORGS_GTT iot,
				             MSC_X_ITEM_SITES_GTT ist
					WHERE   sd.plan_id = -1
					AND     sd.publisher_order_type IN (15, 9, 13, 16, 20) -- ASN , Onhand, PO, Rcpt, Req
					AND     sd.vmi_flag = 1
					AND	sd.customer_site_id = iot.company_key
					AND     sd.supplier_id = iut.object_id
					AND	sd.supplier_site_id = ist.company_key
					AND	itm.inventory_item_id = sd.inventory_item_id
					AND     itm.vmi_flag = 1
					AND     NVL(itm.enable_vmi_auto_replenish_flag, 'N') = 'N'
					AND     sd.plan_id = itm.plan_id)
;





---------------------------------------------------------------------------
-- 2.6 VMI item shortage at your site (buyer centric):exception_10
-- 7.6 VMI item excess at your site (buyer centric): exception_30
---------------------------------------------------------------------------
--The cursor fetches the distinct supplier-item combinations
--for the viewer, where the viewer is the buyer in the VMI plan. Note
--that in VMI plans buyer posts onhand quantities.
--exception 10, 30   -- customer centric

--Bug 5666318
CURSOR exception_10_30(	p_refresh_number IN Number) IS
SELECT distinct sd.supplier_id,
	sd.supplier_site_id,
        sd.publisher_id,
        sd.publisher_site_id,
        sd.inventory_item_id,
        itm.organization_id,
        itm.supplier_id,
        itm.supplier_site_id,
        itm.sr_instance_id
FROM    msc_sup_dem_entries_v sd,
        msc_item_suppliers itm,
	MSC_X_ITEM_SUPPLIERS_GTT iut,
	MSC_X_ITEM_ORGS_GTT iot,
	MSC_X_ITEM_SITES_GTT ist
WHERE 	sd.plan_id = MSC_X_NETTING_PKG.G_PLAN_ID
AND 	sd.publisher_order_type IN (9, 13, 16, 20) -- Onhand, PO, Rcpt, Req
AND     sd.vmi_flag = 1
AND	sd.customer_site_id = iot.company_key
AND     sd.supplier_id = iut.object_id
AND	sd.supplier_site_id = ist.company_key
AND	itm.inventory_item_id = sd.inventory_item_id
AND     sd.plan_id = itm.plan_id
--AND     nvl(sd.last_refresh_number,-1) > nvl(p_refresh_number,-1)
AND     itm.vmi_flag = 1
AND     NVL(itm.enable_vmi_auto_replenish_flag, 'N') = 'N'
AND     ( (nvl(sd.last_refresh_number,-1) >  nvl(p_refresh_number,-1)) or
          (itm.vmi_refresh_flag = 1
	   AND (itm.replenishment_method = 2 OR itm.replenishment_method = 4)
	  )
	);


/** added the following cusors for VMI exceptions */

      -- get the sum of ASN quantity during the replenishment
      -- time frame, excluding those ASNs which are already
      -- pegged by Shippment Receipt
      CURSOR c_asn_quantity ( p_inventory_item_id IN NUMBER
                            , p_plan_id IN NUMBER
                            , p_customer_id IN NUMBER
                            , p_customer_site_id IN NUMBER
                            , p_supplier_id IN NUMBER
                            , p_supplier_site_id IN NUMBER
                            , p_time_fence_end_date IN DATE
                            ) IS
      SELECT SUM( DECODE( sd.publisher_id
                        , sd.supplier_id, sd.tp_quantity
                        , sd.primary_quantity
                        )
                )
        FROM msc_sup_dem_entries sd
        WHERE sd.inventory_item_id =  p_inventory_item_id
        AND sd.supplier_site_id = p_supplier_site_id
        AND sd.supplier_id = p_supplier_id
        AND sd.plan_id = p_plan_id
        AND sd.publisher_order_type = 15 -- ASN
        AND sd.customer_id = p_customer_id
        AND sd.customer_site_id = p_customer_site_id
	AND sd.vmi_flag = 1
        -- AND sd.RECEIPT_DATE <= p_time_fence_end_date
        ;

      -- get the latest allocated on hand quantity during the replenishment
      -- time window
      CURSOR c_allocated_onhand_quantity ( p_inventory_item_id IN NUMBER
                            , p_plan_id IN NUMBER
                            , p_customer_id IN NUMBER
                            , p_customer_site_id IN NUMBER
                            , p_supplier_id IN NUMBER
                            , p_supplier_site_id IN NUMBER
                            , p_time_fence_end_date IN DATE
                            ) IS
      SELECT sd.primary_quantity
        FROM msc_sup_dem_entries sd
        WHERE sd.inventory_item_id =  p_inventory_item_id
        AND sd.publisher_site_id = p_customer_site_id
        AND sd.plan_id = p_plan_id
        AND sd.publisher_order_type = 9 -- ALLOCATED_ONHAND
        AND sd.supplier_site_id = p_supplier_site_id
        AND sd.supplier_id = p_supplier_id
	AND sd.vmi_flag = 1
        ORDER BY sd.key_date desc
        ;

    -- get the shipment receipt quantity
    CURSOR c_shipment_receipt_quantity ( p_inventory_item_id IN NUMBER
                            , p_plan_id IN NUMBER
                            , p_customer_id IN NUMBER
                            , p_customer_site_id IN NUMBER
                            , p_supplier_id IN NUMBER
                            , p_supplier_site_id IN NUMBER
                            , p_time_fence_end_date IN DATE
                            ) IS
    SELECT SUM(sd.primary_quantity)
    FROM msc_sup_dem_entries sd
    WHERE sd.publisher_site_id = p_customer_site_id
    AND sd.inventory_item_id = p_inventory_item_id
    AND sd.publisher_order_type = 16 -- SHIPMENT_RECEIPT
    AND sd.plan_id = p_plan_id
    AND sd.supplier_id = p_supplier_id
    AND sd.supplier_site_id = p_supplier_site_id
    AND sd.vmi_flag = 1
    -- AND sd.RECEIPT_DATE <= SYSDATE
    ;

    -- get the requisition quantity
    CURSOR c_requisition_quantity ( p_inventory_item_id IN NUMBER
                            , p_plan_id IN NUMBER
                            , p_customer_id IN NUMBER
                            , p_customer_site_id IN NUMBER
                            , p_supplier_id IN NUMBER
                            , p_supplier_site_id IN NUMBER
                            , p_time_fence_end_date IN DATE
                            ) IS
    SELECT SUM(sd.primary_quantity)
    FROM msc_sup_dem_entries sd
    WHERE sd.publisher_site_id = p_customer_site_id
    AND sd.inventory_item_id = p_inventory_item_id
    AND sd.publisher_order_type = 20 -- REQUISITION
    AND sd.plan_id = p_plan_id
    AND sd.supplier_id = p_supplier_id
    AND sd.supplier_site_id = p_supplier_site_id
    AND sd.vmi_flag = 1
    -- AND sd.RECEIPT_DATE
    --   BETWEEN SYSDATE AND p_time_fence_end_date
    ;

    -- get the purchase order quantity
    CURSOR c_po_quantity ( p_inventory_item_id IN NUMBER
                            , p_plan_id IN NUMBER
                            , p_customer_id IN NUMBER
                            , p_customer_site_id IN NUMBER
                            , p_supplier_id IN NUMBER
                            , p_supplier_site_id IN NUMBER
                            , p_time_fence_end_date IN DATE
                            ) IS
    SELECT SUM(sd.primary_quantity)
    FROM msc_sup_dem_entries sd
    WHERE sd.publisher_site_id = p_customer_site_id
    AND sd.inventory_item_id = p_inventory_item_id
    AND sd.publisher_order_type = 13 -- PURCHASE_ORDER
    AND sd.plan_id = p_plan_id
    AND sd.supplier_id = p_supplier_id
    AND sd.supplier_site_id = p_supplier_site_id
    AND sd.vmi_flag = 1
    -- AND sd.RECEIPT_DATE
    --   BETWEEN SYSDATE AND p_time_fence_end_date
    ;

    -- get the suggested replenishment quantity
    CURSOR c_replenishment_quantity ( p_inventory_item_id IN NUMBER
                            , p_plan_id IN NUMBER
                            , p_customer_id IN NUMBER
                            , p_customer_site_id IN NUMBER
                            , p_supplier_id IN NUMBER
                            , p_supplier_site_id IN NUMBER
                            ) IS
    SELECT sd.primary_quantity
    FROM msc_sup_dem_entries sd
    WHERE sd.publisher_site_id = p_customer_site_id
    AND sd.inventory_item_id = p_inventory_item_id
    AND sd.publisher_order_type = 19 -- REPLENISHMENT
    AND sd.plan_id = p_plan_id
    AND sd.supplier_id = p_supplier_id
    AND sd.supplier_site_id = p_supplier_site_id
    AND sd.vmi_flag = 1
    ;

    -- get ASL attributes
    CURSOR c_asl_attributes ( p_inventory_item_id IN NUMBER
                            , p_plan_id IN NUMBER
                            , p_sr_instance_id IN NUMBER
                            , p_organization_id IN NUMBER
                            , p_supplier_id IN NUMBER
                            , p_supplier_site_id IN NUMBER
                            ) IS
    SELECT itm.min_minmax_quantity
         , itm.max_minmax_quantity
         , itm.processing_lead_time
         , itm.enable_vmi_auto_replenish_flag
         , itm.min_minmax_days
         , itm.max_minmax_days
         , itm.fixed_order_quantity
         , mvt.average_daily_demand
         , itm.vmi_refresh_flag
         , itm.replenishment_method
    FROM msc_item_suppliers itm
    , msc_vmi_temp mvt
    WHERE itm.inventory_item_id = p_inventory_item_id
    AND itm.plan_id = p_plan_id
    AND itm.sr_instance_id = p_sr_instance_id
    AND itm.organization_id = p_organization_id
    AND itm.supplier_id = p_supplier_id
    AND itm.supplier_site_id = p_supplier_site_id
	      and mvt.plan_id (+) = itm.plan_id
	      and mvt.inventory_item_id (+) = itm.inventory_item_id
	      and mvt.organization_id (+) = itm.organization_id
	      and mvt.sr_instance_id (+) = itm.sr_instance_id
	      and mvt.supplier_site_id (+) = itm.supplier_site_id
	      and mvt.supplier_id (+) = itm.supplier_id
	      and NVL (mvt.using_organization_id(+), 1) = NVL(itm.using_organization_id, -1)
          and mvt.vmi_type (+) = 1 -- supplier facing vmi
    ORDER BY itm.using_organization_id DESC
    ;

    CURSOR c_item_attributes_9_29 ( p_inventory_item_id IN NUMBER
                            , p_plan_id IN NUMBER
                            , p_organization_id IN NUMBER
                            , p_supplier_id IN NUMBER
                            , p_supplier_site_id IN NUMBER
                            ) IS
    SELECT DISTINCT sd.customer_name,
        sd.customer_site_name,
        sd.customer_item_name,
        sd.customer_item_description,
        sd.supplier_name,
        sd.supplier_site_name,
        sd.item_name,
        sd.item_description,
        sd.supplier_item_name
    FROM    msc_sup_dem_entries_v sd
    WHERE sd.inventory_item_id = p_inventory_item_id
    AND sd.plan_id = p_plan_id
    AND sd.customer_site_id = p_organization_id
    AND sd.supplier_id = p_supplier_id
    AND sd.supplier_site_id = p_supplier_site_id
    AND sd.publisher_order_type = 15 -- ASN
    AND sd.vmi_flag = 1
    ;

    CURSOR c_item_attributes_10_30 ( p_inventory_item_id IN NUMBER
                            , p_plan_id IN NUMBER
                            , p_organization_id IN NUMBER
                            , p_supplier_id IN NUMBER
                            , p_supplier_site_id IN NUMBER
                            ) IS
    SELECT DISTINCT sd.supplier_name,
	sd.supplier_site_name,
        sd.supplier_item_name,
        sd.supplier_item_description,
        sd.customer_name,
        sd.customer_site_name,
        sd.item_name,
        sd.item_description,
        sd.customer_item_name
    FROM    msc_sup_dem_entries_v sd
    WHERE sd.inventory_item_id = p_inventory_item_id
    AND sd.plan_id = p_plan_id
    AND sd.customer_site_id = p_organization_id
    AND sd.supplier_id = p_supplier_id
    AND sd.supplier_site_id = p_supplier_site_id
    AND sd.publisher_order_type IN (9, 13, 16, 20)
    AND sd.vmi_flag = 1
    ;

 -- Bug 3737298 : Added Cursor to select customer/ supplier data
  CURSOR cust_sup_item_name_c (p_tx_item_id in number
				, p_tx_org_id in number
				, p_tx_instance_id in number
				, p_tx_supplier_id in number
				, p_tx_supplier_site_id in number) IS
     SELECT distinct 'My Company' ,
	tp.ORGANIZATION_CODE,
	null,
	null,
	tp2.partner_name,
	tps.TP_SITE_CODE ,
	msi.item_name,
	msi.description,
	itm.supplier_item_name
     FROM  msc_item_suppliers itm,
	   msc_trading_partners tp ,
	   msc_trading_partners tp2 ,
	   msc_trading_partner_sites tps ,
	   msc_system_items msi
     WHERE tp.sr_tp_id = p_tx_org_id
	AND      tp.sr_instance_id = p_tx_instance_id
	AND	tp.partner_type = 3
	AND  tp2.partner_id = p_tx_supplier_id
	AND tp2.sr_instance_id = p_tx_instance_id
	AND tp2.partner_type = 1
	AND tps.partner_id = tp2.partner_id
	and tps.sr_instance_id = tp2.sr_instance_id
	AND	tp2.partner_type = tps.partner_type
	AND tps.partner_site_id = p_tx_supplier_site_id
	and (p_tx_supplier_site_id is not null or rownum = 1)
	AND itm.plan_id = MSC_X_NETTING_PKG.G_PLAN_ID
	AND  itm.organization_id =  tp.sr_tp_id
	AND     itm.sr_instance_id = tp.sr_instance_id
	AND itm.inventory_item_id = p_tx_item_id
	AND     itm.vmi_flag = 1
	AND     NVL(itm.enable_vmi_auto_replenish_flag, 'N') = 'N'
	AND msi.inventory_item_id = itm.inventory_item_id
	AND     msi.sr_instance_id = itm.sr_instance_id
	AND msi.plan_id = itm.plan_id
	AND msi.ORGANIZATION_ID = itm.organization_id
       ;

BEGIN

   print_debug_info ( 'START of VMI exception engine ');
   print_debug_info ( '  refresh number/replenish time fence = '
                 || p_refresh_number ||'/'
                 || p_replenish_time_fence
                 );

   --customer posting onhand data, supplier posting intransit data
   --supplier centric
   --dbms_output.put_line('Exception 9 and 29');
   open exception_9_29( p_refresh_number);
   loop
      --Initialize local variables
      l_item_max                        := null;
      l_item_min                        := null;
      l_exception_type                  := null;
      l_exception_group                 := null;
      l_generate_complement             := null;
      l_obs_exception                   := null;
      l_exc_generated	                := null;
      l_supplier_id                     := null;
      l_supplier_site_id                := null;
      l_customer_id                     := null;
      l_customer_site_id                := null;
      l_publisher_id	                := null;
      l_publisher_site_id               := null;
      l_item_id	                        := null;
      l_item_name			:= null;
      l_item_desc			:= null;
      l_publisher_name		        := null;
      l_publisher_site_name		:= null;
      l_supplier_name			:= null;
      l_supplier_site_name		:= null;
      l_supplier_item_name		:= null;
      l_supplier_item_desc		:= null;
      l_customer_name			:= null;
      l_customer_site_name		:= null;
      l_customer_item_name		:= null;
      l_customer_item_desc		:= null;
      l_exception_type_name		:= null;
      l_exception_group_name		:= null;
      l_total_supply                    := null;
      l_lead_time                       := null;
      l_time_fence_end_date             := null;
      l_asn_quantity                    := null;
      l_allocated_onhand_quantity       := null;
      l_shipment_receipt_quantity       := null;
      l_requisition_quantity            := null;
      l_po_quantity                     := null;
      l_total_onorder                   := null;
      l_automatic_allowed_flag          := null;
      l_aps_organization_id             := null;
      l_aps_supplier_id                 := null;
      l_aps_supplier_site_id            := null;
      l_sr_instance_id                  := null;

        l_min_minmax_days := NULL;
        l_max_minmax_days := NULL;
        l_fixed_order_quantity := NULL;
        l_average_daily_demand := NULL;
        l_vmi_refresh_flag := NULL;
        l_lower_limit_quantity := NULL;
        l_upper_limit_quantity := NULL;
        l_replenishment_method := NULL;
        l_row_ret  := FALSE;

      fetch exception_9_29
	into l_customer_id,
	     l_customer_site_id,
	     l_publisher_id,
	     l_publisher_site_id,
	     l_item_id,
             l_aps_organization_id,
             l_aps_supplier_id,
             l_aps_supplier_site_id,
             l_sr_instance_id;

      print_debug_info ( '  item/customer/customer site/publisher/publisher site/instance/org/supplier/supplier = '
			 || l_item_id || '/'
			 || l_customer_id || '/'
			 || l_customer_site_id || '/'
			 || l_publisher_id || '/'
			 || l_publisher_site_id || '/'
			 || l_sr_instance_id || '/'
			 || l_aps_organization_id || '/'
			 || l_aps_supplier_id || '/'
			 || l_aps_supplier_site_id
             );

      exit when exception_9_29%NOTFOUND;

--      dbms_output.put_line('After Loop - exception_9_29');

      OPEN c_asl_attributes ( l_item_id
                            , MSC_X_NETTING_PKG.G_PLAN_ID
                            , l_sr_instance_id
                            , l_aps_organization_id
                            , l_aps_supplier_id
                            , l_aps_supplier_site_id
                            );
      FETCH c_asl_attributes INTO l_item_min
                              , l_item_max
                              , l_lead_time
                              , l_automatic_allowed_flag
         , l_min_minmax_days
         , l_max_minmax_days
         , l_fixed_order_quantity
         , l_average_daily_demand
         , l_vmi_refresh_flag
         , l_replenishment_method
         ;
      CLOSE c_asl_attributes;

      print_debug_info ( '  min/max/lead time/min days/max days/replenishment method = ');
      print_debug_info ( '    '
			 || l_item_min || '/'
			 || l_item_max || '/'
			 || l_lead_time || '/'
			 || l_min_minmax_days || '/'
			 || l_max_minmax_days || '/'
             || l_replenishment_method
			 );
      print_debug_info ( '  fixed order quantity/average daily demand/vmi refresh flag = ');
      print_debug_info ( '    '
			 || l_fixed_order_quantity || '/'
			 || l_average_daily_demand || '/'
			 || l_vmi_refresh_flag
			 );

      OPEN c_item_attributes_9_29 ( l_item_id
                            , MSC_X_NETTING_PKG.G_PLAN_ID
                            , l_customer_site_id
                            , l_publisher_id
                            , l_publisher_site_id
                            );
      FETCH c_item_attributes_9_29 INTO l_customer_name,
		l_customer_site_name,
		l_customer_item_name,
		l_customer_item_desc,
		l_publisher_name,
		l_publisher_site_name,
		l_item_name,
		l_item_desc,
                l_supplier_item_name;

	print_user_info ( 'inside c_item_attributes_9_29 : customer/customer site/customer item/customer item desc/ '
                       || l_customer_name
                       || '/ ' || l_customer_site_name
                       || '/ ' || l_customer_item_name
                       || '/ ' || l_customer_item_desc
                       );
        l_row_ret := (c_item_attributes_9_29%NOTFOUND or c_item_attributes_9_29%NOTFOUND is null
	               or l_item_name is null ) ;

      CLOSE c_item_attributes_9_29;

      IF (l_row_ret = TRUE) THEN

     OPEN cust_sup_item_name_c(l_item_id
				, l_aps_organization_id
				, l_sr_instance_id
				, l_aps_supplier_id
				, l_aps_supplier_site_id ) ;

	FETCH cust_sup_item_name_c INTO l_customer_name,
		l_customer_site_name,
		l_customer_item_name,
		l_customer_item_desc,
		l_publisher_name,
		l_publisher_site_name,
		l_item_name,
		l_item_desc,
                l_supplier_item_name;

	print_user_info ( 'inside cust_sup_item_name_c : customer/customer site/customer item/customer item desc/ '
                       || l_customer_name
                       || '/ ' || l_customer_site_name
                       || '/ ' || l_customer_item_name
                       || '/ ' || l_customer_item_desc
                       );
	CLOSE cust_sup_item_name_c ;

	END IF;

	 print_user_info ( '  customer/customer site/customer item/customer item desc'
                       || l_customer_name
                       || '/' || l_customer_site_name
                       || '/' || l_customer_item_name
                       || '/' || l_customer_item_desc
                       );

	 print_user_info ( '  publisher/publisher site/item/item/desc'
                       || '/' || l_publisher_name
                       || '/' || l_publisher_site_name
                       || '/' || l_item_name
                       || '/' || l_item_desc
                       );

      IF ( l_automatic_allowed_flag = 'N' or l_automatic_allowed_flag IS NULL) THEN
	 --dbms_output.put_line('Check for VMI item');
	 ----------------------------------------------------------
	 -- Since VMI will be calling from the netting and will not
	 -- confuse with the non-vmi items
	 -- Compute exceptions for non-vmi item
	 ----------------------------------------------------------

	 print_debug_info ( '  delete obsolete exception');

	 MSC_X_NETTING_PKG.delete_obsolete_exceptions
	   (l_publisher_id,
	    l_publisher_site_id,                --owning org
	    l_customer_id,
	    l_customer_site_id,
	    null,				--l_supplier_id,
	    null,				--l_supplier_site_id,
	    MSC_X_NETTING_PKG.G_MATERIAL_SHORTAGE,
	    MSC_X_NETTING_PKG.G_EXCEP9,
	    MSC_X_NETTING_PKG.G_EXCEP29,
	    l_item_id,
	    null,			        --l_start_date,
	    null,
	    MSC_X_NETTING_PKG.vmi
	    );

	 print_debug_info ( '  Number of obsolete exceptions deleted of type 9_29 = ' || SQL%ROWCOUNT);

	     -- bug# 4501946 : added delete procedure for exception type = 10, 30

        MSC_X_NETTING_PKG.delete_obsolete_exceptions(l_customer_id,
							    l_customer_site_id,
							    null,		  --customer_id
							    null,		  --customer_site_id
							    l_publisher_id,	  --supplier_id
							    l_publisher_site_id,  --supplier_site_id
							    MSC_X_NETTING_PKG.G_MATERIAL_SHORTAGE,
							    MSC_X_NETTING_PKG.G_EXCEP10,
							    MSC_X_NETTING_PKG.G_EXCEP30,
							    l_item_id,
							    null,
							    null,
							    MSC_X_NETTING_PKG.VMI);

         print_debug_info ( '  Number of obsolete exceptions deleted of type 10,30= ' || SQL%ROWCOUNT);




	 l_generate_complement := MSC_X_NETTING_PKG.generate_complement_exception(
										  l_customer_id,
										  l_customer_site_id,
										  l_item_id,
										  p_refresh_number,
										  MSC_X_NETTING_PKG.VMI,
										  MSC_X_NETTING_PKG.buyer
										  );

	 -- calculate the end date of the replenish time window
	 l_time_fence_end_date := SYSDATE + NVL(p_replenish_time_fence * l_lead_time, 0);

	 print_debug_info ( '  Time fence date = ' || l_time_fence_end_date);

	 -- compute total supply
	 OPEN c_asn_quantity( l_item_id
                            , MSC_X_NETTING_PKG.G_PLAN_ID
                            , l_customer_id
                            , l_customer_site_id
                            , l_publisher_id
                            , l_publisher_site_id
                            , l_time_fence_end_date
                            ) ;
	 FETCH c_asn_quantity
	   INTO l_asn_quantity;
	 CLOSE c_asn_quantity;

	 OPEN c_allocated_onhand_quantity ( l_item_id
					    , MSC_X_NETTING_PKG.G_PLAN_ID
					    , l_customer_id
					    , l_customer_site_id
					    , l_publisher_id
					    , l_publisher_site_id
					    , l_time_fence_end_date
					    );
	 FETCH c_allocated_onhand_quantity
	   INTO l_allocated_onhand_quantity;
	 CLOSE c_allocated_onhand_quantity;

	 OPEN c_shipment_receipt_quantity( l_item_id
					   , MSC_X_NETTING_PKG.G_PLAN_ID
					   , l_customer_id
					   , l_customer_site_id
					   , l_publisher_id
					   , l_publisher_site_id
					   , l_time_fence_end_date
					   );
	 FETCH c_shipment_receipt_quantity INTO l_shipment_receipt_quantity;
	 CLOSE c_shipment_receipt_quantity;

	 OPEN c_requisition_quantity( l_item_id
				      , MSC_X_NETTING_PKG.G_PLAN_ID
				      , l_customer_id
				      , l_customer_site_id
				      , l_publisher_id
				      , l_publisher_site_id
				      , l_time_fence_end_date
				      );
	 FETCH c_requisition_quantity INTO l_requisition_quantity;
	 CLOSE c_requisition_quantity;

	 OPEN c_po_quantity( l_item_id
			     , MSC_X_NETTING_PKG.G_PLAN_ID
			     , l_customer_id
			     , l_customer_site_id
			     , l_publisher_id
			     , l_publisher_site_id
			     , l_time_fence_end_date
			     );
	 FETCH c_po_quantity INTO l_po_quantity;
	 CLOSE c_po_quantity;

	 print_user_info ( '  Supply quantity: asn/onhand/receipt/req/po = '
			    || l_asn_quantity || '-'
			    || l_allocated_onhand_quantity || '-'
			    || l_shipment_receipt_quantity || '-'
			    || l_requisition_quantity || '-'
			    || l_po_quantity
			    );

	 l_total_supply := NVL(l_asn_quantity, 0) + NVL(l_allocated_onhand_quantity, 0)
	                + NVL(l_shipment_receipt_quantity, 0) + NVL(l_requisition_quantity, 0)
                        + NVL(l_po_quantity, 0)
                        ;
	 l_total_onorder := ROUND ( NVL(l_asn_quantity, 0)
                        + NVL(l_shipment_receipt_quantity, 0) + NVL(l_requisition_quantity, 0)
                        + NVL(l_po_quantity, 0)
                        , 6);
	 l_allocated_onhand_quantity := ROUND( NVL(l_allocated_onhand_quantity, 0), 6);

	 print_user_info ( '  total supply/total onorder/total onhand = '
			    || l_total_supply || '-'
			    || l_total_onorder || '-'
			    || l_allocated_onhand_quantity
			    );

     IF (l_replenishment_method =1 OR l_replenishment_method = 3) THEN
       l_lower_limit_quantity := l_item_min;
     ELSE
       l_lower_limit_quantity := l_min_minmax_days * l_average_daily_demand;
     END IF;

     IF (l_replenishment_method =1 OR l_replenishment_method = 3) THEN
       l_upper_limit_quantity := l_item_max;
     ELSE
       l_upper_limit_quantity := l_max_minmax_days * l_average_daily_demand;
     END IF;

	 print_user_info ( '  lower limit quantity/upper limit quantity = '
			    || l_lower_limit_quantity || '-'
			    || l_upper_limit_quantity
			    );

	 if l_total_supply < l_lower_limit_quantity then
	    --exception 2.5 detected
	    l_exception_type := MSC_X_NETTING_PKG.G_EXCEP9;	--vmi item shortage customer site
	    l_exception_group := MSC_X_NETTING_PKG.G_MATERIAL_SHORTAGE;
	    l_exception_type_name := MSC_X_NETTING_PKG.GET_MESSAGE_TYPE (l_exception_type);
	    l_exception_group_name := MSC_X_NETTING_PKG.GET_MESSAGE_GROUP (l_exception_group);

	    print_user_info ( '  VMI item shortage at customer site');

	    MSC_X_NETTING_PKG.update_exceptions_summary(l_publisher_id,
							l_publisher_site_id,
							l_item_id,
							l_exception_type,
							l_exception_group);

	    print_debug_info ( '  exception summary updated');

	    MSC_X_NETTING_PKG.add_exception_details(l_publisher_id,
						    l_publisher_name,
						    l_publisher_site_id,
						    l_publisher_site_name,
						    l_item_id,
						    l_item_name,
						    l_item_desc,
						    l_exception_type,
						    l_exception_type_name,
						    l_exception_group,
						    l_exception_group_name,
						    null,                        --l_trx_id1,
						    null,                        --l_trx_id2,
						    l_customer_id,
						    l_customer_name,
						    l_customer_site_id,
						    l_customer_site_name,
						    l_customer_item_name,
						    null,		         --l_supplier_id,
						    null,
						    null,		         --l_supplier_site_id,
						    null,
						    l_supplier_item_name,
						    null,                        -- l_replenishment_quantity
						    l_total_onorder,             -- l_tp_total_intransit,
						    l_allocated_onhand_quantity, -- l_posting_total_onhand,
						    null,			 --threshold
						    null,			 --lead time
						    l_lower_limit_quantity, -- l_item_min,		         --item min
	                        l_upper_limit_quantity, -- l_item_max,		         --item_max
                                        	    null,                        --l_order_number,
			                            null,                        --l_release_number,
			                            null,                        --l_line_number,
			                            null,                        --l_end_order_number,
			                            null,                        --l_end_order_rel_number,
			                            null,                        --l_end_order_line_number,
			                            null,		         --l_actual_date or bucket start date,
			                            null,		      	 --l_tp_actual_date or bucket end date,
			                            null,                        --l_creation_date,
			                            null,                        --l_tp_creation_date,
	                       	            null                         --l_other_date
                                      , l_replenishment_method
                                      );

	    print_debug_info ( '  exception detail added');

	    if l_generate_complement then
	       --dbms_output.put_line('In complement exception 9');
	       l_exception_type := MSC_X_NETTING_PKG.G_EXCEP10;	--vmi item shortage at your site
	       l_exception_group := MSC_X_NETTING_PKG.G_MATERIAL_SHORTAGE;
	       l_exception_type_name := MSC_X_NETTING_PKG.GET_MESSAGE_TYPE (l_exception_type);
	       l_exception_group_name := MSC_X_NETTING_PKG.GET_MESSAGE_GROUP (l_exception_group);

	       l_obs_exception := MSC_X_NETTING_PKG.G_EXCEP30;	--VMI item excess at sup site

	       print_user_info ( '  VMI item excess at your site');

	      -- bug# 4501946 : removed delete procedure from here and called in the beginning ----

	       MSC_X_NETTING_PKG.update_exceptions_summary(l_customer_id,
							   l_customer_site_id,
							   l_item_id,
							   l_exception_type,
							   l_exception_group);

	       MSC_X_NETTING_PKG.add_exception_details(l_customer_id,
						       l_customer_name,
						       l_customer_site_id,
						       l_customer_site_name,
						       l_item_id,
						       l_item_name,
						       l_item_desc,
						       l_exception_type,
						       l_exception_type_name,
						       l_exception_group,
						       l_exception_group_name,
						       null,			--l_trx_id1,
						       null,                    --l_trx_id2,
						       null,			--l_customer_id,
						       null,
						       null,			--l_customer_site_id,
						       null,
						       l_customer_item_name,
						       l_publisher_id,          --l_supplier_id
						       l_publisher_name,
						       l_publisher_site_id,     --l_supplier_site_id
						       l_publisher_site_name,
						       l_supplier_item_name,
						       null,                    -- l_replenishment_quantity
						       l_total_onorder,         -- l_posting_total_intransit,
						       l_allocated_onhand_quantity, -- l_tp_total_onhand,
		                                       null,			--threshold
					               null,			--lead time
					               l_lower_limit_quantity, -- l_item_min,              -- l_conv_item_min,
					               l_upper_limit_quantity, -- l_item_max,              -- l_conv_item_max
					               null,			--l_order_number,
					               null,			--l_release_number,
					               null,			--l_line_number,
					               null,                    --l_end_order_number,
					               null,                    --l_end_order_rel_number,
					               null,                    --l_end_order_line_number,
					               null,			--l_actual_date or bucket start date,
					               null,	             	--l_tp_actual_date or bucket end date,
					               null,			--l_creation_date,
					               null,                    --l_tp_creation_date,
	                   		       null                   --l_other
                                 , l_replenishment_method
                                 );

	       print_debug_info ( '  exception detail added');
	    end if;

	elsif l_total_supply > l_upper_limit_quantity then

	    print_user_info( '  VMI item excess at customer site');

	    --exception 7.5 detected
	    l_exception_type := MSC_X_NETTING_PKG.G_EXCEP29;	--VMI item excess customer site
	    l_exception_group := MSC_X_NETTING_PKG.G_MATERIAL_EXCESS;
	    l_exception_type_name := MSC_X_NETTING_PKG.GET_MESSAGE_TYPE (l_exception_type);
	    l_exception_group_name := MSC_X_NETTING_PKG.GET_MESSAGE_GROUP (l_exception_group);

	    MSC_X_NETTING_PKG.update_exceptions_summary(l_publisher_id,
                                      l_publisher_site_id,
                                      l_item_id,
                                      l_exception_type,
                                      l_exception_group);

	    print_debug_info ( '  exception summary updated');

	    MSC_X_NETTING_PKG.add_exception_details(l_publisher_id,
      				l_publisher_name,
			        l_publisher_site_id,
			        l_publisher_site_name,
			        l_item_id,
			        l_item_name,
			        l_item_desc,
			        l_exception_type,
			        l_exception_type_name,
			        l_exception_group,
			        l_exception_group_name,
			        null,                   --l_trx_id1,
			        null,                   --l_trx_id2,
			        l_customer_id,
			        l_customer_name,
			        l_customer_site_id,
			        l_customer_site_name,
                                l_customer_item_name,
			        null,			--l_supplier_id,
			        null,
			        null,			--l_supplier_site_id,
			        null,
			        l_supplier_item_name,
			        null,                   -- (l_total_supply - l_item_max)
			        l_total_onorder,        -- l_tp_total_intransit,
			        l_allocated_onhand_quantity, -- l_posting_total_onhand,
			        null,			--threshold,
			       	null,			--lead time
			     	l_lower_limit_quantity, -- l_item_min,		--l_item_min,
				    l_upper_limit_quantity, -- l_item_max,
			        null,                   --l_order_number,
			        null,                   --l_release_number,
			        null,                   --l_line_number,
			        null,                   --l_end_order_number,
			        null,                   --l_end_order_rel_number,
			        null,                   --l_end_order_line_number,
			        null,		        --l_actual_date or bucket start date,
			        null,		      	--l_tp_actual_date or bucket end date,
			        null,                   --l_creation_date,
			        null,                   --l_tp_creation_date,
	                null                  --l_other_date
                    , l_replenishment_method
                    );

	    print_debug_info ( '  exception detail added');

	    if l_generate_complement then
	       --dbms_output.put_line('In complement exception 29');
	       l_exception_type := MSC_X_NETTING_PKG.G_EXCEP30;	--VMI item excess at your site
	       l_exception_group := MSC_X_NETTING_PKG.G_MATERIAL_EXCESS;
	       l_exception_type_name := MSC_X_NETTING_PKG.GET_MESSAGE_TYPE (l_exception_type);
	       l_exception_group_name := MSC_X_NETTING_PKG.GET_MESSAGE_GROUP (l_exception_group);

	       l_obs_exception := 10;	--outbound consignment item shortage at sup site

	       print_debug_info ( '  vmi item excess at your site (complement exception)');

	      -- bug# 4501946 : removed delete procedure from here and called in the beginning ----

	     --  print_debug_info ( '  obsolete exception deleted');

	       MSC_X_NETTING_PKG.update_exceptions_summary(l_customer_id,
							   l_customer_site_id,
							   l_item_id,
							   l_exception_type,
							   l_exception_group);

	       print_debug_info ( '  exception summary updated');

	       MSC_X_NETTING_PKG.add_exception_details(l_customer_id,
						       l_customer_name,
						       l_customer_site_id,
						       l_customer_site_name,
						       l_item_id,
						       l_item_name,
						       l_item_desc,
						       l_exception_type,
						       l_exception_type_name,
						       l_exception_group,
						       l_exception_group_name,
						       null,			--l_trx_id1,
						       null,                    --l_trx_id2,
						       null,		        --l_customer_id,
						       null,
						       null,	                --l_customer_site_id,
						       null,
						       l_customer_item_name,
						       l_publisher_id,          --l_supplier_id
						       l_publisher_name,
						       l_publisher_site_id,     --l_supplier_site_id
						       l_publisher_site_name,
						       l_supplier_item_name,
						       null,                    --(l_total_supply - l_item_max),
						       l_total_onorder,         --l_posting_total_intransit,
						       l_allocated_onhand_quantity, --l_tp_total_onhand,
		                                       null,			--threshold
					               null,			--lead time
					               l_lower_limit_quantity, -- l_item_min,              --l_conv_item_min,
					               l_upper_limit_quantity, -- l_item_max,              --l_conv_item_max,
					               null,			--l_order_number,
					               null,			--l_release_number,
					               null,			--l_line_number,
					               null,                    --l_end_order_number,
					               null,                    --l_end_order_rel_number,
					               null,                    --l_end_order_line_number,
					               null,			--l_actual_date or bucket start date,
					               null,	             	--l_tp_actual_date or bucket end date,
					               null,			--l_creation_date,
					               null,                    --l_tp_creation_date,
	                   		       null                   --l_other_
	                             , l_replenishment_method
                                 );
        end if;

	    print_debug_info ( '  exception detail added');

	 end if;
      END IF; -- ( l_automatic_allowed_flag = 'N' or l_automatic_allowed_flag IS NULL)
   end loop;
   close exception_9_29;
   print_debug_info('Done: ' ||MSC_X_NETTING_PKG.get_message_type(9) || ',' || MSC_X_NETTING_PKG.get_message_type(29) || ':' || sysdate);


   --=================================================================================

   --seller centric
   -- l_partner_site_id := null;
   -- l_sr_instance_id  := null;
   -- l_vmi_item_found := false;

   --      dbms_output.put_line('Exception 10 and 20');

--      dbms_output.put_line('Before Loop - exception_10_30');

   open exception_10_30(p_refresh_number);
   loop
      l_item_max                        := null;
      l_item_min                        := null;
      l_exception_type                  := null;
      l_exception_group                 := null;
      l_generate_complement             := null;
      l_obs_exception	                := null;
      l_exc_generated	                := null;
      l_supplier_id                     := null;
      l_supplier_site_id                := null;
      l_customer_id                     := null;
      l_customer_site_id                := null;
      l_publisher_id	                := null;
      l_publisher_site_id               := null;
      l_item_id	                        := null;
      l_item_name			:= null;
      l_item_desc			:= null;
      l_publisher_name		        := null;
      l_publisher_site_name		:= null;
      l_supplier_name			:= null;
      l_supplier_site_name		:= null;
      l_supplier_item_name		:= null;
      l_supplier_item_desc		:= null;
      l_customer_name			:= null;
      l_customer_site_name		:= null;
      l_customer_item_name		:= null;
      l_customer_item_desc		:= null;
      l_exception_type_name		:= null;
      l_exception_group_name		:= null;
      l_total_supply                    := null;
      l_lead_time                       := null;
      l_time_fence_end_date             := null;
      l_asn_quantity                    := null;
      l_allocated_onhand_quantity       := null;
      l_shipment_receipt_quantity       := null;
      l_requisition_quantity            := null;
      l_po_quantity                     := null;
      l_total_onorder                   := null;
      l_automatic_allowed_flag          := null;
      l_aps_organization_id             := null;
      l_aps_supplier_id                 := null;
      l_aps_supplier_site_id            := null;
      l_sr_instance_id                  := null;
      l_row_ret := FALSE;

      fetch exception_10_30
	into l_supplier_id,
	     l_supplier_site_id,
	     l_publisher_id,
	     l_publisher_site_id,
	     l_item_id,
             l_aps_organization_id,
             l_aps_supplier_id,
             l_aps_supplier_site_id,
             l_sr_instance_id;

   print_debug_info ( '  item/customer/customer site/publisher/publisher site/instance/org/supplier/supplier = '
			 || l_item_id || '/'
			 || l_customer_id || '/'
			 || l_customer_site_id || '/'
			 || l_publisher_id || '/'
			 || l_publisher_site_id || '/'
			 || l_sr_instance_id || '/'
			 || l_aps_organization_id || '/'
			 || l_aps_supplier_id || '/'
			 || l_aps_supplier_site_id
             );

      exit when exception_10_30%NOTFOUND;


--      dbms_output.put_line('After Loop - exception_10_30');


      OPEN c_asl_attributes ( l_item_id
                            , MSC_X_NETTING_PKG.G_PLAN_ID
                            , l_sr_instance_id
                            , l_aps_organization_id
                            , l_aps_supplier_id
                            , l_aps_supplier_site_id
                            );
      FETCH c_asl_attributes INTO l_item_min
                              , l_item_max
                              , l_lead_time
                              , l_automatic_allowed_flag
         , l_min_minmax_days
         , l_max_minmax_days
         , l_fixed_order_quantity
         , l_average_daily_demand
         , l_vmi_refresh_flag
         , l_replenishment_method
                              ;
      CLOSE c_asl_attributes;

      print_debug_info ( '  min/max/lead time/min days/max days/replenishment method = ');
      print_debug_info ( '    '
			 || l_item_min || '/'
			 || l_item_max || '/'
			 || l_lead_time || '/'
			 || l_min_minmax_days || '/'
			 || l_max_minmax_days || '/'
             || l_replenishment_method
			 );
      print_debug_info ( '  fixed order quantity/average daily demand/vmi refresh flag = ');
      print_debug_info ( '    '
			 || l_fixed_order_quantity || '/'
			 || l_average_daily_demand || '/'
			 || l_vmi_refresh_flag
			 );

      OPEN c_item_attributes_10_30 ( l_item_id
				     , MSC_X_NETTING_PKG.G_PLAN_ID
				     , l_publisher_site_id -- l_customer_site_id
				     , l_supplier_id
				     , l_supplier_site_id
				     );
      FETCH c_item_attributes_10_30
	INTO l_supplier_name,
	     l_supplier_site_name,
	     l_supplier_item_name,
	     l_supplier_item_desc,
	     l_publisher_name,
	     l_publisher_site_name,
	     l_item_name,
	     l_item_desc,
	     l_customer_item_name;

	 print_user_info ( '  supplier/supplier site/supplier item/supplier item desc = '
                       || l_supplier_name
                       || '/' || l_supplier_site_name
                       || '/' || l_supplier_item_name
                       || '/' || l_supplier_item_desc
                       );

	 print_user_info ( '  publisher/publisher site/item/item desc/cosotmer item = '
                       || '/' || l_publisher_name
                       || '/' || l_publisher_site_name
                       || '/' || l_item_name
                       || '/' || l_item_desc
                       || '/' || l_customer_item_name
                      );

      CLOSE c_item_attributes_10_30;

      IF ( l_automatic_allowed_flag = 'N' or l_automatic_allowed_flag IS NULL) THEN
	 --dbms_output.put_line('Check for VMI item');
	 ----------------------------------------------------------
	 -- Since VMI will be calling from the netting and will not
	 -- confuse with the non-vmi items
	 -- Compute exceptions for non-vmi item
	 ----------------------------------------------------------

	 print_debug_info ( '  delete obsolete exception');

	 MSC_X_NETTING_PKG.delete_obsolete_exceptions(l_publisher_id,
						      l_publisher_site_id,		--owning org
						      null,				--l_customer_id,
						      null,				--l_customer_site_id,
						      l_supplier_id,
						      l_supplier_site_id,
						      MSC_X_NETTING_PKG.G_MATERIAL_SHORTAGE,
						      MSC_X_NETTING_PKG.G_EXCEP10,
						      MSC_X_NETTING_PKG.G_EXCEP30,
						      l_item_id,
						      null,			        --l_start_date,
						      null,
						      MSC_X_NETTING_PKG.VMI);

	 print_debug_info ( '  Number of obsolete exceptions deleted = ' || SQL%ROWCOUNT);

	  -- bug# 4501946 : added delete procedure for exception type 9, 29 ----

	 MSC_X_NETTING_PKG.delete_obsolete_exceptions(l_supplier_id,
							    l_supplier_site_id,
							    l_publisher_id,		--customer_id
							    l_publisher_site_id,	--customer_site_id
							    null,			--supplier_id
							    null,			--supplier_site_id
							    MSC_X_NETTING_PKG.G_MATERIAL_SHORTAGE,
							    MSC_X_NETTING_PKG.G_EXCEP9,
							    MSC_X_NETTING_PKG.G_EXCEP29,
							    l_item_id,
							    null,
							    null,
							    MSC_X_NETTING_PKG.VMI);
        print_debug_info ( '  Number of obsolete exceptions deleted of type 9, 29 = ' || SQL%ROWCOUNT);

	 l_generate_complement := MSC_X_NETTING_PKG.generate_complement_exception(l_supplier_id,
										  l_supplier_site_id,
										  l_item_id,
										  p_refresh_number,
										  MSC_X_NETTING_PKG.VMI,
										  MSC_X_NETTING_PKG.SELLER);

	 -- calculate the end date of the replenish time window
	 l_time_fence_end_date := SYSDATE + NVL(p_replenish_time_fence * l_lead_time, 0);

	 print_debug_info ( '  Time fence date = ' || l_time_fence_end_date);

	 -- compute total supply
	 OPEN c_asn_quantity( l_item_id
                            , MSC_X_NETTING_PKG.G_PLAN_ID
                            , l_publisher_id
                            , l_publisher_site_id
                            , l_supplier_id
                            , l_supplier_site_id
                            , l_time_fence_end_date
                            );
	 FETCH c_asn_quantity
	   INTO l_asn_quantity;
	 CLOSE c_asn_quantity;

	 OPEN c_allocated_onhand_quantity ( l_item_id
                            , MSC_X_NETTING_PKG.G_PLAN_ID
                            , l_publisher_id
                            , l_publisher_site_id
                            , l_supplier_id
                            , l_supplier_site_id
                            , l_time_fence_end_date
                            );
	 FETCH c_allocated_onhand_quantity
	   INTO l_allocated_onhand_quantity;
	 CLOSE c_allocated_onhand_quantity;

	 OPEN c_shipment_receipt_quantity( l_item_id
                            , MSC_X_NETTING_PKG.G_PLAN_ID
                            , l_publisher_id
                            , l_publisher_site_id
                            , l_supplier_id
                            , l_supplier_site_id
                            , l_time_fence_end_date
                            );
	 FETCH c_shipment_receipt_quantity INTO l_shipment_receipt_quantity;
	 CLOSE c_shipment_receipt_quantity;

	 OPEN c_requisition_quantity( l_item_id
                            , MSC_X_NETTING_PKG.G_PLAN_ID
                            , l_publisher_id
                            , l_publisher_site_id
                            , l_supplier_id
                            , l_supplier_site_id
                            , l_time_fence_end_date
                            );
	 FETCH c_requisition_quantity INTO l_requisition_quantity;
	 CLOSE c_requisition_quantity;

	 OPEN c_po_quantity( l_item_id
                            , MSC_X_NETTING_PKG.G_PLAN_ID
                            , l_publisher_id
                            , l_publisher_site_id
                            , l_supplier_id
                            , l_supplier_site_id
                            , l_time_fence_end_date
                            );
	 FETCH c_po_quantity INTO l_po_quantity;
	 CLOSE c_po_quantity;

	 print_user_info ( '  Supply quantity: asn/onhand/receipt/req/po = '
			    || l_asn_quantity || '-'
			    || l_allocated_onhand_quantity || '-'
			    || l_shipment_receipt_quantity || '-'
			    || l_requisition_quantity || '-'
			    || l_po_quantity
			    );

	 l_total_supply := NVL(l_asn_quantity, 0) + NVL(l_allocated_onhand_quantity, 0)
                        + NVL(l_shipment_receipt_quantity, 0) + NVL(l_requisition_quantity, 0)
                        + NVL(l_po_quantity, 0)
                        ;
	 l_total_onorder := ROUND ( NVL(l_asn_quantity, 0)
                        + NVL(l_shipment_receipt_quantity, 0) + NVL(l_requisition_quantity, 0)
                        + NVL(l_po_quantity, 0)
                        , 6);
	 l_allocated_onhand_quantity := ROUND( NVL(l_allocated_onhand_quantity, 0), 6);

	 print_user_info ( '  total supply/total onorder/total onhand = '
			    || l_total_supply || '-'
			    || l_total_onorder || '-'
			    || l_allocated_onhand_quantity
			    );

     IF (l_replenishment_method = 1 OR l_replenishment_method = 3) THEN
       l_lower_limit_quantity := l_item_min;
     ELSE
       l_lower_limit_quantity := l_min_minmax_days * l_average_daily_demand;
     END IF;

     IF (l_replenishment_method = 1 OR l_replenishment_method = 3) THEN
       l_upper_limit_quantity := l_item_max;
     ELSE
       l_upper_limit_quantity := l_max_minmax_days * l_average_daily_demand;
     END IF;

	 print_user_info ( '  lower limit quantity/upper limit quantity = '
			    || l_lower_limit_quantity || '-'
			    || l_upper_limit_quantity
			    );

	 if l_total_supply < l_lower_limit_quantity then
	    l_exception_type := MSC_X_NETTING_PKG.G_EXCEP10;	--VMI item shortage at sup site
	    l_exception_group := MSC_X_NETTING_PKG.G_MATERIAL_SHORTAGE;
	    l_exception_type_name := MSC_X_NETTING_PKG.GET_MESSAGE_TYPE (l_exception_type);
	    l_exception_group_name := MSC_X_NETTING_PKG.GET_MESSAGE_GROUP (l_exception_group);

	    print_user_info ( '  VMI item shortage at customer site');

	    MSC_X_NETTING_PKG.update_exceptions_summary(l_publisher_id,
					l_publisher_site_id,
					l_item_id,
					l_exception_type,
				       	l_exception_group);

	    print_debug_info ( '  exception summary updated');

	    MSC_X_NETTING_PKG.add_exception_details(l_publisher_id,
					l_publisher_name,
					l_publisher_site_id,
					l_publisher_site_name,
					l_item_id,
					l_item_name,
					l_item_desc,
					l_exception_type,
					l_exception_type_name,
					l_exception_group,
					l_exception_group_name,
					null,                        --l_trx_id1,
				      	null,                        --l_trx_id2,
				      	null,			     --l_customer_id,
				      	null,
				      	null,			     --l_customer_site_id,
				      	null,
					l_customer_item_name,
				       	l_supplier_id,
				       	l_supplier_name,
				      	l_supplier_site_id,
				      	l_supplier_site_name,
				      	l_supplier_item_name,
				       	null,                        -- l_replenishment_quantity,
				       	l_total_onorder,             -- l_posting_total_intransit,
				       	l_allocated_onhand_quantity, -- l_tp_total_onhand,
			       		null,			     --threshold
				      	null,			     --lead time
					l_lower_limit_quantity, -- l_item_min,                  -- l_conv_item_min,
					l_upper_limit_quantity, -- l_item_max,                  -- l_conv_item_max,
				      	null,                        --l_order_number,
				       	null,                        --l_release_number,
				        null,                        --l_line_number,
				       	null,                        --l_end_order_number,
				       	null,                        --l_end_order_rel_number,
				      	null,                        --l_end_order_line_number,
				       	null,                        --l_actual_date or bucket start date,
				       	null,                        --l_tp_actual_date or bucket end date,
				       	null,                        --l_creation_date,
				       	null,                        --l_tp_creation_date,
	                    null                       --l_other_date
                      , l_replenishment_method
                      );

	    print_debug_info ( '  exception detail added');

	    if l_generate_complement then
	       --dbms_output.put_line('In complement exception 10');
	       l_exception_type := MSC_X_NETTING_PKG.G_EXCEP9;	--VMI item shortage at customer site
	       l_exception_group := MSC_X_NETTING_PKG.G_MATERIAL_SHORTAGE;
	       l_exception_type_name := MSC_X_NETTING_PKG.GET_MESSAGE_TYPE (l_exception_type);
	       l_exception_group_name := MSC_X_NETTING_PKG.GET_MESSAGE_GROUP (l_exception_group);

	       l_obs_exception := MSC_X_NETTING_PKG.G_EXCEP29;	--VMI item excess at your site

	       print_user_info ( '  VMI item shortage at customer site');

	       -- bug# 4501946 : removed delete procedure from here and called in the beginning ----

	       MSC_X_NETTING_PKG.update_exceptions_summary(l_supplier_id,
							   l_supplier_site_id,
							   l_item_id,
							   l_exception_type,
							   l_exception_group);
	       MSC_X_NETTING_PKG.add_exception_details(l_supplier_id,
						       l_supplier_name,
						       l_supplier_site_id,
						       l_supplier_site_name,
						       l_item_id,
						       l_item_name,
						       l_item_desc,
						       l_exception_type,
						       l_exception_type_name,
						       l_exception_group,
						       l_exception_group_name,
						       null,			--l_trx_id1,
						       null,                    --l_trx_id2,
						       l_publisher_id,		--l_customer_id,
						       l_publisher_name,
						       l_publisher_site_id,	--l_customer_site_id,
						       l_publisher_site_name,
						       l_customer_item_name,
						       null,            	--l_supplier_id
						       null,
						       null,                	--l_supplier_site_id
						       null,
						       l_supplier_item_name,
						       null,                    -- l_replenishment_quantity,
						       l_total_onorder,         -- l_tp_total_intransit,
						       l_allocated_onhand_quantity, -- l_posting_total_onhand,
		                                       null,			--threshold
						       null,			--lead time
						       l_lower_limit_quantity, -- l_item_min,
						       l_upper_limit_quantity, -- l_item_max,		--item_max
						       null,			--l_order_number,
						       null,			--l_release_number,
						       null,			--l_line_number,
						       null,                    --l_end_order_number,
						       null,                    --l_end_order_rel_number,
						       null,                    --l_end_order_line_number,
						       null,			--l_actual_date or bucket start date,
						       null,             	--l_tp_actual_date or bucket end date,
						       null,			--l_creation_date,
						       null,                    --l_tp_creation_date,
		 				       null 			--l_other_
                             , l_replenishment_method
                             );

	       print_debug_info ( '  exception detail added');

	    end if;
	  elsif l_total_supply > l_upper_limit_quantity then

	    print_user_info( '  VMI item excess at your site');

	    l_exception_type := MSC_X_NETTING_PKG.G_EXCEP30;
	    l_exception_group := MSC_X_NETTING_PKG.G_MATERIAL_EXCESS;
	    l_exception_type_name := MSC_X_NETTING_PKG.GET_MESSAGE_TYPE (l_exception_type);
	    l_exception_group_name := MSC_X_NETTING_PKG.GET_MESSAGE_GROUP (l_exception_group);

	    MSC_X_NETTING_PKG.update_exceptions_summary(l_publisher_id,
							l_publisher_site_id,
							l_item_id,
							l_exception_type,
							l_exception_group);

	    print_debug_info ( '  exception summary updated');

	    MSC_X_NETTING_PKG.add_exception_details(l_publisher_id,
						    l_publisher_name,
						    l_publisher_site_id,
						    l_publisher_site_name,
						    l_item_id,
						    l_item_name,
						    l_item_desc,
						    l_exception_type,
						    l_exception_type_name,
						    l_exception_group,
						    l_exception_group_name,
						    null,                   --l_trx_id1,
						    null,                   --l_trx_id2,
						    null,		    --l_customer_id,
						    null,
						    null,		    --l_customer_site_id,
						    null,
						    l_customer_item_name,
						    l_supplier_id,
						    l_supplier_name,
						    l_supplier_site_id,
						    l_supplier_site_name,
						    l_supplier_item_name,
						    null,                   -- (l_total_supply - l_item_max),
						    l_total_onorder,        -- l_posting_total_intransit,
						    l_allocated_onhand_quantity, -- l_tp_total_onhand,
						    null,		    --threshold
						    null,		    --lead time
	                        l_lower_limit_quantity, -- l_item_min,             -- l_conv_item_min,
				            l_upper_limit_quantity, -- l_item_max,             -- l_conv_item_max,
			                            null,                   --l_order_number,
			                            null,                   --l_release_number,
			                            null,                   --l_line_number,
			                            null,                   --l_end_order_number,
			                            null,                   --l_end_order_rel_number,
			                            null,                   --l_end_order_line_number,
			                            null,                   --l_actual_date or bucket start date,
			                            null,                   --l_tp_actual_date or bucket end date,
			                            null,                   --l_creation_date,
			                            null,                   --l_tp_creation_date,
	                      	            null                  --l_supplier_promise_date
                                      , l_replenishment_method
                                      );
	    print_debug_info ( '  exception detail added');

	    if l_generate_complement then
	       --dbms_output.put_line('In complement exception 30');
	       l_exception_type := MSC_X_NETTING_PKG.G_EXCEP29;	--VMI item excess at customer site
	       l_exception_group := MSC_X_NETTING_PKG.G_MATERIAL_EXCESS;
	       l_exception_type_name := MSC_X_NETTING_PKG.GET_MESSAGE_TYPE (l_exception_type);
	       l_exception_group_name := MSC_X_NETTING_PKG.GET_MESSAGE_GROUP (l_exception_group);
	       l_obs_exception := MSC_X_NETTING_PKG.G_EXCEP9;	--VMI item shortage at customer site

	       print_debug_info ( '  vmi item excess at customer site (complement exception)');

	      -- bug# 4501946 : removed delete procedure from here and called in the beginning ----

	       MSC_X_NETTING_PKG.update_exceptions_summary(l_supplier_id,
							   l_supplier_site_id,
							   l_item_id,
							   l_exception_type,
							   l_exception_group);

	       print_debug_info ( '  exception summary updated');

	       MSC_X_NETTING_PKG.add_exception_details(l_supplier_id,
						       l_supplier_name,
						       l_supplier_site_id,
						       l_supplier_site_name,
						       l_item_id,
						       l_item_name,
						       l_item_desc,
						       l_exception_type,
						       l_exception_type_name,
						       l_exception_group,
						       l_exception_group_name,
						       null,			--l_trx_id1,
						       null,                    --l_trx_id2,
						       l_publisher_id,		--l_customer_id,
						       l_publisher_name,
						       l_publisher_site_id,	--l_customer_site_id,
						       l_publisher_site_name,
						       l_customer_item_name,
						       null,            	--l_supplier_id
						       null,
						       null,                	--l_supplier_site_id
						       null,
						       l_supplier_item_name,
						       null,                    -- (l_total_supply - l_item_max),
						       l_total_onorder,         -- l_tp_total_intransit,
						       l_allocated_onhand_quantity, -- l_posting_total_onhand,
		                                       null,			--threshold,
					               null,			--lead time
				                   l_lower_limit_quantity, -- l_item_min,		--l_item_min,
					               l_upper_limit_quantity, -- l_item_max,
					               null,			--l_order_number,
					               null,			--l_release_number,
					               null,			--l_line_number,
					               null,                    --l_end_order_number,
					               null,                    --l_end_order_rel_number,
					               null,                    --l_end_order_line_number,
					               null,		        --l_actual_date or bucket start date,
					               null,                    --l_tp_actual_date or bucket end date,
					               null,			--l_creation_date,
					               null,                    --l_tp_creation_date,
		 			               null                   --l_supplier_promise_
                                 , l_replenishment_method
                                 );
	    end if;

	    print_debug_info ( '  exception detail added');

	 end if;
      END IF; -- ( l_automatic_allowed_flag = 'N' or l_automatic_allowed_flag IS NULL)
   end loop;
   close exception_10_30;

   commit;

   print_debug_info('Done: ' ||MSC_X_NETTING_PKG.get_message_type(10) || ',' || MSC_X_NETTING_PKG.get_message_type(30)
		    || ':' || sysdate);

   -------------------------------------------------------------
   --launch workflow here
   --------------------------------------------------------------
   print_debug_info('Launch workflow process');

   msc_x_wfnotify_pkg.launch_wf ( l_errbuf
				  , l_retnum
				  );

   -----------------------------------------------------------
   --Clean up at the end of the netting engine run
   -----------------------------------------------------------
   print_debug_info('Launch clear up process');

   clean_up_process;

   print_debug_info('END of the VMI exception engine');

END Compute_VMI_Exceptions;



----------------------------------------------------------------------
--PROCEDURE CLEAN_UP_PROCESS
--Clean up process only for the VMI exception types
-------------------------------------------------------------------------
PROCEDURE clean_up_process IS

BEGIN

	--dbms_output.put_line('Update the magic number');
	--Reset the records for which the workflows have been
	--kicked off, to prevent the create duplicate wf items
	update msc_x_exception_details
	set last_update_login = null
	where plan_id = MSC_X_NETTING_PKG.G_PLAN_ID
	and exception_type in (9, 10, 29, 30)
	and nvl(last_update_login,-1) = MSC_X_NETTING_PKG.G_MAGIC_NUMBER;

	--Update the last_update_login back to null to ensure accurate archival
	--when exceptions are generated in the next round

	update 	msc_item_exceptions ex
	set 	ex.last_update_login = null,
		ex.last_update_date = sysdate
	where 	ex.plan_id = MSC_X_NETTING_PKG.G_PLAN_ID
	and 	ex.version = 0
	and exception_type in (9, 10, 29, 30)
	and 	nvl(ex.last_update_login,-1) = MSC_X_NETTING_PKG.G_MAGIC_NUMBER;

	--update the if the count is 0 to older version
	update msc_item_exceptions ex
	set 	ex.version = version + 1,
		ex.last_update_date = sysdate
	where 	ex.plan_id = MSC_X_NETTING_PKG.G_PLAN_ID
	and	ex.version = 0
	and exception_type in (9, 10, 29, 30)
	and	ex.exception_count = 0;

	-- In prior release, we have kept a history of all the exceptions
	-- occuring during netting for intelligent analysis use such as
	-- exception convergence; overtime or latency of a plan in msc_item_exceptions
	-- table.  The current usage is using the latest version of the data and
	-- not all the history data.  If the table is maintaining all the history
	-- data, in the rolling of the netting engine run for a period of time,
	-- the table will grow quickly and create a performance problem.  Therefore,
	-- the table is arhived based on the user defined profile option and only keep
	-- certain number of version.  Default verion = 20

	delete	 msc_item_exceptions ex
	where 	plan_id = MSC_X_NETTING_PKG.G_PLAN_ID
	and exception_type in (9, 10, 29, 30)
	and   	version > 20;

	/***
	delete 	msc_item_exceptions
        where  	plan_id = G_PLAN_ID
        and	version = 0
        and	exception_count = 0;

         ***/

END CLEAN_UP_PROCESS;

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

END MSC_X_EX5_PKG;


/
