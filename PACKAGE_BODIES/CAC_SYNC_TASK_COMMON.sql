--------------------------------------------------------
--  DDL for Package Body CAC_SYNC_TASK_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SYNC_TASK_COMMON" AS
/* $Header: cacvstcb.pls 120.63.12010000.1 2008/07/24 18:03:24 appldev ship $ */
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
| 04-Nov-2004   sachoudh         Created.                               |
| 01-FEB-2005   rhshriva     Changed update_existing_data               |
| 03-FEB-2004   rhshriva     Changed create_new_data and do_mapping     |
| 26-SEP-2005   deeprao      Changed delete_task_data                   |
|			     and delete_bookings, added delete_tasks    |
*=======================================================================*/

   g_fb_type_changed  boolean := false;

   PROCEDURE check_span_days (
      p_source_object_type_code   IN VARCHAR2,
      p_calendar_start_date       IN DATE,
      p_calendar_end_date         IN DATE,
      p_task_id                   IN NUMBER,
      p_entity                    IN VARCHAR2,
      x_status                   OUT NOCOPY BOOLEAN
   )
   IS

  --cursor to check if the task is recurring once every more than one year
    cursor getTaskRecur(b_task_id IN NUMBER) is

     SELECT 1
     FROM jtf_task_recur_rules jtrr, jtf_tasks_b jtb
      WHERE ((jtrr.occurs_uom ='YER' AND
	  jtrr.occurs_every > 1)
	  OR
	  (jtrr.occurs_uom ='MON'
	  AND (DECODE(sunday,'Y',1,0) + DECODE(monday,'Y',1,0) + DECODE(tuesday,'Y',1,0)
	  + DECODE(wednesday,'Y',1,0) + DECODE(thursday,'Y',1,0) + DECODE(friday,'Y',1,0)
	  + DECODE(saturday,'Y',1,0)) > 1)) AND
      jtb.recurrence_rule_id=jtrr.recurrence_rule_id
      AND jtb.task_id=b_task_id;

     l_temp NUMBER;



   BEGIN
      -------------------------------------------
      -- Returns TRUE:
      --   1) if an appointment spans over a year
      --   2) if a task is endless and parameter G_CAC_SYNC_TASK_NO_DATE is set to no
      -------------------------------------------
      x_status := FALSE;

   open getTaskRecur(p_task_id);
    fetch getTaskRecur into l_temp;


      IF   (p_entity=G_TASK   --source_object_type_code = G_TASK
             AND p_calendar_end_date   IS NULL AND
              G_CAC_SYNC_TASK_NO_DATE ='N'
           )
          OR
          ( p_entity = G_APPOINTMENT AND  getTaskRecur%FOUND   )

      THEN
          x_status := TRUE;
      END IF;

   if (getTaskRecur%ISOPEN)  then
    close getTaskRecur;
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

      /*  x_end_date :=
       convert_task_to_gmt (
        TO_DATE (
           l_end_date || ' ' || l_end_time,
           'DD-MON-YYYY HH24:MI:SS'
        ),
        p_timezone_id
       );*/
       x_end_date := convert_task_to_gmt ( p_end_date, p_timezone_id  );
      ELSE
         x_start_date := TO_DATE (
           l_start_date || ' ' || l_start_time,
           'DD-MON-YYYY HH24:MI:SS');
        x_end_date :=TO_DATE (
           l_end_date || ' ' || l_end_time,
           'DD-MON-YYYY HH24:MI:SS'
        );
       END IF;
     /* x_start_date := TRUNC (x_start_date);
      x_end_date := TRUNC (x_end_date);*/--no trucation of dates hsould be done
      --dates should have time component on it.please refer to bug 4261252.



      IF     p_occurs_which IS NULL
        AND (p_uom = 'MON' OR p_uom ='YER') THEN
        x_date_of_month := TO_CHAR (x_start_date, 'DD');
      END IF;
   END convert_recur_date_to_gmt;

   PROCEDURE process_exclusions (
         p_exclusion_tbl      IN  OUT NOCOPY    cac_sync_task.exclusion_tbl,
         p_rec_rule_id        IN     NUMBER,
         p_repeating_task_id  IN     NUMBER,
         p_task_rec           IN OUT NOCOPY cac_sync_task.task_rec
   )
   IS
       i NUMBER := 0;
       l_exclude_task_id NUMBER ;
       l_temp   NUMBER;

  CURSOR exclusion_exists(b_exclude_task_id IN NUMBER)
   IS
          SELECT task_id FROM jta_task_exclusions WHERE
             task_id=b_exclude_task_id;
   l_exclusion_exists  exclusion_exists%ROWTYPE;
   l_update_exclusion  BOOLEAN:=FALSE;

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


     OPEN exclusion_exists(l_exclude_task_id);

      FETCH exclusion_exists INTO l_exclusion_exists;

       IF (exclusion_exists%FOUND)  THEN
         l_update_exclusion:=TRUE;
       ELSE
         l_update_exclusion:=FALSE;
       END IF;
     IF (exclusion_exists%isopen)  THEN
        CLOSE exclusion_exists;
     END IF;


       if ((p_exclusion_tbl(i).eventType <> g_delete) ) then
--creating exclusion


     if (l_update_exclusion)  then

          delete from jta_task_exclusions
                 where  task_id=l_exclude_task_id
              and recurrence_rule_id=p_rec_rule_id;

  end if;--   if (l_update_exclusion)  then



           create_updation_record
	            (p_exclusion        =>p_exclusion_tbl(i),
	             p_task_rec         =>p_task_rec  ,
	             p_exclude_task_id  =>l_exclude_task_id,
                     p_rec_rule_id=>p_rec_rule_id);
                     --deleting instance

             else
                 delete_exclusion_task (
                  p_repeating_task_id => l_exclude_task_id,
                  x_task_rec          => p_task_rec
              );

           end if;

         END IF; -- l_task_id
       END LOOP;
   END process_exclusions;

procedure create_updation_record
  (p_exclusion       IN OUT NOCOPY   cac_sync_task.exclusion_rec,
   p_task_rec        IN  cac_sync_task.task_rec  ,
   p_exclude_task_id  IN NUMBER,
   p_rec_rule_id   IN NUMBER )

   is
    CURSOR getCollabDetails(b_task_id  NUMBER) IS
      SELECT COLLAB_ID, MEETING_MODE,MEETING_ID,MEETING_URL,JOIN_URL ,
      PLAYBACK_URL ,DOWNLOAD_URL ,CHAT_URL ,IS_STANDALONE_LOCATION,DIAL_IN
      FROM  CAC_VIEW_COLLAB_DETAILS_VL
      WHERE task_id=b_task_id;

    l_collab_details         getCollabDetails%ROWTYPE;

    l_return_status       VARCHAR2(1);
    l_msg_count           NUMBER;
    l_msg_data            VARCHAR2(2000);
    p_updation_record   jtf_task_repeat_appt_pvt.updated_field_rec;
    l_ovn  NUMBER;
    l_location      CAC_VIEW_COLLAB_DETAILS_TL.LOCATION%TYPE;
    l_alarm_days   		  NUMBER;
    l_alarm_mins		  NUMBER;

     Begin
   --no timexone conversion is done. Need to do timezone conversion.
        p_updation_record.task_id  :=p_exclude_task_id;
      --  p_updation_record.task_name :=p_exclusion.subject;
        p_updation_record.description:=p_exclusion.description;
        p_updation_record.task_status_id  :=p_exclusion.statusId;
        p_updation_record.task_priority_id   :=p_exclusion.priorityId;
      --  p_updation_record.owner_type_code :=p_task_rec.resourcetype;
     --   p_updation_record.owner_id      :=p_task_rec.resourceid;
        get_owner_info(p_task_id  =>p_exclude_task_id,
        x_task_name     =>p_updation_record.task_name,
        x_owner_id      =>p_updation_record.owner_id,
        x_owner_type_code  =>p_updation_record.owner_type_code   );

        p_updation_record.task_name :=p_exclusion.subject;

	IF (p_exclusion.objectcode <> G_TASK)
		THEN
		   IF (p_exclusion.alarmflag = 'Y')
		   THEN
		      l_alarm_days :=
           	  p_exclusion.plannedstartdate - p_exclusion.alarmdate;
			  l_alarm_mins := ROUND (l_alarm_days * 1440, 0);
		   ELSE
		      l_alarm_mins := NULL;
		   END IF;
		ELSE
		   l_alarm_mins := NULL;
      	END IF;

   if ( p_exclude_task_id is not null) then

        p_updation_record.planned_start_date :=convert_gmt_to_task (p_exclusion.plannedstartdate, p_exclude_task_id);
        p_updation_record.planned_end_date :=convert_gmt_to_task (p_exclusion.plannedenddate, p_exclude_task_id);
        p_updation_record.scheduled_start_date:=convert_gmt_to_task (p_exclusion.scheduledstartdate, p_exclude_task_id);
        p_updation_record.scheduled_end_date :=convert_gmt_to_task (p_exclusion.scheduledenddate, p_exclude_task_id);
        p_updation_record.actual_end_date :=convert_gmt_to_task (p_exclusion.actualenddate, p_exclude_task_id);     --  DATE     DEFAULT fnd_api.g_miss_date,
        p_updation_record.actual_start_date :=convert_gmt_to_task (p_exclusion.actualstartdate, p_exclude_task_id);     --  DATE
        p_updation_record.old_calendar_start_date:=convert_gmt_to_task (p_exclusion.exclusion_date,p_exclude_task_id); --.plannedstartdate;
        p_updation_record.new_calendar_start_date:=convert_gmt_to_task (p_exclusion.plannedstartdate,p_exclude_task_id);
        p_updation_record.new_calendar_end_date:=convert_gmt_to_task (p_exclusion.plannedenddate,p_exclude_task_id);


     else


        p_updation_record.planned_start_date :=convert_gmt_to_server (p_exclusion.plannedstartdate);
        p_updation_record.planned_end_date :=convert_gmt_to_server (p_exclusion.plannedenddate);
        p_updation_record.scheduled_start_date:=convert_gmt_to_server (p_exclusion.scheduledstartdate);
        p_updation_record.scheduled_end_date :=convert_gmt_to_server (p_exclusion.scheduledenddate);
        p_updation_record.actual_end_date :=convert_gmt_to_server (p_exclusion.actualenddate);     --  DATE     DEFAULT fnd_api.g_miss_date,
        p_updation_record.actual_start_date :=convert_gmt_to_server (p_exclusion.actualstartdate);     --  DATE
        p_updation_record.old_calendar_start_date:=convert_gmt_to_server (p_exclusion.exclusion_date); --.plannedstartdate;
        p_updation_record.new_calendar_start_date:=convert_gmt_to_server (p_exclusion.plannedstartdate);
        p_updation_record.new_calendar_end_date:=convert_gmt_to_server (p_exclusion.plannedenddate);

     end if;

        p_updation_record.timezone_id   :=get_task_timezone_id(p_task_id=>p_exclude_task_id);

        p_updation_record.private_flag :=p_exclusion.privateflag  ;        -- jtf_tasks_b.private_flag%TYPE DEFAULT fnd_api.g_miss_char,
        p_updation_record.alarm_on:=p_exclusion.alarmflag;            -- NUMBER   DEFAULT fnd_api.g_miss_num,
        p_updation_record.change_mode:=jtf_task_repeat_appt_pvt.G_ONE;
        p_updation_record.recurrence_rule_id:=p_rec_rule_id;
     	p_updation_record.free_busy_type	:=p_exclusion.free_busy_type;
     	p_updation_record.alarm_start	:=l_alarm_mins;

       l_ovn:=get_ovn(p_task_id=>p_exclude_task_id);

        jtf_task_repeat_appt_pvt.update_repeat_appointment(
        p_api_version            =>1.0,
        p_init_msg_list           =>fnd_api.g_false,
        p_commit                  =>fnd_api.g_false,
        p_object_version_number   =>l_ovn,
        p_updated_field_rec       =>p_updation_record ,
        x_return_status           =>l_return_status,
        x_msg_count               =>l_msg_count,
        x_msg_data                =>l_msg_data
    ) ;


      IF NOT cac_sync_common.is_success (l_return_status)
           THEN-- Failed to update a task

               cac_sync_common.put_message_to_excl_record (
                  p_exclusion_rec=>p_exclusion,
                  p_status => 2,
                  p_user_message => 'JTA_SYNC_UPDATE_TASK_FAIL'
               );
       else
--add collabsuite details
        -- Start Fix for bug #4687069
          -- Location was not getting updated if added a location to an occurence
          -- which made it an exclusion.
          -- Added updated of collab details for exclusions also.

          OPEN  getCollabDetails(p_updation_record.task_id);

             FETCH getCollabDetails INTO l_collab_details;

          -- Update the rows only if there are some information in the CAC_VIEW_COLLAB_DETAILS table
          --otherwise close the cursor.
             IF (getCollabDetails%FOUND)  THEN

              l_location := SUBSTRB(p_exclusion.locations,1,100);

              cac_view_collab_details_pkg.update_row
               (x_collab_id=> l_collab_details.collab_id ,
                x_task_id=> p_updation_record.task_id,
                x_meeting_mode=>l_collab_details.meeting_mode,
                x_meeting_id=>l_collab_details.meeting_id,
                x_meeting_url=>l_collab_details.meeting_url,
                x_join_url=>l_collab_details.join_url,
                x_playback_url=>l_collab_details.playback_url,
                x_download_url=>l_collab_details.download_url,
                x_chat_url=>l_collab_details.chat_url,
                x_is_standalone_location=>l_collab_details.is_standalone_location,
                x_location=>l_location,
                x_dial_in=>p_exclusion.dial_in,
                x_last_update_date=>SYSDATE,
                x_last_updated_by=>jtf_task_utl.updated_by,
                x_last_update_login=>jtf_task_utl.login_id);

               END IF;


              if (getCollabDetails%ISOPEN) then
              CLOSE getCollabDetails;
              end if;

           -- End Fix for bug #4687069




           END IF;
   end   create_updation_record;

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
         --fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
        -- fnd_msg_pub.add;

        -- fnd_message.set_name('JTF', 'JTA_SYNC_INVALID_SYNCID');
        -- fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.IS_THIS_NEW_TASK');
        -- fnd_msg_pub.add;

        -- raise_application_error (-20100,cac_sync_common.get_messages);
         RETURN TRUE;
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
      p_exclusion_tbl         IN   OUT NOCOPY cac_sync_task.exclusion_tbl,
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
              p_exclusion_rec        IN OUT NOCOPY  cac_sync_task.exclusion_rec
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
      l_sync_task_id NUMBER;
      l_task_id   NUMBER;
   BEGIN


      l_sync_task_id:=get_task_id(p_sync_id=>p_sync_id);


    OPEN c_recur_tasks (
          b_recurrence_rule_id => p_recurrence_rule_id,
          b_exclusion_start_date => convert_gmt_to_task(p_exclusion_rec.exclusion_date,l_sync_task_id)
       );
      FETCH c_recur_tasks INTO l_task_id;

      IF c_recur_tasks%NOTFOUND
      THEN
         l_task_id := -9;
      END IF;

      CLOSE c_recur_tasks;

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
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_TASK_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);

      END IF;

      OPEN c_task_sync;
      FETCH c_task_sync INTO l_task_id;

      IF c_task_sync%NOTFOUND
      THEN
          CLOSE c_task_sync;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_NOTFOUND_TASKID');
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_TASK_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
      ELSIF l_task_id IS NULL
      THEN
         CLOSE c_task_sync;

         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_NULL_TASKID');
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_TASK_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
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
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_TASK_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
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
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_TASK_TIMEZONE_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);

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

         fnd_message.set_name('JTF', 'cac_sync_task_OVN_NOTFOUND');
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_OVN');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
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
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_OVN');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
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
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_RESOURCE_DETAILS');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
      END IF;

      CLOSE c_resource;

   END get_resource_details;



   PROCEDURE do_mapping(p_task_id       IN     NUMBER,
                        p_principal_id  IN     NUMBER,
                        p_operation     IN     VARCHAR2,
                        x_task_sync_id  IN OUT NOCOPY  NUMBER
   )
   IS
   BEGIN
      IF (p_operation = g_new)
      THEN
            IF (x_task_sync_id IS NULL)   OR (x_task_sync_id <= 0)
            THEN
               SELECT jta_sync_task_mapping_s.nextval
               INTO x_task_sync_id
               FROM dual;
            END IF;

            cac_sync_task_map_pkg.insert_row (
                p_task_sync_id => x_task_sync_id,
                p_task_id      => p_task_id,
                p_resource_id  => cac_sync_task.g_login_resource_id,
                p_principal_id => p_principal_id
            );
      ELSIF p_operation = g_modify
      THEN
            cac_sync_task_map_pkg.update_row (
                p_task_sync_id => x_task_sync_id,
                p_task_id      => p_task_id,
                p_resource_id  => cac_sync_task.g_login_resource_id,
                p_principal_id => p_principal_id
            );
   /* ELSIF p_operation = G_DELETE
      THEN
        cac_sync_task_map_pkg.delete_row (
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
      p_task_rec     IN       cac_sync_task.task_rec,
      x_alarm_mins   OUT NOCOPY      NUMBER
   )
   IS
      l_alarm_days   NUMBER;
   BEGIN
      IF (p_task_rec.objectcode <> G_TASK)
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
      p_task_rec       IN       cac_sync_task.task_rec,
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
          IF (p_task_rec.objectcode <> G_TASK) --for booking and appointments
            THEN
               x_planned_start  := convert_gmt_to_server(p_task_rec.plannedstartdate);
               x_planned_end    := convert_gmt_to_server(p_task_rec.plannedenddate);
               x_scheduled_start:= convert_gmt_to_server(p_task_rec.scheduledstartdate);
               x_scheduled_end  := convert_gmt_to_server(p_task_rec.scheduledenddate);
               x_actual_start   := convert_gmt_to_server(p_task_rec.actualstartdate);
               x_actual_end     := convert_gmt_to_server(p_task_rec.actualenddate);
            ELSE-- for tasks
               -- for create task don't do timezone conversion, it's untimed
               x_planned_start   := p_task_rec.plannedstartdate;
               x_planned_end     := p_task_rec.plannedenddate;
               x_scheduled_start := p_task_rec.scheduledstartdate;
               x_scheduled_end   := p_task_rec.scheduledenddate;
               x_actual_start    := p_task_rec.actualstartdate;
               x_actual_end      := p_task_rec.actualenddate;
            END IF;

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
      x_task_rec           IN OUT NOCOPY   cac_sync_task.task_rec
   )
   IS
   BEGIN

      -------------------------------------------------------------
      -- Decide new syncAnchor and Convert server to GMT timezone
      x_task_rec.syncanchor := convert_server_to_gmt (p_syncanchor);

     IF p_item_display_type = 3 AND x_task_rec.objectcode = G_APPOINTMENT THEN
       x_task_rec.plannedstartdate := p_planned_start_date;
       x_task_rec.plannedenddate   := p_planned_end_date;
     ELSIF (x_task_rec.objectcode = G_TASK)  then
     --for task we should not do any timezone conversion.
       x_task_rec.plannedstartdate := p_planned_start_date;
       x_task_rec.plannedenddate   := p_planned_end_date;
       x_task_rec.scheduledstartdate := p_scheduled_start_date;
       x_task_rec.scheduledenddate := p_scheduled_end_date;
       x_task_rec.actualstartdate := p_actual_start_date;
       x_task_rec.actualenddate := p_actual_end_date;

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
     SELECT MAX (tasks.calendar_start_date)
       FROM ( select b.calendar_start_date from jtf_tasks_b b
               where b.recurrence_rule_id=p_recurrence_rule_id
               union
              select b.calendar_start_date from jtf_tasks_b b,
              jta_task_exclusions jte where
              jte.recurrence_rule_id=p_recurrence_rule_id
              and jte.task_id=b.task_id) tasks;

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
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_MAX_ENDDATE');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
      END IF;

      CLOSE c_recur_tasks;

      IF l_date IS NULL
      THEN
         fnd_message.set_name('JTF', 'JTA_SYNC_APPL_ERROR');
         fnd_msg_pub.add;

         fnd_message.set_name('JTF', 'JTA_SYNC_NULL_CALENDAR_ENDDATE');
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_MAX_ENDDATE');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
      END IF;

      RETURN l_date;
   END get_max_enddate;

   FUNCTION get_priorityId (p_task_id IN NUMBER)

    RETURN NUMBER
      IS
         CURSOR get_priorityId
         IS
        SELECT task_priority_id
          FROM jtf_tasks_b
         WHERE task_id = p_task_id;

         l_priorityId  Number;
      BEGIN
      l_priorityId:=null;
         OPEN get_priorityId;
         FETCH get_priorityId into l_priorityId;

         IF get_priorityId%NOTFOUND
         THEN
            CLOSE get_priorityId;
         END IF;

         if (get_priorityId%ISOPEN) then
         CLOSE get_priorityId;
         end if;


         RETURN l_priorityId;
   END get_priorityId;

procedure  get_exclusion_data (
   p_recurrence_rule_id IN NUMBER,
   p_syncanchor         IN  DATE,
   p_task_sync_id       IN number,
   p_timezone_id        IN NUMBER,
   p_principal_id       IN Number,
   p_resource_id        IN Number,
   p_resource_type      IN VARCHAR2,
   p_exclusion_data     IN OUT NOCOPY  cac_sync_task.exclusion_tbl
   )
---  RETURN cac_sync_task.exclusion_tbl
   IS

      l_date         DATE;
      l_alarm_date   DATE;
      l_exclusion    cac_sync_task_cursors.c_exclusions%ROWTYPE;
      i          BINARY_INTEGER          := nvl(p_exclusion_data.last,0) ;
   BEGIN

      FOR l_exclusion in cac_sync_task_cursors.c_exclusions(
      p_syncanchor,
      p_recurrence_rule_id,
      p_resource_id,
      p_resource_type)
      LOOP
     i := i + 1;
     --converting the dates to the timezone of the task id.Previous, code was assuming that every data in the schema is in server timezone.
     p_exclusion_data (i).exclusion_date := convert_task_to_gmt(l_exclusion.exclusion_date,p_timezone_id);--convert_server_to_gmt(l_exclusion.ex_date);
     p_exclusion_data (i).syncid := p_task_sync_id;
     p_exclusion_data (i).recordIndex:=i;
     p_exclusion_data (i).task_id:=l_exclusion.task_id;
     p_exclusion_data (i).syncAnchor:=l_exclusion.new_timestamp;
     p_exclusion_data (i).timeZoneId:=l_exclusion.timezone_id;
     p_exclusion_data (i).eventType:=l_exclusion.event; --new
     p_exclusion_data (i).objectCode:=l_exclusion.source_object_type_code;
     p_exclusion_data (i).subject:=l_exclusion.task_name;
     p_exclusion_data (i).description:=l_exclusion.description;
     p_exclusion_data (i).dateSelected:=l_exclusion.date_selected;

     --code starts for bug # 5213476
     IF ((l_exclusion.planned_end_date - l_exclusion.planned_start_date)*24*60 = 1439) THEN
        l_exclusion.planned_end_date:=l_exclusion.planned_start_date;
     END IF;
     --code ends for bug # 5213476

     p_exclusion_data (i).plannedStartDate:=convert_task_to_gmt(l_exclusion.planned_start_date,p_timezone_id);
     p_exclusion_data (i).plannedEndDate:=convert_task_to_gmt(l_exclusion.planned_end_date,p_timezone_id);
     p_exclusion_data (i).scheduledStartDate:=convert_task_to_gmt(l_exclusion.scheduled_start_date,p_timezone_id);
     p_exclusion_data (i).scheduledEndDate:=convert_task_to_gmt(l_exclusion.scheduled_end_date,p_timezone_id);
     p_exclusion_data (i).statusId:=l_exclusion.task_status_id;
     p_exclusion_data (i).priorityId:=l_exclusion.importance_level;
     p_exclusion_data (i).alarmFlag:=l_exclusion.alarm_on;
     --code starts for bug # 5213476
     l_alarm_date:= set_alarm_date (
                     p_task_id => l_exclusion.task_id,
                     p_request_type => G_REQ_APPOINTMENT,
                     p_scheduled_start_date => l_exclusion.scheduled_start_date,
                     p_planned_start_date => l_exclusion.planned_start_date,
                     p_actual_start_date => l_exclusion.actual_start_date,
                     p_alarm_flag => l_exclusion.alarm_on,
                     p_alarm_start => l_exclusion.alarm_start  );
     p_exclusion_data (i).alarmDate:=convert_task_to_gmt(l_alarm_date,p_timezone_id);
     --code ends for bug # 5213476

     p_exclusion_data (i).privateFlag:=l_exclusion.private_flag;
     p_exclusion_data (i).category:= jtf_task_security_pvt.get_category_id(
                           p_task_id => l_exclusion.task_id,
                           p_resource_id => p_resource_id,
                           p_resource_type_code => p_resource_type);

     p_exclusion_data (i).resourceId:=p_resource_id;
     p_exclusion_data (i).resourceType:=p_resource_type;
     p_exclusion_data (i).task_assignment_id:=0;--l_exclusion.task_id;


     p_exclusion_data (i).unit_of_measure:=null;--l_exclusion.occurs_uom;
     p_exclusion_data (i).occurs_every:=null;--l_exclusion.occurs_every;
     p_exclusion_data (i).start_date:=null;--l_exclusion.start_date_active;
     p_exclusion_data (i).end_date:=null;--l_exclusion.end_date_active;
     p_exclusion_data (i).sunday:=null;--l_exclusion.sunday;
     p_exclusion_data (i).monday:=null;--l_exclusion.monday;
     p_exclusion_data (i).tuesday:=null;--l_exclusion.tuesday;
     p_exclusion_data (i).wednesday:=null;--l_exclusion.wednesday;
     p_exclusion_data (i).thursday:=null;--l_exclusion.thursday;
     p_exclusion_data (i).friday:=null;--l_exclusion.friday;
     p_exclusion_data (i).saturday:=null;--l_exclusion.saturday;
     p_exclusion_data (i).date_of_month :=null;--_exclusion.date_of_month;
     p_exclusion_data (i).occurs_which:=null;--l_exclusion.occurs_which;

     p_exclusion_data (i).locations:=l_exclusion.locations;
     p_exclusion_data (i).principal_id:=p_principal_id;
     p_exclusion_data (i).free_busy_type:=l_exclusion.free_busy_type;
     p_exclusion_data (i).dial_in:=get_dial_in_value(l_exclusion.task_id);

      END LOOP;

---  RETURN l_exclusion_data;
   END get_exclusion_data;



   FUNCTION already_selected(p_task_id     IN NUMBER
                            ,p_sync_id     IN NUMBER
                            ,p_task_tbl    IN cac_sync_task.task_tbl)
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
      p_principal_id           IN   NUMBER,
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
      p_locations              IN   VARCHAR2,
      p_free_busy_type         IN   VARCHAR2,
      p_dial_in                IN   VARCHAR2,
      x_task_rec           IN OUT NOCOPY   cac_sync_task.task_rec
   )
   IS
      l_category_name   VARCHAR2(240); -- Fix bug 2540722
      l_status      BOOLEAN;
      l_operation   VARCHAR2(20);
      l_task_status_id number ;
      l_item_display_type NUMBER;
      l_category_id NUMBER;
      l_repeat_start_day  VARCHAR2(15);
      l_planned_end_date  DATE;
      p_occurs_month   NUMBER;
      l_occurs_month   NUMBER;
      l_actual_end_date  DATE;
      l_scheduled_end_date  DATE;
   BEGIN
      l_operation := p_operation;
      x_task_rec.syncid := p_task_sync_id;

      x_task_rec.resultid := 0;
      x_task_rec.objectcode := RTRIM (p_request_type, 'S');
      x_task_rec.free_busy_type:=p_free_busy_type;
      x_task_rec.dial_in :=p_dial_in;

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

--checking if the appointment spans from 00:00:00 to 23:59:00
--if yes change the end date to be equal to start_date. This will take care
--of appoinment created from JTT and OA pages where
--all day appointments are created from 00:00:00 to 23:59:00
--for all-day appointment created from outlook, the start date is
--equal to end date.

      l_planned_end_date := p_planned_end_date;
    if (x_task_rec.objectcode = G_APPOINTMENT) then
      IF ((p_planned_end_date - p_planned_start_date)*24*60 = 1439) then
             l_planned_end_date := p_planned_start_date;
      end if;
    end if;

   l_scheduled_end_date := p_scheduled_end_date;
    if (x_task_rec.objectcode = G_APPOINTMENT) then
      IF ((p_scheduled_end_date - p_scheduled_start_date)*24*60 = 1439) then
             l_scheduled_end_date := p_scheduled_start_date;
      end if;
    end if;

   l_actual_end_date := p_actual_end_date;
    if (x_task_rec.objectcode = G_APPOINTMENT) then
      IF ((p_actual_end_date - p_actual_start_date)*24*60 = 1439) then
             l_actual_end_date := p_actual_start_date;
      end if;
    end if;
       adjust_timezone (
         p_timezone_id          => p_timezone_id,
         p_syncanchor           => p_syncanchor,
         p_planned_start_date   => p_planned_start_date,
         p_planned_end_date     => l_planned_end_date,
         p_scheduled_start_date => p_scheduled_start_date,
         p_scheduled_end_date   => l_scheduled_end_date,
         p_actual_start_date    => p_actual_start_date,
         p_actual_end_date      => l_actual_end_date,
         p_item_display_type    => l_item_display_type,
         x_task_rec             => x_task_rec
      );

      do_mapping (
         p_task_id,
         p_principal_id,
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
      x_task_rec.locations   := p_locations;

      IF p_operation <> G_DELETE
      THEN
          make_prefix (
             p_assignment_status_id    => get_assignment_status_id (p_task_id, p_resource_id),
             p_source_object_type_code => x_task_rec.objectcode,
             p_resource_type           => p_owner_type_code,
             p_resource_id             => cac_sync_task.g_login_resource_id,
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
       --  x_task_rec.start_date := p_start_date_active;
       --  x_task_rec.end_date := get_max_enddate (p_recurrence_rule_id) ;

    --  commneted out   NVL (p_end_date_active,get_max_enddate (p_recurrence_rule_id) );
    --recurences created from the server does not contain the time component of the end date.
    --so pick up max calendar_start_date for the recurrences
    --refer bug 4261252.
       --  x_task_rec.sunday    := p_sunday;
       --  x_task_rec.monday    := p_monday;
       --  x_task_rec.tuesday   := p_tuesday;
       --  x_task_rec.wednesday := p_wednesday;
       --  x_task_rec.thursday  := p_thursday;
       --  x_task_rec.friday    := p_friday;
       --  x_task_rec.saturday  := p_saturday;
     --    x_task_rec.date_of_month := p_date_of_month;
     --    x_task_rec.occurs_which  := p_occurs_which;

/*
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
   */



     IF p_occurs_uom = 'YER' THEN
         p_occurs_month := to_number(to_char(p_start_date_active, 'MM'));
     else
         p_occurs_month:=null;
     END IF;

     CAC_VIEW_UTIL_PVT.ADJUST_RECUR_RULE_FOR_TIMEZONE(
     p_source_tz_id          => p_timezone_id,  --task timezone id,
     p_dest_tz_id            => G_GMT_TIMEZONE_ID,
     p_base_start_datetime   => p_planned_start_date,
     p_base_end_datetime     => l_planned_end_date,
     p_start_date_active     => p_start_date_active,
     p_end_date_active       => get_max_enddate (p_recurrence_rule_id),
     p_occurs_which          => p_occurs_which,
     p_date_of_month         => p_date_of_month,
     p_occurs_month          => p_occurs_month,
     p_sunday                => p_sunday,
     p_monday                => p_monday,
     p_tuesday               => p_tuesday,
     p_wednesday             => p_wednesday,
     p_thursday              => p_thursday,
     p_friday                => p_friday,
     p_saturday              => p_saturday,
     x_start_date_active     => x_task_rec.start_date,
     x_end_date_active       => x_task_rec.end_date,
     x_occurs_which          => x_task_rec.occurs_which,
     x_date_of_month         => x_task_rec.date_of_month,
     x_occurs_month          => l_occurs_month,
     x_sunday                => x_task_rec.sunday,
     x_monday                => x_task_rec.monday,
     x_tuesday               => x_task_rec.tuesday,
     x_wednesday             => x_task_rec.wednesday,
     x_thursday              => x_task_rec.thursday,
     x_friday                => x_task_rec.friday,
     x_saturday              => x_task_rec.saturday);

        --for appointment that repeats once every month or every year, set the day to 'N', refer to bug 4251849
         if (x_task_rec.unit_of_measure='MON' or x_task_rec.unit_of_measure='MTH' or
          x_task_rec.unit_of_measure='YER' or x_task_rec.unit_of_measure='YR') then
     	  x_task_rec.sunday:='N';
     	  x_task_rec.monday:='N';
     	  x_task_rec.tuesday:='N';
     	  x_task_rec.wednesday:='N';
     	  x_task_rec.thursday:='N';
     	  x_task_rec.friday:='N';
     	  x_task_rec.saturday:='N';
     	 end if;




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
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_ASSIGNMENT_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
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
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_ASSIGNMENT_STATUS_ID');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
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
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_OWNER_INFO');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
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
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_ASSIGNMENT_INFO');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
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
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_ACCESS');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
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
         fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_SOURCE_OBJECT_TYPE');
         fnd_msg_pub.add;

         raise_application_error (-20100,cac_sync_common.get_messages);
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
           fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_SYNC_TYPE');
           fnd_msg_pub.add;

           raise_application_error (-20100,cac_sync_common.get_messages);
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

FUNCTION  compare_task_rec(
p_task_rec   IN OUT NOCOPY cac_sync_task.task_rec
)
return boolean
is

CURSOR get_task_info( b_role    VARCHAR2,  b_task_id   NUMBER)

     IS
       SELECT
          t.timezone_id,
		  tl.description,
		  tl.task_name,
                  t.planned_start_date,
                  t.planned_end_date,
                  t.scheduled_start_date,
                  t.scheduled_end_date,
                  t.actual_start_date,
                  t.actual_end_date,
                  t.calendar_end_date,
                  NVL (t.private_flag, 'N') private_flag,
                  rc.occurs_uom,
                  rc.occurs_every,
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
                  rc.recurrence_rule_id,
                  CAC_VIEW_UTIL_PUB.get_locations(t.task_id) locations,
                  ta.free_busy_type free_busy_type,
                  t.alarm_start alarm_start,
                  t.alarm_on alarm_on
             FROM jtf_task_recur_rules rc,
                  jtf_task_statuses_b ts,
                  jtf_task_priorities_b tb,
                  jtf_tasks_tl tl,
                  jtf_task_all_assignments ta,
                  jtf_tasks_b t
            WHERE
               ta.task_id = t.task_id
               and ta.assignee_role= b_role
               AND tl.task_id = t.task_id
               AND ts.task_status_id = t.task_status_id
               AND tl.language = USERENV ('LANG')
               AND rc.recurrence_rule_id (+)= t.recurrence_rule_id
               AND tb.task_priority_id (+) = t.task_priority_id
               and t.task_id=b_task_id
               and nvl(t.deleted_flag,'N')='N';

        task_info get_task_info%rowtype;
        l_task_id jtf_tasks_b.task_id%type;
        l_start_date date;
        l_end_date  DATE;
        l_occurs_which NUMBER;
        l_date_of_month  NUMBER;
        l_occurs_month  number;
        l_sunday VARCHAR2(1);
        l_monday VARCHAR2(1);
        l_tuesday   VARCHAR2(1);
        l_wednesday VARCHAR2(1);
        l_thursday VARCHAR2(1);
        l_friday  VARCHAR2(1);
        l_saturday VARCHAR2(1);
        p_occurs_month  NUMBER;

        l_alarm_start   NUMBER := 0;
BEGIN

   l_task_id:=get_task_id (p_sync_id => p_task_rec.syncid);
        open get_task_info('ASSIGNEE',l_task_id);
         fetch get_task_info into task_info;

          if ( get_task_info%FOUND) then

              if (get_task_info%ISOPEN)  then
                close get_task_info;
               end if;

      IF (task_info.task_name<>p_task_rec.subject) THEN RETURN FALSE; END IF;  --code changed for bug # 5396599

      if (NVL(task_info.description, 'A')<>NVL(p_task_rec.description, 'A')) then return false; end if;  --code changed for bug # 5264362
     if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task_common.compare_task_rec', ' description didnt match ');

      end if;
          if (task_info.private_flag<>p_task_rec.privateflag) then return false;end if;
   --       if (task_info.occurs_which<>p_task_rec.occurs_which) then return false;end if;
     if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task_common.compare_task_rec', ' private flag didnt match ');

      end if;
         if (task_info.locations<>p_task_rec.locations) then return false;end if;
     if (NVL(task_info.locations,'AaBb')<>NVL(p_task_rec.locations,'AaBb')) then return false;end if;

     if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task_common.compare_task_rec', ' location didnt match ');

      end if;

    g_fb_type_changed := false;
    if (task_info.free_busy_type<>p_task_rec.free_busy_type)
    then
        g_fb_type_changed := true;
    end if;

    get_alarm_mins(p_task_rec => p_task_rec ,x_alarm_mins => l_alarm_start);

    if ((NVL(task_info.alarm_on,'N')<>NVL(p_task_rec.alarmFlag,'N')) or
        (NVL(task_info.alarm_start,0) <> NVL(l_alarm_start,0)))
    then
       if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task_common.compare_task_rec', 'alarm didnt match ');
       end if;
       return false;
    end if;

    IF task_info.occurs_uom = 'YER' THEN
         p_occurs_month := to_number(to_char(task_info.start_date_active, 'MM'));
     else
         p_occurs_month:=null;
     END IF;

if (task_info.recurrence_rule_id is not null) then
     CAC_VIEW_UTIL_PVT.ADJUST_RECUR_RULE_FOR_TIMEZONE(
     p_source_tz_id          => task_info.timezone_id,  --task timezone id,
     p_dest_tz_id            => G_GMT_TIMEZONE_ID,
     p_base_start_datetime   => task_info.planned_start_date,
     p_base_end_datetime     => task_info.planned_end_date,
     p_start_date_active     => task_info.start_date_active,
     p_end_date_active       => get_max_enddate (task_info.recurrence_rule_id),
     p_occurs_which          => task_info.occurs_which,
     p_date_of_month         => task_info.date_of_month,
     p_occurs_month          => p_occurs_month,
     p_sunday                => task_info.sunday,
     p_monday                => task_info.monday,
     p_tuesday               => task_info.tuesday,
     p_wednesday             => task_info.wednesday,
     p_thursday              => task_info.thursday,
     p_friday                => task_info.friday,
     p_saturday              => task_info.saturday,
     x_start_date_active     => l_start_date,
     x_end_date_active       => l_end_date,
     x_occurs_which          => l_occurs_which,
     x_date_of_month         => l_date_of_month,
     x_occurs_month          => l_occurs_month,
     x_sunday                => l_sunday,
     x_monday                => l_monday,
     x_tuesday               => l_tuesday,
     x_wednesday             => l_wednesday,
     x_thursday              => l_thursday,
     x_friday                => l_friday,
     x_saturday              => l_saturday);

          if (TO_CHAR(l_start_date, 'DD-MON-YYYY')<>TO_CHAR(p_task_rec.start_date, 'DD-MON-YYYY')) then return false;end if;
     if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task_common.compare_task_rec', ' start date active didnt match ');

      end if;
          if (TO_CHAR(l_end_date, 'DD-MON-YYYY')<>TO_CHAR(p_task_rec.end_date, 'DD-MON-YYYY')) then return false;end if;
     if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task_common.compare_task_rec', ' end date active didnt match ');

      end if;
        /*if (l_sunday<>p_task_rec.sunday) then return false;end if;
          if (l_monday<>p_task_rec.monday) then return false;end if;
          if (l_tuesday<>p_task_rec.tuesday) then return false;end if;
          if (l_wednesday<>p_task_rec.wednesday) then return false;end if;
          if (l_thursday<>p_task_rec.thursday) then return false;end if;
          if (l_friday<>p_task_rec.friday) then return false;end if;
          if (l_saturday<>p_task_rec.saturday) then return false;end if;
          if (l_date_of_month<>p_task_rec.date_of_month) then return false;end if;
*/
 else
          if (convert_task_to_gmt(task_info.planned_start_date,task_info.timezone_id)<>p_task_rec.plannedstartdate) then return false;end if;
           if (convert_task_to_gmt(task_info.planned_end_date,task_info.timezone_id)<>p_task_rec.plannedenddate) then return false;end if;

end if;  --for if (task_info.recurrence_rule_id is not null) then
          end if;-- for if ( get_task_info%FOUND)


          if (get_task_info%ISOPEN)  then
                close get_task_info;
          end if;

         return true;

end  compare_task_rec;



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

  PROCEDURE convert_recur_date_to_server (
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
 /*     x_start_date :=
     TRUNC (
        convert_gmt_to_server (
           TO_DATE (
          l_start_date || ' ' || l_start_time,
          'DD-MM-YYYY HH24:MI:SS'
           )
        )
     );*/ --commenting out as we want to save start date and time and not just date

    x_start_date :=
             convert_gmt_to_server (
                TO_DATE (
               l_start_date || ' ' || l_start_time,
               'DD-MM-YYYY HH24:MI:SS'
                )
             );

      IF  l_end_date IS NOT NULL THEN
      /*  x_end_date :=
        TRUNC (
        convert_gmt_to_server (
           TO_DATE (
          l_end_date || ' ' || l_end_time,
          'DD-MM-YYYY HH24:MI:SS')));
        x_end_date :=convert_gmt_to_server (TO_DATE (l_end_date || ' ' || l_end_time,'DD-MM-YYYY HH24:MI:SS'));
  */
        x_end_date:=convert_gmt_to_server(p_end_date);
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
   END convert_recur_date_to_server;



   PROCEDURE get_all_nonrepeat_tasks (
      p_request_type         IN       VARCHAR2,
      p_syncanchor           IN       DATE,
      p_recordindex          IN       NUMBER,
      p_resource_id          IN       NUMBER,
      p_principal_id         IN       NUMBER,
      p_resource_type        IN       VARCHAR2,
      p_source_object_type   IN       VARCHAR2,
      p_get_data             IN       BOOLEAN,
      x_totalnew             IN OUT NOCOPY   NUMBER,
      x_totalmodified        IN OUT NOCOPY   NUMBER,
      -- x_totaldeleted       IN OUT NOCOPY NUMBER,
      x_data                 IN OUT NOCOPY   cac_sync_task.task_tbl
      --p_new_syncanchor       IN       DATE
   )
   IS
      x_task_rec   cac_sync_task.task_rec;
      i            INTEGER := p_recordindex;
      l_invalid    BOOLEAN;
      l_end_date   DATE;
   BEGIN
      FOR rec_modify_nonrepeat IN cac_sync_task_cursors.c_modify_non_repeat_task (
                   p_syncanchor,
                   p_resource_id,
                   p_principal_id,
                   p_resource_type,
                   p_source_object_type
                )
      LOOP

     if (rec_modify_nonrepeat.calendar_end_date is not null) then
      l_end_date :=rec_modify_nonrepeat.calendar_end_date;
     elsif (rec_modify_nonrepeat.planned_end_date is not null) then
      l_end_date :=rec_modify_nonrepeat.planned_end_date;
     elsif (rec_modify_nonrepeat.scheduled_end_date is not null) then
      l_end_date :=rec_modify_nonrepeat.scheduled_end_date;
      elsif (rec_modify_nonrepeat.actual_end_date is not null) then
      l_end_date :=rec_modify_nonrepeat.actual_end_date;
     end if;

         --check span days and skip add_task
         check_span_days (
            p_source_object_type_code => rec_modify_nonrepeat.source_object_type_code,
            p_calendar_start_date     => rec_modify_nonrepeat.calendar_start_date,
            p_calendar_end_date       => l_end_date,
            p_task_id                 => rec_modify_nonrepeat.task_id,
            p_entity                  => rec_modify_nonrepeat.entity,
            x_status                  => l_invalid
         );

         IF NOT (l_invalid OR already_selected(p_task_id => rec_modify_nonrepeat.task_id, p_task_tbl => x_data))
         THEN
             IF p_get_data
             THEN
                 add_task (
                    p_request_type         => p_request_type,
                    p_resource_id          => p_resource_id,
                    p_principal_id         => p_principal_id,
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
                    p_locations            => rec_modify_nonrepeat.locations,
                    p_free_busy_type       => rec_modify_nonrepeat.free_busy_type,
                    p_dial_in              => get_dial_in_value(rec_modify_nonrepeat.task_id),
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

      FOR rec_new_nonrepeat IN cac_sync_task_cursors.c_new_non_repeat_task (
                                    p_syncanchor,
                                    p_resource_id,
                                    p_principal_id,
                                    p_resource_type,
                                    p_source_object_type
                               )
      LOOP
     if (rec_new_nonrepeat.calendar_end_date is not null) then
      l_end_date :=rec_new_nonrepeat.calendar_end_date;
     elsif (rec_new_nonrepeat.planned_end_date is not null) then
      l_end_date :=rec_new_nonrepeat.planned_end_date;
     elsif (rec_new_nonrepeat.scheduled_end_date is not null) then
      l_end_date :=rec_new_nonrepeat.scheduled_end_date;
      elsif (rec_new_nonrepeat.actual_end_date is not null) then
      l_end_date :=rec_new_nonrepeat.actual_end_date;
     end if;
         --check span days and skip add_task
         check_span_days (
            p_source_object_type_code => rec_new_nonrepeat.source_object_type_code,
            p_calendar_start_date     => rec_new_nonrepeat.calendar_start_date,
            p_calendar_end_date       => l_end_date,
            p_task_id                 => rec_new_nonrepeat.task_id,
            p_entity                  => rec_new_nonrepeat.entity,
            x_status                  => l_invalid
         );

         IF NOT (l_invalid OR already_selected(p_task_id => rec_new_nonrepeat.task_id, p_task_tbl => x_data))
         THEN
             IF p_get_data
             THEN
                 add_task (
                    p_request_type   => p_request_type,
                    p_resource_id    => p_resource_id,
                    p_principal_id   => p_principal_id,
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
                    p_locations    => rec_new_nonrepeat.locations,
                    p_free_busy_type=>rec_new_nonrepeat.free_busy_type,
                    p_dial_in=>get_dial_in_value(rec_new_nonrepeat.task_id),
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
      p_principal_id         IN       NUMBER,
      p_resource_type        IN       VARCHAR2,
      p_source_object_type   IN       VARCHAR2,
      p_get_data             IN       BOOLEAN,
      x_totaldeleted         IN OUT NOCOPY   NUMBER,
      x_data                 IN OUT NOCOPY   cac_sync_task.task_tbl
   )
   IS
      i   INTEGER := nvl(x_data.last,0);
   BEGIN
      FOR rec_delete IN cac_sync_task_cursors.c_delete_task (
                            p_syncanchor,
                            p_resource_id,
                            p_principal_id,
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

                 cac_sync_task_map_pkg.delete_row (
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

      FOR rec_delete IN cac_sync_task_cursors.c_delete_assignee_reject (
                            p_syncanchor,
                            p_resource_id,
                            p_principal_id,
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

		 /* Commented this for bug#5191856 bcos for deleted appointments, records are not deleted
		     from jtf_task_all_assignments table and the user has the option of Accepting the declined
		     Appointment. */
                 /*cac_sync_task_map_pkg.delete_row (
                    p_task_sync_id => rec_delete.task_sync_id
                 );*/

                 x_data(i).syncanchor := convert_server_to_gmt (SYSDATE);
             ELSE -- For get_count, store the sync_id selected so as to avoid the duplicate
                 i := i + 1;
                 x_data (i).syncid := rec_delete.task_sync_id;
             END IF;

             x_totaldeleted := x_totaldeleted + 1;
          END IF;
      END LOOP;

      FOR rec_delete IN cac_sync_task_cursors.c_delete_assignment (
                         p_syncanchor,
                         p_resource_id,
                         p_resource_type,
                         p_principal_id,
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

                 cac_sync_task_map_pkg.delete_row (
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

      FOR rec_delete IN cac_sync_task_cursors.c_delete_rejected_tasks (
                         p_syncanchor,
                         p_resource_id,
                         p_resource_type,
                         p_principal_id,
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

                 cac_sync_task_map_pkg.delete_row (
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

      FOR rec_delete IN cac_sync_task_cursors.c_delete_unsubscribed(
                         p_resource_id,
                         p_resource_type,
                         p_principal_id,
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

                 cac_sync_task_map_pkg.delete_row (
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
      p_principal_id         IN       NUMBER,
      p_resource_type        IN       VARCHAR2,
      p_source_object_type   IN       VARCHAR2,
      p_get_data             IN       BOOLEAN,
      x_totalnew             IN OUT NOCOPY   NUMBER,
      x_totalmodified        IN OUT NOCOPY   NUMBER,
      -- x_totaldeleted       IN OUT NOCOPY NUMBER,
      x_data                 IN OUT NOCOPY   cac_sync_task.task_tbl,
      x_exclusion_data       IN OUT NOCOPY   cac_sync_task.exclusion_tbl
      --p_new_syncanchor       IN       DATE
   )
   IS
      i            INTEGER       :=  nvl(x_data.last,0);
      x_task_rec   cac_sync_task.task_rec;
      l_invalid    BOOLEAN;


   BEGIN



      FOR rec_modify_repeat IN cac_sync_task_cursors.c_modify_repeating_task (
                                p_syncanchor,
                                p_resource_id,
                                p_principal_id,
                                p_resource_type,
                                p_source_object_type
                             )
      LOOP
         --check span days and skip add_task

         check_span_days (
            p_source_object_type_code => rec_modify_repeat.source_object_type_code,
            p_calendar_start_date     => rec_modify_repeat.calendar_start_date,
            p_calendar_end_date       => rec_modify_repeat.calendar_end_date,
            p_task_id                 => rec_modify_repeat.task_id,
            p_entity                  => rec_modify_repeat.entity,
            x_status                  => l_invalid
         );

           IF (l_invalid AND rec_modify_repeat.entity = G_APPOINTMENT)
	    THEN
             IF p_get_data
             THEN
                 i := i + 1;
                 x_data(i).syncid     := rec_modify_repeat.task_sync_id;
                 x_data(i).recordindex:= i;
                 x_data(i).eventtype  := g_delete;
                 x_data(i).resultid   := 0;

                 cac_sync_task_map_pkg.delete_row (
                    p_task_sync_id => rec_modify_repeat.task_sync_id
                 );

                 x_data(i).syncanchor := convert_server_to_gmt (SYSDATE);
             ELSE -- For get_count, store the sync_id selected so as to avoid the duplicate
                 i := i + 1;
                 x_data (i).syncid := rec_modify_repeat.task_sync_id;
             END IF;

             x_totalmodified := x_totalmodified + 1;

	  END IF;


         IF NOT (l_invalid OR already_selected(p_task_id => rec_modify_repeat.task_id, p_task_tbl => x_data))
         THEN


             IF p_get_data
             THEN

                 add_task (
                    p_request_type => p_request_type,
                    p_resource_id => p_resource_id,
                    p_principal_id => p_principal_id,
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
                    p_locations    => rec_modify_repeat.locations,
                    p_free_busy_type=>rec_modify_repeat.free_busy_type,
                    p_dial_in =>get_dial_in_value(rec_modify_repeat.task_id),
                    x_task_rec => x_task_rec

                    --p_get_data => p_get_data
                 );
                 i := i + 1;
                 x_data (i) := x_task_rec;


                 get_exclusion_data (
                  p_recurrence_rule_id =>rec_modify_repeat.recurrence_rule_id,
                  p_syncanchor         =>p_syncanchor,
                  p_task_sync_id       =>x_task_rec.syncid,
                  p_timezone_id        =>rec_modify_repeat.timezone_id,
                  p_exclusion_data     =>x_exclusion_data ,
                  p_resource_id=>p_resource_id,
                  p_resource_type=>p_resource_type,
                  p_principal_id=>p_principal_id);

          ELSE -- For get_count, store the sync_id selected so as to avoid the duplicate
                 i := i + 1;
                 x_data (i).task_id := rec_modify_repeat.task_id;

             END IF; -- p_get_data

             x_totalmodified := x_totalmodified + 1;
         END IF; -- l_invalid

      END LOOP;

      FOR rec_new_repeat IN cac_sync_task_cursors.c_new_repeating_task (
                                  p_syncanchor,
                                  p_resource_id,
                                  p_principal_id,
                                  p_resource_type,
                                  p_source_object_type
                          )
      LOOP
         --check span days and skip add_task

         check_span_days (
            p_source_object_type_code => rec_new_repeat.source_object_type_code,
            p_calendar_start_date     => rec_new_repeat.calendar_start_date,
            p_calendar_end_date       => rec_new_repeat.calendar_end_date,
            p_task_id                 => rec_new_repeat.task_id,
            p_entity                  => rec_new_repeat.entity,
            x_status                  => l_invalid
         );

         IF NOT (l_invalid OR already_selected(p_task_id => rec_new_repeat.task_id, p_task_tbl => x_data))
         THEN

             IF p_get_data
             THEN

                 add_task (
                    p_request_type => p_request_type,
                    p_resource_id => p_resource_id,
                    p_principal_id => p_principal_id,
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
                    p_locations    => rec_new_repeat.locations,
                    p_free_busy_type=>rec_new_repeat.free_busy_type,
                    p_dial_in => get_dial_in_value(rec_new_repeat.task_id),
                    x_task_rec => x_task_rec
                 );

                 i := i + 1;
                 x_data (i) := x_task_rec;

                get_exclusion_data (
                  p_recurrence_rule_id =>rec_new_repeat.recurrence_rule_id,
                  p_syncanchor         =>p_syncanchor,
                  p_task_sync_id       =>x_task_rec.syncid,
                  p_timezone_id        =>rec_new_repeat.timezone_id,
                  p_exclusion_data     =>x_exclusion_data ,
                  p_resource_id=>p_resource_id,
                  p_resource_type=>p_resource_type,
                  p_principal_id=>p_principal_id);

            ELSE -- For get_count, store the sync_id selected so as to avoid the duplicate
                 i := i + 1;
                 x_data (i).task_id := rec_new_repeat.task_id;

             END IF; -- p_get_data

             x_totalnew := x_totalnew + 1;


         END IF; -- l_invalid
      END LOOP;

   END get_all_repeat_tasks;


  FUNCTION get_collab_id
  RETURN NUMBER
  IS
  l_key NUMBER;
  BEGIN
  	SELECT cac_view_collab_details_s.nextval INTO l_key FROM DUAL;
	RETURN l_key;
  END get_collab_id;


   PROCEDURE create_new_data (
      p_task_rec        IN OUT NOCOPY   cac_sync_task.task_rec,
      p_mapping_type    IN       VARCHAR2,
      p_exclusion_tbl   IN OUT NOCOPY      cac_sync_task.exclusion_tbl,
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
      p_occurs_month        NUMBER;
      l_occurs_number       NUMBER;
      l_rowid	            ROWID;
      l_booking_rec         cac_bookings_pub.booking_type;
      l_object_version_number  NUMBER;
      l_temps               NUMBER;
      l_repeat_start_day    VARCHAR2(15);
      l_G_TASK_TIMEZONE_ID  NUMBER;

       l_sunday VARCHAR2(1);
       l_monday VARCHAR2(1);
       l_tuesday VARCHAR2(1);
       l_wednesday VARCHAR2(1);
       l_thursday VARCHAR2(1);
       l_friday VARCHAR2(1);
       l_saturday VARCHAR2(1);
       l_date_of_month NUMBER;
       l_occurs_which NUMBER;
       l_mapped   Boolean:=false;
      --cursor to check that no duplicate booking is created on the server by the client
      cursor doesBookingExists(b_task_name VARCHAR2,b_cal_start_date DATE,
                               b_cal_end_date  DATE,b_owner_type_code VARCHAR2,
                               b_owner_id NUMBER)
      is
       select b.object_version_number,b.task_id from jtf_tasks_b b,jtf_tasks_tl t
         where b.entity in ('BOOKING','APPOINTMENT')
         and b.source_object_type_code='EXTERNAL APPOINTMENT'
         and t.task_id=b.task_id
         and t.language=userenv('LANG')
         and nvl(b.deleted_flag,'N')='N'
         and t.task_name=b_task_name
         and b.calendar_start_date =b_cal_start_date
         and b.calendar_end_date=b_cal_end_date
         and b.owner_type_code=b_owner_type_code
         and b.owner_id=b_owner_id;
        l_source_object_type_code  jtf_tasks_b.source_object_type_code%type;


         cursor syncIDExists(b_principal_id NUMBER,b_task_id NUMBER,b_resource_id NUMBER)
         is
          select 1 from jta_sync_task_mapping where
           principal_id=b_principal_id
           and task_id=b_task_id
           and resource_id=b_resource_id;

     CURSOR getCollabDetails(b_task_id  NUMBER) IS
      SELECT COLLAB_ID, MEETING_MODE,MEETING_ID,MEETING_URL,JOIN_URL ,
         PLAYBACK_URL ,DOWNLOAD_URL ,CHAT_URL ,IS_STANDALONE_LOCATION,DIAL_IN
        FROM  CAC_VIEW_COLLAB_DETAILS_VL
        WHERE task_id=b_task_id;
      l_collab_details         getCollabDetails%ROWTYPE;

        Dates  VARCHAR2(4000);
        l_location      CAC_VIEW_COLLAB_DETAILS_TL.LOCATION%type:=substrb(p_task_rec.locations,1,100);


   BEGIN
      fnd_msg_pub.initialize;

      get_alarm_mins (p_task_rec, x_alarm_mins => l_alarm_mins);



      --------------------------------------------
      -- Convert GMT to Server timezone
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



      l_category_id := cac_sync_task_category.get_category_id (
                           p_category_name => p_task_rec.category,
                           p_profile_id => cac_sync_task_category.get_profile_id (p_resource_id)
                       );


     l_subject := get_subject( p_subject => p_task_rec.subject
                             , p_type => 'ORACLE');
     l_source_object_type_code:= find_source_object_type_code(p_task_rec.objectcode);

     IF (l_source_object_type_code=G_APPOINTMENT) then --p_task_rec.objectcode = G_APPOINTMENT THEN

--check if the appoitment is all day in the client. If yes then convert the dates
        if (l_planned_start=l_planned_end) then

        l_planned_end:=l_planned_start +1 -1/(60*24)  ;

        end if;


        jta_cal_appointment_pvt.create_appointment (
              p_task_name               => l_subject,
              p_task_type_id            => get_default_task_type,
              p_description             => p_task_rec.description,
              p_task_priority_id        => p_task_rec.priorityid,
              p_owner_type_code         => p_resource_type,
              p_owner_id                => p_resource_id,
              p_planned_start_date      => l_planned_start,
              p_planned_end_date        => l_planned_end,
              p_timezone_id             => G_SERVER_TIMEZONE_ID,  --changed from g_client_timezone_id as all the value must be stored at server timezone
              p_private_flag            => p_task_rec.privateFlag,
              p_alarm_start             => l_alarm_mins,
              p_alarm_on                => p_task_rec.alarmflag,
              p_category_id             => l_category_id,
	          p_free_busy_type          => p_task_rec.free_busy_type,
              x_return_status           => l_return_status,
              x_task_id                 => l_task_id
        );

         cac_view_collab_details_pkg.insert_row (
                  x_rowid => l_rowid,
                  x_collab_id => get_collab_id,
                  x_task_id => l_task_id,
                  x_meeting_mode => 'LIVE',
                  x_meeting_id => null,
                  x_meeting_url => null,
                  x_join_url => null,
                  x_playback_url => null,
                  x_download_url => null,
                  x_chat_url => null,
                  x_is_standalone_location => 'Y',
                  x_location => l_location,-- previous it was p_task_rec.locations,
                  x_dial_in => p_task_rec.dial_in,
                  x_creation_date => SYSDATE,
                  x_created_by => jtf_task_utl.created_by,
                  x_last_update_date => SYSDATE,
                  x_last_updated_by => jtf_task_utl.updated_by,
                  x_last_update_login => jtf_task_utl.login_id
        );

     ELSIF (l_source_object_type_code = G_TASK) THEN

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
              p_timezone_id => G_SERVER_TIMEZONE_ID,--changed from g_client_timezone_id, as everything should be inserted in server timezone
              p_date_selected => NULL, -- Fix Bug 2467021: For creation, pass NULL
              p_alarm_start => l_alarm_mins,
              p_alarm_start_uom => 'MIN',
              p_alarm_interval_uom => 'MIN',
              p_alarm_on => p_task_rec.alarmflag,
              p_private_flag => p_task_rec.privateFlag,
              p_category_id => l_category_id,
              x_return_status => l_return_status,
              x_msg_count => l_msg_count,
              x_msg_data => l_msg_data,
              x_task_id => l_task_id
        );
     ELSE
----check booking for all day appointment. Added the code for all  day booking
       if (l_planned_start=l_planned_end) then

        l_planned_end:=l_planned_start +1 -1/(60*24)  ;

        end if;


    --Check in cac schema if the booking is already present

     open doesBookingExists(l_subject,l_booking_rec.start_date,l_booking_rec.end_date,p_resource_type,p_resource_id);

        fetch doesBookingExists into l_object_version_number,l_task_id;

     if (doesBookingExists%FOUND)  THEN

          CLOSE doesBookingExists;


        cac_view_appt_pvt.update_external_appointment (
              p_object_version_number   =>l_object_version_number,
              p_task_id                 =>l_task_id,
              p_task_name               => l_subject,
              p_task_type_id            => get_default_task_type,
              p_description             => p_task_rec.description,
              p_task_priority_id        => p_task_rec.priorityid,
              p_planned_start_date      => l_planned_start,
              p_planned_end_date        => l_planned_end,
              p_timezone_id             => G_SERVER_TIMEZONE_ID,  --changed from g_client_timezone_id as all the value must be stored at server timezone
              p_private_flag            => p_task_rec.privateFlag,
              p_alarm_start             => l_alarm_mins,
              p_alarm_on                => p_task_rec.alarmflag,
              p_category_id             => l_category_id,
	          p_free_busy_type          => p_task_rec.free_busy_type,
	          p_change_mode             => jtf_task_repeat_appt_pvt.g_all,
              x_return_status           => l_return_status
        );

          OPEN  getCollabDetails(l_task_id);

             FETCH getCollabDetails INTO l_collab_details;

          -- Update the rows only if there are some information in the CAC_VIEW_COLLAB_DETAILS table
          --otherwise close the cursor.
             IF (getCollabDetails%FOUND)  THEN

              l_location := SUBSTRB(p_task_rec.locations,1,100);

              cac_view_collab_details_pkg.update_row
               (x_collab_id=> l_collab_details.collab_id ,
                x_task_id=> l_task_id,
                x_meeting_mode=>l_collab_details.meeting_mode,
                x_meeting_id=>l_collab_details.meeting_id,
                x_meeting_url=>l_collab_details.meeting_url,
                x_join_url=>l_collab_details.join_url,
                x_playback_url=>l_collab_details.playback_url,
                x_download_url=>l_collab_details.download_url,
                x_chat_url=>l_collab_details.chat_url,
                x_is_standalone_location=>l_collab_details.is_standalone_location,
                x_location=>l_location,
                x_dial_in=>p_task_rec.dial_in,
                x_last_update_date=>SYSDATE,
                x_last_updated_by=>jtf_task_utl.updated_by,
                x_last_update_login=>jtf_task_utl.login_id);

               END IF;


              IF (getCollabDetails%ISOPEN) THEN
              CLOSE getCollabDetails;
              END IF;


	   --checking if the update status is false and if yes, write to message stack.

           if (cac_sync_common.is_success (l_return_status)=false) then

               cac_sync_common.put_messages_to_result (
                  p_task_rec,
                  p_status => 2,
                  p_user_message => 'JTA_SYNC_UPDATE_TASK_FAIL'
                  );
            END IF;  -- of (cac_sync_common.is_success (l_return_status))


     ELSE --  for (doesBookingExists%FOUND)

        cac_view_appt_pvt.create_external_appointment (
              p_task_name               => l_subject,
              p_task_type_id            => get_default_task_type,
              p_description             => p_task_rec.description,
              p_task_priority_id        => p_task_rec.priorityid,
              p_owner_type_code         => p_resource_type,
              p_owner_id                => p_resource_id,
              p_planned_start_date      => l_planned_start,
              p_planned_end_date        => l_planned_end,
              p_timezone_id             => G_SERVER_TIMEZONE_ID,  --changed from g_client_timezone_id as all the value must be stored at server timezone
              p_private_flag            => p_task_rec.privateFlag,
              p_alarm_start             => l_alarm_mins,
              p_alarm_on                => p_task_rec.alarmflag,
              p_category_id             => l_category_id,
	          p_free_busy_type          => p_task_rec.free_busy_type,
	          p_source_object_type_code => l_source_object_type_code,
              x_return_status           => l_return_status,
              x_task_id                 => l_task_id
        );

         cac_view_collab_details_pkg.insert_row (
                  x_rowid => l_rowid,
                  x_collab_id => get_collab_id,
                  x_task_id => l_task_id,
                  x_meeting_mode => 'LIVE',
                  x_meeting_id => NULL,
                  x_meeting_url => NULL,
                  x_join_url => NULL,
                  x_playback_url => NULL,
                  x_download_url => NULL,
                  x_chat_url => NULL,
                  x_is_standalone_location => 'Y',
                  x_location => l_location,-- previous it was p_task_rec.locations,
                  x_dial_in => p_task_rec.dial_in,
                  x_creation_date => SYSDATE,
                  x_created_by => jtf_task_utl.created_by,
                  x_last_update_date => SYSDATE,
                  x_last_updated_by => jtf_task_utl.updated_by,
                  x_last_update_login => jtf_task_utl.login_id
        );


     END IF; --  for (doesBookingExists%FOUND)

      IF (doesBookingExists%ISOPEN) THEN
         CLOSE doesBookingExists;
      END IF;

    END IF;  -- for p_task_rec.objectcode = G_APPOINTMENT

      IF cac_sync_common.is_success (l_return_status)
      THEN
           --------------------------------------------
           -- Check whether it has a repeating information
           -- If it has, then create a recurrence
           --------------------------------------------
           IF (   l_source_object_type_code <> G_TASK -- = G_APPOINTMENT
              AND p_task_rec.unit_of_measure <> fnd_api.g_miss_char
              AND p_task_rec.unit_of_measure IS NOT NULL)
           --   include open end dates also
           --   AND p_task_rec.end_date IS NOT NULL)
           THEN
              -- Convert repeating start and end date
              --   to client timezone

             l_G_TASK_TIMEZONE_ID:=get_task_timezone_id(p_task_id=>l_task_id);



            IF p_task_rec.unit_of_measure = 'YER' THEN
                p_occurs_month := to_number(to_char(p_task_rec.start_date, 'MM'));
                else
                p_occurs_month:=null;
              END IF;



              CAC_VIEW_UTIL_PVT.ADJUST_RECUR_RULE_FOR_TIMEZONE(
              p_source_tz_id => G_GMT_TIMEZONE_ID,
              p_dest_tz_id=> l_G_TASK_TIMEZONE_ID,
              p_base_start_datetime=>p_task_rec.plannedstartdate,
              p_base_end_datetime  =>p_task_rec.plannedenddate,
              p_start_date_active  =>p_task_rec.start_date,
              p_end_date_active    =>p_task_rec.end_date,
              p_occurs_which       =>p_task_rec.occurs_which,
              p_date_of_month      =>p_task_rec.date_of_month,
              p_occurs_month       =>p_occurs_month,
              p_sunday             =>p_task_rec.sunday,
              p_monday             =>p_task_rec.monday,
              p_tuesday            =>p_task_rec.tuesday,
              p_wednesday          =>p_task_rec.wednesday,
              p_thursday           =>p_task_rec.thursday,
              p_friday             =>p_task_rec.friday,
              p_saturday           =>p_task_rec.saturday,
              x_start_date_active  =>l_repeat_start_date,
              x_end_date_active    =>l_repeat_end_date   ,
              x_occurs_which       =>l_occurs_which,
              x_date_of_month      =>l_date_of_month,
              x_occurs_month       =>l_occurs_month,
              x_sunday             =>l_sunday,
              x_monday             =>l_monday,
              x_tuesday            =>l_tuesday,
              x_wednesday          =>l_wednesday,
              x_thursday           =>l_thursday,
              x_friday             =>l_friday,
              x_saturday           =>l_saturday);


              IF (l_repeat_end_date IS NULL)
              THEN
                l_occurs_number := G_USER_DEFAULT_REPEAT_COUNT;
              END IF;


                 jtf_task_recurrences_pvt.create_task_recurrence (
                     p_api_version => 1,
                     p_commit => fnd_api.g_false,
                     p_task_id => l_task_id,
                     p_occurs_which => l_occurs_which,
                     p_template_flag => 'N',
                     p_date_of_month => l_date_of_month,
                     p_occurs_uom => p_task_rec.unit_of_measure,
                     p_occurs_every => p_task_rec.occurs_every,
                     p_occurs_number => l_occurs_number,
                     p_occurs_month => l_occurs_month,
                     p_start_date_active => l_repeat_start_date,
                     p_end_date_active => l_repeat_end_date,
                     p_sunday => l_sunday,
                     p_monday => l_monday,
                     p_tuesday => l_tuesday,
                     p_wednesday => l_wednesday,
                     p_thursday => l_thursday,
                     p_friday => l_friday,
                     p_saturday =>l_saturday,
                     x_recurrence_rule_id => l_recurrence_rule_id,
                     x_task_rec => l_task_rec,
                     x_output_dates_counter => l_reccurences_generated,
                     x_return_status => l_return_status,
                     x_msg_count => l_msg_count,
                     x_msg_data => l_msg_data
                 );



              IF cac_sync_common.is_success (l_return_status)
              THEN
                    -------------------------------------------------------
                    -- Recurrences are successfully created.
                    -------------------------------------------------------

               do_mapping (
                p_task_id      => l_task_id,
                p_operation    => g_new,
                x_task_sync_id => p_task_rec.syncid,
                p_principal_id => p_task_rec.principal_id
                );

               l_mapped:=true;
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
                        cac_sync_common.put_messages_to_result (
                           p_task_rec,
                           p_status => g_sync_success,
                           p_user_message => 'JTA_SYNC_SUCCESS'
                        );
                    END IF;
              ELSE
                    -------------------------------------------------------
                    -- Failed to create a task recurrence
                    -------------------------------------------------------
                    cac_sync_common.put_messages_to_result (
                       p_task_rec,
                       p_status => 2,
                       p_user_message => 'JTA_RECURRENCE_CREATION_FAIL'
                    );
              END IF;

           ELSE
              --------------------------------------------------------------------
              -- This is a Single Task and succeeded to create a single task
              --------------------------------------------------------------------
              cac_sync_common.put_messages_to_result (
                   p_task_rec,
                   p_status => g_sync_success,
                   p_user_message => 'JTA_SYNC_SUCCESS'
              );
           END IF;   -- end-check if this is repeating Task


 if (not (l_mapped))  then
      --check if the mapping is created or not. if it not created then only create new mapping.

       do_mapping (
                p_task_id      => l_task_id,
                p_operation    => g_new,
                x_task_sync_id => p_task_rec.syncid,
                p_principal_id => p_task_rec.principal_id
           );
end if;

           p_task_rec.syncanchor := convert_server_to_gmt (SYSDATE);

       ELSE-- failed
           ---------------------------------------------
           -- Failed to create a task
           ---------------------------------------------

           cac_sync_common.put_messages_to_result (
              p_task_rec,
              p_status => 2,
              p_user_message => 'cac_sync_task_CREATION_FAILED'
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



FUNCTION find_source_object_type_code(objectcode IN VARCHAR2)

return VARCHAR2

 is

 begin

 if (objectcode='APPOINTMENT') then
    return 'APPOINTMENT';
 elsif (objectcode='TASK') then
    return  'TASK' ; else
    return  'EXTERNAL APPOINTMENT';
 end if;

 end find_source_object_type_code;



   PROCEDURE  overwrite_task_record (
        p_task_rec         IN OUT NOCOPY cac_sync_task.task_rec,
        p_resource_id     IN       NUMBER,
        p_resource_type   IN       VARCHAR2)

        is
   CURSOR get_task_info( b_role    VARCHAR2,  b_task_id   NUMBER)

     IS
       SELECT     tl.task_name,t.task_id,
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
                  t.timezone_id timezone_id,
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
                  ta.free_busy_type free_busy_type
             FROM jtf_task_recur_rules rc,
                  jtf_task_statuses_b ts,
                  jtf_task_priorities_b tb,
                  jtf_tasks_tl tl,
                  jtf_task_all_assignments ta,
                  jtf_tasks_b t
            WHERE

               ta.task_id = t.task_id
               and ta.assignee_role= b_role
               AND tl.task_id = t.task_id
               AND ts.task_status_id = t.task_status_id
               AND tl.language = USERENV ('LANG')
               AND rc.recurrence_rule_id (+)= t.recurrence_rule_id
               AND tb.task_priority_id (+) = t.task_priority_id
               and t.task_id=b_task_id
               and nvl(t.deleted_flag,'N')='N';

        task_info get_task_info%rowtype;
        l_alarm_mins  NUMBER;
        l_alarmdate   DATE;
        l_task_id     NUMBER;
        p_occurs_month NUMBER;
        l_occurs_month NUMBER;

       BEGIN

         l_task_id := get_task_id (p_sync_id => p_task_rec.syncid);
         open get_task_info('ASSIGNEE',l_task_id);
         fetch get_task_info into task_info;

   /*   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_sync_task_common.create_new_data', 'point 1  p_task_rec.syncid '||p_task_rec.syncid);
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_sync_task_common.create_new_data', 'point 1   l_task_id '|| l_task_id);
      end if;*/

          if ( get_task_info%FOUND) then

              if (get_task_info%ISOPEN)  then
                close get_task_info;
               end if;




     IF task_info.occurs_uom = 'YER' THEN
         p_occurs_month := to_number(to_char(task_info.start_date_active, 'MM'));
     else
         p_occurs_month:=null;
     END IF;

     IF (task_info.recurrence_rule_id is not null) THEN

	     CAC_VIEW_UTIL_PVT.ADJUST_RECUR_RULE_FOR_TIMEZONE(
	     p_source_tz_id          => task_info.timezone_id,  --task timezone id,
	     p_dest_tz_id            => G_GMT_TIMEZONE_ID,
	     p_base_start_datetime   => task_info.planned_start_date,
	     p_base_end_datetime     => task_info.planned_end_date,
	     p_start_date_active     => task_info.start_date_active,
	     p_end_date_active       => get_max_enddate (task_info.recurrence_rule_id),
	     p_occurs_which          => task_info.occurs_which,
	     p_date_of_month         => task_info.date_of_month,
	     p_occurs_month          => p_occurs_month,
	     p_sunday                => task_info.sunday,
	     p_monday                => task_info.monday,
	     p_tuesday               => task_info.tuesday,
	     p_wednesday             => task_info.wednesday,
	     p_thursday              => task_info.thursday,
	     p_friday                => task_info.friday,
	     p_saturday              => task_info.saturday,
	     x_start_date_active     => p_task_rec.start_date,
	     x_end_date_active       => p_task_rec.end_date,
	     x_occurs_which          => p_task_rec.occurs_which,
	     x_date_of_month         => p_task_rec.date_of_month,
	     x_occurs_month          => l_occurs_month,
	     x_sunday                => p_task_rec.sunday,
	     x_monday                => p_task_rec.monday,
	     x_tuesday               => p_task_rec.tuesday,
	     x_wednesday             => p_task_rec.wednesday,
	     x_thursday              => p_task_rec.thursday,
	     x_friday                => p_task_rec.friday,
	     x_saturday              => p_task_rec.saturday);
     END IF;

        --for appointment that repeats once every month or every year, set the day to 'N', refer to bug 4251849
         if (p_task_rec.unit_of_measure='MON' or p_task_rec.unit_of_measure='MTH' or
          p_task_rec.unit_of_measure='YER' or p_task_rec.unit_of_measure='YR') then
     	  p_task_rec.sunday:='N';
     	  p_task_rec.monday:='N';
     	  p_task_rec.tuesday:='N';
     	  p_task_rec.wednesday:='N';
     	  p_task_rec.thursday:='N';
     	  p_task_rec.friday:='N';
     	  p_task_rec.saturday:='N';
     	 end if;



               get_alarm_mins (p_task_rec, x_alarm_mins => l_alarm_mins);

  		     p_task_rec.timeZoneId      := task_info.timezone_id;
  		     p_task_rec.description     := task_info.description;
   		     p_task_rec.statusId        :=task_info.task_status_id;
  		     p_task_rec.priorityId      :=task_info.importance_level;
  		     p_task_rec.alarmFlag       :=task_info.alarm_on;
   		     p_task_rec.privateFlag     :=task_info.private_flag;

                  -- fields added for recurring tasks
  		     p_task_rec.unit_of_measure      :=task_info.occurs_uom;
  		     p_task_rec.occurs_every         :=task_info.occurs_every;

  		     p_task_rec.locations            :=task_info.locations;
  	         p_task_rec.free_busy_type       :=task_info.free_busy_type;


       --checking if the appointment spans from 00:00:00 to 23:59:00
       --if yes change the end date to be equal to start_date. This will take care
       --of appoinment created from JTT and OA pages where
       --all day appointments are created from 00:00:00 to 23:59:00
       --for all-day appointment created from outlook, the start date is
       --equal to end date.

           if (p_task_rec.objectcode = G_APPOINTMENT) then
             IF ((task_info.planned_end_date - task_info.planned_start_date)*24*60 = 1439) then
                    task_info.planned_end_date := task_info.planned_start_date;
             end if;
           end if;


              adjust_timezone (
                p_timezone_id          => task_info.timezone_id,
                p_syncanchor           => task_info.new_timestamp,
                p_planned_start_date   => task_info.planned_start_date,
                p_planned_end_date     => task_info.planned_end_date,
                p_scheduled_start_date => task_info.scheduled_start_date,
                p_scheduled_end_date   => task_info.scheduled_end_date,
                p_actual_start_date    => task_info.actual_start_date,
                p_actual_end_date      => task_info.actual_end_date,
                p_item_display_type    => 1,
                x_task_rec             => p_task_rec);

                p_task_rec.alarmdate := set_alarm_date (
                                    p_task_id => l_task_id,
                                    p_request_type => 'APPOINTMENTS',
                                    p_scheduled_start_date => p_task_rec.scheduledstartdate,
                                    p_planned_start_date => p_task_rec.plannedstartdate,
                                    p_actual_start_date => p_task_rec.actualstartdate,
                                    p_alarm_flag => task_info.alarm_on,
                                    p_alarm_start => task_info.alarm_start
                                );
           --    p_task_rec.alarmdate:=convert_task_to_gmt (p_date=>l_alarmdate,p_timezone_id=>task_info.timezone_id );


           make_prefix (
              p_assignment_status_id    => get_assignment_status_id (l_task_id, p_resource_id),
              p_source_object_type_code => p_task_rec.objectcode,
              p_resource_type           => task_info.owner_type_code,
              p_resource_id             => cac_sync_task.g_login_resource_id,
              p_group_id                => p_resource_id,
              x_subject                 => task_info.task_name
          );

              p_task_rec.subject    := task_info.task_name;

    /*  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_sync_task_common.create_new_data', 'point 1  p_task_rec.subject '||p_task_rec.subject);
      end if;*/
         end if;

           if (get_task_info%ISOPEN)  then
	     close get_task_info;
           end if;

          EXCEPTION
            WHEN OTHERS then
              if (get_task_info%ISOPEN)  then
               close get_task_info;
              end if;





     END  overwrite_task_record;




  PROCEDURE update_existing_data (
      p_task_rec        IN OUT NOCOPY   cac_sync_task.task_rec,
      p_exclusion_tbl   IN OUT NOCOPY      cac_sync_task.exclusion_tbl,
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
      p_occurs_month        NUMBER;
      l_occurs_number       NUMBER;
      l_booking_rec         cac_bookings_pub.booking_type;
      l_rowid	            ROWID;
      l_G_TASK_TIMEZONE_ID  NUMBER;
       l_sunday              VARCHAR2(1);
       l_monday              VARCHAR2(1);
       l_tuesday             VARCHAR2(1);
       l_wednesday           VARCHAR2(1);
       l_thursday            VARCHAR2(1);
       l_friday              VARCHAR2(1);
       l_saturday            VARCHAR2(1);
       l_date_of_month       NUMBER;
       l_occurs_which        NUMBER;
       l_repeat_start_date   DATE;
       l_repeat_end_date     DATE;



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


    cursor getTaskForRecurRule(b_task_id number) is
     select CAC.COLLAB_ID, CAC.MEETING_MODE,CAC.MEETING_ID,CAC.MEETING_URL,
      CAC.JOIN_URL ,CAC.PLAYBACK_URL ,CAC.DOWNLOAD_URL ,CAC.CHAT_URL ,
       CAC.IS_STANDALONE_LOCATION,CAC.DIAL_IN, jtb1.task_id
        from cac_view_collab_details_vl cac, jtf_tasks_b jtb1,jtf_tasks_b jtb2
         where cac.task_id=jtb1.task_id
          and jtb1.recurrence_rule_id=jtb2.recurrence_rule_id
           and jtb2.task_id=b_task_id;

	     p_getTaskForRecurRule    getTaskForRecurRule%rowtype;


     cursor getCollabDetails(b_task_id  NUMBER) is
      select COLLAB_ID, MEETING_MODE,MEETING_ID,MEETING_URL,JOIN_URL ,
         PLAYBACK_URL ,DOWNLOAD_URL ,CHAT_URL ,IS_STANDALONE_LOCATION,DIAL_IN
        from  CAC_VIEW_COLLAB_DETAILS_VL
        where task_id=b_task_id;
     l_collab_details         getCollabDetails%rowtype;
     l_priorityId             jtf_tasks_b.task_priority_id%type;

       repeat_to_nonrepeat  BOOLEAN;
       nonrepeat_to_repeat  BOOLEAN;
       l_location      CAC_VIEW_COLLAB_DETAILS_TL.LOCATION%type:=substrb(p_task_rec.locations,1,100);
       l_free_busy_type   VARCHAR2(25) := FND_API.G_MISS_CHAR;

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
       l_priorityId  := get_priorityId (l_task_id);
/*       l_status_id := getchangedstatusid (
                           p_task_status_id => p_task_rec.statusid,
                           p_source_object_type_code => p_task_rec.objectcode
                      );
*/ ---commented out this code as it not used.
/*       l_category_id := cac_sync_task_category.get_category_id (
                             p_category_name => p_task_rec.category,
                             p_profile_id    => cac_sync_task_category.get_profile_id(p_resource_id)
                        );*/ ---commented out this code as it not used.

       l_update_type := get_update_type (
                            p_task_id => l_task_id,
                            p_resource_id => p_resource_id,
                            p_subject => p_task_rec.subject
                       );


       --checking if the user is converting repeating to non-repeating appointment
       --checking if te user is converting non-repeating to repeating appointment
       repeat_to_nonrepeat:=false;
       nonrepeat_to_repeat:=false;



       if ((l_rec_rule_id is not null) and (p_task_rec.unit_of_measure IS NULL) )  then

           repeat_to_nonrepeat:=true;

        if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

	  FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task_common.create_new_data', ' Converting repeating into non-repeating ' );

         end if;

       elsif ((l_rec_rule_id is null) and (p_task_rec.unit_of_measure is not null) )  then

           nonrepeat_to_repeat:=true;

         if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

	    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_sync_task_common.create_new_data', ' Converting non-repeating into repeating ' );

         end if;

        end if;


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
                 l_changed_rule := cac_sync_task_common.changed_repeat_rule(p_task_rec => p_task_rec);

                 IF l_changed_rule AND
                    l_update_type = cac_sync_task_common.g_update_all
                 THEN -- Changed Repeating Rule


                    -- include open end dates also

            l_G_TASK_TIMEZONE_ID:=get_task_timezone_id(l_task_id);

                         IF p_task_rec.unit_of_measure = 'YER' THEN
	                     p_occurs_month := to_number(to_char(p_task_rec.start_date, 'MM'));
	                     else
	                     p_occurs_month:=null;
	                   END IF;

	                   CAC_VIEW_UTIL_PVT.ADJUST_RECUR_RULE_FOR_TIMEZONE(
	                   p_source_tz_id => G_GMT_TIMEZONE_ID,
	                   p_dest_tz_id=> l_G_TASK_TIMEZONE_ID,
	                   p_base_start_datetime=>p_task_rec.plannedstartdate,
	                   p_base_end_datetime  =>p_task_rec.plannedenddate,
	                   p_start_date_active  =>p_task_rec.start_date,
	                   p_end_date_active    =>p_task_rec.end_date,
	                   p_occurs_which       =>p_task_rec.occurs_which,
	                   p_date_of_month      =>p_task_rec.date_of_month,
	                   p_occurs_month       =>p_occurs_month,
	                   p_sunday             =>p_task_rec.sunday,
	                   p_monday             =>p_task_rec.monday,
	                   p_tuesday            =>p_task_rec.tuesday,
	                   p_wednesday          =>p_task_rec.wednesday,
	                   p_thursday           =>p_task_rec.thursday,
	                   p_friday             =>p_task_rec.friday,
	                   p_saturday           =>p_task_rec.saturday,
	                   x_start_date_active  =>l_repeat_start_date,
                           x_end_date_active    =>l_repeat_end_date   ,
                           x_occurs_which       =>l_occurs_which,
                           x_date_of_month      =>l_date_of_month,
                           x_occurs_month       =>l_occurs_month,
                           x_sunday             =>l_sunday,
                           x_monday             =>l_monday,
                           x_tuesday            =>l_tuesday,
                           x_wednesday          =>l_wednesday,
                           x_thursday           =>l_thursday,
                           x_friday             =>l_friday,
                           x_saturday           =>l_saturday);




                    IF (l_repeat_end_date IS NULL) THEN
			l_occurs_number := G_USER_DEFAULT_REPEAT_COUNT;
                    END IF;

              jtf_task_recurrences_pvt.update_task_recurrence (
                           p_api_version        =>   1.0,
                           p_task_id            =>   l_task_id,
                           p_recurrence_rule_id =>   l_rec_rule_id,
                           p_occurs_which       =>   l_occurs_which,
                           p_date_of_month      =>   l_date_of_month,
                           p_occurs_month       =>   l_occurs_month,
                           p_occurs_uom         =>   p_task_rec.unit_of_measure,
                           p_occurs_every       =>   p_task_rec.occurs_every,
                           p_occurs_number      =>   l_occurs_number,
                           p_start_date_active  =>   l_repeat_start_date,
                           p_end_date_active    =>   l_repeat_end_date,
                           p_sunday             =>   l_sunday,
                           p_monday             =>   l_monday,
                           p_tuesday            =>   l_tuesday,
                           p_wednesday          =>   l_wednesday,
                           p_thursday           =>   l_thursday,
                           p_friday             =>   l_friday,
                           p_saturday           =>   l_saturday,
                           x_new_recurrence_rule_id =>   l_new_recurrence_rule_id,
                           x_return_status      =>   l_return_status,
                           x_msg_count          =>   l_msg_count,
                           x_msg_data           =>   l_msg_data
                    );



                    IF NOT cac_sync_common.is_success (l_return_status)
                    THEN-- Failed to update a task

       l_task_id     := get_task_id (p_sync_id => p_task_rec.syncid);
       l_ovn         := get_ovn (p_task_id => l_task_id);
       l_rec_rule_id := get_recurrence_rule_id (p_task_id => l_task_id);


                    cac_sync_common.put_messages_to_result (
                            p_task_rec,
                            p_status => 2,
                            p_user_message => 'JTA_SYNC_UPDATE_RECUR_FAIL'
                       );

                       ELSE

                       --get all the collab details for the given recurrence rule

                       open getTaskForRecurRule(l_task_id);

                        LOOP

                         fetch getTaskForRecurRule into p_getTaskForRecurRule;

                         exit when getTaskForRecurRule%NOTFOUND;

                         --update collab details

                          cac_view_collab_details_pkg.update_row
                          (x_collab_id=> p_getTaskForRecurRule.collab_id ,
                           x_task_id=> p_getTaskForRecurRule.task_id,
                           x_meeting_mode=>p_getTaskForRecurRule.meeting_mode,
                           x_meeting_id=>p_getTaskForRecurRule.meeting_id,
                           x_meeting_url=>p_getTaskForRecurRule.meeting_url,
                           x_join_url=>p_getTaskForRecurRule.join_url,
                           x_playback_url=>p_getTaskForRecurRule.playback_url,
                           x_download_url=>p_getTaskForRecurRule.download_url,
                           x_chat_url=>p_getTaskForRecurRule.chat_url,
                           x_is_standalone_location=>p_getTaskForRecurRule.is_standalone_location,
                           x_location=>l_location,-- p_task_rec.locations,
                           x_dial_in=>p_task_rec.dial_in,
                           x_last_update_date=>sysdate,
                           x_last_updated_by=>jtf_task_utl.updated_by,
                           x_last_update_login=>jtf_task_utl.login_id);

                        END LOOP;

                        IF (getTaskForRecurRule%ISOPEN) then
                         close getTaskForRecurRule;
                        END IF;

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

          if ((repeat_to_nonrepeat=true)  or (nonrepeat_to_repeat=true) ) then


             delete_task_data ( p_task_rec =>p_task_rec, p_delete_map_flag  =>true);

             create_new_data( p_task_rec =>p_task_rec,
             p_mapping_type    =>null,
             p_exclusion_tbl   =>p_exclusion_tbl,
             p_resource_id     =>p_resource_id,
             p_resource_type   =>p_resource_type );


          else -- of if (repeat_to_nonrepeat=true)  then


       if (l_planned_start_date=l_planned_end_date) then

     	  l_planned_end_date:=l_planned_start_date +1 -1/(60*24)  ;

        end if;
               jta_cal_appointment_pvt.update_appointment (
                    p_object_version_number  => l_ovn ,
                    p_task_id                => l_task_id,
                    p_task_name              => NVL (l_task_name, ' '),
                    p_description            => p_task_rec.description,
                    p_task_priority_id       => l_priorityId,
                    p_planned_start_date     => l_planned_start_date,
                    p_planned_end_date       => l_planned_end_date,
                    p_timezone_id            => get_task_timezone_id (l_task_id),
                    p_private_flag           => p_task_rec.privateflag,
                    p_alarm_start            => l_alarm_mins,
                    p_alarm_on               => p_task_rec.alarmflag,
                    --p_category_id            => l_category_id,
		            p_free_busy_type         => p_task_rec.free_busy_type,
                    p_change_mode            => jtf_task_repeat_appt_pvt.g_all,
                    x_return_status          => l_return_status
               );



   if (l_rec_rule_id is null)  then

   --getting the Details from table CAC_VIEW_COLLAB_DETAILS for a given non -repeating task
          open  getCollabDetails(l_task_id);
            fetch getCollabDetails into l_collab_details;

  -- Update the rows only if there are some information in the CAC_VIEW_COLLAB_DETAILS table
  --otherwise close the cursor.
             If (getCollabDetails%FOUND)  then

              cac_view_collab_details_pkg.update_row
               (x_collab_id=> l_collab_details.collab_id ,
                x_task_id=> l_task_id,
                x_meeting_mode=>l_collab_details.meeting_mode,
                x_meeting_id=>l_collab_details.meeting_id,
                x_meeting_url=>l_collab_details.meeting_url,
                x_join_url=>l_collab_details.join_url,
                x_playback_url=>l_collab_details.playback_url,
                x_download_url=>l_collab_details.download_url,
                x_chat_url=>l_collab_details.chat_url,
                x_is_standalone_location=>l_collab_details.is_standalone_location,
                x_location=>l_location,--  was   p_task_rec.locations,
                x_dial_in=>p_task_rec.dial_in,
                x_last_update_date=>sysdate,
                x_last_updated_by=>jtf_task_utl.updated_by,
                x_last_update_login=>jtf_task_utl.login_id);


               else

               cac_view_collab_details_pkg.insert_row (
                  x_rowid => l_rowid,
                  x_collab_id => get_collab_id,--cac_view_collab_details_s.nextval,
                  x_task_id => l_task_id,
                  x_meeting_mode => 'LIVE',
                  x_meeting_id => null,
                  x_meeting_url => null,
                  x_join_url => null,
                  x_playback_url => null,
                  x_download_url => null,
                  x_chat_url => null,
                  x_is_standalone_location => 'Y',
                  x_location => l_location,--was p_task_rec.locations,
                  x_dial_in => p_task_rec.dial_in,
                  x_creation_date => SYSDATE,
                  x_created_by => jtf_task_utl.created_by,
                  x_last_update_date => SYSDATE,
                  x_last_updated_by => jtf_task_utl.updated_by,
                  x_last_update_login => jtf_task_utl.login_id);


              end if;

             CLOSE getCollabDetails;

   else
--updating all the recurrence of the repeating appointment

              open getTaskForRecurRule(l_task_id);
               LOOP
                 fetch getTaskForRecurRule into p_getTaskForRecurRule;
                 exit when getTaskForRecurRule%NOTFOUND;
                 --update collab details
                 cac_view_collab_details_pkg.update_row
                   (x_collab_id=> p_getTaskForRecurRule.collab_id ,
                    x_task_id=> p_getTaskForRecurRule.task_id,
                    x_meeting_mode=>p_getTaskForRecurRule.meeting_mode,
                    x_meeting_id=>p_getTaskForRecurRule.meeting_id,
                    x_meeting_url=>p_getTaskForRecurRule.meeting_url,
                    x_join_url=>p_getTaskForRecurRule.join_url,
                    x_playback_url=>p_getTaskForRecurRule.playback_url,
                    x_download_url=>p_getTaskForRecurRule.download_url,
                    x_chat_url=>p_getTaskForRecurRule.chat_url,
                    x_is_standalone_location=>p_getTaskForRecurRule.is_standalone_location,
                    x_location=>l_location,--was p_task_rec.locations,
                    x_dial_in=>p_task_rec.dial_in,
                    x_last_update_date=>sysdate,
                    x_last_updated_by=>jtf_task_utl.updated_by,
                    x_last_update_login=>jtf_task_utl.login_id);
                 END LOOP;
              close getTaskForRecurRule;

    end if;-- for if (l_rec_rule_id is null)


         end if; --if (repeat_to_nonrepeat=true)  then



          ELSIF (p_task_rec.objectcode = 'TASK')
	       THEN

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
--                    p_actual_start_date     => l_actual_start_date,
--                    p_actual_end_date       => l_actual_end_date,
                    p_show_on_calendar      => fnd_api.g_miss_char, -- Fix Bug 2467021: For update, pass g_miss_char
                    p_date_selected         => fnd_api.g_miss_char, -- Fix Bug 2467021: For update, pass g_miss_char
                    p_alarm_start           => l_alarm_mins,
                    p_alarm_start_uom       => 'MIN',
                    p_timezone_id           => get_task_timezone_id (l_task_id),
                    p_private_flag          => p_task_rec.privateflag,
                    --p_category_id           => l_category_id,
                    p_change_mode           => 'A',
                    p_enable_workflow       => 'N',
                    p_abort_workflow        => 'N',
                    x_return_status         => l_return_status,
                    x_msg_count             => l_msg_count,
                    x_msg_data              => l_msg_data
              );

      ELSIF (p_task_rec.objectcode = 'BOOKING')
	    THEN

    if ((repeat_to_nonrepeat=true)  or (nonrepeat_to_repeat=true) ) then


             delete_task_data ( p_task_rec =>p_task_rec, p_delete_map_flag  =>true);

             create_new_data( p_task_rec =>p_task_rec,
             p_mapping_type    =>null,
             p_exclusion_tbl   =>p_exclusion_tbl,
             p_resource_id     =>p_resource_id,
             p_resource_type   =>p_resource_type );


          else -- of if (repeat_to_nonrepeat=true)  then


       if (l_planned_start_date=l_planned_end_date) then

     	  l_planned_end_date:=l_planned_start_date +1 -1/(60*24)  ;

        end if;
        cac_view_appt_pvt.update_external_appointment (
              p_object_version_number   =>l_ovn,
              p_task_id                 =>l_task_id,
              p_task_name               => NVL (l_task_name, ' '),
              p_task_type_id            => get_default_task_type,
              p_description             => p_task_rec.description,
              p_task_priority_id        => p_task_rec.priorityid,
              p_planned_start_date      => l_planned_start_date,
              p_planned_end_date        => l_planned_end_date,
              p_timezone_id             => G_SERVER_TIMEZONE_ID,  --changed from g_client_timezone_id as all the value must be stored at server timezone
              p_private_flag            => p_task_rec.privateFlag,
              p_alarm_start             => l_alarm_mins,
              p_alarm_on                => p_task_rec.alarmflag,
              --p_category_id             => l_category_id,
	          p_free_busy_type          => p_task_rec.free_busy_type,
	          p_change_mode             => jtf_task_repeat_appt_pvt.g_all,
              x_return_status           => l_return_status
        );

          OPEN  getCollabDetails(l_task_id);

             FETCH getCollabDetails INTO l_collab_details;

          -- Update the rows only if there are some information in the CAC_VIEW_COLLAB_DETAILS table
          --otherwise close the cursor.
             IF (getCollabDetails%FOUND)  THEN

              l_location := SUBSTRB(p_task_rec.locations,1,100);

              cac_view_collab_details_pkg.update_row
               (x_collab_id=> l_collab_details.collab_id ,
                x_task_id=> l_task_id,
                x_meeting_mode=>l_collab_details.meeting_mode,
                x_meeting_id=>l_collab_details.meeting_id,
                x_meeting_url=>l_collab_details.meeting_url,
                x_join_url=>l_collab_details.join_url,
                x_playback_url=>l_collab_details.playback_url,
                x_download_url=>l_collab_details.download_url,
                x_chat_url=>l_collab_details.chat_url,
                x_is_standalone_location=>l_collab_details.is_standalone_location,
                x_location=>l_location,
                x_dial_in=>p_task_rec.dial_in,
                x_last_update_date=>SYSDATE,
                x_last_updated_by=>jtf_task_utl.updated_by,
                x_last_update_login=>jtf_task_utl.login_id);

               END IF;


              IF (getCollabDetails%ISOPEN) THEN
              CLOSE getCollabDetails;
              END IF;

        do_mapping (
                p_task_id      => l_task_id,
                p_operation    => g_modify,
                x_task_sync_id => p_task_rec.syncid,
                p_principal_id => p_task_rec.principal_id
        );

    end if;-- for if ((repeat_to_nonrepeat=true)  or (nonrepeat_to_repeat=true) ) then


    END IF;

 if ((repeat_to_nonrepeat=false)  and (nonrepeat_to_repeat=false) ) then

           IF NOT cac_sync_common.is_success (l_return_status)
           THEN-- Failed to update a task

               cac_sync_common.put_messages_to_result (
                  p_task_rec,
                  p_status => 2,
                  p_user_message => 'JTA_SYNC_UPDATE_TASK_FAIL'
               );   -- l_return_status
           END IF;
end if;

      ELSIF ((l_update_type = g_update_status)) --and (compare_task_rec(p_task_rec)=true))
      THEN
         if not (compare_task_rec(p_task_rec)) then

            cac_sync_common.put_messages_to_result (
                  p_task_rec,
                  p_status => 2,
                  p_user_message => 'CAC_SYNC_APPT_PERMISSION_DENY',
                  p_token_name=>'P_APPOINTMENT_SUBJECT',
                  p_token_value=>p_task_rec.subject
               );   -- l_return_status
         else

            l_task_assignment_id := get_assignment_id (
                                       p_task_id => l_task_id,
                                       p_resource_id => p_resource_id,
                                       p_resource_type => p_resource_type
                                 );
            l_ovn := get_ovn (p_task_assignment_id => l_task_assignment_id);

            if g_fb_type_changed
            then
                l_free_busy_type := p_task_rec.free_busy_type;
            end if;

            jtf_task_assignments_pvt.update_task_assignment (
             p_api_version           => 1.0,
             p_object_version_number => l_ovn,
             p_init_msg_list         => fnd_api.g_true,
             p_commit                => fnd_api.g_false,
             p_task_assignment_id    => l_task_assignment_id,
             p_assignment_status_id  => 3,   -- ACCEPT
             p_free_busy_type        => l_free_busy_type,
             p_enable_workflow 	     => fnd_profile.value('JTF_TASK_ENABLE_WORKFLOW'),
             p_abort_workflow		 => fnd_profile.value('JTF_TASK_ABORT_PREV_WF'),
             x_return_status         => l_return_status,
             x_msg_count             => l_msg_count,
             x_msg_data              => l_msg_data
            );

            IF NOT cac_sync_common.is_success (l_return_status)
            THEN
               cac_sync_common.put_messages_to_result (
                    p_task_rec,
                    p_status => 2,
                    p_user_message => 'JTA_SYNC_UPDATE_STS_FAIL'
               );
            END IF;
         end if;

         overwrite_task_record(
           p_task_rec=>p_task_rec,
           p_resource_id    =>p_resource_id,
           p_resource_type   =>p_resource_type);
--check when user cant update the appointment as he is the invitee not the owner
	ELSE--IF --(l_update_type=g_do_nothing) then
/*

      if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_sync_task_common.create_new_data', ' When l_update_type=g_do_nothing for task  '|| p_task_rec.subject);
      end if;*/
          if not (compare_task_rec(p_task_rec)) then -- code added for bug 5264362

            cac_sync_common.put_messages_to_result (
                  p_task_rec,
                  p_status => 2,
                  p_user_message => 'CAC_SYNC_APPT_PERMISSION_DENY',
                  p_token_name=>'P_APPOINTMENT_SUBJECT',
                  p_token_value=>p_task_rec.subject
               );   -- l_return_status

--update the record. overwrite saved data
         overwrite_task_record(
           p_task_rec=>p_task_rec,
           p_resource_id    =>p_resource_id,
           p_resource_type   =>p_resource_type);
        elsif g_fb_type_changed
        then
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
             p_free_busy_type        => p_task_rec.free_busy_type,
             p_enable_workflow 	     => fnd_profile.value('JTF_TASK_ENABLE_WORKFLOW'),
             p_abort_workflow		 => fnd_profile.value('JTF_TASK_ABORT_PREV_WF'),
             --p_update_all            => l_update_all,
             --p_enable_workflow       => 'N',
             --p_abort_workflow        => 'N',
             x_return_status         => l_return_status,
             x_msg_count             => l_msg_count,
             x_msg_data              => l_msg_data
         );

	end if;   -- code added for bug 5264362

     END IF; -- l_update_type

      -- Check the current status and update if it's succeeded
     IF nvl(p_task_rec.resultId,0) < 2
     THEN
             cac_sync_common.put_messages_to_result (
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
      x_task_rec            IN OUT NOCOPY   cac_sync_task.task_rec
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

      IF cac_sync_common.is_success (l_return_status)
      THEN
         x_task_rec.syncanchor := convert_server_to_gmt (SYSDATE);

         cac_sync_common.put_messages_to_result (
              x_task_rec,
              p_status => g_sync_success,
              p_user_message => 'JTA_SYNC_SUCCESS'
         );
      ELSE
         cac_sync_common.put_messages_to_result (
              x_task_rec,
              p_status => 2,
              p_user_message => 'JTA_SYNC_DELETE_EXCLUSION_FAIL'
         );
      END IF;
   END delete_exclusion_task;

   PROCEDURE delete_task_data (
      p_task_rec      IN OUT NOCOPY   cac_sync_task.task_rec,
      p_delete_map_flag   IN       BOOLEAN
   )
   IS

      l_task_id     NUMBER;
      l_return_status   VARCHAR2(1);
      l_msg_data    VARCHAR2(2000);
      l_msg_count   NUMBER;
   BEGIN
      l_return_status := fnd_api.g_ret_sts_success;

      l_task_id := get_task_id (p_sync_id => p_task_rec.syncid);

      delete_tasks(p_task_id => l_task_id,
                  x_return_status => l_return_status);


    If  cac_sync_common.is_success (l_return_status)
      THEN
         p_task_rec.syncanchor := convert_server_to_gmt (SYSDATE + 1 / (24 * 60 * 60));

         IF p_delete_map_flag
         THEN

            cac_sync_task_map_pkg.delete_row (
               p_task_sync_id => p_task_rec.syncid
            );
         END IF;

         cac_sync_common.put_messages_to_result (
            p_task_rec,
            p_status => g_sync_success,
            p_user_message => 'JTA_SYNC_SUCCESS'
         );
      ELSE
         cac_sync_common.put_messages_to_result (
            p_task_rec,
            p_status => 2,
            p_user_message => 'JTA_SYNC_DELETE_TASK_FAILED'
         );
      END IF;

   END delete_task_data;

   PROCEDURE reject_task_data (p_task_rec IN OUT NOCOPY cac_sync_task.task_rec)
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

       IF cac_sync_common.is_success (l_return_status)
       THEN
            p_task_rec.syncanchor := convert_server_to_gmt(SYSDATE);

            cac_sync_common.put_messages_to_result (
               p_task_rec,
               p_status => g_sync_success,
               p_user_message => 'JTA_SYNC_SUCCESS'
            );

            cac_sync_task_map_pkg.delete_row(p_task_sync_id => p_task_rec.syncid);
       ELSE
            cac_sync_common.put_messages_to_result (
               p_task_rec,
               p_status => 2,
               p_user_message => 'JTA_SYNC_UPDATE_STS_FAIL'
            );
       END IF;
   END reject_task_data;

   FUNCTION changed_repeat_rule (p_task_rec IN cac_sync_task.task_rec)
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
      convert_recur_date_to_server (
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
                  x_operation := cac_sync_task_common.g_delete;
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
              x_operation := cac_sync_task_common.g_delete;
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
            x_operation := cac_sync_task_common.g_delete;
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
        x_operation := cac_sync_task_common.g_modify;

        CLOSE c_task_status;

    END IF;
   END transformstatus;
/*
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
         ,fnd_responsibility
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
*/--commented out checkUserStatusRule as it is not used in the code
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
           fnd_message.set_token('PROC_NAME','cac_sync_task_COMMON.GET_TASK_ID');
           fnd_msg_pub.add;

           raise_application_error (-20100,cac_sync_common.get_messages);
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



  FUNCTION get_dial_in_value( p_task_id  IN NUMBER)

  RETURN VARCHAR2
    IS
     cursor getDialInValue(b_task_id number)
      is
       select cactl.dial_in
       from
       cac_view_collab_details_tl cactl,
       cac_view_collab_details cac
       where cac.collab_id=cactl.collab_id
       and cactl.LANGUAGE = userenv('LANG')
       and cac.task_id=b_task_id;

      l_dial_in   VARCHAR2(100);

  BEGIN

    open getDialInValue(p_task_id);

     fetch getDialInValue into l_dial_in;

     IF (getDialInValue%NOTFOUND) THEN

      CLOSE getDialInValue;
       return null;

     END IF;

      IF (getDialInValue%ISOPEN) THEN
       CLOSE getDialInValue;
      END IF;

     return l_dial_in;

   END get_dial_in_value;


  procedure delete_bookings (
      p_principal_id        IN   NUMBER

   )
   IS

      CURSOR getUserId(b_principal_id  IN NUMBER)
      IS
       SELECT user_id
        FROM cac_sync_principals
        WHERE principal_id  = b_principal_id;

      CURSOR getBookings(b_principal_id  IN NUMBER, b_user_id IN NUMBER)
      IS
       SELECT jtb.task_id,jtb.object_version_number,jstm.task_sync_id, jtb.source_object_type_code objectcode
        FROM jta_sync_task_mapping jstm, jtf_tasks_b jtb
        WHERE jstm.principal_id IN
		(SELECT principal_id
		FROM cac_sync_principals
		WHERE device_id = (SELECT device_id FROM cac_sync_principals
		WHERE principal_id = b_principal_id)
		AND user_id = b_user_id)
         AND   jstm.task_id=jtb.task_id
        AND   jtb.entity IN ('BOOKING', 'APPOINTMENT')
        AND   jtb.source_object_type_code='EXTERNAL APPOINTMENT';

      p_getBookings     getBookings%rowtype;
      l_getUserId     getUserId%ROWTYPE;
      l_return_status       VARCHAR2(1);
      l_msg_count           NUMBER;
      l_msg_data            VARCHAR2(2000);
      l_user_id  	    NUMBER;


   BEGIN
      l_return_status := fnd_api.g_ret_sts_success;

      OPEN getUserId(p_principal_id);

        FETCH getUserId INTO l_getUserId ;
	     IF (getUserId%FOUND) THEN

		 l_user_id := l_getUserId.user_id;

	      IF (getUserId%ISOPEN) THEN
	       CLOSE getUserId;
	      END IF;

		END IF;

      OPEN getBookings(p_principal_id, l_user_id);

       LOOP  --start of the loop

        fetch getBookings into p_getBookings ;

    /*   if (getBookings%NOTFOUND)  then
	 if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_sync_task_common.delete_booking', 'no booking is found for the principal id ' || p_principal_id);
	  end if;
	  else

	 if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_sync_task_common.delete_booking', 'booking is found for the principal id ' || p_principal_id);
	 end if;

       end if;*/



         exit when getBookings%NOTFOUND;

        delete_tasks(p_task_id => p_getBookings.task_id,
                     x_return_status => l_return_status);


       IF cac_sync_common.is_success (l_return_status)
        THEN
           cac_sync_task_map_pkg.delete_row (
               p_task_sync_id => p_getBookings.task_sync_id);

    /*     if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_sync_task_common.delete_booking', 'success from cac_bookings_pub.delete_booking');
	 end if;

       else --failure from delete_booking API

         if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_sync_task_common.delete_booking', 'failure from cac_bookings_pub.delete_booking');
	 end if;
*/

       END IF;


      END LOOP; --end of the loop

      IF (getBookings%ISOPEN) THEN
       close getBookings;
      END IF;

   END delete_bookings;



  function is_recur_rule_same (
      p_task_rec        IN  OUT NOCOPY cac_sync_task.task_rec

   ) return boolean
   IS

      cursor get_recur_rule(b_task_id  IN NUMBER)
      is
       select OCCURS_WHICH,DAY_OF_WEEK,DATE_OF_MONTH,
              OCCURS_MONTH,OCCURS_UOM,OCCURS_EVERY,
              OCCURS_NUMBER,START_DATE_ACTIVE,END_DATE_ACTIVE,
              SUNDAY,MONDAY,TUESDAY,WEDNESDAY,THURSDAY,FRIDAY,
              SATURDAY
       from jtf_task_recur_rules jtrr, jtf_tasks_b b
       where b.recurrence_rule_id=jtrr.recurrence_rule_id
          and b.task_id=b_task_id;

     l_get_recur_rule  get_recur_rule%rowtype;
      l_task_id  NUMBER;

      l_resource_id NUMBER;
      l_resource_type VARCHAR2(30);
       l_update_type         VARCHAR2(15);

   BEGIN

      l_task_id:=get_task_id (p_sync_id=>p_task_rec.syncid );
    cac_sync_task_common.get_resource_details (l_resource_id, l_resource_type);

       l_update_type := get_update_type (
                            p_task_id => l_task_id,
                            p_resource_id => l_resource_id,
                            p_subject => p_task_rec.subject
                       );


    if (l_update_type = g_update_all)  then
      open get_recur_rule(l_task_id);

      fetch get_recur_rule into l_get_recur_rule ;

     if (get_recur_rule%FOUND) then


      IF (get_recur_rule%ISOPEN) THEN
       close get_recur_rule;
      END IF;


     if (nvl(p_task_rec.unit_of_measure,null)<> nvl(l_get_recur_rule.OCCURS_UOM,null)) then
       return false;
    end if;
/*
     if (nvl(p_task_rec.occurs_every,null)<> nvl(l_get_recur_rule.OCCURS_EVERY,null)) then
       return false;
    end if;
  */
         if (nvl(p_task_rec.start_date,null)<> nvl(l_get_recur_rule.start_date_active,null)) then
       return false;
    end if;

     if (nvl(p_task_rec.end_date,null)<> nvl(l_get_recur_rule.end_date_active,null)) then
       return false;
    end if;
    /*
     if (nvl(p_task_rec.date_of_month,null)<> nvl(l_get_recur_rule.date_of_month,null)) then
       return false;
    end if;

     if (nvl(p_task_rec.occurs_which,null)<> nvl(l_get_recur_rule.OCCURS_WHICH,null)) then
       return false;
    end if;

    if (nvl(p_task_rec.sunday,null)<> nvl(l_get_recur_rule.sunday,null)) then
       return false;
    end if;

    if (nvl(p_task_rec.monday,null)<> nvl(l_get_recur_rule.monday,null)) then
       return false;
    end if;

     if (nvl(p_task_rec.tuesday,null)<> nvl(l_get_recur_rule.tuesday,null)) then
       return false;
    end if;

     if (nvl(p_task_rec.wednesday,null)<> nvl(l_get_recur_rule.wednesday,null)) then
       return false;
    end if;

     if (nvl(p_task_rec.thursday,null)<> nvl(l_get_recur_rule.thursday,null)) then
       return false;
    end if;

     if (nvl(p_task_rec.friday,null)<> nvl(l_get_recur_rule.friday,null)) then
       return false;
    end if;

     if (nvl(p_task_rec.saturday,null)<> nvl(l_get_recur_rule.saturday,null)) then
       return false;
    end if;*/

ELSE

      IF (get_recur_rule%ISOPEN) THEN
       close get_recur_rule;
      END IF;
    return true;

    END IF;

end if;  --  if (l_update_type = g_update_all)

      IF (get_recur_rule%ISOPEN) THEN
       close get_recur_rule;
      END IF;
      return true;
   END is_recur_rule_same;


PROCEDURE delete_tasks (
      p_task_id      IN OUT NOCOPY   NUMBER,
      x_return_status   IN OUT NOCOPY VARCHAR2
   )
   IS

    cursor get_tasks_ids (b_recurrence_rule_id IN NUMBER)
    is
    select jte.task_id from
    jta_task_exclusions jte
    where jte.recurrence_rule_id=b_recurrence_rule_id;

      l_tsk_ids    get_tasks_ids%rowtype;
      l_recurrence_rule_id jtf_tasks_b.recurrence_rule_id%type;
      l_ovn     NUMBER;
      l_msg_data    VARCHAR2(2000);
      l_msg_count   NUMBER;

    BEGIN
      l_ovn := get_ovn (p_task_id => p_task_id);

      l_recurrence_rule_id  :=get_recurrence_rule_id(p_task_id);

          jtf_tasks_pvt.delete_task (
             p_api_version => 1.0,
             p_init_msg_list => fnd_api.g_false,
             p_commit => fnd_api.g_false,
             p_task_id => p_task_id,
             p_object_version_number => l_ovn,
             p_delete_future_recurrences => 'A',
             x_return_status => x_return_status,
             x_msg_count => l_msg_count,
             x_msg_data => l_msg_data
          );

  IF cac_sync_common.is_success (x_return_status) then
---deleting all exclusions....
    if (l_recurrence_rule_id is not null)   then

    open get_tasks_ids(l_recurrence_rule_id);

      LOOP

      fetch get_tasks_ids into l_tsk_ids;
      exit when get_tasks_ids%NOTFOUND;
       l_ovn := get_ovn (p_task_id =>l_tsk_ids.task_id);

            jtf_tasks_pvt.delete_task (
             p_api_version => 1.0,
             p_init_msg_list => fnd_api.g_false,
             p_commit => fnd_api.g_false,
             p_task_id => l_tsk_ids.task_id,
             p_object_version_number => l_ovn,
             p_delete_future_recurrences => jtf_task_repeat_appt_pvt.G_ONE,
             x_return_status => x_return_status,
             x_msg_count => l_msg_count,
             x_msg_data => l_msg_data
          );

       END LOOP;

    if (get_tasks_ids%ISOPEN)  then
      close get_tasks_ids;
    end if;

    end if;

end if;--  for IF cac_sync_common.is_success (x_return_status)
--end deleting all exclusions.....

END delete_tasks;

/* Introduced this procedure for bug#5191856
   This will be called before updating an appointment to see if the appointment still exists
   If the appointment has been deleted/declined, it will return false and update will not be called.
   Instead Sync will throw error saying that appointment has been deleted in server. */
PROCEDURE is_appointment_existing(p_task_sync_id IN NUMBER, x_result OUT NOCOPY VARCHAR2)
IS

   CURSOR check_appt(b_resource_id NUMBER, b_resource_type_code VARCHAR2)
   IS
     SELECT a.assignment_status_id
     from  jtf_tasks_b b, jtf_task_all_assignments a, jta_sync_Task_mapping s
     where b.task_id = a.task_id
     and   s.task_id = b.task_id
     and   s.task_sync_id = p_task_sync_id
     and   a.resource_id = b_resource_id
     and   a.resource_type_code = b_resource_type_code;

   l_resource_id NUMBER;
   l_resource_type_code VARCHAR2(50);
   l_assignment_status_id NUMBER;
BEGIN

  get_resource_details (l_resource_id, l_resource_type_code);

  OPEN check_appt(l_resource_id, l_resource_type_code);
  FETCH check_appt INTO l_assignment_status_id;
  IF check_appt%NOTFOUND
  THEN
     l_assignment_status_id := -1;
  END IF;

  IF check_appt%ISOPEN
  THEN
     CLOSE check_appt;
  END IF;

  IF (l_assignment_status_id = -1 OR l_assignment_status_id = 4)
  THEN
     x_result := 'N';
  ELSE
     x_result := 'Y';
  END IF;

END is_appointment_existing;


END CAC_SYNC_TASK_COMMON ;

/
