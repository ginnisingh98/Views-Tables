--------------------------------------------------------
--  DDL for Package BSC_PERIODICITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_PERIODICITIES_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPPERS.pls 120.4.12000000.3 2007/05/16 12:52:56 ppandey ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCPPERS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: PUBLIC specification to manage periodicities              |
REM | NOTES                                                                 |
REM | 14-JUL-2005 Aditya Rao  Created.                                      |
REM | 12-AUG-2005 Aditya Rao added API Get_Incr_Change                      |
REM | 29-NOV-2005 Krishna Modified for enh#4711274                          |
REM | 07-FEB-2006 ashankar Fix for the bug4695330                           |
REM | 21-MAR-2006 ashankar  Fixed bug#5099465 Modified Validate_Periodicity |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_PERIODICITIES_PUB';


TYPE Periodicities_Rec_Type IS RECORD
(
      Periodicity_Id             BSC_SYS_PERIODICITIES.PERIODICITY_ID%TYPE
    , Num_Of_Periods             BSC_SYS_PERIODICITIES.NUM_OF_PERIODS%TYPE
    , Source                     BSC_SYS_PERIODICITIES.SOURCE%TYPE
    , Base_Periodicity_Id        BSC_SYS_PERIODICITIES.PERIODICITY_ID%TYPE
    , Num_Of_Subperiods          BSC_SYS_PERIODICITIES.NUM_OF_SUBPERIODS%TYPE
    , Period_Col_Name            BSC_SYS_PERIODICITIES.PERIOD_COL_NAME%TYPE
    , Subperiod_Col_Name         BSC_SYS_PERIODICITIES.SUBPERIOD_COL_NAME%TYPE
    , Yearly_Flag                BSC_SYS_PERIODICITIES.YEARLY_FLAG%TYPE
    , Edw_Flag                   BSC_SYS_PERIODICITIES.EDW_FLAG%TYPE
    , Calendar_Id                BSC_SYS_PERIODICITIES.CALENDAR_ID%TYPE
    , Edw_Periodicity_Id         BSC_SYS_PERIODICITIES.EDW_PERIODICITY_ID%TYPE
    , Custom_Code                BSC_SYS_PERIODICITIES.CUSTOM_CODE%TYPE
    , Db_Column_Name             BSC_SYS_PERIODICITIES.DB_COLUMN_NAME%TYPE
    , Periodicity_Type           BSC_SYS_PERIODICITIES.PERIODICITY_TYPE%TYPE
    , Period_Type_Id             BSC_SYS_PERIODICITIES.PERIOD_TYPE_ID%TYPE
    , Record_Type_Id             BSC_SYS_PERIODICITIES.RECORD_TYPE_ID%TYPE
    , Xtd_Pattern                BSC_SYS_PERIODICITIES.XTD_PATTERN%TYPE
    , Short_Name                 BSC_SYS_PERIODICITIES.SHORT_NAME%TYPE
    , Name                       BSC_SYS_PERIODICITIES_TL.NAME%TYPE
    , Description                BIS_LEVELS_TL.DESCRIPTION%TYPE
    , Created_By                 BSC_SYS_PERIODICITIES_TL.CREATED_BY%TYPE
    , Creation_Date              BSC_SYS_PERIODICITIES_TL.CREATION_DATE%TYPE
    , Last_Updated_By            BSC_SYS_PERIODICITIES_TL.LAST_UPDATED_BY%TYPE
    , Last_Update_Date           BSC_SYS_PERIODICITIES_TL.LAST_UPDATE_DATE%TYPE
    , Last_Update_Login          BSC_SYS_PERIODICITIES_TL.LAST_UPDATE_LOGIN%TYPE
    , Application_id             BIS_LEVELS.APPLICATION_ID%TYPE
    , Period_Year                BSC_SYS_PERIODS.YEAR%TYPE
    , Start_Period               BSC_SYS_PERIODS.START_PERIOD%TYPE
    , End_Period                 BSC_SYS_PERIODS.END_PERIOD%TYPE
    , Period_IDs                 VARCHAR2(8000)
    , ForceRunPopulateCalendar   VARCHAR2(1) := FND_API.G_TRUE
);


/*
Procedure Name
Parameters

*/

PROCEDURE Create_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);


--PROCEDURE Validate_Periodicity

PROCEDURE Validate_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,p_Action_Type             IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);

--PROCEDURE Update_Periodicity

PROCEDURE Populate_Periodicity_Record (
  p_Api_Version             IN          NUMBER
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Periodicities_Rec_Type  OUT NOCOPY  BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);

-- populates the BSC_SYS_PERIODS metadata
PROCEDURE Populate_Period_Metadata (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2
 ,p_Action_Type             IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,p_disable_period_val_flag IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);



--PROCEDURE Update_Periodicity

PROCEDURE Update_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);

--PROCEDURE Retrieve_Periodicity

PROCEDURE Retrieve_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Periodicities_Rec_Type  OUT NOCOPY  BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);



--PROCEDURE Delete_Periodicity
PROCEDURE Delete_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);


PROCEDURE Get_Incr_Change (
   p_Periodicity_Id       IN NUMBER
  ,p_Calendar_ID          IN NUMBER
  ,p_Base_Periodicity_Id  IN NUMBER
  ,p_Num_Of_Periods       IN NUMBER
  ,p_Period_Ids           IN VARCHAR2
  ,p_Return_Values        IN VARCHAR2
  ,x_Message_Name         OUT NOCOPY VARCHAR2
  ,x_Objective_List       OUT NOCOPY VARCHAR2
);

/******************************************************************
         Fix for the bug 4695330
/*****************************************************************/

PROCEDURE Create_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,p_disable_period_val_flag IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,p_disable_period_val_flag IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);


PROCEDURE Validate_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,p_Action_Type             IN          VARCHAR2
 ,p_disable_period_val_flag IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);

PROCEDURE Translate_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,p_disable_period_val_flag IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);

PROCEDURE Load_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,p_disable_period_val_flag IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
);

END BSC_PERIODICITIES_PUB;

 

/
