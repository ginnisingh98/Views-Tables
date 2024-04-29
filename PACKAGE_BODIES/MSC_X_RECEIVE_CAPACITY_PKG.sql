--------------------------------------------------------
--  DDL for Package Body MSC_X_RECEIVE_CAPACITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_RECEIVE_CAPACITY_PKG" AS
/* $Header: MSCXRSCB.pls 120.5 2006/05/19 02:19:58 shwmathu noship $ */

G_DAY         CONSTANT INTEGER := 1;
G_WEEK        CONSTANT INTEGER := 2;
G_MONTH       CONSTANT INTEGER := 3;
G_CAL_INSTANCE_ID          number;

CURSOR receive_capacity_c(p_horizon_start_date   In DATE,
                              p_horizon_end_date     In DATE,
                              p_abc_class            In VARCHAR2,
                              p_item_id              In NUMBER,
                              p_planner              In VARCHAR2,
			      p_cal_sr_instance_id   IN NUMBER,
                              p_sce_supplier_id      IN NUMBER,
                              p_sce_supplier_site_id In NUMBER)
IS
SELECT  distinct tp.sr_instance_id,
                 sd.publisher_id,
                 sd.publisher_name,
                 sd.publisher_site_id,
                 sd.publisher_site_name,
                 sd.customer_name,
                 sd.customer_id,
                 sd.customer_site_name,
                 sd.customer_site_id,
                 sd.inventory_item_id,
                 sd.item_name,
                 sd.tp_quantity,
                 sd.tp_uom_code,
                 sd.receipt_date,
                 sd.bucket_type,
                 sd.receipt_date,
                 sd.receipt_date,
		 mis.organization_id,
		 tp2.organization_code,
		 nvl(mis.delivery_calendar_code,G_MSC_X_DEF_CALENDAR),
		 --mis.DELIVERY_CALENDAR_CODE,
		 map2.tp_key,        -- supplier_aps_id
		 map3.tp_key,         -- supplier_site aps id
		 item1.ROUNDING_CONTROL_TYPE
FROM   msc_sup_dem_entries_v sd,
       msc_trading_partner_maps map1,
       msc_trading_partners tp,
       msc_system_items item,
       msc_company_relationships cr,
       msc_trading_partner_maps  map2,
       msc_trading_partner_maps  map3,
       msc_item_suppliers        mis,
       msc_trading_partners      tp2,
       msc_system_items          item1
WHERE  sd.plan_id = -1
  AND  sd.publisher_order_type = SUPPLY_COMMIT
  AND  sd.bucket_Type = G_DAY
  AND  map1.tp_key = tp.partner_id
  AND  map1.map_type = 2  -- company
  AND  map1.company_key = sd.customer_site_id
  AND  sd.customer_id = 1        --OEM
  AND  tp.partner_type = 3
  AND  tp.company_id is null
  AND  item.plan_id = -1
  AND  sd.inventory_item_id = item.inventory_item_id
  AND  item.sr_instance_id = tp.sr_instance_id
  AND  item.organization_id = tp.sr_tp_id
  --AND  sd.quantity > 0
  AND  nvl(item.abc_class_name,-1) = nvl(nvl(p_abc_class, item.abc_class_name),-1)
  AND  nvl(item.planner_code,-1) = nvl(nvl(p_planner, item.planner_code),-1)
  AND  item.inventory_item_id = nvl(p_item_id,item.inventory_item_id)
  AND  sd.publisher_id = nvl(p_sce_supplier_id,sd.publisher_id)
  AND  sd.publisher_site_id = nvl(p_sce_supplier_site_id,sd.publisher_site_id)
  AND  trunc(sd.receipt_date) between nvl(trunc(p_horizon_start_date),sd.receipt_date)
                                  and nvl(trunc(p_horizon_end_date),sd.receipt_date)
  and  cr.object_id = sd.publisher_id
  and  cr.subject_id = sd.customer_id
  and  cr.relationship_type = 2
  and  map2.map_type = 1
  and  map2.company_key = cr.relationship_id
  and  map3.map_type = 3
  and  map3.company_key = sd.publisher_site_id
  and  mis.plan_id = item.plan_id
  and  mis.sr_instance_id = item.sr_instance_id
  and  mis.INVENTORY_ITEM_ID =  item.INVENTORY_ITEM_ID
  and  mis.SUPPLIER_ID = map2.tp_key
  and  mis.SUPPLIER_SITE_ID = map3.tp_key
  and  mis.using_organization_id = -1
  and  mis.sr_instance_id = tp2.sr_instance_id
  and  mis.organization_id = tp2.sr_tp_id
  and  tp2.partner_type = 3
  and  item1.plan_id = mis.plan_id
  and  item1.sr_instance_id = mis.sr_instance_id
  and  item1.organization_id = mis.organization_id
  and  item1.inventory_item_id = mis.inventory_item_id
UNION
SELECT  distinct tp.sr_instance_id,
                 sd.publisher_id,
                 sd.publisher_name,
                 sd.publisher_site_id,
                 sd.publisher_site_name,
                 sd.customer_name,
                 sd.customer_id,
                 sd.customer_site_name,
                 sd.customer_site_id,
                 sd.inventory_item_id,
                 sd.item_name,
                 sd.tp_quantity,
                 sd.tp_uom_code,
                 sd.receipt_date,
                 sd.bucket_type,
                 mcd.week_start_date,
                 mcd.next_date-1,
		 mis.organization_id,
		 tp2.organization_code,
		 nvl(mis.delivery_calendar_code,G_MSC_X_DEF_CALENDAR),
		 --mis.DELIVERY_CALENDAR_CODE,
		 map2.tp_key,
		 map3.tp_key,
		 item1.ROUNDING_CONTROL_TYPE
FROM   msc_sup_dem_entries_v sd,
       msc_trading_partner_maps map1,
       msc_trading_partners tp,
       msc_system_items item,
       MSC_CAL_WEEK_START_DATES  mcd,
       msc_company_relationships cr,
       msc_trading_partner_maps  map2,
       msc_trading_partner_maps  map3,
       msc_item_suppliers        mis,
       msc_trading_partners      tp2,
       msc_system_items          item1
WHERE  sd.plan_id = -1
  AND  sd.publisher_order_type = SUPPLY_COMMIT
  AND  sd.bucket_Type = G_WEEK
  AND  map1.tp_key = tp.partner_id
  AND  map1.map_type = 2  -- company
  AND  map1.company_key = sd.customer_site_id
  AND  sd.customer_id = 1        --OEM
  AND  tp.partner_type = 3
  AND  tp.company_id is null
  AND  item.plan_id = -1
  AND  sd.inventory_item_id = item.inventory_item_id
  AND  item.sr_instance_id = tp.sr_instance_id
  AND  item.organization_id = tp.sr_tp_id
  --AND  sd.quantity > 0
  AND  nvl(item.abc_class_name,-1) = nvl(nvl(p_abc_class, item.abc_class_name),-1)
  AND  nvl(item.planner_code,-1) = nvl(nvl(p_planner, item.planner_code),-1)
  AND  item.inventory_item_id = nvl(p_item_id,item.inventory_item_id)
  AND  sd.publisher_id = nvl(p_sce_supplier_id,sd.publisher_id)
  AND  sd.publisher_site_id = nvl(p_sce_supplier_site_id,sd.publisher_site_id)
  AND  trunc(sd.receipt_date) between nvl(trunc(p_horizon_start_date),sd.receipt_date)
                                  and nvl(trunc(p_horizon_end_date),sd.receipt_date)
  AND  mcd.sr_instance_id = decode(mis.delivery_calendar_code,null,p_cal_sr_instance_id
                                                         ,tp.sr_instance_id)
  AND  mcd.CALENDAR_CODE = nvl(mis.delivery_calendar_code,G_MSC_X_DEF_CALENDAR)
  AND  mcd.EXCEPTION_SET_ID = -1
  AND  to_char(sd.receipt_date,'J') between to_char(mcd.WEEK_START_DATE,'J')
			                and to_char(mcd.NEXT_DATE,'J')
  AND  to_char(sd.receipt_date,'J') < TO_CHAR(mcd.NEXT_DATE,'J')
  and  cr.object_id = sd.publisher_id
  and  cr.subject_id = sd.customer_id
  and  cr.relationship_type = 2
  and  map2.map_type = 1
  and  map2.company_key = cr.relationship_id
  and  map3.map_type = 3
  and  map3.company_key = sd.publisher_site_id
  and  mis.plan_id = -1
  and  mis.sr_instance_id = item.sr_instance_id
  and  mis.INVENTORY_ITEM_ID =  item.INVENTORY_ITEM_ID
  and  mis.SUPPLIER_ID = map2.tp_key
  and  mis.SUPPLIER_SITE_ID = map3.tp_key
  and  mis.using_organization_id = -1
  and  mis.sr_instance_id = tp2.sr_instance_id
  and  mis.organization_id = tp2.sr_tp_id
  and  tp2.partner_type = 3
  and  item1.plan_id = mis.plan_id
  and  item1.sr_instance_id = mis.sr_instance_id
  and  item1.organization_id = mis.organization_id
  and  item1.inventory_item_id = mis.inventory_item_id
UNION
SELECT  distinct tp.sr_instance_id,
                 sd.publisher_id,
                 sd.publisher_name,
                 sd.publisher_site_id,
                 sd.publisher_site_name,
                 sd.customer_name,
                 sd.customer_id,
                 sd.customer_site_name,
                 sd.customer_site_id,
                 sd.inventory_item_id,
                 sd.item_name,
                 sd.tp_quantity,
                 sd.tp_uom_code,
                 sd.receipt_date,
                 sd.bucket_type,
                 mpd.period_start_date,
                 mpd.next_Date-1,
		 mis.organization_id,
		 tp2.organization_code,
		 nvl(mis.delivery_calendar_code,G_MSC_X_DEF_CALENDAR),
		 --mis.DELIVERY_CALENDAR_CODE,
		 map2.tp_key,
		 map3.tp_key,
		 item1.ROUNDING_CONTROL_TYPE
FROM   msc_sup_dem_entries_v sd,
       msc_trading_partner_maps map1,
       msc_trading_partners tp,
       msc_system_items item,
       MSC_PERIOD_START_DATES mpd,
       msc_company_relationships cr,
       msc_trading_partner_maps  map2,
       msc_trading_partner_maps  map3,
       msc_item_suppliers        mis,
       msc_trading_partners      tp2,
       msc_system_items          item1
WHERE  sd.plan_id = -1
  AND  sd.publisher_order_type = SUPPLY_COMMIT
  AND  sd.bucket_Type = G_MONTH
  AND  map1.tp_key = tp.partner_id
  AND  map1.map_type = 2  -- company
  AND  map1.company_key = sd.customer_site_id
  AND  sd.customer_id = 1        --OEM
  AND  tp.partner_type = 3
  AND  tp.company_id is null
  AND  item.plan_id = -1
  AND  sd.inventory_item_id = item.inventory_item_id
  AND  item.sr_instance_id = tp.sr_instance_id
  AND  item.organization_id = tp.sr_tp_id
  --AND  sd.quantity > 0
  AND  nvl(item.abc_class_name,-1) = nvl(nvl(p_abc_class, item.abc_class_name),-1)
  AND  nvl(item.planner_code,-1) = nvl(nvl(p_planner, item.planner_code),-1)
  AND  item.inventory_item_id = nvl(p_item_id,item.inventory_item_id)
  AND  sd.publisher_id = nvl(p_sce_supplier_id,sd.publisher_id)
  AND  sd.publisher_site_id = nvl(p_sce_supplier_site_id,sd.publisher_site_id)
  AND  trunc(sd.receipt_date) between nvl(trunc(p_horizon_start_date),sd.receipt_date)
                                  and nvl(trunc(p_horizon_end_date),sd.receipt_date)
  AND  mpd.sr_instance_id = decode(mis.delivery_calendar_code,null,p_cal_sr_instance_id
                                                         ,tp.sr_instance_id)
  AND  mpd.CALENDAR_CODE = nvl(mis.delivery_calendar_code,G_MSC_X_DEF_CALENDAR)
  AND  mpd.EXCEPTION_SET_ID = -1
  AND  to_char(sd.receipt_date,'J') between to_char(mpd.PERIOD_START_DATE,'J')
		                        and to_char(mpd.NEXT_DATE,'J')
  AND  to_char(sd.receipt_date,'J') < TO_CHAR(mpd.NEXT_DATE,'J')
  and  cr.object_id = sd.publisher_id
  and  cr.subject_id = sd.customer_id
  and  cr.relationship_type = 2
  and  map2.map_type = 1
  and  map2.company_key = cr.relationship_id
  and  map3.map_type = 3
  and  map3.company_key = sd.publisher_site_id
  and  mis.plan_id = -1
  and  mis.sr_instance_id = item.sr_instance_id
  --and mis.ORGANIZATION_ID = item.ORGANIZATION_ID
  and  mis.INVENTORY_ITEM_ID =  item.INVENTORY_ITEM_ID
  and  mis.SUPPLIER_ID = map2.tp_key
  and  mis.SUPPLIER_SITE_ID = map3.tp_key
  and  mis.using_organization_id = -1
  and  mis.sr_instance_id = tp2.sr_instance_id
  and  mis.organization_id = tp2.sr_tp_id
  and  tp2.partner_type = 3
  and  item1.plan_id = mis.plan_id
  and  item1.sr_instance_id = mis.sr_instance_id
  and  item1.organization_id = mis.organization_id
  and  item1.inventory_item_id = mis.inventory_item_id
;

CURSOR sum_receive_capacity_c(p_horizon_start_date   IN DATE,
                              p_horizon_end_date     IN DATE,
                              p_abc_class            IN VARCHAR2,
                              p_item_id              IN NUMBER,
                              p_planner              IN VARCHAR2,
                              p_sce_supplier_id      IN NUMBER,
                              p_sce_supplier_site_id IN NUMBER,
                              p_bucket_type          IN NUMBER) IS
SELECT sum(sd.tp_quantity)
FROM   msc_sup_dem_entries_v sd,
       msc_trading_partner_maps map1,
       msc_trading_partners tp,
       msc_system_items item
WHERE  sd.plan_id = -1
  AND  sd.publisher_order_type = SUPPLY_COMMIT
  AND  map1.tp_key = tp.partner_id
  AND  map1.map_type = 2  -- company
  AND  map1.company_key = sd.customer_site_id
  AND  sd.customer_id = 1        --OEM
  AND  tp.partner_type = 3
  AND  tp.company_id is null
  AND  item.plan_id = -1
  AND  sd.inventory_item_id = item.inventory_item_id
  AND  item.sr_instance_id = tp.sr_instance_id
  AND  item.organization_id = tp.sr_tp_id
  --AND  sd.quantity > 0
  AND  nvl(item.abc_class_name,-1) = nvl(nvl(p_abc_class, item.abc_class_name),-1)
  AND  nvl(item.planner_code,-1) = nvl(nvl(p_planner, item.planner_code),-1)
  AND  item.inventory_item_id = nvl(p_item_id,item.inventory_item_id)
  AND  sd.publisher_id = nvl(p_sce_supplier_id,sd.publisher_id)
  AND  sd.publisher_site_id = nvl(p_sce_supplier_site_id,sd.publisher_site_id)
  AND  trunc(sd.receipt_date) between nvl(trunc(p_horizon_start_date),sd.receipt_date)
                                  and nvl(trunc(p_horizon_end_date),sd.receipt_date)
  AND  sd.bucket_Type = p_bucket_type;

   PROCEDURE LOG_MESSAGE( pBUFF                     IN  VARCHAR2)
   IS
   BEGIN
	  IF ( G_MSC_CP_DEBUG= '1' OR G_MSC_CP_DEBUG = '2') THEN
		 FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
	  END IF;
   EXCEPTION
     WHEN OTHERS THEN
        RETURN;
   END LOG_MESSAGE;

PROCEDURE receive_capacity(p_errbuf OUT NOCOPY VARCHAR2,
        p_retcode 		OUT NOCOPY VARCHAR2,
   	p_horizon_start_date 	In Varchar2,
   	p_horizon_end_date 	In Varchar2,
   	p_abc_class 		In Varchar2,
   	p_item_id 		In Number,
   	p_planner 		In Varchar2,
   	p_supplier_id 		IN number,
   	p_supplier_site_id 	In Number,
   	p_mps_designator_id 	IN Number,
   	p_overwrite 		in Number,
   	p_spread 		in number) IS

l_sr_instance_id     		msc_trading_partners.sr_instance_id%type;
l_sce_supplier_id    		msc_sup_dem_entries.publisher_id%type;
l_sce_supplier_site_id     	msc_sup_dem_entries.publisher_site_id%type;
l_sce_supplier_name     	msc_sup_dem_entries.publisher_name%type;
l_sce_supplier_site_name   	msc_sup_dem_entries.publisher_site_name%type;
l_sce_customer_id    		msc_sup_dem_entries.customer_id%type;
l_sce_customer_site_id     	msc_sup_dem_entries.customer_site_id%type;
l_sce_customer_name    		msc_sup_dem_entries.customer_name%type;
l_sce_customer_site_name   	msc_sup_dem_entries.customer_site_name%type;
l_sce_company_id     		msc_companies.company_id%type;
l_map_supplier_id    		msc_sup_dem_entries.publisher_id%type;
l_map_supplier_site_id     	msc_sup_dem_entries.publisher_site_id%type;
l_item_id         		msc_sup_dem_entries.inventory_item_id%type;
l_item_name       		msc_items.item_name%type;
l_uom_code        		msc_sup_dem_entries.uom_code%type;
l_receipt_date       		msc_sup_dem_entries.receipt_date%type;
l_sr_tp_id        		msc_trading_partners.sr_tp_id%type;
l_modeled_supplier_id      	msc_trading_partners.modeled_supplier_id%type;
l_modeled_supplier_site_id 	msc_trading_partners.modeled_supplier_site_id%type;
l_calendar_code                 msc_trading_partners.calendar_code%type;
l_aps_organization_id      	msc_item_suppliers.organization_id%type;
l_aps_supplier_id    		msc_item_suppliers.supplier_id%type;
l_aps_supplier_site_id     	msc_item_suppliers.supplier_site_id%type;
l_rounding_control              number;
l_bucket_type        		msc_sup_dem_entries.bucket_type%type;
l_org_code        		msc_trading_partners.organization_code%type;
l_plan_id         		Number := -1;     --ods load
l_collected_flag     		Number := 3;      --means from destination
l_capacity        		Number;
l_err_text        		Varchar2(2000);
l_refresh_number     		Number;
l_total_record_fetch    	Number := 0;
insert_row_count     		Number := 0;
l_exist           		Number := 0;
l_err_msg         		Varchar2(1000);

ITEM_NOT_FOUND       		EXCEPTION;
SUPPLIER_NOT_FOUND      	EXCEPTION;
SUPPLIER_SITE_NOT_FOUND    	EXCEPTION;
CAPACITY_IS_NULL     		EXCEPTION;
START_DATE_IS_NULL      	EXCEPTION;
BUCKET_TYPE_IS_NULL     	EXCEPTION;
ITEM_SUPPLIER_NOT_FOUND    	EXCEPTION;

v_row_status         CONSTANT NUMBER := 10;
v_sr_instance_id     CONSTANT NUMBER := -1;

lv_start_date        DATE;
lv_end_date          DATE;

l_horizon_start	 	    date;		--canonical date
l_horizon_end		    date;		--canonical date

/*------------------------------------------------------------------
  Get all the organization for that instance
  ASCP does not deal with Supplier Capacity definition at the Organization
  level , as you know we apply the supplier capacity across all Orgs in
  the instance.

Cursor get_org_c(p_sr_instance_id IN Number) IS
SELECT    distinct sr_tp_id, organization_code
FROM   msc_trading_partners
WHERE  sr_instance_id =  p_sr_instance_id
AND    partner_type = 3
AND    company_id is null; -- if type is 3 (org) then use sr_tp_id



cursor get_global_asl (p_sr_instance_id In Number,
			p_aps_supplier_id In Number,
			p_aps_supplier_site_id In Number,
			p_item_id In Number) IS
SELECT  distinct mis.organization_id, tp.organization_code
FROM	msc_item_suppliers mis, msc_trading_partners tp
WHERE	plan_id = -1
AND	mis.sr_instance_id = p_sr_instance_id
AND	mis.supplier_id = p_aps_supplier_id
AND	mis.supplier_site_id = p_aps_supplier_site_id
AND	mis.inventory_item_id = p_item_id
AND	mis.using_organization_id = -1
AND	tp.sr_instance_id = mis.sr_instance_id
AND	tp.sr_tp_id = mis.organization_id;

----------------------------------------------------------------------*/

BEGIN

  LOG_MESSAGE('*****************************************************');
  fnd_message.set_name('MSC','MSC_PUB_INPUT_DATE_RANGE');
  LOG_MESSAGE( fnd_message.get || ' '  || p_horizon_start_date || '  ' || p_horizon_end_date);
  fnd_message.set_name('MSC','MSC_PUB_INPUT_SUPPLIER');
  LOG_MESSAGE( 'Supplier id: ' || p_supplier_id || ' Supplier site id: ' || p_supplier_site_id);
  fnd_message.set_name('MSC','MSC_PUB_INPUT_ITEM');
  LOG_MESSAGE( fnd_message.get || ' '|| p_item_id);

  --LOG_MESSAGE( 'Input calendar code: ' || p_calendar_code);

   /*----------------------------------------------------------
   get the refresh number
   ----------------------------------------------------------*/
   select msc_collection_s.nextval
   into l_refresh_number
   from dual;

   /*----------------------------------------------------------
   get the instance id for the Default Calendar
   Added this code for bug# 3431898
   ----------------------------------------------------------*/
   if (G_MSC_X_DEF_CALENDAR is not null) then

      begin
	    select sr_instance_id
	      into G_CAL_INSTANCE_ID
	      from msc_calendar_dates
	     where calendar_code = G_MSC_X_DEF_CALENDAR
	       and rownum = 1;
	      LOG_MESSAGE( 'Calendar from Profile: ' || G_MSC_X_DEF_CALENDAR);
	      LOG_MESSAGE( 'Instance id : ' || G_CAL_INSTANCE_ID);
      exception
         when others then
	      LOG_MESSAGE( 'Error in getting sr_instance_id for Calendar.');
	      G_CAL_INSTANCE_ID := -1;
      end;

   end if;

   /*-------------------------------------------------------
       Map the supplier_id in ASCP to the supplier_id in SCE
       and make sure the supplier has a relationship in SCE
       as supplier
    ---------------------------------------------------------*/
--LOG_MESSAGE('Start map the supplier_id');
   BEGIN
      SELECT   distinct c.company_id
        INTO   l_map_supplier_id
      FROM     msc_trading_partner_maps map1,
               msc_company_relationships rel,
               msc_companies c,
               msc_trading_partners tp
      WHERE   rel.relationship_type =2 AND  --supplier
              rel.object_id = c.company_id AND
              rel.subject_id = 1 AND     --other company (OEM)
              rel.relationship_id = map1.company_key AND
              map1.tp_key = tp.partner_id AND
              map1.map_type = 1 AND      --company
              tp.partner_id = p_supplier_id AND
              tp.partner_type = 1;
    EXCEPTION
      WHEN no_data_found then
         LOG_MESSAGE('No data found when map the supplier_id');
         l_map_supplier_id := null;
      when others then
         LOG_MESSAGE('Error in map supplier_id' || sqlerrm);
         l_map_supplier_id := null;
    END;

LOG_MESSAGE('company_id is : ' || l_map_supplier_id  );
   /*------------------------------------------------------------------------
       Map the supplier_site_id in ASCP to the supplier_site_id in SCE
    ----------------------------------------------------------------------*/
--LOG_MESSAGE('Start map the supplier_site_id');
   BEGIN
      SELECT   distinct s.company_site_id
      INTO  l_map_supplier_site_id
      FROM  msc_trading_partner_maps map1,
         msc_companies c,
         msc_company_sites s,
         msc_trading_partners tp,
         msc_trading_partner_sites tps
      WHERE map1.map_type = 3 AND
         map1.tp_key = tps.partner_site_id AND
         tps.partner_site_id = p_supplier_site_id AND
         tp.partner_id = tps.partner_id AND
         tp.partner_type = 1 AND
         map1.company_key = s.company_site_id AND
         s.company_id = c.company_id;
    EXCEPTION
      WHEN no_data_found then
         LOG_MESSAGE('No data found when map the supplier_site_id');
         l_map_supplier_site_id := null;
      when others then
         LOG_MESSAGE('Error in map supplier_site_id' || sqlerrm);
         l_map_supplier_site_id := null;
    END;

LOG_MESSAGE('company site id  is : ' || l_map_supplier_site_id  );


  --------------------------------------------------------------------------
  -- set the standard date as canonical date
  --------------------------------------------------------------------------
  l_horizon_start := fnd_date.canonical_to_date(p_horizon_start_date);
  l_horizon_end := fnd_date.canonical_to_date(p_horizon_end_date);


   /*-----------------------------------------------------------
      Start receive supply commit
   ------------------------------------------------------------*/

  LOG_MESSAGE('Start the receive capacity cursor');
LOG_MESSAGE('p_horizon_end_date  : ' || p_horizon_end_date  );
LOG_MESSAGE('p_abc_class  : ' || p_abc_class  );
LOG_MESSAGE('p_item_id  : ' || p_item_id  );
LOG_MESSAGE('p_planner  : ' || p_planner  );
LOG_MESSAGE('p_supplier_id : '||p_supplier_id);
LOG_MESSAGE('p_supplier_site_id : '||p_supplier_site_id);
LOG_MESSAGE('l_map_supplier_id  : ' || l_map_supplier_id  );
LOG_MESSAGE('l_map_supplier_site_id  : ' || l_map_supplier_site_id  );
LOG_MESSAGE('********************************************************');

--bug 4859926

IF  ((p_overwrite = 1) OR (p_horizon_start_date is null and p_horizon_end_date is null))
THEN
   begin

	DELETE  msc_supplier_capacities
	WHERE	plan_id = -1
	AND	inventory_item_id = nvl(p_item_id , inventory_item_id)
	AND	supplier_id = nvl(p_supplier_id , supplier_id)
	AND	supplier_site_id = nvl(p_supplier_site_id , supplier_site_id)
	AND	using_organization_id = -1 ;

	LOG_MESSAGE( 'Delete all record ' ||sql%rowcount);
   exception
   	WHEN no_data_found then
         LOG_MESSAGE('No record to be deleted in msc_supplier_capacities.');
	WHEN OTHERS THEN
         log_message('Error while deleting records for overwrite_all option.');
   end;

ELSIF (p_overwrite = 2) THEN

  /*--------------------------------------------------------------------------
  deleting capacity between the horizon dates and leave the 2 ends
  ---------------------------------------------------------------------------*/
  begin
	DELETE  msc_supplier_capacities
	WHERE	plan_id = -1
	AND	inventory_item_id = nvl(p_item_id , inventory_item_id)
	AND	supplier_id = nvl(p_supplier_id , supplier_id)
	AND	supplier_site_id = nvl(p_supplier_site_id , supplier_site_id)
	AND	using_organization_id = -1
	AND	(((from_date between nvl(l_horizon_start,from_date) and nvl(l_horizon_end,from_date))
	AND	(to_date between nvl(l_horizon_start,to_date) and nvl(l_horizon_end,to_date)))
	OR (collected_flag in (1, 2)));
	-- bug 5208105

	LOG_MESSAGE('Delete based on horizon_date ' ||sql%rowcount);

  exception
   	WHEN no_data_found then
         LOG_MESSAGE('No record to be deleted in msc_supplier_capacities for overwrite_all option.');
	WHEN OTHERS THEN
         log_message('Error while deleting records for overwrite_all option.'||sqlcode);
	 log_message(sqlerrm);
  end;

  END IF;

------

   open receive_capacity_c(l_horizon_start,
      l_horizon_end,
      p_abc_class,
      p_item_id,
      p_planner,
      G_CAL_INSTANCE_ID,
      l_map_supplier_id,
      l_map_supplier_site_id);

   LOOP
      FETCH receive_capacity_c into
               l_sr_instance_id,
               l_sce_supplier_id,
               l_sce_supplier_name,
               l_sce_supplier_site_id,
               l_sce_supplier_site_name,
               l_sce_customer_name,
               l_sce_customer_id,
               l_sce_customer_site_name,
               l_sce_customer_site_id,
               l_item_id,
               l_item_name,
               l_capacity,
               l_uom_code,
               l_receipt_date,
               l_bucket_type,
               lv_start_date,
               lv_end_date,
	       l_aps_organization_id,
	       l_org_code,
	       l_calendar_code,
	       l_aps_supplier_id,
	       l_aps_supplier_site_id,
	       l_rounding_control;

      LOG_MESSAGE('=======================================================');
      LOG_MESSAGE('l_sr_instance_id  : ' || l_sr_instance_id  );
      LOG_MESSAGE('l_sce_supplier_id  : ' || l_sce_supplier_id  );
      LOG_MESSAGE('l_sce_supplier_name  : ' || l_sce_supplier_name  );
      LOG_MESSAGE('l_sce_supplier_site_id  : ' || l_sce_supplier_site_id  );
      LOG_MESSAGE('l_sce_supplier_site_name  : ' || l_sce_supplier_site_name  );
      LOG_MESSAGE('l_sce_customer_name  : ' || l_sce_customer_name  );
      LOG_MESSAGE('l_sce_customer_id  : ' || l_sce_customer_site_name  );
      LOG_MESSAGE('l_sce_customer_site_id  : ' || l_sce_customer_site_id  );
      LOG_MESSAGE('l_item_id  : ' || l_item_id  );
      LOG_MESSAGE('l_item_name  : ' || l_item_name  );
      LOG_MESSAGE('l_capacity  : ' || l_capacity  );
      LOG_MESSAGE('l_bucket_type  : ' || l_bucket_type  );
      LOG_MESSAGE('l_receipt_date  : ' || l_receipt_date  );
      LOG_MESSAGE('lv_start_date  : ' || lv_start_date  );
      LOG_MESSAGE('lv_end_date  : ' || lv_end_date  );
      LOG_MESSAGE('l_calendar_code  : ' || l_calendar_code  );
      LOG_MESSAGE('l_org_code  : ' || l_org_code  );
      LOG_MESSAGE('l_aps_supplier_id  : ' || l_aps_supplier_id  );
      LOG_MESSAGE('l_aps_supplier_site_id  : ' || l_aps_supplier_site_id  );
      LOG_MESSAGE('l_aps_organization_id : '||l_aps_organization_id);
      LOG_MESSAGE('=======================================================');

      exit when receive_capacity_c%NOTFOUND;

   begin
/***********************************************************************************

	   IF (p_supplier_id is null ) THEN
	      begin
		      SELECT   distinct tp.partner_id
			 INTO  l_aps_supplier_id
			 FROM  msc_trading_partner_maps map1,
			    msc_company_relationships rel,
			    msc_item_suppliers sup,
			    msc_trading_partners tp
			 WHERE rel.relationship_type =2 AND  --supplier
			    rel.object_id = l_sce_supplier_id AND
			    rel.subject_id = 1 AND     --other company (OEM)
			    rel.relationship_id = map1.company_key AND
			    map1.tp_key = tp.partner_id AND
			    map1.map_type = 1 AND      --company
			    sup.plan_id = -1 AND
			    sup.inventory_item_id = l_item_id AND
			    tp.partner_id = sup.supplier_id AND
			    tp.partner_type = 1;
	      exception
		 when no_data_found then
		           --LOG_MESSAGE('supplier not found in sce map ');
		           --raise SUPPLIER_NOT_FOUND;
		           null;
	      end;
	   ELSE
	      l_aps_supplier_id := p_supplier_id;
	   END IF;

	       LOG_MESSAGE('APS supplier ' || l_aps_supplier_id);
	       LOG_MESSAGE('Sce supplier site id ' || l_sce_supplier_site_id);


	   IF (p_supplier_site_id is null) THEN
	      begin
		      SELECT   distinct tps.partner_site_id
			 INTO  l_aps_supplier_site_id
			 FROM  msc_trading_partner_maps map1,
			    msc_companies c,
			    msc_company_sites s,
			    msc_trading_partners tp,
			    msc_trading_partner_sites tps
			 WHERE map1.map_type = 3 AND
			    map1.tp_key = tps.partner_site_id AND
			    tp.partner_id = tps.partner_id AND
			    map1.company_key = s.company_site_id AND
			    s.company_site_id = l_sce_supplier_site_id AND
			    s.company_id = c.company_id AND
			    c.company_id = l_sce_supplier_id AND
			    nvl(tp.company_id,1) = 1;
	      exception
		      when no_data_found then
		           --LOG_MESSAGE('supplier site not found in sce map ');
		           --raise SUPPLIER_SITE_NOT_FOUND;
		           null;
	      end;
	   ELSE
	      l_aps_supplier_site_id := p_supplier_site_id;
	   END IF;

	      LOG_MESSAGE('APS supplier site ' || l_aps_supplier_site_id);
***********************************************************************************/
-- Added for bug # 4560149

 IF (p_supplier_id is null ) THEN
  BEGIN
  SELECT   distinct c.company_id
        INTO   l_map_supplier_id
      FROM     msc_trading_partner_maps map1,
               msc_company_relationships rel,
               msc_companies c,
               msc_trading_partners tp
      WHERE   rel.relationship_type =2 AND  --supplier
              rel.object_id = c.company_id AND
              rel.subject_id = 1 AND     --other company (OEM)
              rel.relationship_id = map1.company_key AND
              map1.tp_key = tp.partner_id AND
              map1.map_type = 1 AND      --company
              tp.partner_id = l_aps_supplier_id AND
              tp.partner_type = 1;

   log_message('Here l_map_supplier_id : '||l_map_supplier_id) ;
  exception
		 when no_data_found then
		           LOG_MESSAGE('supplier not found in sce map ');
	      when others then
		           LOG_MESSAGE('Error : '||sqlerrm);

  end;
END IF;

IF (p_supplier_site_id is null ) THEN
  Begin
   SELECT   distinct s.company_site_id
      INTO  l_map_supplier_site_id
      FROM  msc_trading_partner_maps map1,
         msc_companies c,
         msc_company_sites s,
         msc_trading_partners tp,
         msc_trading_partner_sites tps
      WHERE map1.map_type = 3 AND
         map1.tp_key = tps.partner_site_id AND
         tps.partner_site_id = l_aps_supplier_site_id AND
         tp.partner_id = tps.partner_id AND
         tp.partner_type = 1 AND
         map1.company_key = s.company_site_id AND
         s.company_id = c.company_id;

    log_message('Here l_map_supplier_site_id : '||l_map_supplier_site_id) ;
    exception
		 when no_data_found then
		           LOG_MESSAGE('supplier site not found in sce map ');
	      when others then
		           LOG_MESSAGE('Error : '||sqlerrm);

  end;
END IF;

   IF l_capacity is null then
	      raise CAPACITY_IS_NULL;
   END IF;

   /*IF l_receipt_date is null then
	      raise START_DATE_IS_NULL;
   END IF; */

   IF l_bucket_type is null then
	      raise BUCKET_TYPE_IS_NULL;
   END IF;

   /*----------------------------------------------------------------------
      Start populate the capacity
   ------------------------------------------------------------------------*/

/***********************************************************************************
   OPEN get_global_asl (l_sr_instance_id,
			l_aps_supplier_id,
   		        l_aps_supplier_site_id,
			l_item_id);
   LOOP
      FETCH get_global_asl into l_aps_organization_id, l_org_code;
	              exit when get_global_asl%NOTFOUND;

		LOG_MESSAGE('************************************************************');
		LOG_MESSAGE('Process record: ' || 'Item Name: ' ||
			l_item_name || ' Org: ' || l_org_code || ' Supplier: ' ||
			l_sce_supplier_name ||' Date: ' ||  l_receipt_date ||
			' Bucket ' || l_bucket_type || ' Capacity: ' || l_capacity );

***********************************************************************************/

      IF (l_bucket_type = G_DAY) THEN
          l_capacity := l_capacity;

       log_message('Bkt Day, l_capacity : '||l_capacity);
      ELSE

	  open sum_receive_capacity_c(lv_start_date,
			              lv_end_date,
				      p_abc_class,
				      l_item_id,
			              p_planner,
				      l_map_supplier_id,
				      l_map_supplier_site_id,
				      l_bucket_type);

          fetch sum_receive_capacity_c into l_capacity;
	  close sum_receive_capacity_c;

	  log_message('Inside Cursor sum_receive_capacity_c; l_capacity : '||l_capacity);

      END IF;

	Calculate_Capacity(l_sr_instance_id,
			   l_aps_organization_id,
			   l_aps_supplier_id,
			   l_aps_supplier_site_id,
			   p_mps_designator_id,
			   l_item_id,
			   l_receipt_date,
			   l_capacity,
			   l_bucket_type,
			   l_calendar_code,
			   l_refresh_number,
			   lv_start_date,
			   lv_end_date,
			   l_horizon_start,
			   l_horizon_end,
			   p_overwrite,
			   p_abc_class,
			   p_planner,
			   l_map_supplier_id,
			   l_map_supplier_site_id,
			   l_rounding_control,
			   p_spread);

/***********************************************************************************
   END LOOP;

   CLOSE get_global_asl;

***********************************************************************************/
   EXCEPTION
      WHEN ITEM_NOT_FOUND THEN

	      fnd_message.set_name('MSC','MSC_PUB_RECORD_FAIL');
	      l_err_msg := fnd_message.get;

	      fnd_message.set_name('MSC','MSC_PUB_ITEM_NOT_FOUND');
			FND_MESSAGE.SET_TOKEN('ITEM', l_item_name);
			LOG_MESSAGE('Item not found');
	      l_err_text := l_err_msg || ' ' || 'Item Name ' || l_item_name || ' ' ||
		 ' Org: ' || l_org_code || ' ' ||
				' Supplier: ' || l_sce_supplier_name || ' ' ||
				' Supplier Site: ' || l_sce_supplier_site_name || ' ' ||
				' Capacity: ' || l_capacity || ' ' ||
				' Start Date: ' || l_receipt_date ||  '->' || fnd_message.get;
			LOG_MESSAGE( l_err_text);

      WHEN SUPPLIER_NOT_FOUND THEN
	      fnd_message.set_name('MSC','MSC_PUB_RECORD_FAIL');
	      l_err_msg := fnd_message.get;

	      fnd_message.set_name('MSC','MSC_PUB_SUPPLIER_NOT_FOUND');
			FND_MESSAGE.SET_TOKEN('SUPPLIER', l_sce_supplier_name);
			LOG_MESSAGE('supplier not found');
	      l_err_text := l_err_msg || ' ' || 'Item Name: ' || l_item_name || ' ' ||
		 'Org: ' || l_org_code || ' ' ||
				'Supplier: ' || l_sce_supplier_name || ' ' ||
				'Supplier Site: ' || l_sce_supplier_site_name || ' ' ||
				'Capacity: ' || l_capacity || ' ' ||
				'Start Date: ' || l_receipt_date ||  '->' || fnd_message.get;
			LOG_MESSAGE( l_err_text);

      WHEN SUPPLIER_SITE_NOT_FOUND THEN
	      fnd_message.set_name('MSC','MSC_PUB_RECORD_FAIL');
	      l_err_msg := fnd_message.get;

	      fnd_message.set_name('MSC','MSC_PUB_SUP_SITE_NOT_FOUND');
			FND_MESSAGE.SET_TOKEN('SUPPLIER_SITE', l_sce_supplier_site_name);
			LOG_MESSAGE('supplier site not found');
	      l_err_text := l_err_msg || ' '  || 'Item Name ' || l_item_name || ' ' ||
		 'Org: ' || l_org_code || ' ' ||
				'Supplier: ' || l_sce_supplier_name || ' ' ||
				'Supplier Site: ' || l_sce_supplier_site_name || ' ' ||
				'Capacity: ' || l_capacity || ' ' ||
				'Start Date: ' || l_receipt_date ||  '->' || fnd_message.get;
			LOG_MESSAGE( l_err_text);

      WHEN CAPACITY_IS_NULL THEN
	      fnd_message.set_name('MSC','MSC_PUB_RECORD_FAIL');
	      l_err_msg := fnd_message.get;

	       fnd_message.set_name('MSC','MSC_PUB_CAPACITY_IS_NULL');
			LOG_MESSAGE('Null capacity');
	      l_err_text := l_err_msg || ' ' || 'Item Name ' || l_item_name || ' ' ||
		 'Org: ' || l_org_code || ' ' ||
				'Supplier: ' || l_sce_supplier_name || ' ' ||
				'Supplier Site: ' || l_sce_supplier_site_name || ' ' ||
				'Capacity: ' || l_capacity || ' ' ||
				'Start Date: ' || l_receipt_date ||  '->' || fnd_message.get;
			LOG_MESSAGE( l_err_text);

      WHEN START_DATE_IS_NULL THEN
	      fnd_message.set_name('MSC','MSC_PUB_RECORD_FAIL');
	      l_err_msg := fnd_message.get;

	       fnd_message.set_name('MSC','MSC_PUB_START_DATE_IS_NULL');
			LOG_MESSAGE('start date is null');
	      l_err_text := l_err_msg || ' '  || 'Item Name ' || l_item_name || ' ' ||
		 'Org: ' || l_org_code || ' ' ||
				'Supplier: ' || l_sce_supplier_name || ' ' ||
				'Supplier Site: ' || l_sce_supplier_site_name || ' ' ||
				'Capacity: ' || l_capacity || '-' ||
				'Start Date: ' || l_receipt_date ||  '->' || fnd_message.get;
			LOG_MESSAGE( l_err_text);

      WHEN BUCKET_TYPE_IS_NULL THEN

	      fnd_message.set_name('MSC','MSC_PUB_RECORD_FAIL');
	      l_err_msg := fnd_message.get;

	      fnd_message.set_name('MSC','MSC_PUB_BUCKET_TYPE_IS_NULL');
			LOG_MESSAGE('bucket type is null');
	      l_err_text := l_err_msg || ' ' || 'Item Name ' || l_item_name || ' ' ||
		 'Org: ' || l_org_code || ' ' ||
				'Supplier: ' || l_sce_supplier_name || ' ' ||
				'Supplier Site: ' || l_sce_supplier_site_name || ' ' ||
				'Capacity: ' || l_capacity || ' ' ||
				'Start Date: ' || l_receipt_date ||  '->' || fnd_message.get;
			LOG_MESSAGE( l_err_text);

   END;

   l_total_record_fetch := l_total_record_fetch + 1;

   END LOOP;

   CLOSE receive_capacity_c;

   fnd_message.set_name('MSC','MSC_PUB_TOTAL_RECORD_FETCHED');
   FND_FILE.PUT_LINE(FND_FILE.LOG, fnd_message.get || ' ' || l_total_record_fetch);
   /*---------------------------------------------------------------------------
    | Now update back the current data that are receiving from exchange
    -------------------------------------------------------------------------*/
    begin
      update msc_supplier_capacities
      set last_update_login = null
      where plan_id = -1
      and last_update_login = -999;

      update msc_supplies
      set last_update_login = null
      where plan_id = -1
      and order_type = 5
      and last_update_login = -999;

    exception
      when others then
      LOG_MESSAGE( sqlerrm);
    end;

    -- launch ASCP engine with default constrained plan
  IF ( FND_PROFILE.VALUE('MSC_DEFAULT_CONST_PLAN') IS NOT NULL
     ) THEN
    BEGIN
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Launching ASCP engine with default constrained plan');
      MSC_X_CP_FLOW.Start_ASCP_Engine_WF
      ( p_constrained_plan_flag => 1 -- launch with constrained plan
      );
    EXCEPTION
      WHEN OTHERS THEN
        MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_CP_FLOW.Start_ASCP_Engine_WF');
        MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
    END;
  ELSE
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Please set up default constrained plan');
  END IF;

EXCEPTION
   when others then
      p_errbuf := sqlerrm;
                p_retcode := '2';         --other error
                LOG_MESSAGE( sqlerrm);
                LOG_MESSAGE('Error in main program ' || sqlerrm);
      return;
END receive_capacity;


------------------------------------------------------------------------
--CALCULATE_CAPACITY
------------------------------------------------------------------------
PROCEDURE Calculate_Capacity(p_sr_instance_id IN Number,
   	p_organization_id 	IN Number,
   	p_supplier_id  		IN Number,
   	p_supplier_site_id 	IN Number,
   	p_mps_designator_id 	IN Number,
   	p_item_id 		IN Number,
   	p_receipt_date 		IN date,
   	p_capacity 		IN Number,
   	p_bucket_type 		IN Number,
   	p_calendar_code 	IN varchar2,
   	p_refresh_number 	IN NUmber,
   	p_lv_start_date		IN Date,
	p_lv_end_date		IN Date,
   	p_horizon_start_date    In Date,
	p_horizon_end_date      In Date,
	p_overwrite             In Number,
        p_abc_class             in varchar2,
        p_planner               IN varchar2,
        p_map_supplier_id       IN number,
        p_map_supplier_site_id  IN number,
	p_rounding_control      IN number,
	p_spread		IN Number) IS

l_quantity        	Number;
l_from_date       	Date;
l_to_date		Date;
l_next_work_date	Date;
l_end_date		Date;
l_num_day         	Number;
i           		Number;
l_mod_org_id         	Number := -1;
l_mod_org_code       	msc_trading_partners.organization_code%type;
l_cal_sr_instance_id	Number;
l_cal_org_id		Number;
l_calendar_code		msc_trading_partners.calendar_code%type;

lv_avg number;
lv_diff number;
lv_new_x number;

l_week			number;
l_month			varchar2(100);
l_year			varchar2(100);
lv_sr_instance_id       number;


BEGIN

   if ( p_calendar_code = G_MSC_X_DEF_CALENDAR) then
       /* if the calendar is from profile, use the calendar's sr_instance_id
           for calendar  routines  */
        lv_sr_instance_id := G_CAL_INSTANCE_ID;
   else
	lv_sr_instance_id := p_sr_instance_id;
   end if;
     	/*--------------------------------------------------------------------
      	check if the supplier is modeled as org
      	--------------------------------------------------------------------*/
         BEGIN
            SELECT   distinct tp.sr_tp_id, tp.organization_code
            INTO  l_mod_org_id, l_mod_org_code
            FROM     msc_trading_partners tp
            WHERE tp.sr_instance_id = p_sr_instance_id AND
               tp.modeled_supplier_id = p_supplier_id AND
               tp.modeled_supplier_site_id = p_supplier_site_id AND
               tp.partner_type = 3 AND
               tp.company_id is null;
         EXCEPTION
            WHEN no_data_found then
            l_mod_org_id := -1;

         END;
      	--LOG_MESSAGE('Is supplier modeled as ORG:' || l_mod_org_id);

      	LOG_MESSAGE('p_spread :' || p_spread);
  IF (p_spread = 1) THEN

  l_end_date := last_day(p_receipt_date);

 ------------------------------------------------------------------------------
 -- Bug# 2678523
 -- Need to calculate the capacity with calendar code
 -- Reason: Example weekly bucket.  If we bring in 7-0 calendar code capacity,
 -- when running a plan based on a 5-2 calendar code, then will be missing 2 days
 -- capacities in PWB.
 -- Solution:  A new parameter for calendar code is introduced.  This LOV is a list
 -- of the calendar_code from msc_calendar_dates.  The default calendar code for
 -- this LOV is based on a production plan (from msc_designator where production = 1)
 -- If user not to choose any calendar code, or no calendar code is found, then
 -- we use the default 7-0 calendar.
 ---------------------------------------------------------------------------------

	  IF p_bucket_type = G_MONTH THEN	--monthly bucket
		l_num_day :=  MSC_CALENDAR.calendar_days_between
				       (lv_sr_instance_id,
					p_calendar_code,
					1,              --using '1' because need to find #days
					greatest(p_lv_start_date,sysdate),
					p_lv_end_date);

	  ELSIF p_bucket_type = G_WEEK then	--weekly
		l_num_day :=  MSC_CALENDAR.calendar_days_between
				       (lv_sr_instance_id,
					p_calendar_code,
					1,              --using '1' because need to find #days
					greatest(p_lv_start_date,sysdate),
					p_lv_end_date);
	  ELSIF p_bucket_type = G_DAY then	--day
		l_num_day :=  1;
	  END IF;

	  LOG_MESSAGE('Total capacity  : ' || p_capacity ||' to be spread on : '|| l_num_day || ' days.');

	  l_from_date := greatest(p_lv_start_date,sysdate);

	  lv_avg := p_capacity/l_num_day;
	  lv_diff := 0;

	  FOR i IN 1..l_num_day LOOP

		   if (p_rounding_control = SYS_YES)    then
				  /* if the Item Attribute Rounding flag is yes,
				     the qty should be whole number
				   */

			l_next_work_date := MSC_CALENDAR.calendar_next_work_day(lv_sr_instance_id,
						p_calendar_code,
						1,
						l_from_date);

			l_from_date := l_next_work_date;

			lv_new_x := lv_avg + lv_diff;

			l_quantity := round(lv_new_x);

			lv_diff := lv_new_x - l_quantity;
		   else

			   IF (instr( p_capacity/l_num_day, '.') = 0 ) THEN
				l_quantity := substr( p_capacity/l_num_day, 1, length(p_capacity/l_num_day));
			   ELSE
				l_quantity := substr( p_capacity/l_num_day, 1, instr(p_capacity/l_num_day, '.') + 2);
			   END IF;

		   end if;

	--	LOG_MESSAGE(' l_from_date : = '|| l_from_date);
	--	LOG_MESSAGE(' l_next_work_date : = '|| l_next_work_date);

		populate_Capacity(p_sr_instance_id,
			p_organization_id,
			p_supplier_id,
			p_supplier_site_id,
			p_item_id,
			l_from_date,
			l_quantity,
			p_refresh_number,
			p_lv_start_date,
			p_lv_end_date,
			p_horizon_start_date,
			p_horizon_end_date,
			p_overwrite
			);


		IF (l_mod_org_id <> -1 and l_mod_org_id = p_organization_id) THEN
		LOG_MESSAGE('Here in load supply schedule');
			Load_Supply_Schedule(p_sr_instance_id,
				p_organization_id,
				p_supplier_id,
				p_supplier_site_id,
				l_mod_org_id,
				l_mod_org_code,
				p_mps_designator_id,
				p_item_id,
				l_from_date,
				l_quantity,
				p_refresh_number
				);
		END IF;

		l_from_date := l_from_date + 1;
	   END LOOP;

  /*-----------------------------------------------------------------------------
        will not spread the supplier capacity into daily capacity.
        bring in the exact data from Collaborative planning
        Note: For monthly bucket and if the receipt date falls in the same month/year
            of the sysdate, use sysdate
           For weekly and if the receipt date falls in the same week/month/year
            of the sysdate, use sysdate
           For daily, as the receipt date
   ----------------------------------------------------------------------------*/

   ELSIF (p_spread = 2) THEN

   	l_from_date := p_receipt_date;
   	l_quantity := p_capacity;

      	select to_char(sysdate, 'MON') into l_month from dual;
      	select to_char(sysdate, 'YYYY') into l_year from dual;
      	select to_char(sysdate, 'W') into l_week from dual;


	  --log_message('p_receipt_date : ' ||p_receipt_date);
   	IF p_bucket_type = 3 THEN
   	 	--select last_day(l_from_date) into l_to_date from dual;

   		IF (to_char(p_receipt_date, 'MON') = l_month and
   			to_char(p_receipt_date, 'YYYY') = l_year ) THEN
   			l_from_date := sysdate + 1;
   		END IF;

   	ELSIF p_bucket_type = 2 THEN

   		--select p_receipt_date + 6 into l_to_date from dual;

   		IF (to_char(p_receipt_date, 'MON') = l_month and
   			to_char(p_receipt_date, 'YYYY') = l_year and
   			to_char(p_receipt_date, 'W') = l_week) THEN
   			l_from_date := sysdate + 1;
   		END IF;

   	END IF;

	  --log_message('l_from_date : ' ||l_from_date);
	l_next_work_date := MSC_CALENDAR.calendar_next_work_day
			       (lv_sr_instance_id,
				p_calendar_code,
				1,
				l_from_date);

	--  log_message('l_next_work_date : ' ||l_next_work_date);
	l_from_date := l_next_work_date;


      	populate_Capacity(p_sr_instance_id,
         		p_organization_id,
         		p_supplier_id,
         		p_supplier_site_id,
         		p_item_id,
         		l_from_date,
         		l_quantity,
         		p_refresh_number,
         		p_lv_start_date,
         		p_lv_end_date,
			p_horizon_start_date,
			p_horizon_end_date,
			p_overwrite
         		);

      	IF (l_mod_org_id <> -1 and l_mod_org_id = p_organization_id) THEN
      		--dbms_output.put_line('Here in load supply schedule');
         		Load_Supply_Schedule(p_sr_instance_id,
            		p_organization_id,
            		p_supplier_id,
            		p_supplier_site_id,
            		l_mod_org_id,
            		l_mod_org_code,
            		p_mps_designator_id,
            		p_item_id,
            		l_from_date,
            		l_quantity,
            		p_refresh_number
            		);
      	END IF;
   END IF;
EXCEPTION

  WHEN others THEN
   LOG_MESSAGE('Error in calcuate capacity ' || sqlerrm);
   LOG_MESSAGE( 'Calculate_capacity ' || sqlerrm);
END CALCULATE_CAPACITY;


------------------------------------------------------------------------------------
--POPULATE_CAPACITY
-----------------------------------------------------------------------------------
PROCEDURE Populate_Capacity(p_sr_instance_id IN Number,
				p_organization_id IN Number,
				p_supplier_id	IN Number,
				p_supplier_site_id IN Number,
				p_item_id IN Number,
				p_date IN Date,
				p_capacity IN Number,
				p_refresh_number In Number,
   				p_lv_start_date		IN Date,
				p_lv_end_date		IN Date,
				p_horizon_start_date in Date,
				p_horizon_end_date in Date,
				p_overwrite In Number) IS

/*-----------------------------------------------------------------------------
  if the overwrite is only horizon specific, then need to maintain
  the capacity not in the horizon range
  ----------------------------------------------------------------------------*/
cursor get_existing_capacity (p_sr_instance_id In Number,
				p_organization_id In Number,
				p_supplier_id In Number,
				p_supplier_site_id In Number,
				p_item_id In Number,
				p_date In Date,
				p_horizon_start_date In Date,
				p_horizon_end_date in Date) IS
SELECT  transaction_id,from_date, to_date, capacity
FROM	msc_supplier_capacities
WHERE	plan_id = -1
AND	sr_instance_id = p_sr_instance_id
AND	organization_id = p_organization_id
AND	inventory_item_id = p_item_id
AND	supplier_id = p_supplier_id
AND	supplier_site_id = p_supplier_site_id
AND	using_organization_id = -1
AND	nvl(last_update_login,-1) <> -999
AND	from_date <= nvl(p_horizon_end_date, from_date)
AND	nvl(to_date,p_horizon_start_date) >= nvl(p_horizon_start_date,to_date)
UNION
/*-----------------------------------------------------------------------
 this statement will take care where p_horizon_start_date is null
 and to_date is null
 -----------------------------------------------------------------------*/
SELECT  transaction_id,from_date, to_date, capacity
FROM	msc_supplier_capacities
WHERE	plan_id = -1
AND	sr_instance_id = p_sr_instance_id
AND	organization_id = p_organization_id
AND	inventory_item_id = p_item_id
AND	supplier_id = p_supplier_id
AND	supplier_site_id = p_supplier_site_id
AND	using_organization_id = -1
AND	nvl(last_update_login,-1) <> -999
AND	from_date <= nvl(p_horizon_start_date, from_date)
AND	nvl(to_date,p_horizon_end_date) >= nvl(p_horizon_end_date,to_date)
ORDER BY transaction_id;


l_from_date		date;
l_to_date		date;
l_original_capacity	Number;
l_exist			Number := 0;
l_trx_id		Number;

BEGIN


IF (p_overwrite = 2) THEN

  /*-------------------------------------------------------------------------
  Getting the 2 ends of the horizon date range then
  updating the 2 ends capacities

  ---------------------------------------------------------------------------*/

  open get_existing_capacity (p_sr_instance_id,
			p_organization_id,
			p_supplier_id,
			p_supplier_site_id,
			p_item_id,
			p_date,
			p_horizon_start_date,
			p_horizon_end_date);
  loop
  fetch get_existing_capacity into l_trx_id, l_from_date, l_to_date, l_original_capacity;
  exit when get_existing_capacity%NOTFOUND;

	--dbms_output.put_line('From dt ' || l_from_date || ' to dt ' || l_to_date);

	/*----------------------------------------------------------
	-- there is end date for the existing capacity in ASCP
	------------------------------------------------------------*/

	IF ( l_to_date is not null ) THEN
	   IF (p_horizon_start_date is not null) THEN
		IF (l_from_date < p_horizon_start_date ) then
		/*-------------------------------------------------------------------------
		 IF l_from_date < p_horizon_start_date -- update the from_date,
		 	then insert later when l_to_date > p_horizon_end_date
		 Also works for p_horizon_end_date is null -- just update the to_date
		 -------------------------------------------------------------------------*/

	   		UPDATE msc_supplier_capacities
   			set 	to_date = p_horizon_start_date -1
   			WHERE	plan_id = -1
   			and     transaction_id = l_trx_id;

			IF (l_to_date > p_horizon_end_date and p_horizon_end_date is not null) THEN
   				--dbms_output.put_line('INSERT ' || l_to_date || ' cap ' || l_original_capacity);
				insert_capacity(p_sr_instance_id,
					p_organization_id,
					p_supplier_id,
					p_supplier_site_id,
					p_item_id,
					p_horizon_end_date + 1,
					l_to_date,
					l_original_capacity,
					p_refresh_number);

			END IF;

	   	ELSIF (l_from_date >= p_horizon_start_date and
	   		l_to_date > p_horizon_end_date and
	   		p_horizon_end_date is not null) THEN
   	   			UPDATE msc_supplier_capacities
   				set 	from_date = p_horizon_end_date + 1
   				WHERE	plan_id = -1
   				and     transaction_id = l_trx_id;
		END IF;
	   END IF;
	   IF (p_horizon_start_date is null and
	     	l_to_date > p_horizon_end_date ) THEN
	     	   	UPDATE msc_supplier_capacities
	     		set 	from_date = p_horizon_end_date + 1
	     		WHERE	plan_id = -1
	     		and     transaction_id = l_trx_id;
   	   END IF;
	END IF;

	/*------------------------------------------------------
	This will take care if there is no end date for the
	existing capacity
	-------------------------------------------------------*/
	IF (l_to_date is null ) THEN

	   -- dbms_output.put_line('HN from dt ' || l_from_date || ' to dt ' || l_to_date || ' Trx ' || l_trx_id);
	    IF (p_horizon_end_date is not null) THEN
		/*-------------------------------------------------------------------------
		 IF l_from_date >= p_horizon_start_date -- just update from_date
		 IF l_from_date < p_horizon_start_date -- update the from_date, then insert later
		 IF l_from_date = p_horizon_end_date   -- just update the from_date
		 Also works for p_horizon_start_date is null -- just update the from_date
		 -------------------------------------------------------------------------*/
		--dbms_output.put_line('HZ ' || p_horizon_start_date || p_horizon_end_date);
		UPDATE msc_supplier_capacities
   		set 	from_date = p_horizon_end_date + 1,
   				to_date = null
   		WHERE	plan_id = -1
   		and transaction_id = l_trx_id;


   		IF (l_from_date < p_horizon_start_date and p_horizon_start_date is not null ) THEN
			insert_capacity (p_sr_instance_id,
				p_organization_id,
				p_supplier_id,
				p_supplier_site_id,
				p_item_id,
				l_from_date,
				p_horizon_start_date - 1,
				l_original_capacity,
				p_refresh_number);
   		END IF;

   	    ELSIF (p_horizon_end_date is null ) THEN
	    	IF (l_from_date >= p_horizon_start_date) THEN
	    		/*---------------------------------------------------------
	    		 IF p_horizon_end_date is null and l_to_date is null and
	    		 l_from_date is within the p_horizon_start_date, the trx
	    		 should be overwrite
	    		 --------------------------------------------------------*/
	    		delete msc_supplier_capacities
	    		where transaction_id = l_trx_id;
   	    	ELSIF (l_from_date < p_horizon_start_date ) THEN
 	    		UPDATE msc_supplier_capacities
	    		set to_date = p_horizon_start_date -1
	    		where plan_id = -1
	    		and   transaction_id = l_trx_id;
	    	END IF;

   	    END IF;
	END IF;
  end loop;
  close get_existing_capacity;
END IF;

insert_capacity(p_sr_instance_id,
				p_organization_id,
				p_supplier_id,
				p_supplier_site_id,
				p_item_id,
				p_date,
				p_date,
				p_capacity,
				p_refresh_number);


exception
	when others then
		--dbms_output.put_line('error in populate_capacity ' || sqlerrm);
		FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error in populate_capacity' ||  sqlerrm);
END POPULATE_CAPACITY;

------------------------------------------------------------------------------------
--INSERT_CAPACITY
------------------------------------------------------------------------------------
PROCEDURE Insert_Capacity(p_sr_instance_id IN Number,
            p_organization_id 		IN Number,
            p_supplier_id  		IN Number,
            p_supplier_site_id 		IN Number,
            p_item_id 			IN Number,
            p_from_date 		IN Date,
            p_to_date			IN Date,
            p_capacity 			IN Number,
            p_refresh_number 		In Number) IS

l_nextid    	Number;
l_user_id      	Number := fnd_global.user_id;
l_refresh_number  Number;
l_exist 	number := 0;
BEGIN


   --===========================================================================
   -- If the key date is not the working and is forward/backward to the
   -- working date, need to accumulate the capacity for the same date for the
   -- same run
   --===========================================================================
   begin
	  select count(*)
	  into 	l_exist
	  FROM	msc_supplier_capacities
	  WHERE	plan_id = -1
	  AND	sr_instance_id = p_sr_instance_id
	  AND	organization_id = p_organization_id
	  AND	inventory_item_id = p_item_id
	  AND	supplier_id = p_supplier_id
	  AND	supplier_site_id = p_supplier_site_id
	  AND	from_date = p_from_date
	  AND	to_date = p_to_date
	  AND	using_organization_id = -1
	  AND	nvl(last_update_login,-1) = -999;
   exception
   	when no_data_found then
   		l_exist := 0;
   	when others then
   		l_exist := 0;
   end;

   IF (l_exist > 0) THEN
  		--LOG_MESSAGE( 'update qty ' || p_capacity);
   			UPDATE msc_supplier_capacities
   			set capacity = capacity + p_capacity
   			WHERE	plan_id = -1
    			AND	sr_instance_id = p_sr_instance_id
   			AND	organization_id = p_organization_id
   			AND	inventory_item_id = p_item_id
   			AND	supplier_id = p_supplier_id
   			AND	supplier_site_id = p_supplier_site_id
   			AND	from_date = p_from_date
   			AND	to_date = p_to_date
			AND	using_organization_id = -1
   			AND	nvl(last_update_login,-1) = -999;

   ELSIF (l_exist = 0) THEN


      LOG_MESSAGE('insert capacity');
      select msc_supplier_capacities_s.nextval
      into l_nextid
      from dual;
     BEGIN
        insert into msc_supplier_capacities (
            transaction_id,
            plan_id,
            organization_id,
            sr_instance_id,
            supplier_id,
            supplier_site_id,
            inventory_item_id,
            from_date,
            to_date,
            capacity,
            using_organization_id,
            refresh_number,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            status,
            applied,
            collected_flag,
            last_update_login)
      values (
            l_nextid,
            -1,            --plan_id
            p_organization_id,      --organization_id,
            p_sr_instance_id,
            p_supplier_id,
            p_supplier_site_id,           --p_supplier_site_id,
            p_item_id,
            p_from_date,        --from_date,
            p_to_date,        --to_date
            p_capacity,       --capacity,
            -1,            --using_organization_id,
            p_refresh_number,    --refresh_number,
            sysdate,       --last_update_date,
            l_user_id,        --last_updated_by,
            sysdate,       --creation_date,
            l_user_id,        --created_by,
            null,          --status
            null,          --applied
            3,		--1,          --collected_flag
            -999);            -- to distinguish the data from receive from exchange
      END;
   END IF;

EXCEPTION

  WHEN others THEN
   LOG_MESSAGE('Error in insert capacity ' || sqlerrm);
   LOG_MESSAGE( 'Insert_capacity' ||  sqlerrm);
   null;
END INSERT_CAPACITY;


------------------------------------------------------------------------------------
--UPDATE_CAPACITY
-----------------------------------------------------------------------------------
PROCEDURE Update_Capacity(p_sr_instance_id IN Number,
            p_organization_id IN Number,
            p_supplier_id  IN Number,
            p_supplier_site_id IN Number,
            p_item_id IN Number,
            p_from_date IN Date,
            p_to_date IN Date,
            p_capacity IN Number,
            p_transaction_id IN Number) IS
l_exist  Number := 0;

BEGIN
   begin
      SELECT 1 into l_exist from dual
      WHERE exists (SELECT 1
         from  msc_supplier_capacities
      where    plan_id = -1
      	and   sr_instance_id = p_sr_instance_id
      	and   transaction_id = p_transaction_id
      	and   inventory_item_id = p_item_id
         and      organization_id = p_organization_id
         and      supplier_id = p_supplier_id
         and      nvl(supplier_site_id,-1) = nvl(p_supplier_site_id,-1)
         and      trunc(from_date) = trunc(p_from_date)
         and      trunc(nvl(to_date,from_date)) = trunc(p_to_date)
         and   nvl(last_update_login,-1) <> -999);
   exception
      when no_data_found then
         l_exist := 0;
   end;

   IF (l_exist = 1 ) THEN

   LOG_MESSAGE('update sc and override the collected/manually data');
   	update msc_supplier_capacities
   	set   capacity = p_capacity,
   		from_date = p_from_date,
      		to_date = p_to_date,
      		collected_flag = 3,       -- bug 5208105
      		last_update_login = -999
   	where    plan_id = -1
   	and   sr_instance_id = p_sr_instance_id
   	and   transaction_id = p_transaction_id
   	and   inventory_item_id = p_item_id
        and       organization_id = p_organization_id
        and       supplier_id = p_supplier_id
        and       nvl(supplier_site_id,-1) = nvl(p_supplier_site_id,-1)
        and       trunc(from_date) = trunc(p_from_date)
        and       trunc(nvl(to_date,from_date)) = trunc(p_to_date)
        and nvl(last_update_login,-1) <> -999;
    ELSE

        LOG_MESSAGE('do not override the current data receiving from exchange');
   	update msc_supplier_capacities
   	set   capacity = capacity + p_capacity,
   	   from_date = p_from_date,
   	   to_date = p_to_date,
   	   collected_flag = 3,   -- bug 5208105
   	   last_update_login = -999
   	where    plan_id = -1
   	and   sr_instance_id = p_sr_instance_id
   	and   transaction_id = p_transaction_id
   	and   inventory_item_id = p_item_id
        and       organization_id = p_organization_id
        and       supplier_id = p_supplier_id
        and       nvl(supplier_site_id,-1) = nvl(p_supplier_site_id,-1)
        and       trunc(from_date) = trunc(p_from_date)
        and       trunc(nvl(to_date,from_date)) = trunc(p_to_date)
        and last_update_login = -999;
    END IF;

EXCEPTION

  WHEN others
  THEN
   LOG_MESSAGE('Error in update capacity' || sqlerrm);
   LOG_MESSAGE( sqlerrm);

END UPDATE_CAPACITY;

------------------------------------------------------------------------
-- LOAD_CAPACITY
-------------------------------------------------------------------------
PROCEDURE Load_Supply_Schedule(p_sr_instance_id IN Number,
            p_organization_id IN Number,
            p_supplier_id  IN Number,
            p_supplier_site_id IN Number,
            p_mod_org_id In Number,
            p_mod_org_code IN Varchar2,
            p_mps_designator_id In Number,
            p_item_id IN Number,
            p_date IN Date,
            p_capacity IN Number,
            p_refresh_number IN Number) IS

l_mps_designator_id  Number := -99;
l_mps_designator  msc_designators.designator%type;
l_exist        Number := 0;


BEGIN
LOG_MESSAGE('Load supply Schedule');


   IF (p_mps_designator_id is NULL) THEN
   --bug# 2470463 to change the name from SCE to CP
      SELECT 'CP' ||
         substr(p_mod_org_code,1,instr(p_mod_org_code,':')-1) ||
         '-' || substr(p_mod_org_code,instr(p_mod_org_code,':')+1,7)
      INTO l_mps_designator
      FROM dual;

   begin
      SELECT  designator_id, designator
      INTO  l_mps_designator_id, l_mps_designator
      FROM     msc_designators
         WHERE    sr_instance_id = p_sr_instance_id
         AND   organization_id = p_mod_org_id
            AND   designator_type = 2
            AND   designator = l_mps_designator;

      fnd_message.set_name('MSC','MSC_PUB_MPS_DESIGNATOR');
            LOG_MESSAGE( fnd_message.get || ' ' || l_mps_designator);
            LOG_MESSAGE('Existing MPS designator ' || l_mps_designator);
         exception
            when no_data_found then
               l_mps_designator_id := null;
         end;

   IF (l_mps_designator_id is null ) THEN
      Insert_MPS_Designator(p_sr_instance_id,
            p_organization_id,
            p_supplier_id,
            p_supplier_site_id,
            l_mps_designator,
            p_refresh_number,
            l_mps_designator_id
            );

   END IF;
    ELSE
      begin
         select designator
         into  l_mps_designator
         from  msc_designators
         where designator_id = p_mps_designator_id;
      exception
         when no_data_found then
            l_mps_designator_id := null;
      end;
      l_mps_designator_id := p_mps_designator_id;
      fnd_message.set_name('MSC','MSC_PUB_MPS_DESIGNATOR');
      LOG_MESSAGE( fnd_message.get || ' ' || l_mps_designator);
      LOG_MESSAGE('Existing MPS designator ' || l_mps_designator);
    END IF;
    Insert_Supply_Schedule(p_sr_instance_id,
      p_organization_id,
      p_supplier_id,
      p_supplier_site_id,
      l_mps_designator_id,
      p_item_id,
      p_date,
      p_capacity,
      p_refresh_number);




EXCEPTION

  WHEN others THEN
   LOG_MESSAGE('Error in Load Supply schedule ' || sqlerrm);
   LOG_MESSAGE( sqlerrm);
END LOAD_SUPPLY_SCHEDULE;


------------------------------------------------------------------------------------
--INSERT_MPS_DESIGNATOR
-----------------------------------------------------------------------------------
PROCEDURE Insert_MPS_Designator(p_sr_instance_id IN Number,
            p_organization_id IN Number,
            p_supplier_id In Number,
            p_supplier_site_id In Number,
            p_mps_designator IN Varchar2,
            p_refresh_number IN Number,
            p_mps_designator_id OUT NOCOPY Number) IS

l_nextid    Number;
l_user_id      Number := fnd_global.user_id;
l_refresh_number  Number;
l_supplier_name      msc_trading_partners.partner_name%type;
l_supplier_site_name msc_trading_partner_sites.tp_site_code%type;
l_desc         msc_designators.description%type;
BEGIN


LOG_MESSAGE('insert mps designator');
      select msc_designators_s.nextval
      into p_mps_designator_id
      from dual;
LOG_MESSAGE('MPS Designator ' || p_mps_designator);

begin
select partner_name
into  l_supplier_name
from  msc_trading_partners
where partner_id = p_supplier_id
and   partner_type = 1;

select tp_site_code
into  l_supplier_site_name
from  msc_trading_partner_sites
where partner_id = p_supplier_id
and   partner_site_id = p_supplier_site_id;

exception
   when no_data_found then
      null;
      when others then
         null;
         LOG_MESSAGE('Error in mps ' || sqlerrm);
end;

l_desc := l_supplier_name ||',' || l_supplier_site_name;

fnd_message.set_name('MSC','MSC_PUB_MPS_DESIGNATOR');
LOG_MESSAGE( fnd_message.get || ' '  || p_mps_designator || ' for supplier ' || l_desc);


   insert into msc_designators (
         designator_id,
         designator,
         organization_id,
         sr_instance_id,
         designator_type,
         mps_relief,
         inventory_atp_flag,
         description,
         organization_selection,
         production,
         disable_date,
         refresh_number,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         collected_flag)
   values (
         p_mps_designator_id,
         p_mps_designator,
         p_organization_id,
         p_sr_instance_id,
         2,
         2,
         2,
         substr(l_desc,1,50),
         1,
         2,
         null,
         p_refresh_number,
         sysdate,
         l_user_id,
         sysdate,
         l_user_id,
         null);

commit;
EXCEPTION

  WHEN others THEN
   LOG_MESSAGE('Error  in insert mps designator ' || sqlerrm);
   LOG_MESSAGE( sqlerrm);
END INSERT_MPS_DESIGNATOR;

------------------------------------------------------------------------------------
--INSERT_SUPPLY_SCHEDULE
-----------------------------------------------------------------------------------
PROCEDURE Insert_Supply_schedule(p_sr_instance_id IN Number,
            p_organization_id IN Number,
            p_supplier_id  IN Number,
            p_supplier_site_id IN Number,
            p_mps_designator_id IN Number,
            p_item_id IN Number,
            p_date IN Date,
            p_capacity IN Number,
            p_refresh_number IN Number) IS

l_nextid    Number;
l_user_id      Number := fnd_global.user_id;
l_refresh_number  Number;
BEGIN

LOG_MESSAGE('Clean up the supplies first');
   begin
   DELETE  msc_supplies
   WHERE plan_id = -1
   AND   sr_instance_id = p_sr_instance_id
   AND   organization_id = p_organization_id
   AND   schedule_designator_id = p_mps_designator_id
   AND   inventory_item_id = p_item_id
   AND   order_type = 5
   AND   nvl(last_update_login,-1) <> -999;
   exception
      when others then
         null;
   end;


LOG_MESSAGE('insert msc supplies');
      select msc_supplies_s.nextval
      into l_nextid
      from dual;

   insert into msc_supplies (plan_id,
            transaction_id,
            organization_id,
            sr_instance_id,
            inventory_item_id,
            schedule_designator_id,
            new_schedule_date,
            order_type,
            --supplier_id,
            --supplier_site_id,
            new_order_quantity,
            firm_planned_type,
            refresh_number,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login)
         values (-1,
            l_nextid,
            p_organization_id,      --organization_id,
            p_sr_instance_id,
            p_item_id,
            p_mps_designator_id,
            p_date,
            5,          --planned order
            --p_supplier_id,
            --p_supplier_site_id,            --p_supplier_site_id,
            p_capacity,       --capacity,
            2,          --firm planned type
            p_refresh_number,    --refresh_number,
            sysdate,       --last_update_date,
            l_user_id,        --last_updated_by,
            sysdate,       --creation_date,
            l_user_id,
            -999);

EXCEPTION

  WHEN others THEN
   LOG_MESSAGE('Error in insert supply schedule ' || sqlerrm);
   LOG_MESSAGE( sqlerrm);
END INSERT_SUPPLY_SCHEDULE;



END MSC_X_RECEIVE_CAPACITY_PKG ;

/
