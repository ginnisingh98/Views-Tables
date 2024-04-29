--------------------------------------------------------
--  DDL for Package CAC_VIEW_ACC_DAILY_VIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_VIEW_ACC_DAILY_VIEW_PVT" AUTHID CURRENT_USER as
/* $Header: caccadvs.pls 120.1 2005/07/02 02:17:45 appldev noship $ */
/*#
 * This package is used for accessbility daily view.
 * @rep:scope private
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Accessibility Daily View
 * @rep:compatibility N
 * @rep:category BUSINESS_ENTITY CAC_APPOINTMENT
 */

/**
 * This function extracts only time portion of start dates and
 * returns the time as format 'HH12:MI AM'.
 * @param p_start_date Start Date
 * @param p_end_date   End Date
 * @return The formatted start time
 * @rep:displayname Get start time
 * @rep:lifecycle deprecated
 * @rep:compatibility N
 */
FUNCTION get_start_time(p_start_date IN DATE
                       ,p_end_date IN DATE)
RETURN VARCHAR2;

/**
 * This function is used to convert source timezone
 * to client timezone defined currently.
 * @param p_server_date Date for server date
 * @param p_source_timezone_id Source Timezone Id
 * @return The client date
 * @rep:displayname Get Client Data
 * @rep:lifecycle deprecated
 * @rep:compatibility N
 */
FUNCTION get_client_date(p_server_date IN DATE
                        ,p_source_timezone_id IN NUMBER) RETURN DATE;

/**
 * This function returns valid start date
 * among planned, scheduled, actual and calendar start date.
 * @param p_source_object_type_code source object type code
 * @param p_date_selected date type selected
 * @param p_planned_start_date planned start date
 * @param p_scheduled_start_date scheduled start date
 * @param p_actual_start_date actual start date
 * @param p_calendar_start_date calendar start date
 * @return the valid start date
 * @rep:displayname Get Start Data
 * @rep:lifecycle deprecated
 * @rep:compatibility N
 */
FUNCTION get_start_date(p_source_object_type_code IN VARCHAR2
                       ,p_date_selected IN VARCHAR2
                       ,p_planned_start_date IN DATE
                       ,p_scheduled_start_date IN DATE
                       ,p_actual_start_date IN DATE
                       ,p_calendar_start_date IN DATE
                       )
RETURN DATE;

/**
 * This function returns valid end date
 * among planned, scheduled, actual and calendar end date.
 * @param p_source_object_type_code source object type code
 * @param p_date_selected date type selected
 * @param p_planned_end_date planned end date
 * @param p_scheduled_end_date scheduled end date
 * @param p_actual_end_date actual end date
 * @param p_calendar_end_date calendar end date
 * @return the valid end date
 * @rep:displayname Get End Data
 * @rep:lifecycle deprecated
 * @rep:compatibility N
 */
FUNCTION get_end_date(p_source_object_type_code IN VARCHAR2
                     ,p_date_selected IN VARCHAR2
                     ,p_planned_end_date IN DATE
                     ,p_scheduled_end_date IN DATE
                     ,p_actual_end_date IN DATE
                     ,p_calendar_end_date IN DATE
                     )
RETURN DATE;

/**
 * This function returns the duration in minutes.
 * @param p_source_object_type_code source object type code
 * @param p_date_selected date type selected
 * @param p_planned_start_date planned start date
 * @param p_planned_end_date planned end date
 * @param p_scheduled_start_date scheduled start date
 * @param p_scheduled_end_date scheduled end date
 * @param p_actual_start_date actual start date
 * @param p_actual_end_date actual end date
 * @param p_calendar_start_date calendar start date
 * @param p_calendar_end_date calendar end date
 * @return The duration
 * @rep:displayname Get Duration
 * @rep:lifecycle deprecated
 * @rep:compatibility N
 */
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
RETURN VARCHAR2;

/**
 * This function returns the descriptive duration string, ex. 30 Minutes.
 * @param p_duration_min duration in minute
 * @return The descriptive duration in string
 * @rep:displayname Get descriptive duration
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION to_duration(p_duration_min IN NUMBER) RETURN VARCHAR2;

/**
 * This function returns the descriptive reminder string
 * based on the given reminder in minute.
 * The following minutes are defined in the lookup type JTF_CALND_REMIND_ME.
 *
 *   Minute  Reminder Text
 *   ------- ------------------
 *   0       Do Not Remind Me
 *   5       5 Minutes Before
 *   10      10 Minutes Before
 *   15      15 Minutes Before
 *   30      30 Minutes Before
 *   60      1 Hour Before
 *   120     2 Hours Before
 *   1440    1 Day Before
 *   2880    2 Days Before
 *   4320    3 Days Before
 *   10080   1 Week Before
 * @param p_reminder_min Reminder in minute
 * @return The descriptive reminder string
 * @rep:displayname Get descriptive reminder
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION get_reminder(p_reminder_min IN NUMBER) RETURN VARCHAR2;

/**
 * This function returns the descriptive reminder string
 * based on the given reminder and its unit of measuure.
 * @param p_reminder if p_reminder_uom is null, the unit is regarded as minute
 * @param p_reminder_uom unit of measure for reminder
 * @return The descriptive reminder string
 * @rep:displayname Get descriptive reminder
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION get_reminder(p_reminder IN NUMBER
                     ,p_reminder_uom IN VARCHAR2)
RETURN VARCHAR2;

/**
 * This function returns the descriptive reminder string based on task id.
 * @param p_task_id task id
 * @return The descriptive reminder string
 * @rep:displayname Get descriptive reminder
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION get_reminder(p_task_id IN NUMBER) RETURN VARCHAR2;

/**
 * This function returns the list of attendees
 * concatenated with comma delimit.
 * @param p_task_id task id
 * @return The list of attendees
 * @rep:lifecycle active
 * @rep:displayname Get list of attendees
 * @rep:compatibility N
 */
FUNCTION get_attendees(p_task_id IN NUMBER) RETURN VARCHAR2;

/**
 * This function returns preference value
 * based on the given preference name
 * @param p_preference_name preference name
 * @return The prefix defined for the given preference name
 * @rep:displayname Get Prefix
 * @rep:lifecycle deprecated
 * @rep:compatibility N
 */
FUNCTION get_prefix(p_preference_name IN VARCHAR2) RETURN VARCHAR2;

/**
 * This function returns the subject concatenated to a prefix
 * for event objects
 * @param p_source_code source object code
 * @param p_source_id source object id
 * @return The subject concatenated to a prefix
 * @rep:displayname Get Subject
 * @rep:lifecycle deprecated
 * @rep:compatibility N
 */
FUNCTION get_subject(p_source_code IN VARCHAR2
                    ,p_source_id   IN NUMBER) RETURN VARCHAR2;

/**
 * This function returns the subject concatenated to a prefix
 * for appointment objects
 * @param p_object_code source object code
 * @param p_object_name source object id
 * @param p_task_id task id
 * @param p_resource_id resource id
 * @return The subject concatenated to a prefix
 * @rep:displayname Get Subject
 * @rep:lifecycle deprecated
 * @rep:compatibility N
 */
FUNCTION get_subject(p_object_code IN VARCHAR2
                    ,p_object_name IN VARCHAR2
                    ,p_task_id     IN NUMBER
                    ,p_resource_id IN NUMBER)
RETURN VARCHAR2;

/**
 * This function returns the descriptive repeating information
 * @param p_object_type source object type code (Ignored)
 * @param p_recurrence_rule_id recurrence rule id
 * @return The descriptive repeating information
 * @rep:displayname Get Repeating Information
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION get_repeating(p_object_type IN VARCHAR2
                      ,p_recurrence_rule_id IN NUMBER)
RETURN VARCHAR2;

/**
 * This function returns the descriptive repeating information
 * @param p_task_id task id
 * @return The descriptive repeating information
 * @rep:displayname Get Repeating Information
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION get_repeating(p_task_id IN NUMBER)
RETURN VARCHAR2;

/**
 * This function returns the url information of the destination page.
 * @param p_object_code source object type code
 * @param p_object_id source object id
 * @return The url information
 * @rep:displayname Get Destination URL
 * @rep:lifecycle deprecated
 * @rep:compatibility N
 */
FUNCTION get_destination_uri(p_object_code IN VARCHAR2
                            ,p_object_id   IN NUMBER)
RETURN VARCHAR2;

/**
 * This function returns a flag to indicate
 * whether the given object should be displayed or not.
 * @param p_object_code source object type code
 * @return The show flag
 * @rep:displayname Get Show Flag
 * @rep:lifecycle deprecated
 * @rep:compatibility N
 */
FUNCTION show_flag (p_object_code IN VARCHAR2)
RETURN VARCHAR2;

/**
 * This function returns SQL statement for the given object type code.
 * @param p_object_code source object type code
 * @return The SQL statement
 * @rep:displayname Get SQL
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION get_sql (p_object_type_code IN VARCHAR2)
RETURN VARCHAR2;

/**
 * This function returns an object name for the given object id.
 * @param p_sql SQL statement
 * @param p_object_id source object id
 * @return The object name
 * @rep:displayname Get Object Name
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION get_object_name (p_sql       IN VARCHAR2
                         ,p_object_id IN NUMBER)
RETURN VARCHAR2;

/**
 * This function returns the concatednated information
 * of items related to the given task id.
 * @param p_task_id task id
 * @return The related items
 * @rep:displayname Get Related Items
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION get_related_items (p_task_id IN NUMBER)
RETURN VARCHAR2;

/**
 * This function returns the FireAction event name
 * related to the given task id and resource id.
 * Returns INVITE if assignment status id is 18
 * Returns DEFAULT if assignment status id is NOT 18
 * @param p_task_id task id
 * @param p_resource_id resource id
 * @return The event name
 * @rep:displayname Get Event Name
 * @rep:lifecycle deprecated
 * @rep:compatibility N
 */
FUNCTION get_event_for_detail (p_task_id IN NUMBER
                              ,p_resource_id IN NUMBER)
RETURN VARCHAR2;

END CAC_VIEW_ACC_DAILY_VIEW_PVT;

 

/
