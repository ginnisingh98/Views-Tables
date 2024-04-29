--------------------------------------------------------
--  DDL for Package Body CAC_AVLBLTY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_AVLBLTY_PVT" AS
/* $Header: caccapb.pls 120.7.12010000.7 2009/01/21 11:57:23 anangupt ship $ */

/*******************************************************************************
** Private APIs
*******************************************************************************/

-- finish get_shift_bands method, use caching of objects
-- add sort for tasks/appointments in case of timezone conversion

TYPE PERIOD_REC_TYPE IS RECORD
( template_detail_id NUMBER
, period_id          NUMBER
, period_span_ms     NUMBER
, day_num            NUMBER
, day_start_ms       NUMBER
);

TYPE PERIOD_TBL_TYPE IS TABLE OF PERIOD_REC_TYPE
  INDEX BY BINARY_INTEGER;

TYPE SCHDL_DETAILS_REC_TYPE IS RECORD
( period_id        NUMBER
, start_date_time  DATE
, end_date_time    DATE
);

TYPE SCHDL_DETAILS_TBL_TYPE IS TABLE OF SCHDL_DETAILS_REC_TYPE
  INDEX BY BINARY_INTEGER;


FUNCTION ADJUST_FOR_TIMEZONE
( p_source_tz_id     IN     NUMBER
, p_dest_tz_id       IN     NUMBER
, p_source_day_time  IN     DATE
)RETURN DATE
IS

  l_dest_day_time    DATE;
  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);

BEGIN
  IF (p_source_day_time IS NOT NULL)
  THEN
    --
    -- Only adjust if the timezones are different and not NULL
    --
    IF (   (p_Source_tz_id IS NOT NULL)
       AND (p_Source_tz_id <> p_dest_tz_id)
       )
    THEN
      --
      -- Call the API to get the adjusted date (this API is slow..)
      --
      HZ_TIMEZONE_PUB.Get_Time( p_api_version     => 1.0
                              , p_init_msg_list   => FND_API.G_FALSE
                              , p_source_tz_id    => p_Source_tz_id
                              , p_dest_tz_id      => p_dest_tz_id
                              , p_source_day_time => p_source_day_time
                              , x_dest_day_time   => l_dest_day_time
                              , x_return_status   => l_return_status
                              , x_msg_count       => l_msg_count
                              , x_msg_data        => l_msg_data
                              );

      RETURN l_dest_day_time;

    ELSE
      RETURN p_source_day_time;

    END IF;
  ELSE
    RETURN p_source_day_time;

  END IF;

END ADJUST_FOR_TIMEZONE;


FUNCTION CONVERT_TO_MILLIS
/*******************************************************************************
**  CONVERT_TO_MILLIS
**
**  Will return the period + UOM in day so it can be added to an Oracle DATE.
*******************************************************************************/
( p_Duration IN NUMBER
, p_UOM      IN VARCHAR2
)RETURN NUMBER

IS

BEGIN
  IF (p_UOM = 'MIN')
  THEN
    RETURN (p_Duration*60*1000);
  ELSIF (p_UOM = 'HR')
  THEN
    RETURN (p_Duration*3600*1000);
  ELSIF (p_UOM = 'DAY')
  THEN
    RETURN (p_Duration*24*3600*1000);
  ELSIF (p_UOM = 'WK')
  THEN
    RETURN (p_Duration*7*24*3600*1000);
  ELSE
    RETURN NULL;
  END IF;
END CONVERT_TO_MILLIS;


FUNCTION GET_SHIFT_BANDS
/*******************************************************************************
**  GET_SHIFT_BANDS
**
**  Will create a new CAC_AVLBLTY_TIME_BAND_VARRAY collection.
*******************************************************************************/
( p_period_id       IN NUMBER
) RETURN CAC_AVLBLTY_TIME_BAND_VARRAY IS

  l_shift_bands        CAC_AVLBLTY_TIME_BAND_VARRAY;

BEGIN

  l_shift_bands := CAC_AVLBLTY_TIME_BAND_VARRAY();

  RETURN l_shift_bands;

END GET_SHIFT_BANDS;

PROCEDURE CREATE_AVLBLTY_SUMMARY
/*******************************************************************************
**  CREATE_AVLBLTY_SUMMARY
**
**  Will create a new object in the CAC_AVLBLTY_SUMMARY_VARRAY collection.
*******************************************************************************/
( p_blank_record    IN BOOLEAN
, p_start_dt        IN DATE
, p_end_dt          IN DATE
, p_category_id     IN NUMBER
, p_category_name   IN VARCHAR2
, p_free_busy       IN VARCHAR2
, p_display_color   IN VARCHAR2
, x_avlblty_summary IN OUT NOCOPY CAC_AVLBLTY_SUMMARY_VARRAY
, x_index           IN OUT NOCOPY NUMBER
) IS

  l_summary_date  DATE;
  l_detail_v      CAC_AVLBLTY_DETAIL_VARRAY;
  l_daytime_v     CAC_AVLBLTY_DAY_TIME_VARRAY;
  l_found_index   BOOLEAN;
  l_last_index    NUMBER;
  l_end_dt        DATE;
  l_dt            DATE;

BEGIN

  IF ((p_blank_record) OR (p_category_id IS NULL))
  THEN
    RETURN;
  END IF;

  IF (x_index IS NULL)
  THEN
    x_index := 0;
  ELSE
    l_summary_date := x_avlblty_summary(x_index).SUMMARY_DATE;
  END IF;

  IF (TRUNC(p_end_dt) > TRUNC(p_start_dt))
  THEN
    l_end_dt := TRUNC(p_start_dt) + 1;
  ELSE
    l_end_dt := p_end_dt;
  END IF;

  IF (TRUNC(p_start_dt) = l_summary_date)
  THEN
    l_found_index := false;
    l_detail_v := x_avlblty_summary(x_index).SUMMARY_LINES;
    FOR i in l_detail_v.first..l_detail_v.last
    LOOP
      IF (l_detail_v(i).PERIOD_CATEGORY_ID = p_category_id)
      THEN
        l_found_index := true;
        l_daytime_v   := l_detail_v(i).DAY_TIMES;
        l_last_index  := l_daytime_v.COUNT;
        IF (l_daytime_v(l_last_index).END_DATE_TIME = p_start_dt)
        THEN
          l_daytime_v(l_last_index).END_DATE_TIME := l_end_dt;
        ELSE
          l_daytime_v.EXTEND(1);
          l_daytime_v(l_last_index+1) := CAC_AVLBLTY_DAY_TIME
                                         (
                                           START_DATE_TIME  => p_start_dt,
                                           END_DATE_TIME    => l_end_dt
                                         );
        END IF;
        l_detail_v(i).TOTAL_TIME_MS := l_detail_v(i).TOTAL_TIME_MS + (l_end_dt-p_start_dt)*24*3600*1000;
        l_detail_v(i).DAY_TIMES     := l_daytime_v;
        EXIT;
      END IF;
    END LOOP;
    IF (NOT l_found_index)
    THEN
      l_last_index := l_detail_v.COUNT;
      l_daytime_v := CAC_AVLBLTY_DAY_TIME_VARRAY();
      l_daytime_v.EXTEND(1);
      l_daytime_v(1) := CAC_AVLBLTY_DAY_TIME
                        (
                          START_DATE_TIME  => p_start_dt,
                          END_DATE_TIME    => l_end_dt
                        );
      l_detail_v.EXTEND(1);
      l_detail_v(l_last_index+1) := CAC_AVLBLTY_DETAIL
                                     (
                                       TOTAL_TIME_MS        => (l_end_dt-p_start_dt)*24*3600*1000,
                                       PERIOD_CATEGORY_ID   => p_category_id,
                                       PERIOD_CATEGORY_NAME => p_category_name,
                                       FREE_BUSY_TYPE       => p_free_busy,
                                       DISPLAY_COLOR        => p_display_color,
                                       DAY_TIMES            => l_daytime_v
                                     );
    END IF;
    x_avlblty_summary(x_index).SUMMARY_LINES := l_detail_v;
  ELSE
    x_index := x_index + 1;
    l_daytime_v := CAC_AVLBLTY_DAY_TIME_VARRAY();
    l_daytime_v.EXTEND(1);
    l_daytime_v(1) := CAC_AVLBLTY_DAY_TIME
                      (
                        START_DATE_TIME  => p_start_dt,
                        END_DATE_TIME    => l_end_dt
                      );
    l_detail_v := CAC_AVLBLTY_DETAIL_VARRAY();
    l_detail_v.EXTEND(1);
    l_detail_v(1) := CAC_AVLBLTY_DETAIL
                     (
                       TOTAL_TIME_MS        => (l_end_dt-p_start_dt)*24*3600*1000,
                       PERIOD_CATEGORY_ID   => p_category_id,
                       PERIOD_CATEGORY_NAME => p_category_name,
                       FREE_BUSY_TYPE       => p_free_busy,
                       DISPLAY_COLOR        => p_display_color,
                       DAY_TIMES            => l_daytime_v
                     );
    x_avlblty_summary.EXTEND(1);
    x_avlblty_summary(x_index) := CAC_AVLBLTY_SUMMARY
                                  (
                                    SUMMARY_DATE  => TRUNC(p_start_dt),
                                    SUMMARY_LINES => l_detail_v
                                  );
  END IF;

  -- loop by incrementing a day
  l_dt := TRUNC(p_start_dt) + 1;
  WHILE (p_end_dt > l_dt)
  LOOP
    l_end_dt := l_dt + 1;
    IF (l_end_dt > p_end_dt)
    THEN
      l_end_dt := p_end_dt;
    END IF;
    x_index := x_index + 1;
    l_daytime_v := CAC_AVLBLTY_DAY_TIME_VARRAY();
    l_daytime_v.EXTEND(1);
    l_daytime_v(1) := CAC_AVLBLTY_DAY_TIME
                      (
                        START_DATE_TIME  => l_dt,
                        END_DATE_TIME    => l_end_dt
                      );
    l_detail_v := CAC_AVLBLTY_DETAIL_VARRAY();
    l_detail_v.EXTEND(1);
    l_detail_v(1) := CAC_AVLBLTY_DETAIL
                     (
                       TOTAL_TIME_MS        => (l_end_dt-l_dt)*24*3600*1000,
                       PERIOD_CATEGORY_ID   => p_category_id,
                       PERIOD_CATEGORY_NAME => p_category_name,
                       FREE_BUSY_TYPE       => p_free_busy,
                       DISPLAY_COLOR        => p_display_color,
                       DAY_TIMES            => l_daytime_v
                     );
    x_avlblty_summary.EXTEND(1);
    x_avlblty_summary(x_index) := CAC_AVLBLTY_SUMMARY
                                  (
                                    SUMMARY_DATE  => TRUNC(l_dt),
                                    SUMMARY_LINES => l_detail_v
                                  );
    l_dt := l_dt + 1;
  END LOOP;

END CREATE_AVLBLTY_SUMMARY;

PROCEDURE CREATE_AVLBLTY_TIME
/*******************************************************************************
**  CREATE_AVLBLTY_TIME
**
**  Will create a new object in the CAC_AVLBLTY_TIME_VARRAY collection.
*******************************************************************************/
( p_blank_record    IN BOOLEAN
, p_period_name     IN VARCHAR2
, p_start_dt        IN DATE
, p_end_dt          IN DATE
, p_duration        IN NUMBER
, p_category_id     IN NUMBER
, p_category_name   IN VARCHAR2
, p_free_busy       IN VARCHAR2
, p_display_color   IN VARCHAR2
, p_update_next     IN BOOLEAN
, p_shift_bands     IN CAC_AVLBLTY_TIME_BAND_VARRAY
, x_avlblty_time    IN OUT NOCOPY CAC_AVLBLTY_TIME_VARRAY
, x_index           IN OUT NOCOPY NUMBER
) IS

  l_start_dt  DATE;

BEGIN
  IF (x_index IS NULL)
  THEN
    x_index := 1;
  ELSE
    IF (p_update_next)
    THEN
      -- see if the previous one should be merged with the current one
      IF (((NOT p_blank_record) AND (x_avlblty_time(x_index).PERIOD_CATEGORY_ID =
        p_category_id)) OR (p_blank_record AND
        x_avlblty_time(x_index).PERIOD_CATEGORY_ID IS NULL))
      THEN
        x_avlblty_time(x_index).END_DATE_TIME := p_end_dt;
        x_avlblty_time(x_index).DURATION_MS := x_avlblty_time(x_index).DURATION_MS +
                                               (p_end_dt-p_start_dt)*24*3600*1000;
        RETURN;
      END IF;
      x_avlblty_time(x_index).NEXT_OBJECT_INDEX := x_index + 1;
      /*IF (x_avlblty_time(x_index).end_date_time < p_start_dt)
      THEN
        l_start_dt := x_avlblty_time(x_index).end_date_time;
        x_index := x_index + 1;
        x_avlblty_time.EXTEND(1);
        x_avlblty_time(x_index) := CAC_AVLBLTY_TIME
                                   (
                                     PERIOD_NAME          => NULL,
                                     START_DATE_TIME      => l_start_dt,
                                     END_DATE_TIME        => p_start_dt,
                                     DURATION_MS          => (p_start_dt-l_start_dt)*24*3600*1000,
                                     PERIOD_CATEGORY_ID   => NULL,
                                     PERIOD_CATEGORY_NAME => NULL,
                                     FREE_BUSY_TYPE       => NULL,
                                     DISPLAY_COLOR        => NULL,
                                     SUPER_OBJECT_INDEX   => NULL,
                                     SHIFT_BANDS          => NULL,
                                     NEXT_OBJECT_INDEX    => x_index+1
                                   );
      END IF;*/
    END IF;
    x_index := x_index + 1;
  END IF;
  x_avlblty_time.EXTEND(1);

  IF (p_blank_record)
  THEN
    x_avlblty_time(x_index) := CAC_AVLBLTY_TIME
                               (
                                 PERIOD_NAME          => NULL,
                                 START_DATE_TIME      => p_start_dt,
                                 END_DATE_TIME        => p_end_dt,
                                 DURATION_MS          => (p_end_dt-p_start_dt)*24*3600*1000,
                                 PERIOD_CATEGORY_ID   => NULL,
                                 PERIOD_CATEGORY_NAME => NULL,
                                 FREE_BUSY_TYPE       => NULL,
                                 DISPLAY_COLOR        => NULL,
                                 SUPER_OBJECT_INDEX   => NULL,
                                 SHIFT_BANDS          => NULL,
                                 NEXT_OBJECT_INDEX    => NULL
                               );
  ELSE
    x_avlblty_time(x_index) := CAC_AVLBLTY_TIME
                               (
                                 PERIOD_NAME          => p_period_name,
                                 START_DATE_TIME      => p_start_dt,
                                 END_DATE_TIME        => p_end_dt,
                                 DURATION_MS          => p_duration,
                                 PERIOD_CATEGORY_ID   => p_category_id,
                                 PERIOD_CATEGORY_NAME => p_category_name,
                                 FREE_BUSY_TYPE       => p_free_busy,
                                 DISPLAY_COLOR        => p_display_color,
                                 SUPER_OBJECT_INDEX   => NULL,
                                 SHIFT_BANDS          => p_shift_bands,
                                 NEXT_OBJECT_INDEX    => NULL
                               );
  END IF;

END CREATE_AVLBLTY_TIME;


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
)
IS

  CURSOR C_SCHEDULE
  (
   b_schdl_cat      VARCHAR2,
   b_object_type    VARCHAR2,
   b_object_id      NUMBER,
   b_start_dt       DATE,
   b_end_dt         DATE,
   b_busy_tentative VARCHAR2
  ) IS
   SELECT  CSSB.SCHEDULE_ID,
           CSSD.START_DATE_TIME,
           CSSD.END_DATE_TIME,
           CSPVL.PERIOD_ID,
           CSPVL.HAS_DETAILS,
           CSPVL.DURATION,
           CSPVL.DURATION_UOM,
           NVL(CSPVL.PERIOD_NAME,FL.MEANING) AS PERIOD_NAME,
           CSPCVL.PERIOD_CATEGORY_ID,
           CSPCVL.PERIOD_CATEGORY_NAME,
           DECODE(CSPCVL.FREE_BUSY_TYPE,'FREE','FREE','BUSY','BUSY',NVL(b_busy_tentative,'TENTATIVE')) FREE_BUSY_TYPE,
           CSPCVL.DISPLAY_COLOR
    FROM CAC_SR_SCHDL_OBJECTS CSSO,
         CAC_SR_SCHEDULES_B CSSB,
         CAC_SR_SCHDL_DETAILS CSSD,
         CAC_SR_PERIODS_VL CSPVL,
         CAC_SR_PERIOD_CATS_VL CSPCVL,
         FND_LOOKUPS FL
    WHERE CSSO.OBJECT_TYPE = b_object_type
    AND CSSO.OBJECT_ID = b_object_id
    AND CSSO.START_DATE_ACTIVE <= b_end_dt
    AND CSSO.END_DATE_ACTIVE >= b_start_dt
    AND CSSO.SCHEDULE_ID = CSSB.SCHEDULE_ID
    AND CSSB.DELETED_DATE IS NULL
    AND (CSSB.SCHEDULE_CATEGORY = b_schdl_cat
         OR CSSB.SCHEDULE_ID IN (SELECT SCHEDULE_ID
                                 FROM CAC_SR_PUBLISH_SCHEDULES
                                 WHERE OBJECT_TYPE = b_object_type
                                 AND OBJECT_ID = b_object_id
                                 AND b_schdl_cat IS NULL
                                ))
    AND CSSD.SCHEDULE_OBJECT_ID = CSSO.SCHEDULE_OBJECT_ID
    AND CSSD.START_DATE_TIME < b_end_dt
    AND CSSD.END_DATE_TIME > b_start_dt
    AND CSPVL.PERIOD_ID = CSSD.PERIOD_ID
    AND CSPCVL.PERIOD_CATEGORY_ID = CSPVL.PERIOD_CATEGORY_ID
    AND FL.LOOKUP_TYPE(+) = 'CAC_SR_WEEK_DAY'
    AND FL.LOOKUP_CODE(+) = CSPVL.week_day_num
    ORDER BY CSSD.START_DATE_TIME;

  CURSOR C_EXCEPTION
  (
   b_schdl_cat      VARCHAR2,
   b_object_type    VARCHAR2,
   b_object_id      NUMBER,
   b_start_dt       DATE,
   b_end_dt         DATE,
   b_busy_tentative VARCHAR2
  ) IS
    SELECT CSEVL.EXCEPTION_ID,
           CSEVL.START_DATE_TIME,
           DECODE(CSEVL.WHOLE_DAY_FLAG,'N',CSEVL.END_DATE_TIME,CSEVL.END_DATE_TIME+1) END_DATE_TIME, -- Add 24 hrs if it's whole day
           CSEVL.EXCEPTION_NAME,
           CSPVL.PERIOD_CATEGORY_ID,
           CSPVL.PERIOD_CATEGORY_NAME,
           DECODE(CSPVL.FREE_BUSY_TYPE,'FREE','FREE','BUSY','BUSY',NVL(b_busy_tentative,'TENTATIVE')) FREE_BUSY_TYPE,
           CSPVL.DISPLAY_COLOR,
           CSEVL.HR_CAL_EVENT_TYPE,
           CSEVL.HR_CAL_EVENT_ID,
           DECODE(CSSE.SCHEDULE_OBJECT_ID,NULL,
             DECODE(CSEVL.HR_CAL_EVENT_TYPE,NULL,
               DECODE(CSEVL.HR_CAL_EVENT_ID,NULL,3,2),1),
             DECODE(CSEVL.HR_CAL_EVENT_TYPE,NULL,
               DECODE(CSEVL.HR_CAL_EVENT_ID,NULL,6,5),4)) LEVEL_IND
    FROM CAC_SR_SCHDL_OBJECTS CSSO,
         CAC_SR_SCHEDULES_B CSSB,
         CAC_SR_SCHDL_EXCEPTIONS CSSE,
         CAC_SR_EXCEPTIONS_VL CSEVL,
         CAC_SR_PERIOD_CATS_VL CSPVL
    WHERE CSSO.OBJECT_TYPE = b_object_type
    AND CSSO.OBJECT_ID = b_object_id
    AND CSSO.START_DATE_ACTIVE <= b_end_dt
    AND CSSO.END_DATE_ACTIVE >= b_start_dt
    AND CSSO.SCHEDULE_ID = CSSB.SCHEDULE_ID
    AND CSSB.DELETED_DATE IS NULL
    AND (CSSB.SCHEDULE_CATEGORY = b_schdl_cat
         OR CSSB.SCHEDULE_ID IN (SELECT SCHEDULE_ID
                                 FROM CAC_SR_PUBLISH_SCHEDULES
                                 WHERE OBJECT_TYPE = b_object_type
                                 AND OBJECT_ID = b_object_id
                                 AND b_schdl_cat IS NULL
                                ))
    AND ( ((CSSE.SCHEDULE_ID = CSSB.SCHEDULE_ID) AND (CSSE.SCHEDULE_OBJECT_ID IS NULL OR CSSE.SCHEDULE_OBJECT_ID = CSSO.SCHEDULE_OBJECT_ID))
        OR CSSE.SCHEDULE_OBJECT_ID = CSSO.SCHEDULE_OBJECT_ID)
    AND CSEVL.EXCEPTION_ID = CSSE.EXCEPTION_ID
    AND CSPVL.PERIOD_CATEGORY_ID = CSEVL.PERIOD_CATEGORY_ID
    ORDER BY LEVEL_IND,CSEVL.START_DATE_TIME;

  l_index          NUMBER;
  l_excp_start_dt  DATE;
  l_excp_end_dt    DATE;
  l_excp_fb        VARCHAR2(30);
  l_schdl_id       NUMBER;
  l_start_dt       DATE;
  l_end_dt         DATE;
  l_period_id      NUMBER;
  l_has_details    VARCHAR2(1);
  l_duration_num   NUMBER;
  l_duration_uom   VARCHAR2(30);
  l_fb             VARCHAR2(30);
  l_duration_ms    NUMBER;
  l_rec_processed  BOOLEAN;
  l_shift_bands    CAC_AVLBLTY_TIME_BAND_VARRAY;
  l_super_recs     CAC_AVLBLTY_TIME_VARRAY;
  l_excp_recs      CAC_AVLBLTY_TIME_VARRAY;
  l_super_index    NUMBER;
  l_period_name    VARCHAR2(2000);
  l_category_id    NUMBER;
  l_category_name  VARCHAR2(2000);
  l_color          VARCHAR2(30);
  l_summary_index  NUMBER;
  l_pre_schedule   BOOLEAN;
  l_temp_end_dt    DATE;
  l_temp_dt        DATE;
  l_excp_idx       NUMBER;
  l_hr_cal_events  CAC_HR_CAL_EVENTS_PVT.HR_CAL_EVENT_TBL_TYPE;
  l_idx            NUMBER;
  l_excp_duration  NUMBER;
  l_temp_excp_rec  CAC_AVLBLTY_TIME;
  l_temp_temp_excp_rec  CAC_AVLBLTY_TIME;
  k NUMBER;

BEGIN

  x_Schedule := CAC_AVLBLTY_TIME_VARRAY();
  x_Schedule_Summary := CAC_AVLBLTY_SUMMARY_VARRAY();
  l_excp_recs := CAC_AVLBLTY_TIME_VARRAY();

  IF (NVL(p_Include_Exception,'T') = 'T')
  THEN
    l_excp_idx := 0;
    FOR ref_excp IN C_EXCEPTION(p_Schdl_Cat,p_Object_Type,p_Object_ID,p_Start_Date_Time,p_End_Date_Time,p_Busy_Tentative)
    LOOP
      l_hr_cal_events.DELETE;
      IF (ref_excp.HR_CAL_EVENT_TYPE IS NOT NULL)
      THEN
        CAC_HR_CAL_EVENTS_PVT.GET_HR_CAL_EVENTS
        (
          p_Object_Type     => p_Object_Type
        , p_Object_ID       => p_Object_ID
        , p_Start_Date      => p_Start_Date_Time
        , p_End_Date        => p_End_Date_Time
        , p_Event_Type      => ref_excp.HR_CAL_EVENT_TYPE
        , p_Event_Id        => NULL
        , x_hr_cal_events   => l_hr_cal_events
        );
      ELSIF (ref_excp.HR_CAL_EVENT_ID IS NOT NULL)
      THEN
        CAC_HR_CAL_EVENTS_PVT.GET_HR_CAL_EVENTS
        (
          p_Object_Type     => p_Object_Type
        , p_Object_ID       => p_Object_ID
        , p_Start_Date      => p_Start_Date_Time
        , p_End_Date        => p_End_Date_Time
        , p_Event_Type      => NULL
        , p_Event_Id        => ref_excp.HR_CAL_EVENT_ID
        , x_hr_cal_events   => l_hr_cal_events
        );
      ELSE
        l_hr_cal_events(1).START_DATE_TIME := ref_excp.START_DATE_TIME;
        l_hr_cal_events(1).END_DATE_TIME := ref_excp.END_DATE_TIME;
      END IF;
      IF (l_hr_cal_events.COUNT > 0)
      THEN
        FOR i IN l_hr_cal_events.FIRST..l_hr_cal_events.LAST
        LOOP
          IF ((l_hr_cal_events(i).END_DATE_TIME > l_hr_cal_events(i).START_DATE_TIME)
            AND NOT (((l_hr_cal_events(i).START_DATE_TIME < p_Start_Date_Time) AND
              (l_hr_cal_events(i).END_DATE_TIME < p_Start_Date_Time)) OR
              ((l_hr_cal_events(i).START_DATE_TIME > p_End_Date_Time) AND
              (l_hr_cal_events(i).END_DATE_TIME > p_End_Date_Time))))
          THEN
            IF (l_excp_idx = 0)
            THEN
             l_excp_recs.EXTEND(1);
              l_excp_idx := 1;
              l_excp_recs(1) := CAC_AVLBLTY_TIME
                               (
                                 PERIOD_NAME          => ref_excp.EXCEPTION_NAME,
                                 START_DATE_TIME      => l_hr_cal_events(i).START_DATE_TIME,
                                 END_DATE_TIME        => l_hr_cal_events(i).END_DATE_TIME,
                                 DURATION_MS          => (l_hr_cal_events(i).END_DATE_TIME-l_hr_cal_events(i).START_DATE_TIME)*24*3600*1000,
                                 PERIOD_CATEGORY_ID   => ref_excp.PERIOD_CATEGORY_ID,
                                 PERIOD_CATEGORY_NAME => ref_excp.PERIOD_CATEGORY_NAME,
                                 FREE_BUSY_TYPE       => ref_excp.FREE_BUSY_TYPE,
                                 DISPLAY_COLOR        => ref_excp.DISPLAY_COLOR,
                                 SUPER_OBJECT_INDEX   => NULL,
                                 SHIFT_BANDS          => NULL,
                                 NEXT_OBJECT_INDEX    => NULL
                               );
            ELSE
              l_idx := l_excp_idx;
              FOR j IN 1..l_idx
              LOOP
                IF (l_hr_cal_events(i).START_DATE_TIME <= l_excp_recs(j).START_DATE_TIME)
                THEN
                  -- move all the items
                  l_temp_excp_rec := l_excp_recs(j);
                  l_excp_recs(j) := CAC_AVLBLTY_TIME
                                   (
                                     PERIOD_NAME          => ref_excp.EXCEPTION_NAME,
                                     START_DATE_TIME      => l_hr_cal_events(i).START_DATE_TIME,
                                     END_DATE_TIME        => l_hr_cal_events(i).END_DATE_TIME,
                                     DURATION_MS          => (l_hr_cal_events(i).END_DATE_TIME-l_hr_cal_events(i).START_DATE_TIME)*24*3600*1000,
                                     PERIOD_CATEGORY_ID   => ref_excp.PERIOD_CATEGORY_ID,
                                     PERIOD_CATEGORY_NAME => ref_excp.PERIOD_CATEGORY_NAME,
                                     FREE_BUSY_TYPE       => ref_excp.FREE_BUSY_TYPE,
                                     DISPLAY_COLOR        => ref_excp.DISPLAY_COLOR,
                                     SUPER_OBJECT_INDEX   => NULL,
                                     SHIFT_BANDS          => NULL,
                                     NEXT_OBJECT_INDEX    => NULL
                                   );
                  k := j+1;
                  WHILE k <= l_idx
                  LOOP
                    IF (l_excp_recs(k).START_DATE_TIME >= l_hr_cal_events(i).END_DATE_TIME)
                    THEN
                      l_temp_temp_excp_rec := l_excp_recs(k);
                      l_excp_recs(k) := l_temp_excp_rec;
                      l_temp_excp_rec := l_temp_temp_excp_rec;
                    ELSE
                      l_temp_excp_rec := NULL;
                      IF (l_excp_recs(k).END_DATE_TIME <= l_hr_cal_events(i).END_DATE_TIME)
                      THEN
                        -- k should be deleted
                        FOR l IN k+1..l_idx
                        LOOP
                          l_excp_recs(k) := l_excp_recs(l);
                        END LOOP;
                        l_excp_recs.trim(1);
                        l_idx := l_idx - 1;
                        l_excp_idx := l_excp_idx - 1;
                        k := k - 1;
                      ELSE
                        -- partial overwritten
                        l_excp_recs(k).START_DATE_TIME := l_hr_cal_events(i).END_DATE_TIME;
                        EXIT;
                      END IF;
                    END IF;
                    k := k + 1;
                  END LOOP;
                  IF (l_temp_excp_rec IS NOT NULL)
                  THEN
                    l_excp_recs.EXTEND(1);
                    l_excp_idx := l_excp_idx + 1;
                    l_excp_recs(l_excp_idx) := l_temp_excp_rec;
                  END IF;
                  l_hr_cal_events(i).START_DATE_TIME := l_hr_cal_events(i).END_DATE_TIME;
                  EXIT;
                ELSE
                  IF (l_hr_cal_events(i).START_DATE_TIME < l_excp_recs(j).END_DATE_TIME)
                  THEN
                    -- overwrite
                    l_excp_recs(j).END_DATE_TIME := l_hr_cal_events(i).START_DATE_TIME;
                  END IF;
                END IF;
              END LOOP;
              IF (l_hr_cal_events(i).END_DATE_TIME > l_hr_cal_events(i).START_DATE_TIME)
              THEN
                l_excp_recs.EXTEND(1);
                l_excp_idx := l_excp_idx + 1;
                l_excp_recs(l_excp_idx) := CAC_AVLBLTY_TIME
                                           (
                                             PERIOD_NAME          => ref_excp.EXCEPTION_NAME,
                                             START_DATE_TIME      => l_hr_cal_events(i).START_DATE_TIME,
                                             END_DATE_TIME        => l_hr_cal_events(i).END_DATE_TIME,
                                             DURATION_MS          => (l_hr_cal_events(i).END_DATE_TIME-l_hr_cal_events(i).START_DATE_TIME)*24*3600*1000,
                                             PERIOD_CATEGORY_ID   => ref_excp.PERIOD_CATEGORY_ID,
                                             PERIOD_CATEGORY_NAME => ref_excp.PERIOD_CATEGORY_NAME,
                                             FREE_BUSY_TYPE       => ref_excp.FREE_BUSY_TYPE,
                                             DISPLAY_COLOR        => ref_excp.DISPLAY_COLOR,
                                             SUPER_OBJECT_INDEX   => NULL,
                                             SHIFT_BANDS          => NULL,
                                             NEXT_OBJECT_INDEX    => NULL
                                           );
              END IF;
            END IF;
          END IF;
        END LOOP;
      END IF;
    END LOOP;
  END IF;

  l_excp_idx := l_excp_recs.first;

  l_pre_schedule := FALSE;
  OPEN C_SCHEDULE(p_Schdl_Cat,p_Object_Type,p_Object_ID,p_Start_Date_Time,p_End_Date_Time,p_Busy_Tentative);
  FETCH C_SCHEDULE
    INTO l_schdl_id, l_start_dt, l_end_dt, l_period_id, l_has_details, l_duration_num, l_duration_uom, l_period_name, l_category_id, l_category_name, l_fb, l_color;

  IF C_SCHEDULE%NOTFOUND
  THEN
    -- no schedule found, so assume free
    l_schdl_id     := NULL;
    l_start_dt     := p_Start_Date_Time;
    l_end_dt       := p_End_Date_Time;
    l_fb           := NULL;
    l_period_id    := NULL;
    l_has_details  := NULL;
    l_duration_num := NULL;
    l_duration_uom := NULL;
    l_period_name  := NULL;
    l_category_id  := NULL;
    l_category_name:= NULL;
    l_color        := NULL;
  ELSIF (l_start_dt > p_Start_Date_Time)
  THEN
    l_pre_schedule := TRUE;
    l_temp_end_dt  := l_end_dt;
    l_end_dt       := l_start_dt;
    l_start_dt     := p_Start_Date_Time;
  ELSIF (l_start_dt < p_Start_Date_Time)
  THEN
    l_start_dt := p_Start_Date_Time;
  END IF;

  -- loop through the schedule data
  WHILE (l_start_dt < p_End_Date_Time)
  LOOP
    -- Reset the records start and end within the query start and end
    IF (l_end_dt > p_End_Date_Time)
    THEN
      l_end_dt := p_End_Date_Time;
    END IF;

    -- Fetch shift bands if needed
    IF (p_return_type IN ('B','D'))
    THEN
      IF ((l_has_details = 'Y') AND (NOT l_pre_schedule))
      THEN
        l_shift_bands := GET_SHIFT_BANDS(l_period_id);
      ELSE
        l_shift_bands := NULL;
      END IF;
    END IF;

    l_rec_processed := FALSE;
    -- loop through the exceptions which lie within the current record
    -- note that if no exception is fetched then l_excp_start_dt will be NULL
    WHILE ((l_excp_idx IS NOT NULL) AND (l_excp_recs(l_excp_idx).START_DATE_TIME < l_end_dt))
    LOOP
      IF (l_excp_recs(l_excp_idx).END_DATE_TIME <= l_start_dt)
      THEN
        -- this exception is before current record so fetch the next one
        -- Note that here we're not checking for p_Include_Exception as
        -- this part will not be executed if the flag is set to false
        -- or there are no exceptions
        l_excp_idx := l_excp_recs.NEXT(l_excp_idx);
      ELSE
        -- this exception ends after the record start
        -- now check how to split the record
        IF (l_excp_recs(l_excp_idx).START_DATE_TIME > l_start_dt)
        THEN
          -- exception starts after the schedule record start
          -- so create a schedule record for the first part
          IF (p_return_type IN ('B','D'))
          THEN
            CREATE_AVLBLTY_TIME
            (
              l_pre_schedule,
              l_period_name,
              l_start_dt,
              l_excp_recs(l_excp_idx).START_DATE_TIME,
              (l_excp_recs(l_excp_idx).START_DATE_TIME - l_start_dt)*24*3600*1000,
              l_category_id,
              l_category_name,
              l_fb,
              l_color,
              true,
              NULL,
              x_Schedule,
              l_index
            );
          END IF;
          IF (p_return_type IN ('B','S'))
          THEN
            CREATE_AVLBLTY_SUMMARY
            (
              l_pre_schedule,
              l_start_dt,
              l_excp_recs(l_excp_idx).START_DATE_TIME,
              l_category_id,
              l_category_name,
              l_fb,
              l_color,
              x_Schedule_Summary,
              l_summary_index
            );
          END IF;
          -- reset the schedule record start to the exception start
          l_start_dt := l_excp_recs(l_excp_idx).START_DATE_TIME;
        END IF;
        -- now check where the exception ends and split the remaining record
        IF (l_excp_recs(l_excp_idx).END_DATE_TIME = l_end_dt)
        THEN
          -- exception ends at the same time, so the whole record will be overwritten
          IF (p_return_type IN ('B','D'))
          THEN
            CREATE_AVLBLTY_TIME
            (
              FALSE,
              l_excp_recs(l_excp_idx).PERIOD_NAME,
              l_start_dt,
              l_end_dt,
              (l_end_dt - l_start_dt)*24*3600*1000,
              l_excp_recs(l_excp_idx).PERIOD_CATEGORY_ID,
              l_excp_recs(l_excp_idx).PERIOD_CATEGORY_NAME,
              l_excp_recs(l_excp_idx).FREE_BUSY_TYPE,
              l_excp_recs(l_excp_idx).DISPLAY_COLOR,
              true,
              NULL,
              x_Schedule,
              l_index
            );
          END IF;
          IF (p_return_type IN ('B','S'))
          THEN
            CREATE_AVLBLTY_SUMMARY
            (
              FALSE,
              l_start_dt,
              l_end_dt,
              l_excp_recs(l_excp_idx).PERIOD_CATEGORY_ID,
              l_excp_recs(l_excp_idx).PERIOD_CATEGORY_NAME,
              l_excp_recs(l_excp_idx).FREE_BUSY_TYPE,
              l_excp_recs(l_excp_idx).DISPLAY_COLOR,
              x_Schedule_Summary,
              l_summary_index
            );
          END IF;
          -- fetch the next exception and quit exception loop
          l_excp_idx := l_excp_recs.NEXT(l_excp_idx);
          -- quit exception loop and go to the next schedule record
          l_rec_processed := TRUE;
          EXIT;
        ELSIF (l_excp_recs(l_excp_idx).END_DATE_TIME > l_end_dt)
        THEN
          -- exception ends after the record, so the whole record will be overwritten
          IF (p_return_type IN ('B','D'))
          THEN
            CREATE_AVLBLTY_TIME
            (
              FALSE,
              l_excp_recs(l_excp_idx).PERIOD_NAME,
              l_start_dt,
              l_end_dt,
              (l_end_dt - l_start_dt)*24*3600*1000,
              l_excp_recs(l_excp_idx).PERIOD_CATEGORY_ID,
              l_excp_recs(l_excp_idx).PERIOD_CATEGORY_NAME,
              l_excp_recs(l_excp_idx).FREE_BUSY_TYPE,
              l_excp_recs(l_excp_idx).DISPLAY_COLOR,
              true,
              NULL,
              x_Schedule,
              l_index
            );
          END IF;
          IF (p_return_type IN ('B','S'))
          THEN
            CREATE_AVLBLTY_SUMMARY
            (
              FALSE,
              l_start_dt,
              l_end_dt,
              l_excp_recs(l_excp_idx).PERIOD_CATEGORY_ID,
              l_excp_recs(l_excp_idx).PERIOD_CATEGORY_NAME,
              l_excp_recs(l_excp_idx).FREE_BUSY_TYPE,
              l_excp_recs(l_excp_idx).DISPLAY_COLOR,
              x_Schedule_Summary,
              l_summary_index
            );
          END IF;
          -- reset the exception to the part where it's not used
          l_excp_recs(l_excp_idx).START_DATE_TIME := l_end_dt;
          -- quit exception loop and go to the next schedule record
          l_rec_processed := TRUE;
          EXIT;
        ELSE
          -- exception ends before the end of the record, so split into two
          IF (p_return_type IN ('B','D'))
          THEN
            CREATE_AVLBLTY_TIME
            (
              FALSE,
              l_excp_recs(l_excp_idx).PERIOD_NAME,
              l_start_dt,
              l_excp_recs(l_excp_idx).END_DATE_TIME,
              (l_excp_recs(l_excp_idx).END_DATE_TIME - l_start_dt)*24*3600*1000,
              l_excp_recs(l_excp_idx).PERIOD_CATEGORY_ID,
              l_excp_recs(l_excp_idx).PERIOD_CATEGORY_NAME,
              l_excp_recs(l_excp_idx).FREE_BUSY_TYPE,
              l_excp_recs(l_excp_idx).DISPLAY_COLOR,
              true,
              NULL,
              x_Schedule,
              l_index
            );
          END IF;
          IF (p_return_type IN ('B','S'))
          THEN
            CREATE_AVLBLTY_SUMMARY
            (
              FALSE,
              l_start_dt,
              l_excp_recs(l_excp_idx).END_DATE_TIME,
              l_excp_recs(l_excp_idx).PERIOD_CATEGORY_ID,
              l_excp_recs(l_excp_idx).PERIOD_CATEGORY_NAME,
              l_excp_recs(l_excp_idx).FREE_BUSY_TYPE,
              l_excp_recs(l_excp_idx).DISPLAY_COLOR,
              x_Schedule_Summary,
              l_summary_index
            );
          END IF;
          -- this is the second part. there could possibly be more exceptions
          -- in this part, so set the start of the record to the end of
          -- exception and fetch the next exception
          l_start_dt := l_excp_recs(l_excp_idx).END_DATE_TIME;
          l_excp_idx := l_excp_recs.NEXT(l_excp_idx);
        END IF;
      END IF;
    END LOOP;
    -- now create an item if the record was not completely processed
    IF NOT l_rec_processed
    THEN
      l_duration_ms := CONVERT_TO_MILLIS(l_duration_num,l_duration_uom);
      -- use the minimum of the durations
      IF (((l_end_dt - l_start_dt)*24*3600*1000) > NVL(l_duration_ms,0))
      THEN
        l_duration_ms := (l_end_dt - l_start_dt)*24*3600*1000;
      END IF;
      IF (p_return_type IN ('B','D'))
      THEN
        CREATE_AVLBLTY_TIME
        (
          l_pre_schedule,
          l_period_name,
          l_start_dt,
          l_end_dt,
          l_duration_ms,
          l_category_id,
          l_category_name,
          l_fb,
          l_color,
          true,
          NULL,
          x_Schedule,
          l_index
        );
      END IF;
      IF (p_return_type IN ('B','S'))
      THEN
        CREATE_AVLBLTY_SUMMARY
        (
          l_pre_schedule,
          l_start_dt,
          l_end_dt,
          l_category_id,
          l_category_name,
          l_fb,
          l_color,
          x_Schedule_Summary,
          l_summary_index
        );
      END IF;
    END IF;
    IF (l_pre_schedule)
    THEN
      l_pre_schedule := FALSE;
      l_start_dt     := l_end_dt;
      l_end_dt       := l_temp_end_dt;
      -- if there was an schedule then fetch the next record or else just quit
    ELSIF (l_schdl_id IS NOT NULL)
    THEN
      l_temp_end_dt  := l_end_dt;
      FETCH C_SCHEDULE
        INTO l_schdl_id, l_start_dt, l_end_dt, l_period_id, l_has_details, l_duration_num, l_duration_uom, l_period_name, l_category_id, l_category_name, l_fb, l_color;
      IF C_SCHEDULE%NOTFOUND
      THEN
        l_schdl_id     := NULL;
        l_start_dt     := l_end_dt;
        l_end_dt       := p_End_Date_Time;
        l_fb           := NULL;
        l_period_id    := NULL;
        l_has_details  := NULL;
        l_duration_num := NULL;
        l_duration_uom := NULL;
        l_period_name  := NULL;
        l_category_id  := NULL;
        l_category_name:= NULL;
        l_color        := NULL;
      ELSE
        IF (l_start_dt > l_temp_end_dt)
        THEN
          l_temp_dt      := l_start_dt;
          l_start_dt     := l_temp_end_dt;
          l_temp_end_dt  := l_end_dt;
          l_end_dt       := l_temp_dt;
          l_pre_schedule := TRUE;
        END IF;
      END IF;
    ELSE
      EXIT;
    END IF;
  END LOOP;

  IF C_SCHEDULE%ISOPEN
  THEN
    CLOSE C_SCHEDULE;
  END IF;

  IF C_EXCEPTION%ISOPEN
  THEN
    CLOSE C_EXCEPTION;
  END IF;

END GET_SCHEDULE_DATA;


/**
PROCEDURE getBookingData
/*******************************************************************************
**
** getBookingData
**
**   returns all Bookings and appointments in task tables for the given:
**   - Object Instance
**   - Period
**
*******************************************************************************
( p_api_version         IN     NUMBER                -- API version you coded against
, p_init_msg_list       IN     VARCHAR2 DEFAULT 'F'  -- Create a new error stack?
, p_ObjectType          IN     VARCHAR2              -- JTF OBJECTS type of the Object being queried
, p_ObjectID            IN     NUMBER                -- JTF OBJECTS select ID of the Object Instance being queried
, p_PeriodStartDateTime IN     DATE                  -- start date and time of period of interest
, p_PeriodEndDateTime   IN     DATE                  -- end date and time of period of interest
, p_OpagueBkngCat       IN     JTF_NUMBER_TABLE      -- Booking Categories (i.e. task types) that should be considered OPAGUE
, p_BookingStatus       IN     VARCHAR2              -- Are we looking for Firm or Soft bookings
, p_BusyTentative       IN     VARCHAR2              -- How to treat FREEBUSYTIME objects with FREEBUSYTYPE = BUSY TENTATIVE?
                                                     -- FREE: BUSY TENTATIVE means FREE
                                                     -- BUSY: BUSY TENTATIVE means BUSY
                                                     -- NULL: leave the interpretation to caller
, x_BookingData         IN OUT CAC_SR_FREEBUSYTIME_VARRAY
                                                     -- returns the existings bookings for the Object Instance
, x_return_status          OUT NOCOPY VARCHAR2              -- 'S': API completed without errors
                                                     -- 'E': API completed with recoverable errors; explanation on errorstack (Warnings)
                                                     -- 'U': API completed with UN recoverable errors: error message on error stack
, x_msg_count              OUT NOCOPY NUMBER                -- Number of messages on the errorstack, if 1 then x_msg_data contains the message
, x_msg_data               OUT NOCOPY VARCHAR2              -- contains message if x_msg_count = 1
)
IS
 TYPE c_Bookings_type IS REF CURSOR;

  c_Bookings  c_Bookings_type;

  l_FreeBusyTime   CAC_SR_FREEBUSYTIME;

  i NUMBER := 0;

  --
  -- This is the base query for picking up all opague records from the task table
  --
  l_query  VARCHAR2(2000) :=

  'SELECT GREATEST( CAC_AVLBLTY_PVT.AdjustForTimezone( jtb.timezone_id '          ||
                                                    ', :b_ToTimeZone '            ||
                                                    ', jtb.calendar_start_date '  ||
                                                    ') '                          ||
                 ', :b_PeriodStartDateTime '                                      ||
                 ') StartDateTime '                                               ||
  ',         LEAST( CAC_AVLBLTY_PVT.AdjustForTimezone( jtb.timezone_id '          ||
                                                    ', :b_ToTimeZone '            ||
                                                    ', jtb.calendar_end_date '    ||
                                                    ') '                          ||
                 ', :b_PeriodEndDateTime '                                        ||
                 ') EndDateTime '                                                 ||
  ',      DECODE( jta.free_busy_type, ''FREE'',''FREE'' '                         ||
                                   ', ''BUSY'',''BUSY'' '                         ||
                                   ', ''TENTATIVE'',NVL(:b_BusyTentative,''TENTATIVE'') '       ||
                                   ')                               FBType '      ||
  ',      jtb.task_type_id                                          CategoryID '  ||
  ',      jtb.entity                                                CategoryType '||
  'FROM jtf_task_all_assignments  jta '                                           ||
  ',    jtf_tasks_b               jtb '                                           ||
  ',    ( SELECT jts.task_status_id '                                             ||
  '       FROM   jtf_task_statuses_b jts '                                        ||
  '       WHERE  jts.assignment_status_flag    = ''Y'' '                          ||
  '       AND    NVL(jts.closed_flag,''N'')    = ''N'' '                          ||
  '       AND    NVL(jts.completed_flag,''N'') = ''N'' '                          ||
  '       AND    NVL(jts.rejected_flag,''N'')  = ''N'' '                          ||
  '       AND    NVL(jts.on_hold_flag,''N'')   = ''N'' '                          ||
  '       AND    NVL(jts.cancelled_flag,''N'') = ''N'' '                          ||
  '     ) jto '                                                                   ||
  'WHERE jta.resource_type_code   = :b_ObjectType '                               ||
  'AND   jta.resource_id          = :b_ObjectID '                                 ||
  'AND   jta.assignment_status_id = jto.task_status_id '                          ||
  'AND   jta.task_id              = jtb.task_id '                                 ||
  'AND   jtb.open_flag            = ''Y'' '                                       ||
  'AND   jtb.calendar_end_date   >= :b_StartDate '                                ||
  'AND   jtb.calendar_start_date <= :b_EndDate '                                  ||
  'AND   jtb.entity IN (''BOOKING'',''TASK'',''APPOINTMENT'') '; -- Add appointment here once they go to servertimezone

  l_opague VARCHAR2(2000);
  l_status VARCHAR2(200);
  l_order  VARCHAR2(200) := 'ORDER BY 1';

  l_ServerTimeZone NUMBER := TO_NUMBER(FND_PROFILE.Value('SERVER_TIMEZONE_ID'));

BEGIN

  IF (x_BookingData IS NULL)
  THEN
    x_BookingData := CAC_SR_FREEBUSYTIME_VARRAY();
  END IF;

  --
  -- the list of OPAGUE tasks may have been restricted to the booking categories
  -- (task types) in p_OpagueXcptnPeriodCat
  --
  IF ((p_OpagueBkngCat IS NOT NULL) AND (p_OpagueBkngCat.COUNT > 0))
  THEN
    l_opague := 'AND jtb.task_type_id IN (';
    FOR i IN 1..p_OpagueBkngCat.LAST
    LOOP
      IF (i < p_OpagueBkngCat.LAST)
      THEN
        l_opague := l_opague || p_OpagueBkngCat(i)||',';
      ELSE
        l_opague := l_opague || p_OpagueBkngCat(i)||') ';
      END IF;
    END LOOP;
  END IF;

  --
  -- We'll need to change the query to look for either Firm or Soft bookings:
  -- - free_busy_type = 'BUSY' means the booking is Firm
  -- - free_busy_type = 'TENTATIVE' means the booking is Soft
  --
  IF (p_BookingStatus IS NOT NULL)
  THEN
    l_status := 'AND   jta.free_busy_type = '''||p_BookingStatus||''' ';

  END IF;

  --
  -- Build the query
  --
  l_query := l_query || l_opague || l_Status || l_order;

  --
  -- Initialize the  CAC_SR_FREEBUSYTIME object
  --
  l_FreeBusyTime := CAC_SR_FREEBUSYTIME(NULL,NULL,NULL,NULL,NULL);

  OPEN c_Bookings FOR l_query USING l_ServerTimeZone
                              ,     (p_PeriodStartDateTime - 1)  -- for timezone adjustments
                              ,     l_ServerTimeZone
                              ,     (p_PeriodEndDateTime + 1)  -- for timezone adjustments
                              ,     p_BusyTentative
                              ,     p_ObjectType
                              ,     p_ObjectID
                              ,     (p_PeriodStartDateTime - 1)  -- for timezone adjustments
                              ,     (p_PeriodEndDateTime + 1);  -- for timezone adjustments

  <<BOOKINGS>>
  LOOP -- Bookings
    FETCH c_Bookings INTO l_FreeBusyTime.StartDatetime
                     ,    l_FreeBusyTime.EndDateTime
                     ,    l_FreeBusyTime.FBType
                     ,    l_FreeBusyTime.CategoryID
                     ,    l_FreeBusyTime.CategoryType;

    IF (c_Bookings%FOUND)
    THEN
      --
      -- If after timezone adjustment it is still within the query period use it
      --
      IF  (   ( l_FreeBusyTime.StartDatetime <= p_PeriodEndDateTime )
          AND ( l_FreeBusyTime.EndDateTime   >  p_PeriodStartDateTime)
          )
      THEN
        --
        -- stick it in FreeBusyList
        --
        Extend( p_varray  => x_BookingData
              , p_element => l_FreeBusyTime
              , p_index   => i
              );
      END IF;

    ELSE -- (c_Bookings%NOTFOUND)
      CLOSE c_Bookings;
      EXIT BOOKINGS; -- exit Bookings loop

    END IF;
  END LOOP;-- end Bookings loop

  --
  -- Remove any null element that extend may have added
  --
  Trim( p_varray  => x_BookingData
      , p_index   => i
      );

END getBookingData;
**/


PROCEDURE INSERT_SCHEDULE_DETAILS
/*******************************************************************************
**
** INSERT_SCHEDULE_DETAILS
**
** popluates the schedule details table from the pl/sql table
**
*******************************************************************************/
( p_Schedule_Id          IN     NUMBER               -- id of the schedule
, p_Schedule_Object_Id   IN     NUMBER
, p_Schedule_Details     IN     SCHDL_DETAILS_TBL_TYPE
) IS

  l_created_by         NUMBER;
  l_creation_date      DATE;
  l_last_updated_by    NUMBER;
  l_last_update_date   DATE;
  l_last_update_login  NUMBER;

BEGIN

  l_created_by         := FND_GLOBAL.USER_ID;
  l_creation_date      := SYSDATE;
  l_last_updated_by    := FND_GLOBAL.USER_ID;
  l_last_update_date   := SYSDATE;
  l_last_update_login  := FND_GLOBAL.LOGIN_ID;

  FOR i IN p_Schedule_Details.FIRST..p_Schedule_Details.LAST
  LOOP
    INSERT INTO CAC_SR_SCHDL_DETAILS
    (
      SCHEDULE_DETAIL_ID,
      SCHEDULE_ID,
      SCHEDULE_OBJECT_ID,
      PERIOD_ID,
      START_DATE_TIME,
      END_DATE_TIME,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN
    )
    VALUES
    (
      CAC_SR_SCHDL_DETAILS_S.NEXTVAL,
      p_schedule_id,
      p_schedule_object_id,
      p_Schedule_Details(i).period_id,
      p_Schedule_Details(i).start_date_time,
      p_Schedule_Details(i).end_date_time,
      l_created_by,
      l_creation_date,
      l_last_updated_by,
      l_last_update_date,
      l_last_update_login
    );
  END LOOP;

END INSERT_SCHEDULE_DETAILS;


PROCEDURE CREATE_PERIOD_DATA_DUR
/*******************************************************************************
**
** CREATE_PERIOD_DATA_DUR
**
** popluates the period data pl/sql table by expanding the template
** should be called for duration based template
**
*******************************************************************************/
( p_tmpl_id         IN  NUMBER
, x_period_data     OUT NOCOPY PERIOD_TBL_TYPE
) IS

  CURSOR C_TMPL_DETAILS
  (
    b_tmpl_id    NUMBER
  ) IS
  SELECT DTLS.TEMPLATE_DETAIL_ID,
         DTLS.TEMPLATE_DETAIL_SEQ,
         DTLS.TEMPLATE_ID,
         DTLS.CHILD_PERIOD_ID,
         DTLS.CHILD_TEMPLATE_ID,
         CSPB.DURATION,
         CSPB.DURATION_UOM
  FROM CAC_SR_PERIODS_B CSPB,
        (SELECT CSTD.TEMPLATE_DETAIL_ID,
               CSTD.TEMPLATE_DETAIL_SEQ,
               CSTD.TEMPLATE_ID,
               CSTD.CHILD_PERIOD_ID,
               CSTD.CHILD_TEMPLATE_ID
        FROM CAC_SR_TMPL_DETAILS CSTD
        START WITH CSTD.TEMPLATE_ID = b_tmpl_id
        CONNECT BY PRIOR CSTD.CHILD_TEMPLATE_ID = CSTD.TEMPLATE_ID
        ORDER SIBLINGS BY TEMPLATE_DETAIL_SEQ) DTLS
  WHERE CSPB.PERIOD_ID(+) = DTLS.CHILD_PERIOD_ID
  ORDER BY TEMPLATE_DETAIL_SEQ;     --ADDED FOR BUG#7491187


  i         BINARY_INTEGER;

BEGIN

  i := 0;

  FOR REF_TMPL_DTLS IN C_TMPL_DETAILS(p_tmpl_id)
  LOOP
    IF (REF_TMPL_DTLS.CHILD_PERIOD_ID IS NOT NULL)
    THEN
      -- this is a period, so add a new record
      i:= i+1;
      x_period_data(i).template_detail_id := REF_TMPL_DTLS.TEMPLATE_DETAIL_ID;
      x_period_data(i).period_id          := REF_TMPL_DTLS.CHILD_PERIOD_ID;
      x_period_data(i).period_span_ms     := CONVERT_TO_MILLIS(REF_TMPL_DTLS.DURATION,REF_TMPL_DTLS.DURATION_UOM);
    ELSE
      -- this is a template, so add a dummy record
      i:= i+1;
      x_period_data(i).template_detail_id := REF_TMPL_DTLS.TEMPLATE_DETAIL_ID;
      x_period_data(i).period_id          := NULL;
      x_period_data(i).period_span_ms     := 0;
    END IF;
  END LOOP;

END CREATE_PERIOD_DATA_DUR;


PROCEDURE CREATE_PERIOD_DATA_CAL
/*******************************************************************************
**
** CREATE_PERIOD_DATA_CAL
**
** popluates the period data pl/sql table by expanding the template
** should be called for calendar based template
**
*******************************************************************************/
( p_tmpl_id         IN  NUMBER
, p_tmpl_length     IN  NUMBER
, x_period_data     OUT NOCOPY PERIOD_TBL_TYPE
) IS

  CURSOR C_TMPL_DETAILS
  (
    b_tmpl_id    NUMBER
  ) IS
  SELECT DTLS.TEMPLATE_DETAIL_ID,
         DTLS.TEMPLATE_DETAIL_SEQ,
         DTLS.TEMPLATE_ID,
         DTLS.CHILD_PERIOD_ID,
         DTLS.CHILD_TEMPLATE_ID,
         CSPB.WEEK_DAY_NUM,
         CSPB.START_TIME_MS,
         CSPB.DURATION,
         CSPB.DURATION_UOM,
         CSTB.TEMPLATE_LENGTH_DAYS
  FROM CAC_SR_TEMPLATES_B CSTB,
        CAC_SR_PERIODS_B CSPB,
        (SELECT CSTD.TEMPLATE_DETAIL_ID,
               CSTD.TEMPLATE_DETAIL_SEQ,
               CSTD.TEMPLATE_ID,
               CSTD.CHILD_PERIOD_ID,
               CSTD.CHILD_TEMPLATE_ID
        FROM CAC_SR_TMPL_DETAILS CSTD
        START WITH CSTD.TEMPLATE_ID = b_tmpl_id
        CONNECT BY PRIOR CSTD.CHILD_TEMPLATE_ID = CSTD.TEMPLATE_ID
        ORDER SIBLINGS BY TEMPLATE_DETAIL_SEQ) DTLS
  WHERE CSTB.TEMPLATE_ID(+) = DTLS.CHILD_TEMPLATE_ID
  AND CSPB.PERIOD_ID(+) = DTLS.CHILD_PERIOD_ID
  ORDER BY  TEMPLATE_DETAIL_SEQ;    --ADDED FOR BUG#7491187

  i                     BINARY_INTEGER;
  i_first               BINARY_INTEGER;
  i_last                BINARY_INTEGER;
  l_last_tmpl_id        NUMBER;
  l_last_tmpl_length_ms NUMBER;
  l_total_length_ms     NUMBER;
  l_duration_gap_ms     NUMBER;

BEGIN

  i := 0;
  l_total_length_ms     := 0;
  -- do we need length based logic? it seems, it'll work without it
  l_last_tmpl_id        := p_tmpl_id;
  l_last_tmpl_length_ms := p_tmpl_length * 24 * 3600 * 1000;

  FOR REF_TMPL_DTLS IN C_TMPL_DETAILS(p_tmpl_id)
  LOOP
    IF (REF_TMPL_DTLS.CHILD_PERIOD_ID IS NOT NULL)
    THEN
      -- this is a period, so add a new record
      -- but before that check if there is a gap between the
      -- previous record and this one and fill it
      IF (i > 0)
      THEN
        -- calculate the gap
        IF (REF_TMPL_DTLS.WEEK_DAY_NUM >= x_period_data(i).day_num)
        THEN
          l_duration_gap_ms := (REF_TMPL_DTLS.WEEK_DAY_NUM - x_period_data(i).day_num) * 24 * 3600 * 1000
                               + REF_TMPL_DTLS.START_TIME_MS - x_period_data(i).day_start_ms
                               - x_period_data(i).period_span_ms;
        ELSE
          l_duration_gap_ms := (7 + REF_TMPL_DTLS.WEEK_DAY_NUM - x_period_data(i).day_num) * 24 * 3600 * 1000
                               + REF_TMPL_DTLS.START_TIME_MS - x_period_data(i).day_start_ms
                               - x_period_data(i).period_span_ms;
        END IF;
        IF (l_duration_gap_ms > 0)
        THEN
          -- create a new record for this gap
          i:= i+1;
          x_period_data(i).template_detail_id := NULL;
          x_period_data(i).period_id          := NULL;
          x_period_data(i).period_span_ms     := l_duration_gap_ms;
          x_period_data(i).day_start_ms       := NULL;
          x_period_data(i).day_num            := NULL;
          -- increment the total length
          l_total_length_ms := l_total_length_ms + x_period_data(i).period_span_ms;
        END IF;
      ELSE
        -- this is the first record
        -- so prefill the array assuming week starts on sunday
        l_duration_gap_ms := (REF_TMPL_DTLS.WEEK_DAY_NUM - 1)*24*3600*1000 + REF_TMPL_DTLS.START_TIME_MS;
        IF (l_duration_gap_ms > 0)
        THEN
          -- create a new record for this gap
          i:= i+1;
          x_period_data(i).template_detail_id := NULL;
          x_period_data(i).period_id          := NULL;
          x_period_data(i).period_span_ms     := l_duration_gap_ms;
          x_period_data(i).day_start_ms       := 0;
          x_period_data(i).day_num            := 1;
          -- increment the total length
          l_total_length_ms := l_total_length_ms + x_period_data(i).period_span_ms;
        END IF;
      END IF;
      -- create an actual period record
      i:= i+1;
      x_period_data(i).template_detail_id := REF_TMPL_DTLS.TEMPLATE_DETAIL_ID;
      x_period_data(i).period_id          := REF_TMPL_DTLS.CHILD_PERIOD_ID;
      x_period_data(i).period_span_ms     := CONVERT_TO_MILLIS(REF_TMPL_DTLS.DURATION,REF_TMPL_DTLS.DURATION_UOM);
      x_period_data(i).day_start_ms       := REF_TMPL_DTLS.START_TIME_MS;
      x_period_data(i).day_num            := REF_TMPL_DTLS.WEEK_DAY_NUM;
      -- increment the total length
      l_total_length_ms := l_total_length_ms + x_period_data(i).period_span_ms;
    ELSE
      -- this is a template, so store the tmpl id and length for future records
      l_last_tmpl_id        := REF_TMPL_DTLS.CHILD_TEMPLATE_ID;
      l_last_tmpl_length_ms := REF_TMPL_DTLS.TEMPLATE_LENGTH_DAYS * 24 * 3600 * 1000;
      -- also create a dummy row
      IF (i = 0)
      THEN
        i := 1;
        x_period_data(i).template_detail_id := REF_TMPL_DTLS.TEMPLATE_DETAIL_ID;
        x_period_data(i).period_id          := NULL;
        x_period_data(i).period_span_ms     := 0;
        x_period_data(i).day_start_ms       := 0;
        x_period_data(i).day_num            := 1;
      ELSE
        i := i+1;
        x_period_data(i).template_detail_id := REF_TMPL_DTLS.TEMPLATE_DETAIL_ID;
        x_period_data(i).period_id          := NULL;
        x_period_data(i).period_span_ms     := 0;
        x_period_data(i).day_start_ms       := x_period_data(i-1).day_start_ms + x_period_data(i-1).period_span_ms;
        x_period_data(i).day_num            := x_period_data(i-1).day_num;
        --reset if it's crossing the day
        IF (x_period_data(i).day_start_ms > 24 * 3600 * 1000)
        THEN
          x_period_data(i).day_num      := x_period_data(i).day_num + TRUNC(x_period_data(i).day_start_ms / (24 * 3600 * 1000));
          x_period_data(i).day_start_ms := x_period_data(i).day_start_ms - (x_period_data(i).day_num - x_period_data(i-1).day_num) * 24 * 3600 * 1000;
          IF (x_period_data(i).day_num > 7)
          THEN
            x_period_data(i).day_num    := x_period_data(i).day_num - 7;
          END IF;
        END IF;
      END IF;
    END IF;
  END LOOP;

  -- now calculate the gap between the first and last record and
  -- fill it so that the template becomes curcular
  IF (i > 0)
  THEN
    l_duration_gap_ms := p_tmpl_length * 24 * 3600 * 1000 - l_total_length_ms;
    IF (l_duration_gap_ms > 0)
    THEN
      -- create a new record for this gap
      i:= i+1;
      x_period_data(i).template_detail_id := NULL;
      x_period_data(i).period_id          := NULL;
      x_period_data(i).period_span_ms     := l_duration_gap_ms;
      x_period_data(i).day_start_ms       := NULL;
      x_period_data(i).day_num            := NULL;
    END IF;
  END IF;

END CREATE_PERIOD_DATA_CAL;


PROCEDURE CREATE_PERIOD_DATA_DAY
/*******************************************************************************
**
** CREATE_PERIOD_DATA_DAY
**
** popluates the period data pl/sql table by expanding the template
** should be called for day based template
**
*******************************************************************************/
( p_tmpl_id         IN  NUMBER
, p_tmpl_length     IN  NUMBER
, x_period_data     OUT NOCOPY PERIOD_TBL_TYPE
) IS

  CURSOR C_TMPL_DETAILS
  (
    b_tmpl_id    NUMBER
  ) IS
  SELECT DTLS.TEMPLATE_DETAIL_ID,
         DTLS.TEMPLATE_DETAIL_SEQ,
         DTLS.TEMPLATE_ID,
         DTLS.CHILD_PERIOD_ID,
         DTLS.CHILD_TEMPLATE_ID,
         DTLS.DAY_START,
         DTLS.DAY_STOP,
         CSPB.START_TIME_MS,
         CSPB.END_TIME_MS,
         CSPB.DURATION,
         CSPB.DURATION_UOM
  FROM CAC_SR_PERIODS_B CSPB,
        (SELECT CSTD.TEMPLATE_DETAIL_ID,
               CSTD.TEMPLATE_DETAIL_SEQ,
               CSTD.TEMPLATE_ID,
               CSTD.CHILD_PERIOD_ID,
               CSTD.CHILD_TEMPLATE_ID,
               CSTD.DAY_START,
               CSTD.DAY_STOP
        FROM CAC_SR_TMPL_DETAILS CSTD
        START WITH CSTD.TEMPLATE_ID = b_tmpl_id
        CONNECT BY PRIOR CSTD.CHILD_TEMPLATE_ID = CSTD.TEMPLATE_ID
        ORDER SIBLINGS BY TEMPLATE_DETAIL_SEQ) DTLS
  WHERE CSPB.PERIOD_ID(+) = DTLS.CHILD_PERIOD_ID
  ORDER BY CHILD_PERIOD_ID NULLS FIRST , TEMPLATE_DETAIL_SEQ;  --ADDED FOR BUG#7491187
                                                               --MODIFIED FOR BUG#7758438

  TYPE NUMBER_TBL_TYPE IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  i                     BINARY_INTEGER;
  l_tmpl_offset         NUMBER_TBL_TYPE;
  l_period_data         PERIOD_TBL_TYPE;
  l_duration_gap_ms     NUMBER;

BEGIN

  i := 0;
  l_tmpl_offset(p_tmpl_id) := 0;

  FOR REF_TMPL_DTLS IN C_TMPL_DETAILS(p_tmpl_id)
  LOOP
    IF (REF_TMPL_DTLS.CHILD_PERIOD_ID IS NOT NULL)
    THEN
      -- this is a period, so add a new record
      FOR ref_i IN REF_TMPL_DTLS.DAY_START..REF_TMPL_DTLS.DAY_STOP
      LOOP
        i := i+1;
        l_period_data(i).template_detail_id := REF_TMPL_DTLS.TEMPLATE_DETAIL_ID;
        l_period_data(i).period_id          := REF_TMPL_DTLS.CHILD_PERIOD_ID;
        IF (REF_TMPL_DTLS.DURATION IS NULL)
        THEN
          l_period_data(i).period_span_ms   := REF_TMPL_DTLS.END_TIME_MS - REF_TMPL_DTLS.START_TIME_MS;
        ELSE
          l_period_data(i).period_span_ms   := CONVERT_TO_MILLIS(REF_TMPL_DTLS.DURATION,REF_TMPL_DTLS.DURATION_UOM);
        END IF;
        l_period_data(i).day_start_ms       := NVL(REF_TMPL_DTLS.START_TIME_MS,0);
        l_period_data(i).day_num            := l_tmpl_offset(REF_TMPL_DTLS.TEMPLATE_ID) + ref_i;
      END LOOP;
    ELSE
      -- this is a template, so store the tmpl offset for future records
      l_tmpl_offset(REF_TMPL_DTLS.CHILD_TEMPLATE_ID) := REF_TMPL_DTLS.DAY_START - 1;
      -- add a dummy record
      l_period_data(i).template_detail_id := REF_TMPL_DTLS.TEMPLATE_DETAIL_ID;
      l_period_data(i).period_id          := NULL;
      l_period_data(i).day_start_ms       := 0;
      l_period_data(i).day_num            := REF_TMPL_DTLS.DAY_START;
      l_period_data(i).period_span_ms     := 0;
    END IF;
  END LOOP;

  i := 0;
  -- loop through the entire template length, find periods for those
  -- days and fill up gaps
  FOR ref_i IN 1..p_tmpl_length
  LOOP
    FOR ref_j IN l_period_data.FIRST..l_period_data.LAST
    LOOP
      IF (ref_i = l_period_data(ref_j).day_num)
      THEN
        IF (i = 0)
        THEN
          -- this is the first record being added
          -- check if it needs to be prefilled
          l_duration_gap_ms := (ref_i - 1) * 24 * 3600 * 1000
                               + l_period_data(ref_j).day_start_ms;
          IF (l_duration_gap_ms > 0)
          THEN
            i := 1;
            x_period_data(i).template_detail_id := NULL;
            x_period_data(i).period_id          := NULL;
            x_period_data(i).period_span_ms     := l_duration_gap_ms;
            x_period_data(i).day_start_ms       := 0;
            x_period_data(i).day_num            := 1;
          END IF;
        ELSE
          -- check if there is any gap between this and the previous record
          -- and fill it
          l_duration_gap_ms := (ref_i - x_period_data(i).day_num) * 24 * 3600 * 1000
                               - (x_period_data(i).day_start_ms + x_period_data(i).period_span_ms)
                               + l_period_data(ref_j).day_start_ms;
          IF (l_duration_gap_ms > 0)
          THEN
            i := i+1;
            x_period_data(i).template_detail_id := NULL;
            x_period_data(i).period_id          := NULL;
            x_period_data(i).period_span_ms     := l_duration_gap_ms;
            x_period_data(i).day_start_ms       := NULL;
            x_period_data(i).day_num            := NULL;
          END IF;
        END IF;
        i := i+1;
        x_period_data(i).template_detail_id := l_period_data(ref_j).template_detail_id;
        x_period_data(i).period_id          := l_period_data(ref_j).period_id;
        x_period_data(i).period_span_ms     := l_period_data(ref_j).period_span_ms;
        x_period_data(i).day_start_ms       := l_period_data(ref_j).day_start_ms;
        x_period_data(i).day_num            := l_period_data(ref_j).day_num;
      END IF;
    END LOOP;
  END LOOP;

  -- check if the last part needs to be filled
  -- i should be the last index
  IF (i = 0)
  THEN
    x_period_data(1).template_detail_id := NULL;
    x_period_data(1).period_id          := NULL;
    x_period_data(1).period_span_ms     := p_tmpl_length * 24 * 3600 * 1000;
    x_period_data(1).day_start_ms       := 0;
    x_period_data(1).day_num            := 1;
  ELSE
    l_duration_gap_ms := (p_tmpl_length+1 - x_period_data(i).day_num) * 24 * 3600 * 1000
                         - (x_period_data(i).day_start_ms + x_period_data(i).period_span_ms);
    IF (l_duration_gap_ms > 0)
    THEN
      i := i+1;
      x_period_data(i).template_detail_id := NULL;
      x_period_data(i).period_id          := NULL;
      x_period_data(i).period_span_ms     := l_duration_gap_ms;
      x_period_data(i).day_start_ms       := NULL;
      x_period_data(i).day_num            := NULL;
    END IF;
  END IF;

END CREATE_PERIOD_DATA_DAY;


PROCEDURE GET_PERIOD_START_DUR
/*******************************************************************************
**
** GET_PERIOD_START_DUR
**
** get the starting index of the pl/sql table to use
** should be called for duration based template
**
*******************************************************************************/
( p_Schdl_Start_Date          IN  DATE
, p_period_data               IN  PERIOD_TBL_TYPE
, p_start_template_detail_id  IN  NUMBER
, x_start_index               OUT NOCOPY BINARY_INTEGER
, x_ms_to_use                 OUT NOCOPY NUMBER
) IS

  l_day_ms            NUMBER;
  l_total_ms          NUMBER;

BEGIN

  x_start_index  := p_period_data.FIRST;
  x_ms_to_use    := p_period_data(x_start_index).period_span_ms;

  IF p_start_template_detail_id IS NOT NULL
  THEN
    -- loop through the records and find out where this date starts
    -- the assumption here is that the records start on first day
    FOR i IN p_period_data.FIRST..p_period_data.LAST
    LOOP
      IF (p_start_template_detail_id = p_period_data(i).template_detail_id)
      THEN
        -- current record will be used
        x_start_index := i;
        -- calculate how much time should be used
        x_ms_to_use := p_period_data(x_start_index).period_span_ms;
        -- quit the loop
        EXIT;
      END IF;
    END LOOP;
  END IF;

END GET_PERIOD_START_DUR;


PROCEDURE GET_PERIOD_START_CAL
/*******************************************************************************
**
** GET_PERIOD_START_CAL
**
** get the starting index of the pl/sql table to use
** should be called for calendar based template
**
*******************************************************************************/
( p_Schdl_Start_Date          IN  DATE
, p_period_data               IN  PERIOD_TBL_TYPE
, p_start_template_detail_id  IN  NUMBER
, x_start_index               OUT NOCOPY BINARY_INTEGER
, x_ms_to_use                 OUT NOCOPY NUMBER
, x_ms_use_blank              OUT NOCOPY BOOLEAN
) IS

  l_sunday_date       DATE;
  l_day_number        NUMBER;
  l_day_ms            NUMBER;
  l_total_ms          NUMBER;
  l_start_calc        BOOLEAN;

BEGIN

  x_start_index  := p_period_data.FIRST;
  x_ms_to_use    := p_period_data(x_start_index).period_span_ms;
  x_ms_use_blank := FALSE;

  -- get a known sunday
  l_sunday_date := TO_DATE('1995/01/01','yyyy/mm/dd');
  -- calculate the day number, 1 - sunday, 2 - monday etc.
  l_day_number  := MOD((TRUNC(p_Schdl_Start_Date) - l_sunday_date),7);
  IF (l_day_number >= 0)
  THEN
    l_day_number := 1 + l_day_number;
  ELSE
    l_day_number := 1 - l_day_number;
  END IF;

  -- calculate the time, using the day part and time part
  l_day_ms := (l_day_number - 1) * 24 * 3600 * 1000
             + (p_Schdl_Start_Date - TRUNC(p_Schdl_Start_Date)) * 24 * 3600 * 1000;

  -- loop through the records and find out where this date starts
  -- the assumption here is that the records start on sunday
  l_start_calc := FALSE;
  l_total_ms := 0;
  FOR i IN p_period_data.FIRST..p_period_data.LAST
  LOOP
    IF ((NOT l_start_calc) AND ((p_start_template_detail_id IS NULL) OR
       (p_start_template_detail_id = p_period_data(i).template_detail_id)))
    THEN
      l_start_calc  := TRUE;
      x_start_index := i;
	  IF (l_total_ms > l_day_ms)
	  THEN
	    x_ms_to_use    := l_total_ms - l_day_ms;
		x_ms_use_blank := TRUE;
		EXIT;
	  END IF;
    END IF;
	l_total_ms := l_total_ms + p_period_data(i).period_span_ms;
    IF (l_start_calc)
    THEN
      IF (l_total_ms > l_day_ms)
      THEN
	    x_start_index := i;
        -- calculate how much time should be used
        x_ms_to_use   := l_total_ms - l_day_ms;
        -- quit the loop
        EXIT;
      END IF;
    END IF;
  END LOOP;

END GET_PERIOD_START_CAL;


PROCEDURE GET_PERIOD_START_DAY
/*******************************************************************************
**
** GET_PERIOD_START_DAY
**
** get the starting index of the pl/sql table to use
** should be called for day based template
**
*******************************************************************************/
( p_Schdl_Start_Date          IN  DATE
, p_period_data               IN  PERIOD_TBL_TYPE
, p_start_template_detail_id  IN  NUMBER
, x_start_index               OUT NOCOPY BINARY_INTEGER
, x_ms_to_use                 OUT NOCOPY NUMBER
, x_ms_use_blank              OUT NOCOPY BOOLEAN
) IS

  l_day_ms            NUMBER;
  l_total_ms          NUMBER;
  l_start_calc        BOOLEAN;

BEGIN

  x_start_index  := p_period_data.FIRST;
  x_ms_to_use    := p_period_data(x_start_index).period_span_ms;
  x_ms_use_blank := FALSE;

  -- calculate the time, using the day part and time part
  l_day_ms := (p_Schdl_Start_Date - TRUNC(p_Schdl_Start_Date)) * 24 * 3600 * 1000;

  -- loop through the records and find out where this date starts
  -- the assumption here is that the records start on first day
  l_start_calc := FALSE;
  l_total_ms   := 0;
  FOR i IN p_period_data.FIRST..p_period_data.LAST
  LOOP
    IF ((NOT l_start_calc) AND ((p_start_template_detail_id IS NULL) OR
       (p_start_template_detail_id = p_period_data(i).template_detail_id)))
    THEN
      l_start_calc  := TRUE;
      x_start_index := i;
	  IF (p_period_data(i).day_start_ms > l_day_ms)
	  THEN
	    -- this means that the previous record should be used
		x_ms_to_use    := p_period_data(i).day_start_ms - l_day_ms;
		x_ms_use_blank := TRUE;
		EXIT;
	  END IF;
      l_total_ms   := p_period_data(i).day_start_ms;
    END IF;
    IF (l_start_calc)
    THEN
      l_total_ms := l_total_ms + p_period_data(i).period_span_ms;
      IF (l_total_ms > l_day_ms)
      THEN
        -- current record will be used
        x_start_index := i;
        -- calculate how much time should be used
        x_ms_to_use := l_total_ms - l_day_ms;
        -- quit the loop
        EXIT;
      END IF;
    END IF;
  END LOOP;

END GET_PERIOD_START_DAY;


PROCEDURE GENERATE_SCHEDULE_DETAILS
/*******************************************************************************
**
** GENERATE_SCHEDULE_DETAILS
**
**   generates the schedule details
**   - Schedule
**   - template
**   - duration
**
*******************************************************************************/
( p_period_data               IN  PERIOD_TBL_TYPE
, p_Schdl_Tmpl_Type           IN  VARCHAR2
, p_Schdl_Start_Date          IN  DATE
, p_Schdl_End_Date            IN  DATE
, p_start_template_detail_id  IN  NUMBER
, x_schedule_details          OUT NOCOPY SCHDL_DETAILS_TBL_TYPE
) IS

  l_rec_start        DATE;
  l_rec_end          DATE;
  l_schdl_dtls_data  SCHDL_DETAILS_TBL_TYPE;
  l_schdl_i          BINARY_INTEGER;
  l_period_i         BINARY_INTEGER;
  l_ms_to_use        NUMBER;
  l_use_blank        BOOLEAN;

BEGIN

  IF (p_period_data.COUNT > 0)
  THEN
    IF (p_Schdl_Tmpl_Type = 'DUR')
    THEN
      GET_PERIOD_START_DUR(p_Schdl_Start_Date,p_period_data,p_start_template_detail_id,l_period_i,l_ms_to_use);
      l_use_blank := FALSE;
	ELSIF (p_Schdl_Tmpl_Type = 'CAL')
    THEN
      GET_PERIOD_START_CAL(p_Schdl_Start_Date,p_period_data,p_start_template_detail_id,l_period_i,l_ms_to_use,l_use_blank);
    ELSIF (p_Schdl_Tmpl_Type = 'DAY')
    THEN
      GET_PERIOD_START_DAY(p_Schdl_Start_Date,p_period_data,p_start_template_detail_id,l_period_i,l_ms_to_use,l_use_blank);
    END IF;

    l_schdl_i   := 0;

    l_rec_start := p_Schdl_Start_Date;

    WHILE (l_rec_start < p_Schdl_End_Date+1)
    LOOP
      -- add the period span to calculate end of the schdl detail record
      l_rec_end := l_rec_start + l_ms_to_use / (24*3600*1000.0);
      -- if the end is after schedule end then reset it.
      -- note tha addition of 1 day, as the end date of schedule has 00 in
      -- time part, but it's actually till end of that day
      IF (l_rec_end > p_Schdl_End_Date+1)
      THEN
        l_rec_end := p_Schdl_End_Date+1;
      END IF;

      IF (l_schdl_i = 0)
      THEN
        -- create a new record
        l_schdl_i := 1;
		IF (l_use_blank)
		THEN
          l_schdl_dtls_data(l_schdl_i).period_id     := NULL;
		ELSE
          l_schdl_dtls_data(l_schdl_i).period_id     := p_period_data(l_period_i).period_id;
          IF (l_period_i = p_period_data.LAST)
          THEN
            l_period_i := p_period_data.FIRST;
          ELSE
            l_period_i := l_period_i + 1;
          END IF;
        END IF;
		l_schdl_dtls_data(l_schdl_i).start_date_time := l_rec_start;
        l_schdl_dtls_data(l_schdl_i).end_date_time   := l_rec_end;
      ELSE
        IF (NVL(l_schdl_dtls_data(l_schdl_i).period_id,-1) =
           NVL(p_period_data(l_period_i).period_id,-1))
        THEN
          -- if the previous record's period id is same as this one
          -- then increment the end of previous record
          l_schdl_dtls_data(l_schdl_i).end_date_time := l_rec_end;
        ELSE
          -- create a new record
          l_schdl_i := l_schdl_i + 1;
          l_schdl_dtls_data(l_schdl_i).period_id       := p_period_data(l_period_i).period_id;
          l_schdl_dtls_data(l_schdl_i).start_date_time := l_rec_start;
          l_schdl_dtls_data(l_schdl_i).end_date_time   := l_rec_end;
        END IF;
        IF (l_period_i = p_period_data.LAST)
        THEN
          l_period_i := p_period_data.FIRST;
        ELSE
          l_period_i := l_period_i + 1;
        END IF;
      END IF;

      -- set the start of next record to the end of this record
      l_rec_start := l_rec_end;
      l_ms_to_use := p_period_data(l_period_i).period_span_ms;
    END LOOP;
  ELSE
    l_schdl_dtls_data(1).period_id       := NULL;
    l_schdl_dtls_data(1).start_date_time := p_Schdl_Start_Date;
    l_schdl_dtls_data(1).end_date_time   := p_Schdl_End_Date + 1;
  END IF;

  x_schedule_details := l_schdl_dtls_data;

END GENERATE_SCHEDULE_DETAILS;


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
, p_Schdl_End_Date       IN     DATE                 -- end date of the schedule
                                                     -- 24 hrs will be added to this as it should be till end of that day
) IS

  CURSOR c_get_schdl_objects
  (
    b_schedule_id    NUMBER
  ) IS
  SELECT SCHEDULE_OBJECT_ID
       , START_DATE_ACTIVE
       , END_DATE_ACTIVE
       , START_TEMPLATE_DETAIL_ID
  FROM   CAC_SR_SCHDL_OBJECTS
  WHERE  SCHEDULE_ID = b_schedule_id;

  l_period_data      PERIOD_TBL_TYPE;
  l_schdl_dtls_data  SCHDL_DETAILS_TBL_TYPE;
  l_obj_schdl_dtls   SCHDL_DETAILS_TBL_TYPE;

BEGIN

  IF (p_Schdl_Tmpl_Type = 'DUR')
  THEN
    CREATE_PERIOD_DATA_DUR(p_Schdl_Tmpl_Id,l_period_data);
  ELSIF (p_Schdl_Tmpl_Type = 'CAL')
  THEN
    CREATE_PERIOD_DATA_CAL(p_Schdl_Tmpl_Id,p_Schdl_Tmpl_Length,l_period_data);
  ELSIF (p_Schdl_Tmpl_Type = 'DAY')
  THEN
    CREATE_PERIOD_DATA_DAY(p_Schdl_Tmpl_Id,p_Schdl_Tmpl_Length,l_period_data);
  END IF;

  GENERATE_SCHEDULE_DETAILS
  (
    l_period_data,
    p_Schdl_Tmpl_Type,
    p_Schdl_Start_Date,
    p_Schdl_End_Date,
    NULL,
    l_schdl_dtls_data
  );

  INSERT_SCHEDULE_DETAILS
  (
    p_Schedule_id,
    NULL,
    l_schdl_dtls_data
  );

  FOR ref_schdl_objects IN c_get_schdl_objects(p_schedule_id)
  LOOP
    IF ((ref_schdl_objects.start_date_active = p_Schdl_Start_Date) AND
        (ref_schdl_objects.end_date_active = p_Schdl_End_Date) AND
        (ref_schdl_objects.start_template_detail_id IS NULL))
    THEN
      INSERT_SCHEDULE_DETAILS
      (
        p_Schedule_id,
        ref_schdl_objects.schedule_object_id,
        l_schdl_dtls_data
      );
    ELSE
      GENERATE_SCHEDULE_DETAILS
      (
        l_period_data,
        p_Schdl_Tmpl_Type,
        ref_schdl_objects.start_date_active,
        ref_schdl_objects.end_date_active,
        ref_schdl_objects.start_template_detail_id,
        l_obj_schdl_dtls
      );

      INSERT_SCHEDULE_DETAILS
      (
        p_Schedule_id,
        ref_schdl_objects.schedule_object_id,
        l_obj_schdl_dtls
      );
    END IF;
  END LOOP;

END POPULATE_SCHEDULE_DETAILS;


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
) IS

  CURSOR c_get_schdl
  (
    b_schedule_id    NUMBER
  ) IS
  SELECT CSTB.TEMPLATE_ID
       , CSTB.TEMPLATE_TYPE
       , CSTB.TEMPLATE_LENGTH_DAYS
       , CSSB.START_DATE_ACTIVE
       , CSSB.END_DATE_ACTIVE
  FROM   CAC_SR_SCHEDULES_B CSSB
       , CAC_SR_TEMPLATES_B CSTB
  WHERE  CSSB.SCHEDULE_ID = b_schedule_id
  AND    CSTB.TEMPLATE_ID = CSSB.TEMPLATE_ID;

  l_period_data       PERIOD_TBL_TYPE;
  l_schdl_dtls_data   SCHDL_DETAILS_TBL_TYPE;
  l_Schdl_Tmpl_Id     NUMBER;
  l_Schdl_Tmpl_Type   VARCHAR2(30);
  l_Schdl_Tmpl_Length NUMBER;
  l_Schdl_Start_Date  DATE;
  l_Schdl_End_Date    DATE;

BEGIN

  DELETE FROM CAC_SR_SCHDL_DETAILS
    WHERE SCHEDULE_OBJECT_ID = p_schedule_object_id;

  OPEN c_get_schdl(p_Schedule_Id);
  FETCH c_get_schdl
    INTO l_Schdl_Tmpl_Id,l_Schdl_Tmpl_Type,l_Schdl_Tmpl_Length,l_Schdl_Start_Date,l_Schdl_End_Date;
  CLOSE c_get_schdl;

  IF (l_Schdl_Tmpl_Type = 'DUR')
  THEN
    CREATE_PERIOD_DATA_DUR(l_Schdl_Tmpl_Id,l_period_data);
  ELSIF (l_Schdl_Tmpl_Type = 'CAL')
  THEN
    CREATE_PERIOD_DATA_CAL(l_Schdl_Tmpl_Id,l_Schdl_Tmpl_Length,l_period_data);
  ELSIF (l_Schdl_Tmpl_Type = 'DAY')
  THEN
    CREATE_PERIOD_DATA_DAY(l_Schdl_Tmpl_Id,l_Schdl_Tmpl_Length,l_period_data);
  END IF;

  GENERATE_SCHEDULE_DETAILS
  (
    l_period_data,
    l_Schdl_Tmpl_Type,
    p_Object_Start_Date,
    p_Object_End_Date,
    p_Start_Template_Detail_Id,
    l_schdl_dtls_data
  );

  INSERT_SCHEDULE_DETAILS
  (
    p_Schedule_id,
    p_Schedule_Object_Id,
    l_schdl_dtls_data
  );

END POPULATE_OBJECT_SCHDL_DETAILS;


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
)
IS

  CURSOR c_get_schdl_objects
  (
    b_schedule_id    NUMBER
  ) IS
  SELECT OBJECT_TYPE
       , OBJECT_ID
       , START_DATE_ACTIVE
       , END_DATE_ACTIVE
  FROM   CAC_SR_SCHDL_OBJECTS
  WHERE  SCHEDULE_ID = b_schedule_id;

BEGIN

  POPULATE_SCHEDULE_DETAILS
  (
    p_Schedule_Id,
    p_Schdl_Tmpl_Id,
    p_Schdl_Tmpl_Length,
    p_Schdl_Tmpl_Type,
    p_Schdl_Start_Date,
    p_Schdl_End_Date
  );

  CAC_AVLBLTY_EVENTS_PVT.RAISE_CREATE_SCHEDULE
  (
    p_Schedule_Id,
    p_Schedule_Category,
    p_Schdl_Start_Date,
    p_Schdl_End_Date
  );

  FOR ref_objects IN c_get_schdl_objects(p_Schedule_Id)
  LOOP
    CAC_AVLBLTY_EVENTS_PVT.RAISE_ADD_RESOURCE
    (
      p_Schedule_Id,
      p_Schedule_Category,
      p_Schdl_Start_Date,
      p_Schdl_End_Date,
      ref_objects.object_type,
      ref_objects.object_id,
      ref_objects.start_date_active,
      ref_objects.end_date_active
    );
  END LOOP;

END POST_CREATE_SCHEDULE;


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
)
IS

  CURSOR c_get_schdl_objects
  (
    b_schedule_id    NUMBER
  ) IS
  SELECT CSSO.OBJECT_TYPE
       , CSSO.OBJECT_ID
       , CSSO.START_DATE_ACTIVE
       , CSSO.END_DATE_ACTIVE
       , CSSD.SCHEDULE_OBJECT_ID
  FROM   CAC_SR_SCHDL_OBJECTS CSSO,
         (SELECT SCHEDULE_OBJECT_ID, MIN(START_DATE_TIME)
          FROM CAC_SR_SCHDL_DETAILS
          WHERE SCHEDULE_ID = b_schedule_id
         ) CSSD
  WHERE  CSSO.SCHEDULE_ID = b_schedule_id
  AND    CSSD.SCHEDULE_OBJECT_ID(+) = CSSO.SCHEDULE_OBJECT_ID;

BEGIN

  DELETE FROM CAC_SR_SCHDL_DETAILS
  WHERE SCHEDULE_ID = p_schedule_id;

  POPULATE_SCHEDULE_DETAILS
  (
    p_Schedule_Id,
    p_Schdl_Tmpl_Id,
    p_Schdl_Tmpl_Length,
    p_Schdl_Tmpl_Type,
    p_Schdl_Start_Date,
    p_Schdl_End_Date
  );

  CAC_AVLBLTY_EVENTS_PVT.RAISE_UPDATE_SCHEDULE
  (
    p_Schedule_Id,
    p_Schedule_Category,
    p_Schdl_Start_Date,
    p_Schdl_End_Date
  );

END POST_UPDATE_SCHEDULE;


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
)
IS

BEGIN

  CAC_AVLBLTY_EVENTS_PVT.RAISE_DELETE_SCHEDULE
  (
    p_Schedule_Id,
    p_Schedule_Category,
    p_Schdl_Start_Date,
    p_Schdl_End_Date
  );

END POST_DELETE_SCHEDULE;


END CAC_AVLBLTY_PVT;

/
