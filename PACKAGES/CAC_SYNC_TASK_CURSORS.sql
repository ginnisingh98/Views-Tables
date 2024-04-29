--------------------------------------------------------
--  DDL for Package CAC_SYNC_TASK_CURSORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SYNC_TASK_CURSORS" AUTHID CURRENT_USER AS
/* $Header: cacvstzs.pls 120.16.12010000.1 2008/07/24 18:03:39 appldev ship $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                All rights reserved.                                   |
+=======================================================================+
| FILENAME                                                              |
|      cacvstzs.pls                                                     |
|                                                                       |
| DESCRIPTION                                                           |
|      This package is a common for sync task                           |
|                                                                       |
| NOTES                                                                 |
|                                                                       |
|                                                                       |
| Date      Developer        Change                                     |
| ------    ---------------  ---------------------------------------    |
| 04-Nov-2004   sachoudh         Created.                               |
| 02-FEB-2005  rhshriva      Modified the cursors c_new_repeating_task  |
|                            and c_modify_repeating_task                |
*=======================================================================*/

  -- G_SYNC_DAYS_BEFORE CONSTANT NUMBER := 7;

   G_SYNC_DAYS_BEFORE CONSTANT NUMBER := TO_NUMBER (nvl(fnd_profile.VALUE ('CAC_SYNC_DAYS_BEFORE'),0));
   --G_CAC_SYNC_TASK_NO_DATE VARCHAR2(10)  :=  fnd_profile.VALUE ('CAC_SYNC_TASK_NO_DATE');
   G_CAC_SYNC_TASK_NO_DATE VARCHAR2(50) := 'FALSE';

   CURSOR c_new_repeating_task (
      b_syncanchor           DATE,
      b_resource_id          NUMBER,
      b_principal_id         NUMBER,
      b_resource_type        VARCHAR2,
      b_source_object_type   VARCHAR2
   )
   IS
      SELECT DISTINCT tl.task_name,
             tl.description,
             t.date_selected,
              ( trunc(rc.start_date_active)+ (t.planned_start_date-trunc(t.planned_start_date))) planned_start_date,
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
             NVL (t.timezone_id, cac_sync_task_common.g_client_timezone_id) timezone_id,
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
             greatest(t.object_changed_date, ta.last_update_date) new_timestamp,
             CAC_VIEW_UTIL_PUB.get_locations(t.task_id) locations,
             ta.free_busy_type free_busy_type,
             t.entity
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
                 AND jtb.entity='APPOINTMENT'
                -- AND jtb.source_object_type_code = b_source_object_type  , using entity instead of source_object_type_code
                 AND b_source_object_type = 'APPOINTMENT'
                 AND jtb.recurrence_rule_id IS NOT NULL
              HAVING NOT EXISTS (SELECT 1
                                   FROM jta_sync_task_mapping tm
                                  WHERE tm.task_id = MIN(jtb.task_id)
                                    AND tm.resource_id = cac_sync_task.g_login_resource_id
                                    AND tm.principal_id =  b_principal_id)
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
	      AND exists
	      --rhshriva.. The following lines will check for start date to be in range for any of the repeating tasks
	 (select 1  from jtf_tasks_b b where
         b.recurrence_rule_id = ( select a.recurrence_rule_id from jtf_tasks_b a
         where a.task_id= t.task_id)
         and b.calendar_start_date > (sysdate-G_SYNC_DAYS_BEFORE))

        -- AND  t.calendar_start_date > (sysdate - G_SYNC_DAYS_BEFORE )
         --AND (  ta.last_update_date > (sysdate - G_SYNC_DAYS_BEFORE )
         --       OR t.object_changed_date > (sysdate - G_SYNC_DAYS_BEFORE ) and rownum=1)
         AND ta.task_id = t.task_id
         AND ta.resource_id = b_resource_id
         AND ta.resource_type_code = b_resource_type
         AND ta.assignment_status_id IN (3 -- Accepted
                                        ,18 -- Invited
                                        )
         AND tl.task_id = t.task_id
         AND ts.task_status_id = t.task_status_id
         AND tl.language = USERENV ('LANG')
         AND t.entity='APPOINTMENT'
         AND rc.recurrence_rule_id = t.recurrence_rule_id
         AND tb.task_priority_id (+) = t.task_priority_id
	     AND NVL (t.deleted_flag, 'N') = 'N';

   CURSOR c_modify_repeating_task (
      b_syncanchor           DATE,
      b_resource_id          NUMBER,
      b_principal_id         NUMBER,
      b_resource_type        VARCHAR2,
      b_source_object_type   VARCHAR2
   )
   IS
      SELECT DISTINCT tl.task_name,
                      tl.description,
                      t.date_selected,
             ( trunc(rc.start_date_active)+ (t.planned_start_date-trunc(t.planned_start_date))) planned_start_date,
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
                      NVL (t.timezone_id, cac_sync_task_common.g_client_timezone_id) timezone_id,
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
                      greatest(t.object_changed_date, ta.last_update_date) new_timestamp,
                      CAC_VIEW_UTIL_PUB.get_locations(t.task_id) locations,
                      ta.free_busy_type free_busy_type,
                      t.entity
        FROM jtf_task_recur_rules rc,
             jta_sync_task_mapping tm,
             jtf_task_all_assignments ta,
             jtf_task_statuses_b ts,
             jtf_task_priorities_b tb,
             jtf_tasks_tl tl,
             jtf_tasks_b t
       WHERE tm.resource_id = cac_sync_task.g_login_resource_id
         AND tm.principal_id =  b_principal_id
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
         AND ta.assignment_status_id IN (3,   -- Accepted
                                         18   -- Invited
                                        )
         AND ts.task_status_id = t.task_status_id
         AND t.recurrence_rule_id IS NOT NULL
         AND rc.recurrence_rule_id = t.recurrence_rule_id
         AND tb.task_priority_id (+) = t.task_priority_id
      --   AND t.task_type_id <> 22
	-- AND task_type_id <> 22
         AND tl.language = USERENV ('LANG')
	 AND t.entity='APPOINTMENT'
       --  AND t.source_object_type_code = b_source_object_type  using entity instead of source_object_type_code
         AND b_source_object_type = 'APPOINTMENT'
	 AND exists
    --rhshriva.. The following lines will check for start date to be in range for any of the repeating tasks
	 (select 1  from jtf_tasks_b b where
         b.recurrence_rule_id = t.recurrence_rule_id
	 --commented for bug 5352055
	 /*( select a.recurrence_rule_id from jtf_tasks_b a
         where a.task_id= t.task_id)*/
         and b.calendar_start_date > (sysdate-G_SYNC_DAYS_BEFORE)
	 and rownum=1 )

      --   AND t.calendar_start_date > (sysdate - G_SYNC_DAYS_BEFORE )
         AND (  rc.last_update_date > b_syncanchor
             OR (SELECT MAX(last_update_date) FROM jtf_task_all_assignments
	 	WHERE task_id = t.task_id) > b_syncanchor
             OR t.object_changed_date > b_syncanchor
             OR (SELECT MAX(m.object_changed_date) FROM jtf_tasks_b m WHERE m.task_id IN
			 (SELECT jte.task_id FROM jta_task_exclusions jte
              WHERE jte.recurrence_rule_id=t.recurrence_rule_id)) > b_syncanchor)
         AND ts.task_status_id = t.task_status_id
	 AND NVL (t.deleted_flag, 'N') = 'N';


CURSOR c_exclusions (
      b_syncanchor           DATE,
      b_recurrence_rule_id   NUMBER,
      b_resource_id          NUMBER,
      b_resource_type        VARCHAR2
   )
   IS
      SELECT jte.exclusion_date,
             jte.task_id,
             tl.task_name,
             tl.description,
             tb.date_selected,
             tb.planned_start_date,
             tb.planned_end_date,
             tb.scheduled_start_date,
             tb.scheduled_end_date,
             tb.actual_start_date,
             tb.actual_end_date,
             tb.calendar_start_date,
             tb.calendar_end_date,
             tb.task_status_id,
             tp.importance_level importance_level,
             NVL (tb.alarm_on, 'N') alarm_on,
             tb.alarm_start,
             UPPER (tb.alarm_start_uom) alarm_start_uom,
             NVL (tb.private_flag, 'N') private_flag,
             tb.deleted_flag,
             NVL (tb.timezone_id, cac_sync_task_common.g_client_timezone_id) timezone_id,
             tb.owner_type_code,
             tb.owner_id,
             tb.source_object_type_code,
             jte.recurrence_rule_id,
             greatest(tb.last_update_date ) new_timestamp,
             CAC_VIEW_UTIL_PUB.get_locations(tl.task_id) locations,
             ta.free_busy_type,
             tb.entity,
             case
             when ((nvl(tb.deleted_flag,'N')='Y') and tb.recurrence_rule_id is null) then cac_sync_task_common.g_delete
             when ((nvl(tb.deleted_flag,'N')='N') and tb.recurrence_rule_id is null) then cac_sync_task_common.g_modify
             when ( tb.recurrence_rule_id is not null) then cac_sync_task_common.g_delete




            end as event
      FROM
             jtf_task_priorities_b tp,
             jtf_tasks_tl tl,
             jtf_tasks_b tb,
             jta_task_exclusions jte,
	     jtf_task_all_assignments ta
      WHERE  jte.recurrence_rule_id = b_recurrence_rule_id
      and    tb.task_id=jte.task_id
      and    tl.task_id=tb.task_id
      and    tl.language=userenv('LANG')
      AND    ta.task_id = tb.task_id
      AND    ta.resource_id = b_resource_id
      AND    ta.resource_type_code = b_resource_type
      AND    ta.assignment_status_id IN (3 -- Accepted
                                        ,18 -- Invited
                                        )
      and    tb.task_priority_id(+)=tp.task_priority_id
      and    tb.entity='APPOINTMENT'
      and    tb.source_object_type_code='APPOINTMENT';
     -- AND    ((tb.object_changed_date  > b_syncanchor ) or (tb.last_update_date > b_syncanchor));


   CURSOR c_delete_task (b_syncanchor         DATE,
                         b_resource_id        NUMBER,
                         b_principal_id       NUMBER,
                         b_resource_type      VARCHAR2,
                         b_source_object_type VARCHAR2)
   IS
      SELECT tm.task_sync_id
        FROM jtf_tasks_b t
           , jta_sync_task_mapping tm
       WHERE tm.resource_id = cac_sync_task.g_login_resource_id
         AND tm.principal_id =  b_principal_id
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
                                    b_principal_id         NUMBER,
                                    b_resource_type        VARCHAR2,
                                    b_source_object_type   VARCHAR2)
   IS
      SELECT tm.task_sync_id
        FROM jtf_tasks_b t
           , jta_sync_task_mapping tm
           , jtf_task_all_assignments ta
       WHERE tm.resource_id = cac_sync_task.g_login_resource_id
          AND tm.principal_id =  b_principal_id
         AND t.task_id = tm.task_id
         AND t.owner_type_code = b_resource_type
         AND b_resource_type = 'RS_EMPLOYEE'
         AND NVL (t.deleted_flag, 'N') = 'N'
         AND t.task_type_id <> 22
         AND decode(t.source_object_type_code,'APPOINTMENT','APPOINTMENT','TASK')  = b_source_object_type
         AND decode(t.entity, 'APPOINTMENT','APPOINTMENT','TASK', 'TASK','BOOKING')  =  b_source_object_type
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
                                   b_principal_id         NUMBER,
                                   b_source_object_type   VARCHAR2)
   IS
      SELECT tm.task_sync_id
        FROM jtf_tasks_b t
           , jta_sync_task_mapping tm
       WHERE tm.resource_id = cac_sync_task.g_login_resource_id
         AND tm.principal_id =  b_principal_id
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
         AND decode(t.entity, 'APPOINTMENT','APPOINTMENT','TASK', 'TASK','BOOKING')  =  b_source_object_type
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
         --AND t.object_changed_date > b_syncanchor ;
          AND t.object_changed_date > b_syncanchor ;


   CURSOR c_delete_assignment (b_syncanchor           DATE,
                               b_resource_id          NUMBER,
                               b_resource_type        VARCHAR2,
                               b_principal_id         NUMBER,
                               b_source_object_type   VARCHAR2)
   IS
      SELECT tm.task_sync_id
        FROM jtf_tasks_b t
           , jta_sync_task_mapping tm
       WHERE tm.resource_id = cac_sync_task.g_login_resource_id
         AND tm.principal_id =  b_principal_id
         AND t.task_id = tm.task_id
         AND t.owner_type_code = b_resource_type
         AND b_resource_type = 'RS_EMPLOYEE'
         AND NVL (t.deleted_flag, 'N') = 'N'
         AND decode(t.source_object_type_code,'APPOINTMENT','APPOINTMENT','TASK')  = b_source_object_type
         AND decode(t.entity, 'APPOINTMENT','APPOINTMENT','TASK', 'TASK','BOOKING')  =  b_source_object_type
         --this indicates that the resource is no longer on the task, however the task is not deleted
         AND NOT EXISTS (SELECT 1
                           FROM jtf_task_all_assignments asgn
                          WHERE asgn.task_id = t.task_id
                            AND asgn.resource_id = b_resource_id/*and asgn.last_update_date >= b_syncanchor */
             );

   CURSOR c_new_non_repeat_task (b_syncanchor           DATE,
                                 b_resource_id          NUMBER,
                                 b_principal_id         NUMBER,
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
             NVL (t.timezone_id, cac_sync_task_common.g_client_timezone_id) timezone_id,
             t.task_id,
             t.owner_type_code,
             t.source_object_type_code,
             t.recurrence_rule_id,
             ta.assignment_status_id,
             greatest(t.object_changed_date, ta.last_update_date) new_timestamp,
             CAC_VIEW_UTIL_PUB.get_locations(t.task_id) locations,
             ta.free_busy_type free_busy_type,
             t.entity
        FROM jtf_task_all_assignments ta,
             jtf_task_priorities_b tb,
             jtf_tasks_tl tl,
             jtf_tasks_b t
       WHERE ta.resource_id = b_resource_id
         AND ta.resource_type_code = b_resource_type
     /*    AND ta.assignment_status_id IN (3,   -- Accepted
                                         18   -- Invited
                                        )*/
     --commented out the assignment status code. Please look at bug 4404244
         AND  ta.assignment_status_id <> 4 --rejected task should not be synced to the client._bug 4698139
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
                            AND tm.resource_id = cac_sync_task.g_login_resource_id
                            AND tm.principal_id = b_principal_id)
         AND t.recurrence_rule_id IS NULL
         AND decode(t.source_object_type_code,'APPOINTMENT','APPOINTMENT','TASK')  = b_source_object_type
         AND decode(t.entity, 'APPOINTMENT','APPOINTMENT','TASK', 'TASK','BOOKING')  =  b_source_object_type
         AND tl.task_id = t.task_id
         AND tl.language = USERENV ('LANG')

         AND tb.task_priority_id (+) = t.task_priority_id
         AND NVL(t.open_flag,'Y') = 'Y' -- Enh# 2666995
         AND (  ta.last_update_date > b_syncanchor
             OR t.object_changed_date > b_syncanchor)
         AND nvl(t.calendar_end_date,sysdate+1) > (sysdate - G_SYNC_DAYS_BEFORE )
	     AND NVL (t.deleted_flag, 'N') = 'N'
          and NOT EXISTS (select 1 from jta_task_exclusions where task_id=t.task_id);

           -- (t.calendar_end_date > (sysdate - G_SYNC_DAYS_BEFORE ))
           --  OR
           --  ( (G_CAC_SYNC_TASK_NO_DATE = 'TRUE') AND (t.calendar_end_date IS NULL) );



   CURSOR c_modify_non_repeat_task (
      b_syncanchor           DATE,
      b_resource_id          NUMBER,
      b_principal_id         NUMBER,
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
             NVL (t.timezone_id, cac_sync_task_common.g_client_timezone_id) timezone_id,
             tm.task_sync_id,
             t.task_id,
             t.owner_type_code,
             t.source_object_type_code,
             t.recurrence_rule_id,
             ta.assignment_status_id,
             greatest(t.object_changed_date, ta.last_update_date) new_timestamp,
             CAC_VIEW_UTIL_PUB.get_locations(t.task_id) locations,
             ta.free_busy_type free_busy_type,
             t.entity
        FROM jta_sync_task_mapping tm,
             jtf_task_all_assignments ta,
             jtf_task_priorities_b tb,
             jtf_tasks_tl tl,
             jtf_tasks_b t
       WHERE tm.resource_id = cac_sync_task.g_login_resource_id
         AND tm.principal_id = b_principal_id
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
         AND ta.assignment_status_id <> 4 --rejected task should not be synced to the client. Please refer to bug 4698139
     --    AND ta.assignment_status_id IN (3, 18) -- Accepted, Invited,     --commented out the assignment status code. Please look at bug 4404244
         AND ta.resource_id = b_resource_id
         AND t.recurrence_rule_id IS NULL
         AND task_type_id <> 22
         AND (  t.object_changed_date > b_syncanchor
             OR (SELECT MAX(last_update_date) FROM jtf_task_all_assignments
	 	WHERE task_id = t.task_id) > b_syncanchor)
         --AND (  ta.last_update_date > (sysdate - G_SYNC_DAYS_BEFORE )
          --   OR t.object_changed_date > (sysdate - G_SYNC_DAYS_BEFORE ))
         AND  nvl(t.calendar_end_date,sysdate+1) > (sysdate - G_SYNC_DAYS_BEFORE )
         AND tl.task_id = t.task_id
         AND ta.resource_type_code = b_resource_type
         AND ta.resource_id = b_resource_id
         AND NVL(t.open_flag,'Y') = 'Y' -- Enh# 2666995
         AND decode(t.source_object_type_code,'APPOINTMENT','APPOINTMENT','TASK')  = b_source_object_type
         AND decode(t.entity, 'APPOINTMENT','APPOINTMENT','TASK', 'TASK','BOOKING')  =  b_source_object_type
         AND tl.language = USERENV ('LANG')
         AND tb.task_priority_id (+) = t.task_priority_id
	     AND NVL (t.deleted_flag, 'N') = 'N'
        and NOT EXISTS (select 1 from jta_task_exclusions where task_id=t.task_id);


   CURSOR c_delete_unsubscribed (
       b_resource_id          NUMBER,
       b_resource_type        VARCHAR2,
       b_principal_id         NUMBER,
       b_source_object_type   VARCHAR2
      )
      IS
       SELECT m.task_sync_id
        FROM  jtf_tasks_b b, jta_sync_task_mapping m
       WHERE b.task_id = m.task_id
        AND m.principal_id =  b_principal_id
        AND m.resource_id = cac_sync_task.g_login_resource_id
        AND NVL (b.deleted_flag, 'N') = 'N'
        AND b.owner_type_code ='RS_GROUP'
        AND b.source_object_type_code = cac_sync_task_common.G_APPOINTMENT
        AND b_resource_id = m.resource_id
        AND b_source_object_type = cac_sync_task_common.G_APPOINTMENT
        AND b_resource_type = 'RS_EMPLOYEE'
        AND NOT EXISTS
        (SELECT 1
          FROM fnd_grants g
        WHERE g.instance_pk1_value = to_char(b.owner_id) -- fix bug bug 2613008
          AND g.grantee_key = to_char(cac_sync_task.g_login_resource_id)
        );


END;   -- Package Specification JTA_SYNC_TASK_CURSORS

/
