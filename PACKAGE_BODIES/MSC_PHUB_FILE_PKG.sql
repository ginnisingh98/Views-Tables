--------------------------------------------------------
--  DDL for Package Body MSC_PHUB_FILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_PHUB_FILE_PKG" as
    /* $Header: MSCHBPFB.pls 120.1.12010000.10 2009/08/14 17:08:52 wexia noship $ */

    g_staging_tables msc_phub_pkg.object_names := list_staging_tables;

    function list_staging_tables return msc_phub_pkg.object_names
    is
        r msc_phub_pkg.object_names;
    begin
        select upper('msc_st_'||entity_name||'_f') bulk collect into r from table(msc_phub_pkg.meta_info)
        where transferable=1;
        return r;
    end;

    function get_staging_table(p_fact_type number) return varchar2
    is
        l_entity_name varchar2(30);
    begin
        select upper('msc_st_'||entity_name||'_f') into l_entity_name from table(msc_phub_pkg.meta_info) where fact_type=p_fact_type;
        return l_entity_name;
    end;

    function get_plan_type_meaning(p_plan_type number) return varchar2
    is
        l_plan_type_meaning varchar2(80);
    begin
        select meaning into l_plan_type_meaning
        from mfg_lookups
        where lookup_type='MSC_SCN_PLAN_TYPES'
            and lookup_code=p_plan_type;

        return l_plan_type_meaning;
    end get_plan_type_meaning;

    procedure prepare_partitions(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number)
    is
    begin
        retcode := 0;
        errbuf := null;
        msc_phub_pkg.manage_partitions(g_staging_tables, p_transfer_id, 1);

    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_file_pkg.prepare_partitions.exception: '||sqlerrm;
            end if;
            msc_phub_util.log(errbuf);
            raise;
    end prepare_partitions;

    procedure export_table(
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number, p_fact_type number)
    is
        l_overwrite_after_date date;
        e_export_table exception;

        l_plan_id number;
        l_plan_run_id number;
        l_source_dblink varchar2(30);
        l_source_version varchar2(20);
        l_export_level number;

        l_meta_info msc_apcc_fact_type_table := msc_phub_pkg.meta_info;
        l_package varchar2(30);
        l_entity_name varchar2(30);
        l_sql varchar2(200);
    begin
        msc_phub_util.log('msc_phub_file_pkg.export_table');
        update msc_apcc_upload_detail set
            last_updated_by=fnd_global.user_id,
            last_update_date=sysdate,
            last_update_login=fnd_global.login_id,
            program_id=fnd_global.conc_program_id,
            program_login_id=fnd_global.conc_login_id,
            program_application_id=fnd_global.prog_appl_id,
            request_id=fnd_global.conc_request_id
        where transfer_id=p_transfer_id and fact_type=p_fact_type;
        commit;

        retcode := 0;
        errbuf := null;

        select source_plan_id, source_plan_run_id, source_dblink, nvl(source_version, msc_phub_util.g_version)
        into l_plan_id, l_plan_run_id, l_source_dblink, l_source_version
        from msc_apcc_upload
        where transfer_id=p_transfer_id;

        msc_phub_util.log('msc_phub_file_pkg.export_table: '||
            'p_transfer_id='||p_transfer_id||','||
            'p_fact_type='||p_fact_type||','||
            'l_plan_id='||l_plan_id||','||
            'l_plan_run_id='||l_plan_run_id||','||
            'l_source_dblink='||l_source_dblink||','||
            'l_source_version='||l_source_version);

        l_package := l_meta_info(p_fact_type).package_name;
        l_entity_name := l_meta_info(p_fact_type).entity_name;
        l_sql := 'begin '||l_package||'.export_'||l_entity_name||'_f('||
            ':errbuf, :retcode, :p_st_transaction_id, '||
            ':p_plan_id, :p_plan_run_id, :p_dblink, :p_source_version); end;';
        execute immediate l_sql using out errbuf, out retcode,
            p_transfer_id, l_plan_id, l_plan_run_id, l_source_dblink, l_source_version;

        msc_phub_util.log('msc_phub_file_pkg.export_table: complete, retcode='||retcode);

    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_file_pkg.export_table: '||sqlerrm;
            end if;
            raise;
    end;

    function prepare_transfer_tables_ui(
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_query_id number) return number
    is
        l_transfer_id number;
        n number;
        e_prepare_transfer_tables_ui exception;
    begin
        -- dup data from query_id
        msc_phub_util.log('msc_phub_file_pkg.prepare_transfer_tables_ui('||p_query_id||')');
        select msc_apcc_upload_s.nextval into l_transfer_id from dual;

        select count(*) into n
        from msc_hub_query
        where query_id=p_query_id and number1=1;

        if (n <> 1) then
            retcode := 2;
            errbuf := 'msc_phub_file_pkg.prepare_transfer_tables_ui: n1='||n;
            raise e_prepare_transfer_tables_ui;
        end if;

        select count(*) into n
        from msc_hub_query
        where query_id=p_query_id and number1=2 and blob1 is not null;

        if (n < 1) then
            retcode := 2;
            errbuf := 'msc_phub_file_pkg.prepare_transfer_tables_ui: n2='||n;
            raise e_prepare_transfer_tables_ui;
        end if;

        insert into msc_apcc_upload (
            transfer_id,
            import_level,
            upload_mode,
            directory,
            plan_name,
            plan_type,
            plan_description,
            sr_instance_id,
            organization_id,
            plan_start_date,
            plan_cutoff_date,
            plan_completion_date,
            created_by, creation_date, last_updated_by, last_update_date, last_update_login)
        select
            l_transfer_id,
            number3 import_level,
            number4 upload_mode,
            char3 directory,
            char1 plan_name,
            number2 plan_type,
            char2 plan_description,
            number5 sr_instance_id,
            -23453 organization_id,
            date1 plan_start_date,
            date2 plan_cutoff_date,
            sysdate plan_completion_date,
            fnd_global.user_id, sysdate, fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_hub_query
        where query_id=p_query_id
        and number1=1;

        insert into msc_apcc_upload_detail (
            transfer_id,
            fact_type,
            file_name,
            file_data,
            overwrite_after_date,
            created_by, creation_date, last_updated_by, last_update_date, last_update_login)
        select
            l_transfer_id,
            number2 fact_type,
            char3 file_name,
            blob1 file_data,
            date1 overwrite_after_date,
            fnd_global.user_id, sysdate, fnd_global.user_id, sysdate, fnd_global.login_id
        from msc_hub_query
        where query_id=p_query_id
        and number1=2
        and blob1 is not null;
        commit;

        prepare_partitions(errbuf, retcode, l_transfer_id);
        return l_transfer_id;

    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_file_pkg.prepare_transfer_tables_ui.exception: '||sqlerrm;
            end if;
            msc_phub_util.log(errbuf);
            return l_transfer_id;

    end prepare_transfer_tables_ui;

    function prepare_transfer_tables(
        p_export_level number,
        p_import_level number,
        p_upload_mode number,
        p_directory varchar2,
        p_source_plan_id number,
        p_source_plan_run_id number,
        p_source_dblink varchar2,
        p_source_version varchar2,
        p_include_pds number,
        p_include_ods number,
        p_plan_name varchar2,
        p_plan_type number,
        p_plan_description varchar2,
        p_instance_code varchar2,
        p_organization_code varchar2,
        p_plan_start_date date,
        p_plan_cutoff_date date,
        p_plan_completion_date date) return number
    is
        errbuf varchar2(1000);
        retcode number;
        l_transfer_id number;
        l_sr_instance_id number;
        l_organization_id number;
    begin
        msc_phub_util.log('msc_phub_file_pkg.prepare_transfer_tables');
        select msc_apcc_upload_s.nextval into l_transfer_id from dual;

        begin
            select instance_id
            into l_sr_instance_id
            from msc_apps_instances
            where instance_code=p_instance_code;
        exception
            when others then null;
        end;

        begin
            select sr_instance_id, sr_tp_id
            into l_sr_instance_id, l_organization_id
            from msc_trading_partners
            where partner_type=3
                and organization_code=p_organization_code
                and sr_instance_id=nvl(l_sr_instance_id, sr_instance_id)
                and rownum=1;
        exception
            when others then null;
        end;

        insert into msc_apcc_upload (
            transfer_id,
            export_level,
            import_level,
            upload_mode,
            directory,
            source_plan_id,
            source_plan_run_id,
            source_dblink,
            source_version,
            transfer_status,
            plan_name,
            plan_type,
            plan_description,
            sr_instance_id,
            organization_id,
            plan_start_date,
            plan_cutoff_date,
            plan_completion_date,
            created_by, creation_date, last_updated_by, last_update_date, last_update_login)
        values (
            l_transfer_id,
            p_export_level,
            p_import_level,
            p_upload_mode,
            p_directory,
            p_source_plan_id,
            p_source_plan_run_id,
            p_source_dblink,
            nvl(p_source_version, msc_phub_util.g_version),
            status_transfering,
            p_plan_name,
            p_plan_type,
            p_plan_description,
            l_sr_instance_id,
            l_organization_id,
            p_plan_start_date,
            p_plan_cutoff_date,
            p_plan_completion_date,
            fnd_global.user_id, sysdate, fnd_global.user_id, sysdate, fnd_global.login_id);

        msc_phub_util.log('msc_phub_file_pkg.prepare_transfer_tables'||
            ',p_include_ods='||p_include_ods||
            ',p_include_pds='||p_include_pds||
            ',l_sr_instance_id='||l_sr_instance_id||
            ',l_organization_id='||l_organization_id);

        insert into msc_apcc_upload_detail (
            transfer_id, fact_type, file_name,
            created_by, creation_date, last_updated_by, last_update_date, last_update_login)
        select
            l_transfer_id, fact_type, upper('msc_st_'||entity_name||'_f')||'.csv',
            fnd_global.user_id, sysdate, fnd_global.user_id, sysdate, fnd_global.login_id
        from
            (select rownum fact_type, entity_name, initial_verion
            from table(msc_phub_pkg.meta_info)
            where transferable=1)
        where decode(fact_type,4,p_include_ods,p_include_pds)=1
            and initial_verion<=nvl(p_source_version, msc_phub_util.g_version);
        commit;

        prepare_partitions(errbuf, retcode, l_transfer_id);
        return l_transfer_id;
    end prepare_transfer_tables;

    procedure save_overwrite_date(p_transfer_id number, p_fact_type number,
        p_overwrite_after_date date)
    is
    begin
        msc_phub_util.log('msc_phub_file_pkg.save_overwrite_date ('||
            p_transfer_id||','||p_fact_type||','||p_overwrite_after_date||')');
        update msc_apcc_upload_detail
        set overwrite_after_date=p_overwrite_after_date
        where transfer_id=p_transfer_id and fact_type=p_fact_type;

        commit;
    exception
        when others then null;
    end save_overwrite_date;


    procedure prepare_export(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number)
    is
        l_plan_id number;
        l_plan_run_id number;
        l_plan_type number;
        l_local_archive_flag number;
        l_fact_type number;
        e_prepare_export exception;
        l_transfer_id number;
    begin
        msc_phub_util.log('msc_phub_file_pkg.prepare_export ('||p_transfer_id||')');
        retcode := 0;
        errbuf := null;

        update msc_apcc_upload set
            last_updated_by=fnd_global.user_id,
            last_update_date=sysdate,
            last_update_login=fnd_global.login_id,
            program_id=fnd_global.conc_program_id,
            program_login_id=fnd_global.conc_login_id,
            program_application_id=fnd_global.prog_appl_id,
            request_id=fnd_global.conc_request_id
        where transfer_id=p_transfer_id;
        commit;

        select source_plan_id, source_plan_run_id
        into l_plan_id, l_plan_run_id
        from msc_apcc_upload
        where transfer_id=p_transfer_id;

        if (l_plan_id is null or l_plan_run_id is null) then
            select fact_type into l_fact_type
            from msc_apcc_upload_detail
            where transfer_id=p_transfer_id;

            if (l_fact_type <> 4) then
                retcode := 2;
                errbuf := '(l_plan_id is null or l_plan_run_id is null)';
                raise e_prepare_export;
            end if;
        end if;

    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_file_pkg.prepare_export: '||sqlerrm;
            end if;
    end prepare_export;

    procedure finalize_export(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number)
    is
    begin
        update msc_apcc_upload
        set transfer_status=status_transfered
        where transfer_id=p_transfer_id;
        commit;

    exception
        when others then
            retcode := 2;
            errbuf := 'msc_phub_file_pkg.finalize_export: '||sqlerrm;
    end finalize_export;

    procedure prepare_import(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number)
    is
        e_prepare_import exception;
    begin
        msc_phub_util.log('msc_phub_file_pkg.prepare_import ('||p_transfer_id||')');
        retcode := 0;
        errbuf := null;

        update msc_apcc_upload set
            last_updated_by=fnd_global.user_id,
            last_update_date=sysdate,
            last_update_login=fnd_global.login_id,
            program_id=fnd_global.conc_program_id,
            program_login_id=fnd_global.conc_login_id,
            program_application_id=fnd_global.prog_appl_id,
            request_id=fnd_global.conc_request_id
        where transfer_id=p_transfer_id;
        commit;

        prepare_context(errbuf, retcode, p_transfer_id, msc_phub_pkg.sys_no);
        if (retcode <> 0) then
            raise e_prepare_import;
        end if;

    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_file_pkg.prepare_import.exception: '||sqlerrm;
                msc_phub_util.log(errbuf);
            end if;
            raise;
    end prepare_import;

    procedure finalize_import(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number)
    is
        l_upload_mode number;
        l_plan_id number;
        l_plan_run_id number;
        l_keep_previous number := msc_phub_pkg.sys_yes;
        e_finanlize_import exception;
    begin
        msc_phub_util.log('msc_phub_file_pkg.finalize_import('||p_transfer_id||')');

        select upload_mode, plan_id, plan_run_id
        into l_upload_mode, l_plan_id, l_plan_run_id
        from msc_apcc_upload
        where transfer_id=p_transfer_id;

        if (l_upload_mode = msc_phub_util.upload_create_purge_prev) then
            l_keep_previous := msc_phub_pkg.sys_no;
        end if;

        msc_phub_pkg.finalize_plan_run(errbuf, retcode, l_plan_id, l_plan_run_id,
            msc_phub_pkg.sys_yes, msc_phub_pkg.sys_yes, l_keep_previous);
        if (retcode <> 0) then
            raise e_finanlize_import;
        end if;

        msc_phub_pkg.build_items_from_apcc(l_plan_id, l_plan_run_id);

        update msc_apcc_upload
        set transfer_status=status_transfered
        where transfer_id=p_transfer_id;
        commit;

    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_file_pkg.finalize_import: '||sqlerrm;
            end if;
    end finalize_import;

    procedure prepare_context(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number, p_validate_only number)
    is
        l_plan_type2 number;
        l_upload_mode number;
        l_plan_run_id number;
        l_local_archive_flag number;
        l_fact_type number;
        n number;
        e_prepare_context exception;
        l_include_ods boolean := false;
        l_import_level number;
        l_pi msc_phub_pkg.plan_info;
    begin
        retcode := 0;
        errbuf := null;

        msc_phub_util.log('msc_phub_file_pkg.prepare_context('||
            p_transfer_id||','||p_validate_only||')');

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
        from msc_apcc_upload
        where transfer_id=p_transfer_id;

        select import_level, upload_mode
        into l_import_level, l_upload_mode
        from msc_apcc_upload
        where transfer_id=p_transfer_id;

        msc_phub_util.log('msc_phub_file_pkg.prepare_context: '||
            'l_import_level='||l_import_level||','||
            'l_pi.plan_name='||l_pi.plan_name||','||
            'l_pi.plan_type='||l_pi.plan_type||','||
            'l_upload_mode='||l_upload_mode);

        select count(*) into n
        from msc_apcc_upload_detail
        where transfer_id=p_transfer_id
            and fact_type=4
            and (file_data is not null or l_import_level <> 3);

        l_include_ods := (n = 1);
        if (l_include_ods) then
            msc_phub_util.log('msc_phub_file_pkg.prepare_context: l_include_ods=YES');
        else
            msc_phub_util.log('msc_phub_file_pkg.prepare_context: l_include_ods=NO');
        end if;

        if (l_pi.plan_name is null) then
            msc_phub_util.log('msc_phub_file_pkg.prepare_context: l_pi.plan_name is null');
            if (l_include_ods) then
                msc_phub_util.log('msc_phub_file_pkg.prepare_context: l_include_ods');
                return;
            else
                retcode := 2;
                fnd_message.set_name('MSC', 'MSC_APCC_MISSING_PLAN_INFO');
                errbuf := fnd_message.get;
                raise e_prepare_context;
            end if;
        end if;

        begin
            select r.plan_id, r.plan_run_id, r.plan_type, r.local_archive_flag
            into l_pi.plan_id, l_plan_run_id, l_plan_type2, l_local_archive_flag
            from msc_plan_runs r,
                (select plan_id, max(plan_run_id) last_plan_run_id
                from msc_plan_runs
                where planning_hub_flag=1
                group by plan_id) t
            where r.plan_id=t.plan_id and r.plan_run_id=t.last_plan_run_id
            and r.plan_name=l_pi.plan_name;

        exception
            when no_data_found then null;
        end;

        msc_phub_util.log('msc_phub_file_pkg.prepare_context: '
            ||'l_plan_run_id='||l_plan_run_id);
        if (l_plan_run_id is not null) then
            if (l_plan_type2 <> l_pi.plan_type) then
                retcode := 1;
                fnd_message.set_name('MSC', 'MSC_APCC_PLAN_INFO_E03');
                fnd_message.set_token('PLAN', l_pi.plan_name);
                fnd_message.set_token('PLAN_TYPE', get_plan_type_meaning(l_plan_type2));
                errbuf := fnd_message.get;
                raise e_prepare_context;
            end if;

            if (l_local_archive_flag <> 2) then
                retcode := 2;
                fnd_message.set_name('MSC', 'MSC_APCC_PLAN_INFO_E02');
                fnd_message.set_token('PLAN', l_pi.plan_name);
                errbuf := fnd_message.get;
                raise e_prepare_context;
            end if;

            if (nvl(p_validate_only, msc_phub_pkg.sys_yes) = msc_phub_pkg.sys_yes) then
                return;
            end if;

            if (l_upload_mode = msc_phub_util.upload_create or
                l_upload_mode = msc_phub_util.upload_create_purge_prev) then
                l_plan_run_id := msc_phub_pkg.create_plan_run(errbuf, retcode,
                    null, msc_phub_pkg.sys_no, l_pi);
            else
                update msc_plan_runs
                set plan_description = nvl(l_pi.plan_description, plan_description),
                    sr_instance_id = nvl(l_pi.sr_instance_id, sr_instance_id),
                    organization_id = nvl(l_pi.organization_id, organization_id),
                    plan_start_date = nvl(l_pi.plan_start_date, plan_start_date),
                    plan_cutoff_date = nvl(l_pi.plan_cutoff_date, plan_cutoff_date),
                    plan_completion_date = nvl(l_pi.plan_completion_date, plan_completion_date)
                where plan_run_id=l_plan_run_id;
            end if;

            update msc_apcc_upload
            set plan_id=l_pi.plan_id, plan_run_id=l_plan_run_id
            where transfer_id=p_transfer_id;
            commit;
        else
            if (l_upload_mode = msc_phub_util.upload_replace or
                l_upload_mode = msc_phub_util.upload_create or
                l_upload_mode = msc_phub_util.upload_create_purge_prev) then

                if (l_pi.plan_type = 10) then
                    if (nvl(p_validate_only, msc_phub_pkg.sys_yes) = msc_phub_pkg.sys_yes) then
                        return;
                    end if;

                    select msc_plans_s.nextval into l_pi.plan_id from dual;
                else
                    begin
                        select plan_id, plan_type
                        into l_pi.plan_id, l_plan_type2
                        from
                            (select plan_id, compile_designator, plan_type
                            from msc_plans
                            union
                            select das.scenario_id, substr(das.scenario_name, 1, 50), 10
                            from msd_dp_ascp_scenarios_v das, msd_dem_transfer_query tq
                            where das.demand_plan_id=5555555
                                and das.demand_plan_name = substr(tq.query_name, 1, 30))
                        where compile_designator=l_pi.plan_name
                        and rownum=1;
                    exception
                        when no_data_found then null;
                    end;

                    msc_phub_util.log('msc_phub_file_pkg.prepare_context: '||
                        'l_pi.plan_id='||l_pi.plan_id);

                    if (l_pi.plan_id is not null) then
                        if (l_plan_type2 <> l_pi.plan_type) then
                            retcode := 1;
                            fnd_message.set_name('MSC', 'MSC_APCC_PLAN_INFO_E03');
                            fnd_message.set_token('PLAN', l_pi.plan_name);
                            fnd_message.set_token('PLAN_TYPE', get_plan_type_meaning(l_plan_type2));
                            errbuf := fnd_message.get;
                            raise e_prepare_context;
                        end if;

                        select count(*) into n
                        from msc_plans p, msc_designators d
                        where p.plan_id=l_pi.plan_id
                            and p.sr_instance_id=d.sr_instance_id
                            and p.compile_designator=d.designator
                            and p.organization_id=d.organization_id;

                        if (n > 0) then
                            retcode := 2;
                            fnd_message.set_name('MSC', 'MSC_APCC_PLAN_INFO_E02');
                            fnd_message.set_token('PLAN', l_pi.plan_name);
                            errbuf := fnd_message.get;
                            raise e_prepare_context;
                        end if;
                    end if;

                    if (nvl(p_validate_only, msc_phub_pkg.sys_yes) = msc_phub_pkg.sys_yes) then
                        return;
                    end if;

                    if (l_pi.plan_id is null) then
                        l_pi.plan_id := create_plan(errbuf, retcode, p_transfer_id);
                    end if;
                end if;

                l_plan_run_id := msc_phub_pkg.create_plan_run(errbuf, retcode,
                    null, msc_phub_pkg.sys_no, l_pi);

                update msc_apcc_upload
                set plan_id=l_pi.plan_id, plan_run_id=l_plan_run_id
                where transfer_id=p_transfer_id;
                commit;
            else
                retcode := 2;
                fnd_message.set_name('MSC', 'MSC_APCC_UPLOAD_MODE_E01');
                fnd_message.set_token('PLAN', l_pi.plan_name);
                errbuf := fnd_message.get;
                msc_phub_util.log(errbuf);
                return;
            end if;
        end if;

    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_file_pkg.prepare_context.exception: '||sqlerrm;
            end if;
            msc_phub_util.log(errbuf);
    end prepare_context;

    procedure import_table(
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number, p_fact_type number)
    is
        l_upload_mode number;
        l_overwrite_after_date date;
        l_plan_id number;
        l_plan_run_id number;
        l_plan_type number;
        l_plan_start_date date;
        l_plan_cutoff_date date;
        l_def_instance_code varchar2(3) := null;
        l_def_instance_id number;
        e_import_table exception;

        l_meta_info msc_apcc_fact_type_table := msc_phub_pkg.meta_info;
        l_package varchar2(30);
        l_entity_name varchar2(30);
        l_sql varchar2(1000);
    begin
        msc_phub_util.log('msc_phub_file_pkg.import_table');
        update msc_apcc_upload_detail set
            last_updated_by=fnd_global.user_id,
            last_update_date=sysdate,
            last_update_login=fnd_global.login_id,
            program_id=fnd_global.conc_program_id,
            program_login_id=fnd_global.conc_login_id,
            program_application_id=fnd_global.prog_appl_id,
            request_id=fnd_global.conc_request_id
        where transfer_id=p_transfer_id and fact_type=p_fact_type;
        commit;

        retcode := 0;
        errbuf := null;

        select plan_id, plan_run_id, plan_type, sr_instance_id,
            plan_start_date, plan_cutoff_date, upload_mode
        into l_plan_id, l_plan_run_id, l_plan_type, l_def_instance_id,
            l_plan_start_date, l_plan_cutoff_date, l_upload_mode
        from msc_apcc_upload
        where transfer_id=p_transfer_id;

        select overwrite_after_date
        into l_overwrite_after_date
        from msc_apcc_upload_detail
        where transfer_id=p_transfer_id
        and fact_type=p_fact_type;

        begin
            select instance_code
            into l_def_instance_code
            from msc_apps_instances
            where instance_id=l_def_instance_id;
        exception
            when others then null;
        end;

        msc_phub_util.log('msc_phub_file_pkg.import_table: '||
            'p_transfer_id='||p_transfer_id||','||
            'p_fact_type='||p_fact_type||','||
            'l_plan_id='||l_plan_id||','||
            'l_plan_run_id='||l_plan_run_id||','||
            'l_upload_mode='||l_upload_mode||','||
            'l_overwrite_after_date='||l_overwrite_after_date||','||
            'l_def_instance_code='||l_def_instance_code);

        if (l_upload_mode <> msc_phub_util.upload_append and
            l_upload_mode <> msc_phub_util.upload_replace and
            l_upload_mode <> msc_phub_util.upload_create and
            l_upload_mode <> msc_phub_util.upload_create_purge_prev) then
            retcode := 2;
            fnd_message.set_name('MSC', 'MSC_APCC_MISSING_PARAMETER');
            fnd_message.set_token('PARAM', 'Upload Mode');
            errbuf := fnd_message.get;
            raise e_import_table;
        end if;

        l_package := l_meta_info(p_fact_type).package_name;
        l_entity_name := l_meta_info(p_fact_type).entity_name;
        l_sql := 'begin '||l_package||'.import_'||l_entity_name||'_f('||
            ':errbuf, :retcode, :p_st_transaction_id, :p_plan_id, :p_plan_run_id, '||
            ':p_plan_type, :p_plan_start_date, :p_plan_cutoff_date, '||
            ':p_upload_mode, :p_overwrite_after_date, :p_def_instance_code); end;';
        execute immediate l_sql using out errbuf, out retcode,
            p_transfer_id, l_plan_id, l_plan_run_id,
            l_plan_type, l_plan_start_date, l_plan_cutoff_date,
            l_upload_mode, l_overwrite_after_date, l_def_instance_code;

        msc_phub_util.log('msc_phub_file_pkg.import_table: complete, retcode='||retcode);
    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_file_pkg.import_table: '||sqlerrm;
            end if;
            msc_phub_util.log(errbuf);
    end;

    function create_plan(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number) return number
    is
        l_plan_name varchar2(50);
        l_return_status varchar2(10);
        l_plan_id number;
        e_create_plan exception;
    begin
        msc_phub_util.log('msc_phub_file_pkg.create_plan '||l_plan_name);
        retcode := 0;
        errbuf := null;

        select plan_name into l_plan_name from msc_apcc_upload where transfer_id=p_transfer_id;

        l_plan_id := msc_manage_plan_partitions.get_plan(
            l_plan_name, l_return_status, errbuf);
        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
             retcode := 1;
             errbuf := 'msc_phub_file_pkg.create_plan: '||
                'msc_manage_plan_partitions.get_plan failed:'||
                l_return_status||':'||errbuf;
             raise e_create_plan;
        end if;

        if (l_plan_id is null) then
             retcode := 1;
             errbuf := 'msc_phub_file_pkg.create_plan: '||
                'l_plan_id is null';
             raise e_create_plan;
        end if;

        insert into msc_plans (
            plan_id,
            compile_designator,
            description,
            plan_type,
            sr_instance_id,
            organization_id,
            curr_start_date,
            curr_cutoff_date,
            plan_completion_date,

            curr_append_planned_orders,
            curr_demand_time_fence_flag,
            curr_operation_schedule_type,
            curr_overwrite_option,
            curr_planning_time_fence_flag,
            curr_plan_type,
            daily_cutoff_bucket,
            daily_item_aggregation_level,
            daily_material_constraints,
            daily_resource_constraints,
            daily_res_aggregation_level,
            weekly_cutoff_bucket,
            weekly_item_aggregation_level,
            weekly_material_constraints,
            weekly_resource_constraints,
            weekly_res_aggregation_level,
            optimize_flag,
            schedule_flag,
            curr_enforce_dem_due_dates,
            curr_planned_resources,
            daily_rtg_aggregation_level,
            weekly_rtg_aggregation_level,
            period_cutoff_bucket,
            period_material_constraints,
            period_resource_constraints,
            period_item_aggregation_level,
            period_res_aggregation_level,
            display_kpi,
            last_updated_by, last_update_date, created_by, creation_date
        )
        select
            l_plan_id,
            l_plan_name,
            plan_description,
            plan_type,
            nvl(sr_instance_id, -23453),
            nvl(organization_id, -23453),
            nvl(plan_start_date, sysdate),
            nvl(plan_cutoff_date, sysdate),
            nvl(plan_completion_date, sysdate),
            0, 0, 0, 0, 0, plan_type,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2,
            fnd_global.user_id, sysdate, fnd_global.user_id, sysdate
        from msc_apcc_upload
        where transfer_id=p_transfer_id;
        commit;

        return l_plan_id;

    exception
        when others then
            if (retcode = 0) then
                retcode := 3;
                errbuf := 'msc_phub_file_pkg.create_plan: '||sqlerrm;
            end if;
            raise;
    end create_plan;

    procedure cleanup(
        errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_transfer_id number)
    is
    begin
        msc_phub_util.log('msc_phub_file_pkg.cleanup('||p_transfer_id||')');
        msc_phub_pkg.manage_partitions(g_staging_tables, p_transfer_id, 2);

        update msc_apcc_upload_detail set file_data=null where transfer_id=p_transfer_id;
        commit;

    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_file_pkg.cleanup: '||sqlerrm;
            end if;
            raise;
    end cleanup;

    procedure purge_apcc_tables(errbuf out nocopy varchar2, retcode out nocopy varchar2)
    is
    begin
        msc_phub_util.log('msc_phub_file_pkg.purge_apcc_tables');

        delete from msc_apcc_upload_detail where transfer_id in (
            select distinct transfer_id from msc_apcc_upload
            where transfer_status=status_purging);

        delete from msc_apcc_upload where transfer_status=status_purging;
        commit;

    exception
        when others then
            if (retcode = 0) then
                retcode := 2;
                errbuf := 'msc_phub_file_pkg.purge_apcc_tables: '||sqlerrm;
            end if;
            raise;
    end purge_apcc_tables;

    procedure purge_plan_summary(errbuf out nocopy varchar2, retcode out nocopy varchar2,
        p_plan_id number, p_plan_run_id number default null) is
        cursor c is
            select transfer_id
            from msc_apcc_upload
            where ((source_plan_id=p_plan_id
                    and source_plan_run_id=nvl(p_plan_run_id,source_plan_run_id)
                    and source_dblink is null and export_level>0)
                or (plan_id=p_plan_id and plan_run_id=nvl(p_plan_run_id,plan_run_id)
                    and import_level>0));

    begin
        fnd_message.set_name('MSC', 'MSC_HUB_PURGE_STARTS');
        msc_phub_util.log(fnd_message.get);

        retcode := 0;
        errbuf := null;

        for r in c loop
            begin
                cleanup(errbuf, retcode, r.transfer_id);  --xxx!!!
            exception
                when others then null;
            end;
        end loop;

        msc_phub_pkg.purge_details(errbuf, retcode, p_plan_id, p_plan_run_id);
        fnd_message.set_name('MSC', 'MSC_HUB_PURGE_ENDS');
        msc_phub_util.log(fnd_message.get);

    exception
        when others then
            fnd_message.set_name('MSC', 'MSC_HUB_PURGE_ERROR');
            retcode := 2;
            errbuf := fnd_message.get;
            msc_phub_util.log(errbuf);
    end purge_plan_summary;

end msc_phub_file_pkg;

/
