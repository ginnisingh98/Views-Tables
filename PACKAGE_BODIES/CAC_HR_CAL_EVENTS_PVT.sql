--------------------------------------------------------
--  DDL for Package Body CAC_HR_CAL_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_HR_CAL_EVENTS_PVT" AS
/* $Header: cachrevtb.pls 120.2 2005/08/17 22:12:19 akaran noship $ */


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
) IS

  l_cal_events    PER_CAL_EVENT_VARRAY;
  l_i             NUMBER;

BEGIN

  IF (p_Object_Type = 'PERSON_ASSIGNMENT')
  THEN
    l_cal_events := HR_CAL_EVENT_MAPPING_PKG.GET_CAL_EVENTS
                    (
                      p_assignment_id   => p_Object_ID
                    , p_event_type      => p_Event_Type
                    , p_start_date      => p_Start_Date
                    , p_end_date        => p_End_Date
                    , p_event_type_flag => NULL
                    );
  ELSIF (p_Object_Type IN
    ('BUSINESS_GROUP','HR_ORGANIZATION','HR_JOB','HR_POSITION','HR_LOCATION'))
  THEN
    l_cal_events := HR_CAL_EVENT_MAPPING_PKG.GET_ALL_CAL_EVENTS
                    (
                      p_event_type      => p_Event_Type
                    , p_start_date      => p_Start_Date
                    , p_end_date        => p_End_Date
                    );
  END IF;

  IF (l_cal_events IS NOT NULL)
  THEN
    l_i := l_cal_events.FIRST;
    WHILE (l_i IS NOT NULL)
    LOOP
      IF (NVL(p_Event_Id,l_cal_events(l_i).cal_event_id) = l_cal_events(l_i).cal_event_id)
      THEN
        x_hr_cal_events(l_i).CAL_EVENT_ID    := l_cal_events(l_i).cal_event_id;
        x_hr_cal_events(l_i).EVENT_NAME      := l_cal_events(l_i).event_name;
        x_hr_cal_events(l_i).EVENT_TYPE      := l_cal_events(l_i).event_type;
        x_hr_cal_events(l_i).START_DATE_TIME := l_cal_events(l_i).start_date;
        x_hr_cal_events(l_i).END_DATE_TIME   := l_cal_events(l_i).end_date;
        IF (TO_NUMBER(NVL(l_cal_events(l_i).start_hour,'0')) > 0)
        THEN
          x_hr_cal_events(l_i).START_DATE_TIME := x_hr_cal_events(l_i).START_DATE_TIME + TO_NUMBER(l_cal_events(l_i).start_hour)/24.0;
        END IF;
        IF (TO_NUMBER(NVL(l_cal_events(l_i).start_minute,'0')) > 0)
        THEN
          x_hr_cal_events(l_i).START_DATE_TIME := x_hr_cal_events(l_i).START_DATE_TIME + TO_NUMBER(l_cal_events(l_i).start_minute)/(24.0*60.0);
        END IF;
        IF (TO_NUMBER(NVL(l_cal_events(l_i).end_hour,'0')) > 0)
        THEN
          x_hr_cal_events(l_i).END_DATE_TIME := x_hr_cal_events(l_i).END_DATE_TIME + TO_NUMBER(l_cal_events(l_i).end_hour)/24.0;
        END IF;
        IF (TO_NUMBER(NVL(l_cal_events(l_i).end_minute,'0')) > 0)
        THEN
          x_hr_cal_events(l_i).END_DATE_TIME := x_hr_cal_events(l_i).END_DATE_TIME + TO_NUMBER(l_cal_events(l_i).end_minute)/(24.0*60.0);
        END IF;
      END IF;
      l_i := l_cal_events.NEXT(l_i);
    END LOOP;
  END IF;

END GET_HR_CAL_EVENTS;


END CAC_HR_CAL_EVENTS_PVT;

/
