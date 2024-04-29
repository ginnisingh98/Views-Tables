--------------------------------------------------------
--  DDL for Package Body BSC_CALENDAR_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_CALENDAR_WRAPPER" AS
/* $Header: BSCWCALB.pls 120.1 2005/11/07 03:37:14 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCWCALB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: This is Wrapper Packages which takes the Values from UI   |
REM |             and populates calendar record with these values         |
REM | NOTES                                                                 |
REM | 07-JUN-2005 Krishna Created.                                          |
REM | 29-JUN-2005 Aditya Rao added parameter p_Base_Per_Ids                 |
REM | 07-JUL-2005 Aditya Rao added Locking APIs                             |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_CALENDAR_WRAPPER';

PROCEDURE Create_Calendar_UI
( p_Api_Version           IN          NUMBER
, p_Commit                IN          VARCHAR2
, p_Calendar_Id           IN          NUMBER
, p_Edw_Flag              IN          NUMBER
, p_Edw_Calendar_Id       IN          NUMBER
, p_Edw_Calendar_Type_Id  IN          NUMBER
, p_Fiscal_Year           IN          NUMBER
, p_Fiscal_Change         IN          NUMBER
, p_Range_Yr_Mod          IN          NUMBER
, p_Current_Year          IN          NUMBER
, p_Start_Month           IN          NUMBER
, p_Start_Day             IN          NUMBER
, p_Name                  IN          VARCHAR2
, p_Help                  IN          VARCHAR2
, p_Dim_Short_Name        IN          VARCHAR2
, p_Application_Id        IN          NUMBER
, p_Base_Per_Ids          IN          VARCHAR2
, p_Created_By            IN          NUMBER
, p_Creation_Date         IN          DATE
, p_Last_Updated_By       IN          NUMBER
, p_Last_Update_Date      IN          DATE
, p_Last_Update_Login     IN          NUMBER
, x_Return_Status         OUT NOCOPY  VARCHAR2
, x_Msg_Count             OUT NOCOPY  NUMBER
, x_Msg_Data              OUT NOCOPY  VARCHAR2
)IS
l_Calendar_Record   BSC_CALENDAR_PUB.Calendar_Type_Record;
BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;
  --Here Just populate the calendar record with the values passed from UI and call public API
  l_Calendar_Record.Calendar_Id            := p_Calendar_Id;
  l_Calendar_Record.Edw_Flag               := p_Edw_Flag;
  l_Calendar_Record.Edw_Calendar_Id        := p_Edw_Calendar_Id;
  l_Calendar_Record.Edw_Calendar_Type_Id   := p_Edw_Calendar_Type_Id;
  l_Calendar_Record.Fiscal_Year            := p_Fiscal_Year;
  l_Calendar_Record.Fiscal_Change          := p_Fiscal_Change;
  l_Calendar_Record.Range_Yr_Mod           := p_Range_Yr_Mod;
  l_Calendar_Record.Current_Year           := p_Current_Year;
  l_Calendar_Record.Start_Month            := p_Start_Month;
  l_Calendar_Record.Start_Day              := p_Start_Day;
  l_Calendar_Record.Name                   := p_Name;
  l_Calendar_Record.Help                   := p_Help;
  l_Calendar_Record.Dim_Short_Name         := p_Dim_Short_Name;
  l_Calendar_Record.Application_Id         := p_Application_Id;
  l_Calendar_Record.Creation_Date          := p_Creation_Date;
  l_Calendar_Record.Last_Updated_By        := p_Last_Updated_By;
  l_Calendar_Record.Last_Update_Date       := p_Last_Update_Date;
  l_Calendar_Record.Last_Update_Login      := p_Last_Update_Login;
  l_Calendar_Record.Base_Periodicities_Ids := p_Base_Per_Ids;
  --dbms_output.put_line('before creating BSC_CALENDAR_PUB.Create_Calendar');
  BSC_CALENDAR_PUB.Create_Calendar
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
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_WRAPPER.Create_Calendar_UI ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_WRAPPER.Create_Calendar_UI ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_WRAPPER.Create_Calendar_UI ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_WRAPPER.Create_Calendar_UI ';
    END IF;

END Create_Calendar_UI;
/*******************************************************************************/
PROCEDURE Update_Calendar_UI
( p_Api_Version           IN          NUMBER
, p_Commit                IN          VARCHAR2
, p_Calendar_Id           IN          NUMBER
, p_Edw_Flag              IN          NUMBER
, p_Edw_Calendar_Id       IN          NUMBER
, p_Edw_Calendar_Type_Id  IN          NUMBER
, p_Fiscal_Year           IN          NUMBER
, p_Fiscal_Change         IN          NUMBER
, p_Range_Yr_Mod          IN          NUMBER
, p_Current_Year          IN          NUMBER
, p_Start_Month           IN          NUMBER
, p_Start_Day             IN          NUMBER
, p_Name                  IN          VARCHAR2
, p_Help                  IN          VARCHAR2
, p_Dim_Short_Name        IN          VARCHAR2
, p_Application_Id        IN          NUMBER
, p_Time_Stamp            IN          VARCHAR2 := NULL
, p_Created_By            IN          NUMBER
, p_Creation_Date         IN          DATE
, p_Last_Updated_By       IN          NUMBER
, p_Last_Update_Date      IN          DATE
, p_Last_Update_Login     IN          NUMBER
, x_Return_Status         OUT NOCOPY  VARCHAR2
, x_Msg_Count             OUT NOCOPY  NUMBER
, x_Msg_Data              OUT NOCOPY  VARCHAR2
)IS
l_Calendar_Record   BSC_CALENDAR_PUB.Calendar_Type_Record;
BEGIN
  --dbms_output.put_line('i came here');
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;
  --Here Just populate the calendar record with the values passed from UI and call public API
  l_Calendar_Record.Calendar_Id           := p_Calendar_Id;
  --dbms_output.put_line('not able to assign the value');
  l_Calendar_Record.Edw_Flag              := p_Edw_Flag;
  l_Calendar_Record.Edw_Calendar_Id       := p_Edw_Calendar_Id;
  l_Calendar_Record.Edw_Calendar_Type_Id  := p_Edw_Calendar_Type_Id;
  l_Calendar_Record.Fiscal_Year           := p_Fiscal_Year;
  l_Calendar_Record.Fiscal_Change         := p_Fiscal_Change;
  l_Calendar_Record.Range_Yr_Mod          := p_Range_Yr_Mod;
  l_Calendar_Record.Current_Year          := p_Current_Year;
  l_Calendar_Record.Start_Month           := p_Start_Month;
  l_Calendar_Record.Start_Day             := p_Start_Day;
  l_Calendar_Record.Name                  := p_Name;
  l_Calendar_Record.Help                  := p_Help;
  l_Calendar_Record.Dim_Short_Name        := p_Dim_Short_Name;
  l_Calendar_Record.Application_Id        := p_Application_Id;
  l_Calendar_Record.Created_By            := p_Created_By;
  l_Calendar_Record.Creation_Date         := p_Creation_Date;
  l_Calendar_Record.Last_Updated_By       := p_Last_Updated_By;
  l_Calendar_Record.Last_Update_Date      := p_Last_Update_Date;
  l_Calendar_Record.Last_Update_Login     := p_Last_Update_Login;
  --dbms_output.put_line('before creating BSC_CALENDAR_PUB.Update_Calendar');

  BSC_BIS_LOCKS_PUB.Lock_Calendar (
       p_Calendar_Id    => p_Calendar_Id
     , p_Time_Stamp     => p_Time_Stamp
     , x_Return_Status  => x_Return_Status
     , x_Msg_Count      => x_Msg_Count
     , x_Msg_Data       => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  BSC_CALENDAR_PUB.Update_Calendar
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
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_WRAPPER.Update_Calendar_UI ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_WRAPPER.Update_Calendar_UI ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_WRAPPER.Update_Calendar_UI ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_WRAPPER.Update_Calendar_UI ';
    END IF;

END Update_Calendar_UI;

PROCEDURE Delete_Calendar_UI
(  p_Api_Version           IN          NUMBER
, p_Commit                IN          VARCHAR2
, p_Calendar_Id           IN          NUMBER
, p_Time_Stamp            IN          VARCHAR2 := NULL
, x_Return_Status         OUT NOCOPY  VARCHAR2
, x_Msg_Count             OUT NOCOPY  NUMBER
, x_Msg_Data              OUT NOCOPY  VARCHAR2
)IS
l_Calendar_Record   BSC_CALENDAR_PUB.Calendar_Type_Record;
BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;
  --Here Just populate the calendar record with the values passed from UI and call public API
  l_Calendar_Record.Calendar_Id           := p_Calendar_Id;

  BSC_BIS_LOCKS_PUB.Lock_Calendar_And_Periods (
       p_Calendar_Id    => p_Calendar_Id
     , p_Time_Stamp     => p_Time_Stamp
     , x_Return_Status  => x_Return_Status
     , x_Msg_Count      => x_Msg_Count
     , x_Msg_Data       => x_Msg_Data
  );
  IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  BSC_CALENDAR_PUB.Delete_Calendar
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
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_WRAPPER.Delete_Calendar_UI ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_WRAPPER.Delete_Calendar_UI ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_WRAPPER.Delete_Calendar_UI ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_WRAPPER.Delete_Calendar_UI ';
    END IF;

END Delete_Calendar_UI;

/*
API to check if DBI is installed.
*/

FUNCTION Is_Dbi_Calendar_Enabled
RETURN VARCHAR2 IS
BEGIN

  IF (bsc_dbi_calendar.check_for_dbi) THEN
      RETURN FND_API.G_TRUE;
  ELSE
      RETURN FND_API.G_FALSE;
  END IF;

EXCEPTION
   WHEN OTHERS THEN
       RETURN FND_API.G_FALSE;
END Is_Dbi_Calendar_Enabled;


END BSC_CALENDAR_WRAPPER;

/
