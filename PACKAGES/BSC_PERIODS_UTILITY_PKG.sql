--------------------------------------------------------
--  DDL for Package BSC_PERIODS_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PERIODS_UTILITY_PKG" AUTHID CURRENT_USER AS
/* $Header: BSCUPERS.pls 120.8 2006/06/27 07:09:39 adrao noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCVPERS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Utility file for Calendar and Periodicities and TIME      |
REM |             integration modules  (designer)                           |
REM | NOTES                                                                 |
REM | 14-JUL-2005 Aditya Rao  Created.                                      |
REM | 08-AUG-2005 Aditya Rao  added constants for Bug#4533089               |
REM | 25-AUG-2005 Aditya Rao  added API Get_Non_Rolling_Dim_Obj Bug#4566634 |
REM | 29-AUG-2005 Aditya Rao  Added API Get_Periodicity_Name for Bug#4574115|
REM | 28-SEP-2005 akoduri     Bug#4626935 Get_Daily_Periodicity_Sht_Name API|
REM |                         is added                                      |
REM | 29-NOV-2005 Krishna Modified for enh#4711274                          |
REM | 22-JUN-2006 Aditya Rao  Added API Get_Quarter_Date_Label as requested|
REM |                         by PMV Bug#4767731                            |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_PERIODS_UTILITY_PKG';

C_CREATE   CONSTANT VARCHAR2(30):='CREATE';
C_UPDATE   CONSTANT VARCHAR2(30):='UPDATE';
C_RETRIEVE CONSTANT VARCHAR2(30):='RETRIEVE';
C_DELETE   CONSTANT VARCHAR2(30):='DELETE';

C_MAX_CUSTOM_PERIODICITIES      CONSTANT NUMBER := 20;
C_CUSTOM_PERIODICITY_CODE       CONSTANT NUMBER := 2;
C_NON_CUSTOM_PERIODICITY_CODE   CONSTANT NUMBER := 0;

C_PERIODICITY_YEARLY_FLAG       CONSTANT NUMBER := 0;


C_CUSTOM_DB_COL_PREFIX   CONSTANT VARCHAR2(30) :='CUSTOM_';
C_DFLT_PERIOD_COL_NAME   CONSTANT VARCHAR2(30) :='PERIOD';
C_CUST_PERIODICITY_TYPE  CONSTANT NUMBER       := 0;
C_CUST_NUM_OF_SUBPERIODS CONSTANT NUMBER       := 0;
C_CONSTANT_ZERO          CONSTANT NUMBER       := 0;
C_DEFAULT_START_MONTH    CONSTANT NUMBER       := 1;
C_DEFAULT_START_DAY      CONSTANT NUMBER       := 1;
C_SYSTEM_STAGE           CONSTANT VARCHAR2(12) := 'SYSTEM_STAGE';




C_PERIOD_SHORT_NAME_PREFIX CONSTANT VARCHAR2(30) := 'BSC_PER_';
C_CALNEDAR_SHORT_PREFIX    CONSTANT VARCHAR2(30) := 'CAL';
C_PERIOD_SHORT_PREFIX      CONSTANT VARCHAR2(30) := 'PER';
C_UNDER_SCORE              CONSTANT VARCHAR2(30) := '_';
C_HYPHEN                   CONSTANT VARCHAR2(30) := '-';

C_BSC_APPLICATION_ID  CONSTANT NUMBER := 271;


C_API_VERSION_1_0     CONSTANT NUMBER := 1.0;

C_PMF_DO_TYPE   CONSTANT VARCHAR2(30) := 'PMF';

C_BSC_DO_TYPE   CONSTANT VARCHAR2(30) := 'BSC';
C_OLTP_DO_TYPE  CONSTANT VARCHAR2(30) := 'OLTP';
C_CALENDAR_NAME CONSTANT VARCHAR2(9) := 'Calendar ';


C_CAL_DATE_FORMAT CONSTANT VARCHAR2(10) := 'mm/dd/yyyy';

C_BASE_PERIODICITY_TYPE CONSTANT NUMBER := 0;

C_COMMA_SEPARATOR  CONSTANT VARCHAR2(3)  :=',';

-- Added for Bug#4533089
C_YEAR_COLUMN     CONSTANT VARCHAR(10) := 'YEAR';
C_SEMESTER_COLUMN CONSTANT VARCHAR(10) := 'SEMESTER';
C_QUARTER_COLUMN  CONSTANT VARCHAR(10) := 'QUARTER';
C_BIMESTER_COLUMN CONSTANT VARCHAR(10) := 'BIMESTER';
C_MONTH_COLUMN    CONSTANT VARCHAR(10) := 'MONTH';
C_WEEK52_COLUMN   CONSTANT VARCHAR(10) := 'WEEK52';
C_DAY365_COLUMN   CONSTANT VARCHAR(10) := 'DAY365';


C_FII_ROLLING_QTR      CONSTANT VARCHAR(30) := 'FII_ROLLING_QTR';
C_FII_ROLLING_WEEK     CONSTANT VARCHAR(30) := 'FII_ROLLING_WEEK';
C_FII_ROLLING_MONTH    CONSTANT VARCHAR(30) := 'FII_ROLLING_MONTH';
C_FII_ROLLING_YEAR     CONSTANT VARCHAR(30) := 'FII_ROLLING_YEAR';
C_FII_TIME_ENT_QTR     CONSTANT VARCHAR(30) := 'FII_TIME_ENT_QTR';
C_FII_TIME_WEEK        CONSTANT VARCHAR(30) := 'FII_TIME_WEEK';
C_FII_TIME_ENT_PERIOD  CONSTANT VARCHAR(30) := 'FII_TIME_ENT_PERIOD';
C_FII_TIME_ENT_YEAR    CONSTANT VARCHAR(30) := 'FII_TIME_ENT_YEAR';


FUNCTION Is_Period_Name_Unique (
      p_Calendar_Id      IN NUMBER
    , p_Periodicity_Name IN VARCHAR2
) RETURN VARCHAR2;


FUNCTION Get_Calendar_Name (
    p_Calendar_Id IN NUMBER
) RETURN VARCHAR2;


FUNCTION Get_Calendar_Short_Name (
    p_Calendar_Id IN NUMBER
) RETURN VARCHAR2;


FUNCTION Get_Cust_Per_Cnt_By_Calendar (
    p_Calendar_Id IN NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Next_Cust_Period_DB_Column (
p_Calendar_Id IN NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Next_Periodicity_Id RETURN NUMBER;

FUNCTION Get_Next_Calendar_Id RETURN NUMBER;

FUNCTION Is_Periodicity_In_Calendar (
            p_Calendar_Id    IN NUMBER
          , p_Periodicity_Id IN NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Periodicity_Source (
    p_Periodicity_Id IN NUMBER
) RETURN VARCHAR2;

-- added for Bug#4574115
FUNCTION Get_Periodicity_Name (
    p_Periodicity_Id IN NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Unique_Short_Name RETURN VARCHAR2;

PROCEDURE Print_Period_Metadata (
      p_Debug_Flag VARCHAR2
    , p_Periodicities_Rec_Type IN BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
);

FUNCTION Check_Error_Message(p_Error_Message IN VARCHAR2)
RETURN BOOLEAN;

FUNCTION Is_Base_Periodicity_Daily(p_Base_Periodicity_Id NUMBER)
RETURN BOOLEAN;

FUNCTION Get_FiscalYear_By_Calendar(p_Calendar_Id NUMBER)
RETURN NUMBER;

FUNCTION Get_Periodicity_Short_Name (
            p_Periodicity_Id IN NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Periods_In_Base_Period(p_Base_Periodicity_Id IN NUMBER)
RETURN NUMBER;


PROCEDURE Rollback_API (
  p_In_String               IN          VARCHAR2
 ,p_ErrorOut                IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);

FUNCTION Get_Start_Period_Date (
    p_Calendar_Id    IN NUMBER
  , p_Periodicity_Id IN NUMBER
  , p_Period_id      IN NUMBER
  , p_Year           IN NUMBER
) RETURN DATE;


FUNCTION Get_End_Period_Date (
    p_Calendar_Id    IN NUMBER
  , p_Periodicity_Id IN NUMBER
  , p_Period_id      IN NUMBER
  , p_Year           IN NUMBER
) RETURN DATE;

FUNCTION Get_Periodicity_Db_Col (
    p_Periodicity_Id IN NUMBER
) RETURN VARCHAR2;

-- Added API for Bug#4566634
-- This API returns the correspoding Enterprise Period when a
-- Rolling Period is passed to the API
FUNCTION Get_Non_Rolling_Dim_Obj (p_Short_Name IN VARCHAR2) RETURN VARCHAR2;

FUNCTION Get_Daily_Periodicity_Sht_Name(
  p_Calendar_Id IN NUMBER
) RETURN VARCHAR2;

FUNCTION get_Dimobj_Name_From_period (
  p_Calendar_Id      IN NUMBER
, p_Periodicity_Name IN VARCHAR2
) RETURN VARCHAR2 ;

FUNCTION generate_Period_Short_Name (
  p_Calendar_Id   IN  NUMBER
, p_Period_Id     IN  NUMBER
)RETURN VARCHAR2 ;

FUNCTION Get_Bsc_Periodicity(
  x_time_level_name    IN OUT NOCOPY VARCHAR2
, x_periodicity_id     OUT    NOCOPY NUMBER
, x_calendar_id        OUT    NOCOPY NUMBER
, x_message            OUT    NOCOPY VARCHAR2
)RETURN BOOLEAN;

/*************************************************************************************
API NAME : Get_Quarter_Date_Label
FUNCTIONALITY : This API takes the as of date value and the
time dimension object under consideration and returns in the
Quarter date format, for example

SQL> select Get_Quarter_Date_Format('28-JUN-02', 'BSC_PER_2453567477645868') from dual

Q2 FY02 Day -2

NOTE 1: That this API should be used only with Custom Periodicities and
this will behave unexpectedly by returning null in case of DBI Periodicities

NOTE 2: The API will return the message error text in case of date errors

NOTE 3: Appropriate ORA errors will be returned, for example

SQL> select BSC_PERIODS_UTILITY_PKG.Get_Quarter_Date_Format('28-JUN-03', 'BSC_PER_2453567477645868') from dual

ORA-01403: no data found

SQL> select BSC_PERIODS_UTILITY_PKG.Get_Quarter_Date_Format('30-FEB-03', 'BSC_PER_2453567477645868') from dual

ORA-01839: date not valid for month specified
*************************************************************************************/

FUNCTION Get_Quarter_Date_Label(
  p_As_Of_date                   IN VARCHAR2,
  p_Dimension_Object_Short_Name  IN VARCHAR2
) RETURN VARCHAR2;

END BSC_PERIODS_UTILITY_PKG;

 

/
