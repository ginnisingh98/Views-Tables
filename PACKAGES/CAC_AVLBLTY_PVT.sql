--------------------------------------------------------
--  DDL for Package CAC_AVLBLTY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_AVLBLTY_PVT" AUTHID CURRENT_USER AS
/* $Header: caccaps.pls 120.1 2005/07/02 02:17:52 appldev noship $ */

/*******************************************************************************
** todo list
*******************************************************************************/
--
-- + Add published schedule lookup logic
-- + Add overloaded versions for defaulting
-- + Add error handling
-- + Add time zone support
-- + Profile code for performance
-- + create java wrappers

/*******************************************************************************
** Private APIs
*******************************************************************************/

FUNCTION CONVERT_TO_MILLIS
/*******************************************************************************
**  ConvertToMiliiseconds
**
**  Will return the period + UOM in day so it can be added to an Oracle DATE.
*******************************************************************************/
( p_Duration IN NUMBER
, p_UOM      IN VARCHAR2
)RETURN NUMBER;


FUNCTION ADJUST_FOR_TIMEZONE
( p_source_tz_id     IN     NUMBER
, p_dest_tz_id       IN     NUMBER
, p_source_day_time  IN     DATE
)RETURN DATE;


PROCEDURE GET_SCHEDULE_DATA
/*******************************************************************************
**
** GET_SCHEDULE_DATA
**
**   returns the schedule for the given:
**   - Object Instance
**   - Schedule Type
**   - Period
**
*******************************************************************************/
( p_Object_Type          IN     VARCHAR2             -- JTF OBJECTS type of the Object being queried
, p_Object_ID            IN     NUMBER               -- JTF OBJECTS select ID of the Object Instance being queried
, p_Start_Date_Time      IN     DATE                 -- start date and time of period of interest
, p_End_Date_Time        IN     DATE                 -- end date and time of period of interest
, p_Schdl_Cat            IN     VARCHAR2             -- Schedule Category of the schedule instance we'll look at
, p_Include_Exception    IN     VARCHAR2             -- 'T' or 'F' depending on whether the exceptions be included or not
, p_Busy_Tentative       IN     VARCHAR2             -- How to treat periods with FREEBUSYTYPE = BUSY TENTATIVE?
                                                     -- FREE: BUSY TENTATIVE means FREE
                                                     -- BUSY: BUSY TENTATIVE means BUSY
                                                     -- NULL: leave the interpretation to caller
, p_return_type          IN     VARCHAR2             -- 'D': Detailed schedule
                                                     -- 'S': Schedule Summary
                                                     -- 'B': Both detailed and summary of schedule
, x_Schedule             OUT NOCOPY CAC_AVLBLTY_TIME_VARRAY
, x_Schedule_Summary     OUT NOCOPY CAC_AVLBLTY_SUMMARY_VARRAY
                                                     --  return schedule
);


PROCEDURE POPULATE_SCHEDULE_DETAILS
/*******************************************************************************
**
** POPULATE_SCHEDULE_DETAILS
**
**   expands the schedule for the given:
**   - Schedule
**   - template
**   - duration
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schdl_Tmpl_Id        IN     NUMBER
, p_Schdl_Tmpl_Length    IN     NUMBER
, p_Schdl_Tmpl_Type      IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
);


PROCEDURE POPULATE_OBJECT_SCHDL_DETAILS
/*******************************************************************************
**
** POPULATE_OBJECT_SCHDL_DETAILS
**
**   expands the schedule for the given:
**   - Resource
**   - Schedule
**
*******************************************************************************/
( p_Schedule_Id               IN     NUMBER               -- id of the schedule
, p_Schedule_Object_Id        IN     NUMBER
, p_Object_Start_Date         IN     DATE
, p_Object_End_Date           IN     DATE
, p_Start_Template_Detail_Id  IN     NUMBER
);


PROCEDURE POST_CREATE_SCHEDULE
/*******************************************************************************
**
** POST_CREATE_SCHEDULE
**
**   expands the schedule for the given:
**   - Schedule
**   - template
**   - duration
**   and submits business events
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Tmpl_Id        IN     NUMBER
, p_Schdl_Tmpl_Length    IN     NUMBER
, p_Schdl_Tmpl_Type      IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
);


PROCEDURE POST_UPDATE_SCHEDULE
/*******************************************************************************
**
** POST_UPDATE_SCHEDULE
**
**   expands the schedule for the given:
**   - Schedule
**   - template
**   - duration
**   and submits business events
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Tmpl_Id        IN     NUMBER
, p_Schdl_Tmpl_Length    IN     NUMBER
, p_Schdl_Tmpl_Type      IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
);


PROCEDURE POST_DELETE_SCHEDULE
/*******************************************************************************
**
** POST_DELETE_SCHEDULE
**
**   submits business events
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Category    IN     VARCHAR2
, p_Schdl_Start_Date     IN     DATE
, p_Schdl_End_Date       IN     DATE
);


END CAC_AVLBLTY_PVT;

 

/
