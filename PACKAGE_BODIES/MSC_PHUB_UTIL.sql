--------------------------------------------------------
--  DDL for Package Body MSC_PHUB_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_PHUB_UTIL" AS
/* $Header: MSCHBUTB.pls 120.3.12010000.18 2010/03/03 23:37:29 wexia ship $ */
  SYS_YES CONSTANT INTEGER := 1;
  SYS_NO CONSTANT INTEGER := 2;

  function get_conversion_rate(p_func_currency varchar2,p_sr_instance_id number, p_date date) return number is
    l_currency_rate number;
    l_reporting_currency varchar2(20) := get_reporting_currency_code;
  begin
    /*select CONV_RATE
        into l_currency_rate
      from MSC_CURRENCY_CONVERSIONS
      where FROM_CURRENCY = p_func_currency
        and TO_CURRENCY = l_reporting_currency
        and SR_INSTANCE_ID = p_sr_instance_id
        and CONV_DATE = p_date;*/
    return 1;--l_currency_rate;
  end get_conversion_rate;

    function get_conversion_rate(p_sr_instance_id number, p_organization_id number, p_date date) return number is
      l_func_currency varchar2(20);
      l_rate number;
     begin
       /*select currency_code
        into l_func_currency
       from msc_trading_partners
       where sr_instance_id = p_sr_instance_id
        and organization_id = p_organization_id
        and partner_type = 3;*/
        l_rate := msc_phub_util.get_conversion_rate(l_func_currency, p_sr_instance_id, p_date);
      return l_rate;
    end get_conversion_rate;

   function get_planning_hub_message(p_mesg_code varchar2) return varchar2 is
    l_message varchar2(100);
   begin
    FND_MESSAGE.SET_NAME('MSC', p_mesg_code);
    l_message :=FND_MESSAGE.GET;
    return l_message;
   end  get_planning_hub_message;

   function get_reporting_currency_code return varchar2 is
   begin
        if g_rpt_curr_code is null then
            g_rpt_curr_code := nvl(FND_PROFILE.VALUE('MSC_HUB_CUR_CODE_RPT'),'USD');
        end if;

        return  g_rpt_curr_code;
   end get_reporting_currency_code;

    FUNCTION get_exception_group(p_exception_type_id in number) return varchar2 is
        l_exception_group varchar2(300);
        l_exception_group_id number;

        CURSOR exception_group_meaning(p_exception_group_id NUMBER) IS
            select meaning
            from mfg_lookups
            where lookup_type = 'MSC_EXCEPTION_GROUP'
            and lookup_code = p_exception_group_id;
    BEGIN
        l_exception_group_id:= case
                                when p_exception_type_id in (11,5,12,105,30,48,84,29) then 1
                                when p_exception_type_id in (31,32,33,34,43,44,49,114) then 2
                                when p_exception_type_id in (2,3,20,115) then 3
                                when p_exception_type_id in (6,7,8,10,9,47,62,63,64,65,66,70,71) then 4
                                when p_exception_type_id in (13,14,113,23,24,25,26,27,35,41,42,15,16,69,52) then 5
                                when p_exception_type_id in (28,112,21,22,36,37,45,46,90,91)then 6
                                when p_exception_type_id in (40,38,39,50,51,61)then 7
                                when p_exception_type_id in (17,18,19)then 8
                                when p_exception_type_id in (53,54,55,56,57,58,67,59,60,72,77)then 11
                                when p_exception_type_id in (85,86)then 12
                                when p_exception_type_id in (92,93)then 13
                                when p_exception_type_id in (87,88)then 14
                                when p_exception_type_id in (150,151,152) then 15
                                when p_exception_type_id in (160,161,162) then 16
                                when p_exception_type_id in (170,171,172,173) then 17
                                when p_exception_type_id in (180,181) then 18
                                when p_exception_type_id in (190,191) then 19
                                when p_exception_type_id in (200,201)then 20
                                else 1
                               end;

        open exception_group_meaning(l_exception_group_id);
        fetch exception_group_meaning into l_exception_group;
        close exception_group_meaning;

        return l_exception_group;
    END get_exception_group;

    function get_list_price(p_plan_id number,p_inst_id number,p_org_id number, p_item_id number) return number is

        l_list_price number;
    begin
        select nvl(msi.list_price,0) * (1-(nvl(msi.average_discount,0)/100))
        into l_list_price
        from msc_system_items msi
        where
            msi.plan_id =p_plan_id
            and msi.sr_instance_id = p_inst_id
            and msi.organization_id = p_org_id
            and msi.inventory_item_id = p_item_id;
        return l_list_price;
    end get_list_price;

    function is_plan_constrained (l_daily number,
                                       l_weekly number,
                                       l_monthly number,
                                       l_dailym number,
                                       l_weeklym number,
                                       l_monthlym number) return number is
          begin

           if l_daily = 1 or l_weekly =1 or l_monthly =1 or l_dailym = 1 or l_weeklym =1 or l_monthlym =1 then
             return SYS_YES;
           else
             return SYS_NO;
            end if;

      end is_plan_constrained;

     FUNCTION is_plan_constrained(p_plan_id number) return number is
        l_plan_constrained number;
         begin
            select count(1) into l_plan_constrained
            from
                msc_plans mp
            where
                mp.plan_id = p_plan_id
                and( nvl(mp.daily_resource_constraints,0 ) = 1
                or nvl(mp.weekly_resource_constraints,0) = 1
                or nvl(mp.period_resource_constraints,0) = 1
                or nvl(mp.daily_material_constraints,0 ) = 1
                or nvl(mp.weekly_material_constraints,0) = 1
                or nvl(mp.period_material_constraints,0) = 1);

             if l_plan_constrained = 0 then
                l_plan_constrained := 2;
             end if;

           return l_plan_constrained;
     end is_plan_constrained;

     FUNCTION get_plan_type(p_plan_id number) return number is
        l_plan_type number;
        begin
            select CURR_PLAN_TYPE
                into l_plan_type
            from
                msc_plans
            where
                plan_id = p_plan_id;
        return  l_plan_type;
     end get_plan_type;

    function get_default_plan_run_id(p_scenario_id number, p_plan_type number, p_plan_run_name varchar2) return number
    is
        l_plan_run_id number := null;
    begin
        if (p_plan_run_name is not null) then
            select plan_run_id
            into l_plan_run_id
            from msc_plan_runs
            where plan_run_name=p_plan_run_name;
            return l_plan_run_id;
        end if;

        if (p_scenario_id is not null) then
            select sp.plan_run_id
            into l_plan_run_id
            from msc_scenario_plans sp, msc_plan_runs r
            where scenario_id=p_scenario_id
                and sp.plan_type=decode(p_plan_type, null, sp.plan_type, p_plan_type)
                and sp.plan_type not in (-1, 10)
                and sp.plan_run_id=r.plan_run_id
                and r.local_archive_flag=1
                and rownum=1;
            return l_plan_run_id;
        end if;

        return l_plan_run_id;

    exception
        when others then return null;

    end get_default_plan_run_id;

    FUNCTION get_user_name(p_user_id number) return varchar2 is
        l_user_name varchar2(80);
    begin
        select distinct u.user_name
        into l_user_name
        from fnd_user u, fnd_user_resp_groups g
        where u.user_id=g.user_id
        and g.responsibility_application_id=724
        and sysdate between u.start_date and nvl(u.end_date, sysdate)
        and u.user_id=p_user_id;

        return l_user_name;

    exception
        when others then
            return msc_phub_util.get_planning_hub_message('MSC_HUB_UNASSIGNED');
    end get_user_name;

   procedure validate_icx_session(p_icx_cookie varchar2, p_user varchar2, p_pwd varchar2) is
     l_retval varchar2(1);
     SECURITY_CONTEXT_INVALID exception;

     cursor c_user_info is
     select furg.user_id, furg.responsibility_id, responsibility_application_id
     from fnd_user_resp_groups furg,
       fnd_user fu,
       fnd_responsibility fr
     where furg.user_id = fu.user_id
       and furg.responsibility_id = fr.responsibility_id
       and furg.responsibility_application_id = fr.application_id
       and fu.user_name = 'APCC_ADMIN'
       and fr.responsibility_key = 'APS_SCN_PLN';

     l_user_id number;
     l_resp_id number;
     l_resp_app_id number;
     procedure println (p_msg varchar2) is
     begin
       null;
       --dbms_output.put_line(p_msg);
     end println;
   begin
     println('icx cookie value is cookie user pwd - '|| p_icx_cookie ||' - '||p_user||' - '||p_pwd); commit;

     l_retval := fnd_web_sec.validate_login(p_user, p_pwd);
     println('icx cookie value is valid_login - '||l_retval); commit;

     if p_icx_cookie <> '-1' then
        app_session.validate_icx_session(p_icx_cookie);
     elsif (l_retval ='Y' and p_user = 'APCC_ADMIN') or (p_user = 'Administrator') then
       open c_user_info;
       fetch c_user_info into l_user_id, l_resp_id, l_resp_app_id;
       close c_user_info;
       if (l_user_id is null or l_resp_id is null or l_resp_app_id is null) then
             raise SECURITY_CONTEXT_INVALID;
       end if;
           fnd_global.apps_initialize ( user_id => l_user_id, resp_id => l_resp_id, resp_appl_id => l_resp_app_id);
     else
       raise SECURITY_CONTEXT_INVALID;
     end if;
   end validate_icx_session;

    procedure log(p_message varchar2)
    is
        t timestamp;
    begin
        select systimestamp into t from dual;
        --dbms_output.put_line(to_char(t, 'YYYY-MM-DD HH24:MI:SS')||': '||p_message);
        fnd_file.put_line(fnd_file.log, to_char(t, 'YYYY-MM-DD HH24:MI:SS')||': '||p_message);
    end;

    function suffix(p_dblink varchar2) return varchar2 is
    begin
        if (p_dblink is null) then
            return null;
        end if;
        return '@'||p_dblink;
    end;

    function report_decode_error(p_staging_table varchar2, p_st_transaction_id number,
        p_error_code number, p_columns varchar2)
        return number
    is
        l_sql varchar2(1000);
        c sys_refcursor;
        s varchar2(200);
        l_merged_columns varchar2(1000);
        n number;
        t dbms_utility.uncl_array;
        i number;
        l_result number := 0;
        l_rowcount number;
    begin
        l_sql :=
            ' update '||p_staging_table||' set error_code=:error_code'||
            ' where st_transaction_id=:p_st_transaction_id and error_code is null';
        execute immediate l_sql using p_error_code, p_st_transaction_id;
        l_rowcount := sql%rowcount;
        commit;

        if (l_rowcount > 0) then
            l_result := 1;
            fnd_message.set_name('MSC', 'MSC_APCC_CONV_E02');
            fnd_message.set_token('COLUMNS', p_columns);
            log(fnd_message.get);
            dbms_utility.comma_to_table(p_columns, n, t);
            l_merged_columns := t(1); i := 2;
            while (i <= n) loop
                l_merged_columns := l_merged_columns||'||'',''||'||t(i);
                i := i + 1;
            end loop;

            l_sql :=
                ' select distinct '||l_merged_columns||' from '||p_staging_table||
                ' where st_transaction_id=:p_st_transaction_id and error_code=:error_code';

            open c for l_sql using p_st_transaction_id, p_error_code;
            loop
                fetch c into s;
                exit when c%notfound;
                log(s);
            end loop;
            close c;
        end if;
        return l_result;

    exception
        when others then
            log('msc_phub_util.report_decode_error.exception: '||sqlerrm);
            return 1;
    end report_decode_error;

    function decode_organization_key(p_staging_table varchar2, p_st_transaction_id number,
        p_def_instance_code varchar2,
        p_sr_instance_id_col varchar2, p_organization_id_col varchar2, p_organization_code_col varchar2)
        return number
    is
        l_sql varchar2(1000);
    begin
        l_sql :=
            ' update '||p_staging_table||' f set (error_code, '||p_sr_instance_id_col||', '||p_organization_id_col||') ='||
            '     (select 0, d.sr_instance_id, d.sr_tp_id from '||
            '         (select mtp.sr_instance_id, mtp.sr_tp_id,'||
            '             mtp.organization_code, mai.instance_code'||
            '         from msc_trading_partners mtp, msc_apps_instances mai'||
            '         where mtp.sr_instance_id=mai.instance_id'||
            '         and mtp.partner_type=3) d'||
            '     where (f.'||p_organization_code_col||'=d.organization_code'||
            '         or '''||p_def_instance_code||':''||f.'||p_organization_code_col||'=d.organization_code'||
            '         or f.'||p_organization_code_col||'='''||p_def_instance_code||':''||d.organization_code)'||
            '         and (instr(f.'||p_organization_code_col||', '':'')>0 '||
            '           or nvl('''||p_def_instance_code||''', d.instance_code)=d.instance_code)'||
            '         and rownum=1)'||
            ' where f.st_transaction_id=:p_st_transaction_id'||
            '     and f.error_code = 0'||
            '     and f.'||p_organization_code_col||' is not null';

        execute immediate l_sql using p_st_transaction_id;
        commit;
        return report_decode_error(p_staging_table, p_st_transaction_id, conv_key_err_organization, p_organization_code_col);

    exception
        when others then
            log('msc_phub_util.decode_organization_key.exception: '||sqlerrm);
            return 1;
    end decode_organization_key;

    function decode_item_key(p_staging_table varchar2, p_st_transaction_id number,
        p_item_id_col varchar2, p_item_name_col varchar2)
        return number
    is
        l_sql varchar2(1000);
    begin
        l_sql :=
            ' update '||p_staging_table||' f set (error_code, '||p_item_id_col||') ='||
            '     (select 0, d.inventory_item_id from msc_items d'||
            '     where d.item_name=f.'||p_item_name_col||')'||
            ' where f.st_transaction_id=:p_st_transaction_id'||
            '     and f.error_code = 0'||
            '     and f.'||p_item_name_col||' is not null';

        execute immediate l_sql using p_st_transaction_id;
        commit;
        return report_decode_error(p_staging_table, p_st_transaction_id, conv_key_err_item, p_item_name_col);

    exception
        when others then
            log('msc_phub_util.decode_item_key.exception: '||sqlerrm);
            return 1;
    end decode_item_key;

    function decode_category_key(p_staging_table varchar2, p_st_transaction_id number)
        return number
    is
        l_sql varchar2(1000);
        l_category_set_id number := fnd_profile.value('MSC_HUB_CAT_SET_ID_1');
    begin
        l_sql :=
            ' update '||p_staging_table||' f set (error_code, category_set_id, category_instance_id) ='||
            '     (select 0, '||l_category_set_id||', d.instance_id from msc_apps_instances d'||
            '     where d.instance_code=f.category_instance_code)'||
            ' where f.st_transaction_id=:p_st_transaction_id'||
            '     and f.error_code = 0'||
            '     and f.category_instance_code is not null';
        execute immediate l_sql using p_st_transaction_id;
        commit;

        l_sql :=
            ' update '||p_staging_table||' f set (error_code, sr_category_id) ='||
            '     (select 0, d.sr_category_id from msc_phub_categories_mv d'||
            '     where d.category_set_id=f.category_set_id'||
            '     and d.sr_instance_id=f.category_instance_id'||
            '     and d.category_name=f.category_name)'||
            ' where f.st_transaction_id=:p_st_transaction_id'||
            '     and f.error_code = 0'||
            '     and f.category_name is not null';

        execute immediate l_sql using p_st_transaction_id;
        commit;
        return report_decode_error(p_staging_table, p_st_transaction_id, conv_key_err_category,
            'category_set_id,category_instance_id,category_name');

    exception
        when others then
            log('msc_phub_util.decode_category_key.exception: '||sqlerrm);
            return 1;
    end decode_category_key;

    function decode_customer_key(p_staging_table varchar2, p_st_transaction_id number,
        p_customer_id_col varchar2,
        p_customer_site_id_col varchar2,
        p_region_id_col varchar2,
        p_customer_name_col varchar2,
        p_customer_site_code_col varchar2,
        p_zone_col varchar2)
        return number
    is
        l_sql varchar2(1000);
        l_unassigned varchar2(30) := msc_phub_util.get_planning_hub_message('MSC_HUB_UNASSIGNED');
    begin
        if p_customer_id_col is null then
            l_sql :=
                ' update '||p_staging_table||' f set (error_code, '||p_region_id_col||') ='||
                '     (select 0, d.region_id'||
                '     from msc_phub_customers_mv d'||
                '     where d.zone=nvl(f.'||p_zone_col||','''||l_unassigned||''')'||
                '     and rownum=1)'||
                ' where f.st_transaction_id=:p_st_transaction_id'||
                '     and f.error_code = 0';
        else
            l_sql :=
                ' update '||p_staging_table||' f set (error_code, '||p_customer_id_col||', '||p_customer_site_id_col||', '||p_region_id_col||') ='||
                '     (select 0, d.customer_id, d.customer_site_id, d.region_id'||
                '     from msc_phub_customers_mv d'||
                '     where d.customer_name=nvl(f.'||p_customer_name_col||','''||l_unassigned||''')'||
                '     and (d.customer_site='||p_customer_site_code_col||
                '         or ('||p_customer_site_code_col||' is null and d.customer_site_id=-23453))'||
                '     and d.zone=nvl(f.'||p_zone_col||','''||l_unassigned||''')'||
                '     and rownum=1)'||
                ' where f.st_transaction_id=:p_st_transaction_id'||
                '     and f.error_code = 0';
        end if;

        execute immediate l_sql using p_st_transaction_id;
        commit;
        return report_decode_error(p_staging_table, p_st_transaction_id, conv_key_err_customer,
            p_customer_name_col||','||p_customer_site_code_col||','||p_zone_col);

    exception
        when others then
            log('msc_phub_util.decode_customer_key.exception: '||sqlerrm);
            return 1;
    end decode_customer_key;

    function decode_supplier_key(p_staging_table varchar2, p_st_transaction_id number,
        p_supplier_id_col varchar2,
        p_supplier_site_id_col varchar2,
        p_region_id_col varchar2,
        p_supplier_name_col varchar2,
        p_supplier_site_code_col varchar2,
        p_zone_col varchar2)
        return number
    is
        l_sql varchar2(1000);
        l_unassigned varchar2(30) := msc_phub_util.get_planning_hub_message('MSC_HUB_UNASSIGNED');
    begin
        l_sql :=
            ' update '||p_staging_table||' f set (error_code, '||p_supplier_id_col||', '||p_supplier_site_id_col||', '||p_region_id_col||') ='||
            '     (select 0, d.supplier_id, d.supplier_site_id, d.region_id'||
            '     from msc_phub_suppliers_mv d'||
            '     where d.supplier_name=nvl(f.'||p_supplier_name_col||','''||l_unassigned||''')'||
            '     and d.supplier_site_code=nvl(f.'||p_supplier_site_code_col||','''||l_unassigned||''')'||
            '     and d.zone=nvl(f.'||p_zone_col||','''||l_unassigned||''')'||
            '     and rownum=1)'||
            ' where f.st_transaction_id=:p_st_transaction_id'||
            '     and f.error_code = 0';

        execute immediate l_sql using p_st_transaction_id;
        commit;
        return report_decode_error(p_staging_table, p_st_transaction_id, conv_key_err_supplier,
            p_supplier_name_col||','||p_supplier_site_code_col||','||p_zone_col);

    exception
        when others then
            log('msc_phub_util.decode_supplier_key.exception: '||sqlerrm);
            return 1;
    end decode_supplier_key;

    function decode_resource_key(p_staging_table varchar2, p_st_transaction_id number)
        return number
    is
        l_sql varchar2(1000);
    begin
        l_sql :=
            ' update '||p_staging_table||' f set (error_code, department_id, resource_id) ='||
            '     (select 0, d.department_id, d.resource_id'||
            '     from msc_department_resources d'||
            '     where d.plan_id=-1'||
            '         and nvl(d.department_code,0)=nvl(f.department_code,0)'||
            '         and nvl(d.department_class,0)=nvl(f.department_class,0)'||
            '         and nvl(d.resource_code,0)=nvl(f.resource_code,0)'||
            '         and nvl(d.resource_group_name,0)=nvl(f.resource_group_name,0)'||
            '         and d.sr_instance_id=f.sr_instance_id'||
            '         and d.organization_id=f.organization_id)'||
            ' where f.st_transaction_id=:p_st_transaction_id'||
            '     and f.error_code = 0'||
            '     and f.resource_code is not null';

        execute immediate l_sql using p_st_transaction_id;
        commit;
        return report_decode_error(p_staging_table, p_st_transaction_id, conv_key_err_resource,
            'department_code,department_class,resource_code,resource_group_name,organization_code');

    exception
        when others then
            log('msc_phub_util.decode_resource_key.exception: '||sqlerrm);
            return 1;
    end decode_resource_key;

    function decode_project_key(p_staging_table varchar2, p_st_transaction_id number)
        return number
    is
        l_sql varchar2(1000);
    begin
        l_sql :=
            ' update '||p_staging_table||' f set (error_code, project_id, task_id) ='||
            '     (select 0, d.project_id, d.task_id'||
            '     from msc_phub_projects_mv d'||
            '     where d.project_number=f.project_number'||
            '         and d.task_number=f.task_number'||
            '         and d.sr_instance_id=f.sr_instance_id'||
            '         and d.organization_id=f.organization_id)'||
            ' where f.st_transaction_id=:p_st_transaction_id'||
            '     and f.error_code = 0'||
            '     and f.task_number is not null';

        execute immediate l_sql using p_st_transaction_id;
        commit;
        return report_decode_error(p_staging_table, p_st_transaction_id, conv_key_err_project,
            'project_number,task_number,organization_code');

    exception
        when others then
            log('msc_phub_util.decode_project_key.exception: '||sqlerrm);
            return 1;
    end decode_project_key;

    function prepare_staging_dates(p_staging_table varchar2,
        date_col varchar2, p_st_transaction_id number,
        p_upload_mode number, p_overwrite_after_date date,
        p_plan_start_date date, p_plan_cutoff_date date)
        return number
    is
        l_sql varchar2(1000);
        l_result number := 0;
    begin
        log('msc_phub_util.prepare_staging_dates('||p_staging_table||','||
            date_col||','||p_st_transaction_id||','||
            p_upload_mode||','||p_overwrite_after_date||','||
            p_plan_start_date||','||p_plan_cutoff_date||')');

        if (date_col is null) then
            return 0;
        end if;

/*
        l_sql :=
            ' update '||p_staging_table||
            ' set error_code=:error_code'||
            ' where st_transaction_id=:p_st_transaction_id'||
            ' and ('||date_col||'<nvl(:p_plan_start_date,'||date_col||') or '||date_col||'>nvl(:p_plan_cutoff_date,'||date_col||'))';
        execute immediate l_sql using conv_key_err_date, p_st_transaction_id, p_plan_start_date, p_plan_cutoff_date;
        log('msc_phub_util.prepare_staging_dates:'||l_sql||', rowcount='||sql%rowcount);

        if (l_result > 0) then
            l_result := 1;
        end if;
        commit;
*/

        if (p_upload_mode = msc_phub_util.upload_append and
            p_overwrite_after_date is not null) then
            l_sql :=
                ' update '||p_staging_table||
                ' set error_code=:error_code'||
                ' where st_transaction_id=:p_st_transaction_id'||
                ' and '||date_col||'<=:p_overwrite_after_date';
            execute immediate l_sql using conv_date_filtered, p_st_transaction_id, p_overwrite_after_date;
            log('msc_phub_util.prepare_staging_dates:'||l_sql||', rowcount='||sql%rowcount);
        end if;
        commit;
        return l_result;

    exception
        when others then
            log('msc_phub_util.prepare_staging_dates.exception: '||sqlerrm);
            return 1;
    end prepare_staging_dates;

    function prepare_fact_dates(p_fact_table varchar2, p_is_plan_data number,
        date_col varchar2, p_plan_id number, p_plan_run_id number,
        p_upload_mode number, p_overwrite_after_date date)
        return number
    is
        l_sql varchar2(1000);
        l_plan_clause varchar2(100);
    begin
        log('msc_phub_util.prepare_fact_dates('||p_fact_table||','||
            p_is_plan_data||','||date_col||','||
            p_plan_id||','||p_plan_run_id||','||
            p_upload_mode||','||p_overwrite_after_date||')');

        if (p_is_plan_data = 1) then
            l_plan_clause := 'plan_id=:p_plan_id and plan_run_id=:p_plan_run_id';
        end if;

        if (p_upload_mode = msc_phub_util.upload_append and
            p_overwrite_after_date is not null and
            date_col is not null) then
            l_sql := 'delete from '||p_fact_table||
                ' where '||date_col||'>:p_overwrite_after_date';
            if (p_is_plan_data = 1) then
                l_sql := l_sql||' and '||l_plan_clause;
                execute immediate l_sql using p_overwrite_after_date, p_plan_id, p_plan_run_id;
            else
                execute immediate l_sql using p_overwrite_after_date;
            end if;
            log('msc_phub_util.prepare_fact_dates:'||l_sql||', rowcount='||sql%rowcount);
        end if;

        if (p_upload_mode = msc_phub_util.upload_replace) then
            l_sql := ' delete from '||p_fact_table;
            if (p_is_plan_data = 1) then
                l_sql := l_sql||' where '||l_plan_clause;
                execute immediate l_sql using p_plan_id, p_plan_run_id;
            else
                execute immediate l_sql;
            end if;
            log('msc_phub_util.prepare_fact_dates:'||l_sql||', rowcount='||sql%rowcount);
        end if;
        commit;
        return 0;

    exception
        when others then
            log('msc_phub_util.prepare_fact_dates.exception: '||sqlerrm);
            return 1;
    end prepare_fact_dates;

    function apps_schema return varchar2
    is
        l_apps_schema varchar2(30);
    begin
        select oracle_username
        into l_apps_schema
        from fnd_oracle_userid
        where read_only_flag = 'U';

        return l_apps_schema;
    end apps_schema;

    function get_resource_rn_qid(p_plan_id number, p_plan_run_id number) return number
    is
        l_qid number;
    begin
        select msc_hub_query_s.nextval into l_qid from dual;
        insert into msc_hub_query (
            query_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            number1,
            number2,
            number3,
            number4,
            number5
        )
        -- values
        select distinct l_qid, sysdate, -1, sysdate, -1, -1,
            mrr.plan_id,
            mrr.sr_instance_id,
            mrr.organization_id,
            mrr.department_id,
            mrr.resource_id
        from msc_resource_requirements mrr, msc_plan_runs mpr
        where mpr.plan_id = p_plan_id
            and mpr.plan_run_id = p_plan_run_id
            and mrr.plan_id = p_plan_id
            and mrr.sr_instance_id = mpr.sr_instance_id
            and trunc(nvl(mrr.end_date,mrr.start_date)) between mpr.plan_start_date and mpr.plan_cutoff_date
            and mrr.refresh_number > mpr.lcid

        union all
        select distinct l_qid, sysdate, -1, sysdate, -1, -1,
            mra.plan_id,
            mra.sr_instance_id,
            mra.organization_id,
            mra.department_id,
            mra.resource_id
        from msc_net_resource_avail mra, msc_plan_runs mpr
        where mpr.plan_id = p_plan_id
            and mpr.plan_run_id = p_plan_run_id
            and mra.plan_id = p_plan_id
            and mra.sr_instance_id = mpr.sr_instance_id
            and mra.simulation_set is null
            and trunc(trunc(mra.shift_date)) between mpr.plan_start_date and mpr.plan_cutoff_date
            and mra.refresh_number > mpr.lcid;

        log('msc_phub_util.get_resource_rn_qid, l_qid='||l_qid||', count='||sql%rowcount);
        commit;
        return l_qid;
    end get_resource_rn_qid;

    function get_item_rn_qid(p_plan_id number, p_plan_run_id number) return number
    is
        l_qid number;
    begin
        select msc_hub_query_s.nextval into l_qid from dual;
        insert into msc_hub_query (
            query_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            number1,
            number2,
            number3,
            number4
        )
        -- values
        select distinct l_qid, sysdate, -1, sysdate, -1, -1,
            ms.plan_id,
            ms.sr_instance_id,
            ms.organization_id,
            ms.inventory_item_id
        from msc_supplies ms, msc_plan_runs mpr
        where mpr.plan_id = p_plan_id
            and mpr.plan_run_id = p_plan_run_id
            and ms.plan_id = p_plan_id
            and ms.sr_instance_id = mpr.sr_instance_id
            and trunc(nvl(ms.firm_date,ms.new_schedule_date)) between mpr.plan_start_date and mpr.plan_cutoff_date
            and ms.refresh_number > mpr.lcid

        union all
        select distinct l_qid, sysdate, -1, sysdate, -1, -1,
            md.plan_id,
            md.sr_instance_id,
            md.organization_id,
            md.inventory_item_id
        from msc_demands md, msc_plan_runs mpr
        where mpr.plan_id = p_plan_id
            and mpr.plan_run_id = p_plan_run_id
            and md.plan_id = p_plan_id
            and md.sr_instance_id = mpr.sr_instance_id
            and trunc(nvl(md.firm_date,md.using_assembly_demand_date)) between mpr.plan_start_date and mpr.plan_cutoff_date
            and md.refresh_number > mpr.lcid;

        log('msc_phub_util.get_item_rn_qid, l_qid='||l_qid||', count='||sql%rowcount);
        commit;
        return l_qid;
    end get_item_rn_qid;

    function get_owning_currency_code(p_plan_run_id number) return varchar2
    is
        l_owning_currency_code varchar2(20);
    begin
        select nvl(o.currency_code, 'XXX')
        into l_owning_currency_code
        from msc_trading_partners o, msc_plan_runs r
        where o.sr_instance_id(+)=r.sr_instance_id
        and o.sr_tp_id(+)=r.organization_id
        and o.partner_type(+)=3
        and r.plan_run_id=p_plan_run_id;

        return l_owning_currency_code;
    exception
        when others then
            return 'XXX';
    end;

    function get_reporting_dates(p_plan_start_date date, p_plan_cutoff_date date) return number
    is
        l_qid_last_date number;
    begin
        select msc_hub_query_s.nextval into l_qid_last_date from dual;
        insert into msc_hub_query (
            query_id,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            date1
        )
        select distinct l_qid_last_date, sysdate, 1, sysdate, 1, 1, calendar_date
        from
            (select calendar_date from msc_phub_dates_mv
            where calendar_date between p_plan_start_date and p_plan_cutoff_date
            and calendar_date in (mfg_week_end_date, fis_period_end_date, month_end_date)
            union all
            select trunc(p_plan_cutoff_date) from dual);

        msc_phub_util.log('msc_phub_util.get_reporting_dates, l_qid_last_date='||l_qid_last_date||', count='||sql%rowcount);
        commit;

        return l_qid_last_date;
    end get_reporting_dates;

    function validate_customer_site_id(p_customer_id number, p_customer_site_id number)
        return number is
        l_customer_site_id number;
    begin
        select customer_site_id
        into l_customer_site_id
        from msc_phub_customers_mv
        where customer_id=p_customer_id
        and customer_site_id=p_customer_site_id;

        return l_customer_site_id;

    exception
        when others then return -23453;
    end validate_customer_site_id;

END msc_phub_util;

/
