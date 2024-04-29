--------------------------------------------------------
--  DDL for Package Body CAC_VIEW_ACC_DAILY_VIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_VIEW_ACC_DAILY_VIEW_PVT" as
/* $Header: caccadvb.pls 120.6 2008/01/18 09:21:42 anangupt ship $ */
/*======================================================================+
|  Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
|                All rights reserved.                                   |
+=======================================================================+
| FILENAME                                                              |
|      jtfcadvb.pls                                                     |
|                                                                       |
| DESCRIPTION                                                           |
|      This package is used for accessbility daily view                 |
|                                                                       |
| NOTES                                                                 |
|                                                                       |
|                                                                       |
| Date         Developer        Change                                  |
| -----------  ---------------  --------------------------------------- |
| 07-Oct-2003  Chan-Ik Jang     Created                                 |
| 23-Jan-2003  Chan-Ik Jang     Added get_related_items                 |
| 28-Jan-2003  Chan-Ik Jang     Added get_event_for_detail              |
| 05-Jan-2003  Chan-Ik Jang     Fix the incorrect preference name in    |
|                                get_prefix_type                        |
| 10-Jan-2003  Chan-Ik Jang     Fix the bug 3433268                     |
|                                - make_sentence_weekly                 |
|                                - make_sentence_monthly                |
|                                - make_sentence_yearly                 |
| 30-Apr-2004  Chan-Ik Jang     Fix the bug 3600455                     |
| 08-Jun-2004  Chan-Ik Jang     Fix the bug 3667531                     |
*=======================================================================*/

    /* -----------------------------------------------------------------
     * -- Function Name: get_start_time
     * -- Description  : This function extracts only time portion of start
     * --                dates and returns the time as format
     * --                'HH12:MI AM'
     * -- Parameter    : p_start_date = Start Date
     *                   p_end_date   = End Date
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_start_time(p_start_date IN DATE
                           ,p_end_date IN DATE)
    RETURN VARCHAR2
    IS
        l_duration NUMBER;
        l_start_time VARCHAR2(80);
    BEGIN
        l_duration := (p_end_date - p_start_date)*24*60;
        IF l_duration IN (0, 1439) THEN
            fnd_message.set_name('JTF','CAC_VIEW_APT_ALL_DAY');
            l_start_time := fnd_message.get;
        ELSE
            l_start_time := TO_CHAR(p_start_date, 'HH12:MI AM');
        END IF;

        RETURN l_start_time;
    END;

    /* -----------------------------------------------------------------
     * -- Function Name: get_client_date
     * -- Description  : This function is used to convert source timezone
     * --                to client timezone defined currently.
     * -- Parameter    : p_server_date = Date for server date
     * --                p_source_timezone_id = Source Timezone Id
     * -- Return Type  : DATE
     * -----------------------------------------------------------------*/
    FUNCTION get_client_date(p_server_date IN DATE
                            ,p_source_timezone_id IN NUMBER)
    RETURN DATE
    IS
        l_client_timezone_id NUMBER;
        l_client_date DATE;
    BEGIN
        l_client_timezone_id := TO_NUMBER(NVL(FND_PROFILE.VALUE('CLIENT_TIMEZONE_ID'),4));

        CAC_VIEW_UTIL_PVT.AdjustForTimezone
        (p_source_tz_id     => p_source_timezone_id
        ,p_dest_tz_id       => l_client_timezone_id
        ,p_source_day_time  => p_server_date
        ,x_dest_day_time    => l_client_date
        );

        RETURN l_client_date;

    END get_client_date;

    /* -----------------------------------------------------------------
     * -- Function Name: get_start_date
     * -- Description  : This function determines valid start date among
     * --                various dates and returns the date
     * -- Parameter    : p_source_object_type_code = Source object Type Code
     *                   p_date_selected           = Date type selected
     *                   p_planned_start_date      = Planned start date
     *                   p_scheduled_start_date    = Scheduled start date
     *                   p_actual_start_date       = Actual start date
     *                   p_calendar_start_date     = Calendar start date
     * -- Return Type  : DATE
     * -----------------------------------------------------------------*/
    FUNCTION get_start_date(p_source_object_type_code IN VARCHAR2
                           ,p_date_selected IN VARCHAR2
                           ,p_planned_start_date IN DATE
                           ,p_scheduled_start_date IN DATE
                           ,p_actual_start_date IN DATE
                           ,p_calendar_start_date IN DATE
                           )
    RETURN DATE
    IS
        l_start_date DATE;
    BEGIN
        IF p_source_object_type_code = 'APPOINTMENT' THEN
            l_start_date := p_calendar_start_date;
        ELSIF p_date_selected = 'P' THEN
            l_start_date := p_planned_start_date;
        ELSIF p_date_selected = 'S' THEN
            l_start_date := p_scheduled_start_date;
        ELSIF p_date_selected = 'A' THEN
            l_start_date := p_actual_start_date;
        ELSIF p_date_selected = 'D' THEN
            l_start_date := p_calendar_start_date;
        ELSIF p_date_selected IS NULL THEN
            l_start_date := p_planned_start_date;
        END IF;

        RETURN l_start_date;
    END get_start_date;

    /* -----------------------------------------------------------------
     * -- Function Name: get_end_date
     * -- Description  : This function determines valid end date among
     * --                various dates and returns the date
     * -- Parameter    : p_source_object_type_code = Source object Type Code
     *                   p_date_selected           = Date type selected
     *                   p_planned_end_date        = Planned end date
     *                   p_scheduled_end_date      = Scheduled end date
     *                   p_actual_end_date         = Actual end date
     *                   p_calendar_end_date       = Calendar end date
     * -- Return Type  : DATE
     * -----------------------------------------------------------------*/
    FUNCTION get_end_date(p_source_object_type_code IN VARCHAR2
                         ,p_date_selected IN VARCHAR2
                         ,p_planned_end_date IN DATE
                         ,p_scheduled_end_date IN DATE
                         ,p_actual_end_date IN DATE
                         ,p_calendar_end_date IN DATE
                         )
    RETURN DATE
    IS
        l_end_date DATE;
    BEGIN
        IF p_source_object_type_code = 'APPOINTMENT' THEN
            l_end_date := p_calendar_end_date;
        ELSIF p_date_selected = 'P' THEN
            l_end_date := p_planned_end_date;
        ELSIF p_date_selected = 'S' THEN
            l_end_date := p_scheduled_end_date;
        ELSIF p_date_selected = 'A' THEN
            l_end_date := p_actual_end_date;
        ELSIF p_date_selected = 'D' THEN
            l_end_date := p_calendar_end_date;
        ELSIF p_date_selected IS NULL THEN
            l_end_date := p_planned_end_date;
        END IF;

        RETURN l_end_date;
    END get_end_date;

    /* -----------------------------------------------------------------
     * -- Function Name: get_duration
     * -- Description  : This function determines duration and returns
     * --                the duration in unit of minutes.
     * -- Parameter    : p_source_object_type_code = Source object Type Code
     *                   p_date_selected           = Date type selected
     *                   p_planned_start_date      = Planned start date
     *                   p_planned_end_date        = Planned end date
     *                   p_scheduled_start_date    = Scheduled start date
     *                   p_scheduled_end_date      = Scheduled end date
     *                   p_actual_start_date       = Actual start date
     *                   p_actual_end_date         = Actual end date
     *                   p_calendar_start_date     = Calendar start date
     *                   p_calendar_end_date       = Calendar end date
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_duration(p_source_object_type_code IN VARCHAR2
                         ,p_date_selected IN VARCHAR2
                         ,p_planned_start_date IN DATE
                         ,p_planned_end_date IN DATE
                         ,p_scheduled_start_date IN DATE
                         ,p_scheduled_end_date IN DATE
                         ,p_actual_start_date IN DATE
                         ,p_actual_end_date IN DATE
                         ,p_calendar_start_date IN DATE
                         ,p_calendar_end_date IN DATE
                         )
    RETURN VARCHAR2
    IS
        l_start_date DATE;
        l_end_date DATE;
        l_min NUMBER;
    BEGIN
        l_start_date := get_start_date(p_source_object_type_code => p_source_object_type_code
                                      ,p_date_selected           => p_date_selected
                                      ,p_planned_start_date      => p_planned_start_date
                                      ,p_scheduled_start_date    => p_scheduled_start_date
                                      ,p_actual_start_date       => p_actual_start_date
                                      ,p_calendar_start_date     => p_calendar_start_date
                                      );
        l_end_date := get_end_date(p_source_object_type_code => p_source_object_type_code
                                  ,p_date_selected           => p_date_selected
                                  ,p_planned_end_date        => p_planned_end_date
                                  ,p_scheduled_end_date      => p_scheduled_end_date
                                  ,p_actual_end_date         => p_actual_end_date
                                  ,p_calendar_end_date       => p_calendar_end_date
                                  );

        l_min := round((l_end_date - l_start_date)*24*60,1);
        IF l_min = 0 AND
           trunc(l_start_date) = l_start_date AND
           trunc(l_end_date) = l_end_date THEN
            l_min := 1440;
        END IF;

        RETURN to_duration(l_min);
    END get_duration;

    /* -----------------------------------------------------------------
     * -- Function Name: to_duration
     * -- Description  : This function returns the descriptive duration
     * --                string, ex. 30 Minutes.
     * -- Parameter    : p_duration_min = Duration in minutes
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION to_duration(p_duration_min IN NUMBER)
    RETURN VARCHAR2
    IS
        l_hour NUMBER;
        l_min NUMBER;

        l_hour_text VARCHAR2(240);
        l_min_text VARCHAR2(240);

        CURSOR c_time_uom (b_code VARCHAR2) IS
        SELECT meaning
          FROM fnd_lookups
         WHERE lookup_type = 'CAC_VIEW_DURATION'
           AND lookup_code = b_code;

        l_min_code VARCHAR2(10);
        l_hour_code VARCHAR2(10);

        l_duration VARCHAR2(240);
    BEGIN
        l_min := mod(p_duration_min, 60);
        l_hour := (p_duration_min - l_min)/60;

        IF l_min > 1 THEN
          l_min_code := 'MINS';
        ELSE
          l_min_code := 'MIN';
        END IF;

        IF l_hour > 1 THEN
          l_hour_code := 'HRS';
        ELSIF l_hour = 1 THEN
          l_hour_code := 'HR';
        ELSE
          l_hour_code := NULL;
        END IF;

        OPEN c_time_uom (l_min_code);
        FETCH c_time_uom
         INTO l_min_text;

        IF c_time_uom%NOTFOUND THEN
            l_min_text := 'Minutes';
        END IF;

        CLOSE c_time_uom;

        IF NVL(l_min,0) > 0 THEN
            l_duration := l_min  || ' ' || l_min_text;
        END IF;

        IF l_hour_code IS NOT NULL THEN
            OPEN c_time_uom (l_hour_code);
            FETCH c_time_uom
             INTO l_hour_text;

            IF c_time_uom%NOTFOUND THEN
                l_hour_text := 'Hours';
            END IF;

            CLOSE c_time_uom;

            l_duration := l_hour || ' ' || l_hour_text ||' '|| l_duration;
        END IF;

        RETURN l_duration;
    END to_duration;

    /* -----------------------------------------------------------------
     * -- Function Name: get_reminder
     * -- Description  : This function returns the descriptive reminder
     * --                string, ex. 30 Minutes Before.
     * --                Currently the following minutes defined in the
     * --                lookup type JTF_CALND_REMIND_ME are supported.
     * --
     * --                Minute  Reminder Text
     * --                ------- ------------------
     * --                0       Do Not Remind Me
     * --                5       5 Minutes Before
     * --                10      10 Minutes Before
     * --                15      15 Minutes Before
     * --                30      30 Minutes Before
     * --                60      1 Hour Before
     * --                120     2 Hours Before
     * --                1440    1 Day Before
     * --                2880    2 Days Before
     * --                4320    3 Days Before
     * --                10080   1 Week Before
     * --
     * -- Parameter    : p_reminder_min = Reminder in minutes
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_reminder(p_reminder_min IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_reminder (b_min VARCHAR2) IS
        SELECT meaning
          FROM fnd_lookups
         WHERE lookup_type = 'JTF_CALND_REMIND_ME'
           AND lookup_code = b_min;

        l_reminder VARCHAR2(30);
        l_reminder_string VARCHAR2(240);
    BEGIN
        IF p_reminder_min IS NULL THEN
            l_reminder := '0';
        ELSE
            l_reminder := TO_CHAR(p_reminder_min);
        END IF;

        OPEN c_reminder (l_reminder);
        FETCH c_reminder
         INTO l_reminder_string;

        IF c_reminder%NOTFOUND THEN
            l_reminder_string := NULL;
        END IF;

        CLOSE c_reminder;

	if l_reminder_string is null and p_reminder_min is not null
        then
        l_reminder_string := CAC_VIEW_UTIL_PVT.get_reminder_description(p_reminder_min);
        end if;

        RETURN l_reminder_string;
    END get_reminder;

    /* -----------------------------------------------------------------
     * -- Function Name: get_reminder
     * -- Description  : This function returns the descriptive reminder
     * --                string according to reminder unit of measuure.
     * --
     * -- Parameter    : p_reminder = if p_reminder_uom is null,
     * --                              this is considered as minute
     * --                p_reminder_uom = Unit of Measure for reminder
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_reminder(p_reminder IN NUMBER
                         ,p_reminder_uom IN VARCHAR2)
    RETURN VARCHAR2
    IS
        l_reminder_minute NUMBER;
    BEGIN
        IF p_reminder_uom IS NULL THEN
            l_reminder_minute := p_reminder;

        ELSIF p_reminder_uom = 'DAY' THEN
            l_reminder_minute := p_reminder * 24*60;

        ELSIF p_reminder_uom = 'HOUR' THEN
            l_reminder_minute := p_reminder * 60;

        ELSE
            l_reminder_minute := p_reminder;
        END IF;

        RETURN get_reminder(p_reminder_min => l_reminder_minute);
    END get_reminder;

    /* -----------------------------------------------------------------
     * -- Function Name: get_reminder
     * -- Description  : This function returns the descriptive reminder
     * --                string according to task_id
     * --
     * -- Parameter    : p_task_id = primary key of task table
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_reminder(p_task_id IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_task IS
        SELECT alarm_start
             , alarm_start_uom
          FROM jtf_tasks_b
         WHERE task_id = p_task_id;

        l_reminder NUMBER;
        l_reminder_uom VARCHAR2(30);
        l_reminder_string VARCHAR2(240);
    BEGIN
        OPEN c_task;
        FETCH c_task INTO l_reminder, l_reminder_uom;

        IF c_task%FOUND THEN
            l_reminder_string := get_reminder(l_reminder, l_reminder_uom);
        ELSE
            l_reminder_string := NULL;
        END IF;
        CLOSE c_task;

        RETURN l_reminder_string;
    END get_reminder;

    /* -----------------------------------------------------------------
     * -- Function Name: get_attendees
     * -- Description  : This function returns the list of attendees.
     * --                The attendee names are concatenated as a string.
     * -- Parameter    : p_task_id = Task Id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_attendees(p_task_id IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_attendees IS
        SELECT source_first_name||' '||source_last_name attendee_name
          FROM jtf_rs_resource_extns rs
             , jtf_task_all_assignments jta
         WHERE jta.resource_type_code = 'RS_EMPLOYEE'
           AND jta.assignee_role = 'ASSIGNEE'
           AND jta.task_id = p_task_id
           AND rs.category = 'EMPLOYEE'
           AND rs.resource_id = jta.resource_id
        UNION
        SELECT source_first_name||' '||source_last_name attendee_name
          FROM jtf_rs_resource_extns rs
             , jtf_rs_group_members rg
             , jtf_task_all_assignments jta
         WHERE jta.resource_type_code = 'RS_GROUP'
           AND jta.assignee_role = 'ASSIGNEE'
           AND jta.task_id = p_task_id
           AND rg.group_id = jta.resource_id
           AND rs.resource_id = rg.resource_id
        UNION
        SELECT source_first_name||' '||source_last_name attendee_name
          FROM jtf_rs_resource_extns rs
             , jtf_rs_team_members rt_ind
             , jtf_task_all_assignments jta
         WHERE jta.resource_type_code = 'RS_TEAM'
           AND jta.assignee_role = 'ASSIGNEE'
           AND jta.task_id = p_task_id
           AND rt_ind.team_id = jta.resource_id
           AND rt_ind.resource_type = 'INDIVIDUAL'
           AND rs.resource_id = rt_ind.team_resource_id
        UNION
        SELECT source_first_name||' '||source_last_name attendee_name
          FROM jtf_rs_resource_extns rs
             , jtf_rs_group_members rg
             , jtf_rs_team_members rt_grp
             , jtf_task_all_assignments jta
         WHERE jta.resource_type_code = 'RS_TEAM'
           AND jta.assignee_role = 'ASSIGNEE'
           AND jta.task_id = p_task_id
           AND rt_grp.team_id = jta.resource_id
           AND rt_grp.resource_type = 'GROUP'
           AND rg.group_id = rt_grp.team_resource_id
           AND rs.resource_id = rg.resource_id;

        l_attendees VARCHAR2(4000);
    BEGIN
        FOR rec IN c_attendees
        LOOP
            IF l_attendees IS NULL THEN
                l_attendees := rec.attendee_name;
            ELSE
                l_attendees := l_attendees || ', '||rec.attendee_name;
            END IF;
        END LOOP;

        RETURN l_attendees;
    END get_attendees;

    /* -----------------------------------------------------------------
     * -- Function Name: get_prefix
     * -- Description  : This function checks the preference CAC_VIEW_PREF
     * --                for the current login user and returns the prefix
     * --                defined by the user.
     * -- Parameter    : p_preference_name = Preference name
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_prefix(p_preference_name IN VARCHAR2)
    RETURN VARCHAR2
    IS
        CURSOR c_prefix IS
        SELECT preference_value
          FROM fnd_user_preferences
         WHERE user_name = fnd_global.user_name
           AND module_name = 'CAC_VIEW_PREF'
           AND preference_name = p_preference_name;

        l_prefix VARCHAR2(240);
    BEGIN
        OPEN c_prefix;
        FETCH c_prefix INTO l_prefix;
        CLOSE c_prefix;

        RETURN l_prefix;
    END get_prefix;

    /* -----------------------------------------------------------------
     * -- Function Name: get_prefix_type (Private Function)
     * -- Description  : This function returns the corresponding preference
     * --                name for the given object code and assignment status id.
     * --                There are four preference names supported.
     * --                 CAC_VWS_APPT_INV_PREFIX - Prefix for invitation.
     * --                 CAC_VWS_APPT_DECL_PREFIX - Prefix for decliend invitation.
     * --                 CAC_VWS_APPT_PREFIX - Prefix for normal appointment.
     * --                 CAC_VWS_TASK_PREFIX - Prefix for task.
     * -- Parameter    : p_object_code = object code
     * --                p_assignment_status_id = Assignment status id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_prefix_type (p_object_code IN VARCHAR2
                             ,p_assignment_status_id IN NUMBER)
    RETURN VARCHAR2
    IS
        l_preference_name VARCHAR2(240);
    BEGIN
        IF p_object_code = 'APPOINTMENT' THEN
            IF p_assignment_status_id = 18 THEN
                l_preference_name := 'CAC_VWS_APPT_INV_PREFIX';
            ELSIF p_assignment_status_id = 4 THEN
                l_preference_name := 'CAC_VWS_APPT_DECL_PREFIX';
            ELSE
                l_preference_name := 'CAC_VWS_APPT_PREFIX';
            END IF;
        ELSE
            l_preference_name := 'CAC_VWS_TASK_PREFIX';
        END IF;

        RETURN l_preference_name;
    END get_prefix_type;

    /* -----------------------------------------------------------------
     * -- Function Name: get_subject
     * -- Description  : This function returns the subject along with the prefix
     * --                for event data.
     * -- Parameter    : p_source_code = Source Object Code
     * --                p_source_id   = Source Object Id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_subject(p_source_code IN VARCHAR2
                        ,p_source_id   IN NUMBER)
    RETURN VARCHAR2
    IS
        l_object_name VARCHAR2(240);
        l_prefix VARCHAR2(240);
        l_subject VARCHAR2(240);
    BEGIN
        l_object_name := jtf_task_utl.get_owner(p_object_type_code => p_source_code
                                               ,p_object_id => p_source_id);
        l_prefix := get_prefix(p_preference_name => 'CAC_VWS_EVENT_PREFIX');

        l_subject := l_object_name;
        IF l_prefix IS NOT NULL THEN
            l_subject := l_prefix || ' ' || l_subject;
        END IF;

        RETURN l_subject;
    END get_subject;

    /* -----------------------------------------------------------------
     * -- Function Name: get_subject
     * -- Description  : This function returns the subject along with the prefix
     * --                for appointments.
     * -- Parameter    : p_object_code   = Object Code
     * --                p_object_name   = Object Name
     * --                p_task_id       = Task Id
     * --                p_resource_id   = Resource Id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_subject(p_object_code IN VARCHAR2
                        ,p_object_name IN VARCHAR2
                        ,p_task_id     IN NUMBER
                        ,p_resource_id IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_assignment IS
        SELECT assignment_status_id
          FROM jtf_task_all_assignments
         WHERE task_id = p_task_id
           AND resource_type_code = 'RS_EMPLOYEE'
           AND resource_id = p_resource_id;

        l_assignment_status_id NUMBER;
        l_prefix VARCHAR2(240);
        l_subject VARCHAR2(240);
    BEGIN
        OPEN c_assignment;
        FETCH c_assignment INTO l_assignment_status_id;
        CLOSE c_assignment;

        l_prefix := get_prefix(get_prefix_type(p_object_code => p_object_code
                                              ,p_assignment_status_id => l_assignment_status_id));
        l_subject := p_object_name;
        IF l_prefix IS NOT NULL THEN
            l_subject := l_prefix || ' ' || l_subject;
        END IF;

        RETURN l_subject;
    END get_subject;

    /* -----------------------------------------------------------------
     * -- Function Name: get_weekdays (Private Function)
     * -- Description  : This function returns the descriptive weekdays
     * --                as string.
     * -- Parameter    : p_sunday    = Sunday, Y/N
     * --                p_monday    = Monday, Y/N
     * --                p_tuesday   = Tuesday, Y/N
     * --                p_wednesday = Wednesday, Y/N
     * --                p_thursday  = Thursday, Y/N
     * --                p_friday    = Friday, Y/N
     * --                p_saturday  = Saturday, Y/N
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_weekdays(p_sunday        IN VARCHAR2
                         ,p_monday        IN VARCHAR2
                         ,p_tuesday       IN VARCHAR2
                         ,p_wednesday     IN VARCHAR2
                         ,p_thursday      IN VARCHAR2
                         ,p_friday        IN VARCHAR2
                         ,p_saturday      IN VARCHAR2)
    RETURN VARCHAR2
    IS
        CURSOR c_weekdays IS
        SELECT meaning
          FROM fnd_lookups
         WHERE lookup_type = 'JTF_CALND_WEEKDAYS'
           AND ( (lookup_code = decode(NVL(p_sunday,'N'),   'Y','1','0')) OR
                 (lookup_code = decode(NVL(p_monday,'N'),   'Y','2','0')) OR
                 (lookup_code = decode(NVL(p_tuesday,'N'),  'Y','3','0')) OR
                 (lookup_code = decode(NVL(p_wednesday,'N'),'Y','4','0')) OR
                 (lookup_code = decode(NVL(p_thursday,'N'), 'Y','5','0')) OR
                 (lookup_code = decode(NVL(p_friday,'N'),   'Y','6','0')) OR
                 (lookup_code = decode(NVL(p_saturday,'N'), 'Y','7','0'))
               )
        ORDER BY lookup_code;

        l_weekdays VARCHAR2(240);
    BEGIN
        FOR rec IN c_weekdays LOOP
            IF l_weekdays IS NULL THEN
                l_weekdays := rec.meaning;
            ELSE
                l_weekdays := l_weekdays ||', '|| rec.meaning;
            END IF;
        END LOOP;

        RETURN l_weekdays;
    END get_weekdays;

    /* -----------------------------------------------------------------
     * -- Function Name: get_occurs_month (Private Function)
     * -- Description  : This function returns the descriptive month
     * --                as string, ex. March
     * -- Parameter    : p_occurs_month = Month as number
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_occurs_month(p_occurs_month IN NUMBER)
    RETURN VARCHAR2
    IS
        l_month_var VARCHAR2(80);
    BEGIN
        SELECT to_char(to_date('2000-'||to_char(p_occurs_month,'09')||'-01', 'YYYY-MM-DD'),'Month')
          INTO l_month_var
          FROM dual;

        RETURN rtrim(l_month_var);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END get_occurs_month;

    /* -----------------------------------------------------------------
     * -- Function Name: make_sentence_daily (Private Function)
     * -- Description  : This function returns the repating information
     * --                as string when it repeats daily.
     * -- Parameter    : p_occurs_every = Ocurrences Frequencies
     * --                p_occurs_number= The maximum number of occurrences
     * --                p_end_date     = The date the occurrences ends
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION make_sentence_daily(p_occurs_every  IN NUMBER
                                ,p_occurs_number IN NUMBER
                                ,p_end_date      IN DATE
                                ,p_timezone      IN VARCHAR2)
    RETURN VARCHAR2
    IS
    BEGIN
        IF p_occurs_number IS NOT NULL THEN
            IF p_occurs_every = 1 THEN
                fnd_message.set_name('JTF', 'CAC_VIEW_DAILY_REPEAT_4');
                fnd_message.set_token('OCCURS_NUMBER', p_occurs_number);
            ELSE
                fnd_message.set_name('JTF', 'CAC_VIEW_DAILY_REPEAT_2');
                fnd_message.set_token('OCCURS_EVERY', p_occurs_every);
                fnd_message.set_token('OCCURS_NUMBER', p_occurs_number);
            END IF;
        ELSE
            IF p_occurs_every = 1 THEN
                fnd_message.set_name('JTF', 'CAC_VIEW_DAILY_REPEAT_3');
                fnd_message.set_token('END_DATE', p_end_date);
            ELSE
                fnd_message.set_name('JTF', 'CAC_VIEW_DAILY_REPEAT_1');
                fnd_message.set_token('OCCURS_EVERY', p_occurs_every);
                fnd_message.set_token('END_DATE', p_end_date);
            END IF;
        END IF;
        fnd_message.set_token('TIMEZONE', p_timezone);

        RETURN fnd_message.get;
    END make_sentence_daily;

    /* -----------------------------------------------------------------
     * -- Function Name: make_sentence_weekly (Private Function)
     * -- Description  : This function returns the repating information
     * --                as string when it repeats weekly.
     * -- Parameter    : p_occurs_every = Ocurrences Frequencies
     * --                p_occurs_number= The maximum number of occurrences
     * --                p_end_date     = The date the occurrences ends
     * --                p_sunday       = Sunday, Y/N
     * --                p_monday       = Monday, Y/N
     * --                p_tuesday      = Tuesday, Y/N
     * --                p_wednesday    = Wednesday, Y/N
     * --                p_thursday     = Thursday, Y/N
     * --                p_friday       = Friday, Y/N
     * --                p_saturday     = Saturday, Y/N
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION make_sentence_weekly(p_occurs_every  IN NUMBER
                                 ,p_occurs_number IN NUMBER
                                 ,p_end_date      IN DATE
                                 ,p_sunday        IN VARCHAR2
                                 ,p_monday        IN VARCHAR2
                                 ,p_tuesday       IN VARCHAR2
                                 ,p_wednesday     IN VARCHAR2
                                 ,p_thursday      IN VARCHAR2
                                 ,p_friday        IN VARCHAR2
                                 ,p_saturday      IN VARCHAR2
                                 ,p_timezone      IN VARCHAR2)
    RETURN VARCHAR2
    IS
        l_weekdays VARCHAR2(240);
    BEGIN
        l_weekdays := get_weekdays(p_sunday    => p_sunday
                                  ,p_monday    => p_monday
                                  ,p_tuesday   => p_tuesday
                                  ,p_wednesday => p_wednesday
                                  ,p_thursday  => p_thursday
                                  ,p_friday    => p_friday
                                  ,p_saturday  => p_saturday);

        IF p_occurs_number IS NOT NULL THEN
            IF p_occurs_every = 1 THEN
                fnd_message.set_name('JTF', 'CAC_VIEW_WEEKLY_REPEAT_4');
                fnd_message.set_token('WHICH_DAYS', l_weekdays);
                fnd_message.set_token('OCCURS_NUMBER', p_occurs_number);
            ELSE
                fnd_message.set_name('JTF', 'CAC_VIEW_WEEKLY_REPEAT_2');
                fnd_message.set_token('OCCURS_EVERY', p_occurs_every);
                fnd_message.set_token('WHICH_DAYS', l_weekdays);
                fnd_message.set_token('OCCURS_NUMBER', p_occurs_number);
            END IF;
        ELSE
            IF p_occurs_every = 1 THEN
                fnd_message.set_name('JTF', 'CAC_VIEW_WEEKLY_REPEAT_3');
                fnd_message.set_token('WHICH_DAYS', l_weekdays);
                fnd_message.set_token('END_DATE', p_end_date);
            ELSE
                fnd_message.set_name('JTF', 'CAC_VIEW_WEEKLY_REPEAT_1');
                fnd_message.set_token('OCCURS_EVERY', p_occurs_every);
                fnd_message.set_token('WHICH_DAYS', l_weekdays);
                fnd_message.set_token('END_DATE', p_end_date);
            END IF;
        END IF;
        fnd_message.set_token('TIMEZONE', p_timezone);

        RETURN fnd_message.get;
    END make_sentence_weekly;

    /* -----------------------------------------------------------------
     * -- Function Name: make_sentence_monthly (Private Function)
     * -- Description  : This function returns the repating information
     * --                as string when it repeats monthly.
     * -- Parameter    : p_occurs_every = Ocurrences Frequencies
     * --                p_occurs_number= The maximum number of occurrences
     * --                p_date_of_month= The date which occurs every month
     * --                p_occurs_which = The position of the week
     * --                p_end_date     = The date the occurrences ends
     * --                p_sunday       = Sunday, Y/N
     * --                p_monday       = Monday, Y/N
     * --                p_tuesday      = Tuesday, Y/N
     * --                p_wednesday    = Wednesday, Y/N
     * --                p_thursday     = Thursday, Y/N
     * --                p_friday       = Friday, Y/N
     * --                p_saturday     = Saturday, Y/N
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION make_sentence_monthly(p_occurs_every  IN NUMBER
                                  ,p_occurs_number IN NUMBER
                                  ,p_date_of_month IN NUMBER
                                  ,p_occurs_which  IN NUMBER
                                  ,p_end_date      IN DATE
                                  ,p_sunday        IN VARCHAR2
                                  ,p_monday       IN VARCHAR2
                                  ,p_tuesday      IN VARCHAR2
                                  ,p_wednesday    IN VARCHAR2
                                  ,p_thursday     IN VARCHAR2
                                  ,p_friday       IN VARCHAR2
                                  ,p_saturday     IN VARCHAR2
                                  ,p_timezone     IN VARCHAR2)
    RETURN VARCHAR2
    IS
        CURSOR c_occurs_which IS
        SELECT lower(meaning)
          FROM fnd_lookups
         WHERE lookup_type = 'JTF_TASK_RECUR_OCCURS'
           AND lookup_code = p_occurs_which;

        l_weekdays VARCHAR2(240);
        l_occurs_which VARCHAR2(100);
    BEGIN
        l_weekdays := get_weekdays(p_sunday    => p_sunday
                                  ,p_monday    => p_monday
                                  ,p_tuesday   => p_tuesday
                                  ,p_wednesday => p_wednesday
                                  ,p_thursday  => p_thursday
                                  ,p_friday    => p_friday
                                  ,p_saturday  => p_saturday);

        OPEN c_occurs_which;
        FETCH c_occurs_which INTO l_occurs_which;
        CLOSE c_occurs_which;

        IF p_date_of_month IS NOT NULL THEN
            IF p_occurs_number IS NOT NULL THEN
                IF p_occurs_every = 1 THEN
                    fnd_message.set_name('JTF', 'CAC_VIEW_MONTHLY_REPEAT_6');
                    fnd_message.set_token('DATE_OF_MONTH', p_date_of_month);
                    fnd_message.set_token('OCCURS_NUMBER', p_occurs_number);
                ELSE
                    fnd_message.set_name('JTF', 'CAC_VIEW_MONTHLY_REPEAT_2');
                    fnd_message.set_token('OCCURS_EVERY', p_occurs_every);
                    fnd_message.set_token('DATE_OF_MONTH', p_date_of_month);
                    fnd_message.set_token('OCCURS_NUMBER', p_occurs_number);
                END IF;
            ELSE
                IF p_occurs_every = 1 THEN
                    fnd_message.set_name('JTF', 'CAC_VIEW_MONTHLY_REPEAT_5');
                    fnd_message.set_token('DATE_OF_MONTH', p_date_of_month);
                    fnd_message.set_token('END_DATE', p_end_date);
                ELSE
                    fnd_message.set_name('JTF', 'CAC_VIEW_MONTHLY_REPEAT_1');
                    fnd_message.set_token('OCCURS_EVERY', p_occurs_every);
                    fnd_message.set_token('DATE_OF_MONTH', p_date_of_month);
                    fnd_message.set_token('END_DATE', p_end_date);
                END IF;
            END IF;
        ELSE
            IF p_occurs_number IS NOT NULL THEN
                IF p_occurs_every = 1 THEN
                    fnd_message.set_name('JTF', 'CAC_VIEW_MONTHLY_REPEAT_8');
                    fnd_message.set_token('OCCURS_WHICH', l_occurs_which);
                    fnd_message.set_token('WHICH_DAYS', l_weekdays);
                    fnd_message.set_token('OCCURS_NUMBER', p_occurs_number);
                ELSE
                    fnd_message.set_name('JTF', 'CAC_VIEW_MONTHLY_REPEAT_4');
                    fnd_message.set_token('OCCURS_EVERY', p_occurs_every);
                    fnd_message.set_token('OCCURS_WHICH', l_occurs_which);
                    fnd_message.set_token('WHICH_DAYS', l_weekdays);
                    fnd_message.set_token('OCCURS_NUMBER', p_occurs_number);
                END IF;
            ELSE
                IF p_occurs_every = 1 THEN
                    fnd_message.set_name('JTF', 'CAC_VIEW_MONTHLY_REPEAT_7');
                    fnd_message.set_token('OCCURS_WHICH', l_occurs_which);
                    fnd_message.set_token('WHICH_DAYS', l_weekdays);
                    fnd_message.set_token('END_DATE', p_end_date);
                ELSE
                    fnd_message.set_name('JTF', 'CAC_VIEW_MONTHLY_REPEAT_3');
                    fnd_message.set_token('OCCURS_EVERY', p_occurs_every);
                    fnd_message.set_token('OCCURS_WHICH', l_occurs_which);
                    fnd_message.set_token('WHICH_DAYS', l_weekdays);
                    fnd_message.set_token('END_DATE', p_end_date);
                END IF;
            END IF;
        END IF;
        fnd_message.set_token('TIMEZONE', p_timezone);

        RETURN fnd_message.get;
    END make_sentence_monthly;

    /* -----------------------------------------------------------------
     * -- Function Name: make_sentence_yearly (Private Function)
     * -- Description  : This function returns the repating information
     * --                as string when it repeats yearly.
     * -- Parameter    : p_occurs_every = Ocurrences Frequencies
     * --                p_occurs_number= The maximum number of occurrences
     * --                p_occurs_month = The month which occurs every year
     * --                p_date_of_month= The date of month which occurs every year
     * --                p_occurs_which = The position of the week
     * --                p_end_date     = The date the occurrences ends
     * --                p_sunday       = Sunday, Y/N
     * --                p_monday       = Monday, Y/N
     * --                p_tuesday      = Tuesday, Y/N
     * --                p_wednesday    = Wednesday, Y/N
     * --                p_thursday     = Thursday, Y/N
     * --                p_friday       = Friday, Y/N
     * --                p_saturday     = Saturday, Y/N
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION make_sentence_yearly(p_occurs_every  IN NUMBER
                                 ,p_occurs_number IN NUMBER
                                 ,p_occurs_month  IN NUMBER
                                 ,p_date_of_month IN NUMBER
                                 ,p_occurs_which  IN NUMBER
                                 ,p_end_date      IN DATE
                                 ,p_sunday        IN VARCHAR2
                                 ,p_monday        IN VARCHAR2
                                 ,p_tuesday       IN VARCHAR2
                                 ,p_wednesday     IN VARCHAR2
                                 ,p_thursday      IN VARCHAR2
                                 ,p_friday        IN VARCHAR2
                                 ,p_saturday      IN VARCHAR2
                                 ,p_timezone      IN VARCHAR2)
    RETURN VARCHAR2
    IS
        CURSOR c_occurs_which IS
        SELECT meaning
          FROM fnd_lookups
         WHERE lookup_type = 'JTF_TASK_RECUR_OCCURS'
           AND lookup_code = p_occurs_which;

        l_weekdays VARCHAR2(240);
        l_occurs_which VARCHAR2(100);
    BEGIN
        l_weekdays := get_weekdays(p_sunday    => p_sunday
                                  ,p_monday    => p_monday
                                  ,p_tuesday   => p_tuesday
                                  ,p_wednesday => p_wednesday
                                  ,p_thursday  => p_thursday
                                  ,p_friday    => p_friday
                                  ,p_saturday  => p_saturday);

        OPEN c_occurs_which;
        FETCH c_occurs_which INTO l_occurs_which;
        CLOSE c_occurs_which;

        IF p_date_of_month IS NOT NULL THEN
            IF p_occurs_number IS NOT NULL THEN
                IF p_occurs_every = 1 THEN
                    fnd_message.set_name('JTF', 'CAC_VIEW_YEARLY_REPEAT_6');
                    fnd_message.set_token('OCCURS_MONTH', get_occurs_month(p_occurs_month));
                    fnd_message.set_token('DATE_OF_MONTH', p_date_of_month);
                    fnd_message.set_token('OCCURS_NUMBER', p_occurs_number);
                ELSE
                    fnd_message.set_name('JTF', 'CAC_VIEW_YEARLY_REPEAT_2');
                    fnd_message.set_token('OCCURS_EVERY', p_occurs_every);
                    fnd_message.set_token('OCCURS_MONTH', get_occurs_month(p_occurs_month));
                    fnd_message.set_token('DATE_OF_MONTH', p_date_of_month);
                    fnd_message.set_token('OCCURS_NUMBER', p_occurs_number);
                END IF;
            ELSE
                IF p_occurs_every = 1 THEN
                    fnd_message.set_name('JTF', 'CAC_VIEW_YEARLY_REPEAT_5');
                    fnd_message.set_token('OCCURS_MONTH', get_occurs_month(p_occurs_month));
                    fnd_message.set_token('DATE_OF_MONTH', p_date_of_month);
                    fnd_message.set_token('END_DATE', p_end_date);
                ELSE
                    fnd_message.set_name('JTF', 'CAC_VIEW_YEARLY_REPEAT_1');
                    fnd_message.set_token('OCCURS_EVERY', p_occurs_every);
                    fnd_message.set_token('OCCURS_MONTH', get_occurs_month(p_occurs_month));
                    fnd_message.set_token('DATE_OF_MONTH', p_date_of_month);
                    fnd_message.set_token('END_DATE', p_end_date);
                END IF;
            END IF;
        ELSE
            IF p_occurs_number IS NOT NULL THEN
                IF p_occurs_every = 1 THEN
                    fnd_message.set_name('JTF', 'CAC_VIEW_YEARLY_REPEAT_8');
                    fnd_message.set_token('OCCURS_WHICH', l_occurs_which);
                    fnd_message.set_token('WHICH_DAYS', l_weekdays);
                    fnd_message.set_token('OCCURS_MONTH', get_occurs_month(p_occurs_month));
                    fnd_message.set_token('OCCURS_NUMBER', p_occurs_number);
                ELSE
                    fnd_message.set_name('JTF', 'CAC_VIEW_YEARLY_REPEAT_4');
                    fnd_message.set_token('OCCURS_EVERY', p_occurs_every);
                    fnd_message.set_token('OCCURS_WHICH', l_occurs_which);
                    fnd_message.set_token('WHICH_DAYS', l_weekdays);
                    fnd_message.set_token('OCCURS_MONTH', get_occurs_month(p_occurs_month));
                    fnd_message.set_token('OCCURS_NUMBER', p_occurs_number);
                END IF;
            ELSE
                IF p_occurs_every = 1 THEN
                    fnd_message.set_name('JTF', 'CAC_VIEW_YEARLY_REPEAT_7');
                    fnd_message.set_token('OCCURS_WHICH', l_occurs_which);
                    fnd_message.set_token('WHICH_DAYS', l_weekdays);
                    fnd_message.set_token('OCCURS_MONTH', get_occurs_month(p_occurs_month));
                    fnd_message.set_token('END_DATE', p_end_date);
                ELSE
                    fnd_message.set_name('JTF', 'CAC_VIEW_YEARLY_REPEAT_3');
                    fnd_message.set_token('OCCURS_EVERY', p_occurs_every);
                    fnd_message.set_token('OCCURS_WHICH', l_occurs_which);
                    fnd_message.set_token('WHICH_DAYS', l_weekdays);
                    fnd_message.set_token('OCCURS_MONTH', get_occurs_month(p_occurs_month));
                    fnd_message.set_token('END_DATE', p_end_date);
                END IF;
            END IF;
        END IF;
        fnd_message.set_token('TIMEZONE', p_timezone);

        RETURN fnd_message.get;
    END make_sentence_yearly;

    /* -----------------------------------------------------------------
     * -- Function Name: get_repeating
     * -- Description  : This function returns the repeating information
     * --                as string
     * -- Parameter    : p_object_type  = Ignored
     * --                p_recurrence_rule_id = recurrence rule id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
	FUNCTION get_repeating(p_object_type IN VARCHAR2
                          ,p_recurrence_rule_id IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_repeating (l_server_timezone_id NUMBER) IS
        SELECT occurs_number
             , occurs_every
             , occurs_uom
             , end_date_active
             , occurs_which
             , date_of_month
             , occurs_month
             , sunday
             , monday
             , tuesday
             , wednesday
             , thursday
             , friday
             , saturday
             , '(GMT '||to_char(trunc(gmt_offset),'S09') || ':' ||to_char(abs(gmt_offset - trunc(gmt_offset))*60,'FM900') || ') ' || name timezone_name
             , planned_end_date
          FROM jtf_task_recur_rules r
             , fnd_timezones_vl tz
             , jtf_tasks_vl j
         WHERE r.recurrence_rule_id = p_recurrence_rule_id
           AND tz.enabled_flag = 'Y'
           AND upgrade_tz_id = l_server_timezone_id
           and j.recurrence_rule_id=r.recurrence_rule_id;

        rec_repeating         c_repeating%ROWTYPE;
        l_repeating_statement VARCHAR2(1000);
        l_client_timezone_id  NUMBER;
        l_end_date            rec_repeating.end_date_active%TYPE;
        l_time_hh             NUMBER;
        l_time_mm             NUMBER;
  BEGIN
        l_client_timezone_id := TO_NUMBER(NVL(fnd_profile.value('CLIENT_TIMEZONE_ID'),'4'));


        IF p_recurrence_rule_id IS NULL THEN
            fnd_message.set_name('JTF', 'CAC_VIEW_NO_REPEAT');
            RETURN fnd_message.get;
        END IF;

        OPEN c_repeating (l_client_timezone_id);
        FETCH c_repeating INTO rec_repeating;
        CLOSE c_repeating;

        --for bug #4567434 adjusting date to client time zone
        l_time_hh := to_number(to_char(rec_repeating.planned_end_date,'HH24'));

        l_time_mm := to_number(to_char(rec_repeating.planned_end_date,'MI'));

        l_end_date := rec_repeating.end_date_active;
        l_end_date := l_end_date+(l_time_hh/24)+(l_time_mm/1440);

        l_end_date:=NVL(hz_timezone_pub.convert_datetime(TO_NUMBER(NVL(fnd_profile.value('SERVER_TIMEZONE_ID'),'4'))
														,l_client_timezone_id
														,l_end_date),l_end_date);



      IF rec_repeating.occurs_uom = 'DAY' THEN
            l_repeating_statement := make_sentence_daily(p_occurs_every  => rec_repeating.occurs_every
                                                        ,p_occurs_number => rec_repeating.occurs_number
                                                        ,p_end_date      => l_end_date
                                                        ,p_timezone      => rec_repeating.timezone_name);

        ELSIF rec_repeating.occurs_uom IN ('WEK', 'WK') THEN
            l_repeating_statement := make_sentence_weekly(p_occurs_every  => rec_repeating.occurs_every
                                                         ,p_occurs_number => rec_repeating.occurs_number
                                                         ,p_end_date      => l_end_date
                                                         ,p_sunday        => rec_repeating.sunday
                                                         ,p_monday        => rec_repeating.monday
                                                         ,p_tuesday       => rec_repeating.tuesday
                                                         ,p_wednesday     => rec_repeating.wednesday
                                                         ,p_thursday      => rec_repeating.thursday
                                                         ,p_friday        => rec_repeating.friday
                                                         ,p_saturday      => rec_repeating.saturday
                                                         ,p_timezone      => rec_repeating.timezone_name);

        ELSIF rec_repeating.occurs_uom IN ('MON', 'MTH') THEN
            l_repeating_statement := make_sentence_monthly(p_occurs_every  => rec_repeating.occurs_every
                                                          ,p_occurs_number => rec_repeating.occurs_number
                                                          ,p_date_of_month => rec_repeating.date_of_month
                                                          ,p_occurs_which  => rec_repeating.occurs_which
                                                          ,p_end_date      => l_end_date
                                                          ,p_sunday        => rec_repeating.sunday
                                                          ,p_monday        => rec_repeating.monday
                                                          ,p_tuesday       => rec_repeating.tuesday
                                                          ,p_wednesday     => rec_repeating.wednesday
                                                          ,p_thursday      => rec_repeating.thursday
                                                          ,p_friday        => rec_repeating.friday
                                                          ,p_saturday      => rec_repeating.saturday
                                                          ,p_timezone      => rec_repeating.timezone_name);

        ELSIF rec_repeating.occurs_uom IN ('YER', 'YR') THEN
            l_repeating_statement := make_sentence_yearly(p_occurs_every  => rec_repeating.occurs_every
                                                         ,p_occurs_number => rec_repeating.occurs_number
                                                         ,p_occurs_month  => rec_repeating.occurs_month
                                                         ,p_date_of_month => rec_repeating.date_of_month
                                                         ,p_occurs_which  => rec_repeating.occurs_which
                                                         ,p_end_date      => l_end_date
                                                         ,p_sunday        => rec_repeating.sunday
                                                         ,p_monday        => rec_repeating.monday
                                                         ,p_tuesday       => rec_repeating.tuesday
                                                         ,p_wednesday     => rec_repeating.wednesday
                                                         ,p_thursday      => rec_repeating.thursday
                                                         ,p_friday        => rec_repeating.friday
                                                         ,p_saturday      => rec_repeating.saturday
                                                         ,p_timezone      => rec_repeating.timezone_name);

        END IF;

        RETURN l_repeating_statement;
    END get_repeating;

    /* -----------------------------------------------------------------
     * -- Function Name: get_repeating
     * -- Description  : This function returns the repeating information
     * --                as string
     * -- Parameter    : p_task_id = task id as NUMBER type
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_repeating(p_task_id IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_task IS
        SELECT recurrence_rule_id
          FROM jtf_tasks_b
         WHERE task_id = p_task_id;

        l_recurrence_rule_id NUMBER;
        l_repeating_statement VARCHAR2(1000);
    BEGIN
        OPEN c_task;
        FETCH c_task INTO l_recurrence_rule_id;

        IF c_task%FOUND THEN
            l_repeating_statement := get_repeating(NULL, l_recurrence_rule_id);
        ELSE
            l_repeating_statement := NULL;
        END IF;
        CLOSE c_task;

        RETURN l_repeating_statement;
    END get_repeating;

    /* -----------------------------------------------------------------
     * -- Function Name: get_destination_uri
     * -- Description  : This function returns the url information
     * --                of the destination page
     * --                related to the given object code
     * -- Parameter    : p_object_code  = Object Code
     * --                p_object_id    = Object id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_destination_uri(p_object_code IN VARCHAR2
                                ,p_object_id   IN NUMBER)
    RETURN VARCHAR2
    IS
        /*
        CURSOR c_uri IS
        SELECT oa_web_function_name
             , oa_web_function_parameters
          FROM jtf_objects_b
         WHERE object_code = p_object_code;

        rec_uri  c_uri%ROWTYPE;
        */
        l_uri VARCHAR2(255);
        l_amp VARCHAR2(1);
    BEGIN
        l_amp := '&';
       /*
        OPEN c_uri;
        FETCH c_uri INTO rec_uri;
        IF c_uri%NOTFOUND THEN
            CLOSE c_uri;
            RETURN NULL;
        END IF;
        CLOSE c_uri;

        RETURN 'OA.jsp?OAFunc='||rec_uri.oa_web_function_name||l_amp||replace(rec_uri.oa_web_function_parameters, l_amp||'ID', p_object_id);
        */
        IF p_object_code = 'APPOINTMENT' THEN
            l_uri := 'OA.jsp?OAFunc=CAC_VIEW_APT_GENERAL'||l_amp||'addBreadCrumb=Y'||l_amp||'cacAptId='||p_object_id;
        END IF;

        RETURN l_uri;
    END get_destination_uri;

    /* -----------------------------------------------------------------
     * -- Function Name: show_flag
     * -- Description  : This function returns the indication of whether
     * --                the given object should be displayed or not.
     * --                related to the given object code
     * -- Parameter    : p_object_code  = Object Code
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION show_flag (p_object_code IN VARCHAR2)
    RETURN VARCHAR2
    IS
        l_preference_name VARCHAR2(240);

        CURSOR c_show IS
        SELECT preference_value
          FROM fnd_user_preferences
         WHERE user_name = fnd_global.user_name
           AND module_name = 'CAC_VIEW_PREF'
           AND preference_name = l_preference_name;

        l_show_flag VARCHAR2(1);
    BEGIN
        IF p_object_code = 'APPOINTMENT' THEN
            l_preference_name := 'CAC_VWS_APPT_SHOW';
        ELSIF p_object_code = 'TASK' THEN
            l_preference_name := 'CAC_VWS_TASK_SHOW';
        ELSE
            l_preference_name := 'CAC_VWS_EVENT_SHOW';
        END IF;

        OPEN c_show;
        FETCH c_show INTO l_show_flag;
        CLOSE c_show;

        IF l_show_flag IS NULL
        THEN
            IF p_object_code = 'APPOINTMENT' THEN
                l_show_flag := 'Y';
            ELSIF p_object_code = 'TASK' THEN
                l_show_flag := 'N';
            ELSE
                l_show_flag := 'N';
            END IF;
        END IF;

        RETURN l_show_flag;
    EXCEPTION
        WHEN OTHERS THEN
          RETURN 'N';
    END show_flag;

    /* -----------------------------------------------------------------
     * -- Function Name: get_sql
     * -- Description  : This function returns SQL statement
     * --                for the given object type code.
     * -- Parameter    : p_object_type_code  = Object Type Code
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_sql (p_object_type_code IN VARCHAR2)
    RETURN VARCHAR2
    IS
        CURSOR c_references IS
        SELECT select_id, select_name, from_table, where_clause
          FROM jtf_objects_b
         WHERE object_code = p_object_type_code;

        rec  c_references%ROWTYPE;
        l_where_clause   jtf_objects_b.where_clause%TYPE;
        sql_stmt  VARCHAR2(2000);
    BEGIN
        OPEN c_references;
        FETCH c_references INTO rec;

        IF c_references%NOTFOUND
        THEN
            sql_stmt := NULL;
        ELSE
           IF (rec.where_clause IS NULL)
           THEN
             l_where_clause := '  ';
           ELSE
             l_where_clause := rec.where_clause || ' AND ';
           END IF;

           sql_stmt := 'SELECT ' || rec.select_name ||
                       '  FROM ' || rec.from_table ||
                       ' WHERE ' || l_where_clause ||
                       rec.select_id ||' = :object_id AND ROWNUM = 1';
        END IF;
        CLOSE c_references;

        RETURN sql_stmt;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END get_sql;

    /* -----------------------------------------------------------------
     * -- Function Name: get_object_name
     * -- Description  : This function returns object name
     * --                for the given object id.
     * -- Parameter    : p_sql = SQL statement
     * --                p_object_id = object id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_object_name (p_sql       IN VARCHAR2
                             ,p_object_id IN NUMBER)
    RETURN VARCHAR2
    IS
        l_object_name VARCHAR2(255);
    BEGIN
        EXECUTE IMMEDIATE p_sql
        INTO l_object_name
        USING p_object_id;

        RETURN l_object_name;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END get_object_name;

    /* -----------------------------------------------------------------
     * -- Function Name: get_related_items
     * -- Description  : This function returns the concatednated information
     * --                of items related to the given task id.
     * -- Parameter    : p_task_id  = Task Id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_related_items (p_task_id IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_related_items IS
        SELECT object_type_code
             , object_id
          FROM jtf_task_references_b
         WHERE task_id = p_task_id
        ORDER BY object_type_code;

        l_related_items VARCHAR2(1000);
        l_object_name VARCHAR2(255);
        l_object_type_code VARCHAR2(255);
        l_sql VARCHAR2(2000);
    BEGIN
        l_object_type_code := '###';

        FOR rec IN c_related_items
        LOOP
            IF l_object_type_code <> rec.object_type_code THEN
               l_object_type_code := rec.object_type_code;
               l_sql := get_sql(l_object_type_code);
            END IF;

            l_object_name := get_object_name(l_sql, rec.object_id);

            IF l_object_name IS NOT NULL
            THEN
                IF l_related_items IS NULL
                THEN
                    l_related_items := l_object_name;
                ELSE
                    l_related_items := l_related_items || ', ' || l_object_name;
                END IF;
            END IF;
        END LOOP;

        RETURN l_related_items;
    EXCEPTION
        WHEN OTHERS THEN
          RETURN NULL;
    END get_related_items;

    /* -----------------------------------------------------------------
     * -- Function Name: get_event_for_detail
     * -- Description  : This function returns the FireAction event name
     * --                related to the given task id and resource id.
     * --                Returns INVITE if assignment status id is 18
     * --                Returns DEFAULT if assignment status id is NOT 18
     * -- Parameter    : p_task_id     = Task Id
     * --                p_resource_id = Resource Id
     * -- Return Type  : VARCHAR2
     * -----------------------------------------------------------------*/
    FUNCTION get_event_for_detail (p_task_id IN NUMBER
                                  ,p_resource_id IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_assignment IS
        SELECT assignment_status_id
          FROM jtf_task_all_assignments
         WHERE task_id = p_task_id
           AND resource_id = p_resource_id
           AND resource_type_code = 'RS_EMPLOYEE';

        l_assignment_status_id NUMBER;
        l_event_name VARCHAR2(30);
    BEGIN
        OPEN c_assignment;
        FETCH c_assignment INTO l_assignment_status_id;
        CLOSE c_assignment;

        IF l_assignment_status_id = 18 THEN
        -- if the status is invited
            l_event_name := 'INVITE';
        ELSE
            l_event_name := 'DEFAULT';
        END IF;

        RETURN l_event_name;
    EXCEPTION
        WHEN OTHERS THEN
          RETURN NULL;
    END get_event_for_detail;

END CAC_VIEW_ACC_DAILY_VIEW_PVT;

/
