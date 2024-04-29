--------------------------------------------------------
--  DDL for Package Body FND_DIAG_REQUEST_ANALYZER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DIAG_REQUEST_ANALYZER" AS
/* $Header: AFCPDRAB.pls 120.0.12010000.1 2009/06/19 16:16:28 ggupta noship $*/
  str_error VARCHAR2(2000);
  str_fix_info VARCHAR2(2000);

  FUNCTION get_status(p_status_code VARCHAR2) RETURN VARCHAR2 AS
  c_status fnd_lookups.meaning%TYPE;
  BEGIN
    SELECT nvl(meaning,   'UNKNOWN')
    INTO c_status
    FROM fnd_lookups
    WHERE lookup_type = 'CP_STATUS_CODE'
     AND lookup_code = p_status_code;
    RETURN RTRIM(c_status);
  END get_status;
  FUNCTION get_phase(p_phase_code VARCHAR2) RETURN VARCHAR2 AS
  c_phase fnd_lookups.meaning%TYPE;
  BEGIN
    SELECT nvl(meaning,   'UNKNOWN')
    INTO c_phase
    FROM fnd_lookups
    WHERE lookup_type = 'CP_PHASE_CODE'
     AND lookup_code = p_phase_code;
    RETURN RTRIM(c_phase);
  END get_phase;
  PROCEDURE manager_check(req_id IN NUMBER,   cd_id IN NUMBER,   mgr_defined OUT nocopy boolean,   mgr_active OUT nocopy boolean,   mgr_workshift OUT nocopy boolean,   mgr_running OUT nocopy boolean,   run_alone OUT nocopy boolean) IS
  CURSOR mgr_cursor(rid NUMBER) IS
  SELECT running_processes,
    max_processes,
    decode(control_code,   'T',   'N',   -- Abort
  'X',   'N',   -- Aborted
  'D',   'N',   -- Deactivate
  'E',   'N',   -- Deactivated
  'Y') active
  FROM fnd_concurrent_worker_requests
  WHERE request_id = rid
   AND NOT((queue_application_id = 0)
   AND(concurrent_queue_id IN(1,   4)));
  run_alone_flag VARCHAR2(1);
  BEGIN
    mgr_defined := FALSE;
    mgr_active := FALSE;
    mgr_workshift := FALSE;
    mgr_running := FALSE;
    FOR mgr_rec IN mgr_cursor(req_id)
    LOOP
      mgr_defined := TRUE;

      IF(mgr_rec.active = 'Y') THEN
        mgr_active := TRUE;

        IF(mgr_rec.max_processes > 0) THEN
          mgr_workshift := TRUE;
        END IF;

        IF(mgr_rec.running_processes > 0) THEN
          mgr_running := TRUE;
        END IF;

      END IF;

    END LOOP;

    IF(cd_id IS NULL) THEN
      run_alone_flag := 'N';
    ELSE
      SELECT runalone_flag
      INTO run_alone_flag
      FROM fnd_conflicts_domain d
      WHERE d.cd_id = manager_check.cd_id;
    END IF;

    IF(run_alone_flag = 'Y') THEN
      run_alone := TRUE;
    ELSE
      run_alone := FALSE;
    END IF;

  END manager_check;

  PROCEDURE print_mgrs(p_req_id IN NUMBER,   inner_section IN OUT nocopy jtf_diag_section,   reportcontext IN jtf_diag_report_context) AS
  note jtf_diag_note;
  CURSOR c_mgrs(rid NUMBER) IS
  SELECT user_concurrent_queue_name name,
    fcwr.running_processes active,
    decode(fcwr.control_code,   'A',   fl.meaning,   'D',   fl.meaning,   'E',   fl.meaning,   'N',   fl.meaning,   'R',   fl.meaning,   'T',
	fl.meaning,   'U',   fl.meaning,   'V',   fl.meaning,   'X',   fl.meaning,   NULL,   'Running',   '** Unknown Status **') status
  FROM fnd_concurrent_queues_vl fcqv,
    fnd_concurrent_worker_requests fcwr,
    fnd_lookups fl
  WHERE fcwr.request_id = rid
   AND fcwr.concurrent_queue_id = fcqv.concurrent_queue_id
   AND fcwr.concurrent_queue_id NOT IN(1,   4)
   AND fl.lookup_code(+) = fcwr.control_code
   AND fl.lookup_type(+) = 'CP_CONTROL_CODE';

  BEGIN
    FOR mgr_rec IN c_mgrs(p_req_id)
    LOOP
      note := jtf_diag_report_factory.create_note('- ' || mgr_rec.name || ' | Status: ' || mgr_rec.status || ' (' || mgr_rec.active || ' active processes)',   reportcontext);
      inner_section.add_note(note);
    END LOOP;

  END print_mgrs;

  PROCEDURE runtest(exec_obj IN OUT jtf_diag_execution_obj,   result OUT nocopy VARCHAR2) IS
  -- its a collection of inputs for a particular execution of the test
  allinputs jtf_diag_inputtbl;
  -- a report object provided by the framework to produce a well managed report
  -- of the test execution
  report jtf_diag_report_obj;
  -- this context is needed for creation of different component in the report
  reportcontext jtf_diag_report_context;
  -- section component which will be a container of other component in the report
  SECTION jtf_diag_section;
  inner_section jtf_diag_section;
  -- message of type info, warning, error can be put inside a report
  message jtf_diag_message;
  -- note component
  note jtf_diag_note;
  -- hide show component to be displayed in a report
  hideshow jtf_diag_hide_show;
  -- table component to be displayed in report
  table1 jtf_diag_table;
  -- footer in a report
  footer jtf_diag_footer;
  -- header to be displayed in  a report
  header1 jtf_diag_header;
  --form view component
  form_view jtf_diag_form;
  form_keys jtf_varchar2_table_4000;
  form_values jtf_varchar2_table_4000;
  str_query VARCHAR2(2000);
  str VARCHAR2(2000);
  -- CP Request Analyser
  p_req_id NUMBER;
  reqinfo fnd_concurrent_requests % rowtype;
  proginfo fnd_concurrent_programs_vl % rowtype;
  c_status fnd_lookups.meaning%TYPE;
  m_buf fnd_lookups.meaning%TYPE;
  conc_prog_name fnd_concurrent_programs.concurrent_program_name%TYPE;
  exe_method_code fnd_concurrent_programs_vl.execution_method_code%TYPE;
  conc_app_name fnd_application_vl.application_name%TYPE;
  tmp_id NUMBER(15);
  tmp_status fnd_concurrent_requests.status_code%TYPE;
  tmp_date DATE;
  conc_app_id fnd_concurrent_requests.program_application_id%TYPE;
  conc_id fnd_concurrent_requests.concurrent_program_id%TYPE;
  conc_cd_id fnd_concurrent_requests.cd_id%TYPE;
  v_enabled_flag fnd_concurrent_programs.enabled_flag%TYPE;
  conflict_domain fnd_conflicts_domain.user_cd_name%TYPE;
  parent_id NUMBER(15);
  resp_name VARCHAR2(100);
  rclass_name fnd_concurrent_request_class.request_class_name%TYPE;
  exe_file_name fnd_executables.execution_file_name%TYPE;
  c_user fnd_user.user_name%TYPE;
  last_user fnd_user.user_name%TYPE;
  fcd_phase VARCHAR2(48);
  fcd_status VARCHAR2(48);
  traid fnd_concurrent_requests.program_application_id%TYPE;
  trcpid fnd_concurrent_requests.concurrent_program_id%TYPE;
  icount NUMBER;
  ireqid fnd_concurrent_requests.request_id%TYPE;
  pcode fnd_concurrent_requests.phase_code%TYPE;
  scode fnd_concurrent_requests.status_code%TYPE;
  live_child boolean;
  mgr_defined boolean;
  mgr_active boolean;
  mgr_workshift boolean;
  mgr_running boolean;
  run_alone boolean;
  reqlimit boolean := FALSE;
  mgrname fnd_concurrent_queues_vl.user_concurrent_queue_name%TYPE;
  filename VARCHAR2(255);
  qcf fnd_concurrent_programs.queue_control_flag%TYPE;
  req_notfound

   EXCEPTION;

  CURSOR c_wait IS
  SELECT request_id,
    phase_code,
    status_code
  FROM fnd_concurrent_requests
  WHERE parent_request_id = p_req_id;
  CURSOR c_inc IS
  SELECT to_run_application_id,
    to_run_concurrent_program_id
  FROM fnd_concurrent_program_serial
  WHERE running_application_id = conc_app_id
   AND running_concurrent_program_id = conc_id;
  CURSOR c_ireqs IS
  SELECT request_id,
    phase_code,
    status_code
  FROM fnd_concurrent_requests
  WHERE phase_code = 'R'
   AND program_application_id = traid
   AND concurrent_program_id = trcpid
   AND cd_id = conc_cd_id;
  CURSOR c_userreqs(uid NUMBER,   s DATE) IS
  SELECT request_id,
    to_char(requested_start_date,   'DD-MON-RR HH24:MI:SS') start_date,
    phase_code,
    status_code
  FROM fnd_concurrent_requests
  WHERE phase_code IN('R',   'P')
   AND requested_by = uid
   AND requested_start_date < s
   AND hold_flag = 'N';
  BEGIN
    -- report obj
    report := exec_obj.get_report;
    -- To get the report context to create other components for the report
    reportcontext := report.get_report_context;
    -- Creating a header of the report
    header1 := jtf_diag_report_factory.create_header('CP Diagnostic Request Analyzer',   reportcontext);
    -- Adding the header to the report
    report.add_header(header1);

    SECTION := jtf_diag_report_factory.create_section('Analyzing request ' || p_req_id || ':',   reportcontext);

    -- Taking request id from the user
    allinputs := exec_obj.inputset;
    p_req_id := to_number(jtf_diagnostic_adaptutil.getinputvalue('RequestId',   allinputs));

    BEGIN
      SELECT *
      INTO reqinfo
      FROM fnd_concurrent_requests
      WHERE request_id = p_req_id;

    EXCEPTION
    WHEN no_data_found THEN
      result := 'false';
      -- Creating a message component and adding it to a section
      str_error := 'Request ' || p_req_id || ' not found.';
      str_fix_info := 'Please Enter the valid Request Id';
      message := jtf_diag_report_factory.create_message(str_error,   'error',   reportcontext);
      SECTION.add_message(message);
      GOTO endoffile;
    END;

    SELECT fvl.*
    INTO proginfo
    FROM fnd_concurrent_programs_vl fvl,
      fnd_concurrent_requests fcr
    WHERE fcr.request_id = p_req_id
     AND fcr.concurrent_program_id = fvl.concurrent_program_id
     AND fcr.program_application_id = fvl.application_id;

    SELECT nvl(application_name,   '-- UNKNOWN APPLICATION --')
    INTO conc_app_name
    FROM fnd_application_vl fvl,
      fnd_concurrent_requests fcr
    WHERE fcr.request_id = p_req_id
     AND fcr.program_application_id = fvl.application_id;

    SELECT nvl(meaning,   'UNKNOWN')
    INTO m_buf
    FROM fnd_lookups
    WHERE lookup_type = 'CP_EXECUTION_METHOD_CODE'
     AND lookup_code = proginfo.execution_method_code;

    SELECT nvl(execution_file_name,   'NONE')
    INTO exe_file_name
    FROM fnd_executables
    WHERE application_id = proginfo.executable_application_id
     AND executable_id = proginfo.executable_id;

    form_keys := jtf_varchar2_table_4000('Program',   'Application',   'Executable type',   'Executable file name or procedure',
	'Run alone flag',   'SRS flag',   'NLS compliant',   'Output file type');
    form_values := jtf_varchar2_table_4000(proginfo.user_concurrent_program_name || '  (' || proginfo.concurrent_program_name || ')',   conc_app_name,
	m_buf || '  (' || proginfo.execution_method_code || ')',   exe_file_name,   proginfo.run_alone_flag,   proginfo.srs_flag,   proginfo.nls_compliant,   proginfo.output_file_type);

    IF proginfo.concurrent_class_id IS NOT NULL THEN
      SELECT request_class_name
      INTO rclass_name
      FROM fnd_concurrent_request_class
      WHERE application_id = proginfo.class_application_id
       AND request_class_id = proginfo.concurrent_class_id;
      form_keys.extend;
      form_keys(form_keys.COUNT) := 'Request type';
      form_values.extend;
      form_values(form_values.COUNT) := rclass_name;
    END IF;

    IF proginfo.execution_options IS NOT NULL THEN
      form_keys.extend;
      form_keys(form_keys.COUNT) := 'Execution options';
      form_values.extend;
      form_values(form_values.COUNT) := proginfo.execution_options;
    END IF;

    form_view := jtf_diag_report_factory.create_form('Program information',   form_keys,   form_values,   reportcontext);
    SECTION.add_form(form_view);

    IF proginfo.enable_trace = 'Y' THEN
      inner_section := jtf_diag_report_factory.create_section('Note:',   reportcontext);
      note := jtf_diag_report_factory.create_note('SQL Trace has been enabled for this program.',   reportcontext);
      inner_section.add_note(note);
      SECTION.add_section(inner_section);
    END IF;

    -- Submission information
    BEGIN
      SELECT user_name
      INTO c_user
      FROM fnd_user
      WHERE user_id = reqinfo.requested_by;

    EXCEPTION
    WHEN no_data_found THEN
      c_user := '-- UNKNOWN USER --';
    END;

    BEGIN
      SELECT user_name
      INTO last_user
      FROM fnd_user
      WHERE user_id = reqinfo.last_updated_by;

    EXCEPTION
    WHEN no_data_found THEN
      last_user := '-- UNKNOWN USER --';
    END;

    SELECT responsibility_name
    INTO resp_name
    FROM fnd_responsibility_vl
    WHERE responsibility_id = reqinfo.responsibility_id
     AND application_id = reqinfo.responsibility_application_id;

    form_keys := jtf_varchar2_table_4000('It was submitted by user',   'Using responsibility',   'It was submitted on',   'It was requested to start on',   'Parent request id',   'Language',   'Territory',   'Priority',   'Arguments');
    form_values := jtf_varchar2_table_4000(c_user,   resp_name,   to_char(reqinfo.request_date,   'DD-MON-RR HH24:MI:SS'),   to_char(reqinfo.requested_start_date,   'DD-MON-RR HH24:MI:SS'),
	reqinfo.parent_request_id,   reqinfo.nls_language,   reqinfo.nls_territory,   to_char(reqinfo.priority),   '(' || reqinfo.number_of_arguments || '): ' || reqinfo.argument_text);
    form_view := jtf_diag_report_factory.create_form('Submission information',   form_keys,   form_values,   reportcontext);
    SECTION.add_form(form_view);

    c_status := get_status(reqinfo.status_code);

    inner_section := jtf_diag_report_factory.create_section('Analysis',   reportcontext);

    IF reqinfo.phase_code = 'C' THEN
      note := jtf_diag_report_factory.create_note('Request ' || p_req_id || ' has completed with status "' || c_status || '".',   reportcontext);
      inner_section.add_note(note);
      note := jtf_diag_report_factory.create_note('It began running on: ' || nvl(to_char(reqinfo.actual_start_date,   'DD-MON-RR HH24:MI:SS'),   '-- NO START DATE --'),   reportcontext);
      inner_section.add_note(note);
      note := jtf_diag_report_factory.create_note('It completed on: ' || nvl(to_char(reqinfo.actual_completion_date,   'DD-MON-RR HH24:MI:SS'),   '-- NO COMPLETION DATE --'),   reportcontext);
      inner_section.add_note(note);

      BEGIN
        SELECT user_concurrent_queue_name
        INTO mgrname
        FROM fnd_concurrent_queues_vl
        WHERE concurrent_queue_id = reqinfo.controlling_manager;
        note := jtf_diag_report_factory.create_note('It was run by manager: ' || mgrname,   reportcontext);
        inner_section.add_note(note);

      EXCEPTION
      WHEN no_data_found THEN
        SELECT queue_control_flag
        INTO qcf
        FROM fnd_concurrent_programs
        WHERE concurrent_program_id = reqinfo.concurrent_program_id
         AND application_id = reqinfo.program_application_id;

        IF qcf = 'Y' THEN
          note := jtf_diag_report_factory.create_note('This request is a queue control request, it was run by the ICM',   reportcontext);
        ELSE
          note := jtf_diag_report_factory.create_note('It was run by an unknown manager.',   reportcontext);
        END IF;

        inner_section.add_note(note);
      END;

      SELECT nvl(reqinfo.logfile_name,   '-- No logfile --')
      INTO filename
      FROM dual;
      note := jtf_diag_report_factory.create_note('Logfile: ' || filename,   reportcontext);
      inner_section.add_note(note);
      SELECT nvl(reqinfo.outfile_name,   '-- No output file --')
      INTO filename
      FROM dual;
      note := jtf_diag_report_factory.create_note('Output file: ' || filename,   reportcontext);
      inner_section.add_note(note);
      note := jtf_diag_report_factory.create_note('It produced completion message: ' || nvl(reqinfo.completion_text,   '-- NO COMPLETION MESSAGE --'),   reportcontext);
      inner_section.add_note(note);
      ELSIF reqinfo.phase_code = 'R' THEN
        note := jtf_diag_report_factory.create_note('Request ' || p_req_id || ' is currently running with status "' || c_status || '".',   reportcontext);
        inner_section.add_note(note);
        note := jtf_diag_report_factory.create_note('It began running on: ' || nvl(to_char(reqinfo.actual_start_date,   'DD-MON-RR HH24:MI:SS'),   '-- NO START DATE --'),   reportcontext);
        inner_section.add_note(note);
        BEGIN
          SELECT user_concurrent_queue_name
          INTO mgrname
          FROM fnd_concurrent_queues_vl
          WHERE concurrent_queue_id = reqinfo.controlling_manager;
          note := jtf_diag_report_factory.create_note('It is being run by manager: ' || mgrname,   reportcontext);
          inner_section.add_note(note);

        EXCEPTION
        WHEN no_data_found THEN
          NULL;
        END;

        SELECT nvl(reqinfo.logfile_name,   '-- No logfile --')
        INTO filename
        FROM dual;
        note := jtf_diag_report_factory.create_note('Logfile: ' || filename,   reportcontext);
        inner_section.add_note(note);
        SELECT nvl(reqinfo.outfile_name,   '-- No output file --')
        INTO filename
        FROM dual;
        note := jtf_diag_report_factory.create_note('Output file: ' || filename,   reportcontext);
        inner_section.add_note(note);

        IF reqinfo.os_process_id IS NOT NULL THEN
          note := jtf_diag_report_factory.create_note('OS process id: ' || reqinfo.os_process_id,   reportcontext);
          inner_section.add_note(note);
        END IF;

        IF reqinfo.status_code = 'Z' THEN

          -- Waiting request, See what it is waiting on
          FOR child IN c_wait
          LOOP

            note := jtf_diag_report_factory.create_note('It is waiting on request ' || child.request_id || ' phase = ' || get_phase(child.phase_code) || ' status = ' || get_status(child.status_code),   reportcontext);
            inner_section.add_note(note);
          END LOOP;

          ELSIF reqinfo.status_code = 'W' THEN

            -- Paused, check and see if it is a request set, and if its children are running
            SELECT nvl(concurrent_program_name,   'UNKNOWN')
            INTO conc_prog_name
            FROM fnd_concurrent_programs
            WHERE concurrent_program_id = reqinfo.concurrent_program_id;

            note := jtf_diag_report_factory.create_note('A Running/Paused request is waiting on one or more child requests to complete.',   reportcontext);
            inner_section.add_note(note);

            IF conc_prog_name = 'FNDRSSTG' THEN
              note := jtf_diag_report_factory.create_note('This program appears to be a Request Set Stage.',   reportcontext);
              inner_section.add_note(note);
            END IF;

            IF instr(conc_prog_name,   'RSSUB') > 0 THEN
              note := jtf_diag_report_factory.create_note('This program appears to be a Request Set parent program.',   reportcontext);
              inner_section.add_note(note);
            END IF;

            live_child := FALSE;
            FOR child IN c_wait
            LOOP

              note := jtf_diag_report_factory.create_note('It has a child request: ' || child.request_id || ' (phase = ' || get_phase(child.phase_code) || ' - status = ' || get_status(child.status_code) || ')',   reportcontext);
              inner_section.add_note(note);

              IF child.phase_code <> 'C' THEN
                live_child := TRUE;
              END IF;

            END LOOP;

            IF live_child = FALSE THEN
              str_error := 'This request has no child requests that are still running.';
              str_fix_info := 'You need to wake this request up manually.';
              message := jtf_diag_report_factory.create_message(str_error || str_fix_info,   'error',   reportcontext);
              SECTION.add_message(message);
              result := 'false';
              GOTO endoffile;
            END IF;

          END IF;

          -- Pending Requests
          -------------------------------------------------------------------------------------------------------------
          ELSIF reqinfo.phase_code = 'P' THEN

            note := jtf_diag_report_factory.create_note('Request ' || p_req_id || ' is in phase "Pending" with status "' || c_status || '".',   reportcontext);
            inner_section.add_note(note);
            note := jtf_diag_report_factory.create_note('                           (phase_code = P)   (status_code = ' || reqinfo.status_code || ')',   reportcontext);
            inner_section.add_note(note);

            -- could be a queue control request
            SELECT queue_control_flag
            INTO qcf
            FROM fnd_concurrent_programs
            WHERE concurrent_program_id = reqinfo.concurrent_program_id
             AND application_id = reqinfo.program_application_id;

            IF qcf = 'Y' THEN
              note := jtf_diag_report_factory.create_note('This request is a queue control request',   reportcontext);
              inner_section.add_note(note);
              note := jtf_diag_report_factory.create_note('It will be run by the ICM on its next sleep cycle',   reportcontext);
              inner_section.add_note(note);
              GOTO diagnose;
            END IF;

            -- why is it pending?

            -- could be scheduled

            IF reqinfo.requested_start_date > sysdate OR reqinfo.status_code = 'P' THEN
              note := jtf_diag_report_factory.create_note('This is a scheduled request.',   reportcontext);
              inner_section.add_note(note);
              note := jtf_diag_report_factory.create_note('It is currently scheduled to start running on ' || to_char(reqinfo.requested_start_date,   'DD-MON-RR HH24:MI:SS'),   reportcontext);
              inner_section.add_note(note);
              note := jtf_diag_report_factory.create_note('This should show on the form as Pending/Scheduled',   reportcontext);
              inner_section.add_note(note);
              GOTO diagnose;
            END IF;

            -- could be on hold

            IF reqinfo.hold_flag = 'Y' THEN
              note := jtf_diag_report_factory.create_note('This request is currently on hold. It will not run until the hold is released.',   reportcontext);
              inner_section.add_note(note);
              note := jtf_diag_report_factory.create_note('It was placed on hold by: ' || last_user || ' on ' || to_char(reqinfo.last_update_date,   'DD-MON-RR HH24:MI:SS'),   reportcontext);
              inner_section.add_note(note);
              note := jtf_diag_report_factory.create_note('This should show on the form as Inactive/On Hold',   reportcontext);
              inner_section.add_note(note);
              GOTO diagnose;
            END IF;

            -- could be disabled

            IF proginfo.enabled_flag = 'N' THEN
              note := jtf_diag_report_factory.create_note('This request is currently disabled.',   reportcontext);
              inner_section.add_note(note);
              note := jtf_diag_report_factory.create_note('The concurrent_program ' || proginfo.user_concurrent_program_name || ' needs to be enabled for this request to run.',   reportcontext);
              inner_section.add_note(note);
              note := jtf_diag_report_factory.create_note('This should show on the form as Inactive/Disabled',   reportcontext);
              inner_section.add_note(note);
              GOTO diagnose;
            END IF;

            -- check queue_method_code
            -- unconstrained requests

            IF reqinfo.queue_method_code = 'I' THEN
              note := jtf_diag_report_factory.create_note('This request is an unconstrained request. (queue_method_code = I)',   reportcontext);
              inner_section.add_note(note);

              IF reqinfo.status_code = 'I' THEN
                note := jtf_diag_report_factory.create_note('It is in a "Pending/Normal" status, ready to be run by the next available manager.',   reportcontext);
                inner_section.add_note(note);
                ELSIF reqinfo.status_code = 'Q' THEN
                  note := jtf_diag_report_factory.create_note('It has a status of "Standby" even though it is unconstrained. It will not be run by any manager.',   reportcontext);
                  inner_section.add_note(note);
                  ELSIF reqinfo.status_code IN('A',   'Z') THEN
                    note := jtf_diag_report_factory.create_note('It is in a "Waiting" status. This usually indicates a child request waiting for the parent to release it.',   reportcontext);
                    inner_section.add_note(note);
                    SELECT nvl(parent_request_id,   -1)
                    INTO parent_id
                    FROM fnd_conc_req_summary_v
                    WHERE request_id = p_req_id;

                    IF parent_id = -1 THEN
                      note := jtf_diag_report_factory.create_note('** Unable to find a parent request for this request',   reportcontext);
                      inner_section.add_note(note);
                    ELSE
                      note := jtf_diag_report_factory.create_note('It''s parent request id is: ' || to_char(parent_id),   reportcontext);
                      inner_section.add_note(note);
                    END IF;

                  ELSE
                    str_error := 'Unexpected status of ' || reqinfo.status_code || ' occurred';
                    str_fix_info := ' Please contact System Administrator';
                    message := jtf_diag_report_factory.create_message(str_error || str_fix_info,   'error',   reportcontext);
                    SECTION.add_message(message);
                    result := 'false';
                    GOTO endoffile;
                  END IF;

                  -- constrained requests
                  ELSIF reqinfo.queue_method_code = 'B' THEN
                    note := jtf_diag_report_factory.create_note('This request is a constrained request. (queue_method_code = B)',   reportcontext);
                    inner_section.add_note(note);

                    IF reqinfo.status_code = 'I' THEN
                      note := jtf_diag_report_factory.create_note('The Conflict Resolution manager has released this request, and it is in a "Pending/Normal" status.',   reportcontext);
                      inner_section.add_note(note);
                      note := jtf_diag_report_factory.create_note('It is ready to be run by the next available manager.',   reportcontext);
                      inner_section.add_note(note);
                      ELSIF reqinfo.status_code = 'Q' THEN
                        note := jtf_diag_report_factory.create_note('It is in a "Pending/Standby" status. The Conflict Resolution manager will need to release it before it can be run.',   reportcontext);
                        inner_section.add_note(note);
                        ELSIF reqinfo.status_code IN('A',   'Z') THEN
                          note := jtf_diag_report_factory.create_note('It is in a "Waiting" status. This usually indicates a child request waiting for the parent to release it.',   reportcontext);
                          inner_section.add_note(note);
                          SELECT nvl(parent_request_id,   -1)
                          INTO parent_id
                          FROM fnd_conc_req_summary_v
                          WHERE request_id = p_req_id;

                          IF parent_id = -1 THEN
                            note := jtf_diag_report_factory.create_note('** Unable to find a parent request for this request',   reportcontext);
                            inner_section.add_note(note);
                          ELSE
                            note := jtf_diag_report_factory.create_note('It''s parent request id is: ' || to_char(parent_id),   reportcontext);
                            inner_section.add_note(note);
                          END IF;

                        ELSE
                          note := jtf_diag_report_factory.create_note('Hmmm. A status of ' || reqinfo.status_code || '. I was not really expecting to see this status.',   reportcontext);
                          inner_section.add_note(note);
                        END IF;

                        -- incompatible programs
                        SELECT program_application_id,
                          concurrent_program_id,
                          cd_id
                        INTO conc_app_id,
                          conc_id,
                          conc_cd_id
                        FROM fnd_concurrent_requests
                        WHERE request_id = p_req_id;

                        icount := 0;
                        FOR progs IN c_inc
                        LOOP

                          traid := progs.to_run_application_id;
                          trcpid := progs.to_run_concurrent_program_id;

                          OPEN c_ireqs;
                          LOOP

                            FETCH c_ireqs
                            INTO ireqid,
                              pcode,
                              scode;
                            EXIT
                          WHEN c_ireqs % NOTFOUND;

                          note := jtf_diag_report_factory.create_note('Request ' || p_req_id || ' is waiting, or will have to wait, on an incompatible request: ' || ireqid,   reportcontext);
                          inner_section.add_note(note);
                          note := jtf_diag_report_factory.create_note('which has phase = ' || pcode || ' and status = ' || scode,   reportcontext);
                          inner_section.add_note(note);
                          icount := icount + 1;

                        END LOOP;

                        CLOSE c_ireqs;

                      END LOOP;

                      IF icount = 0 THEN
                        note := jtf_diag_report_factory.create_note('No running incompatible requests were found for request ' || p_req_id,   reportcontext);
                        inner_section.add_note(note);
                      END IF;

                      -- could be a runalone itself

                      IF proginfo.run_alone_flag = 'Y' THEN
                        note := jtf_diag_report_factory.create_note('This request is constrained because it is a runalone request.',   reportcontext);
                        inner_section.add_note(note);
                      END IF;

                      -- single threaded

                      IF reqinfo.single_thread_flag = 'Y' THEN
                        note := jtf_diag_report_factory.create_note('This request is constrained because the profile option Concurrent: Sequential Requests is set.',   reportcontext);
                        inner_section.add_note(note);
                        reqlimit := TRUE;
                      END IF;

                      -- request limit

                      IF reqinfo.request_limit = 'Y' THEN
                        note := jtf_diag_report_factory.create_note('This request is constrained because the profile option Concurrent: Active Request Limit is set.',   reportcontext);
                        inner_section.add_note(note);
                        reqlimit := TRUE;
                      END IF;

                      IF reqlimit = TRUE THEN
                        note := jtf_diag_report_factory.create_note('This request may have to wait on these requests:',   reportcontext);
                        inner_section.add_note(note);
                        FOR progs IN c_userreqs(reqinfo.requested_by,   reqinfo.requested_start_date)
                        LOOP
                          note := jtf_diag_report_factory.create_note('Request id: ' || progs.request_id || ' Requested start date: ' || progs.start_date,   reportcontext);
                          inner_section.add_note(note);
                          note := jtf_diag_report_factory.create_note('     Phase: ' || get_phase(progs.phase_code) || '   Status: ' || get_status(progs.status_code),   reportcontext);
                          inner_section.add_note(note);
                        END LOOP;
                      END IF;

                      -- error, invalid queue_method_code
                    ELSE
                      str_error := 'This request has an invalid queue_method_code of ' || reqinfo.queue_method_code || ' This request will not be run.';
                      str_fix_info := 'You may need to apply patch 739644';
                      message := jtf_diag_report_factory.create_message(str_error,   'error',   reportcontext);
                      inner_section.add_message(message);
                      message := jtf_diag_report_factory.create_message(str_fix_info,   'info',   reportcontext);
                      inner_section.add_message(message);
                      result := 'false';
                      SECTION.add_section(inner_section);
                      GOTO endoffile;
                    END IF;

                    note := jtf_diag_report_factory.create_note('Checking managers available to run this request...',   reportcontext);
                    inner_section.add_note(note);

                    -- check the managers
                    manager_check(p_req_id,   reqinfo.cd_id,   mgr_defined,   mgr_active,   mgr_workshift,   mgr_running,   run_alone);

                    -- could be a runalone ahead of it

                    IF run_alone = TRUE THEN
                      note := jtf_diag_report_factory.create_note('There is a runalone request running ahead of this request',   reportcontext);
                      inner_section.add_note(note);
                      note := jtf_diag_report_factory.create_note('This should show on the form as Inactive/No Manager',   reportcontext);
                      inner_section.add_note(note);

                      SELECT user_cd_name
                      INTO conflict_domain
                      FROM fnd_conflicts_domain
                      WHERE cd_id = reqinfo.cd_id;

                      note := jtf_diag_report_factory.create_note('Conflict domain = ' || conflict_domain,   reportcontext);
                      inner_section.add_note(note);
                      -- see what is running
                      BEGIN
                        SELECT request_id,
                          status_code,
                          actual_start_date
                        INTO tmp_id,
                          tmp_status,
                          tmp_date
                        FROM fnd_concurrent_requests fcr,
                          fnd_concurrent_programs fcp
                        WHERE fcp.run_alone_flag = 'Y'
                         AND fcp.concurrent_program_id = fcr.concurrent_program_id
                         AND fcr.phase_code = 'R'
                         AND fcr.cd_id = reqinfo.cd_id;

                        note := jtf_diag_report_factory.create_note('This request is waiting for request ' || tmp_id || ', which is running with status ' || get_status(tmp_status),   reportcontext);
                        inner_section.add_note(note);
                        note := jtf_diag_report_factory.create_note('It has been running since: ' || nvl(to_char(tmp_date,   'DD-MON-RR HH24:MI:SS'),   '-- NO START DATE --'),   reportcontext);
                        inner_section.add_note(note);

                      EXCEPTION
                      WHEN no_data_found THEN
                        str_error := 'The runalone flag is set for conflict domain ' || conflict_domain || ' but there is no runalone request running. ';
                        str_fix_info := 'Please contact System Administrator';
                        message := jtf_diag_report_factory.create_message(str_error || str_fix_info,   'error',   reportcontext);
                        SECTION.add_message(message);
                        result := 'false';
                        GOTO endoffile;
                      END;

                      ELSIF mgr_defined = FALSE THEN
                        str_error := 'There is no manager defined that can run this request. This should show on the form as Inactive/No Manager. ';
                        str_fix_info := 'Check the specialization rules for each manager to make sure they are defined correctly.';
                        message := jtf_diag_report_factory.create_message(str_error || str_fix_info,   'error',   reportcontext);
                        SECTION.add_message(message);
                        result := 'false';
                        GOTO endoffile;
                        ELSIF mgr_active = FALSE THEN
                          note := jtf_diag_report_factory.create_note('There are one or more managers defined that can run this request, but none of them are currently active',   reportcontext);
                          inner_section.add_note(note);
                          note := jtf_diag_report_factory.create_note('This should show on the form as Inactive/No Manager',   reportcontext);
                          inner_section.add_note(note);
                          -- print out which managers can run it and their status
                          note := jtf_diag_report_factory.create_note('These managers are defined to run this request:',   reportcontext);
                          inner_section.add_note(note);
                          print_mgrs(p_req_id,   inner_section,   reportcontext);

                          str_error := 'Inactive/No Manager. ';
                          str_fix_info := 'Please contact the System Administrator.';
                          message := jtf_diag_report_factory.create_message(str_error || str_fix_info,   'error',   reportcontext);
                          SECTION.add_message(message);
                          result := 'false';
                          GOTO endoffile;

                          ELSIF mgr_workshift = FALSE THEN
                            note := jtf_diag_report_factory.create_note('Right now, there is no manager running in an active workshift that can run this request',   reportcontext);
                            inner_section.add_note(note);
                            note := jtf_diag_report_factory.create_note('This should show on the form as Inactive/No Manager',   reportcontext);
                            inner_section.add_note(note);
                            -- display details about the workshifts
                            ELSIF mgr_running = FALSE THEN
                              note := jtf_diag_report_factory.create_note('There is one or more managers available to run this request, but none of them are running',   reportcontext);
                              inner_section.add_note(note);
                              note := jtf_diag_report_factory.create_note('This should show on the form as Inactive/No Manager',   reportcontext);
                              inner_section.add_note(note);
                              -- print out which managers can run it and their status
                              print_mgrs(p_req_id,   inner_section,   reportcontext);

                              str_error := 'Inactive/No Manager. ';
                              str_fix_info := 'Please contact the System Administrator.';
                              message := jtf_diag_report_factory.create_message(str_error || str_fix_info,   'error',   reportcontext);
                              SECTION.add_message(message);
                              result := 'false';
                              GOTO endoffile;

                            ELSE
                              -- print out the managers available to run it
                              note := jtf_diag_report_factory.create_note('These managers are available to run this request:',   reportcontext);
                              inner_section.add_note(note);
                              print_mgrs(p_req_id,   inner_section,   reportcontext);

                            END IF;

                            -- invalid phase code
                          ELSE
                            str_error := 'Request ' || p_req_id || ' has an invalid phase_code of "' || reqinfo.phase_code || '" ';
                            str_fix_info := '';
                            message := jtf_diag_report_factory.create_message(str_error || str_fix_info,   'error',   reportcontext);
                            SECTION.add_message(message);
                            result := 'false';
                            GOTO endoffile;

                          END IF;

                          << diagnose >> SECTION.add_section(inner_section);
                          -- Setting the out parameter 'result' to true to indicate the test is successfull
                          result := 'true';

                          << endoffile >> ---------------XYZ-----------------------
                          -- Adding the section to the report after constructing it completely.
                          report.add_section(SECTION);

                          -- Creating a custom footer for the report
                          str := 'Oracle corporation.';
                          footer := jtf_diag_report_factory.create_footer(str,   reportcontext);
                          -- Adding the footer to the report
                          report.add_footer(footer);

                        EXCEPTION
                        WHEN others THEN
                          str_error := 'Error number ' || SQLCODE || ' has occurred.' || ' Cause: ' || sqlerrm;
                          str_fix_info := 'Please contact system Administrator';
                          result := 'false';
                        END runtest;
                        -------------------------------------------------------------------------------------------------------------
                        -- procedure to set the description for the test.Framework will supply this information to the ui
                        -- before executing the test
                        -------------------------------------------------------------------------------------------------------------
                        PROCEDURE gettestdesc(str OUT nocopy VARCHAR2) IS
                        BEGIN
                          str := 'Analyze a concurrent request';
                        END gettestdesc;
                        -------------------------------------------------------------------------------------------------------------
                        -- procedure to set the name of the test
                        -------------------------------------------------------------------------------------------------------------
                        PROCEDURE gettestname(str OUT nocopy VARCHAR2) IS
                        BEGIN
                          str := 'Concurrent Request Analyzer';
                        END gettestname;
                        -------------------------------------------------------------------------------------------------------------
                        -- procedure to provide/populate  the default parameters for the test case.
                        -- The input name used must comply with the  XML id specification--namely it must begin with a [a-z][A-z]
                        -- and after that can contain as many of [a-z][A-Z][0-9][._-:] as desired.
                        -------------------------------------------------------------------------------------------------------------
                        PROCEDURE getdefaulttestparams(defaultinputvalues OUT nocopy jtf_diag_test_inputs) IS
                        tempinput jtf_diag_test_inputs;
                        BEGIN
                          tempinput := jtf_diagnostic_adaptutil.initialiseinput;
                          tempinput := jtf_diagnostic_adaptutil.addinput(tempinput,   'RequestId',   NULL,   'FALSE',   NULL,   'This is a Number input',   'FALSE',   'FALSE',   'TRUE');
                          defaultinputvalues := tempinput;

                        EXCEPTION
                        WHEN others THEN
                          defaultinputvalues := jtf_diagnostic_adaptutil.initialiseinput;
                        END getdefaulttestparams;
                        -------------------------------------------------------------------------------------------------------------
                        -- Procedure to report the framwork about the error has occured while running the test
                        -------------------------------------------------------------------------------------------------------------
                        PROCEDURE geterror(str OUT nocopy VARCHAR2) IS
                        BEGIN
                          str := str_error;
                        END geterror;
                        -------------------------------------------------------------------------------------------------------------
                        -- Procedure to report the framwork about the fix information if the test has failed
                        -------------------------------------------------------------------------------------------------------------
                        PROCEDURE getfixinfo(str OUT nocopy VARCHAR2) IS
                        BEGIN
                          str := str_fix_info;
                        END getfixinfo;
                        -------------------------------------------------------------------------------------------------------------
                        -- Procedure to report the framwork about the warning if any has occured while running the test
                        -------------------------------------------------------------------------------------------------------------
                        PROCEDURE iswarning(str OUT nocopy VARCHAR2) IS
                        BEGIN
                          str := 'false';
                        END iswarning;
                        -------------------------------------------------------------------------------------------------------------
                        -- Procedure to report the framwork about the sever error cases if any occured while running the test
                        -------------------------------------------------------------------------------------------------------------
                        PROCEDURE isfatal(str OUT nocopy VARCHAR2) IS
                        BEGIN
                          str := 'false';
                        END isfatal;
END fnd_diag_request_analyzer;

/
