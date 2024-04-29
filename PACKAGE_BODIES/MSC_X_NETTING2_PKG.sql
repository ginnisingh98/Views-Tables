--------------------------------------------------------
--  DDL for Package Body MSC_X_NETTING2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_NETTING2_PKG" AS
/* $Header: MSCXEX2B.pls 120.5 2007/07/31 13:14:21 vsiyer ship $ */



--The cursor below selects the buckets generated for company/org combination
CURSOR time_bkts  IS
SELECT   trunc(b.bkt_start_date), trunc(b.bkt_end_date), b.bucket_type
FROM  msc_plan_buckets b
WHERE    b.plan_id = msc_x_netting_pkg.G_PLAN_ID;

--================================================================
--Group 2: Material Shortage
--================================================================
-------------------------------------------------------------------------------------
-- 2.1 Customer's demand within time bucket is greater than your supply: exception_5
-------------------------------------------------------------------------------------
--The p_company_id is the supplier and below exception cursor is for customer
--facing the exception

CURSOR exception_5 (p_refresh_number IN Number) IS
  select sd.publisher_id,
  	sd.publisher_site_id,
  	sd.supplier_id,
  	sd.supplier_site_id,
  	sd.customer_id,
  	sd.customer_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
  	bkt.bucket_index,
  	bkt.bkt_start_date,
  	bkt.bkt_end_date,
  	msc_x_netting_pkg.SUPPLY_COMMIT,
   	sd.publisher_name,
   	sd.publisher_site_name,
   	sd.supplier_name,
   	sd.supplier_site_name,
   	sd.customer_name,
   	sd.customer_site_name,
 	null,
 	null,
 	null,
 	null,
        nvl(sum(sd.primary_quantity),0),
  	nvl(sum(sd.tp_quantity),0),
  	nvl(sum(sd.quantity),0),
	nvl(max(sd.last_refresh_number),0)
  from msc_sup_dem_entries sd,
  	msc_cp_plan_buckets bkt
  where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
  and sd.publisher_id = bkt.supplier_id
  and sd.publisher_site_id = bkt.supplier_site_id
  and sd.customer_id = bkt.customer_id
  and sd.customer_site_id = bkt.customer_site_id
  and nvl(sd.base_item_id,sd.inventory_item_id) = bkt.inventory_item_id
  and sd.publisher_order_type = msc_x_netting_pkg.SUPPLY_COMMIT
  and sd.plan_id = bkt.plan_id
  and trunc(sd.key_date) between bkt.bkt_start_date and bkt.bkt_end_date
  group by sd.publisher_id,
  	sd.publisher_site_id,
  	sd.supplier_id,
  	sd.supplier_site_id,
  	sd.customer_id,
  	sd.customer_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
  	bkt.bucket_index,
  	bkt.bkt_start_date,
  	bkt.bkt_end_date,
   	sd.publisher_name,
   	sd.publisher_site_name,
   	sd.supplier_name,
   	sd.supplier_site_name,
   	sd.customer_name,
   	sd.customer_site_name
  UNION ALL
  select sd.supplier_id,
  	sd.supplier_site_id,
  	sd.supplier_id,
  	sd.supplier_site_id,
  	sd.publisher_id,
  	sd.publisher_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
   	bkt.bucket_index,
   	bkt.bkt_start_date,
   	bkt.bkt_end_date,
   	msc_x_netting_pkg.ORDER_FORECAST,
   	sd.supplier_name,
   	sd.supplier_site_name,
   	sd.supplier_name,
   	sd.supplier_site_name,
   	sd.publisher_name,
   	sd.publisher_site_name,
   	null,
   	null,
   	null,
   	null,
	nvl(sum(sd.primary_quantity),0),
 	nvl(sum(sd.tp_quantity),0),
   	nvl(sum(sd.quantity),0),
   	nvl(max(sd.last_refresh_number),0)
  from msc_sup_dem_entries sd,
  	msc_cp_plan_buckets bkt
  where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
  and sd.publisher_id = bkt.customer_id
  and sd.publisher_site_id = bkt.customer_site_id
  and nvl(sd.base_item_id,sd.inventory_item_id) = bkt.inventory_item_id
  and sd.publisher_order_type = msc_x_netting_pkg.ORDER_FORECAST
  and sd.supplier_id = bkt.supplier_id
  and sd.supplier_site_id = bkt.supplier_site_id
  and sd.plan_id = bkt.plan_id
  and trunc(sd.key_date) between bkt.bkt_start_date and bkt.bkt_end_date
  group by sd.supplier_id,
  	sd.supplier_site_id,
  	sd.supplier_id,
  	sd.supplier_site_id,
  	sd.publisher_id,
  	sd.publisher_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
  	bkt.bucket_index,
  	bkt.bkt_start_date,
  	bkt.bkt_end_date,
   	sd.supplier_name,
   	sd.supplier_site_name,
   	sd.supplier_name,
   	sd.supplier_site_name,
   	sd.publisher_name,
   	sd.publisher_site_name
 order by 1,2,3,4,5,6,7,8,9;

-----------------------------------------------------------------------------------------
--2.2 Supplier's supply within time bucket is less than your demand (SP) : exception_6
------------------------------------------------------------------------------------------
--The p_company_id is customer and below exception cursor is for supplier
--facing the exception

CURSOR exception_6(p_refresh_number In Number) IS
  select sd.publisher_id,
  	sd.publisher_site_id,
  	sd.customer_id,
  	sd.customer_site_id,
  	sd.supplier_id,
  	sd.supplier_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
   	bkt.bucket_index,
   	bkt.bkt_start_date,
   	bkt.bkt_end_date,
   	msc_x_netting_pkg.ORDER_FORECAST,
   	sd.publisher_name,
   	sd.publisher_site_name,
   	sd.customer_name,
   	sd.customer_site_name,
   	sd.supplier_name,
   	sd.supplier_site_name,
 	null,
 	null,
 	null,
 	null,
	nvl(sum(sd.primary_quantity),0),
 	nvl(sum(sd.tp_quantity),0),
      	nvl(sum(sd.quantity),0),
   	nvl(max(sd.last_refresh_number),0)
  from msc_sup_dem_entries sd,
  	msc_cp_plan_buckets bkt
  where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
  and sd.publisher_id = bkt.customer_id
  and sd.publisher_site_id = bkt.customer_site_id
  and nvl(sd.base_item_id,sd.inventory_item_id) = bkt.inventory_item_id
  and sd.publisher_order_type = msc_x_netting_pkg.ORDER_FORECAST
  and sd.supplier_id = bkt.supplier_id
  and sd.supplier_site_id = bkt.supplier_site_id
  and sd.plan_id = bkt.plan_id
  and trunc(sd.key_date) between bkt.bkt_start_date and bkt.bkt_end_date
  group by sd.publisher_id,
  	sd.publisher_site_id,
  	sd.customer_id,
  	sd.customer_site_id,
  	sd.supplier_id,
  	sd.supplier_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
  	bkt.bucket_index,
  	bkt.bkt_start_date,
  	bkt.bkt_end_date,
   	sd.publisher_name,
   	sd.publisher_site_name,
   	sd.customer_name,
   	sd.customer_site_name,
   	sd.supplier_name,
   	sd.supplier_site_name
  UNION ALL
  select sd.customer_id,
  	sd.customer_site_id,
  	sd.customer_id,
  	sd.customer_site_id,
  	sd.publisher_id,
  	sd.publisher_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
  	bkt.bucket_index,
  	bkt.bkt_start_date,
  	bkt.bkt_end_date,
  	msc_x_netting_pkg.SUPPLY_COMMIT,
   	sd.customer_name,
   	sd.customer_site_name,
   	sd.customer_name,
   	sd.customer_site_name,
   	sd.publisher_name,
   	sd.publisher_site_name,
   	null,
   	null,
   	null,
   	null,
        nvl(sum(sd.primary_quantity),0),
  	nvl(sum(sd.tp_quantity),0),
    	nvl(sum(sd.quantity),0),
  	nvl(max(sd.last_refresh_number),0)
  from msc_sup_dem_entries sd,
  	msc_cp_plan_buckets bkt
  where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
  and sd.publisher_id = bkt.supplier_id
  and sd.publisher_site_id = bkt.supplier_site_id
  and sd.customer_id = bkt.customer_id
  and sd.customer_site_id = bkt.customer_site_id
  and nvl(sd.base_item_id,sd.inventory_item_id) = bkt.inventory_item_id
  and sd.publisher_order_type = msc_x_netting_pkg.SUPPLY_COMMIT
  and sd.plan_id = bkt.plan_id
  and trunc(sd.key_date) between bkt.bkt_start_date and bkt.bkt_end_date
  group by sd.customer_id,
  	sd.customer_site_id,
  	sd.customer_id,
  	sd.customer_site_id,
  	sd.publisher_id,
  	sd.publisher_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
  	bkt.bucket_index,
  	bkt.bkt_start_date,
  	bkt.bkt_end_date,
    	sd.customer_name,
   	sd.customer_site_name,
   	sd.customer_name,
   	sd.customer_site_name,
   	sd.publisher_name,
   	sd.publisher_site_name
 order by 1,2,3,4,5,6,7,8,9;


------------------------------------------------------------------------------------------
-- group the order forecast and supply commit together and join to msc_plan_buckets--
-- this will improve the performace.
------------------------------------------------------------------------------------------

  cursor get_of_sc(p_customer_id IN NUMBER,
  			p_customer_site_id IN Number,
  			p_supplier_id IN Number,
  			p_supplier_site_id IN Number,
  			p_item_id IN Number,
  			p_cutoff_ref_num IN Number) IS
  select nvl(sum(sd.primary_quantity),0),
 	nvl(sum(sd.tp_quantity),0),
   	nvl(sum(sd.quantity),0),
   	bkt.bucket_index,
   	bkt.bkt_start_date,
   	bkt.bkt_end_date,
   	msc_x_netting_pkg.ORDER_FORECAST
  from msc_sup_dem_entries sd,
  	msc_plan_buckets bkt
  where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
  and sd.publisher_id = p_customer_id
  and sd.publisher_site_id = p_customer_site_id
  and nvl(sd.base_item_id,sd.inventory_item_id) = p_item_id
  and sd.publisher_order_type = msc_x_netting_pkg.ORDER_FORECAST
  and sd.supplier_id = p_supplier_id
  and sd.supplier_site_id = p_supplier_site_id
  and sd.plan_id = bkt.plan_id
  and trunc(sd.key_date) between bkt.bkt_start_date and bkt.bkt_end_date
  and sd.last_refresh_number <= p_cutoff_ref_num
  group by bkt.bucket_index, bkt.bkt_start_date, bkt.bkt_end_date
  UNION ALL
  select nvl(sum(sd.primary_quantity),0),
  	nvl(sum(sd.tp_quantity),0),
  	nvl(sum(sd.quantity),0),
  	bkt.bucket_index,
  	bkt.bkt_start_date,
  	bkt.bkt_end_date,
  	msc_x_netting_pkg.SUPPLY_COMMIT
  from msc_sup_dem_entries sd,
  	msc_plan_buckets bkt
  where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
  and sd.publisher_id = p_supplier_id
  and sd.publisher_site_id = p_supplier_site_id
  and sd.customer_id = p_customer_id
  and sd.customer_site_id = p_customer_site_id
  and nvl(sd.base_item_id,sd.inventory_item_id) = p_item_id
  and sd.publisher_order_type = msc_x_netting_pkg.SUPPLY_COMMIT
  and sd.plan_id = bkt.plan_id
  and trunc(sd.key_date) between bkt.bkt_start_date and bkt.bkt_end_date
  and sd.last_refresh_number <= p_cutoff_ref_num
 group by bkt.bucket_index, bkt.bkt_start_date, bkt.bkt_end_date
 order by 4,5,6;


-------------------------------------------------------------------------------------
--2.3 Fulfillment quantity shortfall for your customers purchase order : exception_7
------------------------------------------------------------------------------------
CURSOR exception_7(p_refresh_number IN Number) IS
SELECT  distinct sd1.transaction_id,
   sd1.publisher_id,
   sd1.publisher_name,
   sd1.publisher_site_id,
   sd1.publisher_site_name,
   sd1.inventory_item_id,
   sd1.item_name,
   sd1.item_description,
   sd1.supplier_item_name,
   sd1.supplier_item_description,
   sd1.key_date,
        sd1.ship_date,
        sd1.receipt_date,
        sd1.quantity,
        sd1.primary_quantity,
        sd1.tp_quantity,
        sd1.order_number,
        sd1.release_number,
        sd1.line_number,
        sd1.customer_id,
        sd1.customer_name,
        sd1.customer_site_id,
        sd1.customer_site_name,
        sd1.customer_item_name,
        sd1.customer_item_description,
        sd1.creation_date,
        sd1.last_refresh_number,
        sd2.transaction_id,
        sd2.key_date,
        sd2.ship_date,
        sd2.receipt_date,
        sd2.quantity,
        sd2.primary_quantity,
        sd2.tp_quantity,
        sd2.order_number,
        sd2.release_number,
        sd2.line_number,
        sd2.supplier_id,
        sd2.supplier_name,
        sd2.supplier_site_id,
        sd2.supplier_site_name,
        sd2.creation_date,
        sd2.last_refresh_number
FROM    msc_sup_dem_entries sd1,
        msc_sup_dem_entries sd2
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.publisher_order_type = msc_x_netting_pkg.SALES_ORDER
AND     sd2.plan_id = sd1.plan_id
AND     sd2.inventory_item_id = sd1.inventory_item_id
AND     sd2.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND   	sd2.supplier_id = sd1.publisher_id
AND   	sd2.supplier_site_id = sd1.publisher_site_id
AND	sd2.publisher_id = sd1.customer_id
AND	sd2.publisher_site_id = sd1.customer_site_id
AND     sd1.end_order_number = sd2.order_number
AND     nvl(sd1.end_order_rel_number,-1) =
                        nvl(sd2.release_number,-1)
AND     nvl(sd1.end_order_line_number,-1) =
                        nvl(sd2.line_number,-1)
AND     nvl(sd1.last_refresh_number,-1) >  nvl(p_refresh_number,-1)
order by sd1.publisher_id, sd1.publisher_site_id,
sd1.customer_id, sd1.customer_site_id, sd1.inventory_item_id,
sd2.order_number, sd2.release_number, sd2.line_number, sd1.key_date desc;

-------------------------------------------------------------------------------------------
--2.4 Fulfillment quantity shortfall from your supplier for your purchase order : exception_8
--------------------------------------------------------------------------------------------
CURSOR exception_8(p_refresh_number IN Number) IS
SELECT  distinct sd1.transaction_id,
   sd1.publisher_id,
   sd1.publisher_name,
   sd1.publisher_site_id,
   sd1.publisher_site_name,
   sd1.inventory_item_id,
   sd1.item_name,
   sd1.item_description,
        sd2.customer_item_name,
        sd2.customer_item_description,
        sd1.key_date,
        sd1.ship_date,
        sd1.receipt_date,
        sd1.quantity,
        sd1.primary_quantity,
        sd1.tp_quantity,
        sd1.order_number,
        sd1.release_number,
        sd1.line_number,
        sd1.supplier_id,
        sd1.supplier_name,
        sd1.supplier_site_id,
        sd1.supplier_site_name,
         sd1.supplier_item_name,
         sd1.supplier_item_description,
         sd1.creation_date,
         sd1.last_refresh_number,
        sd2.transaction_id,
        sd2.key_date,
        sd2.ship_date,
        sd2.receipt_date,
        sd2.quantity,
        sd2.primary_quantity,
        sd2.tp_quantity,
        sd2.order_number,
        sd2.release_number,
        sd2.line_number,
        sd2.customer_id,
        sd2.customer_name,
        sd2.customer_site_id,
        sd2.customer_site_name,
        sd2.creation_date,
        sd2.last_refresh_number
FROM    msc_sup_dem_entries sd1,
        msc_sup_dem_entries sd2
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND   	sd2.plan_id = sd1.plan_id
AND     sd2.publisher_order_type = msc_x_netting_pkg.SALES_ORDER
AND   	sd2.customer_id = sd1.publisher_id
AND   	sd2.customer_site_id = sd1.publisher_site_id
AND	sd2.publisher_id = sd1.supplier_id
AND	sd2.publisher_site_id = sd1.supplier_site_id
AND   	sd2.inventory_item_id = sd1.inventory_item_id
AND     sd1.order_number = sd2.end_order_number
AND     nvl(sd1.release_number,-1) =
                        nvl(sd2.end_order_rel_number,-1)
AND     nvl(sd1.line_number,-1) =
                        nvl(sd2.end_order_line_number,-1)
AND     nvl(sd1.last_refresh_number,-1) > nvl(p_refresh_number,-1)
order by sd1.publisher_id, sd1.publisher_site_id,
sd1.supplier_id, sd1.supplier_site_id, sd1.inventory_item_id,
sd1.order_number, sd1.release_number, sd1.line_number, sd2.key_date desc;


--=================================================================================
--GROUP: MATERIAL_EXCESS
-------------------------------------------------------------------------------------
-- 7.1 Customer's demand within time bucket is less than your supply: exception_25
-------------------------------------------------------------------------------------
--The p_company_id is the supplier and below exception cursor is for customer
--facing the exception

CURSOR exception_25(p_refresh_number IN Number) IS
  select sd.publisher_id,
  	sd.publisher_site_id,
  	sd.supplier_id,
  	sd.supplier_site_id,
  	sd.customer_id,
  	sd.customer_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
  	bkt.bucket_index,
  	bkt.bkt_start_date,
  	bkt.bkt_end_date,
  	msc_x_netting_pkg.SUPPLY_COMMIT,
   	sd.publisher_name,
   	sd.publisher_site_name,
   	sd.supplier_name,
   	sd.supplier_site_name,
   	sd.customer_name,
   	sd.customer_site_name,
 	null,
 	null,
 	null,
 	null,
        nvl(sum(sd.primary_quantity),0),
  	nvl(sum(sd.tp_quantity),0),
  	nvl(sum(sd.quantity),0),
  	nvl(max(sd.last_refresh_number),0)
  from msc_sup_dem_entries sd,
  	msc_cp_plan_buckets bkt
  where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
  and sd.publisher_id = bkt.supplier_id
  and sd.publisher_site_id = bkt.supplier_site_id
  and sd.customer_id = bkt.customer_id
  and sd.customer_site_id = bkt.customer_site_id
  and nvl(sd.base_item_id,sd.inventory_item_id) = bkt.inventory_item_id
  and sd.publisher_order_type = msc_x_netting_pkg.SUPPLY_COMMIT
  and sd.plan_id = bkt.plan_id
  and trunc(sd.key_date) between bkt.bkt_start_date and bkt.bkt_end_date
  group by sd.publisher_id,
  	sd.publisher_site_id,
  	sd.supplier_id,
  	sd.supplier_site_id,
  	sd.customer_id,
  	sd.customer_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
  	bkt.bucket_index,
  	bkt.bkt_start_date,
  	bkt.bkt_end_date,
   	sd.publisher_name,
   	sd.publisher_site_name,
   	sd.supplier_name,
   	sd.supplier_site_name,
   	sd.customer_name,
   	sd.customer_site_name
  UNION ALL
  select sd.supplier_id,
  	sd.supplier_site_id,
  	sd.supplier_id,
  	sd.supplier_site_id,
  	sd.publisher_id,
  	sd.publisher_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
   	bkt.bucket_index,
   	bkt.bkt_start_date,
   	bkt.bkt_end_date,
   	msc_x_netting_pkg.ORDER_FORECAST,
   	sd.supplier_name,
   	sd.supplier_site_name,
   	sd.supplier_name,
   	sd.supplier_site_name,
   	sd.publisher_name,
   	sd.publisher_site_name,
   	null,
   	null,
   	null,
   	null,
	nvl(sum(sd.primary_quantity),0),
 	nvl(sum(sd.tp_quantity),0),
     	nvl(sum(sd.quantity),0),
   	nvl(max(sd.last_refresh_number),0)
  from msc_sup_dem_entries sd,
  	msc_cp_plan_buckets bkt
  where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
  and sd.publisher_id = bkt.customer_id
  and sd.publisher_site_id = bkt.customer_site_id
  and nvl(sd.base_item_id,sd.inventory_item_id) = bkt.inventory_item_id
  and sd.publisher_order_type = msc_x_netting_pkg.ORDER_FORECAST
  and sd.supplier_id = bkt.supplier_id
  and sd.supplier_site_id = bkt.supplier_site_id
  and sd.plan_id = bkt.plan_id
  and trunc(sd.key_date) between bkt.bkt_start_date and bkt.bkt_end_date
  group by sd.supplier_id,
  	sd.supplier_site_id,
  	sd.supplier_id,
  	sd.supplier_site_id,
  	sd.publisher_id,
  	sd.publisher_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
  	bkt.bucket_index,
  	bkt.bkt_start_date,
  	bkt.bkt_end_date,
   	sd.supplier_name,
   	sd.supplier_site_name,
   	sd.supplier_name,
   	sd.supplier_site_name,
   	sd.publisher_name,
   	sd.publisher_site_name
 order by 1,2,3,4,5,6,7,8,9;


-----------------------------------------------------------------------------------------
--7.2 Supplier's supply within time bucket is greater than your demand (SP) : exception_26
------------------------------------------------------------------------------------------
--The p_company_id is customer and below exception cursor is for supplier
--facing the exception

CURSOR exception_26(p_refresh_number In Number) IS
  select sd.publisher_id,
  	sd.publisher_site_id,
  	sd.customer_id,
  	sd.customer_site_id,
  	sd.supplier_id,
  	sd.supplier_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
   	bkt.bucket_index,
   	bkt.bkt_start_date,
   	bkt.bkt_end_date,
   	msc_x_netting_pkg.ORDER_FORECAST,
   	sd.publisher_name,
   	sd.publisher_site_name,
   	sd.customer_name,
   	sd.customer_site_name,
   	sd.supplier_name,
   	sd.supplier_site_name,
 	null,
 	null,
 	null,
 	null,
	nvl(sum(sd.primary_quantity),0),
 	nvl(sum(sd.tp_quantity),0),
    	nvl(sum(sd.quantity),0),
   	nvl(max(sd.last_refresh_number),0)
  from msc_sup_dem_entries sd,
  	msc_cp_plan_buckets bkt
  where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
  and sd.publisher_id = bkt.customer_id
  and sd.publisher_site_id = bkt.customer_site_id
  and nvl(sd.base_item_id,sd.inventory_item_id) = bkt.inventory_item_id
  and sd.publisher_order_type = msc_x_netting_pkg.ORDER_FORECAST
  and sd.supplier_id = bkt.supplier_id
  and sd.supplier_site_id = bkt.supplier_site_id
  and sd.plan_id = bkt.plan_id
  and trunc(sd.key_date) between bkt.bkt_start_date and bkt.bkt_end_date
  group by sd.publisher_id,
  	sd.publisher_site_id,
  	sd.customer_id,
  	sd.customer_site_id,
  	sd.supplier_id,
  	sd.supplier_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
  	bkt.bucket_index,
  	bkt.bkt_start_date,
  	bkt.bkt_end_date,
   	sd.publisher_name,
   	sd.publisher_site_name,
   	sd.customer_name,
   	sd.customer_site_name,
   	sd.supplier_name,
   	sd.supplier_site_name
  UNION ALL
  select sd.customer_id,
  	sd.customer_site_id,
  	sd.customer_id,
  	sd.customer_site_id,
  	sd.publisher_id,
  	sd.publisher_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
  	bkt.bucket_index,
  	bkt.bkt_start_date,
  	bkt.bkt_end_date,
  	msc_x_netting_pkg.SUPPLY_COMMIT,
   	sd.customer_name,
   	sd.customer_site_name,
   	sd.customer_name,
   	sd.customer_site_name,
   	sd.publisher_name,
   	sd.publisher_site_name,
   	null,
   	null,
   	null,
   	null,
        nvl(sum(sd.primary_quantity),0),
  	nvl(sum(sd.tp_quantity),0),
  	nvl(sum(sd.quantity),0),
  	nvl(max(sd.last_refresh_number),0)
  from msc_sup_dem_entries sd,
  	msc_cp_plan_buckets bkt
  where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
  and sd.publisher_id = bkt.supplier_id
  and sd.publisher_site_id = bkt.supplier_site_id
  and sd.customer_id = bkt.customer_id
  and sd.customer_site_id = bkt.customer_site_id
  and nvl(sd.base_item_id,sd.inventory_item_id) = bkt.inventory_item_id
  and sd.publisher_order_type = msc_x_netting_pkg.SUPPLY_COMMIT
  and sd.plan_id = bkt.plan_id
  and trunc(sd.key_date) between bkt.bkt_start_date and bkt.bkt_end_date
  group by sd.customer_id,
  	sd.customer_site_id,
  	sd.customer_id,
  	sd.customer_site_id,
  	sd.publisher_id,
  	sd.publisher_site_id,
  	nvl(sd.base_item_id,sd.inventory_item_id),
  	bkt.bucket_index,
  	bkt.bkt_start_date,
  	bkt.bkt_end_date,
    	sd.customer_name,
   	sd.customer_site_name,
   	sd.customer_name,
   	sd.customer_site_name,
   	sd.publisher_name,
   	sd.publisher_site_name
 order by 1,2,3,4,5,6,7,8,9;



-------------------------------------------------------------------------------------
--7.3 Fulfillment quantity excess for your customers purchase order : exception_27
------------------------------------------------------------------------------------
CURSOR exception_27(p_refresh_number IN Number) IS
SELECT  distinct sd1.transaction_id,
   sd1.publisher_id,
   sd1.publisher_name,
   sd1.publisher_site_id,
   sd1.publisher_site_name,
   sd1.inventory_item_id,
   sd1.item_name,
   sd1.item_description,
        sd2.supplier_item_name,
        sd2.supplier_item_description,
        sd1.key_date,
        sd1.ship_date,
        sd1.receipt_date,
        sd1.quantity,
        sd1.primary_quantity,
        sd1.tp_quantity,
        sd1.order_number,
        sd1.release_number,
        sd1.line_number,
        sd1.customer_id,
        sd1.customer_name,
        sd1.customer_site_id,
        sd1.customer_site_name,
        sd1.customer_item_name,
        sd1.customer_item_description,
        sd1.creation_date,
        sd1.last_refresh_number,
        sd2.transaction_id,
        sd2.key_date,
        sd2.ship_date,
        sd2.receipt_date,
        sd2.quantity,
        sd2.primary_quantity,
        sd2.tp_quantity,
        sd2.order_number,
        sd2.release_number,
        sd2.line_number,
        sd2.supplier_id,
        sd2.supplier_name,
        sd2.supplier_site_id,
        sd2.supplier_site_name,
        sd2.creation_date,
        sd2.last_refresh_number
FROM    msc_sup_dem_entries sd1,
        msc_sup_dem_entries sd2
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.publisher_order_type = msc_x_netting_pkg.SALES_ORDER
AND   	sd2.plan_id = sd1.plan_id
AND   	sd2.inventory_item_id = sd1.inventory_item_id
AND     sd2.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND   	sd2.supplier_id = sd1.publisher_id
AND   	sd2.supplier_site_id = sd1.publisher_site_id
AND	sd2.publisher_id = sd1.customer_id
AND	sd2.publisher_site_id = sd1.customer_site_id
AND     sd1.end_order_number = sd2.order_number
AND     nvl(sd1.end_order_rel_number,-1) =
                        nvl(sd2.release_number,-1)
AND     nvl(sd1.end_order_line_number,-1) =
                        nvl(sd2.line_number,-1)
AND     nvl(sd1.last_refresh_number,-1) >  nvl(p_refresh_number,-1)
order by sd1.publisher_id, sd1.publisher_site_id,
sd1.customer_id, sd1.customer_site_id, sd1.inventory_item_id,
sd2.order_number, sd2.release_number, sd2.line_number, sd1.key_date desc;

-------------------------------------------------------------------------------------------
--7.4 Fulfillment quanitty excess from your supplier for your purchase order : exception_28
--------------------------------------------------------------------------------------------
CURSOR exception_28(p_refresh_number IN Number) IS
SELECT  distinct sd1.transaction_id,
   sd1.publisher_id,
   sd1.publisher_name,
   sd1.publisher_site_id,
   sd1.publisher_site_name,
   sd1.inventory_item_id,
   sd1.item_name,
   sd1.item_description,
        sd2.customer_item_name,
        sd2.customer_item_description,
        sd1.key_date,
        sd1.ship_date,
        sd1.receipt_date,
        sd1.quantity,
        sd1.primary_quantity,
        sd1.tp_quantity,
        sd1.order_number,
        sd1.release_number,
        sd1.line_number,
        sd1.supplier_id,
        sd1.supplier_name,
        sd1.supplier_site_id,
        sd1.supplier_site_name,
         sd1.supplier_item_name,
         sd1.supplier_item_description,
         sd1.creation_date,
         sd1.last_refresh_number,
        sd2.transaction_id,
        sd2.key_date,
        sd2.ship_date,
        sd2.receipt_date,
        sd2.quantity,
        sd2.primary_quantity,
        sd2.tp_quantity,
        sd2.order_number,
        sd2.release_number,
        sd2.line_number,
        sd2.customer_id,
        sd2.customer_name,
        sd2.customer_site_id,
        sd2.customer_site_name,
        sd2.creation_date,
        sd2.last_refresh_number
FROM    msc_sup_dem_entries sd1,
        msc_sup_dem_entries sd2
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND   	sd2.plan_id = sd1.plan_id
AND     sd2.publisher_order_type = msc_x_netting_pkg.SALES_ORDER
AND   	sd2.customer_id = sd1.publisher_id
AND   	sd2.customer_site_id = sd1.publisher_site_id
AND	sd2.publisher_id = sd1.supplier_id
AND	sd2.publisher_site_id = sd1.supplier_site_id
AND  	sd2.inventory_item_id = sd1.inventory_item_id
AND     sd1.order_number = sd2.end_order_number
AND     nvl(sd1.release_number,-1) =
                        nvl(sd2.end_order_rel_number,-1)
AND     nvl(sd1.line_number,-1) =
                        nvl(sd2.end_order_line_number,-1)
AND     nvl(sd1.last_refresh_number,-1) > nvl(p_refresh_number,-1)
order by sd1.publisher_id, sd1.publisher_site_id,
sd1.supplier_id, sd1.supplier_site_id, sd1.inventory_item_id,
sd1.order_number, sd1.release_number, sd1.line_number, sd2.key_date desc;

 --======================================================================
 --COMPUTE_MATERIAL_SHORTAGE  (supply planning)
 --======================================================================
 PROCEDURE COMPUTE_MATERIAL_SHORTAGE (   p_refresh_number IN Number,
   t_company_list       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_company_site_list  IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_customer_list      IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_customer_site_list IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_supplier_list      IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_supplier_site_list IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_item_list       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_group_list      IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_type_list       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_trxid1_list     IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_trxid2_list     IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_date1_list      IN OUT NOCOPY  msc_x_netting_pkg.date_arr,
   t_date2_list      IN OUT NOCOPY  msc_x_netting_pkg.date_arr,
   a_company_id            IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_company_name          IN OUT NOCOPY  msc_x_netting_pkg.publisherList,
   a_company_site_id       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_company_site_name     IN OUT NOCOPY  msc_x_netting_pkg.pubsiteList,
   a_item_id               IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_item_name             IN OUT NOCOPY  msc_x_netting_pkg.itemnameList,
   a_item_desc             IN OUT NOCOPY  msc_x_netting_pkg.itemdescList,
   a_exception_type        IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_exception_type_name   IN OUT NOCOPY  msc_x_netting_pkg.exceptypeList,
   a_exception_group       IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_exception_group_name  IN OUT NOCOPY msc_x_netting_pkg.excepgroupList,
   a_trx_id1               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_trx_id2               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_id           IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_name         IN OUT NOCOPY msc_x_netting_pkg.customerList,
   a_customer_site_id      IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_site_name    IN OUT NOCOPY msc_x_netting_pkg.custsiteList,
   a_customer_item_name    IN OUT NOCOPY msc_x_netting_pkg.itemnameList,
   a_supplier_id           IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_supplier_name         IN OUT NOCOPY msc_x_netting_pkg.supplierList,
   a_supplier_site_id      IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_supplier_site_name    IN OUT NOCOPY msc_x_netting_pkg.suppsiteList,
   a_supplier_item_name    IN OUT NOCOPY msc_x_netting_pkg.itemnameList,
   a_number1               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_number2               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_number3               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_threshold             IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_lead_time             IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_item_min_qty          IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_item_max_qty          IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_order_number          IN OUT NOCOPY msc_x_netting_pkg.ordernumberList,
   a_release_number        IN OUT NOCOPY msc_x_netting_pkg.releasenumList,
   a_line_number           IN OUT NOCOPY msc_x_netting_pkg.linenumList,
   a_end_order_number      IN OUT NOCOPY msc_x_netting_pkg.ordernumberList,
   a_end_order_rel_number  IN OUT NOCOPY msc_x_netting_pkg.releasenumList,
   a_end_order_line_number IN OUT NOCOPY msc_x_netting_pkg.linenumList,
   a_creation_date         IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_tp_creation_date      IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date1           	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date2        	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date3            	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date4		   IN OUT  NOCOPY msc_x_netting_pkg.date_arr,
   a_date5		   IN OUT  NOCOPY msc_x_netting_pkg.date_arr,
   a_exception_basis	   IN OUT  NOCOPY msc_x_netting_pkg.exceptbasisList) IS



  b_trx_id1                	msc_x_netting_pkg.number_arr;
  b_trx_id2                	msc_x_netting_pkg.number_arr;
  b_publisher_id     		msc_x_netting_pkg.number_arr;
  b_publisher_site_id      	msc_x_netting_pkg.number_arr;
  b_item_id                	msc_x_netting_pkg.number_arr;
  b_po_qty                 	msc_x_netting_pkg.number_arr;
  b_so_qty                 	msc_x_netting_pkg.number_arr;
  b_tp_po_qty        		msc_x_netting_pkg.number_arr;
  b_tp_so_qty        		msc_x_netting_pkg.number_arr;
  b_posting_po_qty      	msc_x_netting_pkg.number_arr;
  b_posting_so_qty      	msc_x_netting_pkg.number_arr;
  b_customer_id         	msc_x_netting_pkg.number_arr;
  b_customer_site_id    	msc_x_netting_pkg.number_arr;
  b_supplier_id         	msc_x_netting_pkg.number_arr;
  b_supplier_site_id    	msc_x_netting_pkg.number_arr;
  b_po_last_refnum      	msc_x_netting_pkg.number_arr;
  b_so_last_refnum      	msc_x_netting_pkg.number_arr;
  b_po_key_date			msc_x_netting_pkg.date_arr;
  b_so_key_date			msc_x_netting_pkg.date_arr;
  b_po_receipt_date     	msc_x_netting_pkg.date_arr;
  b_so_receipt_date    		msc_x_netting_pkg.date_arr;
  b_po_ship_date     		msc_x_netting_pkg.date_arr;
  b_so_ship_date     		msc_x_netting_pkg.date_arr;
  b_po_creation_date       	msc_x_netting_pkg.date_arr;
  b_so_creation_date    	msc_x_netting_pkg.date_arr;
  b_item_name        		msc_x_netting_pkg.itemnameList;
  b_item_desc        		msc_x_netting_pkg.itemdescList;
  b_publisher_name      	msc_x_netting_pkg.publisherList;
  b_publisher_site_name    	msc_x_netting_pkg.pubsiteList;
  b_supplier_name       	msc_x_netting_pkg.supplierList;
  b_supplier_site_name     	msc_x_netting_pkg.suppsiteList;
  b_supplier_item_name     	msc_x_netting_pkg.itemnameList;
  b_supplier_item_desc     	msc_x_netting_pkg.itemdescList;
  b_customer_name       	msc_x_netting_pkg.customerList;
  b_customer_site_name     	msc_x_netting_pkg.custsiteList;
  b_customer_item_name     	msc_x_netting_pkg.itemnameList;
  b_customer_item_desc     	msc_x_netting_pkg.itemdescList;
  b_order_number     		msc_x_netting_pkg.ordernumberList;
  b_release_number      	msc_x_netting_pkg.releasenumList;
  b_line_number      		msc_x_netting_pkg.linenumList;
  b_end_order_number       	msc_x_netting_pkg.ordernumberList;
  b_end_order_rel_number   	msc_x_netting_pkg.releasenumList;
  b_end_order_line_number  	msc_x_netting_pkg.linenumList;
  b_refresh_number              msc_x_netting_pkg.number_arr;

 l_start_date     		Date;
 l_end_date    			Date;
 l_bucket_type    		Number;
 l_total_demand      		Number := 0;
 l_tp_total_demand   		Number := 0;
 l_total_supply      		Number := 0;
 l_tp_total_supply   		Number := 0;
 l_total_qty      		Number := 0;
 l_exception_type 		Number;
 l_exception_group   		Number;
 l_generate_complement  	Boolean;
 l_updated     			Number;
 l_complement_threshold 	Number;
 l_cutoff_ref_num 		Number;
 l_threshold1     		Number;
 l_threshold2     		Number;
 l_exception_type_name  	fnd_lookup_values.meaning%type;
 l_exception_group_name 	fnd_lookup_values.meaning%type;
 l_posting_total_demand 	Number := 0;
 l_posting_total_supply 	Number := 0;
 l_sum         			Number := 0;
 l_item_desc			msc_sup_dem_entries.item_description%type;
 l_shipping_control		Number;
 l_exception_basis		msc_x_exception_details.exception_basis%type;

 l_last_so_trx_id		Number;
 l_receipt_date			Date;
 l_ship_date			Date;
 l_order_number			msc_sup_dem_entries.order_number%type;
 l_line_number			msc_sup_dem_entries.line_number%type;
 l_release_number		msc_sup_dem_entries.release_number%type;
 l_item_name			msc_sup_dem_entries.item_name%type;
 l_customer_item_name		msc_sup_dem_entries.customer_item_name%type;
 l_supplier_item_name		msc_sup_dem_entries.supplier_item_name%type;
 l_publisher_name		msc_sup_dem_entries.publisher_name%type;
 l_publisher_site_name		msc_sup_dem_entries.publisher_site_name%type;
 l_supplier_name		msc_sup_dem_entries.supplier_name%type;
 l_supplier_site_name		msc_sup_dem_entries.supplier_site_name%type;
 l_customer_name		msc_sup_dem_entries.customer_name%type;
 l_customer_site_name		msc_sup_dem_entries.customer_site_name%type;
 l_publisher_id			Number;
 l_publisher_site_id		Number;
 l_customer_id			Number;
 l_customer_site_id		Number;
 l_supplier_id			Number;
 l_supplier_site_id		Number;
 l_item_id			Number;

 l_pair				Number:= 0;
 l_insert			Number := 0;
 l_inserted_record		Number := 0;


 b_bucket_index			msc_x_netting_pkg.number_arr;
 b_bkt_start_date		msc_x_netting_pkg.date_arr;
 b_bkt_end_date			msc_x_netting_pkg.date_arr;
 b_order_type			msc_x_netting_pkg.number_arr;
 b_total_quantity		msc_x_netting_pkg.number_arr;
 b_tp_total_quantity		msc_x_netting_pkg.number_arr;
 b_posting_total_quantity	msc_x_netting_pkg.number_arr;

 BEGIN

 --dbms_output.put_line('Exception 5');

   open exception_5(p_refresh_number);
    fetch exception_5 BULK COLLECT INTO
    	b_publisher_id,
   	b_publisher_site_id,
   	b_supplier_id,
   	b_supplier_site_id,
   	b_customer_id,
   	b_customer_site_id,
   	b_item_id,
    	b_bucket_index,
    	b_bkt_start_date,
   	b_bkt_end_date,
    	b_order_type,
   	b_publisher_name,
   	b_publisher_site_name,
   	b_supplier_name,
   	b_supplier_site_name,
   	b_customer_name,
   	b_customer_site_name,
   	b_item_name,
	b_item_desc,
	b_supplier_item_name,
	b_customer_item_name,
    	b_total_quantity,
	b_tp_total_quantity,
	b_posting_total_quantity,
	b_refresh_number;
 CLOSE exception_5;

 IF (b_item_id is not null and b_item_id.COUNT > 0) THEN

 FOR j in 1..b_item_id.COUNT
 LOOP


 IF (j = 1 or b_publisher_id(j) <> b_publisher_id(j-1) OR
 		b_publisher_site_id(j) <> b_publisher_site_id(j-1) OR
 		b_customer_id(j) <> b_customer_id(j-1) OR
 		b_customer_site_id(j) <> b_customer_site_id(j-1) OR
 		b_supplier_id(j) <> b_supplier_id(j-1) OR
 		b_supplier_site_id(j) <> b_supplier_site_id(j-1) OR
 		b_item_id(j) <> b_item_id(j-1)) THEN
      --======================================================
      -- archive old exception and its complement
      --======================================================

   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      b_customer_id(j),
      b_customer_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
      msc_x_netting_pkg.G_EXCEP5,
      null,
      null,
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);

     l_threshold1 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP5,
                  	b_publisher_id(j),
               		b_publisher_site_id(j),
               		b_item_id(j),
            		null,
            		null,
            		b_customer_id(j),
            		b_customer_site_id(j),
                     	null);

      --------------------------------------------------------------------------
      -- get the shipping control
      ---------------------------------------------------------------------------
      l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_customer_name(j),
                                         b_customer_site_name(j),
                                         b_publisher_name(j),
                                         b_publisher_site_name(j));

      l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

END IF;


 IF (j > 1 and b_publisher_id(j) = b_publisher_id(j-1) AND
 		b_publisher_site_id(j) = b_publisher_site_id(j-1) AND
 		b_customer_id(j) = b_customer_id(j-1) AND
 		b_customer_site_id(j) = b_customer_site_id(j-1) AND
 		b_supplier_id(j) = b_supplier_id(j-1) AND
 		b_supplier_site_id(j) = b_supplier_site_id(j-1) AND
 		b_item_id(j) = b_item_id(j-1) and
 		b_bucket_index(j) = b_bucket_index(j-1) and
   		b_bkt_start_date(j) = b_bkt_start_date(j-1)) THEN

   	   IF (b_order_type(j-1) = msc_x_netting_pkg.ORDER_FORECAST ) THEN
   	      	l_total_demand := b_total_quantity(j-1);
   	      	l_tp_total_demand := b_tp_total_quantity(j-1);
   	      	l_posting_total_demand := b_posting_total_quantity(j-1);
   	   ELSIF (b_order_type(j-1)= msc_x_netting_pkg.SUPPLY_COMMIT) THEN
   	   	l_total_supply := b_total_quantity(j-1);
   	   	l_tp_total_supply := b_tp_total_quantity(j-1);
   	   	l_posting_total_supply := b_posting_total_quantity(j-1);
   	   END IF;
    	   IF (b_order_type(j) = msc_x_netting_pkg.ORDER_FORECAST) THEN
    	      	l_total_demand := b_total_quantity(j);
   	      	l_tp_total_demand := b_tp_total_quantity(j);
   	      	l_posting_total_demand := b_posting_total_quantity(j);
   	   ELSIF (b_order_type(j) = msc_x_netting_pkg.SUPPLY_COMMIT)  THEN
      	   	l_total_supply := b_total_quantity(j);
   	   	l_tp_total_supply := b_tp_total_quantity(j);
   	   	l_posting_total_supply := b_posting_total_quantity(j);
   	   END IF;
   	   l_pair := 1;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j-1);
   	   l_end_date := b_bkt_end_date(j-1);
   	   l_publisher_id := b_publisher_id(j-1);
   	   l_publisher_site_id := b_publisher_site_id(j-1);
   	   l_customer_id := b_customer_id(j-1);
   	   l_customer_site_id := b_customer_site_id(j-1);
   	   l_supplier_id := b_supplier_id(j-1);
   	   l_supplier_site_id := b_supplier_site_id(j-1);
   	   l_item_id := b_item_id(j-1);
    	   l_publisher_name := b_publisher_name(j-1);
   	   l_publisher_site_name := b_publisher_site_name(j-1);
   	   l_customer_name := b_customer_name(j-1);
   	   l_customer_site_name := b_customer_site_name(j-1);
   	   l_supplier_name := b_supplier_name(j-1);
   	   l_supplier_site_name := b_supplier_site_name(j-1);


 --dbms_output.put_line('equal insert ' || b_bkt_start_date(j));
 ELSIF (j > 1 and b_publisher_id(j) = b_publisher_id(j-1) AND
 		b_publisher_site_id(j) = b_publisher_site_id(j-1) AND
 		b_customer_id(j) = b_customer_id(j-1) AND
 		b_customer_site_id(j) = b_customer_site_id(j-1) AND
 		b_supplier_id(j) = b_supplier_id(j-1) AND
 		b_supplier_site_id(j) = b_supplier_site_id(j-1) AND
 		b_item_id(j) = b_item_id(j-1) AND
 		b_bucket_index(j) <> b_bucket_index(j-1) and l_pair = 1) THEN
	   l_pair := 0;
	   l_insert := 0;
	   --dbms_output.put_line('2 no insert with previous line l_pair = 1' || b_bkt_start_date(j));

 ELSIF (j > 1 and b_publisher_id(j) = b_publisher_id(j-1) AND
 		b_publisher_site_id(j) = b_publisher_site_id(j-1) AND
 		b_customer_id(j) = b_customer_id(j-1) AND
 		b_customer_site_id(j) = b_customer_site_id(j-1) AND
 		b_supplier_id(j) = b_supplier_id(j-1) AND
 		b_supplier_site_id(j) = b_supplier_site_id(j-1) AND
 		b_item_id(j) = b_item_id(j-1) AND
 		b_bucket_index(j) <> b_bucket_index(j-1) and l_pair <> 1) THEN

   	   IF (b_order_type(j-1) = msc_x_netting_pkg.ORDER_FORECAST) THEN
   	      	l_total_demand := b_total_quantity(j-1);
   	      	l_tp_total_demand := b_tp_total_quantity(j-1);
   	      	l_posting_total_demand := b_posting_total_quantity(j-1);
   	      	l_total_supply := 0;
   	      	l_tp_total_supply := 0;
   	      	l_posting_total_supply := 0;
   	   ELSIF (b_order_type(j-1) = msc_x_netting_pkg.SUPPLY_COMMIT) THEN
   	   	l_total_demand := 0;
   	   	l_tp_total_demand := 0;
   	   	l_posting_total_demand := 0;
   	   	l_total_supply := b_total_quantity(j-1);
   	   	l_tp_total_supply := b_tp_total_quantity(j-1);
   	   	l_posting_total_supply := b_posting_total_quantity(j-1);
   	   END IF;

   	   l_pair := 0;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j-1);
   	   l_end_date := b_bkt_end_date(j-1);
   	   l_publisher_id := b_publisher_id(j-1);
   	   l_publisher_site_id := b_publisher_site_id(j-1);
   	   l_customer_id := b_customer_id(j-1);
   	   l_customer_site_id := b_customer_site_id(j-1);
   	   l_supplier_id := b_supplier_id(j-1);
   	   l_supplier_site_id := b_supplier_site_id(j-1);
   	   l_item_id := b_item_id(j-1);
    	   l_publisher_name := b_publisher_name(j-1);
   	   l_publisher_site_name := b_publisher_site_name(j-1);
   	   l_customer_name := b_customer_name(j-1);
   	   l_customer_site_name := b_customer_site_name(j-1);
   	   l_supplier_name := b_supplier_name(j-1);
   	   l_supplier_site_name := b_supplier_site_name(j-1);

 --dbms_output.put_line('3 not equal insert ' || b_bkt_start_date(j));
 ELSIF (j > 1 and l_pair = 1 ) and (b_publisher_id(j) <> b_publisher_id(j-1) OR
 		b_publisher_site_id(j) <> b_publisher_site_id(j-1) OR
 		b_customer_id(j) <> b_customer_id(j-1) OR
 		b_customer_site_id(j) <> b_customer_site_id(j-1) OR
 		b_supplier_id(j) <> b_supplier_id(j-1) OR
 		b_supplier_site_id(j) <> b_supplier_site_id(j-1) OR
 		b_item_id(j) <> b_item_id(j-1) ) THEN

	   l_pair := 0;
	   l_insert := 0;

 --dbms_output.put_line('4 diff no insert' ||  b_bkt_start_date(j) || ' ps ' || b_publisher_site_id(j) || ' cs ' || b_customer_site_id(j));
 ELSIF (j > 1 and l_pair <> 1 ) and (b_publisher_id(j) <> b_publisher_id(j-1) OR
 		b_publisher_site_id(j) <> b_publisher_site_id(j-1) OR
 		b_customer_id(j) <> b_customer_id(j-1) OR
 		b_customer_site_id(j) <> b_customer_site_id(j-1) OR
 		b_supplier_id(j) <> b_supplier_id(j-1) OR
 		b_supplier_site_id(j) <> b_supplier_site_id(j-1) OR
 		b_item_id(j) <> b_item_id(j-1) ) THEN

   	   IF (b_order_type(j-1) = msc_x_netting_pkg.ORDER_FORECAST) THEN
   	      	l_total_demand := b_total_quantity(j-1);
   	      	l_tp_total_demand := b_tp_total_quantity(j-1);
   	      	l_posting_total_demand := b_posting_total_quantity(j-1);
   	      	l_total_supply := 0;
   	      	l_tp_total_supply := 0;
   	      	l_posting_total_supply := 0;
   	   ELSIF (b_order_type(j-1) = msc_x_netting_pkg.SUPPLY_COMMIT) THEN
   	   	l_total_demand := 0;
   	   	l_tp_total_demand := 0;
   	   	l_posting_total_demand := 0;
   	   	l_total_supply := b_total_quantity(j-1);
   	   	l_tp_total_supply := b_tp_total_quantity(j-1);
   	   	l_posting_total_supply := b_posting_total_quantity(j-1);
   	   END IF;

   	   l_pair := 0;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j-1);
   	   l_end_date := b_bkt_end_date(j-1);
   	   l_publisher_id := b_publisher_id(j-1);
   	   l_publisher_site_id := b_publisher_site_id(j-1);
   	   l_customer_id := b_customer_id(j-1);
   	   l_customer_site_id := b_customer_site_id(j-1);
   	   l_supplier_id := b_supplier_id(j-1);
   	   l_supplier_site_id := b_supplier_site_id(j-1);
   	   l_item_id := b_item_id(j-1);
    	   l_publisher_name := b_publisher_name(j-1);
   	   l_publisher_site_name := b_publisher_site_name(j-1);
   	   l_customer_name := b_customer_name(j-1);
   	   l_customer_site_name := b_customer_site_name(j-1);
   	   l_supplier_name := b_supplier_name(j-1);
   	   l_supplier_site_name := b_supplier_site_name(j-1);


 --dbms_output.put_line('5 diff with insert' || b_bkt_start_date(j) || ' ps ' || b_publisher_site_id(j) || ' cs ' || b_customer_site_id(j));

 ELSIF (j = 1 AND b_bkt_start_date.COUNT = 1) THEN
       	   IF (b_order_type(j) = msc_x_netting_pkg.ORDER_FORECAST ) THEN
    	      	l_total_demand := b_total_quantity(j);
   	      	l_tp_total_demand := b_tp_total_quantity(j);
   	      	l_posting_total_demand := b_posting_total_quantity(j);
    	      	l_total_supply := 0;
   	      	l_tp_total_supply := 0;
   	      	l_posting_total_supply := 0;
   	   ELSIF (b_order_type(j) = msc_x_netting_pkg.SUPPLY_COMMIT)  THEN
   	      	l_total_demand := 0;
	      	l_tp_total_demand := 0;
   	   	l_posting_total_demand := 0;
      	   	l_total_supply := b_total_quantity(j);
   	   	l_tp_total_supply := b_tp_total_quantity(j);
   	   	l_posting_total_supply := b_posting_total_quantity(j);
   	   END IF;

   	   l_pair := 0;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j);
   	   l_end_date := b_bkt_end_date(j);
   	   l_publisher_id := b_publisher_id(j);
   	   l_publisher_site_id := b_publisher_site_id(j);
   	   l_customer_id := b_customer_id(j);
   	   l_customer_site_id := b_customer_site_id(j);
   	   l_supplier_id := b_supplier_id(j);
   	   l_supplier_site_id := b_supplier_site_id(j);
   	   l_item_id := b_item_id(j);
    	   l_publisher_name := b_publisher_name(j);
   	   l_publisher_site_name := b_publisher_site_name(j);
   	   l_customer_name := b_customer_name(j);
   	   l_customer_site_name := b_customer_site_name(j);
   	   l_supplier_name := b_supplier_name(j);
   	   l_supplier_site_name := b_supplier_site_name(j);

 --dbms_output.put_line('5 only one line' || b_bkt_start_date(j));
 END IF;


 FND_FILE.PUT_LINE(FND_FILE.LOG, '5:supply ' || l_total_supply || ' demand ' || l_total_demand || ' date ' ||
   	l_start_date || 'cutoff ' || l_cutoff_ref_num );

--dbms_output.put_line( '5:supply ' || l_total_supply || ' demand ' || l_total_demand || ' date ' ||
--  	l_start_date || 'cutoff ' || l_cutoff_ref_num  || ' pair ' || l_pair);
 IF ( ((j > 1 and l_insert = 1) OR (b_bucket_index.COUNT = 1)) and
   	((l_tp_total_demand - l_total_supply) > (l_tp_total_demand * l_threshold1/100)))
   	and (greatest(b_refresh_number(j),b_refresh_number(j-1)) > p_refresh_number)
   	THEN  --- Bug# 4629582

         	--======================================================
         	-- clean up  the opposite exception and its complement
         	--======================================================
      		msc_x_netting_pkg.add_to_delete_tbl(
         	l_publisher_id,			--b_publisher_id(j),
         	l_publisher_site_id,		--b_publisher_site_id(j),
         	l_customer_id,			--b_customer_id(j),
         	l_customer_site_id,		--b_customer_site_id(j),
         	null,
         	null,
         	l_item_id,			--b_item_id(j),
         	msc_x_netting_pkg.G_MATERIAL_EXCESS,
         	msc_x_netting_pkg.G_EXCEP25,
         	null,
         	null,
         	l_start_date,
         	l_end_date,
         	t_company_list,
         	t_company_site_list,
         	t_customer_list,
         	t_customer_site_list,
         	t_supplier_list,
         	t_supplier_site_list,
         	t_item_list,
         	t_group_list,
         	t_type_list,
         	t_trxid1_list,
         	t_trxid2_list,
         	t_date1_list,
         	t_date2_list);

      		l_exception_type := msc_x_netting_pkg.G_EXCEP5;
      		l_exception_group := msc_x_netting_pkg.G_MATERIAL_SHORTAGE;
      		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

      		--dbms_output.put_line('Deman ' || l_tp_total_demand || 'supp ' || l_total_supply);

      		msc_x_netting_pkg.add_to_exception_tbl(
      			l_publisher_id,			--b_publisher_id(j),
         		l_publisher_name,		--b_publisher_name(j),
         		l_publisher_site_id,		--b_publisher_site_id(j),
         		l_publisher_site_name,		--b_publisher_site_name(j),
         		l_item_id,			--b_item_id(j),
         		l_item_name,			--b_item_name(j),
         		l_item_desc,
         		l_exception_type,
         		l_exception_type_name,
         		l_exception_group,
         		l_exception_group_name,
         		null,       			--trx_id1,
         		null,                   	--trx_id2,
         		l_customer_id,			--b_customer_id(j),
         		l_customer_name,		--b_customer_name(j),
         		l_customer_site_id,		--b_customer_site_id(j),
         		l_customer_site_name,		--b_customer_site_name(j),
         		l_customer_item_name,		--b_customer_item_name(j),
         		null,                   	--l_supplier_id
         		null,
         		null,                   	--l_supplier_site_id
         		null,
         		l_supplier_item_name, 		--b_supplier_item_name(j),
         		l_total_supply,    		--number1
         		l_tp_total_demand,      	--number2
         		null,          		--number3
         		l_threshold1,
         		null,       --lead time
         		null,       --item min
         		null,       --item max
         		null,       --l_order_number,
         		null,       --l_release_number,
         		null,       --l_line_number,
         		null,                   --l_end_order_number,
         		null,                   --l_end_order_rel_number,
         		null,                   --l_end_order_line_number,
         		null,			--b_so_creation_date(j),
         		null,			--b_po_creation_date(j),
         		l_start_date,
         		l_end_date,
         		null,			--ship_date(j),
         		null,			--ship_date(j),
         		null,
         		l_exception_basis,
         		a_company_id,
         		a_company_name,
         		a_company_site_id,
         		a_company_site_name,
         		a_item_id,
         		a_item_name,
         		a_item_desc,
         		a_exception_type,
         		a_exception_type_name,
         		a_exception_group,
         		a_exception_group_name,
         		a_trx_id1,
         		a_trx_id2,
         		a_customer_id,
         		a_customer_name,
         		a_customer_site_id,
         		a_customer_site_name,
         		a_customer_item_name,
         		a_supplier_id,
         		a_supplier_name,
         		a_supplier_site_id,
         		a_supplier_site_name,
         		a_supplier_item_name,
         		a_number1,
         		a_number2,
         		a_number3,
         		a_threshold,
         		a_lead_time,
         		a_item_min_qty,
         		a_item_max_qty,
         		a_order_number,
         		a_release_number,
         		a_line_number,
         		a_end_order_number,
         		a_end_order_rel_number,
         		a_end_order_line_number,
         		a_creation_date,
         		a_tp_creation_date,
         		a_date1,
         		a_date2,
         		a_date3,
         		a_date4,
         		a_date5,
         		a_exception_basis);

         		l_inserted_record := l_inserted_record + 1;

      		 end if;  /* compute the exception */
/*------------------------------------------------------------------
 Loop for the last record if require to insert
 ------------------------------------------------------------------*/
 IF ( j > 1 and l_pair = 0 and j = b_bucket_index.COUNT) THEN
 	   l_insert := 1;
 	   l_start_date := b_bkt_start_date(j);
   	   l_end_date := b_bkt_end_date(j);
   	   l_publisher_id := b_publisher_id(j);
   	   l_publisher_site_id := b_publisher_site_id(j);
   	   l_customer_id := b_customer_id(j);
   	   l_customer_site_id := b_customer_site_id(j);
   	   l_supplier_id := b_supplier_id(j);
   	   l_supplier_site_id := b_supplier_site_id(j);
   	   l_item_id := b_item_id(j);
     	   l_publisher_name := b_publisher_name(j);
   	   l_publisher_site_name := b_publisher_site_name(j);
   	   l_customer_name := b_customer_name(j);
   	   l_customer_site_name := b_customer_site_name(j);
   	   l_supplier_name := b_supplier_name(j);
   	   l_supplier_site_name := b_supplier_site_name(j);

    	   IF (b_order_type(j) = msc_x_netting_pkg.ORDER_FORECAST) THEN
    	      	l_total_demand := b_total_quantity(j);
    	      	l_tp_total_demand := b_tp_total_quantity(j);
    	      	l_posting_total_demand := b_posting_total_quantity(j);
    	      	l_total_supply := 0;
    	      	l_tp_total_supply := 0;
    	      	l_posting_total_supply := 0;
    	   ELSIF (b_order_type(j) = msc_x_netting_pkg.SUPPLY_COMMIT) THEN
    	   	l_total_demand := 0;
    	   	l_tp_total_demand := 0;
    	   	l_posting_total_demand := 0;
    	   	l_total_supply := b_total_quantity(j);
    	   	l_tp_total_supply := b_tp_total_quantity(j);
    	   	l_posting_total_supply := b_posting_total_quantity(j);
   	   END IF;
    --dbms_output.put_line(' loop for last record  ' );
      IF ((l_tp_total_demand - l_total_supply) > (l_tp_total_demand * l_threshold1/100))
    and (b_refresh_number(j) > p_refresh_number)
    THEN                                          --- Bug#4629582

     FND_FILE.PUT_LINE(FND_FILE.LOG, '5:insert' || 'demand ' || l_tp_total_demand || 'sup ' || l_total_supply);


       		l_exception_type := msc_x_netting_pkg.G_EXCEP5;
       		l_exception_group := msc_x_netting_pkg.G_MATERIAL_SHORTAGE;
       		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
       		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

       		--dbms_output.put_line('Deman ' || l_tp_total_demand || 'supp ' || l_total_supply);

       		msc_x_netting_pkg.add_to_exception_tbl(
       			l_publisher_id,			--b_publisher_id(j),
          		l_publisher_name,		--b_publisher_name(j),
          		l_publisher_site_id,		--b_publisher_site_id(j),
          		l_publisher_site_name,		--b_publisher_site_name(j),
          		l_item_id,			--b_item_id(j),
          		l_item_name,			--b_item_name(j),
          		l_item_desc,
          		l_exception_type,
          		l_exception_type_name,
          		l_exception_group,
          		l_exception_group_name,
          		null,       			--trx_id1,
          		null,                   	--trx_id2,
          		l_customer_id,			--b_customer_id(j),
          		l_customer_name,		--b_customer_name(j),
          		l_customer_site_id,		--b_customer_site_id(j),
          		l_customer_site_name,		--b_customer_site_name(j),
          		l_customer_item_name,		--b_customer_item_name(j),
          		null,                   	--l_supplier_id
          		null,
          		null,                   	--l_supplier_site_id
          		null,
          		l_supplier_item_name, 		--b_supplier_item_name(j),
          		l_total_supply,    		--number1
          		l_tp_total_demand,      	--number2
          		null,          		--number3
          		l_threshold1,
          		null,       --lead time
          		null,       --item min
          		null,       --item max
          		null,       --l_order_number,
          		null,       --l_release_number,
          		null,       --l_line_number,
          		null,                   --l_end_order_number,
          		null,                   --l_end_order_rel_number,
          		null,                   --l_end_order_line_number,
          		null,			--b_so_creation_date(j),
          		null,			--b_po_creation_date(j),
          		l_start_date,
          		l_end_date,
          		null,			--ship_date(j),
          		null,			--ship_date(j),
          		null,
          		l_exception_basis,
          		a_company_id,
          		a_company_name,
          		a_company_site_id,
          		a_company_site_name,
          		a_item_id,
          		a_item_name,
          		a_item_desc,
          		a_exception_type,
          		a_exception_type_name,
          		a_exception_group,
          		a_exception_group_name,
          		a_trx_id1,
          		a_trx_id2,
          		a_customer_id,
          		a_customer_name,
          		a_customer_site_id,
          		a_customer_site_name,
          		a_customer_item_name,
          		a_supplier_id,
          		a_supplier_name,
          		a_supplier_site_id,
          		a_supplier_site_name,
          		a_supplier_item_name,
          		a_number1,
          		a_number2,
          		a_number3,
          		a_threshold,
          		a_lead_time,
          		a_item_min_qty,
          		a_item_max_qty,
          		a_order_number,
          		a_release_number,
          		a_line_number,
          		a_end_order_number,
          		a_end_order_rel_number,
          		a_end_order_line_number,
          		a_creation_date,
          		a_tp_creation_date,
          		a_date1,
          		a_date2,
          		a_date3,
          		a_date4,
          		a_date5,
          		a_exception_basis);
                        l_inserted_record := l_inserted_record + 1;

       		 end if;  /* compute the exception */
       		end if;   /* m is the last record in the loop */

	   --END LOOP;        /* loop*/
	 --END IF;
  --- END IF;    	--sum
 END LOOP;
 END IF;

 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' || msc_x_netting_pkg.get_message_type(5) ||
   ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

 --=======================================================================================
 --for Supplier supply planning (exception 2.2 and 7.2)
 --======================================================================================
 l_total_supply := 0;
 l_total_demand := 0;
 l_start_date := null;
 l_end_date := null;
 l_pair := 0;
 l_insert := 0;


 --dbms_output.put_line('Exception 6');

 open exception_6(p_refresh_number);
     fetch exception_6 BULK COLLECT INTO
     	b_publisher_id,
    	b_publisher_site_id,
    	b_customer_id,
    	b_customer_site_id,
    	b_supplier_id,
    	b_supplier_site_id,
    	b_item_id,
     	b_bucket_index,
     	b_bkt_start_date,
    	b_bkt_end_date,
     	b_order_type,
    	b_publisher_name,
   	b_publisher_site_name,
   	b_customer_name,
   	b_customer_site_name,
   	b_supplier_name,
   	b_supplier_site_name,
   	b_item_name,
	b_item_desc,
	b_supplier_item_name,
	b_customer_item_name,
     	b_total_quantity,
 	b_tp_total_quantity,
 	b_posting_total_quantity,
 	b_refresh_number;

 CLOSE exception_6;
 IF (b_item_id is not null and b_item_id.COUNT > 0) THEN
 FOR j in 1..b_item_id.COUNT
 LOOP


  IF (j = 1 or b_publisher_id(j) <> b_publisher_id(j-1) OR
  		b_publisher_site_id(j) <> b_publisher_site_id(j-1) OR
  		b_customer_id(j) <> b_customer_id(j-1) OR
  		b_customer_site_id(j) <> b_customer_site_id(j-1) OR
  		b_supplier_id(j) <> b_supplier_id(j-1) OR
  		b_supplier_site_id(j) <> b_supplier_site_id(j-1) OR
 		b_item_id(j) <> b_item_id(j-1)) THEN

      --======================================================
      -- archive old exception and its complement
      --======================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
      msc_x_netting_pkg.G_EXCEP6,
      null,
      null,
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);


     l_threshold1 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP6,
                  	b_publisher_id(j),
               		b_publisher_site_id(j),
               		b_item_id(j),
            		b_supplier_id(j),
            		b_supplier_site_id(j),
            		null,
            		null,
                     	null);


     --------------------------------------------------------------------------
     -- get the shipping control
     ---------------------------------------------------------------------------
     l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                       b_publisher_site_name(j),
                                       b_supplier_name(j),
                                       b_supplier_site_name(j));

     l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

  END IF;


IF (j > 1 and b_publisher_id(j) = b_publisher_id(j-1) AND
 		b_publisher_site_id(j) = b_publisher_site_id(j-1) AND
 		b_customer_id(j) = b_customer_id(j-1) AND
 		b_customer_site_id(j) = b_customer_site_id(j-1) AND
 		b_supplier_id(j) = b_supplier_id(j-1) AND
 		b_supplier_site_id(j) = b_supplier_site_id(j-1) AND
 		b_item_id(j) = b_item_id(j-1) and
 		b_bucket_index(j) = b_bucket_index(j-1) and
   		b_bkt_start_date(j) = b_bkt_start_date(j-1)) THEN

   	   IF (b_order_type(j-1) = msc_x_netting_pkg.ORDER_FORECAST ) THEN
   	      	l_total_demand := b_total_quantity(j-1);
   	      	l_tp_total_demand := b_tp_total_quantity(j-1);
   	      	l_posting_total_demand := b_posting_total_quantity(j-1);
   	   ELSIF (b_order_type(j-1)= msc_x_netting_pkg.SUPPLY_COMMIT) THEN
   	   	l_total_supply := b_total_quantity(j-1);
   	   	l_tp_total_supply := b_tp_total_quantity(j-1);
   	   	l_posting_total_supply := b_posting_total_quantity(j-1);
   	   END IF;

   	   IF (b_order_type(j) = msc_x_netting_pkg.ORDER_FORECAST) THEN
    	      	l_total_demand := b_total_quantity(j);
   	      	l_tp_total_demand := b_tp_total_quantity(j);
   	      	l_posting_total_demand := b_posting_total_quantity(j);

   	   ELSIF (b_order_type(j) = msc_x_netting_pkg.SUPPLY_COMMIT)  THEN
      	   	l_total_supply := b_total_quantity(j);
   	   	l_tp_total_supply := b_tp_total_quantity(j);
   	   	l_posting_total_supply := b_posting_total_quantity(j);
   	   END IF;

   	   l_pair := 1;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j-1);
   	   l_end_date := b_bkt_end_date(j-1);
   	   l_publisher_id := b_publisher_id(j-1);
   	   l_publisher_site_id := b_publisher_site_id(j-1);
   	   l_customer_id := b_customer_id(j-1);
   	   l_customer_site_id := b_customer_site_id(j-1);
   	   l_supplier_id := b_supplier_id(j-1);
   	   l_supplier_site_id := b_supplier_site_id(j-1);
   	   l_item_id := b_item_id(j-1);
   	   l_publisher_name := b_publisher_name(j-1);
   	   l_publisher_site_name := b_publisher_site_name(j-1);
   	   l_customer_name := b_customer_name(j-1);
   	   l_customer_site_name := b_customer_site_name(j-1);
   	   l_supplier_name := b_supplier_name(j-1);
   	   l_supplier_site_name := b_supplier_site_name(j-1);

 ELSIF (j > 1 and b_publisher_id(j) = b_publisher_id(j-1) AND
 		b_publisher_site_id(j) = b_publisher_site_id(j-1) AND
 		b_customer_id(j) = b_customer_id(j-1) AND
 		b_customer_site_id(j) = b_customer_site_id(j-1) AND
 		b_supplier_id(j) = b_supplier_id(j-1) AND
 		b_supplier_site_id(j) = b_supplier_site_id(j-1) AND
 		b_item_id(j) = b_item_id(j-1) AND
 		b_bucket_index(j) <> b_bucket_index(j-1) and l_pair = 1) THEN
	   l_pair := 0;
	   l_insert := 0;

 ELSIF (j > 1 and b_publisher_id(j) = b_publisher_id(j-1) AND
 		b_publisher_site_id(j) = b_publisher_site_id(j-1) AND
 		b_customer_id(j) = b_customer_id(j-1) AND
 		b_customer_site_id(j) = b_customer_site_id(j-1) AND
 		b_supplier_id(j) = b_supplier_id(j-1) AND
 		b_supplier_site_id(j) = b_supplier_site_id(j-1) AND
 		b_item_id(j) = b_item_id(j-1) AND
 		b_bucket_index(j) <> b_bucket_index(j-1) and l_pair <> 1) THEN

   	   IF (b_order_type(j-1) = msc_x_netting_pkg.ORDER_FORECAST) THEN
   	      	l_total_demand := b_total_quantity(j-1);
   	      	l_tp_total_demand := b_tp_total_quantity(j-1);
   	      	l_posting_total_demand := b_posting_total_quantity(j-1);
   	      	l_total_supply := 0;
   	      	l_tp_total_supply := 0;
   	      	l_posting_total_supply := 0;
   	   ELSIF (b_order_type(j-1) = msc_x_netting_pkg.SUPPLY_COMMIT) THEN
   	   	l_total_demand := 0;
   	   	l_tp_total_demand := 0;
   	   	l_posting_total_demand := 0;
   	   	l_total_supply := b_total_quantity(j-1);
   	   	l_tp_total_supply := b_tp_total_quantity(j-1);
   	   	l_posting_total_supply := b_posting_total_quantity(j-1);
   	   END IF;
   	   l_pair := 0;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j-1);
   	   l_end_date := b_bkt_end_date(j-1);
    	   l_publisher_id := b_publisher_id(j-1);
   	   l_publisher_site_id := b_publisher_site_id(j-1);
   	   l_customer_id := b_customer_id(j-1);
   	   l_customer_site_id := b_customer_site_id(j-1);
   	   l_supplier_id := b_supplier_id(j-1);
   	   l_supplier_site_id := b_supplier_site_id(j-1);
   	   l_item_id := b_item_id(j-1);
    	   l_publisher_name := b_publisher_name(j-1);
   	   l_publisher_site_name := b_publisher_site_name(j-1);
   	   l_customer_name := b_customer_name(j-1);
   	   l_customer_site_name := b_customer_site_name(j-1);
   	   l_supplier_name := b_supplier_name(j-1);
   	   l_supplier_site_name := b_supplier_site_name(j-1);

 ELSIF (j > 1 and l_pair = 1 ) and (b_publisher_id(j) <> b_publisher_id(j-1) OR
 		b_publisher_site_id(j) <> b_publisher_site_id(j-1) OR
 		b_customer_id(j) <> b_customer_id(j-1) OR
 		b_customer_site_id(j) <> b_customer_site_id(j-1) OR
 		b_supplier_id(j) <> b_supplier_id(j-1) OR
 		b_supplier_site_id(j) <> b_supplier_site_id(j-1) OR
 		b_item_id(j) <> b_item_id(j-1)) THEN
 	   l_pair := 0;
	   l_insert := 0;

 ELSIF (j > 1 and l_pair <> 1) and (b_publisher_id(j) <> b_publisher_id(j-1) OR
  		b_publisher_site_id(j) <> b_publisher_site_id(j-1) OR
  		b_customer_id(j) <> b_customer_id(j-1) OR
  		b_customer_site_id(j) <> b_customer_site_id(j-1) OR
  		b_supplier_id(j) <> b_supplier_id(j-1) OR
  		b_supplier_site_id(j) <> b_supplier_site_id(j-1) OR
  		b_item_id(j) <> b_item_id(j-1)) THEN

    	   IF (b_order_type(j-1) = msc_x_netting_pkg.ORDER_FORECAST) THEN
    	      	l_total_demand := b_total_quantity(j-1);
    	      	l_tp_total_demand := b_tp_total_quantity(j-1);
    	      	l_posting_total_demand := b_posting_total_quantity(j-1);
    	      	l_total_supply := 0;
    	      	l_tp_total_supply := 0;
    	      	l_posting_total_supply := 0;
    	   ELSIF (b_order_type(j-1) = msc_x_netting_pkg.SUPPLY_COMMIT) THEN
    	   	l_total_demand := 0;
    	   	l_tp_total_demand := 0;
    	   	l_posting_total_demand := 0;
    	   	l_total_supply := b_total_quantity(j-1);
    	   	l_tp_total_supply := b_tp_total_quantity(j-1);
    	   	l_posting_total_supply := b_posting_total_quantity(j-1);
    	   END IF;
    	   l_pair := 0;
    	   l_insert := 1;
    	   l_start_date := b_bkt_start_date(j-1);
   	   l_end_date := b_bkt_end_date(j-1);
    	   l_publisher_id := b_publisher_id(j-1);
   	   l_publisher_site_id := b_publisher_site_id(j-1);
   	   l_customer_id := b_customer_id(j-1);
   	   l_customer_site_id := b_customer_site_id(j-1);
   	   l_supplier_id := b_supplier_id(j-1);
   	   l_supplier_site_id := b_supplier_site_id(j-1);
   	   l_item_id := b_item_id(j-1);
    	   l_publisher_name := b_publisher_name(j-1);
   	   l_publisher_site_name := b_publisher_site_name(j-1);
   	   l_customer_name := b_customer_name(j-1);
   	   l_customer_site_name := b_customer_site_name(j-1);
   	   l_supplier_name := b_supplier_name(j-1);
   	   l_supplier_site_name := b_supplier_site_name(j-1);

 ELSIF (j = 1 and b_bkt_start_date.COUNT = 1) THEN

    	   IF (b_order_type(j) = msc_x_netting_pkg.ORDER_FORECAST ) THEN
    	      	l_total_demand := b_total_quantity(j);
   	      	l_tp_total_demand := b_tp_total_quantity(j);
   	      	l_posting_total_demand := b_posting_total_quantity(j);
    	      	l_total_supply := 0;
   	      	l_tp_total_supply := 0;
   	      	l_posting_total_supply := 0;
   	   ELSIF (b_order_type(j) = msc_x_netting_pkg.SUPPLY_COMMIT)  THEN
   	      	l_total_demand := 0;
	      	l_tp_total_demand := 0;
   	   	l_posting_total_demand := 0;
      	   	l_total_supply := b_total_quantity(j);
   	   	l_tp_total_supply := b_tp_total_quantity(j);
   	   	l_posting_total_supply := b_posting_total_quantity(j);
   	   END IF;

   	   l_pair := 0;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j);
   	   l_end_date := b_bkt_end_date(j);
    	   l_publisher_id := b_publisher_id(j);
   	   l_publisher_site_id := b_publisher_site_id(j);
   	   l_customer_id := b_customer_id(j);
   	   l_customer_site_id := b_customer_site_id(j);
   	   l_supplier_id := b_supplier_id(j);
   	   l_supplier_site_id := b_supplier_site_id(j);
   	   l_item_id := b_item_id(j);
    	   l_publisher_name := b_publisher_name(j);
   	   l_publisher_site_name := b_publisher_site_name(j);
   	   l_customer_name := b_customer_name(j);
   	   l_customer_site_name := b_customer_site_name(j);
   	   l_supplier_name := b_supplier_name(j);
   	   l_supplier_site_name := b_supplier_site_name(j);
 END IF;


FND_FILE.PUT_LINE(FND_FILE.LOG, '6:supply ' || l_total_supply || ' demand ' || l_total_demand || ' date ' ||
   l_start_date || 'cutoff ' || l_cutoff_ref_num || 'bkt ' || b_bucket_index(j));

        IF ( ((j > 1 and l_insert = 1 )  OR (b_bucket_index.COUNT = 1)) and
      	  ((l_total_demand - l_tp_total_supply ) > (l_total_demand * l_threshold1/100)))
      	  and (greatest(b_refresh_number(j),b_refresh_number(j-1)) > p_refresh_number)
      	  THEN

      		--------------------------------------------------------
      		-- clean up the opposite exception and its complement
      		--------------------------------------------------------
      		msc_x_netting_pkg.add_to_delete_tbl(
            	l_publisher_id,			--b_publisher_id(j),
            	l_publisher_site_id,		--b_publisher_site_id(j),
            	null,
            	null,
            	l_supplier_id,			--b_supplier_id(j),
            	l_supplier_site_id,		--b_supplier_site_id(j),
            	l_item_id,			--b_item_id(j),
            	msc_x_netting_pkg.G_MATERIAL_EXCESS,
            	msc_x_netting_pkg.G_EXCEP26,
            	null,
            	null,
            	l_start_date,
            	l_end_date,
            	t_company_list,
            	t_company_site_list,
            	t_customer_list,
            	t_customer_site_list,
            	t_supplier_list,
            	t_supplier_site_list,
            	t_item_list,
            	t_group_list,
            	t_type_list,
            	t_trxid1_list,
            	t_trxid2_list,
            	t_date1_list,
            	t_date2_list);


      		--if plan_type is SP then detected exception 2.2
      		l_exception_type := msc_x_netting_pkg.G_EXCEP6;
      		l_exception_group := msc_x_netting_pkg.G_MATERIAL_SHORTAGE;
      		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

      		msc_x_netting_pkg.add_to_exception_tbl(
      			l_publisher_id,			--b_publisher_id(j),
            		l_publisher_name,		--b_publisher_name(j),
                      	l_publisher_site_id,		--b_publisher_site_id(j),
                      	l_publisher_site_name,		--b_publisher_site_name(j),
                        l_item_id,			--b_item_id(j),
                        l_item_name,			--b_item_name(j),
                        l_item_desc,			--b_item_desc(j),
                      	l_exception_type,
                      	l_exception_type_name,
                      	l_exception_group,
                      	l_exception_group_name,
                      	null,                   	--trx_id1,
                      	null,                   	--trx_id2,
                      	null,         			--l_customer_id,
                      	null,
                      	null,         			--l_customer_site_id,
                      	null,
                      	l_customer_item_name,		--b_customer_item_name(j),
                      	l_supplier_id,			--b_supplier_id(j),
                      	l_supplier_name,		--b_supplier_name(j),
                      	l_supplier_site_id,		--b_supplier_site_id(j),
                      	l_supplier_site_name,		--b_supplier_site_name(j),
                      	l_supplier_item_name,	--b_supplier_item_name(j),
                      	l_tp_total_supply,
                      	l_total_demand,
                      	null,
                      	l_threshold1,
                      	null,         --lead time
            		null,       --item min
            		null,       --item_max
                      	null,                   --l_order_number,
                      	null,                   --l_release_number,
                      	null,                   --l_line_number,
                      	null,                   --l_end_order_number,
                      	null,                   --l_end_order_rel_number,
                      	null,                   --l_end_order_line_number,
                	 null,			--b_so_creation_date(j),
                	 null,			--b_po_creation_date(j),
                	 l_start_date,
                	 l_end_date,
                	 null,			--ship_date(j),
                	 null,			--ship_date(j),
                	 null,
                	 l_exception_basis,
            		a_company_id,
            		a_company_name,
            		a_company_site_id,
            		a_company_site_name,
            		a_item_id,
            		a_item_name,
            		a_item_desc,
            		a_exception_type,
            		a_exception_type_name,
            		a_exception_group,
            		a_exception_group_name,
            		a_trx_id1,
            		a_trx_id2,
            		a_customer_id,
            		a_customer_name,
            		a_customer_site_id,
            		a_customer_site_name,
            		a_customer_item_name,
            		a_supplier_id,
            		a_supplier_name,
            		a_supplier_site_id,
            		a_supplier_site_name,
            		a_supplier_item_name,
            		a_number1,
            		a_number2,
            		a_number3,
            		a_threshold,
            		a_lead_time,
            		a_item_min_qty,
            		a_item_max_qty,
            		a_order_number,
            		a_release_number,
            		a_line_number,
            		a_end_order_number,
            		a_end_order_rel_number,
            		a_end_order_line_number,
            		a_creation_date,
            		a_tp_creation_date,
            		a_date1,
            		a_date2,
            		a_date3,
            		a_date4,
            		a_date5,
            		a_exception_basis);
                        l_inserted_record := l_inserted_record + 1;

        	end if;   	/* compute exception */

   	/*------------------------------------------------------------------
 	Loop for the last record if require to insert
 	------------------------------------------------------------------*/
 	IF ( j > 1 and l_pair = 0 and j = b_bucket_index.COUNT) THEN
 	   l_pair := 0;
 	   l_insert := 1;
 	   l_start_date := b_bkt_start_date(j);
   	   l_end_date := b_bkt_end_date(j);
     	   l_publisher_id := b_publisher_id(j);
   	   l_publisher_site_id := b_publisher_site_id(j);
   	   l_customer_id := b_customer_id(j);
   	   l_customer_site_id := b_customer_site_id(j);
   	   l_supplier_id := b_supplier_id(j);
   	   l_supplier_site_id := b_supplier_site_id(j);
   	   l_item_id := b_item_id(j);
    	   l_publisher_name := b_publisher_name(j);
   	   l_publisher_site_name := b_publisher_site_name(j);
   	   l_customer_name := b_customer_name(j);
   	   l_customer_site_name := b_customer_site_name(j);
   	   l_supplier_name := b_supplier_name(j);
   	   l_supplier_site_name := b_supplier_site_name(j);

    	   IF (b_order_type(j) = msc_x_netting_pkg.ORDER_FORECAST) THEN
    	      	l_total_demand := b_total_quantity(j);
    	      	l_tp_total_demand := b_tp_total_quantity(j);
    	      	l_posting_total_demand := b_posting_total_quantity(j);
    	      	l_total_supply := 0;
    	      	l_tp_total_supply := 0;
    	      	l_posting_total_supply := 0;
    	   ELSIF (b_order_type(j) = msc_x_netting_pkg.SUPPLY_COMMIT) THEN
    	   	l_total_demand := 0;
    	   	l_tp_total_demand := 0;
    	   	l_posting_total_demand := 0;
    	   	l_total_supply := b_total_quantity(j);
    	   	l_tp_total_supply := b_tp_total_quantity(j);
    	   	l_posting_total_supply := b_posting_total_quantity(j);
   	   END IF;

     	   IF ((l_total_demand - l_tp_total_supply ) > (l_total_demand * l_threshold1/100))
     	   and (b_refresh_number(j) > p_refresh_number)
     	   THEN

      		--if plan_type is SP then detected exception 2.2
      		l_exception_type := msc_x_netting_pkg.G_EXCEP6;
      		l_exception_group := msc_x_netting_pkg.G_MATERIAL_SHORTAGE;
      		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

      		msc_x_netting_pkg.add_to_exception_tbl(
      			l_publisher_id,			--b_publisher_id(j),
            		l_publisher_name,		--b_publisher_name(j),
                      	l_publisher_site_id,		--b_publisher_site_id(j),
                      	l_publisher_site_name,		--b_publisher_site_name(j),
                        l_item_id,			--b_item_id(j),
                        l_item_name,		--b_item_name(j),
                        l_item_desc,		--b_item_desc(j),
                      	l_exception_type,
                      	l_exception_type_name,
                      	l_exception_group,
                      	l_exception_group_name,
                      	null,                   --trx_id1,
                      	null,                   --trx_id2,
                      	null,         --l_customer_id,
                      	null,
                      	null,         --l_customer_site_id,
                      	null,
                      	l_customer_item_name,	--b_customer_item_name(j),
                      	l_supplier_id,			--b_supplier_id(j),
                      	l_supplier_name,		--b_supplier_name(j),
                      	l_supplier_site_id,		--b_supplier_site_id(j),
                      	l_supplier_site_name,		--b_supplier_site_name(j),
                      	l_supplier_item_name,	--b_supplier_item_name(j),
                      	l_tp_total_supply,
                      	l_total_demand,
                      	null,
                      	l_threshold1,
                      	null,         --lead time
            		null,       --item min
            		null,       --item_max
                      	null,                   --l_order_number,
                      	null,                   --l_release_number,
                      	null,                   --l_line_number,
                      	null,                   --l_end_order_number,
                      	null,                   --l_end_order_rel_number,
                      	null,                   --l_end_order_line_number,
                	 null,			--b_so_creation_date(j),
                	 null,			--b_po_creation_date(j),
                	 l_start_date,
                	 l_end_date,
                	 null,			--ship_date(j),
                	 null,			--ship_date(j),
                	 null,
                	 l_exception_basis,
            		a_company_id,
            		a_company_name,
            		a_company_site_id,
            		a_company_site_name,
            		a_item_id,
            		a_item_name,
            		a_item_desc,
            		a_exception_type,
            		a_exception_type_name,
            		a_exception_group,
            		a_exception_group_name,
            		a_trx_id1,
            		a_trx_id2,
            		a_customer_id,
            		a_customer_name,
            		a_customer_site_id,
            		a_customer_site_name,
            		a_customer_item_name,
            		a_supplier_id,
            		a_supplier_name,
            		a_supplier_site_id,
            		a_supplier_site_name,
            		a_supplier_item_name,
            		a_number1,
            		a_number2,
            		a_number3,
            		a_threshold,
            		a_lead_time,
            		a_item_min_qty,
            		a_item_max_qty,
            		a_order_number,
            		a_release_number,
            		a_line_number,
            		a_end_order_number,
            		a_end_order_rel_number,
            		a_end_order_line_number,
            		a_creation_date,
            		a_tp_creation_date,
            		a_date1,
            		a_date2,
            		a_date3,
            		a_date4,
            		a_date5,
            		a_exception_basis);
                        l_inserted_record := l_inserted_record + 1;

        	end if;   	-- compute exception

            end if;		/* end of the last record of the loop */

   	 --END LOOP;
       --END IF;
    --end if;
 END LOOP;
 END IF;

 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' || msc_x_netting_pkg.get_message_type(6) ||
   ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));


/* reset the trxid */
l_generate_complement := null;
--dbms_output.put_line('Exception 7 ');   --supplier centric
open exception_7 (p_refresh_number);
   fetch exception_7 BULK COLLECT INTO
            		b_trx_id1,
            		b_publisher_id,
            		b_publisher_name,
            		b_publisher_site_id,
            		b_publisher_site_name,
            		b_item_id,
            		b_item_name,
            		b_item_desc,
                        b_supplier_item_name,
                        b_supplier_item_desc,
                        b_so_key_date,
                       	b_so_ship_date,
                       	b_so_receipt_date,
                    	b_posting_so_qty,
                      	b_so_qty,
                     	b_tp_so_qty,
                     	b_end_order_number,
                        b_end_order_rel_number,
                     	b_end_order_line_number,
                        b_customer_id,
                        b_customer_name,
                     	b_customer_site_id,
                     	b_customer_site_name,
                     	b_customer_item_name,
                     	b_customer_item_desc,
                     	b_so_creation_date,
                     	b_so_last_refnum,
                     	b_trx_id2,
                     	b_po_key_date,
                     	b_po_ship_date,
                     	b_po_receipt_date,
                        b_posting_po_qty,
                        b_po_qty,
                        b_tp_po_qty,
                        b_order_number,
                     	b_release_number,
                     	b_line_number,
                        b_supplier_id,    --owning com
                        b_supplier_name,
                        b_supplier_site_id,  --owning org
                        b_supplier_site_name,
                        b_po_creation_date,
                        b_po_last_refnum;
 CLOSE exception_7;
 IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
 FOR j in 1..b_trx_id1.COUNT
 LOOP
   --dbms_output.put_line('-----Exception7: Trx id 1 = ' || b_trx_id1(j));
   --dbms_output.put_line('---------------  Trx id 2 = ' || b_trx_id2(j));
      --======================================================
      -- archive old exception and its complement
      --======================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      b_customer_id(j),
      b_customer_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
      msc_x_netting_pkg.G_EXCEP7,
      b_trx_id1(j),
      b_trx_id2(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);


   msc_x_netting_pkg.add_to_delete_tbl(
      b_customer_id(j),
      b_customer_site_id(j),
      null,
      null,
      b_publisher_id(j),
      b_publisher_site_id(j),
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
      msc_x_netting_pkg.G_EXCEP8,
      b_trx_id2(j),
      b_trx_id1(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);

   l_threshold1 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP7,
                              b_publisher_id(j),
                              b_publisher_site_id(j),
                              b_item_id(j),
                              null,
                              null,
                              b_customer_id(j),
                              b_customer_site_id(j),
                              b_so_receipt_date(j));


   l_total_qty := msc_x_netting_pkg.get_total_qty(b_order_number(j),
                                b_release_number(j),
                                b_line_number(j),
               			b_publisher_id(j),
               			b_publisher_site_id(j),
               			b_customer_id(j),
               			b_customer_site_id(j),
                                b_item_id(j));



  if (l_total_qty  + (l_threshold1*b_tp_po_qty(j)/100) < b_tp_po_qty(j)) then
        --======================================================
         -- Clean up the opposite exception and its complement
         --======================================================

         msc_x_netting_pkg.add_to_delete_tbl(
         b_publisher_id(j),
         b_publisher_site_id(j),
         b_customer_id(j),
         b_customer_site_id(j),
         null,
         null,
         b_item_id(j),
         msc_x_netting_pkg.G_MATERIAL_EXCESS,
         msc_x_netting_pkg.G_EXCEP27,
         b_trx_id1(j),
         b_trx_id2(j),
         null,
         null,
         t_company_list,
         t_company_site_list,
         t_customer_list,
         t_customer_site_list,
         t_supplier_list,
         t_supplier_site_list,
         t_item_list,
         t_group_list,
         t_type_list,
         t_trxid1_list,
         t_trxid2_list,
         t_date1_list,
         t_date2_list);

      msc_x_netting_pkg.add_to_delete_tbl(
         b_customer_id(j),
         b_customer_site_id(j),
         null,
         null,
         b_publisher_id(j),
         b_publisher_site_id(j),
         b_item_id(j),
         msc_x_netting_pkg.G_MATERIAL_EXCESS,
         msc_x_netting_pkg.G_EXCEP28,
         b_trx_id2(j),
         b_trx_id1(j),
         null,
         null,
         t_company_list,
         t_company_site_list,
         t_customer_list,
         t_customer_site_list,
         t_supplier_list,
         t_supplier_site_list,
         t_item_list,
         t_group_list,
         t_type_list,
         t_trxid1_list,
         t_trxid2_list,
         t_date1_list,
      t_date2_list);

      IF (j=1 OR (b_publisher_id(j -1) <> b_publisher_id(j) OR
      	     b_publisher_site_id(j-1) <> b_publisher_site_id(j) OR
      	     b_customer_id(j-1) <> b_customer_id(j) OR
      	     b_customer_site_id(j-1) <> b_customer_site_id(j) OR
      	     b_item_id(j-1) <> b_item_id(j) OR
      	     b_order_number(j-1) <> b_order_number(j) OR
      	     b_release_number(j-1) <> b_release_number(j) OR
      	     b_line_number(j-1) <> b_line_number(j) )) THEN



 --dbms_output.put_line('PUB ' || b_publisher_id(j));
 --dbms_output.put_line('PUB SITE ' || b_publisher_site_id(j));
 --dbms_output.put_line('ITEM ' || b_item_id(j));
 --dbms_output.put_line('CUST ' || b_customer_id(j));
 --dbms_output.put_line('CUST SITE ' || b_customer_site_id(j));
 --dbms_output.put_line('ORDER ' || b_order_number(j));
 --dbms_output.put_line('LINE ' || b_line_number(j));
 --dbms_output.put_line('REL ' || b_release_number(j));
 		-------------------------------------------------------------------------
 		-- get the latest SO to populate the exception
 		-------------------------------------------------------------------------
 	BEGIN
 	 	select transaction_id, receipt_date, ship_date, order_number, line_number, release_number
 	 	into l_last_so_trx_id, b_so_receipt_date(j), b_so_ship_date(j), b_end_order_number(j),
 	 	b_end_order_line_number(j), b_end_order_rel_number(j)
        	from msc_sup_dem_entries
 		where	publisher_id = b_publisher_id(j)
 		and	publisher_site_id = b_publisher_site_id(j)
 		and	customer_id = b_customer_id(j)
 		and	customer_site_id = b_customer_site_id(j)
 		and	inventory_item_id = b_item_id(j)
   		and  	publisher_order_type = msc_x_netting_pkg.SALES_ORDER
 		and	end_order_number = b_order_number(j)
 		and	NVL(end_order_line_number,-1) = nvl(b_line_number(j),-1)
   		and 	nvl(end_order_rel_number,-1) = nvl(b_release_number(j),-1)
    		and 	key_date = (select  max(key_date)
 			from	msc_sup_dem_entries
 		 	where	publisher_id = b_publisher_id(j)
		 	and	publisher_site_id = b_publisher_site_id(j)
		 	and	customer_id = b_customer_id(j)
		 	and	customer_site_id = b_customer_site_id(j)
		 	and	inventory_item_id = b_item_id(j)
 			and  	publisher_order_type = msc_x_netting_pkg.SALES_ORDER
 			and	end_order_number = b_order_number(j)
 			and	NVL(end_order_line_number,-1) = nvl(b_line_number(j),-1)
   			and nvl(end_order_rel_number,-1) = nvl(b_release_number(j),-1));
   	--dbms_output.put_line('so trx id ' || l_last_so_trx_id);
   	EXCEPTION
   		when others then
   			null;
   			--dbms_output.put_line('Error ' || sqlerrm);
   	END;

   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      b_customer_id(j),
      b_customer_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
      msc_x_netting_pkg.G_EXCEP7,
      l_last_so_trx_id,
      b_trx_id2(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);


   msc_x_netting_pkg.add_to_delete_tbl(
      b_customer_id(j),
      b_customer_site_id(j),
      null,
      null,
      b_publisher_id(j),
      b_publisher_site_id(j),
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
      msc_x_netting_pkg.G_EXCEP8,
      b_trx_id2(j),
      l_last_so_trx_id,
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);

           msc_x_netting_pkg.add_to_delete_tbl(
           b_publisher_id(j),
           b_publisher_site_id(j),
           b_customer_id(j),
           b_customer_site_id(j),
           null,
           null,
           b_item_id(j),
           msc_x_netting_pkg.G_MATERIAL_EXCESS,
           msc_x_netting_pkg.G_EXCEP27,
           l_last_so_trx_id,
           b_trx_id2(j),
           null,
           null,
           t_company_list,
           t_company_site_list,
           t_customer_list,
           t_customer_site_list,
           t_supplier_list,
           t_supplier_site_list,
           t_item_list,
           t_group_list,
           t_type_list,
           t_trxid1_list,
           t_trxid2_list,
           t_date1_list,
           t_date2_list);

        msc_x_netting_pkg.add_to_delete_tbl(
           b_customer_id(j),
           b_customer_site_id(j),
           null,
           null,
           b_publisher_id(j),
           b_publisher_site_id(j),
           b_item_id(j),
           msc_x_netting_pkg.G_MATERIAL_EXCESS,
           msc_x_netting_pkg.G_EXCEP28,
           b_trx_id2(j),
           l_last_so_trx_id,
           null,
           null,
           t_company_list,
           t_company_site_list,
           t_customer_list,
           t_customer_site_list,
           t_supplier_list,
           t_supplier_site_list,
           t_item_list,
           t_group_list,
           t_type_list,
           t_trxid1_list,
           t_trxid2_list,
           t_date1_list,
      t_date2_list);


       		--------------------------------------------------------------------------
      		-- get the shipping control
      		---------------------------------------------------------------------------
      		l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_customer_name(j),
                                    b_customer_site_name(j),
                                    b_publisher_name(j),
                                    b_publisher_site_name(j));

      		l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

      		l_exception_type := msc_x_netting_pkg.G_EXCEP7;  -- fulfillment qty shortfall for your cust po
      		l_exception_group := msc_x_netting_pkg.G_MATERIAL_SHORTAGE;
      		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

             	msc_x_netting_pkg.add_to_exception_tbl(b_publisher_id(j),
               			b_publisher_name(j),
                                b_publisher_site_id(j),
                               	b_publisher_site_name(j),
                                b_item_id(j),
                                b_item_name(j),
                                b_item_desc(j),
                                l_exception_type,
                                l_exception_type_name,
                                l_exception_group,
                                l_exception_group_name,
                                l_last_so_trx_id,		--b_trx_id1(j),
                                b_trx_id2(j),
                                b_customer_id(j),
                                b_customer_name(j),
                                b_customer_site_id(j),
                                b_customer_site_name(j),
                               	b_customer_item_name(j),
                                null,  --l_supplier_id,
                                null,
                                null,  --l_supplier_site_id,
                                null,
                                b_supplier_item_name(j), --item name
                                l_total_qty,    --number1
                                b_tp_po_qty(j),    --number2
                                null,        --number3
                                l_threshold1,
                                null,        --lead time
               			null,       --l_item_min,
               			null,       --l_item_max,
                                b_order_number(j),
                               	b_release_number(j),
                                b_line_number(j),
                                b_end_order_number(j),
                                b_end_order_rel_number(j),
                                b_end_order_line_number(j),
                                null,
                                null,
                                b_so_receipt_date(j),
                                b_po_receipt_date(j),
                                b_so_ship_date(j),
                                b_po_ship_date(j),
                                null,
                                l_exception_basis,
               			a_company_id,
               			a_company_name,
               			a_company_site_id,
               			a_company_site_name,
               			a_item_id,
               			a_item_name,
               			a_item_desc,
               			a_exception_type,
               			a_exception_type_name,
               			a_exception_group,
               			a_exception_group_name,
               			a_trx_id1,
               			a_trx_id2,
               			a_customer_id,
               			a_customer_name,
               			a_customer_site_id,
               			a_customer_site_name,
               			a_customer_item_name,
               			a_supplier_id,
               			a_supplier_name,
               			a_supplier_site_id,
               			a_supplier_site_name,
               			a_supplier_item_name,
               			a_number1,
               			a_number2,
               			a_number3,
               			a_threshold,
               			a_lead_time,
               			a_item_min_qty,
               			a_item_max_qty,
               			a_order_number,
               			a_release_number,
               			a_line_number,
               			a_end_order_number,
               			a_end_order_rel_number,
               			a_end_order_line_number,
               			a_creation_date,
               			a_tp_creation_date,
               			a_date1,
               			a_date2,
               			a_date3,
               			a_date4,
               			a_date5,
               			a_exception_basis);
               			l_inserted_record := l_inserted_record + 1;

      	 if (b_po_last_refnum(j) <= p_refresh_number) then
         	--dbms_output.put_line('In complement exception7 ');
         	l_complement_threshold:= msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP8,
               		b_customer_id(j),
               		b_customer_site_id(j),
               		b_item_id(j),
               		b_publisher_id(j),
               		b_publisher_site_id(j),
               		null,
               		null,
                        b_po_key_date(j));

            if (l_total_qty  + (l_complement_threshold*b_po_qty(j)/100) < b_po_qty(j)) then

         	l_exception_type := msc_x_netting_pkg.G_EXCEP8; --fulfillment qty shortfall from yr sup
         	l_exception_group := msc_x_netting_pkg.G_MATERIAL_SHORTAGE;
         	l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
         	l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

         	msc_x_netting_pkg.add_to_exception_tbl(b_customer_id(j),
                  b_customer_name(j),
                              b_customer_site_id(j),
                              b_customer_site_name(j),
                              b_item_id(j),
                              b_item_name(j),
                              b_item_desc(j),
                              l_exception_type,
                              l_exception_type_name,
                              l_exception_group,
                              l_exception_group_name,
                              b_trx_id2(j),
                              l_last_so_trx_id,			--b_trx_id1(j),
                              null, --l_customer_id,
                              null, --
                              null, --l_customer_site_id,
                              null,
                              b_customer_item_name(j),
                              b_publisher_id(j),
                              b_publisher_name(j),
                              b_publisher_site_id(j),
                              b_publisher_site_name(j),
                              b_supplier_item_name(j),
                              b_po_qty(j), --number1
                              l_total_qty,      --number2
                              null,       --number3
                              l_complement_threshold,
                              null,       --lead time
                  	      null,       --l_item_min,
                  	      null,       --l_item_max,
                              b_order_number(j),
                              b_release_number(j),
                              b_line_number(j),
                              b_end_order_number(j),
                              b_end_order_rel_number(j),
                              b_end_order_line_number(j),
                  	      null,			--b_po_creation_date(j),
                  	      null,			--b_so_creation_date(j),
                  	      b_po_receipt_date(j),
                  	      b_so_receipt_date(j),
                  	      b_so_ship_date(j),
                  	      b_po_ship_date(j),
                  	      null,
                 	      l_exception_basis,
                  	a_company_id,
                  	a_company_name,
                  	a_company_site_id,
                  	a_company_site_name,
                  	a_item_id,
                  	a_item_name,
                  	a_item_desc,
                  	a_exception_type,
                  	a_exception_type_name,
                  	a_exception_group,
                  	a_exception_group_name,
                  	a_trx_id1,
                  	a_trx_id2,
                  	a_customer_id,
                  	a_customer_name,
                  	a_customer_site_id,
                  	a_customer_site_name,
                  	a_customer_item_name,
                  	a_supplier_id,
                  	a_supplier_name,
                  	a_supplier_site_id,
                  	a_supplier_site_name,
                  	a_supplier_item_name,
                  	a_number1,
                  	a_number2,
                  	a_number3,
                  	a_threshold,
                  	a_lead_time,
                  	a_item_min_qty,
                  	a_item_max_qty,
                  	a_order_number,
                  	a_release_number,
                  	a_line_number,
                  	a_end_order_number,
                  	a_end_order_rel_number,
                  	a_end_order_line_number,
            	  	a_creation_date,
            	  	a_tp_creation_date,
            	  	a_date1,
            	  	a_date2,
            	  	a_date3,
            	  	a_date4,
            	  	a_date5,
            	  	a_exception_basis);
            	  	l_inserted_record := l_inserted_record + 1;
            end if;
      	 end if;
   	END IF;			-- if j=1
   end if;			-- if total qty
END LOOP;
END IF;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' || msc_x_netting_pkg.get_message_type(7) ||
   ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

/* reset the trxid */
l_generate_complement := null;

--dbms_output.put_line('Exception 8');    --customer centric
open exception_8 ( p_refresh_number);
      fetch exception_8 BULK COLLECT INTO
                  	b_trx_id1,
                  	b_publisher_id,
                  	b_publisher_name,
                  	b_publisher_site_id,
                  	b_publisher_site_name,
                  	b_item_id,
                  	b_item_name,
                  	b_item_desc,
                        b_customer_item_name,
                        b_customer_item_desc,
                        b_po_key_date,
               		b_po_ship_date,
               		b_po_receipt_date,
               		b_posting_po_qty,
                     	b_po_qty,
                   	b_tp_po_qty,
                     	b_order_number,
                      	b_release_number,
                      	b_line_number,
                     	b_supplier_id,
                     	b_supplier_name,
                       	b_supplier_site_id,
                      	b_supplier_site_name,
                   	b_supplier_item_name,
                   	b_supplier_item_desc,
                     	b_po_creation_date,
                       	b_po_last_refnum,
                    	b_trx_id2,
                    	b_so_key_date,
                      	b_so_ship_date,
                    	b_so_receipt_date,
                       	b_posting_so_qty,
                     	b_so_qty,
                     	b_tp_so_qty,
                      	b_end_order_number,
                      	b_end_order_rel_number,
                     	b_end_order_line_number,
                     	b_customer_id,
                       	b_customer_name,
                       	b_customer_site_id, --owning org
                    	b_customer_site_name,
                       	b_so_creation_date,
                      	b_so_last_refnum;
  CLOSE exception_8;
  IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
  FOR j in 1..b_trx_id1.COUNT
  LOOP
      --dbms_output.put_line('-----Exception8: Trx id 1 = ' || b_trx_id1(j));
      --dbms_output.put_line('---------------  Trx id 2 = ' || b_trx_id2(j));

      --======================================================
      -- archive old exception and its complement
      --======================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
      msc_x_netting_pkg.G_EXCEP8,
      b_trx_id1(j),
      b_trx_id2(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);

   msc_x_netting_pkg.add_to_delete_tbl(
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
      msc_x_netting_pkg.G_EXCEP7,
      b_trx_id2(j),
      b_trx_id1(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);


   l_threshold1 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP8,
            		b_publisher_id(j),
                  	b_publisher_site_id(j),
               		b_item_id(j),
            		b_supplier_id(j),
            		b_supplier_site_id(j),
            		null,
            		null,
                     	b_po_key_date(j));

    l_total_qty := msc_x_netting_pkg.get_total_qty(b_order_number(j),
                        b_release_number(j),
                        b_line_number(j),
            		b_supplier_id(j),
            		b_supplier_site_id(j),
                        b_publisher_id(j),
                        b_publisher_site_id(j),
                        b_item_id(j));

   IF (l_total_qty + (l_threshold1*b_po_qty(j)/100) < b_po_qty(j) ) THEN
            --======================================================
         -- Clean up the opposite exception and its complement
      --======================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_EXCESS,
      msc_x_netting_pkg.G_EXCEP28,
      b_trx_id1(j),
      b_trx_id2(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);

   msc_x_netting_pkg.add_to_delete_tbl(
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_EXCESS,
      msc_x_netting_pkg.G_EXCEP27,
      b_trx_id2(j),
      b_trx_id1(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);


      IF (j=1 OR (b_publisher_id(j -1) <> b_publisher_id(j) OR
      	     b_publisher_site_id(j-1) <> b_publisher_site_id(j) OR
      	     b_customer_id(j-1) <> b_customer_id(j) OR
      	     b_customer_site_id(j-1) <> b_customer_site_id(j) OR
      	     b_item_id(j-1) <> b_item_id(j) OR
      	     b_order_number(j-1) <> b_order_number(j) OR
      	     b_release_number(j-1) <> b_release_number(j) OR
      	     b_line_number(j-1) <> b_line_number(j) )) THEN


 		-------------------------------------------------------------------------
 		-- get the latest SO to populate the exception
 		-------------------------------------------------------------------------
 	BEGIN
 	 	select transaction_id, receipt_date, ship_date, order_number, line_number, release_number, last_refresh_number
 	 	into l_last_so_trx_id, b_so_receipt_date(j), b_so_ship_date(j), b_end_order_number(j),
 	 	b_end_order_line_number(j), b_end_order_rel_number(j), b_so_last_refnum(j)
        	from msc_sup_dem_entries
 		where	publisher_id = b_supplier_id(j)
 		and	publisher_site_id = b_supplier_site_id(j)
 		and	customer_id = b_publisher_id(j)
 		and	customer_site_id = b_publisher_site_id(j)
 		and	inventory_item_id = b_item_id(j)
   		and  	publisher_order_type = msc_x_netting_pkg.SALES_ORDER
 		and	end_order_number = b_order_number(j)
 		and	NVL(end_order_line_number,-1) = nvl(b_line_number(j),-1)
   		and 	nvl(end_order_rel_number,-1) = nvl(b_release_number(j),-1)
    		and 	key_date = (select  max(key_date)
 			from	msc_sup_dem_entries
 		 	where	publisher_id = b_supplier_id(j)
		 	and	publisher_site_id = b_supplier_site_id(j)
		 	and	customer_id = b_publisher_id(j)
		 	and	customer_site_id = b_publisher_site_id(j)
		 	and	inventory_item_id = b_item_id(j)
 			and  	publisher_order_type = msc_x_netting_pkg.SALES_ORDER
 			and	end_order_number = b_order_number(j)
 			and	NVL(end_order_line_number,-1) = nvl(b_line_number(j),-1)
   			and nvl(end_order_rel_number,-1) = nvl(b_release_number(j),-1) );
   	EXCEPTION
   		when others then
   			null;
   			--dbms_output.put_line('Error ' || sqlerrm);
   	END;

     		SELECT max(last_refresh_number)
     		into b_so_last_refnum(j)
  			from	msc_sup_dem_entries
  		 	where	publisher_id = b_supplier_id(j)
 		 	and	publisher_site_id = b_supplier_site_id(j)
 		 	and	customer_id = b_publisher_id(j)
 		 	and	customer_site_id = b_publisher_site_id(j)
 		 	and	inventory_item_id = b_item_id(j)
  			and  	publisher_order_type = msc_x_netting_pkg.SALES_ORDER
  			and	end_order_number = b_order_number(j)
  			and	NVL(end_order_line_number,-1) = nvl(b_line_number(j),-1)
   			and nvl(end_order_rel_number,-1) = nvl(b_release_number(j),-1);


  --dbms_output.put_line('trx id ' || l_last_so_trx_id || ' last ref num ' || b_so_last_refnum(j) || ' p_refnum ' || p_refresh_number);

       --======================================================
       -- archive old exception and its complement
       --======================================================
    msc_x_netting_pkg.add_to_delete_tbl(
       b_publisher_id(j),
       b_publisher_site_id(j),
       null,
       null,
       b_supplier_id(j),
       b_supplier_site_id(j),
       b_item_id(j),
       msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
       msc_x_netting_pkg.G_EXCEP8,
       b_trx_id1(j),
       l_last_so_trx_id,
       null,
       null,
       t_company_list,
       t_company_site_list,
       t_customer_list,
       t_customer_site_list,
       t_supplier_list,
       t_supplier_site_list,
       t_item_list,
       t_group_list,
       t_type_list,
       t_trxid1_list,
       t_trxid2_list,
       t_date1_list,
       t_date2_list);

    msc_x_netting_pkg.add_to_delete_tbl(
       b_supplier_id(j),
       b_supplier_site_id(j),
       b_publisher_id(j),
       b_publisher_site_id(j),
       null,
       null,
       b_item_id(j),
       msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
       msc_x_netting_pkg.G_EXCEP7,
       l_last_so_trx_id,
       b_trx_id1(j),
       null,
       null,
       t_company_list,
       t_company_site_list,
       t_customer_list,
       t_customer_site_list,
       t_supplier_list,
       t_supplier_site_list,
       t_item_list,
       t_group_list,
       t_type_list,
       t_trxid1_list,
       t_trxid2_list,
       t_date1_list,
      t_date2_list);

   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_EXCESS,
      msc_x_netting_pkg.G_EXCEP28,
      b_trx_id1(j),
      l_last_so_trx_id,
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);

   msc_x_netting_pkg.add_to_delete_tbl(
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_EXCESS,
      msc_x_netting_pkg.G_EXCEP27,
      l_last_so_trx_id,
      b_trx_id1(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);

      		--------------------------------------------------------------------------
      		-- get the shipping control
      		---------------------------------------------------------------------------
      		l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                    b_publisher_site_name(j),
                                    b_supplier_name(j),
                                    b_supplier_site_name(j));

      		l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

      		l_exception_type := msc_x_netting_pkg.G_EXCEP8;  -- fulfillment qty shortfall from sup for your po
      		l_exception_group := msc_x_netting_pkg.G_MATERIAL_SHORTAGE;
      		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);


      		msc_x_netting_pkg.add_to_exception_tbl(b_publisher_id(j),
                     b_publisher_name(j),
                                b_publisher_site_id(j),
                                b_publisher_site_name(j),
                                b_item_id(j),
                                b_item_name(j),
                                b_item_desc(j),
                                l_exception_type,
                                l_exception_type_name,
                                l_exception_group,
                                l_exception_group_name,
                                b_trx_id1(j),
                                l_last_so_trx_id,		--b_trx_id2(j),
                                null,  --l_customer_id,
                                null,
                                null,--   l_customer_site_id,
                                null,
                                b_customer_item_name(j),
                                b_supplier_id(j),
                                b_supplier_name(j),
                                b_supplier_site_id(j),
                                b_supplier_site_name(j),
                                b_supplier_item_name(j),
                                b_po_qty(j),     --number1
                                l_total_qty,       --number2
                                null,           --number3
                                l_threshold1,
                                null,        --lead time
            			null,       --l_item_min,
            			null,       --l_item_max,
                                b_order_number(j),
                                b_release_number(j),
                                b_line_number(j),
                                b_end_order_number(j),
                                b_end_order_rel_number(j),
                                b_end_order_line_number(j),
            			null,				--b_po_creation_date(j),
            			null,				--b_so_creation_date(j),
            			b_po_receipt_date(j),
            			b_so_receipt_date(j),
            			b_so_ship_date(j),
            			b_po_ship_date(j),
            			null,
            			l_exception_basis,
            		a_company_id,
            		a_company_name,
            		a_company_site_id,
            		a_company_site_name,
            		a_item_id,
            		a_item_name,
            		a_item_desc,
            		a_exception_type,
            		a_exception_type_name,
            		a_exception_group,
            		a_exception_group_name,
            		a_trx_id1,
            		a_trx_id2,
            		a_customer_id,
            		a_customer_name,
            		a_customer_site_id,
            		a_customer_site_name,
            		a_customer_item_name,
            		a_supplier_id,
            		a_supplier_name,
            		a_supplier_site_id,
            		a_supplier_site_name,
            		a_supplier_item_name,
            		a_number1,
            		a_number2,
            		a_number3,
            		a_threshold,
            		a_lead_time,
            		a_item_min_qty,
            		a_item_max_qty,
            		a_order_number,
            		a_release_number,
            		a_line_number,
            		a_end_order_number,
            		a_end_order_rel_number,
            		a_end_order_line_number,
            		a_creation_date,
            		a_tp_creation_date,
            		a_date1,
            		a_date2,
            		a_date3,
            		a_date4,
            		a_date5,
            		a_exception_basis);
                        l_inserted_record := l_inserted_record + 1;

     	   if (b_so_last_refnum(j) <= p_refresh_number) then
                --dbms_output.put_line('In complement 8');

      			l_complement_threshold:= msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP7,
            		b_supplier_id(j),
            		b_supplier_site_id(j),
            		b_item_id(j),
            		null,
            		null,
            		b_publisher_id(j),
            		b_publisher_site_id(j),
                     	b_so_key_date(j));
       		if (l_total_qty + (l_complement_threshold* b_po_qty(j)/100) < b_po_qty(j) ) THEN

            		l_exception_type := msc_x_netting_pkg.G_EXCEP7;
            		l_exception_group := msc_x_netting_pkg.G_MATERIAL_SHORTAGE;
            		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
            		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

            		msc_x_netting_pkg.add_to_exception_tbl(b_supplier_id(j),
                     	b_supplier_name(j),
                              b_supplier_site_id(j),
                              b_supplier_site_name(j),
                              b_item_id(j),
                              b_item_name(j),
                              b_item_desc(j),
                              l_exception_type,
                              l_exception_type_name,
                              l_exception_group,
                              l_exception_group_name,
                              l_last_so_trx_id,			--b_trx_id2(j),
                              b_trx_id1(j),
                              b_publisher_id(j),
                              b_publisher_name(j),
                              b_publisher_site_id(j),
                              b_publisher_site_name(j),
                              b_customer_item_name(j),
                              null, --l_supplier_id,
                              null,
                              null, --l_supplier_site_id,
                              null,
                              b_supplier_item_name(j),   --item name
                              l_total_qty,      --number1
                              b_tp_po_qty(j),      --number2
                              null,       --number3
                              l_complement_threshold,
                              null,       --lead time
                  		null,       --l_item_min,
                  		null,       --l_item_max,
                              b_order_number(j),
                              b_release_number(j),
                              b_line_number(j),
                              b_end_order_number(j),
                              b_end_order_rel_number(j),
                              b_end_order_line_number(j),
                              null,				--b_so_creation_date(j),
                              null,				--b_po_creation_date(j),
                              b_so_receipt_date(j),
                              b_po_receipt_date(j),
                              b_so_ship_date(j),
                              b_po_ship_date(j),
                              null,
                              l_exception_basis,
                  	a_company_id,
                  	a_company_name,
                  	a_company_site_id,
                  	a_company_site_name,
                  	a_item_id,
                  	a_item_name,
                  	a_item_desc,
                  	a_exception_type,
                  	a_exception_type_name,
                  	a_exception_group,
                  	a_exception_group_name,
                  	a_trx_id1,
                  	a_trx_id2,
                  	a_customer_id,
                  	a_customer_name,
                  	a_customer_site_id,
                  	a_customer_site_name,
                  	a_customer_item_name,
                  	a_supplier_id,
                  	a_supplier_name,
                  	a_supplier_site_id,
                  	a_supplier_site_name,
                  	a_supplier_item_name,
                  	a_number1,
                  	a_number2,
                  	a_number3,
                  	a_threshold,
                  	a_lead_time,
                  	a_item_min_qty,
                  	a_item_max_qty,
                  	a_order_number,
                  	a_release_number,
                  	a_line_number,
                  	a_end_order_number,
                  	a_end_order_rel_number,
                  	a_end_order_line_number,
            	  	a_creation_date,
            	  	a_tp_creation_date,
            	  	a_date1,
            	  	a_date2,
            	  	a_date3,
            	  	a_date4,
            	  	a_date5,
            	  	a_exception_basis);
                        l_inserted_record := l_inserted_record + 1;
              	end if;
           end if;
      	END IF;			-- if j=1
   end if;
END LOOP;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' || msc_x_netting_pkg.get_message_type(8) ||
   ':' ||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total exceptions inserted for the group ' ||
 msc_x_netting_pkg.get_message_group(msc_x_netting_pkg.G_MATERIAL_SHORTAGE) || ':' || l_inserted_record);


-- added exception handler
EXCEPTION
   WHEN OTHERS THEN
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING2_PKG.Compute_Material_Shortage');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
   	--dbms_output.put_line('error in material shortage ' || sqlerrm);
END Compute_Material_Shortage;


--==================================================================
--COMPUTE_MATERIAL_EXCESS (supply planning)
--==================================================================
--======================================================================
PROCEDURE COMPUTE_MATERIAL_EXCESS(   p_refresh_number IN Number,
   t_company_list       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_company_site_list  IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_customer_list      IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_customer_site_list IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_supplier_list      IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_supplier_site_list IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_item_list       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_group_list      IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_type_list       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_trxid1_list     IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_trxid2_list     IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_date1_list      IN OUT NOCOPY  msc_x_netting_pkg.date_arr,
   t_date2_list      IN OUT NOCOPY  msc_x_netting_pkg.date_arr,
   a_company_id            IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_company_name          IN OUT NOCOPY  msc_x_netting_pkg.publisherList,
   a_company_site_id       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_company_site_name     IN OUT NOCOPY  msc_x_netting_pkg.pubsiteList,
   a_item_id               IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_item_name             IN OUT NOCOPY  msc_x_netting_pkg.itemnameList,
   a_item_desc             IN OUT NOCOPY  msc_x_netting_pkg.itemdescList,
   a_exception_type        IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   a_exception_type_name   IN OUT NOCOPY  msc_x_netting_pkg.exceptypeList,
   a_exception_group       IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_exception_group_name  IN OUT NOCOPY msc_x_netting_pkg.excepgroupList,
   a_trx_id1               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_trx_id2               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_id           IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_name         IN OUT NOCOPY msc_x_netting_pkg.customerList,
   a_customer_site_id      IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_site_name    IN OUT NOCOPY msc_x_netting_pkg.custsiteList,
   a_customer_item_name    IN OUT NOCOPY msc_x_netting_pkg.itemnameList,
   a_supplier_id           IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_supplier_name         IN OUT NOCOPY msc_x_netting_pkg.supplierList,
   a_supplier_site_id      IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_supplier_site_name    IN OUT NOCOPY msc_x_netting_pkg.suppsiteList,
   a_supplier_item_name    IN OUT NOCOPY msc_x_netting_pkg.itemnameList,
   a_number1               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_number2               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_number3               IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_threshold             IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_lead_time             IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_item_min_qty          IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_item_max_qty          IN OUT NOCOPY msc_x_netting_pkg.number_arr,
   a_order_number          IN OUT NOCOPY msc_x_netting_pkg.ordernumberList,
   a_release_number        IN OUT NOCOPY msc_x_netting_pkg.releasenumList,
   a_line_number           IN OUT NOCOPY msc_x_netting_pkg.linenumList,
   a_end_order_number      IN OUT NOCOPY msc_x_netting_pkg.ordernumberList,
   a_end_order_rel_number  IN OUT NOCOPY msc_x_netting_pkg.releasenumList,
   a_end_order_line_number IN OUT NOCOPY msc_x_netting_pkg.linenumList,
   a_creation_date         IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_tp_creation_date      IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date1           	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date2        	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date3            	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date4		   IN OUT  NOCOPY msc_x_netting_pkg.date_arr,
   a_date5		   IN OUT  NOCOPY msc_x_netting_pkg.date_arr,
   a_exception_basis	   IN OUT  NOCOPY msc_x_netting_pkg.exceptbasisList) IS


  b_trx_id1                	msc_x_netting_pkg.number_arr;
  b_trx_id2                	msc_x_netting_pkg.number_arr;
  b_publisher_id     		msc_x_netting_pkg.number_arr;
  b_publisher_site_id      	msc_x_netting_pkg.number_arr;
  b_item_id                	msc_x_netting_pkg.number_arr;
  b_po_qty                 	msc_x_netting_pkg.number_arr;
  b_so_qty                 	msc_x_netting_pkg.number_arr;
  b_tp_po_qty        		msc_x_netting_pkg.number_arr;
  b_tp_so_qty        		msc_x_netting_pkg.number_arr;
  b_posting_po_qty      	msc_x_netting_pkg.number_arr;
  b_posting_so_qty      	msc_x_netting_pkg.number_arr;
  b_customer_id         	msc_x_netting_pkg.number_arr;
  b_customer_site_id    	msc_x_netting_pkg.number_arr;
  b_supplier_id         	msc_x_netting_pkg.number_arr;
  b_supplier_site_id    	msc_x_netting_pkg.number_arr;
  b_po_last_refnum      	msc_x_netting_pkg.number_arr;
  b_so_last_refnum      	msc_x_netting_pkg.number_arr;
  b_po_key_date     		msc_x_netting_pkg.date_arr;
  b_so_key_date     		msc_x_netting_pkg.date_arr;
  b_po_receipt_date     	msc_x_netting_pkg.date_arr;
  b_so_receipt_date     	msc_x_netting_pkg.date_arr;
  b_po_ship_date     		msc_x_netting_pkg.date_arr;
  b_so_ship_date     		msc_x_netting_pkg.date_arr;
  b_po_creation_date       	msc_x_netting_pkg.date_arr;
  b_so_creation_date    	msc_x_netting_pkg.date_arr;
  b_item_name        		msc_x_netting_pkg.itemnameList;
  b_item_desc        		msc_x_netting_pkg.itemdescList;
  b_publisher_name      	msc_x_netting_pkg.publisherList;
  b_publisher_site_name    	msc_x_netting_pkg.pubsiteList;
  b_supplier_name       	msc_x_netting_pkg.supplierList;
  b_supplier_site_name     	msc_x_netting_pkg.suppsiteList;
  b_supplier_item_name     	msc_x_netting_pkg.itemnameList;
  b_supplier_item_desc     	msc_x_netting_pkg.itemdescList;
  b_customer_name       	msc_x_netting_pkg.customerList;
  b_customer_site_name     	msc_x_netting_pkg.custsiteList;
  b_customer_item_name     	msc_x_netting_pkg.itemnameList;
  b_customer_item_desc     	msc_x_netting_pkg.itemdescList;
  b_order_number     		msc_x_netting_pkg.ordernumberList;
  b_release_number      	msc_x_netting_pkg.releasenumList;
  b_line_number      		msc_x_netting_pkg.linenumList;
  b_end_order_number       	msc_x_netting_pkg.ordernumberList;
  b_end_order_rel_number   	msc_x_netting_pkg.releasenumList;
  b_end_order_line_number  	msc_x_netting_pkg.linenumList;
  b_refresh_number              msc_x_netting_pkg.number_arr;

 l_start_date     		Date;
 l_end_date    			Date;
 l_bucket_type    		Number;
 l_total_demand      		Number := 0;
 l_tp_total_demand   		Number := 0;
 l_total_supply      		Number := 0;
 l_tp_total_supply   		Number := 0;
 l_total_qty      		Number;
 l_exception_type 		Number;
 l_obs_exception     		Number;
 l_exception_group   		Number;
 l_generate_complement  	Boolean;
 l_updated     			Number;
 l_complement_threshold 	Number;
 l_cutoff_ref_num 		Number;
 l_threshold1     		Number;
 l_threshold2     		Number;
 l_exception_type_name  	fnd_lookup_values.meaning%type;
 l_exception_group_name 	fnd_lookup_values.meaning%type;
 l_posting_total_demand 	Number := 0;
 l_posting_total_supply 	Number := 0;
 l_sum         			Number := 0;
 l_item_desc			msc_sup_dem_entries.item_description%type;
 l_shipping_control		Number;
 l_exception_basis		msc_x_exception_details.exception_basis%type;

 l_last_so_trx_id		Number;
 l_receipt_date			Date;
 l_ship_date			Date;
 l_order_number			msc_sup_dem_entries.order_number%type;
 l_line_number			msc_sup_dem_entries.line_number%type;
 l_release_number		msc_sup_dem_entries.release_number%type;
 l_count			Number:=0;
 l_item_name			msc_sup_dem_entries.item_name%type;
 l_customer_item_name		msc_sup_dem_entries.customer_item_name%type;
 l_supplier_item_name		msc_sup_dem_entries.supplier_item_name%type;
 l_publisher_name		msc_sup_dem_entries.publisher_name%type;
 l_publisher_site_name		msc_sup_dem_entries.publisher_site_name%type;
 l_supplier_name		msc_sup_dem_entries.supplier_name%type;
 l_supplier_site_name		msc_sup_dem_entries.supplier_site_name%type;
 l_customer_name		msc_sup_dem_entries.customer_name%type;
 l_customer_site_name		msc_sup_dem_entries.customer_site_name%type;
 l_publisher_id			Number;
 l_publisher_site_id		Number;
 l_customer_id			Number;
 l_customer_site_id		Number;
 l_supplier_id			Number;
 l_supplier_site_id		Number;
 l_item_id			Number;


 l_pair				Number:= 0;
 l_insert			Number := 0;
 l_inserted_record		Number := 0;

 b_bucket_index			msc_x_netting_pkg.number_arr;
 b_bkt_start_date		msc_x_netting_pkg.date_arr;
 b_bkt_end_date			msc_x_netting_pkg.date_arr;
 b_order_type			msc_x_netting_pkg.number_arr;
 b_total_quantity		msc_x_netting_pkg.number_arr;
 b_tp_total_quantity		msc_x_netting_pkg.number_arr;
 b_posting_total_quantity	msc_x_netting_pkg.number_arr;

BEGIN

--dbms_output.put_line('Exception 25');

open exception_25(p_refresh_number);
    fetch exception_25 BULK COLLECT INTO
    	b_publisher_id,
   	b_publisher_site_id,
   	b_supplier_id,
   	b_supplier_site_id,
   	b_customer_id,
   	b_customer_site_id,
   	b_item_id,
    	b_bucket_index,
    	b_bkt_start_date,
   	b_bkt_end_date,
    	b_order_type,
   	b_publisher_name,
   	b_publisher_site_name,
   	b_supplier_name,
   	b_supplier_site_name,
   	b_customer_name,
   	b_customer_site_name,
   	b_item_name,
	b_item_desc,
	b_supplier_item_name,
	b_customer_item_name,
    	b_total_quantity,
	b_tp_total_quantity,
	b_posting_total_quantity,
	b_refresh_number;
CLOSE exception_25;

IF (b_item_id is not null and b_item_id.COUNT > 0) THEN
FOR j in 1..b_item_id.COUNT
LOOP


 IF (j = 1 or b_publisher_id(j) <> b_publisher_id(j-1) OR
 		b_publisher_site_id(j) <> b_publisher_site_id(j-1) OR
 		b_customer_id(j) <> b_customer_id(j-1) OR
 		b_customer_site_id(j) <> b_customer_site_id(j-1) OR
 		b_supplier_id(j) <> b_supplier_id(j-1) OR
 		b_supplier_site_id(j) <> b_supplier_site_id(j-1) OR
 		b_item_id(j) <> b_item_id(j-1)) THEN


      --======================================================
      -- archive old exception and its complement
      --======================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      b_customer_id(j),
      b_customer_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_EXCESS,
      msc_x_netting_pkg.G_EXCEP25,
      null,
      null,
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);


      l_threshold2 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP25,
                     	b_publisher_id(j),
                  	b_publisher_site_id(j),
                  	b_item_id(j),
               		null,
               		null,
               		b_customer_id(j),
               		b_customer_site_id(j),
                     	null);

       --------------------------------------------------------------------------
     -- get the shipping control
     ---------------------------------------------------------------------------
     l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_customer_name(j),
                                        b_customer_site_name(j),
                                        b_publisher_name(j),
                                        b_publisher_site_name(j));

     l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));
 END IF;


IF (j > 1 and b_publisher_id(j) = b_publisher_id(j-1) AND
 		b_publisher_site_id(j) = b_publisher_site_id(j-1) AND
 		b_customer_id(j) = b_customer_id(j-1) AND
 		b_customer_site_id(j) = b_customer_site_id(j-1) AND
 		b_supplier_id(j) = b_supplier_id(j-1) AND
 		b_supplier_site_id(j) = b_supplier_site_id(j-1) AND
 		b_item_id(j) = b_item_id(j-1) and
 		b_bucket_index(j) = b_bucket_index(j-1) and
   		b_bkt_start_date(j) = b_bkt_start_date(j-1)) THEN

   	   IF (b_order_type(j-1) = msc_x_netting_pkg.ORDER_FORECAST ) THEN
   	      	l_total_demand := b_total_quantity(j-1);
   	      	l_tp_total_demand := b_tp_total_quantity(j-1);
   	      	l_posting_total_demand := b_posting_total_quantity(j-1);
   	   ELSIF (b_order_type(j-1)= msc_x_netting_pkg.SUPPLY_COMMIT) THEN
   	   	l_total_supply := b_total_quantity(j-1);
   	   	l_tp_total_supply := b_tp_total_quantity(j-1);
   	   	l_posting_total_supply := b_posting_total_quantity(j-1);
   	   END IF;
    	   IF (b_order_type(j) = msc_x_netting_pkg.ORDER_FORECAST) THEN
    	      	l_total_demand := b_total_quantity(j);
   	      	l_tp_total_demand := b_tp_total_quantity(j);
   	      	l_posting_total_demand := b_posting_total_quantity(j);
   	   ELSIF (b_order_type(j) = msc_x_netting_pkg.SUPPLY_COMMIT)  THEN
      	   	l_total_supply := b_total_quantity(j);
   	   	l_tp_total_supply := b_tp_total_quantity(j);
   	   	l_posting_total_supply := b_posting_total_quantity(j);
   	   END IF;
   	   l_pair := 1;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j-1);
   	   l_end_date := b_bkt_end_date(j-1);
   	   l_publisher_id := b_publisher_id(j-1);
   	   l_publisher_site_id := b_publisher_site_id(j-1);
   	   l_customer_id := b_customer_id(j-1);
   	   l_customer_site_id := b_customer_site_id(j-1);
   	   l_supplier_id := b_supplier_id(j-1);
   	   l_supplier_site_id := b_supplier_site_id(j-1);
   	   l_item_id := b_item_id(j-1);
   	   l_publisher_name := b_publisher_name(j-1);
   	   l_publisher_site_name := b_publisher_site_name(j-1);
   	   l_customer_name := b_customer_name(j-1);
   	   l_customer_site_name := b_customer_site_name(j-1);
   	   l_supplier_name := b_supplier_name(j-1);
   	   l_supplier_site_name := b_supplier_site_name(j-1);



 --dbms_output.put_line('equal insert ' || b_bkt_start_date(j));
 ELSIF (j > 1 and b_publisher_id(j) = b_publisher_id(j-1) AND
 		b_publisher_site_id(j) = b_publisher_site_id(j-1) AND
 		b_customer_id(j) = b_customer_id(j-1) AND
 		b_customer_site_id(j) = b_customer_site_id(j-1) AND
 		b_supplier_id(j) = b_supplier_id(j-1) AND
 		b_supplier_site_id(j) = b_supplier_site_id(j-1) AND
 		b_item_id(j) = b_item_id(j-1) AND
 		b_bucket_index(j) <> b_bucket_index(j-1) and l_pair = 1) THEN
	   l_pair := 0;
	   l_insert := 0;
	  --dbms_output.put_line('2 no insert with previous line l_pair = 1' || b_bkt_start_date(j));

 ELSIF (j > 1 and b_publisher_id(j) = b_publisher_id(j-1) AND
 		b_publisher_site_id(j) = b_publisher_site_id(j-1) AND
 		b_customer_id(j) = b_customer_id(j-1) AND
 		b_customer_site_id(j) = b_customer_site_id(j-1) AND
 		b_supplier_id(j) = b_supplier_id(j-1) AND
 		b_supplier_site_id(j) = b_supplier_site_id(j-1) AND
 		b_item_id(j) = b_item_id(j-1) AND
 		b_bucket_index(j) <> b_bucket_index(j-1) and l_pair <> 1) THEN

   	   IF (b_order_type(j-1) = msc_x_netting_pkg.ORDER_FORECAST) THEN
   	      	l_total_demand := b_total_quantity(j-1);
   	      	l_tp_total_demand := b_tp_total_quantity(j-1);
   	      	l_posting_total_demand := b_posting_total_quantity(j-1);
   	      	l_total_supply := 0;
   	      	l_tp_total_supply := 0;
   	      	l_posting_total_supply := 0;
   	   ELSIF (b_order_type(j-1) = msc_x_netting_pkg.SUPPLY_COMMIT) THEN
   	   	l_total_demand := 0;
   	   	l_tp_total_demand := 0;
   	   	l_posting_total_demand := 0;
   	   	l_total_supply := b_total_quantity(j-1);
   	   	l_tp_total_supply := b_tp_total_quantity(j-1);
   	   	l_posting_total_supply := b_posting_total_quantity(j-1);
   	   END IF;

   	   l_pair := 0;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j-1);
   	   l_end_date := b_bkt_end_date(j-1);
   	   l_publisher_id := b_publisher_id(j-1);
   	   l_publisher_site_id := b_publisher_site_id(j-1);
   	   l_customer_id := b_customer_id(j-1);
   	   l_customer_site_id := b_customer_site_id(j-1);
   	   l_supplier_id := b_supplier_id(j-1);
   	   l_supplier_site_id := b_supplier_site_id(j-1);
   	   l_item_id := b_item_id(j-1);
   	   l_publisher_name := b_publisher_name(j-1);
   	   l_publisher_site_name := b_publisher_site_name(j-1);
   	   l_customer_name := b_customer_name(j-1);
   	   l_customer_site_name := b_customer_site_name(j-1);
   	   l_supplier_name := b_supplier_name(j-1);
   	   l_supplier_site_name := b_supplier_site_name(j-1);


 --dbms_output.put_line('3 not equal insert ' || b_bkt_start_date(j));
 ELSIF (j > 1 and l_pair = 1 ) and (b_publisher_id(j) <> b_publisher_id(j-1) OR
 		b_publisher_site_id(j) <> b_publisher_site_id(j-1) OR
 		b_customer_id(j) <> b_customer_id(j-1) OR
 		b_customer_site_id(j) <> b_customer_site_id(j-1) OR
 		b_supplier_id(j) <> b_supplier_id(j-1) OR
 		b_supplier_site_id(j) <> b_supplier_site_id(j-1) OR
 		b_item_id(j) <> b_item_id(j-1) ) THEN

	   l_pair := 0;
	   l_insert := 0;

 --dbms_output.put_line('4 diff no insert' ||  b_bkt_start_date(j) || ' ps ' || b_publisher_site_id(j) || ' cs ' || b_customer_site_id(j));
 ELSIF (j > 1 and l_pair <> 1 ) and (b_publisher_id(j) <> b_publisher_id(j-1) OR
 		b_publisher_site_id(j) <> b_publisher_site_id(j-1) OR
 		b_customer_id(j) <> b_customer_id(j-1) OR
 		b_customer_site_id(j) <> b_customer_site_id(j-1) OR
 		b_supplier_id(j) <> b_supplier_id(j-1) OR
 		b_supplier_site_id(j) <> b_supplier_site_id(j-1) OR
 		b_item_id(j) <> b_item_id(j-1) ) THEN

   	   IF (b_order_type(j-1) = msc_x_netting_pkg.ORDER_FORECAST) THEN
   	      	l_total_demand := b_total_quantity(j-1);
   	      	l_tp_total_demand := b_tp_total_quantity(j-1);
   	      	l_posting_total_demand := b_posting_total_quantity(j-1);
   	      	l_total_supply := 0;
   	      	l_tp_total_supply := 0;
   	      	l_posting_total_supply := 0;
   	   ELSIF (b_order_type(j-1) = msc_x_netting_pkg.SUPPLY_COMMIT) THEN
   	   	l_total_demand := 0;
   	   	l_tp_total_demand := 0;
   	   	l_posting_total_demand := 0;
   	   	l_total_supply := b_total_quantity(j-1);
   	   	l_tp_total_supply := b_tp_total_quantity(j-1);
   	   	l_posting_total_supply := b_posting_total_quantity(j-1);
   	   END IF;

   	   l_pair := 0;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j-1);
   	   l_end_date := b_bkt_end_date(j-1);
   	   l_publisher_id := b_publisher_id(j-1);
   	   l_publisher_site_id := b_publisher_site_id(j-1);
   	   l_customer_id := b_customer_id(j-1);
   	   l_customer_site_id := b_customer_site_id(j-1);
   	   l_supplier_id := b_supplier_id(j-1);
   	   l_supplier_site_id := b_supplier_site_id(j-1);
   	   l_item_id := b_item_id(j-1);
    	   l_publisher_name := b_publisher_name(j-1);
    	   l_publisher_site_name := b_publisher_site_name(j-1);
    	   l_customer_name := b_customer_name(j-1);
    	   l_customer_site_name := b_customer_site_name(j-1);
    	   l_supplier_name := b_supplier_name(j-1);
    	   l_supplier_site_name := b_supplier_site_name(j-1);


 --dbms_output.put_line('5 diff with insert' || b_bkt_start_date(j) || ' ps ' || b_publisher_site_id(j) || ' cs ' || b_customer_site_id(j));

 ELSIF (j = 1 AND b_bkt_start_date.COUNT = 1) THEN
       	   IF (b_order_type(j) = msc_x_netting_pkg.ORDER_FORECAST ) THEN
    	      	l_total_demand := b_total_quantity(j);
   	      	l_tp_total_demand := b_tp_total_quantity(j);
   	      	l_posting_total_demand := b_posting_total_quantity(j);
    	      	l_total_supply := 0;
   	      	l_tp_total_supply := 0;
   	      	l_posting_total_supply := 0;
   	   ELSIF (b_order_type(j) = msc_x_netting_pkg.SUPPLY_COMMIT)  THEN
   	      	l_total_demand := 0;
	      	l_tp_total_demand := 0;
   	   	l_posting_total_demand := 0;
      	   	l_total_supply := b_total_quantity(j);
   	   	l_tp_total_supply := b_tp_total_quantity(j);
   	   	l_posting_total_supply := b_posting_total_quantity(j);
   	   END IF;

   	   l_pair := 0;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j);
   	   l_end_date := b_bkt_end_date(j);
   	   l_publisher_id := b_publisher_id(j);
   	   l_publisher_site_id := b_publisher_site_id(j);
   	   l_customer_id := b_customer_id(j);
   	   l_customer_site_id := b_customer_site_id(j);
   	   l_supplier_id := b_supplier_id(j);
   	   l_supplier_site_id := b_supplier_site_id(j);
   	   l_item_id := b_item_id(j);
    	   l_publisher_name := b_publisher_name(j);
   	   l_publisher_site_name := b_publisher_site_name(j);
   	   l_customer_name := b_customer_name(j);
   	   l_customer_site_name := b_customer_site_name(j);
   	   l_supplier_name := b_supplier_name(j);
   	   l_supplier_site_name := b_supplier_site_name(j);

 --dbms_output.put_line('5 only one line' || b_bkt_start_date(j));
 END IF;

 FND_FILE.PUT_LINE(FND_FILE.LOG, '25:supply ' || l_total_supply || ' demand ' || l_total_demand || ' date ' ||
   	l_start_date || 'cutoff ' || l_cutoff_ref_num );

--dbms_output.put_line( '25:supply ' || l_total_supply || ' demand ' || l_total_demand || ' date ' ||
--   	l_start_date || 'cutoff ' || l_cutoff_ref_num  || ' pair ' || l_pair);
     	IF (((j > 1 and l_insert = 1) OR (b_bucket_index.COUNT = 1)) and
     	    ((l_total_supply - l_tp_total_demand)  > (l_tp_total_demand * l_threshold2/100)))
     	    and (greatest(b_refresh_number(j),b_refresh_number(j-1)) > p_refresh_number)
     	    THEN


         	--======================================================
        	 -- clean up  the opposite exception and its complement
         	--======================================================
      		msc_x_netting_pkg.add_to_delete_tbl(
         	l_publisher_id,			--b_publisher_id(j),
         	l_publisher_site_id,		--b_publisher_site_id(j),
         	l_customer_id,			--b_customer_id(j),
         	l_customer_site_id,		--b_customer_site_id(j),
         	null,
         	null,
         	l_item_id,			--b_item_id(j),
         	msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
         	msc_x_netting_pkg.G_EXCEP5,
         	null,
         	null,
         	l_start_date,
         	l_end_date,
         	t_company_list,
         	t_company_site_list,
         	t_customer_list,
         	t_customer_site_list,
         	t_supplier_list,
         	t_supplier_site_list,
         	t_item_list,
         	t_group_list,
         	t_type_list,
         	t_trxid1_list,
         	t_trxid2_list,
         	t_date1_list,
         	t_date2_list);


      		l_exception_type := msc_x_netting_pkg.G_EXCEP25;--Cust order fcst < your allocated supply
      		l_exception_group := msc_x_netting_pkg.G_MATERIAL_EXCESS;
      		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

      		msc_x_netting_pkg.add_to_exception_tbl(
      			l_publisher_id,			--b_publisher_id(j),
         		l_publisher_name,		--b_publisher_name(j),
         		l_publisher_site_id,		--b_publisher_site_id(j),
         		l_publisher_site_name,		--b_publisher_site_name(j),
         		l_item_id,			--b_item_id(j),
         		l_item_name,			--b_item_name(j),
         		l_item_desc,
         		l_exception_type,
         		l_exception_type_name,
         		l_exception_group,
         		l_exception_group_name,
         		null,       			--trx_id1,
         		null,                   	--trx_id2,
         		l_customer_id,			--b_customer_id(j),
         		l_customer_name,		--b_customer_name(j),
         		l_customer_site_id,		--b_customer_site_id(j),
         		l_customer_site_name,		--b_customer_site_name(j),
         		l_customer_item_name,		--b_customer_item_name(j),
         		null,                   	--l_supplier_id
         		null,
         		null,                   	--l_supplier_site_id
         		null,
         		l_supplier_item_name,		--b_supplier_item_name(j),
         		l_total_supply,
         		l_tp_total_demand,
         		null,
         		l_threshold2,
         		null,       --lead time
         		null,       --item min
         		null,       --item_max
         		null,       --l_order_number,
         		null,       --l_release_number,
         		null,       --l_line_number,
         		null,                   --l_end_order_number,
         		null,                   --l_end_order_rel_number,
         		null,                   --l_end_order_line_number,
         		null,			--b_so_creation_date(j),
         		null,			--b_po_creation_date(j),
         		l_start_date,
         		l_end_date,
         		null,			--ship_date(j),
         		null,			--ship_date(j),
         		null,
         		l_exception_basis,
         		a_company_id,
         		a_company_name,
         		a_company_site_id,
         		a_company_site_name,
         		a_item_id,
         		a_item_name,
         		a_item_desc,
         		a_exception_type,
         		a_exception_type_name,
         		a_exception_group,
         		a_exception_group_name,
         		a_trx_id1,
         		a_trx_id2,
         		a_customer_id,
         		a_customer_name,
         		a_customer_site_id,
         		a_customer_site_name,
         		a_customer_item_name,
         		a_supplier_id,
         		a_supplier_name,
         		a_supplier_site_id,
         		a_supplier_site_name,
         		a_supplier_item_name,
         		a_number1,
         		a_number2,
         		a_number3,
         		a_threshold,
         		a_lead_time,
         		a_item_min_qty,
         		a_item_max_qty,
         		a_order_number,
         		a_release_number,
         		a_line_number,
         		a_end_order_number,
         		a_end_order_rel_number,
         		a_end_order_line_number,
         		a_creation_date,
         		a_tp_creation_date,
         		a_date1,
         		a_date2,
         		a_date3,
         		a_date4,
         		a_date5,
         		a_exception_basis);
                        l_inserted_record := l_inserted_record + 1;


      		    END IF;   --compute exception

/*------------------------------------------------------------------
 Loop for the last record if require to insert
 ------------------------------------------------------------------*/
IF ( j > 1 and l_pair = 0 and j = b_bucket_index.COUNT) THEN
 	   l_insert := 1;
 	   l_start_date := b_bkt_start_date(j);
   	   l_end_date := b_bkt_end_date(j);
   	   l_publisher_id := b_publisher_id(j);
   	   l_publisher_site_id := b_publisher_site_id(j);
   	   l_customer_id := b_customer_id(j);
   	   l_customer_site_id := b_customer_site_id(j);
   	   l_supplier_id := b_supplier_id(j);
   	   l_supplier_site_id := b_supplier_site_id(j);
   	   l_item_id := b_item_id(j);
     	   l_publisher_name := b_publisher_name(j);
   	   l_publisher_site_name := b_publisher_site_name(j);
   	   l_customer_name := b_customer_name(j);
   	   l_customer_site_name := b_customer_site_name(j);
   	   l_supplier_name := b_supplier_name(j);
   	   l_supplier_site_name := b_supplier_site_name(j);

    	   IF (b_order_type(j) = msc_x_netting_pkg.ORDER_FORECAST) THEN
    	      	l_total_demand := b_total_quantity(j);
    	      	l_tp_total_demand := b_tp_total_quantity(j);
    	      	l_posting_total_demand := b_posting_total_quantity(j);
    	      	l_total_supply := 0;
    	      	l_tp_total_supply := 0;
    	      	l_posting_total_supply := 0;
    	   ELSIF (b_order_type(j) = msc_x_netting_pkg.SUPPLY_COMMIT) THEN
    	   	l_total_demand := 0;
    	   	l_tp_total_demand := 0;
    	   	l_posting_total_demand := 0;
    	   	l_total_supply := b_total_quantity(j);
    	   	l_tp_total_supply := b_tp_total_quantity(j);
    	   	l_posting_total_supply := b_posting_total_quantity(j);
   	   END IF;
    --dbms_output.put_line(' loop for last record  ' );

     	   IF  ((l_total_supply - l_tp_total_demand)  > (l_tp_total_demand * l_threshold2/100))
     	   and (b_refresh_number(j) > p_refresh_number)
     	   THEN


      		l_exception_type := msc_x_netting_pkg.G_EXCEP25;--Cust order fcst < your allocated supply
      		l_exception_group := msc_x_netting_pkg.G_MATERIAL_EXCESS;
      		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);


      		msc_x_netting_pkg.add_to_exception_tbl(
      			l_publisher_id,			--b_publisher_id(j),
         		l_publisher_name,		--b_publisher_name(j),
         		l_publisher_site_id,		--b_publisher_site_id(j),
         		l_publisher_site_name,		-- b_publisher_site_name(j),
         		l_item_id,			--b_item_id(j),
         		l_item_name,			--b_item_name(j),
         		l_item_desc,
         		l_exception_type,
         		l_exception_type_name,
         		l_exception_group,
         		l_exception_group_name,
         		null,       			--trx_id1,
         		null,                   	--trx_id2,
         		l_customer_id,			--b_customer_id(j),
         		l_customer_name,		--b_customer_name(j),
         		l_customer_site_id,		--b_customer_site_id(j),
         		l_customer_site_name,		--b_customer_site_name(j),
         		l_customer_item_name,		--b_customer_item_name(j),
         		null,                   	--l_supplier_id
         		null,
         		null,                   	--l_supplier_site_id
         		null,
         		l_supplier_item_name,		--b_supplier_item_name(j),
         		l_total_supply,
         		l_tp_total_demand,
         		null,
         		l_threshold2,
         		null,       --lead time
         		null,       --item min
         		null,       --item_max
         		null,       --l_order_number,
         		null,       --l_release_number,
         		null,       --l_line_number,
         		null,                   --l_end_order_number,
         		null,                   --l_end_order_rel_number,
         		null,                   --l_end_order_line_number,
         		null,			--b_so_creation_date(j),
         		null,			--b_po_creation_date(j),
         		l_start_date,
         		l_end_date,
         		null,			--ship_date(j),
         		null,			--ship_date(j),
         		null,
         		l_exception_basis,
         		a_company_id,
         		a_company_name,
         		a_company_site_id,
         		a_company_site_name,
         		a_item_id,
         		a_item_name,
         		a_item_desc,
         		a_exception_type,
         		a_exception_type_name,
         		a_exception_group,
         		a_exception_group_name,
         		a_trx_id1,
         		a_trx_id2,
         		a_customer_id,
         		a_customer_name,
         		a_customer_site_id,
         		a_customer_site_name,
         		a_customer_item_name,
         		a_supplier_id,
         		a_supplier_name,
         		a_supplier_site_id,
         		a_supplier_site_name,
         		a_supplier_item_name,
         		a_number1,
         		a_number2,
         		a_number3,
         		a_threshold,
         		a_lead_time,
         		a_item_min_qty,
         		a_item_max_qty,
         		a_order_number,
         		a_release_number,
         		a_line_number,
         		a_end_order_number,
         		a_end_order_rel_number,
         		a_end_order_line_number,
         		a_creation_date,
         		a_tp_creation_date,
         		a_date1,
         		a_date2,
         		a_date3,
         		a_date4,
         		a_date5,
         		a_exception_basis);
                        l_inserted_record := l_inserted_record + 1;


      		    END IF;   	--compute exception
      		    END IF;	-- m loop to the last record
               --END LOOP;
          --end if;
  -- END IF;		--sum
end loop;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' || msc_x_netting_pkg.get_message_type(25) ||
   ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

--=======================================================================================
--for Supplier supply planning (exception 7.2)
--======================================================================================
l_total_supply := 0;
l_total_demand := 0;
l_pair := 0;
l_insert := 0;

--dbms_output.put_line('Exception 26');

 open exception_26(p_refresh_number);
     fetch exception_26 BULK COLLECT INTO
     	b_publisher_id,
    	b_publisher_site_id,
    	b_customer_id,
    	b_customer_site_id,
    	b_supplier_id,
    	b_supplier_site_id,
    	b_item_id,
     	b_bucket_index,
     	b_bkt_start_date,
    	b_bkt_end_date,
     	b_order_type,
   	b_publisher_name,
   	b_publisher_site_name,
   	b_customer_name,
   	b_customer_site_name,
   	b_supplier_name,
   	b_supplier_site_name,
   	b_item_name,
	b_item_desc,
	b_supplier_item_name,
	b_customer_item_name,
     	b_total_quantity,
 	b_tp_total_quantity,
  	b_posting_total_quantity,
 	b_refresh_number;

 CLOSE exception_26;

IF (b_item_id is not null and b_item_id.COUNT > 0) THEN
FOR j in 1..b_item_id.COUNT
LOOP


   IF (j = 1 or b_publisher_id(j) <> b_publisher_id(j-1) OR
   		b_publisher_site_id(j) <> b_publisher_site_id(j-1) OR
   		b_customer_id(j) <> b_customer_id(j-1) OR
   		b_customer_site_id(j) <> b_customer_site_id(j-1) OR
   		b_supplier_id(j) <> b_supplier_id(j-1) OR
   		b_supplier_site_id(j) <> b_supplier_site_id(j-1) OR
 		b_item_id(j) <> b_item_id(j-1)) THEN

      --======================================================
      -- archive old exception and its complement
      --======================================================
   	msc_x_netting_pkg.add_to_delete_tbl(
      		b_publisher_id(j),
      		b_publisher_site_id(j),
      		null,
      		null,
      		b_supplier_id(j),
      		b_supplier_site_id(j),
      		b_item_id(j),
      		msc_x_netting_pkg.G_MATERIAL_EXCESS,
      		msc_x_netting_pkg.G_EXCEP26,
      		null,
      		null,
      		null,
      		null,
      		t_company_list,
      		t_company_site_list,
      		t_customer_list,
      		t_customer_site_list,
      		t_supplier_list,
      		t_supplier_site_list,
      		t_item_list,
      		t_group_list,
      		t_type_list,
      		t_trxid1_list,
      		t_trxid2_list,
      		t_date1_list,
      		t_date2_list);


        l_threshold2 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP26,
                     	b_publisher_id(j),
                  	b_publisher_site_id(j),
                  	b_item_id(j),
               		b_supplier_id(j),
               		b_supplier_site_id(j),
               		null,
               		null,
                     	null);


     	--------------------------------------------------------------------------
     	-- get the shipping control
     	---------------------------------------------------------------------------
     	l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                       b_publisher_site_name(j),
                                       b_supplier_name(j),
                                       b_supplier_site_name(j));

     	l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

   END IF;

IF (j > 1 and b_publisher_id(j) = b_publisher_id(j-1) AND
 		b_publisher_site_id(j) = b_publisher_site_id(j-1) AND
 		b_customer_id(j) = b_customer_id(j-1) AND
 		b_customer_site_id(j) = b_customer_site_id(j-1) AND
 		b_supplier_id(j) = b_supplier_id(j-1) AND
 		b_supplier_site_id(j) = b_supplier_site_id(j-1) AND
 		b_item_id(j) = b_item_id(j-1) and
 		b_bucket_index(j) = b_bucket_index(j-1) and
   		b_bkt_start_date(j) = b_bkt_start_date(j-1)) THEN

   	   IF (b_order_type(j-1) = msc_x_netting_pkg.ORDER_FORECAST ) THEN
   	      	l_total_demand := b_total_quantity(j-1);
   	      	l_tp_total_demand := b_tp_total_quantity(j-1);
   	      	l_posting_total_demand := b_posting_total_quantity(j-1);
   	   ELSIF (b_order_type(j-1)= msc_x_netting_pkg.SUPPLY_COMMIT) THEN
   	   	l_total_supply := b_total_quantity(j-1);
   	   	l_tp_total_supply := b_tp_total_quantity(j-1);
   	   	l_posting_total_supply := b_posting_total_quantity(j-1);
   	   END IF;

   	   IF (b_order_type(j) = msc_x_netting_pkg.ORDER_FORECAST) THEN
    	      	l_total_demand := b_total_quantity(j);
   	      	l_tp_total_demand := b_tp_total_quantity(j);
   	      	l_posting_total_demand := b_posting_total_quantity(j);

   	   ELSIF (b_order_type(j) = msc_x_netting_pkg.SUPPLY_COMMIT)  THEN
      	   	l_total_supply := b_total_quantity(j);
   	   	l_tp_total_supply := b_tp_total_quantity(j);
   	   	l_posting_total_supply := b_posting_total_quantity(j);
   	   END IF;

   	   l_pair := 1;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j-1);
   	   l_end_date := b_bkt_end_date(j-1);
   	   l_publisher_id := b_publisher_id(j-1);
   	   l_publisher_site_id := b_publisher_site_id(j-1);
   	   l_customer_id := b_customer_id(j-1);
   	   l_customer_site_id := b_customer_site_id(j-1);
   	   l_supplier_id := b_supplier_id(j-1);
   	   l_supplier_site_id := b_supplier_site_id(j-1);
   	   l_item_id := b_item_id(j-1);
   	   l_publisher_name := b_publisher_name(j-1);
   	   l_publisher_site_name := b_publisher_site_name(j-1);
   	   l_customer_name := b_customer_name(j-1);
   	   l_customer_site_name := b_customer_site_name(j-1);
   	   l_supplier_name := b_supplier_name(j-1);
   	   l_supplier_site_name := b_supplier_site_name(j-1);

 ELSIF (j > 1 and b_publisher_id(j) = b_publisher_id(j-1) AND
 		b_publisher_site_id(j) = b_publisher_site_id(j-1) AND
 		b_customer_id(j) = b_customer_id(j-1) AND
 		b_customer_site_id(j) = b_customer_site_id(j-1) AND
 		b_supplier_id(j) = b_supplier_id(j-1) AND
 		b_supplier_site_id(j) = b_supplier_site_id(j-1) AND
 		b_item_id(j) = b_item_id(j-1) AND
 		b_bucket_index(j) <> b_bucket_index(j-1) and l_pair = 1) THEN
	   l_pair := 0;
	   l_insert := 0;

 ELSIF (j > 1 and b_publisher_id(j) = b_publisher_id(j-1) AND
 		b_publisher_site_id(j) = b_publisher_site_id(j-1) AND
 		b_customer_id(j) = b_customer_id(j-1) AND
 		b_customer_site_id(j) = b_customer_site_id(j-1) AND
 		b_supplier_id(j) = b_supplier_id(j-1) AND
 		b_supplier_site_id(j) = b_supplier_site_id(j-1) AND
 		b_item_id(j) = b_item_id(j-1) AND
 		b_bucket_index(j) <> b_bucket_index(j-1) and l_pair <> 1) THEN

   	   IF (b_order_type(j-1) = msc_x_netting_pkg.ORDER_FORECAST) THEN
   	      	l_total_demand := b_total_quantity(j-1);
   	      	l_tp_total_demand := b_tp_total_quantity(j-1);
   	      	l_posting_total_demand := b_posting_total_quantity(j-1);
   	      	l_total_supply := 0;
   	      	l_tp_total_supply := 0;
   	      	l_posting_total_supply := 0;
   	   ELSIF (b_order_type(j-1) = msc_x_netting_pkg.SUPPLY_COMMIT) THEN
   	   	l_total_demand := 0;
   	   	l_tp_total_demand := 0;
   	   	l_posting_total_demand := 0;
   	   	l_total_supply := b_total_quantity(j-1);
   	   	l_tp_total_supply := b_tp_total_quantity(j-1);
   	   	l_posting_total_supply := b_posting_total_quantity(j-1);
   	   END IF;
   	   l_pair := 0;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j-1);
   	   l_end_date := b_bkt_end_date(j-1);
    	   l_publisher_id := b_publisher_id(j-1);
   	   l_publisher_site_id := b_publisher_site_id(j-1);
   	   l_customer_id := b_customer_id(j-1);
   	   l_customer_site_id := b_customer_site_id(j-1);
   	   l_supplier_id := b_supplier_id(j-1);
   	   l_supplier_site_id := b_supplier_site_id(j-1);
   	   l_item_id := b_item_id(j-1);
    	   l_publisher_name := b_publisher_name(j-1);
   	   l_publisher_site_name := b_publisher_site_name(j-1);
   	   l_customer_name := b_customer_name(j-1);
   	   l_customer_site_name := b_customer_site_name(j-1);
   	   l_supplier_name := b_supplier_name(j-1);
   	   l_supplier_site_name := b_supplier_site_name(j-1);

 ELSIF (j > 1 and l_pair = 1 ) and (b_publisher_id(j) <> b_publisher_id(j-1) OR
 		b_publisher_site_id(j) <> b_publisher_site_id(j-1) OR
 		b_customer_id(j) <> b_customer_id(j-1) OR
 		b_customer_site_id(j) <> b_customer_site_id(j-1) OR
 		b_supplier_id(j) <> b_supplier_id(j-1) OR
 		b_supplier_site_id(j) <> b_supplier_site_id(j-1) OR
 		b_item_id(j) <> b_item_id(j-1)) THEN
 	   l_pair := 0;
	   l_insert := 0;

 ELSIF (j > 1 and l_pair <> 1) and (b_publisher_id(j) <> b_publisher_id(j-1) OR
  		b_publisher_site_id(j) <> b_publisher_site_id(j-1) OR
  		b_customer_id(j) <> b_customer_id(j-1) OR
  		b_customer_site_id(j) <> b_customer_site_id(j-1) OR
  		b_supplier_id(j) <> b_supplier_id(j-1) OR
  		b_supplier_site_id(j) <> b_supplier_site_id(j-1) OR
  		b_item_id(j) <> b_item_id(j-1)) THEN

    	   IF (b_order_type(j-1) = msc_x_netting_pkg.ORDER_FORECAST) THEN
    	      	l_total_demand := b_total_quantity(j-1);
    	      	l_tp_total_demand := b_tp_total_quantity(j-1);
    	      	l_posting_total_demand := b_posting_total_quantity(j-1);
    	      	l_total_supply := 0;
    	      	l_tp_total_supply := 0;
    	      	l_posting_total_supply := 0;
    	   ELSIF (b_order_type(j-1) = msc_x_netting_pkg.SUPPLY_COMMIT) THEN
    	   	l_total_demand := 0;
    	   	l_tp_total_demand := 0;
    	   	l_posting_total_demand := 0;
    	   	l_total_supply := b_total_quantity(j-1);
    	   	l_tp_total_supply := b_tp_total_quantity(j-1);
    	   	l_posting_total_supply := b_posting_total_quantity(j-1);
    	   END IF;
    	   l_pair := 0;
    	   l_insert := 1;
    	   l_start_date := b_bkt_start_date(j-1);
   	   l_end_date := b_bkt_end_date(j-1);
    	   l_publisher_id := b_publisher_id(j-1);
   	   l_publisher_site_id := b_publisher_site_id(j-1);
   	   l_customer_id := b_customer_id(j-1);
   	   l_customer_site_id := b_customer_site_id(j-1);
   	   l_supplier_id := b_supplier_id(j-1);
   	   l_supplier_site_id := b_supplier_site_id(j-1);
   	   l_item_id := b_item_id(j-1);
    	   l_publisher_name := b_publisher_name(j-1);
   	   l_publisher_site_name := b_publisher_site_name(j-1);
   	   l_customer_name := b_customer_name(j-1);
   	   l_customer_site_name := b_customer_site_name(j-1);
   	   l_supplier_name := b_supplier_name(j-1);
   	   l_supplier_site_name := b_supplier_site_name(j-1);

 ELSIF (j = 1 and b_bkt_start_date.COUNT = 1) THEN

    	   IF (b_order_type(j) = msc_x_netting_pkg.ORDER_FORECAST ) THEN
    	      	l_total_demand := b_total_quantity(j);
   	      	l_tp_total_demand := b_tp_total_quantity(j);
   	      	l_posting_total_demand := b_posting_total_quantity(j);
    	      	l_total_supply := 0;
   	      	l_tp_total_supply := 0;
   	      	l_posting_total_supply := 0;
   	   ELSIF (b_order_type(j) = msc_x_netting_pkg.SUPPLY_COMMIT)  THEN
   	      	l_total_demand := 0;
	      	l_tp_total_demand := 0;
   	   	l_posting_total_demand := 0;
      	   	l_total_supply := b_total_quantity(j);
   	   	l_tp_total_supply := b_tp_total_quantity(j);
   	   	l_posting_total_supply := b_posting_total_quantity(j);
   	   END IF;

   	   l_pair := 0;
   	   l_insert := 1;
   	   l_start_date := b_bkt_start_date(j);
   	   l_end_date := b_bkt_end_date(j);
    	   l_publisher_id := b_publisher_id(j);
   	   l_publisher_site_id := b_publisher_site_id(j);
   	   l_customer_id := b_customer_id(j);
   	   l_customer_site_id := b_customer_site_id(j);
   	   l_supplier_id := b_supplier_id(j);
   	   l_supplier_site_id := b_supplier_site_id(j);
   	   l_item_id := b_item_id(j);
    	   l_publisher_name := b_publisher_name(j);
   	   l_publisher_site_name := b_publisher_site_name(j);
   	   l_customer_name := b_customer_name(j);
   	   l_customer_site_name := b_customer_site_name(j);
   	   l_supplier_name := b_supplier_name(j);
   	   l_supplier_site_name := b_supplier_site_name(j);

 END IF;


 FND_FILE.PUT_LINE(FND_FILE.LOG, '26:supply ' || l_total_supply || ' demand ' || l_total_demand ||
  		' date ' || l_start_date || 'cutoff ' || l_cutoff_ref_num);


     IF (((j > 1 and l_insert = 1 )  OR (b_bucket_index.COUNT = 1)) and
     	((l_tp_total_supply - l_total_demand) > (l_total_demand * l_threshold2/100)))
     	and (greatest(b_refresh_number(j),b_refresh_number(j-1)) > p_refresh_number)
     	THEN

      --------------------------------------------------------
      -- clean up the opposite exception and its complement
      --------------------------------------------------------
      msc_x_netting_pkg.add_to_delete_tbl(
            l_publisher_id,			--b_publisher_id(j),
            l_publisher_site_id,		--b_publisher_site_id(j),
            null,
            null,
            l_supplier_id,			--b_supplier_id(j),
            l_supplier_site_id,			--b_supplier_site_id(j),
            l_item_id,				--b_item_id(j),
            msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
            msc_x_netting_pkg.G_EXCEP6,
            null,
            null,
            l_start_date,
            l_end_date,
            t_company_list,
            t_company_site_list,
            t_customer_list,
            t_customer_site_list,
            t_supplier_list,
            t_supplier_site_list,
            t_item_list,
            t_group_list,
            t_type_list,
            t_trxid1_list,
            t_trxid2_list,
            t_date1_list,
            t_date2_list);


      --if plan_type is SP then detected exception 7.2
         --dbms_output.put_line('dem ' || l_total_demand || 'sup ' || l_tp_total_supply);
      l_exception_type := msc_x_netting_pkg.G_EXCEP26;
      l_exception_group := msc_x_netting_pkg.G_MATERIAL_EXCESS;
      l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

      msc_x_netting_pkg.add_to_exception_tbl(
      			l_publisher_id,			--b_publisher_id(j),
            		l_publisher_name,		--b_publisher_name(j),
                      	l_publisher_site_id,		--b_publisher_site_id(j),
                      	l_publisher_site_name,		--b_publisher_site_name(j),
                        l_item_id,			--b_item_id(j),
                        l_item_name,		--b_item_name(j),
                        l_item_desc,		--b_item_desc(j),
                      l_exception_type,
                      l_exception_type_name,
                      l_exception_group,
                      l_exception_group_name,
                      null,                   --trx_id1,
                      null,                   --trx_id2,
                      null,         --l_customer_id,
                      null,
                      null,         --l_customer_site_id,
                      null,
                      l_customer_item_name,	--b_customer_item_name(j),
                      l_supplier_id,		--b_supplier_id(j),
                      l_supplier_name,		--b_supplier_name(j),
                      l_supplier_site_id,	--b_supplier_site_id(j),
                      l_supplier_site_name,	--b_supplier_site_name(j),
                      l_supplier_item_name,	--b_supplier_item_name(j),
                      l_tp_total_supply,
                      l_total_demand,
                      null,
                      l_threshold2,
                      null,         --lead time
            	      null,       --item min
            	      null,       --item_max
                      null,                   --l_order_number,
                      null,                   --l_release_number,
                      null,                   --l_line_number,
                      null,                   --l_end_order_number,
                      null,                   --l_end_order_rel_number,
                      null,                   --l_end_order_line_number,
               	      null,			--b_so_creation_date(j),
                      null,			--b_po_creation_date(j),
                      l_start_date,
                      l_end_date,
                      null,			--ship_date(j),
               	      null,			--ship_date(j),
                      null,
               	      l_exception_basis,
            	a_company_id,
            	a_company_name,
            	a_company_site_id,
            	a_company_site_name,
            	a_item_id,
            	a_item_name,
            	a_item_desc,
            	a_exception_type,
            	a_exception_type_name,
            	a_exception_group,
            	a_exception_group_name,
            	a_trx_id1,
            	a_trx_id2,
            	a_customer_id,
            	a_customer_name,
            	a_customer_site_id,
            	a_customer_site_name,
            	a_customer_item_name,
            	a_supplier_id,
            	a_supplier_name,
            	a_supplier_site_id,
            	a_supplier_site_name,
            	a_supplier_item_name,
            	a_number1,
            	a_number2,
            	a_number3,
            	a_threshold,
            	a_lead_time,
            	a_item_min_qty,
            	a_item_max_qty,
            	a_order_number,
            	a_release_number,
            	a_line_number,
            	a_end_order_number,
            	a_end_order_rel_number,
            	a_end_order_line_number,
            	a_creation_date,
            	a_tp_creation_date,
            	a_date1,
            	a_date2,
            	a_date3,
            	a_date4,
            	a_date5,
            	a_exception_basis);
                l_inserted_record := l_inserted_record + 1;

        	end if;  	--compute exception
   	/*------------------------------------------------------------------
 	Loop for the last record if require to insert
 	------------------------------------------------------------------*/
 	IF ( j > 1 and l_pair = 0 and j = b_bucket_index.COUNT) THEN
	 	   l_pair := 0;
	 	   l_insert := 1;
	 	   l_start_date := b_bkt_start_date(j);
	   	   l_end_date := b_bkt_end_date(j);
	     	   l_publisher_id := b_publisher_id(j);
	   	   l_publisher_site_id := b_publisher_site_id(j);
	   	   l_customer_id := b_customer_id(j);
	   	   l_customer_site_id := b_customer_site_id(j);
	   	   l_supplier_id := b_supplier_id(j);
	   	   l_supplier_site_id := b_supplier_site_id(j);
	   	   l_item_id := b_item_id(j);
    	  	   l_publisher_name := b_publisher_name(j);
   	   	   l_publisher_site_name := b_publisher_site_name(j);
   	   	   l_customer_name := b_customer_name(j);
   	   	   l_customer_site_name := b_customer_site_name(j);
   	   	   l_supplier_name := b_supplier_name(j);
   	   	  l_supplier_site_name := b_supplier_site_name(j);

	    	   IF (b_order_type(j) = msc_x_netting_pkg.ORDER_FORECAST) THEN
	    	      	l_total_demand := b_total_quantity(j);
	    	      	l_tp_total_demand := b_tp_total_quantity(j);
	    	      	l_posting_total_demand := b_posting_total_quantity(j);
	    	      	l_total_supply := 0;
	    	      	l_tp_total_supply := 0;
	    	      	l_posting_total_supply := 0;
	    	   ELSIF (b_order_type(j) = msc_x_netting_pkg.SUPPLY_COMMIT) THEN
	    	   	l_total_demand := 0;
	    	   	l_tp_total_demand := 0;
	    	   	l_posting_total_demand := 0;
	    	   	l_total_supply := b_total_quantity(j);
	    	   	l_tp_total_supply := b_tp_total_quantity(j);
	    	   	l_posting_total_supply := b_posting_total_quantity(j);
   	   END IF;

     	   IF ((l_tp_total_supply - l_total_demand) > (l_total_demand * l_threshold2/100))
     	   and (b_refresh_number(j) > p_refresh_number)
     	   THEN


      	--if plan_type is SP then detected exception 7.2
         --dbms_output.put_line('dem ' || l_total_demand || 'sup ' || l_tp_total_supply);
      	l_exception_type := msc_x_netting_pkg.G_EXCEP26;
      	l_exception_group := msc_x_netting_pkg.G_MATERIAL_EXCESS;
      	l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      	l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

      	msc_x_netting_pkg.add_to_exception_tbl(
      			l_publisher_id,			--b_publisher_id(j),
            		l_publisher_name,		--b_publisher_name(j),
                      	l_publisher_site_id,		--b_publisher_site_id(j),
                      	l_publisher_site_name,		--b_publisher_site_name(j),
                        l_item_id,			--b_item_id(j),
                        l_item_name,		--b_item_name(j),
                        l_item_desc,		--b_item_desc(j),
                      l_exception_type,
                      l_exception_type_name,
                      l_exception_group,
                      l_exception_group_name,
                      null,                   --trx_id1,
                      null,                   --trx_id2,
                      null,         --l_customer_id,
                      null,
                      null,         --l_customer_site_id,
                      null,
                      l_customer_item_name,	--b_customer_item_name(j),
                      l_supplier_id,		--b_supplier_id(j),
                      l_supplier_name,		--b_supplier_name(j),
                      l_supplier_site_id,	--b_supplier_site_id(j),
                      l_supplier_site_name,	--b_supplier_site_name(j),
                      l_supplier_item_name,	--b_supplier_item_name(j),
                      l_tp_total_supply,
                      l_total_demand,
                      null,
                      l_threshold2,
                      null,         --lead time
            	      null,       --item min
            	      null,       --item_max
                      null,                   --l_order_number,
                      null,                   --l_release_number,
                      null,                   --l_line_number,
                      null,                   --l_end_order_number,
                      null,                   --l_end_order_rel_number,
                      null,                   --l_end_order_line_number,
               	      null,			--b_so_creation_date(j),
                      null,			--b_po_creation_date(j),
                      l_start_date,
                      l_end_date,
                      null,			--ship_date(j),
               	      null,			--ship_date(j),
                      null,
               	      l_exception_basis,
            	a_company_id,
            	a_company_name,
            	a_company_site_id,
            	a_company_site_name,
            	a_item_id,
            	a_item_name,
            	a_item_desc,
            	a_exception_type,
            	a_exception_type_name,
            	a_exception_group,
            	a_exception_group_name,
            	a_trx_id1,
            	a_trx_id2,
            	a_customer_id,
            	a_customer_name,
            	a_customer_site_id,
            	a_customer_site_name,
            	a_customer_item_name,
            	a_supplier_id,
            	a_supplier_name,
            	a_supplier_site_id,
            	a_supplier_site_name,
            	a_supplier_item_name,
            	a_number1,
            	a_number2,
            	a_number3,
            	a_threshold,
            	a_lead_time,
            	a_item_min_qty,
            	a_item_max_qty,
            	a_order_number,
            	a_release_number,
            	a_line_number,
            	a_end_order_number,
            	a_end_order_rel_number,
            	a_end_order_line_number,
            	a_creation_date,
            	a_tp_creation_date,
            	a_date1,
            	a_date2,
            	a_date3,
            	a_date4,
            	a_date5,
            	a_exception_basis);
                l_inserted_record := l_inserted_record + 1;

        	end if;  	--compute exception

           end if;		-- end of the last record of the loop
       -- END LOOP;
       --END IF;
    --END IF;	--sum
END LOOP;
END IF;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(26) ||
   ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));


--=================================================================================

/* reset the trxid */
l_generate_complement := null;

--dbms_output.put_line('Exception  27');  --supplier centric
open exception_27 (p_refresh_number);
   fetch exception_27 BULK COLLECT INTO
            	b_trx_id1,
            	b_publisher_id,
            	b_publisher_name,
            	b_publisher_site_id,
            	b_publisher_site_name,
            	b_item_id,
            	b_item_name,
            	b_item_desc,
            	b_supplier_item_name,
              	b_supplier_item_desc,
              	b_so_key_date,
          	b_so_ship_date,
             	b_so_receipt_date,
                b_posting_so_qty,
             	b_so_qty,
             	b_tp_so_qty,
              	b_end_order_number,
              	b_end_order_rel_number,
             	b_end_order_line_number,
             	b_customer_id,
             	b_customer_name,
               	b_customer_site_id,
               	b_customer_site_name,
               	b_customer_item_name,
              	b_customer_item_desc,
               	b_so_creation_date,
             	b_so_last_refnum,
             	b_trx_id2,
             	b_po_key_date,
             	b_po_ship_date,
            	b_po_receipt_date,
                b_posting_po_qty,
                b_po_qty,
                b_tp_po_qty,
                b_order_number,
                b_release_number,
                b_line_number,
                b_supplier_id,    --owning com
                b_supplier_name,
                b_supplier_site_id,  --owning org
                b_supplier_site_name,
                b_po_creation_date,
                b_po_last_refnum;
 CLOSE exception_27;

 IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
 FOR j in 1..b_trx_id1.COUNT
 LOOP
   --dbms_output.put_line('-----Exception27: Trx id 1 = ' || b_trx_id1(j));
   --dbms_output.put_line('---------------  Trx id 2 = ' || b_trx_id2(j));
      --======================================================
      -- archive old exception and its complement
      --======================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      b_customer_id(j),
      b_customer_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_EXCESS,
      msc_x_netting_pkg.G_EXCEP27,
      b_trx_id1(j),
      b_trx_id2(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);


   msc_x_netting_pkg.add_to_delete_tbl(
      b_customer_id(j),
      b_customer_site_id(j),
      null,
      null,
      b_publisher_id(j),
      b_publisher_site_id(j),
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_EXCESS,
      msc_x_netting_pkg.G_EXCEP28,
      b_trx_id2(j),
      b_trx_id1(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);


   l_threshold2 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP27,
                         	b_publisher_id(j),
                              	b_publisher_site_id(j),
                              	b_item_id(j),
                               	null,
                               	null,
                              	b_customer_id(j),
                           	b_customer_site_id(j),
                              	b_so_key_date(j));

   l_total_qty := msc_x_netting_pkg.get_total_qty(b_order_number(j),
                               	b_release_number(j),
                               	b_line_number(j),
               			b_publisher_id(j),
               			b_publisher_site_id(j),
               			b_customer_id(j),
               			b_customer_site_id(j),
                             	b_item_id(j));

    IF (l_total_qty > b_po_qty(j) + (l_threshold2*b_po_qty(j)/100) ) then
      --======================================================
         -- Clean up the opposite exception and its complement
         --======================================================

         msc_x_netting_pkg.add_to_delete_tbl(
         b_publisher_id(j),
         b_publisher_site_id(j),
         b_customer_id(j),
         b_customer_site_id(j),
         null,
         null,
         b_item_id(j),
         msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
         msc_x_netting_pkg.G_EXCEP7,
         b_trx_id1(j),
         b_trx_id2(j),
         null,
         null,
         t_company_list,
         t_company_site_list,
         t_customer_list,
         t_customer_site_list,
         t_supplier_list,
         t_supplier_site_list,
         t_item_list,
         t_group_list,
         t_type_list,
         t_trxid1_list,
         t_trxid2_list,
         t_date1_list,
      t_date2_list);

      msc_x_netting_pkg.add_to_delete_tbl(
         b_customer_id(j),
         b_customer_site_id(j),
         null,
         null,
         b_publisher_id(j),
         b_publisher_site_id(j),
         b_item_id(j),
         msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
         msc_x_netting_pkg.G_EXCEP8,
         b_trx_id2(j),
         b_trx_id1(j),
         null,
         null,
         t_company_list,
         t_company_site_list,
         t_customer_list,
         t_customer_site_list,
         t_supplier_list,
         t_supplier_site_list,
         t_item_list,
         t_group_list,
         t_type_list,
         t_trxid1_list,
         t_trxid2_list,
         t_date1_list,
      t_date2_list);


      IF (j=1 OR (b_publisher_id(j -1) <> b_publisher_id(j) OR
      	     b_publisher_site_id(j-1) <> b_publisher_site_id(j) OR
      	     b_customer_id(j-1) <> b_customer_id(j) OR
      	     b_customer_site_id(j-1) <> b_customer_site_id(j) OR
      	     b_item_id(j-1) <> b_item_id(j) OR
      	     b_order_number(j-1) <> b_order_number(j) OR
      	     b_release_number(j-1) <> b_release_number(j) OR
      	     b_line_number(j-1) <> b_line_number(j) )) THEN

 --dbms_output.put_line('PUB ' || b_publisher_id(j));
 --dbms_output.put_line('PUB SITE ' || b_publisher_site_id(j));
 --dbms_output.put_line('ITEM ' || b_item_id(j));
 --dbms_output.put_line('CUST ' || b_customer_id(j));
 --dbms_output.put_line('CUST SITE ' || b_customer_site_id(j));
 --dbms_output.put_line('ORDER ' || b_order_number(j));
 --dbms_output.put_line('LINE ' || b_line_number(j));
 --dbms_output.put_line('REL ' || b_release_number(j));
 		-------------------------------------------------------------------------
 		-- get the latest SO to populate the exception
 		-------------------------------------------------------------------------
 	BEGIN
 	 	select transaction_id, receipt_date, ship_date, order_number, line_number, release_number
 	 	into l_last_so_trx_id, b_so_receipt_date(j), b_so_ship_date(j), b_end_order_number(j),
 	 	b_end_order_line_number(j), b_end_order_rel_number(j)
        	from msc_sup_dem_entries
 		where	publisher_id = b_publisher_id(j)
 		and	publisher_site_id = b_publisher_site_id(j)
 		and	customer_id = b_customer_id(j)
 		and	customer_site_id = b_customer_site_id(j)
 		and	inventory_item_id = b_item_id(j)
   		and  	publisher_order_type = msc_x_netting_pkg.SALES_ORDER
 		and	end_order_number = b_order_number(j)
 		and	NVL(end_order_line_number,-1) = nvl(b_line_number(j),-1)
   		and 	nvl(end_order_rel_number,-1) = nvl(b_release_number(j),-1)
    		and 	key_date = (select  max(key_date)
 			from	msc_sup_dem_entries
 		 	where	publisher_id = b_publisher_id(j)
		 	and	publisher_site_id = b_publisher_site_id(j)
		 	and	customer_id = b_customer_id(j)
		 	and	customer_site_id = b_customer_site_id(j)
		 	and	inventory_item_id = b_item_id(j)
 			and  	publisher_order_type = msc_x_netting_pkg.SALES_ORDER
 			and	end_order_number = b_order_number(j)
 			and	NVL(end_order_line_number,-1) = nvl(b_line_number(j),-1)
   			and nvl(end_order_rel_number,-1) = nvl(b_release_number(j),-1));
   	--dbms_output.put_line('so trx id ' || l_last_so_trx_id);
   	EXCEPTION
   		when others then
   			null;
   			--dbms_output.put_line('Error ' || sqlerrm);
   	END;


      --======================================================
      -- archive old exception and its complement
      --======================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      b_customer_id(j),
      b_customer_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_EXCESS,
      msc_x_netting_pkg.G_EXCEP27,
      l_last_so_trx_id,
      b_trx_id2(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);


   msc_x_netting_pkg.add_to_delete_tbl(
      b_customer_id(j),
      b_customer_site_id(j),
      null,
      null,
      b_publisher_id(j),
      b_publisher_site_id(j),
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_EXCESS,
      msc_x_netting_pkg.G_EXCEP28,
      b_trx_id2(j),
      l_last_so_trx_id,
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);


      msc_x_netting_pkg.add_to_delete_tbl(
         b_publisher_id(j),
         b_publisher_site_id(j),
         b_customer_id(j),
         b_customer_site_id(j),
         null,
         null,
         b_item_id(j),
         msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
         msc_x_netting_pkg.G_EXCEP7,
         l_last_so_trx_id,
         b_trx_id2(j),
         null,
         null,
         t_company_list,
         t_company_site_list,
         t_customer_list,
         t_customer_site_list,
         t_supplier_list,
         t_supplier_site_list,
         t_item_list,
         t_group_list,
         t_type_list,
         t_trxid1_list,
         t_trxid2_list,
         t_date1_list,
      t_date2_list);

      msc_x_netting_pkg.add_to_delete_tbl(
         b_customer_id(j),
         b_customer_site_id(j),
         null,
         null,
         b_publisher_id(j),
         b_publisher_site_id(j),
         b_item_id(j),
         msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
         msc_x_netting_pkg.G_EXCEP8,
         b_trx_id2(j),
         l_last_so_trx_id,
         null,
         null,
         t_company_list,
         t_company_site_list,
         t_customer_list,
         t_customer_site_list,
         t_supplier_list,
         t_supplier_site_list,
         t_item_list,
         t_group_list,
         t_type_list,
         t_trxid1_list,
         t_trxid2_list,
         t_date1_list,
      t_date2_list);

                --dbms_output.put_line('generate ex27');

      		--------------------------------------------------------------------------
      		-- get the shipping control
      		---------------------------------------------------------------------------
      		l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_customer_name(j),
                                    b_customer_site_name(j),
                                    b_publisher_name(j),
                                    b_publisher_site_name(j));

      		l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

      		l_exception_type := msc_x_netting_pkg.G_EXCEP27;  --  fulfillment qty excess for customer PO
      		l_exception_group := msc_x_netting_pkg.G_MATERIAL_EXCESS;
      		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);


      		msc_x_netting_pkg.add_to_exception_tbl(b_publisher_id(j),
               		b_publisher_name(j),
                                   b_publisher_site_id(j),
                                   b_publisher_site_name(j),
                                   b_item_id(j),
                                   b_item_name(j),
                                   b_item_desc(j),
                                   l_exception_type,
                                   l_exception_type_name,
                                   l_exception_group,
                                   l_exception_group_name,
                                   l_last_so_trx_id,			--b_trx_id1(j),
                                   b_trx_id2(j),
                                   b_customer_id(j),
                                   b_customer_name(j),
                                   b_customer_site_id(j),
                                   b_customer_site_name(j),
                                   b_customer_item_name(j),
                                   null,--l_supplier_id,
                                   null,
                                   null,  --l_supplier_site_id,
                                   null,
                                   b_supplier_item_name(j), --item name
                                   l_total_qty,
                                   b_tp_po_qty(j),
                                   null,
                                   l_threshold2,
                                   null,        --lead time
               			   null,       --l_item_min,
               			   null,       --l_item_max,
                                   b_order_number(j),
                                   b_release_number(j),
                                   b_line_number(j),
                                   b_end_order_number(j),
                                   b_end_order_rel_number(j),
                                   b_end_order_line_number(j),
                                   null,				--b_so_creation_date(j),
                                   null,				--b_po_creation_date(j),
                                   b_so_receipt_date(j),
                                   b_po_receipt_date(j),
                                   b_so_ship_date(j),
                                   b_po_ship_date(j),
                                   null,
                                   l_exception_basis,
               			a_company_id,
               			a_company_name,
               			a_company_site_id,
               			a_company_site_name,
               			a_item_id,
               			a_item_name,
               			a_item_desc,
               			a_exception_type,
               			a_exception_type_name,
               			a_exception_group,
               			a_exception_group_name,
               			a_trx_id1,
               			a_trx_id2,
               			a_customer_id,
               			a_customer_name,
               			a_customer_site_id,
               			a_customer_site_name,
               			a_customer_item_name,
               			a_supplier_id,
               			a_supplier_name,
               			a_supplier_site_id,
               			a_supplier_site_name,
               			a_supplier_item_name,
               			a_number1,
               			a_number2,
               			a_number3,
               			a_threshold,
               			a_lead_time,
               			a_item_min_qty,
               			a_item_max_qty,
               			a_order_number,
               			a_release_number,
               			a_line_number,
               			a_end_order_number,
               			a_end_order_rel_number,
               			a_end_order_line_number,
               			a_creation_date,
               			a_tp_creation_date,
               			a_date1,
               			a_date2,
               			a_date3,
               			a_date4,
               			a_date5,
               			a_exception_basis);
                      		l_inserted_record := l_inserted_record + 1;

      			-------------------------------------------------
      			-- generate complement exceptions
      			-------------------------------------------------
      	    if (b_po_last_refnum(j) <= p_refresh_number) then
      		--dbms_output.put_line('In complement 27');

      		   l_complement_threshold:= msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP28,
               		b_customer_id(j),
               		b_customer_site_id(j),
               		b_item_id(j),
               		b_publisher_id(j),
               		b_publisher_site_id(j),
               		null,
               		null,
                        b_po_ship_date(j));

         	   if (l_total_qty > b_po_qty(j) + (l_complement_threshold*b_po_qty(j)/100) ) then

         		l_exception_type := msc_x_netting_pkg.G_EXCEP28;  --fulfillment qty excess from your sup
         		l_exception_group := msc_x_netting_pkg.G_MATERIAL_EXCESS;
         		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
         		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

         		msc_x_netting_pkg.add_to_exception_tbl(b_customer_id(j),
                  	b_customer_name(j),
                              b_customer_site_id(j),
                              b_customer_site_name(j),
                              b_item_id(j),
                              b_item_name(j),
                              b_item_desc(j),
                              l_exception_type,
                              l_exception_type_name,
                              l_exception_group,
                              l_exception_group_name,
                              b_trx_id2(j),
                              l_last_so_trx_id,			--b_trx_id1(j),
                              null, --l_customer_id,
                              null,
                              null, --l_customer_site_id,
                              null,
                              b_customer_item_name(j),
                              b_publisher_id(j),
                              b_publisher_name(j),
                              b_publisher_site_id(j),
                              b_publisher_site_name(j),
                              b_supplier_item_name(j),
                              b_po_qty(j),
                              l_total_qty,
                              null,
                              l_complement_threshold,
                              null,       --lead time
                  		null,       --l_item_min,
                  	      null,       --l_item_max,
                              b_order_number(j),
                              b_release_number(j),
                              b_line_number(j),
                              b_end_order_number(j),
                              b_end_order_rel_number(j),
                              b_end_order_line_number(j),
                      	      null,				--b_po_creation_date(j),
                      	      null,				--b_so_creation_date(j),
                      	      b_po_receipt_date(j),
                      	      b_so_receipt_date(j),
                      	      b_so_ship_date(j),
                      	      b_po_ship_date(j),
                      	      null,
                 	      l_exception_basis,
                  	a_company_id,
                  	a_company_name,
                  	a_company_site_id,
                  	a_company_site_name,
                  	a_item_id,
                  	a_item_name,
                  	a_item_desc,
                  	a_exception_type,
                  	a_exception_type_name,
                  	a_exception_group,
                  	a_exception_group_name,
                  	a_trx_id1,
                  	a_trx_id2,
                  	a_customer_id,
                  	a_customer_name,
                  	a_customer_site_id,
                  	a_customer_site_name,
                  	a_customer_item_name,
                  	a_supplier_id,
                  	a_supplier_name,
                  	a_supplier_site_id,
                  	a_supplier_site_name,
                  	a_supplier_item_name,
                  	a_number1,
                  	a_number2,
                  	a_number3,
                  	a_threshold,
                  	a_lead_time,
                  	a_item_min_qty,
                  	a_item_max_qty,
                  	a_order_number,
                  	a_release_number,
                  	a_line_number,
                  	a_end_order_number,
                  	a_end_order_rel_number,
                  	a_end_order_line_number,
            	  	a_creation_date,
            	  	a_tp_creation_date,
            	  	a_date1,
            	  	a_date2,
            	  	a_date3,
            	  	a_date4,
            	  	a_date5,
            	  	a_exception_basis);
            	  	l_inserted_record := l_inserted_record + 1;

               	   end if;
           end if;
     	END IF;			-- if j=1
   end if;
END LOOP;
END IF;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: '  || msc_x_netting_pkg.get_message_type(27) ||
   ':' ||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

/* reset the trxid */

l_generate_complement := null;

--dbms_output.put_line('Exception 28');   --customer centric
Open exception_28 ( p_refresh_number);
      fetch exception_28 BULK COLLECT INTO
                  	b_trx_id1,
                  	b_publisher_id,
                  	b_publisher_name,
                  	b_publisher_site_id,
                  	b_publisher_site_name,
                  	b_item_id,
                  	b_item_name,
                  	b_item_desc,
                  	b_customer_item_name,
                  	b_customer_item_desc,
                  	b_po_key_date,
               		b_po_ship_date,
               		b_po_receipt_date,
               		b_posting_po_qty,
                       	b_po_qty,
                   	b_tp_po_qty,
                    	b_order_number,
                    	b_release_number,
                     	b_line_number,
                     	b_supplier_id,
                  	b_supplier_name,
                   	b_supplier_site_id,
                    	b_supplier_site_name,
                    	b_supplier_item_name,
                    	b_supplier_item_desc,
                   	b_po_creation_date,
                    	b_po_last_refnum,
                  	b_trx_id2,
                  	b_so_key_date,
                      	b_so_ship_date,
                    	b_so_receipt_date,
                    	b_posting_so_qty,
                    	b_so_qty,
                   	b_tp_so_qty,
                 	b_end_order_number,
                   	b_end_order_rel_number,
                    	b_end_order_line_number,
                   	b_customer_id,
                   	b_customer_name,
                     	b_customer_site_id, --owning org
                       	b_customer_site_name,
                    	b_so_creation_date,
                      	b_so_last_refnum;
 CLOSE  exception_28;

 IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
 FOR j in 1..b_trx_id1.COUNT
 LOOP
      --dbms_output.put_line('-----Exception28: Trx id 1 = ' || b_trx_id1(j));
      --dbms_output.put_line('---------------  Trx id 2 = ' || b_trx_id2(j));

      --======================================================
      -- archive old exception and its complement
      --======================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_EXCESS,
      msc_x_netting_pkg.G_EXCEP28,
      b_trx_id1(j),
      b_trx_id2(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);

   msc_x_netting_pkg.add_to_delete_tbl(
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_EXCESS,
      msc_x_netting_pkg.G_EXCEP27,
      b_trx_id2(j),
      b_trx_id1(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);


      l_threshold2 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP28,
                     	b_publisher_id(j),
                  	b_publisher_site_id(j),
                  	b_item_id(j),
               		b_supplier_id(j),
               		b_supplier_site_id(j),
               		null,
               		null,
                     	b_po_key_date(j));

      l_total_qty := msc_x_netting_pkg.get_total_qty(b_order_number(j),
                       	b_release_number(j),
                        b_line_number(j),
            		b_supplier_id(j),
            		b_supplier_site_id(j),
                        b_publisher_id(j),
                        b_publisher_site_id(j),
                        b_item_id(j));

   IF (l_total_qty > b_po_qty(j) + (l_threshold2*b_po_qty(j)/100) ) then

         --======================================================
         -- Clean up the opposite exception and its complement
      --======================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
      msc_x_netting_pkg.G_EXCEP8,
      b_trx_id1(j),
      b_trx_id2(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);

   msc_x_netting_pkg.add_to_delete_tbl(
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
      msc_x_netting_pkg.G_EXCEP7,
      b_trx_id2(j),
      b_trx_id1(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);

      IF (j=1 OR (b_publisher_id(j -1) <> b_publisher_id(j) OR
      	     b_publisher_site_id(j-1) <> b_publisher_site_id(j) OR
      	     b_customer_id(j-1) <> b_customer_id(j) OR
      	     b_customer_site_id(j-1) <> b_customer_site_id(j) OR
      	     b_item_id(j-1) <> b_item_id(j) OR
      	     b_order_number(j-1) <> b_order_number(j) OR
      	     b_release_number(j-1) <> b_release_number(j) OR
      	     b_line_number(j-1) <> b_line_number(j) )) THEN

--dbms_output.put_line('in if');
 		-------------------------------------------------------------------------
 		-- get the latest SO to populate the exception
 		-------------------------------------------------------------------------
 	BEGIN
 	 	select transaction_id, receipt_date, ship_date, order_number, line_number, release_number, last_refresh_number
 	 	into l_last_so_trx_id, b_so_receipt_date(j), b_so_ship_date(j), b_end_order_number(j),
 	 	b_end_order_line_number(j), b_end_order_rel_number(j), b_so_last_refnum(j)
        	from msc_sup_dem_entries
 		where	publisher_id = b_supplier_id(j)
 		and	publisher_site_id = b_supplier_site_id(j)
 		and	customer_id = b_publisher_id(j)
 		and	customer_site_id = b_publisher_site_id(j)
 		and	inventory_item_id = b_item_id(j)
   		and  	publisher_order_type = msc_x_netting_pkg.SALES_ORDER
 		and	end_order_number = b_order_number(j)
 		and	NVL(end_order_line_number,-1) = nvl(b_line_number(j),-1)
   		and 	nvl(end_order_rel_number,-1) = nvl(b_release_number(j),-1)
    		and 	key_date = (select  max(key_date)
 			from	msc_sup_dem_entries
 		 	where	publisher_id = b_supplier_id(j)
		 	and	publisher_site_id = b_supplier_site_id(j)
		 	and	customer_id = b_publisher_id(j)
		 	and	customer_site_id = b_publisher_site_id(j)
		 	and	inventory_item_id = b_item_id(j)
 			and  	publisher_order_type = msc_x_netting_pkg.SALES_ORDER
 			and	end_order_number = b_order_number(j)
 			and	NVL(end_order_line_number,-1) = nvl(b_line_number(j),-1)
   			and nvl(end_order_rel_number,-1) = nvl(b_release_number(j),-1) );
   	EXCEPTION
   		when others then
   			null;
   			--dbms_output.put_line('Error ' || sqlerrm);
   	END;

     		SELECT max(last_refresh_number)
     		into b_so_last_refnum(j)
  			from	msc_sup_dem_entries
  		 	where	publisher_id = b_supplier_id(j)
 		 	and	publisher_site_id = b_supplier_site_id(j)
 		 	and	customer_id = b_publisher_id(j)
 		 	and	customer_site_id = b_publisher_site_id(j)
 		 	and	inventory_item_id = b_item_id(j)
  			and  	publisher_order_type = msc_x_netting_pkg.SALES_ORDER
  			and	end_order_number = b_order_number(j)
  			and	NVL(end_order_line_number,-1) = nvl(b_line_number(j),-1)
   			and nvl(end_order_rel_number,-1) = nvl(b_release_number(j),-1);


  --dbms_output.put_line('trx id ' || l_last_so_trx_id || ' last ref num ' || b_so_last_refnum(j) || ' p_refnum ' || p_refresh_number);

        --======================================================
        -- archive old exception and its complement
        --======================================================
     msc_x_netting_pkg.add_to_delete_tbl(
        b_publisher_id(j),
        b_publisher_site_id(j),
        null,
        null,
        b_supplier_id(j),
        b_supplier_site_id(j),
        b_item_id(j),
        msc_x_netting_pkg.G_MATERIAL_EXCESS,
        msc_x_netting_pkg.G_EXCEP28,
        b_trx_id1(j),
        l_last_so_trx_id,
        null,
        null,
        t_company_list,
        t_company_site_list,
        t_customer_list,
        t_customer_site_list,
        t_supplier_list,
        t_supplier_site_list,
        t_item_list,
        t_group_list,
        t_type_list,
        t_trxid1_list,
        t_trxid2_list,
        t_date1_list,
        t_date2_list);

     msc_x_netting_pkg.add_to_delete_tbl(
        b_supplier_id(j),
        b_supplier_site_id(j),
        b_publisher_id(j),
        b_publisher_site_id(j),
        null,
        null,
        b_item_id(j),
        msc_x_netting_pkg.G_MATERIAL_EXCESS,
        msc_x_netting_pkg.G_EXCEP27,
        l_last_so_trx_id,
        b_trx_id1(j),
        null,
        null,
        t_company_list,
        t_company_site_list,
        t_customer_list,
        t_customer_site_list,
        t_supplier_list,
        t_supplier_site_list,
        t_item_list,
        t_group_list,
        t_type_list,
        t_trxid1_list,
        t_trxid2_list,
        t_date1_list,
        t_date2_list);

   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
      msc_x_netting_pkg.G_EXCEP8,
      b_trx_id1(j),
      l_last_so_trx_id,
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);

   msc_x_netting_pkg.add_to_delete_tbl(
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_MATERIAL_SHORTAGE,
      msc_x_netting_pkg.G_EXCEP7,
      l_last_so_trx_id,
      b_trx_id1(j),
      null,
      null,
      t_company_list,
      t_company_site_list,
      t_customer_list,
      t_customer_site_list,
      t_supplier_list,
      t_supplier_site_list,
      t_item_list,
      t_group_list,
      t_type_list,
      t_trxid1_list,
      t_trxid2_list,
      t_date1_list,
      t_date2_list);


                --dbms_output.put_line('generate ex28');
      		--------------------------------------------------------------------------
      		-- get the shipping control
      		---------------------------------------------------------------------------
      		l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
      	                              b_publisher_site_name(j),
                                    b_supplier_name(j),
                                    b_supplier_site_name(j));

      		l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));
      		l_exception_type := msc_x_netting_pkg.G_EXCEP28;
      		l_exception_group := msc_x_netting_pkg.G_MATERIAL_EXCESS;
      		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

         	msc_x_netting_pkg.add_to_exception_tbl(b_publisher_id(j),
                     b_publisher_name(j),
                                b_publisher_site_id(j),
                                b_publisher_site_name(j),
                                b_item_id(j),
                                b_item_name(j),
                                b_item_desc(j),
                                l_exception_type,
                                l_exception_type_name,
                                l_exception_group,
                                l_exception_group_name,
                                b_trx_id1(j),
                                l_last_so_trx_id,		--b_trx_id2(j),
                                null,  --l_customer_id,
                                null,  --
                                null,  --l_customer_site_id,
                                null,
                                b_customer_item_name(j),
                                b_supplier_id(j),
                                b_supplier_name(j),
                                b_supplier_site_id(j),
                                b_supplier_site_name(j),
                                b_supplier_item_name(j),
                                b_po_qty(j),     --number1
                                l_total_qty,       --number2
                                null,           --number3
                                l_threshold2,
                                null,        --lead time
            			null,       --l_item_min,
            			null,       --l_item_max,
                                b_order_number(j),
                                b_release_number(j),
                                b_line_number(j),
                                b_end_order_number(j),
                                b_end_order_rel_number(j),
                                b_end_order_line_number(j),
            			null,				--b_po_creation_date(j),
            			null,				--b_so_creation_date(j),
            			b_po_receipt_date(j),
            			b_so_receipt_date(j),
            			b_so_ship_date(j),
            			b_po_ship_date(j),
            			null,
            			l_exception_basis,
            			a_company_id,
            			a_company_name,
            			a_company_site_id,
            			a_company_site_name,
            			a_item_id,
            			a_item_name,
            			a_item_desc,
            			a_exception_type,
            			a_exception_type_name,
            			a_exception_group,
            			a_exception_group_name,
            			a_trx_id1,
            			a_trx_id2,
            			a_customer_id,
            			a_customer_name,
            			a_customer_site_id,
            			a_customer_site_name,
            			a_customer_item_name,
            			a_supplier_id,
            			a_supplier_name,
            			a_supplier_site_id,
            			a_supplier_site_name,
            			a_supplier_item_name,
            			a_number1,
            			a_number2,
            			a_number3,
            			a_threshold,
            			a_lead_time,
            			a_item_min_qty,
            			a_item_max_qty,
            			a_order_number,
            			a_release_number,
            			a_line_number,
            			a_end_order_number,
            			a_end_order_rel_number,
            			a_end_order_line_number,
            			a_creation_date,
            			a_tp_creation_date,
            			a_date1,
            			a_date2,
            			a_date3,
            			a_date4,
            			a_date5,
            			a_exception_basis);
				l_inserted_record := l_inserted_record + 1;

         		------------------------------------------------------
         		-- generate complement exception
         		------------------------------------------------------
       	   if (b_so_last_refnum(j) <= p_refresh_number) then
                --dbms_output.put_line('In complement28');

                --dbms_output.put_line('generate complement ex');
      	   	l_complement_threshold:= msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP27,
               		b_supplier_id(j),
               		b_supplier_site_id(j),
               		b_item_id(j),
               		null,
               		null,
               		b_publisher_id(j),
               		b_publisher_site_id(j),
                        b_so_key_date(j));

            	   if (l_total_qty > b_po_qty(j) + (l_complement_threshold*b_po_qty(j)/100) ) THEN

            		l_exception_type := msc_x_netting_pkg.G_EXCEP27;  --fulfillment qty excess for your cust po
            		l_exception_group := msc_x_netting_pkg.G_MATERIAL_EXCESS;
            		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
            		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

            		msc_x_netting_pkg.add_to_exception_tbl(b_supplier_id(j),
                  		b_supplier_name(j),
                              b_supplier_site_id(j),
                              b_supplier_site_name(j),
                              b_item_id(j),
                              b_item_name(j),
                              b_item_desc(j),
                              l_exception_type,
                              l_exception_type_name,
                              l_exception_group,
                              l_exception_group_name,
                              l_last_so_trx_id,			--b_trx_id2(j),
                              b_trx_id1(j),
                           b_publisher_id(j),
                           b_publisher_name(j),
                              b_publisher_site_id(j),
                              b_publisher_site_name(j),
                              b_customer_item_name(j),
                              null, --l_supplier_id,
                              null,
                              null, --l_supplier_site_id,
                              null,
                              b_supplier_item_name(j),   --itme name
                              l_total_qty,
                              b_tp_po_qty(j),
                              null,
                              l_complement_threshold,
                              null,       --lead time
               			null,       --l_item_min,
               			null,       --l_item_max,
                              b_order_number(j),
                              b_release_number(j),
                              b_line_number(j),
                              b_end_order_number(j),
                              b_end_order_rel_number(j),
                              b_end_order_line_number(j),
                              null,				--b_so_creation_date(j),
                              null,				--b_po_creation_date(j),
                              b_so_receipt_date(j),
                              b_po_receipt_date(j),
                              b_so_ship_date(j),
                              b_po_ship_date(j),
                              null,
                              l_exception_basis,
               		a_company_id,
               		a_company_name,
               		a_company_site_id,
               		a_company_site_name,
               		a_item_id,
               		a_item_name,
               		a_item_desc,
               		a_exception_type,
               		a_exception_type_name,
               		a_exception_group,
               		a_exception_group_name,
               		a_trx_id1,
               		a_trx_id2,
               		a_customer_id,
               		a_customer_name,
               		a_customer_site_id,
               		a_customer_site_name,
               		a_customer_item_name,
               		a_supplier_id,
               		a_supplier_name,
               		a_supplier_site_id,
               		a_supplier_site_name,
               		a_supplier_item_name,
               		a_number1,
               		a_number2,
               		a_number3,
               		a_threshold,
               		a_lead_time,
               		a_item_min_qty,
               		a_item_max_qty,
               		a_order_number,
               		a_release_number,
               		a_line_number,
               		a_end_order_number,
               		a_end_order_rel_number,
               		a_end_order_line_number,
               		a_creation_date,
               		a_tp_creation_date,
               		a_date1,
               		a_date2,
               		a_date3,
               		a_date4,
               		a_date5,
               		a_exception_basis);
               		l_inserted_record := l_inserted_record + 1;

            	   end if;
          END IF; /* generate complement exception */
     	END IF;		--if j = 1
    end if;
END LOOP;
END IF;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' || msc_x_netting_pkg.get_message_type(28) ||
   ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total exceptions inserted for the group ' ||
 msc_x_netting_pkg.get_message_group(msc_x_netting_pkg.G_MATERIAL_EXCESS) || ':' || l_inserted_record);

EXCEPTION
   WHEN OTHERS THEN
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING2_PKG.Compute_Material_Excess');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
--      dbms_output.put_line('Error ' || sqlerrm);
      return;

END Compute_Material_Excess;

END MSC_X_NETTING2_PKG;


/
