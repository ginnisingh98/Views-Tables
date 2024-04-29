--------------------------------------------------------
--  DDL for Package Body MSC_DEMANTRA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_DEMANTRA_PKG" as
/* $Header: MSCHBDMB.pls 120.14.12010000.15 2010/03/03 23:47:19 wexia ship $ */

    procedure populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_api_name varchar2(100) := 'msc_demand_f_pkg.populate_details';
        l_owning_currency_code varchar2(20) := msc_phub_util.get_owning_currency_code(p_plan_run_id);
    begin
        retcode := 0;
        errbuf := '';

        --dbms_output.put_line(l_api_name||'('||p_plan_id||', '||p_plan_run_id||')');
        insert into msc_demantra_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            customer_id,
            customer_site_id,
            region_id,
            inventory_item_id,
            demand_class,
            owning_org_id,
            owning_inst_id,
            start_date,
            aggr_type, category_set_id, sr_category_id,
            consensus_fcst,
            consensus_fcst_value,
            consensus_fcst_value2,
            consensus_fcst_cum,
            priority,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        select
            t.scenario_id plan_id,
            p_plan_run_id,
            decode(t.organization_id, -1, -23453, t.sr_instance_id) sr_instance_id, --wei: sync sr_instance_id with organization_id
            decode(t.organization_id, -1, -23453, t.organization_id) organization_id,
            t.customer_id,
            t.customer_site_id,
            mpc.region_id,
            t.inventory_item_id,
            t.demand_class,

            decode(t.organization_id,
                -1, msc_hub_calendar.get_item_org(-1, t.inventory_item_id, t.sr_instance_id),
                t.organization_id) owning_org_id,

            t.sr_instance_id owning_inst_id,

            t.start_date,
            to_number(0) aggr_type,
            to_number(-23453) category_set_id,
            to_number(-23453) sr_category_id,
            t.consensus_fcst,
            t.consensus_fcst*t.price consensus_fcst_value,
            t.consensus_fcst*t.price * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))
                consensus_fcst_value2,
            t.consensus_fcst_cum,
            t.priority,
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from (
            select
                k.scenario_id,
                k.sr_instance_id,
                k.organization_id,
                k.customer_id,
                k.customer_site_id,
                k.zone_id,
                k.inventory_item_id,
                k.demand_class,
                k.start_date,
                nvl(f.currency_code, l_owning_currency_code) currency_code,
                nvl(k.list_price,0)*(1- nvl(k.average_discount,0)/100) price,
                f.consensus_fcst,
                sum(nvl(f.consensus_fcst, 0)) over(partition by
                    k.scenario_id, k.sr_instance_id, k.organization_id,
                    k.customer_id, k.customer_site_id, k.zone_id,
                    k.inventory_item_id, k.demand_class
                    order by k.start_date) consensus_fcst_cum,
                f.priority
            from
                (select distinct
                    k1.scenario_id,
                    k1.sr_instance_id,
                    k1.organization_id,
                    k1.customer_id,
                    k1.customer_site_id,
                    k1.zone_id,
                    k1.inventory_item_id,
                    k1.demand_class,
                    k1.list_price,
                    k1.average_discount,
                    k2.start_date
                from
                    (select distinct
                        k0.scenario_id,
                        k0.sr_instance_id,
                        k0.organization_id,
                        k0.customer_id,
                        k0.customer_site_id,
                        k0.zone_id,
                        k0.inventory_item_id,
                        k0.demand_class,
                        i.list_price,
                        i.average_discount
                    from msd_dem_scn_entries_v k0, msc_system_items i
                    where i.plan_id=-1
                        and i.sr_instance_id=k0.sr_instance_id
                        and i.organization_id=k0.organization_id
                        and i.inventory_item_id=k0.inventory_item_id
                        and k0.scenario_id=p_plan_id
                    ) k1,

                    (select distinct start_date
                    from msd_dem_scn_entries_v
                    where scenario_id=p_plan_id) k2
                ) k,
                msd_dem_scn_entries_v f
            where k.scenario_id = f.scenario_id(+)
                and k.sr_instance_id = f.sr_instance_id(+)
                and k.organization_id = f.organization_id(+)
                and k.customer_id = f.customer_id(+)
                and k.customer_site_id = f.customer_site_id(+)
                and k.zone_id = f.zone_id(+)
                and k.inventory_item_id = f.inventory_item_id(+)
                and k.demand_class = f.demand_class(+)
                and k.start_date = f.start_date(+)) t,
            msc_currency_conv_mv mcc,
            msc_phub_customers_mv mpc
        where mcc.to_currency(+) = fnd_profile.value('MSC_HUB_CUR_CODE_RPT')
            and mcc.from_currency(+) = t.currency_code
            and mcc.calendar_date(+) = t.start_date
            and mpc.customer_id = t.customer_id
            and mpc.customer_site_id = t.customer_site_id
            and mpc.region_id = decode(t.customer_id, -23453, t.zone_id, mpc.region_id);

        commit;
        --dbms_output.put_line('rowcount='||sql%rowcount);

        summarize_demantra_f(errbuf, retcode, p_plan_id, p_plan_run_id);
        msc_phub_util.log('msc_demantra_pkg.populate_details: complete');

    exception
        when dup_val_on_index then
            --dbms_output.put_line(to_char(SQLCODE) || ':' || sqlerrm);
            errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_DUPLICATE_DATA')||
                SQLCODE||' -ERROR- '||sqlerrm;
            retcode := 2;

            if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_unexpected, l_api_name, to_char(SQLCODE)||':'||sqlerrm);
            end if;


        when others then
            --dbms_output.put_line(to_char(SQLCODE) || ':' || sqlerrm);
            errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_POPULATE_ERROR')||
                SQLCODE||' -ERROR- '||sqlerrm;
            retcode := 2;

            if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_unexpected, l_api_name, to_char(SQLCODE)||':'||sqlerrm);
            end if;

    end populate_details;

    procedure populate_ods(errbuf out nocopy varchar2, retcode out nocopy varchar2)
    is
    begin
        msc_phub_util.log('msc_demantra_pkg.populate_ods');
        retcode := 0;
        errbuf := '';

        delete from msc_demantra_ods_f;
        commit;

        msc_phub_util.log('msc_demantra_pkg.populate_ods: insert');
        insert into msc_demantra_ods_f (
            sr_instance_id,
            organization_id,
            inventory_item_id,
            customer_id,
            customer_site_id,
            region_id,
            demand_class,
            end_date,
            sales_fcst,
            sales_fcst_value,
            sales_fcst_value2,
            sales_fcst_cum,
            mktg_fcst,
            mktg_fcst_value,
            mktg_fcst_value2,
            mktg_fcst_cum,
            budget,
            budget_cum,
            budget2,
            budget2_cum,
            booking_fcst,
            booking_fcst_value,
            booking_fcst_value2,
            booking_fcst_cum,
            shipment_fcst,
            shipment_fcst_value,
            shipment_fcst_value2,
            shipment_fcst_cum,
            projected_backlog,
            projected_backlog_value,
            projected_backlog_value2,
            actual_backlog,
            actual_backlog_value,
            actual_backlog_value2,
            booking_history,
            booking_history_value,
            booking_history_value2,
            booking_history_cum,
            shipment_history,
            shipment_history_value,
            shipment_history_value2,
            shipment_history_cum,
            production_history,
            consen_fcst_accrcy_mape_4week,
            consen_fcst_accrcy_mape_8week,
            consen_fcst_accrcy_mape_13week,
            returns_history,
            annual_plan_value,
            annual_plan_value2,
            financial_fcst_value,
            financial_fcst_value2,
            final_fcst,
            final_fcst_value,
            final_fcst_value2,
            final_fcst_cum,
            inventory_history,
            inventory_history_value,
            inventory_history_value2,
            booking_history_rd,
            booking_history_rd_value,
            booking_history_rd_value2,
            created_by, creation_date,
            last_updated_by, last_update_date, last_update_login)
        select
            t.sr_instance_id,
            t.organization_id,
            t.inventory_item_id,
            t.customer_id,
            t.customer_site_id,
            t.region_id,
            t.demand_class,
            t.end_date,

            t.sales_fcst,
            t.sales_fcst * t.price sales_fcst_value,
            t.sales_fcst * t.price * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) sales_fcst_value2,
            sum(t.sales_fcst) over(partition by
                t.sr_instance_id, t.organization_id, t.inventory_item_id,
                t.customer_id, t.customer_site_id, t.region_id,
                t.demand_class order by t.end_date) sales_fcst_cum,

            t.mktg_fcst,
            t.mktg_fcst * t.price mktg_fcst_value,
            t.mktg_fcst * t.price * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) mktg_fcst_value2,
            sum(t.mktg_fcst) over(partition by
                t.sr_instance_id, t.organization_id, t.inventory_item_id,
                t.customer_id, t.customer_site_id, t.region_id,
                t.demand_class order by t.end_date) mktg_fcst_cum,

            t.budget,
            sum(t.budget) over(partition by
                t.sr_instance_id, t.organization_id, t.inventory_item_id,
                t.customer_id, t.customer_site_id, t.region_id,
                t.demand_class order by t.end_date) budget_cum,

            t.budget * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) budget2,
            sum(t.budget * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0))) over(partition by
                t.sr_instance_id, t.organization_id, t.inventory_item_id,
                t.customer_id, t.customer_site_id, t.region_id,
                t.demand_class order by t.end_date) budget2_cum,

            t.booking_fcst,
            t.booking_fcst * t.price booking_fcst_value,
            t.booking_fcst * t.price * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) booking_fcst_value2,
            sum(t.booking_fcst) over(partition by
                t.sr_instance_id, t.organization_id, t.inventory_item_id,
                t.customer_id, t.customer_site_id, t.region_id,
                t.demand_class order by t.end_date) booking_fcst_cum,

            t.shipment_fcst,
            t.shipment_fcst * t.price shipment_fcst_value,
            t.shipment_fcst * t.price * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) shipment_fcst_value2,
            sum(t.shipment_fcst) over(partition by
                t.sr_instance_id, t.organization_id, t.inventory_item_id,
                t.customer_id, t.customer_site_id, t.region_id,
                t.demand_class order by t.end_date) shipment_fcst_cum,

            t.projected_backlog,
            t.projected_backlog * t.price projected_backlog_value,
            t.projected_backlog * t.price * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) projected_backlog_value2,

            t.actual_backlog,
            t.actual_backlog * t.price actual_backlog_value,
            t.actual_backlog * t.price * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) actual_backlog_value2,

            t.booking_history,
            t.booking_history * t.price booking_history_value,
            t.booking_history * t.price * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) booking_history_value2,
            sum(t.booking_history) over(partition by
                t.sr_instance_id, t.organization_id, t.inventory_item_id,
                t.customer_id, t.customer_site_id, t.region_id,
                t.demand_class order by t.end_date) booking_history_cum,

            t.shipment_history,
            t.shipment_history * t.price shipment_history_value,
            t.shipment_history * t.price * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) shipment_history_value2,
            sum(t.shipment_history) over(partition by
                t.sr_instance_id, t.organization_id, t.inventory_item_id,
                t.customer_id, t.customer_site_id, t.region_id,
                t.demand_class order by t.end_date) shipment_history_cum,

            t.production_history,
            t.consen_fcst_accrcy_mape_4week,
            t.consen_fcst_accrcy_mape_8week,
            t.consen_fcst_accrcy_mape_13week,

            t.returns_history,

            t.annual_plan_value,
            t.annual_plan_value * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) annual_plan_value2,

            t.financial_fcst_value,
            t.financial_fcst_value * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) financial_fcst_value2,

            t.final_fcst,
            t.final_fcst * t.price final_fcst_value,
            t.final_fcst * t.price * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) final_fcst_value2,
            sum(t.final_fcst) over(partition by
                t.sr_instance_id, t.organization_id, t.inventory_item_id,
                t.customer_id, t.customer_site_id, t.region_id,
                t.demand_class order by t.end_date) final_fcst_cum,

            t.inventory_history,
            t.inventory_history * t.price inventory_history_value,
            t.inventory_history * t.price * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) inventory_history_value2,

            t.booking_history_rd,
            t.booking_history_rd * t.price booking_history_rd_value,
            t.booking_history_rd * t.price * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate, 0)) booking_history_rd_value2,

            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from
            (select
                mtp.sr_instance_id,
                nvl(mtp.sr_tp_id, -23453) organization_id,
                msi.inventory_item_id,
                nvl(mpc.customer_id, -23453) customer_id,
                nvl(mpc.customer_site_id, -23453) customer_site_id,
                nvl(mpc.region_id, -23453) region_id,
                mdc.demand_class,
                bov.sdate end_date,
                bov.sales_fcst sales_fcst,
                bov.mktg_fcst mktg_fcst,
                bov.budget budget,
                bov.fcst_booking booking_fcst,
                bov.fcst_shipment shipment_fcst,
                decode(bov.record_type, 1, 0, lag(nvl(bov.total_backlog, 0)) over(partition by
                    mtp.sr_instance_id, mtp.sr_tp_id, msi.inventory_item_id,
                    mpc.customer_id, mpc.customer_site_id, mpc.region_id,
                    bov.level2 order by bov.sdate) +
                    nvl(bov.fcst_booking, 0) - nvl(bov.fcst_shipment, 0)) projected_backlog,
                bov.total_backlog actual_backlog,
                bov.ebs_bh_book_qty_bd booking_history,
                bov.ebs_sh_ship_qty_sd shipment_history,
                bov.actual_prod production_history,
                bov.week4_abs_pct_err consen_fcst_accrcy_mape_4week,
                bov.week8_abs_pct_err consen_fcst_accrcy_mape_8week,
                bov.week13_abs_pct_err consen_fcst_accrcy_mape_13week,
                bov.ebs_return_history returns_history,
                bov.fcst_hyp_annual_plan annual_plan_value,
                bov.fcst_hyp_financial financial_fcst_value,
                bov.c_pred final_fcst,
                bov.actual_on_hand inventory_history,
                bov.ebs_bh_book_qty_rd booking_history_rd,
                nvl(msi.list_price, 0) * (1-(nvl(msi.average_discount, 0)/100)) price,
                mtp.currency_code
            from
                msd_dem_bieo_obi_mv_syn bov,
                msc_system_items msi,
                msc_phub_customers_mv mpc,
                msc_trading_partners mtp,
                (select sr_instance_id, meaning, demand_class from msc_demand_classes
                    union all select instance_id, '0', '-23453' from msc_apps_instances) mdc
            where bov.level3=mtp.organization_code(+)
                and mtp.partner_type(+)=3
                and msi.plan_id(+)=-1
                and bov.dkey_item=msi.inventory_item_id(+)
                and bov.dkey_site=mpc.customer_site_id(+)
                and nvl(bov.level2, '-23453')=mdc.meaning(+)
                and msi.sr_instance_id=mtp.sr_instance_id
                and msi.organization_id=mtp.sr_tp_id
                and mdc.sr_instance_id=mtp.sr_instance_id) t,
            msc_currency_conv_mv mcc
        where mcc.to_currency(+)=fnd_profile.value('MSC_HUB_CUR_CODE_RPT')
            and mcc.from_currency(+)=nvl(t.currency_code, 'XXX')
            and mcc.calendar_date(+)=t.end_date;

        commit;

        msc_phub_util.log('msc_demantra_pkg.populate_ods: complete');
    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_demantra_pkg.populate_ods: '||sqlerrm;
            end if;
            msc_phub_util.log(errbuf);
    end populate_ods;

    procedure summarize_demantra_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_category_set_id1 number := fnd_profile.value('MSC_HUB_CAT_SET_ID_1');
    begin
        msc_phub_util.log('msc_demantra_pkg.summarize_demantra_f');
        retcode := 0;
        errbuf := '';

        delete from msc_demantra_f
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id and aggr_type>0;
        msc_phub_util.log('msc_demantra_pkg.summarize_demantra_f, delete='||sql%rowcount);
        commit;

        -- level 1
        insert into msc_demantra_f (
            plan_id, plan_run_id,
            sr_instance_id, organization_id, owning_org_id, owning_inst_id,
            inventory_item_id,
            customer_id, customer_site_id, region_id,
            demand_class, start_date,
            aggr_type, category_set_id, sr_category_id,
            consensus_fcst,
            consensus_fcst_value,
            consensus_fcst_value2,
            consensus_fcst_cum,
            priority,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category (42, 43, 44)
        select
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id, f.owning_org_id, f.owning_inst_id,
            to_number(-23453) inventory_item_id,
            f.customer_id, f.customer_site_id, f.region_id,
            f.demand_class, f.start_date,
            to_number(42) aggr_type,
            l_category_set_id1 category_set_id,
            nvl(q.sr_category_id, -23453),
            sum(f.consensus_fcst),
            sum(f.consensus_fcst_value),
            sum(f.consensus_fcst_value2),
            sum(f.consensus_fcst_cum),
            avg(f.priority),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_demantra_f f,
            msc_phub_item_categories_mv q
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
            and f.owning_inst_id=q.sr_instance_id(+)
            and f.owning_org_id=q.organization_id(+)
            and f.inventory_item_id=q.inventory_item_id(+)
            and q.category_set_id(+)=l_category_set_id1
        group by
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id, f.owning_org_id, f.owning_inst_id,
            f.customer_id, f.customer_site_id, f.region_id,
            f.demand_class, f.start_date,
            nvl(q.sr_category_id, -23453);

        msc_phub_util.log('msc_demantra_pkg.summarize_demantra_f, level1='||sql%rowcount);
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_demantra_pkg.summarize_demantra_f: '||sqlerrm;
            raise;
    end summarize_demantra_f;

    procedure export_demantra_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_demantra_pkg.export_demantra_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_demantra_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_demantra_f('||
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
            '     zone,'||
            '     demand_class,'||
            '     start_date,'||
            '     consensus_fcst,'||
            '     consensus_fcst_value,'||
            '     consensus_fcst_value2,'||
            '     consensus_fcst_cum,'||
            '     priority,'||
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
            '     decode(f.region_id, -23453, null, cmv.zone),'||
            '     f.demand_class,'||
            '     f.start_date,'||
            '     f.consensus_fcst,'||
            '     f.consensus_fcst_value,'||
            '     f.consensus_fcst_value2,'||
            '     f.consensus_fcst_cum,'||
            '     f.priority,'||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_demantra_f'||l_suffix||' f,'||
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
        msc_phub_util.log('msc_demantra_pkg.export_demantra_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_demantra_pkg.export_demantra_f: '||sqlerrm;
            raise;
    end export_demantra_f;

    procedure export_demantra_ods_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_demantra_pkg.export_demantra_ods_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_demantra_ods_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_demantra_ods_f('||
            '     st_transaction_id,'||
            '     error_code,'||
            '     sr_instance_id,'||
            '     organization_id,'||
            '     inventory_item_id,'||
            '     customer_id,'||
            '     customer_site_id,'||
            '     region_id,'||
            '     organization_code,'||
            '     item_name,'||
            '     customer_name,'||
            '     customer_site_code,'||
            '     zone,'||
            '     demand_class,'||
            '     end_date,'||
            '     production_history,'||
            '     sales_fcst,'||
            '     sales_fcst_value,'||
            '     sales_fcst_value2,'||
            '     sales_fcst_cum,'||
            '     mktg_fcst,'||
            '     mktg_fcst_value,'||
            '     mktg_fcst_value2,'||
            '     mktg_fcst_cum,'||
            '     budget,'||
            '     budget2,'||
            '     budget_cum,'||
            '     budget2_cum,'||
            '     booking_fcst,'||
            '     booking_fcst_value,'||
            '     booking_fcst_value2,'||
            '     booking_fcst_cum,'||
            '     shipment_fcst,'||
            '     shipment_fcst_value,'||
            '     shipment_fcst_value2,'||
            '     shipment_fcst_cum,'||
            '     projected_backlog,'||
            '     actual_backlog,'||
            '     shipment_history,'||
            '     shipment_history_value,'||
            '     shipment_history_value2,'||
            '     shipment_history_cum,'||
            '     booking_history,'||
            '     booking_history_value,'||
            '     booking_history_value2,'||
            '     booking_history_cum,'||
            '     consen_fcst_accrcy_mape_4week,'||
            '     consen_fcst_accrcy_mape_8week,'||
            '     consen_fcst_accrcy_mape_13week,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     returns_history,'||
            '     annual_plan_value,'||
            '     annual_plan_value2,'||
            '     financial_fcst_value,'||
            '     financial_fcst_value2,'||
            '     final_fcst,'||
            '     final_fcst_value,'||
            '     final_fcst_value2,'||
            '     final_fcst_cum,'||
            '     projected_backlog_value,'||
            '     projected_backlog_value2,'||
            '     actual_backlog_value,'||
            '     actual_backlog_value2,'||
            '     inventory_history,'||
            '     inventory_history_value,'||
            '     inventory_history_value2,'||
            '     booking_history_rd,'||
            '     booking_history_rd_value,'||
            '     booking_history_rd_value2,';
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
            '     f.customer_id,'||
            '     f.customer_site_id,'||
            '     f.region_id,'||
            '     mtp.organization_code,'||
            '     mi.item_name,'||
            '     decode(f.customer_id, -23453, null, cmv.customer_name),'||
            '     decode(f.customer_site_id, -23453, null, cmv.customer_site),'||
            '     decode(f.region_id, -23453, null, cmv.zone),'||
            '     f.demand_class,'||
            '     f.end_date,'||
            '     f.production_history,'||
            '     f.sales_fcst,'||
            '     f.sales_fcst_value,'||
            '     f.sales_fcst_value2,'||
            '     f.sales_fcst_cum,'||
            '     f.mktg_fcst,'||
            '     f.mktg_fcst_value,'||
            '     f.mktg_fcst_value2,'||
            '     f.mktg_fcst_cum,'||
            '     f.budget,'||
            '     f.budget2,'||
            '     f.budget_cum,'||
            '     f.budget2_cum,'||
            '     f.booking_fcst,'||
            '     f.booking_fcst_value,'||
            '     f.booking_fcst_value2,'||
            '     f.booking_fcst_cum,'||
            '     f.shipment_fcst,'||
            '     f.shipment_fcst_value,'||
            '     f.shipment_fcst_value2,'||
            '     f.shipment_fcst_cum,'||
            '     f.projected_backlog,'||
            '     f.actual_backlog,'||
            '     f.shipment_history,'||
            '     f.shipment_history_value,'||
            '     f.shipment_history_value2,'||
            '     f.shipment_history_cum,'||
            '     f.booking_history,'||
            '     f.booking_history_value,'||
            '     f.booking_history_value2,'||
            '     f.booking_history_cum,'||
            '     f.consen_fcst_accrcy_mape_4week,'||
            '     f.consen_fcst_accrcy_mape_8week,'||
            '     f.consen_fcst_accrcy_mape_13week,';
        if (p_source_version >= '12.1.3') then l_sql := l_sql||
            '     f.returns_history,'||
            '     f.annual_plan_value,'||
            '     f.annual_plan_value2,'||
            '     f.financial_fcst_value,'||
            '     f.financial_fcst_value2,'||
            '     f.final_fcst,'||
            '     f.final_fcst_value,'||
            '     f.final_fcst_value2,'||
            '     f.final_fcst_cum,'||
            '     f.projected_backlog_value,'||
            '     f.projected_backlog_value2,'||
            '     f.actual_backlog_value,'||
            '     f.actual_backlog_value2,'||
            '     f.inventory_history,'||
            '     f.inventory_history_value,'||
            '     f.inventory_history_value2,'||
            '     f.booking_history_rd,'||
            '     f.booking_history_rd_value,'||
            '     f.booking_history_rd_value2,';
        end if;
        l_sql := l_sql||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_demantra_ods_f'||l_suffix||' f,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,'||
            '     '||l_apps_schema||'.msc_items'||l_suffix||' mi,'||
            '     '||l_apps_schema||'.msc_phub_customers_mv'||l_suffix||' cmv'||
            ' where mtp.partner_type(+)=3'||
            '     and mtp.sr_instance_id(+)=f.sr_instance_id'||
            '     and mtp.sr_tp_id(+)=f.organization_id'||
            '     and mi.inventory_item_id(+)=f.inventory_item_id'||
            '     and cmv.customer_id(+)=f.customer_id'||
            '     and cmv.customer_site_id(+)=f.customer_site_id'||
            '     and cmv.region_id(+)=f.region_id';

        execute immediate l_sql using p_st_transaction_id;
        commit;
        msc_phub_util.log('msc_demantra_pkg.export_demantra_ods_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_demantra_pkg.export_demantra_ods_f: '||sqlerrm;
            raise;
    end export_demantra_ods_f;

    procedure import_demantra_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_demantra_f';
        l_fact_table varchar2(30) := 'msc_demantra_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_demantra_pkg.import_demantra_f');
        retcode := 0;
        errbuf := null;

        l_result := l_result + msc_phub_util.prepare_staging_dates(
            l_staging_table, 'start_date', p_st_transaction_id,
            p_upload_mode, p_overwrite_after_date,
            p_plan_start_date, p_plan_cutoff_date);

        l_result := l_result + msc_phub_util.prepare_fact_dates(
            l_fact_table, 1, 'start_date', p_plan_id, p_plan_run_id,
            p_upload_mode, p_overwrite_after_date);

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'sr_instance_id', 'organization_id', 'organization_code');

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'owning_inst_id', 'owning_org_id', 'owning_org_code');

        l_result := l_result + msc_phub_util.decode_item_key(
            l_staging_table, p_st_transaction_id, 'inventory_item_id', 'item_name');

        l_result := l_result + msc_phub_util.decode_customer_key(
            l_staging_table, p_st_transaction_id,
            'customer_id', 'customer_site_id', 'region_id',
            'customer_name', 'customer_site_code', 'zone');

        msc_phub_util.log('msc_demantra_pkg.import_demantra_f: insert into msc_demantra_f');
        insert into msc_demantra_f (
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
            demand_class,
            start_date,
            consensus_fcst,
            consensus_fcst_value,
            consensus_fcst_value2,
            consensus_fcst_cum,
            priority,
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
            nvl(customer_id, -23453),
            nvl(customer_site_id, -23453),
            nvl(region_id, -23453),
            demand_class,
            start_date,
            consensus_fcst,
            consensus_fcst_value,
            consensus_fcst_value2,
            consensus_fcst_cum,
            priority,
            0, -23453, -23453,
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_demantra_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_demantra_pkg.import_demantra_f: inserted='||sql%rowcount);
        commit;

        summarize_demantra_f(errbuf, retcode, p_plan_id, p_plan_run_id);

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_demantra_pkg.import_demantra_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_demantra_pkg.import_demantra_f: '||sqlerrm;
            raise;
    end import_demantra_f;

    procedure import_demantra_ods_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_demantra_ods_f';
        l_fact_table varchar2(30) := 'msc_demantra_ods_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_demantra_pkg.import_demantra_ods_f');
        retcode := 0;
        errbuf := null;

        delete from msc_demantra_ods_f;
        commit;

        l_result := l_result + msc_phub_util.prepare_staging_dates(
            l_staging_table, 'end_date', p_st_transaction_id,
            p_upload_mode, p_overwrite_after_date,
            p_plan_start_date, p_plan_cutoff_date);

        l_result := l_result + msc_phub_util.prepare_fact_dates(
            l_fact_table, 0, 'end_date', p_plan_id, p_plan_run_id,
            p_upload_mode, p_overwrite_after_date);

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'sr_instance_id', 'organization_id', 'organization_code');

        l_result := l_result + msc_phub_util.decode_item_key(
            l_staging_table, p_st_transaction_id, 'inventory_item_id', 'item_name');

        l_result := l_result + msc_phub_util.decode_customer_key(
            l_staging_table, p_st_transaction_id,
            'customer_id', 'customer_site_id', 'region_id',
            'customer_name', 'customer_site_code', 'zone');

        msc_phub_util.log('msc_demantra_pkg.import_demantra_ods_f: insert into msc_demantra_ods_f');
        insert into msc_demantra_ods_f (
            sr_instance_id,
            organization_id,
            inventory_item_id,
            customer_id,
            customer_site_id,
            region_id,
            demand_class,
            end_date,
            production_history,
            sales_fcst,
            sales_fcst_value,
            sales_fcst_value2,
            sales_fcst_cum,
            mktg_fcst,
            mktg_fcst_value,
            mktg_fcst_value2,
            mktg_fcst_cum,
            budget,
            budget2,
            budget_cum,
            budget2_cum,
            booking_fcst,
            booking_fcst_value,
            booking_fcst_value2,
            booking_fcst_cum,
            shipment_fcst,
            shipment_fcst_value,
            shipment_fcst_value2,
            shipment_fcst_cum,
            projected_backlog,
            actual_backlog,
            shipment_history,
            shipment_history_value,
            shipment_history_value2,
            shipment_history_cum,
            booking_history,
            booking_history_value,
            booking_history_value2,
            booking_history_cum,
            consen_fcst_accrcy_mape_4week,
            consen_fcst_accrcy_mape_8week,
            consen_fcst_accrcy_mape_13week,
            returns_history,
            annual_plan_value,
            annual_plan_value2,
            financial_fcst_value,
            financial_fcst_value2,
            final_fcst,
            final_fcst_value,
            final_fcst_value2,
            final_fcst_cum,
            projected_backlog_value,
            projected_backlog_value2,
            actual_backlog_value,
            actual_backlog_value2,
            inventory_history,
            inventory_history_value,
            inventory_history_value2,
            booking_history_rd,
            booking_history_rd_value,
            booking_history_rd_value2,
            created_by, creation_date,
            last_updated_by, last_update_date, last_update_login
        )
        select
            nvl(sr_instance_id, -23453),
            nvl(organization_id, -23453),
            nvl(inventory_item_id, -23453),
            nvl(customer_id, -23453),
            nvl(customer_site_id, -23453),
            nvl(region_id, -23453),
            demand_class,
            end_date,
            production_history,
            sales_fcst,
            sales_fcst_value,
            sales_fcst_value2,
            sales_fcst_cum,
            mktg_fcst,
            mktg_fcst_value,
            mktg_fcst_value2,
            mktg_fcst_cum,
            budget,
            budget2,
            budget_cum,
            budget2_cum,
            booking_fcst,
            booking_fcst_value,
            booking_fcst_value2,
            booking_fcst_cum,
            shipment_fcst,
            shipment_fcst_value,
            shipment_fcst_value2,
            shipment_fcst_cum,
            projected_backlog,
            actual_backlog,
            shipment_history,
            shipment_history_value,
            shipment_history_value2,
            shipment_history_cum,
            booking_history,
            booking_history_value,
            booking_history_value2,
            booking_history_cum,
            consen_fcst_accrcy_mape_4week,
            consen_fcst_accrcy_mape_8week,
            consen_fcst_accrcy_mape_13week,
            returns_history,
            annual_plan_value,
            annual_plan_value2,
            financial_fcst_value,
            financial_fcst_value2,
            final_fcst,
            final_fcst_value,
            final_fcst_value2,
            final_fcst_cum,
            projected_backlog_value,
            projected_backlog_value2,
            actual_backlog_value,
            actual_backlog_value2,
            inventory_history,
            inventory_history_value,
            inventory_history_value2,
            booking_history_rd,
            booking_history_rd_value,
            booking_history_rd_value2,
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_demantra_ods_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_demantra_pkg.import_demantra_ods_f: inserted='||sql%rowcount);
        commit;

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_demantra_pkg.import_demantra_ods_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_demantra_pkg.import_demantra_ods_f: '||sqlerrm;
            raise;
    end import_demantra_ods_f;

end msc_demantra_pkg;

/
