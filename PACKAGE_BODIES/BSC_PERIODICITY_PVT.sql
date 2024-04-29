--------------------------------------------------------
--  DDL for Package Body BSC_PERIODICITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PERIODICITY_PVT" AS
/* $Header: BSCVPITB.pls 120.0 2005/07/21 23:35:41 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCVPCTB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Private package for populating the calendar  tables       |
REM | NOTES                                                                 |
REM | 07-JUN-2005 Krishna  Created.                                         |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_PERIODICITY_PVT';


PROCEDURE Create_Periods
( p_Api_Version    IN          NUMBER
, p_Commit         IN          VARCHAR2 := FND_API.G_FALSE
, p_Period_Record  IN          BSC_PERIODS_PUB.Period_Record
, x_Return_Status  OUT NOCOPY  VARCHAR2
, x_Msg_Count      OUT NOCOPY  NUMBER
, x_Msg_Data       OUT NOCOPY  VARCHAR2
)IS
l_Is_Daily_Periodicity  BOOLEAN := FALSE;
l_Fiscal_Year           NUMBER;
--l_period_Varray_Record  BSC_PERIODS_PUB.Start_End_Period_Varray;
l_Start_Date            DATE;
l_End_Date              DATE;
l_Start_Period          NUMBER;
l_End_Period            NUMBER;
x_Start_Period          NUMBER;
x_End_Period            NUMBER;
l_No_Base_Periods       NUMBER;
BEGIN
  SAVEPOINT CreatePeriodsPVTSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  IF(p_Period_Record.Base_Periodicity_Id IS NOT NULL) THEN
    l_Is_Daily_Periodicity := BSC_PERIODS_UTILITY_PKG.Is_Base_Periodicity_Daily(p_Period_Record.Base_Periodicity_Id);
  END IF;

  l_Fiscal_Year     := BSC_PERIODS_UTILITY_PKG.Get_FiscalYear_By_Calendar(p_Period_Record.Calendar_Id);

  IF(p_Period_Record.Periods IS NOT NULL) THEN

    FOR i IN 1..p_Period_Record.period_Varry.COUNT LOOP
      IF(l_Is_Daily_Periodicity) THEN
        --dbms_output.put_line('INSIDE DAILY PERIODICITY');
        l_Start_Date := TO_DATE(p_Period_Record.period_Varry(i).Start_Period,'MM/DD/YY');
        l_End_Date   := TO_DATE(p_Period_Record.period_Varry(i).End_Period,'MM/DD/YY');
        --dbms_output.put_line(' l_Start_Date:-' || l_Start_Date);
        --dbms_output.put_line(' l_End_Date:-' || l_End_Date);
        l_Start_Period := 0;
        l_End_Period   := 0;
        IF(i = 1) THEN
          l_Start_Period := 1;
        END IF;
        IF(i = p_Period_Record.period_Varry.COUNT) THEN
          l_End_Period := 365;
        END IF;
      ELSE
        --dbms_output.put_line('INSIDE OUT OF DAILY PERIODICITY');
        l_Start_Period := p_Period_Record.period_Varry(i).Start_Period;
        l_End_Period   := p_Period_Record.period_Varry(i).End_Period;
        l_Start_Date := NULL;
        l_End_Date   := NULL;
      END IF;

      INSERT INTO bsc_sys_periods
      ( periodicity_id
      , year
      , period_id
      , start_date
      , end_date
      , start_period
      , end_period
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
      , last_update_login
      )VALUES
      (
        p_Period_Record.Periodicity_Id
      , l_Fiscal_Year
      , i
      , l_Start_Date
      , l_End_Date
      , l_Start_Period
      , l_End_Period
      , NVL(p_Period_Record.Created_By,FND_GLOBAL.USER_ID)
      , NVL(p_Period_Record.Creation_Date,SYSDATE)
      , NVL(p_Period_Record.Last_Updated_By,FND_GLOBAL.USER_ID)
      , NVL(p_Period_Record.Last_Update_Date,SYSDATE)
      , NVL(p_Period_Record.Last_Update_Login,FND_GLOBAL.LOGIN_ID)
      );

    END LOOP;
  END IF;

  IF ((p_Commit IS NOT NULL) AND (p_Commit = FND_API.G_TRUE)) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO CreatePeriodsPVTSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITY_PVT.Create_Periods ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODICITY_PVT.Create_Periods ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO CreatePeriodsPVTSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITY_PVT.Create_Periods ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODICITY_PVT.Create_Periods ';
    END IF;
END Create_Periods;

/****************************************************************************************/

PROCEDURE Update_Periods
( p_Api_Version    IN          NUMBER
, p_Commit         IN          VARCHAR2 := FND_API.G_FALSE
, p_Period_Record  IN          BSC_PERIODS_PUB.Period_Record
, x_Return_Status  OUT NOCOPY  VARCHAR2
, x_Msg_Count      OUT NOCOPY  NUMBER
, x_Msg_Data       OUT NOCOPY  VARCHAR2
)IS
l_System_Stage   bsc_sys_init.property_value%TYPE;
BEGIN
  SAVEPOINT UpdatePeriodsPVTSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

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

  BSC_PERIODICITY_PVT.Create_Periods
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
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO UpdatePeriodsPVTSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITY_PVT.Update_Periods ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODICITY_PVT.Update_Periods ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO UpdatePeriodsPVTSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITY_PVT.Update_Periods ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODICITY_PVT.Update_Periods ';
    END IF;
END Update_Periods;

/**********************************************************************************/

PROCEDURE Delete_Periods
( p_Api_Version    IN          NUMBER
, p_Commit         IN          VARCHAR2 := FND_API.G_FALSE
, p_Period_Record  IN          BSC_PERIODS_PUB.Period_Record
, x_Return_Status  OUT NOCOPY  VARCHAR2
, x_Msg_Count      OUT NOCOPY  NUMBER
, x_Msg_Data       OUT NOCOPY  VARCHAR2
)IS

BEGIN
  SAVEPOINT DeletePeriodsPVTSP;
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  DELETE bsc_sys_periods
  WHERE  periodicity_id = p_Period_Record.Periodicity_Id;

  DELETE bsc_sys_periods_tl
  WHERE  periodicity_id = p_Period_Record.Periodicity_Id;

  IF ((p_Commit IS NOT NULL) AND (p_Commit = FND_API.G_TRUE)) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO DeletePeriodsPVTSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITY_PVT.Delete_Periods ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODICITY_PVT.Delete_Periods ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO DeletePeriodsPVTSP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITY_PVT.Delete_Periods ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_PERIODICITY_PVT.Delete_Periods ';
    END IF;
END Delete_Periods;
/**********************************************************************************/


END BSC_PERIODICITY_PVT;

/
