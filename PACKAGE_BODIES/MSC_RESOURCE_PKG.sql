--------------------------------------------------------
--  DDL for Package Body MSC_RESOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_RESOURCE_PKG" as
/* $Header: MSCHBRSB.pls 120.14.12010000.12 2010/03/03 23:39:50 wexia ship $ */
  l_constrained_plan    number ;

procedure populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2, p_plan_id in number, p_plan_run_id in number) is
    l_refresh_mode  number;
    l_res_rn_qid  number;
    con_ods_plan_id constant number := -1;
    l_qid_last_date number;
    l_plan_start_date date;
    l_plan_cutoff_date date;
    l_plan_type number;
    l_sr_instance_id number;
    l_rowcount1 number := 0;
    l_rowcount2 number := 0;
    l_owning_currency_code varchar2(20) := msc_phub_util.get_owning_currency_code(p_plan_run_id);
begin
    msc_phub_util.log('msc_resource_pkg.populate_details');
    l_constrained_plan := msc_phub_util.is_plan_constrained(p_plan_id);
    retcode := 0;
    errbuf := null;

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
            l_res_rn_qid := msc_phub_util.get_resource_rn_qid(p_plan_id, p_plan_run_id);

            delete from msc_resources_f
            where  plan_id = p_plan_id
                and plan_run_id = p_plan_run_id
                and (p_plan_id, sr_instance_id, organization_id, department_id, resource_id) in
                    (select number1, number2, number3, number4, number5 from msc_hub_query q where q.query_id = l_res_rn_qid);

            l_rowcount1 := l_rowcount1 + sql%rowcount;
            msc_phub_util.log('msc_resources_f, delete='||sql%rowcount||', l_rowcount1='||l_rowcount1);

            delete from msc_resources_cum_f
            where  plan_id = p_plan_id
                and plan_run_id = p_plan_run_id
                and (p_plan_id, sr_instance_id, organization_id, department_id, resource_id) in
                    (select number1, number2, number3, number4, number5 from msc_hub_query q where q.query_id = l_res_rn_qid);

            l_rowcount2 := l_rowcount2 + sql%rowcount;
            msc_phub_util.log('msc_resources_cum_f, delete='||sql%rowcount||', l_rowcount2='||l_rowcount2);
            commit;
        end if;
    end if;

    l_qid_last_date := msc_phub_util.get_reporting_dates(l_plan_start_date, l_plan_cutoff_date);

    insert into msc_resources_f(
        plan_id,
        plan_run_id,
        sr_instance_id,
        organization_id,
        department_id,
        owning_department_id,
        resource_id,
        inventory_item_id,
        analysis_date,
        aggr_type, resource_group,
        created_by,
        creation_date,
        last_update_date,
        last_updated_by,
        last_update_login,
        program_id,
        program_login_id,
        program_application_id,
        request_id,
        required_hours,
        available_hours,
        setup_time_hrs,
        order_quantity,
        resource_hours,
        no_of_orders,
        resource_cost,
        resource_cost2
    )
          --values
             select
                 plan_id ,
                 plan_run_id ,
                 sr_instance_id ,
                 organization_id ,
                 department_id ,
                 nvl(owning_department_id,-23453),
                 resource_id ,
                 inventory_item_id ,
                 analysis_date ,
                 to_number(0) aggr_type,
                 '-23453' resource_group,
                 fnd_global.user_id created_by,
                     sysdate creation_date,
                     sysdate last_update_date,
                     fnd_global.user_id last_updated_by,
                     fnd_global.login_id last_update_login,
                     fnd_global.conc_program_id program_id,
                     fnd_global.conc_login_id program_login_id,
                     fnd_global.prog_appl_id program_application_id,
                     fnd_global.conc_request_id request_id,
                 sum(required_hours),
                 sum(available_hours) ,
                 sum(setup_time_hrs) ,
                 sum(order_quantity) ,
                 sum(resource_hours),
                 sum(no_of_orders),
                sum(resource_cost) resource_cost,
                sum(resource_cost2) resource_cost2
             from
             (
                   select
                           mrr.plan_id plan_id,
                           p_plan_run_id plan_run_id,
                           mrr.sr_instance_id sr_instance_id,
                           mrr.organization_id organization_id,
                           mrr.department_id department_id,
                           nvl(mdr.owning_department_id,mrr.department_id) owning_department_id,
                           mrr.resource_id resource_id,
                           -23453 inventory_item_id, -- nvl(mrr.assembly_item_id, -23453), need vijay confirm
                           trunc(decode(l_constrained_plan,1,mrr.start_date,nvl(mrr.end_date,mrr.start_date))) analysis_date,
                           sum(decode(nvl(mrr.schedule_flag,2),1,(mrr.resource_hours),0) ) required_hours,
                           to_number(null) available_hours,
                           sum(decode(nvl(mrr.schedule_flag,2),1,0,(mrr.resource_hours)))  setup_time_hrs,
                           to_number(null) order_quantity,
                           to_number(null) resource_hours,
                           to_number(null) sup_trx_id,
                           to_number(null) no_of_orders,
                           to_number(null) resource_cost,
                           to_number(null) resource_cost2
                       from msc_resource_requirements mrr,
                            msc_department_resources mdr
                       where  mdr.plan_id = p_plan_id
                            and mdr.plan_id = mrr.plan_id
                            and mdr.sr_instance_id = mrr.sr_instance_id
                            and mdr.organization_id = mrr.organization_id
                            and mdr.department_id = mrr.department_id
                            and mdr.resource_id = mrr.resource_id
                            and mrr.resource_id > 0
                            and ((mdr.plan_id <> con_ods_plan_id
                                    and ((l_constrained_plan=2 and mrr.parent_id = 2) or (l_constrained_plan=1 and mrr.parent_id = 1))
                                    and trunc(decode(l_constrained_plan,1,mrr.start_date,nvl(mrr.end_date,mrr.start_date)))
                                        between l_plan_start_date and l_plan_cutoff_date
                                )
                                or (mdr.plan_id = con_ods_plan_id
                                    and mdr.sr_instance_id = l_sr_instance_id
                                    and (l_refresh_mode = 1
                                         or (l_refresh_mode = 2 and (p_plan_id, mdr.sr_instance_id, mdr.organization_id, mdr.department_id, mdr.resource_id) in
                                               (select number1, number2, number3, number4, number5 from msc_hub_query q where q.query_id = l_res_rn_qid) ) )
                                    and trunc(nvl(mrr.end_date,mrr.start_date)) between l_plan_start_date and l_plan_cutoff_date
                                )
                            )
                       group by
                        mrr.plan_id,
                        p_plan_run_id,
                        mrr.sr_instance_id,
                        mrr.organization_id,
                        mrr.department_id,
                        nvl(mdr.owning_department_id,mrr.department_id),
                        mrr.resource_id,
                        --nvl(mrr.assembly_item_id, -23453),
                        trunc(decode(l_constrained_plan,1,mrr.start_date,nvl(mrr.end_date,mrr.start_date)))


                 union all

                select
                    mra.plan_id plan_id,
                    p_plan_run_id plan_run_id,
                    mra.sr_instance_id sr_instance_id,
                    mra.organization_id organization_id,
                    mra.department_id department_id,
                    mra.department_id owning_department_id,
                    mra.resource_id resource_id,
                    -23453 inventory_item_id,
                    trunc(mra.shift_date) analysis_date,
                    to_number(null) required_hours,
                    sum(mra.capacity_units * decode(mra.from_time,null,1,((decode(sign(mra.to_time-mra.from_time),
                        -1, mra.to_time+86400, mra.to_time) - mra.from_time)/3600))) available_hours,
                    to_number(null) setup_time_hrs,
                    to_number(null) order_quantity,
                    to_number(null) resource_hours,
                    to_number(null) sup_trx_id,
                    to_number(null) no_of_orders,
                    to_number(null) resource_cost,
                    to_number(null) resource_cost2
                from msc_net_resource_avail mra
                where mra.plan_id = p_plan_id
                    and mra.resource_id > 0
                    and ((mra.plan_id <> con_ods_plan_id
                            and mra.parent_id <> -1)
                        or (mra.plan_id = con_ods_plan_id
                            and mra.sr_instance_id = l_sr_instance_id
                            and mra.simulation_set is null
                            and (l_refresh_mode = 1
                            or (l_refresh_mode = 2 and (p_plan_id, mra.sr_instance_id, mra.organization_id, mra.department_id, mra.resource_id) in
                            (select number1, number2, number3, number4, number5 from msc_hub_query q where q.query_id = l_res_rn_qid) ) )
                            and trunc(mra.shift_date) between l_plan_start_date and l_plan_cutoff_date
                        )
                    )
                group by
                    mra.plan_id,
                    mra.sr_instance_id,
                    mra.organization_id,
                    mra.department_id,
                    mra.resource_id,
                    trunc(mra.shift_date)

               union all
                         select
                      mrr.plan_id plan_id,
                      p_plan_run_id plan_run_id,
                      mrr.sr_instance_id sr_instance_id,
                      mrr.organization_id organization_id,
                      mrr.department_id department_id,
                      nvl(mdr.owning_department_id,mrr.department_id) owning_department_id,
                      mrr.resource_id  resource_id,
                      ms.inventory_item_id inventory_item_id,
                      trunc(nvl(mrr.end_date,mrr.start_date)) analysis_date,
                  to_number(null) required_hours,
                  to_number(null) available_hours,
                  to_number(null) setup_time_hrs,
                      sum(nvl(mrr.cummulative_quantity, ms.new_order_quantity)) order_quantity,
                      sum(mrr.resource_hours) resource_hours,
              ms.transaction_id sup_trx_id,
                        1 no_of_orders,
                           to_number(null) resource_cost,
                           to_number(null) resource_cost2
                        from
                            msc_resource_requirements mrr,
                            msc_supplies ms ,
                            msc_department_resources mdr
                        where  mdr.plan_id = p_plan_id
                            and mrr.parent_id = 2
                            and nvl(mrr.schedule_flag,2) = 1
                            and mdr.plan_id = mrr.plan_id
                            and mdr.sr_instance_id = mrr.sr_instance_id
                            and mdr.organization_id = mrr.organization_id
                            and mdr.department_id = mrr.department_id
                            and mdr.resource_id = mrr.resource_id
                            and mrr.plan_id = ms.plan_id
                            and mrr.sr_instance_id = ms.sr_instance_id
                            and mrr.organization_id = ms.organization_id
                            and mrr.supply_id = ms.transaction_id
                            and mrr.resource_id > 0
                            and trunc(nvl(mrr.end_date,mrr.start_date)) between l_plan_start_date and l_plan_cutoff_date
                            and p_plan_id <> con_ods_plan_id
                        group by
                            mrr.plan_id ,
                            p_plan_run_id,
                            mrr.sr_instance_id ,
                            mrr.organization_id ,
                            mrr.department_id ,
                                              nvl(mdr.owning_department_id,mrr.department_id),
                            mrr.resource_id ,
                            ms.inventory_item_id,
                            ms.transaction_id,
                trunc(nvl(mrr.end_date,mrr.start_date)),
                            1

               union all
                select
                    t1.plan_id,
                    p_plan_run_id plan_run_id,
                    t1.sr_instance_id,
                    t1.organization_id,
                    t1.department_id,
                    t1.owning_department_id,
                    t1.resource_id,
                    t1.inventory_item_id,
                    t1.resource_date analysis_date,
                    t1.required_hours,
                    t1.available_hours,
                    t1.setup_hours setup_time_hrs,
                    to_number(null) order_quantity,
                    to_number(null) resource_hours,
            to_number(null) sup_trx_id,
                    to_number(null) no_of_orders,
                    t1.resource_cost,
                    t1.resource_cost * decode(decode(l_plan_type, 6, l_owning_currency_code, t1.currency_code),
                        fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) resource_cost2
                from
                    /* For SNO plan don't filter detail_level.
                    */
                    (select
                        mdrs.plan_id,
                        mdrs.sr_instance_id,
                        mdrs.organization_id,
                        mtp.currency_code,
                        to_number(-23453) inventory_item_id,
                        mdrs.department_id,
                        mdr.owning_department_id,
                        mdrs.resource_id,
                        trunc(mdrs.resource_date) resource_date,
                        mdrs.required_hours,
                        mdrs.available_hours,
                        mdrs.setup_hours,
                        mdrs.resource_cost
                    from
                        msc_bis_res_summary mdrs,
                        msc_department_resources mdr,
                        msc_trading_partners mtp
                    where mdrs.plan_id = p_plan_id
                        and l_plan_type = 6
                        and nvl(mdrs.period_type, 0) = 1
                        and mdrs.sr_instance_id = mtp.sr_instance_id(+)
                        and mdrs.organization_id = mtp.sr_tp_id(+)
                        and mtp.partner_type(+) = 3
                        and mdr.plan_id = mdrs.plan_id
                        and mdr.sr_instance_id = mdrs.sr_instance_id
                        and mdr.organization_id = mdrs.organization_id
                        and mdr.department_id = mdrs.department_id
                        and mdr.resource_id = mdrs.resource_id
                    union all
                    select distinct
                        mbid.plan_id,
                        mbid.sr_instance_id,
                        mbid.organization_id,
                        mtp.currency_code,
                        mbid.inventory_item_id,
                        to_number(-23453) department_id,
                        to_number(-23453) owning_department_id,
                        to_number(-23453) resource_id,
                        d.mfg_week_end_date resource_date,
                        to_number(null) required_hours,
                        to_number(null) available_hours,
                        to_number(null) setup_hours,
                        mbid.production_cost
                    from
                        msc_bis_inv_detail mbid,
                        msc_trading_partners mtp,
                        msc_phub_dates_mv d
                    where mbid.plan_id = p_plan_id
                        and nvl(mbid.detail_level, 0) = 1
                        and nvl(mbid.period_type, 0) = 1
                        and l_plan_type in (1,101,102,103,105)
                        and mbid.sr_instance_id = mtp.sr_instance_id(+)
                        and mbid.organization_id = mtp.sr_tp_id(+)
                        and mtp.partner_type(+) = 3
                        and trunc(mbid.detail_date) between d.mfg_week_start_date and d.mfg_week_end_date
                    ) t1,
                    msc_currency_conv_mv mcc
                where mcc.to_currency(+) = fnd_profile.value('MSC_HUB_CUR_CODE_RPT')
                    and mcc.from_currency(+) = decode(l_plan_type, 6, l_owning_currency_code, t1.currency_code)
                    and mcc.calendar_date(+) = t1.resource_date
                    and p_plan_id <> con_ods_plan_id

             )
     group by
                plan_id,
                plan_run_id,
                sr_instance_id,
                organization_id,
                department_id,
                nvl(owning_department_id,-23453),
                resource_id,
                inventory_item_id,
                analysis_date
             ;

    l_rowcount1 := l_rowcount1 + sql%rowcount;
    msc_phub_util.log('msc_resources_f, insert='||sql%rowcount||', l_rowcount1='||l_rowcount1);
    commit;

    -- msc_resources_cum_f
    insert into msc_resources_cum_f (
        plan_id,
        plan_run_id,
        sr_instance_id,
        organization_id,
        department_id,
        resource_id,
        inventory_item_id,
        analysis_date,
        aggr_type,
        resource_group,
        cum_net_resource_avail,
        created_by, creation_date,
        last_update_date, last_updated_by, last_update_login,
        program_id, program_login_id,
        program_application_id, request_id)
    select
        f.plan_id,
        f.plan_run_id,
        f.sr_instance_id,
        f.organization_id,
        f.department_id,
        f.resource_id,
        f.inventory_item_id,
        d.date1 analysis_date,
        to_number(0) aggr_type,
        '-23453' resource_group,
        sum(nvl(f.available_hours, 0) - nvl(f.required_hours, 0)) cum_net_resource_avail,
        fnd_global.user_id, sysdate,
        sysdate, fnd_global.user_id, fnd_global.login_id,
        fnd_global.conc_program_id, fnd_global.conc_login_id,
        fnd_global.prog_appl_id, fnd_global.conc_request_id
    from
        msc_resources_f f,
        msc_hub_query d
    where f.plan_id=p_plan_id
        and f.plan_run_id=p_plan_run_id
        and f.aggr_type=0
        and d.query_id=l_qid_last_date
        and d.date1 >= f.analysis_date
        and ((f.plan_id <> con_ods_plan_id)
            or (f.plan_id = con_ods_plan_id
                and f.sr_instance_id = l_sr_instance_id
                and (l_refresh_mode = 1
                or (l_refresh_mode = 2 and (p_plan_id, f.sr_instance_id, f.organization_id, f.department_id, f.resource_id) in
                (select number1, number2, number3, number4, number5 from msc_hub_query q where q.query_id = l_res_rn_qid)))
        )
    )
    group by
        f.plan_id,
        f.plan_run_id,
        f.sr_instance_id,
        f.organization_id,
        f.department_id,
        f.resource_id,
        f.inventory_item_id,
        d.date1;

    l_rowcount2 := l_rowcount2 + sql%rowcount;
    msc_phub_util.log('msc_resources_cum_f, insert='||sql%rowcount||', l_rowcount2='||l_rowcount2);
    commit;

    if (l_rowcount1 > 0) then
        summarize_resources_f(errbuf, retcode, p_plan_id, p_plan_run_id);
    end if;

    if (l_rowcount2 > 0) then
        summarize_resources_cum_f(errbuf, retcode, p_plan_id, p_plan_run_id);
    end if;

    msc_phub_util.log('msc_resource_pkg.populate_details: complete');

EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
            errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_DUPLICATE_DATA')||SQLCODE||' -ERROR- '||sqlerrm;
            retcode := 2;
      WHEN OTHERS THEN
            errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_POPULATE_ERROR')||SQLCODE||' -ERROR- '||sqlerrm;
            retcode := 2;
END populate_details;


    procedure summarize_resources_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
    begin
        msc_phub_util.log('msc_resource_pkg.summarize_resources_f');
        retcode := 0;
        errbuf := '';

        delete from msc_resources_f
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id and aggr_type>0;
        msc_phub_util.log('msc_resource_pkg.summarize_resources_f, delete='||sql%rowcount);
        commit;

        -- level 1
        insert into msc_resources_f (
            plan_id, plan_run_id,
            sr_instance_id, organization_id,
            department_id, owning_department_id, resource_id,
            inventory_item_id, analysis_date,
            aggr_type, resource_group,
            required_hours,
            available_hours,
            setup_time_hrs,
            order_quantity,
            resource_hours,
            no_of_orders,
            resource_cost,
            resource_cost2,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- department (81)
        select
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            f.department_id,
            to_number(-23453) owning_department_id,
            to_number(-23453) resource_id,
            f.inventory_item_id, f.analysis_date,
            to_number(81) aggr_type,
            '-23453' resource_group,
            sum(f.required_hours),
            sum(f.available_hours),
            sum(f.setup_time_hrs),
            sum(f.order_quantity),
            sum(f.resource_hours),
            sum(f.no_of_orders),
            sum(f.resource_cost),
            sum(f.resource_cost2),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_resources_f f
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
        group by
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            f.department_id,
            f.inventory_item_id, f.analysis_date
        union all
        -- resource_group (82)
        select
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            to_number(-23453) department_id,
            to_number(-23453) owning_department_id,
            to_number(-23453) resource_id,
            f.inventory_item_id, f.analysis_date,
            to_number(82) aggr_type,
            nvl(r.resource_group_name, '-23453') resource_group,
            sum(f.required_hours),
            sum(f.available_hours),
            sum(f.setup_time_hrs),
            sum(f.order_quantity),
            sum(f.resource_hours),
            sum(f.no_of_orders),
            sum(f.resource_cost),
            sum(f.resource_cost2),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_resources_f f,
            msc_department_resources r
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
            and r.plan_id(+) = -1
            and r.sr_instance_id(+) = f.sr_instance_id
            and r.organization_id(+) = f.organization_id
            and r.department_id(+) = f.department_id
            and r.resource_id(+) = f.resource_id
        group by
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            f.inventory_item_id, f.analysis_date,
            r.resource_group_name;

        msc_phub_util.log('msc_resource_pkg.summarize_resources_f, level1='||sql%rowcount);
        commit;

        -- level 2
        insert into msc_resources_f (
            plan_id, plan_run_id,
            sr_instance_id, organization_id,
            department_id, owning_department_id, resource_id,
            inventory_item_id, analysis_date,
            aggr_type, resource_group,
            required_hours,
            available_hours,
            setup_time_hrs,
            order_quantity,
            resource_hours,
            no_of_orders,
            resource_cost,
            resource_cost2,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- resource_group-mfg_period (1038)
        select
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            f.department_id, f.owning_department_id, f.resource_id,
            f.inventory_item_id, d.mfg_period_start_date,
            to_number(1038) aggr_type,
            f.resource_group,
            sum(f.required_hours),
            sum(f.available_hours),
            sum(f.setup_time_hrs),
            sum(f.order_quantity),
            sum(f.resource_hours),
            sum(f.no_of_orders),
            sum(f.resource_cost),
            sum(f.resource_cost2),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_resources_f f,
            msc_phub_dates_mv d
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type = 82
            and f.analysis_date = d.calendar_date
            and d.mfg_period_start_date is not null
        group by
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            f.department_id, f.owning_department_id, f.resource_id,
            f.inventory_item_id, d.mfg_period_start_date,
            f.resource_group
        union all
        -- resource_group-fiscal_period (1039)
        select
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            f.department_id, f.owning_department_id, f.resource_id,
            f.inventory_item_id, d.fis_period_start_date,
            to_number(1039) aggr_type,
            f.resource_group,
            sum(f.required_hours),
            sum(f.available_hours),
            sum(f.setup_time_hrs),
            sum(f.order_quantity),
            sum(f.resource_hours),
            sum(f.no_of_orders),
            sum(f.resource_cost),
            sum(f.resource_cost2),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_resources_f f,
            msc_phub_dates_mv d
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type = 82
            and f.analysis_date = d.calendar_date
            and d.fis_period_start_date is not null
        group by
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            f.department_id, f.owning_department_id, f.resource_id,
            f.inventory_item_id, d.fis_period_start_date,
            f.resource_group;

        msc_phub_util.log('msc_resource_pkg.summarize_resources_f, level2='||sql%rowcount);
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_resource_pkg.summarize_demands_f: '||sqlerrm;
            raise;

    end summarize_resources_f;

    procedure summarize_resources_cum_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
    begin
        msc_phub_util.log('msc_resource_pkg.summarize_resources_cum_f');
        retcode := 0;
        errbuf := '';

        delete from msc_resources_cum_f
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id and aggr_type>0;
        msc_phub_util.log('msc_resource_pkg.summarize_resources_cum_f, delete='||sql%rowcount);
        commit;

        -- level 1
        insert into msc_resources_cum_f (
            plan_id, plan_run_id,
            sr_instance_id, organization_id,
            department_id, resource_id,
            inventory_item_id, analysis_date,
            aggr_type, resource_group,
            cum_net_resource_avail,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- department (81)
        select
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            f.department_id,
            to_number(-23453) resource_id,
            f.inventory_item_id, f.analysis_date,
            to_number(81) aggr_type,
            '-23453' resource_group,
            sum(f.cum_net_resource_avail),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_resources_cum_f f
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
        group by
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            f.department_id,
            f.inventory_item_id, f.analysis_date
        union all
        -- resource_group (82)
        select
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            to_number(-23453) department_id,
            to_number(-23453) resource_id,
            f.inventory_item_id, f.analysis_date,
            to_number(82) aggr_type,
            nvl(r.resource_group_name, '-23453') resource_group,
            sum(f.cum_net_resource_avail),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_resources_cum_f f,
            msc_department_resources r
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
            and r.plan_id(+) = -1
            and r.sr_instance_id(+) = f.sr_instance_id
            and r.organization_id(+) = f.organization_id
            and r.department_id(+) = f.department_id
            and r.resource_id(+) = f.resource_id
        group by
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            f.inventory_item_id, f.analysis_date,
            r.resource_group_name;

        msc_phub_util.log('msc_resource_pkg.summarize_resources_cum_f, level1='||sql%rowcount);
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_resource_pkg.summarize_resources_cum_f: '||sqlerrm;
            raise;
    end summarize_resources_cum_f;

    procedure export_resources_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_resource_pkg.export_resources_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_resources_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_resources_f('||
            '     st_transaction_id,'||
            '     error_code,'||
            '     sr_instance_id,'||
            '     organization_id,'||
            '     department_id,'||
            '     resource_id,'||
            '     inventory_item_id,'||
            '     organization_code,'||
            '     department_code,'||
            '     department_class,'||
            '     resource_code,'||
            '     resource_group_name,'||
            '     item_name,'||
            '     analysis_date,'||
            '     available_hours,'||
            '     required_hours,'||
            '     setup_time_hrs,'||
            '     order_quantity,'||
            '     resource_hours,'||
            '     no_of_orders,'||
            '     resource_cost,'||
            '     resource_cost2,'||
            '     created_by, creation_date,'||
            '     last_updated_by, last_update_date, last_update_login'||
            ' )'||
            ' select'||
            '     :p_st_transaction_id,'||
            '     0,'||
            '     f.sr_instance_id,'||
            '     f.organization_id,'||
            '     f.department_id,'||
            '     f.resource_id,'||
            '     f.inventory_item_id,'||
            '     mtp.organization_code,'||
            '     mdr.department_code,'||
            '     mdr.department_class,'||
            '     mdr.resource_code,'||
            '     mdr.resource_group_name,'||
            '     mi.item_name,'||
            '     f.analysis_date,'||
            '     f.available_hours,'||
            '     f.required_hours,'||
            '     f.setup_time_hrs,'||
            '     f.order_quantity,'||
            '     f.resource_hours,'||
            '     f.no_of_orders,'||
            '     f.resource_cost,'||
            '     f.resource_cost2,'||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_resources_f'||l_suffix||' f,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,'||
            '     '||l_apps_schema||'.msc_items'||l_suffix||' mi,'||
            '     '||l_apps_schema||'.msc_department_resources'||l_suffix||' mdr'||
            ' where f.plan_id=:p_plan_id'||
            '     and f.plan_run_id=:p_plan_run_id'||
            '     and f.aggr_type=0'||
            '     and mtp.partner_type(+)=3'||
            '     and mtp.sr_instance_id(+)=f.sr_instance_id'||
            '     and mtp.sr_tp_id(+)=f.organization_id'||
            '     and mi.inventory_item_id(+)=f.inventory_item_id'||
            '     and mdr.plan_id(+)=-1'||
            '     and mdr.department_id(+)=f.department_id'||
            '     and mdr.resource_id(+)=f.resource_id'||
            '     and mdr.sr_instance_id(+)=f.sr_instance_id'||
            '     and mdr.organization_id(+)=f.organization_id';

        execute immediate l_sql using p_st_transaction_id, p_plan_id, p_plan_run_id;
        commit;
        msc_phub_util.log('msc_resource_pkg.export_resources_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_resource_pkg.export_resources_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end export_resources_f;

    procedure export_resources_cum_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_resource_pkg.export_resources_cum_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_resources_cum_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_resources_cum_f('||
            '     st_transaction_id,'||
            '     error_code,'||
            '     sr_instance_id,'||
            '     organization_id,'||
            '     department_id,'||
            '     resource_id,'||
            '     inventory_item_id,'||
            '     organization_code,'||
            '     department_code,'||
            '     department_class,'||
            '     resource_code,'||
            '     resource_group_name,'||
            '     item_name,'||
            '     analysis_date,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     cum_net_resource_avail,';
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
            '     f.department_id,'||
            '     f.resource_id,'||
            '     f.inventory_item_id,'||
            '     mtp.organization_code,'||
            '     mdr.department_code,'||
            '     mdr.department_class,'||
            '     mdr.resource_code,'||
            '     mdr.resource_group_name,'||
            '     mi.item_name,'||
            '     f.analysis_date,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     f.cum_net_resource_avail,';
        end if;
        l_sql := l_sql||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_resources_cum_f'||l_suffix||' f,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,'||
            '     '||l_apps_schema||'.msc_items'||l_suffix||' mi,'||
            '     '||l_apps_schema||'.msc_department_resources'||l_suffix||' mdr'||
            ' where f.plan_id=:p_plan_id'||
            '     and f.plan_run_id=:p_plan_run_id'||
            '     and f.aggr_type=0'||
            '     and mtp.partner_type(+)=3'||
            '     and mtp.sr_instance_id(+)=f.sr_instance_id'||
            '     and mtp.sr_tp_id(+)=f.organization_id'||
            '     and mi.inventory_item_id(+)=f.inventory_item_id'||
            '     and mdr.plan_id(+)=-1'||
            '     and mdr.department_id(+)=f.department_id'||
            '     and mdr.resource_id(+)=f.resource_id'||
            '     and mdr.sr_instance_id(+)=f.sr_instance_id'||
            '     and mdr.organization_id(+)=f.organization_id';

        execute immediate l_sql using p_st_transaction_id, p_plan_id, p_plan_run_id;
        commit;
        msc_phub_util.log('msc_resource_pkg.export_resources_cum_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_resource_pkg.export_resources_cum_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end export_resources_cum_f;

    procedure import_resources_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_resources_f';
        l_fact_table varchar2(30) := 'msc_resources_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_resource_pkg.import_resources_f');
        retcode := 0;
        errbuf := null;

        l_result := l_result + msc_phub_util.prepare_staging_dates(
            l_staging_table, 'analysis_date', p_st_transaction_id,
            p_upload_mode, p_overwrite_after_date,
            p_plan_start_date, p_plan_cutoff_date);

        l_result := l_result + msc_phub_util.prepare_fact_dates(
            l_fact_table, 1, 'analysis_date', p_plan_id, p_plan_run_id,
            p_upload_mode, p_overwrite_after_date);

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'sr_instance_id', 'organization_id', 'organization_code');

        l_result := l_result + msc_phub_util.decode_item_key(
            l_staging_table, p_st_transaction_id, 'inventory_item_id', 'item_name');

        l_result := l_result + msc_phub_util.decode_resource_key(
            l_staging_table, p_st_transaction_id);

        msc_phub_util.log('msc_resource_pkg.import_resources_f: insert into msc_resources_f');
        insert into msc_resources_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            department_id,
            resource_id,
            inventory_item_id,
            analysis_date,
            available_hours,
            required_hours,
            setup_time_hrs,
            order_quantity,
            resource_hours,
            no_of_orders,
            resource_cost,
            resource_cost2,
            owning_department_id, aggr_type, resource_group,
            created_by, creation_date,
            last_updated_by, last_update_date, last_update_login
        )
        select
            p_plan_id,
            p_plan_run_id,
            nvl(sr_instance_id, -23453),
            nvl(organization_id, -23453),
            nvl(department_id, -23453),
            nvl(resource_id, -23453),
            nvl(inventory_item_id, -23453),
            analysis_date,
            available_hours,
            required_hours,
            setup_time_hrs,
            order_quantity,
            resource_hours,
            no_of_orders,
            resource_cost,
            resource_cost2,
            -23453, 0, '-23453',
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_resources_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_resource_pkg.import_resources_f: inserted='||sql%rowcount);
        commit;

        summarize_resources_f(errbuf, retcode, p_plan_id, p_plan_run_id);

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_resource_pkg.import_resources_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_resource_pkg.import_resources_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end import_resources_f;

    procedure import_resources_cum_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_resources_cum_f';
        l_fact_table varchar2(30) := 'msc_resources_cum_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_resource_pkg.import_resources_cum_f');
        retcode := 0;
        errbuf := null;

        l_result := l_result + msc_phub_util.prepare_staging_dates(
            l_staging_table, 'analysis_date', p_st_transaction_id,
            p_upload_mode, p_overwrite_after_date,
            p_plan_start_date, p_plan_cutoff_date);

        l_result := l_result + msc_phub_util.prepare_fact_dates(
            l_fact_table, 1, 'analysis_date', p_plan_id, p_plan_run_id,
            p_upload_mode, p_overwrite_after_date);

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'sr_instance_id', 'organization_id', 'organization_code');

        l_result := l_result + msc_phub_util.decode_item_key(
            l_staging_table, p_st_transaction_id, 'inventory_item_id', 'item_name');

        l_result := l_result + msc_phub_util.decode_resource_key(
            l_staging_table, p_st_transaction_id);

        msc_phub_util.log('msc_resource_pkg.import_resources_cum_f: insert into msc_resources_cum_f');
        insert into msc_resources_cum_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            department_id,
            resource_id,
            inventory_item_id,
            analysis_date,
            cum_net_resource_avail,
            aggr_type, resource_group,
            created_by, creation_date,
            last_updated_by, last_update_date, last_update_login
        )
        select
            p_plan_id,
            p_plan_run_id,
            nvl(sr_instance_id, -23453),
            nvl(organization_id, -23453),
            nvl(department_id, -23453),
            nvl(resource_id, -23453),
            nvl(inventory_item_id, -23453),
            analysis_date,
            cum_net_resource_avail,
            0, '-23453',
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_resources_cum_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_resource_pkg.import_resources_cum_f: inserted='||sql%rowcount);
        commit;

        summarize_resources_cum_f(errbuf, retcode, p_plan_id, p_plan_run_id);

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_resource_pkg.import_resources_cum_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_resource_pkg.import_resources_cum_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end import_resources_cum_f;

end msc_resource_pkg;

/
