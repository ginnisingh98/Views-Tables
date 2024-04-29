--------------------------------------------------------
--  DDL for Package Body MSC_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ITEM_PKG" as
/* $Header: MSCHBITB.pls 120.44.12010000.15 2010/03/30 19:45:40 wexia ship $ */





procedure populate_details(errbuf out nocopy varchar2,
                             retcode out  nocopy varchar2,
                     p_plan_id number,
                 p_plan_run_id number default null) is


    l_qid_bucket  number;
    l_qid_vmi_item number;
    l_qid_last_date1 number;
    l_qid_last_date number;
    l_qid_sd_item  number;
    l_qid_pab number;
    l_qid_pab_item number;
    l_qid_others number;

    l_api_name varchar2(100);
    l_stmt_id number;

    l_sysdate date;
    l_user_id number;
    l_user_login_id number;
    l_cp_login_id number;
    l_program_id number;
    l_appl_id number;
    l_request_id number;
    l_plan_days number;
    l_count number;
    l_plan_start_date date;
    l_plan_cutoff_date date;
    l_plan_type number;
    l_sr_instance_id number;

    l_owning_currency_code varchar2(20) := msc_phub_util.get_owning_currency_code(p_plan_run_id);

    l_refresh_mode  number;
    l_res_item_qid  number;
    con_ods_plan_id constant number := -1;
    l_rowcount0 number := 0;
    l_rowcount1 number := 0;
    l_rowcount2 number := 0;
begin

    msc_phub_util.log('msc_item_pkg.populate_details');

    retcode :=0;    -- this means successfully
    errbuf :='';

    -- ODS plan
    if  p_plan_id = -1
    then
        -- get plan_cutoff_date
        select trunc(plan_cutoff_date) into l_plan_cutoff_date
        from msc_plan_runs
        where plan_run_id = p_plan_run_id;

        -- get refresh_mode
        select refresh_mode into l_refresh_mode
        from msc_plan_runs
        where plan_run_id = p_plan_run_id;

        if l_refresh_mode = 2 -- targeted refesh
        then
            l_res_item_qid := msc_phub_util.get_item_rn_qid(p_plan_id, p_plan_run_id);

            delete from msc_item_inventory_f
            where  plan_id = p_plan_id
                and plan_run_id = p_plan_run_id
                and (p_plan_id, sr_instance_id, organization_id, inventory_item_id) in
                    (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid);

            l_rowcount1 := l_rowcount1 + sql%rowcount;
            msc_phub_util.log('msc_item_inventory_f, delete='||sql%rowcount||', l_rowcount1='||l_rowcount1);
            commit;

            delete from msc_item_orders_f
            where  plan_id = p_plan_id
                and plan_run_id = p_plan_run_id
                and (p_plan_id, sr_instance_id, organization_id, inventory_item_id) in
                    (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid);

            l_rowcount2 := l_rowcount2 + sql%rowcount;
            msc_phub_util.log('msc_item_orders_f, delete='||sql%rowcount||', l_rowcount2='||l_rowcount2);
            commit;
        end if;
    end if;

   l_user_id := fnd_global.user_id;
   l_sysdate :=sysdate;
   l_user_login_id :=fnd_global.login_id;
   l_cp_login_id :=FND_GLOBAL.CONC_LOGIN_ID;
   l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
   l_appl_id := FND_GLOBAL.PROG_APPL_ID;
   l_request_id := FND_GLOBAL.CONC_REQUEST_ID;


    select plan_type, sr_instance_id, plan_start_date, plan_cutoff_date
    into l_plan_type, l_sr_instance_id, l_plan_start_date, l_plan_cutoff_date
    from msc_plan_runs
    where plan_id=p_plan_id
    and plan_run_id=p_plan_run_id;

    l_api_name := 'msc_item_pkg.populate_details';

    -----------------------------------------------------------------
    --- get the total days in the plan into l_plan_days
    --- l_plan_days will be used later to calculate avg_daily_demand
    -----------------------------------------------------------------

    l_plan_days := (l_plan_cutoff_date - l_plan_start_date + 1);


    ---------------------------------------------------------------
    -- insert vmi item in this plan into msc_hub_query by l_qid_vmi_item;
    -- max possible rows insert =100;
    -- we can verify the query with plan_id=63
    -- l_qid_vim_item result will be used later to populate vmi_flag
    ---------------------------------------------------------------

    l_stmt_id :=10;
    select msc_hub_query_s.nextval into l_qid_vmi_item from dual;

    insert into msc_hub_query(
        query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        number1, -- plan_id
        number2, -- plan_run_id
        number3, -- sr_instance_id
        number4, -- organization_id
        number5, -- inventory_item_id
        number6  -- vmi flag
    )
    select unique
        l_qid_vmi_item,l_sysdate,1,l_sysdate,1,1,
        p_plan_id,
        p_plan_run_id,
        msi.sr_instance_id,
        msi.organization_id,
        msi.inventory_item_id,
        nvl(mis.vmi_flag,0)
    from
        msc_item_suppliers mis,
        msc_system_items msi
    where msi.plan_id=mis.plan_id
        and msi.sr_instance_id=mis.sr_instance_id
        and msi.organization_id=mis.organization_id
        and msi.inventory_item_id=mis.inventory_item_id
        and msi.plan_id=p_plan_id
        and nvl(mis.vmi_flag,0)=1
        and msi.sr_instance_id=decode(p_plan_id, -1, l_sr_instance_id, msi.sr_instance_id);

    msc_phub_util.log(l_stmt_id||', l_qid_vmi_item='||l_qid_vmi_item||', count='||sql%rowcount);
    commit;

    ----------------------------------------------------------------------------
    -- get plan bucket information+ (curr_start_date-1) + (curr_cutoff_date+1)
    -- we need to find out the last working
    -- day in the bucket since engine put supply/demand during that bucket
    -- in bucket's last working day
    -- about 200 rows
    ----------------------------------------------------------------------------
    l_stmt_id:=20;
    select msc_hub_query_s.nextval into l_qid_bucket from dual;
    insert into msc_hub_query(
    query_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    number1,        -- plan_id
    number2,        -- plan_run_id
    number3,        -- sr_instance_id
    number4,        -- organization_id
    date1,          -- bkt_start_date
    date2,          --- bkt_end_date
    date3,          --- last working day NOTE: for day bucket, this could be null
    date4,                  -- safety_Stock period date in msc_safety_Stock table,
                            -- this may not at bucket_start date
    date5,          -- working day bkt start date
    number10,       -- bucket_type
    number11        -- days in bucket
    )
    select
    l_qid_bucket,l_sysdate,1,l_sysdate,1,1,
    p_plan_id,
    p_plan_run_id,
    mpb.sr_instance_id,
    mpb.organization_id,
    mpb.bkt_start_date,
    mpb.bkt_end_date,
    decode(mpb.bucket_type,1,mpb.bkt_start_date,
           msc_hub_calendar.last_work_date(p_plan_id,mpb.sr_instance_id,
                mpb.bucket_type,mpb.bkt_start_date,
                mpb.bkt_end_date) )last_work_date,

        -- day bucket always has its self as last_work_date
        -- no matter it is actually a working day or not

    msc_hub_calendar.ss_date(p_plan_id,mpb.bkt_start_date,mpb.bkt_end_date) ss_date,

    decode(mpb.bucket_type,1,
            msc_hub_calendar.working_day_bkt_start_date(p_plan_id,
                        mpb.sr_instance_id,
                mpb.bucket_type,
                mpb.bkt_start_date,
                mpb.bkt_end_date),
        mpb.bkt_start_date) working_day_bkt_start_date,

        mpb.bucket_type,
    mpb.days_in_bkt
   from msc_plan_buckets mpb
   where mpb.plan_id =p_plan_id
   and mpb.sr_instance_id = decode(mpb.plan_id, -1, l_sr_instance_id, mpb.sr_instance_id)
   and mpb.curr_flag=1;

   msc_phub_util.log(l_stmt_id||', l_qid_bucket='||l_qid_bucket||', count='||sql%rowcount);
   commit;


  -------------------------------------------------------------------------
   -- get the
   --   last date of week(for mfg calendar)
   --   last date of period(for fiscal calendar)
   --   last date of the month(for Greg calendar)
   -- about 100 rows max
   --------------------------------------------------------------------

    l_qid_last_date1 := msc_phub_util.get_reporting_dates(l_plan_start_date, l_plan_cutoff_date);


   -------------------------------------------------------------------
   -- insert last date of the week/period and month as
   -- well as its corresonding bkt_start_date and last_work_date
   -- this is required to move ss to last date of the week/bis period/month
   -- from bkt_start_date and pab from last_work_date to last_date of
   -- week/period/month
   -- about 100 rows
   -----------------------------------------------------------------


   l_stmt_id :=35;
   select msc_hub_query_s.nextval into l_qid_last_date from dual;


   insert into msc_hub_query (
    query_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    date1, -- last_date
    date2, -- bkt_start_date, for day bucket, it may not be a working day
    date3  -- last_work_date,

   )
    select  l_qid_last_date,
        l_sysdate,1,l_sysdate,1,1,
    f1.date1  last_date,
      (select max(f2.date1) from msc_hub_query f2
       where f2.date1<=f1.date1 and f2.query_id=l_qid_bucket),

      (select max(f3.date3) from msc_hub_query f3
       where f3.date3<=f1.date1 and f3.query_id=l_qid_bucket)

    from msc_hub_query f1 where f1.query_id = l_qid_last_date1;

    msc_phub_util.log(l_stmt_id||', l_qid_last_date='||l_qid_last_date||', count='||sql%rowcount);
    commit;

   ----------------------------------------------------------
   -- get the item which has supply/demand
   -- only item which has activity(supply/demand)
   -- is included
   -----------------------------------------------------------

   l_stmt_id :=50;
   select msc_hub_query_s.nextval into l_qid_sd_item from dual;


    insert into msc_hub_query(
        query_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        number1,  -- plan_id
        number2,  --- plan_run_id
        number3,  -- sr_instance_id
        number4,  -- organization_id
        number5,  -- inventory_item_id
        number6, -- vmi_flag
        number7, -- owning_org_id
        number8, -- owning_inst_id
        date1,   -- bkt_start_date
        date2,   -- bkt_end_date
        date3, -- activity_date
        number10, --bkt_type
        number11  -- days_in_bkt
        )
    select
        l_qid_sd_item,
        l_sysdate,1,l_sysdate,1,1,
        p_plan_id,
        p_plan_run_id,
        sd.sr_instance_id,
        sd.organization_id,
        sd.inventory_item_id,
        sd.vmi_flag,
        decode(sign(sd.organization_id), -1, msc_hub_calendar.get_item_org(p_plan_id, sd.inventory_item_id,
        decode(sign(sd.sr_instance_id), -1, l_sr_instance_id, sd.sr_instance_id)),
        sd.organization_id),
        decode(sign(sd.sr_instance_id), -1, l_sr_instance_id, sd.sr_instance_id),
        f.date1,
        f.date2,
        sd.activity_date,
        f.number10,
        f.number11
    from msc_hub_query f,
        (select unique
            mdf.plan_id,
            mdf.sr_instance_id,
            mdf.organization_id,
            mdf.inventory_item_id,
            nvl(mdf.vmi_flag,0) vmi_flag,
            mdf.order_date      activity_date
        from msc_demands_f mdf
        where mdf.plan_id= p_plan_id
            and mdf.plan_run_id = p_plan_run_id
            and mdf.aggr_type=0
        union
        select unique
            msf.plan_id,
            msf.sr_instance_id,
            msf.organization_id,
            msf.inventory_item_id,
            nvl(msf.vmi_flag,0) vmi_flag,
            msf.supply_date     activity_date
        from msc_supplies_f msf
        where msf.plan_id = p_plan_id
            and msf.plan_run_id = p_plan_run_id
            and msf.aggr_type=0) sd
    where sd.activity_date between f.date1 and f.date2
        and f.query_id =l_qid_bucket
        and (p_plan_id <> con_ods_plan_id
            or (p_plan_id = con_ods_plan_id
                and sd.sr_instance_id = l_sr_instance_id
                and (l_refresh_mode = 1
                    or (l_refresh_mode = 2 and (p_plan_id, sd.sr_instance_id, sd.organization_id, sd.inventory_item_id) in
                    (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid)))));


   msc_phub_util.log(l_stmt_id||', l_qid_sd_item='||l_qid_sd_item||', count='||sql%rowcount);
   commit;



-----------------------------------------------------------------------------
   l_stmt_id :=55;
   select msc_hub_query_s.nextval into l_qid_pab_item from dual;

   insert into msc_hub_query
    (query_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    number1,  -- plan_id
    number2,  --- plan_run_id
    number3,  -- sr_instance_id
    number4,  -- organization_id
    number5,  -- inventory_item_id
    number6, -- vmi_flag
    number7, -- owning_org_id
    number8, -- owning_inst_id
    date3   -- activity_date
    )
    select
    l_qid_pab_item,
    l_sysdate,1,l_sysdate,1,1,
    p_plan_id,
    p_plan_run_id,
    sd.sr_instance_id,
    sd.organization_id,
    sd.inventory_item_id,
    sd.vmi_flag,
    decode(sign(sd.organization_id), -1, msc_hub_calendar.get_item_org(p_plan_id, sd.inventory_item_id,
        decode(sign(sd.sr_instance_id), -1, l_sr_instance_id, sd.sr_instance_id)),
        sd.organization_id),
    decode(sign(sd.sr_instance_id), -1, l_sr_instance_id, sd.sr_instance_id),
    l.date3
   from msc_hub_query l,
    (select unique
        mdf.plan_id,
        mdf.sr_instance_id,
        mdf.organization_id,
        mdf.inventory_item_id,
        nvl(mdf.vmi_flag,0) vmi_flag
      from msc_demands_f mdf
      where mdf.plan_id= p_plan_id
      and   mdf.plan_run_id = p_plan_run_id
      and mdf.aggr_type=0
      union
      select unique
        msf.plan_id,
        msf.sr_instance_id,
        msf.organization_id,
        msf.inventory_item_id,
        nvl(msf.vmi_flag,0) vmi_flag
      from msc_supplies_f msf
      where msf.plan_id = p_plan_id
      and   msf.plan_run_id = p_plan_run_id
      and msf.aggr_type=0) sd
   where l.query_id = l_qid_last_date
    and (p_plan_id <> con_ods_plan_id
        or (p_plan_id = con_ods_plan_id
            and sd.sr_instance_id = l_sr_instance_id
            and (l_refresh_mode = 1
                or (l_refresh_mode = 2 and (p_plan_id, sd.sr_instance_id, sd.organization_id, sd.inventory_item_id) in
                (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid)))))
   union
   select l_qid_pab_item,
    l_sysdate,1,l_sysdate,1,1,
    p_plan_id,
    p_plan_run_id,
    f.number3,
    f.number4,
    f.number5,
    f.number6,
    f.number7,
    f.number8,
    f.date3   --- activity_date
   from msc_hub_query f where f.query_id=l_qid_sd_item;

   msc_phub_util.log(l_stmt_id||', l_qid_pab_item='||l_qid_pab_item||', count='||sql%rowcount);
   commit;

   --------------------------------------------------------------------
   --- now, calculate pab and supply/demand
   --- pab and supply/demand is put at the last work date of the bucket
   --- we will later move pab to last date of the bucket
   --------------------------------------------------------------------


   l_stmt_id :=60;
   select msc_hub_query_s.nextval into l_qid_pab from dual;


   insert into msc_hub_query (
    query_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    number1,    -- plan_id
    number2,    --- plan_run_id
    number3,    -- sr_instance_id
    number4,    -- organization_id
    number5,    --- inventory_item_id
    number6,    -- vmi flag
    char1,      -- currency_code
    date3,     -- last work date,
    --------------------------------------------------
    number10,    -- pab_qty
    -----------------------------------------
    number11,    -- total demand
    number12,    -- total supply
    number13,   -- planned order qty
    number14,   -- indep_demand_qty
    number15,  --- indep_demand_value
    number16,   -- total dep demand
    number17,   --sales_order_value
    number18,   -- return order value
    number19,   -- make order qty
    number20,   -- make order leadtime
    number21,   -- make order count
    number23,   -- item leadtime
    number24,   -- onhand_qty
    number26,   -- onhand_usable
    number27,   -- intransit_usable
    number28,   -- plnd_xfer_usable
    number29,   -- onhand_defective
    number30,   -- intransit_defective
    number31,   -- plnd_xfer_defective
    number32,   -- supply_qty_usable
    number33,   -- supply_qty_defective
    number25,   -- scheduled_rept_qty
    number22,   -- forecast qty,
    number9    -- in drp, some supply (1,2,51) is also a demand
    )
   select
    l_qid_pab,
    l_sysdate,1,l_sysdate,1,1,
    p_plan_id,
    p_plan_run_id,
    s.sr_instance_id,
    s.organization_id,
    s.inventory_item_id,
    s.vmi_flag,
    nvl(mtp.currency_code, l_owning_currency_code),
    s.last_work_date,
    ------------------------------------------------
    SUM(nvl(s.pab_supply,0)- nvl(d.pab_demand,0)-nvl(s.drp_supply_as_demand,0))  --- drp case
    OVER (PARTITION BY s.plan_id,s.plan_run_id,
               s.sr_instance_id,s.organization_id,s.inventory_item_id
    ORDER by s.last_work_date) pab_qty,
    -------------------------------------------------------
    d.total_demand,
    s.total_supply,
    s.planned_order_qty,
    d.total_indep_Demand_qty,

    ---- make sure this indep_demand_value is qty * std_cost. this is used to calculate
    ---- cogs =item std cost x sum of  Indep dem qty
    ---d.total_indep_demand_value,  -- qty * std_Cost
    d.total_indep_Demand_qty * msi.standard_cost,

    d.total_dep_demand_qty,
    d.sales_order_qty  * nvl(msi.list_price,0)*(1-nvl(msi.average_discount,0)/100)  sales_order_value,
    s.return_order_qty * nvl(msi.list_price,0)*(1-nvl(msi.average_discount,0)/100) return_order_value,
    s.make_order_qty,
    s.work_order_leadtime,
    s.work_order_count,
    msi.fixed_lead_time,
    s.onhand_qty,
    s.onhand_usable,
    s.intransit_usable,
    s.plnd_xfer_usable,
    s.onhand_defective,
    s.intransit_defective,
    s.plnd_xfer_defective,
    s.supply_qty_usable,
    s.supply_qty_defective,
    s.scheduled_rept_qty,
    d.forecast_qty,
    s.drp_supply_as_demand
  from
   (select mfq.number1  plan_id,
    mfq.number2 plan_run_id,
    mfq.number3 sr_instance_id,
    mfq.number4 organization_id,
    mfq.number5 inventory_item_id,
    mfq.number6     vmi_flag, ---- nvl(msf.vmi_flag,0) vmi_flag,
    mfq.number7 owning_org_id,
    mfq.number8 owning_inst_id,
    mfq.date3   last_work_date,
    sum(decode(nvl(msf.supply_type,0),
                   4,0,
               0,0,
               nvl(msf.supply_qty,0)))  pab_supply,

    --- exclude onhand from total supply for drp
    sum(decode(l_plan_type,5,decode(msf.supply_type,18,0,nvl(msf.supply_qty,0)),
        nvl(msf.supply_qty,0)) ) total_supply,


    /*  ms.source_organization_id <> ms.organization_id
      and     (ms.order_type <> PURCH_REQ or
         (ms.order_type = PURCH_REQ and ms.supplier_id is not null))*/


    sum(nvl(msf.drp_supply_as_demand,0)) drp_supply_as_demand,

    sum(mfq.number11) days_in_bkt,
    sum(case when msf.supply_type in (5,76,77,78,79) then msf.supply_qty else 0 end) planned_order_qty,

    sum(nvl(msf.work_order_qty,0)) make_order_qty,
    -- return order in srp is defined
    -- as order_type in (1,2,18) and nvl(item_type_id,401) = 401 and nvl(item_type_value,1) = 2

    sum(nvl(msf.return_order_qty,0))      return_order_qty,
    sum(nvl(msf.work_order_leadtime,0))       work_order_leadtime,
    sum(nvl(msf.work_order_count,0)) work_order_count,
    sum(decode(nvl(msf.supply_type,0),
               18, nvl(msf.supply_qty,0),
           0)) onhand_qty,

    sum(case when l_plan_type=8
        and nvl(msf.part_condition,1)=1
        and msf.supply_type=18
        then msf.supply_qty else 0 end) onhand_usable,

    sum(case when l_plan_type=8
        and nvl(msf.part_condition,1)=1
        and msf.supply_type in (8,11,12)
        then msf.supply_qty else 0 end) intransit_usable,

    sum(case when l_plan_type=8
        and nvl(msf.part_condition,1)=1
        and msf.supply_type=51
        then msf.supply_qty else 0 end) plnd_xfer_usable,

    sum(case when l_plan_type=8
        and nvl(msf.part_condition,1)=2
        and msf.supply_type=18
        then msf.supply_qty else 0 end) onhand_defective,

    sum(case when l_plan_type=8
        and nvl(msf.part_condition,1)=2
        and msf.supply_type in (8,11,12)
        then msf.supply_qty else 0 end) intransit_defective,

    sum(case when l_plan_type=8
        and nvl(msf.part_condition,1)=2
        and msf.supply_type=51
        then msf.supply_qty else 0 end) plnd_xfer_defective,

    sum(case when l_plan_type=8
        and nvl(msf.part_condition,1)=1
        then msf.supply_qty else 0 end) supply_qty_usable,

    sum(case when l_plan_type=8
        and nvl(msf.part_condition,1)=2
        then msf.supply_qty else 0 end) supply_qty_defective,

    sum(case when msf.supply_type in (1,2,3,8,11,12,14,27,49,53,80)
        then nvl(msf.supply_qty, 0) else 0 end) scheduled_rept_qty -- bug 6797566, 9376354

    from msc_supplies_f msf,msc_hub_query mfq
    where mfq.number1 = msf.plan_id(+)
    and mfq.number2 =  msf.plan_run_id(+)
    and mfq.number3 =  msf.sr_instance_id(+)
    and mfq.number4 = msf.organization_id(+)
    and mfq.number5 = msf.inventory_item_id(+)
    and mfq.date3 =   msf.supply_date(+)
    and msf.aggr_type(+)=0
    and mfq.query_id =l_qid_pab_item   --- calculate at activity_date and last work day
    and (p_plan_id <> con_ods_plan_id
        or (p_plan_id = con_ods_plan_id
            and mfq.number3 = l_sr_instance_id
            and (l_refresh_mode = 1
                or (l_refresh_mode = 2 and (p_plan_id, mfq.number3, mfq.number4, mfq.number5) in
                (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid)))))
    group by
    mfq.number1,
    mfq.number2,
    mfq.number3,
    mfq.number4,
    mfq.number5,
    mfq.number6,
    mfq.number7,
    mfq.number8,
    mfq.date3
    ) s,
    (select mfq1.number1        plan_id,
    mfq1.number2            plan_run_id,
    mfq1.number3            sr_instance_id,
    mfq1.number4            organization_id,
    mfq1.number5            inventory_item_id,
    mfq1.number6                     vmi_flag,       ---- nvl(mdf.vmi_flag,0) vmi_flag,
    mfq1.number7 owning_org_id,
    mfq1.number8 owning_inst_id,
    mfq1.date3          last_work_date,

    sum( decode(l_plan_type,5,
            decode(nvl(mdf.order_type,0),
                              0,0,
                              -1,0,
                              -29,decode(mfq1.number4,-23453,0,nvl(mdf.demand_qty,0)), -- exclude global f/c
                  -31,0,
                              nvl(mdf.demand_qty,0)),
            decode(nvl(mdf.order_type,0),
                              0,0,
                  -5,0,
                                  -22,0,
                              -29,decode(mfq1.number4,-23453,0,nvl(mdf.demand_qty,0)), -- exclude global f/c
                              -31,0,   --exclude safety stock demand
                               nvl(mdf.demand_qty,0))))    pab_demand,

    -- for drp plan
    ---
    -- work order,INTER_ORG_DEMAND (based on order_date), exclude planned order
    -- supply, exclude onhand(18)
    --- supply type 1,2,51 also count as demand
    -- decode(ms.order_type, PLANNED_ARRIVAL, PLANNED_SHIPMENT_OFF,
    -- PURCHASE_ORDER,PLANNED_SHIPMENT_OFF,
    -- PURCH_REQ,PLANNED_SHIPMENT_OFF)

    --pab= total_suply+onhand-total_demand

    sum(decode(l_plan_type,5,
                decode(nvl(mdf.order_type,0),
                              0,0,
                      -1,0,
                              -29,decode(mfq1.number4,-23453,0,nvl(mdf.demand_qty,0)),
                      -31,0,
                      nvl(mdf.demand_qty,0)),
               decode(nvl(mdf.order_type,0),
                                 0,0,
                     -29,decode(mfq1.number4,-23453,0,nvl(mdf.demand_qty,0)),
                     -31,0,
                     nvl(mdf.demand_qty,0))))  total_demand,


    sum(nvl(mdf.INDEP_DEMAND_QTY,0) )   total_indep_demand_qty,
    ---- make sure this indep_demand_value is qty * std_cost. this is used to calculate
    ---- cogs =item std cost x sum of  Indep dem qty

    --sum(nvl(INDEP_DEMAND_QTY,0) * msi.standard_cost)       total_indep_demand_value,
    sum(decode(nvl(mdf.order_type,0),
        -1,decode(l_plan_type,5,0,nvl(mdf.demand_qty,0)),  -- exclude drp planned demand from dep demand
        -2,nvl(mdf.demand_qty,0),
        -3,nvl(mdf.demand_qty,0),
        -4,nvl(mdf.demand_qty,0),
        -24,nvl(mdf.demand_qty,0),
        -25,nvl(mdf.demand_qty,0),
        0))             total_dep_demand_qty,
    sum(nvl(mdf.sales_order_qty,0)) sales_order_qty,
    sum(decode(nvl(mdf.order_type,0),
        -29,nvl(mdf.demand_qty,0),
        0))             forecast_Qty
    from msc_demands_f mdf,msc_hub_query mfq1
    where mfq1.number1 = mdf.plan_id(+)
    and mfq1.number2   = mdf.plan_run_id(+)
    and mfq1.number3   = mdf.sr_instance_id(+)
    and mfq1.number4   = mdf.organization_id(+)
    and mfq1.number5   = mdf.inventory_item_id(+)
    and mfq1.date3    = mdf.order_date(+)
    and mdf.aggr_type(+)=0
    and mfq1.query_id  = l_qid_pab_item   --- calculate at activity_date and last work day
    and (p_plan_id <> con_ods_plan_id
        or (p_plan_id = con_ods_plan_id
            and mfq1.number3 = l_sr_instance_id
            and (l_refresh_mode = 1
                or (l_refresh_mode = 2 and (p_plan_id, mfq1.number3, mfq1.number4, mfq1.number5) in
                (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid)))))
    group by
    mfq1.number1,
    mfq1.number2,
    mfq1.number3,
    mfq1.number4,
    mfq1.number5,
    mfq1.number6,
    mfq1.number7,
    mfq1.number8,
    mfq1.date3
    ) d,
   msc_system_items msi,
   msc_trading_partners mtp
   where d.plan_id = s.plan_id
   and   d.plan_run_id = s.plan_run_id
   and   d.sr_instance_id = s.sr_instance_id
   and   d.organization_id = s.organization_id
   and   d.inventory_item_id = s.inventory_item_id
   and   d.last_work_date  = s.last_work_date
   and   d.plan_id = msi.plan_id
   and   d.owning_inst_id = msi.sr_instance_id
   and   d.owning_org_id = msi.organization_id
   and   d.inventory_item_id = msi.inventory_item_id
   and   d.owning_inst_id = mtp.sr_instance_id(+)
   and   d.owning_org_id = mtp.sr_tp_id(+)
   and   mtp.partner_type(+)=3;

   msc_phub_util.log(l_stmt_id||', l_qid_pab='||l_qid_pab||', count='||sql%rowcount);
   commit;

   ---------------------------------------------------------------------------
  --- calculate daily demand
  ---------------------------------------------------------------------------
   l_stmt_id :=90;
   select msc_hub_query_s.nextval into l_qid_others from dual;


 insert into msc_hub_query (
    query_id,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    number1,  -- plan_id
    number2,  --- plan_run_id
    number3,  -- sr_instance_id
    number4,  -- organization_id
    number5,  -- inventory_item_id
    number10 --- avg_daily_demand
    )
  select
    l_qid_others,
    l_sysdate,1,l_sysdate,1,1,
    p_plan_id,
    p_plan_run_id,
    mdf.sr_instance_id,
    mdf.organization_id,
    mdf.inventory_item_id,
    sum(nvl(mdf.demand_qty,0)) / l_plan_days
  from msc_demands_f mdf
  where mdf.plan_id = p_plan_id
  and   mdf.plan_run_id = p_plan_run_id
  and   mdf.aggr_type=0
    and (p_plan_id <> con_ods_plan_id
        or (p_plan_id = con_ods_plan_id
            and mdf.sr_instance_id = l_sr_instance_id
            and (l_refresh_mode = 1
                or (l_refresh_mode = 2 and (p_plan_id, mdf.sr_instance_id, mdf.organization_id, mdf.inventory_item_id) in
                (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid)))))
  group by
    l_qid_others,
    l_sysdate,1,l_sysdate,1,1,
    p_plan_id,
    p_plan_run_id,
    mdf.sr_instance_id,
    mdf.organization_id,
    mdf.inventory_item_id;

    msc_phub_util.log(l_stmt_id||', l_qid_others='||l_qid_others||', count='||sql%rowcount);
   commit;

   --------------------------------------------------------------------------------
   --- insert pab,ss,min/max inventory into msc_item_inventory_f table
   -------------------------------------------------------------------------------

    l_stmt_id :=100;

 insert into msc_item_inventory_f (
        CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    PROGRAM_ID,
    PROGRAM_LOGIN_ID,
    PROGRAM_APPLICATION_ID,
    REQUEST_ID,
    ----------------------------
    plan_id,
    plan_run_id,
    io_plan_flag,
    sr_instance_id,
    organization_id,
    owning_inst_id,
    owning_org_id,
    inventory_item_id,
    vmi_flag,
    order_date,
    aggr_type, category_set_id, sr_category_id,
    pab_qty,
    pab_value,
    pab_value2,
    safety_stock_qty,
    safety_stock_value,
    safety_stock_value2,
    safety_stock_days,
    demand_var_ss_qty,
    sup_ltvar_ss_qty,
    transit_ltvar_ss_qty,
    mfg_ltvar_ss_qty,
    total_unpooled_safety_stock,
    min_inventory_level,
    max_inventory_level,
    avg_daily_demand,
    inv_build_target,
    inventory_cost_post,
    inventory_cost_no_post,
    inventory_value_post,
    inventory_value_no_post,
    inventory_value,
    inventory_cost_post2,
    inventory_cost_no_post2,
    inventory_value_post2,
    inventory_value_no_post2,
    inventory_value2)
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
    pab_tbl.plan_id,
    pab_tbl.plan_run_id,
    decode(l_plan_type,4,1,9,1,0) io_plan_flag,

    decode(pab_tbl.organization_id, -1, -23453, pab_tbl.sr_instance_id) sr_instance_id,
    decode(pab_tbl.organization_id, -1, -23453, pab_tbl.organization_id) organization_id,

    decode(sign(pab_tbl.sr_instance_id), -1, l_sr_instance_id, pab_tbl.sr_instance_id) owing_inst_id,
    decode(sign(pab_tbl.organization_id),
        -1, msc_hub_calendar.get_item_org(p_plan_id, pab_tbl.inventory_item_id,
            decode(sign(pab_tbl.sr_instance_id), -1, l_sr_instance_id, pab_tbl.sr_instance_id)),
        pab_tbl.organization_id) owing_inst_id,

    pab_tbl.inventory_item_id,
    nvl(vmi.number6, 0) vmi_flag,
    pab_tbl.order_date,
    to_number(0) aggr_type,
    to_number(-23453) category_set_id,
    to_number(-23453) sr_category_id,
    sum(pab_tbl.pab_qty)  pab_qty,               --- sum(decode(sign(pab_tbl.pab_qty),-1,0,pab_tbl.pab_qty)),
    sum(pab_tbl.pab_value) pab_value,              -- sum(decode(sign(pab_tbl.pab_qty),-1,0,pab_tbl.pab_value)),
    sum((pab_tbl.pab_value) * decode(pab_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))) pab_value2,
    sum(pab_tbl.safety_stock_qty),
    sum(pab_tbl.safety_stock_value),
    sum((pab_tbl.safety_stock_value) * decode(pab_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))) safety_stock_value2,

    (case when l_plan_type in (4, 9) then sum(pab_tbl.safety_stock_days)
        else decode(sum(nvl(pab_tbl.avg_daily_demand,0)), 0, to_number(null),
            sum(pab_tbl.safety_stock_qty)/sum(pab_tbl.avg_daily_demand)) end) safety_stock_days,

    sum(pab_tbl.demand_var_ss_qty),
    sum(pab_tbl.sup_ltvar_ss_qty),
    sum(pab_tbl.transit_ltvar_ss_qty),
    sum(pab_tbl.mfg_ltvar_ss_qty),
    sum(pab_tbl.total_unpooled_safety_stock),
    sum(nvl(pab_tbl.min_inventory_level, pab_tbl.safety_stock_qty)) min_inventory_level,
    sum(pab_tbl.max_inventory_level) max_inventory_level,
    sum(pab_tbl.avg_daily_demand) avg_daily_demand,
    sum(pab_tbl.inv_build_target),
    sum(pab_tbl.inventory_cost_post),
    sum(pab_tbl.inventory_cost_no_post),
    sum(pab_tbl.inventory_value_post),
    sum(pab_tbl.inventory_value_no_post),
    sum(pab_tbl.inventory_value),
    sum(pab_tbl.inventory_cost_post * decode(pab_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))),
    sum(pab_tbl.inventory_cost_no_post * decode(pab_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))),
    sum(pab_tbl.inventory_value_post * decode(pab_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))),
    sum(pab_tbl.inventory_value_no_post * decode(pab_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))),
    sum(pab_tbl.inventory_value * decode(pab_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0)))
   from
     (select
    pab.plan_id,
    pab.plan_run_id,
    pab.sr_instance_id,
    pab.organization_id,
    pab.inventory_item_id,
    nvl(mtp.currency_code, l_owning_currency_code) currency_code,

    pab.order_date,
    --------------------------------------------------------------
    pab.pab_qty,
    pab.pab_qty*m1.standard_cost  pab_value,
    --------------------------------------------------------------
    to_number(null) safety_stock_qty,
    to_number(null) safety_stock_value,
    to_number(null) safety_stock_days,
    to_number(null) demand_var_ss_qty,
    to_number(null) sup_ltvar_ss_qty,
    to_number(null) transit_ltvar_ss_qty,
    to_number(null) mfg_ltvar_ss_qty,
    to_number(null) total_unpooled_safety_stock,
    to_number(null) min_inventory_level,    -- min level
    to_number(null) max_inventory_level,
    -------------------------------------------------------------
    to_number(null) avg_daily_demand,
    to_number(null) inv_build_target,
    to_number(null) inventory_cost_post,
    to_number(null) inventory_cost_no_post,
    to_number(null) inventory_value_post,
    to_number(null) inventory_value_no_post,
    to_number(null) inventory_value

    from
             (select
            p.number1  plan_id,
            p.number2  plan_run_id,
            p.number3  sr_instance_id,
            p.number4  organization_id,
            p.number5  inventory_item_id,
            l.date1   order_date,
            p.date3    pab_acvivity_date,
            LAST_VALUE(p.number10 ignore nulls)
                OVER (PARTITION BY p.number1,p.number2,p.number3,
                p.number4,p.number5
                ORDER by p.date3) pab_qty
        from msc_hub_query l,msc_hub_query p
        where l.query_id =l_qid_last_date and p.query_id=l_qid_pab
            and   l.date3  = p.date3) pab,
        msc_system_items m1,
        msc_trading_partners mtp
        where pab.plan_id = m1.plan_id(+)
        and pab.sr_instance_id = m1.sr_instance_id(+)
        and pab.organization_id = m1.organization_id(+)
        and pab.inventory_item_id = m1.inventory_item_id(+)
        and pab.sr_instance_id = mtp.sr_instance_id(+)
        and pab.organization_id = mtp.sr_tp_id(+)
        and mtp.partner_type(+) = 3
        and l_plan_type<>6           --- exclude sno plan since sno plan, pab is from msc_bis_inv_detail.pab column
        and (p_plan_id <> con_ods_plan_id
          or ( p_plan_id = con_ods_plan_id
            and (l_refresh_mode = 1
                 or (l_refresh_mode = 2 and (p_plan_id, pab.sr_instance_id, pab.organization_id, pab.inventory_item_id) in
                       (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid) ) )
            and trunc(pab.order_date) between l_plan_start_date and l_plan_cutoff_date
          )
        )

        union all
        -- SNO PAB
        select
            p_plan_id,
            p_plan_run_id,
            t.sr_instance_id,
            t.organization_id,
            t.inventory_item_id,
            nvl(mtp.currency_code, l_owning_currency_code) currency_code,
            t.date1 order_date,
            decode(l_plan_type, 6, t.pab, null) pab_qty,
            decode(l_plan_type, 6, t.pab * nvl(msi.standard_cost, 0), null) pab_value,
            to_number(null) safety_stock_qty,
            to_number(null) safety_stock_value,
            to_number(null) safety_stock_days,
            to_number(null) demand_var_ss_qty,
            to_number(null) sup_ltvar_ss_qty,
            to_number(null) transit_ltvar_ss_qty,
            to_number(null) mfg_ltvar_ss_qty,
            to_number(null) total_unpooled_safety_stock,
            to_number(null) min_inventory_level,
            to_number(null) max_inventory_level,
            to_number(null) avg_daily_demand,
            decode(l_plan_type, 6, t.pab, null) inv_build_target,
            to_number(null) inventory_cost_post,
            to_number(null) inventory_cost_no_post,
            to_number(null) inventory_value_post,
            to_number(null) inventory_value_no_post,
            to_number(null) inventory_value
        from
            (select
                mbid.plan_id,
                mbid.sr_instance_id,
                mbid.organization_id,
                mbid.inventory_item_id,
                d.date1,
                mbid.pab,
                mbid.inventory_value_post,
                mbid.inventory_value_no_post,
                mbid.inventory_value,
                rank() over (partition by mbid.plan_id,
                    mbid.sr_instance_id, mbid.organization_id, mbid.inventory_item_id,
                    d.date1 order by mbid.detail_date desc, nvl(mbid.period_type,0) desc) rn
            from msc_bis_inv_detail mbid, msc_hub_query d
            where mbid.plan_id=p_plan_id
                and p_plan_id <> con_ods_plan_id
                and d.query_id=l_qid_last_date1
                and mbid.detail_date <= d.date1
                and ((nvl(mbid.detail_level,0)=1 and nvl(mbid.period_type,0)=1)
                    or (nvl(mbid.detail_level,0)=0 and nvl(mbid.period_type,0)=0))
            ) t,
            msc_system_items msi,
            msc_trading_partners mtp
        where t.rn=1
            and t.plan_id=msi.plan_id(+)
            and t.sr_instance_id=msi.sr_instance_id(+)
            and t.organization_id=msi.organization_id(+)
            and t.inventory_item_id=msi.inventory_item_id(+)
            and t.sr_instance_id=mtp.sr_instance_id(+)
            and t.organization_id=mtp.sr_tp_id(+)
            and mtp.partner_type(+)=3
       union all
        -- safety_stock_qty
        select
            t.plan_id,
            p_plan_run_id,
            t.sr_instance_id,
            t.organization_id,
            t.inventory_item_id,
            nvl(mtp.currency_code, l_owning_currency_code) currency_code,
            t.date1 order_date,
            to_number(null) pab_qty,
            to_number(null) pab_value,
            t.safety_stock_quantity safety_stock_qty,
            t.safety_stock_quantity * nvl(msi.standard_cost,0) safety_stock_value,
            (case when l_plan_type in (4, 9) then t.achieved_days_of_supply else null end) safety_stock_days,

            t.demand_var_ss_percent*t.total_unpooled_safety_stock/100 demand_var_ss_qty,
            t.sup_ltvar_ss_percent*t.total_unpooled_safety_stock/100 sup_ltvar_ss_qty,
            t.transit_ltvar_ss_percent*t.total_unpooled_safety_stock/100 transit_ltvar_ss_qty,
            t.mfg_ltvar_ss_percent*t.total_unpooled_safety_stock/100 mfg_ltvar_ss_qty,
            t.total_unpooled_safety_stock,

            to_number(null) min_inventory_level,
            to_number(null) max_inventory_level,
            to_number(null) avg_daily_demand,
            to_number(null) inv_build_target,
            to_number(null) inventory_cost_post,
            to_number(null) inventory_cost_no_post,
            to_number(null) inventory_value_post,
            to_number(null) inventory_value_no_post,
            to_number(null) inventory_value

        from
            (select
                f.plan_id,
                f.sr_instance_id,
                f.organization_id,
                f.inventory_item_id,
                d.date1,
                f.safety_stock_quantity,
                f.achieved_days_of_supply,
                f.demand_var_ss_percent,
                f.sup_ltvar_ss_percent,
                f.transit_ltvar_ss_percent,
                f.mfg_ltvar_ss_percent,
                f.total_unpooled_safety_stock,
                rank() over (partition by f.plan_id,
                    f.sr_instance_id, f.organization_id, f.inventory_item_id,
                    d.date1 order by f.period_start_date desc) rn
            from msc_safety_stocks f, msc_hub_query d
            where f.plan_id=p_plan_id
                and p_plan_id <> con_ods_plan_id
                and d.query_id=l_qid_last_date1
                and f.period_start_date <= d.date1
            ) t,
            msc_system_items msi,
            msc_trading_partners mtp
        where t.rn=1
            and t.plan_id=msi.plan_id(+)
            and t.sr_instance_id=msi.sr_instance_id(+)
            and t.organization_id=msi.organization_id(+)
            and t.inventory_item_id=msi.inventory_item_id(+)
            and t.sr_instance_id=mtp.sr_instance_id(+)
            and t.organization_id=mtp.sr_tp_id(+)
            and mtp.partner_type(+)=3

      union all
      ------------------------------------------------------------------------------------
      --- in msc_inventory_level, even if it is day bucket, if it is
      --- not a working day, there is no row for it. in such case
      --- we use the previous working day's value of the no-working day bucket inventory value
      --- see bug 6706755
      --- attention: with this, we will not pick up inventory value on not working day in
      --- msc_inventory_level ???
      /*

      here is the very trick part. for min inventory level. in msc_inventory_level table
      if it is not a working day, even if it is a day bucket, there is no value for the
      day in msc_inventory_level. however, there could be safety stock value for the day
      since msc_safety_stock.period_start_date is not aligned with bkt start date
      so for min inventory level (day bucket, non working day), we first get min_quantity
      from msc_inventory_level for the previous working day and if specified, use it
      otherwise, get the ss qty for the bucket day
      */

      /*
      min_inventory_level, max_inventory_level are for DRP and can be ignored for now.
      To preserve old code without affecting performance, we'll only populate items
      in msc_inventory_levels. To populate remaining items from msi.min_minmax_quantity,
      we may add another union later when we support DRP.
      */
      ---------------------------------------------------------------------------------------
        -- min_inventory_level
        select
            t.plan_id,
            p_plan_run_id,
            t.sr_instance_id,
            t.organization_id,
            t.inventory_item_id,
            nvl(mtp.currency_code, l_owning_currency_code) currency_code,
            t.date1 order_date,
            to_number(null) pab_qty,
            to_number(null) pab_value,
            to_number(null) safety_stock_qty,
            to_number(null) safety_stock_value,
            to_number(null) safety_stock_days,
            to_number(null) demand_var_ss_qty,
            to_number(null) sup_ltvar_ss_qty,
            to_number(null) transit_ltvar_ss_qty,
            to_number(null) mfg_ltvar_ss_qty,
            to_number(null) total_unpooled_safety_stock,
            nvl(t.min_quantity, msi.min_minmax_quantity) min_inventory_level,
            nvl(t.max_quantity, msi.max_minmax_quantity) max_inventory_level,
            to_number(null) avg_daily_demand,
            to_number(null) inv_build_target,
            to_number(null) inventory_cost_post,
            to_number(null) inventory_cost_no_post,
            to_number(null) inventory_value_post,
            to_number(null) inventory_value_no_post,
            to_number(null) inventory_value
        from
            (select
                f.plan_id,
                f.sr_instance_id,
                f.organization_id,
                f.inventory_item_id,
                d.date1,
                f.min_quantity,
                f.max_quantity,
                rank() over (partition by f.plan_id,
                    f.sr_instance_id, f.organization_id, f.inventory_item_id,
                    d.date1 order by f.inventory_date desc) rn
            from msc_inventory_levels f, msc_hub_query d
            where f.plan_id=p_plan_id
                and p_plan_id <> con_ods_plan_id
                and d.query_id=l_qid_last_date1
                and f.inventory_date <= d.date1
            ) t,
            msc_system_items msi,
            msc_trading_partners mtp
        where t.rn=1
            and t.plan_id=msi.plan_id(+)
            and t.sr_instance_id=msi.sr_instance_id(+)
            and t.organization_id=msi.organization_id(+)
            and t.inventory_item_id=msi.inventory_item_id(+)
            and t.sr_instance_id=mtp.sr_instance_id(+)
            and t.organization_id=mtp.sr_tp_id(+)
            and mtp.partner_type(+)=3

     union all
       select
        others.number1  plan_id,        -- plan_id
        others.number2  plan_run_id,        --- plan_run_id
        others.number3  sr_instance_id,     -- sr_instance_id
        others.number4  organization_id,    -- organization_id
        others.number5  inventory_item_id,  --- inventory_item_id
        nvl(mtp2.currency_code, l_owning_currency_code) currency_code,
        last_date1.date1    order_date,     -- end date
        ----------------------------------------------------------------------------
        to_number(null)  pab_qty,
        to_number(null)   pab_value,
        ----------------------------------------------------------------------------

        to_number(null) safety_stock_qty,
        to_number(null) safety_stock_value,
        to_number(null) safety_stock_days,
        to_number(null) demand_var_ss_qty,
        to_number(null) sup_ltvar_ss_qty,
        to_number(null) transit_ltvar_ss_qty,
        to_number(null) mfg_ltvar_ss_qty,
        to_number(null) total_unpooled_safety_stock,
        to_number(null) min_inventory_level,    -- min level
        to_number(null) max_inventory_level,
        ----------------------------------------------------------------------------
        others.number10 avg_daily_demand,
        ----------------------------------------------------------------------------
        to_number(null) inv_build_target,
        to_number(null) inventory_cost_post,
        to_number(null) inventory_cost_no_post,
        to_number(null) inventory_value_post,
        to_number(null) inventory_value_no_post,
        to_number(null) inventory_value

    from    msc_hub_query others,
        msc_hub_query last_date1,
        msc_trading_partners mtp2
    where   last_date1.query_id =l_qid_last_date
        and others.query_id = l_qid_others
    and others.number3 = mtp2.sr_instance_id
    and others.number4 = mtp2.sr_tp_id
    and mtp2.partner_type = 3
    and p_plan_id <> con_ods_plan_id

    union all
    -- inventory_value
    select
        p_plan_id,
        p_plan_run_id,
        mbid.sr_instance_id,
        mbid.organization_id,
        mbid.inventory_item_id,
        nvl(mtp.currency_code, l_owning_currency_code) currency_code,
        d.mfg_week_end_date order_date,
        to_number(null) pab_qty,
        to_number(null) pab_value,
        to_number(null) safety_stock_qty,
        to_number(null) safety_stock_value,
        to_number(null) safety_stock_days,
        to_number(null) demand_var_ss_qty,
        to_number(null) sup_ltvar_ss_qty,
        to_number(null) transit_ltvar_ss_qty,
        to_number(null) mfg_ltvar_ss_qty,
        to_number(null) total_unpooled_safety_stock,
        to_number(null) min_inventory_level,
        to_number(null) max_inventory_level,
        to_number(null) avg_daily_demand,
        to_number(null) inv_build_target,
        sum(inventory_cost_post) inventory_cost_post,
        sum(inventory_cost_no_post) inventory_cost_no_post,
        avg(inventory_value_post) inventory_value_post,
        avg(inventory_value_no_post) inventory_value_no_post,
        avg(inventory_value) inventory_value
    from
        msc_bis_inv_detail mbid,
        msc_phub_dates_mv d,
        msc_trading_partners mtp
    where trunc(mbid.detail_date)=d.calendar_date
        and mbid.plan_id=p_plan_id
        and mbid.sr_instance_id=mtp.sr_instance_id(+)
        and mbid.organization_id=mtp.sr_tp_id(+)
        and mtp.partner_type(+)=3
        and nvl(mbid.detail_level,0)=1
        and nvl(mbid.period_type,0)=1
        and p_plan_id <> con_ods_plan_id
    group by
        mbid.sr_instance_id,
        mbid.organization_id,
        mbid.inventory_item_id,
        nvl(mtp.currency_code, l_owning_currency_code),
        d.mfg_week_end_date
     ) pab_tbl,
     msc_currency_conv_mv mcc,
     msc_hub_query vmi
     where mcc.from_currency(+) =pab_tbl.currency_code    --- make sure 'XXX' is not a valid currency code
     and mcc.to_currency(+) = fnd_profile.value('MSC_HUB_CUR_CODE_RPT')
     and mcc.calendar_date(+) = pab_tbl.order_date
     and vmi.query_id(+)=l_qid_vmi_item
     and pab_tbl.plan_id = vmi.number1(+)
     and pab_tbl.sr_instance_id = vmi.number3(+)
     and pab_tbl.organization_id = vmi.number4(+)
     and pab_tbl.inventory_item_id = vmi.number5(+)
     group by
    pab_tbl.plan_id,
    pab_tbl.plan_run_id,
    decode(l_plan_type,4,1,9,1,0),
    decode(pab_tbl.organization_id, -1, -23453, pab_tbl.sr_instance_id),
    decode(pab_tbl.organization_id, -1, -23453, pab_tbl.organization_id),
    decode(sign(pab_tbl.sr_instance_id), -1, l_sr_instance_id, pab_tbl.sr_instance_id),
    decode(sign(pab_tbl.organization_id),
        -1, msc_hub_calendar.get_item_org(p_plan_id, pab_tbl.inventory_item_id,
            decode(sign(pab_tbl.sr_instance_id), -1, l_sr_instance_id, pab_tbl.sr_instance_id)),
        pab_tbl.organization_id),
    pab_tbl.inventory_item_id,
    nvl(vmi.number6, 0),
    pab_tbl.order_date;

    l_rowcount1 := l_rowcount1 + sql%rowcount;
    msc_phub_util.log('msc_item_inventory_f, insert='||sql%rowcount||', l_rowcount1='||l_rowcount1);
    commit;

   --------------------------------------------------------------------------------
   --- insert supply, demand activity into msc_item_orders_f table
   -------------------------------------------------------------------------------

    l_stmt_id :=110;

    insert into msc_item_orders_f (
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    program_id,
    program_login_id,
    program_application_id,
    request_id,
    ------------------------------------------------------------------------
    plan_id,
    plan_run_id,
    io_plan_flag,
    sr_instance_id,
    organization_id,
    owning_inst_id,
    owning_org_id,
    inventory_item_id,
    vmi_flag,
    order_date,
    aggr_type, category_set_id, sr_category_id,
    ------------------------------------------------------------------------
    demand_qty,
    supply_qty,
    pegged_to_excess_qty,
    sup_end_pgd_to_fcst,
    sup_end_pgd_to_so,
    sup_end_pgd_to_ss,
    sup_end_pgd_to_excess,
    dmd_pgd_to_schd_recp,
    dmd_pgd_to_plnd_order,
    dmd_pgd_to_onhand,
    sup_end_pgd_to_fcst_value,
    sup_end_pgd_to_so_value,
    sup_end_pgd_to_ss_value,
    sup_end_pgd_to_excess_value,
    dmd_pgd_to_schd_recp_value,
    dmd_pgd_to_plnd_order_value,
    dmd_pgd_to_onhand_value,
    sup_end_pgd_to_fcst_value2,
    sup_end_pgd_to_so_value2,
    sup_end_pgd_to_ss_value2,
    sup_end_pgd_to_excess_value2,
    dmd_pgd_to_schd_recp_value2,
    dmd_pgd_to_plnd_order_value2,
    dmd_pgd_to_onhand_value2,
    planned_order_qty,
    indep_demand_qty,
    indep_demand_value,
    dep_demand_qty,
    sales_order_value,
    sales_order_value2,
    return_order_value,
    make_order_qty,
    make_order_leadtime,
    make_order_count,
    stock_outs_count,
    no_activity_item_count,
    days_in_bkt,
    item_leadtime,
    avg_daily_demand,
    onhand_qty,
    onhand_value,
    onhand_value2,
    onhand_usable,
    intransit_usable,
    plnd_xfer_usable,
    onhand_defective,
    intransit_defective,
    plnd_xfer_defective,
    supply_qty_usable,
    supply_qty_defective,
    scheduled_rept_qty,
    scheduled_rept_value,
    scheduled_rept_value2,
    forecast_qty)
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
    ---------------------------------------------------
    p_plan_id,
    p_plan_run_id,
    decode(l_plan_type,4,1,9,1,0) io_plan_flag,
    order_tbl.sr_instance_id,
    order_tbl.organization_id,
    decode(order_tbl.sr_instance_id,-23453, l_sr_instance_id,order_tbl.sr_instance_id) owing_inst_id,
    decode(order_tbl.organization_id,
                     -23453,msc_hub_calendar.get_item_org(p_plan_id,order_tbl.inventory_item_id,
                                                          decode(order_tbl.sr_instance_id,-23453,l_sr_instance_id,
                              order_tbl.sr_instance_id)),
                 order_tbl.organization_id) owning_org_id,
    order_tbl.inventory_item_id,
    order_tbl.vmi_flag,
    order_tbl.order_date,
    to_number(0) aggr_type,
    to_number(-23453) category_set_id,
    to_number(-23453) sr_category_id,
    --------------------------------------------------
    sum(order_tbl.demand_qty),
    sum(order_tbl.supply_qty),
    sum(order_tbl.pegged_to_excess_qty),
    sum(order_tbl.sup_end_pgd_to_fcst),
    sum(order_tbl.sup_end_pgd_to_so),
    sum(order_tbl.sup_end_pgd_to_ss),
    sum(order_tbl.sup_end_pgd_to_excess),
    sum(order_tbl.dmd_pgd_to_schd_recp),
    sum(order_tbl.dmd_pgd_to_plnd_order),
    sum(order_tbl.dmd_pgd_to_onhand),
    sum(order_tbl.sup_end_pgd_to_fcst_value),
    sum(order_tbl.sup_end_pgd_to_so_value),
    sum(order_tbl.sup_end_pgd_to_ss_value),
    sum(order_tbl.sup_end_pgd_to_excess_value),
    sum(order_tbl.dmd_pgd_to_schd_recp_value),
    sum(order_tbl.dmd_pgd_to_plnd_order_value),
    sum(order_tbl.dmd_pgd_to_onhand_value),
    sum(order_tbl.sup_end_pgd_to_fcst_value * decode(order_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0))),
    sum(order_tbl.sup_end_pgd_to_so_value * decode(order_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0))),
    sum(order_tbl.sup_end_pgd_to_ss_value * decode(order_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0))),
    sum(order_tbl.sup_end_pgd_to_excess_value * decode(order_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0))),
    sum(order_tbl.dmd_pgd_to_schd_recp_value * decode(order_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0))),
    sum(order_tbl.dmd_pgd_to_plnd_order_value * decode(order_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0))),
    sum(order_tbl.dmd_pgd_to_onhand_value * decode(order_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0))),
    sum(order_tbl.planned_order_qty),
    sum(order_tbl.indep_demand_qty),
    sum(order_tbl.indep_demand_value),
    sum(order_tbl.dep_demand_qty),
    sum(order_tbl.sales_order_value),
    sum(order_tbl.sales_order_value * decode(order_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0))) sales_order_value2,
    sum(order_tbl.return_order_value),
    sum(order_tbl.make_order_qty),
    sum(order_tbl.make_order_leadtime),
    sum(order_tbl.make_order_count),
    sum(order_tbl.stock_outs_count),
    sum(order_tbl.no_activity_item_count),
    sum(order_tbl.days_in_bkt),
    sum(order_tbl.item_leadtime),
    sum(order_tbl.avg_daily_demand),
    sum(order_tbl.onhand_qty),
    sum(order_tbl.onhand_qty * nvl(msi.standard_cost,0)) onhand_value,
    sum(order_tbl.onhand_qty * nvl(msi.standard_cost,0) *
        decode(order_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0))) onhand_value2,
    sum(order_tbl.onhand_usable),
    sum(order_tbl.intransit_usable),
    sum(order_tbl.plnd_xfer_usable),
    sum(order_tbl.onhand_defective),
    sum(order_tbl.intransit_defective),
    sum(order_tbl.plnd_xfer_defective),
    sum(order_tbl.supply_qty_usable),
    sum(order_tbl.supply_qty_defective),
    sum(order_tbl.scheduled_rept_qty),
    sum(order_tbl.scheduled_rept_qty * nvl(msi.standard_cost,0)) scheduled_rept_value,
    sum(order_tbl.scheduled_rept_qty * nvl(msi.standard_cost,0) *
        decode(order_tbl.currency_code,
        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0))) scheduled_rept_value2,
    sum(order_tbl.forecast_qty)
     from
        (
    select
        sd.number1  plan_id,    -- plan_id
        sd.number2  plan_run_id,    --- plan_run_id
        sd.number3  sr_instance_id, -- sr_instance_id
        sd.number4  organization_id,    -- organization_id
        sd.char1 currency_code,
        sd.number5  inventory_item_id,  --- inventory_item_id
        sd.number6  vmi_flag,   -- vmi flag
        sd.date3    order_date,
        -------------------------------------------------
        sd.number11 + nvl(sd.number9,0) demand_qty,     -- total demand -- in drp, supply(1,2,51) is demand
        sd.number12 supply_qty,     -- total supply
        sd.number13 planned_order_qty,  -- planned order qty
        sd.number14 indep_demand_qty,   -- indep_demand_qty
        sd.number15 indep_demand_value, --- indep_demand_value
        sd.number16 dep_demand_qty,     -- total dep demand
        sd.number17 sales_order_value,  -- sales_order_value
        sd.number18 return_order_value, -- return order value
        sd.number19 make_order_qty,     -- make order qty
        sd.number20 make_order_leadtime,    -- make order leadtime
        sd.number21 make_order_count,   -- make order count
        sd_item.number11 days_in_bkt,   -- days in bucket
        sd.number23     item_leadtime,
        sd.number24     onhand_qty,
        sd.number26     onhand_usable,
        sd.number27     intransit_usable,
        sd.number28     plnd_xfer_usable,
        sd.number29     onhand_defective,
        sd.number30     intransit_defective,
        sd.number31     plnd_xfer_defective,
        sd.number32     supply_qty_usable,
        sd.number33     supply_qty_defective,

        sd.number25     scheduled_rept_qty,
        sd.number22     forecast_qty,   --- forecast qty
        ----------------------------------------
        nvl(others.number10,0)  avg_daily_demand,
        ---------------------------------------------------------------
        to_number(null) pegged_to_excess_qty,
        to_number(0) sup_end_pgd_to_fcst,
        to_number(0) sup_end_pgd_to_so,
        to_number(0) sup_end_pgd_to_ss,
        to_number(0) sup_end_pgd_to_excess,
        to_number(0) dmd_pgd_to_schd_recp,
        to_number(0) dmd_pgd_to_plnd_order,
        to_number(0) dmd_pgd_to_onhand,
        to_number(0) sup_end_pgd_to_fcst_value,
        to_number(0) sup_end_pgd_to_so_value,
        to_number(0) sup_end_pgd_to_ss_value,
        to_number(0) sup_end_pgd_to_excess_value,
        to_number(0) dmd_pgd_to_schd_recp_value,
        to_number(0) dmd_pgd_to_plnd_order_value,
        to_number(0) dmd_pgd_to_onhand_value,
        --------------------------------------------------------------
        to_number(null) no_activity_item_count,
        to_number(null) stock_outs_count

    from msc_hub_query sd,
         msc_hub_query sd_item,
         msc_hub_query others
    where sd.query_id =l_qid_pab
    and   sd_item.query_id =l_qid_sd_item
    and   sd.number1 = sd_item.number1
    and   sd.number2 = sd_item.number2
    and   sd.number3 = sd_item.number3
    and   sd.number4 = sd_item.number4
    and   sd.number5 = sd_item.number5
    and   sd.date3 =  sd_item.date3
    and  others.query_id(+) = l_qid_others
    and  others.number1(+)= sd.number1
    and  others.number2(+)= sd.number2
    and  others.number3 (+)=sd.number3
    and others.number4(+)= sd.number4
    and others.number5 (+)= sd.number5   --- note, need outer join since some item may do not have demand(only supply)
    and (p_plan_id <> con_ods_plan_id
      or ( p_plan_id = con_ods_plan_id
        and (l_refresh_mode = 1
             or (l_refresh_mode = 2 and (p_plan_id, sd.number3, sd.number4, sd.number5) in
                   (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid) ) )
        and trunc(sd.date3) between l_plan_start_date and l_plan_cutoff_date
      )
    )

    union all
    select
        mfp.plan_id,
        p_plan_run_id,
        mfp.sr_instance_id,
        mfp.organization_id,
        nvl(mtp.currency_code, l_owning_currency_code),
        mfp.inventory_item_id,
        nvl(peg_vmi.number6, 0) vmi_flag,
        trunc(nvl(mfp.supply_date, nvl(ms.firm_date,ms.new_schedule_date))),
        to_number(null) demand_qty,
        to_number(null) supply_qty,
        to_number(null) planned_order_qty,
        to_number(null) indep_demand_qty,
        to_number(null) indep_demand_value,
        to_number(null) dep_demand_qty,
        to_number(null) sales_order_value,
        to_number(null) return_order_value,
        to_number(null) make_order_qty,
        to_number(null) make_order_leadtime,
        to_number(null) make_order_count,
        to_number(null) days_in_bkt,
        to_number(null) item_leadtime,
        to_number(null) onhand_qty,
        to_number(null) onhand_usable,
        to_number(null) intransit_usable,
        to_number(null) plnd_xfer_usable,
        to_number(null) onhand_defective,
        to_number(null) intransit_defective,
        to_number(null) plnd_xfer_defective,
        to_number(null) supply_qty_usable,
        to_number(null) supply_qty_defective,
        to_number(null) scheduled_rept_qty,
        to_number(null) forecast_qty,
        to_number(null) avg_daily_demand,
        sum(mfp.allocated_quantity) pegged_to_excess_qty,
        to_number(0) sup_end_pgd_to_fcst,
        to_number(0) sup_end_pgd_to_so,
        to_number(0) sup_end_pgd_to_ss,
        to_number(0) sup_end_pgd_to_excess,
        to_number(0) dmd_pgd_to_schd_recp,
        to_number(0) dmd_pgd_to_plnd_order,
        to_number(0) dmd_pgd_to_onhand,
        to_number(0) sup_end_pgd_to_fcst_value,
        to_number(0) sup_end_pgd_to_so_value,
        to_number(0) sup_end_pgd_to_ss_value,
        to_number(0) sup_end_pgd_to_excess_value,
        to_number(0) dmd_pgd_to_schd_recp_value,
        to_number(0) dmd_pgd_to_plnd_order_value,
        to_number(0) dmd_pgd_to_onhand_value,
        to_number(null) no_activity_item_count,
        to_number(null) stock_outs_count
    from
        msc_full_pegging mfp,
        msc_hub_query peg_vmi,
        msc_supplies ms,
        msc_trading_partners mtp
    where ms.plan_id=mfp.plan_id
        and ms.transaction_id=mfp.transaction_id
        and ms.sr_instance_id=mfp.sr_instance_id
        and mfp.plan_id=p_plan_id
        and mfp.demand_id=-1
        and mfp.plan_id=peg_vmi.number1(+)
        and mfp.sr_instance_id=peg_vmi.number3(+)
        and mfp.organization_id=peg_vmi.number4(+)
        and mfp.inventory_item_id=peg_vmi.number5(+)
        and peg_vmi.query_id(+)=l_qid_vmi_item
        and mtp.partner_type(+)=3
        and mtp.sr_instance_id(+)=mfp.sr_instance_id
        and mtp.sr_tp_id(+)=mfp.organization_id
        and p_plan_id <> con_ods_plan_id
    group by
        mfp.plan_id,
        p_plan_run_id,
        mfp.sr_instance_id,
        mfp.organization_id,
        nvl(mtp.currency_code, l_owning_currency_code),
        mfp.inventory_item_id,
        nvl(peg_vmi.number6, 0),
        trunc(nvl(mfp.supply_date, nvl(ms.firm_date,ms.new_schedule_date)))

    union all
    select
        mfp.plan_id,
        p_plan_run_id,
        mfp.sr_instance_id,
        mfp.organization_id,
        nvl(mtp.currency_code, l_owning_currency_code),
        mfp.inventory_item_id,
        msi.vmi_flag,
        trunc(nvl(ms.firm_date, ms.new_schedule_date)),
        to_number(null) demand_qty,
        to_number(null) supply_qty,
        to_number(null) planned_order_qty,
        to_number(null) indep_demand_qty,
        to_number(null) indep_demand_value,
        to_number(null) dep_demand_qty,
        to_number(null) sales_order_value,
        to_number(null) return_order_value,
        to_number(null) make_order_qty,
        to_number(null) make_order_leadtime,
        to_number(null) make_order_count,
        to_number(null) days_in_bkt,
        to_number(null) item_leadtime,
        to_number(null) onhand_qty,
        to_number(null) onhand_usable,
        to_number(null) intransit_usable,
        to_number(null) plnd_xfer_usable,
        to_number(null) onhand_defective,
        to_number(null) intransit_defective,
        to_number(null) plnd_xfer_defective,
        to_number(null) supply_qty_usable,
        to_number(null) supply_qty_defective,
        to_number(null) scheduled_rept_qty,
        to_number(null) forecast_qty,
        to_number(null) avg_daily_demand,
        to_number(null) pegged_to_excess_qty,
        sum(decode(md.origination_type, 29, mfp.allocated_quantity, 0)) sup_end_pgd_to_fcst,
        sum(decode(md.origination_type, 30, mfp.allocated_quantity, 0)) sup_end_pgd_to_so,
        sum(decode(mfp2.demand_id, -2, mfp.allocated_quantity, 0)) sup_end_pgd_to_ss,
        sum(decode(mfp2.demand_id, -1, mfp.allocated_quantity, 0)) sup_end_pgd_to_excess,
        to_number(0) dmd_pgd_to_schd_recp,
        to_number(0) dmd_pgd_to_plnd_order,
        to_number(0) dmd_pgd_to_onhand,
        sum(decode(md.origination_type, 29, mfp.allocated_quantity,0) *
            nvl(msi.standard_cost,0)) sup_end_pgd_to_fcst_value,
        sum(decode(md.origination_type, 30, mfp.allocated_quantity, 0) *
            nvl(msi.standard_cost,0)) sup_end_pgd_to_so_value,
        sum(decode(mfp2.demand_id, -2, mfp.allocated_quantity, 0) *
            nvl(msi.standard_cost,0)) sup_end_pgd_to_ss_value,
        sum(decode(mfp2.demand_id, -1, mfp.allocated_quantity, 0) *
            nvl(msi.standard_cost,0)) sup_end_pgd_to_excess_value,
        to_number(0) dmd_pgd_to_schd_recp_value,
        to_number(0) dmd_pgd_to_plnd_order_value,
        to_number(0) dmd_pgd_to_onhand_value,
        to_number(null) no_activity_item_count,
        to_number(null) stock_outs_count
    from
        msc_full_pegging mfp,
        msc_full_pegging mfp2,
        (select
            msi_2.plan_id,
            msi_2.sr_instance_id,
            msi_2.organization_id,
            msi_2.inventory_item_id,
            msi_2.standard_cost,
            msi_2.list_price,
            msi_2.average_discount,
            nvl(peg_vmi.number6, 0) vmi_flag
        from
            msc_system_items msi_2,
            msc_hub_query peg_vmi
        where peg_vmi.query_id(+) = l_qid_vmi_item
            and peg_vmi.number1(+) = msi_2.plan_id
            and peg_vmi.number3(+) = msi_2.sr_instance_id
            and peg_vmi.number4(+) = msi_2.organization_id
            and peg_vmi.number5(+) = msi_2.inventory_item_id) msi,
        msc_demands md,
        msc_trading_partners mtp,
        msc_supplies ms
    where mfp.plan_id=mfp2.plan_id
        and mfp.end_pegging_id=mfp2.end_pegging_id
        and mfp2.plan_id=md.plan_id(+)
        and mfp2.demand_id=md.demand_id(+)
        and mfp2.prev_pegging_id is null
        and mfp.plan_id=p_plan_id
        and mtp.partner_type=3
        and mtp.sr_instance_id=mfp.sr_instance_id
        and mtp.sr_tp_id=mfp.organization_id
        and mfp.plan_id=msi.plan_id
        and mfp.sr_instance_id=msi.sr_instance_id
        and mfp.organization_id=msi.organization_id
        and mfp.inventory_item_id=msi.inventory_item_id
        and mfp.plan_id=ms.plan_id
        and mfp.sr_instance_id=ms.sr_instance_id
        and mfp.transaction_id=ms.transaction_id
        and p_plan_id <> con_ods_plan_id
    group by
        mfp.plan_id,
        p_plan_run_id,
        mfp.sr_instance_id,
        mfp.organization_id,
        nvl(mtp.currency_code, l_owning_currency_code),
        mfp.inventory_item_id,
        msi.vmi_flag,
        trunc(nvl(ms.firm_date, ms.new_schedule_date))

    union all
    select
        mfp.plan_id,
        p_plan_run_id,
        mfp.sr_instance_id,
        mfp.organization_id,
        nvl(mtp.currency_code, l_owning_currency_code),
        mfp.inventory_item_id,
        msi.vmi_flag,
        trunc(mfp.demand_date),
        to_number(null) demand_qty,
        to_number(null) supply_qty,
        to_number(null) planned_order_qty,
        to_number(null) indep_demand_qty,
        to_number(null) indep_demand_value,
        to_number(null) dep_demand_qty,
        to_number(null) sales_order_value,
        to_number(null) return_order_value,
        to_number(null) make_order_qty,
        to_number(null) make_order_leadtime,
        to_number(null) make_order_count,
        to_number(null) days_in_bkt,
        to_number(null) item_leadtime,
        to_number(null) onhand_qty,
        to_number(null) onhand_usable,
        to_number(null) intransit_usable,
        to_number(null) plnd_xfer_usable,
        to_number(null) onhand_defective,
        to_number(null) intransit_defective,
        to_number(null) plnd_xfer_defective,
        to_number(null) supply_qty_usable,
        to_number(null) supply_qty_defective,
        to_number(null) scheduled_rept_qty,
        to_number(null) forecast_qty,
        to_number(null) avg_daily_demand,
        to_number(null) pegged_to_excess_qty,
        to_number(0) sup_end_pgd_to_fcst,
        to_number(0) sup_end_pgd_to_so,
        to_number(0) sup_end_pgd_to_ss,
        to_number(0) sup_end_pgd_to_excess,
        sum(case when supply_type in (1,2,3,11,12) then allocated_quantity else 0 end) dmd_pgd_to_schd_recp,
        sum(case when supply_type in (5,76,77,78,79) then allocated_quantity else 0 end) dmd_pgd_to_plnd_order,
        sum(case when supply_type in (18) then allocated_quantity else 0 end) dmd_pgd_to_onhand,
        to_number(0) sup_end_pgd_to_fcst_value,
        to_number(0) sup_end_pgd_to_so_value,
        to_number(0) sup_end_pgd_to_ss_value,
        to_number(0) sup_end_pgd_to_excess_value,
        sum((case when supply_type in (1,2,3,11,12) then allocated_quantity else 0 end) *
            nvl(msi.list_price,0)*(1-nvl(msi.average_discount,0)/100)) dmd_pgd_to_schd_recp_value,
        sum((case when supply_type in (5,76,77,78,79) then allocated_quantity else 0 end) *
            nvl(msi.list_price,0)*(1-nvl(msi.average_discount,0)/100)) dmd_pgd_to_plnd_order_value,
        sum((case when supply_type in (18) then allocated_quantity else 0 end) *
            nvl(msi.list_price,0)*(1-nvl(msi.average_discount,0)/100)) dmd_pgd_to_onhand_value,
        to_number(null) no_activity_item_count,
        to_number(null) stock_outs_count
    from
        msc_full_pegging mfp,
        (select
            msi_2.plan_id,
            msi_2.sr_instance_id,
            msi_2.organization_id,
            msi_2.inventory_item_id,
            msi_2.list_price,
            msi_2.average_discount,
            nvl(peg_vmi.number6, 0) vmi_flag
        from
            msc_system_items msi_2,
            msc_hub_query peg_vmi
        where peg_vmi.query_id(+) = l_qid_vmi_item
            and peg_vmi.number1(+) = msi_2.plan_id
            and peg_vmi.number3(+) = msi_2.sr_instance_id
            and peg_vmi.number4(+) = msi_2.organization_id
            and peg_vmi.number5(+) = msi_2.inventory_item_id) msi,
        msc_demands md,
        msc_trading_partners mtp
    where mfp.plan_id=md.plan_id
        and mfp.demand_id=md.demand_id
        and md.origination_type in (5,6,7,8,9,10,11,12,15,22,24,27,29,30)
        and mfp.plan_id=p_plan_id
        and mtp.partner_type(+)=3
        and mtp.sr_instance_id(+)=mfp.sr_instance_id
        and mtp.sr_tp_id(+)=mfp.organization_id
        and mfp.plan_id=msi.plan_id
        and mfp.sr_instance_id=msi.sr_instance_id
        and mfp.organization_id=msi.organization_id
        and mfp.inventory_item_id=msi.inventory_item_id
        and p_plan_id <> con_ods_plan_id
    group by
        mfp.plan_id,
        p_plan_run_id,
        mfp.sr_instance_id,
        mfp.organization_id,
        nvl(mtp.currency_code, l_owning_currency_code),
        mfp.inventory_item_id,
        msi.vmi_flag,
        trunc(mfp.demand_date)

   union all
   select
        plan_id,
        plan_run_id,
        me.sr_instance_id,
        me.ORGANIZATION_ID,
        nvl(mtp.currency_code, l_owning_currency_code),
        me.INVENTORY_ITEM_ID,
        nvl(vmi1.number6,0) vmi_flag,
        me.ANALYSIS_DATE order_date,  --- bkt_start_date
        -----------------------------------------------------------------------
        to_number(null) demand_qty,     -- total demand
        to_number(null) supply_qty,     -- total supply
        to_number(null) planned_order_qty,  -- planned order qty
        to_number(null) indep_demand_qty,   -- indep_demand_qty
        to_number(null) indep_demand_value, --- indep_demand_value
        to_number(null) dep_demand_qty,     -- total dep demand
        to_number(null) sales_order_value,  --sales_order_value
        to_number(null) return_order_value, -- return order value
        to_number(null) make_order_qty,     -- make order qty
        to_number(null) make_order_leadtime,    -- make order leadtime
        to_number(null) make_order_count,   -- make order count
        to_number(null) days_in_bkt,   -- days in bucket
        to_number(null) item_leadtime,
        to_number(null) onhand_qty,
        to_number(null) onhand_usable,
        to_number(null) intransit_usable,
        to_number(null) plnd_xfer_usable,
        to_number(null) onhand_defective,
        to_number(null) intransit_defective,
        to_number(null) plnd_xfer_defective,
        to_number(null) supply_qty_usable,
        to_number(null) supply_qty_defective,

        to_number(null) scheduled_rept_qty,
        to_number(null) forecast_qty,
        to_number(null) avg_daily_demand,

        ------------------------------------------------------------------------------
        to_number(null) pegged_to_excess_qty,
        to_number(0) sup_end_pgd_to_fcst,
        to_number(0) sup_end_pgd_to_so,
        to_number(0) sup_end_pgd_to_ss,
        to_number(0) sup_end_pgd_to_excess,
        to_number(0) dmd_pgd_to_schd_recp,
        to_number(0) dmd_pgd_to_plnd_order,
        to_number(0) dmd_pgd_to_onhand,
        to_number(0) sup_end_pgd_to_fcst_value,
        to_number(0) sup_end_pgd_to_so_value,
        to_number(0) sup_end_pgd_to_ss_value,
        to_number(0) sup_end_pgd_to_excess_value,
        to_number(0) dmd_pgd_to_schd_recp_value,
        to_number(0) dmd_pgd_to_plnd_order_value,
        to_number(0) dmd_pgd_to_onhand_value,
        ----------------------------------------------------------
        sum(decode(EXCEPTION_TYPE,5,EXCEPTION_COUNT,0) )no_activity_item_count,
        sum(decode(EXCEPTION_TYPE,2,exception_count,0)) stock_outs_count
  from  msc_exceptions_f me,
        msc_hub_query vmi1,
        msc_trading_partners mtp
  where me.EXCEPTION_TYPE in (5,2)
      and me.plan_id = p_plan_id
      and me.plan_run_id = p_plan_run_id
      and me.aggr_type=0
      and vmi1.number1(+) = me.plan_id
      and vmi1.number3(+) = me.sr_instance_id
      and vmi1.number4(+) = me.organization_id
      and vmi1.number5(+) = me.inventory_item_id
      and vmi1.number2(+) = me.plan_run_id
      and vmi1.query_id(+)=l_qid_vmi_item
        and mtp.partner_type(+)=3
        and mtp.sr_instance_id(+)=me.sr_instance_id
        and mtp.sr_tp_id(+)=me.organization_id
      and p_plan_id <> con_ods_plan_id
      group by
        plan_id,
        plan_run_id,
        me.sr_instance_id,
        me.ORGANIZATION_ID,
        nvl(mtp.currency_code, l_owning_currency_code),
        me.INVENTORY_ITEM_ID,
        nvl(vmi1.number6,0),
        me.ANALYSIS_DATE
    ) order_tbl,
    msc_currency_conv_mv mcc,
    msc_system_items msi
  where mcc.from_currency(+) = order_tbl.currency_code
    and mcc.to_currency(+) = fnd_profile.value('MSC_HUB_CUR_CODE_RPT')
    and mcc.calendar_date(+) = order_tbl.order_date
    and order_tbl.plan_id=msi.plan_id(+)
    and order_tbl.sr_instance_id=msi.sr_instance_id(+)
    and order_tbl.organization_id=msi.organization_id(+)
    and order_tbl.inventory_item_id=msi.inventory_item_id(+)
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
    p_plan_id,
    p_plan_run_id,
    decode(l_plan_type,4,1,9,1,0),
    order_tbl.sr_instance_id,
    order_tbl.organization_id,
    decode(order_tbl.sr_instance_id,-23453, l_sr_instance_id,order_tbl.sr_instance_id),
    decode(order_tbl.organization_id,
                     -23453,msc_hub_calendar.get_item_org(p_plan_id,order_tbl.inventory_item_id,
                                                          decode(order_tbl.sr_instance_id,-23453,l_sr_instance_id,
                              order_tbl.sr_instance_id)),
                 order_tbl.organization_id),
    order_tbl.inventory_item_id,
    order_tbl.vmi_flag,
    order_tbl.order_date;

    l_rowcount2 := l_rowcount2 + sql%rowcount;
    msc_phub_util.log('msc_item_orders_f, insert='||sql%rowcount||', l_rowcount2='||l_rowcount2);
    commit;

    if (l_rowcount1 > 0) then
        summarize_item_inventory_f(errbuf, retcode, p_plan_id, p_plan_run_id);
    end if;

    if (l_rowcount2 > 0) then
        summarize_item_orders_f(errbuf, retcode, p_plan_id, p_plan_run_id);
    end if;

    msc_phub_util.log('msc_item_pkg.populate_details: complete');

  exception
    when no_data_found then

    retcode :=2;
    msc_phub_util.log(to_char(SQLCODE) || ':' || sqlerrm || ' in stmt_id=' || l_stmt_id);
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(fnd_log.LEVEL_UNEXPECTED,
            l_api_name,
            to_char(SQLCODE) || ':' || sqlerrm || ' in stmt_id=' || l_stmt_id);
    end if;

    errbuf := sqlerrm;
    when others then
    msc_phub_util.log(to_char(SQLCODE) || ':' || sqlerrm || ' in stmt_id=' || l_stmt_id);
    retcode :=2;
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(fnd_log.LEVEL_UNEXPECTED,
            l_api_name,
            to_char(SQLCODE) || ':' || sqlerrm || ' in stmt_id=' || l_stmt_id);

    end if;



    errbuf := sqlerrm;
end populate_details;


    procedure summarize_item_inventory_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_category_set_id1 number := fnd_profile.value('MSC_HUB_CAT_SET_ID_1');
    begin
        msc_phub_util.log('msc_item_pkg.summarize_item_inventory_f');
        retcode := 0;
        errbuf := '';

        delete from msc_item_inventory_f
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id and aggr_type>0;
        msc_phub_util.log('msc_item_pkg.summarize_item_inventory_f, delete='||sql%rowcount);
        commit;

        -- level 1
        insert into msc_item_inventory_f (
            plan_id, plan_run_id, io_plan_flag,
            sr_instance_id, organization_id, owning_inst_id, owning_org_id,
            inventory_item_id,
            vmi_flag, order_date,
            aggr_type, category_set_id, sr_category_id,
            pab_qty,
            pab_value,
            pab_value2,
            safety_stock_qty,
            safety_stock_value,
            safety_stock_value2,
            safety_stock_days,
            demand_var_ss_qty,
            sup_ltvar_ss_qty,
            transit_ltvar_ss_qty,
            mfg_ltvar_ss_qty,
            total_unpooled_safety_stock,
            min_inventory_level,
            max_inventory_level,
            avg_daily_demand,
            inv_build_target,
            inventory_cost_post,
            inventory_cost_no_post,
            inventory_value_post,
            inventory_value_no_post,
            inventory_value,
            inventory_cost_post2,
            inventory_cost_no_post2,
            inventory_value_post2,
            inventory_value_no_post2,
            inventory_value2,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category (42, 43, 44)
        select
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id, f.owning_inst_id, f.owning_org_id,
            to_number(-23453) inventory_item_id,
            f.vmi_flag, f.order_date,
            to_number(42) aggr_type,
            l_category_set_id1 category_set_id,
            nvl(q.sr_category_id, -23453),
            sum(f.pab_qty),
            sum(f.pab_value),
            sum(f.pab_value2),
            sum(f.safety_stock_qty),
            sum(f.safety_stock_value),
            sum(f.safety_stock_value2),
            sum(f.safety_stock_days),
            sum(f.demand_var_ss_qty),
            sum(f.sup_ltvar_ss_qty),
            sum(f.transit_ltvar_ss_qty),
            sum(f.mfg_ltvar_ss_qty),
            sum(f.total_unpooled_safety_stock),
            sum(f.min_inventory_level),
            sum(f.max_inventory_level),
            sum(f.avg_daily_demand),
            sum(f.inv_build_target),
            sum(f.inventory_cost_post),
            sum(f.inventory_cost_no_post),
            sum(f.inventory_value_post),
            sum(f.inventory_value_no_post),
            sum(f.inventory_value),
            sum(f.inventory_cost_post2),
            sum(f.inventory_cost_no_post2),
            sum(f.inventory_value_post2),
            sum(f.inventory_value_no_post2),
            sum(f.inventory_value2),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_item_inventory_f f,
            msc_phub_item_categories_mv q
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
            and f.owning_inst_id=q.sr_instance_id(+)
            and f.owning_org_id=q.organization_id(+)
            and f.inventory_item_id=q.inventory_item_id(+)
            and q.category_set_id(+)=l_category_set_id1
        group by
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id, f.owning_inst_id, f.owning_org_id,
            f.vmi_flag, f.order_date,
            nvl(q.sr_category_id, -23453);

        msc_phub_util.log('msc_item_pkg.summarize_item_inventory_f, level1='||sql%rowcount);
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_item_pkg.summarize_item_inventory_f: '||sqlerrm;
            raise;
    end summarize_item_inventory_f;


    procedure summarize_item_orders_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_category_set_id1 number := fnd_profile.value('MSC_HUB_CAT_SET_ID_1');
    begin
        msc_phub_util.log('msc_item_pkg.summarize_item_orders_f');
        retcode := 0;
        errbuf := '';

        delete from msc_item_orders_f
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id and aggr_type>0;
        msc_phub_util.log('msc_item_pkg.summarize_item_orders_f, delete='||sql%rowcount);
        commit;

        -- level 1
        insert into msc_item_orders_f (
            plan_id, plan_run_id, io_plan_flag,
            sr_instance_id, organization_id, owning_inst_id, owning_org_id,
            inventory_item_id,
            vmi_flag, order_date,
            aggr_type, category_set_id, sr_category_id,
            demand_qty,
            supply_qty,
            pegged_to_excess_qty,
            planned_order_qty,
            indep_demand_qty,
            indep_demand_value,
            dep_demand_qty,
            sales_order_value,
            sales_order_value2,
            return_order_value,
            make_order_qty,
            make_order_leadtime,
            make_order_count,
            stock_outs_count,
            no_activity_item_count,
            days_in_bkt,
            item_leadtime,
            avg_daily_demand,
            onhand_qty,
            onhand_value,
            onhand_value2,
            onhand_usable,
            intransit_usable,
            plnd_xfer_usable,
            onhand_defective,
            intransit_defective,
            plnd_xfer_defective,
            supply_qty_usable,
            supply_qty_defective,
            scheduled_rept_qty,
            scheduled_rept_value,
            scheduled_rept_value2,
            forecast_qty,
            sup_end_pgd_to_fcst,
            sup_end_pgd_to_so,
            sup_end_pgd_to_ss,
            sup_end_pgd_to_excess,
            dmd_pgd_to_schd_recp,
            dmd_pgd_to_plnd_order,
            dmd_pgd_to_onhand,
            sup_end_pgd_to_fcst_value,
            sup_end_pgd_to_so_value,
            sup_end_pgd_to_ss_value,
            sup_end_pgd_to_excess_value,
            dmd_pgd_to_schd_recp_value,
            dmd_pgd_to_plnd_order_value,
            dmd_pgd_to_onhand_value,
            sup_end_pgd_to_fcst_value2,
            sup_end_pgd_to_so_value2,
            sup_end_pgd_to_ss_value2,
            sup_end_pgd_to_excess_value2,
            dmd_pgd_to_schd_recp_value2,
            dmd_pgd_to_plnd_order_value2,
            dmd_pgd_to_onhand_value2,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category (42, 43, 44)
        select
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id, f.owning_inst_id, f.owning_org_id,
            to_number(-23453) inventory_item_id,
            f.vmi_flag, f.order_date,
            to_number(42) aggr_type,
            l_category_set_id1 category_set_id,
            nvl(q.sr_category_id, -23453),
            sum(f.demand_qty),
            sum(f.supply_qty),
            sum(f.pegged_to_excess_qty ),
            sum(f.planned_order_qty),
            sum(f.indep_demand_qty),
            sum(f.indep_demand_value),
            sum(f.dep_demand_qty),
            sum(f.sales_order_value),
            sum(f.sales_order_value2),
            sum(f.return_order_value),
            sum(f.make_order_qty),
            sum(f.make_order_leadtime),
            sum(f.make_order_count),
            sum(f.stock_outs_count),
            sum(f.no_activity_item_count),
            sum(f.days_in_bkt),
            sum(f.item_leadtime),
            sum(f.avg_daily_demand),
            sum(f.onhand_qty),
            sum(f.onhand_value),
            sum(f.onhand_value2),
            sum(f.onhand_usable),
            sum(f.intransit_usable),
            sum(f.plnd_xfer_usable),
            sum(f.onhand_defective),
            sum(f.intransit_defective),
            sum(f.plnd_xfer_defective),
            sum(f.supply_qty_usable),
            sum(f.supply_qty_defective),
            sum(f.scheduled_rept_qty),
            sum(f.scheduled_rept_value),
            sum(f.scheduled_rept_value2),
            sum(f.forecast_qty),
            sum(f.sup_end_pgd_to_fcst),
            sum(f.sup_end_pgd_to_so),
            sum(f.sup_end_pgd_to_ss),
            sum(f.sup_end_pgd_to_excess),
            sum(f.dmd_pgd_to_schd_recp),
            sum(f.dmd_pgd_to_plnd_order),
            sum(f.dmd_pgd_to_onhand),
            sum(f.sup_end_pgd_to_fcst_value),
            sum(f.sup_end_pgd_to_so_value),
            sum(f.sup_end_pgd_to_ss_value),
            sum(f.sup_end_pgd_to_excess_value),
            sum(f.dmd_pgd_to_schd_recp_value),
            sum(f.dmd_pgd_to_plnd_order_value),
            sum(f.dmd_pgd_to_onhand_value),
            sum(f.sup_end_pgd_to_fcst_value2),
            sum(f.sup_end_pgd_to_so_value2),
            sum(f.sup_end_pgd_to_ss_value2),
            sum(f.sup_end_pgd_to_excess_value2),
            sum(f.dmd_pgd_to_schd_recp_value2),
            sum(f.dmd_pgd_to_plnd_order_value2),
            sum(f.dmd_pgd_to_onhand_value2),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_item_orders_f f,
            msc_phub_item_categories_mv q
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
            and f.owning_inst_id=q.sr_instance_id(+)
            and f.owning_org_id=q.organization_id(+)
            and f.inventory_item_id=q.inventory_item_id(+)
            and q.category_set_id(+)=l_category_set_id1
        group by
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id, f.owning_inst_id, f.owning_org_id,
            f.vmi_flag, f.order_date,
            nvl(q.sr_category_id, -23453);

        msc_phub_util.log('msc_item_pkg.summarize_item_orders_f, level1='||sql%rowcount);
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_item_pkg.summarize_item_orders_f: '||sqlerrm;
            raise;
    end summarize_item_orders_f;

    procedure export_item_inventory_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_item_pkg.export_item_inventory_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_item_inventory_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_item_inventory_f('||
            '     st_transaction_id,'||
            '     error_code,'||
            '     sr_instance_id,'||
            '     organization_id,'||
            '     owning_inst_id,'||
            '     owning_org_id,'||
            '     inventory_item_id,'||
            '     organization_code,'||
            '     owning_org_code,'||
            '     item_name,'||
            '     vmi_flag,'||
            '     order_date,'||
            '     pab_qty,'||
            '     pab_value,'||
            '     pab_value2,'||
            '     safety_stock_qty,'||
            '     min_inventory_level,'||
            '     max_inventory_level,'||
            '     avg_daily_demand,'||
            '     inv_build_target,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     safety_stock_value,'||
            '     safety_stock_value2,'||
            '     safety_stock_days,'||
            '     demand_var_ss_qty,'||
            '     sup_ltvar_ss_qty,'||
            '     transit_ltvar_ss_qty,'||
            '     mfg_ltvar_ss_qty,'||
            '     total_unpooled_safety_stock,'||
            '     inventory_cost_post,'||
            '     inventory_cost_no_post,'||
            '     inventory_value_post,'||
            '     inventory_value_no_post,'||
            '     inventory_value,'||
            '     inventory_cost_post2,'||
            '     inventory_cost_no_post2,'||
            '     inventory_value_post2,'||
            '     inventory_value_no_post2,'||
            '     inventory_value2,';
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
            '     f.owning_inst_id,'||
            '     f.owning_org_id,'||
            '     f.inventory_item_id,'||
            '     mtp.organization_code,'||
            '     mtp2.organization_code,'||
            '     mi.item_name,'||
            '     f.vmi_flag,'||
            '     f.order_date,'||
            '     f.pab_qty,'||
            '     f.pab_value,'||
            '     f.pab_value2,'||
            '     f.safety_stock_qty,'||
            '     f.min_inventory_level,'||
            '     f.max_inventory_level,'||
            '     f.avg_daily_demand,'||
            '     f.inv_build_target,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     f.safety_stock_value,'||
            '     f.safety_stock_value2,'||
            '     f.safety_stock_days,'||
            '     f.demand_var_ss_qty,'||
            '     f.sup_ltvar_ss_qty,'||
            '     f.transit_ltvar_ss_qty,'||
            '     f.mfg_ltvar_ss_qty,'||
            '     f.total_unpooled_safety_stock,'||
            '     inventory_cost_post,'||
            '     inventory_cost_no_post,'||
            '     inventory_value_post,'||
            '     inventory_value_no_post,'||
            '     inventory_value,'||
            '     inventory_cost_post2,'||
            '     inventory_cost_no_post2,'||
            '     inventory_value_post2,'||
            '     inventory_value_no_post2,'||
            '     inventory_value2,';
        end if;
        l_sql := l_sql||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_item_inventory_f'||l_suffix||' f,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp2,'||
            '     '||l_apps_schema||'.msc_items'||l_suffix||' mi'||
            ' where f.plan_id=:p_plan_id'||
            '     and f.plan_run_id=:p_plan_run_id'||
            '     and f.aggr_type=0'||
            '     and mtp.partner_type(+)=3'||
            '     and mtp.sr_instance_id(+)=f.sr_instance_id'||
            '     and mtp.sr_tp_id(+)=f.organization_id'||
            '     and mtp2.partner_type(+)=3'||
            '     and mtp2.sr_instance_id(+)=f.owning_inst_id'||
            '     and mtp2.sr_tp_id(+)=f.owning_org_id'||
            '     and mi.inventory_item_id(+)=f.inventory_item_id';

        execute immediate l_sql using p_st_transaction_id, p_plan_id, p_plan_run_id;
        commit;
        msc_phub_util.log('msc_item_pkg.export_item_inventory_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_item_pkg.export_item_inventory_f: '||sqlerrm;
            raise;
    end export_item_inventory_f;

    procedure export_item_orders_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_item_pkg.export_item_orders_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_item_orders_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_item_orders_f('||
            '     st_transaction_id,'||
            '     error_code,'||
            '     sr_instance_id,'||
            '     organization_id,'||
            '     owning_inst_id,'||
            '     owning_org_id,'||
            '     inventory_item_id,'||
            '     organization_code,'||
            '     owning_org_code,'||
            '     item_name,'||
            '     vmi_flag,'||
            '     order_date,'||
            '     demand_qty,'||
            '     pegged_to_excess_qty,'||
            '     supply_qty,'||
            '     planned_order_qty,'||
            '     indep_demand_qty,'||
            '     dep_demand_qty,'||
            '     sales_order_value,'||
            '     return_order_value,'||
            '     make_order_qty,'||
            '     make_order_leadtime,'||
            '     make_order_count,'||
            '     stock_outs_count,'||
            '     no_activity_item_count,'||
            '     item_leadtime,'||
            '     avg_daily_demand,'||
            '     days_in_bkt,'||
            '     indep_demand_value,'||
            '     scheduled_rept_qty,'||
            '     onhand_qty,'||
            '     forecast_qty,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     onhand_usable,'||
            '     intransit_usable,'||
            '     plnd_xfer_usable,'||
            '     onhand_defective,'||
            '     intransit_defective,'||
            '     plnd_xfer_defective,'||
            '     sup_end_pgd_to_fcst,'||
            '     sup_end_pgd_to_so,'||
            '     sup_end_pgd_to_ss,'||
            '     sup_end_pgd_to_excess,'||
            '     dmd_pgd_to_schd_recp,'||
            '     dmd_pgd_to_plnd_order,'||
            '     dmd_pgd_to_onhand,'||
            '     sup_end_pgd_to_fcst_value,'||
            '     sup_end_pgd_to_so_value,'||
            '     sup_end_pgd_to_ss_value,'||
            '     sup_end_pgd_to_excess_value,'||
            '     dmd_pgd_to_schd_recp_value,'||
            '     dmd_pgd_to_plnd_order_value,'||
            '     dmd_pgd_to_onhand_value,'||
            '     sup_end_pgd_to_fcst_value2,'||
            '     sup_end_pgd_to_so_value2,'||
            '     sup_end_pgd_to_ss_value2,'||
            '     sup_end_pgd_to_excess_value2,'||
            '     dmd_pgd_to_schd_recp_value2,'||
            '     dmd_pgd_to_plnd_order_value2,'||
            '     dmd_pgd_to_onhand_value2,'||
            '     supply_qty_usable,'||
            '     supply_qty_defective,'||
            '     sales_order_value2,'||
            '     onhand_value,'||
            '     onhand_value2,'||
            '     scheduled_rept_value,'||
            '     scheduled_rept_value2,';
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
            '     f.owning_inst_id,'||
            '     f.owning_org_id,'||
            '     f.inventory_item_id,'||
            '     mtp.organization_code,'||
            '     mtp2.organization_code,'||
            '     mi.item_name,'||
            '     f.vmi_flag,'||
            '     f.order_date,'||
            '     f.demand_qty,'||
            '     f.pegged_to_excess_qty,'||
            '     f.supply_qty,'||
            '     f.planned_order_qty,'||
            '     f.indep_demand_qty,'||
            '     f.dep_demand_qty,'||
            '     f.sales_order_value,'||
            '     f.return_order_value,'||
            '     f.make_order_qty,'||
            '     f.make_order_leadtime,'||
            '     f.make_order_count,'||
            '     f.stock_outs_count,'||
            '     f.no_activity_item_count,'||
            '     f.item_leadtime,'||
            '     f.avg_daily_demand,'||
            '     f.days_in_bkt,'||
            '     f.indep_demand_value,'||
            '     f.scheduled_rept_qty,'||
            '     f.onhand_qty,'||
            '     f.forecast_qty,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     f.onhand_usable,'||
            '     f.intransit_usable,'||
            '     f.plnd_xfer_usable,'||
            '     f.onhand_defective,'||
            '     f.intransit_defective,'||
            '     f.plnd_xfer_defective,'||
            '     f.sup_end_pgd_to_fcst,'||
            '     f.sup_end_pgd_to_so,'||
            '     f.sup_end_pgd_to_ss,'||
            '     f.sup_end_pgd_to_excess,'||
            '     f.dmd_pgd_to_schd_recp,'||
            '     f.dmd_pgd_to_plnd_order,'||
            '     f.dmd_pgd_to_onhand,'||
            '     f.sup_end_pgd_to_fcst_value,'||
            '     f.sup_end_pgd_to_so_value,'||
            '     f.sup_end_pgd_to_ss_value,'||
            '     f.sup_end_pgd_to_excess_value,'||
            '     f.dmd_pgd_to_schd_recp_value,'||
            '     f.dmd_pgd_to_plnd_order_value,'||
            '     f.dmd_pgd_to_onhand_value,'||
            '     f.sup_end_pgd_to_fcst_value2,'||
            '     f.sup_end_pgd_to_so_value2,'||
            '     f.sup_end_pgd_to_ss_value2,'||
            '     f.sup_end_pgd_to_excess_value2,'||
            '     f.dmd_pgd_to_schd_recp_value2,'||
            '     f.dmd_pgd_to_plnd_order_value2,'||
            '     f.dmd_pgd_to_onhand_value2,'||
            '     f.supply_qty_usable,'||
            '     f.supply_qty_defective,'||
            '     f.sales_order_value2,'||
            '     f.onhand_value,'||
            '     f.onhand_value2,'||
            '     f.scheduled_rept_value,'||
            '     f.scheduled_rept_value2,';
        end if;
        l_sql := l_sql||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_item_orders_f'||l_suffix||' f,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp2,'||
            '     '||l_apps_schema||'.msc_items'||l_suffix||' mi'||
            ' where f.plan_id=:p_plan_id'||
            '     and f.plan_run_id=:p_plan_run_id'||
            '     and f.aggr_type=0'||
            '     and mtp.partner_type(+)=3'||
            '     and mtp.sr_instance_id(+)=f.sr_instance_id'||
            '     and mtp.sr_tp_id(+)=f.organization_id'||
            '     and mtp2.partner_type(+)=3'||
            '     and mtp2.sr_instance_id(+)=f.owning_inst_id'||
            '     and mtp2.sr_tp_id(+)=f.owning_org_id'||
            '     and mi.inventory_item_id(+)=f.inventory_item_id';

        execute immediate l_sql using p_st_transaction_id, p_plan_id, p_plan_run_id;
        commit;
        msc_phub_util.log('msc_item_pkg.export_item_orders_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_item_pkg.export_item_orders_f: '||sqlerrm;
            raise;
    end export_item_orders_f;

    procedure import_item_inventory_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_item_inventory_f';
        l_fact_table varchar2(30) := 'msc_item_inventory_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_item_pkg.import_item_inventory_f');
        retcode := 0;
        errbuf := null;

        l_result := l_result + msc_phub_util.prepare_staging_dates(
            l_staging_table, 'order_date', p_st_transaction_id,
            p_upload_mode, p_overwrite_after_date,
            p_plan_start_date, p_plan_cutoff_date);

        l_result := l_result + msc_phub_util.prepare_fact_dates(
            l_fact_table, 1, 'order_date', p_plan_id, p_plan_run_id,
            p_upload_mode, p_overwrite_after_date);

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'sr_instance_id', 'organization_id', 'organization_code');

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'owning_inst_id', 'owning_org_id', 'owning_org_code');

        l_result := l_result + msc_phub_util.decode_item_key(
            l_staging_table, p_st_transaction_id, 'inventory_item_id', 'item_name');

        msc_phub_util.log('msc_item_pkg.import_item_inventory_f: insert into msc_item_inventory_f');
        insert into msc_item_inventory_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            owning_inst_id,
            owning_org_id,
            inventory_item_id,
            io_plan_flag,
            vmi_flag,
            order_date,
            pab_qty,
            pab_value,
            pab_value2,
            safety_stock_qty,
            min_inventory_level,
            max_inventory_level,
            avg_daily_demand,
            inv_build_target,
            safety_stock_value,
            safety_stock_value2,
            safety_stock_days,
            demand_var_ss_qty,
            sup_ltvar_ss_qty,
            transit_ltvar_ss_qty,
            mfg_ltvar_ss_qty,
            total_unpooled_safety_stock,
            inventory_cost_post,
            inventory_cost_no_post,
            inventory_value_post,
            inventory_value_no_post,
            inventory_value,
            inventory_cost_post2,
            inventory_cost_no_post2,
            inventory_value_post2,
            inventory_value_no_post2,
            inventory_value2,
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
            nvl(inventory_item_id, -23453),
            decode(p_plan_type, 4, 1, 0) io_plan_flag,
            vmi_flag,
            order_date,
            pab_qty,
            pab_value,
            pab_value2,
            safety_stock_qty,
            min_inventory_level,
            max_inventory_level,
            avg_daily_demand,
            inv_build_target,
            safety_stock_value,
            safety_stock_value2,
            safety_stock_days,
            demand_var_ss_qty,
            sup_ltvar_ss_qty,
            transit_ltvar_ss_qty,
            mfg_ltvar_ss_qty,
            total_unpooled_safety_stock,
            inventory_cost_post,
            inventory_cost_no_post,
            inventory_value_post,
            inventory_value_no_post,
            inventory_value,
            inventory_cost_post2,
            inventory_cost_no_post2,
            inventory_value_post2,
            inventory_value_no_post2,
            inventory_value2,
            0, -23453, -23453,
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_item_inventory_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_item_pkg.import_item_inventory_f: inserted='||sql%rowcount);
        commit;

        summarize_item_inventory_f(errbuf, retcode, p_plan_id, p_plan_run_id);

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_item_pkg.import_item_inventory_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_item_pkg.import_item_inventory_f: '||sqlerrm;
            raise;
    end import_item_inventory_f;

    procedure import_item_orders_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_item_orders_f';
        l_fact_table varchar2(30) := 'msc_item_orders_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_item_pkg.import_item_orders_f');
        retcode := 0;
        errbuf := null;

        l_result := l_result + msc_phub_util.prepare_staging_dates(
            l_staging_table, 'order_date', p_st_transaction_id,
            p_upload_mode, p_overwrite_after_date,
            p_plan_start_date, p_plan_cutoff_date);

        l_result := l_result + msc_phub_util.prepare_fact_dates(
            l_fact_table, 1, 'order_date', p_plan_id, p_plan_run_id,
            p_upload_mode, p_overwrite_after_date);

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'sr_instance_id', 'organization_id', 'organization_code');

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'owning_inst_id', 'owning_org_id', 'owning_org_code');

        l_result := l_result + msc_phub_util.decode_item_key(
            l_staging_table, p_st_transaction_id, 'inventory_item_id', 'item_name');

        msc_phub_util.log('msc_item_pkg.import_item_orders_f: insert into msc_item_orders_f');
        insert into msc_item_orders_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            owning_inst_id,
            owning_org_id,
            inventory_item_id,
            io_plan_flag,
            vmi_flag,
            order_date,
            demand_qty,
            pegged_to_excess_qty,
            supply_qty,
            planned_order_qty,
            indep_demand_qty,
            dep_demand_qty,
            sales_order_value,
            sales_order_value2,
            return_order_value,
            make_order_qty,
            make_order_leadtime,
            make_order_count,
            stock_outs_count,
            no_activity_item_count,
            item_leadtime,
            avg_daily_demand,
            days_in_bkt,
            indep_demand_value,
            scheduled_rept_qty,
            onhand_qty,
            forecast_qty,
            onhand_usable,
            intransit_usable,
            plnd_xfer_usable,
            onhand_defective,
            intransit_defective,
            plnd_xfer_defective,
            sup_end_pgd_to_fcst,
            sup_end_pgd_to_so,
            sup_end_pgd_to_ss,
            sup_end_pgd_to_excess,
            dmd_pgd_to_schd_recp,
            dmd_pgd_to_plnd_order,
            dmd_pgd_to_onhand,
            sup_end_pgd_to_fcst_value,
            sup_end_pgd_to_so_value,
            sup_end_pgd_to_ss_value,
            sup_end_pgd_to_excess_value,
            dmd_pgd_to_schd_recp_value,
            dmd_pgd_to_plnd_order_value,
            dmd_pgd_to_onhand_value,
            sup_end_pgd_to_fcst_value2,
            sup_end_pgd_to_so_value2,
            sup_end_pgd_to_ss_value2,
            sup_end_pgd_to_excess_value2,
            dmd_pgd_to_schd_recp_value2,
            dmd_pgd_to_plnd_order_value2,
            dmd_pgd_to_onhand_value2,
            supply_qty_usable,
            supply_qty_defective,
            onhand_value,
            onhand_value2,
            scheduled_rept_value,
            scheduled_rept_value2,
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
            nvl(inventory_item_id, -23453),
            decode(p_plan_type, 4, 1, 0) io_plan_flag,
            vmi_flag,
            order_date,
            demand_qty,
            pegged_to_excess_qty,
            supply_qty,
            planned_order_qty,
            indep_demand_qty,
            dep_demand_qty,
            sales_order_value,
            sales_order_value2,
            return_order_value,
            make_order_qty,
            make_order_leadtime,
            make_order_count,
            stock_outs_count,
            no_activity_item_count,
            item_leadtime,
            avg_daily_demand,
            days_in_bkt,
            indep_demand_value,
            scheduled_rept_qty,
            onhand_qty,
            forecast_qty,
            onhand_usable,
            intransit_usable,
            plnd_xfer_usable,
            onhand_defective,
            intransit_defective,
            plnd_xfer_defective,
            sup_end_pgd_to_fcst,
            sup_end_pgd_to_so,
            sup_end_pgd_to_ss,
            sup_end_pgd_to_excess,
            dmd_pgd_to_schd_recp,
            dmd_pgd_to_plnd_order,
            dmd_pgd_to_onhand,
            sup_end_pgd_to_fcst_value,
            sup_end_pgd_to_so_value,
            sup_end_pgd_to_ss_value,
            sup_end_pgd_to_excess_value,
            dmd_pgd_to_schd_recp_value,
            dmd_pgd_to_plnd_order_value,
            dmd_pgd_to_onhand_value,
            sup_end_pgd_to_fcst_value2,
            sup_end_pgd_to_so_value2,
            sup_end_pgd_to_ss_value2,
            sup_end_pgd_to_excess_value2,
            dmd_pgd_to_schd_recp_value2,
            dmd_pgd_to_plnd_order_value2,
            dmd_pgd_to_onhand_value2,
            supply_qty_usable,
            supply_qty_defective,
            onhand_value,
            onhand_value2,
            scheduled_rept_value,
            scheduled_rept_value2,
            0, -23453, -23453,
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_item_orders_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_item_pkg.import_item_orders_f: inserted='||sql%rowcount);
        commit;

        summarize_item_orders_f(errbuf, retcode, p_plan_id, p_plan_run_id);

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_item_pkg.import_item_orders_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_item_pkg.import_item_orders_f: '||sqlerrm;
            raise;
    end import_item_orders_f;

end msc_item_pkg;

/
