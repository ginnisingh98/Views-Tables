--------------------------------------------------------
--  DDL for Package Body MSC_SCH_WB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SCH_WB" AS
/* $Header: MSCOSCWB.pls 120.6.12010000.2 2009/03/26 07:41:13 sbnaik ship $ */


PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('MSC_ATP_DEBUG'), 'N');

PROCEDURE GET_ATP_RESULT (
			  x_session_id	    IN 	   number,
			  commit_flag       IN     NUMBER,
			  call_oe           IN     NUMBER,
			  x_msg_count       OUT    NoCopy number,
			  x_msg_data        OUT    NoCopy varchar2,
			  x_return_status   OUT    NoCopy varchar2,
                          p_diagnostic_atp  IN     number DEFAULT 2
                         )
IS
x_atp_rec               MRP_ATP_PUB.atp_rec_typ;
x_atp_rec_out           MRP_ATP_PUB.atp_rec_typ;
x_atp_supply_demand     MRP_ATP_PUB.ATP_Supply_Demand_Typ;
x_atp_period            MRP_ATP_PUB.ATP_Period_Typ;
x_atp_details           MRP_ATP_PUB.ATP_Details_Typ;
a_session_id            NUMBER := x_session_id;

char_1_null     varchar2(2000) := NULL;
char_30_null    varchar2(30) := NULL;
number_null	number := null;
number_one      number := 1;
date_null 	date := null;
i               NUMBER := 1;

sql_stmt        VARCHAR2(1000);
l_count         NUMBER := 0;
begin
     order_sch_wb.debug_session_id := x_session_id;

   IF PG_DEBUG in ('Y', 'C') THEN
      atp_debug('GET_ATP_RESULT: ' || 'got here');
      select count(*)
      into l_count
      from mrp_atp_schedule_temp
      where session_id = x_session_id
      and status_flag  = 1;
      atp_debug('GET_ATP_RESULT: sending that many records to ATP : ' || l_count);
   END IF;


   SELECT
     Rowidtochar(a.ROWID),
     a.inventory_item_id,
     a.inventory_item_name,
     a.organization_id,
     a.sr_instance_id,
     Decode(override_flag,'Y',
            Nvl(a.firm_source_org_id,a.source_organization_id),
                a.source_organization_id),
     Decode(override_flag,'Y',
            Nvl(a.firm_source_org_code,a.source_organization_code),
                a.source_organization_code),
     a.order_line_id,
     a.Scenario_Id,
     a.Order_Header_Id,
     a.order_number,
     a.Calling_Module,
     a.Customer_Id,
     a.Customer_Site_Id,
     a.Destination_Time_Zone,
     a.quantity_ordered,
     a.uom_code,
     Decode(override_flag,'Y',
             Nvl(a.firm_ship_date,a.requested_ship_date),
                 a.requested_ship_date),
     Decode(override_flag,'Y',
             Nvl(a.firm_arrival_date,a.requested_arrival_date),
                 a.requested_arrival_date),
     date_null,	    --	a.Earliest_Acceptable_Date,
     a.Latest_Acceptable_Date,
     a.Delivery_Lead_Time,
     a.Freight_Carrier,
     a.Ship_Method,
     a.Demand_Class,
     nvl(a.ship_set_name,
     a.ship_set_id+Nvl(a.source_organization_id,0)),    -- a.Ship_Set_Name,
     -- When it is put back into the table the name will be used.
     a.arrival_set_id, --a.Arrival_Set_Name
     -- we don't append source_org since they can be different
     -- and we don't need it since we don't have pick sources
     a.Override_Flag,
     a.Action,
     date_null,     --a.Ship_Date, ??? scheduled_ship_date
     number_null,   -- a.Available_Quantity,
     number_null,   -- a.Requested_Date_Quantity,
     date_null,     -- a.Group_Ship_Date,
     date_null,     -- a.Group_Arrival_Date,
     a.Vendor_Id,
     a.Vendor_Name,
     a.Vendor_Site_Id,
     a.Vendor_Site_Name,
     a.Insert_Flag,
     number_null,                   -- a.Error_Code,
     char_1_null,                   -- a.Error_Message
     a.old_source_organization_id,
     a.old_demand_class,
     a.atp_lead_time,               -- bug 1303240
     number_one,                    --substitution_typ_code,
     number_one,                    -- REQ_ITEM_DETAIL_FLAG
     p_diagnostic_atp,
     a.assignment_set_id,
     a.sequence_number,
     a.firm_flag,
     a.order_line_number,
     a.option_number,
     a.shipment_number,
     a.item_desc,
     a.old_line_schedule_date,
     a.old_source_organization_code,
     a.firm_source_org_id,
     a.firm_source_org_code,
     a.firm_ship_date,
     a.firm_arrival_date,
     a.ship_method_text,
     a.ship_set_id,
     a.arrival_set_id,
     a.PROJECT_ID,
     a.TASK_ID,
     a.PROJECT_NUMBER,
     a.TASK_NUMBER,
     a.Top_Model_line_id,
     a.ATO_Model_Line_Id,
     a.Parent_line_id,
     a.Config_item_line_id,
     a.Validation_Org,
     a.Component_Sequence_ID,
     a.Component_Code,
     a.line_number,
     a.included_item_flag
  BULK collect into
     x_atp_rec.row_id,
     x_atp_rec.Inventory_Item_Id,
     x_atp_rec.Inventory_Item_Name,
     x_atp_rec.organization_id,
     x_atp_rec.instance_id,
     x_atp_rec.Source_Organization_Id,
     x_atp_rec.Source_Organization_Code,
     x_atp_rec.Identifier,
     x_atp_rec.Scenario_Id,
     x_atp_rec.Demand_Source_Header_Id,
     x_atp_rec.order_number,
     x_atp_rec.Calling_Module,
     x_atp_rec.Customer_Id,
     x_atp_rec.Customer_Site_Id,
     x_atp_rec.Destination_Time_Zone,
     x_atp_rec.Quantity_Ordered,
     x_atp_rec.Quantity_UOM,
     x_atp_rec.Requested_Ship_Date,
     x_atp_rec.Requested_Arrival_Date,
     x_atp_rec.Earliest_Acceptable_Date,
     x_atp_rec.Latest_Acceptable_Date,
     x_atp_rec.Delivery_Lead_Time,
     x_atp_rec.Freight_Carrier,
     x_atp_rec.Ship_Method,
     x_atp_rec.Demand_Class,
     x_atp_rec.Ship_Set_Name,
     x_atp_rec.Arrival_Set_Name,
     x_atp_rec.Override_Flag,
     x_atp_rec.Action,
     x_atp_rec.Ship_Date,
     x_atp_rec.Available_Quantity,
     x_atp_rec.Requested_Date_Quantity,
     x_atp_rec.Group_Ship_Date,
     x_atp_rec.Group_Arrival_Date,
     x_atp_rec.Vendor_Id,
     x_atp_rec.Vendor_Name,
     x_atp_rec.Vendor_Site_Id,
     x_atp_rec.Vendor_Site_Name,
     x_atp_rec.Insert_Flag,
     x_atp_rec.Error_Code,
     x_atp_rec.message,
     x_atp_rec.old_source_organization_id,
     x_atp_rec.old_demand_class,
     x_atp_rec.atp_lead_time,  -- bug 1303240
     x_atp_rec.substitution_typ_code,
     x_atp_rec.REQ_ITEM_DETAIL_FLAG,
     x_atp_rec.attribute_02,   -- ATP Pegging
     x_atp_rec.attribute_03,
     x_atp_rec.sequence_number,
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
     x_atp_rec.PROJECT_ID,
     x_atp_rec.TASK_ID,
     x_atp_rec.PROJECT_NUMBER,
     x_atp_rec.TASK_NUMBER,
     x_atp_rec.Top_Model_line_id,
     x_atp_rec.ATO_Model_Line_Id,
     x_atp_rec.Parent_line_id,
     x_atp_rec.Config_item_line_id,
     x_atp_rec.Validation_Org,
     x_atp_rec.Component_Sequence_ID,
     x_atp_rec.Component_Code,
     x_atp_rec.line_number,
     x_atp_rec.included_item_flag
     from mrp_atp_schedule_temp a
     where a.session_id = x_session_id
     and a.status_flag = 1
     order by a.source_organization_code,
              a.sequence_number,
              a.arrival_set_id,
              a.ship_set_id,
              a.line_number,
              a.shipment_number,
              nvl(a.option_number, -1);

   if x_atp_rec.inventory_item_id.count > 0 THEN
      FOR j IN 1..x_atp_rec.inventory_item_id.count LOOP
	 IF PG_DEBUG in ('Y', 'C') THEN
	    atp_debug('GET_ATP_RESULT: ' || ' ************************************************ ');
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_table.Inventory_Item_Id: '
		||to_char(x_atp_rec.Inventory_Item_Id(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_table.inventory_item_name: '
		||x_atp_rec.Inventory_Item_Name(j) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.organization_id :'
		   || to_char(x_atp_rec.organization_id(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.instance_id:'
		   || to_char(x_atp_rec.instance_id(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Source_Organization_Id:'
		   || to_char(x_atp_rec.Source_Organization_Id(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Source_Organization_Code:'
		   || x_atp_rec.Source_Organization_Code(j));
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.order header id:'
		   || to_char(x_atp_rec.demand_source_header_id(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.order number:'
		   || to_char(x_atp_rec.order_number(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.order line id:'
		   || to_char(x_atp_rec.identifier(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.order scenario id:'
		   || to_char(x_atp_rec.scenario_id(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.calling_module:'
		   || to_char(x_atp_rec.calling_module(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.cust id:'
		   || to_char(x_atp_rec.customer_id(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.cust site id:'
		   || to_char(x_atp_rec.customer_site_id(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Quantity_Ordered:'
		   || to_char(x_atp_rec.Quantity_Ordered(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Quantity_UOM:'
		   || x_atp_rec.Quantity_UOM(j) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Requested_Ship_Date:'
		   || to_char(x_atp_rec.Requested_Ship_Date(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Requested_Arrival_Date:'
		   || to_char(x_atp_rec.Requested_Arrival_Date(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Latest_Acceptable_Date:'
		|| to_char(x_atp_rec.Latest_Acceptable_Date(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Delivery_Lead_Time:'
		   || to_char(x_atp_rec.Delivery_Lead_Time(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Freight_Carrier:'
		   || x_atp_rec.Freight_Carrier(j) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Ship_Method:'
		   || x_atp_rec.Ship_Method(j) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Demand_Class:'
		   || x_atp_rec.Demand_Class (j));
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Override_Flag:'
		   || x_atp_rec.Override_Flag (j));
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Action:'
		   || to_char(x_atp_rec.Action(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.ship_set_name:'
		   || x_atp_rec.ship_set_name(j) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.arrival_set_name:'
		   || x_atp_rec.arrival_set_name(j) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.vendor_id:'
		|| to_char(x_atp_rec.vendor_id(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.vendor_site_id:'
		   || to_char(x_atp_rec.vendor_site_id(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Insert_Flag:'
		   || to_char(x_atp_rec.Insert_Flag(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Insert_Flag:'
		   || to_char(x_atp_rec.old_source_organization_id(j)) );
	    atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Insert_Flag:'
		   || x_atp_rec.old_demand_class(j) );
            atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.Atp_Lead_time:'
                   || x_atp_rec.Atp_Lead_time(j) );
            atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.substitution_typ_code:'
                   || x_atp_rec.substitution_typ_code(j) );
            atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.REQ_ITEM_DETAIL_FLAG:'
                   || x_atp_rec.REQ_ITEM_DETAIL_FLAG(j) );
             atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.diagnostic_atp:'
                   || x_atp_rec.attribute_02(j) );
             atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.assignment_set: '
                   || x_atp_rec.attribute_03(j) );
             atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.top_model_line_id: '
                   || x_atp_rec.top_model_line_id(j) );
             atp_debug('GET_ATP_RESULT: ' || 'x_atp_rec.ato_model_line_id: '
                   || x_atp_rec.ato_model_line_id(j) );
          END IF;
      END LOOP;

   END IF;

   if x_atp_rec.inventory_item_id.count > 0 THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         atp_debug('GET_ATP_RESULT: ' || ' Before calling scheduling '||x_atp_rec.inventory_item_id.COUNT);
      END IF;

      -- 2709847, modified to call MRP procedures instead of MSC procedures as planning manager fix to insert
      -- Sales Order Line ID is invoked in MRP procedure.

     MSC_SATP_FUNC.new_extend_atp(x_atp_rec,
                                  x_atp_rec.inventory_item_id.count,
                                  x_return_status);

     IF PG_DEBUG in ('Y', 'C') THEN
         atp_debug('GET_ATP_RESULT: after new_extend_atp'|| x_return_status);
     END IF;

     IF x_return_status <> 'E' THEN

      IF commit_flag = 1 THEN
	 MRP_ATP_PUB.call_atp
	   (a_session_id,
	    x_atp_rec,
	    x_atp_rec_out,
	    x_atp_supply_demand,
	    x_atp_period,
	    x_atp_details,
	    x_return_status,
	    x_msg_data,
	    x_msg_count);
       ELSE
	 MRP_ATP_PUB.call_atp_no_commit
	   (a_session_id,
	    x_atp_rec,
	    x_atp_rec_out,
	    x_atp_supply_demand,
	    x_atp_period,
	    x_atp_details,
	    x_return_status,
	    x_msg_data,
	    x_msg_count);
      END IF;

     END IF;

   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
      atp_debug('GET_ATP_RESULT: ' || 'After calling Scheduling '||x_return_status||' $ '||x_msg_data||' $ '||x_atp_rec_out.inventory_item_id.count);
   END IF;
   if x_return_status = 'E' then
      IF PG_DEBUG in ('Y', 'C') THEN
         atp_debug('GET_ATP_RESULT: ' || ' err '||x_msg_data||' '||x_msg_count);
      END IF;
   end if;

   if x_atp_rec_out.inventory_item_id.count > 0 then
      IF PG_DEBUG in ('Y', 'C') THEN
         atp_debug('GET_ATP_RESULT: ' || ' sched date '||x_atp_rec_out.ship_date.count);
         atp_debug('GET_ATP_RESULT: ' || ' SD '||x_atp_supply_demand.level.count);
         atp_debug('GET_ATP_RESULT: ' || ' period '||x_atp_period.level.count);
         atp_debug('GET_ATP_RESULT: ' || ' details '||x_atp_details.level.count);
      END IF;
   end if;

   IF call_oe = 1 THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         atp_debug('GET_ATP_RESULT: ' || ' before call_oe_api ');
      END IF;
      msc_bal_utils.call_oe_api(x_atp_rec_out,
				x_msg_count,
				x_msg_data,
				x_return_status);
   END IF;

   IF x_return_status = 'E' THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         atp_debug('GET_ATP_RESULT: ' || ' error in call_oe_api '||x_msg_data);
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         atp_debug(' Exception in get_atp_results '||Substr(Sqlerrm,1,100));
      END IF;
      x_return_status := 'E';
      x_msg_data := Substr(Sqlerrm,1,100);
END get_atp_result;

FUNCTION get_label(p_demand_class varchar2) return varchar2 is

   cursor demand_class_desc_c(v_demand_class varchar2) is
   select distinct meaning
   from msc_demand_classes
   where demand_class = v_demand_class;

   l_ret_value varchar2(80);
begin
       if p_demand_class = '-1' OR
          p_demand_class = 'OTHER'  then
           l_ret_value := 'OTHER';
       else
           open demand_class_desc_c(p_demand_class);
           fetch demand_class_desc_c into l_ret_value;
           close demand_class_desc_c;
       end if;
       return l_ret_value;
END get_label;

FUNCTION  get_alloc_rule_variables return NUMBER
IS
begin
  IF (MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF = 'Y' AND
      MSC_ATP_PVT.G_PF_RULE_OUTSIDE_ATF = 'Y')  THEN

    msc_sch_wb.atp_debug ( 'get_alloc_rule_variables : TWO rules are being used');

    msc_sch_wb.atp_debug(' MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF   '
                            ||MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF  );

    msc_sch_wb.atp_debug('MSC_ATP_PVT.G_PF_RULE_OUTSIDE_ATF ' ||
                            MSC_ATP_PVT.G_PF_RULE_OUTSIDE_ATF);
    return 1; -- I will need to display two allocation rules in the library
  ELSIF
      (MSC_ATP_PVT.G_MEM_RULE_WITHIN_ATF <> 'Y' AND
        MSC_ATP_PVT.G_PF_RULE_OUTSIDE_ATF = 'Y') THEN
    return 2;  -- inly PF rule is used
  ELSE
    return 0; -- just single member allocation rule or standard items.
  END IF;


END;


PROCEDURE delete_lines
  ( p_session_id NUMBER,
    p_where_clause varchar2) IS
       sqlstmt VARCHAR2(100);
BEGIN
   order_sch_wb.debug_session_id := p_session_id;

   IF PG_DEBUG in ('Y', 'C') THEN
      atp_debug('delete_lines: ' || ' deleting all rows for session_id 1 '||p_session_id);
   END IF;
   sqlstmt := 'DELETE FROM mrp_atp_schedule_temp mast '||
     'WHERE '||p_where_clause||' and mast.session_id = :session_id';
   execute immediate sqlstmt using p_session_id;

   IF PG_DEBUG in ('Y', 'C') THEN
      atp_debug('delete_lines: ' || ' deleting all rows for session_id 2 '||p_session_id);
   END IF;

   DELETE FROM mrp_atp_details_temp madt
     WHERE madt.session_id = p_session_id;
   IF PG_DEBUG in ('Y', 'C') THEN
      atp_debug('delete_lines: ' || ' deleting all rows for session_id 3 '||p_session_id);
   END IF;

   commit;

END delete_lines;

PROCEDURE get_supply_sources_local(
				   x_dblink             IN      VARCHAR2,
				   x_session_id         IN      NUMBER,
				   x_sr_instance_id     IN      NUMBER,
				   x_assignment_set_id  IN      NUMBER,
				   x_plan_id            IN      NUMBER,
				   x_calling_inst       IN      VARCHAR2,
				   x_ret_status         OUT     NoCopy VARCHAR2,
				   x_error_mesg         OUT     NoCopy VARCHAR2)
  IS
     sql_stmt VARCHAR2(300);
     l_dynstring VARCHAR2(129);
     l_calling_module  NUMBER;
     l_customer_site_id NUMBER;
     l_return_status VARCHAR2(1);
     l_cursor  integer;
     rows_processed number;
     DBLINK_NOT_OPEN         EXCEPTION;
     PRAGMA  EXCEPTION_INIT(DBLINK_NOT_OPEN, -2081);
     --bug3610706
     l_node_id NUMBER;
     l_rac_count NUMBER;

     cursor cto_related_case (p_session_id NUMBER)  IS
     select 1
     from mrp_atp_schedule_temp
     where session_id = p_session_id
     and ato_model_line_id is NOT NULL
     and status_flag = 4
     and rownum = 1;

     cto_exists NUMBER :=0;
BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('****Begin Get_Supply_Sources_Local');
   END IF;

   OPEN cto_related_case(x_session_id);
   FETCH cto_related_case INTO cto_exists;
   CLOSE cto_related_case;

   --bug3610706 start
      BEGIN
        SELECT count(*)
        into l_rac_count
        from gv$instance;
        IF l_rac_count > 1 then
           l_node_id := userenv('INSTANCE');
           IF PG_DEBUG in ('Y', 'C') THEN
              msc_sch_wb.atp_debug('RAC Instance id is:' || l_node_id);
           END IF;
        ELSE
           l_node_id := null;
        END IF;
      EXCEPTION
         WHEN OTHERS THEN
           l_node_id := null;
      END;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('node id is:' || l_node_id);
      END IF;
   --bug3610706 end
   IF PG_DEBUG in ('Y', 'C') THEN
    msc_sch_wb.atp_debug(' get_supply_sources_local: cto_related_case : ' ||
                         cto_exists);
   END IF;


   IF  cto_exists = 1  THEN
    IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug(' get_supply_sources_local ' ||
                         ' calling MSC_ATP_UTILS.Update_line_item_properties');
    END IF;

   MSC_ATP_UTILS.Update_Line_Item_Properties(p_session_id => x_session_id);

   MSC_ATP_CTO. Match_CTO_Lines(p_session_id    => x_session_id,
                                p_dblink        => x_dblink,
                                p_instance_id   => x_sr_instance_id,
                                x_return_status => l_return_status);
    IF l_return_status <> 'S' THEN
     IF PG_DEBUG in ('Y', 'C') THEN
       msc_sch_wb.atp_debug( 'get_supply_sources_local '||
                            ' sth wrong was in MSC_ATP_CTO. Match_CTO_Lines '||
                            ' error is '||
                              l_return_status  );
     END IF;
    END IF;

   END IF;


   IF x_dblink IS NOT NULL AND x_calling_inst = 'APPS' THEN
      l_dynstring := '@'||x_dblink;
   END IF;
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('get_supply_sources_local: ' || 'l_dynstring : ' || l_dynstring);
   END IF;

--  savirine, Sep 06, 2001:  added the get_regions call to get the get_regions info which will be used for ATP request.

   l_calling_module := Null;
   l_customer_site_id := Null;

   IF x_calling_inst = 'APPS' THEN
     l_calling_module := null;
   ELSE
     l_calling_module := 724;  -- 724 means the calling module is APS.
   END IF;

   SELECT DISTINCT mast.customer_site_id
   INTO   l_customer_site_id
   FROM   mrp_atp_schedule_temp mast
   WHERE  mast.session_id = x_session_id
   AND    status_flag = 4;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('get_supply_sources_local: ' || 'l_calling_module : ' || l_calling_module);
      msc_sch_wb.atp_debug('get_supply_sources_local: ' || 'l_customer_site_id : ' || l_customer_site_id);
      msc_sch_wb.atp_debug('get_supply_sources_local: ' || 'x_assignment_set_id : ' || x_assignment_set_id);
   END IF;

   MSC_SATP_FUNC.Get_Regions (
                  p_customer_site_id	=> l_customer_site_id,
                  p_calling_module	=> NVL(l_calling_module, -99),
		  -- i.e. Source (ERP) or Destination (724)
	          p_instance_id		=> x_sr_instance_id,
	          p_session_id          => x_session_id,
	          p_dblink		=> x_dblink,
	          x_return_status	=> l_return_status );

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('get_supply_sources_local: ' || 'Get_Regions, return status : ' || l_return_status);
   END IF;

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      -- something wrong so we want to rollback;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('get_supply_sources_local: ' || 'expected error in Call to Get_Regions');
      END IF;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('get_supply_sources_local: ' || 'something wrong in Call to Get_Regions');
      END IF;
   END IF;
   --bug3610706 pass the node to the remote call in case of RAC
   sql_stmt :=
     ' begin msc_atp_proc.get_supply_sources'||l_dynstring||
     '(:session_id, :instance_id, :assgn_id, '||
     ' :plan_id, :inst,:l_ret_status, :l_error_mesg,:node_id); end;';

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug('get_supply_sources_local: ' || 'sql_stmt : ' || sql_stmt);
   END IF;

   execute immediate sql_stmt using x_session_id, x_sr_instance_id,
		x_assignment_set_id, x_plan_id, x_calling_inst,
		OUT x_ret_status, OUT x_error_mesg,l_node_id;

    IF x_dblink IS NOT NULL then
    l_cursor := dbms_sql.open_cursor;
    -- mark distributed transaction boundary
    -- will need to do a manual clean up (commit) of the distributed
    -- operation, else subsequent operations fail w/ ora-02080 (bug 2218999)
    commit;
    DBMS_SQL.PARSE ( l_cursor,
                     'alter session close database link ' ||x_dblink,
                     dbms_sql.native
                   );
    BEGIN
     rows_processed := dbms_sql.execute(l_cursor);
    EXCEPTION
      WHEN DBLINK_NOT_OPEN THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('get_supply_sources_local: ' || 'inside DBLINK_NOT_OPEN');
       END IF;
    END;
   end if;

  IF PG_DEBUG in ('Y', 'C') THEN
     msc_sch_wb.atp_debug('get_supply_sources_local: ' || ' After calling PATPB');
     msc_sch_wb.atp_debug('get_supply_sources_local: ' || 'x_error_mesg := ' || x_error_mesg);
     msc_sch_wb.atp_debug('get_supply_sources_local: ' || 'x_ret_status := ' || x_ret_status);
  END IF;
END get_supply_sources_local;


PROCEDURE get_atp_rule_name (
			     dblink         VARCHAR2,
			     item_id        NUMBER,
			     org_id         NUMBER,
			     sr_instance_id NUMBER,
			     atp_rule_name  OUT NoCopy VARCHAR2,
			     inst           VARCHAR2)
  IS
     sqlstring VARCHAR2(2000);
     l_dblink  VARCHAR2(128) := NULL;
     l_cursor  integer;
     rows_processed number;
     DBLINK_NOT_OPEN         EXCEPTION;
     PRAGMA  EXCEPTION_INIT(DBLINK_NOT_OPEN, -2081);
BEGIN
   IF dblink IS NOT NULL THEN
      l_dblink := '@'||dblink;
   END IF;

   IF inst = order_sch_wb.server THEN
      -- called from Planning server
      -- msc_item_id is passed in for item_id
      sqlstring :=
	' SELECT rule_name '||
	'  FROM msc_atp_rules'||l_dblink||' mar, '||
	'  msc_system_items'||l_dblink||' msi '||
	'  WHERE '||
	'  mar.rule_id = msi.atp_rule_id '||
	'  AND mar.sr_instance_id = msi.sr_instance_id '||
	'  AND msi.sr_instance_id = :sr_instance_id '||
	'  AND msi.organization_id = :org_id '||
	'  AND msi.inventory_item_id = :item_id '||
	'  AND msi.plan_id = -1';

        BEGIN
	   EXECUTE IMMEDIATE sqlstring INTO atp_rule_name
	     using sr_instance_id, org_id, item_id;

  IF l_dblink IS NOT NULL then
    l_cursor := dbms_sql.open_cursor;
    -- mark distributed transaction boundary
    -- will need to do a manual clean up (commit) of the distributed
    -- operation, else subsequent operations fail w/ ora-02080 (bug 2218999)
    commit;
    DBMS_SQL.PARSE ( l_cursor,
                     'alter session close database link ' ||l_dblink,
                     dbms_sql.native
                   );
    BEGIN
     rows_processed := dbms_sql.execute(l_cursor);
    EXCEPTION
      WHEN DBLINK_NOT_OPEN THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('get_atp_rule_name: ' || 'inside DBLINK_NOT_OPEN');
       END IF;
    END;
  end if;

	   RETURN;
	EXCEPTION
	   WHEN no_data_found THEN
	      NULL;
	END;

	sqlstring :=
	  'SELECT rule_name '||
	  ' FROM msc_atp_rules'||l_dblink||' mar, '||
	  ' msc_trading_partners'||l_dblink||' mtp '||
	  ' WHERE '||
	  ' mar.rule_id = mtp.default_atp_rule_id '||
	  ' AND mar.sr_instance_id = mtp.sr_instance_id '||
	  ' AND mtp.sr_tp_id = :org_id '||
	  ' AND mtp.sr_instance_id = :sr_instance_id '||
	  ' AND mtp.partner_type = 3';

        BEGIN
	   EXECUTE IMMEDIATE sqlstring INTO atp_rule_name
	     using org_id, sr_instance_id;

	   RETURN;
	EXCEPTION
	   WHEN no_data_found THEN
	      RETURN;
	END;
       ELSE
	      -- called from apps instance
	  BEGIN
	     SELECT rule_name
	       INTO atp_rule_name
	       FROM mtl_atp_rules mar,
	       mtl_system_items msi
	       WHERE
	       mar.rule_id = msi.atp_rule_id
	       AND msi.organization_id = org_id
	       AND msi.inventory_item_id = item_id;
	     RETURN;
	  EXCEPTION
	     WHEN no_data_found THEN
		NULL;
	  END;

	  BEGIN
	     SELECT rule_name
	       INTO atp_rule_name
	       FROM mtl_atp_rules mar,
	       mtl_parameters mp
	       WHERE
	       mar.rule_id = mp.default_atp_rule_id
	       AND mp.organization_id = org_id;
	     RETURN;
	  EXCEPTION
	     WHEN no_data_found THEN
	     RETURN;
	  END;
   END IF;

END get_atp_rule_name;

PROCEDURE get_msc_assign_set(x_dblink                   VARCHAR2,
                             x_assignment_set_id   IN  OUT NoCopy NUMBER,
                             x_sr_instance_id           NUMBER,
                             x_ret_code             OUT NoCopy VARCHAR2,
                             x_err_mesg             OUT NoCopy VARCHAR2) IS
     sqlstring VARCHAR2(500);
     l_dblink  VARCHAR2(128) := NULL;
     l_msc_assign_set_id  NUMBER;
     l_cursor  integer;
     rows_processed number;
     DBLINK_NOT_OPEN         EXCEPTION;
     PRAGMA  EXCEPTION_INIT(DBLINK_NOT_OPEN, -2081);
BEGIN

   x_ret_code := 'S';
   x_err_mesg := NULL;

   IF x_dblink IS NOT NULL THEN
      l_dblink := '@'||x_dblink;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug(' get_msc_assign_set dblink '||l_dblink);
      END IF;
   END IF;

      sqlstring :=
        ' select assignment_set_id '||
        ' from   msc_assignment_sets'||l_dblink||' '||
        ' where  sr_instance_id = :x_sr_instance_id '||
        ' and    sr_assignment_set_id = :x_assignment_set_id';
      execute immediate sqlstring INTO l_msc_assign_set_id
        using x_sr_instance_id, x_assignment_set_id;

       x_assignment_set_id := l_msc_assign_set_id;

      IF PG_DEBUG in ('Y', 'C') THEN
           atp_debug('get_msc_assign_set: ' ||
                     ' msc  assignment_set_id = '||l_msc_assign_set_id);
      END IF;

     IF l_dblink IS NOT NULL then
        l_cursor := dbms_sql.open_cursor;

       -- mark distributed transaction boundary
       -- will need to do a manual clean up (commit) of the distributed
       -- operation, else subsequent operations fail w/ ora-02080 (bug 2218999)
        commit;
        DBMS_SQL.PARSE ( l_cursor,
                    'alter session close database link ' ||l_dblink,
                     dbms_sql.native
                   );
        BEGIN
        rows_processed := dbms_sql.execute(l_cursor);
        EXCEPTION
        WHEN DBLINK_NOT_OPEN THEN
         IF PG_DEBUG in ('Y', 'C') THEN
          atp_debug('get_assignment_set: ' || 'inside DBLINK_NOT_OPEN');
         END IF;
        END;
     END IF;

      EXCEPTION
      WHEN no_data_found THEN
      x_ret_code := 'E';
      x_err_mesg :=  substr(sqlerrm,1,100);

END get_msc_assign_set;

PROCEDURE get_assignment_set (
			      x_dblink                   VARCHAR2,
			      x_assignment_set_id    OUT NoCopy NUMBER,
			      -- This we return what is on the server (MSC)
			      x_assignment_set_name  OUT NoCopy VARCHAR2,
			      x_plan_id              OUT NoCopy NUMBER,
			      x_plan_name            OUT NoCopy VARCHAR2,
			      x_sr_instance_id           NUMBER,
			      x_inst                     VARCHAR2,
			      x_ret_code             OUT NoCopy VARCHAR2,
			      x_err_mesg             OUT NoCopy VARCHAR2)
  IS
     sqlstring VARCHAR2(500);
     l_dblink  VARCHAR2(128) := NULL;
     l_assign_set_id  NUMBER;
     l_assign_name VARCHAR2(34);
     l_cursor  integer;
     rows_processed number;
     DBLINK_NOT_OPEN         EXCEPTION;
     PRAGMA  EXCEPTION_INIT(DBLINK_NOT_OPEN, -2081);
BEGIN
   x_ret_code := 'S';
   x_err_mesg := NULL;

   IF x_dblink IS NOT NULL THEN
      l_dblink := '@'||x_dblink;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug(' get_assignment_set dblink '||l_dblink);
      END IF;
   END IF;


   IF x_inst = order_sch_wb.apps THEN

      x_assignment_set_id := fnd_profile.value('MRP_ATP_ASSIGN_SET');

     if x_assignment_set_id is null then

       get_profile('MSC_ATP_ASSIGN_SET', x_assignment_set_id);

         sqlstring :=
         ' SELECT assignment_set_name '||
         ' FROM msc_assignment_sets' ||l_dblink||' '||
         ' WHERE assignment_set_id = :x_assignment_set_id '||
         ' AND sr_instance_id = :x_sr_instance_id';
        execute immediate sqlstring INTO l_assign_name
        using x_assignment_set_id, x_sr_instance_id;
        x_assignment_set_name := l_assign_name;

          IF l_dblink IS NOT NULL then
             l_cursor := dbms_sql.open_cursor;
             -- mark distributed transaction boundary
             -- will need to do a manual clean up (commit) of the distributed
             -- operation, else subsequent operations fail w/ ora-02080 (bug 2218999)
             commit;
             DBMS_SQL.PARSE ( l_cursor,
                     'alter session close database link ' ||l_dblink,
                     dbms_sql.native
                   );
            BEGIN
             rows_processed := dbms_sql.execute(l_cursor);
            EXCEPTION
            WHEN DBLINK_NOT_OPEN THEN
            IF PG_DEBUG in ('Y', 'C') THEN
             msc_sch_wb.atp_debug('get_assignment_set: ' || 'inside DBLINK_NOT_OPEN');
            END IF;
            END;
          end if;

         IF x_assignment_set_name IS NULL THEN
            -- could be using a assgn set in a diff instance.
            x_assignment_set_id := NULL;
         END IF;

      else

      IF PG_DEBUG in ('Y', 'C') THEN
         atp_debug('get_assignment_set: ' || ' apps x_assignment_set_id = '||x_assignment_set_id);
      END IF;
      SELECT mas.assignment_set_name
	INTO x_assignment_set_name
	FROM mrp_assignment_sets mas
	WHERE mas.assignment_set_id = x_assignment_set_id;

-- Bug # 2744339
  --   end if; --  check mrp assignment set for region level sourcing

      sqlstring :=
	' select assignment_set_id '||
	' from   msc_assignment_sets'||l_dblink||' '||
	' where  sr_instance_id = :x_sr_instance_id '||
	' and    sr_assignment_set_id = :x_assignment_set_id';
      execute immediate sqlstring INTO l_assign_set_id
	using x_sr_instance_id, x_assignment_set_id;
      x_assignment_set_id := l_assign_set_id;


   END IF;

      IF PG_DEBUG in ('Y', 'C') THEN
         atp_debug('get_assignment_set: ' || ' apps x_assignment_set_id = '||x_assignment_set_id);
      END IF;

    ELSE
      -- Server.

      x_assignment_set_id := fnd_profile.value('MSC_ATP_ASSIGN_SET');
      IF PG_DEBUG in ('Y', 'C') THEN
         atp_debug('get_assignment_set: ' || ' server x_assignment_set_id = '||x_assignment_set_id);
      END IF;
      IF x_assignment_set_id IS  NULL THEN

	 SELECT mas.assignment_set_id,mas.assignment_set_name
	   INTO x_assignment_set_id, x_assignment_set_name
	   FROM msc_apps_instances mai, msc_assignment_sets mas
	   WHERE mai.instance_id = x_sr_instance_id
	   AND mas.assignment_set_id = mai.assignment_set_id
	   AND mas.sr_instance_id = mai.instance_id;

	 IF PG_DEBUG in ('Y', 'C') THEN
	    atp_debug('get_assignment_set: ' || ' server from msc_apps...x_assignment_set_id = '||x_assignment_set_id);
	 END IF;
       ELSE
	 SELECT mas.assignment_set_name
	   INTO x_assignment_set_name
	   FROM msc_assignment_sets mas
	   WHERE mas.assignment_set_id = x_assignment_set_id
	   AND mas.sr_instance_id = x_sr_instance_id;

	 IF x_assignment_set_name IS NULL THEN
	    -- could be using a assgn set in a diff instance.
	    x_assignment_set_id := NULL;
	 END IF;
      END IF;
   END IF;

EXCEPTION
   WHEN no_data_found THEN
      x_ret_code := 'E';
      x_err_mesg :=  substr(sqlerrm,1,100);
END get_assignment_set;

PROCEDURE atp_debug(buf IN VARCHAR2) IS
BEGIN
   --IF order_sch_wb.mr_debug = 'Y' THEN
   IF order_sch_wb.mr_debug in ('Y','C') THEN
      IF order_sch_wb.file_or_terminal = 1 THEN
	 mrp_timing(buf);
       ELSE
--	 dbms_output.put_line(buf);
         null;
      END IF;
   END IF;
END atp_debug;

PROCEDURE MRP_TIMING(buf IN VARCHAR2)
IS
  fname utl_file.file_type ;
BEGIN
   IF (utl_file.is_open(fname)) THEN
      utl_file.put(fname, 'atp_session: '||order_sch_wb.debug_session_id||' '||buf);
      utl_file.fflush(fname);
      utl_file.fclose(fname);
    ELSE
      if order_sch_wb.file_dir is null then
        --select ltrim(rtrim(substr(value, instr(value,',',-1,1)+1)))
        --  into order_sch_wb.file_dir from v$parameter where name= 'utl_file_dir';
        /*bug 3374136 changes start*/
       select ltrim(rtrim(value)) into order_sch_wb.file_dir from
       (select value from v$parameter2  where name='utl_file_dir' order by rownum desc)
       where rownum <2;
      /*bug 3374136 changes end*/
      end if;
 -- dbms_output.put_line('dir '||order_sch_wb.file_dir||order_sch_wb.debug_session_id);

      fname := utl_file.fopen(order_sch_wb.file_dir,'session-'||order_sch_wb.debug_session_id,'a');
      utl_file.put(fname, buf);
      utl_file.fflush(fname);
      utl_file.fclose(fname);
   END IF;
   return;
EXCEPTION
   WHEN OTHERS THEN
--      dbms_output.put_line('Exception in mrp_timing '||Sqlerrm);
      return;
END MRP_TIMING;


PROCEDURE get_period_atp_strings(
 				 p_is_allocated		BOOLEAN,
				 p_session_id		NUMBER,
                                 p_old_session_id	number,
                                 p_dmd_flag		number,
				 p_end_pegging_id	number,
				 p_pegging_id           NUMBER,
				 p_organization_id      NUMBER,
				 p_sr_instance_id       NUMBER,
				 p_inst                 VARCHAR2,
				 p_supply_str    OUT    NoCopy VARCHAR2,
				 p_demand_str    OUT    NoCopy VARCHAR2,
				 p_bkd_demand_str    OUT    NoCopy VARCHAR2,
				 p_net_atp_str   OUT    NoCopy VARCHAR2,
				 p_cum_atp_str   OUT    NoCopy VARCHAR2,
				 p_row_hdr_str   OUT    NoCopy VARCHAR2,
				 p_date_str      OUT    NoCopy VARCHAR2,
				 p_week_str      OUT    NoCopy VARCHAR2,
				 p_period_str    OUT    NoCopy VARCHAR2
				 ) is

v_inv_item		varchar2(40);
v_org_code		varchar2(7);
v_resource_code		varchar2(10);
--p_inv_item		varchar2(40);
--p_org_code		varchar2(7);
l_pivot_hdr             VARCHAR2(400); --bug 2246200
p_resource_code		varchar2(10);
v_total_supply_qty	number;
v_total_demand_qty	number;
v_week_start_date	date;
v_week_end_date		date;
v_period_start_date	date;
v_period_end_date	date;
v_wk_start_date		date;
v_pr_start_date		date;
v_period_qty		number;
v_cumulative_qty	number;
l_old_cum		number := 0;

rec_cnt			number;
day_gap			number;

x_atp_period_string 	order_sch_wb.atp_period_string_typ;

-- The week and period is calculated based on the source org of the line.
-- We may need to do it for the org in which that pegging node is
cursor wk_cur is select b.week_start_date
		from mtl_parameters p, bom_cal_week_start_dates b
		where p.calendar_exception_set_id = b.exception_set_id
		and p.calendar_code = b.calendar_code
		and p.organization_id = p_organization_id
		and b.week_start_date > v_week_start_date
		and b.week_start_date <= v_week_end_date;

cursor pr_cur is select b.period_start_date
		from mtl_parameters p, bom_period_start_dates b
		where p.calendar_exception_set_id = b.exception_set_id
		and p.calendar_code = b.calendar_code
		and p.organization_id = p_organization_id
		and b.period_start_date > v_period_start_date
		and b.period_start_date <= v_period_end_date;

cursor msc_wk_cur is
   select b.week_start_date
     from msc_trading_partners p, msc_cal_week_start_dates b
     where p.calendar_exception_set_id = b.exception_set_id
     AND p.sr_instance_id = p_sr_instance_id
     AND b.sr_instance_id = p.sr_instance_id
     and p.calendar_code = b.calendar_code
     and p.sr_tp_id = p_organization_id
     AND p.partner_type = 3
     and b.week_start_date > v_week_start_date
     and b.week_start_date <= v_week_end_date;

cursor msc_pr_cur is
   select b.period_start_date
     from msc_trading_partners p, MSC_period_START_DATES b
     where p.calendar_exception_set_id = b.exception_set_id
     AND p.sr_instance_id = p_sr_instance_id
     AND b.sr_instance_id = p.sr_instance_id
     and p.calendar_code = b.calendar_code
     and p.sr_tp_id = p_organization_id
     AND p.partner_type = 3
     and b.period_start_date > v_period_start_date
     and b.period_start_date <= v_period_end_date;

cursor get_item_name is
      SELECT DISTINCT
        inventory_item_name||order_sch_wb.delim||owb_tree.lookups(5)   -- 'Item'
        ||order_sch_wb.delim||source_organization_code
        FROM mrp_atp_schedule_temp
        WHERE end_pegging_id = p_end_pegging_id;

BEGIN

   p_row_hdr_str	  := NULL;
   p_date_str		  := 'CH';
   p_week_str		  := 'CH';
   p_period_str		  := 'CH';
   p_net_atp_str	  := NULL;
   p_cum_atp_str	  := NULL;
   p_bkd_demand_str	  := NULL;


   msc_owb_tree.get_lookups;

   IF NOT p_is_allocated THEN

   IF p_pegging_id IS NOT NULL THEN
      SELECT Decode(department_id, NULL,
		    Decode(supplier_id, NULL,
			   inventory_item_name||order_sch_wb.delim||owb_tree.lookups(5)||order_sch_wb.delim||organization_code,
			   -- 'Item'
			   supplier_name||order_sch_wb.delim||owb_tree.lookups(17)||order_sch_wb.delim||supplier_site_name),
		    department_code||order_sch_wb.delim||Decode(resource_code, NULL, owb_tree.lookups(18),owb_tree.lookups(6))||order_sch_wb.delim||Decode(resource_code, NULL, '   ', resource_code))
		    -- blank above is so that pivot table will get some value to display
		    -- for line. otherwise following values shift left.
	INTO l_pivot_hdr
	FROM mrp_atp_details_temp
	WHERE pegging_id = p_pegging_id
	AND record_type = 3;
   END IF;

   IF l_pivot_hdr IS NULL THEN
      -- It will be null if pegging_id is not specified or if it is specified
      -- and it is an item.

         open  get_item_name;
         fetch get_item_name into l_pivot_hdr;
         close get_item_name;

   END IF;

   select
     Nvl(total_supply_quantity,0),
     Nvl(total_demand_quantity,0),
     period_start_date,
     Nvl(period_end_date,period_start_date),
     -- hack to avoid NULL
     Nvl(period_quantity,0),
     Nvl(cumulative_quantity,0),
     Nvl(total_bucketed_demand_quantity,0)
     bulk collect INTO
     x_atp_period_string.Total_Supply_Quantity,
     x_atp_period_string.Total_Demand_Quantity,
     x_atp_period_string.Period_Start_Date,
     x_atp_period_string.Period_End_Date,
     x_atp_period_string.Period_Quantity,
     x_atp_period_string.Cumulative_Quantity,
     x_atp_period_string.Bucketed_Quantity
     FROM MRP_ATP_DETAILS_TEMP
     WHERE
     record_type = 1
     AND (( p_pegging_id IS NULL and end_pegging_id  = p_end_pegging_id)
	  OR pegging_id = p_pegging_id)
     order by period_start_date;

     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('get_period_atp_strings: ' || ' count '||x_atp_period_string.total_supply_quantity.COUNT);
     END IF;


  ELSE   -- if allocated

   if p_dmd_flag = 0 then
   select
     Nvl(a.total_supply_quantity,0),
     Nvl(a.total_demand_quantity,0),
     b.period_start_date,
     Nvl(b.period_end_date,b.period_start_date),
     -- hack to avoid NULL
     Nvl(a.period_quantity,0),
     Nvl(a.cumulative_quantity,0),
     Nvl(a.total_bucketed_demand_quantity,0)
     bulk collect INTO
     x_atp_period_string.Total_Supply_Quantity,
     x_atp_period_string.Total_Demand_Quantity,
     x_atp_period_string.Period_Start_Date,
     x_atp_period_string.Period_End_Date,
     x_atp_period_string.Period_Quantity,
     x_atp_period_string.Cumulative_Quantity,
     x_atp_period_string.Bucketed_Quantity
     FROM MRP_ATP_DETAILS_TEMP a,
          MRP_ATP_DETAILS_TEMP b
     WHERE
     a.record_type (+) = 1
     and a.session_id (+) = p_session_id
     and b.session_id = p_old_session_id
     and b.record_type = 1
     and a.period_start_date(+) = b.period_start_date
     order by b.period_start_date;
   else
    select
     Nvl(total_supply_quantity,0),
     Nvl(total_demand_quantity,0),
     period_start_date,
     Nvl(period_end_date,period_start_date),
     -- hack to avoid NULL
     Nvl(period_quantity,0),
     Nvl(cumulative_quantity,0),
     Nvl(total_bucketed_demand_quantity,0)
     bulk collect INTO
     x_atp_period_string.Total_Supply_Quantity,
     x_atp_period_string.Total_Demand_Quantity,
     x_atp_period_string.Period_Start_Date,
     x_atp_period_string.Period_End_Date,
     x_atp_period_string.Period_Quantity,
     x_atp_period_string.Cumulative_Quantity,
     x_atp_period_string.Bucketed_Quantity
     FROM MRP_ATP_DETAILS_TEMP
     WHERE
     record_type = 1
     and session_id = p_session_id
     order by period_start_date;
   end if;


     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug('get_period_atp_strings: ' || ' count '||x_atp_period_string.total_supply_quantity.COUNT);
     END IF;

  END IF; -- if not allocated

   IF x_atp_period_string.total_supply_quantity.COUNT > 0 THEN

      p_row_hdr_str	:= 'RowHeader';
      p_date_str        := p_date_str||order_sch_wb.delim||'Dy';
      p_week_str        := p_week_str||order_sch_wb.delim||'Wk';
      p_period_str      := p_period_str||order_sch_wb.delim||'Pr';
      p_net_atp_str	:= 'GD'||order_sch_wb.delim||'New-End';
      p_cum_atp_str	:= 'GD'||order_sch_wb.delim||'New-End';
      p_supply_str	:= 'GD'||order_sch_wb.delim||'New-End';
      p_demand_str	:= 'GD'||order_sch_wb.delim||'New-End';
      p_bkd_demand_str	:= 'GD'||order_sch_wb.delim||'New-End';

      v_week_start_date := x_atp_period_string.period_start_date(1);
      v_period_start_date := x_atp_period_string.period_start_date(1);
      v_week_end_date := x_atp_period_string.period_end_date(x_atp_period_string.period_end_date.count);
      v_period_end_date := v_week_end_date;
      IF order_sch_wb.mr_debug = 'Y' THEN
	 IF PG_DEBUG in ('Y', 'C') THEN
	    msc_sch_wb.atp_debug('get_period_atp_strings: ' || '$$$ '||v_week_start_date||' '||v_week_end_date||' '||v_period_start_date||' '||v_period_end_date);
	 END IF;
      END IF;


      FOR j IN 1..x_atp_period_string.total_supply_quantity.COUNT loop
	 p_supply_str := p_supply_str||order_sch_wb.delim||Rtrim(To_char(x_atp_period_string.total_supply_quantity(j),order_sch_wb.mrn_canonical_num),'.');
	 p_demand_str := p_demand_str||order_sch_wb.delim||Rtrim(To_char(x_atp_period_string.total_demand_quantity(j),order_sch_wb.mrn_canonical_num),'.');
	 p_bkd_demand_str := p_bkd_demand_str||order_sch_wb.delim||Rtrim(To_char(x_atp_period_string.bucketed_quantity(j),order_sch_wb.mrn_canonical_num),'.');
	 p_net_atp_str := p_net_atp_str||order_sch_wb.delim||Rtrim(To_char(x_atp_period_string.period_quantity(j),order_sch_wb.mrn_canonical_num),'.');

        if (p_dmd_flag = 0 ) AND (x_atp_period_string.cumulative_quantity(j) = 0) THEN
         p_cum_atp_str := p_cum_atp_str||order_sch_wb.delim||Rtrim(To_char(l_old_cum,order_sch_wb.mrn_canonical_num),'.');
        else
	 p_cum_atp_str := p_cum_atp_str||order_sch_wb.delim||Rtrim(To_char(x_atp_period_string.cumulative_quantity(j),order_sch_wb.mrn_canonical_num),'.');
	 l_old_cum := x_atp_period_string.cumulative_quantity(j);
        end if;

         p_date_str := p_date_str||order_sch_wb.delim||To_char(x_atp_period_string.period_start_date(j),order_sch_wb.MRD_CANONICAL_DATE);
	 --   dbms_output.put_line(x_atp_period_string.period_start_date(j));
	 IF  x_atp_period_string.period_start_date(j) <>
	   x_atp_period_string.period_end_date(j) THEN
	    day_gap := x_atp_period_string.period_end_date(j) -
	      x_atp_period_string.period_start_date(j);
	    for i in 1..day_gap loop
	       p_supply_str := p_supply_str||order_sch_wb.delim||0;
	       p_demand_str := p_demand_str||order_sch_wb.delim||0;
	       p_bkd_demand_str := p_bkd_demand_str||order_sch_wb.delim||0;
	       p_net_atp_str := p_net_atp_str||order_sch_wb.delim||0;
	       p_cum_atp_str := p_cum_atp_str||order_sch_wb.delim||Rtrim(To_char(l_old_cum,order_sch_wb.mrn_canonical_num),'.');
	       x_atp_period_string.period_start_date(j) := x_atp_period_string.period_start_date(j) + 1;
	       p_date_str := p_date_str||order_sch_wb.delim||To_char(x_atp_period_string.period_start_date(j),order_sch_wb.MRD_CANONICAL_DATE);
	       --			    dbms_output.put_line('!! '||x_atp_period_string.period_start_date(j));
	    END LOOP;
	 END IF;
      END LOOP;

      p_week_str := p_week_str||order_sch_wb.delim||To_char(v_week_start_date,order_sch_wb.mrd_canonical_date);
      IF p_inst = 'SERVER' THEN
	 open msc_wk_cur;
	 LOOP
	    fetch msc_wk_cur into v_wk_start_date;
	    EXIT WHEN msc_wk_cur%NOTFOUND;
	    p_week_str := p_week_str||order_sch_wb.delim||To_char(v_wk_start_date,order_sch_wb.MRD_CANONICAL_DATE);
	 end loop;
	 close msc_wk_cur;
       ELSE
	       open wk_cur;
	       LOOP
		  fetch wk_cur into v_wk_start_date;
		  EXIT WHEN wk_cur%NOTFOUND;
		  p_week_str := p_week_str||order_sch_wb.delim||To_char(v_wk_start_date,order_sch_wb.MRD_CANONICAL_DATE);
	       end loop;
	       close wk_cur;
      END IF;


      p_period_str := p_period_str||order_sch_wb.delim||To_char(v_period_start_date,order_sch_wb.MRD_CANONICAL_DATE);
      IF p_inst = 'SERVER' THEN
	 open msc_pr_cur;
	 loop
	    fetch msc_pr_cur into v_pr_start_date;
	    EXIT WHEN msc_pr_cur%NOTFOUND;
	    p_period_str := p_period_str||order_sch_wb.delim||To_char(v_pr_start_date,order_sch_wb.MRD_CANONICAL_DATE);
	 end loop;
	 close msc_pr_cur;
       ELSE
	       open pr_cur;
	       loop
		  fetch pr_cur into v_pr_start_date;
		  EXIT WHEN pr_cur%NOTFOUND;
		  p_period_str := p_period_str||order_sch_wb.delim||To_char(v_pr_start_date,order_sch_wb.MRD_CANONICAL_DATE);
	       end loop;
	       close pr_cur;
      END IF;
      p_date_str := p_date_str||order_sch_wb.delim||'End';
      p_week_str := p_week_str||order_sch_wb.delim||'End';
      p_period_str := p_period_str||order_sch_wb.delim||'End';

      IF NOT p_is_allocated THEN
       p_row_hdr_str := p_row_hdr_str||order_sch_wb.delim||l_pivot_hdr
	||order_sch_wb.delim||owb_tree.lookups(13)||order_sch_wb.delim||
	owb_tree.lookups(14)||order_sch_wb.delim||owb_tree.lookups(27)||order_sch_wb.delim||owb_tree.lookups(15)||order_sch_wb.delim||
	owb_tree.lookups(16)||order_sch_wb.delim||'End';
      ELSE
        IF p_pegging_id  is null THEN
           p_row_hdr_str:=  owb_tree.lookups(6)||order_sch_wb.delim;
        ELSE
           p_row_hdr_str:=  owb_tree.lookups(5)||order_sch_wb.delim;
        END IF;
        p_row_hdr_str := p_row_hdr_str||
        owb_tree.lookups(13)||order_sch_wb.delim||
	owb_tree.lookups(14)||order_sch_wb.delim||owb_tree.lookups(27)||order_sch_wb.delim||
        owb_tree.lookups(15)||order_sch_wb.delim||
	owb_tree.lookups(16)||order_sch_wb.delim||'End';
      END IF;

      p_supply_str := p_supply_str||order_sch_wb.delim||'End';
      p_demand_str := p_demand_str||order_sch_wb.delim||'End';
      p_bkd_demand_str := p_bkd_demand_str||order_sch_wb.delim||'End';
      p_net_atp_str := p_net_atp_str||order_sch_wb.delim||'End';
      p_cum_atp_str := p_cum_atp_str||order_sch_wb.delim||'End';
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('get_period_atp_strings: ' || ' excp in get_period_strings '||substr(Sqlerrm, 1, 100));
      END IF;

      IF wk_cur%isopen THEN
	 CLOSE wk_cur;
      END IF;
      IF msc_wk_cur%isopen THEN
	 CLOSE msc_wk_cur;
      END IF;
      IF pr_cur%isopen THEN
	 CLOSE pr_cur;
      END IF;
      IF msc_pr_cur%isopen THEN
	 CLOSE msc_pr_cur;
      END IF;

END get_period_atp_strings;

PROCEDURE cleanup_data (p_session_id in number) IS
begin
 delete from mrp_atp_schedule_temp
 where status_flag = 1
 and session_id = p_session_id;

 update mrp_atp_schedule_temp
 set  status_flag = 1
 where session_id = p_session_id
 and status_flag = 2;
end cleanup_data;


PROCEDURE calc_exceptions(
			  p_session_id         IN    NUMBER,
			  x_return_status      OUT   NoCopy VARCHAR2,
			  x_msg_data           OUT   NoCopy VARCHAR2,
			  x_msg_count          OUT   NoCopy NUMBER
			  )
  IS
     -- PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   x_return_status := 'S';

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug(' Inside calc_exceptions '||p_session_id);
   END IF;

   UPDATE mrp_atp_schedule_temp mast
     set
     mast.exception1 = Decode(error_code,53,1,52,1,100,1,0),
     mast.exception2 = Decode(error_code,0,
			      Decode(Sign(trunc(mast.scheduled_ship_date) -
					 Nvl(trunc(mast.old_line_schedule_date),trunc(mast.scheduled_ship_date)))
				     ,1,1,0),
			      0), -- later than old sched date
     mast.exception3 = Decode(error_code,0,
			      Decode(Sign(trunc(mast.scheduled_ship_date) +
                                          Decode(trunc(mast.requested_ship_date),NULL,Nvl(mast.delivery_lead_time,0),0)
					  -trunc(mast.promise_date)),1,1,0), 0),
     -- later than promise date. Consider sched ship/arrival date depending on whether
     -- requested date was ship/arrival.
     mast.exception4= Decode(error_code,0,
			     Decode(Sign(trunc(mast.SCHEDULED_SHIP_DATE) + Decode(trunc(mast.requested_ship_date),NULL,
                                                                         Nvl(mast.delivery_lead_time,0),0)
					 - NVL(trunc(mast.requested_ship_date),trunc(mast.requested_arrival_date))),1,1,0),
			     0), -- later than request date
     mast.exception5 = 0, -- insufficient margin
     mast.exception6 = Decode(error_code,0,
			      Decode(substr(mast.SOURCE_ORGANIZATION_CODE, instr(mast.SOURCE_ORGANIZATION_CODE,':')+1,3),
				     Nvl(mast.OLD_SOURCE_ORGANIZATION_CODE,
					 substr(mast.SOURCE_ORGANIZATION_CODE, instr(mast.SOURCE_ORGANIZATION_CODE,':')+1,3)),0,1),
			      0),
     mast.exception7 = Decode(error_code,0,0,52,0,53,0,100,0,NULL,0,1),
     mast.exception8 = 0,
     mast.exception9 = 0,
     mast.exception10 = 0,
     mast.exception11 = 0,
     mast.exception12 = 0,
     mast.exception13 = 0,
     mast.exception14 = 0,
     mast.exception15 = 0
     WHERE session_id = p_session_id
     AND scenario_id = 1
     AND status_flag =  2;

     IF PG_DEBUG in ('Y', 'C') THEN
        msc_sch_wb.atp_debug(' After update in  calc_exceptions ');
     END IF;

      COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         atp_debug('calc_exceptions: ' || ' exception in calc_excep  - '||substr(sqlerrm,1,100));
      END IF;
      x_return_status := 'E';

END calc_exceptions;

FUNCTION get_supply_demand_source_name
  (
   organization_id           IN NUMBER,
   supply_demand_source_type IN NUMBER,
   supply_demand_source_id   IN NUMBER
   ) RETURN VARCHAR2 IS
      supply_demand_source_name VARCHAR2(200);
BEGIN
   if supply_demand_source_type = 1 then
      SELECT SEGMENT1
	INTO supply_demand_source_name
	FROM PO_HEADERS
	WHERE PO_HEADER_ID=supply_demand_source_id;
    elsif supply_demand_source_type = 2 then
      SELECT CONCATENATED_SEGMENTS
	INTO supply_demand_source_name
	FROM mtl_sales_orders_kfv
	WHERE SALES_ORDER_ID = supply_demand_source_id;
    elsif supply_demand_source_type = 3 THEN
      SELECT CONCATENATED_SEGMENTS
	INTO supply_demand_source_name
	FROM gl_code_combinations_kfv
	where CHART_OF_ACCOUNTS_ID = order_sch_wb.PARAMETER_CHART_OF_ACCOUNTS_ID
	and CODE_COMBINATION_ID = supply_demand_source_id;
    elsif (supply_demand_source_type = 4) or (supply_demand_source_type = 5) then
      SELECT WIP_ENTITY_NAME
	INTO supply_demand_source_name
	FROM WIP_ENTITIES
	WHERE WIP_ENTITY_ID=supply_demand_source_id;
    elsif supply_demand_source_type = 6 then
      SELECT CONCATENATED_SEGMENTS
	INTO supply_demand_source_name
	FROM mtl_generic_dispositions_kfv
	WHERE ORGANIZATION_ID = ORGANIZATION_ID
	AND DISPOSITION_ID = supply_demand_source_id;
    elsif supply_demand_source_type = 8 then
      SELECT SHIPMENT_NUM
	INTO supply_demand_source_name
	FROM RCV_SHIPMENT_HEADERS
	WHERE SHIPMENT_HEADER_ID=supply_demand_source_id;
    elsif supply_demand_source_type = 9 THEN
      SELECT SCHEDULE_DESIGNATOR
	INTO supply_demand_source_name
	FROM MRP_SCHEDULE_DATES
	WHERE MPS_TRANSACTION_ID=supply_demand_source_id
	AND SCHEDULE_LEVEL = 2
	AND SUPPLY_DEMAND_TYPE = 2;
    elsif supply_demand_source_type = 10 then
      SELECT SEGMENT1
	INTO supply_demand_source_name
	FROM PO_REQUISITION_HEADERS
	WHERE REQUISITION_HEADER_ID=supply_demand_source_id;
    elsif supply_demand_source_type = 11 THEN
      NULL;
      -- If it is resource supply, there is no identifier
      -- :SD_DETAIL.sd_type := :PARAMETER.resource_supply;
    elsif supply_demand_source_type is not null THEN
      supply_demand_source_name := order_sch_wb.form_field_C_COLUMN1;
   end if;

   RETURN supply_demand_source_name;

END get_supply_demand_source_name;

PROCEDURE pipe_utility(
		       p_session_id         IN       NUMBER,
		       p_command            IN       VARCHAR2,
		       p_message            IN OUT   NoCopy VARCHAR2,
		       p_message_count      OUT      NoCopy NUMBER,   -- Right now just 0 or 1
		       x_return_status      OUT      NoCopy VARCHAR2,
		       x_msg_data           OUT      NoCopy VARCHAR2,
		       x_msg_count          OUT      NoCopy NUMBER
		       )
  IS
     ret        NUMBER;
     empty_pipe EXCEPTION;
     PRAGMA     EXCEPTION_INIT (EMPTY_PIPE, -6556);
BEGIN
   x_return_status := 'S';
   x_msg_data := NULL;
   x_msg_count := NULL;

   IF p_command = 'CREATE' THEN
      ret := DBMS_PIPE.CREATE_PIPE
	(pipename => 'session-'||p_session_id,
	 maxpipesize => 8000, --7419485
	 private => FALSE);
      IF ret <> 0 THEN
	 IF PG_DEBUG in ('Y', 'C') THEN
	    atp_debug('pipe_utility: ' || ' Unable to open pipe ');
	 END IF;
	 x_return_status := 'E';
	 RETURN;
      END IF;
      dbms_pipe.reset_buffer;  -- good to reset it to clear things
    ELSIF p_command = 'REMOVE' THEN
      ret := dbms_pipe.remove_pipe('session-'||p_session_id);
      IF ret <> 0 THEN
	 IF PG_DEBUG in ('Y', 'C') THEN
	    atp_debug('pipe_utility: ' || ' Unable to remove pipe ');
	 END IF;
	 x_return_status := 'E';
	 RETURN;
      END IF;
    ELSIF p_command = 'PURGE' THEN
      dbms_pipe.purge('session-'||p_session_id);

        ELSIF p_command = 'OMERROR' THEN
    -- we need to create a new independent pipe for this

        ret := DBMS_PIPE.CREATE_PIPE
        (pipename => 'OMERROR-'||p_session_id,
         maxpipesize => 5000,
         private => FALSE);
      IF ret <> 0 THEN
         IF PG_DEBUG in ('Y', 'C') THEN
            atp_debug('pipe_utility: FOR OMERROR' || ' Unable to open pipe ');
         END IF;
         x_return_status := 'E';
         RETURN;
      END IF;
      dbms_pipe.reset_buffer;
      dbms_pipe.pack_message(p_message);
      ret := dbms_pipe.send_message('OMERROR-'||p_session_id, 0);

    ELSIF p_command = 'CHECK_OM' THEN
      p_message := NULL;
      ret := dbms_pipe.receive_message('OMERROR-'||p_session_id, 0);
      ret := dbms_pipe.next_item_type;
      dbms_pipe.unpack_message(p_message);
      dbms_pipe.purge('OMERROR-'||p_session_id);

    ELSIF p_command = 'SEND' THEN
      --msc_sch_wb.atp_debug(' b4 sending mesg '||p_message);
      p_message := Nvl(p_message,fnd_date.date_to_canonical(Sysdate));

      dbms_pipe.pack_message(p_message);
      ret := dbms_pipe.send_message('session-'||p_session_id, 0);   -- 0 implies no block
      IF ret <> 0 THEN
	 IF PG_DEBUG in ('Y', 'C') THEN
         null;
	 --   msc_sch_wb.atp_debug('pipe_utility: ' || ' ERROR/Warning : ret code when sending message '||ret);
	 END IF;
      END IF;
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('pipe_utility: ' || ' sent mesg '||p_message);
      END IF;
    ELSIF p_command = 'RECEIVE' THEN
         p_message := NULL;
	 ret := dbms_pipe.receive_message('session-'||p_session_id, 0);
	 IF ret <> 0 THEN
	    IF PG_DEBUG in ('Y', 'C') THEN
                null;
	      -- msc_sch_wb.atp_debug('pipe_utility: ' || ' ERROR/Warning : ret code when recv message '||ret);
	    END IF;
	 END IF;

	 -- When 'END' is sent then it means that ATP is done
	 p_message_count := 0;
	 ret := dbms_pipe.next_item_type;
	 IF ret <> 0 THEN
	    dbms_pipe.unpack_message(p_message);
	    p_message_count := p_message_count + 1;
	 END IF;
   END IF;

EXCEPTION
   WHEN EMPTY_PIPE THEN
      NULL;
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         atp_debug(' Exception in pipe_utility '||p_command||Substr(Sqlerrm,1,100));
      END IF;
      x_return_status := 'E';
      x_msg_data := Substr(Sqlerrm,1,100);
END pipe_utility;

PROCEDURE set_session_id(p_session_id   IN NUMBER)
  IS
BEGIN
   order_sch_wb.mr_debug := NVL(fnd_profile.value('MSC_ATP_DEBUG'),'N');
   order_sch_wb.debug_session_id := p_session_id;
   MSC_ATP_PVT.G_SESSION_ID := p_session_id;

END set_session_id;

PROCEDURE  extend_other_cols(x_other_cols IN OUT NoCopy order_sch_wb.other_cols_typ, amount NUMBER)
  IS
BEGIN
   x_other_cols.row_index.extend(amount);
   x_other_cols.org_code.extend(amount);
   x_other_cols.ship_method_text.extend(amount);
   x_other_cols.vendor_name.extend(amount);
   x_other_cols.vendor_site_name.extend(amount);
   x_other_cols.sr_supplier_id.extend(amount);
   x_other_cols.sr_supplier_site_id.extend(amount);
END extend_other_cols;

PROCEDURE commit_db IS
BEGIN
   COMMIT;
END commit_db;

PROCEDURE get_master_org(p_master_org_id OUT NoCopy NUMBER)
  IS
     l_sql     VARCHAR2(500);
     l_org_id  NUMBER;
BEGIN
/* removed oe api since it was using autonomous call.

   l_sql := 'begin :l_master_org_id := oe_sys_parameters.value(''MASTER_ORGANIZATION_ID''); end; ';
   execute immediate l_sql using OUT l_org_id;
  */

p_master_org_id := null;

    SELECT
           master_organization_id
           INTO  p_master_org_id
    FROM   oe_system_parameters_all
    WHERE NVL(ORG_ID,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV
             ('CLIENT_INFO'),1 ,1),' ', NULL,
              SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
              NVL(l_org_id, NVL(TO_NUMBER(DECODE(SUBSTRB
                 (USERENV('CLIENT_INFO'),1,1),' ', NULL,
                  SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99));

   EXCEPTION

   WHEN NO_DATA_FOUND THEN

   p_master_org_id := null;

    WHEN OTHERS THEN

    p_master_org_id := null;

END get_master_org;

PROCEDURE get_profile(profile_name VARCHAR2, profile_value OUT NoCopy NUMBER)
  IS
     l_atp_link VARCHAR2(255);
     sqlstmt    VARCHAR2(255) := 'begin :profile_value := fnd_profile.value';
     -- atp_cursor  integer;
     -- atp_rows_processed number;
     l_cursor  integer;
     rows_processed number;
     DBLINK_NOT_OPEN         EXCEPTION;
     PRAGMA  EXCEPTION_INIT(DBLINK_NOT_OPEN, -2081);
     l_return_status varchar2(60);
     l_instance_id number;
BEGIN

--   l_atp_link := fnd_profile.value('MRP_ATP_DATABASE_LINK');
   MSC_SATP_FUNC.get_dblink_profile(l_atp_link, l_instance_id, l_return_status);
   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug(' get_profile '||l_atp_link);
   END IF;
   IF l_atp_link IS NOT NULL THEN
      sqlstmt := sqlstmt||'@'||l_atp_link;
   END IF;
   sqlstmt := sqlstmt||'('''||profile_name||'''); END; ';

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug(' get_profile '||sqlstmt);
   END IF;
   execute immediate sqlstmt using OUT profile_value;

IF l_atp_link IS NOT NULL then
    -- mark distributed transaction boundary
    -- will need to do a manual clean up (commit) of the distributed
    -- operation, else subsequent operations fail w/ ora-02080 (bug 2218999)
    commit;
    l_cursor := dbms_sql.open_cursor;
    DBMS_SQL.PARSE ( l_cursor,
                     'alter session close database link ' ||l_atp_link,
                     dbms_sql.native
                   );
    BEGIN
     rows_processed := dbms_sql.execute(l_cursor);
    EXCEPTION
      WHEN DBLINK_NOT_OPEN THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('get_profile: ' || 'inside DBLINK_NOT_OPEN');
       END IF;
    END;
end if;

   IF PG_DEBUG in ('Y', 'C') THEN
      msc_sch_wb.atp_debug(' get_profile '||profile_value);
   END IF;
END get_profile;

PROCEDURE get_session_id(p_db_link in varchar2 default NULL,p_session_id out NoCopy varchar2 )  IS
  sql_stmt varchar2(200);
  l_null_db_link varchar2(100) := NULL;
  l_db_link varchar2(100) ;
  l_cursor  integer;
  rows_processed number;
  DBLINK_NOT_OPEN         EXCEPTION;
  PRAGMA  EXCEPTION_INIT(DBLINK_NOT_OPEN, -2081);
BEGIN
  if ( p_db_link is NULL) then
    select mrp_atp_schedule_temp_s.nextval
    into p_session_id
    from dual;
  else
    l_db_link := '@'||p_db_link;
    --sql_stmt := ' select mrp_atp_schedule_temp_s.nextval from dual@'||p_db_link;
    sql_stmt := 'begin msc_sch_wb.get_session_id'||l_db_link||'(:l_null_db_link,:p_session_id); end;';
    EXECUTE IMMEDIATE sql_stmt using l_null_db_link, out p_session_id;

    l_cursor := dbms_sql.open_cursor;
    commit;
    DBMS_SQL.PARSE ( l_cursor, 'alter session close database link ' ||p_db_link, dbms_sql.native);
    BEGIN
     rows_processed := dbms_sql.execute(l_cursor);
    EXCEPTION
      WHEN DBLINK_NOT_OPEN THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          msc_sch_wb.atp_debug('get_session_id: ' || 'inside DBLINK_NOT_OPEN');
       END IF;
    END;

  end if;
END get_session_id;

PROCEDURE get_g_atp_error_code (x_atp_err_code OUT NoCopy NUMBER) IS
BEGIN
        x_atp_err_code := MSC_SCH_WB.G_ATP_ERROR_CODE ;
END get_g_atp_error_code;

PROCEDURE update_constraint_path(p_session_id     IN     NUMBER,
                                 p_return_error   IN OUT NoCopy VARCHAR2) IS
CURSOR  get_constr_peg_id IS
select  distinct end_pegging_id
from    mrp_atp_details_temp
where   session_id  = p_session_id
and     record_type = 3
and     constraint_type is not NULL;

sql_stmt  VARCHAR2(4000);
l_end_peg_id_list  VARCHAR2(3000):= '0';
l_end_peg_id       VARCHAR2(10):= '-1';

--bug 3751114
l_peg_record_type               NUMBER := 3;
l_constraint_path_flag          NUMBER := 1;

BEGIN

OPEN get_constr_peg_id;
 LOOP
     FETCH get_constr_peg_id INTO l_end_peg_id;
     EXIT WHEN get_constr_peg_id%NOTFOUND;
     l_end_peg_id_list := l_end_peg_id||' ,'||l_end_peg_id_list;
 END LOOP;
CLOSE get_constr_peg_id;

IF PG_DEBUG in ('Y', 'C') THEN
  msc_sch_wb.atp_debug('l_end_peg_id_list in update_constr ' ||
                                             l_end_peg_id_list);
END IF;

IF l_end_peg_id <> '-1' THEN

      sql_stmt := 'UPDATE mrp_atp_details_temp
                    set    constrained_path = ' || l_constraint_path_flag ||
                    ' where  record_type = ' || l_peg_record_type ||
                    ' and    session_id =  '||p_session_id||
                   ' and    pegging_id in
                       (select pegging_id
                        from   mrp_atp_details_temp
                        where  record_type = ' ||  l_peg_record_type ||
                        ' and    session_id ='||p_session_id||
                      ' start with session_id = '||p_session_id||
                      ' and   record_type = ' || l_peg_record_type ||
                      '  and   end_pegging_id in ('||l_end_peg_id_list||') ' ||
                      ' and   constraint_type is not null
                        connect by pegging_id = PRIOR parent_pegging_id
                                and record_type = ' || l_peg_record_type ||
                               ' and  session_id =  '||p_session_id||')';
EXECUTE IMMEDIATE sql_stmt;
commit;

END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Excp in update_constraint_path '||
                              Substr(Sqlerrm, 1,100));
         p_return_error := 'E';
      END IF;

END update_constraint_path ;

PROCEDURE get_ato_comp_details(p_session_id        IN      NUMBER,
                               p_child_ato_id      IN      NUMBER,
                               p_organization_id   IN      NUMBER,
                               x_days_late         IN OUT  NoCopy NUMBER,
                               x_error_code        IN OUT  NoCopy VARCHAR2) IS

CURSOR ato_details_with_org(p_inventory_item_id NUMBER,
                   p_session_id        NUMBER,
                   p_organization_id   NUMBER  ) IS
select
       trunc(mast.supply_demand_date - mast.required_date)
from   mrp_atp_details_temp mast
where  --mast.constraint_type is not NULL
    mast.session_id = p_session_id
and    mast.record_type = 3
and    mast.supply_demand_type = 2
and    mast.inventory_item_id  = p_inventory_item_id
and    mast.organization_id   = p_organization_id;

CURSOR ato_details_no_org( p_inventory_item_id NUMBER,
                           p_session_id NUMBER)
IS
select trunc(mast.supply_demand_date - mast.required_date) date_diff
from mrp_atp_details_temp mast
where  --mast.constrained_path is not NULL
    mast.session_id = p_session_id
and    mast.record_type = 3
and    mast.supply_demand_type = 2
and    mast.inventory_item_id  = p_inventory_item_id
order by date_diff DESC;



BEGIN
IF p_organization_id  is NOT NULL THEN
   OPEN  ato_details_with_org(p_child_ato_id,
                  p_session_id,
                  p_organization_id);
   FETCH ato_details_with_org INTO
                x_days_late;
   CLOSE ato_details_with_org;

ELSE
   OPEN  ato_details_no_org(p_child_ato_id,
                            p_session_id);
   FETCH ato_details_no_org INTO
                x_days_late;
   CLOSE ato_details_no_org;
END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF PG_DEBUG in ('Y', 'C') THEN
         msc_sch_wb.atp_debug('Excp in msc_sch_wb.get_ato_comp_details '||
                              Substr(Sqlerrm, 1,100));
      END IF;


END get_ato_comp_details;


END msc_sch_wb;

/
