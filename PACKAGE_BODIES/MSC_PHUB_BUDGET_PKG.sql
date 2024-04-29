--------------------------------------------------------
--  DDL for Package Body MSC_PHUB_BUDGET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_PHUB_BUDGET_PKG" as
/* $Header: MSCHBBDB.pls 120.6.12010000.3 2010/04/21 13:40:24 wexia noship $ */

    procedure populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_owning_currency_code varchar2(20) := msc_phub_util.get_owning_currency_code(p_plan_run_id);
        l_enforce_budget_constraints number;
        l_budget_id number;
        l_budget_value number;

        l_plan_start_date date;
        l_plan_cutoff_date date;
        l_plan_type number;
        l_sr_instance_id number;
        l_organization_id number;

    begin
        msc_phub_util.log('msc_phub_budget_pkg.populate_details:');
        retcode := 0;
        errbuf := null;

        select enforce_budget_constraints, budget_id, budget_value
        into l_enforce_budget_constraints, l_budget_id, l_budget_value
        from msc_plans
        where plan_id=p_plan_id;

        select plan_type, sr_instance_id, organization_id, plan_start_date, plan_cutoff_date
        into l_plan_type, l_sr_instance_id, l_organization_id, l_plan_start_date, l_plan_cutoff_date
        from msc_plan_runs
        where plan_id=p_plan_id
        and plan_run_id=p_plan_run_id;

        msc_phub_util.log('msc_phub_budget_pkg.populate_details: '||
            'l_enforce_budget_constraints='||l_enforce_budget_constraints||
            ',l_budget_id='||l_budget_id||
            ',l_budget_value='||l_budget_value);

        if (nvl(l_enforce_budget_constraints,2) <> 1) then
            msc_phub_util.log('msc_phub_budget_pkg.populate_details: l_enforce_budget_constraints<>1');
            return;
        end if;

        if (l_budget_id is null and l_budget_value is null) then
            msc_phub_util.log('msc_phub_budget_pkg.populate_details: l_budget_id is null and budget_value is null');
            return;
        end if;

        if (l_budget_id > 0) then
            insert into msc_budgets_f (
                plan_id,
                plan_run_id,
                budget_level,
                sr_instance_id,
                organization_id,
                category_set_id,
                category_instance_id,
                sr_category_id,
                budget_value,
                budget_value2,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                program_id,
                program_login_id,
                program_application_id,
                request_id)
            select
                p_plan_id,
                p_plan_run_id,
                t.budget_level,
                t.sr_instance_id,
                t.organization_id,
                t.category_set_id,
                t.category_instance_id,
                t.sr_category_id,
                t.budget_value,
                t.budget_value * decode(t.currency_code,
                    fnd_profile.value('MSC_HUB_CUR_CODE_RPT'),
                    1, nvl(mcc.conv_rate,0)) budget_value2,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.login_id,
                fnd_global.conc_program_id,
                fnd_global.conc_login_id,
                fnd_global.prog_appl_id,
                fnd_global.conc_request_id
            from
                (select
                    -- budget_level: 0:plan 1:org 2:cat 3:org-cat
                    decode(sign(b.organization_id), -1,
                        decode(sign(b.sr_category_id), -1, 0, 2),
                        decode(sign(b.sr_category_id), -1, 1, 3)) budget_level,
                    decode(b.sr_instance_id, -1, -23453, b.sr_instance_id) sr_instance_id,
                    decode(b.organization_id, -1, -23453, b.organization_id) organization_id,
                    nvl(mtp.currency_code, l_owning_currency_code) currency_code,
                    fnd_profile.value('MSR_BUDGET_CATEGORY_SET') category_set_id,
                    b.category_instance_id,
                    b.sr_category_id,
                    b.budget_value
                from
                    msc_inventory_budget_values b,
                    msc_trading_partners mtp
                where budget_id=l_budget_id
                    and b.sr_instance_id=mtp.sr_instance_id(+)
                    and b.organization_id=mtp.sr_tp_id(+)
                    and mtp.partner_type(+)=3
                ) t,
                msc_currency_conv_mv mcc
            where mcc.from_currency(+)=t.currency_code
                and mcc.calendar_date(+)=l_plan_start_date
                and mcc.to_currency(+)=fnd_profile.value('MSC_HUB_CUR_CODE_RPT');
        else
            insert into msc_budgets_f (
                plan_id,
                plan_run_id,
                budget_level,
                sr_instance_id,
                organization_id,
                category_set_id,
                category_instance_id,
                sr_category_id,
                budget_value,
                budget_value2,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login,
                program_id,
                program_login_id,
                program_application_id,
                request_id)
            select
                p_plan_id,
                p_plan_run_id,
                0,
                to_number(-23453),
                to_number(-23453),
                null,
                -1,
                -1,
                budget_value,
                budget_value * decode(currency_code,
                    fnd_profile.value('MSC_HUB_CUR_CODE_RPT'),
                    1, nvl(mcc.conv_rate,0)) budget_value2,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.login_id,
                fnd_global.conc_program_id,
                fnd_global.conc_login_id,
                fnd_global.prog_appl_id,
                fnd_global.conc_request_id
            from
                (select
                    l_budget_value budget_value,
                    l_owning_currency_code currency_code
                from dual), -- inline table for outer join
                msc_currency_conv_mv mcc
            where mcc.from_currency(+)=currency_code
                and mcc.calendar_date(+)=l_plan_start_date
                and mcc.to_currency(+)=fnd_profile.value('MSC_HUB_CUR_CODE_RPT');
        end if;
        msc_phub_util.log('msc_phub_budget_pkg.populate_details: msc_budgets_f, rowcount='||sql%rowcount);
        commit;

    exception
        when others then
            msc_phub_util.log('msc_phub_budget_pkg.populate_details.exception: '||sqlerrm);
            errbuf := msc_phub_util.get_planning_hub_message('MSC_HUB_POPULATE_ERROR')||':'||sqlerrm;
            retcode := 2;
    end populate_details;

    procedure export_budgets_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_dblink varchar2, p_source_version varchar2)
    is
        l_sql varchar2(5000);
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
    begin
        msc_phub_util.log('msc_phub_budget_pkg.export_budgets_f');
        retcode := 0;
        errbuf := null;

        delete from msc_st_budgets_f where st_transaction_id=p_st_transaction_id;
        commit;

        l_sql :=
            ' insert into msc_st_budgets_f('||
            '     st_transaction_id,'||
            '     error_code,'||
            '     sr_instance_id,'||
            '     organization_id,'||
            '     category_set_id,'||
            '     category_instance_id,'||
            '     sr_category_id,'||
            '     organization_code,'||
            '     category_instance_code,'||
            '     category_name,'||
            '     budget_level,'||
            '     budget_value,'||
            '     budget_value2,'||
            '     created_by, creation_date,'||
            '     last_updated_by, last_update_date, last_update_login'||
            ' )'||
            ' select'||
            '     :p_st_transaction_id,'||
            '     0,'||
            '     f.sr_instance_id,'||
            '     f.organization_id,'||
            '     f.category_set_id,'||
            '     f.category_instance_id,'||
            '     f.sr_category_id,'||
            '     mtp.organization_code,'||
            '     mai.instance_code category_instance_code,'||
            '     c.category_name,'||
            '     f.budget_level,'||
            '     f.budget_value,'||
            '     f.budget_value2,'||
            '     fnd_global.user_id, sysdate,'||
            '     fnd_global.user_id, sysdate, fnd_global.login_id'||
            ' from'||
            '     '||l_apps_schema||'.msc_budgets_f'||l_suffix||' f,'||
            '     '||l_apps_schema||'.msc_trading_partners'||l_suffix||' mtp,'||
            '     '||l_apps_schema||'.msc_phub_categories_mv'||l_suffix||' c,'||
            '     '||l_apps_schema||'.msc_apps_instances'||l_suffix||' mai'||
            ' where f.plan_id=:p_plan_id'||
            '     and f.plan_run_id=:p_plan_run_id'||
            '     and mtp.partner_type(+)=3'||
            '     and mtp.sr_instance_id(+)=f.sr_instance_id'||
            '     and mtp.sr_tp_id(+)=f.organization_id'||
            '     and c.sr_instance_id(+)=f.category_instance_id'||
            '     and c.sr_category_id(+)=f.sr_category_id'||
            '     and c.category_set_id(+)=f.category_set_id'||
            '     and mai.instance_id(+)=f.category_instance_id';

        execute immediate l_sql using p_st_transaction_id, p_plan_id, p_plan_run_id;
        commit;
        msc_phub_util.log('msc_phub_budget_pkg.export_budgets_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_phub_budget_pkg.export_budgets_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end export_budgets_f;

    procedure import_budgets_f (
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_st_transaction_id number, p_plan_id number, p_plan_run_id number,
        p_plan_type number, p_plan_start_date date, p_plan_cutoff_date date,
        p_upload_mode number, p_overwrite_after_date date, p_def_instance_code varchar2)
    is
        l_staging_table varchar2(30) := 'msc_st_budgets_f';
        l_fact_table varchar2(30) := 'msc_budgets_f';
        l_result number := 0;
    begin
        msc_phub_util.log('msc_phub_budget_pkg.import_budgets_f');
        retcode := 0;
        errbuf := null;

        l_result := l_result + msc_phub_util.prepare_fact_dates(
            l_fact_table, 1, null, p_plan_id, p_plan_run_id,
            p_upload_mode, p_overwrite_after_date);

        l_result := l_result + msc_phub_util.decode_organization_key(
            l_staging_table, p_st_transaction_id, p_def_instance_code,
            'sr_instance_id', 'organization_id', 'organization_code');

        l_result := l_result + msc_phub_util.decode_category_key(
            l_staging_table, p_st_transaction_id);

        if (p_upload_mode = msc_phub_util.upload_replace) then
            msc_phub_util.log('msc_phub_budget_pkg.import_budgets_f: purge msc_budgets_f');

            delete from msc_budgets_f
            where plan_id=p_plan_id and plan_run_id=p_plan_run_id;
            commit;
        end if;

        msc_phub_util.log('msc_phub_budget_pkg.import_budgets_f: insert into msc_budgets_f');
        insert into msc_budgets_f (
            plan_id,
            plan_run_id,
            sr_instance_id,
            organization_id,
            category_set_id,
            category_instance_id,
            sr_category_id,
            budget_level,
            budget_value,
            budget_value2,
            created_by, creation_date,
            last_updated_by, last_update_date, last_update_login
        )
        select
            p_plan_id,
            p_plan_run_id,
            nvl(sr_instance_id, -1),
            nvl(organization_id, -1),
            nvl(category_set_id, -23453),
            nvl(category_instance_id, -1),
            nvl(sr_category_id, -1),
            budget_level,
            budget_value,
            budget_value2,
            fnd_global.user_id, sysdate,
            fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_st_budgets_f
        where st_transaction_id=p_st_transaction_id and error_code=0;

        msc_phub_util.log('msc_phub_budget_pkg.import_budgets_f: inserted='||sql%rowcount);
        commit;

        if (l_result > 0) then
            retcode := -1;
        end if;

        msc_phub_util.log('msc_phub_budget_pkg.import_budgets_f: complete, retcode='||retcode);

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_phub_budget_pkg.import_budgets_f: '||sqlerrm;
            msc_phub_util.log(errbuf);
    end import_budgets_f;

end msc_phub_budget_pkg;

/
