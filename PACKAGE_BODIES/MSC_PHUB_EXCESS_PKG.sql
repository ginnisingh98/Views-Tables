--------------------------------------------------------
--  DDL for Package Body MSC_PHUB_EXCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_PHUB_EXCESS_PKG" as
/* $Header: MSCHBESB.pls 120.2.12010000.3 2010/04/05 15:00:46 wexia noship $ */

    procedure populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
          p_plan_id number, p_plan_run_id number)
      is
      l_sysdate date;
      l_user_id number;
      l_user_login_id number;
      l_cp_login_id number;
      l_program_id number;
      l_appl_id number;
      l_request_id number;
      l_plan_start_date date;
      l_plan_cutoff_date date;
      l_plan_type number;
      l_sr_instance_id number;
      l_item_simulation_set_id number;
      l_qid_vmi number;
      l_sim_plan_id number;
      l_owning_currency_code varchar2(20) := msc_phub_util.get_owning_currency_code(p_plan_run_id);
    begin
       msc_phub_util.log('msc_phub_excess_pkg.populate_details');
       retcode := 0;
       errbuf := null;
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



       if l_plan_type in (101,102,103,105) then

            begin
                select simulation_set_id
                into l_item_simulation_set_id
                from msc_plans
                where plan_id=p_plan_id;

                select plan_id
                into l_sim_plan_id
                from msc_rp_simulation_sets
                where simulation_set_id=l_item_simulation_set_id;
            exception
                when others then null;
            end;

            msc_phub_util.log('msc_phub_excess_pkg.populate_details: '||
                'l_item_simulation_set_id='||l_item_simulation_set_id||', '||
                'l_sim_plan_id='||l_sim_plan_id);

            if l_item_simulation_set_id is null then
              return;
            end if;

            select msc_hub_query_s.nextval into l_qid_vmi      from dual;
            insert into msc_hub_query(
                 query_id,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login,
                 date1, -- OBSOLESCENCE_DATE
                 number3,    -- sr_instance_id
                 number4,    -- organization_id
                 number5,        -- inventory_item_id
                 number7,  -- excess_horizon
                 number8   -- standard_cost
                 )
             select
                 unique l_qid_vmi,
                 l_sysdate,
                 1,
                 l_sysdate,
                 1,
                 1,
                 msi.obsolescence_date,
                 msi.sr_instance_id,
                 msi.organization_id,
                 msi.inventory_item_id,
                 msi.excess_horizon,
                 msi.standard_cost
             from  msc_system_items msi
                 where msi.plan_id=l_sim_plan_id
                 and nvl(msi.simulation_set_id, -23453)=l_item_simulation_set_id;

            msc_phub_util.log('l_qid_vmi='||l_qid_vmi||', count='||sql%rowcount);
            commit;
           else
            if (l_plan_type=6) then
                select fnd_profile.value('MSC_APCC_SNO_ITEM_SIMULATION_SET')
                into l_item_simulation_set_id
                from dual;
            else
                select item_simulation_set_id
                into l_item_simulation_set_id
                from msc_plans
                where plan_id=p_plan_id;
            end if;

            msc_phub_util.log('msc_phub_excess_pkg.populate_details: '||
                'l_item_simulation_set_id='||l_item_simulation_set_id);

            if l_item_simulation_set_id is null then
                return;
            end if;

            select msc_hub_query_s.nextval into l_qid_vmi from dual;
            insert into msc_hub_query(
                query_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                date1, -- OBSOLESCENCE_DATE
                number3,    -- sr_instance_id
                number4,    -- organization_id
                number5,        -- inventory_item_id
                number7,  -- excess_horizon
                number8   -- standard_cost
            )
            select
                unique l_qid_vmi,
                l_sysdate,
                1,
                l_sysdate,
                1,
                1,
                mia.obsolescence_date,
                mia.sr_instance_id,
                mia.organization_id,
                mia.inventory_item_id,
                mia.excess_horizon,
                nvl(mia.standard_cost, msi.standard_cost)
            from  msc_item_attributes mia, msc_system_items msi
            where mia.plan_id=-1
                and mia.simulation_set_id=l_item_simulation_set_id
                and msi.plan_id=p_plan_id
                and mia.sr_instance_id=msi.sr_instance_id
                and mia.organization_id=msi.organization_id
                and mia.inventory_item_id=msi.inventory_item_id;

            /*  and (msi.obsolescence_date is not null or  msi.excess_horizon is not null);*/
            msc_phub_util.log('l_qid_vmi='||l_qid_vmi||', count='||sql%rowcount);
            commit;
        end if;


        insert into msc_items_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            aggr_type,
            category_set_id,
            sr_category_id,
            dmd_within_obs_horizon,
            dmd_within_excess_horizon,
            excess_onhand,
            excess_onorder,
            obsolete_onhand,
            obsolete_onorder,
            total_excess,
            total_obs,
            excess_from_onhand_value,
            excess_from_onorder_value,
            obsolete_onhand_value,
            obsolete_onorder_value,
            total_excess_value,
            total_obs_value,
            excess_from_onhand_value2,
            excess_from_onorder_value2,
            obsolete_onhand_value2,
            obsolete_onorder_value2,
            total_excess_value2,
            total_obs_value2,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
         select
            sdt.plan_id,
            sdt.plan_run_id,
            sdt.sr_instance_id,
            sdt.organization_id,
            sdt.inventory_item_id,
            to_number(0),
            to_number(-23453),
            to_number(-23453),
            sum(nvl(sdt.dmd_within_obs_horizon,0)) dmd_within_obs_horizon,
            sum(nvl(sdt.dmd_within_excess_horizon,0)) dmd_within_excess_horizon,

            greatest(sum(nvl(sdt.onhand_qty,0)-nvl(sdt.dmd_within_excess_horizon,0)), 0) excess_onhand,
            greatest(sum(nvl(sdt.onorder_qty,0)-nvl(sdt.dmd_within_excess_horizon,0)), 0) excess_onorder,

            greatest(sum(nvl(sdt.onhand_qty,0)-nvl(sdt.dmd_within_obs_horizon,0)), 0) obsolete_onhand,
            greatest(sum(nvl(sdt.onorder_qty,0)-nvl(sdt.dmd_within_obs_horizon,0)), 0) obsolete_onorder,

            greatest(sum(nvl(sdt.onorder_qty,0)-nvl(sdt.dmd_within_excess_horizon,0)), 0) +
                greatest(sum(nvl(sdt.onhand_qty,0)-nvl(sdt.dmd_within_excess_horizon,0)), 0) total_excess,

            greatest(sum(nvl(sdt.onorder_qty,0)-nvl(sdt.dmd_within_obs_horizon,0)), 0) +
                greatest(sum(nvl(sdt.onhand_qty,0)-nvl(sdt.dmd_within_obs_horizon,0)), 0) total_obs,

            greatest(sum(nvl(sdt.onhand_value,0)-nvl(sdt.dmd_within_excess_hor_value,0)), 0) excess_from_onhand_value,
            greatest(sum(nvl(sdt.onorder_value,0)-nvl(sdt.dmd_within_excess_hor_value,0)), 0) excess_from_onorder_value,

            greatest(sum(nvl(sdt.onhand_value,0)-nvl(sdt.dmd_within_obs_hor_value,0)), 0) obsolete_onhand_value,
            greatest(sum(nvl(sdt.onorder_value,0)-nvl(sdt.dmd_within_obs_hor_value,0)), 0) obsolete_onorder_value,

            greatest(sum(nvl(sdt.onhand_value,0)-nvl(sdt.dmd_within_excess_hor_value,0)), 0) +
                greatest(sum(nvl(sdt.onorder_value,0)-nvl(sdt.dmd_within_excess_hor_value,0)), 0) total_excess_value,

            greatest(sum(nvl(sdt.onhand_value,0)-nvl(sdt.dmd_within_obs_hor_value,0)), 0) +
                greatest(sum(nvl(sdt.onorder_value,0)-nvl(sdt.dmd_within_obs_hor_value,0)), 0) total_obs_value,


            greatest(sum((nvl(sdt.onhand_value,0)-nvl(sdt.dmd_within_excess_hor_value,0)) *
                decode(sdt.currency_code, fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))), 0) excess_from_onhand_value2,
            greatest(sum((nvl(sdt.onorder_value,0)-nvl(sdt.dmd_within_excess_hor_value,0)) *
                decode(sdt.currency_code, fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))), 0) excess_from_onorder_value2,

            greatest(sum((nvl(sdt.onhand_value,0)-nvl(sdt.dmd_within_obs_hor_value,0)) *
                decode(sdt.currency_code, fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))), 0) obsolete_onhand_value2,
            greatest(sum((nvl(sdt.onorder_value,0)-nvl(sdt.dmd_within_obs_hor_value,0)) *
                decode(sdt.currency_code, fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))), 0) obsolete_onorder_value2,

            greatest(sum((nvl(sdt.onhand_value,0)-nvl(sdt.dmd_within_excess_hor_value,0)) *
                decode(sdt.currency_code, fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))), 0) +
                greatest(sum((nvl(sdt.onorder_value,0)-nvl(sdt.dmd_within_excess_hor_value,0)) *
                    decode(sdt.currency_code, fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))), 0) total_excess_value2,

            greatest(sum((nvl(sdt.onhand_value,0)-nvl(sdt.dmd_within_obs_hor_value,0)) *
                decode(sdt.currency_code, fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))), 0) +
                greatest(sum((nvl(sdt.onorder_value,0)-nvl(sdt.dmd_within_obs_hor_value,0)) *
                    decode(sdt.currency_code, fnd_profile.value('MSC_HUB_CUR_CODE_RPT'), 1, nvl(mcc.conv_rate,0))), 0) total_obs_value2,

            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            (
            select
                msf.plan_id,
                msf.plan_run_id,
                msf.sr_instance_id,
                msf.organization_id,
                msf.inventory_item_id,
                msf.supply_date detail_date,
                nvl(mtp.currency_code, l_owning_currency_code) currency_code,
                to_number(0) dmd_within_obs_horizon,
                to_number(0) dmd_within_excess_horizon,
                to_number(0) dmd_within_obs_hor_value,
                to_number(0) dmd_within_excess_hor_value,
                sum(decode(msf.supply_type,18, nvl(msf.supply_qty,0),0)) onhand_qty,
                sum(case when msf.supply_type in (1,2,3,8,11,12,14,27,49,53,80)
                    then nvl(msf.supply_qty,0) else 0 end) onorder_qty,
                sum(decode(msf.supply_type,18,nvl(msf.supply_qty,0),0)
                    *nvl(b.number8, nvl(i.standard_cost,0))) onhand_value,
                sum((case when msf.supply_type in (1,2,3,8,11,12,14,27,49,53,80)
                    then nvl(msf.supply_qty,0) else 0 end)
                    *nvl(b.number8, nvl(i.standard_cost,0))) onorder_value
            from msc_supplies_f msf,msc_trading_partners mtp, msc_hub_query b, msc_system_items i
            where msf.plan_id=p_plan_id
                and msf.plan_run_id=p_plan_run_id
                and msf.aggr_type=0
                and b.query_id(+)=l_qid_vmi
                and b.number5(+)=msf.inventory_item_id
                and b.number3(+)=msf.sr_instance_id
                and b.number4(+)=msf.organization_id
                and msf.sr_instance_id(+)=mtp.sr_instance_id
                and msf.organization_id(+)=mtp.sr_tp_id
                and mtp.partner_type(+)=3
                and msf.plan_id=i.plan_id(+)
                and msf.sr_instance_id=i.sr_instance_id(+)
                and msf.organization_id=i.organization_id(+)
                and msf.inventory_item_id=i.inventory_item_id(+)
                and msf.supply_type in (18,1,2,3,8,11,12,14,27,49,53,80)
            group by
                msf.plan_id,
                msf.plan_run_id,
                msf.sr_instance_id,
                msf.organization_id,
                msf.inventory_item_id,
                msf.supply_date,
                nvl(mtp.currency_code, l_owning_currency_code)
            union all
            select
                mdf.plan_id,
                mdf.plan_run_id,
                mdf.sr_instance_id,
                mdf.organization_id,
                mdf.inventory_item_id,
                mdf.order_date detail_date,
                nvl(mtp.currency_code, l_owning_currency_code) currency_code,
                nvl((case when mdf.order_date between l_plan_start_date and nvl(b.date1, l_plan_cutoff_date)
                    then mdf.demand_qty else 0 end),0) dmd_within_obs_horizon,
                nvl((case when mdf.order_date between l_plan_start_date and decode(b.number7, null, l_plan_cutoff_date, l_plan_start_date+b.number7)
                    then mdf.demand_qty else 0 end),0) dmd_within_excess_horizon,
                nvl((case when mdf.order_date between l_plan_start_date and nvl(b.date1, l_plan_cutoff_date)
                    then mdf.demand_qty else 0 end),0)*nvl(b.number8,nvl(i.standard_cost,0)) dmd_within_obs_hor_value,
                nvl((case when mdf.order_date between l_plan_start_date and decode(b.number7, null, l_plan_cutoff_date, l_plan_start_date+b.number7)
                    then mdf.demand_qty else 0 end),0)*nvl(b.number8,nvl(i.standard_cost,0)) dmd_within_excess_hor_value,
                to_number(0) onhand_qty,
                to_number(0) onorder_qty,
                to_number(0) onhand_value,
                to_number(0) onorder_value
            from msc_demands_f mdf, msc_trading_partners mtp, msc_hub_query b, msc_system_items i
            where mdf.plan_id=p_plan_id
                and mdf.plan_run_id=p_plan_run_id
                and mdf.aggr_type=0
                and b.query_id(+)=l_qid_vmi
                and b.number5(+)=mdf.inventory_item_id
                and b.number3(+)=mdf.sr_instance_id
                and b.number4(+)=mdf.organization_id
                and mdf.sr_instance_id=mtp.sr_instance_id(+)
                and mdf.organization_id=mtp.sr_tp_id(+)
                and mtp.partner_type(+)=3
                and mdf.plan_id=i.plan_id(+)
                and mdf.sr_instance_id=i.sr_instance_id(+)
                and mdf.organization_id=i.organization_id(+)
                and mdf.inventory_item_id=i.inventory_item_id(+)
            ) sdt,
            msc_currency_conv_mv mcc
        where sdt.plan_id=p_plan_id
            and mcc.to_currency(+)=fnd_profile.value('MSC_HUB_CUR_CODE_RPT')
            and mcc.from_currency(+)=nvl(sdt.currency_code, l_owning_currency_code)
            and mcc.calendar_date(+)=sdt.detail_date
        group by
            sdt.plan_id,
            sdt.plan_run_id,
            sdt.sr_instance_id,
            sdt.organization_id,
            sdt.inventory_item_id;

        msc_phub_util.log('msc_phub_excess_pkg.populate_details: msc_items_f, rowcount='||sql%rowcount);
        commit;

        summarize_items_f(errbuf, retcode, p_plan_id, p_plan_run_id);

   exception
          when others then
              msc_phub_util.log('msc_phub_cost_pkg.populate_details.exception: '||sqlerrm);
              errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_POPULATE_ERROR')||':'||sqlerrm;
              retcode := 2;
     end;

    procedure summarize_items_f(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_category_set_id1 number := fnd_profile.value('MSC_HUB_CAT_SET_ID_1');
    begin
        msc_phub_util.log('msc_item_pkg.summarize_items_f');
        retcode := 0;
        errbuf := '';

        delete from msc_items_f
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id and aggr_type>0;
        msc_phub_util.log('msc_item_pkg.summarize_items_f, delete='||sql%rowcount);
        commit;

        -- level 1
        insert into msc_items_f (
            plan_id, plan_run_id,
            sr_instance_id, organization_id, inventory_item_id,
            aggr_type, category_set_id, sr_category_id,
            dmd_within_obs_horizon,
            dmd_within_excess_horizon,
            excess_onorder,
            excess_onhand,
            obsolete_onorder,
            obsolete_onhand,
            total_excess,
            excess_from_onhand_value,
            excess_from_onorder_value,
            total_excess_value,
            excess_from_onhand_value2,
            excess_from_onorder_value2,
            total_excess_value2,
            total_obs,
            obsolete_onhand_value,
            obsolete_onorder_value,
            total_obs_value,
            obsolete_onhand_value2,
            obsolete_onorder_value2,
            total_obs_value2,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id)
        -- category (42, 43, 44)
        select
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            to_number(-23453) inventory_item_id,
            to_number(42) aggr_type,
            l_category_set_id1 category_set_id,
            nvl(q.sr_category_id, -23453),
            sum(dmd_within_obs_horizon),
            sum(dmd_within_excess_horizon),
            sum(excess_onorder),
            sum(excess_onhand),
            sum(obsolete_onorder),
            sum(obsolete_onhand),
            sum(total_excess),
            sum(excess_from_onhand_value),
            sum(excess_from_onorder_value),
            sum(total_excess_value),
            sum(excess_from_onhand_value2),
            sum(excess_from_onorder_value2),
            sum(total_excess_value2),
            sum(total_obs),
            sum(obsolete_onhand_value),
            sum(obsolete_onorder_value),
            sum(total_obs_value),
            sum(obsolete_onhand_value2),
            sum(obsolete_onorder_value2),
            sum(total_obs_value2),
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from
            msc_items_f f,
            msc_phub_item_categories_mv q
        where f.plan_id=p_plan_id and f.plan_run_id=p_plan_run_id
            and f.aggr_type=0
            and f.sr_instance_id=q.sr_instance_id(+)
            and f.organization_id=q.organization_id(+)
            and f.inventory_item_id=q.inventory_item_id(+)
            and q.category_set_id(+)=l_category_set_id1
        group by
            f.plan_id, f.plan_run_id,
            f.sr_instance_id, f.organization_id,
            nvl(q.sr_category_id, -23453);

        msc_phub_util.log('msc_item_pkg.summarize_items_f, level1='||sql%rowcount);
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_item_pkg.summarize_demands_f: '||sqlerrm;
            raise;

    end summarize_items_f;

    procedure export_items_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_phub_excess_pkg.export_items_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_items_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_items_f('||
            '     st_transaction_id,'||
            '     error_code,'||
            '     sr_instance_id,'||
            '     organization_id,'||
            '     inventory_item_id,'||
            '     organization_code,'||
            '     item_name,'||
            '     dmd_within_obs_horizon,'||
            '     dmd_within_excess_horizon,'||
            '     excess_onorder,'||
            '     excess_onhand,'||
            '     obsolete_onorder,'||
            '     obsolete_onhand,'||
            '     total_excess,'||
            '     excess_from_onhand_value,'||
            '     excess_from_onorder_value,'||
            '     total_excess_value,'||
            '     excess_from_onhand_value2,'||
            '     excess_from_onorder_value2,'||
            '     total_excess_value2,'||
            '     total_obs,'||
            '     obsolete_onhand_value,'||
            '     obsolete_onorder_value,'||
            '     total_obs_value,'||
            '     obsolete_onhand_value2,'||
            '     obsolete_onorder_value2,'||
            '     total_obs_value2,'||
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
            '     f.dmd_within_obs_horizon,'||
            '     f.dmd_within_excess_horizon,'||
            '     f.excess_onorder,'||
            '     f.excess_onhand,'||
            '     f.obsolete_onorder,'||
            '     f.obsolete_onhand,'||
            '     f.total_excess,'||
            '     f.excess_from_onhand_value,'||
            '     f.excess_from_onorder_value,'||
            '     f.total_excess_value,'||
            '     f.excess_from_onhand_value2,'||
            '     f.excess_from_onorder_value2,'||
            '     f.total_excess_value2,'||
            '     f.total_obs,'||
            '     f.obsolete_onhand_value,'||
            '     f.obsolete_onorder_value,'||
            '     f.total_obs_value,'||
            '     f.obsolete_onhand_value2,'||
            '     f.obsolete_onorder_value2,'||
            '     f.total_obs_value2,'||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_items_f'||l_suffix||' f,'||
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
        msc_phub_util.log('msc_phub_excess_pkg.export_items_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_phub_excess_pkg.export_items_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end export_items_f;

    procedure import_items_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_items_f';
        l_fact_table varchar2(30) := 'msc_items_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_phub_excess_pkg.import_items_f');
        retcode := 0;
        errbuf := null;

        l_result := l_result + msc_phub_util.prepare_fact_dates(
            l_fact_table, 1, null, p_plan_id, p_plan_run_id,
            p_upload_mode, p_overwrite_after_date);

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'sr_instance_id', 'organization_id', 'organization_code');

        l_result := l_result + msc_phub_util.decode_item_key(
            l_staging_table, p_st_transaction_id, 'inventory_item_id', 'item_name');

        msc_phub_util.log('msc_phub_excess_pkg.import_items_f: insert into msc_items_f');
        insert into msc_items_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            dmd_within_obs_horizon,
            dmd_within_excess_horizon,
            excess_onorder,
            excess_onhand,
            obsolete_onorder,
            obsolete_onhand,
            total_excess,
            excess_from_onhand_value,
            excess_from_onorder_value,
            total_excess_value,
            excess_from_onhand_value2,
            excess_from_onorder_value2,
            total_excess_value2,
            total_obs,
            obsolete_onhand_value,
            obsolete_onorder_value,
            total_obs_value,
            obsolete_onhand_value2,
            obsolete_onorder_value2,
            total_obs_value2,
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
            dmd_within_obs_horizon,
            dmd_within_excess_horizon,
            excess_onorder,
            excess_onhand,
            obsolete_onorder,
            obsolete_onhand,
            total_excess,
            excess_from_onhand_value,
            excess_from_onorder_value,
            total_excess_value,
            excess_from_onhand_value2,
            excess_from_onorder_value2,
            total_excess_value2,
            total_obs,
            obsolete_onhand_value,
            obsolete_onorder_value,
            total_obs_value,
            obsolete_onhand_value2,
            obsolete_onorder_value2,
            total_obs_value2,
            0, -23453, -23453,
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_items_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_phub_excess_pkg.import_items_f: inserted='||sql%rowcount);
        commit;

        summarize_items_f(errbuf, retcode, p_plan_id, p_plan_run_id);

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_phub_excess_pkg.import_items_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_phub_excess_pkg.import_items_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end import_items_f;

end msc_phub_excess_pkg;

/
