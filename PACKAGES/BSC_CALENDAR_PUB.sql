--------------------------------------------------------
--  DDL for Package BSC_CALENDAR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_CALENDAR_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPCALS.pls 120.3 2007/12/18 06:48:03 lbodired ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCPCALS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Public package for populating the calendar tables         |
REM | NOTES                                                                 |
REM | 07-JUN-2005 Krishna Created.                                          |
REM | 06-JUL-07 psomesul     Bug#6168487 - CHANGING CALENDAR DEF WHICH IS IN PRODUCTION IS NOT TRIGGERING  TO USER |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):=  'BSC_CALENDAR_PUB';

TYPE varchar2_tabletype IS TABLE OF VARCHAR2(32000) INDEX BY binary_integer;

TYPE Calendar_Type_Record IS record
(
  Calendar_Id             bsc_sys_calendars_b.calendar_id%TYPE
, Edw_Flag                bsc_sys_calendars_b.edw_flag%TYPE
, Edw_Calendar_Id         bsc_sys_calendars_b.edw_calendar_id%TYPE
, Edw_Calendar_Type_Id    bsc_sys_calendars_b.edw_calendar_type_id%TYPE
, Fiscal_Year             bsc_sys_calendars_b.fiscal_year%TYPE
, Fiscal_Change           bsc_sys_calendars_b.fiscal_change%TYPE
, Range_Yr_Mod            bsc_sys_calendars_b.range_yr_mod%TYPE
, Current_Year            bsc_sys_calendars_b.current_year%TYPE
, Start_Month             bsc_sys_calendars_b.start_month%TYPE
, Start_Day               bsc_sys_calendars_b.start_day%TYPE
, Created_By              bsc_sys_calendars_b.created_by%TYPE
, Creation_Date           bsc_sys_calendars_b.creation_date%TYPE
, Last_Updated_By         bsc_sys_calendars_b.last_updated_by%TYPE
, Last_Update_Date        bsc_sys_calendars_b.last_update_date%TYPE
, Last_Update_Login       bsc_sys_calendars_b.last_update_login%TYPE
, Name                    bsc_sys_calendars_tl.name%TYPE
, Help                    bsc_sys_calendars_tl.help%TYPE
, Dim_Short_Name          bsc_sys_dim_groups_tl.short_name%TYPE
, Application_Id          bis_dimensions.application_id%TYPE
, Language                bsc_sys_calendars_tl.language%TYPE
, Source_Lang             bsc_sys_calendars_tl.source_lang%TYPE
, Base_Periodicities_Ids  VARCHAR2(32000)
);

PROCEDURE Create_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Delete_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Validate_Calendar_Action
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, p_Action                 IN          VARCHAR2
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Retrieve_And_Populate_Cal_Rec
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Calendar_Record        OUT NOCOPY  BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Fill_Default_Values_Create_Cal
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Calendar_Record        OUT NOCOPY  BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Create_Calendar_Post_Action
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Calendar_Post_Action
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);
PROCEDURE Flag_Changes_For_Objectives
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Id            IN          NUMBER
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Create_Periodicities_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

FUNCTION get_production_obj_having_cal(
  p_cal_id  IN   bsc_kpis_b.calendar_id%TYPE
  )
RETURN VARCHAR2;


PROCEDURE comp_leapyear_prioryear(
  p_calid IN NUMBER,
  p_cyear IN NUMBER,
  p_pyear IN NUMBER,
  x_result OUT nocopy NUMBER
 );

END BSC_CALENDAR_PUB;

/
