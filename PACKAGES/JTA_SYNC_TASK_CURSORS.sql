--------------------------------------------------------
--  DDL for Package JTA_SYNC_TASK_CURSORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTA_SYNC_TASK_CURSORS" AUTHID CURRENT_USER AS
/* $Header: jtavstzs.pls 120.3 2005/09/08 06:02:40 deeprao ship $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                            All rights reserved.                       |
+=======================================================================+
| FILENAME                                                              |
|          jtavstzs.pls                                                 |
|                                                                       |
| DESCRIPTION                                                           |
|          This package has all the cursors                             |
|                                                                       |
| NOTES                                                                 |
|                                                                       |
|                                                                       |
|Date           Developer   Change                                      |
|-----------    ---------   ------------------------------------------- |
|04-02-02       SSALLAKA      Created                                   |
|04-19-2002     SSALLAKA      Updated with Object_changted_date instead |
|                               last_update_date in jtf_tasks_b table   |
|04-22-2002     CJANG         Added t.owner_type_code = 'RS_EMPLOYEE'   |
|                                 in the cursor c_delete_assignment     |
|04-23-2002     CJANG         When a user change non-repeat to repeat   |
|                            after sync, the cursor c_new_repeating_task|
|                            was selecting the repeating as a new.      |
|                            This bug is fixed by moving                |
|                              jtaa.last_update_date > b_syncanchor from|
|                              inline view to outside where clause      |
|                            This may affect performance.               |
|04-24-2002     CJANG        Modified the cursor c_modify_non_repeat_task
|                              and c_modify_non_repeat_task             |
|                              and c_delete_tasks                       |
|                              and c_delete_rejected_tasks              |
|                             to pick up all the non-task manager source|
|04-25-2002     CJANG        Modified the cursor                        |
|                              1) c_new_repeating_task:                 |
|                                Added ta.assignment_status_id IN (3,18)|
|                                Select the greatest start_date_active  |
|                              2) c_modify_repeating_task:              |
|                                Added ta.assignment_status_id IN (3,18)|
|                                Select the greatest start_date_active  |
|                              3) c_delete_assignee_reject: Newly added |
|                              4) c_delete_rejected_tasks:              |
|                                                                       |
|               OR ( nvl(sts.completed_flag,'N') = 'Y' AND              |
|                    nvl(sts.cancelled_flag,'N') = 'Y' AND              |
|                    nvl(sts.rejected_flag,'N') = 'Y' AND               |
|                    nvl(sts.closed_flag,'N') = 'Y'                     |
|              ====>                                                    |
|               OR ( nvl(sts.completed_flag,'N') = 'Y' OR               |
|                    nvl(sts.cancelled_flag,'N') = 'Y' OR               |
|                    nvl(sts.rejected_flag,'N') = 'Y' OR                |
|                    nvl(sts.closed_flag,'N') = 'Y'                     |
|                                                                       |
|04-26-2002     CJANG       1)Added two more conditions to the cursor   |
|                                 c_non_repeat_task                     |
|                                                                       |
|                                AND ta.assignment_status_id IN (3, 18) |
|                                AND ta.resource_id = b_resource_id     |
|                              not to pick up any rejected appts/task   |
|                           2)Modified the following statement in all   |
|                             cursors                                   |
|                                 tm.resource_id = b_resource_id        |
|                  ==>tm.resource_id = jta_sync_task.g_login_resource_id|
|                           3)Modified all cursor for handling group id |
|                                                                       |
|04-29-2002     CJANG       Added a condition in c_new_non_repeat_task  |
|                               "AND ta.assignment_status_id IN (3,18)" |
|                                                                       |
|05-02-2002     CJANG       Modified c_new_repeating_task to pick up    |
|                             all the future appts modified.            |
|                           Modified c_delete_rejected_tasks,           |
|                                    c_delete_assignment                |
|                            to support diverse source_object_type      |
|                                 such as Opportunity, Lead etc         |
|                                                                       |
|07-02-2002     CJANG       Fix Bug: 2442496                            |
|                           Modified c_delete_assignee_reject to pick up|
|                             only the rejected appointment.            |
|                           A task is not deleted from device even if   |
|                             the task has been rejected by the current |
|                             logged-in assignee.                       |
|07-03-2002     CJANG       After Code Review for Fix Bug: 2442496      |
|                             Modified c_delete_assignee_reject         |
|                           ta.assignee_role = 'ASSIGNEE'               |
|                           ==> nvl(ta.assignee_role,'ASSIGNEE')        |
|                                      = 'ASSIGNEE'                     |
|									|
|18-JUL-2005   TSINGHAL   Commented code 'assignment_status_id IN(3,18)'|
|                         to allow all	assignment_status_id as per     |
|                         bug 4397779 update				|
|									|
|08-SEP-2005  DEEPRAO	  Modified c_delete_unsubscribed                |
|                                                                       |
*=======================================================================*/
   CURSOR c_new_repeating_task (
      b_syncanchor           DATE,
      b_resource_id          NUMBER,
      b_resource_type        VARCHAR2,
      b_source_object_type   VARCHAR2
   )
   IS
      SELECT DISTINCT tl.task_name,
             tl.description,
             t.date_selected,
             t.planned_start_date,
             t.planned_end_date,
             t.scheduled_start_date,
             t.scheduled_end_date,
             t.actual_start_date,
             t.actual_end_date,
             t.calendar_start_date,
             t.calendar_end_date,
             t.task_status_id,
             tb.importance_level importance_level,
             NVL (t.alarm_on, 'N') alarm_on,
             t.alarm_start,
             UPPER (t.alarm_start_uom) alarm_start_uom,
             NVL (t.private_flag, 'N') private_flag,
             t.deleted_flag,
             NVL (t.timezone_id, jta_sync_task_common.g_client_timezone_id) timezone_id,
             t.task_id,
             t.owner_type_code,
             t.source_object_type_code,
             rc.recurrence_rule_id,
             rc.occurs_uom,
             rc.occurs_every,
             rc.occurs_number,
             greatest(rc.start_date_active, t.planned_start_date) start_date_active,
             rc.end_date_active,
             rc.sunday,
             rc.monday,
             rc.tuesday,
             rc.wednesday,
             rc.thursday,
             rc.friday,
             rc.saturday,
             rc.date_of_month,
             rc.occurs_which,
             greatest(t.object_changed_date, ta.last_update_date) new_timestamp
        FROM jtf_task_recur_rules rc,
             jtf_task_statuses_b ts,
             jtf_task_priorities_b tb,
             jtf_tasks_tl tl,
             jtf_task_all_assignments ta,
             jtf_tasks_b t,
             (SELECT jtb.recurrence_rule_id
                   , MIN (jtb.task_id) task_id
                FROM jtf_tasks_b jtb
                   , jtf_task_all_assignments jtaa
               WHERE jtaa.resource_id = b_resource_id
                 AND jtaa.resource_type_code = b_resource_type
                 AND jtb.task_id = jtaa.task_id
                 AND jtb.source_object_type_code = b_source_object_type
                 AND b_source_object_type = 'APPOINTMENT'
                 AND jtb.recurrence_rule_id IS NOT NULL
              HAVING NOT EXISTS (SELECT 1
                                   FROM jta_sync_task_mapping tm
                                  WHERE tm.task_id = MIN(jtb.task_id)
                                    AND tm.resource_id = jta_sync_task.g_login_resource_id)
              GROUP BY jtb.recurrence_rule_id) newtask
       WHERE t.task_id = newtask.task_id
         AND ( (b_resource_type = 'RS_GROUP' AND
                t.owner_type_code = b_resource_type AND
                t.owner_id = b_resource_id
               )
               OR
               (b_resource_type = 'RS_EMPLOYEE' AND
                t.owner_type_code = b_resource_type
               )
             )
         AND (t.object_changed_date > b_syncanchor OR
              ta.last_update_date > b_syncanchor)
         AND ta.task_id = t.task_id
         AND ta.resource_id = b_resource_id
         AND ta.resource_type_code = b_resource_type
		 -- Modifed by TSINGHAL for bug 4397779
		 /*
         AND ta.assignment_status_id IN (3 -- Accepted
                                        ,18 -- Invited
                                        )*/
         AND tl.task_id = t.task_id
         AND ts.task_status_id = t.task_status_id
         AND tl.language = USERENV ('LANG')
         AND task_type_id <> 22
         AND rc.recurrence_rule_id = t.recurrence_rule_id
         AND tb.task_priority_id (+) = t.task_priority_id;

   CURSOR c_modify_repeating_task (
      b_syncanchor           DATE,
      b_resource_id          NUMBER,
      b_resource_type        VARCHAR2,
      b_source_object_type   VARCHAR2
   )
   IS
      SELECT DISTINCT tl.task_name,
                      tl.description,
                      t.date_selected,
                      t.planned_start_date,
                      t.planned_end_date,
                      t.scheduled_start_date,
                      t.scheduled_end_date,
                      t.actual_start_date,
                      t.actual_end_date,
                      t.calendar_start_date,
                      t.calendar_end_date,
                      t.task_status_id,
                      tb.importance_level l_importance_level,
                      NVL (t.alarm_on, 'N') alarm_on,
                      t.alarm_start,
                      UPPER (t.alarm_start_uom) alarm_start_uom,
                      NVL (t.private_flag, 'N') private_flag,
                      t.deleted_flag,
                      NVL (t.timezone_id, jta_sync_task_common.g_client_timezone_id) timezone_id,
                      tm.task_sync_id,
                      t.task_id,
                      t.owner_type_code,
                      t.source_object_type_code,
                      ta.assignment_status_id,
                      rc.recurrence_rule_id,
                      rc.occurs_uom,
                      rc.occurs_every,
                      rc.occurs_number,
                      greatest(rc.start_date_active, t.planned_start_date) start_date_active,
                      rc.end_date_active,
                      rc.sunday,
                      rc.monday,
                      rc.tuesday,
                      rc.wednesday,
                      rc.thursday,
                      rc.friday,
                      rc.saturday,
                      rc.date_of_month,
                      rc.occurs_which,
                      greatest(t.object_changed_date, ta.last_update_date) new_timestamp
        FROM jtf_task_recur_rules rc,
             jta_sync_task_mapping tm,
             jtf_task_all_assignments ta,
             jtf_task_statuses_b ts,
             jtf_task_priorities_b tb,
             jtf_tasks_tl tl,
             jtf_tasks_b t
       WHERE tm.resource_id = jta_sync_task.g_login_resource_id
         AND t.task_id = tm.task_id
         AND t.task_id = ta.task_id
         AND tl.task_id = t.task_id
         AND ( (b_resource_type = 'RS_GROUP' AND
                t.owner_type_code = b_resource_type AND
                t.owner_id = b_resource_id
               )
               OR
               (b_resource_type = 'RS_EMPLOYEE' AND
                t.owner_type_code = b_resource_type
               )
             )
         AND ta.resource_id = b_resource_id
		 -- Modified by TSINGHAL for bug 4397779
/*         AND ta.assignment_status_id IN (3,   -- Accepted
                                         18   -- Invited
                                        )*/
         AND ts.task_status_id = t.task_status_id
         AND t.recurrence_rule_id IS NOT NULL
         AND rc.recurrence_rule_id = t.recurrence_rule_id
         AND tb.task_priority_id (+) = t.task_priority_id
         AND task_type_id <> 22
         AND tl.language = USERENV ('LANG')
         AND t.source_object_type_code = b_source_object_type
         AND b_source_object_type = 'APPOINTMENT'
         AND (  rc.last_update_date > b_syncanchor
             OR ta.last_update_date > b_syncanchor
             OR t.object_changed_date > b_syncanchor)
         AND ts.task_status_id = t.task_status_id ;

   CURSOR c_delete_task (b_syncanchor         DATE,
                         b_resource_id        NUMBER,
                         b_resource_type      VARCHAR2,
                         b_source_object_type VARCHAR2)
   IS
      SELECT tm.task_sync_id
        FROM jtf_tasks_b t
           , jta_sync_task_mapping tm
       WHERE tm.resource_id = jta_sync_task.g_login_resource_id
         AND t.task_id = tm.task_id
         AND ( (b_resource_type = 'RS_GROUP' AND
                t.owner_type_code = b_resource_type AND
                t.owner_id = b_resource_id
               )
               OR
               (b_resource_type = 'RS_EMPLOYEE' AND
                t.owner_type_code = b_resource_type
               )
             )
         AND NVL (t.deleted_flag, 'N') = 'Y'
         AND decode(t.source_object_type_code,'APPOINTMENT','APPOINTMENT','TASK')  = b_source_object_type
         AND task_type_id <> 22
         AND t.object_changed_date > b_syncanchor;

   -- This cursor is working for only appointment
   -- If the invitee rejects the invitation, then it sends a delete signal
   CURSOR c_delete_assignee_reject (b_syncanchor           DATE,
                                    b_resource_id          NUMBER,
                                    b_resource_type        VARCHAR2,
                                    b_source_object_type   VARCHAR2)
   IS
      SELECT tm.task_sync_id
        FROM jtf_tasks_b t
           , jta_sync_task_mapping tm
           , jtf_task_all_assignments ta
       WHERE tm.resource_id = jta_sync_task.g_login_resource_id
         AND t.task_id = tm.task_id
         AND t.owner_type_code = b_resource_type
         AND b_resource_type = 'RS_EMPLOYEE'
         AND NVL (t.deleted_flag, 'N') = 'N'
         AND t.task_type_id <> 22
         AND decode(t.source_object_type_code,'APPOINTMENT','APPOINTMENT','TASK')  = b_source_object_type
         AND b_source_object_type = 'APPOINTMENT' -- Fix bug 2442496
         AND ta.task_id = t.task_id
         AND ta.resource_id = b_resource_id
         AND ta.resource_type_code = b_resource_type
         AND nvl(ta.assignee_role,'ASSIGNEE') = 'ASSIGNEE' -- Fix bug 2442496
         AND ta.assignment_status_id = 4 -- Reject Status
         AND ta.last_update_date > b_syncanchor;

   CURSOR c_delete_rejected_tasks (b_syncanchor           DATE,
                                   b_resource_id          NUMBER,
                                   b_resource_type        VARCHAR2,
                                   b_source_object_type   VARCHAR2)
   IS
      SELECT tm.task_sync_id
        FROM jtf_tasks_b t
           , jta_sync_task_mapping tm
       WHERE tm.resource_id = jta_sync_task.g_login_resource_id
         AND t.task_id = tm.task_id
         AND ( (b_resource_type = 'RS_GROUP' AND
                t.owner_type_code = b_resource_type AND
                t.owner_id = b_resource_id
               )
               OR
               (b_resource_type = 'RS_EMPLOYEE' AND
                t.owner_type_code = b_resource_type
               )
             )
         AND NVL (t.deleted_flag, 'N') = 'N'
         AND t.task_type_id <> 22
         AND decode(t.source_object_type_code,'APPOINTMENT','APPOINTMENT','TASK')  = b_source_object_type
         AND
             (
             -- Closed Status
                NVL(t.open_flag,'Y') = 'N' -- Enh# 2666995

             -- endless task
             OR
                (   t.calendar_end_date IS NULL AND
                    t.calendar_start_date IS NOT NULL AND
                    t.source_object_type_code <> 'APPOINTMENT')

             -- Appointment with the spanned Date
             OR (   t.source_object_type_code = 'APPOINTMENT' AND
                    TRUNC (t.calendar_start_date) <> TRUNC (t.calendar_end_date)
                )
             )
         AND t.object_changed_date > b_syncanchor;

   CURSOR c_delete_assignment (b_syncanchor           DATE,
                               b_resource_id          NUMBER,
                               b_resource_type        VARCHAR2,
                               b_source_object_type   VARCHAR2)
   IS
      SELECT tm.task_sync_id
        FROM jtf_tasks_b t
           , jta_sync_task_mapping tm
       WHERE tm.resource_id = jta_sync_task.g_login_resource_id
         AND t.task_id = tm.task_id
         AND t.owner_type_code = b_resource_type
         AND b_resource_type = 'RS_EMPLOYEE'
         AND NVL (t.deleted_flag, 'N') = 'N'
         AND decode(t.source_object_type_code,'APPOINTMENT','APPOINTMENT','TASK')  = b_source_object_type
         --this indicates that the resource is no longer on the task, however the task is not deleted
         AND NOT EXISTS (SELECT 1
                           FROM jtf_task_all_assignments asgn
                          WHERE asgn.task_id = t.task_id
                            AND asgn.resource_id = b_resource_id/*and asgn.last_update_date >= b_syncanchor */
             );

   CURSOR c_new_non_repeat_task (b_syncanchor           DATE,
                                 b_resource_id          NUMBER,
                                 b_resource_type        VARCHAR2,
                                 b_source_object_type   VARCHAR2)
   IS
      SELECT distinct tl.task_name,
             tl.description,
             t.date_selected,
             t.planned_start_date,
             t.planned_end_date,
             t.scheduled_start_date,
             t.scheduled_end_date,
             t.actual_start_date,
             t.actual_end_date,
             t.calendar_start_date,
             t.calendar_end_date,
             t.task_status_id,
             tb.importance_level,
             NVL (t.alarm_on, 'N') alarm_on,
             t.alarm_start,
             UPPER (t.alarm_start_uom) alarm_start_uom,
             NVL (t.private_flag, 'N') private_flag,
             t.deleted_flag,
             NVL (t.timezone_id, jta_sync_task_common.g_client_timezone_id) timezone_id,
             t.task_id,
             t.owner_type_code,
             t.source_object_type_code,
             t.recurrence_rule_id,
             ta.assignment_status_id,
             greatest(t.object_changed_date, ta.last_update_date) new_timestamp
        FROM jtf_task_all_assignments ta,
             jtf_task_priorities_b tb,
             jtf_tasks_tl tl,
             jtf_tasks_b t
       WHERE ta.resource_id = b_resource_id
         AND ta.resource_type_code = b_resource_type
		 -- Commented by TSINGHAL to fix bug 4397779
         /* AND ta.assignment_status_id IN (3,   -- Accepted
                                         18   -- Invited
                                        )*/
         AND t.task_id = ta.task_id
         AND ( (b_resource_type = 'RS_GROUP' AND
                t.owner_type_code = b_resource_type AND
                t.owner_id = b_resource_id
               )
               OR
               (b_resource_type = 'RS_EMPLOYEE' AND
                t.owner_type_code = b_resource_type
               )
             )
         AND task_type_id <> 22
         AND NOT EXISTS (SELECT 1
                           FROM jta_sync_task_mapping tm
                          WHERE tm.task_id = t.task_id
                            AND tm.resource_id = jta_sync_task.g_login_resource_id)
         AND t.recurrence_rule_id IS NULL
         AND decode(t.source_object_type_code,'APPOINTMENT','APPOINTMENT','TASK')  = b_source_object_type
         AND tl.task_id = t.task_id
         AND tl.language = USERENV ('LANG')
         AND tb.task_priority_id (+) = t.task_priority_id
         AND NVL(t.open_flag,'Y') = 'Y' -- Enh# 2666995
         AND (  ta.last_update_date > b_syncanchor
             OR t.object_changed_date > b_syncanchor);

   CURSOR c_modify_non_repeat_task (
      b_syncanchor           DATE,
      b_resource_id          NUMBER,
      b_resource_type        VARCHAR2,
      b_source_object_type   VARCHAR2
   )
   IS
      SELECT  distinct  tl.task_name,
             tl.description,
             t.date_selected,
             t.planned_start_date,
             t.planned_end_date,
             t.scheduled_start_date,
             t.scheduled_end_date,
             t.actual_start_date,
             t.actual_end_date,
             t.calendar_start_date,
             t.calendar_end_date,
             t.task_status_id,
             tb.importance_level,
             NVL (t.alarm_on, 'N') alarm_on,
             t.alarm_start,
             UPPER (t.alarm_start_uom) alarm_start_uom,
             NVL (t.private_flag, 'N') private_flag,
             t.deleted_flag,
             NVL (t.timezone_id, jta_sync_task_common.g_client_timezone_id) timezone_id,
             tm.task_sync_id,
             t.task_id,
             t.owner_type_code,
             t.source_object_type_code,
             t.recurrence_rule_id,
             ta.assignment_status_id,
             greatest(t.object_changed_date, ta.last_update_date) new_timestamp
        FROM jta_sync_task_mapping tm,
             jtf_task_all_assignments ta,
             jtf_task_priorities_b tb,
             jtf_tasks_tl tl,
             jtf_tasks_b t
       WHERE tm.resource_id = jta_sync_task.g_login_resource_id
         AND t.task_id = tm.task_id
         AND ( (b_resource_type = 'RS_GROUP' AND
                t.owner_type_code = b_resource_type AND
                t.owner_id = b_resource_id
               )
               OR
               (b_resource_type = 'RS_EMPLOYEE' AND
                t.owner_type_code = b_resource_type
               )
             )
         AND ta.task_id = t.task_id
		 -- Modified by TSINGHAL for bug 4397779
/*         AND ta.assignment_status_id IN (3, 18) -- Accepted, Invited */
         AND ta.resource_id = b_resource_id
         AND t.recurrence_rule_id IS NULL
         AND task_type_id <> 22
         AND (  t.object_changed_date > b_syncanchor
             OR ta.last_update_date > b_syncanchor)
         AND tl.task_id = t.task_id
         AND ta.resource_type_code = b_resource_type
         AND ta.resource_id = b_resource_id
         AND NVL(t.open_flag,'Y') = 'Y' -- Enh# 2666995
         AND decode(t.source_object_type_code,'APPOINTMENT','APPOINTMENT','TASK')  = b_source_object_type
         AND tl.language = USERENV ('LANG')
         AND tb.task_priority_id (+) = t.task_priority_id;


   CURSOR c_delete_unsubscribed (
       b_resource_id          NUMBER,
       b_resource_type        VARCHAR2,
       b_source_object_type   VARCHAR2
      )
      IS
       SELECT m.task_sync_id
        FROM  jtf_tasks_b b, jta_sync_task_mapping m
       WHERE b.task_id = m.task_id
        AND m.resource_id = jta_sync_task.g_login_resource_id
        AND NVL (b.deleted_flag, 'N') = 'N'
        AND b.owner_type_code ='RS_GROUP'
        AND b.source_object_type_code = jta_sync_task_common.G_APPOINTMENT
        AND b_resource_id = m.resource_id
        AND b_source_object_type = jta_sync_task_common.G_APPOINTMENT
        AND b_resource_type = 'RS_EMPLOYEE'
        AND NOT EXISTS
        (SELECT 1
          FROM fnd_grants g
        WHERE g.instance_pk1_value = to_char(b.owner_id) -- fix bug bug 2613008
          AND g.grantee_key = to_char(jta_sync_task.g_login_resource_id) -- fix bug#4592625
        );


END;   -- Package Specification JTA_SYNC_TASK_CURSORS

 

/
