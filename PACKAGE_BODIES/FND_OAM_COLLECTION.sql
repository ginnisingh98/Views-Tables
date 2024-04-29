--------------------------------------------------------
--  DDL for Package Body FND_OAM_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_COLLECTION" AS
  /* $Header: AFOAMCLB.pls 120.7 2007/01/03 20:02:35 ravmohan noship $ */
  -- Some Constants to define the various agents we will be pinging
  AOLJ_DB_POOL constant number := 1;
  PLSQL_AGNT constant number := 2;
  SERVLET_AGNT constant number := 3;
  JSP constant number := 4;
  TCF constant number := 5;
  JTF constant number := 6;
  DISCOVERER constant number := 7;
  PHP constant number := 8;
  REPORT constant number := 9;
  FORMS constant number := 10;
  FWK constant number := 11;

  AGENT_MIN constant number := PLSQL_AGNT;
  AGENT_MAX constant number := PHP;

  -- Some constants to define status values
  STATUS_NORMAL constant number := 0;
  STATUS_WARNING constant number := 1;
  STATUS_ERROR constant number := 2;
  STATUS_INACTIVE constant number := 3;
  STATUS_UNKNOWN constant number := 4;

  -- Some constants to define operator codes
  OPER_E constant varchar2(1) := 'E';
  OPER_G constant varchar2(1) := 'G';
  OPER_L constant varchar2(1) := 'L';
  OPER_I constant varchar2(1) := 'I';

  -- internal constant for group id for Applications Systems Status Group
  APP_SYS_STATUS constant number := 7;

  -- internal type used for computation of rollup status
  TYPE st_table IS TABLE OF number index by binary_integer;

  -- Module name for this package
  MODULE constant varchar2(200) := 'fnd.plsql.FND_OAM_COLLECTION';

  PROCEDURE debug (p_txt varchar2)
  IS

  BEGIN
        --dbms_output.put_line(p_txt);
        null;
  END debug;

  --
  -- Checks if currently we are in the context of a concurrent
  -- request (i.e. FNDOAMCOL execution) or not.
  --
  FUNCTION is_request RETURN boolean
  IS
    v_conc_req_id fnd_concurrent_requests.request_id%TYPE;
    v_retu boolean := false;
  BEGIN
    -- check if its concurrent request
    select fnd_global.conc_request_id into v_conc_req_id from dual;
    if v_conc_req_id > 0 then
      v_retu := true;
    end if;
    return v_retu;
  END is_request;

  --
  -- Gets the current user id
  --
  FUNCTION get_user_id RETURN number
   IS
        v_userid number;
        v_conc_req_id number;
   BEGIN
        -- check if its concurrent request
        select fnd_global.conc_request_id into v_conc_req_id from dual;
        if v_conc_req_id > 0 then
          select fcr.requested_by into v_userid
            from fnd_concurrent_requests fcr
            where fcr.request_id = v_conc_req_id;
        else
          select fnd_global.user_id into v_userid from dual;
          if (v_userid < 0 or v_userid is null) then
                v_userid := 0; -- default
          end if;
        end if;

        return v_userid;
   EXCEPTION
        when others then
          v_userid := 0;
          return v_userid;
   END get_user_id;

  --
  -- Checks to see if the value for the given metric needs to be
  -- collected
  --
  -- Note:
  --   For use for Dashbaord Collection Program only.
  --
  FUNCTION is_collection_enabled (p_metric_short_name varchar2) RETURN boolean
  IS
    v_is_supported fnd_oam_metval.is_supported%TYPE;
    v_collection_enabled_flag fnd_oam_metval.collection_enabled_flag%TYPE;
    v_retu boolean := TRUE;
  BEGIN
    select nvl(is_supported,'Y'), nvl(collection_enabled_flag,'Y')
        into v_is_supported, v_collection_enabled_flag
        from fnd_oam_metval
        where metric_short_name = p_metric_short_name
        and rownum = 1;

   if (v_is_supported = 'N' or v_collection_enabled_flag = 'N') then
        v_retu := FALSE;
   end if;

   --if (v_retu) then
   --  dbms_output.put_line('COLLECTION_ENABLED: ' || p_metric_short_name || ': '|| 'TRUE');
   --else
   --  dbms_output.put_line('COLLECTION_ENABLED: ' || p_metric_short_name || ': '|| 'FALSE');
   --end if;

   return v_retu;
  EXCEPTION
        when no_data_found then
                --dbms_output.put_line('COLLECTION_ENABLED: ' || p_metric_short_name || ': ' || 'FALSE');
                return FALSE;
  END is_collection_enabled;

  --
  -- Checks to see if the value for the given service instance needs to
  -- be collected
  --
  FUNCTION is_collection_enabled (
        p_application_id number,
        p_concurrent_queue_name varchar2) RETURN boolean
  IS
    v_collection_enabled_flag fnd_oam_svci_info.collection_enabled_flag%TYPE;
    v_retu boolean := TRUE;
  BEGIN
    select nvl(collection_enabled_flag, 'Y')
        into v_collection_enabled_flag
        from fnd_oam_svci_info
        where application_id = p_application_id
        and concurrent_queue_name = p_concurrent_queue_name;
    if (v_collection_enabled_flag = 'N') then
        v_retu := FALSE;
    end if;

    --if (v_retu) then
    -- dbms_output.put_line('COLLECTION_ENABLED: ' || p_concurrent_queue_name || ': '|| 'TRUE');
    --else
    -- dbms_output.put_line('COLLECTION_ENABLED: ' || p_concurrent_queue_name || ': '|| 'FALSE');
    --end if;

    return v_retu;
  EXCEPTION
        when no_data_found then
                --dbms_output.put_line('COLLECTION_ENABLED: ' || p_concurrent_queue_name || ': ' || 'TRUE');
                return  TRUE;
  END is_collection_enabled;

  --
  -- Returns the operator symbol based on the threshold operator code
  --
  FUNCTION get_operator_symbol(p_threshold_operator varchar2) RETURN varchar2
  IS
    v_retu varchar2(10) := '=';
  BEGIN
    if p_threshold_operator = OPER_E then
      v_retu := '=';
    elsif p_threshold_operator = OPER_G then
      v_retu := '>';
    elsif p_threshold_operator = OPER_L then
      v_retu := '<';
    elsif p_threshold_operator = OPER_I then
      v_retu := 'IN';
    end if;

    return v_retu;
  END get_operator_symbol;

  --
  -- Checks the metric value against specified threshold to see if
  -- an alert needs to be raised for the given metric
  --
  FUNCTION shall_raise_alert(p_metric_short_name varchar2) RETURN boolean
  IS
    v_retu boolean := FALSE;
    l_metric_type fnd_oam_metval.metric_type%TYPE;
    l_threshold_operator fnd_oam_metval.threshold_operator%TYPE;
    l_threshold_value fnd_oam_metval.threshold_value%TYPE;
    l_operator_symbol varchar2(10);
  BEGIN
    --if (is_alert_enabled(p_metric_short_name)) then
        select metric_type, threshold_operator, threshold_value
          into l_metric_type, l_threshold_operator, l_threshold_value
          from fnd_oam_metval
          where metric_short_name = p_metric_short_name
          and rownum = 1;

        if (l_threshold_operator is not null and
            l_threshold_value is not null) then
          l_operator_symbol := get_operator_symbol(l_threshold_operator);

          declare
            v_raise_alert       number := 0;
            v_check_sql         varchar2(1024);
            v_value_column      varchar2(50);
          begin
             --determine the column our threshold value should measure against
             if (l_metric_type = 'I') then -- Numeric metric
              v_value_column := 'metric_value';
            elsif (l_metric_type = 'S') then -- Status metric
              v_value_column := 'status_code';
            end if;

            -- construct threshold check sql and execute
            -- bug #4670957 - ilawler
            -- converted literals to use binds where possible
            begin
               if (l_threshold_operator = OPER_I) then
                  --can't bind a list, use string concat
                  v_check_sql := 'select 1 from fnd_oam_metval where metric_short_name = :1 and '||
                     v_value_column||' '||l_operator_symbol ||' '||'('||l_threshold_value||')';
                  execute immediate v_check_sql
                     into v_raise_alert
                     using p_metric_short_name;
               else
                  --use bind for =,<,> since they're the majority case.
                  v_check_sql := 'select 1 from fnd_oam_metval where metric_short_name = :1 and '||
                     v_value_column||' '||l_operator_symbol ||' '||':2';
                  execute immediate v_check_sql
                     into v_raise_alert
                     using p_metric_short_name, l_threshold_value;
               end if;
            exception
               when no_data_found then
                  v_raise_alert := 0;
            end;

            -- convert the number into a boolean
            if v_raise_alert = 1 then
              v_retu := TRUE;
            end if;
          end;
        end if;
    --end if;

    --if (v_retu) then
     --dbms_output.put_line('RAISE_ALERT: ' || p_metric_short_name || ': '||'TYPE: '||l_metric_type||' OP: '||l_operator_symbol||' '||'THRSHVAL: '||l_threshold_value|| ' :TRUE');
    --else
     --dbms_output.put_line('RAISE_ALERT: ' || p_metric_short_name || ': '||'TYPE: '||l_metric_type||' OP:'||l_operator_symbol||' '||'THRSHVAL: '||l_threshold_value|| ' :FALSE');
    --end if;

    return v_retu;
  END shall_raise_alert;

  --
  -- Checks the status code for the given service instance against threshold
  -- value to see if an alert needs to be raised.
  --
  FUNCTION shall_raise_alert(p_application_id           number,
                             p_concurrent_queue_name    varchar2)
     RETURN boolean
  IS
    v_retu              boolean := FALSE;
    l_threshold_value   fnd_oam_svci_info.threshold_value%TYPE;
  BEGIN
    --if (is_alert_enabled(p_application_id, p_concurrent_queue_name)) then
        select threshold_value
          into l_threshold_value
          from fnd_oam_svci_info
          where application_id = p_application_id
          and concurrent_queue_name = p_concurrent_queue_name;

        if (l_threshold_value is not null) then
           declare
              v_raise_alert     number := 0;
              v_check_sql       varchar2(1024);
           begin
              -- construct threshold check sql and execute
              -- bug #4670957 - ilawler
              -- converted literals to use binds where possible
              v_check_sql := 'select 1 from fnd_oam_app_sys_status where ' ||
                 'application_id = :1 and concurrent_queue_name = :2 and ' ||
                 'status_code IN ' || '('||l_threshold_value||')';
              --dbms_output.put_line('CHK_SQL: ' || v_check_sql);

              begin
                 execute immediate v_check_sql
                    into v_raise_alert
                    using p_application_id, p_concurrent_queue_name;
              exception
                 when no_data_found then
                    v_raise_alert := 0;
              end;

              if v_raise_alert = 1 then
                 v_retu := TRUE;
              end if;
           end;
        end if;
    --end if;

    --if (v_retu) then
     --dbms_output.put_line('RAISE_ALERT: ' ||p_concurrent_queue_name|| ': '||'THRSHVAL: '||l_threshold_value|| ' :TRUE');
    --else
     --dbms_output.put_line('RAISE_ALERT: ' ||p_concurrent_queue_name|| ': '||'THRSHVAL: '||l_threshold_value|| ' :FALSE');
    --end if;

    return v_retu;
  END shall_raise_alert;

  --
  --
  -- Name
  --   construct_url
  --
  -- Purpose
  --   Constructs a url to ping for the given agent. This is an internal
  --   procedure only.
  --
  -- Input Arguments
  --   1) agent: type of agent for which the url is required. Valid values
  --      are AOLJ_DB_POOL, WEB_AGNT, SERVLET_AGNT, JSP, TCF, JTF, DISCOVERER,
  --      PHP, REPORT, FWK.
  --
  -- Output Arguments
  --
  -- Returns
  --   The URL for the given agent. For example for PHP (personal home page)
  --   'http://<host>:<port>/OA_HTML/US/ICXINDEX.htm' is returned. If the URL
  --   cannot be constructed, null is returned.
  --
  -- Notes:
  --
  --
  FUNCTION construct_url(agent in number) RETURN varchar2
  IS
    v_url varchar2(1000) := null;
    v_err varchar2(2000);
    valid_agent boolean := true;
  BEGIN
    if agent = AOLJ_DB_POOL then
        v_url := fnd_web_config.jsp_agent;
        if v_url is not null then
          v_url := v_url || 'jsp/fnd/AoljDbcPoolStatus.jsp';
        end if;
    elsif agent = PLSQL_AGNT then
        v_url := fnd_web_config.plsql_agent;
        if v_url is not null then
          v_url := v_url || 'fnd_web.ping';
        end if;
    elsif agent = SERVLET_AGNT or agent = TCF then
        -- we'll first try to retrieve value of 'APPS_SERVLET_AGENT' profile
        -- option. If this value is not available then we will use the base
        -- web server url to construct the url to ping for servlet agent.
        begin
          select pov.profile_option_value
            into v_url
            from   fnd_profile_options po,
              fnd_profile_option_values pov
            where  po.profile_option_name = 'APPS_SERVLET_AGENT'
            and    pov.application_id = po.application_id
            and    pov.profile_option_id = po.profile_option_id
            and    pov.level_id = 10001;
        exception
          when others then
            null;
        end;
        if v_url is null then
          v_url := fnd_web_config.web_server;
          if v_url is not null then
            v_url := v_url || 'oa_servlets';
          end if;
        end if;
        if v_url is not null then
          v_url := fnd_web_config.trail_slash(v_url);
          if agent = SERVLET_AGNT then
            v_url := v_url || 'oracle.apps.fnd.test.HelloWorldServlet';
          elsif agent = TCF then
            v_url := v_url || 'oracle.apps.fnd.tcf.SocketServer';
          end if;
        end if;
    elsif agent = JSP then
        v_url := fnd_web_config.jsp_agent;
        if v_url is not null then
          v_url := v_url || 'jsp/fnd/fndping.jsp?dbc=' || fnd_web_config.database_id;
        end if;
    elsif agent = JTF then
        v_url := fnd_web_config.jsp_agent;
        if v_url is not null then
          v_url := v_url || 'jtflogin.jsp';
        end if;
    elsif agent = DISCOVERER then
        --v_url := fnd_web_config.web_server;
        --if v_url is not null then
        --  v_url := v_url || 'servlets/discoservlet';
        --end if;
        v_url := fnd_profile.value('ICX_DISCOVERER_VIEWER_LAUNCHER');
    elsif agent = PHP then
        v_url := fnd_web_config.jsp_agent;
        if v_url is not null then
          v_url := v_url || 'US/ICXINDEX.htm';
        end if;
    elsif agent = REPORT then
        -- retrieve ICX_REPORT_LANCHER and ICX_REPORT_SERVER profile option
        -- values to construct the reports server url.
        declare
          v_launcher varchar(1000);
          v_server varchar(100);
        begin
          select pov.profile_option_value
            into v_launcher
            from   fnd_profile_options po,
              fnd_profile_option_values pov
            where  po.profile_option_name = 'ICX_REPORT_LAUNCHER'
            and    pov.application_id = po.application_id
            and    pov.profile_option_id = po.profile_option_id
            and    pov.level_id = 10001;

          select pov.profile_option_value
            into v_server
            from   fnd_profile_options po,
              fnd_profile_option_values pov
            where  po.profile_option_name = 'ICX_REPORT_SERVER'
            and    pov.application_id = po.application_id
            and    pov.profile_option_id = po.profile_option_id
            and    pov.level_id = 10001;

          if v_launcher is not null and v_server is not null then
            v_url := fnd_web_config.trail_slash(v_launcher);
            v_url := v_url || 'showenv?server=' || v_server;
          end if;
        exception
          when others then
            null;
        end;
    elsif agent = FWK then
        v_url := fnd_web_config.web_server;
    elsif agent = FORMS then
        -- retrieve ICX_FORMS_LAUNCHER profile option
        -- values to construct the reports server url.
        declare
          v_launcher varchar(1000);
        begin
          select pov.profile_option_value
            into v_launcher
            from   fnd_profile_options po,
              fnd_profile_option_values pov
            where  po.profile_option_name = 'ICX_FORMS_LAUNCHER'
            and    pov.application_id = po.application_id
            and    pov.profile_option_id = po.profile_option_id
            and    pov.level_id = 10001;

          if v_launcher is not null then
            v_url := v_launcher;
          end if;
        exception
          when others then
            null;
        end;
    else
        valid_agent := false;
    end if;

    if (v_url is null) and valid_agent then
      fnd_file.put_line(fnd_file.log, fnd_message.get);
    end if;
    return v_url;
  END construct_url;


  --
  -- Name
  --   get_agent_status
  --
  -- Purpose
  --   Returns the status for a given agent. This is for internal purpose only.
  --
  -- Input Arguments
  --   1) agent: type of agent for which the url is required. Valid values
  --      are AOLJ_DB_POOL, WEB_AGNT, SERVLET_AGNT, JSP, TCF, JTF, DISCOVERER,
  --      PHP, REPORT, FWK.
  --
  -- Output Arguments
  --
  -- Returns
  --   The status for the given agent. 0 - normal, 1 - warning, 2 - error,
  --   3 - unknown
  --
  -- Notes:
  --
  --
  FUNCTION get_agent_status (agent in number) RETURN number
  IS
    v_status number := STATUS_UNKNOWN;
    v_url varchar2(2000) := null;
    v_response varchar2(4000) := null;
  BEGIN
    -- compose a pingable url
    v_url := construct_url(agent);
    --dbms_output.put_line('URL: ' || v_url);

    if v_url is null then
      return STATUS_WARNING; -- status warning if unable to construct url,
                             -- probably some profile option is not set
    end if;

    -- Check if SSL, if so make it unavailable for now (bug 2905278)
    if (instr(v_url, 'https:', 1, 1) = 1) then
      return STATUS_UNKNOWN;
    end if;
    -- End (bug 2905278)


    -- now make a network call
    v_response := utl_http.request(v_url);

    -- now parse the response to determine status based on agent.
    if agent = PLSQL_AGNT then
      declare
        v_index number := -1;
      begin
        v_index := instr(v_response, 'FND_WEB.PING', 1, 2);
        if v_index <= 0 then
          v_status := STATUS_ERROR;
        else
          v_status := STATUS_NORMAL;
        end if;
      end;
    elsif agent = SERVLET_AGNT then
      declare
        v_index number := -1;
      begin
        v_index := instr(v_response, 'HelloWorldServlet', 1, 1);
        if v_index <= 0 then
          v_status := STATUS_ERROR;
        else
          v_status := STATUS_NORMAL;
        end if;
      end;
    elsif agent = JSP then
      declare
        v_index number := -1;
      begin
        v_index := instr(v_response, 'AOL_VERSION', 1, 1);
        if v_index <= 0 then
          v_status := STATUS_ERROR;
        else
          v_status := STATUS_NORMAL;
        end if;
      end;
    elsif agent = REPORT then
      declare
        v_index number := -1;
      begin
        v_index := instr(v_response, 'SERVER_NAME', 1, 1);
        if v_index <= 0 then
          v_status := STATUS_ERROR;
        else
          v_status := STATUS_NORMAL;
        end if;
      end;
    elsif agent = JTF or agent = DISCOVERER
      or agent = PHP or agent = TCF or agent = FORMS then
      declare
        v_index number := -1;
      begin
        v_index := instr(v_response, 'Bad Request', 1, 1);
        if v_index <= 0 then
          v_index := instr(v_response, '404 Not Found', 1, 1);
        end if;
        if v_index <= 0 then
          v_index := instr(v_response, '500 Internal Server Error', 1, 1);
        end if;
        if v_index <= 0 then
          v_status := STATUS_NORMAL;
        else
          v_status := STATUS_ERROR;
        end if;
      end;
    end if;

    return v_status;
  EXCEPTION
    when utl_http.init_failed then
      --dbms_output.put_line('INIT_FAILED');
      return STATUS_UNKNOWN;
    when utl_http.request_failed then
      --dbms_output.put_line('REQUEST_FAILED');
      return STATUS_ERROR;
    when others then
      return STATUS_UNKNOWN;
  END get_agent_status;

  --
  -- Name
  --   insert_app_sys_status_internal
  -- Purpose
  --   This procedure is for internal use of this package only!
  --   This procedure will insert a row into fnd_oam_app_sys_status
  --
  -- Input Arguments
  --    p_metric_short_name varchar2
  --    p_application_id number
  --    p_concurrent_queue_short_name varchar2
  --    p_name varchar2
  --    p_type varchar2
  --    p_status_code number
  --    p_node_name varchar2
  --
  -- Output Arguments
  --
  -- Input/Output Arguments
  --
  -- Notes:
  --    This is an internal convenience method only for this package and should
  --    not be exposed.
  --
  PROCEDURE insert_app_sys_status_internal (
      p_metric_short_name in varchar2,
      p_application_id number,
      p_concurrent_queue_short_name varchar2,
      p_name varchar2,
      p_type varchar2,
      p_status_code in number,
      p_node_name in varchar2)
  IS
      v_userid number;
  BEGIN
    v_userid := get_user_id;

    insert into fnd_oam_app_sys_status (metric_short_name, application_id,
      concurrent_queue_name, name, type, status_code, node_name, last_updated_by,
      last_update_date, last_update_login)
    values
      (p_metric_short_name,
       p_application_id,
       p_concurrent_queue_short_name,
       p_name,
       p_type,
       p_status_code,
       p_node_name,
       v_userid, sysdate, 0);
  END insert_app_sys_status_internal;

  --
  -- Name
  --   update_metric_internal
  -- Purpose
  --   This procedure is for internal use of this package only!
  --   This procedure will update a row in fnd_oam_metval for the given
  --   metric name.
  --
  -- Input Arguments
  --    p_metric_name varchar2
  --    p_value varchar2
  --    p_status_code number : if < 0 then status_code is not updated.
  --
  -- Output Arguments
  --
  -- Input/Output Arguments
  --
  -- Notes:
  --    This is an internal convenience method only for this package and should
  --    not be exposed.
  --
  PROCEDURE update_metric_internal (
      p_metric_name in varchar2,
      p_value in varchar2,
      p_status_code in number)
  IS
        v_userid number;
  BEGIN
    v_userid := get_user_id;
    if p_status_code >= 0 then
      update fnd_oam_metval
        set metric_value = p_value,
        status_code = p_status_code,
        last_collected_date = sysdate,
        last_updated_by = v_userid,
        last_update_date = sysdate,
        last_update_login = 0
        where metric_short_name = p_metric_name;
    else
      update fnd_oam_metval
        set metric_value = p_value,
        last_collected_date = sysdate,
        last_updated_by = v_userid,
        last_update_date = sysdate,
        last_update_login = 0
        where metric_short_name = p_metric_name;
    end if;
  END update_metric_internal;

  --
  -- Name
  --   refresh_status_for_service
  -- Purpose
  --   This procedure is for internal use of this package only!
  --   For a given server type, and node name this procedure will insert
  --   the status  information for all the service instances for that
  --   particular server type running on the given node into
  --   fnd_oam_app_sys_status
  --
  -- Input Arguments
  --    p_server_type varchar2 - 'C' - Concurrent Processing,
  --                           - 'F' - Forms
  --                           - 'W' - Web
  --    p_node_name varchar2
  --
  --
  -- Output Arguments
  --
  -- Input/Output Arguments
  --
  --
  -- Notes:
  --    This is an internal convenience proc only for this package and should
  --    not be exposed.
  --
  PROCEDURE refresh_status_for_service(
      p_server_type in varchar2,
      p_node_name in varchar2)
  IS
    cursor svc_c(v_server_type varchar2, v_node_name varchar2) is
      select
        fcq.application_id application_id,
        fcq.concurrent_queue_id concurrent_queue_id,
        fcq.concurrent_queue_name concurrent_queue_name
      from fnd_cp_services fcs, fnd_concurrent_queues fcq
      where
        fcs.service_id = to_number(fcq.manager_type)
        and fcs.server_type in (v_server_type, 'E')
        and upper(fcq.target_node) = upper(v_node_name)
        and upper(fcs.enabled) = 'Y'
        and upper(fcq.enabled_flag) = 'Y'
        order by fcs.oam_display_order asc;

    v_count number := 0;
  BEGIN
    for svc_inst in svc_c(p_server_type, p_node_name) loop
      v_count := v_count + 1;
      declare
        v_target number := -1;
        v_actual number := -1;
        v_status_code number;
        v_desc varchar2(1000);
        v_err_code number;
        v_err_msg varchar2(1000);
      begin
        -- check if collection is enabled before calling API to get status
        if (is_collection_enabled(
                svc_inst.application_id, svc_inst.concurrent_queue_name)) then
          fnd_oam.get_svc_inst_status(svc_inst.application_id,
            svc_inst.concurrent_queue_id, v_target, v_actual, v_status_code,
            v_desc, v_err_code, v_err_msg);

          if v_err_code > 0 then -- error
            -- Log some information for now.
            fnd_file.put_line(fnd_file.log, 'Error in refresh_status_for_service:');
            fnd_file.put_line(fnd_file.log, 'SERVER_TYPE: ' || p_server_type);
            fnd_file.put_line(fnd_file.log, 'NODE NAME: ' || p_node_name);
            fnd_file.put_line(fnd_file.log, 'APP ID: ' ||
                svc_inst.application_id);
            fnd_file.put_line(fnd_file.log, 'CONCURRENT QUEUE ID: ' ||
                svc_inst.concurrent_queue_id);
            fnd_file.put_line(fnd_file.log, 'CONCURRENT QUEUE NAME: ' ||
                svc_inst.concurrent_queue_name);
            fnd_file.put_line(fnd_file.log, 'v_target: ' || v_target);
            fnd_file.put_line(fnd_file.log, 'v_actual: ' || v_actual);
            fnd_file.put_line(fnd_file.log, 'v_status_code: ' || v_status_code);
            fnd_file.put_line(fnd_file.log, 'v_desc: ' || v_desc);
            fnd_file.put_line(fnd_file.log, 'v_err_code: ' || v_err_code);
            fnd_file.put_line(fnd_file.log, 'v_err_msg: ' || v_err_msg);
            v_status_code := STATUS_UNKNOWN;
          end if;
          --dbms_output.put_line('STATUS CODE: ' || v_status_code);

        else
                -- upload status null since collection not enabled.
                v_status_code := -1;
        end if;

        -- now insert into fnd_oam_mets:
        insert_app_sys_status_internal(
          p_server_type || '_' || to_char(v_count) ||
                                  '_' || p_node_name,
          svc_inst.application_id, svc_inst.concurrent_queue_name, null,
          p_server_type,v_status_code, p_node_name);

      end;
    end loop;
  EXCEPTION
    when others then
      raise;
  END refresh_status_for_service;

  --
  -- Internal API to register status in a table in order to compute
  -- rollup.
  --
  PROCEDURE register_status_in_table(
        p_satus_code number,
        p_info_table IN OUT NOCOPY st_table)
  IS

  BEGIN
        if p_satus_code = STATUS_ERROR then
                p_info_table(1) := 1;
        elsif p_satus_code = STATUS_WARNING then
                p_info_table(2) := 1;
        elsif p_satus_code = STATUS_UNKNOWN then
                p_info_table(3) := 1;
        elsif p_satus_code = STATUS_NORMAL then
                p_info_table(4) := 1;
        elsif p_satus_code = STATUS_INACTIVE then
                p_info_table(5) := 1;
        end if;
  END  register_status_in_table;

  --
  -- Name
  --   compute_rollup_status
  -- Purpose
  --   This function is for internal use of this package only!
  --   Computes the the rollup status for a set of metrics given some
  --   metadata information about the individual component metrics
  --   that comprise the rollup.
  --
  -- Input Arguments
  --   p_comp_info - st_table Table of numbers of with five entries as follows:
  --            at index 1: if at least one component has STATUS_ERROR then 1
  --                        otherwise 0.
  --            at index 2: if at least one component has STATUS_WARNING then 1
  --                        otherwise 0.
  --            at index 3: if at least one component has STATUS_UNKNOWN then 1
  --                        otherwise 0.
  --            at index 4: if at least one component has STATUS_NORMAL then 1
  --                        otherwise 0.
  --            at index 5: if at least one component has STATUS_INACTIVE then
  --                        1 otherwise 0.
  --
  -- Output Arguments
  --
  -- Input/Output Arguments
  --
  -- Returns
  --   one of the following status codes:
  --    STATUS_ERROR, STATUS_WARNING, STATUS_UNKNOWN, STATUS_NORMAL,
  --    STATUS_INACTIVE
  --
  -- Notes:
  --    This is an internal convenience method only for this package and should
  --    not be exposed.
  --
  FUNCTION compute_rollup_status(
    p_comp_info st_table) RETURN number
  IS
    v_status number := STATUS_NORMAL;
  BEGIN
    if p_comp_info.exists(1) and p_comp_info(1) = 1 then
      v_status := STATUS_ERROR;
    elsif p_comp_info.exists(2) and p_comp_info(2) = 1 then
      v_status := STATUS_WARNING;
    elsif p_comp_info.exists(3) and p_comp_info(3) = 1 then
      v_status := STATUS_WARNING;
    elsif p_comp_info.exists(4) and p_comp_info(4) = 1 then
      v_status := STATUS_NORMAL;
    elsif p_comp_info.exists(5) and p_comp_info(5) = 1 then
      v_status := STATUS_INACTIVE;
    end if;

    return v_status;
  END compute_rollup_status;

  --
  -- Name
  --   compute_overall_server_status
  -- Purpose
  --   This procedure is for internal use of this package only!
  --   Given the server name this procedure will compute and insert the status
  --   for that server into fnd_oam_mets, based on the status of the server
  --   on individual nodes.
  --
  -- Input Arguments
  --    p_server varchar2 -- metric name for the server e.g. 'CP_SERVER'
  --    p_server_type varchar2 -- server type eg. 'C','A','W','D' or 'F'
  --
  -- Output Arguments
  --
  -- Input/Output Arguments
  --
  --
  -- Notes:
  --    This is an internal convenience method only for this package and should
  --    not be exposed.
  --
  PROCEDURE compute_overall_server_status(
    p_server in varchar2,
    p_server_type in varchar2)
  IS

  BEGIN
     declare
        cursor server_st is
          select status_code from fnd_oam_app_sys_status
            where metric_short_name like p_server || '%';
        overall_st number := STATUS_NORMAL;
        found_up boolean := false;
        found_warning boolean := false;
        server_count number := 0;
        info_table st_table;
      begin
        --for server in server_st loop
        --  if server.status_code = STATUS_NORMAL then
        --    found_up := true;
        --  elsif server.status_code = STATUS_WARNING then
        --    found_warning := true;
        --    overall_st := STATUS_WARNING;
        --  else
        --    overall_st := STATUS_WARNING;
        --  end if;
        --  server_count := server_count + 1;
        --end loop;
        --if server_count > 0 and found_up = false and found_warning = false then
        --  overall_st := STATUS_ERROR;
        --end if;

        for server in server_st loop
          register_status_in_table(server.status_code, info_table);
          --if server.status_code = STATUS_ERROR then
          --  info_table(1) := 1;
          --elsif server.status_code = STATUS_WARNING then
          --  info_table(2) := 1;
          --elsif server.status_code = STATUS_UNKNOWN then
          --  info_table(3) := 1;
          --elsif server.status_code = STATUS_NORMAL then
          --  info_table(4) := 1;
          --elsif server.status_code = STATUS_INACTIVE then
          --  info_table(5) := 1;
          --end if;
        end loop;

        overall_st := compute_rollup_status(info_table);

        -- now insert into fnd_oam_mets
        insert_app_sys_status_internal(
          p_server || '_OVERALL',
          null, null, null, p_server_type, overall_st, null);

      end;
  END compute_overall_server_status;

  --
  -- Name
  --   refresh_status_for_tier
  -- Purpose
  --   This procedure is for internal use of this package only!
  --   For a given server type, and node name this procedure will insert
  --   the status  information for all the service instances for that
  --   particular server type running on the given node into
  --   fnd_oam_app_sys_status
  --
  -- Input Arguments
  --    p_server_type varchar2 - 'C' - Concurrent Processing,
  --                           - 'F' - Forms
  --                           - 'W' - Web
  --                           - 'A' - Admin
  --    p_node_name varchar2
  --
  --
  -- Output Arguments
  --
  -- Input/Output Arguments
  --
  --
  -- Notes:
  --    This is an internal convenience proc only for this package and should
  --    not be exposed.
  --
  PROCEDURE refresh_status_for_tier(
      p_server_type in varchar2,
      p_node_name in varchar2)
  IS
     v_server_type_prep varchar2(30);
  BEGIN
        -- determine the server type
        if p_server_type = 'C' then
                v_server_type_prep := 'CP_SERVER_';
        elsif p_server_type = 'W' then
                v_server_type_prep := 'WEB_SERVER_';
        elsif p_server_type = 'F' then
                v_server_type_prep := 'FORMS_SERVER_';
        elsif p_server_type = 'A' then
                v_server_type_prep := 'ADMIN_SERVER_';
        else
                v_server_type_prep := 'UNKNOWN_SERVER_';
        end if;

        refresh_status_for_service(p_server_type, p_node_name);

          -- Now Compute Overall CP Server status on this node
          declare
            v_tier_overall_status number := STATUS_NORMAL; -- start off by up
            v_found_up_instance boolean := false;
            v_found_inactive_instance boolean := false;
            v_count number := 0;

            cursor status_c is
              select status_code from fnd_oam_app_sys_status where
                upper(node_name) = upper(p_node_name) and (
                metric_short_name like p_server_type || '_%');
            info_table st_table;
          begin
            for st in status_c loop
              register_status_in_table(st.status_code, info_table);
              --if st.status_code = STATUS_ERROR then
              --  info_table(1) := 1;
              --elsif st.status_code = STATUS_WARNING then
              --  info_table(2) := 1;
              --elsif st.status_code = STATUS_UNKNOWN then
              --  info_table(3) := 1;
              --elsif st.status_code = STATUS_NORMAL then
              --  info_table(4) := 1;
              --elsif st.status_code = STATUS_INACTIVE then
              --  info_table(5) := 1;
              --end if;
            end loop;

            -- also factor in the status of the current host while
            -- computing the status for this tier on this host.
            declare
                v_host_status number;
            begin
                select status_code into v_host_status
                        from fnd_oam_app_sys_status
                        where upper(node_name) = upper(p_node_name)
                        and metric_short_name like 'HOST_%'
                        and rownum = 1; -- we expect only one row per host
                register_status_in_table(v_host_status, info_table);
            exception
                when others then
                        null;
            end;

            -- compute the rollup for this tier on this node and update
            -- into the table.
            v_tier_overall_status := compute_rollup_status(info_table);

            insert_app_sys_status_internal(
              v_server_type_prep || p_node_name,
              null, null, null, p_server_type, v_tier_overall_status, p_node_name);
          end;
  END refresh_status_for_tier;


  --
  -- Name
  --   refresh_app_sys_status
  --
  -- Purpose
  --   Derives the status of the following applications servers using URL
  --   pings of the corresponding processes that belong to the server. The status
  --   and host information for each of the processes as well as servers are
  --   updated in the FND_OAM_APP_SYS_STATUS table
  --      1)  Admin - Currently no processes are defined for this server
  --      2)  Web   - Consists of Apache Web Listener, Apache Jserv
  --      3)  Forms - Consists of the forms launcher
  --      4)  CP    - Consists of the Internal Concurrent Manager, Reports
  --      5)  Data  - Consists of the database instances as defined in gv$instance.
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_app_sys_status
  IS
  pragma AUTONOMOUS_TRANSACTION;
    cursor nodes_c is
      select upper(node_name) node_name, status, support_cp, support_forms,
        support_web, support_admin
        from FND_OAM_FNDNODES_VL
        where node_mode = 'O'
        and (nvl(support_cp, 'N') = 'Y' or
             nvl(support_forms, 'N') = 'Y' or
             nvl(support_web, 'N') = 'Y' or
             nvl(support_admin, 'N') = 'Y' or
             nvl(support_db, 'N') = 'Y');
  BEGIN
    -- delete existing app sys status information. We will change this later if we are
    -- going to move it to an archive table
    delete from fnd_oam_app_sys_status;

    -- now update latest host information
    declare
      i number := 1;
      seq_counter number := 1;
      node_status number;
    begin
      for node in nodes_c loop
        select decode(nvl(node.status, 'U'),
                'Y',STATUS_NORMAL,
                'N',STATUS_ERROR,
                'U',STATUS_UNKNOWN, STATUS_UNKNOWN) into node_status
          from dual;
        insert_app_sys_status_internal(
          'HOST_'||to_char(i),
          null, null, null, null, node_status, node.node_name);

        i := i + 1;


        -- now based on the various flags for the applications servers, update
        -- the status of individual processes as well as those of the servers

        -- Concurrent Processing
        if node.support_cp = 'Y' then
          refresh_status_for_tier('C', node.node_name);
        end if; -- if node.support_cp = 'Y' then

        -- For Forms
        if node.support_forms = 'Y' then
          refresh_status_for_tier('F', node.node_name);
        end if; -- if node.support_forms = 'Y' then

        -- For ADMIN
        if node.support_admin = 'Y' then
          refresh_status_for_tier('A', node.node_name);
        end if; -- end if node.support_admin = 'Y' then

        -- For WEB SERVER
        if node.support_web = 'Y' then
          refresh_status_for_tier('W', node.node_name);
        end if; -- if node.support_web = 'Y' then

      end loop;

      -- For DATA SERVER
      -- We will need to collect database statuses for all the
      -- individual instances list in gv$instance
      declare
          v_db_status number := STATUS_NORMAL;
          v_db_count number := 0;
          v_node_name varchar2(100);
          v_db_node_registered boolean := false;
          cursor dbst_c is
            select upper(host_name) host_name, instance_name, database_status
              from gv$instance;

          -- added the where clause to this cursor as a fix for bug 3955412
          cursor nodex_c is
		    --rjaiswal bug#4917109
			-- For virtual host we have the entry of main host in this column 'webhost'
			-- So this column can be used to compare the gv$instance host_name value
			-- instead of comparing it with node_name.Added webhost column
            select upper(node_name) node_name,upper(webhost) webhost from FND_OAM_FNDNODES_VL
                where node_mode = 'O'
                and (nvl(support_cp, 'N') = 'Y' or
                nvl(support_forms, 'N') = 'Y' or
                nvl(support_web, 'N') = 'Y' or
                nvl(support_admin, 'N') = 'Y' or
                nvl(support_db, 'N') = 'Y');
			--rjaiswal bug#4917109
      begin
          for db in dbst_c loop
            v_db_status := STATUS_NORMAL;

            -- what are the possible values for database_status here that we
            -- need to check??
            if db.database_status <> 'ACTIVE' then
              v_db_status := STATUS_WARNING;
            end if;

            -- fix for bug 2848014; if host_name has domain name as well
            -- only use the first part.
            v_node_name := db.host_name;
            for ndx in nodex_c loop
                declare
                        v_gv_host varchar2(100);
                        v_fn_node varchar2(100);
			--rjaiswal bug#4917109 starts
			--this variable is required to hold the value of web host:
                        v_fn_webhost varchar2(100);
			--rjaiswal bug#4917109 ends
                begin
                        select decode(instr(db.host_name, '.') - 1, -1,
                                db.host_name,
                                substr(db.host_name, 0,
                                        instr(db.host_name, '.') - 1))
                         into v_gv_host from dual;

                        select decode(instr(ndx.node_name, '.') - 1, -1,
                                ndx.node_name,
                                substr(ndx.node_name, 0,
                                        instr(ndx.node_name, '.') - 1))
                         into v_fn_node from dual;
	            --rjaiswal bug#4917109 starts
			-- Storing the value of webhost inorder to compare it with v_gv_host
                        select decode(instr(ndx.webhost, '.') - 1, -1,
                                ndx.webhost,
                                substr(ndx.webhost, 0,
                                        instr(ndx.webhost, '.') - 1))
                         into v_fn_webhost from dual;
			-- ADDED "or v_gv_host = v_fn_webhost" in the "if" condition
			-- This column can be used to compare the gv$instance host_name value
                if ( v_gv_host = v_fn_node or v_gv_host = v_fn_webhost) then
                        v_node_name := ndx.node_name;
		     --rjaiswal bug#4917109 ends
                        v_db_node_registered := true;
                        exit; -- we found match so we are done with this loop
                end if;
                end;
            end loop;

            if (v_db_node_registered = false) then
                -- no match found in FND_OAM_FNDNODES_VL, so we will create
                -- a new entry for this host (if one does not
                -- already exist) with status as unknown for now.
                -- This is temporary bug fix for 2952829.
                declare
                        v_temp number;
                        v_host_count number;
                begin
                        select  1 into v_temp
                          from fnd_oam_app_sys_status
                          where metric_short_name like 'HOST_%'
                          and node_name = db.host_name;
                exception
                        when no_data_found then
                          select count(*) into v_host_count
                           from fnd_oam_app_sys_status
                           where  metric_short_name like 'HOST_%'
                           and node_name is not null;

                          insert_app_sys_status_internal(
                                'HOST_'||to_char(v_host_count+1),
                                null, null, null, null,
                                STATUS_UNKNOWN, db.host_name);
                end;
                v_node_name := db.host_name;
            end if;

            -- now insert status Database instance into
            -- fnd_oam_app_sys_status
            -- we will insert only if an entry for the host on which the
            -- db instance lives has already been inserted. This way we
            -- will avoid errors during computing rollup in situations where
            -- a db instance was living on a node that is not being
            -- monitored.
            declare
                v_temp number;
            begin
                select 1 into v_temp
                 from fnd_oam_app_sys_status
                 where metric_short_name like 'HOST_%'
                 and node_name = v_node_name;

                select count(*) into v_db_count
                 from fnd_oam_app_sys_status
                 where metric_short_name like 'DATABASE_INS_%'
                 and node_name = v_node_name;

                insert_app_sys_status_internal(
                 'DATABASE_INS_' || to_char(v_db_count+1) || '_' || v_node_name,
                 null, null, db.instance_name, 'D', v_db_status, v_node_name);
            exception
                when no_data_found then
                        null;
            end;
          end loop;
      end;

      -- DATA SERVER
      -- Now compute the rollup for database server status on each node
      declare
        cursor all_monitored_nodes is
                select node_name from fnd_oam_app_sys_status
                 where metric_short_name like 'HOST_%'
                 and node_name is not null;
        cursor db_instance (p_node varchar2) is
                select metric_short_name, status_code
                 from fnd_oam_app_sys_status
                 where metric_short_name like 'DATABASE_INS_%'
                 and node_name = p_node;
      begin
        for nd in all_monitored_nodes loop
                declare
                        info_table st_table;
                        v_db_status number;
                        v_db_count number := 0;
                begin
                  for dbi in db_instance(nd.node_name) loop
                        if dbi.status_code = STATUS_ERROR then
                                info_table(1) := 1;
                        elsif dbi.status_code = STATUS_WARNING then
                                info_table(2) := 1;
                        elsif dbi.status_code = STATUS_UNKNOWN then
                                info_table(3) := 1;
                        elsif dbi.status_code = STATUS_NORMAL then
                                info_table(4) := 1;
                        elsif dbi.status_code = STATUS_INACTIVE then
                                info_table(5) := 1;
                        end if;
                        v_db_count := v_db_count + 1;
                  end loop;

                  if (v_db_count > 0) then
                        v_db_status := compute_rollup_status(info_table);
                        insert_app_sys_status_internal(
                          'DATA_SERVER_' || nd.node_name,
                          null, null, null, 'D', v_db_status, nd.node_name);
                  end if;
                end;
        end loop;
      end;

      -- Now finally, compute the overall status for CP, Forms, Admin, Web and
      -- Database. These are computed simply from the overall statuses across
      -- the different nodes.
        -- CP
        compute_overall_server_status('CP_SERVER', 'C');

        -- FORM
        compute_overall_server_status('FORMS_SERVER', 'F');

        -- DATA
        compute_overall_server_status('DATA_SERVER', 'D');

        -- ADMIN
        compute_overall_server_status('ADMIN_SERVER', 'A');

        -- WEB
        compute_overall_server_status('WEB_SERVER', 'W');
    end;
    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_app_sys_status;

  --
  -- Name
  --   refresh_activity
  --
  -- Purpose
  --   Computes the values for the following indicators and updates the
  --   fnd_oam_mets table using an autonomous transaction.
  --      1) Number of Active Users
  --      2) Number of Database sessions
  --      3) Number of Running requests
  --      4) Number of Service Processes
  --      5) Number of Serivces Up
  --      6) Number of Serivces Down
  --      7) Number of invalid objects
  --      8) % of Workflow mailer messages waiting to be sent
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_activity
  IS
  pragma AUTONOMOUS_TRANSACTION;
    ct_active_users number;
    ct_db_sessions number;
    ct_running_req number;
    ct_service_processes number;
    ct_services_up number;
    ct_services_down number;
    ct_invalid_objects number;
    ct_waiting_msg number;
    ct_processed_msg number;
  BEGIN
    if (is_collection_enabled('ACTIVE_USERS')) then
      -- get the number of active users
      select count(distinct(F.login_id))
        into ct_active_users
        from fnd_login_resp_forms F,
          gv$session S
        where F.AUDSID = S.AUDSID;

      -- update the number of active forms users
      update_metric_internal('ACTIVE_USERS', to_char(ct_active_users), -1);
    end if;

    if (is_collection_enabled('DB_SESSIONS')) then
      -- get the number of db sessions
      select count(*) into ct_db_sessions from gv$session where audsid > 0;

      -- update the number of db sessions
      update_metric_internal('DB_SESSIONS', to_char(ct_db_sessions), -1);
    end if;

    if (is_collection_enabled('RUNNING_REQ')) then
      -- get the number of running requests
      select count(*)
        into ct_running_req
        from fnd_concurrent_requests
        where phase_code = 'R';

      -- update the number of running requests
      update_metric_internal('RUNNING_REQ', to_char(ct_running_req), -1);
    end if;

    if (is_collection_enabled('SERVICE_PROCS')) then
      -- get the number of service processes
      select count(*)
        into ct_service_processes
        from fnd_concurrent_processes
        where process_status_code in ('R','A','P');

      -- update the number of service processes
      update_metric_internal('SERVICE_PROCS', to_char(ct_service_processes), -1);
    end if;

    if (is_collection_enabled('SERVICES_UP')) then
      -- Now get the number of Services Up
      select count(concurrent_queue_id)
        into ct_services_up
        from fnd_concurrent_queues_vl
        where running_processes = max_processes and max_processes > 0;

      -- Update Services Up
      update_metric_internal('SERVICES_UP', to_char(ct_services_up), 0);
    end if;

    if (is_collection_enabled('SERVICES_DOWN')) then
      -- Get the number of services down
      select count(concurrent_queue_id)
        into ct_services_down
        from fnd_concurrent_queues_vl
        where running_processes = 0 and max_processes > 0;

      -- Update Services down
      update_metric_internal('SERVICES_DOWN', to_char(ct_services_down), 2);
    end if;

    if (is_collection_enabled('INVALID_OBJECTS')) then
      -- Get the count of invalid objects for 'APPS' schema only
      -- using user() function instead of hard coding 'APPS' - fix
      -- for bug 3876651
      SELECT COUNT(*)
        into ct_invalid_objects
        FROM DBA_OBJECTS DO
        WHERE DO.STATUS = 'INVALID'  AND
               DO.OWNER = user and
               EXISTS (select 1
               from DBA_ERRORS DE
               where DE.NAME = DO.OBJECT_NAME AND
                     DE.OWNER = DO.OWNER );

      -- Update the invalid objects
      update_metric_internal('INVALID_OBJECTS', to_char(ct_invalid_objects), -1);
    end if;

    -- added changes for this metric for performance optimization
    -- if a greater than threshold is specified for alerting, during
    -- FNDOAMCOL execution metric value will be counted only upto
    -- the threshold value
    if (is_collection_enabled('WFM_WAIT_MSG')) then
      declare
        v_alrt_enabled_flag fnd_oam_metval.alert_enabled_flag%TYPE;
        v_threshold_oper fnd_oam_metval.threshold_operator%TYPE;
        v_threshold_val fnd_oam_metval.threshold_value%TYPE;
      begin
        select nvl(alert_enabled_flag,'Y'),
         threshold_operator, threshold_value
         into v_alrt_enabled_flag, v_threshold_oper, v_threshold_val
         from fnd_oam_metval
         where metric_short_name = 'WFM_WAIT_MSG';

        if (is_request() and
            v_alrt_enabled_flag = 'Y' and
            v_threshold_oper = OPER_G and
            v_threshold_val is not null) then
                -- Count only upto the specified threshold
                select count(*)
                        into ct_waiting_msg
                        from
                        (
                        select  mail_status
                        from wf_notifications
                        where mail_status = 'MAIL' ) v
                where rownum <= to_number(v_threshold_val) + 1;
        else
                -- Get the full count of waiting workflow mailer messages
                select  count(*)
                        into ct_waiting_msg
                        from wf_notifications
                        where mail_status = 'MAIL';
        end if;
      end;

      -- Update the unsent workflow email metric
      update_metric_internal('WFM_WAIT_MSG', to_char(ct_waiting_msg), -1);
    end if;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_activity;

  --
  -- Name
  --   refresh_config_changes
  --
  -- Purpose
  --   Computes the values for the following indicators and updates the
  --   fnd_oam_mets table using an autonomous transaction.
  --      1) Number of patches applied in the last 24 hours
  --      2) Number of changes in profile options in last 24 hours
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_config_changes
  IS
  pragma AUTONOMOUS_TRANSACTION;
    ct_patches number;
    ct_profile_options number;
    ct_context_files number;
  BEGIN
    if (is_collection_enabled('PATCHES')) then
      -- Get the number of patches applied within last 24 hours

      -- Modified query for bug 3835667
      select count(*) into ct_patches
        from ad_patch_drivers d, ad_patch_runs r
        where r.end_date >= sysdate - 1
                and d.patch_driver_id = r.patch_driver_id;

      --select count(distinct(PATCH_NAME))
      --  into ct_patches
      --  from ad_applied_patches where APPLIED_PATCH_ID in
      --   (select APPLIED_PATCH_ID from ad_patch_drivers where PATCH_DRIVER_ID in
      --    (select PATCH_DRIVER_ID from ad_patch_runs where sysdate-START_DATE <=1));

      -- Update the number of patches applied within last 24 hours
      update_metric_internal('PATCHES', to_char(ct_patches), -1);
    end if;

    if (is_collection_enabled('PROFILE_OPT')) then
      -- get the number of profile options changed in last 24 hours
      select count(*) into ct_profile_options
        from  fnd_profile_options ovl,
            fnd_profile_option_values v
        where ovl.start_date_active <= SYSDATE
            and (nvl(ovl.end_date_active, SYSDATE) >= SYSDATE)
            and (v.level_id = 10001 and v.level_value = 0)
            and ovl.profile_option_id = v.profile_option_id
            and ovl.application_id = v.application_id
            and (sysdate - v.last_update_date <= 1);

      -- Update the profile options
      update_metric_internal('PROFILE_OPT', to_char(ct_profile_options), -1);
    end if;

    if (is_collection_enabled('CONTEXT_FILES_EDITED')) then
      -- query the number of context files changed in last 24 hours
      select count(*) into ct_context_files
        from (
                select focf.last_update_date lud
                        from fnd_oam_context_files focf
                        where (status <> 'H' or status is null)
                        and upper(name) <> 'METADATA')
        where lud >= sysdate - 1;

      -- update the number of context files changed
      update_metric_internal('CONTEXT_FILES_EDITED', to_char(ct_context_files), -1);
    end if;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_config_changes;

  --
  -- Name
  --   refresh_throughput
  --
  -- Purpose
  --   Computes the values for the following indicators and updates the
  --   fnd_oam_mets table using an autonomous transaction.
  --      1) % of Completed requests
  --      2) % of Workflow mailer messages that have been processed
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_throughput
  IS
  pragma AUTONOMOUS_TRANSACTION;
    ct_completed_req number;
    ct_total_req number;
    ct_waiting_msg number;
    ct_processed_msg number;
  BEGIN
    if (is_collection_enabled('COMPLETED_REQ')) then
      -- Compute the percentage of completed requests as the following:
      -- The numerator is the sum of the running requests and the requests that
      -- completed in the last 24 hours.
      -- The denominator is the sum of the running requests, the requests that
      -- completed in the last 24 hours, and the requests
      -- that are eligible to run at the current time.
      declare
        v_numerator number;
        v_denominator number;
      begin
        select count(*) into v_numerator
                from fnd_concurrent_requests
                where phase_code in ('R', 'C')
                  and status_code <> 'D'
                  and greatest(requested_start_date, request_date)
                      between sysdate-1 and sysdate;

        select count(*) into v_denominator
                from fnd_concurrent_requests
                where (  (phase_code in ('R', 'C')
                              and status_code <> 'D')
                         or ( status_code in ('I','Q')
                               and hold_flag <> 'Y') )
                    and greatest(requested_start_date, request_date)
                        between sysdate-1 and sysdate;

        select round((greatest(1,v_numerator)/greatest(1,v_denominator))* 100)
                into ct_completed_req
                from dual;
        update_metric_internal('COMPLETED_REQ', to_char(ct_completed_req), -1);
      end;
    end if;


    if (is_collection_enabled('WFM_PROC_MSG')) then
      -- Get the count of processed workflow mailer messages that began within
      -- last 24 hours
      select  count(*)
        into ct_processed_msg
        from wf_notifications
        where mail_status = 'SENT'
        and status = 'OPEN'
        and (sysdate - begin_date <= 1);

      update_metric_internal('WFM_PROC_MSG', to_char(ct_processed_msg), -1);
    end if;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_throughput;

  --
  -- Name
  --   refresh_user_alerts_summary
  --
  -- Purpose
  --   Computes the values for the following indicators and updates the
  --   fnd_oam_mets table using an autonomous transaction.
  --
  --      1) Number of New User Alerts
  --      2) Number of New User Alert Occurrances
  --      3) Number of Open User Alerts
  --      4) Number of Open User Alert Occurrances
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_user_alerts_summary
  IS
  pragma AUTONOMOUS_TRANSACTION;
    --ct_unpr number;
    --ct_pr number;
    --ct_total_unpr number;
    ct_new_al number;
    ct_new_occ number;
    ct_open_al number;
    ct_open_occ number;
  BEGIN
    if (is_collection_enabled('USER_ALERT_NEW')) then
      -- get the number of new alerts
      select count(*) into ct_new_al from fnd_log_unique_exceptions where
                status='N' and category='USER';

      -- update new alerts
      update_metric_internal('USER_ALERT_NEW', to_char(ct_new_al), -1);
    end if;

    if (is_collection_enabled('USER_ALERT_NEW_OCC')) then
      -- get the number of new occurrences
      select count(*) into ct_new_occ
                from fnd_log_exceptions fle, fnd_log_unique_exceptions flue
                where fle.unique_exception_id = flue.unique_exception_id
                and flue.status='N'
                and flue.category='USER';

      -- update new occurrances
      update_metric_internal('USER_ALERT_NEW_OCC', to_char(ct_new_occ), -1);
    end if;


    if (is_collection_enabled('USER_ALERT_OPEN')) then
      -- get number of open alerts
      select count(*) into ct_open_al from fnd_log_unique_exceptions where
                status='O' and category='USER';

      -- update open alerts
      update_metric_internal('USER_ALERT_OPEN', to_char(ct_open_al), -1);
    end if;

    if (is_collection_enabled('USER_ALERT_OPEN_OCC')) then
      -- get the number of open occurrences
      select count(*) into ct_open_occ
                from fnd_log_exceptions fle, fnd_log_unique_exceptions flue
                where fle.unique_exception_id = flue.unique_exception_id
                and flue.status='O'
                and flue.category='USER';

      -- update open occurrances
      update_metric_internal('USER_ALERT_OPEN_OCC', to_char(ct_open_occ), -1);
    end if;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_user_alerts_summary;

  --
  -- Name
  --   refresh_exceptions_summary
  --
  -- Purpose
  --   Computes the values for the following indicators and updates the
  --   fnd_oam_mets table using an autonomous transaction.
  --      #1) Number of critical unprocessed exceptions in last 24 hours
  --      #2) Number of critical processed exceptions in last 24 hours
  --      #3) Number of total critical unprocessed exceptions
  --
  --      1) Number of New System Alerts
  --      2) Number of New Occurrances
  --      3) Number of Open System Alerts
  --      4) Number of Open Occurrances
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_exceptions_summary
  IS
  pragma AUTONOMOUS_TRANSACTION;
    --ct_unpr number;
    --ct_pr number;
    --ct_total_unpr number;
    ct_new_al number;
    ct_new_occ number;
    ct_open_al number;
    ct_open_occ number;
  BEGIN
    if (is_collection_enabled('CRIT_UNPR_EXCEP')) then
      -- get the number of new alerts
      select count(*) into ct_new_al from fnd_log_unique_exceptions where
                status='N';

      -- update new alerts
      update_metric_internal('CRIT_UNPR_EXCEP', to_char(ct_new_al), -1);
    end if;

    if (is_collection_enabled('CRIT_PR_EXCEP')) then
      -- get the number of new occurrences
      select count(*) into ct_new_occ
                from fnd_log_exceptions fle, fnd_log_unique_exceptions flue
                where fle.unique_exception_id = flue.unique_exception_id
                and flue.status='N';

      -- update new occurrances
      update_metric_internal('CRIT_PR_EXCEP', to_char(ct_new_occ), -1);
    end if;


    if (is_collection_enabled('CRIT_TOTAL_UNPR_EXCEP')) then
      -- get number of open alerts
      select count(*) into ct_open_al from fnd_log_unique_exceptions where
                status='O';

      -- update open alerts
      update_metric_internal('CRIT_TOTAL_UNPR_EXCEP', to_char(ct_open_al), -1);
    end if;

    if (is_collection_enabled('OPEN_OCC')) then
      -- get the number of open occurrences
      select count(*) into ct_open_occ
                from fnd_log_exceptions fle, fnd_log_unique_exceptions flue
                where fle.unique_exception_id = flue.unique_exception_id
                and flue.status='O';

      -- update open occurrances
      update_metric_internal('OPEN_OCC', to_char(ct_open_occ), -1);
    end if;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_exceptions_summary;

  --
  -- Name
  --   refresh_miscellaneous
  --
  -- Purpose
  --   Computes the values for the following indicators and
  --   updates the FND_OAM_METVAL using an autonomous transaction.
  --   Metrics: PL./SQL Agent, Servlet Agent, JSP Agent, JTF, Discoverer,
  --            Personal Home Page, TCF
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --   THIS PROCEDURE IS DEPRECATED - PLEASE DO NOT CALL THIS ANYMORE
  --   Use the corresponding Java API instead.
  --
  PROCEDURE refresh_miscellaneous
  IS
  pragma AUTONOMOUS_TRANSACTION;
    v_status_code number;
    v_agent_short_name varchar2(30);
  BEGIN
    for agent in AGENT_MIN..AGENT_MAX loop
      v_status_code := get_agent_status(agent);

      -- figure out the metric short name
      if agent = AOLJ_DB_POOL then
        v_agent_short_name := 'AOLJ_DB_POOL_GEN';
      elsif agent = PLSQL_AGNT then
        v_agent_short_name := 'PL_SQL_AGNT_GEN';
      elsif agent = SERVLET_AGNT then
        v_agent_short_name := 'SERVLET_AGNT_GEN';
      elsif agent = TCF then
        v_agent_short_name := 'TCF_GEN';
      elsif agent = JSP then
        v_agent_short_name := 'JSP_AGNT_GEN';
      elsif agent = JTF then
        v_agent_short_name := 'JTF_GEN';
      elsif agent = DISCOVERER then
        v_agent_short_name := 'DISCOVERER_GEN';
      elsif agent = PHP then
        v_agent_short_name := 'PHP_GEN';
      elsif agent = REPORT then
        v_agent_short_name := 'REPORT_GEN';
      elsif agent = FWK then
        v_agent_short_name := 'FWK_GEN';
      elsif agent = FORMS then
        v_agent_short_name := 'FORMS_GEN';
      end if;

      update_metric_internal(v_agent_short_name, null, v_status_code);
    end loop;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_miscellaneous;

  --
  -- Name
  --   raise_alerts
  --
  -- Purpose
  --   Checks values for all metrics and service instances that are currently
  --   being monitored and raises alert if the values or status codes match
  --   the thresholds specified by the user.
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE raise_alerts
  IS
    cursor c_mets is
      select metric_short_name, metric_type, metric_value, status_code,
             threshold_operator, threshold_value
        from fnd_oam_metval
        where nvl(is_supported,'Y') = 'Y'
        and nvl(collection_enabled_flag,'Y') = 'Y'
        and nvl(alert_enabled_flag, 'N') = 'Y'
        and group_id <> 8 and group_id <> 0; -- Disabling Alerting for Web Components and Internal Metrics
                           -- For OAM Rollup A

   cursor c_svci is
     select foa.application_id application_id,
            foa.concurrent_queue_name concurrent_queue_name,
            fcq.concurrent_queue_id concurrent_queue_id,
            foa.status_code status_code
        from fnd_oam_app_sys_status foa,
             fnd_concurrent_queues fcq,
             fnd_oam_svci_info fsi
        where foa.application_id = fcq.application_id
          and foa.concurrent_queue_name = fcq.concurrent_queue_name
          and foa.application_id = fsi.application_id (+)
          and foa.concurrent_queue_name = fsi.concurrent_queue_name (+)
          and nvl(fsi.collection_enabled_flag, 'Y') = 'Y'
          and nvl(fsi.alert_enabled_flag, 'N') = 'Y';

     v_metric_list varchar2(3500) := '';
     v_st_list varchar2(3500) := '';
     v_temp varchar2(300) := '';

     v_x varchar2(2000);
  BEGIN
    for met in c_mets loop
      if (shall_raise_alert(met.metric_short_name)) then
        v_temp := met.metric_short_name;
        if (met.metric_type = 'S') then
          v_temp := v_temp || ':' || met.status_code || ',';
          if (length(v_st_list || v_temp) < 3500) then
            v_st_list := v_st_list || v_temp;
          end if;
        else
          v_temp := v_temp ||':'||met.threshold_operator||':'||met.threshold_value||',';
          if (length(v_metric_list || v_temp) < 3500) then
            v_metric_list := v_metric_list || v_temp;
          end if;
        end if;
      end if;
    end loop;

    for svci in c_svci loop
      if (shall_raise_alert(svci.application_id,
                svci.concurrent_queue_name)) then
        v_temp := svci.application_id||':'||svci.concurrent_queue_id||':'||svci.status_code||',';

        if (length(v_st_list || v_temp) < 3500) then
          v_st_list := v_st_list || v_temp;
        end if;
      end if;
    end loop;

    if (length(v_metric_list) > 0) then
     if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
        fnd_message.clear;
        fnd_message.set_name('FND','OAM_DASHBOARD_METRIC_ALERT');
        fnd_message.set_token_sql('METRICS_AND_VALUES',
          'select fnd_oam_dashboard_util.get_trans_name_values(''MET'','''||v_metric_list||''') from dual');
        --dbms_output.put_line('MET ALERT: ' || fnd_message.get);
        fnd_log.message(log_level=>fnd_log.level_unexpected,
                      module=>MODULE||'.raise_alert',
                      pop_message=>true);
      end if;
    end if;

    if (length(v_st_list) > 0) then
      if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
        fnd_message.clear;
        fnd_message.set_name('FND','OAM_DASHBOARD_STATUS_ALERT');
        fnd_message.set_token_sql('COMPONENTS_AND_STATUS',
          'select fnd_oam_dashboard_util.get_trans_name_values(''STATUS'','''||v_st_list||''') from dual');
        --dbms_output.put_line('STATUS ALERT: ' || fnd_message.get);
        fnd_log.message(log_level=>fnd_log.level_unexpected,
                      module=>MODULE||'.raise_alert',
                      pop_message=>true);
      end if;
    end if;
  END;


  --
  -- Name
  --   refresh_all
  --
  -- Purpose
  --   Computes the values for all the indicators and updates the
  --   fnd_oam_mets table.
  --
  -- Input Arguments
  --
  -- Output Arguments
  --    errbuf - for any error message
  --    retcode - 0 for success, 1 for success with warnings, 2 for error
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_all (errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2)
  IS

  BEGIN
    fnd_file.put_line(fnd_file.log, 'Refreshing All ...');

    fnd_file.put_line(fnd_file.log, 'Refreshing Applications System Status ...');
    refresh_app_sys_status;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing Activity ...');
    refresh_activity;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing Configuration Changes ...');
    refresh_config_changes;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing Throughput ...');
    refresh_throughput;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing Exceptions Summary ...');
    refresh_exceptions_summary;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing Miscellaneous ...');
    refresh_miscellaneous;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Done refreshing All ...');

    -- Cancel any reduntant pending requests
    fnd_file.put_line(fnd_file.log, 'Cancelling any pending requests for FNDOAMCOL ...');
    declare
      cursor pending_req is
      select
        fcr.request_id request_id
      from fnd_concurrent_requests fcr, fnd_concurrent_programs fcp
      where
        fcr.program_application_id = fcp.application_id
        and fcr.concurrent_program_id = fcp.concurrent_program_id
        and fcp.concurrent_program_name = 'FNDOAMCOL'
        and fcr.phase_code = 'P';
      ret_code number;
      ret_msg varchar2(1000);
    begin
      for p_r in pending_req loop
        begin
                ret_code := -1;
                ret_msg := '';
                fnd_file.put_line(fnd_file.log, 'Found pending request: ' || p_r.request_id);
                ret_code := fnd_amp_private.cancel_request(p_r.request_id, ret_msg);
                if (ret_code <> 4 and ret_code <> 5) then
                        fnd_file.put_line(fnd_file.log, 'Unable to cancel request ' || p_r.request_id);
                        fnd_file.put_line(fnd_file.log, 'Message: ' || ret_msg);
                elsif (ret_code >= 0) then
                        fnd_file.put_line(fnd_file.log, 'Cancelled request ' || p_r.request_id);
                else
                        fnd_file.put_line(fnd_file.log, 'ret_code: ' || ret_code);
                        fnd_file.put_line(fnd_file.log, 'Message: ' || ret_msg);
                end if;
        end;
      end loop;

    exception
        -- some error occurred while cancelling pending requests
        -- Not failing the program since refresh was completed successfully.
        when others then
          null;
    end;
    fnd_file.new_line(fnd_file.log, 1);
    fnd_file.put_line(fnd_file.log, 'Done cancelling any pending requests for FNDOAMCOL ...');

    retcode := '0';
    errbuf := 'Refresh Action OK';
  EXCEPTION
    when others then
      retcode := '2';
      errbuf := SQLERRM;
  END refresh_all;

  --
  -- Name
  --   submit_col_req_conditional
  --
  -- Purpose
  --   Submits a request for program 'FNDOAMCOL' if and only if there are no
  --   other requests for this program in the pending or running phase.
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  --
  -- Notes:
  --
  --
  PROCEDURE submit_col_req_conditional
  IS
    retcode number;
    retval boolean;
    msg varchar2(1000);
    active_count number;

    appl_id number;
    resp_id number;
    user_id number;
    user_name varchar2(80);
    resp_name varchar2(80);
    resp_key varchar2(50);

    p_request_id number := null;
    p_phase varchar2(100);
    p_status varchar2(100);
    p_dev_phase varchar2(100);
    p_dev_status varchar2(100);
    p_message varchar2(500);
    outcome boolean;
  BEGIN
    -- First query to see if there is a request already submitted for this
    -- program.
    outcome :=
      fnd_concurrent.get_request_status(
        request_id=>p_request_id,
        appl_shortname=>'FND',
        program=>'FNDOAMCOL',
        phase=>p_phase,
        status=>p_status,
        dev_phase=>p_dev_phase,
        dev_status=>p_dev_status,
        message=>p_message);

    --dbms_output.put_line('REQ ID ' || p_request_id);
    --dbms_output.put_line('PHASE ' || p_phase);
    --dbms_output.put_line('STATUS ' || p_status);
    --dbms_output.put_line('DEV_PHASE ' || p_dev_phase);
    --dbms_output.put_line('DEV_STATUS ' || p_dev_status);
    --dbms_output.put_line('MESSAGE ' || p_message);
    if p_dev_phase is null then
        p_dev_phase := 'X';
    end if;
    if  ((outcome = false and p_request_id is null) or
        (outcome = true and p_request_id is not null and
                p_dev_phase <> 'PENDING' and
                p_dev_phase <> 'RUNNING')) and
       fnd_program.program_exists('FNDOAMCOL', 'FND') = true then

      --dbms_output.put_line('Submmitting request');
      --select application_id, responsibility_id, responsibility_name
      --  into   appl_id, resp_id, resp_name
      --    from fnd_responsibility_vl
      --where responsibility_name = 'System Administrator';

      select application_id, responsibility_id, responsibility_key
        into appl_id, resp_id, resp_key
          from fnd_responsibility
        where responsibility_key = 'SYSTEM_ADMINISTRATOR';

      select user_id, user_name
        into user_id, user_name
          from fnd_user
      where user_name = 'SYSADMIN';

      -- Now initialize the environment for SYSADMIN
      fnd_global.apps_initialize(user_id, resp_id, appl_id);

      -- Set the repeat options
      retval := fnd_request.set_repeat_options(repeat_interval => 10,
                                               repeat_unit => 'MINUTES',
                                               repeat_type => 'END');

      -- Submit the request.
      retcode := fnd_request.submit_request(application=>'FND', program=>'FNDOAMCOL');

    end if;
    commit;
  EXCEPTION
    when others then
      rollback;
      null;
  END submit_col_req_conditional;

  --
  -- Name
  --   resubmit
  --
  -- Purpose
  --   Submits a request for program 'FNDOAMCOL' with the new repeat
  --   interval if the current interval is different from the new repeat
  --   interval.
  --
  --   It will cancel any pending or running requests before submitting
  --   a new request.
  --
  --   If more than one repeating requests are found, it will cancel them
  --   all and submit a new request with the given repeat interval.
  --
  --
  -- Input Arguments
  --
  --   p_repeat_interval - The new repeat interval
  --   p_repeat_interval_unit_code - The new repeat interval unit code
  --
  -- Output Arguments
  --   p_ret_code
  --      -1 - Was unable to cancel one or more in progress requests.
  --           Check p_ret_msg for any error message.
  --      -2 - There was no need to resubmit - since the currently
  --            repeating request has the same repeat interval.
  --      >0 - Successfully resubmitted. Request id of the new request.
  --
  --   p_ret_msg
  --      Any return error message.
  -- Notes:
  --
  --
  PROCEDURE resubmit(
        p_repeat_interval fnd_concurrent_requests.resubmit_interval%TYPE,
        p_repeat_interval_unit_code fnd_concurrent_requests.resubmit_interval_unit_code%TYPE,
        p_ret_code OUT NOCOPY number,
        p_ret_msg OUT NOCOPY varchar2)
  IS
    v_in_progress_count number := 0;
    v_continue_submit boolean := false;
    v_curr_interval fnd_concurrent_requests.resubmit_interval%TYPE;
    v_curr_unit_code fnd_concurrent_requests.resubmit_interval_unit_code%TYPE;
    ret_code number := -1;
    ret_msg varchar2(1000) := '';
    retval boolean;
  BEGIN
    select count(*) into  v_in_progress_count
      from fnd_concurrent_requests fcr,
           fnd_concurrent_programs fcp
      where
        fcr.program_application_id = fcp.application_id
        and     fcr.concurrent_program_id = fcp.concurrent_program_id
        and     fcp.concurrent_program_name = 'FNDOAMCOL'
        and     fcr.phase_code in ('R','P')
        and     fcr.resubmit_interval is not null
        and     fcr.resubmit_interval_unit_code is not null;

    if (v_in_progress_count <> 1) then
        v_continue_submit := true;
    else
      -- compare repeat intervals to see if we need to resubmit
      select fcr.resubmit_interval, fcr.resubmit_interval_unit_code
        into v_curr_interval, v_curr_unit_code
        from fnd_concurrent_requests fcr,
           fnd_concurrent_programs fcp
      where
        fcr.program_application_id = fcp.application_id
        and     fcr.concurrent_program_id = fcp.concurrent_program_id
        and     fcp.concurrent_program_name = 'FNDOAMCOL'
        and     fcr.phase_code in ('R','P')
        and     fcr.resubmit_interval is not null
        and     fcr.resubmit_interval_unit_code is not null;

     if (v_curr_interval <> p_repeat_interval or
         v_curr_unit_code <> p_repeat_interval_unit_code) then
        v_continue_submit := true;
     else
        p_ret_code := -2; -- there was no need to resubmit
        p_ret_msg := '';
     end if;
    end if;

    if (v_continue_submit = true) then
      -- cancel all pending running requests for FNDOAMCOL and submit new
      declare
        cursor repeating_req is
        select
          fcr.request_id request_id
        from fnd_concurrent_requests fcr, fnd_concurrent_programs fcp
          where
          fcr.program_application_id = fcp.application_id
          and fcr.concurrent_program_id = fcp.concurrent_program_id
          and fcp.concurrent_program_name = 'FNDOAMCOL'
          and fcr.phase_code in ('P','R');


      begin
       for p_r in repeating_req loop
        begin
                ret_code := fnd_amp_private.cancel_request(p_r.request_id, ret_msg);
                if (ret_code <> 4 and ret_code <> 5) then
                  p_ret_code := -1;
                  p_ret_msg := ret_msg;
                  -- unable to cancel request
                  return;
                end if;

                -- log some debugging info
                if (fnd_log.level_event >= fnd_log.g_current_runtime_level) then
                  fnd_log.string(log_level=>fnd_log.level_event,
                      module=>MODULE||'.resubmit',
                      message=>'Cancelled Request ' || p_r.request_id);
                end if;
        end;
       end loop;

       -- Set the repeat options
       retval := fnd_request.set_repeat_options(
                        repeat_interval => p_repeat_interval,
                        repeat_unit => p_repeat_interval_unit_code,
                        repeat_type => 'END');
       -- Submit the request.
       p_ret_code := fnd_request.submit_request(application=>'FND', program=>'FNDOAMCOL');
       p_ret_msg := ret_msg;

       -- check for any errors in the request submission
       if (p_ret_code = 0) then
         p_ret_msg := fnd_message.get;
       end if;
     exception
        -- some error occurred
        when others then
          raise;
     end;

    end if;

  END resubmit;

  --
  -- API to check if an already new or open alert exists for the given
  -- encoded messge
  --
/*
  FUNCTION is_alert_open ( p_enc_msg fnd_log_unique_exceptions.encoded_message%TYPE) RETURN boolean
  IS
        v_exists boolean := FALSE;
        v_temp number := 0;
  BEGIN
debug('p_enc_msg: ' || p_enc_msg);
        begin
          select 1 into v_temp
                from fnd_log_unique_exceptions
                where encoded_message = p_enc_msg
                and status in ('N','O');
          v_exists := TRUE;
        exception
          when no_data_found then
            v_exists := FALSE;
        end;
debug('is_alert_open returning ' || v_temp);
        return v_exists;
  END is_alert_open;
*/

  --
  -- Internal API for Alerting for Long Running Requests General
  --
  PROCEDURE ALERT_LRR_GEN
  IS
    v_lng_run_req_count fnd_oam_metval_vl.metric_value%TYPE;
    v_lng_run_req_alert_enable varchar2(1):='';
    v_lng_run_req_tolerance varchar2(10):='';
    v_lng_run_req_offset varchar2(10):='';

    cursor req_id_list(p_tol varchar2,p_offset varchar2) is
      select fcr.request_id  request_id,
             fcp.user_concurrent_program_name user_concurrent_program_name
      from
             fnd_concurrent_requests fcr,
             fnd_conc_prog_onsite_info fcpoi,
             fnd_concurrent_programs_vl fcp
      where
             fcr.program_application_id=fcpoi.program_application_id
             AND fcp.application_id = fcr.PROGRAM_APPLICATION_ID
             AND fcp.CONCURRENT_PROGRAM_ID=fcr.CONCURRENT_PROGRAM_ID
             and fcr.concurrent_program_id=fcpoi.concurrent_program_id
             and fcpoi.avg_run_time is not null
             and (sysdate -fcr.ACTUAL_START_DATE)*86400 >
                        (fcpoi.avg_run_time*(1+.01*to_number(p_tol)))
             and ((sysdate -fcr.ACTUAL_START_DATE)*86400 >
                        (to_number(p_offset)*60))
             and fcr.phase_code='R';

    -- Types for record of tables
    TYPE NumTabType IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
    TYPE VarcharTabType IS TABLE OF
        fnd_concurrent_programs_vl.user_concurrent_program_name%TYPE
          INDEX BY BINARY_INTEGER;

    TYPE RecTabType IS RECORD
        (request_id NumTabType,
         display_name VarcharTabType);

    v_req_list_rec RecTabType;
    v_attch_id number;

  BEGIN
    select threshold_value, alert_enabled_flag
      into v_lng_run_req_count, v_lng_run_req_alert_enable
      from fnd_oam_metval
      where  metric_short_name ='LONG_RUNNING_REQ_COUNT';

    select threshold_value into v_lng_run_req_tolerance
      from fnd_oam_metval
      where  metric_short_name ='LONG_RUNNING_REQ_TOLERANCE';

    select threshold_value into v_lng_run_req_offset
      from fnd_oam_metval
      where  metric_short_name ='LONG_RUNNING_REQ_OFFSET';

    if(v_lng_run_req_alert_enable ='Y') then
      open req_id_list(v_lng_run_req_tolerance,v_lng_run_req_offset);
      fetch req_id_list bulk collect
        into v_req_list_rec.request_id, v_req_list_rec.display_name;
      close req_id_list;

      if ((v_req_list_rec.request_id is not null) and (v_req_list_rec.request_id.count >= TO_NUMBER(v_lng_run_req_count))) then
       -- raise alert with attachment
       if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
         fnd_message.clear;
         fnd_message.set_name('FND','OAM_SYSAL_LONG_RUNNING_REQ_GEN');
         fnd_message.set_token('COUNT',v_lng_run_req_count);
         fnd_message.set_token('TOLERANCE',v_lng_run_req_tolerance);
         v_attch_id := fnd_log.message_with_attachment(
                log_level=>fnd_log.level_unexpected,
                module=>MODULE||'.Alert_Long_Running_Requests',
                pop_message=>false);
         fnd_log_attachment.writeln(
                pattachment_id => v_attch_id,
                pmessage => fnd_message.get);
         fnd_log_attachment.writeln(
                pattachment_id => v_attch_id,
                pmessage => ' ');
         for i in v_req_list_rec.request_id.FIRST..v_req_list_rec.request_id.LAST loop
           -- write info to attachment about each request.
           fnd_log_attachment.writeln(
                pattachment_id => v_attch_id,
                pmessage => v_req_list_rec.request_id(i) || ' - ' ||
                            v_req_list_rec.display_name(i));
         end loop;
         fnd_log_attachment.close(
                pattachment_id => v_attch_id);
       end if;
      end if;
    end if; -- if(v_lng_run_req_alert_enable ='Y') then

  END ALERT_LRR_GEN;

  --
  -- Internal API for Alerting for Long Running Requests Specific
  --
  PROCEDURE ALERT_LRR_SPE
  IS
    v_spec_long_run_enabled varchar2(1):='';

    cursor spec_req_id_list is
      select fcr.request_id  request_id,
             fcp.user_concurrent_program_name user_concurrent_program_name,
             fcpoi.max_run_time max_run_time,
             fcpoi.avg_run_time avg_run_time,
             fcpoi.alert_long_running_threshold/60 threshold_minutes,
             fcpoi.alert_long_running_tolerance tolerance
      from
             fnd_concurrent_requests fcr,
             fnd_conc_prog_onsite_info fcpoi,
             fnd_concurrent_programs_vl fcp
      where
             fcr.program_application_id=fcpoi.program_application_id
             AND fcp.CONCURRENT_PROGRAM_ID=fcr.CONCURRENT_PROGRAM_ID
             AND fcp.application_id = fcr.PROGRAM_APPLICATION_ID
             and fcr.concurrent_program_id=fcpoi.concurrent_program_id
             and ((fcpoi.ALERT_LONG_RUNNING_THRESHOLD is not null)
                or (fcpoi.AVG_RUN_TIME is not null))
             and (sysdate -fcr.ACTUAL_START_DATE)*86400 >
                (to_number(nvl(fcpoi.ALERT_LONG_RUNNING_THRESHOLD,
                   fcpoi.AVG_RUN_TIME))*(1+.01*to_number(nvl(
                        fcpoi.ALERT_LONG_RUNNING_TOLERANCE,0))))
             and fcpoi.ALERT_LONG_RUNNING_ENABLED='Y'
             and fcr.phase_code='R';

    -- Types for record of tables
    TYPE NumTabType IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
    TYPE VarcharTabType IS TABLE OF
        fnd_concurrent_programs_vl.user_concurrent_program_name%TYPE
          INDEX BY BINARY_INTEGER;

    TYPE SpecRecTabType IS RECORD
        (request_id NumTabType,
         display_name VarcharTabType,
         max_run_time NumTabType,
         avg_run_time NumTabType,
         threshold NumTabType,
         tolerance NumTabType);

    v_spec_req_list_rec SpecRecTabType;

    v_spec_cnt number := 0;
    v_spec_tol number;

  BEGIN

    select threshold_value into v_spec_long_run_enabled
      from fnd_oam_metval
      where  metric_short_name ='SPECIFIC_LONG_RUNNING_ENABLED';

    if(v_spec_long_run_enabled ='Y') then
      --debug('v_spec_long_run_enabled is Y');
      select count(*) into v_spec_cnt
        from fnd_conc_prog_onsite_info
          where ALERT_LONG_RUNNING_ENABLED='Y' and rownum < 2;
     if (v_spec_cnt > 0) then
      open spec_req_id_list;
      fetch spec_req_id_list bulk collect
         into v_spec_req_list_rec.request_id,
             v_spec_req_list_rec.display_name,
             v_spec_req_list_rec.max_run_time,
             v_spec_req_list_rec.avg_run_time,
             v_spec_req_list_rec.threshold,
             v_spec_req_list_rec.tolerance;
      close spec_req_id_list;

      if (v_spec_req_list_rec.request_id is not null and v_spec_req_list_rec.request_id.count > 0) then
       for i in v_spec_req_list_rec.request_id.FIRST..v_spec_req_list_rec.request_id.LAST loop
      --debug('Looping in cursor spec_req_id_list');
        if ((fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)) then
          -- Compute tolerance for this program
          v_spec_tol := round(
           nvl(v_spec_req_list_rec.threshold(i),
             v_spec_req_list_rec.avg_run_time(i))*(
               1+.01*to_number(nvl(
                 v_spec_req_list_rec.tolerance(i),0))));

          -- Note: In the future if we provide users with more options, we
          -- may need to choose different messages based on those options

          -- raise proxy alert for each request
          fnd_message.clear;
          fnd_message.set_name('FND','OAM_SYSAL_LONG_RUNNING_REQ_SPE');
          fnd_message.set_token('PROG', v_spec_req_list_rec.display_name(i));
          fnd_message.set_token('TOLERANCE', v_spec_tol);
          fnd_log.proxy_alert_for_conc_req(
            module => MODULE||'.Alert_Long_Running_Requests',
            pop_message => true,
            request_id => v_spec_req_list_rec.request_id(i));
        end if;
       end loop;
      end if;
     end if;
   end if;

  END ALERT_LRR_SPE;

  --
  -- Internal API for Alerting for Long Pending Requests General
  --
  PROCEDURE ALERT_LPR_GEN
  IS
    v_lng_pend_req_count fnd_oam_metval_vl.metric_value%TYPE;
    v_lng_pend_req_alert_enable varchar2(1):='';
    v_lng_pend_req_tolerance varchar2(10):='';

    cursor req_id_list(p_tol varchar2) is
      select fcr.request_id  request_id,
             fcp.user_concurrent_program_name user_concurrent_program_name
        from
             fnd_concurrent_requests fcr,
             fnd_conc_prog_onsite_info fcpoi,
             fnd_concurrent_programs_vl fcp
        where
             fcr.program_application_id=fcpoi.program_application_id
             AND fcp.application_id = fcr.PROGRAM_APPLICATION_ID
             AND fcp.CONCURRENT_PROGRAM_ID=fcr.CONCURRENT_PROGRAM_ID
             and fcr.concurrent_program_id=fcpoi.concurrent_program_id
             and ((sysdate -fcr.REQUESTED_START_DATE)*86400 >
                  (to_number(nvl(p_tol,0))*60))
             and fcr.phase_code='P'
             and fcr.status_code in  ('I', 'Q');

    -- Types for record of tables
    TYPE NumTabType IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
    TYPE VarcharTabType IS TABLE OF
        fnd_concurrent_programs_vl.user_concurrent_program_name%TYPE
          INDEX BY BINARY_INTEGER;

    TYPE RecTabType IS RECORD
        (request_id NumTabType,
         display_name VarcharTabType);

    v_req_list_rec RecTabType;
    v_attch_id number;

  BEGIN
    select threshold_value,alert_enabled_flag
      into v_lng_pend_req_count,v_lng_pend_req_alert_enable
      from fnd_oam_metval
      where  metric_short_name ='LONG_PENDING_REQ_COUNT';

    select threshold_value
      into v_lng_pend_req_tolerance
      from fnd_oam_metval
      where  metric_short_name ='LONG_PENDING_REQ_TOLERANCE';

    if(v_lng_pend_req_alert_enable ='Y') then
      open req_id_list(v_lng_pend_req_tolerance);
      fetch req_id_list bulk collect
        into v_req_list_rec.request_id, v_req_list_rec.display_name;
      close req_id_list;

      if (v_req_list_rec.request_id is not null and v_req_list_rec.request_id.count >= TO_NUMBER(v_lng_pend_req_count)) then
       if (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
         fnd_message.clear;
         fnd_message.set_name('FND','OAM_SYSAL_LONG_PENDING_REQ_GEN');
         fnd_message.set_token('COUNT',v_lng_pend_req_count);
         fnd_message.set_token('TOLERANCE',v_lng_pend_req_tolerance);
         v_attch_id := fnd_log.message_with_attachment(
                log_level=>fnd_log.level_unexpected,
                module=>MODULE||'.Alert_Long_Pending_Requests',
                pop_message=>false);
         fnd_log_attachment.writeln(
                pattachment_id => v_attch_id,
                pmessage => fnd_message.get);
         fnd_log_attachment.writeln(
                pattachment_id => v_attch_id,
                pmessage => ' ');
         for i in v_req_list_rec.request_id.FIRST..v_req_list_rec.request_id.LAST loop
           -- write info to attachment about each request.
           fnd_log_attachment.writeln(
                pattachment_id => v_attch_id,
                pmessage => v_req_list_rec.request_id(i) || ' - ' ||
                            v_req_list_rec.display_name(i));
         end loop;
         fnd_log_attachment.close(
                pattachment_id => v_attch_id);
        end if;
      end if;
    end if; -- if(v_lng_pend_req_alert_enable ='Y') then

  END ALERT_LPR_GEN;

  --
  -- Internal API for Alerting for Long Pending Requests Specific
  --
  PROCEDURE ALERT_LPR_SPE
  IS
    v_spec_long_pend_enabled varchar2(1):='';

    cursor spec_req_id_list is
      select fcr.request_id  request_id,
             fcp.user_concurrent_program_name user_concurrent_program_name,
             nvl(fcpoi.ALERT_LONG_PENDING_TOLERANCE,0)/60 tolerance_minutes
        from
             fnd_concurrent_requests fcr,
             fnd_conc_prog_onsite_info fcpoi,
             fnd_concurrent_programs_vl fcp
        where
             fcr.program_application_id=fcpoi.program_application_id
             AND fcp.application_id = fcr.PROGRAM_APPLICATION_ID
             AND fcp.CONCURRENT_PROGRAM_ID=fcr.CONCURRENT_PROGRAM_ID
             and fcr.concurrent_program_id=fcpoi.concurrent_program_id
             and (sysdate -fcr.REQUESTED_START_DATE)*86400 >
                  (to_number(nvl(fcpoi.ALERT_LONG_PENDING_TOLERANCE,0)))
             and fcpoi.ALERT_LONG_PENDING_ENABLED='Y'
             and fcr.phase_code='P'
             and fcr.status_code in  ('I', 'Q');

    -- Types for record of tables
    TYPE NumTabType IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
    TYPE VarcharTabType IS TABLE OF
        fnd_concurrent_programs_vl.user_concurrent_program_name%TYPE
          INDEX BY BINARY_INTEGER;

    TYPE SpecRecTabType IS RECORD
        (request_id NumTabType,
         display_name VarcharTabType,
         tolerance NumTabType);

    v_spec_req_list_rec SpecRecTabType;
    v_spec_cnt number := 0;
  BEGIN

    select threshold_value
      into v_spec_long_pend_enabled
      from fnd_oam_metval
      where  metric_short_name ='SPECIFIC_LONG_PENDING_ENABLED';

    if (v_spec_long_pend_enabled ='Y') then
     select count(*) into v_spec_cnt
       from fnd_conc_prog_onsite_info
         where ALERT_LONG_PENDING_ENABLED='Y' and rownum < 2;

     if (v_spec_cnt > 0) then
      open spec_req_id_list;
      fetch spec_req_id_list bulk collect
        into
          v_spec_req_list_rec.request_id,
          v_spec_req_list_rec.display_name,
          v_spec_req_list_rec.tolerance;
      close spec_req_id_list;

      if (v_spec_req_list_rec.request_id is not null and v_spec_req_list_rec.request_id.count > 0) then
       for i in v_spec_req_list_rec.request_id.FIRST..v_spec_req_list_rec.request_id.LAST loop
        if ((fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)) then
          fnd_message.clear;
          fnd_message.set_name('FND','OAM_SYSAL_LONG_PENDING_REQ_SPE');
          fnd_message.set_token('PROG', v_spec_req_list_rec.display_name(i));
          fnd_message.set_token('TOLERANCE', v_spec_req_list_rec.tolerance(i));
          fnd_log.proxy_alert_for_conc_req(
            module => MODULE||'.Alert_Long_Pending_Requests',
            pop_message => true,
            request_id => v_spec_req_list_rec.request_id(i));
        end if;
       end loop;
      end if;
     end if;
    end if;

  END ALERT_LPR_SPE;

  --
  -- Name
  --   Alert_Long_Running_Requests
  --
  -- Purpose
  --    The procedure will raise a consolidated alert if more than
  --    a user specified threshold
  --    number of concurrent requests are running for more than a
  --    user specified threshold offset
  --    period of time and for more than a user specified threshold
  --    tolerance percentage of their
  --    respective average runtimes. It also raise an alert for specified
  --    concurrent programs if it
  --    runs for more than the user specified threshold tolerance percentage
  --    of its user specific threshold offset period of time.
  --
  -- Input Arguments
  --
  --    None
  --
  -- Output Arguments
  --
  --    None
  --
  -- Notes:
  --
  --
  PROCEDURE Alert_Long_Running_Requests
  IS
  BEGIN
    --
    -- Check logging enabled in the first place. There's nothing to do
    -- if not enabled.
    --
    if (fnd_log.level_unexpected < fnd_log.g_current_runtime_level) then
      fnd_file.put_line(fnd_file.log, 'Logging Not Enabled.');
      return;
    end if;

    -- General Alert
    ALERT_LRR_GEN;
    -- Specific Alert
    ALERT_LRR_SPE;

  END  Alert_Long_Running_Requests;


  --
  -- Name
  --   Alert_Long_Pending_Requests
  --
  -- Purpose
  --
  --   The procedure raises a consolidated alert if more than a user specified
  --   threshold number of concurrent requests are pending for more than a user
  --   specified threshold period of time after their requested start time.
  --   It also raise an alert for specified concurrent programs if it is
  --   pending for more than a user specified threshold period of time.
  --
  -- Input Arguments
  --
  --   None
  --
  -- Output Arguments
  --
  --   None
  --
  -- Notes:
  --
  --
  PROCEDURE Alert_Long_Pending_Requests
  IS

  BEGIN
    --
    -- Check logging enabled in the first place. There's nothing to do
    -- if not enabled.
    --
    if (fnd_log.level_unexpected < fnd_log.g_current_runtime_level) then
      fnd_file.put_line(fnd_file.log, 'Logging Not Enabled.');
      return;
    end if;

    -- General Alert
    ALERT_LPR_GEN;
    -- Specific Alert
    ALERT_LPR_SPE;

  END Alert_Long_Pending_Requests;

END fnd_oam_collection;

/

  GRANT EXECUTE ON "APPS"."FND_OAM_COLLECTION" TO "EM_OAM_MONITOR_ROLE";
