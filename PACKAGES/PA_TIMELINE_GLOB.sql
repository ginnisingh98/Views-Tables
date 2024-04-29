--------------------------------------------------------
--  DDL for Package PA_TIMELINE_GLOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TIMELINE_GLOB" AUTHID CURRENT_USER as
  /* $Header: PARLTMLS.pls 115.9 2002/02/12 18:31:13 pkm ship  $*/

TYPE TimeChartRecord  IS RECORD (  time_chart_record_type      VARCHAR(30),
  assignment_id           NUMBER        ,
  resource_id             NUMBER        ,
  start_date              DATE          ,
  end_date                DATE          ,
  scale_type              VARCHAR2(30)  ,
  color_pattern           VARCHAR2(30)  ,
  help_text               VARCHAR2(150)
                                );

TYPE TimeChartTabTyp IS TABLE OF TimeChartRecord INDEX BY BINARY_INTEGER;

TYPE TimeScaleRecord  IS RECORD ( start_date              DATE          ,
  end_date                DATE          ,
  scale_row_type          VARCHAR2(30)  ,
  scale_type              VARCHAR2(30)  ,
  scale_text              VARCHAR2(30)  ,
  scale_marker_code       VARCHAR2(1)
                                );

TYPE TimeScaleTabTyp IS TABLE OF TimeScaleRecord INDEX BY BINARY_INTEGER;

TYPE ColorPatternRecord IS RECORD ( status_code        VARCHAR2(30) ,
  color_pattern_code      VARCHAR2(1),
  description    VARCHAR2(80)
                                  );

TYPE ColorPatternTabTyp IS TABLE OF ColorPatternRecord INDEX BY BINARY_INTEGER;

TYPE TimelineProfileSetup IS RECORD
   (res_capacity_percentage  NUMBER,
    res_overcommitment_percentage NUMBER,
    availability_cal_period  VARCHAR2(30),
    availability_duration    NUMBER);

TYPE TimeChartWeekDetailRecord IS RECORD (
    event_id           NUMBER,
    sys_status_code    PA_PROJECT_STATUSES.project_system_status_code%TYPE,
    status_priority    NUMBER,
    day_one_hours      NUMBER,
    day_two_hours      NUMBER,
    day_three_hours    NUMBER,
    day_four_hours     NUMBER,
    day_five_hours     NUMBER,
    day_six_hours      NUMBER,
    day_seven_hours    NUMBER);

TYPE TimeChartWeekDetailTabTyp IS TABLE OF TimeChartWeekDetailRecord INDEX BY BINARY_INTEGER;

TYPE ResourceCapacityRecord IS RECORD (
    day_one_hours      NUMBER,
    day_two_hours      NUMBER,
    day_three_hours    NUMBER,
    day_four_hours     NUMBER,
    day_five_hours     NUMBER,
    day_six_hours      NUMBER,
    day_seven_hours    NUMBER);

TYPE WeekDatesRangeRecord IS RECORD ( week_start_date              DATE          ,
  week_end_date                DATE
                                    );

TYPE WeekDatesRangeTabTyp IS TABLE OF WeekDatesRangeRecord INDEX BY BINARY_INTEGER;

END PA_TIMELINE_GLOB;

 

/
