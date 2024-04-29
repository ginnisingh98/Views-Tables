--------------------------------------------------------
--  DDL for Package Body FND_OAM_CPCHARTS_COL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_CPCHARTS_COL" AS
  /* $Header: AFOAMCCB.pls 120.0 2005/11/18 15:37:25 appldev noship $ */
  --
  -- Name
  --   refresh_all
  --
  -- Purpose
  --   Computes the values for all the chart metrics and updates the
  --   fnd_oam_chart_metrics table.
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
    fnd_file.put_line(fnd_file.log, 'OAM Chart Collection, Refreshing All ...');

    fnd_file.put_line(fnd_file.log, 'Refreshing concurrent requests status ...');
    refresh_req_status;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing completed requests status ...');
    refresh_completed_req_status;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing pending requests status ...');
    refresh_pending_req_status;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing running requests duration ...');
    refresh_running_req_duration;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing running request counts grouped by user ...');
    refresh_running_req_user;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing running request counts grouped by application ...');
    refresh_running_req_app;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing running request counts grouped by responsibility ...');
    refresh_running_req_resp;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing pending request counts grouped by user ...');
    refresh_pending_req_user;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing pending request counts grouped by application ...');
    refresh_pending_req_app;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing pending request counts grouped by responsibility ...');
    refresh_pending_req_resp;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing pending request counts grouped by manager ...');
    refresh_pend_req_mgr;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing running request and process counts grouped by responsibility ...');
    refresh_run_req_process_mgr;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing the Concurrent requests statististics by user ...');
    refresh_req_stats_user;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Refreshing the Concurrent requests statististics by program ...');
    refresh_req_stats_program;
    fnd_file.new_line(fnd_file.log, 1);

    fnd_file.put_line(fnd_file.log, 'Done refreshing All ...');

  EXCEPTION
    when others then
      retcode := '2';
      errbuf := SQLERRM;
  END refresh_all;


  --
  --
  -- Gets the current user id
  --
  FUNCTION get_user_id RETURN number
  IS
    v_userid number;

   BEGIN
          select fnd_global.user_id into v_userid from dual;
          if (v_userid < 0 or v_userid is null) then
                v_userid := 0; -- default
          end if;

        return v_userid;
   EXCEPTION
        when others then
          v_userid := 0;
          return v_userid;
   END get_user_id;

  -- Name
  --   insert_metric_internal
  -- Purpose
  --   This procedure is for internal use only!
  --   This procedure will insert a row in fnd_oam_chart_metrics for the given
  --   metric name.
  --
  -- Input Arguments
  --    p_metric_name varchar2
  --    p_context varchar2
  --    p_value number
  --
  -- Output Arguments
  --
  -- Input/Output Arguments
  --
  -- Notes:
  --    This is an internal convenience method only for OAM chart data collection
  --
  PROCEDURE insert_metric_internal (
      p_metric_name in varchar2,
      p_context in varchar2,
      p_value in number)
  IS
        v_userid number;
  BEGIN
      v_userid := get_user_id;

-- insert the data
      insert into fnd_oam_chart_metrics (metric_short_name, metric_context,
          value, last_updated_by, last_update_date,
          last_update_login, created_by, creation_date)
      values (p_metric_name, p_context, p_value,
              v_userid, sysdate, v_userid, 0, sysdate);

  END insert_metric_internal;

  -- Name
  --   update_metric_internal
  -- Purpose
  --   This procedure is for internal use only!
  --   This procedure will update a row in fnd_oam_chart_metrics for the given
  --   metric name. If it does not exist, then insert.
  --
  -- Input Arguments
  --    p_metric_name varchar2
  --    p_context varchar2
  --    p_value number
  --
  -- Output Arguments
  --
  -- Input/Output Arguments
  --
  -- Notes:
  --    This is an internal convenience method only for OAM chart data collection
  --

  PROCEDURE update_metric_internal (
      p_metric_name in varchar2,
      p_context in varchar2,
      p_value in number)
  IS
        v_userid number;
        name varchar2(30);
  BEGIN
      v_userid := get_user_id;

      select metric_short_name into name
        from fnd_oam_chart_metrics
        where metric_short_name = p_metric_name
          and metric_context = p_context;

      if(name is not null) then
        update fnd_oam_chart_metrics
        set value = p_value,
          last_updated_by = v_userid,
          last_update_date = sysdate,
          last_update_login = v_userid
        where
          metric_short_name = p_metric_name
          and metric_context = p_context;
      end if;

      exception
          when no_data_found then
          -- insert the data
        insert into fnd_oam_chart_metrics (metric_short_name, metric_context,
          value, last_updated_by, last_update_date,
          last_update_login, created_by, creation_date)
        values (p_metric_name, p_context, p_value,
              v_userid, sysdate, v_userid, 0, sysdate);

  END update_metric_internal;

  -- Name
  --   delete_metric_internal
  -- Purpose
  --   This procedure is for internal use only!
  --   This procedure will delete the metric entry if it exists in fnd_oam_chart_metrics for the given
  --   metric name regardless of the context.
  --
  -- Input Arguments
  --    p_metric_name varchar2
  --
  -- Output Arguments
  --
  -- Input/Output Arguments
  --
  -- Notes:
  --    This is an internal convenience method only for OAM chart data collection
  --
  PROCEDURE delete_metric_internal (
      p_metric_name in varchar2)
  IS
  BEGIN

--  delete the entry
       delete from fnd_oam_chart_metrics
        where metric_short_name = p_metric_name;

  END delete_metric_internal;


  --
  -- Name
  --   refresh_req_status
  --
  -- Purpose
  --   Computes the metric values for the all request status
  --
  PROCEDURE refresh_req_status
  IS

  BEGIN

    update_req_status_metric('REQ_RUNNING');
    update_req_status_metric('REQ_PENDING');
    update_req_status_metric('REQ_COMPLETED');
    update_req_status_metric('REQ_WAITING_ON_LOCK');
    update_req_status_metric('REQ_INACTIVE');

  END refresh_req_status;
  --
  -- Name
  --   update_req_status_metric
  --
  -- Purpose
  --   compute the metric value for one request status
  --
  PROCEDURE update_req_status_metric(p_metric_name in varchar2)
  IS
    ct_running number;
    ct_pending number;
    ct_completed number;
    ct_waiting_on_lock number;
    ct_inactive number;
  BEGIN

      if(p_metric_name = 'REQ_RUNNING') then
        select count(*) into ct_running
          from  fnd_concurrent_requests
          where status_code = 'R';

        -- Update the number of running requests, use 0 for the metric_context
        update_metric_internal(p_metric_name, '0', ct_running);
      end if;

      if(p_metric_name = 'REQ_PENDING') then
        select count(rv.Request_ID) into ct_pending
         from Fnd_amp_requests_v rv,
            Fnd_lookups l
         Where  rv.phase_code = 'P'
         and l.meaning = rv.phase
         and l.lookup_code = 'P'
         and l.lookup_type = 'CP_PHASE_CODE';

/*query from old request java code:
        select count(distinct(R.Request_ID)) into ct_pending
         from Fnd_Concurrent_Programs_vl CP,
            Fnd_User U,
            Fnd_Concurrent_Requests R,
            Fnd_Responsibility_Tl RES,
            Fnd_Application A,
            Fnd_amp_requests_v rv,
            Fnd_lookups l
         Where  rv.phase_code = 'P'
         and l.meaning = rv.phase
         and l.lookup_code = 'P'
         and l.lookup_type = 'CP_PHASE_CODE'
         And CP.Application_ID = rv.Program_Application_ID
         And CP.Concurrent_Program_ID = rv.Concurrent_Program_ID
         and R.request_id = rv.request_id
         and rv.Program_Application_ID = R.Program_Application_ID
         And rv.Concurrent_Program_ID = R.Concurrent_Program_ID
         And A.Application_ID = rv.Program_Application_ID
         And U.User_ID = R.Requested_By
         And RES.application_id = R.responsibility_application_id
         AND RES.language(+)=USERENV('LANG')
         And RES.responsibility_id = R.responsibility_id;
*/
        -- update the number of pending requests, use 0 for the metric_context
        update_metric_internal(p_metric_name, '0', ct_pending);
      end if;

      if(p_metric_name = 'REQ_COMPLETED') then
        select count(*) into ct_completed
          from  fnd_concurrent_requests
        where phase_code = 'C' and (sysdate - actual_completion_date)*1440 <= 60;

        -- update the number of COMPLETED requests in the last 1 hour, use 0 for the metric_context
        update_metric_internal(p_metric_name, '0', ct_completed);
      end if;

      if(p_metric_name = 'REQ_WAITING_ON_LOCK') then
        select count(*) into ct_waiting_on_lock
          from  fnd_concurrent_requests r, GV$SESSION WS
        where r.phase_code = 'R'
          and r.oracle_session_id = WS.AUDSID
          and WS.LOCKWAIT IS NOT NULL;

         -- update the number of requests that are waiting on locks, use 0 for the metric_context
        update_metric_internal(p_metric_name, '0', ct_waiting_on_lock);
      end if;

      if(p_metric_name = 'REQ_INACTIVE') then
        select count(rv.Request_ID) into ct_inactive
         From Fnd_amp_requests_v rv,
          Fnd_lookups l
        Where  rv.phase_code = 'P'
        and l.meaning = rv.phase
        and l.lookup_code = 'I'
        and l.lookup_type = 'CP_PHASE_CODE';

 /* query from old request java code:
         select count(distinct(R.Request_ID)) into ct_inactive
         From Fnd_Concurrent_Programs_vl CP,
          Fnd_User U,
          Fnd_Concurrent_Requests R,
          Fnd_Responsibility_Tl RES,
          Fnd_Application A,
          Fnd_amp_requests_v rv,
          Fnd_lookups l
        Where  rv.phase_code = 'P'
        and l.meaning = rv.phase
        and l.lookup_code = 'I'
        and l.lookup_type = 'CP_PHASE_CODE'
        And CP.Application_ID = rv.Program_Application_ID
        And CP.Concurrent_Program_ID = rv.Concurrent_Program_ID
        and R.request_id = rv.request_id
        and rv.Program_Application_ID = R.Program_Application_ID
        And rv.Concurrent_Program_ID = R.Concurrent_Program_ID
        And A.Application_ID = rv.Program_Application_ID
        And U.User_ID = R.Requested_By
        And RES.application_id = R.responsibility_application_id
        AND RES.language(+)=USERENV('LANG')
        And RES.responsibility_id = R.responsibility_id;
*/
        -- update the number of inactive requests, use 0 for the metric_context
        update_metric_internal(p_metric_name, '0', ct_inactive);
      end if;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END update_req_status_metric;

  --
  -- Name
  --   refresh_completed_req_status
  --
  -- Purpose
  --   Computes the metric values for the completed request status for the last hour
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_completed_req_status
  IS
    cursor req_c is
    SELECT count(*) count, status_code
      FROM fnd_concurrent_requests
      WHERE status_code IN ('C', 'G', 'E', 'X' )
        AND ((sysdate - actual_completion_date) * (1440)) <= 60
      GROUP BY status_code;

    ct_error number := 0;
    ct_succ number := 0;
    ct_term number := 0;
    ct_warn number := 0;

  BEGIN

      for req in req_c loop
        --error
        if req.status_code = 'E' then
          ct_error := req.count;
        end if;

        if req.status_code = 'C' then
          ct_succ := req.count;
        end if;

        if req.status_code = 'X' then
          ct_term := req.count;
        end if;

        if req.status_code = 'G' then
          ct_warn := req.count;
        end if;
      end loop;

          -- update the number of completed requests with error, use 0 for the metric_context
          update_metric_internal('COMPLETED_REQ_ERROR', '0', ct_error);

          -- update the number of completed requests with success, use 0 for the metric_context
          update_metric_internal('COMPLETED_REQ_SUCCESSFUL', '0', ct_succ);

          -- update the number of completed requests with termination, use 0 for the metric_context
          update_metric_internal('COMPLETED_REQ_TERMINATED', '0', ct_term);

          -- update the number of completed requests with warning, use 0 for the metric_context
          update_metric_internal('COMPLETED_REQ_WARNING', '0', ct_warn);

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_completed_req_status;

  -- Name
  --   refresh_pending_req_status
  --
  -- Purpose
  --   Computes the metric values for the pending request status
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_pending_req_status
  IS
    cursor req_c is
        SELECT count(*) count, status_code
          FROM fnd_concurrent_requests
                     WHERE (status_code IN ('I', 'Q')
                     AND requested_start_date <= sysdate
                     AND phase_code = 'P'
                     AND hold_flag = 'N')
                     GROUP BY status_code;


    ct_normal number := 0;
    ct_standby number := 0;
    ct_scheduled number := 0;
  BEGIN

      for req in req_c loop
        --normal
        if req.status_code = 'I' then
          ct_normal := req.count;
        end if;

        if req.status_code = 'Q' then
          ct_standby := req.count;
        end if;
      end loop;

      SELECT count(*) into ct_scheduled
        FROM fnd_concurrent_requests
            WHERE (phase_code = 'P' AND hold_flag = 'N')
              AND ( (status_code = 'P' )
                    OR (status_code IN( 'I', 'Q')
                        AND requested_start_date > sysdate ));

          -- update the number of pending requests with status normal, use 0 for the metric_context
          update_metric_internal('PENDING_REQ_NORMAL', '0', ct_normal);

          -- update the number of pending requests with status standby, use 0 for the metric_context
          update_metric_internal('PENDING_REQ_STANDBY', '0', ct_standby);

          -- update the number of pending requests with status scheduled, use 0 for the metric_context
          update_metric_internal('PENDING_REQ_SCHEDULED', '0', ct_scheduled);

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_pending_req_status;

  -- Name
  --   refresh_running_req_duration
  --
  -- Purpose
  --   Computes the metric values for the running request duration
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_running_req_duration
  IS
    ct_10min number := 0;
    ct_60min number := 0;
    ct_long number := 0;
  BEGIN

      select count(*) into ct_10min
        from fnd_concurrent_requests
              where ((sysdate - actual_start_date) * (1440)) <= 10
                  and status_code in ('R');

      select count(*) into ct_60min
          from fnd_concurrent_requests
              where ((sysdate - actual_start_date) * (1440)) between 10 and 60
                and status_code in ('R');

      select count(*) into ct_long
          from fnd_concurrent_requests
              where ((sysdate - actual_start_date) * (1440)) >= 60
                 and status_code in ('R');

          -- update the number of running requests with duration less than 10 minutes, use 0 for the metric_context
          update_metric_internal('RUNNING_REQ_10MIN', '0', ct_10min);

          -- update the number of running requests with duration between 10-60 minutes, use 0 for the metric_context
          update_metric_internal('RUNNING_REQ_60MIN', '0', ct_60min);

          -- update the number of running requests with duration longer than 60 minutes, use 0 for the metric_context
          update_metric_internal('RUNNING_REQ_LONG', '0', ct_long);

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_running_req_duration;


  --
  -- Name
  --   refresh_running_req_user
  --
  -- Purpose
  --   Computes the metric values for the running request grouped by user
  --
  --

  PROCEDURE refresh_running_req_user
  IS
    cursor req_c is
    select count(*) count, user_name
              from fnd_concurrent_requests, fnd_user
              where requested_by = user_id and status_code = 'R'
              group by user_name;

  BEGIN

      --Delete entries for running request count for all users.
      delete_metric_internal('RUNNING_REQ_USER');
      for req in req_c loop
          -- Insert the number of running requests for each user, use user_name as the metric_context
          insert_metric_internal('RUNNING_REQ_USER', req.user_name, req.count);
      end loop;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_running_req_user;


  --
  -- Name
  --   refresh_pending_req_user
  --
  -- Purpose
  --   Computes the metric values for the pending request grouped by user
  --
  --

  PROCEDURE refresh_pending_req_user
  IS
    cursor req_c is
    select count(rv.Request_ID) count, user_name
         from Fnd_amp_requests_v rv,
            Fnd_lookups l
         Where  rv.phase_code = 'P'
         and l.meaning = rv.phase
         and l.lookup_code = 'P'
         and l.lookup_type = 'CP_PHASE_CODE'
         group by user_name;
  BEGIN

      --Delete entries for pending request count for all users.
      delete_metric_internal('PENDING_REQ_USER');
      for req in req_c loop
          -- Insert the number of pending requests for each user, use user_name as the metric_context
          insert_metric_internal('PENDING_REQ_USER', req.user_name, req.count);
      end loop;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_pending_req_user;

  --
  -- Name
  --   refresh_running_req_app
  --
  -- Purpose
  --   Computes the metric values for the running request grouped by application
  --
  --

  PROCEDURE refresh_running_req_app
  IS
    cursor req_c is
    select count(*) count, application_name
         from fnd_concurrent_requests r, fnd_application_vl v
         where  r.program_application_id = v.application_id and status_code = 'R'
              group by application_name;

  BEGIN

      --Delete entries for running request count for all applications.
      delete_metric_internal('RUNNING_REQ_APPLICATION');
      for req in req_c loop
          -- Insert the number of running requests for each APPLICATION, use application_name as the metric_context
          insert_metric_internal('RUNNING_REQ_APPLICATION', req.application_name, req.count);
      end loop;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_running_req_app;

  -- Name
  --   refresh_pending_req_app
  --
  -- Purpose
  --   Computes the metric values for the pending request grouped by application
  --
  --

  PROCEDURE refresh_pending_req_app
  IS
    cursor req_c is
    select count(rv.Request_ID) count, application_name
         from Fnd_amp_requests_v rv,
            Fnd_lookups l
         Where  rv.phase_code = 'P'
         and l.meaning = rv.phase
         and l.lookup_code = 'P'
         and l.lookup_type = 'CP_PHASE_CODE'
         group by application_name;

  BEGIN

      --Delete entries for pending request count for all applications.
      delete_metric_internal('PENDING_REQ_APPLICATION');
      for req in req_c loop
          -- Insert the number of pending requests for each APPLICATION, use application_name as the metric_context
          insert_metric_internal('PENDING_REQ_APPLICATION', req.application_name, req.count);
      end loop;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_pending_req_app;

  --
  -- Name
  --   refresh_running_req_resp
  --
  -- Purpose
  --   Computes the metric values for the running request grouped by responsibility
  --
  --

  PROCEDURE refresh_running_req_resp
  IS
    cursor req_c is
    select count(*) count, responsibility_name
             from fnd_concurrent_requests r, fnd_responsibility_vl v
                where r.responsibility_application_id = v.application_id
                 and r.responsibility_id = v.responsibility_id and  status_code = 'R'
                 group by responsibility_name;

  BEGIN

      --Delete entries for running request count for all responsibility.
      delete_metric_internal('RUNNING_REQ_RESP');
      for req in req_c loop
          -- Insert the number of running requests for each responsibility, use responsibility_name as the metric_context
          insert_metric_internal('RUNNING_REQ_RESP', req.responsibility_name, req.count);
      end loop;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_running_req_resp;
  --
  -- Name
  --   refresh_pending_req_resp
  --
  -- Purpose
  --   Computes the metric values for the pending request grouped by responsibility
  --
  --

  PROCEDURE refresh_pending_req_resp
  IS
    cursor req_c is
    select count(rv.Request_ID) count, responsibility_name
         from Fnd_amp_requests_v rv,
            Fnd_lookups l
         Where  rv.phase_code = 'P'
         and l.meaning = rv.phase
         and l.lookup_code = 'P'
         and l.lookup_type = 'CP_PHASE_CODE'
         group by responsibility_name;

  BEGIN

      --Delete entries for pending request count for all responsibility.
      delete_metric_internal('PENDING_REQ_RESP');
      for req in req_c loop
          -- Insert the number of pending requests for each responsibility, use responsibility_name as the metric_context
          insert_metric_internal('PENDING_REQ_RESP', req.responsibility_name, req.count);
      end loop;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_pending_req_resp;

  -- Name
  --   update_run_req_mgr_metric
  --
  -- Purpose
  --   compute the count of running requests for a specified manager
  --
  PROCEDURE update_run_req_mgr_metric(p_queue_application_id in number,
                                          p_concurrent_queue_name in varchar2,
                                          p_user_concurrent_queue_name in varchar2)
  IS
    ct_running number := 0;
  BEGIN
          select count(*) into ct_running
              from fnd_concurrent_worker_requests r
              where queue_application_id =  p_queue_application_id
                   and concurrent_queue_name = p_concurrent_queue_name
                   and status_code = 'R';

        update_metric_internal('RUNNING_REQ_MANAGER', p_user_concurrent_queue_name, ct_running);

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END update_run_req_mgr_metric;
  -- Name
  --   update_pend_req_mgr_metric
  --
  -- Purpose
  --   compute the count of pending requests for a specified manager
  --
  PROCEDURE update_pend_req_mgr_metric(p_queue_application_id in number,
                                          p_concurrent_queue_name in varchar2,
                                          p_user_concurrent_queue_name in varchar2)
  IS
    ct_pending number := 0;
  BEGIN
  --sql suggested by mike.
        select count(*) into ct_pending
                  from fnd_concurrent_worker_requests r
                   where queue_application_id = p_queue_application_id
                   and concurrent_queue_name = p_concurrent_queue_name
                   and status_code = 'I' and hold_flag <> 'Y'
                   and requested_start_date <= sysdate;

        update_metric_internal('PENDING_REQ_MANAGER', p_user_concurrent_queue_name, ct_pending);

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END update_pend_req_mgr_metric;

  -- Name
  --   update_process_mgr_metric
  --
  -- Purpose
  --   compute the count of process for a specified manager
  --
  PROCEDURE update_process_mgr_metric(p_queue_application_id in number,
                                          p_concurrent_queue_name in varchar2,
                                          p_user_concurrent_queue_name in varchar2)
  IS
    ct_process number :=0;
  BEGIN
          select running_processes into ct_process
              from fnd_concurrent_queues_vl
              where application_id =  p_queue_application_id
                   and concurrent_queue_name = p_concurrent_queue_name;

          update_metric_internal('RUNNING_PROCESS_MANAGER', p_user_concurrent_queue_name, ct_process);

    commit;
  EXCEPTION
    when no_data_found then
          -- the count for running process is 0
    update_metric_internal('RUNNING_PROCESS_MANAGER', p_user_concurrent_queue_name, 0);
    commit;

    when others then
      rollback;
      raise;

  END update_process_mgr_metric;


  -- Name
  --   refresh_run_req_process_mgr
  --
  -- Purpose
  --   refresh the count of running requests and processes for all managers
  --
  PROCEDURE refresh_run_req_process_mgr
  IS
    cursor mgr_c is
        select application_id, concurrent_queue_name, user_concurrent_queue_name
              from fnd_concurrent_queues_vl
              where manager_type = 1;
  BEGIN

      --Delete entries for running request count and running process count for all managers.
      delete_metric_internal('RUNNING_REQ_MANAGER');
      delete_metric_internal('RUNNING_PROCESS_MANAGER');
      for mgr in mgr_c loop
          -- update the number of running requests for each manager
          update_run_req_mgr_metric(mgr.application_id, mgr.concurrent_queue_name, mgr.user_concurrent_queue_name);
          -- update the number of running processes for each manager
          update_process_mgr_metric(mgr.application_id, mgr.concurrent_queue_name, mgr.user_concurrent_queue_name);
      end loop;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;

  END refresh_run_req_process_mgr;

  -- Name
  --   refresh_pend_req_mgr
  --
  -- Purpose
  --   refresh the count of pending requests for all managers
  --
  PROCEDURE refresh_pend_req_mgr
  IS
    cursor mgr_c is
        select application_id, concurrent_queue_name, user_concurrent_queue_name
              from fnd_concurrent_queues_vl
              where manager_type = 1;
  BEGIN

      --Delete entries for pending request count for all managers.
      delete_metric_internal('PENDING_REQ_MANAGER');
      for mgr in mgr_c loop
          -- update the number of pending requests for each manager
          update_pend_req_mgr_metric(mgr.application_id, mgr.concurrent_queue_name, mgr.user_concurrent_queue_name);
      end loop;

    commit;
  EXCEPTION
    when others then
      rollback;
      raise;

  END refresh_pend_req_mgr;

  -- Name
  --   refresh_req_stats_user
  --
  -- Purpose
  --   refresh the concurrent request statistics by user
  --
  PROCEDURE refresh_req_stats_user
  IS
    cursor s24h_c is
        SELECT r.requested_by user_id,
                count(r.actual_completion_date) count,
                sum(r.actual_completion_date-nvl(r.actual_start_date,r.requested_start_date))*24*3600 runtime  --in seconds
           FROM fnd_concurrent_requests r
          WHERE r.phase_code = 'C'
           and (sysdate - r.actual_completion_date) <= 1
          group by r.requested_by;

    cursor s7day_c is
        SELECT r.requested_by user_id,
                count(r.actual_completion_date) count,
                sum(r.actual_completion_date-nvl(r.actual_start_date,r.requested_start_date))*24*3600 runtime --in seconds
           FROM fnd_concurrent_requests r
          WHERE r.phase_code = 'C'
           and (sysdate - r.actual_completion_date) <= 7
          group by r.requested_by;

    cursor s31day_c is
        SELECT r.requested_by user_id,
                count(r.actual_completion_date) count,
                sum(r.actual_completion_date-nvl(r.actual_start_date,r.requested_start_date))*24*3600 runtime --in seconds
           FROM fnd_concurrent_requests r
          WHERE r.phase_code = 'C'
           and (sysdate - r.actual_completion_date) <= 31
          group by r.requested_by;

  BEGIN

      --Delete entries for statistics data for stats_interval=24hours.
      delete from fnd_oam_cpstats_user where stats_interval = 24; --24 hours
      for stat in s24h_c loop
         -- insert the data
         insert_stats_user(stat.user_id, 24, stat.count, stat.runtime);
      end loop;

      delete from fnd_oam_cpstats_user where stats_interval = 168; -- 7days = 168 hours
      for stat in s7day_c loop
         -- insert the data
         insert_stats_user(stat.user_id, 168, stat.count, stat.runtime);
      end loop;

      delete from fnd_oam_cpstats_user where stats_interval = 744;  --31 days = 744 hours
      for stat in s31day_c loop
         -- insert the data
         insert_stats_user(stat.user_id, 744, stat.count, stat.runtime);
      end loop;
    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_req_stats_user;

  -- Name
  --   refresh_req_stats_program
  --
  -- Purpose
  --   refresh the concurrent request statistics by program
  --
  PROCEDURE refresh_req_stats_program
  IS
    cursor s24h_c is
      SELECT r.program_application_id app_id, r.concurrent_program_id prog_id,
       round(sum(greatest(actual_completion_date-actual_start_date,0))*3600*24, 0) total, -- in seconds
       round(avg(greatest(actual_completion_date-actual_start_date,0))*3600*24, 0) ave,  -- in seconds
       round(min(greatest(actual_completion_date-actual_start_date,0))*3600*24, 0) minimum, -- in seconds
       round(max(greatest(actual_completion_date-actual_start_date,0))*3600*24, 0) maximum,  -- in seconds
       count(*) count
      FROM fnd_concurrent_requests r
      WHERE r.phase_code = 'C'
        and r.actual_completion_date is not null
        and r.actual_start_date is not null
        and (sysdate - r.actual_completion_date) <= 1
      GROUP BY r.program_application_id, r.concurrent_program_id;

    cursor s7day_c is
      SELECT r.program_application_id app_id, r.concurrent_program_id prog_id,
       round(sum(greatest(actual_completion_date-actual_start_date,0))*3600*24, 0) total,
       round(avg(greatest(actual_completion_date-actual_start_date,0))*3600*24, 0) ave,
       round(min(greatest(actual_completion_date-actual_start_date,0))*3600*24, 0) minimum,
       round(max(greatest(actual_completion_date-actual_start_date,0))*3600*24, 0) maximum,
       count(*) count
      FROM fnd_concurrent_requests r
      WHERE r.phase_code = 'C'
        and r.actual_completion_date is not null
        and r.actual_start_date is not null
        and (sysdate - r.actual_completion_date) <= 7
      GROUP BY r.program_application_id, r.concurrent_program_id;

    cursor s31day_c is
      SELECT r.program_application_id app_id, r.concurrent_program_id prog_id,
       round(sum(greatest(actual_completion_date-actual_start_date,0))*3600*24, 0) total,
       round(avg(greatest(actual_completion_date-actual_start_date,0))*3600*24, 0) ave,
       round(min(greatest(actual_completion_date-actual_start_date,0))*3600*24, 0) minimum,
       round(max(greatest(actual_completion_date-actual_start_date,0))*3600*24, 0) maximum,
       count(*) count
      FROM fnd_concurrent_requests r
      WHERE r.phase_code = 'C'
        and r.actual_completion_date is not null
        and r.actual_start_date is not null
        and (sysdate - r.actual_completion_date) <= 31
      GROUP BY r.program_application_id, r.concurrent_program_id;

  BEGIN

      --Delete entries for statistics data for stats_interval=24hours.
      delete from fnd_oam_cpstats_program where stats_interval = 24;
      for stat in s24h_c loop
         -- insert the data
         insert_stats_program(stat.app_id, stat.prog_id, 24,
                stat.total, stat.ave, stat.minimum, stat.maximum, stat.count);
      end loop;

      delete from fnd_oam_cpstats_program where stats_interval = 168; -- 7 days = 168 hours
      for stat in s7day_c loop
         -- insert the data
         insert_stats_program(stat.app_id, stat.prog_id, 168,
                stat.total, stat.ave, stat.minimum, stat.maximum, stat.count);
      end loop;

      delete from fnd_oam_cpstats_program where stats_interval = 744; -- 31 days = 744 hours
      for stat in s31day_c loop
         -- insert the data
         insert_stats_program(stat.app_id, stat.prog_id, 744,
                stat.total, stat.ave, stat.minimum, stat.maximum, stat.count);
      end loop;
    commit;
  EXCEPTION
    when others then
      rollback;
      raise;
  END refresh_req_stats_program;


  -- Name
  --   insert_stats_user
  -- Purpose
  --   This procedure is for internal use only!
  --   This procedure will insert a row in fnd_oam_stats_user
  --
  -- Input Arguments
  --
  --
  PROCEDURE insert_stats_user (
      p_user_id in number,
      p_stats_interval in varchar2,
      p_comp_req_count in number,
      p_total_runtime in number)
  IS
        v_userid number;
  BEGIN
      v_userid := get_user_id;

-- insert the data
         insert into fnd_oam_cpstats_user (user_id, stats_interval,
          comp_req_count, total_runtime,
          last_updated_by, last_update_date,
          last_update_login, created_by, creation_date)
         values (p_user_id, p_stats_interval, p_comp_req_count,
              p_total_runtime,
              v_userid, sysdate, v_userid, 0, sysdate);

  END insert_stats_user;
  -- Name
  --   insert_stats_program
  -- Purpose
  --   This procedure is for internal use only!
  --   This procedure will insert a row in fnd_oam_stats_user
  --
  -- Input Arguments
  --
  --
  PROCEDURE insert_stats_program (
      p_app_id in number,
      p_program_id in number,
      p_stats_interval in varchar2,
      p_total_runtime in number,
      p_ave_tuntime in number,
      p_min_tuntime in number,
      p_max_tuntime in number,
      p_times_run in number)
  IS
        v_userid number;
  BEGIN
      v_userid := get_user_id;

-- insert the data
         insert into fnd_oam_cpstats_program (application_id, program_id, stats_interval,
          total_runtime, ave_runtime, min_runtime, max_runtime, times_run,
          last_updated_by, last_update_date,
          last_update_login, created_by, creation_date)
         values (p_app_id, p_program_id, p_stats_interval, p_total_runtime,
         p_ave_tuntime, p_min_tuntime, p_max_tuntime,
              p_times_run,
              v_userid, sysdate, v_userid, 0, sysdate);

  END insert_stats_program;

  --
  -- Name
  --   submit_req_conditional
  --
  -- Purpose
  --   Submits a request for program 'OAMCHARTCOL' if and only if there are no
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

  PROCEDURE submit_req_conditional
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
        program=>'OAMCHARTCOL',
        phase=>p_phase,
        status=>p_status,
        dev_phase=>p_dev_phase,
        dev_status=>p_dev_status,
        message=>p_message);

    if p_dev_phase is null then
        p_dev_phase := 'X';
    end if;
    if  ((outcome = false and p_request_id is null) or
        (outcome = true and p_request_id is not null and
                p_dev_phase <> 'PENDING' and
                p_dev_phase <> 'RUNNING')) and
       fnd_program.program_exists('OAMCHARTCOL', 'FND') = true then

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

      -- Submit the request.
      retcode := fnd_request.submit_request(application=>'FND', program=>'OAMCHARTCOL');

    end if;
    commit;
  EXCEPTION
    when others then
      rollback;
      null;
  END submit_req_conditional;


  END fnd_oam_cpcharts_col;

/
