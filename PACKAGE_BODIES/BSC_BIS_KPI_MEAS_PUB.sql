--------------------------------------------------------
--  DDL for Package Body BSC_BIS_KPI_MEAS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIS_KPI_MEAS_PUB" AS
/* $Header: BSCKPMDB.pls 120.15 2007/06/08 08:48:59 akoduri ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCKPMDB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper for Dimension, part of PMD APIs                   |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 20-MAR-2003 PAJOHRI  Created.                                         |
REM | 15-MAY-2003 ADRAO    Added Incremental changes to APIs                |
REM | 24-JUL-2003 ASHANKAR Fix for the bug 3060555                          |
REM | 24-JUL-2003 ADRAO    Fixed Bug #3067265                               |
REM | 25-JUL-2003 ASHANKAR Fix for the bug#3067854                          |
REM | 26-AUG-2003 ADRAO    Fixed for Bug#3112912 modified procedures        |
REM |                      Create_KPI_Analysis_Options & Update_KPI         |
REM | 28-Aug-2003 Adeulgao fixed bug#3108877                                |
REM | 02-Sep-2003 ADRAO    fixed bug#3123858                                |
REM | 10-Sep-2003 ADEULGAO fixed bug#3126401                                |
REM | 11-Sep-2003 ADEULGAO fixed bug#3136397                                |
REM | 11-Sep-2003 ADEULGAO fixed bug#3139925                                |
REM | 13-Sep-2003 mahrao fixed bug#3099977, used p_create_view flag in impo.|
REM | 20-OCT-2003 PAJOHRI  Bug#3180374, and modularization of the code      |
REM | 20-OCT-2003 PAJOHRI  Bug#3179995, added two new procedures            |
REM |                      Delete_Dim_Objs_In_DSet, Create_Dim_Objs_In_DSet |
REM | 20-OCT-2003 PAJOHRI  Bug #3179995                                     |
REM | 04-NOV-2003 PAJOHRI  Bug #3152258                                     |
REM | 14-NOV-2003 PAJOHRI  Bug #3248729                                     |
REM | 08-DEC-2003 KYADAMAK Bug #3225685                                     |
REM | 07-JAN-2004 PAJOHRI  Bug #3343860, created two new procudures         |
REM |          Create_Default_Kpi_Dim_Object & Delete_Default_Kpi_Dim_Object|
REM |          to create and delete default row in BSC_KPI_DIM_LEVELS_VL    |
REM | 16-JAN-2004 PAJOHRI  Bug #3372305                                     |
REM | 29-JAN-2004 PAJOHRI  Bug #3404081                                     |
REM | 15-MAR-2004 PAJOHRI  Bug #3504996, Assign_DSet_Analysis_Options       |
REM |                      procedure is modified, to flag stuct. changes.   |
REM | 30-Mar-2004 ADEULGAO fixed DBI Report Issues                          |
REM |                      added apis 1. Is_Pmv_Viewby_Report()             |
REM |                                 2. is_Abstract_Pmv_Dimension()        |
REM |                      removed condition  IF (l_view_by = 'Y')          |
REM |                      in Get_Default_Viewby_For_Measure()              |
REM | 12-APR-2004 PAJOHRI  Bug #3426566, added conditions to filter those   |
REM |                      Dimension whose Short_Name = 'UNASSIGNED'        |
REM | 13-APR-2004 ASHANKAR BUG#3565772 Modified the fucntions               |
REM |                      Is_Time_In_Dim_Object,Is_Time_With_Measure       |
REM | 16-APR-2004 ASHANKAR BUG#3550054 added the validate_list_button       |
REM |                      function                                         |
REM | 23-APR-2004 ASHANKAR  Bug #3518610,Added the fucntion Validate        |
REM |                       listbutton                                      |
REM | 01-JUN-2004 ADRAO    Fixed for Bug#3663301, initiated an Action Flag  |
REM |                      Change when Default Measure is changed for KPI   |
REM |                      Changed Update_Kpi API                           |
REM | 14-JUN-2004 ADRAO    added Short_Name to Analysis Option for          |
REM |                   Enh#3540302 (ADMINISTRATOR TO ADD KPI TO KPI REGION)|
REM | 17-AUG-2004 WLEUNG   added function Remove_Empty_Dims_For_DimSet      |
REM |                      Bug #3784852                                     |
REM | 29-SEP-2004 ashankar added modules is_Period_Circular,                |
REM |                      Parse_Base_Periods and Find_Period_CircularRef   |
REM |                      for bug#3908204                                  |
REM | 10-OCT-2004 ashankar Moved Parse_Base_Periods to BSC_UTILITY package  |
REM |                      and renamed it to Parse_String to make it Generic|
REM |                      enough.This was done as per the review comment   |
REM | 18-JAN-2005 WLEUNG   bug 4036171 fix Get_Default_Viewby_For_Measure   |
REM | 21-FEB-2005 ankagarw  enh# 3862703                                    |
REM | 11-APR-2005 kyadamak bug#4290070 Not validation views for rolling dims|
REM |  18-Jul-2005 ppandey  Enh #4417483, Restrict Internal/Calendar Dims   |
REM |  22-AUG-2005 ashankar Bug#4220400 Modifed the UPDATE_KPI API          |
REM | 19-SEP-2005 adrao     fixed Bug#4615361 modified API Update_Dim_Set   |
REM | 06-Jan-2006 akoduri   Enh#4739401 - Hide Dimensions/Dim Objects       |
REM | 24-Jan-2006 akoduri   Bug#4958055  Dgrp dimension not getting deleted |
REM |                       while disassociating from objective             |
REM | 15-FEB-2006 akoduri  Bug#4305536  Support new attribute type in       |
REM |                      Objective designer                               |
REM | 11-APR-2006 visuri   Bug#5151997 Report not going in Prototype after  |
REM |                      adding PMF Dim Obj                               |
REM | 19-APR-2006 visuri   Bug#5080308 Commented view by validation         |
REM | 31-Jan-2007 akoduri  Enh #5679096 Migration of multibar functionality |
REM |                      from VB to Html                                  |
REM | 13-APR-2007 ankgoel  Bug#5943068 Impact on common dimension by dim    |
REM |                      reorder in a dim set                             |
REM | 09-Mar-2007 akoduri  Bug#5925299 Key Items are not retained in update |
REM |                      and in reordering of dim objects in dimension set|
REM | 20-APR-2007 vtulasi   Warning and caching issue                       |
REM | 07-JUN-2007 vtulasi   Prototype Flag issue                            |
REM | 06-JUN-2007 akoduri   Bug 5958688 Enable YTD as default at KPI        |
REM +=======================================================================+
*/
--PMV abastract dimension type
TIME_COMP_TYPE   CONSTANT  VARCHAR2(100) := 'TIME_COMPARISON_TYPE';

/*********************************************************************************/
TYPE Dim_Index_Type IS Record
(       p_dim_group_id        BSC_SYS_DIM_GROUPS_TL.Dim_Group_Id%TYPE
    ,   p_dim_short_name      BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE
    ,   p_dim_old_index       BSC_KPI_DIM_GROUPS.Dim_Group_Index%TYPE
);
TYPE Dim_Index_Table_Type IS TABLE OF Dim_Index_Type INDEX BY BINARY_INTEGER;

/*******************************************************************/
FUNCTION Is_Time_In_Dim_Object
(   p_DimObj_ViewBy_Tbl     IN     BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type
  , p_dim_obj_name          IN     VARCHAR2
)RETURN BOOLEAN;
/***********************************************************************/
FUNCTION Is_View_By
(
    p_DimObj_ViewBy_Tbl     IN     BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type
  , p_dim_obj_name          IN     VARCHAR2
)RETURN BOOLEAN;
/*******************************************************************/
FUNCTION Is_Time_With_Measure
(       p_DimObj_ViewBy_Tbl  IN                    BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type
    ,   x_return_status             OUT   NOCOPY   VARCHAR2
    ,   x_msg_count                 OUT   NOCOPY   NUMBER
    ,   x_msg_data                  OUT   NOCOPY   VARCHAR2
)RETURN BOOLEAN;
/*******************************************************************/
PROCEDURE Create_Dim_Grp_Lev_In_Dset
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_dim_short_names       IN              VARCHAR2
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);
/************************************************************************************
--      API name        : Set_Key_Item_Value
--      Type            : Private
--      Function        :
--      This API is used to set the key item values. This API is used in dimension
--      set page to retain the key item values while updating a dimension set
--      or reordering dimension objects within a dimension set.
--      For normal key item setting purpose BSC_DEFAULT_KEY_ITEM_PUB.Set_Key_Item_Value
--      should be used
************************************************************************************/

PROCEDURE Set_Key_Item_Value
(
    p_indicator        IN           BSC_KPIS_B.indicator%TYPE
  , p_dim_set_id       IN           BSC_KPI_DIM_SETS_VL.dim_set_id%TYPE
  , p_level_table_name IN           BSC_SYS_DIM_LEVELS_VL.level_table_name%TYPE
  , p_key_value        IN           BSC_KPI_DIM_LEVEL_PROPERTIES.default_key_value%TYPE
  , x_return_status    OUT  NOCOPY  VARCHAR2
  , x_msg_count        OUT  NOCOPY  NUMBER
  , x_msg_data         OUT  NOCOPY  VARCHAR2
)IS
  l_Dim_Set_Rec BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
  l_dim_level_id bsc_sys_dim_levels_b.dim_level_id%TYPE;
BEGIN
  SELECT
    d.dim_level_id
  INTO
    l_dim_level_id
  FROM
    bsc_kpi_dim_levels_b kd,
    bsc_sys_dim_levels_b d
  WHERE
    kd.indicator = p_indicator
    AND kd.level_table_name = d.level_table_name
    AND kd.dim_set_id = p_dim_set_id
    AND kd.level_table_name = p_level_table_name;

  l_Dim_Set_Rec.Bsc_Kpi_Id  := p_indicator;
  l_Dim_Set_Rec.Bsc_Dim_Set_Id := p_dim_set_id;
  l_Dim_Set_Rec.Bsc_Level_Name := p_level_table_name;
  l_Dim_Set_Rec.Bsc_Level_Id := l_dim_level_id;

  --Update bsc_kpi_dim_levels_b with the default_key_value
  BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Levels (
    p_Dim_Set_Rec    =>  l_Dim_Set_Rec
   ,x_Dim_Set_Rec    =>  l_Dim_Set_Rec
   ,x_return_status  =>  x_return_status
   ,x_msg_count      =>  x_msg_count
   ,x_msg_data       =>  x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_Dim_Set_Rec.Bsc_Dset_Default_Key_Value := p_key_value;
  BSC_DIMENSION_SETS_PUB.Update_Dim_Levels (
    p_commit         =>  FND_API.G_FALSE
   ,p_Dim_Set_Rec    =>  l_Dim_Set_Rec
   ,x_return_status  =>  x_return_status
   ,x_msg_count      =>  x_msg_count
   ,x_msg_data       =>  x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Update bsc_kpi_dim_level_properties with the default_key_value
  BSC_DIMENSION_SETS_PUB.Retrieve_Dim_Level_Properties (
    p_Dim_Set_Rec    =>  l_Dim_Set_Rec
   ,x_Dim_Set_Rec    =>  l_Dim_Set_Rec
   ,x_return_status  =>  x_return_status
   ,x_msg_count      =>  x_msg_count
   ,x_msg_data       =>  x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  l_Dim_Set_Rec.Bsc_Dset_Default_Key_Value := p_key_value;
  BSC_DIMENSION_SETS_PUB.Update_Dim_Level_Properties (
    p_commit         =>  FND_API.G_FALSE
   ,p_Dim_Set_Rec    =>  l_Dim_Set_Rec
   ,x_return_status  =>  x_return_status
   ,x_msg_count      =>  x_msg_count
   ,x_msg_data       =>  x_msg_data
  );
  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     FND_MSG_PUB.Count_And_Get
     (      p_encoded   =>  FND_API.G_FALSE
        ,   p_count     =>  x_msg_count
        ,   p_data      =>  x_msg_data
     );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Set_Key_Item_Value ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Set_Key_Item_Value ';
     END IF;
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF (x_msg_data IS NOT NULL) THEN
         x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Set_Key_Item_Value ';
     ELSE
         x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Set_Key_Item_Value ';
     END IF;
END  Set_Key_Item_Value;


/*****************************************************************
Name :- get_KPI_Type
Description :- This function will return the Type of indicator
Creaor :-Ashankar
/*****************************************************************/
FUNCTION get_KPI_Type
(       p_Kpi_ID                IN          NUMBER
) RETURN NUMBER IS
    l_Indic_Type          BSC_KPIS_B.Indicator_Type%TYPE;
BEGIN
   SELECT Indicator_Type
   INTO   l_Indic_Type
   FROM   BSC_KPIS_B
   WHERE  Indicator = p_Kpi_ID;

   RETURN l_Indic_Type;
END get_KPI_Type;
/*************************************************************************/
/*****************************************************************/
PROCEDURE Get_Valid_Analysis_Option_Ids
(       p_Kpi_Id                    IN      NUMBER
    ,   p_Analysis_Group_ID         IN      NUMBER
    ,   p_Option_ID                 IN      NUMBER
    ,   p_Parent_Option_ID          IN      NUMBER
    ,   p_GrandParent_Option_ID     IN      NUMBER
    ,   x_Parent_Option_ID          OUT   NOCOPY  NUMBER
    ,   x_GrandParent_Option_ID     OUT   NOCOPY  NUMBER
    ,   x_return_status             OUT   NOCOPY  VARCHAR2
    ,   x_msg_count                 OUT   NOCOPY  NUMBER
    ,   x_msg_data                  OUT   NOCOPY  VARCHAR2
) IS
    l_Count NUMBER   := -1;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Get_Valid_Analysis_Option_Ids Procedure');
    x_Parent_Option_ID      :=  p_Parent_Option_ID;
    x_GrandParent_Option_ID :=  p_GrandParent_Option_ID;

    IF (x_Parent_Option_ID IS NULL) THEN
        x_Parent_Option_ID      := 0;
    END IF;
    IF (x_GrandParent_Option_ID IS NULL) THEN
        x_GrandParent_Option_ID := 0;
    END IF;
    IF (p_Analysis_Group_ID = 1) THEN
        l_Count := 0;
        WHILE (l_Count = 0) LOOP
            SELECT COUNT(*) INTO l_Count
            FROM   BSC_KPI_ANALYSIS_OPTIONS_B
            WHERE  Indicator                = p_Kpi_Id
            AND    Analysis_Group_Id        = p_Analysis_Group_ID
            AND    Option_Id                = p_Option_ID
            AND    Parent_Option_Id         = x_Parent_Option_ID;
            IF (l_Count = 0) THEN
                IF (x_Parent_Option_ID <> 0) THEN
                    x_Parent_Option_ID := 0;
                ELSE
                    l_Count := -1;
                    EXIT;
                END IF;
            END IF;
        END LOOP;
    ELSIF (p_Analysis_Group_ID = 2) THEN
        l_Count := 0;
        WHILE (l_Count = 0) LOOP
            SELECT COUNT(*) INTO l_Count
            FROM   BSC_KPI_ANALYSIS_OPTIONS_B
            WHERE  Indicator                = p_Kpi_Id
            AND    Analysis_Group_Id        = p_Analysis_Group_ID
            AND    Option_Id                = p_Option_ID
            AND    Parent_Option_Id         = x_Parent_Option_ID
            AND    Grandparent_Option_Id    = x_GrandParent_Option_ID;
            IF (l_Count = 0) THEN
                IF (x_GrandParent_Option_ID <> 0) THEN
                    x_GrandParent_Option_ID := 0;
                ELSIF (x_Parent_Option_ID <> 0) THEN
                    x_Parent_Option_ID      := 0;
                ELSE
                    l_Count := -1;
                    EXIT;
                END IF;
            END IF;
        END LOOP;
    END IF;
    IF (l_Count = -1) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_V_NO_ANLSIS_DEF_FOR_COMB');
        FND_MESSAGE.SET_TOKEN('ANLSIS_OPT1', p_Option_ID);
        FND_MESSAGE.SET_TOKEN('ANLSIS_OPT2', p_Parent_Option_ID);
        FND_MESSAGE.SET_TOKEN('ANLSIS_OPT3', p_GrandParent_Option_ID);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Get_Default_Viewby_For_Measure Procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Get_Valid_Analysis_Option_Ids ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Get_Valid_Analysis_Option_Ids ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Get_Valid_Analysis_Option_Ids;
/************************************************************************************/
PROCEDURE store_kpi_anal_group
(     p_kpi_id        IN            NUMBER
  ,   x_Anal_Opt_Tbl  IN OUT NOCOPY BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type
) IS
    CURSOR   c_kpi_anal_group IS
    SELECT   Analysis_Group_Id
         ,   Num_Of_Options
         ,   Dependency_Flag
    FROM     BSC_KPI_ANALYSIS_GROUPS
    WHERE    Indicator = p_kpi_id
    ORDER BY Analysis_Group_Id;

    l_Count NUMBER := 0;
BEGIN
     FOR cd IN c_kpi_anal_group LOOP
          x_Anal_Opt_Tbl(l_count).Bsc_analysis_group_id := cd.analysis_group_id;
          x_Anal_Opt_Tbl(l_count).Bsc_no_option_id      := cd.num_of_options;
          x_Anal_Opt_Tbl(l_count).Bsc_dependency_flag   := cd.dependency_flag;
          l_count := l_count +1;
     END LOOP;
END store_kpi_anal_group;
/*******************************************************************/
PROCEDURE Create_Default_Kpi_Dim_Object
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    l_Count                     NUMBER;
    l_bsc_dimset_rec            BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  p_kpi_id
    AND     Prototype_Flag   <>  2;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Create_Default_Kpi_Dim_Object procedure');
    SAVEPOINT CreateBSCDefDimObjectsPMD;

    l_bsc_dimset_rec.Bsc_Kpi_Id         :=  p_kpi_id;
    l_bsc_dimset_rec.Bsc_Dim_Set_Id     :=  p_dim_set_id;

    SELECT COUNT(*) INTO l_Count
    FROM   BSC_KPI_DIM_LEVELS_B
    WHERE  Indicator  =  l_bsc_dimset_rec.Bsc_Kpi_Id
    AND    Dim_Set_Id =  l_bsc_dimset_rec.Bsc_Dim_Set_Id;
    IF (l_Count = 0) THEN
        -- Bug #3343860 if l_Count = 0, it means create default entry in BSC_KPI_DIM_LEVELS_B
        BSC_BIS_KPI_MEAS_PUB.Create_Dim_Grp_Lev_In_Dset
        (       p_commit                =>   FND_API.G_FALSE
            ,   p_kpi_id                =>   l_bsc_dimset_rec.Bsc_Kpi_Id
            ,   p_dim_set_id            =>   l_bsc_dimset_rec.Bsc_Dim_Set_Id
            ,   p_dim_short_names       =>   NULL
            ,   x_return_status         =>   x_return_status
            ,   x_msg_count             =>   x_msg_count
            ,   x_msg_data              =>   x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Default_Kpi_Dim_Object Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Grp_Lev_In_Dset');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --repeat the same steps for all the shared indicators
        FOR cd IN c_kpi_ids LOOP
            l_bsc_dimset_rec.Bsc_Kpi_Id :=  cd.indicator;
            BSC_BIS_KPI_MEAS_PUB.Create_Dim_Grp_Lev_In_Dset
            (       p_commit                =>   FND_API.G_FALSE
                ,   p_kpi_id                =>   l_bsc_dimset_rec.Bsc_Kpi_Id
                ,   p_dim_set_id            =>   l_bsc_dimset_rec.Bsc_Dim_Set_Id
                ,   p_dim_short_names       =>   NULL
                ,   x_return_status         =>   x_return_status
                ,   x_msg_count             =>   x_msg_count
                ,   x_msg_data              =>   x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Default_Kpi_Dim_Object Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Grp_Lev_In_Dset');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END LOOP;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Create_Default_Kpi_Dim_Object procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCDefDimObjectsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCDefDimObjectsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCDefDimObjectsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Create_Default_Kpi_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Create_Default_Kpi_Dim_Object ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCDefDimObjectsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Create_Default_Kpi_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Create_Default_Kpi_Dim_Object ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Create_Default_Kpi_Dim_Object;
/*******************************************************************/
PROCEDURE Delete_Default_Kpi_Dim_Object
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    l_Count                     NUMBER;
    l_bsc_dimset_rec            BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  p_kpi_id
    AND     Prototype_Flag   <>  2;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Delete_Default_Kpi_Dim_Object procedure');
    SAVEPOINT CreateBSCDefDimObjectsPMD;

    l_bsc_dimset_rec.Bsc_Kpi_Id         :=  p_kpi_id;
    l_bsc_dimset_rec.Bsc_Dim_Set_Id     :=  p_dim_set_id;

    --remove the default entry 'XXX' from BSC_KPI_DIM_LEVELS_B if exists
    BSC_DIMENSION_SETS_PUB.Delete_Dim_Levels
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_Dim_Set_Rec           =>  l_bsc_dimset_rec
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Default_Kpi_Dim_Object Failed: at BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Group_In_Dset');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --repeat the same steps for all the shared indicators
    FOR cd IN c_kpi_ids LOOP
        l_bsc_dimset_rec.Bsc_Kpi_Id :=  cd.indicator;
        BSC_DIMENSION_SETS_PUB.Delete_Dim_Levels
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_Dim_Set_Rec           =>  l_bsc_dimset_rec
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Default_Kpi_Dim_Object Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Grp_Lev_In_Dset');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Delete_Default_Kpi_Dim_Object procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCDefDimObjectsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCDefDimObjectsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCDefDimObjectsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Delete_Default_Kpi_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Delete_Default_Kpi_Dim_Object ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCDefDimObjectsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Delete_Default_Kpi_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Delete_Default_Kpi_Dim_Object ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Default_Kpi_Dim_Object;
/*******************************************************************
    PROCEUDRE to Orders Dimensions in Dimension Sets
 *******************************************************************/
PROCEDURE Order_Dims_In_DSets
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_dim_short_names       IN              VARCHAR2
    ,   p_kpi_flag_change       IN              BOOLEAN
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    l_current_index             NUMBER;
    l_dim_index                 NUMBER;
    l_count1                    NUMBER;
    l_tab_index                 NUMBER;
    l_count_new                 NUMBER;
    l_count_old                 NUMBER := 0;
    l_MTab_New_Count            NUMBER;
    l_flag                      BOOLEAN;
    l_refresh                   BOOLEAN := FALSE;
    l_assigns                   VARCHAR2(32000);
    l_assign                    BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
    l_MTab_DimInx_Old           BSC_BIS_KPI_MEAS_PUB.Dim_Index_Table_Type;
    l_MTab_DimInx_New           BSC_BIS_KPI_MEAS_PUB.Dim_Index_Table_Type;
    l_bsc_dimset_rec            BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;

    CURSOR   c_dim_index IS
    SELECT   A.Dim_Group_Id
          ,  A.Dim_Group_Index
          ,  B.Short_Name
    FROM     BSC_KPI_DIM_GROUPS     A
          ,  BSC_SYS_DIM_GROUPS_VL  B
    WHERE    A.Indicator    =  p_kpi_id
    AND      A.Dim_Set_Id   =  p_dim_set_id
    AND      A.Dim_Group_ID =  B.Dim_Group_ID
    ORDER BY A.Dim_Group_Index;

    --get shared indicators also
    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  p_kpi_id
    AND     Prototype_Flag   <>  2;
BEGIN
    SAVEPOINT OrderBSCDimsInDSetPMD;
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_bsc_dimset_rec.Bsc_Kpi_Id      :=  p_kpi_id;
    l_bsc_dimset_rec.Bsc_Dim_Set_Id  :=  p_dim_set_id;

    FOR cd IN c_dim_index LOOP
        l_flag       :=  TRUE;
        l_assigns    :=  p_dim_short_names;
        l_count_new  :=  0;
        WHILE (is_more(p_dim_short_names   =>  l_assigns
                     , p_dim_short_name    =>  l_assign)
        ) LOOP
            IF(cd.Short_Name = l_assign) THEN
                l_flag  :=  FALSE;
                l_MTab_DimInx_New(l_count_new).p_dim_group_id   :=  cd.Dim_Group_ID;
                l_MTab_DimInx_New(l_count_new).p_dim_short_name :=  cd.Short_Name;
                l_MTab_DimInx_New(l_count_new).p_dim_old_index  :=  cd.Dim_Group_Index;
                EXIT;
            END IF;
            l_count_new  :=  l_count_new + 1;
        END LOOP;
        IF(l_flag) THEN
            l_MTab_DimInx_Old(l_count_old).p_dim_group_id       :=  cd.Dim_Group_ID;
            l_MTab_DimInx_Old(l_count_old).p_dim_short_name     :=  cd.Short_Name;
            l_MTab_DimInx_Old(l_count_old).p_dim_old_index      :=  cd.Dim_Group_Index;
            l_count_old  :=  l_count_old + 1;
        END IF;
    END LOOP;
    l_current_index :=  0;
    FOR i IN 0..(l_MTab_DimInx_Old.COUNT-1) LOOP
        IF (l_current_index <> l_MTab_DimInx_Old(i).p_dim_old_index) THEN
            l_refresh                                   :=  TRUE;
            l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id     :=  l_MTab_DimInx_Old(i).p_dim_group_id;
            l_bsc_dimset_rec.Bsc_Dim_Level_Group_Index  :=  l_current_index;
            l_bsc_dimset_rec.Bsc_Kpi_Id                 :=  p_kpi_id;
            l_bsc_dimset_rec.Bsc_Dim_Set_Id             :=  p_dim_set_id;
            BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset
            (       p_commit              =>    FND_API.G_FALSE
                ,   p_Dim_Set_Rec         =>    l_bsc_dimset_rec
                ,   p_create_Dim_Lev_Grp  =>    FALSE
                ,   x_return_status       =>    x_return_status
                ,   x_msg_count           =>    x_msg_count
                ,   x_msg_data            =>    x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets Failed: at BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset');
                RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            --for shared KPIs
            FOR cd IN c_kpi_ids LOOP
                l_bsc_dimset_rec.Bsc_Kpi_Id   :=  cd.Indicator;
                BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset
                (       p_commit              =>    FND_API.G_FALSE
                    ,   p_Dim_Set_Rec         =>    l_bsc_dimset_rec
                    ,   p_create_Dim_Lev_Grp  =>    FALSE
                    ,   x_return_status       =>    x_return_status
                    ,   x_msg_count           =>    x_msg_count
                    ,   x_msg_data            =>    x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets Failed: at BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset');
                    RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END LOOP;
        END IF;
        l_current_index :=  l_current_index + 1;
    END LOOP;
    l_MTab_New_Count    :=  l_MTab_DimInx_New.COUNT -1;
    l_tab_index         :=  0;
    WHILE (l_tab_index <= l_MTab_New_Count) LOOP
        IF (l_MTab_DimInx_New.EXISTS(l_tab_index)) THEN
            IF (l_current_index <> l_MTab_DimInx_New(l_tab_index).p_dim_old_index) THEN
                l_refresh                                   :=  TRUE;
                l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id     :=  l_MTab_DimInx_New(l_tab_index).p_dim_group_id;
                l_bsc_dimset_rec.Bsc_Dim_Level_Group_Index  :=  l_current_index;
                l_bsc_dimset_rec.Bsc_Kpi_Id                 :=  p_kpi_id;
                l_bsc_dimset_rec.Bsc_Dim_Set_Id             :=  p_dim_set_id;
                BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset
                (       p_commit              =>    FND_API.G_FALSE
                    ,   p_Dim_Set_Rec         =>    l_bsc_dimset_rec
                    ,   p_create_Dim_Lev_Grp  =>    FALSE
                    ,   x_return_status       =>    x_return_status
                    ,   x_msg_count           =>    x_msg_count
                    ,   x_msg_data            =>    x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets Failed: at BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset');
                    RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                --for shared KPIs
                FOR cd IN c_kpi_ids LOOP
                    l_bsc_dimset_rec.Bsc_Kpi_Id   :=  cd.Indicator;
                    BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset
                    (       p_commit              =>    FND_API.G_FALSE
                        ,   p_Dim_Set_Rec         =>    l_bsc_dimset_rec
                        ,   p_create_Dim_Lev_Grp  =>    FALSE
                        ,   x_return_status       =>    x_return_status
                        ,   x_msg_count           =>    x_msg_count
                        ,   x_msg_data            =>    x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets Failed: at BSC_DIMENSION_SETS_PUB.Update_Dim_Group_In_Dset');
                        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END LOOP;
            END IF;
            l_current_index :=  l_current_index + 1;
        END IF;
        l_tab_index := l_tab_index + 1;
    END LOOP;
    IF ((p_kpi_flag_change) OR (l_refresh)) THEN
        --dbms_output.PUT_LINE('p_kpi_flag_change is TRUE, it means flag structural changes also');
        BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet
        (       p_commit                =>    FND_API.G_FALSE
            ,   p_kpi_id                =>    p_kpi_id
            ,   p_dim_set_id            =>    p_dim_set_id
            ,   p_delete                =>    TRUE
            ,   x_return_status         =>    x_return_status
            ,   x_msg_count             =>    x_msg_count
            ,   x_msg_data              =>    x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets Failed: at BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet');
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
   /* ELSIF (l_refresh) THEN
        --dbms_output.PUT_LINE('Refresh is TRUE');
        BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet
        (       p_commit                =>    FND_API.G_FALSE
            ,   p_kpi_id                =>    p_kpi_id
            ,   p_dim_set_id            =>    p_dim_set_id
            ,   p_kpi_flag_change       =>    BSC_DESIGNER_PVT.G_ActionFlag.Normal
            ,   p_delete                =>    TRUE
            ,   x_return_status         =>    x_return_status
            ,   x_msg_count             =>    x_msg_count
            ,   x_msg_data              =>    x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets Failed: at BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet');
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF; */
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO OrderBSCDimsInDSetPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO OrderBSCDimsInDSetPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO OrderBSCDimsInDSetPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO OrderBSCDimsInDSetPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Order_Dims_In_DSets;

-- function to get if report is view by or no
FUNCTION Is_Pmv_Viewby_Report
(
    p_Measure_Short_Name  IN OUT  NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
  l_view_applicable       BOOLEAN     := FALSE;
  l_view_disabled         VARCHAR2(1);
  l_function_code         VARCHAR2(100);
  l_Region_Code           VARCHAR2(100);

  CURSOR c_Report_ViewBy(c_region_code VARCHAR2) IS
  SELECT Attribute1
  FROM   AK_REGIONS
  WHERE  Region_Code = c_region_code;
BEGIN
  BSC_JV_PMF.get_Pmf_Measure
  (       p_Measure_ShortName   =>    p_Measure_Short_Name
      ,   x_function_name       =>    l_function_code
      ,   x_region_code         =>    l_Region_Code
  );
  IF (c_Report_ViewBy%ISOPEN) THEN
    CLOSE c_Report_ViewBy;
  END IF;

  OPEN c_Report_ViewBy(l_Region_Code);
    FETCH c_Report_ViewBy INTO l_view_disabled;
  CLOSE c_Report_ViewBy;

  --dbms_output.PUT_LINE('l_view_disabled -' || l_view_disabled);
  IF ((l_view_disabled IS NULL) OR (l_view_disabled = 'N')) THEN
    l_view_applicable := TRUE;
  ELSE
    l_view_applicable := FALSE;
  END IF;

  RETURN l_view_applicable;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_Report_ViewBy%ISOPEN) THEN
          CLOSE c_Report_ViewBy;
        END IF;
    RAISE;
END Is_Pmv_Viewby_Report;

/*******************************************************************
    Adeulgao changed this
***************************************************************/
FUNCTION Is_More
(       x_dim_objects    IN  OUT     NOCOPY  VARCHAR2
    ,   x_View_Bys       IN  OUT     NOCOPY  VARCHAR2
    ,   x_dim_object         OUT     NOCOPY  VARCHAR2
    ,   x_View_By            OUT     NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
BEGIN
    IF (x_dim_objects IS NOT NULL) THEN
        l_pos_ids           := INSTR(x_dim_objects,   ',');
        l_pos_rel_types     := INSTR(x_View_Bys,      ',');
        IF (l_pos_ids > 0) THEN
            x_dim_object    :=  TRIM(SUBSTR(x_dim_objects,  1,    l_pos_ids - 1));
            x_View_By       :=  TRIM(SUBSTR(x_View_Bys,     1,    l_pos_rel_types   - 1));

            x_dim_objects   :=  TRIM(SUBSTR(x_dim_objects,   l_pos_ids + 1));
            x_View_Bys      :=  TRIM(SUBSTR(x_View_Bys,      l_pos_rel_types + 1));
        ELSE
            x_dim_object    :=  TRIM(x_dim_objects);
            x_View_By       :=  TRIM(x_View_Bys);

            x_dim_objects   :=  NULL;
            x_View_Bys      :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;
/*******************************************************************
    This API gets all the defualt level and views for a measure
    from the table fetched from get_DimObj_ViewBy_Tbl API
    this is called from both create and update KPI Analysis options
 *******************************************************************/
PROCEDURE Get_Default_Viewby_For_Measure
(       p_DimObj_ViewBy_Tbl     IN          BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type
    ,   x_dim_objects           OUT NOCOPY  VARCHAR
    ,   x_defaults              OUT NOCOPY  VARCHAR
    ,   x_view_bys              OUT NOCOPY  VARCHAR
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
)IS
    l_default_level_set     BOOLEAN := FALSE;
    l_default               VARCHAR2(100);
    l_view_by               VARCHAR2(100);
    l_DimObj_ViewBy_Tbl     BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Get_Default_Viewby_For_Measure Procedure');
    l_DimObj_ViewBy_Tbl    :=   p_DimObj_ViewBy_Tbl;

    FOR i IN 0..(p_DimObj_ViewBy_Tbl.COUNT-1) LOOP
    IF (x_dim_objects IS NULL) THEN -- bug 4036171 fix the way to contruct x_dim_objects
            x_dim_objects   :=  l_DimObj_ViewBy_Tbl(i).p_Dim_Object_Names;
        ELSE
            x_dim_objects   :=  x_dim_objects||', '||l_DimObj_ViewBy_Tbl(i).p_Dim_Object_Names;
        END IF;

        l_default_level_set := FALSE;
        WHILE (is_more(   x_dim_objects   =>  l_DimObj_ViewBy_Tbl(i).p_Dim_Object_Names
                      ,   x_View_Bys      =>  l_DimObj_ViewBy_Tbl(i).p_View_By_There
                      ,   x_dim_object    =>  l_default
                      ,   x_View_By       =>  l_view_by
        )) LOOP
            --dbms_output.PUT_LINE('***  l_default  <'||l_default||'>');
            --dbms_output.PUT_LINE('***  l_view_by  <'||l_view_by||'>');
            IF (NOT l_default_level_set) THEN
                IF (x_defaults IS NULL) THEN
                    x_defaults  := l_default;
                ELSE
                    x_defaults  := x_defaults||', '||l_default;
                END IF;
                    l_default_level_set := TRUE;
                END IF;
                IF ((x_view_bys IS NULL) AND (l_view_by = 'Y')) THEN
                    x_view_bys  :=  l_default;
                EXIT;
            END IF;
        END LOOP;
    END LOOP;
    --dbms_output.PUT_LINE('***  l_view_by  <'||x_view_bys||'>');
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Get_Default_Viewby_For_Measure Procedure');
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.get_Default_ViewBy_For_Measure ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.get_Default_ViewBy_For_Measure ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Get_Default_Viewby_For_Measure;

/*******************************************************************/

FUNCTION is_Abstract_Pmv_Dimension
(   p_dimension IN VARCHAR2
) RETURN BOOLEAN IS
BEGIN
    -- TIME_COMPARISON_TYPE is special dimension
    -- if dimension is null then the parameter is AS_OF_DATE
    -- we should not be returning these in the PMV table, as we do not have this in the table
    IF ((p_dimension IS NULL) OR (UPPER(TRIM(p_dimension)) = BSC_BIS_KPI_MEAS_PUB.Time_Comp_Type)) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END is_Abstract_Pmv_Dimension;

/*******************************************************************/

PROCEDURE get_DimObj_ViewBy_Tbl
(       p_Measure_Short_Name   IN             VARCHAR2
    ,   p_Region_Code          IN             VARCHAR2
    ,   x_DimObj_ViewBy_Tbl    OUT   NOCOPY   BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type
    ,   x_return_status        OUT   NOCOPY   VARCHAR2
    ,   x_msg_count            OUT   NOCOPY   NUMBER
    ,   x_msg_data             OUT   NOCOPY   VARCHAR2
) IS
    l_Region_Code               VARCHAR2(30);
    l_Function_Code             VARCHAR2(30);
    l_DimObj_ViewBy_Tbl         BIS_PMV_BSC_API_PUB.DimLevel_Viewby_Tbl_Type;
    l_count                     NUMBER := 0;
    l_table_index               NUMBER := 0;

    l_dimension                 VARCHAR2(100);
    l_dim_object                VARCHAR2(100);
    l_flag                      BOOLEAN;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.get_DimObj_ViewBy_Tbl Procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_Region_Code   :=  p_Region_Code;
    IF (p_Region_Code IS NULL) THEN
        BSC_JV_PMF.get_Pmf_Measure
        (       p_Measure_ShortName   =>    p_Measure_Short_Name
            ,   x_function_name       =>    l_function_code
            ,   x_region_code         =>    l_Region_Code
        );
        IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.get_Dimensions_In_Meas Failed: at BSC_JV_PMF.get_Pmf_Measure');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    BIS_PMV_BSC_API_PUB.Get_Dimlevel_Viewby
    (       p_api_version           =>  1
        ,   p_Region_Code           =>  l_Region_Code
        ,   p_Measure_Short_Name    =>  p_measure_short_name
        ,   x_DimLevel_Viewby_Tbl   =>  l_DimObj_ViewBy_Tbl
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF ((x_return_status IS NOT NULL) AND (x_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.get_DimObj_ViewBy_Tbl Failed: at BIS_PMV_BSC_API_PUB.Get_Dimlevel_Viewby');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    FOR i IN 1..l_DimObj_ViewBy_Tbl.COUNT LOOP
        l_flag          :=  TRUE;
        l_dimension     :=  TRIM(SUBSTR(l_DimObj_ViewBy_Tbl(i).Dim_DimLevel, 1, (INSTR(l_DimObj_ViewBy_Tbl(i).Dim_DimLevel, '+') - 1)));

        IF (NOT BSC_BIS_KPI_MEAS_PUB.is_Abstract_Pmv_Dimension(l_dimension)) THEN
            l_table_index   := 0;
            WHILE ( l_table_index < x_DimObj_ViewBy_Tbl.COUNT) LOOP
                IF (l_dimension = x_DimObj_ViewBy_Tbl(l_table_index).p_Dimension_Name) THEN
                    l_flag := FALSE;
                    EXIT;
                END IF;
                l_table_index := l_table_index+1;
            END LOOP;
            IF (l_flag) THEN
                l_table_index   := x_DimObj_ViewBy_Tbl.COUNT;
                IF (l_table_index > 6) THEN
                    EXIT;
                END IF;
                x_DimObj_ViewBy_Tbl(l_table_index).p_Measure_Short_Name:= p_Measure_Short_Name;
                x_DimObj_ViewBy_Tbl(l_table_index).p_Region_Code       := l_Region_Code;
                x_DimObj_ViewBy_Tbl(l_table_index).p_Function_Code     := l_function_code;
                x_DimObj_ViewBy_Tbl(l_table_index).p_Measure_Short_Name:= p_Measure_Short_Name;
                x_DimObj_ViewBy_Tbl(l_table_index).p_Dimension_Name    := l_dimension;
                x_DimObj_ViewBy_Tbl(l_table_index).p_Is_Time_There     := FALSE;
                x_DimObj_ViewBy_Tbl(l_table_index).p_Dim_Object_Names  := SUBSTR(l_DimObj_ViewBy_Tbl(i).Dim_DimLevel, (INSTR(l_DimObj_ViewBy_Tbl(i).Dim_DimLevel, '+')+1));
                x_DimObj_ViewBy_Tbl(l_table_index).p_View_By_There     := l_DimObj_ViewBy_Tbl(i).Viewby_Applicable;
                x_DimObj_ViewBy_Tbl(l_table_index).p_All_There         := l_DimObj_ViewBy_Tbl(i).All_Applicable;
            ELSE
                x_DimObj_ViewBy_Tbl(l_table_index).p_Dim_Object_Names  := x_DimObj_ViewBy_Tbl(l_table_index).p_Dim_Object_Names||', '||
                                   SUBSTR(l_DimObj_ViewBy_Tbl(i).Dim_DimLevel, (INSTR(l_DimObj_ViewBy_Tbl(i).Dim_DimLevel, '+')+1));
                x_DimObj_ViewBy_Tbl(l_table_index).p_View_By_There     := x_DimObj_ViewBy_Tbl(l_table_index).p_View_By_There||', '||
                                                                          l_DimObj_ViewBy_Tbl(i).Viewby_Applicable;
                x_DimObj_ViewBy_Tbl(l_table_index).p_All_There         := x_DimObj_ViewBy_Tbl(l_table_index).p_All_There||', '||
                                                                          l_DimObj_ViewBy_Tbl(i).All_Applicable;
            END IF;
            IF ((NOT x_DimObj_ViewBy_Tbl(l_table_index).p_Is_Time_There) AND
                 (INSTR(x_DimObj_ViewBy_Tbl(l_table_index).p_Dimension_Name , 'TIME') > 0)) THEN
                x_DimObj_ViewBy_Tbl(l_table_index).p_Is_Time_There     := TRUE;
            END IF;
        END IF;
    END LOOP;
    /*--dbms_output.PUT_LINE('  ---  INITIAL TABLE  ---- '||x_DimObj_ViewBy_Tbl.COUNT);
    FOR i IN 0..(x_DimObj_ViewBy_Tbl.COUNT-1) LOOP
        --dbms_output.PUT_LINE('x_DimObj_ViewBy_Tbl('||i||').p_Measure_Short_Name '||x_DimObj_ViewBy_Tbl(i).p_Measure_Short_Name);
        --dbms_output.PUT_LINE('x_DimObj_ViewBy_Tbl('||i||').p_Region_Code        '||x_DimObj_ViewBy_Tbl(i).p_Region_Code);
        --dbms_output.PUT_LINE('x_DimObj_ViewBy_Tbl('||i||').p_Function_Code      '||x_DimObj_ViewBy_Tbl(i).p_Function_Code);
        --dbms_output.PUT_LINE('x_DimObj_ViewBy_Tbl('||i||').p_Dimension_Name     '||x_DimObj_ViewBy_Tbl(i).p_Dimension_Name);
        --dbms_output.PUT_LINE('x_DimObj_ViewBy_Tbl('||i||').p_Dim_Object_Names   '||x_DimObj_ViewBy_Tbl(i).p_Dim_Object_Names);
        --dbms_output.PUT_LINE('x_DimObj_ViewBy_Tbl('||i||').p_Dim_Object_Names   '||x_DimObj_ViewBy_Tbl(i).p_Dim_Object_Names);
        --dbms_output.PUT_LINE('x_DimObj_ViewBy_Tbl('||i||').p_View_By_There      '||x_DimObj_ViewBy_Tbl(i).p_View_By_There);
        --dbms_output.PUT_LINE('x_DimObj_ViewBy_Tbl('||i||').p_All_There          '||x_DimObj_ViewBy_Tbl(i).p_All_There);
        IF (x_DimObj_ViewBy_Tbl(i).p_Is_Time_There) THEN
            --dbms_output.PUT_LINE('x_DimObj_ViewBy_Tbl('||i||').p_Is_Time_There TRUE');
        ELSE
            --dbms_output.PUT_LINE('x_DimObj_ViewBy_Tbl('||i||').p_Is_Time_There FALSE');
        END IF;
    END LOOP;*/
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.get_DimObj_ViewBy_Tbl Procedure');
EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data  :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.get_DimObj_ViewBy_Tbl ';
        ELSE
            x_msg_data  :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.get_DimObj_ViewBy_Tbl ';
        END IF;
END get_DimObj_ViewBy_Tbl;
/*******************************************************************/
FUNCTION get_Next_Alias
(
    p_Alias        IN   VARCHAR2
) RETURN VARCHAR2
IS
    l_alias     VARCHAR2(3);
    l_return    VARCHAR2(3);
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
/*******************************************************************
    PROCEUDRE TO REMOVE THE UNUSED PMF DIMENSION
 *******************************************************************/
PROCEDURE Remove_Unused_PMF_Dimenison
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_Kpi_Id                IN          NUMBER
    ,   p_dim_set_id            IN          NUMBER
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
    l_dimension_id          BSC_SYS_DIM_GROUPS_TL.Dim_Group_Id%TYPE;
    l_flag                  BOOLEAN;
    l_temp_var              VARCHAR2(32000);

    CURSOR  c_dim_set_ind IS
    SELECT  DISTINCT dim_group_id
    FROM    BSC_KPI_DIM_GROUPS
    WHERE   Dim_Set_Id   =  p_dim_set_id
    AND     Indicator    =  p_Kpi_Id;

    CURSOR  cr_bsc_dim IS
    SELECT  C.Source                    Source
    FROM    BSC_SYS_DIM_GROUPS_VL       A
         ,  BSC_SYS_DIM_LEVELS_BY_GROUP B
         ,  BSC_SYS_DIM_LEVELS_B        C
    WHERE   A.Dim_Group_ID    =   B.Dim_Group_ID
    AND     C.Dim_Level_ID    =   B.Dim_Level_ID
    AND     A.Short_Name     <>   BSC_BIS_DIMENSION_PUB.Unassigned_Dim
    AND     A.Dim_Group_ID    =   l_dimension_id;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Remove_Unused_PMF_Dimenison procedure');
    FND_MSG_PUB.Initialize;
    x_return_status         :=  FND_API.G_RET_STS_SUCCESS;
    IF (p_dim_set_id IS NOT NULL) THEN
        --dbms_output.PUT_LINE('dim set id is not NULL should not be here ..... ');
        FOR cd IN c_dim_set_ind LOOP
            l_dimension_id  :=  cd.Dim_Group_Id;
            FOR cn_bsc IN cr_bsc_dim LOOP
                IF (cn_bsc.Source = 'PMF') THEN
                    l_flag  :=  TRUE;
                    EXIT;
                ELSE
                    l_flag  :=  FALSE;
                    EXIT;
                END IF;
            END LOOP;
            IF (l_flag) THEN
                --first delete the remove dimension from dimension set and indicator combination
                SELECT  short_name INTO l_temp_var
                FROM    BSC_SYS_DIM_GROUPS_VL
                WHERE   dim_group_id = l_dimension_id;
                -- START  Granular Locking
                BSC_BIS_LOCKS_PUB.LOCK_DIM_SET
                (       p_Kpi_Id             =>  p_Kpi_Id
                     ,  p_Dim_Set_Id         =>  p_dim_set_id
                     ,  p_time_stamp         =>  NULL
                     ,  x_return_status      =>  x_return_status
                     ,  x_msg_count          =>  x_msg_count
                     ,  x_msg_data           =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DIM_SET - Failed');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                -- END  Granular Locking
                BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set
                (       p_commit                =>  FND_API.G_FALSE
                    ,   p_kpi_id                =>  p_Kpi_Id
                    ,   p_dim_set_id            =>  p_dim_set_id
                    ,   p_dim_short_names       =>  l_temp_var
                    ,   p_time_stamp            =>  NULL
                    ,   x_return_status         =>  x_return_status
                    ,   x_msg_count             =>  x_msg_count
                    ,   x_msg_data              =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                --now delete the dimension from system level, ie from BSC_SYS_DIM_GROUPS_TL table
                BSC_BIS_DIMENSION_PUB.Delete_Dimension
                (       p_commit                =>  FND_API.G_FALSE
                    ,   p_dim_short_name        =>  l_temp_var
                    ,   x_return_status         =>  x_return_status
                    ,   x_msg_count             =>  x_msg_count
                    ,   x_msg_data              =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_BIS_DIMENSION_PUB.Delete_Dimension');
                    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
                    x_msg_data      :=  NULL;
                END IF;
            END IF;
        END LOOP;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Remove_Unused_PMF_Dimenison procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Remove_Unused_PMF_Dimenison ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Remove_Unused_PMF_Dimenison ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Remove_Unused_PMF_Dimenison ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Remove_Unused_PMF_Dimenison ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Remove_Unused_PMF_Dimenison;

/*******************************************************************
    PROCEUDRE to SET Defaults for PMF Dimension Levels
 *******************************************************************/
PROCEDURE Get_PMF_Defaults
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_data_set_id           IN          NUMBER
    ,   p_measure_short_name    IN          VARCHAR2
    ,   p_dim_obj_short_names   IN          VARCHAR2
    ,   p_default_short_names   IN          VARCHAR2
    ,   p_view_by_name          IN          VARCHAR2
    ,   x_dim_obj_short_names   OUT NOCOPY  VARCHAR2
    ,   x_default_short_names   OUT NOCOPY  VARCHAR2
    ,   x_view_by_name          OUT NOCOPY  VARCHAR2
    ,   x_measure_short_name    OUT NOCOPY  VARCHAR2
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
    l_DimObj_ViewBy_Tbl     BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type;
    l_flag                  BOOLEAN;
    l_temp_var              VARCHAR2(32000);
    l_dim_obj_name          BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults procedure');
    FND_MSG_PUB.Initialize;
    x_return_status         :=  FND_API.G_RET_STS_SUCCESS;
    x_dim_obj_short_names   :=  p_dim_obj_short_names;
    x_default_short_names   :=  p_default_short_names;
    x_view_by_name          :=  p_view_by_name;
    x_measure_short_name    :=  p_measure_short_name;
    --dbms_output.PUT_LINE('into the PMF area      <'||p_dim_obj_short_names||'>');
    --dbms_output.PUT_LINE('p_default_short_names  <'||p_default_short_names||'>');
    --dbms_output.PUT_LINE('p_view_by_name         <'||p_view_by_name||'>');
    --dbms_output.PUT_LINE('p_measure_short_name   <'||p_measure_short_name||'>');
    IF (x_measure_short_name IS NULL) THEN
        SELECT    Short_Name
        INTO      x_measure_short_name
        FROM      BSC_SYS_MEASURES
               ,  BSC_SYS_DATASETS_VL
        WHERE     MEASURE_ID  = MEASURE_ID1
        AND       DATASET_ID  = p_data_set_id;
    END IF;
    BSC_BIS_KPI_MEAS_PUB.get_DimObj_ViewBy_Tbl
    (       p_Measure_Short_Name   =>   x_measure_short_name
        ,   p_Region_Code          =>   NULL
        ,   x_DimObj_ViewBy_Tbl    =>   l_DimObj_ViewBy_Tbl
        ,   x_return_status        =>   x_return_status
        ,   x_msg_count            =>   x_msg_count
        ,   x_msg_data             =>   x_msg_data
    );
    --dbms_output.PUT_LINE(' fetched the PMV table .....!');
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults Failed: at BSC_BIS_KPI_MEAS_PUB.get_DimObj_ViewBy_Tbl');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (x_dim_obj_short_names IS NULL) THEN
        BSC_BIS_KPI_MEAS_PUB.get_Default_ViewBy_For_Measure
        (       p_DimObj_ViewBy_Tbl =>  l_DimObj_ViewBy_Tbl
            ,   x_dim_objects       =>  x_dim_obj_short_names
            ,   x_defaults          =>  x_default_short_names
            ,   x_view_bys          =>  x_view_by_name
            ,   x_return_status     =>  x_return_status
            ,   x_msg_count         =>  x_msg_count
            ,   x_msg_data          =>  x_msg_data
        );
        --dbms_output.PUT_LINE(' fetched the default and view by .....!');
        --dbms_output.PUT_LINE('-* Defaults *- '||x_default_short_names);
        --dbms_output.PUT_LINE('-* view by  *- '||x_view_by_name);
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults Failed: at BSC_BIS_KPI_MEAS_PUB.get_Default_ViewBy_For_Measure');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    IF (x_view_by_name IS NULL) THEN
        l_flag := FALSE;
        IF (x_default_short_names IS NOT NULL) THEN
            -- 2nd page submit
            l_temp_var  :=  x_default_short_names;
            WHILE (is_more(     p_dim_short_names   =>  l_temp_var
                            ,   p_dim_short_name    =>  l_dim_obj_name)
            )LOOP
                IF (BSC_BIS_KPI_MEAS_PUB.is_View_By(l_DimObj_ViewBy_Tbl, l_dim_obj_name)) THEN
                    l_flag          :=  TRUE;
                    x_view_by_name  :=  l_dim_obj_name;
                    EXIT WHEN l_flag;
                END IF;
            END LOOP;
        ELSE
            -- first page commit
            l_temp_var  :=  x_dim_obj_short_names;
            WHILE (is_more(     p_dim_short_names   =>  l_temp_var
                            ,   p_dim_short_name    =>  l_dim_obj_name)
            )LOOP
                --dbms_output.PUT_LINE('l_dim_obj_name '||l_dim_obj_name);
                IF (BSC_BIS_KPI_MEAS_PUB.is_View_By(l_DimObj_ViewBy_Tbl, l_dim_obj_name)) THEN
                    --dbms_output.PUT_LINE('SETTING VIEW BY');
                    l_flag          :=  TRUE;
                    x_view_by_name  :=  l_dim_obj_name;
                    EXIT WHEN l_flag;
                END IF;
            END LOOP;
        END IF;
        IF (NOT l_flag) THEN -- BSC model need to have at least one view by for color calculation
            l_temp_var  :=  x_default_short_names;

            IF (is_more(     p_dim_short_names   =>  l_temp_var
                         ,   p_dim_short_name    =>  l_dim_obj_name)) THEN
            x_view_by_name  :=  l_dim_obj_name;
            --dbms_output.PUT_LINE('pick default x_view_by_name   <'||x_view_by_name||'>');
            -- visuri commented this validation for bug 5080308
                /*ELSE
                    --dbms_output.PUT_LINE('view by problem');
                    FND_MESSAGE.SET_NAME('BSC','BSC_VIEW_BY_REQUIRED');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;*/
            END IF;
        END IF;
    END IF;
    -- WHY IS THIS REQUIRED ** ask Pankaj
    IF (x_measure_short_name IS NULL) THEN
        SELECT    Short_Name
        INTO      x_measure_short_name
        FROM      BSC_SYS_MEASURES
               ,  BSC_SYS_DATASETS_VL
        WHERE     MEASURE_ID  = MEASURE_ID1
        AND       DATASET_ID  = p_data_set_id;
    END IF;
    l_flag  :=  BSC_BIS_KPI_MEAS_PUB.is_Time_With_Measure
                (       p_DimObj_ViewBy_Tbl    =>   l_DimObj_ViewBy_Tbl
                    ,   x_return_status        =>   x_return_status
                    ,   x_msg_count            =>   x_msg_count
                    ,   x_msg_data             =>   x_msg_data
                );
    IF (l_flag) THEN
        IF (NOT BSC_BIS_KPI_MEAS_PUB.is_Time_In_Dim_Object(l_DimObj_ViewBy_Tbl, x_view_by_name)) THEN
            l_flag  := FALSE;
            IF (x_default_short_names IS NOT NULL) THEN
                l_temp_var  :=  x_default_short_names;
                WHILE (is_more(     p_dim_short_names   =>  l_temp_var
                                ,   p_dim_short_name    =>  l_dim_obj_name)
                )LOOP
                    IF (BSC_BIS_KPI_MEAS_PUB.is_Time_In_Dim_Object(l_DimObj_ViewBy_Tbl, l_dim_obj_name)) THEN
                        l_flag  := TRUE;
                        EXIT WHEN l_flag;
                    END IF;
                END LOOP;
            ELSE
                l_temp_var  :=  x_dim_obj_short_names;
                WHILE (is_more(     p_dim_short_names   =>  l_temp_var
                                ,   p_dim_short_name    =>  l_dim_obj_name)
                )LOOP
                    IF(BSC_BIS_KPI_MEAS_PUB.is_Time_In_Dim_Object(l_DimObj_ViewBy_Tbl, l_dim_obj_name)) THEN
                        l_flag  := TRUE;
                        x_default_short_names  :=  l_dim_obj_name;
                        EXIT WHEN l_flag;
                    END IF;
                END LOOP;
            END IF;
        END IF;
        IF(NOT l_flag) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_TIME_DIM_REQUIRED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
    -- changed this code so that view by and default dimension are
    -- set properly when finish pressed on 1,2 page in 3 step process
    --
    IF (x_default_short_names IS NULL) THEN
        x_default_short_names   :=  x_view_by_name;
    ELSE
        IF (INSTR(x_default_short_names, x_view_by_name)  =  0 ) THEN
          x_default_short_names :=  x_default_short_names||', '||x_view_by_name;
        END IF;
    END IF;
    l_temp_var  :=  x_default_short_names;
    WHILE (is_more(     p_dim_short_names   =>  l_temp_var
                    ,   p_dim_short_name    =>  l_dim_obj_name)
    )LOOP
        IF (INSTR(x_dim_obj_short_names, l_dim_obj_name)  =  0 ) THEN
            x_dim_obj_short_names :=  x_dim_obj_short_names||', '||l_dim_obj_name;
        END IF;
    END LOOP;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Get_PMF_Defaults;
/*********************************************************************************
                        CREATE DIMENSION-SETS
*********************************************************************************/
PROCEDURE Create_Dim_Set
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_display_name          IN              VARCHAR2
    ,   p_dim_short_names       IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   p_dim_set_short_name    IN              VARCHAR2   := NULL
    ,   x_return_status         OUT    NOCOPY   VARCHAR2            -- Send the KPI Time Stamp
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)IS
    l_bsc_dimset_rec        BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_index                     NUMBER := 0;
    l_count                     NUMBER;
    l_count_independent_dim_obj NUMBER;
    l_kpi_name                  VARCHAR2(32000);

    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator =   p_kpi_id
    AND     Prototype_Flag   <>  2;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT CreateBSCDimSetPMD;
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Create_Dim_Set procedure');
    IF (p_kpi_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    SELECT  COUNT(*) INTO l_count
    FROM    BSC_KPIS_B
    WHERE   indicator = p_kpi_id;
    IF (l_count = 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_bsc_dimset_rec.Bsc_Kpi_Id                     :=  p_kpi_id;         --varchar2(10)
    l_bsc_dimset_rec.Bsc_Dim_Set_Short_Name         :=  p_dim_set_short_name;
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Kpi_Id         <'||l_bsc_dimset_rec.Bsc_Kpi_Id||'>');
    -- Verify that this is not a Shared KPI.
    SELECT  share_flag
    INTO    l_count
    FROM    BSC_KPIS_B
    WHERE  indicator = l_bsc_dimset_rec.Bsc_Kpi_Id ;
    IF (l_count = 2) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
        --FND_MESSAGE.SET_TOKEN('BSC_KPI', l_bsc_dimset_rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    BSC_UTILITY.Enable_Dimensions_Entity(
        p_Entity_Type           => BSC_UTILITY.c_DIMENSION
      , p_Entity_Short_Names    => p_dim_short_names
      , p_Entity_Action_Type    => BSC_UTILITY.c_UPDATE
      , x_Return_Status         => x_return_status
      , x_Msg_Count             => x_msg_count
      , x_Msg_Data              => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_bsc_dimset_rec.Bsc_New_Dset                   :=  'N';    --varchar2(45)
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_New_Dset       <'||l_bsc_dimset_rec.Bsc_New_Dset||'>');
    l_bsc_dimset_rec.Bsc_Dim_Set_Name               :=  p_display_name;       --varchar2(45)
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Dim_Set_Name   <'||l_bsc_dimset_rec.Bsc_Dim_Set_Name||'>');
    l_bsc_dimset_rec.Bsc_Action := 'RESET';
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Action   <'||l_bsc_dimset_rec.Bsc_Action||'>');

    SELECT  NVL(MAX(dim_set_id) + 1, 0)
    INTO    l_bsc_dimset_rec.bsc_dim_set_id
    FROM    BSC_KPI_DIM_SETS_VL
    WHERE   indicator = l_bsc_dimset_rec.bsc_kpi_id;
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.bsc_dim_set_id             <'||l_bsc_dimset_rec.bsc_dim_set_id||'>');

    -- START Granular Locking
    -- Lock the underlying KPI, so that it is not deleted when assignment is being done.
    BSC_BIS_LOCKS_PUB.LOCK_KPI
    (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
       ,   p_time_stamp         =>  p_time_stamp
       ,   p_Full_Lock_Flag     =>  FND_API.G_FALSE
       ,   x_return_status      =>  x_return_status
       ,   x_msg_count          =>  x_msg_count
       ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_SET Failed: at BSC_BIS_LOCKS_PUB.LOCK_KPI');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- END Granular Locking
    BSC_DIMENSION_SETS_PUB.Create_Bsc_Kpi_Dim_Sets_Tl--INSERT INTO BSC_KPI_DIM_SETS_TL
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_Dim_Set_Rec           =>  l_bsc_dimset_rec
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_SET Failed: at BSC_DIMENSION_SETS_PUB.Create_Bsc_Kpi_Dim_Sets_Tl');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    BSC_BIS_KPI_MEAS_PUB.Create_Dim_Grp_Lev_In_Dset
    (       p_commit                =>   FND_API.G_FALSE
        ,   p_kpi_id                =>   l_bsc_dimset_rec.Bsc_Kpi_Id
        ,   p_dim_set_id            =>   l_bsc_dimset_rec.bsc_dim_set_id
        ,   p_dim_short_names       =>   p_dim_short_names
        ,   x_return_status         =>   x_return_status
        ,   x_msg_count             =>   x_msg_count
        ,   x_msg_data              =>   x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_SET Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Grp_Lev_In_Dset');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- START: Granular Locking, Change time stamp of Dim Set & KPI
    BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
    (      p_Kpi_Id             =>  p_Kpi_Id
       ,   p_dim_set_id         =>  l_bsc_dimset_rec.bsc_dim_set_id
       ,   x_return_status      =>  x_return_status
       ,   x_msg_count          =>  x_msg_count
       ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET Failed: SET_TIME_STAMP_DIM_SET');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- END: Granular Locking, Change time stamp of Dim Set & KPI
    --for all shared indicator, repeat the steps above
    FOR cd IN c_kpi_ids LOOP
        l_bsc_dimset_rec.Bsc_Kpi_Id :=  cd.indicator;
        --dbms_output.PUT_LINE('Within Shared Indicator Loop  KPI_ID is <'||l_bsc_dimset_rec.Bsc_Kpi_Id||'>');
        -- Lock the underlying KPI, so that it is not deleted when assignment is being done.
        BSC_BIS_LOCKS_PUB.LOCK_KPI
        (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
           ,   p_time_stamp         =>  NULL
           ,   p_Full_Lock_Flag     =>  FND_API.G_FALSE
           ,   x_return_status      =>  x_return_status
           ,   x_msg_count          =>  x_msg_count
           ,   x_msg_data           =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_SET Failed: at BSC_BIS_LOCKS_PUB.LOCK_KPI');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        SELECT  NVL(MAX(dim_set_id) + 1, 0)
        INTO    l_bsc_dimset_rec.bsc_dim_set_id
        FROM    BSC_KPI_DIM_SETS_VL
        WHERE   indicator = l_bsc_dimset_rec.bsc_kpi_id;
        BSC_DIMENSION_SETS_PUB.Create_Bsc_Kpi_Dim_Sets_Tl--INSERT INTO BSC_KPI_DIM_SETS_TL
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_Dim_Set_Rec           =>  l_bsc_dimset_rec
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_SET Failed: at BSC_DIMENSION_SETS_PUB.Create_Bsc_Kpi_Dim_Sets_Tl');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        BSC_BIS_KPI_MEAS_PUB.Create_Dim_Grp_Lev_In_Dset
        (       p_commit                =>   FND_API.G_FALSE
            ,   p_kpi_id                =>   l_bsc_dimset_rec.Bsc_Kpi_Id
            ,   p_dim_set_id            =>   l_bsc_dimset_rec.bsc_dim_set_id
            ,   p_dim_short_names       =>   p_dim_short_names
            ,   x_return_status         =>   x_return_status
            ,   x_msg_count             =>   x_msg_count
            ,   x_msg_data              =>   x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_SET Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Grp_Lev_In_Dset');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- START: Granular Locking, Change time stamp of Dim Set & KPI
        BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
        (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
           ,   p_dim_set_id         =>  l_bsc_dimset_rec.bsc_dim_set_id
           ,   x_return_status      =>  x_return_status
           ,   x_msg_count          =>  x_msg_count
           ,   x_msg_data           =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET Failed: SET_TIME_STAMP_DIM_SET');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- END: Granular Locking, Change time stamp of Dim Set & KPI
    END LOOP;
    /*************************************************************
      List Button validation.For a list button the condition is that
      all the dimesnion sets within the tab (irrespective of whether they are
      in the same KPI or different KPIs) the dimesnion objects should be the same
      So we have to check for the validity of the List Button while creating a new Dimesnion set.
      This API will internally take care of Shared indiactors also.So don't need to call for
      Shared indiactors.
    /************************************************************/
    BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button
    (
          p_Kpi_Id          =>  p_kpi_id
        , p_Dim_Level_Id    =>  NULL
        , x_return_status   =>  x_return_status
        , x_msg_count       =>  x_msg_count
        , x_msg_data        =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Set procedure Failed:at BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /********************************************************
        Check no of independent dimension objects in dimension set
    ********************************************************/

    SELECT COUNT(0) INTO l_count_independent_dim_obj
    FROM   BSC_KPI_DIM_LEVELS_B
    WHERE  INDICATOR = p_kpi_id
    AND    DIM_SET_ID = l_bsc_dimset_rec.bsc_dim_set_id;

    IF(l_count_independent_dim_obj > bsc_utility.NO_IND_DIM_OBJ_LIMIT) THEN

        l_count_independent_dim_obj := 0;
        l_count_independent_dim_obj := bsc_utility.get_nof_independent_dimobj
                                       (    p_Kpi_Id        =>  p_Kpi_Id
                                          , p_Dim_Set_Id    =>  l_bsc_dimset_rec.bsc_dim_set_id
                                       );
       IF(l_count_independent_dim_obj >bsc_utility.NO_IND_DIM_OBJ_LIMIT) THEN
            SELECT NAME INTO l_kpi_name
            FROM   BSC_KPIS_VL
            WHERE  INDICATOR = p_Kpi_Id;

            l_kpi_name := '['||l_kpi_name||']';

            FND_MESSAGE.SET_NAME('BSC','BSC_IND_DIMOBJ_LIMIT');
            FND_MESSAGE.SET_TOKEN('NAME_LIST',l_kpi_name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;


    END IF;

    /********************************************************/
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Create_Dim_Set procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCDimSetPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCDimSetPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCDimSetPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Create_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Create_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCDimSetPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Create_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Create_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Create_Dim_Set;
/*********************************************************************************
                        UPDATE DIMENSION-SETS
*********************************************************************************/
PROCEDURE Update_Dim_Set
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_display_name          IN              VARCHAR2
    ,   p_assign_dim_names      IN              VARCHAR2
    ,   p_unassign_dim_names    IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)IS
    l_bsc_dimset_rec            BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_count                     NUMBER := 0;
    l_count_independent_dim_obj NUMBER;
    l_kpi_name                  VARCHAR2(32000);
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set procedure');
    IF (p_kpi_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- added for Bug#4615361
    BSC_UTILITY.Enable_Dimensions_Entity(
        p_Entity_Type           => BSC_UTILITY.c_DIMENSION
      , p_Entity_Short_Names    => p_assign_dim_names
      , p_Entity_Action_Type    => BSC_UTILITY.c_UPDATE
      , x_Return_Status         => x_return_status
      , x_Msg_Count             => x_msg_count
      , x_Msg_Data              => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set
    (       p_commit            =>  FND_API.G_FALSE
        ,   p_kpi_id            =>  p_kpi_id
        ,   p_dim_set_id        =>  p_dim_set_id
        ,   p_display_name      =>  p_display_name
        ,   p_time_stamp        =>  p_time_stamp
        ,   x_return_status     =>  x_return_status
        ,   x_msg_count         =>  x_msg_count
        ,   x_msg_data          =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set Failed: at BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    BSC_BIS_KPI_MEAS_PUB.Assign_Unassign_Dimensions
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_kpi_id                =>  p_kpi_id
        ,   p_dim_set_id            =>  p_dim_set_id
        ,   p_assign_dim_names      =>  p_assign_dim_names
        ,   p_unassign_dim_names    =>  p_unassign_dim_names
        ,   p_time_stamp            =>  NULL
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set Failed: at BSC_DIMENSION_SETS_PUB.Assign_Unassign_Dimensions <'||x_msg_data||'>');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /********************************************************
                Check no of independent dimension objects in dimension set
    ********************************************************/

    SELECT COUNT(0) INTO l_count_independent_dim_obj
    FROM   BSC_KPI_DIM_LEVELS_B
    WHERE  INDICATOR = p_kpi_id
    AND    DIM_SET_ID = p_dim_set_id;

    IF(l_count_independent_dim_obj > bsc_utility.NO_IND_DIM_OBJ_LIMIT) THEN

        l_count_independent_dim_obj := 0;
        l_count_independent_dim_obj := bsc_utility.get_nof_independent_dimobj
                                           (    p_Kpi_Id        =>  p_kpi_id
                                              , p_Dim_Set_Id    =>  p_dim_set_id
                                           );

       IF(l_count_independent_dim_obj >bsc_utility.NO_IND_DIM_OBJ_LIMIT) THEN
            SELECT NAME INTO l_kpi_name
            FROM   BSC_KPIS_VL
            WHERE  INDICATOR = p_Kpi_Id;

            l_kpi_name := '['||l_kpi_name||']';

            FND_MESSAGE.SET_NAME('BSC','BSC_IND_DIMOBJ_LIMIT');
            FND_MESSAGE.SET_TOKEN('NAME_LIST',l_kpi_name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;

    /********************************************************/

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Update_Dim_Set;

/*********************************************************************************
                        UPDATE DIMENSION-SETS
*********************************************************************************/
PROCEDURE Update_Dim_Set
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_display_name          IN              VARCHAR2
    ,   p_dim_short_names       IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)IS
    l_unassign_dim_names        VARCHAR2(32000);
    l_count                     NUMBER := 0;
    l_meaning                   VARCHAR(60);

    CURSOR  p_unassign_dim_names IS
    SELECT  short_name FROM BSC_SYS_DIM_GROUPS_VL
    WHERE   dim_group_id IN (SELECT  dim_group_id
    FROM    BSC_KPI_DIM_GROUPS
    WHERE   dim_set_id = p_dim_set_id
    AND     indicator  = p_kpi_id);
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_kpi_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_dim_set_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SET_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    SELECT COUNT(DIM_SET_ID)
    INTO l_count
    FROM BSC_KPI_DIM_SETS_VL
    WHERE DIM_SET_ID = p_dim_set_id AND INDICATOR = p_kpi_id;

    IF (l_count = 0) THEN
       FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');

       SELECT MEANING
       INTO l_meaning
       FROM BSC_LOOKUPS
       WHERE LOOKUP_TYPE = 'BSC_UI_COMMON' AND LOOKUP_CODE = 'DIM_SET' ;

       FND_MESSAGE.SET_TOKEN('TYPE', l_meaning, TRUE);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    FOR cd IN p_unassign_dim_names LOOP
        IF (cd.short_name IS NOT NULL) THEN
            IF (l_unassign_dim_names IS NULL) THEN
                l_unassign_dim_names := cd.short_name;
            ELSE
                l_unassign_dim_names := l_unassign_dim_names||', '||cd.short_name;
            END IF;
        END IF;
    END LOOP;

    BSC_UTILITY.Enable_Dimensions_Entity(
        p_Entity_Type           => BSC_UTILITY.c_DIMENSION
      , p_Entity_Short_Names    => p_dim_short_names
      , p_Entity_Action_Type    => BSC_UTILITY.c_UPDATE
      , x_Return_Status         => x_return_status
      , x_Msg_Count             => x_msg_count
      , x_Msg_Data              => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_kpi_id                =>  p_kpi_id
        ,   p_dim_set_id            =>  p_dim_set_id
        ,   p_display_name          =>  p_display_name
        ,   p_assign_dim_names      =>  p_dim_short_names
        ,   p_unassign_dim_names    =>  l_unassign_dim_names
        ,   p_time_stamp            =>  p_time_stamp
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set Failed: at BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set <'||x_msg_data||'>');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Update_Dim_Set;
/*********************************************************************************
                        UPDATE DIMENSION-SET
*********************************************************************************/
PROCEDURE Update_Dim_Set
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_display_name          IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)IS

    l_bsc_dimset_rec        BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_count                 NUMBER := 0;


    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  p_kpi_id
    AND     Prototype_Flag   <>  2;
BEGIN
    SAVEPOINT UpdateBSCDimSetPMD;
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_kpi_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_dim_set_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SET_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_bsc_dimset_rec.Bsc_Kpi_Id         :=  p_kpi_id;      --number
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Kpi_Id                   <'||l_bsc_dimset_rec.Bsc_Kpi_Id||'>');
    -- Verify that this is not a Shared KPI.
    SELECT  share_flag
    INTO    l_count
    FROM    BSC_KPIS_B
    WHERE  indicator = l_bsc_dimset_rec.Bsc_Kpi_Id ;
    IF (l_count = 2) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
        --FND_MESSAGE.SET_TOKEN('BSC_KPI', l_bsc_dimset_rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_bsc_dimset_rec.Bsc_Dim_Set_Id     :=  p_dim_set_id;      --number
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Dim_Set_Id                   <'||l_bsc_dimset_rec.Bsc_Dim_Set_Id||'>');
    l_bsc_dimset_rec.Bsc_Dim_Set_Name   :=  p_display_name;
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Dim_Set_Name             <'||l_bsc_dimset_rec.Bsc_Dim_Set_Name||'>');

    SELECT COUNT(*) INTO l_count
    FROM   BSC_KPI_DIM_SETS_VL
    WHERE  indicator  = l_bsc_dimset_rec.Bsc_Kpi_Id
    AND    dim_set_id = l_bsc_dimset_rec.Bsc_Dim_Set_Id;
    IF (l_count = 0) THEN
        FND_MESSAGE.SET_NAME('BSC',        'BSC_INCORRECT_KPI_DIMSET');
        FND_MESSAGE.SET_TOKEN('KPI_ID',     l_bsc_dimset_rec.Bsc_Kpi_Id);
        FND_MESSAGE.SET_TOKEN('DIM_SET_ID', l_bsc_dimset_rec.Bsc_Dim_Set_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- START Granular Locking
    -- We need to call locking only in this API, since this is the lowermost API
    -- and all Update APIs will call this API eventually.
    BSC_BIS_LOCKS_PUB.LOCK_DIM_SET
    (      p_Kpi_Id             =>  p_Kpi_Id
       ,   p_Dim_Set_Id         =>  p_dim_set_id
       ,   p_time_stamp         =>  p_time_stamp
       ,   x_return_status      =>  x_return_status
       ,   x_msg_count          =>  x_msg_count
       ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DIM_SET');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- END Granular Locking
    BSC_DIMENSION_SETS_PUB.Update_Bsc_Kpi_Dim_Sets_Tl
    (       p_commit            =>  FND_API.G_FALSE
        ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
        ,   x_return_status     =>  x_return_status
        ,   x_msg_count         =>  x_msg_count
        ,   x_msg_data          =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set Failed: at BSC_DIMENSION_SETS_PUB.Update_Bsc_Kpi_Dim_Sets_Tl');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- START: Granular Locking, Change time stamp of Dim Set & KPI
    BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
    (      p_Kpi_Id             =>  p_Kpi_Id
       ,   p_dim_set_id         =>  l_bsc_dimset_rec.bsc_dim_set_id
       ,   x_return_status      =>  x_return_status
       ,   x_msg_count          =>  x_msg_count
       ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- END: Granular Locking, Change time stamp of Dim Set & KPI
    --for shared inidicators repeat the steps above
    FOR cd IN c_kpi_ids LOOP
        l_bsc_dimset_rec.Bsc_Kpi_Id :=  cd.indicator;
        --dbms_output.PUT_LINE('Within Shared Indicator Loop  KPI_ID is <'||l_bsc_dimset_rec.Bsc_Kpi_Id||'>');
        SELECT COUNT(*) INTO l_count FROM BSC_KPI_DIM_SETS_VL
        WHERE indicator  = l_bsc_dimset_rec.Bsc_Kpi_Id
        AND   dim_set_id = l_bsc_dimset_rec.Bsc_Dim_Set_Id;
        IF (l_count = 0) THEN
            FND_MESSAGE.SET_NAME('BSC',        'BSC_INCORRECT_KPI_DIMSET');
            FND_MESSAGE.SET_TOKEN('KPI_ID',     l_bsc_dimset_rec.Bsc_Kpi_Id);
            FND_MESSAGE.SET_TOKEN('DIM_SET_ID', l_bsc_dimset_rec.Bsc_Dim_Set_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- START Granular Locking
        -- We need to call locking only in this API, since this is the lowermost API
        -- and all Update APIs will call this API eventually.
        BSC_BIS_LOCKS_PUB.LOCK_DIM_SET
        (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
           ,   p_Dim_Set_Id         =>  p_dim_set_id
           ,   p_time_stamp         =>  NULL
           ,   x_return_status      =>  x_return_status
           ,   x_msg_count          =>  x_msg_count
           ,   x_msg_data           =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DIM_SET');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- END Granular Locking
        BSC_DIMENSION_SETS_PUB.Update_Bsc_Kpi_Dim_Sets_Tl
        (       p_commit            =>  FND_API.G_FALSE
            ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
            ,   x_return_status     =>  x_return_status
            ,   x_msg_count         =>  x_msg_count
            ,   x_msg_data          =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set Failed: at BSC_DIMENSION_SETS_PUB.Update_Bsc_Kpi_Dim_Sets_Tl');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- START: Granular Locking, Change time stamp of Dim Set & KPI
        BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
        (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
           ,   p_dim_set_id         =>  l_bsc_dimset_rec.bsc_dim_set_id
           ,   x_return_status      =>  x_return_status
           ,   x_msg_count          =>  x_msg_count
           ,   x_msg_data           =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- END: Granular Locking, Change time stamp of Dim Set & KPI
    END LOOP;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdateBSCDimSetPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdateBSCDimSetPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdateBSCDimSetPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO UpdateBSCDimSetPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Update_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Update_Dim_Set;

/*********************************************************************************
          API to find out pure PMF Dim Groups, i.e. Indicator not created for
          AG Report, and containing only PMF type Dim Objects, imported from
          measures. Added for bug 5151997
*********************************************************************************/

FUNCTION is_Pure_Pmf_Dim_Grp
(
  p_Indicator IN NUMBER
, p_DimSetId  IN NUMBER

)
RETURN BOOLEAN IS

  l_count NUMBER;
  l_kpi_sname BSC_KPIS_B.SHORT_NAME%TYPE;

CURSOR c_ind_type IS
  SELECT short_name
  FROM bsc_kpis_b
  WHERE indicator = p_Indicator;

BEGIN

--Source of Dim Levels present in this Dim Set should not be BSC

  SELECT  count(1)
  INTO  l_count
  FROM  BSC_KPI_DIM_LEVELS_VL
  WHERE INDICATOR    = p_Indicator
  AND   DIM_SET_ID   = p_DimSetId
  AND   LEVEL_SOURCE = BSC_BIS_MEASURE_PUB.c_BSC;

  IF (c_ind_type%ISOPEN) THEN
    CLOSE c_ind_type;
  END IF;

/*
Short name in BSC_KPIS_B should be null for Objectives created in Objective Designer, This
filters Objectives for AG report.
*/
  OPEN c_ind_type;
    FETCH c_ind_type INTO l_kpi_sname;
  CLOSE c_ind_type;

  IF ((l_count = 0) AND (l_kpi_sname IS NULL)) THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;

  EXCEPTION
    WHEN OTHERS THEN
      IF (c_ind_type%ISOPEN) THEN
        CLOSE c_ind_type;
      END IF;
    RETURN FALSE;

END is_Pure_Pmf_Dim_Grp;

/*********************************************************************************
                        DELETE DIMENSION-SETS
*********************************************************************************/
PROCEDURE Delete_Dim_Set
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)IS
    l_bsc_dimset_rec            BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_count                     NUMBER := 0;

    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  p_kpi_id
    AND     Prototype_Flag   <>  2;
BEGIN
    SAVEPOINT DeleteBSCDimSetPMD;
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Set procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_kpi_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC', 'BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_dim_set_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC', 'BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SET_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_dim_set_id = 0) THEN
        FND_MESSAGE.SET_NAME('BSC', 'BSC_DIM_SET_0_NO_DELETE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_bsc_dimset_rec.Bsc_Kpi_Id         :=  p_kpi_id;      --number
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Kpi_Id                   <'||l_bsc_dimset_rec.Bsc_Kpi_Id||'>');
    -- Verify that this is not a Shared KPI.
    SELECT  share_flag
    INTO    l_count
    FROM    BSC_KPIS_B
    WHERE  indicator = l_bsc_dimset_rec.Bsc_Kpi_Id ;
    IF (l_count = 2) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
        --FND_MESSAGE.SET_TOKEN('BSC_KPI', l_bsc_dimset_rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    SELECT COUNT(*) INTO l_count
    FROM   BSC_KPI_DIM_SETS_VL
    WHERE  indicator = l_bsc_dimset_rec.Bsc_Kpi_Id;
    IF (l_count = 1) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_D_KPI_AT_LEAST_1_DS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_bsc_dimset_rec.Bsc_Dim_Set_Id     :=  p_dim_set_id;      --number
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Dim_Set_Id                   <'||l_bsc_dimset_rec.Bsc_Dim_Set_Id||'>');
    -- START Granular Locking
    BSC_BIS_LOCKS_PUB.LOCK_DIM_SET
    (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
       ,   p_Dim_Set_Id         =>  p_dim_set_id
       ,   p_time_stamp         =>  NULL
       ,   x_return_status      =>  x_return_status
       ,   x_msg_count          =>  x_msg_count
       ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DIM_SET - Delete_Dim_Set');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- END Granular Locking
    -- Aditya added for Incremental Changes
    -- Deleting the Dimension set involves a structural change to be captured by Optimizer.
    -- The following changes the action_flag for the currently affected KPI only
    --IF (NVL(BSC_BIS_KPI_MEAS_PUB.get_DimensionSetSource(l_bsc_dimset_rec.Bsc_Kpi_Id, l_bsc_dimset_rec.Bsc_Dim_Set_Id), 'BSC') = 'BSC') THEN
    IF (NOT BSC_BIS_KPI_MEAS_PUB.is_Pure_Pmf_Dim_Grp(l_bsc_dimset_rec.Bsc_Kpi_Id, l_bsc_dimset_rec.Bsc_Dim_Set_Id)) THEN
        BSC_DESIGNER_PVT.ActionFlag_Change(p_kpi_id, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
    END IF;
    BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset
    (       p_commit            =>  FND_API.G_FALSE
        ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
        ,   x_return_status     =>  x_return_status
        ,   x_msg_count         =>  x_msg_count
        ,   x_msg_data          =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.DELETE_DIM_SET Failed: at BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset <'||x_msg_data||'>');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --repeat the steps above for all the shared indicators
    FOR cd IN c_kpi_ids LOOP
        l_bsc_dimset_rec.Bsc_Kpi_Id :=  cd.indicator;
        --dbms_output.PUT_LINE('Within Shared Indicator Loop  KPI_ID is <'||l_bsc_dimset_rec.Bsc_Kpi_Id||'>');
        SELECT COUNT(*) INTO l_count
        FROM   BSC_KPI_DIM_GROUPS
        WHERE  indicator  = l_bsc_dimset_rec.Bsc_Kpi_Id
        AND    dim_set_id = p_dim_set_id;
        IF (l_count <> 0) THEN
            BSC_BIS_LOCKS_PUB.LOCK_DIM_SET
            (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
               ,   p_Dim_Set_Id         =>  p_dim_set_id
               ,   p_time_stamp         =>  NULL
               ,   x_return_status      =>  x_return_status
               ,   x_msg_count          =>  x_msg_count
               ,   x_msg_data           =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DIM_SET - Delete_Dim_Set');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            --IF (NVL(BSC_BIS_KPI_MEAS_PUB.get_DimensionSetSource(l_bsc_dimset_rec.Bsc_Kpi_Id, l_bsc_dimset_rec.Bsc_Dim_Set_Id), 'BSC') = 'BSC') THEN
            IF (NOT BSC_BIS_KPI_MEAS_PUB.is_Pure_Pmf_Dim_Grp(l_bsc_dimset_rec.Bsc_Kpi_Id, l_bsc_dimset_rec.Bsc_Dim_Set_Id)) THEN
                BSC_DESIGNER_PVT.ActionFlag_Change(l_bsc_dimset_rec.Bsc_Kpi_Id, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
            END IF;
            BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset
            (       p_commit            =>  FND_API.G_FALSE
                ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                ,   x_return_status     =>  x_return_status
                ,   x_msg_count         =>  x_msg_count
                ,   x_msg_data          =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.DELETE_DIM_SET Failed: at BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset <'||x_msg_data||'>');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END LOOP;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Set procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteBSCDimSetPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteBSCDimSetPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteBSCDimSetPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO DeleteBSCDimSetPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Dim_Set;
/*********************************************************************************
                        ASSIGN DIMENSION TO  DIMENSION-SETS
*********************************************************************************/
PROCEDURE Assign_Dims_To_Dim_Set
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_dim_short_names       IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)IS
    l_bsc_dimset_rec        BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_index                 NUMBER := 0;
    l_count                 NUMBER := 0;
    l_dim_short_names       VARCHAR2(32000);
    l_dim_short_name        BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
    l_temp_var              VARCHAR2(32000);
    l_kpi_flag_change       BOOLEAN := FALSE;
    l_level_table_names     BSC_EDIT_VLIST;
    l_key_item_values       FND_TABLE_OF_NUMBER;
    l_key_item              NUMBER;

    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  p_kpi_id
    AND     Prototype_Flag   <>  2;

    CURSOR c_Dim_Levels IS
    SELECT
      level_table_name
    FROM
      bsc_kpi_dim_levels_b
    WHERE
      indicator = p_kpi_id
      AND dim_set_id = p_dim_set_id
    INTERSECT
    SELECT
      column_value level_table_name
    FROM
      TABLE(CAST(l_level_table_names AS BSC_EDIT_VLIST));
BEGIN
    SAVEPOINT AssBSCDimToDSetPMD;
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_kpi_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_dim_set_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SET_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    SELECT
      level_table_name
     ,default_key_value
    BULK COLLECT INTO
      l_level_table_names,
      l_key_item_values
    FROM
      bsc_kpi_dim_levels_b
    WHERE
      indicator = p_kpi_id
      AND dim_set_id = p_dim_set_id
      AND default_key_value IS NOT NULL;

    l_bsc_dimset_rec.Bsc_Kpi_Id             :=  p_kpi_id;         --varchar2(10)
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Kpi_Id         <'||l_bsc_dimset_rec.Bsc_Kpi_Id||'>');
    -- Verify that this is not a Shared KPI.
    SELECT  share_flag
    INTO    l_count
    FROM    BSC_KPIS_B
    WHERE  indicator = l_bsc_dimset_rec.Bsc_Kpi_Id ;
    IF (l_count <> 2) THEN
        --BSC_KPI_DIM_LEVELS_B.indicator
        l_bsc_dimset_rec.Bsc_Dim_Set_Id     :=  p_dim_set_id;      --number
        --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Dim_Set_Id                   <'||l_bsc_dimset_rec.Bsc_Dim_Set_Id||'>');
        -- BSC_KPI_DIM_LEVELS_TL.total_disp_name
        l_bsc_dimset_rec.Bsc_New_Dset       :=  'N';    --varchar2(45)
        --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_New_Dset       <'||l_bsc_dimset_rec.Bsc_New_Dset||'>');
        l_bsc_dimset_rec.Bsc_Action := 'RESET';
        --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Action   <'||l_bsc_dimset_rec.Bsc_Action||'>');
        SELECT COUNT(*) INTO l_count FROM BSC_KPI_DIM_SETS_VL
        WHERE indicator  = l_bsc_dimset_rec.Bsc_Kpi_Id
        AND   dim_set_id = l_bsc_dimset_rec.Bsc_Dim_Set_Id;
        IF (l_count = 0) THEN
            FND_MESSAGE.SET_NAME('BSC',        'BSC_INCORRECT_KPI_DIMSET');
            FND_MESSAGE.SET_TOKEN('KPI_ID',     l_bsc_dimset_rec.Bsc_Kpi_Id);
            FND_MESSAGE.SET_TOKEN('DIM_SET_ID', l_bsc_dimset_rec.Bsc_Dim_Set_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        --remove the default entry 'XXX' from BSC_KPI_DIM_LEVELS_B if exists
        BSC_BIS_KPI_MEAS_PUB.Delete_Default_Kpi_Dim_Object
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_kpi_id                =>  p_kpi_id
            ,   p_dim_set_id            =>  p_dim_set_id
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set Failed: at BSC_BIS_KPI_MEAS_PUB.Delete_Default_Kpi_Dim_Object');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_temp_var          :=  p_dim_short_names;
        l_dim_short_names   :=  NULL;
        WHILE (is_more(     p_dim_short_names   =>  l_temp_var
                        ,   p_dim_short_name    =>  l_dim_short_name)
        ) LOOP
            SELECT  COUNT(*)  INTO l_count
            FROM    BSC_SYS_DIM_GROUPS_VL
            WHERE   short_name = l_dim_short_name;
            IF (l_count =  0) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_GROUP_SHORT_NAME');
                FND_MESSAGE.SET_TOKEN('BSC_GROUP_SHORT_NAME',  l_dim_short_name);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            SELECT COUNT(*) INTO l_count
            FROM   BSC_KPI_DIM_GROUPS
            WHERE  dim_group_id = (SELECT dim_group_id FROM BSC_SYS_DIM_GROUPS_VL WHERE Short_Name = l_dim_short_name)
            AND    dim_set_id   =  l_bsc_dimset_rec.Bsc_Dim_Set_Id
            AND    indicator    =  l_bsc_dimset_rec.Bsc_Kpi_Id;
            IF (l_count = 0) THEN
                IF (l_dim_short_names IS NULL) THEN
                    l_dim_short_names  :=  l_dim_short_name;
                    l_kpi_flag_change  :=  TRUE;
                ELSE
                    l_dim_short_names  :=  l_dim_short_names||', '||l_dim_short_name;
                END IF;
            END IF;
        END LOOP;

        IF (l_dim_short_names IS NOT NULL) THEN
            BSC_BIS_LOCKS_PUB.LOCK_DIM_SET
            (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
               ,   p_Dim_Set_Id         =>  l_bsc_dimset_rec.bsc_dim_set_id
               ,   p_time_stamp         =>  p_time_stamp
               ,   x_return_status      =>  x_return_status
               ,   x_msg_count          =>  x_msg_count
               ,   x_msg_data           =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DIM_SET - Assign_Dims_To_Dim_Set');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- BSC_DESIGNER_PVT.ActionFlag_Change(p_kpi_id, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
            BSC_BIS_KPI_MEAS_PUB.Create_Dim_Grp_Lev_In_Dset
            (       p_commit                =>   FND_API.G_FALSE
                ,   p_kpi_id                =>   p_kpi_id
                ,   p_dim_set_id            =>   l_bsc_dimset_rec.bsc_dim_set_id
                ,   p_dim_short_names       =>   l_dim_short_names
                ,   x_return_status         =>   x_return_status
                ,   x_msg_count             =>   x_msg_count
                ,   x_msg_data              =>   x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Grp_Lev_In_Dset');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- START: Granular Locking, Change time stamp of Dim Set & KPI
            BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
            (      p_Kpi_Id             =>  p_Kpi_Id
               ,   p_dim_set_id         =>  l_bsc_dimset_rec.bsc_dim_set_id
               ,   x_return_status      =>  x_return_status
               ,   x_msg_count          =>  x_msg_count
               ,   x_msg_data           =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET - Assign_Dims_To_Dim_Set');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- END: Granular Locking, Change time stamp of Dim Set & KPI
            --repeat the steps above for all the shared indicators
            FOR cd IN c_kpi_ids LOOP
                l_bsc_dimset_rec.Bsc_Kpi_Id :=  cd.indicator;
                --dbms_output.PUT_LINE('Within Shared Indicator Loop  KPI_ID is <'||l_bsc_dimset_rec.Bsc_Kpi_Id||'>');
                SELECT COUNT(*) INTO l_count FROM BSC_KPI_DIM_SETS_VL
                WHERE indicator  = l_bsc_dimset_rec.Bsc_Kpi_Id
                AND   dim_set_id = l_bsc_dimset_rec.Bsc_Dim_Set_Id;
                IF (l_count = 0) THEN
                    FND_MESSAGE.SET_NAME('BSC',        'BSC_INCORRECT_KPI_DIMSET');
                    FND_MESSAGE.SET_TOKEN('KPI_ID',     l_bsc_dimset_rec.Bsc_Kpi_Id);
                    FND_MESSAGE.SET_TOKEN('DIM_SET_ID', l_bsc_dimset_rec.Bsc_Dim_Set_Id);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                -- START Granular Locking
                BSC_BIS_LOCKS_PUB.LOCK_DIM_SET
                (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
                   ,   p_Dim_Set_Id         =>  l_bsc_dimset_rec.bsc_dim_set_id
                   ,   p_time_stamp         =>  NULL -- Should not pass time_stamp here
                   ,   x_return_status      =>  x_return_status
                   ,   x_msg_count          =>  x_msg_count
                   ,   x_msg_data           =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DIM_SET - Assign_Dims_To_Dim_Set');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                --BSC_DESIGNER_PVT.ActionFlag_Change(l_bsc_dimset_rec.Bsc_Kpi_Id, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
                BSC_BIS_KPI_MEAS_PUB.Create_Dim_Grp_Lev_In_Dset
                (       p_commit                =>   FND_API.G_FALSE
                    ,   p_kpi_id                =>   l_bsc_dimset_rec.Bsc_Kpi_Id
                    ,   p_dim_set_id            =>   l_bsc_dimset_rec.bsc_dim_set_id
                    ,   p_dim_short_names       =>   l_dim_short_names
                    ,   x_return_status         =>   x_return_status
                    ,   x_msg_count             =>   x_msg_count
                    ,   x_msg_data              =>   x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Grp_Lev_In_Dset');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                -- START: Granular Locking, Change time stamp of Dim Set & KPI
                BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
                (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
                   ,   p_dim_set_id         =>  l_bsc_dimset_rec.bsc_dim_set_id
                   ,   x_return_status      =>  x_return_status
                   ,   x_msg_count          =>  x_msg_count
                   ,   x_msg_data           =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET - Assign_Dims_To_Dim_Set');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END LOOP;
        END IF;
        BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_kpi_id                =>  p_kpi_id
            ,   p_dim_set_id            =>  p_dim_set_id
            ,   p_dim_short_names       =>  p_dim_short_names
            ,   p_kpi_flag_change       =>  l_kpi_flag_change
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set Failed: at BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        BSC_BIS_KPI_MEAS_PUB.Create_Default_Kpi_Dim_Object
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_kpi_id                =>  p_kpi_id
            ,   p_dim_set_id            =>  p_dim_set_id
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set Failed: at BSC_DIMENSION_SETS_PUB.Create_Default_Kpi_Dim_Object');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    FOR cd IN c_Dim_Levels LOOP
      l_key_item := NULL;
      FOR i IN 1..l_level_table_names.COUNT LOOP
        IF cd.level_table_name = l_level_table_names(i) THEN
          l_key_item := l_key_item_values(i);
          EXIT;
        END IF;
      END LOOP;
      IF l_key_item IS NOT NULL THEN
        Set_Key_Item_Value (
           p_indicator        =>  p_kpi_id
	 , p_dim_set_id       =>  p_dim_set_id
	 , p_level_table_name =>  cd.level_table_name
	 , p_key_value        =>  l_key_item
         , x_return_status    =>  x_return_status
         , x_msg_count        =>  x_msg_count
         , x_msg_data         =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Assign_Dims_To_Dim_Set;

/*********************************************************************************
                        ASSIGN DIMENSION TO  DIMENSION-SETS
*********************************************************************************/
PROCEDURE Assign_Unassign_Dimensions
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_assign_dim_names      IN              VARCHAR2
    ,   p_unassign_dim_names    IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)IS
  l_unassigns           VARCHAR2(32000);
  l_assigns             VARCHAR2(32000);
  l_unassign            BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
  l_assign              BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;

  l_unassign_dim_objs   VARCHAR2(32000);
  l_temp                VARCHAR2(32000);

  l_flag                BOOLEAN;
  l_level_table_names   BSC_EDIT_VLIST;
  l_key_item_values     FND_TABLE_OF_NUMBER;
  l_key_item            NUMBER;

  CURSOR c_Dim_Levels IS
  SELECT
    level_table_name
  FROM
    bsc_kpi_dim_levels_b
  WHERE
    indicator = p_kpi_id
    AND dim_set_id = p_dim_set_id
  INTERSECT
  SELECT
    column_value level_table_name
  FROM
    TABLE(CAST(l_level_table_names AS BSC_EDIT_VLIST));


BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Assign_Unassign_Dimensions procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_kpi_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_dim_set_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SET_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT
      level_table_name
     ,default_key_value
    BULK COLLECT INTO
      l_level_table_names,
      l_key_item_values
    FROM
      bsc_kpi_dim_levels_b
    WHERE
      indicator = p_kpi_id
      AND dim_set_id = p_dim_set_id
      AND default_key_value IS NOT NULL;

    IF (p_unassign_dim_names IS NOT NULL) THEN
        l_unassigns   :=  p_unassign_dim_names;
        WHILE (is_more(     p_dim_short_names   =>  l_unassigns
                        ,   p_dim_short_name    =>  l_unassign)
        ) LOOP
            l_assigns   :=  p_assign_dim_names;
            l_flag      :=  TRUE;
            WHILE (is_more(     p_dim_short_names   =>  l_assigns
                            ,   p_dim_short_name    =>  l_assign)
            ) LOOP
                IF(l_unassign = l_assign) THEN
                    l_flag  :=  FALSE;
                    EXIT;
                END IF;
            END LOOP;
            IF(l_flag) THEN
                IF (l_unassign_dim_objs IS NULL) THEN
                    l_unassign_dim_objs    :=  l_unassign;
                ELSE
                    l_unassign_dim_objs    :=  l_unassign_dim_objs||', '||l_unassign;
                END IF;
            END IF;
        END LOOP;
        IF (l_unassign_dim_objs IS NOT NULL) THEN
            BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set
            (       p_commit                =>  FND_API.G_FALSE
                ,   p_kpi_id                =>  p_kpi_id
                ,   p_dim_set_id            =>  p_dim_set_id
                ,   p_dim_short_names       =>  l_unassign_dim_objs
                ,   p_time_stamp            =>  p_time_stamp
                ,   x_return_status         =>  x_return_status
                ,   x_msg_count             =>  x_msg_count
                ,   x_msg_data              =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Assign_Unassign_Dimensions Failed: at BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_kpi_id                =>  p_kpi_id
        ,   p_dim_set_id            =>  p_dim_set_id
        ,   p_dim_short_names       =>  p_assign_dim_names
        ,   p_time_stamp            =>  p_time_stamp
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Assign_Unassign_Dimensions Failed: at BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Restore old key item values if any are set
    FOR cd IN c_Dim_Levels LOOP
      l_key_item := NULL;
      FOR i IN 1..l_level_table_names.COUNT LOOP
        IF cd.level_table_name = l_level_table_names(i) THEN
          l_key_item := l_key_item_values(i);
          EXIT;
        END IF;
      END LOOP;
      IF l_key_item IS NOT NULL THEN
        Set_Key_Item_Value (
           p_indicator        =>  p_kpi_id
	 , p_dim_set_id       =>  p_dim_set_id
	 , p_level_table_name =>  cd.level_table_name
	 , p_key_value        =>  l_key_item
         , x_return_status    =>  x_return_status
         , x_msg_count        =>  x_msg_count
         , x_msg_data         =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;
/*************************************************************
  List Button validation.For a list button the condition is that
  all the dimesnion sets within the tab (irrespective of whether they are
  in the same KPI or different KPIs) the dimesnion objects should be the same
  So when a dimension set is being updated it has to be validate that
  it contains all the common dimension objects.
  The validation is done for shared kpis also internally.
/************************************************************/
    BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button
    (
          p_Kpi_Id        =>  p_kpi_id
        , p_Dim_Level_Id  =>  NULL
        , x_return_status =>  x_return_status
        , x_msg_count     =>  x_msg_count
        , x_msg_data      =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
     --dbms_output.PUT_LINE('BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button Failed:   BSC_BIS_KPI_MEAS_PUB.Create_Dim_Set');
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Assign_Unassign_Dimensions procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Assign_Unassign_Dimensions ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Assign_Unassign_Dimensions ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Assign_Unassign_Dimensions ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Assign_Unassign_Dimensions ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Assign_Unassign_Dimensions;

/*********************************************************************************
                        REMOVE DIMENSION FROM DIMENSION-SETS
*********************************************************************************/
PROCEDURE Unassign_Dims_From_Dim_Set
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_dim_short_names       IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)IS
    l_bsc_dimset_rec        BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_count                 NUMBER := 0;
    l_dim_short_names       VARCHAR2(32000);
    l_dim_short_name        BSC_SYS_DIM_GROUPS_TL.short_name%TYPE;
    l_kpi_flag_change       BOOLEAN := FALSE;

    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator =   p_kpi_id
    AND     Prototype_Flag   <>  2;

    CURSOR   c_dim_index IS
    SELECT   B.Short_Name
    FROM     BSC_KPI_DIM_GROUPS     A
          ,  BSC_SYS_DIM_GROUPS_VL  B
    WHERE    A.Indicator    =  p_kpi_id
    AND      A.Dim_Set_Id   =  p_dim_set_id
    AND      A.Dim_Group_ID =  B.Dim_Group_ID
    ORDER BY A.Dim_Group_Index;
BEGIN
    SAVEPOINT UnAssBSCDimToDSetPMD;
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_kpi_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_dim_set_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SET_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_bsc_dimset_rec.Bsc_Kpi_Id         :=  p_kpi_id;      --number
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Kpi_Id                   <'||l_bsc_dimset_rec.Bsc_Kpi_Id||'>');

    -- Verify that this is not a Shared KPI.
    SELECT  share_flag
    INTO    l_count
    FROM    BSC_KPIS_B
    WHERE  indicator = l_bsc_dimset_rec.Bsc_Kpi_Id;
    IF (l_count = 2) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_bsc_dimset_rec.Bsc_Dim_Set_Id     :=  p_dim_set_id;  --number
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Dim_Set_Id               <'||l_bsc_dimset_rec.Bsc_Dim_Set_Id||'>');

    SELECT COUNT(*) INTO l_count FROM BSC_KPI_DIM_SETS_VL
    WHERE indicator  = l_bsc_dimset_rec.Bsc_Kpi_Id
    AND   dim_set_id = l_bsc_dimset_rec.Bsc_Dim_Set_Id;
    IF (l_count = 0) THEN
        FND_MESSAGE.SET_NAME('BSC',        'BSC_INCORRECT_KPI_DIMSET');
        FND_MESSAGE.SET_TOKEN('KPI_ID',     l_bsc_dimset_rec.Bsc_Kpi_Id);
        FND_MESSAGE.SET_TOKEN('DIM_SET_ID', l_bsc_dimset_rec.Bsc_Dim_Set_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- START Granular Locking
    BSC_BIS_LOCKS_PUB.LOCK_DIM_SET
    (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
       ,   p_Dim_Set_Id         =>  p_dim_set_id
       ,   p_time_stamp         =>  p_time_stamp
       ,   x_return_status      =>  x_return_status
       ,   x_msg_count          =>  x_msg_count
       ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DIM_SET - Unassign_Dims_From_Dim_Set');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- END Granular Locking
    IF(p_dim_short_names IS NOT NULL) THEN
        l_count := 0;
        l_dim_short_names   :=  p_dim_short_names;
        -- Aditya added for Incremental Changes
        -- Deleting a Dimension from a Dimension Set should be flagged as a Strucutural change
        -- for the KPI under consideration only.
        --BSC_DESIGNER_PVT.ActionFlag_Change(p_kpi_id, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
        WHILE (Is_More(     p_dim_short_names   =>  l_dim_short_names
                        ,   p_dim_short_name    =>  l_dim_short_name)
        ) LOOP
            SELECT  COUNT(*)  INTO l_count
            FROM    BSC_SYS_DIM_GROUPS_VL  A
                ,   BSC_KPI_DIM_GROUPS     B
            WHERE   A.short_name   = l_dim_short_name
            AND     A.Dim_Group_Id = B.Dim_Group_Id
            AND     B.Indicator    = l_bsc_dimset_rec.Bsc_Kpi_Id
            AND     B.Dim_Set_Id   = p_dim_set_id;
            IF (l_count <> 0) THEN
                SELECT  dim_group_id
                INTO    l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id
                FROM    BSC_SYS_DIM_GROUPS_VL
                WHERE   short_name = l_dim_short_name;
                --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id      <'||l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id||'>');
                l_kpi_flag_change   := TRUE;
                BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset
                (       p_commit                =>  FND_API.G_FALSE
                    ,   p_Dim_Set_Rec           =>  l_bsc_dimset_rec
                    ,   p_create_Dim_Lev_Grp    =>  FALSE
                    ,   x_return_status         =>  x_return_status
                    ,   x_msg_count             =>  x_msg_count
                    ,   x_msg_data              =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set Failed: at BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset <'||x_msg_data||'>');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END LOOP;
    END IF;

    -- START: Granular Locking, Change time stamp of Dim Set & KPI
    BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
    (      p_Kpi_Id             =>  p_Kpi_Id
       ,   p_dim_set_id         =>  l_bsc_dimset_rec.bsc_dim_set_id
       ,   x_return_status      =>  x_return_status
       ,   x_msg_count          =>  x_msg_count
       ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set Failed: at BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --repeat the steps above for all the shared indicators
    FOR cd IN c_kpi_ids LOOP
        l_bsc_dimset_rec.Bsc_Kpi_Id :=  cd.indicator;
        --dbms_output.PUT_LINE('Within Shared Indicator Loop  KPI_ID is <'||l_bsc_dimset_rec.Bsc_Kpi_Id||'>');
        IF(p_dim_short_names IS NOT NULL) THEN
            l_count := 0;
            l_dim_short_names   :=  p_dim_short_names;
            -- Aditya added for Incremental Changes
            --BSC_DESIGNER_PVT.ActionFlag_Change(l_bsc_dimset_rec.Bsc_Kpi_Id, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
            WHILE (Is_More(     p_dim_short_names   =>  l_dim_short_names
                            ,   p_dim_short_name    =>  l_dim_short_name)
            ) LOOP
                SELECT  COUNT(*)  INTO l_count
                FROM    BSC_SYS_DIM_GROUPS_VL  A
                    ,   BSC_KPI_DIM_GROUPS     B
                WHERE   A.short_name   = l_dim_short_name
                AND     A.Dim_Group_Id = B.Dim_Group_Id
                AND     B.Indicator    = l_bsc_dimset_rec.Bsc_Kpi_Id
                AND     B.Dim_Set_Id   = p_dim_set_id;
                IF (l_count <> 0) THEN
                    SELECT  dim_group_id
                    INTO    l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id
                    FROM    BSC_SYS_DIM_GROUPS_VL
                    WHERE   short_name = l_dim_short_name;
                    -- START Granular Locking
                    BSC_BIS_LOCKS_PUB.LOCK_DIM_SET
                    (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
                       ,   p_Dim_Set_Id         =>  p_dim_set_id
                       ,   p_time_stamp         =>  NULL -- should not pass time_stamp here
                       ,   x_return_status      =>  x_return_status
                       ,   x_msg_count          =>  x_msg_count
                       ,   x_msg_data           =>  x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DIM_SET - Unassign_Dims_From_Dim_Set');
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                    -- END Granular Locking
                    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id      <'||l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id||'>');
                    BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset
                    (       p_commit                =>  FND_API.G_FALSE
                        ,   p_Dim_Set_Rec           =>  l_bsc_dimset_rec
                        ,   p_create_Dim_Lev_Grp    =>  FALSE
                        ,   x_return_status         =>  x_return_status
                        ,   x_msg_count             =>  x_msg_count
                        ,   x_msg_data              =>  x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set Failed: at BSC_DIMENSION_SETS_PUB.Delete_Dim_Group_In_Dset <'||x_msg_data||'>');
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
            END LOOP;
            -- START: Granular Locking, Change time stamp of Dim Set & KPI
            BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
            (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
               ,   p_dim_set_id         =>  l_bsc_dimset_rec.bsc_dim_set_id
               ,   x_return_status      =>  x_return_status
               ,   x_msg_count          =>  x_msg_count
               ,   x_msg_data           =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET - Unassign_Dims_From_Dim_Set');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- END: Granular Locking, Change time stamp of Dim Set & KPI
        END IF;
    END LOOP;
    IF (p_dim_short_names IS NOT NULL) THEN
        FOR cd IN c_dim_index LOOP
            IF (l_dim_short_names IS NULL) THEN
                l_dim_short_names   :=  cd.Short_Name;
            ELSE
                l_dim_short_names   :=  l_dim_short_names||', '||cd.Short_Name;
            END IF;
        END LOOP;
        BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets
        (       p_commit                =>    FND_API.G_FALSE
            ,   p_kpi_id                =>    p_kpi_id
            ,   p_dim_set_id            =>    p_dim_set_id
            ,   p_dim_short_names       =>    l_dim_short_names
            ,   p_kpi_flag_change       =>    l_kpi_flag_change
            ,   x_return_status         =>    x_return_status
            ,   x_msg_count             =>    x_msg_count
            ,   x_msg_data              =>    x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set Failed: at BSC_BIS_KPI_MEAS_PUB.Order_Dims_In_DSets');
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    BSC_BIS_KPI_MEAS_PUB.Create_Default_Kpi_Dim_Object
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_kpi_id                =>  p_kpi_id
        ,   p_dim_set_id            =>  p_dim_set_id
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );

    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set Failed: at BSC_DIMENSION_SETS_PUB.Create_Default_Kpi_Dim_Object');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (p_dim_short_names IS NOT NULL) THEN
       BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button
       (
          p_Kpi_Id          =>  p_kpi_id
         , p_Dim_Level_Id    =>  NULL
         , x_return_status   =>  x_return_status
         , x_msg_count       =>  x_msg_count
         , x_msg_data        =>  x_msg_data
       );
        BSC_DIM_FILTERS_PUB.Check_Filters_Not_Apply_By_KPI
        (       p_Kpi_Id          =>  p_kpi_id
            ,   x_return_status   =>  x_return_status
            ,   x_msg_count       =>  x_msg_count
            ,   x_msg_data        =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set failed at BSC_BIS_KPI_MEAS_PUB.Check_Filters_Not_Apply');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Unassign_Dims_From_Dim_Set;
/*********************************************************************************
                      UPDATE DIMENSION LEVEL SELECTIONS
*********************************************************************************/
PROCEDURE Create_Dim_Grp_Lev_In_Dset
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_dim_short_names       IN              VARCHAR2
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)IS
    l_bsc_dimset_rec        BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_index                 NUMBER := 0;
    l_count                 NUMBER;
    l_dim_short_names       VARCHAR2(32000);
    l_dim_short_name        BSC_SYS_DIM_GROUPS_TL.short_name%TYPE;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Create_Dim_Grp_Lev_In_Dset procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_bsc_dimset_rec.Bsc_Dim_Level_Help                 := 'XXX';
    l_bsc_dimset_rec.Bsc_Dim_Level_Long_Name            := 'XXX';
    l_bsc_dimset_rec.Bsc_Dim_Tot_Disp_Name              := 'XXX';
    l_bsc_dimset_rec.Bsc_Dim_Comp_Disp_Name             := 'XXX';
    l_bsc_dimset_rec.Bsc_Dset_Comp_Order                :=  0;
    l_bsc_dimset_rec.Bsc_Dset_Dim_Level_Index           :=  1;
    l_bsc_dimset_rec.Bsc_Dset_Parent_Level_Rel          := 'XXX';
    l_bsc_dimset_rec.Bsc_Dset_Position                  :=  0;
    l_bsc_dimset_rec.Bsc_Dset_Status                    :=  0;
    l_bsc_dimset_rec.Bsc_Dset_Target_Level              :=  1;
    l_bsc_dimset_rec.Bsc_Dset_User_Level0               :=  0;
    l_bsc_dimset_rec.Bsc_Dset_User_Level1               :=  0;
    l_bsc_dimset_rec.Bsc_Dset_User_Level1_Default       :=  0;
    l_bsc_dimset_rec.Bsc_Dset_User_Level2               :=  0;
    l_bsc_dimset_rec.Bsc_Dset_User_Level2_Default       :=  0;
    l_bsc_dimset_rec.Bsc_Dset_Value_Order               :=  0;
    l_bsc_dimset_rec.Bsc_Kpi_Id                         :=  p_kpi_id;
    l_bsc_dimset_rec.Bsc_Level_Name                     := 'XXX';
    l_bsc_dimset_rec.Bsc_View_Name                      := 'XXX';
    l_bsc_dimset_rec.Bsc_New_Dset                       := 'Y';
    l_bsc_dimset_rec.Bsc_Option_Id                      :=  0;
    l_bsc_dimset_rec.Bsc_Pk_Col                         := 'XXX';
    l_bsc_dimset_rec.Bsc_Dim_Set_Id                     :=  p_dim_set_id;
    IF (p_dim_short_names IS NOT NULL) THEN
        l_bsc_dimset_rec.Bsc_Dset_Parent_Level_Rel      :=  NULL;
        l_bsc_dimset_rec.Bsc_Dset_No_Items              :=  0;
        l_bsc_dimset_rec.Bsc_Dset_Level_Display         :=  0;
        l_bsc_dimset_rec.Bsc_Dset_Default_Type          :=  0;
        l_bsc_dimset_rec.Bsc_Dset_Default_Value         := 'T';
        l_bsc_dimset_rec.Bsc_Dset_Parent_In_Total       :=  2;
        l_bsc_dimset_rec.Bsc_Dset_Total0                :=  0;
        l_bsc_dimset_rec.Bsc_Dset_Status                :=  2;
        l_bsc_dimset_rec.Bsc_Dset_User_Level0           :=  2;
        l_bsc_dimset_rec.Bsc_Dset_Filter_Value          :=  0;
        l_bsc_dimset_rec.Bsc_Dset_User_Level1           :=  2;
        l_bsc_dimset_rec.Bsc_Dset_User_Level1_Default   :=  2;
        l_bsc_dimset_rec.Bsc_Dset_User_Level2           :=  NULL;
        l_bsc_dimset_rec.Bsc_Dset_User_Level2_Default   :=  NULL;
        l_bsc_dimset_rec.Bsc_Dim_Tot_Disp_Name          := 'ALL';
        l_bsc_dimset_rec.Bsc_Dim_Comp_Disp_Name         := 'COMPARISON';
        l_bsc_dimset_rec.Bsc_New_Dset                   := 'N';
        l_dim_short_names   := p_dim_short_names;
        WHILE (Is_More(  p_dim_short_names   =>  l_dim_short_names
                      ,  p_dim_short_name    =>  l_dim_short_name)
        ) LOOP
            SELECT COUNT(*) INTO l_count
            FROM   BSC_KPI_DIM_GROUPS     A
                ,  BSC_SYS_DIM_GROUPS_VL  B
            WHERE  A.Dim_Group_Id  = B.Dim_Group_Id
            AND    A.Indicator     = l_bsc_dimset_rec.bsc_kpi_id
            AND    A.Dim_Set_Id    = l_bsc_dimset_rec.Bsc_Dim_Set_Id
            AND    B.Short_Name    = l_dim_short_name;
            IF (l_count = 0) THEN
                --dbms_output.PUT_LINE('l_dim_short_name                 <'||l_dim_short_name||'>');
                --l_bsc_dimset_rec.Bsc_Level_Name := BSC_PMF_UI_API_PUB.get_Dim_Level_View_Name(cd.short_name);
                --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Level_Name  <'||l_bsc_dimset_rec.Bsc_Level_Name||'>');
                SELECT  NVL(MAX(Dim_Group_Index) + 1, 0)
                INTO    l_bsc_dimset_rec.Bsc_Dim_Level_Group_Index
                FROM    BSC_KPI_DIM_GROUPS
                WHERE   indicator  = l_bsc_dimset_rec.bsc_kpi_id
                AND     dim_set_id = l_bsc_dimset_rec.bsc_dim_set_id;

                SELECT  dim_group_id
                INTO    l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id
                FROM    BSC_SYS_DIM_GROUPS_VL
                WHERE   short_name = l_dim_short_name;
                --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id        <'||l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id||'>');
                -- START : Granular Locking
                BSC_BIS_LOCKS_PUB.LOCK_DIM_GROUP
                (       p_dim_group_id          =>  l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id
                    ,   p_time_stamp            =>  NULL
                    ,   x_return_status         =>  x_return_status
                    ,   x_msg_count             =>  x_msg_count
                    ,   x_msg_data              =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DIM_GROUP Failed: at Create_Dim_Grp_Lev_In_Dset');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                -- END : Granular Locking
                BSC_DIMENSION_SETS_PUB.Create_Dim_Group_In_Dset--insert into BSC_KPI_DIM_GROUPS
                (       p_commit                =>  FND_API.G_FALSE
                    ,   p_Dim_Set_Rec           =>  l_bsc_dimset_rec
                    ,   p_create_Dim_Lev_Grp    =>  FALSE
                    ,   x_return_status         =>  x_return_status
                    ,   x_msg_count             =>  x_msg_count
                    ,   x_msg_data              =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_GRP_LEV_IN_DSET Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Group_In_Dset <'||x_msg_data||'>');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                BSC_DIMENSION_SETS_PUB.Create_Dim_Level_Properties--insert into BSC_KPI_DIM_LEVEL_PROPERTIES
                (       p_commit            =>  FND_API.G_FALSE
                    ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                    ,   x_return_status     =>  x_return_status
                    ,   x_msg_count         =>  x_msg_count
                    ,   x_msg_data          =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_GRP_LEV_IN_DSET Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Level_Properties <'||x_msg_data||'>');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                BSC_DIMENSION_SETS_PUB.Create_Dim_Levels
                (       p_commit            =>  FND_API.G_FALSE
                    ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                    ,   x_return_status     =>  x_return_status
                    ,   x_msg_count         =>  x_msg_count
                    ,   x_msg_data          =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_GRP_LEV_IN_DSET Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Levels <'||x_msg_data||'>');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END LOOP;
    ELSE
        IF (l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id IS NULL) THEN
            SELECT  COUNT(*)
            INTO    l_count
            FROM    BSC_KPI_DIM_LEVELS_B
            WHERE   INDICATOR   = l_bsc_dimset_rec.Bsc_Kpi_Id
            AND     DIM_SET_ID  = l_bsc_dimset_rec.Bsc_Dim_Set_Id;
            l_bsc_dimset_rec.Bsc_Dset_Dim_Level_Index := l_count + 1;
        END IF;
        BSC_DIMENSION_SETS_PUB.Create_Dim_Levels
        (       p_commit            =>  FND_API.G_FALSE
            ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
            ,   x_return_status     =>  x_return_status
            ,   x_msg_count         =>  x_msg_count
            ,   x_msg_data          =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_GRP_LEV_IN_DSET Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Levels <'||x_msg_data||'>');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- START: Granular Locking, Change time stamp of Dim Set & KPI
    BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
    (      p_Kpi_Id             =>  p_Kpi_Id
       ,   p_dim_set_id         =>  l_bsc_dimset_rec.bsc_dim_set_id
       ,   x_return_status      =>  x_return_status
       ,   x_msg_count          =>  x_msg_count
       ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET: at BSC_DIMENSION_SETS_PUB.Create_Dim_Grp_Lev_In_Dset');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --dbms_output.PUT_LINE('END Setting TIME STAMP');
    -- END: Granular Locking, Change time stamp of Dim Set & KPI
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Create_Dim_Grp_Lev_In_Dset procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Create_Dim_Grp_Lev_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Create_Dim_Grp_Lev_In_Dset ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Create_Dim_Grp_Lev_In_Dset ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Create_Dim_Grp_Lev_In_Dset ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Create_Dim_Grp_Lev_In_Dset;
/*********************************************************************************
                        ASSIGN DIMENSION-SETS
*********************************************************************************/
PROCEDURE Assign_DSet_Analysis_Options
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_analysis_grp_id       IN              NUMBER
    ,   p_option_id             IN              NUMBER
    ,   p_time_stamp            IN              VARCHAR2   := NULL  -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)IS

    l_bsc_dimset_rec        BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_count                 NUMBER := 0;

    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator =   p_kpi_id
    AND     Prototype_Flag   <>  2;
BEGIN
    SAVEPOINT AssBSCDSetPMD;
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Assign_DSet_Analysis_Options procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_kpi_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_dim_set_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SET_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_analysis_grp_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'Analysis Group ID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_option_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', 'Option ID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_bsc_dimset_rec.Bsc_Kpi_Id         :=  p_kpi_id;      --number
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Kpi_Id                   <'||l_bsc_dimset_rec.Bsc_Kpi_Id||'>');
    l_bsc_dimset_rec.Bsc_Dim_Set_Id     :=  p_dim_set_id;      --number
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Dim_Set_Id                  <'||l_bsc_dimset_rec.Bsc_Dim_Set_Id||'>');
    l_bsc_dimset_rec.Bsc_Analysis_Id    :=  p_analysis_grp_id;
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Analysis_Id              <'||l_bsc_dimset_rec.Bsc_Analysis_Id||'>');
    l_bsc_dimset_rec.Bsc_Option_Id      :=  p_option_id;
    --dbms_output.PUT_LINE('l_bsc_dimset_rec.Bsc_Option_Id                <'||l_bsc_dimset_rec.Bsc_Option_Id||'>');


    SELECT  COUNT(Indicator) INTO l_Count
    FROM    BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE   Dim_Set_Id        = l_bsc_dimset_rec.Bsc_Dim_Set_Id
    AND     Indicator         = l_bsc_dimset_rec.Bsc_Kpi_Id
    AND     Analysis_Group_Id = l_bsc_dimset_rec.Bsc_Analysis_Id
    AND     Option_Id         = l_bsc_dimset_rec.Bsc_Option_Id;

    IF (l_Count = 0) THEN
        SELECT COUNT(*) INTO l_count FROM BSC_KPI_DIM_SETS_VL
        WHERE indicator  = l_bsc_dimset_rec.Bsc_Kpi_Id
        AND   dim_set_id = l_bsc_dimset_rec.Bsc_Dim_Set_Id;
        IF (l_count = 0) THEN
            FND_MESSAGE.SET_NAME('BSC',        'BSC_INCORRECT_KPI_DIMSET');
            FND_MESSAGE.SET_TOKEN('KPI_ID',     l_bsc_dimset_rec.Bsc_Kpi_Id);
            FND_MESSAGE.SET_TOKEN('DIM_SET_ID', l_bsc_dimset_rec.Bsc_Dim_Set_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        BSC_DIMENSION_SETS_PUB.Update_Kpi_Analysis_Options_B
        (       p_commit            =>  FND_API.G_FALSE
            ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
            ,   x_return_status     =>  x_return_status
            ,   x_msg_count         =>  x_msg_count
            ,   x_msg_data          =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Assign_DSet_Analysis_Options Failed: at BSC_DIMENSION_SETS_PUB.Update_Kpi_Analysis_Options_B <'||x_msg_data||'>');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --copied from VB Code
        BSC_DESIGNER_PVT.Deflt_Update_AOPTS(l_bsc_dimset_rec.Bsc_Kpi_Id);
        BSC_DESIGNER_PVT.ActionFlag_Change(l_bsc_dimset_rec.Bsc_Kpi_Id , BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
        --repeat the steps above for all the shared indicators
        FOR cd IN c_kpi_ids LOOP
            l_bsc_dimset_rec.Bsc_Kpi_Id :=  cd.indicator;
            --dbms_output.PUT_LINE('Within Shared Indicator Loop  KPI_ID is <'||l_bsc_dimset_rec.Bsc_Kpi_Id||'>');
            SELECT COUNT(*) INTO l_count FROM BSC_KPI_DIM_SETS_VL
            WHERE indicator  = l_bsc_dimset_rec.Bsc_Kpi_Id
            AND   dim_set_id = l_bsc_dimset_rec.Bsc_Dim_Set_Id;
            IF (l_count = 0) THEN
                FND_MESSAGE.SET_NAME('BSC',        'BSC_INCORRECT_KPI_DIMSET');
                FND_MESSAGE.SET_TOKEN('KPI_ID',     l_bsc_dimset_rec.Bsc_Kpi_Id);
                FND_MESSAGE.SET_TOKEN('DIM_SET_ID', l_bsc_dimset_rec.Bsc_Dim_Set_Id);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            BSC_DIMENSION_SETS_PUB.Update_Kpi_Analysis_Options_B
            (       p_commit            =>  FND_API.G_FALSE
                ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                ,   x_return_status     =>  x_return_status
                ,   x_msg_count         =>  x_msg_count
                ,   x_msg_data          =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Assign_DSet_Analysis_Options Failed: at BSC_DIMENSION_SETS_PUB.Update_Kpi_Analysis_Options_B <'||x_msg_data||'>');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            BSC_DESIGNER_PVT.ActionFlag_Change(l_bsc_dimset_rec.Bsc_Kpi_Id , BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
        END LOOP;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Assign_DSet_Analysis_Options procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO AssBSCDSetPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO AssBSCDSetPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO AssBSCDSetPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Assign_DSet_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Assign_DSet_Analysis_Options ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO AssBSCDSetPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Assign_DSet_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Assign_DSet_Analysis_Options ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Assign_DSet_Analysis_Options;

/*********************************************************************************
*********************************************************************************/
FUNCTION Is_More
(       p_dim_short_names   IN  OUT NOCOPY  VARCHAR2
    ,   p_dim_short_name        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
BEGIN
    IF (p_dim_short_names IS NOT NULL) THEN
        l_pos_ids           := INSTR(p_dim_short_names,   ',');
        IF (l_pos_ids > 0) THEN
            p_dim_short_name  :=  TRIM(SUBSTR(p_dim_short_names,    1,    l_pos_ids - 1));
            p_dim_short_names :=  TRIM(SUBSTR(p_dim_short_names,    l_pos_ids + 1));
        ELSE
            p_dim_short_name  :=  TRIM(p_dim_short_names);
            p_dim_short_names :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;
/*********************************************************************************
*********************************************************************************/
PROCEDURE get_Dim_Set_Source_Info
(   p_Indicator     IN  NUMBER
  , p_DimSetId      IN  NUMBER
  , x_Source        OUT NOCOPY  VARCHAR2
  , x_Data_Set_Id   OUT NOCOPY  NUMBER
) IS
    CURSOR   c_dimSetSource IS
    SELECT   LEVEL_SOURCE
    FROM     BSC_KPI_DIM_LEVELS_VL
    WHERE    INDICATOR    = p_Indicator
    AND      DIM_SET_ID   = p_DimSetId
    AND      LEVEL_SOURCE IS NOT NULL;

    CURSOR   c_source IS
    SELECT   D.SOURCE
           , D.DataSet_ID
    FROM     BSC_SYS_DATASETS_VL        D
           , BSC_DB_DATASET_DIM_SETS_V  B
    WHERE    D.DATASET_ID = B.DATASET_ID
    AND      B.INDICATOR  = p_Indicator
    AND      B.DIM_SET_ID = p_DimSetId;
BEGIN
    IF (c_dimSetSource%ISOPEN) THEN
        CLOSE c_dimSetSource;
    END IF;
    OPEN c_dimSetSource;
        FETCH c_dimSetSource INTO x_Source;
    CLOSE c_dimSetSource;
    IF (x_Source IS NULL) THEN
        IF (c_source%ISOPEN) THEN
            CLOSE c_source;
        END IF;
        OPEN c_source;
            FETCH c_source INTO x_Source, x_Data_Set_Id;
        CLOSE c_source;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_dimSetSource%ISOPEN) THEN
            CLOSE c_dimSetSource;
        END IF;
        IF (c_source%ISOPEN) THEN
            CLOSE c_source;
        END IF;
END get_Dim_Set_Source_Info;

/*********************************************************************************
*********************************************************************************/
FUNCTION get_DimensionSetSource
(   p_Indicator IN NUMBER
  , p_DimSetId  IN NUMBER
) RETURN VARCHAR2
IS
    l_source            BSC_SYS_DIM_LEVELS_B.SOURCE%TYPE;
    l_data_set_id       BSC_SYS_DATASETS_B.Dataset_Id%TYPE;
BEGIN
    BSC_BIS_KPI_MEAS_PUB.get_Dim_Set_Source_Info
    (     p_Indicator   =>  p_Indicator
        , p_DimSetId    =>  p_DimSetId
        , x_Source      =>  l_source
        , x_Data_Set_Id =>  l_data_set_id
    );
    RETURN l_source;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'BSC';
END get_DimensionSetSource;

/*********************************************************************************/
FUNCTION GET_AO_NAME
(       p_indicator     in  NUMBER
    ,   p_a0            in  NUMBER
    ,   p_a1            in  NUMBER
    ,   p_a2            in  NUMBER
    ,   p_group_id      in  NUMBER
) RETURN VARCHAR2 IS
    l_group_id      NUMBER;

    h_ag_count      NUMBER;
    l_anal_name     bsc_kpi_analysis_options_tl.name%TYPE := NULL;
    h_ag1_depend    NUMBER;
    h_ag2_depend    NUMBER;
    h_ag_depend     NUMBER;
BEGIN
    l_group_id := p_group_id;
    SELECT  MAX( ANALYSIS_GROUP_ID)
    INTO    h_ag_count
    FROM    BSC_KPI_ANALYSIS_GROUPS
    WHERE   INDICATOR   =   p_indicator;
    IF (l_group_id= 0) THEN
        SELECT  NAME INTO l_anal_name
        FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
        WHERE   ANALYSIS_GROUP_ID =0
        AND     OPTION_ID = p_a0
        AND     INDICATOR = p_indicator;
    ELSIF(l_group_id =1 AND h_ag_count >0) THEN
        SELECT  DEPENDENCY_FLAG INTO h_ag_depend
        FROM    BSC_KPI_ANALYSIS_GROUPS
        WHERE   ANALYSIS_GROUP_ID =1
        AND     INDICATOR   =   p_indicator;
        IF h_ag_depend = 0 THEN
            SELECT  NAME INTO l_anal_name
            FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
            WHERE   ANALYSIS_GROUP_ID = 1
            AND     OPTION_ID   =   p_a1
            AND     INDICATOR   =   p_indicator;
        ELSE
            BEGIN
                SELECT  NAME INTO l_anal_name
                FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
                WHERE   ANALYSIS_GROUP_ID =1
                AND     OPTION_ID         = p_a1
                AND     PARENT_OPTION_ID  = p_a0
                AND     INDICATOR         = p_indicator;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;
        END IF;
    ELSIF((l_group_id =2 AND h_ag_count >1)) THEN
        SELECT  DEPENDENCY_FLAG
        INTO    h_ag1_depend
        FROM    BSC_KPI_ANALYSIS_GROUPS
        WHERE   ANALYSIS_GROUP_ID =1
        AND     INDICATOR   =   p_indicator;

        SELECT  DEPENDENCY_FLAG
        INTO    h_ag2_depend
        FROM    BSC_KPI_ANALYSIS_GROUPS
        WHERE   ANALYSIS_GROUP_ID = 2
        AND     INDICATOR   =   p_indicator;
        IF h_ag2_depend = 0 THEN
            SELECT  NAME
            INTO    l_anal_name
            FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
            WHERE   ANALYSIS_GROUP_ID =2
            AND     OPTION_ID=p_a2
            AND     INDICATOR=p_indicator;
        ELSE
            IF h_ag2_depend = 1 AND h_ag1_depend = 0 THEN
                BEGIN
                    SELECT  NAME
                    INTO    l_anal_name
                    FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
                    WHERE   ANALYSIS_GROUP_ID   =   2
                    AND     OPTION_ID           =   p_a2
                    AND     PARENT_OPTION_ID    =   p_a1
                    AND     INDICATOR           =   p_indicator;
            EXCEPTION
                WHEN OTHERS
                    THEN NULL;
            END;
        ELSE
            BEGIN
                SELECT  NAME
                INTO    l_anal_name
                FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
                WHERE   ANALYSIS_GROUP_ID     = 2
                AND     OPTION_ID             = p_a2
                AND     PARENT_OPTION_ID      = p_a1
                AND     GRANDPARENT_OPTION_ID = p_a0
                AND     INDICATOR             = p_indicator;
            EXCEPTION
                WHEN OTHERS THEN
                   NULL;
            END;
        END IF;
    END IF;
END IF;
RETURN l_anal_name;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END GET_AO_NAME;

/*********************************************************************************/
FUNCTION GET_SERIES_COUNT
(       p_indicator     IN  NUMBER
    ,   p_a0            IN  NUMBER
    ,   p_a1            IN  NUMBER
    ,   p_a2            IN  NUMBER
) RETURN NUMBER IS

    l_count   NUMBER    :=  0;

    CURSOR c_SeriesCount IS
    SELECT COUNT(SERIES_ID)
    FROM   BSC_KPI_ANALYSIS_MEASURES_VL
    WHERE  INDICATOR     = p_indicator
    AND    ANALYSIS_OPTION0 = p_a0
    AND    ANALYSIS_OPTION1 = p_a1
    AND    ANALYSIS_OPTION2 = p_a2;
BEGIN
    IF (c_SeriesCount%ISOPEN)THEN
        CLOSE c_SeriesCount;
    END IF;

    OPEN    c_SeriesCount;
    FETCH   c_SeriesCount INTO l_count;
    CLOSE   c_SeriesCount;

    RETURN l_count;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END GET_SERIES_COUNT;

/*********************************************************************************
         API TO UPDATE PMF/BSC MEASURES/ANALYSIS OPTIONS WITHIN AN INDICATOR
*********************************************************************************/
PROCEDURE Update_KPI_Analysis_Options
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN          NUMBER
    ,   p_data_source           IN          VARCHAR2  --this parameter is not needed and can be removed from the API
    ,   p_analysis_group_id     IN          NUMBER
    ,   p_analysis_option_id0   IN          NUMBER
    ,   p_analysis_option_id1   IN          NUMBER
    ,   p_analysis_option_id2   IN          NUMBER
    ,   p_series_id             IN          NUMBER
    ,   p_data_set_id           IN          NUMBER
    ,   p_dim_set_id            IN          NUMBER
    ,   p_option0_Name          IN          VARCHAR2
    ,   p_option1_Name          IN          VARCHAR2
    ,   p_option2_Name          IN          VARCHAR2
    ,   p_measure_short_name    IN          VARCHAR2
    ,   p_dim_obj_short_names   IN          VARCHAR2  --comma seperated dimension objects needed for PMF Measures
    ,   p_default_short_names   IN          VARCHAR2  :=  NULL
    ,   p_view_by_name          IN          VARCHAR2  :=  NULL
    ,   p_measure_name          IN          VARCHAR2  --BSC_KPI_ANALYSIS_MEASURES_VL.name
    ,   p_measure_help          IN          VARCHAR2  --BSC_KPI_ANALYSIS_MEASURES_VL.help
    ,   p_default_value         IN          NUMBER
    ,   p_time_stamp            IN          VARCHAR2  := NULL
    ,   p_update_ana_opt        IN          BOOLEAN := FALSE
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
    l_Bsc_Anal_Opt_Rec      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
    l_bsc_dimset_rec        BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_measure_short_name    BSC_SYS_MEASURES.Short_Name%TYPE;
    l_dim_short_name        BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE := 'DGRP_';
    l_temp_var              VARCHAR2(32000);
    l_count                 NUMBER;
    l_alias                 VARCHAR2(4);

    l_data_source           BSC_SYS_DIM_LEVELS_B.Source%TYPE;
    l_temp_data_source      BSC_SYS_DIM_LEVELS_B.Source%TYPE;
    l_data_set_id           BSC_SYS_DATASETS_B.Dataset_Id%TYPE;
    l_dim_obj_short_names   VARCHAR2(32000);
    l_default_short_names   VARCHAR2(32000);
    l_view_by_name          BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE;
    l_dim_set_id            BSC_KPI_DIM_SETS_TL.dim_set_id%TYPE;

    l_dim_obj_names         VARCHAR2(32000);
    l_dim_obj_name          VARCHAR2(30);
    l_index                 NUMBER := 0;
    l_namecount             NUMBER;

    l_dim_obj_tmp_short_names   VARCHAR2(32000);

    --START ADEED BY PETER
    -- Need the following to keep track of whether data set has changed (3169904)
    l_old_data_set_id       BSC_SYS_DATASETS_B.Dataset_Id%TYPE;
    l_indic_type            NUMBER;
    l_config_type           NUMBER;
    l_def_calc_id           bsc_kpi_measure_props.default_calculation%TYPE;
    CURSOR  c_old_data_set_id IS
    SELECT  dataset_id
    FROM    BSC_KPI_ANALYSIS_MEASURES_B
    WHERE   indicator        = p_kpi_id
    AND     analysis_option0 = NVL(p_analysis_option_id0, 0)
    AND     analysis_option1 = NVL(p_analysis_option_id1, 0)
    AND     analysis_option2 = NVL(p_analysis_option_id2, 0)
    AND     series_id        = NVL(p_series_id, 0);
    -- Need the above to keep track of whether data set has changed
    --END ADEED BY PETER

    CURSOR  c_data_set_id IS
    SELECT  DISTINCT a.dataset_id DataSet_Id
    FROM    BSC_SYS_DATASETS_B a
          , BSC_SYS_MEASURES   b
    WHERE   UPPER(b.short_name) = UPPER(p_measure_short_name)
    AND     a.measure_id1       = b.measure_id
    AND     ROWNUM < 2;

    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  p_kpi_id
    AND     Prototype_Flag   <>  2;

    CURSOR  C_OPTIONZERO_SOURCE IS
    SELECT  D.SOURCE,D.DATASET_ID
    FROM    BSC_SYS_DATASETS_B D,
            BSC_KPI_ANALYSIS_MEASURES_B K
    WHERE   D.DATASET_ID = K.DATASET_ID
    AND     k.indicator      = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
    AND     analysis_option0 = 0
    AND     analysis_option1 = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1
    AND     analysis_option2 = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2
    AND     series_id        = 0;

    CURSOR c_stack_series_id IS
    SELECT
      stack_series_id
    FROM
      bsc_kpi_analysis_measures_b
    WHERE
      indicator  = p_kpi_id AND
      analysis_option0 = p_analysis_option_id0 AND
      analysis_option1 = p_analysis_option_id1 AND
      analysis_option2 = p_analysis_option_id2 AND
      series_id        = p_series_id;

    CURSOR c_default_calculation IS
    SELECT
      default_calculation
    FROM
      bsc_kpi_measure_props kp,
      bsc_kpi_analysis_measures_b km
    WHERE
      km.indicator = p_kpi_id AND
      km.indicator = kp.indicator AND
      km.kpi_measure_id = kp.kpi_measure_id AND
      km.analysis_option0 = p_analysis_option_id0 AND
      km.analysis_option1 = p_analysis_option_id1 AND
      km.analysis_option2 = p_analysis_option_id2 AND
      km.series_id        = p_series_id;

BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT UpdateBSCKPIAnaOpts;
    --Initialize record for BSC_KPI_ANALYSIS_MEASURES_B/TL &BSC_KPI_ANALYSIS_OPTIONS_B/TL
    l_dim_set_id                                    :=  p_dim_set_id;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Name              :=  p_option0_Name;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Help              :=  p_measure_help;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2            :=  p_analysis_option_id2;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1            :=  p_analysis_option_id1;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0            :=  p_analysis_option_id0;
    l_Bsc_Anal_Opt_Rec.Bsc_Measure_Prototype_Flag   :=  NULL;
    l_Bsc_Anal_Opt_Rec.Bsc_Measure_Long_Name        :=  p_measure_name;
    l_Bsc_Anal_Opt_Rec.Bsc_Measure_Help             :=  p_measure_help;
    l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id                   :=  p_kpi_id;
    l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id               :=  l_dim_set_id;
    l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Stack_Series_Id  :=  NULL;
    l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Series_Type      :=  NULL;
    l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Series_Id        :=  p_series_id;
    l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Series_Color     :=  NULL;
    l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id               :=  p_data_set_id;
    l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Budget_Flag      :=  NULL;
    l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Bm_Flag          :=  NULL;
    l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Bm_Color         :=  NULL;
    l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Axis             :=  NULL;
    l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id        :=  p_analysis_group_id;
    l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Default_Value    :=  p_default_value;
    IF p_series_id IS NOT NULL THEN
      OPEN c_stack_series_id;
      FETCH c_stack_series_id INTO l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Stack_Series_Id;
      CLOSE c_stack_series_id;
    END IF;
    IF (l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id IS NULL) THEN
        IF (c_data_set_id%ISOPEN) THEN
            CLOSE c_data_set_id;
        END IF;
        OPEN c_data_set_id;
            FETCH c_data_set_id INTO l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id;
        CLOSE c_data_set_id;
    END IF;
    IF (l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'DATASET'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    SELECT  COUNT(*) INTO l_count
    FROM    BSC_KPIS_B
    WHERE   indicator = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;
    IF (l_count = 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Verify that this is not a Shared KPI.
    SELECT  share_flag  INTO  l_count
    FROM    BSC_KPIS_B
    WHERE   indicator = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id ;
    IF (l_count = 2) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
        --FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT  Source INTO l_data_source
    FROM    BSC_SYS_DATASETS_B
    WHERE   Dataset_Id = l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id;
    IF (NOT p_update_ana_opt AND l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id IS NOT NULL) THEN
        BSC_BIS_KPI_MEAS_PUB.get_Dim_Set_Source_Info
        (     p_Indicator   =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
            , p_DimSetId    =>  l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id
            , x_Source      =>  l_temp_data_source
            , x_Data_Set_Id =>  l_data_set_id
        );
        --dbms_output.PUT_LINE('l_temp_data_source  <'||l_temp_data_source||'>');
        --dbms_output.PUT_LINE('l_data_source       <'||l_data_source||'>');
        --dbms_output.PUT_LINE('l_data_set_id       <'||l_data_set_id||'>');
        IF ((l_temp_data_source IS NOT NULL) AND
              (((l_data_source <> l_temp_data_source) AND (l_data_set_id <> -1)) OR
                ((l_data_set_id <> -1) AND (l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id = -1)))) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_NO_UPDATE_MEASURE_SOURCE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_temp_data_source IS NULL)  THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_V_NO_MEASURE_BY_DIM_SET');
            FND_MESSAGE.SET_TOKEN('DIM_SET', l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;
    --dbms_output.PUT_LINE('p_data_source   '||l_data_source);
    -- START Granular Locking - Lock the KPI Under consideration
    BSC_BIS_LOCKS_PUB.LOCK_KPI
    (      p_Kpi_Id             =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
       ,   p_time_stamp         =>  p_time_stamp
       ,   p_Full_Lock_Flag     =>  NULL
       ,   x_return_status      =>  x_return_status
       ,   x_msg_count          =>  x_msg_count
       ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_KPI - Failed');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --ADDED BY PETER
    -- Save the old data set ID for comparison (3169904)
    IF (c_old_data_set_id%ISOPEN) THEN
        CLOSE c_old_data_set_id;
    END IF;
    OPEN    c_old_data_set_id;
        FETCH c_old_data_set_id INTO l_old_data_set_id;
    CLOSE   c_old_data_set_id;
    --END HERE BY PETER
    OPEN c_default_calculation;
    FETCH c_default_calculation INTO l_def_calc_id;
    CLOSE c_default_calculation;

    --default_calculation should be cleared off when the current dataset does not support that property
    IF l_old_data_set_id <> p_data_set_id AND l_def_calc_id IS NOT NULL AND
       BSC_CALCULATIONS_PUB.Is_Calculation_Enabled(p_dataset_id => p_data_set_id, p_calculation_id => l_def_calc_id) = 'N' THEN
      BSC_KPI_SERIES_PUB.Save_Default_Calculation(
        p_commit              =>  FND_API.G_FALSE
       ,p_Indicator           =>  p_kpi_id
       ,p_Analysis_Option0    =>  p_analysis_option_id0
       ,p_Analysis_Option1    =>  p_analysis_option_id1
       ,p_Analysis_Option2    =>  p_analysis_option_id2
       ,p_Series_Id           =>  p_series_id
       ,p_default_calculation =>  NULL
       ,x_return_status       =>  x_return_status
       ,x_msg_count           =>  x_msg_count
       ,x_msg_data            =>  x_msg_data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
    -- END Granular Locking - Lock the KPI Under consideration
    IF (l_data_source = 'PMF') THEN
        IF ((l_dim_set_id IS NULL) OR (l_dim_set_id = 0)) THEN
            --Whenever user update Option-0 with a PMF Measure,
            --a new dimension set should be created. So change l_dim_set_id to NULL
            l_dim_set_id                        :=  NULL;
            l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id   :=  l_dim_set_id;
        END IF;
        --dbms_output.PUT_LINE('into the PMF area');
        BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults
        (       p_commit                =>   FND_API.G_FALSE
            ,   p_data_set_id           =>   l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id
            ,   p_measure_short_name    =>   p_measure_short_name
            ,   p_dim_obj_short_names   =>   p_dim_obj_short_names
            ,   p_default_short_names   =>   p_default_short_names
            ,   p_view_by_name          =>   p_view_by_name
            ,   x_dim_obj_short_names   =>   l_dim_obj_short_names
            ,   x_default_short_names   =>   l_default_short_names
            ,   x_view_by_name          =>   l_view_by_name
            ,   x_measure_short_name    =>   l_measure_short_name
            ,   x_return_status         =>   x_return_status
            ,   x_msg_count             =>   x_msg_count
            ,   x_msg_data              =>   x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        BSC_BIS_KPI_MEAS_PUB.Remove_Unused_PMF_Dimenison
        (       p_commit                =>   FND_API.G_FALSE
            ,   p_Kpi_Id                =>   l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
            ,   p_dim_set_id            =>   l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id
            ,   x_return_status         =>   x_return_status
            ,   x_msg_count             =>   x_msg_count
            ,   x_msg_data              =>   x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_BIS_KPI_MEAS_PUB.Remove_Unused_PMF_Dimenison');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --this following part of the code is copied from BSC_PMF_UI_API_PUB.Create_Bsc_Analysis_Option
        IF (l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id IS NULL) THEN
            l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id      := 0;
        END IF;
        IF (l_Bsc_Anal_Opt_Rec.Bsc_Parent_Option_Id IS NULL) THEN
            l_Bsc_Anal_Opt_Rec.Bsc_Parent_Option_Id       := 0;
        END IF;
        IF (l_Bsc_Anal_Opt_Rec.Bsc_Grandparent_Option_Id IS NULL) THEN
            l_Bsc_Anal_Opt_Rec.Bsc_Grandparent_Option_Id  := 0;
        END IF;
        IF (l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1 IS NULL) THEN
            l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1          := 0;
        END IF;
        IF (l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2 IS NULL) THEN
            l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2          := 0;
        END IF;
        -- Start Granular Locking
        l_dim_obj_names :=  l_dim_obj_short_names;
        IF (l_dim_obj_short_names IS NOT NULL) THEN
            l_dim_obj_names   :=  l_dim_obj_short_names ;
            WHILE (is_more(     p_dim_short_names       =>  l_dim_obj_names
                            ,   p_dim_short_name        =>  l_dim_obj_name)
            ) LOOP
                --dbms_output.PUT_LINE('locking .. '|| l_dim_obj_name);
                -- added for Bug#3549057
                SELECT COUNT(1) INTO l_Count
                FROM   BSC_SYS_DIM_LEVELS_B
                WHERE  SHORT_NAME = l_dim_obj_name;

                IF (l_Count > 0) THEN

                  IF (l_dim_obj_tmp_short_names IS NULL) THEN
                     l_dim_obj_tmp_short_names := l_dim_obj_name;
                  ELSE
                     l_dim_obj_tmp_short_names := l_dim_obj_tmp_short_names ||',' || l_dim_obj_name;
                  END IF;

                  BSC_BIS_LOCKS_PUB.LOCK_DIM_LEVEL
                  (       p_dim_level_id        =>  NVL(BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(l_dim_obj_name), -1)
                      ,   p_time_stamp          =>  NULL
                      ,   x_return_status       =>  x_return_status
                      ,   x_msg_count           =>  x_msg_count
                      ,   x_msg_data            =>  x_msg_data
                  );
                  --dbms_output.PUT_LINE('locked @@ .. '|| l_dim_obj_name);
                  IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                      --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_CREATE_DIMENSION');
                      RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
                END IF;
            END LOOP;
        END IF;
        -- End Granular Locking

        -- Over write with valid Dimension Object short_names
        -- added for Bug#3549057
        l_dim_obj_short_names := l_dim_obj_tmp_short_names;


        IF (l_dim_obj_short_names IS NOT NULL) THEN
            --dbms_output.PUT_LINE('Create A Unique Dimension Group Short_Name As Well As Display Name');
            SELECT NVL(MAX(dim_group_id) + 1, 0) INTO l_count
            FROM   BSC_SYS_DIM_GROUPS_VL;

            l_dim_short_name    :=  l_dim_short_name||l_count;
            l_temp_var          :=  l_dim_short_name;
            l_alias             :=  NULL;
            l_count             :=  0;
            WHILE (l_count <> 0) LOOP
                SELECT  COUNT(*) INTO l_count
                FROM    BSC_SYS_DIM_GROUPS_VL
                WHERE   UPPER(short_name) = l_temp_var
                OR      UPPER(name)       = l_temp_var;
                IF (l_count = 0) THEN
                    l_dim_short_name    :=  l_temp_var;
                END IF;
                l_alias     :=  BSC_BIS_KPI_MEAS_PUB.get_Next_Alias(l_alias);
                l_temp_var  :=  l_dim_short_name||'_'||l_alias;
            END LOOP;
            --dbms_output.PUT_LINE('Unique Short Name Created  '||l_dim_short_name);
            --dbms_output.PUT_LINE('l_dim_obj_short_names      '||l_dim_obj_short_names);
            --dbms_output.PUT_LINE('CREATE DIMENSION GROUPS');
            BSC_BIS_DIMENSION_PUB.Create_Dimension
            (       p_commit                =>  FND_API.G_FALSE
                ,   p_dim_short_name        =>  l_dim_short_name
                ,   p_display_name          =>  l_dim_short_name
                ,   p_description           =>  l_dim_short_name
                ,   p_dim_obj_short_names   =>  l_dim_obj_short_names
                ,   p_application_id        =>  271
                ,   p_create_view           =>  1
                ,   p_hide                  =>  FND_API.G_TRUE
                ,   x_return_status         =>  x_return_status
                ,   x_msg_count             =>  x_msg_count
                ,   x_msg_data              =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_BIS_DIMENSION_PUB.Create_Dimension');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

        END IF;
        --if dimension set exists than update otherwise create new dimension set
        IF (l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id IS NULL) THEN
            --dbms_output.PUT_LINE('CREATE DIMENSION SET');
            IF (l_dim_obj_short_names IS NULL) THEN
                l_dim_short_name  :=  NULL;
            END IF;
            --get the dimension set Id which is created now
            SELECT  NVL(MAX(dim_set_id) + 1, 0)
            INTO    l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id
            FROM    BSC_KPI_DIM_SETS_VL
            WHERE   indicator = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;
            BSC_BIS_KPI_MEAS_PUB.Create_Dim_Set
            (       p_commit             =>  FND_API.G_FALSE
                ,   p_kpi_id             =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
                ,   p_display_name       => 'Dimension Set '||l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id
                ,   p_dim_short_names    =>  l_dim_short_name
                ,   p_time_stamp         =>  NULL
                ,   x_return_status      =>  x_return_status
                ,   x_msg_count          =>  x_msg_count
                ,   x_msg_data           =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_BIS_KPI_MEAS_PUB.Create_Dim_Set');
                RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        ELSE
            SELECT  COUNT(*) INTO l_count
            FROM    BSC_KPI_DIM_SETS_VL
            WHERE   indicator  = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
            AND     dim_set_id = l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id;
            IF (l_count = 0) THEN
                FND_MESSAGE.SET_NAME('BSC',        'BSC_INCORRECT_KPI_DIMSET');
                FND_MESSAGE.SET_TOKEN('KPI_ID',     l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id);
                FND_MESSAGE.SET_TOKEN('DIM_SET_ID', l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            --dbms_output.PUT_LINE('ASSIGN TO DIMENSION SET');
            IF (l_dim_obj_short_names IS NULL) THEN
                l_dim_short_name  :=  NULL;
            END IF;
            BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set
            (       p_commit                =>  FND_API.G_FALSE
                ,   p_kpi_id                =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
                ,   p_dim_set_id            =>  l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id
                ,   p_dim_short_names       =>  l_dim_short_name
                ,   x_return_status         =>  x_return_status
                ,   x_msg_count             =>  x_msg_count
                ,   x_msg_data              =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set Failed: at BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set');
                RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        -- default values and view by
        IF (l_default_short_names IS NOT NULL) THEN
            l_dim_obj_names   :=  l_default_short_names ;
            WHILE (is_more(     p_dim_short_names       =>  l_dim_obj_names
                            ,   p_dim_short_name        =>  l_dim_obj_name)
            ) LOOP
                IF (INSTR(l_dim_obj_short_names, l_dim_obj_name)  <>  0 ) THEN
                    l_bsc_dimset_rec.Bsc_Dset_Default_Value :=  'LD';
                    l_bsc_dimset_rec.Bsc_Kpi_Id             :=  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;
                    l_bsc_dimset_rec.Bsc_Dim_Set_Id         :=  l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id;
                    SELECT level_table_name
                    INTO   l_bsc_dimset_rec.Bsc_Level_Name
                    FROM   BSC_SYS_DIM_LEVELS_B
                    WHERE  Short_Name = l_dim_obj_name;
                    BSC_DIMENSION_SETS_PUB.Update_Dim_Levels
                    (       p_commit            =>  FND_API.G_FALSE
                        ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                        ,   x_return_status     =>  x_return_status
                        ,   x_msg_count         =>  x_msg_count
                        ,   x_msg_data          =>  x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_GRP_LEV_IN_DSET Failed: at BSC_DIMENSION_SETS_PUB.Update_Dim_Levels <'||x_msg_data||'>');
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                    -- default values and view by for shared indicators
                    FOR cd IN c_kpi_ids LOOP
                        l_bsc_dimset_rec.Bsc_Kpi_Id :=  cd.indicator;
                        BSC_DIMENSION_SETS_PUB.Update_Dim_Levels
                        (       p_commit            =>  FND_API.G_FALSE
                            ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                            ,   x_return_status     =>  x_return_status
                            ,   x_msg_count         =>  x_msg_count
                            ,   x_msg_data          =>  x_msg_data
                        );
                        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_GRP_LEV_IN_DSET Failed: at BSC_DIMENSION_SETS_PUB.Update_Dim_Levels <'||x_msg_data||'>');
                            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                   END LOOP;
                END IF;
            END LOOP;
        END IF;
        IF (l_view_by_name IS NOT NULL) THEN
            IF (INSTR(l_default_short_names, l_view_by_name)  <>  0 ) THEN
                l_bsc_dimset_rec.Bsc_Dset_Default_Value :=  'C';
                l_bsc_dimset_rec.Bsc_Kpi_Id             :=   l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;
                l_bsc_dimset_rec.Bsc_Dim_Set_Id         :=   l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id;
                SELECT level_table_name
                INTO   l_bsc_dimset_rec.Bsc_Level_Name
                FROM   BSC_SYS_DIM_LEVELS_B
                WHERE  Short_Name = l_view_by_name;
                BSC_DIMENSION_SETS_PUB.Update_Dim_Levels
                (       p_commit            =>  FND_API.G_FALSE
                    ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                    ,   x_return_status     =>  x_return_status
                    ,   x_msg_count         =>  x_msg_count
                    ,   x_msg_data          =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_GRP_LEV_IN_DSET Failed: at BSC_DIMENSION_SETS_PUB.Update_Dim_Levels <'||x_msg_data||'>');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                -- default values and view by for shared indicators
                FOR cd IN c_kpi_ids LOOP
                    l_bsc_dimset_rec.Bsc_Kpi_Id :=  cd.indicator;
                    BSC_DIMENSION_SETS_PUB.Update_Dim_Levels
                    (       p_commit            =>  FND_API.G_FALSE
                        ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                        ,   x_return_status     =>  x_return_status
                        ,   x_msg_count         =>  x_msg_count
                        ,   x_msg_data          =>  x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.CREATE_DIM_GRP_LEV_IN_DSET Failed: at BSC_DIMENSION_SETS_PUB.Update_Dim_Levels <'||x_msg_data||'>');
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END LOOP;
            END IF;
        END IF;
        --Added for bug#    4099118

        SELECT  indicator_type,config_type
        INTO    l_indic_type, l_config_type
        FROM    bsc_kpis_b
        WHERE   indicator  =  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;
        /* MultiBar indicator can have more number of series
         but if the first analysis option is PMF Measure then there is no point of
         have more than one series under the same analysis option
        */
        IF(l_indic_type = 10 AND l_config_type = 1) THEN -- Multibar indicator
            FOR CD IN C_OPTIONZERO_SOURCE LOOP
                IF(cd.dataset_id = -1 OR cd.source ='PMF') THEN
                    BSC_ANALYSIS_OPTION_PUB.delete_extra_series(
                      p_Bsc_Anal_Opt_Rec    => l_Bsc_Anal_Opt_Rec
                    , x_return_status       => x_return_status
                    , x_msg_count           => x_msg_count
                    , x_msg_data            => x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
            END LOOP;
        END IF;

        SELECT  COUNT(1)   INTO    l_namecount
        FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
        WHERE   indicator           = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;

        SELECT  COUNT(1)   INTO    l_index
        FROM    BSC_KPI_ANALYSIS_MEASURES_B
        WHERE   indicator        = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
        AND     analysis_option0 = 0
        AND     analysis_option1 = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1
        AND     analysis_option2 = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2
        AND     series_id        = 0
        AND     dataset_id       = -1;


        IF (p_update_ana_opt OR ((l_dim_set_id IS NOT NULL) OR
             ((l_dim_set_id IS NULL) AND
                ((l_index = 1) AND (p_analysis_option_id0 = 0 OR l_namecount = 1))))) THEN
            --dbms_output.PUT_LINE('IN IF');

            l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id       := p_analysis_option_id0;
            IF (l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id  IS NULL) THEN
                l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id   := 0;
            END IF;
            l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0            := l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
            IF (l_Bsc_Anal_Opt_Rec.Bsc_Option_Name IS NULL) THEN
                l_Bsc_Anal_Opt_Rec.Bsc_Option_Name := l_Bsc_Anal_Opt_Rec.Bsc_Measure_Long_Name;
            END IF;
            BSC_BIS_LOCKS_PUB.LOCK_DATASET
            (      p_dataset_id        =>  l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id
                ,  p_time_stamp        =>  NULL
                ,  x_return_status     =>  x_return_status
                ,  x_msg_count         =>  x_msg_count
                ,  x_msg_data          =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DATASET Failed: at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            --dbms_output.PUT_LINE('l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id               '||l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id);
            --dbms_output.PUT_LINE('l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id    '||l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id);
            --dbms_output.PUT_LINE('l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id   '||l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id);
            -- END Granular Locking
            BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options
            (       p_commit         =>  FND_API.G_FALSE
                ,   p_Anal_Opt_Rec   =>  l_Bsc_Anal_Opt_Rec
                ,   x_return_status  =>  x_return_status
                ,   x_msg_count      =>  x_msg_count
                ,   x_msg_data       =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            BSC_DESIGNER_PVT.Deflt_RefreshKpi(l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id);
            FOR cd IN c_kpi_ids LOOP
             l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id := cd.indicator;
             BSC_DESIGNER_PVT.Deflt_RefreshKpi(l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id);
            END LOOP;

            BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button
            (
                  p_Kpi_Id          =>  p_kpi_id
                , p_Dim_Level_Id    =>  NULL
                , x_return_status   =>  x_return_status
                , x_msg_count       =>  x_msg_count
                , x_msg_data        =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed Failed: BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        ELSE
            --dbms_output.PUT_LINE('ELSE');
            IF (l_Bsc_Anal_Opt_Rec.Bsc_Measure_Long_Name IS NULL) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
                FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_IVIEWER', 'ANALYSIS_MS'), TRUE);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (l_Bsc_Anal_Opt_Rec.Bsc_Option_Name IS NULL) THEN
                l_Bsc_Anal_Opt_Rec.Bsc_Option_Name  :=  l_Bsc_Anal_Opt_Rec.Bsc_Measure_Long_Name;
            END IF;
            BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Options
            (       p_commit         =>  FND_API.G_FALSE
                ,   p_Anal_Opt_Rec   =>  l_Bsc_Anal_Opt_Rec
                ,   x_return_status  =>  x_return_status
                ,   x_msg_count      =>  x_msg_count
                ,   x_msg_data       =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Options');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        -- START Granular Locking added by Aditya
        BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
        (       p_kpi_id                =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
            ,   p_dim_set_id            =>  l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_DIMENSION_PUB.CREATE_DIM_LEVEL_GROUP Failed: at BSC_DIMENSION_GROUPS_PUB.Update_Dim_Levels_In_Group');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASET
        (       p_dataset_id            =>  l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_DIMENSION_PUB.CREATE_DIM_LEVEL_GROUP Failed: at BSC_DIMENSION_GROUPS_PUB.Update_Dim_Levels_In_Group');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- END Granular Locking added by Aditya
    ELSIF (l_data_source = 'BSC') THEN
       -- IF (p_option0_Name IS NOT NULL) THEN  /* if changed to fix bug  3149102 */
        IF ((p_option0_Name IS NOT NULL) OR (l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id IS NOT NULL)) THEN
            l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id     :=  p_analysis_option_id0;
            l_Bsc_Anal_Opt_Rec.Bsc_Parent_Option_Id       :=  NULL;
            l_Bsc_Anal_Opt_Rec.Bsc_Grandparent_Option_Id  :=  NULL;
            l_Bsc_Anal_Opt_Rec.Bsc_Option_Name            :=  p_option0_Name;
            --dbms_output.PUT_LINE('BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options '||p_option0_Name);
            -- START  Granular Locking
            IF (l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id IS NOT NULL) THEN
                BSC_BIS_LOCKS_PUB.LOCK_DIM_SET
                (      p_Kpi_Id             =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
                    ,  p_Dim_Set_Id         =>  l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id
                    ,  p_time_stamp         =>  null
                    ,  x_return_status      =>  x_return_status
                    ,  x_msg_count          =>  x_msg_count
                    ,  x_msg_data           =>  x_msg_data
               );
               IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                 --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DIM_SET - Failed');
                   RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;
            -- Lock the Datasets before UPDATE
            -- IF (l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id IS NULL) THEN fiexed bug
            IF (l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id IS NOT NULL) THEN
                 BSC_BIS_LOCKS_PUB.LOCK_DATASET
                 (       p_dataset_id           =>  l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id
                      ,  p_time_stamp           =>  NULL
                      ,  x_return_status        =>  x_return_status
                      ,  x_msg_count            =>  x_msg_count
                      ,  x_msg_data             =>  x_msg_data
                 );
                 IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                     --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DATASET Failed: at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options');
                     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
            END IF;
            -- END  Granular Locking
            BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options
            (       p_commit           =>    FND_API.G_FALSE
                ,   p_Anal_Opt_Rec     =>    l_Bsc_Anal_Opt_Rec
                ,   p_data_Source      =>    l_data_source
                ,   x_return_status    =>    x_return_status
                ,   x_msg_count        =>    x_msg_count
                ,   x_msg_data         =>    x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            IF (p_option1_Name IS NOT NULL) THEN
                l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id     :=  p_analysis_option_id1;
                l_Bsc_Anal_Opt_Rec.Bsc_Option_Name            :=  p_option1_Name;
                l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id      :=  1;
                BSC_BIS_KPI_MEAS_PUB.Get_Valid_Analysis_Option_Ids
                (       p_Kpi_Id                    =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
                    ,   p_Analysis_Group_ID         =>  l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id
                    ,   p_Option_ID                 =>  l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id
                    ,   p_Parent_Option_ID          =>  p_analysis_option_id0
                    ,   p_GrandParent_Option_ID     =>  NULL
                    ,   x_Parent_Option_ID          =>  l_Bsc_Anal_Opt_Rec.Bsc_Parent_Option_Id
                    ,   x_GrandParent_Option_ID     =>  l_Bsc_Anal_Opt_Rec.Bsc_Grandparent_Option_Id
                    ,   x_return_status             =>  x_return_status
                    ,   x_msg_count                 =>  x_msg_count
                    ,   x_msg_data                  =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_BIS_KPI_MEAS_PUB.Get_Valid_Analysis_Option_Ids');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                l_Bsc_Anal_Opt_Rec.Bsc_Grandparent_Option_Id  :=  NULL;
                --dbms_output.PUT_LINE('BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options1 '||p_option1_Name);
                BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options
                (      p_commit           =>    FND_API.G_FALSE
                    ,   p_Anal_Opt_Rec     =>    l_Bsc_Anal_Opt_Rec
                    ,   p_data_Source      =>    l_data_source
                    ,   x_return_status    =>    x_return_status
                    ,   x_msg_count        =>    x_msg_count
                    ,   x_msg_data         =>    x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
            IF (p_option2_Name IS NOT NULL) THEN
                l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id     :=  p_analysis_option_id2;
                l_Bsc_Anal_Opt_Rec.Bsc_Option_Name            :=  p_option2_Name;
                l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id      :=  2;
                BSC_BIS_KPI_MEAS_PUB.Get_Valid_Analysis_Option_Ids
                (       p_Kpi_Id                    =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
                    ,   p_Analysis_Group_ID         =>  l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id
                    ,   p_Option_ID                 =>  l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id
                    ,   p_Parent_Option_ID          =>  p_analysis_option_id1
                    ,   p_GrandParent_Option_ID     =>  p_analysis_option_id0
                    ,   x_Parent_Option_ID          =>  l_Bsc_Anal_Opt_Rec.Bsc_Parent_Option_Id
                    ,   x_GrandParent_Option_ID     =>  l_Bsc_Anal_Opt_Rec.Bsc_Grandparent_Option_Id
                    ,   x_return_status             =>  x_return_status
                    ,   x_msg_count                 =>  x_msg_count
                    ,   x_msg_data                  =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_BIS_KPI_MEAS_PUB.Get_Valid_Analysis_Option_Ids');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                --dbms_output.PUT_LINE('BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options2 '||p_option2_Name);
                BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options
                (       p_commit           =>    FND_API.G_FALSE
                    ,   p_Anal_Opt_Rec     =>    l_Bsc_Anal_Opt_Rec
                    ,   p_data_Source      =>    l_data_source
                    ,   x_return_status    =>    x_return_status
                    ,   x_msg_count        =>    x_msg_count
                    ,   x_msg_data         =>    x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options');
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END IF;
        IF ((p_default_value IS NOT NULL) AND (l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Series_Id IS NOT NULL)) THEN
            --logic for setting BSC_KPI_ANALYSIS_MEASURES_B.Default_Value for multi series indicators
            SELECT  COUNT(*) INTO l_count FROM BSC_KPI_ANALYSIS_MEASURES_B
            WHERE   indicator        = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
            AND     analysis_option0 = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0
            AND     analysis_option1 = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1
            AND     analysis_option2 = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2;
            IF (l_count > 1 ) THEN -- this condition ensure that it have many series.
                UPDATE BSC_KPI_ANALYSIS_MEASURES_B
                SET    default_value     = 1
                WHERE  indicator         = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
                AND    analysis_option0  = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0
                AND    analysis_option1  = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1
                AND    analysis_option2  = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2
                AND    series_id         = p_default_value;

                UPDATE  BSC_KPI_ANALYSIS_MEASURES_B
                SET     default_value    = 0
                WHERE   indicator        = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
                AND     analysis_option0 = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0
                AND     analysis_option1 = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1
                AND     analysis_option2 = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2
                AND     series_id       <> p_default_value;
            END IF;
        END IF;
        --ADDED BY PETER
        -- If the data set is changed, we need to flag it as a structural change (3169904)
        IF (l_old_data_set_id <> l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id) THEN
            BSC_DESIGNER_PVT.ActionFlag_Change(p_kpi_id, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
            FOR cd IN c_kpi_ids LOOP
            l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id := cd.indicator;
            BSC_DESIGNER_PVT.ActionFlag_Change(l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id , BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
            END LOOP;
        END IF;
        --END BY PETER
        -- START Granular Locking added by Aditya
        BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_KPI
        (       p_kpi_id                =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF ((x_return_status  =  FND_API.G_RET_STS_ERROR)  OR (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) THEN
              --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET Failed');
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASET
        (       p_dataset_id            =>  l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF ((x_return_status  =  FND_API.G_RET_STS_ERROR)  OR (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) THEN
              --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASET  Failed');
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- END Granular Locking added by Aditya
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_data_set_id%ISOPEN) THEN
            CLOSE c_data_set_id;
        END IF;
        ROLLBACK TO UpdateBSCKPIAnaOpts;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_data_set_id%ISOPEN) THEN
            CLOSE c_data_set_id;
        END IF;
        ROLLBACK TO UpdateBSCKPIAnaOpts;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        IF (c_data_set_id%ISOPEN) THEN
            CLOSE c_data_set_id;
        END IF;
        ROLLBACK TO UpdateBSCKPIAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        IF (c_data_set_id%ISOPEN) THEN
            CLOSE c_data_set_id;
        END IF;
        ROLLBACK TO UpdateBSCKPIAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Update_KPI_Analysis_Options;

/*********************************************************************************
         API TO CREATE PMF/BSC MEASURES/ANALYSIS OPTIONS WITHIN AN INDICATOR
*********************************************************************************/
-- ADRAO added Short_Name to Analysis Option for Enh#3540302 (ADMINISTRATOR TO ADD KPI TO KPI REGION)
PROCEDURE Create_KPI_Analysis_Options
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN          NUMBER
    ,   p_analysis_group_id     IN          NUMBER
    ,   p_data_set_id           IN          NUMBER
    ,   p_measure_short_name    IN          VARCHAR2
    ,   p_measure_name          IN          VARCHAR2
    ,   p_measure_help          IN          VARCHAR2
    ,   p_time_stamp            IN          VARCHAR2   := NULL
    ,   p_Short_Name            IN          VARCHAR2   := NULL
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
    l_Bsc_Anal_Opt_Rec      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
    l_count                 NUMBER;
    l_datasource            BSC_SYS_DATASETS_B.Source%TYPE;
    l_meaning               VARCHAR(60);
    l_DimObj_ViewBy_Tbl     BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type;
    l_measure_short_name    BSC_SYS_MEASURES.Short_Name%TYPE;
    l_sname                 BSC_KPIS_B.SHORT_NAME%TYPE;

    CURSOR  c_data_source IS
    SELECT  Source
    FROM    BSC_SYS_DATASETS_B
    WHERE   Dataset_Id = p_data_set_id;

    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator =   p_kpi_id
    AND     Prototype_Flag   <>  2;

    l_default_level_set     BOOLEAN := FALSE;
    l_namecount             NUMBER;
    l_index                 NUMBER;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Create_KPI_Analysis_Options procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT CreateBSCKPIAnaOpts;

    OPEN c_data_source;
        FETCH c_data_source INTO l_datasource;
    CLOSE c_data_source;
    IF (l_datasource IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        SELECT MEANING INTO l_meaning
        FROM   BSC_LOOKUPS
        WHERE  LOOKUP_TYPE = 'BSC_UI_COMMON' AND LOOKUP_CODE = 'EDW_MEASURE' ;
        FND_MESSAGE.SET_TOKEN('TYPE', l_meaning, TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF ((l_datasource <> 'BSC') AND (l_datasource <> 'PMF')) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DATA_SOURCE');
        FND_MSG_PUB.ADD;
        RAISE           FND_API.G_EXC_ERROR;
    END IF;
    --Initialize record for BSC_KPI_ANALYSIS_MEASURES_B/TL &BSC_KPI_ANALYSIS_OPTIONS_B/TL
    l_measure_short_name                            :=  p_measure_short_name;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Name              :=  p_measure_name;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2            :=  0;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1            :=  0;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0            :=  0;
    l_Bsc_Anal_Opt_Rec.Bsc_Measure_Long_Name        :=  p_measure_name;
    l_Bsc_Anal_Opt_Rec.Bsc_Measure_Help             :=  p_measure_help;
    l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id                   :=  p_kpi_id;
    l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Series_Id        :=  0;
    l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id               :=  p_data_set_id;
    l_Bsc_Anal_Opt_Rec.Bsc_Parent_Option_Id         :=  0;
    l_Bsc_Anal_Opt_Rec.Bsc_Grandparent_Option_Id    :=  0;
    IF (p_analysis_group_id IS NOT NULL) THEN
        l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id    :=  p_analysis_group_id;
    ELSE
        l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id    :=  0;
    END IF;

    l_Bsc_Anal_Opt_Rec.Bsc_Option_Short_Name        :=  p_Short_Name;

    IF (l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF ((l_datasource = 'BSC') AND (l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id IS NULL)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'DATASET'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    SELECT  COUNT(*) INTO l_count
    FROM    BSC_KPIS_B
    WHERE   indicator = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;
    IF (l_count = 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Verify that this is not a Shared KPI.
    SELECT  share_flag  INTO  l_count
    FROM    BSC_KPIS_B
    WHERE   indicator = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id ;
    IF (l_count = 2) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --dbms_output.PUT_LINE('l_datasource   '||l_datasource);
    IF (l_Bsc_Anal_Opt_Rec.Bsc_Measure_Long_Name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_IVIEWER', 'ANALYSIS_MS'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_Bsc_Anal_Opt_Rec.Bsc_Option_Name IS NULL) THEN
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Name  :=  l_Bsc_Anal_Opt_Rec.Bsc_Measure_Long_Name;
    END IF;
    --START Granular Locking - Lock the KPI Under consideration
    BSC_BIS_LOCKS_PUB.LOCK_KPI
    (       p_Kpi_Id             =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
        ,   p_time_stamp         =>  p_time_stamp
        ,   p_Full_Lock_Flag     =>  NULL
        ,   x_return_status      =>  x_return_status
        ,   x_msg_count          =>  x_msg_count
        ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_KPI - Failed');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- END Granular Locking - Lock the KPI Under consideration
    IF (l_datasource = 'PMF') THEN
        BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_kpi_id                =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
            ,   p_data_source           =>  l_datasource
            ,   p_analysis_group_id     =>  l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id
            ,   p_analysis_option_id0   =>  NULL
            ,   p_analysis_option_id1   =>  NULL
            ,   p_analysis_option_id2   =>  NULL
            ,   p_series_id             =>  NULL
            ,   p_data_set_id           =>  l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id
            ,   p_dim_set_id            =>  NULL
            ,   p_option0_Name          =>  l_Bsc_Anal_Opt_Rec.Bsc_Option_Name
            ,   p_option1_Name          =>  NULL
            ,   p_option2_Name          =>  NULL
            ,   p_measure_short_name    =>  NULL
            ,   p_dim_obj_short_names   =>  NULL
            ,   p_default_short_names   =>  NULL
            ,   p_view_by_name          =>  NULL
            ,   p_measure_name          =>  l_Bsc_Anal_Opt_Rec.Bsc_Measure_Long_Name
            ,   p_measure_help          =>  l_Bsc_Anal_Opt_Rec.Bsc_Measure_Help
            ,   p_default_value         =>  NULL
            ,   p_time_stamp            =>  NULL
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_KPI_Analysis_Options Failed: at BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSIF (l_datasource = 'BSC') THEN
        --for BSC we do not create dimension set. Therefore use the default value for dimension set
        l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id   :=  0;
        -- In 5.1.0 the requirement is that whenever we add the BIS/BSC measure the default measure option 0
        --should be overridden.Till now we were handling this issue for BIS measures.Now in 5.1.0 we have o handle
        --this for BSC measures also.
        /*****************conditions to be checked before updating ***********************
        If the name of the option 0 is not chnaged.
        If the number of the analysis options within the indicator are 1
        If the dataset_id is -1.
        If all the above conditons are met then only update the option 0.
        other wise create a new analysis option.
        *********************************************************************************/
        SELECT  COUNT(0)
        INTO    l_namecount
        FROM    BSC_KPI_ANALYSIS_OPTIONS_VL
        WHERE   indicator           = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;

        SELECT  COUNT(*)
        INTO    l_index
        FROM    BSC_KPI_ANALYSIS_MEASURES_B
        WHERE   indicator        = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
        AND     analysis_option0 = 0
        AND     analysis_option1 = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1
        AND     analysis_option2 = l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2
        AND     series_id        = 0
        AND     dataset_id = -1;
        IF ((l_namecount =1) AND (l_index=1)AND (l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id = 0)) THEN
            SELECT  Option_Id
            INTO    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0
            FROM    BSC_KPI_ANALYSIS_OPTIONS_B
            WHERE   Indicator           = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
            AND     Analysis_Group_Id   = l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id;
            l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id   := l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0;
            IF (l_Bsc_Anal_Opt_Rec.Bsc_Option_Name IS NULL) THEN
                l_Bsc_Anal_Opt_Rec.Bsc_Option_Name := l_Bsc_Anal_Opt_Rec.Bsc_Measure_Long_Name;
            END IF;
            BSC_BIS_LOCKS_PUB.LOCK_DATASET
            (      p_dataset_id        =>  l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id
                ,  p_time_stamp        =>  NULL
                ,  x_return_status     =>  x_return_status
                ,  x_msg_count         =>  x_msg_count
                ,  x_msg_data          =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_DATASET Failed: at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            --dbms_output.PUT_LINE('l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id               '||l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id);
            --dbms_output.PUT_LINE('l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id    '||l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id);
            --dbms_output.PUT_LINE('l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id   '||l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id);
            -- END Granular Locking
            BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options
            (       p_commit         =>  FND_API.G_FALSE
                ,   p_Anal_Opt_Rec   =>  l_Bsc_Anal_Opt_Rec
                ,   x_return_status  =>  x_return_status
                ,   x_msg_count      =>  x_msg_count
                ,   x_msg_data       =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_KPI_Analysis_Options Failed: at BSC_ANALYSIS_OPTION_PUB.Update_Analysis_Options');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            BSC_DESIGNER_PVT.Deflt_RefreshKpi(l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id);
            FOR cd IN c_kpi_ids LOOP
           l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id := cd.indicator;
           BSC_DESIGNER_PVT.Deflt_RefreshKpi(l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id);
            END LOOP;
        ELSE
            SELECT  COUNT(Option_Id) + 1
            INTO    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0
            FROM    BSC_KPI_ANALYSIS_OPTIONS_B
            WHERE   Indicator           = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
            AND     Analysis_Group_Id   = l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id;

            -- START Granular Locking added by Aditya
            BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Options
            (       p_commit           =>    FND_API.G_FALSE
                ,   p_Anal_Opt_Rec     =>    l_Bsc_Anal_Opt_Rec
                ,   x_return_status    =>    x_return_status
                ,   x_msg_count        =>    x_msg_count
                ,   x_msg_data         =>    x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_KPI_Analysis_Options Failed: at BSC_ANALYSIS_OPTION_PUB.Create_Analysis_Options');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASET
            (     p_dataset_id            =>  l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Id
              ,   x_return_status         =>  x_return_status
              ,   x_msg_count             =>  x_msg_count
              ,   x_msg_data              =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DATASET  Failed');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- Added by ADRAO
            BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_KPI
            (     p_kpi_id                =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
              ,   x_return_status         =>  x_return_status
              ,   x_msg_count             =>  x_msg_count
              ,   x_msg_data              =>  x_msg_data
            );
            IF ((x_return_status  =  FND_API.G_RET_STS_ERROR)  OR (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) THEN
                  RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- END Granular Locking added by Aditya
        END IF;
    END IF;

    SELECT short_name
    INTO l_sname
    FROM BSC_KPIS_B
    WHERE INDICATOR =  p_kpi_id ;

    IF ((l_datasource = 'BSC') OR (l_sname IS NOT NULL)) THEN
      BSC_DESIGNER_PVT.ActionFlag_Change(p_kpi_id, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
      FOR cd IN c_kpi_ids LOOP
          l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id := cd.indicator;
          BSC_DESIGNER_PVT.ActionFlag_Change(l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
      END LOOP;

    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Create_KPI_Analysis_Options procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_data_source%ISOPEN)THEN
            CLOSE c_data_source;
        END IF;
        ROLLBACK TO CreateBSCKPIAnaOpts;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_data_source%ISOPEN)THEN
            CLOSE c_data_source;
        END IF;
        ROLLBACK TO CreateBSCKPIAnaOpts;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        IF (c_data_source%ISOPEN)THEN
            CLOSE c_data_source;
        END IF;
        ROLLBACK TO CreateBSCKPIAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Create_KPI_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Create_KPI_Analysis_Options ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        IF (c_data_source%ISOPEN)THEN
            CLOSE c_data_source;
        END IF;
        ROLLBACK TO CreateBSCKPIAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Create_KPI_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Create_KPI_Analysis_Options ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Create_KPI_Analysis_Options;
/*********************************************************************************
         API TO DELETE PMF/BSC MEASURES/ANALYSIS OPTIONS WITHIN AN INDICATOR
*********************************************************************************/
/*PROCEDURE Delete_KPI_Analysis_Options
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN          NUMBER
    ,   p_data_source           IN          VARCHAR2
    ,   p_option_id             IN          NUMBER
    ,   p_time_stamp            IN          VARCHAR2   := NULL
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
    l_count                 NUMBER;
    l_new_count             NUMBER;
    l_tab_id                NUMBER;
    l_dim_set_id            NUMBER;

    l_Bsc_Anal_Opt_Rec      BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
    l_Bsc_Kpi_Entity_Rec    BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
    l_Bsc_Dim_Set_Rec_Type  BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Analysis_Options procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT DeleteBSCKPIAnaOpts;
    IF (p_data_source IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DATA_SOURCE'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF ((p_data_source <> 'BSC') AND (p_data_source <> 'PMF')) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DATA_SOURCE');
        FND_MSG_PUB.ADD;
        RAISE           FND_API.G_EXC_ERROR;
    END IF;
    --Initialize record for BSC_KPI_ANALYSIS_MEASURES_B/TL &BSC_KPI_ANALYSIS_OPTIONS_B/TL
    l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id                :=  p_kpi_id;              -- BSC_KPI_ANALYSIS_OPTIONS_TL.indicator
    l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id    :=  p_option_id;           -- BSC_KPI_ANALYSIS_OPTIONS_TL.option_id
    l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id     :=  0;   -- BSC_KPI_ANALYSIS_OPTIONS_TL.analysis_group_id

    -- we also need to normalize the values for column ANALYSYS_OPTION0,
    -- ANALYSYS_OPTION1, ANALYSYS_OPTION2 based on group id.
    IF (l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id = 0) THEN
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0    :=  l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1    :=  0;
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2    :=  0;
    ELSIF (l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id = 1) THEN
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1    :=  l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0    :=  0;
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2    :=  0;
    ELSE
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2    :=  l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0    :=  0;
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1    :=  0;
    END IF;
    --dbms_output.PUT_LINE('l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id              '||l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id);
    --dbms_output.PUT_LINE('l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id  '||l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id);
    --dbms_output.PUT_LINE('l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id   '||l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id);
    IF (l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT  COUNT(*) INTO l_count
    FROM    BSC_KPIS_B
    WHERE   indicator = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;
    IF (l_count = 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON',  'ANALYSIS_OPTIONS'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON',  'ANALYSIS_GROUP'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Verify that this is not a Shared KPI.
    SELECT  share_flag  INTO    l_count
    FROM    BSC_KPIS_B
    WHERE   indicator = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id ;
    IF (l_count = 2) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
        --FND_MESSAGE.SET_TOKEN('BSC_KPI', l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --Determine if Indicator assigned to a tab.
    SELECT  COUNT(indicator) INTO l_count
    FROM    BSC_TAB_INDICATORS
    WHERE   indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
    -- if indicator assigned to tab get tab id.
    IF(l_count > 0) THEN
        SELECT  tab_id INTO l_tab_id
        FROM    BSC_TAB_INDICATORS
        WHERE   indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;
    END IF;
    -- obtain dimension set id this option is using.
    SELECT  dim_set_id INTO l_dim_set_id
    FROM    BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE   indicator         = p_kpi_id
    AND     analysis_group_id = 0
    AND     option_id         = p_option_id;

    -- START Granular Locking - Lock the KPI Under consideration
    BSC_BIS_LOCKS_PUB.LOCK_KPI
    (       p_Kpi_Id             =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
       ,    p_time_stamp         =>  NULL
       ,    p_Full_Lock_Flag     =>  NULL
       ,    x_return_status      =>  x_return_status
       ,    x_msg_count          =>  x_msg_count
       ,    x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_KPI - Failed');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Determine number of distinct dataset_id before delete.
    SELECT COUNT (DISTINCT dataset_id) INTO l_count
    FROM BSC_KPI_ANALYSIS_MEASURES_B
    WHERE INDICATOR = p_kpi_id;

    -- END Granular Locking - Lock the KPI Under consideration
    BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Options
    (       p_commit              =>    FND_API.G_FALSE
        ,   p_Anal_Opt_Rec        =>    l_Bsc_Anal_Opt_Rec
        ,   x_return_status       =>    x_return_status
        ,   x_msg_count           =>    x_msg_count
        ,   x_msg_data            =>    x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Analysis_Options Failed: at BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Options');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Determine number of distinct dataset_id after delete.
    SELECT COUNT (DISTINCT dataset_id) INTO l_new_count
    FROM BSC_KPI_ANALYSIS_MEASURES_B
    WHERE INDICATOR=p_kpi_id;
    IF (l_count <> l_new_count) THEN
        -- fixed bug#3136769
        BSC_DESIGNER_PVT.ActionFlag_Change(p_kpi_id, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
    END IF;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_kpi_id;
    BSC_KPI_PUB.Update_Kpi_Time_Stamp
    (       p_commit              =>  FND_API.G_FALSE
        ,   p_Bsc_Kpi_Entity_Rec  =>  l_Bsc_Kpi_Entity_Rec
        ,   x_return_status       =>  x_return_status
        ,   x_msg_count           =>  x_msg_count
        ,   x_msg_data            =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Analysis_Options Failed: at BSC_KPI_PUB.Update_Kpi_Time_Stamp');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Determine if the dimension set is being used by other options.
    IF (p_data_source = 'PMF') THEN
        SELECT COUNT(option_id) INTO l_count
        FROM   BSC_KPI_ANALYSIS_OPTIONS_B
        WHERE  indicator    = p_kpi_id
        AND    dim_set_id   = l_dim_set_id;
        -- If there are no more options using this dim set delete it.
        IF (l_count = 0) THEN
            BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Set
            (       p_commit         =>  FND_API.G_FALSE
                ,   p_kpi_id         =>  p_kpi_id
                ,   p_dim_set_id     =>  l_dim_set_id
                ,   x_return_status  =>  x_return_status
                ,   x_msg_count      =>  x_msg_count
                ,   x_msg_data       =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Analysis_Options Failed: at BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Set');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- Need to call procedure for list button logic.
            BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels
            (       p_commit          =>  FND_API.G_FALSE
                ,   p_Tab_Id          =>  l_tab_id
                ,   x_return_status   =>  x_return_status
                ,   x_msg_count       =>  x_msg_count
                ,   x_msg_data        =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Analysis_Options Failed: at BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Analysis_Options procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteBSCKPIAnaOpts;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteBSCKPIAnaOpts;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteBSCKPIAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Analysis_Options ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO DeleteBSCKPIAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Analysis_Options ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_KPI_Analysis_Options;   */
/************************************************************************************
                            DELETE_KPI_ANALYSIS_OPTIONS
************************************************************************************/
PROCEDURE Delete_KPI_Analysis_Options
(       p_Bsc_Anal_Opt_Rec      IN          BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type
    ,   p_data_source           IN          VARCHAR2
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
    l_count                 NUMBER;
    l_tab_id                NUMBER;
    l_regions               VARCHAR2(32000);
    l_dim_group_id          BSC_SYS_DIM_GROUPS_VL.DIM_GROUP_ID%TYPE;
    l_dim_shortName         BSC_SYS_DIM_GROUPS_VL.SHORT_NAME%TYPE;

    CURSOR c_dim_group_id  IS
      SELECT
        dim_group_id
      FROM
        BSC_KPI_DIM_GROUPS
      WHERE
        Dim_Set_Id   =  p_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id AND
        Indicator    =  p_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;

    CURSOR c_dim_short_name(p_dim_group_id NUMBER) IS
      SELECT
        short_name
      FROM
        BSC_SYS_DIM_GROUPS_VL
      WHERE
        dim_group_id = p_dim_group_id;


BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Analysis_Options procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT DeleteBSCKPIAnaOpts;
    -- we also need to normalize the values for column ANALYSYS_OPTION0,
    -- ANALYSYS_OPTION1, ANALYSYS_OPTION2 based on group id.

    -- END Granular Locking - Lock the KPI Under consideration
    BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Options
    (       p_commit              =>    FND_API.G_FALSE
        ,   p_Anal_Opt_Rec        =>    p_Bsc_Anal_Opt_Rec
        ,   x_return_status       =>    x_return_status
        ,   x_msg_count           =>    x_msg_count
        ,   x_msg_data            =>    x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Analysis_Options Failed: at BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Options');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Determine if the dimension set is being used by other options.
    IF (p_data_source = 'PMF') THEN
        SELECT COUNT(option_id) INTO l_count
        FROM   BSC_KPI_ANALYSIS_OPTIONS_B
        WHERE  indicator    = p_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
        AND    dim_set_id   = p_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id;

  --Fetch the dim group id before deleting the objective.
        l_dim_group_id := -1;
        OPEN c_dim_group_id;
        FETCH c_dim_group_id INTO l_dim_group_id;
        CLOSE c_dim_group_id;

        -- If there are no more options using this dim set delete it.
        IF (l_count = 0) THEN
            BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Set
            (       p_commit         =>  FND_API.G_FALSE
                ,   p_kpi_id         =>  p_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
                ,   p_dim_set_id     =>  p_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id
                ,   x_return_status  =>  x_return_status
                ,   x_msg_count      =>  x_msg_count
                ,   x_msg_data       =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Analysis_Options Failed: at BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Set');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            --Determine if Indicator assigned to a tab.
            SELECT  COUNT(indicator) INTO l_count
            FROM    BSC_TAB_INDICATORS
            WHERE   indicator = p_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;
            -- if indicator assigned to tab get tab id.
            IF(l_count > 0) THEN
                SELECT  tab_id INTO l_tab_id
                FROM    BSC_TAB_INDICATORS
                WHERE   indicator = p_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;
            END IF;
            -- Need to call procedure for list button logic.
            BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels
            (       p_commit          =>  FND_API.G_FALSE
                ,   p_Tab_Id          =>  l_tab_id
                ,   x_return_status   =>  x_return_status
                ,   x_msg_count       =>  x_msg_count
                ,   x_msg_data        =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Analysis_Options Failed: at BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        IF(l_dim_group_id <> -1) THEN
    OPEN c_dim_short_name(l_dim_group_id);
          FETCH c_dim_short_name INTO l_dim_shortName;
    CLOSE c_dim_short_name;
          --delete the imported dimensions if it is not used in any report
          l_regions := BSC_UTILITY.Is_Dim_In_AKReport(l_dim_shortName, BSC_UTILITY.c_DIMENSION);
          IF(l_regions IS NULL AND l_dim_shortName IS NOT NULL) THEN
             BSC_BIS_DIMENSION_PUB.Delete_Dimension
              (    p_commit                =>  FND_API.G_FALSE
               ,   p_dim_short_name        =>  l_dim_shortName
               ,   x_return_status         =>  x_return_status
               ,   x_msg_count             =>  x_msg_count
               ,   x_msg_data              =>  x_msg_data
              );
             IF ((x_return_status IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
               RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
          END IF;
        END IF;
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Analysis_Options procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteBSCKPIAnaOpts;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteBSCKPIAnaOpts;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteBSCKPIAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Analysis_Options ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO DeleteBSCKPIAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Analysis_Options ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Analysis_Options ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_KPI_Analysis_Options;
/************************************************************************************
                            UPDATE KPIS
************************************************************************************/
PROCEDURE Update_Kpi
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN          NUMBER
    ,   p_kpi_name              IN          VARCHAR2
    ,   p_kpi_help              IN          VARCHAR2   := NULL
    ,   p_responsibility_id     IN          NUMBER     := NULL
    ,   p_default_value         IN          NUMBER
    ,   p_BM_Property_Value     IN          NUMBER     := BSC_KPI_PUB.Benchmark_Kpi_Line_Graph -- 0 For Lines and 1 for Bars
    ,   p_time_stamp            IN          VARCHAR2   := NULL
    ,   p_Anal_opt0             IN          BSC_KPI_ANALYSIS_MEASURES_B.analysis_option0%TYPE
    ,   p_Anal_opt1             IN          BSC_KPI_ANALYSIS_MEASURES_B.analysis_option1%TYPE
    ,   p_Anal_opt2             IN          BSC_KPI_ANALYSIS_MEASURES_B.analysis_option2%TYPE
    ,   p_Anal_Series           IN          BSC_KPI_ANALYSIS_MEASURES_B.series_id%TYPE
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
    l_Bsc_Kpi_Entity_Rec        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
    l_commit                    VARCHAR2(10);
    l_tab_name                  BSC_TABS_TL.name%TYPE;
    l_count                     NUMBER;
    l_max_group_count           NUMBER;
    l_anal_grp_id               NUMBER;
    l_Anal_Num_Tbl              BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type;
    l_Old_Anal_Num_Tbl          BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type;

    l_obj_prototype_flag BSC_KPIS_B.prototype_flag%TYPE;
    l_color_rollup_type BSC_KPIS_B.color_rollup_type%TYPE;
    l_def_kpi_measure_id BSC_KPI_ANALYSIS_MEASURES_VL.kpi_measure_id%TYPE;
    l_kpi_measure_id BSC_KPI_ANALYSIS_MEASURES_VL.kpi_measure_id%TYPE;


    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator =   p_kpi_id
    AND     Prototype_Flag   <>  2;

    CURSOR c_dft_anal_ids IS
    SELECT  analysis_option0
          , analysis_option1
          , analysis_option2
          , series_id
    FROM    bsc_oaf_analysys_opt_comb_v
    WHERE   indicator    =  p_kpi_id
    AND     default_flag =  1;


BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Update_Kpi procedure');
    SAVEPOINT UpdatePMDBSCKPIs;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MSG_PUB.Initialize;
    IF (p_kpi_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    SELECT  COUNT(*) INTO l_count
    FROM    BSC_KPIS_B
    WHERE   indicator = p_kpi_id;
    IF (l_count = 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Verify that this is not a Shared KPI.
    SELECT  share_flag
    INTO    l_count
    FROM    bsc_kpis_b
    WHERE   indicator = p_kpi_id ;
    IF (l_count = 2) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
        --FND_MESSAGE.SET_TOKEN('BSC_KPI', p_kpi_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id     := p_kpi_id;

    l_Anal_Num_Tbl(0) := p_Anal_opt0;
    l_Anal_Num_Tbl(1) := p_Anal_opt1;
    l_Anal_Num_Tbl(2) := p_Anal_opt2;

    l_anal_grp_id := BSC_ANALYSIS_OPTION_PUB.get_Analysis_Group_Id
                      (
                           p_Anal_Opt_Comb_Tbl => l_Anal_Num_Tbl
                         , p_obj_id            => p_kpi_id
                      );
    l_Anal_Num_Tbl(3) := p_Anal_Series;

    FOR cd_df IN c_dft_anal_ids LOOP
     l_Old_Anal_Num_Tbl(0) :=  cd_df.analysis_option0;
     l_Old_Anal_Num_Tbl(1) :=  cd_df.analysis_option1;
     l_Old_Anal_Num_Tbl(2) :=  cd_df.analysis_option2;
     l_Old_Anal_Num_Tbl(3) :=  cd_df.series_id;
    END LOOP;


    l_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id      := l_anal_grp_id;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name           := p_kpi_name;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help           := p_kpi_help;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value  := p_default_value;
    l_Bsc_Kpi_Entity_Rec.Bsc_Anal_Opt_Comb_Tbl  := l_Anal_Num_Tbl;



    IF ((p_BM_Property_Value IS NOT NULL) AND (p_BM_Property_Value <> BSC_KPI_PUB.Benchmark_Kpi_Line_Graph)) THEN
        l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Code   :=  BSC_KPI_PUB.Benchmark_Kpi_Property;
        l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Value  :=  BSC_KPI_PUB.Benchmark_Kpi_Bar_Graph;
    ELSE
        l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Code   :=  BSC_KPI_PUB.Benchmark_Kpi_Property;
        l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Property_Value  :=  BSC_KPI_PUB.Benchmark_Kpi_Line_Graph;
    END IF;
    -- Set some default values.
    -- Added by ADRAO
    BSC_BIS_LOCKS_PUB.LOCK_KPI
    (       p_Kpi_Id             =>  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
       ,    p_time_stamp         =>  p_time_stamp
       ,    p_Full_Lock_Flag     =>  NULL
       ,    x_return_status      =>  x_return_status
       ,    x_msg_count          =>  x_msg_count
       ,    x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_KPI - Failed');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- We need to check if there is an update on the Indicator name in order
    -- to prevent it.  To do this we need to check if there is a different
    -- indicator in the same tab  with the same name.
    SELECT  COUNT(indicator)   INTO   l_count
    FROM    BSC_TAB_INDICATORS A
    WHERE   A.Indicator <>  p_kpi_id
    AND     A.Tab_Id     = (SELECT Tab_Id FROM BSC_TAB_INDICATORS WHERE Indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id)
    AND     A.Indicator IN (SELECT Indicator FROM BSC_KPIS_TL WHERE Name = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name);
    IF (l_count <> 0) THEN
        SELECT v.name
        INTO   l_tab_name
        FROM   bsc_tabs_vl v
              ,bsc_tab_indicators w
        WHERE  v.tab_id =w.tab_id
        AND    w.indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id;

        FND_MESSAGE.SET_NAME('BSC','BSC_B_NO_SAMEKPI_TAB');
        FND_MESSAGE.SET_TOKEN('Indicator name: ', p_kpi_name);
        FND_MESSAGE.SET_TOKEN('Tab name: ',       l_tab_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    BSC_KPI_PUB.Update_Kpi
    (       p_commit              =>    FND_API.G_FALSE
        ,   p_Bsc_Kpi_Entity_Rec  =>    l_Bsc_Kpi_Entity_Rec
        ,   x_return_status       =>    x_return_status
        ,   x_msg_count           =>    x_msg_count
        ,   x_msg_data            =>    x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_Kpi Failed: at BSC_KPI_PUB.Update_Kpi');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Fixed Bug#3663301, Called ActionFlag_Change with a Color Flag
    IF (l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value IS NOT NULL) THEN
        IF(BSC_ANALYSIS_OPTION_PUB.Default_Anal_Option_Changed(l_Anal_Num_Tbl,l_Old_Anal_Num_Tbl))THEN

            BSC_DESIGNER_PVT.Deflt_RefreshKpi(l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);

            SELECT kpi_measure_id
            INTO l_kpi_measure_id
            FROM bsc_kpi_analysis_measures_vl
	    WHERE analysis_option0 = p_Anal_opt0
	      AND analysis_option1 = p_Anal_opt1
	      AND analysis_option2 = p_Anal_opt2
	      AND series_id = p_Anal_Series
              AND indicator = p_kpi_id;

	    SELECT bk.color_rollup_type, km.kpi_measure_id, bk.prototype_flag
	    INTO   l_color_rollup_type, l_def_kpi_measure_id, l_obj_prototype_flag
	    FROM bsc_db_color_ao_defaults_v dd, bsc_kpi_analysis_measures_vl km, bsc_kpis_b bk
	    WHERE km.indicator = l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id AND
	  	bk.indicator = km.indicator AND
		km.indicator = dd.indicator AND
		dd.a0_default = km.analysis_option0 AND
		dd.a1_default = km.analysis_option1 AND
		dd.a2_default = km.analysis_option2 AND
		km.default_value = 1;

	    IF (l_obj_prototype_flag <> 2 AND
	        l_obj_prototype_flag <> '7' AND
	        ((l_color_rollup_type = BSC_COLOR_CALC_UTIL.DEFAULT_KPI AND l_def_kpi_measure_id = l_kpi_measure_id)
	  	    --OR (l_color_rollup_type <> BSC_COLOR_CALC_UTIL.DEFAULT_KPI))) THEN
	  	)) THEN

	      BSC_KPI_COLOR_PROPERTIES_PUB.Obj_Prototype_Flag_Change
	      ( p_objective_id   => l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
	      , p_prototype_flag => '7'
	      , x_return_status  => x_return_status
	      , x_msg_count      => x_msg_count
	      , x_msg_data       => x_msg_data
	      );

	    END IF;

            --BSC_DESIGNER_PVT.ActionFlag_Change(l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id , BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color);
            FOR cd IN c_kpi_ids LOOP
              l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := cd.indicator;
              BSC_DESIGNER_PVT.Deflt_RefreshKpi(l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id);
              --BSC_DESIGNER_PVT.ActionFlag_Change(l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id , BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color);
            END LOOP;

            BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button
            (
                  p_Kpi_Id        =>  p_kpi_id
                , p_Dim_Level_Id  =>  NULL
                , x_return_status =>  x_return_status
                , x_msg_count     =>  x_msg_count
                , x_msg_data      =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Update_Kpi Failed:at BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button');
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
    END IF;

    -- Added by ADRAO
    BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_KPI
    (       p_kpi_id                =>  l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF ((x_return_status  =  FND_API.G_RET_STS_ERROR)  OR (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Update_Kpi procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UpdatePMDBSCKPIs;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UpdatePMDBSCKPIs;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO UpdatePMDBSCKPIs;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Update_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Update_Kpi ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO UpdatePMDBSCKPIs;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Update_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Update_Kpi ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Update_Kpi;

/************************************************************************************/
PROCEDURE Create_Kpi
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_group_id              IN              NUMBER
    ,   p_kpi_name              IN              VARCHAR2
    ,   p_kpi_help              IN              VARCHAR2
    ,   p_responsibility_id     IN              NUMBER
    ,   x_return_status         OUT NOCOPY      VARCHAR2
    ,   x_msg_count             OUT NOCOPY      NUMBER
    ,   x_msg_data              OUT NOCOPY      VARCHAR2
) IS
    l_Bsc_Kpi_Entity_Rec              BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Create_Kpi procedure');
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MSG_PUB.Initialize;
    SAVEPOINT CreatePMDBSCKPIs;
    IF (p_kpi_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_responsibility_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_SETUP', 'SRC_RESPONSIBILITY'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- set the passed values to the record.
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Group_Id               := p_group_id;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Name                   := p_kpi_name;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Help                   := p_kpi_help;
    l_Bsc_Kpi_Entity_Rec.Bsc_Responsibility_Id          := p_responsibility_id;
    -- set some default values.
    l_Bsc_Kpi_Entity_Rec.Bsc_Anal_Group_Id              :=  0;
    l_Bsc_Kpi_Entity_Rec.Bsc_Csf_Id                     :=  0;
    l_Bsc_Kpi_Entity_Rec.Bsc_Dependency_Flag            :=  0;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Bm_Group_Id            :=  1;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Color_Flag             :=  1;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Config_Type            :=  1;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Current_Period         :=  1;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Default_Value          :=  0;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Display_Order          :=  0;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Indicator_Type         :=  1;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Level_Comb             := '?';
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Num_Years              :=  0;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Periodicity_Id         :=  5;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Previous_Years         :=  0;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Color        := 'G';
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Prototype_Flag         :=  3;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Share_Flag             :=  0;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level0            :=  1;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_User_Level1            :=  1;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Default_Size  :=  0;
    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Viewport_Flag          :=  0;
    l_Bsc_Kpi_Entity_Rec.Bsc_Language                   := 'US';
    l_Bsc_Kpi_Entity_Rec.Bsc_Num_Options                :=  1;
    l_Bsc_Kpi_Entity_Rec.Bsc_Parent_Anal_Id             :=  0;
    l_Bsc_Kpi_Entity_Rec.Bsc_Source_Language            := 'US';
    l_Bsc_Kpi_Entity_Rec.Created_By                     :=  0;
    l_Bsc_Kpi_Entity_Rec.Last_Updated_By                :=  0;
    l_Bsc_Kpi_Entity_Rec.Last_Update_Login              :=  0;
    l_Bsc_Kpi_Entity_Rec.Last_Update_Login              :=  0;
    BSC_KPI_PUB.Create_Kpi
    (       p_commit              =>    FND_API.G_FALSE
         ,  p_Bsc_Kpi_Entity_Rec  =>    l_Bsc_Kpi_Entity_Rec
         ,  x_return_status       =>    x_return_status
         ,  x_msg_count           =>    x_msg_count
         ,  x_msg_data            =>    x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Kpi Failed: at BSC_KPI_PUB.Create_Kpi');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Create_Kpi procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreatePMDBSCKPIs;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreatePMDBSCKPIs;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreatePMDBSCKPIs;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Create_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Create_Kpi ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO CreatePMDBSCKPIs;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Create_Kpi ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Create_Kpi ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Create_Kpi;

/*********************************************************************************
 This fucntion will validate if time is there within the dimension object.
 It is not necessary that even if the time is associated with the measure
 then it need not be the view by. so no need to check that it time is there
 then it should be the view by also.
 *********************************************************************************/
FUNCTION is_Time_In_Dim_Object
(   p_DimObj_ViewBy_Tbl     IN     BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type
  , p_dim_obj_name          IN     VARCHAR2
) RETURN BOOLEAN IS
    l_Short_Names         VARCHAR2(8000);
    l_Short_Name          VARCHAR2(100);
BEGIN
    IF (TRIM(p_dim_obj_name) IS NULL) THEN
        RETURN FALSE;
    END IF;
    FOR i IN 0..(p_DimObj_ViewBy_Tbl.COUNT-1) LOOP
        IF ((p_DimObj_ViewBy_Tbl(i).p_Is_Time_There)) THEN
            l_short_names  := p_DimObj_ViewBy_Tbl(i).p_Dim_Object_Names;
            WHILE (is_more(p_dim_short_names   =>  l_Short_Names
                         , p_dim_short_name    =>  l_Short_Name)
            ) LOOP
                IF (TRIM(p_dim_obj_name) = l_short_name) THEN
                    RETURN TRUE;
                END IF;
            END LOOP;
        END IF;
    END LOOP;
    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END is_Time_In_Dim_Object;
/************************************************************************************/
FUNCTION is_View_By
(   p_DimObj_ViewBy_Tbl   IN     BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type
  , p_dim_obj_name        IN     VARCHAR2
)RETURN BOOLEAN IS
    l_DimObj_ViewBy_Tbl   BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type;
    l_Dim_Obj             VARCHAR2(100);
    l_View_By             VARCHAR2(100);
BEGIN
    IF (TRIM(p_dim_obj_name) IS NULL) THEN
        RETURN FALSE;
    END IF;
    l_DimObj_ViewBy_Tbl :=  p_DimObj_ViewBy_Tbl;
    FOR i IN 0..(p_DimObj_ViewBy_Tbl.COUNT-1) LOOP
        WHILE (Is_More(   x_dim_objects   =>  l_DimObj_ViewBy_Tbl(i).p_Dim_Object_Names
                      ,   x_View_Bys      =>  l_DimObj_ViewBy_Tbl(i).p_View_By_There
                      ,   x_dim_object    =>  l_Dim_Obj
                      ,   x_View_By       =>  l_view_by
        )) LOOP
            IF (TRIM(p_dim_obj_name) = l_Dim_Obj) THEN
                IF (l_view_by = 'Y') THEN
                    RETURN TRUE;
                ELSE
                    RETURN FALSE;
                END IF;
            END IF;
        END LOOP;
    END LOOP;
    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END is_View_By;
/************************************************************************************/
FUNCTION is_Time_With_Measure
(       p_DimObj_ViewBy_Tbl   IN             BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type
    ,   x_return_status       OUT   NOCOPY   VARCHAR2
    ,   x_msg_count           OUT   NOCOPY   NUMBER
    ,   x_msg_data            OUT   NOCOPY   VARCHAR2
) RETURN BOOLEAN IS
BEGIN
    FOR i IN 0..(p_DimObj_ViewBy_Tbl.COUNT-1) LOOP
        IF ((p_DimObj_ViewBy_Tbl(i).p_Is_Time_There)) THEN
            RETURN TRUE;
        END IF;
    END LOOP;
    RETURN FALSE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END is_Time_With_Measure;
/****************************************************************************
 added by Ravi
/**********************************************************************/
FUNCTION get_anal_opt_comb_message
(
      p_Kpi_Id          IN          BSC_KPIS_B.indicator%TYPE
  ,   p_Option_0        IN          NUMBER
  ,   p_Option_1        IN          NUMBER
  ,   p_Option_2        IN          NUMBER
  ,   p_Sid             IN          NUMBER
)RETURN VARCHAR2
IS
    l_tokens       VARCHAR2(2000);
    l_Msg_Data     VARCHAR2(32000);
    l_msg_count    NUMBER;
BEGIN
    FND_MSG_PUB.Initialize;

    SELECT  Full_Name
    INTO    l_tokens
    FROM    bsc_oaf_analysys_opt_comb_v
    WHERE   Indicator        = p_Kpi_Id
    AND     Analysis_Option0 = p_Option_0
    AND     Analysis_Option1 = p_Option_1
    AND     Analysis_Option2 = p_Option_2
    and     Series_Id        = p_Sid;

    IF(l_tokens IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MEAS_DELETE_DEPEND');
        FND_MESSAGE.SET_TOKEN('MEASURE', l_tokens);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    RETURN NULL;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (l_Msg_Data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  l_Msg_Data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR BSC_BIS_KPI_MEAS_PUB.get_anal_opt_comb_message');
        RETURN l_Msg_Data;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (l_Msg_Data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  l_Msg_Data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR BSC_BIS_KPI_MEAS_PUB.get_anal_opt_comb_message');
        RETURN l_Msg_Data;
    WHEN OTHERS THEN
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||SQLERRM);
        RETURN NULL;
END get_anal_opt_comb_message;
/*********************************************************************************
          API to CREATE DIMENSION-OBJECTS IN  DIMENSION SETS USED IN CASCADING
          It should only be called for BSC type of Dimension Sets not for PMF type
*********************************************************************************/
PROCEDURE Create_Dim_Objs_In_DSet
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   p_kpi_flag_change       IN              NUMBER     := NULL
    ,   p_delete                IN              BOOLEAN    := FALSE
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)IS
    l_bsc_dimset_rec        BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_index                 NUMBER := 0;
    l_count                 NUMBER;

    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  p_kpi_id
    AND     Prototype_Flag    <> 2;

    CURSOR   c_dim_group_id IS
    SELECT   Dim_Group_ID
    FROM     BSC_KPI_DIM_GROUPS
    WHERE    Indicator     =  l_bsc_dimset_rec.Bsc_Kpi_Id
    AND      Dim_Set_Id    =  l_bsc_dimset_rec.Bsc_Dim_Set_Id
    ORDER BY Dim_Group_Index;

    CURSOR   c_dim_level_id IS
    SELECT   A.Dim_Level_Id  Dim_Level_Id
    FROM     BSC_SYS_DIM_LEVELS_BY_GROUP  A
          ,  BSC_SYS_DIM_GROUPS_VL        B
    WHERE    A.Dim_Group_Id = l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id
    AND      A.Dim_Group_ID = B.Dim_Group_ID
    AND      B.Short_Name  <> BSC_BIS_DIMENSION_PUB.Unassigned_Dim;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet procedure');
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_bsc_dimset_rec.Bsc_Dim_Level_Help            := 'XXX';
    l_bsc_dimset_rec.Bsc_Dim_Level_Long_Name       := 'XXX';
    l_bsc_dimset_rec.Bsc_Dim_Tot_Disp_Name         := 'XXX';
    l_bsc_dimset_rec.Bsc_Dset_Comp_Order           :=  0;
    l_bsc_dimset_rec.Bsc_Dset_Dim_Level_Index      :=  1;
    l_bsc_dimset_rec.Bsc_Dset_Parent_Level_Rel     := 'XXX';
    l_bsc_dimset_rec.Bsc_Dset_Position             :=  0;
    l_bsc_dimset_rec.Bsc_Dset_Status               :=  0;
    l_bsc_dimset_rec.Bsc_Dset_Target_Level         :=  1;
    l_bsc_dimset_rec.Bsc_Dset_User_Level0          :=  0;
    l_bsc_dimset_rec.Bsc_Dset_User_Level1          :=  0;
    l_bsc_dimset_rec.Bsc_Dset_User_Level1_Default  :=  0;
    l_bsc_dimset_rec.Bsc_Dset_User_Level2          :=  0;
    l_bsc_dimset_rec.Bsc_Dset_User_Level2_Default  :=  0;
    l_bsc_dimset_rec.Bsc_Dset_Value_Order          :=  0;
    l_bsc_dimset_rec.Bsc_Kpi_Id                    :=  p_kpi_id;
    l_bsc_dimset_rec.Bsc_Level_Name                := 'XXX';
    l_bsc_dimset_rec.Bsc_View_Name                 := 'XXX';
    l_bsc_dimset_rec.Bsc_New_Dset                  := 'Y';
    l_bsc_dimset_rec.Bsc_Option_Id                 :=  0;
    l_bsc_dimset_rec.Bsc_Pk_Col                    := 'XXX';
    l_bsc_dimset_rec.Bsc_Dim_Set_Id                :=  p_dim_set_id;
    l_bsc_dimset_rec.Bsc_Dset_Parent_Level_Rel     :=  NULL;
    l_bsc_dimset_rec.Bsc_Dset_No_Items             :=  0;
    l_bsc_dimset_rec.Bsc_Dset_Level_Display        :=  0;
    l_bsc_dimset_rec.Bsc_Dset_Default_Type         :=  0;
    l_bsc_dimset_rec.Bsc_Dset_Default_Value        := 'T';
    l_bsc_dimset_rec.Bsc_Dset_Parent_In_Total      :=  2;
    l_bsc_dimset_rec.Bsc_Dset_Total0               :=  0;
    l_bsc_dimset_rec.Bsc_Dset_Status               :=  2;
    l_bsc_dimset_rec.Bsc_Dset_User_Level0          :=  2;
    l_bsc_dimset_rec.Bsc_Dset_Filter_Value         :=  0;
    l_bsc_dimset_rec.Bsc_Dset_User_Level1          :=  2;
    l_bsc_dimset_rec.Bsc_Dset_User_Level1_Default  :=  2;
    l_bsc_dimset_rec.Bsc_Dset_User_Level2          :=  NULL;
    l_bsc_dimset_rec.Bsc_Dset_User_Level2_Default  :=  NULL;
    l_bsc_dimset_rec.Bsc_Dim_Tot_Disp_Name         := 'ALL';
    l_bsc_dimset_rec.Bsc_Dim_Comp_Disp_Name        := 'COMPARISON';
    l_bsc_dimset_rec.Bsc_New_Dset                  := 'N';
    l_count                                        :=  0;
    SELECT MAX(NUM) INTO l_count
    FROM    (SELECT   COUNT(SYS_DIM_LEL.Dim_Group_Id) NUM
         ,   SYS_DIM_LEL.Dim_Level_Id
    FROM     BSC_KPI_DIM_GROUPS            KPI_GROUP
         ,   BSC_SYS_DIM_LEVELS_BY_GROUP   SYS_DIM_LEL
    WHERE    KPI_GROUP.Dim_Group_Id   =    SYS_DIM_LEL.Dim_Group_Id
    AND      KPI_GROUP.Indicator      =    l_bsc_dimset_rec.Bsc_Kpi_Id
    AND      KPI_GROUP.Dim_Set_Id     =    l_bsc_dimset_rec.Bsc_Dim_Set_Id
    GROUP BY SYS_DIM_LEL.Dim_Level_Id);
    --dbms_output.PUT_LINE('l_count '||l_count);
    IF (l_count > 1) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_KPI_COMMON_DIM_OBJS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_delete) THEN
        --delete all the dimension objects before creating.
        --dbms_output.PUT_LINE('DELETE ENABLED');
        BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet
        (       p_commit            =>  FND_API.G_FALSE
            ,   p_kpi_id            =>  p_kpi_id
            ,   p_dim_set_id        =>  p_dim_set_id
            ,   x_return_status     =>  x_return_status
            ,   x_msg_count         =>  x_msg_count
            ,   x_msg_data          =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet Failed: at  BSC_DIMENSION_SETS_PUB.Delete_Dim_Objs_In_DSet');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    --remove the default entry 'XXX' from BSC_KPI_DIM_LEVELS_B if exists
    BSC_BIS_KPI_MEAS_PUB.Delete_Default_Kpi_Dim_Object
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_kpi_id                =>  p_kpi_id
        ,   p_dim_set_id            =>  p_dim_set_id
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet Failed: at BSC_BIS_KPI_MEAS_PUB.Delete_Default_Kpi_Dim_Object');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    FOR cn_bsc IN c_dim_group_id LOOP
        l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id :=  cn_bsc.Dim_Group_ID;
        BSC_BIS_LOCKS_PUB.LOCK_KPI
        (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
           ,   p_time_stamp         =>  NULL
           ,   p_Full_Lock_Flag     =>  FND_API.G_FALSE
           ,   x_return_status      =>  x_return_status
           ,   x_msg_count          =>  x_msg_count
           ,   x_msg_data           =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet Failed: at  BSC_BIS_LOCKS_PUB.Lock_Dim_Group');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- END : Granular Locking
        BSC_DIMENSION_SETS_PUB.Create_Dim_Level_Properties--insert into BSC_KPI_DIM_LEVEL_PROPERTIES
        (       p_commit            =>  FND_API.G_FALSE
            ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
            ,   x_return_status     =>  x_return_status
            ,   x_msg_count         =>  x_msg_count
            ,   x_msg_data          =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Level_Properties <'||x_msg_data||'>');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        BSC_DIMENSION_SETS_PUB.Create_Dim_Levels
        (       p_commit            =>  FND_API.G_FALSE
            ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
            ,   x_return_status     =>  x_return_status
            ,   x_msg_count         =>  x_msg_count
            ,   x_msg_data          =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Levels <'||x_msg_data||'>');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
    IF ((p_kpi_flag_change IS NOT NULL) AND (p_kpi_flag_change = BSC_DESIGNER_PVT.G_ActionFlag.Normal)) THEN
        --do not flag any changes to KPIs
        NULL;
        --dbms_output.PUT_LINE('NO CHANGES');
    ELSIF ((p_kpi_flag_change IS NOT NULL) AND (p_kpi_flag_change = BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color)) THEN
        --flag color changes to KPIs
        --IF (NVL(BSC_BIS_KPI_MEAS_PUB.get_DimensionSetSource(l_bsc_dimset_rec.Bsc_Kpi_Id, l_bsc_dimset_rec.Bsc_Dim_Set_Id), 'BSC') = 'BSC') THEN
        IF (NOT BSC_BIS_KPI_MEAS_PUB.is_Pure_Pmf_Dim_Grp(l_bsc_dimset_rec.Bsc_Kpi_Id, l_bsc_dimset_rec.Bsc_Dim_Set_Id)) THEN
            BSC_DESIGNER_PVT.ActionFlag_Change(l_bsc_dimset_rec.Bsc_Kpi_Id , BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color);
        END IF;
        --dbms_output.PUT_LINE('COLOR CHANGES');
    ELSE
        --flag structural changes to KPIs
        --IF (NVL(BSC_BIS_KPI_MEAS_PUB.get_DimensionSetSource(l_bsc_dimset_rec.Bsc_Kpi_Id, l_bsc_dimset_rec.Bsc_Dim_Set_Id), 'BSC') = 'BSC') THEN
        IF (NOT is_Pure_Pmf_Dim_Grp(l_bsc_dimset_rec.Bsc_Kpi_Id, l_bsc_dimset_rec.Bsc_Dim_Set_Id)) THEN
            BSC_DESIGNER_PVT.ActionFlag_Change(l_bsc_dimset_rec.Bsc_Kpi_Id , BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
        END IF;
        --dbms_output.PUT_LINE('STRUCTURAL CHANGES');
    END IF;
    BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
    (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
       ,   p_dim_set_id         =>  l_bsc_dimset_rec.bsc_dim_set_id
       ,   x_return_status      =>  x_return_status
       ,   x_msg_count          =>  x_msg_count
       ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet Failed: at BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET <'||x_msg_data||'>');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --reapeating the steps for shared KPIs also
    FOR cm IN c_kpi_ids LOOP
        l_bsc_dimset_rec.Bsc_Kpi_Id     :=  cm.indicator;
        SELECT MAX(NUM) INTO l_count
        FROM  (SELECT   COUNT(SYS_DIM_LEL.Dim_Group_Id) NUM
             ,   SYS_DIM_LEL.Dim_Level_Id
        FROM     BSC_KPI_DIM_GROUPS            KPI_GROUP
             ,   BSC_SYS_DIM_LEVELS_BY_GROUP   SYS_DIM_LEL
        WHERE    KPI_GROUP.Dim_Group_Id   =    SYS_DIM_LEL.Dim_Group_Id
        AND      KPI_GROUP.Indicator      =    l_bsc_dimset_rec.Bsc_Kpi_Id
        AND      KPI_GROUP.Dim_Set_Id     =    l_bsc_dimset_rec.Bsc_Dim_Set_Id
        GROUP BY SYS_DIM_LEL.Dim_Level_Id);
        IF (l_count > 1) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_KPI_COMMON_DIM_OBJS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        FOR cn_bsc IN c_dim_group_id LOOP
            l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id :=  cn_bsc.Dim_Group_ID;
            BSC_BIS_LOCKS_PUB.LOCK_KPI
            (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
               ,   p_time_stamp         =>  NULL
               ,   p_Full_Lock_Flag     =>  FND_API.G_FALSE
               ,   x_return_status      =>  x_return_status
               ,   x_msg_count          =>  x_msg_count
               ,   x_msg_data           =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet Failed: at  BSC_BIS_LOCKS_PUB.Lock_Dim_Group');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- END : Granular Locking
            BSC_DIMENSION_SETS_PUB.Create_Dim_Level_Properties--insert into BSC_KPI_DIM_LEVEL_PROPERTIES
            (       p_commit            =>  FND_API.G_FALSE
                ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                ,   x_return_status     =>  x_return_status
                ,   x_msg_count         =>  x_msg_count
                ,   x_msg_data          =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Level_Properties <'||x_msg_data||'>');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            BSC_DIMENSION_SETS_PUB.Create_Dim_Levels
            (       p_commit            =>  FND_API.G_FALSE
                ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                ,   x_return_status     =>  x_return_status
                ,   x_msg_count         =>  x_msg_count
                ,   x_msg_data          =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet Failed: at BSC_DIMENSION_SETS_PUB.Create_Dim_Levels <'||x_msg_data||'>');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END LOOP;
        IF ((p_kpi_flag_change IS NOT NULL) AND (p_kpi_flag_change = BSC_DESIGNER_PVT.G_ActionFlag.Normal)) THEN
            --do not flag any changes to KPIs
            NULL;
            --dbms_output.PUT_LINE('NO CHANGES');
        ELSIF ((p_kpi_flag_change IS NOT NULL) AND (p_kpi_flag_change = BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color)) THEN
            --flag color changes to KPIs
            --IF (NVL(BSC_BIS_KPI_MEAS_PUB.get_DimensionSetSource(l_bsc_dimset_rec.Bsc_Kpi_Id, l_bsc_dimset_rec.Bsc_Dim_Set_Id), 'BSC') = 'BSC') THEN
            IF (NOT BSC_BIS_KPI_MEAS_PUB.is_Pure_Pmf_Dim_Grp(l_bsc_dimset_rec.Bsc_Kpi_Id, l_bsc_dimset_rec.Bsc_Dim_Set_Id)) THEN
                BSC_DESIGNER_PVT.ActionFlag_Change(l_bsc_dimset_rec.Bsc_Kpi_Id , BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color);
            END IF;
            --dbms_output.PUT_LINE('COLOR CHANGES');
        ELSE
            --flag structural changes to KPIs
            --IF (NVL(BSC_BIS_KPI_MEAS_PUB.get_DimensionSetSource(l_bsc_dimset_rec.Bsc_Kpi_Id,l_bsc_dimset_rec.Bsc_Dim_Set_Id), 'BSC') = 'BSC') THEN
            IF (NOT BSC_BIS_KPI_MEAS_PUB.is_Pure_Pmf_Dim_Grp(l_bsc_dimset_rec.Bsc_Kpi_Id, l_bsc_dimset_rec.Bsc_Dim_Set_Id)) THEN
                BSC_DESIGNER_PVT.ActionFlag_Change(l_bsc_dimset_rec.Bsc_Kpi_Id , BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
            END IF;
            --dbms_output.PUT_LINE('STRUCTURAL CHANGES');
        END IF;
        BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
        (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
           ,   p_dim_set_id         =>  l_bsc_dimset_rec.bsc_dim_set_id
           ,   x_return_status      =>  x_return_status
           ,   x_msg_count          =>  x_msg_count
           ,   x_msg_data           =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet Failed: at BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET <'||x_msg_data||'>');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
    BSC_BIS_KPI_MEAS_PUB.Create_Default_Kpi_Dim_Object
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_kpi_id                =>  p_kpi_id
        ,   p_dim_set_id            =>  p_dim_set_id
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet Failed: at BSC_DIMENSION_SETS_PUB.Create_Default_Kpi_Dim_Object');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Create_Dim_Objs_In_DSet;

/*********************************************************************************
          API to DELETE DIMENSION-OBJECTS IN  DIMENSION SETS USED IN CASCADING
          It should only be called for BSC type of Dimension Sets not for PMF type
*********************************************************************************/
PROCEDURE Delete_Dim_Objs_In_DSet
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN              NUMBER
    ,   p_dim_set_id            IN              NUMBER
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)IS
    l_bsc_dimset_rec        BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_index                 NUMBER := 0;
    l_count                 NUMBER;

    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator  =  p_kpi_id
    AND     Prototype_Flag   <>  2;

    CURSOR  c_dim_group_id IS
    SELECT  Dim_Group_ID
    FROM    BSC_KPI_DIM_GROUPS
    WHERE   Indicator     =  l_bsc_dimset_rec.Bsc_Kpi_Id
    AND     Dim_Set_Id    =  l_bsc_dimset_rec.Bsc_Dim_Set_Id
    ORDER BY Dim_Group_Index;

    CURSOR  c_dim_level_id IS
    SELECT  dim_level_id
    FROM    BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE   dim_group_id = l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet procedure');
    FND_MSG_PUB.Initialize;
    x_return_status                   := FND_API.G_RET_STS_SUCCESS;
    l_bsc_dimset_rec.Bsc_Kpi_Id       :=  p_kpi_id;
    l_bsc_dimset_rec.Bsc_Dim_Set_Id   :=  p_dim_set_id;
    FOR cn_bsc IN c_dim_group_id LOOP
        l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id   :=  cn_bsc.Dim_Group_ID;
        BSC_BIS_LOCKS_PUB.LOCK_KPI
        (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
           ,   p_time_stamp         =>  NULL
           ,   p_Full_Lock_Flag     =>  FND_API.G_FALSE
           ,   x_return_status      =>  x_return_status
           ,   x_msg_count          =>  x_msg_count
           ,   x_msg_data           =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet Failed: at  BSC_BIS_LOCKS_PUB.Lock_Dim_Group');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        FOR cd IN c_dim_level_id LOOP
            l_bsc_dimset_rec.Bsc_Level_Id   := cd.dim_level_id;
            BSC_DIMENSION_SETS_PUB.Delete_Dim_Level_Properties
            (       p_commit            =>  FND_API.G_FALSE
                ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                ,   x_return_status     =>  x_return_status
                ,   x_msg_count         =>  x_msg_count
                ,   x_msg_data          =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet Failed: at BSC_DIMENSION_SETS_PUB.Delete_Dim_Level_Properties');
                RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            BSC_DIMENSION_SETS_PUB.Delete_Dim_Levels
            (       p_commit            =>  FND_API.G_FALSE
                ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                ,   x_return_status     =>  x_return_status
                ,   x_msg_count         =>  x_msg_count
                ,   x_msg_data          =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet Failed: at BSC_DIMENSION_SETS_PUB.Delete_Dim_Levels');
                RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END LOOP;
    END LOOP;
    BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
    (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
       ,   p_dim_set_id         =>  l_bsc_dimset_rec.bsc_dim_set_id
       ,   x_return_status      =>  x_return_status
       ,   x_msg_count          =>  x_msg_count
       ,   x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet Failed: at BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET <'||x_msg_data||'>');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --for share KPIs
    FOR cm IN c_kpi_ids LOOP
        l_bsc_dimset_rec.Bsc_Kpi_Id     :=  cm.indicator;
        FOR cn_bsc IN c_dim_group_id LOOP
            l_bsc_dimset_rec.Bsc_Dim_Level_Group_Id   :=  cn_bsc.Dim_Group_ID;
            BSC_BIS_LOCKS_PUB.LOCK_KPI
            (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
               ,   p_time_stamp         =>  NULL
               ,   p_Full_Lock_Flag     =>  FND_API.G_FALSE
               ,   x_return_status      =>  x_return_status
               ,   x_msg_count          =>  x_msg_count
               ,   x_msg_data           =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet Failed: at  BSC_BIS_LOCKS_PUB.Lock_Dim_Group');
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            FOR cd IN c_dim_level_id LOOP
                l_bsc_dimset_rec.Bsc_Level_Id   := cd.dim_level_id;
                BSC_DIMENSION_SETS_PUB.Delete_Dim_Level_Properties
                (       p_commit            =>  FND_API.G_FALSE
                    ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                    ,   x_return_status     =>  x_return_status
                    ,   x_msg_count         =>  x_msg_count
                    ,   x_msg_data          =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet Failed: at BSC_DIMENSION_SETS_PUB.Delete_Dim_Level_Properties');
                    RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                BSC_DIMENSION_SETS_PUB.Delete_Dim_Levels
                (       p_commit            =>  FND_API.G_FALSE
                    ,   p_Dim_Set_Rec       =>  l_bsc_dimset_rec
                    ,   x_return_status     =>  x_return_status
                    ,   x_msg_count         =>  x_msg_count
                    ,   x_msg_data          =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet Failed: at BSC_DIMENSION_SETS_PUB.Delete_Dim_Levels');
                    RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END LOOP;
        END LOOP;
        BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET
        (      p_Kpi_Id             =>  l_bsc_dimset_rec.Bsc_Kpi_Id
           ,   p_dim_set_id         =>  l_bsc_dimset_rec.bsc_dim_set_id
           ,   x_return_status      =>  x_return_status
           ,   x_msg_count          =>  x_msg_count
           ,   x_msg_data           =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet Failed: at BSC_BIS_LOCKS_PUB.SET_TIME_STAMP_DIM_SET <'||x_msg_data||'>');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
    --create the default entry 'XXX' from BSC_KPI_DIM_LEVELS_B if exists
    BSC_BIS_KPI_MEAS_PUB.Create_Default_Kpi_Dim_Object
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_kpi_id                =>  p_kpi_id
        ,   p_dim_set_id            =>  p_dim_set_id
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet Failed: at BSC_DIMENSION_SETS_PUB.Create_Default_Kpi_Dim_Object');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --dbms_output.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_Dim_Objs_In_DSet;
/********************************************************************************/
FUNCTION get_KPIs
(       p_Kpi_ID                IN          NUMBER
    ,   p_Dim_Set_ID            IN          NUMBER -- IN creation pass null to it
) RETURN VARCHAR2 IS
    l_Msg_Data              VARCHAR2(32000);
    l_msg_count             NUMBER;
    l_kpi_names             VARCHAR2(32000);
    l_Count                 NUMBER;

    CURSOR  c_dim_set_kpi IS
    SELECT  Name||'['||Indicator||']' Indicator
    FROM    BSC_KPIS_VL
    WHERE  (Source_Indicator =  p_kpi_id
    OR      Indicator        =  p_kpi_id)
    AND     share_flag      <>  2;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.get_KPIs Function');
    FND_MSG_PUB.Initialize;
    IF (p_Kpi_ID IS NULL) THEN
        RETURN NULL;
    END IF;
    IF (NOT BSC_UTILITY.isBscInProductionMode()) THEN
        RETURN NULL;
    END IF;
    IF (p_Dim_Set_ID IS NOT NULL) THEN
        SELECT COUNT(*) INTO l_Count
        FROM   BSC_KPI_DIM_GROUPS
        WHERE  Indicator  =  p_Kpi_ID
        AND    Dim_Set_Id =  p_Dim_Set_ID;
        IF (l_Count = 0) THEN
            RETURN NULL;
        END IF;
    END IF;
    FOR cd IN c_dim_set_kpi LOOP
        IF (l_kpi_names IS NULL) THEN
            l_kpi_names := cd.Indicator;
        ELSE
            l_kpi_names := l_kpi_names||', '||cd.Indicator;
        END IF;
    END LOOP;
    IF (l_kpi_names IS NOT NULL) THEN
        --raise exception for Structural Changes
        FND_MESSAGE.SET_NAME('BSC','BSC_PMD_KPI_STRUCT_INVALID');
        FND_MESSAGE.SET_TOKEN('INDICATORS', l_kpi_names);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.get_KPIs Function');
    RETURN NULL;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (l_Msg_Data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  l_Msg_Data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR BSC_BIS_KPI_MEAS_PUB.get_KPIs');
        RETURN l_Msg_Data;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (l_Msg_Data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  l_Msg_Data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR BSC_BIS_KPI_MEAS_PUB.get_KPIs');
        RETURN l_Msg_Data;
    WHEN OTHERS THEN
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||SQLERRM);
        RETURN NULL;
END get_KPIs;
/********************************************************************************
    WARNING : -
    This function will return false if any changes Dimensions within Dimension-Sets
    will results in structural changes. This is designed to fulfil the UI screen
    need and not a generic function so it should not be called internally from any
    other APIs without proper impact analysis.
********************************************************************************/
FUNCTION is_KPI_Flag_For_Dim_In_DimSets
(       p_Kpi_ID                IN          NUMBER
    ,   p_Dim_Set_ID            IN          NUMBER
    ,   p_Unassign_dim_names    IN          VARCHAR2
    ,   p_Dim_Short_Names       IN          VARCHAR2
) RETURN VARCHAR2 IS
    l_Msg_Data              VARCHAR2(32000);
    l_msg_count             NUMBER;

    l_dimension             BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
    l_Dimension_Old_Name    BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;

    l_old_dimensions        VARCHAR2(8000)  := NULL;
    l_temp_dimensions       VARCHAR2(8000);
    l_temp_var              VARCHAR2(8000);
    l_kpi_names             VARCHAR2(32000);

    l_Struct_Flag           BOOLEAN := FALSE;
    l_flag                  BOOLEAN;
    l_Dim_Short_Names       VARCHAR2(32000);
    l_unassigns             VARCHAR2(32000);
    l_assigns               VARCHAR2(32000);
    l_unassign              BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
    l_assign                BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
    l_unassign_dim_objs     VARCHAR2(32000);


    CURSOR   c_Old_Dimensions IS
    SELECT   A.Short_Name
          ,  B.Dim_Group_Index
    FROM     BSC_SYS_DIM_GROUPS_VL    A
          ,  BSC_KPI_DIM_GROUPS       B
    WHERE    A.Dim_Group_Id   =   B.Dim_Group_Id
    AND      B.Indicator      =   p_Kpi_ID
    AND      B.Dim_Set_ID     =   p_Dim_Set_ID
    ORDER BY B.Dim_Group_Index;
BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.is_KPI_Flag_For_Dim_In_DimSets Function');
    FND_MSG_PUB.Initialize;
    l_Dim_Short_Names   := p_Dim_Short_Names;
    IF (p_Kpi_ID IS NULL) THEN
        RETURN NULL;
    END IF;
    IF (NOT BSC_UTILITY.isBscInProductionMode()) THEN
        RETURN NULL;
    END IF;
    l_unassign_dim_objs := NULL;
    IF (p_Dim_Set_ID IS NOT NULL) THEN
        IF (p_Unassign_dim_names IS NOT NULL) THEN
            l_unassigns   :=  p_Unassign_dim_names;
            WHILE (is_more(p_dim_short_names   =>  l_unassigns
                          ,p_dim_short_name    =>  l_unassign)
            ) LOOP
                l_assigns   :=  p_Dim_Short_Names;
                l_flag      :=  TRUE;
                WHILE (is_more(     p_dim_short_names   =>  l_assigns
                                ,   p_dim_short_name    =>  l_assign)
                ) LOOP
                    IF(l_unassign = l_assign) THEN
                        l_flag  :=  FALSE;
                        EXIT;
                    END IF;
                END LOOP;
                IF(l_flag) THEN
                    IF (l_unassign_dim_objs IS NULL) THEN
                        l_unassign_dim_objs    :=  l_unassign;
                    ELSE
                        l_unassign_dim_objs    :=  l_unassign_dim_objs||', '||l_unassign;
                    END IF;
                END IF;
            END LOOP;
        END IF;
    END IF;
    --dbms_output.PUT_LINE('l_unassign_dim_objs  <'||l_unassign_dim_objs||'>');
    IF (l_unassign_dim_objs IS NOT NULL) THEN
        l_Struct_Flag   := TRUE;
    END IF;
    IF ((NOT l_Struct_Flag) AND (p_Dim_Short_Names IS NULL)) THEN
        RETURN NULL;
    END IF;
    IF (NOT l_Struct_Flag) THEN
        FOR cd IN c_Old_Dimensions LOOP
            l_flag          :=  TRUE;
            l_temp_var      :=  p_Dim_Short_Names;
            IF (l_old_dimensions IS NULL) THEN
                l_old_dimensions   := cd.Short_Name;
            ELSE
                l_old_dimensions   := l_old_dimensions||','||cd.Short_Name;
            END IF;
        END LOOP;
    END IF;
    IF ((l_old_dimensions IS NULL) AND (p_Dim_Short_Names IS NOT NULL)) THEN
        l_Struct_Flag       :=  TRUE;
    ELSIF (l_old_dimensions IS NULL) THEN
        l_Dim_Short_Names   :=  p_Dim_Short_Names;
    ELSE
        l_Dim_Short_Names   :=  l_old_dimensions||','||p_Dim_Short_Names;
    END IF;
    IF (NOT l_Struct_Flag) THEN
        FOR cd IN c_Old_Dimensions LOOP
            l_flag          :=  TRUE;
            l_temp_var      :=  l_Dim_Short_Names;
            IF (l_old_dimensions IS NULL) THEN
                l_old_dimensions   := cd.Short_Name;
            ELSE
                l_old_dimensions   := l_old_dimensions||','||cd.Short_Name;
            END IF;
            WHILE (is_more(p_dim_short_names  =>  l_temp_var
                        ,  p_dim_short_name   =>  l_dimension
            )) LOOP
                IF (l_dimension = cd.Short_Name) THEN
                    l_flag  :=  FALSE;
                    EXIT;
                END IF;
            END LOOP;
            IF (l_flag) THEN
                --dbms_output.PUT_LINE('cd.Short_Name     <'||cd.Short_Name||'>');
                l_Struct_Flag   := TRUE;
                EXIT;
            END IF;
        END LOOP;
    END IF;
    --dbms_output.PUT_LINE('l_old_dimensions  '||l_old_dimensions);
    IF (NOT l_Struct_Flag) THEN
        l_temp_var   :=  l_Dim_Short_Names;
        WHILE (is_more(p_dim_short_names   =>  l_temp_var
                    ,  p_dim_short_name    =>  l_dimension
        )) LOOP
            l_flag              :=  TRUE;
            l_temp_dimensions   :=  l_old_dimensions;
            WHILE (is_more(p_dim_short_names   =>  l_temp_dimensions
                        ,  p_dim_short_name    =>  l_Dimension_Old_Name
            )) LOOP
                IF (l_Dimension_Old_Name = l_dimension) THEN
                    l_flag  :=  FALSE;
                    EXIT;
                END IF;
            END LOOP;
            IF (l_flag) THEN
                --dbms_output.PUT_LINE('l_dimension     <'||l_dimension||'>');
                l_Struct_Flag   := TRUE;
                EXIT;
            END IF;
        END LOOP;
    END IF;
    /*IF (l_Struct_Flag) THEN
        --dbms_output.PUT_LINE('l_Struct_Flag IS TRUE');
    ELSE
        --dbms_output.PUT_LINE('l_Struct_Flag IS FALSE');
    END IF;*/
    l_kpi_names :=  BSC_BIS_KPI_MEAS_PUB.get_KPIs(p_Kpi_ID, NULL);
    IF ((l_Struct_Flag) AND (l_kpi_names IS NOT NULL)) THEN
        l_Msg_Data := l_kpi_names;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.is_KPI_Flag_For_Dim_In_DimSets Function');
    RETURN NULL;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (l_Msg_Data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  l_Msg_Data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR BSC_BIS_KPI_MEAS_PUB.is_KPI_Flag_For_Dim_In_DimSets');
        RETURN l_Msg_Data;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (l_Msg_Data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  l_Msg_Data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR BSC_BIS_KPI_MEAS_PUB.is_KPI_Flag_For_Dim_In_DimSets');
        RETURN l_Msg_Data;
    WHEN OTHERS THEN
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||SQLERRM);
        RETURN NULL;
END is_KPI_Flag_For_Dim_In_DimSets;
--=============================================================================
FUNCTION check_config_impact_dimset
(        p_Kpi_ID                IN          NUMBER
     ,   p_Dim_Set_ID            IN          NUMBER   := NULL
     ,   p_Unassign_dim_names    IN          VARCHAR2
     ,   p_Dim_Short_Names       IN          VARCHAR2
) RETURN VARCHAR2 IS
    TYPE index_by_table IS Record
    (       p_dim_short_name       VARCHAR2(30)
    );
    TYPE index_by_table_type IS TABLE OF index_by_table INDEX BY BINARY_INTEGER;

    l_old_dim_array             index_by_table_type;
    l_dim_objs_array            index_by_table_type;
    l_unassign_dim_name         VARCHAR2(32000);
    l_assign_dim_name           VARCHAR2(32000);
    l_dim_name_after_remove     VARCHAR2(32000);
    l_final_dim_names           VARCHAR2(32000);
    l_dimobj_name_rel           VARCHAR2(32000);
    l_count                     NUMBER;
    l_no_rels                   NUMBER;
    l_dim_set_count             NUMBER;
    l_dim_set_count_temp        NUMBER;
    l_Msg_Data                  VARCHAR2(32000);
    l_msg_count                 NUMBER;

    CURSOR   cr_Old_Dimensions IS
    SELECT   A.Short_Name
    FROM     BSC_SYS_DIM_GROUPS_VL    A
           , BSC_KPI_DIM_GROUPS       B
    WHERE    A.Dim_Group_Id   =   B.Dim_Group_Id
    AND      B.Indicator      =   p_Kpi_ID
    AND      B.Dim_Set_ID     =   p_Dim_Set_ID
    ORDER BY B.Dim_Group_Index;

    CURSOR   cr_dim_objs_in_dimset IS
    SELECT   VL.SHORT_NAME
    FROM     BSC_SYS_DIM_LEVELS_B        VL ,
             BSC_SYS_DIM_LEVELS_BY_GROUP DG ,
             BSC_SYS_DIM_GROUPS_VL       TL
    WHERE    VL.DIM_LEVEL_ID = DG.DIM_LEVEL_ID
    AND      DG.dim_group_id = TL.DIM_GROUP_ID
    AND      INSTR(l_final_dim_names,','||TL.SHORT_NAME||',') > 0;

    i NUMBER;
    l_dim_short_name       VARCHAR2(30);

BEGIN
    FND_MSG_PUB.Initialize;
    l_unassign_dim_name := p_Unassign_dim_names;
    l_assign_dim_name   := p_Dim_Short_Names;
    OPEN  cr_Old_Dimensions;
    -- bug#3405498 meastmon 28-jan-2004: The following is not supported in 8i
    --FETCH cr_Old_Dimensions BULK COLLECT INTO l_old_dim_array;
    l_old_dim_array.delete;
    i := 0;
    LOOP
        FETCH cr_Old_Dimensions INTO l_dim_short_name;
        EXIT WHEN cr_Old_Dimensions%NOTFOUND;
        i := i+1;
        l_old_dim_array(i).p_dim_short_name := l_dim_short_name;
    END LOOP;
    CLOSE cr_Old_Dimensions;

    --dbms_output.PUT_LINE('UNASSIGNED NAMES ARE :-  '||l_unassign_dim_name);
    --dbms_output.PUT_LINE('CHECKING DIM OBJECTS');
    IF(l_unassign_dim_name IS NULL) THEN
        --dbms_output.PUT_LINE('IF LOOP');
        FOR index_loop IN 1..(l_old_dim_array.COUNT) LOOP
            IF(l_dim_name_after_remove IS NULL) THEN
                l_dim_name_after_remove := l_old_dim_array(index_loop).p_dim_short_name;
            ELSE
                l_dim_name_after_remove :=l_dim_name_after_remove || ','||l_old_dim_array(index_loop).p_dim_short_name;
            END IF;
        END LOOP;
    ELSE
        --dbms_output.PUT_LINE('IF LOOP');
        FOR index_loop IN 1..(l_old_dim_array.COUNT) LOOP
            IF (Instr(l_unassign_dim_name,l_old_dim_array(index_loop).p_dim_short_name) = 0 ) THEN
            --dbms_output.PUT_LINE('ADDING DIM :-  '||l_old_dim_array(index_loop).p_dim_short_name);
            IF(l_dim_name_after_remove IS NULL) THEN
                l_dim_name_after_remove := l_old_dim_array(index_loop).p_dim_short_name;
            ELSE
                l_dim_name_after_remove :=l_dim_name_after_remove || ','||l_old_dim_array(index_loop).p_dim_short_name;
            END IF;
            END IF;
        END LOOP;
    END IF;
    --dbms_output.PUT_LINE('after remove  DIMS ARE  '||l_dim_name_after_remove);
    l_final_dim_names := l_dim_name_after_remove ||','|| l_assign_dim_name;
    l_final_dim_names := ','||l_final_dim_names;
    --dbms_output.PUT_LINE('FINAL DIMS ARE  '||l_final_dim_names);

    SELECT COUNT(b.dim_level_id) INTO l_count
    FROM   BSC_SYS_DIM_LEVELS_BY_GROUP b,
           BSC_SYS_DIM_GROUPS_VL       vl
    WHERE  b.dim_group_id = vl.dim_group_id
    AND    INSTR(l_final_dim_names,','||vl.short_name ||',')>0 ;
    --dbms_output.PUT_LINE('THE COUNT OF DIMOBJECTS :- '||l_count );
    IF(l_count > BSC_BIS_KPI_MEAS_PUB.CONFIG_LIMIT_DIM) THEN
        --dbms_output.PUT_LINE('DIMESION OBJECTS MESSAEGE' );
        FND_MESSAGE.SET_NAME('BSC','BSC_PMD_IMPACT_KPI_SPACE');
        FND_MESSAGE.SET_TOKEN('CONTINUE', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'YES'), TRUE);
        FND_MESSAGE.SET_TOKEN('CANCEL', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'NO'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT COUNT(DIM_SET_ID) INTO l_dim_set_count
    FROM   BSC_KPI_DIM_SETS_VL
    WHERE  INDICATOR = p_Kpi_ID;
    IF (l_dim_set_count > BSC_BIS_KPI_MEAS_PUB.CONFIG_LIMIT_DIMSET ) THEN
        --dbms_output.PUT_LINE('FIRST dimset IF LOOP' );
        FND_MESSAGE.SET_NAME('BSC','BSC_PMD_IMPACT_KPI_SUMMARY_LVL');
        FND_MESSAGE.SET_TOKEN('CONTINUE', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'YES'), TRUE);
        FND_MESSAGE.SET_TOKEN('CANCEL', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'NO'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --dbms_output.PUT_LINE('DIM SET COUNT  :- '||l_dim_set_count );
    IF(l_dim_set_count = BSC_BIS_KPI_MEAS_PUB.CONFIG_LIMIT_DIMSET AND p_Dim_Set_ID IS NULL ) THEN
        --dbms_output.PUT_LINE('dimset IF LOOP' );
        FND_MESSAGE.SET_NAME('BSC','BSC_PMD_IMPACT_KPI_SUMMARY_LVL');
        FND_MESSAGE.SET_TOKEN('CONTINUE', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'YES'), TRUE);
        FND_MESSAGE.SET_TOKEN('CANCEL', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'NO'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN cr_dim_objs_in_dimset ;
    -- bug#3405498 meastmon 28-jan-2004: The following is not supported in 8i
    --FETCH cr_dim_objs_in_dimset BULK COLLECT INTO l_dim_objs_array;
    l_dim_objs_array.delete;
    i := 0;
    LOOP
        FETCH cr_dim_objs_in_dimset INTO l_dim_short_name;
        EXIT WHEN cr_dim_objs_in_dimset%NOTFOUND;
        i := i+1;
        l_dim_objs_array(i).p_dim_short_name := l_dim_short_name;
    END LOOP;
    CLOSE cr_dim_objs_in_dimset;

    FOR index_loop IN 1..(l_dim_objs_array.COUNT) LOOP
        IF(l_dimobj_name_rel IS NULL) THEN
            l_dimobj_name_rel := l_dim_objs_array(index_loop).p_dim_short_name;
        ELSE
            l_dimobj_name_rel := l_dimobj_name_rel ||','||l_dim_objs_array(index_loop).p_dim_short_name;
        END IF;
    END LOOP;
    --dbms_output.PUT_LINE('The final dimension objects are :- '||l_dimobj_name_rel );
    l_no_rels := get_no_rels(p_dim_obj_sht_names => l_dimobj_name_rel);
    --dbms_output.PUT_LINE('THE NO OF RELATIONS ARE :- '||l_no_rels  );
    IF(l_no_rels > BSC_BIS_KPI_MEAS_PUB.CONFIG_LIMIT_RELS) THEN
        --dbms_output.PUT_LINE('RELATIONS MESSAGE' );
        FND_MESSAGE.SET_NAME('BSC','BSC_PMD_IMPACT_KPI_SUMMARY_LVL');
        FND_MESSAGE.SET_TOKEN('CONTINUE', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'YES'), TRUE);
        FND_MESSAGE.SET_TOKEN('CANCEL',   BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'NO'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF(cr_dim_objs_in_dimset %ISOPEN) THEN
        CLOSE cr_dim_objs_in_dimset ;
    END IF;
    IF(cr_Old_Dimensions %ISOPEN) THEN
        CLOSE cr_Old_Dimensions ;
    END IF;
    RETURN NULL;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (l_Msg_Data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  l_Msg_Data
            );
        END IF;
        IF(cr_dim_objs_in_dimset %ISOPEN) THEN
            CLOSE cr_dim_objs_in_dimset ;
        END IF;
        IF(cr_Old_Dimensions %ISOPEN) THEN
            CLOSE cr_Old_Dimensions ;
        END IF;
        RETURN  l_Msg_Data;
    WHEN OTHERS THEN
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||SQLERRM);
        IF(cr_dim_objs_in_dimset %ISOPEN) THEN
            CLOSE cr_dim_objs_in_dimset ;
        END IF;
        IF(cr_Old_Dimensions %ISOPEN) THEN
            CLOSE cr_Old_Dimensions ;
        END IF;
        RETURN NULL;
END check_config_impact_dimset;
--=============================================================================
FUNCTION get_no_rels
(p_dim_obj_sht_names IN VARCHAR2
)RETURN NUMBER
IS
    l_no_rels                  NUMBER;
    index_loop                 NUMBER;
    l_count                    NUMBER;
    l_dim_short_name_temp      VARCHAR2(32000);
    l_dim_short_names          VARCHAR2(32000);
    l_whole_str_temp           VARCHAR2(32000);
    l_sht_tmp                  VARCHAR2(32000);
    TYPE One_To_N_Index_Type IS Record
    (       p_dim_short_name   VARCHAR2(30)
    );
    TYPE One_To_N_Index_Table IS TABLE OF One_To_N_Index_Type INDEX BY BINARY_INTEGER;
    dim_objs_array_temp         One_To_N_Index_Table;

    CURSOR cr_rel_parent_names IS
    SELECT PARENT_SHORT_NAME
    FROM   BSC_SYS_DIM_LEVEL_RELS_V
    WHERE  SHORT_NAME = l_dim_short_name_temp;

    i NUMBER;
    l_dim_short_name   VARCHAR2(30);

BEGIN
     l_no_rels := 0;
     l_dim_short_names    := p_dim_obj_sht_names;
     WHILE(Is_More(  p_dim_short_names   => l_dim_short_names
                  ,  p_dim_short_name    => l_dim_short_name_temp))
     LOOP
        --dbms_output.PUT_LINE('checkin for dim in getnorels :-  '|| l_dim_short_name_temp);
       IF(cr_rel_parent_names%ISOPEN) THEN
            CLOSE cr_rel_parent_names;
       END IF;
       OPEN cr_rel_parent_names;
       -- bug#3405498 meastmon 28-jan-2004: The following is not supported in 8i
       --FETCH cr_rel_parent_names BULK COLLECT INTO dim_objs_array_temp;
       dim_objs_array_temp.delete;
       i := 0;
       LOOP
           FETCH cr_rel_parent_names INTO l_dim_short_name;
           EXIT WHEN cr_rel_parent_names%NOTFOUND;
           i := i+1;
           dim_objs_array_temp(i).p_dim_short_name := l_dim_short_name;
       END LOOP;
       CLOSE cr_rel_parent_names;

       l_count          := 0;
       l_whole_str_temp := ','|| p_dim_obj_sht_names||',';
       FOR index_loop IN 1..(dim_objs_array_temp.COUNT) LOOP
            l_sht_tmp := ','||dim_objs_array_temp(index_loop).p_dim_short_name||',';
            IF(Instr(l_whole_str_temp,l_sht_tmp) > 0) THEN
                l_count := l_count + 1;
                --dbms_output.PUT_LINE('found relation for :-  '|| dim_objs_array_temp(index_loop).p_dim_short_name);
            END IF;
       END LOOP;
       IF(l_count > 0) THEN
            l_no_rels := l_no_rels + 1;
       END IF;
     END LOOP;
     IF(cr_rel_parent_names %ISOPEN) THEN
        CLOSE cr_rel_parent_names ;
     END IF;
     RETURN l_no_rels;
EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.PUT_LINE('EXCEPTION OTHERS '||SQLERRM);
      IF(cr_rel_parent_names %ISOPEN) THEN
        CLOSE cr_rel_parent_names ;
      END IF;
      RETURN l_no_rels;
END get_no_rels;

/*********************************************************************************
  API TO GET MEAS COUNT IN OBJECTIVE - ONLY BSC MEASURES FOR NORMAL OBJECTIVES,
  AND ALL MEASURES FOR OBJs CREATED FROM AG FLOW. THIS IS USED TO DETERMINE
  STRUCTURAL CHANGE
*********************************************************************************/

FUNCTION get_Struct_Meas_Count
(  p_kpi_id   IN  NUMBER

) RETURN NUMBER IS

l_count     NUMBER;
l_new_count NUMBER;
l_sname     BSC_KPIS_B.SHORT_NAME%TYPE;

BEGIN

SELECT short_name
INTO l_sname
FROM BSC_KPIS_B
WHERE INDICATOR = p_kpi_id;

IF (l_sname IS NOT NULL) THEN

 SELECT COUNT (DISTINCT dataset_id) INTO l_count
   FROM BSC_KPI_ANALYSIS_MEASURES_B
   WHERE INDICATOR = p_kpi_id;

ELSE

  SELECT COUNT (DISTINCT A.dataset_id) INTO l_count
    FROM BSC_KPI_ANALYSIS_MEASURES_B A, BSC_SYS_DATASETS_B B
    WHERE INDICATOR = p_kpi_id
    AND A.DATASET_ID = B.DATASET_ID
    AND B.SOURCE = 'BSC';

END IF;
RETURN l_count;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;

END get_Struct_Meas_Count;

/*********************************************************************************
         API TO DELETE PMF/BSC MEASURES/ANALYSIS OPTIONS WITHIN AN INDICATOR
*********************************************************************************/
PROCEDURE Delete_KPI_Multi_Groups_Opts
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_kpi_id                IN          NUMBER
    ,   p_data_source           IN          VARCHAR2
    ,   p_Option_0              IN          NUMBER
    ,   p_Option_1              IN          NUMBER
    ,   p_Option_2              IN          NUMBER
    ,   p_Sid                   IN          NUMBER
    ,   p_time_stamp            IN          VARCHAR2   := NULL
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
    l_Anal_Num_Tbl              BSC_ANALYSIS_OPTION_PUB.Anal_Opt_Comb_Num_Tbl_Type;
    l_old_Anal_Opt_Tbl          BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type;
    l_Anal_Opt_Rec              BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
    l_Anal_Opt_Tbl              BSC_ANALYSIS_OPTION_PUB.Bsc_Anal_Opt_Tbl_Type;
    l_Bsc_Anal_Opt_Rec          BSC_ANALYSIS_OPTION_PUB.Bsc_Option_Rec_Type;
    l_Bsc_Dim_Set_Rec_Type      BSC_DIMENSION_SETS_PUB.Bsc_Dim_Set_Rec_Type;
    l_Bsc_Kpi_Entity_Rec        BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;
    l_count                     NUMBER;
    l_Default_Delete            BOOLEAN := FALSE;
    l_ind_type                  BSC_KPIS_B.indicator_type%TYPE;
    l_max_group_count           NUMBER;
    l_new_count                 NUMBER;
    l_series_count              NUMBER;
    l_tab_id                    NUMBER;
    l_series_delete             BOOLEAN;
    l_kpi_id                    BSC_KPIS_B.indicator%TYPE;

    CURSOR   c_kpi_anal_group IS
    SELECT   Analysis_Group_Id
         ,   Num_Of_Options
         ,   Dependency_Flag
    FROM     BSC_KPI_ANALYSIS_GROUPS
    WHERE    Indicator = p_kpi_id
    ORDER BY Analysis_Group_Id;

    CURSOR  c_kpi_ids IS
    SELECT  indicator
    FROM    BSC_KPIS_B
    WHERE   Source_Indicator =   p_kpi_id
    AND     Prototype_Flag   <>  2;

BEGIN
    --dbms_output.PUT_LINE('Entered inside BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Multi_Groups_Opts procedure');
    SAVEPOINT DeleteBSCKPIMulAnaOpts;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_data_source IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DATA_SOURCE'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF ((p_data_source <> 'BSC') AND (p_data_source <> 'PMF')) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DATA_SOURCE');
        FND_MSG_PUB.ADD;
        RAISE           FND_API.G_EXC_ERROR;
    END IF;

    l_series_delete                                 :=  FALSE;
    l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id                   :=  p_kpi_id;
    l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id       :=  p_Option_0;
    l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id        :=  0;
    IF (l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id = 0) THEN
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0        :=  l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1        :=  0;
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2        :=  0;
    ELSIF (l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id = 1) THEN
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1        :=  l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0        :=  0;
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2        :=  0;
    ELSE
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2        :=  l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id;
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0        :=  0;
        l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1        :=  0;
    END IF;

    IF (l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT  COUNT(*) INTO l_count
    FROM    BSC_KPIS_B
    WHERE   indicator = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;
    IF (l_count = 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'KPI_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Option_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON',  'ANALYSIS_OPTIONS'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_Bsc_Anal_Opt_Rec.Bsc_Analysis_Group_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON',  'ANALYSIS_GROUP'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT  share_flag  INTO    l_count
    FROM    BSC_KPIS_B
    WHERE   indicator = l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id;
    IF (l_count = 2) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_SHARED_KPI');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- obtain dimension set id this option is using.
    SELECT  dim_set_id INTO l_Bsc_Anal_Opt_Rec.Bsc_Dim_Set_Id
    FROM    BSC_KPI_ANALYSIS_OPTIONS_B
    WHERE   indicator         = p_kpi_id
    AND     analysis_group_id = 0
    AND     option_id         = p_Option_0;
    -- START Granular Locking - Lock the KPI Under consideration

    BSC_BIS_LOCKS_PUB.LOCK_KPI
    (       p_Kpi_Id             =>  l_Bsc_Anal_Opt_Rec.Bsc_Kpi_Id
       ,    p_time_stamp         =>  NULL
       ,    p_Full_Lock_Flag     =>  NULL
       ,    x_return_status      =>  x_return_status
       ,    x_msg_count          =>  x_msg_count
       ,    x_msg_data           =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_LOCKS_PUB.LOCK_KPI - Failed');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Determine number of distinct dataset_id before delete.
    /*SELECT COUNT (DISTINCT dataset_id) INTO l_count
    FROM BSC_KPI_ANALYSIS_MEASURES_B
    WHERE INDICATOR = p_kpi_id;*/

    l_count := get_Struct_Meas_Count(p_kpi_id);

    BSC_BIS_KPI_MEAS_PUB.store_kpi_anal_group(p_kpi_id, l_Anal_Opt_Tbl);
    BSC_ANALYSIS_OPTION_PUB.store_anal_opt_grp_count(p_kpi_id,l_old_Anal_Opt_Tbl);


    l_Anal_Opt_Rec.Bsc_Kpi_Id                   := p_kpi_id;
    l_Anal_Opt_Rec.Bsc_Option_Group0            := p_Option_0;
    l_Anal_Opt_Rec.Bsc_Option_Group1            := p_Option_1;
    l_Anal_Opt_Rec.Bsc_Option_Group2            := p_Option_2;
    l_Anal_Opt_Rec.Bsc_Dataset_Series_Id        := p_Sid;

    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group0        := p_Option_0;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group1        := p_Option_1;
    l_Bsc_Anal_Opt_Rec.Bsc_Option_Group2        := p_Option_2;
    l_Bsc_Anal_Opt_Rec.Bsc_Dataset_Series_Id    := p_Sid;

    /*** Check if the source is PMF then directly call the previous API*/
    IF (p_data_source = 'BSC') THEN
        SELECT COUNT(0)
        INTO   l_max_group_count
        FROM   BSC_KPI_ANALYSIS_GROUPS
        WHERE  INDICATOR = p_kpi_id;

        l_Anal_Num_Tbl(0) := p_Option_0;
        l_Anal_Num_Tbl(1) := p_Option_1;
        l_Anal_Num_Tbl(2) := p_Option_2;

        IF (l_max_group_count > 1) THEN
            BSC_ANALYSIS_OPTION_PUB.Delete_Ana_Opt_Mult_Groups
            (      p_commit              =>    FND_API.G_FALSE
               ,   p_Kpi_id              =>    p_kpi_id
               ,   p_Anal_Opt_Tbl        =>    l_Anal_Opt_Tbl
               ,   p_max_group_count     =>    l_max_group_count
               ,   p_Anal_Opt_Comb_Tbl   =>    l_Anal_Num_Tbl
               ,   p_Anal_Opt_Rec        =>    l_Anal_Opt_Rec
               ,   x_return_status       =>    x_return_status
               ,   x_msg_count           =>    x_msg_count
               ,   x_msg_data            =>    x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
               --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Ana_Opt_Mult_Groups Failed: at BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Options');
               RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        ELSE
            l_Default_Delete    := TRUE;
        END IF;
    END IF;
    IF ((p_data_source = 'PMF') OR (l_Default_Delete)) THEN
        BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Analysis_Options
        (       p_Bsc_Anal_Opt_Rec  =>  l_Bsc_Anal_Opt_Rec
            ,   p_data_source       =>  p_data_source
            ,   x_return_status     =>  x_return_status
            ,   x_msg_count         =>  x_msg_count
            ,   x_msg_data          =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_Ana_Opt_Mult_Groups Failed: at BSC_ANALYSIS_OPTION_PUB.Delete_Analysis_Options');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    l_Bsc_Kpi_Entity_Rec.Bsc_Kpi_Id := p_kpi_id;
    BSC_KPI_PVT.Set_Default_Option
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_Bsc_Kpi_Entity_Rec    =>  l_Bsc_Kpi_Entity_Rec
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
       --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Multi_Groups_Opts Failed: at BSC_KPI_PVT.Set_Default_Option');
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_KPI_PUB.Update_Kpi_Time_Stamp
    (       p_commit              =>  FND_API.G_FALSE
        ,   p_Bsc_Kpi_Entity_Rec  =>  l_Bsc_Kpi_Entity_Rec
        ,   x_return_status       =>  x_return_status
        ,   x_msg_count           =>  x_msg_count
        ,   x_msg_data            =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Multi_Groups_Opts Failed: at BSC_KPI_PUB.Update_Kpi_Time_Stamp');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    BSC_ANALYSIS_OPTION_PUB.Synch_Kpi_Anal_Group
    (        p_commit              =>  FND_API.G_FALSE
         ,   p_Kpi_Id              =>  p_kpi_id
         ,   p_Anal_Opt_Tbl        =>  l_Anal_Opt_Tbl
         ,   x_return_status       =>  x_return_status
         ,   x_msg_count           =>  x_msg_count
         ,   x_msg_data            =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Multi_Groups_Opts Failed: at BSC_BIS_KPI_MEAS_PUB.Synch_Kpi_Anal_Group');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

/*    SELECT COUNT (DISTINCT dataset_id) INTO l_new_count
    FROM BSC_KPI_ANALYSIS_MEASURES_B
    WHERE INDICATOR = p_kpi_id;*/

    l_new_count := get_Struct_Meas_Count(p_kpi_id);

    IF (l_count <> l_new_count) THEN
        BSC_DESIGNER_PVT.ActionFlag_Change(p_kpi_id, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
    END IF;
    BSC_DESIGNER_PVT.Deflt_RefreshKpi(p_kpi_id);

    FOR cd IN c_kpi_ids LOOP
        l_kpi_id :=  cd.indicator;
        BSC_ANALYSIS_OPTION_PUB.Synch_Kpi_Anal_Group
        (        p_commit              =>  FND_API.G_FALSE
             ,   p_Kpi_Id              =>  l_kpi_id
             ,   p_Anal_Opt_Tbl        =>  l_Anal_Opt_Tbl
             ,   x_return_status       =>  x_return_status
             ,   x_msg_count           =>  x_msg_count
             ,   x_msg_data            =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Multi_Groups_Opts Failed: at BSC_BIS_KPI_MEAS_PUB.Synch_Kpi_Anal_Group');
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        SELECT COUNT (DISTINCT dataset_id) INTO l_new_count
        FROM BSC_KPI_ANALYSIS_MEASURES_B
        WHERE INDICATOR = l_kpi_id;
        IF (l_count <> l_new_count) THEN
            BSC_DESIGNER_PVT.ActionFlag_Change(l_kpi_id, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
        END IF;
        BSC_DESIGNER_PVT.Deflt_RefreshKpi(l_kpi_id);
    END LOOP;

    BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button
    (
          p_Kpi_Id        =>  p_kpi_id
        , p_Dim_Level_Id  =>  NULL
        , x_return_status =>  x_return_status
        , x_msg_count     =>  x_msg_count
        , x_msg_data      =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        --dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Multi_Groups_Opts procedure Failed:at  BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Added for Start-to-End KPI Enhancement to maintain SHORT_NAME
    -- This API will refresh short_names for Analysis Options belonging to Start-to-End KPIs
    -- Enhancement#3540302 and Bug#3691035
    BSC_ANALYSIS_OPTION_PVT.Refresh_Short_Names
    (
            p_Commit        => FND_API.G_FALSE
          , p_Kpi_Id        => p_kpi_id
          , x_Return_Status => x_return_status
          , x_Msg_Count     => x_msg_count
          , x_Msg_Data      => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
         COMMIT;
    END IF;
     x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --dbms_output.PUT_LINE('Exiting from BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Multi_Groups_Opts procedure');
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DeleteBSCKPIMulAnaOpts;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DeleteBSCKPIMulAnaOpts;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO DeleteBSCKPIMulAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Multi_Groups_Opts ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Multi_Groups_Opts ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO DeleteBSCKPIMulAnaOpts;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Multi_Groups_Opts ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Delete_KPI_Multi_Groups_Opts ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Delete_KPI_Multi_Groups_Opts;


/*****************************************************************
Name        :- Find_Period_CircularRef
Description :- This Function will find the circular reference among the periods.
Input       :- Accepts the base period and the current period.
Ouput       :- Returns TRUE if circular reference is found else returns false.
Creator     :- Ashankar to fix the bug 3908204
/*****************************************************************/

FUNCTION Find_Period_CircularRef
(
     p_basePeriod      IN   BSC_SYS_PERIODICITIES.periodicity_id%TYPE
 ,   p_current_period  IN   BSC_SYS_PERIODICITIES.periodicity_id%TYPE

) RETURN BOOLEAN IS

l_baseperiod    BSC_SYS_PERIODICITIES.periodicity_id%TYPE;
l_count         NUMBER;
l_Source        BSC_SYS_PERIODICITIES.Source%TYPE;
l_period_values BSC_UTILITY.varchar_tabletype;
l_period_number NUMBER;
l_temp          BOOLEAN;

BEGIN

    l_baseperiod := p_basePeriod;

    IF(l_baseperiod = p_current_period) THEN
      RETURN TRUE;
    END IF;

    SELECT SOURCE
    INTO   l_Source
    FROM  BSC_SYS_PERIODICITIES
    WHERE PERIODICITY_ID =l_baseperiod;

    IF((l_Source IS NULL) OR (LENGTH(TRIM(l_Source))=0))THEN
      RETURN FALSE;
    END IF;

    BSC_UTILITY.Parse_String
    (
          p_List         => l_Source
       ,  p_Separator    => BSC_BIS_KPI_MEAS_PUB.COMMA_SEPARATOR
       ,  p_List_Data    => l_period_values
       ,  p_List_number  => l_period_number
    );

    /*
     --Enable for debug
    FOR i IN 1..l_period_number LOOP
     --dbms_output.PUT_LINE('period ['|| to_char(i) || '] value is :-' || l_period_values(i));
    END LOOP;*/

    l_temp := FALSE;
    FOR j IN 1..l_period_number LOOP
     l_temp := Find_Period_CircularRef(l_period_values(j),p_current_period);
     IF(l_temp) THEN
       EXIT;
     END IF;
    END LOOP;

    RETURN l_temp;
END Find_Period_CircularRef;

/*****************************************************************
Name        :- is_Period_Ciruclar
Description :- This is the top level API to check Circular Reference among periods.
               This API is called from VB as of now.
Input       :- Accepts the base period and the current period.
Ouput       :- Returns 'Y' if circular reference is found else returns 'N'.
Creator     :- Ashankar to fix the bug 3908204
/*****************************************************************/

FUNCTION is_Period_Circular
(
     p_basePeriod      IN   BSC_SYS_PERIODICITIES.periodicity_id%TYPE
 ,   p_current_period  IN   BSC_SYS_PERIODICITIES.periodicity_id%TYPE
) RETURN VARCHAR2 IS

l_ifCircular   BOOLEAN;

BEGIN
    l_ifCircular := BSC_BIS_KPI_MEAS_PUB.Find_Period_CircularRef
                    (
                          p_basePeriod     => p_basePeriod
                      ,   p_current_period => p_current_period
                    );
    IF(l_ifCircular) THEN
     RETURN BSC_BIS_KPI_MEAS_PUB.CIR_REF_EXISTS;
    END IF;

    RETURN  BSC_BIS_KPI_MEAS_PUB.CIR_REF_NOTEXISTS;
END is_Period_Circular;
/****************************************************************************************
   To get comma seperated dimension object shortnames for a given BIS measure shortname
****************************************************************************************/
PROCEDURE check_pmf_validveiw_for_mes
(
        p_dataset_id            IN          NUMBER
    ,   x_dimobj_name           OUT NOCOPY  VARCHAR2
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2

)IS
l_DimObj_ViewBy_Tbl     BSC_BIS_KPI_MEAS_PUB.DimObj_Viewby_Tbl_Type;
l_comma_shtnames        VARCHAR2(32000);
l_dim_sht_name          VARCHAR2(32000);
l_measure_short_name    VARCHAR2(32000);


BEGIN
  SELECT MES.SHORT_NAME
  INTO   l_measure_short_name
  FROM   BSC_SYS_MEASURES MES,
         BSC_SYS_DATASETS_B  SYS
  WHERE  MES.MEASURE_ID = SYS.MEASURE_ID1
  AND    SYS.DATASET_ID = p_dataset_id;

 --dbms_output.PUT_LINE('given measure short name is :-  '|| l_measure_short_name);

    BSC_BIS_KPI_MEAS_PUB.get_DimObj_ViewBy_Tbl(
                            p_Measure_Short_Name   =>   l_measure_short_name
                        ,   p_Region_Code          =>   null
                        ,   x_DimObj_ViewBy_Tbl    =>   l_DimObj_ViewBy_Tbl
                        ,   x_return_status        =>   x_return_status
                        ,   x_msg_count            =>   x_msg_count
                        ,   x_msg_data             =>   x_msg_data
                        );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        ----dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults Failed: at BSC_BIS_KPI_MEAS_PUB.get_DimObj_ViewBy_Tbl');
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

--dbms_output.PUT_LINE('The no of dimension objects count is = '||l_DimObj_ViewBy_Tbl.COUNT);

    FOR i IN 0..l_DimObj_ViewBy_Tbl.COUNT-1 LOOP
   /*     if (l_comma_shtnames is null) then
            l_comma_shtnames :=   l_DimObj_ViewBy_Tbl(i).p_Dim_Object_Names ;
        end if;
        l_comma_shtnames := l_comma_shtnames||','||  l_DimObj_ViewBy_Tbl(i).p_Dim_Object_Names ;*/
        --dbms_output.PUT_LINE('the i value is   :-  '||i);
        l_comma_shtnames   := l_DimObj_ViewBy_Tbl(i).p_Dim_Object_Names;

        if(instr(l_comma_shtnames,',') > 0) then
            WHILE (is_more(   p_dim_short_names   =>  l_comma_shtnames
                            , p_dim_short_name    =>  l_dim_sht_name  )
            ) LOOP
            --dbms_output.PUT_LINE('CALLING CHECK VIEW FOR :-  '||l_dim_sht_name );

            -- Dont validate if the Dimension short name is of rolling type. Bug#4290070
            IF (BIS_UTILITIES_PVT.Is_Rolling_Period_Level(l_dim_sht_name) = 0) THEN
                BSC_BIS_DIM_OBJ_PUB.Validate_PMF_Views(
                                                  p_Dim_Obj_Short_Name     =>  l_dim_sht_name
                                                , p_Dim_Obj_View_Name      =>  null
                                                , x_Return_Status          =>  x_return_status
                                                , x_Msg_Count              =>  x_msg_count
                                                , x_Msg_Data               =>  x_msg_data
                                                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                ----dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults Failed: at BSC_BIS_KPI_MEAS_PUB.get_DimObj_ViewBy_Tbl');
                   SELECT NAME
                   INTO   x_dimobj_name
                   FROM   BIS_LEVELS_VL
                   WHERE  SHORT_NAME = l_dim_sht_name;
                   RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
            --dbms_output.PUT_LINE('x_return_status   '||x_return_status);
            --dbms_output.PUT_LINE('x_msg_data    '||x_msg_data);
            end loop;
        else
            --dbms_output.PUT_LINE('CALLING CHECK VIEW FOR :-  '||l_comma_shtnames );
            -- Dont validate if the Dimension short name is of rolling type. Bug#4290070
            IF (BIS_UTILITIES_PVT.Is_Rolling_Period_Level(l_comma_shtnames) = 0) THEN
                BSC_BIS_DIM_OBJ_PUB.Validate_PMF_Views(
                                                  p_Dim_Obj_Short_Name     =>  l_comma_shtnames
                                                , p_Dim_Obj_View_Name      =>  null
                                                , x_Return_Status          =>  x_return_status
                                                , x_Msg_Count              =>  x_msg_count
                                                , x_Msg_Data               =>  x_msg_data
                                                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                ----dbms_output.PUT_LINE('BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults Failed: at BSC_BIS_KPI_MEAS_PUB.get_DimObj_ViewBy_Tbl');
                    SELECT NAME
                    INTO   x_dimobj_name
                    FROM   BIS_LEVELS_VL
                    WHERE  SHORT_NAME = l_comma_shtnames;
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
            --dbms_output.PUT_LINE('x_return_status   '||x_return_status);
            --dbms_output.PUT_LINE('x_msg_data   '|| x_msg_data);

        end if;
       ----dbms_output.PUT_LINE('FOR  DIMENISON OBJECT "'||l_comma_shtnames ||'" THE X_RETURN_STATUS IS  :- '||l_return_status ||' AND X_MSG_dATA IS :- ' || l_msg_data);

    END LOOP;


EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --dbms_output.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_KPI_MEAS_PUB.Get_PMF_Defaults ';
        END IF;
        --dbms_output.PUT_LINE('EXCEPTION IN WHEN OTHERS '||x_msg_data);
END check_pmf_validveiw_for_mes;

 /**
  * This API take the measure short name,dimension object short name
  * and required property type and returns the corresponding property
  * of the dimension object
  * p_Measure_Short_Name - Short Name of the measure
  * p_Dim_Obj_Short_Name - Short Name of the dimension object
  * @propertyType - This indicates the attribute value that is required .
  * This can take the following values
  *       1. c_VIEWBY - Checks whether viewBy is applicable or not
  *       2. c_ALL    - Checks whether all is enabled or not
  *       3. C_HIDE_DIM_OBJ - Checks whether dimension object is hidden in the parameter section or not
  * @returns 'Y' or 'N' depending on the attribute value
  */
FUNCTION Get_Dimobj_Properties
(       p_Measure_Short_Name   IN             VARCHAR2
    ,   p_Dim_Obj_Short_Name   IN             VARCHAR2
    ,   p_Property_Type        IN             VARCHAR2
) RETURN VARCHAR2 IS
    l_region_code         AK_REGIONS.REGION_CODE%TYPE;
    l_actual_data_source  BIS_INDICATORS.ACTUAL_DATA_SOURCE%TYPE;
    l_DimObj_ViewBy_Tbl   BIS_PMV_BSC_API_PUB.DimLevel_Viewby_Tbl_Type;
    l_return_status       VARCHAR2(100);
    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_dim_DimObj          VARCHAR2(100);
BEGIN
  IF (p_Measure_Short_Name IS NOT NULL AND p_Dim_Obj_Short_Name IS NOT NULL) THEN
    SELECT actual_data_source
    INTO   l_actual_data_source
    FROM   BIS_INDICATORS
    WHERE  SHORT_NAME = p_Measure_Short_Name;
    l_region_code := SUBSTR(l_actual_data_source, 0, (INSTR(l_actual_data_source,'.')-1));
    IF(l_region_code IS NOT NULL) THEN
      BIS_PMV_BSC_API_PUB.Get_Dimlevel_Viewby
      (   p_Region_Code               =>  l_Region_Code
          ,   p_Measure_Short_Name    =>  p_Measure_Short_Name
          ,   x_DimLevel_Viewby_Tbl   =>  l_DimObj_ViewBy_Tbl
          ,   x_return_status         =>  l_return_status
          ,   x_msg_count             =>  l_msg_count
          ,   x_msg_data              =>  l_msg_data
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RETURN 'N';
      END IF;

      FOR i IN 1..l_DimObj_ViewBy_Tbl.COUNT LOOP
       l_dim_DimObj := l_DimObj_ViewBy_Tbl(i).Dim_DimLevel;
       IF (l_dim_DimObj IS NOT NULL AND p_Dim_Obj_Short_Name = SUBSTR(l_dim_DimObj,INSTR(l_dim_DimObj,'+')+1)) THEN
          IF (p_Property_Type = c_VIEWBY) THEN
            RETURN l_DimObj_ViewBy_Tbl(i).Viewby_Applicable;
          ELSIF (p_Property_Type = c_ALL) THEN
            RETURN l_DimObj_ViewBy_Tbl(i).All_Applicable;
          ELSIF (p_Property_Type = C_HIDE_DIM_OBJ) THEN
            RETURN l_DimObj_ViewBy_Tbl(i).Hide_Level;
          END IF;
        END IF;
      END LOOP;
      RETURN 'N';
    END IF;
  END IF;
EXCEPTION
    WHEN OTHERS THEN
      RETURN 'N';
END Get_Dimobj_Properties;


PROCEDURE get_obj_common_dimensions_tabs (
  p_dim_short_name  IN  VARCHAR2
, p_objective_id    IN  NUMBER
, x_tab_ids         OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_objective_tabs(p_indicator NUMBER) IS
    SELECT DISTINCT tab_id
      FROM bsc_tab_indicators
      WHERE indicator = p_indicator;

  CURSOR c_common_dim(p_tab_id NUMBER, p_dim VARCHAR2) IS
    SELECT 1
      FROM bsc_sys_com_dim_levels
      WHERE tab_id = p_tab_id
      AND   dim_level_id IN ( SELECT dim_level_id
                                FROM bsc_sys_dim_levels_by_group dim_lvl, bsc_sys_dim_groups_vl dim
                                WHERE dim.short_name = p_dim
                                AND   dim.dim_group_id = dim_lvl.dim_group_id
                            );
  l_common_dim  NUMBER;
  l_tab_id      NUMBER;

BEGIN

  IF p_objective_id IS NOT NULL THEN

    FOR l_objective_tabs IN c_objective_tabs(p_objective_id) LOOP

      l_tab_id := l_objective_tabs.tab_id;

      l_common_dim := 0;
      IF c_common_dim%ISOPEN THEN
        CLOSE c_common_dim;
      END IF;
      OPEN c_common_dim(l_tab_id, p_dim_short_name);
      FETCH c_common_dim INTO l_common_dim;
      IF c_common_dim%NOTFOUND THEN
        l_common_dim := 0;
      END IF;
      CLOSE c_common_dim;

      IF l_common_dim > 0 THEN
        IF x_tab_ids IS NULL THEN
          x_tab_ids := l_tab_id;
        ELSE
          x_tab_ids := x_tab_ids || ',' || l_tab_id;
        END IF;
      END IF;

    END LOOP;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_common_dim%ISOPEN THEN
      CLOSE c_common_dim;
    END IF;
    x_tab_ids := NULL;
END get_obj_common_dimensions_tabs;


PROCEDURE get_common_dimensions_tabs (
  p_dim_short_name  IN  VARCHAR2
, p_objective_id    IN  NUMBER
, x_tab_ids         OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_shared_obj(p_indicator NUMBER) IS
    SELECT indicator
    FROM   bsc_kpis_b
    WHERE  source_indicator = p_indicator
    AND    share_flag = 2
    AND    prototype_flag <> 2;

  l_tab_ids       VARCHAR2(1000);
  l_objective_id  NUMBER;

BEGIN

  IF p_objective_id IS NOT NULL THEN

    get_obj_common_dimensions_tabs
    ( p_dim_short_name => p_dim_short_name
    , p_objective_id   => p_objective_id
    , x_tab_ids        => x_tab_ids
    );

  END IF;

  -- look for shared objectives
  FOR c_shared IN c_shared_obj(p_objective_id) LOOP

    l_objective_id := c_shared.indicator;

    get_obj_common_dimensions_tabs
    ( p_dim_short_name => p_dim_short_name
    , p_objective_id   => l_objective_id
    , x_tab_ids        => l_tab_ids
    );
    IF l_tab_ids IS NOT NULL THEN
      IF x_tab_ids IS NULL THEN
        x_tab_ids := l_tab_ids;
      ELSE
        x_tab_ids := x_tab_ids || ',' || l_tab_ids;
      END IF;
    END IF;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    x_tab_ids := NULL;
END get_common_dimensions_tabs;


END BSC_BIS_KPI_MEAS_PUB;

/
