--------------------------------------------------------
--  DDL for Package Body MSC_PHUB_COST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_PHUB_COST_PKG" as
/* $Header: MSCHBCTB.pls 120.23.12010000.6 2010/04/30 12:38:38 wexia noship $ */

    procedure populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_owning_currency_code varchar2(20) := msc_phub_util.get_owning_currency_code(p_plan_run_id);
        l_qid_last_date number;

        l_plan_start_date date;
        l_plan_cutoff_date date;
        l_plan_type number;
        l_sr_instance_id number;
        l_organization_id number;

    begin
        msc_phub_util.log('msc_phub_cost_pkg.populate_details:');
        retcode := 0;
        errbuf := null;

        select plan_type, sr_instance_id, organization_id, plan_start_date, plan_cutoff_date
        into l_plan_type, l_sr_instance_id, l_organization_id, l_plan_start_date, l_plan_cutoff_date
        from msc_plan_runs
        where plan_id=p_plan_id
        and plan_run_id=p_plan_run_id;


        -- l_qid_last_date
        l_qid_last_date := msc_phub_util.get_reporting_dates(l_plan_start_date, l_plan_cutoff_date);

        insert into msc_costs_f (
            plan_id,
            plan_run_id,
            owning_inst_id,
            owning_org_id,
            sr_instance_id,
            organization_id,
            source_org_instance_id,
            source_organization_id,
            inventory_item_id,
            customer_id,
            customer_site_id,
            customer_region_id,
            supplier_id,
            supplier_site_id,
            supplier_region_id,
            io_plan_flag,
            ship_method,
            detail_date,
            aggr_type, category_set_id, sr_category_id,
            revenue,
            revenue2,
            manufacturing_cost,
            manufacturing_cost2,
            purchasing_cost,
            purchasing_cost2,
            transportation_cost,
            transportation_cost2,
            carrying_cost,
            carrying_cost2,
            supply_chain_cost,
            supply_chain_cost2,
            gross_margin,
            gross_margin2,
            fixed_cost,
            fixed_cost2,
            facility_cost,
            facility_cost2,
            item_travel_distance,
            source_count,
            risk_item_count,
            ctb_make_order_cnt,
            total_make_order_cnt,
            avail_component_qty,
            total_component_qty,
            ready_to_build_qty,
            total_build_qty,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        select
            p_plan_id,
            p_plan_run_id,
            t.owning_inst_id,
            t.owning_org_id,
            t.sr_instance_id,
            t.organization_id,
            t.source_org_instance_id,
            t.source_organization_id,
            t.inventory_item_id,
            t.customer_id,
            t.customer_site_id,
            t.customer_region_id,
            t.supplier_id,
            t.supplier_site_id,
            t.supplier_region_id,
            t.io_plan_flag,
            t.ship_method,
            t.detail_date,
            to_number(0) aggr_type,
            to_number(-23453) category_set_id,
            to_number(-23453) sr_category_id,
            sum(t.revenue),
            sum(t.revenue * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0)))
                revenue2,
            sum(t.manufacturing_cost),
            sum(t.manufacturing_cost * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0)))
                manufacturing_cost2,
            sum(t.purchasing_cost),
            sum(t.purchasing_cost * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0)))
                purchasing_cost2,
            sum(t.transportation_cost),
            sum(t.transportation_cost * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0)))
                transportation_cost2,
            sum(t.carrying_cost),
            sum(t.carrying_cost * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0)))
                carrying_cost2,
            sum(t.supply_chain_cost),
            sum(t.supply_chain_cost * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0)))
                supply_chain_cost2,
            sum(nvl(t.revenue,0)-nvl(t.supply_chain_cost,0)) gross_margin,
            sum((nvl(t.revenue,0)-nvl(t.supply_chain_cost,0)) * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0)))
                gross_margin2,
            sum(t.fixed_cost),
            sum(t.fixed_cost * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0)))
                fixed_cost2,
            sum(t.facility_cost),
            sum(t.facility_cost * decode(t.currency_code,
                fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0)))
                facility_cost2,
            sum(t.item_travel_distance),
            sum(t.source_count),
            sum(t.risk_item_count),
            sum(ctb_make_order_cnt),
            sum(total_make_order_cnt),
            sum(avail_component_qty),
            sum(total_component_qty),
            sum(ready_to_build_qty),
            sum(total_build_qty),

            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            (select
                decode(sign(mbid.sr_instance_id), -1,
                    l_sr_instance_id, mbid.sr_instance_id) owning_inst_id,
                decode(sign(mbid.organization_id), -1,
                    msc_hub_calendar.get_item_org(p_plan_id,
                        mbid.inventory_item_id,
                        decode(sign(mbid.sr_instance_id), -1,
                            l_sr_instance_id, mbid.sr_instance_id)),
                    mbid.organization_id) owning_org_id,
                decode(sign(nvl(mbid.organization_id, -23453)),
                    -1, -23453, nvl(mbid.sr_instance_id, -23453)) sr_instance_id,
                nvl(mbid.organization_id, -23453) organization_id,
                nvl(mbid.source_org_instance_id, -23453) source_org_instance_id,
                nvl(mbid.source_organization_id, -23453) source_organization_id,
                nvl(mbid.inventory_item_id, -23453) inventory_item_id,
                nvl(mbid.customer_id, -23453) customer_id,
                nvl(mbid.customer_site_id, -23453) customer_site_id,
                cmv.region_id customer_region_id,
                nvl(mbid.supplier_id, -23453) supplier_id,
                nvl(mbid.supplier_site_id, -23453) supplier_site_id,
                smv.region_id supplier_region_id,
                decode(l_plan_type,4,1,9,1,0) io_plan_flag,
                nvl(mbid.ship_method, '-23453') ship_method,
                decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)) currency_code,
                trunc(mbid.detail_date) detail_date,
                sum(decode(l_plan_type, 6,
                    decode(sign(mbid.mds_price), -1, -mbid.mds_price, 0), mbid.mds_price)) revenue,
                sum(nvl(mbid.production_cost,0)) manufacturing_cost,
                sum(nvl(mbid.purchasing_cost,0)) purchasing_cost,
                sum(nvl(mbid.transportation_cost,0)) transportation_cost,
                sum(nvl(mbid.carrying_cost,0)) carrying_cost,
                sum(nvl(mbid.production_cost,0) + nvl(mbid.purchasing_cost,0) +
                    nvl(mbid.carrying_cost,0) + nvl(mbid.transportation_cost,0)) supply_chain_cost,
                to_number(null) fixed_cost,
                to_number(null) facility_cost,
                sum(nvl(mbid.item_travel_distance,0)) item_travel_distance,
                to_number(null) source_count,
                to_number(null) risk_item_count,
                to_number(null) ctb_make_order_cnt,
                to_number(null) total_make_order_cnt,
                to_number(null) avail_component_qty,
                to_number(null) total_component_qty,
                to_number(null) ready_to_build_qty,
                to_number(null) total_build_qty
            from
                msc_bis_inv_detail mbid,
                msc_trading_partners mtp,
                msc_phub_suppliers_mv smv,
                msc_phub_customers_mv cmv
            where mbid.plan_id=p_plan_id
                and mbid.sr_instance_id=mtp.sr_instance_id(+)
                and mbid.organization_id=mtp.sr_tp_id(+)
                and l_plan_type not in (101,102,103,105)
                and mtp.partner_type(+)=3
                and (nvl(mbid.detail_level,0)=1 or l_plan_type=6)
                and nvl(mbid.period_type,0)=1
                and smv.supplier_id(+) = nvl(mbid.supplier_id, -23453)
                and smv.supplier_site_id(+) = nvl(mbid.supplier_site_id, -23453)
                and smv.region_id(+) = decode(nvl(mbid.supplier_id, -23453), -23453, nvl(mbid.zone_id, -23453), smv.region_id(+))
                and cmv.customer_id(+) = nvl(mbid.customer_id, -23453)
                and cmv.customer_site_id(+) = nvl(mbid.customer_site_id, -23453)
                and cmv.region_id(+) = decode(nvl(mbid.zone_id, -23453),
                    -23453, decode(nvl(mbid.customer_id, -23453), -23453, -23453, cmv.region_id(+)),
                    nvl(mbid.zone_id, -23453))
            group by
                decode(sign(mbid.sr_instance_id), -1,
                    l_sr_instance_id, mbid.sr_instance_id),
                decode(sign(mbid.organization_id), -1,
                    msc_hub_calendar.get_item_org(p_plan_id,
                        mbid.inventory_item_id,
                        decode(sign(mbid.sr_instance_id), -1,
                            l_sr_instance_id, mbid.sr_instance_id)),
                    mbid.organization_id),
                decode(sign(nvl(mbid.organization_id, -23453)),
                    -1, -23453, nvl(mbid.sr_instance_id, -23453)),
                nvl(mbid.organization_id, -23453),
                nvl(mbid.source_org_instance_id, -23453),
                nvl(mbid.source_organization_id, -23453),
                nvl(mbid.inventory_item_id, -23453),
                nvl(mbid.customer_id, -23453),
                nvl(mbid.customer_site_id, -23453),
                cmv.region_id,
                nvl(mbid.supplier_id, -23453),
                nvl(mbid.supplier_site_id, -23453),
                smv.region_id,
                decode(l_plan_type,4,1,9,1,0),
                nvl(mbid.ship_method, '-23453'),
                decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)),
                trunc(mbid.detail_date)
            union all
            -- facility_cost
            select
                decode(sign(mbod.sr_instance_id), -1,
                    l_sr_instance_id, mbod.sr_instance_id) owning_inst_id,
                decode(sign(mbod.organization_id), -1,
                    l_organization_id, mbod.organization_id) owning_org_id,
                mbod.sr_instance_id,
                mbod.organization_id,
                to_number(-23453) source_org_instance_id,
                to_number(-23453) source_organization_id,
                to_number(-23453) inventory_item_id,
                to_number(-23453) customer_id,
                to_number(-23453) customer_site_id,
                to_number(-23453) customer_region_id,
                to_number(-23453) supplier_id,
                to_number(-23453) supplier_site_id,
                to_number(-23453) supplier_region_id,
                to_number(0) io_plan_flag,
                '-23453' ship_method,
                l_owning_currency_code currency_code,
                trunc(mbod.detail_date),
                to_number(null) revenue,
                to_number(null) manufacturing_cost,
                to_number(null) purchasing_cost,
                to_number(null) transportation_cost,
                to_number(null) carrying_cost,
                to_number(null) supply_chain_cost,
                sum(decode(mbod.facility_cost_type,
                    3, mbod.facility_cost, null)) fixed_cost,
                sum(decode(mbod.facility_cost_type,
                    1, mbod.facility_cost, 2, mbod.facility_cost,
                    null)) facility_cost,
                to_number(null) item_travel_distance,
                to_number(null) source_count,
                to_number(null) risk_item_count,
                to_number(null) ctb_make_order_cnt,
                to_number(null) total_make_order_cnt,
                to_number(null) avail_component_qty,
                to_number(null) total_component_qty,
                to_number(null) ready_to_build_qty,
                to_number(null) total_build_qty
            from msc_bis_org_detail mbod
            where mbod.plan_id=p_plan_id
            group by
                decode(sign(mbod.sr_instance_id), -1,
                    l_sr_instance_id, mbod.sr_instance_id),
                decode(sign(mbod.organization_id), -1,
                    l_organization_id, mbod.organization_id),
                mbod.sr_instance_id,
                mbod.organization_id,
                trunc(mbod.detail_date)
            union all
            -- source_count
            select
                decode(sign(mis.sr_instance_id), -1,
                    l_sr_instance_id, mis.sr_instance_id) owning_inst_id,
                decode(sign(mis.organization_id), -1,
                    msc_hub_calendar.get_item_org(p_plan_id,
                        mis.inventory_item_id,
                        decode(sign(mis.sr_instance_id), -1,
                            l_sr_instance_id, mis.sr_instance_id)),
                    mis.organization_id) owning_org_id,
                decode(sign(nvl(mis.organization_id, -23453)),
                    -1, -23453, nvl(mis.sr_instance_id, -23453)) sr_instance_id,
                nvl(mis.organization_id, -23453) organization_id,
                nvl(mis.sr_instance_id2, -23453) source_org_instance_id,
                nvl(mis.source_organization_id, -23453) source_organization_id,
                nvl(mis.inventory_item_id, -23453) inventory_item_id,
                nvl(mis.customer_id, -23453) customer_id,
                nvl(mis.customer_site_id, -23453) customer_site_id,
                cmv.region_id customer_region_id,
                nvl(mis.supplier_id, -23453) supplier_id,
                nvl(mis.supplier_site_id, -23453) supplier_site_id,
                smv.region_id supplier_region_id,
                decode(l_plan_type,4,1,9,1,0) io_plan_flag,
                '-23453' ship_method,
                decode(l_plan_type, 6, l_owning_currency_code, nvl(mtp.currency_code, l_owning_currency_code)) currency_code,
                last_date1.date1 detail_date,
                to_number(null) revenue,
                to_number(null) manufacturing_cost,
                to_number(null) purchasing_cost,
                to_number(null) transportation_cost,
                to_number(null) carrying_cost,
                to_number(null) supply_chain_cost,
                to_number(null) fixed_cost,
                to_number(null) facility_cost,
                to_number(null) item_travel_distance,
                mis.source_count,
                risk.risk_item_count,
                to_number(null) ctb_make_order_cnt,
                to_number(null) total_make_order_cnt,
                to_number(null) avail_component_qty,
                to_number(null) total_component_qty,
                to_number(null) ready_to_build_qty,
                to_number(null) total_build_qty
            from
                (select distinct
                    plan_id,
                    nvl(sr_instance_id, -23453) sr_instance_id,
                    nvl(organization_id, -23453) organization_id,
                    nvl(inventory_item_id, -23453) inventory_item_id,
                    nvl(customer_id, -23453) customer_id,
                    nvl(customer_site_id, -23453) customer_site_id,
                    nvl(zone_id, -23453) zone_id,
                    nvl(sr_instance_id2, -23453) sr_instance_id2,
                    nvl(source_organization_id, -23453) source_organization_id,
                    nvl(supplier_id, -23453) supplier_id,
                    nvl(supplier_site_id, -23453) supplier_site_id,
                    nvl(region_id, -23453) region_id,
                    nvl(effective_date, l_plan_start_date) effective_date,
                    nvl(disable_date, l_plan_cutoff_date) disable_date,
                    to_number(1) source_count
                from msc_item_sourcing
                where plan_id=p_plan_id
                ) mis,
                (select
                    plan_id,
                    nvl(sr_instance_id, -23453) sr_instance_id,
                    nvl(organization_id, -23453) organization_id,
                    nvl(inventory_item_id, -23453) inventory_item_id,
                    nvl(customer_id, -23453) customer_id,
                    nvl(customer_site_id, -23453) customer_site_id,
                    nvl(zone_id, -23453) zone_id,
                    nvl(effective_date, l_plan_start_date) effective_date,
                    nvl(disable_date, l_plan_cutoff_date) disable_date,
                    decode(sign(count(*)-1), 1, 0, 1) risk_item_count
                from msc_item_sourcing
                where plan_id=p_plan_id
                group by
                    plan_id,
                    nvl(sr_instance_id, -23453),
                    nvl(organization_id, -23453),
                    nvl(inventory_item_id, -23453),
                    nvl(customer_id, -23453),
                    nvl(customer_site_id, -23453),
                    nvl(zone_id, -23453),
                    nvl(effective_date, l_plan_start_date),
                    nvl(disable_date, l_plan_cutoff_date)
                ) risk,
                msc_trading_partners mtp,
                msc_phub_customers_mv cmv,
                msc_phub_suppliers_mv smv,
                msc_hub_query last_date1
            where mis.plan_id=p_plan_id
                and mis.sr_instance_id=risk.sr_instance_id(+)
                and mis.organization_id=risk.organization_id(+)
                and mis.inventory_item_id=risk.inventory_item_id(+)
                and mis.customer_id=risk.customer_id(+)
                and mis.customer_site_id=risk.customer_site_id(+)
                and mis.zone_id=risk.zone_id(+)
                and mis.effective_date=risk.effective_date(+)
                and mis.disable_date=risk.disable_date(+)
                and mis.sr_instance_id=mtp.sr_instance_id(+)
                and mis.organization_id=mtp.sr_tp_id(+)
                and mtp.partner_type(+)=3
                and cmv.customer_id(+) = nvl(mis.customer_id, -23453)
                and cmv.customer_site_id(+) = nvl(mis.customer_site_id, -23453)
                and cmv.region_id(+) = decode(nvl(mis.zone_id, -23453),
                    -23453, decode(nvl(mis.customer_id, -23453), -23453, -23453, cmv.region_id(+)),
                    nvl(mis.zone_id, -23453))
                and smv.supplier_id(+) = nvl(mis.supplier_id, -23453)
                and smv.supplier_site_id(+) = nvl(mis.supplier_site_id, -23453)
                and smv.region_id(+) = decode(nvl(mis.region_id, -23453),
                    -23453, decode(nvl(mis.supplier_id, -23453), -23453, -23453, smv.region_id(+)),
                    nvl(mis.region_id, -23453))
                and last_date1.date1 between nvl(mis.effective_date, l_plan_start_date) and nvl(mis.disable_date, l_plan_cutoff_date)
                and last_date1.query_id=l_qid_last_date
            union all
            -- clear_to_build
            select
                decode(sign(mrk.instance_id), -1,
                    l_sr_instance_id, mrk.instance_id) owning_inst_id,
                decode(sign(mrk.org_id), -1,
                    msc_hub_calendar.get_item_org(p_plan_id,
                        mrk.item_id,
                        decode(sign(mrk.instance_id), -1,
                            l_sr_instance_id, mrk.instance_id)),
                    mrk.org_id) owning_org_id,
                decode(sign(nvl(mrk.org_id, -23453)),
                    -1, -23453, nvl(mrk.instance_id, -23453)) sr_instance_id,
                nvl(mrk.org_id, -23453) organization_id,
                to_number(-23453) source_org_instance_id,
                to_number(-23453) source_organization_id,
                nvl(mrk.item_id, -23453) inventory_item_id,
                nvl(mrk.customer_id, -23453) customer_id,
                nvl(mrk.customer_site_id, -23453) customer_site_id,
                cmv.region_id customer_region_id,
                nvl(mrk.supplier_id, -23453) supplier_id,
                nvl(mrk.supplier_site_id, -23453) supplier_site_id,
                smv.region_id supplier_region_id,
                to_number(0) io_plan_flag,
                '-23453' ship_method,
                nvl(mtp.currency_code, l_owning_currency_code) currency_code,
                d.mfg_week_end_date detail_date,
                sum(decode(mrk.kpi_type_id, 5, kpi_value, null)) revenue,
                sum(decode(mrk.kpi_type_id, 7, kpi_value, null)) manufacturing_cost,
                sum(decode(mrk.kpi_type_id, 8, kpi_value, null)) purchasing_cost,
                to_number(null) transportation_cost,
                to_number(null) carrying_cost,
                sum(case when mrk.kpi_type_id in (7,8) then kpi_value else 0 end) supply_chain_cost,
                to_number(null) fixed_cost,
                to_number(null) facility_cost,
                to_number(null) item_travel_distance,
                to_number(null) source_count,
                to_number(null) risk_item_count,
                sum(decode(mrk.kpi_type_id, 36, kpi_value_num1, null)) ctb_make_order_cnt,
                sum(decode(mrk.kpi_type_id, 36, kpi_value_num2, null)) total_make_order_cnt,
                sum(decode(mrk.kpi_type_id, 37, kpi_value_num1, null)) avail_component_qty,
                sum(decode(mrk.kpi_type_id, 37, kpi_value_num2, null)) total_component_qty,
                sum(decode(mrk.kpi_type_id, 38, kpi_value_num1, null)) ready_to_build_qty,
                sum(decode(mrk.kpi_type_id, 38, kpi_value_num2, null)) total_build_qty
            from
                msc_rp_kpi mrk,
                msc_trading_partners mtp,
                msc_phub_suppliers_mv smv,
                msc_phub_customers_mv cmv,
                msc_phub_dates_mv d
            where mrk.plan_id=p_plan_id
                and mrk.instance_id=mtp.sr_instance_id(+)
                and mrk.org_id=mtp.sr_tp_id(+)
                and mrk.kpi_type_id in (5,7,8,36,37,38)
                and l_plan_type in (101,102,103,105)
                and mtp.partner_type(+)=3
                and smv.supplier_id(+) = nvl(mrk.supplier_id, -23453)
                and smv.supplier_site_id(+) = nvl(mrk.supplier_site_id, -23453)
                and smv.region_id(+) = decode(nvl(mrk.supplier_id, -23453), -23453, -23453, smv.region_id(+))
                and cmv.customer_id(+) = nvl(mrk.customer_id, -23453)
                and cmv.customer_site_id(+) = nvl(mrk.customer_site_id, -23453)
                and cmv.region_id(+) = decode(nvl(mrk.customer_id, -23453), -23453, -23453, cmv.region_id(+))
                and trunc(mrk.kpi_time)=d.calendar_date
                and mrk.item_id is not null
                and mrk.kpi_time is not null
                and mrk.org_id is not null
            group by
                decode(sign(mrk.instance_id), -1,
                    l_sr_instance_id, mrk.instance_id),
                decode(sign(mrk.org_id), -1,
                    msc_hub_calendar.get_item_org(p_plan_id,
                        mrk.item_id,
                        decode(sign(mrk.instance_id), -1,
                            l_sr_instance_id, mrk.instance_id)),
                    mrk.org_id),
                decode(sign(nvl(mrk.org_id, -23453)),
                    -1, -23453, nvl(mrk.instance_id, -23453)),
                nvl(mrk.org_id, -23453),
                nvl(mrk.item_id, -23453),
                nvl(mrk.customer_id, -23453),
                nvl(mrk.customer_site_id, -23453),
                cmv.region_id,
                nvl(mrk.supplier_id, -23453),
                nvl(mrk.supplier_site_id, -23453),
                smv.region_id,
                decode(l_plan_type,4,1,9,1,0),
                nvl(mtp.currency_code, l_owning_currency_code),
                d.mfg_week_end_date
            ) t,
            msc_currency_conv_mv mcc
        where mcc.from_currency(+)=t.currency_code
            and mcc.calendar_date(+)=t.detail_date
            and mcc.to_currency(+)=fnd_profile.value('MSC_HUB_CUR_CODE_RPT')
        group by
            t.owning_inst_id,
            t.owning_org_id,
            t.sr_instance_id,
            t.organization_id,
            t.source_org_instance_id,
            t.source_organization_id,
            t.inventory_item_id,
            t.customer_id,
            t.customer_site_id,
            t.customer_region_id,
            t.supplier_id,
            t.supplier_site_id,
            t.supplier_region_id,
            t.io_plan_flag,
            t.ship_method,
            t.detail_date;

        msc_phub_util.log('msc_phub_cost_pkg.populate_details: msc_costs_f, rowcount='||sql%rowcount);
        commit;

        summarize_costs_f(errbuf, retcode, p_plan_id, p_plan_run_id);

    exception
        when others then
            msc_phub_util.log('msc_phub_cost_pkg.populate_details.exception: '||sqlerrm);
            errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_POPULATE_ERROR')||':'||sqlerrm;
            retcode := 2;

    end populate_details;


    procedure summarize_costs_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_category_set_id1 number := fnd_profile.value('MSC_HUB_CAT_SET_ID_1');
    begin
        msc_phub_util.log('msc_phub_cost_pkg.summarize_costs_f');
        retcode := 0;
        errbuf := '';

        delete from msc_costs_f
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id and aggr_type>0;
        msc_phub_util.log('msc_phub_cost_pkg.summarize_costs_f, delete='||sql%rowcount);
        commit;

        -- level 1
        insert into msc_costs_f (
            plan_id, plan_run_id,
            owning_inst_id, owning_org_id,
            sr_instance_id, organization_id,
            source_org_instance_id, source_organization_id,
            inventory_item_id,
            customer_id, customer_site_id, customer_region_id,
            supplier_id, supplier_site_id, supplier_region_id,
            io_plan_flag, ship_method, detail_date,
            aggr_type, category_set_id, sr_category_id,
            revenue,
            revenue2,
            manufacturing_cost,
            manufacturing_cost2,
            purchasing_cost,
            purchasing_cost2,
            transportation_cost,
            transportation_cost2,
            carrying_cost,
            carrying_cost2,
            supply_chain_cost,
            supply_chain_cost2,
            gross_margin,
            gross_margin2,
            fixed_cost,
            fixed_cost2,
            facility_cost,
            facility_cost2,
            item_travel_distance,
            source_count,
            risk_item_count,
            ctb_make_order_cnt,
            total_make_order_cnt,
            avail_component_qty,
            total_component_qty,
            ready_to_build_qty,
            total_build_qty,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category (42, 43, 44)
        select
            f.plan_id, f.plan_run_id,
            f.owning_inst_id, f.owning_org_id,
            f.sr_instance_id, f.organization_id,
            f.source_org_instance_id, f.source_organization_id,
            to_number(-23453) inventory_item_id,
            f.customer_id, f.customer_site_id, f.customer_region_id,
            f.supplier_id, f.supplier_site_id, f.supplier_region_id,
            f.io_plan_flag, f.ship_method, f.detail_date,
            to_number(42) aggr_type,
            l_category_set_id1 category_set_id,
            nvl(q.sr_category_id, -23453),
            sum(f.revenue),
            sum(f.revenue2),
            sum(f.manufacturing_cost),
            sum(f.manufacturing_cost2),
            sum(f.purchasing_cost),
            sum(f.purchasing_cost2),
            sum(f.transportation_cost),
            sum(f.transportation_cost2),
            sum(f.carrying_cost),
            sum(f.carrying_cost2),
            sum(f.supply_chain_cost),
            sum(f.supply_chain_cost2),
            sum(f.gross_margin),
            sum(f.gross_margin2),
            sum(f.fixed_cost),
            sum(f.fixed_cost2),
            sum(f.facility_cost),
            sum(f.facility_cost2),
            sum(f.item_travel_distance),
            sum(f.source_count),
            sum(f.risk_item_count),
            sum(f.ctb_make_order_cnt),
            sum(f.total_make_order_cnt),
            sum(f.avail_component_qty),
            sum(f.total_component_qty),
            sum(f.ready_to_build_qty),
            sum(f.total_build_qty),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_costs_f f,
            msc_phub_item_categories_mv q
        where f.plan_id = p_plan_id and f.plan_run_id = p_plan_run_id
            and f.aggr_type=0
            and f.sr_instance_id=q.sr_instance_id(+)
            and f.organization_id=q.organization_id(+)
            and f.inventory_item_id=q.inventory_item_id(+)
            and q.category_set_id(+)=l_category_set_id1
        group by
            f.plan_id, f.plan_run_id,
            f.owning_inst_id, f.owning_org_id,
            f.sr_instance_id, f.organization_id,
            f.source_org_instance_id, f.source_organization_id,
            f.customer_id, f.customer_site_id, f.customer_region_id,
            f.supplier_id, f.supplier_site_id, f.supplier_region_id,
            f.io_plan_flag, f.ship_method, f.detail_date,
            nvl(q.sr_category_id, -23453);

        msc_phub_util.log('msc_phub_cost_pkg.summarize_costs_f, level1='||sql%rowcount);
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_phub_cost_pkg.summarize_costs_f: '||sqlerrm;
            raise;

    end summarize_costs_f;

    procedure export_costs_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_phub_cost_pkg.export_costs_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_costs_f where st_transaction_id=p_st_transaction_id;
        commit;

        if (p_source_version < '12.1.3') then
            l_sql :=
                ' insert into msc_st_costs_f('||
                '     st_transaction_id,'||
                '     error_code,'||
                '     owning_inst_id,'||
                '     owning_org_id,'||
                '     sr_instance_id,'||
                '     organization_id,'||
                '     inventory_item_id,'||
                '     owning_org_code,'||
                '     organization_code,'||
                '     item_name,'||
                '     detail_date,'||
                '     revenue,'||
                '     revenue2,'||
                '     manufacturing_cost,'||
                '     manufacturing_cost2,'||
                '     purchasing_cost,'||
                '     purchasing_cost2,'||
                '     transportation_cost,'||
                '     transportation_cost2,'||
                '     carrying_cost,'||
                '     carrying_cost2,'||
                '     supply_chain_cost,'||
                '     supply_chain_cost2,'||
                '     gross_margin,'||
                '     gross_margin2,'||
                '     created_by, creation_date,'||
                '     last_updated_by, last_update_date, last_update_login'||
                ' )'||
                ' select'||
                '     :p_st_transaction_id,'||
                '     0,'||
                '     f.owning_inst_id,'||
                '     f.owning_org_id,'||
                '     f.sr_instance_id,'||
                '     f.organization_id,'||
                '     f.inventory_item_id,'||
                '     mtp3.organization_code,'||
                '     mtp.organization_code,'||
                '     mi.item_name,'||
                '     f.order_date,'||
                '     f.revenue,'||
                '     f.revenue2,'||
                '     f.manufacturing_cost,'||
                '     f.manufacturing_cost2,'||
                '     f.purchasing_cost,'||
                '     f.purchasing_cost2,'||
                '     f.transportation_cost,'||
                '     f.transportation_cost2,'||
                '     f.carrying_cost,'||
                '     f.carrying_cost2,'||
                '     f.supply_chain_cost,'||
                '     f.supply_chain_cost2,'||
                '     f.gross_margin,'||
                '     f.gross_margin2,'||
                '     fnd_global.user_id, sysdate,'||
                '     fnd_global.user_id, sysdate, fnd_global.login_id'||
                ' from'||
                '     '||l_apps_schema||'.msc_item_inventory_f'||l_suffix||' f,'||
                '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,'||
                '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp3,'||
                '     '||l_apps_schema||'.msc_items'||l_suffix||' mi'||
                ' where f.plan_id=:p_plan_id'||
                '     and f.plan_run_id=:p_plan_run_id'||
                '     and f.aggr_type=0'||
                '     and mtp.partner_type(+)=3'||
                '     and mtp.sr_instance_id(+)=f.sr_instance_id'||
                '     and mtp.sr_tp_id(+)=f.organization_id'||
                '     and mtp3.partner_type(+)=3'||
                '     and mtp3.sr_instance_id(+)=f.owning_inst_id'||
                '     and mtp3.sr_tp_id(+)=f.owning_org_id'||
                '     and mi.inventory_item_id(+)=f.inventory_item_id';
        else
            l_sql :=
                ' insert into msc_st_costs_f('||
                '     st_transaction_id,'||
                '     error_code,'||
                '     owning_inst_id,'||
                '     owning_org_id,'||
                '     sr_instance_id,'||
                '     organization_id,'||
                '     source_org_instance_id,'||
                '     source_organization_id,'||
                '     inventory_item_id,'||
                '     customer_id,'||
                '     customer_site_id,'||
                '     customer_region_id,'||
                '     supplier_id,'||
                '     supplier_site_id,'||
                '     supplier_region_id,'||
                '     owning_org_code,'||
                '     organization_code,'||
                '     source_org_code,'||
                '     item_name,'||
                '     customer_name,'||
                '     customer_site_code,'||
                '     customer_zone,'||
                '     supplier_name,'||
                '     supplier_site_code,'||
                '     supplier_zone,'||
                '     ship_method,'||
                '     detail_date,'||
                '     revenue,'||
                '     revenue2,'||
                '     manufacturing_cost,'||
                '     manufacturing_cost2,'||
                '     purchasing_cost,'||
                '     purchasing_cost2,'||
                '     transportation_cost,'||
                '     transportation_cost2,'||
                '     carrying_cost,'||
                '     carrying_cost2,'||
                '     supply_chain_cost,'||
                '     supply_chain_cost2,'||
                '     gross_margin,'||
                '     gross_margin2,'||
                '     fixed_cost,'||
                '     fixed_cost2,'||
                '     facility_cost,'||
                '     facility_cost2,'||
                '     item_travel_distance,'||
                '     source_count,'||
                '     risk_item_count,'||
                '     ctb_make_order_cnt,'||
                '     total_make_order_cnt,'||
                '     avail_component_qty,'||
                '     total_component_qty,'||
                '     ready_to_build_qty,'||
                '     total_build_qty,'||
                '     created_by, creation_date,'||
                '     last_updated_by, last_update_date, last_update_login'||
                ' )'||
                ' select'||
                '     :p_st_transaction_id,'||
                '     0,'||
                '     f.owning_inst_id,'||
                '     f.owning_org_id,'||
                '     f.sr_instance_id,'||
                '     f.organization_id,'||
                '     f.source_org_instance_id,'||
                '     f.source_organization_id,'||
                '     f.inventory_item_id,'||
                '     f.customer_id,'||
                '     f.customer_site_id,'||
                '     f.customer_region_id,'||
                '     f.supplier_id,'||
                '     f.supplier_site_id,'||
                '     f.supplier_region_id,'||
                '     mtp3.organization_code,'||
                '     mtp.organization_code,'||
                '     mtp2.organization_code,'||
                '     mi.item_name,'||
                '     decode(f.customer_id, -23453, null, cmv.customer_name),'||
                '     decode(f.customer_site_id, -23453, null, cmv.customer_site),'||
                '     decode(f.customer_region_id, -23453, null, cmv.zone),'||
                '     decode(f.supplier_id, -23453, null, smv.supplier_name),'||
                '     decode(f.supplier_site_id, -23453, null, smv.supplier_site_code),'||
                '     decode(f.supplier_region_id, -23453, null, smv.zone),'||
                '     f.ship_method,'||
                '     f.detail_date,'||
                '     f.revenue,'||
                '     f.revenue2,'||
                '     f.manufacturing_cost,'||
                '     f.manufacturing_cost2,'||
                '     f.purchasing_cost,'||
                '     f.purchasing_cost2,'||
                '     f.transportation_cost,'||
                '     f.transportation_cost2,'||
                '     f.carrying_cost,'||
                '     f.carrying_cost2,'||
                '     f.supply_chain_cost,'||
                '     f.supply_chain_cost2,'||
                '     f.gross_margin,'||
                '     f.gross_margin2,'||
                '     f.fixed_cost,'||
                '     f.fixed_cost2,'||
                '     f.facility_cost,'||
                '     f.facility_cost2,'||
                '     f.item_travel_distance,'||
                '     f.source_count,'||
                '     f.risk_item_count,'||
                '     f.ctb_make_order_cnt,'||
                '     f.total_make_order_cnt,'||
                '     f.avail_component_qty,'||
                '     f.total_component_qty,'||
                '     f.ready_to_build_qty,'||
                '     f.total_build_qty,'||
                '     fnd_global.user_id, sysdate,'||
                '     fnd_global.user_id, sysdate, fnd_global.login_id'||
                ' from'||
                '     '||l_apps_schema||'.msc_costs_f'||l_suffix||' f,'||
                '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,'||
                '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp2,'||
                '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp3,'||
                '     '||l_apps_schema||'.msc_items'||l_suffix||' mi,'||
                '     '||l_apps_schema||'.msc_phub_customers_mv'||l_suffix||' cmv,'||
                '     '||l_apps_schema||'.msc_phub_suppliers_mv'||l_suffix||' smv'||
                ' where f.plan_id=:p_plan_id'||
                '     and f.plan_run_id=:p_plan_run_id'||
                '     and f.aggr_type=0'||
                '     and mtp.partner_type(+)=3'||
                '     and mtp.sr_instance_id(+)=f.sr_instance_id'||
                '     and mtp.sr_tp_id(+)=f.organization_id'||
                '     and mtp2.partner_type(+)=3'||
                '     and mtp2.sr_instance_id(+)=f.source_org_instance_id'||
                '     and mtp2.sr_tp_id(+)=f.source_organization_id'||
                '     and mtp3.partner_type(+)=3'||
                '     and mtp3.sr_instance_id(+)=f.owning_inst_id'||
                '     and mtp3.sr_tp_id(+)=f.owning_org_id'||
                '     and mi.inventory_item_id(+)=f.inventory_item_id'||
                '     and cmv.customer_id(+)=f.customer_id'||
                '     and cmv.customer_site_id(+)=f.customer_site_id'||
                '     and cmv.region_id(+)=f.customer_region_id'||
                '     and smv.supplier_id(+)=f.supplier_id'||
                '     and smv.supplier_site_id(+)=f.supplier_site_id'||
                '     and smv.region_id(+)=f.supplier_region_id';
        end if;

        execute immediate l_sql using p_st_transaction_id, p_plan_id, p_plan_run_id;
        commit;
        msc_phub_util.log('msc_phub_cost_pkg.export_costs_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_phub_cost_pkg.export_costs_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end export_costs_f;

    procedure import_costs_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_costs_f';
        l_fact_table varchar2(30) := 'msc_costs_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_phub_cost_pkg.import_costs_f');
        retcode := 0;
        errbuf := null;

        l_result := l_result + msc_phub_util.prepare_staging_dates(
            l_staging_table, 'detail_date', p_st_transaction_id,
            p_upload_mode, p_overwrite_after_date,
            p_plan_start_date, p_plan_cutoff_date);

        l_result := l_result + msc_phub_util.prepare_fact_dates(
            l_fact_table, 1, 'detail_date', p_plan_id, p_plan_run_id,
            p_upload_mode, p_overwrite_after_date);

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'owning_inst_id', 'owning_org_id', 'owning_org_code');

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'sr_instance_id', 'organization_id', 'organization_code');

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'source_org_instance_id', 'source_organization_id', 'source_org_code');

        l_result := l_result + msc_phub_util.decode_item_key(
            l_staging_table, p_st_transaction_id, 'inventory_item_id', 'item_name');

        l_result := l_result + msc_phub_util.decode_customer_key(
            l_staging_table, p_st_transaction_id,
            'customer_id', 'customer_site_id', 'customer_region_id',
            'customer_name', 'customer_site_code', 'customer_zone');

        l_result := l_result + msc_phub_util.decode_supplier_key(
            l_staging_table, p_st_transaction_id,
            'supplier_id', 'supplier_site_id', 'supplier_region_id',
            'supplier_name', 'supplier_site_code', 'supplier_zone');

        msc_phub_util.log('msc_phub_cost_pkg.import_costs_f: insert into msc_costs_f');
        insert into msc_costs_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            owning_inst_id,
            owning_org_id,
            source_org_instance_id,
            source_organization_id,
            inventory_item_id,
            customer_id,
            customer_site_id,
            customer_region_id,
            supplier_id,
            supplier_site_id,
            supplier_region_id,
            io_plan_flag,
            ship_method,
            detail_date,
            revenue,
            revenue2,
            manufacturing_cost,
            manufacturing_cost2,
            purchasing_cost,
            purchasing_cost2,
            transportation_cost,
            transportation_cost2,
            carrying_cost,
            carrying_cost2,
            supply_chain_cost,
            supply_chain_cost2,
            gross_margin,
            gross_margin2,
            fixed_cost,
            fixed_cost2,
            facility_cost,
            facility_cost2,
            item_travel_distance,
            source_count,
            risk_item_count,
            ctb_make_order_cnt,
            total_make_order_cnt,
            avail_component_qty,
            total_component_qty,
            ready_to_build_qty,
            total_build_qty,
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
            nvl(customer_id, -23453),
            nvl(customer_site_id, -23453),
            nvl(customer_region_id, -23453),
            nvl(supplier_id, -23453),
            nvl(supplier_site_id, -23453),
            nvl(supplier_region_id, -23453),
            decode(p_plan_type, 4, 1, 0) io_plan_flag,
            ship_method,
            detail_date,
            revenue,
            revenue2,
            manufacturing_cost,
            manufacturing_cost2,
            purchasing_cost,
            purchasing_cost2,
            transportation_cost,
            transportation_cost2,
            carrying_cost,
            carrying_cost2,
            supply_chain_cost,
            supply_chain_cost2,
            gross_margin,
            gross_margin2,
            fixed_cost,
            fixed_cost2,
            facility_cost,
            facility_cost2,
            item_travel_distance,
            source_count,
            risk_item_count,
            ctb_make_order_cnt,
            total_make_order_cnt,
            avail_component_qty,
            total_component_qty,
            ready_to_build_qty,
            total_build_qty,
            0, -23453, -23453,
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_costs_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_phub_cost_pkg.import_costs_f: inserted='||sql%rowcount);
        commit;

        summarize_costs_f(errbuf, retcode, p_plan_id, p_plan_run_id);

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_phub_cost_pkg.import_costs_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_phub_cost_pkg.import_costs_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end import_costs_f;

    procedure migrate
    is
        l_applsys_schema  varchar2(100);
        l_msc_schema  varchar2(100);
        e_migrate exception;
        dummy1 varchar2(100);
        dummy2 varchar2(100);
        l_sql varchar2(2000);

        l_costs_f varchar2(30) := 'MSC_COSTS_F';
        l_next_id number;

        cursor c2 is
        select distinct plan_run_id
        from msc_item_inventory_f f
        where not exists (select 1 from msc_costs_f where plan_run_id=f.plan_run_id)
        order by plan_run_id;
    begin
        msc_phub_util.log('msc_phub_cost_pkg.migrate');

        if (fnd_installation.get_app_info('FND',
            dummy1, dummy2, l_applsys_schema) = false) then
            msc_phub_util.log('get_app_info(FND) failed');
            raise e_migrate;
        end if;

        if (fnd_installation.get_app_info('MSC',
            dummy1, dummy2, l_msc_schema) = false) then
            msc_phub_util.log('get_app_info(MSC) failed');
            raise e_migrate;
        end if;

        for r in c2
        loop
            l_sql :=
                ' select nvl(min(partition_id), -1) next_id'||
                ' from'||
                '     (select to_number(substr(partition_name, length(:table_name)-2)) partition_id'||
                '     from sys.all_tab_partitions'||
                '     where table_name=:table_name) t'||
                ' where partition_id>=:plan_run_id';

            execute immediate l_sql into l_next_id using 'MSC_COSTS_F', 'MSC_COSTS_F', r.plan_run_id;


            --msc_phub_util.log(r.plan_run_id||','||l_next_id);
            if (l_next_id=-1) then
                l_sql := 'alter table '||l_costs_f||
                    ' add partition '||substr(l_costs_f, 5)||'_'||to_char(r.plan_run_id)||
                    ' values less than ('||to_char(r.plan_run_id+1)||')';

                ad_ddl.do_ddl(l_applsys_schema, l_msc_schema,
                    ad_ddl.alter_table, l_sql, l_costs_f);
                --msc_phub_util.log(l_sql);
            end if;

            l_sql :=
                ' insert into msc_costs_f ('||
                '     plan_id,'||
                '     plan_run_id,'||
                '     sr_instance_id,'||
                '     organization_id,'||
                '     inventory_item_id,'||
                '     owning_org_id,'||
                '     owning_inst_id,'||
                '     source_org_instance_id,'||
                '     source_organization_id,'||
                '     customer_id,'||
                '     customer_site_id,'||
                '     customer_region_id,'||
                '     supplier_id,'||
                '     supplier_site_id,'||
                '     supplier_region_id,'||
                '     ship_method,'||
                '     detail_date,'||
                '     io_plan_flag,'||
                '     aggr_type,'||
                '     category_set_id,'||
                '     sr_category_id,'||
                '     revenue,'||
                '     revenue2,'||
                '     manufacturing_cost,'||
                '     manufacturing_cost2,'||
                '     purchasing_cost,'||
                '     purchasing_cost2,'||
                '     transportation_cost,'||
                '     transportation_cost2,'||
                '     carrying_cost,'||
                '     carrying_cost2,'||
                '     supply_chain_cost,'||
                '     supply_chain_cost2,'||
                '     gross_margin,'||
                '     gross_margin2,'||
                '     created_by, creation_date,'||
                '     last_updated_by, last_update_date, last_update_login'||
                ' )'||
                ' select'||
                '     plan_id,'||
                '     plan_run_id,'||
                '     sr_instance_id,'||
                '     organization_id,'||
                '     inventory_item_id,'||
                '     owning_org_id,'||
                '     owning_inst_id,'||
                '     to_number(-23453) source_org_instance_id,'||
                '     to_number(-23453) source_organization_id,'||
                '     to_number(-23453) customer_id,'||
                '     to_number(-23453) customer_site_id,'||
                '     to_number(-23453) customer_region_id,'||
                '     to_number(-23453) supplier_id,'||
                '     to_number(-23453) supplier_site_id,'||
                '     to_number(-23453) supplier_region_id,'||
                '     ship_method,'||
                '     order_date detail_date,'||
                '     io_plan_flag,'||
                '     aggr_type,'||
                '     category_set_id,'||
                '     sr_category_id,'||
                '     revenue,'||
                '     revenue2,'||
                '     manufacturing_cost,'||
                '     manufacturing_cost2,'||
                '     purchasing_cost,'||
                '     purchasing_cost2,'||
                '     transportation_cost,'||
                '     transportation_cost2,'||
                '     carrying_cost,'||
                '     carrying_cost2,'||
                '     supply_chain_cost,'||
                '     supply_chain_cost2,'||
                '     gross_margin,'||
                '     gross_margin2,'||
                '     fnd_global.user_id, sysdate,'||
                '     fnd_global.user_id, sysdate, fnd_global.login_id'||
                ' from msc_item_inventory_f'||
                ' where plan_run_id=:p_plan_run_id';

            execute immediate l_sql using r.plan_run_id;
            --msc_phub_util.log('insert: plan_run_id='||r.plan_run_id||', rowcount='||sql%rowcount);
            commit;

            if (l_next_id>r.plan_run_id) then
                l_sql := 'alter table '||l_costs_f||
                    ' split partition '||substr(l_costs_f, 5)||'_'||to_char(l_next_id)||
                    ' at ('||to_char(r.plan_run_id+1)||')'||
                    ' into (partition '||substr(l_costs_f, 5)||'_'||to_char(r.plan_run_id)||', '||
                    ' partition '||substr(l_costs_f, 5)||'_'||to_char(l_next_id)||')';

                ad_ddl.do_ddl(l_applsys_schema, l_msc_schema,
                    ad_ddl.alter_table, l_sql, l_costs_f);
                --msc_phub_util.log(l_sql);
            end if;
        end loop;
        msc_phub_util.log('msc_phub_cost_pkg.migrate complete');

    exception
        when others then
            msc_phub_util.log('msc_phub_cost_pkg.migrate.exception:'||sqlerrm);
            raise;
    end migrate;

    function need_migrate return number
    is
        l_n1 number := 0;
        l_n2 number := 0;
        l_sql varchar2(2000);
        e_need_migrate exception;
    begin
        -- test whether 12.1 columns exist
        begin
            l_sql := 'select count(*) from msc_item_inventory_f where rownum=1 and gross_margin2=0';
            execute immediate l_sql into l_n1;
        exception
            when others then
                return 0;
        end;

        l_sql :=
            ' select count(*)'||
            ' from sys.all_tab_partitions'||
            ' where table_name=:table_name'||
            ' and partition_name<>:base_partition_name'||
            ' and rownum=1';

        execute immediate l_sql into l_n1 using 'MSC_ITEM_INVENTORY_F', 'ITEM_INVENTORY_F_0';
        execute immediate l_sql into l_n2 using 'MSC_COSTS_F', 'COSTS_F_0';
        return (case when l_n1=1 and l_n2=0 then 1 else 0 end);
    end;

end msc_phub_cost_pkg;

/
