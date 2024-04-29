--------------------------------------------------------
--  DDL for Package Body ZPB_AW_WRITE_BACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_AW_WRITE_BACK" AS
/* $Header: zpbwriteback.plb 120.10 2007/12/05 12:53:22 mbhat ship $ */

G_PKG_NAME CONSTANT VARCHAR2(17) := 'zpb_aw_write_back';

------------------------------------------------------------------------------
-- INITIALIZE - Initializes the session by attaching the AW's and setting the
--              context for a given business area
------------------------------------------------------------------------------
PROCEDURE INITIALIZE (p_user_name          IN VARCHAR2,
                      p_business_area_id   IN NUMBER,
                      p_return_status      OUT NOCOPY VARCHAR2,
                      p_msg_data           OUT NOCOPY VARCHAR2)
   is
      l_msg_count   NUMBER;
      l_user_id     NUMBER;
begin
   select USER_ID into l_user_id from FND_USER where USER_NAME = p_user_name;

   ZPB_AW.INITIALIZE (p_api_version      => 1.0,
                      p_init_msg_list    => FND_API.G_TRUE,
                      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
                      x_return_status    => p_return_status,
                      x_msg_count        => l_msg_count,
                      x_msg_data         => p_msg_data,
                      p_business_area_id => p_business_area_id,
                      p_shadow_id        => l_user_id,
                      p_shared_rw        => FND_API.G_TRUE,
                      p_annot_rw         => FND_API.G_FALSE);

end INITIALIZE;

------------------------------------------------------------------------------
-- L_LOG_USER - Procedure that logs various parameters about the CR
--
------------------------------------------------------------------------------
PROCEDURE l_log_user (P_TASK  IN VARCHAR2,
                      P_USER  IN VARCHAR2,
                      P_RESP  IN VARCHAR2,
                      P_ORDER IN NUMBER,
                      P_QDR   IN VARCHAR2)
   IS
BEGIN
   ZPB_LOG.WRITE_EVENT_TR ('zpb_aw_write_back.l_log_user',
                           'ZPB_WRITEMGR_PROCESS_TASK',
                           'TASK_NUMBER', to_char(p_task));
   ZPB_LOG.WRITE_EVENT_TR ('zpb_aw_write_back.l_log_user',
                           'ZPB_WRITEMGR_SUBMITTED_BY',
                           'USER', p_user,
                           'RESP', p_resp);
   ZPB_LOG.WRITE_EVENT_TR ('zpb_aw_write_back.l_log_user',
                           'ZPB_WRITEMGR_EXECUTE',
                           'ORDER', to_char(p_order));
   ZPB_LOG.WRITE_EVENT_TR ('zpb_aw_write_back.l_log_user',
                              'ZPB_WRITEMGR_PROCEDURE',
                           'PROC', p_qdr);
END l_log_user;

------------------------------------------------------------------------------
-- L_REMOVE_OLD_RECORDS - Procedure that updates ZPB_WRITEBACK_TASKS after
--                        a CR has been run
--
------------------------------------------------------------------------------
PROCEDURE l_remove_old_records
   IS
      default_num_of_days number       := 30;
      prof_num_of_days    varchar2(255);
      num_of_days         number;
      rcd_ct              number;
      prof_name           varchar2(35);
      l_aws               varchar2(256);
BEGIN
   zpb_log.write ('ZPB_AW_WRITE_BACK.l_remove_old_records','Begin program :');

   prof_name := 'ZPB_WRITEBACK_TABLE_NUMBER_OF_DAYS';
   fnd_profile.get(prof_name, prof_num_of_days);
   if prof_num_of_days is null then
      num_of_days := default_num_of_days;
    else
      num_of_days := to_number(prof_num_of_days);
   end if;

   select count(*) into rcd_ct
      from ZPB_WRITEBACK_TASKS
      where (status = COMPLETED  or status = FAILED)
      and completion_date <= (SYSDATE - num_of_days);

   if rcd_ct > 0 then
      ZPB_LOG.WRITE_EVENT_TR ('zpb_aw_write_back.l_remove_old_records',
                              'ZPB_WRITEMGR_CLEANUP',
                              'DATE', (SYSDATE - (num_of_days - 1)));

      delete from ZPB_WRITEBACK_TASKS
         where (status = COMPLETED or status = FAILED)
         and completion_date <= (SYSDATE - num_of_days);
   end if;
   zpb_log.write ('ZPB_AW_WRITE_BACK.l_remove_old_records','End program :');
END l_remove_old_records;

------------------------------------------------------------------------------
-- SUBMIT_WRITEBACK_REQUEST - Submits the writeback request
--
------------------------------------------------------------------------------
PROCEDURE submit_writeback_request ( P_BUSINESS_AREA_ID IN NUMBER,
                                     P_USER_ID IN NUMBER,
                                     P_RESP_ID IN NUMBER,
                                     P_SESSION_ID IN NUMBER,
                                     P_TASK_TYPE IN VARCHAR2,
                                     P_SPL IN VARCHAR2,
                                     P_START_TIME IN DATE,
                                     P_OUTVAL OUT NOCOPY Number )
IS
   req_id NUMBER;
   req_nm ZPB_REQUESTS.req_name%type;
   resp_name FND_RESPONSIBILITY_VL.RESPONSIBILITY_NAME%type;
   zpb_user FND_USER.USER_NAME%type;
   stmt_ln NUMBER;
   cmd_str VARCHAR2(32767);
   spl_stmt ZPB_WRITEBACK_TRANSACTION.QDR%type;
   str_ptr NUMBER;
   ctr NUMBER;
   tsk_seq NUMBER;
   delim varchar2(1);

   -- Added for Bug: 5475982
   l_conc_request_id NUMBER;

BEGIN

   ZPB_ERROR_HANDLER.INITIALIZE;

   -- Added for Bug: 5475982
   l_conc_request_id := fnd_global.conc_request_id;

   SELECT distinct(responsibility_name) into resp_name
      FROM FND_RESPONSIBILITY_VL
      WHERE responsibility_id = P_RESP_ID;

   SELECT distinct(user_name) into zpb_user
      from FND_USER
      where user_id = P_USER_ID;

   select req_name
      into req_nm
      from ZPB_REQUESTS
      where req_task_type = P_TASK_TYPE;

   select zpb_writeback_seq.nextval into tsk_seq from dual;

   INSERT INTO zpb_writeback_tasks (task_type, business_area_id, user_id,
                                    session_id, task_seq, status, resp_id,
                                    submit_date,
                                    CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
                                    LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
      VALUES (P_TASK_TYPE, p_business_area_id, zpb_user,
              P_SESSION_ID, tsk_seq,
              PENDING, resp_name, P_START_TIME,
              fnd_global.USER_ID, SYSDATE, fnd_global.USER_ID,
              SYSDATE, fnd_global.LOGIN_ID);

   cmd_str := P_SPL;
   stmt_ln := lengthb(cmd_str);
   ctr := 0;
   delim := ';';
   loop
      ctr := ctr + 1;
      str_ptr := instrb(cmd_str, delim);
      exit when str_ptr = 0 or str_ptr is null;
      spl_stmt := substrb(cmd_str, 0, str_ptr - 1);
      INSERT INTO zpb_writeback_transaction
         (task_seq, exec_order, qdr,
          CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
          LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
         VALUES (tsk_seq,  ctr, spl_stmt,
                 fnd_global.USER_ID, SYSDATE, fnd_global.USER_ID,
                 SYSDATE, fnd_global.LOGIN_ID);

      cmd_str := substrb(cmd_str, (str_ptr - stmt_ln),
                         (stmt_ln - str_ptr));
      stmt_ln := lengthb(cmd_str);
   end loop;

   -- handles the condition when no delimiter is at the end of cmd_str
   if cmd_str is not null then
      INSERT INTO zpb_writeback_transaction
         (task_seq, exec_order, qdr,
          CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
          LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
         VALUES (tsk_seq, ctr, cmd_str,
                 fnd_global.USER_ID, SYSDATE, fnd_global.USER_ID,
                 SYSDATE, fnd_global.LOGIN_ID);
   end if;

   -- Fix for Bug: 5475982
   -- If this procedure is invoked from an interactive UI session or
   -- for User Maintanence task only then the following Conc. program
   -- should be launched otherwise it will be bundled for all
   -- users/rules and launched once.

   IF l_conc_request_id < 0 OR p_task_type = 'UM' THEN
     IF req_nm = 'ZPB_DO_WRTBK' THEN
       req_id := FND_REQUEST.SUBMIT_REQUEST ('ZPB',
                                             req_nm,
                                             null,
                                             TO_CHAR(P_START_TIME, 'DD-MON-YYYY HH24:MI:SS'),
                                             FALSE,
                                             tsk_seq,
                                             null,
                                             P_BUSINESS_AREA_ID);
     ELSE
       req_id := FND_REQUEST.SUBMIT_REQUEST ('ZPB',
                                             req_nm,
                                             null,
                                             TO_CHAR(P_START_TIME, 'DD-MON-YYYY HH24:MI:SS'),
                                             FALSE,
                                             tsk_seq,
                                             P_BUSINESS_AREA_ID);
     END IF;

   END IF;

   P_OUTVAL := req_id;

EXCEPTION
   when others then
      ZPB_ERROR_HANDLER.HANDLE_EXCEPTION (G_PKG_NAME,
                                          'submit_writeback_request');

END submit_writeback_request;

 PROCEDURE process_cleanup ( ERRBUF OUT NOCOPY VARCHAR2,
                               RETCODE OUT NOCOPY VARCHAR2,
                               P_TASK_SEQ IN NUMBER,
                               P_BUSINESS_AREA_ID IN NUMBER)
   is
      errNum              number;
      aw_attached         boolean := FALSE;
      last_task           number;
      l_aws               varchar2(256);
      l_dataAw            varchar2(32);
      l_annotAw           varchar2(32);

      cursor tasks is
         select a.task_seq taskseq, a.user_id asuser,
           a.resp_id asresp, b.qdr type, b.exec_order exorder
            from zpb_writeback_tasks a, zpb_writeback_transaction b
            where b.task_seq = a.task_seq
              and a.task_seq = P_TASK_SEQ
            order by b.exec_order ASC;

BEGIN
   errbuf := ' ';
   RETCODE := '0';
/*
   FOR each in tasks loop
      if NOT aw_attached then
         l_attach_aws (each.read_aws, false, each.asuser);
         l_attach_aws (each.write_aws, true, each.asuser);
         aw_attached := TRUE;
         l_aws := each.write_aws||'|'||each.read_aws;
      end if;

      --log user/resp
      last_task := each.taskseq;
      l_log_user (last_task, each.asuser, each.asresp,
                  each.exorder, each.type);

      --set the status to failed
      update zpb_writeback_tasks set
            status = FAILED, completion_date = SYSDATE,
                LAST_UPDATED_BY =  fnd_global.USER_ID, LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
         where task_seq = each.taskseq;

      if (each.type = 'FULL') then
         /*
         delete * from zpb_ac_param_values;
         delete * from zpb_analysis_cycles;
         delete * from zpb_analysis_cycle_instances;
         delete * from zpb_analysis_cycle_tasks;
         --delete * from zpb_aw_references;
         delete * from zpb_cycle_model_dimensions;
         delete * from zpb_cycle_relationships;
         delete * from zpb_dc_distribution_lists;
         delete * from zpb_dc_distribution_list_items;
         delete * from zpb_dc_instruction_text;
         delete * from zpb_dc_instruction_text_items;
         delete * from zpb_home_page_data;
         delete * from zpb_label_lookups;
         delete * from zpb_solve_allocation_basis;
         delete * from zpb_solve_allocation_rules;
         delete * from zpb_solve_definitions;
         delete * from zpb_solve_input_levels;
         delete * from zpb_solve_output_hierarchies;
         delete * from zpb_solve_output_levels;
         delete * from zpb_status_sql;
         delete * from zpb_status_sql_lines;
         delete * from zpb_task_parameters;
         delete * from zpb_writeback_tasks;
         delete * from zpb_writeback_transaction;

            null;
         --
         -- TODO: Delete from WF tables
         --
      end if;
/*
      delete * from zpb_univ_attributes;
      delete * from zpb_univ_dimensions;
      delete * from zpb_univ_dimension_abbrevs;
      delete * from zpb_univ_dimension_groups;
      delete * from zpb_univ_hierarchies;

      l_dataAw  := substr (each.write_aws, 1, instr (each.write_aws, '|')-1);
      l_annotAw := substr (each.write_aws, instr (each.write_aws, '|')+1);
      zpb_build_metadata.remove_metadata (l_dataAw, l_annotAw);

   END LOOP;
   if aw_attached then
      --detach AW
      l_detach_aws (l_aws, true);
      aw_attached := FALSE;

      --update the tasks table
      update zpb_writeback_tasks set
            status = COMPLETED, completion_date = SYSDATE,
                LAST_UPDATED_BY =  fnd_global.USER_ID, LAST_UPDATE_DATE = SYSDATE,
                LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
         where task_seq = last_task;

    else
      --log no tasks found
      FND_MESSAGE.SET_NAME('ZPB','ZPB_WRITEMGR_NO_TASKS_FOUND');
      FND_FILE.put_line(FND_FILE.LOG, FND_MESSAGE.GET);
   end if;

   --remove records timed by ZPB_WRITEBACK_TABLE_NUMBER_OF_DAYS profile
   l_remove_old_records;

EXCEPTION
   when others then
      ZPB_ERROR_HANDLER.HANDLE_EXCEPTION (G_PKG_NAME,
                                          'process_cleanup');
      retcode := '2';
      errNum := SQLCODE;
      errbuf := sqlerrm(errNum);
      if aw_attached then
         l_detach_aws (l_aws, false);
      end if;
    */
END process_cleanup;

--process_dvac_admin_task will maintain data view access controls.
--
-- Procedure will read in two task tokens for a data view access control request.
-- The first token will specify whether the request is from a task or action.
-- The second token contains the instance_id.
--
PROCEDURE process_dvac_writeback ( ERRBUF OUT NOCOPY VARCHAR2,
                                      RETCODE OUT NOCOPY VARCHAR2,
                                      P_TASK_SEQ IN NUMBER,
                                      P_BUSINESS_AREA_ID IN NUMBER)
   IS
      errNum                    number;
      l_initialized             boolean := FALSE;
      x_return_status           varchar2(1);
      l_spl                     varchar2(80);
      x_msg_count               number;
      x_msg_data                varchar2(4000);
      l_api_version             NUMBER := 1.0;

      cursor tasks is
         select task_seq taskseq, business_Area_id,
            user_id asuser, resp_id asresp
            from zpb_writeback_tasks
            where task_seq = P_TASK_SEQ;

      cursor tokens is
                   select qdr token, exec_order exorder
                   from zpb_writeback_transaction
                   where task_seq = P_TASK_SEQ
         order by exec_order ASC;

        BEGIN

   errbuf := ' ';

   for v_task in tasks loop

      --set the initial status to failed
      update zpb_writeback_tasks set
        status = FAILED, completion_date = SYSDATE,
         LAST_UPDATED_BY =  fnd_global.USER_ID, LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
         where task_seq = v_task.taskseq;

      if (not l_initialized) then
         INITIALIZE (v_task.asuser,
                     v_task.business_Area_id,
                     x_return_status,
                     errbuf);
         l_initialized := true;
      end if;

      for v_tokens in tokens loop
         -- start of bug 5007057
         -- Delete the logic that would only execute the first dvac olap
         -- command and execute the olap command for each v_tokens
         -- if (v_tokens.exorder = 1) then
            l_spl := v_tokens.token;
            zpb_aw.execute(l_spl);
         -- end if;
      end loop;

      -- the following line is deleted to fix the bug 5007057
      -- zpb_aw.execute(l_spl);
      -- end of bug 5007057

      --update the tasks table
      update zpb_writeback_tasks set
         status = COMPLETED, completion_date = SYSDATE,
         LAST_UPDATED_BY =  fnd_global.USER_ID, LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
         where task_seq = v_task.taskseq;

   end loop;

   ZPB_AW.EXECUTE ('update');
   commit;

   ZPB_AW.DETACH_ALL;

   l_remove_old_records;
   RETCODE := '0';

EXCEPTION
   when others then
      ZPB_ERROR_HANDLER.HANDLE_EXCEPTION (G_PKG_NAME,
                                          'process_dvac_admin_task');
      retcode := '2';
      errNum := SQLCODE;
      errbuf := sqlerrm(errNum);
      ZPB_AW.DETACH_ALL;

END process_dvac_writeback;


--process_scoping_admin_tasks will set ownership, write or read scoping assignments
--for a selected user.
-- Procedure will handle a rule set given query_path search key
-- of the form <FOLDER_PATH>/<USER_ID>_<TASK_TYPE>_
-- This key is stored as the first token in the task transaction table.
-- The second token contains the SPL procedure call.

  PROCEDURE process_scoping_admin_tasks ( ERRBUF OUT NOCOPY VARCHAR2,
                                           RETCODE OUT NOCOPY VARCHAR2,
                                           P_TASK_SEQ IN NUMBER,
                                           P_CONC_REQUEST_ID IN NUMBER DEFAULT NULL,
                                           P_BUSINESS_AREA_ID IN NUMBER)
   IS
      errNum                    number;
      l_initialized             boolean := FALSE;
      task                      number;
      l_start                   number;
      l_end                     number;
      s_user_id                 varchar2(80);
      l_user_id                 number;
      l_aws                     varchar2(256);
      l_query_path              varchar2(80);
      set_reset                 boolean := TRUE;
      query_path_key            varchar2(256);
      x_user_account_state      varchar2(12);
      x_return_status           varchar2(1);
      x_has_read_acc            number;
      x_msg_count               number;
      x_msg_data                varchar2(4000);
      l_invalid_user            VARCHAR2(12) := 'INVALID_USER';
      l_has_read_acc            VARCHAR2(12) := 'HAS_READ_ACC';
      l_no_read_acc             VARCHAR2(11) := 'NO_READ_ACC';
      l_api_version             NUMBER := 1.0;

      -- Added for Bug:5475982
      l_err_msg                 VARCHAR2(256);
      l_status                  VARCHAR2(256);

      cursor tasks is
         select a.task_seq taskseq, a.business_Area_id,
            a.user_id asuser,
            a.resp_id asresp, b.qdr token, b.exec_order exorder
           from zpb_writeback_tasks a, zpb_writeback_transaction b
           where b.task_seq = a.task_seq
            and a.task_seq = P_TASK_SEQ
           order by b.exec_order ASC;

      -- Added for Bug: 5475982
      CURSOR tasks_bulk_mode
      IS
      SELECT a.task_seq taskseq,
             a.business_Area_id,
             a.user_id asuser,
             a.resp_id asresp,
	     b.qdr token,
	     b.exec_order exorder
      FROM   zpb_writeback_tasks a,
             zpb_writeback_transaction b
      WHERE  b.task_seq = a.task_seq
      AND    a.session_id = p_conc_request_id
      AND    a.task_type = 'DO'
      ORDER BY b.exec_order ASC;

BEGIN
   zpb_log.write ('ZPB_AW_WRITE_BACK.process_scoping_admin_tasks','Begin program :');
   errbuf := ' ';
   retcode := '0';

   -- Added for Bug:5475982
   IF p_conc_request_id > 0 THEN

     for v_task in tasks_bulk_mode loop
        task := v_task.taskseq;

        if not l_initialized then
           INITIALIZE (v_task.asuser,
                       v_task.business_Area_id,
                       x_return_status,
                       errbuf);
           l_initialized := true;
        end if;

        zpb_log.write_statement ('ZPB_AW_WRITE_BACK.process_scoping_admin_tasks',
              'Updating writeback_tasks table with Status as FAILED for Task Seq: '||task );
        --set the initial status to failed
        update zpb_writeback_tasks set
           status = FAILED, completion_date = SYSDATE,
           LAST_UPDATED_BY =  fnd_global.USER_ID, LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
           where task_seq = task;

        if (v_task.exorder = 1) then
          s_user_id := v_task.token;
          l_user_id := to_number(s_user_id);
        else
           l_log_user (v_task.taskseq, v_task.asuser, v_task.asresp,
                       v_task.exorder, v_task.token);

           -- Added exception handling code for Bug:5475982
           BEGIN
             ZPB_AW.EXECUTE(v_task.token);
           EXCEPTION
	     WHEN OTHERS THEN
               fnd_message.set_name('ZPB','ZPB_MNTDATASEC_FAILED');

               l_status := fnd_message.get;
               l_err_msg := SQLERRM;

               IF INSTR(v_task.token, 'ReadAccess',1) > 0 THEN

                 UPDATE zpb_security_rule_definition_t
	         SET status = l_status,
	             error = error || '; ' || l_err_msg
	         WHERE business_area = v_task.business_Area_id
		 AND rule_type = 'READ'
	         AND   user_id = v_task.asuser;

               ELSIF INSTR(v_task.token, 'WriteAccess',1) > 0 THEN

                 UPDATE zpb_security_rule_definition_t
	         SET status = l_status,
	             error = error || '; ' || l_err_msg
	         WHERE business_area = v_task.business_Area_id
		 AND rule_type = 'WRITE'
	         AND   user_id = v_task.asuser;

               ELSIF INSTR(v_task.token, 'Ownership',1) > 0 THEN

                 UPDATE zpb_security_rule_definition_t
	         SET status = l_status,
	             error = error || '; ' || l_err_msg
	         WHERE business_area = v_task.business_Area_id
		 AND rule_type = 'OWNERSHIP'
	         AND   user_id = v_task.asuser;

	       END IF;

	       UPDATE zpb_account_states
	       SET has_read_access = 0
	       WHERE user_id = v_task.asuser
	       AND business_area_id = v_task.business_Area_id;

               retcode := '2';
	   END;
        end if;

        zpb_log.write_statement ('ZPB_AW_WRITE_BACK.process_scoping_admin_tasks',
              'Checking for Read access in accounts_states table for User'||l_user_id);

        --check this user for read access and update has_read_access flag in zpb_account_states
        ZPB_SECURITY_UTIL_PVT.validate_user(l_user_id,
                                            v_task.business_area_id,
                                            l_api_version,
                                            FND_API.G_FALSE,
                                            FND_API.G_FALSE,
                                            FND_API.G_VALID_LEVEL_FULL,
                                            x_user_account_state,
                                            x_return_status,
                                            x_msg_count,
                                            x_msg_data);

        if (x_user_account_state = l_has_read_acc) then
           x_has_read_acc := 1;
        else
           x_has_read_acc := 0;
        end if;

        zpb_log.write_statement ('ZPB_AW_WRITE_BACK.process_scoping_admin_tasks',
              'Updating accounts_states table has_read_access col for User'||l_user_id);
        update zpb_account_states
           set has_read_access = x_has_read_acc
           where user_id = l_user_id
           and business_area_id = v_task.business_area_id;

     end loop;

   ELSE

     for v_task in tasks loop
        task := v_task.taskseq;

        if not l_initialized then
           INITIALIZE (v_task.asuser,
                       v_task.business_Area_id,
                       x_return_status,
                       errbuf);
           l_initialized := true;
        end if;

        zpb_log.write_statement ('ZPB_AW_WRITE_BACK.process_scoping_admin_tasks',
              'Updating writeback_tasks table with Status as FAILED for Task Seq: '||task );
        --set the initial status to failed
        update zpb_writeback_tasks set
           status = FAILED, completion_date = SYSDATE,
           LAST_UPDATED_BY =  fnd_global.USER_ID, LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
           where task_seq = task;

        if (v_task.exorder = 1) then
          s_user_id := v_task.token;
          l_user_id := to_number(s_user_id);
        else
           l_log_user (v_task.taskseq, v_task.asuser, v_task.asresp,
                       v_task.exorder, v_task.token);
           ZPB_AW.EXECUTE(v_task.token);
        end if;

        zpb_log.write_statement ('ZPB_AW_WRITE_BACK.process_scoping_admin_tasks',
              'Checking for Read access in accounts_states table for User'||l_user_id);

        --check this user for read access and update has_read_access flag in zpb_account_states
        ZPB_SECURITY_UTIL_PVT.validate_user(l_user_id,
                                            v_task.business_area_id,
                                            l_api_version,
                                            FND_API.G_FALSE,
                                            FND_API.G_FALSE,
                                            FND_API.G_VALID_LEVEL_FULL,
                                            x_user_account_state,
                                            x_return_status,
                                            x_msg_count,
                                            x_msg_data);

        if (x_user_account_state = l_has_read_acc) then
           x_has_read_acc := 1;
        else
           x_has_read_acc := 0;
        end if;

        zpb_log.write_statement ('ZPB_AW_WRITE_BACK.process_scoping_admin_tasks',
              'Updating accounts_states table has_read_access col for User'||l_user_id);
        update zpb_account_states
           set has_read_access = x_has_read_acc
           where user_id = l_user_id
           and business_area_id = v_task.business_area_id;

     end loop;
   END IF;


   ZPB_AW.EXECUTE ('update');
   commit;

   ZPB_AW.DETACH_ALL;

   --update the tasks table
   -- Added for Bug: 5475982
   IF p_conc_request_id > 0 THEN

     zpb_log.write_statement ('ZPB_AW_WRITE_BACK.process_scoping_admin_tasks',
        'Updating writeback_tasks table with Status as COMPLETED for SessionID: '||p_conc_request_id );

     UPDATE zpb_writeback_tasks
     SET status = COMPLETED,
         completion_date = SYSDATE,
	 last_updated_by =  fnd_global.user_id,
	 last_update_date = SYSDATE,
	 last_update_login = fnd_global.login_id
     WHERE session_id = p_conc_request_id;

   ELSE

    zpb_log.write_statement ('ZPB_AW_WRITE_BACK.process_scoping_admin_tasks',
        'Updating writeback_tasks table with Status as COMPLETED for Task Seq: '||task );

     UPDATE zpb_writeback_tasks
     SET status = COMPLETED,
         completion_date = SYSDATE,
         last_updated_by =  fnd_global.user_id,
	 last_update_date = SYSDATE,
         last_update_login = fnd_global.login_id
     WHERE task_seq = task;

   END IF;

   COMMIT;

   --remove records timed by ZPB_WRITEBACK_TABLE_NUMBER_OF_DAYS profile
   l_remove_old_records;

   -- Moved this line to the beginning of the procedure for Bug: 5475982.
   -- It is set to '0' to begin with and if an execution of a qdr fails
   -- then the retcode is set to '2'.

   -- RETCODE := '0';

   zpb_log.write ('ZPB_AW_WRITE_BACK.process_scoping_admin_tasks','End program :');

EXCEPTION
   when others then
      ZPB_ERROR_HANDLER.HANDLE_EXCEPTION (G_PKG_NAME,
                                          'process_ownership_tasks');
      retcode := '2';
      errNum := SQLCODE;
      errbuf := sqlerrm(errNum);
      ZPB_AW.DETACH_ALL;

END process_scoping_admin_tasks;

------------------------------------------------------------------------------
-- REAPPLY_ALL_SCOPES - Procedure to rebuild all read/write/ownership scopes
--                      for a given Business Area.  Called after a BA refresh
--                      in case any of the rules have changed.
------------------------------------------------------------------------------
PROCEDURE reapply_all_scopes ( ERRBUF OUT NOCOPY VARCHAR2,
                               RETCODE OUT NOCOPY VARCHAR2,
                               P_BUSINESS_AREA IN NUMBER )
   is
      l_query_path    VARCHAR2(255);
      l_user_name     FND_USER.USER_NAME%type;
      l_retcode       VARCHAR2(2);

      -- filter out bad queries that are in the ZPB_VALIDATION_TEMP_DATA table.
      -- This goes for all cursors.

     cursor all_readaccess is
          select distinct substr(SSQL.QUERY_PATH, 1, instr(SSQL.QUERY_PATH, 'ReadAccess')+10) QUERY_PATH
          from ZPB_STATUS_SQL SSQL
          where QUERY_PATH like 'oracle/apps/zpb/BusArea' ||
                p_business_area || '/ZPBSystem/Private/Manager/%ReadAccess%' and
                substr(SSQL.QUERY_PATH, 1, instr(SSQL.QUERY_PATH, 'ReadAccess')+10)
                   not in(
                     select substr(replace(VTDATA.VALUE, fnd_global.newline(), '/'), 1, instr(SSQL.QUERY_PATH, 'ReadAccess')+10)
                     from ZPB_VALIDATION_TEMP_DATA VTDATA
                     where VTDATA.business_area_id = p_business_area);

     cursor all_writeaccess is
         select distinct substr(SSQL.QUERY_PATH, 1, instr(SSQL.QUERY_PATH, 'WriteAccess')+11) QUERY_PATH
          from ZPB_STATUS_SQL SSQL
          where QUERY_PATH like 'oracle/apps/zpb/BusArea' ||
                p_business_area || '/ZPBSystem/Private/Manager/%WriteAccess%' and
                substr(SSQL.QUERY_PATH, 1, instr(SSQL.QUERY_PATH, 'WriteAccess')+11)
                   not in(
                     select substr(replace(VTDATA.VALUE, fnd_global.newline(), '/'), 1, instr(SSQL.QUERY_PATH, 'WriteAccess')+11)
                     from ZPB_VALIDATION_TEMP_DATA VTDATA
                     where VTDATA.business_area_id = p_business_area);

     cursor all_ownership is
         select distinct substr(SSQL.QUERY_PATH, 1, instr(SSQL.QUERY_PATH, 'Ownership')+9) QUERY_PATH
          from ZPB_STATUS_SQL SSQL
          where QUERY_PATH like 'oracle/apps/zpb/BusArea' ||
                p_business_area || '/ZPBSystem/Private/Manager/%Ownership%' and
                substr(SSQL.QUERY_PATH, 1, instr(SSQL.QUERY_PATH, 'Ownership')+9)
                   not in(
                     select substr(replace(VTDATA.VALUE, fnd_global.newline(), '/'), 1, instr(SSQL.QUERY_PATH, 'Ownership')+9)
                     from ZPB_VALIDATION_TEMP_DATA VTDATA
                     where VTDATA.business_area_id = p_business_area);

begin
   select USER_NAME
      into l_user_name
      from FND_USER
      where USER_ID = FND_GLOBAL.USER_ID;

   zpb_log.write ('ZPB_AW_WRITE_BACK.reapply_all_scopes','Begin program :');

   INITIALIZE (l_user_name,
               p_business_area,
               l_retcode,
               errbuf);

   zpb_log.write ('ZPB_AW_WRITE_BACK.reapply_all_scopes','Initialization done :');

   zpb_log.write ('ZPB_AW_WRITE_BACK.reapply_all_scopes','Process Read Access');
   for each in all_readaccess loop
      l_query_path := each.query_path;
      ZPB_AW.EXECUTE('call sc.set.scope('''||l_query_path||''')');
   end loop;

   zpb_log.write ('ZPB_AW_WRITE_BACK.reapply_all_scopes','Process Write Access');
   for each in all_writeaccess loop
      l_query_path := each.query_path;
      ZPB_AW.EXECUTE('call sc.set.write.acc('''||l_query_path||''')');
   end loop;

   zpb_log.write ('ZPB_AW_WRITE_BACK.reapply_all_scopes','Process Ownership Access');
   for each in all_ownership loop
      l_query_path := each.query_path;
      ZPB_AW.EXECUTE('call sc.set.ownership('''||l_query_path||''')');
   end loop;

   DELETE FROM zpb_validation_temp_data WHERE business_area_id = p_business_area;

   zpb_log.write ('ZPB_AW_WRITE_BACK.reapply_all_scopes','Done');

   ZPB_AW.EXECUTE ('update');
   commit;

   ZPB_AW.DETACH_ALL;
   RETCODE := '0';

EXCEPTION
   WHEN OTHERS THEN
   RETCODE := '2';

end reapply_all_scopes;

   PROCEDURE process_spl ( ERRBUF     OUT NOCOPY VARCHAR2,
                           RETCODE    OUT NOCOPY VARCHAR2,
                           P_TASK_SEQ IN NUMBER,
                           P_BUSINESS_AREA_ID IN NUMBER)
   is
      l_initialized             boolean := FALSE;
      last_task                 number;
      l_aws                     varchar2(256);
      l_personal_aw_nm          zpb_users.personal_aw%type;
      l_personal_aw_nmq         zpb_users.personal_aw%type;
      l_start                   number;
      l_end                     number;
      l_user_id                 zpb_account_states.user_id%type;
      b_commit                  boolean := true;
      b_start_aw_daemon         boolean := false;
      x_user_account_state      varchar2(12);
      x_return_status           varchar2(1);
      x_msg_count               number;
      x_has_read_acc            number;
      x_msg_data                varchar2(4000);
      l_api_version             NUMBER := 1.0;
      l_request_id              NUMBER;
      l_task_type               zpb_writeback_tasks.task_type%TYPE;

      cursor tasks is
         select a.task_type tasktype, a.business_area_id,
            a.task_seq taskseq, a.user_id asuser,
           a.resp_id asresp, b.qdr qdr, b.exec_order exorder
            from zpb_writeback_tasks a, zpb_writeback_transaction b
            where b.task_seq = a.task_seq
              and a.task_seq = P_TASK_SEQ
            order by b.exec_order ASC;

BEGIN
   errbuf := ' ';
   RETCODE := '0';

   FOR each in tasks loop
      l_task_type := each.tasktype;

      if not l_initialized then
         INITIALIZE (each.asuser,
                     each.business_Area_id,
                     x_return_status,
                     errbuf);
         l_initialized := true;
      end if;

      --log user/resp
      last_task := each.taskseq;
      l_log_user (last_task, each.asuser, each.asresp,
                  each.exorder, each.qdr);

      --set the status to failed
      update zpb_writeback_tasks set
         status = FAILED, completion_date = SYSDATE,
         LAST_UPDATED_BY =  fnd_global.USER_ID, LAST_UPDATE_DATE = SYSDATE,
         LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
         where task_seq = each.taskseq;

      ZPB_AW.EXECUTE(each.qdr);

      if (each.tasktype = UMAINT) then
        ZPB_AW.EXECUTE('update');
        commit; --commit changes so zpb_personal_aw.aw_create has visibility to new user
        b_commit := false;
        l_initialized := false;

        l_start := instr(each.qdr, '(');
        l_end := instr(each.qdr, ',');
        l_user_id := substr(each.qdr, l_start+2, l_end - l_start - 3);

        -- Make sure at least one personal AW does not exist before starting daemon
        -- null test added for 10g only
        if (not b_start_aw_daemon ) then
          l_personal_aw_nm := ZPB_AW.GET_PERSONAL_AW (l_user_id);
          if(l_personal_aw_nm is null) then
            b_start_aw_daemon := true;
          else
            l_personal_aw_nmq := ZPB_AW.GET_SCHEMA || '.' || l_personal_aw_nm;
            if (not zpb_aw.interpbool('shw aw(exists ''' || l_personal_aw_nmq ||''')')) then
              b_start_aw_daemon := true;
            end if;
          end if;
        end if;

      end if;
   END LOOP;

   if (b_commit) then
      ZPB_AW.EXECUTE ('update');
      commit;
   end if;

   ZPB_AW.DETACH_ALL;

   --update the tasks table
   update zpb_writeback_tasks set
      status = COMPLETED, completion_date = SYSDATE,
      LAST_UPDATED_BY =  fnd_global.USER_ID, LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATE_LOGIN = fnd_global.LOGIN_ID
      where task_seq = last_task;

   --remove records timed by ZPB_WRITEBACK_TABLE_NUMBER_OF_DAYS profile
   l_remove_old_records;

   IF (l_task_type = UMAINT and b_start_aw_daemon) THEN
    l_request_id := FND_REQUEST.SUBMIT_REQUEST (application => 'ZPB',
                                                 program => 'ZPB_CREATE_PERS_AW_DAEMON',
                                                 description => null,
                                                 start_time => null,
                                                 sub_request => FALSE,
                                                 argument1 => p_task_seq);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      retcode :='2';
END process_spl;

FUNCTION get_run_pend_req_count
RETURN NUMBER
IS
  -- Cursor to get the number of INACTIVE, PENDING and RUNNING
  -- 'ZPB: Create Personal Analytic Workspace' requests at a
  -- given time.
  CURSOR l_run_pend_req_csr
  IS
  SELECT COUNT(*)
  FROM fnd_concurrent_requests
  WHERE concurrent_program_id = (SELECT concurrent_program_id
                                 FROM   fnd_concurrent_programs
                                 WHERE  concurrent_program_name = 'ZPB_CREATE_PERSONAL_AW')
  AND phase_code in ('I','P','R');

  l_count  NUMBER := 0;
BEGIN

  OPEN l_run_pend_req_csr;
  FETCH l_run_pend_req_csr INTO l_count;
  CLOSE l_run_pend_req_csr;

  RETURN l_count;

END get_run_pend_req_count;

PROCEDURE process_create_pers_aw_daemon (errbuf             OUT NOCOPY VARCHAR2,
                                         retcode            OUT NOCOPY VARCHAR2,
                                         p_task_seq         IN NUMBER)
IS
  CURSOR users_csr
  IS
  SELECT DISTINCT b.qdr,
         a.business_area_id
  FROM   zpb_writeback_tasks a,
         zpb_writeback_transaction b
  WHERE  b.task_seq = a.task_seq
  AND    a.task_seq = p_task_seq
  AND    a.task_type = 'UM';

  l_curr_conc_req_count   NUMBER;
  l_max_conc_req_count    NUMBER;
  l_request_id            NUMBER;
  l_start                 NUMBER;
  l_end                   NUMBER;
  l_user_id               VARCHAR2(30);
  l_personal_aw_nm        zpb_users.personal_aw%type;
  l_personal_aw_nmq       zpb_users.personal_aw%type;
  b_start_aw_cr_daemon    boolean;


BEGIN

   l_max_conc_req_count := fnd_profile.value('ZPB_MAX_CREATE_PERS_AW_REQUESTS');

   FOR users_rec IN users_csr LOOP
        b_start_aw_cr_daemon := false;
        l_curr_conc_req_count := get_run_pend_req_count();

        WHILE l_curr_conc_req_count > l_max_conc_req_count LOOP

          l_curr_conc_req_count := get_run_pend_req_count();

        END LOOP;

        l_start := instr(users_rec.qdr, '(');
        l_end := instr(users_rec.qdr, ',');
        l_user_id := substr(users_rec.qdr, l_start+2, l_end - l_start - 3);

        -- Ensure aw does not exist before launching request
        -- null test added for 10g only
        l_personal_aw_nm := ZPB_AW.GET_PERSONAL_AW (l_user_id);
        if(l_personal_aw_nm is null) then
           b_start_aw_cr_daemon := true;
        else
          l_personal_aw_nmq := ZPB_AW.GET_SCHEMA || '.' || l_personal_aw_nm;
          if (not zpb_aw.interpbool('shw aw(exists ''' || l_personal_aw_nmq ||''')')) then
            b_start_aw_cr_daemon := true;
          end if;
        end if;

        if b_start_aw_cr_daemon then
           l_request_id := fnd_request.submit_request (application => 'ZPB',
                                                       program => 'ZPB_CREATE_PERSONAL_AW',
                                                       description => null,
                                                       start_time => null,
                                                       sub_request => FALSE,
                                                       argument1 => l_user_id,
                                                       argument2 => users_rec.business_area_id);
        end if;

        COMMIT;
   END LOOP;
END process_create_pers_aw_daemon;

PROCEDURE process_create_personal_aw (errbuf             OUT NOCOPY VARCHAR2,
                                      retcode            OUT NOCOPY VARCHAR2,
                                      p_user_id          IN NUMBER,
                                      p_business_area_id IN NUMBER)
IS
  l_user_account_state      VARCHAR2(12);
  x_has_read_acc            NUMBER;
  l_has_read_acc            VARCHAR2(12) := 'HAS_READ_ACC';
  l_api_version             NUMBER := 1.0;
  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(4000);
  b_commit                  BOOLEAN := TRUE;

BEGIN

  UPDATE zpb_account_states
  SET has_read_access = 0
  WHERE business_area_id = p_business_area_id
  AND user_id = p_user_id;

  COMMIT;

  errbuf := ' ';
  retcode := '0';
  zpb_personal_aw.aw_create (p_user_id, p_business_area_id);

  zpb_security_util_pvt.validate_user(p_user_id,
                                      p_business_area_id,
                                      l_api_version,
                                      FND_API.G_FALSE,
                                      FND_API.G_FALSE,
                                      FND_API.G_VALID_LEVEL_FULL,
                                      l_user_account_state,
                                      l_return_status,
                                      l_msg_count,
                                      l_msg_data);

  IF (l_user_account_state = l_has_read_acc) THEN
    x_has_read_acc := 1;
  ELSE
    x_has_read_acc := 0;
  END IF;

  UPDATE zpb_account_states
  SET has_read_access = x_has_read_acc
  WHERE user_id = p_user_id
  AND business_area_id = p_business_area_id;

  IF (b_commit) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
     fnd_message.set_name('ZPB','ZPB_WRITEMGR_AW_CREATE_FAILED');
     fnd_file.put_line(FND_FILE.LOG, FND_MESSAGE.GET);

     retcode := 2;

END process_create_personal_aw;

PROCEDURE bulk_writeback(p_business_area_id IN NUMBER,
                         p_root_request_id  IN NUMBER,
                         p_child_request_id OUT NOCOPY NUMBER)
IS
   req_id NUMBER;

BEGIN
     req_id := fnd_request.submit_request ('ZPB',
                                           'ZPB_DO_WRTBK',
					   NULL,
					   NULL,
					   FALSE,
					   NULL,
					   p_root_request_id,
					   p_business_area_id);
     p_child_request_id := req_id;

EXCEPTION
  WHEN others THEN
    fnd_file.put_line(FND_FILE.LOG, 'Error occurred while launching ZPB: Data Ownership Writeback process.');
    p_child_request_id := -1;

END bulk_writeback;

END ZPB_AW_WRITE_BACK;


/
