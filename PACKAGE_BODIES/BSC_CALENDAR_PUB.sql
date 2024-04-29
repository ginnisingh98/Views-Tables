--------------------------------------------------------
--  DDL for Package Body BSC_CALENDAR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_CALENDAR_PUB" AS
/* $Header: BSCPCALB.pls 120.4 2007/12/18 06:49:19 lbodired ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCPCALB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Public package for populating the calendar  tables        |
REM | NOTES                                                                 |
REM | 07-JUN-2005 Krishna  Created.                                         |
REM | 31-AUG-2005 Aditya Rao fixed Bug#4565308 for START_DAY of fiscal year |
REM | 29-NOV-2005 Krishna Modified for enh#4711274                          |
REM | 06-JUL-07 psomesul  Bug#6168487 - CHANGING CALENDAR DEF WHICH IS IN PRODUCTION IS NOT TRIGGERING  TO USER |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_CALENDAR_PUB';

FISCAL_YEAR_CHANGE  NUMBER := 0;
--The following three APIs are used to call BIA populate canlednars
--in different phases
--For every calendar we create we create dimension also
PROCEDURE Create_Calendar_Dimension
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Calendar_Dimension
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
);

PROCEDURE Change_Fiscal_Year
IS
BEGIN
  FISCAL_YEAR_CHANGE := 1;
END Change_Fiscal_Year;

FUNCTION  Get_Fiscal_Year
RETURN NUMBER IS
BEGIN
  RETURN FISCAL_YEAR_CHANGE;
END Get_Fiscal_Year;

PROCEDURE Create_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS
l_Calendar_Record BSC_CALENDAR_PUB.Calendar_Type_Record;
BEGIN
  SAVEPOINT CreateCalendarPubSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  BSC_CALENDAR_PUB.Validate_Calendar_Action
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Calendar_Record  => p_Calendar_Record
  , p_Action           => BSC_PERIODS_UTILITY_PKG.C_CREATE
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_CALENDAR_PUB.Fill_Default_Values_Create_Cal
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Calendar_Record  => p_Calendar_Record
  , x_Calendar_Record  => l_Calendar_Record
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_CALENDAR_PVT.Create_Calendar
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Calendar_Record  => l_Calendar_Record
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_CALENDAR_PUB.Create_Calendar_Dimension
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Calendar_Record  => l_Calendar_Record
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_CALENDAR_PUB.Create_Calendar_Post_Action
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Calendar_Record  => l_Calendar_Record
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ((p_Commit IS NOT NULL) AND (p_Commit = FND_API.G_TRUE)) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CreateCalendarPubSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CreateCalendarPubSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO CreateCalendarPubSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Create_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Create_Calendar ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO CreateCalendarPubSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Create_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Create_Calendar ';
    END IF;
END Create_Calendar;

/*****************************************************************************************/

PROCEDURE Update_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS
l_Calendar_Record BSC_CALENDAR_PUB.Calendar_Type_Record;
l_Fiscal_Year       BSC_SYS_CALENDARS_B.FISCAL_YEAR%TYPE;
l_Start_Month       BSC_SYS_CALENDARS_B.START_MONTH%TYPE;
l_Start_Day         BSC_SYS_CALENDARS_B.START_DAY%TYPE;
l_Calendar_Old_Name BSC_SYS_CALENDARS_TL.NAME%TYPE;
BEGIN
  SAVEPOINT UpdateCalendarPubSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  SELECT fiscal_year
        ,start_month
        ,start_day
        ,name
  INTO   l_Fiscal_Year
        ,l_Start_Month
        ,l_Start_Day
        ,l_Calendar_Old_Name
  FROM   bsc_sys_calendars_vl
  WHERE  calendar_id = p_Calendar_Record.Calendar_Id;

  -- added for Bug#4565308
  IF((l_Fiscal_Year <> p_Calendar_Record.Fiscal_Year)
      OR (l_Start_Month <> p_Calendar_Record.Start_Month)
      OR (l_Start_Day <> p_Calendar_Record.Start_Day)) THEN
    Change_Fiscal_Year();
  END IF;

  BSC_CALENDAR_PUB.Validate_Calendar_Action
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Calendar_Record  => p_Calendar_Record
  , p_Action           => BSC_PERIODS_UTILITY_PKG.C_UPDATE
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_CALENDAR_PUB.Retrieve_And_Populate_Cal_Rec
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Calendar_Record  => p_Calendar_Record
  , x_Calendar_Record  => l_Calendar_Record
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_CALENDAR_PVT.Update_Calendar
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Calendar_Record  => l_Calendar_Record
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_CALENDAR_PUB.Update_Calendar_Dimension
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Calendar_Record  => l_Calendar_Record
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF(UPPER(LTRIM(RTRIM(p_Calendar_Record.Name))) <> UPPER(LTRIM(RTRIM(l_Calendar_Old_Name)))) THEN
    BSC_CALENDAR_PVT.Update_PeriodNames_In_Calendar
    ( p_Calendar_Id        => p_Calendar_Record.Calendar_Id
    , x_Return_Status      => x_Return_Status
    , x_Msg_Count          => x_Msg_Count
    , x_Msg_Data           => x_Msg_Data
    );
    IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  BSC_CALENDAR_PUB.Update_Calendar_Post_Action
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Calendar_Record  => l_Calendar_Record
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF ((p_Commit IS NOT NULL) AND (p_Commit = FND_API.G_TRUE)) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UpdateCalendarPubSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UpdateCalendarPubSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO UpdateCalendarPubSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Update_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Update_Calendar ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO UpdateCalendarPubSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Update_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Update_Calendar ';
    END IF;
END Update_Calendar;



/****************************************************************************************/
PROCEDURE Delete_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS
CURSOR C_Periodicity_ShortNames IS
SELECT short_name
FROM   bsc_sys_periodicities
WHERE  calendar_id = p_Calendar_Record.Calendar_Id;

CURSOR C_Per_Views IS
SELECT B.level_values_view_name
FROM   bsc_sys_periodicities P,
       bis_levels        B
WHERE  b.short_name = P.short_name
AND    P.calendar_id = p_Calendar_Record.Calendar_Id
AND    P.db_column_name IS NOT NULL;

CURSOR C_Clendar_ShortName IS
SELECT short_name
FROM   bsc_sys_calendars_b
WHERE  calendar_id = p_Calendar_Record.Calendar_Id;

l_Views_Array     varchar2_tabletype;
l_Comma_Per_ShortNames  VARCHAR2(32000);
l_Calendar_ShortName    BSC_SYS_CALENDARS_B.SHORT_NAME%TYPE;
l_DimObj_ViewName       BIS_LEVELS.LEVEL_VALUES_VIEW_NAME%TYPE;
l_count                NUMBER;

BEGIN
  SAVEPOINT DeleteCalendarPubSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  BSC_CALENDAR_PUB.Validate_Calendar_Action
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Calendar_Record  => p_Calendar_Record
  , p_Action           => BSC_PERIODS_UTILITY_PKG.C_DELETE
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FOR CCAL IN C_Clendar_ShortName LOOP
    l_Calendar_ShortName := CCAL.short_name;
  END LOOP;

  FOR CD IN C_Periodicity_ShortNames LOOP
    IF(l_Comma_Per_ShortNames IS NULL) THEN
      l_Comma_Per_ShortNames := CD.short_name;
    ELSE
      l_Comma_Per_ShortNames := l_Comma_Per_ShortNames || ','||CD.short_name;
    END IF;
  END LOOP;

  l_count := 0;
  FOR CViews IN C_Per_Views  LOOP
      l_count := l_count + 1;
      l_Views_Array(l_count) := CViews.level_values_view_name;
  END LOOP;

  BSC_BIS_DIMENSION_PUB.UnAssign_Dimension_Objects
  ( p_commit               => p_Commit
  , p_dim_short_name       => l_Calendar_ShortName
  , p_dim_obj_short_names  => l_Comma_Per_ShortNames
  , p_time_stamp           => NULL
  , x_return_status        => x_Return_Status
  , x_msg_count            => x_Msg_Count
  , x_msg_data             => x_Msg_Data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Delete dimension objects corresponding to periodicities
  FOR CPER in C_Periodicity_ShortNames LOOP
    BSC_BIS_DIM_OBJ_PUB.Delete_Dim_Object
    ( p_commit              => p_commit
    , p_dim_obj_short_name  => CPER.short_name
    , x_return_status       => x_Return_Status
    , x_msg_count           => x_Msg_Count
    , x_msg_data            => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;
  --Delete dimension corresponding to calendar
  BSC_BIS_DIMENSION_PUB.Delete_Dimension
  ( p_commit          => p_commit
  , p_dim_short_name  => l_Calendar_ShortName
  , x_return_status   => x_Return_Status
  , x_msg_count       => x_Msg_Count
  , x_msg_data        => x_Msg_Data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --Delete calendar
  BSC_CALENDAR_PVT.Delete_Calendar
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Calendar_Record  => p_Calendar_Record
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  FOR index_loop IN 1..l_count LOOP
    l_DimObj_ViewName := l_Views_Array(index_loop);
    IF(l_DimObj_ViewName IS NOT NULL) THEN
      BSC_PERIODS_PUB.Drop_Periodicity_View
      ( p_Periodicity_View  => l_DimObj_ViewName
      , x_Return_Status     => x_Return_Status
      , x_Msg_Count         => x_Msg_Count
      , x_Msg_Data          => x_Msg_Data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END LOOP;
  IF ((p_Commit IS NOT NULL) AND (p_Commit = FND_API.G_TRUE)) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DeleteCalendarPubSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DeleteCalendarPubSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO DeleteCalendarPubSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Delete_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Delete_Calendar ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO DeleteCalendarPubSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Delete_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Delete_Calendar ';
    END IF;
END Delete_Calendar;

/***********************************************************************************/

PROCEDURE Validate_Calendar_Action
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, p_Action                 IN          VARCHAR2
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS
l_count             NUMBER := 0;
l_Objective_Names   VARCHAR2(32000);
l_Calendar_Name     BSC_SYS_CALENDARS_TL.NAME%TYPE;

CURSOR C_Objectives IS
SELECT k.name
FROM   bsc_kpis_vl K
WHERE  K.calendar_id = p_Calendar_Record.Calendar_Id;


BEGIN

  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;
  IF(p_Action = BSC_PERIODS_UTILITY_PKG.C_CREATE OR p_Action = BSC_PERIODS_UTILITY_PKG.C_UPDATE) THEN
    IF(BIS_UTILITIES_PVT.Value_Missing_Or_Null(p_Calendar_Record.Name) = FND_API.G_TRUE) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_CALENDAR_NAME_NULL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF(BIS_UTILITIES_PVT.Value_Missing_Or_Null(p_Calendar_Record.Dim_Short_Name) = FND_API.G_TRUE) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_CAL_SHORT_NAME_NULL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  IF(p_Action = BSC_PERIODS_UTILITY_PKG.C_CREATE ) THEN
    SELECT COUNT(1)
    INTO   l_count
    FROM   bsc_sys_calendars_b
    WHERE  TRIM(calendar_id) = TRIM(p_Calendar_Record.Calendar_Id);
    IF(l_count > 0)THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_CAL_ID_EXISTS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT COUNT(1)
    INTO   l_count
    FROM   bsc_sys_calendars_vl
    WHERE  TRIM(NAME) = TRIM(p_Calendar_Record.Name);
    IF(l_count > 0)THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_CALENDAR_EXISTS');
      FND_MESSAGE.SET_TOKEN('CALENDAR_NAME',TRIM(p_Calendar_Record.Name));
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT COUNT(1)
    INTO   l_count
    FROM   bsc_sys_calendars_b
    WHERE  TRIM(short_name) = TRIM(p_Calendar_Record.Dim_Short_Name);
    IF( l_count > 0 ) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_CAL_SHORT_NAME_UNIQUE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSIF(p_Action = BSC_PERIODS_UTILITY_PKG.C_UPDATE) THEN
    IF(p_Calendar_Record.Fiscal_Year IS NULL) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_FISCAL_YEAR_NULL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT COUNT(1)
    INTO   l_count
    FROM   BSC_SYS_CALENDARS_B
    WHERE  CALENDAR_ID <> p_Calendar_Record.Calendar_Id
    AND    TRIM(short_name) = TRIM(p_Calendar_Record.Dim_Short_Name);
    IF( l_count > 0 ) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_CAL_SHORT_NAME_UNIQUE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF(p_Action = BSC_PERIODS_UTILITY_PKG.C_DELETE ) THEN

    l_count := 0;
    SELECT COUNT(1)
    INTO   l_count
    FROM   bsc_sys_calendars_b
    WHERE  calendar_id = p_Calendar_Record.Calendar_Id;
    --first check if the calendar passed exists or not
    IF(l_count = 0 ) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_CALENDAR_DEL_ALREADY');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_count := 0;
    SELECT COUNT(K.INDICATOR)
    INTO   l_count
    FROM   BSC_KPI_PERIODICITIES K,
           BSC_SYS_PERIODICITIES S
    WHERE  S.PERIODICITY_ID = K.PERIODICITY_ID
    AND    S.CALENDAR_ID = p_Calendar_Record.Calendar_Id;

    SELECT name
    INTO   l_Calendar_Name
    FROM   bsc_sys_calendars_vl
    WHERE  calendar_id = p_Calendar_Record.Calendar_Id;

    IF (l_count <> 0) THEN
      FOR cObj IN C_Objectives LOOP
        IF(l_Objective_Names IS NULL) THEN
          l_Objective_Names := cObj.name;
        ELSE
          l_Objective_Names := l_Objective_Names || ',' || cObj.name;
        END IF;
      END LOOP;
      FND_MESSAGE.SET_NAME('BSC','BSC_CALENDAR_USED_IN_OBJECTIVE');
      FND_MESSAGE.SET_TOKEN('CALENDAR', l_Calendar_Name);
      FND_MESSAGE.SET_TOKEN('OBJECTIVES', l_Objective_Names);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  IF ((p_Commit IS NOT NULL) AND (p_Commit = FND_API.G_TRUE)) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Validate_Calendar_Action ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Validate_Calendar_Action ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Validate_Calendar_Action ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Validate_Calendar_Action ';
    END IF;
END Validate_Calendar_Action;

/*******************************************************************************************/

PROCEDURE Retrieve_And_Populate_Cal_Rec
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Calendar_Record        OUT NOCOPY  BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS

BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

 SELECT  calendar_id
       , edw_flag
       , edw_calendar_id
       , edw_calendar_type_id
       , fiscal_year
       , fiscal_change
       , range_yr_mod
       , current_year
       , start_month
       , start_day
       , name
       , help
       , created_by
       , creation_date
       , last_updated_by
       , last_update_date
       , last_update_login
  INTO   x_Calendar_Record.Calendar_Id
       , x_Calendar_Record.Edw_Flag
       , x_Calendar_Record.Edw_Calendar_Id
       , x_Calendar_Record.Edw_Calendar_Type_Id
       , x_Calendar_Record.Fiscal_Year
       , x_Calendar_Record.Fiscal_Change
       , x_Calendar_Record.Range_Yr_Mod
       , x_Calendar_Record.Current_Year
       , x_Calendar_Record.Start_Month
       , x_Calendar_Record.Start_Day
       , x_Calendar_Record.Name
       , x_Calendar_Record.Help
       , x_Calendar_Record.Created_By
       , x_Calendar_Record.Creation_Date
       , x_Calendar_Record.Last_Updated_By
       , x_Calendar_Record.Last_Update_Date
       , x_Calendar_Record.Last_Update_Login
  FROM  bsc_sys_calendars_vl
  WHERE calendar_id = p_Calendar_Record.Calendar_Id;


  IF(p_Calendar_Record.Name <> x_Calendar_Record.Name) THEN
    x_Calendar_Record.Name := p_Calendar_Record.Name;
  END IF;

  IF(p_Calendar_Record.Help <> x_Calendar_Record.Help) THEN
    x_Calendar_Record.Help := p_Calendar_Record.Help;
  END IF;

  IF(p_Calendar_Record.Fiscal_Year <> x_Calendar_Record.Fiscal_Year) THEN
    x_Calendar_Record.Fiscal_Year := p_Calendar_Record.Fiscal_Year;
  END IF;

  IF(p_Calendar_Record.Current_Year <> x_Calendar_Record.Current_Year) THEN
    x_Calendar_Record.Current_Year := p_Calendar_Record.Current_Year;
  END IF;

  IF(p_Calendar_Record.Start_Month <> x_Calendar_Record.Start_Month) THEN
    x_Calendar_Record.Start_Month := p_Calendar_Record.Start_Month;
  END IF;

  -- added for Bug#4565308
  IF(p_Calendar_Record.Start_Day <> x_Calendar_Record.Start_Day) THEN
    x_Calendar_Record.Start_Day := p_Calendar_Record.Start_Day;
  END IF;

  IF(p_Calendar_Record.Last_Update_Date IS NULL ) THEN
      x_Calendar_Record.Last_Update_Date := SYSDATE;
  ELSE
      x_Calendar_Record.Last_Update_Date := p_Calendar_Record.Last_Update_Date;
  END IF;

  IF (p_Calendar_Record.Last_Updated_By IS NULL) THEN
    x_Calendar_Record.Last_Updated_By := FND_GLOBAL.USER_ID;
  ELSE
    x_Calendar_Record.Last_Updated_By := p_Calendar_Record.Last_Updated_By;
  END IF;

  IF (p_Calendar_Record.Last_Update_Login IS NULL) THEN
    x_Calendar_Record.Last_Update_Login := FND_GLOBAL.LOGIN_ID;
  ELSE
    x_Calendar_Record.Last_Update_Login := p_Calendar_Record.Last_Update_Login;
  END IF;

  x_Calendar_Record.Dim_Short_Name  := p_Calendar_Record.Dim_Short_Name;
  x_Calendar_Record.Application_Id  := p_Calendar_Record.Application_Id;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Retrieve_And_Populate_Cal_Rec';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Retrieve_And_Populate_Cal_Rec ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Retrieve_And_Populate_Cal_Rec ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Retrieve_And_Populate_Cal_Rec ';
    END IF;
END Retrieve_And_Populate_Cal_Rec;
/*************************************************************************************/

PROCEDURE Create_Calendar_Post_Action
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS

BEGIN
  SAVEPOINT CreateCalendarPostActionSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  BSC_CALENDAR_PUB.Create_Periodicities_Calendar
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Calendar_Record  => p_Calendar_Record
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_UPDATE_UTIL.Populate_Calendar_Tables
  ( p_commit         => p_Commit
  , p_calendar_id    => p_Calendar_Record.Calendar_Id
  , x_return_status  => x_Return_Status
  , x_msg_count      => x_Msg_Count
  , x_msg_data       => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CreateCalendarPostActionSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CreateCalendarPostActionSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO CreateCalendarPostActionSP;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Create_Calendar_Post_Action';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Create_Calendar_Post_Action ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO CreateCalendarPostActionSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Create_Calendar_Post_Action ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Create_Calendar_Post_Action ';
    END IF;

END Create_Calendar_Post_Action;

/*************************************************************************************/

PROCEDURE Fill_Default_Values_Create_Cal
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Calendar_Record        OUT NOCOPY  BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS

BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    x_Calendar_Record := p_Calendar_Record;

  IF (p_Calendar_Record.Calendar_Id IS NULL) THEN
    x_Calendar_Record.Calendar_Id := BSC_PERIODS_UTILITY_PKG.Get_Next_Calendar_Id;
  ELSE
    x_Calendar_Record.Calendar_Id := p_Calendar_Record.Calendar_Id;
  END IF;

  IF(p_Calendar_Record.Name IS NULL) THEN
    x_Calendar_Record.Name := BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'CALENDAR') ||' '|| x_Calendar_Record.Calendar_Id;
  ELSE
    x_Calendar_Record.Name := P_Calendar_Record.Name;
  END IF;

  IF(p_Calendar_Record.Help IS NULL) THEN
    x_Calendar_Record.Help := p_Calendar_Record.Name;
  ELSE
    x_Calendar_Record.Help := P_Calendar_Record.Help;
  END IF;

  IF(p_Calendar_Record.Edw_Flag IS NULL) THEN
    x_Calendar_Record.Edw_Flag := BSC_PERIODS_UTILITY_PKG.C_CONSTANT_ZERO;
  ELSE
    x_Calendar_Record.Edw_Flag := p_Calendar_Record.Edw_Flag;
  END IF;

  IF(p_Calendar_Record.Edw_Calendar_Id IS NOT NULL) THEN
    x_Calendar_Record.Edw_Calendar_Id := p_Calendar_Record.Edw_Calendar_Id;
  END IF;

  IF(p_Calendar_Record.Edw_Calendar_Type_Id IS NOT NULL) THEN
    x_Calendar_Record.Edw_Calendar_Type_Id := p_Calendar_Record.Edw_Calendar_Type_Id;
  END IF;

  IF(p_Calendar_Record.Fiscal_Year IS NULL) THEN
    x_Calendar_Record.Fiscal_Year := to_char(SYSDATE,'YYYY');
  ELSE
    x_Calendar_Record.Fiscal_Year := p_Calendar_Record.Fiscal_Year;
  END IF;

  IF(p_Calendar_Record.Fiscal_Change IS NULL) THEN
    x_Calendar_Record.Fiscal_Change := BSC_PERIODS_UTILITY_PKG.C_CONSTANT_ZERO;
  ELSE
    x_Calendar_Record.Fiscal_Change  := p_Calendar_Record.Fiscal_Change;
  END IF;

  IF(p_Calendar_Record.Range_Yr_Mod IS NULL) THEN
    x_Calendar_Record.Range_Yr_Mod := BSC_PERIODS_UTILITY_PKG.C_CONSTANT_ZERO;
  ELSE
    x_Calendar_Record.Range_Yr_Mod := p_Calendar_Record.Range_Yr_Mod;
  END IF;

  IF(p_Calendar_Record.Start_Month IS NULL) THEN
    x_Calendar_Record.Start_Month := BSC_PERIODS_UTILITY_PKG.C_DEFAULT_START_MONTH;
  ELSE
    x_Calendar_Record.Start_Month := p_Calendar_Record.Start_Month;
  END IF;

  IF(p_Calendar_Record.Start_Day IS NULL) THEN
    x_Calendar_Record.Start_Day := BSC_PERIODS_UTILITY_PKG.C_DEFAULT_START_DAY;
  ELSE
    x_Calendar_Record.Start_Day  := p_Calendar_Record.Start_Day;
  END IF;

  IF(p_Calendar_Record.Dim_Short_Name IS NULL) THEN
    x_Calendar_Record.Dim_Short_Name := BSC_PERIODS_UTILITY_PKG.Get_Unique_Short_Name();
  ELSE
    x_Calendar_Record.Dim_Short_Name  := p_Calendar_Record.Dim_Short_Name;
  END IF;

  IF(p_Calendar_Record.Application_Id IS NULL) THEN
    x_Calendar_Record.Application_Id := BSC_PERIODS_UTILITY_PKG.C_BSC_APPLICATION_ID;
  ELSE
    x_Calendar_Record.Application_Id  := p_Calendar_Record.Application_Id;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Fill_Default_Values_Create_Cal';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Fill_Default_Values_Create_Cal ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Fill_Default_Values_Create_Cal ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Fill_Default_Values_Create_Cal';
    END IF;
END Fill_Default_Values_Create_Cal;

/*****************************************************************************************/

PROCEDURE Update_Calendar_Post_Action
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS
l_System_Stage   bsc_sys_init.property_value%TYPE;

BEGIN
  SAVEPOINT UpdateCalendarPostActionSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  SELECT property_value
  INTO   l_System_Stage
  from   bsc_sys_init
  WHERE  property_code =  BSC_PERIODS_UTILITY_PKG.C_SYSTEM_STAGE;

  IF(l_System_Stage = 2 AND  Get_Fiscal_Year() = 1) THEN
    BSC_CALENDAR_PVT.Update_Fiscal_Change
    ( p_Api_Version            => p_Api_Version
    , p_Commit                 => p_Commit
    , p_Calendar_Id            => p_Calendar_Record.Calendar_Id
    , x_Return_Status          => x_Return_Status
    , x_Msg_Count              => x_Msg_Count
    , x_Msg_Data               => x_Msg_Data
    );
    IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_CALENDAR_PUB.Flag_Changes_For_Objectives
    ( p_Api_Version            => p_Api_Version
    , p_Commit                 => p_Commit
    , p_Calendar_Id            => p_Calendar_Record.Calendar_Id
    , x_Return_Status          => x_Return_Status
    , x_Msg_Count              => x_Msg_Count
    , x_Msg_Data               => x_Msg_Data
    );
    IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_UPDATE_UTIL.Populate_Calendar_Tables
    ( p_commit         => p_Commit
    , p_calendar_id    => p_Calendar_Record.Calendar_Id
    , x_return_status  => x_Return_Status
    , x_msg_count      => x_Msg_Count
    , x_msg_data       => x_Msg_Data
    );
    IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UpdateCalendarPostActionSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UpdateCalendarPostActionSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO UpdateCalendarPostActionSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data ||'BSC_CALENDAR_PUB.Update_Calendar_Post_Action ';
    ELSE
      x_msg_data      :=  SQLERRM || 'at BSC_CALENDAR_PUB.Update_Calendar_Post_Action ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO UpdateCalendarPostActionSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Update_Calendar_Post_Action ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Update_Calendar_Post_Action ';
    END IF;
END Update_Calendar_Post_Action;

/*****************************************************************************************/

PROCEDURE Flag_Changes_For_Objectives
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Id            IN          NUMBER
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS


CURSOR C_FLAG_OBJECTIVES IS
  SELECT DISTINCT(K.indicator)
  FROM   bsc_kpi_periodicities K,
         bsc_sys_periodicities S
  WHERE  S.periodicity_id = K.periodicity_id
  AND    S.calendar_id    = p_Calendar_Id;

BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  FOR CD IN C_FLAG_OBJECTIVES LOOP
    BSC_DESIGNER_PVT.ActionFlag_Change(CD.indicator,BSC_DESIGNER_PVT.G_ActionFlag.Update_Update);

    IF(BSC_PERIODS_UTILITY_PKG.Check_Error_Message('ActionFlag_Change')) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_ERROR_ACTION_FLAG_CHANGE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END LOOP;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Flag_Changes_For_Objectives ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Flag_Changes_For_Objectives ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Flag_Changes_For_Objectives ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Flag_Changes_For_Objectives ';
    END IF;
END Flag_Changes_For_Objectives;
/*****************************************************************************************/

PROCEDURE Create_Periodicities_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS
l_Calendar_Record     BSC_CALENDAR_PUB.Calendar_Type_Record;
h_tmp_array           BSC_UPDATE_UTIL.t_array_of_number;
h_count               NUMBER;
h_new_per_id          NUMBER;
h_periodicity_type    NUMBER;
h_new_source          VARCHAR2(200);
l_Periodicity_Record  BSC_PERIODICITIES_PUB.Periodicities_Rec_Type;

l_Periodicity_Ids    BSC_UTILITY.VARCHAR_TABLETYPE;
l_Periodicity_Count  NUMBER;
l_Count              NUMBER;

CURSOR c_base_per (p_calendar_id NUMBER, p_custom_code NUMBER) IS
  SELECT PERIODICITY_ID
  FROM   BSC_SYS_PERIODICITIES
  WHERE  CALENDAR_ID = p_calendar_id
  AND    CUSTOM_CODE < p_custom_code
  ORDER  BY PERIODICITY_ID;

CURSOR c_new_per (p_calendar_id NUMBER) IS
  SELECT PERIODICITY_ID,SOURCE
  FROM   BSC_SYS_PERIODICITIES
  WHERE  CALENDAR_ID = p_calendar_id
  ORDER  BY PERIODICITY_ID;

CURSOR c_get_per (p_calendar_id NUMBER, p_periodicity_type NUMBER) IS
  SELECT PERIODICITY_ID
  FROM   BSC_SYS_PERIODICITIES
  WHERE  CALENDAR_ID = p_calendar_id
  AND    PERIODICITY_TYPE = p_periodicity_type;

BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;
  BSC_APPS.Init_Bsc_Apps;
  l_Count := 1;

  IF (p_Calendar_Record.Base_Periodicities_Ids IS NOT NULL) THEN
    BSC_UTILITY.Parse_String
    ( p_List         => p_Calendar_Record.Base_Periodicities_Ids
    , p_Separator    => BSC_PERIODS_UTILITY_PKG.C_COMMA_SEPARATOR
    , p_List_Data    => l_Periodicity_Ids
    , p_List_number  => l_Periodicity_Count
    );
  END IF;

  FOR CD IN c_base_per(1, 1) LOOP
    SELECT  NULL
          , num_of_periods
          , source
          , num_of_subperiods
          , period_col_name
          , subperiod_col_name
          , yearly_flag
          , edw_flag
          , p_Calendar_Record.Calendar_Id
          , edw_periodicity_id
          , custom_code
          , db_column_name
          , periodicity_type
          , name
    INTO    l_Periodicity_Record.Periodicity_Id
          , l_Periodicity_Record.Num_Of_Periods
          , l_Periodicity_Record.Source
          , l_Periodicity_Record.Num_Of_Subperiods
          , l_Periodicity_Record.Period_Col_Name
          , l_Periodicity_Record.Subperiod_Col_Name
          , l_Periodicity_Record.Yearly_Flag
          , l_Periodicity_Record.Edw_Flag
          , l_Periodicity_Record.Calendar_Id
          , l_Periodicity_Record.Edw_Periodicity_Id
          , l_Periodicity_Record.Custom_Code
          , l_Periodicity_Record.Db_Column_Name
          , l_Periodicity_Record.Periodicity_Type
          , l_Periodicity_Record.Name
    FROM bsc_sys_periodicities_vl
    WHERE periodicity_id = CD.periodicity_id;

    IF (p_Calendar_Record.Base_Periodicities_Ids IS NOT NULL) THEN
        IF (l_Periodicity_Count > 0) THEN
            l_Periodicity_Record.Periodicity_Id := l_Periodicity_Ids(l_Count);
        END IF;

        l_Periodicity_Count := l_Periodicity_Count - 1;
        l_Count := l_Count + 1;
    END IF;
    l_Periodicity_Record.ForceRunPopulateCalendar := FND_API.G_FALSE;

    BSC_PERIODICITIES_PUB.Create_Periodicity
    ( p_Api_Version             => p_Api_Version
    , p_Commit                  => p_Commit
    , p_Periodicities_Rec_Type  => l_Periodicity_Record
    , x_Return_Status           => x_Return_Status
    , x_Msg_Count               => x_Msg_Count
    , x_Msg_Data                => x_Msg_Data
    );

  END LOOP;
  FOR cd_new_per IN c_new_per(p_Calendar_Record.Calendar_Id) LOOP
    h_new_source := '';
    IF cd_new_per.source IS NOT NULL THEN
      h_count := BSC_UPDATE_UTIL.Decompose_Numeric_List(cd_new_per.source,h_tmp_array,',');
      FOR h_i IN 1.. h_count LOOP
        h_periodicity_type := h_tmp_array(h_i);

        OPEN c_get_per(p_Calendar_Record.Calendar_Id, h_periodicity_type);
        FETCH c_get_per INTO h_new_per_id;
        IF c_get_per%FOUND THEN
          IF h_new_source IS NOT NULL THEN
            h_new_source := h_new_source  || ',' || h_new_per_id;
          ELSE
            h_new_source :=h_new_per_id;
          END IF;
        END IF;
        CLOSE c_get_per;
      END LOOP;

      UPDATE bsc_sys_periodicities
      SET    source = h_new_source
      WHERE  periodicity_id = cd_new_per.periodicity_id;
    END IF;
  END LOOP;



EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Create_Periodicities_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Create_Periodicities_Calendar ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Create_Periodicities_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Create_Periodicities_Calendar ';
    END IF;
END Create_Periodicities_Calendar;
/*********************************************************************************/
PROCEDURE Create_Calendar_Dimension
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS
l_Short_Name  bsc_sys_calendars_b.short_name%TYPE;
BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  IF(p_Calendar_Record.Dim_Short_Name IS NULL) THEN
    l_Short_Name := BSC_PERIODS_UTILITY_PKG.Get_Unique_Short_Name();
  ELSE
    l_Short_Name := p_Calendar_Record.Dim_Short_Name;
  END IF;

  BSC_BIS_DIMENSION_PUB.Create_Dimension
  ( p_commit                => p_Commit
  , p_dim_short_name        => l_Short_Name
  , p_display_name          => p_Calendar_Record.Name
  , p_description           => p_Calendar_Record.Help
  , p_dim_obj_short_names   => NULL
  , p_application_id        => p_Calendar_Record.Application_Id
  , p_create_view           => 0
  , x_return_status         => x_Return_Status
  , x_msg_count             => x_Msg_Count
  , x_msg_data              => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  UPDATE bsc_sys_calendars_b
  SET    short_name  = l_Short_Name
  WHERE  calendar_id = p_Calendar_Record.calendar_id;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Create_Calendar_Dimension ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Create_Calendar_Dimension ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Create_Calendar_Dimension ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Create_Calendar_Dimension ';
    END IF;
END Create_Calendar_Dimension;
/*******************************************************************************/
PROCEDURE Update_Calendar_Dimension
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS
CURSOR C_comma_objNames IS
SELECT obj_short_name
FROM   bsc_bis_dim_obj_by_dim_vl
WHERE  dim_short_name = p_Calendar_Record.Dim_Short_Name;


l_Short_Name  bsc_sys_calendars_b.short_name%TYPE;
l_dim_obj_shortNames    VARCHAR2(32000);
BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  FOR CD IN C_comma_objNames LOOP
    IF(l_dim_obj_shortNames IS NULL) THEN
      l_dim_obj_shortNames := CD.obj_short_name;
    ELSE
      l_dim_obj_shortNames := l_dim_obj_shortNames || ',' ||CD.obj_short_name;
    END IF;
  END LOOP;


  BSC_BIS_DIMENSION_PUB.Update_Dimension
  ( p_commit               => p_Commit
  , p_dim_short_name       => p_Calendar_Record.Dim_Short_Name
  , p_display_name         => p_Calendar_Record.Name
  , p_description          => p_Calendar_Record.Help
  , p_application_id       => p_Calendar_Record.Application_Id
  , p_dim_obj_short_names  => l_dim_obj_shortNames
  , p_time_stamp           => NULL
  , x_return_status        => x_return_status
  , x_msg_count            => x_msg_count
  , x_msg_data             => x_msg_data
  );

  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Update_Calendar_Dimension ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Update_Calendar_Dimension ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Update_Calendar_Dimension ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Update_Calendar_Dimension ';
    END IF;
END Update_Calendar_Dimension;


FUNCTION get_production_obj_having_cal(
  p_cal_id  IN   bsc_kpis_b.calendar_id%TYPE
  )
RETURN VARCHAR2 IS
  l_result        VARCHAR2(32000);
  CURSOR c_objs IS
    SELECT  indicator, name, calendar_id
    FROM bsc_kpis_vl
    WHERE prototype_flag = 0
      AND calendar_id    = p_cal_id;
BEGIN
  l_result := NULL;
  IF (p_cal_id IS NOT NULL) THEN
    FOR cd IN c_objs LOOP
       IF (l_result IS NULL) THEN
           l_result := cd.name;
       ELSE
           l_result := l_result || ',' || cd.name;
       END IF;
    END LOOP;
  END IF;
  RETURN l_result;
END get_production_obj_having_cal;

PROCEDURE comp_leapyear_prioryear(
  p_calid IN NUMBER,
  p_cyear IN NUMBER,
  p_pyear IN NUMBER,
  x_result OUT nocopy NUMBER
 )IS
lday number :=0;
lmonth number:=0;

CURSOR diff IS
SELECT day30, MONTH
FROM bsc_db_calendar
WHERE calendar_id = p_calid
AND   year =  p_cyear
MINUS
SELECT day30, MONTH
FROM bsc_db_calendar
WHERE calendar_id = p_calid
AND   year = p_pyear;
BEGIN
  OPEN diff;
  IF diff%NOTFOUND THEN
    x_result := -1;
  ELSE
    FETCH diff into lday, lmonth;
  END IF;
  CLOSE diff;
  IF lday <>0 THEN
   SELECT day365
   INTO x_result
   FROM bsc_db_calendar
   WHERE calendar_id = p_calid
   AND  year  = p_cyear
   AND  day30 = lday
   AND  MONTH = lmonth;
 END IF;
EXCEPTION
 WHEN OTHERS THEN
   x_result := -1;
END comp_leapyear_prioryear;


END BSC_CALENDAR_PUB;

/
