--------------------------------------------------------
--  DDL for Package CAC_HR_CAL_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_HR_CAL_EVENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: cachrevts.pls 120.1 2005/07/02 02:17:58 appldev noship $ */


/*******************************************************************************
** Record type that holds the Calendar Event Information
*******************************************************************************/
TYPE HR_CAL_EVENT_REC_TYPE IS RECORD
( CAL_EVENT_ID          NUMBER
, EVENT_NAME            VARCHAR2(2000)
, EVENT_TYPE            VARCHAR2(30)
, START_DATE_TIME       DATE
, END_DATE_TIME         DATE
);

/*******************************************************************************
** PL/SQL table TYPE definition for the results of the GET_HR_CAL_EVENTS procedure
*******************************************************************************/
TYPE HR_CAL_EVENT_TBL_TYPE IS TABLE OF HR_CAL_EVENT_REC_TYPE INDEX BY BINARY_INTEGER;


PROCEDURE GET_HR_CAL_EVENTS
/*******************************************************************************
**  GET_HR_CAL_EVENTS
**
**  This API will return calendar events defined in hr events
**
*******************************************************************************/
( p_Object_Type          IN     VARCHAR2             -- JTF OBJECTS type of the Object being queried
, p_Object_ID            IN     NUMBER               -- JTF OBJECTS select ID of the Object Instance being queried
, p_Start_Date           IN     DATE                 -- start date of period of interest
, p_End_Date             IN     DATE                 -- end date of period of interest
, p_Event_Type           IN     VARCHAR2
, p_Event_Id             IN     NUMBER
, x_hr_cal_events        OUT NOCOPY HR_CAL_EVENT_TBL_TYPE
);


END CAC_HR_CAL_EVENTS_PVT;

 

/
