--------------------------------------------------------
--  DDL for Package Body MSC_CL_PUBLISH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_PUBLISH" AS -- body
/* $Header: MSCXCPB.pls 120.11.12010000.3 2009/10/09 12:31:30 sbnaik ship $ */


   --=================
   -- Global variables
   --=================
   v_oh_refresh_number NUMBER;
   v_supply_refresh_number NUMBER;
   v_so_refresh_number NUMBER;
   v_suprep_refresh_number NUMBER;

   G_ASN_DESC    varchar2(80);
   G_PO_DESC    varchar2(80);
   G_REQ_DESC    varchar2(80);

   G_SHIP_CONTROL              VARCHAR2(30);
   G_ARRIVE_CONTROL            VARCHAR2(30);

   PROCEDURE LOG_MESSAGE( pBUFF                     IN  VARCHAR2)
   IS
   BEGIN

     IF fnd_global.conc_request_id > 0 THEN   -- concurrent program

         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
          --dbms_output.put_line( pBUFF);

     ELSE

        --  dbms_output.put_line( pBUFF);
       null;

     END IF;

   END LOG_MESSAGE;

   PROCEDURE LOG_DEBUG( pBUFF                     IN  VARCHAR2)
   IS
   BEGIN

     IF (fnd_global.conc_request_id > 0 AND (G_MSC_DEBUG = 'Y')) THEN

         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);

     ELSE
         NULL;
         -- DBMS_OUTPUT.PUT_LINE( pBUFF);

     END IF;

   END LOG_DEBUG;


-- ==========================================================================================
-- PROCEDURE : INITIALIZE_REFRESH_NUM
--
-- This procedure initilizes refresh numbers foreach entity. This is required for contineous
-- collections.

-- Refresh numbers resolved in this procedure are used in each Cursors.
-- ==========================================================================================

   PROCEDURE INITIALIZE_REFRESH_NUM (p_refresh_number NUMBER,
									 p_lrtype VARCHAR2 ,
                                     p_po_enabled_flag    NUMBER,
                                     p_oh_enabled_flag    NUMBER,
                                     p_so_enabled_flag    NUMBER,
                                     p_asl_enabled_flag   NUMBER,
                                     p_sup_resp_flag      NUMBER,
                                     p_po_sn_flag         NUMBER,
                                     p_oh_sn_flag         NUMBER,
                                     p_so_sn_flag         NUMBER,
									 p_suprep_sn_flag     NUMBER) IS
   BEGIN

    -- ==============================
    -- Initialize the refresh numbers
    -- ==============================
    v_oh_refresh_number := -1;
    v_supply_refresh_number := -1;
    v_so_refresh_number := -1;
	v_suprep_refresh_number := -1;

    IF (p_lrtype = 'T') THEN

        IF (nvl(p_po_enabled_flag, SYS_NO) = SYS_YES AND
            nvl(p_PO_SN_FLAG, G_AUTO_NO_COLL) <> G_AUTO_NO_COLL
           ) THEN

            v_supply_refresh_number := p_refresh_number;

        END IF;

        IF (nvl(p_oh_enabled_flag, SYS_NO) = SYS_YES AND
            nvl(p_OH_SN_FLAG, G_AUTO_NO_COLL) <> G_AUTO_NO_COLL
           ) THEN

            v_oh_refresh_number := p_refresh_number;

        END IF;

        IF (nvl( p_so_enabled_flag, SYS_NO) = SYS_YES AND
            nvl(p_SO_SN_FLAG, G_AUTO_NO_COLL) <> G_AUTO_NO_COLL
           ) THEN

            v_so_refresh_number := p_refresh_number;

        END IF;

        IF (nvl( p_sup_resp_flag, SYS_NO) = SYS_YES AND
            nvl(p_suprep_sn_flag, G_AUTO_NO_COLL) <> G_AUTO_NO_COLL
           ) THEN

            v_suprep_refresh_number := p_refresh_number;

        END IF;

        LOG_DEBUG ('  Refresh Number for supply entities :' ||v_supply_refresh_number);
        LOG_DEBUG ('  Refresh Number for onHand entities :' ||v_oh_refresh_number);
        LOG_DEBUG ('  Refresh Number for Sales Order entities :' ||v_so_refresh_number);
        LOG_DEBUG ('  Refresh Number for Supplier Responses :' ||v_suprep_refresh_number);

    END IF; -- (v_lrtype = 'T')

   END INITIALIZE_REFRESH_NUM ;

-- ===============================================
-- Procedure : PUBLISH
--
-- ===============================================
PROCEDURE PUBLISH (ERRBUF		OUT NOCOPY VARCHAR2,
		   RETCODE	        OUT NOCOPY NUMBER,
                   p_sr_instance_id	    NUMBER,
                   p_user_id		    NUMBER,
                   p_po_enabled_flag    NUMBER,
                   p_oh_enabled_flag    NUMBER,
                   p_so_enabled_flag    NUMBER,
				   p_asl_enabled_flag   NUMBER,
				   p_sup_resp_flag		NUMBER,
				   p_po_sn_flag         NUMBER,
				   p_oh_sn_flag         NUMBER,
				   p_so_sn_flag         NUMBER,
				   p_suprep_sn_flag     NUMBER) IS
v_refresh_number	NUMBER;
v_apps_ver               NUMBER;
v_lrtype		varchar2(1);
v_so_lrtype		varchar2(1);

v_sr_dblink             VARCHAR2(128);

type varcharlist is table of varchar2(2);
t_status_code varcharlist := varcharlist();
t_ins_status_code varcharlist := varcharlist();
lv_sql_stmt  varchar2(14000);
lv_sql_stmt1  varchar2(14000);
lv_sql_stmt2  varchar2(14000);
lv_sql_stmt3  varchar2(14000);
lv_sql_stmt4  varchar2(14000);

   TYPE CurTyp IS REF CURSOR; -- define weak REF CURSOR type -Cursor variable
   CUR_DELIVERY_ASN              CurTyp;


   G_NULL_STRING          VARCHAR2(10) := '-234567';
   G_PLAN_ID              NUMBER       := -1;
   G_SR_INSTANCE_ID       NUMBER       := -1;
   G_OEM_ID		  NUMBER       := 1;
   G_SR_OEM_ID		  NUMBER       := -1;
   G_UNALLOC_ONHAND       NUMBER       := 10;
   G_ALLOC_ONHAND	  NUMBER       := 9;
   G_DAILY_BKT_TYPE	  NUMBER       := 1;
   G_MRP_ONHAND		  NUMBER       := 18;
   G_SUPPLIER		  NUMBER       := 1;
   G_CUSTOMER		  NUMBER       := 2;
   G_ORGANIZATION	  NUMBER	   := 3;
   G_SITE_MAP_TYPE	  NUMBER       := 3;
   G_SALES_ORDER	  NUMBER       := 14;
   G_PO			  NUMBER       := 13;
   G_REQ		  NUMBER       := 20;
   G_ASN		  NUMBER       := 15;
   G_SHIP_RECEIPT	  NUMBER       := 16;

   /* PO-SHIP-DATE */
   G_SHIP                 NUMBER       := 1;
   G_ARRIVAL              NUMBER       := 2;

    /* If last collection method is Partial or Complete then
       we need to pull all records.
       else
       we need to pull records where we find refresh_number = v_refresh_number

       We will also need to build collections objects order to call
       SCE Loads API.
    */


CURSOR mscSupply(p_refresh_number NUMBER,
                 p_sr_instance_id NUMBER,
				 p_language_code  VARCHAR2) IS
select  --msc_sup_dem_entries_s.nextval transaction_id
       G_SR_INSTANCE_ID	 sr_instance_id
       ,G_PLAN_ID        	 plan_id
       ,decode(ms.order_type, 11, mcr.object_id , G_OEM_ID)     publisher_id  -- Bug 4395985
       ,decode(ms.order_type, 11, mtpm1.company_key , mcsil.company_site_id)    publisher_site_id
       ,decode(ms.order_type, 11, mc1.company_name, mc.company_name)      publisher_name
       ,decode(ms.order_type, 11, mcs1.company_site_name, mcs.company_site_name)    publisher_site_name
       ,ms.inventory_item_id     inventory_item_id
       ,ms.new_order_quantity    quantity
       ,decode(ms.order_type, 1,13,
                              2,20,
                              8,16,
                              11,15)      publisher_order_type
       ,nvl(ms.new_dock_date, ( ms.new_schedule_date - nvl( mi.POSTPROCESSING_LEAD_TIME,0))) receipt_date
--       ,ms.new_schedule_date    ship_date
       ,mcr.object_id           supplier_id
       ,mc1.company_name        supplier_name
       ,mtpm1.company_key        supplier_site_id
       ,mcs1.company_site_name  supplier_site_name
       ,ms.purch_line_num       Order_line_number
       ,decode(instr(ms.order_number,'('),
				   0, ms.order_number,
			   substr(ms.order_number, 1, instr(ms.order_number,'(') - 1)) order_number
       ,1                       ship_to_party_id
       ,mcsil.company_site_id   ship_to_party_site_id
       ,mc.company_name         ship_to_party_name
       ,mcs.company_site_name   ship_to_party_site_name
       ,mcr.object_id           ship_from_party_id
       ,mtpm1.company_key        SHIP_FROM_PARTY_SITE_ID
       ,mc1.company_name        SHIP_FROM_PARTY_NAME
       ,mcs1.company_site_name  SHIP_FROM_PARTY_SITE_NAME
       ,mi.item_name            publisher_item_name
       ,mi.description          pub_item_description
       ,mi.uom_code		uom_code
       ,flv.meaning             publisher_order_type_desc
       ,1                       bucket_type
       ,'Day'                   bucket_type_desc
       ,'PUBLISH'    		comments
       ,p_user_id 		created_by
       ,ms.creation_date	creation_date
       ,p_user_id		last_updated_by
       ,ms.last_update_date	last_update_date
       ,decode(order_type, 1, ms.new_dock_date,
                           2, ms.new_dock_date,
                           8, ms.new_schedule_date,
                          11, ms.new_schedule_date) key_date
       ,ms.supplier_id		partner_id
       ,ms.supplier_site_id	partner_site_id
       ,ms.sr_instance_id	orig_sr_instance_id
       ,ms.organization_id	t_organization_id
	   ,decode(ms.order_type, 1, TRIM(substr(ms.order_number,instr(ms.order_number,'(')+1,instr(ms.order_number,'(',1,2)-2
	   - instr(ms.order_number,'('))) ,  decode(instr(ms.order_number,'('),			   0, to_char(null),
	   substr(ms.order_number, instr(ms.order_number,'(')))) release_number
	   ,ms.NEW_ORDER_PLACEMENT_DATE order_placement_date
       ,ms.vmi_flag
	   ,ms.acceptance_required_flag acceptance_required_flag
	   ,ms.need_by_date
	   ,ms.promised_date
	   , mi.base_item_id
	   , itm.item_name
           , to_number(NULL) --- internal flag
	   ,mi.planner_code  --Bug 4424426
from
       msc_supplies ms
-- Table to get org equivalent company_site_id
       ,msc_companies mc
       ,msc_company_sites mcs
       ,msc_company_site_id_lid mcsil
-- Tables to get Supplier's company_id
       ,msc_trading_partner_maps mtpm
       ,msc_company_relationships mcr
       ,msc_companies mc1
-- Tables to get Supplier's company_site_id
       ,msc_trading_partner_maps mtpm1
       ,msc_company_sites mcs1
-- Table to get global item_id
       , msc_system_items mi
       , msc_items itm
-- Table to get order type description
       ,fnd_lookup_values flv
where
       ms.sr_instance_id = p_sr_instance_id
-- Get PO related transactions
and order_type IN (1,2,8,11)
-- Get only ODS records
and ms.plan_id = G_PLAN_ID
-- Join with msc_company_site_id_lid to get org equivalent company_site_id
and ms.organization_id = mcsil.sr_company_site_id
and ms.sr_instance_id  = mcsil.sr_instance_id
and mcsil.partner_type = G_ORGANIZATION
and mcsil.sr_company_id = G_SR_OEM_ID
and mcsil.company_site_id = mcs.company_site_id
and mcs.company_id = mc.company_id
    -- Make sure that only OEM's PO are published
and mcs.company_id = G_OEM_ID
-- Join with msc_system_items to get Item related information
and ms.inventory_item_id = mi.inventory_item_id
and ms.organization_id   = mi.organization_id
and ms.sr_instance_id    = mi.sr_instance_id
and ms.plan_id		 = mi.plan_id
and itm.inventory_item_id (+)= mi.base_item_id
and mi.inventory_planning_code <> 7  --- vmi
-- Get the Supplier's company_id
and ms.supplier_id       = mtpm.tp_key
and mtpm.map_type 	 = 1
and mtpm.company_key 	 = mcr.relationship_id
and mcr.object_id 	 = mc1.company_id
-- Get the supplier's company_site_id. Use Outer joint
-- with msc_trading_partner_maps since some order types
-- supplier site is optional
and nvl(ms.supplier_site_id, -99) = mtpm1.tp_key
and mtpm1.map_type 	 = 3
and mtpm1.company_key 	 = mcs1.company_site_id
-- Get the order type description
and decode(ms.order_type, 1,13, 2,20, 8,16, 11,15) = flv.lookup_code
-- and decode(ms.order_type, 1,13, 2,20, 8,16, 11,15, 12,16) = flv.lookup_code
and flv.lookup_type = 'MSC_X_ORDER_TYPE'
and flv.language = p_language_code
-- Get the rows according to last collection metnod
and nvl(ms.refresh_number, -1) = decode(v_lrtype, 'C', nvl(p_refresh_number, -1)
                                               , 'P', nvl(p_refresh_number, -1)
                                               , 'I', p_refresh_number
					      , 'T', decode (p_po_sn_flag, G_AUTO_NET_COLL, p_refresh_number,
								G_AUTO_TAR_COLL,  nvl(p_refresh_number, -1)))
UNION ALL  /* Get internal reqs for customer vmi enabled items in mod orgs */
select
       G_SR_INSTANCE_ID	 sr_instance_id
       ,G_PLAN_ID        	 plan_id
       ,G_OEM_ID                 publisher_id
       ,mcs2.company_site_id    publisher_site_id
       ,mc2.company_name          publisher_name
       ,mcs2.company_site_name    publisher_site_name
       ,ms.inventory_item_id     inventory_item_id
       ,ms.new_order_quantity    quantity
       , 20 publisher_order_type
       ,nvl(ms.new_dock_date, ( ms.new_schedule_date - nvl( mi.POSTPROCESSING_LEAD_TIME,0))) receipt_date
--       ,ms.new_schedule_date    ship_date
       , G_OEM_ID         supplier_id
       ,mc2.company_name        supplier_name
       ,mcs2.company_site_id       supplier_site_id
       ,mcs2.company_site_name  supplier_site_name
       ,ms.purch_line_num       Order_line_number
       ,decode(instr(ms.order_number,'('),
				   0, ms.order_number,
			   substr(ms.order_number, 1, instr(ms.order_number,'(') - 1)) order_number
       ,mc.company_id         ship_to_party_id
       ,mcs.company_site_id   ship_to_party_site_id
       ,mc.company_name         ship_to_party_name
       ,mcs.company_site_name   ship_to_party_site_name
       ,G_OEM_ID           ship_from_party_id
       ,mcs2.company_site_id       SHIP_FROM_PARTY_SITE_ID
       ,mc2.company_name        SHIP_FROM_PARTY_NAME
       ,mcs2.company_site_name  SHIP_FROM_PARTY_SITE_NAME
       ,mi.item_name            publisher_item_name
       ,mi.description          pub_item_description
       ,mi.uom_code		uom_code
       ,flv.meaning             publisher_order_type_desc
       ,1                       bucket_type
       ,'Day'                   bucket_type_desc
       ,'PUBLISH'    		comments
       ,p_user_id 		created_by
       ,ms.creation_date	creation_date
       ,p_user_id		last_updated_by
       ,ms.last_update_date	last_update_date
       ,ms.new_dock_date        key_date
       ,to_number(NULL)		partner_id
       ,to_number(NULL)	partner_site_id
       ,ms.sr_instance_id	orig_sr_instance_id
       ,ms.organization_id	t_organization_id
	   ,decode(instr(order_number,'('),
			   0, to_char(null),
			   substr(order_number, instr(order_number,'('))) release_number
	   ,ms.NEW_ORDER_PLACEMENT_DATE order_placement_date
       ,ms.vmi_flag
	   ,ms.acceptance_required_flag acceptance_required_flag
	   ,ms.need_by_date
	   ,ms.promised_date
	   ,to_number(null)  -- base_item_id
	   ,to_char(null)  -- base item_name
	   , SYS_YES
	   ,mi.planner_code --Bug 4424426
from
       msc_supplies ms
      , msc_trading_partners mtp
-- Table to get customer/customer site
       ,msc_companies mc
       ,msc_company_sites mcs
       , msc_trading_partner_maps map1
-- Tables to get Supplier Site
       ,msc_trading_partner_maps map2
       , msc_trading_partners mtp2
       ,msc_company_sites mcs2
       , msc_companies mc2
-- Table to get global item_id
       ,msc_system_items mi
-- Table to get order type description
       ,fnd_lookup_values flv
where
       ms.sr_instance_id = p_sr_instance_id
-- Get  Internal Reqs
and ms.order_type  = 2
and ms.plan_id = -1
and ms.source_organization_id is not null
and ms.source_organization_id <> ms.organization_id
and ms.supplier_id is null
and ms.supplier_site_id is null
----Get only reqs in customer modelled orgs with vmi enabled
and ms.organization_id = mtp.sr_tp_id
and ms.sr_instance_id  = mtp.sr_instance_id
and mtp.partner_type = 3
and mtp.modeled_customer_id is not null
and mtp.modeled_customer_site_id is not null
-- Get only ODS records
and ms.plan_id = G_PLAN_ID
-- Get the customer customer site
and mtp.modeled_customer_site_id = map1.tp_key
and map1.map_type = 3
and map1.company_key = mcs.company_site_id
and mc.company_id = mcs.company_id
-- Get the supplier site id
and ms.source_organization_id = mtp2.sr_tp_id
and ms.source_sr_instance_id = mtp2.sr_instance_id
and mtp2.partner_type = 3
and mtp2.partner_id = map2.tp_key
and map2.map_type = 2
and map2.company_key = mcs2.company_site_id
and mc2.company_id = mcs2.company_id
-- Join with msc_system_items to get Item related information
and ms.inventory_item_id = mi.inventory_item_id
and ms.organization_id   = mi.organization_id
and ms.sr_instance_id    = mi.sr_instance_id
and ms.plan_id		 = mi.plan_id
and mi.inventory_planning_code = 7  --- vmi
-- Get the order type description
and flv.lookup_code = decode(ms.order_type,2,20)  -- Requisition
and flv.lookup_type = 'MSC_X_ORDER_TYPE'
and flv.language = p_language_code
and  flv.lookup_code = 20
-- Get the rows according to last collection metnod
and nvl(ms.refresh_number, -1) = decode(v_lrtype, 'C', nvl(p_refresh_number, -1)
                                               , 'P', nvl(p_refresh_number, -1)
                                               , 'I', p_refresh_number
					      , 'T', decode (p_po_sn_flag, G_AUTO_NET_COLL, p_refresh_number,
								G_AUTO_TAR_COLL,  nvl(p_refresh_number, -1)));

CURSOR allocOnhand(p_refresh_number NUMBER,
                   p_sr_instance_id NUMBER,
				   p_language_code  VARCHAR2) IS
select
G_PLAN_ID 			PLAN_ID,
G_SR_INSTANCE_ID 		SR_INSTANCE_ID,
G_OEM_ID		 	PUBLISHER_ID,
mcs.company_site_id 		PUBLISHER_SITE_ID,
mc.company_name 		PUBLISHER_NAME,
mcs.company_site_name 		PUBLISHER_SITE_NAME,
ms.inventory_item_id 		INVENTORY_ITEM_ID,
SUM(nvl(ms.new_order_quantity,0)) 		QUANTITY,
'PUBLISH' 			COMMENTS,
G_ALLOC_ONHAND			PUBLISHER_ORDER_TYPE,
mc1.company_id		 	SUPPLIER_ID,
mc1.company_name 		SUPPLIER_NAME,
mtpm.company_key 		SUPPLIER_SITE_ID,
mcs1.company_site_name 		SUPPLIER_SITE_NAME,
G_DAILY_BKT_TYPE		BUCKET_TYPE,
mi.item_name 			PUBLISHER_ITEM_NAME,
mi.description 			PUB_ITEM_DESCRIPTIION   ,
flv.meaning 			PUBLISHER_ORDER_TYPE_DESC,
flv.meaning 			TP_ORDER_TYPE_DESC,
'Day'  				BUCKET_TYPE_DESC,
mi.uom_code 			UOM_CODE,
mi.uom_code			PRIMARY_UOM,
SUM(nvl(ms.new_order_quantity,0))  		PRIMARY_QUANTITY,
mtps.partner_id			PARTNER_ID,
mtps.partner_site_id		PRATNER_SITE_ID,
ms.sr_instance_id		ORIG_SR_INSTANCE_ID,
ms.organization_id		ORGANIZATION_ID
, ms.vmi_flag           VMI_FLAG
,G_SUPPLIER			ALLOCATION_TYPE
, mi.base_item_id		BASE_ITEM_ID
, itm.item_name			BASE_ITEM_NAME
,mi.planner_code		PLANNER_CODE --Bug 4424426
from 	msc_supplies ms
--========================================
-- Tables to get Publisher's organization_id
--========================================
	, msc_company_site_id_lid mcsil
	, msc_company_sites mcs
	, msc_companies mc
--========================================
-- Tables to get Supplier's information
--========================================
	, msc_trading_partner_sites mtps
	, msc_trading_partner_maps mtpm
	, msc_company_sites mcs1
	, msc_companies mc1
--========================================
-- Tables to get Item information
--========================================
	, msc_system_items mi
	, msc_items itm
--==================================
-- Tables to lookup type description
--==================================
	, fnd_lookup_values flv
where
--============================================
-- Joins for getting Allocated On hand records
--============================================
        ms.plan_id 	      = G_PLAN_ID
and 	ms.sr_instance_id     = p_sr_instance_id
and 	ms.order_type 	      = G_MRP_ONHAND
and     ms.planning_partner_site_id is not null
and     ms.planning_tp_type   = G_SUPPLIER
--==========================================
-- Joins to get Org equivalent company site.
--==========================================
and	ms.organization_id    = mcsil.sr_company_site_id
and	ms.sr_instance_id     = mcsil.sr_instance_id
and     mcsil.company_site_id = mcs.company_site_id
and     mcsil.partner_type    = G_ORGANIZATION
and     mcsil.sr_company_id   = G_SR_OEM_ID
and     mcs.company_id        = mc.company_id
and     mc.company_id         = G_OEM_ID
--========================================
-- Joins to get supplier site information.
--========================================
and     ms.planning_partner_site_id = mtps.partner_site_id
and     mtps.partner_site_id	    = mtpm.tp_key
and     mtpm.map_type 		    = G_SITE_MAP_TYPE
and     mtpm.company_key	    = mcs1.company_site_id
and     mcs1.company_id		    = mc1.company_id
--========================================
-- Joins to get Item information.
--========================================
and     ms.inventory_item_id 	= mi.inventory_item_id
and     ms.organization_id 	= mi.organization_id
and     ms.sr_instance_id 	= mi.sr_instance_id
and     ms.plan_id 		= mi.plan_id
and     itm.inventory_item_id (+)= mi.base_item_id
--=====================================
-- Joins to get Lookup Type description
--=====================================
and    flv.lookup_code = decode(ms.order_type,G_MRP_ONHAND,G_ALLOC_ONHAND)
and    flv.lookup_code = G_ALLOC_ONHAND
and    flv.lookup_type = 'MSC_X_ORDER_TYPE'
and    flv.language = p_language_code
--================================================
-- Net Change / Targetted / Complete refresh check
--================================================
and nvl(ms.refresh_number, -1) = decode(v_lrtype, 'C', nvl(p_refresh_number, -1)
                                               , 'P', nvl(p_refresh_number, -1)
                                               , 'I', p_refresh_number
					, 'T', decode (p_oh_sn_flag, G_AUTO_NET_COLL, p_refresh_number,
							     G_AUTO_TAR_COLL,  nvl(p_refresh_number, -1))
                                       )

GROUP BY
G_PLAN_ID,
G_SR_INSTANCE_ID,
G_OEM_ID,
mcs.company_site_id,
mc.company_name,
mcs.company_site_name,
ms.inventory_item_id,
'PUBLISH',
G_ALLOC_ONHAND,
mc1.company_id,
mc1.company_name,
mtpm.company_key,
mcs1.company_site_name,
G_DAILY_BKT_TYPE ,
mi.item_name,
mi.description,
flv.meaning,
flv.meaning,
'Day',
mi.uom_code,
mi.uom_code,
mtps.partner_id,
mtps.partner_site_id,
ms.sr_instance_id,
ms.organization_id
, ms.vmi_flag
, G_SUPPLIER
, mi.base_item_id
, itm.item_name
,mi.planner_code --Bug 4424426
UNION   /* sbala: get on hand in modelled supplier  orgs */
select
G_PLAN_ID 			PLAN_ID,
G_SR_INSTANCE_ID 		SR_INSTANCE_ID,
G_OEM_ID		 	PUBLISHER_ID,
mcs.company_site_id 		PUBLISHER_SITE_ID,
mc.company_name 		PUBLISHER_NAME,
mcs.company_site_name 		PUBLISHER_SITE_NAME,
ms.inventory_item_id 		INVENTORY_ITEM_ID,
SUM(nvl(ms.new_order_quantity,0)) 		QUANTITY,
'PUBLISH' 			COMMENTS,
G_ALLOC_ONHAND			PUBLISHER_ORDER_TYPE,
mc1.company_id		 	SUPPLIER_ID,
mc1.company_name 		SUPPLIER_NAME,
mtpm.company_key 		SUPPLIER_SITE_ID,
mcs1.company_site_name 		SUPPLIER_SITE_NAME,
G_DAILY_BKT_TYPE		BUCKET_TYPE,
mi.item_name 			PUBLISHER_ITEM_NAME,
mi.description 			PUB_ITEM_DESCRIPTIION   ,
flv.meaning 			PUBLISHER_ORDER_TYPE_DESC,
flv.meaning 			TP_ORDER_TYPE_DESC,
'Day'  				BUCKET_TYPE_DESC,
mi.uom_code 			UOM_CODE,
mi.uom_code			PRIMARY_UOM,
SUM(nvl(ms.new_order_quantity,0))  		PRIMARY_QUANTITY,
mtps.partner_id			PARTNER_ID,
mtps.partner_site_id		PRATNER_SITE_ID,
ms.sr_instance_id		ORIG_SR_INSTANCE_ID,
ms.organization_id		ORGANIZATION_ID,
ms.vmi_flag             VMI_FLAG,
G_SUPPLIER			ALLOCATION_TYPE,
mi.base_item_id			BASE_ITEM_ID,
itm.item_name			BASE_ITEM_NAME,
mi.planner_code			PLANNER_CODE --Bug 4424426
from 	msc_supplies ms
--========================================
-- Tables to get Publisher's organization_id
--========================================
	, msc_company_site_id_lid mcsil
	, msc_company_sites mcs
	, msc_companies mc
--========================================
-- Tables to get Supplier's information
--========================================
        , msc_trading_partners mtp
	, msc_trading_partner_sites mtps
	, msc_trading_partner_maps mtpm
	, msc_company_sites mcs1
	, msc_companies mc1
--========================================
-- Tables to get Item information
--========================================
	, msc_system_items mi
	, msc_items itm
--==================================
-- Tables to lookup type description
--==================================
	, fnd_lookup_values flv
where
--============================================
-- Joins for getting Allocated On hand records
--============================================
        ms.plan_id 	      = G_PLAN_ID
and 	ms.sr_instance_id     = p_sr_instance_id
and 	ms.order_type 	      = G_MRP_ONHAND
--==========================================
-- Joins to get Org equivalent company site.
--==========================================
and	ms.organization_id    = mcsil.sr_company_site_id
and	ms.sr_instance_id     = mcsil.sr_instance_id
and     mcsil.company_site_id = mcs.company_site_id
and     mcsil.partner_type    = G_ORGANIZATION
and     mcsil.sr_company_id   = G_SR_OEM_ID
and     mcs.company_id        = mc.company_id
and     mc.company_id         = G_OEM_ID
--========================================
-- Joins to get supplier/supplier site information.
--========================================
and     ms.organization_id  = mtp.sr_tp_id   /* sbala Added join to mtp */
and     ms.sr_instance_id   = mtp.sr_instance_id
and     mtp.partner_type = G_ORGANIZATION
and     mtp.modeled_supplier_id is not null
and     mtp.modeled_supplier_site_id is not null
and     mtps.partner_id = mtp.modeled_supplier_id
and     mtps.partner_site_id = mtp.modeled_supplier_site_id
and     mtpm.tp_key = mtp.modeled_supplier_site_id
and     mtpm.map_type 		    = G_SITE_MAP_TYPE
and     mtpm.company_key	    = mcs1.company_site_id
and     mcs1.company_id		    = mc1.company_id
--========================================
-- Joins to get Item information.
--========================================
and     ms.inventory_item_id 	= mi.inventory_item_id
and     ms.organization_id 	= mi.organization_id
and     ms.sr_instance_id 	= mi.sr_instance_id
and     ms.plan_id 		= mi.plan_id
and     itm.inventory_item_id   (+)= mi.base_item_id
--=====================================
-- Joins to get Lookup Type description
--=====================================
and    flv.lookup_code = decode(ms.order_type,G_MRP_ONHAND,G_ALLOC_ONHAND)
and    flv.lookup_code = G_ALLOC_ONHAND
and    flv.lookup_type = 'MSC_X_ORDER_TYPE'
and    flv.language =p_language_code
--================================================
-- Net Change / Targetted / Complete refresh check
--================================================
and nvl(ms.refresh_number, -1) = decode(v_lrtype, 'C', nvl(p_refresh_number, -1)
                                               , 'P', nvl(p_refresh_number, -1)
                                               , 'I', p_refresh_number
						, 'T', decode (p_po_sn_flag, G_AUTO_NET_COLL, p_refresh_number,
								G_AUTO_TAR_COLL,  nvl(p_refresh_number, -1))
                                       )

GROUP BY
G_PLAN_ID,
G_SR_INSTANCE_ID,
G_OEM_ID,
mcs.company_site_id,
mc.company_name,
mcs.company_site_name,
ms.inventory_item_id,
'PUBLISH',
G_ALLOC_ONHAND,
mc1.company_id,
mc1.company_name,
mtpm.company_key,
mcs1.company_site_name,
G_DAILY_BKT_TYPE ,
mi.item_name,
mi.description,
flv.meaning,
flv.meaning,
'Day',
mi.uom_code,
mi.uom_code,
mtps.partner_id,
mtps.partner_site_id,
ms.sr_instance_id,
ms.organization_id,
ms.vmi_flag,
G_SUPPLIER,
mi.base_item_id,
itm.item_name,
mi.planner_code --Bug 4424426
UNION  /* sbala: Added for Select of Customer orgs */
select
G_PLAN_ID 			PLAN_ID,
G_SR_INSTANCE_ID 		SR_INSTANCE_ID,
G_OEM_ID		 	PUBLISHER_ID,
mcs.company_site_id 		PUBLISHER_SITE_ID,
mc.company_name 		PUBLISHER_NAME,
mcs.company_site_name 		PUBLISHER_SITE_NAME,
ms.inventory_item_id 		INVENTORY_ITEM_ID,
SUM(nvl(ms.new_order_quantity,0)) 		QUANTITY,
'PUBLISH' 			COMMENTS,
G_ALLOC_ONHAND			PUBLISHER_ORDER_TYPE,
mc1.company_id		 	SUPPLIER_ID, /* sbala will go into customerid */
mc1.company_name 		SUPPLIER_NAME, /* sbala: CUSTOMER_NAME */
mtpm.company_key 		SUPPLIER_SITE_ID, /* sbala: CUSTOMER SITE ID */
mcs1.company_site_name 		SUPPLIER_SITE_NAME,/* sbala:CUSTOMERSITENAME */
G_DAILY_BKT_TYPE		BUCKET_TYPE,
mi.item_name 			PUBLISHER_ITEM_NAME,
mi.description 			PUB_ITEM_DESCRIPTIION   ,
flv.meaning 			PUBLISHER_ORDER_TYPE_DESC,
flv.meaning 			TP_ORDER_TYPE_DESC,
'Day'  				BUCKET_TYPE_DESC,
mi.uom_code 			UOM_CODE,
mi.uom_code			PRIMARY_UOM,
SUM(nvl(ms.new_order_quantity,0))  		PRIMARY_QUANTITY,
mtps.partner_id			PARTNER_ID,
mtps.partner_site_id		PRATNER_SITE_ID,
ms.sr_instance_id		ORIG_SR_INSTANCE_ID,
ms.organization_id		ORGANIZATION_ID,
ms.vmi_flag             VMI_FLAG,
G_CUSTOMER			ALLOCATION_TYPE,
mi.base_item_id			BASE_ITEM_ID,
itm.item_name			BASE_ITEM_NAME,
mi.planner_code			PLANNER_CODE --Bug 4424426
from 	msc_supplies ms
--========================================
-- Tables to get Publisher's organization_id
--========================================
	, msc_company_site_id_lid mcsil
	, msc_company_sites mcs
	, msc_companies mc
--========================================
-- Tables to get Supplier's information
--========================================
        , msc_trading_partners mtp
	, msc_trading_partner_sites mtps
	, msc_trading_partner_maps mtpm
	, msc_company_sites mcs1
	, msc_companies mc1
--========================================
-- Tables to get Item information
--========================================
	, msc_system_items mi
	, msc_items itm
--==================================
-- Tables to lookup type description
--==================================
	, fnd_lookup_values flv
where
--============================================
-- Joins for getting Allocated On hand records
--============================================
        ms.plan_id 	      = G_PLAN_ID
and 	ms.sr_instance_id     = p_sr_instance_id
and 	ms.order_type 	      = G_MRP_ONHAND
--==========================================
-- Joins to get Org equivalent company site.
--==========================================
and	ms.organization_id    = mcsil.sr_company_site_id
and	ms.sr_instance_id     = mcsil.sr_instance_id
and     mcsil.company_site_id = mcs.company_site_id
and     mcsil.partner_type    = G_ORGANIZATION
and     mcsil.sr_company_id   = G_SR_OEM_ID
and     mcs.company_id        = mc.company_id
and     mc.company_id         = G_OEM_ID
--========================================
-- Joins to get supplier/supplier site information.
--========================================
and     ms.organization_id  = mtp.sr_tp_id   /* sbala Added join to mtp */
and     ms.sr_instance_id   = mtp.sr_instance_id
and     mtp.partner_type = G_ORGANIZATION
and     mtp.modeled_customer_id is not null
and     mtp.modeled_customer_site_id is not null
and     mtps.partner_id = mtp.modeled_customer_id
and     mtps.partner_site_id = mtp.modeled_customer_site_id
and     mtpm.tp_key = mtp.modeled_customer_site_id
and     mtpm.map_type 		    = G_SITE_MAP_TYPE
and     mtpm.company_key	    = mcs1.company_site_id
and     mcs1.company_id		    = mc1.company_id
--========================================
-- Joins to get Item information.
--========================================
and     ms.inventory_item_id 	= mi.inventory_item_id
and     ms.organization_id 	= mi.organization_id
and     ms.sr_instance_id 	= mi.sr_instance_id
and     ms.plan_id 		= mi.plan_id
and     itm.inventory_item_id   (+)= mi.base_item_id
--=====================================
-- Joins to get Lookup Type description
--=====================================
and    flv.lookup_code = decode(ms.order_type,G_MRP_ONHAND,G_ALLOC_ONHAND)
and    flv.lookup_code = G_ALLOC_ONHAND
and    flv.lookup_type = 'MSC_X_ORDER_TYPE'
and    flv.language = p_language_code
--================================================
-- Net Change / Targetted / Complete refresh check
--================================================
and nvl(ms.refresh_number, -1) = decode(v_lrtype, 'C', nvl(p_refresh_number, -1)
                                               , 'P', nvl(p_refresh_number, -1)
                                               , 'I', p_refresh_number
					       , 'T', decode (p_po_sn_flag, G_AUTO_NET_COLL, p_refresh_number,
							     G_AUTO_TAR_COLL,  nvl(p_refresh_number, -1))
                                       )

GROUP BY
G_PLAN_ID,
G_SR_INSTANCE_ID,
G_OEM_ID,
mcs.company_site_id,
mc.company_name,
mcs.company_site_name,
ms.inventory_item_id,
'PUBLISH',
G_ALLOC_ONHAND,
mc1.company_id,
mc1.company_name,
mtpm.company_key,
mcs1.company_site_name,
G_DAILY_BKT_TYPE,
mi.item_name,
mi.description,
flv.meaning,
flv.meaning,
'Day',
mi.uom_code,
mi.uom_code,
mtps.partner_id,
mtps.partner_site_id,
ms.sr_instance_id,
ms.organization_id,
ms.vmi_flag,
G_CUSTOMER,
mi.base_item_id,
itm.item_name,
mi.planner_code --Bug 4424426
;

CURSOR allocOnhandNetChange(p_refresh_number NUMBER,
                   p_sr_instance_id NUMBER ,
				   p_language_code VARCHAR2) IS
select
G_PLAN_ID 			PLAN_ID,
G_SR_INSTANCE_ID 		SR_INSTANCE_ID,
G_OEM_ID		 	PUBLISHER_ID,
mcs.company_site_id 		PUBLISHER_SITE_ID,
mc.company_name 		PUBLISHER_NAME,
mcs.company_site_name 		PUBLISHER_SITE_NAME,
ms.inventory_item_id 		INVENTORY_ITEM_ID,
SUM(nvl(ms.new_order_quantity,0)) 		QUANTITY,
'PUBLISH' 			COMMENTS,
G_ALLOC_ONHAND			PUBLISHER_ORDER_TYPE,
mc1.company_id		 	SUPPLIER_ID,
mc1.company_name 		SUPPLIER_NAME,
mtpm.company_key 		SUPPLIER_SITE_ID,
mcs1.company_site_name 		SUPPLIER_SITE_NAME,
G_DAILY_BKT_TYPE		BUCKET_TYPE,
mi.item_name 			PUBLISHER_ITEM_NAME,
mi.description 			PUB_ITEM_DESCRIPTIION   ,
flv.meaning 			PUBLISHER_ORDER_TYPE_DESC,
flv.meaning 			TP_ORDER_TYPE_DESC,
'Day'  				BUCKET_TYPE_DESC,
mi.uom_code 			UOM_CODE,
mi.uom_code			PRIMARY_UOM,
SUM(nvl(ms.new_order_quantity,0))  		PRIMARY_QUANTITY,
mtps.partner_id			PARTNER_ID,
mtps.partner_site_id		PRATNER_SITE_ID,
ms.sr_instance_id		ORIG_SR_INSTANCE_ID,
ms.organization_id		ORGANIZATION_ID
, ms.vmi_flag           VMI_FLAG
, G_SUPPLIER			ALLOCATION_TYPE
, mi.base_item_id		BASE_ITEM_ID
, itm.item_name			BASE_ITEM_NAME
,mi.planner_code		PLANNER_CODE --Bug 4424426
from 	msc_supplies ms
--========================================
-- Tables to get Publisher's organization_id
--========================================
	, msc_company_site_id_lid mcsil
	, msc_company_sites mcs
	, msc_companies mc
--========================================
-- Tables to get Supplier's information
--========================================
	, msc_trading_partner_sites mtps
	, msc_trading_partner_maps mtpm
	, msc_company_sites mcs1
	, msc_companies mc1
--========================================
-- Tables to get Item information
--========================================
	, msc_system_items mi
	, msc_items itm
--==================================
-- Tables to lookup type description
--==================================
	, fnd_lookup_values flv
where
--============================================
-- Joins for getting Allocated On hand records
--============================================
        ms.plan_id 	      = G_PLAN_ID
and 	ms.sr_instance_id     = p_sr_instance_id
and 	ms.order_type 	      = G_MRP_ONHAND
and     ms.planning_partner_site_id is not null
and     ms.planning_tp_type   = G_SUPPLIER
--==========================================
-- Joins to get Org equivalent company site.
--==========================================
and	ms.organization_id    = mcsil.sr_company_site_id
and	ms.sr_instance_id     = mcsil.sr_instance_id
and     mcsil.company_site_id = mcs.company_site_id
and     mcsil.partner_type    = G_ORGANIZATION
and     mcsil.sr_company_id   = G_SR_OEM_ID
and     mcs.company_id        = mc.company_id
and     mc.company_id         = G_OEM_ID
--========================================
-- Joins to get supplier site information.
--========================================
and     ms.planning_partner_site_id = mtps.partner_site_id
and     mtps.partner_site_id	    = mtpm.tp_key
and     mtpm.map_type 		    = G_SITE_MAP_TYPE
and     mtpm.company_key	    = mcs1.company_site_id
and     mcs1.company_id		    = mc1.company_id
--========================================
-- Joins to get Item information.
--========================================
and     ms.inventory_item_id 	= mi.inventory_item_id
and     ms.organization_id 	= mi.organization_id
and     ms.sr_instance_id 	= mi.sr_instance_id
and     ms.plan_id 		= mi.plan_id
and     itm.inventory_item_id (+)= mi.base_item_id
--=====================================
-- Joins to get Lookup Type description
--=====================================
and    flv.lookup_code = decode(ms.order_type,G_MRP_ONHAND,G_ALLOC_ONHAND)
and    flv.lookup_code = G_ALLOC_ONHAND
and    flv.lookup_type = 'MSC_X_ORDER_TYPE'
and    flv.language =  p_language_code
and    exists
(--==========================================
-- Local View to get Net change information.
--==========================================
        select 1
          from   msc_supplies ms1
          where  plan_id = G_PLAN_ID
          and    sr_instance_id = p_sr_instance_id
	  --==============================================
	-- Joins for getting net change Item information
	--==============================================
	  and    ms.plan_id	      = ms1.plan_id
	  and    ms.sr_instance_id      = ms1.sr_instance_id
	  and    ms.organization_id     = ms1.organization_id
	  and    ms.inventory_item_id   = ms1.inventory_item_id
	  and    ms.planning_partner_site_id = ms1.planning_partner_site_id
	  and    ms.planning_tp_type    = ms1.planning_tp_type
	  and 	 ms1.order_type = G_MRP_ONHAND
	  and    ms1.planning_partner_site_id is not null
	  and    ms1.planning_tp_type = G_SUPPLIER
	  and    nvl(ms1.refresh_number, -1) = p_refresh_number
)
GROUP BY
G_PLAN_ID,
G_SR_INSTANCE_ID,
G_OEM_ID,
mcs.company_site_id,
mc.company_name,
mcs.company_site_name,
ms.inventory_item_id,
'PUBLISH',
G_ALLOC_ONHAND,
mc1.company_id,
mc1.company_name,
mtpm.company_key,
mcs1.company_site_name,
G_DAILY_BKT_TYPE ,
mi.item_name,
mi.description,
flv.meaning,
flv.meaning,
'Day',
mi.uom_code,
mi.uom_code,
mtps.partner_id,
mtps.partner_site_id,
ms.sr_instance_id,
ms.organization_id
, ms.vmi_flag
, G_SUPPLIER
, mi.base_item_id
, itm.item_name
,mi.planner_code		 --Bug 4424426
UNION     /* sbala: Allocated on hand for modeled supplier  records */
select
G_PLAN_ID 			PLAN_ID,
G_SR_INSTANCE_ID 		SR_INSTANCE_ID,
G_OEM_ID		 	PUBLISHER_ID,
mcs.company_site_id 		PUBLISHER_SITE_ID,
mc.company_name 		PUBLISHER_NAME,
mcs.company_site_name 		PUBLISHER_SITE_NAME,
ms.inventory_item_id 		INVENTORY_ITEM_ID,
SUM(nvl(ms.new_order_quantity,0)) 		QUANTITY,
'PUBLISH' 			COMMENTS,
G_ALLOC_ONHAND			PUBLISHER_ORDER_TYPE,
mc1.company_id		 	SUPPLIER_ID,
mc1.company_name 		SUPPLIER_NAME,
mtpm.company_key 		SUPPLIER_SITE_ID,
mcs1.company_site_name 		SUPPLIER_SITE_NAME,
G_DAILY_BKT_TYPE		BUCKET_TYPE,
mi.item_name 			PUBLISHER_ITEM_NAME,
mi.description 			PUB_ITEM_DESCRIPTIION   ,
flv.meaning 			PUBLISHER_ORDER_TYPE_DESC,
flv.meaning 			TP_ORDER_TYPE_DESC,
'Day'  				BUCKET_TYPE_DESC,
mi.uom_code 			UOM_CODE,
mi.uom_code			PRIMARY_UOM,
SUM(nvl(ms.new_order_quantity,0))  		PRIMARY_QUANTITY,
mtps.partner_id			PARTNER_ID,
mtps.partner_site_id		PRATNER_SITE_ID,
ms.sr_instance_id		ORIG_SR_INSTANCE_ID,
ms.organization_id		ORGANIZATION_ID,
ms.vmi_flag             VMI_FLAG,
G_SUPPLIER			ALLOCATION_TYPE,
mi.base_item_id			BASE_ITEM_ID,
itm.item_name			BASE_ITEM_NAME
,mi.planner_code		PLANNER_CODE --Bug 4424426
from 	msc_supplies ms
--========================================
-- Tables to get Publisher's organization_id
--========================================
	, msc_company_site_id_lid mcsil
	, msc_company_sites mcs
	, msc_companies mc

--========================================
-- Tables to get Supplier's information
--========================================
        , msc_trading_partners mtp /* added sbala */
	, msc_trading_partner_sites mtps
	, msc_trading_partner_maps mtpm
	, msc_company_sites mcs1
	, msc_companies mc1
--========================================
-- Tables to get Item information
--========================================
	, msc_system_items mi
	, msc_items itm
--==================================
-- Tables to lookup type description
--==================================
	, fnd_lookup_values flv
where
--============================================
-- Joins for getting Allocated On hand records
--============================================
        ms.plan_id 	      = G_PLAN_ID
and 	ms.sr_instance_id     = p_sr_instance_id
and 	ms.order_type 	      = G_MRP_ONHAND
--==========================================
-- Joins to get Org equivalent company site.
--==========================================
and	ms.organization_id    = mcsil.sr_company_site_id
and	ms.sr_instance_id     = mcsil.sr_instance_id
and     mcsil.company_site_id = mcs.company_site_id
and     mcsil.partner_type    = G_ORGANIZATION
and     mcsil.sr_company_id   = G_SR_OEM_ID
and     mcs.company_id        = mc.company_id
and     mc.company_id         = G_OEM_ID
--========================================
-- Joins to get supplier site information.
--========================================
and     ms.organization_id = mtp.sr_tp_id  /* added joins to mtp sbala */
and     ms.sr_instance_id = mtp.sr_instance_id
and     mtp.partner_type = G_ORGANIZATION
and     mtp.modeled_supplier_id is not null
and     mtp.modeled_supplier_site_id is not null
and     mtps.partner_id = mtp.modeled_supplier_id /* added sbala */
and     mtps.partner_site_id = mtp.modeled_supplier_site_id
and     mtps.partner_site_id	    = mtpm.tp_key
and     mtpm.map_type 		    = G_SITE_MAP_TYPE
and     mtpm.company_key	    = mcs1.company_site_id
and     mcs1.company_id		    = mc1.company_id
--========================================
-- Joins to get Item information.
--========================================
and     ms.inventory_item_id 	= mi.inventory_item_id
and     ms.organization_id 	= mi.organization_id
and     ms.sr_instance_id 	= mi.sr_instance_id
and     ms.plan_id 		= mi.plan_id
and     itm.inventory_item_id (+)= mi.base_item_id
--=====================================
-- Joins to get Lookup Type description
--=====================================
and    flv.lookup_code = decode(ms.order_type,G_MRP_ONHAND,G_ALLOC_ONHAND)
and    flv.lookup_code = G_ALLOC_ONHAND
and    flv.lookup_type = 'MSC_X_ORDER_TYPE'
and    flv.language = p_language_code
and    exists
(--==========================================
-- Local View to get Net change information.
--==========================================
      select     1
          from   msc_supplies ms1,
	         msc_trading_partners mtp2
          where  plan_id = G_PLAN_ID  /* Changes for modeled suppliers sbala */
          and    ms1.sr_instance_id = p_sr_instance_id
	  --==============================================
	-- Joins for getting net change Item information
	--==============================================
	  and    ms.plan_id	      = ms1.plan_id
	  and    ms.sr_instance_id      = ms1.sr_instance_id
	  and    ms.organization_id     = ms1.organization_id
	  and    ms.inventory_item_id   = ms1.inventory_item_id
	  ----and    ms.planning_partner_site_id = X.planning_partner_site_id sbala
	  ----and    ms.planning_tp_type    = X.planning_tp_type sbala
	  and 	 ms1.order_type = G_MRP_ONHAND
	  and    ms1.organization_id = mtp2.sr_tp_id
          and    ms1.sr_instance_id = mtp2.sr_instance_id
	  and    mtp2.partner_type = G_ORGANIZATION
	  and    mtp2.modeled_supplier_id is not null
	  and    mtp2.modeled_supplier_site_id is not null
	  and    nvl(ms1.refresh_number, -1) = p_refresh_number
)
GROUP BY
G_PLAN_ID,
G_SR_INSTANCE_ID,
G_OEM_ID,
mcs.company_site_id,
mc.company_name,
mcs.company_site_name,
ms.inventory_item_id,
'PUBLISH',
G_ALLOC_ONHAND,
mc1.company_id,
mc1.company_name,
mtpm.company_key,
mcs1.company_site_name,
G_DAILY_BKT_TYPE ,
mi.item_name,
mi.description,
flv.meaning,
flv.meaning,
'Day',
mi.uom_code,
mi.uom_code,
mtps.partner_id,
mtps.partner_site_id,
ms.sr_instance_id,
ms.organization_id,
ms.vmi_flag,
G_SUPPLIER,
mi.base_item_id,
itm.item_name
,mi.planner_code		 --Bug 4424426
UNION     /* sbala: Allocated on hand for modeled customer  records */
select
G_PLAN_ID 			PLAN_ID,
G_SR_INSTANCE_ID 		SR_INSTANCE_ID,
G_OEM_ID		 	PUBLISHER_ID,
mcs.company_site_id 		PUBLISHER_SITE_ID,
mc.company_name 		PUBLISHER_NAME,
mcs.company_site_name 		PUBLISHER_SITE_NAME,
ms.inventory_item_id 		INVENTORY_ITEM_ID,
SUM(nvl(ms.new_order_quantity,0)) 		QUANTITY,
'PUBLISH' 			COMMENTS,
G_ALLOC_ONHAND			PUBLISHER_ORDER_TYPE,
mc1.company_id		 	SUPPLIER_ID, /* sbala CUSTOMERID */
mc1.company_name 		SUPPLIER_NAME, /* sbala CUSTOMERNAME */
mtpm.company_key 		SUPPLIER_SITE_ID, /* sbala CUSTOMER SITEID */
mcs1.company_site_name  SUPPLIER_SITE_NAME, /* sbala CUSTOMERSITENAME */
G_DAILY_BKT_TYPE		BUCKET_TYPE,
mi.item_name 			PUBLISHER_ITEM_NAME,
mi.description 			PUB_ITEM_DESCRIPTIION   ,
flv.meaning 			PUBLISHER_ORDER_TYPE_DESC,
flv.meaning 			TP_ORDER_TYPE_DESC,
'Day'  				BUCKET_TYPE_DESC,
mi.uom_code 			UOM_CODE,
mi.uom_code			PRIMARY_UOM,
SUM(nvl(ms.new_order_quantity,0))  		PRIMARY_QUANTITY,
mtps.partner_id			PARTNER_ID,
mtps.partner_site_id		PRATNER_SITE_ID,
ms.sr_instance_id		ORIG_SR_INSTANCE_ID,
ms.organization_id		ORGANIZATION_ID,
ms.vmi_flag             VMI_FLAG,
G_CUSTOMER			ALLOCATION_TYPE,
mi.base_item_id			BASE_ITEM_ID,
itm.item_name			BASE_ITEM_NAME
,mi.planner_code		PLANNER_CODE --Bug 4424426
from 	msc_supplies ms
--========================================
-- Tables to get Publisher's organization_id
--========================================
	, msc_company_site_id_lid mcsil
	, msc_company_sites mcs
	, msc_companies mc

--========================================
-- Tables to get Customer's information
--========================================
        , msc_trading_partners mtp /* added sbala */
	, msc_trading_partner_sites mtps
	, msc_trading_partner_maps mtpm
	, msc_company_sites mcs1
	, msc_companies mc1
--========================================
-- Tables to get Item information
--========================================
	, msc_system_items mi
        , msc_items itm
--==================================
-- Tables to lookup type description
--==================================
	, fnd_lookup_values flv
where
--============================================
-- Joins for getting Allocated On hand records
--============================================
        ms.plan_id 	      = G_PLAN_ID
and 	ms.sr_instance_id     = p_sr_instance_id
and 	ms.order_type 	      = G_MRP_ONHAND
--==========================================
-- Joins to get Org equivalent company site.
--==========================================
and	ms.organization_id    = mcsil.sr_company_site_id
and	ms.sr_instance_id     = mcsil.sr_instance_id
and     mcsil.company_site_id = mcs.company_site_id
and     mcsil.partner_type    = G_ORGANIZATION
and     mcsil.sr_company_id   = G_SR_OEM_ID
and     mcs.company_id        = mc.company_id
and     mc.company_id         = G_OEM_ID
--========================================
-- Joins to get customer  site information.
--========================================
and     ms.organization_id = mtp.sr_tp_id  /* added joins to mtp sbala */
and     ms.sr_instance_id = mtp.sr_instance_id
and     mtp.partner_type = G_ORGANIZATION
and     mtp.modeled_customer_id is not null
and     mtp.modeled_customer_site_id is not null
and     mtps.partner_id = mtp.modeled_customer_id /* added sbala */
and     mtps.partner_site_id = mtp.modeled_customer_site_id
and     mtps.partner_site_id	    = mtpm.tp_key
and     mtpm.map_type 		    = G_SITE_MAP_TYPE
and     mtpm.company_key	    = mcs1.company_site_id
and     mcs1.company_id		    = mc1.company_id
--========================================
-- Joins to get Item information.
--========================================
and     ms.inventory_item_id 	= mi.inventory_item_id
and     ms.organization_id 	= mi.organization_id
and     ms.sr_instance_id 	= mi.sr_instance_id
and     ms.plan_id 		= mi.plan_id
and     itm.inventory_item_id (+)= mi.base_item_id
--=====================================
-- Joins to get Lookup Type description
--=====================================
and    flv.lookup_code = decode(ms.order_type,G_MRP_ONHAND,G_ALLOC_ONHAND)
and    flv.lookup_code = G_ALLOC_ONHAND
and    flv.lookup_type = 'MSC_X_ORDER_TYPE'
and    flv.language = p_language_code
and exists
--==========================================
-- Local View to get Net change information.
--==========================================
        (select 1
          from   msc_supplies ms1,
	         msc_trading_partners mtp2
          where  plan_id = G_PLAN_ID  /* Changes for modeled customers sbala */
          and    ms1.sr_instance_id = p_sr_instance_id
	  and 	 ms1.order_type = G_MRP_ONHAND
	  and    ms1.organization_id = mtp2.sr_tp_id
	  --==============================================
	  -- Joins for getting net change Item information
	  --==============================================
	  and    ms.plan_id	      = ms1.plan_id
	  and    ms.sr_instance_id      = ms1.sr_instance_id
	  and    ms.organization_id     = ms1.organization_id
	  and    ms.inventory_item_id   = ms1.inventory_item_id
	  ----and    ms.planning_partner_site_id = X.planning_partner_site_id sbala
	  ----and    ms.planning_tp_type    = X.planning_tp_type sbala
          and    ms1.sr_instance_id = mtp2.sr_instance_id
	  and    mtp2.partner_type = G_ORGANIZATION
	  and    mtp2.modeled_customer_id is not null
	  and    mtp2.modeled_customer_site_id is not null
	  and    nvl(ms1.refresh_number, -1) = p_refresh_number
	  )
GROUP BY
G_PLAN_ID,
G_SR_INSTANCE_ID,
G_OEM_ID,
mcs.company_site_id,
mc.company_name,
mcs.company_site_name,
ms.inventory_item_id,
'PUBLISH',
G_ALLOC_ONHAND,
mc1.company_id,
mc1.company_name,
mtpm.company_key,
mcs1.company_site_name,
G_DAILY_BKT_TYPE ,
mi.item_name,
mi.description,
flv.meaning,
flv.meaning,
'Day',
mi.uom_code,
mi.uom_code,
mtps.partner_id,
mtps.partner_site_id,
ms.sr_instance_id,
ms.organization_id,
ms.vmi_flag,
G_CUSTOMER,
mi.base_item_id,
itm.item_name
,mi.planner_code		 --Bug 4424426
;

CURSOR unallocOnhand(p_refresh_number NUMBER,
                   p_sr_instance_id NUMBER,
				   p_language_code VARCHAR2) IS
select
G_PLAN_ID 			PLAN_ID,
G_SR_INSTANCE_ID 		SR_INSTANCE_ID,
G_OEM_ID		 	PUBLISHER_ID,
mcs.company_site_id 		PUBLISHER_SITE_ID,
mc.company_name 		PUBLISHER_NAME,
mcs.company_site_name 		PUBLISHER_SITE_NAME,
ms.inventory_item_id 		INVENTORY_ITEM_ID,
SUM(nvl(ms.new_order_quantity,0)) 		QUANTITY,
'PUBLISH' 			COMMENTS,
G_UNALLOC_ONHAND			PUBLISHER_ORDER_TYPE,
G_DAILY_BKT_TYPE		BUCKET_TYPE,
mi.item_name 			PUBLISHER_ITEM_NAME,
mi.description 			PUB_ITEM_DESCRIPTIION   ,
flv.meaning 			PUBLISHER_ORDER_TYPE_DESC,
flv.meaning 			TP_ORDER_TYPE_DESC,
'Day'  				BUCKET_TYPE_DESC,
mi.uom_code 			UOM_CODE,
mi.uom_code			PRIMARY_UOM,
SUM(nvl(ms.new_order_quantity,0))  		PRIMARY_QUANTITY,
mi.base_item_id			BASE_ITEM_ID,
itm.item_name			BASE_ITEM_NAME
,mi.planner_code		PLANNER_CODE --Bug 4424426
FROM msc_company_site_id_lid mcsil,
     msc_company_sites mcs,
     msc_companies mc,
     msc_supplies ms,
     msc_system_items mi,
     msc_items itm,
     msc_trading_partners mtp,
     fnd_lookup_values flv
WHERE
ms.plan_id 	      = G_PLAN_ID
and 	ms.sr_instance_id     = p_sr_instance_id
and 	ms.order_type 	      = G_MRP_ONHAND
-- and     ms.planning_partner_site_id is null
and     (ms.planning_tp_type IS NULL OR ms.planning_tp_type = 2)
and	ms.organization_id    = mcsil.sr_company_site_id
and	ms.sr_instance_id     = mcsil.sr_instance_id
and     mcsil.company_site_id = mcs.company_site_id
and     mcsil.partner_type    = G_ORGANIZATION
and     mcsil.sr_company_id   = G_SR_OEM_ID
and     mcs.company_id        = mc.company_id
and     mc.company_id         = G_OEM_ID
and     ms.inventory_item_id 	= mi.inventory_item_id
and     ms.organization_id 	= mi.organization_id
and     ms.sr_instance_id 	= mi.sr_instance_id
and     ms.plan_id 		= mi.plan_id
and     itm.inventory_item_id  (+)= mi.base_item_id
and     ms.organization_id = mtp.sr_tp_id
and     ms.sr_instance_id = mtp.sr_instance_id
and     mtp.partner_type = 3
and     mtp.modeled_supplier_id is null
and     mtp.modeled_customer_id is null
and    flv.lookup_code = decode(ms.order_type,G_MRP_ONHAND,G_UNALLOC_ONHAND)
and    flv.lookup_code = G_UNALLOC_ONHAND
and    flv.lookup_type = 'MSC_X_ORDER_TYPE'
and    flv.language = p_language_code
and nvl(ms.refresh_number, -1) = decode(v_lrtype, 'C', nvl(p_refresh_number, -1)
                                                , 'P', nvl(p_refresh_number, -1)
                                                , 'I', p_refresh_number
						, 'T', decode (p_oh_sn_flag, G_AUTO_NET_COLL, p_refresh_number,
						    G_AUTO_TAR_COLL,  nvl(p_refresh_number, -1))
                                       )
GROUP BY
G_PLAN_ID,
G_SR_INSTANCE_ID,
G_OEM_ID,
mcs.company_site_id,
mc.company_name,
mcs.company_site_name,
ms.inventory_item_id,
'PUBLISH',
G_UNALLOC_ONHAND,
G_DAILY_BKT_TYPE ,
mi.item_name,
mi.description,
flv.meaning,
flv.meaning,
'Day',
mi.uom_code,
mi.uom_code,
mi.base_item_id,
itm.item_name
,mi.planner_code	;--Bug 4424426

CURSOR unallocOnhandNetChange(p_refresh_number NUMBER,
                              p_sr_instance_id NUMBER,
							  p_language_code VARCHAR2) IS
select
G_PLAN_ID 			PLAN_ID,
G_SR_INSTANCE_ID 		SR_INSTANCE_ID,
G_OEM_ID		 	PUBLISHER_ID,
mcs.company_site_id 		PUBLISHER_SITE_ID,
mc.company_name 		PUBLISHER_NAME,
mcs.company_site_name 		PUBLISHER_SITE_NAME,
ms.inventory_item_id 		INVENTORY_ITEM_ID,
SUM(nvl(ms.new_order_quantity,0)) 		QUANTITY,
'PUBLISH' 			COMMENTS,
G_UNALLOC_ONHAND			PUBLISHER_ORDER_TYPE,
G_DAILY_BKT_TYPE		BUCKET_TYPE,
mi.item_name 			PUBLISHER_ITEM_NAME,
mi.description 			PUB_ITEM_DESCRIPTIION   ,
flv.meaning 			PUBLISHER_ORDER_TYPE_DESC,
flv.meaning 			TP_ORDER_TYPE_DESC,
'Day'  				BUCKET_TYPE_DESC,
mi.uom_code 			UOM_CODE,
mi.uom_code			PRIMARY_UOM,
SUM(nvl(ms.new_order_quantity,0))  		PRIMARY_QUANTITY,
mi.base_item_id			BASE_ITEM_ID,
itm.item_name			BASE_ITEM_NAME
,mi.planner_code		PLANNER_CODE --Bug 4424426
FROM msc_company_site_id_lid mcsil,
     msc_company_sites mcs,
     msc_companies mc,
     msc_supplies ms,
     msc_system_items mi,
     msc_items itm,
     msc_trading_partners mtp,
     fnd_lookup_values flv
WHERE
--==============================================
-- Joins for getting net change Item information
--==============================================
     ms.plan_id 	      = G_PLAN_ID
and 	ms.sr_instance_id     = p_sr_instance_id
and 	ms.order_type 	      = G_MRP_ONHAND
and    (ms.planning_tp_type IS NULL OR ms.planning_tp_type = 2)
and	    ms.organization_id    = mcsil.sr_company_site_id
and	    ms.sr_instance_id     = mcsil.sr_instance_id
and     mcsil.company_site_id = mcs.company_site_id
and     mcsil.partner_type    = G_ORGANIZATION
and     mcsil.sr_company_id   = G_SR_OEM_ID
and     mcs.company_id        = mc.company_id
and     mc.company_id         = G_OEM_ID
and     ms.inventory_item_id 	= mi.inventory_item_id
and     ms.organization_id 	= mi.organization_id
and     ms.sr_instance_id 	= mi.sr_instance_id
and     ms.plan_id 		= mi.plan_id
and     itm.inventory_item_id (+)= mi.base_item_id
and     ms.organization_id = mtp.sr_tp_id
and     ms.sr_instance_id = mtp.sr_instance_id
and     mtp.partner_type = 3
and     mtp.modeled_supplier_id is null
and     mtp.modeled_customer_id is null
and    flv.lookup_code = decode(ms.order_type,G_MRP_ONHAND,G_UNALLOC_ONHAND)
and    flv.lookup_code = G_UNALLOC_ONHAND
and    flv.lookup_type = 'MSC_X_ORDER_TYPE'
and    flv.language = p_language_code
and exists
--==========================================
    -- Local View to get Net change information.
    -- at Item - Organizatoin level.
    --==========================================
     (select 1
      from   msc_supplies ms1
      where  plan_id = G_PLAN_ID
      and    sr_instance_id = p_sr_instance_id
      and    ms1.order_type = G_MRP_ONHAND
      and         ms.plan_id             = ms1.plan_id
      and     ms.sr_instance_id      = ms1.sr_instance_id
      and     ms.organization_id     = ms1.organization_id
      and     ms.inventory_item_id   = ms1.inventory_item_id
      and    (ms1.planning_tp_type IS NULL OR ms1.planning_tp_type = 2)
      and    nvl(ms1.refresh_number, -1) = p_refresh_number
      )
GROUP BY
G_PLAN_ID,
G_SR_INSTANCE_ID,
G_OEM_ID,
mcs.company_site_id,
mc.company_name,
mcs.company_site_name,
ms.inventory_item_id,
'PUBLISH',
G_UNALLOC_ONHAND,
G_DAILY_BKT_TYPE ,
mi.item_name,
mi.description,
flv.meaning,
flv.meaning,
'Day',
mi.uom_code,
mi.uom_code,
mi.base_item_id,
itm.item_name
,mi.planner_code;--Bug 4424426

CURSOR salesOrders(p_refresh_number NUMBER,
                   p_sr_instance_id NUMBER,
				   p_language_code VARCHAR2) IS

select
-- msc_sup_dem_entries_s.nextval 	TRANSACTION_ID,
G_PLAN_ID 			PLAN_ID,
G_SR_INSTANCE_ID        	SR_INSTANCE_ID,
G_OEM_ID		 	PUBLISHER_ID,
mcs.company_site_id 		PUBLISHER_SITE_ID,
mc.company_name 		PUBLISHER_NAME,
mcs.company_site_name 		PUBLISHER_SITE_NAME,
mso.inventory_item_id 		INVENTORY_ITEM_ID,
(nvl(mso.primary_uom_quantity,0) - nvl(mso.completed_quantity,0)) 		QUANTITY,
'PUBLISH' 			COMMENTS,
G_SALES_ORDER			PUBLISHER_ORDER_TYPE,
mc1.company_id 	        	CUSTOMER_ID,
mc1.company_name 		CUSTOMER_NAME,
mtpm.company_key 		CUSTOMER_SITE_ID,
mcs1.company_site_name		customer_site_name,
G_DAILY_BKT_TYPE		BUCKET_TYPE,
mso.sales_order_number 		ORDER_NUMBER,
null          ORDER_LINE_NUMBER,
mso.requirement_date 		ship_date,
nvl(mso.schedule_arrival_date,mso.requirement_date) 	receipt_date,
mso.promise_date        	original_promise_date,
mi.item_name 			PUBLISHER_ITEM_NAME,
mi.description 			PUB_ITEM_DESCRIPTIION   ,
flv.meaning 			PUBLISHER_ORDER_TYPE_DESC,
flv.meaning 			TP_ORDER_TYPE_DESC,
'Day'    			BUCKET_TYPE_DESC,
mi.uom_code 			UOM_CODE,
p_user_id    		        CREATED_BY,
mso.creation_date		CREATION_DATE,
mso.LAST_UPDATED_BY		LAST_UPDATED_BY,
mso.LAST_UPDATE_DATE	 	LAST_UPDATE_DATE,
decode(mso.order_date_type_code, G_SHIP,    mso.requirement_date,
                                 G_ARRIVAL, mso.schedule_arrival_date,
                                 mso.requirement_date) key_date,
decode(mso.order_date_type_code, G_SHIP,G_SHIP_CONTROL,
                                 G_ARRIVAL,G_ARRIVE_CONTROL,
				 G_SHIP_CONTROL)  shipping_control,
mi.uom_code  			PRIMARY_UOM,
(nvl(mso.primary_uom_quantity,0) - nvl(mso.completed_quantity,0))	PRIMARY_QUANTITY,
mso.customer_id			PARTNER_ID,
mso.ship_to_site_use_id		PARTNER_SITE_ID,
mso.sr_instance_id		ORIG_SR_INSTANCE_ID,
mso.organization_id		ORGANIZATION_ID,
mi.base_item_id			BASE_ITEM_ID,
itm.item_name			BASE_ITEM_NAME,
to_char(NULL)		END_ORDER_NUMBER,
to_char(NULL)		END_ORDER_RELEASE_NUMBER,
to_char(NULL)		END_ORDER_LINE_NUMBER,
to_number(NULL) 	END_ORDER_PUBLISHER_ID,
to_char(NULL) END_ORDER_PUBLISHER_NAME,
to_number(NULL) END_ORDER_PUBLISHER_SITE_ID,
to_char(NULL) END_ORDER_PUBLISHER_SITE_NAME,
to_char(NULL)	END_ORDER_TYPE,
to_number(NULL)		INTERNAL_FLAG,
G_OEM_ID	supplier_id,
mcs.company_site_id supplier_site_id,
mc.company_name supplier_name,
mcs.company_site_name supplier_site_name
,mi.planner_code		PLANNER_CODE	 --Bug 4424426
from 	msc_sales_orders mso
--========================================
-- Tables to get Publisher's organization_id
--========================================
	, msc_company_site_id_lid mcsil
	, msc_company_sites mcs
	, msc_companies mc
	, msc_trading_partners mtp
--========================================
-- Tables to get Customer and Customer Site information
--========================================
	, msc_trading_partner_sites mtps
    , msc_trading_partner_maps mtpm
    , msc_company_sites mcs1
    , msc_companies mc1
--========================================
-- Tables to get Item information
--========================================
	, msc_system_items mi
	, msc_items itm
--==================================
-- Tables to lookup type description
--==================================
	, fnd_lookup_values flv
where
--============================================
-- Joins for Sales Order records
--============================================
 	mso.sr_instance_id     = p_sr_instance_id
--==========================================
-- Joins to get Org equivalent company site.
--==========================================
and	mso.organization_id    = mcsil.sr_company_site_id
and	mso.sr_instance_id     = mcsil.sr_instance_id
and     mcsil.company_site_id = mcs.company_site_id
and mcsil.sr_company_id    = G_SR_OEM_ID
and mcsil.partner_type     = G_ORGANIZATION
and     mcs.company_id        = mc.company_id
and     mc.company_id         = G_OEM_ID
and     mso.organization_id = mtp.sr_tp_id
and     mso.sr_instance_id = mtp.sr_instance_id
and     mtp.partner_type = 3
and     mtp.modeled_supplier_id is NULL
--=====================================================
-- Joins to get Customer and Customer site information.
--=====================================================
and     mso.ship_to_site_use_id = mtps.partner_site_id
and     mso.customer_id         = mtps.partner_id
and     mtps.partner_site_id	= mtpm.tp_key
and     mtpm.map_type 		= G_SITE_MAP_TYPE
and     mtpm.company_key        = mcs1.company_site_id
and     mcs1.company_id         = mc1.company_id
--========================================
-- Joins to get Item information.
--========================================
and     mso.inventory_item_id 	= mi.inventory_item_id
and     mso.organization_id 	= mi.organization_id
and     mso.sr_instance_id 	    = mi.sr_instance_id
and     mi.plan_id = G_PLAN_ID
and     itm.inventory_item_id (+)= mi.base_item_id
--=====================================
-- Joins to get Lookup Type description
--=====================================
and    flv.lookup_code = decode(mso.demand_source_type,8,0,14)
and    flv.lookup_code = 14
and    flv.lookup_type = 'MSC_X_ORDER_TYPE'
and    flv.language = p_language_code
--================================================
-- Net Change / Targetted / Complete refresh check
--================================================
and nvl(mso.refresh_number, -1) = decode(v_lrtype, 'C', nvl(p_refresh_number, -1)
                                               , 'P', nvl(p_refresh_number, -1)
                                               , 'I', p_refresh_number
					       , 'T', decode (p_po_sn_flag, G_AUTO_NET_COLL, p_refresh_number,
							      G_AUTO_TAR_COLL,  nvl(p_refresh_number, -1))
                                        )
--=========================================================
-- Consider only open Sales Order Lines,
-- From Release 11i if completed quantity is populated then
-- it's considered as closed Sales Order line.
-- We will not bring over these records
--====================-=====================================
--Bug 4535374, added the code for handling R12
and decode(v_apps_ver ,3, decode(v_lrtype,'I',0,mso.completed_quantity),4, decode(v_lrtype,'I',0,mso.completed_quantity), 0) = 0
--============================================
-- Consider lines on Sales Order only. We need
-- not to bring Reservation Lines.
--============================================
and nvl(mso.reservation_type, -99) = 1
and mso.demand_source_type <> 8 /* Ignore Internal Sales orders */
UNION /* sales order in supplier modeled orgs (multi company plng) */
select
-- msc_sup_dem_entries_s.nextval 	TRANSACTION_ID,
G_PLAN_ID 			PLAN_ID,
G_SR_INSTANCE_ID        	SR_INSTANCE_ID,
G_OEM_ID	        	PUBLISHER_ID,
mcs_org.company_site_id 	PUBLISHER_SITE_ID,
mc_org.company_name 	PUBLISHER_NAME,
mcs_org.company_site_name 	PUBLISHER_SITE_NAME,
mso.inventory_item_id 		INVENTORY_ITEM_ID,
(nvl(mso.primary_uom_quantity,0) - nvl(mso.completed_quantity,0)) 		QUANTITY,
'PUBLISH' 			COMMENTS,
G_SALES_ORDER			PUBLISHER_ORDER_TYPE,
G_OEM_ID 	        	CUSTOMER_ID,
mc.company_name 		CUSTOMER_NAME,
mcs.company_site_id 		CUSTOMER_SITE_ID,
mcs.company_site_name		customer_site_name,
G_DAILY_BKT_TYPE		BUCKET_TYPE,
mso.sales_order_number 		ORDER_NUMBER,
null		                ORDER_LINE_NUMBER,
mso.requirement_date 		ship_date,
mso.schedule_arrival_date 	receipt_date,
mso.promise_date        	original_promise_date,
mi.item_name 			PUBLISHER_ITEM_NAME,
mi.description 			PUB_ITEM_DESCRIPTIION   ,
flv.meaning 			PUBLISHER_ORDER_TYPE_DESC,
flv.meaning 			TP_ORDER_TYPE_DESC,
'Day'    			BUCKET_TYPE_DESC,
mi.uom_code 			UOM_CODE,
p_user_id    		        CREATED_BY,
mso.creation_date		CREATION_DATE,
mso.LAST_UPDATED_BY		LAST_UPDATED_BY,
mso.LAST_UPDATE_DATE	 	LAST_UPDATE_DATE,
decode(mso.order_date_type_code, G_SHIP,    mso.requirement_date,
                                 G_ARRIVAL, mso.schedule_arrival_date,
                                 mso.requirement_date) key_date,
decode(mso.order_date_type_code, G_SHIP,G_SHIP_CONTROL,
                                 G_ARRIVAL,G_ARRIVE_CONTROL,
				 G_SHIP_CONTROL)  shipping_control,
mi.uom_code  			PRIMARY_UOM,
(nvl(mso.primary_uom_quantity,0) - nvl(mso.completed_quantity,0))	PRIMARY_QUANTITY,
-1			PARTNER_ID,
-1	PARTNER_SITE_ID,
mso.sr_instance_id		ORIG_SR_INSTANCE_ID,
mso.organization_id		ORGANIZATION_ID,
mi.base_item_id			BASE_ITEM_ID,
itm.item_name			BASE_ITEM_NAME,
decode(instr(ms.order_number,'('),
       0, ms.order_number,
       substr(ms.order_number, 1, instr(ms.order_number,'(') - 1))
       		END_ORDER_NUMBER,
decode(instr(order_number,'('),
        0, to_char(null),
        substr(order_number, instr(order_number,'(')))
			END_ORDER_RELEASE_NUMBER,
to_char(ms.purch_line_num)		END_ORDER_LINE_NUMBER,
G_OEM_ID   END_ORDER_PUBLISHER_ID,
mc.company_name  END_ORDER_PUBLISHER_NAME,
mcs.company_site_id END_ORDER_PUBLISHER_SITE_ID,
mcs.company_site_name END_ORDER_PUBLISHER_SITE_NAME,
to_char(G_PO) END_ORDER_TYPE,
to_number(NULL)		INTERNAL_FLAG,
mcs_modeled.company_id supplier_id,
mcs_modeled.company_site_id supplier_site_id,
mc_modeled.company_name supplier_name,
mcs_modeled.company_site_name supplier_site_name
,mi.planner_code		PLANNER_CODE --Bug 4424426
from 	msc_sales_orders mso
       , msc_trading_partners mtp
       , msc_trading_partner_maps mtpm
       , msc_supplies ms
       , msc_trading_partners mtp2
       , msc_trading_partner_maps map2
       , msc_trading_partner_maps mtpm_org
       , msc_company_sites mcs_org
       , msc_companies mc_org
       , msc_company_sites mcs_modeled
       , msc_companies mc_modeled
       , msc_company_sites mcs
       , msc_companies mc
       , msc_system_items mi
       , msc_items itm
       , fnd_lookup_values flv
where
--============================================
-- Joins for Sales Order records
--============================================
 	mso.sr_instance_id     = p_sr_instance_id
--==========================================
--------------------------------------------------
----- Joins to get supplier info for modeled orgs
------------------------------------------------
and   mso.organization_id = mtp.sr_tp_id
and   mso.sr_instance_id = mtp.sr_instance_id
and   mtp.partner_type = 3
and   mtp.modeled_supplier_site_id = mtpm.tp_key
and   mtpm.map_type = 3
and   mtpm.company_key = mcs_modeled.company_site_id
and   mtpm_org.tp_key = mtp.partner_id
and   mtpm_org.map_type = 2
and   mtpm_org.company_key = mcs_org.company_site_id
and   mc_org.company_id = mcs_org.company_id
and   mcs_modeled.company_id = mc_modeled.company_id
and   mso.supply_id = ms.transaction_id
and   mso.sr_instance_id = ms.sr_instance_id
and   ms.organization_id =  mtp2.sr_tp_id
and   ms.sr_instance_id = mtp2.sr_instance_id
and   mso.inventory_item_id = ms.inventory_item_id
and   mtp2.partner_type = 3
and   mtp2.partner_id = map2.tp_key
and   ms.plan_id = -1
and   map2.map_type = 2
and   map2.company_key = mcs.company_site_id
and   mcs.company_id = mc.company_id
--========================================
-- Joins to get Item information.
--========================================
and     mso.inventory_item_id 	= mi.inventory_item_id
and     mso.organization_id 	= mi.organization_id
and     mso.sr_instance_id 	    = mi.sr_instance_id
and     mi.plan_id = G_PLAN_ID
and     itm.inventory_item_id (+)= mi.base_item_id
--=====================================
-- Joins to get Lookup Type description
--=====================================
and    flv.lookup_code = decode(mso.demand_source_type,8,0,14)
and    flv.lookup_code = 14
and    flv.lookup_type = 'MSC_X_ORDER_TYPE'
and    flv.language = p_language_code
--================================================
-- Net Change / Targetted / Complete refresh check
--================================================
and nvl(mso.refresh_number, -1) = decode(v_lrtype, 'C', nvl(p_refresh_number, -1)
                                               , 'P', nvl(p_refresh_number, -1)
                                               , 'I', p_refresh_number
					       , 'T', decode (p_po_sn_flag, G_AUTO_NET_COLL, p_refresh_number,
							      G_AUTO_TAR_COLL,  nvl(p_refresh_number, -1))
                                        )
--=========================================================
-- Consider only open Sales Order Lines,
-- From Release 11i if completed quantity is populated then
-- it's considered as closed Sales Order line.
-- We will not bring over these records
--====================-=====================================
--Bug 4535374, added the code for handling R12
and decode(v_apps_ver ,3,decode(v_lrtype,'I',0,mso.completed_quantity),4,decode(v_lrtype,'I',0,mso.completed_quantity), 0) = 0
--============================================
-- Consider lines on Sales Order only. We need
-- not to bring Reservation Lines.
--============================================
and nvl(mso.reservation_type, -99) = 1
and mso.demand_source_type <> 8 /* Ignore Internal Sales orders */
UNION ---Internal sales orders for customer facing VMI
select
G_PLAN_ID 			PLAN_ID,
G_SR_INSTANCE_ID        	SR_INSTANCE_ID,
G_OEM_ID		 	PUBLISHER_ID,
mcs.company_site_id 		PUBLISHER_SITE_ID,
mc.company_name 		PUBLISHER_NAME,
mcs.company_site_name 		PUBLISHER_SITE_NAME,
mso.inventory_item_id 		INVENTORY_ITEM_ID,
(nvl(mso.primary_uom_quantity,0) - nvl(mso.completed_quantity,0)) 		QUANTITY,
'PUBLISH' 			COMMENTS,
G_SALES_ORDER			PUBLISHER_ORDER_TYPE,
mc2.company_id 	        	CUSTOMER_ID,
mc2.company_name 		CUSTOMER_NAME,
mcs2.company_site_id	CUSTOMER_SITE_ID,
mcs2.company_site_name		customer_site_name,
G_DAILY_BKT_TYPE		BUCKET_TYPE,
mso.sales_order_number 		ORDER_NUMBER,
null		                ORDER_LINE_NUMBER,
mso.requirement_date 		ship_date,
nvl(mso.schedule_arrival_date,mso.requirement_date) 	receipt_date,
mso.promise_date        	original_promise_date,
mi.item_name 			PUBLISHER_ITEM_NAME,
mi.description 			PUB_ITEM_DESCRIPTIION   ,
flv.meaning 			PUBLISHER_ORDER_TYPE_DESC,
flv.meaning 			TP_ORDER_TYPE_DESC,
'Day'    			BUCKET_TYPE_DESC,
mi.uom_code 			UOM_CODE,
p_user_id    		        CREATED_BY,
mso.creation_date		CREATION_DATE,
mso.LAST_UPDATED_BY		LAST_UPDATED_BY,
mso.LAST_UPDATE_DATE	 	LAST_UPDATE_DATE,
decode(mso.order_date_type_code, G_SHIP,    mso.requirement_date,
                                 G_ARRIVAL, mso.schedule_arrival_date,
                                 mso.requirement_date) key_date,
decode(mso.order_date_type_code, G_SHIP,G_SHIP_CONTROL,
                                 G_ARRIVAL,G_ARRIVE_CONTROL,
				 G_SHIP_CONTROL)  shipping_control,
mi.uom_code  			PRIMARY_UOM,
(nvl(mso.primary_uom_quantity,0)
	- nvl(mso.completed_quantity,0))	PRIMARY_QUANTITY,
mtp.modeled_customer_id		PARTNER_ID,
mtp.modeled_customer_site_id	PARTNER_SITE_ID,
mso.sr_instance_id		ORIG_SR_INSTANCE_ID,
mso.organization_id		ORGANIZATION_ID,
to_number(null)                            BASE_ITEM_ID,
to_char(null)                            BASE_ITEM_NAME,
decode(instr(ms.order_number,'('),
                                   0, ms.order_number,
                           substr(ms.order_number, 1, instr(ms.order_number,'(')
 - 1)) END_ORDER_NUMBER,
decode(instr(order_number,'('),
                           0, to_char(null),
                           substr(order_number, instr(order_number,'(')))
       END_ORDER_RELEASE_NUMBER,
to_char(ms.purch_line_num) END_ORDER_LINE_NUMBER,
mc2.company_id END_ORDER_PUBLISHER_ID,
mc2.company_name END_ORDER_PUBLISHER_NAME,
mcs2.company_site_id END_ORDER_PUBLISHER_SITE_ID,
mcs2.company_site_name END_ORDER_PUBLISHER_SITE_NAME,
to_char(G_REQ) END_ORDER_TYPE,
SYS_YES INTERNAL_FLAG,
G_OEM_ID               SUPPLIER_ID,
mcs.company_site_id    SUPPLIER_SITE_ID,
mc.company_name        SUPPLIER_NAME,
mcs.company_site_name  SUPPLIER_SITE_NAME
,mi.planner_code		PLANNER_CODE --Bug 4424426
from 	msc_sales_orders mso,
	msc_trading_partners mtp,
	msc_trading_partner_maps map,
	msc_company_sites mcs,
	msc_companies mc,
	msc_supplies ms,
	msc_trading_partners mtp2,
        msc_trading_partner_maps map2,
        msc_company_sites mcs2,
        msc_companies mc2,
        msc_system_items mi,
        fnd_lookup_values flv
where   mso.sr_instance_id     = p_sr_instance_id
and     mso.demand_source_type = 8 --- Internal Sales order
and	mso.organization_id    = mtp.sr_tp_id
and	mso.sr_instance_id     = mtp.sr_instance_id
and 	mtp.partner_type = 3
and     mtp.partner_id = map.tp_key
and     map.map_type = 2
and     map.company_key = mcs.company_site_id
and     mc.company_id = mcs.company_id
and     ms.transaction_id = mso.supply_id
and     ms.organization_id = mtp2.sr_tp_id
and     ms.sr_instance_id = mtp2.sr_instance_id
and     ms.order_type = 2
and     ms.source_organization_id is not null
and     mtp2.partner_type = 3
and     mtp2.modeled_customer_id is not null
and     mtp2.modeled_customer_site_id is not null
and     mtp2.modeled_customer_site_id = map2.tp_key
and     map2.map_type = 3
and     map2.company_key = mcs2.company_site_id
and     mc2.company_id = mcs2.company_id
and     ms.inventory_item_id 	= mi.inventory_item_id
and     ms.organization_id 	= mi.organization_id
and     ms.sr_instance_id      = mi.sr_instance_id
and     ms.plan_id = mi.plan_id
and     mi.plan_id = G_PLAN_ID
and     mi.inventory_planning_code = 7 -- vmi
and    flv.lookup_code = decode(mso.demand_source_type,8,14)
and    flv.lookup_code = 14
and    flv.lookup_type = 'MSC_X_ORDER_TYPE'
and    flv.language = p_language_code
and nvl(mso.refresh_number, -1) = decode(v_lrtype,
			'C', nvl(p_refresh_number, -1)
                       , 'P', nvl(p_refresh_number, -1)
                       , 'I', p_refresh_number
 , 'T', decode (p_po_sn_flag, G_AUTO_NET_COLL, p_refresh_number,
     G_AUTO_TAR_COLL,  nvl(p_refresh_number, -1))
        )
	--Bug 4535374, added the code for handling R12
and decode(v_apps_ver ,3,decode(v_lrtype,'I',0,mso.completed_quantity),4,decode(v_lrtype,'I',0,mso.completed_quantity), 0) = 0
and nvl(mso.reservation_type, -99) = 1
;

cursor org IS
    select mtpm.company_key org_id
    from   msc_trading_partners     mtp,
	   msc_trading_partner_maps mtpm,
	   msc_instance_orgs        mio,
	   msc_coll_parameters      mcp
    where  mtp.sr_instance_id = p_sr_instance_id
    and    mtp.partner_type = 3
    and    mtp.partner_id = mtpm.tp_key
    and    mtpm.map_type = 2
    and    mio.sr_instance_id = mtp.sr_instance_id
    and    mio.ORGANIZATION_ID = mtp.sr_tp_id
    and    mcp.instance_id = mio.sr_instance_id
    and    nvl(mcp.ORG_GROUP,'-999') = DECODE(nvl(mcp.org_group,'-999'), '-999', nvl(mcp.org_group,'-999')
									 , mio.org_group);

    t_sr_instance_id	   number_arr;
    t_plan_id		   number_arr ;
    t_internal_flag 	   number_arr;
    t_end_ord_pub_name	   msc_sce_loads_pkg.publisherList;
    t_ins_end_ord_pub_name     msc_sce_loads_pkg.publisherList := msc_sce_loads_pkg.publisherList();
    t_end_ord_pub_id 	   msc_sce_loads_pkg.publishidList := msc_sce_loads_pkg.publishidList();
    t_ins_end_ord_pub_id   msc_sce_loads_pkg.publishidList := msc_sce_loads_pkg.publishidList();
    t_end_ord_pub_site_name msc_sce_loads_pkg.pubsiteList;
    t_ins_end_ord_pub_site_name msc_sce_loads_pkg.pubsiteList := msc_sce_loads_pkg.pubsiteList();
    t_end_ord_pub_site_id  msc_sce_loads_pkg.pubsiteidList;
    t_ins_end_ord_pub_site_id  msc_sce_loads_pkg.pubsiteidList :=
				msc_sce_loads_pkg.pubsiteidList();
    t_end_pub_ord_type 	   msc_sce_loads_pkg.ordertypeList;
    t_ins_end_pub_ord_type         msc_sce_loads_pkg.ordertypeList := msc_sce_loads_pkg.ordertypeList();
    t_ins_end_ord_type_desc        msc_sce_loads_pkg.otdescList := msc_sce_loads_pkg.otdescList();
    t_end_order_number	   msc_sce_loads_pkg.ordernumList := msc_sce_loads_pkg.ordernumList();
    t_ins_end_ord_num      msc_sce_loads_pkg.ordernumList := msc_sce_loads_pkg.ordernumList();
    t_delivery_id            msc_sce_loads_pkg.linenumList := msc_sce_loads_pkg.linenumList();
    t_end_order_line_number msc_sce_loads_pkg.linenumList := msc_sce_loads_pkg.linenumList();
    t_ins_end_ord_line_num msc_sce_loads_pkg.linenumList := msc_sce_loads_pkg.linenumList();
    t_end_order_rel_number msc_sce_loads_pkg.ordernumList := msc_sce_loads_pkg.ordernumList();
    t_ins_end_ord_rel_num msc_sce_loads_pkg.ordernumList := msc_sce_loads_pkg.ordernumList();
    t_pub                  msc_sce_loads_pkg.publisherList := msc_sce_loads_pkg.publisherList();
    t_pub_id               msc_sce_loads_pkg.publishidList := msc_sce_loads_pkg.publishidList();
      /* PS: added code to initialize the variables  */
    t_pub_site             msc_sce_loads_pkg.pubsiteList := msc_sce_loads_pkg.pubsiteList();
    t_pub_site_id          msc_sce_loads_pkg.pubsiteidList := msc_sce_loads_pkg.pubsiteidList();
    t_supp                 msc_sce_loads_pkg.supplierList := msc_sce_loads_pkg.supplierList();
    t_supp_id              msc_sce_loads_pkg.suppidList := msc_sce_loads_pkg.suppidList();
    t_supp_site            msc_sce_loads_pkg.suppsiteList := msc_sce_loads_pkg.suppsiteList();
    t_supp_site_id         msc_sce_loads_pkg.suppsiteidList := msc_sce_loads_pkg.suppsiteidList();
    t_customer_id	   number_arr;
    t_customer_name	   msc_sce_loads_pkg.supplierList;
    t_customer_site_id	   number_arr;
    t_customer_site_name   msc_sce_loads_pkg.suppsiteList;
    t_shipfrom             msc_sce_loads_pkg.shipfromList := msc_sce_loads_pkg.shipfromList();
    t_shipfrom_id          msc_sce_loads_pkg.shipfromidList := msc_sce_loads_pkg.shipfromidList();
    t_shipfrom_site        msc_sce_loads_pkg.shipfromsiteList := msc_sce_loads_pkg.shipfromsiteList();
    t_shipfrom_site_id     msc_sce_loads_pkg.shipfromsidList := msc_sce_loads_pkg.shipfromsidList();
    t_shipfrom_addr        msc_sce_loads_pkg.shipfromaddrList := msc_sce_loads_pkg.shipfromaddrList();
    t_shipto               msc_sce_loads_pkg.shiptoList := msc_sce_loads_pkg.shiptoList();
    t_shipto_id            msc_sce_loads_pkg.shiptoidList := msc_sce_loads_pkg.shiptoidList();
    t_shipto_site          msc_sce_loads_pkg.shiptositeList := msc_sce_loads_pkg.shiptositeList();
    t_shipto_site_id       msc_sce_loads_pkg.shiptosidList := msc_sce_loads_pkg.shiptosidList();
    t_order_type           msc_sce_loads_pkg.ordertypeList;
    t_pub_order_type       msc_sce_loads_pkg.ordertypeList;
    t_ot_desc              msc_sce_loads_pkg.otdescList;
    t_tp_ot_desc           msc_sce_loads_pkg.otdescList;
    t_bkt_type_desc        msc_sce_loads_pkg.bktypedescList;
    t_bkt_type             msc_sce_loads_pkg.bktypeList;
    t_item_name            msc_sce_loads_pkg.itemList := msc_sce_loads_pkg.itemList();
    t_item_id              msc_sce_loads_pkg.itemidList := msc_sce_loads_pkg.itemidList();
    t_base_item_id 	   msc_sce_loads_pkg.itemidList;
    t_base_item_name	   msc_sce_loads_pkg.itemList;
    t_item_desc            msc_sce_loads_pkg.itemdescList := msc_sce_loads_pkg.itemdescList();
    t_pri_uom              msc_sce_loads_pkg.uomList;
    t_category             msc_sce_loads_pkg.categoryList;
    t_ord_num              msc_sce_loads_pkg.ordernumList := msc_sce_loads_pkg.ordernumList();
    t_line_num             msc_sce_loads_pkg.linenumList := msc_sce_loads_pkg.linenumList();
    t_new_sched_date       msc_sce_loads_pkg.newschedList;
    t_new_dock_date        msc_sce_loads_pkg.newschedList;
    t_ship_date            msc_sce_loads_pkg.shipdateList := msc_sce_loads_pkg.shipdateList();
    t_receipt_date         msc_sce_loads_pkg.receiptdateList := msc_sce_loads_pkg.receiptdateList();
    t_new_ord_plac_date    msc_sce_loads_pkg.newordplaceList;
    t_orig_prom_date       msc_sce_loads_pkg.origpromList;
    t_req_date             msc_sce_loads_pkg.reqdateList;
    t_uom                  msc_sce_loads_pkg.uomList := msc_sce_loads_pkg.uomList();
    t_quantity             msc_sce_loads_pkg.qtyList := msc_sce_loads_pkg.qtyList();
    t_comments             msc_sce_loads_pkg.commentList;
    t_created_by	   number_arr;
    t_creation_date	   msc_sce_loads_pkg.shipdateList;
    t_last_updated_by	   number_arr;
    t_last_update_date     msc_sce_loads_pkg.shipdateList;
    t_transaction_id	   number_arr := number_arr();
    t_key_date		   msc_sce_loads_pkg.newschedList := msc_sce_loads_pkg.newschedList();
    t_promise_date	   msc_sce_loads_pkg.newschedList;
    t_primary_quantity	   number_arr;
    t_owner_item_name	   msc_sce_loads_pkg.itemList := msc_sce_loads_pkg.itemList();
    t_customer_item_name   msc_sce_loads_pkg.itemList := msc_sce_loads_pkg.itemList();
    t_supplier_item_name   msc_sce_loads_pkg.itemList := msc_sce_loads_pkg.itemList();
    t_owner_item_desc	   msc_sce_loads_pkg.itemdescList := msc_sce_loads_pkg.itemdescList();
    t_cust_item_desc       msc_sce_loads_pkg.itemdescList := msc_sce_loads_pkg.itemdescList();
    t_sup_item_desc	   msc_sce_loads_pkg.itemdescList := msc_sce_loads_pkg.itemdescList();

    t_partner_id	   number_arr := number_arr();
    t_partner_site_id	   number_arr := number_arr();
    t_orig_sr_instance_id  number_arr := number_arr();
    t_organization_id	   number_arr := number_arr();
    t_alloc_type 	   number_arr := number_arr();
    t_tp_uom               msc_sce_loads_pkg.uomList := msc_sce_loads_pkg.uomList();
    t_release_number	   msc_sce_loads_pkg.ordernumList;
    t_tp_quantity	   number_arr := number_arr();
    t_vmi_flag	         number_arr := number_arr();
	t_acceptance_required_flag acceptance_flags := acceptance_flags();
	t_need_by_date	msc_sce_loads_pkg.receiptdateList := msc_sce_loads_pkg.receiptdateList();
	t_promised_date	msc_sce_loads_pkg.receiptdateList :=  msc_sce_loads_pkg.receiptdateList();
    t_shipping_control     shippingControlList := shippingControlList();

    t_planner_code	   msc_sce_loads_pkg.plannerCode := msc_sce_loads_pkg.plannerCode(); --Bug 4424426

/* Variable for inserting records */
    t_ins_sr_instance_id       number_arr := number_arr();
    t_ins_plan_id	       number_arr := number_arr();
    t_ins_pub                  msc_sce_loads_pkg.publisherList := msc_sce_loads_pkg.publisherList();
    t_ins_pub_id               msc_sce_loads_pkg.publishidList := msc_sce_loads_pkg.publishidList();
    t_ins_pub_site             msc_sce_loads_pkg.pubsiteList := msc_sce_loads_pkg.pubsiteList();
    t_ins_pub_site_id          msc_sce_loads_pkg.pubsiteidList := msc_sce_loads_pkg.pubsiteidList();
    t_ins_supp                 msc_sce_loads_pkg.supplierList := msc_sce_loads_pkg.supplierList();
    t_ins_supp_id              msc_sce_loads_pkg.suppidList := msc_sce_loads_pkg.suppidList();
    t_ins_supp_site            msc_sce_loads_pkg.suppsiteList := msc_sce_loads_pkg.suppsiteList();
    t_ins_supp_site_id         msc_sce_loads_pkg.suppsiteidList := msc_sce_loads_pkg.suppsiteidList();
    t_ins_customer_id 	       number_arr := number_arr();
    t_ins_customer_name	       msc_sce_loads_pkg.supplierList := msc_sce_loads_pkg.supplierList();
    t_ins_customer_site_id     number_arr := number_arr();
    t_ins_customer_site_name   msc_sce_loads_pkg.supplierList := msc_sce_loads_pkg.supplierList();
    t_ins_shipfrom             msc_sce_loads_pkg.shipfromList := msc_sce_loads_pkg.shipfromList();
    t_ins_shipfrom_id          msc_sce_loads_pkg.shipfromidList := msc_sce_loads_pkg.shipfromidList();
    t_ins_shipfrom_site        msc_sce_loads_pkg.shipfromsiteList := msc_sce_loads_pkg.shipfromsiteList();
    t_ins_shipfrom_site_id     msc_sce_loads_pkg.shipfromsidList := msc_sce_loads_pkg.shipfromsidList();
    t_ins_shipfrom_addr        msc_sce_loads_pkg.shipfromaddrList := msc_sce_loads_pkg.shipfromaddrList();
    t_ins_shipto               msc_sce_loads_pkg.shiptoList := msc_sce_loads_pkg.shiptoList();
    t_ins_shipto_id            msc_sce_loads_pkg.shiptoidList := msc_sce_loads_pkg.shiptoidList();
    t_ins_shipto_site          msc_sce_loads_pkg.shiptositeList := msc_sce_loads_pkg.shiptositeList();
    t_ins_shipto_site_id       msc_sce_loads_pkg.shiptosidList := msc_sce_loads_pkg.shiptosidList();
    t_ins_order_type           msc_sce_loads_pkg.ordertypeList := msc_sce_loads_pkg.ordertypeList();
    t_ins_ot_desc              msc_sce_loads_pkg.otdescList := msc_sce_loads_pkg.otdescList();
    t_ins_bkt_type_desc        msc_sce_loads_pkg.bktypedescList := msc_sce_loads_pkg.bktypedescList();
    t_ins_bkt_type             msc_sce_loads_pkg.bktypeList := msc_sce_loads_pkg.bktypeList();
    t_ins_item_name            msc_sce_loads_pkg.itemList := msc_sce_loads_pkg.itemList();
    t_ins_base_item_name       msc_sce_loads_pkg.itemList := msc_sce_loads_pkg.itemList();
    t_ins_item_id              msc_sce_loads_pkg.itemidList := msc_sce_loads_pkg.itemidList();
    t_ins_base_item_id	      msc_sce_loads_pkg.itemidList := msc_sce_loads_pkg.itemidList();
    t_ins_item_desc            msc_sce_loads_pkg.itemdescList := msc_sce_loads_pkg.itemdescList();
    t_ins_pri_uom              msc_sce_loads_pkg.uomList := msc_sce_loads_pkg.uomList();
    t_ins_category             msc_sce_loads_pkg.categoryList := msc_sce_loads_pkg.categoryList();
    t_ins_ord_num              msc_sce_loads_pkg.ordernumList := msc_sce_loads_pkg.ordernumList();
    t_ins_line_num             msc_sce_loads_pkg.linenumList := msc_sce_loads_pkg.linenumList();
    t_ins_new_sched_date       msc_sce_loads_pkg.newschedList := msc_sce_loads_pkg.newschedList();
    t_ins_ship_date            msc_sce_loads_pkg.shipdateList := msc_sce_loads_pkg.shipdateList();
    t_ins_receipt_date         msc_sce_loads_pkg.receiptdateList := msc_sce_loads_pkg.receiptdateList();
    t_ins_new_ord_plac_date    msc_sce_loads_pkg.newordplaceList := msc_sce_loads_pkg.newordplaceList();
    t_ins_orig_prom_date       msc_sce_loads_pkg.origpromList := msc_sce_loads_pkg.origpromList();
    t_ins_req_date             msc_sce_loads_pkg.reqdateList := msc_sce_loads_pkg.reqdateList();
    t_ins_uom                  msc_sce_loads_pkg.uomList := msc_sce_loads_pkg.uomList();
    t_ins_quantity             msc_sce_loads_pkg.qtyList := msc_sce_loads_pkg.qtyList();
    t_ins_comments             msc_sce_loads_pkg.commentList := msc_sce_loads_pkg.commentList();
    t_ins_created_by	       number_arr := number_arr();
    t_ins_creation_date	       msc_sce_loads_pkg.shipdateList := msc_sce_loads_pkg.shipdateList();
    t_ins_last_updated_by      number_arr := number_arr();
    t_ins_last_update_date     msc_sce_loads_pkg.shipdateList := msc_sce_loads_pkg.shipdateList();
    t_ins_transaction_id       number_arr := number_arr();
    t_ins_key_date	       msc_sce_loads_pkg.newschedList := msc_sce_loads_pkg.newschedList();
    t_ins_pub_order_type       msc_sce_loads_pkg.ordertypeList := msc_sce_loads_pkg.ordertypeList();
    t_ins_new_dock_date        msc_sce_loads_pkg.newschedList := msc_sce_loads_pkg.newschedList();
    t_ins_tp_ot_desc           msc_sce_loads_pkg.otdescList := msc_sce_loads_pkg.otdescList();
    t_ins_primary_quantity     number_arr := number_arr();
    t_ins_promise_date	       msc_sce_loads_pkg.newschedList := msc_sce_loads_pkg.newschedList();
    t_ins_owner_item_name      msc_sce_loads_pkg.itemList := msc_sce_loads_pkg.itemList();
    t_ins_customer_item_name   msc_sce_loads_pkg.itemList := msc_sce_loads_pkg.itemList();
    t_ins_supplier_item_name   msc_sce_loads_pkg.itemList := msc_sce_loads_pkg.itemList();
    t_ins_owner_item_desc      msc_sce_loads_pkg.itemdescList := msc_sce_loads_pkg.itemdescList();
    t_ins_cust_item_desc       msc_sce_loads_pkg.itemdescList := msc_sce_loads_pkg.itemdescList();
    t_ins_sup_item_desc	       msc_sce_loads_pkg.itemdescList := msc_sce_loads_pkg.itemdescList();
    t_ins_tp_uom	       msc_sce_loads_pkg.uomList := msc_sce_loads_pkg.uomList();
    t_ins_tp_quantity	       number_arr := number_arr();
	t_ins_release_number       msc_sce_loads_pkg.ordernumList := msc_sce_loads_pkg.ordernumList();
    t_ins_alloc_type 	       number_arr := number_arr();
    t_ins_vmi_flag	       number_arr := number_arr();
	t_ins_acceptance_required_flag acceptance_flags := acceptance_flags();
	t_ins_need_by_date	 msc_sce_loads_pkg.receiptdateList :=  msc_sce_loads_pkg.receiptdateList();
	t_ins_promised_date	 msc_sce_loads_pkg.receiptdateList :=  msc_sce_loads_pkg.receiptdateList();
    t_ins_delivery_id          msc_sce_loads_pkg.linenumList := msc_sce_loads_pkg.linenumList();
    t_ins_internal_flag	       number_arr := number_arr();
    t_ins_shipping_control     shippingControlList := shippingControlList();
    t_ins_shipping_control_code     number_arr := number_arr();
    t_ins_planner_code          msc_sce_loads_pkg.plannerCode := msc_sce_loads_pkg.plannerCode();  --Bug 4424426

    a_supplier_update		   number_arr := number_arr();
    a_customer_update          number_arr := number_arr();
    a_resultant_update         number_arr := number_arr();

    l_owner_item_name		MSC_SUP_DEM_ENTRIES.OWNER_ITEM_NAME%TYPE;
    l_customer_item_name	MSC_SUP_DEM_ENTRIES.CUSTOMER_ITEM_NAME%TYPE;
    l_supplier_item_name	MSC_SUP_DEM_ENTRIES.SUPPLIER_ITEM_NAME%TYPE;
    l_owner_item_desc		MSC_SUP_DEM_ENTRIES.OWNER_ITEM_DESCRIPTION%TYPE;
    l_customer_item_desc	MSC_SUP_DEM_ENTRIES.CUSTOMER_ITEM_DESCRIPTION%TYPE;
    l_supplier_item_desc	MSC_SUP_DEM_ENTRIES.SUPPLIER_ITEM_DESCRIPTION%TYPE;
    l_lead_time			NUMBER;
    l_tp_customer_id		NUMBER;
    l_tp_customer_site_id	NUMBER;
    l_location_id		NUMBER;
    l_org_location_id		NUMBER;
    l_session_id		NUMBER;
    l_regions_return_status	VARCHAR2(1);
    l_tp_uom			MSC_SUP_DEM_ENTRIES.TP_UOM_CODE%TYPE;
    l_conversion_found		BOOLEAN;
    l_conversion_rate		NUMBER;

    l_process_lead_time             BOOLEAN;
    l_prev_lead_time                NUMBER;
    l_prev_partner_id               NUMBER;
    l_prev_partner_site_id  NUMBER;
    l_prev_organization_id  NUMBER;

    l_sysdate		    DATE;
    i NUMBER :=0 ;
    j NUMBER :=0 ;

    full_language   VARCHAR2(80);
    l_language_code VARCHAR2(10);

    l_shipping_ctrl_lktype VARCHAR2(30) := 'MSC_X_SHIPPING_CONTROL';

    l_ship_lkcode    NUMBER := 2;
    l_arrive_lkcode  NUMBER := 1;


	l_asl_vmi_flag  NUMBER;

    a_ins_count	number_arr := number_arr();
    v_in_org_str             VARCHAR2(1024):='NULL';
	v_in_ot_str              VARCHAR2(1024):= 'NULL';
    v_sql_stmt               VARCHAR2(3000);
	a_post_status			NUMBER;
	a_ack_return_status      BOOLEAN;

    CURSOR itemSuppliers (p_organization_id NUMBER,
                          p_sr_instance_id  NUMBER,
                          p_item_id         NUMBER,
                          p_partner_id	    NUMBER,
                          p_partner_site_id NUMBER) IS
    select supplier_item_name,
           nvl(mis.processing_lead_time, 0),
           mis.uom_code,
		   nvl(mis.vmi_flag, 2),
           description
    from  msc_item_suppliers mis
    where mis.plan_id           = G_PLAN_ID
    and   mis.organization_id   = p_organization_id
    and   mis.sr_instance_id    = p_sr_instance_id
    and   mis.inventory_item_id = p_item_id
    and   mis.supplier_id 	= p_partner_id
    and   nvl(mis.supplier_site_id, -99) = decode(mis.supplier_site_id,
    		   					     null, -99, p_partner_site_id)
    order by nvl(mis.supplier_site_id, -99), mis.using_organization_id desc;

BEGIN
    /* Display the parameters */

    LOG_MESSAGE('Parameters');
    LOG_MESSAGE('==========');
    LOG_MESSAGE('  p_sr_instance_id :'||p_sr_instance_id);
    LOG_MESSAGE('  p_user_id :'||p_user_id);
    LOG_MESSAGE('  p_po_enabled_flag :'||  p_po_enabled_flag);
    LOG_MESSAGE('  p_oh_enabled_flag :'||  p_oh_enabled_flag);
    LOG_MESSAGE('  p_so_enabled_flag :'||  p_so_enabled_flag);
    LOG_MESSAGE('  p_asl_enabled_flag :'||  p_asl_enabled_flag);
    LOG_MESSAGE('  p_sup_resp_flag :'||  p_sup_resp_flag);
    LOG_MESSAGE('  p_po_sn_flag :'||  p_po_sn_flag);
    LOG_MESSAGE('  p_oh_sn_flag :'||  p_oh_sn_flag);
    LOG_MESSAGE('  p_so_sn_flag :'||  p_so_sn_flag);
    LOG_MESSAGE('  p_suprep_sn_flag :'||  p_suprep_sn_flag);

    --======================
    -- Get the user language
    --======================
/*  BUG #3845796 :Using Applications Session Language in preference to ICX_LANGUAGE profile value */

        l_language_code := USERENV('LANG');

        IF(l_language_code is null) THEN
        full_language := fnd_profile.value('ICX_LANGUAGE');

        IF full_language IS NOT NULL THEN
	   BEGIN
                SELECT language_code
                INTO   l_language_code
                FROM   fnd_languages
                WHERE  nls_language = full_language;
           EXCEPTION WHEN OTHERS THEN
                LOG_MESSAGE('Error while fetching user language');
           END;
        ELSE
            LOG_MESSAGE('Can not determine language using either the Applications Session or the
        ICX_LANGUAGE profile option so assigning default value as US ');
            l_language_code := 'US';
        END IF;
        END IF;

        LOG_MESSAGE('The language Code :'||l_language_code);

	    execute immediate
		'select meaning from FND_LOOKUP_VALUES '
		|| ' where LOOKUP_TYPE = ''MSC_X_ORDER_TYPE'' '
		|| ' and   LOOKUP_CODE = 15 '
		|| ' and   LANGUAGE = :l_language_code '
		into  G_ASN_DESC
		USING  l_language_code;
        LOG_DEBUG('The G_ASN_DESC :'||G_ASN_DESC);

	execute immediate
		'select meaning from FND_LOOKUP_VALUES '
		|| ' where LOOKUP_TYPE = ''MSC_X_ORDER_TYPE'' '
		|| ' and   LOOKUP_CODE = 13 '
		|| ' and   LANGUAGE = :l_language_code '
		into  G_PO_DESC
		USING  l_language_code;
        LOG_DEBUG('The G_PO_DESC :'||G_PO_DESC);

	execute immediate
		'select meaning from FND_LOOKUP_VALUES '
		|| ' where LOOKUP_TYPE = ''MSC_X_ORDER_TYPE'' '
		|| ' and   LOOKUP_CODE = 20 '
		|| ' and   LANGUAGE = :l_language_code '
		into  G_REQ_DESC
		USING  l_language_code;
        LOG_DEBUG('The G_REQ_DESC :'||G_REQ_DESC);

	  BEGIN
	  select  MEANING
	    into  G_SHIP_CONTROL
	    from  fnd_lookup_values
	   where  LOOKUP_TYPE = l_shipping_ctrl_lktype
	     and  LOOKUP_CODE =l_ship_lkcode
	     and  language = l_language_code;
        LOG_DEBUG('G_SHIP_CONTROL :'||G_SHIP_CONTROL);

	  select  MEANING
	    into  G_ARRIVE_CONTROL
	    from  fnd_lookup_values
	   where  LOOKUP_TYPE = l_shipping_ctrl_lktype
	     and  LOOKUP_CODE =l_arrive_lkcode
	     and  language = l_language_code;
        LOG_DEBUG('G_ARRIVE_CONTROL :'||G_ARRIVE_CONTROL);
	  EXCEPTION
	    WHEN OTHERS THEN
	      G_SHIP_CONTROL := 'Ship';
	      G_ARRIVE_CONTROL := 'Arrival';
	  END;

    /* Get the current refresh number for the source instance */
    BEGIN
        select LCID,
               lrtype,
	       so_lrtype,
               DECODE(mai.m2a_dblink,NULL,' ', '@' || m2a_dblink),
	       apps_ver
          into v_refresh_number,
               v_lrtype,
	       v_so_lrtype,
	       v_sr_dblink,
	       v_apps_ver
        from msc_apps_instances mai
	where mai.instance_id = p_sr_instance_id;

        LOG_MESSAGE('Additional Information');
        LOG_MESSAGE('======================');
        LOG_MESSAGE('  Last Refresh Number :'||v_refresh_number);
        LOG_MESSAGE('  Last Refresh Type :'||v_lrtype);
        LOG_MESSAGE('  Last Sales Order Refresh Type :'||v_so_lrtype);
    EXCEPTION WHEN OTHERS THEN
	LOG_MESSAGE('Error while fetching last refresh number');
	LOG_MESSAGE(SQLERRM);
	RETCODE := G_ERROR;
    END;

	/* LEG-COLL */
	-- ========================================
	-- Manipulate lrtype for legacy collections
	-- ========================================
	IF v_lrtype = 'L' THEN
		v_lrtype := 'I';
		LOG_MESSAGE('Legacy Collections -- Treating as Net Change collections');
    END IF;

    -- ===========
    -- Get sysdate
    -- ===========
    BEGIN
        select sysdate into l_sysdate from dual;
    EXCEPTION WHEN OTHERS THEN
	LOG_MESSAGE('Error while fetching sysdate');
	LOG_MESSAGE(SQLERRM);
	RETCODE := G_ERROR;
    END;

	-- ====================================================================
	-- Derive refresh_number (LCID) for each entity.
	-- Before contineous collections the refresh_number used to be
	-- same for all entities collected. In case of contineous collections
	-- we can collect some entities in targeted mode and some entities
	-- in net change mode. Therefore we can have different refresh numbers
	-- across the entities.
	-- ====================================================================

    IF (v_lrtype = 'T') THEN
        INITIALIZE_REFRESH_NUM(v_refresh_number,
		    				   v_lrtype,
		    				   p_po_enabled_flag,
							   p_oh_enabled_flag,
							   p_so_enabled_flag,
							   p_asl_enabled_flag,
							   p_sup_resp_flag ,
							   p_po_sn_flag,
							   p_oh_sn_flag,
							   p_so_sn_flag,
							   p_suprep_sn_flag);
    ELSE
	    v_supply_refresh_number := v_refresh_number;
        v_oh_refresh_number := v_refresh_number;
        v_so_refresh_number := v_refresh_number;
        v_suprep_refresh_number := v_refresh_number;
    END IF;

    -- ===============================================================================
    -- If complete refresh then delete following records in msc_sup_dem_entries
    --
    -- 1. All PO Order Types (13,20,16,15) which belong to Publisher = "My Company"
    --	  and publisher_site IN (All enaled inventory organizations for ERP instance)
    -- 2. All Allocated OH records (order type = G_ALLOC_ONHAND) which belong to
    --    Publisher = "My Company"
    --	  and publisher_site IN (All enaled inventory organizations for ERP instance)
    -- 3. All Sales Order records which belong to Publisher = "My Company"
    --	  and publisher_site IN (All enaled inventory organizations for ERP instance)
    -- ================================================================================

    /* Get the enabled Orgs for instance */

    /* Get the enabled Orgs for instance */
      IF v_in_org_str='NULL' THEN

           FOR lc_ins_org IN org LOOP

               IF org%rowcount = 1 THEN
                  v_in_org_str:=' IN ('|| lc_ins_org.org_id;
               ELSE
                  v_in_org_str := v_in_org_str||','||lc_ins_org.org_id;
               END IF;

           END LOOP;

           IF v_in_org_str<>'NULL' THEN
              v_in_org_str:= v_in_org_str || ')';
           ELSE
              v_in_org_str:= '= -9999';
           END IF;

        END IF; -- If v_in_org_str='NULL'

    IF ( v_lrtype = 'C' OR
		 v_lrtype = 'P' ) THEN

     /* Delete PO, OH and SO records if the current collection is of Complete refresh */
        IF v_lrtype = 'C' THEN

	    IF (v_so_lrtype = 'C') then
		     /* bug:3584822 -- Delete S.O only if the Sales orders
			is YES in complete refresh */
		     v_sql_stmt:=
			' delete msc_sup_dem_entries msde'
			||' where msde.publisher_id = 1'
			||' and   msde.publisher_site_id '||v_in_org_str
			||' and   msde.plan_id = -1 '
			||' and   msde.publisher_order_type IN '
			||'( 9, 10, 13, 20, 14, 15, 16 '
			||') ';
	    ELSE
		     v_sql_stmt:=
			' delete msc_sup_dem_entries msde'
			||' where msde.publisher_id = 1'
			||' and   msde.publisher_site_id '||v_in_org_str
			||' and   msde.plan_id = -1 '
			||' and   msde.publisher_order_type IN '
			||'( 9, 10, 13, 20, 15, 16 '
			||') ';
	    END IF;

		EXECUTE IMMEDIATE v_sql_stmt;

		LOG_MESSAGE('Total Records for deletion in Complete Refresh : '||SQL%ROWCOUNT);
		COMMIT;

	END IF;

	    IF ( v_lrtype = 'P' AND p_po_enabled_flag = MSC_CL_COLLECTION.SYS_YES) THEN

             v_sql_stmt:=
        	' delete msc_sup_dem_entries msde'
        	||' where msde.publisher_id = 1'
        	||' and   msde.publisher_site_id '||v_in_org_str
        	||' and   msde.plan_id = -1 '
        	||' and   msde.publisher_order_type IN '
        	||'( 13, 20, 15, 16 '
        	||') ';

            EXECUTE IMMEDIATE v_sql_stmt;
            LOG_MESSAGE('Total records(PO/REQ/ASN/REC) for deletion in Targeted Refresh : '||SQL%ROWCOUNT);

            COMMIT;

        END IF;

        IF ( v_lrtype = 'P' AND p_oh_enabled_flag = MSC_CL_COLLECTION.SYS_YES) THEN

             v_sql_stmt:=
        	' delete msc_sup_dem_entries msde'
        	||' where msde.publisher_id = 1'
        	||' and   msde.publisher_site_id '||v_in_org_str
        	||' and   msde.plan_id = -1 '
        	||' and   msde.publisher_order_type IN '
        	||'( 9, 10 '
        	||') ';

            EXECUTE IMMEDIATE v_sql_stmt;
            LOG_MESSAGE('Total records(Onhand) for deletion in Targeted Refresh : '||SQL%ROWCOUNT);

            COMMIT;

	    END IF;

	    IF ( v_lrtype = 'P' AND p_so_enabled_flag = MSC_CL_COLLECTION.SYS_YES) THEN

             v_sql_stmt:=
        	' delete msc_sup_dem_entries msde'
        	||' where msde.publisher_id = 1'
        	||' and   msde.publisher_site_id '||v_in_org_str
        	||' and   msde.plan_id = -1 '
        	||' and   msde.publisher_order_type IN '
        	||'( 14 '
        	||') ';

            EXECUTE IMMEDIATE v_sql_stmt;
            LOG_MESSAGE('Total records(Sales Orders) for deletion in Targeted Refresh : '||SQL%ROWCOUNT);

            COMMIT;

        END IF;

    ELSIF (v_lrtype = 'T') THEN

		--=====================================================
		-- If it's Automatic collections then
		-- some entities can be refreshed in net change mode
		-- and some entities can be refreshed in targeted mode.
		--
		-- We will find out all entities refreshed in Targeted
		-- mode and delete those entities.
		-- ====================================================


	    --=======================
		-- Initialize v_in_ot_str
		--=======================
		v_in_ot_str := 'NULL' ;

        v_in_ot_str := 'IN ( -99 ';

		IF (nvl(p_po_enabled_flag, SYS_NO) = SYS_YES AND nvl(p_po_sn_flag, G_AUTO_NO_COLL) = G_AUTO_TAR_COLL) THEN
				v_in_ot_str :=  v_in_ot_str ||  ', '||   G_PO  ||', '
                                  || G_REQ ||', '
                                  || G_ASN ||', '
                                  || G_SHIP_RECEIPT;
        END IF;

        IF (nvl(p_oh_enabled_flag, SYS_NO) = SYS_YES AND nvl(p_oh_sn_flag, G_AUTO_NO_COLL) = G_AUTO_TAR_COLL) THEN

                v_in_ot_str := v_in_ot_str ||', '||G_ALLOC_ONHAND ||', '||G_UNALLOC_ONHAND ;

        END IF;

        IF (nvl(p_so_enabled_flag, SYS_NO) = SYS_YES AND nvl(p_so_sn_flag, G_AUTO_NO_COLL) = G_AUTO_TAR_COLL) THEN

                v_in_ot_str := v_in_ot_str ||', '||G_SALES_ORDER;

        END IF;

        v_in_ot_str := v_in_ot_str || ', -999)' ;

        --================================
        -- Initialize and build v_sql_stmt
        --================================

        BEGIN

        v_sql_stmt := NULL;

        v_sql_stmt:=
        	' delete msc_sup_dem_entries msde'
        	||' where msde.publisher_id = 1'
        	||' and   msde.publisher_site_id '||v_in_org_str
        	||' and   msde.plan_id = -1 '
        	||' and   msde.publisher_order_type '||v_in_ot_str;


        EXECUTE IMMEDIATE v_sql_stmt;

        COMMIT;

        EXCEPTION WHEN OTHERS THEN
            LOG_MESSAGE('Error while deleting records from msc_sup_dem_entries in case of Automatic Collections');
            LOG_MESSAGE(SQLERRM);

			RETCODE := G_ERROR;
			RETURN;
        END;

    ELSIF (
              (v_lrtype = 'I' AND p_po_enabled_flag = MSC_CL_COLLECTION.SYS_YES))
                  OR
              (v_lrtype = 'T' AND (nvl(p_po_enabled_flag, SYS_NO) = SYS_YES AND nvl(p_po_sn_flag, G_AUTO_NO_COLL) = G_AUTO_NET_COLL)
          ) THEN

        -- =================================================================
        -- If PO data is collected in netchange mode then we want to delete
        -- following records from msc_sup_dem_entries
        -- Records with =>
        --     publisher_id = 1
        --     order_type = G_REQ
        --     order_number = null
        --
        -- These records are created using MOE. We will delete those.
        -- ================================================================

            BEGIN

            v_sql_stmt := NULL;

            v_sql_stmt:=
            ' delete msc_sup_dem_entries msde'
            ||' where msde.publisher_id = 1'
            ||' and   msde.publisher_site_id '||v_in_org_str
            ||' and   msde.plan_id = -1 '
            ||' and   msde.publisher_order_type = 20 '
            ||' and   msde.order_number is NULL' ;

            EXECUTE IMMEDIATE v_sql_stmt;

            COMMIT;
            EXCEPTION WHEN OTHERS THEN
                LOG_MESSAGE('Error while deleting records from msc_sup_dem_entries created using MOE');
                LOG_MESSAGE(SQLERRM);

                RETCODE := G_ERROR;
                RETURN;

            END;

    END IF; --v_lrtype = 'C' or v_lrtype = 'P' THEN


   /* Get the cursor data into collection objects */
   --=======================
   -- Collect Supply Records
   --=======================

   IF ((v_lrtype = 'C') OR
	  (v_lrtype = 'I') OR
	  (v_lrtype = 'P' AND p_po_enabled_flag = MSC_CL_COLLECTION.SYS_YES) OR
	  (v_lrtype = 'T' AND nvl(p_po_sn_flag, G_AUTO_NO_COLL) <> G_AUTO_NO_COLL )) THEN

   OPEN mscSupply(v_supply_refresh_number,
                  p_sr_instance_id,
                  l_language_code);

   BEGIN
   FETCH mscSupply BULK COLLECT INTO
       --t_transaction_id,
       t_sr_instance_id,
       t_plan_id,
       t_pub_id,
       t_pub_site_id,
       t_pub,
       t_pub_site,
       t_item_id,
       t_quantity,
       t_order_type,
       t_receipt_date,
--       t_ship_date,
       t_supp_id,
       t_supp,
       t_supp_site_id,
       t_supp_site,
       t_line_num,
       t_ord_num,
       t_shipto_id,
       t_shipto_site_id,
       t_shipto,
       t_shipto_site,
       t_shipfrom_id,
       t_shipfrom_site_id,
       t_shipfrom,
       t_shipfrom_site,
       t_item_name,
       t_item_desc,
       t_uom,
       t_ot_desc,
       t_bkt_type,
       t_bkt_type_desc,
       t_comments,
       t_created_by,
       t_creation_date,
       t_last_updated_by,
       t_last_update_date,
       t_key_date,
       t_partner_id,
       t_partner_site_id,
       t_orig_sr_instance_id,
       t_organization_id,
	   t_release_number,
	   t_new_ord_plac_date
       , t_vmi_flag
	   , t_acceptance_required_flag
	   , t_need_by_date
	   , t_promised_date
	   , t_base_item_id
	   , t_base_item_name
	   , t_internal_flag
	   ,t_planner_code; --Bug 4424426

    CLOSE mscSupply;

    EXCEPTION WHEN OTHERS THEN
        LOG_MESSAGE('Error while fetching records from CURSOR mscSupply');
        LOG_MESSAGE(SQLERRM);
        RETCODE := G_ERROR;
    END;

    /* Now we have all collection objects for publishing data to
       Supply ChaExchange.
       Calling SCE API.
    */

    LOG_MESSAGE('Total Supply records fetched :'||t_pub_id.COUNT);

    --===========================================================================================
    -- Derive dependant column values before updating or inserting records in msc_sup_dem_entries
    --===========================================================================================
    IF t_pub_id.COUNT > 0 THEN

        FOR j in 1.. t_pub_id.COUNT LOOP

        --===================================================
    	-- Extend the variables which value will get derived.
    	--===================================================

    	t_owner_item_name.EXTEND;
    	t_customer_item_name.EXTEND;
    	t_supplier_item_name.EXTEND;
    	t_owner_item_desc.EXTEND;
    	t_cust_item_desc.EXTEND;
    	t_tp_uom.EXTEND;
    	t_tp_quantity.EXTEND;
    	t_ship_date.EXTEND;
		t_sup_item_desc.EXTEND;

        --============================================
    	-- Derive the Item cross reference information
	-- This need not be done for internal requisitions
    	--============================================

	if(t_internal_flag(j) is null) then
    	--====================
    	-- Initialize variable
    	--====================
    	   l_supplier_item_name	:= null;
    	   l_lead_time := 0;
    	   l_tp_uom    := null;
    	   l_conversion_rate := null;
           l_supplier_item_desc := null;

    	   t_customer_item_name(j) := t_item_name(j);
    	   t_owner_item_name(j) := t_item_name(j);
    	   t_owner_item_desc(j) := t_item_desc(j);
    	   t_cust_item_desc(j) := t_item_desc(j);

    	       BEGIN

			   --=====================================================
			   -- We will fetch vmi_flag from itemSuppliers cursor
			   -- but it won't be used for order types in mscSupplies
			   -- cursor. We are fetching it here for syntax purpose.
			   -- ====================================================

    	           OPEN itemSuppliers(t_organization_id(j),
    		          	      t_orig_sr_instance_id(j),
    		       		      t_item_id(j),
    		       		      t_partner_id(j),
    		        	      t_partner_site_id(j));

    		   FETCH itemSuppliers INTO l_supplier_item_name,
    		        		    l_lead_time,
    		        		    l_tp_uom,
								l_asl_vmi_flag,
								l_supplier_item_desc;

		   CLOSE itemSuppliers;

		   EXCEPTION WHEN OTHERS THEN
		       l_supplier_item_name := null;
		       l_lead_time := 0;
		       l_tp_uom := t_uom(j);
               l_supplier_item_desc := NULL;
		   END;

		   t_supplier_item_name(j) := l_supplier_item_name;
		   t_tp_uom(j) := nvl(l_tp_uom, t_uom(j));
		   t_sup_item_desc(j) := l_supplier_item_desc;

		   --===============================================
		   -- Get the conversion rate and derive tp_quantity
		   --===============================================
		   msc_x_util.get_uom_conversion_rates
		       (t_uom(j),
                        t_tp_uom(j),
                        t_item_id(j),
                        l_conversion_found,
                        l_conversion_rate);

                  IF l_conversion_found THEN
                      t_tp_quantity(j) := t_quantity(j) * l_conversion_rate;
                  ELSE
                      t_tp_quantity(j) := t_quantity(j);
                  END IF;

	       --===================================================
	       -- Derive the ship_date and receipt_date information.
	       --===================================================
         	   t_ship_date(j) := t_receipt_date(j) - nvl(l_lead_time, 0);
	else /* Internal requisitions */

			   t_tp_quantity(j) := t_quantity(j);

			   l_lead_time := 0; /* sbala, add code to calculate
						   lead time correctly for internal
						   reqs */

			   t_ship_date(j) := t_receipt_date(j) - nvl(l_lead_time, 0);

                 /* Added for bug# 3311573, set supplier_item_name as the OEM
		    item name for Internal Reqs of Cust. VMI items in the customer modeled org */
			   t_supplier_item_name(j) := t_item_name(j);
			   t_sup_item_desc(j) := t_item_desc(j);
	end if;
        END LOOP;
    END IF;

    IF t_pub_id.COUNT > 0 THEN

         BEGIN

         FORALL j in 1..t_pub_id.COUNT

          UPDATE  msc_sup_dem_entries
          SET    last_refresh_number = msc_cl_refresh_s.nextval,
                 quantity = round((nvl(t_quantity(j),0)),6),
                 tp_quantity = round((nvl(t_tp_quantity(j),0)),6),
                 comments = t_comments(j),
                 ship_date = t_ship_date(j),
                 receipt_date = t_receipt_date(j),
                 ship_from_party_id = t_shipfrom_id(j),
                 ship_to_party_id = t_shipto_id(j),
                 ship_to_party_site_id = t_shipto_site_id(j),
                 ship_to_party_name = t_shipto(j),
                 ship_to_party_site_name = t_shipto_site(j),
                 ship_from_party_site_id = t_shipfrom_site_id(j),
                 ship_from_party_name = t_shipfrom(j),
                 ship_from_party_site_name = t_shipfrom_site(j),
                 uom_code = t_uom(j),
                 last_update_date = sysdate,
                 last_updated_by = -1,
	         primary_quantity = round((nvl(t_quantity(j),0)),6),
	         tp_uom_code = t_tp_uom(j),
	         key_date = t_key_date(j),
			 primary_uom = t_uom(j),
			 need_by_date = t_need_by_date(j),
			 promised_date = t_promised_date(j)
			 ,internal_flag = t_internal_flag(j)
          WHERE  plan_id = t_plan_id(j) AND
                 sr_instance_id = t_sr_instance_id(j) AND
                 publisher_id = t_pub_id(j) AND
                 publisher_site_id = t_pub_site_id(j) AND
                 NVL(supplier_id, G_NULL_STRING) = NVL(t_supp_id(j), G_NULL_STRING) AND
                 NVL(supplier_site_id, G_NULL_STRING) = NVL(t_supp_site_id(j), G_NULL_STRING) AND
                 publisher_order_type = t_order_type(j) AND
                 inventory_item_id = t_item_id(j) AND
                 NVL(bucket_type, G_NULL_STRING) = NVL(t_bkt_type(j), G_NULL_STRING) AND
                 NVL(order_number, G_NULL_STRING) = NVL(t_ord_num(j), G_NULL_STRING) AND
                 NVL(line_number, G_NULL_STRING) = NVL(t_line_num(j), G_NULL_STRING) AND
		 /* Removed Key_date from transaction key. Added release_number istead */
                 -- NVL(key_date, sysdate) = NVL(t_key_date(j), sysdate) ;
		 NVL(release_number, G_NULL_STRING) = NVL(t_release_number(j), G_NULL_STRING);

                 COMMIT;

          EXCEPTION WHEN OTHERS THEN
              LOG_MESSAGE('Error while updating msc_sup_dem_entries');
              LOG_MESSAGE(SQLERRM);
              RETCODE := G_ERROR;
          END;

    END IF;

    /* Create collections objects for insertion */
        FOR j in 1.. t_pub_id.COUNT LOOP
            IF (SQL%BULK_ROWCOUNT(j) = 0) THEN
                a_ins_count.EXTEND;
                t_ins_sr_instance_id.EXTEND;
                t_ins_plan_id.EXTEND;
                --t_ins_transaction_id.EXTEND;
                t_ins_pub_id.EXTEND;
       		t_ins_pub_site_id.EXTEND;
       		t_ins_pub.EXTEND;
       		t_ins_pub_site.EXTEND;
       		t_ins_item_id.EXTEND;
	        t_ins_base_item_id.EXTEND;
       		t_ins_quantity.EXTEND;
       		t_ins_order_type.EXTEND;
       		t_ins_receipt_date.EXTEND;
       		t_ins_ship_date.EXTEND;
       		t_ins_supp_id.EXTEND;
       		t_ins_supp.EXTEND;
       		t_ins_supp_site_id.EXTEND;
       		t_ins_supp_site.EXTEND;
       		t_ins_line_num.EXTEND;
       		t_ins_ord_num.EXTEND;
       		t_ins_shipto_id.EXTEND;
       		t_ins_shipto_site_id.EXTEND;
       		t_ins_shipto.EXTEND;
       		t_ins_shipto_site.EXTEND;
       		t_ins_shipfrom_id.EXTEND;
       		t_ins_shipfrom_site_id.EXTEND;
       		t_ins_shipfrom.EXTEND;
       		t_ins_shipfrom_site.EXTEND;
       		t_ins_item_name.EXTEND;
	        t_ins_base_item_name.EXTEND;
       		t_ins_item_desc.EXTEND;
       		t_ins_uom.EXTEND;
       		t_ins_ot_desc.EXTEND;
       		t_ins_bkt_type.EXTEND;
       		t_ins_bkt_type_desc.EXTEND;
       		t_ins_comments.EXTEND;
       		t_ins_created_by.EXTEND;
    		t_ins_creation_date.EXTEND;
    		t_ins_last_updated_by.EXTEND;
    		t_ins_last_update_date.EXTEND;
    		t_ins_key_date.EXTEND;
        	t_ins_release_number.EXTEND;
			t_ins_new_ord_plac_date.EXTEND;
			t_ins_acceptance_required_flag.EXTEND;
			t_ins_need_by_date.EXTEND;
			t_ins_promised_date.EXTEND;
		t_ins_internal_flag.EXTEND;
		    t_ins_sup_item_desc.EXTEND;
		 t_ins_planner_code.EXTEND; --Bug 4424426

       		a_ins_count(a_ins_count.COUNT)	:= j;
       		t_ins_sr_instance_id(a_ins_count.COUNT) := t_sr_instance_id(j);
       		--t_ins_transaction_id(a_ins_count.COUNT) := t_transaction_id(j);
       		t_ins_plan_id(a_ins_count.COUNT) := t_plan_id(j);
       		t_ins_pub_id(a_ins_count.COUNT)	:= t_pub_id(j);
       		t_ins_pub_site_id(a_ins_count.COUNT)	:= t_pub_site_id(j);
       		t_ins_pub(a_ins_count.COUNT)	:= t_pub(j);
       		t_ins_pub_site(a_ins_count.COUNT)	:= t_pub_site(j);
       		t_ins_item_id(a_ins_count.COUNT)	:= t_item_id(j);
	        t_ins_base_item_id(a_ins_count.COUNT) := t_base_item_id(j);
		t_ins_base_item_name(a_ins_count.COUNT) := t_base_item_name(j);
       		t_ins_quantity(a_ins_count.COUNT)	:= t_quantity(j);
       		t_ins_order_type(a_ins_count.COUNT)	:= t_order_type(j);
       		t_ins_supp_id(a_ins_count.COUNT)	:= t_supp_id(j);
       		t_ins_supp(a_ins_count.COUNT)	:= t_supp(j);
       		t_ins_supp_site_id(a_ins_count.COUNT)	:= t_supp_site_id(j);
       		t_ins_supp_site(a_ins_count.COUNT)	:= t_supp_site(j);
       		t_ins_line_num(a_ins_count.COUNT)	:= t_line_num(j);
       		t_ins_ord_num(a_ins_count.COUNT)	:= t_ord_num(j);
       		t_ins_shipto_id(a_ins_count.COUNT):= t_shipto_id(j);
       		t_ins_shipto_site_id(a_ins_count.COUNT)	:= t_shipto_site_id(j);
       		t_ins_shipto(a_ins_count.COUNT)	:= t_shipto(j);
       		t_ins_shipto_site(a_ins_count.COUNT)	:= t_shipto_site(j);
       		t_ins_shipfrom_id(a_ins_count.COUNT)	:= t_shipfrom_id(j);
       		t_ins_shipfrom_site_id(a_ins_count.COUNT)	:= t_shipfrom_site_id(j);
       		t_ins_shipfrom(a_ins_count.COUNT)	:= t_shipfrom(j);
       		t_ins_shipfrom_site(a_ins_count.COUNT)	:= t_shipfrom_site(j);
       		t_ins_item_name(a_ins_count.COUNT)	:= t_item_name(j);
	        t_ins_item_desc(a_ins_count.COUNT)	:= t_item_desc(j);
	        t_ins_uom(a_ins_count.COUNT)	:= t_uom(j);
       		t_ins_ot_desc(a_ins_count.COUNT)	:= t_ot_desc(j);
       		t_ins_bkt_type(a_ins_count.COUNT)	:= t_bkt_type(j);
       		t_ins_bkt_type_desc(a_ins_count.COUNT)	:= t_bkt_type_desc(j);
       		t_ins_comments(a_ins_count.COUNT)	:= t_comments(j);
       		t_ins_created_by(a_ins_count.COUNT)	:= t_created_by(j);
    		t_ins_creation_date(a_ins_count.COUNT)	:= t_creation_date(j);
    		t_ins_last_updated_by(a_ins_count.COUNT)	:= t_last_updated_by(j);
    		t_ins_last_update_date(a_ins_count.COUNT)	:= t_last_update_date(j);
    		t_ins_key_date(a_ins_count.COUNT) := t_key_date(j);
		    t_ins_release_number(a_ins_count.COUNT) := t_release_number(j);
			t_ins_new_ord_plac_date(a_ins_count.COUNT) := t_new_ord_plac_date(j);
			t_ins_need_by_date(a_ins_count.COUNT) := t_need_by_date(j);
			t_ins_promised_date(a_ins_count.COUNT) := t_promised_date(j);
		t_ins_internal_flag(a_ins_count.COUNT) := t_internal_flag(j);
		t_ins_planner_code(a_ins_count.COUNT) := t_planner_code(j);--Bug 4424426

    		t_ins_owner_item_name.EXTEND;
    		t_ins_customer_item_name.EXTEND;
    		t_ins_supplier_item_name.EXTEND;
    		t_ins_owner_item_desc.EXTEND;
    		t_ins_cust_item_desc.EXTEND;
    		t_ins_tp_uom.EXTEND;
    		t_ins_tp_quantity.EXTEND;
    		t_ins_vmi_flag.EXTEND;

    		t_ins_customer_item_name(a_ins_count.COUNT) := t_item_name(j);
    		t_ins_owner_item_name(a_ins_count.COUNT) := t_item_name(j);
    		t_ins_owner_item_desc(a_ins_count.COUNT) := t_item_desc(j);
    		t_ins_cust_item_desc(a_ins_count.COUNT) := t_item_desc(j);
    		t_ins_supplier_item_name(a_ins_count.COUNT) := t_supplier_item_name(j);
            t_ins_sup_item_desc(a_ins_count.COUNT) := t_sup_item_desc(j);

            /* If Supplier Item description is not available then we will use
			   OEM Item description */

		    if t_ins_supplier_item_name(a_ins_count.COUNT) IS NOT NULL THEN
	            if  t_ins_sup_item_desc(a_ins_count.COUNT) IS NULL THEN
				    t_ins_sup_item_desc(a_ins_count.COUNT) := t_item_desc(j);
	            end if;
		    end if;

    		t_ins_tp_uom(a_ins_count.COUNT) := t_tp_uom(j);
    		t_ins_tp_quantity(a_ins_count.COUNT) := t_tp_quantity(j);
    		t_ins_receipt_date(a_ins_count.COUNT) := t_receipt_date(j);
         	t_ins_ship_date(a_ins_count.COUNT) := t_ship_date(j);
    		t_ins_vmi_flag(a_ins_count.COUNT) := t_vmi_flag(j);

			/* CP-ACK starts */
			t_ins_acceptance_required_flag(a_ins_count.COUNT) := t_acceptance_required_flag(j);

            END IF;
        END LOOP;

        LOG_MESSAGE('Total Supply records for insertion '||a_ins_count.COUNT);

          /* for bug # 3323263, modified code to populate the customer columns
	     from the ship_to* columns */

        IF a_ins_count.COUNT > 0 THEN
            BEGIN
            FORALL j in 1..a_ins_count.COUNT
		insert into msc_sup_dem_entries
		(
		 sr_instance_id
		 ,transaction_id
		 ,plan_id
		 ,publisher_id
		 ,publisher_site_id
		 ,publisher_name
       		 ,publisher_site_name
       		 ,inventory_item_id
       		 ,quantity
       		 ,publisher_order_type
       		 ,receipt_date
       		 ,ship_date
       		 ,supplier_id
       		 ,supplier_name
       		 ,supplier_site_id
       		 ,supplier_site_name
       		 ,line_number
       		 ,order_number
       		 ,ship_to_party_id
       		 ,ship_to_party_site_id
       		 ,ship_to_party_name
       		 ,ship_to_party_site_name
       		 ,ship_from_party_id
       		 ,SHIP_FROM_PARTY_SITE_ID
       		 ,SHIP_FROM_PARTY_NAME
       		 ,SHIP_FROM_PARTY_SITE_NAME
       		 ,publisher_item_name
       		 ,pub_item_description
       		 ,uom_code
       		 ,publisher_order_type_desc
       		 ,bucket_type
       		 ,bucket_type_desc
       		 ,created_by
       		 ,creation_date
       		 ,last_updated_by
       		 ,last_update_date
       		 ,comments
       		 ,key_date
       		 ,item_name
       		 ,owner_item_name
       		 ,customer_item_name
       		 ,supplier_item_name
       		 ,item_description
       		 ,owner_item_description
       		 ,customer_item_description
       		 ,supplier_item_description
       		 ,primary_quantity
       		 ,tp_uom_code
       		 ,tp_quantity
       		 ,customer_id
       		 ,customer_site_id
       		 ,customer_name
       		 ,customer_site_name
			 ,last_refresh_number
			 ,release_number
			 ,primary_uom
			 ,new_order_placement_date
             , vmi_flag
			 ,acceptance_required_flag
			 ,need_by_date
			 ,promised_date
			 , base_item_id
			 , base_item_name
				 , internal_flag
				 ,planner_code --Bug 4424426
       		)values
                (
                 t_ins_sr_instance_id(j),
		 msc_sup_dem_entries_s.nextval,
                 --t_ins_transaction_id(j),
                 t_ins_plan_id(j),
                 t_ins_pub_id(j),
                 t_ins_pub_site_id(j),
                 t_ins_pub(j),
                 t_ins_pub_site(j),
                 t_ins_item_id(j),
                 round(t_ins_quantity(j),6),
     		 t_ins_order_type(j),
     		 t_ins_receipt_date(j),
     		 t_ins_ship_date(j),
     		 t_ins_supp_id(j),
     		 t_ins_supp(j),
     		 t_ins_supp_site_id(j),
     		 t_ins_supp_site(j),
     		 t_ins_line_num(j),
     		 t_ins_ord_num(j),
     		 t_ins_shipto_id(j),
     		 t_ins_shipto_site_id(j),
     		 t_ins_shipto(j),
     		 t_ins_shipto_site(j),
     		 t_ins_shipfrom_id(j),
     		 t_ins_shipfrom_site_id(j),
     		 t_ins_shipfrom(j),
     		 t_ins_shipfrom_site(j),
      		 t_ins_item_name(j),
                 t_ins_item_desc(j),
                 t_ins_uom(j),
     		 t_ins_ot_desc(j),
     		 t_ins_bkt_type(j),
     		 t_ins_bkt_type_desc(j),
     		 t_ins_created_by(j),
  		 t_ins_creation_date(j),
  		 t_ins_last_updated_by(j),
  		 t_ins_last_update_date(j),
     		 t_ins_comments(j),
     		 t_ins_key_date(j),
     		 t_ins_item_name(j),
     		 t_ins_owner_item_name(j),
     		 t_ins_customer_item_name(j),
     		 t_ins_supplier_item_name(j),
     		 t_ins_item_desc(j),
     		 t_ins_owner_item_desc(j),
     		 t_ins_cust_item_desc(j),
			 t_ins_sup_item_desc(j),
     		 round(t_ins_quantity(j), 6),
     		 t_ins_tp_uom(j),
     		 round(t_ins_tp_quantity(j), 6),
     		 t_ins_shipto_id(j),
     		 t_ins_shipto_site_id(j),
     		 t_ins_shipto(j),
     		 t_ins_shipto_site(j),
				 msc_cl_refresh_s.nextval,
				 t_ins_release_number(j),
				 t_ins_uom(j),
				 t_new_ord_plac_date(j)
              , t_ins_vmi_flag(j)
			  , t_ins_acceptance_required_flag(j)
			  , t_ins_need_by_date(j)
			  , t_ins_promised_date(j)
			  , t_ins_base_item_id(j)
			  , t_ins_base_item_name(j)
		 ,t_ins_internal_flag(j)
		 ,t_ins_planner_code(j)--Bug 4424426
              );

              COMMIT;

          EXCEPTION WHEN OTHERS THEN
              LOG_MESSAGE('Error while inserting records into msc_sup_dem_entries');
              LOG_MESSAGE(SQLERRM);
              ROLLBACK;
              RETCODE := G_ERROR;
          END;

        END IF;

		END IF; -- if v_lrtype = ......

--====================================
-- Populate Unallocated On hand record
--====================================

  BEGIN
      IF (v_lrtype = 'I' OR
          (v_lrtype = 'T' AND nvl(p_oh_sn_flag, G_AUTO_NO_COLL) = G_AUTO_NET_COLL)) THEN
		  /* SBALA - Debug */
		  LOG_MESSAGE('Fetching from unallocOnhandNetChange');
		  LOG_MESSAGE('v_refresh_number = '||v_refresh_number||'     p_sr_instance_id = '||p_sr_instance_id);
		  /* SBALA - Debug */

	      OPEN unallocOnhandNetChange (v_oh_refresh_number,
							  p_sr_instance_id,
                              l_language_code);

          FETCH unallocOnhandNetChange BULK COLLECT INTO
                       t_plan_id,
                       t_sr_instance_id,
                       t_pub_id,
                       t_pub_site_id,
                       t_pub,
                       t_pub_site,
                       t_item_id ,
                       t_quantity,
                       t_comments,
                       t_pub_order_type,
                       t_bkt_type,
                       t_item_name,
                       t_item_desc ,
                       t_ot_desc,
                       t_tp_ot_desc,
                       t_bkt_type_desc,
                       t_uom,
                       t_pri_uom,
                       t_primary_quantity,
		       t_base_item_id,
		       t_base_item_name,
		       t_planner_code;--Bug 4424426

           CLOSE unallocOnhandNetChange ;

      ELSE

	IF ((v_lrtype = 'C') OR
		(v_lrtype = 'P' AND p_oh_enabled_flag = MSC_CL_COLLECTION.SYS_YES) OR
		(v_lrtype = 'T' AND nvl(p_oh_sn_flag, G_AUTO_NO_COLL) = G_AUTO_TAR_COLL)) THEN

            OPEN unallocOnhand (v_oh_refresh_number,
                                   p_sr_instance_id,
                                   l_language_code);
	    FETCH unallocOnhand BULK COLLECT INTO
            	     t_plan_id,
            	     t_sr_instance_id,
            	     t_pub_id,
            	     t_pub_site_id,
            	     t_pub,
            	     t_pub_site,
            	     t_item_id ,
            	     t_quantity,
            	     t_comments,
            	     t_pub_order_type,
            	     t_bkt_type,
            	     t_item_name,
            	     t_item_desc ,
            	     t_ot_desc,
            	     t_tp_ot_desc,
            	     t_bkt_type_desc,
            	     t_uom,
            	     t_pri_uom,
                     t_primary_quantity,
		     t_base_item_id,
		     t_base_item_name,
		     t_planner_code;--Bug 4424426


	    CLOSE unallocOnhand;

        END IF;

      END IF;
      EXCEPTION WHEN OTHERS THEN
         LOG_MESSAGE('Error while fetching records from unallocOnhand cusrsor');
         LOG_MESSAGE(SQLERRM);
         RETCODE := G_ERROR;
   END;


     --=======================================
     -- Compute the values of derived columns
     -- before updation and insertion
     --=======================================

	 IF ((v_lrtype = 'C') OR
		 (v_lrtype = 'I') OR
		 (v_lrtype = 'P' AND p_oh_enabled_flag = MSC_CL_COLLECTION.SYS_YES) OR
	     (v_lrtype = 'T' AND nvl(p_oh_sn_flag, G_AUTO_NO_COLL) <> G_AUTO_NO_COLL)) THEN

        LOG_MESSAGE('Total records fetched for UnAllocated Onhand:'||t_plan_id.COUNT);


        FOR i IN 1..t_plan_id.COUNT LOOP

            t_owner_item_name.EXTEND;
   	    t_owner_item_desc.EXTEND;


             t_owner_item_name(i)    := t_item_name(i);
    	     t_owner_item_desc(i)    := t_item_desc(i);


         END LOOP;

         IF t_plan_id.COUNT > 0 THEN

             BEGIN
		 FORALL i in 1..t_plan_id.COUNT

                 update msc_sup_dem_entries
                     set quantity 	  = round(t_quantity(i), 6),
            	     bucket_type 	  = t_bkt_type(i),
            	     uom_code 	          = t_uom(i)     ,
            	     primary_uom 	  = t_pri_uom(i),
                     primary_quantity     = round(t_primary_quantity(i), 6),
		     key_date             = sysdate,
		     new_schedule_date    = sysdate,
                     last_refresh_number  = msc_cl_refresh_s.nextval ,
                     last_update_date     = l_sysdate,
                     last_updated_by	  = p_user_id
                 where   plan_id = G_PLAN_ID
                   and	 sr_instance_id 		 =  G_SR_INSTANCE_ID
                   and	 publisher_id 		   	 = t_pub_id(i)
            	   and	 publisher_site_id 		 = t_pub_site_id(i)
            	   and	 inventory_item_id 		 = t_item_id(i)
            	   and	 publisher_order_type 		 = t_pub_order_type(i);
            	 COMMIT;
             EXCEPTION WHEN OTHERS THEN
                 ROLLBACK;
                 LOG_MESSAGE('ERROR while updating msc_up_dem_entries using allocOnhand');
                 LOG_MESSAGE(SQLERRM);
                 RETCODE := G_ERROR;
             END;



	END IF;


     --==========================================================
     -- Insert the fetched records if the records are new records
     --     Step 1. Extend the insert variables.
     --     Step 2. BULK insert.
     --==========================================================

     /* Initialize the count */

     a_ins_count := null;
     a_ins_count := number_arr();

     FOR i IN 1..t_plan_id.COUNT LOOP
         IF (SQL%BULK_ROWCOUNT(i) = 0) THEN
             a_ins_count.EXTEND;
             --t_ins_transaction_id.EXTEND;
             t_ins_plan_id.EXTEND;
             t_ins_sr_instance_id.EXTEND;
             t_ins_pub_id.EXTEND;
	     t_ins_pub_site_id.EXTEND;
             t_ins_pub.EXTEND;
             t_ins_pub_site.EXTEND;
             --t_ins_new_sched_date.EXTEND;
             t_ins_item_id.EXTEND;
	     t_ins_base_item_id.EXTEND;
             t_ins_quantity.EXTEND;
             t_ins_comments.EXTEND;
             t_ins_pub_order_type.EXTEND;
             t_ins_bkt_type.EXTEND;
             --t_ins_ord_num.EXTEND;
             --t_ins_new_dock_date.EXTEND;
             t_ins_item_name.EXTEND;
	     t_ins_base_item_name.EXTEND;
             t_ins_item_desc.EXTEND;
             t_ins_ot_desc.EXTEND;
             t_ins_bkt_type_desc.EXTEND;
             t_ins_uom.EXTEND;
             --t_ins_created_by.EXTEND;
             --t_ins_creation_date.EXTEND;
             --t_ins_last_updated_by.EXTEND;
             --t_ins_last_update_date.EXTEND;
             --t_ins_key_date.EXTEND;
             t_ins_pri_uom.EXTEND;
             t_ins_primary_quantity.EXTEND;

    	     --==================================
    	     -- Extend the Item related variables
    	     --==================================

    	     t_ins_owner_item_name.EXTEND;
    	     ---t_ins_customer_item_name.EXTEND;
    	     ----t_ins_supplier_item_name.EXTEND;
    	     t_ins_owner_item_desc.EXTEND;
    	     ----t_ins_cust_item_desc.EXTEND;
    	     ----t_ins_tp_uom.EXTEND;
    	     ----t_ins_tp_quantity.EXTEND;

	     t_ins_planner_code.EXTEND;--Bug 4424426

	     a_ins_count(a_ins_count.COUNT)	:= i;
             --t_ins_transaction_id(a_ins_count.COUNT)  := t_transaction_id(i);
             t_ins_plan_id(a_ins_count.COUNT)		:= t_plan_id(i)	;
             t_ins_sr_instance_id(a_ins_count.COUNT)	:= t_sr_instance_id(i);
             t_ins_pub_id(a_ins_count.COUNT)		:= t_pub_id(i);
	         t_ins_pub_site_id(a_ins_count.COUNT)	:= t_pub_site_id(i);
             t_ins_pub(a_ins_count.COUNT)		:= t_pub(i);
             t_ins_pub_site(a_ins_count.COUNT)	:= t_pub_site(i);
             --t_ins_new_sched_date(a_ins_count.COUNT)	:= t_new_sched_date(i);
             t_ins_item_id(a_ins_count.COUNT)		:= t_item_id(i);
	     t_ins_base_item_id(a_ins_count.COUNT)      :=
							   t_base_item_id(i);
             t_ins_quantity(a_ins_count.COUNT)	:= t_quantity(i);
             t_ins_comments(a_ins_count.COUNT)	:= t_comments(i);
             t_ins_pub_order_type(a_ins_count.COUNT)	:= t_pub_order_type(i);
             --t_ins_supp_id(a_ins_count.COUNT)		:= t_supp_id(i);
	     --t_ins_supp(a_ins_count.COUNT)   		:= t_supp(i);
	     --t_ins_supp_site_id(a_ins_count.COUNT)    := t_supp_site_id(i);
	     --t_ins_supp_site(a_ins_count.COUNT)       := t_supp_site(i);
     	     t_ins_bkt_type(a_ins_count.COUNT)   	:= t_bkt_type(i);
             --t_ins_ord_num(a_ins_count.COUNT)   	:= t_ord_num(i);
	     --t_ins_new_dock_date(a_ins_count.COUNT)   := t_new_dock_date(i);
	     t_ins_item_name(a_ins_count.COUNT)   	:= t_item_name(i);
	     t_ins_base_item_name(a_ins_count.COUNT)    :=
							   t_base_item_name(i);
	     t_ins_item_desc(a_ins_count.COUNT)   	:= t_item_desc(i);
	     t_ins_ot_desc(a_ins_count.COUNT)   	:= t_ot_desc(i);
	     ---t_ins_tp_ot_desc(a_ins_count.COUNT)   	:= t_tp_ot_desc(i);
	     t_ins_bkt_type_desc(a_ins_count.COUNT)   := t_bkt_type_desc(i);
	     t_ins_uom(a_ins_count.COUNT)   		:= t_uom(i);
	     --t_ins_created_by(a_ins_count.COUNT)   	:= t_created_by(i);
	     --t_ins_creation_date(a_ins_count.COUNT)   := t_creation_date(i);
	     --t_ins_last_updated_by(a_ins_count.COUNT) := t_last_updated_by(i);
	     --t_ins_last_update_date(a_ins_count.COUNT):= t_last_update_date(i);
	     --t_ins_key_date(a_ins_count.COUNT)   	:= t_key_date(i);
	     t_ins_pri_uom(a_ins_count.COUNT)   	:= t_pri_uom(i);
	     t_ins_primary_quantity(a_ins_count.COUNT)  := t_primary_quantity(i);
 ---t_ins_customer_item_name(a_ins_count.COUNT) := t_customer_item_name(i);
             t_ins_owner_item_name(a_ins_count.COUNT)    := t_owner_item_name(i);
             t_ins_owner_item_desc(a_ins_count.COUNT)    := t_owner_item_desc(i);

	      t_ins_planner_code(a_ins_count.COUNT)    := t_planner_code(i);--Bug 4424426
   ---   t_ins_cust_item_desc(a_ins_count.COUNT)     := t_cust_item_desc(i);
   ---- t_ins_supplier_item_name(a_ins_count.COUNT) := t_supplier_item_name(i);
	 ---    t_ins_tp_uom(a_ins_count.COUNT) := t_tp_uom(i);
            --- t_ins_tp_quantity(a_ins_count.COUNT) := t_tp_quantity(i);
         END IF;
     END LOOP;

      LOG_MESSAGE('Total records for insertion for Unallocated Onhand:'||a_ins_count.COUNT);

     -- ==================
     -- Insert the records
     -- ==================
     IF a_ins_count.COUNT > 0 THEN

        BEGIN
            FORALL i IN 1..a_ins_count.COUNT
            INSERT INTO MSC_SUP_DEM_ENTRIES
            ( 	transaction_id,
              	plan_id,
              	sr_instance_id,
              	publisher_id,
              	publisher_site_id,
              	publisher_name,
              	publisher_site_name,
        	new_schedule_date       ,
        	inventory_item_id              ,
        	quantity,
        	comments,
        	publisher_order_type,
        	/** supplier_id,
        	supplier_name,
        	supplier_site_id,
        	supplier_site_name, */
        	bucket_type,
        	--order_number,
        	--new_dock_date,
        	item_name,
        	ITEM_DESCRIPTION,
        	PUB_ITEM_DESCRIPTIION   ,
        	PUBLISHER_ORDER_TYPE_DESC,
        	---tp_order_type_desc,
        	bucket_type_desc        ,
        	uom_code              ,
        	created_by,
        	creation_date,
        	last_updated_by,
        	last_update_date,
        	key_date,
        	primary_uom,
                primary_quantity,
                /* tp_uom_code,
                tp_quantity, */
                /* customer_id,
                customer_site_id,
                customer_name,
                customer_site_name, */
	        last_refresh_number,
	        ---supplier_item_name,
		owner_item_name,
		---customer_item_name,
		---supplier_item_description,
		owner_item_description,
		---customer_item_description
	        base_item_id,
	        base_item_name,
		planner_code--Bug 4424426
            )
            values
            (    msc_sup_dem_entries_s.nextval,
        	 t_ins_plan_id(i),
        	 t_ins_sr_instance_id(i),
        	 t_ins_pub_id(i),
        	 t_ins_pub_site_id(i),
        	 t_ins_pub(i),
        	 t_ins_pub_site(i),
		 l_sysdate,            --- new_schedule_date
        	 --t_ins_new_sched_date(i)      ,
        	 t_ins_item_id(i)              ,
        	 round(t_ins_quantity(i),6),
        	 t_ins_comments(i),
        	 t_ins_pub_order_type(i),
        	 /* t_ins_supp_id(i),
        	 t_ins_supp(i),
        	 t_ins_supp_site_id(i),
        	 t_ins_supp_site(i), */
        	 t_ins_bkt_type(i),
        	 --t_ins_ord_num(i),
        	 --t_ins_new_dock_date(i),
        	 t_ins_item_name(i),
        	 t_ins_item_desc(i)   ,
        	 t_ins_item_desc(i)   ,
        	 t_ins_ot_desc(i),
        	 ---t_tp_ot_desc(i),
        	 t_ins_bkt_type_desc(i)        ,
        	 t_ins_uom(i)              ,
        	 p_user_id,    --t_ins_created_by(i),
        	 l_sysdate,    --t_ins_creation_date(i),
        	 p_user_id,    --t_ins_last_updated_by(i),
        	 l_sysdate,    --t_ins_last_update_date(i),
        	 l_sysdate,    --Key Date
        	 --t_ins_key_date(i),
        	 t_ins_pri_uom(i),
                 round(t_ins_primary_quantity(i),6),
                 /* t_ins_tp_uom(i),
                 round(t_ins_tp_quantity(i), 6), */
                 /* t_ins_pub_id(i),
        	 t_ins_pub_site_id(i),
        	 t_ins_pub(i),
        	 t_ins_pub_site(i), */
	         msc_cl_refresh_s.nextval,
	         ---t_ins_supplier_item_name(i),
		 t_ins_owner_item_name(i),
		 ----t_ins_customer_item_name(i),
		 ---t_ins_supplier_item_name(i),
		 t_ins_owner_item_desc(i),
		 ---t_ins_cust_item_desc(i)
	         t_ins_base_item_id(i),
		 t_ins_base_item_name(i),
		 t_ins_planner_code(i) --Bug 4424426
            );

            COMMIT;
        EXCEPTION WHEN OTHERS THEN
            LOG_MESSAGE('ERROR while inserting from unallocOnhand to msc_sup_dem_entries ');
            LOG_MESSAGE(SQLERRM);
            ROLLBACK;
            RETCODE := G_ERROR;
        END;
     END IF;

      END IF;

--===================================================================================
-- Populate Allocated on hand record
--===================================================================================

    BEGIN
         IF ((v_lrtype = 'I') OR
		     (v_lrtype = 'T' AND nvl(p_oh_sn_flag, G_AUTO_NO_COLL) = G_AUTO_NET_COLL)) THEN

             OPEN allocOnhandNetChange (v_oh_refresh_number,
                               p_sr_instance_id,
                               l_language_code);
             FETCH allocOnhandNetChange BULK COLLECT INTO
            	 t_plan_id,
            	 t_sr_instance_id,
            	 t_pub_id,
            	 t_pub_site_id,
            	 t_pub,
            	 t_pub_site,
            	 t_item_id              ,
            	 t_quantity,
            	 t_comments,
            	 t_pub_order_type,
            	 t_supp_id,
            	 t_supp,
            	 t_supp_site_id,
            	 t_supp_site,
            	 t_bkt_type,
            	 t_item_name,
            	 t_item_desc   ,
            	 t_ot_desc,
            	 t_tp_ot_desc,
            	 t_bkt_type_desc        ,
            	 t_uom              ,
            	 t_pri_uom,
                 t_primary_quantity,
                 t_partner_id,
    	         t_partner_site_id,
           	 t_orig_sr_instance_id,
           	 t_organization_id
             , t_vmi_flag
             , t_alloc_type
	     , t_base_item_id
	     , t_base_item_name
	     ,t_planner_code;  --Bug 4424426

             CLOSE allocOnhandNetChange;
         ELSE
			 IF ((v_lrtype = 'C') OR
				 (v_lrtype = 'P' AND p_oh_enabled_flag = MSC_CL_COLLECTION.SYS_YES) OR
		         (v_lrtype = 'T' AND nvl(p_oh_sn_flag, G_AUTO_NO_COLL) = G_AUTO_TAR_COLL)) THEN

                 OPEN allocOnhand (v_oh_refresh_number,
                                   p_sr_instance_id,
                                   l_language_code);
                 FETCH allocOnhand BULK COLLECT INTO
            	     t_plan_id,
            	     t_sr_instance_id,
            	     t_pub_id,
            	     t_pub_site_id,
            	     t_pub,
            	     t_pub_site,
            	     t_item_id              ,
            	     t_quantity,
            	     t_comments,
            	     t_pub_order_type,
            	     t_supp_id,
            	     t_supp,
            	     t_supp_site_id,
            	     t_supp_site,
            	     t_bkt_type,
            	     t_item_name,
            	     t_item_desc   ,
            	     t_ot_desc,
            	     t_tp_ot_desc,
            	     t_bkt_type_desc        ,
            	     t_uom              ,
            	     t_pri_uom,
                     t_primary_quantity,
                     t_partner_id,
    	             t_partner_site_id,
           	         t_orig_sr_instance_id,
           	         t_organization_id
                     , t_vmi_flag
                     , t_alloc_type
		     , t_base_item_id
		     , t_base_item_name
		     , t_planner_code; --Bug 4424426



                 CLOSE allocOnhand;
		     END IF;
         END IF;

     EXCEPTION WHEN OTHERS THEN
         LOG_MESSAGE('Error while fetching records from allocOnhand cusrsor');
         LOG_MESSAGE(SQLERRM);
         RETCODE := G_ERROR;
     END;


     --=======================================
     -- Compute the values of derived columns
     -- before updation and insertion
     --=======================================

	 IF ((v_lrtype = 'C') OR
		 (v_lrtype = 'I') OR
		 (v_lrtype = 'P' AND p_oh_enabled_flag = MSC_CL_COLLECTION.SYS_YES) OR
		 (v_lrtype = 'T' AND nvl(p_oh_sn_flag, G_AUTO_NO_COLL) <> G_AUTO_NO_COLL)) THEN

        LOG_MESSAGE('Total records fetched for Allocated Onhand:'||t_plan_id.COUNT);

     FOR i IN 1..t_plan_id.COUNT LOOP

         --==================================
    	 -- Extend the Item related variables
    	 --==================================

    	 t_owner_item_name.EXTEND;
    	 t_customer_item_name.EXTEND;
    	 t_supplier_item_name.EXTEND;
    	 t_owner_item_desc.EXTEND;
    	 t_cust_item_desc.EXTEND;
    	 t_tp_uom.EXTEND;
    	 t_tp_quantity.EXTEND;
	 t_sup_item_desc.EXTEND;

         --============================================
    	 -- Derive the Item cross reference information
    	 --============================================


    	 --====================
    	 -- Initialize variable
    	 --====================
    	 l_supplier_item_name	:= null;
         l_supplier_item_desc := null;
    	 l_tp_uom := null;
    	 l_lead_time := 0;

    	 t_customer_item_name(i) := t_item_name(i);
         t_owner_item_name(i)    := t_item_name(i);
    	 t_owner_item_desc(i)    := t_item_desc(i);
    	 t_cust_item_desc(i)     := t_item_desc(i);

        IF (t_alloc_type(i) = G_SUPPLIER) then


             BEGIN

    		    OPEN itemSuppliers(t_organization_id(i),
    			    	   t_orig_sr_instance_id(i),
    		       		   t_item_id(i),
    		       		   t_partner_id(i),
    		        	   t_partner_site_id(i));

    		    FETCH itemSuppliers INTO l_supplier_item_name,
    		  		             l_lead_time,
    		        		     l_tp_uom,
								 l_asl_vmi_flag,
                                             l_supplier_item_desc;

		        IF itemSuppliers%NOTFOUND THEN
		            l_supplier_item_name := null;
		            l_lead_time := 0;
		            l_tp_uom := t_uom(i);
					l_asl_vmi_flag := 2;
	                END IF;

		        CLOSE itemSuppliers;

	        EXCEPTION WHEN OTHERS THEN
	            l_supplier_item_name := null;
	            l_lead_time := 0;
	            l_tp_uom := t_uom(i);
				l_asl_vmi_flag := 2;
                l_supplier_item_desc := null;
	        END;

            t_supplier_item_name(i) := l_supplier_item_name;
	        t_tp_uom(i) := nvl(l_tp_uom, t_uom(i));
			t_sup_item_desc(i) := l_supplier_item_desc;

            --==========================================
            -- Mark onhand as VMI onhand if
            -- 1. It's Allocated On Hand
            -- 2. Item has ASL with vmi_flag set to Yes.
            --==========================================
            t_vmi_flag(i) := nvl(l_asl_vmi_flag, 2);

        ELSE  /* Modeled Customer Case */

                 /* Added for bug# 3311573, set supplier_item_name as the OEM
		    item name for Allocated onhand in the customer modeled org */

		 t_supplier_item_name(i) := t_item_name(i);
		 t_sup_item_desc(i)      := t_item_desc(i);

		t_customer_item_name(i) := null;

		/* Add code to get customer item name from msc_item customers */

		    BEGIN

		   /* sbala Using Fetching Customer item name,
		      Using t_supp variables because that is
		      what I get in the cursor */

                   select customer_item_name,
                          description,
                          uom_code
                     into l_customer_item_name,
                          l_customer_item_desc,
                          l_tp_uom
                   from  msc_item_customers mic
                   where mic.plan_id = G_PLAN_ID
                   and   mic.inventory_item_id = t_item_id(i)
                   and   mic.customer_id       = t_supp_id(i)
                   and   nvl(mic.customer_site_id, -99) = decode(
						mic.customer_site_id,
                                                null, -99,
                                                t_supp_site_id(i));


            EXCEPTION WHEN OTHERS THEN
                       l_customer_item_name := null;
                       l_customer_item_desc := null;
                       l_tp_uom := null;
            END;
	    END IF;

        t_customer_item_name(i) := l_customer_item_name;
	    t_cust_item_desc(i) := l_customer_item_desc;
	    t_tp_uom(i) := nvl(l_tp_uom, t_uom(i));


  	--===============================================
	-- Get the conversion rate and derive tp_quantity
	--===============================================
	msc_x_util.get_uom_conversion_rates
		   (t_uom(i),
                    t_tp_uom(i),
                    t_item_id(i),
                    l_conversion_found,
                    l_conversion_rate);

        IF l_conversion_found THEN
            t_tp_quantity(i) := t_quantity(i) * l_conversion_rate;
        ELSE
            t_tp_quantity(i) := t_quantity(i);
        END IF;

     END LOOP;

     --===========================
     -- Update the fetched records
     --===========================

     IF t_plan_id.COUNT > 0 THEN

             BEGIN

             FORALL i in 1..t_plan_id.COUNT

                 update msc_sup_dem_entries
                     set quantity 	  = round(t_quantity(i), 6),
            	     bucket_type 	  = t_bkt_type(i),
            	     uom_code 	          = t_uom(i)     ,
            	     primary_uom 	  = t_pri_uom(i),
                     primary_quantity     = round(t_primary_quantity(i), 6),
		     key_date             = sysdate,
		     new_schedule_date    = sysdate,
                     last_refresh_number  = msc_cl_refresh_s.nextval ,
                     last_update_date     = l_sysdate,
                     last_updated_by	  = p_user_id,
                     tp_quantity	  = round(t_tp_quantity(i), 6),
                     tp_uom_code	  = t_tp_uom(i),
                     supplier_item_name   = t_supplier_item_name(i)
                 where   plan_id = G_PLAN_ID
                   and	 sr_instance_id 		 =  G_SR_INSTANCE_ID
                   and	 publisher_id 		   	 = t_pub_id(i)
            	   and	 publisher_site_id 		 = t_pub_site_id(i)
            	   and	 inventory_item_id 		 = t_item_id(i)
            	   and	 publisher_order_type 		 = t_pub_order_type(i)
            	   and	 supplier_id          		 = t_supp_id(i)
            	   and	 supplier_site_id     		 = t_supp_site_id(i)
            	   and   t_alloc_type(i) = G_SUPPLIER;
            	   --and	 nvl(bucket_type, G_NULL_STRING) = NVL(t_bkt_type(i), G_NULL_STRING)
            	   --and	 nvl(order_number, G_NULL_STRING)= NVL(t_ord_num(i), G_NULL_STRING)
            	   --and	 nvl(key_date, sysdate) 	 = nvl(t_key_date(i), sysdate);

            	 COMMIT;
             EXCEPTION WHEN OTHERS THEN
                 ROLLBACK;
                 LOG_MESSAGE('ERROR while updating msc_up_dem_entries using allocOnhand');
                 LOG_MESSAGE(SQLERRM);
                 RETCODE := G_ERROR;
             END;

             FOR i IN 1..t_plan_id.COUNT LOOP
			     a_supplier_update.EXTEND;
			     a_supplier_update(i) := SQL%BULK_ROWCOUNT(i);
             END LOOP;

	     BEGIN
	     /* sbala: Added update for Allocation type G_CUSTOMER
             * Keeping update separate to ensure indexes are used in update
	     ** If no performance hit, the SQL's can be merged
	     */
	     FORALL i in 1..t_plan_id.COUNT

                 update msc_sup_dem_entries
                     set quantity 	  = round(t_quantity(i), 6),
            	     bucket_type 	  = t_bkt_type(i),
            	     uom_code 	          = t_uom(i)     ,
            	     primary_uom 	  = t_pri_uom(i),
                     primary_quantity     = round(t_primary_quantity(i), 6),
		     key_date             = sysdate,
		     new_schedule_date    = sysdate,
                     last_refresh_number  = msc_cl_refresh_s.nextval ,
                     last_update_date     = l_sysdate,
                     last_updated_by	  = p_user_id,
                     tp_quantity	  = round(t_tp_quantity(i), 6),
                     tp_uom_code	  = t_tp_uom(i),
		     /* sbala added */
                     customer_item_name   = t_customer_item_name(i)
                 where   plan_id = G_PLAN_ID
                   and	 sr_instance_id 		 =  G_SR_INSTANCE_ID
                   and	 publisher_id 		   	 = t_pub_id(i)
            	   and	 publisher_site_id 		 = t_pub_site_id(i)
            	   and	 inventory_item_id 		 = t_item_id(i)
            	   and	 publisher_order_type 		 = t_pub_order_type(i)
                   /* sbala changes, keep t_supp_id, t_supp_site_id
		   ** variables itself since they are populate with
		   ** cust id from the SQL */
            	   and	 customer_id          		 = t_supp_id(i)
            	   and	 customer_site_id     		 = t_supp_site_id(i)
	           and   t_alloc_type(i) = G_CUSTOMER;
            	   --and	 nvl(bucket_type, G_NULL_STRING) = NVL(t_bkt_type(i), G_NULL_STRING)
            	   --and	 nvl(order_number, G_NULL_STRING)= NVL(t_ord_num(i), G_NULL_STRING)
            	   --and	 nvl(key_date, sysdate) 	 = nvl(t_key_date(i), sysdate);

            	 COMMIT;
             EXCEPTION WHEN OTHERS THEN
                 ROLLBACK;
                 LOG_MESSAGE('ERROR while updating msc_up_dem_entries using allocOnhand');
                 LOG_MESSAGE(SQLERRM);
                 RETCODE := G_ERROR;
             END;

             FOR i IN 1..t_plan_id.COUNT LOOP
                 a_customer_update.EXTEND;
                 a_customer_update(i) := SQL%BULK_ROWCOUNT(i);
             END LOOP;

             FOR i IN 1..t_plan_id.COUNT LOOP
			     a_resultant_update.EXTEND;
                 a_resultant_update(i) := a_supplier_update(i) + a_customer_update(i);
             END LOOP;

     END IF;

     --==========================================================
     -- Insert the fetched records if the records are new records
     --     Step 1. Extend the insert variables.
     --     Step 2. BULK insert.
     --==========================================================

     /* Initialize the count */

     a_ins_count := null;
     a_ins_count := number_arr();

     FOR i IN 1..t_plan_id.COUNT LOOP
         IF (a_resultant_update(i) = 0) THEN
             a_ins_count.EXTEND;
             --t_ins_transaction_id.EXTEND;
             t_ins_plan_id.EXTEND;
             t_ins_sr_instance_id.EXTEND;
             t_ins_pub_id.EXTEND;
	     t_ins_pub_site_id.EXTEND;
             t_ins_pub.EXTEND;
             t_ins_pub_site.EXTEND;
             --t_ins_new_sched_date.EXTEND;
             t_ins_item_id.EXTEND;
	     t_ins_base_item_id.EXTEND;
             t_ins_quantity.EXTEND;
             t_ins_comments.EXTEND;
             t_ins_pub_order_type.EXTEND;
             t_ins_supp_id.EXTEND;
             t_ins_supp.EXTEND;
             t_ins_supp_site_id.EXTEND;
             t_ins_supp_site.EXTEND;
             t_ins_bkt_type.EXTEND;
             --t_ins_ord_num.EXTEND;
             --t_ins_new_dock_date.EXTEND;
             t_ins_item_name.EXTEND;
	     t_ins_base_item_name.EXTEND;
             t_ins_item_desc.EXTEND;
             t_ins_ot_desc.EXTEND;
             t_ins_tp_ot_desc.EXTEND;
             t_ins_bkt_type_desc.EXTEND;
             t_ins_uom.EXTEND;
             --t_ins_created_by.EXTEND;
             --t_ins_creation_date.EXTEND;
             --t_ins_last_updated_by.EXTEND;
             --t_ins_last_update_date.EXTEND;
             --t_ins_key_date.EXTEND;
             t_ins_pri_uom.EXTEND;
             t_ins_primary_quantity.EXTEND;
     	     t_ins_vmi_flag.EXTEND;

    	     --==================================
    	     -- Extend the Item related variables
    	     --==================================

    	     t_ins_owner_item_name.EXTEND;
    	     t_ins_customer_item_name.EXTEND;
    	     t_ins_supplier_item_name.EXTEND;
    	     t_ins_owner_item_desc.EXTEND;
    	     t_ins_cust_item_desc.EXTEND;
    	     t_ins_tp_uom.EXTEND;
    	     t_ins_tp_quantity.EXTEND;
    	     t_ins_alloc_type.EXTEND;
			 t_ins_sup_item_desc.EXTEND;
			  t_ins_planner_code.EXTEND; --Bug 4424426

	     a_ins_count(a_ins_count.COUNT)	:= i;
             --t_ins_transaction_id(a_ins_count.COUNT)  := t_transaction_id(i);
             t_ins_plan_id(a_ins_count.COUNT)		:= t_plan_id(i)	;
             t_ins_sr_instance_id(a_ins_count.COUNT)	:= t_sr_instance_id(i);
             t_ins_pub_id(a_ins_count.COUNT)		:= t_pub_id(i);
	         t_ins_pub_site_id(a_ins_count.COUNT)	:= t_pub_site_id(i);
             t_ins_pub(a_ins_count.COUNT)		:= t_pub(i);
             t_ins_pub_site(a_ins_count.COUNT)	:= t_pub_site(i);
             --t_ins_new_sched_date(a_ins_count.COUNT)	:= t_new_sched_date(i);
             t_ins_item_id(a_ins_count.COUNT)		:= t_item_id(i);
	     t_ins_base_item_id(a_ins_count.COUNT)  := t_base_item_id(i);
             t_ins_quantity(a_ins_count.COUNT)	:= t_quantity(i);
             t_ins_comments(a_ins_count.COUNT)	:= t_comments(i);
             t_ins_pub_order_type(a_ins_count.COUNT)	:= t_pub_order_type(i);
             t_ins_supp_id(a_ins_count.COUNT)		:= t_supp_id(i);
	     t_ins_supp(a_ins_count.COUNT)   		:= t_supp(i);
	     t_ins_supp_site_id(a_ins_count.COUNT)    := t_supp_site_id(i);
	     t_ins_supp_site(a_ins_count.COUNT)       := t_supp_site(i);
     	     t_ins_bkt_type(a_ins_count.COUNT)   	:= t_bkt_type(i);
             --t_ins_ord_num(a_ins_count.COUNT)   	:= t_ord_num(i);
	     --t_ins_new_dock_date(a_ins_count.COUNT)   := t_new_dock_date(i);
	     t_ins_item_name(a_ins_count.COUNT)   	:= t_item_name(i);
	     t_ins_base_item_name(a_ins_count.COUNT) := t_base_item_name(i);
	     t_ins_item_desc(a_ins_count.COUNT)   	:= t_item_desc(i);
	     t_ins_ot_desc(a_ins_count.COUNT)   	:= t_ot_desc(i);
	     t_ins_tp_ot_desc(a_ins_count.COUNT)   	:= t_tp_ot_desc(i);
	     t_ins_bkt_type_desc(a_ins_count.COUNT)   := t_bkt_type_desc(i);
	     t_ins_uom(a_ins_count.COUNT)   		:= t_uom(i);
	     --t_ins_created_by(a_ins_count.COUNT)   	:= t_created_by(i);
	     --t_ins_creation_date(a_ins_count.COUNT)   := t_creation_date(i);
	     --t_ins_last_updated_by(a_ins_count.COUNT) := t_last_updated_by(i);
	     --t_ins_last_update_date(a_ins_count.COUNT):= t_last_update_date(i);
	     --t_ins_key_date(a_ins_count.COUNT)   	:= t_key_date(i);
	     t_ins_pri_uom(a_ins_count.COUNT)   	:= t_pri_uom(i);
	     t_ins_primary_quantity(a_ins_count.COUNT)  := t_primary_quantity(i);
    	     t_ins_customer_item_name(a_ins_count.COUNT) := t_customer_item_name(i);
             t_ins_owner_item_name(a_ins_count.COUNT)    := t_owner_item_name(i);
             t_ins_owner_item_desc(a_ins_count.COUNT)    := t_owner_item_desc(i);
    	     t_ins_cust_item_desc(a_ins_count.COUNT)     := t_cust_item_desc(i);
             t_ins_supplier_item_name(a_ins_count.COUNT) := t_supplier_item_name(i);
			 t_ins_sup_item_desc(a_ins_count.COUNT) := t_sup_item_desc(i);
			 /* Derive supplier item description */
			 if (t_ins_supplier_item_name(a_ins_count.COUNT) IS NOT NULL AND
					 t_ins_sup_item_desc(a_ins_count.COUNT) IS NULL) THEN
			     t_ins_sup_item_desc(a_ins_count.COUNT) := t_owner_item_desc(i);
			 end if;

	     t_ins_tp_uom(a_ins_count.COUNT) := t_tp_uom(i);
             t_ins_tp_quantity(a_ins_count.COUNT) := t_tp_quantity(i);
             t_ins_vmi_flag(a_ins_count.COUNT) := t_vmi_flag(i);
             t_ins_alloc_type(a_ins_count.COUNT) := t_alloc_type(i);

	      t_ins_planner_code(a_ins_count.COUNT) := t_planner_code(i); --Bug 4424426
         END IF;
     END LOOP;

    LOG_MESSAGE('Total records for insertion for Allocated Onhand:'||a_ins_count.COUNT);

     -- ==================
     -- Insert the records
     -- ==================
     IF a_ins_count.COUNT > 0 THEN

        BEGIN
            FORALL i IN 1..a_ins_count.COUNT
            INSERT INTO MSC_SUP_DEM_ENTRIES
            ( 	transaction_id,
              	plan_id,
              	sr_instance_id,
              	publisher_id,
              	publisher_site_id,
              	publisher_name,
              	publisher_site_name,
        	new_schedule_date       ,
        	inventory_item_id              ,
        	quantity,
        	comments,
        	publisher_order_type,
        	supplier_id,
        	supplier_name,
        	supplier_site_id,
        	supplier_site_name,
        	bucket_type,
        	--order_number,
        	--new_dock_date,
        	item_name,
        	ITEM_DESCRIPTION,
        	PUB_ITEM_DESCRIPTIION   ,
        	PUBLISHER_ORDER_TYPE_DESC,
        	tp_order_type_desc,
        	bucket_type_desc        ,
        	uom_code              ,
        	created_by,
        	creation_date,
        	last_updated_by,
        	last_update_date,
        	key_date,
        	primary_uom,
                primary_quantity,
                tp_uom_code,
                tp_quantity,
                customer_id,
                customer_site_id,
                customer_name,
                customer_site_name,
	        last_refresh_number,
	        supplier_item_name,
			owner_item_name,
			customer_item_name,
			supplier_item_description,
			owner_item_description,
			customer_item_description
            , vmi_flag
	    , base_item_id
	    , base_item_name
	    ,planner_code --Bug 4424426
            )
            values
            (    msc_sup_dem_entries_s.nextval,
        	 t_ins_plan_id(i),
        	 t_ins_sr_instance_id(i),
        	 t_ins_pub_id(i),
        	 t_ins_pub_site_id(i),
        	 t_ins_pub(i),
        	 t_ins_pub_site(i),
		 l_sysdate,        --new_schedule_date
        	 --t_ins_new_sched_date(i)      ,
        	 t_ins_item_id(i)              ,
        	 round(t_ins_quantity(i),6),
        	 t_ins_comments(i),
        	 t_ins_pub_order_type(i),
        	 DECODE(t_ins_alloc_type(i),
			            G_SUPPLIER, t_ins_supp_id(i),
			        t_ins_pub_id(i)),
        	 DECODE(t_ins_alloc_type(i),
			            G_SUPPLIER, t_ins_supp(i),
			        t_ins_pub(i)),
		     DECODE(t_ins_alloc_type(i),
			           G_SUPPLIER, t_ins_supp_site_id(i),
			       t_ins_pub_site_id(i)),
        	 DECODE(t_ins_alloc_type(i),
			            G_SUPPLIER, t_ins_supp_site(i),
			        t_ins_pub_site(i)),
        	 t_ins_bkt_type(i),
        	 --t_ins_ord_num(i),
        	 --t_ins_new_dock_date(i),
        	 t_ins_item_name(i),
        	 t_ins_item_desc(i)   ,
        	 t_ins_item_desc(i)   ,
        	 t_ins_ot_desc(i),
        	 t_tp_ot_desc(i),
        	 t_ins_bkt_type_desc(i)        ,
        	 t_ins_uom(i)              ,
        	 p_user_id,    --t_ins_created_by(i),
        	 l_sysdate,    --t_ins_creation_date(i),
        	 p_user_id,    --t_ins_last_updated_by(i),
        	 l_sysdate,    --t_ins_last_update_date(i),
        	 l_sysdate,    --Key Date -> It's SYSDATE for OnHand Type of Order Types.
        	 t_ins_pri_uom(i),
                 round(t_ins_primary_quantity(i),6),
                 t_ins_tp_uom(i),
                 round(t_ins_tp_quantity(i), 6),
		     DECODE(t_ins_alloc_type(i),
			            G_SUPPLIER, t_ins_pub_id(i),
			        t_ins_supp_id(i)),
		     DECODE(t_ins_alloc_type(i),
			            G_SUPPLIER, t_ins_pub_site_id(i),
			        t_ins_supp_site_id(i)),
        	 DECODE(t_ins_alloc_type(i),
			            G_SUPPLIER, t_ins_pub(i),
			        t_ins_supp(i)),
        	 DECODE(t_ins_alloc_type(i),
			            G_SUPPLIER, t_ins_pub_site(i),
			        t_ins_supp_site(i)),
	         msc_cl_refresh_s.nextval,
	         t_ins_supplier_item_name(i),
			 t_ins_owner_item_name(i),
			 t_ins_customer_item_name(i),
			 t_ins_sup_item_desc(i),
			 t_ins_owner_item_desc(i),
			 t_ins_cust_item_desc(i)
             , t_ins_vmi_flag(i)
	     , t_ins_base_item_id(i)
	     , t_ins_base_item_name(i)
	      , t_planner_code(i) --Bug 4424426
            );

            COMMIT;
        EXCEPTION WHEN OTHERS THEN
            LOG_MESSAGE('ERROR while inserting from allocOnhand to msc_sup_dem_entries ');
            LOG_MESSAGE(SQLERRM);
            ROLLBACK;
            RETCODE := G_ERROR;
        END;
     END IF;

    END IF;  -- if v_lrtype = ...

--=============================
-- Populate Sales Order Records
--=============================
    IF ((v_lrtype = 'C') OR
	    (v_lrtype = 'I') OR
	    (v_lrtype = 'P' AND p_so_enabled_flag = MSC_CL_COLLECTION.SYS_YES) OR
	    (v_lrtype = 'T' AND nvl(p_so_sn_flag, G_AUTO_NO_COLL) <> G_AUTO_NO_COLL)
		) THEN

    BEGIN
         OPEN salesOrders (v_so_refresh_number,
                           p_sr_instance_id,
                           l_language_code);
         FETCH salesOrders BULK COLLECT INTO
        --         t_transaction_id,
        	 t_plan_id,
        	 t_sr_instance_id,
        	 t_pub_id,
        	 t_pub_site_id,
        	 t_pub,
        	 t_pub_site,
        	 t_item_id              ,
        	 t_quantity,
        	 t_comments,
        	 t_pub_order_type,
        	 t_customer_id,
        	 t_customer_name,
        	 t_customer_site_id,
        	 t_customer_site_name,
        	 t_bkt_type,
        	 t_ord_num,
        	 t_line_num,
        	 t_ship_date,
        	 t_receipt_date,
        	 t_promise_date,
        	 t_item_name,
        	 t_item_desc   ,
        	 t_ot_desc,
        	 t_tp_ot_desc,
        	 t_bkt_type_desc        ,
        	 t_uom              ,
        	 t_created_by,
        	 t_creation_date,
        	 t_last_updated_by,
        	 t_last_update_date,
        	 t_key_date,
		 t_shipping_control,
        	 t_pri_uom,
                 t_primary_quantity,
                 t_partner_id,
	         t_partner_site_id,
       		 t_orig_sr_instance_id,
       		 t_organization_id,
	         t_base_item_id,
		 t_base_item_name,
		 t_end_order_number,
		 t_end_order_rel_number,
		 t_end_order_line_number,
                 t_end_ord_pub_id,
		 t_end_ord_pub_name,
		 t_end_ord_pub_site_id,
	         t_end_ord_pub_site_name,
		 t_end_pub_ord_type,
		 t_internal_flag,
		 t_supp_id,
		 t_supp_site_id,
		 t_supp,
		 t_supp_site,
		 t_planner_code; --Bug 4424426
         CLOSE salesOrders;
     EXCEPTION WHEN OTHERS THEN
         LOG_MESSAGE('Error while fetching records from salesOrders cusrsor');
         LOG_MESSAGE(SQLERRM);
         RETCODE := G_ERROR;
     END;

    LOG_MESSAGE('Total records fetched for Sales Orders :'||t_plan_id.COUNT);

     --===========================
     -- Update the fetched records
     --===========================

     IF t_plan_id.COUNT > 0 THEN

             BEGIN

             FORALL i in 1..t_plan_id.COUNT

                 update msc_sup_dem_entries
                     set quantity 	  = round(t_quantity(i), 6),
            	     bucket_type 	  = t_bkt_type(i),
            	     uom_code 	          = t_uom(i)     ,
            	     primary_uom 	  = t_pri_uom(i),
                     primary_quantity = round(t_primary_quantity(i), 6),
		     shipping_control     = t_shipping_control(i),
		     shipping_control_code     = decode(t_shipping_control(i),G_ARRIVE_CONTROL,1,
		                                                              2),
		     ship_date            = t_ship_date(i),
		     receipt_date         = t_receipt_date(i),
		     key_date             = t_key_date(i),
		     last_refresh_number = msc_cl_refresh_s.nextval,
	         end_order_number = t_end_order_number(i),
		 end_order_line_number = t_end_order_line_number(i),
		 end_order_rel_number = t_end_order_rel_number(i),
	         end_order_publisher_id = t_end_ord_pub_id(i),
	         end_order_publisher_site_id = t_end_ord_pub_site_id(i),
	         end_order_publisher_name = t_end_ord_pub_name(i),
                 end_order_publisher_site_name = t_end_ord_pub_site_name(i),
	         end_order_type = t_end_pub_ord_type(i),
		 internal_flag = t_internal_flag(i)
                 where   plan_id = G_PLAN_ID
                   and	 sr_instance_id 		 =  G_SR_INSTANCE_ID
                   and	 publisher_id 		   	 = t_pub_id(i)
            	   and	 publisher_site_id 		 = t_pub_site_id(i)
            	   and	 inventory_item_id 		 = t_item_id(i)
            	   and	 publisher_order_type 	 = t_pub_order_type(i)
            	   and	 customer_id          	 = t_customer_id(i)
            	   and	 customer_site_id     	 = t_customer_site_id(i)
            	   and	 nvl(bucket_type, G_NULL_STRING) = NVL(t_bkt_type(i), G_NULL_STRING)
            	   and	 nvl(order_number, G_NULL_STRING)= NVL(t_ord_num(i), G_NULL_STRING)
            	   and	 nvl(line_number, G_NULL_STRING)= NVL(t_line_num(i), G_NULL_STRING)
            	   --and	 nvl(key_date, sysdate) 	 = nvl(t_key_date(i), sysdate)
		   ;

            	   COMMIT;
             EXCEPTION WHEN OTHERS THEN
                 ROLLBACK;
                 LOG_MESSAGE('ERROR while updating msc_up_dem_entries using Sales Orders');
                 LOG_MESSAGE(SQLERRM);
                 RETCODE := G_ERROR;
             END;

     END IF;

     --==========================================================
     -- Insert the fetched records if the records are new records
     --     Step 1. Extend the insert variables.
     --     Step 2. BULK insert.
     --==========================================================

     /* Initialize the count */

     a_ins_count := null;
     a_ins_count := number_arr();

     FOR i IN 1..t_plan_id.COUNT LOOP
         IF (SQL%BULK_ROWCOUNT(i) = 0) THEN
             a_ins_count.EXTEND;
			 t_ins_transaction_id.EXTEND;
			 t_ins_plan_id.EXTEND;
			 t_ins_sr_instance_id.EXTEND;
			 t_ins_pub_id.EXTEND;
			 t_ins_pub_site_id.EXTEND;
			 t_ins_pub.EXTEND;
			 t_ins_pub_site.EXTEND;
			 t_ins_item_id.EXTEND;
	                 t_ins_base_item_id.EXTEND;
			 t_ins_quantity.EXTEND;
			 t_ins_comments.EXTEND;
			 t_ins_pub_order_type.EXTEND;
			 t_ins_customer_id.EXTEND;
			 t_ins_customer_name.EXTEND;
			 t_ins_customer_site_id.EXTEND;
             		 t_ins_customer_site_name.EXTEND;
			 t_ins_bkt_type.EXTEND;
			 t_ins_ord_num.EXTEND;
			 t_ins_line_num.EXTEND;
			 t_ins_ship_date.EXTEND;
                         t_ins_receipt_date.EXTEND;
                         t_ins_promise_date.EXTEND;
                         t_ins_item_name.EXTEND;
	                 t_ins_base_item_name.EXTEND;
                         t_ins_item_desc.EXTEND;
                         t_ins_ot_desc.EXTEND;
                         t_ins_tp_ot_desc.EXTEND;
                         t_ins_bkt_type_desc.EXTEND;
                         t_ins_uom.EXTEND;
                         t_ins_created_by.EXTEND;
                         t_ins_creation_date.EXTEND;
                         t_ins_last_updated_by.EXTEND;
                         t_ins_last_update_date.EXTEND;
                         t_ins_key_date.EXTEND;
                         t_ins_pri_uom.EXTEND;
                         t_ins_primary_quantity.EXTEND;
                         t_ins_tp_uom.EXTEND;
                         t_ins_tp_quantity.EXTEND;
			 t_ins_end_ord_num.EXTEND;
			 t_ins_end_ord_line_num.EXTEND;
			 t_ins_end_ord_rel_num.EXTEND;
			 t_ins_internal_flag.EXTEND;
			 t_ins_end_ord_pub_id.EXTEND;
			 t_ins_end_ord_pub_name.EXTEND;
			 t_ins_end_ord_pub_site_id.EXTEND;
			 t_ins_end_ord_pub_site_name.EXTEND;
			 t_ins_end_pub_ord_type.EXTEND;
			 t_ins_supp.EXTEND;
                         t_ins_supp_id.EXTEND;
			 t_ins_supp_site_id.EXTEND;
			 t_ins_supp_site.EXTEND;
			 t_ins_shipping_control.EXTEND;
			 t_ins_shipping_control_code.EXTEND;
			 t_ins_end_ord_type_desc.EXTEND;
			  t_ins_planner_code.EXTEND; --Bug 4424426

                 a_ins_count(a_ins_count.COUNT)	:= i;
                 --t_ins_transaction_id(a_ins_count.COUNT):= t_transaction_id(i);
                 t_ins_plan_id(a_ins_count.COUNT)	:= t_plan_id(i);
                 t_ins_sr_instance_id(a_ins_count.COUNT):= t_sr_instance_id(i);
                 t_ins_pub_id(a_ins_count.COUNT)	:= t_pub_id(i);
                 t_ins_pub_site_id(a_ins_count.COUNT)	:= t_pub_site_id(i);
                 t_ins_pub(a_ins_count.COUNT)		:= t_pub(i);
                 t_ins_pub_site(a_ins_count.COUNT)	:= t_pub_site(i);
                 t_ins_item_id(a_ins_count.COUNT)	:= t_item_id(i);
	         t_ins_base_item_id(a_ins_count.COUNT)  :=
						     t_base_item_id(i);
                 t_ins_quantity(a_ins_count.COUNT)	:= t_quantity(i);
                 t_ins_comments(a_ins_count.COUNT)	:= t_comments(i);
                 t_ins_pub_order_type(a_ins_count.COUNT):= t_pub_order_type(i);
                 t_ins_customer_id(a_ins_count.COUNT)	:= t_customer_id(i);
                 t_ins_customer_name(a_ins_count.COUNT) := t_customer_name(i);
                 t_ins_customer_site_id(a_ins_count.COUNT):= t_customer_site_id(i);
                 t_ins_customer_site_name(a_ins_count.COUNT):= t_customer_site_name(i);
                 t_ins_bkt_type(a_ins_count.COUNT)	:= t_bkt_type(i);
                 t_ins_ord_num(a_ins_count.COUNT)	:= t_ord_num(i);
                 t_ins_line_num(a_ins_count.COUNT) 	:= t_line_num(i);
                 t_ins_ship_date(a_ins_count.COUNT)	:= t_ship_date(i);
                 t_ins_receipt_date(a_ins_count.COUNT)	:= t_receipt_date(i);
                 t_ins_promise_date(a_ins_count.COUNT)	:= t_promise_date(i);
                 t_ins_item_name(a_ins_count.COUNT) 	:= t_item_name(i);
	         t_ins_base_item_name(a_ins_count.COUNT) :=
							t_base_item_name(i);
                 t_ins_item_desc(a_ins_count.COUNT) 	:= t_item_desc(i);
                 t_ins_ot_desc(a_ins_count.COUNT)	:= t_ot_desc(i);
                 t_ins_tp_ot_desc(a_ins_count.COUNT) 	:= t_tp_ot_desc(i);
                 t_ins_bkt_type_desc(a_ins_count.COUNT)	:= t_bkt_type_desc(i);
                 t_ins_uom(a_ins_count.COUNT) 		:= t_uom(i);
                 t_ins_created_by(a_ins_count.COUNT) 	:= t_created_by(i);
                 t_ins_creation_date(a_ins_count.COUNT)	:= t_creation_date(i);
                 t_ins_last_updated_by(a_ins_count.COUNT):= t_last_updated_by(i);
                 t_ins_last_update_date(a_ins_count.COUNT):= t_last_update_date(i);
                 t_ins_key_date(a_ins_count.COUNT) 	:= t_key_date(i);
                 t_ins_pri_uom(a_ins_count.COUNT)	:= t_pri_uom(i);
                 t_ins_primary_quantity(a_ins_count.COUNT):= t_primary_quantity(i);
	 t_ins_end_ord_num(a_ins_count.COUNT) := t_end_order_number(i);
	 t_ins_end_ord_line_num(a_ins_count.COUNT) :=
						t_end_order_line_number(i);
	 t_ins_end_ord_rel_num(a_ins_count.COUNT) := t_end_order_rel_number(i);
	 t_ins_end_ord_pub_id(a_ins_count.COUNT) :=
                                        t_end_ord_pub_id(i);

         t_ins_end_ord_pub_name(a_ins_count.COUNT) :=
                                        t_end_ord_pub_name(i);

         t_ins_end_ord_pub_site_id(a_ins_count.COUNT) :=
                                t_end_ord_pub_site_id(i);

         t_ins_end_ord_pub_site_name(a_ins_count.COUNT) :=
				t_end_ord_pub_site_name(i);

	 t_ins_end_pub_ord_type(a_ins_count.COUNT) :=
				t_end_pub_ord_type(i);

         t_ins_internal_flag(a_ins_count.COUNT) :=
				t_internal_flag(i);

	 t_ins_supp_id(a_ins_count.COUNT) := t_supp_id(i);
         t_ins_supp(a_ins_count.COUNT) := t_supp(i);
         t_ins_supp_site_id(a_ins_count.COUNT) := t_supp_site_id(i);
	 t_ins_supp_site(a_ins_count.COUNT) := t_supp_site(i);
	 t_ins_shipping_control(a_ins_count.COUNT) := t_shipping_control(i);

	  t_ins_planner_code(a_ins_count.COUNT) := t_planner_code(i); --Bug 4424426


	 if (t_shipping_control(a_ins_count.COUNT) = G_ARRIVE_CONTROL) then
	            /* arrive */
	       t_ins_shipping_control_code(a_ins_count.COUNT) := 1;
         else
	            /* ship */
	       t_ins_shipping_control_code(a_ins_count.COUNT) := 2;
         end if;

	 if (t_ins_end_pub_ord_type(a_ins_count.COUNT) = G_PO) then
	        /* if end order type = PO */
	       t_ins_end_ord_type_desc(a_ins_count.COUNT) := G_PO_DESC;
	 elsif (t_ins_end_pub_ord_type(a_ins_count.COUNT) = G_REQ) then
	        /* if end order type = Req */
	       t_ins_end_ord_type_desc(a_ins_count.COUNT) := G_REQ_DESC;
	 else
	       t_ins_end_ord_type_desc(a_ins_count.COUNT) := null;

	 end if;

    		--==================================
    		-- Extend the Item related variables
    		--==================================

    		t_ins_owner_item_name.EXTEND;
    		t_ins_customer_item_name.EXTEND;
    		t_ins_supplier_item_name.EXTEND;
    		t_ins_owner_item_desc.EXTEND;
    		t_ins_cust_item_desc.EXTEND;
    		t_ins_sup_item_desc.EXTEND;

    		--============================================
    		-- Derive the Item cross reference information
    		--============================================

    		   --====================
    		   -- Initialize variable
    		   --====================
    		   l_customer_item_name	:= null;
    		   l_customer_item_desc := null;
    		   l_lead_time := 0;
    		   l_tp_uom := null;

    		   t_ins_supplier_item_name(a_ins_count.COUNT) := t_item_name(i);
    		   t_ins_owner_item_name(a_ins_count.COUNT) := t_item_name(i);
    		   t_ins_owner_item_desc(a_ins_count.COUNT) := t_item_desc(i);
    		   t_ins_sup_item_desc(a_ins_count.COUNT) := t_item_desc(i);

    		   BEGIN

    		   select customer_item_name,
    		          description,
    		          uom_code
    		     into l_customer_item_name,
    		     	  l_customer_item_desc,
    		     	  l_tp_uom
    		   from  msc_item_customers mic
    		   where mic.plan_id = G_PLAN_ID
    		   and   mic.inventory_item_id = t_item_id(i)
    		   and   mic.customer_id       = t_partner_id(i)
    		   and   nvl(mic.customer_site_id, -99) = decode(mic.customer_site_id,
    		   					     null, -99,
    		   					     t_partner_site_id(i));

		   EXCEPTION WHEN OTHERS THEN
		       l_customer_item_name := null;
		       l_customer_item_desc := null;
		       l_tp_uom := null;
		   END;

		   t_ins_customer_item_name(a_ins_count.COUNT) := l_customer_item_name;
		   t_ins_cust_item_desc(a_ins_count.COUNT) := l_customer_item_desc;
		   t_ins_tp_uom(a_ins_count.COUNT) := nvl(l_tp_uom, t_uom(i));

	       --===============================================
	       -- Get the conversion rate and derive tp_quantity
	       --===============================================
	       msc_x_util.get_uom_conversion_rates(
	           t_uom(i),
	           t_ins_tp_uom(a_ins_count.COUNT),
	           t_item_id(i),
	           l_conversion_found,
	           l_conversion_rate);

	       IF (l_conversion_found) THEN
	           t_ins_tp_quantity(a_ins_count.COUNT) := t_quantity(i) * nvl(l_conversion_rate, 1);
	       ELSE
	           t_ins_tp_quantity(a_ins_count.COUNT) := t_quantity(i);
	       END IF;

         END IF; -- (SQL%BULK_ROWCOUNT(i) = 0)
     END LOOP;

    LOG_MESSAGE('Total records for insertion for Sales Orders:'||a_ins_count.COUNT);

     -- ==================
     -- Insert the records
     -- ==================
     IF a_ins_count.COUNT > 0 THEN
        BEGIN
            FORALL i IN 1..a_ins_count.COUNT
            INSERT INTO MSC_SUP_DEM_ENTRIES
            (
                 transaction_id,
                 plan_id	,
                 sr_instance_id ,
                 publisher_id	,
                 publisher_site_id	,
                 publisher_name		,
                 publisher_site_name	,
                 inventory_item_id	,
                 quantity	,
                 comments	,
                 publisher_order_type,
                 customer_id	,
                 customer_name ,
                 customer_site_id,
                 customer_site_name,
                 bucket_type	,
                 order_number	,
                 line_number 	,
                 ship_date	,
                 receipt_date	,
                 promise_ship_date	,
                 item_name 	,
                 pub_item_description 	,
                 publisher_order_type_desc	,
                 tp_order_type_desc 	,
                 bucket_type_desc	,
                 uom_code 		,
                 created_by 	,
                 creation_date	,
                 last_updated_by,
                 last_update_date,
                 key_date 	,
		 shipping_control,
		 shipping_control_code,
                 primary_uom	,
                 primary_quantity,
                 owner_item_name,
                 supplier_item_name,
                 customer_item_name,
                 item_description,
                 owner_item_description,
                 supplier_item_description,
                 customer_item_description,
                 supplier_id,
                 supplier_site_id,
                 supplier_name,
                 supplier_site_name,
		 last_refresh_number,
		 tp_uom_code,
		 tp_quantity,
		 base_item_id,
		 base_item_name,
		 end_order_number,
		 end_order_line_number,
		 end_order_rel_number,
		 end_order_publisher_id,
		 end_order_publisher_site_id,
		 end_order_publisher_name,
		 end_order_publisher_site_name,
		 end_order_type,
		 end_order_type_desc,
	         internal_flag,
		 planner_code --Bug 4424426
             )
            values
            (
                 msc_sup_dem_entries_s.nextval,
                 t_ins_plan_id(i)	,
                 t_ins_sr_instance_id(i),
                 t_ins_pub_id(i)	,
                 t_ins_pub_site_id(i)	,
                 t_ins_pub(i)		,
                 t_ins_pub_site(i)	,
                 t_ins_item_id(i)	,
                 round(t_ins_quantity(i), 6)	,
                 t_ins_comments(i)	,
                 t_ins_pub_order_type(i),
                 t_ins_customer_id(i)	,
                 t_ins_customer_name(i) ,
                 t_ins_customer_site_id(i),
                 t_ins_customer_site_name(i),
                 t_ins_bkt_type(i)	,
                 t_ins_ord_num(i)	,
                 t_ins_line_num(i) 	,
                 t_ins_ship_date(i)	,
                 t_ins_receipt_date(i)	,
                 t_ins_promise_date(i)	,
                 t_ins_item_name(i) 	,
                 t_ins_item_desc(i) 	,
                 t_ins_ot_desc(i)	,
                 t_ins_tp_ot_desc(i) 	,
                 t_ins_bkt_type_desc(i)	,
                 t_ins_uom(i) 		,
                 t_ins_created_by(i) 	,
                 t_ins_creation_date(i)	,
                 t_ins_last_updated_by(i),
                 t_ins_last_update_date(i),
                 t_ins_key_date(i) 	,
		 t_ins_shipping_control(i),
		 t_ins_shipping_control_code(i),
                 t_ins_pri_uom(i)	,
                 round(t_ins_primary_quantity(i), 6),
                 t_ins_owner_item_name(i),
                 t_ins_supplier_item_name(i),
                 t_ins_customer_item_name(i),
                 t_ins_item_desc(i),
                 t_ins_owner_item_desc(i),
                 t_ins_sup_item_desc(i),
                 t_ins_cust_item_desc(i),
                 t_ins_supp_id(i), ---- t_ins_pub_id(i)	,
                 t_ins_supp_site_id(i)	,
                 t_ins_supp(i)		,
                 t_ins_supp_site(i)  ,
		 msc_cl_refresh_s.nextval,
		 t_ins_tp_uom(i),
		 round(t_ins_tp_quantity(i), 6),
	         t_ins_base_item_id(i),
		 t_ins_base_item_name(i),
		 t_ins_end_ord_num(i),
	         t_ins_end_ord_line_num(i),
		 t_ins_end_ord_rel_num(i),
		 t_ins_end_ord_pub_id(i),
		 t_ins_end_ord_pub_site_id(i),
		 t_ins_end_ord_pub_name(i),
		 t_ins_end_ord_pub_site_name(i),
		 t_ins_end_pub_ord_type(i),
		 t_ins_end_ord_type_desc(i),
		 t_ins_internal_flag(i),
		 t_ins_planner_code(i) --Bug 4424426
             );

             COMMIT;
        EXCEPTION WHEN OTHERS THEN
            LOG_MESSAGE('ERROR while inserting from Sales orders to msc_sup_dem_entries ');
            LOG_MESSAGE(SQLERRM);
            ROLLBACK;
            RETCODE := G_ERROR;
        END;
     END IF;

	    /* Update the pegging information for internal sales orders / internal reqs */
            BEGIN

             FORALL i in 1..t_plan_id.COUNT

	 	 update msc_sup_dem_entries sd
		 set link_trans_id = t_line_num(i)
		 where sd.plan_id = G_PLAN_ID
		 and   sd.sr_instance_id = G_SR_INSTANCE_ID
		 and   sd.inventory_item_id = t_item_id(i)
		 and   sd.customer_id = t_customer_id(i)
		 and   sd.customer_site_id = t_customer_site_id(i)
		 and   sd.supplier_id = t_pub_id(i)
		 and   sd.supplier_site_id = t_pub_site_id(i)
		 and   sd.publisher_order_type = G_REQ
		 and   sd.internal_flag = SYS_YES
	      	 and   sd.order_number = t_end_order_number(i)
                 and   nvl(sd.line_number, '-1')  =
					nvl(t_end_order_line_number(i), '-1')
                 and   nvl(sd.release_number, '-1')  =
					nvl(t_end_order_rel_number(i), '-1')
                 and   sd.customer_id = t_end_ord_pub_id(i)
                 and   sd.customer_site_id = t_end_ord_pub_site_id(i)
                 and   sd.publisher_order_type = t_end_pub_ord_type(i)
		 and   t_internal_flag(i) = SYS_YES;


                LOG_MESSAGE('updating pegging info for int reqs 1');
		 COMMIT;
                 EXCEPTION WHEN OTHERS THEN
                 ROLLBACK;
                LOG_MESSAGE('ERROR while updating pegging info for int reqs 1');

                 LOG_MESSAGE(SQLERRM);
                 RETCODE := G_ERROR;

	    END;
	 END IF;  -- if v_lrtype ...

--===============================================================================
-- After processing Sales Orders, we need to Collect PO Acknowledgment records as
-- Supplier Sales Orders.
--
-- For Automatic collections, we will manipulate v_lrtype depending on parameters
-- so that we can call following API in targeted or Net change mode.
--===============================================================================

    IF ((v_lrtype = 'C') OR
        (v_lrtype = 'I') OR
        (v_lrtype = 'P' AND p_sup_resp_flag = MSC_CL_COLLECTION.SYS_YES) OR
        (v_lrtype = 'T' AND nvl(p_suprep_sn_flag, G_AUTO_NO_COLL) <> G_AUTO_NO_COLL)
        ) THEN

	    IF (v_lrtype = 'T' and nvl(p_suprep_sn_flag, G_AUTO_NO_COLL) <> G_AUTO_NO_COLL) THEN

			IF (nvl(p_suprep_sn_flag, G_AUTO_NO_COLL) = G_AUTO_NET_COLL) THEN
                v_lrtype := 'I';
            ELSIF (nvl(p_suprep_sn_flag, G_AUTO_NO_COLL) = G_AUTO_TAR_COLL) THEN
				v_lrtype := 'P';
			END IF;

		END IF;

		LOG_MESSAGE('Collection mode for Supplier Responses in Collaboration ODS Load : '||v_lrtype);


	    MSC_CL_SUPPLIER_RESP.PUBLISH_SUPPLIER_RESPONSE( v_suprep_refresh_number,
	    												p_sr_instance_id,
	    												a_ack_return_status,
	    												v_lrtype,
	    												p_user_id,
	    												v_in_org_str
	    										  	   );

	    IF (a_ack_return_status = FALSE) THEN
	        LOG_MESSAGE('Error while publishing PO Acknowledgment Records');
	        RETCODE := G_ERROR;
	    END IF;

	END IF; -- IF ((v_lrtype = 'C')......


---=====================PRAGNESH=================================

   if (p_so_enabled_flag = MSC_CL_COLLECTION.SYS_YES ) then

      /* PS: added code to initialize the variables  */

    t_pub                      := msc_sce_loads_pkg.publisherList();
    t_pub_site		       := msc_sce_loads_pkg.pubsiteList();
    t_pub_site_id	       := msc_sce_loads_pkg.pubsiteidList();
    t_pub_id		       := msc_sce_loads_pkg.publishidList();
    t_supp_id		       := msc_sce_loads_pkg.suppidList();
    t_supp		       := msc_sce_loads_pkg.supplierList();
    t_supp_site_id	       := msc_sce_loads_pkg.suppsiteidList();
    t_supp_site		       := msc_sce_loads_pkg.suppsiteList();
    t_item_id		       := msc_sce_loads_pkg.itemidList();
    t_quantity		       := msc_sce_loads_pkg.qtyList();
    t_receipt_date	       := msc_sce_loads_pkg.receiptdateList();
    t_line_num		       := msc_sce_loads_pkg.linenumList();
    t_shipto_id		       := msc_sce_loads_pkg.shiptoidList();
    t_shipto_site_id	       := msc_sce_loads_pkg.shiptosidList();
    t_shipto		       := msc_sce_loads_pkg.shiptoList();
    t_shipto_site	       := msc_sce_loads_pkg.shiptositeList();
    t_shipfrom_id	       := msc_sce_loads_pkg.shipfromidList();
    t_shipfrom_site_id	       := msc_sce_loads_pkg.shipfromsidList();
    t_shipfrom		       := msc_sce_loads_pkg.shipfromList();
    t_shipfrom_site	       := msc_sce_loads_pkg.shipfromsiteList();
    t_item_name		       := msc_sce_loads_pkg.itemList();
    t_item_desc		       := msc_sce_loads_pkg.itemdescList();
    t_uom		       := msc_sce_loads_pkg.uomList();
    t_key_date		       := msc_sce_loads_pkg.newschedList();
    t_ord_num		       := msc_sce_loads_pkg.ordernumList();
    t_end_order_number	       := msc_sce_loads_pkg.ordernumList();
    t_end_order_line_number    := msc_sce_loads_pkg.linenumList();

    t_planner_code    := msc_sce_loads_pkg.plannerCode();--Bug 4424426

	        LOG_MESSAGE('Writing the lv_sql_stmt ');
	  /*  lv_sql_stmt := 'select  1 '||
		'      ,mcsil.company_site_id      '||
		'       ,mc.company_name            '||
		'       ,mcs.company_site_name      '||
		'       ,msi.inventory_item_id      '||
		'       ,mavv.shipped_quantity      '||
		'       ,mavv.ultimate_dropoff_date receipt_date'||
		'       ,mc.company_id              '||
		'       ,mc.company_name            '||
		'       ,mcsil.company_site_id      '||
		'       ,mcs.company_site_name      '||
		'       ,mavv.delivery_name         '||
		'       ,mcr.object_id              '||
		'       ,mc1.company_name           '||
		'       ,mcs1.company_site_id       '||
		'       ,mcs1.company_site_name     '||
		'       ,mc.company_id              '||
		'       ,mc.company_name            '||
		'       ,mcsil.company_site_id      '||
		'       ,mcs.company_site_name      '||
		'       ,msi.item_name              '||
		'       ,msi.description            '||
		'       ,msi.uom_code		   '||
		'       ,mavv.ultimate_dropoff_date '||
		'       ,nvl(asn.SOURCE_DELIVERY_ID,-999999) '||
		'       ,mavv.DELIVERY_ID         SOURCE_DELIVERY_ID'||
		'       ,to_char(null) ' ||
		'       ,to_char(null) ' ||
		'       ,mavv.status_code '||
		'       ,msi.planner_code '||
		' from msc_system_items         msi   ,'||
		'     msc_trading_partners      mtp   ,'||
		'     msc_company_site_id_lid   mcsil ,'||
		'     msc_company_sites         mcs   ,'||
		'     msc_companies             mc    ,'||
		'     msc_sup_dem_entries       asn   ,'||
		'     msc_company_relationships mcr   ,'||
		'     msc_trading_partner_maps  mtpm  ,'||
		'     msc_companies             mc1   ,'||
		'     msc_company_sites         mcs1  ,'||
		'     msc_trading_partners      mtp1   ,'||
		'     msc_trading_partner_maps  mtpm1  ,'||
		'     mrp_ap_vmi_intransits_v'||v_sr_dblink ||'  mavv '||
		' where mtp.partner_type = 3 '||
		' and mtp.sr_instance_id = '||p_sr_instance_id||
		' and mtp.modeled_customer_id is not null  '||
		' and mtp.modeled_customer_site_id is not null '||
		' and msi.sr_instance_id = mtp.sr_instance_id'||
		' and msi.plan_id = -1'||
		' and msi.organization_id = mtp.sr_tp_id'||
		' and msi.sr_inventory_item_id = mavv.inventory_item_id'||
		' and msi.INVENTORY_PLANNING_CODE = 7'||
		' and msi.CONSIGNED_FLAG = 2'||
		' and mtp.sr_tp_id = mavv.destination_organization_id'||
		' and asn.source_DELIVERY_ID(+) = mavv.delivery_id'||
		' and asn.source_DELIVERY_ID is null '||
		' and asn.publisher_order_type(+) = 15'||
		' and mavv.status_code = ''IT'''||
		' and mavv.CONSIGNED_FLAG = 2 '||
		' and mtp1.sr_tp_id = mavv.source_organization_id '||
		' and mtp1.sr_instance_id = mtp.sr_instance_id ' ||
		' and mtp1.partner_type = mtp.partner_type '||
		' and mtp1.sr_tp_id = mcsil.sr_company_site_id'||
		' and mtp1.sr_instance_id  = mcsil.sr_instance_id'||
		' and mcsil.partner_type = 3 '||
		' and mcsil.sr_company_id = -1 '||
		' and mcsil.company_site_id = mcs.company_site_id'||
		' and mcs.company_id = mc.company_id'||
		' and mcs.company_id = 1 '||
		' and mtp.modeled_customer_id    = mtpm.tp_key'||
		' and mtpm.map_type        = 1'||
		' and mtpm.company_key     = mcr.relationship_id'||
		' and mcr.object_id        = mc1.company_id'||
		' and nvl(mtp.modeled_customer_site_id, -99) = mtpm1.tp_key'||
		' and mtpm1.map_type       = 3'||
		' and mtpm1.company_key    = mcs1.company_site_id'||
		'  union all '||
                ' select 1 '||
		'       ,mcsil.company_site_id    '||
		'       ,mc.company_name          '||
		'       ,mcs.company_site_name    '||
		'       ,msi.inventory_item_id    '||
		'       ,mavv.shipped_quantity    '||
		'       ,mavv.ultimate_dropoff_date  receipt_date'||
		'       ,mc.company_id           '||
		'       ,mc.company_name         '||
		'       ,mcsil.company_site_id   '||
		'       ,mcs.company_site_name   '||
		'       ,mavv.delivery_name      '||
		'      ,mcr.object_id            '||
		'      ,mc1.company_name         '||
		'      ,mcs1.company_site_id   '||
		'      ,mcs1.company_site_name '||
		'       ,mc.company_id         '||
		'      , mc.company_name       '||
		'      , mcsil.company_site_id '||
		'      , mcs.company_site_name     '||
		'      ,msi.item_name            '||
		'       ,msi.description         '||
		'       ,msi.uom_code		'||
		'      ,mavv.ultimate_dropoff_date '||
		'       ,asn.SOURCE_DELIVERY_ID '||
		'       ,mavv.DELIVERY_ID  source_delivery_id'||
		'       ,to_char(null) ' ||
		'       ,to_char(null) ' ||
		'       ,mavv.status_code '||
		'       ,msi.planner_code '||
		' from msc_system_items  msi,'||
		'     msc_trading_partners mtp,'||
		'     msc_company_site_id_lid mcsil,'||
		'     msc_company_sites   mcs,'||
		'     msc_companies  mc,'||
		'     msc_sup_dem_entries  asn,'||
		'     msc_company_relationships mcr,'||
		'     msc_trading_partner_maps  mtpm,'||
		'     msc_companies  mc1,'||
		'     msc_company_sites   mcs1,'||
		'     msc_trading_partners      mtp1   ,'||
		'     msc_trading_partner_maps  mtpm1,'||
		'     mrp_ap_vmi_intransits_v'||v_sr_dblink ||'   mavv'||
		' where mtp.partner_type = 3'||
		' and mtp.sr_instance_id = '||p_sr_instance_id||
		' and mtp.modeled_customer_id is not null '||
		' and mtp.modeled_customer_site_id is not null '||
		' and msi.sr_instance_id = mtp.sr_instance_id'||
		' and msi.plan_id = -1'||
		' and msi.INVENTORY_PLANNING_CODE = 7'||
		' and msi.CONSIGNED_FLAG = 2'||
		' and mavv.CONSIGNED_FLAG = 2 '||
		' and msi.organization_id = mtp.sr_tp_id'||
		' and msi.sr_inventory_item_id = mavv.inventory_item_id'||
		' and mtp.sr_tp_id = mavv.destination_organization_id'||
		' and asn.SOURCE_DELIVERY_ID = mavv.DELIVERY_ID'||
		' and asn.publisher_order_type = 15'||
		' and (asn.quantity <> mavv.shipped_quantity'||
		'      or trunc(asn.key_date) <> trunc(mavv.ultimate_dropoff_date)'||
		'      or mavv.status_code <> ''IT'' )'||
		' and mtp1.sr_tp_id = mavv.source_organization_id '||
		' and mtp1.sr_instance_id = mtp.sr_instance_id ' ||
		' and mtp1.partner_type = mtp.partner_type '||
		' and mtp1.sr_tp_id = mcsil.sr_company_site_id'||
		' and mtp1.sr_instance_id  = mcsil.sr_instance_id'||
		' and mcsil.partner_type = 3 '||
		' and mcsil.sr_company_id = -1  '||
		' and mcsil.company_site_id = mcs.company_site_id'||
		' and mcs.company_id = mc.company_id'||
		'  and mcs.company_id = 1 '||
		' and mtp.modeled_customer_id    = mtpm.tp_key'||
		' and mtpm.map_type        = 1'||
		' and mtpm.company_key     = mcr.relationship_id'||
		' and mcr.object_id        = mc1.company_id'||
		' and nvl(mtp.modeled_customer_site_id, -99) = mtpm1.tp_key'||
		' and mtpm1.map_type       = 3'||
		' and mtpm1.company_key    = mcs1.company_site_id ' ||
		' union all  ' ||
		' select 1 '||
		'       ,mcsil.company_site_id      '||
		'       ,mc.company_name            '||
		'       ,mcs.company_site_name      '||
		'       ,msi.inventory_item_id      '||
		'       ,mavv.shipped_quantity      '||
		'       ,mavv.ultimate_dropoff_date '||
		'       ,mc.company_id              '||
		'       ,mc.company_name            '||
		'       ,mcsil.company_site_id      '||
		'       ,mcs.company_site_name      '||
		'       ,mavv.delivery_name         '||
		'       ,mcr.object_id              '||
		'       ,mc1.company_name           '||
		'       ,mcs1.company_site_id       '||
		'       ,mcs1.company_site_name     '||
		'       ,mc.company_id              '||
		'       ,mc.company_name            '||
		'       ,mcsil.company_site_id      '||
		'       ,mcs.company_site_name      '||
		'       ,msi.item_name              '||
		'       ,msi.description            '||
		'       ,msi.uom_code		    '||
		'       ,mavv.ultimate_dropoff_date '||
		'       ,nvl(asn.SOURCE_DELIVERY_ID,-999999) '||
		'       ,mavv.DELIVERY_ID          '||
		'       ,mavv.req_order_number ' ||
		'       ,to_char(mavv.req_line_number) ' ||
		'       ,mavv.status_code  '||
		'       ,msi.planner_code '||
		' from mrp_ap_vmi_intransits_v'||v_sr_dblink ||'   mavv, '||
		'     msc_system_items          msi,'||
		'     msc_trading_partners      mtp,'||
		'     msc_company_site_id_lid   mcsil,'||
		'     msc_company_sites         mcs,'||
		'     msc_companies             mc,'||
		'     msc_sup_dem_entries       asn,'||
		'     msc_company_relationships mcr,'||
		'     msc_trading_partner_maps  mtpm,'||
		'     msc_companies             mc1,'||
		'     msc_company_sites         mcs1,'||
		'     msc_trading_partners      mtp1   ,'||
		'     msc_trading_partner_maps  mtpm1'||
		' where mtp.partner_type = 3'||
		' and mtp.sr_instance_id = '||p_sr_instance_id||
		' and mtp.modeled_customer_id is not null'||
		' and mtp.modeled_customer_site_id is not null'||
		' and msi.sr_instance_id = mtp.sr_instance_id'||
		' and msi.plan_id = -1'||
		' and msi.CONSIGNED_FLAG = 1'||
		' and msi.INVENTORY_PLANNING_CODE = 7'||
		' and msi.organization_id = mtp.sr_tp_id'||
		' and msi.sr_inventory_item_id = mavv.inventory_item_id'||
		' and mtp.sr_tp_id = mavv.destination_organization_id'||
		' and asn.source_DELIVERY_ID(+) = mavv.delivery_id'||
		' and asn.source_DELIVERY_ID is null'||
		' and asn.publisher_order_type(+) = 15'||
		' and mavv.status_code = ''IT'''||
		' and mavv.CONSIGNED_FLAG = 1'||
		' and mtp1.sr_tp_id = mavv.source_organization_id '||
		' and mtp1.sr_instance_id = mtp.sr_instance_id ' ||
		' and mtp1.partner_type = mtp.partner_type '||
		' and mtp1.sr_tp_id = mcsil.sr_company_site_id'||
		' and mtp1.sr_instance_id  = mcsil.sr_instance_id'||
		' and mcsil.partner_type = 3 '||
		' and mcsil.sr_company_id = -1  '||
		' and mcsil.company_site_id = mcs.company_site_id'||
		' and mcs.company_id = mc.company_id'||
		' and mcs.company_id = 1 '||
		' and mtp.modeled_customer_id    = mtpm.tp_key'||
		' and mtpm.map_type        = 1'||
		' and mtpm.company_key     = mcr.relationship_id'||
		' and mcr.object_id        = mc1.company_id'||
		' and nvl(mtp.modeled_customer_site_id, -99) = mtpm1.tp_key'||
		' and mtpm1.map_type       = 3'||
		' and mtpm1.company_key    = mcs1.company_site_id'||
		' union all '||
		' select 1 '||
		'       ,mcsil.company_site_id      '||
		'       ,mc.company_name            '||
		'       ,mcs.company_site_name      '||
		'       ,msi.inventory_item_id      '||
		'       ,mavv.shipped_quantity      '||
		'       ,mavv.ultimate_dropoff_date '||
		'       ,mc.company_id              '||
		'       ,mc.company_name            '||
		'       ,mcsil.company_site_id      '||
		'       ,mcs.company_site_name      '||
		'       ,mavv.delivery_name         '||
		'       ,mcr.object_id              '||
		'       ,mc1.company_name           '||
		'       ,mcs1.company_site_id       '||
		'       ,mcs1.company_site_name     '||
		'       ,mc.company_id              '||
		'       ,mc.company_name            '||
		'       ,mcsil.company_site_id      '||
		'       ,mcs.company_site_name      '||
		'       ,msi.item_name              '||
		'       ,msi.description            '||
		'       ,msi.uom_code		   '||
		'       ,mavv.ultimate_dropoff_date'||
		'       ,asn.SOURCE_DELIVERY_ID '||
		'       ,mavv.DELIVERY_ID      '||
		'       ,mavv.req_order_number ' ||
		'       ,to_char(mavv.req_line_number) ' ||
		'       ,mavv.status_code '||
		'       ,msi.planner_code '||
		' from mrp_ap_vmi_intransits_v'||v_sr_dblink ||'  mavv, '||
		'     msc_system_items          msi,'||
		'     msc_trading_partners      mtp,'||
		'     msc_company_site_id_lid   mcsil,'||
		'     msc_company_sites         mcs,'||
		'     msc_companies             mc,'||
		'     msc_sup_dem_entries       asn,'||
		'     msc_company_relationships mcr,'||
		'     msc_trading_partner_maps  mtpm,'||
		'     msc_companies             mc1,'||
		'     msc_company_sites         mcs1,'||
		'     msc_trading_partners      mtp1   ,'||
		'     msc_trading_partner_maps  mtpm1'||
		' where mtp.partner_type = 3'||
		' and mtp.sr_instance_id = '||p_sr_instance_id||
		' and mtp.modeled_customer_id is not null'||
		' and mtp.modeled_customer_site_id is not null'||
		' and msi.sr_instance_id = mtp.sr_instance_id'||
		' and msi.plan_id = -1'||
		' and msi.INVENTORY_PLANNING_CODE = 7'||
		' and msi.CONSIGNED_FLAG = 1'||
		' and mavv.CONSIGNED_FLAG = 1'||
		' and msi.organization_id = mtp.sr_tp_id'||
		' and mtp.sr_tp_id = mavv.destination_organization_id'||
		' and msi.sr_inventory_item_id = mavv.inventory_item_id'||
		' and asn.source_DELIVERY_ID = mavv.delivery_id'||
		' and asn.publisher_order_type = 15'||
		' and (asn.quantity <> mavv.shipped_quantity'||
		'     or trunc(asn.key_date) <> trunc(mavv.ultimate_dropoff_date)'||
		'     or mavv.status_code <> ''IT''  )'||
		' and mtp1.sr_tp_id = mavv.source_organization_id '||
		' and mtp1.sr_instance_id = mtp.sr_instance_id ' ||
		' and mtp1.partner_type = mtp.partner_type '||
		' and mtp1.sr_tp_id = mcsil.sr_company_site_id'||
		' and mtp1.sr_instance_id  = mcsil.sr_instance_id'||
		' and mcsil.partner_type = 3 '||
		' and mcsil.sr_company_id = -1  '||
		' and mcsil.company_site_id = mcs.company_site_id'||
		' and mcs.company_id = mc.company_id'||
		' and mcs.company_id = 1 '||
		' and mtp.modeled_customer_id    = mtpm.tp_key'||
		' and mtpm.map_type        = 1'||
		' and mtpm.company_key     = mcr.relationship_id'||
		' and mcr.object_id        = mc1.company_id'||
		' and nvl(mtp.modeled_customer_site_id, -99) = mtpm1.tp_key'||
		' and mtpm1.map_type       = 3'||
		' and mtpm1.company_key    = mcs1.company_site_id';
		*/

		lv_sql_stmt1 := 'select  1 '||
		'      ,mcsil.company_site_id      '||
		'       ,mc.company_name            '||
		'       ,mcs.company_site_name      '||
		'       ,msi.inventory_item_id      '||
		'       ,mavv.shipped_quantity      '||
		'       ,mavv.ultimate_dropoff_date receipt_date'||
		'       ,mc.company_id              '||
		'       ,mc.company_name            '||
		'       ,mcsil.company_site_id      '||
		'       ,mcs.company_site_name      '||
		'       ,mavv.delivery_name         '||
		'       ,mcr.object_id              '||
		'       ,mc1.company_name           '||
		'       ,mcs1.company_site_id       '||
		'       ,mcs1.company_site_name     '||
		'       ,mc.company_id              '||
		'       ,mc.company_name            '||
		'       ,mcsil.company_site_id      '||
		'       ,mcs.company_site_name      '||
		'       ,msi.item_name              '||
		'       ,msi.description            '||
		'       ,msi.uom_code		   '||
		'       ,mavv.ultimate_dropoff_date '||
		'       ,nvl(asn.SOURCE_DELIVERY_ID,-999999) '||
		'       ,mavv.DELIVERY_ID         SOURCE_DELIVERY_ID'||
		'       ,to_char(null) ' ||
		'       ,to_char(null) ' ||
		'       ,mavv.status_code '||
		'       ,msi.planner_code '||
		' from msc_system_items         msi   ,'||
		'     msc_trading_partners      mtp   ,'||
		'     msc_company_site_id_lid   mcsil ,'||
		'     msc_company_sites         mcs   ,'||
		'     msc_companies             mc    ,'||
		'     msc_sup_dem_entries       asn   ,'||
		'     msc_company_relationships mcr   ,'||
		'     msc_trading_partner_maps  mtpm  ,'||
		'     msc_companies             mc1   ,'||
		'     msc_company_sites         mcs1  ,'||
		'     msc_trading_partners      mtp1   ,'||
		'     msc_trading_partner_maps  mtpm1  ,'||
		'     mrp_ap_vmi_intransits_v'||v_sr_dblink ||'  mavv '||
		' where mtp.partner_type = 3 '||
		' and mtp.sr_instance_id = '||p_sr_instance_id||
		' and mtp.modeled_customer_id is not null  '||
		' and mtp.modeled_customer_site_id is not null '||
		' and msi.sr_instance_id = mtp.sr_instance_id'||
		' and msi.plan_id = -1'||
		' and msi.organization_id = mtp.sr_tp_id'||
		' and msi.sr_inventory_item_id = mavv.inventory_item_id'||
		' and msi.INVENTORY_PLANNING_CODE = 7'||
		' and msi.CONSIGNED_FLAG = 2'||
		' and mtp.sr_tp_id = mavv.destination_organization_id'||
		' and asn.source_DELIVERY_ID(+) = mavv.delivery_id'||
		' and asn.source_DELIVERY_ID is null '||
		' and asn.publisher_order_type(+) = 15'||
		' and mavv.status_code = ''IT'''||
		' and mavv.CONSIGNED_FLAG = 2 '||
		' and mtp1.sr_tp_id = mavv.source_organization_id '||
		' and mtp1.sr_instance_id = mtp.sr_instance_id ' ||
		' and mtp1.partner_type = mtp.partner_type '||
		' and mtp1.sr_tp_id = mcsil.sr_company_site_id'||
		' and mtp1.sr_instance_id  = mcsil.sr_instance_id'||
		' and mcsil.partner_type = 3 '||
		' and mcsil.sr_company_id = -1 '||
		' and mcsil.company_site_id = mcs.company_site_id'||
		' and mcs.company_id = mc.company_id'||
		' and mcs.company_id = 1 '||
		' and mtp.modeled_customer_id    = mtpm.tp_key'||
		' and mtpm.map_type        = 1'||
		' and mtpm.company_key     = mcr.relationship_id'||
		' and mcr.object_id        = mc1.company_id'||
		' and nvl(mtp.modeled_customer_site_id, -99) = mtpm1.tp_key'||
		' and mtpm1.map_type       = 3'||
		' and mtpm1.company_key    = mcs1.company_site_id';

lv_sql_stmt2 := ' select 1 '||
		'       ,mcsil.company_site_id    '||
		'       ,mc.company_name          '||
		'       ,mcs.company_site_name    '||
		'       ,msi.inventory_item_id    '||
		'       ,mavv.shipped_quantity    '||
		'       ,mavv.ultimate_dropoff_date  receipt_date'||
		'       ,mc.company_id           '||
		'       ,mc.company_name         '||
		'       ,mcsil.company_site_id   '||
		'       ,mcs.company_site_name   '||
		'       ,mavv.delivery_name      '||
		'      ,mcr.object_id            '||
		'      ,mc1.company_name         '||
		'      ,mcs1.company_site_id   '||
		'      ,mcs1.company_site_name '||
		'       ,mc.company_id         '||
		'      , mc.company_name       '||
		'      , mcsil.company_site_id '||
		'      , mcs.company_site_name     '||
		'      ,msi.item_name            '||
		'       ,msi.description         '||
		'       ,msi.uom_code		'||
		'      ,mavv.ultimate_dropoff_date '||
		'       ,asn.SOURCE_DELIVERY_ID '||
		'       ,mavv.DELIVERY_ID  source_delivery_id'||
		'       ,to_char(null) ' ||
		'       ,to_char(null) ' ||
		'       ,mavv.status_code '||
		'       ,msi.planner_code '||
		' from msc_system_items  msi,'||
		'     msc_trading_partners mtp,'||
		'     msc_company_site_id_lid mcsil,'||
		'     msc_company_sites   mcs,'||
		'     msc_companies  mc,'||
		'     msc_sup_dem_entries  asn,'||
		'     msc_company_relationships mcr,'||
		'     msc_trading_partner_maps  mtpm,'||
		'     msc_companies  mc1,'||
		'     msc_company_sites   mcs1,'||
		'     msc_trading_partners      mtp1   ,'||
		'     msc_trading_partner_maps  mtpm1,'||
		'     mrp_ap_vmi_intransits_v'||v_sr_dblink ||'   mavv'||
		' where mtp.partner_type = 3'||
		' and mtp.sr_instance_id = '||p_sr_instance_id||
		' and mtp.modeled_customer_id is not null '||
		' and mtp.modeled_customer_site_id is not null '||
		' and msi.sr_instance_id = mtp.sr_instance_id'||
		' and msi.plan_id = -1'||
		' and msi.INVENTORY_PLANNING_CODE = 7'||
		' and msi.CONSIGNED_FLAG = 2'||
		' and mavv.CONSIGNED_FLAG = 2 '||
		' and msi.organization_id = mtp.sr_tp_id'||
		' and msi.sr_inventory_item_id = mavv.inventory_item_id'||
		' and mtp.sr_tp_id = mavv.destination_organization_id'||
		' and asn.SOURCE_DELIVERY_ID = mavv.DELIVERY_ID'||
		' and asn.publisher_order_type = 15'||
		' and (asn.quantity <> mavv.shipped_quantity'||
		'      or trunc(asn.key_date) <> trunc(mavv.ultimate_dropoff_date)'||
		'      or mavv.status_code <> ''IT'' )'||
		' and mtp1.sr_tp_id = mavv.source_organization_id '||
		' and mtp1.sr_instance_id = mtp.sr_instance_id ' ||
		' and mtp1.partner_type = mtp.partner_type '||
		' and mtp1.sr_tp_id = mcsil.sr_company_site_id'||
		' and mtp1.sr_instance_id  = mcsil.sr_instance_id'||
		' and mcsil.partner_type = 3 '||
		' and mcsil.sr_company_id = -1  '||
		' and mcsil.company_site_id = mcs.company_site_id'||
		' and mcs.company_id = mc.company_id'||
		'  and mcs.company_id = 1 '||
		' and mtp.modeled_customer_id    = mtpm.tp_key'||
		' and mtpm.map_type        = 1'||
		' and mtpm.company_key     = mcr.relationship_id'||
		' and mcr.object_id        = mc1.company_id'||
		' and nvl(mtp.modeled_customer_site_id, -99) = mtpm1.tp_key'||
		' and mtpm1.map_type       = 3'||
		' and mtpm1.company_key    = mcs1.company_site_id ';

lv_sql_stmt3 := ' select 1 '||
		'       ,mcsil.company_site_id      '||
		'       ,mc.company_name            '||
		'       ,mcs.company_site_name      '||
		'       ,msi.inventory_item_id      '||
		'       ,mavv.shipped_quantity      '||
		'       ,mavv.ultimate_dropoff_date '||
		'       ,mc.company_id              '||
		'       ,mc.company_name            '||
		'       ,mcsil.company_site_id      '||
		'       ,mcs.company_site_name      '||
		'       ,mavv.delivery_name         '||
		'       ,mcr.object_id              '||
		'       ,mc1.company_name           '||
		'       ,mcs1.company_site_id       '||
		'       ,mcs1.company_site_name     '||
		'       ,mc.company_id              '||
		'       ,mc.company_name            '||
		'       ,mcsil.company_site_id      '||
		'       ,mcs.company_site_name      '||
		'       ,msi.item_name              '||
		'       ,msi.description            '||
		'       ,msi.uom_code		    '||
		'       ,mavv.ultimate_dropoff_date '||
		'       ,nvl(asn.SOURCE_DELIVERY_ID,-999999) '||
		'       ,mavv.DELIVERY_ID          '||
		'       ,mavv.req_order_number ' ||
		'       ,to_char(mavv.req_line_number) ' ||
		'       ,mavv.status_code  '||
		'       ,msi.planner_code '||
		' from mrp_ap_vmi_intransits_v'||v_sr_dblink ||'   mavv, '||
		'     msc_system_items          msi,'||
		'     msc_trading_partners      mtp,'||
		'     msc_company_site_id_lid   mcsil,'||
		'     msc_company_sites         mcs,'||
		'     msc_companies             mc,'||
		'     msc_sup_dem_entries       asn,'||
		'     msc_company_relationships mcr,'||
		'     msc_trading_partner_maps  mtpm,'||
		'     msc_companies             mc1,'||
		'     msc_company_sites         mcs1,'||
		'     msc_trading_partners      mtp1   ,'||
		'     msc_trading_partner_maps  mtpm1'||
		' where mtp.partner_type = 3'||
		' and mtp.sr_instance_id = '||p_sr_instance_id||
		' and mtp.modeled_customer_id is not null'||
		' and mtp.modeled_customer_site_id is not null'||
		' and msi.sr_instance_id = mtp.sr_instance_id'||
		' and msi.plan_id = -1'||
		' and msi.CONSIGNED_FLAG = 1'||
		' and msi.INVENTORY_PLANNING_CODE = 7'||
		' and msi.organization_id = mtp.sr_tp_id'||
		' and msi.sr_inventory_item_id = mavv.inventory_item_id'||
		' and mtp.sr_tp_id = mavv.destination_organization_id'||
		' and asn.source_DELIVERY_ID(+) = mavv.delivery_id'||
		' and asn.source_DELIVERY_ID is null'||
		' and asn.publisher_order_type(+) = 15'||
		' and mavv.status_code = ''IT'''||
		' and mavv.CONSIGNED_FLAG = 1'||
		' and mtp1.sr_tp_id = mavv.source_organization_id '||
		' and mtp1.sr_instance_id = mtp.sr_instance_id ' ||
		' and mtp1.partner_type = mtp.partner_type '||
		' and mtp1.sr_tp_id = mcsil.sr_company_site_id'||
		' and mtp1.sr_instance_id  = mcsil.sr_instance_id'||
		' and mcsil.partner_type = 3 '||
		' and mcsil.sr_company_id = -1  '||
		' and mcsil.company_site_id = mcs.company_site_id'||
		' and mcs.company_id = mc.company_id'||
		' and mcs.company_id = 1 '||
		' and mtp.modeled_customer_id    = mtpm.tp_key'||
		' and mtpm.map_type        = 1'||
		' and mtpm.company_key     = mcr.relationship_id'||
		' and mcr.object_id        = mc1.company_id'||
		' and nvl(mtp.modeled_customer_site_id, -99) = mtpm1.tp_key'||
		' and mtpm1.map_type       = 3'||
		' and mtpm1.company_key    = mcs1.company_site_id';

lv_sql_stmt4 := ' select 1 '||
		'       ,mcsil.company_site_id      '||
		'       ,mc.company_name            '||
		'       ,mcs.company_site_name      '||
		'       ,msi.inventory_item_id      '||
		'       ,mavv.shipped_quantity      '||
		'       ,mavv.ultimate_dropoff_date '||
		'       ,mc.company_id              '||
		'       ,mc.company_name            '||
		'       ,mcsil.company_site_id      '||
		'       ,mcs.company_site_name      '||
		'       ,mavv.delivery_name         '||
		'       ,mcr.object_id              '||
		'       ,mc1.company_name           '||
		'       ,mcs1.company_site_id       '||
		'       ,mcs1.company_site_name     '||
		'       ,mc.company_id              '||
		'       ,mc.company_name            '||
		'       ,mcsil.company_site_id      '||
		'       ,mcs.company_site_name      '||
		'       ,msi.item_name              '||
		'       ,msi.description            '||
		'       ,msi.uom_code		   '||
		'       ,mavv.ultimate_dropoff_date'||
		'       ,asn.SOURCE_DELIVERY_ID '||
		'       ,mavv.DELIVERY_ID      '||
		'       ,mavv.req_order_number ' ||
		'       ,to_char(mavv.req_line_number) ' ||
		'       ,mavv.status_code '||
		'       ,msi.planner_code '||
		' from mrp_ap_vmi_intransits_v'||v_sr_dblink ||'  mavv, '||
		'     msc_system_items          msi,'||
		'     msc_trading_partners      mtp,'||
		'     msc_company_site_id_lid   mcsil,'||
		'     msc_company_sites         mcs,'||
		'     msc_companies             mc,'||
		'     msc_sup_dem_entries       asn,'||
		'     msc_company_relationships mcr,'||
		'     msc_trading_partner_maps  mtpm,'||
		'     msc_companies             mc1,'||
		'     msc_company_sites         mcs1,'||
		'     msc_trading_partners      mtp1   ,'||
		'     msc_trading_partner_maps  mtpm1'||
		' where mtp.partner_type = 3'||
		' and mtp.sr_instance_id = '||p_sr_instance_id||
		' and mtp.modeled_customer_id is not null'||
		' and mtp.modeled_customer_site_id is not null'||
		' and msi.sr_instance_id = mtp.sr_instance_id'||
		' and msi.plan_id = -1'||
		' and msi.INVENTORY_PLANNING_CODE = 7'||
		' and msi.CONSIGNED_FLAG = 1'||
		' and mavv.CONSIGNED_FLAG = 1'||
		' and msi.organization_id = mtp.sr_tp_id'||
		' and mtp.sr_tp_id = mavv.destination_organization_id'||
		' and msi.sr_inventory_item_id = mavv.inventory_item_id'||
		' and asn.source_DELIVERY_ID = mavv.delivery_id'||
		' and asn.publisher_order_type = 15'||
		' and (asn.quantity <> mavv.shipped_quantity'||
		'     or trunc(asn.key_date) <> trunc(mavv.ultimate_dropoff_date)'||
		'     or mavv.status_code <> ''IT''  )'||
		' and mtp1.sr_tp_id = mavv.source_organization_id '||
		' and mtp1.sr_instance_id = mtp.sr_instance_id ' ||
		' and mtp1.partner_type = mtp.partner_type '||
		' and mtp1.sr_tp_id = mcsil.sr_company_site_id'||
		' and mtp1.sr_instance_id  = mcsil.sr_instance_id'||
		' and mcsil.partner_type = 3 '||
		' and mcsil.sr_company_id = -1  '||
		' and mcsil.company_site_id = mcs.company_site_id'||
		' and mcs.company_id = mc.company_id'||
		' and mcs.company_id = 1 '||
		' and mtp.modeled_customer_id    = mtpm.tp_key'||
		' and mtpm.map_type        = 1'||
		' and mtpm.company_key     = mcr.relationship_id'||
		' and mcr.object_id        = mc1.company_id'||
		' and nvl(mtp.modeled_customer_site_id, -99) = mtpm1.tp_key'||
		' and mtpm1.map_type       = 3'||
		' and mtpm1.company_key    = mcs1.company_site_id';

    BEGIN
         i := 0;
	 j :=1;

	 LOOP

        -- lv_sql_stmt := 'lv_sql_stmt'||j;

	--LOG_MESSAGE('Total records fetched for ASN Deliveries----'||lv_sql_stmt1);

	if (j=1) then
		--LOG_MESSAGE('Total records fetched for ASN Deliveries---IN-');
		OPEN CUR_DELIVERY_ASN  for lv_sql_stmt1;
	elsif (j=2) then
		OPEN CUR_DELIVERY_ASN  for lv_sql_stmt2;
	elsif (j=3) then
		OPEN CUR_DELIVERY_ASN  for lv_sql_stmt3;
	elsif (j=4) then
		OPEN CUR_DELIVERY_ASN  for lv_sql_stmt4;
        else
	     null;
	end if;



         LOOP
             i := i+1;
		  /* PS: Extend the variables in the loop  */
			t_pub_id.EXTEND;
			t_pub_site_id.EXTEND;
			t_pub.EXTEND;
			t_pub_site.EXTEND;
			t_supp_id.EXTEND;
			t_supp.EXTEND;
			t_supp_site_id.EXTEND;
			t_supp_site.EXTEND;
			t_item_id.EXTEND;
			t_quantity.EXTEND;
			t_receipt_date.EXTEND;
			t_line_num.EXTEND;
			t_shipto_id.EXTEND;
			t_shipto_site_id.EXTEND;
			t_shipto.EXTEND;
			t_shipto_site.EXTEND;
			t_shipfrom_id.EXTEND;
			t_shipfrom_site_id.EXTEND;
			t_shipfrom.EXTEND;
			t_shipfrom_site.EXTEND;
			t_item_name.EXTEND;
			t_item_desc.EXTEND;
			t_uom.EXTEND;
			t_key_date.EXTEND;
			t_ord_num.EXTEND;
			t_delivery_id.EXTEND;
			t_status_code.EXTEND;
			t_end_order_number.EXTEND;
			t_end_order_line_number.EXTEND;
			t_planner_code.EXTEND;--Bug 4424426

	 FETCH CUR_DELIVERY_ASN INTO
              t_pub_id(i),
			       t_pub_site_id(i),
			       t_pub(i),
			       t_pub_site(i),
			       t_item_id(i),
			       t_quantity(i),
			       t_receipt_date(i),
			       t_supp_id(i),
			       t_supp(i),
			       t_supp_site_id(i),
			       t_supp_site(i),
			       t_ord_num(i),
			       t_shipto_id(i),
			       t_shipto(i),
			       t_shipto_site_id(i),
			       t_shipto_site(i),
			       t_shipfrom_id(i),
			       t_shipfrom(i),
			       t_shipfrom_site_id(i),
			       t_shipfrom_site(i),
			       t_item_name(i),
			       t_item_desc(i),
			       t_uom(i),
			       t_key_date(i),
			       t_line_num(i),
			       t_delivery_id(i),
			       t_end_order_number(i),
			       t_end_order_line_number(i),
			       t_status_code(i),
			       t_planner_code(i);--Bug 4424426

             EXIT WHEN CUR_DELIVERY_ASN%NOTFOUND;

         END LOOP;

         CLOSE CUR_DELIVERY_ASN;



         /* PS: Trim the last element from the array  ; since it will always be null*/
			t_pub_id.TRIM;
			t_pub_site_id.TRIM;
			t_pub.TRIM;
			t_pub_site.TRIM;
			t_supp_id.TRIM;
			t_supp.TRIM;
			t_supp_site_id.TRIM;
			t_supp_site.TRIM;
			t_item_id.TRIM;
			t_quantity.TRIM;
			t_receipt_date.TRIM;
			t_line_num.TRIM;
			t_shipto_id.TRIM;
			t_shipto_site_id.TRIM;
			t_shipto.TRIM;
			t_shipto_site.TRIM;
			t_shipfrom_id.TRIM;
			t_shipfrom_site_id.TRIM;
			t_shipfrom.TRIM;
			t_shipfrom_site.TRIM;
			t_item_name.TRIM;
			t_item_desc.TRIM;
			t_uom.TRIM;
			t_key_date.TRIM;
			t_ord_num.TRIM;
			t_delivery_id.TRIM;
			t_status_code.TRIM;
			t_planner_code.TRIM;--Bug 4424426
			t_end_order_number.TRIM;
			t_end_order_line_number.TRIM;


	 LOG_MESSAGE('Total records fetched for ASN Deliveries--j'||j||'-- :'||t_pub_id.COUNT);

	 i := i-1; --bug 8978614
	 j := j+1;
	-- lv_sql_stmt := '';

	 If (j = 5) THEN
		EXIT;
	 END IF;

	 END LOOP;

	EXCEPTION WHEN OTHERS THEN
	       IF (CUR_DELIVERY_ASN%ISOPEN) THEN
		  CLOSE CUR_DELIVERY_ASN;
	       END IF;
		 LOG_MESSAGE('Error while fetching records for New Open Deliveries in Unconsigned ');
		 LOG_MESSAGE(SQLERRM);
		 RETCODE := G_ERROR;
	END;


	    LOG_MESSAGE('Total records fetched for ASN Deliveries :'||t_pub_id.COUNT);

     --===========================
     -- Update the fetched records
     --===========================

     IF t_pub_id.COUNT > 0 THEN

             BEGIN

             FORALL i in 1..t_pub_id.COUNT

                 update msc_sup_dem_entries
                     set key_date 	  = t_key_date(i),
            	         receipt_date 	  = t_receipt_date(i),
			 quantity         = decode(t_status_code(i),'IT',t_quantity(i),0),
			 primary_quantity = decode(t_status_code(i),'IT',t_quantity(i),0),
			 tp_quantity      = decode(t_status_code(i),'IT',t_quantity(i),0),
			 sr_delivery_status_code = t_status_code(i),
		         last_refresh_number  = msc_cl_refresh_s.nextval,
			 last_update_date = sysdate,
			 last_updated_by = decode(t_status_code(i),'IT',p_user_id,-999)
                 where   plan_id = G_PLAN_ID
                   and	 sr_instance_id 	 = G_SR_INSTANCE_ID
                   and	 publisher_id 		 = t_pub_id(i)
            	   and	 publisher_site_id 	 = t_pub_site_id(i)
            	   and	 inventory_item_id 	 = t_item_id(i)
            	   and	 publisher_order_type 	 = G_ASN
            --	   and	 customer_id          	 = t_customer_id(i)
            --	   and	 customer_site_id     	 = t_customer_site_id(i)
		   and   SOURCE_delivery_id      = t_line_num(i)
		   and   t_line_num(i)           <> -999999;

            	   COMMIT;
             EXCEPTION WHEN OTHERS THEN
                 ROLLBACK;
                 LOG_MESSAGE('ERROR while updating msc_up_dem_entries using ASN Deliveries');
                 LOG_MESSAGE(SQLERRM);
                 RETCODE := G_ERROR;
             END;
                 LOG_MESSAGE('completed the update Deliveries');

     END IF;

     --==========================================================
     -- Insert the fetched records if the records are new records
     --     Step 1. Extend the insert variables.
     --     Step 2. BULK insert.
     --==========================================================

     /* Initialize the count */

     a_ins_count := null;
     a_ins_count := number_arr();

     FOR j IN 1..t_pub_id.COUNT LOOP
         IF (SQL%BULK_ROWCOUNT(j) = 0) THEN
             a_ins_count.EXTEND;
			t_ins_pub_id.EXTEND;
			t_ins_pub_site_id.EXTEND;
			t_ins_pub.EXTEND;
			t_ins_pub_site.EXTEND;
			t_ins_supp_id.EXTEND;
			t_ins_supp.EXTEND;
			t_ins_supp_site_id.EXTEND;
			t_ins_supp_site.EXTEND;
			t_ins_item_id.EXTEND;
			t_ins_quantity.EXTEND;
			t_ins_receipt_date.EXTEND;
			t_ins_line_num.EXTEND;
			t_ins_shipto_id.EXTEND;
			t_ins_shipto_site_id.EXTEND;
			t_ins_shipto.EXTEND;
			t_ins_shipto_site.EXTEND;
			t_ins_shipfrom_id.EXTEND;
			t_ins_shipfrom_site_id.EXTEND;
			t_ins_shipfrom.EXTEND;
			t_ins_shipfrom_site.EXTEND;
			t_ins_item_name.EXTEND;
			t_ins_item_desc.EXTEND;
			t_ins_uom.EXTEND;
			t_ins_key_date.EXTEND;
			t_ins_ord_num.EXTEND;
			t_ins_delivery_id.EXTEND;
			t_ins_status_code.EXTEND;
			t_ins_planner_code.EXTEND;--Bug 4424426
			t_ins_end_ord_num.EXTEND;
			t_ins_end_ord_line_num.EXTEND;


                a_ins_count(a_ins_count.COUNT)	        := j;
		t_ins_pub_id(a_ins_count.COUNT)	        := t_pub_id(j);
		t_ins_pub_site_id(a_ins_count.COUNT)	:= t_pub_site_id(j);
		t_ins_pub(a_ins_count.COUNT)	        := t_pub(j);
		t_ins_pub_site(a_ins_count.COUNT)	:= t_pub_site(j);
		t_ins_supp_id(a_ins_count.COUNT)	:= t_supp_id(j);
		t_ins_supp(a_ins_count.COUNT)	        := t_supp(j);
		t_ins_supp_site_id(a_ins_count.COUNT)	:= t_supp_site_id(j);
		t_ins_supp_site(a_ins_count.COUNT)	:= t_supp_site(j);
                t_ins_item_id(a_ins_count.COUNT)	:= t_item_id(j);
                t_ins_quantity(a_ins_count.COUNT)	:= t_quantity(j);
		t_ins_receipt_date(a_ins_count.COUNT)   := t_receipt_date(j);
		t_ins_shipto_id(a_ins_count.COUNT)      := t_shipto_id(j);
		t_ins_shipto_site_id(a_ins_count.COUNT)	:= t_shipto_site_id(j);
		t_ins_shipto(a_ins_count.COUNT)	        := t_shipto(j);
		t_ins_shipto_site(a_ins_count.COUNT)	:= t_shipto_site(j);
		t_ins_shipfrom_id(a_ins_count.COUNT)	:= t_shipfrom_id(j);
		t_ins_shipfrom_site_id(a_ins_count.COUNT):= t_shipfrom_site_id(j);
		t_ins_shipfrom(a_ins_count.COUNT)	:= t_shipfrom(j);
		t_ins_shipfrom_site(a_ins_count.COUNT)	:= t_shipfrom_site(j);
		t_ins_item_name(a_ins_count.COUNT)	:= t_item_name(j);
		t_ins_item_desc(a_ins_count.COUNT)	:= t_item_desc(j);
		t_ins_uom(a_ins_count.COUNT)	        := t_uom(j);
		t_ins_key_date(a_ins_count.COUNT)       := t_key_date(j);
		t_ins_line_num(a_ins_count.COUNT)       := t_line_num(j);
                t_ins_ord_num(a_ins_count.COUNT)        := t_ord_num(j);
		t_ins_delivery_id(a_ins_count.COUNT)    := t_delivery_id(j);
		t_ins_status_code(a_ins_count.COUNT)    := t_status_code(j);
		t_ins_planner_code(a_ins_count.COUNT)    := t_planner_code(j);--Bug 4424426
	 t_ins_end_ord_num(a_ins_count.COUNT) := t_end_order_number(j);
	 t_ins_end_ord_line_num(a_ins_count.COUNT) :=
						t_end_order_line_number(j);

	END IF;

   END LOOP;

   LOG_MESSAGE('Total records for insertion for ASN Deliveries :'||a_ins_count.COUNT);

	IF a_ins_count.COUNT > 0 THEN
	    BEGIN
	    FORALL j in 1..a_ins_count.COUNT
		insert into msc_sup_dem_entries
		(
		 sr_instance_id
		 ,transaction_id
		 ,plan_id
		 ,publisher_id
		 ,publisher_site_id
		 ,publisher_name
		 ,publisher_site_name
		 ,inventory_item_id
		 ,quantity
		 ,publisher_order_type
		 ,receipt_date
		 ,supplier_id
		 ,supplier_name
		 ,supplier_site_id
		 ,supplier_site_name
		 ,SOURCE_delivery_id
		 ,order_number
		 ,ship_to_party_id
		 ,ship_to_party_site_id
		 ,ship_to_party_name
		 ,ship_to_party_site_name
		 ,ship_from_party_id
		 ,SHIP_FROM_PARTY_SITE_ID
		 ,SHIP_FROM_PARTY_NAME
		 ,SHIP_FROM_PARTY_SITE_NAME
		 ,publisher_item_name
		 ,pub_item_description
		 ,uom_code
		 ,publisher_order_type_desc
		 ,bucket_type
		 ,bucket_type_desc
		 ,created_by
		 ,creation_date
		 ,last_updated_by
		 ,last_update_date
		 ,comments
		 ,key_date
		 ,item_name
		 ,owner_item_name
		 ,customer_item_name
		 ,supplier_item_name
		 ,item_description
		 ,owner_item_description
		 ,customer_item_description
		 ,supplier_item_description
		 ,primary_quantity
		 ,tp_uom_code
		 ,tp_quantity
		 ,customer_id
		 ,customer_site_id
		 ,customer_name
		 ,customer_site_name
		 ,last_refresh_number
		 ,primary_uom
	         ,vmi_flag
		 ,end_order_number
		 ,end_order_line_number
		 ,sr_delivery_status_code
		 ,planner_code--Bug 4424426
		)values
		(
		 G_SR_INSTANCE_ID,
		 msc_sup_dem_entries_s.nextval,
		 G_PLAN_ID,
		 t_ins_pub_id(j),
		 t_ins_pub_site_id(j),
		 t_ins_pub(j),
		 t_ins_pub_site(j),
		 t_ins_item_id(j),
		 round(t_ins_quantity(j),6),
		 G_ASN,
		 t_ins_receipt_date(j),
		 t_ins_supp_id(j),
		 t_ins_supp(j),
		 t_ins_supp_site_id(j),
		 t_ins_supp_site(j),
		 t_ins_delivery_id(j),
		 t_ins_ord_num(j),
		 t_ins_shipto_id(j),
		 t_ins_shipto_site_id(j),
		 t_ins_shipto(j),
		 t_ins_shipto_site(j),
		 t_ins_shipfrom_id(j),
		 t_ins_shipfrom_site_id(j),
		 t_ins_shipfrom(j),
		 t_ins_shipfrom_site(j),
		 t_ins_item_name(j),
		 t_ins_item_desc(j),
		 t_ins_uom(j),
		 G_ASN_DESC,
		 1,
		 'DAY',
		 p_user_id,
		 sysdate,
		 p_user_id,
		 sysdate,
		 'PUBLISH VMI ASN',
		 t_ins_key_date(j),
		 t_ins_item_name(j),
		 t_ins_item_name(j),
		 t_ins_item_name(j),
		 t_ins_item_name(j),
		 --t_ins_owner_item_name(j),
		 --t_ins_customer_item_name(j),
		 --t_ins_supplier_item_name(j),
		 t_ins_item_desc(j),
		 t_ins_item_desc(j),
		 t_ins_item_desc(j),
		 t_ins_item_desc(j),
		 --t_ins_owner_item_desc(j),
		 --t_ins_cust_item_desc(j),
		 --t_ins_supplier_item_name(j),
		 round(t_ins_quantity(j), 6),
		 t_ins_uom(j),
		 round(t_ins_quantity(j), 6),
		 t_ins_shipto_id(j),
		 t_ins_shipto_site_id(j),
		 t_ins_shipto(j),
		 t_ins_shipto_site(j),
		 msc_cl_refresh_s.nextval,
		 t_ins_uom(j),
	         1,
		 t_ins_end_ord_num(j),
		 t_ins_end_ord_line_num(j),
		 t_ins_status_code(j),
		 t_ins_planner_code(j)--Bug 4424426
	      );

	      COMMIT;

	  EXCEPTION WHEN OTHERS THEN
	      LOG_MESSAGE('Error while inserting records into msc_sup_dem_entries');
	      LOG_MESSAGE(SQLERRM);
	      ROLLBACK;
	      RETCODE := G_ERROR;
	  END;

	END IF;

	    /* Update the pegging information for ASN / internal reqs */
            BEGIN
                 LOG_MESSAGE('updating pegging info for int reqs using ASN.');

             FORALL i in 1..t_pub_id.COUNT

	 	 update msc_sup_dem_entries sd
		 set   link_trans_id = t_delivery_id(i)
		 where sd.plan_id = G_PLAN_ID
		 and   sd.sr_instance_id = G_SR_INSTANCE_ID
		 and   sd.inventory_item_id = t_item_id(i)
		 and   sd.customer_id = t_shipto_id(i)
		 and   sd.customer_site_id = t_shipto_site_id(i)
		 and   sd.supplier_id = t_supp_id(i)
		 and   sd.supplier_site_id = t_supp_site_id(i)
		 and   sd.publisher_order_type = G_REQ
		 and   sd.internal_flag = SYS_YES
	      	 and   sd.order_number = t_end_order_number(i)
                 and   nvl(sd.line_number, '-1')  = nvl(t_end_order_line_number(i), '-1')
		 and   t_end_order_number(i) is not null;

                 LOG_MESSAGE('Total Records for update of Reqs  from ASN : '||SQL%ROWCOUNT);
		 COMMIT;

            EXCEPTION WHEN OTHERS THEN
                 ROLLBACK;
                 LOG_MESSAGE('ERROR while updating pegging info for int reqs using ASN.');
                 LOG_MESSAGE(SQLERRM);

                 RETCODE := G_ERROR;
	    END;

   end if;

-----=====================PRAGNESH=================================



--======================================================================
-- After Publsih ODS Load , we need to update refresh_number of
-- transactions which are owned by non OEM company and OEM does not have
-- any transaction for those Items.
-- This will insure that those transactions will be captured by VMI netting
-- engine.
-- This needs to be done in case of complete refresh collections.
--======================================================================

	IF v_lrtype = 'C' THEN

	BEGIN

         UPDATE MSC_SUP_DEM_ENTRIES msde1
		 set last_refresh_number = msc_cl_refresh_s.nextval
         where plan_id = G_PLAN_ID
		 --===========================================================
		 -- Make sure that the Transaction is owned by non OEM Company
		 -- and has reference to OEM Company.
		 --===========================================================
		 and   publisher_id <> G_OEM_ID
		 and   (customer_id = G_OEM_ID OR
			    supplier_id = G_OEM_ID)
		 and   not exists ( select 1
                   			from msc_sup_dem_entries msde2
                   			where
						    --==================================================
							-- Make sure that OEM has transaction for that Item.
							--==================================================
							msde2.inventory_item_id = msde1.inventory_item_id
                   			and   msde2.plan_id = msde1.plan_id
                   			and   msde2.publisher_id = G_OEM_ID
						    --======================================================
							-- Make sure that OEM's transaction is supposed for
							-- TPs transaction.
							-- It's difficult to do pegging here. Only we will check
							-- for reference to TP's site in OEM transaction.
							--======================================================
							and decode(msde2.customer_id, msde1.publisher_id,
									   msde2.customer_site_id, msde2.supplier_site_id) = msde1.publisher_site_id
							);

		 COMMIT;

	 EXCEPTION WHEN OTHERS THEN
	     LOG_MESSAGE('Error in updating last_refresh_number of non OEM transactions.');
		 LOG_MESSAGE(SQLERRM);
		 RETCODE := G_ERROR;

	 END;

	 END IF;



--======================================================================
-- Publish ODS is done. Now we need to blow away exceptions related to
-- OEM. This needs to be done if the complete refresh collections is
-- performed.
--======================================================================

    -- IF v_lrtype = 'C' THEN
	    MSC_CL_POST_PUBLISH.POST_CLEANUP(v_in_org_str,
										 v_lrtype,
			                             a_post_status);

        IF a_post_status = G_ERROR THEN
		    RETCODE := G_ERROR;
		END IF;

	-- END IF;

--======================================================================
-- Publish ODS is done. Now we need to call API to compute
-- average daily demand for VMI Items.
----  Not required from 11.5.10
--======================================================================
/* 	IF (p_asl_enabled_flag = MSC_CL_COLLECTION.SYS_YES) THEN

		BEGIN

			MSC_X_PLANNING.CALCULATE_AVERAGE_DEMAND;
		    LOG_MESSAGE('Done CALCULATE_AVERAGE_DEMAND');
		EXCEPTION WHEN OTHERS THEN
			LOG_MESSAGE('Error in MSC_X_PLANNING.CALCULATE_AVERAGE_DEMAND');
			LOG_MESSAGE(SQLERRM);
			RETCODE := G_ERROR;
		END;

	END IF;

*/

END PUBLISH;

END MSC_CL_PUBLISH;

/
