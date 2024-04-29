--------------------------------------------------------
--  DDL for Package GMP_CALENDAR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_CALENDAR_API" AUTHID CURRENT_USER AS
/* $Header: GMPCAPIS.pls 120.1.12010000.1 2008/07/30 06:15:09 appldev ship $ */
/*#
 * This is the public interface for fetching data from OPM Shop Calendar
 * These APIs are used by that OPM Process Execution.
 * The calendar APIs provide various calendar related information such as
 * if a given day is a work day, provide contiguous working periods etc.
 * @rep:scope public
 * @rep:product GMP
 * @rep:displayname GMP_CALENDAR_API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY GMP_CALENDAR_API
*/

  m_api_version   CONSTANT NUMBER         := 1;
  m_pkg_name      CONSTANT VARCHAR2 (30)  := 'GMP_CALENDAR_API';


TYPE contig_time_rec IS RECORD
(
  start_date DATE,
  duration   NUMBER,
  end_date   DATE
);

TYPE contig_period_tbl IS TABLE OF contig_time_rec INDEX BY BINARY_INTEGER;

TYPE date_rec IS RECORD (
 cal_date     DATE,
 is_workday   NUMBER );
TYPE date_tbl IS TABLE OF date_rec
        INDEX BY BINARY_INTEGER;

TYPE workday_rec IS RECORD(
 workday   DATE);
TYPE workdays_tbl IS TABLE OF workday_rec
        INDEX BY BINARY_INTEGER;

TYPE shopday_dtl_rec IS RECORD (
  shift_no    NUMBER,
  shift_start NUMBER ,
  shift_duration NUMBER );
TYPE shopday_dtl_tbl IS TABLE OF shopday_dtl_rec
        INDEX BY BINARY_INTEGER;

/*#
 *  API for IS_WORKING_DAY -  FUNCTION
 *  This API takes Calendar_id and date as input and returns if the given
 *  day is a Working day or not.
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list
 *  @param p_calendar_code This is the calendar code.
 *  @param p_date This is the date which is determined to be a work day or not
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname IS_WORKING_DAY
*/
FUNCTION is_working_day(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      BOOLEAN  :=  TRUE,
        p_calendar_code		IN 	VARCHAR2,
        p_date       		IN	 DATE,
        x_return_status         IN OUT  NOCOPY VARCHAR2
      ) RETURN BOOLEAN ;

/*#
 *  API for IS_WORKING_DAYTIME -  FUNCTION
 *  This API returns if the date time passed for a calendar is a falls during
 *  working time of a work day.
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list
 *  @param p_calendar_code This is the calendar code.
 *  @param p_date This is the date and time which is determined to be in the
 *               worktime or not
 *  @param p_ind  Indicator takes values 0 or 1, 0 means Start and 1 means End.
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname IS_WORKING_DAYTIME
*/
FUNCTION IS_WORKING_DAYTIME(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      BOOLEAN  := TRUE,
        p_calendar_code		IN 	VARCHAR2,
        p_date                  IN      DATE,
        p_ind                   IN      NUMBER,
        x_return_status         IN OUT  NOCOPY VARCHAR2
        ) RETURN BOOLEAN ;


/*#
 *  API for GET_CONTIGUOUS_PERIODS -  PROCEDURE
 *  This s the API to fetch contiguous periods of times that add upto the
 *  required duration.If Start date is given, the duration is calculated
 *  from the start date forward. If the end date is given, the duration is
 *  calculated from the end date backwards. The return is the collection of
 *  contiguous periods with their start date,end date and durations
 *
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list
 *  @param p_start_date This is the Start date
 *  @param p_end_date This is the end date
 *  @param p_calendar_code This is the calendar code.
 *  @param p_duration This is the required durationrequired. The sum of
 *  contiguous periods fetched add upto this. Contiguous periods start on or
 *  after start date if provided. Or contiguous period end at or before end date
 *  if provided. Only one of the two dates can be supplied.
 *  @param p_output_tbl  This is PL/SQL table where the output is stored
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname GET_CONTIGUOUS_PERIODS
*/
PROCEDURE get_contiguous_periods(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      BOOLEAN  :=  TRUE,
        p_start_date            IN      DATE,
        p_end_date              IN      DATE,
        p_calendar_code		IN 	VARCHAR2,
        p_duration              IN      NUMBER,
        p_output_tbl            OUT     NOCOPY contig_period_tbl,
        x_return_status         IN OUT  NOCOPY VARCHAR2
   ) ;

/*#
 *  API for GET_ALL_DATES -  PROCEDURE
 *  This API returns the Working and Non-Working days between a specified
 *  Start and End dates in Calendar
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list
 *  @param p_calendar_code This is the calendar code.
 *  @param p_start_date This is the start date of the desired range
 *  @param p_end_date This is the End date of the desired range
 *  @param p_output_tbl  This is PL/SQL table where the output is stored
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname GET_ALL_DATES
*/
PROCEDURE get_all_dates(
	p_api_version           IN      NUMBER,
        p_init_msg_list         IN      BOOLEAN  :=  TRUE,
        p_calendar_code		IN 	VARCHAR2,
	p_start_date		IN 	DATE,
	p_end_date		IN	DATE,
 	p_output_tbl		OUT     NOCOPY date_tbl,
        x_return_status         IN OUT  NOCOPY VARCHAR2
    );

/*#
 *  API for GET_WORK_DAYS -  PROCEDURE
 *  This API returns the Working days between a specified
 *  Start and End dates in Calendar
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list
 *  @param p_calendar_code This is the calendar code.
 *  @param p_start_date This is the start date of the desired date range
 *  @param p_end_date This is the End date of the desired date range
 *  @param p_output_tbl  This is PL/SQL table where the output is stored
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname GET_WORK_DAYS
*/
PROCEDURE get_work_days(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      BOOLEAN  :=  TRUE,
        p_calendar_code		IN 	VARCHAR2,
        p_start_date            IN      DATE,
        p_end_date              IN      DATE,
        p_output_tbl            OUT NOCOPY workdays_tbl,
        x_return_status         IN OUT  NOCOPY VARCHAR2
    );

/*#
 *  API for GET_WORKDAY_DETAILS -  PROCEDURE
 *  This API returns the Working day details i.e. shift numbers and their
 *  durations for a given Shop Day
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list
 *  @param p_calendar_code This is the calendar code.
 *  @param p_shopday_no This is the calendar Shop Day.
 *  @param p_output_tbl  This is PL/SQL table where the output is stored
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname GET_WORKDAY_DETAILS
*/
PROCEDURE get_workday_details(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      BOOLEAN  :=  TRUE,
        p_calendar_code		IN 	VARCHAR2,
        p_shopday_no            IN      NUMBER,
        p_output_tbl       	OUT NOCOPY shopday_dtl_tbl,
        x_return_status         IN OUT  NOCOPY VARCHAR2
     );

-- Bug: 6265867 Kbanddyo added this procedure
/*#
 *  Returns the nearest working day details,shift numbers
 *  @param p_api_version Version Number of the API
 *  @param p_init_msg_list Flag for initializing message list
 *  @param p_calendar_id This is the calendar id.
 *  @param p_date This is the date to be checked against calendar
 *  @param p_direction  This provides the direction to find nearest date forward
 *  or backward
 *  @param x_date This is the nearest date checked against the calendar
 *  @param x_return_status Return status 'S'-Success, 'E'-Error,
 *       'U'-Unexpected Error
 *  @rep:scope public
 *  @rep:lifecycle active
 *  @rep:displayname GET_NEAREST_WORKDAYTIME
*/
PROCEDURE get_nearest_workdaytime(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      BOOLEAN  := TRUE,
        p_calendar_id           IN      VARCHAR2,
        p_date                  IN      DATE,
        p_direction             IN      NUMBER,
        x_date                  IN OUT  NOCOPY DATE ,
        x_return_status         IN OUT  NOCOPY VARCHAR2
        ) ;

END gmp_calendar_api ;

/
