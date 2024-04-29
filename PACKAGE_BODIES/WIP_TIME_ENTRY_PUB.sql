--------------------------------------------------------
--  DDL for Package Body WIP_TIME_ENTRY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_TIME_ENTRY_PUB" AS
/* $Header: wipwsilb.pls 120.10 2008/04/30 12:00:57 sisankar noship $ */

procedure  process_interface_records(retcode out nocopy number,
                                     errbuf  out nocopy varchar2,
                                     p_organization_id in number)
is

    l_shift_enabled boolean := false;
    l_clock_enabled boolean := False;
    l_valid_shift_pref boolean := true;
    l_valid_clock_pref boolean := true;
    l_conc_status   boolean;
    l_stmt_num      number;
    l_err_msg       varchar2(2000);
    l_return_status number;
    l_status        number :=0 ;
    l_temp          number;
    l_org_code      varchar2(3);
    l_count         number :=0;

    g_user_id         number;
    g_user_login_id   number;
    g_program_appl_id number;
    g_request_id      number;
    g_program_id      number;
    g_logLevel        number;

    v_wip_time_intf  t_wip_time_intf;

    cursor running_intf_records(org_id Number) is
    select *
    from wip_time_entry_interface
    where process_status  = wip_constants.running
    and organization_id = org_id;

    e_null_org_id  exception;

begin

    l_stmt_num := 10;

    if p_organization_id is null then
        raise e_null_org_id;
    end if;

    select organization_code
    into l_org_code
    from mtl_parameters
    where organization_id = p_organization_id;

    wip_ws_util.trace_log('Launching Import Time Entry Records for Organization: '||l_org_code);

    g_user_id         := fnd_global.user_id;
    g_user_login_id   := fnd_global.login_id;
    g_program_appl_id := fnd_global.prog_appl_id;
    g_request_id      := fnd_global.conc_request_id;
    g_program_id      := fnd_global.conc_program_id;
    g_logLevel        := FND_LOG.g_current_runtime_level;

    l_stmt_num := 20;

    begin
        select distinct case when (attribute_value_code/10) < 2 then 1 else 0 end
        into l_temp
        from wip_preference_values
        where preference_id=26 and
        level_id in (select level_id
                     from wip_preference_levels
                     where organization_id = p_organization_id and
                     resp_key is not null and
                     department_id is null);
    exception
        when too_many_rows then
            l_valid_shift_pref := false;
            fnd_message.set_name('WIP','WIP_INVALID_SHIFT_PREF');
            fnd_message.set_token('ORG', to_char(l_org_code));
            l_err_msg := fnd_message.get;

            update wip_time_entry_interface
            set process_status     = wip_constants.error,
            error                  = l_err_msg,
            request_id             = g_request_id,
            program_id             = g_program_id,
            program_application_id = g_program_appl_id,
            program_update_date    = sysdate,
            last_updated_by        = g_user_id,
            last_update_date       = sysdate,
            last_update_login      = g_user_login_id
            where
            time_entry_type     = 1
            and process_status  = wip_constants.pending
            and (organization_id = p_organization_id or
                 organization_code = (select mp.organization_code
                                      from mtl_parameters mp
                                      where mp.organization_id = p_organization_id));

            l_status := sql%rowcount;
            if l_status>0 then
                wip_ws_util.trace_log(l_err_msg);
            end if;

        when no_data_found then
            l_valid_shift_pref := true;
    end;

    begin
        select distinct decode(mod(attribute_value_code,10),1,1,0)
        into l_temp
        from wip_preference_values
        where preference_id=26 and
        level_id in (select level_id
                     from wip_preference_levels
                     where organization_id = p_organization_id and
                     resp_key is not null and
                     department_id is null);
    exception
        when too_many_rows then
            l_valid_clock_pref := false;
            fnd_message.set_name('WIP','WIP_INVALID_CLOCK_PREF');
            fnd_message.set_token('ORG', to_char(l_org_code));
            l_err_msg := fnd_message.get;

            update wip_time_entry_interface
            set process_status     = wip_constants.error,
            error                  = l_err_msg,
            request_id             = g_request_id,
            program_id             = g_program_id,
            program_application_id = g_program_appl_id,
            program_update_date    = sysdate,
            last_updated_by        = g_user_id,
            last_update_date       = sysdate,
            last_update_login      = g_user_login_id
            where
            time_entry_type     = 3
            and process_status  = wip_constants.pending
            and (organization_id = p_organization_id or
                 organization_code = (select mp.organization_code
                                      from mtl_parameters mp
                                      where mp.organization_id = p_organization_id));

            l_count := sql%rowcount;
            l_status := l_status+l_count;
            if l_count >0 then
                wip_ws_util.trace_log(l_err_msg);
            end if;

        when no_data_found then
            l_valid_clock_pref := true;
    end;

    get_time_preferences(p_organization_id => p_organization_id,
                         x_shift_enabled   => l_shift_enabled,
                         x_clock_enabled   => l_clock_enabled);


    l_stmt_num := 30;
    if l_shift_enabled and l_valid_shift_pref then

        fnd_message.set_name('WIP','WIP_AAH_IMPORT_NOT_ALLOWED');
        l_err_msg := fnd_message.get;

        update wip_time_entry_interface
        set process_status     = wip_constants.error,
        error                  = l_err_msg,
        request_id             = g_request_id,
        program_id             = g_program_id,
        program_application_id = g_program_appl_id,
        program_update_date    = sysdate,
        last_updated_by        = g_user_id,
        last_update_date       = sysdate,
        last_update_login      = g_user_login_id
        where
        time_entry_type     = 1
        and process_status  = wip_constants.pending
        and (organization_id = p_organization_id or
             organization_code = (select mp.organization_code
                                  from mtl_parameters mp
                                  where mp.organization_id = p_organization_id));

        l_count := sql%rowcount;
        l_status := l_status+l_count;
        if l_count >0 then
            wip_ws_util.trace_log(l_err_msg);
        end if;

    end if;
    l_stmt_num := 40;
    if l_clock_enabled and l_valid_clock_pref then

        fnd_message.set_name('WIP','WIP_DLH_IMPORT_NOT_ALLOWED');
        l_err_msg := fnd_message.get;

        update wip_time_entry_interface
        set process_status     = wip_constants.error,
        error                  = l_err_msg,
        request_id             = g_request_id,
        program_id             = g_program_id,
        program_application_id = g_program_appl_id,
        program_update_date    = sysdate,
        last_updated_by        = g_user_id,
        last_update_date       = sysdate,
        last_update_login      = g_user_login_id
        where
        time_entry_type     = 3
        and process_status  = wip_constants.pending
        and (organization_id = p_organization_id or
             organization_code = (select mp.organization_code
                                  from mtl_parameters mp
                                  where mp.organization_id = p_organization_id));

        l_count := sql%rowcount;
        l_status := l_status+l_count;
        if l_count >0 then
            wip_ws_util.trace_log(l_err_msg);
        end if;

    end if;
    l_stmt_num := 50;

    update wip_time_entry_interface
    set process_status     = wip_constants.running,
    organization_id        = nvl(organization_id,p_organization_id),
    request_id             = fnd_global.conc_request_id,
    program_id             = fnd_global.conc_program_id,
    program_application_id = fnd_global.prog_appl_id,
    program_update_date    = sysdate,
    last_updated_by        = fnd_global.user_id,
    last_update_date       = sysdate,
    last_update_login      = fnd_global.login_id
    where
    process_status  = wip_constants.pending
    and (organization_id = p_organization_id or
         organization_code = (select mp.organization_code
                              from mtl_parameters mp
                              where mp.organization_id = p_organization_id));

    l_stmt_num := 55;
    /* Added for Bug 6908314. This SQL will default employee_id from badge_id. */
    update wip_time_entry_interface wtei
    set wtei.employee_id   = ( select bre.person_id
                               from per_all_people_f papf,
                                    bom_resource_employees bre
                               where  papf.person_id = bre.person_id
                               and sysdate between papf.effective_start_date and nvl(papf.effective_end_date,sysdate+1)
                               and bre.organization_id = wtei.organization_id
                               and papf.employee_number = wtei.badge_id
                               and rownum=1
                             ),
    wtei.last_update_date  = sysdate
    where
    wtei.organization_id = p_organization_id and
    wtei.process_status  = wip_constants.running and
    wtei.employee_id is null and
    wtei.badge_id is not null;

    l_stmt_num := 60;

    open running_intf_records(p_organization_id);
    fetch running_intf_records bulk collect into v_wip_time_intf;
    close running_intf_records;

    l_stmt_num := 70;

    if (g_logLevel <= wip_constants.trace_logging) then
        wip_ws_util.trace_log('Launching Process to import the records');
    end if;

    process( p_wip_time_intf_tbl => v_wip_time_intf,
             x_ret_status        => l_return_status);

    l_stmt_num := 80;

    if (g_logLevel <= wip_constants.trace_logging) then
        wip_ws_util.trace_log('Returned from Process after importing the records');
    end if;

    commit;

    if l_return_status = 1 and l_status =0 then
        retcode :=1;
        errbuf := 'The Import program successfully imported all records';
        wip_ws_util.trace_log(errbuf);
        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',errbuf);
    else
        retcode := 1;
        errbuf := 'The Import program marked at least one row as errored';
        wip_ws_util.trace_log(errbuf);
        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',errbuf);
    end if;

exception
    when e_null_org_id then
        retcode := -1;
        errbuf := 'Organization parameter cannot be null';
        wip_ws_util.trace_log(errbuf);
        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',errbuf);
    when others then
        retcode := -1;
        errbuf := 'Errors encountered in interface txn, please check the log file.';
        wip_ws_util.trace_log(errbuf);
        wip_ws_util.trace_log(sqlerrm(sqlcode));
        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',errbuf);
end process_interface_records;

procedure get_time_preferences(p_organization_id IN NUMBER default null,
                               x_shift_enabled OUT NOCOPY boolean,
                               x_clock_enabled OUT NOCOPY boolean)
is

l_level_id      Number;
l_pref_value    Number;
l_shift_value   Number;
l_clock_value   Number;
begin

    begin
        -- How to get Resp key here. Without Resp key this will return multiple rows.
        -- One option is to use resp_id from which the concurrent program is executed.
        -- another option is to use rownum. Since it doesn't make any sense to have
        -- different settings w.r.t time entry parameters for different responsibilities,
        -- we will use rownum.

        select level_id
        into l_level_id
        from wip_preference_levels
        where organization_id = p_organization_id
        and department_id is null
        and level_id in (select level_id
                         from wip_preference_values
                         where preference_id = 26)
        and rownum=1;

    exception
        when no_data_found then
            l_level_id :=1; -- set levet to Site level
        when too_many_rows then -- It will never reach here.
            l_level_id :=1; -- Currently set to site level.
        when others then
            l_level_id :=0;
    end;

    begin
        select to_number(attribute_value_code)
        into l_pref_value
        from wip_preference_values
        where level_id = l_level_id
        and preference_id = 26;
    exception
        when no_data_found then
        -- this might happen if lower level parameters have inherited them from upper levels.
        -- if records are inherited from upper level, then we will look directly at site level.
        -- if records are inherited, then we will consider site as the upper level and not responsibility.

            select to_number(attribute_value_code)
            into l_pref_value
            from wip_preference_values
            where level_id = 1
            and preference_id = 26;

        when others then
            l_pref_value :=0;
    end;

    l_shift_value := l_pref_value/10;
    l_clock_value := mod(l_pref_value,10);

    If l_shift_value < 2 then
        x_shift_enabled := false;
    else
        x_shift_enabled := true;
    end if;

    If l_clock_value = 1 then
        x_clock_enabled := false;
    else
        x_clock_enabled := true;
    end if;
end get_time_preferences;

function default_res_id(p_org_id  in number,
                        p_wip_id  in number,
                        p_op_seq  in number,
                        p_res_seq in number)

return number is
l_res_id number;
begin

    select resource_id
    into l_res_id
    from wip_operation_resources
    where organization_id = p_org_id
    and wip_entity_id = p_wip_id
    and operation_seq_num = p_op_seq
    and resource_seq_num = p_res_seq;

    return l_res_id;
exception
    when others then
        return null;
end default_res_id;

procedure process(p_wip_time_intf_tbl in t_wip_time_intf,
                  x_ret_status    out nocopy number)
is

l_wip_time_intf_tbl t_wip_time_intf;
l_counter number;
l_error_count number :=0;
l_stmt_num number;
ins_counter number;
type t_wip_res_actual_times is table of wip_resource_actual_times%rowtype index by binary_integer;
v_wip_res_actual_times  t_wip_res_actual_times;

type t_interface_id   is table of wip_time_entry_interface.interface_id%type index by binary_integer;
type t_process_status is table of wip_time_entry_interface.process_status%type index by binary_integer;
type t_error          is table of wip_time_entry_interface.error%type index by binary_integer;

v_interface_id   t_interface_id;
v_process_status t_process_status;
v_error          t_error;
pop_counter number :=1;
l_bom_hr_uom varchar2(3);
l_duration number := 0;
g_logLevel number;

begin

    g_logLevel        := FND_LOG.g_current_runtime_level;
    l_stmt_num :=10;
    l_bom_hr_uom := fnd_profile.value('BOM:HOUR_UOM_CODE');
    l_wip_time_intf_tbl := p_wip_time_intf_tbl;
    l_counter := l_wip_time_intf_tbl.first;
    ins_counter := 1;
    l_stmt_num :=20;

    if (g_logLevel <= wip_constants.trace_logging) then
            wip_ws_util.trace_log('Beginning to process interface records');
    end if;

    while l_counter is not null loop
        if l_wip_time_intf_tbl(l_counter).actual_start_date is null or
          (l_wip_time_intf_tbl(l_counter).actual_end_date is null and
           l_wip_time_intf_tbl(l_counter).duration is null) then
           l_stmt_num :=30;
            fnd_message.set_name('WIP','WIP_TIME_IMPORT_DATE_NULL');
            l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
            l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
            l_error_count := l_error_count +1;
            wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                    l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
            goto skip_validations;
        end if;
        l_stmt_num :=35;
        if l_wip_time_intf_tbl(l_counter).time_entry_type = 1 or
           l_wip_time_intf_tbl(l_counter).time_entry_type = 2 then /* Actual Attendance Hours,
                                                                      Scheduled Available Hours */
            if l_wip_time_intf_tbl(l_counter).time_entry_type = 2 and nvl(l_wip_time_intf_tbl(l_counter).action_flag,-1) not in (1,2) then
                 fnd_message.set_name('WIP','WIP_SAH_ONLY_ADJUSTMENT');
                 l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
                 l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
                 l_error_count := l_error_count +1;
                 wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                    l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
                 goto skip_validations;
            end if;

            l_stmt_num :=40;
            if l_wip_time_intf_tbl(l_counter).wip_entity_id is not null or
               l_wip_time_intf_tbl(l_counter).job_name is not null or
               l_wip_time_intf_tbl(l_counter).operation_seq_num is not null or
               l_wip_time_intf_tbl(l_counter).resource_seq_num is not null then
                  l_wip_time_intf_tbl(l_counter).wip_entity_id := null;
                  l_wip_time_intf_tbl(l_counter).operation_seq_num := null;
                  l_wip_time_intf_tbl(l_counter).resource_seq_num := null;
                  fnd_message.set_name('WIP','WIP_IMP_JOB_IGNORED');
                  l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
                  l_wip_time_intf_tbl(l_counter).process_status := wip_constants.warning;
                  l_error_count := l_error_count +1;
                  if (g_logLevel <= wip_constants.trace_logging) then
                      wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                        l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
                  end if;
            end if;
            l_stmt_num :=50;
            if l_wip_time_intf_tbl(l_counter).employee_id is null then
                 fnd_message.set_name('WIP','WIP_NO_EMP_DETAILS');
                 l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
                 l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
                 l_error_count := l_error_count +1;
                 wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                    l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
                 goto skip_validations;
             end if;
             l_stmt_num :=60;
             if is_emp_invalid(p_org_id  => l_wip_time_intf_tbl(l_counter).organization_id,
                               p_dep_id  => null,
                               p_res_id  => null,
                               p_emp_id  => l_wip_time_intf_tbl(l_counter).employee_id) then
                 fnd_message.set_name('WIP','WIP_INVALID_EMP_DETAILS');
                 l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
                 l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
                 l_error_count := l_error_count +1;
                 wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                    l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
                 goto skip_validations;
             end if;
             l_stmt_num :=70;
        elsif l_wip_time_intf_tbl(l_counter).time_entry_type = 3 then /* Direct Labor Hours */
            l_stmt_num :=80;
            if l_wip_time_intf_tbl(l_counter).wip_entity_id is null and
               l_wip_time_intf_tbl(l_counter).job_name is null then
                   fnd_message.set_name('WIP','WIP_NO_JOB_DETAILS');
                   l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
                   l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
                   l_error_count := l_error_count +1;
                   wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                    l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
                   goto skip_validations;
            elsif l_wip_time_intf_tbl(l_counter).wip_entity_id is null and
                  l_wip_time_intf_tbl(l_counter).job_name is not null then
                  l_wip_time_intf_tbl(l_counter).wip_entity_id := default_job_id(p_org_id   => l_wip_time_intf_tbl(l_counter).organization_id,
                                                                                 p_job_name => l_wip_time_intf_tbl(l_counter).job_name);
            end if;
            l_stmt_num :=90;
            if is_job_invalid(p_org_id => l_wip_time_intf_tbl(l_counter).organization_id,
                              p_we_id  => l_wip_time_intf_tbl(l_counter).wip_entity_id) then
                fnd_message.set_name('WIP','WIP_INVALID_JOB_DETAILS');
                l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
                l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
                l_error_count := l_error_count +1;
                wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                    l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
                goto skip_validations;
            end if;
            l_stmt_num :=100;
            if l_wip_time_intf_tbl(l_counter).operation_seq_num is null then
                fnd_message.set_name('WIP','WIP_JOB_OP_NULL');
                l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
                l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
                l_error_count := l_error_count +1;
                wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                    l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
                goto skip_validations;
            else
                l_stmt_num :=110;
                l_wip_time_intf_tbl(l_counter).department_id := get_op_dept_id(p_org_id => l_wip_time_intf_tbl(l_counter).organization_id,
                                                                               p_we_id  => l_wip_time_intf_tbl(l_counter).wip_entity_id,
                                                                               p_op_seq => l_wip_time_intf_tbl(l_counter).operation_seq_num);
                if l_wip_time_intf_tbl(l_counter).department_id < 0 then
                    fnd_message.set_name('WIP','WIP_INVALID_JOB_OP');
                    l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
                    l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
                    l_error_count := l_error_count +1;
                    wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                        l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
                    goto skip_validations;
                end if;
            end if;
            l_stmt_num :=120;
            if l_wip_time_intf_tbl(l_counter).resource_id is null and
               l_wip_time_intf_tbl(l_counter).resource_code is null and
               l_wip_time_intf_tbl(l_counter).resource_seq_num is null then
                fnd_message.set_name('WIP','WIP_NO_RES_DETAILS');
                l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
                l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
                l_error_count := l_error_count +1;
                wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                    l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
                goto skip_validations;
            elsif l_wip_time_intf_tbl(l_counter).resource_id is null and
                l_wip_time_intf_tbl(l_counter).resource_code is not null and
                l_wip_time_intf_tbl(l_counter).resource_seq_num is null then
                l_wip_time_intf_tbl(l_counter).resource_id := default_res_id(p_org_id   => l_wip_time_intf_tbl(l_counter).organization_id,
                                                                             p_res_name => l_wip_time_intf_tbl(l_counter).resource_code);
            elsif l_wip_time_intf_tbl(l_counter).resource_id is null and
                l_wip_time_intf_tbl(l_counter).resource_seq_num is not null then
                l_wip_time_intf_tbl(l_counter).resource_id := default_res_id(p_org_id   => l_wip_time_intf_tbl(l_counter).organization_id,
                                                                             p_wip_id   => l_wip_time_intf_tbl(l_counter).wip_entity_id,
                                                                             p_op_seq   => l_wip_time_intf_tbl(l_counter).operation_seq_num,
                                                                             p_res_seq  => l_wip_time_intf_tbl(l_counter).resource_seq_num);

            end if;
            l_stmt_num :=130;
            if is_res_invalid(p_org_id  => l_wip_time_intf_tbl(l_counter).organization_id,
                              p_dep_id  => l_wip_time_intf_tbl(l_counter).department_id,
                              p_res_id  => l_wip_time_intf_tbl(l_counter).resource_id) then
                fnd_message.set_name('WIP','WIP_INVALID_RES_DETAILS');
                l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
                l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
                l_error_count := l_error_count +1;
                wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                    l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
                goto skip_validations;
            end if;
            l_stmt_num :=140;
            if l_wip_time_intf_tbl(l_counter).employee_id is null then
                fnd_message.set_name('WIP','WIP_NO_EMP_DETAILS');
                l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
                l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
                l_error_count := l_error_count +1;
                wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                    l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
                goto skip_validations;
            end if;
            l_stmt_num :=150;
            if is_emp_invalid(p_org_id  => l_wip_time_intf_tbl(l_counter).organization_id,
                              p_dep_id  => l_wip_time_intf_tbl(l_counter).department_id,
                              p_res_id  => l_wip_time_intf_tbl(l_counter).resource_id,
                              p_emp_id  => l_wip_time_intf_tbl(l_counter).employee_id) then
                fnd_message.set_name('WIP','WIP_INVALID_EMP_DETAILS');
                l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
                l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
                l_error_count := l_error_count +1;
                wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                    l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
                goto skip_validations;
            end if;
            l_stmt_num :=160;
        else
            fnd_message.set_name('WIP','WIP_INVALID_TIME_TYPE');
            l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
            l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
            l_error_count := l_error_count +1;
            wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                    l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
            goto skip_validations;
        end if;
        l_stmt_num :=180;
        if ((l_wip_time_intf_tbl(l_counter).actual_end_date is null) or
            (l_wip_time_intf_tbl(l_counter).actual_end_date is not null and
             l_wip_time_intf_tbl(l_counter).duration is not null)) then

            if wip_ws_labor_metric_pub.is_time_uom(l_wip_time_intf_tbl(l_counter).uom_code) <> 1 or
                l_wip_time_intf_tbl(l_counter).uom_code is null then
                fnd_message.set_name('WIP','WIP_INVALID_TIME_UOM');
                l_wip_time_intf_tbl(l_counter).error          := fnd_message.get;
                l_wip_time_intf_tbl(l_counter).process_status := wip_constants.error;
                l_error_count := l_error_count +1;
                wip_ws_util.trace_log('Error Importing record '||'( stmt_num: '||l_stmt_num||') '||
                    l_wip_time_intf_tbl(l_counter).error||' for Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
                goto skip_validations;
            end if;

            if l_wip_time_intf_tbl(l_counter).uom_code <> l_bom_hr_uom then
                l_duration := inv_convert.inv_um_convert(item_id       => -1,
                                                         precision     => 38,
                                                         from_quantity => l_wip_time_intf_tbl(l_counter).duration,
                                                         from_unit     => l_wip_time_intf_tbl(l_counter).uom_code,
                                                         to_unit       => l_bom_hr_uom,
                                                         from_name     => null,
                                                         to_name       => null);
            else
                l_duration := l_wip_time_intf_tbl(l_counter).duration;
            end if;
            l_wip_time_intf_tbl(l_counter).actual_end_date := l_wip_time_intf_tbl(l_counter).actual_start_date +
                                                              (l_duration/24);
            l_wip_time_intf_tbl(l_counter).duration := l_duration;
            l_wip_time_intf_tbl(l_counter).uom_code := l_bom_hr_uom;
        end if;
        l_stmt_num :=190;
        if l_wip_time_intf_tbl(l_counter).duration is null then
            l_wip_time_intf_tbl(l_counter).duration := (l_wip_time_intf_tbl(l_counter).actual_end_date -
                                                              l_wip_time_intf_tbl(l_counter).actual_start_date)*24;
            l_wip_time_intf_tbl(l_counter).uom_code := l_bom_hr_uom;
        end if;

        if (g_logLevel <= wip_constants.trace_logging) then
            wip_ws_util.trace_log('Completed validations for record in Intf Id: '||l_wip_time_intf_tbl(l_counter).interface_id);
        end if;

        l_stmt_num :=200;
        <<skip_validations>>
        if l_wip_time_intf_tbl(l_counter).process_status = wip_constants.running or
           l_wip_time_intf_tbl(l_counter).process_status = wip_constants.warning then
        select wip_resource_actual_times_s.nextval
        into v_wip_res_actual_times(ins_counter).time_entry_id from dual;
        v_wip_res_actual_times(ins_counter).organization_id           := l_wip_time_intf_tbl(l_counter).organization_id;
        v_wip_res_actual_times(ins_counter).wip_entity_id             := l_wip_time_intf_tbl(l_counter).wip_entity_id;
        v_wip_res_actual_times(ins_counter).operation_seq_num         := l_wip_time_intf_tbl(l_counter).operation_seq_num;
        v_wip_res_actual_times(ins_counter).resource_id               := l_wip_time_intf_tbl(l_counter).resource_id;
        v_wip_res_actual_times(ins_counter).resource_seq_num          := l_wip_time_intf_tbl(l_counter).resource_seq_num;
        v_wip_res_actual_times(ins_counter).instance_id               := null;
        v_wip_res_actual_times(ins_counter).serial_number             := null;
        select decode(l_wip_time_intf_tbl(l_counter).time_entry_type,1,6,2,7,3,5)
        into v_wip_res_actual_times(ins_counter).time_entry_mode from dual;
        v_wip_res_actual_times(ins_counter).cost_flag                 := 'N';
        v_wip_res_actual_times(ins_counter).add_to_rtg                := 'N';
        v_wip_res_actual_times(ins_counter).status_type               := 2;
        v_wip_res_actual_times(ins_counter).start_date                := l_wip_time_intf_tbl(l_counter).actual_start_date;
        v_wip_res_actual_times(ins_counter).end_date                  := l_wip_time_intf_tbl(l_counter).actual_end_date;
        v_wip_res_actual_times(ins_counter).projected_completion_date := null;
        v_wip_res_actual_times(ins_counter).duration                  := l_wip_time_intf_tbl(l_counter).duration;
        v_wip_res_actual_times(ins_counter).uom_code                  := l_wip_time_intf_tbl(l_counter).uom_code;
        v_wip_res_actual_times(ins_counter).employee_id               := l_wip_time_intf_tbl(l_counter).employee_id;
        v_wip_res_actual_times(ins_counter).process_status            := 1;
        v_wip_res_actual_times(ins_counter).created_by                := fnd_global.user_id;
        v_wip_res_actual_times(ins_counter).creation_date             := sysdate;
        v_wip_res_actual_times(ins_counter).last_updated_by           := fnd_global.user_id;
        v_wip_res_actual_times(ins_counter).last_update_date         := sysdate;
        v_wip_res_actual_times(ins_counter).last_update_login         := fnd_global.login_id;
        v_wip_res_actual_times(ins_counter).object_version_number     := 1;
        v_wip_res_actual_times(ins_counter).action_flag               := l_wip_time_intf_tbl(l_counter).action_flag;
        v_wip_res_actual_times(ins_counter).request_id                := fnd_global.conc_request_id;
        v_wip_res_actual_times(ins_counter).program_id                := fnd_global.conc_program_id;
        v_wip_res_actual_times(ins_counter).program_application_id    := fnd_global.prog_appl_id;
        v_wip_res_actual_times(ins_counter).program_update_date       := sysdate;
        ins_counter := ins_counter+1;
        end if;
        v_process_status(pop_counter) := l_wip_time_intf_tbl(l_counter).process_status;
        v_error(pop_counter)          := l_wip_time_intf_tbl(l_counter).error;
        v_interface_id(pop_counter)   :=l_wip_time_intf_tbl(l_counter).interface_id;
        pop_counter := pop_counter+1;
        l_counter := l_wip_time_intf_tbl.next(l_counter);
    end loop;

    if (g_logLevel <= wip_constants.trace_logging) then
            wip_ws_util.trace_log('Before Inserting records in Actual Times Table');
    end if;

    -- insert into wip_resource_actual_times table
    forall ins_index in v_wip_res_actual_times.first..v_wip_res_actual_times.last
    INSERT into WIP_RESOURCE_ACTUAL_TIMES values v_wip_res_actual_times(ins_index);

    if (g_logLevel <= wip_constants.trace_logging) then
            wip_ws_util.trace_log('After Inserting records in Actual Times Table');
    end if;

    -- update back wip_time_entry_interface table
    forall upd_index in v_interface_id.first..v_interface_id.last
    update wip_time_entry_interface set
    process_status   = decode(v_process_status(upd_index),
                              wip_constants.running,wip_constants.completed,v_process_status(upd_index) ),
    error            = v_error(upd_index),
    last_update_date = sysdate
    where interface_id = v_interface_id(upd_index);

    if (g_logLevel <= wip_constants.trace_logging) then
            wip_ws_util.trace_log('After Updating status for records in Interface Table');
    end if;

      if l_error_count > 0 then
          x_ret_status := -1;
      else
          x_ret_status := 1;
      end if;
end process;

procedure write_to_log(p_interface_id in number,
                       p_error_msg in varchar2,
                       p_stmt_num in number)
is
begin
    fnd_file.put_line(fnd_file.log,'Error while importing time entry record '||'( stmt_num: '||p_stmt_num||') '||p_error_msg||' for interface Id: '||p_interface_id);
    fnd_file.new_line(fnd_file.log, 2);
end write_to_log;

function is_emp_invalid(p_org_id in number,
                        p_dep_id in number,
                        p_res_id in number,
                        p_emp_id in number)
return boolean is
l_count number;
begin
    if p_dep_id is not null then
        select count(1)
        into l_count
        from bom_resource_employees bre,
             bom_department_resources bdr
        where bdr.department_id = p_dep_id
        and bdr.resource_id = p_res_id
        and bdr.resource_id = bre.resource_id
        and bre.organization_id = p_org_id
        and bre.person_id = p_emp_id;
    else
        select count(1)
        into l_count
        from bom_resource_employees bre
        where bre.organization_id = p_org_id
        and bre.person_id = p_emp_id
        and bre.resource_id = nvl(p_res_id,bre.resource_id);
    end if;
    if l_count >= 1 then
         return false;
     else
         return true;
     end if;
end is_emp_invalid;

function default_job_id(p_org_id   in number,
                        p_job_name in varchar2)
return number is
    l_we_id number;
begin
    select wip_entity_id
    into l_we_id
    from wip_entities
    where wip_entity_name = p_job_name
    and organization_id = p_org_id;
    return l_we_id;
exception
    when others then
        return null;
end default_job_id;

function is_job_invalid(p_org_id in number,
                        p_we_id  in number)
return boolean is
     l_count number;
begin
     select count(1)
     into l_count
     from wip_discrete_jobs wdj
     where wdj.organization_id = p_org_id
     and wdj.wip_entity_id = p_we_id
     and wdj.status_type in (wip_constants.released,wip_constants.comp_chrg,wip_constants.hold);

     if l_count = 0 then
         return true;
     else
         return false;
     end if;
end is_job_invalid;

function get_op_dept_id(p_org_id in number,
                        p_we_id  in number,
                        p_op_seq in number)
return number is
l_dep_id number;
begin
    select department_id
    into l_dep_id
    from wip_operations
    where organization_id=p_org_id
    and wip_entity_id=p_we_id
    and operation_seq_num=p_op_seq;
    return l_dep_id;
exception
    when others then
        return -1;
end get_op_dept_id;

function default_res_id(p_org_id   in number,
                        p_res_name in varchar)
return number is
l_res_id number;
begin
    select resource_id
    into l_res_id
    from bom_resources
    where organization_id = p_org_id
    and resource_code = p_res_name;
    return l_res_id;
exception
    when others then
        return null;
end default_res_id;

function is_res_invalid(p_org_id in number,
                        p_dep_id in number,
                        p_res_id in number)
return boolean is
l_count number;
begin
    select count(1)
    into l_count
    from bom_department_resources bdr,
         bom_departments bd
    where bdr.department_id= bd.department_id
    and bd.organization_id = p_org_id
    and bd.department_id = p_dep_id
    and bdr.resource_id = p_res_id;

    if l_count >= 1 then
         return false;
     else
         return true;
     end if;
end is_res_invalid;

function is_emp_shift_in(p_wip_entity_id in number,
                         p_employee_id   in number)
return boolean is

l_org_id number;
l_count number;
l_value varchar2(2);
l_shift_value number;
begin

    select organization_id
    into l_org_id
    from wip_entities
    where wip_entity_id = p_wip_entity_id;

    l_value := wip_ws_util.get_preference_value_code(p_pref_id   => 26,
                                                     p_resp_key  => WIP_WS_UTIL.get_current_resp_key,
                                                     p_org_id    => l_org_id,
                                                     p_dept_id   => null);
    l_shift_value := to_number(l_value)/10;
    if l_shift_value >= 2 then

        /* If this query returns count as 1 then employee has already shifted in. */
        select count(1)
        into l_count
        from wip_resource_actual_times
        where organization_id = l_org_id
        and employee_id = p_employee_id
        and wip_entity_id is null
        and time_entry_mode = 8
        and end_date is null;

        if l_count >= 1 then
            return true;
        else
            return false;
        end if;

    else
        return true;
    end if;

exception
    when others then
        return false;

end is_emp_shift_in;

END WIP_TIME_ENTRY_PUB;

/
