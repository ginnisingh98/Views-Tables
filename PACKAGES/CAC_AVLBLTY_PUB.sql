--------------------------------------------------------
--  DDL for Package CAC_AVLBLTY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_AVLBLTY_PUB" AUTHID CURRENT_USER AS
/* $Header: caccabs.pls 120.2 2008/01/09 12:51:33 lokumar ship $ */

/*******************************************************************************
** Datatypes used in APIs
*******************************************************************************/
/**
  CREATE OR REPLACE TYPE CAC_AVLBLTY_TIME_BAND AS
  OBJECT( START_DATE_TIME       DATE           -- The start date and time of the period detail
        , END_DATE_TIME         DATE           -- The end date and time of the period detail
        , MIN_BREAK_MINS        NUMBER         -- Minimum number of minutes available for break
        , MAX_BREAK_MINS        NUMBER         -- Maximum number of minutes available for break
        , CORE_FLAG             VARCHAR2(1)    -- Flag indicating if the period detail is a core one or not
        , PERIOD_DTL_TYPE_ID    NUMBER         -- Type of the period detail,
        , PERIOD_DTL_TYPE_NAME  VARCHAR2(2000) -- like 'Core working hours', 'Flexible lunch' etc.
        );

  CREATE OR REPLACE TYPE CAC_AVLBLTY_TIME_BAND_VARRAY AS
  VARRAY(100000) OF CAC_AVLBLTY_TIME_BAND;

  CREATE OR REPLACE TYPE CAC_AVLBLTY_TIME AS
  OBJECT( PERIOD_NAME           VARCHAR2(2000)                -- Name of the shift
        , START_DATE_TIME       DATE                          -- The start date and time of the period
        , END_DATE_TIME         DATE                          -- The end date and time of the period
        , DURATION_MS           NUMBER                        -- Duration of the period in milliseconds.
                                                              -- This could be less than end date-start date if the period is of flexible type
        , PERIOD_CATEGORY_ID    NUMBER                        -- Category Id of the shift
        , PERIOD_CATEGORY_NAME  VARCHAR2(2000)                -- Category Name of the shift
        , FREE_BUSY_TYPE        VARCHAR2(30)                  -- FREE / BUSY / BUSY_TENTATIVE associated with the period category
        , DISPLAY_COLOR         VARCHAR2(30)                  -- Display color associated with the period category
        , SHIFT_BANDS           CAC_AVLBLTY_TIME_BAND_VARRAY  -- An array containing shift bands.
                                                              -- It's populated only the if category of the period allows period details
        , SUPER_OBJECT_INDEX    NUMBER                        -- This will contain the index of the period in the VARRRAY
                                                              -- that was overwritten by the current one.
                                                              -- For example, in the case of a holiday on a regular working day,
                                                              -- the super object will have the period as defined by the schedule
                                                              -- and the current object will be that of the holiday.
                                                              -- This could go up to any level
        , NEXT_OBJECT_INDEX     NUMBER                        -- This will contain the index of the period in the VARRRAY
                                                              -- that comes after this one.
                                                              -- This should be used to browse the VARRAY
        );

  CREATE OR REPLACE TYPE CAC_AVLBLTY_TIME_VARRAY AS
  VARRAY(100000) OF CAC_AVLBLTY_TIME;

  CREATE OR REPLACE TYPE CAC_AVLBLTY_DAY_TIME AS
  OBJECT( START_TIME_MS       NUMBER   -- Start time of this record in milliseconds
                                       -- This is calculated since the start of day (00:00)
        , END_TIME_MS         NUMBER   -- End time of this record in milliseconds
                                       -- This is calculated since the start of day (00:00)
        );

  CREATE OR REPLACE TYPE CAC_AVLBLTY_DAY_TIME_VARRAY AS
  VARRAY(100000) OF CAC_AVLBLTY_DAY_TIME;

  CREATE OR REPLACE TYPE CAC_AVLBLTY_DETAIL AS
  OBJECT( TOTAL_TIME_MS           NUMBER                      -- Total time of this line
        , PERIOD_CATEGORY_ID      NUMBER                      -- Category Id of the shift
        , PERIOD_CATEGORY_NAME    VARCHAR2(2000)              -- Category Name of the shift
        , FREE_BUSY_TYPE          VARCHAR2(30)                -- FREE / BUSY / BUSY_TENTATIVE associated with the period category
        , DISPLAY_COLOR           VARCHAR2(30)                -- Display color associated with the period category
        , DAY_TIMES               CAC_AVLBLTY_DAY_TIME_VARRAY -- Times of the day where this line is applicable
                                                              -- for example, a person can be free at 09:00 to 12:00
                                                              -- and then again at 13:00 to 17:00.
                                                              -- This attribute will have two rows in that case
        );

  CREATE OR REPLACE TYPE CAC_AVLBLTY_DETAIL_VARRAY AS
  VARRAY(100000) OF CAC_AVLBLTY_DETAIL;

  CREATE OR REPLACE TYPE CAC_AVLBLTY_SUMMARY AS
  OBJECT( SUMMARY_DATE     DATE                       -- The day (date) for which summary was calculated
        , SUMMARY_LINES    CAC_AVLBLTY_DETAIL_VARRAY  -- Detail lines for the summary day.
                                                      -- This will contain different categories in case
                                                      -- person is working on different shifts.
                                                      -- For each category there will be a row
        );

  CREATE OR REPLACE TYPE CAC_AVLBLTY_SUMMARY_VARRAY AS
  VARRAY(100000) OF CAC_AVLBLTY_SUMMARY;

**/


/*******************************************************************************
** Public APIs
*******************************************************************************/

PROCEDURE GET_SCHEDULE
/*******************************************************************************
**  GET_SCHEDULE
**
**  Roughly translates to JTF_CALENDAR_PUB_24HR.Get_Resource_Shifts API.
**  It will return a list of periods for which the given Object is considered
**  to be available. The algorithme used is as follows:
**
**     24*7*365              (full availability if no constraints are defined)
**     Schedule              (if a schedule was defined we'll use it)
**     Holidays              (if Holidays are defined in HR we'll honor them)
**     Exceptions  -         (Resource level Exceptions will be honored)
**    --------------
**     Schedule
**
*******************************************************************************/
( p_api_version          IN     NUMBER               -- API version you coded against
, p_init_msg_list        IN     VARCHAR2             -- Create a new error stack?
, p_Object_Type          IN     VARCHAR2             -- JTF OBJECTS type of the Object being queried
, p_Object_ID            IN     NUMBER               -- JTF OBJECTS select ID of the Object Instance being queried
, p_Start_Date_Time      IN     DATE                 -- start date and time of period of interest
, p_End_Date_Time        IN     DATE                 -- end date and time of period of interest
, p_Schedule_Category    IN     VARCHAR2             -- Schedule Category of the schedule instance we'll look at
, p_Include_Exception    IN     VARCHAR2             -- 'T' or 'F' depending on whether the exceptions be included or not
, p_Busy_Tentative       IN     VARCHAR2             -- How to treat periods with FREEBUSYTYPE = BUSY TENTATIVE?
                                                     -- FREE: BUSY TENTATIVE means FREE
                                                     -- BUSY: BUSY TENTATIVE means BUSY
                                                     -- NULL: leave the interpretation to caller
, x_Schedule             OUT NOCOPY CAC_AVLBLTY_TIME_VARRAY
                                                     --  return schedule
, x_return_status        OUT NOCOPY VARCHAR2         -- 'S': API completed without errors
                                                     -- 'E': API completed with recoverable errors; explanation on errorstack
                                                     -- 'U': API completed with UN recoverable errors: error message on error stack
, x_msg_count            OUT NOCOPY NUMBER           -- Number of messages on the errorstack
, x_msg_data             OUT NOCOPY VARCHAR2         -- contains message if x_msg_count = 1
);


PROCEDURE GET_SCHEDULE_SUMMARY
/*******************************************************************************
**  GET_SCHEDULE_SUMMARY
**
**  This API will return summary of schedule on day by day basis
**  The algorithme used is as follows:
**
**     24*7*365              (full availability if no constraints are defined)
**     Schedule              (if a schedule was defined we'll use it)
**     Holidays              (if Holidays are defined in HR we'll honor them)
**     Exceptions  -         (Resource level Exceptions will be honored)
**    --------------
**     Schedule
**
*******************************************************************************/
( p_api_version          IN     NUMBER               -- API version you coded against
, p_init_msg_list        IN     VARCHAR2             -- Create a new error stack?
, p_Object_Type          IN     VARCHAR2             -- JTF OBJECTS type of the Object being queried
, p_Object_ID            IN     NUMBER               -- JTF OBJECTS select ID of the Object Instance being queried
, p_Start_Date           IN     DATE                 -- start date of period of interest
, p_End_Date             IN     DATE                 -- end date of period of interest
, p_Schedule_Category    IN     VARCHAR2             -- Schedule Category of the schedule instance we'll look at
, p_Include_Exception    IN     VARCHAR2             -- 'T' or 'F' depending on whether the exceptions be included or not
, p_Busy_Tentative       IN     VARCHAR2             -- How to treat periods with FREEBUSYTYPE = BUSY TENTATIVE?
                                                     -- FREE: BUSY TENTATIVE means FREE
                                                     -- BUSY: BUSY TENTATIVE means BUSY
                                                     -- NULL: leave the interpretation to caller
, x_Schedule_Summary     OUT NOCOPY CAC_AVLBLTY_SUMMARY_VARRAY
                                                     --  return schedule summary
, x_return_status        OUT NOCOPY VARCHAR2         -- 'S': API completed without errors
                                                     -- 'E': API completed with recoverable errors; explanation on errorstack
                                                     -- 'U': API completed with UN recoverable errors: error message on error stack
, x_msg_count            OUT NOCOPY NUMBER           -- Number of messages on the errorstack
, x_msg_data             OUT NOCOPY VARCHAR2         -- contains message if x_msg_count = 1
);


PROCEDURE IS_AVAILABLE
/*****************************************************************************
**  Method IS_AVAILABLE
**
**  Roughly translates to JTF_CALENDAR_PUB_24HR. Is_Res_Available API.
**  It will return:
**   - 'T' if the resource is available for the given period
**   - 'F' if the resource is unavailable for the given period
**
*******************************************************************************/
( p_api_version          IN     NUMBER               -- API version you coded against
, p_init_msg_list        IN     VARCHAR2             -- Create a new error stack?
, p_Object_Type          IN     VARCHAR2             -- JTF OBJECTS type of the Object being queried
, p_Object_ID            IN     NUMBER               -- JTF OBJECTS select ID of the Object Instance being queried
, p_Start_Date_Time      IN     DATE                 -- start date and time of period of interest
, p_End_Date_Time        IN     DATE                 -- end date and time of period of interest
, p_Schedule_Category    IN     VARCHAR2             -- Schedule Category of the schedule instance we'll look at
, p_Busy_Tentative       IN     VARCHAR2             -- How to treat periods with FREEBUSYTYPE = BUSY TENTATIVE?
                                                     -- FREE: BUSY TENTATIVE means FREE
                                                     -- BUSY: BUSY TENTATIVE means BUSY
                                                     -- NULL: leave the interpretation to caller
, p_task_assignment_id   IN     NUMBER  DEFAULT NULL -- specifies the task assignment id to be ignored while checking availability
                                                     -- Added by lokumar for bug#6345516
, x_Available            OUT NOCOPY VARCHAR2         -- 'T' or 'F'
, x_return_status        OUT NOCOPY VARCHAR2         -- 'S': API completed without errors
                                                     -- 'E': API completed with recoverable errors; explanation on errorstack
                                                     -- 'U': API completed with UN recoverable errors: error message on error stack
, x_msg_count            OUT NOCOPY NUMBER           -- Number of messages on the errorstack
, x_msg_data             OUT NOCOPY VARCHAR2         -- contains message if x_msg_count = 1
);


END CAC_AVLBLTY_PUB;

/
