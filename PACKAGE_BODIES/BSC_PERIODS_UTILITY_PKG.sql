--------------------------------------------------------
--  DDL for Package Body BSC_PERIODS_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PERIODS_UTILITY_PKG" AS
/* $Header: BSCUPERB.pls 120.11 2006/06/27 08:43:13 adrao noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCUPERB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Utility file for Calendar and Periodicities and TIME      |
REM |             integration modules  (designer)                           |
REM | NOTES                                                                 |
REM | 14-JUL-2005 Aditya Rao  Created.                                      |
REM | 25-AUG-2005 Aditya Rao  added API Get_Non_Rolling_Dim_Obj Bug#4566634 |
REM | 29-AUG-2005 Aditya Rao  Changed API Get_Cust_Per_Cnt_By_Calendar for  |
REM |                         Bug#4576424                                   |
REM | 29-AUG-2005 Aditya Rao  Added API Get_Periodicity_Name for Bug#4574115|
REM | 28-SEP-2005 akoduri     Bug#4626935 Get_Daily_Periodicity_Sht_Name API|
REM |                         is added                                      |
REM | 29-NOV-2005 kyadamak    Added APIs for Enhancement#4711274            |
REM | 16-FEB-2006 Aditya Rao  added ABS() to DBMS_UTILITY.GET_TIME for      |
REM |                         Bug#5039894                                   |
REM | 22-JUN-2006 Aditya Rao  Added API Get_Quarter_Date_Label as requested |
REM |                         by PMV Bug#4767731                            |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_PERIODS_UTILITY_PKG';

-- Checks if the Periodicity Name is unique to the calendar or not.
FUNCTION get_Next_Alias
(
  p_Alias        IN   VARCHAR2
) RETURN VARCHAR2
IS
  l_alias     VARCHAR2(4);
  l_return    VARCHAR2(4);
  l_count     NUMBER;
BEGIN
  IF (p_Alias IS NULL) THEN
    l_return :=  'A';
  ELSE
    l_count := LENGTH(p_Alias);
    IF (l_count = 1) THEN
      l_return   := 'A0';
    ELSIF (l_count > 1) THEN
      l_alias     :=  SUBSTR(p_Alias, 2);
      l_count     :=  TO_NUMBER(l_alias)+1;
      l_return    :=  SUBSTR(p_Alias, 1, 1)||TO_CHAR(l_count);
    END IF;
  END IF;
  RETURN l_return;
END get_Next_Alias;

FUNCTION Is_Period_Name_Unique (
      p_Calendar_Id      IN NUMBER
    , p_Periodicity_Name IN VARCHAR2
) RETURN VARCHAR2 IS
    l_Count NUMBER;
BEGIN
    l_Count := 0;

    SELECT COUNT(1) INTO l_Count
    FROM   BSC_SYS_PERIODICITIES_VL P
    WHERE  P.CALENDAR_ID = p_Calendar_Id
    AND    UPPER(P.NAME) = UPPER(p_Periodicity_Name);


    IF (l_Count <> 0) THEN
        RETURN FND_API.G_FALSE;
    END IF;

    RETURN FND_API.G_TRUE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_Period_Name_Unique;

-- Gets the Calendar Name from the CALENDAR_ID
FUNCTION Get_Calendar_Name (
    p_Calendar_Id IN NUMBER
) RETURN VARCHAR2 IS
    l_Calendar_Name  BSC_SYS_CALENDARS_TL.NAME%TYPE;
BEGIN

    SELECT C.NAME
    INTO   l_Calendar_Name
    FROM   BSC_SYS_CALENDARS_VL C
    WHERE  C.CALENDAR_ID = p_Calendar_Id;

    RETURN l_Calendar_Name;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Calendar_Name;

-- Returns the calendar short_name.
FUNCTION Get_Calendar_Short_Name (
    p_Calendar_Id IN NUMBER
) RETURN VARCHAR2
IS
    l_Calendar_Short_Name  BSC_SYS_CALENDARS_B.SHORT_NAME%TYPE;
BEGIN

    SELECT C.SHORT_NAME
    INTO   l_Calendar_Short_Name
    FROM   BSC_SYS_CALENDARS_B C
    WHERE  C.CALENDAR_ID = p_Calendar_Id;

    RETURN l_Calendar_Short_Name;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Calendar_Short_Name;


-- Get the number of custom periodicities by Calendar.
-- Changed condition for Bug#4576424
FUNCTION Get_Cust_Per_Cnt_By_Calendar (
    p_Calendar_Id IN NUMBER
) RETURN VARCHAR2 IS
    l_Count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   l_Count
    FROM   BSC_SYS_PERIODICITIES P
    WHERE  P.CALENDAR_ID = p_Calendar_Id
    AND    P.CUSTOM_CODE <> BSC_PERIODS_UTILITY_PKG.C_BASE_PERIODICITY_TYPE;

    RETURN  l_Count;
EXCEPTION
    WHEN OTHERS THEN
        RETURN BSC_PERIODS_UTILITY_PKG.C_NON_CUSTOM_PERIODICITY_CODE;
END Get_Cust_Per_Cnt_By_Calendar;

-- Returns the next custom DB Column name
FUNCTION Get_Next_Cust_Period_DB_Column (
    p_Calendar_Id IN NUMBER
) RETURN VARCHAR2 IS
    l_Max_Custom_Id    NUMBER;
    l_Custom_DB_Column BSC_SYS_PERIODICITIES.DB_COLUMN_NAME%TYPE;
BEGIN
    SELECT NVL(MAX(TO_NUMBER(SUBSTR(P.DB_COLUMN_NAME, LENGTH(C_CUSTOM_DB_COL_PREFIX)+1))), 0)
    INTO   l_Max_Custom_Id
    FROM   BSC_SYS_PERIODICITIES P
    WHERE  P.CUSTOM_CODE > 0
    AND    P.CALENDAR_ID = P_CALENDAR_ID;

    l_Custom_DB_Column := C_CUSTOM_DB_COL_PREFIX || (l_Max_Custom_Id+1);

    RETURN l_Custom_DB_Column;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Next_Cust_Period_DB_Column;


-- Gets the next PERIODICITY_ID from sequence BSC_SYS_PERIODICITY_ID_S
FUNCTION Get_Next_Periodicity_Id
RETURN NUMBER IS
    l_Next_Number NUMBER;
BEGIN

    SELECT BSC_SYS_PERIODICITY_ID_S.NEXTVAL
    INTO   l_Next_Number
    FROM   DUAL;

    RETURN l_Next_Number;
EXCEPTION
    WHEN OTHERS THEN
        SELECT NVL(MAX(P.PERIODICITY_ID)+1, 0)
        INTO   l_Next_Number
        FROM   BSC_SYS_PERIODICITIES P;

        RETURN l_Next_Number;
END Get_Next_Periodicity_Id;

FUNCTION Get_Next_Calendar_Id
RETURN NUMBER IS
    l_Next_Number NUMBER;
BEGIN

    SELECT BSC_SYS_CALENDAR_ID_S.NEXTVAL
    INTO   l_Next_Number
    FROM   DUAL;

    RETURN l_Next_Number;
EXCEPTION
    WHEN OTHERS THEN
        SELECT NVL(MAX(P.calendar_id)+1, 0)
        INTO   l_Next_Number
        FROM   bsc_sys_calendars_b P;

        RETURN l_Next_Number;
END Get_Next_Calendar_Id;


--Checks if a given periodicity belongs to a calendar.
FUNCTION Is_Periodicity_In_Calendar (
            p_Calendar_Id    IN NUMBER
          , p_Periodicity_Id IN NUMBER
) RETURN VARCHAR2
IS
    l_Count NUMBER;
BEGIN
    SELECT COUNT(1)
    INTO   l_Count
    FROM   BSC_SYS_PERIODICITIES B
    WHERE  B.PERIODICITY_ID = p_Periodicity_Id
    AND    B.CALENDAR_ID    = p_Calendar_Id;

    IF (l_Count = 1) THEN
        RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_Periodicity_In_Calendar;


FUNCTION Get_Periodicity_Source (
    p_Periodicity_Id IN NUMBER
) RETURN VARCHAR2
IS
    l_Source_Column BSC_SYS_PERIODICITIES.SOURCE%TYPE;
BEGIN
    SELECT B.SOURCE
    INTO   l_Source_Column
    FROM   BSC_SYS_PERIODICITIES B
    WHERE  B.PERIODICITY_ID = p_Periodicity_Id;

    RETURN l_Source_Column;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Periodicity_Source;


-- Get unique periodicity short_name
FUNCTION Get_Unique_Short_Name RETURN VARCHAR2
IS
    l_Return_Short_Name VARCHAR2(30);
BEGIN
    RETURN C_PERIOD_SHORT_NAME_PREFIX||TO_CHAR(SYSDATE,'J')||ABS(DBMS_UTILITY.GET_TIME);
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Unique_Short_Name;


PROCEDURE Print_Period_Metadata (
      p_Debug_Flag VARCHAR2
    , p_Periodicities_Rec_Type IN BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
) IS
BEGIN
    NULL;
/*
    DBMS_OUTPUT.PUT_LINE('p_Debug_Flag - ' || p_Debug_Flag);
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Periodicity_Id           ' ||   p_Periodicities_Rec_Type.Periodicity_Id     );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Num_Of_Periods           ' ||   p_Periodicities_Rec_Type.Num_Of_Periods     );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Source                   ' ||   p_Periodicities_Rec_Type.Source             );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Base_Periodicity_Id      ' ||   p_Periodicities_Rec_Type.Base_Periodicity_Id);
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Num_Of_Subperiods        ' ||   p_Periodicities_Rec_Type.Num_Of_Subperiods  );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Period_Col_Name          ' ||   p_Periodicities_Rec_Type.Period_Col_Name    );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Subperiod_Col_Name       ' ||   p_Periodicities_Rec_Type.Subperiod_Col_Name );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Yearly_Flag              ' ||   p_Periodicities_Rec_Type.Yearly_Flag        );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Edw_Flag                 ' ||   p_Periodicities_Rec_Type.Edw_Flag           );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Calendar_Id              ' ||   p_Periodicities_Rec_Type.Calendar_Id        );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Edw_Periodicity_Id       ' ||   p_Periodicities_Rec_Type.Edw_Periodicity_Id );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Custom_Code              ' ||   p_Periodicities_Rec_Type.Custom_Code        );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Db_Column_Name           ' ||   p_Periodicities_Rec_Type.Db_Column_Name     );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Periodicity_Type         ' ||   p_Periodicities_Rec_Type.Periodicity_Type   );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Period_Type_Id           ' ||   p_Periodicities_Rec_Type.Period_Type_Id     );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Record_Type_Id           ' ||   p_Periodicities_Rec_Type.Record_Type_Id     );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Xtd_Pattern              ' ||   p_Periodicities_Rec_Type.Xtd_Pattern        );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Short_Name               ' ||   p_Periodicities_Rec_Type.Short_Name         );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Name                     ' ||   p_Periodicities_Rec_Type.Name               );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Created_By               ' ||   p_Periodicities_Rec_Type.Created_By         );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Creation_Date            ' ||   p_Periodicities_Rec_Type.Creation_Date      );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Last_Updated_By          ' ||   p_Periodicities_Rec_Type.Last_Updated_By    );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Last_Update_Date         ' ||   p_Periodicities_Rec_Type.Last_Update_Date   );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Last_Update_Login        ' ||   p_Periodicities_Rec_Type.Last_Update_Login  );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Application_id           ' ||   p_Periodicities_Rec_Type.Application_id     );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Period_Year              ' ||   p_Periodicities_Rec_Type.Period_Year        );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Start_Period             ' ||   p_Periodicities_Rec_Type.Start_Period       );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.End_Period               ' ||   p_Periodicities_Rec_Type.End_Period         );
    DBMS_OUTPUT.PUT_LINE('p_Periodicities_Rec_Type.Period_IDs               ' ||   p_Periodicities_Rec_Type.Period_IDs         );
*/
END Print_Period_Metadata;


FUNCTION Check_Error_Message(p_Error_Message IN VARCHAR2)
RETURN BOOLEAN IS
l_error_message   bsc_message_logs.message%TYPE;
l_Is_Error        BOOLEAN;

CURSOR C_ERROR(l_source VARCHAR2) IS
  SELECT message
  INTO   l_error_message
  FROM   bsc_message_logs
  WHERE  type = 0
  AND    UPPER(SOURCE) = UPPER(l_source)
  AND    LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID;

BEGIN
  l_Is_Error := FALSE;
  IF(C_ERROR%ISOPEN) THEN
    CLOSE C_ERROR;
  END IF;

  OPEN C_ERROR(p_Error_Message);
  FETCH C_ERROR INTO l_error_message;
  CLOSE C_ERROR;

  IF(LENGTH(l_error_message) > 0 ) THEN
    l_Is_Error := TRUE;
  END IF;

  RETURN l_Is_Error;

END Check_Error_Message;

FUNCTION Get_FiscalYear_By_Calendar(p_Calendar_Id NUMBER)
RETURN NUMBER IS
l_Fiscal_Year BSC_SYS_CALENDARS_B.FISCAL_YEAR%TYPE;
BEGIN
  SELECT FISCAL_YEAR
  INTO   l_Fiscal_Year
  FROM   BSC_SYS_CALENDARS_B
  WHERE  CALENDAR_ID = p_Calendar_Id;

  RETURN l_Fiscal_Year;

END Get_FiscalYear_By_Calendar;

-- added exception for Bug#4626530
FUNCTION Is_Base_Periodicity_Daily(p_Base_Periodicity_Id NUMBER)
RETURN BOOLEAN IS
l_Is_Daily          BOOLEAN := FALSE;
l_Periodicity_Id    NUMBER;
BEGIN
  SELECT periodicity_type
  INTO   l_Periodicity_Id
  FROM   bsc_sys_periodicities
  WHERE  periodicity_id = p_Base_Periodicity_Id;

  IF(l_Periodicity_Id = 9) THEN
    l_Is_Daily := TRUE;
  END IF;

  RETURN l_Is_Daily;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END Is_Base_Periodicity_Daily;

FUNCTION Get_Periodicity_Short_Name (
            p_Periodicity_Id IN NUMBER
) RETURN VARCHAR2 IS
    l_Short_Name  BSC_SYS_PERIODICITIES.SHORT_NAME%TYPE;
BEGIN
    SELECT P.SHORT_NAME INTO l_Short_Name
    FROM   BSC_SYS_PERIODICITIES P
    WHERE  P.PERIODICITY_ID = p_Periodicity_Id;

    RETURN l_Short_Name;

EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;
END Get_Periodicity_Short_Name;

-- added exception for Bug#4626530
FUNCTION Get_Periods_In_Base_Period (
    p_Base_Periodicity_Id IN NUMBER
) RETURN NUMBER
IS
    l_no_Periods  NUMBER;
BEGIN
    SELECT NUM_OF_PERIODS
    INTO   l_No_Periods
    FROM   BSC_SYS_PERIODICITIES
    WHERE  PERIODICITY_ID = p_Base_Periodicity_Id;

    RETURN l_No_Periods;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END Get_Periods_In_Base_Period;


PROCEDURE Rollback_API (
  p_In_String               IN          VARCHAR2
 ,p_ErrorOut                IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS
BEGIN
    SAVEPOINT RollbackAPIPUB;

    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    IF (p_ErrorOut = FND_API.G_TRUE) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_ERROR_MESSAGE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO RollbackAPIPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
END Rollback_API;

-- Added APIs to get View START_DATE and END_DATE
-- A typical usage example is
-- BSC_PERIODS_UTILITY_PKG.Get_Start_Period_Date (424, 1569, 2, 2005);

FUNCTION Get_Start_Period_Date (
    p_Calendar_Id    IN NUMBER
  , p_Periodicity_Id IN NUMBER
  , p_Period_id      IN NUMBER
  , p_Year           IN NUMBER
) RETURN DATE IS
    l_Sql           VARCHAR2(1000);
    l_Period_DB_Col BSC_SYS_PERIODICITIES.DB_COLUMN_NAME%TYPE;
    l_Date          DATE;
    l_Cal_Yr        BSC_DB_CALENDAR.CALENDAR_YEAR%TYPE;
    l_Cal_Mn        BSC_DB_CALENDAR.CALENDAR_MONTH%TYPE;
    l_Cal_Dy        BSC_DB_CALENDAR.CALENDAR_DAY%TYPE;
    l_Sep           VARCHAR2(1);
BEGIN
    l_Period_DB_Col := BSC_PERIODS_UTILITY_PKG.Get_Periodicity_Db_Col(p_Periodicity_Id);


    l_Sql :=  ' SELECT A.CALENDAR_DAY, A.CALENDAR_MONTH, A.CALENDAR_YEAR FROM (' ||
              '  SELECT CALENDAR_DAY, CALENDAR_MONTH, CALENDAR_YEAR,  ' ||
              '  (DAY365 - MIN(DAY365) OVER (PARTITION BY '||l_Period_DB_Col||')) SORT_DATE  ' ||
              '  FROM BSC_DB_CALENDAR  ' ||
              '  WHERE CALENDAR_ID = :1 AND YEAR = :2 AND '||l_Period_DB_Col||' = :3) A ' ||
              ' WHERE A.SORT_DATE = 0 ';


    l_Sep := '/';

    EXECUTE IMMEDIATE l_Sql
    INTO l_Cal_Dy, l_Cal_Mn, l_Cal_Yr
    USING p_Calendar_Id, p_Year, p_Period_id;

    -- to avoid false postives (need to use direct values)
    RETURN TO_DATE(l_Cal_Mn||l_Sep||l_Cal_Dy||l_Sep||l_Cal_Yr, 'mm/dd/yyyy');

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Start_Period_Date;


FUNCTION Get_End_Period_Date (
    p_Calendar_Id    IN NUMBER
  , p_Periodicity_Id IN NUMBER
  , p_Period_id      IN NUMBER
  , p_Year           IN NUMBER
) RETURN DATE IS
    l_Sql           VARCHAR2(1000);
    l_Period_DB_Col BSC_SYS_PERIODICITIES.DB_COLUMN_NAME%TYPE;
    l_Date          DATE;
    l_Cal_Yr        BSC_DB_CALENDAR.CALENDAR_YEAR%TYPE;
    l_Cal_Mn        BSC_DB_CALENDAR.CALENDAR_MONTH%TYPE;
    l_Cal_Dy        BSC_DB_CALENDAR.CALENDAR_DAY%TYPE;
    l_Sep           VARCHAR2(1);
BEGIN
    l_Period_DB_Col := BSC_PERIODS_UTILITY_PKG.Get_Periodicity_Db_Col(p_Periodicity_Id);


    l_Sql :=  ' SELECT A.CALENDAR_DAY, A.CALENDAR_MONTH, A.CALENDAR_YEAR FROM (' ||
              '  SELECT CALENDAR_DAY, CALENDAR_MONTH, CALENDAR_YEAR,  ' ||
              '  (MAX(DAY365) OVER (PARTITION BY '||l_Period_DB_Col||')-DAY365) SORT_DATE  ' ||
              '  FROM BSC_DB_CALENDAR  ' ||
              '  WHERE CALENDAR_ID = :1 AND YEAR = :2 AND '||l_Period_DB_Col||' = :3) A ' ||
              ' WHERE A.SORT_DATE = 0 ';

    l_Sep := '/';

    EXECUTE IMMEDIATE l_Sql
    INTO l_Cal_Dy, l_Cal_Mn, l_Cal_Yr
    USING p_Calendar_Id, p_Year, p_Period_id;

    --to avoid false postives (need to use direct values)
    RETURN TO_DATE(l_Cal_Mn||l_Sep||l_Cal_Dy||l_Sep||l_Cal_Yr, 'mm/dd/yyyy');

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_End_Period_Date;


FUNCTION Get_Periodicity_Db_Col (
    p_Periodicity_Id IN NUMBER
) RETURN VARCHAR2 IS
    l_Period_DB_Col BSC_SYS_PERIODICITIES.DB_COLUMN_NAME%TYPE;
BEGIN
    SELECT P.DB_COLUMN_NAME
    INTO   l_Period_Db_Col
    FROM   BSC_SYS_PERIODICITIES P
    WHERE  P.PERIODICITY_ID = p_Periodicity_Id;

    RETURN l_Period_Db_Col;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Periodicity_Db_Col;


-- Added API for Bug#4566634
-- This API returns the correspoding Enterprise Period when a
-- Rolling Period is passed to the API
FUNCTION Get_Non_Rolling_Dim_Obj (
    p_Short_Name IN VARCHAR2
)  RETURN VARCHAR2 IS
BEGIN

    IF (p_Short_Name = C_FII_ROLLING_QTR) THEN
        RETURN C_FII_TIME_ENT_QTR;
    ELSIF (p_Short_Name = C_FII_ROLLING_WEEK) THEN
        RETURN C_FII_TIME_WEEK;
    ELSIF (p_Short_Name = C_FII_ROLLING_MONTH) THEN
        RETURN C_FII_TIME_ENT_PERIOD;
    ELSIF (p_Short_Name = C_FII_ROLLING_YEAR) THEN
        RETURN C_FII_TIME_ENT_YEAR;
    END IF;

    RETURN p_Short_Name;

EXCEPTION
    WHEN OTHERS THEN
        RETURN p_Short_Name;
END Get_Non_Rolling_Dim_Obj;

-- added for Bug#4574115
FUNCTION Get_Periodicity_Name (
    p_Periodicity_Id IN NUMBER
) RETURN VARCHAR2 IS
    l_Name BSC_SYS_PERIODICITIES_VL.NAME%TYPE;
BEGIN
    SELECT B.NAME
    INTO   l_Name
    FROM   BSC_SYS_PERIODICITIES_VL B
    WHERE  B.PERIODICITY_ID = p_Periodicity_Id;

    RETURN l_Name;

EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END Get_Periodicity_Name;

FUNCTION Get_Daily_Periodicity_Sht_Name(
  p_Calendar_Id IN NUMBER
) RETURN VARCHAR2 IS
  l_Periodicity_Short_Name BSC_SYS_PERIODICITIES_VL.SHORT_NAME%TYPE;

  CURSOR c_CalendarPeriodicities IS
    SELECT PERIODICITY_ID,
           SHORT_NAME
    FROM   BSC_SYS_PERIODICITIES_VL
    WHERE  CALENDAR_id = p_Calendar_Id;

BEGIN
   FOR prdcty IN c_CalendarPeriodicities LOOP
     IF (Is_Base_Periodicity_Daily(prdcty.PERIODICITY_ID)) THEN
       l_Periodicity_Short_Name := prdcty.SHORT_NAME;
     END IF;
   END LOOP;

   RETURN l_Periodicity_Short_Name;
EXCEPTION
  WHEN OTHERS THEN
    RETURN l_Periodicity_Short_Name;
END Get_Daily_Periodicity_Sht_Name;



/**************************************************************************
   Function Name :- generate_Period_Short_Name
   Description   :- generates period short Name  as Below
                    BSC_PER_CALx_PERy  where x = calendarId and y = periodId
   Parameters    :-
      p_Calendar_Id  :- Id of the calendar.
      p_Period_Id    :- periodicity Id of the period
*****************************************************************************/
FUNCTION generate_Period_Short_Name (
         p_Calendar_Id   IN  NUMBER
        ,p_Period_Id     IN  NUMBER
)RETURN VARCHAR2 IS
l_Short_Name      BSC_SYS_PERIODICITIES.SHORT_NAME%TYPE;
l_Flag           BOOLEAN;
l_Temp_Var       BIS_LEVELS.SHORT_NAME%TYPE;
l_Count          NUMBER;
l_alias                 VARCHAR2(4);

BEGIN
  l_Short_Name := BSC_PERIODS_UTILITY_PKG.C_PERIOD_SHORT_NAME_PREFIX||C_CALNEDAR_SHORT_PREFIX||p_Calendar_Id||
                C_UNDER_SCORE||C_PERIOD_SHORT_PREFIX||p_Period_Id;

  l_Flag     := TRUE;
  l_alias    := NULL;
  l_Temp_Var := l_Short_Name;

  WHILE (l_flag) LOOP
    SELECT COUNT(1)
    INTO   l_Count
    FROM   BIS_LEVELS_VL
    WHERE  UPPER(Short_Name) = UPPER(l_temp_var);

    IF (l_Count = 0) THEN
        l_flag            :=  FALSE;
        l_Short_Name      :=  l_temp_var;
    END IF;
      l_alias     :=  get_Next_Alias(l_alias);
      l_temp_var  :=  l_Short_Name||l_alias;
  END LOOP;

  RETURN l_Short_Name;

EXCEPTION
 WHEN OTHERS THEN
 RETURN NULL;
END generate_Period_Short_Name;
/**************************************************************************
   Function Name :- get_Dimobj_Name_From_period
   Description   :- Makes the name of period dimension object from calendar name and period name
                    BSC_PER_CALx_PERy  where x = calendarId and y = periodId
   Parameters    :-
      p_Calendar_Id         :- Id of the calendar.
      p_Periodicity_Name    :- Name of the period
*****************************************************************************/

FUNCTION get_Dimobj_Name_From_period (
  p_Calendar_Id      IN NUMBER
, p_Periodicity_Name IN VARCHAR2
) RETURN VARCHAR2 IS
l_Count          NUMBER;
l_Calendar_Name  BSC_SYS_CALENDARS_TL.NAME%TYPE;
l_Return_Name    BIS_LEVELS_TL.NAME%TYPE;
l_Flag           BOOLEAN;
l_Sequence       NUMBER;
l_Temp_Var       BIS_LEVELS_TL.NAME%TYPE;
BEGIN
  SELECT name
  INTO   l_Calendar_Name
  FROM   bsc_sys_calendars_vl
  WHERE  calendar_id = p_Calendar_Id;

  l_Return_Name := SUBSTR(l_Calendar_Name,1,254-LENGTH(p_Periodicity_Name))|| BSC_PERIODS_UTILITY_PKG.C_HYPHEN || p_Periodicity_Name;

  l_Sequence := 0;
  l_Flag := TRUE;
  l_Temp_Var := l_Return_Name;
  WHILE(l_Flag) LOOP
    SELECT COUNT(1)
    INTO   l_Count
    FROM   bis_levels_vl
    WHERE  UPPER(name) = UPPER(l_Temp_Var);

    IF(l_Count = 0 ) THEN
      l_Flag := FALSE;
      l_Return_Name := l_Temp_Var;
    END IF;
    l_Sequence := l_Sequence + 1;
    l_Temp_Var := SUBSTR(l_Calendar_Name,1,250-LENGTH(p_Periodicity_Name))||l_Sequence ||BSC_PERIODS_UTILITY_PKG.C_HYPHEN || p_Periodicity_Name;

  END LOOP;
  RETURN l_Return_Name;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_Dimobj_Name_From_period;

/**************************************************************************
   Function Name :- Get_Bsc_Periodicity
   Description   :- First checks if Period is Roling type. (Picks corresponding level id for rolilng type)
                    Then calls BSC_DBI_CALENDAR.Get_Bsc_Periodicity to get the Periodicity corresponding to level.
   Parameters    :-
      x_time_level_name   :- takes the level Short_Name and returns corresponding short_name (short_name will change for rolling type)
      x_periodicity_id    :- returns periodicity id corresponding to period
      x_calendar_id       :- returns calendar_id it is associated to.
      x_message           :- Message returned from API.
*****************************************************************************/
FUNCTION Get_Bsc_Periodicity(
    x_time_level_name    IN OUT NOCOPY VARCHAR2
  , x_periodicity_id     OUT    NOCOPY NUMBER
  , x_calendar_id        OUT    NOCOPY NUMBER
  , x_message            OUT    NOCOPY VARCHAR2
)RETURN BOOLEAN IS
BEGIN
  IF(BIS_UTILITIES_PVT.Is_Rolling_Period_Level(x_time_level_name) = 1) THEN
    x_time_level_name := BSC_PERIODS_UTILITY_PKG.Get_Non_Rolling_Dim_Obj(x_time_level_name);
  END IF;

  RETURN BSC_DBI_CALENDAR.Get_Bsc_Periodicity(
     p_time_level_name    => x_time_level_name
    ,x_periodicity_id     => x_periodicity_id
    ,x_calendar_id        => x_calendar_id
    ,x_message            => x_message
  );
END Get_Bsc_Periodicity;

/*************************************************************************************************************
API NAME : Get_Quarter_Date_Label
FUNCTIONALITY : This API takes the as of date value and the
time dimension object under consideration and returns in the
Quarter date format, for example

SQL> select BSC_PERIODS_UTILITY_PKG.Get_Quarter_Date_Format('28-JUN-02', 'BSC_PER_2453567477645868') from dual

Q2 FY02 Day -2

NOTE 1: That this API should be used only with Custom Periodicities and
this will behave unexpectedly by returning null in case of DBI Periodicities

NOTE 2: The API will return the message error text in case of date errors

NOTE 3: Appropriate ORA errors will be returned, for example

SQL> select BSC_PERIODS_UTILITY_PKG.Get_Quarter_Date_Format('28-JUN-03', 'BSC_PER_2453567477645868') from dual

ORA-01403: no data found

SQL> select BSC_PERIODS_UTILITY_PKG.Get_Quarter_Date_Format('30-FEB-03', 'BSC_PER_2453567477645868') from dual

ORA-01839: date not valid for month specified
*************************************************************************************************************/

FUNCTION Get_Quarter_Date_Label(
  p_As_Of_date                   IN VARCHAR2,
  p_Dimension_Object_Short_Name  IN VARCHAR2
) RETURN VARCHAR2 IS

  l_Calendar_Id NUMBER;
  l_Day         NUMBER;
  l_Month       NUMBER;
  l_Year        NUMBER;
  l_YY          VARCHAR2(2);
  l_Quarter     NUMBER;

  l_Last_Day_Count    NUMBER;
  l_Current_Day_Count NUMBER;
  l_Days_Left         NUMBER;

  l_Data_Label  VARCHAR2(100);

  CURSOR c_Get_Calendar_ID IS
    SELECT P.CALENDAR_ID
    FROM BSC_SYS_PERIODICITIES_VL P
    WHERE P.SHORT_NAME = p_Dimension_Object_Short_Name;

BEGIN

  l_Calendar_Id := NULL;

  FOR cGC IN c_Get_Calendar_ID LOOP
    l_Calendar_Id := cGC.CALENDAR_ID;
  END LOOP;

  IF (l_Calendar_Id IS NULL) THEN
    RETURN NULL;
  END IF;

  IF (p_As_Of_date IS NULL) THEN
    RETURN NULL;
  END IF;

  SELECT TO_NUMBER(TO_CHAR(TO_DATE(p_As_Of_date, 'DD/MM/YYYY'), 'DD')),
         TO_NUMBER(TO_CHAR(TO_DATE(p_As_Of_date, 'DD/MM/YYYY'), 'MM')),
         TO_NUMBER(TO_CHAR(TO_DATE(p_As_Of_date, 'DD/MM/YYYY'), 'YYYY')),
         TO_CHAR(TO_DATE(p_As_Of_date, 'DD/MM/YYYY'), 'YY')
  INTO   l_Day, l_Month, l_Year, l_YY
  FROM   DUAL;

  SELECT C.QUARTER, C.DAY365
  INTO   l_Quarter, l_Current_Day_Count
  FROM   BSC_DB_CALENDAR C
  WHERE  C.CALENDAR_YEAR  = l_Year
  AND    C.CALENDAR_MONTH = l_Month
  AND    C.CALENDAR_DAY   = l_Day
  AND    C.CALENDAR_ID    = l_Calendar_Id;

  -- Get the last day count for the current quarter.

  SELECT MAX(C.DAY365) INTO l_Last_Day_Count
  FROM   BSC_DB_CALENDAR C
  WHERE  C.CALENDAR_ID    = l_Calendar_Id
  AND    C.CALENDAR_YEAR  = l_Year
  AND    C.QUARTER        = l_Quarter;


  l_Days_Left := (l_Last_Day_Count - l_Current_Day_Count);

  -- Q&QUARTER_NUMBER FY&YEAR_NUMBER Day -&DAY_NUMBER
  FND_MESSAGE.SET_NAME('BSC', 'BSC_DATE_LABEL');
  FND_MESSAGE.SET_TOKEN('DAY_NUMBER', l_Days_Left, FALSE);
  FND_MESSAGE.SET_TOKEN('QUARTER_NUMBER', l_Quarter, FALSE);
  FND_MESSAGE.SET_TOKEN('YEAR_NUMBER',l_YY, FALSE);

  l_Data_Label := FND_MESSAGE.GET;

  RETURN l_Data_Label;
EXCEPTION
  WHEN OTHERS THEN
    RETURN SQLERRM;
END Get_Quarter_Date_Label;


END BSC_PERIODS_UTILITY_PKG;

/
