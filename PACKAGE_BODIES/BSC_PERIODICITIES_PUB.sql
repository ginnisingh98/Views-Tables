--------------------------------------------------------
--  DDL for Package Body BSC_PERIODICITIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_PERIODICITIES_PUB" AS
/* $Header: BSCPPERB.pls 120.13.12000000.4 2007/05/16 12:51:35 ppandey ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCPPERB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: PUBLIC package body to manage periodicities               |
REM | NOTES                                                                 |
REM | 14-JUL-2005 Aditya Rao  Created.                                      |
REM | 12-AUG-2005 Aditya Rao added API Get_Incr_Change                      |
REM | 25-AUG-2005 Pradeep    Bug #4570854, on delete current periodicity_id |
REM |                          need to be used for Annually_source          |
REM | 29-AUG-2005 Aditya Rao Fixed Bug#4574115 in API Validate_Periodicity  |
REM | 07-OCT-2005 Aditya Rao Fixed Bug#4655119, enabled corresponding DO    |
REM |                        created for Periodicities                      |
REM | 29-NOV-2005 Krishna Modified for enh#4711274                          |
REM | 29-DEC-2005 Krishna Passsing enabled = false for hidden periodicities |
REM | 07-FEB-2006 ashankar Fix for the bug4695330                           |
REM | 15-FEB-2006 visuri  Fixed bug#4757375 AK check for Delete Periodicity |
REM | 21-MAR-2006 ashankar  Fixed bug#5099465 Modified Validate_Periodicity |
REM +=======================================================================+
*/

G_PKG_NAME CONSTANT VARCHAR2(30):='BSC_PERIODICITIES_PUB';


/*
Procedure Name
Parameters

*/

PROCEDURE Update_Annually_Source
( p_Calendar_Id    IN  NUMBER
, p_Periodicity_Id IN  NUMBER
, p_Action         IN  NUMBER
, x_Return_Status  OUT NOCOPY  VARCHAR2
, x_Msg_Count      OUT NOCOPY  NUMBER
, x_Msg_Data       OUT NOCOPY  VARCHAR2
);
/**************************************************************/

PROCEDURE Create_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,p_disable_period_val_flag IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS
    l_Periodicities_Rec_Type  BSC_PERIODICITIES_PUB.Periodicities_Rec_Type;
    l_Dim_Short_Name          BSC_SYS_CALENDARS_B.SHORT_NAME%TYPE;
    l_Periodicity_View_Name   VARCHAR2(30);
    l_Dimobj_Name             BIS_LEVELS_TL.NAME%TYPE;
    l_Dim_Enabled             VARCHAR2(10);
BEGIN
    SAVEPOINT CreatePeriodicityPUB;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    l_Dim_Enabled   := FND_API.G_TRUE;
    l_Periodicities_Rec_Type := p_Periodicities_Rec_Type;

    BSC_PERIODICITIES_PUB.Populate_Periodicity_Record (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Periodicities_Rec_Type  => p_Periodicities_Rec_Type
     ,x_Periodicities_Rec_Type  => l_Periodicities_Rec_Type
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_PERIODICITIES_PUB.Validate_Periodicity (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Periodicities_Rec_Type  => l_Periodicities_Rec_Type
     ,p_Action_Type             => BSC_PERIODS_UTILITY_PKG.C_CREATE
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_PERIODICITIES_PVT.Create_Periodicity (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Commit                  => p_Commit
     ,p_Periodicities_Rec_Type  => l_Periodicities_Rec_Type
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_PERIODICITIES_PUB.Populate_Period_Metadata (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Commit                  => p_Commit
     ,p_Action_Type             => BSC_PERIODS_UTILITY_PKG.C_CREATE
     ,p_Periodicities_Rec_Type  => l_Periodicities_Rec_Type
     ,p_disable_period_val_flag => p_disable_period_val_flag
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_PERIODICITIES_PUB.Update_Annually_Source (
      p_Calendar_Id     => l_Periodicities_Rec_Type.Calendar_Id
     ,p_Periodicity_Id  => l_Periodicities_Rec_Type.Periodicity_Id
     ,p_Action          => 1  -- Action for new/updated Period.
     ,x_Return_Status   => x_Return_Status
     ,x_Msg_Count       => x_Msg_Count
     ,x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_PERIODS_PUB.Create_Periodicity_View (
      p_Periodicity_Id         => l_Periodicities_Rec_Type.Periodicity_Id
    , p_Short_Name             => l_Periodicities_Rec_Type.Short_Name
    , p_Calendar_Id            => l_Periodicities_Rec_Type.Calendar_Id
    , x_Periodicity_View_Name  => l_Periodicity_View_Name
    , x_Return_Status          => x_Return_Status
    , x_Msg_Count              => x_Msg_Count
    , x_Msg_Data               => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF(l_Periodicities_Rec_Type.Periodicity_Type IN (11,12) )THEN
      l_Dim_Enabled := FND_API.G_FALSE;
    END IF;

    l_Dim_Short_Name := BSC_PERIODS_UTILITY_PKG.Get_Calendar_Short_Name(l_Periodicities_Rec_Type.Calendar_Id);
    l_Dimobj_Name := BSC_PERIODS_UTILITY_PKG.get_Dimobj_Name_From_period
                     ( p_Calendar_Id      => l_Periodicities_Rec_Type.Calendar_Id
                     , p_Periodicity_Name => l_Periodicities_Rec_Type.Name
                     );
    -- passed p_Dim_Obj_Enabled = 'T' for Dimension Objects, Bug#4655119
    BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object
    (
            p_commit                  =>  p_Commit
        ,   p_dim_obj_short_name      =>  l_Periodicities_Rec_Type.Short_Name
        ,   p_display_name            =>  l_Dimobj_Name
        ,   p_application_id          =>  l_Periodicities_Rec_Type.Application_id
        ,   p_description             =>  l_Periodicities_Rec_Type.Description
        ,   p_data_source             =>  BSC_PERIODS_UTILITY_PKG.C_PMF_DO_TYPE
        ,   p_source_table            =>  l_Periodicity_View_Name
        ,   p_where_clause            =>  NULL
        ,   p_comparison_label_code   =>  NULL
        ,   p_table_column            =>  NULL
        ,   p_source_type             =>  BSC_PERIODS_UTILITY_PKG.C_OLTP_DO_TYPE
        ,   p_maximum_code_size       =>  NULL
        ,   p_maximum_name_size       =>  NULL
        ,   p_all_item_text           =>  NULL
        ,   p_comparison_item_text    =>  NULL
        ,   p_prototype_default_value =>  NULL
        ,   p_dimension_values_order  =>  NULL
        ,   p_comparison_order        =>  1
        ,   p_dim_short_names         =>  l_Dim_Short_Name
        ,   p_Dim_Obj_Enabled         =>  l_Dim_Enabled
        ,   x_return_status           =>  x_return_status
        ,   x_msg_count               =>  x_msg_count
        ,   x_msg_data                =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF(l_Periodicities_Rec_Type.ForceRunPopulateCalendar = FND_API.G_TRUE ) THEN
        BSC_UPDATE_UTIL.Populate_Calendar_Tables
        ( p_commit         => p_Commit
        , p_calendar_id    => l_Periodicities_Rec_Type.Calendar_Id
        , x_return_status  => x_Return_Status
        , x_msg_count      => x_Msg_Count
        , x_msg_data       => x_Msg_Data
        );
        IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    IF (p_Commit IS NOT NULL AND p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreatePeriodicityPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreatePeriodicityPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreatePeriodicityPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PUB.Create_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PUB.Create_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreatePeriodicityPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PUB.Create_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PUB.Create_Periodicity ';
        END IF;
END Create_Periodicity;


PROCEDURE Update_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2 := FND_API.G_FALSE
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,p_disable_period_val_flag IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS
    l_Periodicities_Rec_Type BSC_PERIODICITIES_PUB.Periodicities_Rec_Type;
    l_Structural_Flag        VARCHAR2(1);
    l_Periodicity_View_Name  VARCHAR2(30);
    l_Message_Name           BSC_MESSAGES.MESSAGE_NAME%TYPE;
    l_Objective_List         VARCHAR2(2000);
    l_Dimobj_Name             BIS_LEVELS_TL.NAME%TYPE;
    l_Dim_Short_Name         BSC_SYS_DIM_GROUPS_TL.SHORT_NAME%TYPE;
    l_Dim_Enabled            VARCHAR2(10);
BEGIN
    SAVEPOINT UpdatePeriodicityPUB;
    FND_MSG_PUB.Initialize;
    l_Dim_Enabled   := FND_API.G_TRUE;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_Periodicities_Rec_Type := p_Periodicities_Rec_Type;

    l_Structural_Flag := FND_API.G_FALSE;

    BSC_PERIODICITIES_PUB.Validate_Periodicity (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Periodicities_Rec_Type  => l_Periodicities_Rec_Type
     ,p_Action_Type             => BSC_PERIODS_UTILITY_PKG.C_UPDATE
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_PERIODICITIES_PUB.Get_Incr_Change (
       p_Periodicity_Id       => l_Periodicities_Rec_Type.Periodicity_Id
      ,p_Calendar_ID          => l_Periodicities_Rec_Type.Calendar_Id
      ,p_Base_Periodicity_Id  => l_Periodicities_Rec_Type.Base_Periodicity_Id
      ,p_Num_Of_Periods       => l_Periodicities_Rec_Type.Num_Of_Periods
      ,p_Period_Ids           => l_Periodicities_Rec_Type.Period_IDs
      ,p_Return_Values        => FND_API.G_FALSE
      ,x_Message_Name         => l_Message_Name
      ,x_Objective_List       => l_Objective_List
    );

    BSC_PERIODICITIES_PVT.Update_Periodicity (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Commit                  => p_Commit
     ,p_Periodicities_Rec_Type  => l_Periodicities_Rec_Type
     ,x_Structural_Flag         => l_Structural_Flag
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_Message_Name IS NOT NULL) THEN
        l_Structural_Flag := FND_API.G_TRUE;
    END IF ;

    BSC_PERIODICITIES_PUB.Populate_Period_Metadata (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Commit                  => p_Commit
     ,p_Action_Type             => BSC_PERIODS_UTILITY_PKG.C_UPDATE
     ,p_Periodicities_Rec_Type  => l_Periodicities_Rec_Type
     ,p_disable_period_val_flag => p_disable_period_val_flag
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_PERIODICITIES_PUB.Update_Annually_Source(
      p_Calendar_Id     => l_Periodicities_Rec_Type.Calendar_Id
     ,p_Periodicity_Id  => l_Periodicities_Rec_Type.Periodicity_Id
     ,p_Action          => 1  -- Action for new/updated Period.
     ,x_Return_Status   => x_Return_Status
     ,x_Msg_Count       => x_Msg_Count
     ,x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Recreate underlying views.
    BSC_PERIODS_PUB.Create_Periodicity_View
    (
      p_Periodicity_Id         => l_Periodicities_Rec_Type.Periodicity_Id
    , p_Short_Name             => l_Periodicities_Rec_Type.Short_Name
    , p_Calendar_Id            => l_Periodicities_Rec_Type.Calendar_Id
    , x_Periodicity_View_Name  => l_Periodicity_View_Name
    , x_Return_Status          => x_Return_Status
    , x_Msg_Count              => x_Msg_Count
    , x_Msg_Data               => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF(l_Periodicities_Rec_Type.Periodicity_Type IN (11,12) )THEN
      l_Dim_Enabled := FND_API.G_FALSE;
    END IF;

    l_Dim_Short_Name := BSC_PERIODS_UTILITY_PKG.Get_Calendar_Short_Name(l_Periodicities_Rec_Type.Calendar_Id);
    l_Dimobj_Name := BSC_PERIODS_UTILITY_PKG.get_Dimobj_Name_From_period
                     ( p_Calendar_Id      => l_Periodicities_Rec_Type.Calendar_Id
                     , p_Periodicity_Name => l_Periodicities_Rec_Type.Name
                     );
    -- passed p_Dim_Obj_Enabled = 'T' for Dimension Objects, Bug#4655119
    BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object
    (
            p_Commit                    =>  p_commit
        ,   p_Dim_Obj_Short_Name        =>  l_Periodicities_Rec_Type.Short_Name
        ,   p_Display_Name              =>  l_Dimobj_Name
        ,   p_Application_Id            =>  l_Periodicities_Rec_Type.Application_id
        ,   p_Description               =>  l_Periodicities_Rec_Type.Description
        ,   p_Data_Source               =>  BSC_PERIODS_UTILITY_PKG.C_PMF_DO_TYPE
        ,   p_Source_Table              =>  l_Periodicity_View_Name
        ,   p_Where_Clause              =>  NULL
        ,   p_Comparison_Label_Code     =>  NULL
        ,   p_Table_Column              =>  NULL
        ,   p_Source_Type               =>  BSC_PERIODS_UTILITY_PKG.C_OLTP_DO_TYPE
        ,   p_Maximum_Code_Size         =>  NULL
        ,   p_Maximum_Name_Size         =>  NULL
        ,   p_All_Item_Text             =>  NULL
        ,   p_Comparison_Item_Text      =>  NULL
        ,   p_Prototype_Default_Value   =>  NULL
        ,   p_Dimension_Values_Order    =>  NULL
        ,   p_Comparison_Order          =>  NULL
        ,   p_Assign_Dim_Short_Names    =>  l_Dim_Short_Name
        ,   p_Unassign_Dim_Short_Names  =>  NULL
        ,   p_Dim_Obj_Enabled           =>  l_Dim_Enabled
        ,   x_Return_Status             =>  x_Return_Status
        ,   x_Msg_Count                 =>  x_Msg_Count
        ,   x_Msg_Data                  =>  x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF (l_Structural_Flag = FND_API.G_TRUE) THEN
        BSC_PERIODICITIES_PVT.Incr_Refresh_Objectives(
          p_Commit                  => p_Commit
         ,p_Periodicities_Rec_Type  => p_Periodicities_Rec_Type
         ,x_Return_Status           => x_Return_Status
         ,x_Msg_Count               => x_Msg_Count
         ,x_Msg_Data                => x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- populate Calendar tables.

    IF(l_Periodicities_Rec_Type.ForceRunPopulateCalendar = FND_API.G_TRUE ) THEN
        BSC_UPDATE_UTIL.Populate_Calendar_Tables
        ( p_commit         => p_Commit
        , p_calendar_id    => l_Periodicities_Rec_Type.Calendar_Id
        , x_return_status  => x_Return_Status
        , x_msg_count      => x_Msg_Count
        , x_msg_data       => x_Msg_Data
        );
        IF(x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;

    IF ((p_Commit IS NOT NULL) AND p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdatePeriodicityPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdatePeriodicityPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdatePeriodicityPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PUB.Update_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PUB.Update_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO UpdatePeriodicityPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PUB.Update_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PUB.Update_Periodicity ';
        END IF;
END Update_Periodicity;



-- Delete periodicity API
PROCEDURE Delete_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS
    l_Dim_Object_SN  BSC_SYS_PERIODICITIES.SHORT_NAME%TYPE;
    l_Dimension_SN   BSC_SYS_CALENDARS_B.SHORT_NAME%TYPE;
    l_Periodicity_View_Name   VARCHAR2(30);
    l_dim_name       BSC_SYS_CALENDARS_VL.NAME%TYPE;
    l_dim_obj_name   BSC_SYS_PERIODICITIES_VL.NAME%TYPE;
    l_regions        VARCHAR2(32000);

    CURSOR c_Delete_View IS
        SELECT L.LEVEL_VALUES_VIEW_NAME
        FROM   BIS_LEVELS L
        WHERE  L.SHORT_NAME = l_Dim_Object_SN
        AND    L.LEVEL_VALUES_VIEW_NAME IS NOT NULL;
BEGIN
    SAVEPOINT DeletePeriodicityPUB;
    FND_MSG_PUB.Initialize;

    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('p_Periodicities_Rec_Type.Periodicity_Id - ' ||p_Periodicities_Rec_Type.Periodicity_Id);
    --dbms_output.PUT_LINE('p_Periodicities_Rec_Type.Calendar_Id - ' ||p_Periodicities_Rec_Type.Calendar_Id);


    BSC_PERIODICITIES_PUB.Validate_Periodicity (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Periodicities_Rec_Type  => p_Periodicities_Rec_Type
     ,p_Action_Type             => BSC_PERIODS_UTILITY_PKG.C_DELETE
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_Dim_Object_SN := BSC_PERIODS_UTILITY_PKG.Get_Periodicity_Short_Name(p_Periodicities_Rec_Type.Periodicity_Id);
    l_Dimension_SN  := BSC_PERIODS_UTILITY_PKG.Get_Calendar_Short_Name(p_Periodicities_Rec_Type.Calendar_Id);
    l_regions := BSC_UTILITY.Is_Dim_In_AKReport(l_Dimension_SN||'+'||l_Dim_Object_SN);
    IF(l_regions IS NOT NULL) THEN

      SELECT c.name
      INTO   l_dim_name
      FROM   bsc_sys_calendars_vl c
      WHERE  c.short_name = l_Dimension_SN;

      SELECT c.name
      INTO   l_dim_obj_name
      FROM   bsc_sys_periodicities_vl c
      WHERE  c.short_name = l_Dim_Object_SN;

      FND_MESSAGE.SET_NAME('BIS','BIS_DIM_OBJ_RPTASSOC_ERROR');
      FND_MESSAGE.SET_TOKEN('DIM_NAME', l_dim_obj_name);
      FND_MESSAGE.SET_TOKEN('DIM_OBJ_NAME', l_dim_name);
      FND_MESSAGE.SET_TOKEN('REPORTS_ASSOC', l_regions);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    BSC_PERIODICITIES_PVT.Delete_Periodicity (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Commit                  => p_Commit
     ,p_Periodicities_Rec_Type  => p_Periodicities_Rec_Type
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_PERIODICITIES_PUB.Update_Annually_Source(
      p_Calendar_Id     => p_Periodicities_Rec_Type.Calendar_Id
     ,p_Periodicity_Id  => p_Periodicities_Rec_Type.Periodicity_Id
     ,p_Action          => 2  -- Action for Period Delete.
     ,x_Return_Status   => x_Return_Status
     ,x_Msg_Count       => x_Msg_Count
     ,x_Msg_Data        => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --dbms_output.PUT_LINE('Shortnames - ' || l_Dim_Object_SN || ', ' || l_Dimension_SN);

    BSC_BIS_DIM_OBJ_PUB.Unassign_Dimensions
    (       p_commit                =>  p_commit
        ,   p_dim_obj_short_name    =>  l_Dim_Object_SN
        ,   p_dim_short_names       =>  l_Dimension_SN
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --dbms_output.PUT_LINE(' After Unassign_Dimensions ');

    -- Get hold of the view that needs to be dropped.
    FOR cDelView IN c_Delete_View LOOP
        l_Periodicity_View_Name := cDelView.LEVEL_VALUES_VIEW_NAME;
    END LOOP;

    BSC_BIS_DIM_OBJ_PUB.Delete_Dim_Object
    (       p_commit              => p_commit
        ,   p_dim_obj_short_name  => l_Dim_Object_SN
        ,   x_return_status       => x_return_status
        ,   x_msg_count           => x_msg_count
        ,   x_msg_data            => x_msg_data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --dbms_output.PUT_LINE(' After Delete_Dim_Object ');


    -- Drop the periodicity view
    IF (l_Periodicity_View_Name IS NOT NULL) THEN
        BSC_PERIODS_PUB.Drop_Periodicity_View
        (
          p_Periodicity_View  => l_Periodicity_View_Name
        , x_Return_Status     => x_Return_Status
        , x_Msg_Count         => x_Msg_Count
        , x_Msg_Data          => x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF (p_Commit IS NOT NULL AND p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeletePeriodicityPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeletePeriodicityPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeletePeriodicityPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PUB.Delete_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PUB.Delete_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO DeletePeriodicityPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PUB.Delete_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PUB.Delete_Periodicity ';
        END IF;
END Delete_Periodicity;


PROCEDURE Validate_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,p_Action_Type             IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
)IS
BEGIN
   BSC_PERIODICITIES_PUB.Validate_Periodicity
   (
      p_Api_Version             => p_Api_Version
     ,p_Periodicities_Rec_Type  => p_Periodicities_Rec_Type
     ,p_Action_Type             => p_Action_Type
     ,p_disable_period_val_flag => FND_API.G_FALSE
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
END Validate_Periodicity;



PROCEDURE Validate_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,p_Action_Type             IN          VARCHAR2
 ,p_disable_period_val_flag IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS
    CURSOR c_Objectives IS
    SELECT K.NAME
    FROM   BSC_KPIS_VL K
         , BSC_KPI_PERIODICITIES P
    WHERE  P.PERIODICITY_ID = p_Periodicities_Rec_Type.Periodicity_Id
    AND    K.INDICATOR = P.INDICATOR;


    l_Periodicity_Name  BSC_SYS_PERIODICITIES_TL.NAME%TYPE;
    l_Is_Name_Unique    VARCHAR2(1);
    l_Max_Periodicities NUMBER;
    l_Count             NUMBER;
    l_Is_Circular       VARCHAR2(3);
    l_Objective_Names   VARCHAR2(2000);
BEGIN
    SAVEPOINT ValidatePeriodicityPUB;

    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;


    IF ((p_Action_Type = BSC_PERIODS_UTILITY_PKG.C_CREATE) OR (p_Action_Type = BSC_PERIODS_UTILITY_PKG.C_UPDATE)) THEN

        IF (p_Periodicities_Rec_Type.Calendar_Id IS NULL) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_CALENDAR_ID_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (p_Periodicities_Rec_Type.Custom_Code <> BSC_PERIODS_UTILITY_PKG.C_BASE_PERIODICITY_TYPE) THEN
            IF (p_Periodicities_Rec_Type.Base_Periodicity_Id IS NULL) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_BASE_PERIODICITY_NULL');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (p_Periodicities_Rec_Type.Period_IDs IS NULL) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_PERIOD_IDS_NULL');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        l_Is_Name_Unique := BSC_PERIODS_UTILITY_PKG.Is_Period_Name_Unique (
                                  p_Periodicities_Rec_Type.Calendar_Id
                                , p_Periodicities_Rec_Type.Name
                            );

        -- Validation#3
        IF (p_Periodicities_Rec_Type.Num_Of_Periods IS NULL) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_NUM_PERIODS_CANNOT_NULL');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;



        IF (p_Action_Type = BSC_PERIODS_UTILITY_PKG.C_CREATE) THEN

            -- Validation#1:
            IF(l_Is_Name_Unique = FND_API.G_FALSE) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_PERIOD_EXISTS');
                FND_MESSAGE.SET_TOKEN('PERIOD', p_Periodicities_Rec_Type.Name);
                FND_MESSAGE.SET_TOKEN('CALENDAR',
                    BSC_PERIODS_UTILITY_PKG.Get_Calendar_Name(
                        p_Periodicities_Rec_Type.Calendar_Id
                    )
                );
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- Validation#2
            SELECT COUNT(1) INTO l_Count
            FROM   BSC_SYS_PERIODICITIES P
            WHERE  P.PERIODICITY_ID = p_Periodicities_Rec_Type.Periodicity_id;

            IF (l_Count <> 0) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_PERIODICITY_ID_UNIQUE');
                FND_MESSAGE.SET_TOKEN('PERIODICITY_ID', p_Periodicities_Rec_Type.Periodicity_id);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- Validation#2:
            l_Max_Periodicities := BSC_PERIODS_UTILITY_PKG.Get_Cust_Per_Cnt_By_Calendar(
                                        p_Periodicities_Rec_Type.Calendar_Id
                                   );
            IF(l_Max_Periodicities =  BSC_PERIODS_UTILITY_PKG.C_MAX_CUSTOM_PERIODICITIES) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_PER_CAL_EXCEEDS_LIMIT');
                FND_MESSAGE.SET_TOKEN('CALENDAR',
                    BSC_PERIODS_UTILITY_PKG.Get_Calendar_Name(
                        p_Periodicities_Rec_Type.Calendar_Id
                    )
                );
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF (p_Action_Type = BSC_PERIODS_UTILITY_PKG.C_UPDATE) THEN

            SELECT COUNT(1) INTO l_Count
            FROM   BSC_SYS_PERIODICITIES_VL P
            WHERE  P.NAME            = p_Periodicities_Rec_Type.Name
            AND    P.CALENDAR_ID     = p_Periodicities_Rec_Type.Calendar_Id
            AND    P.PERIODICITY_ID <> p_Periodicities_Rec_Type.Periodicity_id;

            IF (l_Count <> 0) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_PERIOD_EXISTS');
                FND_MESSAGE.SET_TOKEN('PERIOD', p_Periodicities_Rec_Type.Name);
                FND_MESSAGE.SET_TOKEN('CALENDAR',
                    BSC_PERIODS_UTILITY_PKG.Get_Calendar_Name(
                        p_Periodicities_Rec_Type.Calendar_Id
                    )
                );
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- Do not allow update of Base Periodicities .
            -- Change Periodicity_Type to Custom_Code.
            SELECT COUNT(1) INTO l_Count
            FROM   BSC_SYS_PERIODICITIES B
            WHERE  B.PERIODICITY_ID   = p_Periodicities_Rec_Type.Periodicity_id
            AND    B.CALENDAR_ID      = p_Periodicities_Rec_Type.Calendar_Id
            AND    B.PERIODICITY_TYPE <> 0;

            IF (l_Count <> 0) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_NO_UPT_BASE_PERIODICITIES');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            -- Check for circular dependency
            l_Is_Circular := BSC_BIS_KPI_MEAS_PUB.is_Period_Circular (
                                      p_Periodicities_Rec_Type.Base_Periodicity_Id
                                    , p_Periodicities_Rec_Type.Periodicity_id
                             );

            IF (l_Is_Circular = BSC_BIS_KPI_MEAS_PUB.CIR_REF_EXISTS) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_PERIOD_NO_CIRCULAR_REF');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    ELSIF (p_Action_Type = BSC_PERIODS_UTILITY_PKG.C_DELETE) THEN

        -- You cannot delete a BASE Periodicity
        SELECT COUNT(1) INTO l_Count
        FROM   BSC_SYS_PERIODICITIES B
        WHERE  B.PERIODICITY_ID   = p_Periodicities_Rec_Type.Periodicity_id
        AND    B.CALENDAR_ID      = p_Periodicities_Rec_Type.Calendar_Id
        AND    B.PERIODICITY_TYPE <> 0;

        IF (l_Count <> 0) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_NO_DEL_BASE_PERIODICITIES');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- You cannot delete a custom periodicity, which is the base
        -- periodicity of another Custom Periodicity

        IF(p_disable_period_val_flag=FND_API.G_FALSE)THEN

            SELECT COUNT(1) INTO l_Count
            FROM   BSC_SYS_PERIODICITIES B
            WHERE  TRIM(B.SOURCE) = TO_CHAR(p_Periodicities_Rec_Type.Periodicity_id);

            IF (l_Count <> 0) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_NO_DEL_IS_BASE_PER');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        -- You cannot delete a periodicity, if it being used in some
        -- objectives.

        SELECT COUNT(1) INTO l_Count
        FROM   BSC_KPI_PERIODICITIES P
        WHERE  P.PERIODICITY_ID = p_Periodicities_Rec_Type.Periodicity_id;

        IF (l_Count <> 0) THEN
            FOR cObj IN c_Objectives LOOP
                IF(l_Objective_Names IS NULL) THEN
                    l_Objective_Names := cObj.NAME;
                ELSE
                    l_Objective_Names := l_Objective_Names || ',' || cObj.NAME;
                END IF;
            END LOOP;

            -- fixed for Bug#4574115
            FND_MESSAGE.SET_NAME('BSC','BSC_PERIOD_USED_IN_OBJECTIVE');
            FND_MESSAGE.SET_TOKEN('PERIODICITY', BSC_PERIODS_UTILITY_PKG.Get_Periodicity_Name(p_Periodicities_Rec_Type.Periodicity_id));
            FND_MESSAGE.SET_TOKEN('OBJECTIVES', l_Objective_Names);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO ValidatePeriodicityPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO ValidatePeriodicityPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO ValidatePeriodicityPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PUB.Validate_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PUB.Validate_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO ValidatePeriodicityPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PUB.Validate_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PUB.Validate_Periodicity ';
        END IF;
END Validate_Periodicity;

-- This API tries to populate the periodicity record with pre-req/default values.

PROCEDURE Populate_Periodicity_Record (
  p_Api_Version             IN          NUMBER
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Periodicities_Rec_Type  OUT NOCOPY  BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS

    l_Calendar_Id               BSC_SYS_CALENDARS_B.CALENDAR_ID%TYPE;
    l_Base_Periodicity_Source   BSC_SYS_PERIODICITIES.SOURCE%TYPE;
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    x_Periodicities_Rec_Type := p_Periodicities_Rec_Type;

    l_Calendar_Id := p_Periodicities_Rec_Type.Calendar_Id;
    l_Base_Periodicity_Source := NULL;

    -- Get the next periodicity_id from sequence
    IF (x_Periodicities_Rec_Type.Periodicity_Id IS NULL) THEN
        x_Periodicities_Rec_Type.Periodicity_Id := BSC_PERIODS_UTILITY_PKG.Get_Next_Periodicity_Id;
    END IF;

    IF (x_Periodicities_Rec_Type.Custom_Code IS NULL) THEN
        x_Periodicities_Rec_Type.Custom_Code := BSC_PERIODS_UTILITY_PKG.C_CUSTOM_PERIODICITY_CODE;
    END IF;

    -- If the periodicity_type is Custom then differnt defaults needs to populated differently

    IF (x_Periodicities_Rec_Type.Custom_Code <> BSC_PERIODS_UTILITY_PKG.C_NON_CUSTOM_PERIODICITY_CODE) THEN

        -- Populate the BSC_SYS_PERIODICITY.SOURCE column
        IF (x_Periodicities_Rec_Type.Base_Periodicity_Id IS NOT NULL) THEN
            /*l_Base_Periodicity_Source := BSC_PERIODS_UTILITY_PKG.Get_Periodicity_Source (
                                                x_Periodicities_Rec_Type.Base_Periodicity_Id
                                         );
            IF (l_Base_Periodicity_Source IS NOT NULL) THEN
                l_Base_Periodicity_Source := l_Base_Periodicity_Source ||
                                             ',' ||
                                             x_Periodicities_Rec_Type.Base_Periodicity_Id;
            ELSE
                l_Base_Periodicity_Source := x_Periodicities_Rec_Type.Base_Periodicity_Id;
            END IF;
            */
            -- Fixed for UTP issue#1
            l_Base_Periodicity_Source := x_Periodicities_Rec_Type.Base_Periodicity_Id;

        END IF;

        x_Periodicities_Rec_Type.Source             := l_Base_Periodicity_Source;

        x_Periodicities_Rec_Type.Num_Of_Subperiods  := BSC_PERIODS_UTILITY_PKG.C_CUST_NUM_OF_SUBPERIODS;
        x_Periodicities_Rec_Type.Period_Col_Name    := BSC_PERIODS_UTILITY_PKG.C_DFLT_PERIOD_COL_NAME;
        x_Periodicities_Rec_Type.Subperiod_Col_Name := NULL;
        x_Periodicities_Rec_Type.Yearly_Flag        := BSC_PERIODS_UTILITY_PKG.C_PERIODICITY_YEARLY_FLAG;
        x_Periodicities_Rec_Type.Edw_Flag           := 0; -- not used anymore
        x_Periodicities_Rec_Type.Edw_Periodicity_Id := NULL; -- not used anymore

        IF(x_Periodicities_Rec_Type.Db_Column_Name IS NULL) THEN
            x_Periodicities_Rec_Type.Db_Column_Name := BSC_PERIODS_UTILITY_PKG.Get_Next_Cust_Period_DB_Column (
                                                            l_Calendar_Id
                                                       );
        END IF;

        x_Periodicities_Rec_Type.Periodicity_Type   := BSC_PERIODS_UTILITY_PKG.C_CUST_PERIODICITY_TYPE;
        x_Periodicities_Rec_Type.Period_Type_Id     := NULL;
        x_Periodicities_Rec_Type.Record_Type_Id     := NULL;
        x_Periodicities_Rec_Type.Xtd_Pattern        := NULL;

    ELSE  -- else these periodicities are of BSC type
        x_Periodicities_Rec_Type.Num_Of_Subperiods  := BSC_PERIODS_UTILITY_PKG.C_CUST_NUM_OF_SUBPERIODS;

        IF (x_Periodicities_Rec_Type.Period_Col_Name IS NULL) THEN
            x_Periodicities_Rec_Type.Period_Col_Name    := BSC_PERIODS_UTILITY_PKG.C_DFLT_PERIOD_COL_NAME;
        END IF;

        x_Periodicities_Rec_Type.Subperiod_Col_Name := NULL;

        IF (x_Periodicities_Rec_Type.Yearly_Flag IS NULL) THEN
            x_Periodicities_Rec_Type.Yearly_Flag        := BSC_PERIODS_UTILITY_PKG.C_PERIODICITY_YEARLY_FLAG;
        END IF;

        x_Periodicities_Rec_Type.Edw_Flag           := 0; -- not used anymore
        x_Periodicities_Rec_Type.Edw_Periodicity_Id := NULL; -- not used anymore

        x_Periodicities_Rec_Type.Period_Type_Id     := NULL;
        x_Periodicities_Rec_Type.Record_Type_Id     := NULL;
        x_Periodicities_Rec_Type.Xtd_Pattern        := NULL;

    END IF;

    IF (x_Periodicities_Rec_Type.Short_Name IS NULL) THEN
         x_Periodicities_Rec_Type.Short_Name := BSC_PERIODS_UTILITY_PKG.generate_Period_Short_Name
                                                                        ( l_Calendar_Id
                                                                        , x_Periodicities_Rec_Type.Periodicity_Id
                                                                        );
    END IF;


    IF (x_Periodicities_Rec_Type.Application_Id IS NULL) THEN
        x_Periodicities_Rec_Type.Application_Id := BSC_PERIODS_UTILITY_PKG.C_BSC_APPLICATION_ID;
    END IF;

    IF (x_Periodicities_Rec_Type.Created_By IS NULL) THEN
        x_Periodicities_Rec_Type.Created_By := FND_GLOBAL.USER_ID;
    END IF;

    IF (x_Periodicities_Rec_Type.Creation_Date IS NULL) THEN
        x_Periodicities_Rec_Type.Creation_Date := SYSDATE;
    END IF;

    IF (x_Periodicities_Rec_Type.Last_Updated_By IS NULL) THEN
        x_Periodicities_Rec_Type.Last_Updated_By := FND_GLOBAL.USER_ID;
    END IF;

    IF (x_Periodicities_Rec_Type.Last_Update_Date IS NULL) THEN
        x_Periodicities_Rec_Type.Last_Update_Date := SYSDATE;
    END IF;

    IF (x_Periodicities_Rec_Type.Last_Update_Login IS NULL) THEN
        x_Periodicities_Rec_Type.Last_Update_Login := FND_GLOBAL.LOGIN_ID;
    END IF;


EXCEPTION
    WHEN OTHERS THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
END Populate_Periodicity_Record;

-- populates the BSC_SYS_PERIODS Metadata.

PROCEDURE Populate_Period_Metadata (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2
 ,p_Action_Type             IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,p_disable_period_val_flag IN          VARCHAR2
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS
    l_Period_Record         BSC_PERIODS_PUB.Period_Record;
    l_Struct_Flag           BOOLEAN;
BEGIN
    SAVEPOINT PopulatePeriodsPUB;
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    l_Period_Record.Periodicity_Id      := p_Periodicities_Rec_Type.Periodicity_Id;
    l_Period_Record.Base_Periodicity_Id := p_Periodicities_Rec_Type.Base_Periodicity_Id;
    l_Period_Record.Calendar_Id         := p_Periodicities_Rec_Type.Calendar_Id;
    l_Period_Record.Periods             := p_Periodicities_Rec_Type.Period_IDs;
    l_Period_Record.No_Of_Periods       := p_Periodicities_Rec_Type.Num_Of_Periods;

    IF (l_Period_Record.Created_By IS NULL) THEN
        l_Period_Record.Created_By := FND_GLOBAL.USER_ID;
    END IF;

    IF (l_Period_Record.Creation_Date IS NULL) THEN
        l_Period_Record.Creation_Date := SYSDATE;
    END IF;

    IF (l_Period_Record.Last_Updated_By IS NULL) THEN
        l_Period_Record.Last_Updated_By := FND_GLOBAL.USER_ID;
    END IF;

    IF (l_Period_Record.Last_Update_Date IS NULL) THEN
        l_Period_Record.Last_Update_Date := SYSDATE;
    END IF;

    IF (l_Period_Record.Last_Update_Login IS NULL) THEN
        l_Period_Record.Last_Update_Login := FND_GLOBAL.LOGIN_ID;
    END IF;

    IF (p_Action_Type = BSC_PERIODS_UTILITY_PKG.C_CREATE) THEN
        BSC_PERIODS_PUB.Create_Periods
        (
          p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
        , p_Commit                  => p_Commit
        , p_Period_Record           => l_Period_Record
        , p_disable_period_val_flag => p_disable_period_val_flag
        , x_Return_Status           => x_Return_Status
        , x_Msg_Count               => x_Msg_Count
        , x_Msg_Data                => x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSIF (p_Action_Type = BSC_PERIODS_UTILITY_PKG.C_UPDATE) THEN
        BSC_PERIODS_PUB.Update_Periods
        (
          p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
        , p_Commit                  => p_Commit
        , p_Period_Record           => l_Period_Record
        , x_Structual_Change        => l_Struct_Flag
        , p_disable_period_val_flag => p_disable_period_val_flag
        , x_Return_Status           => x_Return_Status
        , x_Msg_Count               => x_Msg_Count
        , x_Msg_Data                => x_Msg_Data
        );
        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF (p_Commit IS NOT NULL AND p_Commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO PopulatePeriodsPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO PopulatePeriodsPUB;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO PopulatePeriodsPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PUB.Populate_Period_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PUB.Populate_Period_Metadata ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO PopulatePeriodsPUB;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PUB.Populate_Period_Metadata ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PUB.Populate_Period_Metadata ';
        END IF;
END Populate_Period_Metadata;

-- Public Retrieve API
PROCEDURE Retrieve_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Periodicities_Rec_Type  OUT NOCOPY  BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

    BSC_PERIODICITIES_PVT.Retrieve_Periodicity (
      p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
     ,p_Periodicities_Rec_Type  => p_Periodicities_Rec_Type
     ,x_Periodicities_Rec_Type  => x_Periodicities_Rec_Type
     ,x_Return_Status           => x_Return_Status
     ,x_Msg_Count               => x_Msg_Count
     ,x_Msg_Data                => x_Msg_Data
    );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PUB.Retrieve_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PUB.Retrieve_Periodicity ';
        END IF;
    WHEN OTHERS THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_PERIODICITIES_PUB.Retrieve_Periodicity ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_PERIODICITIES_PUB.Retrieve_Periodicity ';
        END IF;
END Retrieve_Periodicity;
/**********************************************************************************************/
PROCEDURE Update_Annually_Source
( p_Calendar_Id    IN  NUMBER
, p_Periodicity_Id IN  NUMBER
, p_Action         IN  NUMBER
, x_Return_Status  OUT NOCOPY  VARCHAR2
, x_Msg_Count      OUT NOCOPY  NUMBER
, x_Msg_Data       OUT NOCOPY  VARCHAR2
)IS
BEGIN
  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;
  BSC_UPDATE_UTIL.Update_AnualPeriodicity_Src
  ( x_calendar_id     => p_Calendar_Id
  , x_periodicity_id  => p_Periodicity_Id
  , x_action          => p_Action
  );

  IF(BSC_PERIODS_UTILITY_PKG.Check_Error_Message('BSC_UPDATE_UTIL.UpdAnualPeriodicitySrc')) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_ERROR_UPDATE_ANUAL_SOURCE');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
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
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Delete_Calendar_Indexes ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Delete_Calendar_Indexes ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_CALENDAR_PUB.Delete_Calendar_Indexes ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_CALENDAR_PUB.Delete_Calendar_Indexes ';
    END IF;
END Update_Annually_Source;
/*****************************************************************************************/

PROCEDURE Get_Incr_Change (
   p_Periodicity_Id       IN NUMBER
  ,p_Calendar_ID          IN NUMBER
  ,p_Base_Periodicity_Id  IN NUMBER
  ,p_Num_Of_Periods       IN NUMBER
  ,p_Period_Ids           IN VARCHAR2
  ,p_Return_Values        IN VARCHAR2
  ,x_Message_Name         OUT NOCOPY VARCHAR2
  ,x_Objective_List       OUT NOCOPY VARCHAR2
) IS
    l1_Periodicities_Rec_Type    BSC_PERIODICITIES_PUB.Periodicities_Rec_Type;
    l2_Periodicities_Rec_Type    BSC_PERIODICITIES_PUB.Periodicities_Rec_Type;
    l_Period_Record              BSC_PERIODS_PUB.Period_Record;
    l_Structural_Flag            VARCHAR2(1);
    l_Comma_List                 VARCHAR2(12228);
    l_Return_Status              VARCHAR2(1);
    l_Msg_Count                  NUMBER;
    l_Msg_Data                   VARCHAR2(2000);

    CURSOR C_Obj_List IS
      SELECT K.NAME, K.INDICATOR
      FROM   BSc_KPI_PERIODICITIES P
            ,BSC_KPIS_VL K
      WHERE K.INDICATOR = P.INDICATOR
      AND   K.PROTOTYPE_FLAG NOT IN (1, 2, 3)
      AND   P.PERIODICITY_ID = p_Periodicity_Id;

BEGIN

  l1_Periodicities_Rec_Type.Periodicity_Id := p_Periodicity_Id;
  l_Structural_Flag := FND_API.G_FALSE;

  BSC_PERIODICITIES_PUB.Retrieve_Periodicity (
    p_Api_Version             => BSC_PERIODS_UTILITY_PKG.C_API_VERSION_1_0
   ,p_Periodicities_Rec_Type  => l1_Periodicities_Rec_Type
   ,x_Periodicities_Rec_Type  => l2_Periodicities_Rec_Type
   ,x_Return_Status           => l_Return_Status
   ,x_Msg_Count               => l_Msg_Count
   ,x_Msg_Data                => l_Msg_Data
  );

  IF (p_Num_Of_Periods IS NOT NULL) THEN
      IF(l2_Periodicities_Rec_Type.Num_Of_Periods <> p_Num_Of_Periods) THEN
          l_Structural_Flag := FND_API.G_TRUE;
      END IF;
  END IF;

  IF (p_Base_Periodicity_Id IS NOT NULL) THEN
      IF (TO_CHAR(p_Base_Periodicity_Id) <> l2_Periodicities_Rec_Type.Source) THEN
          l_Structural_Flag := FND_API.G_TRUE;
      END IF;
  END IF;

  l_Period_Record.Periodicity_Id := p_Periodicity_Id;
  l_Period_Record.Periods        := p_Period_Ids;

  IF(BSC_PERIODS_PUB.Is_Period_Modified(l_Period_Record) = FND_API.G_TRUE) THEN
    l_Structural_Flag := FND_API.G_TRUE;
  END IF;

  IF(l_Structural_Flag = FND_API.G_TRUE) THEN
    x_Message_Name := 'BSC_PMD_KPI_STRUCT_INVALID';

    IF(p_Return_Values = FND_API.G_TRUE) THEN
        FOR Colst IN C_Obj_List LOOP
          IF(x_Objective_List Is NULL) THEN
            x_Objective_List := Colst.NAME||'['||Colst.INDICATOR||']';
          ELSE
            x_Objective_List := x_Objective_List ||','||Colst.NAME||'['||Colst.INDICATOR||']';
          END IF;
        END LOOP;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_Objective_List := NULL;
    x_Message_Name   := 'BSC_ERROR_ACTION_FLAG_CHANGE';
END Get_Incr_Change;


PROCEDURE Create_Periodicity (
  p_Api_Version             IN          NUMBER
 ,p_Commit                  IN          VARCHAR2
 ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
 ,x_Return_Status           OUT NOCOPY  VARCHAR2
 ,x_Msg_Count               OUT NOCOPY  NUMBER
 ,x_Msg_Data                OUT NOCOPY  VARCHAR2
) IS
 BEGIN

  BSC_PERIODICITIES_PUB.Create_Periodicity (
    p_Api_Version              =>  p_Api_Version
   ,p_Commit                   =>  p_Commit
   ,p_Periodicities_Rec_Type   =>  p_Periodicities_Rec_Type
   ,p_disable_period_val_flag  =>  FND_API.G_FALSE
   ,x_Return_Status            =>  x_Return_Status
   ,x_Msg_Count                =>  x_Msg_Count
   ,x_Msg_Data                 =>  x_Msg_Data
 );

 END  Create_Periodicity;


 PROCEDURE Update_Periodicity (
   p_Api_Version             IN          NUMBER
  ,p_Commit                  IN          VARCHAR2 := FND_API.G_FALSE
  ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
  ,x_Return_Status           OUT NOCOPY  VARCHAR2
  ,x_Msg_Count               OUT NOCOPY  NUMBER
  ,x_Msg_Data                OUT NOCOPY  VARCHAR2
 ) IS
 BEGIN
    BSC_PERIODICITIES_PUB.Update_Periodicity (
      p_Api_Version             =>  p_Api_Version
     ,p_Commit                  =>  p_Commit
     ,p_Periodicities_Rec_Type  =>  p_Periodicities_Rec_Type
     ,p_disable_period_val_flag =>  FND_API.G_FALSE
     ,x_Return_Status           =>  x_Return_Status
     ,x_Msg_Count               =>  x_Msg_Count
     ,x_Msg_Data                =>  x_Msg_Data
 );

END Update_Periodicity;

PROCEDURE Translate_Periodicity (
   p_Api_Version             IN          NUMBER
  ,p_Commit                  IN          VARCHAR2 := FND_API.G_FALSE
  ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
  ,p_disable_period_val_flag IN          VARCHAR2
  ,x_Return_Status           OUT NOCOPY  VARCHAR2
  ,x_Msg_Count               OUT NOCOPY  NUMBER
  ,x_Msg_Data                OUT NOCOPY  VARCHAR2
 ) IS
 BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  UPDATE bsc_sys_periodicities_tl
  SET    name = NVL(p_Periodicities_Rec_Type.name,name)
      ,  source_lang = USERENV('LANG')
  WHERE  USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
  AND    periodicity_id = p_Periodicities_Rec_Type.Periodicity_Id;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Translate_Periodicity;


PROCEDURE Load_Periodicity (
   p_Api_Version             IN          NUMBER
  ,p_Commit                  IN          VARCHAR2 := FND_API.G_FALSE
  ,p_Periodicities_Rec_Type  IN          BSC_PERIODICITIES_PUB.Periodicities_Rec_Type
  ,p_disable_period_val_flag IN          VARCHAR2
  ,x_Return_Status           OUT NOCOPY  VARCHAR2
  ,x_Msg_Count               OUT NOCOPY  NUMBER
  ,x_Msg_Data                OUT NOCOPY  VARCHAR2
 ) IS
  l_count           NUMBER;
  l_name            bsc_sys_periodicities_tl.name%TYPE;
 BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    UPDATE bsc_sys_periodicities
    SET num_of_periods = p_Periodicities_Rec_Type.Num_Of_Periods,
        source = p_Periodicities_Rec_Type.Source,
        num_of_subperiods = p_Periodicities_Rec_Type.Num_Of_Subperiods,
        period_col_name = p_Periodicities_Rec_Type.Period_Col_Name,
        subperiod_col_name = p_Periodicities_Rec_Type.Subperiod_Col_Name,
        yearly_flag = p_Periodicities_Rec_Type.Yearly_Flag,
        edw_flag = p_Periodicities_Rec_Type.Edw_Flag,
        calendar_id = p_Periodicities_Rec_Type.Calendar_Id,
        custom_code = p_Periodicities_Rec_Type.Custom_Code,
        db_column_name = p_Periodicities_Rec_Type.Db_Column_Name,
        periodicity_type = p_Periodicities_Rec_Type.Periodicity_Type
    WHERE periodicity_id = p_Periodicities_Rec_Type.Periodicity_Id;

    IF (SQL%NOTFOUND) THEN
      INSERT INTO bsc_sys_periodicities(
        periodicity_id,
        num_of_periods,
        source,
        num_of_subperiods,
        period_col_name,
        subperiod_col_name,
        yearly_flag,
        edw_flag,
        calendar_id,
        custom_code,
        db_column_name,
        periodicity_type)
      VALUES(
        p_Periodicities_Rec_Type.Periodicity_Id,
        p_Periodicities_Rec_Type.Num_Of_Periods,
        p_Periodicities_Rec_Type.Source,
        p_Periodicities_Rec_Type.Num_Of_Subperiods,
        p_Periodicities_Rec_Type.Period_Col_Name,
        p_Periodicities_Rec_Type.Subperiod_Col_Name,
        p_Periodicities_Rec_Type.Yearly_Flag,
        p_Periodicities_Rec_Type.Edw_Flag,
        p_Periodicities_Rec_Type.Calendar_Id,
        p_Periodicities_Rec_Type.Custom_Code,
        p_Periodicities_Rec_Type.Db_Column_Name,
        p_Periodicities_Rec_Type.Periodicity_Type
      );
    END IF;
    IF (p_Periodicities_Rec_Type.name IS NULL) THEN
      SELECT meaning
      INTO   l_name
      FROM   bsc_lookups
      WHERE  lookup_code=p_Periodicities_Rec_Type.Periodicity_Id
      AND    lookup_type = 'BSC_PERIODICITY';
    ELSE
      l_name := p_Periodicities_Rec_Type.name;

    END IF;

    UPDATE bsc_sys_periodicities_tl
    SET    name = l_name,
           SOURCE_LANG = userenv('LANG')
    WHERE  periodicity_id = p_Periodicities_Rec_Type.Periodicity_Id
    AND    userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

    IF (SQL%NOTFOUND) THEN
      INSERT INTO bsc_sys_periodicities_tl (
        PERIODICITY_ID,
        NAME,
        LANGUAGE,
        SOURCE_LANG,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
      ) SELECT
        p_Periodicities_Rec_Type.Periodicity_Id,
        l_name,
        L.LANGUAGE_CODE,
        USERENV('LANG'),
        FND_GLOBAL.user_id,
        SYSDATE,
        FND_GLOBAL.user_id,
        SYSDATE,
        FND_GLOBAL.user_id
      FROM FND_LANGUAGES L
      WHERE L.INSTALLED_FLAG in ('I', 'B')
      AND NOT EXISTS
        (SELECT NULL
         FROM  bsc_sys_periodicities_tl t
         WHERE periodicity_id = p_Periodicities_Rec_Type.Periodicity_Id
         AND t.LANGUAGE = L.LANGUAGE_CODE);

    END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- If error is set from previous API don't change it.
    IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;
END Load_Periodicity;

END BSC_PERIODICITIES_PUB;

/
