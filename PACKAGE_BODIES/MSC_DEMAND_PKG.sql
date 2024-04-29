--------------------------------------------------------
--  DDL for Package Body MSC_DEMAND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_DEMAND_PKG" as
/* $Header: MSCHBDEB.pls 120.40.12010000.16 2010/03/26 11:33:23 wexia ship $ */


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
    l_qid_last_date number;

    l_owning_currency_code varchar2(20) := msc_phub_util.get_owning_currency_code(p_plan_run_id);

    l_refresh_mode  number;
    l_res_item_qid  number;
    l_plan_start_date date;
    l_plan_cutoff_date date;
    l_plan_type number;
    l_sr_instance_id number;
    con_ods_plan_id constant number := -1;
    l_rowcount1 number := 0;
    l_rowcount2 number := 0;
begin

    msc_phub_util.log('msc_demand_pkg.populate_details');


    retcode :=0;    -- this means successfully
    errbuf :='';
     --Successfully populated msc_demands_f table for plan_id ='||p_plan_id||',plan_run_id='||p_plan_run_id;
            -- initial there is no error message
    l_api_name := 'msc_demand_pkg.populate_details';
    l_stmt_id :=1;

    l_user_id := fnd_global.user_id;
    l_sysdate :=sysdate;
    l_user_login_id :=fnd_global.login_id;
    l_cp_login_id :=FND_GLOBAL.CONC_LOGIN_ID;
    l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;
    l_appl_id := FND_GLOBAL.PROG_APPL_ID;
    l_request_id := FND_GLOBAL.CONC_REQUEST_ID;

    l_stmt_id :=5;
    select plan_type, sr_instance_id, plan_start_date, plan_cutoff_date
    into l_plan_type, l_sr_instance_id, l_plan_start_date, l_plan_cutoff_date
    from msc_plan_runs
    where plan_id=p_plan_id
    and plan_run_id=p_plan_run_id;

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

            delete from msc_demands_f
            where  plan_id = p_plan_id
                and plan_run_id = p_plan_run_id
                and (p_plan_id, sr_instance_id, organization_id, inventory_item_id) in
                    (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid);

            l_rowcount1 := l_rowcount1 + sql%rowcount;
            msc_phub_util.log('msc_demands_f, delete='||sql%rowcount||', l_rowcount1='||l_rowcount1);
            commit;

            delete from msc_demands_cum_f
            where  plan_id = p_plan_id
                and plan_run_id = p_plan_run_id
                and (p_plan_id, sr_instance_id, organization_id, inventory_item_id) in
                    (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid);

            l_rowcount2 := l_rowcount2 + sql%rowcount;
            msc_phub_util.log('msc_demands_cum_f, delete='||sql%rowcount||', l_rowcount2='||l_rowcount2);
            commit;
        end if;
    end if;


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
    number10        -- vmi flag
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
    and nvl(mis.vmi_flag,0)=1
    and msi.sr_instance_id=decode(p_plan_id, -1, l_sr_instance_id, msi.sr_instance_id);

    msc_phub_util.log('l_stmt_id='||l_stmt_id||' count='||sql%rowcount);
    commit;

 --------------------------------------------------------------------

 --- for drp(5), it total demand should not include
 --- planned order demand (1)
 --- for work order (3) and Interorganization_Demand(24), it should use old date
 --

    l_stmt_id :=20;
    insert into msc_demands_f (
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        PROGRAM_ID,
        PROGRAM_LOGIN_ID,
        PROGRAM_APPLICATION_ID,
        REQUEST_ID,
        plan_id,
        plan_run_id,
        io_plan_flag,
        sr_instance_id,
        organization_id,
        inventory_item_id,
        original_item_id,
        project_id,
        task_id,
        customer_id,
        customer_site_id,
        region_id,
        demand_class,
        owning_org_id,
        owning_inst_id,
        order_date,
        aggr_type, category_set_id, sr_category_id,
        order_type,
        vmi_flag,
        part_condition,
        demand_qty,
        qty_by_due_date,
        net_demand,
        constrained_fcst,
        constrained_fcst_value,
        constrained_fcst_value2,
        indep_demand_count,
        indep_met_ontime_count,
        indep_met_full_count,
        indep_demand_value,
        indep_demand_value2,
        indep_demand_qty,
        annualized_cogs,
        indep_by_due_date_qty,
        sales_order_qty,
        sales_order_count,
        sales_order_metr_count,
        sales_order_meta_count,
        sales_order_sd,
        sales_order_sd_value,
        sales_order_sd_value2,
        sales_order_rd,
        sales_order_rd_value,
        sales_order_rd_value2,
        sales_order_pd,
        sales_order_pd_value,
        sales_order_pd_value2,
        forecast_qty,
        --qty_by_due_date_with_p,
        io_required_qty,
        io_delivered_qty,
        late_dmd_stf_factor,
        late_order_count,
        late_order_value,
        late_order_value2,
        service_level,
        item_parent_demand,
        item_parent_demand_value,
        demand_fulfillment_lead_time)
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

    ------------------------------------------------------
        p_plan_id,
        p_plan_run_id,
        decode(l_plan_type,4,1,9,1,0) io_plan_flag,
        demand_tbl.sr_instance_id,
        demand_tbl.organization_id,
        demand_tbl.inventory_item_id,
        demand_tbl.original_item_id,
        demand_tbl.project_id,
        demand_tbl.task_id,
    --- we should not populate customer_id/customer_site_id
    --- at all for dependent demand.
    --- we do not want show dependent demand in customer dimension
    --- bug 6797611
        nvl(case when -demand_tbl.order_type in (5,6,7,8,9,10,11,12,15,22,27,29,30,81)
            then demand_tbl.customer_id end, -23453),

        msc_phub_util.validate_customer_site_id(
            nvl(case when -demand_tbl.order_type in (5,6,7,8,9,10,11,12,15,22,27,29,30,81)
                    then demand_tbl.customer_id end, -23453),
            demand_tbl.customer_site_id),
        nvl(cmv.region_id, -23453),
        demand_tbl.demand_class,
        demand_tbl.owning_org_id,
        demand_tbl.owning_inst_id,
    ----- we an not just put it in curr_start_date
    ----- need to put it in last working day of the bucket where plan start date in
        decode(sign(to_number(demand_tbl.order_date-l_plan_start_date)),-1,
                                       msc_hub_calendar.last_work_date(p_plan_id,l_plan_start_date),
                       demand_tbl.order_date),
        to_number(0) aggr_type,
        to_number(-23453) category_set_id,
        to_number(-23453) sr_category_id,
        demand_tbl.order_type,
        nvl(msi.vmi_flag, 0) vmi_flag,
        demand_tbl.part_condition,
        sum(demand_tbl.demand_qty),
        sum(demand_tbl.qty_by_due_date),
        sum(demand_tbl.net_demand),
        sum(demand_tbl.constrained_fcst),
        sum(demand_tbl.constrained_fcst *
            nvl(msi.list_price,0)*(1- nvl(msi.average_discount,0)/100)) constrained_fcst_value,
        sum(demand_tbl.constrained_fcst *
            nvl(msi.list_price,0)*(1- nvl(msi.average_discount,0)/100) *
            decode(demand_tbl.currency_code,fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))) constrained_fcst_value2,
        sum(demand_tbl.indep_demand_count),
        sum(demand_tbl.indep_met_ontime_count),
        sum(demand_tbl.indep_met_full_count),
        sum(demand_tbl.indep_demand_qty *
            nvl(msi.list_price,0)*(1- nvl(msi.average_discount,0)/100)) indep_demand_value,
        sum(demand_tbl.indep_demand_qty *
            nvl(msi.list_price,0)*(1- nvl(msi.average_discount,0)/100) *
            decode(demand_tbl.currency_code,fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))) indep_demand_value2,
        sum(demand_tbl.indep_demand_qty),
        sum(demand_tbl.indep_demand_qty * nvl(msi.standard_cost,0) *
            365 / nvl(l_plan_cutoff_date-l_plan_start_date+1, 365)) annualized_cogs,
        sum(demand_tbl.indep_by_due_date_qty),
        sum(demand_tbl.sales_order_qty),
        sum(demand_tbl.sales_order_count),
        sum(demand_tbl.sales_order_metr_count),
        sum(demand_tbl.sales_order_meta_count),
        sum(demand_tbl.sales_order_sd),
        sum(demand_tbl.sales_order_sd *
            nvl(msi.list_price,0)*(1- nvl(msi.average_discount,0)/100)) sales_order_sd_value,
        sum(demand_tbl.sales_order_sd *
            nvl(msi.list_price,0)*(1- nvl(msi.average_discount,0)/100) *
            decode(demand_tbl.currency_code,fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))) sales_order_sd_value2,
        sum(demand_tbl.sales_order_rd),
        sum(demand_tbl.sales_order_rd *
            nvl(msi.list_price,0)*(1- nvl(msi.average_discount,0)/100)) sales_order_rd_value,
        sum(demand_tbl.sales_order_rd *
            nvl(msi.list_price,0)*(1- nvl(msi.average_discount,0)/100) *
            decode(demand_tbl.currency_code,fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))) sales_order_rd_value2,
        sum(demand_tbl.sales_order_pd),
        sum(demand_tbl.sales_order_pd *
            nvl(msi.list_price,0)*(1- nvl(msi.average_discount,0)/100)) sales_order_pd_value,
        sum(demand_tbl.sales_order_pd *
            nvl(msi.list_price,0)*(1- nvl(msi.average_discount,0)/100) *
            decode(demand_tbl.currency_code,fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))) sales_order_pd_value2,
        sum(demand_tbl.forecast_qty),
        sum(demand_tbl.io_required_qty),
        sum(demand_tbl.io_delivered_qty),
            sum(demand_tbl.late_dmd_stf_factor),
        sum(demand_tbl.late_order_count),
        sum(demand_tbl.late_order_qty *
            nvl(msi.list_price,0)*(1- nvl(msi.average_discount,0)/100)) late_order_value,
        sum(demand_tbl.late_order_qty *
            nvl(msi.list_price,0)*(1- nvl(msi.average_discount,0)/100) *
            decode(demand_tbl.currency_code,fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))) late_order_value2,
        min(demand_tbl.service_level),
        sum(demand_tbl.item_parent_demand),
        sum(demand_tbl.item_parent_demand *
            nvl(msi.list_price,0)*(1- nvl(msi.average_discount,0)/100)) item_parent_demand_value,
        avg(demand_tbl.demand_fulfillment_lead_time)
   from(
      select
        -- sync sr_instance_id with organization_id
    -- this is important since in org dimension,
    -- it only has (inst,org)=(-23543,-23453)

        decode(md.organization_id, -1, -23453, md.sr_instance_id) sr_instance_id,

    -- ASCP global forecast, org leave as -1, not mapped to Org dim
        -- SNO org=-1 change to Unassigned, mapped to Org dim

        -- ASCP, order type 29(forecast) 77(Part_Demand) may have org=-1
    -- we need to show such demand qty in order qty measure, but we
    -- should not include global forecast into item's total demand,
    -- total indep demand, pab measure.

        decode(md.organization_id, -1, -23453, md.organization_id) organization_id,

        md.inventory_item_id,
        nvl(md.original_item_id, -23453) original_item_id,
        nvl(md.project_id,-23453) project_id,
        nvl(md.task_id, -23453) task_id,
        decode(sign(md.customer_id), 1, md.customer_id, -23453) customer_id,
        decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453) customer_site_id,
        decode(sign(md.zone_id), 1, md.zone_id, -23453) region_id,
        nvl(md.demand_class, '-23453') demand_class,

        decode(md.organization_id,-1, msc_hub_calendar.get_item_org(p_plan_id, md.inventory_item_id,
                                         decode(md.sr_instance_id,-1, l_sr_instance_id, md.sr_instance_id)),
               md.organization_id) owning_org_id,

        --- we assume that the item must exist in plan's owning inst
        decode(md.sr_instance_id, -1, l_sr_instance_id, md.sr_instance_id) owning_inst_id,

        -- drp plan and
        decode(l_plan_type,5,decode(md.origination_type,
                        3,trunc(nvl(md.old_using_assembly_demand_date,md.using_assembly_demand_date)),
                        24,trunc(nvl(md.old_using_assembly_demand_date,md.using_assembly_demand_date)),
                        trunc(nvl(md.firm_date,md.using_assembly_demand_date))),
                    trunc(nvl(md.firm_date,md.using_assembly_demand_date)) ) order_date,

        -1 * md.origination_type order_type,
        decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)) currency_code,

            nvl(md.item_type_value,1) part_condition,

       ---- demand qty
       --- take care of drp demand
       --- currently in ASCP, safety_stock demand is excluded in total demand
       --- but in bug 6688725,we are required to show safety stock(31) demand in order qty measure
       --- however, we will not include the safety stock demand into total demand of the item

      sum(decode(l_plan_type,5,decode(md.origination_type,3,nvl(md.using_requirement_quantity,0),
                                                           24,nvl(md.using_requirement_quantity,0),
                                       decode(md.assembly_demand_comp_date,null,
                                              decode(md.origination_type,29,(nvl(md.probability,1)* md.using_requirement_quantity),
                                                           md.using_requirement_quantity),
                                              decode(md.origination_type, 29,(nvl(md.probability,1)* md.daily_demand_rate),
                                                            md.daily_demand_rate))),
               decode(md.assembly_demand_comp_date,null,
                 decode(md.origination_type,29,(nvl(md.probability,1)* md.using_requirement_quantity),
                        md.using_requirement_quantity),
                 decode(md.origination_type, 29,(nvl(md.probability,1)* md.daily_demand_rate),
                        md.daily_demand_rate)) )
            ) /
            decode(nvl(least(sum(decode(md.origination_type,29,nvl(md.probability,0),null)),1),1),
                   0,1,
                   nvl(least(sum(decode(md.origination_type,29,nvl(md.probability,0),null)),1),1)
                 ) demand_qty,

      --------------------------------------------------------------------------------------------------
      --- the logic for the folliwing code is.
      ---  if it is forecast demand ==> if min(sum(nvl(md.probability,0)),1) ==0, then =1, else min(sum(nvl(md.probability,0)),1)
      --- for all other demand, it is 1

       /*decode(nvl(least(sum(decode(md.origination_type,29,nvl(md.probability,0),null)),1),1),
                   0,1,
                   nvl(least(sum(decode(md.origination_type,29,nvl(md.probability,0),null)),1),1))
       */



      -- take care of forecast demand which has probability
      --- sum(decode(md.origination_type,31,0,nvl(md.quantity_by_due_date,0))) qty_by_due_date,

      --- safety stock demand is not in total demand, so it is not in qty by due date
      --- global forecast is not in total demand, so it should not in qty_by_due_date
      ------------------------------------------------------------------------------------------------------
      sum(decode(md.origination_type,31,0,
            29, decode(md.organization_id,-1,0,nvl(md.quantity_by_due_date,0) * nvl(md.probability,1)),
            nvl(md.quantity_by_due_date,0) )
        ) /
        decode(nvl(least(sum(decode(md.origination_type,29,decode(md.organization_id,-1,0,nvl(md.probability,0)),null)),1),1),
                   0,1,
                   nvl(least(sum(decode(md.origination_type,29,decode(md.organization_id,-1,0,nvl(md.probability,0)),null)),1),1)
                 ) qty_by_due_date,

    sum(decode(md.origination_type, 81, using_requirement_quantity, 0)) net_demand,
    sum(decode(md.origination_type, 81, quantity_by_due_date, 0)) constrained_fcst,

    ---- indep demand count
    sum(decode(md.origination_type,
                       5,decode(nvl(md.using_requirement_quantity,0),0,0,1),
                       6,decode(nvl(md.using_requirement_quantity,0),0,0,1),
                       7,decode(nvl(md.using_requirement_quantity,0),0,0,1),
                       8,decode(nvl(md.using_requirement_quantity,0),0,0,1),
                       9,decode(nvl(md.using_requirement_quantity,0),0,0,1),
                       10,decode(nvl(md.using_requirement_quantity,0),0,0,1),
                       11,decode(nvl(md.using_requirement_quantity,0),0,0,1),
                       12,decode(nvl(md.using_requirement_quantity,0),0,0,1),
                       15,decode(nvl(md.using_requirement_quantity,0),0,0,1),
                       22,decode(nvl(md.using_requirement_quantity,0),0,0,1),
                       27,decode(nvl(md.using_requirement_quantity,0),0,0,1),
                       29,decode(md.organization_id,-1,0,decode((nvl(md.using_requirement_quantity,0)* nvl(md.probability,1)),0,0,1)),
                       30,decode(nvl(md.using_requirement_quantity,0),0,0,1),
                       81,decode(nvl(md.using_requirement_quantity,0),0,0,1),
                       0))  indep_demand_count,

    --- indepedent demand meet on time count
    sum(decode(md.origination_type,
                       5,decode(nvl(md.quantity_by_due_date,0),0,0,1),
                       6,decode(nvl(md.quantity_by_due_date,0),0,0,1),
                       7,decode(nvl(md.quantity_by_due_date,0),0,0,1),
                       8,decode(nvl(md.quantity_by_due_date,0),0,0,1),
                       9,decode(nvl(md.quantity_by_due_date,0),0,0,1),
                       10,decode(nvl(md.quantity_by_due_date,0),0,0,1),
                       11,decode(nvl(md.quantity_by_due_date,0),0,0,1),
                       12,decode(nvl(md.quantity_by_due_date,0),0,0,1),
                       15,decode(nvl(md.quantity_by_due_date,0),0,0,1),
                       22,decode(nvl(md.quantity_by_due_date,0),0,0,1),
                       27,decode(nvl(md.quantity_by_due_date,0),0,0,1),
                       29,decode(md.organization_id,-1,0,decode((nvl(md.quantity_by_due_date,0)* nvl(md.probability,1)),0,0,1)),
                       30,decode(nvl(md.quantity_by_due_date,0),0,0,1),
                       81,decode(nvl(md.quantity_by_due_date,0),0,0,1),
                       0))  indep_met_ontime_count,

    --- independent demand meet full count
    sum(decode(nvl(md.using_requirement_quantity,0),0,0,
            decode(md.origination_type,
                       5,decode(nvl(md.UNMET_QUANTITY,0),0,1,0),
                       6,decode(nvl(md.UNMET_QUANTITY,0),0,1,0),
                       7,decode(nvl(md.UNMET_QUANTITY,0),0,1,0),
                       8,decode(nvl(md.UNMET_QUANTITY,0),0,1,0),
                       9,decode(nvl(md.UNMET_QUANTITY,0),0,1,0),
                       10,decode(nvl(md.UNMET_QUANTITY,0),0,1,0),
                       11,decode(nvl(md.UNMET_QUANTITY,0),0,1,0),
                       12,decode(nvl(md.UNMET_QUANTITY,0),0,1,0),
                       15,decode(nvl(md.UNMET_QUANTITY,0),0,1,0),
                       22,decode(nvl(md.UNMET_QUANTITY,0),0,1,0),
                       27,decode(nvl(md.UNMET_QUANTITY,0),0,1,0),
                       29,decode(md.organization_id,-1,0,decode(nvl(md.UNMET_QUANTITY,0),0,1,0)),
                       30,decode(nvl(md.UNMET_QUANTITY,0),0,1,0),
                       81,decode(nvl(md.UNMET_QUANTITY,0),0,1,0),
                       0)))  indep_met_full_count,


    --- indepedent demand qty
    sum(decode(md.assembly_demand_comp_date,null,
          decode(md.origination_type,
                        29,decode(md.organization_id,-1,0,(nvl(md.probability,1)* md.using_requirement_quantity)),
                        5, md.using_requirement_quantity,
                        6, md.using_requirement_quantity,
                        7, md.using_requirement_quantity,
                        8, md.using_requirement_quantity,
                        9, md.using_requirement_quantity,
                        10, md.using_requirement_quantity,
                        11, md.using_requirement_quantity,
                        12, md.using_requirement_quantity,
                        15, md.using_requirement_quantity,
                        22, md.using_requirement_quantity,
                        27, md.using_requirement_quantity,
                        30, md.using_requirement_quantity,
                        81, md.using_requirement_quantity,
                        0),
            decode(md.origination_type,
                       29,decode(md.organization_id,-1,0,(nvl(md.probability,1)*md.daily_demand_rate)),
                       5,md.daily_demand_rate,
                       6, md.daily_demand_rate,
                       7,md.daily_demand_rate,
                       8, md.daily_demand_rate,
                       9,md.daily_demand_rate,
                       10, md.daily_demand_rate,
                       11,md.daily_demand_rate,
                       12, md.daily_demand_rate,
               22, md.daily_demand_rate,
                       15,md.daily_demand_rate,
                       27,md.daily_demand_rate,
                       30, md.daily_demand_rate,
                       81, md.daily_demand_rate,
                        0))) /
        decode(nvl(least(sum(decode(md.origination_type,
                     29,decode(md.organization_id,-1,0,nvl(md.probability,0)), null)), 1),1),0,1,
                     nvl(least(sum(decode(md.origination_type,
                     29,decode(md.organization_id,-1,0,nvl(md.probability,0)), null)),1),1)) indep_demand_qty,


    --- indep_by_due_date_qty
    sum(decode(md.origination_type,5,nvl(md.quantity_by_due_date,0),
                    6,nvl(md.quantity_by_due_date,0),
                    7,nvl(md.quantity_by_due_date,0),
                    8,nvl(md.quantity_by_due_date,0),
                    9,nvl(md.quantity_by_due_date,0),
                    10,nvl(md.quantity_by_due_date,0),
                    11,nvl(md.quantity_by_due_date,0),
                    12,nvl(md.quantity_by_due_date,0),
                    15,nvl(md.quantity_by_due_date,0),
                    22,nvl(md.quantity_by_due_date,0),
                    27,nvl(md.quantity_by_due_date,0),
                    29,decode(md.organization_id,-1,0,nvl(md.quantity_by_due_date,0) * nvl(md.probability,1)),  -- take care of probability
                    30,nvl(md.quantity_by_due_date,0),
                    81,nvl(md.quantity_by_due_date,0),
                    0)) /
        decode(nvl(least(sum(decode(md.origination_type,29,decode(md.organization_id,-1,nvl(md.probability,0)),null)),1),1),
                   0,1,
                   nvl(least(sum(decode(md.origination_type,29,decode(md.organization_id,-1,nvl(md.probability,0)),null)),1),1)
                 ) indep_by_due_date_qty,

        --- sales_order_qty
        sum(decode(md.assembly_demand_comp_date,null,
                     decode(md.origination_type,30,md.using_requirement_quantity,to_number(null)),
                     decode(md.origination_type,30,md.daily_demand_rate,to_number(null)))
            ) sales_order_qty,

        --- sales order count
        sum(decode(md.origination_type,30,1,to_number(null))) sales_order_count,

        --- count of sales order meets require date
        sum(decode(md.origination_type,30,
                       decode(sign(md.SCHEDULE_SHIP_DATE-md.request_date),-1,1,0),
                   to_number(null)))    sales_order_metr_count,

        --- sales orde meets accept date
        sum(decode(md.origination_type,30,
                       decode(sign(md.SCHEDULE_SHIP_DATE- md.LATEST_ACCEPTABLE_DATE),-1,1,0),
                   to_number(null)))    sales_order_meta_count,

        to_number(null) sales_order_sd,
        to_number(null) sales_order_rd,
        to_number(null) sales_order_pd,

    --- forecast qty
    sum(decode(md.assembly_demand_comp_date,null,
                 decode(md.origination_type,29,decode(md.organization_id,-1,0,(nvl(md.probability,1)* md.using_requirement_quantity)),
                        to_number(null)),
                 decode(md.origination_type, 29,decode(md.organization_id,-1,0,(nvl(md.probability,1)* md.daily_demand_rate)),
                        to_number(null)))
            ) /
            decode(nvl(least(sum(decode(md.origination_type,29,decode(md.organization_id,-1,0,nvl(md.probability,0)),null)),1),1),
                   0,1,
                   nvl(least(sum(decode(md.origination_type,29,decode(md.organization_id,-1,0,nvl(md.probability,0)),null)),1),1)
      )  forecast_qty,

    sum(decode(l_plan_type,4,decode(md.origination_type,
                  5,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  6,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  7,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  8,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  9,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  10,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  11,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  12,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  15,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  22,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  27,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  29,decode(md.organization_id,-1,0,nvl(md.old_demand_quantity,0) * nvl(md.probability,1)),
                  30,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  0),
               9,decode(md.origination_type,
                  5,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  6,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  7,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  8,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  9,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  10,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  11,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  12,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  15,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  22,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  27,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  29,decode(md.organization_id,-1,0,nvl(md.old_demand_quantity,0) * nvl(md.probability,1)),
                  30,nvl(md.old_demand_quantity,0) * nvl(md.probability,1),
                  0),
                0)) io_delivered_qty,

    sum(decode(l_plan_type,4,decode(md.origination_type,
                  5,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  6,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  7,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  8,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  9,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  10,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  11,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  12,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  15,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  22,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  27,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  29,decode(md.organization_id,-1,0,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1)),
                  30,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  0),
              9,decode(md.origination_type,
                  5,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  6,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  7,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  8,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  9,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  10,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  11,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  12,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  15,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  22,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  27,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  29,decode(md.organization_id,-1,0,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1)),
                  30,nvl(md.using_requirement_quantity, 0) * nvl(md.probability,1),
                  0),
                0)) io_required_qty,

-----------------------------------------------------------------------------------------------------
      to_number(null)  late_dmd_stf_factor,
      to_number(null) late_order_count,
      to_number(null) late_order_qty,
        ---- indep demand service_level
        min(decode(md.origination_type,
            5,nvl(md.service_level, 50),
            6,nvl(md.service_level, 50),
            7,nvl(md.service_level, 50),
            8,nvl(md.service_level, 50),
            9,nvl(md.service_level, 50),
            10,nvl(md.service_level, 50),
            11,nvl(md.service_level, 50),
            12,nvl(md.service_level, 50),
            15,nvl(md.service_level, 50),
            22,nvl(md.service_level, 50),
            27,nvl(md.service_level, 50),
            29,nvl(md.service_level, 50),
            30,nvl(md.service_level, 50),
            81,nvl(md.service_level, 50),
            null))  service_level,
         to_number(null) item_parent_demand,
         avg(md.demand_fulfillment_lead_time) demand_fulfillment_lead_time

      from msc_demands md, msc_trading_partners mtp
      where md.plan_id = p_plan_id
      and md.sr_instance_id = mtp.sr_instance_id(+)
      and md.organization_id = mtp.sr_tp_id(+)
      and mtp.partner_type(+) = 3
      and (p_plan_id <> con_ods_plan_id
          or ( p_plan_id = con_ods_plan_id
            and md.sr_instance_id = l_sr_instance_id
            and (l_refresh_mode = 1
                 or (l_refresh_mode = 2 and (p_plan_id, md.sr_instance_id, md.organization_id, md.inventory_item_id) in
                       (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid) ) )
            and md.origination_type <> 29
            and trunc(nvl(md.firm_date,md.using_assembly_demand_date)) between l_plan_start_date and l_plan_cutoff_date
          )
      )
      group by
      decode(md.organization_id, -1, -23453, md.sr_instance_id),
      decode(md.organization_id, -1, -23453, md.organization_id),
      md.inventory_item_id,
      nvl(md.original_item_id, -23453),
      nvl(md.project_id,-23453),
      nvl(md.task_id, -23453),
      decode(sign(md.customer_id), 1, md.customer_id, -23453),
      decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453),
      decode(sign(md.zone_id), 1, md.zone_id, -23453),
      nvl(md.demand_class, '-23453'),

      decode(md.organization_id, -1, msc_hub_calendar.get_item_org(p_plan_id, md.inventory_item_id,
                   decode(md.sr_instance_id, -1, l_sr_instance_id, md.sr_instance_id)),
                  md.organization_id),

      decode(md.sr_instance_id, -1, l_sr_instance_id, md.sr_instance_id),

     decode(l_plan_type,5,decode(md.origination_type,
                    3,trunc(nvl(md.old_using_assembly_demand_date,md.using_assembly_demand_date)),
                    24,trunc(nvl(md.old_using_assembly_demand_date,md.using_assembly_demand_date)),
                    trunc(nvl(md.firm_date,md.using_assembly_demand_date))),
                          trunc(nvl(md.firm_date,md.using_assembly_demand_date)) ),
      -1 * md.origination_type,
      decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)),
      nvl(md.item_type_value,1)

    union all
    select
        decode(md.organization_id, -1, -23453, md.sr_instance_id) sr_instance_id,
        decode(md.organization_id, -1, -23453, md.organization_id) organization_id,
        md.inventory_item_id,
        nvl(md.original_item_id, -23453) original_item_id,
        nvl(md.project_id,-23453) project_id,
        nvl(md.task_id, -23453) task_id,
        decode(sign(md.customer_id), 1, md.customer_id, -23453) customer_id,
        decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453) customer_site_id,
        decode(sign(md.zone_id), 1, md.zone_id, -23453) region_id,
        nvl(md.demand_class, '-23453') demand_class,
        decode(md.organization_id,-1, msc_hub_calendar.get_item_org(p_plan_id, md.inventory_item_id,
                                         decode(md.sr_instance_id,-1, l_sr_instance_id, md.sr_instance_id)),
               md.organization_id) owning_org_id,

        decode(md.sr_instance_id, -1, l_sr_instance_id, md.sr_instance_id) owning_inst_id,

        md.order_date,

        -1 * md.origination_type order_type,
        decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)) currency_code,

            nvl(md.item_type_value,1) part_condition,

        sum(md.using_requirement_quantity) demand_qty,

        to_number(null) qty_by_due_date,
        to_number(null) net_demand,
        to_number(null) constrained_fcst,

        sum(decode(nvl(md.using_requirement_quantity,0),0,0,1)) indep_demand_count,

        to_number(null) indep_met_ontime_count,
        to_number(null) indep_met_full_count,

        sum(md.using_requirement_quantity) indep_demand_qty,

        to_number(null) indep_by_due_date_qty,
        to_number(null) sales_order_qty,
        to_number(null) sales_order_count,
        to_number(null) sales_order_metr_count,
        to_number(null) sales_order_meta_count,
        to_number(null) sales_order_sd,
        to_number(null) sales_order_rd,
        to_number(null) sales_order_pd,

        sum(md.using_requirement_quantity)  forecast_qty,

        to_number(null) io_delivered_qty,
        to_number(null) io_required_qty,
        to_number(null) late_dmd_stf_factor,
        to_number(null) late_order_count,
        to_number(null) late_order_qty,
        to_number(null) service_level,
        to_number(null) item_parent_demand,
        avg(md.demand_fulfillment_lead_time) demand_fulfillment_lead_time

      from
        (select distinct
            decode(nvl(md2.bucket_type,1), 1, d.calendar_date, 2, d.mfg_week_start_date, d.mfg_period_start_date) order_date,
            md2.organization_id,
            md2.sr_instance_id,
            md2.inventory_item_id,
            md2.original_item_id,
            md2.project_id,
            md2.task_id,
            md2.customer_id,
            md2.customer_site_id,
            md2.zone_id,
            md2.demand_class,
            md2.item_type_value,
            md2.origination_type,
            md2.probability,
            md2.using_requirement_quantity,
            md2.daily_demand_rate,
            md2.quantity_by_due_date,
            md2.unmet_quantity,
            md2.service_level,
            md2.demand_fulfillment_lead_time,
            md2.old_demand_quantity
        from
            msc_demands md2,
            msc_phub_dates_mv d
        where md2.plan_id=-1
            and md2.plan_id=p_plan_id
            and md2.origination_type=29
            and decode(nvl(md2.bucket_type,1), 1, d.calendar_date, 2, d.mfg_week_start_date, d.mfg_period_start_date)
                between greatest(md2.using_assembly_demand_date, l_plan_start_date)
                    and least(nvl(md2.assembly_demand_comp_date, md2.using_assembly_demand_date), l_plan_cutoff_date)
            and md2.sr_instance_id=l_sr_instance_id
            and d.mfg_seq_num is not null
        ) md,
        msc_trading_partners mtp
      where md.sr_instance_id = mtp.sr_instance_id(+)
        and md.organization_id = mtp.sr_tp_id(+)
        and mtp.partner_type(+) = 3
        and (l_refresh_mode = 1
           or (l_refresh_mode = 2 and (p_plan_id, md.sr_instance_id, md.organization_id, md.inventory_item_id) in
                 (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid) ) )
      group by
          decode(md.organization_id, -1, -23453, md.sr_instance_id),
          decode(md.organization_id, -1, -23453, md.organization_id),
          md.inventory_item_id,
          nvl(md.original_item_id, -23453),
          nvl(md.project_id,-23453),
          nvl(md.task_id, -23453),
          decode(sign(md.customer_id), 1, md.customer_id, -23453),
          decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453),
          decode(sign(md.zone_id), 1, md.zone_id, -23453),
          nvl(md.demand_class, '-23453'),

          decode(md.organization_id, -1, msc_hub_calendar.get_item_org(p_plan_id, md.inventory_item_id,
                       decode(md.sr_instance_id, -1, l_sr_instance_id, md.sr_instance_id)),
                      md.organization_id),

          decode(md.sr_instance_id, -1, l_sr_instance_id, md.sr_instance_id),
          md.order_date,
          -1 * md.origination_type,
          decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)),
          nvl(md.item_type_value,1)

    union all
    -- ODS sales orders
    select
        mso.sr_instance_id,
        mso.organization_id,
        mso.inventory_item_id,
        nvl(mso.original_item_id, -23453) original_item_id,
        nvl(mso.project_id,-23453) project_id,
        nvl(mso.task_id, -23453) task_id,
        decode(sign(mso.customer_id), 1, mso.customer_id, -23453) customer_id,
        decode(sign(mso.ship_to_site_use_id), 1, mso.ship_to_site_use_id, -23453) customer_site_id,
        to_number(-23453) region_id,
        nvl(mso.demand_class, '-23453') demand_class,
        mso.organization_id owning_org_id,
        mso.sr_instance_id owning_inst_id,
        trunc(mso.requirement_date) order_date,
        to_number(-30) order_type,
        decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)) currency_code,
        to_number(1) part_condition,

        sum(mso.primary_uom_quantity) demand_qty,
        to_number(null) qty_by_due_date,
        to_number(null) net_demand,
        to_number(null) constrained_fcst,
        sum(decode(nvl(mso.primary_uom_quantity,0),0,0,1)) indep_demand_count,
        to_number(null) indep_met_ontime_count,
        to_number(null) indep_met_full_count,
        sum(mso.primary_uom_quantity) indep_demand_qty,
        to_number(null) indep_by_due_date_qty,
        sum(mso.primary_uom_quantity) sales_order_qty,
        sum(decode(nvl(mso.primary_uom_quantity,0),0,0,1)) sales_order_count,
        to_number(null) sales_order_metr_count,
        to_number(null) sales_order_meta_count,
        to_number(null) sales_order_sd,
        to_number(null) sales_order_rd,
        to_number(null) sales_order_pd,
        to_number(null) forecast_qty,
        to_number(null) io_delivered_qty,
        to_number(null) io_required_qty,
        to_number(null) late_dmd_stf_factor,
        to_number(null) late_order_count,
        to_number(null) late_order_qty,
        to_number(null) service_level,
        to_number(null) item_parent_demand,
        to_number(null) demand_fulfillment_lead_time
    from
        msc_sales_orders mso,
        msc_trading_partners mtp
    where p_plan_id=-1
        and mso.sr_instance_id = mtp.sr_instance_id(+)
        and mso.organization_id = mtp.sr_tp_id(+)
        and mtp.partner_type(+) = 3
        and mso.sr_instance_id = l_sr_instance_id
        and (l_refresh_mode = 1
            or (l_refresh_mode = 2 and (p_plan_id, mso.sr_instance_id, mso.organization_id, mso.inventory_item_id) in
                 (select number1, number2, number3, number4 from msc_hub_query q where q.query_id = l_res_item_qid) ) )
        and trunc(mso.requirement_date) between l_plan_start_date and l_plan_cutoff_date
    group by
        mso.sr_instance_id,
        mso.organization_id,
        mso.inventory_item_id,
        nvl(mso.original_item_id, -23453),
        nvl(mso.project_id,-23453),
        nvl(mso.task_id, -23453),
        decode(sign(mso.customer_id), 1, mso.customer_id, -23453),
        decode(sign(mso.ship_to_site_use_id), 1, mso.ship_to_site_use_id, -23453),
        nvl(mso.demand_class, '-23453'),
        trunc(mso.requirement_date),
        decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code))

    union all
    select
         md1.sr_instance_id,
         md1.organization_id,
         md1.inventory_item_id,
         nvl(md1.original_item_id, -23453) original_item_id,
         nvl(md1.project_id,-23453)  project_id,
         nvl(md1.task_id,   -23453)  task_id,
         decode(sign(md1.customer_id), 1, md1.customer_id, -23453) customer_id,
         decode(sign(md1.customer_site_id), 1, md1.customer_site_id, -23453) customer_site_id,
         decode(sign(md1.zone_id), 1, md1.zone_id, -23453) region_id,
         nvl(md1.demand_class, '-23453') demand_class,
         md1.organization_id owning_org_id,
         md1.sr_instance_id  owning_inst_id,

         trunc(nvl(md1.firm_date,md1.using_assembly_demand_date)) order_date,
         -1 * md1.origination_type order_type,
         nvl(mtp1.currency_code, l_owning_currency_code) currency_code,
         nvl(md1.item_type_value,1) part_condition,
         to_number(null) demand_qty,
         to_number(null) qty_by_due_date,
         to_number(null) net_demand,
         to_number(null) constrained_fcst,
         to_number(null) indep_demand_count,
         to_number(null) indep_met_ontime_count,
         to_number(null) indep_met_full_count,
         to_number(null) indep_demand_qty,
         to_number(null) indep_by_due_date_qty,
         to_number(null) sales_order_qty,
         to_number(null) sales_order_count,
         to_number(null) sales_order_metr_count,
         to_number(null) sales_order_meta_count,
         to_number(null) sales_order_sd,
         to_number(null) sales_order_rd,
         to_number(null) sales_order_pd,
         to_number(null) forecast_qty,
         to_number(null) io_delivered_qty,
         to_number(null) io_required_qty,




   --- late demand satisfaction factor
   --

    sum(decode(md1.assembly_demand_comp_date,null,
                 decode(md1.origination_type,29,(nvl(md1.probability,1)* md1.using_requirement_quantity),
                        31,0,md1.using_requirement_quantity),
                 decode(md1.origination_type, 29,(nvl(md1.probability,1)* md1.daily_demand_rate),
                        31, 0,md1.daily_demand_rate))
          * round(decode(med1.exception_type,
              24, decode(sign(md1.dmd_satisfied_date - md1.using_assembly_demand_date), 0,0,
                md1.dmd_satisfied_date - md1.using_assembly_demand_date),
              69, 0,   --- only for exception 24 and 26
              26,decode(sign(md1.dmd_satisfied_date - md1.using_assembly_demand_date), 0,0,
                md1.dmd_satisfied_date - md1.using_assembly_demand_date),0))
               )
       /decode(nvl(least(sum(decode(md1.origination_type,29,nvl(md1.probability,0),null)),1),1),
                  0,1,
                  nvl(least(sum(decode(md1.origination_type,29,nvl(md1.probability,0),null)),1),1))

     - sum( nvl(md1.quantity_by_due_date,0) *  nvl(md1.probability,1)
         * round(decode(med1.exception_type,
              24, decode(sign(md1.dmd_satisfied_date - md1.using_assembly_demand_date), 0,0,
                md1.dmd_satisfied_date - md1.using_assembly_demand_date),
              69, 0, --- only for exception 24 and 26
              26,decode(sign(md1.dmd_satisfied_date - md1.using_assembly_demand_date), 0,0,
                md1.dmd_satisfied_date - md1.using_assembly_demand_date),0))
        )
            /decode(nvl(least(sum(decode(md1.origination_type,29,nvl(md1.probability,0),null)),1),1),
                  0,1,
                  nvl(least(sum(decode(md1.origination_type,29,nvl(md1.probability,0),null)),1),1))       late_dmd_stf_factor,


    --- late demand count
    sum(decode(med1.exception_type,
                       24,1,
                       26,1,
                       69,1,
                       to_number(null))) late_order_count,-- all demand type

    --- late demand val
    --- need denominator part for forecast demand qty???
    --- simply the decode???
    --- replace std_cost with net selling price

    sum(decode(med1.exception_type,
               24,
                   decode(md1.assembly_demand_comp_date,null,
                         decode(md1.origination_type,29,(nvl(md1.probability,1)* md1.using_requirement_quantity),
                                                     31,0,md1.using_requirement_quantity),
                   decode(md1.origination_type,29,(nvl(md1.probability,1)* md1.daily_demand_rate),
                                               31, 0,md1.daily_demand_rate)),
              69,
                   decode(md1.assembly_demand_comp_date,null,
                         decode(md1.origination_type,29,(nvl(md1.probability,1)* md1.using_requirement_quantity),
                                                     31,0,md1.using_requirement_quantity),
                   decode(md1.origination_type,29,(nvl(md1.probability,1)* md1.daily_demand_rate),
                                               31, 0,md1.daily_demand_rate)),
               26,
                   decode(md1.assembly_demand_comp_date,null,
                         decode(md1.origination_type,29,(nvl(md1.probability,1)* md1.using_requirement_quantity),
                                                     31,0,md1.using_requirement_quantity),
                   decode(md1.origination_type,29,(nvl(md1.probability,1)* md1.daily_demand_rate),
                                               31, 0,md1.daily_demand_rate)),
           to_number(null)) ) /
             decode(nvl(least(sum(decode(md1.origination_type,29,nvl(md1.probability,0),
                                                    null)),1),1),0,1,
                nvl(least(sum(decode(md1.origination_type,29,nvl(md1.probability,0),null)),1),1)
             ) late_order_qty,
         min(nvl(md1.service_level, 50)) service_level,
         to_number(null) item_parent_demand,
         to_number(null) demand_fulfillment_lead_time

    from msc_demands md1,msc_trading_partners mtp1,
         msc_exception_details med1
    where md1.plan_id=med1.plan_id
    and md1.plan_id=p_plan_id
    and md1.origination_type in (5,6,7,8,9,10,11,12,15,22,27,29,30)  --- only for indep demand
    and md1.sr_instance_id = med1.sr_instance_id
    and md1.organization_id =med1.organization_id
    and md1.inventory_item_id=med1.inventory_item_id
    and md1.demand_id= MED1.NUMBER1
    and med1.EXCEPTION_TYPE in (24,26,69)
    and md1.sr_instance_id = mtp1.sr_instance_id(+)
    and md1.organization_id = mtp1.sr_tp_id(+)
    and mtp1.partner_type(+) = 3
    and l_plan_type <> 6
    and md1.sr_instance_id<>-1
    and md1.organization_id<>-1   -- exclude global f/c
    and p_plan_id <> con_ods_plan_id
    group by
       md1.sr_instance_id,
       md1.organization_id,
       md1.inventory_item_id,
       nvl(md1.original_item_id, -23453),
       nvl(md1.project_id,-23453),
       nvl(md1.task_id, -23453),
       decode(sign(md1.customer_id), 1, md1.customer_id, -23453),
       decode(sign(md1.customer_site_id), 1, md1.customer_site_id, -23453),
       decode(sign(md1.zone_id), 1, md1.zone_id, -23453),
       nvl(md1.demand_class, '-23453'),

       md1.organization_id,
       md1.sr_instance_id,

       trunc(nvl(md1.firm_date,md1.using_assembly_demand_date)),
       -1 * md1.origination_type,
       nvl(mtp1.currency_code, l_owning_currency_code),
       nvl(md1.item_type_value,1)
    union all
    -- item_parent_demand
    select
        t.sr_instance_id,
        t.organization_id,
        t.inventory_item_id,
        t.original_item_id,
        t.project_id,
        t.task_id,
        t.customer_id,
        t.customer_site_id,
        t.region_id,
        t.demand_class,
        t.owning_org_id,
        t.owning_inst_id,
        t.order_date,
        t.order_type,
        nvl(mtp1.currency_code, l_owning_currency_code) currency_code,
        t.part_condition,
        to_number(null) demand_qty,
        to_number(null) qty_by_due_date,
        to_number(null) net_demand,
        to_number(null) constrained_fcst,
        to_number(null) indep_demand_count,
        to_number(null) indep_met_ontime_count,
        to_number(null) indep_met_full_count,
        to_number(null) indep_demand_qty,
        to_number(null) indep_by_due_date_qty,
        to_number(null) sales_order_qty,
        to_number(null) sales_order_count,
        to_number(null) sales_order_metr_count,
        to_number(null) sales_order_meta_count,
        to_number(null) sales_order_sd,
        to_number(null) sales_order_rd,
        to_number(null) sales_order_pd,
        to_number(null) forecast_qty,
        to_number(null) io_delivered_qty,
        to_number(null) io_required_qty,
        to_number(null) late_dmd_stf_factor,
        to_number(null) late_order_count,
        to_number(null) late_order_qty,
        to_number(null) service_level,
        sum(t.item_parent_demand) item_parent_demand,
        to_number(null) demand_fulfillment_lead_time
    from
        (select
            mfp1.sr_instance_id,
            mfp1.organization_id,
            mfp1.inventory_item_id,
            nvl(md.original_item_id, -23453) original_item_id,
            nvl(md.project_id, -23453) project_id,
            nvl(md.task_id, -23453) task_id,
            decode(sign(md.customer_id), 1, md.customer_id, -23453) customer_id,
            decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453) customer_site_id,
            decode(sign(md.zone_id), 1, md.zone_id, -23453) region_id,
            nvl(md.demand_class, '-23453') demand_class,
            md.organization_id owning_org_id,
            md.sr_instance_id owning_inst_id,
            trunc(mfp1.demand_date) order_date,
            -1 * md.origination_type order_type,
            nvl(md.item_type_value,1) part_condition,
            mfp2.demand_id item_parent_demand_id,
            avg(mfp1.demand_quantity) item_parent_demand
        from
            msc_full_pegging mfp1,
            msc_full_pegging mfp2,
            msc_demands md
        where mfp1.plan_id=mfp2.plan_id
            and mfp2.plan_id=md.plan_id
            and mfp2.demand_id=md.demand_id
            and md.origination_type in (5,6,7,8,9,10,11,12,15,22,27,29,30)
            and mfp1.end_pegging_id=mfp2.pegging_id
            and mfp2.prev_pegging_id is null
            and mfp1.plan_id=p_plan_id
            and p_plan_id <> con_ods_plan_id
        group by
            mfp1.sr_instance_id,
            mfp1.organization_id,
            mfp1.inventory_item_id,
            nvl(md.original_item_id, -23453),
            nvl(md.project_id, -23453),
            nvl(md.task_id, -23453),
            decode(sign(md.customer_id), 1, md.customer_id, -23453),
            decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453),
            decode(sign(md.zone_id), 1, md.zone_id, -23453),
            nvl(md.demand_class, '-23453'),
            md.organization_id,
            md.sr_instance_id,
            trunc(mfp1.demand_date),
            md.origination_type,
            nvl(md.item_type_value,1),
            mfp2.demand_id) t,
        msc_trading_partners mtp1
    where t.sr_instance_id=mtp1.sr_instance_id(+)
        and t.organization_id=mtp1.sr_tp_id(+)
        and mtp1.partner_type(+)=3
    group by
        t.sr_instance_id,
        t.organization_id,
        t.inventory_item_id,
        t.original_item_id,
        t.project_id,
        t.task_id,
        t.customer_id,
        t.customer_site_id,
        t.region_id,
        t.demand_class,
        t.owning_org_id,
        t.owning_inst_id,
        t.order_date,
        t.order_type,
        nvl(mtp1.currency_code, l_owning_currency_code),
        t.part_condition
    union all
    -- ASCP constrained_fcst from MSD_DEM_CONSTRAINED_FORECAST_V
    select
        t.sr_instance_id,
        t.organization_id,
        t.inventory_item_id,
        t.original_item_id,
        t.project_id,
        t.task_id,
        t.customer_id,
        t.customer_site_id,
        t.region_id,
        t.demand_class,
        t.owning_org_id,
        t.owning_inst_id,
        t.order_date,
        t.order_type,
        nvl(mtp1.currency_code, l_owning_currency_code) currency_code,
        t.part_condition,
        to_number(null) demand_qty,
        to_number(null) qty_by_due_date,
        to_number(null) net_demand,
        sum(t.constrained_fcst) constrained_fcst,
        to_number(null) indep_demand_count,
        to_number(null) indep_met_ontime_count,
        to_number(null) indep_met_full_count,
        to_number(null) indep_demand_qty,
        to_number(null) indep_by_due_date_qty,
        to_number(null) sales_order_qty,
        to_number(null) sales_order_count,
        to_number(null) sales_order_metr_count,
        to_number(null) sales_order_meta_count,
        to_number(null) sales_order_sd,
        to_number(null) sales_order_rd,
        to_number(null) sales_order_pd,
        to_number(null) forecast_qty,
        to_number(null) io_delivered_qty,
        to_number(null) io_required_qty,
        to_number(null) late_dmd_stf_factor,
        to_number(null) late_order_count,
        to_number(null) late_order_qty,
        to_number(null) service_level,
        to_number(null) item_parent_demand,
        to_number(null) demand_fulfillment_lead_time
    from
        (select
            md.sr_instance_id,
            md.organization_id,
            nvl(msib.inventory_item_id, msi.inventory_item_id) inventory_item_id,
            nvl(md.original_item_id, -23453) original_item_id,
            nvl(md.project_id, -23453) project_id,
            nvl(md.task_id, -23453) task_id,
            decode(sign(md.customer_id), 1, md.customer_id, -23453) customer_id,
            decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453) customer_site_id,
            decode(sign(md.zone_id), 1, md.zone_id, -23453) region_id,
            nvl(md.demand_class, '-23453') demand_class,
            md.organization_id owning_org_id,
            md.sr_instance_id owning_inst_id,
            trunc(md.using_assembly_demand_date) order_date,
            -1 * md.origination_type order_type,
            nvl(md.item_type_value,1) part_condition,
            md.quantity_by_due_date constrained_fcst
        from
            msc_demands md,
            msc_system_items msi,
            msc_system_items msia,
            msc_system_items msib
        where md.plan_id = msia.plan_id
            and md.sr_instance_id = msia.sr_instance_id
            and md.organization_id = msia.organization_id
            and md.using_assembly_item_id = msia.inventory_item_id
            and ((md.inventory_item_id <> md.using_assembly_item_id and msia.bom_item_type = 5)
                or (md.inventory_item_id = md.using_assembly_item_id))
            and md.origination_type in (6, 7, 8, 9, 11, 29, 30, 42, 22)
            and md.plan_id = msi.plan_id
            and md.sr_instance_id = msi.sr_instance_id
            and md.organization_id = msi.organization_id
            and md.inventory_item_id = msi.inventory_item_id
            and msi.mrp_planning_code <> 6
            and nvl(md.source_organization_id, -23453) = -23453
            and nvl(md.quantity_by_due_date, 0) <> 0
            and decode(nvl(msi.ato_forecast_control, 3), 3, 2, 1) = 1
            and md.plan_id = msib.plan_id(+)
            and md.original_inst_id = msib.sr_instance_id(+)
            and md.original_org_id = msib.organization_id(+)
            and md.original_item_id = msib.inventory_item_id(+)
            and msib.mrp_planning_code(+) <> 6
            and md.plan_id=p_plan_id
            and p_plan_id <> con_ods_plan_id
            and l_plan_type in (1,101,102,103,105)
        union all
        select
            md.sr_instance_id,
            md.organization_id,
            nvl(msib.inventory_item_id, msi.inventory_item_id) inventory_item_id,
            nvl(md.original_item_id, -23453) original_item_id,
            nvl(md.project_id, -23453) project_id,
            nvl(md.task_id, -23453) task_id,
            decode(sign(md.customer_id), 1, md.customer_id, -23453) customer_id,
            decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453) customer_site_id,
            decode(sign(md.zone_id), 1, md.zone_id, -23453) region_id,
            nvl(md.demand_class, '-23453') demand_class,
            md.organization_id owning_org_id,
            md.sr_instance_id owning_inst_id,
            trunc(md.dmd_satisfied_date) order_date,
            -1 * md.origination_type order_type,
            nvl(md.item_type_value,1) part_condition,
            (md.using_requirement_quantity - nvl(md.quantity_by_due_date, 0)) constrained_fcst
        from
            msc_demands md,
            msc_system_items msi,
            msc_system_items msia,
            msc_system_items msib
        where md.plan_id = msia.plan_id
            and md.sr_instance_id = msia.sr_instance_id
            and md.organization_id = msia.organization_id
            and md.using_assembly_item_id = msia.inventory_item_id
            and ((md.inventory_item_id <> md.using_assembly_item_id and msia.bom_item_type = 5)
                or (md.inventory_item_id = md.using_assembly_item_id))
            and md.origination_type in (6, 7, 8, 9, 11, 29, 30, 42, 22)
            and md.plan_id = msi.plan_id
            and md.sr_instance_id = msi.sr_instance_id
            and md.organization_id = msi.organization_id
            and md.inventory_item_id = msi.inventory_item_id
            and msi.mrp_planning_code <> 6
            and nvl(md.source_organization_id, -23453) = -23453
            and(md.using_requirement_quantity - nvl(md.quantity_by_due_date, 0) <> 0)
            and decode(nvl(msi.ato_forecast_control, 3), 3, 2, 1) = 1
            and md.plan_id = msib.plan_id(+)
            and md.original_inst_id = msib.sr_instance_id(+)
            and md.original_org_id = msib.organization_id(+)
            and md.original_item_id = msib.inventory_item_id(+)
            and msib.mrp_planning_code(+) <> 6
            and md.plan_id=p_plan_id
            and p_plan_id <> con_ods_plan_id
            and l_plan_type in (1,101,102,103,105)
            and md.dmd_satisfied_date is not null) t,
        msc_trading_partners mtp1
    where t.sr_instance_id=mtp1.sr_instance_id(+)
        and t.organization_id=mtp1.sr_tp_id(+)
        and mtp1.partner_type(+)=3
    group by
        t.sr_instance_id,
        t.organization_id,
        t.inventory_item_id,
        t.original_item_id,
        t.project_id,
        t.task_id,
        t.customer_id,
        t.customer_site_id,
        t.region_id,
        t.demand_class,
        t.owning_org_id,
        t.owning_inst_id,
        t.order_date,
        t.order_type,
        nvl(mtp1.currency_code, l_owning_currency_code),
        t.part_condition
    union all
    -- sales_order_qty on schedule_ship_date
    select
        decode(md.organization_id, -1, -23453, md.sr_instance_id) sr_instance_id,
        decode(md.organization_id, -1, -23453, md.organization_id) organization_id,
        md.inventory_item_id,
        nvl(md.original_item_id, -23453) original_item_id,
        nvl(md.project_id,-23453) project_id,
        nvl(md.task_id, -23453) task_id,
        decode(sign(md.customer_id), 1, md.customer_id, -23453) customer_id,
        decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453) customer_site_id,
        decode(sign(md.zone_id), 1, md.zone_id, -23453) region_id,
        nvl(md.demand_class, '-23453') demand_class,
        decode(md.organization_id,-1, msc_hub_calendar.get_item_org(p_plan_id, md.inventory_item_id,
            decode(md.sr_instance_id,-1, l_sr_instance_id, md.sr_instance_id)),
            md.organization_id) owning_org_id,
        decode(md.sr_instance_id, -1, l_sr_instance_id, md.sr_instance_id) owning_inst_id,
        trunc(nvl(nvl(md.dmd_satisfied_date, md.schedule_ship_date),
            md.using_assembly_demand_date)) order_date,
        to_number(-23453) order_type,
        decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)) currency_code,
        nvl(md.item_type_value, 1) part_condition,

        to_number(null) demand_qty,
        to_number(null) qty_by_due_date,
        to_number(null) net_demand,
        to_number(null) constrained_fcst,
        to_number(null) indep_demand_count,
        to_number(null) indep_met_ontime_count,
        to_number(null) indep_met_full_count,
        to_number(null) indep_demand_qty,
        to_number(null) indep_by_due_date_qty,
        to_number(null) sales_order_qty,
        to_number(null) sales_order_count,
        to_number(null) sales_order_metr_count,
        to_number(null) sales_order_meta_count,
        sum(decode(md.assembly_demand_comp_date, null,
            md.using_requirement_quantity, md.daily_demand_rate)) sales_order_sd,
        to_number(null) sales_order_rd,
        to_number(null) sales_order_pd,

        to_number(null) forecast_qty,
        to_number(null) io_delivered_qty,
        to_number(null) io_required_qty,
        to_number(null) late_dmd_stf_factor,
        to_number(null) late_order_count,
        to_number(null) late_order_qty,
        to_number(null) service_level,
        to_number(null) item_parent_demand,
        to_number(null) demand_fulfillment_lead_time
    from msc_demands md, msc_trading_partners mtp
    where md.plan_id = p_plan_id
        and md.sr_instance_id = mtp.sr_instance_id(+)
        and md.organization_id = mtp.sr_tp_id(+)
        and mtp.partner_type(+) = 3
        and md.origination_type = 30
        and p_plan_id <> con_ods_plan_id
    group by
        decode(md.organization_id, -1, -23453, md.sr_instance_id),
        decode(md.organization_id, -1, -23453, md.organization_id),
        md.inventory_item_id,
        nvl(md.original_item_id, -23453),
        nvl(md.project_id,-23453),
        nvl(md.task_id, -23453),
        decode(sign(md.customer_id), 1, md.customer_id, -23453),
        decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453),
        decode(sign(md.zone_id), 1, md.zone_id, -23453),
        nvl(md.demand_class, '-23453'),
        decode(md.organization_id,-1, msc_hub_calendar.get_item_org(p_plan_id, md.inventory_item_id,
            decode(md.sr_instance_id,-1, l_sr_instance_id, md.sr_instance_id)),
            md.organization_id),
        decode(md.sr_instance_id, -1, l_sr_instance_id, md.sr_instance_id),
        trunc(nvl(nvl(md.dmd_satisfied_date, md.schedule_ship_date),
            md.using_assembly_demand_date)),
        decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)),
        nvl(md.item_type_value, 1)
    union all
    -- sales_order_rd on request_ship_date
    select
        decode(md.organization_id, -1, -23453, md.sr_instance_id) sr_instance_id,
        decode(md.organization_id, -1, -23453, md.organization_id) organization_id,
        md.inventory_item_id,
        nvl(md.original_item_id, -23453) original_item_id,
        nvl(md.project_id,-23453) project_id,
        nvl(md.task_id, -23453) task_id,
        decode(sign(md.customer_id), 1, md.customer_id, -23453) customer_id,
        decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453) customer_site_id,
        decode(sign(md.zone_id), 1, md.zone_id, -23453) region_id,
        nvl(md.demand_class, '-23453') demand_class,
        decode(md.organization_id,-1, msc_hub_calendar.get_item_org(p_plan_id, md.inventory_item_id,
            decode(md.sr_instance_id,-1, l_sr_instance_id, md.sr_instance_id)),
            md.organization_id) owning_org_id,
        decode(md.sr_instance_id, -1, l_sr_instance_id, md.sr_instance_id) owning_inst_id,
        trunc(nvl(md.request_ship_date, md.using_assembly_demand_date)) order_date,
        to_number(-23453) order_type,
        decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)) currency_code,
        nvl(md.item_type_value, 1) part_condition,

        to_number(null) demand_qty,
        to_number(null) qty_by_due_date,
        to_number(null) net_demand,
        to_number(null) constrained_fcst,
        to_number(null) indep_demand_count,
        to_number(null) indep_met_ontime_count,
        to_number(null) indep_met_full_count,
        to_number(null) indep_demand_qty,
        to_number(null) indep_by_due_date_qty,
        to_number(null) sales_order_qty,
        to_number(null) sales_order_count,
        to_number(null) sales_order_metr_count,
        to_number(null) sales_order_meta_count,

        to_number(null) sales_order_sd,
        sum(decode(md.assembly_demand_comp_date, null,
            md.using_requirement_quantity, md.daily_demand_rate)) sales_order_rd,
        to_number(null) sales_order_pd,

        to_number(null) forecast_qty,
        to_number(null) io_delivered_qty,
        to_number(null) io_required_qty,
        to_number(null) late_dmd_stf_factor,
        to_number(null) late_order_count,
        to_number(null) late_order_qty,
        to_number(null) service_level,
        to_number(null) item_parent_demand,
        to_number(null) demand_fulfillment_lead_time
    from msc_demands md, msc_trading_partners mtp
    where md.plan_id = p_plan_id
        and md.sr_instance_id = mtp.sr_instance_id(+)
        and md.organization_id = mtp.sr_tp_id(+)
        and mtp.partner_type(+) = 3
        and md.origination_type = 30
        and p_plan_id <> con_ods_plan_id
    group by
        decode(md.organization_id, -1, -23453, md.sr_instance_id),
        decode(md.organization_id, -1, -23453, md.organization_id),
        md.inventory_item_id,
        nvl(md.original_item_id, -23453),
        nvl(md.project_id,-23453),
        nvl(md.task_id, -23453),
        decode(sign(md.customer_id), 1, md.customer_id, -23453),
        decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453),
        decode(sign(md.zone_id), 1, md.zone_id, -23453),
        nvl(md.demand_class, '-23453'),
        decode(md.organization_id,-1, msc_hub_calendar.get_item_org(p_plan_id, md.inventory_item_id,
            decode(md.sr_instance_id,-1, l_sr_instance_id, md.sr_instance_id)),
            md.organization_id),
        decode(md.sr_instance_id, -1, l_sr_instance_id, md.sr_instance_id),
        trunc(nvl(md.request_ship_date, md.using_assembly_demand_date)),
        decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)),
        nvl(md.item_type_value, 1)
    union all
    -- sales_order_pd on promise_ship_date
    select
        decode(md.organization_id, -1, -23453, md.sr_instance_id) sr_instance_id,
        decode(md.organization_id, -1, -23453, md.organization_id) organization_id,
        md.inventory_item_id,
        nvl(md.original_item_id, -23453) original_item_id,
        nvl(md.project_id,-23453) project_id,
        nvl(md.task_id, -23453) task_id,
        decode(sign(md.customer_id), 1, md.customer_id, -23453) customer_id,
        decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453) customer_site_id,
        decode(sign(md.zone_id), 1, md.zone_id, -23453) region_id,
        nvl(md.demand_class, '-23453') demand_class,
        decode(md.organization_id,-1, msc_hub_calendar.get_item_org(p_plan_id, md.inventory_item_id,
            decode(md.sr_instance_id,-1, l_sr_instance_id, md.sr_instance_id)),
            md.organization_id) owning_org_id,
        decode(md.sr_instance_id, -1, l_sr_instance_id, md.sr_instance_id) owning_inst_id,
        trunc(nvl(md.promise_ship_date, md.using_assembly_demand_date)) order_date,
        to_number(-23453) order_type,
        decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)) currency_code,
        nvl(md.item_type_value, 1) part_condition,

        to_number(null) demand_qty,
        to_number(null) qty_by_due_date,
        to_number(null) net_demand,
        to_number(null) constrained_fcst,
        to_number(null) indep_demand_count,
        to_number(null) indep_met_ontime_count,
        to_number(null) indep_met_full_count,
        to_number(null) indep_demand_qty,
        to_number(null) indep_by_due_date_qty,
        to_number(null) sales_order_qty,
        to_number(null) sales_order_count,
        to_number(null) sales_order_metr_count,
        to_number(null) sales_order_meta_count,

        to_number(null) sales_order_sd,
        to_number(null) sales_order_rd,
        sum(decode(md.assembly_demand_comp_date, null,
            md.using_requirement_quantity, md.daily_demand_rate)) sales_order_pd,

        to_number(null) forecast_qty,
        to_number(null) io_delivered_qty,
        to_number(null) io_required_qty,
        to_number(null) late_dmd_stf_factor,
        to_number(null) late_order_count,
        to_number(null) late_order_qty,
        to_number(null) service_level,
        to_number(null) item_parent_demand,
        to_number(null) demand_fulfillment_lead_time
    from msc_demands md, msc_trading_partners mtp
    where md.plan_id = p_plan_id
        and md.sr_instance_id = mtp.sr_instance_id(+)
        and md.organization_id = mtp.sr_tp_id(+)
        and mtp.partner_type(+) = 3
        and md.origination_type = 30
        and p_plan_id <> con_ods_plan_id
    group by
        decode(md.organization_id, -1, -23453, md.sr_instance_id),
        decode(md.organization_id, -1, -23453, md.organization_id),
        md.inventory_item_id,
        nvl(md.original_item_id, -23453),
        nvl(md.project_id,-23453),
        nvl(md.task_id, -23453),
        decode(sign(md.customer_id), 1, md.customer_id, -23453),
        decode(sign(md.customer_site_id), 1, md.customer_site_id, -23453),
        decode(sign(md.zone_id), 1, md.zone_id, -23453),
        nvl(md.demand_class, '-23453'),
        decode(md.organization_id,-1, msc_hub_calendar.get_item_org(p_plan_id, md.inventory_item_id,
            decode(md.sr_instance_id,-1, l_sr_instance_id, md.sr_instance_id)),
            md.organization_id),
        decode(md.sr_instance_id, -1, l_sr_instance_id, md.sr_instance_id),
        trunc(nvl(md.promise_ship_date, md.using_assembly_demand_date)),
        decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)),
        nvl(md.item_type_value, 1)
    ) demand_tbl,
   msc_currency_conv_mv mcc,
   msc_phub_customers_mv cmv,
     (select msi2.plan_id,
       msi2.sr_instance_id,
       msi2.organization_id,
       msi2.inventory_item_id,
       msi2.standard_cost,
       msi2.list_price,
       msi2.average_discount,
       nvl(f_2.number10,0) vmi_flag
    from msc_system_items msi2,
     msc_hub_query f_2
    where f_2.query_id(+) = l_qid_vmi
    and   f_2.number1(+) = msi2.plan_id
    and   f_2.number3(+) = msi2.sr_instance_id
    and   f_2.number4(+) = msi2.organization_id
    and   f_2.number5(+) = msi2.inventory_item_id) msi
   where mcc.from_currency(+) =demand_tbl.currency_code     -- make sure 'XXX' is not a valid currency code
   and mcc.to_currency(+) = fnd_profile.value('MSC_HUB_CUR_CODE_RPT')
   and mcc.calendar_date (+)= demand_tbl.order_date
   and cmv.customer_id(+) = nvl(demand_tbl.customer_id,-23453)
   and cmv.customer_site_id(+) = nvl(demand_tbl.customer_site_id,-23453)
   and cmv.region_id(+) = decode(nvl(demand_tbl.region_id,-23453),
                               -23453,decode(nvl(demand_tbl.customer_id,-23453),-23453,-23453,cmv.region_id(+)),
                demand_tbl.region_id)
    and msi.plan_id = p_plan_id
    and demand_tbl.owning_inst_id = msi.sr_instance_id
    and demand_tbl.owning_org_id = msi.organization_id
    and demand_tbl.inventory_item_id = msi.inventory_item_id

   group by
    decode(l_plan_type,4,1,9,1,0),
    demand_tbl.sr_instance_id,
    demand_tbl.organization_id,
    demand_tbl.inventory_item_id,
    demand_tbl.original_item_id,
    demand_tbl.project_id,
    demand_tbl.task_id,
    nvl(case when -demand_tbl.order_type in (5,6,7,8,9,10,11,12,15,22,27,29,30,81)
        then demand_tbl.customer_id end, -23453),

    msc_phub_util.validate_customer_site_id(
        nvl(case when -demand_tbl.order_type in (5,6,7,8,9,10,11,12,15,22,27,29,30,81)
                then demand_tbl.customer_id end, -23453),
        demand_tbl.customer_site_id),

    nvl(cmv.region_id, -23453),
    demand_tbl.demand_class,
    demand_tbl.owning_org_id,
    demand_tbl.owning_inst_id,
    decode(sign(to_number(demand_tbl.order_date-l_plan_start_date)),-1,
                                       msc_hub_calendar.last_work_date(p_plan_id,l_plan_start_date),
                       demand_tbl.order_date),
    demand_tbl.order_type,
    nvl(msi.vmi_flag, 0),
    demand_tbl.part_condition;

    l_rowcount1 := l_rowcount1 + sql%rowcount;
    msc_phub_util.log('msc_demands_f, insert='||sql%rowcount||', l_rowcount1='||l_rowcount1);
    commit;

    l_qid_last_date := msc_phub_util.get_reporting_dates(l_plan_start_date, l_plan_cutoff_date);

    -- msc_demands_cum_f
    insert into msc_demands_cum_f (
        plan_id,
        plan_run_id,
        sr_instance_id,
        organization_id,
        owning_inst_id,
        owning_org_id,
        inventory_item_id,
        customer_id,
        customer_site_id,
        region_id,
        original_item_id,
        vmi_flag,
        demand_class,
        io_plan_flag,
        order_date,
        aggr_type, category_set_id, sr_category_id,
        backlog_qty,
        cum_sales_order_qty,
        cum_forecast_qty,
        cum_qty_by_due_date,
        cum_qty_by_due_date_value,
        cum_qty_by_due_date_value2,
        cum_constrained_fcst,
        cum_constrained_fcst_value,
        cum_constrained_fcst_value2,
        created_by, creation_date,
        last_update_date, last_updated_by, last_update_login,
        program_id, program_login_id,
        program_application_id, request_id)
    select
        f.plan_id,
        f.plan_run_id,
        f.sr_instance_id,
        f.organization_id,
        f.owning_inst_id,
        f.owning_org_id,
        f.inventory_item_id,
        f.customer_id,
        f.customer_site_id,
        f.region_id,
        f.original_item_id,
        f.vmi_flag,
        f.demand_class,
        f.io_plan_flag,
        d.date1,
        to_number(0) aggr_type, to_number(-23453), to_number(-23453),
        sum(nvl(f.indep_demand_qty,0) - nvl(f.indep_by_due_date_qty,0)) backlog_qty,
        sum(nvl(f.sales_order_qty,0)) cum_sales_order_qty,
        sum(nvl(f.forecast_qty,0)) cum_forecast_qty,
        sum(nvl(f.qty_by_due_date,0)) cum_qty_by_due_date,
        sum(nvl(f.qty_by_due_date_value,0)) cum_qty_by_due_date_value,
        sum(nvl(f.qty_by_due_date_value2,0)) cum_qty_by_due_date_value2,
        sum(nvl(f.constrained_fcst,0)) cum_constrained_fcst,
        sum(nvl(f.constrained_fcst_value,0)) cum_constrained_fcst_value,
        sum(nvl(f.constrained_fcst_value2,0)) cum_constrained_fcst_value2,
        fnd_global.user_id, sysdate,
        sysdate, fnd_global.user_id, fnd_global.login_id,
        fnd_global.conc_program_id, fnd_global.conc_login_id,
        fnd_global.prog_appl_id, fnd_global.conc_request_id
    from
        msc_demands_f f,
        msc_hub_query d
    where f.plan_id=p_plan_id
        and f.plan_run_id=p_plan_run_id
        and f.aggr_type=0
        and d.query_id=l_qid_last_date
        and d.date1 >= f.order_date
    group by
        f.plan_id,
        f.plan_run_id,
        f.sr_instance_id,
        f.organization_id,
        f.owning_inst_id,
        f.owning_org_id,
        f.inventory_item_id,
        f.customer_id,
        f.customer_site_id,
        f.region_id,
        f.original_item_id,
        f.vmi_flag,
        f.demand_class,
        f.io_plan_flag,
        d.date1;

    l_rowcount2 := l_rowcount2 + sql%rowcount;
    msc_phub_util.log('msc_demands_cum_f, insert='||sql%rowcount||', l_rowcount2='||l_rowcount2);
    commit;

    if (l_rowcount1 > 0) then
        summarize_demands_f(errbuf, retcode, p_plan_id, p_plan_run_id);
    end if;

    if (l_rowcount2 > 0) then
        summarize_demands_cum_f(errbuf, retcode, p_plan_id, p_plan_run_id);
    end if;

    msc_phub_util.log('msc_demand_pkg.populate_details: complete');

 exception
    when no_data_found then

    retcode :=2;
    errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_DUPLICATE_DATA')||SQLCODE||' -ERROR- '||sqlerrm;

    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(fnd_log.LEVEL_UNEXPECTED,
            l_api_name,
            to_char(SQLCODE)||':'||sqlerrm||' in stmt_id='||l_stmt_id);
    end if;


     when dup_val_on_index then
         retcode :=2;
         errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_DUPLICATE_DATA')||SQLCODE||' -ERROR- '||sqlerrm;
     if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(fnd_log.LEVEL_UNEXPECTED,
            l_api_name,
            to_char(SQLCODE)||':'||sqlerrm||' in stmt_id='||l_stmt_id);
    end if;

    when others then
    retcode :=2;
    errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_POPULATE_ERROR')||SQLCODE||' -ERROR- '||sqlerrm;
    if( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       fnd_log.string(fnd_log.LEVEL_UNEXPECTED,
            l_api_name,
            to_char(SQLCODE)||':'||sqlerrm||' in stmt_id='||l_stmt_id);
    end if;
    msc_phub_util.log(to_char(SQLCODE)||':'||sqlerrm||' in stmt_id='||l_stmt_id);

end populate_details;


    procedure summarize_demands_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_category_set_id1 number := fnd_profile.value('MSC_HUB_CAT_SET_ID_1');
    begin
        msc_phub_util.log('msc_demand_pkg.summarize_demands_f');
        retcode := 0;
        errbuf := '';

        delete from msc_demands_f
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id and aggr_type>0;
        msc_phub_util.log('msc_demand_pkg.summarize_demands_f, delete='||sql%rowcount);
        commit;

        -- level 1
        insert into msc_demands_f (
            plan_id, plan_run_id,
            io_plan_flag,
            sr_instance_id, organization_id, inventory_item_id,
            original_item_id,
            project_id, task_id,
            customer_id, customer_site_id, region_id,
            demand_class,
            owning_org_id, owning_inst_id,
            order_date,
            aggr_type, category_set_id, sr_category_id,
            order_type, vmi_flag,
            part_condition,
            demand_qty,
            qty_by_due_date,
            net_demand,
            constrained_fcst,
            constrained_fcst_value,
            constrained_fcst_value2,
            indep_demand_count,
            indep_met_ontime_count,
            indep_met_full_count,
            indep_demand_value,
            indep_demand_value2,
            indep_demand_qty,
            annualized_cogs,
            indep_by_due_date_qty,
            sales_order_qty,
            sales_order_count,
            sales_order_metr_count,
            sales_order_meta_count,
            sales_order_sd,
            sales_order_sd_value,
            sales_order_sd_value2,
            sales_order_rd,
            sales_order_rd_value,
            sales_order_rd_value2,
            sales_order_pd,
            sales_order_pd_value,
            sales_order_pd_value2,
            forecast_qty,
            io_required_qty,
            io_delivered_qty,
            late_dmd_stf_factor,
            late_order_count,
            late_order_value,
            late_order_value2,
            service_level,
            item_parent_demand,
            item_parent_demand_value,
            demand_fulfillment_lead_time,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category (42, 43, 44)
        select
            f.plan_id, f.plan_run_id,
            f.io_plan_flag,
            f.sr_instance_id, f.organization_id,
            to_number(-23453) inventory_item_id,
            f.original_item_id,
            f.project_id, f.task_id,
            f.customer_id, f.customer_site_id, f.region_id,
            f.demand_class,
            f.owning_org_id, f.owning_inst_id,
            f.order_date,
            to_number(42) aggr_type,
            l_category_set_id1 category_set_id,
            nvl(q.sr_category_id, -23453),
            f.order_type, f.vmi_flag,
            f.part_condition,
            sum(f.demand_qty),
            sum(f.qty_by_due_date),
            sum(f.net_demand),
            sum(f.constrained_fcst),
            sum(f.constrained_fcst_value),
            sum(f.constrained_fcst_value2),
            sum(f.indep_demand_count),
            sum(f.indep_met_ontime_count),
            sum(f.indep_met_full_count),
            sum(f.indep_demand_value),
            sum(f.indep_demand_value2),
            sum(f.indep_demand_qty),
            sum(f.annualized_cogs),
            sum(f.indep_by_due_date_qty),
            sum(f.sales_order_qty),
            sum(f.sales_order_count),
            sum(f.sales_order_metr_count),
            sum(f.sales_order_meta_count),
            sum(f.sales_order_sd),
            sum(f.sales_order_sd_value),
            sum(f.sales_order_sd_value2),
            sum(f.sales_order_rd),
            sum(f.sales_order_rd_value),
            sum(f.sales_order_rd_value2),
            sum(f.sales_order_pd),
            sum(f.sales_order_pd_value),
            sum(f.sales_order_pd_value2),
            sum(f.forecast_qty),
            sum(f.io_required_qty),
            sum(f.io_delivered_qty),
            sum(f.late_dmd_stf_factor),
            sum(f.late_order_count),
            sum(f.late_order_value),
            sum(f.late_order_value2),
            min(service_level),
            sum(f.item_parent_demand),
            sum(f.item_parent_demand_value),
            avg(f.demand_fulfillment_lead_time),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_demands_f f,
            msc_phub_item_categories_mv q
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
            and f.owning_inst_id=q.sr_instance_id(+)
            and f.owning_org_id=q.organization_id(+)
            and f.inventory_item_id=q.inventory_item_id(+)
            and q.category_set_id(+)=l_category_set_id1
        group by
            f.plan_id, f.plan_run_id,
            f.io_plan_flag,
            f.sr_instance_id, f.organization_id,
            f.original_item_id,
            f.project_id, f.task_id,
            f.customer_id, f.customer_site_id, f.region_id,
            f.demand_class,
            f.owning_org_id, f.owning_inst_id,
            f.order_date,
            nvl(q.sr_category_id, -23453),
            f.order_type, f.vmi_flag,
            f.part_condition;

        msc_phub_util.log('msc_demand_pkg.summarize_demands_f, level1='||sql%rowcount);
        commit;

        -- level 2
        insert into msc_demands_f (
            plan_id, plan_run_id, io_plan_flag,
            sr_instance_id, organization_id, inventory_item_id,
            original_item_id,
            project_id, task_id,
            customer_id, customer_site_id, region_id,
            demand_class, owning_org_id, owning_inst_id, order_date,
            aggr_type, category_set_id, sr_category_id,
            order_type, vmi_flag,
            part_condition,
            demand_qty,
            qty_by_due_date,
            net_demand,
            constrained_fcst,
            constrained_fcst_value,
            constrained_fcst_value2,
            indep_demand_count,
            indep_met_ontime_count,
            indep_met_full_count,
            indep_demand_value,
            indep_demand_value2,
            indep_demand_qty,
            annualized_cogs,
            indep_by_due_date_qty,
            sales_order_qty,
            sales_order_count,
            sales_order_metr_count,
            sales_order_meta_count,
            sales_order_sd,
            sales_order_sd_value,
            sales_order_sd_value2,
            sales_order_rd,
            sales_order_rd_value,
            sales_order_rd_value2,
            sales_order_pd,
            sales_order_pd_value,
            sales_order_pd_value2,
            forecast_qty,
            io_required_qty,
            io_delivered_qty,
            late_dmd_stf_factor,
            late_order_count,
            late_order_value,
            late_order_value2,
            service_level,
            item_parent_demand,
            item_parent_demand_value,
            demand_fulfillment_lead_time,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category-mfg_period (1016, 1017, 1018)
        select
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id, f.inventory_item_id,
            f.original_item_id,
            f.project_id, f.task_id,
            f.customer_id, f.customer_site_id, f.region_id,
            f.demand_class, f.owning_org_id, f.owning_inst_id,
            d.mfg_period_start_date order_date,
            decode(f.aggr_type, 42, 1016, 43, 1017, 1018) aggr_type,
            f.category_set_id, f.sr_category_id,
            f.order_type, f.vmi_flag,
            f.part_condition,
            sum(f.demand_qty),
            sum(f.qty_by_due_date),
            sum(f.net_demand),
            sum(f.constrained_fcst),
            sum(f.constrained_fcst_value),
            sum(f.constrained_fcst_value2),
            sum(f.indep_demand_count),
            sum(f.indep_met_ontime_count),
            sum(f.indep_met_full_count),
            sum(f.indep_demand_value),
            sum(f.indep_demand_value2),
            sum(f.indep_demand_qty),
            sum(f.annualized_cogs),
            sum(f.indep_by_due_date_qty),
            sum(f.sales_order_qty),
            sum(f.sales_order_count),
            sum(f.sales_order_metr_count),
            sum(f.sales_order_meta_count),
            sum(f.sales_order_sd),
            sum(f.sales_order_sd_value),
            sum(f.sales_order_sd_value2),
            sum(f.sales_order_rd),
            sum(f.sales_order_rd_value),
            sum(f.sales_order_rd_value2),
            sum(f.sales_order_pd),
            sum(f.sales_order_pd_value),
            sum(f.sales_order_pd_value2),
            sum(f.forecast_qty),
            sum(f.io_required_qty),
            sum(f.io_delivered_qty),
            sum(f.late_dmd_stf_factor),
            sum(f.late_order_count),
            sum(f.late_order_value),
            sum(f.late_order_value2),
            min(f.service_level),
            sum(f.item_parent_demand),
            sum(f.item_parent_demand_value),
            avg(f.demand_fulfillment_lead_time),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_demands_f f,
            msc_phub_dates_mv d
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type between 42 and 44
            and f.order_date = d.calendar_date
            and d.mfg_period_start_date is not null
        group by
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id, f.inventory_item_id,
            f.original_item_id,
            f.project_id, f.task_id,
            f.customer_id, f.customer_site_id, f.region_id,
            f.demand_class, f.owning_org_id, f.owning_inst_id,
            d.mfg_period_start_date,
            decode(f.aggr_type, 42, 1016, 43, 1017, 1018),
            f.category_set_id, f.sr_category_id,
            f.order_type, f.vmi_flag,
            f.part_condition
        union all
        -- category-fiscal_period (1019, 1020, 1021)
        select
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id, f.inventory_item_id,
            f.original_item_id,
            f.project_id, f.task_id,
            f.customer_id, f.customer_site_id, f.region_id,
            f.demand_class, f.owning_org_id, f.owning_inst_id,
            d.fis_period_start_date order_date,
            decode(f.aggr_type, 42, 1019, 43, 1020, 1021) aggr_type,
            f.category_set_id, f.sr_category_id,
            f.order_type, f.vmi_flag,
            f.part_condition,
            sum(f.demand_qty),
            sum(f.qty_by_due_date),
            sum(f.net_demand),
            sum(f.constrained_fcst),
            sum(f.constrained_fcst_value),
            sum(f.constrained_fcst_value2),
            sum(f.indep_demand_count),
            sum(f.indep_met_ontime_count),
            sum(f.indep_met_full_count),
            sum(f.indep_demand_value),
            sum(f.indep_demand_value2),
            sum(f.indep_demand_qty),
            sum(f.annualized_cogs),
            sum(f.indep_by_due_date_qty),
            sum(f.sales_order_qty),
            sum(f.sales_order_count),
            sum(f.sales_order_metr_count),
            sum(f.sales_order_meta_count),
            sum(f.sales_order_sd),
            sum(f.sales_order_sd_value),
            sum(f.sales_order_sd_value2),
            sum(f.sales_order_rd),
            sum(f.sales_order_rd_value),
            sum(f.sales_order_rd_value2),
            sum(f.sales_order_pd),
            sum(f.sales_order_pd_value),
            sum(f.sales_order_pd_value2),
            sum(f.forecast_qty),
            sum(f.io_required_qty),
            sum(f.io_delivered_qty),
            sum(f.late_dmd_stf_factor),
            sum(f.late_order_count),
            sum(f.late_order_value),
            sum(f.late_order_value2),
            min(f.service_level),
            sum(f.item_parent_demand),
            sum(f.item_parent_demand_value),
            avg(f.demand_fulfillment_lead_time),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_demands_f f,
            msc_phub_dates_mv d
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type between 42 and 44
            and f.order_date = d.calendar_date
            and d.fis_period_start_date is not null
        group by
            f.plan_id, f.plan_run_id, f.io_plan_flag,
            f.sr_instance_id, f.organization_id, f.inventory_item_id,
            f.original_item_id,
            f.project_id, f.task_id,
            f.customer_id, f.customer_site_id, f.region_id,
            f.demand_class, f.owning_org_id, f.owning_inst_id,
            d.fis_period_start_date,
            decode(f.aggr_type, 42, 1019, 43, 1020, 1021),
            f.category_set_id, f.sr_category_id,
            f.order_type, f.vmi_flag,
            f.part_condition;

        msc_phub_util.log('msc_demand_pkg.summarize_demands_f, level2='||sql%rowcount);
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_demand_pkg.summarize_demands_f: '||sqlerrm;
            raise;
    end summarize_demands_f;

    procedure summarize_demands_cum_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_category_set_id1 number := fnd_profile.value('MSC_HUB_CAT_SET_ID_1');
    begin
        msc_phub_util.log('msc_demand_pkg.summarize_demands_cum_f');
        retcode := 0;
        errbuf := '';

        delete from msc_demands_cum_f
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id and aggr_type>0;
        msc_phub_util.log('msc_demand_pkg.summarize_demands_cum_f, delete='||sql%rowcount);
        commit;

        -- level 1
        insert into msc_demands_cum_f (
            plan_id, plan_run_id,
            io_plan_flag,
            sr_instance_id, organization_id, inventory_item_id,
            original_item_id,
            vmi_flag,
            customer_id, customer_site_id, region_id,
            demand_class,
            owning_org_id, owning_inst_id,
            order_date,
            aggr_type, category_set_id, sr_category_id,
            backlog_qty,
            cum_sales_order_qty,
            cum_forecast_qty,
            cum_constrained_fcst,
            cum_constrained_fcst_value,
            cum_constrained_fcst_value2,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category (42, 43, 44)
        select
            f.plan_id, f.plan_run_id,
            f.io_plan_flag,
            f.sr_instance_id, f.organization_id,
            to_number(-23453) inventory_item_id,
            f.original_item_id,
            f.vmi_flag,
            f.customer_id, f.customer_site_id, f.region_id,
            f.demand_class,
            f.owning_org_id, f.owning_inst_id,
            f.order_date,
            to_number(42) aggr_type,
            l_category_set_id1 category_set_id,
            nvl(q.sr_category_id, -23453),
            sum(f.backlog_qty),
            sum(f.cum_sales_order_qty),
            sum(f.cum_forecast_qty),
            sum(f.cum_constrained_fcst),
            sum(f.cum_constrained_fcst_value),
            sum(f.cum_constrained_fcst_value2),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_demands_cum_f f,
            msc_phub_item_categories_mv q
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
            and f.owning_inst_id=q.sr_instance_id(+)
            and f.owning_org_id=q.organization_id(+)
            and f.inventory_item_id=q.inventory_item_id(+)
            and q.category_set_id(+)=l_category_set_id1
        group by
            f.plan_id, f.plan_run_id,
            f.io_plan_flag,
            f.sr_instance_id, f.organization_id,
            f.original_item_id,
            f.vmi_flag,
            f.customer_id, f.customer_site_id, f.region_id,
            f.demand_class,
            f.owning_org_id, f.owning_inst_id,
            f.order_date,
            nvl(q.sr_category_id, -23453);

        msc_phub_util.log('msc_demand_pkg.summarize_demands_cum_f, level1='||sql%rowcount);
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_demand_pkg.summarize_demands_cum_f: '||sqlerrm;
            raise;
    end summarize_demands_cum_f;

    procedure export_demands_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_demand_pkg.export_demands_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_demands_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_demands_f('||
            '     st_transaction_id,'||
            '     error_code,'||
            '     sr_instance_id,'||
            '     organization_id,'||
            '     owning_inst_id,'||
            '     owning_org_id,'||
            '     inventory_item_id,'||
            '     customer_id,'||
            '     customer_site_id,'||
            '     region_id,'||
            '     project_id,'||
            '     task_id,'||
            '     organization_code,'||
            '     owning_org_code,'||
            '     item_name,'||
            '     customer_name,'||
            '     customer_site_code,'||
            '     zone,'||
            '     project_number,'||
            '     task_number,'||
            '     order_type,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     part_condition,'||
            '     original_item_id,';
        end if;
        l_sql := l_sql||
            '     order_date,'||
            '     vmi_flag,'||
            '     demand_class,'||
            '     demand_qty,'||
            '     qty_by_due_date,'||
            '     indep_demand_count,'||
            '     indep_met_ontime_count,'||
            '     indep_met_full_count,'||
            '     indep_demand_value,'||
            '     indep_demand_value2,'||
            '     indep_demand_qty,'||
            '     annualized_cogs,'||
            '     indep_by_due_date_qty,'||
            '     sales_order_qty,'||
            '     sales_order_count,'||
            '     sales_order_metr_count,'||
            '     sales_order_meta_count,'||
            '     forecast_qty,'||
            '     late_dmd_stf_factor,'||
            '     late_order_count,'||
            '     late_order_value,'||
            '     late_order_value2,'||
            '     qty_by_due_date_value,'||
            '     qty_by_due_date_value2,'||
            '     io_delivered_qty,'||
            '     io_required_qty,'||
            '     net_demand,'||
            '     constrained_fcst,'||
            '     constrained_fcst_value,'||
            '     constrained_fcst_value2,'||
            '     service_level,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     item_parent_demand,'||
            '     item_parent_demand_value,'||
            '     demand_fulfillment_lead_time,'||
            '     sales_order_sd,'||
            '     sales_order_sd_value,'||
            '     sales_order_sd_value2,'||
            '     sales_order_rd,'||
            '     sales_order_rd_value,'||
            '     sales_order_rd_value2,'||
            '     sales_order_pd,'||
            '     sales_order_pd_value,'||
            '     sales_order_pd_value2,';
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
            '     f.customer_id,'||
            '     f.customer_site_id,'||
            '     f.region_id,'||
            '     f.project_id,'||
            '     f.task_id,'||
            '     mtp.organization_code,'||
            '     mtp2.organization_code,'||
            '     mi.item_name,'||
            '     decode(f.customer_id, -23453, null, cmv.customer_name),'||
            '     decode(f.customer_site_id, -23453, null, cmv.customer_site),'||
            '     decode(f.region_id, -23453, null, cmv.zone),'||
            '     proj.project_number,'||
            '     proj.task_number,'||
            '     f.order_type,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     f.part_condition,'||
            '     f.original_item_id,';
        end if;
        l_sql := l_sql||
            '     f.order_date,'||
            '     f.vmi_flag,'||
            '     f.demand_class,'||
            '     f.demand_qty,'||
            '     f.qty_by_due_date,'||
            '     f.indep_demand_count,'||
            '     f.indep_met_ontime_count,'||
            '     f.indep_met_full_count,'||
            '     f.indep_demand_value,'||
            '     f.indep_demand_value2,'||
            '     f.indep_demand_qty,'||
            '     f.annualized_cogs,'||
            '     f.indep_by_due_date_qty,'||
            '     f.sales_order_qty,'||
            '     f.sales_order_count,'||
            '     f.sales_order_metr_count,'||
            '     f.sales_order_meta_count,'||
            '     f.forecast_qty,'||
            '     f.late_dmd_stf_factor,'||
            '     f.late_order_count,'||
            '     f.late_order_value,'||
            '     f.late_order_value2,'||
            '     f.qty_by_due_date_value,'||
            '     f.qty_by_due_date_value2,'||
            '     f.io_delivered_qty,'||
            '     f.io_required_qty,'||
            '     f.net_demand,'||
            '     f.constrained_fcst,'||
            '     f.constrained_fcst_value,'||
            '     f.constrained_fcst_value2,'||
            '     f.service_level,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     f.item_parent_demand,'||
            '     f.item_parent_demand_value,'||
            '     f.demand_fulfillment_lead_time,'||
            '     f.sales_order_sd,'||
            '     f.sales_order_sd_value,'||
            '     f.sales_order_sd_value2,'||
            '     f.sales_order_rd,'||
            '     f.sales_order_rd_value,'||
            '     f.sales_order_rd_value2,'||
            '     f.sales_order_pd,'||
            '     f.sales_order_pd_value,'||
            '     f.sales_order_pd_value2,';
        end if;
        l_sql := l_sql||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_demands_f'||l_suffix||' f,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp2,'||
            '     '||l_apps_schema||'.msc_items'||l_suffix||' mi,'||
            '     '||l_apps_schema||'.msc_phub_customers_mv'||l_suffix||' cmv,'||
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
            '     and mtp.sr_tp_id(+)=f.organization_id'||
            '     and mtp2.partner_type(+)=3'||
            '     and mtp2.sr_instance_id(+)=f.owning_inst_id'||
            '     and mtp2.sr_tp_id(+)=f.owning_org_id'||
            '     and mi.inventory_item_id(+)=f.inventory_item_id'||
            '     and cmv.customer_id(+)=f.customer_id'||
            '     and cmv.customer_site_id(+)=f.customer_site_id'||
            '     and cmv.region_id(+)=f.region_id'||
            '     and proj.project_id(+)=f.project_id'||
            '     and proj.task_id(+)=f.task_id'||
            '     and proj.sr_instance_id(+)=f.sr_instance_id'||
            '     and proj.organization_id(+)=f.organization_id';

        execute immediate l_sql using p_st_transaction_id, p_plan_id, p_plan_run_id;
        commit;
        msc_phub_util.log('msc_demand_pkg.export_demands_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_demand_pkg.export_demands_f: '||sqlerrm;
            raise;
    end export_demands_f;

    procedure export_demands_cum_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_demand_pkg.export_demands_cum_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_demands_cum_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_demands_cum_f('||
            '     st_transaction_id,'||
            '     error_code,'||
            '     sr_instance_id,'||
            '     organization_id,'||
            '     owning_inst_id,'||
            '     owning_org_id,'||
            '     inventory_item_id,'||
            '     customer_id,'||
            '     customer_site_id,'||
            '     region_id,'||
            '     organization_code,'||
            '     owning_org_code,'||
            '     item_name,'||
            '     customer_name,'||
            '     customer_site_code,'||
            '     zone,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     original_item_id,';
        end if;
        l_sql := l_sql||
            '     order_date,'||
            '     vmi_flag,'||
            '     demand_class,'||
            '     backlog_qty,'||
            '     cum_sales_order_qty,'||
            '     cum_forecast_qty,'||
            '     cum_qty_by_due_date,'||
            '     cum_qty_by_due_date_value,'||
            '     cum_qty_by_due_date_value2,'||
            '     cum_constrained_fcst,'||
            '     cum_constrained_fcst_value,'||
            '     cum_constrained_fcst_value2,'||
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
            '     f.customer_id,'||
            '     f.customer_site_id,'||
            '     f.region_id,'||
            '     mtp.organization_code,'||
            '     mtp2.organization_code,'||
            '     mi.item_name,'||
            '     decode(f.customer_id, -23453, null, cmv.customer_name),'||
            '     decode(f.customer_site_id, -23453, null, cmv.customer_site),'||
            '     decode(f.region_id, -23453, null, cmv.zone),';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     f.original_item_id,';
        end if;
        l_sql := l_sql||
            '     f.order_date,'||
            '     f.vmi_flag,'||
            '     f.demand_class,'||
            '     f.backlog_qty,'||
            '     f.cum_sales_order_qty,'||
            '     f.cum_forecast_qty,'||
            '     f.cum_qty_by_due_date,'||
            '     f.cum_qty_by_due_date_value,'||
            '     f.cum_qty_by_due_date_value2,'||
            '     f.cum_constrained_fcst,'||
            '     f.cum_constrained_fcst_value,'||
            '     f.cum_constrained_fcst_value2,'||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_demands_cum_f'||l_suffix||' f,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp2,'||
            '     '||l_apps_schema||'.msc_items'||l_suffix||' mi,'||
            '     '||l_apps_schema||'.msc_phub_customers_mv'||l_suffix||' cmv'||
            ' where f.plan_id=:p_plan_id'||
            '     and f.plan_run_id=:p_plan_run_id'||
            '     and f.aggr_type=0'||
            '     and mtp.partner_type(+)=3'||
            '     and mtp.sr_instance_id(+)=f.sr_instance_id'||
            '     and mtp.sr_tp_id(+)=f.organization_id'||
            '     and mtp2.partner_type(+)=3'||
            '     and mtp2.sr_instance_id(+)=f.owning_inst_id'||
            '     and mtp2.sr_tp_id(+)=f.owning_org_id'||
            '     and mi.inventory_item_id(+)=f.inventory_item_id'||
            '     and cmv.customer_id(+)=f.customer_id'||
            '     and cmv.customer_site_id(+)=f.customer_site_id'||
            '     and cmv.region_id(+)=f.region_id';

        execute immediate l_sql using p_st_transaction_id, p_plan_id, p_plan_run_id;
        commit;
        msc_phub_util.log('msc_demand_pkg.export_demands_cum_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_demand_pkg.export_demands_cum_f: '||sqlerrm;
            raise;
    end export_demands_cum_f;

    procedure import_demands_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_demands_f';
        l_fact_table varchar2(30) := 'msc_demands_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_demand_pkg.import_demands_f');
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

        l_result := l_result + msc_phub_util.decode_item_key(
            l_staging_table, p_st_transaction_id, 'original_item_id', 'original_item_name');

        l_result := l_result + msc_phub_util.decode_customer_key(
            l_staging_table, p_st_transaction_id,
            'customer_id', 'customer_site_id', 'region_id',
            'customer_name', 'customer_site_code', 'zone');

        l_result := l_result + msc_phub_util.decode_project_key(
            l_staging_table, p_st_transaction_id);

        msc_phub_util.log('msc_demand_pkg.import_demands_f: insert into msc_demands_f');
        insert into msc_demands_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            owning_inst_id,
            owning_org_id,
            inventory_item_id,
            original_item_id,
            customer_id,
            customer_site_id,
            region_id,
            project_id,
            task_id,
            order_type,
            part_condition,
            demand_class,
            order_date,
            io_plan_flag,
            vmi_flag,
            demand_qty,
            qty_by_due_date,
            indep_demand_count,
            indep_met_ontime_count,
            indep_met_full_count,
            indep_demand_value,
            indep_demand_value2,
            indep_demand_qty,
            annualized_cogs,
            indep_by_due_date_qty,
            sales_order_qty,
            sales_order_count,
            sales_order_metr_count,
            sales_order_meta_count,
            sales_order_sd,
            sales_order_sd_value,
            sales_order_sd_value2,
            sales_order_rd,
            sales_order_rd_value,
            sales_order_rd_value2,
            sales_order_pd,
            sales_order_pd_value,
            sales_order_pd_value2,
            forecast_qty,
            late_dmd_stf_factor,
            late_order_count,
            late_order_value,
            late_order_value2,
            qty_by_due_date_value,
            qty_by_due_date_value2,
            io_delivered_qty,
            io_required_qty,
            net_demand,
            constrained_fcst,
            constrained_fcst_value,
            constrained_fcst_value2,
            service_level,
            item_parent_demand,
            item_parent_demand_value,
            demand_fulfillment_lead_time,
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
            -23453 original_item_id,
            nvl(customer_id, -23453),
            nvl(customer_site_id, -23453),
            nvl(region_id, -23453),
            nvl(project_id, -23453),
            nvl(task_id, -23453),
            order_type,
            part_condition,
            demand_class,
            order_date,
            decode(p_plan_type, 4, 1, 0) io_plan_flag,
            vmi_flag,
            demand_qty,
            qty_by_due_date,
            indep_demand_count,
            indep_met_ontime_count,
            indep_met_full_count,
            indep_demand_value,
            indep_demand_value2,
            indep_demand_qty,
            annualized_cogs,
            indep_by_due_date_qty,
            sales_order_qty,
            sales_order_count,
            sales_order_metr_count,
            sales_order_meta_count,
            sales_order_sd,
            sales_order_sd_value,
            sales_order_sd_value2,
            sales_order_rd,
            sales_order_rd_value,
            sales_order_rd_value2,
            sales_order_pd,
            sales_order_pd_value,
            sales_order_pd_value2,
            forecast_qty,
            late_dmd_stf_factor,
            late_order_count,
            late_order_value,
            late_order_value2,
            qty_by_due_date_value,
            qty_by_due_date_value2,
            io_delivered_qty,
            io_required_qty,
            net_demand,
            constrained_fcst,
            constrained_fcst_value,
            constrained_fcst_value2,
            service_level,
            item_parent_demand,
            item_parent_demand_value,
            demand_fulfillment_lead_time,
            0, -23453, -23453,
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_demands_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_demand_pkg.import_demands_f: inserted='||sql%rowcount);
        commit;

        summarize_demands_f(errbuf, retcode, p_plan_id, p_plan_run_id);

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_demand_pkg.import_demands_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_demand_pkg.import_demands_f: '||sqlerrm;
            raise;
    end import_demands_f;

    procedure import_demands_cum_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_demands_cum_f';
        l_fact_table varchar2(30) := 'msc_demands_cum_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_demand_pkg.import_demands_cum_f');
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

        l_result := l_result + msc_phub_util.decode_item_key(
            l_staging_table, p_st_transaction_id, 'original_item_id', 'original_item_name');

        l_result := l_result + msc_phub_util.decode_customer_key(
            l_staging_table, p_st_transaction_id,
            'customer_id', 'customer_site_id', 'region_id',
            'customer_name', 'customer_site_code', 'zone');

        msc_phub_util.log('msc_demand_pkg.import_demands_cum_f: insert into msc_demands_cum_f');
        insert into msc_demands_cum_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            owning_inst_id,
            owning_org_id,
            inventory_item_id,
            original_item_id,
            customer_id,
            customer_site_id,
            region_id,
            demand_class,
            order_date,
            io_plan_flag,
            vmi_flag,
            backlog_qty,
            cum_sales_order_qty,
            cum_forecast_qty,
            cum_qty_by_due_date,
            cum_qty_by_due_date_value,
            cum_qty_by_due_date_value2,
            cum_constrained_fcst,
            cum_constrained_fcst_value,
            cum_constrained_fcst_value2,
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
            -23453 original_item_id,
            nvl(customer_id, -23453),
            nvl(customer_site_id, -23453),
            nvl(region_id, -23453),
            demand_class,
            order_date,
            decode(p_plan_type, 4, 1, 0) io_plan_flag,
            vmi_flag,
            backlog_qty,
            cum_sales_order_qty,
            cum_forecast_qty,
            cum_qty_by_due_date,
            cum_qty_by_due_date_value,
            cum_qty_by_due_date_value2,
            cum_constrained_fcst,
            cum_constrained_fcst_value,
            cum_constrained_fcst_value2,
            0, -23453, -23453,
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_demands_cum_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_demand_pkg.import_demands_cum_f: inserted='||sql%rowcount);
        commit;

        summarize_demands_cum_f(errbuf, retcode, p_plan_id, p_plan_run_id);

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_demand_pkg.import_demands_cum_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_demand_pkg.import_demands_cum_f: '||sqlerrm;
            raise;
    end import_demands_cum_f;

end msc_demand_pkg;

/
