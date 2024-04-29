--------------------------------------------------------
--  DDL for Package Body CN_PERIODS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PERIODS_API" AS
-- $Header: cnsyprb.pls 120.9.12000000.2 2007/08/06 22:10:29 jxsingh ship $


--Package Body Name
--  cn_periods_api
--Purpose
--  API to access information related to cn_periods.
--
--History:
--  02-27-95  V Young	    Created by converting some procedure from
--			    cn_general_utils package, and added some other
--			    procedures to support new API.
--  07-26-95  A Erickson    cn_periods.period_name  colum name update.
--  07-24-95  A Erickson    check_cn_period_record. set repository_status = F.
--  08-08-95  A Erickson    init srp periods when new cn period created.
--  11-28-95  A Erickson    Support WHO columns in GL_PERIOD_STATUSES update.
--  01-26-96  A Erickson    Added Set_Dates routine for Collection code.
--  03-13-96  A Erickson    Remove reference to system start date.
-- 26-MAR-03  (gasriniv)   updated to fix bug#2804029
--  02-02-07  jxsingh       Bug#5707688 + Open Period Log Messages Added.

  payee_pop_failed  EXCEPTION;
  srp_pop_failed    EXCEPTION;
  abort 	    EXCEPTION;
  conc_fail	    EXCEPTION;

  TYPE requests IS TABLE of NUMBER(15) INDEX BY BINARY_INTEGER;

  --

/* ----------------------------------------------------------------------- */
  --
  -- Procedure Name
  --   Update_GL_Status
  -- Purpose
  -- Update status in GL_PERIOD_STATUSES
  --

 PROCEDURE update_gl_status ( x_org_id             NUMBER,
			      x_period_name	    VARCHAR2,
			      x_closing_status     VARCHAR2,
			      x_forecast_flag      VARCHAR2,
			      x_application_id     NUMBER,
			      x_set_of_books_id    NUMBER,
			      x_freeze_flag        VARCHAR2,
			      x_last_update_date   DATE,
			      x_last_update_login  NUMBER,
			      x_last_updated_by    NUMBER)
    IS
       CURSOR c IS
       SELECT gl.closing_status, gl.start_date, gl.end_date,
	      gl.quarter_num, gl.period_year
	 FROM GL_PERIOD_STATUSES GL
	WHERE gl.application_id = x_application_id
	  AND gl.adjustment_period_flag = 'N'
	  and gl.set_of_books_id = x_set_of_books_id
	  and gl.period_name = x_period_name;

       l_closing_status VARCHAR2(1);
       l_start_date DATE;
       l_end_date DATE;
       l_period_quota_id NUMBER(15);
       l_quarter_num NUMBER(15);
       l_period_year NUMBER(15);

     -- Added as part of bug fix bug#2804029
      CURSOR cn_period_info(p_period_name cn_period_statuses.period_name%TYPE,
                            p_period_year cn_period_statuses.period_year%TYPE) IS
      SELECT cn.period_status
      FROM   cn_period_statuses cn
      WHERE  cn.period_name = p_period_name
      AND    cn.period_year = p_period_year
      AND    cn.org_id      = x_org_id;

       -- for API calls
       l_return_status        varchar2(1);
       l_msg_count            number;
       l_msg_data             VARCHAR2(2000);
       l_loading_status       varchar2(30);

  BEGIN

     OPEN c;
     FETCH c INTO
       l_closing_status,
       l_start_date,
       l_end_date,
       l_quarter_num,
       l_period_year;
     CLOSE c;

      -- Added as part of bug fix bug#2804029
      OPEN cn_period_info(x_period_name,l_period_year);
      FETCH cn_period_info INTO l_closing_status;
      IF cn_period_info%NOTFOUND THEN
	 l_closing_status := 'N';
      END IF;
      CLOSE cn_period_info;
      -- End add as part of bug fix bug#2804029


    UPDATE  gl_period_statuses
       SET  closing_status    = x_closing_status,
	    last_update_date  = x_last_update_date,
	    last_update_login = x_last_update_login,
	    last_updated_by   = x_last_updated_by
     WHERE  period_name       = x_period_name
       AND  application_id    = x_application_id
       AND  set_of_books_id   = x_set_of_books_id ;

    -- 1979768
    IF (x_closing_status = 'O' OR x_closing_status = 'F')  THEN
       UPDATE  cn_period_statuses
	 SET  period_status     = x_closing_status,
	      forecast_flag     = x_forecast_flag,
	      freeze_flag       = x_freeze_flag,
	      last_update_date  = x_last_update_date,
	      last_update_login = x_last_update_login,
              last_updated_by   = x_last_updated_by,
	      object_version_number  = object_version_number + 1,
	      processing_status_code = 'PROCESSING'
       WHERE  period_name       = x_period_name
         AND  org_id            = x_org_id;
     ELSE
       UPDATE  cn_period_statuses
	 SET  period_status     = x_closing_status,
	      forecast_flag     = x_forecast_flag,
	      freeze_flag       = x_freeze_flag,
	      last_update_date  = x_last_update_date,
	      last_update_login = x_last_update_login,
              last_updated_by   = x_last_updated_by,
              object_version_number = object_version_number + 1
       WHERE  period_name       = x_period_name
	 AND  org_id            = x_org_id ;
     END IF;

     -- bug 1979768 : populate_srp_tables moved to concurrent program

  END update_gl_status ;

  -- Add concurrency to the open periods process
PROCEDURE update_error (x_physical_batch_id NUMBER) IS
   l_user_id            NUMBER(15) := fnd_global.user_id;
   l_resp_id            NUMBER(15) := fnd_global.resp_id;
   l_login_id           NUMBER(15) := fnd_global.login_id;
   l_conc_prog_id       NUMBER(15) := fnd_global.conc_program_id;
   l_conc_request_id    NUMBER(15) := fnd_global.conc_request_id;
   l_prog_appl_id       NUMBER(15) := fnd_global.prog_appl_id;
BEGIN
   -- Giving the batch an 'ERROR' status prevents subsequent
   -- physical processes picking it up.
   UPDATE cn_process_batches
     SET status_code          = 'ERROR'
     ,last_update_date       = sysdate
     ,last_update_login      = l_login_id
     ,last_updated_by        = l_user_id
     ,request_id             = l_conc_request_id
     ,program_application_id = l_prog_appl_id
     ,program_id             = l_conc_prog_id
     ,program_update_date    = sysdate
     WHERE physical_batch_id      = x_physical_batch_id;
END update_error;

-- this is called from within a single-org context
procedure conc_dispatch
  (p_parent_proc_audit_id     NUMBER,
   p_logical_batch_id         NUMBER,
   p_org_id                   NUMBER)
is
  l_primary_request_stack   REQUESTS;
  l_primary_batch_stack     REQUESTS;
  g_batch_total             NUMBER       := 0;
  l_temp_id                 NUMBER       := 0;
  l_new_status              VARCHAR2(30) := NULL;
  l_curr_status             VARCHAR2(30) := NULL;
  l_temp_phys_batch_id      NUMBER;
  primary_ptr               NUMBER := 1;
  l_dev_phase               VARCHAR2(80);
  l_dev_status              VARCHAR2(80);
  l_request_id              NUMBER      ;

  l_completed_batch_count   NUMBER :=0  ;
  l_call_status             BOOLEAN     ;

  l_dummy1                  VARCHAR2(500);
  l_dummy2                  varchar2(500);
  l_dummy3                  varchar2(500);
  unfinished                BOOLEAN := TRUE;

  l_sleep_time  number := 30;
  l_sleep_time_char VARCHAR2(30);
  l_failed_request_id  NUMBER;

  CURSOR physical_batches IS
     SELECT DISTINCT physical_batch_id
       FROM cn_process_batches
       WHERE logical_batch_id = p_logical_batch_id;
BEGIN
  cn_message_pkg.flush;

  l_sleep_time_char := fnd_profile.value('CN_SLEEP_TIME');
  IF l_sleep_time_char IS NOT NULL THEN
    l_sleep_time := to_number(l_sleep_time_char);
  END IF;

  WHILE unfinished LOOP
    l_primary_request_stack.delete;
    l_primary_batch_stack.delete;
    primary_ptr                 := 1;
    l_completed_batch_count     := 0;
    g_batch_total               := 0;
  ---------------------------------------------------------------------
  fnd_file.put_line(fnd_file.Log, 'Step  5 : Parallel Process Starts');
  ---------------------------------------------------------------------
    FOR physical_rec IN physical_batches LOOP
       fnd_request.set_org_id(p_org_id);
       l_temp_id := fnd_request.submit_request
	 (application         => 'CN',
	  program             => 'POPULATE_NEW_PERIODS',
	  description         => NULL,
	  start_time          => NULL,
	  sub_request         => NULL,
	  argument1           => physical_rec.physical_batch_id,
	  argument2           => p_parent_proc_audit_id
	  );

       cn_message_pkg.debug('Submitted Request: ' || l_temp_id);
       commit;

       g_batch_total := g_batch_total+1;
       l_primary_request_stack(g_batch_total) := l_temp_id;
       l_primary_batch_stack(g_batch_total) := physical_rec.physical_batch_id;

      -- If submission failed update the batch record and fail
      IF l_temp_id = 0 THEN
	 l_temp_phys_batch_id := physical_rec.physical_batch_id;
	 l_failed_request_id := l_temp_id;
	 raise conc_fail;
      END IF;
    END LOOP;

    IF (g_batch_total = 0) THEN
       RAISE no_data_found;
    END IF;

    cn_message_pkg.debug('Number of batches submitted: ' || g_batch_total);
    ------------------------------------------------------------------------------------------
    fnd_file.put_line(fnd_file.Log, 'Step  6 : Total Batches Submitted => ' || g_batch_total);
    ------------------------------------------------------------------------------------------
    dbms_lock.sleep(l_sleep_time);

    WHILE l_completed_batch_count <= g_batch_total LOOP
       IF l_primary_request_stack(primary_ptr) IS NOT NULL THEN
	  l_call_status := fnd_concurrent.get_request_status
	    (  request_id     => l_primary_request_stack(primary_ptr),
	       phase          => l_dummy1,
	       status         => l_dummy2,
	       dev_phase      => l_dev_phase,
	       dev_status     => l_dev_status,
	       message        => l_dummy3);
	  IF (NOT l_call_status)  THEN
	     l_failed_request_id := l_primary_request_stack(primary_ptr);
	     l_temp_phys_batch_id := l_primary_batch_stack(primary_ptr);
	     raise conc_fail;
	  END IF;

	  IF l_dev_phase = 'COMPLETE' THEN
	     l_failed_request_id := l_primary_request_stack(primary_ptr);
	     l_temp_phys_batch_id := l_primary_batch_stack(primary_ptr);

	     l_primary_batch_stack(primary_ptr)   := null;
	     l_primary_request_stack(primary_ptr) := null;
	     l_completed_batch_count := l_completed_batch_count +1;

	     IF l_dev_status = 'ERROR' THEN
		raise conc_fail;
	     END IF;
	  END IF;
       END IF;

       primary_ptr := primary_ptr+1;

       IF l_completed_batch_count = g_batch_total THEN
	  l_completed_batch_count := l_completed_batch_count+1;

	  unfinished := FALSE;
	ELSE
	  IF primary_ptr > g_batch_total THEN
	     dbms_lock.sleep(l_sleep_time);
	     primary_ptr := 1;
	  END IF;
       END IF;
    END LOOP;
  END LOOP;
EXCEPTION
   WHEN no_data_found THEN
      cn_message_pkg.debug('Conc_dispatch: no physical batches to process');
      ---------------------------------------------------------------------------
      fnd_file.put_line(fnd_file.Log, 'Step  7 : No Physical Batches to process');
      ---------------------------------------------------------------------------
   WHEN conc_fail THEN
      update_error(l_temp_phys_batch_id);
      cn_message_pkg.debug('Concurrent program fails: ' || l_temp_phys_batch_id);
      --------------------------------------------------------------------------------------------------------------------
      fnd_file.put_line(fnd_file.Log, 'Step  7 : Concurrent Program (Physical Batch) Failed => ' || l_temp_phys_batch_id);
      --------------------------------------------------------------------------------------------------------------------
   WHEN others THEN
      cn_message_pkg.debug(sqlerrm);
      cn_message_pkg.rollback_errormsg_commit('Exception in conc_dispatch');
      ---------------------------------------------------------------------------------
      fnd_file.put_line(fnd_file.Log, 'Step  7 : Some Other Exception in Conc Dispatch');
      ---------------------------------------------------------------------------------
      RAISE;
END conc_dispatch;

-- this routine will be called from within a single-org context
PROCEDURE populate_srp_tables(errbuf OUT NOCOPY VARCHAR2,
			      retcode OUT NOCOPY NUMBER)
IS
   l_logical_batch_id NUMBER(15);
   l_start_period_id  number(15);
   l_end_period_id    number(15);
   l_start_date       date;
   l_end_date         date;
   l_proc_audit_id          number;
   l_reps_total             number;
   l_temp                   number;
   l_physical_batch_id      number;
   l_period_quota_id        number;
   l_org_id                 NUMBER;

   CURSOR pending_periods IS
        SELECT
          period_id,
          start_date,
          end_date,
          quarter_num,
          period_year,
          period_status
        FROM cn_period_statuses
   WHERE processing_status_code = 'PROCESSING'
     AND period_id between l_start_period_id and l_end_period_id
     AND request_id is null
       ORDER BY period_id;

  CURSOR affected_quotas IS
        SELECT quota_id
          FROM cn_quotas
         WHERE (end_date IS NULL OR end_date >= l_start_date)
           AND start_date <= l_end_date;

BEGIN
  retcode := 0; -- success = 0, warning = 1, fail = 2

  -- get current working org ID
  l_org_id := mo_global.get_current_org_id;
  IF l_org_id IS NULL THEN
     -- org ID is not set... raise error
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  cn_message_pkg.begin_batch(x_process_type => 'OPEN_PERIODS',
                             x_process_audit_id => l_proc_audit_id,
                             x_parent_proc_audit_id => l_proc_audit_id,
                             x_request_id => fnd_global.conc_request_id,
			     p_org_id => l_org_id);

  cn_message_pkg.debug('Beginning of open periods process.');
  ---------------------------------------------------------------
  fnd_file.put_line(fnd_file.Log, 'Open Period Process - Start');
  ---------------------------------------------------------------
  --initialize message list
  fnd_msg_pub.initialize;

  -- insert people into cn_process_batches
  select cn_process_batches_s2.nextval into l_logical_batch_id from dual;

  -- determine the periods to process
  select min(period_id), max(period_id), min(start_date), max(end_date)
    into l_start_period_id, l_end_period_id, l_start_date, l_end_date
    from cn_period_statuses
   where processing_status_code = 'PROCESSING';

  ----------------------------------------------------------------------------------
  fnd_file.put_line(fnd_file.Log, 'Step  1 : Period Information');
  fnd_file.put_line(fnd_file.Log, '        : Min Period Id => '||l_start_period_id);
  fnd_file.put_line(fnd_file.Log, '        : Max Period Id => '||l_end_period_id);
  ----------------------------------------------------------------------------------

  insert into cn_process_batches
     (process_batch_id,
      logical_batch_id,
      srp_period_id,
      period_id,
      end_period_id,
      start_date,
      end_date,
      salesrep_id,
      sales_lines_total,
      status_code,
      process_batch_type,
      creation_date,
      created_by,
      org_id)
   select cn_process_batches_s1.nextval,
          l_logical_batch_id,
          1,
          cps.period_id,
          cps.period_id,
          cps.start_date,
          cps.end_date,
          v.salesrep_id,
          0,
          'IN_USE',
          'OPENING_PERIODS',
          sysdate,
          fnd_global.user_id,
          l_org_id
     from (select distinct s.salesrep_id
             from jtf_rs_role_relations rr,
                  cn_rs_salesreps s,
                  jtf_rs_roles_b r
            where rr.role_resource_id = s.resource_id
	      and rr.role_resource_type = 'RS_INDIVIDUAL'
	      and rr.delete_flag = 'N'
              and rr.role_id = r.role_id
              and r.role_type_code = 'SALES_COMP'
              and (rr.end_date_active IS NULL OR rr.end_date_active >= l_start_date)
              and rr.start_date_active <= l_end_date) v,
           cn_period_statuses cps
         where cps.processing_status_code = 'PROCESSING'
       and cps.period_id between l_start_period_id and l_end_period_id
       and not exists
                  (select 1
                     from cn_process_batches
                    where logical_batch_id = (select logical_batch_id
                                               from cn_period_statuses
                                              where period_id = cps.period_id)
                      and salesrep_id = v.salesrep_id
                      and period_id = cps.period_id
		      and sales_lines_total = 1);

  l_reps_total := SQL%rowcount;

  l_temp := cn_global_var.get_salesrep_batch_size(l_org_id);

  ----------------------------------------------------------------------------
  fnd_file.put_line(fnd_file.Log, 'Step  2 : Salesrep Batch Size => '||l_temp);
  fnd_file.put_line(fnd_file.Log, '        : Logical Batch Id    => '||l_logical_batch_id);
  ----------------------------------------------------------------------------

  loop
    select cn_process_batches_s3.nextval into l_physical_batch_id from dual;
  ----------------------------------------------------------------------------
  fnd_file.put_line(fnd_file.Log, '        : Physical Batch Id   => '||l_physical_batch_id);
  ----------------------------------------------------------------------------
    update cn_process_batches
       set physical_batch_id = l_physical_batch_id
     where logical_batch_id = l_logical_batch_id
       and physical_batch_id is null
       and rownum <= l_temp;

    if (SQL%notfound) then
       exit;
    end if;
  end loop;

 update cn_process_batches pb
    set pb.physical_batch_id = (select min(physical_batch_id)
                                  from cn_process_batches
                                 where logical_batch_id = pb.logical_batch_id
                                   and salesrep_id = pb.salesrep_id)
  where pb.logical_batch_id = l_logical_batch_id;

  -- process affected quotas
  FOR pending_period IN pending_periods LOOP
     FOR affected_quota IN affected_quotas LOOP
	-- populate cn_period_quotas on as needed basis
	-- keep this API call since not at the salesrep level, plus some
	-- complicated logic
          cn_period_quotas_pkg.begin_record
            (x_operation         => 'INSERT',
             x_period_quota_id   => l_period_quota_id,
             x_period_id         => pending_period.period_id,
             x_quota_id          => affected_quota.quota_id,
             x_period_target     => 0,
             x_itd_target        => null, -- will be populated in table handler
             x_period_payment    => 0,
             x_itd_payment       => null, -- will be populated in table handler
             x_quarter_num       => pending_period.quarter_num,
             x_period_year       => pending_period.period_year,
             x_creation_date     => sysdate,
             x_last_update_date  => sysdate,
             x_last_update_login => fnd_global.login_id,
             x_last_updated_by   => fnd_global.user_id,
             x_created_by        => fnd_global.user_id,
             x_period_type_code  => null, -- not used
	     x_performance_goal  => 0
             );
    END LOOP;
  END LOOP;

  -- if affected quotas are updated successfully, then mark the periods with logical_batch_id
  UPDATE cn_period_statuses
     SET request_id = l_logical_batch_id
   WHERE processing_status_code = 'PROCESSING'
     AND period_id between l_start_period_id AND l_end_period_id;

  -----------------------------------------------------------------------------
  fnd_file.put_line(fnd_file.Log, 'Step  3 : Quotas are updated successfully');
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  fnd_file.put_line(fnd_file.Log, 'Step  4 : Processing Status => PROCESSING ');
  -----------------------------------------------------------------------------

  commit;

  conc_dispatch(p_parent_proc_audit_id  => l_proc_audit_id,
                p_logical_batch_id      => l_logical_batch_id,
		p_org_id                => l_org_id);

  BEGIN
    SELECT 1 INTO l_temp FROM dual
      WHERE NOT exists (SELECT 1
			FROM cn_process_batches
                        WHERE logical_batch_id = l_logical_batch_id AND status_code = 'ERROR');
  EXCEPTION
    WHEN no_data_found THEN
          cn_message_pkg.debug('There is some physical batch that failed.');
          RAISE;
  END;

  ----------------------------------------------------------------------------------------
  fnd_file.put_line(fnd_file.Log, '        : No Exceptions found in Step 7');
  fnd_file.put_line(fnd_file.Log, 'Step  8 : All Physical Batches completed successfully');
  ----------------------------------------------------------------------------------------

  -------------------------------------------------------------------
  fnd_file.put_line(fnd_file.Log, 'Step  9 : Parallel Process Ends');
  -------------------------------------------------------------------

  UPDATE cn_period_statuses
     SET processing_status_code = 'CLEAN'
   WHERE processing_status_code = 'PROCESSING'
     AND period_id between l_start_period_id AND l_end_period_id;

  ------------------------------------------------------------------------
  fnd_file.put_line(fnd_file.Log, 'Step 10 : Processing Status => CLEAN ');
  ------------------------------------------------------------------------

  cn_message_pkg.debug('End of open periods process.');
  COMMIT;

  -------------------------------------------------------------
  fnd_file.put_line(fnd_file.Log, 'Open Period Process - End');
  -------------------------------------------------------------

  cn_message_pkg.end_batch(l_proc_audit_id);
EXCEPTION
  WHEN OTHERS THEN
    rollback;
    retcode := 2;
    errbuf := SQLCODE||' '||Sqlerrm;

    -- set status to ERROR
    UPDATE cn_period_statuses
       SET processing_status_code = 'FAILED'
     WHERE processing_status_code = 'PROCESSING';

    IF l_org_id IS NOT NULL THEN
       cn_message_pkg.end_batch(l_proc_audit_id);
    END IF;

    -- commit status change
    COMMIT;
END populate_srp_tables;

/* ----------------------------------------------------------------------- */
  --
  -- Procedure Name
  --   Populate_srp_table_runner
  -- Purpose
  --   Concurrent program runner to populate srp tables once
  --   a period is being opened.
  -- History
  --   18-SEP-2001 hlchen created
  --   16-feb-2005 mblum modified

-- this routine will be called from within a single-org context
PROCEDURE populate_srp_tables_runner(errbuf OUT nocopy VARCHAR2,
				     retcode OUT nocopy NUMBER,
				     p_physical_batch_id NUMBER,
				     p_parent_proc_audit_id NUMBER) IS

     l_period_id NUMBER(15);
     l_start_date DATE;
     l_end_date   DATE;
     l_period_status VARCHAR2(30);
     l_org_id        NUMBER;

     -- bug 4135215 for telecom italia
     CURSOR affected_srps IS
	SELECT salesrep_id, period_id, org_id
	  FROM cn_process_batches
	 WHERE physical_batch_id = p_physical_batch_id
	   AND sales_lines_total = 0
         ORDER BY period_id;

     CURSOR srp_plan_info(l_salesrep_id IN NUMBER, l_start_date IN DATE, l_end_date IN DATE) IS
	SELECT srp_plan_assign_id, role_id, comp_plan_id,
	       start_date, end_date, salesrep_id
	  FROM cn_srp_plan_assigns
	 WHERE salesrep_id = l_salesrep_id
	   AND role_id IS NOT null
	   AND start_date <= l_start_date AND end_date >= l_end_date;

     CURSOR get_credit_types(l_comp_plan_id IN NUMBER) IS
	select distinct q.credit_type_id
	  from cn_quota_assigns qa, cn_quotas q
	 where qa.comp_plan_id = l_comp_plan_id
	   and qa.quota_id = q.quota_id;

     CURSOR get_pd_info(l_period_id IN NUMBER) IS
	SELECT start_date, end_date, period_status
	  FROM cn_period_statuses
	 WHERE period_id = l_period_id;

     CURSOR srp_payee_info(l_salesrep_id in number) IS
     SELECT spay.quota_id, spay.start_date, spay.end_date, spa.comp_plan_id
       from cn_srp_payee_assigns spay, cn_srp_plan_assigns spa,
            cn_srp_quota_assigns sqa
      where spay.payee_id = l_salesrep_id
        and (spay.end_date IS NULL OR spay.end_date >= l_start_date)
        AND spay.start_date <= l_end_date
        and spay.srp_quota_assign_id = sqa.srp_quota_assign_id
        and sqa.srp_plan_assign_id = spa.srp_plan_assign_id;

     -- for API calls
     l_return_status        varchar2(1);
     l_msg_count            number;
     l_msg_data             VARCHAR2(2000);
     l_loading_status       varchar2(30);

     l_proc_audit_id        NUMBER := NULL;
     dummy_num              NUMBER ;

     l_err_srp_id number:=0;
     l_err_quota_id number:=0;
     l_orig_pd_id  NUMBER := -1;
     l_user_id     NUMBER := fnd_global.user_id;
     l_login_id    NUMBER := fnd_global.login_id;
     l_curr_srp_id NUMBER;
     l_curr_pd_id  NUMBER;
     l_count       NUMBER;

BEGIN
   --SAVEPOINT populate_srp_tables_runner; -- obsolete now since we commit for each rep
   retcode := 0; -- success = 0, warning = 1, fail = 2

   -- get current working org ID
   l_org_id := mo_global.get_current_org_id;
   IF l_org_id IS NULL THEN
      -- org ID is not set... raise error
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   cn_message_pkg.begin_batch
     (
      x_parent_proc_audit_id   => p_parent_proc_audit_id
      ,x_process_audit_id      => l_proc_audit_id
      ,x_request_id            => fnd_global.conc_request_id
      ,x_process_type          => 'OPEN_PERIODS_RUNNER'
      ,p_org_id                => l_org_id);

   cn_message_pkg.debug('Populate SRP tables runner');

   FOR srp IN affected_srps LOOP
      IF srp.period_id <> l_orig_pd_id THEN
	 l_orig_pd_id := srp.period_id;
	 OPEN  get_pd_info(srp.period_id);
	 FETCH get_pd_info INTO l_start_date, l_end_date, l_period_status;
	 CLOSE get_pd_info;
      END IF;

      l_curr_srp_id := srp.salesrep_id;
      l_curr_pd_id  := srp.period_id;

      IF l_period_status IN ('O', 'F') THEN
	 -- Populate cn_srp_intel_periods
	 l_err_srp_id := srp.salesrep_id;

	 SELECT COUNT(1) INTO l_count
	   FROM cn_srp_intel_periods
	   WHERE period_id = srp.period_id
	   AND salesrep_id = srp.salesrep_id
	   AND org_id      = srp.org_id;

	   IF l_count = 0 THEN
	      INSERT INTO cn_srp_intel_periods
		(srp_intel_period_id,
		 salesrep_id,
		 org_id,
		 period_id,
		 processing_status_code,
		 process_all_flag,
		 creation_date,
		 created_by,
		 last_update_date,
		 last_updated_by,
		 last_update_login,
		 start_date,
		 end_date
		 ) VALUES
		(cn_srp_intel_periods_s.NEXTVAL,
		 srp.salesrep_id,
		 l_org_id,
		 srp.period_id,
		 'CLEAN',
		 'Y',
		 Sysdate,
		 l_user_id,
		 Sysdate,
		 l_user_id,
		 l_login_id,
		 l_start_date,
		 l_end_date);
	   END IF; -- if rec not exist
	END IF;  -- if status = O

	-- check to see if current rep is a payee
	SELECT COUNT(1) INTO l_count
	  FROM cn_srp_roles
	 WHERE salesrep_id = srp.salesrep_id
	   AND role_id = 54
	   AND org_id = srp.org_id;

	IF l_count > 0 THEN
	   -- rep is a payee
	   for p in srp_payee_info(srp.salesrep_id) LOOP
	      -- populate cn_srp_periods
	      CN_SRP_PERIODS_PVT.Create_Srp_Periods_per_Quota
		(p_api_version          => 1.0,
		 x_return_status        => l_return_status,
		 x_msg_count            => l_msg_count,
		 x_msg_data             => l_msg_data,
		 p_role_id              => 54,
		 p_quota_id             => p.quota_id,
		 p_comp_plan_id         => p.comp_plan_id,
		 p_salesrep_id          => srp.salesrep_id,
		 p_start_date           => p.start_date,
		 p_end_date             => p.end_date,
		 x_loading_status       => l_loading_status);

	      IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
		 RAISE   payee_pop_failed;
	      END IF;
	   end loop;
	END IF;

	for c in srp_plan_info(srp.salesrep_id, l_start_date, l_end_date) LOOP
	   -- populate cn_srp_periods
	   -- complicated logic so keep API call
	   CN_SRP_PERIODS_PVT.Create_Srp_Periods_Per_Quota
	     (p_api_version          => 1.0,
	      x_return_status        => l_return_status,
	      x_msg_count            => l_msg_count,
	      x_msg_data             => l_msg_data,
	      p_role_id              => c.role_id,
	      p_comp_plan_id         => c.comp_plan_id,
	      p_salesrep_id          => srp.salesrep_id,
	      p_start_date           => c.start_date,
	      p_end_date             => c.end_date,
	      p_quota_id             => NULL, -- do all quotas
	      p_sync_flag            => FND_API.G_FALSE, -- don't sync right here
	      x_loading_status       => l_loading_status);

	   fnd_file.put_line(fnd_file.Log, l_loading_status);
	   fnd_file.put_line(fnd_file.Log, l_msg_data);
	   fnd_file.put_line(fnd_file.Log, 'role ' || c.role_id);
	   fnd_file.put_line(fnd_file.Log, 'plan ' || c.comp_plan_id);
	   fnd_file.put_line(fnd_file.Log, 'dates ' || c.start_date || ', ' || c.end_date);


	   IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
	      RAISE   srp_pop_failed;
	   END IF;

	   -- sync accum bals for last period
	   -- complicated logic so keep API call
	   FOR ct IN get_credit_types(c.comp_plan_id) loop
	      cn_srp_periods_pvt.Sync_Accum_Balances_Start_Pd
		(p_salesrep_id          => c.salesrep_id,
		 p_org_id               => l_org_id,
		 p_credit_type_id       => ct.credit_type_id,
		 p_role_id              => c.role_id,
		 p_start_period_id      => srp.period_id);
	   END LOOP;

	   -- populate cn_srp_period_quotas
	   -- complicated logic so keep API call
	   cn_srp_period_quotas_pkg.insert_record
	     (
	      x_srp_plan_assign_id  => c.srp_plan_assign_id
	      ,x_quota_id	    => NULL
	      ,x_start_period_id    => srp.period_id
	      ,x_end_period_id      => srp.period_id
	      ,x_start_date         => l_start_date
	      ,x_end_date           => l_end_date );

	   -- populate cn_srp_per_quota_rc_pkg
/*	   cn_srp_per_quota_rc_pkg.insert_record
	     (
	      x_srp_plan_assign_id   => c.srp_plan_assign_id
	      ,x_quota_id	     => null
	      ,x_revenue_class_id    => null
	      ,x_start_date          => l_start_date
	      ,x_end_date            => l_end_date );*/
	   -- denormalizing API call
	   INSERT INTO cn_srp_per_quota_rc
	       ( srp_per_quota_rc_id
		 ,srp_period_quota_id
		 ,srp_plan_assign_id
		 ,salesrep_id
		 ,org_id
		 ,period_id
		 ,quota_id
		 ,revenue_class_id
		 ,target_amount
		 ,year_to_date
		 ,period_to_date
		 ,quarter_to_date)
	       SELECT
	       cn_srp_per_quota_rc_s.nextval
	       ,pq.srp_period_quota_id
	       ,pq.srp_plan_assign_id
	       ,pq.salesrep_id
	       ,l_org_id
	       ,pq.period_id
	       ,pq.quota_id
	       ,qr.revenue_class_id
	       ,0 -- target amount
	       ,0 -- ytd
	       ,0 -- ptd
	       ,0 -- qtd
	       FROM  cn_srp_period_quotas pq -- periods that rep/plan uses quota
	       ,cn_quota_rules            qr
	       ,cn_quotas	          q
	       WHERE pq.srp_plan_assign_id = c.srp_plan_assign_id
	       AND pq.quota_id	      = qr.quota_id
	       AND qr.quota_id	      = q.quota_id
	       AND q.quota_type_code IN ('EXTERNAL','FORMULA')
	       AND l_period_status in ('O','F')
	       AND NOT EXISTS (SELECT 'srp_period_quota_rc already exists'
			       FROM cn_srp_per_quota_rc spqr
			       WHERE spqr.srp_period_quota_id = pq.srp_period_quota_id
			       AND spqr.srp_plan_assign_id = pq.srp_plan_assign_id
			       AND spqr.revenue_class_id    = qr.revenue_class_id)
	       ;

	END LOOP; -- srp_plan_info

	-- mark that this rep, period IS done
	UPDATE cn_process_batches
	   SET sales_lines_total = 1
	 WHERE physical_batch_id = p_physical_batch_id
	   AND salesrep_id = srp.salesrep_id
	   AND period_id = srp.period_id;

	COMMIT;  -- commit for each srp and period
   END LOOP; -- main srp loop

   cn_message_pkg.debug('Update cn_period_statuses.processing_status_code');
   cn_message_pkg.debug('Populate SRP tables runner <<');
   cn_message_pkg.end_batch(l_proc_audit_id);
EXCEPTION
   WHEN    payee_pop_failed  THEN
      --ROLLBACK TO populate_srp_tables;
      retcode := 2;

      -- change status to FAILED
      UPDATE cn_period_statuses
     	 SET processing_status_code = 'FAILED'
       WHERE processing_status_code = 'PROCESSING'
	 AND period_id = l_curr_pd_id;
      -- commit status change
      COMMIT;

      fnd_file.put_line(fnd_file.Log, 'Payee Population Failed');
      fnd_file.put_line(fnd_file.Log, 'salesrep id'||l_err_srp_id);
      fnd_file.put_line(fnd_file.Log, 'period id'||l_period_id);
      fnd_file.put_line(fnd_file.Log, 'quota id'||l_err_quota_id);
   WHEN    srp_pop_failed  THEN
      --ROLLBACK TO populate_srp_tables_runner;
      retcode := 2;

      -- change status to FAILED
      UPDATE cn_period_statuses
     	 SET processing_status_code = 'FAILED'
       WHERE processing_status_code = 'PROCESSING'
	 AND period_id = l_curr_pd_id;
      -- commit status change
      COMMIT;

      fnd_file.put_line(fnd_file.Log, 'Srp Periods Population Failed');
      fnd_file.put_line(fnd_file.Log, 'salesrep id'||l_curr_srp_id);
      fnd_file.put_line(fnd_file.Log, 'period id'||l_curr_pd_id);
   WHEN  OTHERS THEN
      --ROLLBACK TO populate_srp_tables_runner;
      errbuf := substr(sqlerrm,1,250);
      retcode := 2;

      -- change status to FAILED
      UPDATE cn_period_statuses
     	 SET processing_status_code = 'FAILED'
       WHERE processing_status_code = 'PROCESSING'
	 AND period_id = l_curr_pd_id;
      -- commit status change
      COMMIT;

      fnd_file.put_line(fnd_file.Log, 'Unknown Failure');
      fnd_file.put_line(fnd_file.Log, 'salesrep id'||l_curr_srp_id);
      fnd_file.put_line(fnd_file.Log, 'period id'||l_curr_pd_id);
      fnd_file.put_line(fnd_file.Log, 'errbuf'||errbuf);
END populate_srp_tables_runner;


/* ----------------------------------------------------------------------- */
  --
  -- Procedure Name
  -- Check_CN_Period_Record
  -- Purpose
  -- Create a CN status record in CN_PERIOD_STATUSES if it doesn't exist.
  --

  PROCEDURE Check_CN_Period_Record (x_org_id             NUMBER,
				    x_period_name	 VARCHAR2,
				    x_closing_status	 VARCHAR2,
				    x_period_type	 VARCHAR2,
				    x_period_year	 NUMBER,
				    x_quarter_num        NUMBER,
				    x_period_num	 NUMBER,
				    x_period_set_name    VARCHAR2,
				    x_start_date         DATE,
				    x_end_date           DATE,
				    x_freeze_flag        VARCHAR2,
				    x_repository_id	 NUMBER) IS

    x_period_id       NUMBER(15);
    x_period_type_id  NUMBER(15);
    x_period_set_id   NUMBER(15);
    x_dummy           NUMBER(15);

    l_return_status   VARCHAR2(30);
    l_loading_status  VARCHAR2(30);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);

    CURSOR c1 IS
       SELECT period_type_id
	 FROM cn_period_types
	 WHERE period_type = x_period_type
	   AND org_id      = x_org_id;
    CURSOR c2 IS
       SELECT period_set_id
	 FROM cn_period_sets
	 WHERE period_set_name = x_period_set_name
	   AND org_id          = x_org_id;

    l_period_set_id NUMBER;
    l_period_type_id NUMBER;
    l_cal_per_int_type_id NUMBER;
    l_interval_number NUMBER;
    l_period_quota_id number(15);

    CURSOR repository IS
       SELECT period_set_id, period_type_id
	 FROM cn_repositories
	WHERE org_id = x_org_id;
    CURSOR interval_types IS
       SELECT interval_type_id
	 FROM cn_interval_types
	WHERE org_id = x_org_id;
    CURSOR interval_number (p_interval_type_id NUMBER) IS
       SELECT interval_number
	 FROM cn_cal_per_int_types
	 WHERE interval_type_id = p_interval_type_id
	   AND org_id = x_org_id
	 ORDER BY Abs(cal_period_id - x_period_id);

    BEGIN

       -- get the period_type_id from cn_period_types,
       -- if there is no matching record, create one
       OPEN c1;
       FETCH c1 INTO x_period_type_id;

       IF (c1%NOTFOUND) THEN
	  SELECT cn_period_types_s.NEXTVAL
	    INTO x_period_type_id
	    FROM dual;
	  INSERT INTO cn_period_types
	    (period_type_id,
	     period_type,
	     org_id)
	    VALUES
	    (x_period_type_id,
	     x_period_type,
	     x_org_id);
       END IF;
       CLOSE c1;

       -- get the period_set_id from cn_period_sets.
       -- if there is no matching record, create one
       OPEN c2;
       FETCH c2 INTO x_period_set_id;

       IF (c2%NOTFOUND) THEN
	  SELECT cn_period_sets_s.NEXTVAL
	    INTO x_period_set_id
	    FROM dual;
	  INSERT INTO cn_period_sets
	    (period_set_id,
	     period_set_name,
	     org_id)
	    VALUES
	    (x_period_set_id,
	     x_period_set_name,
	     x_org_id);
       END IF;
       CLOSE c2;

       x_period_id := 10000000000 * x_period_set_id +
	  10000000 * x_period_type_id +
	 1000 * x_period_year + x_period_num;

       SELECT period_id
	 INTO x_dummy
	 FROM cn_period_statuses
	 WHERE period_id   = x_period_id
	   AND org_id      = x_org_id;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN

	 -- the following code is obsolete and commented out

	-- if    x_period_type = 'Year' then
	--      x_period_type_id := 1  ;
	-- elsif x_period_type = 'Quarter' then
	--      x_period_type_id := 2  ;
	-- elsif x_period_type = 'Month' then
	--      x_period_type_id := 3   ;
	-- else  x_period_type_id := 0 ;        -- Bug 397015. Xinyang Fan
        -- end if;


	INSERT INTO cn_period_statuses
		   (period_id,
		    period_name,
		    period_type_id,
		    period_status,
		    period_type,
		    period_year,
		    quarter_num,
		    start_date,
		    end_date,
		    forecast_flag,
		    period_set_name,
		    period_set_id,
		    freeze_flag,
		    processing_status_code,
		    org_id)
	    VALUES (x_period_id,
		    x_period_name,
		    x_period_type_id,
		    x_closing_status,
		    x_period_type,
		    x_period_year,
		    x_quarter_num,
		    x_start_date,
		    x_end_date,
		    'N',
		    x_period_set_name,
		    x_period_set_id,
		    x_freeze_flag,
		    Decode(x_closing_status,'O','PROCESSING','F','PROCESSING','CLEAN'), --1979768
		    x_org_id);


	-- bug 1979768 : populate_srp_tables moved to concurrent program


	-- In addition, the newly activated period should be inserted into cn_calc_per_int_types
	-- for the relevant interval types.
	OPEN  repository;
	FETCH repository INTO l_period_set_id, l_period_type_id;
	CLOSE repository;

	IF (x_period_set_id = l_period_set_id AND x_period_type_id = l_period_type_id) THEN
	   FOR interval_type IN interval_types LOOP
	      IF (interval_type.interval_type_id <> -1003) THEN
		 l_cal_per_int_type_id := NULL;
		 l_interval_number := 1; --default value

		 OPEN  interval_number(interval_type.interval_type_id);
		 FETCH interval_number INTO l_interval_number;
		 CLOSE interval_number;

		 cn_int_assign_pkg.insert_row
		   (x_cal_per_int_type_id => l_cal_per_int_type_id,
		    x_interval_type_id    => interval_type.interval_type_id,
		    x_cal_period_id       => x_period_id,
		    x_org_id              => x_org_id,
		    x_interval_number     => l_interval_number,
		    x_last_update_date    => sysdate,
		    x_last_updated_by     => fnd_global.user_id,
		    x_creation_date       => sysdate,
		    x_created_by          => fnd_global.user_id,
		    x_last_update_login   => fnd_global.login_id
		    );
	      END IF;
	   END LOOP;
	END IF;

	-- Set repository status to F = Frozen.  Per WFRIEND. 07-21-95.
	-- Removed.  Per WFRIEND.  08-03-95.
	--	UPDATE cn_repositories
	--	   SET status = 'F'
	--	 WHERE repository_id = x_repository_id ;

  END Check_CN_Period_Record;

--
-- Procedure Name
--   set_dates
-- Purpose
--   Set start and end dates from start and end periods.
-- History
--   01-26-96	A. Erickson	Created
--   03-13-96	A. Erickson	Updated.
--

  PROCEDURE set_dates (x_start_period_id  cn_period_statuses.period_id%TYPE,
		       x_end_period_id	  cn_period_statuses.period_id%TYPE,
		       x_org_id           cn_period_statuses.org_id%TYPE,
		       x_start_date	  OUT	nocopy  DATE,
		       x_end_date	  OUT	nocopy  DATE) IS

    CURSOR get_dates (p_period_id NUMBER) is
     SELECT cn.start_date, cn.end_date
       FROM CN_PERIOD_STATUSES CN, CN_REPOSITORIES_ALL RP
      WHERE rp.period_set_id = cn.period_set_id
        AND rp.period_type_id = cn.period_type_id
        AND cn.org_id = rp.org_id
        AND cn.org_id = x_org_id
        AND period_id = p_period_id;

    date_rec get_dates%ROWTYPE;

    CURSOR get_min_date IS
     SELECT MIN(cn.start_date)
       FROM CN_PERIOD_STATUSES CN, CN_REPOSITORIES_ALL RP
      WHERE rp.period_set_id = cn.period_set_id
        AND rp.period_type_id = cn.period_type_id
        AND cn.org_id = rp.org_id
        AND cn.org_id = x_org_id;

  BEGIN
     IF (x_start_period_id IS NOT NULL) THEN
	OPEN  get_dates(x_start_period_id);
	FETCH get_dates INTO date_rec;
	CLOSE get_dates;
	x_start_date := date_rec.start_date;
      ELSE
	OPEN get_min_date;
	FETCH get_min_date INTO x_start_date;
	CLOSE get_min_date;
     END IF;

     IF (x_end_period_id IS NOT NULL) THEN
	OPEN  get_dates(x_end_period_id);
	FETCH get_dates INTO date_rec;
	CLOSE get_dates;
	x_end_date := date_rec.end_date;
      ELSE
	x_end_date := SYSDATE;
     END IF;
  END set_dates;


END cn_periods_api;

/
