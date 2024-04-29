--------------------------------------------------------
--  DDL for Package Body MSC_X_NETTING4_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_NETTING4_PKG" AS
/* $Header: MSCXEX4B.pls 120.3 2008/01/07 09:36:28 dejoshi ship $ */


--===========================================
-- Group: Changed Order
--============================================
--------------------------------------------------------------------------------
-- Your customer's purchase order to you has been cancelled: exception_33
-- supplier centric
-------------------------------------------------------------------------------
CURSOR exception_33 (p_refresh_number in Number) IS
SELECT  sd.transaction_id,      -- need customer info only
        sd.publisher_id,
        sd.publisher_name,
        sd.publisher_site_id,
        sd.publisher_site_name,
        sd.inventory_item_id,
        sd.item_name,
        sd.item_description,
        sd.customer_item_name,
        sd.customer_item_description,
        sd.key_date,
        sd.ship_date,
        sd.receipt_date,
        sd.quantity,
        sd.primary_quantity,
        sd.tp_quantity,
        sd.order_number,
        sd.release_number,
        sd.line_number,
        sd.supplier_id,
        sd.supplier_name,
        sd.supplier_site_id,
        sd.supplier_site_name,
        sd.supplier_item_name,
        sd.supplier_item_description,
        sd.last_update_date
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND   sd.quantity = 0
AND     nvl(sd.last_refresh_number,-1) > nvl(p_refresh_number,-1)
AND     (sd.last_update_login is NULL OR nvl(sd.last_update_login,-99) <>-99) --added for Bug #6729356
AND   NOT EXISTS	---- Fix for Bug # 6144881
	(
 	 SELECT order_number
	 FROM msc_sup_dem_history sdh
	 WHERE sdh.quantity_old is null
	 AND sdh.order_number   = sd.order_number
	 AND nvl(sdh.line_number, -99)   = nvl(sd.line_number, -99)
	 AND nvl(sdh.release_number,-99) = nvl(sd.release_number, -99)
	 AND sdh.quantity_new =
		(select sum(quantity)
		from msc_sup_dem_entries
		where publisher_order_type = 15
		and end_order_number = sd.order_number
		and nvl(end_order_line_number,-99) = nvl(sd.line_number, -99)
		and nvl(end_order_rel_number, -99) = nvl(sd.release_number, -99)));

--------------------------------------------------------------------------------
-- Your customer's purchase order to you has been rescheduled: exception_34
-- supplier centric
-------------------------------------------------------------------------------
CURSOR exception_34 (p_refresh_number in Number) IS
SELECT  distinct sd1.transaction_id,
	sd2.history_id,
   	sd1.publisher_id,
        sd1.publisher_name,
        sd1.publisher_site_id,
        sd1.publisher_site_name,
        sd1.inventory_item_id,
        sd1.item_name,
        sd1.item_description,
        sd1.customer_item_name,
        sd1.customer_item_description,
        sd1.quantity,
        sd1.primary_quantity,
        sd1.tp_quantity,
        sd1.supplier_id,
        sd1.supplier_name,
        sd1.supplier_site_id,
        sd1.supplier_site_name,
        sd1.supplier_item_name,
        sd1.supplier_item_description,
        sd1.order_number,
        sd1.release_number,
        sd1.line_number,
        sd1.key_date,
        sd2.key_date_new,
        sd2.key_date_old
FROM    msc_sup_dem_entries sd1,
   msc_sup_dem_history sd2
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND   sd1.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND   sd2.plan_id = sd1.plan_id
AND   sd2.publisher_order_type = sd1.publisher_order_type
AND   sd2.item_name = sd1.item_name
AND   sd2.publisher_name = sd1.publisher_name
AND   sd2.publisher_site_name = sd1.publisher_site_name
AND   sd2.supplier_name = sd1.supplier_name
AND   sd2.supplier_site_name = sd1.supplier_site_name
AND   sd2.order_number = sd1.order_number
AND   nvl(sd2.release_number, -1) = nvl(sd1.release_number, -1)
AND   nvl(sd2.line_number, -1) = nvl(sd1.line_number, -1)
AND   trunc(sd2.key_date_old) <> trunc(sd2.key_date_new)
AND   trunc(sd1.key_date)=trunc(sd2.key_date_new)
AND   sd2.key_date_old is not null
AND   sd2.last_refresh_number_new = sd1.last_refresh_number
AND   sd1.transaction_id = sd2.transaction_id
AND     nvl(sd1.last_refresh_number,-1) > nvl(p_refresh_number,-1)
UNION
SELECT  distinct sd1.transaction_id,
	sd2.history_id,
   	sd1.publisher_id,
        sd1.publisher_name,
        sd1.publisher_site_id,
        sd1.publisher_site_name,
        sd1.inventory_item_id,
        sd1.item_name,
        sd1.item_description,
        sd1.customer_item_name,
        sd1.customer_item_description,
        sd1.quantity,
        sd1.primary_quantity,
        sd1.tp_quantity,
        sd1.supplier_id,
        sd1.supplier_name,
        sd1.supplier_site_id,
        sd1.supplier_site_name,
        sd1.supplier_item_name,
        sd1.supplier_item_description,
        sd1.order_number,
        sd1.release_number,
        sd1.line_number,
        sd1.key_date,
        sd2.key_date_new,
        sd2.key_date_old
FROM    msc_sup_dem_entries sd1,
   msc_sup_dem_history sd2
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND   sd1.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND   sd2.plan_id = sd1.plan_id
AND   sd2.publisher_order_type = sd1.publisher_order_type
AND   sd2.item_name = sd1.item_name
AND   sd2.publisher_name = sd1.publisher_name
AND   sd2.publisher_site_name = sd1.publisher_site_name
AND   sd2.supplier_name = sd1.supplier_name
AND   sd2.supplier_site_name = sd1.supplier_site_name
AND   sd2.order_number = sd1.order_number
AND   nvl(sd2.release_number, -1) = nvl(sd1.release_number, -1)
AND   nvl(sd2.line_number, -1) = nvl(sd1.line_number, -1)
AND   trunc(sd1.key_date) <> trunc(sd2.key_date_new)
AND   sd1.transaction_id = sd2.transaction_id
AND     nvl(sd1.last_refresh_number,-1) > nvl(p_refresh_number,-1)
order by 1,2 desc;

------------------------------------------------------------------------------
-- Purchase order has been rejected
-------------------------------------------------------------------------------
CURSOR exception_49 (p_refresh_number in Number) IS
SELECT  sd.transaction_id,      -- need customer info only
        sd.publisher_id,
        sd.publisher_name,
        sd.publisher_site_id,
        sd.publisher_site_name,
        sd.inventory_item_id,
        sd.item_name,
        sd.item_description,
        sd.customer_item_name,
        sd.customer_item_description,
        sd.key_date,
        sd.ship_date,
        sd.receipt_date,
        sd.quantity,
        sd.primary_quantity,
        sd.tp_quantity,
        sd.order_number,
        sd.release_number,
        sd.line_number,
        sd.supplier_id,
        sd.supplier_name,
        sd.supplier_site_id,
        sd.supplier_site_name,
        sd.supplier_item_name,
        sd.supplier_item_description,
        sd.creation_date,
        sd.last_update_date
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND     sd.acceptance_required_flag = 'R'
AND     nvl(sd.last_refresh_number,-1) > nvl(p_refresh_number,-1);

--==============================================================================
-- Group9: Forecast Accuracy
--------------------------------------------------------------------------------
-- Sales Forecast Accuracy
-- 9.1 Customer sales forecast exceeds actual sales: exception_35
-- 9.2 Sales forecast exceeds actual sales: exception_36
--both customer/supplier can post sales forecast for the related data
--inorder to identify who is posting the data,
--the publisher_id has to be = customer_id for the following case
-------------------------------------------------------------------------------

CURSOR exception_35_36  IS
SELECT  distinct sd.publisher_id,     --require distinct bug# 2381227 (duplicate exceptions)
        sd.publisher_name,
        sd.publisher_site_id,
        sd.publisher_site_name,
        sd.inventory_item_id,
        sd.item_name,
        sd.item_description,
        sd.customer_item_name,
        sd.supplier_id,
        sd.supplier_name,
        sd.supplier_site_id,
        sd.supplier_site_name,
        sd.supplier_item_name,
        sd.supplier_item_description
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type = msc_x_netting_pkg.SALES_FORECAST
AND   sd.customer_id = sd.publisher_id
AND   sd.customer_site_id = sd.publisher_site_id
AND   trunc(sd.key_date) between
      add_months(trunc(sysdate), -3) and trunc(sysdate);

/* replace ship_date to key_date (performance) */

------------------------------------------------------------------------------
--  Forecast Accuracy
-- 9.3 Customer order forecast exceeds actual orders: exception_37
-- 9.4 Order forecast exceeds actual orders: exception_38
--Note: These two exceptions will not supported in this release
-------------------------------------------------------------------------------
CURSOR exception_37_38  IS
SELECT  sd.publisher_id,
        sd.publisher_name,
        sd.publisher_site_id,
        sd.publisher_site_name,
        sd.inventory_item_id,
        sd.item_name,
        sd.item_description,
        sd.supplier_id,
        sd.supplier_name,
        sd.supplier_site_id,
        sd.supplier_site_name,
        sd.supplier_item_name,
        sd.supplier_item_description
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type = msc_x_netting_pkg.ORDER_FORECAST
AND   trunc(sd.key_date) between
      add_months(trunc(sysdate), -3) and trunc(sysdate);

---====================================================================
-- Group 10: Peformance below target
-- =====================================================================
-- Forecast Accuracy
-- 10.1 Customer forecast error exceeds threshold: exception_39
-- 10.2 Forecast error exceeds threshold: exception_40
----------------------------------------------------------------------
CURSOR exception_39_40  IS
SELECT  distinct sd.publisher_id,
        sd.publisher_name,
        sd.publisher_site_id,
        sd.publisher_site_name,
        sd.inventory_item_id,
        sd.item_name,
        sd.item_description,
        sd.customer_item_name,
        sd.supplier_id,
        sd.supplier_name,
        sd.supplier_site_id,
        sd.supplier_site_name,
        sd.supplier_item_name,
        sd.supplier_item_description
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type = msc_x_netting_pkg.HISTORICAL_SALES
AND   trunc(sd.key_date) between
      add_months(trunc(sysdate), -3) and trunc(sysdate);

/* replace ship_date to key_date (performance) */

----------------------------------------------------------------------
-- Fill Rate
-- 9. Your supplier's performance is below the threshold for fill-rate
-- over the last 3 months: exception_41
-- 10. Your performance is below the threshold for fill-rate over
-- the last 3 months: exception_42
-- Note: These two exceptions will not supported in this release
----------------------------------------------------------------------
CURSOR exception_41_42  IS
SELECT  distinct sd.publisher_id,
        sd.publisher_name,
        sd.publisher_site_id,
        sd.publisher_site_name,
        sd.inventory_item_id,
        sd.item_name,
        sd.item_description,
        sd.customer_item_name,
         sd.order_number,
        sd.supplier_id,
        sd.supplier_name,
        sd.supplier_site_id,
        sd.supplier_site_name,
        sd.supplier_item_name,
        sd.supplier_item_description
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND   trunc(sd.key_date) between
      add_months(trunc(sysdate), -3) and trunc(sysdate);

/* replace receipt_date to key_date (performance) */

CURSOR initial_shipment_cur(p_company_id in Number,
         p_org_id in Number,
         p_item_id in Number,
         p_order_number in Varchar2) Is
SELECT   sd1.primary_quantity, sd1.tp_quantity,sd1.quantity,
   sd2.primary_quantity, sd2.tp_quantity,sd2.quantity
FROM  msc_sup_dem_entries sd1,
   msc_sup_dem_entries sd2
WHERE sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND   sd1.publisher_id = p_company_id
AND   sd1.publisher_site_id = p_org_id
AND   sd1.inventory_item_id = p_item_id
AND   sd1.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND   sd1.order_number = p_order_number
AND   sd2.plan_id = sd1.plan_id
AND   sd2.publisher_id = sd1.supplier_id
AND   sd2.publisher_site_id = sd1.supplier_site_id
AND   sd2.publisher_order_type = msc_x_netting_pkg.ASN
AND   sd2.end_order_number = sd1.order_number
AND   nvl(sd2.end_order_rel_number,-1) = nvl(sd1.release_number,-1)
AND   nvl(sd2.end_order_line_number, -1) = nvl(sd1.line_number,-1)
AND   trunc(sd2.key_date) <= trunc(sd1.key_date)
AND   trunc(sd1.key_date) between
      add_months(trunc(sysdate),-3) and trunc(sysdate);

 /*---------------------------------
  The actual date for order type = ASN is ship_date
  In order to compute the shipment qty, the load program has
  calculate the lead time for the ship_date.
  The receipt_date = ship_date + lead time
  Netting engine will only use receipt_date to compute exception
  or can also use ship_date only.

  Note: in release 11.5.10, a shipping control context will be honored
  for all relevant transactions in CP.  The impact will be on PO/SO/ASN/shipment receipt
  Therefore, the key_date will be used instead on receipt or ship date for exception

 ---------------------------------------*/

----------------------------------------------------------------------
-- 10.5 Supplier fill rate is below threshold
-- 10.6 Fill rate to customer is below threshold
----------------------------------------------------------------------
CURSOR exception_43_44 IS
SELECT  distinct sd.publisher_id,
        sd.publisher_site_id,
        sd.inventory_item_id,
        sd.supplier_id,
        sd.supplier_site_id
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND   trunc(sd.key_date) between
      add_months(trunc(sysdate), -3) and trunc(sysdate);
--ORDER BY sd.order_number, sd.release_number, sd.line_number;

/* replace receipt_date to key_date (performance) */
  /*---------------------------------
   The actual date for order type = ASN/SO is ship_date
   In order to compute the dates between po and asn, the load program has
   calculate the lead time for the ship_date.
   The receipt_date = ship_date + lead time
   Netting engine will only use receipt_date to compute exception
   or can also use ship_date only.

     Note: in release 11.5.10, a shipping control context will be honored
     for all relevant transactions in CP.  The impact will be on PO/SO/ASN/shipment receipt
     Therefore, the key_date will be used instead on receipt or ship date for exception

 ---------------------------------------*/
/*----------------------------------------------------------------
 | The pegging is as following:
 | case1: PO -> SO -> ASN -> SHIPMENT RECEIPT or
 | case2: PO -> SO -> ASN and PO -> SHIPMENT RECEIPT or
 | case3: PO -> SO and PO -> ASN -> SHIPMENT RECEIPT or
 | case4: PO -> SO and PO -> ASN and PO -> SHIPMENT RECEIPT
 | Note: First look at the shipment receipt, then asn, then so
 ------------------------------------------------------------------*/
/*------------------------------------------------------
   find the po lines for a particular po
  ----------------------------------------------------*/
CURSOR po_line_cur (p_publisher_id in number,
      p_publisher_site_id in number,
      p_item_id in number) IS
SELECT  distinct sd.publisher_id,
        sd.publisher_name,
        sd.publisher_site_id,
        sd.publisher_site_name,
        sd.inventory_item_id,
        sd.item_name,
        sd.item_description,
        sd.customer_item_name,
        sd.key_date,
        sd.ship_date,
        sd.receipt_date,
        sd.quantity,
        sd.tp_quantity,
         sd.order_number,
   sd.release_number,
        sd.line_number,
        sd.supplier_id,
        sd.supplier_name,
        sd.supplier_site_id,
        sd.supplier_site_name,
        sd.supplier_item_name,
        sd.supplier_item_description
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND   sd.publisher_id = p_publisher_id
AND   sd.publisher_site_id = p_publisher_site_id
AND   sd.inventory_item_id = p_item_id
AND   trunc(sd.key_date) between
      add_months(trunc(sysdate), -3) and trunc(sysdate);

/*-----------------------------------------------------------------------
 | case1: PO -> SO -> ASN -> SHIPMENT RECEIPT


 -----------------------------------------------------------------------*/

CURSOR receipt1_cur (p_supplier_id in number,
      p_supplier_site_id in number,
      p_item_id in number,
      p_order_number in Varchar2,
      p_release_number in Varchar2,
      p_line_number in Varchar2) IS
SELECT   sd3.key_date		--sd3.ship_date     --sd2.new_schedule_date
				--the load also populate the ship date; therefore
            			--use ship date to compare
    /*-----------------------------------------------------------------------------
      Note: in release 11.5.10, a shipping control context will be honored
      for all relevant transactions in CP.  The impact will be on PO/SO/ASN/shipment receipt
   	Therefore, the key_date will be used instead on receipt or ship date for exception
     ---------------------------------------------------------------------------------*/
FROM  msc_sup_dem_entries sd1,
   msc_sup_dem_entries sd2,
   msc_sup_dem_entries sd3
WHERE sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND   sd1.publisher_id = p_supplier_id
AND   sd1.publisher_site_id = p_supplier_site_id
AND   sd1.inventory_item_id = p_item_id
AND   sd1.publisher_order_type = msc_x_netting_pkg.SALES_ORDER
AND   sd1.end_order_number = p_order_number
AND   nvl(sd1.end_order_rel_number,-1) = nvl(p_release_number, -1)
AND   nvl(sd1.end_order_line_number, -1) = nvl(p_line_number, -1)
AND   sd2.plan_id = sd1.plan_id
AND   sd2.publisher_order_type = msc_x_netting_pkg.ASN
AND   sd2.end_order_number = sd1.order_number
AND   nvl(sd2.end_order_rel_number,-1) = nvl(sd1.release_number,-1)
AND   nvl(sd2.end_order_line_number, -1) = nvl(sd1.line_number, -1)
AND   sd2.end_order_publisher_id = sd1.publisher_id
AND   sd3.plan_id = sd2.plan_id
AND   sd3.publisher_order_type = msc_x_netting_pkg.SHIPMENT_RECEIPT
AND   sd3.end_order_number = sd2.order_number
AND   nvl(sd3.end_order_rel_number,-1) = nvl(sd2.release_number, -1)
AND   nvl(sd3.end_order_line_number, -1) = nvl(sd2.line_number, -1)
AND   trunc(sd3.key_date) between
      add_months(trunc(sysdate),-3) and trunc(sysdate);

/*-----------------------------------------------------------------------
 | case3: PO -> SO and PO -> ASN -> SHIPMENT RECEIPT
 -----------------------------------------------------------------------*/
CURSOR receipt2_cur (p_supplier_id in number,
      p_supplier_site_id in number,
      p_item_id in number,
      p_order_number in Varchar2,
      p_release_number in Varchar2,
      p_line_number in Varchar2) IS
SELECT   sd2.key_date		--sd2.ship_date     --sd2.new_schedule_date
				-- the load also populate the ship date; therefore
            			--use ship date to compare
    /*-----------------------------------------------------------------------------
      Note: in release 11.5.10, a shipping control context will be honored
      for all relevant transactions in CP.  The impact will be on PO/SO/ASN/shipment receipt
   	Therefore, the key_date will be used instead on receipt or ship date for exception
     ---------------------------------------------------------------------------------*/
FROM  msc_sup_dem_entries sd1,
   msc_sup_dem_entries sd2
WHERE sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND   sd1.publisher_id = p_supplier_id
AND   sd1.publisher_site_id = p_supplier_site_id
AND   sd1.inventory_item_id = p_item_id
AND   sd1.publisher_order_type = msc_x_netting_pkg.ASN
AND   sd1.end_order_number = p_order_number
AND   nvl(sd1.end_order_rel_number,-1) = nvl(p_release_number, -1)
AND   nvl(sd1.end_order_line_number, -1) = nvl(p_line_number, -1)
AND   sd2.plan_id = sd1.plan_id
AND   sd2.publisher_id = sd1.customer_id
AND   sd2.publisher_site_id = sd1.customer_site_id
AND   sd2.publisher_order_type = msc_x_netting_pkg.SHIPMENT_RECEIPT
AND   sd2.end_order_number = sd1.order_number
AND   nvl(sd2.end_order_rel_number,-1) = nvl(sd1.release_number, -1)
AND   nvl(sd2.end_order_line_number, -1) = nvl(sd1.line_number, -1)
AND   trunc(sd2.key_date) between
      add_months(trunc(sysdate),-3) and trunc(sysdate);

/*-----------------------------------------------------------------------
 | PO -> SHIPMENT RECEIPT:
 | case2: the pegging is PO -> SO -> ASN and PO -> SHIPMENT_RECEIPT or
 | case4:           PO -> SO and PO -> ASN and PO -> SHIPMENT RECEIPT
 -----------------------------------------------------------------------*/

CURSOR receipt3_cur (p_publisher_id in number,
      p_publisher_site_id in number,
      p_item_id in number,
      p_order_number in Varchar2,
      p_release_number in Varchar2,
      p_line_number in Varchar2) IS
SELECT   sd1.key_date		--sd1.ship_date     --sd2.new_schedule_date
				-- the load also populate the ship date; therefore
            			--use ship date to compare
    /*-----------------------------------------------------------------------------
      Note: in release 11.5.10, a shipping control context will be honored
      for all relevant transactions in CP.  The impact will be on PO/SO/ASN/shipment receipt
   	Therefore, the key_date will be used instead on receipt or ship date for exception
     ---------------------------------------------------------------------------------*/

FROM  msc_sup_dem_entries sd1
WHERE sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND   sd1.publisher_id = p_publisher_id
AND   sd1.publisher_site_id = p_publisher_site_id
AND   sd1.inventory_item_id = p_item_id
AND   sd1.publisher_order_type = msc_x_netting_pkg.SHIPMENT_RECEIPT
AND   sd1.end_order_number = p_order_number
AND   nvl(sd1.end_order_rel_number,-1) = nvl(p_release_number, -1)
AND   nvl(sd1.end_order_line_number, -1) = nvl(p_line_number, -1)
AND   sd1.end_order_publisher_id = p_publisher_id
AND   trunc(sd1.key_date) between
      add_months(trunc(sysdate),-3) and trunc(sysdate);



----------------------------------------------------------------------
-- Inventory Turn
-- 10.9 Inventory turns below threshold: exception_45
-- 10.10 Customer inventory turns below threshold: exception_46
----------------------------------------------------------------------
CURSOR exception_45_46 IS     --need distinct because it will sum up the hs
SELECT  distinct sd.publisher_id,
        sd.publisher_name,
        sd.publisher_site_id,
        sd.publisher_site_name,
        sd.inventory_item_id,
        sd.item_name,
        sd.item_description,
        sd.customer_item_name,
        sd.supplier_id,
        sd.supplier_name,
        sd.supplier_site_id,
        sd.supplier_site_name,
        sd.supplier_item_name,
        sd.supplier_item_description
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type = msc_x_netting_pkg.HISTORICAL_SALES
AND   trunc(sd.key_date) between
      add_months(trunc(sysdate), -3)and trunc(sysdate);

/* replace new_schedule_date to key_date (performance) */
--------------------------------------------------------------------------
-- Stock Out
-- 10.3 Supplier has exceeded a stock out threshold: exception_47
-- 10.4 You have exceeded a stock out threshold: exception_48
------------------------------------------------------------------------
--find out when the onhand hit 0, then count the number of stock out
--if it reaches the threshold, raise the exceptions
--The threshold is in number not in percentage.
CURSOR exception_47_48 IS
SELECT  distinct
   sd2.publisher_id,
        sd1.publisher_name,
        sd2.publisher_site_id,
        sd1.publisher_site_name,
        sd2.inventory_item_id,
        sd1.item_name,
        sd1.item_description,
        sd2.customer_item_name,
        sd2.supplier_id,
        sd1.supplier_name,
        sd2.supplier_site_id,
        sd1.supplier_site_name,
        sd1.supplier_item_name,
        sd1.supplier_item_description
FROM    msc_sup_dem_history sd1,
   msc_sup_dem_entries sd2,
   msc_item_suppliers itm,
   msc_trading_partners part,
   msc_trading_partner_maps map
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.publisher_order_type = msc_x_netting_pkg.ALLOCATED_ONHAND
AND   sd1.item_name is not null
AND   sd1.quantity_new = 0
AND   sd1.quantity_new <> sd1.quantity_old
AND   sd2.plan_id = sd1.plan_id
AND   sd2.publisher_order_type = sd1.publisher_order_type
AND   sd2.item_name = sd1.item_name
AND   sd2.publisher_name = sd1.publisher_name
AND   sd2.publisher_site_name = sd1.publisher_site_name
AND   sd2.supplier_name = sd1.supplier_name
AND   sd2.supplier_site_name = sd1.supplier_site_name
AND   sd2.new_schedule_date = sd1.new_schedule_date_new
AND   map.map_type = 2
AND   map.company_key = sd2.publisher_site_id
AND   map.tp_key = part.partner_id
AND   itm.plan_id = sd1.plan_id
AND   itm.sr_instance_id = part.sr_instance_id
AND   itm.organization_id = part.sr_tp_id
AND   itm.inventory_item_id = sd2.inventory_item_id
AND   itm.supplier_id = NVL(sd2.supplier_id, itm.supplier_id)
AND   itm.supplier_site_id = NVL(sd2.supplier_site_id, itm.supplier_site_id)
AND   itm.vmi_flag = 1
AND   trunc(sd1.new_schedule_date_new) between
      add_months(trunc(sysdate), -3)and trunc(sysdate);



--======================================================================
--COMPUTE_CHANGED_ORDER
--======================================================================
PROCEDURE COMPUTE_CHANGED_ORDER (p_refresh_number IN Number,
   t_company_list       IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_company_site_list  IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_customer_list   IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_customer_site_list    IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_supplier_list   IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_supplier_site_list    IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
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
   a_customer_item_name IN OUT NOCOPY msc_x_netting_pkg.itemnameList,
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



CURSOR archive_order_c(p_refresh_number in number,
				p_type in number) IS
select  distinct sd.transaction_id,
   sd.publisher_id,
   sd.publisher_site_id,
   sd.inventory_item_id,
   sd.supplier_id,
   sd.supplier_site_id
from  msc_sup_dem_entries sd,
   msc_x_exception_details dt
where    sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
and   sd.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND     nvl(sd.last_refresh_number,-1) > nvl(p_refresh_number,-1)
and   dt.plan_id = sd.plan_id
and   dt.company_id = sd.supplier_id
and   dt.company_site_id = sd.supplier_site_id
and   dt.inventory_item_id = sd.inventory_item_id
and   dt.customer_id = sd.publisher_id
and   dt.customer_site_id = sd.publisher_site_id
and   dt.order_number = sd.order_number
and   dt.line_number = sd.line_number
and   dt.release_number = sd.release_number
and   dt.transaction_id1 = sd.transaction_id
and   dt.exception_type = p_type
and   dt.version is null;

CURSOR rescheduled_order_exist (p_supplier_id in number,
      p_supplier_site_id in number,
      p_item_id in number,
      p_order_number in Varchar2) IS
SELECT ed.exception_detail_id
FROM msc_x_exception_details ed
WHERE ed.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND ed.inventory_item_id = p_item_id
AND ed.company_id = p_supplier_id
AND ed.company_site_id = p_supplier_site_id
AND ed.exception_type = 34
AND ed.order_number = p_order_number;


CURSOR archive_rejected_order (p_refresh_number in number,
				p_type in number) IS
select  distinct sd.transaction_id,
   sd.publisher_id,
   sd.publisher_site_id,
   sd.inventory_item_id,
   sd.supplier_id,
   sd.supplier_site_id
from  msc_sup_dem_entries sd,
   msc_x_exception_details dt
where    sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
and   sd.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND     nvl(sd.last_refresh_number,-1) > nvl(p_refresh_number,-1)
and   dt.plan_id = sd.plan_id
and   dt.company_id = sd.publisher_id
and   dt.company_site_id = sd.publisher_site_id
and   dt.inventory_item_id = sd.inventory_item_id
and   dt.supplier_id = sd.supplier_id
and   dt.supplier_site_id = sd.supplier_site_id
and   dt.order_number = sd.order_number
and   dt.line_number = sd.line_number
and   dt.release_number = sd.release_number
and   dt.transaction_id1 = sd.transaction_id
and   dt.exception_type = p_type
and   dt.version is null;


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

  b_history_id       		msc_x_netting_pkg.number_arr;
  b_key_date			msc_x_netting_pkg.date_arr;
  b_ship_date			msc_x_netting_pkg.date_arr;
  b_receipt_date     		msc_x_netting_pkg.date_arr;
  b_receipt_date_new    	msc_x_netting_pkg.date_arr;
  b_receipt_date_old    	msc_x_netting_pkg.date_arr;
  b_po_creation_date    	msc_x_netting_pkg.date_arr;
  b_po_last_update_date		msc_x_netting_pkg.date_arr;
  b_cancelled_date      	msc_x_netting_pkg.date_arr;
  b_date1         		msc_x_netting_pkg.date_arr;
  b_date2         		msc_x_netting_pkg.date_arr;
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
  b_customer_site_name    	msc_x_netting_pkg.custsiteList;
  b_customer_item_name     	msc_x_netting_pkg.itemnameList;
  b_customer_item_desc     	msc_x_netting_pkg.itemdescList;
  b_order_number     		msc_x_netting_pkg.ordernumberList;
  b_release_number      	msc_x_netting_pkg.releasenumList;
  b_line_number      		msc_x_netting_pkg.linenumList;
  b_end_order_number       	msc_x_netting_pkg.ordernumberList;
  b_end_order_rel_number   	msc_x_netting_pkg.releasenumList;
  b_end_order_line_number  	msc_x_netting_pkg.linenumList;

 l_reschedule_date      	date;
 l_old_history_id    		Number;
 l_exception_count         	Number;
 l_exception_type          	Number;
 l_exception_group         	Number;
 l_exception_type_name     	fnd_lookup_values.meaning%type;
 l_exception_group_name    	fnd_lookup_values.meaning%type;
 l_row            		Number := 0;
 l_exception_detail_id     	Number;
 l_item_type Varchar2(20) := 'MSCSNDNT';
 l_item_key Varchar2(100) := null;


 l_type				Number;
 l_group			Number;
 l_item_id			Number;
 l_publisher_id			Number;
 l_publisher_site_id		Number;
 l_supplier_id			Number;
 l_supplier_site_id		Number;
 l_trx_id1			Number;
 l_shipping_control		Number;
 l_exception_basis		msc_x_exception_details.exception_basis%type;
 l_inserted_record		Number := 0;

BEGIN



--------------------------------------------------------------
--Need to clean up the existing exceptions before regenerate
--new exception or the criteria is already satisfied.
--This query is for canceled order
--------------------------------------------------------------
 OPEN archive_order_c(p_refresh_number, msc_x_netting_pkg.G_EXCEP33);
      fetch archive_order_c BULK COLLECT INTO
            b_trx_id1,
            b_publisher_id,
            b_publisher_site_id,
            b_item_id,
            b_supplier_id,
            b_supplier_site_id;
 CLOSE archive_order_c;

 IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
 FOR j in 1..b_trx_id1.COUNT
 LOOP

   --======================================================
      -- archive old exception
   --=====================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_CHANGED_ORDER,
      msc_x_netting_pkg.G_EXCEP33,
      b_trx_id1(j),
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
  END LOOP;
  END IF;


--dbms_output.put_line('Exception 33');

open exception_33(p_refresh_number);
   fetch exception_33 BULK COLLECT INTO
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
         b_key_date,
         b_ship_date,
         b_receipt_date,
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
         b_cancelled_date;
CLOSE exception_33;

IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
FOR j in 1..b_trx_id1.COUNT
LOOP
   --dbms_output.put_line('Exception 33 ' || b_trx_id1(j));
   /*-----------------------------------------------------------------
   | There is no option for the user to delete this type of
   | exception when the exception is viewed.
   | Delete the exception if it is 1 months old (30 days).
   ------------------------------------------------------------------*/
begin
   delete msc_x_exception_details
   where plan_id = msc_x_netting_pkg.G_PLAN_ID
   and exception_type = 33
   and exception_group = msc_x_netting_pkg.G_CHANGED_ORDER
   and company_id = b_supplier_id(j)
   and company_site_id = b_supplier_site_id(j)
   and inventory_item_id = b_item_id(j)
   and trunc(creation_date ) < trunc(sysdate) - 30;

   l_row := SQL%ROWCOUNT;
   ----dbms_output.put_line('detail row delete ' || l_row);

   update msc_item_exceptions
   set exception_count = exception_count - l_row,
      last_update_date = sysdate
   where plan_id = msc_x_netting_pkg.G_PLAN_ID
   and exception_type = 33
   and exception_group = msc_x_netting_pkg.G_CHANGED_ORDER
   and company_id = b_supplier_id(j)
   and company_site_id = b_supplier_site_id(j)
   and inventory_item_id = b_item_id(j)
   and version = 0;
exception
   when others then
   null;
end;

   --------------------------------------------------------------------------
   -- get the shipping control
   ---------------------------------------------------------------------------
   l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                    b_publisher_site_name(j),
                                    b_supplier_name(j),
                                    b_supplier_site_name(j));

   l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

   l_exception_type := msc_x_netting_pkg.G_EXCEP33;   -- cancelled order
   l_exception_group := msc_x_netting_pkg.G_CHANGED_ORDER;
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
               	b_trx_id1(j),
               	null,    --l_trx_id2,
               	b_publisher_id(j),
               	b_publisher_name(j),
               	b_publisher_site_id(j),
               	b_publisher_site_name(j),
               	b_customer_item_name(j),
               	null, --l_supplier_id,
               	null, --l_supplier_name,
               	null, --l_supplier_site_id,
               	null, --l_supplier_site_name,
               	b_supplier_item_name(j),
               	b_tp_po_qty(j),      --#1
               	null,       --#2
               	b_tp_po_qty(j),      --#3
               	null,       --threshold
               	null,       --lead time
            	null,       --l_item_min,
            	null,       --l_item_max,
            	b_order_number(j),
            	b_release_number(j),
            	b_line_number(j),
            	null,    --l_end_order_number,
            	null,    --l_end_order_rel_number,
            	null,    --l_end_order_line_number,
                null,
                null,
            	b_cancelled_date(j),
            	b_receipt_date(j),
                null,
                null,
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
END LOOP;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(33) ||
      ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

---------------------------------------------------------------------
-- This is required  purge all the zero qty entries for order execution entities
-- The following exception_34 will be wrong if the transaction with quantity = 0
-- is not deleted.
---------------------------------------------------------------------
msc_x_netting_pkg.Purge_Zqty_Exec_Order(p_refresh_number);

--------------------------------------------------------------
--Need to clean up the existing exceptions before regenerate
--new exception or the criteria is already satisfied.
--This query is for rescheduled order
--------------------------------------------------------------
 OPEN archive_order_c(p_refresh_number, msc_x_netting_pkg.G_EXCEP34);
      fetch archive_order_c BULK COLLECT INTO
            b_trx_id1,
            b_publisher_id,
            b_publisher_site_id,
            b_item_id,
            b_supplier_id,
            b_supplier_site_id;
 CLOSE archive_order_c;

 IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
 FOR j in 1..b_trx_id1.COUNT
 LOOP

   --======================================================
      -- archive old exception
   --=====================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_CHANGED_ORDER,
      msc_x_netting_pkg.G_EXCEP34,
      b_trx_id1(j),
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
  END LOOP;
END IF;

--dbms_output.put_line('Exception 34');
open exception_34(p_refresh_number);
   fetch exception_34 BULK COLLECT INTO
      	b_trx_id1,
      	b_history_id,
      	b_publisher_id,
         b_publisher_name,
         b_publisher_site_id,
         b_publisher_site_name,
         b_item_id,
         b_item_name,
         b_item_desc,
         b_customer_item_name,
         b_customer_item_desc,
         b_posting_po_qty,
         b_po_qty,
         b_tp_po_qty,
         b_supplier_id,
         b_supplier_name,
         b_supplier_site_id,
         b_supplier_site_name,
         b_supplier_item_name,
         b_supplier_item_desc,
         b_order_number,
         b_release_number,
         b_line_number,
         b_receipt_date,
         b_receipt_date_new,
         b_receipt_date_old;
 CLOSE exception_34;


 IF (b_item_id is not null and b_item_id.COUNT > 0) THEN

 FOR j in 1..b_item_id.COUNT
 LOOP

   --------------------------------------------------------------------------
   -- get the shipping control
   ---------------------------------------------------------------------------
   l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                     b_publisher_site_name(j),
                                     b_supplier_name(j),
                                     b_supplier_site_name(j));

   l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

   l_exception_type := msc_x_netting_pkg.G_EXCEP34;  -- rescheduled order
   l_exception_group := msc_x_netting_pkg.G_CHANGED_ORDER;
   l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
   l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

        IF (trunc(b_receipt_date(j)) <> trunc(b_receipt_date_new(j))) THEN
                l_reschedule_date := b_receipt_date_new(j);
        ELSIF (trunc(b_receipt_date(j)) = trunc(b_receipt_date_new(j)) and
               trunc(b_receipt_date_new(j)) <> trunc(b_receipt_date_old(j))) THEN
               l_reschedule_date := b_receipt_date_old(j);
        END IF;

   l_exception_detail_id := 0;
   open rescheduled_order_exist (b_supplier_id(j),
         b_supplier_site_id(j),
         b_item_id(j),
         b_order_number(j));
   fetch rescheduled_order_exist into l_exception_detail_id;
   close rescheduled_order_exist;


   IF (l_exception_detail_id = 0 ) THEN

      l_exception_detail_id := msc_x_netting_pkg.does_detail_excep_exist(b_supplier_id(j),
                          	b_supplier_site_id(j),
                          	b_item_id(j),
                          	l_exception_type,
                     		b_trx_id1(j));
   END IF;

   IF (l_exception_detail_id > 0) THEN  --detail already exist

           begin
      		select number3
      		into   l_old_history_id
      		from   msc_x_exception_details
      		where  exception_detail_id = l_exception_detail_id;
      		exception
           when others then
              l_old_history_id := 0;
      	   end;

      	   IF (l_old_history_id < b_history_id(j) ) THEN
	     --fix to update the LAST_UPDATED_BY , check this in  MSC_SCE_LOADS_PKG when trying to delete the record...
              update msc_x_exception_details
               set    number3 = b_history_id(j),
                      date1 = b_receipt_date(j),
                      date2 = l_reschedule_date,
		      number1 = b_po_qty(j),--updating the date entered by the user in the exception
		      number2 = b_po_qty(j),
		      LAST_UPDATE_LOGIN=-99
               where  exception_detail_id = l_exception_detail_id;

	       l_inserted_record := l_inserted_record + 1;--updating the count of the records that are shown in the log.

           END IF;

    ELSIF (l_exception_detail_id = 0 and ( j> 1 and b_trx_id1(j) <> b_trx_id1(j-1)) or (j = 1)) THEN
	--dbms_output.put_line('Generate reschedule order ');
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
             	b_trx_id1(j),
          	null,       --l_trx_id2,
            	b_publisher_id(j),
             	b_publisher_name(j),
            	b_publisher_site_id(j),
              	b_publisher_site_name(j),
             	b_customer_item_name(j),
             	null, --l_supplier_id,
             	null, --l_supplier_name,
              	null, --l_supplier_site_id,
         	null, --l_supplier_site_name,
             	b_supplier_item_name(j),
           	b_tp_po_qty(j),      --number1
            	b_tp_po_qty(j),      --number2
            	b_history_id(j),     --number3
          	null,    --threshold
           	null,       --lead time
            	null,       --l_item_min,
            	null,       --l_item_max,
        	b_order_number(j),
           	b_release_number(j),
            	b_line_number(j),
            	null,       --l_end_order_number,
            	null,       --l_end_order_rel_number,
            	null,       --l_end_order_line_number,
                null,
                null,
             	b_receipt_date(j),
          	l_reschedule_date,      --l_ship_date,
                null,
                null,
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
         END IF;

END LOOP;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(34) ||
      ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));


---------------------------------------------------------------------------
-- Ecxeption_49 -> 8.3  Purchase order has been rejected (bug# 2761469)
-- The supplier rejects the PO in ISP, if the buyer sees that, then the buyer
-- may look for different supplier.  The buyer then may close the PO.
-- Normally, if the supplier rejects a PO, then will not accept this later on,
-- because the buyer may take the action already.
---------------------------------------------------------------------------

--------------------------------------------------------------
--Need to clean up the existing exceptions before regenerate
--new exception or the criteria is already satisfied.
--This query is for rescheduled order
--------------------------------------------------------------
OPEN archive_rejected_order(p_refresh_number, msc_x_netting_pkg.G_EXCEP49);
      fetch archive_rejected_order BULK COLLECT INTO
            b_trx_id1,
            b_publisher_id,
            b_publisher_site_id,
            b_item_id,
            b_supplier_id,
            b_supplier_site_id;
 CLOSE archive_rejected_order;

 IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
 FOR j in 1..b_trx_id1.COUNT
 LOOP

   --======================================================
      -- archive old exception
   --=====================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_item_id(j),
      msc_x_netting_pkg.G_CHANGED_ORDER,
      msc_x_netting_pkg.G_EXCEP49,
      b_trx_id1(j),
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

  END LOOP;
END IF;

--dbms_output.put_line('Exception 49');

 open exception_49(p_refresh_number);
      fetch exception_49 BULK COLLECT INTO
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
           	b_key_date,
           	b_ship_date,
          	b_receipt_date,
              	b_posting_po_qty,
             	b_po_qty,
               	b_tp_po_qty,
               	b_order_number,
             	b_release_number,
            	b_line_number,
          	b_supplier_id,                  --so org
            	b_supplier_name,
             	b_supplier_site_id,
          	b_supplier_site_name,
       		b_supplier_item_name,
            	b_supplier_item_desc,
            	b_po_creation_date,
           	b_po_last_update_date;
  CLOSE exception_49;

  -----------------------------------------------------------------------
  -- exception 8.3 (customer centric)
  -----------------------------------------------------------------------
  IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
  FOR j in 1..b_trx_id1.COUNT
  LOOP

     --------------------------------------------------------------------------
     -- get the shipping control
     ---------------------------------------------------------------------------
     l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                    b_publisher_site_name(j),
                                    b_supplier_name(j),
                                    b_supplier_site_name(j));

     l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

     	l_exception_type := msc_x_netting_pkg.G_EXCEP49; -- PO has been rejected
   	l_exception_group := msc_x_netting_pkg.G_CHANGED_ORDER;
   	l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
   	l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

       --======================================================
        -- archive response required exceptions
	--bug# 2761469
	--If the po (line) got rejected by the ISP, check
	--if this po (line) has any response required exceptions
	--generated.  If so, remove them
        --======================================================

     msc_x_netting_pkg.add_to_delete_tbl(
        b_supplier_id(j),
        b_supplier_site_id(j),
        b_publisher_id(j),
        b_publisher_site_id(j),
        null,
        null,
        b_item_id(j),
        msc_x_netting_pkg.G_RESPONSE_REQUIRED,
        msc_x_netting_pkg.G_EXCEP11,
        b_trx_id1(j),
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


     msc_x_netting_pkg.add_to_delete_tbl(
        b_publisher_id(j),
        b_publisher_site_id(j),
        null,
        null,
        b_supplier_id(j),
        b_supplier_site_id(j),
        b_item_id(j),
        msc_x_netting_pkg.G_RESPONSE_REQUIRED,
        msc_x_netting_pkg.G_EXCEP31,
        b_trx_id1(j),
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
             	null,                   --l_trx_id2,
             	null,                   --l_customer_id,
             	null,
             	null,                   --l_customer_site_id,
             	null,
             	b_customer_item_name(j),
             	b_supplier_id(j),
             	b_supplier_name(j),
             	b_supplier_site_id(j),
             	b_supplier_site_name(j),
             	b_supplier_item_name(j),
             	b_po_qty(j),
             	null,
             	null,
             	null,
             	null,
            	null,       --l_item_min,
            	null,       --l_item_max,
            	b_order_number(j),
            	b_release_number(j),
            	b_line_number(j),
            	null,                   --l_end_order_number,
            	null,                   --l_end_order_rel_number,
            	null,                   --l_end_order_line_number,
                b_po_creation_date(j),
                null,
            	b_receipt_date(j),
            	b_po_last_update_date(j),
                null,
                null,
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
  END LOOP;
 END IF;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(49) ||
               ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total exceptions inserted for the group ' ||
 msc_x_netting_pkg.get_message_group(msc_x_netting_pkg.G_CHANGED_ORDER) || ':' || l_inserted_record);


-- added exception handler
EXCEPTION
   WHEN OTHERS THEN
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING4_PKG.compute_changed_order');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);

END compute_changed_order;

--==================================================================================
-- COMPUTE_FORECAST_ACCURACY
--==================================================================================
PROCEDURE COMPUTE_FORECAST_ACCURACY (
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
   a_customer_item_name IN OUT NOCOPY msc_x_netting_pkg.itemnameList,
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
  b_publisher_id     	   	msc_x_netting_pkg.number_arr;
  b_publisher_site_id      	msc_x_netting_pkg.number_arr;
  b_item_id                	msc_x_netting_pkg.number_arr;
  b_po_qty                 	msc_x_netting_pkg.number_arr;
  b_so_qty                 	msc_x_netting_pkg.number_arr;
  b_tp_po_qty        		msc_x_netting_pkg.number_arr;
  b_tp_so_qty        		msc_x_netting_pkg.number_arr;
  b_posting_po_qty   	   	msc_x_netting_pkg.number_arr;
  b_posting_so_qty      	msc_x_netting_pkg.number_arr;
  b_customer_id         	msc_x_netting_pkg.number_arr;
  b_customer_site_id    	msc_x_netting_pkg.number_arr;
  b_supplier_id         	msc_x_netting_pkg.number_arr;
  b_supplier_site_id    	msc_x_netting_pkg.number_arr;
  b_po_last_refnum      	msc_x_netting_pkg.number_arr;
  b_so_last_refnum      	msc_x_netting_pkg.number_arr;
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


l_exception_type           	Number;
l_exception_group          	Number;
l_exception_type_name      	fnd_lookup_values.meaning%type;
l_exception_group_name     	fnd_lookup_values.meaning%type;
l_threshold1            	Number := 0;
l_threshold2      		Number := 0;
l_shipping_control		Number;
l_exception_basis		msc_x_exception_details.exception_basis%type;

l_posting_forecast      	Number;
l_forecast        		Number;
l_tp_forecast        		Number;
l_total_forecast     		Number;
l_posting_total_forecast   	Number;
l_posting_total_hs      	Number;
l_tp_total_forecast     	Number;
l_posting_historical_sales 	Number;
l_historical_sales      	Number;
l_tp_historical_sales      	Number;
l_p_total_historical_sales 	Number;
l_total_historical_sales   	Number;
l_tp_total_historical_sales   	Number;
l_posting_total_po      	Number;
l_total_po        		Number;
l_tp_total_po        		Number;
l_posting_total_onhand  	Number;
l_total_onhand       		Number;
l_tp_total_onhand    		Number;
l_initial_ship_qty      	Number;
l_tp_initial_ship_qty   	Number;
l_num_line     			Number;
l_fulfill      			Number;
l_flag         			Boolean;
l_sum_po_qty      		Number;
l_tp_sum_po_qty      		Number;
l_posting_sum_ship_qty  	Number;
l_sum_ship_qty    		Number;
l_tp_sum_ship_qty 		Number;
l_date         			Date;
l_last_3_month    		Date;
l_stock_out    			Number;
l_tp_stock_out    		Number;
l_vmi_item_found  		boolean;
l_partner_site_id 		Number;
l_sr_instance_id  		Number;
l_row       			number;
i        			Number;
l_item_type       		Varchar2(20) := 'MSCSNDNT';
l_item_key     			Varchar2(100) := null;
l_inserted_record		Number := 0;

BEGIN

------------------------------------------------------------------
 -- archive the cpfr exceptions first before recompute
 ------------------------------------------------------------------

 delete msc_x_exception_details
 where   plan_id = msc_x_netting_pkg.G_PLAN_ID
 and  exception_type in (35,36);

 update msc_item_exceptions
 set  version = version + 1,
   last_update_date = sysdate
 where   plan_id = msc_x_netting_pkg.G_PLAN_ID
 and  exception_type in (35,36);


 l_item_key :=    to_char(msc_x_netting_pkg.G_FORECAST_ACCURACY) || '-' ||
         to_char(msc_x_netting_pkg.G_EXCEP35) || '-' || '%';
 msc_x_netting_pkg.delete_wf_notification(l_item_type, l_item_key);


 l_item_key :=    to_char(msc_x_netting_pkg.G_FORECAST_ACCURACY) || '-' ||
         to_char(msc_x_netting_pkg.G_EXCEP36) || '-' || '%';
 msc_x_netting_pkg.delete_wf_notification(l_item_type, l_item_key);

--dbms_output.put_line('Exception 35 and 36');
open exception_35_36;
      fetch exception_35_36 BULK COLLECT INTO
         	b_publisher_id,
         	b_publisher_name,
         	b_publisher_site_id,
         	b_publisher_site_name,
         	b_item_id,
         	b_item_name,
         	b_item_desc,
         	b_customer_item_name,
               	b_supplier_id,
               	b_supplier_name,
               	b_supplier_site_id,
               	b_supplier_site_name,
                b_supplier_item_name,
                b_supplier_item_desc;
CLOSE exception_35_36;
IF (b_item_id is not null and b_item_id.COUNT > 0) THEN
FOR j in 1..b_item_id.COUNT
LOOP
   -- exception 35 supplier centric

   --------------------------------------------------------------------------
   -- get the shipping control
   ---------------------------------------------------------------------------
   l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                    b_publisher_site_name(j),
                                    b_supplier_name(j),
                                    b_supplier_site_name(j));

   l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

   l_threshold1 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP35,
                  	b_supplier_id(j),
               		b_supplier_site_id(j),
               		b_item_id(j),
            		null,
            		null,
            		b_publisher_id(j),
            		b_publisher_site_id(j),
                     	null);
        -- exception 36 customer centric
   l_threshold2 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP36,
               		b_publisher_id(j),
               		b_publisher_site_id(j),
               		b_item_id(j),
               		b_supplier_id(j),
               		b_supplier_site_id(j),
               		null,
               		null,
               		null);


         select  nvl(sum(sd.primary_quantity),0),
            nvl(sum(sd.tp_quantity),0),
            nvl(sum(sd.quantity),0)
         into  l_total_historical_sales,
            l_tp_total_historical_sales,
            l_p_total_historical_sales
         from  msc_sup_dem_entries sd
         where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
         and   sd.publisher_id = b_publisher_id(j)
         and   sd.publisher_site_id = b_publisher_site_id(j)
         and   sd.inventory_item_id = b_item_id(j)
         and   sd.publisher_order_type = msc_x_netting_pkg.HISTORICAL_SALES
         and   sd.supplier_id = b_supplier_id(j)
         and   sd.supplier_site_id = b_supplier_site_id(j)
         and   sd.customer_id = sd.publisher_id
         and   sd.customer_site_id = sd.publisher_site_id
         and   trunc(sd.new_schedule_date) between
            add_months(trunc(sysdate),-3) and trunc(sysdate);

         select nvl(sum(sd.primary_quantity),0),
            nvl(sum(sd.tp_quantity),0),
            nvl(sum(sd.quantity),0)
   into  l_total_forecast, l_tp_total_forecast, l_posting_total_forecast
   from  msc_sup_dem_entries sd
   where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
   and   sd.publisher_id = b_publisher_id(j)
   and   sd.publisher_site_id = b_publisher_site_id(j)
   and   sd.inventory_item_id = b_item_id(j)
   and   sd.publisher_order_type = msc_x_netting_pkg.SALES_FORECAST
   and   sd.supplier_id = b_supplier_id(j)
   and   sd.supplier_site_id = b_supplier_site_id(j)
   and   sd.customer_id = sd.publisher_id
   and   sd.customer_site_id = sd.publisher_site_id
   and   trunc(sd.key_date) between
            add_months(trunc(sysdate),-3) and trunc(sysdate);

         IF (l_tp_total_forecast > 0) and (l_tp_total_historical_sales > 0) and
            (1- l_tp_total_historical_sales/l_tp_total_forecast) > l_threshold1/100 THEN

            l_exception_type := msc_x_netting_pkg.G_EXCEP35;
      l_exception_group := msc_x_netting_pkg.G_FORECAST_ACCURACY;
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
            null,       --l_trx_id1,
            null,                   --l_trx_id2,
            b_publisher_id(j),
            b_publisher_name(j),
            b_publisher_site_id(j),
            b_publisher_site_name(j),
            b_customer_item_name(j),
            null,                   --l_supplier_id
            null,
            null,                   --l_supplier_site_id
            null,
            b_supplier_item_name(j),
            l_tp_total_historical_sales,
            l_tp_total_forecast,
            null,
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
            null,
            null,
            add_months(sysdate,-3), --l_actual_date or bucket start date,
            sysdate,                --l_tp_actual_date or bucket end date,
            null,
            null,
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

        END IF;
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(35) || ':' || sysdate);
   IF (l_total_forecast > 0) and (l_total_historical_sales > 0 ) and
            (1- l_total_historical_sales/l_total_forecast) > l_threshold2/100 THEN
      l_exception_type := msc_x_netting_pkg.G_EXCEP36;
      l_exception_group := msc_x_netting_pkg.G_FORECAST_ACCURACY;
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
         null,       --l_trx_id1,
         null,                   --l_trx_id2,
         null,       --l_customer_id,
         null,       --l_customer_name,
         null,       --l_customer_site_id,
         null,       --l_customer_site_name,
         b_customer_item_name(j),
         b_supplier_id(j),
         b_supplier_name(j),
         b_supplier_site_id(j),
         b_supplier_site_name(j),
         b_supplier_item_name(j),
         l_total_historical_sales,
         l_total_forecast,
         null,
         l_threshold2,
         null,       --lead time
         null,       --item min
         null,       --item max
         null,       --l_order_number,
         null,       --l_release_number,
         null,       --l_line_number,
         null,                   --l_end_order_number,
         null,                   --l_end_order_rel_number,
         null,                   --l_end_order_line_number,
         null,
         null,
         add_months(sysdate,-3), --l_actual_date or bucket start date,
         sysdate,                --l_tp_actual_date or bucket end date,
         null,
         null,
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
      END IF;
END LOOP;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(36) ||
   ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total exceptions inserted for the group ' ||
 msc_x_netting_pkg.get_message_group(msc_x_netting_pkg.G_FORECAST_ACCURACY) || ':' || l_inserted_record);

-- added exception handler
EXCEPTION
   WHEN OTHERS THEN
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING4_PKG.compute_changed_order');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);

End Compute_forecast_accuracy;


--==================================================================================
-- COMPUTE_PERFORMANCE
--==================================================================================
PROCEDURE COMPUTE_PERFORMANCE (
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
   a_customer_item_name IN OUT NOCOPY msc_x_netting_pkg.itemnameList,
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
  b_publisher_id     	   	msc_x_netting_pkg.number_arr;
  b_publisher_site_id      	msc_x_netting_pkg.number_arr;
  b_item_id                	msc_x_netting_pkg.number_arr;
  b_po_qty                 	msc_x_netting_pkg.number_arr;
  b_so_qty                 	msc_x_netting_pkg.number_arr;
  b_tp_po_qty        		msc_x_netting_pkg.number_arr;
  b_tp_so_qty        		msc_x_netting_pkg.number_arr;
  b_posting_po_qty   		msc_x_netting_pkg.number_arr;
  b_posting_so_qty      	msc_x_netting_pkg.number_arr;
  b_customer_id         	msc_x_netting_pkg.number_arr;
  b_customer_site_id    	msc_x_netting_pkg.number_arr;
  b_supplier_id         	msc_x_netting_pkg.number_arr;
  b_supplier_site_id    	msc_x_netting_pkg.number_arr;
  b_po_last_refnum      	msc_x_netting_pkg.number_arr;
  b_so_last_refnum      	msc_x_netting_pkg.number_arr;
  b_po_receipt_date     	msc_x_netting_pkg.date_arr;
  b_so_receipt_date     	msc_x_netting_pkg.date_arr;
  b_po_ship_date     		msc_x_netting_pkg.date_arr;
  b_so_ship_date     		msc_x_netting_pkg.date_arr;
  b_po_creation_date 	     	msc_x_netting_pkg.date_arr;
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


l_threshold1               	Number := 0;
l_threshold2         		Number := 0;
l_exception_type           	Number;
l_exception_group          	Number;
l_exception_type_name      	fnd_lookup_values.meaning%type;
l_exception_group_name     	fnd_lookup_values.meaning%type;
l_shipping_control		Number;
l_exception_basis		msc_x_exception_details.exception_basis%type;

r_publisher_id       		msc_x_netting_pkg.number_arr;
r_publisher_site_id     	msc_x_netting_pkg.number_arr;
r_supplier_id        		msc_x_netting_pkg.number_arr;
r_supplier_site_id      	msc_x_netting_pkg.number_arr;
r_item_id         		msc_x_netting_pkg.number_arr;
r_po_qty       			msc_x_netting_pkg.number_arr;
r_tp_po_qty       		msc_x_netting_pkg.number_arr;
r_publisher_name     		msc_x_netting_pkg.publisherList;
r_publisher_site_name      	msc_x_netting_pkg.pubsiteList;
r_supplier_name         	msc_x_netting_pkg.supplierList;
r_supplier_site_name    	msc_x_netting_pkg.suppsiteList;
r_supplier_item_name    	msc_x_netting_pkg.itemnameList;
r_supplier_item_desc    	msc_x_netting_pkg.itemdescList;
r_item_name       		msc_x_netting_pkg.itemnameList;
r_item_desc       		msc_x_netting_pkg.itemdescList;
r_customer_item_name    	msc_x_netting_pkg.itemnameList;
r_receipt_date       		msc_x_netting_pkg.date_arr;
r_ship_date       		msc_x_netting_pkg.date_arr;
r_key_date       		msc_x_netting_pkg.date_arr;
r_order_number       		msc_x_netting_pkg.ordernumberList;
r_release_number     		msc_x_netting_pkg.releasenumList;
r_line_number        		msc_x_netting_pkg.linenumList;





l_posting_forecast      	Number;
l_forecast        		Number;
l_tp_forecast        		Number;
l_total_forecast     		Number;
l_posting_total_forecast   	Number;
l_posting_total_hs      	Number;
l_tp_total_forecast     	Number;
l_posting_historical_sales 	Number;
l_historical_sales      	Number;
l_tp_historical_sales      	Number;
l_p_total_historical_sales 	Number;
l_total_historical_sales   	Number;
l_tp_total_historical_sales   	Number;
l_posting_total_po      	Number;
l_total_po        		Number;
l_tp_total_po        		Number;
l_posting_total_onhand     	Number;
l_total_onhand       		Number;
l_tp_total_onhand    		Number;
l_initial_ship_qty      	Number;
l_tp_initial_ship_qty      	Number;
l_num_line     			Number;
l_fulfill      			Number;
l_flag         			Boolean;
l_sum_po_qty      		Number;
l_tp_sum_po_qty      		Number;
l_posting_sum_ship_qty  	Number;
l_sum_ship_qty    		Number;
l_tp_sum_ship_qty 		Number;
l_date         			Date;
l_last_3_month    		Date;
l_stock_out    			Number;
l_tp_stock_out    		Number;
l_vmi_item_found  		boolean;
l_partner_site_id 		Number;
l_sr_instance_id  		Number;
l_row       			number;
i        			Number;
l_item_type       		Varchar2(20) := 'MSCSNDNT';
l_item_key     			Varchar2(100) := null;
l_inserted_record 		Number := 0;

BEGIN

 ------------------------------------------------------------------
 -- archive the cpfr exceptions first before recompute
 ------------------------------------------------------------------

 delete msc_x_exception_details
 where   plan_id = msc_x_netting_pkg.G_PLAN_ID
 and  exception_type in (39,40,43,44,45,46,47,48);

 update msc_item_exceptions
 set  version = version + 1,
   last_update_date = sysdate
 where   plan_id = msc_x_netting_pkg.G_PLAN_ID
 and  exception_type in (39,40,43,44,45,46,47,48);


 l_item_key :=    to_char(msc_x_netting_pkg.G_PERFORMANCE) || '-' ||
         to_char(msc_x_netting_pkg.G_EXCEP39) || '-' ||'%';
 msc_x_netting_pkg.delete_wf_notification(l_item_type, l_item_key);


 l_item_key :=    to_char(msc_x_netting_pkg.G_PERFORMANCE) || '-' ||
         to_char(msc_x_netting_pkg.G_EXCEP40) || '-' || '%';
 msc_x_netting_pkg.delete_wf_notification(l_item_type, l_item_key);


 l_item_key :=    to_char(msc_x_netting_pkg.G_PERFORMANCE) || '-' ||
         to_char(msc_x_netting_pkg.G_EXCEP43) || '-' || '%';
 msc_x_netting_pkg.delete_wf_notification(l_item_type, l_item_key);


 l_item_key :=    to_char(msc_x_netting_pkg.G_PERFORMANCE) || '-' ||
         to_char(msc_x_netting_pkg.G_EXCEP44) || '-' || '%';
 msc_x_netting_pkg.delete_wf_notification(l_item_type, l_item_key);


 l_item_key :=    to_char(msc_x_netting_pkg.G_PERFORMANCE) || '-' ||
         to_char(msc_x_netting_pkg.G_EXCEP45) || '-' || '%';
 msc_x_netting_pkg.delete_wf_notification(l_item_type, l_item_key);


 l_item_key :=    to_char(msc_x_netting_pkg.G_PERFORMANCE) || '-' ||
         to_char(msc_x_netting_pkg.G_EXCEP46) || '-' || '%';
 msc_x_netting_pkg.delete_wf_notification(l_item_type, l_item_key);


 l_item_key :=    to_char(msc_x_netting_pkg.G_PERFORMANCE) || '-' ||
         to_char(msc_x_netting_pkg.G_EXCEP47) || '-' || '%';
 msc_x_netting_pkg.delete_wf_notification(l_item_type, l_item_key);


 l_item_key :=    to_char(msc_x_netting_pkg.G_PERFORMANCE) || '-' ||
         to_char(msc_x_netting_pkg.G_EXCEP48) || '-' || '%';
 msc_x_netting_pkg.delete_wf_notification(l_item_type, l_item_key);

/*-----------------------------------------------------
  9.3Customer order forecast exceeds actual orders
  9.4Order forecast exceeds actual orders
  Will not be supported in this releas
----------------------------------------------------- */

--dbms_output.put_line('Exception 39 and 40');

open exception_39_40;
      fetch exception_39_40 BULK COLLECT INTO
         	b_publisher_id,
         	b_publisher_name,
         	b_publisher_site_id,
         	b_publisher_site_name,
         	b_item_id,
         	b_item_name,
         	b_item_desc,
         	b_customer_item_name,
               	b_supplier_id,
               	b_supplier_name,
               	b_supplier_site_id,
               	b_supplier_site_name,
                b_supplier_item_name,
                b_supplier_item_desc;
 CLOSE exception_39_40;
 IF (b_item_id is not null and b_item_id.COUNT > 0) THEN
 FOR j in 1..b_item_id.COUNT
 LOOP

    --------------------------------------------------------------------------
    -- get the shipping control
    ---------------------------------------------------------------------------
    l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                     b_publisher_site_name(j),
                                     b_supplier_name(j),
                                     b_supplier_site_name(j));

    l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));
   -- exception 39 supplier centric

   l_threshold1 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP39,
                b_supplier_id(j),
               	b_supplier_site_id(j),
               	b_item_id(j),
            	null,
            	null,
            	b_publisher_id(j),
            	b_publisher_site_id(j),
                null);
        -- exception 39 customer centric
   l_threshold2 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP40,
              	b_publisher_id(j),
               	b_publisher_site_id(j),
                b_item_id(j),
               	b_supplier_id(j),
               	b_supplier_site_id(j),
               	null,
               	null,
               	null);


   l_total_forecast:= 0;
   l_tp_total_forecast := 0;
   l_total_historical_sales := 0;
   l_tp_total_historical_sales := 0;
   l_posting_total_forecast := 0;
   l_posting_total_hs := 0;

   i := 3;

   SELECT add_months(trunc(sysdate),-i) into l_date from dual;
   while i > 0
   loop

            select nvl(sum(sd.primary_quantity),0),
               nvl(sum(sd.tp_quantity),0),
               nvl(sum(sd.quantity),0)
            into  l_historical_sales, l_tp_historical_sales, l_posting_historical_sales
            from  msc_sup_dem_entries sd
            where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
            and   sd.publisher_id = b_publisher_id(j)
            and   sd.publisher_site_id = b_publisher_site_id(j)
            and   sd.inventory_item_id = b_item_id(j)
            and   sd.publisher_order_type = msc_x_netting_pkg.HISTORICAL_SALES
            and   sd.supplier_id = b_supplier_id(j)
            and   sd.supplier_site_id = b_supplier_site_id(j)
            and   sd.customer_id = sd.publisher_id
            and   sd.customer_site_id = sd.publisher_site_id
            and   trunc(sd.new_schedule_date) between trunc(l_date)
               and add_months(trunc(sysdate),-(i-1)) -1;

            select nvl(sum(sd.primary_quantity),0), nvl(sum(sd.tp_quantity),0),
               nvl(sum(sd.quantity),0)
      into  l_forecast, l_tp_forecast, l_posting_forecast
      from  msc_sup_dem_entries sd
      where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
      and   sd.publisher_id = b_publisher_id(j)
      and   sd.publisher_site_id = b_publisher_site_id(j)
      and   sd.inventory_item_id = b_item_id(j)
      and   sd.publisher_order_type = msc_x_netting_pkg.SALES_FORECAST
      and   sd.supplier_id = b_supplier_id(j)
      and   sd.supplier_site_id = b_supplier_site_id(j)
      and   sd.customer_id = sd.publisher_id
      and   sd.customer_site_id = sd.publisher_site_id
      and   trunc(sd.key_date) between trunc(l_date)
         and add_months(trunc(sysdate),-(i-1)) -1;

      l_total_forecast := l_total_forecast +
            abs(l_historical_sales - l_forecast);
      l_tp_total_forecast := l_tp_total_forecast +
            abs(l_tp_historical_sales - l_tp_forecast);
      l_total_historical_sales := l_total_historical_sales +
            abs(l_historical_sales);
      l_tp_total_historical_sales := l_tp_total_historical_sales +
            abs(l_tp_historical_sales);

      i := i -1;
      l_date := add_months(trunc(sysdate),-i);

      /*-------------------------------------------------------
       | calcuate for the original posting UOM_code and original qty
       --------------------------------------------------------------*/
       l_posting_total_forecast := l_posting_total_forecast +
         abs(l_posting_historical_sales - l_posting_forecast);
       l_posting_total_hs := l_posting_total_hs +
         abs(l_posting_historical_sales);

   end loop;

         IF (l_tp_total_historical_sales > 0) and (l_tp_total_forecast > 0 ) and
            (1/3 * l_tp_total_forecast) / (1/3 * l_tp_total_historical_sales) >
               l_threshold1/100 THEN

            l_exception_type := msc_x_netting_pkg.G_EXCEP39;   --your cust sales fcst accuracy for 3 month
      l_exception_group := msc_x_netting_pkg.G_PERFORMANCE;
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
         null,       --l_trx_id1,
         null,                   --l_trx_id2,
         b_publisher_id(j),
         b_publisher_name(j),
         b_publisher_site_id(j),
         b_publisher_site_name(j),
         b_customer_item_name(j),
         null,                   --l_supplier_id
         null,
         null,                   --l_supplier_site_id
         null,
         b_supplier_item_name(j),
         l_tp_total_forecast,
         l_tp_total_historical_sales,
         round((1/3 * l_tp_total_forecast) /(1/3 * l_tp_total_historical_sales),2) * 100,    --MAPE
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
         null,
         null,
         add_months(sysdate,-3), --l_actual_date or bucket start date,
         sysdate,                --l_tp_actual_date or bucket end date,
         null,
         null,
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

        END IF;
   IF (l_total_historical_sales > 0) and (l_total_forecast > 0) and
            (1/3 * l_total_forecast) / (1/3 * l_total_historical_sales) > l_threshold2/100 THEN
      l_exception_type := msc_x_netting_pkg.G_EXCEP40;   --your order fcst > hist sales for 3 months
      l_exception_group := msc_x_netting_pkg.G_PERFORMANCE;
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
         null,       --l_trx_id1,
         null,                   --l_trx_id2,
         null,       --l_customer_id,
         null,       --l_customer_name,
         null,       --l_customer_site_id,
         null,       --l_customer_site_name,
         b_customer_item_name(j),
         b_supplier_id(j),
         b_supplier_name(j),
         b_supplier_site_id(j),
         b_supplier_site_name(j),
         b_supplier_item_name(j),
         l_total_forecast,
         l_total_historical_sales,
         round((1/3 * l_total_forecast) / (1/3 * l_total_historical_sales),2) * 100, --MAPE,
         l_threshold2,
         null,       --lead time
         null,       --item min
         null,       --item max
         null,       --l_order_number,
         null,       --l_release_number,
         null,       --l_line_number,
         null,                   --l_end_order_number,
         null,                   --l_end_order_rel_number,
         null,                   --l_end_order_line_number,
         null,
         null,
         add_months(sysdate,-3), --l_actual_date or bucket start date,
         sysdate,                --l_tp_actual_date or bucket end date,
         null,
         null,
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

      END IF;
END LOOP;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(39) ||
      ',' || msc_x_netting_pkg.get_message_type(40) || ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));


----------------------------------------------------------------------
-- 10.7 supplier on-time delivery performance is below threshold
-- 10.8 on-time delivery performance is below threshold
---------------------------------------------------------------------

--dbms_output.put_line('Exception 43 and 44');
open exception_43_44;
   fetch exception_43_44 BULK COLLECT INTO
         	b_publisher_id,
         	b_publisher_site_id,
         	b_item_id,
               	b_supplier_id,
               	b_supplier_site_id;
CLOSE exception_43_44;
IF (b_item_id is not null and b_item_id.COUNT > 0) THEN
FOR j in 1..b_item_id.COUNT
LOOP

   -- exception 43 customer centric


   l_threshold1 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP43,
                  	b_publisher_id(j),
               		b_publisher_site_id(j),
               		b_item_id(j),
            		b_supplier_id(j),
            		b_supplier_site_id(j),
            		null,
            		null,
                     	null);
     -- exception 44 supplier centric
   l_threshold2 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP44,
                     	b_supplier_id(j),
                  	b_supplier_site_id(j),
                  	b_item_id(j),
               		null,
               		null,
               		b_publisher_id(j),
               		b_publisher_site_id(j),
                     	null);
   l_num_line := 0;
   l_fulfill := 0;
   l_flag := false;

   open po_line_cur (b_publisher_id(j),
         	b_publisher_site_id(j),
         	b_item_id(j));
      fetch po_line_cur BULK COLLECT INTO
         	r_publisher_id,
         	r_publisher_name,
         	r_publisher_site_id,
         	r_publisher_site_name,
         	r_item_id,
         	r_item_name,
         	r_item_desc,
         	r_customer_item_name,
         	r_key_date,
         	r_ship_date,
         	r_receipt_date,
         	r_po_qty,
         	r_tp_po_qty,
         	r_order_number,
      		r_release_number,
                r_line_number,
               	r_supplier_id,
               	r_supplier_name,
               	r_supplier_site_id,
               	r_supplier_site_name,
                r_supplier_item_name,
                r_supplier_item_desc;
   CLOSE po_line_cur;

   IF (r_publisher_id is not null and b_publisher_id.COUNT > 0) THEN
    FOR k in 1..r_publisher_id.COUNT
    LOOP
         l_flag := false;

         open receipt1_cur(r_supplier_id(k),
         r_supplier_site_id(k),
         r_item_id(k),
         r_order_number(k),
         r_release_number(k),
         r_line_number(k));
         loop
           fetch receipt1_cur into l_date;
           exit when receipt1_cur%NOTFOUND;
             l_num_line := l_num_line + 1;

             IF (l_date > r_ship_date(k)) THEN
             --dbms_output.put_line('Ship1 date ' || r_ship_date(k) || ' the date ' || l_date);
                l_flag := true;
                l_fulfill := l_fulfill + 1;
             ELSE
                l_fulfill := l_fulfill + 0;
             END IF;
         end loop;

         close receipt1_cur;

         IF (l_flag = false) THEN
         open receipt2_cur(r_supplier_id(k),
         r_supplier_site_id(k),
         r_item_id(k),
         r_order_number(k),
         r_release_number(k),
         r_line_number(k));
         loop
           fetch receipt2_cur into l_date;
           exit when receipt2_cur%NOTFOUND;
               l_num_line := l_num_line + 1;
           IF (l_date > r_ship_date(k)) THEN
           --dbms_output.put_line('Ship2 date ' || r_ship_date(k) || ' the date ' || l_date);
              l_flag := true;
              l_fulfill := l_fulfill + 1;
           ELSE
              l_fulfill := l_fulfill + 0;
           END IF;
         end loop;
         close receipt2_cur;
         END IF;

         IF (l_flag = false) THEN
            open receipt3_cur(r_supplier_id(k),
         r_supplier_site_id(k),
         r_item_id(k),
         r_order_number(k),
         r_release_number(k),
         r_line_number(k));
      loop
         fetch receipt3_cur into l_date;
         exit when receipt3_cur%NOTFOUND;

         l_num_line := l_num_line + 1;
                  --dbms_output.put_line('Ship3 date ' || r_ship_date(k) || ' the date ' || l_date);
         IF (l_date > r_ship_date(k)) THEN
         --dbms_output.put_line('Ship3 date ' || r_ship_date(k) || ' the date ' || l_date);
         l_flag := true;
            l_fulfill := l_fulfill + 1;
         ELSE
         l_fulfill := l_fulfill + 0;
         END IF;
      end loop;
            close receipt3_cur;
         END IF;

        IF (l_flag = true and l_num_line <> 0) and
       (1 - l_fulfill /l_num_line) < (l_threshold1/100) THEN
            l_exception_type := msc_x_netting_pkg.G_EXCEP43;   --your supp on-time del performance
      l_exception_group := msc_x_netting_pkg.G_PERFORMANCE;
      l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

     --------------------------------------------------------------------------
   -- get the shipping control
   ---------------------------------------------------------------------------
   l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(r_publisher_name(k),
                                    r_publisher_site_name(k),
                                    r_supplier_name(k),
                                    r_supplier_site_name(k));

   l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

      msc_x_netting_pkg.add_to_exception_tbl(r_publisher_id(k),
            r_publisher_name(k),
            r_publisher_site_id(k),
            r_publisher_site_name(k),
            r_item_id(k),
            r_item_name(k),
            r_item_desc(k),
            l_exception_type,
            l_exception_type_name,
            l_exception_group,
            l_exception_group_name,
            null,       --l_trx_id1,
            null,                   --l_trx_id2,
            null,       --l_customer_id,
            null,       --l_customer_name,
            null,       --l_customer_site_id,
            null,       --l_customer_site_name,
            r_customer_item_name(k),
            r_supplier_id(k),
            r_supplier_name(k),
            r_supplier_site_id(k),
            r_supplier_site_name(k),
            r_supplier_item_name(k),
            l_fulfill,
            l_num_line,
            (1 - l_fulfill /l_num_line) * 100,        --performance
            l_threshold1,
            null,       --lead time
            null,       --item min
            null,       --item max
            r_order_number(k),
            r_release_number(k),
            r_line_number(k),
            null,                   --l_end_order_number,
            null,                   --l_end_order_rel_number,
            null,                   --l_end_order_line_number,
            null,
            null,
            add_months(sysdate,-3), --l_actual_date or bucket start date,
            sysdate,                --l_tp_actual_date or bucket end date,
            null,
            null,
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

        END IF;

   IF (l_flag = true and l_num_line <> 0) and
       (1 - l_fulfill /l_num_line < l_threshold2/100) THEN
      l_exception_type := msc_x_netting_pkg.G_EXCEP44;   --your on-time del performance
      l_exception_group := msc_x_netting_pkg.G_PERFORMANCE; -- metric
      l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);


      msc_x_netting_pkg.add_to_exception_tbl(r_supplier_id(k),
            r_supplier_name(k),
            r_supplier_site_id(k),
            r_supplier_site_name(k),
            r_item_id(k),
            r_item_name(k),
            r_item_desc(k),
            l_exception_type,
            l_exception_type_name,
            l_exception_group,
            l_exception_group_name,
            null,       --l_trx_id1,
            null,                   --l_trx_id2,
            r_publisher_id(k),
            r_publisher_name(k),
            r_publisher_site_id(k),
            r_publisher_site_name(k),
            r_customer_item_name(k),
            null,       --l_supplier_id
            null,       --l_supplier_name,
            null,       --l_supplier_site_id
            null,       --l_supplier_site_name,
            r_supplier_item_name(k),
            l_fulfill,
            l_num_line,
            (1 - l_fulfill /l_num_line) * 100,        -- performance
            l_threshold2,
            null,       --lead time
            null,       --item min
            null,       --item max
            r_order_number(k),
            r_release_number(k),
            r_line_number(k),
            null,                   --l_end_order_number,
            null,                   --l_end_order_rel_number,
            null,                   --l_end_order_line_number,
            null,
            null,
            add_months(sysdate,-3), --l_actual_date or bucket start date,
            sysdate,                --l_tp_actual_date or bucket end date,
            null,
            null,
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

      END IF;
    END LOOP;
END IF;
END LOOP;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(43) || ','
|| msc_x_netting_pkg.get_message_type(44) || ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
--------------------------------------------------
--dbms_output.put_line('Exception 45 and 46');
open exception_45_46;
      fetch exception_45_46 BULK COLLECT INTO
         	b_publisher_id,
         	b_publisher_name,
         	b_publisher_site_id,
         	b_publisher_site_name,
         	b_item_id,
         	b_item_name,
         	b_item_desc,
         	b_customer_item_name,
               	b_supplier_id,
               	b_supplier_name,
               	b_supplier_site_id,
               	b_supplier_site_name,
                b_supplier_item_name,
                b_supplier_item_desc;
CLOSE exception_45_46;
IF (b_item_id is not null and b_item_id.COUNT > 0) THEN
FOR j in 1..b_item_id.COUNT
LOOP
   -- exception 45 customer centric
   --------------------------------------------------------------------------
   -- get the shipping control
   ---------------------------------------------------------------------------
   l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                    b_publisher_site_name(j),
                                    b_supplier_name(j),
                                    b_supplier_site_name(j));

   l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

   l_threshold1 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP45,
                b_publisher_id(j),
               	b_publisher_site_id(j),
               	b_item_id(j),
            	b_supplier_id(j),
            	b_supplier_site_id(j),
            	null,
            	null,
                null);
        -- exception 46 supplier centric
   l_threshold2 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP46,
                b_supplier_id(j),
                b_supplier_site_id(j),
                b_item_id(j),
               	null,
               	null,
               	b_publisher_id(j),
               	b_publisher_site_id(j),
                null);

         select  nvl(sum(sd.primary_quantity),0),
            nvl(sum(sd.tp_quantity),0),
            nvl(sum(sd.quantity),0)
         into  l_total_historical_sales,
            l_tp_total_historical_sales,
            l_p_total_historical_sales
         from  msc_sup_dem_entries sd
         where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
         and   sd.publisher_id = b_publisher_id(j)
         and   sd.publisher_site_id = b_publisher_site_id(j)
         and   sd.inventory_item_id = b_item_id(j)
         and   sd.publisher_order_type = msc_x_netting_pkg.HISTORICAL_SALES
         and   sd.supplier_id = b_supplier_id(j)
         and   sd.supplier_site_id = b_supplier_site_id(j)
         and   sd.customer_id = sd.publisher_id
         and   sd.customer_site_id = sd.publisher_site_id
         and   trunc(sd.new_schedule_date) between
            add_months(trunc(sysdate),-3) and trunc(sysdate);

         select  nvl(sum(sd.primary_quantity),0),
            nvl(sum(sd.tp_quantity),0),
            nvl(sum(sd.quantity),0)
   into  l_total_onhand, l_tp_total_onhand, l_posting_total_onhand
   from  msc_sup_dem_entries sd
   where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
   and   sd.publisher_id = b_publisher_id(j)
   and   sd.publisher_site_id = b_publisher_site_id(j)
   and   sd.inventory_item_id = b_item_id(j)
   and   sd.publisher_order_type = msc_x_netting_pkg.ALLOCATED_ONHAND
   and   sd.supplier_id = b_supplier_id(j)
   and   sd.supplier_site_id = b_supplier_site_id(j)
   and   sd.customer_id = sd.publisher_id
   and   sd.customer_site_id = sd.publisher_site_id
   and   trunc(sd.new_schedule_date) between
            add_months(trunc(sysdate),-3) and trunc(sysdate);

        IF (l_total_onhand > 0) and (l_total_historical_sales > 0 ) and
            (l_total_historical_sales/l_total_onhand) < l_threshold1 THEN

            l_exception_type := msc_x_netting_pkg.G_EXCEP45;   --your inventory turn
      l_exception_group := msc_x_netting_pkg.G_PERFORMANCE;
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
            null,       --l_trx_id1,
            null,                   --l_trx_id2,
            null,       --l_customer_id,
            null,       --l_customer_name,
            null,       --l_customer_site_id,
            null,       --l_customer_site_name,
            b_customer_item_name(j),
            b_supplier_id(j),
            b_supplier_name(j),
            b_supplier_site_id(j),
            b_supplier_site_name(j),
            b_supplier_item_name(j),
            l_total_historical_sales,
            l_total_onhand,
            round(l_total_historical_sales/l_total_onhand,1), -- inventory turn
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
            null,
            null,
            add_months(sysdate,-3), --l_actual_date or bucket start date,
            sysdate,                --l_tp_actual_date or bucket end date,
            null,
            null,
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

        END IF;
        --dbms_output.put_line('tp His ' || l_tp_total_historical_sales || 'tp onhand ' || l_tp_total_onhand);
   IF (l_tp_total_onhand > 0) and (l_tp_total_historical_sales > 0) and
            (l_tp_total_historical_sales/l_tp_total_onhand) < l_threshold2 THEN
      l_exception_type := msc_x_netting_pkg.G_EXCEP46;   --customer inventory turns
      l_exception_group := msc_x_netting_pkg.G_PERFORMANCE;
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
         null,       --l_trx_id1,
         null,                   --l_trx_id2,
         b_publisher_id(j),
         b_publisher_name(j),
         b_publisher_site_id(j),
         b_publisher_site_name(j),
         b_customer_item_name(j),
         null,       --l_supplier_id
         null,       --l_supplier_name,
         null,       --l_supplier_site_id
         null,       --l_supplier_site_name,
         b_supplier_item_name(j),
         l_tp_total_historical_sales,
         l_tp_total_onhand,
         round(l_tp_total_historical_sales/l_tp_total_onhand,1),     -- inventory turn
         l_threshold2,
         null,       --lead time
         null,       --item min
         null,       --item max
         null,       --l_order_number,
         null,       --l_release_number,
         null,       --l_line_number,
         null,                   --l_end_order_number,
         null,                   --l_end_order_rel_number,
         null,                   --l_end_order_line_number,
         null,
         null,
         add_months(sysdate,-3), --l_actual_date or bucket start date,
         sysdate,                --l_tp_actual_date or bucket end date,
         null,
         null,
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
      END IF;
END LOOP;
END IF;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(45) ||
      ',' || msc_x_netting_pkg.get_message_type(46) || ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
--------------------------------------------------
--dbms_output.put_line('Exception 47 and 48');

open exception_47_48;
    fetch exception_47_48 BULK COLLECT INTO
         	b_publisher_id,
         	b_publisher_name,
         	b_publisher_site_id,
         	b_publisher_site_name,
         	b_item_id,
         	b_item_name,
         	b_item_desc,
         	b_customer_item_name,
         	b_supplier_id,
               	b_supplier_name,
               	b_supplier_site_id,
               	b_supplier_site_name,
                b_supplier_item_name,
                b_supplier_item_desc;
CLOSE exception_47_48;
IF (b_item_id is not null and b_item_id.COUNT > 0) THEN
FOR j in 1..b_item_id.COUNT
LOOP
   -- exception 47 customer centric

   --------------------------------------------------------------------------
   -- get the shipping control
   ---------------------------------------------------------------------------
   l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                    b_publisher_site_name(j),
                                    b_supplier_name(j),
                                    b_supplier_site_name(j));

   l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

   l_threshold1 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP47,
                b_publisher_id(j),
               	b_publisher_site_id(j),
               	b_item_id(j),
            	b_supplier_id(j),
            	b_supplier_site_id(j),
            	null,
            	null,
                null);
          -- exception 48 supplier centric
   l_threshold2 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP48,
                b_supplier_id(j),
                b_supplier_site_id(j),
                b_item_id(j),
               	null,
               	null,
               	b_publisher_id(j),
               	b_publisher_site_id(j),
                null);



    SELECT  count(*)
    INTO  l_stock_out
     FROM    msc_sup_dem_history sd
     WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
     AND     sd.publisher_order_type = msc_x_netting_pkg.ALLOCATED_ONHAND
     AND   sd.publisher_name = b_publisher_name(j)
     AND   sd.publisher_site_name = b_publisher_site_name(j)
     AND   sd.publisher_item_name = b_item_name(j)
     AND   sd.quantity_new <> sd.quantity_old
     AND   sd.quantity_new = 0
     AND   trunc(sd.new_schedule_date_new) between
         add_months(trunc(sysdate), -3)and trunc(sysdate);


         IF l_stock_out > l_threshold1 then
               l_exception_type := msc_x_netting_pkg.G_EXCEP47;   --excee
         	l_exception_group := msc_x_netting_pkg.G_PERFORMANCE;
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
            	null,       --l_trx_id1,
            	null,                   --l_trx_id2,
            	null,       --l_customer_id,
            	null,       --l_customer_name,
            	null,       --l_customer_site_id,
            	null,       --l_customer_site_name,
            	b_customer_item_name(j),
            	b_supplier_id(j),
            	b_supplier_name(j),
            	b_supplier_site_id(j),
            	b_supplier_site_name(j),
            	b_supplier_item_name(j),
            	l_stock_out,
            	null,
            	null,
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
            	null,
            	null,
            	add_months(sysdate,-3), --l_actual_date or bucket start date,
            	sysdate,                --l_tp_actual_date or bucket end date,
            	null,
            	null,
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
        END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(47) ||
      ':' ||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

   IF (l_stock_out > l_threshold2) then
         l_exception_type := msc_x_netting_pkg.G_EXCEP48;   --stock out at your customer site
         l_exception_group := msc_x_netting_pkg.G_PERFORMANCE;
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
            null,       --l_trx_id1,
            null,                   --l_trx_id2,
            b_publisher_id(j),
            b_publisher_name(j),
            b_publisher_site_id(j),
            b_publisher_site_name(j),
            b_customer_item_name(j),
            null,       --l_supplier_id
            null,       --l_supplier_name,
            null,       --l_supplier_site_id
            null,       --l_supplier_site_name,
            b_supplier_item_name(j),
            l_stock_out,
            null,
            null,
            l_threshold2,
            null,       --lead time
            null,       --item min
            null,       --item max
            null,       --l_order_number,
            null,       --l_release_number,
            null,       --l_line_number,
            null,                   --l_end_order_number,
            null,                   --l_end_order_rel_number,
            null,                   --l_end_order_line_number,
            null,
            null,
            add_months(sysdate,-3), --l_actual_date or bucket start date,
            sysdate,                --l_tp_actual_date or bucket end date,
            null,
            null,
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
      END IF;
END LOOP;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(47) ||
      ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total exceptions inserted for the group ' ||
 msc_x_netting_pkg.get_message_group(msc_x_netting_pkg.G_PERFORMANCE) || ':' || l_inserted_record);

-- added exception handler
EXCEPTION
   WHEN OTHERS THEN
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING4_PKG.COMPUTE_PERFORMANCE');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);

END COMPUTE_PERFORMANCE;


--------------------------------------------------------------------------
--PROCEDURE COMPUTE_CUSTOM_EXCEPTION
--------------------------------------------------------------------------
PROCEDURE COMPUTE_CUSTOM_EXCEPTION IS

BEGIN

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Launch Customer Exception at: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        /* launch custom exceptions whar supposed to be run with netting engine */

        MSC_X_USER_EXCEP_GEN.RunCustomExcepWithNetting;

END compute_custom_exception;


END MSC_X_NETTING4_PKG;


/
