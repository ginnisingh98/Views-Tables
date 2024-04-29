--------------------------------------------------------
--  DDL for Package Body JTA_SYNC_TASK_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTA_SYNC_TASK_COMMON" AS
/* $Header: jtavstcb.pls 120.2 2005/12/28 22:19:48 deeprao ship $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                All rights reserved.                                   |
+=======================================================================+
| FILENAME                                                              |
|      jtavstcb.pls                                                     |
|                                                                       |
| DESCRIPTION                                                           |
|      This package is a common for sync task                           |
|                                                                       |
| NOTES                                                                 |
|                                                                       |
|                                                                       |
| Date      Developer        Change                                     |
| ------    ---------------  ---------------------------------------    |
| 19-Feb-2002   cjang        Changed to binary structure for if-test    |
|                               in get_event_type                       |
| 20-Feb-2002   cjang        The followings are not synced              |
|                            1) Change from Task to Appt                |
|                            2) Change from Appt to Task                |
|                               Removed the parameter x_event_type,     |
|                                       x_object form get_event_type    |
|                               We do not sync the tasks on public      |
|                                    calendar                           |
|                            Changed get_group_calendar()               |
| 21-Feb-2002   cjang        Refactoring                                |
| 22-Feb-2002   cjang        Refactoring                                |
| 25-Feb-2002   cjang        Bug Fix on set_alarm_date()                |
|                            Removed include_record()                   |
|                            Removed ABS() on get_alarm_mins()          |
|                            Modified get_client_priority()             |
| 27-Feb-2002   cjang        Added can_update_task, get_max_enddate     |
|                            Modified add_task                          |
| 28-Feb-2002   cjang        Integrate with invitee function            |
| 01-Mar-2002   cjang        Refactoring and Bug Fix                    |
| 06-Mar-2002   cjang        Added get_all_nonrepeat_tasks              |
|                                  get_all_repeat_tasks                 |
|                                  create_new_data                      |
|                                  update_existing_data                 |
|                                  add_nonrepeat_task                   |
|                                  add_repeat_task                      |
|                            Modified parameters on add_task            |
| 08-Mar-2002   arpatel      Added all attributes for update of         |
|                              repeating appointments                   |
| 11-Mar-2002   cjang        Added the followings                       |
|                              - delete_exclusion_task                  |
|                              - delete_task_data                       |
|                              - reject_task_data                       |
|                              - changed_repeat_rule                    |
|                              - update_repeating_rule                  |
| 11-Mar-2002   sanjeev      - changed methods for exclusions           |
|                            - changed update_existing_data()           |
| 13-Mar-2002   cjang        Added insert_or_update_mapping             |
|                            Changed OUT to IN OUT on the parameter     |
|                               x_task_rec in delete_exclusion_task     |
| 14-Mar-2002   arpatel      Added privateFlag to create_new_data       |
|                             and update_existing_data                  |
| 14-Mar-2002  ssallaka      Added get_exclusion _data                  |
| 15-Mar-2002  ssallaka      Added count_exclusion                      |
| 25-Mar-2002  sanjeev       Added procedure transformStatus()          |
|                                  function getChangedStatusId()  and   |
|                                           checkUserStatusRule()       |
| 04-Apr-2002  cjang         Modified convert_recur_date_to_client      |
|                            TO_DATE should only use numbers            |
| 08-Apr-2002  arpatel       Merged convert_dates2 with convert_dates   |
| 09-APr-2002  ssallaka      Choping the subject of task if it is       |
|                            more than 80 chars and fixed the typo      |
|                              of tuesday in task_rec                   |
| 19-Apr-2002   cjang            Removed p_get_data from add_task()     |
| 24-Apr-2002   cjang        Process exclusion first, and update        |
| 25-Apr-2002   cjang        Modified update_existing_data() to fix     |
|                               the length(80) issue of task name       |
|                            Modified get_all_deleted_tasks to execute  |
|                               the new cursor c_delete_assignee_reject |
|                              to pick up the appts rejected by assignee|
| 26-Apr-2002   cjang        Modified all the calls to check_span_days  |
|                              to pass source_object_type_code          |
|                              rather than p_request_type               |
|                            All delete cursor has now p_resource_type  |
| 30-Apr-2002   cjang        Added a new parameter p_resource_type      |
|                                in get_assignment_id                   |
|                            Fixed the undefined message name           |
| 01-May-2002   cjang        Fixed task_name length issue               |
|                            Added convert_carriage_return              |
|                            Modified get_subject                       |
| 17-May-2002   cjang        Fix for the bug 2380399                    |
|                             Modified update_existing_data()           |
| 21-May-2002   cjang        Modified get_exclusion_data()              |
|                             Added "DISTINCT" in the cursor c_exclusion|
| 23-May-2002   cjang        Modified add_task() to fix bug 2389092     |
|                              it defaults x_task_rec.dateselected with |
|                              'S' when it's NULL.                      |
|                            Added validate_syncid() to fix bug 2382927 |
| 29-May-2002   cjang        Modified validate_syncid()                 |
|                               to fix Bug# 2395004                     |
|                                                                       |
| 02-Jul-2002   cjang        (Fix Bug: 2442686) Ver: 115.75             |
|                            If this is TASK, assignee can update any   |
|                            fields, but if it's APPOINTMENT, then      |
|                            the invitee can update only the status when|
|                            he/she accept the appointment.             |
|                            Modified get_update_type()                 |
|                              to check source object type code when the|
|                              login user is an assignee for the task   |
|                                                                       |
|                            (Fix Bug: 2443049) Ver: 115.76             |
|                            When a new task is synced from Outlook,    |
|                            display on calendar should be checked.     |
|                            When a updated task is synced from Outlook,|
|                            display on calendar should not be nullified|
| 04-Oct-2002   cjang        To fix bug 2540722,                        |
|                             in ADD_TASK()                             |
|                              1)  Change local varible definition      |
|                                  from l_category_name   VARCHAR2(40); |
|                                    to l_category_name   VARCHAR2(240);|
|                                                                       |
|                              2)  Change from                          |
|           l_category_name := jtf_task_utl.get_category_name_for_task( |
|                                p_task_id => p_task_id,                |
|                                p_resource_id => p_resource_id,        |
|                                p_resource_type_code => p_resource_type|
|                             );                                        |
|            to                                                         |
|    l_category_name := substrb(jtf_task_utl.get_category_name_for_task(|
|                           p_task_id => p_task_id,                     |
|                           p_resource_id => p_resource_id,             |
|                           p_resource_type_code => p_resource_type     |
|                        ), 1, 240);                                    |
|                                                                       |
|                            To Fix bug 2608703, Removed the followings |
|                             IF (l_category_name = 'Unfiled')          |
|                             THEN                                      |
|                               l_category_name := NULL;                |
|                             END IF;                                   |
| 04-Oct-2002   cjang        Fixed bug 2469488, 2469487, 2469479        |
|                             1) Modified get_all_nonrepeat_tasks       |
|                             2) Modified get_all_deleted_tasks         |
|                             3) Modified get_all_repeat_tasks          |
|                             4) Added already_selected()               |
|                            Fixed bug 2482833                          |
|                             1) Added get_sync_info()                  |
|                             2) Modified get_update_type()             |
|                            Fixed GSCC Warning                         |
|                            File.Pkg.22                                |
|                            1190-1, 1511, 2527, 3144 -                 |
|                            No default parameter values in package body|
| 09-Oct-2002   cjang       Fixed bug 2467021                           |
|                            Modified convert_dates(),create_new_data(),update_existing_data():
|                            If it is APPOINTMENT, pass Y for show_on_calendar and pass P for date_selected.
|                            This is coded by the package jta_cal_appointment_pvt.
|                            If it is TASK for creation, pass show_on_calendar and date_selected as NULL
|                            if it is TASK for update, pass show_on_calendar and date_selected as g_miss_char
| 22-Oct-2002   cjang       Fixed bug 2635512, Removed debug_pkg.add    |
| 01-Nov-2002   cjang       Fixed bug 2540722                           |
|                            Call jtf_task_security_pvt.get_category_id()|
|                               and jtf_task_utl.get_category_name()    |
|                                instead of calling jtf_task_utl.get_category_name_for_task()
| 07-Nov-2002   cjang       Removed the code fix for the bug 2469488,   |
|                             2469487, 2469479                          |
|                             But keep the function already_selected()  |
|                                so this version 115.82 is basically    |
|                                  same as 115.81                       |
|                             Here just removed the comment             |
|                                "Fixed bug 2469488, 2469487, 2469479"  |
*=======================================================================*/

   PROCEDURE check_span_days (
      p_source_object_type_code   IN VARCHAR2,
      p_calendar_start_date       IN DATE,
      p_calendar_end_date         IN DATE,
      x_status                   OUT NOCOPY BOOLEAN
   )
   IS
   BEGIN
      -------------------------------------------
      -- Returns TRUE:
      --   1) if an appointment spans over a day
      --   2) if a task is endless
      -------------------------------------------
      x_status := FALSE;

      IF   (p_source_object_type_code = G_TASK AND
            p_calendar_end_date   IS NULL AND
            p_calendar_start_date IS NOT NULL
           )
        OR (p_source_object_type_code = G_APPOINTMENT AND
            TRUNC (p_calendar_start_date) <> TRUNC (p_calendar_end_date)
           )
      THEN
          x_status := TRUE;
      END IF;

   END check_span_days;

   FUNCTION convert_carriage_return(
                        p_subject IN VARCHAR2
                       ,p_type    IN VARCHAR2)
   RETURN VARCHAR2
   IS
      l_from VARCHAR2(10);
      l_to   VARCHAR2(10);
   BEGIN
      IF p_type = 'ORACLE'
      THEN
          l_from := G_CARRIAGE_RETURN_XML;
          l_to   := G_CARRIAGE_RETURN_ORACLE;
      ELSE
          l_from := G_CARRIAGE_RETURN_ORACLE;
          l_to   := G_CARRIAGE_RETURN_XML;
      END IF;

      RETURN REPLACE(p_subject, l_from ,l_to);
   END convert_carriage_return;

   FUNCTION get_subject(p_subject IN VARCHAR2
                       ,p_type    IN VARCHAR2)
   RETURN VARCHAR2
   IS
      l_from VARCHAR2(10);
      l_to   VARCHAR2(10);
   BEGIN
      RETURN SUBSTR(convert_carriage_return(p_subject,p_type), 1, 80);
   END get_subject;

   PROCEDURE convert_recur_date_to_gmt (
      p_timezone_id   IN       NUMBER,
      p_base_start_date   IN       DATE,
      p_base_end_date     IN       DATE,
      p_start_date    IN       DATE,
      p_end_date      IN       DATE,
      p_item_display_type      IN NUMBER,
      p_occurs_which      IN       NUMBER,
      p_uom       IN       VARCHAR2,
      x_date_of_month     OUT NOCOPY      NUMBER,
      x_start_date    IN OUT NOCOPY      DATE,
      x_end_date      IN OUT NOCOPY      DATE
   )
   IS
      l_start_date   VARCHAR2(11);   -- DD-MON-YYYY
      l_start_time   VARCHAR2(8);   -- HH24:MI:SS
      l_end_date     VARCHAR2(11);   -- DD-MON-YYYY
      l_end_time     VARCHAR2(8);   -- HH24:MI:SS
   BEGIN
      l_start_date := TO_CHAR (p_start_date, 'DD-MON-YYYY');
      l_start_time := TO_CHAR (p_base_start_date, 'HH24:MI:SS');
      l_end_date := TO_CHAR (p_end_date, 'DD-MON-YYYY');
      l_end_time := TO_CHAR (p_base_end_date, 'HH24:MI:SS');

      IF p_item_display_type <> 3 THEN
      x_start_date :=
       convert_task_to_gmt (
        TO_DATE (
           l_start_date || ' ' || l_start_time,
           'DD-MON-YYYY HH24:MI:SS'
        ),
        p_timezone_id
       );
        x_end_date :=
       convert_task_to_gmt (
        TO_DATE (
           l_end_date || ' ' || l_end_time,
           'DD-MON-YYYY HH24:MI:SS'
        ),
        p_timezone_id
       );
      ELSE
         x_start_date := TO_DATE (
           l_start_date || ' ' || l_start_time,
           'DD-MON-YYYY HH24:MI:SS');
        x_end_date :=TO_DATE (
           l_end_date || ' ' || l_end_time,
           'DD-MON-YYYY HH24:MI:SS'
        );
       END IF;
      x_start_date := TRUNC (x_start_date);
      x_end_date := TRUNC (x_end_date);

      IF     p_occurs_which IS NULL
        AND (p_uom = 'MON' OR p_uom ='YER') THEN
        x_date_of_month := TO_CHAR (x_start_date, 'DD');
      END IF;
   END convert_recur_date_to_gmt;

   PROCEDURE process_exclusions (
         p_exclusion_tbl      IN     jta_sync_task.exclusion_tbl,
         p_rec_rule_id        IN     NUMBER,
         p_repeating_task_id  IN     NUMBER,
         p_task_rec           IN OUT NOCOPY jta_sync_task.task_rec
   )
   IS
       i NUMBER := 0;
       l_exclude_task_id NUMBER ;
   BEGIN
       FOR i IN p_exclusion_tbl.FIRST .. p_exclusion_tbl.LAST
       LOOP
          l_exclude_task_id := get_excluding_taskid (
                  p_sync_id            => p_task_rec.syncid,
                  p_recurrence_rule_id => p_rec_rule_id,
                  p_exclusion_rec      => p_exclusion_tbl (i)
          );

          IF l_exclude_task_id > 0
          THEN
              delete_exclusion_task (
                  p_repeating_task_id => l_exclude_task_id,
                  x_task_rec          => p_task_rec
              );
          END IF; -- l_task_id
       END LOOP;
   END process_exclusions;

   FUNCTION get_default_task_type
      RETURN NUMBER
   IS
   BEGIN
      RETURN NVL (
        fnd_profile.VALUE ('JTF_TASK_DEFAULT_TASK_TYPE'),
        g_task_type_general
         );
   END;

   FUNCTION is_this_new_task (p_sync_id IN NUMBER)
      RETURN BOOLEAN
   IS
      CURSOR c_synctask
      IS
     SELECT task_id
       FROM jta_sync_task_mapping
      WHERE task_sync_id = p_sync_id;

      l_task_id   NUMBER;
   BEGIN
      IF    p_sync_id IS NULL OR
            p_sync_id < 1
      THEN
         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_INVALID_SYNCID');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.IS_THIS_NEW_TASK');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      OPEN c_synctask;
      FETCH c_synctask INTO l_task_id;

      IF c_synctask%NOTFOUND
      THEN
     CLOSE c_synctask;
     RETURN TRUE;
      ELSE
     CLOSE c_synctask;
     RETURN FALSE;
      END IF;
   END;

   -- count num of exclusions from jta_task_exclusion
   FUNCTION count_exclusions (p_recurrence_rule_id IN NUMBER)
      RETURN NUMBER
   IS
      l_count   NUMBER;
   BEGIN
      SELECT COUNT (recurrence_rule_id)
    INTO l_count
    FROM jta_task_exclusions
       WHERE recurrence_rule_id = p_recurrence_rule_id;
      RETURN l_count;
   END count_exclusions;

   FUNCTION count_excluded_tasks (p_recurrence_rule_id IN NUMBER)
      RETURN NUMBER
   IS
      l_count   NUMBER;
   BEGIN
      SELECT COUNT (recurrence_rule_id)
    INTO l_count
    FROM jtf_tasks_b
       WHERE recurrence_rule_id = p_recurrence_rule_id;
      RETURN l_count;
   END count_excluded_tasks;

   FUNCTION check_for_exclusion (
      p_sync_id           IN   NUMBER,
      p_exclusion_tbl         IN   jta_sync_task.exclusion_tbl,
      p_calendar_start_date   IN   DATE,
      p_client_time_zone_id   IN   NUMBER
      )
      RETURN BOOLEAN
   IS
      is_exclusion   BOOLEAN;
      l_task_date    DATE;
   BEGIN
      IF    (p_exclusion_tbl.COUNT = 0)
     OR (p_exclusion_tbl IS NULL)
      THEN
     RETURN FALSE;
      ELSE
     is_exclusion := FALSE;

     FOR i IN p_exclusion_tbl.FIRST .. p_exclusion_tbl.LAST
     LOOP
        l_task_date := p_calendar_start_date;

        IF     (p_sync_id = p_exclusion_tbl (i).syncid)
           AND (TRUNC (l_task_date) =
              TRUNC (p_exclusion_tbl (i).exclusion_date))
        THEN
           is_exclusion := TRUE;
           EXIT;
        END IF;
     END LOOP;   --end of the loop

     RETURN is_exclusion;
      END IF;
   END;

   FUNCTION get_excluding_taskid (
              p_sync_id          IN   NUMBER,
              p_recurrence_rule_id   IN   NUMBER,
              p_exclusion_rec        IN   jta_sync_task.exclusion_rec
   )
   RETURN NUMBER
   IS
      CURSOR c_recur_tasks (b_recurrence_rule_id     NUMBER,
                            b_exclusion_start_date   DATE)
      IS
         SELECT task_id
           FROM jtf_tasks_b
          WHERE recurrence_rule_id = b_recurrence_rule_id
            AND TRUNC (calendar_start_date) = TRUNC (b_exclusion_start_date);

      l_task_id   NUMBER;
   BEGIN
      OPEN c_recur_tasks (
          b_recurrence_rule_id => p_recurrence_rule_id,
          b_exclusion_start_date => p_exclusion_rec.exclusion_date
       );
      FETCH c_recur_tasks INTO l_task_id;

      IF c_recur_tasks%NOTFOUND
      THEN
         l_task_id := -9;
      END IF;

      CLOSE c_recur_tasks;

      IF p_sync_id <> p_exclusion_rec.syncid
      THEN
         l_task_id := -9;
      END IF;

      RETURN l_task_id;
   END;

   FUNCTION set_alarm_date (
      p_task_id            IN   NUMBER,
      p_request_type           IN   VARCHAR2,
      p_scheduled_start_date   IN   DATE,
      p_planned_start_date     IN   DATE,
      p_actual_start_date      IN   DATE,
      p_alarm_flag         IN   VARCHAR2,
      p_alarm_start        IN   NUMBER
      )
      RETURN DATE
   IS
      l_date_selected   VARCHAR2(1);
      l_date        DATE;
      l_alarm_date  DATE;
      l_alarm_days  NUMBER;

      CURSOR c_dateselect
      IS
     SELECT jt.date_selected
       FROM jtf_tasks_b jt
      WHERE jt.task_id = p_task_id;
   --check for alarm flag

   BEGIN
      IF p_alarm_flag = 'Y'
      THEN
     OPEN c_dateselect;
     FETCH c_dateselect INTO l_date_selected;

     IF    c_dateselect%NOTFOUND
        OR l_date_selected = 'P'
        OR p_request_type = G_REQ_APPOINTMENT
     THEN
        l_date := p_planned_start_date;
     ELSIF l_date_selected = 'S'
     THEN
        l_date := p_scheduled_start_date;
     ELSIF l_date_selected = 'A'
     THEN
        l_date := p_actual_start_date;
     END IF;

     CLOSE c_dateselect;
     l_alarm_days := p_alarm_start / 1440;
     l_alarm_date := l_date - l_alarm_days;
      END IF;

      RETURN l_alarm_date;
   END;

   FUNCTION get_task_id (p_sync_id IN NUMBER)
      RETURN NUMBER
   IS
      CURSOR c_task_sync
      IS
     SELECT task_id
       FROM jta_sync_task_mapping
      WHERE task_sync_id = p_sync_id;

      l_task_id   NUMBER;
   BEGIN
      IF    p_sync_id IS NULL
     OR p_sync_id < 1
      THEN
         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_INVALID_SYNCID');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_TASK_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);

      END IF;

      OPEN c_task_sync;
      FETCH c_task_sync INTO l_task_id;

      IF c_task_sync%NOTFOUND
      THEN
          CLOSE c_task_sync;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_NOTFOUND_TASKID');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_TASK_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      ELSIF l_task_id IS NULL
      THEN
         CLOSE c_task_sync;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_NULL_TASKID');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_TASK_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      CLOSE c_task_sync;
      RETURN l_task_id;
   END;

   FUNCTION get_task_id (p_task_assignment_id IN NUMBER)
      RETURN NUMBER
   IS
      CURSOR c_task
      IS
     SELECT task_id
       FROM jtf_task_all_assignments
      WHERE task_assignment_id = p_task_assignment_id;

      l_task_id   NUMBER;
   BEGIN
      OPEN c_task;
      FETCH c_task INTO l_task_id;

      IF c_task%NOTFOUND
      THEN
         CLOSE c_task;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_NOTFOUND_TASKID');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_TASK_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      CLOSE c_task;
      RETURN l_task_id;
   END;

   FUNCTION get_task_timezone_id (p_task_id IN NUMBER)
      RETURN NUMBER
   IS
      CURSOR c_task_timezone
      IS
     SELECT timezone_id
       FROM jtf_tasks_b
      WHERE task_id = p_task_id;

      l_task_timezone_id   NUMBER;
   BEGIN
      OPEN c_task_timezone;
      FETCH c_task_timezone INTO l_task_timezone_id;

      IF c_task_timezone%NOTFOUND
      THEN
         CLOSE c_task_timezone;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_TIMEZONEID_NOTFOUND');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_TASK_TIMEZONE_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);

      END IF;

      CLOSE c_task_timezone;

      IF l_task_timezone_id IS NULL
      THEN
     l_task_timezone_id :=
        NVL (fnd_profile.VALUE ('CLIENT_TIMEZONE_ID'), 0);
      END IF;

      RETURN l_task_timezone_id;
   END;

   FUNCTION get_ovn (p_task_id IN NUMBER)
      RETURN NUMBER
   IS
      CURSOR c_tasks_ovn (b_task_id NUMBER)
      IS
     SELECT object_version_number
       FROM jtf_tasks_b
      WHERE task_id = b_task_id;

      l_object_version_number   NUMBER;
   BEGIN
      OPEN c_tasks_ovn (p_task_id);
      FETCH c_tasks_ovn into l_object_version_number;

      IF c_tasks_ovn%NOTFOUND
      THEN
         CLOSE c_tasks_ovn;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_TASK_OVN_NOTFOUND');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_OVN');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      CLOSE c_tasks_ovn;
      RETURN l_object_version_number;
   END get_ovn;

   FUNCTION get_ovn (p_task_assignment_id IN NUMBER)
      RETURN NUMBER
   IS
      CURSOR c_assignment_ovn (b_task_assignment_id NUMBER)
      IS
     SELECT object_version_number
       FROM jtf_task_all_assignments
      WHERE task_assignment_id = b_task_assignment_id;

      l_object_version_number   NUMBER;
   BEGIN
      OPEN c_assignment_ovn (p_task_assignment_id);
      FETCH c_assignment_ovn into l_object_version_number;

      IF c_assignment_ovn%NOTFOUND
      THEN
         CLOSE c_assignment_ovn;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_ASSIGNMT_OVN_NOTFOUND');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_OVN');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      CLOSE c_assignment_ovn;
      RETURN l_object_version_number;
   END get_ovn;

   PROCEDURE get_resource_details (
      x_resource_id OUT NOCOPY   NUMBER,
      x_resource_type   OUT NOCOPY   VARCHAR2
   )
   IS
      CURSOR c_resource
      IS
     SELECT resource_id, 'RS_' || category
       FROM jtf_rs_resource_extns
      WHERE user_id = fnd_global.user_id;
   BEGIN
      OPEN c_resource;
      FETCH c_resource INTO x_resource_id, x_resource_type;

      IF c_resource%NOTFOUND
      THEN
         CLOSE c_resource;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_RESOURCE_NOTFOUND');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_RESOURCE_DETAILS');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      CLOSE c_resource;

   END get_resource_details;

   PROCEDURE do_mapping(p_task_id       IN     NUMBER,
                        p_operation     IN     VARCHAR2,
                        x_task_sync_id  IN OUT NOCOPY  NUMBER
   )
   IS
   BEGIN
      IF (p_operation = g_new)
      THEN
            IF x_task_sync_id IS NULL
            THEN
               SELECT jta_sync_task_mapping_s.nextval
               INTO x_task_sync_id
               FROM dual;
            END IF;

            jta_sync_task_map_pkg.insert_row (
                p_task_sync_id => x_task_sync_id,
                p_task_id      => p_task_id,
                p_resource_id  => jta_sync_task.g_login_resource_id
            );
      ELSIF p_operation = g_modify
      THEN
            jta_sync_task_map_pkg.update_row (
                p_task_sync_id => x_task_sync_id,
                p_task_id      => p_task_id,
                p_resource_id  => jta_sync_task.g_login_resource_id
            );
/*  ELSIF p_operation = G_DELETE
      THEN
        jta_sync_task_map_pkg.delete_row (
        p_task_sync_id => x_task_sync_id
     );*/

      END IF;
   END do_mapping;

   /*PROCEDURE get_event_type (
      p_deleted_flag         IN     VARCHAR2,
      p_task_sync_id         IN     NUMBER,
      p_source_object_type_code IN  VARCHAR2,
      p_calendar_start_date  IN     DATE,
      p_calendar_end_date    IN     DATE,
      p_assignment_status_id IN     NUMBER,
      x_operation          OUT NOCOPY VARCHAR2
   )
   IS
      l_deleted_flag        VARCHAR2(1) := NVL (p_deleted_flag, 'N');
      l_task_sync_id        NUMBER  := p_task_sync_id;
      l_calendar_start_date DATE    := p_calendar_start_date;
      l_calendar_end_date   DATE    := p_calendar_end_date;
   BEGIN
      -- For task, we sync a task with the spanned day
      -- For Appt, we don't a task with the spanned day
      IF l_calendar_start_date IS NOT NULL AND
     (l_calendar_end_date IS NULL OR
      (p_source_object_type_code = G_APPOINTMENT AND
       trunc(l_calendar_start_date) <> trunc(l_calendar_end_date))
     )
      THEN
      IF l_task_sync_id IS NOT NULL
      THEN
          x_operation := G_DELETE;
      END IF;
      RETURN;
      END IF;

      IF l_task_sync_id IS NOT NULL
      THEN
      IF l_deleted_flag = 'Y' OR
         p_assignment_status_id = 4 -- Rejected
      THEN
          x_operation := G_DELETE;
      ELSE -- l_deleted_flag = 'N'
          x_operation  := G_MODIFY;
      END IF;
      ELSE -- l_task_sync_id IS NULL
      IF l_deleted_flag = 'N' AND
         nvl(p_assignment_status_id,-1) <> 4 -- Not Rejected
      THEN
         x_operation := G_NEW;
      END IF;
      END IF;
   END get_event_type;
*/
   FUNCTION get_group_team_tasks (p_resource_id IN NUMBER)
      RETURN resource_list_tbl
   IS
      CURSOR c_group_id (b_resource_id IN VARCHAR2)
      IS
     SELECT group_id resource_id
       FROM jtf_rs_group_members
      WHERE resource_id = b_resource_id
        AND delete_flag <> 'Y';

      CURSOR c_team_id (b_resource_id IN VARCHAR2)
      IS
     SELECT team_id resource_id
       FROM jtf_rs_team_members
      WHERE team_resource_id = b_resource_id
        AND delete_flag <> 'Y';

      l_group_resource_tbl   resource_list_tbl;
      i              BINARY_INTEGER    := 0;
   BEGIN
      FOR r_resources IN c_group_id (b_resource_id => p_resource_id)
      LOOP
     i := i + 1;
     l_group_resource_tbl (i).resource_id := r_resources.resource_id;
     l_group_resource_tbl (i).resource_type := 'RS_GROUP';
      END LOOP;

      FOR r_resources IN c_team_id (b_resource_id => p_resource_id)
      LOOP
     i := i + 1;
     l_group_resource_tbl (i).resource_id := r_resources.resource_id;
     l_group_resource_tbl (i).resource_type := 'RS_TEAM';
      END LOOP;

      RETURN l_group_resource_tbl;
   END get_group_team_tasks;

   FUNCTION get_group_calendar (p_resource_id IN NUMBER)
      RETURN resource_list_tbl
   IS
      ------------------------------------------------------------------------------
      -- This does not pick up the public calendar, pick up only group calendar
      ------------------------------------------------------------------------------
      CURSOR c_group_calendar (b_resource_id IN VARCHAR2)
      IS
     SELECT DISTINCT fgs.instance_pk1_value resource_id,
             fgs.instance_pk2_value resource_type
       FROM fnd_grants fgs,
        fnd_menus fmu,
        fnd_objects fos,
        jtf_rs_group_usages jru,
        jtf_rs_groups_tl jrt
      WHERE fgs.object_id = fos.object_id   -- grants joint to object
        AND fgs.menu_id = fmu.menu_id   -- grants joint to menus
        AND fos.obj_name = 'JTF_TASK_RESOURCE'
        AND fgs.grantee_key = b_resource_id
        AND fgs.grantee_type = 'USER'
        AND fgs.start_date < SYSDATE
        AND (  fgs.end_date >= SYSDATE
        OR fgs.end_date IS NULL)
        AND fgs.instance_pk2_value = 'RS_GROUP'
        AND jrt.group_id = TO_NUMBER (fgs.instance_pk1_value)
        AND jrt.language = USERENV ('LANG')
        AND jru.group_id = jrt.group_id
        AND jru.usage = 'GROUP_CALENDAR';

      l_group_resource_tbl   resource_list_tbl;
      i              BINARY_INTEGER    := 0;
   BEGIN
      FOR r_resources IN c_group_calendar (b_resource_id => p_resource_id)
      LOOP
     i := i + 1;
     l_group_resource_tbl (i).resource_id := r_resources.resource_id;
     l_group_resource_tbl (i).resource_type := r_resources.resource_type;
      END LOOP;   --r_resources

      RETURN l_group_resource_tbl;
   END get_group_calendar;

   PROCEDURE get_group_resource (
      p_request_type    IN   VARCHAR2,
      p_resource_id IN   NUMBER,
      p_resource_type   IN   VARCHAR2,
      x_resources   OUT NOCOPY  resource_list_tbl
   )
   IS
      res_index   BINARY_INTEGER;
   BEGIN
      IF p_request_type = G_REQ_APPOINTMENT
      THEN
          x_resources := get_group_calendar (p_resource_id => p_resource_id);
      ELSIF p_request_type = G_REQ_TASK
      THEN
          x_resources := get_group_team_tasks (p_resource_id => p_resource_id);
      END IF;

      res_index := NVL (x_resources.LAST, 0) + 1;
      x_resources (res_index).resource_id := p_resource_id;
      x_resources (res_index).resource_type := p_resource_type;
   END get_group_resource;

   PROCEDURE get_alarm_mins (
      p_task_rec     IN       jta_sync_task.task_rec,
      x_alarm_mins   OUT NOCOPY      NUMBER
   )
   IS
      l_alarm_days   NUMBER;
   BEGIN
      IF (p_task_rec.objectcode = G_APPOINTMENT)
      THEN
     IF (p_task_rec.alarmflag = 'Y')
     THEN
        l_alarm_days :=
           p_task_rec.plannedstartdate - p_task_rec.alarmdate;
        x_alarm_mins := ROUND (l_alarm_days * 1440, 0);
     ELSE
        x_alarm_mins := NULL;
     END IF;
      ELSE
     x_alarm_mins := NULL;
      END IF;
   END get_alarm_mins;

   FUNCTION convert_gmt_to_client (p_date IN DATE)
      RETURN DATE
   IS
      l_date   DATE;
   BEGIN
      jtf_cal_utility_pvt.adjustfortimezone (
     g_gmt_timezone_id,
     NVL (g_client_timezone_id, g_server_timezone_id),
     p_date,
     l_date
      );
      RETURN l_date;
   END;

   FUNCTION convert_task_to_gmt (p_date IN DATE, p_timezone_id IN NUMBER)
      RETURN DATE
   IS
      l_date   DATE;
   BEGIN
      jtf_cal_utility_pvt.adjustfortimezone (
     p_timezone_id,
     g_gmt_timezone_id,
     p_date,
     l_date
      );
      RETURN l_date;
   END convert_task_to_gmt;

   FUNCTION convert_server_to_gmt (p_date IN DATE)
      RETURN DATE
   IS
      l_date   DATE;
   BEGIN
      jtf_cal_utility_pvt.adjustfortimezone (
     g_server_timezone_id,
     g_gmt_timezone_id,
     p_date,
     l_date
      );
      RETURN l_date;
   END convert_server_to_gmt;

   FUNCTION convert_gmt_to_task (p_date IN DATE, p_task_id IN NUMBER)
      RETURN DATE
   IS
      l_date           DATE;
      l_task_timezone_id   NUMBER;
   BEGIN
      l_task_timezone_id := get_task_timezone_id (p_task_id);

      IF l_task_timezone_id <> g_gmt_timezone_id
      THEN
     jtf_cal_utility_pvt.adjustfortimezone (
        g_gmt_timezone_id,
        l_task_timezone_id,
        p_date,
        l_date
     );
      ELSE
     l_date := p_date;
      END IF;

      RETURN l_date;
   END convert_gmt_to_task;

   FUNCTION convert_gmt_to_server (p_date IN DATE)
      RETURN DATE
   IS
      l_date   DATE;
   BEGIN
      jtf_cal_utility_pvt.adjustfortimezone (
     g_gmt_timezone_id,
     g_server_timezone_id,
     p_date,
     l_date
      );
      RETURN l_date;
   END convert_gmt_to_server;

   PROCEDURE convert_dates (
      p_task_rec       IN       jta_sync_task.task_rec,
      p_operation      IN       VARCHAR2, --CREATE OR UPDATE
      x_planned_start      OUT NOCOPY      DATE,
      x_planned_end    OUT NOCOPY      DATE,
      x_scheduled_start    OUT NOCOPY      DATE,
      x_scheduled_end      OUT NOCOPY      DATE,
      x_actual_start       OUT NOCOPY      DATE,
      x_actual_end     OUT NOCOPY      DATE,
      x_date_selected      OUT NOCOPY      VARCHAR2,
      x_show_on_calendar   OUT NOCOPY      VARCHAR2
   )
   IS
      l_task_id NUMBER;
   BEGIN
      -- If it's All Day APMT, do not convert the dates
      IF  (p_task_rec.plannedstartdate = p_task_rec.plannedenddate AND
           TRUNC(p_task_rec.plannedstartdate) = p_task_rec.plannedstartdate) AND
          p_task_rec.objectcode = G_APPOINTMENT
      THEN
         x_planned_start := p_task_rec.plannedstartdate;
         x_planned_end := p_task_rec.plannedenddate;

      -- This is not all day appointment
      ELSE
         IF p_operation = 'CREATE'
         THEN
            IF p_task_rec.objectcode = G_APPOINTMENT
            THEN
               x_planned_start := convert_gmt_to_client(p_task_rec.plannedstartdate);
               x_planned_end   := convert_gmt_to_client(p_task_rec.plannedenddate);
            ELSE
               -- for create task don't do timezone conversion, it's untimed
               x_planned_start   := p_task_rec.plannedstartdate;
               x_planned_end     := p_task_rec.plannedenddate;
               x_scheduled_start := p_task_rec.scheduledstartdate;
               x_scheduled_end   := p_task_rec.scheduledenddate;
               x_actual_start    := p_task_rec.actualstartdate;
               x_actual_end      := p_task_rec.actualenddate;
            END IF;
         ELSIF p_operation = 'UPDATE'
         THEN
            l_task_id := get_task_id (p_sync_id => p_task_rec.syncid);
            x_planned_start   := convert_gmt_to_task (p_task_rec.plannedstartdate,   l_task_id);
            x_planned_end     := convert_gmt_to_task (p_task_rec.plannedenddate,     l_task_id);
            x_scheduled_start := convert_gmt_to_task (p_task_rec.scheduledstartdate, l_task_id);
            x_scheduled_end   := convert_gmt_to_task (p_task_rec.scheduledenddate,   l_task_id);
            x_actual_start    := convert_gmt_to_task (p_task_rec.actualstartdate,    l_task_id);
            x_actual_end      := convert_gmt_to_task (p_task_rec.actualenddate,      l_task_id);
         END IF; -- end-if operation
      END IF; -- end if-all day appt

   END convert_dates;

   PROCEDURE adjust_timezone (
      p_timezone_id        IN   NUMBER,
      p_syncanchor         IN   DATE,
      p_planned_start_date     IN   DATE,
      p_planned_end_date       IN   DATE,
      p_scheduled_start_date   IN   DATE,
      p_scheduled_end_date     IN   DATE,
      p_actual_start_date      IN   DATE,
      p_actual_end_date        IN   DATE,
      p_item_display_type      IN NUMBER,
      x_task_rec           IN OUT NOCOPY   jta_sync_task.task_rec
   )
   IS
   BEGIN

      -------------------------------------------------------------
      -- Decide new syncAnchor and Convert server to GMT timezone
      x_task_rec.syncanchor := convert_server_to_gmt (p_syncanchor);

     IF p_item_display_type = 3 AND x_task_rec.objectcode = G_APPOINTMENT THEN
       x_task_rec.plannedstartdate := p_planned_start_date;
       x_task_rec.plannedenddate   := p_planned_end_date;
     ELSE
       x_task_rec.plannedstartdate := convert_task_to_gmt (p_planned_start_date, p_timezone_id);
       x_task_rec.plannedenddate   := convert_task_to_gmt (p_planned_end_date, p_timezone_id);
       x_task_rec.scheduledstartdate := convert_task_to_gmt (p_scheduled_start_date, p_timezone_id);
       x_task_rec.scheduledenddate := convert_task_to_gmt (p_scheduled_end_date, p_timezone_id);
       x_task_rec.actualstartdate := convert_task_to_gmt (p_actual_start_date, p_timezone_id);
       x_task_rec.actualenddate := convert_task_to_gmt (p_actual_end_date, p_timezone_id);

     END IF;

   END adjust_timezone;

   FUNCTION get_max_enddate (p_recurrence_rule_id IN NUMBER)
      RETURN DATE
   IS
      CURSOR c_recur_tasks
      IS
     SELECT MAX (calendar_end_date)
       FROM jtf_tasks_b
      WHERE recurrence_rule_id = p_recurrence_rule_id;

      l_date   DATE;
   BEGIN
      OPEN c_recur_tasks;
      FETCH c_recur_tasks into l_date;

      IF c_recur_tasks%NOTFOUND
      THEN
         CLOSE c_recur_tasks;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_INVALID_RECUR_RULE_ID');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_MAX_ENDDATE');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      CLOSE c_recur_tasks;

      IF l_date IS NULL
      THEN
         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_NULL_CALENDAR_ENDDATE');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_MAX_ENDDATE');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      RETURN l_date;
   END get_max_enddate;

   procedure  get_exclusion_data (p_recurrence_rule_id IN NUMBER,  p_exclusion_data in out NOCOPY  jta_sync_task.exclusion_tbl,

   p_task_sync_id in number )
---  RETURN jta_sync_task.exclusion_tbl
   IS
      CURSOR c_exclusion
      IS
     SELECT DISTINCT exclusion_date ex_date
       FROM jta_task_exclusions
      WHERE recurrence_rule_id = p_recurrence_rule_id;

      l_date         DATE;
---  l_exclusion_data   jta_sync_task.exclusion_tbl;
      l_exclusion    c_exclusion%ROWTYPE;
      i          BINARY_INTEGER          := nvl(p_exclusion_data.last,0) ;
   BEGIN
      FOR l_exclusion IN c_exclusion
      LOOP
     i := i + 1;
     p_exclusion_data (i).exclusion_date := l_exclusion.ex_date;
     p_exclusion_data (i).syncid := p_task_sync_id;
      END LOOP;

---  RETURN l_exclusion_data;
   END get_exclusion_data;

   FUNCTION already_selected(p_task_id     IN NUMBER
                            ,p_sync_id     IN NUMBER
                            ,p_task_tbl    IN jta_sync_task.task_tbl)
   RETURN BOOLEAN
   IS
       l_selected BOOLEAN := FALSE;
   BEGIN
       IF p_task_tbl.COUNT > 0
       THEN
           FOR i IN p_task_tbl.FIRST..p_task_tbl.LAST
           LOOP
               IF p_task_id IS NOT NULL
               THEN
                   IF p_task_tbl(i).task_id = p_task_id
                   THEN
                      l_selected := TRUE;
                      EXIT;
                   END IF;
               ELSIF p_sync_id IS NOT NULL
               THEN
                   IF p_task_tbl(i).syncid = p_sync_id
                   THEN
                      l_selected := TRUE;
                      EXIT;
                   END IF;
               ELSE
                   EXIT;
               END IF;
           END LOOP;
       END IF;

       RETURN l_selected;

   END already_selected;

   PROCEDURE add_task (
      p_request_type           IN   VARCHAR2,
      p_resource_id            IN   NUMBER,
      p_resource_type          IN   VARCHAR2,
      p_recordindex            IN   NUMBER,
      p_operation              IN   VARCHAR2,
      p_task_sync_id           IN   NUMBER,
      p_task_id                IN   NUMBER,
      p_task_name              IN   VARCHAR2,
      p_owner_type_code        IN   VARCHAR2,
      p_description            IN   VARCHAR2,
      p_task_status_id         IN   NUMBER,
      p_task_priority_id       IN   NUMBER,
      p_private_flag           IN   VARCHAR2,
      p_date_selected          IN   VARCHAR2,
      p_timezone_id            IN   NUMBER,
      p_syncanchor             IN   DATE,
      p_planned_start_date     IN   DATE,
      p_planned_end_date       IN   DATE,
      p_scheduled_start_date   IN   DATE,
      p_scheduled_end_date     IN   DATE,
      p_actual_start_date      IN   DATE,
      p_actual_end_date        IN   DATE,
      p_calendar_start_date    IN   DATE,
      p_calendar_end_date      IN   DATE,
      p_alarm_on               IN   VARCHAR2,
      p_alarm_start            IN   NUMBER,
      p_recurrence_rule_id     IN   NUMBER,
      p_occurs_uom             IN   VARCHAR2,
      p_occurs_every           IN   NUMBER,
      p_occurs_number          IN   NUMBER,
      p_start_date_active      IN   DATE,
      p_end_date_active        IN   DATE,
      p_sunday                 IN   VARCHAR2,
      p_monday                 IN   VARCHAR2,
      p_tuesday                IN   VARCHAR2,
      p_wednesday              IN   VARCHAR2,
      p_thursday               IN   VARCHAR2,
      p_friday                 IN   VARCHAR2,
      p_saturday               IN   VARCHAR2,
      p_date_of_month          IN   VARCHAR2,
      p_occurs_which           IN   VARCHAR2,
      --p_get_data               IN   BOOLEAN,
      x_task_rec           IN OUT NOCOPY   jta_sync_task.task_rec
   )
   IS
      l_category_name   VARCHAR2(240); -- Fix bug 2540722
      l_status      BOOLEAN;
      l_operation   VARCHAR2(20);
      l_task_status_id number ;
      l_item_display_type NUMBER;
      l_category_id NUMBER;
   BEGIN
      l_operation := p_operation;
      x_task_rec.syncid := p_task_sync_id;

      x_task_rec.resultid := 0;
      x_task_rec.objectcode := RTRIM (p_request_type, 'S');


      -- item display type equals 3 for all items shown on top of daily view
      --l_item_display_type := jtf_cal_utility_pvt.getItemType
      --                     ( p_SourceCode      => 'TASK'
      --                     , p_PeriodStartDate => null
      --                     , p_PeriodEndDate   => null
      --                     , p_StartDate       => p_calendar_start_date
      --                     , p_EndDate         => p_calendar_end_date
      --                     , p_CalSpanDaysProfile => fnd_profile.value('JTF_CAL_SPAN_DAYS')
      --                     );
      l_item_display_type := 1;

      adjust_timezone (
         p_timezone_id          => p_timezone_id,
         p_syncanchor           => p_syncanchor,
         p_planned_start_date   => p_planned_start_date,
         p_planned_end_date     => p_planned_end_date,
         p_scheduled_start_date => p_scheduled_start_date,
         p_scheduled_end_date   => p_scheduled_end_date,
         p_actual_start_date    => p_actual_start_date,
         p_actual_end_date      => p_actual_end_date,
         p_item_display_type    => l_item_display_type,
         x_task_rec             => x_task_rec
      );

      do_mapping (
         p_task_id,
         p_operation,
         x_task_rec.syncid
      );

      -- change status
      l_task_status_id := p_task_status_id;

      IF (x_task_rec.objectcode <> G_APPOINTMENT)
      THEN
           transformstatus (
               p_task_status_id => l_task_status_id,
               p_task_sync_id   => x_task_rec.syncId,
               x_operation      => l_operation
           ) ;
      END IF;

      x_task_rec.recordindex := p_recordindex;
      x_task_rec.eventtype   := p_operation;
      x_task_rec.subject     := convert_carriage_return(p_task_name,'XML');
      x_task_rec.task_id     := p_task_id;

      IF p_operation <> G_DELETE
      THEN
          make_prefix (
             p_assignment_status_id    => get_assignment_status_id (p_task_id, p_resource_id),
             p_source_object_type_code => x_task_rec.objectcode,
             p_resource_type           => p_owner_type_code,
             p_resource_id             => jta_sync_task.g_login_resource_id,
             p_group_id                => p_resource_id,
             x_subject                 => x_task_rec.subject
          );
      END IF;

      x_task_rec.description  := p_description;
      x_task_rec.statusid     := l_task_status_id;
      x_task_rec.priorityid   := get_client_priority(p_task_priority_id);
      x_task_rec.alarmflag    := p_alarm_on;
      x_task_rec.privateflag  := p_private_flag;
      x_task_rec.dateselected := NVL(p_date_selected,'S'); -- fix bug 2389092

      x_task_rec.resultsystemmessage := NULL;
      x_task_rec.resultusermessage   := NULL;

      -- For fix bug 2540722
      l_category_id := jtf_task_security_pvt.get_category_id(
                           p_task_id => p_task_id,
                           p_resource_id => p_resource_id,
                           p_resource_type_code => p_resource_type
                       );
      IF l_category_id IS NOT NULL
      THEN
          l_category_name := substr(jtf_task_utl.get_category_name(l_category_id), 1, 240);
      END IF;
      x_task_rec.category  := l_category_name;

      x_task_rec.alarmdate := set_alarm_date (
                                 p_task_id => p_task_id,
                                 p_request_type => p_request_type,
                                 p_scheduled_start_date => x_task_rec.scheduledstartdate,
                                 p_planned_start_date => x_task_rec.plannedstartdate,
                                 p_actual_start_date => x_task_rec.actualstartdate,
                                 p_alarm_flag => p_alarm_on,
                                 p_alarm_start => p_alarm_start
                              );

      ----------------------------------------------------------
      -- Repeating data
      ----------------------------------------------------------
      IF p_recurrence_rule_id IS NOT NULL
      THEN
         x_task_rec.unit_of_measure := p_occurs_uom;
         x_task_rec.occurs_every := p_occurs_every;
         --x_task_rec.occurs_number := p_occurs_number;
         x_task_rec.start_date := p_start_date_active;
         x_task_rec.end_date := NVL (p_end_date_active,
                                     get_max_enddate (p_recurrence_rule_id)
                                );
         x_task_rec.sunday    := p_sunday;
         x_task_rec.monday    := p_monday;
         x_task_rec.tuesday   := p_tuesday;
         x_task_rec.wednesday := p_wednesday;
         x_task_rec.thursday  := p_thursday;
         x_task_rec.friday    := p_friday;
         x_task_rec.saturday  := p_saturday;
         x_task_rec.date_of_month := p_date_of_month;
         x_task_rec.occurs_which  := p_occurs_which;

         convert_recur_date_to_gmt (
           p_timezone_id       => p_timezone_id,
           p_base_start_date   => p_planned_start_date,
           p_base_end_date     => p_planned_end_date,
           p_start_date        => x_task_rec.start_date,
           p_end_date          => x_task_rec.end_date,
           p_item_display_type => l_item_display_type,
           p_occurs_which      => p_occurs_which,
           p_uom               => p_occurs_uom,
           x_date_of_month     => x_task_rec.date_of_month,
           x_start_date        => x_task_rec.start_date,
           x_end_date          => x_task_rec.end_date
         );
      END IF;

   END add_task;


   FUNCTION get_client_priority (p_importance_level IN NUMBER)
      RETURN NUMBER
   IS
      l_priority_id   NUMBER;
   BEGIN
      IF p_importance_level <= 2   -- Critical(1), High(1)
      THEN
     l_priority_id := 2;
      ELSIF p_importance_level = 3   -- Medium, Standard
      THEN
     l_priority_id := 3;
      ELSIF p_importance_level >= 4   -- Low, Optional(5)
      THEN
     l_priority_id := 4;
      ELSE
     l_priority_id := NULL;
      END IF;

      RETURN l_priority_id;
   END get_client_priority;

   PROCEDURE make_prefix (
      p_assignment_status_id    IN       NUMBER,
      p_source_object_type_code IN       VARCHAR2,
      p_resource_type           IN       VARCHAR2,
      p_resource_id             IN       NUMBER,
      p_group_id                IN       NUMBER,
      x_subject                 IN OUT NOCOPY   VARCHAR2
   )
   IS
      l_prefix VARCHAR2(100);
   BEGIN

      -- This is appending the prefix 'INVITEE: '
      IF p_source_object_type_code = G_APPOINTMENT AND
         p_resource_type <> 'RS_GROUP' AND
         p_assignment_status_id = 18
      THEN
         x_subject := g_prefix_invitee || x_subject;

      -- This is appending the prefix of the group
      ELSIF p_source_object_type_code = G_APPOINTMENT AND
            p_resource_type = 'RS_GROUP'
      THEN
         l_prefix := jtf_cal_utility_pvt.GetGroupPrefix(p_ResourceID   => p_resource_id
                                                       ,p_ResourceType => p_resource_type
                                                       ,p_GroupID      => p_group_id);
         IF l_prefix IS NOT NULL
         THEN
            x_subject := l_prefix || x_subject;
         END IF;
      END IF;

   END make_prefix;

   -- check if the user is assigne then set status to rejected
   -- and set delete flag to false this rec can not be deleted
   -- else set delete flag to true this rec can be delted
   PROCEDURE check_delete_data (
      p_task_id       IN       NUMBER,
      p_resource_id   IN       NUMBER,
      p_objectcode    IN       VARCHAR2,
      x_status_id     OUT NOCOPY      NUMBER,
      x_delete_flag   OUT NOCOPY      VARCHAR2
   )
   IS
      l_assignee_role          VARCHAR2(30);
      l_assignment_status_id   NUMBER;
   BEGIN
      IF (p_objectcode = G_APPOINTMENT)
      THEN
     get_assignment_info (
        p_task_id => p_task_id,
        p_resource_id => p_resource_id,
        x_assignee_role => l_assignee_role,
        x_assignment_status_id => l_assignment_status_id
     );

     IF (l_assignee_role = 'ASSIGNEE')
     THEN
        x_status_id := 4;   --rejected
        x_delete_flag := 'U';   -- UPDATE
     ELSIF l_assignee_role = 'GROUP'
     THEN
        x_delete_flag := 'X';   -- DO NOTHING
     ELSIF (l_assignee_role = 'OWNER')
     THEN
        x_delete_flag := 'D';   -- DELETE
     END IF;
      ELSE   -- p_objectcode = G_TASK
     x_delete_flag := 'D';
      END IF;   -- p_objectcode = G_APPOINTMENT
   END check_delete_data;

   FUNCTION get_assignment_id (p_task_id IN NUMBER
                             , p_resource_id IN NUMBER
                             , p_resource_type IN VARCHAR2
   )
   RETURN NUMBER
   IS
      CURSOR c_assignment
      IS
     SELECT task_assignment_id
       FROM jtf_task_all_assignments
      WHERE task_id = p_task_id
        AND resource_id = p_resource_id
        AND resource_type_code = p_resource_type;

      l_task_assignment_id   NUMBER;
   BEGIN
      OPEN c_assignment;
      FETCH c_assignment into l_task_assignment_id;

      IF c_assignment%NOTFOUND
      THEN
         CLOSE c_assignment;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_ASSIGNMENT_NOTFOUND');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_ASSIGNMENT_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      CLOSE c_assignment;
      RETURN l_task_assignment_id;
   END get_assignment_id;

   FUNCTION get_assignment_status_id (
      p_task_id       IN   NUMBER,
      p_resource_id   IN   NUMBER
      )
      RETURN NUMBER
   IS
      CURSOR c_assignment
      IS
     SELECT assignment_status_id
       FROM jtf_task_all_assignments
      WHERE task_id = p_task_id
        AND resource_id = p_resource_id;

      l_assignment_status_id   NUMBER;
   BEGIN
      OPEN c_assignment;
      FETCH c_assignment into l_assignment_status_id;

      IF c_assignment%NOTFOUND
      THEN
         CLOSE c_assignment;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_ASSIGN_STSID_NOTFOUND');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_ASSIGNMENT_STATUS_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      CLOSE c_assignment;
      RETURN l_assignment_status_id;
   END get_assignment_status_id;

   PROCEDURE get_owner_info (
      p_task_id       IN       NUMBER,
      x_task_name     OUT NOCOPY      VARCHAR2,
      x_owner_id      OUT NOCOPY      NUMBER,
      x_owner_type_code   OUT NOCOPY      VARCHAR2
   )
   IS
      CURSOR c_task (b_task_id NUMBER)
      IS
     SELECT task_name, owner_id, owner_type_code
       FROM jtf_tasks_vl
      WHERE task_id = b_task_id;

      rec_task   c_task%ROWTYPE;
   BEGIN
      OPEN c_task (p_task_id);
      FETCH c_task INTO rec_task;

      IF c_task%NOTFOUND
      THEN
         CLOSE c_task;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_NOTFOUND_TASKID');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_OWNER_INFO');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      CLOSE c_task;
      x_task_name := rec_task.task_name;
      x_owner_id := rec_task.owner_id;
      x_owner_type_code := rec_task.owner_type_code;
   END get_owner_info;

   PROCEDURE get_assignment_info (
      p_task_id            IN   NUMBER,
      p_resource_id        IN   NUMBER,
      x_assignee_role          OUT NOCOPY  VARCHAR2,
      x_assignment_status_id   OUT NOCOPY  NUMBER
   )
   IS
      CURSOR c_assignment (b_task_id NUMBER, b_resource_id NUMBER)
      IS
     SELECT a.assignee_role, a.assignment_status_id, r.resource_id
       FROM jtf_rs_resource_extns r, jtf_task_all_assignments a
      WHERE a.task_id = b_task_id
        AND a.resource_id = b_resource_id
        AND r.user_id = a.created_by;

      l_assignee_role          VARCHAR2(30);
      l_assignment_status_id   NUMBER;
      l_task_name          VARCHAR2(80);
      l_owner_id           NUMBER;
      l_owner_type_code        VARCHAR2(30);
      l_creator_resource_id    NUMBER;
   BEGIN
      get_owner_info (
     p_task_id => p_task_id,
     x_task_name => l_task_name,
     x_owner_id => l_owner_id,
     x_owner_type_code => l_owner_type_code
      );

      IF l_owner_type_code = 'RS_GROUP'
      THEN
     OPEN c_assignment (
         b_task_id => p_task_id,
         b_resource_id => l_owner_id
          );
      ELSE
     OPEN c_assignment (
         b_task_id => p_task_id,
         b_resource_id => p_resource_id
          );
      END IF;

      FETCH c_assignment into l_assignee_role, l_assignment_status_id, l_creator_resource_id;

      IF c_assignment%NOTFOUND
      THEN
         CLOSE c_assignment;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_ASSIGNMENT_NOTFOUND');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_ASSIGNMENT_INFO');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      CLOSE c_assignment;

      IF l_owner_type_code = 'RS_GROUP'
      -- AND l_creator_resource_id <> p_resource_id

      THEN
     x_assignee_role := 'GROUP';
     x_assignment_status_id := NULL;
      ELSE
     x_assignee_role := l_assignee_role;
     x_assignment_status_id := l_assignment_status_id;
      END IF;
   END get_assignment_info;

   FUNCTION get_access (p_group_id IN VARCHAR2, p_resource_id IN NUMBER)
      RETURN VARCHAR2
   IS
      --     1) JTF_CAL_FULL_ACCESS
      --     2) JTF_CAL_ADMIN_ACCESS
      --     3) JTF_CAL_READ_ACCESS
      CURSOR c_access (b_group_id VARCHAR2, b_resource_id VARCHAR2)
      IS
         SELECT DISTINCT fmu.menu_name
           FROM fnd_menus fmu, fnd_objects fos, fnd_grants fgs
          WHERE fmu.menu_id = fgs.menu_id   -- grants joint to menus
            AND fos.obj_name = 'JTF_TASK_RESOURCE'
            AND fos.object_id = fgs.object_id   -- grants joint to object
            AND fgs.grantee_key = b_resource_id
            AND fgs.grantee_type = 'USER'
            AND fgs.start_date < SYSDATE
            AND (  fgs.end_date >= SYSDATE
            OR fgs.end_date IS NULL)
            AND fgs.instance_pk2_value = 'RS_GROUP'
            AND fgs.instance_pk1_value = b_group_id;

      l_menu_name   fnd_menus.menu_name%TYPE;
   BEGIN
      OPEN c_access (b_group_id => p_group_id, b_resource_id => p_resource_id);
      FETCH c_access into l_menu_name;

      IF c_access%NOTFOUND
      THEN
         CLOSE c_access;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_ACCESS_PRIV_NOTFOUND');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_ACCESS');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      CLOSE c_access;
      RETURN l_menu_name;
   END get_access;

   FUNCTION get_source_object_type (p_task_id IN NUMBER)
      RETURN VARCHAR2
   IS
      CURSOR c_source (b_task_id NUMBER)
      IS
     SELECT source_object_type_code
       FROM jtf_tasks_b
      WHERE task_id = b_task_id;

      l_source_object_type_code   VARCHAR2(60);
   BEGIN
      OPEN c_source (b_task_id => p_task_id);
      FETCH c_source into l_source_object_type_code;

      IF c_source%NOTFOUND
      THEN
         CLOSE c_source;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_NOTFOUND_TASKID');
         fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_SOURCE_OBJECT_TYPE');
         fnd_msg_pub.add;

         raise_application_error (-20100,jta_sync_common.get_messages);
      END IF;

      CLOSE c_source;
      RETURN l_source_object_type_code;
   END get_source_object_type;

   -- Added for fix bug 2482833
   PROCEDURE get_sync_info (p_task_id         IN NUMBER,
                            p_resource_id     IN NUMBER,
                            x_assignee_role  OUT NOCOPY VARCHAR2,
                            x_resource_type  OUT NOCOPY VARCHAR2,
                            x_group_calendar_flag OUT NOCOPY VARCHAR2,
                            x_assignment_status_id OUT NOCOPY NUMBER,
                            x_source_object_type_code OUT NOCOPY VARCHAR2)
   IS
       CURSOR c_resource IS
       SELECT asg.assignee_role
            , rs.resource_type_code
            , rs.group_calendar_flag
            , asg.assignment_status_id
            , tsk.source_object_type_code
         FROM (SELECT p_resource_id resource_id
                    , 'RS_EMPLOYEE' resource_type_code
                    , 'N' group_calendar_flag
                 FROM dual
               UNION ALL
               SELECT tm.team_id resource_id
                    , 'RS_TEAM'  resource_type_code
                    , 'N' group_calendar_flag
                 FROM jtf_rs_team_members tm
                WHERE tm.team_resource_id = p_resource_id
               UNION ALL
               SELECT gm.group_id resource_id
                    , 'RS_GROUP' resource_type_code
                    , 'N' group_calendar_flag
                 FROM jtf_rs_group_members gm
                WHERE gm.resource_id = p_resource_id
               UNION ALL
               SELECT g.group_id resource_id
                    , 'RS_GROUP' resource_type_code
                    , 'Y' group_calendar_flag
                 FROM fnd_grants fg
                    , jtf_rs_groups_b g
                WHERE fg.grantee_key = to_char(p_resource_id)
                  AND fg.grantee_type = 'USER'
                  AND fg.instance_pk2_value = 'RS_GROUP'
                  AND fg.instance_pk1_value = to_char(g.group_id)
              ) rs
            , jtf_task_all_assignments asg
            , jtf_tasks_b tsk
        WHERE asg.resource_type_code = rs.resource_type_code
          AND asg.resource_id        = rs.resource_id
          AND asg.task_id            = tsk.task_id
          AND tsk.task_id            = p_task_id
       ORDER BY rs.group_calendar_flag desc
               ,decode(rs.resource_type_code,
                       'RS_EMPLOYEE', 1,
                       'RS_GROUP',    2,
                       'RS_TEAM',     3);

   BEGIN
       OPEN c_resource;
       FETCH c_resource
        INTO x_assignee_role
           , x_resource_type
           , x_group_calendar_flag
           , x_assignment_status_id
           , x_source_object_type_code;
       IF c_resource%NOTFOUND
       THEN
           CLOSE c_resource;

           fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
           fnd_msg_pub.add;

           fnd_message.set_name('JTF', 'JTA_SYNC_ASSIGNMENT_NOTFOUND');
           fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_SYNC_TYPE');
           fnd_msg_pub.add;

           raise_application_error (-20100,jta_sync_common.get_messages);
       END IF;
       CLOSE c_resource;

   END get_sync_info;

   FUNCTION get_update_type (p_task_id IN NUMBER,
                             p_resource_id IN NUMBER,
                             p_subject IN VARCHAR2)
   RETURN VARCHAR2
   IS
      l_synced_resource_type    VARCHAR2(30);
      l_group_calendar_flag     VARCHAR2(1);
      l_task_name               VARCHAR2(80);
      l_assignee_role           VARCHAR2(30);
      l_assignment_status_id    NUMBER;
      l_source_object_type_code VARCHAR2(60); -- Added for fix bug 2442686
      l_update_type             VARCHAR2(15) := G_UPDATE_ALL; -- Added for fix bug 2442686
   BEGIN
      -- Added for fix bug 2482833
      get_sync_info (p_task_id         => p_task_id,
                     p_resource_id     => p_resource_id,
                     x_assignee_role   => l_assignee_role,
                     x_resource_type   => l_synced_resource_type,
                     x_group_calendar_flag => l_group_calendar_flag,
                     x_assignment_status_id => l_assignment_status_id,
                     x_source_object_type_code => l_source_object_type_code
      );

      IF rtrim(l_synced_resource_type) = 'RS_GROUP' AND
         l_group_calendar_flag = 'Y'
      THEN
          l_update_type := g_do_nothing; -- Added for fix bug 2442686
      ELSE
         IF l_assignee_role = 'ASSIGNEE'
         THEN
            -- Fix bug 2442686:
            -- If this is TASK, assignee can update any fields,
            -- but if it's APPOINTMENT, then the invitee can update only the status
            -- when he/she accept the appointment.
            --l_source_object_type_code := get_source_object_type(p_task_id); -- Added for fix bug 2442686
            IF l_source_object_type_code = G_APPOINTMENT -- Added for fix bug 2442686
            THEN
                IF l_assignment_status_id = 18 AND -- Status = Invited
                   SUBSTR(p_subject, 1, LENGTH(g_prefix_invitee)) <> g_prefix_invitee
                THEN
                   l_update_type := g_update_status;
                ELSE   -- Status <> Invited
                   l_update_type := g_do_nothing;
                END IF;
            END IF;
         END IF;
      END IF;

      RETURN l_update_type; -- Added for fix bug 2442686

   END get_update_type;

   FUNCTION get_recurrence_rule_id (p_task_id IN NUMBER)
      RETURN NUMBER
   IS
      CURSOR c_recur
      IS
     SELECT t.recurrence_rule_id
       FROM jtf_tasks_b t
      WHERE t.task_id = p_task_id;

      l_recurrence_rule_id   NUMBER;
   BEGIN
      OPEN c_recur;
      FETCH c_recur into l_recurrence_rule_id;

      IF c_recur%NOTFOUND
      THEN
     l_recurrence_rule_id := NULL;
      END IF;

      CLOSE c_recur;
      RETURN l_recurrence_rule_id;
   END get_recurrence_rule_id;

   PROCEDURE convert_recur_date_to_client (
      p_base_start_time   IN       DATE,
      p_base_end_time     IN       DATE,
      p_start_date    IN       DATE,
      p_end_date      IN       DATE,
      p_occurs_which      IN       NUMBER,
      p_uom       IN       VARCHAR2,
      x_date_of_month     OUT NOCOPY      NUMBER,
      x_start_date    IN OUT NOCOPY      DATE,
      x_end_date      IN OUT NOCOPY      DATE
   )
   IS
      l_start_date   VARCHAR2(10);   -- DD-MM-YYYY
      l_start_time   VARCHAR2(8);   -- HH24:MI:SS
      l_end_date     VARCHAR2(10);   -- DD-MM-YYYY
      l_end_time     VARCHAR2(8);   -- HH24:MI:SS
   BEGIN
      l_start_date := TO_CHAR (p_start_date, 'DD-MM-YYYY');
      l_start_time := TO_CHAR (p_base_start_time, 'HH24:MI:SS');
      l_end_date := TO_CHAR (p_end_date, 'DD-MM-YYYY');
      l_end_time := TO_CHAR (p_base_end_time, 'HH24:MI:SS');

      if  l_start_time <>  l_end_time then
      x_start_date :=
     TRUNC (
        convert_gmt_to_client (
           TO_DATE (
          l_start_date || ' ' || l_start_time,
          'DD-MM-YYYY HH24:MI:SS'
           )
        )
     );
      IF  l_end_date IS NOT NULL THEN
        x_end_date :=
        TRUNC (
        convert_gmt_to_client (
           TO_DATE (
          l_end_date || ' ' || l_end_time,
          'DD-MM-YYYY HH24:MI:SS'
           )
         )
        );
     END IF;
       else
       x_start_date  :=  TO_DATE(l_start_date,'DD-MM-YYYY');
       x_end_date  :=  TO_DATE(l_end_date,'DD-MM-YYYY');
       end if ;

      IF     p_occurs_which IS NULL
     AND (p_uom = 'MON' OR p_uom ='YER')
      THEN
     x_date_of_month := TO_CHAR (x_start_date, 'DD');
      END IF;
   END convert_recur_date_to_client;

   PROCEDURE get_all_nonrepeat_tasks (
      p_request_type         IN       VARCHAR2,
      p_syncanchor           IN       DATE,
      p_recordindex          IN       NUMBER,
      p_resource_id          IN       NUMBER,
      p_resource_type        IN       VARCHAR2,
      p_source_object_type   IN       VARCHAR2,
      p_get_data             IN       BOOLEAN,
      x_totalnew             IN OUT NOCOPY   NUMBER,
      x_totalmodified        IN OUT NOCOPY   NUMBER,
      -- x_totaldeleted       IN OUT NOCOPY NUMBER,
      x_data                 IN OUT NOCOPY   jta_sync_task.task_tbl
      --p_new_syncanchor       IN       DATE
   )
   IS
      x_task_rec   jta_sync_task.task_rec;
      i            INTEGER := p_recordindex;
      l_invalid    BOOLEAN;
   BEGIN
      FOR rec_modify_nonrepeat IN jta_sync_task_cursors.c_modify_non_repeat_task (
                   p_syncanchor,
                   p_resource_id,
                   p_resource_type,
                   p_source_object_type
                )
      LOOP
         --check span days and skip add_task
         check_span_days (
            p_source_object_type_code => rec_modify_nonrepeat.source_object_type_code,
            p_calendar_start_date     => rec_modify_nonrepeat.calendar_start_date,
            p_calendar_end_date       => rec_modify_nonrepeat.calendar_end_date,
            x_status                  => l_invalid
         );

         IF NOT (l_invalid OR already_selected(p_task_id => rec_modify_nonrepeat.task_id, p_task_tbl => x_data))
         THEN
             IF p_get_data
             THEN
                 add_task (
                    p_request_type         => p_request_type,
                    p_resource_id          => p_resource_id,
                    p_resource_type        => p_resource_type,
                    p_recordindex          => i+1,
                    p_operation            => g_modify,
                    p_task_sync_id         => rec_modify_nonrepeat.task_sync_id,
                    p_task_id              => rec_modify_nonrepeat.task_id,
                    p_task_name            => rec_modify_nonrepeat.task_name,
                    p_owner_type_code      => rec_modify_nonrepeat.owner_type_code,
                    p_description          => rec_modify_nonrepeat.description,
                    p_task_status_id       => rec_modify_nonrepeat.task_status_id,
                    p_task_priority_id     => rec_modify_nonrepeat.importance_level ,
                    p_private_flag         => rec_modify_nonrepeat.private_flag,
                    p_date_selected        => rec_modify_nonrepeat.date_selected,
                    p_timezone_id          => rec_modify_nonrepeat.timezone_id,
                    p_syncanchor           => rec_modify_nonrepeat.new_timestamp,
                    p_planned_start_date   => rec_modify_nonrepeat.planned_start_date,
                    p_planned_end_date     => rec_modify_nonrepeat.planned_end_date,
                    p_scheduled_start_date => rec_modify_nonrepeat.scheduled_start_date,
                    p_scheduled_end_date   => rec_modify_nonrepeat.scheduled_end_date,
                    p_actual_start_date    => rec_modify_nonrepeat.actual_start_date,
                    p_actual_end_date      => rec_modify_nonrepeat.actual_end_date,
                    p_calendar_start_date  => rec_modify_nonrepeat.calendar_start_date,
                    p_calendar_end_date    => rec_modify_nonrepeat.calendar_end_date,
                    p_alarm_on             => rec_modify_nonrepeat.alarm_on,
                    p_alarm_start          => rec_modify_nonrepeat.alarm_start,
                    p_recurrence_rule_id   => rec_modify_nonrepeat.recurrence_rule_id,
                    p_occurs_uom           => NULL,
                    p_occurs_every         => NULL,
                    p_occurs_number        => NULL,
                    p_start_date_active    => NULL,
                    p_end_date_active      => NULL,
                    p_sunday               => NULL,
                    p_monday               => NULL,
                    p_tuesday              => NULL,
                    p_wednesday            => NULL,
                    p_thursday             => NULL,
                    p_friday               => NULL,
                    p_saturday             => NULL,
                    p_date_of_month        => NULL,
                    p_occurs_which         => NULL,
                    x_task_rec             => x_task_rec
                 );
                 i := i + 1;
                 x_data (i) := x_task_rec;

             ELSE -- For get_count, store the task_id selected so as to avoid the duplicate
                 i := i + 1;
                 x_data (i).task_id := rec_modify_nonrepeat.task_id;
             END IF; -- p_get_data
             x_totalmodified := x_totalmodified + 1;
         END IF; -- l_invalid

      END LOOP;

      FOR rec_new_nonrepeat IN jta_sync_task_cursors.c_new_non_repeat_task (
                                    p_syncanchor,
                                    p_resource_id,
                                    p_resource_type,
                                    p_source_object_type
                               )
      LOOP
         --check span days and skip add_task
         check_span_days (
            p_source_object_type_code => rec_new_nonrepeat.source_object_type_code,
            p_calendar_start_date     => rec_new_nonrepeat.calendar_start_date,
            p_calendar_end_date       => rec_new_nonrepeat.calendar_end_date,
            x_status                  => l_invalid
         );

         IF NOT (l_invalid OR already_selected(p_task_id => rec_new_nonrepeat.task_id, p_task_tbl => x_data))
         THEN
             IF p_get_data
             THEN
                 add_task (
                    p_request_type   => p_request_type,
                    p_resource_id    => p_resource_id,
                    p_resource_type  => p_resource_type,
                    p_recordindex    => i + 1,
                    p_operation      => g_new,
                    p_task_sync_id   => NULL,
                    p_task_id        => rec_new_nonrepeat.task_id,
                    p_task_name      => rec_new_nonrepeat.task_name,
                    p_owner_type_code => rec_new_nonrepeat.owner_type_code,
                    p_description => rec_new_nonrepeat.description,
                    p_task_status_id => rec_new_nonrepeat.task_status_id,
                    p_task_priority_id => rec_new_nonrepeat.importance_level ,
                    p_private_flag => rec_new_nonrepeat.private_flag,
                    p_date_selected => rec_new_nonrepeat.date_selected,
                    p_timezone_id => rec_new_nonrepeat.timezone_id,
                    p_syncanchor => rec_new_nonrepeat.new_timestamp,
                    p_planned_start_date => rec_new_nonrepeat.planned_start_date,
                    p_planned_end_date => rec_new_nonrepeat.planned_end_date,
                    p_scheduled_start_date => rec_new_nonrepeat.scheduled_start_date,
                    p_scheduled_end_date => rec_new_nonrepeat.scheduled_end_date,
                    p_actual_start_date => rec_new_nonrepeat.actual_start_date,
                    p_actual_end_date => rec_new_nonrepeat.actual_end_date,
                    p_calendar_start_date => rec_new_nonrepeat.calendar_start_date,
                    p_calendar_end_date => rec_new_nonrepeat.calendar_end_date,
                    p_alarm_on => rec_new_nonrepeat.alarm_on,
                    p_alarm_start => rec_new_nonrepeat.alarm_start,
                    p_recurrence_rule_id => rec_new_nonrepeat.recurrence_rule_id,
                    p_occurs_uom => NULL,
                    p_occurs_every => NULL,
                    p_occurs_number => NULL,
                    p_start_date_active => NULL,
                    p_end_date_active => NULL,
                    p_sunday => NULL,
                    p_monday => NULL,
                    p_tuesday => NULL,
                    p_wednesday => NULL,
                    p_thursday => NULL,
                    p_friday => NULL,
                    p_saturday => NULL,
                    p_date_of_month => NULL,
                    p_occurs_which => NULL,
                    --p_get_data => p_get_data,
                    x_task_rec => x_task_rec
                 );

                 i := i + 1;
                 x_data (i) := x_task_rec;
             ELSE -- For get_count, store the task_id selected so as to avoid the duplicate
                 i := i + 1;
                 x_data (i).task_id := rec_new_nonrepeat.task_id;
             END IF; --p_get_data

             x_totalnew := x_totalnew + 1;
         END IF; -- l_invalid
      END LOOP;

   END get_all_nonrepeat_tasks;

   PROCEDURE get_all_deleted_tasks (
      p_request_type         IN       VARCHAR2,
      p_syncanchor           IN       DATE,
      p_recordindex          IN       NUMBER,
      p_resource_id          IN       NUMBER,
      p_resource_type        IN       VARCHAR2,
      p_source_object_type   IN       VARCHAR2,
      p_get_data             IN       BOOLEAN,
      x_totaldeleted         IN OUT NOCOPY   NUMBER,
      x_data                 IN OUT NOCOPY   jta_sync_task.task_tbl
   )
   IS
      i   INTEGER := nvl(x_data.last,0);
   BEGIN
      FOR rec_delete IN jta_sync_task_cursors.c_delete_task (
                            p_syncanchor,
                            p_resource_id,
                            p_resource_type,
                            p_source_object_type
                      )
      LOOP
         IF NOT already_selected(p_sync_id => rec_delete.task_sync_id, p_task_tbl => x_data)
         THEN
             IF p_get_data
             THEN
                 i := i + 1;
                 x_data(i).syncid     := rec_delete.task_sync_id;
                 x_data(i).recordindex:= i;
                 x_data(i).eventtype  := g_delete;
                 x_data(i).resultid   := 0;

                 jta_sync_task_map_pkg.delete_row (
                    p_task_sync_id => rec_delete.task_sync_id
                 );

                 x_data(i).syncanchor := convert_server_to_gmt (SYSDATE);
             ELSE -- For get_count, store the sync_id selected so as to avoid the duplicate
                 i := i + 1;
                 x_data (i).syncid := rec_delete.task_sync_id;
             END IF;

             x_totaldeleted := x_totaldeleted + 1;
          END IF;
      END LOOP;

      FOR rec_delete IN jta_sync_task_cursors.c_delete_assignee_reject (
                            p_syncanchor,
                            p_resource_id,
                            p_resource_type,
                            p_source_object_type
                      )
      LOOP
          IF NOT already_selected(p_sync_id => rec_delete.task_sync_id, p_task_tbl => x_data)
          THEN
             IF p_get_data
             THEN
                 i := i + 1;
                 x_data(i).syncid     := rec_delete.task_sync_id;
                 x_data(i).recordindex:= i;
                 x_data(i).eventtype  := g_delete;
                 x_data(i).resultid   := 0;

                 jta_sync_task_map_pkg.delete_row (
                    p_task_sync_id => rec_delete.task_sync_id
                 );

                 x_data(i).syncanchor := convert_server_to_gmt (SYSDATE);
             ELSE -- For get_count, store the sync_id selected so as to avoid the duplicate
                 i := i + 1;
                 x_data (i).syncid := rec_delete.task_sync_id;
             END IF;

             x_totaldeleted := x_totaldeleted + 1;
          END IF;
      END LOOP;

      FOR rec_delete IN jta_sync_task_cursors.c_delete_assignment (
                         p_syncanchor,
                         p_resource_id,
                         p_resource_type,
                         p_source_object_type
                      )
      LOOP
          IF NOT already_selected(p_sync_id => rec_delete.task_sync_id, p_task_tbl => x_data)
          THEN
             IF p_get_data
             THEN
                 i := i + 1;
                 x_data(i).eventtype  := g_delete;
                 x_data(i).syncid     := rec_delete.task_sync_id;
                 x_data(i).recordindex:= i;
                 x_data(i).resultid   := 0;

                 jta_sync_task_map_pkg.delete_row (
                    p_task_sync_id => rec_delete.task_sync_id
                 );

                 x_data(i).syncanchor := convert_server_to_gmt (SYSDATE);
             ELSE -- For get_count, store the sync_id selected so as to avoid the duplicate
                 i := i + 1;
                 x_data (i).syncid := rec_delete.task_sync_id;
             END IF;

             x_totaldeleted := x_totaldeleted + 1;
          END IF;
      END LOOP;

      FOR rec_delete IN jta_sync_task_cursors.c_delete_rejected_tasks (
                         p_syncanchor,
                         p_resource_id,
                         p_resource_type,
                         p_source_object_type
                       )
      LOOP
          IF NOT already_selected(p_sync_id => rec_delete.task_sync_id, p_task_tbl => x_data)
          THEN
             IF p_get_data
             THEN
                 i := i + 1;
                 x_data (i).syncid     := rec_delete.task_sync_id;
                 x_data(i).recordindex := i;
                 x_data (i).eventtype  := g_delete;
                 x_data (i).resultid   := 0;

                 jta_sync_task_map_pkg.delete_row (
                     p_task_sync_id => rec_delete.task_sync_id
                 );

                 x_data (i).syncanchor := convert_server_to_gmt (SYSDATE);
             ELSE -- For get_count, store the sync_id selected so as to avoid the duplicate
                 i := i + 1;
                 x_data (i).syncid := rec_delete.task_sync_id;
             END IF;

             x_totaldeleted := x_totaldeleted + 1;
          END IF;
      END LOOP;

      FOR rec_delete IN jta_sync_task_cursors.c_delete_unsubscribed(
                         p_resource_id,
                         p_resource_type,
                         p_source_object_type
                       )
      LOOP
          IF NOT already_selected(p_sync_id => rec_delete.task_sync_id, p_task_tbl => x_data)
          THEN
             IF p_get_data
             THEN
                 i := i + 1;
                 x_data (i).syncid     := rec_delete.task_sync_id;
                 x_data(i).recordindex := i;
                 x_data (i).eventtype  := g_delete;
                 x_data (i).resultid   := 0;

                 jta_sync_task_map_pkg.delete_row (
                     p_task_sync_id => rec_delete.task_sync_id
                 );

                 x_data (i).syncanchor := convert_server_to_gmt (SYSDATE);

             ELSE -- For get_count, store the sync_id selected so as to avoid the duplicate
                 i := i + 1;
                 x_data (i).syncid := rec_delete.task_sync_id;
             END IF;

             x_totaldeleted := x_totaldeleted + 1;
          END IF;
      END LOOP;
   END get_all_deleted_tasks;

------------------------------------------------
   PROCEDURE get_all_repeat_tasks (
      p_request_type         IN       VARCHAR2,
      p_syncanchor           IN       DATE,
      p_recordindex          IN       NUMBER,
      p_resource_id          IN       NUMBER,
      p_resource_type        IN       VARCHAR2,
      p_source_object_type   IN       VARCHAR2,
      p_get_data             IN       BOOLEAN,
      x_totalnew             IN OUT NOCOPY   NUMBER,
      x_totalmodified        IN OUT NOCOPY   NUMBER,
      -- x_totaldeleted       IN OUT NOCOPY NUMBER,
      x_data                 IN OUT NOCOPY   jta_sync_task.task_tbl,
      x_exclusion_data       IN OUT NOCOPY   jta_sync_task.exclusion_tbl
      --p_new_syncanchor       IN       DATE
   )
   IS
      i            INTEGER       :=  nvl(x_data.last,0);
      x_task_rec   jta_sync_task.task_rec;
      l_invalid    BOOLEAN;
   BEGIN

      FOR rec_modify_repeat IN jta_sync_task_cursors.c_modify_repeating_task (
                                p_syncanchor,
                                p_resource_id,
                                p_resource_type,
                                p_source_object_type
                             )
      LOOP
         --check span days and skip add_task
         check_span_days (
            p_source_object_type_code => rec_modify_repeat.source_object_type_code,
            p_calendar_start_date     => rec_modify_repeat.calendar_start_date,
            p_calendar_end_date       => rec_modify_repeat.calendar_end_date,
            x_status                  => l_invalid
         );

         IF NOT (l_invalid OR already_selected(p_task_id => rec_modify_repeat.task_id, p_task_tbl => x_data))
         THEN

             IF p_get_data
             THEN
                 add_task (
                    p_request_type => p_request_type,
                    p_resource_id => p_resource_id,
                    p_resource_type => p_resource_type,
                    p_recordindex => i + 1,
                    p_operation => g_modify,
                    p_task_sync_id => rec_modify_repeat.task_sync_id,
                    p_task_id => rec_modify_repeat.task_id,
                    p_task_name => rec_modify_repeat.task_name,
                    p_owner_type_code => rec_modify_repeat.owner_type_code,
                    p_description => rec_modify_repeat.description,
                    p_task_status_id => rec_modify_repeat.task_status_id,
                    p_task_priority_id => null  ,
                    p_private_flag => rec_modify_repeat.private_flag,
                    p_date_selected => rec_modify_repeat.date_selected,
                    p_timezone_id => rec_modify_repeat.timezone_id,
                    p_syncanchor => rec_modify_repeat.new_timestamp,
                    p_planned_start_date => rec_modify_repeat.planned_start_date,
                    p_planned_end_date => rec_modify_repeat.planned_end_date,
                    p_scheduled_start_date => rec_modify_repeat.scheduled_start_date,
                    p_scheduled_end_date => rec_modify_repeat.scheduled_end_date,
                    p_actual_start_date => rec_modify_repeat.actual_start_date,
                    p_actual_end_date => rec_modify_repeat.actual_end_date,
                    p_calendar_start_date => rec_modify_repeat.calendar_start_date,
                    p_calendar_end_date => rec_modify_repeat.calendar_end_date,
                    p_alarm_on => rec_modify_repeat.alarm_on,
                    p_alarm_start => rec_modify_repeat.alarm_start,
                    p_recurrence_rule_id => rec_modify_repeat.recurrence_rule_id,
                    p_occurs_uom => rec_modify_repeat.occurs_uom,
                    p_occurs_every => rec_modify_repeat.occurs_every,
                    p_occurs_number => rec_modify_repeat.occurs_number,
                    p_start_date_active => rec_modify_repeat.start_date_active,
                    p_end_date_active => rec_modify_repeat.end_date_active,
                    p_sunday => rec_modify_repeat.sunday,
                    p_monday => rec_modify_repeat.monday,
                    p_tuesday => rec_modify_repeat.tuesday,
                    p_wednesday => rec_modify_repeat.wednesday,
                    p_thursday => rec_modify_repeat.thursday,
                    p_friday => rec_modify_repeat.friday,
                    p_saturday => rec_modify_repeat.saturday,
                    p_date_of_month => rec_modify_repeat.date_of_month,
                    p_occurs_which => rec_modify_repeat.occurs_which,
                    x_task_rec => x_task_rec
                    --p_get_data => p_get_data
                 );
                 i := i + 1;
                 x_data (i) := x_task_rec;

                 get_exclusion_data (
                    p_recurrence_rule_id => rec_modify_repeat.recurrence_rule_id,
                    p_exclusion_data => x_exclusion_data,
                    p_task_sync_id => x_task_rec.syncid
                 );
             ELSE -- For get_count, store the sync_id selected so as to avoid the duplicate
                 i := i + 1;
                 x_data (i).task_id := rec_modify_repeat.task_id;
             END IF; -- p_get_data

             x_totalmodified := x_totalmodified + 1;
         END IF; -- l_invalid

      END LOOP;

      FOR rec_new_repeat IN jta_sync_task_cursors.c_new_repeating_task (
                                  p_syncanchor,
                                  p_resource_id,
                                  p_resource_type,
                                  p_source_object_type
                          )
      LOOP
         --check span days and skip add_task
         check_span_days (
            p_source_object_type_code => rec_new_repeat.source_object_type_code,
            p_calendar_start_date     => rec_new_repeat.calendar_start_date,
            p_calendar_end_date       => rec_new_repeat.calendar_end_date,
            x_status                  => l_invalid
         );

         IF NOT (l_invalid OR already_selected(p_task_id => rec_new_repeat.task_id, p_task_tbl => x_data))
         THEN
             IF p_get_data
             THEN
                 add_task (
                    p_request_type => p_request_type,
                    p_resource_id => p_resource_id,
                    p_resource_type => p_resource_type,
                    p_recordindex => i + 1,
                    p_operation => g_new,
                    p_task_sync_id => null  ,
                    p_task_id => rec_new_repeat.task_id,
                    p_task_name => rec_new_repeat.task_name,
                    p_owner_type_code => rec_new_repeat.owner_type_code,
                    p_description => rec_new_repeat.description,
                    p_task_status_id => rec_new_repeat.task_status_id,
                    p_task_priority_id => rec_new_repeat.importance_level,
                    p_private_flag => rec_new_repeat.private_flag,
                    p_date_selected => rec_new_repeat.date_selected,
                    p_timezone_id => rec_new_repeat.timezone_id,
                    p_syncanchor => rec_new_repeat.new_timestamp,
                    p_planned_start_date => rec_new_repeat.planned_start_date,
                    p_planned_end_date => rec_new_repeat.planned_end_date,
                    p_scheduled_start_date => rec_new_repeat.scheduled_start_date,
                    p_scheduled_end_date => rec_new_repeat.scheduled_end_date,
                    p_actual_start_date => rec_new_repeat.actual_start_date,
                    p_actual_end_date => rec_new_repeat.actual_end_date,
                    p_calendar_start_date => rec_new_repeat.calendar_start_date,
                    p_calendar_end_date => rec_new_repeat.calendar_end_date,
                    p_alarm_on => rec_new_repeat.alarm_on,
                    p_alarm_start => rec_new_repeat.alarm_start,
                    p_recurrence_rule_id => rec_new_repeat.recurrence_rule_id,
                    p_occurs_uom => rec_new_repeat.occurs_uom,
                    p_occurs_every => rec_new_repeat.occurs_every,
                    p_occurs_number => rec_new_repeat.occurs_number,
                    p_start_date_active => rec_new_repeat.start_date_active,
                    p_end_date_active => rec_new_repeat.end_date_active,
                    p_sunday => rec_new_repeat.sunday,
                    p_monday => rec_new_repeat.monday,
                    p_tuesday => rec_new_repeat.tuesday,
                    p_wednesday => rec_new_repeat.wednesday,
                    p_thursday => rec_new_repeat.thursday,
                    p_friday => rec_new_repeat.friday,
                    p_saturday => rec_new_repeat.saturday,
                    p_date_of_month => rec_new_repeat.date_of_month,
                    p_occurs_which => rec_new_repeat.occurs_which,
                    --p_get_data => p_get_data,
                    x_task_rec => x_task_rec
                 );

                 i := i + 1;
                 x_data (i) := x_task_rec;

                 get_exclusion_data (
                    p_recurrence_rule_id => rec_new_repeat.recurrence_rule_id,
                    p_exclusion_data => x_exclusion_data,
                    p_task_sync_id => x_task_rec.syncid
                 );
             ELSE -- For get_count, store the sync_id selected so as to avoid the duplicate
                 i := i + 1;
                 x_data (i).task_id := rec_new_repeat.task_id;
             END IF; -- p_get_data

             x_totalnew := x_totalnew + 1;

         END IF; -- l_invalid
      END LOOP;

   END get_all_repeat_tasks;

   PROCEDURE create_new_data (
      p_task_rec        IN OUT NOCOPY   jta_sync_task.task_rec,
      p_mapping_type    IN       VARCHAR2,
      p_exclusion_tbl   IN       jta_sync_task.exclusion_tbl,
      p_resource_id     IN       NUMBER,
      p_resource_type   IN       VARCHAR2
   )
   IS
      l_task_id             NUMBER;
      l_return_status       VARCHAR2(1);
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2(2000);
      l_task_assignment_id  NUMBER;
      l_show_on_calendar    VARCHAR2(100);
      l_date_selected       VARCHAR2(100);
      l_alarm_mins          NUMBER;
      l_scheduled_start     DATE;
      l_scheduled_end       DATE;
      l_planned_end         DATE;
      l_planned_start       DATE;
      l_actual_end          DATE;
      l_actual_start        DATE;
      l_recurrence_rule_id  NUMBER;
      l_rec_rule_id         NUMBER;
      task_id               NUMBER;
      l_task_rec            jtf_task_recurrences_pub.task_details_rec;
      l_reccurences_generated   INTEGER;
      l_update_type         VARCHAR2(15);
      l_repeat_start_date   DATE;
      l_repeat_end_date     DATE;
      l_status_id           NUMBER;
      l_category_id         NUMBER;
      l_subject             VARCHAR2(80);
      l_occurs_month        NUMBER;
      l_occurs_number       NUMBER;
   BEGIN
      fnd_msg_pub.initialize;

      get_alarm_mins (p_task_rec, x_alarm_mins => l_alarm_mins);

      --------------------------------------------
      -- Convert GMT to Client timezone
      --   for plan / schedule / actual dates
      --------------------------------------------
      convert_dates (
         p_task_rec => p_task_rec,
         p_operation => 'CREATE',
         x_planned_start => l_planned_start,
         x_planned_end => l_planned_end,
         x_scheduled_start => l_scheduled_start,
         x_scheduled_end => l_scheduled_end,
         x_actual_start => l_actual_start,
         x_actual_end => l_actual_end,
         x_date_selected => l_date_selected,
         x_show_on_calendar => l_show_on_calendar
      );

      l_category_id := jta_sync_task_category.get_category_id (
                           p_category_name => p_task_rec.category,
                           p_profile_id => jta_sync_task_category.get_profile_id (p_resource_id)
                       );
      /*l_status_id :=
     getchangedstatusid (
        p_task_status_id => p_task_rec.statusid,
        p_source_object_type_code => p_task_rec.objectcode
     );
     */
     l_subject := get_subject( p_subject => p_task_rec.subject
                             , p_type => 'ORACLE');

     IF p_task_rec.objectcode = G_APPOINTMENT THEN
        jta_cal_appointment_pvt.create_appointment (
              p_task_name               => l_subject,
              p_task_type_id            => get_default_task_type,
              p_description             => p_task_rec.description,
              p_task_priority_id        => p_task_rec.priorityid,
              p_owner_type_code         => p_resource_type,
              p_owner_id                => p_resource_id,
              p_planned_start_date      => l_planned_start,
              p_planned_end_date        => l_planned_end,
              p_timezone_id             => g_client_timezone_id,
              p_private_flag            => p_task_rec.privateflag,
              p_alarm_start             => l_alarm_mins,
              p_alarm_on                => p_task_rec.alarmflag,
              p_category_id             => l_category_id,
              x_return_status           => l_return_status,
              x_task_id                 => l_task_id
        );
     ELSE
        jtf_tasks_pvt.create_task (
              p_api_version => 1.0,
              p_init_msg_list => fnd_api.g_true,
              p_commit => fnd_api.g_false,
              p_source_object_type_code => p_task_rec.objectcode,
              p_task_name => l_subject,
              p_task_type_id => get_default_task_type,
              p_description => p_task_rec.description,
              p_task_status_id => p_task_rec.statusId,
              p_task_priority_id => p_task_rec.priorityid,
              p_owner_type_code => p_resource_type,
              p_owner_id => p_resource_id,
              p_planned_start_date => l_planned_start,
              p_planned_end_date => l_planned_end,
              p_scheduled_start_date => l_scheduled_start,
              p_scheduled_end_date => l_scheduled_end,
              p_actual_start_date => l_actual_start,
              p_actual_end_date => l_actual_end,
              p_show_on_calendar => NULL, -- Fix Bug 2467021: For creation, pass NULL
              p_timezone_id => g_client_timezone_id,
              p_date_selected => NULL, -- Fix Bug 2467021: For creation, pass NULL
              p_alarm_start => l_alarm_mins,
              p_alarm_start_uom => 'MIN',
              p_alarm_interval_uom => 'MIN',
              p_alarm_on => p_task_rec.alarmflag,
              p_private_flag => p_task_rec.privateflag,
              p_category_id => l_category_id,
              x_return_status => l_return_status,
              x_msg_count => l_msg_count,
              x_msg_data => l_msg_data,
              x_task_id => l_task_id
        );
      END IF;

      IF jta_sync_common.is_success (l_return_status)
      THEN
           --------------------------------------------
           -- Check whether it has a repeating information
           -- If it has, then create a recurrence
           --------------------------------------------
           IF (   p_task_rec.objectcode = G_APPOINTMENT
              AND p_task_rec.unit_of_measure <> fnd_api.g_miss_char
              AND p_task_rec.unit_of_measure IS NOT NULL)
           --   include open end dates also
           --   AND p_task_rec.end_date IS NOT NULL)
           THEN
              -- Convert repeating start and end date
              --   to client timezone
              convert_recur_date_to_client (
                 p_base_start_time => p_task_rec.plannedstartdate,
                 p_base_end_time => p_task_rec.plannedenddate,
                 p_start_date => p_task_rec.start_date,
                 p_end_date => p_task_rec.end_date,
                 p_occurs_which => p_task_rec.occurs_which,
                 p_uom => p_task_rec.unit_of_measure,
                 x_date_of_month => p_task_rec.date_of_month,
                 x_start_date => l_repeat_start_date,
                 x_end_date => l_repeat_end_date
              );
              IF p_task_rec.unit_of_measure = 'YER' THEN
                l_occurs_month := to_number(to_char(l_repeat_start_date, 'MM'));
              END IF;

              -- include open end dates also
              IF (p_task_rec.end_date IS NULL)
              THEN
                l_occurs_number := G_USER_DEFAULT_REPEAT_COUNT;
              END IF;
                 jtf_task_recurrences_pvt.create_task_recurrence (
                     p_api_version => 1,
                     p_commit => fnd_api.g_false,
                     p_task_id => l_task_id,
                     p_occurs_which => p_task_rec.occurs_which,
                     p_template_flag => 'N',
                     p_date_of_month => p_task_rec.date_of_month,
                     p_occurs_uom => p_task_rec.unit_of_measure,
                     p_occurs_every => p_task_rec.occurs_every,
                     p_occurs_number => l_occurs_number,
                     p_occurs_month => l_occurs_month,
                     p_start_date_active => l_repeat_start_date,
                     p_end_date_active => l_repeat_end_date,
                     p_sunday => p_task_rec.sunday,
                     p_monday => p_task_rec.monday,
                     p_tuesday => p_task_rec.tuesday,
                     p_wednesday => p_task_rec.wednesday,
                     p_thursday => p_task_rec.thursday,
                     p_friday => p_task_rec.friday,
                     p_saturday => p_task_rec.saturday,
                     x_recurrence_rule_id => l_recurrence_rule_id,
                     x_task_rec => l_task_rec,
                     x_output_dates_counter => l_reccurences_generated,
                     x_return_status => l_return_status,
                     x_msg_count => l_msg_count,
                     x_msg_data => l_msg_data
                 );


              IF jta_sync_common.is_success (l_return_status)
              THEN
                    -------------------------------------------------------
                    -- Recurrences are successfully created.
                    -------------------------------------------------------
                    IF p_exclusion_tbl.COUNT > 0
                    THEN
                        process_exclusions (
                              p_exclusion_tbl   => p_exclusion_tbl,
                              p_rec_rule_id => l_recurrence_rule_id,
                              p_repeating_task_id => l_task_id,
                              p_task_rec => p_task_rec
                        );
                    ELSE
                        -------------------------------------------------------
                        -- There are no exclusion tasks.
                        -------------------------------------------------------
                        jta_sync_common.put_messages_to_result (
                           p_task_rec,
                           p_status => g_sync_success,
                           p_user_message => 'JTA_SYNC_SUCCESS'
                        );
                    END IF;
              ELSE
                    -------------------------------------------------------
                    -- Failed to create a task recurrence
                    -------------------------------------------------------
                    jta_sync_common.put_messages_to_result (
                       p_task_rec,
                       p_status => 2,
                       p_user_message => 'JTA_RECURRENCE_CREATION_FAIL'
                    );
              END IF;

           ELSE
              --------------------------------------------------------------------
              -- This is a Single Task and succeeded to create a single task
              --------------------------------------------------------------------
              jta_sync_common.put_messages_to_result (
                   p_task_rec,
                   p_status => g_sync_success,
                   p_user_message => 'JTA_SYNC_SUCCESS'
              );
           END IF;   -- end-check if this is repeating Task

           do_mapping (
                p_task_id      => l_task_id,
                p_operation    => g_new,
                x_task_sync_id => p_task_rec.syncid
           );

           p_task_rec.syncanchor := convert_server_to_gmt (SYSDATE);

       ELSE-- failed
           ---------------------------------------------
           -- Failed to create a task
           ---------------------------------------------

           jta_sync_common.put_messages_to_result (
              p_task_rec,
              p_status => 2,
              p_user_message => 'JTA_SYNC_TASK_CREATION_FAILED'
           );
      END IF;   -- end-check if task creation is successed or not

      /*insert_or_update_mapping (
     p_task_sync_id => p_task_rec.syncid,
     p_task_id => l_task_id,
     p_resource_id => p_resource_id,
     p_mapping_type => p_mapping_type
      );
      */

   END create_new_data;

   PROCEDURE update_existing_data (
      p_task_rec        IN OUT NOCOPY   jta_sync_task.task_rec,
      p_exclusion_tbl   IN       jta_sync_task.exclusion_tbl,
      p_resource_id     IN       NUMBER,
      p_resource_type   IN       VARCHAR2
   )
   IS
      l_ovn                 NUMBER;
      l_task_id             NUMBER;
      l_exclude_task_id     NUMBER;
      l_return_status       VARCHAR2(1);
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2(2000);
      l_task_assignment_id  NUMBER;
      l_show_on_calendar    VARCHAR2(100);
      l_date_selected       VARCHAR2(100);
      l_alarm_mins          NUMBER;
      l_rec_rule_id         NUMBER;
      task_id               NUMBER;
      l_update_type         VARCHAR2(15);
      l_planned_start_date  DATE;
      l_planned_end_date    DATE;
      l_scheduled_start_date    DATE;
      l_scheduled_end_date  DATE;
      l_actual_start_date   DATE;
      l_actual_end_date     DATE;
      l_sync_id             NUMBER;
      l_category_id         NUMBER;
      l_recurr              VARCHAR2(5);
      l_update_all          VARCHAR2(5);
      l_new_recurrence_rule_id  NUMBER;
      l_occurs_month        NUMBER;
      l_occurs_number       NUMBER;

      CURSOR c_recur_tasks (b_recurrence_rule_id NUMBER)
      IS
         SELECT task_id,
                planned_start_date,
                planned_end_date,
                scheduled_start_date,
                scheduled_end_date,
                actual_start_date,
                actual_end_date,
                calendar_start_date,
                timezone_id
           FROM jtf_tasks_b
          WHERE recurrence_rule_id = b_recurrence_rule_id;

      l_changed_rule boolean ;
      l_status_id number;
      l_task_name jtf_tasks_tl.task_name%TYPE;
   BEGIN
       fnd_msg_pub.initialize;

       get_alarm_mins (
           p_task_rec,
           x_alarm_mins => l_alarm_mins
       );

       ---------------------------------------
       -- Convert GMT to client timezone
       --   for plan / schedule / actual dates
       ---------------------------------------
       convert_dates (
           p_task_rec         => p_task_rec,
           p_operation        => 'UPDATE',
           x_planned_start    => l_planned_start_date,
           x_planned_end      => l_planned_end_date,
           x_scheduled_start  => l_scheduled_start_date,
           x_scheduled_end    => l_scheduled_end_date,
           x_actual_start     => l_actual_start_date,
           x_actual_end       => l_actual_end_date,
           x_date_selected    => l_date_selected,
           x_show_on_calendar => l_show_on_calendar
       );

       l_task_name   := get_subject(p_subject => p_task_rec.subject,
                                    p_type => 'ORACLE');
       l_task_id     := get_task_id (p_sync_id => p_task_rec.syncid);
       l_ovn         := get_ovn (p_task_id => l_task_id);
       l_rec_rule_id := get_recurrence_rule_id (p_task_id => l_task_id);
       l_sync_id     := p_task_rec.syncid;

       l_status_id := getchangedstatusid (
                           p_task_status_id => p_task_rec.statusid,
                           p_source_object_type_code => p_task_rec.objectcode
                      );

       l_category_id := jta_sync_task_category.get_category_id (
                             p_category_name => p_task_rec.category,
                             p_profile_id    => jta_sync_task_category.get_profile_id(p_resource_id)
                        );

       l_update_type := get_update_type (
                            p_task_id => l_task_id,
                            p_resource_id => p_resource_id,
                            p_subject => p_task_rec.subject
                       );
       -- if it is repeating and exclusion and owner privilage
       --process exclusions
       IF NVL(p_task_rec.resultId,0) < 2 AND
          l_rec_rule_id IS NOT NULL AND
          p_task_rec.unit_of_measure IS NOT NULL AND
          p_task_rec.unit_of_measure <> fnd_api.g_miss_char
       THEN
          IF l_update_type = g_update_all
          THEN
             IF p_exclusion_tbl.COUNT > 0
             THEN
                 process_exclusions (
                           p_exclusion_tbl => p_exclusion_tbl,
                           p_rec_rule_id => l_rec_rule_id,
                           p_repeating_task_id => l_task_id,
                           p_task_rec => p_task_rec
                 );
             ELSE -- p_exclusion_tbl.COUNT = 0 and check change rule
                 l_changed_rule := jta_sync_task_common.changed_repeat_rule(p_task_rec => p_task_rec);

                 IF l_changed_rule AND
                    l_update_type = jta_sync_task_common.g_update_all
                 THEN -- Changed Repeating Rule
                    IF p_task_rec.unit_of_measure = 'YER' THEN
                       l_occurs_month := to_number(to_char(p_task_rec.start_date, 'MM'));
                    END IF;

                    -- include open end dates also
                    IF (p_task_rec.end_date IS NULL) THEN
                      l_occurs_number := G_USER_DEFAULT_REPEAT_COUNT;
                    END IF;

                    jtf_task_recurrences_pvt.update_task_recurrence (
                           p_api_version        =>   1.0,
                           p_task_id            =>   l_task_id,
                           p_recurrence_rule_id =>   l_rec_rule_id,
                           p_occurs_which       =>   p_task_rec.occurs_which,
                           p_date_of_month      =>   p_task_rec.date_of_month,
                           p_occurs_month       =>   l_occurs_month,
                           p_occurs_uom         =>   p_task_rec.unit_of_measure,
                           p_occurs_every       =>   p_task_rec.occurs_every,
                           p_occurs_number      =>   l_occurs_number,
                           p_start_date_active  =>   p_task_rec.start_date,
                           p_end_date_active    =>   p_task_rec.end_date,
                           p_sunday             =>   p_task_rec.sunday,
                           p_monday             =>   p_task_rec.monday,
                           p_tuesday            =>   p_task_rec.tuesday,
                           p_wednesday          =>   p_task_rec.wednesday,
                           p_thursday           =>   p_task_rec.thursday,
                           p_friday             =>   p_task_rec.friday,
                           p_saturday           =>   p_task_rec.saturday,
                           x_new_recurrence_rule_id =>   l_new_recurrence_rule_id,
                           x_return_status      =>   l_return_status,
                           x_msg_count          =>   l_msg_count,
                           x_msg_data           =>   l_msg_data
                    );

                    IF NOT jta_sync_common.is_success (l_return_status)
                    THEN-- Failed to update a task
                       jta_sync_common.put_messages_to_result (
                            p_task_rec,
                            p_status => 2,
                            p_user_message => 'JTA_SYNC_UPDATE_RECUR_FAIL'
                       );
                    END IF;   -- is_success
                 END IF;   -- change rule
             END IF; -- p_exclusion_tbl.COUNT > 0
          END IF; -- l_update_type = g_update_all
       END IF; -- success and recurring appt process

       --------------------------------------------------
       -- Update Repeating Tasks
       --  1. You can delete the excluded tasks, or
       --  2. You can update all occurrences
       --------------------------------------------------
       --- update_task with new parameters
       IF l_update_type = g_update_all
       THEN
           -----------------------------------------------------------
           -- Fix for the bug 2380399
           --  : If the current sync has a change of any fields
           --    along with the change of repeating rule,
           --    The update_task_recurrence_rule API creates new repeating
           --    tasks and updates the mapping record with the new first
           --    task_id. Hence the new task_id must be picked from
           --    mapping table again. And the new object_version_number
           --    of the the new task_id must be selected for update of the
           --    other fields
           -----------------------------------------------------------
           l_task_id := get_task_id (p_sync_id => p_task_rec.syncid);
           l_ovn := get_ovn (p_task_id => l_task_id);

           IF p_task_rec.objectcode = G_APPOINTMENT
           THEN
               jta_cal_appointment_pvt.update_appointment (
                    p_object_version_number  => l_ovn ,
                    p_task_id                => l_task_id,
                    p_task_name              => NVL (l_task_name, ' '),
                    p_description            => p_task_rec.description,
                    p_task_priority_id       => p_task_rec.priorityid,
                    p_planned_start_date     => l_planned_start_date,
                    p_planned_end_date       => l_planned_end_date,
                    p_timezone_id            => get_task_timezone_id (l_task_id),
                    p_private_flag           => p_task_rec.privateflag,
                    p_alarm_start            => l_alarm_mins,
                    p_alarm_on               => p_task_rec.alarmflag,
                    p_category_id            => l_category_id,
                    p_change_mode            => 'A',
                    x_return_status          => l_return_status
               );
           ELSE
               jtf_tasks_pvt.update_task (
                    p_api_version           => 1.0,
                    p_init_msg_list         => fnd_api.g_true,
                    p_commit                => fnd_api.g_false,
                    p_task_id               => l_task_id,
                    p_object_version_number => l_ovn,
                    p_task_name             => NVL (l_task_name, ' '),
                    p_description           => p_task_rec.description,
                    p_task_status_id        => p_task_rec.statusid,
                    p_task_priority_id      => p_task_rec.priorityid,
                    p_planned_start_date    => l_planned_start_date,
                    p_planned_end_date      => l_planned_end_date,
                    p_scheduled_start_date  => l_scheduled_start_date,
                    p_scheduled_end_date    => l_scheduled_end_date,
                    p_actual_start_date     => l_actual_start_date,
                    p_actual_end_date       => l_actual_end_date,
                    p_show_on_calendar      => fnd_api.g_miss_char, -- Fix Bug 2467021: For update, pass g_miss_char
                    p_date_selected         => fnd_api.g_miss_char, -- Fix Bug 2467021: For update, pass g_miss_char
                    p_alarm_start           => l_alarm_mins,
                    p_alarm_start_uom       => 'MIN',
                    p_timezone_id           => get_task_timezone_id (l_task_id),
                    p_private_flag          => p_task_rec.privateflag,
                    p_category_id           => l_category_id,
                    p_change_mode           => 'A',
                    p_enable_workflow       => 'N',
                    p_abort_workflow        => 'N',
                    x_return_status         => l_return_status,
                    x_msg_count             => l_msg_count,
                    x_msg_data              => l_msg_data
              );
           END IF;

           IF NOT jta_sync_common.is_success (l_return_status)
           THEN-- Failed to update a task

               jta_sync_common.put_messages_to_result (
                  p_task_rec,
                  p_status => 2,
                  p_user_message => 'JTA_SYNC_UPDATE_TASK_FAIL'
               );   -- l_return_status
           END IF;

      ELSIF l_update_type = g_update_status
      THEN
         l_task_assignment_id := get_assignment_id (
                                       p_task_id => l_task_id,
                                       p_resource_id => p_resource_id,
                                       p_resource_type => p_resource_type
                                 );

         l_ovn := get_ovn (p_task_assignment_id => l_task_assignment_id);

         jtf_task_assignments_pvt.update_task_assignment (
             p_api_version           => 1.0,
             p_object_version_number => l_ovn,
             p_init_msg_list         => fnd_api.g_true,
             p_commit                => fnd_api.g_false,
             p_task_assignment_id    => l_task_assignment_id,
             p_assignment_status_id  => 3,   -- ACCEPT
             --p_update_all            => l_update_all,
             --p_enable_workflow       => 'N',
             --p_abort_workflow        => 'N',
             x_return_status         => l_return_status,
             x_msg_count             => l_msg_count,
             x_msg_data              => l_msg_data
         );

         IF NOT jta_sync_common.is_success (l_return_status)
         THEN
             jta_sync_common.put_messages_to_result (
                p_task_rec,
                p_status => 2,
                p_user_message => 'JTA_SYNC_UPDATE_STS_FAIL'
             );
         END IF;

     END IF; -- l_update_type

      -- Check the current status and update if it's succeeded
     IF nvl(p_task_rec.resultId,0) < 2
     THEN
             jta_sync_common.put_messages_to_result (
                p_task_rec,
                p_status => g_sync_success,
                p_user_message => 'JTA_SYNC_SUCCESS'
             );
             --CHANGE TO GMT
             p_task_rec.syncanchor := convert_server_to_gmt (SYSDATE);
     END IF;

   END update_existing_data;

   PROCEDURE delete_exclusion_task (
      p_repeating_task_id   IN       NUMBER,
      x_task_rec            IN OUT NOCOPY   jta_sync_task.task_rec
   )
   IS
      l_ovn     NUMBER;
      l_return_status   VARCHAR2(1);
      l_msg_data    VARCHAR2(2000);
      l_msg_count   NUMBER;
   BEGIN

      l_return_status := fnd_api.g_ret_sts_success;

      l_ovn := get_ovn (p_task_id => p_repeating_task_id);

      IF x_task_rec.objectcode = G_APPOINTMENT
      THEN
          jta_cal_appointment_pvt.delete_appointment (
              p_object_version_number       => l_ovn,
              p_task_id                     => p_repeating_task_id,
              p_delete_future_recurrences   => fnd_api.g_false,
              x_return_status               => l_return_status
          );
      ELSE
          jtf_tasks_pvt.delete_task (
            p_api_version               => 1.0,
            p_init_msg_list             => fnd_api.g_true,
            p_commit                    => fnd_api.g_false,
            p_task_id                   => p_repeating_task_id,
            p_object_version_number     => l_ovn,
            x_return_status             => l_return_status,
            p_delete_future_recurrences => fnd_api.g_false ,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data
          );
      END IF;

      IF jta_sync_common.is_success (l_return_status)
      THEN
         x_task_rec.syncanchor := convert_server_to_gmt (SYSDATE);

         jta_sync_common.put_messages_to_result (
              x_task_rec,
              p_status => g_sync_success,
              p_user_message => 'JTA_SYNC_SUCCESS'
         );
      ELSE
         jta_sync_common.put_messages_to_result (
              x_task_rec,
              p_status => 2,
              p_user_message => 'JTA_SYNC_DELETE_EXCLUSION_FAIL'
         );
      END IF;
   END delete_exclusion_task;

   PROCEDURE delete_task_data (
      p_task_rec      IN OUT NOCOPY   jta_sync_task.task_rec,
      p_delete_map_flag   IN       BOOLEAN
   )
   IS
      l_task_id     NUMBER;
      l_ovn     NUMBER;
      l_return_status   VARCHAR2(1);
      l_msg_data    VARCHAR2(2000);
      l_msg_count   NUMBER;
   BEGIN
      l_return_status := fnd_api.g_ret_sts_success;

      l_task_id := get_task_id (p_sync_id => p_task_rec.syncid);
      l_ovn := get_ovn (p_task_id => l_task_id);

      IF p_task_rec.objectcode = G_APPOINTMENT THEN
          jta_cal_appointment_pvt.delete_appointment (
              p_object_version_number       => l_ovn,
              p_task_id                     => l_task_id,
              p_delete_future_recurrences   => 'A',
              x_return_status               => l_return_status
          );
      ELSE
          jtf_tasks_pvt.delete_task (
             p_api_version => 1.0,
             p_init_msg_list => fnd_api.g_true,
             p_commit => fnd_api.g_false,
             p_task_id => l_task_id,
             p_object_version_number => l_ovn,
             p_delete_future_recurrences => 'A',
             x_return_status => l_return_status,
             x_msg_count => l_msg_count,
             x_msg_data => l_msg_data
          );
      END IF;

      IF jta_sync_common.is_success (l_return_status)
      THEN
         p_task_rec.syncanchor := convert_server_to_gmt (SYSDATE + 1 / (24 * 60 * 60));

         IF p_delete_map_flag
         THEN
            jta_sync_task_map_pkg.delete_row (
               p_task_sync_id => p_task_rec.syncid
            );
         END IF;

         jta_sync_common.put_messages_to_result (
            p_task_rec,
            p_status => g_sync_success,
            p_user_message => 'JTA_SYNC_SUCCESS'
         );
      ELSE
         jta_sync_common.put_messages_to_result (
            p_task_rec,
            p_status => 2,
            p_user_message => 'JTA_SYNC_DELETE_TASK_FAILED'
         );
      END IF;
   END delete_task_data;

   PROCEDURE reject_task_data (p_task_rec IN OUT NOCOPY jta_sync_task.task_rec)
   IS
       l_task_id              NUMBER;
       l_rec_rule_id          NUMBER;
       l_task_assignment_id   NUMBER;
       l_ovn                  NUMBER;
       l_resource_id          NUMBER;
       l_resource_type        VARCHAR2(30);
       l_deleted              BOOLEAN        := FALSE;
       l_return_status        VARCHAR2(1);
       l_msg_data             VARCHAR2(2000);
       l_msg_count            NUMBER;

       --CURSOR c_tasks (b_recurrence_rule_id NUMBER, b_task_id NUMBER)
       --IS
       --   SELECT task_id, source_object_type_code
       --     FROM jtf_tasks_b
       --    WHERE (   b_recurrence_rule_id IS NOT NULL
       --      AND recurrence_rule_id = b_recurrence_rule_id)
       --       OR (   b_recurrence_rule_id IS NULL
       --      AND task_id = b_task_id);

       l_update_all varchar2(1) ;

   BEGIN
       get_resource_details (l_resource_id, l_resource_type);

       l_task_id := get_task_id (p_sync_id => p_task_rec.syncid);
       l_rec_rule_id := get_recurrence_rule_id (p_task_id => l_task_id);

       if l_rec_rule_id is not null then
           l_update_all := 'Y' ;
       else
           l_update_all := null ;
       end if ;

       l_task_assignment_id := get_assignment_id (
                                     p_task_id => l_task_id,
                                     p_resource_id => l_resource_id,
                                     p_resource_type => l_resource_type
                               );

       l_ovn := get_ovn (p_task_assignment_id => l_task_assignment_id);

       jtf_task_assignments_pvt.update_task_assignment (
            p_api_version => 1.0,
            p_object_version_number => l_ovn,
            p_init_msg_list => fnd_api.g_true,
            p_commit => fnd_api.g_false,
            p_task_assignment_id => l_task_assignment_id,
            p_assignment_status_id => 4,   -- reject
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data
            --p_enable_workflow  => 'N',
            --p_abort_workflow  => 'N'
       );

       IF jta_sync_common.is_success (l_return_status)
       THEN
            p_task_rec.syncanchor := convert_server_to_gmt(SYSDATE);

            jta_sync_common.put_messages_to_result (
               p_task_rec,
               p_status => g_sync_success,
               p_user_message => 'JTA_SYNC_SUCCESS'
            );

            jta_sync_task_map_pkg.delete_row(p_task_sync_id => p_task_rec.syncid);
       ELSE
            jta_sync_common.put_messages_to_result (
               p_task_rec,
               p_status => 2,
               p_user_message => 'JTA_SYNC_UPDATE_STS_FAIL'
            );
       END IF;
   END reject_task_data;

   FUNCTION changed_repeat_rule (p_task_rec IN jta_sync_task.task_rec)
      RETURN BOOLEAN
   IS
      CURSOR c_task_recur (b_task_id NUMBER)
      IS
     SELECT jtrr.*
       FROM jtf_task_recur_rules jtrr, jtf_tasks_b jtb
      WHERE jtb.task_id = b_task_id
        AND jtb.recurrence_rule_id IS NOT NULL
        AND jtrr.recurrence_rule_id = jtb.recurrence_rule_id;

      l_task_id      NUMBER;
      l_rec_task_recur   c_task_recur%ROWTYPE;
      l_start_date   DATE;
      l_end_date     DATE;
      l_current      DATE             := SYSDATE;
      l_date_of_month    NUMBER;
   BEGIN
      l_task_id := get_task_id (p_sync_id => p_task_rec.syncid);
      OPEN c_task_recur (l_task_id);
      FETCH c_task_recur into l_rec_task_recur;

      IF c_task_recur%NOTFOUND
      THEN
     CLOSE c_task_recur;
     RETURN FALSE;
      END IF;

      CLOSE c_task_recur;
      convert_recur_date_to_client (
     p_base_start_time => p_task_rec.plannedstartdate,
     p_base_end_time => p_task_rec.plannedenddate,
     p_start_date => p_task_rec.start_date,
     p_end_date => p_task_rec.end_date,
     p_occurs_which => p_task_rec.occurs_which,
     p_uom => p_task_rec.unit_of_measure,
     x_date_of_month => l_date_of_month,
     x_start_date => l_start_date,
     x_end_date => l_end_date
      );



      IF     NVL (p_task_rec.occurs_which, 0) =
        NVL (l_rec_task_recur.occurs_which, 0)
     AND NVL (p_task_rec.date_of_month, 0) =
        NVL (l_rec_task_recur.date_of_month, 0)
     AND p_task_rec.unit_of_measure = l_rec_task_recur.occurs_uom
     AND NVL (p_task_rec.occurs_every, 0) =
        NVL (l_rec_task_recur.occurs_every, 0)
     /*AND NVL (p_task_rec.occurs_number, 0) =
        NVL (l_rec_task_recur.occurs_number, 0)*/
     AND l_start_date = l_rec_task_recur.start_date_active
     AND NVL (l_end_date, TRUNC (l_current)) =
        NVL (l_rec_task_recur.end_date_active, TRUNC (l_current))
     AND NVL (p_task_rec.sunday, '?') = NVL (l_rec_task_recur.sunday, '?')
     AND NVL (p_task_rec.monday, '?') = NVL (l_rec_task_recur.monday, '?')
     AND NVL (p_task_rec.tuesday, '?') =
        NVL (l_rec_task_recur.tuesday, '?')
     AND NVL (p_task_rec.wednesday, '?') =
        NVL (l_rec_task_recur.wednesday, '?')
     AND NVL (p_task_rec.thursday, '?') =
        NVL (l_rec_task_recur.thursday, '?')
     AND NVL (p_task_rec.friday, '?') = NVL (l_rec_task_recur.friday, '?')
     AND NVL (p_task_rec.saturday, '?') =
        NVL (l_rec_task_recur.saturday, '?')
      THEN
     RETURN FALSE;
      ELSE
     RETURN TRUE;
      END IF;
   END changed_repeat_rule;

      PROCEDURE transformstatus (
      p_task_status_id   IN OUT NOCOPY      NUMBER,
      p_task_sync_id     IN      NUMBER,
      x_operation    IN OUT NOCOPY      VARCHAR2
   )
   IS
      l_rejected_flag    CHAR;
      l_cancelled_flag   CHAR;
      l_completed_flag   CHAR;
      l_closed_flag  CHAR;
      l_assigned_flag    CHAR;
      l_working_flag     CHAR;
      l_schedulable_flag CHAR;
      l_accepted_flag    CHAR;
      l_on_hold_flag     CHAR;
      l_approved_flag    CHAR;

      CURSOR c_task_status
      IS
     SELECT closed_flag, completed_flag, cancelled_flag, rejected_flag,
        assigned_flag, working_flag, schedulable_flag, accepted_flag,
        on_hold_flag, approved_flag

       FROM jtf_task_statuses_b
      WHERE task_status_id = p_task_status_id;
   BEGIN
       IF     (p_task_status_id = 8)
     OR (p_task_status_id = 4)
     OR (p_task_status_id = 7)
         OR (p_task_status_id = 12)
     OR (p_task_status_id = 15)
     OR (p_task_status_id = 16)
     OR (p_task_status_id = 6)
    THEN
        IF    (p_task_status_id = 8)
            OR (p_task_status_id = 4)
            OR (p_task_status_id = 7)
            THEN
                  x_operation := jta_sync_task_common.g_delete;
            END IF;

        IF   (p_task_status_id = 12)
          OR (p_task_status_id = 15)
          OR (p_task_status_id = 16)
          OR (p_task_status_id = 6)
        THEN
            IF p_task_sync_id IS NOT NULL
                THEN
               OPEN c_task_status;
               FETCH c_task_status into l_closed_flag, l_rejected_flag, l_cancelled_flag, l_completed_flag,
                        l_assigned_flag, l_working_flag, l_schedulable_flag,
                        l_accepted_flag, l_on_hold_flag, l_approved_flag;

               IF    (NVL (l_closed_flag, 'N') = 'Y')
              OR (NVL (l_rejected_flag, 'N') = 'Y')
              OR (NVL (l_completed_flag, 'N') = 'Y')
              OR (NVL (l_cancelled_flag, 'N') = 'Y')
               THEN
              x_operation := jta_sync_task_common.g_delete;
                   END IF;
                   CLOSE c_task_status;
                END IF;

            END IF;

    ELSE
        OPEN c_task_status;
        FETCH c_task_status into l_closed_flag, l_rejected_flag, l_cancelled_flag, l_completed_flag,
                     l_assigned_flag, l_working_flag, l_schedulable_flag,
                     l_accepted_flag, l_on_hold_flag, l_approved_flag;

        IF  (NVL (l_closed_flag, 'N') = 'Y')
              OR (NVL (l_rejected_flag, 'N') = 'Y')
              OR (NVL (l_completed_flag, 'N') = 'Y')
              OR (NVL (l_cancelled_flag, 'N') = 'Y')
        THEN
            x_operation := jta_sync_task_common.g_delete;
            ELSIF (NVL (l_assigned_flag, 'N') = 'Y')
        THEN    p_task_status_id := 12;
        ELSIF (NVL (l_working_flag, 'N') = 'Y')
        THEN    p_task_status_id := 15;
        ELSIF (NVL (l_schedulable_flag, 'N') = 'Y')
        THEN    p_task_status_id := 12;
        ELSIF (NVL (l_accepted_flag, 'N') = 'Y')
        THEN    p_task_status_id := 15;
        ELSIF (NVL (l_on_hold_flag, 'N') = 'Y')
        THEN    p_task_status_id := 16;
        ELSIF (NVL (l_approved_flag, 'N') = 'Y')
        THEN    p_task_status_id := 15;
        END IF;
        x_operation := jta_sync_task_common.g_modify;

        CLOSE c_task_status;

    END IF;
   END transformstatus;

   FUNCTION getchangedstatusid (
      p_task_status_id        IN   NUMBER,
      p_source_object_type_code   IN   VARCHAR2
      )
      RETURN NUMBER
   IS
   BEGIN
      IF (p_source_object_type_code = G_APPOINTMENT)
      THEN
     RETURN p_task_status_id;
      ELSE
     IF (checkuserstatusrule ())
     THEN
        RETURN fnd_api.g_miss_num;
     ELSE
        RETURN p_task_status_id;
     END IF;
      END IF;
   END getchangedstatusid;


  FUNCTION checkUserStatusRule
   RETURN BOOLEAN
   IS
   l_num NUMBER;
   BEGIN
       IF G_USER_STATUS_RULE IS NULL
       THEN
             SELECT 1 INTO l_num
         FROM
         fnd_user
         ,fnd_user_resp_groups
         ,jtf_state_rules_b
         , jtf_state_responsibilities
         WHERE fnd_user.user_id = fnd_global.user_id
         AND fnd_user.user_id = fnd_user_resp_groups.user_id
         AND fnd_user_resp_groups.responsibility_id = jtf_state_responsibilities.responsibility_id
         AND jtf_state_responsibilities.rule_id = jtf_state_rules_b.rule_id;
         G_USER_STATUS_RULE := TRUE;
      RETURN TRUE;
    ELSE
             RETURN G_USER_STATUS_RULE;
       END IF;

   EXCEPTION
   WHEN no_data_found
   THEN
         G_USER_STATUS_RULE := FALSE;
     RETURN FALSE;
   WHEN too_many_rows
   THEN
        G_USER_STATUS_RULE := TRUE;
    RETURN TRUE;
END checkUserStatusRule;

    -- Added to fix bug 2382927
    FUNCTION validate_syncid(p_syncid IN NUMBER)
    RETURN BOOLEAN
    IS
        CURSOR c_mapping (b_syncid NUMBER) IS
        SELECT 1
          FROM jta_sync_task_mapping
         WHERE task_sync_id = b_syncid;

        l_dummy NUMBER;
        l_valid BOOLEAN := TRUE;
    BEGIN

        ---------------------------------
        -- Fix Bug# 2395004
        IF NVL(p_syncid,-1) < 1
        THEN
           fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
           fnd_msg_pub.add;

           fnd_message.set_name('JTF', 'JTA_SYNC_INVALID_SYNCID');
           fnd_message.set_token('PROC_NAME','JTA_SYNC_TASK_COMMON.GET_TASK_ID');
           fnd_msg_pub.add;

           raise_application_error (-20100,jta_sync_common.get_messages);
        END IF;
        ---------------------------------

        OPEN c_mapping (p_syncid);
        FETCH c_mapping INTO l_dummy;
        IF c_mapping%NOTFOUND
        THEN
            l_valid := FALSE;
        END IF;
        CLOSE c_mapping;

        RETURN l_valid;
    END validate_syncid;

END jta_sync_task_common;

/
