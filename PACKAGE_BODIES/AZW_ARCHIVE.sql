--------------------------------------------------------
--  DDL for Package Body AZW_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZW_ARCHIVE" AS
/* $Header: AZWARCHB.pls 115.8 1999/11/09 12:52:51 pkm ship    $ */

/* Private Procedure Declarations ********************************************/
  PROCEDURE Processes;
  PROCEDURE Task_Steps;

  FUNCTION is_process_notfound(p_node_id varchar2) RETURN boolean
  IS
    cnt number DEFAULT 0;
  BEGIN

    SELECT COUNT(*) INTO cnt
    FROM az_archive aap
    where aap.node_id = p_node_id;

    if(cnt = 0) then
      return TRUE;
    ELSE
      return FALSE;
    END IF;

    return FALSE;
  END is_process_notfound;

  FUNCTION is_step_notfound(p_item_key varchar2
                           ,p_activity_type varchar2
                           ,p_step varchar2
                           ,p_begin_date date
                           ) RETURN boolean
  IS
    cnt number DEFAULT 0;
  BEGIN
    select count(*) into cnt
    from az_archive_steps aas
    where aas.item_key = p_item_key
    and   aas.activity_type = p_activity_type
    and   aas.step  = p_step
    and   aas.begin_date = p_begin_date;

    if(cnt = 0) then
      return TRUE;
    ELSE
      return FALSE;
    END IF;

    return FALSE;

  END is_step_notfound;

  /*------------------------------------------------------------------------
   * PROCESSES
   *
   * Private procedure.  Called by procedure Run.
   * Populate implementation process hierarchies in the intermediate table.
   * It performs the following steps:
   *   1. Get all distinct processes of the given phase from az_processes_all_v and
   *      az_flow_phases_v into the intermediate table.
   *   2. Find all distinct parent ids for the processes found in Step 1.
   *   3. For each parent id in Step 2, get all distinct hierarchy ancestors
   *      in az_groups_v into the intermediate table.
   *-----------------------------------------------------------------------*/
  PROCEDURE processes IS
    CURSOR all_groups_cursor IS
      SELECT TO_CHAR(agv.display_order, '0000')||'.'||agv.group_id node_id
             ,agv.display_name
             ,TO_CHAR(ag.display_order, '0000')||'.'||
              agv.hierarchy_parent_id parent_node_id
             ,agv.status
             ,fl.meaning status_display_name
      FROM   az_groups_v agv
             ,az_groups ag
             ,fnd_lookups fl
      WHERE  agv.hierarchy_parent_id = ag.group_id
      AND    agv.status = fl.lookup_code
      AND    fl.lookup_type = 'AZ_PROCESS_STATUS'
      UNION ALL
      SELECT TO_CHAR(agv.display_order, '0000')||'.'||agv.group_id node_id
             ,agv.display_name
             ,agv.hierarchy_parent_id parent_node_id
             ,agv.status
             ,fl.meaning status_display_name
      FROM   az_groups_v agv
             ,fnd_lookups fl
      WHERE  agv.hierarchy_parent_id is NULL
      AND    agv.status = fl.lookup_code
      AND    fl.lookup_type = 'AZ_PROCESS_STATUS';

    CURSOR all_processes_cursor IS
      SELECT DISTINCT TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type
               ||'.'||apv.process_name||'.'||apv.context_id node_id ,
             apv.display_name,
             TO_CHAR(ag.display_order, '0000')||'.'||apv.parent_id parent_node_id,
             apv.context_type,
             apv.context_type_name context_type_display_name,
             apv.context_id,
             apv.context_name context_display_name,
             apv.status,
             fl.meaning status_display_name,
             apv.comments
      FROM   az_processes_all_v apv,
             az_groups ag,
             fnd_lookups fl
      WHERE  apv.parent_id = ag.group_id
      AND    apv.status = fl.lookup_code
      AND    fl.lookup_type = 'AZ_PROCESS_STATUS';

    CURSOR all_tasks_cursor IS
      SELECT atv.item_type||'.'||atv.root_activity||'.'||atv.context_id||'.'||
               TO_CHAR(TO_NUMBER(atv.item_key), '00000') node_id
             ,apv.display_name
             ,TO_CHAR(apv.display_order, '0000')||'.'||apv.item_type||'.'||
               apv.process_name||'.'||apv.context_id parent_node_id
             ,apv.context_type
             ,apv.context_type_name context_type_display_name
             ,atv.context_id
             ,atv.context_name context_display_name
             ,atv.status
             ,fl.meaning status_display_name
             ,atv.item_key
             ,atv.assigned_user
             ,wf_directory.GetRoleDisplayName(atv.assigned_user)
              assigned_user_display_name
             ,atv.begin_date
             ,atv.end_date
             ,atv.duration
      FROM   az_tasks_v atv
             ,az_processes_all_v apv
             ,fnd_lookups fl
      WHERE  atv.item_type = apv.item_type
      AND    atv.root_activity = apv.process_name
      AND    atv.context_id = apv.context_id
      AND    atv.status = fl.lookup_code
      AND    fl.lookup_type = 'AZ_PROCESS_STATUS';
  BEGIN
    FOR each_group IN all_groups_cursor LOOP
      if (is_process_notfound(each_group.node_id)) then
        INSERT INTO az_archive
        (node_id, node_type
        ,parent_node_id, node_name
        ,context_type, context_type_name
        ,context_id,   context_name
        ,status_code,  status_name
        ,item_key
        ,assigned_user, assigned_user_name
        ,start_date,    end_date
        ,duration,      comments
        )
        VALUES
        (each_group.node_id, 'G',
         each_group.parent_node_id, each_group.display_name,
         NULL, NULL, NULL, NULL,
         each_group.status, each_group.status_display_name,
         NULL, NULL, NULL, NULL, NULL, NULL, NULL);
         COMMIT;
      end if;
    END LOOP;

    FOR each_proc IN all_processes_cursor LOOP
      if (is_process_notfound(each_proc.node_id)) then
        INSERT INTO az_archive
        (node_id, node_type
        ,parent_node_id, node_name
        ,context_type, context_type_name
        ,context_id,   context_name
        ,status_code,  status_name
        ,item_key
        ,assigned_user, assigned_user_name
        ,start_date,    end_date
        ,duration,      comments
        )
        VALUES
        (each_proc.node_id, 'P',
         each_proc.parent_node_id, each_proc.display_name,
         each_proc.context_type, each_proc.context_type_display_name,
         each_proc.context_id, each_proc.context_display_name,
         each_proc.status, each_proc.status_display_name,
         NULL, NULL, NULL, NULL, NULL, NULL,
         each_proc.comments);
         COMMIT;
       end if;
    END LOOP;

    FOR each_task in all_tasks_cursor LOOP
      if (is_process_notfound(each_task.node_id)) then
        INSERT into az_archive
        (node_id, node_type
        ,parent_node_id, node_name
        ,context_type, context_type_name
        ,context_id,   context_name
        ,status_code,  status_name
        ,item_key
        ,assigned_user, assigned_user_name
        ,start_date,    end_date
        ,duration,      comments
        )
        VALUES
        (each_task.node_id, 'T',
         each_task.parent_node_id, each_task.display_name,
         each_task.context_type, each_task.context_type_display_name,
         each_task.context_id, each_task.context_display_name,
         each_task.status, each_task.status_display_name,
         each_task.item_key,
         each_task.assigned_user, each_task.assigned_user_display_name,
         each_task.begin_date, each_task.end_date, each_task.duration, NULL);
         COMMIT;
       end if;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      --DBMS_OUTPUT.PUT_LINE('error:azw_archive.processes' || SQLERRM);
      RAISE;
  END processes;

  /*------------------------------------------------------------------------
   * Run
   *
   * Publice procedure.  To be called to generate archive information.
   *-----------------------------------------------------------------------*/
  PROCEDURE Run IS
    rel varchar2(255);
    rel_info varchar2(255);
    result boolean;
  BEGIN
    result :=fnd_release.get_release(rel,rel_info);
    --DBMS_OUTPUT.PUT_LINE(rel);
    fnd_profile.put('AZ_ARCHIVE_RELEASE', rel);
    COMMIT;

    processes;
    task_steps;
  EXCEPTION
    WHEN OTHERS THEN
      --DBMS_OUTPUT.PUT_LINE('error: AZW_ARCHIVE.Run ' || SQLERRM);
      RAISE;
  END Run;

  /*------------------------------------------------------------------------
   * Task_Steps
   *
   * Private procedure. To be called by Run to copy the task steps information
   * into the archive table, az_archive_task_steps.
   *-----------------------------------------------------------------------*/
  PROCEDURE Task_Steps IS
    l_item_type  az_tasks_v.item_type%TYPE;
    l_item_key   az_tasks_v.item_key%TYPE;
    CURSOR all_tasks_cursor IS
      SELECT atv.item_type||'.'||atv.root_activity||'.'||atv.context_id||'.'||
               TO_CHAR(TO_NUMBER(atv.item_key), '00000') node_id,
	     atv.item_type item_type,
	     atv.item_key  item_key
      FROM   az_tasks_v atv;

    CURSOR all_steps_cursor IS
      SELECT wiasv.activity_type_code type
             --,wiasv.activity_type_display_name
             ,wiasv.activity_name name
             ,wiasv.activity_display_name display_name
             ,wiasv.assigned_user user_name
             ,wiasv.assigned_user_display_name user_display_name
 	     ,wna.text_value form_name
             ,wiasv.activity_status_code status
	     --,wiasv.activity_status_display_name status_display_name
	     ,wiasv.activity_result_code result
	     --,wiasv.activity_result_display_name result_display_name
	     ,wiasv.activity_begin_date begin_date
             ,wiasv.activity_end_date end_date
	     ,wiasv.execution_time
	     ,wn.user_comment
      FROM wf_item_activity_statuses_v wiasv
           ,wf_notification_attributes wna
  	   ,wf_notifications wn
      WHERE wiasv.item_type = l_item_type
      AND   wiasv.item_key  = l_item_key
      AND   wiasv.notification_id = wn.notification_id (+)
      AND   wn.notification_id = wna.notification_id (+)
      AND   wna.name (+) = 'AZW_IA_FORM'
      AND   NOT (wiasv.activity_name in ('START', 'END'))
      UNION
      SELECT wiasv.activity_type type
             --,wiasv.activity_type_display_name
             ,wiasv.activity_name name
             ,wiasv.activity_display_name display_name
             ,wiasv.recipient_role user_name
             ,wiasv.recipient_role_name user_display_name
             ,wna.text_value form_name
             ,wiasv.activity_status status
             --,wiasv.activity_status_display_name status_display_name
             --,wiasv.result result
             ,wiash.activity_result_code result
             --,wiasv.activity_result_display_name result_display_name
             ,wiasv.begin_date begin_date
             ,wiasv.end_date end_date
             ,wiasv.execution_time
             ,wn.user_comment
      FROM wf_item_activities_history_v wiasv
           ,wf_item_activity_statuses_h wiash
           ,wf_notification_attributes wna
           ,wf_notifications wn
      WHERE wiasv.item_type = l_item_type
      AND   wiasv.item_key  = l_item_key
      AND   wiasv.item_type = wiash.item_type
      AND   wiasv.item_key  = wiash.item_key
      AND   wiasv.begin_date = wiash.begin_date
      AND   wiasv.notification_id = wiash.notification_id
      AND   wiasv.notification_id = wn.notification_id (+)
      AND   wn.notification_id = wna.notification_id (+)
      AND   wna.name (+) = 'AZW_IA_FORM'
      AND   NOT (wiasv.activity_name in ('START', 'END'));
  BEGIN
    FOR each_task in all_tasks_cursor LOOP
      l_item_type := each_task.item_type;
      l_item_key  := each_task.item_key;
      FOR each_step in all_steps_cursor LOOP
        if(is_step_notfound(each_task.item_key, each_step.type
                            ,each_step.name, each_step.begin_date)) then
	  INSERT into az_archive_steps
          (item_key
          ,activity_type
          ,step,   step_name
          ,assigned_user, assigned_user_name
          ,form_name
          ,status_code
          ,result_code
          ,begin_date
          ,end_date
          ,duration
          ,comments
          ,node_id
          )
          VALUES
	  (each_task.item_key
           ,each_step.type
           ,each_step.name, each_step.display_name
           ,each_step.user_name, each_step.user_display_name
	   ,each_step.form_name
           ,each_step.status
	   ,each_step.result
	   ,each_step.begin_date, each_step.end_date
	   ,each_step.execution_time
	   ,each_step.user_comment
           ,each_task.node_id);
           COMMIT;
         end if;
      END LOOP;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      --DBMS_OUTPUT.PUT_LINE('error: AZW_ARCHIVE.Task_Steps' || SQLERRM);
      RAISE;
  END Task_Steps;

END AZW_ARCHIVE;

/
