--------------------------------------------------------
--  DDL for Package Body BSC_PERIODS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PERIODS_PUB" AS
/* $Header: BSCPPITB.pls 120.3.12000000.2 2007/01/31 09:41:25 ashankar ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCPPCTB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Public package for populating the calendar  tables        |
REM | NOTES                                                                 |
REM | 07-JUN-2005 Krishna  Created.                                         |
REM | 08-AUG-2005 Aditya Rao modified view creation for Periodicities with  |
REM |             performance enhancement and creation of view for yearly   |
REM |             periodicity (Bug#4533089)                                 |
REM | 12-AUG-2005 Aditya Rao added API Get_Period_List                      |
REM | 07-FEB-2006 ashankar Fix for the bug4695330                           |
REM | 17-JAN-2007 ashankar Fix for the bug5654559                           |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_PERIODS_PUB';


FUNCTION Parse_Periods
( p_Periods       VARCHAR2
, x_Start_Period  OUT NOCOPY VARCHAR2
, x_End_Period    OUT NOCOPY VARCHAR2
)RETURN BSC_PERIODS_PUB.Start_End_Period_Varray IS
l_Start_Pos     NUMBER := 1;
l_End_Pos       NUMBER;
l_Length        NUMBER;
l_Is_String_End BOOLEAN  := TRUE;
l_Period_Start  VARCHAR2(32000);
l_Period_End    VARCHAR2(32000);
l_Index         NUMBER := 1 ;

period_Varray_Record BSC_PERIODS_PUB.Start_End_Period_Varray := BSC_PERIODS_PUB.Start_End_Period_Varray();
start_End_Record     BSC_PERIODS_PUB.Start_End_Period_Record ;
BEGIN
  l_Length := LENGTH(TRIM(p_Periods));
  IF(p_Periods IS NOT NULL) THEN
    LOOP
      l_End_Pos := INSTR(p_Periods,',',l_Start_Pos);
      IF(l_End_Pos = 0) THEN
        l_End_Pos := l_Length + 1;
        l_Is_String_End := FALSE;
      END IF;

      l_Period_Start  := SUBSTR(p_Periods,l_Start_Pos,l_End_Pos-l_Start_Pos);
      --dbms_output.put_line(' l_Period_Start :-' ||l_Period_Start );
      l_Start_Pos := l_End_Pos + 1 ;
      l_End_Pos := INSTR(p_Periods,',',l_Start_Pos);
      --dbms_output.put_line(' l_End_Pos:-' || l_End_Pos);
      IF(x_Start_Period  IS NULL) THEN
        x_Start_Period := l_Period_Start;
      --dbms_output.put_line(' x_Start_Period:-' || x_Start_Period);
      END IF;

      IF(l_End_Pos = 0) THEN
        l_End_Pos := l_Length + 1;
        --dbms_output.put_line(' l_End_Pos:-' || l_End_Pos);
        l_Is_String_End := FALSE;
      END IF;
      --dbms_output.put_line(' l_Period_End:-' ||l_Period_End );
      l_Period_End  := SUBSTR(p_Periods,l_Start_Pos,l_End_Pos-l_Start_Pos);
      --dbms_output.put_line(' l_Period_End:-' || l_Period_End);
      l_Start_Pos  := l_End_Pos + 1;
      x_End_Period := l_Period_End;
      start_End_Record.Start_Period := l_Period_Start;
      start_End_Record.End_Period   := l_Period_End;
      period_Varray_Record.extend(1);
      period_Varray_Record(l_Index) := start_End_Record;
      IF(NOT l_Is_String_End) THEN
        EXIT;
      END IF;
      l_Index := l_Index + 1;
    END LOOP;
  END IF;

  RETURN period_Varray_Record;
END Parse_Periods;

/****************************************************************************************/
FUNCTION Get_Valid_Period_View_Name
(
 p_short_name IN VARCHAR2
)
RETURN VARCHAR2 IS
l_found       BOOLEAN;
l_alias       VARCHAR2(30);
l_count       NUMBER;
l_table_name  BIS_LEVELS.LEVEL_VALUES_VIEW_NAME%TYPE;
BEGIN

  l_found      := TRUE;
  l_alias      := NULL;
  l_table_name := 'BSC_P_' || SUBSTR(p_short_name , 1, 22) || '_V';
  WHILE (l_found) LOOP
    SELECT COUNT(1)
    INTO   l_count
    FROM   bis_levels
    WHERE  level_values_view_name = l_table_name;
    IF (l_count = 0) THEN
      l_found := FALSE;
    END IF;
    IF(l_found) THEN
      l_alias      := bsc_utility.get_Next_Alias(l_alias);
      l_table_name := 'BSC_P_' ||SUBSTR(p_short_name, 1, 18)||l_alias|| '_V';
    END IF;
  END LOOP;

  RETURN l_table_name;

END Get_Valid_Period_View_Name;
/****************************************************************************************/


FUNCTION Get_Periods
( p_Periodicity_Id      IN NUMBER
, p_Base_Periodicity_Id IN NUMBER
)RETURN VARCHAR2 IS
l_Periods VARCHAR2(32000);
l_Is_Daily_Periodicity BOOLEAN;
CURSOR C_Base_Daily_Periods IS
  SELECT start_date,end_date
  FROM   bsc_sys_periods
  WHERE  periodicity_id = p_Periodicity_Id;
CURSOR C_Periods IS
  SELECT start_period,end_period
  FROM   bsc_sys_periods
  WHERE  periodicity_id = p_Periodicity_Id;
BEGIN
  IF(p_Base_Periodicity_Id IS NOT NULL) THEN
    l_Is_Daily_Periodicity := BSC_PERIODS_UTILITY_PKG.Is_Base_Periodicity_Daily(p_Base_Periodicity_Id);
  END IF;
  IF(l_Is_Daily_Periodicity) THEN
    FOR CD_Base IN C_Base_Daily_Periods LOOP
      IF(l_Periods IS NULL) THEN
        l_Periods := CD_Base.start_date||','||CD_Base.end_date;
      ELSE
        l_Periods := l_Periods ||','||CD_Base.start_date||','||CD_Base.end_date;
      END IF;
    END LOOP;
  ELSE
    FOR CD_Base IN C_Periods LOOP
      IF(l_Periods IS NULL) THEN
        l_Periods := CD_Base.start_period||','||CD_Base.end_period;
      ELSE
        l_Periods := l_Periods ||','||CD_Base.start_period||','||CD_Base.end_period;
      END IF;
    END LOOP;
  END IF;

 RETURN l_Periods;

END Get_Periods;

/******************************************************************************/

FUNCTION Is_Period_Modified
(p_Period_Record  IN          BSC_PERIODS_PUB.Period_Record
)RETURN VARCHAR2 IS
l_periods            VARCHAR2(32000);
l_Is_Period_Modified VARCHAR2(1);
l_In_Trimmed_String  VARCHAR2(32000);
l_In_Dbase_String    VARCHAR2(32000);
BEGIN
  l_Is_Period_Modified := FND_API.G_FALSE;

  l_periods :=  Get_Period_List(p_Period_Record.Periodicity_Id);

  l_In_Trimmed_String := REPLACE(p_Period_Record.Periods,' ','');
  l_In_Dbase_String   := REPLACE(l_periods,' ','');
  IF(l_In_Trimmed_String <> l_In_Dbase_String) THEN
    l_Is_Period_Modified := FND_API.G_TRUE;
  END IF;

  RETURN l_Is_Period_Modified;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_Period_Modified;

/******************************************************************************/

PROCEDURE Create_Periods
( p_Api_Version             IN          NUMBER
, p_Commit                  IN          VARCHAR2
, p_Period_Record           IN          BSC_PERIODS_PUB.Period_Record
, p_disable_period_val_flag IN          VARCHAR2
, x_Return_Status           OUT NOCOPY  VARCHAR2
, x_Msg_Count               OUT NOCOPY  NUMBER
, x_Msg_Data                OUT NOCOPY  VARCHAR2
)IS
l_Period_Record         BSC_PERIODS_PUB.Period_Record;
l_period_Varray_Record  BSC_PERIODS_PUB.Start_End_Period_Varray;
x_Start_Period          VARCHAR2(32000);
x_End_Period            VARCHAR2(32000);

BEGIN
  SAVEPOINT CreatePeriodsPubSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;
  --dbms_output.put_line('before assigning ');
  l_Period_Record := p_Period_Record;
  l_period_Varray_Record   := Parse_Periods
                              ( p_Periods       => p_Period_Record.Periods
                              , x_Start_Period  => x_Start_Period
                              , x_End_Period    => x_End_Period
                              );
  --dbms_output.put_line('before Validate_Periods_Action');
  l_Period_Record.period_Varry := l_period_Varray_Record;

  IF(p_disable_period_val_flag = FND_API.G_FALSE)THEN

      BSC_PERIODS_PUB.Validate_Periods_Action
      ( p_Api_Version      => p_Api_Version
      , p_Commit           => p_Commit
      , p_Period_Record    => l_Period_Record
      , p_Action           => BSC_PERIODS_UTILITY_PKG.C_CREATE
      , x_Start_Period     => x_Start_Period
      , x_End_Period       => x_End_Period
      , x_Return_Status    => x_Return_Status
      , x_Msg_Count        => x_Msg_Count
      , x_Msg_Data         => x_Msg_Data
      );
      IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

  END IF;
 --dbms_output.put_line('before Create_Periods');
  BSC_PERIODICITY_PVT.Create_Periods
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Period_Record    => l_Period_Record
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
    ROLLBACK TO CreatePeriodsPubSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CreatePeriodsPubSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO CreatePeriodsPubSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODS_PUB.Create_Periods ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODS_PUB.Create_Periods ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO CreatePeriodsPubSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODS_PUB.Create_Periods ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODS_PUB.Create_Periods ';
    END IF;
END Create_Periods;

/*****************************************************************************************/

PROCEDURE Update_Periods
( p_Api_Version             IN          NUMBER
, p_Commit                  IN          VARCHAR2
, p_Period_Record           IN          BSC_PERIODS_PUB.Period_Record
, x_Structual_Change        OUT NOCOPY  BOOLEAN
, p_disable_period_val_flag IN          VARCHAR2
, x_Return_Status           OUT NOCOPY  VARCHAR2
, x_Msg_Count               OUT NOCOPY  NUMBER
, x_Msg_Data                OUT NOCOPY  VARCHAR2
)IS
l_Period_Record         BSC_PERIODS_PUB.Period_Record;
l_period_Varray_Record  BSC_PERIODS_PUB.Start_End_Period_Varray;
x_End_Period            VARCHAR2(32000);
x_Start_Period          VARCHAR2(32000);

BEGIN
  SAVEPOINT UpdatePeriodsPubSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  l_Period_Record := p_Period_Record;
  l_period_Varray_Record   := Parse_Periods
                              ( p_Periods       => p_Period_Record.Periods
                              , x_Start_Period  => x_Start_Period
                              , x_End_Period    => x_End_Period
                              );

  l_Period_Record.period_Varry := l_period_Varray_Record;

  IF(p_disable_period_val_flag = FND_API.G_FALSE)THEN

      BSC_PERIODS_PUB.Validate_Periods_Action
      ( p_Api_Version      => p_Api_Version
      , p_Commit           => p_Commit
      , p_Period_Record    => l_Period_Record
      , p_Action           => BSC_PERIODS_UTILITY_PKG.C_UPDATE
      , x_Start_Period     => x_Start_Period
      , x_End_Period       => x_End_Period
      , x_Return_Status    => x_Return_Status
      , x_Msg_Count        => x_Msg_Count
      , x_Msg_Data         => x_Msg_Data
      );
      IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
 END IF;

 -- adrao modified to p_Period_Record
  BSC_PERIODICITY_PVT.Update_Periods
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Period_Record    => l_Period_Record
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
    ROLLBACK TO UpdatePeriodsPubSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UpdatePeriodsPubSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO UpdatePeriodsPubSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODS_PUB.Update_Periods ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODS_PUB.Update_Periods ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO UpdatePeriodsPubSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODS_PUB.Update_Periods ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODS_PUB.Update_Calendar ';
    END IF;
END Update_Periods;



/****************************************************************************************/
PROCEDURE Delete_Periods
( p_Api_Version    IN          NUMBER
, p_Commit         IN          VARCHAR2 := FND_API.G_FALSE
, p_Period_Record  IN          BSC_PERIODS_PUB.Period_Record
, x_Return_Status  OUT NOCOPY  VARCHAR2
, x_Msg_Count      OUT NOCOPY  NUMBER
, x_Msg_Data       OUT NOCOPY  VARCHAR2
)IS
BEGIN
  SAVEPOINT DeletePeriodsPubSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  BSC_PERIODS_PUB.Validate_Periods_Action
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Period_Record    => p_Period_Record
  , p_Action           => BSC_PERIODS_UTILITY_PKG.C_DELETE
  , x_Start_Period     => NULL
  , x_End_Period       => NULL
  , x_Return_Status    => x_Return_Status
  , x_Msg_Count        => x_Msg_Count
  , x_Msg_Data         => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_PERIODICITY_PVT.Delete_Periods
  ( p_Api_Version      => p_Api_Version
  , p_Commit           => p_Commit
  , p_Period_Record    => p_Period_Record
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
    ROLLBACK TO DeletePeriodsPubSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DeletePeriodsPubSP;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO DeletePeriodsPubSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODS_PUB.Delete_Periods ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODS_PUB.Delete_Periods ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO DeletePeriodsPubSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODS_PUB.Delete_Periods ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODS_PUB.Delete_Periods ';
    END IF;
END Delete_Periods;

/***********************************************************************************/

PROCEDURE Validate_Periods_Action
( p_Api_Version    IN          NUMBER
, p_Commit         IN          VARCHAR2 := FND_API.G_FALSE
, p_Period_Record  IN          BSC_PERIODS_PUB.Period_Record
, p_Action         IN          VARCHAR2
, x_Start_Period   IN          VARCHAR2
, x_End_Period     IN          VARCHAR2
, x_Return_Status  OUT NOCOPY  VARCHAR2
, x_Msg_Count      OUT NOCOPY  NUMBER
, x_Msg_Data       OUT NOCOPY  VARCHAR2
)IS
l_No_Base_Periods       NUMBER;
l_Is_Daily_Periodicity  BOOLEAN;
BEGIN

  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;
  IF(p_Period_Record.Base_Periodicity_Id IS NOT NULL) THEN
    l_No_Base_Periods := BSC_PERIODS_UTILITY_PKG.Get_Periods_In_Base_Period(p_Period_Record.Base_Periodicity_Id);
    l_Is_Daily_Periodicity := BSC_PERIODS_UTILITY_PKG.Is_Base_Periodicity_Daily(p_Period_Record.Base_Periodicity_Id);
  END IF;


  IF(p_Action <> BSC_PERIODS_UTILITY_PKG.C_DELETE ) THEN
    IF((NOT l_Is_Daily_Periodicity) AND (p_Period_Record.Base_Periodicity_Id IS NOT NULL)) THEN
      IF(x_Start_Period <> 1 OR x_End_Period <> l_No_Base_Periods) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_WRONG_PERIODS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
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
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODS_PUB.Validate_Periods_Action ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODS_PUB.Validate_Periods_Action ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODS_PUB.Validate_Periods_Action ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODS_PUB.Validate_Periods_Action ';
    END IF;
END Validate_Periods_Action;
/****************************************************************************************/

PROCEDURE Create_Periodicity_View
( p_Periodicity_Id         IN  NUMBER
, p_Short_Name             IN  VARCHAR2
, p_Calendar_Id            IN  NUMBER
, x_Periodicity_View_Name  OUT NOCOPY VARCHAR2
, x_Return_Status          OUT NOCOPY  VARCHAR2
, x_Msg_Count              OUT NOCOPY  NUMBER
, x_Msg_Data               OUT NOCOPY  VARCHAR2
) IS
BEGIN
      BSC_PERIODS_PUB.Create_Periodicity_View
      (
           p_Periodicity_Id        => p_Periodicity_Id
        ,  p_Short_Name            => p_Short_Name
        ,  p_Calendar_Id           => p_Calendar_Id
        ,  p_periodicity_Type      => NULL
        ,  x_Periodicity_View_Name => x_Periodicity_View_Name
        ,  x_Return_Status         => x_Return_Status
        ,  x_Msg_Count             => x_Msg_Count
        ,  x_Msg_Data              => x_Msg_Data
     );
 END Create_Periodicity_View;

PROCEDURE Create_Periodicity_View
(
     p_Periodicity_Id        IN         NUMBER
  ,  p_Short_Name            IN         VARCHAR2
  ,  p_Calendar_Id           IN         NUMBER
  ,  p_periodicity_Type      IN         BSC_SYS_PERIODICITIES.periodicity_type%TYPE
  ,  x_Periodicity_View_Name OUT NOCOPY VARCHAR2
  ,  x_Return_Status         OUT NOCOPY VARCHAR2
  ,  x_Msg_Count             OUT NOCOPY NUMBER
  ,  x_Msg_Data              OUT NOCOPY VARCHAR2
)IS
l_Sql_Stmt      VARCHAR2(32000);
l_View_Name     BIS_LEVELS.LEVEL_VALUES_VIEW_NAME%TYPE;
l_Period_DB_Col BSC_SYS_PERIODICITIES.DB_COLUMN_NAME%TYPE;

BEGIN
  --dbms_output.put_line('START :Create_Periodicity_View :- ' ||DBMS_UTILITY.GET_TIME);
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;
  x_Periodicity_View_Name := Get_Valid_Period_View_Name(p_Short_Name);

  --dbms_output.put_line('BEFORE PREPARING SQL TEXT ');

  l_Period_DB_Col := BSC_PERIODS_UTILITY_PKG.Get_Periodicity_Db_Col(p_Periodicity_Id);

   /*l_Sql_Stmt := ' CREATE OR REPLACE VIEW ' || x_Periodicity_View_Name||'(ID,VALUE,START_DATE,END_DATE) AS '||
                ' SELECT  BP.PERIOD_ID,  BP.NAME, ' ||
                ' BSC_PERIODS_UTILITY_PKG.Get_Start_Period_Date(BC.CALENDAR_ID, BP.PERIODICITY_ID, BP.PERIOD_ID, BP.YEAR),  ' ||
                ' BSC_PERIODS_UTILITY_PKG.Get_End_Period_Date(BC.CALENDAR_ID, BP.PERIODICITY_ID, BP.PERIOD_ID, BP.YEAR) ' ||
                ' FROM BSC_SYS_PERIODS_VL BP,  BSC_SYS_CALENDARS_B BC ' ||
                ' WHERE  BP.PERIODICITY_ID = ' || p_Periodicity_Id ||
                ' AND BC.CALENDAR_ID = ' || p_Calendar_Id ||
                ' ORDER BY BP.PERIOD_ID, BP.MONTH '; */

 -- The yearly periodicity needs a different query to calculate the ID, VALUE, START_DATE and END_DATE

 --We are not supposed to create view for Month day and Month week as they are no longer supported.So we will skip
 --view creation part for those periodicities. but we want the view name. This is required for the bug#5654559

 IF((p_periodicity_Type IS NULL AND l_Period_DB_Col IS NOT NULL) OR (p_periodicity_Type IS NOT NULL AND (
    p_periodicity_Type NOT IN
    (BSC_PERIODS_PUB.C_MONTH_DAY,BSC_PERIODS_PUB.C_MONTH_WEEK)))) THEN
     IF (l_Period_DB_Col = BSC_PERIODS_UTILITY_PKG.C_YEAR_COLUMN) THEN
         l_Sql_Stmt :=  ' CREATE OR REPLACE VIEW ' || x_Periodicity_View_Name||'(ID,VALUE,START_DATE,END_DATE) AS '||
                        ' SELECT  C.YEAR,C.YEAR, ' ||
                        ' MIN(TO_DATE(C.CALENDAR_YEAR||''-''||C.CALENDAR_MONTH||''-''||C.CALENDAR_DAY, ''YYYY-MM-DD'')) START_DATE, ' ||
                        ' MAX(TO_DATE(C.CALENDAR_YEAR||''-''||C.CALENDAR_MONTH||''-''||C.CALENDAR_DAY, ''YYYY-MM-DD'')) END_DATE ' ||
                        ' FROM  BSC_DB_CALENDAR C ' ||
                        ' WHERE C.CALENDAR_ID = ' || p_Calendar_Id ||
                        ' GROUP BY C.YEAR ' ||
                        ' ORDER BY C.YEAR ';

      ELSE
         l_Sql_Stmt :=  ' CREATE OR REPLACE VIEW ' || x_Periodicity_View_Name||'(ID,VALUE,START_DATE,END_DATE) AS '||
                        ' SELECT  BP.PERIOD_ID, BP.NAME, ' ||
                        ' MIN(TO_DATE(C.CALENDAR_YEAR||''-''||C.CALENDAR_MONTH||''-''||C.CALENDAR_DAY, ''YYYY-MM-DD'')) START_DATE, ' ||
                        ' MAX(TO_DATE(C.CALENDAR_YEAR||''-''||C.CALENDAR_MONTH||''-''||C.CALENDAR_DAY, ''YYYY-MM-DD'')) END_DATE ' ||
                        ' FROM BSC_SYS_PERIODS_VL BP,  BSC_DB_CALENDAR C ' ||
                        ' WHERE BP.PERIODICITY_ID = ' || p_Periodicity_Id ||
                        ' AND C.CALENDAR_ID = ' || p_Calendar_Id ||
                        ' AND BP.YEAR = C.YEAR ' ||
                        ' AND BP.PERIOD_ID = C.' || l_Period_DB_Col ||
                        ' GROUP BY BP.PERIOD_ID, BP.NAME, BP.YEAR ' ||
                        ' ORDER BY BP.YEAR, BP.PERIOD_ID ';
      END IF;

      BSC_APPS.Do_Ddl_AT(l_Sql_Stmt, ad_ddl.create_view, x_Periodicity_View_Name, 'APPS', 'BSC');
  END IF;
      --dbms_output.put_line('END :Create_Periodicity_View :- ' ||DBMS_UTILITY.GET_TIME);

EXCEPTION
 WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MESSAGE.SET_NAME('BSC','BSC_ERROR_CREATE_PER_VIEW');
       FND_MSG_PUB.ADD;
       FND_MSG_PUB.Count_And_Get
       (  p_encoded   =>  FND_API.G_FALSE
        , p_count     =>  x_msg_count
        , p_data      =>  x_msg_data
       );
       IF (x_msg_data IS NOT NULL) THEN
           x_msg_data      :=  x_msg_data||' -> BSC_PERIODS_PUB.Create_Periodicity_View ';
       ELSE
           x_msg_data      :=  SQLERRM||' at BSC_PERIODS_PUB.Create_Periodicity_View ';
      END IF;
END Create_Periodicity_View;
/*************************************************************************************/
PROCEDURE Drop_Periodicity_View
( p_Periodicity_View  IN  VARCHAR2
, x_Return_Status     OUT NOCOPY  VARCHAR2
, x_Msg_Count         OUT NOCOPY  NUMBER
, x_Msg_Data          OUT NOCOPY  VARCHAR2
)IS
l_Sql_Stmt    VARCHAR2(32000);
BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  l_Sql_Stmt := 'DROP VIEW ' || p_Periodicity_View;

  BSC_APPS.Do_Ddl_AT(l_Sql_Stmt, ad_ddl.drop_view, p_Periodicity_View, 'APPS', 'BSC');


EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_ERROR_DELETE_PER_VIEW');
    FND_MSG_PUB.ADD;
    --dbms_output.put_line('WHEN THEN ERROR IS  :- '||SUBSTR(SQLERRM,1,200) );
END Drop_Periodicity_View;
/*************************************************************************************/


/*************************************************************************************/
FUNCTION Get_Period_List (p_Periodicity_Id IN NUMBER)
RETURN VARCHAR2 IS
  CURSOR C_Non_Daily_Periods_List IS
    SELECT DISTINCT P.START_PERIOD, P.END_PERIOD, P.PERIOD_ID
    FROM   BSC_SYS_PERIODS P
    WHERE  P.PERIODICITY_ID = p_Periodicity_Id
    ORDER BY P.PERIOD_ID;

  CURSOR c_Daily_Periods_List IS
    SELECT DISTINCT P.START_DATE, P.END_DATE, P.PERIOD_ID
    FROM   BSC_SYS_PERIODS P
    WHERE  P.PERIODICITY_ID = p_Periodicity_Id
    ORDER BY P.PERIOD_ID;

  CURSOR c_Source_Type IS
    SELECT P.SOURCE FROM BSC_SYS_PERIODICITIES P
    WHERE  P.PERIODICITY_ID = p_Periodicity_Id;

  l_Comma_List VARCHAR2(12228);
  l_Source     BSC_SYS_PERIODICITIES.SOURCE%TYPE;
BEGIN

  FOR Cst IN c_Source_Type LOOP
    l_Source := Cst.SOURCE;
  END LOOP;

 IF(BSC_PERIODS_UTILITY_PKG.Is_Base_Periodicity_Daily(TO_NUMBER(l_Source))) THEN
    FOR Cdpl IN c_Daily_Periods_List LOOP
      IF (l_Comma_List IS NULL) THEN
        l_Comma_List := TO_CHAR(Cdpl.START_DATE, 'MM/DD/YY') ||',' ||TO_CHAR(Cdpl.END_DATE, 'MM/DD/YY');
      ELSE
        l_Comma_List := l_Comma_List || ',' ||
                        TO_CHAR(Cdpl.START_DATE, 'MM/DD/YY') ||',' ||TO_CHAR(Cdpl.END_DATE, 'MM/DD/YY');
      END IF;
    END LOOP;
 ELSE
    FOR Cndpl IN C_Non_Daily_Periods_List LOOP
      IF(l_Comma_List IS NULL) THEN
        l_Comma_List := Cndpl.START_PERIOD||','||Cndpl.END_PERIOD;
      ELSE
        l_Comma_List := l_Comma_List||','||Cndpl.START_PERIOD||','||Cndpl.END_PERIOD;
      END IF;
    END LOOP;
 END IF;

 RETURN l_Comma_List;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END Get_Period_List;
/*************************************************************************************/



END BSC_PERIODS_PUB;

/
