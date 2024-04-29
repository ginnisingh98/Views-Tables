--------------------------------------------------------
--  DDL for Package Body MSC_ATP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ATP_UTILS" AS
/* $Header: MSCUATPB.pls 120.9 2007/12/12 10:42:48 sbnaik ship $  */

G_PKG_NAME              CONSTANT VARCHAR2(30) := 'MSC_ATP_UTILS';

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

PROCEDURE put_into_temp_table
  (
   x_dblink		IN   VARCHAR2,
   x_session_id         IN   NUMBER,
   x_atp_rec            IN   MRP_ATP_PUB.atp_rec_typ,
   x_atp_supply_demand  IN   MRP_ATP_PUB.ATP_Supply_Demand_Typ,
   x_atp_period         IN   MRP_ATP_PUB.ATP_Period_Typ,
   x_atp_details        IN   MRP_ATP_PUB.ATP_Details_Typ,
   x_mode               IN   NUMBER,
   x_return_status      OUT   NoCopy VARCHAR2,
   x_msg_data           OUT   NoCopy VARCHAR2,
   x_msg_count          OUT   NoCopy NUMBER
   ) IS
      --PRAGMA AUTONOMOUS_TRANSACTION;

      l_dynstring VARCHAR2(128) := NULL;
      sql_stmt    VARCHAR2(10000);

      -- bug 2974324. Redundant Variables removed from here.


BEGIN
   -- initialize API returm status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF x_dblink IS NOT NULL THEN
     l_dynstring := '@'||x_dblink;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('put_into_temp_table: ' || 'session_id : '||x_session_id);
      msc_sch_wb.atp_debug('enter put_into_temp_table');
      msc_sch_wb.atp_debug('put_into_temp_table: ' || 'l_dynstring = '||l_dynstring);
      -- bug 2974324. Repeated statements removed from here.
   END IF;

   /* -- bug3378648:we dont need this sql as this should be done locally

   IF x_mode = RESULTS_MODE AND x_dblink IS NOT NULL THEN
      -- Deletes any records in the
      -- cchen : add  database link to the subquery
      sql_stmt :=
        'DELETE FROM MRP_ATP_DETAILS_TEMP'||l_dynstring||
        ' WHERE session_id = :x_session_id '||
        ' and order_line_id in ( '||
        ' select order_line_id from mrp_atp_schedule_temp'||l_dynstring||
        ' where session_id = :x_session_id_1 '||
        ' and status_flag = 1) '||
        ' and record_type <> 3';


      EXECUTE IMMEDIATE sql_stmt USING  x_session_id, x_session_id;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('put_into_temp_table: ' || 'delete details temp  rows := '|| SQL%ROWCOUNT);
      END IF;
   END IF;
   /* -- bug3378648:we dont need this sql as this should be done locally

-- moved deleting old records from mrp_atp_details_temp to call_schedule_remote

/*
   MSC_ATP_UTILS.PUT_SD_DATA(x_atp_supply_demand, x_dblink, x_session_id);
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('put_into_temp_table: ' || ' Inserted supply demand  records ');
   END IF;

--   MSC_ATP_UTILS.PUT_PERIOD_DATA(x_atp_period, x_dblink, x_session_id);
-- dsting call it with null because we'll transfer it later
-- I'm not really expecting anything here
IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('put_into_temp_table: ' || '   dsting expect 0 period recs: ' || x_atp_period.level.count);
END IF;
   MSC_ATP_UTILS.PUT_PERIOD_DATA(x_atp_period, NULL, x_session_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('put_into_temp_table: ' || ' Inserted period records ');
      msc_sch_wb.atp_debug('enter put_into_temp_table :30');
   END IF;

-- dsting transfer it later
--   MSC_ATP_UTILS.PUT_Pegging_Data(x_session_id, x_dblink);

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('put_into_temp_table: ' || 'Inserted Pegging Records');
   END IF;
*/

   MSC_ATP_UTILS.Put_Scheduling_data(x_atp_rec, x_mode, x_dblink, x_session_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('put_into_temp_table: ' || ' Inserted main records ');
   END IF;

      --commit;  -- autonomous transaction

EXCEPTION

 -- Bug 2458308 : krajan
 -- error Handling

    WHEN MSC_ATP_PUB.ATP_INVALID_OBJECTS_FOUND THEN
        -- bug 2974324. Redundant cursor statements removed from here.
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('ATP Invalid Objects Found in put_Into_temp_table ');
           msc_sch_wb.atp_debug('put_into_temp_table: ' || ' Error in MSCUATPB.pls '||substr(sqlerrm,1,100));
        END IF;
        x_msg_data := substr(sqlerrm,1,100);
        x_return_status := FND_API.G_RET_STS_ERROR;
        --   IF l_dynstring is null THEN
        --     ROLLBACK;
        --    END IF;
        RAISE MSC_ATP_PUB.ATP_INVALID_OBJECTS_FOUND;

   WHEN OTHERS THEN
      -- bug 2974324. Redundant cursor statements removed from here.
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('put_into_temp_table: ' || ' Error in MSCUATPB.pls '||substr(sqlerrm,1,100));
      END IF;
      x_msg_data := substr(sqlerrm,1,100);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Bug 2458308 : krajan
      -- Commented out rollbacks
      -- IF l_dynstring is null THEN
        -- ROLLBACK;
      -- END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END put_into_temp_table;


PROCEDURE get_from_temp_table
  (
   x_dblink		IN    VARCHAR2,
   x_session_id         IN    NUMBER,
   x_atp_rec            OUT   NoCopy MRP_ATP_PUB.atp_rec_typ,
   x_atp_supply_demand  OUT   NoCopy MRP_ATP_PUB.ATP_Supply_Demand_Typ,
   x_atp_period         OUT   NoCopy MRP_ATP_PUB.ATP_Period_Typ,
   x_atp_details        OUT   NoCopy MRP_ATP_PUB.ATP_Details_Typ,
   x_mode               IN    NUMBER,
   x_return_status      OUT   NoCopy VARCHAR2,
   x_msg_data           OUT   NoCopy VARCHAR2,
   x_msg_count          OUT   NoCopy NUMBER,
   p_details_flag       IN    NUMBER
   ) IS

   sched_cv             mrp_atp_utils.SchedCurTyp;
   sched_rec            mrp_atp_utils.Schedule_Temp;
   details_rec          mrp_atp_utils.Details_Temp;
   i                    PLS_INTEGER := 1;
   j                    PLS_INTEGER := 1;
   l_dynstring          VARCHAR2(128) := NULL;
   sql_stmt             VARCHAR2(10000);
   temp                 number ;
   l_status_flag        pls_integer;
   l_mso_lead_time_factor number;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('get_from_temp_table: ' || 'Entering get from temp table');
      msc_sch_wb.atp_debug('get_from_temp_table: ' || 'p_details_falg := ' || p_details_flag);
   END IF;
   -- initialize API returm status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF x_dblink IS NOT NULL THEN
     l_dynstring := '@'||x_dblink;
   END IF;


   ---s_cto_rearch
   IF x_dblink is not null and x_mode = REQUEST_MODE THEN

        --bug 3378648
       --delete the old data if any; This data will exist in case of Global order promising
       Delete mrp_atp_schedule_temp
       where session_id = x_session_id
       and   status_flag in (1, 2, 99);
       --and   status_flag in (1, 99);

       --delete local detail data
       delete mrp_atp_details_temp
       where session_id = x_session_id;

       --transfer the date from source to dest mrp_atp_schedule_temp
       MSC_ATP_UTILS.Transfer_scheduling_data(x_session_id, x_dblink, REQUEST_MODE);
   END IF;
   ---e_cto_rearch

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('get_from_temp_table: ' || 'get from temp table,  l_dynstring = '||l_dynstring);
      msc_sch_wb.atp_debug('get_from_temp_table: ' || 'get from temp table,  x_session_id = '||x_session_id);
      msc_sch_wb.atp_debug('get_from_temp_table: ' || 'get from temp table,  x_mode = ' || x_mode);
   END IF;

   -- cchen: rewrite this sql_stmt.  based on the mode we either have status 1
   -- or 2 in the where clause

   -- bug 1878093, pass atp_flag from mtl_system_items to destination
   -- for use in case item has not been collected as yet.

   --pegging enhancement: If on same database then use bulk collect
   --- can't use bulk collect in case of distributed set up becauase its not supported.
--s_cto_rearch
--   IF l_dynstring is null THEN
--e_cto_rearch
       l_mso_lead_time_factor := MSC_ATP_PVT.G_MSO_LEAD_TIME_FACTOR;
       IF x_mode = results_mode THEN
           l_status_flag := 2;  -- changed form 1 to 2
       ELSE
           l_status_flag := 99;
       END IF;

       IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('l_status_flag := ' || l_status_flag);
       END IF;

       SELECT
              ACTION
             ,CALLING_MODULE
             ,ORDER_HEADER_ID
             ,ORDER_LINE_ID
             ,INVENTORY_ITEM_ID
             ,ORGANIZATION_ID
             ,SR_INSTANCE_ID
             ,ORDER_NUMBER
             ,SOURCE_ORGANIZATION_ID
             ,CUSTOMER_ID
             ,CUSTOMER_SITE_ID
             ,DESTINATION_TIME_ZONE
             ,QUANTITY_ORDERED
             ,UOM_CODE
             ,REQUESTED_SHIP_DATE
             ,REQUESTED_ARRIVAL_DATE
             ,LATEST_ACCEPTABLE_DATE
             ,DELIVERY_LEAD_TIME
             ,FREIGHT_CARRIER
             ,SHIP_METHOD
             ,DEMAND_CLASS
             ,SHIP_SET_NAME
             ,ARRIVAL_SET_NAME
             ,OVERRIDE_FLAG
             ,SCHEDULED_SHIP_DATE
             -- rajjain 02/21/2003 Bug 2815484
             ,SCHEDULED_ARRIVAL_DATE
             ,AVAILABLE_QUANTITY
             ,REQUESTED_DATE_QUANTITY
             ,GROUP_SHIP_DATE
             ,GROUP_ARRIVAL_DATE
             ,VENDOR_ID
             ,VENDOR_SITE_ID
             ,INSERT_FLAG
             ,ERROR_CODE
             ,INVENTORY_ITEM_NAME
             ,SOURCE_ORGANIZATION_CODE
             ,SCENARIO_ID
             ,VENDOR_NAME
             ,VENDOR_SITE_NAME
             ,MDI_ROWID
             ,DEMAND_SOURCE_TYPE
             ,DEMAND_SOURCE_DELIVERY
             /* --bug 4078703: always pass atp_lead_time back to OM
             ,DECODE(MSC_ATP_PVT.G_INV_CTP, 5,
                          Decode(order_line_id, ato_model_line_id,
                          decode(bom_item_type, 1,
                                (fixed_lt + (variable_lt * QUANTITY_ORDERED)) * (1 + l_mso_lead_time_factor), 0), 0), 0)
              */
             ,atp_lead_time
             ,OE_FLAG
             ,END_PEGGING_ID
             ,OLD_SOURCE_ORGANIZATION_ID
             ,OLD_DEMAND_CLASS
             --,ATTRIBUTE_06
             ,SUBSTITUTION_TYP_CODE
             ,REQ_ITEM_DETAIL_FLAG
             ,OLD_INVENTORY_ITEM_ID
             ,REQUEST_ITEM_ID
             ,REQUEST_ITEM_NAME
             ,REQ_ITEM_AVAILABLE_DATE
             ,REQ_ITEM_AVAILABLE_DATE_QTY
             ,REQ_ITEM_REQ_DATE_QTY
             ,SALES_REP
             ,CUSTOMER_CONTACT
             ,SUBST_FLAG
             ,diagnostic_atp_flag
             ---columns for CTO project
             ,Top_Model_line_id,
             ATO_Parent_Model_Line_Id,
             ATO_Model_Line_Id,
             Parent_line_id,
             match_item_id,
             Config_item_line_id,
             Validation_Org,
             Component_Sequence_ID,
             Component_Code,
             line_number,
             included_item_flag,
             atp_flag,
             atp_components_flag,
             bom_item_type,
             pick_components_flag,
             OSS_ERROR_CODE,
             sequence_number,
             original_request_date,
             --bug 3508529: add extra coumns

            --bug 3508529: add columns that are present in atp rec type
            null, --earliest_acceptable_date,
            error_message, --message,
            null, --ato_delete_flag,
            null, --attribute_01,
            null, --attribute_03,
            null, --attribute_04,
            null, --attribute_05,
            compile_designator, --attribute_07,
            null, --attribute_08,
            null, --attribute_09,
            null, --attribute_10,
            customer_name, --customer_name,
            null, --customer_class,
            customer_location, --customer_location,
            customer_country, --null, --customer_country, 2814895
            customer_state, --null, --customer_state, 2814895
            customer_city, --null, --customer_city, 2814895
            customer_postal_code, --null, --customer_postal_code, 2814895
            atp_flag, --atp_flag,
            wip_supply_type, --wip_supply_type,
            mandatory_item_flag, --mandatory_item_flag,
            null, --base_model_id,
            matched_item_name, --matched_item_name,
            cascade_model_info_to_comp, --cascade_model_info_to_comp,
            firm_flag, --firm_flag,
            order_line_number, --order_line_number,
            option_number, --option_number,
            shipment_number, --shipment_number,
            item_desc, --item_desc,
            old_line_schedule_date, --old_line_schedule_date,
            old_source_organization_code, --old_source_organization_code,
            firm_source_org_id, --firm_source_org_id,
            firm_source_org_code, --firm_source_org_code,
            firm_ship_date, --firm_ship_date,
            firm_arrival_date, --firm_arrival_date,
            ship_method_text, --ship_method_text,
            ship_set_id, --ship_set_id,
            arrival_set_id, --arrival_set_id,
            project_id, --project_id,
            task_id, --task_id,
            null, --project_number,
            null, --task_number
            null, --attribute_11,
            null, --attribute_12,
            null, --attribute_13,
            null, --attribute_14,
            null, --attribute_15,
            null, --attribute_16,
            null, --attribute_17,
            null, --attribute_18,
            null, --attribute_19,
            null, --attribute_20,
            null, --attribute_21,
            null, --attribute_22,
            null, --attribute_23,
            null, --attribute_24,
            null, --attribute_25,
            null, --attribute_26,
            null, --attribute_27,
            null, --attribute_28,
            null, --attribute_29,
            null, --attribute_30,
            null, --atf_date,
            plan_id, --plan_id,
            null, --receiving_cal_code,
            null, --intransit_cal_code,
            null, --shipping_cal_code,
            null, --manufacturing_cal_code
            --end bug 3508529: add all columns available in atp_rec_type
            internal_org_id, -- Bug 3449812
            first_valid_ship_arrival_date, --bug 3328421
            party_site_id, --2814895
            part_of_set  --4500382

            BULK COLLECT INTO

            x_atp_rec.action,
            x_atp_rec.calling_module,
            x_atp_rec.Demand_Source_Header_Id,
            x_atp_rec.identifier,
            x_atp_rec.inventory_item_id,
            x_atp_rec.organization_id,
            x_atp_rec.instance_id,
	    x_atp_rec.order_number,
            x_atp_rec.source_organization_id,
            x_atp_rec.customer_id,
            x_atp_rec.customer_site_id,
            x_atp_rec.destination_time_zone,
            x_atp_rec.quantity_ordered,
            x_atp_rec.quantity_uom,
            x_atp_rec.requested_ship_date,
            x_atp_rec.requested_arrival_date,
            x_atp_rec.latest_acceptable_date,
            x_atp_rec.delivery_lead_time,
            x_atp_rec.freight_carrier,
            x_atp_rec.ship_method,
            x_atp_rec.demand_class,
            x_atp_rec.ship_set_name,
            x_atp_rec.arrival_set_name,
            x_atp_rec.override_flag,
            x_atp_rec.Ship_Date,
            -- rajjain 02/21/2003 Bug 2815484
            x_atp_rec.Arrival_Date,
            x_atp_rec.available_quantity,
            x_atp_rec.requested_date_quantity,
            x_atp_rec.group_ship_date,
            x_atp_rec.group_arrival_date,
            x_atp_rec.vendor_id,
            x_atp_rec.vendor_site_id,
            x_atp_rec.insert_flag,
            x_atp_rec.error_code,
            x_atp_rec.Inventory_Item_Name,
            x_atp_rec.Source_Organization_Code,
            x_atp_rec.Scenario_Id,
            x_atp_rec.vendor_name,
            x_atp_rec.vendor_site_name,
            x_atp_rec.row_id,
            x_atp_rec.Demand_Source_Type,
            x_atp_rec.demand_source_delivery,
            x_atp_rec.atp_lead_time,
            x_atp_rec.oe_flag,
            x_atp_rec.end_pegging_id,
            x_atp_rec.old_source_organization_id,
            x_atp_rec.old_demand_class,
            --x_atp_rec.attribute_06,
            x_atp_rec.substitution_typ_code,
            x_atp_rec.req_item_detail_flag,
            x_atp_rec.old_inventory_item_id,
            x_atp_rec.request_item_id,
            x_atp_rec.request_item_name,
            x_atp_rec.req_item_available_date,
            x_atp_rec.req_item_available_date_qty,
            x_atp_rec.req_item_req_date_qty,
            x_atp_rec.sales_rep,
            x_atp_rec.customer_contact,
            x_atp_rec.subst_flag,
            x_atp_rec.attribute_02,
            ---columns for CTO project
            x_atp_rec.Top_Model_line_id,
            x_atp_rec.ATO_Parent_Model_Line_Id,
            x_atp_rec.ATO_Model_Line_Id,
            x_atp_rec.Parent_line_id,
            x_atp_rec.match_item_id,
            x_atp_rec.Config_item_line_id,
            x_atp_rec.Validation_Org,
            x_atp_rec.Component_Sequence_ID,
            x_atp_rec.Component_Code,
            x_atp_rec.line_number,
            x_atp_rec.included_item_flag,
            x_atp_rec.attribute_06,
            x_atp_rec.atp_components_flag,
            x_atp_rec.bom_item_type,
            x_atp_rec.pick_components_flag,
            x_atp_rec.OSS_ERROR_CODE,
            x_atp_rec.sequence_number,
            x_atp_rec.original_request_date,
            --bug 3508529: add columns that are present in atp rec type
            x_atp_rec.earliest_acceptable_date,
            x_atp_rec.message,
            x_atp_rec.ato_delete_flag,
            x_atp_rec.attribute_01,
            x_atp_rec.attribute_03,
            x_atp_rec.attribute_04,
            x_atp_rec.attribute_05,
            x_atp_rec.attribute_07,
            x_atp_rec.attribute_08,
            x_atp_rec.attribute_09,
            x_atp_rec.attribute_10,
            x_atp_rec.customer_name,
            x_atp_rec.customer_class,
            x_atp_rec.customer_location,
            x_atp_rec.customer_country,
            x_atp_rec.customer_state,
            x_atp_rec.customer_city,
            x_atp_rec.customer_postal_code,
            x_atp_rec.atp_flag,
            x_atp_rec.wip_supply_type,
            x_atp_rec.mandatory_item_flag,
            x_atp_rec.base_model_id,
            x_atp_rec.matched_item_name,
            x_atp_rec.cascade_model_info_to_comp,
            x_atp_rec.firm_flag,
            x_atp_rec.order_line_number,
            x_atp_rec.option_number,
            x_atp_rec.shipment_number,
            x_atp_rec.item_desc,
            x_atp_rec.old_line_schedule_date,
            x_atp_rec.old_source_organization_code,
            x_atp_rec.firm_source_org_id,
            x_atp_rec.firm_source_org_code,
            x_atp_rec.firm_ship_date,
            x_atp_rec.firm_arrival_date,
            x_atp_rec.ship_method_text,
            x_atp_rec.ship_set_id,
            x_atp_rec.arrival_set_id,
            x_atp_rec.project_id,
            x_atp_rec.task_id,
            x_atp_rec.project_number,
            x_atp_rec.task_number,
            x_atp_rec.attribute_11,
            x_atp_rec.attribute_12,
            x_atp_rec.attribute_13,
            x_atp_rec.attribute_14,
            x_atp_rec.attribute_15,
            x_atp_rec.attribute_16,
            x_atp_rec.attribute_17,
            x_atp_rec.attribute_18,
            x_atp_rec.attribute_19,
            x_atp_rec.attribute_20,
            x_atp_rec.attribute_21,
            x_atp_rec.attribute_22,
            x_atp_rec.attribute_23,
            x_atp_rec.attribute_24,
            x_atp_rec.attribute_25,
            x_atp_rec.attribute_26,
            x_atp_rec.attribute_27,
            x_atp_rec.attribute_28,
            x_atp_rec.attribute_29,
            x_atp_rec.attribute_30,
            x_atp_rec.atf_date,
            x_atp_rec.plan_id,
            x_atp_rec.receiving_cal_code,
            x_atp_rec.intransit_cal_code,
            x_atp_rec.shipping_cal_code,
            x_atp_rec.manufacturing_cal_code,
            x_atp_rec.internal_org_id, -- Bug 3449812
            x_atp_rec.first_valid_ship_arrival_date, --bug 3328421
            x_atp_rec.party_site_id, --2814895
            x_atp_rec.part_of_set  --4500382

	    FROM mrp_atp_schedule_temp
	    WHERE session_id = x_session_id
            AND   status_flag = l_status_flag
            AND   NVL(mandatory_item_flag, 2) = 2
            AND   ORDER_LINE_ID = DECODE( x_mode, MSC_ATP_UTILS.RESULTS_MODE, ORDER_LINE_ID,
                                                  NVL(ATO_Model_Line_Id, ORDER_LINE_ID))
            ORDER BY sequence_number;

            IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Records Retrieved := ' || x_atp_rec.inventory_item_id.count );
            END IF;

            --bug3520746 Begin Changes
            --bug3610706 added the condition for de-centrlized env.
            --insert into local regions table from Source
            IF x_mode = REQUEST_MODE AND x_dblink IS NOT NULL THEN
             sql_stmt :=
               'INSERT INTO MSC_REGIONS_TEMP(
                session_id,
                partner_site_id,
                region_id,
                region_type,
                zone_flag,
                partner_type
                )
                (SELECT
                 session_id,
                 partner_site_id,
                 region_id,
                 region_type,
                 zone_flag,
                 partner_type
                 FROM msc_regions_temp' || l_dynstring || '
                 WHERE session_id = :x_session_id)';
              EXECUTE IMMEDIATE sql_stmt USING x_session_id;

              IF PG_DEBUG in ('Y', 'C') THEN
                 msc_sch_wb.atp_debug('Rows inserted in msc_regions_temp:'|| sql%rowcount);
              END IF;
            END IF;
            --bug3520746 End Changes
---s_cto_rearch
/*    ELSE
      sql_stmt :=
	  'SELECT
           ACTION
          ,CALLING_MODULE
          ,SESSION_ID
          ,ORDER_HEADER_ID
          ,ORDER_LINE_ID
          ,INVENTORY_ITEM_ID
          ,ORGANIZATION_ID
          ,SR_INSTANCE_ID
          ,ORGANIZATION_CODE
          ,ORDER_NUMBER
          ,SOURCE_ORGANIZATION_ID
          ,CUSTOMER_ID
          ,CUSTOMER_SITE_ID
          ,DESTINATION_TIME_ZONE
          ,QUANTITY_ORDERED
          ,UOM_CODE
          ,REQUESTED_SHIP_DATE
          ,REQUESTED_ARRIVAL_DATE
          ,LATEST_ACCEPTABLE_DATE
          ,DELIVERY_LEAD_TIME
          ,FREIGHT_CARRIER
          ,SHIP_METHOD
          ,DEMAND_CLASS
          ,SHIP_SET_NAME
          ,SHIP_SET_ID
          ,ARRIVAL_SET_NAME
          ,ARRIVAL_SET_ID
          ,OVERRIDE_FLAG
          ,SCHEDULED_SHIP_DATE
          ,SCHEDULED_ARRIVAL_DATE
          ,AVAILABLE_QUANTITY
          ,REQUESTED_DATE_QUANTITY
          ,GROUP_SHIP_DATE
          ,GROUP_ARRIVAL_DATE
          ,VENDOR_ID
          ,VENDOR_SITE_ID
          ,INSERT_FLAG
          ,ERROR_CODE
          ,ERROR_MESSAGE
          ,SEQUENCE_NUMBER
          ,FIRM_FLAG
          ,INVENTORY_ITEM_NAME
          ,SOURCE_ORGANIZATION_CODE
          ,INSTANCE_ID1
          ,ORDER_LINE_NUMBER
          ,SHIPMENT_NUMBER
          ,OPTION_NUMBER
          ,PROMISE_DATE
          ,CUSTOMER_NAME
          ,CUSTOMER_LOCATION
          ,OLD_LINE_SCHEDULE_DATE
          ,OLD_SOURCE_ORGANIZATION_CODE
          ,SCENARIO_ID
          ,VENDOR_NAME
          ,VENDOR_SITE_NAME
          ,STATUS_FLAG
          ,MDI_ROWID
          ,DEMAND_SOURCE_TYPE
          ,DEMAND_SOURCE_DELIVERY
          ,ATP_LEAD_TIME
          ,OE_FLAG
          ,ITEM_DESC
          ,INTRANSIT_LEAD_TIME
          ,SHIP_METHOD_TEXT
          ,END_PEGGING_ID
          ,PROJECT_ID
          ,TASK_ID
          ,PROJECT_NUMBER
          ,TASK_NUMBER
          ,OLD_SOURCE_ORGANIZATION_ID
          ,OLD_DEMAND_CLASS
          ,EXCEPTION1
          ,EXCEPTION2
          ,EXCEPTION3
          ,EXCEPTION4
          ,EXCEPTION5
          ,EXCEPTION6
          ,EXCEPTION7
          ,EXCEPTION8
          ,EXCEPTION9
          ,EXCEPTION10
          ,EXCEPTION11
          ,EXCEPTION12
          ,EXCEPTION13
          ,EXCEPTION14
          ,EXCEPTION15
          ,ATTRIBUTE_06
          ,SUBSTITUTION_TYP_CODE
          ,REQ_ITEM_DETAIL_FLAG
          ,OLD_INVENTORY_ITEM_ID
          ,REQUEST_ITEM_ID
          ,REQUEST_ITEM_NAME
          ,REQ_ITEM_AVAILABLE_DATE
          ,REQ_ITEM_AVAILABLE_DATE_QTY
          ,REQ_ITEM_REQ_DATE_QTY
          ,SALES_REP
          ,CUSTOMER_CONTACT
          ,SUBST_FLAG ' ;

         --diag_atp
         IF MSC_ATP_PVT.G_APPS_VER >= 3 THEN
             sql_stmt := sql_stmt || ', diagnostic_atp_flag ';
	 ELSE
	     sql_stmt := sql_stmt || ', 2'; -- non-diagnostic for older sources
         END IF;

         sql_stmt := sql_stmt ||
	   'FROM mrp_atp_schedule_temp'||l_dynstring||'
	   WHERE session_id = :x_session_id';

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('get_from_temp_table: ' || 'sql_stmt ' || sql_stmt);
        END IF;

        IF x_mode = results_mode THEN
           sql_stmt := sql_stmt || ' AND status_flag = 2';  -- changed form 1 to 2
        ELSE
           sql_stmt := sql_stmt || ' AND status_flag = 99';
        END IF;

        -- Bug 2341719 Use the sequence number as ordering tool.
        sql_stmt := sql_stmt || ' ORDER BY sequence_number ';
        -- End Bug 2341719 .

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('get_from_temp_table: ' || 'sql_stmt ' || sql_stmt);
        END IF;

        OPEN sched_cv FOR sql_stmt USING x_session_id;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('get_from_temp_table: ' || 'after open sched_cv ' );
        END IF;

        LOOP
	   IF PG_DEBUG in ('Y', 'C') THEN
	      msc_sch_wb.atp_debug('get_from_temp_table: ' || 'get from temp table,  in LOOP,line 1');
	   END IF;

	   FETCH sched_cv INTO sched_rec;
	   temp := SQLCODE;
	   IF PG_DEBUG in ('Y', 'C') THEN
	      msc_sch_wb.atp_debug('get_from_temp_table: ' || 'after fetch: SQLCODE = '||temp);
	   END IF;

	   EXIT WHEN sched_cv%NOTFOUND;
	   -- process record

	   IF PG_DEBUG in ('Y', 'C') THEN
	      msc_sch_wb.atp_debug('get_from_temp_table: ' || 'get from temp table,  in LOOP,after exit');
	   END IF;

	   MSC_SATP_FUNC.Extend_Atp(x_atp_rec, x_return_status, 1);

           x_atp_rec.row_id(i) := sched_rec.mdi_rowid;
           x_atp_rec.inventory_item_id(i) :=sched_rec.inventory_item_id;
           x_atp_rec.Inventory_Item_Name(i) := sched_rec.Inventory_Item_Name;
           x_atp_rec.instance_id(i) := sched_rec.sr_instance_id;
           x_atp_rec.source_organization_id(i):=sched_rec.source_organization_id;
           x_atp_rec.Source_Organization_Code(i) := sched_rec.Source_Organization_Code;
           x_atp_rec.identifier(i) := sched_rec.order_line_id;       -- different
	   x_atp_rec.order_number(i) := sched_rec.order_number;
           x_atp_rec.Demand_Source_Header_Id(i) := sched_rec.order_header_id;
           x_atp_rec.Demand_Source_Type(i) := sched_rec.Demand_Source_Type;
           x_atp_rec.demand_source_delivery(i) :=sched_rec.demand_source_delivery;
           x_atp_rec.atp_lead_time(i) := sched_rec.atp_lead_time;
           x_atp_rec.Scenario_Id(i) := sched_rec.Scenario_Id;
           x_atp_rec.calling_module(i) := sched_rec.calling_module;
           x_atp_rec.customer_id(i) := sched_rec.customer_id;
           x_atp_rec.customer_site_id(i) := sched_rec.customer_site_id;
           x_atp_rec.destination_time_zone(i) :=sched_rec.destination_time_zone;
           x_atp_rec.quantity_ordered(i) := sched_rec.quantity_ordered;
           x_atp_rec.quantity_uom(i) := sched_rec.uom_code;
           x_atp_rec.requested_ship_date(i) := sched_rec.requested_ship_date;
           x_atp_rec.requested_arrival_date(i) :=sched_rec.requested_arrival_date;
           x_atp_rec.latest_acceptable_date(i) :=sched_rec.latest_acceptable_date;
           x_atp_rec.delivery_lead_time(i) := sched_rec.delivery_lead_time;
           x_atp_rec.freight_carrier(i) :=sched_rec.freight_carrier;
           x_atp_rec.ship_method(i) :=sched_rec.ship_method;
           x_atp_rec.demand_class(i) :=sched_rec.demand_class;
           x_atp_rec.ship_set_name(i) := sched_rec.ship_set_name;
           x_atp_rec.arrival_set_name(i) :=sched_rec.arrival_set_name ;
           x_atp_rec.override_flag(i) :=sched_rec.override_flag;
           x_atp_rec.action(i) :=sched_rec.action;
           x_atp_rec.vendor_id(i) := sched_rec.vendor_id;
           x_atp_rec.vendor_site_id(i) :=sched_rec.vendor_site_id;
           x_atp_rec.insert_flag(i) := sched_rec.insert_flag;
           x_atp_rec.Ship_Date(i) := sched_rec.scheduled_ship_date;
           -- rajjain 02/21/2003 Bug 2815484
           x_atp_rec.Arrival_Date(i) := sched_rec.scheduled_arrival_date;
           x_atp_rec.available_quantity(i):= sched_rec.available_quantity;
           x_atp_rec.requested_date_quantity(i) := sched_rec.requested_date_quantity;
           x_atp_rec.group_ship_date(i) := sched_rec.group_ship_date;
           x_atp_rec.group_arrival_date(i) := sched_rec.group_arrival_date;
           x_atp_rec.vendor_name(i) := sched_rec.vendor_name;
           x_atp_rec.vendor_site_name(i) := sched_rec.vendor_site_name;
           x_atp_rec.error_code(i) := sched_rec.error_code;
           x_atp_rec.oe_flag(i) := sched_rec.oe_flag;
           x_atp_rec.end_pegging_id(i) := sched_rec.end_pegging_id;
           x_atp_rec.old_source_organization_id(i)
             := sched_rec.old_source_organization_id;
           x_atp_rec.old_demand_class(i) := sched_rec.old_demand_class;
           x_atp_rec.attribute_06(i) := sched_rec.attribute_06;
           x_atp_rec.organization_id(i)
             := sched_rec.organization_id;
           x_atp_rec.substitution_typ_code(i) := sched_rec.substitution_typ_code;
           x_atp_rec.req_item_detail_flag(i) := sched_rec.req_item_detail_flag;
           x_atp_rec.old_inventory_item_id(i) := sched_rec.old_inventory_item_id;
           x_atp_rec.request_item_id(i) := sched_rec.request_item_id;
           x_atp_rec.request_item_name(i) := sched_rec.request_item_name;
           x_atp_rec.req_item_req_date_qty(i) := sched_rec.req_item_req_date_qty;
           x_atp_rec.req_item_available_date(i) := sched_rec.req_item_available_date;
           x_atp_rec.req_item_available_date_qty(i) := sched_rec.req_item_available_date_qty;
           x_atp_rec.sales_rep(i) :=  sched_rec.sales_rep;
           x_atp_rec.customer_contact(i) :=  sched_rec.customer_contact;
           x_atp_rec.subst_flag(i) :=  sched_rec.subst_flag;

           --diag_atp
           x_atp_rec.attribute_02(i) := sched_rec.diagnostic_atp_flag;
	   IF PG_DEBUG in ('Y', 'C') THEN
	      msc_sch_wb.atp_debug('get_from_temp_table: ' || 'Diagnostic flag: ' || sched_rec.diagnostic_atp_flag);
	   END IF;
           i := i + 1;

        END LOOP;
        CLOSE sched_cv;

     END IF;

*/
--e_cto_reach
     IF x_mode = RESULTS_MODE and NVL(p_details_flag, 2) = 1 THEN
	MSC_ATP_UTILS.Retrieve_Period_And_SD_Data(x_session_id,
						  x_atp_period,
						  x_atp_supply_demand);

	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('leaving get_from_temp_table');
	END IF;
     END IF;   -- If x_mode = results_mode

EXCEPTION

   WHEN MSC_ATP_PUB.ATP_INVALID_OBJECTS_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('error in get_from_temp_table' || sqlerrm);
            msc_sch_wb.atp_debug('get_from_temp_table: ' || 'Invalid Objects found');
         END IF;
         RAISE MSC_ATP_PUB.ATP_INVALID_OBJECTS_FOUND;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('error in get_from_temp_table' || sqlerrm);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_from_temp_table;

FUNCTION Call_ATP_11(
		     p_group_id      NUMBER,
		     p_session_id    NUMBER,
		     p_insert_flag   NUMBER,
		     p_partial_flag  NUMBER,
		     p_err_message   IN OUT NoCopy VARCHAR2)
RETURN NUMBER is

v_dummy			NUMBER := 0;
x_atp_rec               MRP_ATP_PUB.atp_rec_typ;
x_atp_rec_out           MRP_ATP_PUB.atp_rec_typ;
x_atp_supply_demand     MRP_ATP_PUB.ATP_Supply_Demand_Typ;
x_atp_period            MRP_ATP_PUB.ATP_Period_Typ;
x_atp_details           MRP_ATP_PUB.ATP_Details_Typ;
x_return_status         VARCHAR2(1);
x_msg_data              VARCHAR2(200);
x_msg_count             NUMBER;
x_session_id            NUMBER;

ato_exists VARCHAR2(1) := 'N';
j NUMBER;

BEGIN

    SELECT NVL(count(*),0)
    INTO v_dummy
    FROM mtl_demand_interface mdi3,
	 mtl_demand_interface mdi
    WHERE  mdi3.demand_source_header_id = mdi.demand_source_header_id
    AND    mdi3.demand_source_line = mdi.demand_source_line
    AND    mdi3.demand_source_delivery = mdi.demand_source_delivery
    AND    mdi3.demand_source_type = mdi.demand_source_type
    AND    mdi3.schedule_group_id = mdi.schedule_group_id
    AND    mdi3.atp_group_id <> mdi.atp_group_id
    AND    mdi3.transaction_process_order < mdi.transaction_process_order
    AND    mdi.atp_group_id = p_group_id;

    -- this takes care of the case when call is made for rows already
    -- processed. Eg. change orders case
    IF (v_dummy <> 0) THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Call_ATP_11: ' || ' Calling API 02 ');
      END IF;

      return(INV_EXTATP_GRP.G_ALL_SUCCESS);
    END IF;

    -- Need to add logic where multiple same item requests are
    -- grouped and sent to ATP API, and updates also must be appropriate.

    SELECT
      rowidTochar(mdi.ROWID)	row_id,		/* unique identifier */
      mdi.inventory_item_id,
      mdi.organization_id,                  /* source organization id */
      NVL(mdi.demand_source_line,-1),                /* identifier  */
      NVL(mdi.demand_source_header_id, -1),
      NVL(mdi.demand_source_type, -1),
      mdi.Demand_Source_Delivery,
      mdi.atp_lead_time,
      -- NULL,                              /* scenario id */
      NULL,                              /*  calling module - not used */
      NULL,             /* customer_id - Not needed since source org is known*/
      NULL,                              /* customer site id */
      NULL,                              /* dest time zone */
      nvl(mdi.primary_uom_quantity, mdi.line_item_quantity),   /* quantity */
      nvl(msi.primary_uom_code, mdi.line_item_uom),            /* UOM */
      mdi.requirement_date request_date,    /* requirement_date */
      NULL,                              /* requested arrival date */
      mdi.latest_acceptable_date,           /* Latest_Acceptable_Date */
      NULL,                              /* Delivery_Lead_Time */
      NULL,                              /* Freight_Carrier */
      NULL,                              /* Ship_Method */
      mdi.demand_class,                  /* Demand_Class */
      Decode(p_partial_flag,0,'Ship Set',NULL),             /* Ship_Set_Name */
      NULL,                              /* Arrival_Set_Name */
      NULL,                              /* Override_Flag */
      Nvl(mdi.action_code,100),          /*ATP action code - eg.ATP inquiry,demand */
      NULL,                              /* Ship_Date */
      NULL,                              /* Available_Quantity */
      NULL,                              /* Requested_Date_Quantity */
      NULL,                              /* Group_Available_Date */
      NULL,                              /* Group_Arrival_Date */
      NULL,                              /* Vendor_Id */
      NULL,                              /* Vendor_Site_Id */
      p_insert_flag,                              /* Insert_Flag */
      NULL,                              /* Error_Code */
      NULL                               /* Message */
      bulk collect INTO
      x_atp_rec.ROW_ID,
      x_atp_rec.inventory_item_id,
      x_atp_rec.source_organization_id,
      x_atp_rec.identifier,
      x_atp_rec.Demand_Source_Header_Id,
      x_atp_rec.Demand_Source_Type,
      x_atp_rec.Demand_Source_Delivery,
      x_atp_rec.atp_lead_time,
      -- x_atp_rec.scenario_id,
      x_atp_rec.calling_module,
      x_atp_rec.customer_id,
      x_atp_rec.customer_site_id,
      x_atp_rec.destination_time_zone,
      x_atp_rec.quantity_ordered,
      x_atp_rec.quantity_uom,
      x_atp_rec.requested_ship_date,
      x_atp_rec.requested_arrival_date,
      x_atp_rec.latest_acceptable_date,
      x_atp_rec.delivery_lead_time,
      x_atp_rec.freight_carrier,
      x_atp_rec.ship_method,
      x_atp_rec.demand_class,
      x_atp_rec.ship_set_name,
      x_atp_rec.arrival_set_name,
      x_atp_rec.override_flag,
      x_atp_rec.action,
      x_atp_rec.ship_date,
      x_atp_rec.available_quantity,
      x_atp_rec.requested_date_quantity,
      x_atp_rec.group_ship_date,
      x_atp_rec.group_arrival_date,
      x_atp_rec.vendor_id,
      x_atp_rec.vendor_site_id,
      x_atp_rec.insert_flag,
      x_atp_rec.error_code,
      x_atp_rec.message
      FROM
      mrp_ap_apps_instances mai,
      ORG_ORGANIZATION_DEFINITIONS ood,
      MTL_SYSTEM_ITEMS msi,
      MTL_DEMAND_INTERFACE mdi
      WHERE 	mdi.atp_group_id = p_group_id
      AND     ((mdi.demand_type = 1
		AND EXISTS (SELECT 'ATO Model exists'
                            FROM mtl_demand_interface
			    WHERE atp_group_id = mdi.atp_group_id
			    AND demand_type = 1))
	       OR NOT EXISTS (SELECT 'ATO Model exists'
			      FROM mtl_demand_interface
			      WHERE atp_group_id = mdi.atp_group_id
			      AND demand_type = 1))
      AND     Nvl(mdi.process_flag,1) = 1
      AND     nvl(mdi.error_code,61) = 61
      AND     ood.organization_id = mdi.organization_id
      AND     msi.organization_id = mdi.organization_id
      AND     msi.inventory_item_id = mdi.inventory_item_id;

    -- Update mtl_demand_interface with the right return values
    -- call atp module
    IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('Call_ATP_11: ' || ' Calling API '||x_atp_rec.Inventory_Item_Id.COUNT);
       msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 0 '||x_atp_rec.inventory_item_id(1));
       msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 1 '||x_atp_rec.Source_Organization_Id(1));
       msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 2 '||x_atp_rec.Identifier(1));
       msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 3 '||x_atp_rec.Calling_Module(1));
       msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 4 '||x_atp_rec.Quantity_Ordered(1));
       msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 5 '||x_atp_rec.Quantity_UOM(1));
       msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 6 '||x_atp_rec.Requested_Ship_Date(1));
       msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 7 '||x_atp_rec.Latest_Acceptable_Date(1));
       msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 8 '||x_atp_rec.Action(1));
       msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 9 '||x_atp_rec.Insert_Flag(1));
    END IF;

    x_session_id := p_session_id;

    MSC_ATP_PUB.Call_ATP(
			 x_session_id,
			 x_atp_rec,
			 x_atp_rec_out,
			 x_atp_supply_demand,
			 x_atp_period,
			 x_atp_details,
			 x_return_status,
			 x_msg_data,
			 x_msg_count);

IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('Call_ATP_11: ' || 'x_atp_rec_out.Ship_Date:'
|| to_char(x_atp_rec_out.Ship_Date(1)) );
   msc_sch_wb.atp_debug('Call_ATP_11: ' || 'x_atp_rec_out.Available_Quantity:'
|| to_char(x_atp_rec_out.Available_Quantity(1)) );
   msc_sch_wb.atp_debug('Call_ATP_11: ' || 'x_atp_rec_out.Requested_Date_Quantity:'
|| to_char(x_atp_rec_out.Requested_Date_Quantity(1)) );
END IF;


    IF x_return_status <> FND_API.g_ret_sts_success THEN
       FOR j IN 1..x_atp_rec_out.Inventory_Item_Id.COUNT loop
	  UPDATE mtl_demand_interface set
	    LAST_UPDATE_DATE = SYSDATE,
	    Error_Code	= X_atp_rec_out.error_code(j),
	    Err_Explanation = X_atp_rec_out.message(j)
	    WHERE rowid = Chartorowid(X_atp_rec_out.row_id(j));
       END LOOP;

       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Call_ATP_11: ' || 'Errpr :'||x_msg_data);
       END IF;
     ELSE

       IF x_atp_rec_out.Inventory_Item_Id.COUNT > 0 THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     msc_sch_wb.atp_debug('Call_ATP_11: ' || ' atp_rec_out count '||x_atp_rec_out.ship_date.COUNT);
	     msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 00 '||x_atp_rec_out.row_id(1));
	     msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 00 '||x_atp_rec_out.requested_date_quantity(1));
	     msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 11 '||x_atp_rec_out.ship_date(1));
	     msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 22 '||x_atp_rec_out.available_quantity(1));
	     msc_sch_wb.atp_debug('Call_ATP_11: ' || ' 33 '||x_atp_rec_out.group_ship_date(1));
	  END IF;
       END IF;

       IF x_atp_rec_out.Inventory_Item_Id.COUNT > 0 THEN
	  FOR j IN 1..x_atp_rec_out.Inventory_Item_Id.COUNT LOOP
	     IF PG_DEBUG in ('Y', 'C') THEN
	        msc_sch_wb.atp_debug('Call_ATP_11: ' || ' atp_rec_out '||j);
	     END IF;
	     --	  FORALL j IN 1..x_atp_rec_out.Inventory_Item_Id.COUNT
	     -- For all was giving wierd problems in Updating date variables.

	     -- ?? Infinite_time_fence_date is being updated in inlatp.ppc
             IF PG_DEBUG in ('Y', 'C') THEN
                msc_sch_wb.atp_debug('Call_ATP_11: ' || 'christine, request date atp q is'||x_Atp_rec_out.requested_date_quantity(j));
             END IF;
	     UPDATE mtl_demand_interface
	      SET    Request_Date_ATP_Quantity = x_Atp_rec_out.requested_date_quantity(j),
	      Request_ATP_Date = To_date(To_char(X_atp_rec_out.ship_date(j), 'J'),'J'),
	      Request_ATP_Date_Quantity = X_atp_rec_out.available_quantity(j),
	      Group_Available_Date = NVL(X_atp_rec_out.group_ship_date(j),
				       requirement_date),
	      Error_Code	= X_atp_rec_out.error_code(j),
	      Err_Explanation = X_atp_rec_out.message(j)
	      WHERE rowid = Chartorowid(X_atp_rec_out.row_id(j));
	  END LOOP;
       END IF;

       IF x_atp_supply_demand.Inventory_Item_Id.COUNT > 0 THEN

	  IF PG_DEBUG in ('Y', 'C') THEN
	     msc_sch_wb.atp_debug('Call_ATP_11: ' || ' atp_sd count '||x_atp_supply_demand.Inventory_Item_Id.COUNT);
	  END IF;

	  FOR j IN 1..x_atp_supply_demand.inventory_item_id.COUNT LOOP
	     IF PG_DEBUG in ('Y', 'C') THEN
	        msc_sch_wb.atp_debug('Call_ATP_11: ' || ' atp_sd '||j);
	     END IF;
	     INSERT INTO MTL_SUPPLY_DEMAND_TEMP
	       (
		RECORD_TYPE,
		SUPPLY_DEMAND_SOURCE_TYPE,
		ON_HAND_QUANTITY,
		QUANTITY,
		DISPOSITION_TYPE,
		DISPOSITION_ID,
		SUPPLY_DEMAND_TYPE,
		REQUIREMENT_DATE,
		SEQ_NUM,
		GROUP_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		INVENTORY_ITEM_ID,
		ORGANIZATION_ID,
		C_COLUMN1,
                C_COLUMN8)
	       VALUES(
		      'SD',
		      x_atp_supply_demand.supply_demand_source_type(j),
		      NULL, -- New ATP does not calculate this
		      ROUND(x_atp_supply_demand.supply_demand_quantity(j),5),
		      x_atp_supply_demand.disposition_type(j),
		      x_atp_supply_demand.identifier3(j),
		      x_atp_supply_demand.supply_demand_type(j),
		      x_atp_supply_demand.supply_demand_date(j),
		      p_group_id,
		      p_session_id,
		      SYSDATE,
		      0,
		      SYSDATE,
		      0,
		      -1,
		      x_atp_supply_demand.inventory_item_id(j),
		      x_atp_supply_demand.organization_id(j),
		      NULL,           -- We don't need this since the form handles all cases.
	              x_atp_supply_demand.disposition_name(j)
               );

	  END LOOP;
       END IF;
       IF x_atp_period.inventory_item_id.COUNT > 0 THEN
	  IF PG_DEBUG in ('Y', 'C') THEN
	     msc_sch_wb.atp_debug('Call_ATP_11: ' || ' atp_period count '||x_atp_period.Inventory_Item_Id.COUNT);
	  END IF;

	  FOR j IN 1..x_atp_period.inventory_item_id.COUNT LOOP
	     IF PG_DEBUG in ('Y', 'C') THEN
	        msc_sch_wb.atp_debug('Call_ATP_11: ' || ' atp period '||j);
	     END IF;
	     INSERT INTO MTL_SUPPLY_DEMAND_TEMP
	       (
		ATP_PERIOD_START_DATE,
		ATP_PERIOD_END_DATE,
		ATP_PERIOD_TOTAL_SUPPLY,
		ATP_PERIOD_TOTAL_DEMAND,
		ATP,
		RECORD_TYPE,
		SEQ_NUM,
		GROUP_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		PERIOD_NET_AVAILABLE,
		INVENTORY_ITEM_ID,
		ORGANIZATION_ID)
	       VALUES(
		      x_atp_period.Period_Start_Date(j),
		      x_atp_period.Period_End_Date(j),
		      Round(x_atp_period.total_supply_quantity(j),5),
		      Round(x_atp_period.total_demand_quantity(j),5),
		      Round(x_atp_period.cumulative_quantity(j), 5),
		      'ATP',
		      p_group_id,
		      p_session_id,
		      SYSDATE,
		      0,
		      SYSDATE,
		      0,
		      -1,
		      Round(x_atp_period.period_quantity(j),5),
		      x_atp_period.inventory_item_id(j),
		      x_atp_period.organization_id(j));
	  END LOOP;
       END IF;

    END IF;

    return(INV_EXTATP_GRP.G_ALL_SUCCESS);
EXCEPTION
   WHEN OTHERS THEN
      p_err_message := substr(sqlerrm,1,100);
      return(INV_EXTATP_GRP.G_RETURN_ERROR);
End Call_ATP_11;

PROCEDURE extend_mast( mast_rec     IN OUT  NoCopy mrp_atp_utils.mrp_atp_schedule_temp_typ,
		       x_ret_code   OUT NoCopy varchar2,
		       x_ret_status OUT NoCopy varchar2) IS
BEGIN
   mast_rec.rowid_char.extend(1);
   mast_rec.sequence_number.extend(1);
   mast_rec.firm_flag.extend(1);
   mast_rec.order_line_number.extend(1);
   mast_rec.option_number.extend(1);
   mast_rec.shipment_number.extend(1);
   mast_rec.item_desc.extend(1);
   mast_rec.customer_name.extend(1);
   mast_rec.customer_location.extend(1);
   mast_rec.ship_set_name.extend(1);
   mast_rec.arrival_set_name.extend(1);
   mast_rec.requested_ship_date.extend(1);
   mast_rec.requested_arrival_date.extend(1);
   mast_rec.old_line_schedule_date.extend(1);
   mast_rec.old_source_organization_code.extend(1);
   mast_rec.firm_source_org_id.extend(1);
   mast_rec.firm_source_org_code.extend(1);
   mast_rec.firm_ship_date.extend(1);
   mast_rec.firm_arrival_date.extend(1);
   mast_rec.ship_method_text.extend(1);
   mast_rec.ship_set_id.extend(1);
   mast_rec.arrival_set_id.extend(1);
   mast_rec.project_id.extend(1);
   mast_rec.task_id.extend(1);
   mast_rec.project_number.extend(1);
   mast_rec.task_number.extend(1);
EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Excp in extend_mast : '||Substr(Sqlerrm,1,100));
      END IF;
END extend_mast;


PROCEDURE trim_mast( mast_rec     IN OUT  NoCopy mrp_atp_utils.mrp_atp_schedule_temp_typ,
		       x_ret_code   OUT NoCopy varchar2,
		       x_ret_status OUT NoCopy varchar2) IS
BEGIN
   mast_rec.rowid_char.trim(1);
   mast_rec.sequence_number.trim(1);
   mast_rec.firm_flag.trim(1);
   mast_rec.order_line_number.trim(1);
   mast_rec.option_number.trim(1);
   mast_rec.shipment_number.trim(1);
   mast_rec.item_desc.trim(1);
   mast_rec.customer_name.trim(1);
   mast_rec.customer_location.trim(1);
   mast_rec.ship_set_name.trim(1);
   mast_rec.arrival_set_name.trim(1);
   mast_rec.requested_ship_date.trim(1);
   mast_rec.requested_arrival_date.trim(1);
   mast_rec.old_line_schedule_date.trim(1);
   mast_rec.old_source_organization_code.trim(1);
   mast_rec.firm_source_org_id.trim(1);
   mast_rec.firm_source_org_code.trim(1);
   mast_rec.firm_ship_date.trim(1);
   mast_rec.firm_arrival_date.trim(1);
   mast_rec.ship_method_text.trim(1);
   mast_rec.ship_set_id.trim(1);
   mast_rec.arrival_set_id.trim(1);
   mast_rec.project_id.trim(1);
   mast_rec.task_id.trim(1);
   mast_rec.project_number.trim(1);
   mast_rec.task_number.trim(1);
EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Excp in trim_mast : '||Substr(Sqlerrm,1,100));
      END IF;
END trim_mast;

-- Bug 2974324. Redundant test procedure removed from here


-- Added on 10/16/00 by ngoel for inserting BOM data into MSC_BOM_TEMP
-- table when ATP is called with CTO models from OM or Configurator.

PROCEDURE put_into_bom_temp_table(
        p_session_id         IN    NUMBER,
	p_dblink	     IN    VARCHAR2,
        p_atp_bom_rec        IN    MRP_ATP_PUB.ATP_BOM_Rec_Typ,
        x_return_status      OUT   NoCopy VARCHAR2,
        x_msg_data           OUT   NoCopy VARCHAR2,
        x_msg_count          OUT   NoCopy NUMBER)
IS

j		PLS_INTEGER;
l_dynstring     VARCHAR2(128) := NULL;
sql_stmt        VARCHAR2(10000);

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('****Begin put_into_bom_temp_table ****');
   END IF;
   -- initialize API returm status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_dblink IS NOT NULL THEN
      l_dynstring := '@'||p_dblink;
   END IF;

   -- Delete records from msc_bom_temp_table in case there are any records
   -- with similar session id.

   -- bug 2974324. Changed the dynamic SQL to static if db_link is null
   IF p_dblink IS NULL THEN
	DELETE msc_bom_temp WHERE session_id = p_session_id;
   ELSE
	sql_stmt := 'DELETE msc_bom_temp'||l_dynstring|| ' WHERE  session_id = :session_id';

	IF PG_DEBUG in ('Y', 'C') THEN
	msc_sch_wb.atp_debug('put_into_bom_temp_table: ' || 'sql_stmt : '||sql_stmt);
	END IF;

	EXECUTE IMMEDIATE sql_stmt using p_session_id;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('put_into_bom_temp_table: ' || 'After deleting from msc_bom_temp table');
   END IF;

   j := p_atp_bom_rec.assembly_identifier.FIRST;
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('put_into_bom_temp_table: ' || 'j = '||j);
   END IF;

   -- bug 2974324. Changed the dynamic SQL to static if db_link is null
   IF p_dblink IS NOT NULL THEN

   WHILE j IS NOT NULL LOOP
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('put_into_bom_temp_table: ' || 'in loop j = '||j ||' : '|| 'item_id : ' ||
		p_atp_bom_rec.assembly_item_id(j) || ' : '||
		'comp item_id : ' ||p_atp_bom_rec.component_item_id(j)||
                ' atp flag   : ' || p_atp_bom_rec.atp_check(j));
   END IF;
   	sql_stmt := 'INSERT INTO msc_bom_temp'||l_dynstring|| ' (
                session_id,
                assembly_identifier,
		assembly_item_id,
		component_identifier,
		component_item_id,
		quantity,
		fixed_lt,
		variable_lt,
		effective_date,
		disable_date,
		atp_check,
		wip_supply_type,
		smc_flag,
                pre_process_lt,
                source_organization_id,  -- krajan: 2400614
                atp_flag                 -- krajan: 2462661
		)
	VALUES  (
		:session_id,
		:assembly_identifier,
		:assembly_item_id,
		:component_identifier,
		:component_item_id,
		:quantity,
		:fixed_lt,
		:variable_lt,
		:effective_date,
		:disable_date,
		:atp_check,
		:wip_supply_type,
		:smc_flag,
                :pre_process_lt,
                -- krajan : 2400614
                :source_organization_id,
                -- krajan : 2462661
                :atp_flag
                )';


   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('put_into_bom_temp_table: ' || 'after insert into bom_temp');
   END IF;

	EXECUTE IMMEDIATE sql_stmt using
		p_session_id,
		p_atp_bom_rec.assembly_identifier(j),
		p_atp_bom_rec.assembly_item_id(j),
		p_atp_bom_rec.component_identifier(j),
		p_atp_bom_rec.component_item_id(j),
		p_atp_bom_rec.quantity(j),
		p_atp_bom_rec.fixed_lt(j),
		p_atp_bom_rec.variable_lt(j),
		p_atp_bom_rec.effective_date(j),
		p_atp_bom_rec.disable_date(j),
		p_atp_bom_rec.atp_check(j),
		p_atp_bom_rec.wip_supply_type(j),
		p_atp_bom_rec.smc_flag(j),
                p_atp_bom_rec.pre_process_lt(j),
                -- krajan: 2400614
                p_atp_bom_rec.source_organization_id(j),
                -- krajan: 2462661
                p_atp_bom_rec.atp_flag(j);

        j := p_atp_bom_rec.assembly_identifier.NEXT(j);

   END LOOP;

     ELSE  -- bug 2974324. Changed the dynamic SQL to static if db_link is null

       FORALL j in 1..p_atp_bom_rec.assembly_identifier.COUNT
       INSERT INTO msc_bom_temp (
		session_id,
                assembly_identifier,
		assembly_item_id,
		component_identifier,
		component_item_id,
		quantity,
		fixed_lt,
		variable_lt,
		effective_date,
		disable_date,
		atp_check,
		wip_supply_type,
		smc_flag,
                pre_process_lt,
                source_organization_id,
                atp_flag)
       VALUES(
		p_session_id,
		p_atp_bom_rec.assembly_identifier(j),
		p_atp_bom_rec.assembly_item_id(j),
		p_atp_bom_rec.component_identifier(j),
		p_atp_bom_rec.component_item_id(j),
		p_atp_bom_rec.quantity(j),
		p_atp_bom_rec.fixed_lt(j),
		p_atp_bom_rec.variable_lt(j),
		p_atp_bom_rec.effective_date(j),
		p_atp_bom_rec.disable_date(j),
		p_atp_bom_rec.atp_check(j),
		p_atp_bom_rec.wip_supply_type(j),
		p_atp_bom_rec.smc_flag(j),
                p_atp_bom_rec.pre_process_lt(j),
                p_atp_bom_rec.source_organization_id(j),
                p_atp_bom_rec.atp_flag(j));

     END IF; -- bug 2974324. Changed the dynamic SQL to static if db_link is null


   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('****End put_into_bom_temp_table ****');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug(' Error in put_into_bom_temp_table '||substr(sqlerrm,1,100));
      END IF;
      x_msg_data := substr(sqlerrm,1,100);
      x_return_status := FND_API.G_RET_STS_ERROR;
END put_into_bom_temp_table;


PROCEDURE Put_Period_Data (
        p_atp_period            IN      MRP_ATP_PUB.ATP_Period_Typ,
        p_dblink                IN      VARCHAR2,
        p_session_id            IN      NUMBER )
IS
      sql_stmt		VARCHAR2(10000);
      rows_processed 	NUMBER;
      cur_handler 	NUMBER;
      l_user_id		NUMBER;
      l_sysdate		DATE;
BEGIN

   IF p_atp_period.level.COUNT > 0 THEN

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('PROCEDURE Put_Period_Data');
         msc_sch_wb.atp_debug('Put_Period_Data: ' || '   period records '||p_atp_period.level.COUNT);
      END IF;

      l_user_id := FND_GLOBAL.user_id;
      l_sysdate := sysdate;

      IF p_dblink IS NULL THEN
         FORALL j IN 1..p_atp_period.level.COUNT

	   INSERT INTO mrp_atp_details_temp
	   (
	    session_id,
	    scenario_id,
	    order_line_id,
	    atp_LEVEL,
	    inventory_item_id,
	    request_item_id,
	    organization_id,
	    department_id,
	    resource_id,
	    supplier_id,
	    supplier_site_id,
	    from_organization_id,
	    from_location_id,
	    to_organization_id,
	    to_location_id,
	    ship_method,
	    uom_code,
	    total_supply_quantity,
	    total_demand_quantity,
	    total_bucketed_demand_quantity, -- time_phased_atp
	    period_start_date,
	    period_end_date,
	    period_quantity,
	    cumulative_quantity,
	    identifier1,
	    identifier2,
            record_type,
            pegging_id,
            end_pegging_id
	    -- dsting
	    , creation_date
	    , created_by
	    , last_update_date
	    , last_updated_by
	    , last_update_login
	    )
	   VALUES
	   (
            p_session_id,
            p_atp_period.scenario_id(j),
            p_atp_period.identifier(j),
            p_atp_period.level(j),
            p_atp_period.inventory_item_id(j),
            p_atp_period.request_item_id(j),
            p_atp_period.organization_id(j),
            p_atp_period.department_id(j),
            p_atp_period.resource_id(j),
            p_atp_period.supplier_id(j),
            p_atp_period.supplier_site_id(j),
            p_atp_period.from_organization_id(j),
            p_atp_period.from_location_id(j),
            p_atp_period.to_organization_id(j),
            p_atp_period.to_location_id(j),
            p_atp_period.ship_method(j),
            p_atp_period.uom(j),
            p_atp_period.total_supply_quantity(j),
            p_atp_period.total_demand_quantity(j),
            p_atp_period.total_bucketed_demand_quantity(j), -- time_phased_atp
            p_atp_period.period_start_date(j),
            p_atp_period.period_end_date(j),
            p_atp_period.period_quantity(j),
            p_atp_period.cumulative_quantity(j),
            p_atp_period.identifier1(j),
            p_atp_period.identifier2(j),
            1,
            p_atp_period.pegging_id(j),
            p_atp_period.end_pegging_id(j)
	    -- dsting
	    , l_sysdate 		-- creation_date
	    , L_USER_ID		-- created_by
	    , l_sysdate 		-- last_update_date
	    , L_USER_ID  	-- update_by
	    , L_USER_ID 	-- login_by
	    );

     ELSE -- IF x_dblink IS NULL THEN
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('   XXX Put_Period_Data should not be called with dblink');
	END IF;

	-- dsting: added stuff for creation_date, created_by,
	-- last_update_date, last_updated_by, last_update_login

      sql_stmt := '
	   INSERT INTO mrp_atp_details_temp'||p_dblink||'
	   (
	    session_id,
	    scenario_id,
	    order_line_id,
	    atp_LEVEL,
	    inventory_item_id,
	    request_item_id,
	    organization_id,
	    department_id,
	    resource_id,
	    supplier_id,
	    supplier_site_id,
	    from_organization_id,
	    from_location_id,
	    to_organization_id,
	    to_location_id,
	    ship_method,
	    uom_code,
	    total_supply_quantity,
	    total_demand_quantity,
	    total_bucketed_demand_quantity, -- time_phased_atp
	    period_start_date,
	    period_end_date,
	    period_quantity,
	    cumulative_quantity,
	    identifier1,
	    identifier2,
            record_type,
            pegging_id,
            end_pegging_id
	  , creation_date
	  , created_by
	  , last_update_date
	  , last_updated_by
	  , last_update_login
	    )
	   VALUES
	   (
	    :x_session_id,
	    :scenario_id,
	    :identifier,
	    :atp_level,
	    :inventory_item_id,
	    :request_item_id,
	    :organization_id,
	    :department_id,
	    :resource_id,
	    :supplier_id,
	    :supplier_site_id,
	    :from_organization_id,
	    :from_location_id,
	    :to_organization_id,
	    :to_location_id,
	    :ship_method,
	    :uom,
	    :total_supply_quantity,
	    :total_demand_quantity,
            :total_bucketed_demand_quantity, -- time_phased_atp
	    :period_start_date,
	    :period_end_date,
	    :period_quantity,
	    :cumulative_quantity,
	    :identifier1,
	    :identifier2,
            1,
            :pegging_id,
            :end_pegging_id
	  , sysdate
	  , :created_by
	  , sysdate
	  , :created_by
	  , :created_by
	    )';

      -- Obtain cursor handler for sql_stmt
      cur_handler := DBMS_SQL.OPEN_CURSOR;

      -- Parse cursor handler for sql_stmt
      DBMS_SQL.PARSE(cur_handler, sql_stmt, DBMS_SQL.NATIVE);

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Put_Period_Data: ' || 'enter put_into_temp_table :just before execute');
      END IF;

      FOR j IN 1..p_atp_period.level.COUNT LOOP

          -- Bind variables in the loop for insert.

          DBMS_SQL.BIND_VARIABLE(cur_handler, ':x_session_id', p_session_id);
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':scenario_id', p_atp_period.scenario_id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':identifier', p_atp_period.identifier(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':atp_level', p_atp_period.Level(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Inventory_Item_Id', p_atp_period.Inventory_Item_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Request_Item_Id', p_atp_period.Request_Item_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Organization_Id', p_atp_period.Organization_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Department_Id', p_atp_period.Department_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Resource_Id', p_atp_period.Resource_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Supplier_Id', p_atp_period.Supplier_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Supplier_Site_Id', p_atp_period.Supplier_Site_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':From_Organization_Id', p_atp_period.From_Organization_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':From_Location_Id', p_atp_period.From_Location_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':To_Organization_Id', p_atp_period.To_Organization_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':To_Location_Id', p_atp_period.To_Location_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Ship_Method', p_atp_period.Ship_Method(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Uom', p_atp_period.Uom(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':total_supply_quantity', p_atp_period.total_supply_quantity(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':total_demand_quantity', p_atp_period.total_demand_quantity(j));
          -- time_phased_atp
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':total_bucketed_demand_quantity', p_atp_period.total_bucketed_demand_quantity(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':period_start_date', p_atp_period.period_start_date(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':period_end_date', p_atp_period.period_end_date(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':period_quantity', p_atp_period.period_quantity(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':cumulative_quantity', p_atp_period.cumulative_quantity(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Identifier1', p_atp_period.Identifier1(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Identifier2', p_atp_period.Identifier2(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':pegging_id', p_atp_period.pegging_id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':end_pegging_id', p_atp_period.end_pegging_id(j));

	  -- dsting
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':created_by',
						   L_USER_ID);

          -- Execute the cursor
          rows_processed := DBMS_SQL.EXECUTE(cur_handler);

      END LOOP;

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Put_Period_Data: ' || 'enter put_into_temp_table :after execute');
      END IF;

      -- Close the cursor in case it is open
      IF DBMS_SQL.IS_OPEN(cur_handler) THEN
         DBMS_SQL.CLOSE_CURSOR(cur_handler);
      END IF;

     END IF; -- IF x_dblink IS NULL THEN

   END IF;
END Put_Period_Data;

-- dsting unused after s/d changes
PROCEDURE Put_Pegging_data (p_session_id IN NUMBER,
                            p_dblink     IN VARCHAR2)

IS

SQL_STMT 	VARCHAR2(10000);
l_user_id	number;
BEGIN
      -- for pegging part: we are not storing pegging records in record of
      -- tables.  The pegging records will always be there in the server,
      -- if the source instance is different than the server, we need to
      -- put it back into source.

      l_user_id := FND_GLOBAL.USER_ID;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Put_Pegging_data: ' || 'p_dblink = ' ||p_dblink);
      END IF;

      IF p_dblink is not null THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Put_Pegging_data: ' || 'inserting pegging into source side');
        END IF;
	-- Bug 1761545, added component_identifier in pegging for MATO

	-- dsting: added creation_date, created_by,
	-- last_update_date, last_updated_by, last_update_login

        sql_stmt := '
              INSERT INTO mrp_atp_details_temp@'||p_dblink|| '
                 (session_id,
                  order_line_id,
                  pegging_id,
                  parent_pegging_id,
                  atp_level,
                  record_type,
                  organization_id,
                  organization_code,
                  identifier1,
                  identifier2,
                  identifier3,
                  inventory_item_id,
                  inventory_item_name,
                  resource_id,
                  resource_code,
                  department_id,
                  department_code,
                  supplier_id,
                  supplier_name,
                  supplier_site_id,
                  supplier_site_name,
                  scenario_id,
                  source_type,
                  supply_demand_source_type,
                  supply_demand_quantity,
                  supply_demand_type,
                  supply_demand_date,
                  end_pegging_id,
                  constraint_flag,
                  number1,
		  char1,
		  component_identifier,
                  allocated_quantity,
                  batchable_flag,
                  -- 2152184
                  request_item_id,
                  ptf_date
		  -- dsting
		  , creation_date
		  , created_by
		  , last_update_date
		  , last_updated_by
		  , last_update_login )
                  SELECT
                  session_id,
                  order_line_id,
                  pegging_id,
                  parent_pegging_id,
                  atp_level,
                  record_type,
                  organization_id,
                  organization_code,
                  identifier1,
                  identifier2,
                  identifier3,
                  inventory_item_id,
                  inventory_item_name,
                  resource_id,
                  resource_code,
                  department_id,
                  department_code,
                  supplier_id,
                  supplier_name,
                  supplier_site_id,
                  supplier_site_name,
                  scenario_id,
                  source_type,
                  supply_demand_source_type,
                  supply_demand_quantity,
                  supply_demand_type,
                  supply_demand_date,
                  end_pegging_id,
                  constraint_flag,
                  number1,
		  char1,
		  component_identifier,
                  allocated_quantity,
                  batchable_flag,
                  -- 2152184
                  request_item_id,
                  ptf_date
		, sysdate
		, :created_by
		, sysdate
		, :created_by
		, :created_by
                  FROM mrp_atp_details_temp
                  WHERE record_type = 3
                  AND   session_id = :x_session_id ';

                  EXECUTE IMMEDIATE sql_stmt USING
				-- dsting
				l_user_id,
				l_user_id,
				l_user_id,
				p_session_id;

                  IF PG_DEBUG in ('Y', 'C') THEN
                     msc_sch_wb.atp_debug('Put_Pegging_data: ' || 'inserted pegging into source side');
                  END IF;


                  -- after the insert is done, delete the pegging records
                  -- at the server since they are not needed anymore
                  begin
                  DELETE from  mrp_atp_details_temp
                  WHERE record_type = 3
                  AND   session_id = p_session_id;
                  exception
                    when others then null;
                  end;

      END IF;
END Put_Pegging_data;

Procedure Put_Scheduling_data(p_atp_rec            IN   MRP_ATP_PUB.atp_rec_typ,
                              p_mode               IN   NUMBER,
                              p_dblink             IN   VARCHAR2,
                              p_session_id         IN   NUMBER
)
IS

      j NUMBER;
      l_dynstring VARCHAR2(128) := NULL;
      sql_stmt    VARCHAR2(10000);
      l_atp_rec   MRP_ATP_PUB.atp_rec_typ;
      l_status_flag	NUMBER := 99; -- bug 2974324. Initialize l_status_flag to 99 here.
      l_sequence_number	MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(); -- for bug 2974324.
      found NUMBER;

      mast_rec mrp_atp_utils.mrp_atp_schedule_temp_typ;
      mast_rec_insert mrp_atp_utils.mrp_atp_schedule_temp_typ;
      TYPE mastcurtyp IS REF CURSOR;
      mast_cursor mastcurtyp;
      l_ret_code VARCHAR2(1);
      l_ret_status VARCHAR2(100);
      cur_handler NUMBER;
      rows_processed NUMBER;
      l_plan_name  varchar2(10);   -- for bug 2392456
      l_user_id    number;
      l_count	number; -- for bug 2974324

BEGIN

      l_user_id := FND_GLOBAL.USER_ID;
      IF p_dblink IS NOT NULL THEN
	l_dynstring := '@' || p_dblink;
      END IF;

      l_count := p_atp_rec.Inventory_Item_Id.COUNT; -- Bug 2974324

---s_cto_rearch
      IF l_count > 0 THEN
           IF p_mode = RESULTS_MODE THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                   msc_sch_wb.atp_debug('Put_Scheduling_data in results mode: ' || ' output records '|| l_count );
              END IF;
              MSC_ATP_UTILS.Put_sch_data_result_mode(p_atp_rec, p_dblink, p_session_id);
           ELSE
              MSC_ATP_UTILS.Put_sch_Data_Request_mode(p_atp_rec, p_session_id);
           END IF;
      END IF;
---e_cto_rearch


END Put_Scheduling_data;

PROCEDURE Retrieve_Period_and_SD_Data(
	p_session_id	IN		NUMBER,
	x_atp_period	OUT NOCOPY	MRP_ATP_PUB.ATP_Period_Typ,
	x_atp_supply_demand OUT NOCOPY	MRP_ATP_PUB.ATP_Supply_Demand_Typ
) IS

BEGIN

     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('PROCEDURE Retrieve_Period_And_SD_Data');
     END IF;

     -----------------
     -- Period Data --
     -----------------
     SELECT
	    scenario_id,
	    order_line_id,
	    atp_LEVEL,
	    inventory_item_id,
	    request_item_id,
	    organization_id,
	    department_id,
	    resource_id,
	    supplier_id,
	    supplier_site_id,
	    from_organization_id,
	    from_location_id,
	    to_organization_id,
	    to_location_id,
	    ship_method,
	    uom_code,
	    total_supply_quantity,
	    total_demand_quantity,
	    total_bucketed_demand_quantity, -- time_phased_atp
	    period_start_date,
	    period_end_date,
	    period_quantity,
	    cumulative_quantity,
	    identifier1,
	    identifier2,
            pegging_id,
            end_pegging_id
     BULK COLLECT INTO
            x_atp_period.scenario_id,
            x_atp_period.identifier,
            x_atp_period.level,
            x_atp_period.inventory_item_id,
            x_atp_period.request_item_id,
            x_atp_period.organization_id,
            x_atp_period.department_id,
            x_atp_period.resource_id,
            x_atp_period.supplier_id,
            x_atp_period.supplier_site_id,
            x_atp_period.from_organization_id,
            x_atp_period.from_location_id,
            x_atp_period.to_organization_id,
            x_atp_period.to_location_id,
            x_atp_period.ship_method,
            x_atp_period.uom,
            x_atp_period.total_supply_quantity,
            x_atp_period.total_demand_quantity,
            x_atp_period.total_bucketed_demand_quantity, -- time_phased_atp
            x_atp_period.period_start_date,
            x_atp_period.period_end_date,
            x_atp_period.period_quantity,
            x_atp_period.cumulative_quantity,
            x_atp_period.identifier1,
            x_atp_period.identifier2,
            x_atp_period.pegging_id,
            x_atp_period.end_pegging_id
     FROM mrp_atp_details_temp
     WHERE session_id = p_session_id
	  and record_type = 1
          and pegging_id in (select pegging_id from mrp_atp_details_temp
                             where session_id = p_session_id
                             and    record_type = 3);

     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Retrieve_Period_and_SD_Data: ' || '   Rows period data: ' || SQL%ROWCOUNT);
     END IF;

     -------------
     -- SD Data --
     -------------
     SELECT ORDER_LINE_ID
          ,PEGGING_ID
          ,ATP_LEVEL
          ,REQUEST_ITEM_ID
          ,INVENTORY_ITEM_ID
          ,ORGANIZATION_ID
          ,DEPARTMENT_ID
          ,RESOURCE_ID
          ,SUPPLIER_ID
          ,SUPPLIER_SITE_ID
          ,FROM_ORGANIZATION_ID
          ,FROM_LOCATION_ID
          ,TO_ORGANIZATION_ID
          ,TO_LOCATION_ID
          ,SHIP_METHOD
          ,UOM_CODE
          ,IDENTIFIER1
          ,IDENTIFIER2
          ,IDENTIFIER3
          ,IDENTIFIER4
          ,SUPPLY_DEMAND_TYPE
          ,SUPPLY_DEMAND_DATE
          ,SUPPLY_DEMAND_QUANTITY
          ,SUPPLY_DEMAND_SOURCE_TYPE
          ,SCENARIO_ID
          ,DISPOSITION_TYPE
          ,DISPOSITION_NAME
          ,SUPPLY_DEMAND_SOURCE_TYPE_NAME
          ,END_PEGGING_ID
     bulk collect into

     x_atp_supply_demand.identifier,
     x_atp_supply_demand.pegging_id,
     x_atp_supply_demand.Level,
     x_atp_supply_demand.Request_Item_Id,
     x_atp_supply_demand.Inventory_Item_Id,
     x_atp_supply_demand.Organization_Id,
     x_atp_supply_demand.Department_Id,
     x_atp_supply_demand.Resource_Id,
     x_atp_supply_demand.Supplier_Id,
     x_atp_supply_demand.Supplier_Site_Id,
     x_atp_supply_demand.From_Organization_Id,
     x_atp_supply_demand.From_Location_Id,
     x_atp_supply_demand.To_Organization_Id,
     x_atp_supply_demand.To_Location_Id,
     x_atp_supply_demand.Ship_Method,
     x_atp_supply_demand.Uom,
     x_atp_supply_demand.Identifier1,
     x_atp_supply_demand.Identifier2,
     x_atp_supply_demand.Identifier3,
     x_atp_supply_demand.Identifier4,
     x_atp_supply_demand.Supply_Demand_Type,
     x_atp_supply_demand.Supply_Demand_Date,
     x_atp_supply_demand.supply_demand_quantity,
     x_atp_supply_demand.Supply_Demand_Source_Type,
     x_atp_supply_demand.scenario_id,
     x_atp_supply_demand.disposition_type,
     x_atp_supply_demand.disposition_name,
     x_atp_supply_demand.Supply_Demand_Source_Type_name,
     x_atp_supply_demand.end_pegging_id
     FROM mrp_atp_details_temp
     WHERE session_id = p_session_id
	  and record_type = 2
          and pegging_id in (select pegging_id from mrp_atp_details_temp
                             where session_id = p_session_id
                             and    record_type = 3);


     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Retrieve_Period_and_SD_Data: ' || '   Rows SD data: ' || SQL%ROWCOUNT);
     END IF;

END Retrieve_Period_and_SD_Data;

/*
 * dsting 10/1/02
 *
 * IF dblink is set then
 *    transfer data from dest mrp_atp_details_temp to src
 * ELSE it's a nondistributed setup
 *    transfer data from mrp_atp_Details_temp to pl/sql tables
 *
 */
PROCEDURE Transfer_mrp_atp_details_temp(
	p_dblink	IN		VARCHAR2,
	p_session_id	IN		NUMBER
) IS
   sql_stmt VARCHAR2(10000);
   l_std_cols     CONSTANT VARCHAR2(3000) := '
SESSION_ID
,ORDER_LINE_ID
,PEGGING_ID
,PARENT_PEGGING_ID
,ATP_LEVEL
,REQUEST_ITEM_ID
,INVENTORY_ITEM_ID
,INVENTORY_ITEM_NAME
,ORGANIZATION_ID
,ORGANIZATION_CODE
,DEPARTMENT_ID
,DEPARTMENT_CODE
,RESOURCE_ID
,RESOURCE_CODE
,SUPPLIER_ID
,SUPPLIER_NAME
,SUPPLIER_SITE_ID
,SUPPLIER_SITE_NAME
,FROM_ORGANIZATION_ID
,FROM_ORGANIZATION_CODE
,FROM_LOCATION_ID
,FROM_LOCATION_CODE
,TO_ORGANIZATION_ID
,TO_ORGANIZATION_CODE
,TO_LOCATION_ID
,TO_LOCATION_CODE
,SHIP_METHOD
,UOM_CODE
,IDENTIFIER1
,IDENTIFIER2
,IDENTIFIER3
,IDENTIFIER4
,SUPPLY_DEMAND_TYPE
,SUPPLY_DEMAND_DATE
,SUPPLY_DEMAND_QUANTITY
,SUPPLY_DEMAND_SOURCE_TYPE
,ALLOCATED_QUANTITY
,SOURCE_TYPE
,RECORD_TYPE
,TOTAL_SUPPLY_QUANTITY
,TOTAL_DEMAND_QUANTITY
,PERIOD_START_DATE
,PERIOD_QUANTITY
,CUMULATIVE_QUANTITY
,WEIGHT_CAPACITY
,VOLUME_CAPACITY
,WEIGHT_UOM
,VOLUME_UOM
,PERIOD_END_DATE
,SCENARIO_ID
,DISPOSITION_TYPE
,DISPOSITION_NAME
,REQUEST_ITEM_NAME
,SUPPLY_DEMAND_SOURCE_TYPE_NAME
,END_PEGGING_ID
,CONSTRAINT_FLAG
,NUMBER1
,CHAR1
,COMPONENT_IDENTIFIER
,BATCHABLE_FLAG
,DEST_INV_ITEM_ID
,SUPPLIER_ATP_DATE
,SUMMARY_FLAG
,PTF_DATE ';

   l_apps_v3_cols CONSTANT VARCHAR2(3000) := '
,CREATION_DATE
,CREATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATED_BY
,LAST_UPDATE_LOGIN
,PEGGING_TYPE
,FIXED_LEAD_TIME
,VARIABLE_LEAD_TIME
,PREPROCESSING_LEAD_TIME
,PROCESSING_LEAD_TIME
,POSTPROCESSING_LEAD_TIME
,INTRANSIT_LEAD_TIME
,ATP_RULE_ID
,ALLOCATION_RULE
,INFINITE_TIME_FENCE
,SUBSTITUTION_WINDOW
,REQUIRED_QUANTITY
,ROUNDING_CONTROL
,ATP_FLAG
,ATP_COMPONENT_FLAG
,REQUIRED_DATE
,OPERATION_SEQUENCE_ID
,SOURCING_RULE_NAME
,OFFSET
,EFFICIENCY
,UTILIZATION
,OWNING_DEPARTMENT
,REVERSE_CUM_YIELD
,BASIS_TYPE
,USAGE
,CONSTRAINT_TYPE
,CONSTRAINT_DATE
,ATP_RULE_NAME
,PLAN_NAME
,constrained_path
,TOTAL_BUCKETED_DEMAND_QUANTITY -- time_phased_atp
,aggregate_time_fence_date, -- Bug 3279014
UNALLOCATED_QUANTITY, -- Bug 3282426
PF_DISPLAY_FLAG ,
ORIGINAL_DEMAND_DATE,
ORIGINAL_DEMAND_QUANTITY,
ORIGINAL_ITEM_ID,
ORIGINAL_SUPPLY_DEMAND_TYPE,
BASE_MODEL_ID,
BASE_MODEL_NAME,
MODEL_SD_FLAG,
ERROR_CODE,
NONATP_FLAG,
ORIG_CUSTOMER_SITE_NAME, --3263368
ORIG_CUSTOMER_NAME,      --3263368
ORIG_DEMAND_CLASS,       --3263368
ORIG_REQUEST_DATE,       --3263368
COMPONENT_YIELD_FACTOR,  --4570421
SCALING_TYPE,            --4570421
ROUNDING_DIRECTION,      --4570421
SCALE_ROUNDING_VARIANCE, --4570421
SCALE_MULTIPLE,          --4570421
ORGANIZATION_TYPE        --4775920
';

BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Transfer_mrp_atp_details_temp: ' || 'PROCEDURE Transfer_SD_And_Period_Data');
   END IF;

   IF p_dblink IS NOT NULL THEN
     -- transfer period (record_type 1) and s/d (2) and pegging (3) data
     -- that appear in the pegging tree
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Transfer_mrp_atp_details_temp: ' || 'apps_ver: ' || MSC_ATP_PVT.G_APPS_VER);
     END IF;

     sql_stmt := 'Insert into mrp_atp_details_temp@' || p_dblink || ' (';

     IF MSC_ATP_PVT.G_APPS_VER >= 3 THEN
	sql_stmt := sql_stmt     || l_std_cols || l_apps_v3_cols ||
		    ' ) select ' || l_std_cols || l_apps_v3_cols;
     ELSE
	sql_stmt := sql_stmt     || l_std_cols ||
		    ' ) select ' || l_std_cols;
     END IF;

     sql_stmt := sql_stmt ||
	'from mrp_atp_details_temp
        where  session_id = :p_session_id
        and    record_type in (1, 2, 3)
        and    pegging_id in (Select pegging_id from mrp_atp_details_temp
                              where  session_id = :p_session_id
                              and    record_type = 3)';
IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('Transfer_mrp_atp_details_temp: ' || 'dsting: '||sql_stmt);
END IF;
     execute immediate sql_stmt using p_session_id , p_session_id;

IF PG_DEBUG in ('Y', 'C') THEN
   msc_sch_wb.atp_debug('Transfer_mrp_atp_details_temp: ' || 'dsting: '|| SQL%ROWCOUNT);
END IF;
  END IF;

END Transfer_mrp_atp_details_temp;

/*
 * dsting 10/16/02
 *
 * Copy the supply/demand records with pegging_id = p_old_pegging_id
 * and give them the new pegging_id p_pegging_id
 *
 * Right now this is only used for the fix for bug 2621270
 */
PROCEDURE Copy_MRP_SD_Recs(
	p_old_pegging_id NUMBER,
	p_pegging_id	 NUMBER
) IS
sql_stmt VARCHAR2(3000);
who_cols VARCHAR2(100);
t1       NUMBER;
BEGIN
	IF PG_DEBUG in ('Y', 'C') THEN
	   msc_sch_wb.atp_debug('PROCEDURE Copy_MRP_SD_Recs');
	   msc_sch_wb.atp_debug('Copy_MRP_SD_Recs: ' || '   p_old_pegging_id: '     || p_old_pegging_id);
	   msc_sch_wb.atp_debug('Copy_MRP_SD_Recs: ' || '   p_pegging_id: '     || p_pegging_id);
	END IF;

	INSERT INTO mrp_atp_details_temp (
			session_id,
	 		scenario_id,
		 	order_line_id,
		 	ATP_Level,
	 		Inventory_Item_Id,
		 	Request_Item_Id,
		 	Organization_Id,
	 		Department_Id,
		 	Resource_Id,
		 	Supplier_Id,
	 		Supplier_Site_Id,
		 	From_Organization_Id,
		 	From_Location_Id,
		 	To_Organization_Id,
		 	To_Location_Id,
	 		Ship_Method,
		 	Uom_code,
		 	Identifier1,
	 		Identifier2,
		 	Identifier3,
		 	Identifier4,
	 		Supply_Demand_Type,
		 	Supply_Demand_Source_Type,
		 	Supply_Demand_Source_type_name,
	 		Supply_Demand_Date,
		 	supply_demand_quantity,
		 	disposition_type,
	 		disposition_name,
	         	record_type,
        	 	pegging_id,
         		end_pegging_id,
		 	creation_date,
	 		created_by,
		 	last_update_date,
		 	last_updated_by,
	 		last_update_login
		)
		SELECT
			MSC_ATP_PVT.G_SESSION_ID,
	 		scenario_id,
		 	order_line_id,
		 	ATP_Level,
	 		Inventory_Item_Id,
		 	Request_Item_Id,
		 	Organization_Id,
	 		Department_Id,
		 	Resource_Id,
		 	Supplier_Id,
	 		Supplier_Site_Id,
		 	From_Organization_Id,
		 	From_Location_Id,
	 		To_Organization_Id,
		 	To_Location_Id,
		 	Ship_Method,
	 		Uom_code,
		 	Identifier1,
		 	Identifier2,
	 		Identifier3,
		 	Identifier4,
		 	Supply_Demand_Type,
	 		Supply_Demand_Source_Type,
		 	Supply_Demand_Source_type_name,
		 	Supply_Demand_Date,
	 		supply_demand_quantity,
		 	disposition_type,
		 	disposition_name,
         		2,
	         	p_pegging_id,
        	 	end_pegging_id,
		 	creation_date,
	 		created_by,
		 	last_update_date,
		 	last_updated_by,
	 		last_update_login
		FROM mrp_atp_details_temp
		where pegging_id = p_old_pegging_id
		and   record_type = 2;

		IF PG_DEBUG in ('Y', 'C') THEN
		   msc_sch_wb.atp_debug('Copy_MRP_SD_Recs: ' || '    Num rows copied: ' || SQL%ROWCOUNT);
		END IF;

END Copy_MRP_SD_Recs;

Procedure Process_Supply_Demand_details( p_dblink             IN    varchar2,
                                         p_session_id         IN    number,
                                         x_atp_supply_demand  OUT NOCOPY MRP_ATP_PUB.ATP_Supply_Demand_Typ)
IS
  j                    PLS_INTEGER := 1;
  sql_stmt             VARCHAR2(10000);
  sched_cv             mrp_atp_utils.SchedCurTyp;
  details_rec          mrp_atp_utils.Details_Temp;
  l_dynstring          VARCHAR2(128) := NULL;

BEGIN

  IF p_dblink IS NOT NULL THEN
     l_dynstring := '@'||p_dblink;
  END IF;

  IF l_dynstring is not null then
     ---distributed database:
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Process_Supply_Demand_details: ' || 'Distributed environment. Put from dest to source table');
     END IF;
     sql_stmt := 'Insert into mrp_atp_details_temp' || l_dynstring ||
           '(select * from mrp_atp_details_temp
            where  session_id = :p_session_id
            and    record_type = 2
            and    pegging_id in (Select pegging_id from mrp_atp_details_temp
                                  where  session_id = :p_session_id
                                  and    record_type = 3))';
     execute immediate sql_stmt using p_session_id , p_session_id;

  ELSE --- IF p_dblink is not null then
     --- non-distributed environment
     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('Process_Supply_Demand_details: ' || 'Non Distributed env. Put SD details from temp table to pl/sql tables');
     END IF;
     j := 1;
     SELECT ORDER_LINE_ID
          ,PEGGING_ID
          ,ATP_LEVEL
          ,REQUEST_ITEM_ID
          ,INVENTORY_ITEM_ID
          ,ORGANIZATION_ID
          ,DEPARTMENT_ID
          ,RESOURCE_ID
          ,SUPPLIER_ID
          ,SUPPLIER_SITE_ID
          ,FROM_ORGANIZATION_ID
          ,FROM_LOCATION_ID
          ,TO_ORGANIZATION_ID
          ,TO_LOCATION_ID
          ,SHIP_METHOD
          ,UOM_CODE
          ,IDENTIFIER1
          ,IDENTIFIER2
          ,IDENTIFIER3
          ,IDENTIFIER4
          ,SUPPLY_DEMAND_TYPE
          ,SUPPLY_DEMAND_DATE
          ,SUPPLY_DEMAND_QUANTITY
          ,SUPPLY_DEMAND_SOURCE_TYPE
          ,SCENARIO_ID
          ,DISPOSITION_TYPE
          ,DISPOSITION_NAME
          ,SUPPLY_DEMAND_SOURCE_TYPE_NAME
          ,END_PEGGING_ID
     bulk collect into

     x_atp_supply_demand.identifier,
     x_atp_supply_demand.pegging_id,
     x_atp_supply_demand.Level,
     x_atp_supply_demand.Request_Item_Id,
     x_atp_supply_demand.Inventory_Item_Id,
     x_atp_supply_demand.Organization_Id,
     x_atp_supply_demand.Department_Id,
     x_atp_supply_demand.Resource_Id,
     x_atp_supply_demand.Supplier_Id,
     x_atp_supply_demand.Supplier_Site_Id,
     x_atp_supply_demand.From_Organization_Id,
     x_atp_supply_demand.From_Location_Id,
     x_atp_supply_demand.To_Organization_Id,
     x_atp_supply_demand.To_Location_Id,
     x_atp_supply_demand.Ship_Method,
     x_atp_supply_demand.Uom,
     x_atp_supply_demand.Identifier1,
     x_atp_supply_demand.Identifier2,
     x_atp_supply_demand.Identifier3,
     x_atp_supply_demand.Identifier4,
     x_atp_supply_demand.Supply_Demand_Type,
     x_atp_supply_demand.Supply_Demand_Date,
     x_atp_supply_demand.supply_demand_quantity,
     x_atp_supply_demand.Supply_Demand_Source_Type,
     x_atp_supply_demand.scenario_id,
     x_atp_supply_demand.disposition_type,
     x_atp_supply_demand.disposition_name,
     x_atp_supply_demand.Supply_Demand_Source_Type_name,
     x_atp_supply_demand.end_pegging_id
     FROM mrp_atp_details_temp
     WHERE session_id = p_session_id
	  and record_type = 2
          and pegging_id in (select pegging_id from mrp_atp_details_temp
                             where session_id = p_session_id
                             and    record_type = 3);


  END IF;

END Process_Supply_Demand_Details;

------------------------------------------------------------------------

/*
 * dsting 10/1/02 supply/demand performance enh
 *
 * DEPRECATED
 *
 * Put_SD_Data should not be doing anything now
 * p_atp_supply_demand should have 0 records in it
 * since sd data is never stored in pl/sql tables during processing
 *
 */
PROCEDURE Put_SD_Data (
        p_atp_supply_demand     IN      MRP_ATP_PUB.ATP_Supply_Demand_Typ,
        p_dblink                IN      VARCHAR2,
        p_session_id            IN      NUMBER )
IS

      sql_stmt    VARCHAR2(10000);
      rows_processed NUMBER;
      cur_handler NUMBER;
      l_user_id   number;
BEGIN

   l_user_id := FND_GLOBAL.USER_ID;

   IF p_atp_supply_demand.level.COUNT > 0 THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Put_SD_Data: ' || ' SD records '||p_atp_supply_demand.level.COUNT);
         msc_sch_wb.atp_debug('XXX should not have sd records in Put_SD_Data');
      END IF;

     IF p_dblink IS NULL THEN

       FORALL j IN 1..p_atp_supply_demand.level.COUNT
	INSERT INTO mrp_atp_details_temp
	(
	 session_id,
	 scenario_id,
	 order_line_id,
	 ATP_Level,
	 Inventory_Item_Id,
	 Request_Item_Id,
	 Organization_Id,
	 Department_Id,
	 Resource_Id,
	 Supplier_Id,
	 Supplier_Site_Id,
	 From_Organization_Id,
	 From_Location_Id,
	 To_Organization_Id,
	 To_Location_Id,
	 Ship_Method,
	 Uom_code,
	 Identifier1,
	 Identifier2,
	 Identifier3,
	 Identifier4,
	 Supply_Demand_Type,
	 Supply_Demand_Source_Type,
	 Supply_Demand_Source_type_name,
	 Supply_Demand_Date,
	 supply_demand_quantity,
	 disposition_type,
	 disposition_name,
         record_type,
         pegging_id,
         end_pegging_id
	 -- dsting
	 , creation_date
	 , created_by
	 , last_update_date
	 , last_updated_by
	 , last_update_login
	 )
	VALUES
	(
	 p_session_id,
	 p_atp_supply_demand.scenario_id(j),
	 p_atp_supply_demand.identifier(j),
	 p_atp_supply_demand.LEVEL(j),
         p_atp_supply_demand.Inventory_Item_Id(j),
         p_atp_supply_demand.Request_Item_Id(j),
         p_atp_supply_demand.Organization_Id(j),
         p_atp_supply_demand.Department_Id(j),
         p_atp_supply_demand.Resource_Id(j),
         p_atp_supply_demand.Supplier_Id(j),
         p_atp_supply_demand.Supplier_Site_Id(j),
         p_atp_supply_demand.From_Organization_Id(j),
         p_atp_supply_demand.From_Location_Id(j),
         p_atp_supply_demand.To_Organization_Id(j),
         p_atp_supply_demand.To_Location_Id(j),
         p_atp_supply_demand.Ship_Method(j),
         p_atp_supply_demand.Uom(j),
         p_atp_supply_demand.Identifier1(j),
         p_atp_supply_demand.Identifier2(j),
         p_atp_supply_demand.Identifier3(j),
         p_atp_supply_demand.Identifier4(j),
         p_atp_supply_demand.Supply_Demand_Type(j),
         p_atp_supply_demand.Supply_Demand_Source_Type(j),
         p_atp_supply_demand.Supply_Demand_Source_Type_name(j),
         p_atp_supply_demand.Supply_Demand_Date(j),
         p_atp_supply_demand.supply_demand_quantity(j),
         p_atp_supply_demand.disposition_type(j),
         p_atp_supply_demand.disposition_name(j),
         2,
         p_atp_supply_demand.pegging_id(j),
         p_atp_supply_demand.end_pegging_id(j)
	 -- dsting
	 , sysdate 	-- creation_date
	 , l_user_id	-- created_by
	 , sysdate 	-- last_update_date
	 , l_user_id	-- updated_by
	 , l_user_id	-- login_by
	 );


     ELSE -- OF IF x_dblink IS NULL THEN

	-- dsting: added stuff for creation_date, created_by,
	-- last_update_date, last_updated_by, last_update_login

      sql_stmt := '
	INSERT INTO mrp_atp_details_temp@'||p_dblink||'
	(
	 session_id,
	 scenario_id,
	 order_line_id,
	 ATP_Level,
	 Inventory_Item_Id,
	 Request_Item_Id,
	 Organization_Id,
	 Department_Id,
	 Resource_Id,
	 Supplier_Id,
	 Supplier_Site_Id,
	 From_Organization_Id,
	 From_Location_Id,
	 To_Organization_Id,
	 To_Location_Id,
	 Ship_Method,
	 Uom_code,
	 Identifier1,
	 Identifier2,
	 Identifier3,
	 Identifier4,
	 Supply_Demand_Type,
	 Supply_Demand_Source_Type,
	 Supply_Demand_Source_type_name,
	 Supply_Demand_Date,
	 supply_demand_quantity,
	 disposition_type,
	 disposition_name,
         record_type,
         pegging_id,
         end_pegging_id
	, creation_date
	, created_by
	, last_update_date
	, last_updated_by
	, last_update_login
	 )
	VALUES
	(
	 :x_session_id,
	 :scenario_id,
	 :identifier,
	 :atp_level,
	 :Inventory_Item_Id,
	 :Request_Item_Id,
	 :Organization_Id,
	 :Department_Id,
	 :Resource_Id,
	 :Supplier_Id,
	 :Supplier_Site_Id,
	 :From_Organization_Id,
	 :From_Location_Id,
	 :To_Organization_Id,
	 :To_Location_Id,
	 :Ship_Method,
	 :Uom_Code,
	 :Identifier1,
	 :Identifier2,
	 :Identifier3,
	 :Identifier4,
	 :Supply_Demand_Type,
	 :Supply_Demand_Source_Type,
	 :name,
	 :Supply_Demand_Date,
	 :supply_demand_quantity,
	 :disposition_type,
	 :disposition_name,
         2,
         :pegging_id,
         :end_pegging_id
	, sysdate
	, :created_by
	, sysdate
	, :last_updated_by
	, :last_update_login
	 )';

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Put_SD_Data: ' || 'enter put_into_temp_table in between values and execute ');
      END IF;

      -- Obtain cursor handler for sql_stmt
      cur_handler := DBMS_SQL.OPEN_CURSOR;

      -- Parse cursor handler for sql_stmt
      DBMS_SQL.PARSE(cur_handler, sql_stmt, DBMS_SQL.NATIVE);

      FOR j IN 1..p_atp_supply_demand.level.COUNT LOOP
          -- Bind variables in the loop for insert.

          DBMS_SQL.BIND_VARIABLE(cur_handler, ':x_session_id', p_session_id);
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':scenario_id', p_atp_supply_demand.scenario_id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':identifier', p_atp_supply_demand.identifier(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':atp_level', p_atp_supply_demand.Level(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Inventory_Item_Id', p_atp_supply_demand.Inventory_Item_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Request_Item_Id', p_atp_supply_demand.Request_Item_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Organization_Id', p_atp_supply_demand.Organization_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Department_Id', p_atp_supply_demand.Department_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Resource_Id', p_atp_supply_demand.Resource_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Supplier_Id', p_atp_supply_demand.Supplier_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Supplier_Site_Id', p_atp_supply_demand.Supplier_Site_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':From_Organization_Id', p_atp_supply_demand.From_Organization_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':From_Location_Id', p_atp_supply_demand.From_Location_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':To_Organization_Id', p_atp_supply_demand.To_Organization_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':To_Location_Id', p_atp_supply_demand.To_Location_Id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Ship_Method', p_atp_supply_demand.Ship_Method(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Uom_Code', p_atp_supply_demand.Uom(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Identifier1', p_atp_supply_demand.Identifier1(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Identifier2', p_atp_supply_demand.Identifier2(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Identifier3', p_atp_supply_demand.Identifier3(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Identifier4', p_atp_supply_demand.Identifier4(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Supply_Demand_Type', p_atp_supply_demand.Supply_Demand_Type(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Supply_Demand_Source_Type', p_atp_supply_demand.Supply_Demand_Source_Type(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':name', p_atp_supply_demand.Supply_Demand_Source_Type_name(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':Supply_Demand_Date', p_atp_supply_demand.Supply_Demand_Date(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':supply_demand_quantity', p_atp_supply_demand.supply_demand_quantity(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':disposition_type', p_atp_supply_demand.disposition_type(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':disposition_name', p_atp_supply_demand.disposition_name(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':pegging_id', p_atp_supply_demand.pegging_id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':end_pegging_id', p_atp_supply_demand.end_pegging_id(j));
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':created_by', l_user_id);
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':last_updated_by', l_user_id);
          DBMS_SQL.BIND_VARIABLE(cur_handler, ':last_update_login', l_user_id);

          -- Execute the cursor
          rows_processed := DBMS_SQL.EXECUTE(cur_handler);

      END LOOP;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Put_SD_Data: ' || 'enter put_into_temp_table :20');
      END IF;

      -- Close the cursor in case it is open
      IF DBMS_SQL.IS_OPEN(cur_handler) THEN
         DBMS_SQL.CLOSE_CURSOR(cur_handler);
      END IF;

     END IF; -- IF x_db_link IS NULL
   END IF;

END Put_SD_Data;

procedure Update_Line_Item_Properties(p_session_id IN NUMBER,
                                      Action       IN NUMBER) --3720018
IS
BEGIN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Inside Update_Line_Item_Properties');
         msc_sch_wb.atp_debug('Update item properties');
      END IF;
      update mrp_atp_schedule_temp mast
      --bug 4078703: Populate atp_lead time as this lead time is required
      --on OM sales order lies to support misc. functionalities in inv and
      --other module. Here we populte it on top model line only.  This value is populated
      -- option class and items in put_sch_data_resulst_mode procedure
      set (atp_flag, atp_components_flag, bom_item_type, pick_components_flag, fixed_lt, variable_lt, atp_lead_time) =
      (Select msi.atp_flag,
              decode(MSC_ATP_PVT.G_INV_CTP, 5,
                       --IF ATP flag for PTO model/ATO model is other than 'N' then we still go to destination
                       -- Thats why atp components flag is set as it is for PTO ato models
                       decode(mast.order_line_id, mast.ato_model_line_id, msi.atp_components_flag,
                          decode(msi.pick_components_flag, 'Y', msi.atp_components_flag, 'N')) ,
                     msi.atp_components_flag ),
              msi.bom_item_type,
              msi.pick_components_flag,
              msi.fixed_lead_time,
              msi.VARIABLE_LEAD_TIME,
              ---bug 4078703: populate ATP lead time
              CEIL(decode(mast.order_line_id, mast.ato_model_line_id,
                          decode(bom_item_type, 1,
                                (NVL(msi.fixed_lead_time, 0) + (NVL(msi.VARIABLE_LEAD_TIME, 0) * mast.quantity_ordered)) * (1 + MSC_ATP_PVT.G_MSO_LEAD_TIME_FACTOR), 0), null))
       from mtl_system_items msi
       where msi.organization_id = nvl(mast.source_organization_id, mast.validation_org)
       and   msi.inventory_item_id = mast.inventory_item_id)
       where mast.session_id = p_session_id
       --bug 3378648
       and   mast.status_flag in (99,4)--4658238
       and   (mast.source_organization_id is not null
              or mast.validation_org is not null);

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('After updating item properties');
         msc_sch_wb.atp_debug('Rows updated := ' || SQL%ROWCOUNT);
      END IF;

      --3720018, this query will update old_source_organization_id and old_demand_class
      -- in case of atp inquiry for a scheduled line from sales order pad
      IF ( NVL(Action, -1) = 100 ) THEN
         update mrp_atp_schedule_temp mast
         set (mast.old_source_organization_id,  mast.Old_Demand_Class )=
                  (SELECT mast.Source_Organization_Id,
                          NVL(mast.Old_Demand_Class, mast.demand_class)
                   from oe_order_lines_all o
                   where o.line_id = mast.order_line_id and
                         o.schedule_ship_date is not NULL
                   )
         where mast.Old_Source_Organization_Id is NULL and
               mast.session_id = p_session_id;
      END IF;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('After updating old_source_organization_id and old_demand_class');
         msc_sch_wb.atp_debug('Rows updated := ' || SQL%ROWCOUNT);
      END IF;
      -- 3720018

END Update_Line_item_properties;

procedure Put_Sch_data_Request_Mode(p_atp_rec IN   MRP_ATP_PUB.atp_rec_typ,
                                           p_session_id   IN NUMBER)
IS
l_status_flag  NUMBER := 99;
j              NUMBER;
l_user_id      number;
l_sequence_number MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr();
l_count        number;

begin

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('enter Put_Sch_data_Request_Mode');
   END IF;

   l_user_id := FND_GLOBAL.USER_ID;
   l_count := p_atp_rec.inventory_item_id.count;
    --- Delete Old Data
   Delete from mrp_atp_schedule_temp where session_id = p_session_id
   --bug 3378648: delete only ATP relevent data
   and status_flag in (1,2, 99);

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('***** After Deleting data for old session ****');
   END IF;

   l_sequence_number.Extend(l_count);

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('After Extending Sequence array');
   END IF;
   IF  nvl(p_atp_rec.calling_module(1), -1) in (-1, 724,-99) THEN
       FOR j in 1..l_count LOOP
           l_sequence_number(j) := j;
       END LOOP;
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('l_sequence_number.count := ' || l_sequence_number.count);
          msc_sch_wb.atp_debug('l_count := ' || l_count);
       END IF;
   END IF;


   FORALL j in 1..l_count
   INSERT INTO mrp_atp_schedule_temp
   (
      mdi_rowid,
      session_id,
      scenario_id,
      sr_instance_id,
      inventory_item_id ,
      inventory_item_name,
      source_organization_id,
      source_organization_code,
      order_header_id,            -- add
      Demand_Source_Delivery,
      Demand_Source_Type,
      atp_lead_time,
      order_line_id,            -- different
      order_number,
      calling_module,
      customer_id,
      customer_site_id,
      destination_time_zone,
      quantity_ordered,
      uom_code,
      requested_ship_date,
      requested_arrival_date,
      latest_acceptable_date,
      delivery_lead_time,
      freight_carrier,
      ship_method,
      demand_class,
      ship_set_name,
      arrival_set_name,
      override_flag,
      action,
      scheduled_ship_date,  -- different
      available_quantity,
      requested_date_quantity,
      group_ship_date,
      group_arrival_date,
      vendor_id,
      vendor_name,
      vendor_site_id,
      vendor_site_name,
      insert_flag,
      error_code,
      error_Message,
       status_flag,
      oe_flag,
      end_pegging_id,
      old_source_organization_id,
      old_demand_class,
      scheduled_arrival_date,
      attribute_06,
      organization_id,
      substitution_typ_code,
      req_item_detail_flag,
      old_inventory_item_id,
      request_item_id,
      request_item_name,
      req_item_req_date_qty,
      req_item_available_date_qty,
      req_item_available_date,
      sales_rep,
      customer_contact,
      subst_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      diagnostic_atp_flag,
      sequence_number,
      source_doc_id,
      ---columns for CTO project
      Top_Model_line_id,
      ATO_Parent_Model_Line_Id,
      ATO_Model_Line_Id,
      Parent_line_id,
      match_item_id,
      Config_item_line_id,
      Validation_Org,
      Component_Sequence_ID,
      Component_Code,
      line_number,
      included_item_flag,
      atp_flag,
      firm_flag,
      order_line_number,
      option_number,
      shipment_number,
      item_desc,
      old_line_schedule_date,
      old_source_organization_code,
      firm_source_org_id,
      firm_source_org_code,
      firm_ship_date,
      firm_arrival_date,
      ship_method_text,
      ship_set_id,
      arrival_set_id,
      PROJECT_ID,
      TASK_ID,
      PROJECT_NUMBER,
      TASK_NUMBER,
      original_request_date,
      CASCADE_MODEL_INFO_TO_COMP,
      internal_org_id, --4279623
      customer_country, --2814895
      customer_state,
      customer_city,
      customer_postal_code,
      party_site_id,
      part_of_set ---4500382

   )
   values
   (
      p_atp_rec.row_id(j),
      p_session_id,
      NVL(p_atp_rec.scenario_id(j), -1),
      MSC_ATP_PVT.G_INSTANCE_ID,
      --p_atp_rec.instance_id(j),
      p_atp_rec.inventory_item_id(j) ,
      p_atp_rec.inventory_item_name(j),
      p_atp_rec.source_organization_id(j),
      p_atp_rec.source_organization_code(j),
      nvl(p_atp_rec.demand_source_header_id(j), -1),
      p_atp_rec.demand_source_delivery(j),
      p_atp_rec.demand_source_type(j),
      p_atp_rec.atp_lead_time(j),
      NVL(p_atp_rec.identifier(j),0),
      p_atp_rec.order_number(j),
      p_atp_rec.calling_module(j),
      p_atp_rec.customer_id(j),
      p_atp_rec.customer_site_id(j),
      p_atp_rec.destination_time_zone(j),
      p_atp_rec.quantity_ordered(j),
      p_atp_rec.quantity_uom(j),
      p_atp_rec.requested_ship_date(j),
      p_atp_rec.requested_arrival_date(j),
      p_atp_rec.latest_acceptable_date(j),
      p_atp_rec.delivery_lead_time(j),
      p_atp_rec.freight_carrier(j),
      p_atp_rec.ship_method(j),
      p_atp_rec.demand_class(j),
      p_atp_rec.ship_set_name(j),
      p_atp_rec.arrival_set_name(j),
      p_atp_rec.override_flag(j),
      p_atp_rec.action(j),
      p_atp_rec.ship_date(j),
      p_atp_rec.available_quantity(j),
      p_atp_rec.requested_date_quantity(j),
      p_atp_rec.group_ship_date(j),
      p_atp_rec.group_arrival_date(j),
      p_atp_rec.vendor_id(j),
      p_atp_rec.vendor_name(j),
      p_atp_rec.vendor_site_id(j),
      p_atp_rec.vendor_site_name(j),
      p_atp_rec.insert_flag(j),
      p_atp_rec.error_code(j),
      p_atp_rec.message(j),
      l_status_flag,
      p_atp_rec.oe_flag(j),
      p_atp_rec.end_pegging_id(j),
      p_atp_rec.old_source_organization_id(j),
      p_atp_rec.old_demand_class(j),
      p_atp_rec.arrival_date(j),
      p_atp_rec.attribute_06(j),
      p_atp_rec.organization_id(j),
      p_atp_rec.substitution_typ_code(j),
      p_atp_rec.req_item_detail_flag(j),
      p_atp_rec.old_inventory_item_id(j),
      p_atp_rec.request_item_id(j),
      p_atp_rec.request_item_name(j),
      p_atp_rec.req_item_req_date_qty(j),
      p_atp_rec.req_item_available_date_qty(j),
      p_atp_rec.req_item_available_date(j),
      p_atp_rec.sales_rep(j),
      p_atp_rec.customer_contact(j),
      p_atp_rec.subst_flag(j),
      sysdate,
      l_user_id,
      sysdate,
      l_user_id,
      l_user_id,
      p_atp_rec.attribute_02(j),
      decode( nvl(p_atp_rec.calling_module(j),-1),724,l_sequence_number(j),
                                          -99,l_sequence_number(j),
                                          -1, l_sequence_number(j),
                                           p_atp_rec.attribute_11(j)),
      p_atp_rec.attribute_01(j),
      --cto_attribute
      p_atp_rec.Top_Model_line_id(j),
      p_atp_rec.ATO_Parent_Model_Line_Id(j),
      p_atp_rec.ATO_Model_Line_Id(j),
      p_atp_rec.Parent_line_id(j),
      p_atp_rec.match_item_id(j),
      p_atp_rec.Config_item_line_id(j),
      p_atp_rec.Validation_Org(j),
      p_atp_rec.Component_Sequence_ID(j),
      p_atp_rec.Component_Code(j),
      p_atp_rec.line_number(j),
      p_atp_rec.included_item_flag(j),
      decode(p_atp_rec.source_organization_id(j), null, 'Y', null),
      p_atp_rec.firm_flag(j),
      p_atp_rec.order_line_number(j),
      p_atp_rec.option_number(j),
      p_atp_rec.shipment_number(j),
      p_atp_rec.item_desc(j),
      p_atp_rec.old_line_schedule_date(j),
      p_atp_rec.old_source_organization_code(j),
      p_atp_rec.firm_source_org_id(j),
      p_atp_rec.firm_source_org_code(j),
      p_atp_rec.firm_ship_date(j),
      p_atp_rec.firm_arrival_date(j),
      p_atp_rec.ship_method_text(j),
      p_atp_rec.ship_set_id(j),
      p_atp_rec.arrival_set_id(j),
      p_atp_rec.PROJECT_ID(j),
      p_atp_rec.TASK_ID(j),
      p_atp_rec.PROJECT_NUMBER(j),
      p_atp_rec.TASK_NUMBER(j),
      p_atp_rec.original_request_date(j),
      p_atp_rec.CASCADE_MODEL_INFO_TO_COMP(j),
      p_atp_rec.internal_org_id(j), --4279623
      p_atp_rec.customer_country(j), --2814895
      p_atp_rec.customer_state(j),
      p_atp_rec.customer_city(j),
      p_atp_rec.customer_postal_code(j),
      p_atp_rec.party_site_id(j),
      nvl(p_atp_rec.part_of_set(j),'N') --4500382
    );


   ---now update item attributes
   --we have already inserted atp_flag = 'Y' if source organization_id is null
   -- if source organzation_id is provided then atp_flag is inserted as null
   --If we have invalid org-item combination then atp_flag will remain null
   -- else it will be updated from atp_flag of nvl(src_ord, validation_org)
   IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug('After Inserting the data in request mode');
       msc_sch_wb.atp_debug('rows inserted = ' || SQL%ROWCOUNT);
   END IF;

   IF MSC_ATP_PVT.G_CALLING_MODULE <> 724 THEN
      /*
      update mrp_atp_schedule_temp mast
      set (atp_flag, atp_components_flag, bom_item_type, pick_components_flag, fixed_lt, variable_lt) =
      (Select msi.atp_flag,
              decode(MSC_ATP_PVT.G_INV_CTP, 5,
                       --IF ATP flag for PTO model/ATO model is other than 'N' then we still go to destination
                       -- Thats why atp components flag is set as it is for PTO ato models
                       decode(mast.order_line_id, mast.ato_model_line_id, msi.atp_components_flag,
                          decode(msi.pick_components_flag, 'Y', msi.atp_components_flag, 'N')) ,
                     msi.atp_components_flag ),
              msi.bom_item_type,
              msi.pick_components_flag,
              msi.fixed_lead_time,
              msi.VARIABLE_LEAD_TIME
       from mtl_system_items msi
       where msi.organization_id = nvl(mast.source_organization_id, mast.validation_org)
       and   msi.inventory_item_id = mast.inventory_item_id)
       where mast.session_id = p_session_id
       --bug 3378648: only update request data
       and status_flag = 99
       and   (mast.source_organization_id is not null
              or mast.validation_org is not null);

      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('After updating item properties');
         msc_sch_wb.atp_debug('Rows updated := ' || SQL%ROWCOUNT);
      END IF;
      */
      MSC_ATP_UTILS.Update_Line_item_properties(p_session_id, p_atp_rec.action(1)); --3720018
      /*
      -- Bug 3449812 - Removed IF to populate internal_org in all cases
      -- IF MSC_ATP_PVT.G_INV_CTP = 4 THEN
                --add condition to fiter based on atp query
                --removing the condition below to suport OE flag for all modules.
                     --and (MSC_ATP_PVT.G_CALLING_MODULE IN (-1, 660)) THEN
          IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('Check if OE flag has been turned on or not');
          END IF;
          select count(*)
          into   l_count
          from mrp_atp_schedule_temp mast
          where mast.session_id = p_session_id
          --bug 3378648
          and status_flag = 99
          and   mast.OE_FLAG = 'Y';

          IF PG_DEBUG in ('Y', 'C') THEN
            msc_sch_wb.atp_debug('l_count for OE Flag := ' || l_count);
          END IF;

          IF l_count > 0 then

             update mrp_atp_schedule_temp  mast
             set    OE_FLAG =
                       (Select decode(MSC_ATP_PVT.G_INV_CTP, 5, mast.OE_FLAG,
                               decode( prha.interface_source_code, 'MRP', 'Y', 'MSC', 'Y', 'N'))
                        from   po_requisition_headers_all prha
                        where  prha.requisition_header_id = mast.source_doc_id),
                    INTERNAL_ORG_ID =                                           -- Bug 3449812
                       (Select po.destination_organization_id
                        from   po_requisition_lines_all po,
                               oe_order_lines_all oe
                        where  oe.source_document_line_id = po.requisition_line_id
                        and    oe.line_id = mast.order_line_id)
             where  mast.session_id = p_session_id
             --bug 3378648: only update request data
             and    status_flag = 99
             and    mast.OE_FLAG = 'Y';

             IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('After updating OE Flag ');
             END IF;

          END IF;

      -- END IF; */
   ELSE
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Call from destination Instance. No need to update atp flags or oe flags');
      END IF;
   END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('exit Put_Sch_data_Request_Mode');
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    msc_sch_wb.atp_debug('Something wrong in Put_Sch_data_Request_Mode');
    msc_sch_wb.atp_debug('Sql Err := ' || sqlerrm);

END Put_Sch_Data_Request_Mode;

Procedure Put_Sch_data_result_mode(p_atp_rec IN  MRP_ATP_PUB.atp_rec_typ,
                                          p_dblink             IN   VARCHAR2,
                                          p_session_id         IN   NUMBER)
IS
      j NUMBER;
      l_dynstring VARCHAR2(128) := NULL;
      sql_stmt    VARCHAR2(10000);
      l_atp_rec   MRP_ATP_PUB.atp_rec_typ;
      l_status_flag     NUMBER := 99; -- bug 2974324. Initialize l_status_flag to 99 here.
      l_sequence_number MRP_ATP_PUB.number_arr := MRP_ATP_PUB.number_arr(); -- for bug 2974324.
      found NUMBER;

      mast_rec mrp_atp_utils.mrp_atp_schedule_temp_typ;
      mast_rec_insert mrp_atp_utils.mrp_atp_schedule_temp_typ;
      TYPE mastcurtyp IS REF CURSOR;
      mast_cursor mastcurtyp;
      l_ret_code VARCHAR2(1);
      l_ret_status VARCHAR2(1000);
      cur_handler NUMBER;
      rows_processed NUMBER;
      l_plan_name  varchar2(10);   -- for bug 2392456
      l_user_id    number;
      l_count   number; -- for bug 2974324
      l_count_temp number;


BEGIN


   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('enter Put_Sch_data_result_mode');
      msc_sch_wb.atp_debug('G_INCLUDED_ITEM_IS_PRESENT :=' || MSC_ATP_CTO.G_INCLUDED_ITEM_IS_PRESENT);
   END IF;

   -- bug 2974324. Set l_status_flag to 2 here.
   l_status_flag := SYS_NO;
   l_count := p_atp_rec.inventory_item_id.count;


       msc_sch_wb.atp_debug('l_count := '||  l_count);
      /*l_sequence_number.extend(l_count);
      FOR j in 1..l_count LOOP
         l_sequence_number(j) := j;
      END LOOP; */
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug(' insert data for Call from  other modules');
         FOR j in 1..l_count LOOP
            msc_sch_wb.atp_debug('j');
            msc_sch_wb.atp_debug('Identifier := ' ||  p_atp_rec.identifier(j));
            msc_sch_wb.atp_debug('Mandatory flag := ' ||  p_atp_rec.mandatory_item_flag(j));
            msc_sch_wb.atp_debug('sequence number := ' || p_atp_rec.sequence_number(j));
            msc_sch_wb.atp_debug('atp_lead_time := ' || p_atp_rec.atp_lead_time(j));

         END LOOP;
      END IF;

      FORALL j in 1..l_count
         ---bug 3295956: Merge two update sqls in 1. Update ship method on component lines from
         -- model line. Cascade info to components based on value of cascade_model_info_to_comp attribute
         UPDATE MRP_ATP_SCHEDULE_TEMP
         SET

		scenario_id = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    NVL(p_atp_rec.scenario_id(j), -1), scenario_id),
		inventory_item_id = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.inventory_item_id(j), inventory_item_id),
		inventory_item_name = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.inventory_item_name(j), inventory_item_name),
		source_organization_id =Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.source_organization_id(j),
                                        Decode(nvl(cascade_model_info_to_comp, 1), 1,
                                                     p_atp_rec.source_organization_id(j), null)),
		source_organization_code = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.source_organization_code(j),
                                           Decode(nvl(cascade_model_info_to_comp, 1), 1,
                                                     p_atp_rec.source_organization_code(j), null)),
		order_header_id = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    nvl(p_atp_rec.demand_source_header_id(j), -1), null),
		Demand_Source_Type = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.demand_source_type(j), null),
		delivery_lead_time = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.delivery_lead_time(j),
                                      Decode(nvl(cascade_model_info_to_comp, 1), 1,
                                                    p_atp_rec.delivery_lead_time(j), null)),
		ship_method = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.ship_method(j),
                                      Decode(nvl(cascade_model_info_to_comp, 1), 1,
                                      p_atp_rec.ship_method(j), null)),
		demand_class = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.demand_class(j), null),
		scheduled_ship_date = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.ship_date(j),
                                       Decode(nvl(cascade_model_info_to_comp, 1), 1,
                                                     p_atp_rec.ship_date(j),null)),
		available_quantity = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.available_quantity(j), null),
		requested_date_quantity =  Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.requested_date_quantity(j), null),
		group_ship_date =  Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.group_ship_date(j),
                                           Decode(nvl(cascade_model_info_to_comp, 1), 1,
                                                    p_atp_rec.group_ship_date(j), null)),
		group_arrival_date = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.group_arrival_date(j),
                                           Decode(nvl(cascade_model_info_to_comp, 1), 1,
                                                    p_atp_rec.group_arrival_date(j),null)),
		error_code = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.error_code(j),
                                     Decode(error_code, null,decode(p_atp_rec.error_code(j), 150, 0, 61, 0, 0, 0, MSC_ATP_PVT.GROUPEL_ERROR))),
		error_Message = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.message(j), null),
		status_flag = 2,
		end_pegging_id = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.end_pegging_id(j),
                                           Decode(nvl(cascade_model_info_to_comp, 1), 1,
                                                    p_atp_rec.end_pegging_id(j),null)),
		scheduled_arrival_date = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.arrival_date(j),
                                           Decode(nvl(cascade_model_info_to_comp, 1), 1,
                                                    p_atp_rec.arrival_date(j),null)),
		organization_id = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.organization_id(j), null),
		request_item_id = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.request_item_id(j), null),
		request_item_name = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.request_item_name(j), null),
		req_item_req_date_qty = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.req_item_req_date_qty(j), null),
		req_item_available_date_qty = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.req_item_available_date_qty(j), null),
		req_item_available_date =Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.req_item_available_date(j), null),
		sales_rep =  Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                    p_atp_rec.sales_rep(j),  null),
		customer_contact = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                                   p_atp_rec.customer_contact(j), null),
		compile_designator = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                    DECODE(MSC_ATP_PVT.G_INV_CTP, 4, p_atp_rec.attribute_07(j), null), null),
		subst_flag = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                    p_atp_rec.subst_flag(j), null),
                match_item_id = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                    p_atp_rec.match_item_id(j), null),
                matched_item_name = Decode(order_line_id, NVL(ato_model_line_id, order_line_id),
                                    p_atp_rec.matched_item_name(j), null),
                plan_id = p_atp_rec.plan_id(j),
                --bug 3328421
                first_valid_ship_arrival_date = p_atp_rec.first_valid_ship_arrival_date(j),
                --bug 4078703: update atp_lead_time on options
                --atp_lead_time = Decode(order_line_id, NVL(ato_model_line_id, order_line_id), 0, p_atp_rec.atp_lead_time(j))
               -- atp_lead_time = Decode(order_line_id, NVL(ato_model_line_id, order_line_id), NULL, p_atp_rec.atp_lead_time(j))
               atp_lead_time = Decode(ato_model_line_id, null, null, order_line_id, 0, p_atp_rec.atp_lead_time(j))

                where session_id = p_session_id
                --bug 3378648: update only request data
                and status_flag = 99
                and   NVL(ato_model_line_id, order_line_id)  = p_atp_rec.identifier(j)
                and   NVL(p_atp_rec.mandatory_item_flag(j), 2) = 2
                --bug 3347424: added this condition so that line corresponding
                --to particular warehouse is update in case of global order promising
                --bug 3373467: Following condition doesn't work if no sources are found.
                -- in that case source orgs remian null and we were not updating any thing.
                and   NVL(source_organization_id, NVL(p_atp_rec.source_organization_id(j), -1)) =
                                                            NVL(p_atp_rec.source_organization_id(j), -1);
                --and   sequence_number =  p_atp_rec.sequence_number(j);
                --add condition for inv id and seq id
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('After Updating the table');
          msc_sch_wb.atp_debug('Rows Updated := ' || SQL%ROWCOUNT);
       END IF;

       IF MSC_ATP_CTO.G_INCLUDED_ITEM_IS_PRESENT  =1 THEN
          ---included items are present. Insert them into table
          IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('Included Items are present');
          END IF;
          --couldn't find a wayt to insert data selectively from
          -- pl/sql table to temp table. Therefore, copying the records for the time being.
          FOR j in 1..p_atp_rec.inventory_item_id.count LOOP
              IF NVL(p_atp_rec.mandatory_item_flag(j), 2)  = 1 THEN
                  IF PG_DEBUG in ('Y', 'C') THEN
                       msc_sch_wb.atp_debug('Add Included item for line := ' || j);
                  END IF;
                  MSC_SATP_FUNC.Assign_Atp_Input_Rec(p_atp_rec,
                                                     j,
                                                     l_atp_rec,
                                                     l_ret_status );
              END IF;
          END LOOP;

          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Number of included items := ' || l_atp_rec.inventory_item_id.count);
          END IF;
          l_count := l_atp_rec.inventory_item_id.count;
          FORALL j in 1..l_count
             INSERT INTO mrp_atp_schedule_temp
		   (
		   mdi_rowid,
		   session_id,
		   scenario_id,
		   sr_instance_id,
		   inventory_item_id,
		   inventory_item_name,
		   source_organization_id,
		   source_organization_code,
		   order_header_id,            -- add
		   Demand_Source_Delivery,
		   Demand_Source_Type,
		   atp_lead_time,
		   order_line_id,            -- different
		   order_number,
		   calling_module,
		   customer_id,
		   customer_site_id,
		   destination_time_zone,
		   quantity_ordered,
		   uom_code,
		   requested_ship_date,
		   requested_arrival_date,
		   latest_acceptable_date,
		   delivery_lead_time,
		   freight_carrier,
		   ship_method,
		   demand_class,
		   ship_set_name,
		   arrival_set_name,
		   override_flag,
		   action,
		   scheduled_ship_date,  -- different
		   available_quantity,
		   requested_date_quantity,
		   group_ship_date,
		   group_arrival_date,
		   vendor_id,
		   vendor_name,
		   vendor_site_id,
		   vendor_site_name,
		   insert_flag,
		   error_code,
		   error_Message,
		   status_flag,
		   oe_flag,
		   end_pegging_id,
		   old_source_organization_id,
		   old_demand_class,
		   scheduled_arrival_date,
		   attribute_06,
		   organization_id,
		   substitution_typ_code,
		   req_item_detail_flag,
		   old_inventory_item_id,
		   request_item_id,
		   request_item_name,
		   req_item_req_date_qty,
		   req_item_available_date_qty,
		   req_item_available_date,
		   sales_rep,
		   customer_contact,
		   compile_designator,      -- added for bug 2392456
		   subst_flag,
		   creation_date,
		   created_by,
		   last_update_date,
		   last_updated_by,
		   last_update_login,
		   diagnostic_atp_flag,
		   sequence_number,
                   mandatory_item_flag,
                   --bug 3328421:
                   first_valid_ship_arrival_date
		   )
	        VALUES
		   (
		   l_atp_rec.row_id(j),
		   p_session_id,
		   NVL(l_atp_rec.scenario_id(j), -1),
		   l_atp_rec.instance_id(j),
		   l_atp_rec.inventory_item_id(j),
		   l_atp_rec.inventory_item_name(j),
		   l_atp_rec.source_organization_id(j),
		   l_atp_rec.source_organization_code(j),
		   nvl(l_atp_rec.demand_source_header_id(j), -1),
		   l_atp_rec.demand_source_delivery(j),
		   l_atp_rec.demand_source_type(j),
		   l_atp_rec.atp_lead_time(j),
		   NVL(l_atp_rec.identifier(j),0),
		   l_atp_rec.order_number(j),
		   l_atp_rec.calling_module(j),
		   l_atp_rec.customer_id(j),
		   l_atp_rec.customer_site_id(j),
		   l_atp_rec.destination_time_zone(j),
		   l_atp_rec.quantity_ordered(j),
		   l_atp_rec.quantity_uom(j),
		   l_atp_rec.requested_ship_date(j),
		   l_atp_rec.requested_arrival_date(j),
		   l_atp_rec.latest_acceptable_date(j),
		   l_atp_rec.delivery_lead_time(j),
		   l_atp_rec.freight_carrier(j),
		   l_atp_rec.ship_method(j),
		   l_atp_rec.demand_class(j),
		   l_atp_rec.ship_set_name(j),
		   l_atp_rec.arrival_set_name(j),
		   l_atp_rec.override_flag(j),
		   l_atp_rec.action(j),
		   l_atp_rec.ship_date(j),
		   l_atp_rec.available_quantity(j),
		   l_atp_rec.requested_date_quantity(j),
		   l_atp_rec.group_ship_date(j),
		   l_atp_rec.group_arrival_date(j),
		   l_atp_rec.vendor_id(j),
		   l_atp_rec.vendor_name(j),
		   l_atp_rec.vendor_site_id(j),
		   l_atp_rec.vendor_site_name(j),
		   l_atp_rec.insert_flag(j),
		   l_atp_rec.error_code(j),
		   l_atp_rec.message(j),
		   l_status_flag,
		   l_atp_rec.oe_flag(j),
		   l_atp_rec.end_pegging_id(j),
		   l_atp_rec.old_source_organization_id(j),
		   l_atp_rec.old_demand_class(j),
		   l_atp_rec.arrival_date(j),
		   l_atp_rec.attribute_06(j),
		   l_atp_rec.organization_id(j),
		   l_atp_rec.substitution_typ_code(j),
		   l_atp_rec.req_item_detail_flag(j),
		   l_atp_rec.old_inventory_item_id(j),
		   l_atp_rec.request_item_id(j),
		   l_atp_rec.request_item_name(j),
		   l_atp_rec.req_item_req_date_qty(j),
		   l_atp_rec.req_item_available_date_qty(j),
		   l_atp_rec.req_item_available_date(j),
		   l_atp_rec.sales_rep(j),
		   l_atp_rec.customer_contact(j),
		   DECODE(MSC_ATP_PVT.G_INV_CTP, 4, l_atp_rec.attribute_07(j), null ),
		   l_atp_rec.subst_flag(j),
		   sysdate,
		   l_user_id,
		   sysdate,
		   l_user_id,
		   l_user_id,
		   l_atp_rec.attribute_02(j),
                   l_atp_rec.sequence_number(j),
                   l_atp_rec.mandatory_item_flag(j),
                   --bug 3328421
                   l_atp_rec.first_valid_ship_arrival_date(j)
		   );
                   --where NVL(p_atp_rec.mandatory_item_flag(j), 2) = 1;
          IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('Number of Rows Inserted := ' || SQL%ROWCOUNT);
          END IF;
       END IF; ---  IF MSC_ATP_CTO.G_INCLUDED_ITEM_IS_PRESENT  =1 THEN




     --now update the data for ATO models
     --bug 3347424: update plan_id only for scheduling requests
     --For global ATP we get multiple lines with same line_id. as a result update was failing.
     IF MSC_ATP_CTO.G_MODEL_IS_PRESENT = 1 and p_atp_rec.action(1) <> 100  THEN

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Model is present, update model component data');
        END IF;
        --bug 3295956: cascade ship method and delivery lead time from model to components
        -- Cascade info from model to components based on cascade_model_info_to_comp attribute. This is for istore.
        /* Update mrp_atp_schedule_temp mast_1
        set (scheduled_ship_date, end_pegging_id, scheduled_arrival_date, status_flag,
             group_ship_date, group_arrival_date, plan_id, ship_method, delivery_lead_time,
             source_organization_id, error_code) =
             (select Decode(NVL(mast_1.cascade_model_info_to_comp, 1), 1, scheduled_ship_date, null),
                     Decode(NVL(mast_1.cascade_model_info_to_comp, 1), 1, end_pegging_id, null),
                     Decode(NVL(mast_1.cascade_model_info_to_comp, 1), 1, scheduled_arrival_date, null),
                     2,
                     Decode(NVL(mast_1.cascade_model_info_to_comp, 1), 1, group_ship_date,  null),
                     Decode(NVL(mast_1.cascade_model_info_to_comp, 1), 1, group_arrival_date,  null),
                     plan_id,
                     Decode(NVL(mast_1.cascade_model_info_to_comp, 1), 1, ship_method,  null),
                     Decode(NVL(mast_1.cascade_model_info_to_comp, 1), 1, delivery_lead_time,  null),
                     Decode(NVL(mast_1.cascade_model_info_to_comp, 1), 1, source_organization_id,  null),
                     decode(error_code, 150, 0, 61, 0, 0, 0, MSC_ATP_PVT.GROUPEL_ERROR)
              from mrp_atp_schedule_temp mast_2 where
              mast_2.session_id = p_session_id and
              mast_2.order_line_id = mast_1.ato_model_line_id and
              mast_2.source_organization_id = NVL(mast_1.source_organization_id, mast_2.source_organization_id)
               )
        where mast_1.session_id = p_session_id
        and   mast_1.ato_model_line_id is not null
        and   mast_1.order_line_id <> mast_1.ato_model_line_id;
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Number of Rows updated := ' || SQL%ROWCOUNT);
        END IF;
        */

        ---update plan_id on msc_cto_bom and msc_cto_sources for 24x7
        update msc_cto_bom mcb
        set plan_id = (select plan_id
                       from mrp_atp_schedule_temp  mast
                       where mast.session_id = p_session_id
                       and mast.order_line_id = mcb.line_id
                       )
        where mcb.session_id = p_session_id;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Number of Rows updated n msc_cto_bom := ' || SQL%ROWCOUNT);
        END IF;

        update msc_cto_sources mcs
        set plan_id = (select plan_id
                       from mrp_atp_schedule_temp  mast
                       where mast.session_id = p_session_id
                       and mast.order_line_id = mcs.line_id
                       )
        where mcs.session_id = p_session_id;

        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('Number of Rows updated in msc_cto_sources := ' || SQL%ROWCOUNT);
        END IF;
     END IF;


   --now transfer the data across dblink
   IF p_dblink is not null then
      Transfer_Scheduling_data(p_session_id,
                               p_dblink,
                               RESULTS_MODE);
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('exit Put_Sch_data_Result_Mode');
   END IF;

END Put_Sch_Data_Result_Mode;

Procedure Transfer_Scheduling_data(p_session_id IN Number,
                                   p_dblink     IN  VARCHAR2,
                                   p_mode       IN  NUMBER)


IS
l_sql_stmt varchar2(20000);
l_status_flag  number;
l_tnsfer_sts_flag number;
L_dest_DBLINK  varchar2(128);
l_source_dblink varchar2(128);
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('enter Transfer_Scheduling_data');
    END IF;

    IF p_mode = RESULTS_MODE THEN
       l_status_flag := 2;
       l_tnsfer_sts_flag := 2;
    ELSE
       l_status_flag := 1;
       l_tnsfer_sts_flag := 99;
    END IF;

    IF p_mode = RESULTS_MODE then
       L_source_DBLINK := '@' || p_dblink;
    ELSE
       l_dest_dblink := '@' || p_dblink;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Before deleting old data');
    END IF;

    /* bug 3378649: delete any data locally
    --delete any old data
    IF p_mode = RESULTS_MODE THEN
       l_sql_stmt :=
                'DELETE FROM MRP_ATP_SCHEDULE_TEMP'||L_source_DBLINK||
                ' WHERE session_id = :p_session_id '||
                ' and status_flag in (1, 99, 2) ';

        EXECUTE IMMEDIATE l_sql_stmt USING  p_session_id;
    ELSE
        IF PG_DEBUG in ('Y', 'C') THEN
           msc_sch_wb.atp_debug('deleting old data in local table');
        END IF;

        DELETE FROM MRP_ATP_SCHEDULE_TEMP
        WHERE session_id = p_session_id
        and status_flag in (1, 99, 2);
    END IF;
    */

    IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Number of rows deleted := ' || SQL%ROWCOUNT);
      msc_sch_wb.atp_debug('After deleting old data');
      msc_sch_wb.atp_debug('l_status_flag := ' || l_status_flag);
      msc_sch_wb.atp_debug('l_tnsfer_sts_flag := ' || l_tnsfer_sts_flag);
    END IF;

    l_sql_stmt :=
       'Insert into mrp_atp_schedule_temp' || L_source_DBLINK ||
       ' (mdi_rowid,
	session_id,
	scenario_id,
	sr_instance_id,
	inventory_item_id,
	inventory_item_name,
	source_organization_id,
	source_organization_code,
	order_header_id,
	Demand_Source_Delivery,
	Demand_Source_Type,
	atp_lead_time,
	order_line_id,
	order_number,
	calling_module,
	customer_id,
	customer_site_id,
	destination_time_zone,
	quantity_ordered,
	uom_code,
	requested_ship_date,
	requested_arrival_date,
	latest_acceptable_date,
	delivery_lead_time,
	freight_carrier,
	ship_method,
	demand_class,
	ship_set_name,
	arrival_set_name,
	override_flag,
	action,
	scheduled_ship_date,
	available_quantity,
	requested_date_quantity,
	group_ship_date,
	group_arrival_date,
	vendor_id,
	vendor_name,
	vendor_site_id,
	vendor_site_name,
	insert_flag,
	error_code,
	error_Message,
	status_flag,
	oe_flag,
	end_pegging_id,
	old_source_organization_id,
	old_demand_class,
	scheduled_arrival_date,
	attribute_06,
	organization_id,
	substitution_typ_code,
	req_item_detail_flag,
	old_inventory_item_id,
	request_item_id,
	request_item_name,
	req_item_req_date_qty,
	req_item_available_date_qty,
	req_item_available_date,
	sales_rep,
	customer_contact,
	compile_designator,
	subst_flag';
   IF MSC_ATP_PVT.G_APPS_VER >= 3  THEN
      l_sql_stmt := l_sql_stmt ||
	', creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login,
	diagnostic_atp_flag,
	sequence_number,
	firm_flag,
	order_line_number,
	option_number,
	shipment_number,
	item_desc,
	customer_name,
	customer_location,
	old_line_schedule_date,
	old_source_organization_code,
	firm_source_org_id,
	firm_source_org_code,
	firm_ship_date,
	firm_arrival_date,
	ship_method_text,
	ship_set_id,
	arrival_set_id,
	project_id,
	task_id,
	project_number,
	task_number,
        Top_Model_line_id,
        ATO_Parent_Model_Line_Id,
        ATO_Model_Line_Id,
        Parent_line_id,
        match_item_id,
        matched_item_name,
        Config_item_line_id,
        Validation_Org,
        Component_Sequence_ID,
        Component_Code,
        line_number,
        included_item_flag,
        atp_flag,
        atp_components_flag,
        wip_supply_type,
        bom_item_type,
        pick_components_flag,
        OSS_ERROR_CODE,
        original_request_date,
        mandatory_item_flag,
        CASCADE_MODEL_INFO_TO_COMP,
        INTERNAL_ORG_ID,  -- Bug 3449812
        first_valid_ship_arrival_date, -- bug 3328421
        customer_country, --2814895
        customer_state, --2814895
        customer_city, --2814895
        customer_postal_code, --2814895
        party_site_id, --2814895
        part_of_set --4500382
        ';
   END IF;

   l_sql_stmt := l_sql_stmt ||
   ' )  select
        mdi_rowid,
	session_id,
	scenario_id,
	sr_instance_id,
	inventory_item_id,
	inventory_item_name,
	source_organization_id,
	source_organization_code,
	order_header_id,
	Demand_Source_Delivery,
	Demand_Source_Type,
	atp_lead_time,
	order_line_id,
	order_number,
	calling_module,
	customer_id,
	customer_site_id,
	destination_time_zone,
	quantity_ordered,
	uom_code,
	requested_ship_date,
	requested_arrival_date,
	latest_acceptable_date,
	delivery_lead_time,
	freight_carrier,
	ship_method,
	demand_class,
	ship_set_name,
	arrival_set_name,
	override_flag,
	action,
	scheduled_ship_date,
	available_quantity,
	requested_date_quantity,
	group_ship_date,
	group_arrival_date,
	vendor_id,
	vendor_name,
	vendor_site_id,
	vendor_site_name,
	insert_flag,
	error_code,
	error_Message, ' ||
	l_tnsfer_sts_flag || ',
	oe_flag,
	end_pegging_id,
	old_source_organization_id,
	old_demand_class,
	scheduled_arrival_date,
	attribute_06,
	organization_id,
	substitution_typ_code,
	req_item_detail_flag,
	old_inventory_item_id,
	request_item_id,
	request_item_name,
	req_item_req_date_qty,
	req_item_available_date_qty,
	req_item_available_date,
	sales_rep,
	customer_contact,
	compile_designator,
	subst_flag';

   IF MSC_ATP_PVT.G_APPS_VER >= 3  THEN
      l_sql_stmt := l_sql_stmt ||
	',creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	last_update_login,
	diagnostic_atp_flag,
	sequence_number,
	firm_flag,
	order_line_number,
	option_number,
	shipment_number,
	item_desc,
	customer_name,
	customer_location,
	old_line_schedule_date,
	old_source_organization_code,
	firm_source_org_id,
	firm_source_org_code,
	firm_ship_date,
	firm_arrival_date,
	ship_method_text,
	ship_set_id,
	arrival_set_id,
	project_id,
	task_id,
	project_number,
	task_number,
        Top_Model_line_id,
        ATO_Parent_Model_Line_Id,
        ATO_Model_Line_Id,
        Parent_line_id,
        match_item_id,
        matched_item_name,
        Config_item_line_id,
        Validation_Org,
        Component_Sequence_ID,
        Component_Code,
        line_number,
        included_item_flag,
        atp_flag,
        atp_components_flag,
        wip_supply_type,
        bom_item_type,
        pick_components_flag,
        OSS_ERROR_CODE,
        original_request_date,
        mandatory_item_flag,
        CASCADE_MODEL_INFO_TO_COMP,
        INTERNAL_ORG_ID, -- Bug 3449812
        first_valid_ship_arrival_date, --bug 3328421
        customer_country, --2814895
        customer_state, --2814895
        customer_city, --2814895
        customer_postal_code, --2814895
        party_site_id, --2814895
        part_of_set --4500382
        ';
   END IF;

   l_sql_stmt := l_sql_stmt || '  from MRP_ATP_SCHEDULE_TEMP' || l_dest_dblink ||
                                  ' where session_id = :p_session_id
                                  and status_flag = ' || l_tnsfer_sts_flag ;


   IF PG_DEBUG in ('Y', 'C') THEN
               msc_sch_wb.atp_debug('Transfer_Scheduling_data: ' || l_sql_stmt);
   END IF;
   EXECUTE IMMEDIATE l_sql_stmt USING p_session_id;

   IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('Rows Transfered: ' || SQL%ROWCOUNT);
   END IF;


   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('exit Transfer_Scheduling_data');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Error Occured while transfering the data accros db link');
         msc_sch_wb.atp_debug('errro := ' ||SQLERRM);
      END IF;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Transfer_Scheduling_data;

/* Bug 5598066: Function to Truncate demand to 6 decimal places.
   Also if the 7th point if 9, it will be a 1 increase in the 6th point. */

FUNCTION Truncate_Demand (p_demand_qty IN NUMBER)
  Return NUMBER
IS
 l_truncated_demand NUMBER;
 BEGIN

l_truncated_demand := (floor((p_demand_qty + 0.0000001) * 1000000.0)/1000000.0) ;

RETURN l_truncated_demand ;
EXCEPTION
  WHEN OTHERS THEN
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('Error in function Truncate_Demand: '||sqlerrm);
   END IF;
END Truncate_Demand;


END MSC_ATP_UTILS;


/
