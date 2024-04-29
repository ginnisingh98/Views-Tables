--------------------------------------------------------
--  DDL for Package Body MSC_PHUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_PHUB_PKG" AS
/* $Header: MSCHBPBB.pls 120.48.12010000.25 2010/03/03 23:43:30 wexia ship $ */

    g_fact_tables object_names := list_plan_fact_tables;

    function meta_info return msc_apcc_fact_type_table
    is
        t msc_apcc_fact_type_table := msc_apcc_fact_type_table();
        n number;
    begin
        t.extend(15);
        t(1) := msc_apcc_fact_type(1, 'msc_supply_pkg', 'supplies', '11.5.10', 'supply_date', 1, 1);
        t(2) := msc_apcc_fact_type(2, 'msc_demand_pkg', 'demands', '11.5.10', 'order_date', 1, 1);
        t(3) := msc_apcc_fact_type(3, 'msc_demand_pkg', 'demands_cum', '11.5.10', 'order_date', 1, 1);
        t(4) := msc_apcc_fact_type(4, 'msc_demantra_pkg', 'demantra_ods', '11.5.10', 'end_date', 4, 1);
        t(5) := msc_apcc_fact_type(5, 'msc_demantra_pkg', 'demantra', '11.5.10', 'start_date', 3, 1);
        t(6) := msc_apcc_fact_type(6, 'msc_exception_pkg', 'exceptions', '11.5.10', 'analysis_date', 1, 1);
        t(7) := msc_apcc_fact_type(7, 'msc_item_pkg', 'item_orders', '11.5.10', 'order_date', 1, 1);
        t(8) := msc_apcc_fact_type(8, 'msc_supply_pkg', 'item_wips', '11.5.10', 'wip_start_date', 2, 1);
        t(9) := msc_apcc_fact_type(9, 'msc_resource_pkg', 'resources', '11.5.10', 'analysis_date', 2, 1);
        t(10) := msc_apcc_fact_type(10, 'msc_supplier_pkg', 'suppliers', '11.5.10', 'analysis_date', 1, 1);
        t(11) := msc_apcc_fact_type(11, 'msc_item_pkg', 'item_inventory', '11.5.10', 'order_date', 1, 1);
        t(12) := msc_apcc_fact_type(12, 'msc_phub_excess_pkg', 'items', '12.1.3', null, 2, 1);
        t(13) := msc_apcc_fact_type(13, 'msc_phub_budget_pkg', 'budgets', '12.1.3', null, 0, 1);
        -- take costs from 11510 msc_item_inventory_f
        t(14) := msc_apcc_fact_type(14, 'msc_phub_cost_pkg', 'costs', '11.5.10', 'detail_date', 1, 1);
        t(15) := msc_apcc_fact_type(15, 'msc_resource_pkg', 'resources_cum', '12.1.3', 'analysis_date', 2, 1);
        return t;
    end;

    function list_plan_fact_tables return object_names
    is
        r object_names;
    begin
        select upper('msc_'||entity_name||'_f') bulk collect into r from table(meta_info) where fact_type<>4;
        return r;
    end;


  procedure println(p_msg varchar2) is
  begin
   --insert into msc_temp_xx (msg) values (p_msg); commit;
    if ( g_log_flag= 0 ) then
      return;
    elsif ( g_log_flag = 1 ) then
      g_log_row := g_log_row + 1;
      if (g_log_file_name is null) then
        select ltrim(rtrim(value))
          into g_log_file_dir
        from (select value from v$parameter2 where name='utl_file_dir'
             order by rownum desc)
        where rownum <2;
       g_log_file_name := 'msc-phub.txt';
       g_log_file_handle := utl_file.fopen(g_log_file_dir, g_log_file_name, 'w');
     end if;

     if (utl_file.is_open(g_log_file_handle)) then
       utl_file.put_line(g_log_file_handle, p_msg);
       utl_file.fflush(g_log_file_handle);
       utl_file.fclose(g_log_file_handle);
     else
       g_log_file_handle := utl_file.fopen(g_log_file_dir, g_log_file_name, 'a');
       utl_file.put_line(g_log_file_handle, p_msg);
       utl_file.fflush(g_log_file_handle);
       utl_file.fclose(g_log_file_handle);
     end if;
   elsif ( g_log_flag = 2 ) then
     fnd_file.put_line(fnd_file.log, p_msg);
   end if;
   --dbms_output.put_line(p_msg);
  exception
   when others then
      return;
  end println;

  function check_apcc_setup return number is
    l_category_set_id1 varchar2(200) := fnd_profile.value('MSC_HUB_CAT_SET_ID_1');
    l_category_set_id2 varchar2(200) := fnd_profile.value('MSC_HUB_CAT_SET_ID_2');
    l_category_set_id3 varchar2(200) := fnd_profile.value('MSC_HUB_CAT_SET_ID_3');
    l_hub_cal_code varchar2(200) := fnd_profile.value('MSC_HUB_CAL_CODE');
    l_hub_pr_set varchar2(200) := fnd_profile.value('MSC_HUB_PERIOD_SET_NAME');
    l_hub_cur_code varchar2(200) := fnd_profile.value('MSC_HUB_CUR_CODE_RPT');
    l_hur_reg_instance varchar2(200) := fnd_profile.value('MSC_HUB_REGION_INSTANCE');
    l_top_bottom_n varchar2(200) := fnd_profile.value('MSC_HUB_TOP_BOTTOM_N_VALUE');
  begin
    if l_category_set_id1 is null then
      return 2;
    end if;
    return 1;
  end check_apcc_setup;

    function submit_each(p_package varchar2, p_plan_id number, p_plan_run_id number)
        return number is
        l_req_id number := 0;
    begin
        msc_phub_util.log('msc_phub_pkg.submit_each: ('||p_package||','||p_plan_id||','||p_plan_run_id||')');
        l_req_id := fnd_request.submit_request('MSC', 'MSCHUBA2', null,
            null, false, p_package, p_plan_id, p_plan_run_id);
        msc_phub_util.log('msc_phub_pkg.submit_each: l_req_id='||l_req_id);
        commit;
        return l_req_id;
    end submit_each;

    function msc_wait_for_request(p_request_id in  number) return number
    is

        l_refreshed_flag           NUMBER;
        l_pending_timeout_flag     NUMBER;
        l_start_time               DATE;

        l_call_status      boolean;
        l_phase            varchar2(80);
        l_status           varchar2(80);
        l_dev_phase        varchar2(80);
        l_dev_status       varchar2(80);
        l_message          varchar2(240);
        l_request_id number;

        l_ctr number := 0;
        l_timeout number := 9999;
    begin
        l_request_id := p_request_id;
        l_start_time := SYSDATE;

        LOOP
            << begin_loop >>
            dbms_lock.sleep(10);
            l_pending_timeout_flag := sign( sysdate - l_start_time - l_timeout/1440.0);
            l_call_status:= fnd_concurrent.wait_for_request(l_request_id,
                10, 10, l_phase, l_status, l_dev_phase, l_dev_status, l_message);
            --msc_phub_util.log(' msc_wait_for_request '||p_request_id||' complete status '||l_request_id||' - '||l_dev_phase||' - '||l_dev_status);
            exit when l_call_status=FALSE;
            if l_dev_phase='PENDING' then
                exit when l_pending_timeout_flag= 1;
            elsif l_dev_phase='RUNNING' then
                GOTO begin_loop;
            elsif l_dev_phase='COMPLETE' then
                if l_dev_status = 'NORMAL' then
                    --msc_phub_util.log(' msc_wait_for_request '||p_request_id||' complete status '||l_request_id||' - '||l_dev_phase||' - '||l_dev_status);
                    return sys_yes;
                end if;
                exit;
            elsif l_dev_phase='INACTIVE' THEN
                exit when l_pending_timeout_flag= 1;
            end if;
            -- dbms_lock.sleep(10);
        end loop;

        return sys_no;
    end msc_wait_for_request;

    function populate_facts(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number) return number is
        l_exceptions_req_id number;
        l_resource_req_id number;
        l_suppliers_req_id number;
        l_supplies_req_id number;
        l_demands_req_id number;
        l_items_req_id number;
        l_budgets_req_id number;
        l_costs_req_id number;
        l_excesss_req_id number;


        l_max_wait_time number := 999999;
    begin
        msc_phub_util.log('msc_phub_pkg.populate_facts');

        l_exceptions_req_id := submit_each('msc_exception_pkg', p_plan_id, p_plan_run_id);
        l_resource_req_id := submit_each('msc_resource_pkg', p_plan_id, p_plan_run_id);
        l_suppliers_req_id := submit_each('msc_supplier_pkg', p_plan_id, p_plan_run_id);
        l_supplies_req_id := submit_each('msc_supply_pkg', p_plan_id, p_plan_run_id);
        l_demands_req_id := submit_each('msc_demand_pkg', p_plan_id, p_plan_run_id);
        l_budgets_req_id := submit_each('msc_phub_budget_pkg', p_plan_id, p_plan_run_id);
        l_costs_req_id := submit_each('msc_phub_cost_pkg', p_plan_id, p_plan_run_id);

        if (msc_wait_for_request(l_supplies_req_id) = sys_no) then
            return sys_no;
        end if;

        if (msc_wait_for_request(l_demands_req_id) = sys_no) then
            return sys_no;
        end if;

        if (msc_wait_for_request(l_exceptions_req_id) = sys_no) then
            return sys_no;
        end if;

        l_items_req_id := submit_each('msc_item_pkg', p_plan_id, p_plan_run_id);
        l_excesss_req_id := submit_each('msc_phub_excess_pkg', p_plan_id, p_plan_run_id);

        if (msc_wait_for_request(l_resource_req_id) = sys_no) then
            return sys_no;
        end if;

        if (msc_wait_for_request(l_suppliers_req_id) = sys_no) then
            return sys_no;
        end if;

        if (msc_wait_for_request(l_items_req_id) = sys_no) then
            return sys_no;
        end if;

        if (msc_wait_for_request(l_budgets_req_id) = sys_no) then
            return sys_no;
        end if;

        if (msc_wait_for_request(l_costs_req_id) = sys_no) then
            return sys_no;
        end if;

        if (msc_wait_for_request(l_excesss_req_id) = sys_no) then
            return sys_no;
        end if;

        return sys_yes;
    end populate_facts;

    procedure manage_partitions(p_tables object_names, p_partition_id number, p_mode number)
    is
        l_partition_name varchar2(300);
        sql_stmt varchar2(300);
        dummy1 varchar2(50);
        dummy2 varchar2(50);
        l_applsys_schema  varchar2(100);
        e_manage_partitions exception;
        retcode number := 0;
        errbuf varchar2(2000);
        partition_does_not_exist exception;
        pragma exception_init (partition_does_not_exist, -2149);
    begin
        msc_phub_util.log('msc_phub_pkg.manage_partitions: '||p_partition_id||','||p_mode);

        if (fnd_installation.get_app_info('FND',
            dummy1, dummy2, l_applsys_schema) = false) then
            retcode := 1;
            fnd_message.set_name('MSC', 'MSC_PART_UNDEFINED_SCHEMA');
            errbuf := fnd_message.get;
            raise e_manage_partitions;
        end if;

        for i in 1..p_tables.count loop
            l_partition_name := substr(p_tables(i), 5)||'_'||to_char(p_partition_id);
            if (p_mode = 1) then
                -- create partitions
                sql_stmt := 'alter table '||p_tables(i)||
                    ' add partition '||l_partition_name||
                    ' values less than ('||to_char(p_partition_id+1)||')';
            elsif (p_mode = 2) then
                --drop partitions
                sql_stmt := 'alter table '||p_tables(i)||' drop partition '||l_partition_name;
            elsif (p_mode = 3) then
                --truncate partitions
                sql_stmt := 'alter table '||p_tables(i)||' truncate partition '||l_partition_name;
            end if;

            begin
                msc_phub_util.log(sql_stmt);
                ad_ddl.do_ddl(l_applsys_schema, 'MSC', ad_ddl.alter_table, sql_stmt, p_tables(i));

            exception
                when partition_does_not_exist then
                    msc_phub_util.log('msc_phub_pkg.manage_partitions: '||sqlerrm);

            end;
        end loop;

    exception
        when others then
            if (retcode = 0) then
                retcode := 1;
                errbuf := sqlerrm;
            end if;
            msc_phub_util.log('msc_phub_pkg.manage_partitions.exception: '||errbuf);
            raise;

    end manage_partitions;

  --lookup values for plan types old and new
  --MSC_PLAN_TYPE
  --1 Manufacturing Plan
  --2 Production Plan
  --3 Master Plan
  --4 Inventory Plan
  --5 Distribution Plan
  --6 Maintenance Schedule
  --7 Manufacturing Schedule
  --8 Service Plan
  --9 Service Inventory Plan

  --MSC_SCN_PLAN_TYPES
  --1 Advanced Supply Chain Planning
  --4 Inventory Optimization
  --5 Distribution Planning
  --6 Strategic Network Optimization
  --8 Service Planning
  --10 Demand Management

    function get_plan_info(p_plan_id number, p_plan_type number) return plan_info
    is
        l_pi plan_info;
    begin
        if (p_plan_type = 10) then
            select
                das.scenario_id,
                substr(das.scenario_name, 1, 50),
                substr(das.scenario_name, 1, 100),
                to_number(10),
                decode(das.sr_instance_id, -23453, o.sr_instance_id, das.sr_instance_id),
                decode(das.organization_id, -23453, o.sr_tp_id, das.organization_id),
                tq.from_date, tq.until_date,
                nvl(dsr.last_update_date, sysdate)
            into l_pi
            from
                msd_dp_ascp_scenarios_v das,
                msd_dp_scenario_revisions dsr,
                msd_dem_transfer_query tq,
                (select mtp.sr_instance_id, mtp.sr_tp_id
                from msc_trading_partners mtp, msd_dem_app_instance_orgs daio
                where daio.organization_id=nvl(fnd_profile.value('MSD_DEM_MASTER_ORG'), -23453)
                and mtp.organization_code=daio.organization_code
                and mtp.partner_type=3
                union all select to_number(-23453), to_number(-23453) from dual) o
            where das.demand_plan_id=5555555
                and das.demand_plan_name=substr(tq.query_name, 1, 30)
                and das.scenario_id=p_plan_id
                and das.scenario_id=dsr.scenario_id(+)
                and das.last_revision=dsr.revision(+)
                and rownum=1;
        else
            select
                p.plan_id,
                p.compile_designator,
                p.description,
                (case when p.plan_type in (1,2,3) then 1
                    when p.curr_plan_type in (101,102,103,105) then 101
                    else nvl(p.plan_type, -1) end) plan_type,
                p.sr_instance_id,
                p.organization_id,
                trunc(nvl(b.bkt_start_date, p.curr_start_date)),
                trunc(nvl(b.bkt_end_date, p.curr_cutoff_date)),
                nvl(p.plan_completion_date, sysdate)
            into l_pi
            from msc_plans p,
                (select plan_id, min(bkt_start_date) bkt_start_date, max(bkt_end_date) bkt_end_date
                from msc_plan_buckets
                where curr_flag=1
                group by plan_id
                ) b
            where p.plan_id=p_plan_id
                and p.plan_id=b.plan_id(+);
        end if;
        return l_pi;

    exception
        when others then
            msc_phub_util.log('msc_phub_pkg.get_plan_info.exception: '||sqlerrm);
            raise;
    end;

    function populate_plan_run_info(p_plan_id number,
        p_plan_type number default null,
        p_scenario_name varchar2 default null,
        p_local_archive_flag number default sys_yes,
        p_pi plan_info default null)
        return number
    is
        l_pi plan_info;
        l_plan_run_id number;
        l_plan_version number;
        l_plan_run_name varchar2(100);
        l_local_archive_flag number;
    begin
        msc_phub_util.log('msc_phub_pkg.populate_plan_run_info('||
            p_plan_id||','||p_plan_type||','||
            p_scenario_name||','||p_local_archive_flag||')');

        -- check local_archive_flag
        begin
            select local_archive_flag into l_local_archive_flag
            from msc_plan_runs
            where plan_id=p_plan_id;
        exception
            when others then null;
        end;

        if (l_local_archive_flag is not null and
            l_local_archive_flag <> p_local_archive_flag) then
            msc_phub_util.log('msc_phub_pkg.populate_plan_run_info: mismatch '||
                'l_local_archive_flag='||l_local_archive_flag||
                ', p_local_archive_flag='||p_local_archive_flag);
            return null;
        end if;

        if (p_local_archive_flag = sys_yes) then
            l_pi := get_plan_info(p_plan_id, p_plan_type);
        else
            l_pi := p_pi;
        end if;

        select msc_plan_runs_s.nextval into l_plan_run_id from dual;
        select count(*) into l_plan_version from msc_plan_runs where plan_id=l_pi.plan_id;

        l_plan_run_name := l_pi.plan_name||
            to_char(sysdate, ' MM/DD')||'('||l_plan_version||')';

        if p_scenario_name is not null then
            l_plan_run_name := l_plan_run_name||' ['||p_scenario_name||']';
        end if;

        insert into msc_plan_runs (
            plan_id, plan_run_id, plan_run_name, sr_instance_id, organization_id,
            plan_name, plan_type, plan_description,
            plan_start_date, plan_cutoff_date, plan_completion_date,
            start_date, end_date, last_run_flag,
            planning_hub_flag, archive_flag, local_archive_flag,
            created_by, creation_date, last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id, program_application_id, request_id
        )
        values (
            l_pi.plan_id, l_plan_run_id, l_plan_run_name,
            l_pi.sr_instance_id, l_pi.organization_id,
            l_pi.plan_name, l_pi.plan_type, l_pi.plan_description,
            l_pi.plan_start_date, l_pi.plan_cutoff_date, l_pi.plan_completion_date,
            sysdate, null, sys_no, sys_no, sys_no, p_local_archive_flag,
            fnd_global.user_id, sysdate, sysdate, fnd_global.user_id, fnd_global.user_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id, fnd_global.prog_appl_id, fnd_global.conc_request_id
        );
        commit;

        msc_phub_util.log('msc_phub_pkg.populate_plan_run_info('||l_pi.plan_id||', '||l_plan_run_id||
            ', '''||l_plan_run_name||''')');
        return l_plan_run_id;
    end populate_plan_run_info;

    procedure purge_previous_plan_run(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number)
    is
        l_prev_plan_run_id number;
        l_max_wait_time number := 999999;
        l_request_id number;
    begin
        msc_phub_util.log('msc_phub_pkg.purge_previous_plan_run('||p_plan_id||','||p_plan_run_id||')');
        retcode := 0;
        errbuf := null;

        select max(plan_run_id)
        into l_prev_plan_run_id
        from msc_plan_runs
        where plan_id=p_plan_id
        and plan_run_id<p_plan_run_id
        and nvl(archive_flag,sys_no)=sys_yes;

        if (l_prev_plan_run_id is not null) then
            l_request_id := fnd_request.submit_request('MSC','MSCHUBP',
                null, null, false, p_plan_id, l_prev_plan_run_id);
            commit;

            msc_phub_util.log('msc_phub_pkg.purge_previous_plan_run, MSCHUBFP('||
                p_plan_id||','||l_prev_plan_run_id||'), l_request_id='||l_request_id);

            /*
            if (msc_wait_for_request(l_request_id) = sys_no) then
                retcode := 2;
                errbuf := 'msc_phub_pkg.purge_previous_plan_run: msc_wait_for_request failed';
            end if;
            */
        else
            msc_phub_util.log('msc_phub_pkg.purge_previous_plan_run, l_prev_plan_run_id='||l_prev_plan_run_id);
        end if;

    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_pkg.purge_previous_plan_run.exception: '||sqlerrm;
            end if;
            raise;

    end purge_previous_plan_run;

    function remote_context_sql(p_dblink varchar2, p_sql varchar2) return varchar2
    is
        l_apps_schema varchar2(30) := msc_phub_util.apps_schema;
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
    begin
        execute immediate 'select sysdate from dual'||l_suffix;

        return
            ' declare'||
            '     l_user_id number;'||
            '     l_responsibility_id number;'||
            '     l_application_id number;'||
            ' begin'||
            '     select user_id into l_user_id'||
            '     from '||l_apps_schema||'.fnd_user'||l_suffix||
            '     where user_name=fnd_global.user_name;'||
            ' '||
            '     select responsibility_id into l_responsibility_id'||
            '     from '||l_apps_schema||'.fnd_responsibility'||l_suffix||
            '     where responsibility_key=('||
            '         select responsibility_key from fnd_responsibility'||
            '         where responsibility_id=fnd_global.resp_id);'||
            ' '||
            '     select application_id into l_application_id'||
            '     from '||l_apps_schema||'.fnd_application'||l_suffix||
            '     where application_short_name=fnd_global.application_short_name;'||
            ' '||
            '     '||l_apps_schema||'.fnd_global.apps_initialize'||l_suffix||'('||
            '         l_user_id, l_responsibility_id, l_application_id);'||
            '     '||p_sql||
            ' end;';

    exception
        when others then
            msc_phub_util.log('msc_phub_pkg.remote_context_sql.exception: '||sqlerrm);
            fnd_message.set_name('MSC', 'MSC_APCC_DBLINK_E01');
            fnd_message.set_token('DBLINK', p_dblink);
            msc_phub_util.log(fnd_message.get);
            raise;
    end remote_context_sql;

    procedure publish_to_central_apcc(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number,
        p_target_plan_name varchar2, p_dblink varchar2,
        p_include_ods number, p_archive_flag number)
    is
        l_db_name varchar2(30) := fnd_profile.value('MSC_APCC_BACK_TO_SELF_DBLINK');
        l_sql varchar2(2000);
        l_pi plan_info;
        l_suffix varchar2(32) := msc_phub_util.suffix(p_dblink);
        l_request_id number;
        l_upload_mode number := 3;
    begin
        retcode := 0;
        errbuf := null;
        msc_phub_util.log('msc_phub_pkg.publish_to_central_apcc('||p_plan_id
            ||','||p_plan_run_id||','||p_target_plan_name
            ||','||p_dblink||','||p_include_ods||','||p_archive_flag||')');

        if (l_db_name is null) then
            select value into l_db_name from v$parameter where name='db_name';
        end if;
        msc_phub_util.log('msc_phub_pkg.publish_to_central_apcc:l_db_name='||l_db_name);

        select
            plan_id,
            plan_name,
            plan_description,
            plan_type,
            sr_instance_id,
            organization_id,
            plan_start_date,
            plan_cutoff_date,
            plan_completion_date
        into l_pi
        from msc_plan_runs
        where plan_id=p_plan_id and plan_run_id=p_plan_run_id;

        if (p_archive_flag = 2) then
            l_upload_mode := 4;
        end if;

        l_sql :=
            ' :1 := fnd_request.submit_request'||l_suffix||'('||
            '     ''MSC'', ''MSCHUBFI'', null, null, false,'||
            '     :transfer_id, :debug_level, :source_plan_id, :source_plan_run_id,'||
            '     :source_db_link, :source_version, :target_plan_name,'||
            '     :plan_description, :plan_type, :directory, :upload_mode, :include_ods,'||
            '     :instance_code, :organization_code, :plan_start_date, :plan_cutoff_date);';

        execute immediate remote_context_sql(p_dblink, l_sql) using out l_request_id,
            to_number(null), to_number(null), p_plan_id, p_plan_run_id,
            l_db_name, msc_phub_util.g_version, nvl(p_target_plan_name, l_pi.plan_name),
            l_pi.plan_description, l_pi.plan_type, to_char(null), l_upload_mode, p_include_ods,
            msc_get_name.instance_code(l_pi.sr_instance_id),
            msc_get_name.org_code(l_pi.organization_id, l_pi.sr_instance_id),
            to_char(l_pi.plan_start_date), to_char(l_pi.plan_cutoff_date);

        commit;

        fnd_message.set_name('MSC', 'MSC_APCC_REMOTE_CONFIRM');
        fnd_message.set_token('DBLINK', p_dblink);
        fnd_message.set_token('REQ_ID', l_request_id);
        msc_phub_util.log(fnd_message.get);

    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_pkg.publish_to_central_apcc.exception: '||sqlerrm;
            end if;
            msc_phub_util.log(errbuf);
    end publish_to_central_apcc;


    procedure populate_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number,
        p_plan_run_id number default null,
        p_archive_flag number default sys_yes,
        p_target_plan_name varchar2 default null,
        p_dblink varchar2 default null,
        p_include_ods number default sys_no,
        p_plan_type number default null,
        p_scenario_name in varchar2 default null)
    is
        l_plan_run_id number;
        l_return_status number := sys_yes;
        l_purge_req_id number;
        l_etl_flag number := sys_no;

        l_plan_type number;
        l_display_kpi number;
        e_populate_details exception;

        l_local_archive_flag number := sys_no;
        l_max_wait_time number := 999999;
        l_request_id number;
        l_demantra_flag number := sys_no;
    begin
        retcode := 0;
        errbuf := null;

        fnd_message.set_name('MSC', 'MSC_HUB_POPULATE_STARTS');
        msc_phub_util.log(fnd_message.get);

        msc_phub_util.log('msc_phub_pkg.populate_details('||
            p_plan_id||','||
            p_plan_run_id||','||
            p_archive_flag||','||
            p_target_plan_name||','||
            p_dblink||','||
            p_include_ods||','||
            p_plan_type||')');

        if (p_plan_type = 10 or (p_plan_type is null and p_plan_id > 5555555)) then
            l_demantra_flag := sys_yes;
            l_plan_type := 10;
        end if;

        -- check_apcc_setup
        if (check_apcc_setup = 2) then
            retcode := 1;
            errbuf := fnd_message.get_string('MSC', 'MSC_APCC_INVALID_PROFILE');
            raise e_populate_details;
        end if;

        -- validate inputs
        if (p_plan_id=-1) then
            msc_phub_util.log('msc_phub_pkg.populate_details: (p_plan_id=-1)');
            return;
        end if;

        begin
            select max(local_archive_flag) into l_local_archive_flag
            from msc_plan_runs
            where plan_id=p_plan_id and plan_run_id=nvl(p_plan_run_id,plan_run_id);
        exception
            when others then null;
        end;

        if (l_local_archive_flag = 2) then
            fnd_message.set_name('MSC', 'MSC_APCC_PLAN_INFO_E01');
            retcode := 1;
            errbuf := 'msc_phub_pkg.populate_details: '||fnd_message.get;
            raise e_populate_details;
        end if;

        -- populate_plan_run_info
        if (p_plan_run_id is null) then
            l_plan_run_id := populate_plan_run_info(p_plan_id, p_plan_type, p_scenario_name);
        else
            l_plan_run_id := p_plan_run_id;
        end if;

        if (l_plan_run_id is null) then
            msc_phub_util.log('msc_phub_pkg.populate_details: (l_plan_run_id is null)');
            return;
        end if;

        if (l_demantra_flag = sys_yes) then
            l_etl_flag := sys_yes;
        else
            select curr_plan_type, nvl(display_kpi,1)
            into l_plan_type, l_display_kpi
            from msc_plans
            where plan_id=p_plan_id;

            if ((l_display_kpi = 1 and l_plan_type not in (5)) or l_plan_type in (6,101,102,103,105)) then
                l_etl_flag := sys_yes;

                -- build item dimension
                build_items_from_pds(p_plan_id);
            end if;

        end if;

        if (l_etl_flag = sys_yes) then  --(

            --managing partitions
            manage_partitions(g_fact_tables, l_plan_run_id, 1);

            -- this will refresh all mvs for now, but we need to place this call in collections conc program also
            --pabram need to move collections mv refresh later, need to move this code after populate_facts
            -- bug 6836759 , comment out refresh_mvs(3) for now
            --bug 6665805, collections is calling this api after collections run, commenting this 051308
            --refresh_mvs(3);

            --populate fact/summary tables
            if (l_demantra_flag = sys_yes) then
                msc_demantra_pkg.populate_details(errbuf, retcode, p_plan_id, l_plan_run_id);
            else
                if (populate_facts(errbuf, retcode, p_plan_id, l_plan_run_id) = sys_no) then
                    retcode := 1;
                    errbuf := 'Error while populating the fact tables. purging this plan summary. ';
                    msc_phub_util.log(errbuf);

                    --purge_details(l_purge_errbuf, l_purge_retcode, p_plan_id, l_plan_run_id);
                    l_purge_req_id := fnd_request.submit_request('MSC','MSCHUBP',NULL, NULL, FALSE, p_plan_id, l_plan_run_id);
                    l_return_status := sys_no;
                    commit;
                end if;
            end if;
        end if;  --}

        -- finalize_plan_run
        finalize_plan_run(errbuf, retcode, p_plan_id, l_plan_run_id, l_etl_flag, l_return_status, p_archive_flag);

        if (l_return_status = sys_yes) then
            /*
            -- build item dimension
            if (l_demantra_flag = sys_yes) then
                build_items_from_apcc(p_plan_id, p_plan_run_id);
            end if;
            */

            -- publish_to_central_apcc
            if (p_dblink is not null) then
                publish_to_central_apcc(errbuf, retcode, p_plan_id, l_plan_run_id,
                    p_target_plan_name, p_dblink, p_include_ods, p_archive_flag);
            end if;

        end if;

        fnd_message.set_name('MSC', 'MSC_HUB_POPULATE_ENDS');
        msc_phub_util.log(fnd_message.get);

    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_pkg.populate_details: '||sqlerrm;
            end if;
            msc_phub_util.log(errbuf);

    end populate_details;

    procedure purge_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number default null) is

        cursor c is
            select plan_run_id
            from msc_plan_runs
            where plan_id = p_plan_id
            and plan_run_id = nvl(p_plan_run_id, plan_run_id)
            union
            select p_plan_run_id from dual where p_plan_run_id is not null;

    begin
        msc_phub_util.log('msc_phub_pkg.purge_details');
        retcode := 0;
        errbuf := null;

        for r in c loop
            manage_partitions(g_fact_tables, r.plan_run_id, 2);

            update msc_plan_runs set
                planning_hub_flag = sys_no,
                last_run_flag = sys_no,
                archive_flag = sys_no,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id,
                program_id = fnd_global.conc_program_id,
                program_login_id = fnd_global.conc_login_id,
                program_application_id = fnd_global.prog_appl_id,
                request_id = fnd_global.conc_request_id
            where plan_run_id = r.plan_run_id;
            commit;
        end loop;

        update msc_plan_runs
        set last_run_flag=1
        where plan_run_id=(
            select max(plan_run_id)
            from msc_plan_runs
            where plan_id=p_plan_id
            and archive_flag=1
        );

        if (p_plan_run_id is null) then
            purge_items(p_plan_id);
        end if;

        msc_phub_util.log('msc_phub_pkg.purge_details: complete');
    end purge_details;

   procedure refresh_one_mv(p_name varchar2) is
   begin
     dbms_mview.refresh(p_name);
   end refresh_one_mv;

   procedure refresh_ods_mvs(errbuf out nocopy varchar2, retcode out nocopy varchar2) is
     l_ods_table_list object_names := object_names(
       'MSC_PHUB_DATES_MV',
       'MSC_PHUB_CATEGORIES_MV',
       'MSC_PHUB_ITEM_CATEGORIES_MV',
       'MSC_PHUB_CUSTOMERS_MV',
       'MSC_PHUB_SUPPLIERS_MV',
       'MSC_CURRENCY_CONV_MV',
       'MSC_PHUB_PROJECTS_MV',
       'MSC_PHUB_RESOURCES_MV'
     );
     l_name varchar2(50);

    p_return_status number;
    p_error_message varchar2(2000);
   begin
     for i in 1..l_ods_table_list.count loop
       l_name := l_ods_table_list(i);
       msc_phub_util.log('Refreshing MV : '||l_name||' starts');
       refresh_one_mv(l_name);
       msc_phub_util.log('Refreshing MV : '||l_name||' ends');
     end loop;

     build_items_from_pds(-1);

     exception
       when others then
         retcode := 1;
         errbuf := 'Error while Refreshing MV :'||l_name||': '||sqlerrm;
     msc_phub_util.log(errbuf);
   end refresh_ods_mvs;

   procedure refresh_pds_mvs(errbuf out nocopy varchar2, retcode out nocopy varchar2) is
     l_pds_table_list object_names := object_names(
      -- 'MSC_DEMANDS_F_MV'
     );
     l_name varchar2(50);
   begin
     for i in 1..l_pds_table_list.count loop
       l_name := l_pds_table_list(i);
       msc_phub_util.log('Refreshing MV : '||l_name||' starts');
       refresh_one_mv(l_name);
       msc_phub_util.log('Refreshing MV : '||l_name||' ends');
     end loop;

     exception
       when others then
         retcode := 1;
         errbuf := 'Error while Refreshing MV : '||l_name;
     msc_phub_util.log(errbuf);
   end refresh_pds_mvs;

    procedure refresh_mvs(p_refresh_mode varchar2)
    is
        errbuf varchar2(1000) := '';
        retcode number := 0;
    begin
        refresh_mvs(errbuf, retcode, p_refresh_mode);
    end refresh_mvs;

    procedure refresh_mvs(errbuf out nocopy varchar2, retcode out nocopy varchar2, p_refresh_mode varchar2) is
    begin
        msc_phub_util.log('msc_phub_pkg.refresh_mvs');
        retcode := 0;
        errbuf := null;

        -- check_apcc_setup
        if (check_apcc_setup = 2) then
            msc_phub_util.log(fnd_message.get_string('MSC', 'MSC_APCC_INVALID_PROFILE'));
            return;
        end if;

        check_migrate(errbuf, retcode);

        --1 ods, 2 pds, 3 both
        if (p_refresh_mode = 1) then
            refresh_ods_mvs(errbuf, retcode);
        elsif (p_refresh_mode = 2) then
            refresh_pds_mvs(errbuf, retcode);
        elsif (p_refresh_mode = 3) then
            refresh_ods_mvs(errbuf, retcode);
            refresh_pds_mvs(errbuf, retcode);
        end if;
    end refresh_mvs;

    procedure populate_demantra_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number, p_archive_flag number default -1,
        p_dblink varchar2 default null,
        p_include_ods number default sys_no)
    is
        l_return_status number := sys_yes;
        l_plan_run_id number;
        l_req_id number;
    begin
        populate_details(errbuf, retcode, p_plan_id, p_plan_run_id, p_archive_flag, null, p_dblink, p_include_ods, 10);
    end populate_demantra_details;

    procedure populate_sno_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number,
        p_plan_run_id number default null,
        p_archive_flag number default -1,
        p_scenario_name in varchar2 default null) is
    begin
        populate_details(errbuf, retcode, p_plan_id, p_plan_run_id, p_archive_flag,
            null, null, sys_no, 6, p_scenario_name);
    end;

    procedure finalize_plan_run(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number,
        p_etl_flag number, p_success number, p_keep_previous number)
    is
        l_sr_instance_id number;
        l_prev_plan_run_id number;
    begin
        retcode := 0;
        errbuf := null;
        msc_phub_util.log('msc_phub_pkg.finalize_plan_run('||
            p_plan_id||','||p_plan_run_id||','
            ||p_etl_flag||','||p_success||','||p_keep_previous||')');

        select sr_instance_id
        into l_sr_instance_id
        from msc_plan_runs
        where plan_run_id=p_plan_run_id;

        if (p_success = sys_yes) then
            update msc_plan_runs set
                last_run_flag=sys_no,
                last_update_date = sysdate,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
            where plan_id=p_plan_id
            and plan_run_id < p_plan_run_id
            and (p_plan_id<>-1 or sr_instance_id=l_sr_instance_id);

            update msc_plan_runs set
                last_run_flag=sys_yes,
                planning_hub_flag=sys_yes,
                end_date=sysdate,
                archive_flag=p_etl_flag
            where plan_id=p_plan_id and plan_run_id=p_plan_run_id;
        else
            update msc_plan_runs set end_date=sysdate
            where plan_id=p_plan_id and plan_run_id=p_plan_run_id;
        end if;
        commit;

        -- purge_previous_plan_run
        if (p_keep_previous = sys_no) then
            purge_previous_plan_run(errbuf, retcode, p_plan_id, p_plan_run_id);
        end if;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_phub_pkg.finalize_plan_run: '||sqlerrm;
            raise;
    end;

    function create_plan_run(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_scenario_name varchar2 default null,
        p_local_archive_flag number default sys_yes,
        p_pi plan_info default null)
        return number
    is
        l_plan_run_id number;
        l_plan_run_name varchar2(100);
        e_create_plan_run exception;
    begin
        retcode := 0;
        errbuf := null;

        msc_phub_util.log('msc_phub_pkg.create_plan_run('||
            p_pi.plan_id||','||p_pi.plan_type||','||
            p_scenario_name||','||p_local_archive_flag||')');

        l_plan_run_id := populate_plan_run_info(p_pi.plan_id,
            p_pi.plan_type, p_scenario_name, p_local_archive_flag, p_pi);

        if (l_plan_run_id is null) then
            retcode := 2;
            errbuf := 'msc_phub_pkg.create_plan_run: populate_plan_run_info failed';
            raise e_create_plan_run;
        end if;

        manage_partitions(g_fact_tables, l_plan_run_id, 1);
        return l_plan_run_id;

    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_pkg.create_plan_run: '||sqlerrm;
            end if;
            raise;
    end create_plan_run;

    procedure populate_demantra_ods(errbuf out nocopy varchar2, retcode out nocopy varchar2)
    is
    begin
        msc_demantra_pkg.populate_ods(errbuf, retcode);
    end;

    procedure populate_each(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_package varchar2, p_plan_id number, p_plan_run_id number)
    is
        l_sql varchar2(200);
    begin
        msc_phub_util.log('msc_phub_pkg.populate_each: ('||p_package||','||p_plan_id||','||p_plan_run_id||')');
        l_sql := 'begin '||p_package||'.populate_details(:errbuf, :retcode, :p_plan_id, :p_plan_run_id); end;';
        execute immediate l_sql using out errbuf, out retcode, p_plan_id, p_plan_run_id;
    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_pkg.populate_each: '||sqlerrm;
                msc_phub_util.log(errbuf);
            end if;
            raise;
    end populate_each;

    procedure build_items_from_pds(p_plan_id number)
    is
    begin
        msc_phub_util.log('msc_phub_pkg.build_items_from_pds('||p_plan_id||')');

        delete from msc_apcc_item_d where plan_id=p_plan_id;
        msc_phub_util.log('msc_phub_pkg.build_items_from_pds: delete='||sql%rowcount);
        commit;

        insert into msc_apcc_item_d (
            plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            sr_category_id1,
            sr_category_id2,
            sr_category_id3,
            latest_item_id,
            item_name,
            abc_class,
            product_family_id,
            average_daily_demand,
            average_discount,
            buyer_name,
            fixed_lead_time,
            list_price,
            max_minmax_quantity,
            min_minmax_quantity,
            minimum_order_quantity,
            mrp_planning_code,
            planner_code,
            planning_make_buy_code,
            postprocessing_lead_time,
            preprocessing_lead_time,
            standard_cost,
            unit_volume,
            unit_weight,
            uom_code,
            variable_lead_time,
            volume_uom,
            weight_uom,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id
        )
        select
            i.plan_id,
            i.sr_instance_id,
            i.organization_id,
            i.inventory_item_id,
            nvl(ic1.sr_category_id, -23453),
            nvl(ic2.sr_category_id, -23453),
            nvl(ic3.sr_category_id, -23453),
            nvl(s.highest_item_id, -23453),
            i.item_name,
            i.abc_class,
            i.product_family_id,
            i.average_daily_demand,
            i.average_discount,
            i.buyer_name,
            i.fixed_lead_time,
            i.list_price,
            i.max_minmax_quantity,
            i.min_minmax_quantity,
            i.minimum_order_quantity,
            i.mrp_planning_code,
            i.planner_code,
            i.planning_make_buy_code,
            i.postprocessing_lead_time,
            i.preprocessing_lead_time,
            i.standard_cost,
            i.unit_volume,
            i.unit_weight,
            i.uom_code,
            i.variable_lead_time,
            i.volume_uom,
            i.weight_uom,
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from msc_system_items i,
            (select sr_instance_id, organization_id, inventory_item_id, sr_category_id
            from msc_phub_item_categories_mv
            where category_set_id=fnd_profile.value('MSC_HUB_CAT_SET_ID_1')) ic1,
            (select sr_instance_id, organization_id, inventory_item_id, sr_category_id
            from msc_phub_item_categories_mv
            where category_set_id=fnd_profile.value('MSC_HUB_CAT_SET_ID_2')) ic2,
            (select sr_instance_id, organization_id, inventory_item_id, sr_category_id
            from msc_phub_item_categories_mv
            where category_set_id=fnd_profile.value('MSC_HUB_CAT_SET_ID_3')) ic3,
            (select distinct lower_item_id, highest_item_id
            from msc_item_substitutes
            where plan_id=p_plan_id
                and relationship_type=8
                and inferred_flag=2
                and forward_rule=1
                and sysdate between effective_date and nvl(disable_date, sysdate)
            union all
            select distinct highest_item_id, highest_item_id
            from msc_item_substitutes
            where plan_id=p_plan_id
                and relationship_type=8
                and sysdate between effective_date and nvl(disable_date, sysdate)
            ) s
        where i.plan_id=p_plan_id
            and i.organization_id>0
            and i.sr_instance_id=ic1.sr_instance_id(+)
            and i.organization_id=ic1.organization_id(+)
            and i.inventory_item_id=ic1.inventory_item_id(+)
            and i.sr_instance_id=ic2.sr_instance_id(+)
            and i.organization_id=ic2.organization_id(+)
            and i.inventory_item_id=ic2.inventory_item_id(+)
            and i.sr_instance_id=ic3.sr_instance_id(+)
            and i.organization_id=ic3.organization_id(+)
            and i.inventory_item_id=ic3.inventory_item_id(+)
            and i.inventory_item_id=s.lower_item_id(+)
            and nvl(i.new_plan_id,-1)=-1; -- quick workaround to avoid ORA-00001, still doesn't fix RP

        msc_phub_util.log('msc_phub_pkg.build_items_from_pds: insert='||sql%rowcount);
        commit;

        msc_phub_util.log('msc_phub_pkg.build_items_from_pds: complete');

    exception
        when others then
            msc_phub_util.log('msc_phub_pkg.build_items_from_pds.exception:'||sqlerrm);
            raise;
    end build_items_from_pds;

    procedure gather_items(p_query_id number, p_fact_type number, p_plan_id number, p_plan_run_id number)
    is
        l_table varchar2(30);
        l_is_plan boolean := (p_fact_type <> 4);
        l_meta_info msc_apcc_fact_type_table := msc_phub_pkg.meta_info;
        l_item_columns varchar2(100);
        l_sql varchar2(1000);
    begin
        l_table := upper('msc_'||l_meta_info(p_fact_type).entity_name||'_f');

        if (l_meta_info(p_fact_type).item_dim in (1,3)) then
            l_item_columns := 'owning_inst_id, owning_org_id';
        else
            l_item_columns := 'sr_instance_id, organization_id';
        end if;

        l_sql :=
            ' insert into msc_hub_query ('||
            '     query_id, number3, number4, number5,'||
            '     created_by, creation_date, last_updated_by, last_update_date'||
            ' )'||
            ' select distinct'||
            '     :p_query_id, '||l_item_columns||', inventory_item_id,'||
            '     fnd_global.user_id, sysdate, fnd_global.user_id, sysdate'||
            ' from '||l_table;

        if (l_is_plan) then
            l_sql := l_sql||' where plan_id='||p_plan_id;
            if (p_plan_run_id is not null) then
                l_sql := l_sql||'and plan_run_id='||p_plan_run_id;
            end if;
            l_sql := l_sql||' and aggr_type=0';
        end if;

        execute immediate l_sql using p_query_id;
        commit;

    exception
        when others then
            msc_phub_util.log('msc_phub_pkg.gather_items.exception:'||sqlerrm);
            raise;
    end gather_items;

    procedure build_items_from_apcc(p_plan_id number, p_plan_run_id number)
    is
        l_qid_plan_item number;
        cursor c is select fact_type, item_dim from table(meta_info) where item_dim in (1,2) and fact_type<>4;
    begin
        msc_phub_util.log('msc_phub_pkg.build_items_from_apcc('||
            p_plan_id||','||p_plan_run_id||')');

        if (nvl(p_plan_id, -1) <= 0) then
            return;
        end if;

        select msc_hub_query_s.nextval into l_qid_plan_item from dual;
        for r in c loop
            gather_items(l_qid_plan_item, r.fact_type, p_plan_id, p_plan_run_id);
        end loop;

        -- delete existing items
        delete from msc_apcc_item_d d
        where exists (
            select 1 from msc_hub_query q
            where q.query_id=l_qid_plan_item
            and q.number3=d.sr_instance_id
            and q.number4=d.organization_id
            and q.number5=d.inventory_item_id)
        and d.plan_id=p_plan_id;
        --msc_phub_util.log('msc_phub_pkg.update_item_dim_from_ods: delete_existing_items.rowcount='||sql%rowcount);
        commit;

        -- insert items
        insert into msc_apcc_item_d (
            plan_id,
            sr_instance_id,
            organization_id,
            inventory_item_id,
            item_name,
            abc_class,
            product_family_id,
            sr_category_id1,
            sr_category_id2,
            sr_category_id3,
            average_daily_demand,
            average_discount,
            buyer_name,
            fixed_lead_time,
            list_price,
            max_minmax_quantity,
            min_minmax_quantity,
            minimum_order_quantity,
            mrp_planning_code,
            planner_code,
            planning_make_buy_code,
            postprocessing_lead_time,
            preprocessing_lead_time,
            standard_cost,
            unit_volume,
            unit_weight,
            uom_code,
            variable_lead_time,
            volume_uom,
            weight_uom,
            created_by, creation_date,
            last_update_date, last_updated_by, last_update_login,
            program_id, program_login_id,
            program_application_id, request_id
        )
        select
            p_plan_id,
            d.sr_instance_id,
            d.organization_id,
            d.inventory_item_id,
            d.item_name,
            d.abc_class,
            d.product_family_id,
            d.sr_category_id1,
            d.sr_category_id2,
            d.sr_category_id3,
            d.average_daily_demand,
            d.average_discount,
            d.buyer_name,
            d.fixed_lead_time,
            d.list_price,
            d.max_minmax_quantity,
            d.min_minmax_quantity,
            d.minimum_order_quantity,
            d.mrp_planning_code,
            d.planner_code,
            d.planning_make_buy_code,
            d.postprocessing_lead_time,
            d.preprocessing_lead_time,
            d.standard_cost,
            d.unit_volume,
            d.unit_weight,
            d.uom_code,
            d.variable_lead_time,
            d.volume_uom,
            d.weight_uom,
            fnd_global.user_id, sysdate,
            sysdate, fnd_global.user_id, fnd_global.login_id,
            fnd_global.conc_program_id, fnd_global.conc_login_id,
            fnd_global.prog_appl_id, fnd_global.conc_request_id
        from msc_apcc_item_d d,
            (select distinct
                number3 sr_instance_id,
                number4 organization_id,
                number5 inventory_item_id
            from msc_hub_query where query_id=l_qid_plan_item) q
        where d.sr_instance_id=q.sr_instance_id
        and d.organization_id=q.organization_id
        and d.inventory_item_id=q.inventory_item_id
        and d.plan_id=-1;
        commit;

    exception
        when others then
            msc_phub_util.log('msc_phub_pkg.build_items_from_apcc.exception:'||sqlerrm);
            raise;
    end build_items_from_apcc;

    procedure purge_items(p_plan_id number)
    is
        l_qid_ods_item number;
    begin
        msc_phub_util.log('msc_phub_pkg.purge_items('||p_plan_id||')');
        if (nvl(p_plan_id, -1) > 0) then
            delete from msc_apcc_item_d where plan_id=p_plan_id;
            msc_phub_util.log('msc_phub_pkg.purge_items: rowcount='||sql%rowcount);
            commit;
        end if;

    exception
        when others then
            msc_phub_util.log('msc_phub_pkg.purge_items.exception:'||sqlerrm);
            raise;
    end purge_items;

    procedure populate_ods_details(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_sr_instance_id number, p_refresh_mode number, p_param1 varchar2 default null) is

        con_ods_plan_id constant number := -1;
        l_plan_run_id number;
        l_lcid number;
        l_return_status number := sys_no;
        l_days_forward number := nvl(fnd_profile.value('MSC_APCC_COLL_HORIZON_DAYS'),30);
        l_days_back number := nvl(fnd_profile.value('MSC_APCC_COLL_HORIZON_DAYS_BACK'),30);
        l_instance_code varchar2(3);
        l_plan_run_name varchar2(100);
        l_pi plan_info;

    begin
        --set the conc program ret values to success
        retcode := 0;
        errbuf := null;

        fnd_message.set_name('MSC', 'MSC_HUB_POPULATE_STARTS');
        msc_phub_util.log(fnd_message.get);

        msc_phub_util.log('msc_phub_pkg.populate_ods_details('||
            p_sr_instance_id||','||p_refresh_mode||')');

        -- prepare plan info
        select compile_designator, description
        into l_pi.plan_name, l_pi.plan_description
        from msc_plans
        where plan_id=-1;

        select organization_id
        into l_pi.organization_id
        from msc_instance_orgs
        where rownum=1 and sr_instance_id=p_sr_instance_id;

        l_pi.plan_id := -1;
        l_pi.plan_type := -1;
        l_pi.sr_instance_id := p_sr_instance_id;
        l_pi.plan_start_date := trunc(sysdate) - l_days_back;
        l_pi.plan_cutoff_date := trunc(sysdate) + l_days_forward;

        --get last collection id
        select lcid
        into l_lcid
        from msc_apps_instances
        where instance_id=p_sr_instance_id;

        --populate msc_plan_buckets one row for days between sysdate and l_horizon_date
        msc_phub_util.log('Populating msc_plan_buckets');
        delete from msc_plan_buckets
        where plan_id=-1;
        commit;

        for v_counter in 1 .. l_days_back + l_days_forward + 1 loop
            insert into msc_plan_buckets (
                plan_id,
                organization_id,
                sr_instance_id,
                bucket_index,
                curr_flag,
                bkt_start_date,
                bkt_end_date,
                days_in_bkt,
                bucket_type,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by
            )
            values (
                con_ods_plan_id,
                l_pi.organization_id,
                p_sr_instance_id,
                v_counter,
                1,  --curr_flag
                l_pi.plan_start_date + v_counter - 1,
                l_pi.plan_start_date + v_counter - 1/86400,
                1,  --days_in_bkt
                1,  --bucket_type
                sysdate,
                fnd_global.user_id,
                sysdate,
                fnd_global.user_id
            );
        end loop;
        commit;

        --populate msc_plan_organizations one row for each org from msc_instance_orgs where sr_instance_id = p_sr_instance_id;
        msc_phub_util.log('Populating msc_plan_organizations');
        delete from msc_plan_organizations
        where plan_id=-1;
        commit;

        insert into msc_plan_organizations(
            plan_id,
            organization_id,
            sr_instance_id,
            organization_code,
            net_wip,
            net_reservations,
            net_purchasing,
            plan_safety_stock,
            plan_level,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login)
        select con_ods_plan_id,
            mio.organization_id,
            mio.sr_instance_id,
            mtp.organization_code,
            2,  --net_wip
            2,  --net_reservations
            2,  --net_purchasing
            2,  --plan_safety_stock
            2,  --plan_level
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            fnd_global.login_id
        from msc_instance_orgs mio,
            msc_trading_partners mtp
        where mio.sr_instance_id = p_sr_instance_id
            and mio.sr_instance_id = mtp.sr_instance_id
            and mio.organization_id = mtp.sr_tp_id
            and mtp.partner_type = 3;
        commit;

        --check for existing collections data
        begin
            select plan_run_id, plan_run_name
            into l_plan_run_id, l_plan_run_name
            from msc_plan_runs
            where plan_id = con_ods_plan_id
                and sr_instance_id=p_sr_instance_id
                and archive_flag=1;

            msc_phub_util.log('msc_phub_pkg.populate_ods_details('||l_plan_run_id||
                ', '''||l_plan_run_name||''')');

            if (p_refresh_mode = 1) then
                manage_partitions(g_fact_tables, l_plan_run_id, 3);
            end if;
        exception
            when no_data_found then
                msc_phub_util.log('msc_phub_pkg.populate_ods_details.exception: l_plan_run_id is null');

                select instance_code into l_instance_code
                from msc_apps_instances where instance_id=p_sr_instance_id;

                l_plan_run_id := populate_plan_run_info(-1, -1, l_instance_code, sys_yes, l_pi);
                manage_partitions(g_fact_tables, l_plan_run_id, 1);
        end;

        -- update msc_plan_runs
        update msc_plan_runs set
            refresh_mode = p_refresh_mode,
            plan_type = l_pi.plan_type,
            sr_instance_id = p_sr_instance_id,
            organization_id = l_pi.organization_id,
            plan_start_date = l_pi.plan_start_date,
            plan_cutoff_date = l_pi.plan_cutoff_date,
            plan_completion_date = sysdate,
            last_update_date = sysdate,
            last_updated_by = fnd_global.user_id,
            last_update_login = fnd_global.login_id,
            program_id = fnd_global.conc_program_id,
            program_login_id = fnd_global.conc_login_id,
            program_application_id = fnd_global.prog_appl_id,
            request_id = fnd_global.conc_request_id
        where plan_run_id = l_plan_run_id;
        commit;

        --call populate_ods_facts api to populate fact tables
        l_return_status := populate_ods_facts(errbuf, retcode, -1, l_plan_run_id);
        if (l_return_status = sys_no) then
            retcode := 1;
            errbuf := 'Error while populating the fact tables. purging this plan summary. ';
            msc_phub_util.log(errbuf);
        else
            update msc_plan_runs set lcid = l_lcid
            where plan_run_id=l_plan_run_id;
            commit;
        end if;
        finalize_plan_run(errbuf, retcode, -1, l_plan_run_id, sys_yes, l_return_status, sys_yes);

        fnd_message.set_name('MSC', 'MSC_HUB_POPULATE_ENDS');
        msc_phub_util.log(fnd_message.get);
    end populate_ods_details;

    function populate_ods_facts(errbuf out nocopy varchar2, retcode out nocopy varchar2,
                                p_plan_id number, p_plan_run_id number) return number is
        l_resource_req_id number;
        l_supplies_req_id number;
        l_demands_req_id number;
        l_items_req_id number;
    begin
        l_resource_req_id := submit_each('msc_resource_pkg', p_plan_id, p_plan_run_id);
        msc_phub_util.log('resource req id '|| l_resource_req_id);

        l_supplies_req_id := submit_each('msc_supply_pkg', p_plan_id, p_plan_run_id);
        msc_phub_util.log('supplies req id '|| l_supplies_req_id);

        l_demands_req_id := submit_each('msc_demand_pkg', p_plan_id, p_plan_run_id);
        msc_phub_util.log('demands req id '|| l_demands_req_id);

        if (msc_wait_for_request(l_supplies_req_id) = sys_no) then
            return sys_no;
        end if;

        if (msc_wait_for_request(l_demands_req_id) = sys_no) then
            return sys_no;
        end if;

        l_items_req_id := submit_each('msc_item_pkg', p_plan_id, p_plan_run_id);
        msc_phub_util.log('items req id '|| l_items_req_id);

        if (msc_wait_for_request(l_resource_req_id) = sys_no) then
            return sys_no;
        end if;

        if (msc_wait_for_request(l_items_req_id) = sys_no) then
            return sys_no;
        end if;

        return sys_yes;
    end populate_ods_facts;

    procedure maintain_data_model(errbuf out nocopy varchar2, retcode out nocopy varchar2)
    is
    begin
        msc_phub_util.log('msc_phub_pkg.maintain_data_model');
        retcode := 0;
        errbuf := null;

        execute immediate 'begin msc_phub_cost_pkg.migrate; end;';

    exception
        when others then
            retcode := 1;
            errbuf := 'msc_phub_pkg.maintain_data_model.exception:'||sqlerrm;
            msc_phub_util.log(errbuf);
            raise;
    end maintain_data_model;

    procedure check_migrate(errbuf out nocopy varchar2, retcode out nocopy varchar2)
    is
        l_need_migrate number := 0;
        l_request_id number := 0;
        e_check_migrate exception;
    begin
        msc_phub_util.log('msc_phub_pkg.check_migrate');

        execute immediate 'begin :1 := msc_phub_cost_pkg.need_migrate; end;' using out l_need_migrate;

        msc_phub_util.log('msc_phub_pkg.maintain_data_model, l_need_migrate='||l_need_migrate);

        if (l_need_migrate = 1) then
            l_request_id := fnd_request.submit_request('MSC','MSCHUBM', null, null, false);
            msc_phub_util.log('msc_phub_pkg.maintain_data_model: l_request_id='||l_request_id);
            commit;

            if (msc_wait_for_request(l_request_id) = sys_no) then
                raise e_check_migrate;
            end if;
        end if;

    exception
        when others then
            retcode := 1;
            errbuf := 'msc_phub_pkg.check_migrate.exception:'||sqlerrm;
            msc_phub_util.log(errbuf);
            raise;
    end check_migrate;

END msc_phub_pkg;

/
