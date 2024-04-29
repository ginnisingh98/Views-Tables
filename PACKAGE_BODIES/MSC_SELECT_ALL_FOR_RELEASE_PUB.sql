--------------------------------------------------------
--  DDL for Package Body MSC_SELECT_ALL_FOR_RELEASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SELECT_ALL_FOR_RELEASE_PUB" AS
    /* $Header: MSCSARPB.pls 120.15.12010000.4 2009/12/08 14:46:49 skakani ship $ */
TYPE numtab is table of Number index by binary_integer;
TYPE char240_tab is table of varchar2(240) index by binary_integer;
g_instance_id numtab;
g_job_prefix char240_tab;

FUNCTION get_implement_as(p_order_type number,
                          p_org_id number,
                          p_source_org_id number,
                          p_supplier_id number,
                          p_planning_make_buy_code number,
                          p_build_in_wip_flag number,
                          p_purchasing_enabled_flag number) return number IS
  p_impl_as number;
BEGIN
  p_impl_as := 1; -- none
     if p_order_type = 5 then
        if p_org_id = p_source_org_id then
           if p_build_in_wip_flag = 1 then
              p_impl_as := 3; -- discrete job
           end if;

        elsif p_org_id <> p_source_org_id then
              p_impl_as := 2; -- purchase req

        elsif p_supplier_id is not null then
           if p_purchasing_enabled_flag =1 then
              p_impl_as := 2; -- purchase req
           end if;
        elsif p_supplier_id is null and p_source_org_id is null then
              if p_planning_make_buy_code = 1 then
                 if p_build_in_wip_flag = 1 then
                    p_impl_as := 3; -- discrete job
                 end if;
              else -- if p_planning_make_buy_code = 2 then
                 if p_purchasing_enabled_flag = 1 then
                    p_impl_as := 2; -- purchase req
                 end if;
              end if;
         end if; --if p_org_id = p_source_org_id then
    elsif p_order_type = 13 then
         p_impl_as := 4;
    elsif p_order_type = 51 then
         p_impl_as := 5;
    elsif p_order_type = 76 then
	--pabram.srp.changes added 76,77,78
         p_impl_as := 2;
    elsif p_order_type = 77 then
         p_impl_as := 5;
    elsif p_order_type = 78 then
         p_impl_as := 2;
    end if; -- if p_order_type = 5 then

    return p_impl_as;

END get_implement_as;

function get_alternate_rtg (p_plan_id in number,
p_sr_instance_id number,
p_proc_seq_id number) return varchar2 is
    alt_rtg varchar2(40) ; --5338566 bugfix, length changed to 40
begin
select alternate_routing_designator
into alt_rtg
from msc_routings b, msc_process_effectivity p
where p.plan_id = b.plan_id
and p.sr_instance_id= b.sr_instance_id
and p.routing_sequence_id = b.routing_sequence_id
and p.process_sequence_id = p_proc_seq_id
and p.plan_id = p_plan_id
and p.sr_instance_id = p_sr_instance_id
;
return (alt_rtg);
exception when no_data_found then
   return null;

end get_alternate_rtg ;

function get_alternate_bom (p_plan_id in number,
p_sr_instance_id number,
p_proc_seq_id number) return varchar2 is
    alt_bom varchar2(40) ; --5338566 bugfix, length changed to 40
begin

select alternate_bom_designator
into alt_bom
from msc_boms b, msc_process_effectivity p
where p.plan_id = b.plan_id
and p.sr_instance_id= p.sr_instance_id
and p.bill_sequence_id = b.bill_sequence_id
and p.process_sequence_id = p_proc_seq_id
and p.plan_id = p_plan_id
and p.sr_instance_id = p_sr_instance_id
;
return (alt_bom);
exception when no_data_found then
   return null;

end get_alternate_bom ;

--Bug3273575 create a new function to get job prefix profile from Source.
function get_wip_job_prefix(p_sr_instance_id in number)
         return varchar2 is
l_wip_job_prefix VARCHAR2(240) := NULL;
begin
    for i in 1..g_instance_id.COUNT loop
         IF g_instance_id(i) = p_sr_instance_id then
             return(g_job_prefix(i));
         END IF;
    end loop;
    return (null);
exception
 when others then
    return null;
end get_wip_job_prefix;

PROCEDURE Update_Implement_Attrib(p_where_clause IN VARCHAR2,
                                  p_employee_id IN NUMBER,
                                  p_demand_class IN VARCHAR2,
                                  p_def_job_class IN VARCHAR2,
                                  p_def_firm_jobs IN VARCHAR2,
                                  p_include_so IN VARCHAR2,
                                  p_total_rows OUT NOCOPY NUMBER,
                                  p_succ_rows OUT NOCOPY NUMBER,
                                  p_error_rows OUT NOCOPY NUMBER,
                                  p_current_plan_type IN NUMBER DEFAULT NULL
                                  ) IS

   p_sql_stmt  VARCHAR2(32767);
   p_drp_stmt  VARCHAR2(32767);

   TYPE SelCurTyp IS REF CURSOR;
   SelCur SelCurTyp;
   p_rel_error varchar2(30000);

   p_plan_id number;
   p_bom_item_type number;
   p_release_time_fence_code number;
   p_in_source_plan number;
   p_action varchar2(250);
   p_cfm_routing_flag number;
   p_effectivity_control number;
   p_unit_number number;
   p_order_type number;
   p_project_id number;
   p_impl_as number;
   p_org_id number;
   p_source_org_id number;
   p_supplier_id number;
   p_planning_make_buy_code number;
   p_build_in_wip_flag number;
   p_purchasing_enabled_flag number;
   p_loc_id number;
   p_empl_id number;
   p_item_id number;
   p_due_date date;
   p_planner_code varchar2(20);
   p_task_id number;
   p_transaction_id number;
   p_inst_id number;
   p_lots_exist number;
   p_new_order_qty number;

   p_def_job_status number;
   p_wip_class_code varchar2(300);
   p_mesg varchar2(80);
   p_plan_type number := p_current_plan_type;

   cursor plan_type_c is
      select curr_plan_type
      from msc_plans
      where plan_id = p_plan_id;

PROCEDURE reset_record IS
BEGIN
    p_loc_id := null;
    p_empl_id := null;
    p_rel_error := null;
    p_cfm_routing_flag := null;
    p_effectivity_control := null;
    p_unit_number := null;
    p_project_id := null;
    p_task_id := null;
    p_source_org_id := null;
    p_supplier_id := null;
    p_planner_code := null;
    p_impl_as := null;
    p_lots_exist := null;

END reset_record;

PROCEDURE verify_release_error IS

  p_valid number;
  p_rel_schd_OK varchar2(3);

  CURSOR empl_C IS
      SELECT mp.employee_id
  FROM msc_planners mp
  WHERE mp.planner_code = p_planner_code
    AND mp.organization_id = p_org_id
    AND mp.sr_instance_id = p_inst_id
    AND mp.current_employee_flag = 1;

 CURSOR loc_C IS
  select mtps.sr_tp_site_id
    from msc_trading_partners mtp,
         msc_trading_partner_sites mtps
    where mtp.sr_tp_id = p_org_id
      AND mtp.sr_instance_id = p_inst_id
      AND mtp.partner_type =3
      AND mtps.partner_id = mtp.partner_id;

BEGIN
  if p_bom_item_type in (1, 2, 3, 5) then
     --  Models/Option Classes cannot be released
     p_rel_error := FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_MODEL');
  end if;

  if p_release_time_fence_code = 6 then
     -- Kanban Items Cannot be Released.
     p_rel_error := p_rel_error ||' '||
                    FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_KANBAN');
  end if;

  if p_in_source_plan = 1 then
     p_rel_schd_OK :=
        nvl(fnd_profile.value('MSC_DRP_RELEASE_FROM_MRP'),'N');
   -- Record was generated as part of some other plan/schedule.
     if (p_lots_exist = 2 and -- can not release supply schedule
         p_new_order_qty <> 0) or  -- which is generated by plan
        (p_lots_exist = 1 and -- demand schedule
         p_rel_schd_OK = 'N') or
        (p_lots_exist = 2 and -- manually created planned order
         p_new_order_qty =0 and  -- for supply schedule
         p_rel_schd_OK = 'N') then

         p_rel_error := p_rel_error ||' '||
                 FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_IN_SOURCE_PLAN');
     end if;
  end if; -- if p_in_source_plan = 1 then

  if p_action = msc_get_name.lookup_meaning('MRP_ACTIONS',6) then -- None
     if (p_plan_type = 8 and p_order_type = 51) then
      null;
     else
     p_rel_error := p_rel_error ||' '||
                 FND_MESSAGE.GET_STRING('MSC', 'MSC_REL_ACTION_NONE');
     end if;
  end if;


  if p_cfm_routing_flag = 1 and p_order_type = 5 then
     p_rel_error := p_rel_error ||' '||
                 FND_MESSAGE.GET_STRING('MSC', 'MSC_NO_FLOW_SCHEDULE');
  end if;

  if p_effectivity_control=2 and
     p_unit_number is null and
     p_order_type = 5 then
     p_rel_error := p_rel_error || ' '||
                 FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_UNIT_NUMBER');
  end if;

  if p_project_id is not null then
     p_valid := msc_rel_wf.is_pjm_valid(p_org_id,
                                         p_project_id,
                                         p_task_id,
                                         p_due_date,
                                         null,
                                         p_inst_id);
    if p_valid = 0 then
       p_rel_error := p_rel_error || ' '||
                 FND_MESSAGE.GET_STRING('MSC', 'MSC_PJM_VALIDATION1');

    end if;
  end if; -- if p_project_id is not null then

  p_valid := null;
  if nvl(FND_PROFILE.VALUE('MSC_REL_ONLY_ONHAND_SUPPLY'),'N') =  'Y' and
     p_order_type = 5 and p_org_id = p_source_org_id then

     -- 4417550, make planned order can be released only when
     -- child supply are on hand or make planned order

         p_valid := MSC_SELECT_ALL_FOR_RELEASE_PUB.child_supplies_onhand(
                    p_plan_id, p_transaction_id);
         if p_valid > 0 then
            p_rel_error := p_rel_error ||' '||
                 FND_MESSAGE.GET_STRING('MSC', 'MSC_REL_ONLY_ONHAND_WARN2');
         end if;

  end if; -- if nvl(FND_PROFILE.VALUE('MSC_REL_ONLY_ONHAND_SUPPLY'),'N') = 'Y'

  if p_rel_error is null then
     if p_order_type in (5,13,51,76,77,78) then
       --pabram.srp.changes added 76,77,78

        p_impl_as := msc_select_all_for_release_pub.get_implement_as(
                          p_order_type,
                          p_org_id,
                          p_source_org_id,
                          p_supplier_id,
                          p_planning_make_buy_code,
                          p_build_in_wip_flag,
                          p_purchasing_enabled_flag);
    end if;

    if p_impl_as in (2,5) or p_order_type = 2 then
    -- update impl_location_id
       OPEN loc_C;
       FETCH loc_C into p_loc_id;
       CLOSE loc_c;
/*
       if p_loc_id is null then
         p_rel_error := p_rel_error ||' '||
                 FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_LOCATION');
       end if;
*/
    end if; -- if p_impl_as in (2,5) or p_order_type = 2 then

    if p_impl_as in (2,5) then
   /* update employee_id to be the employee_id for the corresponding
      planner_code in msc_system_items */
      OPEN empl_C;
      FETCH empl_C INTO p_empl_id;
      CLOSE empl_C;

      if p_empl_id is null then
         p_rel_error := p_rel_error ||' '||
                 FND_MESSAGE.GET_STRING('MRP', 'MRP_REL_ALL_EMPLOYEE');
      end if;
    end if; -- if p_impl_as in (2,5) then

  end if; -- if p_rel_error is null then

END verify_release_error;

PROCEDURE update_success_supplies IS
  CURSOR sr_item IS
      SELECT msi.sr_inventory_item_id
        FROM msc_system_items msi
       WHERE msi.plan_id=p_plan_id
         AND msi.organization_id = p_org_id
         AND msi.sr_instance_id = p_inst_id
         and msi.inventory_item_id = p_item_id;

  p_sr_item_id number;
  p_job_name varchar2(3000);
  p_load_type number;
  p_item_wip_class varchar2(300);

BEGIN

  IF p_impl_as = 3 then -- discrete job
     if p_wip_class_code is null then
        if nvl(p_cfm_routing_flag,0) <> 3 then
           OPEN sr_item;
           FETCH sr_item INTO p_sr_item_id;
           CLOSE sr_item;
           p_item_wip_class :=
                   msc_rel_wf.get_acc_class_from_source(
                      p_org_id,
                      p_sr_item_id,
                      p_project_id,
                      p_inst_id);
        end if; -- if p_cfm_routing_flag <> 3
     end if; -- if p_wip_class_code is null then

     p_job_name := get_wip_job_prefix(p_inst_id)||
                   msc_rel_wf.get_job_seq_from_source(p_inst_id);

      update msc_supplies mr
         set implement_wip_class_code =
            nvl(p_wip_class_code, p_item_wip_class),
         implement_status_code =
           nvl(implement_status_code, p_def_job_status),
         implement_demand_class =
           nvl(mr.implement_demand_class, p_demand_class),
         implement_job_name =
           nvl(mr.implement_job_name, p_job_name),
         implement_firm = nvl(mr.implement_firm,
           DECODE(p_def_firm_jobs, 'Y', 1, mr.firm_planned_type)),
         implement_alternate_routing = nvl(implement_alternate_routing,
            get_alternate_rtg(mr.plan_id,mr.sr_instance_id,mr.process_seq_id)),
         implement_alternate_bom = nvl(implement_alternate_bom,
            get_alternate_bom(mr.plan_id,mr.sr_instance_id,mr.process_seq_id))
      where  transaction_id  = p_transaction_id
        and plan_id = p_plan_id;

  END IF; -- IF p_impl_as = 3 then

  p_load_type := msc_get_name.load_type(
                p_plan_type,
                p_plan_id,
                'MSC_SUPPLIES',
                p_transaction_id,
                p_org_id,
                p_inst_id,
                p_order_type,
                p_impl_as,
                p_source_org_id,
                p_inst_id,
                nvl(p_cfm_routing_flag,0),
                p_item_id,
                null);

  IF p_order_type in (1, 2, 3, 5, 51, 53,76,77,78) THEN
    --pabram.srp.changes added 76,77,78
    update msc_supplies mr
    SET implement_date = nvl(mr.implement_date,
	 decode(trunc(GREATEST(NVL(mr.firm_date,mr.new_schedule_date),
                                      TRUNC(SYSDATE))),
				trunc(mr.new_schedule_date),
				   mr.new_schedule_date,
				   msc_calendar.next_work_day(
				      mr.organization_id,
				      mr.sr_instance_id,
				      1,
			greatest(nvl( mr.firm_date, mr.new_schedule_date ),
						trunc(sysdate))
				   )
		              )
			),
      implement_quantity = nvl(implement_quantity,
            DECODE(mr.disposition_status_type, 2,
                    decode(mr.order_type,3,
                          decode(nvl(mr.implemented_quantity,0),0,
                          mr.new_order_quantity, mr.implemented_quantity),
                           0),
            GREATEST(NVL(mr.firm_quantity, mr.new_order_quantity)
            - NVL(mr.quantity_in_process, 0)
            - NVL(mr.implemented_quantity, 0), 0))),
        release_status = 1,
        implement_as = p_impl_as,
        release_errors = null,
        implement_employee_id = p_empl_id,
        implement_location_id = p_loc_id,
        implement_supplier_id = nvl(mr.implement_supplier_id,
             DECODE(p_impl_as,
	     2, nvl(mr.implement_supplier_id, mr.source_supplier_id),
             mr.implement_supplier_id)),
        implement_supplier_site_id = DECODE(p_impl_as, 2,
            nvl(mr.implement_supplier_site_id, mr.source_supplier_site_id),
            mr.implement_supplier_site_id),
        implement_source_org_id = DECODE(p_impl_as, 2,
            DECODE(mr.source_organization_id, mr.organization_id, NULL,
            mr.source_organization_id),
            5, nvl(mr.source_organization_id, mr.organization_id), NULL),
        implement_sr_instance_id = DECODE(p_impl_as, 2,
            DECODE(mr.source_sr_instance_id, mr.sr_instance_id, NULL,
            mr.source_sr_instance_id),
            5, nvl(mr.source_sr_instance_id, mr.sr_instance_id), NULL),
        reschedule_flag = DECODE(mr.order_type, 5, 2, 51, 2, 1),
        implement_unit_number = decode(p_effectivity_control,2,
            nvl(implement_unit_number,unit_number), null),
        load_type = p_load_type,
        status = 0,
        applied = 2,
        last_updated_by = fnd_global.user_id,
        implement_status_code =
-- bug 4410222, For cancelled discrete jobs, set implement_status_code to 7
              decode(order_type, 3,
                                decode(disposition_status_type,2, 7,
                                       implement_status_code),
                                 implement_status_code),
        implement_dock_date = nvl(implement_dock_date,
                        decode(order_type, 2, new_dock_date ,
                               53, new_dock_date ,
                               implement_dock_date))
    where transaction_id = p_transaction_id
      and plan_id = p_plan_id;

    if p_order_type in (5,51,76,77,78) then
       --pabram.srp.changes added 76,77,78
       update msc_supplies mr
          set quantity_in_process =
                DECODE(mr.number1,
                       -9999, mr.quantity_in_process,
                        GREATEST(0,
                            NVL(mr.quantity_in_process, 0) +
                            NVL(mr.implement_quantity, 0) -
                            NVL(mr.number1,0))),
               number1 = DECODE(mr.order_type,
                         5, mr.implement_quantity,
                         51, mr.implement_quantity,
                         mr.number1),
              implement_project_id =
                        nvl(mr.implement_project_id,mr.project_id),
              implement_task_id =
                        nvl(mr.implement_task_id,mr.task_id),
              implement_ship_date = nvl(implement_ship_date,
                        decode(p_load_type, 32, new_ship_date, -- internal req
                               256, new_ship_date, -- internal repair
                               implement_ship_date)),
              implement_dock_date = nvl(implement_dock_date,
                        decode(p_load_type, 32, new_dock_date ,
                                256, new_ship_date, -- internal repair
                               implement_dock_date)),
              implement_firm = nvl(implement_firm,
                        decode(p_load_type, 32, firm_planned_type,
                                256, firm_planned_type, -- internal repair
                               implement_firm))
        where transaction_id = p_transaction_id
          and plan_id = p_plan_id;
    end if; -- if p_order_type in (5,51) then
  ELSE -- p_order_type  = 13
    update msc_supplies msrs
       SET implement_date = nvl(msrs.implement_date,
		msrs.last_unit_completion_date),
        implement_daily_rate =  nvl(msrs.implement_daily_rate, msrs.daily_rate),
        implement_quantity =  nvl(msrs.implement_daily_rate, msrs.daily_rate),
        implement_demand_class = nvl(msrs.implement_demand_class,
		p_demand_class),
        implement_line_id = nvl(msrs.implement_line_id, msrs.line_id),
        implement_processing_days = nvl(msrs.implement_processing_days,
                msc_calendar.days_between(msrs.organization_id,
                                          msrs.sr_instance_id,
                                          1,
                                          msrs.last_unit_completion_date,
                                          nvl(msrs.first_unit_completion_date,
                                              msrs.new_schedule_date)
                                          ) +1),
        load_type = p_load_type,
        release_errors = null,
        release_status = 1,
        implement_as =4,
        status = 0,
        applied = 2,
        last_updated_by = fnd_global.user_id
    where transaction_id = p_transaction_id
      and plan_id = p_plan_id;

  END IF; --IF p_order_type in (1, 2, 3, 5, 51, 53)

END update_success_supplies;

Procedure update_sup_rel_error IS
BEGIN
          update msc_supplies
            SET implement_as = NULL,
                implement_quantity = NULL,
                implement_date = NULL,
                release_status = 2,
                release_errors = p_rel_error
          where transaction_id = p_transaction_id
            and plan_id = p_plan_id;
END update_sup_rel_error;

Procedure update_dmd_rel_error IS
BEGIN
             update msc_demands
             set release_errors = p_rel_error,
                implement_org_id = null,
                implement_instance_id = null,
                implement_date = NULL,
                implement_ship_date = NULL,
                implement_arrival_date = NULL,
                implement_earliest_date = NULL,
                implement_firm = NULL,
                reschedule_flag = NULL,
                load_type = null,
                release_status = 2
           where plan_id = p_plan_id
             and demand_id = p_transaction_id
             and sr_instance_id = p_inst_id;

END update_dmd_rel_error;

PROCEDURE update_dmd_success IS
  p_impl_date date;
  v_ship_date date;
  v_arrival_date date;
  v_earliest_date date;
BEGIN
             msc_rel_wf.update_so_dates(p_plan_id, p_transaction_id, p_inst_id,
                             p_impl_date, v_ship_date, v_arrival_date,
                             v_earliest_date);
            update msc_demands
            set implement_org_id = organization_id,
                implement_instance_id = sr_instance_id,
                implement_date = nvl(implement_date,planned_ship_date),
                implement_ship_date = v_ship_date,
                implement_arrival_date = v_arrival_date,
                implement_earliest_date = v_earliest_date,
                implement_firm = nvl(implement_firm, org_firm_flag),
                load_type = 30,
                reschedule_flag = 1,
                release_status = 1,
                status = 0,
                applied =2,
                last_updated_by = fnd_global.user_id,
                release_errors = NULL
           where plan_id = p_plan_id
             and demand_id = p_transaction_id
             and sr_instance_id = p_inst_id;
END update_dmd_success;

BEGIN -- main procedure

-- front port bug 3466661
   IF g_instance_id.COUNT = 0 THEN
      SELECT instance_id,null
      BULK COLLECT INTO g_instance_id,g_job_prefix
      FROM msc_apps_instances;

      FOR i in 1..g_instance_id.COUNT LOOP
          BEGIN
              msc_rel_wf.get_profile_value(
                   p_profile_name   => 'WIP_JOB_PREFIX',
                   p_instance_id    => g_instance_id(i),
                   p_calling_source => 'PACKAGE',
                   p_profile_value  => g_job_prefix(i));
          EXCEPTION
           WHEN OTHERS THEN
              g_job_prefix(i) := null;
          END;
       END LOOP;
   END IF; -- IF g_instance_id.COUNT = 0 THEN

   p_error_rows := 0;
   p_succ_rows := 0;
   p_total_rows := 0;


   p_sql_stmt :=
       'select ' ||
         'plan_id, ' ||
         'transaction_id, ' ||
         'action, ' ||
         'cfm_routing_flag, ' ||
         'bom_item_type, ' ||
         'release_time_fence_code, ' ||
         'in_source_plan, ' ||
         'inventory_item_id, ' ||
         'build_in_wip_flag, ' ||
         'order_type, ' ||
         'source_organization_id, ' ||
         'organization_id, ' ||
         'purchasing_enabled_flag, ' ||
         'source_vendor_id, ' ||
         'planning_make_buy_code, ' ||
         'build_in_wip_flag, '||
    --     'effectivity_control, ' ||
         'planner_code, ' ||
         'sr_instance_id, ' ||
         'new_due_date, ' ||
         'project_id, ' ||
         'task_id, ' ||
         'unit_number, ' ||
         'lots_exist, '||
         'quantity_rate '||
         ' from '||msc_get_name.get_order_view(p_plan_type, p_plan_id) ||
         ' where ' || p_where_clause ||
         ' and order_type IN (1, 2, 3, 5, 13, 51, 53, 76,77,78)'||
         ' and source_table = ''MSC_SUPPLIES''' ||
         ' and nvl(release_time_fence_code,-1) <> 7' ||
    -- Shikyu items should not be processed
         ' and nvl(release_status,2) = 2';
         --pabram.srp.changes added 76,77,78

   p_drp_stmt :=
             'select ' ||
         'plan_id, ' ||
         'transaction_id, ' ||
         'action, ' ||
         'cfm_routing_flag, ' ||
         'bom_item_type, ' ||
         'release_time_fence_code, ' ||
         'in_source_plan, ' ||
         'inventory_item_id, ' ||
         'build_in_wip_flag, ' ||
         'order_type, ' ||
         'source_organization_id, ' ||
         'organization_id, ' ||
         'purchasing_enabled_flag, ' ||
         'source_vendor_id, ' ||
         'planning_make_buy_code, ' ||
         'build_in_wip_flag, '||
  'planner_code, ' ||
         'sr_instance_id, ' ||
         'new_due_date, ' ||
         'project_id, ' ||
         'task_id, ' ||
         'unit_number, ' ||
         'lots_exist, '||
         'quantity_rate '||
         ' from  MSC_ORDERS_DRP_V'||
         ' where ' || p_where_clause ||
         ' and (  (order_type IN (1, 2, 3, 5, 13, 51, 53, 76,77,78)'||
         ' and source_table = ''MSC_SUPPLIES'' ) ' ||
         ' OR (order_type  = 53  and source_table = ''MSC_DEMANDS'') ) ' ||
         ' and nvl(release_time_fence_code,-1) <> 7' ||
         ' and nvl(release_status,2) = 2';



  IF p_current_plan_type = 5 THEN  -- DRP
    OPEN selCur FOR p_drp_stmt;
  ELSE  -- for all other types of plans
    OPEN selCur FOR p_sql_stmt;
  END IF;

    LOOP
      FETCH selCur INTO p_plan_id,p_transaction_id,p_action,
                        p_cfm_routing_flag, p_bom_item_type,
                        p_release_time_fence_code, p_in_source_plan,
                        p_item_id, p_build_in_wip_flag, p_order_type,
                        p_source_org_id, p_org_id, p_purchasing_enabled_flag,
                        p_supplier_id,p_planning_make_buy_code,
                        p_build_in_wip_flag, -- p_effectivity_control,
                        p_planner_code, p_inst_id, p_due_date, p_project_id,
                        p_task_id, p_unit_number, p_lots_exist,
                        p_new_order_qty;
      begin
          select effectivity_control
          into p_effectivity_control
          from msc_system_items
          where plan_id = p_plan_id
          and sr_instance_id = p_inst_id
          and organization_id = p_org_id
          and inventory_item_id = p_item_id;
       exception
          when others then
             null;
       end;
      EXIT WHEN selCur%NOTFOUND;
       if p_plan_type is null then
           open Plan_type_c;
           fetch plan_type_c into p_plan_type;
           close plan_type_c;
        end if;
        if p_def_job_status is null then
           p_def_job_status:= msc_get_name.GET_preference(
                'ORDERS_DEFAULT_JOB_STATUS',
                msc_get_name.get_default_pref_id(fnd_global.user_id),
                p_plan_type);
           p_def_job_status := nvl(p_def_job_status, 1);
           p_wip_class_code := msc_get_name.GET_preference(
                'ORDERS_JOB_CLASS_CODE',
                msc_get_name.get_default_pref_id(fnd_global.user_id),
                p_plan_type);
        end if;

        verify_release_error;
        if p_rel_error is not null then
           update_sup_rel_error;
           p_error_rows := p_error_rows +1;
        else -- if p_rel_error is null then
           update_success_supplies;
           p_succ_rows := p_succ_rows +1;
        end if; --if p_rel_error is not null then
        p_total_rows := p_total_rows+1;
        reset_record;
    END LOOP;
    CLOSE selCur;

 if p_include_so = 'Y' then
        p_sql_stmt :=
         'SELECT ' ||
         'plan_id, ' ||
         'transaction_id, ' ||
         'sr_instance_id ' ||
         'from msc_orders_v mo' ||
         ' where ' || p_where_clause ||
         ' and nvl(release_status,2) = 2' ||
         ' and order_type = 30'||
         ' and source_table = ''MSC_DEMANDS'''||
         ' and exists (select 1 from msc_exception_details med ' ||
                        ' where med.plan_id = mo.plan_id ' ||
                        ' and med.exception_type = 70 ' ||
                        ' and med.organization_id = mo.organization_id '||
                        ' and med.sr_instance_id = mo.sr_instance_id '||
                        ' and med.inventory_item_id = mo.inventory_item_id '||
                        ' and med.number1 = mo.transaction_id) ';

    OPEN selCur FOR p_sql_stmt;
    LOOP
      FETCH selCur INTO p_plan_id,p_transaction_id, p_inst_id;
      EXIT WHEN selCur%NOTFOUND;
          p_mesg := null;
          p_mesg :=
             msc_rel_wf.verify_so_release(p_plan_id, p_transaction_id, p_inst_id);
          if p_mesg is not null then
             p_rel_error := FND_MESSAGE.GET_STRING('MSC',p_mesg);
             update_dmd_rel_error;
             p_error_rows := p_error_rows +1;
          else -- if l_mesg is null then
             p_succ_rows := p_succ_rows +1;
             update_dmd_success;
       end if; -- if l_mesg is not null then
       p_total_rows := p_total_rows+1;
       p_rel_error := null;
    END LOOP;
    CLOSE selCur;

 end if; -- if p_include_so = 'Y' then

END Update_Implement_Attrib;

FUNCTION child_supplies_onhand(p_plan_id number,
                                   p_transaction_id number) return number IS
   CURSOR child_supply_c is
     SELECT 1
     from msc_full_pegging mfp1,
          msc_full_pegging mfp2,
          msc_supplies ms
     where mfp1.plan_id = p_plan_id
      and mfp1.transaction_id = p_transaction_id
      and mfp2.plan_id = mfp1.plan_id
      and mfp2.prev_pegging_id = mfp1.pegging_id
      and ms.plan_id = mfp2.plan_id
      and ms.transaction_id = mfp2.transaction_id
      and ms.sr_instance_id = mfp2.sr_instance_id
      and (ms.order_type in (1,2,8,11,12) or -- purchased/transferred supply
            (ms.order_type = 5 and -- not make planned order
             nvl(ms.source_organization_id,-1) <> ms.organization_id));
    v_temp number;
BEGIN
          v_temp :=0;
          OPEN child_supply_c;
          FETCH child_supply_c INTO v_temp;
          CLOSE child_supply_c;

          return v_temp;
END child_supplies_onhand;

END MSC_SELECT_ALL_FOR_RELEASE_PUB;

/
