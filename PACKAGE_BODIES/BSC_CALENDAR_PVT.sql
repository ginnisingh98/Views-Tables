--------------------------------------------------------
--  DDL for Package Body BSC_CALENDAR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_CALENDAR_PVT" AS
/* $Header: BSCVCALB.pls 120.2 2005/11/30 02:47:25 kyadamak noship $ */
/*
REM +==================================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA                |
REM |                         All rights reserved.                                     |
REM +==================================================================================+
REM | FILENAME                                                                         |
REM |     BSCVCALB.pls                                                                 |
REM |                                                                                  |
REM | DESCRIPTION                                                                      |
REM |     Module: Private package for populating the calendar  tables                  |
REM | NOTES                                                                            |
REM | 07-JUN-2005 Krishna  Created.                                                    |
REM | 31-AUG-2004 Aditya Rao fixed Bug#4565308 for START_DAY of fiscal year            |
REM | 29-NOV-2005 kyadamak Added API Update_PeriodNames_In_Calendar for Enh#4711274    |
REM +==================================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_CALENDAR_PVT';

PROCEDURE Create_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS

BEGIN
  SAVEPOINT CreateCalendarSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO bsc_sys_calendars_b
  ( calendar_id
  , edw_flag
  , edw_calendar_id
  , edw_calendar_type_id
  , fiscal_year
  , fiscal_change
  , range_yr_mod
  , current_year
  , start_month
  , start_day
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  , short_name
  )
  VALUES
  ( p_Calendar_Record.Calendar_Id
  , p_Calendar_Record.Edw_Flag
  , p_Calendar_Record.Edw_Calendar_Id
  , p_Calendar_Record.Edw_Calendar_Type_Id
  , p_Calendar_Record.Fiscal_Year
  , p_Calendar_Record.Fiscal_Change
  , p_Calendar_Record.Range_Yr_Mod
  , p_Calendar_Record.Current_Year
  , p_Calendar_Record.Start_Month
  , p_Calendar_Record.Start_Day
  , NVL(p_Calendar_Record.Created_By,FND_GLOBAL.USER_ID)
  , NVL(p_Calendar_Record.Creation_Date,SYSDATE)
  , NVL(p_Calendar_Record.Last_Updated_By,FND_GLOBAL.USER_ID)
  , NVL(p_Calendar_Record.Last_Update_Date,SYSDATE)
  , NVL(p_Calendar_Record.Last_Update_Login,FND_GLOBAL.LOGIN_ID)
  , p_Calendar_Record.Dim_Short_Name
  );

  INSERT INTO bsc_sys_calendars_tl
  ( calendar_id
  , language
  , source_lang
  , name
  , help
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  )
  SELECT
    p_Calendar_Record.Calendar_Id
  , L.LANGUAGE_CODE
  , USERENV('LANG')
  , p_Calendar_Record.name
  , p_Calendar_Record.Help
  , NVL(p_Calendar_Record.Created_By,FND_GLOBAL.USER_ID)
  , NVL(p_Calendar_Record.Last_Update_Date,SYSDATE)
  , NVL(p_Calendar_Record.Last_Updated_By,FND_GLOBAL.USER_ID)
  , NVL(p_Calendar_Record.Last_Update_Date,SYSDATE)
  , NVL(p_Calendar_Record.Last_Update_Login,FND_GLOBAL.LOGIN_ID)
  FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG IN ('I', 'B')
  AND NOT EXISTS
  (
    SELECT NULL
    FROM   bsc_sys_calendars_tl T
    WHERE  T.calendar_id = p_Calendar_Record.Calendar_Id
    AND    T.LANGUAGE    = L.LANGUAGE_CODE
  );

  IF ((p_Commit IS NOT NULL) AND (p_Commit = FND_API.G_TRUE)) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO CreateCalendarSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PVT.Create_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PVT.Create_Calendar ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO CreateCalendarSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PVT.Create_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PVT.Create_Calendar ';
    END IF;
END Create_Calendar;

/****************************************************************************************/

PROCEDURE Update_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS
l_System_Stage   bsc_sys_init.property_value%TYPE;
BEGIN
  SAVEPOINT UpdateCalendarSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  -- added for Bug#4565308
  UPDATE bsc_sys_calendars_b
  SET  fiscal_year        = p_Calendar_Record.Fiscal_Year
     , current_year       = p_Calendar_Record.Current_Year
     , start_month        = p_Calendar_Record.Start_Month
     , start_day          = p_Calendar_Record.Start_Day
     , last_updated_by    = p_Calendar_Record.Last_Updated_By
     , last_update_date   = p_Calendar_Record.Last_Update_Date
     , last_update_login  = p_Calendar_Record.Last_Update_Login
  WHERE calendar_id       = p_Calendar_Record.Calendar_Id;

  UPDATE bsc_sys_calendars_tl
  SET  name               = p_Calendar_Record.Name
     , help               = p_Calendar_Record.Help
     , last_updated_by    = p_Calendar_Record.Last_Updated_By
     , last_update_date   = p_Calendar_Record.Last_Update_Date
     , last_update_login  = p_Calendar_Record.Last_Update_Login
     , source_lang        = USERENV('LANG')
  WHERE calendar_id       = p_Calendar_Record.Calendar_Id
  AND USERENV('LANG')     IN (LANGUAGE, SOURCE_LANG);

  UPDATE bsc_kpi_periodicities
  SET    current_period = p_Calendar_Record.Fiscal_Year
  WHERE  periodicity_id IN
  ( SELECT periodicity_id
    FROM   bsc_sys_periodicities
    WHERE  calendar_id = p_Calendar_Record.Calendar_Id
    AND    periodicity_type = 1
  );

  IF ((p_Commit IS NOT NULL) AND (p_Commit = FND_API.G_TRUE)) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO UpdateCalendarSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PVT.Update_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PVT.Update_Calendar ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO UpdateCalendarSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PVT.Update_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PVT.Update_Calendar ';
    END IF;
END Update_Calendar;

PROCEDURE Delete_Calendar
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Record        IN          BSC_CALENDAR_PUB.Calendar_Type_Record
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS

BEGIN
  SAVEPOINT DeleteCalendarSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  DELETE bsc_db_week_maps
  WHERE  calendar_id = p_Calendar_Record.Calendar_Id;

  DELETE bsc_db_calendar
  WHERE  calendar_id = p_Calendar_Record.Calendar_Id;

  DELETE bsc_sys_periods_tl
  WHERE  periodicity_id IN
  (
    SELECT periodicity_id
    FROM   bsc_sys_periodicities
    WHERE  calendar_id = p_Calendar_Record.Calendar_Id
  );

  DELETE bsc_sys_periods
  WHERE  periodicity_id IN
  (
    SELECT periodicity_id
    FROM   bsc_sys_periodicities
    WHERE  calendar_id = p_Calendar_Record.Calendar_Id
  );

  DELETE bsc_sys_periodicities_tl
  WHERE  periodicity_id IN
  (
    SELECT periodicity_id
    FROM   bsc_sys_periodicities
    WHERE  calendar_id = p_Calendar_Record.Calendar_Id
  );

  DELETE bsc_sys_periodicities
  WHERE  calendar_id = p_Calendar_Record.Calendar_Id;

  DELETE bsc_sys_calendars_tl
  WHERE  calendar_id = p_Calendar_Record.Calendar_Id;
  --dbms_output.put_line(' deleting from bsc_sys_calendars_b with calendar id as :- ' || p_Calendar_Record.Calendar_Id);

  DELETE bsc_sys_calendars_b
  WHERE  calendar_id = p_Calendar_Record.Calendar_Id;

  IF ((p_Commit IS NOT NULL) AND (p_Commit = FND_API.G_TRUE)) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO DeleteCalendarSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PVT.Delete_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PVT.Delete_Calendar ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO DeleteCalendarSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PVT.Delete_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PVT.Delete_Calendar ';
    END IF;
END Delete_Calendar;

PROCEDURE Update_Fiscal_Change
( p_Api_Version            IN          NUMBER
, p_Commit                 IN          VARCHAR2
, p_Calendar_Id            IN          NUMBER
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
)IS
BEGIN
  SAVEPOINT DeleteCalendarSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  UPDATE bsc_sys_calendars_b
  SET    fiscal_change = 1
  WHERE  calendar_id = p_Calendar_Id;

  IF ((p_Commit IS NOT NULL) AND (p_Commit = FND_API.G_TRUE)) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO DeleteCalendarSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PVT.Update_Fiscal_Change ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PVT.Update_Fiscal_Change ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO DeleteCalendarSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PVT.Update_Fiscal_Change ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PVT.Update_Fiscal_Change ';
    END IF;
END Update_Fiscal_Change;

PROCEDURE Update_PeriodNames_In_Calendar
( p_Calendar_Id            IN  NUMBER
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
) IS

CURSOR C_Period_Names IS
SELECT BSCPER.short_name
      ,BSCPER.name
      ,BSCDIM.dim_level_id
      ,BISDIM.level_id
FROM   bsc_sys_periodicities_vl BSCPER,
       bsc_sys_dim_levels_vl    BSCDIM,
       bis_levels_vl            BISDIM
WHERE  BSCPER.short_name = BSCDIM.short_name
AND    BSCPER.short_name = BISDIM.short_name
AND    BSCDIM.short_name = BISDIM.short_name
AND    BSCPER.calendar_id = p_Calendar_Id;


l_Dimobj_New_Name     BSC_SYS_DIM_LEVELS_TL.NAME%TYPE;

BEGIN
  FOR CD IN C_Period_Names LOOP
    l_Dimobj_New_Name := BSC_PERIODS_UTILITY_PKG.get_Dimobj_Name_From_period
                         ( p_Calendar_Id      => p_Calendar_Id
                         , p_Periodicity_Name => CD.name
                         );

    UPDATE bsc_sys_dim_levels_tl
    SET    name         = l_Dimobj_New_Name
          ,SOURCE_LANG  = userenv('LANG')
    WHERE  dim_level_id = CD.dim_level_id
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

    UPDATE bis_levels_tl
    SET    name         = l_Dimobj_New_Name
          ,SOURCE_LANG  = userenv('LANG')
    WHERE  level_id     = CD.level_id
    AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);

  END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PVT.Update_PeriodNames_In_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PVT.Update_PeriodNames_In_Calendar ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PVT.Update_PeriodNames_In_Calendar ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PVT.Update_PeriodNames_In_Calendar ';
    END IF;

END Update_PeriodNames_In_Calendar;


END BSC_CALENDAR_PVT;

/
