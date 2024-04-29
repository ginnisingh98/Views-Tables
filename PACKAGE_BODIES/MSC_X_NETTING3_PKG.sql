--------------------------------------------------------
--  DDL for Package Body MSC_X_NETTING3_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_NETTING3_PKG" AS
/* $Header: MSCXEX3B.pls 120.1 2006/02/09 04:24:39 pragarwa noship $ */


--==========================================================================
--Group 3: Response  required
--==========================================================================
----------------------------------------------------------------------------
--3.1 Response required for customer po: exception_11
--3.2 Supplier response required for po: exception_31
----------------------------------------------------------------------------
CURSOR exception_11_31 IS
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
        msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP11,
        	sd.supplier_id,
        	sd.supplier_site_id,
        	sd.inventory_item_id,
        	null,
        	null,
        	sd.publisher_id,
        	sd.publisher_site_id,
        	sd.key_date),
   	msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP31,
               	sd.publisher_id,
            	sd.publisher_site_id,
            	sd.inventory_item_id,
         	sd.supplier_id,
         	sd.supplier_site_id,
         	null,
         	null,
                sd.key_date)
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND     msc_x_netting_pkg.does_so_exist(sd.order_number,
                        sd.release_number,
                        sd.line_number,
         		sd.supplier_id,
                        sd.supplier_site_id,
                        sd.publisher_id,
         		sd.publisher_site_id,
                        sd.inventory_item_id ) = 0
AND     sd.creation_date < sysdate
AND	nvl(sd.acceptance_required_flag,'Y') = 'Y';
--------------------------------------------------------------------------------------
-- change for the po acknowledgement:
-- if the acception_required_flag(PO) = 'Y' and also encounter response required exception,
-- raise it to the supplier.
-- if the acceptance_required_flag(PO) = 'N' and also encouter response required exception,
-- do not raise to the supplier.
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--3.4 Customer response required for so: exception_12 supplier centric
--3.3 Response required for supplier so: exception_32  customer centric
--
-------------------------------------------------------------------------------
CURSOR exception_12_32 IS
SELECT  sd.transaction_id,      -- need customer info only
        sd.publisher_id,
        sd.publisher_name,
        sd.publisher_site_id,
        sd.publisher_site_name,
        sd.inventory_item_id,
        sd.item_name,
        sd.item_description,
        sd.supplier_item_name,
        sd.supplier_item_description,
        sd.key_date,
        sd.ship_date,
        sd.receipt_date,
        sd.quantity,
        sd.primary_quantity,
        sd.tp_quantity,
        sd.order_number,
        sd.release_number,
        sd.line_number,
        sd.customer_id,
        sd.customer_name,
        sd.customer_site_id,
        sd.customer_site_name,
        sd.customer_item_name,
        sd.customer_item_description,
        sd.creation_date ,
   	msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP12,
               	sd.publisher_id,
            	sd.publisher_site_id,
            	sd.inventory_item_id,
         	null,
         	null,
         	sd.customer_id,
         	sd.customer_site_id,
                sd.key_date),
   	msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP32,
               sd.customer_id,
            	sd.customer_site_id,
            	sd.inventory_item_id,
         	sd.publisher_id,
         	sd.publisher_site_id,
         	null,
         	null,
               	sd.key_date)
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND   sd.publisher_order_type = msc_x_netting_pkg.SALES_ORDER
AND   msc_x_netting_pkg.does_po_exist(sd.end_order_number,
               	sd.end_order_rel_number,
               	sd.end_order_line_number,
        	sd.customer_id,
               	sd.customer_site_id,
               	sd.publisher_id,
        	sd.publisher_site_id,
               	sd.inventory_item_id) = 0
AND     sd.creation_date  < sysdate;

--==================================================================
--Group 4: Potential late orders
--==================================================================
/* Get all the po with the netchange */
CURSOR tp_viewers_po(p_refresh_number IN Number) IS
SELECT  sd.transaction_id,
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
   	sd.creation_date
FROM    msc_sup_dem_entries sd
WHERE   sd.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND     sd.last_refresh_number > p_refresh_number;

/* Cursor level_1_supp_po fetches the first level of
   supplier's PO  that have been created
   Note: The original pegged transactions might generate exception
   for the late order already. Therefore, no need to show that exception
   here.
   Get the first level po to peg down the tree to find the late order
   exceptions.
*/
CURSOR level_1_supp_po(p_order_number IN Varchar2,
                        p_release_number IN Varchar2,
                        p_line_number IN Varchar2,
         		p_supplier_id IN Number,
                        p_supplier_site_id IN Number,
                        p_item_id IN Number) IS
SELECT  distinct sd2.transaction_id      --po trx-id
FROM    msc_sup_dem_entries sd1,
        msc_sup_dem_entries sd2
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.plan_id = sd2.plan_id
AND     sd1.publisher_order_type = msc_x_netting_pkg.SALES_ORDER     --SO
AND   	sd1.publisher_id = p_supplier_id
AND     sd1.publisher_site_id = p_supplier_site_id
AND   	sd1.inventory_item_id = p_item_id
AND   	sd1.inventory_item_id = sd2.inventory_item_id
AND     sd1.end_order_number = p_order_number
AND     nvl(sd1.end_order_rel_number, -1) =
                nvl(p_release_number, -1)
AND     nvl(sd1.end_order_line_number, -1) =
                nvl(p_line_number, -1)
AND     sd2.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER     --PO
AND     nvl(sd1.order_number, -1) =
                nvl(sd2.end_order_number, -1)
AND     nvl(sd1.release_number, -1) =
                nvl(sd2.end_order_rel_number, -1)
AND     nvl(sd1.line_number, -1) =
                nvl(sd2.end_order_line_number, -1);

/* Cursor TP_VIEWERS_DEPENDENT_ORDERS fetches the distinct transactions
   that have been directly or indirectly pegged to the
   first level suppliers PO
*/

CURSOR tp_viewers_dependent_orders(p_transaction_id IN Number) IS
select  sd.transaction_id,
        sd.publisher_order_type,
      	sd.publisher_id,
        sd.publisher_site_id
FROM    msc_sup_dem_entries sd
START WITH sd.transaction_id = p_transaction_id
CONNECT BY sd.end_order_number = PRIOR sd.order_number
AND
    (
        sd.end_order_line_number IS NOT NULL AND
        sd.end_order_line_number = PRIOR sd.line_number
        OR
        sd.end_order_line_number IS NULL AND
        sd.publisher_id = sd.end_order_publisher_id AND
        sd.publisher_site_id = sd.end_order_publisher_site_id AND
        sd.inventory_item_id = PRIOR sd.inventory_item_id
        OR
        sd.end_order_line_number IS NULL AND
        sd.publisher_site_id <>  sd.end_order_publisher_site_id

     )
AND nvl(sd.release_number, -1) = nvl(PRIOR sd.end_order_rel_number, -1)
AND (    (sd.end_order_publisher_id IS NOT NULL AND
         sd.end_order_type IS NOT NULL AND
        sd.end_order_publisher_id = PRIOR sd.publisher_id AND
         sd.end_order_publisher_site_id = PRIOR sd.publisher_site_id AND
         sd.end_order_type = PRIOR sd.publisher_order_type)
     OR
         (sd.end_order_publisher_id IS NULL AND
         sd.end_order_type IS NOT NULL AND
         sd.publisher_id = PRIOR sd.publisher_id AND
      sd.publisher_site_id = PRIOR sd.publisher_site_id)
     );

/** Got the po transaction_id and need find out the pegging so
 ** which has the condition : so.key_date > po.key_date
**/

CURSOR exception_13(p_company_id IN Number,
         	p_company_site_id IN Number,
                p_item_id IN Number,
                p_transaction_id IN Number) IS
SELECT  distinct sd1.transaction_id,
        sd1.supplier_id,
        sd1.supplier_name,
        sd1.supplier_site_id,
        sd1.supplier_site_name,
        sd1.supplier_item_name,
        sd1.key_date,
        sd1.ship_date,
        sd1.receipt_date,
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
        sd2.creation_date,
   	msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP13,
                        sd1.publisher_id,
                        sd1.publisher_site_id,
                        sd1.inventory_item_id,
                        sd1.supplier_id,
                        sd1.supplier_site_id,
                        null,
                        null,
                        sd1.key_date)
FROM    msc_sup_dem_entries sd1,
        msc_sup_dem_entries sd2
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.plan_id = sd2.plan_id
AND     sd1.inventory_item_id = p_item_id
AND     sd1.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND     sd1.transaction_id = p_transaction_id   -- po trxid
AND   	sd1.publisher_id = sd2.customer_id
AND   	sd1.publisher_id = p_company_id
AND     sd1.publisher_site_id = sd2.customer_site_id
AND     sd1.publisher_site_id = p_company_site_id
AND     sd2.publisher_order_type = msc_x_netting_pkg.SALES_ORDER
AND   	sd2.inventory_item_id = sd1.inventory_item_id
AND     sd1.order_number = sd2.end_order_number
AND     nvl(sd1.release_number,-1) =
                        nvl(sd2.end_order_rel_number,-1)
AND     nvl(sd1.line_number,-1) =
                        nvl(sd2.end_order_line_number,-1)
AND     trunc(sd2.key_date) > trunc(sd1.key_date) +
   	msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP13,
                        sd1.publisher_id,
                        sd1.publisher_site_id,
                        sd1.inventory_item_id,
                        sd1.supplier_id,
                        sd1.supplier_site_id,
                        null,
                        null,
                        sd1.key_date);


-----------------------------------------------------------------
-- 11.5.10 new exception: (release 115.10)
-- Sales order at risk due to upstream lateness
-- purchase order at risk due to upstream lateness
-- (this is the same exception as
-- exception_13.  (but order at risk exception has the pegging in ascp)
------------------------------------------------------------------


/* Get all the so with the net change */
CURSOR exception_50_51 (p_refresh_number IN Number) IS
SELECT  sd1.transaction_id,
   sd2.transaction_id,
   sd1.publisher_id,
   sd1.publisher_name,
   sd1.publisher_site_id,
   sd1.publisher_site_name,
   sd1.inventory_item_id,
   sd1.item_name,
   sd1.item_description,
   sd1.supplier_id,
   sd1.supplier_name,
   sd1.supplier_site_id,
   sd1.supplier_site_name,
   sd1.supplier_item_name,
   sd1.supplier_item_description,
   sd1.quantity,
   sd2.quantity,
   sd1.key_date,
   sd1.ship_date,
   sd1.receipt_date,
   sd2.key_date,
   sd2.ship_date,
   sd2.receipt_date,
   sd1.end_order_number,
   sd1.end_order_rel_number,
   sd1.end_order_line_number,
   sd2.order_number,
   sd2.release_number,
   sd2.line_number,
   sd1.order_number,
   sd1.release_number,
   sd1.line_number
FROM    msc_sup_dem_entries sd1,
        msc_sup_dem_entries sd2
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.plan_id = sd2.plan_id
AND     sd1.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
AND     sd1.publisher_id = sd2.customer_id
AND     sd1.publisher_site_id = sd2.customer_site_id
AND     sd2.publisher_order_type = msc_x_netting_pkg.SALES_ORDER
AND     sd2.inventory_item_id = sd1.inventory_item_id
AND     sd1.order_number = sd2.end_order_number
AND     nvl(sd1.release_number,-1) =
                        nvl(sd2.end_order_rel_number,-1)
AND     nvl(sd1.line_number,-1) =
                        nvl(sd2.end_order_line_number,-1)
AND    (sd2.last_refresh_number > p_refresh_number OR
	sd1.last_refresh_number > p_refresh_number)
ORDER BY sd1.publisher_id, sd1.publisher_site_id, sd1.supplier_id, sd1.supplier_site_id, sd1.inventory_item_id; 	----lowest level of the pegging (which is the so)

/*-------------------------------------------------------------------------------------------------------
Traverse up to find the first pegging SO (first search in CP, if not exist search in ASCP)
-----------------------------------------------------------------------------------------------------------*/

CURSOR level_2_so_cp(p_order_number IN Varchar2,
                        p_release_number IN Varchar2,
                        p_line_number IN Varchar2,
        	        p_customer_id IN Number,
                        p_customer_site_id IN Number,
                        p_item_id IN Number) IS
SELECT  distinct sd1.transaction_id,      --SO trx-id
		sd1.publisher_id,
		sd1.publisher_name,
		sd1.publisher_site_id,
		sd1.publisher_site_name,
		sd1.supplier_item_name,
		sd1.inventory_item_id,
		sd1.item_name,
		sd1.item_description,
   		sd1.key_date,
   		sd1.ship_date,
   		sd1.receipt_date,
   		sd1.creation_date,
   		sd1.quantity,
   		sd1.primary_quantity,
   		sd1.tp_quantity,
   		sd1.order_number,
   		sd1.release_number,
   		sd1.line_number,
   		sd1.end_order_number,
   		sd1.end_order_rel_number,
   		sd1.end_order_line_number,
   		sd1.customer_id,
   		sd1.customer_name,
   		sd1.customer_site_id,
   		sd1.customer_site_name,
   		sd1.customer_item_name,
   		sd1.customer_item_description
FROM    msc_sup_dem_entries sd1
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.inventory_item_id = P_ITEM_ID
AND   	sd1.publisher_id =  p_customer_id    /* sbala P_SUPPLIER_ID */
AND    	sd1.publisher_site_id = p_customer_site_id /* sbala P_SUPPLIER_SITE_ID */
AND    	sd1.publisher_order_type =  msc_x_netting_pkg.SALES_ORDER
			/* sbala msc_x_netting_pkg.PURCHASE_ORDER */
AND	sd1.order_number = P_ORDER_NUMBER
AND	nvl(sd1.release_number,'-1') = nvl(P_RELEASE_NUMBER,'-1')
AND     nvl(sd1.line_number, '-1')  =  nvl(P_LINE_NUMBER,'-1');


/*-----------------------------------------------------------------------------------------------
  The pegging does not exist in CP; need to find the pegging in ASCP
------------------------------------------------------------------------------------------------*/

CURSOR  map_po_in_ascp (P_PLAN_ID IN NUMBER,
			P_ORDER_NUMBER IN VARCHAR2,
			P_RELEASE_NUMBER IN VARCHAR2,
			P_LINE_NUMBER IN VARCHAR2,
			P_ITEM_ID IN NUMBER,
			P_CUST_ID IN NUMBER,
			P_CUST_SITE_ID IN NUMBER,
			P_SUPP_ID IN NUMBER,
			P_SUPP_SITE_ID IN NUMBER) IS
SELECT 	SUP.TRANSACTION_ID	-- the 1st level of po transaction id in ASCP
FROM	msc_supplies sup,
		msc_companies c,
		msc_company_sites s,
		msc_trading_partners t,
		msc_trading_partner_maps m
WHERE      sup.plan_id =  P_PLAN_ID
AND	decode(instr(sup.order_number,'('),0, sup.order_number,substr(sup.order_number, 1, instr(sup.order_number,'(') - 1)) = P_ORDER_NUMBER
AND	sup.purch_line_num = P_LINE_NUMBER
AND	sup.inventory_item_id = P_ITEM_ID
AND	sup.order_type =  1
AND	c.company_id = P_CUST_ID
AND	s.company_site_id = P_CUST_SITE_ID
AND	t.sr_tp_id = sup.organization_id
AND	t.sr_instance_id = sup.sr_instance_id
AND	t.partner_type = 3
AND	m.tp_key = t.partner_id
AND	m.map_type = 2
AND	s.company_site_id = m.company_key
AND	c.company_id = s.company_id;

/*---------------------------------------------------------------------------------------------
 IF the po exists in ASCP, find all pegging existing in ASCP
-----------------------------------------------------------------------------------------------*/

CURSOR get_all_pegging (P_TRANSACTION_ID IN NUMBER,
 			P_PLAN_ID IN NUMBER) IS

SELECT  distinct p.pegging_id,
	p.sr_instance_id,
	p.organization_id,
	p.inventory_item_id,
	p.transaction_id,
	p.disposition_id,
	p.supply_type,
	p.demand_id
FROM	msc_full_pegging p
WHERE	p.plan_id = P_PLAN_ID
START WITH p.transaction_id = P_TRANSACTION_ID
CONNECT BY p.pegging_id = PRIOR p.prev_pegging_id
	AND p.plan_id = PRIOR p.plan_id
	AND p.sr_instance_id = PRIOR p.sr_instance_id
ORDER BY p.pegging_id desc;

-----------------------------------------------------------------
-- clean up old exception 50,51
----------------------------------------------------------------
CURSOR get_delete_row (p_transaction_id IN NUMBER) IS
SELECT company_id, company_site_id, customer_id, customer_site_id,
   	supplier_id, supplier_site_id, inventory_item_id,
   	transaction_id1, transaction_id2
FROM msc_x_exception_details
WHERE plan_id = -1
AND exception_type in (msc_x_netting_pkg.G_EXCEP50,msc_x_netting_pkg.G_EXCEP51)
AND transaction_id2 = p_transaction_id;

--------------------------------------------------------------
--Need to clean up the existing exceptions before regenerate
--new exception or the criteria is already satisfied.
--This query is for 4.2 and 4.3 only.
--------------------------------------------------------------
CURSOR  delete_old_exception (p_refresh_number IN Number) IS
SELECT distinct sd1.transaction_id,
   sd1.publisher_id,
   sd1.publisher_site_id,
   sd1.inventory_item_id,
   sd1.supplier_id,
   sd1.supplier_site_id
FROM    msc_sup_dem_entries sd1,
   	msc_trading_partners tp,
   	msc_trading_partner_maps map,
   	msc_item_suppliers itm,
   	msc_trading_partner_maps map2,
        msc_trading_partner_maps map3,
        msc_company_relationships r
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER     --
AND   	map.map_type = 2
AND   	map.company_key = sd1.publisher_site_id
AND   	map.tp_key = tp.partner_id
AND   	itm.plan_id = sd1.plan_id
AND   	itm.organization_id = tp.sr_tp_id
AND     itm.sr_instance_id = tp.sr_instance_id
AND   	tp.partner_type = 3
AND   	itm.supplier_id = map2.tp_key
AND   	nvl(itm.supplier_site_id, map3.tp_key) = map3.tp_key
AND     map2.map_type = 1
AND     map2.company_key = r.relationship_id
AND     r.subject_id = 1
AND     r.object_id = sd1.supplier_id
AND   	r.relationship_type = 2
AND   	map3.map_type = 3
AND   	map3.company_key = sd1.supplier_site_id      --supplier's lead time
AND   	itm.inventory_item_id = sd1.inventory_item_id;


------------------------------------------------------------------------------
--4.2  your po to your supplier requires lead time compression
--      (customer centric) : exception_14
-- need distinct in the query
-- past due exception should not have another potential late order exception
-- the complement exception type is 4

-- combine exception14 and exception15 in the computation part.
------------------------------------------------------------------------------
CURSOR exception_14(p_refresh_number In Number) IS
SELECT  distinct sd1.transaction_id,      -- need customer info only
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
        nvl(itm.processing_lead_time,0)
FROM    msc_sup_dem_entries sd1,
   	msc_trading_partners tp,
   	msc_trading_partner_maps map,
   	msc_item_suppliers itm,
   	msc_trading_partner_maps map2,
        msc_trading_partner_maps map3,
        msc_company_relationships r
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER     --
AND   	map.map_type = 2
AND   	map.company_key = sd1.publisher_site_id
AND   	map.tp_key = tp.partner_id
AND   	itm.plan_id = sd1.plan_id
AND   	itm.organization_id = tp.sr_tp_id
AND     itm.sr_instance_id = tp.sr_instance_id
AND   	tp.partner_type = 3
AND   	itm.supplier_id = map2.tp_key
AND   	nvl(itm.supplier_site_id, map3.tp_key) = map3.tp_key
AND     map2.map_type = 1
AND     map2.company_key = r.relationship_id
AND     r.subject_id = 1
AND     r.object_id = sd1.supplier_id
AND   	r.relationship_type = 2
AND   	map3.map_type = 3
AND   	map3.company_key = sd1.supplier_site_id      --supplier's lead time
AND   	itm.inventory_item_id = sd1.inventory_item_id
AND     sd1.last_refresh_number > p_refresh_number
ORDER BY sd1.publisher_id, sd1.publisher_site_id, sd1.supplier_id, sd1.supplier_site_id, sd1.inventory_item_id;

---------------------------------------------------------------------------------
--4.3  Your customer's po to you requires lead time compression
-- (supplier centric) : exception_15
-- past due exception should not have another
-- potential late order exception
-- the complement exception type is 3
---------------------------------------------------------------
CURSOR exception_15(p_refresh_number In Number) IS
SELECT  distinct sd1.transaction_id,      -- need customer info only
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
        nvl(itm.processing_lead_time,0)
FROM    msc_sup_dem_entries sd1,
   	msc_trading_partners tp,
   	msc_trading_partner_maps map,
   	msc_item_suppliers itm,
   	msc_trading_partner_maps map2,
        msc_trading_partner_maps map3,
        msc_company_relationships r
WHERE   sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND     sd1.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER     --
AND   	map.map_type = 2
AND   	map.company_key = sd1.publisher_site_id
AND   	map.tp_key = tp.partner_id
AND   	itm.plan_id = sd1.plan_id
AND   	itm.organization_id = tp.sr_tp_id
AND     itm.sr_instance_id = tp.sr_instance_id
AND   	tp.partner_type = 3
AND   	itm.supplier_id = map2.tp_key
AND   	nvl(itm.supplier_site_id, map3.tp_key) = map3.tp_key
AND     map2.map_type = 1
AND     map2.company_key = r.relationship_id
AND     r.subject_id = 1
AND     r.object_id = sd1.supplier_id
AND   	r.relationship_type = 2
AND   	map3.map_type = 3
AND   	map3.company_key = sd1.supplier_site_id
AND   	itm.inventory_item_id = sd1.inventory_item_id
AND   	not exists (SELECT * FROM msc_x_exception_details d
         WHERE   d.exception_type  = msc_x_netting_pkg.G_EXCEP3
         AND   d.transaction_id1 = sd1.transaction_id)
AND   nvl(sd1.last_refresh_number,-1) > nvl(p_refresh_number,-1)
ORDER BY sd1.publisher_id, sd1.publisher_site_id, sd1.supplier_id, sd1.supplier_site_id, sd1.inventory_item_id;
--------------------------------------------------------------------------------------
--4.4  your sales order requires lead time compression (supplier centric): exception_16
-- If past due exceptions exist then potential late order exceptions should not be generated.
-- ie: Delivery_date(SO) + threshold < order_placement_date + Leadtime compression
-- this exception requirement is not checking for any po existence

--------------------------------------------------------------------------------------
CURSOR exception_16(p_refresh_number In Number) IS
SELECT sd1.transaction_id,      -- need customer info only
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
        sd1.creation_date
FROM    msc_sup_dem_entries sd1
WHERE    sd1.plan_id = msc_x_netting_pkg.G_PLAN_ID
AND   	sd1.publisher_order_type = msc_x_netting_pkg.SALES_ORDER
AND    not exists (SELECT * FROM msc_x_exception_details d
         WHERE   d.exception_type  in (3,12)
         AND   d.transaction_id1 = sd1.transaction_id)
AND   sd1.last_refresh_number > p_refresh_number
ORDER BY sd1.publisher_id, sd1.publisher_site_id, sd1.customer_id, sd1.customer_site_id, sd1.inventory_item_id ;


 --======================================================================
 --COMPUTE_RESPONSE_REQUIRED
 --======================================================================
PROCEDURE COMPUTE_RESPONSE_REQUIRED (
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
and      exception_type in  (11,12,31,32)
group by plan_id,
        inventory_item_id,
       company_id,
       company_site_id,
       exception_group,
       exception_type;



  b_threshold1       		msc_x_netting_pkg.number_arr;
  b_threshold2       		msc_x_netting_pkg.number_arr;
  b_company_id       		msc_x_netting_pkg.number_arr;
  b_organization_id     	msc_x_netting_pkg.number_arr;
  b_trx_id1             	msc_x_netting_pkg.number_arr;
  b_trx_id2             	msc_x_netting_pkg.number_arr;
  b_publisher_id     		msc_x_netting_pkg.number_arr;
  b_publisher_site_id   	msc_x_netting_pkg.number_arr;
  b_item_id             	msc_x_netting_pkg.number_arr;
  b_po_qty              	msc_x_netting_pkg.number_arr;
  b_so_qty              	msc_x_netting_pkg.number_arr;
  b_tp_qty        		msc_x_netting_pkg.number_arr;
  b_posting_po_qty      	msc_x_netting_pkg.number_arr;
  b_posting_so_qty      	msc_x_netting_pkg.number_arr;
  b_customer_id         	msc_x_netting_pkg.number_arr;
  b_customer_site_id    	msc_x_netting_pkg.number_arr;
  b_supplier_id         	msc_x_netting_pkg.number_arr;
  b_supplier_site_id    	msc_x_netting_pkg.number_arr;
  b_lead_time           	msc_x_netting_pkg.number_arr;
  b_po_key_date     		msc_x_netting_pkg.date_arr;
  b_so_key_date        		msc_x_netting_pkg.date_arr;
  b_po_ship_date     		msc_x_netting_pkg.date_arr;
  b_so_ship_date        	msc_x_netting_pkg.date_arr;
  b_po_receipt_date     	msc_x_netting_pkg.date_arr;
  b_so_receipt_date        	msc_x_netting_pkg.date_arr;
  b_po_creation_date    	msc_x_netting_pkg.date_arr;
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
  b_end_order_num       	msc_x_netting_pkg.ordernumberList;
  b_end_order_rel_num      	msc_x_netting_pkg.releasenumList;
  b_end_order_line_num  	msc_x_netting_pkg.linenumList;

  l_exception_type         	Number;
  l_exception_group        	Number;
  l_exception_type_name    	fnd_lookup_values.meaning%type;
  l_exception_group_name   	fnd_lookup_values.meaning%type;
  l_exception_detail_id    	Number;
  l_exception_detail_id1      	Number;
  l_exception_detail_id2      	Number;
  l_exception_exists       	Number;
  l_late_order_exist1      	Number;
  l_late_order_exist2      	Number;
  l_late_order_exist    	Number;
  l_tp_response_exist1     	Number;
  l_tp_response_exist2     	Number;
  l_so_exist               	Number;
  l_dummy                  	Number;
  l_item_type        		Varchar2(20);
  l_item_key         		Varchar2(100);
  l_row           		Number;
  l_shipping_control		Number;
  l_exception_basis		msc_x_exception_details.exception_basis%type;

  l_inserted_record		Number;

--------------------------------------------------------
-- plsql table list for archive old exception
----------------------------------------------------------
TYPE        numberList  IS TABLE OF number;
u_plan_id      numberList;
u_inventory_item_id  numberList;
u_company_id      numberList;
u_company_site_id numberList;
u_exception_group numberList;
u_exception_type  numberList;
u_count        numberList;

 BEGIN


 l_item_type        		:= 'MSCSNDNT';
 l_item_key         		:= null;
 l_inserted_record		:= 0;



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
and   exception_type in (11,12,31,32);

update msc_item_exceptions
set version = version + 1
where plan_id = msc_x_netting_pkg.G_PLAN_ID
and   exception_type in (11,12,31,32);


 --dbms_output.put_line('Exception 11 and 31');
 open exception_11_31;
   fetch exception_11_31 BULK COLLECT INTO
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
                b_tp_qty,
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
                b_threshold1,
                b_threshold2;

 CLOSE exception_11_31;

 IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
 FOR j in 1..b_trx_id1.COUNT LOOP

   l_exception_type := msc_x_netting_pkg.G_EXCEP11;
   l_exception_group := msc_x_netting_pkg.G_RESPONSE_REQUIRED;
   l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
   l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

   IF (sysdate > b_po_creation_date(j) + b_threshold1(j)) THEN


        --------------------------------------------------------------------------
        -- get the shipping control
        ---------------------------------------------------------------------------
        l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                           b_publisher_site_name(j),
                                           b_supplier_name(j),
                                           b_supplier_site_name(j));

        l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));
        -----------------------------------------------------------------------
        -- exception 3.1 (supplier centric)
        -----------------------------------------------------------------------

        l_exception_detail_id1 := msc_x_netting_pkg.does_detail_excep_exist(b_supplier_id(j),
                         	b_supplier_site_id(j),
                     		b_item_id(j),
                                l_exception_type,
                                b_trx_id1(j));
        IF (l_exception_detail_id1 > 0 ) then
                         --dbms_output.put_line('----Detail exist for trx_id '||b_trx_id1(j));
                         --reset version=null indicate no need to resend notification
                         update msc_x_exception_details
                         set    version = null,
                           	threshold = b_threshold1(j),
                                date1 = b_po_receipt_date(j),
                           	date2 = b_po_ship_date(j),
                           	number1 = b_tp_qty(j)
                         where  exception_detail_id = l_exception_detail_id1;

                         --Need to reset the item exception.  The item exception
                         --might be archive for the same key
                         msc_x_netting_pkg.update_exceptions_summary(b_supplier_id(j),
                                                 b_supplier_site_id(j),
                                                 b_item_id(j),
                                                 l_exception_type,
                                                 l_exception_group);

        ELSE
                     --dbms_output.put_line('-----Exception11: Create exception' );

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
                                 null,                   --l_trx_id2,
                                 b_publisher_id(j),         --l_customer_id,
                                 b_publisher_name(j),
                                 b_publisher_site_id(j),     --l_customer_site_id,
                                 b_publisher_site_name(j),
                                 b_customer_item_name(j),
                                 null,       --l_supplier_id,
                                 null,
                                 null,       --l_supplier_site_id,
                                 null,
                                 b_supplier_item_name(j),
                                 b_tp_qty(j),
                                 null,
                                 null,
                                 b_threshold1(j),
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
   -----------------------------------------------------------------------
         -- exception 3.2(customer centric)
   -----------------------------------------------------------------------
   l_exception_detail_id2 := null;
   IF (sysdate > b_po_creation_date(j) + b_threshold2(j)) THEN
            l_exception_type := msc_x_netting_pkg.G_EXCEP31;
            l_exception_group := msc_x_netting_pkg.G_RESPONSE_REQUIRED;

            l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
            l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);
            l_exception_detail_id2 := msc_x_netting_pkg.does_detail_excep_exist(b_publisher_id(j),
                                                      b_publisher_site_id(j),
                                                      b_item_id(j),
                                                      l_exception_type,
                                                      b_trx_id1(j));
            IF (l_exception_detail_id2 > 0 ) then
                          --dbms_output.put_line('----Detail exist for trx_id '||b_trx_id1(j));
                          --reset version=null indicate no need to resend notification
                          update msc_x_exception_details
                          set    	version = null,
                            		threshold = b_threshold2(j),
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
                     --dbms_output.put_line('-----Exception31: Create exception' );

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
                                null,               --l_customer_id,
                                null,
                                null,         --l_customer_site_id,
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
                                b_threshold2(j),
                                null,         --lead time
              			null,        --l_item_min,
              			null,        --l_item_max,
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
         END IF;  -- exception31

 END LOOP;
 END IF;

 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(11) ||
        msc_x_netting_pkg.get_message_type(31) || ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));


 l_exception_detail_id1 := null;
 l_exception_detail_id2 := null;
 l_exception_exists := null;


 open exception_12_32;
        fetch exception_12_32 BULK COLLECT INTO
                b_trx_id1,
                                 b_publisher_id,      --so company
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
                                 b_tp_qty,
                                 b_order_number,
                                 b_release_number,
                                 b_line_number,
                                 b_customer_id,                  --po com
                                 b_customer_name,
                                 b_customer_site_id,
                                 b_customer_site_name,
                                 b_customer_item_name,
                                 b_customer_item_desc,
                                 b_so_creation_date,
                                 b_threshold1,
                                 b_threshold2;
 CLOSE exception_12_32;

 IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
 FOR j in 1..b_trx_id1.COUNT LOOP

   l_exception_type := msc_x_netting_pkg.G_EXCEP12;
   l_exception_group := msc_x_netting_pkg.G_RESPONSE_REQUIRED;
   l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
   l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

   IF (sysdate > b_so_creation_date(j) + b_threshold1(j)) THEN

         --------------------------------------------------------------------------
         -- get the shipping control
         ---------------------------------------------------------------------------
         l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_customer_name(j),
                                            b_customer_site_name(j),
                                            b_publisher_name(j),
                                            b_publisher_site_name(j));

         l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

      -------------------------------------------------------------
      -- exception 12 (supplier centric)
      --------------------------------------------------------------
               l_exception_detail_id1 := msc_x_netting_pkg.does_detail_excep_exist(b_publisher_id(j),
                                                      b_publisher_site_id(j),
                     b_item_id(j),
                                                         l_exception_type,
                                                         b_trx_id1(j));

               IF (l_exception_detail_id1 > 0 ) then
                         --dbms_output.put_line('----Detail exist for trx_id '||b_trx_id1(j));
                         --reset version=null indicate no need to resend notification
                         update msc_x_exception_details
                         set    version = null,
                           	threshold = b_threshold1(j),
                           	date1 = b_so_ship_date(j),
                           	date2 = b_so_receipt_date(j),
                           	number1 = b_so_qty(j)
                         where  exception_detail_id = l_exception_detail_id1;

                        --Need to reset the item exception.  The item exception
                         --might be archive for the same key
                         msc_x_netting_pkg.update_exceptions_summary(b_publisher_id(j),
                                                 b_publisher_site_id(j),
                                                 b_item_id(j),
                                                 l_exception_type,
                                                 l_exception_group);

               ELSE
                    --dbms_output.put_line('-----Exception12: Create exception' );

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
                                 b_customer_id(j),          --l_customer_id,
                                 b_customer_name(j),
                                 b_customer_site_id(j),        --l_customer_site_id,
                                 b_customer_site_name(j),
                                 b_customer_item_name(j),
                                 null,
                                 null,
                                 null,
                                 null,
                                 b_supplier_item_name(j),
                                 b_so_qty(j),
                                 null,
                                 null,
                                 b_threshold1(j),
                                 null,       --lead time
            			null,       --l_item_min,
            			null,       --l_item_max,
                                 b_order_number(j),
                                 b_release_number(j),
                                 b_line_number(j),
                                 null,                   --l_end_order_number,
                                 null,                   --l_end_order_rel_number,
                                 null,                   --l_end_order_line_number,
                                 b_so_creation_date(j),
 				 null,
                                 b_so_ship_date(j),
 				 b_so_receipt_date(j),
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
    ---------------------------------------------------------------------------
   --dbms_output.put_line('Start exception 32');


   l_exception_detail_id1 := null;
   l_exception_detail_id2 := null;
   l_exception_exists := null;

   IF (sysdate > b_so_creation_date(j) + b_threshold2(j)) THEN
      -------------------------------------------------------------
           -- exception 32 (customer centric)
           --------------------------------------------------------------
            l_exception_type := msc_x_netting_pkg.G_EXCEP32;
            l_exception_group := msc_x_netting_pkg.G_RESPONSE_REQUIRED;
            l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
      	    l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

            l_exception_detail_id2 := msc_x_netting_pkg.does_detail_excep_exist(b_customer_id(j),
                                               b_customer_site_id(j),
                                               b_item_id(j),
                                               l_exception_type,
                                               b_trx_id1(j));

            IF (l_exception_detail_id2 > 0 ) then
                 --dbms_output.put_line('----Detail exist for trx_id '||b_trx_id1(j));
                 --reset version=null indicate no need to resend notification
                 update msc_x_exception_details
                 set    version = null,
                       	threshold = b_threshold2(j),
                       	date1 = b_so_ship_date(j),
                       	date2 = b_so_receipt_date(j),
                       	number1 = b_tp_qty(j)
                 where  exception_detail_id = l_exception_detail_id2;

                 --Need to reset the item exception.  The item exception
                 --might be archive for the same key
                 msc_x_netting_pkg.update_exceptions_summary(b_customer_id(j),
                                  b_customer_site_id(j),
                                  b_item_id(j),
                                  l_exception_type,
                                  l_exception_group);

            ELSE
                   --dbms_output.put_line('-----Exception32: Create exception' );

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
                                   b_trx_id1(j),
                                   null,                   --l_trx_id2,
                                   null,                   --l_customer_id,
                                   null,
                                   null,                   --l_customer_site_id,
                                   null,
                                   b_customer_item_name(j),
                                   b_publisher_id(j),
                                   b_publisher_name(j),
                                   b_publisher_site_id(j),
                                   b_publisher_site_name(j),
                                   b_supplier_item_name(j),
                                   b_tp_qty(j),
                                   null,
                                   null,
                                   b_threshold2(j),
                                   null,        --lead time
               			   null,       --l_item_min,
               			   null,       --l_item_max,
                                   b_order_number(j),
                                   b_release_number(j),
                                   b_line_number(j),
                                   null,                   --l_end_order_number,
                                   null,                   --l_end_order_rel_number,
                                   null,                   --l_end_order_line_number,
                                   b_so_creation_date(j),
 				   null,
                                   b_so_ship_date(j),
 				   b_so_receipt_date(j),
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
 END LOOP;
 END IF;

 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(12) ||
      msc_x_netting_pkg.get_message_type(32) || ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));


 FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total exceptions inserted for the group ' ||
 msc_x_netting_pkg.get_message_group(msc_x_netting_pkg.G_RESPONSE_REQUIRED) || ':' || l_inserted_record);
 --===========================================================================================
   --Archive all the exception notifications sent out in previous engine runs
   --and are not re-occurr in this run
         --The old exceptions with version = 'X' in msc_x_exception_details table
 --=======================================================================================
 BEGIN
   delete msc_x_exception_details
         where  plan_id = msc_x_netting_pkg.G_PLAN_ID
         and   exception_type in (11,12,31,32)
         and   version = 'X';

         l_row := SQL%ROWCOUNT;
 EXCEPTION
   when others then
      null;
 END;

 --==================================
 -- Update Exception Headers
 --==================================
 IF (l_row > 0) THEN
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
                set   exception_count = u_count(i)
            where plan_id = u_plan_id(i)
            and   company_id = u_company_id(i)
            and   company_site_id = u_company_site_id(i)
            and   inventory_item_id = u_inventory_item_id(i)
            and   exception_type = u_exception_type(i)
            and   exception_group = u_exception_group(i)
            and    version = 0;


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
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING3_PKG.COMPUTE_RESPONSE_REQUIRED');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
      return;

 END Compute_response_required;

 --===================================================================================
 --COMPUTE_POTENTIAL_LATE_ORDER
 --===================================================================================
 PROCEDURE COMPUTE_POTENTIAL_LATE_ORDER (p_refresh_number IN Number,
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



  b_pegged_trx_id       	msc_x_netting_pkg.number_arr;
  b_order_type       		msc_x_netting_pkg.number_arr;
  b_po_trx_id        		msc_x_netting_pkg.number_arr;
  b_source_trx_id    		msc_x_netting_pkg.number_arr;
  b_threshold        		msc_x_netting_pkg.number_arr;
  b_company_id       		msc_x_netting_pkg.number_arr;
  b_organization_id     	msc_x_netting_pkg.number_arr;
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
  b_first_supplier_id      	msc_x_netting_pkg.number_arr;
  b_first_supplier_site_id 	msc_x_netting_pkg.number_arr;
  b_last_publisher_id      	msc_x_netting_pkg.number_arr;
  b_last_publisher_site_id    	msc_x_netting_pkg.number_arr;
  b_lead_time              	msc_x_netting_pkg.number_arr;
  b_po_key_date     		msc_x_netting_pkg.date_arr;
  b_so_key_date     		msc_x_netting_pkg.date_arr;
  b_po_receipt_date     	msc_x_netting_pkg.date_arr;
  b_so_receipt_date     	msc_x_netting_pkg.date_arr;
  b_po_ship_date     		msc_x_netting_pkg.date_arr;
  b_so_ship_date     		msc_x_netting_pkg.date_arr;
  b_po_creation_date       	msc_x_netting_pkg.date_arr;
  b_so_creation_date    	msc_x_netting_pkg.date_arr;
  b_first_po_key_date		msc_x_netting_pkg.date_arr;
  b_first_po_ship_date		msc_x_netting_pkg.date_arr;
  b_first_po_receipt_date  	msc_x_netting_pkg.date_arr;
  b_key_date			msc_x_netting_pkg.date_arr;
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
  b_first_supplier_name    	msc_x_netting_pkg.supplierList;
  b_first_supplier_site_name  	msc_x_netting_pkg.suppsiteList;
  b_first_supplier_item_name  	msc_x_netting_pkg.itemnameList;
  b_first_supplier_item_desc  	msc_x_netting_pkg.itemdescList;
  b_exception_type_name    	msc_x_netting_pkg.exceptypeList;
  b_order_number     		msc_x_netting_pkg.ordernumberList;
  b_release_number      	msc_x_netting_pkg.releasenumList;
  b_line_number      		msc_x_netting_pkg.linenumList;
  b_end_order_number       	msc_x_netting_pkg.ordernumberList;
  b_end_order_rel_number   	msc_x_netting_pkg.releasenumList;
  b_end_order_line_number  	msc_x_netting_pkg.linenumList;
  b_so_order_number       	msc_x_netting_pkg.ordernumberList;
  b_so_release_number   	msc_x_netting_pkg.releasenumList;
  b_so_line_number	  	msc_x_netting_pkg.linenumList;


 l_exception_count         	Number;
 l_exception_type          	Number;
 l_exception_group         	Number;
 l_exception_type_name     	fnd_lookup_values.meaning%type;
 l_exception_group_name    	fnd_lookup_values.meaning%type;
 l_so_exist                	Number;
 l_dummy                   	Number;
 l_exception_detail_id     	Number;
 l_exception_detail_id1    	Number;
 l_exception_detail_id2    	Number;
 l_exception_exists        	Number;
 l_late_order_exist1       	Number;
 l_late_order_exist2       	Number;
 l_late_order_exist        	Number;
 l_tp_response_exist1      	Number;
 l_tp_response_exist2      	Number;
 l_item_type         		Varchar2(20);
 l_item_key          		Varchar2(100);
 l_row            		Number;
 l_exist       			Number;
 l_count       			Number;
 i          			number;


  k_so_trx_id			msc_x_netting_pkg.number_arr;
  k_item_id                	msc_x_netting_pkg.number_arr;
  k_posting_so_qty		msc_x_netting_pkg.number_arr;
  k_so_qty                 	msc_x_netting_pkg.number_arr;
  k_tp_qty        		msc_x_netting_pkg.number_arr;
  k_customer_id         	msc_x_netting_pkg.number_arr;
  k_customer_site_id    	msc_x_netting_pkg.number_arr;
  k_supplier_id         	msc_x_netting_pkg.number_arr;
  k_supplier_site_id    	msc_x_netting_pkg.number_arr;
  k_po_key_date     		msc_x_netting_pkg.date_arr;
  k_so_key_date     		msc_x_netting_pkg.date_arr;
  k_po_receipt_date     	msc_x_netting_pkg.date_arr;
  k_so_receipt_date     	msc_x_netting_pkg.date_arr;
  k_po_ship_date     		msc_x_netting_pkg.date_arr;
  k_so_ship_date     		msc_x_netting_pkg.date_arr;
  k_po_creation_date       	msc_x_netting_pkg.date_arr;
  k_so_creation_date    	msc_x_netting_pkg.date_arr;
  k_item_name        		msc_x_netting_pkg.itemnameList;
  k_item_desc        		msc_x_netting_pkg.itemdescList;
  k_supplier_name       	msc_x_netting_pkg.supplierList;
  k_supplier_site_name     	msc_x_netting_pkg.suppsiteList;
  k_supplier_item_name     	msc_x_netting_pkg.itemnameList;
  k_supplier_item_desc     	msc_x_netting_pkg.itemdescList;
  k_customer_name       	msc_x_netting_pkg.customerList;
  k_customer_site_name     	msc_x_netting_pkg.custsiteList;
  k_customer_item_name     	msc_x_netting_pkg.itemnameList;
  k_customer_item_desc     	msc_x_netting_pkg.itemdescList;
  k_order_number     		msc_x_netting_pkg.ordernumberList;
  k_release_number      	msc_x_netting_pkg.releasenumList;
  k_line_number      		msc_x_netting_pkg.linenumList;
  k_end_order_number       	msc_x_netting_pkg.ordernumberList;
  k_end_order_rel_number   	msc_x_netting_pkg.releasenumList;
  k_end_order_line_number  	msc_x_netting_pkg.linenumList;

  n_ascp_first_po_trx_id	msc_x_netting_pkg.number_arr;

  d_company_id			msc_x_netting_pkg.number_arr;
  d_company_site_id		msc_x_netting_pkg.number_arr;
  d_customer_id			msc_x_netting_pkg.number_arr;
  d_customer_site_id		msc_x_netting_pkg.number_arr;
  d_supplier_id			msc_x_netting_pkg.number_arr;
  d_supplier_site_id		msc_x_netting_pkg.number_arr;
  d_item_id			msc_x_netting_pkg.number_arr;
  d_trx_id1			msc_x_netting_pkg.number_arr;
  d_trx_id2			msc_x_netting_pkg.number_arr;

 l_so_trx_id		Number;
 l_po_trx_id		Number;
 l_customer_id		Number;
 l_customer_site_id	Number;
 l_customer_name	msc_sup_dem_entries.customer_name%type;
 l_customer_site_name	msc_sup_dem_entries.customer_site_name%type;
 l_customer_item_name	msc_sup_dem_entries.customer_item_name%type;
 l_customer_item_desc   msc_sup_dem_entries.customer_item_description%type;
 l_item_name		msc_sup_dem_entries.item_name%type;
 l_item_desc		msc_sup_dem_entries.item_description%type;
 l_supplier_id		Number;
 l_supplier_site_id	Number;
 l_supplier_name	msc_sup_dem_entries.supplier_name%type;
 l_supplier_site_name	msc_sup_dem_entries.supplier_site_name%type;
 l_supplier_item_name	msc_sup_dem_entries.supplier_item_name%type;
 l_order_number		msc_sup_dem_entries.order_number%type;
 l_release_number	msc_sup_dem_entries.release_number%type;
 l_line_number		msc_sup_dem_entries.line_number%type;
 l_end_order_number	msc_sup_dem_entries.end_order_number%type;
 l_end_order_rel_number	msc_sup_dem_entries.end_order_rel_number%type;
 l_end_order_line_number	msc_sup_dem_entries.end_order_line_number%type;
 l_posting_so_qty	Number;
 l_so_qty		Number;
 l_tp_so_qty		Number;
 l_posting_po_qty	Number;
 l_po_qty		Number;
 l_tp_po_qty		Number;
 l_po_creation_date	Date;
 l_so_creation_date	Date;
 l_po_ship_date		Date;
 l_so_ship_date		Date;
 l_so_receipt_date	Date;
 l_po_receipt_date	Date;
 l_so_key_date		Date;
 l_po_key_date		Date;
 l_shipping_control	Number;
 l_exception_basis	msc_x_exception_details.exception_basis%type;

 l_ascp_demand_order_number 	msc_demands.order_number%type;
 l_ascp_so_line_id              Number;
 l_ascp_reservation_id 		Number;
 l_cp_org_id 			Number;
 l_cp_customer_id 		Number;
 l_cp_customer_site_id 		Number;
 l_cp_item_id 			Number;
 l_plan_order_at_risk		msc_plans.compile_designator%type;
 l_plan_order_at_risk_id	number;
 l_demand_id			Number;
 l_item_id			Number;

 l_ascp_po_order_number		msc_supplies.order_number%type;
 l_ascp_po_line			msc_supplies.purch_line_num%type;
 l_cp_company_id		Number;
 l_cp_company_site_id		Number;

 l_peg_id			Number;
 l_peg_sr_instance_id		Number;
 l_peg_org_id			Number;
 l_peg_item_id			Number;
 l_peg_trx_id			Number;
 l_peg_disposition_id		Number;
 l_peg_supply_type		Number;

 l_threshold			Number;
 l_threshold50			Number;
 l_threshold51			Number;
 l_transit_time			Number;
 l_inserted_record		Number;

--------------------------------------------------------
-- plsql table list for archive old exception
----------------------------------------------------------
TYPE  numberList  IS TABLE OF number;
u_publihser_id    numberList;
u_publisher_site_id  numberList;
u_item_id      numberList;
u_supplier_id     numberList;
u_supplier_site_id   numberList;
u_trx_id    numberList;


BEGIN
 l_item_type         		:= 'MSCSNDNT';
 l_item_key          		:= null;
 l_exist       			:= 0;
 l_count       			:= 0;

 l_threshold			:= 0;
 l_threshold50			:= 0;
 l_threshold51			:= 0;
 l_transit_time			:= 0;
 l_inserted_record		:= 0;


----------------------------------------------------------------
-- Exception type : Potentia late order due to upstream lateness
---------------------------------------------------------------


--dbms_output.put_line('exception 13');

open tp_viewers_po (p_refresh_number);
   fetch tp_viewers_po BULK COLLECT INTO
               	b_source_trx_id,
               	b_publisher_id,
               	b_publisher_name,
               	b_publisher_site_id,
               	b_publisher_site_name,
               	b_item_id,
               	b_item_name,
               	b_item_desc,
               	b_customer_item_name,
               	b_customer_item_desc,
               	b_first_po_key_date,
               	b_first_po_ship_date,
              	b_first_po_receipt_date,
           	b_posting_po_qty,
             	b_po_qty,
              	b_tp_po_qty,
             	b_order_number,
             	b_release_number,
             	b_line_number,
         	b_first_supplier_id,
         	b_first_supplier_name,
         	b_first_supplier_site_id,
                b_first_supplier_site_name,
                b_first_supplier_item_name,
                b_first_supplier_item_desc,
                b_po_creation_date;
CLOSE tp_viewers_po;


IF (b_source_trx_id is not null and b_source_trx_id.COUNT > 0) THEN
FOR j in 1..b_source_trx_id.COUNT
LOOP
   	--------------------------------------------------------------------------
   	-- get the shipping control
   	---------------------------------------------------------------------------
   	l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                    b_publisher_site_name(j),
                                    b_first_supplier_name(j),
                                    b_first_supplier_site_name(j));

   	l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

	l_exception_type := msc_x_netting_pkg.G_EXCEP13;
	l_exception_group := msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER;
	l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
	l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

   --select the tp_viewers level-1 suppliers po
   --that was created to fulfil tp_viewers_po

   open level_1_supp_po(
                     	b_order_number(j),
                        b_release_number(j),
                        b_line_number(j),
            		b_first_supplier_id(j),
                        b_first_supplier_site_id(j),
                        b_item_id(j));
    fetch level_1_supp_po BULK COLLECT INTO b_po_trx_id;
    CLOSE level_1_supp_po;
    IF (b_po_trx_id is not null and b_po_trx_id.COUNT > 0) THEN
    FOR k in 1..b_po_trx_id.COUNT
    LOOP
           --traversing down to find the upstream lateness
           --dbms_output.put_line('Traversing down Po trx id ' ||b_po_trx_id(k));
       BEGIN
           open tp_viewers_dependent_orders(b_po_trx_id(k));
             fetch tp_viewers_dependent_orders BULK COLLECT INTO
                                   b_pegged_trx_id,
                                   b_order_type,
                                   b_last_publisher_id,
                                   b_last_publisher_site_id;
           CLOSE tp_viewers_dependent_orders;

           IF (b_pegged_trx_id is not null and b_pegged_trx_id.COUNT > 0) THEN
           FOR l in 1..b_pegged_trx_id.COUNT
           LOOP
                IF b_order_type(l) = msc_x_netting_pkg.PURCHASE_ORDER then
                           ---------------------------------------
                           ----  the exception_13 cursor
                           ----------------------------------------
                     open exception_13 (b_last_publisher_id(l),
                                 b_last_publisher_site_id(l),
                                 b_item_id(j),
                                 b_pegged_trx_id(l));

                        fetch exception_13 BULK COLLECT INTO
                              b_trx_id1,
                                           b_supplier_id,
                                           b_supplier_name,
                                           b_supplier_site_id,
                                           b_supplier_site_name,
                                           b_supplier_item_name,
                                           b_po_key_date,
                                           b_po_ship_date,
                                           b_po_receipt_date,
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
                                           b_so_creation_date,
                                           b_threshold;
                   CLOSE exception_13;
                   IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
                   FOR m in 1..b_trx_id1.COUNT
                   LOOP
                     --dbms_output.put_line('-----Exception13: Trx id 1 = '|| b_source_trx_id(j));
                     --dbms_output.put_line('---------------   Trx id 2 = ' || b_trx_id2(m));

               		--======================================================
               		-- Clean up the old exception
              		 --======================================================
            		msc_x_netting_pkg.add_to_delete_tbl(
               		b_publisher_id(j),
               		b_publisher_site_id(j),
               		null,
               		null,
               		b_supplier_id(m),
               		b_supplier_site_id(m),
               		b_item_id(j),
               		msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER,
               		msc_x_netting_pkg.G_EXCEP13,
              		b_source_trx_id(j),
               		b_trx_id2(m),
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


            		-- bug# 2426271 to populate more info
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
                                    b_source_trx_id(j),
                                    b_trx_id2(m),
                                    b_first_supplier_id(j),
                                    b_first_supplier_name(j),
                                    b_first_supplier_site_id(j),
                                    b_first_supplier_site_name(j),
                                    b_customer_item_name(j),
                                    b_supplier_id(m),
                                    b_supplier_name(m),
                                    b_supplier_site_id(m),
                                    b_supplier_site_name(m),
                                    b_supplier_item_name(m),
                                    b_po_qty(j),    --number1
                                    b_tp_so_qty(m),      --number2
                                       abs(b_so_receipt_date(m) - b_po_receipt_date(m)),  --number3
                                    b_threshold(m),
                                    null,       --lead time
                  			null,       --l_item_min,
                  			null,       --l_item_max,
                                    b_order_number(j),
                                    b_release_number(j),
                                    b_line_number(j),
                                    b_end_order_number(m),
                                    b_end_order_rel_number(m),
                                    b_end_order_line_number(m),
             	      		    b_po_creation_date(j),
                  	            b_so_creation_date(m),
                                    b_first_po_receipt_date(j),
                                    b_so_receipt_date(m),
                                    b_so_ship_date(m),
                                    b_first_po_ship_date(j),
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

                     	END LOOP;      -- close exception_13
                     	END IF;
               END IF;
         END LOOP;         --tp_viewers_dependent_orders
         END IF;
      EXCEPTION
               when others then
                  --dbms_output.put_line('Error ' || sqlerrm);
                  null;

      END;
       END LOOP;    --level_1_supp_po
       END IF;
END LOOP;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(13) ||
   ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

--dbms_output.put_line('end of exception 13');
--------------------------------------------------------------------
-- New exception for release 11.5.10
-- Sales order at risk due to upstream lateness
--------------------------------------------------------------------
l_exception_detail_id1 := null;
l_exception_detail_id2 := null;
l_exception_exists := null;
l_late_order_exist := null;




l_plan_order_at_risk := FND_PROFILE.VALUE('MSC_PLAN_FOR_ORDER_AT_RISK');
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Plan order at risk ' || l_plan_order_at_risk);
--dbms_output.put_line('Plan order at risk ' || l_plan_order_at_risk);
BEGIN
	select plan_id
	into	l_plan_order_at_risk_id
	from	msc_plans
	where	compile_designator = l_plan_order_at_risk;
EXCEPTION
	when others then
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'The plan for order at risk has not defined as a profile option ');
END;


OPEN exception_50_51 (p_refresh_number);
fetch exception_50_51 BULK COLLECT INTO
            	b_trx_id1,
            	b_trx_id2,
            	b_customer_id,
            	b_customer_name,
            	b_customer_site_id,
            	b_customer_site_name,
            	b_item_id,
            	b_item_name,
            	b_item_desc,
            	b_supplier_id,
		b_supplier_name,
		b_supplier_site_id,
            	b_supplier_site_name,
           	b_supplier_item_name,
               	b_supplier_item_desc,
               	b_po_qty,
               	b_so_qty,
               	b_po_key_date,
             	b_po_ship_date,
           	b_po_receipt_date,
           	b_so_key_date,
           	b_so_ship_date,
           	b_so_receipt_date,
           	b_end_order_number,
           	b_end_order_rel_number,
           	b_end_order_line_number,
              	b_so_order_number,
               	b_so_release_number,
               	b_so_line_number,
                b_order_number,
	        b_release_number,
	        b_line_number;
CLOSE exception_50_51;

--dbms_output.put_line('In 50');
--dbms_output.put_line('Number of rows = ' || b_trx_id1.COUNT);
IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
FOR j in 1..b_trx_id1.COUNT
LOOP

--dbms_output.put_line('first trx id2 ' || b_trx_id2(j));
   --======================================================
   -- Clean up the old exceptions
   --======================================================
   IF (j = 1 or b_trx_id2(j-1) <> b_trx_id2(j)) THEN

     open get_delete_row(b_trx_id2(j));
     fetch get_delete_row BULK COLLECT INTO
   	d_company_id,
   	d_company_site_id,
   	d_customer_id,
   	d_customer_site_id,
   	d_supplier_id,
   	d_supplier_site_id,
   	d_item_id,
   	d_trx_id1,
   	d_trx_id2;
     CLOSE get_delete_row;
     IF (d_company_id is not null and d_company_id.COUNT > 0) THEN
       --dbms_output.put_line('Delete row count ' || d_company_id.COUNT);
       FOR d in 1..d_company_id.COUNT LOOP
         -- dbms_output.put_line('Trxid2 ' || d_trx_id2(d));
     	  msc_x_netting_pkg.add_to_delete_tbl(
                d_company_id(d),
                d_company_site_id(d),
                d_customer_id(d),
             	d_customer_site_id(d),
               	d_supplier_id(d),
            	d_supplier_site_id(d),
            	d_item_id(d),
           	msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER,
           	msc_x_netting_pkg.G_EXCEP50,
         	d_trx_id1(d),
            	d_trx_id2(d),
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
                d_company_id(d),
                d_company_site_id(d),
                d_customer_id(d),
             	d_customer_site_id(d),
               	d_supplier_id(d),
            	d_supplier_site_id(d),
            	d_item_id(d),
           	msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER,
           	msc_x_netting_pkg.G_EXCEP51,
         	d_trx_id1(d),
            	d_trx_id2(d),
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
   END IF;

   IF (j = 1 or b_customer_id(j-1) <> b_customer_id(j) or
                     b_customer_site_id(j-1) <> b_customer_site_id(j) or
                     b_supplier_id(j-1) <> b_supplier_id(j) or
                     b_supplier_site_id(j-1) <> b_supplier_site_id(j) or
                     b_item_id(j-1) <> b_item_id(j) ) THEN

      	l_threshold50 :=  msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP50,
                        b_customer_id(j),
                        b_customer_site_id(j),
                        b_item_id(j),
                        b_supplier_id(j),
                        b_supplier_site_id(j),
                        null,
                        null,
                        b_po_key_date(j));

        l_threshold51 :=  msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP51,
                          b_customer_id(j),
                          b_customer_site_id(j),
                          b_item_id(j),
                          b_supplier_id(j),
                          b_supplier_site_id(j),
                          null,
                          null,
                        b_po_key_date(j));
          ---------------------------------------------------------------------------
          -- get the shipping control
          ---------------------------------------------------------------------------
          l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_customer_name(j),
                                             b_customer_site_name(j),
                                             b_supplier_name(j),
                                             b_supplier_site_name(j));

          l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

   END IF;

   -- limit the loop (at this point don't know it is for exception50 or 51
   IF   (trunc(b_so_key_date(j)) > trunc(b_po_key_date(j))  ) THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'TRX ID = ' || b_trx_id1(j));
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'END ORDER= ' || b_end_order_number(j));
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'END REL = ' || b_end_order_rel_number(j));
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'END LINE = ' || b_end_order_line_number(j));
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'CUST = ' || b_customer_id(j));
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'CUST SITE = ' || b_customer_site_id(j));
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'ITEM = ' || b_item_id(j));
     /*---------------------------------------------------------------------------------
     -- Get the SO2 from CP  (eg: cust: OEM, supp: CM - at this point not cust will pass in
     -----------------------------------------------------------------------------------*/
      OPEN level_2_so_cp (b_end_order_number(j),b_end_order_rel_number(j), b_end_order_line_number(j),
				b_customer_id(j), b_customer_site_id(j), b_item_id(j));
      FETCH level_2_so_cp BULK COLLECT INTO k_so_trx_id,
			k_supplier_id,
			k_supplier_name,
			k_supplier_site_id,
			k_supplier_site_name,
			k_supplier_item_name,
			k_item_id,
			k_item_name,
			k_item_desc,
			k_so_key_date,
	   		k_so_ship_date,
	   		k_so_receipt_date,
	   		k_so_creation_date,
	   		k_posting_so_qty,
			k_so_qty,
	   		k_tp_qty,
	   		k_order_number,
	   		k_release_number,
	   		k_line_number,
	   		k_end_order_number,
	   		k_end_order_rel_number,
	   		k_end_order_line_number,
	   		k_customer_id,
	   		k_customer_name,
	   		k_customer_site_id,
   			k_customer_site_name,
   			k_customer_item_name,
   			k_customer_item_desc;
      CLOSE level_2_so_cp;


	/*------------------------------------------------------------------------------
	      IF SO exists, then the pegging is existing in CP.  Generate the exception
	------------------------------------------------------------------------------*/
      IF (k_so_trx_id is not null and k_so_trx_id.COUNT > 0)THEN  --

          -- dbms_output.put_line('SO EXISTS IN CP');

        IF   (trunc(b_so_key_date(j)) > trunc(b_po_key_date(j)) +  l_threshold50) THEN

 	FOR k in 1..k_so_trx_id.COUNT
   	    LOOP

 		l_exception_type := msc_x_netting_pkg.G_EXCEP50;
		l_exception_group := msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER;
		l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
		l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);
   	       --dbms_output.put_line('SO EXISTS IN CP WITH SO TRXID : ' || k_so_trx_id(k) || 'Supplier ' || k_supplier_id(k));
   	       FND_FILE.PUT_LINE(FND_FILE.LOG, 'SO EXISTS IN CP WITH SO TRXID : ' || k_so_trx_id(k) || 'Supplier ' || k_supplier_id(k));
   	       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Generate Sales order at risk');
		--Generate the exception: Sales Order at risk due to upstream lateness
		--======================================================
               		-- Clean up the old exceptions
                --======================================================
            	msc_x_netting_pkg.add_to_delete_tbl(
               		k_supplier_id(k),
               		k_supplier_site_id(k),
               		k_customer_id(k),
               		k_customer_site_id(k),
               		k_supplier_id(k),
               		k_supplier_site_id(k),
               		k_item_id(k),
               		msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER,
               		msc_x_netting_pkg.G_EXCEP50,
              		k_so_trx_id(k),
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


                     	msc_x_netting_pkg.add_to_exception_tbl(k_supplier_id(k),
                                    k_supplier_name(k),
                                    k_supplier_site_id(k),
                                    k_supplier_site_name(k),
                                    k_item_id(k),
                                    k_item_name(k),
                                    k_item_desc(k),
                                    l_exception_type,
                                    l_exception_type_name,
                                    l_exception_group,
                                    l_exception_group_name,
                                    k_so_trx_id(k),
                                    b_trx_id2(j),
                                    k_customer_id(k),
                                    k_customer_name(k),
                                    k_customer_site_id(k),
                                    k_customer_site_name(k),
                                    k_customer_item_name(k),
                                    k_supplier_id(k),
                                    k_supplier_name(k),
                                    k_supplier_site_id(k),
                                    k_supplier_site_name(k),
                                    k_supplier_item_name(k),
                                    k_so_qty(k),    --number1
                                    b_so_qty(j),      --number2
                                    abs(b_so_receipt_date(j) - b_po_receipt_date(j)),  --number3
                                    l_threshold50,
                                    null,       --lead time
                  		    null,       --l_item_min,
                  		    null,       --l_item_max,
                                    k_order_number(k),
                                    k_release_number(k),
                                    k_line_number(k),
                                    b_so_order_number(j),
                                    b_so_release_number(j),
                                    b_so_line_number(j),
                                    k_so_creation_date(k),
 				    null,
                                    k_so_ship_date(k),
 				    k_so_receipt_date(k),
                                    b_so_receipt_date(j),
                                    b_so_ship_date(j),
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
	 ELSE

	-- --dbms_output.put_line('No SO in CP');

	 /*--------------------------------------------------------------------
	 -- if the SO2 is not exist in CP, now need to look at the PO2 in Ascp
	 -----------------------------------------------------------------------*/

        /* Plan order at risk is plan_id based on compile
           designator in profile */

        --dbms_output.put_line('PLAN ORDER AT RISK = ' || l_plan_order_at_risk_id);

        if l_plan_order_at_risk_id is not null THEN
	     /*--------------------------------------------------------------------
	     -- if there is a specified plan defined in the profile
	     -----------------------------------------------------------------------*/


	     --dbms_output.put_line('Order  number = ' || b_order_number(j));
             --dbms_output.put_line('Release number = ' || b_release_number(j));
             --dbms_output.put_line('Line number = ' ||  b_line_number(j));
             --dbms_output.put_line('Item = ' || b_item_id(j));
             --dbms_output.put_line('Customer = ' || b_customer_id(j));
             --dbms_output.put_line('Customer Site = ' || b_customer_site_id(j));
             --dbms_output.put_line('Supplier = ' || b_supplier_id(j));
             --dbms_output.put_line('Supplier Site = ' || b_supplier_site_id(j));


	     FND_FILE.PUT_LINE(FND_FILE.LOG, 'PLAN EXISTS ' || l_plan_order_at_risk);
	     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Order  number = ' || b_order_number(j));
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Release number = ' || b_release_number(j));
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Line number = ' ||  b_line_number(j));
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Item = ' || b_item_id(j));
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Customer = ' || b_customer_id(j));
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Customer Site = ' || b_customer_site_id(j));
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Supplier = ' || b_supplier_id(j));
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Supplier Site = ' || b_supplier_site_id(j));

	     OPEN map_po_in_ascp (l_plan_order_at_risk_id,
				b_order_number(j),
				b_release_number(j),
				b_line_number(j),
				b_item_id(j),
				b_customer_id(j),
				b_customer_site_id(j),
				b_supplier_id(j),
				b_supplier_site_id(j));
	     FETCH map_po_in_ascp BULK COLLECT INTO n_ascp_first_po_trx_id;
	     CLOSE map_po_in_ascp;



            --dbms_output.put_line('Num of POs found = ' || n_ascp_first_po_trx_id.COUNT);

	    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Num of POs found = ' ||
	                                   n_ascp_first_po_trx_id.COUNT);

	     IF ((n_ascp_first_po_trx_id is not null)
		  AND (n_ascp_first_po_trx_id.COUNT > 0)) THEN --sbala

		  --dbms_output.put_line('Found PO ');



		  FOR n in 1..n_ascp_first_po_trx_id.COUNT LOOP

                  --dbms_output.put_line('IN PEG LOOP');
                  --dbms_output.put_line(' PO TRX ID = ' ||  n_ascp_first_po_trx_id(n));


	          FND_FILE.PUT_LINE(FND_FILE.LOG, 'IN PEG LOOP');
                   FND_FILE.PUT_LINE(FND_FILE.LOG, ' PO TRX ID = ' ||  n_ascp_first_po_trx_id(n));

		    OPEN get_all_pegging (n_ascp_first_po_trx_id(n),
					 l_plan_order_at_risk_id);

                    LOOP
 		    FETCH get_all_pegging INTO
 		    			l_peg_id,
 		    			l_peg_sr_instance_id,
					l_peg_org_id,
					l_peg_item_id,
					l_peg_trx_id,
					l_peg_disposition_id,
					l_peg_supply_type,
 					l_demand_id;



                    EXIT when get_all_pegging%NOTFOUND;
   --dbms_output.put_line('Peg trx_id ' || l_peg_trx_id || ' Peg type ' || l_peg_supply_type);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Peg trx_id ' || l_peg_trx_id || ' Peg type ' || l_peg_supply_type);
      		 /*---------------------------------------------------------------
      		  Get the PO at risk
      		  -----------------------------------------------------------------*/


      		  IF (l_peg_trx_id <> n_ascp_first_po_trx_id(n) and
      		  		l_peg_supply_type = msc_x_netting_pkg.ASCP_PURCHASE_ORDER) THEN


		     BEGIN
			SELECT  sup.order_number,
				sup.purch_line_num,
				s1.company_id,
				s1.company_site_id,		--- cp cust id --- po owner
				sup.inventory_item_id,
				sd.transaction_id,
				sd.supplier_id,
				sd.supplier_name,
				sd.supplier_site_id,
				sd.supplier_site_name,
				sd.supplier_item_name,
				sd.inventory_item_id,
				sd.item_name,
				sd.item_description,
				sd.key_date,
   				sd.ship_date,
   				sd.receipt_date,
   				sd.quantity,
   				sd.primary_quantity,
   				sd.tp_quantity,
   				sd.order_number,
   				sd.release_number,
   				sd.line_number,
   				sd.customer_id,
   				sd.customer_name,
   				sd.customer_site_id,
   				sd.customer_site_name,
   				sd.customer_item_name,
   				sd.customer_item_description

    			INTO 	l_ascp_po_order_number,
				l_ascp_po_line,
				l_cp_company_id,
    				l_cp_company_site_id,
				l_cp_item_id,
				l_po_trx_id,
				l_supplier_id,
				l_supplier_name,
				l_supplier_site_id,
				l_supplier_site_name,
				l_supplier_item_name,
				l_item_id,
				l_item_name,
				l_item_desc,
				l_po_key_date,
				l_po_ship_date,
				l_po_receipt_date,
				l_posting_po_qty,
				l_po_qty,
				l_tp_po_qty,
				l_order_number,
				l_release_number,
				l_line_number,
				l_customer_id,
				l_customer_name,
				l_customer_site_id,
				l_customer_site_name,
				l_customer_item_name,
				l_customer_item_desc
			FROM 	msc_supplies sup,
				msc_companies c1,
				msc_company_sites s1,
				msc_trading_partners t1,
				msc_trading_partner_maps m1,
				msc_trading_partners t2,
				msc_trading_partner_maps m2,
				msc_companies c2,
				msc_company_sites s2,
				msc_company_relationships rel,
				msc_trading_partner_maps m3,
				msc_sup_dem_entries sd
			WHERE	sup.transaction_id = l_peg_trx_id
			AND 	sup.plan_id = l_plan_order_at_risk_id
			AND	sup.sr_instance_id = l_peg_sr_instance_id
			AND	sup.organization_id = l_peg_org_id
			AND	sup.inventory_item_id = l_peg_item_id
			AND	sup.order_type = msc_x_netting_pkg.ASCP_PURCHASE_ORDER

				--	getting the org
			AND	t1.sr_tp_id = sup.organization_id
			AND	t1.sr_instance_id = sup.sr_instance_id
			AND	t1.partner_type = 3 	--org
			AND	m1.tp_key = t1.partner_id
			AND	m1.map_type = 2
			AND	s1.company_site_id = m1.company_key
			AND	s1.company_id = c1.company_id

			--	getting the supplier
			AND	rel.relationship_type = 2	--supplier
			AND	rel.object_id = c2.company_id   -- supplier
			AND	rel.subject_id = c1.company_id	--1
			AND	rel.relationship_id = m2.company_key
			AND	m2.tp_key = t2.partner_id
			AND	m2.map_type = 1	-- supp
			AND	t2.partner_id = sup.supplier_id
			AND	t2.partner_type = 1 	-- supplier

			--	getting the suppliersite
			AND	m3.tp_key = sup.supplier_site_id
			AND	m3.map_type = 3		--supp site
			AND	s2.company_site_id = m3.company_key
			AND	s2.company_id = c2.company_id

			-- join to cp to get PO
			AND 	sd.publisher_order_type = msc_x_netting_pkg.PURCHASE_ORDER
			AND 	sd.inventory_item_id = sup.inventory_item_id
			AND 	    sup.order_number = sd.order_number || sd.release_number
			AND 	nvl(sd.line_number,'-1') = nvl(purch_line_num, '-1')
			AND 	sd.publisher_id = s1.company_id
			AND 	sd.publisher_site_id = s1.company_site_id
			AND 	sd.supplier_id = s2.company_id
          		AND 	sd.supplier_site_id = s2.company_site_id;

		      EXCEPTION

				when no_data_found then
				--dbms_output.put_line('NO PO FOUND IN CP');
				FND_FILE.PUT_LINE(FND_FILE.LOG, 'NO PO FOUND IN CP');
					l_po_trx_id := null;

				when too_many_rows then

				FND_FILE.PUT_LINE(FND_FILE.LOG, 'TOO MANY POs');

		      	when others then
		      	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error to find PO in cp ' || sqlerrm);
	    			l_ascp_po_order_number := null;
				l_ascp_po_line := null;
	    			l_cp_company_id := null;
	    			l_cp_company_site_id := null;
	    			l_supplier_id := null;
	    			l_supplier_site_id := null;
				l_cp_item_id := null;
		        END;

--dbms_output.put_line('TRX ID of PO = ' || l_po_trx_id || 'SO dt ' || b_so_receipt_date(j) ||'PO date ' || b_po_receipt_date(j));
--dbms_output.put_line(b_so_receipt_date(j) - b_po_receipt_date(j));

			IF l_po_trx_id is not null THEN


			   IF   (trunc(b_so_key_date(j)) > trunc(b_po_key_date(j)) +  l_threshold51) THEN
				--Generate the exceptions for this PO
				--the purchase order at risk due to upstream lateness

				l_exception_type := msc_x_netting_pkg.G_EXCEP51;
				l_exception_group := msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER;
				l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
				l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);

				--======================================================
               			-- Clean up the old exceptions
                		--======================================================
            			msc_x_netting_pkg.add_to_delete_tbl(
               				l_customer_id,
               				l_customer_site_id,
               				l_customer_id,
               				l_customer_site_id,
               				l_supplier_id,
               				l_supplier_site_id,
               				l_item_id,
               				msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER,
               				msc_x_netting_pkg.G_EXCEP51,
              				l_po_trx_id,
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


--dbms_output.put_line('Generate excep 51');

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Generate exception 51');
                     		msc_x_netting_pkg.add_to_exception_tbl(l_customer_id,
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
                                    l_po_trx_id,
                                    b_trx_id2(j),
                                    l_customer_id,
                                    l_customer_name,
                                    l_customer_site_id,
                                    l_customer_site_name,
                                    l_customer_item_name,
                                    l_supplier_id,
                                    l_supplier_name,
                                    l_supplier_site_id,
                                    l_supplier_site_name,
                                    l_supplier_item_name,
                                    l_po_qty,    --number1
                                    b_so_qty(j),      --number2
                                    abs(b_so_receipt_date(j) - b_po_receipt_date(j)),  --number3
                                    l_threshold51,
                                    null,       --lead time
                  		    null,       --l_item_min,
                  		    null,       --l_item_max,
                                    l_order_number,
                                    l_release_number,
                                    l_line_number,
                                    b_so_order_number(j),
                                    b_so_release_number(j),
                                    b_so_line_number(j),
                                    l_po_creation_date,
        			    l_so_creation_date,
                                    l_po_ship_date,
        			    l_po_receipt_date,
                                    b_so_receipt_date(j),
                                    b_so_ship_date(j),
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
            		    END IF;			-- with threshold
			END IF;
		END IF;


		    /* sbala: Need code to check for existence of records */

		--dbms_output.put_line('Demand id = ' || l_demand_id);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Demand id = ' || l_demand_id);

		    /* sbala LOOP */
		    /*--------------------------------------------------------------
		      Look for the SO existing in  CP
		      --------------------------------------------------------------*/
		     BEGIN
			SELECT  dem.order_number,
				dem.sales_order_line_id, --sbala
				dem.reservation_id,
				s1.company_site_id,		--- cp supplier_site_id -- so owner
				c2.company_id,
				s2.company_site_id,
				dem.inventory_item_id,
				sd.transaction_id,
				sd.supplier_id,
				sd.supplier_name,
				sd.supplier_site_id,
				sd.supplier_site_name,
				sd.supplier_item_name,
				sd.inventory_item_id,
				sd.item_name,
				sd.item_description,
				sd.key_date,
   				sd.ship_date,
   				sd.receipt_date,
   				sd.quantity,
   				sd.primary_quantity,
   				sd.tp_quantity,
   				sd.order_number,
   				sd.release_number,
   				sd.line_number,
   				sd.customer_id,
   				sd.customer_name,
   				sd.customer_site_id,
   				sd.customer_site_name,
   				sd.customer_item_name,
   				sd.customer_item_description

    			INTO 	l_ascp_demand_order_number,
				l_ascp_so_line_id,
    				l_ascp_reservation_id,
    				l_cp_org_id,
    				l_cp_customer_id,
    				l_cp_customer_site_id,
				l_cp_item_id,
				l_so_trx_id,
				l_supplier_id,
				l_supplier_name,
				l_supplier_site_id,
				l_supplier_site_name,
				l_supplier_item_name,
				l_item_id,
				l_item_name,
				l_item_desc,
				l_so_key_date,
				l_so_ship_date,
				l_so_receipt_date,
				l_posting_so_qty,
				l_so_qty,
				l_tp_so_qty,
				l_order_number,
				l_release_number,
				l_line_number,
				l_customer_id,
				l_customer_name,
				l_customer_site_id,
				l_customer_site_name,
				l_customer_item_name,
				l_customer_item_desc
			FROM 	msc_demands dem,
				msc_companies c1,
				msc_company_sites s1,
				msc_trading_partners t1,
				msc_trading_partner_maps m1,
				msc_trading_partners t2,
				msc_trading_partner_maps m2,
				msc_companies c2,
				msc_company_sites s2,
				msc_company_relationships rel,
				msc_trading_partner_maps m3,
				msc_sup_dem_entries sd,
				msc_sales_orders mso
			WHERE	dem.demand_id = l_demand_id
			AND 	dem.plan_id = l_plan_order_at_risk_id
			AND	dem.sr_instance_id = l_peg_sr_instance_id
			AND	dem.organization_id = l_peg_org_id
			AND	dem.inventory_item_id = l_peg_item_id
			AND	dem.origination_type in (msc_x_netting_pkg.ASCP_SALES_ORDER,
					msc_x_netting_pkg.ASCP_SALES_ORDER_MDS)
--- sbala AND	dem.customer_id is not null
				--	getting the org
			AND	t1.sr_tp_id = dem.organization_id
			AND	t1.sr_instance_id = dem.sr_instance_id
			AND	t1.partner_type = 3 	--org
			AND	m1.tp_key = t1.partner_id
			AND	m1.map_type = 2
			AND	s1.company_site_id = m1.company_key
			AND	s1.company_id = c1.company_id

			--	getting the customer
			AND	rel.relationship_type = 1	--cust
			AND	rel.object_id = c2.company_id   -- cust
			AND	rel.subject_id = c1.company_id	--1
			AND	rel.relationship_id = m2.company_key
			AND	m2.tp_key = t2.partner_id
			AND	m2.map_type = 1	--cust
			AND	t2.partner_id = dem.customer_id
			AND	t2.partner_type = 2 	-- cust
----sbala 	AND	t2.sr_instance_id = dem.sr_instance_id

			--	getting the customer site
			AND	m3.tp_key = dem.customer_site_id
			AND	m3.map_type = 3		--cust site
			AND	s2.company_site_id = m3.company_key
			AND	s2.company_id = c2.company_id

            		-- join to cp to get SO
            		AND	dem.sr_instance_id = mso.sr_instance_id
            		AND	dem.organization_id = mso.organization_id
            		AND	dem.inventory_item_id = mso.inventory_item_id
            		AND	dem.sales_order_line_id = mso.demand_source_line
            		AND 	sd.publisher_order_type = msc_x_netting_pkg.SALES_ORDER
       			AND	sd.inventory_item_id = mso.inventory_item_id
			AND	sd.order_number = mso.sales_order_number
        		AND	sd.line_number = mso.demand_source_line
        		AND 	sd.publisher_id = s1.company_id
        		AND 	sd.publisher_site_id = s1.company_site_id;

		      EXCEPTION

				when no_data_found then

				--dbms_output.put_line('NO SO FOUND IN CP');
				FND_FILE.PUT_LINE(FND_FILE.LOG, 'NO SO FOUND IN CP');
					l_so_trx_id := null;

				when too_many_rows then
				null;
				--dbms_output.put_line('TOO MANY SOs');

		      	when others then
		      	--dbms_output.put_line('Error to find SO in cp ' || sqlerrm);
	    			l_ascp_demand_order_number := null;
				l_ascp_so_line_id := null;
	    			l_ascp_reservation_id := null;
	    			l_cp_org_id := null;
	    			l_cp_customer_id := null;
	    			l_cp_customer_site_id := null;
				l_cp_item_id := null;
		      END;

--dbms_output.put_line('TRX ID of SO = ' || l_so_trx_id || 'SO dt ' || b_so_receipt_date(j) ||'PO date ' || b_po_receipt_date(j));
--dbms_output.put_line(b_so_receipt_date(j) -  b_po_receipt_date(j));



			IF l_so_trx_id is not null THEN
				--Generate the exceptions for this SO
				--the sales order at risk due to upstream lateness

			   IF   (trunc(b_so_key_date(j)) > trunc(b_po_key_date(j)) +  l_threshold50) THEN
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Generate exception 50');
				l_exception_type := msc_x_netting_pkg.G_EXCEP50;
				l_exception_group := msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER;
				l_exception_type_name := msc_x_netting_pkg.get_message_type (l_exception_type);
				l_exception_group_name := msc_x_netting_pkg.get_message_group (l_exception_group);
				--======================================================
               			-- Clean up the old exceptions
                		--======================================================
            			msc_x_netting_pkg.add_to_delete_tbl(
               				l_supplier_id,
               				l_supplier_site_id,
               				l_customer_id,
               				l_customer_site_id,
               				l_supplier_id,
               				l_supplier_site_id,
               				l_item_id,
               				msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER,
               				msc_x_netting_pkg.G_EXCEP50,
              				l_so_trx_id,
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


                     		msc_x_netting_pkg.add_to_exception_tbl(l_supplier_id,
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
                                    l_so_trx_id,
                                    b_trx_id2(j),
                                    l_customer_id,
                                    l_customer_name,
                                    l_customer_site_id,
                                    l_customer_site_name,
                                    l_customer_item_name,
                                    l_supplier_id,
                                    l_supplier_name,
                                    l_supplier_site_id,
                                    l_supplier_site_name,
                                    l_supplier_item_name,
                                    l_so_qty,    --number1
                                    b_so_qty(j),      --number2
                                    abs(b_so_receipt_date(j) - b_po_receipt_date(j)),  --number3
                                    l_threshold50,
                                    null,       --lead time
                  		    null,       --l_item_min,
                  		    null,       --l_item_max,
                                    l_order_number,
                                    l_release_number,
                                    l_line_number,
                                    b_so_order_number(j),
                                    b_so_release_number(j),
                                    b_so_line_number(j),
                                    null,
 				    null,
                                    l_so_ship_date,
 				    l_so_receipt_date,
                                    b_so_receipt_date(j),
                                    b_so_ship_date(j),
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
      				END IF;		-- with threshold
                  	   END IF;	-- if l_so_trx_id is not null  **/
                        --dbms_output.put_line('AT 1');
			--END IF;		-- if so in ascp is exist

                    --dbms_output.put_line('Getting next demand');

		    END LOOP;		-- get all pegging
		    CLOSE get_all_pegging;
	    	END LOOP;		--map_po_in_ascp
	    END IF;			-- ascp_first_po_trx_id
	  END IF;			-- plan order at risk
    	END IF;
   END IF;		---compare the date
END LOOP;
END IF;


FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(50 ) || '-' ||
   msc_x_netting_pkg.get_message_type(51) ||
   ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
--------------------------------------------------------------
--Need to clean up the existing exceptions before regenerate
--new exception or the criteria is already satisfied.
--This query is for 4.2 and 4.3 only.
--------------------------------------------------------------


l_exception_detail_id1 := null;
l_exception_detail_id2 := null;
l_exception_exists := null;
l_late_order_exist := null;

 l_threshold := 0;
 l_transit_time := 0;
--dbms_output.put_line('Exception 14');
 open exception_14(p_refresh_number);
      fetch exception_14 BULK COLLECT INTO  b_trx_id1,
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
                                b_supplier_id,                  --so org
                                b_supplier_name,
                                b_supplier_site_id,
                                b_supplier_site_name,
                                b_supplier_item_name,
                                b_supplier_item_desc,
                                b_po_creation_date,
            			b_lead_time;
  CLOSE exception_14;


  -----------------------------------------------------------------------
  -- exception 4.2 (customer centric)
  -----------------------------------------------------------------------

IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
  FOR j in 1..b_trx_id1.COUNT
  LOOP
   --======================================================
      -- archive old exception -- Purchase order compresses lead time
   --=====================================================
   msc_x_netting_pkg.add_to_delete_tbl(
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_item_id(j),
      msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER,
      msc_x_netting_pkg.G_EXCEP14,
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

   --======================================================
      -- archive old exception --Customer purchase order compresses lead time
   --=====================================================
    msc_x_netting_pkg.add_to_delete_tbl(
      b_supplier_id(j),
      b_supplier_site_id(j),
      b_publisher_id(j),
      b_publisher_site_id(j),
      null,
      null,
      b_item_id(j),
      msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER,
      msc_x_netting_pkg.G_EXCEP15,
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


   ----------------------------------------------------------------------
   -- getting the lead time
   ----------------------------------------------------------------------
   IF (j = 1 or b_publisher_id(j-1) <> b_publisher_id(j) or
                  b_publisher_site_id(j-1) <> b_publisher_site_id(j) or
                  b_supplier_id(j-1) <> b_supplier_id(j) or
                  b_supplier_site_id(j-1) <> b_supplier_site_id(j) or
                  b_item_id(j-1) <> b_item_id(j) ) THEN
   	l_threshold := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP14,
         	b_publisher_id(j),
         	b_publisher_site_id(j),
         	b_item_id(j),
         	b_supplier_id(j),
         	b_supplier_site_id(j),
         	null,
         	null,
         	b_po_key_date(j)) ;
    	l_transit_time := MSC_X_UTIL.GET_CUSTOMER_TRANSIT_TIME(b_supplier_id(j),
                           b_supplier_site_id(j),
                           b_publisher_id(j),
                           b_publisher_site_id(j) )  ;

    END IF;

    IF (b_po_key_date(j) + l_threshold < b_po_creation_date(j) + b_lead_time(j) + l_transit_time) THEN

	SELECT count(*)
	into l_count
	FROM msc_x_exception_details d
        WHERE  d.exception_type  = msc_x_netting_pkg.G_EXCEP4
        AND   d.transaction_id1 = b_trx_id1(j);

        IF (l_count > 0) THEN

   		--------------------------------------------------------------------------
   		-- get the shipping control
   		--------------------------------------------------------------------------
   		l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_publisher_name(j),
                                    b_publisher_site_name(j),
                                    b_supplier_name(j),
                                    b_supplier_site_name(j));

   		l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

    		l_exception_type := msc_x_netting_pkg.G_EXCEP14; -- your PO to supplier requires lead time comp.
    		l_exception_group := msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER;
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
                                l_threshold,
                                b_lead_time(j) + l_transit_time,
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

 		END IF; -- l_count
 	/*------------------------------------------------------------------------------
 	Exception_15: Customer purchase order compresses lead time
 	--------------------------------------------------------------------------------*/
 	l_count := 0;

 	SELECT count(*)
 	INTO   l_count
 	FROM msc_x_exception_details d
	WHERE d.exception_type  = msc_x_netting_pkg.G_EXCEP3
        AND   d.transaction_id1 = b_trx_id1(j);

        IF (l_count > 0 ) THEN
  		l_exception_type := msc_x_netting_pkg.G_EXCEP15; -- cust po to you requires lead time comp.
  		l_exception_group := msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER;

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
                                null,                   --l_trx_id2,
                                b_publisher_id(j),         --l_customer_id,
                                b_publisher_name(j),
                                b_publisher_site_id(j),    --l_customer_site_id,
                                b_publisher_site_name(j),
                                b_customer_item_name(j),
                                null,        --l_supplier_id,
                                null,
                                null,        --l_supplier_site_id,
                                null,
                                b_supplier_item_name(j),
                                b_tp_po_qty(j),
                                null,
                                null,
                                l_threshold,
                                b_lead_time(j) + l_transit_time,
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
            END IF;	-- l_count
      END IF;
 END LOOP;
END IF;


FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(14) || '-' ||
	msc_x_netting_pkg.get_message_type(15) ||
         ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));


-----------------------------------------------------------------------------
-- exception 16:
--ShipDate(SOLTP_VIEWER) - Creation_Date(SOLTP_VIEWER)  <
--ItemLeadTimeTP_VIEWER(SOLTP_VIEWER) + threshold

--Compression Days = Lead Time - [ShipDate - Creation Date]
---------------------------------------------------------------------------
l_threshold := 0;
l_transit_time := 0;

open exception_16 (p_refresh_number);
     fetch exception_16 BULK COLLECT INTO
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
                                b_order_number,
                                b_release_number,
                                b_line_number,
                                b_customer_id,                  --so org
                                b_customer_name,
                                b_customer_site_id,
                                b_customer_site_name,
                                b_customer_item_name,
                                b_customer_item_desc,
                                b_so_creation_date;

  CLOSE exception_16;



IF (b_trx_id1 is not null and b_trx_id1.COUNT > 0) THEN
  FOR j in 1..b_trx_id1.COUNT
  LOOP
   --dbms_output.put_line('-----Exception16: Trx id 1 = ' || b_trx_id1(j) );

   	--======================================================
      	-- archive old exception
   	--=====================================================
   	msc_x_netting_pkg.add_to_delete_tbl(
      	b_publisher_id(j),
      	b_publisher_site_id(j),
      	b_customer_id(j),
      	b_customer_site_id(j),
      	null,
      	null,
      	b_item_id(j),
      	msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER,
      	msc_x_netting_pkg.G_EXCEP16,
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


    ----------------------------------------------------------------------
    -- getting the lead time
    ----------------------------------------------------------------------
    IF (j =1 or b_publisher_id(j-1) <> b_publisher_id(j) or
                   b_publisher_site_id(j-1) <> b_publisher_site_id(j) or
                   b_customer_id(j-1) <> b_customer_id(j) or
                   b_customer_site_id(j-1) <> b_customer_site_id(j) or
                   b_item_id(j-1) <> b_item_id(j) ) THEN
    	l_threshold := msc_pmf_pkg.get_threshold(msc_x_netting_pkg.G_EXCEP16,
          	b_publisher_id(j),
          	b_publisher_site_id(j),
          	b_item_id(j),
          	null,
          	null,
          	b_customer_id(j),
          	b_customer_site_id(j),
          	b_so_key_date(j)) ;

    END IF;


    IF (b_so_key_date(j) < b_so_creation_date(j) + abs(trunc(b_so_receipt_date(j)) - trunc(b_so_ship_date(j)))  - l_threshold) THEN

   	--------------------------------------------------------------------------
   	-- get the shipping control
   	--------------------------------------------------------------------------
   	l_shipping_control := MSC_X_UTIL.GET_SHIPPING_CONTROL(b_customer_name(j),
                                    b_customer_site_name(j),
                                    b_publisher_name(j),
                                    b_publisher_site_name(j));

   	l_exception_basis := MSC_X_UTIL.GET_LOOKUP_MEANING('MSC_X_SHIPPING_CONTROL',
			   		nvl(l_shipping_control,1));

    	l_exception_type := msc_x_netting_pkg.G_EXCEP16; -- your so requires lead time comp.
    	l_exception_group := msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER;
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
                                null,        --l_trx_id2,
                                b_customer_id(j),          --l_customer_id,
                                b_customer_name(j),
                                b_customer_site_id(j),     --l_customer_site_id,
                                b_customer_site_name(j),
                                b_customer_item_name(j),
                                null,        --l_supplier_id,
                                null,
                                null,        --l_supplier_site_id,
                                null,
                                b_supplier_item_name(j),
                                b_so_qty(j),
                                null,
                                null,
                                l_threshold,
                                abs(trunc(b_so_receipt_date(j)) - trunc(b_so_ship_date(j))),
            			null,       --l_item_min,
            			null,       --l_item_max,
                                b_order_number(j),
                                b_release_number(j),
                                b_line_number(j),
                                null,                   --l_end_order_number,
                                null,                   --l_end_order_rel_number,
                                null,                   --l_end_order_line_number,
                  	        b_so_creation_date(j),
                  	        null,
                  	        b_so_ship_date(j),
                  	        b_so_receipt_date(j),
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
end loop;
END IF;

FND_FILE.PUT_LINE(FND_FILE.LOG, 'Done: ' ||msc_x_netting_pkg.get_message_type(16) ||
      '.' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));



FND_FILE.PUT_LINE(FND_FILE.LOG, 'Total exceptions inserted for the group ' ||
 msc_x_netting_pkg.get_message_group(msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER) || ':' || l_inserted_record);

EXCEPTION
   when others then
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING3_PKG.Compute_Potential_Late_Order');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
--      dbms_output.put_line('Error in compute potential late order ' || sqlerrm);
      return;

END Compute_Potential_Late_Order;

END MSC_X_NETTING3_PKG;


/
