--------------------------------------------------------
--  DDL for Package Body MSC_X_NETTING1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_NETTING1_PKG" AS
/* $Header: MSCXEX1B.pls 120.1 2005/09/23 01:48:35 shwmathu noship $ */

--================================================================
--Group 1: Late Order
--================================================================
/*---------------------------------
The actual date for order type = SO is ship_date
In order to compute the supply, the load program has
calculate the lead time for the ship_date.
The receipt_date = ship_date + lead time

---------------------------------------*/
-------------------------------------------------------------------------------
--1.1 Replenishment to customer scheduled after need date : exception_1
---------------------------------------------------------------------------------

CURSOR exception_1(p_refresh_number IN Number) IS

SELECT  distinct sd1.transaction_id,
   sd1.publisher_id,
   sd1.publisher_name,
   sd1.publisher_site_id,
   sd1.publisher_site_name,
   sd1.inventory_item_id,
   sd1.item_name,
   sd1.item_description,
   sd1.supplier_item_name,
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
AND     sd2.plan_id = sd1.plan_id
AND     sd2.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND     sd2.supplier_id = sd1.publisher_id
AND   sd2.supplier_site_id = sd1.publisher_site_id
AND   sd2.inventory_item_id = sd1.inventory_item_id
AND     sd1.end_order_number = sd2.order_number
AND     nvl(sd1.end_order_rel_number,-1) = nvl(sd2.release_number,-1)
AND     nvl(sd1.end_order_line_number,-1) = nvl(sd2.line_number,-1)
AND     nvl(sd1.last_refresh_number,-1) > nvl(p_refresh_number,-1);


------------------------------------------------------------------------------
--1.2 Replenishment from supplier schedules after need date : exception_2
------------------------------------------------------------------------------
CURSOR exception_2(p_refresh_number IN Number) IS
SELECT  distinct sd1.transaction_id,
   sd1.publisher_id,
   sd1.publisher_name,
   sd1.publisher_site_id,
   sd1.publisher_site_name,
   sd1.inventory_item_id,
   sd1.item_name,
   sd1.item_description,
   sd1.customer_item_name,
   sd1.customer_item_description,
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
AND     sd2.plan_id = sd1.plan_id
AND     sd2.publisher_order_type = msc_x_netting_pkg.SALES_ORDER
AND     sd2.customer_id = sd1.publisher_id
AND   sd2.customer_site_id = sd1.publisher_site_id
AND   sd2.inventory_item_id = sd1.inventory_item_id
AND     sd1.order_number = sd2.end_order_number
AND     nvl(sd1.release_number,-1) = nvl(sd2.end_order_rel_number,-1)
AND     nvl(sd1.line_number,-1) = nvl(sd2.end_order_line_number,-1)
AND     nvl(sd1.last_refresh_number,-1) > nvl(p_refresh_number,-1);



-----------------------------------------------------------------------------------
--1.3 Replenishment to customer is past due (supplier centric) : exception_3
--1.4 Replenishment from supplier is past due (customer centric): exception_4
-- Exception will be generated when:
-- po exist without so and the receipt_date(po) < sysdate
----------------------------------------------------------------------------------
CURSOR exception_3_4 IS
SELECT  sd1.transaction_id,      -- need customer info only
   sd1.publisher_id,
   sd1.publisher_name,
   sd1.publisher_site_id,
   sd1.publisher_site_name,
   sd1.inventory_item_id,
   sd1.item_name,
   sd1.item_description,
   sd1.customer_item_name,
   sd1.customer_item_description,
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
        msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP3,        --exception type
                   sd1.supplier_id,    --p_company_id
                   sd1.supplier_site_id,     --p_company_site_id
                   sd1.inventory_item_id,    --p_inventory_item_id
                   null,            --p_supplier_company_id
                   null,            --p_supplier_company_site_id
                   sd1.publisher_id,      --p_customer_company_id
                   sd1.publisher_site_id,    --p_customer_company_site_id
                        sd1.key_date),
   msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP4,
                        sd1.publisher_id,
                        sd1.publisher_site_id,
                        sd1.inventory_item_id,
                        sd1.supplier_id,
                        sd1.supplier_site_id,
                        null,
                        null,
                        sd1.key_date)
FROM    msc_sup_dem_entries sd1
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER     -- PO
AND     trunc(sysdate) > trunc(sd1.key_date);


-------------------------------------------------------------------------------
--GROUP: EARLY_ORDERS
-------------------------------------------------------------------------------
--6.2 Replenishment to customer scheduled before need date : exception_23
---------------------------------------------------------------------------------

CURSOR exception_23(p_refresh_number IN Number) IS
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
AND     sd2.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND     sd2.supplier_id = sd1.publisher_id
AND   sd2.supplier_site_id = sd1.publisher_site_id
AND   sd2.inventory_item_id = sd1.inventory_item_id
AND     sd1.end_order_number = sd2.order_number
AND     nvl(sd1.end_order_rel_number,-1) = nvl(sd2.release_number,-1)
AND     nvl(sd1.end_order_line_number,-1) = nvl(sd2.line_number,-1)
AND     nvl(sd1.last_refresh_number,-1) > nvl(p_refresh_number,-1);


------------------------------------------------------------------------------
--6.2 Replenishment from supplier schedule before need ate : exception_24
------------------------------------------------------------------------------
CURSOR exception_24(p_refresh_number IN Number) IS
SELECT  distinct sd1.transaction_id,
   sd1.publisher_id,
   sd1.publisher_name,
   sd1.publisher_site_id,
   sd1.publisher_site_name,
   sd1.inventory_item_id,
   sd1.item_name,
   sd1.item_description,
   sd1.customer_item_name,
   sd1.customer_item_description,
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
        sd2.creation_date ,
        sd2.last_refresh_number
FROM    msc_sup_dem_entries sd1,
        msc_sup_dem_entries sd2
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND     sd2.plan_id = sd1.plan_id
AND     sd2.publisher_order_type = msc_x_netting_pkg.SALES_ORDER
AND     sd2.customer_id = sd1.publisher_id
AND   sd2.customer_site_id = sd1.publisher_site_id
AND   sd2.inventory_item_id = sd1.inventory_item_id
AND     sd1.order_number = sd2.end_order_number
AND     nvl(sd1.release_number,-1) = nvl(sd2.end_order_rel_number,-1)
AND     nvl(sd1.line_number,-1) = nvl(sd2.end_order_line_number,-1)
AND     nvl(sd1.last_refresh_number,-1) > nvl(p_refresh_number,-1);



--===================================================================
-- Group 5: Forecast Mismatch (Demand Planning)
--===================================================================


--The cursor below selects the buckets generated for company/org combination
CURSOR time_bkts  IS
SELECT   trunc(b.bkt_start_date), trunc(b.bkt_end_date), b.bucket_type
FROM  msc_plan_buckets b
WHERE    b.plan_id = msc_x_netting_pkg.G_PLAN_ID;

---------------------------------------------------------------------------
-- customer centric
-------------------------------------------------------------------------
-- 5.1 Customer's sales forecast is greater than your sales forecast: exception_19
-- 5.2 Customer's sales forecast is less than your sales forecast: exception_20
--both customer/supplier can post sales forecast for the related data
--inorder to identify who is posting the data,
--the publisher_id has to be = supplier_id for the following case
---------------------------------------------------------------------------
CURSOR exception_19_20( p_refresh_number in Number) IS
SELECT distinct sd.customer_id,
   sd.customer_name,
        sd.customer_site_id,
        sd.customer_site_name,
        sd.customer_item_name,
        sd.customer_item_description,
        sd.publisher_id,
        sd.publisher_name,
        sd.publisher_site_id,
        sd.publisher_site_name,
        sd.inventory_item_id,
        sd.item_name,
        sd.item_description,
        sd.supplier_item_name
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type = msc_x_netting_pkg.SALES_FORECAST
AND   sd.supplier_id = sd.publisher_id
AND   sd.supplier_site_id = sd.publisher_site_id
AND     nvl(sd.last_refresh_number,-1) >  nvl(p_refresh_number,-1);

-------------------------------------------------------------------------------------
--5.3 Supplier's sales forecast is greater than your sales forecast (DP): exception_21
--5.4 Supplier's sales forecast is less than your sales forecast (DP): exception_22
--supplier centric
--------------------------------------------------------------------------------------
CURSOR exception_21_22(p_refresh_number IN Number) IS
SELECT distinct sd.supplier_id,
   sd.supplier_name,
        sd.supplier_site_id,
        sd.supplier_site_name,
        sd.supplier_item_name,
        sd.supplier_item_description,
        sd.publisher_id,
        sd.publisher_name,
        sd.publisher_site_id,
        sd.publisher_site_name,
        sd.inventory_item_id,
        sd.item_name,
        sd.item_description,
        sd.customer_item_name
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type = msc_x_netting_pkg.SALES_FORECAST
AND   sd.customer_id = sd.publisher_id
AND   sd.customer_site_id = sd.publisher_site_id
AND     nvl(sd.last_refresh_number,-1) >  nvl(p_refresh_number,-1);

--==================================================================
-- COMPUTE_LATE_ORDER
--==================================================================
PROCEDURE Compute_Late_Order(p_refresh_number IN Number,
   t_company_list       IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   t_company_site_list  IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   t_customer_list   IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   t_customer_site_list    IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   t_supplier_list   IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   t_supplier_site_list    IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   t_item_list       IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   t_group_list      IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   t_type_list       IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   t_trxid1_list     IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   t_trxid2_list     IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   t_date1_list      IN OUT   NOCOPY msc_x_netting_pkg.date_arr,
   t_date2_list      IN OUT   NOCOPY msc_x_netting_pkg.date_arr,
   a_company_id            IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   a_company_name          IN OUT   NOCOPY msc_x_netting_pkg.publisherList,
   a_company_site_id       IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   a_company_site_name     IN OUT   NOCOPY msc_x_netting_pkg.pubsiteList,
   a_item_id               IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   a_item_name             IN OUT   NOCOPY msc_x_netting_pkg.itemnameList,
   a_item_desc             IN OUT   NOCOPY msc_x_netting_pkg.itemdescList,
   a_exception_type        IN OUT   NOCOPY msc_x_netting_pkg.number_arr,
   a_exception_type_name   IN OUT   NOCOPY msc_x_netting_pkg.exceptypeList,
   a_exception_group       IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_exception_group_name  IN OUT  NOCOPY msc_x_netting_pkg.excepgroupList,
   a_trx_id1               IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_trx_id2               IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_id           IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_name         IN OUT  NOCOPY msc_x_netting_pkg.customerList,
   a_customer_site_id      IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_customer_site_name    IN OUT  NOCOPY msc_x_netting_pkg.custsiteList,
   a_customer_item_name IN OUT  NOCOPY msc_x_netting_pkg.itemnameList,
   a_supplier_id           IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_supplier_name         IN OUT  NOCOPY msc_x_netting_pkg.supplierList,
   a_supplier_site_id      IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_supplier_site_name    IN OUT  NOCOPY msc_x_netting_pkg.suppsiteList,
   a_supplier_item_name    IN OUT  NOCOPY msc_x_netting_pkg.itemnameList,
   a_number1               IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_number2               IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_number3               IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_threshold             IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_lead_time             IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_item_min_qty          IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_item_max_qty          IN OUT  NOCOPY msc_x_netting_pkg.number_arr,
   a_order_number          IN OUT  NOCOPY msc_x_netting_pkg.ordernumberList,
   a_release_number        IN OUT  NOCOPY msc_x_netting_pkg.releasenumList,
   a_line_number           IN OUT  NOCOPY msc_x_netting_pkg.linenumList,
   a_end_order_number      IN OUT  NOCOPY msc_x_netting_pkg.ordernumberList,
   a_end_order_rel_number  IN OUT  NOCOPY msc_x_netting_pkg.releasenumList,
   a_end_order_line_number IN OUT  NOCOPY msc_x_netting_pkg.linenumList,
   a_creation_date         IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_tp_creation_date      IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date1           	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date2        	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date3            	   IN OUT NOCOPY msc_x_netting_pkg.date_arr,
   a_date4		   IN OUT  NOCOPY msc_x_netting_pkg.date_arr,
   a_date5		   IN OUT  NOCOPY msc_x_netting_pkg.date_arr,
   a_exception_basis	   IN OUT  NOCOPY msc_x_netting_pkg.exceptbasisList) IS

CURSOR excepSummary IS
select plan_id,
   inventory_item_id,
   company_id,
   company_site_id,
   exception_group,
   exception_type,
   count(*)
from     msc_x_exception_details
where    plan_id =msc_x_netting_pkg.G_PLAN_ID
and   version = 'X'
and      exception_type in (3,4)
group by plan_id,
        inventory_item_id,
       company_id,
       company_site_id,
       exception_group,
       exception_type;

  b_trx_id1                	msc_x_netting_pkg.number_arr;
  b_trx_id2                	msc_x_netting_pkg.number_arr;
  b_threshold1       		msc_x_netting_pkg.number_arr;
  b_threshold2       		msc_x_netting_pkg.number_arr;
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


l_exception_count       	Number;
l_complement_threshold  	Number;
l_threshold1      		Number;
l_threshold2      		Number;
l_exception_type  		Number;
l_exception_group 		Number;
l_exception_type_name   	fnd_lookup_values.meaning%type;
l_exception_group_name  	fnd_lookup_values.meaning%type;
l_exception_detail_id1  	Number;
l_exception_detail_id2  	Number;
l_exception_exists   		Number;
l_so_exist     			Number;
l_so_qty    			Number;
l_item_type       		Varchar2(20);
l_item_key     			Varchar2(100);
l_row       			Number;
l_shipping_control		Number;
l_exception_basis		msc_x_exception_details.exception_basis%type;
l_inserted_record		Number;


--------------------------------------------------------
-- plsql table list for archive old exception
----------------------------------------------------------
TYPE  numberList  IS TABLE OF number;
u_plan_id      numberList;
u_inventory_item_id  numberList;
u_company_id      numberList;
u_company_site_id numberList;
u_exception_group numberList;
u_exception_type  numberList;
u_count        numberList;


BEGIN


l_exception_exists   		 := 0;
l_so_exist     			 := 0;
l_item_type       		 := 'MSCSNDNT';
l_item_key     			 := null;
l_inserted_record		 := 0;



--dbms_output.put_line('Exception 1');
--supplier centric as viewer
open exception_1 (p_refresh_number);
      fetch exception_1 BULK COLLECT INTO
                  b_trx_id1,     --so trxid
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
                  b_trx_id2,     --po trxid
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
                  b_po_creation_date,
                  b_po_last_refnum;

  CLOSE exception_1;

IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
  FOR j in 1 .. b_trx_id1.COUNT
  LOOP
        --dbms_output.put_line('-----Exception1: Trx id 1 = ' || b_trx_id1(j));
        --dbms_output.put_line('---------------  Trx id 2 = ' || b_trx_id2(j));

   --======================================================
   -- archive old exception and its complement
   --=====================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      b_customer_id(j),
      b_customer_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_LATE_ORDER,
      msc_x_netting_pkg.G_EXCEP1,
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
      msc_x_netting_pkg.G_LATE_ORDER,
      msc_x_netting_pkg.G_EXCEP2,
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

       l_threshold1 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP1,
                              b_publisher_id(j),
                              b_publisher_site_id(j),
                              b_item_id(j),
                              null,
                              null,
                              b_customer_id(j),
                              b_customer_site_id(j),
                              b_so_key_date(j));



   IF (b_so_key_date(j) > b_po_key_date(j) + l_threshold1) then


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
      msc_x_netting_pkg.G_EARLY_ORDER,
      msc_x_netting_pkg.G_EXCEP23,
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
      msc_x_netting_pkg.G_EARLY_ORDER,
      msc_x_netting_pkg.G_EXCEP24,
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

      --------------------------------------------------------------------------
      -- get the shipping control
      ---------------------------------------------------------------------------
      l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_customer_name(j),
                                    b_customer_site_name(j),
                                    b_publisher_name(j),
                                    b_publisher_site_name(j));

      l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

   	l_exception_type := msc_x_netting_pkg.G_EXCEP1;  -- replenishment to cust after need date
        l_exception_group := msc_x_netting_pkg.G_LATE_ORDER;
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
                                b_trx_id2(j),
                                b_customer_id(j),
                                b_customer_name(j),
                                b_customer_site_id(j),
                                b_customer_site_name(j),
                                b_customer_item_name(j),
                                null,  --l_supplier_id,
                                null,  --l_supplier_name,
                                null,  --l_supplier_site_id,
                                null,  --l_supplier_site_name,
                                b_supplier_item_name(j), --supplier item name
                                b_so_qty(j),  --number1
                                b_tp_po_qty(j),    --number2
                                null,        --number3
                                l_threshold1,      --threshold
                                null,        --lead time
            			null,       --l_item_min,
            			null,       --l_item_max,
                                b_order_number(j),
                                b_release_number(j),
                                b_line_number(j),
                                b_end_order_number(j),
                                b_end_order_rel_number(j),
                                b_end_order_line_number(j),
                                b_so_creation_date(j),
                                b_po_creation_date(j),
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
   -- generate complement exception
   ------------------------------------------------
   if (b_po_last_refnum(j) <= p_refresh_number)  then
      --detected exception 1.2

      l_complement_threshold:= msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP2,
               b_customer_id(j),
               b_customer_site_id(j),
               b_item_id(j),
               b_publisher_id(j),
               b_publisher_site_id(j),
               null,
               null,
               b_po_key_date(j));

         if (b_so_key_date(j) > b_po_key_date(j) + l_complement_threshold) then


         	l_exception_type := msc_x_netting_pkg.G_EXCEP2; --replenishment from sup after need dt
         	l_exception_group := msc_x_netting_pkg.G_LATE_ORDER;
         	l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
         	l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

         	--dbms_output.put_line('Generating complement exception ' || l_exception_type);

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
                 	b_trx_id1(j),
                 	null,        --l_customer_id,
                 	null,        --l_customer_name,
                 	null,        --l_customer_site_id,
                 	null,        --customer site name,
                 	b_customer_item_name(j), --customer item name
                 	b_publisher_id(j),    --supplier_id
                 	b_publisher_name(j),
                 	b_publisher_site_id(j),  --supplier_site
                 	b_publisher_site_name(j),
                 	b_supplier_item_name(j),
                 	b_po_qty(j),  --number1
                 	b_tp_so_qty(j),      --number2
                 	null,        --number3
                 	l_complement_threshold,
                 	null,        --lead time
            	 	null,       --l_item_min,
            	 	null,       --l_item_max,
                 	b_order_number(j),
                 	b_release_number(j),
                 	b_line_number(j),
                 	b_end_order_number(j),
                 	b_end_order_rel_number(j),
                 	b_end_order_line_number(j),
                 	b_po_creation_date(j),
                 	b_so_creation_date(j),
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
   END IF;
   END IF;
 END LOOP;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' || msc_x_netting_pkg.get_message_type(1) ||
   ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));


--dbms_output.put_line('Exception 2'); --customer centric
open exception_2 ( p_refresh_number);
      fetch exception_2 BULK COLLECT INTO
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
                                        b_customer_site_id,
                                        b_customer_site_name,
                                        b_so_creation_date,
                                        b_so_last_refnum;
  CLOSE exception_2;

IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
  FOR j in 1 .. b_trx_id1.COUNT
  LOOP
      --dbms_output.put_line('-----Exception2: Trx id 1 = ' || b_trx_id1(j));
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
      msc_x_netting_pkg.G_LATE_ORDER,
      msc_x_netting_pkg.G_EXCEP2,
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
      msc_x_netting_pkg.G_LATE_ORDER,
      msc_x_netting_pkg.G_EXCEP1,
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


   l_threshold1 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP2,
                  	b_publisher_id(j),
               		b_publisher_site_id(j),
               		b_item_id(j),
            		b_supplier_id(j),
            		b_supplier_site_id(j),
            		null,
            		null,
                     	b_po_key_date(j));

   IF b_so_key_date(j) > b_po_key_date(j) + l_threshold1 THEN
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
      msc_x_netting_pkg.G_EARLY_ORDER,
      msc_x_netting_pkg.G_EXCEP24,
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
      msc_x_netting_pkg.G_EARLY_ORDER,
      msc_x_netting_pkg.G_EXCEP23,
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

      --------------------------------------------------------------------------
      -- get the shipping control
      ---------------------------------------------------------------------------
      l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                    b_publisher_site_name(j),
                                    b_supplier_name(j),
                                    b_supplier_site_name(j));

      l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

      --dbms_output.put_line('Exception2');
         l_exception_type := msc_x_netting_pkg.G_EXCEP2;  -- replenishment from sup after need date
         l_exception_group := msc_x_netting_pkg.G_LATE_ORDER;
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
            b_trx_id2(j),
            null,       --l_customer_id,
            null,
            null,       --l_customer_site_id,
            null,
            b_customer_item_name(j),
            b_supplier_id(j),
            b_supplier_name(j),
            b_supplier_site_id(j),
            b_supplier_site_name(j),
            b_supplier_item_name(j),
            b_po_qty(j),
            b_tp_so_qty(j),
            null,       --number3
            l_threshold1,
            null,       --lead time
            null,       --l_item_min,
            null,       --l_item_max,
            b_order_number(j),
            b_release_number(j),
            b_line_number(j),
            b_end_order_number(j),
            b_end_order_rel_number(j),
            b_end_order_line_number(j),
            b_po_creation_date(j),
            b_so_creation_date(j),
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
      -----------------------------------------------
      -- generate complement exception
      -----------------------------------------------
   if (b_so_last_refnum(j) <= p_refresh_number) then
         --dbms_output.put_line('There is complement exception for ex2');
      l_complement_threshold:= msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP1,
            b_supplier_id(j),
            b_supplier_site_id(j),
            b_item_id(j),
            null,
            null,
            b_publisher_id(j),
            b_publisher_site_id(j),
            b_so_key_date(j));

      if b_so_key_date(j) > b_po_key_date(j) + l_complement_threshold THEN

         l_exception_type := msc_x_netting_pkg.G_EXCEP1; --replenishment to cust after need dt
         l_exception_group := msc_x_netting_pkg.G_LATE_ORDER;
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
                              b_trx_id2(j),
                              b_trx_id1(j),
                              b_publisher_id(j),      --l_customer_id
                              b_publisher_name(j),
                              b_publisher_site_id(j), --l_customer_site_id,
                              b_publisher_site_name(j),
                              b_customer_item_name(j),
                              null,       --l_supplier_id,
                              null,
                              null,       --l_supplier_site_id,
                              null,
                              b_supplier_item_name(j),   --item name
                              b_so_qty(j),
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
                              b_so_creation_date(j),
                              b_po_creation_date(j),
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
   END IF;
END LOOP;
END IF;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' || msc_x_netting_pkg.get_message_type(2) ||
   ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));



/*=======================================================
 Set the previous run exception with version = 'X' at first.
 Then generates the exception, if the exception detail
 is exist, then no need to send notification and reset
 version = null.  If the exception detail not exist, create
 a new exception detail and send the notification.
 Set version = 'CURRENT'
 And archive the msc_item_exceptions
=====================================================*/

update msc_x_exception_details
set version = 'X'
where plan_id = msc_x_netting_pkg.G_PLAN_ID
and   exception_type in (3,4);

update msc_item_exceptions
set version = version + 1
where plan_id = msc_x_netting_pkg.G_PLAN_ID
and   exception_type in (3,4);

--dbms_output.put_line('Exception 3 and 4');

l_exception_detail_id1 := null;
l_exception_detail_id2 := null;
l_exception_exists := null;

open exception_3_4;
     fetch exception_3_4 BULK COLLECT INTO b_trx_id1,
            b_publisher_id,
            b_publisher_name,
            b_publisher_site_id,       --
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
            b_supplier_id,       --so org
            b_supplier_name,
            b_supplier_site_id,
            b_supplier_site_name,
            b_supplier_item_name,
            b_supplier_item_desc,
            b_po_creation_date,
            b_threshold1,
            b_threshold2;
 CLOSE exception_3_4;

IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
 FOR j in 1 .. b_trx_id1.COUNT
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


   IF (trunc(sysdate) > trunc(b_po_key_date(j)) + b_threshold1(j)) THEN

           l_so_exist := msc_x_netting_pkg.does_so_exist ( b_order_number(j),
                                        b_release_number(j),
                                        b_line_number(j),
               				b_supplier_id(j),
               				b_supplier_site_id(j),
               				b_publisher_id(j),
               				b_publisher_site_id(j),
               				b_item_id(j));

           IF (l_so_exist = 1) THEN
            -- the so qty here is
                l_so_qty := msc_x_netting_pkg.get_total_qty(b_order_number(j),
                                        b_release_number(j),
                                        b_line_number(j),
               				b_supplier_id(j),    --so org
                                        b_supplier_site_id(j),
               				b_publisher_id(j),      --po org
               				b_publisher_site_id(j),
               				b_item_id(j));

           END IF;
      IF (l_so_exist = 1 and l_so_qty < b_po_qty(j)) OR (l_so_exist = 0) THEN

      -------------------------------------------------------------------
      --exception 1.3 (supplier centric)
      ----------------------------------------------------------------

      l_exception_type := msc_x_netting_pkg.G_EXCEP3;  -- replenishment to cust is past due
                l_exception_group := msc_x_netting_pkg.G_LATE_ORDER;
                l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

      l_exception_detail_id1 := msc_x_netting_pkg.does_detail_excep_exist(b_supplier_id(j),
                                                        b_supplier_site_id(j),
                                                        b_item_id(j),
                                                        l_exception_type,
                                                        b_trx_id1(j));

      IF (l_exception_detail_id1 > 0) THEN  --detail already exist

                	--dbms_output.put_line('----Detail exist for trx_id '||b_trx_id1(j));
                       --reset version=null indicate no need to resend notification
                        update msc_x_exception_details
                        set    version = null,
                           date1 =    b_po_receipt_date(j),
                           date2 =    b_po_ship_date(j),
                           number1 =  b_tp_po_qty(j)
                        where  exception_detail_id = l_exception_detail_id1;

         		--Need to reset the item exception.  The item exception
         		--might be archive for the same key
         		msc_x_netting_pkg.update_exceptions_summary(b_supplier_id(j),
            			b_supplier_site_id(j),
            			b_item_id(j),
            			l_exception_type,
            			l_exception_group);

       ELSE
         --dbms_output.put_line('-----Exception3: Create exception3' );

         msc_x_netting_pkg.add_to_exception_tbl(b_supplier_id(j),    --supplier centric
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
                                null,        --l_trx_id2,
                                b_publisher_id(j),    --l_customer_id,
                                b_publisher_name(j),
                                b_publisher_site_id(j),  --l_customer_site_id,
                                b_publisher_site_name(j),
                                b_customer_item_name(j),
                                null,        --l_supplier_id
                                null,
                                null,        --l_supplier_site_id
                                null,
                                b_supplier_item_name(j),
                                b_tp_po_qty(j),
                                null,
                                null,
                                b_threshold1(j),
                                null,        --lead time
            			null,       --l_item_min,
            			null,       --l_item_max,
                                b_order_number(j),
                                b_release_number(j),
                                b_line_number(j),
                                null,        --l_end_order_number,
                                null,        --l_end_order_rel_number,
                                null,        --l_end_order_line_number,
                                b_po_creation_date(j),
 				null,
                                b_po_receipt_date(j),
 				b_po_ship_date(j),
                                sysdate,
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
      end if;
     END IF;


     ----------------------------------------------------------------
     -- Exception 4: Replenishment from supplier is past due
     -----------------------------------------------------------------
     l_exception_detail_id1 := null;
     l_exception_detail_id2 := null;
     l_exception_exists := null;
     l_so_exist := null;

     IF (trunc(sysdate) > trunc(b_po_key_date(j)) + b_threshold2(j)) THEN

        l_so_exist := msc_x_netting_pkg.does_so_exist ( b_order_number(j),
                                       	b_release_number(j),
                                       	b_line_number(j),
                  			b_supplier_id(j),
                  			b_supplier_site_id(j),
                  			b_publisher_id(j),
                  			b_publisher_site_id(j),
                  			b_item_id(j));

        IF (l_so_exist = 1) THEN
                  -- the so qty here is
            l_so_qty := msc_x_netting_pkg.get_total_qty(b_order_number(j),
                                       	b_release_number(j),
                                       	b_line_number(j),
                  			b_supplier_id(j),    --so org
                                       	b_supplier_site_id(j),
                  			b_publisher_id(j),      --po org
                  			b_publisher_site_id(j),
                  			b_item_id(j));

        END IF;

        IF (l_so_exist = 1 and l_so_qty < b_po_qty(j)) OR (l_so_exist = 0) THEN
         ---------------------------------------------------------------
         -- exception 1.4 (customer centric)
         ---------------------------------------------------------------
         l_exception_type := msc_x_netting_pkg.G_EXCEP4;  -- replenishment from supplier is past due
               l_exception_group := msc_x_netting_pkg.G_LATE_ORDER;
               l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
         l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

         l_exception_detail_id2 := msc_x_netting_pkg.does_detail_excep_exist(
                             		b_publisher_id(j),
                                      	b_publisher_site_id(j),
                                     	b_item_id(j),
                                       	l_exception_type,
                                      	b_trx_id1(j));

         IF (l_exception_detail_id2 > 0) THEN  --detail already exist

                        --dbms_output.put_line('----Detail exist for trx_id '||b_trx_id1(j));
                        --reset version=null indicate no need to resend notification
                        update msc_x_exception_details
                        set    version = null,
                           	date1 = b_po_receipt_date(j),
                           	date2 = b_po_ship_date(j),
                           	number1 = b_po_qty(j)
                        where  exception_detail_id = l_exception_detail_id2;

                     --Need to reset the item exception.  The item exception
                        --might be archive for the same key
                        msc_x_netting_pkg.update_exceptions_summary(b_publisher_id(j),
                        	b_publisher_site_id(j),
                        	b_item_id(j),
                           	l_exception_type,
                           	l_exception_group);
         ELSE
                      --dbms_output.put_line('-----Exception4: Create exception4' );

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
                                       null,             --l_customer_site_id,
                                       null,
                                       b_customer_item_name(j),
                                       b_supplier_id(j),    --l_supplier_id
                                       b_supplier_name(j),
                                       b_supplier_site_id(j),     --l_supplier_site_id
                                       b_supplier_site_name(j),
                                       b_supplier_item_name(j),
                                       b_po_qty(j),
                                       null,
                                       null,
                                       b_threshold2(j),
                                       null,       --lead time
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
                                	b_po_receipt_date(j),
 					b_po_ship_date(j),
                                	sysdate,
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
      END IF;
     END IF;

 END LOOP;
END IF;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' || msc_x_netting_pkg.get_message_type(3) || ',' ||
    msc_x_netting_pkg.get_message_type(4) || ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total exceptions inserted for the group ' ||
 msc_x_netting_pkg.get_message_group(msc_x_netting_pkg.G_LATE_ORDER) || ':' || l_inserted_record);

--===========================================================================================
   --Archive all the exception notifications sent out in previous engine runs
   --and are not re-occurr in this run
        --The old exceptions with version = 'X' in msc_x_exception_details table
--=======================================================================================
BEGIN
   delete msc_x_exception_details
        where     plan_id = msc_x_netting_pkg.G_PLAN_ID
        and exception_type in (3,4)
        and version = 'X';

        l_row := SQL%ROWCOUNT;
EXCEPTION
   when others then
      null;
END;

--==================================
-- Update Exception Headers
--==================================
IF l_row > 0 THEN
  BEGIN

   OPEN excepSummary;

         FETCH excepSummary BULK COLLECT INTO
         u_plan_id,
         u_inventory_item_id,
         u_company_id,
         u_company_site_id,
         u_exception_group,
         u_exception_type,
         u_count;

         CLOSE excepSummary;
      IF u_plan_id.COUNT > 0 THEN
           FORALL i in 1..u_plan_id.COUNT
               update msc_item_exceptions
               set     exception_count = u_count(i)
            where plan_id = u_plan_id(i)
            and   company_id = u_company_id(i)
            and   company_site_id = u_company_site_id(i)
            and   inventory_item_id = u_inventory_item_id(i)
            and   exception_type = u_exception_type(i)
            and   exception_group = u_exception_group(i)
            and   version = 0;


             FOR i in u_plan_id.FIRST..u_plan_id.LAST LOOP

         l_item_key := to_char(u_exception_group(i)) || '-' ||
         to_char(u_exception_type(i)) || '-' ||
         to_char(u_inventory_item_id(i)) || '-' ||
         to_char(u_company_id(i)) || '-' ||
         to_char(u_company_site_id(i)) || '%';

         msc_x_netting_pkg.delete_wf_notification(l_item_type, l_item_key);
       END LOOP;
      END IF;
   EXCEPTION WHEN OTHERS THEN
      return;
   END;
END IF;



EXCEPTION
        when others then
              	MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING1_PKG.COMPUTE_LATE_ORDER');
      		MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
                return;

END COMPUTE_LATE_ORDER;



--======================================================================
--COMPUTE_EARLY_ORDER
--======================================================================
PROCEDURE Compute_Early_Order(p_refresh_number IN Number,
   t_company_list       IN OUT NOCOPY msc_x_netting_pkg.number_arr,
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

l_exception_count       	Number;
l_complement_threshold  	Number;
l_threshold    			Number;
l_exception_type  		Number;
l_exception_group 		Number;
l_exception_type_name   	fnd_lookup_values.meaning%type;
l_exception_group_name  	fnd_lookup_values.meaning%type;
l_exception_detail_id1  	Number;
l_exception_detail_id2  	Number;
l_exception_exists   		Number;
l_so_exist     			Number;
l_row       			Number;
l_shipping_control		Number;
l_exception_basis		msc_x_exception_details.exception_basis%type;
l_inserted_record		Number;

BEGIN

l_exception_exists   		:= 0;
l_so_exist     			:= 0;
l_inserted_record		:= 0;

--supplier centric as viewer
open exception_23 (p_refresh_number);
      fetch exception_23 BULK COLLECT INTO b_trx_id1,       --so trxid
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
                  b_trx_id2,     --po trxid
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
                  b_po_creation_date,
                  b_po_last_refnum;

CLOSE exception_23;
IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
FOR j in 1..b_trx_id1.COUNT
LOOP
        --dbms_output.put_line('-----Exception23: Trx id 1 = ' || b_trx_id1(j));
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
      msc_x_netting_pkg.G_EARLY_ORDER,
      msc_x_netting_pkg.G_EXCEP23,
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
      msc_x_netting_pkg.G_EARLY_ORDER,
      msc_x_netting_pkg.G_EXCEP24,
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


         l_threshold := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP23,
                               	b_publisher_id(j),
                              	b_publisher_site_id(j),
                               	b_item_id(j),
                               	null,
                               	null,
                              	b_customer_id(j),
                           	b_customer_site_id(j),
                              	b_so_key_date(j));


   IF (b_po_key_date(j) > b_so_key_date(j) + l_threshold) then
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
      msc_x_netting_pkg.G_LATE_ORDER,
      msc_x_netting_pkg.G_EXCEP1,
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
      msc_x_netting_pkg.G_LATE_ORDER,
      msc_x_netting_pkg.G_EXCEP2,
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


        --------------------------------------------------------------------------
        -- get the shipping control
        ---------------------------------------------------------------------------
        l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_customer_name(j),
                                      b_customer_site_name(j),
                                      b_publisher_name(j),
                                      b_publisher_site_name(j));

        l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));


      l_exception_type := msc_x_netting_pkg.G_EXCEP23;  --Replenishment to cust before need date
         l_exception_group := msc_x_netting_pkg.G_EARLY_ORDER;
      l_exception_type_name := msc_x_netting_pkg.get_message_type(l_exception_type);
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
                                b_so_qty(j),
                                b_tp_po_qty(j),    --number2
                                null,        --number3
                                l_threshold,
                           	null,       --lead time
            			null,       --l_item_min,
            			null,       --l_item_max,
                                b_order_number(j),
                                b_release_number(j),
                                b_line_number(j),
                                b_end_order_number(j),
                                b_end_order_rel_number(j),
                                b_end_order_line_number(j),
                                b_so_creation_date(j),
                                b_po_creation_date(j),
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
      -------------------------------------------------------
      -- generate complement exception
      --------------------------------------------------------

   IF (b_po_last_refnum(j) <= p_refresh_number) then
      --detected exception 1.2
      --dbms_output.put_line('There is complement exception for ex23');
      l_complement_threshold:= msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP24,
               	b_customer_id(j),
               	b_customer_site_id(j),
               	b_item_id(j),
               	b_publisher_id(j),
               	b_publisher_site_id(j),
               	null,
               	null,
                b_po_key_date(j));

      if (b_po_key_date(j) > b_so_key_date(j) + l_complement_threshold) THEN
         l_exception_type := msc_x_netting_pkg.G_EXCEP24;  --Replenishment to cust before need date
         l_exception_group := msc_x_netting_pkg.G_EARLY_ORDER;
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
                           b_trx_id1(j),
                           null, --l_customer_id,
                           null, --
                           null, --l_customer_site_id,
                           null,
                           b_customer_item_name(j),
                           b_publisher_id(j),      --l_supplier_id,
                           b_publisher_name(j),
                           b_publisher_site_id(j), --l_supplier_site_id,
                           b_publisher_site_name(j),
                           b_supplier_item_name(j),
                           b_po_qty(j),
                           b_tp_so_qty(j),
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
                           b_po_creation_date(j),
	                   b_so_creation_date(j),
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
         end if;   /* generate complement */
   END IF;
END LOOP;
END IF;
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' || msc_x_netting_pkg.get_message_type(23) ||
   ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

/* reset the trxid */

--dbms_output.put_line('Exception 24'); --customer centric
open exception_24 ( p_refresh_number);
      fetch exception_24 BULK COLLECT INTO b_trx_id1,
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
                                        b_customer_site_id,
                                        b_customer_site_name,
                                        b_so_creation_date,
                                        b_so_last_refnum;
 CLOSE exception_24;
 IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
 FOR j in 1..b_trx_id1.COUNT
 LOOP
      --dbms_output.put_line('-----Exception24: Trx id 1 = ' || b_trx_id1(j));
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
      msc_x_netting_pkg.G_EARLY_ORDER,
      msc_x_netting_pkg.G_EXCEP24,
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
      msc_x_netting_pkg.G_EARLY_ORDER,
      msc_x_netting_pkg.G_EXCEP23,
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

      l_threshold := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP24,
                     	b_publisher_id(j),
                  	b_publisher_site_id(j),
                  	b_item_id(j),
               		b_supplier_id(j),
               		b_supplier_site_id(j),
               		null,
               		null,
                     	b_po_key_date(j));

   IF b_po_key_date(j) > b_so_key_date(j) + l_threshold THEN
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
      msc_x_netting_pkg.G_LATE_ORDER,
      msc_x_netting_pkg.G_EXCEP2,
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
      msc_x_netting_pkg.G_LATE_ORDER,
      msc_x_netting_pkg.G_EXCEP1,
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


      --------------------------------------------------------------------------
      -- get the shipping control
      ---------------------------------------------------------------------------
      l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                    b_publisher_site_name(j),
                                    b_supplier_name(j),
                                    b_supplier_site_name(j));

      l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

      l_exception_type := msc_x_netting_pkg.G_EXCEP24;  --Replenishment from supplier before need date
      l_exception_group := msc_x_netting_pkg.G_EARLY_ORDER;
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
                                b_trx_id1(j),      --number1
                                b_trx_id2(j),      --number2
            			null, --l_customer_id,
            			null,
            			null, --l_customer_site_id,
            			null,
            			b_customer_item_name(j),
                                b_supplier_id(j),
                                b_supplier_name(j),
                                b_supplier_site_id(j),
                                b_supplier_site_name(j),
                                b_supplier_item_name(j),
            			b_po_qty(j),    --number1
            			b_tp_so_qty(j),      --number2
            			null,
            			l_threshold,
            			null,       --lead time
            			null,       --l_item_min,
            			null,       --l_item_max,
            			b_order_number(j),
            			b_release_number(j),
            			b_line_number(j),
            			b_end_order_number(j),
            			b_end_order_rel_number(j),
            			b_end_order_line_number(j),
            			b_po_creation_date(j),
            			b_so_creation_date(j),
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
      -----------------------------------------------------
      -- generate complement exception
      ----------------------------------------------------
      if (b_so_last_refnum(j) <= p_refresh_number) then
         --dbms_output.put_line('There is complement exception for ex23');
         l_complement_threshold:= msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP23,
               		b_supplier_id(j),
               		b_supplier_site_id(j),
               		b_item_id(j),
               		null,
               		null,
               		b_publisher_id(j),
               		b_publisher_site_id(j),
                        b_so_key_date(j));

      if b_po_key_date(j) > b_so_key_date(j) + l_complement_threshold THEN
         	l_exception_type := msc_x_netting_pkg.G_EXCEP23;  --Replenishment to cust before need date
              	l_exception_group := msc_x_netting_pkg.G_EARLY_ORDER;
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
                           b_trx_id2(j),
                           b_trx_id1(j),
                           b_publisher_id(j),
                           b_publisher_name(j),
                           b_publisher_site_id(j),
                           b_publisher_site_name(j),
                           b_customer_item_name(j),
                           null, --l_supplier_id,
                           null, --
                           null, --l_supplier_site_id,
                           null,
                           b_supplier_item_name(j),
                           b_so_qty(j), --number1
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
                           b_so_creation_date(j),
                           b_po_creation_date(j),
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
   END IF;
END LOOP;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' || msc_x_netting_pkg.get_message_type(24) ||
   ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total exceptions inserted for the group ' ||
 msc_x_netting_pkg.get_message_group(msc_x_netting_pkg.G_EARLY_ORDER) || ':' || l_inserted_record);

-- added exception handler
EXCEPTION
   WHEN OTHERS THEN
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING1_PKG.compute_early_order');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
	--dbms_output.put_line('Error ' || sqlerrm);
END compute_early_order;



------------------------------------------------------------------
--COMPUTE_FORECAST_MISMATCH
-------------------------------------------------------------------
PROCEDURE COMPUTE_FORECAST_MISMATCH(p_refresh_number in Number,
   t_company_list       	IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_company_site_list  	IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_customer_list   		IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_customer_site_list    	IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_supplier_list   		IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_supplier_site_list    	IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_item_list       		IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_group_list      		IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_type_list       		IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_trxid1_list     		IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_trxid2_list     		IN OUT NOCOPY  msc_x_netting_pkg.number_arr,
   t_date1_list      		IN OUT NOCOPY  msc_x_netting_pkg.date_arr,
   t_date2_list      		IN OUT NOCOPY  msc_x_netting_pkg.date_arr,
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

l_start_date      		Date;
l_end_date     			Date;
l_bucket_type     		Number;
l_total_forecast  		Number;
l_tp_total_forecast  		Number;
l_total_sales_fsct   		Number;
l_tp_total_sales_fsct   	Number;
l_posting_total_forecast   	Number;
l_posting_total_sales_fsct    	Number;
l_exception_type  		Number;
l_exception_group 		Number;
l_generate_complement   	Boolean;
l_updated      			Number;
l_complement_threshold  	Number;
l_cutoff_ref_num  		Number;
l_threshold1      		Number;
l_threshold2      		Number;
l_exception_type_name   	fnd_lookup_values.meaning%type;
l_exception_group_name  	fnd_lookup_values.meaning%type;
l_sum       			Number;
l_shipping_control		Number;
l_exception_basis		msc_x_exception_details.exception_basis%type;
l_inserted_record		Number;

BEGIN
l_sum       			:= 0;
l_inserted_record		:= 0;

--dbms_output.put_line('Exception 19 and 20');
open exception_19_20( p_refresh_number);
   fetch exception_19_20
   BULK COLLECT INTO b_customer_id,
      b_customer_name,
      b_customer_site_id,
      b_customer_site_name,
      b_customer_item_name,
      b_customer_item_desc,
      b_publisher_id,
      b_publisher_name,
      b_publisher_site_id,
      b_publisher_site_name,
      b_item_id,
      b_item_name,
      b_item_desc,
      b_supplier_item_name;
CLOSE exception_19_20;

IF (b_customer_id is not null and b_customer_id.COUNT > 0) THEN
FOR j in 1..b_customer_id.COUNT
LOOP

---------------------------------------------------------------------------
 -- Check if the sales forecast data does not exist in msc_sup_dem_entries
 -- at all and should not going through the bucketing loop
 --------------------------------------------------------------------------
   BEGIN
   		select nvl(sum(sd.quantity),-999999)
            	into l_sum
            	from msc_sup_dem_entries sd
            	where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
            	and sd.publisher_id = b_publisher_id(j)
            	and sd.publisher_site_id = b_publisher_site_id(j)
      		and sd.customer_id = b_customer_id(j)
      		and sd.customer_site_id = b_customer_site_id(j)
            	and sd.inventory_item_id = b_item_id(j)
            	and sd.publisher_order_type = msc_x_netting_pkg.SALES_FORECAST;
   EXCEPTION
   when no_data_found then
      l_sum := -999999;
    when others then
      l_sum := -999999;
   END;

   IF (l_sum <> -999999 ) THEN

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
      msc_x_netting_pkg.G_FORECAST_MISMATCH,
      msc_x_netting_pkg.G_EXCEP19,
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

   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      b_customer_id(j),
      b_customer_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_FORECAST_MISMATCH,
      msc_x_netting_pkg.G_EXCEP20,
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



      l_threshold1 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP19,
                  	b_publisher_id(j),
               		b_publisher_site_id(j),
               		b_item_id(j),
            		null,
            		null,
            		b_customer_id(j),
            		b_customer_site_id(j),
                     	null);
      l_threshold2 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP20,
                     	b_publisher_id(j),
                  	b_publisher_site_id(j),
                  	b_item_id(j),
               		null,
               		null,
               		b_customer_id(j),
               		b_customer_site_id(j),
                     	null);

      l_generate_complement := msc_x_netting_pkg.generate_complement_exception(b_customer_id(j),
            		b_customer_site_id(j),
                        b_item_id(j),
                        p_refresh_number,
                        msc_x_netting_pkg.DEMAND_PLANNING,
                        msc_x_netting_pkg.SELLER);
    /*-----------------------------------------------------
    | get the bucket logic
    ------------------------------------------------------*/

    l_cutoff_ref_num := p_refresh_number;
    MSC_EXCHANGE_BUCKETING.calculate_netting_bucket(msc_x_netting_pkg.G_SR_INSTANCE_ID,
            b_customer_id(j),
            b_customer_site_id(j),
            b_publisher_id(j),      --supplier_id
            b_publisher_site_id(j), --supplier_site_id
            b_item_id(j),
            msc_x_netting_pkg.DEMAND_PLANNING,
            l_cutoff_ref_num);


    --------------------------------------------------------------------------
    -- get the shipping control
    ---------------------------------------------------------------------------
    l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_customer_name(j),
                                      b_customer_site_name(j),
                                      b_publisher_name(j),
                                      b_publisher_site_name(j));

    l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));


    open time_bkts;
    loop
       fetch time_bkts
       into l_start_date,l_end_date,l_bucket_type;
       exit when time_bkts%NOTFOUND;


       BEGIN
       		--------------------------------------------------------------------------
       		-- at a certain bucket, if the other party has no data at all, should
       		-- consider the exception.  That means set the sum to 0
       		--------------------------------------------------------------------------
      		select nvl(sum(sd.tp_quantity),0), --supplier centric (look at the tp qty)
         	nvl(sum(sd.primary_quantity),0),
         	nvl(sum(sd.quantity),0)
      		into l_tp_total_forecast, l_total_forecast, l_posting_total_forecast
      		from msc_sup_dem_entries sd
      		where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
      		and sd.publisher_id = b_customer_id(j)
      		and sd.publisher_site_id = b_customer_site_id(j)
      		and sd.inventory_item_id = b_item_id(j)
      		and sd.publisher_order_type = msc_x_netting_pkg.SALES_FORECAST
      		and sd.supplier_id = b_publisher_id(j)
      		and sd.supplier_site_id = b_publisher_site_id(j)
      		and trunc(sd.key_date) between l_start_date and l_end_date
      		and sd.last_refresh_number <= l_cutoff_ref_num;

      EXCEPTION
      	when NO_DATA_FOUND then
         	l_total_forecast := 0;
         	l_tp_total_forecast := 0;
         	l_posting_total_forecast := 0;
      END;

      BEGIN
      		select nvl(sum(sd.primary_quantity),0),
         	nvl(sum(sd.tp_quantity),0),
         	nvl(sum(sd.quantity),0)
            	into l_total_sales_fsct, l_tp_total_sales_fsct, l_posting_total_sales_fsct
            	from msc_sup_dem_entries sd
            	where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
            	and sd.publisher_id = b_publisher_id(j)
            	and sd.publisher_site_id = b_publisher_site_id(j)
      		and sd.customer_id = b_customer_id(j)
      		and sd.customer_site_id = b_customer_site_id(j)
            	and sd.inventory_item_id = b_item_id(j)
            	and sd.publisher_order_type = msc_x_netting_pkg.SALES_FORECAST
            	and trunc(sd.key_date) between l_start_date and l_end_date
            	and sd.last_refresh_number <= l_cutoff_ref_num;

      EXCEPTION
            when NO_DATA_FOUND then
               l_total_sales_fsct := 0;
               l_tp_total_sales_fsct := 0;
               l_posting_total_sales_fsct := 0;
      END;

      if ((l_tp_total_forecast - l_total_sales_fsct) > (l_tp_total_forecast * l_threshold1/100)) then
									--- Bug# 4629582

      --------------------------------------------------------
      -- clean up the opposite exception and its complement
      --------------------------------------------------------
      msc_x_netting_pkg.add_to_delete_tbl(
         b_customer_id(j),
         b_customer_site_id(j),
         null,
         null,
         b_publisher_id(j),
         b_publisher_site_id(j),
         b_item_id(j),
         msc_x_netting_pkg.G_FORECAST_MISMATCH,
         msc_x_netting_pkg.G_EXCEP21,
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

      msc_x_netting_pkg.add_to_delete_tbl(
         b_customer_id(j),
         b_customer_site_id(j),
         null,
         null,
         b_publisher_id(j),
         b_publisher_site_id(j),
         b_item_id(j),
         msc_x_netting_pkg.G_FORECAST_MISMATCH,
         msc_x_netting_pkg.G_EXCEP22,
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


      l_exception_type := msc_x_netting_pkg.G_EXCEP19;   --cust sales fcst > your sales fcst
      l_exception_group := msc_x_netting_pkg.G_FORECAST_MISMATCH;
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
             	null,         --l_trx_id1,
              	null,                   --l_trx_id2,
               	b_customer_id(j),
              	b_customer_name(j),
               	b_customer_site_id(j),
                b_customer_site_name(j),
              	b_customer_item_name(j),
              	null,                   --l_supplier_id
               	null,
               	null,                   --l_supplier_site_id
               	null,
               	b_supplier_item_name(j),
               	l_total_sales_fsct,
         	l_tp_total_forecast,
         	null,
              	l_threshold1,
         	null,       --lead time
         	null,       --item min
         	null,       --item_max
         	null,       --l_order_number,
             	null,       --l_release_number,
             	null,         --l_line_number,
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

      if l_generate_complement then
         --dbms_output.put_line('in 19 complement');
         l_complement_threshold:= msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP22,
               b_customer_id(j),
               b_customer_site_id(j),
               b_item_id(j),
               b_publisher_id(j),
               b_publisher_site_id(j),
               null,
               null,
               null);

        if ((l_tp_total_forecast - l_total_sales_fsct) > (l_tp_total_forecast * l_complement_threshold/100 )) then
											--- Bug# 4629582
            l_exception_type := msc_x_netting_pkg.G_EXCEP22;   --sup sales fcst < your sales fcst
            l_exception_group := msc_x_netting_pkg.G_FORECAST_MISMATCH;
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
                       	null,                   --l_trx_id1,
                       	null,                   --l_trx_id2,
                        null,       --l_customer_id,
                        null,
                        null,       --l_customer_site_id,
                        null,
                        b_customer_item_name(j),
                      	b_publisher_id(j),      --l_supplier_id
                      	b_publisher_name(j),
                        b_publisher_site_id(j),      --l_supplier_site_id
                        b_publisher_site_name(j),
                        b_supplier_item_name(j),
                    	l_tp_total_sales_fsct,
                        l_total_forecast,
                        null,
                        l_complement_threshold,
                        null,       --lead time
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
              end if;
          end if; /* generate complement */


       elsif
         ((l_total_sales_fsct - l_tp_total_forecast ) > (l_tp_total_forecast * l_threshold2/100 )) then
									--- Bug# 4629582

      -----------------------------------------------------
      --clean up the opposite exception and its complement
      -----------------------------------------------------
      msc_x_netting_pkg.add_to_delete_tbl(
         b_customer_id(j),
         b_customer_site_id(j),
         null,
         null,
         b_publisher_id(j),
         b_publisher_site_id(j),
         b_item_id(j),
         msc_x_netting_pkg.G_FORECAST_MISMATCH,
         msc_x_netting_pkg.G_EXCEP21,
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

      msc_x_netting_pkg.add_to_delete_tbl(
         b_customer_id(j),
         b_customer_site_id(j),
         null,
         null,
         b_publisher_id(j),
         b_publisher_site_id(j),
         b_item_id(j),
         msc_x_netting_pkg.G_FORECAST_MISMATCH,
         msc_x_netting_pkg.G_EXCEP22,
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


      l_exception_type := msc_x_netting_pkg.G_EXCEP20;   --cust sales fsct < your sales fcst
      l_exception_group := msc_x_netting_pkg.G_FORECAST_MISMATCH;
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
                       	b_customer_id(j),
                        b_customer_name(j),
                       	b_customer_site_id(j),
                      	b_customer_site_name(j),
                       	b_customer_item_name(j),
                        null,                   --l_supplier_id
                        null,
                        null,                   --l_supplier_site_id
                        null,
                        b_supplier_item_name(j),
            		l_total_sales_fsct,
            		l_tp_total_forecast,
            		null,
                       	l_threshold2  ,
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

      if l_generate_complement then
         l_complement_threshold:= msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP21,
               b_customer_id(j),
               b_customer_site_id(j),
               b_item_id(j),
               b_publisher_id(j),
               b_publisher_site_id(j),
               null,
               null,
               null);

           if ((l_total_sales_fsct - l_tp_total_forecast) > (l_tp_total_forecast * l_complement_threshold/100 )) then
										--- Bug# 4629582

            l_exception_type := msc_x_netting_pkg.G_EXCEP21;   --supp sales fcst is > your sales fcst
            l_exception_group := msc_x_netting_pkg.G_FORECAST_MISMATCH;
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
                               	null,                   --l_trx_id1,
                              	null,                   --l_trx_id2,
                               	null,       --l_customer_id,
                              	null,
                                null,       --l_customer_site_id,
                            	null,
                               	b_customer_item_name(j),
                               	b_publisher_id(j),      --l_supplier_id
                            	b_publisher_name(j),
                              	b_publisher_site_id(j),      --l_supplier_site_id
                                b_publisher_site_name(j),
                             	b_supplier_item_name(j),
                             	l_tp_total_sales_fsct,
                             	l_total_forecast,
                              	null,
                                l_complement_threshold,
                                null,       --lead time
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
           end if;
      end if; /* generate complement */
      end if;
   end loop;
   close time_bkts;
   END IF;
END LOOP;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(19) ||
',' || msc_x_netting_pkg.get_message_type(20) || ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

--=======================================================================================
--for Supplier DEMAND planning (exception 5.3 and 5.4
--======================================================================================
--dbms_output.put_line('exception 21 and 22');
open exception_21_22(p_refresh_number);
   fetch exception_21_22
   BULK COLLECT INTO b_supplier_id,
      b_supplier_name,
      b_supplier_site_id,
      b_supplier_site_name,
      b_supplier_item_name,
      b_supplier_item_desc,
      b_publisher_id,
      b_publisher_name,
      b_publisher_site_id,
      b_publisher_site_name,
      b_item_id,
      b_item_name,
      b_item_desc,
      b_customer_item_name;

CLOSE exception_21_22;
IF (b_item_id is not null and b_item_id.COUNT > 0) THEN
FOR j in 1..b_item_id.COUNT
LOOP

---------------------------------------------------------------------------
 -- Check if the sales forecast data does not exist in msc_sup_dem_entries
 -- at all and should not going through the bucketing loop
 --------------------------------------------------------------------------
   BEGIN
         	select  nvl(sum(sd.quantity),-999999)
         	into  l_sum
        	from   msc_sup_dem_entries sd
        	where  sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
        	and    sd.publisher_id = b_publisher_id(j)
        	and    sd.publisher_site_id = b_publisher_site_id(j)
   		and   sd.supplier_id = b_supplier_id(j)
   		and   sd.supplier_site_id = b_supplier_site_id(j)
   		and   sd.inventory_item_id = b_item_id(j)
   		and   sd.publisher_order_type = msc_x_netting_pkg.SALES_FORECAST;

   EXCEPTION
   when no_data_found then
      l_sum := -999999;
   when others then
      l_sum := -99999;
   END;

   IF (l_sum <> -999999) THEN


   --========================================================
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
         msc_x_netting_pkg.G_FORECAST_MISMATCH,
         msc_x_netting_pkg.G_EXCEP21,
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

   msc_x_netting_pkg.add_to_delete_tbl(
         b_publisher_id(j),
         b_publisher_site_id(j),
         null,
         null,
         b_supplier_id(j),
         b_supplier_site_id(j),
         b_item_id(j),
         msc_x_netting_pkg.G_FORECAST_MISMATCH,
         msc_x_netting_pkg.G_EXCEP22,
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


   l_threshold1 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP21,
                  	b_publisher_id(j),
               		b_publisher_site_id(j),
               		b_item_id(j),
            		b_supplier_id(j),
            		b_supplier_site_id(j),
            		null,
            		null,
                     	null);
   l_threshold2 := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP22,
                     	b_publisher_id(j),
                  	b_publisher_site_id(j),
                  	b_item_id(j),
               		b_supplier_id(j),
               		b_supplier_site_id(j),
               		null,
               		null,
                     	null);

   l_generate_complement := msc_x_netting_pkg.generate_complement_exception(b_supplier_id(j),
            b_supplier_site_id(j),
            b_item_id(j),
            p_refresh_number,
            msc_x_netting_pkg.DEMAND_PLANNING,
            msc_x_netting_pkg.BUYER);


   /*------------------------------------------------
     | get the bucketing range
     ------------------------------------------------*/
   l_cutoff_ref_num := p_refresh_number;

   MSC_EXCHANGE_BUCKETING.calculate_netting_bucket(msc_x_netting_pkg.G_SR_INSTANCE_ID,
               b_publisher_id(j),         --customer
               b_publisher_site_id(j),
               b_supplier_id(j),
               b_supplier_site_id(j),
               b_item_id(j),
               msc_x_netting_pkg.DEMAND_PLANNING,
               l_cutoff_ref_num);

   --------------------------------------------------------------------------
   -- get the shipping control
   ---------------------------------------------------------------------------
   l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                      b_publisher_site_name(j),
                                      b_supplier_name(j),
                                      b_supplier_site_name(j));

   l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));


   open time_bkts;
       loop
       fetch time_bkts
                  into l_start_date,
                  l_end_date,
         	  l_bucket_type;
       exit when time_bkts%NOTFOUND;

       		--------------------------------------------------------------------------
       		-- at a certain bucket, if the other party has no data at all, should
       		-- consider the exception.  That means set the sum to 0
       		--------------------------------------------------------------------------
       BEGIN
                select nvl(sum(sd.primary_quantity),0),
                  nvl(sum(sd.tp_quantity),0) ,
                  nvl(sum(sd.quantity),0)
                into l_total_forecast, l_tp_total_forecast, l_posting_total_forecast
          	from msc_sup_dem_entries sd
       		where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
                and sd.publisher_id = b_publisher_id(j)
                and sd.publisher_site_id = b_publisher_site_id(j)
            	and sd.supplier_id = b_supplier_id(j)
            	and sd.supplier_site_id = b_supplier_site_id(j)
            	and sd.inventory_item_id = b_item_id(j)
            	and sd.publisher_order_type = msc_x_netting_pkg.SALES_FORECAST
            	and trunc(sd.key_date) between l_start_date and l_end_date
            	and sd.last_refresh_number <= l_cutoff_ref_num;

       EXCEPTION
              when NO_DATA_FOUND then
                           l_total_forecast := 0;
                           l_tp_total_forecast := 0;
                           l_posting_total_forecast := 0;
       END;

       BEGIN
           select nvl(sum(sd.tp_quantity),0),
            nvl(sum(sd.primary_quantity),0),
            nvl(sum(sd.quantity),0)
           into l_tp_total_sales_fsct, l_total_sales_fsct, l_posting_total_sales_fsct
           from msc_sup_dem_entries sd
           where sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
           and sd.publisher_id = b_supplier_id(j)
           and sd.publisher_site_id = b_supplier_site_id(j)
           and sd.customer_id = b_publisher_id(j)
           and sd.customer_site_id = b_publisher_site_id(j)
           and sd.inventory_item_id = b_item_id(j)
           and sd.publisher_order_type = msc_x_netting_pkg.SALES_FORECAST
           and trunc(sd.key_date) between l_start_date and l_end_date
           and sd.last_refresh_number <= l_cutoff_ref_num;


       EXCEPTION
                  when NO_DATA_FOUND then
                           l_total_sales_fsct := 0;
                           l_tp_total_sales_fsct := 0;
                           l_posting_total_sales_fsct := 0;
       END;

        if ((l_total_forecast - l_tp_total_sales_fsct) > (l_total_forecast * l_threshold1/100 )) then
								--- Bug#4629582

      --======================================================
         -- clean up the oppositeexception and its complement
         --======================================================
      msc_x_netting_pkg.add_to_delete_tbl(
         b_supplier_id(j),
         b_supplier_site_id(j),
         b_publisher_id(j),
         b_publisher_site_id(j),
         null,
         null,
         b_item_id(j),
         msc_x_netting_pkg.G_FORECAST_MISMATCH,
         msc_x_netting_pkg.G_EXCEP19,
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

      msc_x_netting_pkg.add_to_delete_tbl(
         b_supplier_id(j),
         b_supplier_site_id(j),
         b_publisher_id(j),
         b_publisher_site_id(j),
         null,
         null,
         b_item_id(j),
         msc_x_netting_pkg.G_FORECAST_MISMATCH,
         msc_x_netting_pkg.G_EXCEP20,
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

      l_exception_type := 22; --sup sales fcst < your sales fcst
      l_exception_group := msc_x_netting_pkg.G_FORECAST_MISMATCH;
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
                         null,                   --l_trx_id1,
                         null,                   --l_trx_id2,
                         null,         --l_customer_id,
                         null,
                         null,         --l_customer_site_id,
                         null,
                         b_customer_item_name(j),
                         b_supplier_id(j),
                         b_supplier_name(j),
                         b_supplier_site_id(j),
                         b_supplier_site_name(j),
                         b_supplier_item_name(j),
                         l_tp_total_sales_fsct,
                         l_total_forecast,
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
      if l_generate_complement then
                  --dbms_output.put_line('In complement exception 22');
               l_complement_threshold:= msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP19,
               		b_supplier_id(j),
               		b_supplier_site_id(j),
               		b_item_id(j),
               		null,
               		null,
               		b_publisher_id(j),
               		b_publisher_site_id(j),
                        null);

       if ((l_total_forecast - l_tp_total_sales_fsct) > (l_total_forecast * l_complement_threshold/100 )) then
										--- Bug# 4629582

            l_exception_type := msc_x_netting_pkg.G_EXCEP19;   --cust sales fcst > your sales fcst
            l_exception_group := msc_x_netting_pkg.G_FORECAST_MISMATCH;
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
                            	null,         --l_trx_id1,
                            	null,                   --l_trx_id2,
                            	b_publisher_id(j),     --l_customer_id,
                            	b_publisher_name(j),
                            	b_publisher_site_id(j),   --l_customer_site_id,
                            	b_publisher_site_name(j),
                            	b_customer_item_name(j),
                            	null,                   --l_supplier_id
                            	null,
                            	null,                   --l_supplier_site_id
                            	null,
                            	b_supplier_item_name(j),
                  		l_total_sales_fsct,
                  		l_tp_total_forecast,
                  		null,
                            	l_complement_threshold,
                  		null,       --lead time
                  		null,       --item min
                  		null,       --item_max
                  		null,       --l_order_number,
                            	null,         --l_release_number,
                            	null,         --l_line_number,
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
            end if;
          end if;   --- end generate complement exception

      elsif
	(( l_tp_total_sales_fsct - l_total_forecast ) > (l_total_forecast * l_threshold2/100 )) then

								--- Bug# 4629582

      --======================================================
         -- clean up the oppositeexception and its complement
         --======================================================

      msc_x_netting_pkg.add_to_delete_tbl(
         b_supplier_id(j),
         b_supplier_site_id(j),
         b_publisher_id(j),
         b_publisher_site_id(j),
         null,
         null,
         b_item_id(j),
         msc_x_netting_pkg.G_FORECAST_MISMATCH,
         msc_x_netting_pkg.G_EXCEP19,
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

      msc_x_netting_pkg.add_to_delete_tbl(
         b_supplier_id(j),
         b_supplier_site_id(j),
         b_publisher_id(j),
         b_publisher_site_id(j),
         null,
         null,
         b_item_id(j),
         msc_x_netting_pkg.G_FORECAST_MISMATCH,
         msc_x_netting_pkg.G_EXCEP20,
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


            l_exception_type := msc_x_netting_pkg.G_EXCEP21;   --Sup sales fcst > your sales fcst
            l_exception_group := msc_x_netting_pkg.G_FORECAST_MISMATCH;
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
                      	null,                   --l_trx_id1,
                      	null,                   --l_trx_id2,
                      	null,         --l_customer_id,
                      	null,
                      	null,         --l_customer_site_id,
                      	null,
                      	b_customer_item_name(j),
                      	b_supplier_id(j),
                      	b_supplier_name(j),
                      	b_supplier_site_id(j),
                      	b_supplier_site_name(j),
                      	b_supplier_item_name(j),
                      	l_tp_total_sales_fsct,
                      	l_total_forecast,
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

      if l_generate_complement then
         --dbms_output.put_line('In complement exception 21');
         l_complement_threshold:= msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP20,
               		b_supplier_id(j),
               		b_supplier_site_id(j),
               		b_item_id(j),
               		null,
               		null,
               		b_publisher_id(j),
               		b_publisher_site_id(j),
                        null);

              if ((l_tp_total_sales_fsct - l_total_forecast) > (l_total_forecast * l_complement_threshold/100 )) then
										--- Bug# 4629582

                l_exception_type := msc_x_netting_pkg.G_EXCEP20;   --cust sales fcst < your sales fcst
                l_exception_group := msc_x_netting_pkg.G_FORECAST_MISMATCH;
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
                            	null,         --l_trx_id1,
                            	null,                   --l_trx_id2,
                            	b_publisher_id(j),     --l_customer_id,
                            	b_publisher_name(j),
                            	b_publisher_site_id(j),   --l_customer_site_id,
                            	b_publisher_site_name(j),
                            	b_customer_item_name(j),
                            	null,                   --l_supplier_id
                            	null,
                            	null,                   --l_supplier_site_id
                            	null,
                            	b_supplier_item_name(j),
                  		l_total_sales_fsct,
                  		l_tp_total_forecast,
                  		null,
                            	l_complement_threshold,
                  		null,       --lead time
                  		null,       --item min
                  		null,       --item_max
                  		null,       --l_order_number,
                  	      	null,         --l_release_number,
                            	null,         --l_line_number,
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
           end if;
      end if; /** generate complement exception */
     end if;
   end loop;
   close time_bkts;
END IF;
END LOOP;
END IF;


FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(21) ||
   ',' || msc_x_netting_pkg.get_message_type(22) || ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total exceptions inserted for the group ' ||
 msc_x_netting_pkg.get_message_group(msc_x_netting_pkg.G_FORECAST_MISMATCH) || ':' || l_inserted_record);

-- added exception handler
EXCEPTION
   WHEN OTHERS THEN
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING1_PKG.compute_forecast_mismatch');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);


END COMPUTE_FORECAST_MISMATCH;

END MSC_X_NETTING1_PKG;


/
