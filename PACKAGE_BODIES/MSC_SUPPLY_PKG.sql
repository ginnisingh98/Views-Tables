--------------------------------------------------------
--  DDL for Package Body MSC_SUPPLY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SUPPLY_PKG" as
/* $Header: MSCHBSUB.pls 120.28.12010000.10 2010/03/03 23:38:00 wexia ship $ */
/*
create table msc_supplies_f (
    plan_id  number not null,
    plan_run_id   number not null,
    sr_instance_id  number not null,
    organization_id number not null,
    inventory_item_id number not null,
    project_id number,
    task_id number,
    supplier_id number,
    supplier_site_id number,
    supply_date date,
    supply_type number,
    supply_qty number,
    Planned_order_cnt number,
    Planned_order_itf_cnt number,
    Planned_order_gmod_cnt number,
    Planned_order_bwo_cnt number
    )

create index msc_supply_f_n1 on msc_supplies_f(plan_id,plan_run_id,sr_instance_id,
                        organization_id,inventory_item_id,
                        supply_date,supply_type);
create index msc_supply_f_n2 on msc_supplies_f(project_id,task_id);
create index msc_supply_f_n3 on msc_supplies_f(supplier_id,supplier_site_id);
*/


procedure populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number default null) is

    l_api_name varchar2(100);
    l_stmt_id number ;
    l_sysdate date;
    l_user_id number;
    l_user_login_id number;
    l_cp_login_id number;
    l_program_id number;
    l_appl_id number;
    l_request_id number;
    l_qid_vmi number;
    l_plan_start_date date;
    l_plan_cutoff_date date;
    l_plan_type number;
    l_sr_instance_id number;
    l_refresh_mode  number;
    l_res_item_qid  number;
    con_ods_plan_id constant number := -1;
    l_rowcount1 number := 0;
    l_rowcount2 number := 0;
begin

    msc_phub_util.log('msc_supply_pkg.populate_details');
   retcode :=0;    -- this means successfully
   errbuf :='';

   -- ODS plan
   if  p_plan_id = con_ods_plan_id
   then
        -- get refresh_mode
        select refresh_mode into l_refresh_mode
        from msc_plan_runs
        where plan_run_id = p_plan_run_id;

        if l_refresh_mode = 2 -- targeted refesh
        then
            l_res_item_qid := msc_phub_util.get_item_rn_qid(p_plan_id, p_plan_run_id);

            delete from msc_supplies_f
            where  plan_id = p_plan_id
                and plan_run_id = p_plan_run_id
                and (p_plan_id, sr_instance_id, organization_id, inventory_item_id) in
                    (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid);

            l_rowcount1 := l_rowcount1 + sql%rowcount;
            msc_phub_util.log('msc_supplies_f, delete='||sql%rowcount||', l_rowcount1='||l_rowcount1);
            commit;

            delete from msc_item_wips_f
            where  plan_id = p_plan_id
                and plan_run_id = p_plan_run_id
                and (p_plan_id, sr_instance_id, organization_id, inventory_item_id) in
                    (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid);

            l_rowcount2 := l_rowcount2 + sql%rowcount;
            msc_phub_util.log('msc_item_wips_f, delete='||sql%rowcount||', l_rowcount2='||l_rowcount2);
            commit;
        end if;
   end if;

   --  Successfully populated msc_supplies_f table for plan_id =' || p_plan_id || ',plan_run_id=' || p_plan_run_id;
   -- initial there is no error message
   l_api_name := 'msc_supply_f_pkg.populate_details';

   l_user_id := fnd_global.user_id;
   l_sysdate :=sysdate;
   l_user_login_id :=fnd_global.login_id;
   l_cp_login_id :=FND_GLOBAL.CONC_LOGIN_ID;
   l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
   l_appl_id := FND_GLOBAL.PROG_APPL_ID;
   l_request_id := FND_GLOBAL.CONC_REQUEST_ID;

    l_stmt_id :=5;
    select plan_type, sr_instance_id
    into l_plan_type, l_sr_instance_id
    from msc_plan_runs
    where plan_id=p_plan_id
    and plan_run_id=p_plan_run_id;

    select trunc(plan_start_date), trunc(plan_cutoff_date)
    into l_plan_start_date, l_plan_cutoff_date
    from msc_plan_runs
    where plan_run_id = p_plan_run_id;


  l_stmt_id :=10;
----------------------------------------------------

  select msc_hub_query_s.nextval into l_qid_vmi      from dual;

   insert into msc_hub_query(
    query_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    number1,    -- plan_id
    number3,    -- sr_instance_id
    number4,    -- organization_id
    number5,        -- inventory_item_id
    number10    -- vmi flag
    )
    select
    unique l_qid_vmi,l_sysdate,1,l_sysdate,1,1,
    p_plan_id,
    msi.sr_instance_id,
    msi.organization_id,
    msi.inventory_item_id,
    nvl(mis.vmi_flag,0)
    from msc_item_suppliers mis,
     msc_system_items msi
    where msi.plan_id = mis.plan_id
    and msi.sr_instance_id = mis.sr_instance_id
    and msi.organization_id = mis.organization_id
    and msi.inventory_item_id = mis.inventory_item_id
    and msi.plan_id=p_plan_id
    and nvl(mis.vmi_flag,0)=1;


    msc_phub_util.log(l_stmt_id||', l_qid_vmi='||l_qid_vmi||', count='||sql%rowcount);
   commit;


   l_stmt_id :=20;
   ----------------------------------------------------
  Insert into msc_supplies_f (
        created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    REQUEST_ID,
-----------------------------------------------------
    plan_id, -- plan_id
    plan_run_id,
    io_plan_flag,   --- this flag indidate whether it is an io plan
    sr_instance_id,
    organization_id,
    owning_inst_id,
    owning_org_id,
    source_org_instance_id,
    source_organization_id,
    inventory_item_id,
    project_id,
    task_id,
    supplier_id,
    supplier_site_id,
    region_id,
    customer_region_id,
    ship_method,
    part_condition,
    supply_date,
    aggr_type, category_set_id, sr_category_id,
    supply_type,
    vmi_flag,
    supply_qty,
    Planned_order_count,
    work_order_leadtime, --- for work order (work order, planned work order)
    work_order_count,
    work_order_qty,
    stockout_days, -- this is for vmi measure 'stockout day'
    supply_volume,
    drp_supply_as_demand,
    return_order_qty,
    return_fcst
    )
   select
    l_user_id,
    l_sysdate,
    l_user_id,
    l_sysdate,
    l_user_login_id,
    l_program_id,
    l_cp_login_id,
    l_appl_id,
    l_request_id,
----------------------------------------------
    p_plan_id, -- plan_id
    p_plan_run_id, -- plan_run_id,
    decode(l_plan_type,4,1,9,1,0)  io_plan_flag,
    supply_tbl.sr_instance_id,
    supply_tbl.organization_id,
    supply_tbl.owning_inst_id,
    supply_tbl.owning_org_id,
    supply_tbl.source_org_instance_id,
    supply_tbl.source_organization_id,
    supply_tbl.inventory_item_id,
    supply_tbl.project_id,
    supply_tbl.task_id,
    supply_tbl.supplier_id,
    supply_tbl.supplier_site_id,
    mps.region_id,
    supply_tbl.customer_region_id,
    --- if supply_date <l_plan_start_date, supply_date =l_plan_start_date-1
    --- else if supply_date>l_curr_cutoff_date, supply_date=l_curr_cutoff_date+1
    --- else supply_date
    --- we can not simply put it at plan start date,
    --- should be at the last working day of the bucket where plan start date is

    supply_tbl.ship_method,
    supply_tbl.part_condition,
    decode(sign(to_number(supply_tbl.supply_date-l_plan_start_date)),
        -1, msc_hub_calendar.last_work_date(p_plan_id,l_plan_start_date),
        decode(supply_tbl.supply_type,
            18, msc_hub_calendar.last_work_date(p_plan_id,supply_tbl.supply_date),
            supply_tbl.supply_date)),
    to_number(0) aggr_type,
    to_number(-23453) category_set_id,
    to_number(-23453) sr_category_id,
    supply_tbl.supply_type,
    nvl(vmi.number10,0) vmi_flag,
    sum(supply_tbl.supply_qty),
    sum(supply_tbl.Planned_order_count),
    sum(supply_tbl.work_order_leadtime),
    sum(supply_tbl.work_order_count),
    sum(supply_tbl.work_order_qty),
    sum(supply_tbl.stockout_days),
    sum(supply_tbl.supply_volume),
    sum(supply_tbl.drp_supply_as_demand),
    sum(supply_tbl.return_order_qty),
    sum(supply_tbl.return_fcst)

    from
       (select
       decode(sign(ms.organization_id), -1, -23453, ms.sr_instance_id) sr_instance_id,
       decode(sign(ms.organization_id), -1, -23453, ms.organization_id) organization_id,
        decode(sign(ms.sr_instance_id), -1, l_sr_instance_id, ms.sr_instance_id) owning_inst_id,
        decode(sign(ms.organization_id), -1, msc_hub_calendar.get_item_org(p_plan_id, ms.inventory_item_id,
            decode(sign(ms.sr_instance_id), -1, l_sr_instance_id, ms.sr_instance_id)),
            ms.organization_id) owning_org_id,
       decode(ms.source_sr_instance_id,null,-23453,0,-23453,ms.source_sr_instance_id) source_org_instance_id,
       decode(ms.source_organization_id,null,-23453,0,-23453,ms.source_organization_id)  source_organization_id,
       ms.inventory_item_id,
       nvl(ms.project_id,-23453) project_id,
       nvl(ms.task_id,-23453)  task_id,
       nvl(ms.supplier_id,-23453)  supplier_id,
       nvl(ms.supplier_site_id,-23453) supplier_site_id,
       decode(l_plan_type, 8, nvl(ms.zone_id,-23453), -23453) customer_region_id,
       nvl(ms.ship_method, '-23453') ship_method,
       nvl(ms.item_type_value,1) part_condition,
       trunc(nvl(ms.firm_date,ms.new_schedule_date)) supply_date,
       ms.order_type supply_type,

       sum(decode(msi.base_item_id,null,
          decode(ms.disposition_status_type,2, 0,
        decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
          decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) )) supply_qty,

      sum(decode(ms.order_type,5,
         decode(msi.base_item_id,null,
           decode(ms.disposition_status_type, 2, 0,1),1),to_number(null))) Planned_order_count,


    ---------------------------------------------------------------------------
    --- ??? exclude if new_schedule_date is null
    --- decode(nvl(ms.source_organization_id, ms.organization_id),
        --           ms.organization_id,
        --         PLANNED_MAKE_OFF,
        --       PLANNED_BUY_OFF)
    -- make order 3,7,14,15,27,28,
    -- 4,13 ?? do we need to include Repetitive schdule as make order??
    -- make planned order
    -- 3,4,5,7,13,14,15,16,17,27,28,30
    ---------------------------------------------------------------------------
    sum(decode(ms.order_type,3, nvl(ms.new_schedule_date,null)-nvl(ms.new_wip_start_date,null),
            5,decode(msc_supply_pkg.implement_code(ms.source_organization_id,ms.organization_id,
                            msi.repetitive_type,ms.source_supplier_id,
                        msi.planning_make_buy_code,msi.build_in_wip_flag),
               3,nvl(ms.new_schedule_date,null)-nvl(ms.new_wip_start_date,null),
               4,nvl(ms.new_schedule_date,null)- nvl(ms.first_unit_start_date,null),
               0),
            7,nvl(ms.new_schedule_date,null)-nvl(ms.new_wip_start_date,null),
            14,nvl(ms.new_schedule_date,null)-nvl(ms.new_wip_start_date,null),
            15,nvl(ms.new_schedule_date,null)-nvl(ms.new_wip_start_date,null),
            27,nvl(ms.new_schedule_date,null)-nvl(ms.new_wip_start_date,null),
            28,nvl(ms.new_schedule_date,null)-nvl(ms.new_wip_start_date,null),
            4,nvl(ms.new_schedule_date,null)- nvl(ms.first_unit_start_date,null),
            13,nvl(ms.new_schedule_date,null)- nvl(ms.first_unit_start_date,null),
            16,nvl(ms.new_schedule_date,null)- nvl(ms.first_unit_start_date,null),
            17,nvl(ms.new_schedule_date,null)-nvl(ms.new_wip_start_date,null),
            30,nvl(ms.new_schedule_date,null)- nvl(ms.first_unit_start_date,null),
            88,nvl(ms.new_schedule_date,null)- nvl(ms.first_unit_start_date,null),
            to_number(null))) work_order_leadtime,

    sum(decode(ms.order_type,3,1,
          5,decode(msc_supply_pkg.implement_code(ms.source_organization_id,ms.organization_id,
                            msi.repetitive_type,ms.source_supplier_id,
                        msi.planning_make_buy_code,msi.build_in_wip_flag),
              3,1,0),
          7,1,
          14,1,
          15,1,
          27,1,
          28,1,
          4,1,
          13,1,
          16,1,
          17,1,
          30,1,
          88,1,
          to_number(null))) work_order_count,
    sum(decode(ms.order_type,
                           3, decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                   5, decode(msc_supply_pkg.implement_code(ms.source_organization_id,ms.organization_id,
                            msi.repetitive_type,ms.source_supplier_id,
                        msi.planning_make_buy_code,msi.build_in_wip_flag),
                  3,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                  4,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                  0),
                7,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                14,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                15,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                27,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                28,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                4,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                13,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                16,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                17,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                30,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                88,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                to_number(null))) work_order_qty,

     --- order_type in (1,2,18) and nvl(item_type_id,401) = 401 and nvl(item_type_value,1) = 2

     sum(decode(l_plan_type,8,
                         decode(ms.order_type,1,decode(nvl(item_type_id,401),401,
                                                       decode(nvl(item_type_value,1),
                                      2,decode(msi.base_item_id,null,
                                    decode(ms.disposition_status_type,2, 0,
                                                decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                                                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                                      0),
                                    0),
                                 2,decode(nvl(item_type_id,401),401,
                                                       decode(nvl(item_type_value,1),
                                      2,decode(msi.base_item_id,null,
                                    decode(ms.disposition_status_type,2, 0,
                                                decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                                                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                                      0),
                                    0),
                          18,decode(nvl(item_type_id,401),401,
                                                       decode(nvl(item_type_value,1),
                                      2,decode(msi.base_item_id,null,
                                    decode(ms.disposition_status_type,2, 0,
                                                decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                                                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                                      0),
                                    0),
                        0),
              9,
                  decode(ms.order_type,1,decode(nvl(item_type_id,401),401,
                                                       decode(nvl(item_type_value,1),
                                      2,decode(msi.base_item_id,null,
                                    decode(ms.disposition_status_type,2, 0,
                                                decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                                                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                                      0),
                                    0),
                                 2,decode(nvl(item_type_id,401),401,
                                                       decode(nvl(item_type_value,1),
                                      2,decode(msi.base_item_id,null,
                                    decode(ms.disposition_status_type,2, 0,
                                                decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                                                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                                      0),
                                    0),
                          18,decode(nvl(item_type_id,401),401,
                                                       decode(nvl(item_type_value,1),
                                      2,decode(msi.base_item_id,null,
                                    decode(ms.disposition_status_type,2, 0,
                                                decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                                                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                                      0),
                                    0),
                        0),
             0)) return_order_qty,

      sum(decode(ms.order_type,81,ms.new_order_quantity,0)) return_fcst,
      to_number(null) drp_supply_as_demand,


      to_number(null) stockout_days,
      sum(case when ms.order_type=5 and nvl(ms.source_organization_id,-23453)<>ms.organization_id then ms.new_order_quantity
        when ms.order_type in (1,2,8,51,53,76,80,87) then ms.new_order_quantity else null end) supply_volume

    from
       msc_supplies ms,
       msc_system_items msi
    where ms.plan_id = msi.plan_id
    and   decode(sign(ms.sr_instance_id), -1, l_sr_instance_id, ms.sr_instance_id) = msi.sr_instance_id
    and   decode(sign(ms.organization_id), -1, msc_hub_calendar.get_item_org(p_plan_id, ms.inventory_item_id,
        decode(sign(ms.sr_instance_id), -1, l_sr_instance_id, ms.sr_instance_id)),
        ms.organization_id) = msi.organization_id
    and   ms.inventory_item_id = msi.inventory_item_id
    and ms.plan_id=p_plan_id
    and not (l_plan_type=8 and ms.order_type in (2,3)) -- bug 9123354
    and (p_plan_id <> con_ods_plan_id
      or ( p_plan_id = con_ods_plan_id
        and ms.sr_instance_id = l_sr_instance_id
        and (l_refresh_mode = 1
             or (l_refresh_mode = 2 and (p_plan_id, ms.sr_instance_id, ms.organization_id, ms.inventory_item_id) in
                   (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid) ) )
        and trunc(nvl(ms.firm_date,ms.new_schedule_date)) between l_plan_start_date and l_plan_cutoff_date
      )
    )
    group by
        decode(sign(ms.organization_id), -1, -23453, ms.sr_instance_id),
        decode(sign(ms.organization_id), -1, -23453, ms.organization_id),
        decode(sign(ms.sr_instance_id), -1, l_sr_instance_id, ms.sr_instance_id),
        decode(sign(ms.organization_id), -1, msc_hub_calendar.get_item_org(p_plan_id, ms.inventory_item_id,
            decode(sign(ms.sr_instance_id), -1, l_sr_instance_id, ms.sr_instance_id)),
            ms.organization_id),
        decode(ms.source_sr_instance_id,null,-23453,0,-23453,ms.source_sr_instance_id),
        decode(ms.source_organization_id,null,-23453,0,-23453,ms.source_organization_id),
        ms.inventory_item_id,
        nvl(ms.project_id,-23453),
        nvl(ms.task_id,-23453),
        nvl(ms.supplier_id,-23453),
        nvl(ms.supplier_site_id,-23453),
        decode(l_plan_type, 8, nvl(ms.zone_id,-23453), -23453),
        nvl(ms.ship_method, '-23453'),
        nvl(ms.item_type_value,1),
        trunc(nvl(ms.firm_date,ms.new_schedule_date)),
        ms.order_type

    union all
    select
        decode(sign(med.organization_id), -1, -23453, med.sr_instance_id) sr_instance_id,
        decode(sign(med.organization_id), -1, -23453, med.organization_id) organization_id,
        decode(sign(med.sr_instance_id), -1, l_sr_instance_id, med.sr_instance_id) owning_inst_id,
        decode(sign(med.organization_id), -1, msc_hub_calendar.get_item_org(p_plan_id, med.inventory_item_id,
            decode(sign(med.sr_instance_id), -1, l_sr_instance_id, med.sr_instance_id)),
            med.organization_id) owning_org_id,
        -23453 source_org_instance_id,
        -23453 source_organization_id,
        med.inventory_item_id,
        -23453 project_id,
        -23453 task_id,
        nvl(med.supplier_id, -23453)  supplier_id,
        nvl(med.supplier_site_id, -23453) supplier_id,
        decode(l_plan_type, 8, nvl(med.zone_id,-23453), -23453) customer_region_id,
        '-23453' ship_method,
        -23453 part_condition,
        trunc(med.date1) supply_date,  -- exception date
        -23453 supply_type,
        -----------------------------------------------------------------------
        to_number(null)  supply_qty,
        to_number(null) Planned_order_count,
        to_number(null) work_order_leadtime,
        to_number(null) work_order_count,
        to_number(null) work_order_qty,
        to_number(null) return_order_qty,
        to_number(null) return_fcst,
        to_number(null) drp_supply_as_demand,
        sum(med.date2 - med.date1) stockout_days,     --- should be to_date - from_date
        -- may get from msc_exception_f if this has performance issue
        -- table from_date - to_date
        to_number(null) supply_volume
    from msc_exception_details med
    where med.exception_type =2
         and med.plan_id = p_plan_id
         and p_plan_id <> con_ods_plan_id
    group by
        decode(sign(med.organization_id), -1, -23453, med.sr_instance_id),
        decode(sign(med.organization_id), -1, -23453, med.organization_id),
        decode(sign(med.sr_instance_id), -1, l_sr_instance_id, med.sr_instance_id),
        decode(sign(med.organization_id), -1, msc_hub_calendar.get_item_org(p_plan_id, med.inventory_item_id,
            decode(sign(med.sr_instance_id), -1, l_sr_instance_id, med.sr_instance_id)),
            med.organization_id),
       med.inventory_item_id,
       nvl(med.supplier_id, -23453),
       nvl(med.supplier_site_id, -23453),
       decode(l_plan_type, 8, nvl(med.zone_id,-23453), -23453),
       trunc(med.date1)

    union all
    select
       ms2.sr_instance_id,
       decode(ms2.source_organization_id,null,-23453,0,-23453,ms2.source_organization_id) organization_id,
        decode(sign(ms2.sr_instance_id), -1, l_sr_instance_id, ms2.sr_instance_id) owning_inst_id,
        decode(sign(ms2.organization_id), -1, msc_hub_calendar.get_item_org(p_plan_id, ms2.inventory_item_id,
            decode(sign(ms2.sr_instance_id), -1, l_sr_instance_id, ms2.sr_instance_id)),
            ms2.organization_id) owning_org_id,
       decode(ms2.source_sr_instance_id,null,-23453,0,-23453,ms2.source_sr_instance_id) source_org_instance_id,
       decode(ms2.source_organization_id,null,-23453,0,-23453,ms2.source_organization_id) source_organization_id,
       ms2.inventory_item_id,
       nvl(ms2.project_id,-23453) project_id,
       nvl(ms2.task_id,-23453)  task_id,
       nvl(ms2.supplier_id,-23453)  supplier_id,
       nvl(ms2.supplier_site_id,-23453) supplier_site_id,
       -23453 customer_region_id,
       nvl(ms2.ship_method, '-23453') ship_method,
       nvl(ms2.item_type_value,1) part_condition,
       trunc(nvl(ms2.firm_date,ms2.new_schedule_date)) supply_date,
       ms2.order_type supply_type,

       -----------------------------------------------------------------------
       to_number(null)  supply_qty,
       to_number(null) Planned_order_count,
       to_number(null) work_order_leadtime,
       to_number(null) work_order_count,
       to_number(null) work_order_qty,
       to_number(null) return_order_qty,
       to_number(null) return_fcst,


    /*  ms.source_organization_id <> ms.organization_id
         and     (ms.order_type <> PURCH_REQ or
         (ms.order_type = PURCH_REQ and ms.supplier_id is not null))*/


        sum(decode(l_plan_type,5,decode(ms2.order_type,1,
                    decode(ms2.organization_id,ms2.source_organization_id,0,
                      decode(msi2.base_item_id,null,
                        decode(ms2.disposition_status_type,2, 0,
                        decode(ms2.last_unit_completion_date,null, ms2.new_order_quantity,ms2.daily_rate) ),
                        decode(ms2.last_unit_completion_date,null, ms2.new_order_quantity,ms2.daily_rate) )),
                       51,decode(ms2.organization_id, ms2.source_organization_id,0,
                          decode(msi2.base_item_id,null,
                        decode(ms2.disposition_status_type,2, 0,
                        decode(ms2.last_unit_completion_date,null, ms2.new_order_quantity,ms2.daily_rate) ),
                        decode(ms2.last_unit_completion_date,null, ms2.new_order_quantity,ms2.daily_rate) )),
                       2,decode(ms2.supplier_id,null,0,
                           decode(ms2.organization_id, ms2.source_organization_id,0,
                          decode(msi2.base_item_id,null,
                        decode(ms2.disposition_status_type,2, 0,
                        decode(ms2.last_unit_completion_date,null, ms2.new_order_quantity,ms2.daily_rate) ),
                        decode(ms2.last_unit_completion_date,null, ms2.new_order_quantity,ms2.daily_rate) ))),
                      0),0)) drp_supply_as_demand,
        to_number(null) stockout_days,
        to_number(null) supply_volume
        from
            msc_supplies ms2,
            msc_system_items msi2
    where ms2.plan_id = msi2.plan_id
    and   decode(sign(ms2.sr_instance_id), -1, l_sr_instance_id, ms2.sr_instance_id) = msi2.sr_instance_id
    and   decode(sign(ms2.organization_id), -1, msc_hub_calendar.get_item_org(p_plan_id, ms2.inventory_item_id,
            decode(sign(ms2.sr_instance_id), -1, l_sr_instance_id, ms2.sr_instance_id)),
            ms2.organization_id) = msi2.organization_id
    and   ms2.inventory_item_id = msi2.inventory_item_id
    and ms2.plan_id=p_plan_id
    and ms2.order_type in (1,2,51)
    and p_plan_id <> con_ods_plan_id
    group by
        ms2.sr_instance_id,
        decode(ms2.source_organization_id,null,-23453,0,-23453,ms2.source_organization_id),
        decode(sign(ms2.sr_instance_id), -1, l_sr_instance_id, ms2.sr_instance_id),
        decode(sign(ms2.organization_id), -1, msc_hub_calendar.get_item_org(p_plan_id, ms2.inventory_item_id,
            decode(sign(ms2.sr_instance_id), -1, l_sr_instance_id, ms2.sr_instance_id)),
            ms2.organization_id),
        decode(ms2.source_sr_instance_id,null,-23453,0,-23453,ms2.source_sr_instance_id),
        ms2.inventory_item_id,
        nvl(ms2.project_id,-23453),
        nvl(ms2.task_id,-23453),
        nvl(ms2.supplier_id,-23453),
        nvl(ms2.supplier_site_id,-23453),
        nvl(ms2.ship_method, '-23453'),
        nvl(ms2.item_type_value,1),
        trunc(nvl(ms2.firm_date,ms2.new_schedule_date)),
        ms2.order_type
    ) supply_tbl,
    msc_phub_suppliers_mv mps,
    msc_hub_query vmi
    where mps.supplier_id = supply_tbl.supplier_id
        and mps.supplier_site_id = supply_tbl.supplier_site_id
        and (supply_tbl.supplier_id<>-23453 or mps.region_id=-23453)
        and vmi.query_id(+)=l_qid_vmi
        and vmi.number1(+)=p_plan_id
        and vmi.number3(+)=supply_tbl.sr_instance_id
        and vmi.number4(+)=supply_tbl.organization_id
        and vmi.number5(+)=supply_tbl.inventory_item_id
    group by
        decode(l_plan_type,4,1,9,1,0),
        supply_tbl.sr_instance_id,
        supply_tbl.organization_id,
        supply_tbl.owning_inst_id,
        supply_tbl.owning_org_id,
        supply_tbl.source_org_instance_id,
        supply_tbl.source_organization_id,
        supply_tbl.inventory_item_id,
        supply_tbl.project_id,
        supply_tbl.task_id,
        supply_tbl.supplier_id,
        supply_tbl.supplier_site_id,
        mps.region_id,
        supply_tbl.customer_region_id,
        supply_tbl.ship_method,
        supply_tbl.part_condition,
        decode(sign(to_number(supply_tbl.supply_date-l_plan_start_date)),
            -1, msc_hub_calendar.last_work_date(p_plan_id,l_plan_start_date),
            decode(supply_tbl.supply_type,
                18, msc_hub_calendar.last_work_date(p_plan_id,supply_tbl.supply_date),
                supply_tbl.supply_date)),
        supply_tbl.supply_type,
        nvl(vmi.number10,0);

    l_rowcount1 := l_rowcount1 + sql%rowcount;
    msc_phub_util.log('msc_supplies_f, insert='||sql%rowcount||', l_rowcount1='||l_rowcount1);
    commit;


--- populate wip start qty
--- msc_item_wip_f
---

 l_stmt_id:=30;
 Insert into msc_item_wips_f (
        created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    REQUEST_ID,
-----------------------------------------------------
    plan_id, -- plan_id
    plan_run_id,
    sr_instance_id,
    organization_id,
    inventory_item_id,
    vmi_flag,
    wip_start_date,
    aggr_type, category_set_id, sr_category_id,
    wip_qty
    )
   select
    l_user_id,
    l_sysdate,
    l_user_id,
    l_sysdate,
        l_user_login_id,
    l_program_id,
    l_cp_login_id,
    l_appl_id,
    l_request_id,
----------------------------------------------
    p_plan_id,          -- plan_id
    p_plan_run_id,          -- plan_run_id,
        wip_tbl.sr_instance_id,
    wip_tbl.organization_id,
    wip_tbl.inventory_item_id,
    wip_tbl.vmi_flag,
    decode(sign(to_number(wip_tbl.wip_start_date-l_plan_start_date)),-1,l_plan_start_date,wip_tbl.wip_start_date),
    to_number(0) aggr_type,
    to_number(-23453) category_set_id,
    to_number(-23453) sr_category_id,
    sum(wip_tbl.wip_qty)
    from
       (select
       ms.sr_instance_id,
       ms.organization_id,
       ms.inventory_item_id,
       msi.vmi_flag,
       trunc(nvl(nvl(ms.new_wip_start_date,ms.first_unit_start_date),l_plan_start_date)) wip_start_date,
    -- make order 3,7,14,15,27,28,
    -- 4,13 ?? do we need to include Repetitive schdule as make order??
    -- make planned order
    ---------------------------------------------------------------------------
    sum(decode(ms.order_type,
                           3, decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                   5, decode(msc_supply_pkg.implement_code(ms.source_organization_id,ms.organization_id,
                            msi.repetitive_type,ms.source_supplier_id,
                        msi.planning_make_buy_code,msi.build_in_wip_flag),
                  3,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                  4,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                  0),
                7,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                14,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                15,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                27,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                28,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                4,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                13,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                16,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                17,decode(msc_supply_pkg.implement_code(ms.source_organization_id,ms.organization_id,
                            msi.repetitive_type,ms.source_supplier_id,
                        msi.planning_make_buy_code,msi.build_in_wip_flag),
                  3,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                  4,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                  0),
                30,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                88,decode(msi.base_item_id,null,
                    decode(ms.disposition_status_type,2, 0,
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                    decode(ms.last_unit_completion_date,null, ms.new_order_quantity,ms.daily_rate) ),
                to_number(null))) wip_qty
    from
       msc_supplies ms,
       ( select msi_1.plan_id,
            msi_1.sr_instance_id,
            msi_1.organization_id,
            msi_1.inventory_item_id,
            msi_1.base_item_id,
            msi_1.repetitive_type,
            msi_1.planning_make_buy_code,
            msi_1.build_in_wip_flag,
            nvl(f_1.number10,0) vmi_flag
         from msc_system_items msi_1,
          msc_hub_query f_1
         where f_1.query_id(+) = l_qid_vmi
         and   f_1.number1(+) = msi_1.plan_id
         and   f_1.number3(+) = msi_1.sr_instance_id
         and   f_1.number4(+) = msi_1.organization_id
         and   f_1.number5(+) = msi_1.inventory_item_id) msi
    where ms.plan_id = msi.plan_id
    and   ms.sr_instance_id = msi.sr_instance_id
    and   ms.organization_id =msi.organization_id
    and   ms.inventory_item_id = msi.inventory_item_id
    and ms.plan_id=p_plan_id
    and l_plan_type not in (4,9)  --- exclude io plan
    and (p_plan_id <> con_ods_plan_id
      or ( p_plan_id = con_ods_plan_id
        and ms.sr_instance_id = l_sr_instance_id
        and (l_refresh_mode = 1
             or (l_refresh_mode = 2 and (p_plan_id, ms.sr_instance_id, ms.organization_id, ms.inventory_item_id) in
                   (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid) ) )
        and trunc(nvl(nvl(ms.new_wip_start_date,ms.first_unit_start_date),l_plan_start_date)) between l_plan_start_date and l_plan_cutoff_date
      )
    )
    group by
    ms.sr_instance_id,
    ms.organization_id,
    ms.inventory_item_id,
    msi.vmi_flag,
    trunc(nvl(nvl(ms.new_wip_start_date,ms.first_unit_start_date),l_plan_start_date))  ) wip_tbl
--    where l_plan_type <> 6
    group by
    l_user_id,
    l_sysdate,
    l_user_id,
    l_sysdate,
        l_user_login_id,
    l_program_id,
    l_cp_login_id,
    l_appl_id,
    l_request_id,
-----------------------------------------------
    p_plan_id, -- plan_id
    p_plan_run_id, -- plan_run_id,
        wip_tbl.sr_instance_id,
    wip_tbl.organization_id,
    wip_tbl.inventory_item_id,
    wip_tbl.vmi_flag,
    decode(sign(to_number(wip_tbl.wip_start_date-l_plan_start_date)),-1,l_plan_start_date,wip_tbl.wip_start_date);

    l_rowcount2 := l_rowcount2 + sql%rowcount;
    msc_phub_util.log('msc_item_wips_f, insert='||sql%rowcount||', l_rowcount2='||l_rowcount2);
    commit;

    if (l_rowcount1 > 0) then
        summarize_supplies_f(errbuf, retcode, p_plan_id, p_plan_run_id);
    end if;

    if (l_rowcount2 > 0) then
        summarize_item_wips_f(errbuf, retcode, p_plan_id, p_plan_run_id);
    end if;

    msc_phub_util.log('msc_supply_pkg.populate_details: complete');

  exception
    when no_data_found then
        retcode :=2;
        errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_DUPLICATE_DATA')||SQLCODE||' -ERROR- '||sqlerrm;
        msc_phub_util.log('msc_supply_pkg.populate_details.exception: '||errbuf);


     when dup_val_on_index then
        retcode :=2;
        errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_DUPLICATE_DATA')||SQLCODE||' -ERROR- '||sqlerrm;
        msc_phub_util.log('msc_supply_pkg.populate_details.exception: '||errbuf);

    when others then
        retcode :=2;
        errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_POPULATE_ERROR')||SQLCODE||' -ERROR- '||sqlerrm;
        msc_phub_util.log('msc_supply_pkg.populate_details.exception: '||errbuf);


end populate_details;


function implement_code (p_source_org_id in number,
             p_org_id in number,
             p_repetitive_type in number,
             p_source_supplier_id in number,
             p_planning_make_buy_code in number,
             p_build_in_wip_flag in number) return number is

begin

if (p_source_org_id is NULL) and (p_source_supplier_id is null) THEN
    if (p_planning_make_buy_code = 1) and (p_build_in_wip_flag= 1) THEN
       return 3;
     else
       return 2;
     end if;
elsif (p_org_id = p_source_org_id ) then
     if (p_repetitive_type=2) then return 4;
     elsif (p_build_in_wip_flag=1) then return 3;
     else return 3;
     end if;
  elsif (p_source_org_id <>p_org_id ) then return 2;
  else return 2;
  end if;
end implement_code;


    procedure summarize_supplies_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_category_set_id1 number := fnd_profile.value('MSC_HUB_CAT_SET_ID_1');
    begin
        msc_phub_util.log('msc_supply_pkg.summarize_supplies_f');
        retcode := 0;
        errbuf := '';

        delete from msc_supplies_f
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id and aggr_type>0;
        msc_phub_util.log('msc_supply_pkg.summarize_supplies_f, delete='||sql%rowcount);
        commit;

        -- level 1
        insert into msc_supplies_f (
            plan_id, plan_run_id, io_plan_flag,
            sr_instance_id, organization_id, inventory_item_id,
            owning_inst_id, owning_org_id,
            source_org_instance_id, source_organization_id,
            project_id, task_id,
            supplier_id, supplier_site_id, region_id,
            ship_method, customer_region_id,
            part_condition,
            supply_date,
            aggr_type, category_set_id, sr_category_id,
            supply_type, vmi_flag,
            supply_qty,
            planned_order_count,
            work_order_leadtime,
            work_order_count,
            work_order_qty,
            stockout_days,
            supply_volume,
            drp_supply_as_demand,
            return_order_qty,
            return_fcst,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category (42, 43, 44)
        select
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id,
            to_number(-23453) inventory_item_id,
            f.owning_inst_id, f.owning_org_id,
            f.source_org_instance_id, f.source_organization_id,
            f.project_id, f.task_id,
            f.supplier_id, f.supplier_site_id, f.region_id,
            f.ship_method, f.customer_region_id,
            f.part_condition,
            f.supply_date,
            to_number(42) aggr_type,
            l_category_set_id1 category_set_id,
            nvl(q.sr_category_id, -23453),
            f.supply_type, f.vmi_flag,
            sum(f.supply_qty),
            sum(f.planned_order_count),
            sum(f.work_order_leadtime),
            sum(f.work_order_count),
            sum(f.work_order_qty),
            sum(f.stockout_days),
            sum(f.supply_volume),
            sum(f.drp_supply_as_demand),
            sum(f.return_order_qty),
            sum(f.return_fcst),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_supplies_f f,
            msc_phub_item_categories_mv q
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
            and f.owning_inst_id=q.sr_instance_id(+)
            and f.owning_org_id=q.organization_id(+)
            and f.inventory_item_id=q.inventory_item_id(+)
            and q.category_set_id(+)=l_category_set_id1
        group by
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id,
            f.owning_inst_id, f.owning_org_id,
            f.source_org_instance_id, f.source_organization_id,
            f.project_id, f.task_id,
            f.supplier_id, f.supplier_site_id, f.region_id,
            f.ship_method, f.customer_region_id,
            f.part_condition,
            f.supply_date,
            nvl(q.sr_category_id, -23453),
            f.supply_type, f.vmi_flag;

        msc_phub_util.log('msc_supply_pkg.summarize_supplies_f, level1='||sql%rowcount);
        commit;

        -- level 2
        insert into msc_supplies_f (
            plan_id, plan_run_id, io_plan_flag,
            sr_instance_id, organization_id, inventory_item_id,
            owning_inst_id, owning_org_id,
            source_org_instance_id, source_organization_id,
            project_id, task_id,
            supplier_id, supplier_site_id, region_id,
            ship_method, customer_region_id,
            part_condition,
            supply_date,
            aggr_type, category_set_id, sr_category_id,
            supply_type, vmi_flag,
            supply_qty,
            planned_order_count,
            work_order_leadtime,
            work_order_count,
            work_order_qty,
            stockout_days,
            supply_volume,
            drp_supply_as_demand,
            return_order_qty,
            return_fcst,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category-mfg_period (1016, 1017, 1018)
        select
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id, f.inventory_item_id,
            f.owning_inst_id, f.owning_org_id,
            f.source_org_instance_id, f.source_organization_id,
            f.project_id, f.task_id,
            f.supplier_id, f.supplier_site_id, f.region_id,
            f.ship_method, f.customer_region_id,
            f.part_condition,
            d.mfg_period_start_date supply_date,
            decode(f.aggr_type, 42, 1016, 43, 1017, 1018) aggr_type,
            f.category_set_id, f.sr_category_id,
            f.supply_type, f.vmi_flag,
            sum(f.supply_qty),
            sum(f.planned_order_count),
            sum(f.work_order_leadtime),
            sum(f.work_order_count),
            sum(f.work_order_qty),
            sum(f.stockout_days),
            sum(f.supply_volume),
            sum(f.drp_supply_as_demand),
            sum(f.return_order_qty),
            sum(f.return_fcst),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_supplies_f f,
            msc_phub_dates_mv d
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type between 42 and 44
            and f.supply_date = d.calendar_date
            and d.mfg_period_start_date is not null
        group by
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id, f.inventory_item_id,
            f.owning_inst_id, f.owning_org_id,
            f.source_org_instance_id, f.source_organization_id,
            f.project_id, f.task_id,
            f.supplier_id, f.supplier_site_id, f.region_id,
            f.ship_method, f.customer_region_id,
            f.part_condition,
            d.mfg_period_start_date,
            decode(f.aggr_type, 42, 1016, 43, 1017, 1018),
            f.category_set_id, f.sr_category_id,
            f.supply_type, f.vmi_flag
        union all
        -- category-fiscal_period (1019, 1020, 1021)
        select
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id, f.inventory_item_id,
            f.owning_inst_id, f.owning_org_id,
            f.source_org_instance_id, f.source_organization_id,
            f.project_id, f.task_id,
            f.supplier_id, f.supplier_site_id, f.region_id,
            f.ship_method, f.customer_region_id,
            f.part_condition,
            d.fis_period_start_date supply_date,
            decode(f.aggr_type, 42, 1019, 43, 1020, 1021) aggr_type,
            f.category_set_id, f.sr_category_id,
            f.supply_type, f.vmi_flag,
            sum(f.supply_qty),
            sum(f.planned_order_count),
            sum(f.work_order_leadtime),
            sum(f.work_order_count),
            sum(f.work_order_qty),
            sum(f.stockout_days),
            sum(f.supply_volume),
            sum(f.drp_supply_as_demand),
            sum(f.return_order_qty),
            sum(f.return_fcst),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_supplies_f f,
            msc_phub_dates_mv d
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type between 42 and 44
            and f.supply_date = d.calendar_date
            and d.fis_period_start_date is not null
        group by
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id, f.inventory_item_id,
            f.owning_inst_id, f.owning_org_id,
            f.source_org_instance_id, f.source_organization_id,
            f.project_id, f.task_id,
            f.supplier_id, f.supplier_site_id, f.region_id,
            f.ship_method, f.customer_region_id,
            f.part_condition,
            d.fis_period_start_date,
            decode(f.aggr_type, 42, 1019, 43, 1020, 1021),
            f.category_set_id, f.sr_category_id,
            f.supply_type, f.vmi_flag;

        msc_phub_util.log('msc_supply_pkg.summarize_supplies_f, level2='||sql%rowcount);
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_supply_pkg.summarize_supplies_f: '||sqlerrm;
            raise;
    end summarize_supplies_f;

    procedure summarize_item_wips_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_category_set_id1 number := fnd_profile.value('MSC_HUB_CAT_SET_ID_1');
    begin
        msc_phub_util.log('msc_supply_pkg.summarize_item_wips_f');
        retcode := 0;
        errbuf := '';

        delete from msc_item_wips_f
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id and aggr_type>0;
        msc_phub_util.log('msc_supply_pkg.summarize_item_wips_f, delete='||sql%rowcount);
        commit;

        -- level 1
        insert into msc_item_wips_f (
            plan_id, plan_run_id,
            sr_instance_id, organization_id, inventory_item_id,
            vmi_flag, wip_start_date,
            aggr_type, category_set_id, sr_category_id,
            wip_qty,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category (42, 43, 44)
        select
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            to_number(-23453) inventory_item_id,
            f.vmi_flag, f.wip_start_date,
            to_number(42) aggr_type,
            l_category_set_id1 category_set_id,
            nvl(q.sr_category_id, -23453),
            sum(f.wip_qty),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_item_wips_f f,
            msc_phub_item_categories_mv q
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
            and f.sr_instance_id=q.sr_instance_id(+)
            and f.organization_id=q.organization_id(+)
            and f.inventory_item_id=q.inventory_item_id(+)
            and q.category_set_id(+)=l_category_set_id1
        group by
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            f.vmi_flag, f.wip_start_date,
            nvl(q.sr_category_id, -23453);

        msc_phub_util.log('msc_supply_pkg.summarize_item_wips_f, level1='||sql%rowcount);
        commit;

        -- level 2
        insert into msc_item_wips_f (
            plan_id, plan_run_id,
            sr_instance_id, organization_id, inventory_item_id,
            vmi_flag, wip_start_date,
            aggr_type, category_set_id, sr_category_id,
            wip_qty,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category-mfg_period (1016, 1017, 1018)
        select
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id, f.inventory_item_id,
            f.vmi_flag,
            d.mfg_period_start_date wip_start_date,
            decode(f.aggr_type, 42, 1016, 43, 1017, 1018) aggr_type,
            f.category_set_id, f.sr_category_id,
            sum(f.wip_qty),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_item_wips_f f,
            msc_phub_dates_mv d
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type between 42 and 44
            and f.wip_start_date = d.calendar_date
            and d.mfg_period_start_date is not null
        group by
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id, f.inventory_item_id,
            f.vmi_flag,
            d.mfg_period_start_date,
            decode(f.aggr_type, 42, 1016, 43, 1017, 1018),
            f.category_set_id, f.sr_category_id
        union all
        -- category-fiscal_period (1019, 1020, 1021)
        select
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id, f.inventory_item_id,
            f.vmi_flag,
            d.fis_period_start_date wip_start_date,
            decode(f.aggr_type, 42, 1019, 43, 1020, 1021) aggr_type,
            f.category_set_id, f.sr_category_id,
            sum(f.wip_qty),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_item_wips_f f,
            msc_phub_dates_mv d
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type between 42 and 44
            and f.wip_start_date = d.calendar_date
            and d.fis_period_start_date is not null
        group by
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id, f.inventory_item_id,
            f.vmi_flag,
            d.fis_period_start_date,
            decode(f.aggr_type, 42, 1019, 43, 1020, 1021),
            f.category_set_id, f.sr_category_id;

        msc_phub_util.log('msc_supply_pkg.summarize_item_wips_f, level2='||sql%rowcount);
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_supply_pkg.summarize_item_wips_f: '||sqlerrm;
            raise;
    end summarize_item_wips_f;

    procedure export_supplies_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_supply_pkg.export_supplies_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_supplies_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_supplies_f('||
            '     st_transaction_id,'||
            '     error_code,'||
            '     sr_instance_id,'||
            '     organization_id,'||
            '     inventory_item_id,'||
            '     supplier_id,'||
            '     supplier_site_id,'||
            '     region_id,'||
            '     project_id,'||
            '     task_id,'||
            '     organization_code,'||
            '     item_name,'||
            '     supplier_name,'||
            '     supplier_site_code,'||
            '     zone,'||
            '     project_number,'||
            '     task_number,'||
            '     ship_method,'||
            '     supply_type,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     part_condition,'||
            '     owning_org_code,'||
            '     owning_inst_id,'||
            '     owning_org_id,'||
            '     source_org_code,'||
            '     source_org_instance_id,'||
            '     source_organization_id,'||
            '     customer_region_id,'||
            '     customer_zone,';
        end if;
        l_sql := l_sql||
            '     vmi_flag,'||
            '     supply_date,'||
            '     supply_qty,'||
            '     planned_order_count,'||
            '     planned_order_itf_count,'||
            '     planned_order_gmod_count,'||
            '     planned_order_bwo_count,'||
            '     work_order_leadtime,'||
            '     work_order_count,'||
            '     qty_pegged_to_excess,'||
            '     stockout_days,'||
            '     work_order_qty,'||
            '     drp_supply_as_demand,'||
            '     return_order_qty,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     supply_volume,'||
            '     return_fcst,';
        end if;
        l_sql := l_sql||
            '     created_by, creation_date,'||
            '     last_updated_by, last_update_date, last_update_login'||
            ' )'||
            ' select'||
            '     :p_st_transaction_id,'||
            '     0,'||
            '     f.sr_instance_id,'||
            '     f.organization_id,'||
            '     f.inventory_item_id,'||
            '     f.supplier_id,'||
            '     f.supplier_site_id,'||
            '     f.region_id,'||
            '     f.project_id,'||
            '     f.task_id,'||
            '     mtp.organization_code,'||
            '     mi.item_name,'||
            '     decode(f.supplier_id, -23453, null, smv.supplier_name),'||
            '     decode(f.supplier_site_id, -23453, null, smv.supplier_site_code),'||
            '     decode(f.region_id, -23453, null, smv.zone),'||
            '     proj.project_number,'||
            '     proj.task_number,'||
            '     f.ship_method,'||
            '     f.supply_type,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     f.part_condition,'||
            '     mtp3.organization_code,'||
            '     f.owning_inst_id,'||
            '     f.owning_org_id,'||
            '     mtp2.organization_code,'||
            '     f.source_org_instance_id,'||
            '     f.source_organization_id,'||
            '     f.customer_region_id,'||
            '     decode(f.customer_region_id, -23453, null, cmv.zone),';
        end if;
        l_sql := l_sql||
            '     f.vmi_flag,'||
            '     f.supply_date,'||
            '     f.supply_qty,'||
            '     f.planned_order_count,'||
            '     f.planned_order_itf_count,'||
            '     f.planned_order_gmod_count,'||
            '     f.planned_order_bwo_count,'||
            '     f.work_order_leadtime,'||
            '     f.work_order_count,'||
            '     f.qty_pegged_to_excess,'||
            '     f.stockout_days,'||
            '     f.work_order_qty,'||
            '     f.drp_supply_as_demand,'||
            '     f.return_order_qty,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     f.supply_volume,'||
            '     f.return_fcst,';
        end if;
        l_sql := l_sql||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_supplies_f'||l_suffix||' f,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp2,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp3,'||
            '     '||l_apps_schema||'.msc_phub_customers_mv'||l_suffix||' cmv,';
        end if;
        l_sql := l_sql||
            '     '||l_apps_schema||'.msc_items'||l_suffix||' mi,'||
            '     '||l_apps_schema||'.msc_phub_suppliers_mv'||l_suffix||' smv,'||
            '     (select p.sr_instance_id, p.organization_id,'||
            '         p.project_id, t.task_id, p.project_number, t.task_number'||
            '     from '||l_apps_schema||'.msc_projects'||l_suffix||' p, '||l_apps_schema||'.msc_project_tasks'||l_suffix||' t'||
            '     where p.project_id=t.project_id'||
            '         and p.plan_id=t.plan_id'||
            '         and p.sr_instance_id=t.sr_instance_id'||
            '         and p.organization_id=t.organization_id'||
            '         and p.plan_id=-1) proj'||
            ' where f.plan_id=:p_plan_id'||
            '     and f.plan_run_id=:p_plan_run_id'||
            '     and f.aggr_type=0'||
            '     and mtp.partner_type(+)=3'||
            '     and mtp.sr_instance_id(+)=f.sr_instance_id'||
            '     and mtp.sr_tp_id(+)=f.organization_id';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     and mtp3.partner_type(+)=3'||
            '     and mtp3.sr_instance_id(+)=f.owning_inst_id'||
            '     and mtp3.sr_tp_id(+)=f.owning_org_id'||
            '     and mtp2.partner_type(+)=3'||
            '     and mtp2.sr_instance_id(+)=f.source_org_instance_id'||
            '     and mtp2.sr_tp_id(+)=f.source_organization_id'||
            '     and cmv.customer_id(+)=-23453'||
            '     and cmv.customer_site_id(+)=-23453'||
            '     and cmv.region_id(+)=f.customer_region_id';
        end if;
        l_sql := l_sql||
            '     and mi.inventory_item_id(+)=f.inventory_item_id'||
            '     and smv.supplier_id(+)=f.supplier_id'||
            '     and smv.supplier_site_id(+)=f.supplier_site_id'||
            '     and smv.region_id(+)=f.region_id'||
            '     and proj.project_id(+)=f.project_id'||
            '     and proj.task_id(+)=f.task_id'||
            '     and proj.sr_instance_id(+)=f.sr_instance_id'||
            '     and proj.organization_id(+)=f.organization_id';

        execute immediate l_sql using p_st_transaction_id, p_plan_id, p_plan_run_id;
        commit;
        msc_phub_util.log('msc_supply_pkg.export_supplies_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_supply_pkg.export_supplies_f: '||sqlerrm;
            raise;
    end export_supplies_f;

    procedure export_item_wips_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_supply_pkg.export_item_wips_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_item_wips_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_item_wips_f('||
            '     st_transaction_id,'||
            '     error_code,'||
            '     sr_instance_id,'||
            '     organization_id,'||
            '     inventory_item_id,'||
            '     organization_code,'||
            '     item_name,'||
            '     vmi_flag,'||
            '     wip_start_date,'||
            '     wip_qty,'||
            '     created_by, creation_date,'||
            '     last_updated_by, last_update_date, last_update_login'||
            ' )'||
            ' select'||
            '     :p_st_transaction_id,'||
            '     0,'||
            '     f.sr_instance_id,'||
            '     f.organization_id,'||
            '     f.inventory_item_id,'||
            '     mtp.organization_code,'||
            '     mi.item_name,'||
            '     f.vmi_flag,'||
            '     f.wip_start_date,'||
            '     f.wip_qty,'||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_item_wips_f'||l_suffix||' f,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,'||
            '     '||l_apps_schema||'.msc_items'||l_suffix||' mi'||
            ' where f.plan_id=:p_plan_id'||
            '     and f.plan_run_id=:p_plan_run_id'||
            '     and f.aggr_type=0'||
            '     and mtp.partner_type(+)=3'||
            '     and mtp.sr_instance_id(+)=f.sr_instance_id'||
            '     and mtp.sr_tp_id(+)=f.organization_id'||
            '     and mi.inventory_item_id(+)=f.inventory_item_id';

        execute immediate l_sql using p_st_transaction_id, p_plan_id, p_plan_run_id;
        commit;
        msc_phub_util.log('msc_supply_pkg.export_item_wips_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_supply_pkg.export_item_wips_f: '||sqlerrm;
            raise;
    end export_item_wips_f;

    procedure import_supplies_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_supplies_f';
        l_fact_table varchar2(30) := 'msc_supplies_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_supply_pkg.import_supplies_f');
        retcode := 0;
        errbuf := null;

        l_result := l_result + msc_phub_util.prepare_staging_dates(
            l_staging_table, 'supply_date', p_st_transaction_id,
            p_upload_mode, p_overwrite_after_date,
            p_plan_start_date, p_plan_cutoff_date);

        l_result := l_result + msc_phub_util.prepare_fact_dates(
            l_fact_table, 1, 'supply_date', p_plan_id, p_plan_run_id,
            p_upload_mode, p_overwrite_after_date);

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'sr_instance_id', 'organization_id', 'organization_code');

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'owning_inst_id', 'owning_org_id', 'owning_org_code');

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'source_org_instance_id', 'source_organization_id', 'source_org_code');

        l_result := l_result + msc_phub_util.decode_item_key(
            l_staging_table, p_st_transaction_id, 'inventory_item_id', 'item_name');

        l_result := l_result + msc_phub_util.decode_supplier_key(
            l_staging_table, p_st_transaction_id,
            'supplier_id', 'supplier_site_id', 'region_id',
            'supplier_name', 'supplier_site_code', 'zone');

        l_result := l_result + msc_phub_util.decode_project_key(
            l_staging_table, p_st_transaction_id);

        l_result := l_result + msc_phub_util.decode_customer_key(
            l_staging_table, p_st_transaction_id,
            null, null, 'customer_region_id',
            null, null, 'customer_zone');

        msc_phub_util.log('msc_supply_pkg.import_supplies_f: insert into msc_supplies_f');
        insert into msc_supplies_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            owning_inst_id,
            owning_org_id,
            source_org_instance_id,
            source_organization_id,
            inventory_item_id,
            supplier_id,
            supplier_site_id,
            region_id,
            customer_region_id,
            project_id,
            task_id,
            ship_method,
            supply_type,
            part_condition,
            io_plan_flag,
            vmi_flag,
            supply_date,
            supply_qty,
            planned_order_count,
            planned_order_itf_count,
            planned_order_gmod_count,
            planned_order_bwo_count,
            work_order_leadtime,
            work_order_count,
            qty_pegged_to_excess,
            stockout_days,
            work_order_qty,
            drp_supply_as_demand,
            return_order_qty,
            return_fcst,
            supply_volume,
            aggr_type, category_set_id, sr_category_id,
            created_by, creation_date,
            last_updated_by, last_update_date, last_update_login
        )
        select
            p_plan_id,
            p_plan_run_id,
            nvl(sr_instance_id, -23453),
            nvl(organization_id, -23453),
            nvl(owning_inst_id, -23453),
            nvl(owning_org_id, -23453),
            nvl(source_org_instance_id, -23453),
            nvl(source_organization_id, -23453),
            nvl(inventory_item_id, -23453),
            nvl(supplier_id, -23453),
            nvl(supplier_site_id, -23453),
            nvl(region_id, -23453),
            nvl(customer_region_id, -23453),
            nvl(project_id, -23453),
            nvl(task_id, -23453),
            ship_method,
            supply_type,
            part_condition,
            decode(p_plan_type, 4, 1, 0) io_plan_flag,
            vmi_flag,
            supply_date,
            supply_qty,
            planned_order_count,
            planned_order_itf_count,
            planned_order_gmod_count,
            planned_order_bwo_count,
            work_order_leadtime,
            work_order_count,
            qty_pegged_to_excess,
            stockout_days,
            work_order_qty,
            drp_supply_as_demand,
            return_order_qty,
            return_fcst,
            supply_volume,
            0, -23453, -23453,
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_supplies_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_supply_pkg.import_supplies_f: inserted='||sql%rowcount);
        commit;

        summarize_supplies_f(errbuf, retcode, p_plan_id, p_plan_run_id);

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_supply_pkg.import_supplies_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_supply_pkg.import_supplies_f: '||sqlerrm;
            raise;
    end import_supplies_f;

    procedure import_item_wips_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_item_wips_f';
        l_fact_table varchar2(30) := 'msc_item_wips_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_supply_pkg.import_item_wips_f');
        retcode := 0;
        errbuf := null;

        l_result := l_result + msc_phub_util.prepare_staging_dates(
            l_staging_table, 'wip_start_date', p_st_transaction_id,
            p_upload_mode, p_overwrite_after_date,
            p_plan_start_date, p_plan_cutoff_date);

        l_result := l_result + msc_phub_util.prepare_fact_dates(
            l_fact_table, 1, 'wip_start_date', p_plan_id, p_plan_run_id,
            p_upload_mode, p_overwrite_after_date);

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'sr_instance_id', 'organization_id', 'organization_code');

        l_result := l_result + msc_phub_util.decode_item_key(
            l_staging_table, p_st_transaction_id, 'inventory_item_id', 'item_name');

        msc_phub_util.log('msc_supply_pkg.import_item_wips_f: insert into msc_item_wips_f');
        insert into msc_item_wips_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            vmi_flag,
            wip_start_date,
            wip_qty,
            aggr_type, category_set_id, sr_category_id,
            created_by, creation_date,
            last_updated_by, last_update_date, last_update_login
        )
        select
            p_plan_id,
            p_plan_run_id,
            nvl(sr_instance_id, -23453),
            nvl(organization_id, -23453),
            nvl(inventory_item_id, -23453),
            vmi_flag,
            wip_start_date,
            wip_qty,
            0, -23453, -23453,
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_item_wips_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_supply_pkg.import_item_wips_f: inserted='||sql%rowcount);
        commit;

        summarize_item_wips_f(errbuf, retcode, p_plan_id, p_plan_run_id);

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_supply_pkg.import_item_wips_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_supply_pkg.import_item_wips_f: '||sqlerrm;
            raise;
    end import_item_wips_f;

end msc_supply_pkg;

/
