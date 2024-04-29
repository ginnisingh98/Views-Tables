--------------------------------------------------------
--  DDL for Package Body XXAH_TASK_NOTIFY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_TASK_NOTIFY_PKG" AS

  gn_org_id                NUMBER        := FND_PROFILE.value('ORG_ID');
  gn_user_id               NUMBER        := FND_GLOBAL.user_id;
  gn_conc_request_id       NUMBER(15)    := FND_GLOBAL.conc_request_id;
  gc_appl_short_name       VARCHAR2(25)  := 'PA';
  gn_responsibility_id     NUMBER        := FND_GLOBAL.resp_id;
  gn_resp_appl_id          NUMBER        := fnd_global.RESP_APPL_ID;
  gc_application_shortname fnd_application.application_short_name%TYPE := FND_GLOBAL.application_short_name;
  gc_err_pos               VARCHAR2(1000);
  gc_debug_flag            VARCHAR2(1)   := 'Y';
  gn_application_id        NUMBER        := 275; -- PA

  ln_msg_count             NUMBER;


  -- return codes for concurent request
  gc_retcode_succes   CONSTANT NUMBER:= 0;
  gc_retcode_warning  CONSTANT NUMBER:= 1;
  gc_retcode_error    CONSTANT NUMBER:= 2;

  -- variables to handle submitted request and status
  lc_request_phase          VARCHAR2(2000);
  lc_request_status         VARCHAR2(2000);
  lc_dev_phase              VARCHAR2(2000);
  lc_dev_status             VARCHAR2(2000);
  lb_request_return_status  BOOLEAN;
  lc_req_message            VARCHAR2(2000);



PROCEDURE debug_print(
   p_print_flag  IN  VARCHAR2
  ,p_debug_mesg  IN  VARCHAR2
)
IS
BEGIN
  IF p_print_flag = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,p_debug_mesg);
  END IF;
END debug_print;


PROCEDURE send_message(
    p_recipient_name  wf_notifications.recipient_role%TYPE
  , p_task_id         pa_tasks.task_id%TYPE
  , p_message_subject VARCHAR2
  , p_message_body    VARCHAR2
)
IS
-- Original by Marc Smeenge

  v_itemtype CONSTANT wf_items.item_type%TYPE := 'ARSNDMSG';
  v_itemkey  wf_items.item_key%TYPE := to_char(sysdate
                                       ,'ddmmyyyy hh24:mi:ss');
  v_process CONSTANT wf_process_activities.process_name%TYPE :=
            'AR_SEND_MESSAGE_PROCESS';
  v_recipient wf_notifications.recipient_role%TYPE;
  v_request_id fnd_concurrent_requests.request_id%TYPE;
  v_program_id fnd_concurrent_programs.concurrent_program_id%TYPE;
  v_application_id fnd_concurrent_programs.application_id%TYPE;
  v_found BOOLEAN;
  v_session_id PLS_INTEGER;
BEGIN
  v_recipient:= p_recipient_name;

  wf_engine.CreateProcess(v_ItemType, v_ItemKey, v_process);
  wf_engine.SetItemAttrText
            (v_ItemType
            ,v_ItemKey
            ,'AR_MESSAGE_SUBJECT'
            -- ,'Test'
            ,p_message_subject
            );
  wf_engine.SetItemAttrText
            (v_ItemType
            ,v_ItemKey
            ,'AR_MESSAGE_BODY'
            -- ,'Dit is een test berichtje'
            , p_message_body
            );
  wf_engine.SetItemAttrText
            (v_ItemType
            ,v_ItemKey
            ,'AR_MESSAGE_RECIPIENT'
            ,v_recipient);
  wf_engine.StartProcess(v_ItemType, v_ItemKey);
  -- fnd_global.apps_initialize(0,20420,1);
  v_request_id := fnd_request.submit_request(
                application => 'FND'
               ,program => 'FNDWFBG'
               ,description => 'Task overdue notification using ARSNDMSG'
               ,argument1 => v_itemtype
               ,argument2 => NULL
               ,argument3 => NULL
               ,argument4 => 'Y'
               ,argument5 => 'Y'
               ,argument6 => NULL
               ,argument7 => chr(0)
               );

  IF v_request_id = 0 THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Failed to send task overdue notification to ' || p_recipient_name || ': ' || p_message_subject);
    COMMIT;
  ELSE
    -- needed to start the concurrent request
    COMMIT;

    -- wait for request to complete and check status
    lb_request_return_status := fnd_concurrent.wait_for_request(
                                                                request_id => v_request_id
                                                              , interval => 10
                                                              , max_wait => 0
                                                              , phase => lc_request_phase
                                                              , status => lc_request_status
                                                              , dev_phase => lc_dev_phase
                                                              , dev_status => lc_dev_status
                                                              , message => lc_req_message
                                                              );

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Request ' || to_char(v_request_id) || '(' || p_recipient_name || '): ' || p_message_subject);

    IF ((NOT (UPPER(lc_dev_status) = 'NORMAL' AND UPPER(lc_dev_phase) = 'COMPLETE')) OR (NOT (UPPER(lc_request_status) = 'NORMAL' AND UPPER(lc_request_phase) = 'COMPLETED')))
    THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Request ' || to_char(v_request_id) || '(' || p_recipient_name || '): completed with error');
    ELSE
    -- keep track of notified tasks
      INSERT INTO xxah_tasks_notified(
          task_id
        , notified_flag
      )
      VALUES(
          p_task_id
        , 'Y'
      );
    END IF;
    COMMIT;
  END IF;

END send_message;

PROCEDURE notify_all
(
    x_retbuf            OUT   VARCHAR2
  , x_retcode           OUT   NUMBER
)
IS
  ln_task_tbl_idx            NUMBER;
  ln_pa_task_id              NUMBER;

  ln_errcode                 NUMBER;
  ln_msg_index               NUMBER                  := -1;
  ln_msg_index_out           NUMBER;
  ln_msg_count               NUMBER;
  lc_msg_data                VARCHAR2(2000);
  lc_return_status           VARCHAR2(1);
  lc_return_msg              VARCHAR2(500);
  ln_return_msg              NUMBER;
  lc_errmsg                  VARCHAR2(4000);
  lc_data                    VARCHAR2(500)           := NULL;

  ln_person_id               per_all_people_f.person_id%TYPE;

  ln_out_pa_task_id          NUMBER;
  lc_out_pm_task_reference   pa_tasks.pm_task_reference%TYPE;         --VARCHAR2;


  CURSOR lcu_tasks IS
  SELECT
    paa.segment1                  project_number
  , paa.project_id                project_id
  , t.task_number                 task_number
  , t.task_id                     task_id
  , pe.status_code                status_code
  , ps.project_system_status_code system_status_code
  -- , t.scheduled_start_date        scheduled_start_date
  -- , t.scheduled_finish_date       scheduled_finish_date
  , pevs.scheduled_finish_date    scheduled_finish_date
  , t.task_manager_person_id      task_manager_person_id
  , pev.element_version_id        element_version_id
  , u.user_id                     user_id
  , u.user_name                   user_name
  FROM pa_proj_elem_ver_schedule  pevs
  ,    pa_proj_element_versions   pev
  ,    pa_proj_elements           pe
  ,    pa_project_statuses        ps
  ,    pa_proj_elem_ver_structure pevst
  ,    pa_tasks                   t
  ,    pa_projects_all            paa
  ,    per_all_people_f           papf
  ,    fnd_user                   u
  WHERE 1=1
  AND   pevs.element_version_id         = pev.element_version_id
  AND   pev.proj_element_id             = t.task_id
  AND   pev.parent_structure_version_id = pevst.element_version_id
  AND   pev.proj_element_id             = pe.proj_element_id
  AND   ps.project_status_code          = pe.status_code
  AND   ps.status_type                  = 'TASK'
  AND   ps.project_system_status_code   = 'NOT_STARTED'
  AND   t.project_id                    = paa.project_id
  AND   t.task_manager_person_id        = papf.person_id
  AND   trunc(SYSDATE) BETWEEN trunc(papf.effective_start_date) AND nvl(papf.effective_end_date, hr_general.end_of_time)
  AND   papf.person_id                  = u.employee_id
  -- AND   pevs.project_id = 522
  AND   pevs.critical_flag = 'Y'
  -- AND   pevs.milestone_flag = 'N'
  AND   pevst.latest_eff_published_flag = 'Y'
  AND   pev.object_type = 'PA_TASKS'
  AND   pe.object_type = 'PA_TASKS'
  AND   pevs.scheduled_finish_date < SYSDATE
  -- v2 23/jan/2009, only include tasks after 15 march 2009
  AND   pevs.scheduled_finish_date >= to_date('15032009','ddmmyyyy')
  AND   NOT EXISTS (
          SELECT 1
          FROM xxah_tasks_notified xtn
          WHERE xtn.task_id = t.task_id
        )
  ORDER BY paa.segment1
  ,        t.task_number
  ;

  lc_message_subject         VARCHAR2(4000);
  lc_message_body            VARCHAR2(4000);
  lc_recipient               VARCHAR2(200);

  lc_log_text                VARCHAR2(4000);

BEGIN
  gc_err_pos:= '<100>';
  FND_MSG_PUB.initialize;


  gc_err_pos:= '<104>';
  FOR lr_tasks IN lcu_tasks LOOP

    lc_message_subject:= 'Project ' || lr_tasks.project_number || ' task ' || lr_tasks.task_number || ' not started';
    lc_message_body:= 'This is to notify you that ';
    lc_message_body:= lc_message_body || ' task ' || lr_tasks.task_number || ' (project ' || lr_tasks.project_number || ')';
    lc_message_body:= lc_message_body || ' was due on ' || to_char(lr_tasks.scheduled_finish_date, 'DD-MON-YYYY') || '.';
    lc_message_body:= lc_message_body || ' This task was marked critical and requires your immediate attention.';

    lc_recipient:= lr_tasks.user_name;


    -- dbms_output.put_line('error message: ' || lc_errmsg);

    send_message(
        p_recipient_name  => lc_recipient
      , p_task_id         => lr_tasks.task_id
      , p_message_subject => lc_message_subject
      , p_message_body    => lc_message_body
    );

  END LOOP;

  x_retbuf:=  'Task Notification Request completed succesfully';
  x_retcode:= gc_retcode_succes;

EXCEPTION
  WHEN OTHERS THEN
    x_retbuf:=  'Error OTHERS: ' || SQLCODE || ', ' || SQLERRM;
    x_retcode:= gc_retcode_error;

END notify_all;

END xxah_task_notify_pkg;

/
