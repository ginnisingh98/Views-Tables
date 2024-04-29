--------------------------------------------------------
--  DDL for Package Body MSC_DRP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_DRP_UTIL" AS
/* $Header: MSCDRPUB.pls 120.21.12010000.3 2009/02/26 19:16:57 eychen ship $ */
TYPE supply_undo_type IS RECORD (
transaction_id number,
sr_instance_id number,
orig_shipment_id number,
orig_firm_flag number,
orig_firm_qty number,
orig_firm_date date,
orig_ship_date date,
orig_dock_date date,
orig_lead_time number,
orig_ship_method varchar2(30),
shipment_id number,
firm_flag number,
firm_qty number,
firm_date date,
ship_date date,
dock_date date,
lead_time number,
ship_method varchar2(30));

TYPE supply_undo_rec IS TABLE OF supply_undo_type INDEX BY BINARY_INTEGER;
g_supply_undo_rec supply_undo_rec;


FUNCTION order_type_text(arg_lookup_type IN varchar2,
                        arg_lookup_code IN NUMBER,
                        arg_org_id IN NUMBER,
                        arg_source_org IN NUMBER,
                        arg_demand_source_type IN NUMBER default null) return varchar2 IS
   v_new_lookup_type varchar2(80);
   v_new_lookup_code NUMBER;
BEGIN
   if arg_lookup_code is null then
      return null;
   end if;

   v_new_lookup_type := arg_lookup_type;
   v_new_lookup_code := arg_lookup_code;

   if v_new_lookup_type = 'MRP_ORDER_TYPE' then
      if  v_new_lookup_code = 2 then -- purchase req
         if arg_source_org <> arg_org_id then
             v_new_lookup_code := 53; -- internal req
         end if;
      end if;
   elsif v_new_lookup_type = 'MSC_DEMAND_ORIGINATION' then
      if  v_new_lookup_code = 1 then  -- planned order demand
         if arg_source_org <> arg_org_id then
             v_new_lookup_code := 49; -- Request Shipments
         else
             v_new_lookup_code := 48; -- Unconstrained Kit Demand
         end if;
      elsif v_new_lookup_code = 30 then -- Sales Order
         if arg_demand_source_type = 8 then
            v_new_lookup_code := 54; -- Internal Sales Orders
         end if;
      end if;
   end if;

   return msc_get_name.lookup_meaning(v_new_lookup_type, v_new_lookup_code);

END order_type_text;

FUNCTION cost_under_util(p_plan_id number,
                         p_weight_cap number, p_volume_cap number,
                         p_weight number, p_volume number,
                         p_from_org_id number, p_from_inst_id number,
                         p_to_org_id number, p_to_inst_id number,
                         p_ship_method varchar2) RETURN number IS
  CURSOR cost_c is
    select COST_PER_WEIGHT_UNIT, COST_PER_VOLUME_UNIT,
           SHIPMENT_WEIGHT_UOM, SHIPMENT_VOLUME_UOM,
           WEIGHT_UOM, VOLUME_UOM
      from msc_interorg_ship_methods
     where from_organization_id = p_from_org_id
       and sr_instance_id = p_from_inst_id
       and to_organization_id = p_to_org_id
       and sr_instance_id2 = p_to_inst_id
       and ship_method = p_ship_method
       and plan_id = p_plan_id;

  v_weight_cost number;
  v_volume_cost number;
  v_shp_wt_uom varchar2(3);
  v_shp_vl_uom varchar2(3);
  v_wt_uom varchar2(3);
  v_vl_uom varchar2(3);
BEGIN
  IF (p_weight_cap > 0 and p_weight_cap <= p_weight) or
     (p_volume_cap > 0 and p_volume_cap <= p_volume) then
  -- over_utilize, return null value
     return null;
  END IF;
  IF p_weight_cap > p_weight or
     p_volume_cap > p_volume then

     OPEN  cost_c;
     FETCH cost_c INTO v_weight_cost,v_volume_cost,
                       v_shp_wt_uom, v_shp_vl_uom,
                       v_wt_uom, v_vl_uom;
     CLOSE cost_c;

--dbms_output.put_line(v_weight_cost||','||v_volume_cost||','||v_shp_wt_uom||','||v_wt_uom);
  -- only show cost when ship_wt_uom = wt_uom
     IF nvl(v_shp_wt_uom,v_wt_uom) = nvl(v_wt_uom,v_shp_wt_uom) and
        p_weight_cap > p_weight and
        v_weight_cost is not null then
        return (p_weight_cap - p_weight) * v_weight_cost;
     ELSIF nvl(v_shp_vl_uom,v_vl_uom) = nvl(v_vl_uom,v_shp_vl_uom) and
           p_volume_cap > p_volume and
           v_volume_cost is not null then
        return (p_volume_cap - p_volume) * v_volume_cost;
     ELSE
        return null;
     END IF;
  END IF;

  return null;

END cost_under_util;

FUNCTION material_avail_date(p_plan_id number, p_supply_id number)
                                                         RETURN date IS
  CURSOR date_c IS
    select ms.new_schedule_date
      from msc_supplies ms,
           msc_single_lvl_peg mslp
     where mslp.plan_id = p_plan_id
       and mslp.pegging_type = 1 -- supply to parent supply
       and mslp.parent_id = p_supply_id
       and mslp.child_id = ms.transaction_id
       and mslp.plan_id = ms.plan_id;
  v_date date;
BEGIN
  IF p_plan_id is null or p_supply_id is null then
     return null;
  END IF;

  OPEN date_c;
  FETCH date_c INTO v_date;
  CLOSE date_c;

  return v_date;
END material_avail_date;

 PROCEDURE offset_date(p_anchor_date in varchar2,
                          p_plan_id in number,
                          p_from_org in number, p_to_org in number,
                          p_inst_id in number,
                          p_ship_method in varchar2,
                          p_lead_time in out nocopy number,
                          p_ship_calendar in out nocopy varchar2,
                          p_deliver_calendar in out nocopy varchar2,
                          p_receive_calendar in out nocopy varchar2,
                          p_ship_date in out nocopy date,
                          p_dock_date in out nocopy date) is
  p_associate_type number;
  cursor lead_time_c is
    select intransit_time
      from msc_interorg_ship_methods
     where from_organization_id = p_from_org
       and to_organization_id = p_to_org
       and sr_instance_id = p_inst_id
       and ship_method = p_ship_method
       and plan_id = p_plan_id;
  p_work_date date;
BEGIN

if p_lead_time is null then
   OPEN lead_time_c;
   FETCH lead_time_c INTO p_lead_time;
   CLOSE lead_time_c;
end if;

if p_ship_method is null then
    if p_anchor_date = 'SHIP_DATE' then
       p_dock_date := p_ship_date + nvl(p_lead_time,0);
    else
       p_ship_date := p_dock_date - nvl(p_lead_time,0);
    end if;

   return;
end if;

   if p_deliver_calendar is null then

       p_deliver_calendar :=
          msc_calendar.get_calendar_code(
            p_inst_id,
            null,
            null,
            null,
            null,
            4,
            null,
            p_ship_method,
            7, --MSC_CALENDAR.VIC,
            p_associate_type);
    end if;

    if p_receive_calendar is null then
       p_receive_calendar :=
          msc_calendar.get_calendar_code(
            p_inst_id,
            null,
            null,
            null,
            null,
            3,
            p_to_org,
            p_ship_method,
            3, --MSC_CALENDAR.ORC,
            p_associate_type);
     end if;

     if p_ship_calendar is null then
       p_ship_calendar :=
          msc_calendar.get_calendar_code(
            p_inst_id,
            null,
            null,
            null,
            null,
            3,
            p_from_org,
            p_ship_method,
            5, --MSC_CALENDAR.OSC,
            p_associate_type);
     end if;
-- dbms_output.put_line(p_lead_time||','||p_deliver_calendar||','||p_receive_calendar||','||p_ship_calendar);
    if p_anchor_date = 'SHIP_DATE' then
 -- dbms_output.put_line('old ship date='||to_char(p_ship_date, 'MM/DD/RR HH24:MI'));
        p_ship_date :=
            msc_drp_util.get_work_day( 'NEXT', p_ship_calendar,
                                        p_inst_id, p_ship_date);
 -- dbms_output.put_line('new ship date='||to_char(p_ship_date, 'MM/DD/RR HH24:MI'));
        p_dock_date :=
            msc_rel_wf.get_offset_date(p_deliver_calendar,
                                        p_inst_id,
                                        p_lead_time, p_ship_date);
-- dbms_output.put_line('dock date='||to_char(p_dock_date, 'MM/DD/RR HH24:MI'));
        p_dock_date :=
            msc_drp_util.get_work_day('NEXT', p_receive_calendar,
                                        p_inst_id, p_dock_date);
-- dbms_output.put_line('dock date2='||to_char(p_dock_date, 'MM/DD/RR HH24:MI'));
    else
        p_dock_date :=
            msc_drp_util.get_work_day('PREV',p_receive_calendar,
                                        p_inst_id, p_dock_date);
        p_ship_date :=
            msc_rel_wf.get_offset_date(p_deliver_calendar,
                                        p_inst_id,
                                        -1*p_lead_time, p_dock_date);
        p_ship_date :=
            msc_drp_util.get_work_day('PREV', p_ship_calendar,
                                        p_inst_id, p_ship_date);
    end if;

END offset_date;

 PROCEDURE offset_dates(p_anchor_date in varchar2,
                          p_plan_id in number,
                          p_from_org in number, p_to_org in number,
                          p_inst_id in number,
                          p_item_id in number,
                          p_ship_method in varchar2,
                          p_lead_time in  number,
                          p_ship_calendar in  varchar2,
                          p_deliver_calendar in  varchar2,
                          p_receive_calendar in  varchar2,
                          p_ship_date in out nocopy date,
                          p_dock_date in out nocopy date,
                          p_due_date in out nocopy date) IS
	CURSOR pp_lt_c IS
	SELECT nvl(postprocessing_lead_time, 0)
	FROM  msc_system_items
	WHERE plan_id = p_plan_id
	AND   sr_instance_id = p_inst_id
	AND   ORGANIZATION_ID = p_to_org
	AND   INVENTORY_ITEM_ID = p_item_id;

     v_pp_lead_time number;
     v_lead_time number := p_lead_time;
     v_ship_method varchar2(30) := p_ship_method;
     v_deliver_calendar varchar2(20) := p_deliver_calendar;
     v_receive_calendar varchar2(20) := p_receive_calendar;
     v_ship_calendar varchar2(20) := p_ship_calendar;
     v_anchor_date varchar2(30);
     p_association_type number;

BEGIN
     OPEN pp_lt_c;
     FETCH pp_lt_c INTO v_pp_lead_time;
     CLOSE pp_lt_c;

     if v_receive_calendar is null then
       v_receive_calendar :=
          msc_calendar.get_calendar_code(
            p_inst_id,
            null,
            null,
            null,
            null,
            3,
            p_to_org,
            p_ship_method,
            3, --MSC_CALENDAR.ORC,
            p_association_type);
     end if;

     IF p_anchor_date = 'DUE_DATE' then
        p_dock_date :=
            msc_rel_wf.get_offset_date(v_receive_calendar,
                                        p_inst_id,
                                        v_pp_lead_time*-1, p_due_date);
        v_anchor_date := 'DOCK_DATE';
     ELSE
        v_anchor_date := p_anchor_date;
     END IF;

     offset_date(v_anchor_date,
                          p_plan_id,
                          p_from_org, p_to_org,
                          p_inst_id,
                          v_ship_method,
                          v_lead_time,
                          v_ship_calendar,
                          v_deliver_calendar,
                          v_receive_calendar,
                          p_ship_date,
                          p_dock_date);

     IF p_anchor_date <> 'DUE_DATE' then
        p_due_date :=
            msc_rel_wf.get_offset_date(v_receive_calendar,
                                        p_inst_id,
                                        v_pp_lead_time, p_dock_date);
     END IF;

END offset_dates;

 PROCEDURE IR_dates( p_plan_id in number,
                          p_inst_id in number,
                          p_transaction_id in number,
                          p_ship_date out nocopy date,
                          p_dock_date out nocopy date,
                          p_due_date out nocopy date) IS
  CURSOR ir_c IS
   select new_ship_date, new_dock_date, new_schedule_date
     from msc_supplies
    where plan_id = p_plan_id
      and sr_instance_id = p_inst_id
      and transaction_id = p_transaction_id;
BEGIN
   OPEN ir_c;
   FETCH ir_c INTO p_ship_date, p_dock_date, p_due_date;
   CLOSE ir_c;

END IR_dates;

FUNCTION wt_convert_ratio(p_item_id number, p_org_id number, p_inst_id number,
                p_uom_code varchar2) return number is
  cursor wt_c is
    select CONVERSION_RATE
      from MSC_WT_UOM_CONVERSIONS_VIEW
     where inventory_item_id = p_item_id
       and organization_id =p_org_id
       and sr_instance_id = p_inst_id
       and uom_code = p_uom_code;
   v_temp number;
BEGIN
 open wt_c;
 fetch wt_c into v_temp;
 close wt_c;

 return 1/nvl(v_temp,1);
END wt_convert_ratio;

FUNCTION vl_convert_ratio(p_item_id number, p_org_id number, p_inst_id number,
                p_uom_code varchar2) return number is
  cursor wt_c is
    select CONVERSION_RATE
      from MSC_VL_UOM_CONVERSIONS_VIEW
     where inventory_item_id = p_item_id
       and organization_id =p_org_id
       and sr_instance_id = p_inst_id
       and uom_code = p_uom_code;
   v_temp number;
BEGIN
 open wt_c;
 fetch wt_c into v_temp;
 close wt_c;


 return 1/nvl(v_temp,1);
END vl_convert_ratio;

FUNCTION sourcing_rule_name(p_plan_id number, p_item_id number,
                            p_from_org_id number, p_from_org_inst_id number,
                            p_to_org_id number, p_to_org_inst_id number,
                            p_rank number) return varchar2 IS
  cursor name_c is
   select msr.sourcing_rule_name
     from msc_item_sourcing mis,
          msc_sourcing_rules msr
    where mis.plan_id = p_plan_id
      and mis.inventory_item_id = p_item_id
      and mis.source_organization_id = p_from_org_id
      and mis.sr_instance_id = p_from_org_inst_id
      and mis.organization_id = p_to_org_id
      and mis.sr_instance_id2 = p_to_org_inst_id
      and nvl(mis.rank,-1) = nvl(p_rank,nvl(mis.rank,-1))
      and mis.circular_src = 1
      and msr.sourcing_rule_id = mis.sourcing_rule_id;

   v_name varchar2(80);
BEGIN
   OPEN name_c;
   FETCH name_c INTO v_name;
   CLOSE name_c;

   return v_name;
END sourcing_rule_name;

FUNCTION get_pref_key(p_plan_type number,
                      p_lookup_type varchar2, p_lookup_code number,
                      p_pref_tab varchar2) RETURN varchar2 IS

  v_plan_type number;
  cursor def_pref_c is
    select preference_key
      from  msc_user_preference_keys
     where plan_type = v_plan_type
       and number1 = p_lookup_code
       and PREF_TAB = p_pref_tab
       and prompt = p_lookup_type;
  v_out varchar2(100);
BEGIN

  v_plan_type := p_plan_type;

  if p_lookup_type in ('MSC_SUPPLIER_PLAN_TYPE','MSC_RESOURCE_HP',
                       'TRANSPORTATION_PLAN') or
     p_plan_type in (2,3) then
     v_plan_type :=1;
  end if;
    open def_pref_c;
    fetch def_pref_c into v_out;
    close def_pref_c;

    return v_out;
END get_pref_key;

FUNCTION alloc_rule_name(p_rule_id number) return varchar2 IS
  CURSOR rule_c IS
    select name
      from msc_drp_alloc_rules
     where rule_id = p_rule_id;
  p_name varchar2(30);
BEGIN
  IF p_rule_id is null then
     return null;
  END IF;

  OPEN rule_c;
  FETCH rule_c INTO p_name;
  CLOSE rule_c;

  return p_name;
END alloc_rule_name;

FUNCTION get_cal_violation(p_violated_calendars varchar2 ) return varchar2 IS
  l_out varchar2(3000);
  p_padded_vl_cal varchar2(10);
  no_of_calendars number :=7;
BEGIN
  p_padded_vl_cal := lpad(p_violated_calendars,no_of_calendars,'0');
  FOR a in 1..no_of_calendars loop
  IF substr(p_padded_vl_cal,a,1) <> '0' then
      if l_out is null then
         l_out :=
         msc_get_name.lookup_meaning('MSC_CALENDAR',a);
      else
         l_out := l_out ||','||
         msc_get_name.lookup_meaning('MSC_CALENDAR',a);
      end if;
  END IF;
  END LOOP;
  return l_out;
END get_cal_violation;

PROCEDURE update_supply_row(p_plan_id number,
                          p_transaction_id number,
                          p_shipment_id number,
                          p_firm_flag number,
                          p_ship_date date,
                          p_dock_date date,
                          p_ship_method varchar2,
                          p_lead_time number) IS

  cursor sup_c is
    select msi.postprocessing_lead_time pp_lead_time,
           ms.firm_planned_type firm_flag,
           ms.firm_date,
           ms.new_ship_date ship_date,
           ms.new_dock_date dock_date,
           ms.ship_method,
           ms.intransit_lead_time lead_time,
           ms.shipment_id,
           decode( ms.firm_planned_type, 1,
                   nvl(ms.firm_quantity,ms.new_order_quantity),
                   null) firm_qty,
           nvl(ms.firm_quantity,ms.new_order_quantity) new_firm_qty,
           ms.sr_instance_id
      from msc_supplies ms,
           msc_system_items msi
        where ms.plan_id = p_plan_id
          and ms.transaction_id = p_transaction_id
          and msi.inventory_item_id = ms.INVENTORY_ITEM_ID
          and msi.organization_id = ms.organization_id
          and msi.sr_instance_id = ms.sr_instance_id
          and msi.plan_id = ms.plan_id;
   p_firm_date date;
   p_firm_qty number;
   sup_rec sup_c%ROWTYPE;
   p_rec number := -1;

BEGIN

     OPEN sup_c;
     FETCH sup_c INTO sup_rec;
     CLOSE sup_c;
     p_firm_date := p_dock_date + sup_rec.pp_lead_time;

     -- record undo first

     for a in 1..nvl(g_supply_undo_rec.last,0) loop
         if g_supply_undo_rec(a).transaction_id = p_transaction_id then
            p_rec := a;
            exit;
          end if;
     end loop;

     if p_rec =-1 then
        -- first time update this transaction_id, start to record old values
        p_rec := nvl(g_supply_undo_rec.last,0) +1;
        g_supply_undo_rec(p_rec).transaction_id := p_transaction_id;
        g_supply_undo_rec(p_rec).sr_instance_id := sup_rec.sr_instance_id;
        g_supply_undo_rec(p_rec).orig_shipment_id := sup_rec.shipment_id;
        g_supply_undo_rec(p_rec).orig_firm_flag := sup_rec.firm_flag;
        g_supply_undo_rec(p_rec).orig_firm_qty := sup_rec.firm_qty;
        g_supply_undo_rec(p_rec).orig_firm_date := sup_rec.firm_date;
        g_supply_undo_rec(p_rec).orig_ship_date := sup_rec.ship_date;
        g_supply_undo_rec(p_rec).orig_dock_date := sup_rec.dock_date;
        g_supply_undo_rec(p_rec).orig_ship_method := sup_rec.ship_method;
        g_supply_undo_rec(p_rec).orig_lead_time := sup_rec.lead_time;
     end if;

      if p_firm_flag = 1 then
        p_firm_qty := sup_rec.new_firm_qty;
      else
        p_firm_qty := null;
        p_firm_date :=null;
      end if;

      g_supply_undo_rec(p_rec).shipment_id := p_shipment_id;
      g_supply_undo_rec(p_rec).firm_flag := p_firm_flag;
      g_supply_undo_rec(p_rec).firm_qty := p_firm_qty;
      g_supply_undo_rec(p_rec).firm_date := p_firm_date;

      g_supply_undo_rec(p_rec).ship_date := nvl(p_ship_date,sup_rec.ship_date);
      g_supply_undo_rec(p_rec).dock_date := nvl(p_dock_date,sup_rec.dock_date);
      g_supply_undo_rec(p_rec).ship_method :=
                                    nvl(p_ship_method,sup_rec.ship_method);
      g_supply_undo_rec(p_rec).lead_time := nvl(p_lead_time,sup_rec.lead_time);


     -- update table
          update msc_supplies
             set firm_planned_type = p_firm_flag,
                 firm_quantity = p_firm_qty,
                 firm_date = p_firm_date,
                 new_ship_date = nvl(p_ship_date,new_ship_date),
                 new_dock_date = nvl(p_dock_date,new_dock_date),
                 ship_method = nvl(p_ship_method,ship_method),
                 intransit_lead_time  = nvl(p_lead_time,intransit_lead_time),
                 status = 0,
                 applied = 2,
                 shipment_id = p_shipment_id
           where plan_id = p_plan_id
             and transaction_id = p_transaction_id;

END update_supply_row;

PROCEDURE mark_supply_undo(p_plan_id number) IS
  supply_Columns msc_undo.changeRGType;
  i number := 1;
  x_return_sts VARCHAR2(20);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(2000);
BEGIN
  for a in 1..nvl(g_supply_undo_rec.LAST,0) loop
      if notEqual(g_supply_undo_rec(a).firm_flag,
                  g_supply_undo_rec(a).orig_firm_flag) then
		supply_columns(i).column_changed := 'FIRM_PLANNED_TYPE';
		supply_columns(i).column_changed_text := get_msg('MSC','FIRM');
		supply_columns(i).old_value :=
                        g_supply_undo_rec(a).orig_firm_flag;
		supply_columns(i).column_type := 'NUMBER';
		supply_columns(i).new_value :=
                        g_supply_undo_rec(a).firm_flag;
		i := i+1 ;
       END IF;
      if notEqual(g_supply_undo_rec(a).firm_date,
                  g_supply_undo_rec(a).orig_firm_date) then
		supply_columns(i).column_changed := 'FIRM_DATE';
		supply_columns(i).column_changed_text := get_msg('MSC','FIRM_DATE');
		supply_columns(i).old_value :=
                   fnd_date.date_to_canonical(g_supply_undo_rec(a).orig_firm_date);
		supply_columns(i).column_type := 'DATE';
		supply_columns(i).new_value :=
                   fnd_date.date_to_canonical(g_supply_undo_rec(a).firm_date);
		i := i+1 ;
       END IF;
      if notEqual(g_supply_undo_rec(a).firm_qty,
                  g_supply_undo_rec(a).orig_firm_qty) then
		supply_columns(i).column_changed := 'FIRM_QUANTITY';
		supply_columns(i).column_changed_text := get_msg('MSC','FIRM_QTY');
		supply_columns(i).old_value :=
                        fnd_number.number_to_canonical(g_supply_undo_rec(a).orig_firm_qty);
		supply_columns(i).column_type := 'NUMBER';
		supply_columns(i).new_value :=
                        fnd_number.number_to_canonical(g_supply_undo_rec(a).firm_qty);
		i := i+1 ;
       END IF;
      if notEqual(g_supply_undo_rec(a).shipment_id,
          g_supply_undo_rec(a).orig_shipment_id) then
		supply_columns(i).column_changed := 'SHIPMENT_ID';
		supply_columns(i).column_changed_text := get_msg('MSC','SHIPMENT_ID');
		supply_columns(i).old_value :=
                        to_char(g_supply_undo_rec(a).orig_shipment_id);
		supply_columns(i).column_type := 'NUMBER';
		supply_columns(i).new_value :=
                        to_char(g_supply_undo_rec(a).shipment_id);
		i := i+1 ;
      end if;
      if notEqual(g_supply_undo_rec(a).lead_time,
          g_supply_undo_rec(a).orig_lead_time) then
		supply_columns(i).column_changed := 'INTRANSIT_LEAD_TIME';
		supply_columns(i).column_changed_text := get_msg('MSC','LEAD_TIME');
		supply_columns(i).old_value :=
                    fnd_number.number_to_canonical(g_supply_undo_rec(a).orig_lead_time);
		supply_columns(i).column_type := 'NUMBER';
		supply_columns(i).new_value :=
                    fnd_number.number_to_canonical(g_supply_undo_rec(a).lead_time);
		i := i+1 ;
       END IF;
      if notEqual(g_supply_undo_rec(a).ship_method,
          g_supply_undo_rec(a).orig_ship_method) then
		supply_columns(i).column_changed := 'SHIP_METHOD';
		supply_columns(i).column_changed_text := get_msg('MSC','MSC_EC_SHIP_METHOD');
		supply_columns(i).old_value := g_supply_undo_rec(a).orig_ship_method;
		supply_columns(i).column_type := 'VARCHAR2';
		supply_columns(i).new_value := g_supply_undo_rec(a).ship_method;
		i := i+1 ;
       END IF;
      if notEqual(g_supply_undo_rec(a).ship_date,
          g_supply_undo_rec(a).orig_ship_date) then
		supply_columns(i).column_changed := 'NEW_SHIP_DATE';
		supply_columns(i).column_changed_text := get_msg('MSC','MSC_SHIP_DATE');
		supply_columns(i).old_value := fnd_date.date_to_canonical(g_supply_undo_rec(a).orig_ship_date);
		supply_columns(i).column_type := 'DATE';
		supply_columns(i).new_value := fnd_date.date_to_canonical(g_supply_undo_rec(a).ship_date);
		i := i+1 ;
       END IF;
      if notEqual(g_supply_undo_rec(a).dock_date,
          g_supply_undo_rec(a).orig_dock_date) then
		supply_columns(i).column_changed := 'NEW_DOCK_DATE';
		supply_columns(i).column_changed_text := get_msg('MSC','MSC_DOCK_DATE');
		supply_columns(i).old_value := fnd_date.date_to_canonical(g_supply_undo_rec(a).orig_dock_date);
		supply_columns(i).column_type := 'DATE';
		supply_columns(i).new_value := fnd_date.date_to_canonical(g_supply_undo_rec(a).dock_date);
		i := i+1 ;
       END IF;
    msc_undo.store_undo(1, --table_changed
		2,     --insert or update
  		g_supply_undo_rec(a).transaction_id,
  		p_plan_id,
  		g_supply_undo_rec(a).sr_instance_id,
		NULL,
		supply_Columns,
		x_return_sts,
		x_msg_count,
		x_msg_data,
		NULL);
    i := 1;
    supply_Columns.delete;
  end loop;

  g_supply_undo_rec.delete;
END mark_supply_undo;


FUNCTION notEqual(p_value number, p_value2 number) return boolean IS
BEGIN
    if p_value <> p_value2 or
       (p_value is null and p_value2 is not null) or
       (p_value is not null and p_value2 is null) then
        return true;
    else
        return false;
    end if;

END notEqual;

FUNCTION notEqual(p_value varchar2, p_value2 varchar2) return boolean IS
BEGIN
    if p_value <> p_value2 or
       (p_value is null and p_value2 is not null) or
       (p_value is not null and p_value2 is null) then
        return true;
    else
        return false;
    end if;

END notEqual;

FUNCTION notEqual(p_value date, p_value2 date) return boolean IS
BEGIN
    if p_value <> p_value2 or
       (p_value is null and p_value2 is not null) or
       (p_value is not null and p_value2 is null) then
        return true;
    else
        return false;
    end if;

END notEqual;

Function get_msg(p_product varchar2, p_name varchar2) RETURN varchar2 IS
Begin
   FND_MESSAGE.set_name(p_product, p_name);
   return FND_MESSAGE.get;
End get_msg;

FUNCTION get_iso_trip(p_plan_id number, p_instance_id number,
                      p_disposition_id number) return number IS
  CURSOR trip_c IS
   select shipment_id
     from msc_supplies
    where plan_id = p_plan_id
      and sr_instance_id = p_instance_id
      and transaction_id = p_disposition_id;
  v_trip number;

BEGIN
   OPEN trip_c;
   FETCH trip_c INTO v_trip;
   CLOSE trip_c;

   return v_trip;
END get_iso_trip;

FUNCTION forecast_name(p_plan_id number,p_instance_id number,p_org_id number,
                       p_schedule_designator_id number,p_forecast_set_id number)
  RETURN varchar2 IS
  v_name varchar2(300);
  v_name2 varchar2(300);
BEGIN
  v_name := msc_get_name.scenario_designator(p_forecast_set_id,p_plan_id,p_org_id,p_instance_id);
  v_name2 := msc_get_name.designator(p_schedule_designator_id,p_forecast_set_id);
  if v_name is not null and v_name2 is not null then
     return v_name ||'/'||v_name2;
  else
     return v_name || v_name2;
  end if;
END forecast_name;

FUNCTION get_iso_name(p_plan_id number, p_instance_id number,
                      p_transaction_id number) return varchar2 IS
  CURSOR iso_c IS
   select order_number
     from msc_demands
    where plan_id = p_plan_id
      and sr_instance_id = p_instance_id
      and disposition_id = p_transaction_id;
  v_order_number varchar2(100);

BEGIN
   OPEN iso_c;
   FETCH iso_c INTO v_order_number;
   CLOSE iso_c;

   return v_order_number;
END get_iso_name;

FUNCTION get_work_day(  p_next_or_prev          IN varchar2,
                        p_calendar_code         IN varchar2,
                        p_instance_id           IN number,
                        p_calendar_date         IN date) return date IS
  p_out_date date;
  p_valid_hour date;
  v_from_time number;
  v_to_time number;
  v_time number;

  CURSOR time_c IS
  select mst.from_time,mst.to_time
    from msc_shift_times mst,
         msc_calendar_shifts mcs
   where mcs.calendar_code = p_calendar_code
     and mcs.sr_instance_id = p_instance_id
     and mst.calendar_code = mcs.calendar_code
     and mst.sr_instance_id = mcs.sr_instance_id
     and mst.shift_num = mcs.shift_num;

  p_end_of_prev_day boolean := false;

BEGIN
--dbms_output.put_line('original day='||to_char(p_calendar_date,'MM-DD-RR HH24:MI')||' move type is '||p_next_or_prev);

   if p_calendar_date is null then
      return p_calendar_date;
   end if;

   if p_next_or_prev  = 'NEXT' then
      p_out_date := msc_calendar.next_work_day(p_calendar_code,
                                        p_instance_id,
                                        p_calendar_date);
   else
      p_out_date := msc_calendar.prev_work_day(p_calendar_code,
                                        p_instance_id,
                                        p_calendar_date);
   end if;
 --dbms_output.put_line('p_out_date after move day='||to_char(p_out_date,'MM-DD-RR HH24:MI')||',move type is '||p_next_or_prev);
   if trunc(p_out_date) = trunc(p_calendar_date) then
       -- need to preserve the timestamp
      p_out_date := to_date(to_char(p_out_date, 'MM/DD/RR')||' '||
                                to_char(p_calendar_date,'HH24:MI'),
                                'MM/DD/RR HH24:MI');
   elsif p_next_or_prev  = 'PREV' then
      -- need to set to end time of the last shift of previous day
      -- set to 23:59 for now,
      -- it will be changed again, if shift is defined
      p_end_of_prev_day := true;
      p_out_date := to_date(to_char(p_out_date, 'MM/DD/RR')||' 23:59',
                                'MM/DD/RR HH24:MI');
   end if;
--dbms_output.put_line('p_out_date before shift time='||to_char(p_out_date,'MM-DD-RR HH24:MI'));

   if p_calendar_code is null then
      return p_out_date;
   end if;

   -- 5498765, need to check shift hours also

      OPEN time_c;
      LOOP
      FETCH time_c INTO v_from_time, v_to_time;
      EXIT WHEN time_c%NOTFOUND;
         if v_from_time > v_to_time then
            v_to_time := v_to_time + 60*60*24;
         end if;
--dbms_output.put_line('shift range is '||to_char(trunc(p_out_date)+v_from_time/(60*60*24),'MM-DD-RR HH24:MI')||','||to_char(trunc(p_out_date)+v_to_time/(60*60*24),'MM-DD-RR HH24:MI'));
         if not(p_end_of_prev_day) and
             p_out_date >=
                  trunc(p_out_date) + v_from_time/(60*60*24) and
             p_out_date <=
                  trunc(p_out_date) + v_to_time/(60*60*24) then
             -- valid working hours
             p_valid_hour := p_out_date;
             exit;
         else -- find the next working hour
             if p_next_or_prev  = 'NEXT' then
                if p_out_date <
                     trunc(p_out_date) + v_from_time/(60*60*24) then
                   if p_valid_hour is null or
                      p_valid_hour >
                         trunc(p_out_date) + v_from_time/(60*60*24) then
                      p_valid_hour :=
                         trunc(p_out_date) + v_from_time/(60*60*24);
                   end if;
                end if;
                if v_time is null or
                   v_time > v_from_time then
                   -- find the earliest shift time
                   v_time := v_from_time;
                end if;
             else -- if p_next_or_prev  = 'PREV' then
                if p_out_date >
                     trunc(p_out_date) + v_to_time/(60*60*24) then
                   if p_valid_hour is null or
                      p_valid_hour <
                         trunc(p_out_date) + v_to_time/(60*60*24) then
                      p_valid_hour :=
                         trunc(p_out_date) + v_to_time/(60*60*24);
                   end if;
                end if;
                if v_time is null or
                   v_time < v_to_time then
                   -- find the latiest shift time
                   v_time := v_to_time;
                end if;
             end if; -- if p_next_or_prev  = 'NEXT' then
         end if;
      END LOOP;
      CLOSE time_c;

      if v_from_time is null then
         return p_out_date;
      end if;

--dbms_output.put_line('v_time is '||to_char(trunc(p_out_date)+v_time/(60*60*24),'MM-DD-RR HH24:MI')||','||to_char(p_valid_hour,'MM-DD-RR HH24:MI'));
   if p_end_of_prev_day then
      p_out_date := trunc(p_out_date)+v_time/(60*60*24);
   elsif p_valid_hour is not null then
      p_out_date := p_valid_hour;
   else -- have not find the valid hour yet
      if p_next_or_prev  = 'NEXT' then
         -- move to the earliest shift time of the next working day
            p_out_date := msc_calendar.date_offset(p_calendar_code,
                                                  p_instance_id,
                                                  p_out_date,1,null);
            p_out_date := trunc(p_out_date) + v_time/(60*60*24);
      else -- if p_next_or_prev  = 'PREV'
         -- move to the latest shift time of the prev working day
            p_out_date := msc_calendar.date_offset(p_calendar_code,
                                                  p_instance_id,
                                                  p_out_date,-1,null);
            p_out_date := trunc(p_out_date) + v_time/(60*60*24);

      end if; -- -- if p_next_or_prev  = 'PREV'
    end if; -- if p_valid_hour is not null

-- dbms_output.put_line('p_out_date after shift time='||to_char(p_out_date,'MM-DD-RR HH24:MI'));
   return p_out_date;
END get_work_day;

FUNCTION rel_exp_where_clause(p_exc_type number,
                      p_plan_id number, p_org_id number,
                      p_inst_id number, p_item_id number,
                      p_source_org_id number, p_source_inst_id number,
                      p_supplier_id number, p_supply_id number,
                      p_demand_id number,
                      p_due_date date, p_dmd_satisfied_date date,
                      p_start_date date, p_end_date date) RETURN varchar2 IS

p_where varchar2(32000);

  v_id numberArr;
  v_list varchar2(32000);
  v_exc_list varchar2(32000);
  p_related_excp_type number;
  v_source_org_id number;
  v_source_inst_id number;
  p_comp_id number;
  p_min_time number;
  p_max_time number;
  p_lt_window number :=
         nvl(FND_PROFILE.value('MSC_DRP_REL_EXP_OFFSET_DAYS'),0);

  cursor pegged_supply is
    select child_id
      from msc_single_lvl_peg
     where plan_id = p_plan_id
       and pegging_type = 2 -- supply to parent demand
       and parent_id = p_demand_id;

  cursor source_org_c is
    select source_organization_id,
           sr_instance_id2,
           min(avg_transit_lead_time),
           max(avg_transit_lead_time)
      from msc_item_sourcing mis
     where mis.plan_id = p_plan_id
       and mis.inventory_item_id =  p_item_id
       and mis.organization_id = p_org_id
       and mis.sr_instance_id = p_inst_id
       and mis.source_organization_id =
              nvl(p_source_org_id, mis.source_organization_id)
       and mis.sr_instance_id2 = nvl(p_source_inst_id,mis.sr_instance_id2)
     group by source_organization_id, sr_instance_id2;


   cursor lead_time_c is
     select nvl(fixed_lead_time,0)
       from msc_system_items
      where plan_id = p_plan_id
       and inventory_item_id =  p_item_id
       and organization_id = p_org_id
       and sr_instance_id = p_inst_id;

   cursor comp_c is
     select inventory_item_id
       from msc_components_sc_v
      where plan_id = p_plan_id
       and using_assembly_id =  p_item_id
       and organization_id = p_org_id
       and sr_instance_id = p_inst_id;
BEGIN

  if p_exc_type in (24,26,52,95,96,111) then
     OPEN pegged_supply;
     FETCH pegged_supply BULK COLLECT INTO v_id;
     CLOSE pegged_supply;
  end if;

  v_list := construct_list(v_id);
  if v_list is not null then
        v_list := '('||v_list ||')';
  end if;

  if p_exc_type in (24,26,95,96,111) then -- late repl for SO/Forecast
     -- find matl and alloc const for the same item/org

     p_max_time := 0;
     p_min_time := 0;
     p_lt_window := 0;

     p_related_excp_type := 37; -- matl const
     v_id := related_excp(v_id,p_related_excp_type, p_plan_id,
                          p_org_id, p_inst_id, p_item_id,
                          p_due_date,p_dmd_satisfied_date,
                          p_max_time,p_min_time,p_lt_window);

     IF p_exc_type in (24,26) then
        p_related_excp_type := 82; -- alloc const
        v_id := related_excp(v_id,p_related_excp_type, p_plan_id,
                          p_org_id, p_inst_id, p_item_id,
                          p_due_date,p_dmd_satisfied_date,
                          p_max_time,p_min_time,p_lt_window);
     END IF;

     v_exc_list  := construct_list(v_id);

     if v_exc_list is null then
        v_exc_list := '(-1)';
     else
        v_exc_list := '('||v_exc_list||')';
     end if;

     p_where := p_where ||
                ' and ( exception_id in '||v_exc_list || ' or ';

     if v_list is not null then
        -- find order lead time const and order firm late for the related sup
        p_where := p_where ||
                ' ( exception_type in (59, 62) '||
                 ' and inventory_item_id = '||p_item_id ||
                 ' and organization_id = '||p_org_id ||
                 ' and sr_instance_id = '||p_inst_id ||
                 ' and transaction_id in '||v_list ||
                ') or ';
     end if;
     -- find demand qty not satisfied for this demand
     p_where := p_where ||
                ' ( exception_type =67 '||
                 ' and inventory_item_id = '||p_item_id ||
                 ' and organization_id = '||p_org_id ||
                 ' and sr_instance_id = '||p_inst_id ||
                 ' and demand_id = '||p_demand_id ||'))';

  elsif p_exc_type =52 then -- SO/Forecast at risk
     if v_list is null then
        v_list := '(-1)';
     end if;
     p_where :=  p_where ||
                 ' and exception_type in (54,57) '||
                 ' and inventory_item_id = '||p_item_id ||
                 ' and organization_id = '||p_org_id ||
                 ' and sr_instance_id = '||p_inst_id ||
                 ' and transaction_id in '||v_list;

  end if; -- end of if p_exc_type in (24,26,95,96,111)

  if p_exc_type in (37,2,20,73) then
    -- matl const, shortage, below safety, below target

    -- find item in the source org

       OPEN source_org_c;
       LOOP
          FETCH source_org_c INTO v_source_org_id, v_source_inst_id,
                                  p_min_time, p_max_time;
          EXIT WHEN source_org_c%NOTFOUND;

             p_related_excp_type := 37; -- matl const
             v_id := related_excp(
                          v_id,p_related_excp_type, p_plan_id,
                          v_source_org_id, v_source_inst_id, p_item_id,
                          p_start_date,p_end_date,
                          p_max_time,p_min_time,p_lt_window);

             p_related_excp_type := 82; -- alloc const
             v_id := related_excp(
                          v_id,p_related_excp_type, p_plan_id,
                          v_source_org_id, v_source_inst_id, p_item_id,
                          p_start_date,p_end_date,
                          p_max_time,p_min_time,p_lt_window);

        if p_exc_type in (2,20,73) then
             p_related_excp_type := 81; -- item cons to later date
             v_id := related_excp(
                          v_id,p_related_excp_type, p_plan_id,
                          v_source_org_id, v_source_inst_id, p_item_id,
                          p_start_date,p_end_date,
                          p_max_time,p_min_time,p_lt_window);

        end if;

       END LOOP;
       CLOSE source_org_c;

     if p_exc_type = 37 then
     -- find allocation const, dmd qty not satisfied, order lt const
     -- for the same item in the same org
        p_max_time := 0;
        p_min_time := 0;
        p_lt_window := 0;

        p_related_excp_type := 82; -- alloc const
        v_id := related_excp(
                          v_id,p_related_excp_type, p_plan_id,
                          p_org_id, p_inst_id, p_item_id,
                          p_start_date,p_end_date,
                          p_max_time,p_min_time,p_lt_window);

        p_related_excp_type :=  67; -- dmd qty not satisfied
        v_id := related_excp(
                          v_id,p_related_excp_type, p_plan_id,
                          p_org_id, p_inst_id, p_item_id,
                          p_start_date,p_end_date,
                          p_max_time,p_min_time,p_lt_window);

        p_related_excp_type :=  59; -- order lt const
        v_id := related_excp(
                          v_id,p_related_excp_type, p_plan_id,
                          p_org_id, p_inst_id, p_item_id,
                          p_start_date,p_end_date,
                          p_max_time,p_min_time,p_lt_window);

     end if; -- if p_exc_type = 37 then

     if p_exc_type in (37,2,20,73) then
     -- find matl/alloc const for component in the same org

        OPEN lead_time_c;
        FETCH lead_time_c INTO p_max_time;
        CLOSE lead_time_c;

        p_min_time := p_max_time;
        p_lt_window := 0;

        OPEN comp_c;
        LOOP
          FETCH comp_c INTO p_comp_id;
          EXIT WHEN comp_c%NOTFOUND;

             p_related_excp_type := 82; -- alloc const
             v_id := related_excp(
                          v_id,p_related_excp_type, p_plan_id,
                          p_org_id, p_inst_id, p_comp_id,
                          p_start_date,p_end_date,
                          p_max_time,p_min_time,p_lt_window);

             p_related_excp_type := 37; -- matl const
             v_id := related_excp(
                          v_id,p_related_excp_type, p_plan_id,
                          p_org_id, p_inst_id, p_comp_id,
                          p_start_date,p_end_date,
                          p_max_time,p_min_time,p_lt_window);

         END LOOP;
         CLOSE comp_c;

     end if; -- if p_exc_type in (37,2,20,73)


     if v_exc_list is null then
        v_exc_list := '(-1)';
     else
        v_exc_list := '('||v_exc_list||')';
     end if;

     p_where := p_where ||
                ' and exception_id in '||v_exc_list;

  end if; -- if p_exc_type in (37,2,20,73)

  return p_where;
END rel_exp_where_clause;

FUNCTION construct_list(p_id numberArr) RETURN varchar2 IS
  p_list varchar2(3000);
  p_query_id number;
BEGIN
  for a in 1..nvl(p_id.last,0) loop
     if p_list is null then
        p_list := p_id(a);
     else
        p_list := p_list ||','||p_id(a);
     end if;
  end loop;

  if length(p_list) > 1500 then
-- 5898008, where clause in folder block has length limit < 2000

    select msc_form_query_s.nextval
       into p_query_id
        from dual;

     forall a in 1..nvl(p_id.last,0)
         insert into msc_form_query
                        (QUERY_ID,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN,
                        NUMBER1)
                values (
                        p_query_id,
                        sysdate,
                        -1,
                        sysdate,
                        -1,
                        -1,
                         p_id(a));

     p_list := ' select number1 '||
                 ' from msc_form_query '||
                 ' where query_id ='||p_query_id ;
  end if; -- if length(p_list) > 2000 then

  return p_list;

END  construct_list;

FUNCTION related_excp(p_id numberArr,p_related_excp_type number,
                      p_plan_id number, p_org_id number,
                      p_inst_id number, p_item_id number,
                      p_start_date date, p_end_date date,
                      p_max_time number, p_min_time number,
                      p_lt_window number) RETURN numberArr IS

    cursor exc_id_c is
     select med.exception_detail_id
       from msc_exception_details med
     where med.plan_id = p_plan_id
       and med.inventory_item_id =  p_item_id
       and med.organization_id = p_org_id
       and med.sr_instance_id = p_inst_id
       and med.exception_type = p_related_excp_type
       and (med.date1
               between(p_start_date - p_max_time - p_lt_window) and
                      (p_end_date - p_min_time +1) or
            nvl(med.date2,med.date1)
               between(p_start_date - p_max_time - p_lt_window) and
                      (p_end_date - p_min_time +1) or
            (med.date1 < (p_start_date - p_max_time - p_lt_window) and
             nvl(med.date2,med.date1) > (p_end_date - p_min_time +1)));

 v_id numberArr;
 i number;
BEGIN

     OPEN exc_id_c;
     FETCH exc_id_c BULK COLLECT INTO v_id;
     CLOSE exc_id_c;

  if p_id is not null then
     -- merge two arrays
     i := nvl(v_id.last,0);
     for a in 1 .. nvl(p_id.last,0) loop
        v_id(i+a) := p_id(a);
     end loop;
  end if;

  return v_id;

END related_excp;

PROCEDURE update_exp_version(p_rowid rowid,
                             p_action_taken number) IS
  TYPE numtab is table of Number index by binary_integer;
  p_action numTab;
  p_excp_id numTab;
  p_plan_id number;
  p_excp_type number;
  p_org_id number;
  p_inst_id number;
  p_item_id number;
  p_supplier_id number;
  p_supplier_site_id number;
  p_source_org_id number;
  p_action_taken_date date;

BEGIN

  -- lock msc_srp_item_exceptions first

    Select msie.plan_id,
           msie.organization_id,
           msie.sr_instance_id,
           msie.inventory_item_id,
           msie.exception_type,
           msie.supplier_id,
           msie.supplier_site_id,
           msie.source_org_id
    INTO p_plan_id, p_org_id, p_inst_id, p_item_id, p_excp_type,
         p_supplier_id, p_supplier_site_id, p_source_org_id
    From msc_exception_details med,
         Msc_srp_item_exceptions msie
   Where med.plan_id = msie.plan_id
     And med.organization_id = msie.organization_id
     And med.sr_instance_id = msie.sr_instance_id
     And med.inventory_item_id = msie.inventory_item_id
     And med.exception_type = msie.exception_type
     And nvl(med.supplier_id,-23453) = msie.supplier_id
     And nvl(med.supplier_site_id,-23453) = msie.supplier_site_id
     And decode(med.exception_type, 43, med.number2,-23453) =
         msie.source_org_id
     and msie.exist = 1
     and med.rowid = p_rowid
     for update of msie.action_taken_date nowait;

  -- lock msc_exception_details

    Select med.exception_detail_id
    BULK COLLECT INTO p_excp_id
    From msc_exception_details med
   Where med.plan_id = p_plan_id
     And med.organization_id = p_org_id
     And med.sr_instance_id = p_inst_id
     And med.inventory_item_id = p_item_id
     And med.exception_type = p_excp_type
     And nvl(med.supplier_id,-23453) = p_supplier_id
     And nvl(med.supplier_site_id,-23453) = p_supplier_site_id
     And decode(med.exception_type, 43, med.number2,-23453) = p_source_org_id
     for update of med.action_taken_date, med.action_taken nowait;

    if p_action_taken = 1 then
       p_action_taken_date := sysdate;
    end if;

 -- update all the excp within the same criteria group
    Forall a in 1..nvl(p_excp_id.last,0)
    Update msc_exception_details
       Set action_taken_date = p_action_taken_date,
           action_taken = p_action_taken
     Where plan_id = p_plan_id
       AND exception_detail_id = p_excp_id(a);

    Update msc_srp_item_exceptions
       Set action_taken_date = p_action_taken_date
     Where plan_id = p_plan_id
       And organization_id = p_org_id
       And sr_instance_id = p_inst_id
       And inventory_item_id = p_item_id
       And exception_type = p_excp_type
       And supplier_id = p_supplier_id
       And supplier_site_id = p_supplier_site_id
       And source_org_id = p_source_org_id
       and exist = 1;
EXCEPTION
  WHEN app_exception.record_lock_exception THEN
    -- dbms_output.put_line('can not lock');
       null;
  when others then
    -- dbms_output.put_line('error is ' ||SQLERRM);
       null;
END update_exp_version;

PROCEDURE retrieve_exp_version(p_plan_id number) IS
  TYPE dateTab is table of Date index by binary_integer;
  TYPE numtab is table of Number index by binary_integer;
  p_action numTab;
  p_excp_id numTab;
  p_action_date dateTab;
  p_gen_date dateTab;
  p_plan_date date;

  CURSOR plan_c IS
   select plan_start_date
     from msc_plans
    where plan_id = p_plan_id;

BEGIN


    OPEN plan_c;
    FETCH plan_c INTO p_plan_date;
    CLOSE plan_c;

MSC_UTIL.MSC_DEBUG('retrieve exception versions ');

    Select med.exception_detail_id,
           msie.action_taken_date,
           msie.last_generated_date
    BULK COLLECT INTO p_excp_id, p_action_date, p_gen_date
    From msc_exception_details med,
         Msc_srp_item_exceptions msie
   Where med.plan_id = msie.plan_id
     And med.organization_id = msie.organization_id
     And med.sr_instance_id = msie.sr_instance_id
     And med.inventory_item_id = msie.inventory_item_id
     And med.exception_type = msie.exception_type
     And nvl(med.supplier_id,-23453) = msie.supplier_id
     And nvl(med.supplier_site_id,-23453) = msie.supplier_site_id
     And decode(med.exception_type, 43, med.number2,-23453) =
         msie.source_org_id
     and msie.exist = 1
     and msie.plan_id = p_plan_id;

   Forall a in 1..nvl(p_excp_id.last,0)
      Update msc_exception_details
         Set action_taken_date = p_action_date(a),
             first_generated_date = p_gen_date(a),
             Action_taken = decode(p_action_date(a), null, 2, 1),
             new_exception = decode(p_gen_date(a), p_plan_date, 1, 0)
       Where plan_id = p_plan_id
         And exception_detail_id = p_excp_id(a);
   commit;

EXCEPTION
  WHEN app_exception.record_lock_exception THEN
      null; --dbms_output.put_line('can not lock');
  WHEN others then
     null; --dbms_output.put_line('error is ' ||SQLERRM);
END retrieve_exp_version;

END MSC_DRP_UTIL;

/
