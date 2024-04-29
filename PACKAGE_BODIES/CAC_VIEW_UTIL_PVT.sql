--------------------------------------------------------
--  DDL for Package Body CAC_VIEW_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_VIEW_UTIL_PVT" as
/* $Header: cacpvutb.pls 120.7 2006/01/09 23:57:17 deeprao noship $ */
/*======================================================================+
|  Copyright (c) 2004 Oracle Corporation Redwood Shores, California, USA|
|                All rights reserved.                                   |
+=======================================================================+
| FILENAME                                                              |
|      cacpvutb.pls                                                     |
|                                                                       |
| DESCRIPTION                                                           |
|      This package is a private utility for Calendar views.            |
|                                                                       |
| NOTES                                                                 |
|                                                                       |
| Date         Developer        Change                                  |
| -----------  ---------------  --------------------------------------- |
| 01-July-2004  Rada Despotovic Created                                 |
*=======================================================================*/

    /* -----------------------------------------------------------------
     * -- Function Name: create_repeat_collab_details
     * -- Description  : This function creates collaboration details record
     * --                for target task_id by copying the data from source
     * --                task_id.
     * -- Parameter    : p_source_task_id = Task Id
     * -- Parameter    : p_target_task_id = Task Id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
      PROCEDURE create_repeat_collab_details (
      p_source_task_id		IN	 NUMBER,
      p_target_task_id		IN	 NUMBER
   )
   IS
    CURSOR c_collab
      IS
	 SELECT location, dial_in, meeting_mode, meeting_url,
       meeting_id, join_url, playback_url, chat_url, download_url,
       is_standalone_location
	   FROM cac_view_collab_details_vl
	  WHERE task_id = p_source_task_id;

     collab_row c_collab%ROWTYPE;
     l_seqnum  NUMBER := 0;
     l_row_id VARCHAR2(30);
   BEGIN
      SAVEPOINT create_repeat_collab_sp;
      OPEN c_collab;
      FETCH c_collab INTO collab_row;

      IF c_collab%NOTFOUND THEN
         RETURN;
         CLOSE c_collab;
      END IF;
      CLOSE c_collab;
      -- new collab_id
      SELECT cac_view_collab_details_s.nextval
        INTO l_seqnum
       FROM DUAL;

      CAC_VIEW_COLLAB_DETAILS_PKG.INSERT_ROW(
        X_ROWID => l_row_id,
        X_COLLAB_ID => l_seqnum,
        X_TASK_ID => p_target_task_id,
        X_MEETING_MODE => collab_row.meeting_mode,
        X_MEETING_ID => collab_row.meeting_id,
        X_MEETING_URL => collab_row.meeting_url,
        X_JOIN_URL => collab_row.join_url,
        X_PLAYBACK_URL => collab_row.playback_url,
        X_DOWNLOAD_URL => collab_row.download_url,
        X_CHAT_URL => collab_row.chat_url,
        X_IS_STANDALONE_LOCATION => collab_row.is_standalone_location,
        X_LOCATION => collab_row.location,
        X_DIAL_IN => collab_row.dial_in,
        X_CREATION_DATE => SYSDATE,
        X_CREATED_BY => jtf_task_utl.created_by,
        X_LAST_UPDATE_DATE => SYSDATE,
        X_LAST_UPDATED_BY => jtf_task_utl.updated_by,
        X_LAST_UPDATE_LOGIN => fnd_global.login_id);

   EXCEPTION
     WHEN OTHERS THEN
        ROLLBACK TO create_repeat_collab_sp;
        fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
        fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
        fnd_msg_pub.add;

   END create_repeat_collab_details;

    /* -----------------------------------------------------------------
     * -- Function Name: update_repeat_collab_details
     * -- Description  : This function updates collaboration details record
     * --                for target task_id by copying the data from source
     * --                task_id.
     * -- Parameter    : p_source_task_id = Task Id
     * -- Parameter    : p_target_task_id = Task Id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
      PROCEDURE update_repeat_collab_details(
       p_source_task_id		IN	 NUMBER,
      p_target_task_id		IN	 NUMBER
   )
   IS
      CURSOR c_collab
      IS
	 SELECT location, dial_in, meeting_mode, meeting_url,
       meeting_id, join_url, playback_url, chat_url, download_url,
       is_standalone_location
	   FROM cac_view_collab_details_vl
	  WHERE task_id = p_source_task_id;

      CURSOR c_collab_update
      IS
	 SELECT collab_id
	   FROM cac_view_collab_details_vl
	  WHERE task_id = p_target_task_id;

     collab_row c_collab%ROWTYPE;
     collab_update_row c_collab_update%ROWTYPE;
     l_seqnum  NUMBER := 0;
     l_row_id VARCHAR2(30);
   BEGIN

      SAVEPOINT update_repeat_collab_sp;
      OPEN c_collab;
      FETCH c_collab INTO collab_row;

      IF c_collab%NOTFOUND THEN
         CLOSE c_collab;
         RETURN;
      END IF;
      CLOSE c_collab;
      OPEN c_collab_update;
      FETCH c_collab_update INTO collab_update_row;

      IF c_collab_update%NOTFOUND THEN
         CLOSE c_collab_update;
         -- insert here
         -- new collab_id
         SELECT cac_view_collab_details_s.nextval
                INTO l_seqnum
         FROM DUAL;
         CAC_VIEW_COLLAB_DETAILS_PKG.INSERT_ROW(
        X_ROWID => l_row_id,
        X_COLLAB_ID => l_seqnum,
        X_TASK_ID => p_target_task_id,
        X_MEETING_MODE => collab_row.meeting_mode,
        X_MEETING_ID => collab_row.meeting_id,
        X_MEETING_URL => collab_row.meeting_url,
        X_JOIN_URL => collab_row.join_url,
        X_PLAYBACK_URL => collab_row.playback_url,
        X_DOWNLOAD_URL => collab_row.download_url,
        X_CHAT_URL => collab_row.chat_url,
        X_IS_STANDALONE_LOCATION => collab_row.is_standalone_location,
        X_LOCATION => collab_row.location,
        X_DIAL_IN => collab_row.dial_in,
        X_CREATION_DATE => SYSDATE,
        X_CREATED_BY => jtf_task_utl.created_by,
        X_LAST_UPDATE_DATE => SYSDATE,
        X_LAST_UPDATED_BY => jtf_task_utl.updated_by,
        X_LAST_UPDATE_LOGIN => fnd_global.login_id);
         RETURN;
      END IF;
      CLOSE c_collab_update;

      CAC_VIEW_COLLAB_DETAILS_PKG.UPDATE_ROW (
         X_COLLAB_ID => collab_update_row.collab_id,
         X_TASK_ID => p_target_task_id,
         X_MEETING_MODE => collab_row.meeting_mode,
         X_MEETING_ID => collab_row.meeting_id,
         X_MEETING_URL => collab_row.meeting_url,
         X_JOIN_URL => collab_row.join_url,
         X_PLAYBACK_URL => collab_row.playback_url,
         X_DOWNLOAD_URL => collab_row.download_url,
         X_CHAT_URL => collab_row.chat_url,
         X_IS_STANDALONE_LOCATION => collab_row.is_standalone_location,
         X_LOCATION => collab_row.location,
         X_DIAL_IN => collab_row.dial_in,
         X_LAST_UPDATE_DATE => SYSDATE,
         X_LAST_UPDATED_BY => jtf_task_utl.updated_by,
         X_LAST_UPDATE_LOGIN => fnd_global.login_id
         );

   EXCEPTION
     WHEN OTHERS THEN
        ROLLBACK TO update_repeat_collab_sp;
        fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
        fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
        fnd_msg_pub.add;
   END;

   PROCEDURE AdjustForTimezone
   ( p_source_tz_id     IN     NUMBER
   , p_dest_tz_id       IN     NUMBER
   , p_source_day_time  IN     DATE
   , x_dest_day_time       OUT NOCOPY      DATE
   )
   IS
     l_return_status        VARCHAR2(1);
     l_msg_count            NUMBER;
     l_msg_data             VARCHAR2(2000);

     l_SourceTimezoneID NUMBER;

   BEGIN
     IF (p_source_day_time IS NOT NULL)
     THEN
       /****************************************************************************
       ** NULL is the same in every timezone
       ****************************************************************************/
       IF (p_source_tz_id IS NULL)
       THEN
         /**************************************************************************
         ** If the timezone is not defined used the profile value
         **************************************************************************/
         --l_SourceTimezoneID := to_number(FND_PROFILE.Value('JTF_CAL_DEFAULT_TIMEZONE'));
           l_SourceTimezoneID := to_number(FND_PROFILE.Value('SERVER_TIMEZONE_ID'));
         --l_SourceTimezoneID := to_number(NVL(FND_PROFILE.Value('CLIENT_TIMEZONE_ID'),4));
       ELSE
         l_SourceTimezoneID := p_source_tz_id;
       END IF;
       /***********************************************************************
       ** Only adjust if the timezones are different
       ***********************************************************************/
       IF (l_SourceTimezoneID <> p_dest_tz_id)
       THEN
         /*********************************************************************
         ** Call the API to get the adjusted date (this API is slow..)
         *********************************************************************/
         HZ_TIMEZONE_PUB.Get_Time( p_api_version     => 1.0
                                 , p_init_msg_list   => FND_API.G_FALSE
                                 , p_source_tz_id    => l_SourceTimezoneID
                                 , p_dest_tz_id      => p_dest_tz_id
                                 , p_source_day_time => p_source_day_time
                                 , x_dest_day_time   => x_dest_day_time
                                 , x_return_status   => l_return_status
                                 , x_msg_count       => l_msg_count
                                 , x_msg_data        => l_msg_data
                                 );
       ELSE
         x_dest_day_time := p_source_day_time;
       END IF;
     ELSE
       x_dest_day_time := NULL;
     END IF;
   END AdjustForTimezone;

   FUNCTION GET_REMINDER_MEANING (p_lookup_code IN VARCHAR2)
   RETURN VARCHAR2
   IS
       CURSOR c_uom (b_lookup_code VARCHAR2) IS
       SELECT meaning
         FROM fnd_lookups
        WHERE lookup_type = 'CAC_VIEW_REMINDER_UOM'
          AND lookup_code = b_lookup_code
          AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                                 AND TRUNC(NVL(end_date_active, SYSDATE));

       rec_uom   c_uom%ROWTYPE;
   BEGIN
       OPEN c_uom (p_lookup_code);
       FETCH c_uom INTO rec_uom;
       CLOSE c_uom;

       RETURN rec_uom.meaning;
   END GET_REMINDER_MEANING;

   FUNCTION GET_REMINDER_DESCRIPTION (p_reminder IN NUMBER)
   RETURN VARCHAR2
   IS
       l_week NUMBER;
       l_day NUMBER;
       l_hr NUMBER;
       l_min NUMBER;
       l_rem NUMBER;

       l_code VARCHAR2(80);
       l_result_text VARCHAR2(500);
   BEGIN
       l_week := floor(p_reminder / (60*24*7));

       l_rem := p_reminder - l_week*7*60*24;
       l_day := floor(l_rem / (60*24));

       l_rem := l_rem - l_day*60*24;
       l_hr  := floor(l_rem / 60);

       l_rem := l_rem - l_hr*60;
       l_min := l_rem;

       l_result_text := NULL;

       IF l_week > 0 THEN
           IF l_week = 1 THEN
               l_code := 'WEEK';
           ELSE
               l_code := 'WEEKS';
           END IF;

           l_result_text := l_week ||' '|| get_reminder_meaning(l_code);
       END IF;

       IF l_day > 0 THEN
           IF l_day = 1 THEN
           	   l_code := 'DAY';
           ELSE
               l_code := 'DAYS';
           END IF;

           IF l_result_text IS NULL THEN
               l_result_text := l_day ||' '|| get_reminder_meaning(l_code);
           ELSE
               l_result_text := l_result_text ||' '|| l_day ||' '|| get_reminder_meaning(l_code);
           END IF;
       END IF;

       IF l_hr > 0 THEN
           IF l_hr = 1 THEN
           	   l_code := 'HOUR';
           ELSE
               l_code := 'HOURS';
           END IF;

           IF l_result_text IS NULL THEN
               l_result_text := l_hr ||' '|| get_reminder_meaning(l_code);
           ELSE
               l_result_text := l_result_text ||' '|| l_hr ||' '|| get_reminder_meaning(l_code);
           END IF;
       END IF;

       IF l_min > 0 THEN
       	   l_code := 'MIN';

           IF l_result_text IS NULL THEN
               l_result_text := l_min ||' '|| get_reminder_meaning(l_code);
           ELSE
               l_result_text := l_result_text ||' '|| l_min ||' '|| get_reminder_meaning(l_code);
           END IF;
       END IF;

       IF l_result_text IS NOT NULL THEN
           l_result_text := l_result_text ||' '|| get_reminder_meaning('BEFORE');
       END IF;

       RETURN l_result_text;
   END GET_REMINDER_DESCRIPTION;

   PROCEDURE ADJUST_DAYS(p_difference IN NUMBER
                        ,p_sunday     IN  VARCHAR2
                        ,p_monday     IN  VARCHAR2
                        ,p_tuesday    IN  VARCHAR2
                        ,p_wednesday  IN  VARCHAR2
                        ,p_thursday   IN  VARCHAR2
                        ,p_friday     IN  VARCHAR2
                        ,p_saturday   IN  VARCHAR2
                        ,x_sunday     OUT NOCOPY VARCHAR2
                        ,x_monday     OUT NOCOPY VARCHAR2
                        ,x_tuesday    OUT NOCOPY VARCHAR2
                        ,x_wednesday  OUT NOCOPY VARCHAR2
                        ,x_thursday   OUT NOCOPY VARCHAR2
                        ,x_friday     OUT NOCOPY VARCHAR2
                        ,x_saturday   OUT NOCOPY VARCHAR2)
   IS
      TYPE days_list IS TABLE OF VARCHAR2(1);
      l_days days_list;
      l_days_out days_list;
      l_pos NUMBER;
   BEGIN
      l_days := days_list(p_sunday
                         ,p_monday
                         ,p_tuesday
                         ,p_wednesday
                         ,p_thursday
                         ,p_friday
                         ,p_saturday);

      l_days_out := days_list('N','N','N','N','N','N','N');

      FOR i IN l_days.FIRST..l_days.LAST
      LOOP
         IF l_days(i) = 'Y' THEN

            l_pos := i + p_difference;

            IF l_pos < l_days.FIRST THEN
              l_pos := l_days.LAST;
            ELSIF l_pos > l_days.LAST THEN
              l_pos := l_days.FIRST;
            END IF;

            l_days_out(l_pos) := 'Y';
         END IF;
      END LOOP;

      x_sunday    := l_days_out(1);
      x_monday    := l_days_out(2);
      x_tuesday   := l_days_out(3);
      x_wednesday := l_days_out(4);
      x_thursday  := l_days_out(5);
      x_friday    := l_days_out(6);
      x_saturday  := l_days_out(7);

   END ADJUST_DAYS;

   PROCEDURE ADJUST_RECUR_RULE_FOR_TIMEZONE
   (p_source_tz_id        IN  NUMBER
   ,p_dest_tz_id          IN  NUMBER
   ,p_base_start_datetime IN  DATE
   ,p_base_end_datetime   IN  DATE
   ,p_start_date_active   IN  DATE
   ,p_end_date_active     IN  DATE
   ,p_occurs_which        IN  NUMBER
   ,p_date_of_month       IN  NUMBER
   ,p_occurs_month        IN  NUMBER
   ,p_sunday              IN  VARCHAR2
   ,p_monday              IN  VARCHAR2
   ,p_tuesday             IN  VARCHAR2
   ,p_wednesday           IN  VARCHAR2
   ,p_thursday            IN  VARCHAR2
   ,p_friday              IN  VARCHAR2
   ,p_saturday            IN  VARCHAR2
   ,x_start_date_active   OUT NOCOPY DATE
   ,x_end_date_active     OUT NOCOPY DATE
   ,x_occurs_which        OUT NOCOPY NUMBER
   ,x_date_of_month       OUT NOCOPY NUMBER
   ,x_occurs_month        OUT NOCOPY NUMBER
   ,x_sunday              OUT NOCOPY VARCHAR2
   ,x_monday              OUT NOCOPY VARCHAR2
   ,x_tuesday             OUT NOCOPY VARCHAR2
   ,x_wednesday           OUT NOCOPY VARCHAR2
   ,x_thursday            OUT NOCOPY VARCHAR2
   ,x_friday              OUT NOCOPY VARCHAR2
   ,x_saturday            OUT NOCOPY VARCHAR2
   )
   IS
      l_converted_basetime DATE;
      l_difference NUMBER;
      l_repeat_start_date DATE;
      l_repeat_end_date DATE;
   BEGIN
      -- Convert base start date time
      CAC_VIEW_UTIL_PVT.AdjustForTimezone
      ( p_source_tz_id     => p_source_tz_id
      , p_dest_tz_id       => p_dest_tz_id
      , p_source_day_time  => p_base_start_datetime
      , x_dest_day_time    => l_converted_basetime
      );

      -- Difference of date
      l_difference := TRUNC(l_converted_basetime) - TRUNC(p_base_start_datetime);

      l_repeat_start_date := TO_DATE(TO_CHAR(p_start_date_active, 'DD-MON-YYYY')||' '||
                                     TO_CHAR(p_base_start_datetime, 'HH24:MI:SS'),
                                     'DD-MON-YYYY HH24:MI:SS');
      l_repeat_end_date := TO_DATE(TO_CHAR(p_end_date_active, 'DD-MON-YYYY')||' '||
                                   TO_CHAR(p_base_end_datetime, 'HH24:MI:SS'),
                                   'DD-MON-YYYY HH24:MI:SS');

      CAC_VIEW_UTIL_PVT.AdjustForTimezone
      ( p_source_tz_id     => p_source_tz_id
      , p_dest_tz_id       => p_dest_tz_id
      , p_source_day_time  => l_repeat_start_date
      , x_dest_day_time    => x_start_date_active
      );

      CAC_VIEW_UTIL_PVT.AdjustForTimezone
      ( p_source_tz_id     => p_source_tz_id
      , p_dest_tz_id       => p_dest_tz_id
      , p_source_day_time  => l_repeat_end_date
      , x_dest_day_time    => x_end_date_active
      );

      -- Adjust the day of the week
      ADJUST_DAYS(l_difference
                 ,p_sunday
                 ,p_monday
                 ,p_tuesday
                 ,p_wednesday
                 ,p_thursday
                 ,p_friday
                 ,p_saturday
                 ,x_sunday
                 ,x_monday
                 ,x_tuesday
                 ,x_wednesday
                 ,x_thursday
                 ,x_friday
                 ,x_saturday
      );

      IF p_date_of_month IS NOT NULL THEN
         x_date_of_month := TO_NUMBER(TO_CHAR(l_converted_basetime, 'DD'));
      END IF;

      -- Adjust the occuring month
      IF p_occurs_month IS NOT NULL THEN
         l_difference := TO_NUMBER(TO_CHAR(l_converted_basetime, 'MM'))
                          - TO_NUMBER(TO_CHAR(p_base_start_datetime, 'MM'));
         x_occurs_month := p_occurs_month + l_difference;
      END IF;

      -- Adjust occurs_which
      IF p_occurs_which IS NOT NULL AND p_occurs_which <> 0 THEN
         x_occurs_which := CEIL(TO_NUMBER(TO_CHAR(l_converted_basetime, 'DD'))/7);
         IF x_occurs_which = 5
         THEN
            x_occurs_which := 99;
         END IF;
      END IF;

   END ADJUST_RECUR_RULE_FOR_TIMEZONE;

   FUNCTION GET_DURATION_MEANING (p_lookup_code IN VARCHAR2)
   RETURN VARCHAR2
   IS
       CURSOR c_uom (b_lookup_code VARCHAR2) IS
       SELECT meaning
         FROM fnd_lookups
        WHERE lookup_type = 'CAC_VIEW_DURATION'
          AND lookup_code = b_lookup_code
          AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                                 AND TRUNC(NVL(end_date_active, SYSDATE));

       rec_uom   c_uom%ROWTYPE;
   BEGIN
       OPEN c_uom (p_lookup_code);
       FETCH c_uom INTO rec_uom;
       CLOSE c_uom;

       RETURN rec_uom.meaning;
   END GET_DURATION_MEANING;

   FUNCTION GET_DURATION_DESCRIPTION (p_duration IN NUMBER)
   RETURN VARCHAR2
   IS
       l_week NUMBER;
       l_day NUMBER;
       l_hr NUMBER;
       l_min NUMBER;
       l_dur NUMBER;

       l_code VARCHAR2(80);
       l_result_text VARCHAR2(500);
   BEGIN

       l_week := FLOOR(p_duration / (60*24*7));

       l_dur := p_duration - l_week*7*60*24;
       l_day := FLOOR(l_dur / (60*24));

       l_dur := l_dur - l_day*60*24;
       l_hr  := FLOOR(l_dur / 60);

       l_dur := l_dur - l_hr*60;
       l_min := l_dur;

       l_result_text := NULL;

       IF l_week > 0 THEN
           IF l_week = 1 THEN
               l_code := 'WEK';
           ELSE
               l_code := 'WEKS';
           END IF;

           l_result_text := l_week ||' '|| get_duration_meaning(l_code);
       END IF;

       IF l_day > 0 THEN
           IF l_day = 1 THEN
           	   l_code := 'DAY';
           ELSE
               l_code := 'DAYS';
           END IF;

           IF l_result_text IS NULL THEN
               l_result_text := l_day ||' '|| get_duration_meaning(l_code);
           ELSE
               l_result_text := l_result_text ||' '|| l_day ||' '|| get_duration_meaning(l_code);
           END IF;
       END IF;

       IF l_hr > 0 THEN
           IF l_hr = 1 THEN
           	   l_code := 'HR';
           ELSE
               l_code := 'HRS';
           END IF;

           IF l_result_text IS NULL THEN
               l_result_text := l_hr ||' '|| get_duration_meaning(l_code);
           ELSE
               l_result_text := l_result_text ||' '|| l_hr ||' '|| get_duration_meaning(l_code);
           END IF;
       END IF;

       IF l_min > 0 THEN
       	   l_code := 'MINS';

           IF l_result_text IS NULL THEN
               l_result_text := l_min ||' '|| get_duration_meaning(l_code);
           ELSE
               l_result_text := l_result_text ||' '|| l_min ||' '|| get_duration_meaning(l_code);
           END IF;
       END IF;

       RETURN l_result_text;
   END GET_DURATION_DESCRIPTION;

END CAC_VIEW_UTIL_PVT;

/
