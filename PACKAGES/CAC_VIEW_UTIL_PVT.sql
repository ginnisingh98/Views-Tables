--------------------------------------------------------
--  DDL for Package CAC_VIEW_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_VIEW_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: cacpvuts.pls 120.6 2006/01/10 00:02:30 deeprao noship $ */
/*#
 * This package is a private utility for Calendar views.
 * @rep:scope private
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Private Calendar View Util
 * @rep:compatibility N
 * @rep:category BUSINESS_ENTITY CAC_APPOINTMENT
 */

/**
 * This procedure creates collaboration details record
 * for target task_id by copying the data from source task_id
 * @param p_source_task_id source task id
 * @param p_target_task_id target task id
 * @rep:displayname Create Repeating Collaboration Details
 * @rep:lifecycle active
 * @rep:compatibility N
 */
PROCEDURE create_repeat_collab_details (
 p_source_task_id     IN   NUMBER,
 p_target_task_id     IN   NUMBER
);

/**
 * This procedure updates collaboration details record
 * for target task_id by copying the data from source task_id
 * @param p_source_task_id source task id
 * @param p_target_task_id target task id
 * @rep:displayname Update Repeating Collaboration Details
 * @rep:lifecycle active
 * @rep:compatibility N
 */
PROCEDURE update_repeat_collab_details(
 p_source_task_id     IN   NUMBER,
 p_target_task_id     IN   NUMBER
);

/**
 * This procedure is used to convert a given time from a source timezone to a destination timezone.
 * @param p_source_tz_id a source timezone id
 * @param p_dest_tz_id a destination timezone id
 * @rep:displayname Adjust For Timezone
 * @rep:lifecycle active
 * @rep:compatibility N
 */
PROCEDURE AdjustForTimezone
( p_source_tz_id     IN     NUMBER
, p_dest_tz_id       IN     NUMBER
, p_source_day_time  IN     DATE
, x_dest_day_time    OUT    NOCOPY    DATE
);

/**
 * This function is used to get reminder description.
 * @param p_reminder a reminder
 * @return a reminder description
 * @rep:displayname Get Reminder Description
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION GET_REMINDER_DESCRIPTION (p_reminder IN NUMBER) RETURN VARCHAR2;

/**
 * This procedure is used to convert a repeating rule from source timezone to destination timezone.
 * @param p_source_tz_id a source timezone id
 * @param p_dest_tz_id a destination timezone id
 * @param p_base_start_datetime base start date/time
 * @param p_base_end_datetime base end date/time
 * @param p_start_date_active repeating start date
 * @param p_end_date_active repeating end date
 * @param p_occurs_which relative position occuring in a week
 * @param p_date_of_month date of the month
 * @param p_occurs_month occuring month
 * @param p_sunday sunday
 * @param p_monday monday
 * @param p_tuesday tuesday
 * @param p_wednesday wednesday
 * @param p_thursday thursday
 * @param p_friday friday
 * @param p_saturday saturday
 * @param x_start_date_active repeating start date
 * @param x_end_date_active repeating end date
 * @param x_occurs_which relative position occuring in a week
 * @param x_date_of_month date of the month
 * @param x_occurs_month occuring month
 * @param x_sunday sunday
 * @param x_monday monday
 * @param x_tuesday tuesday
 * @param x_wednesday wednesday
 * @param x_thursday thursday
 * @param x_friday friday
 * @param x_saturday saturday
 * @rep:displayname Adjust Recurrence Rule For Timezone
 * @rep:lifecycle active
 * @rep:compatibility N
 */
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
);

/**
 * This function is used to get duration description.
 * @param p_duration a duration
 * @return a duration description
 * @rep:displayname Get Duration Description
 * @rep:lifecycle active
 * @rep:compatibility N
 */
FUNCTION GET_DURATION_DESCRIPTION (p_duration IN NUMBER) RETURN VARCHAR2;


END CAC_VIEW_UTIL_PVT;

 

/
