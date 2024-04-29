--------------------------------------------------------
--  DDL for Package Body BSC_BIS_DIMENSION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIS_DIMENSION_PUB" AS
/* $Header: BSCGPMDB.pls 120.9 2007/08/02 13:39:22 psomesul ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCCPMDB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper for Dimension in PMF & Dimension Group in BSC     |
REM |             part of PMD APIs                                          |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 02-MAY-2003 PAJOHRI  Created.                                         |
REM | 17-JUL-2003 ADRAO    Bug#3054935 Changed following procedures         |
REM |                      BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet()   |
REM |                      BSC_BIS_KPI_MEAS_PUB.UnCreate_Dim_Objs_In_DSet() |
REM |                      to use 'NULL' timestamp                          |
REM | 18-JUL-2003 PAJOHRI  Bug #3053521                                     |
REM | 22-JUL-2003 ADRAO    Bug #3034094  - Fixed in Update_Dimension        |
REM | 30-JUL-2003 PAJOHRI  Bug #3075316, 3073486                            |
REM | 09-SEP-2003 ASHANKAR Bug #3129610                                     |
REM | 13-SEP-2003 MAHRAO   Fix for bug# 3099977, added p_create_view flag   |
REM | 20-OCT-2003 PAJOHRI  Bug #3179995                                     |
REM | 20-OCT-2003 PAJOHRI  Bug #3179995                                     |
REM | 04-NOV-2003 PAJOHRI  Bug #3152258                                     |
REM | 04-NOV-2003 PAJOHRI  Bug #3220613                                     |
REM | 04-NOV-2003 PAJOHRI  Bug #3232366                                     |
REM | 04-NOV-2003 PAJOHRI  Bug #3269384                                     |
REM | 08-DEC-2003 KYADAMAK Bug #3225685                                     |
REM | 02-MAR-2004 ankgoel  Bug #3464470                                     |
REM | 30-MAR-2004 KYADAMAK BUG #3516466 Passing default appid as 271        |
REM | 12-APR-2004 PAJOHRI  Bug #3426566, modified the logic to use dimension|
REM |                      'UNASSIGNED' always if there if no Dimension/    |
REM |                      Dimension Object association for PMF and retain  |
REM |                      'All Enable' flag                                |
REM | 19-APR-2004 PAJOHRI  Bug #3541933, fix for filter buttons             |
REM | 23-APR-2004 ASHANKAR  Bug #3518610,Added the fucntion Validate        |
REM |                       listbutton                                      |
REM | 05-MAY-2004 PAJOHRI  Bug #3590436, fixed Sync_Dimensions_In_Bis       |
REM | 16-JUN-2004 PAJOHRI   Bug #3659486, to support 'All Enable' flag in   |
REM |                       Dimension/Dimension Object Association Page     |
REM | 09-AUG-2004 sawu      Used c_BSC_DIM constant in create_dimension     |
REM | 11-AUG-2004 sawu     Added create_dimension() for bug#3819855 with    |
REM |                      p_is_default_short_name                          |
REM | 17-AUG-2004 wleung   modified Bug#3784852 on Assign_Unassign_Dim_Objs |
REM | 08-SEP-2004 visuri   Added Dim_With_Single_Dim_Obj() and              |
REM |                      Is_Dim_Empty() for bug #3784852                  |
REM | 09-SEP-2004 visuri   Shifted Remove_Empty_Dims_For_DimSet() from      |
REM |                      BSC_BIS_KPI_MEAS_PUB  for bug #3784852           |
REM | 08-OCT-2004 rpenneru added Modified for bug#3939995                   |
REM | 27-OCT-2004 sawu     Bug#3947903: added Is_Objective_Assigned()       |
REM | 08-Feb-05   ankgoel  Enh#4172034 DD Seeding by Product Teams          |
REM | 02-Mar-05   ppandey  Bug#4211876 Prmary Dim provided for              |
REM |                      Update_Dimension_Level should not be accepte.    |
REM | 29-Mar-05   ankagarw bug# 4218260 Unable to save comparison source    |
REM |                      label lov value                                  |
REM | 31-MAR-05   adrao     Modified API check_sametype_dims to remove      |
REM |                       disctinction betweem BSC and BIS Dimesion Objs  |
REM | 11-APR-2005 kyadamak bug#4290070 Not recreating views for rolling dims|
REM | 06-JUN-2005 mdamle   Enh#4403547 Set default p_commit to false for    |
REM |                      dim. group apis called from EOs                  |
REM |  18-Jul-2005 ppandey  Enh #4417483, Restrict Internal/Calendar Dims   |
REM |  20-Jul-2005 ppandey  Bug #4495539, MIXED Dim Obj not allowed from DD |
REM |  11-AUG-2005 ppandey  Bug #4324947 Validation for Dim,Dim Obj in Rpt  |
REM |  06-Jan-2006 akoduri  Enh#4739401 - Hide Dimensions/Dim Objects       |
REM |  10-FEB-2006 akoduri  Bug#4997042 Cascade 'All' property from dim     |
REM |                       designer to dim groups of Reports               |
REM |  15-JUN-2006 ashankar Bug#5254737 Made changes to Create_Dimension    |
REM |                       Method.Removed the parameter value 'TRUE' in    |
REM |                       FND_MESSAGE.SET_TOKEN API                       |
REM |   27-Jun-07 ashankar  Bug#6134149 synching up the dim obj props to    |
REM |                       BSC_KPI_MEASURE_PROPS table                     |
REM |  02-AUG-07 psomesul  B#6168487-Handling dim. object comparison settings |
REM +=======================================================================+
*/
CONFIG_LIMIT_DIM              CONSTANT        NUMBER := 8;
/*********************************************************************************/

TYPE KPI_Dim_Set_Type IS Record
(       p_kpi_id            BSC_KPI_DIM_SETS_TL.indicator%TYPE
    ,   p_dim_set_id        BSC_KPI_DIM_SETS_TL.dim_set_id%TYPE
    ,   p_short_name        BSC_SYS_DIM_GROUPS_TL.short_name%TYPE
);
TYPE KPI_Dim_Set_Table_Type IS TABLE OF KPI_Dim_Set_Type INDEX BY BINARY_INTEGER;
/*********************************************************************************/
TYPE Dim_Obj_Relations_Type IS Record
(
    p_dim_obj_id        BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE
);
TYPE Dim_Obj_Table_Type IS TABLE OF Dim_Obj_Relations_Type INDEX BY BINARY_INTEGER;
/*********************************************************************************/

TYPE dimobj_objective_kpis_type IS RECORD
(      p_indicator           BSC_KPIS_B.indicator%TYPE ,
       p_kpi_measure_id      BSC_DB_DATASET_DIM_SETS_V.kpi_measure_id%TYPE,
       p_short_name          BSC_SYS_DIM_LEVELS_B.short_name%TYPE
);
TYPE dimobj_obj_kpis_tbl_type IS TABLE OF dimobj_objective_kpis_type INDEX BY BINARY_INTEGER;

/*********************************************************************************/
FUNCTION Attmpt_Recr_View
(       p_dim_lvl_shrt_name             VARCHAR2
    ,   x_dim_lvl_name      OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN;
/*********************************************************************************/
FUNCTION check_sametype_dimobjs
(       p_dim_name              IN  VARCHAR2
    ,   p_dim_short_name        IN  VARCHAR2
    ,   p_dim_short_names       IN  VARCHAR2
    ,   p_Restrict_Dim_Validate IN              VARCHAR2 := NULL
    ,   x_dim_type              OUT    NOCOPY   VARCHAR2
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)RETURN BOOLEAN;

FUNCTION is_color_change_required (
   p_old_default    IN  VARCHAR2,
   p_new_default    IN  VARCHAR2,
   p_obj_id         IN  bsc_kpis_b.indicator%TYPE,
   p_kpi_measure_id IN  bsc_kpi_measure_props.kpi_measure_id%TYPE
 )
RETURN NUMBER;

FUNCTION get_kpi_flag_change (
   p_old_default        IN             VARCHAR2,
   p_new_default        IN             VARCHAR2,
   p_indicator          IN             bsc_kpis_b.indicator%TYPE,
   p_dim_obj_objs_tbl   IN  OUT NOCOPY BSC_BIS_DIMENSION_PUB.dimobj_obj_kpis_tbl_type
 )
RETURN NUMBER;

/*********************************************************************************/
PROCEDURE Restrict_Internal_Dim_Objs
(       p_dim_short_name                IN              VARCHAR2
    ,   p_assign_dim_obj_names          IN              VARCHAR2
    ,   p_unassign_dim_obj_names        IN              VARCHAR2
    ,   x_return_status                 OUT    NOCOPY   VARCHAR2
    ,   x_msg_count                     OUT    NOCOPY   NUMBER
    ,   x_msg_data                      OUT    NOCOPY   VARCHAR2
);

/*********************************************************************************/
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
/*********************************************************************************************
                         Returns the Dim_Group_ID of BIS Dimension
*********************************************************************************************/
FUNCTION Get_Bis_Dimension_ID
(  p_Short_Name  IN BIS_DIMENSIONS.Short_Name%TYPE
) RETURN NUMBER IS

    l_dim_id    BIS_DIMENSIONS.Dimension_ID%TYPE;

    CURSOR  c_Dim_Group_Id IS
    SELECT  Dimension_ID
    FROM    BIS_DIMENSIONS
    WHERE   Short_Name  = p_Short_Name;
BEGIN
    IF (c_Dim_Group_Id%ISOPEN) THEN
        CLOSE c_Dim_Group_Id;
    END IF;
    OPEN  c_Dim_Group_Id;
        FETCH  c_Dim_Group_Id  INTO l_dim_id;
    CLOSE  c_Dim_Group_Id;
    RETURN l_dim_id;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_Dim_Group_Id%ISOPEN) THEN
            CLOSE c_Dim_Group_Id;
        END IF;
        RETURN l_dim_id;
END Get_Bis_Dimension_ID;

/*********************************************************************************************
                            Returns the Dim_Group_ID of BSC Dimension
*********************************************************************************************/
FUNCTION Get_Bsc_Dimension_ID
(  p_Short_Name  IN BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE
) RETURN NUMBER IS

    l_dim_id    BSC_SYS_DIM_GROUPS_TL.Dim_Group_ID%TYPE;

    CURSOR  c_Dim_Group_Id IS
    SELECT  Dim_Group_ID
    FROM    BSC_SYS_DIM_GROUPS_VL
    WHERE   Short_Name  = p_Short_Name;
BEGIN
    IF (c_Dim_Group_Id%ISOPEN) THEN
        CLOSE c_Dim_Group_Id;
    END IF;
    OPEN  c_Dim_Group_Id;
        FETCH  c_Dim_Group_Id  INTO l_dim_id;
    CLOSE  c_Dim_Group_Id;

    RETURN l_dim_id;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_Dim_Group_Id%ISOPEN) THEN
            CLOSE c_Dim_Group_Id;
        END IF;
        RETURN l_dim_id;
END Get_Bsc_Dimension_ID;
/*********************************************************************************************
                            Checks if a Dimension is Attached to a Objective
*********************************************************************************************/
FUNCTION Is_Dimension_in_Ind
(  p_dim_group_id  IN BSC_SYS_DIM_GROUPS_TL.Dim_Group_ID%TYPE
) RETURN BOOLEAN IS

    l_return_val   BOOLEAN:= FALSE;
    l_Count NUMBER  := 0;
   BEGIN

SELECT COUNT(1) INTO l_Count
    FROM   BSC_KPI_DIM_GROUPS
    WHERE DIM_GROUP_ID= p_dim_group_id;
    IF (l_Count = 0) THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN l_return_val;
END Is_Dimension_in_Ind;
/*********************************************************************************************
                            Returns the Name of BSC Dimension
*********************************************************************************************/
FUNCTION Get_Bsc_Dimension_Name
(  p_Short_Name  IN BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE
) RETURN VARCHAR2 IS

    l_dim_name    BSC_SYS_DIM_GROUPS_TL.Name%TYPE;

    CURSOR  c_Dim_Group_Name IS
    SELECT  Name
    FROM    BSC_SYS_DIM_GROUPS_VL
    WHERE   Short_Name  = p_Short_Name;
BEGIN
    IF (c_Dim_Group_Name%ISOPEN) THEN
        CLOSE c_Dim_Group_Name;
    END IF;
    OPEN  c_Dim_Group_Name;
        FETCH  c_Dim_Group_Name  INTO l_dim_name;
    CLOSE  c_Dim_Group_Name;

    RETURN l_dim_name;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_Dim_Group_Name%ISOPEN) THEN
            CLOSE c_Dim_Group_Name;
        END IF;
        RETURN l_dim_name;
END Get_Bsc_Dimension_Name;
/*********************************************************************************************
   Function to check Dimension/Dimension Object if association exists
*********************************************************************************************/
FUNCTION is_Relation_Exists
(  p_Dim_Grp_Id    IN BSC_SYS_DIM_GROUPS_TL.Dim_Group_ID%TYPE
 , p_Dim_Level_Id  IN BSC_SYS_DIM_LEVELS_B.Dim_Level_ID%TYPE
) RETURN BOOLEAN IS
    l_flag  BOOLEAN := FALSE;
    l_Count NUMBER  := 0;
BEGIN
    SELECT COUNT(1) INTO l_Count
    FROM   BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE  Dim_Level_Id = p_Dim_Level_Id
    AND    Dim_Group_Id = p_Dim_Grp_Id;
    IF (l_Count = 0) THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN l_flag;
END is_Relation_Exists;
/*********************************************************************************
          Set the ALL Enable Flag Primary Flag
*********************************************************************************/
FUNCTION Get_Primary_All_Flag(p_Dim_Obj_Short_Name IN VARCHAR2)
RETURN NUMBER IS
    l_Bsc_Dim_Obj_ID        BSC_SYS_DIM_LEVELS_B.Dim_Level_ID%TYPE;
    l_Bsc_Group_ID          BSC_SYS_DIM_GROUPS_TL.Dim_Group_ID%TYPE;
    l_Dim_Short_Name        BIS_DIMENSIONS.Short_Name%TYPE;
    l_All_Flag              BSC_SYS_DIM_LEVELS_BY_GROUP.Total_Flag%TYPE;

    CURSOR  c_Bis_Levels IS
    SELECT  B.Short_Name
    FROM    BIS_LEVELS     A
         ,  BIS_DIMENSIONS B
    WHERE   A.Short_Name   = p_Dim_Obj_Short_Name
    AND     A.Dimension_Id = B.Dimension_Id;

    CURSOR c_All_Pri_Flag IS
    SELECT Total_Flag
    FROM   BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE  Dim_Level_Id =  l_Bsc_Dim_Obj_ID
    AND    Dim_Group_Id =  l_Bsc_Group_ID;
BEGIN
    --DBMS_OUTPUT.PUT_LINE('Entered inside BSC_BIS_DIMENSION_PUB.Get_Primary_All_Flag procedure');
    IF (c_Bis_Levels%ISOPEN) THEN
        CLOSE c_Bis_Levels;
    END IF;
    OPEN  c_Bis_Levels;
        FETCH   c_Bis_Levels
        INTO    l_Dim_Short_Name;
    CLOSE  c_Bis_Levels;

    l_Bsc_Group_ID     := BSC_BIS_DIMENSION_PUB.Get_Bsc_Dimension_ID(l_Dim_Short_Name);
    l_Bsc_Dim_Obj_ID   := BSC_BIS_DIM_OBJ_PUB.Get_Bsc_Dim_Obj_ID(p_Dim_Obj_Short_Name);

    IF (c_All_Pri_Flag%ISOPEN) THEN
        CLOSE c_All_Pri_Flag;
    END IF;
    OPEN  c_All_Pri_Flag;
        FETCH   c_All_Pri_Flag INTO l_All_Flag;
    CLOSE  c_All_Pri_Flag;
    RETURN NVL(l_All_Flag, -1);
    --DBMS_OUTPUT.PUT_LINE('Exiting from BSC_BIS_DIMENSION_PUB.Get_Primary_All_Flag procedure');
EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END Get_Primary_All_Flag;
/*********************************************************************************************
  Returns the number of dimension associated with the dimension object
*********************************************************************************************/
FUNCTION Get_Number_Of_Dimensions
(  p_Dim_Level_Id  IN BSC_SYS_DIM_LEVELS_B.Dim_Level_ID%TYPE
) RETURN NUMBER IS
    l_Count NUMBER := 0;
BEGIN
    SELECT COUNT(Dim_Group_ID) INTO l_Count
    FROM   BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE  Dim_Level_Id = p_Dim_Level_Id;
    RETURN l_Count;
EXCEPTION
    WHEN OTHERS THEN
        RETURN l_Count;
END Get_Number_Of_Dimensions;
--=========================================================================================
PROCEDURE Sync_All_Enable_Flag
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_Dim_Obj_Short_Name    IN              VARCHAR2
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    l_Bsc_Level_ID          BSC_SYS_DIM_LEVELS_B.Dim_Level_ID%TYPE;
    l_Bsc_Group_ID          BSC_SYS_DIM_GROUPS_TL.Dim_Group_ID%TYPE;
    l_Dim_Short_Name        BIS_DIMENSIONS.Short_Name%TYPE;
    l_Total_Flag            BSC_SYS_DIM_LEVELS_BY_GROUP.Total_Flag%TYPE := NULL;

    CURSOR  c_Bis_Levels IS
    SELECT  B.Short_Name
    FROM    BIS_LEVELS     A
         ,  BIS_DIMENSIONS B
    WHERE   A.Short_Name   = p_Dim_Obj_Short_Name
    AND     A.Dimension_Id = B.Dimension_Id;

    CURSOR  c_Total_Flag IS
    SELECT  Total_Flag
    FROM    BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE   Dim_Group_Id  =  l_Bsc_Group_ID
    AND     Dim_Level_Id  =  l_Bsc_Level_ID;
BEGIN
    --DBMS_OUTPUT.PUT_LINE('Entered inside BSC_BIS_DIMENSION_PUB.Sync_All_Enable_Flag procedure');
    SAVEPOINT SyncPMFAllInPMD;
    IF (BSC_BIS_DIM_OBJ_PUB.Get_Dim_Obj_Source(NULL, p_Dim_Obj_Short_Name) = 'PMF') THEN
        l_Bsc_Level_ID  :=  BSC_BIS_DIM_OBJ_PUB.Get_Bsc_Dim_Obj_ID(p_Dim_Obj_Short_Name);

        IF (c_Bis_Levels%ISOPEN) THEN
            CLOSE c_Bis_Levels;
        END IF;
        OPEN  c_Bis_Levels;
            FETCH   c_Bis_Levels
            INTO    l_Dim_Short_Name;
        CLOSE  c_Bis_Levels;

        --sync up all values
        l_Bsc_Group_ID    := BSC_BIS_DIMENSION_PUB.Get_Bsc_Dimension_ID(l_Dim_Short_Name);
        IF (c_Total_Flag%ISOPEN) THEN
            CLOSE c_Total_Flag;
        END IF;
        OPEN  c_Total_Flag;
            FETCH   c_Total_Flag INTO l_Total_Flag;
        CLOSE  c_Total_Flag;
        IF (l_Total_Flag IS NOT NULL) THEN
            UPDATE BSC_SYS_DIM_LEVELS_BY_GROUP
            SET    Total_Flag   =  l_Total_Flag
            WHERE  Dim_Level_Id =  l_Bsc_Level_ID;
        END IF;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
        --DBMS_OUTPUT.PUT_LINE('COMMIT SUCCESSFUL');
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    --DBMS_OUTPUT.PUT_LINE('Exiting from BSC_BIS_DIMENSION_PUB.Sync_All_Enable_Flag procedure');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO SyncPMFAllInPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NULL) THEN
            x_msg_data      :=  SQLERRM||' -> BSC_BIS_DIMENSION_PUB.Sync_All_Enable_Flag ';
        END IF;
        --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Sync_All_Enable_Flag;
--=========================================================================================
PROCEDURE Sync_Dimensions_In_Bis
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_Dim_Obj_Short_Name    IN              VARCHAR2
    ,   p_Sync_Flag             IN              BOOLEAN
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    l_Bsc_Level_ID              BSC_SYS_DIM_LEVELS_B.Dim_Level_ID%TYPE;
    l_Bsc_Group_ID              BSC_SYS_DIM_GROUPS_TL.Dim_Group_ID%TYPE :=  NULL;
    l_Bis_Group_ID              BIS_DIMENSIONS.Dimension_ID%TYPE;

    l_Old_Bsc_Group_ID          BSC_SYS_DIM_GROUPS_TL.Dim_Group_ID%TYPE;
    l_Old_Dim_Short_Name        BIS_DIMENSIONS.Short_Name%TYPE;

    l_Dim_Short_Name            BIS_DIMENSIONS.Short_Name%TYPE;

    l_Sync_Flag                 BOOLEAN;

    l_bis_dimension_level_rec   BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
    l_error_tbl                 BIS_UTILITIES_PUB.Error_Tbl_Type;

    l_bis_dim_level_rec         BIS_LEVELS%ROWTYPE;

    CURSOR   c_Bis_Levels IS
    SELECT   B.Short_Name
    FROM     BIS_LEVELS       A
          ,  BIS_DIMENSIONS   B
    WHERE    A.Short_Name   = p_Dim_Obj_Short_Name
    AND      A.Dimension_Id = B.Dimension_Id;

    CURSOR   c_Dim_Groups IS
    SELECT   Dim_Group_Id
    FROM     BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE    Dim_Level_Id  =  l_Bsc_Level_ID
    ORDER BY Dim_Level_Index DESC;

    CURSOR   c_Dim_Short_Name IS
    SELECT   Short_Name
    FROM     BSC_SYS_DIM_GROUPS_VL
    WHERE    Dim_Group_Id = l_Bsc_Group_ID;

    CURSOR   c_Dim_Level_Info IS
    SELECT   LEVEL_ID
           , SHORT_NAME
           , DIMENSION_ID
           , LEVEL_VALUES_VIEW_NAME
           , WHERE_CLAUSE
           , CREATION_DATE
           , CREATED_BY
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , LAST_UPDATE_LOGIN
           , SOURCE
           , COMPARISON_LABEL_CODE
           , ATTRIBUTE_CODE
           , APPLICATION_ID
           , VIEW_OBJECT_NAME
           , DEFAULT_VALUES_API
           , DEFAULT_SEARCH
           , LONG_LOV
           , MASTER_LEVEL
           , ENABLED
           , DRILL_TO_FORM_FUNCTION
           , HIDE_IN_DESIGN
    FROM     BIS_LEVELS  A
    WHERE    A.Short_Name   = p_Dim_Obj_Short_Name;
BEGIN

    SAVEPOINT SyncPMFBSCDimsInPMD;
    IF (c_Bis_Levels%ISOPEN) THEN
        CLOSE c_Bis_Levels;
    END IF;

    OPEN  c_Bis_Levels;
        FETCH   c_Bis_Levels
        INTO    l_Old_Dim_Short_Name;
    CLOSE  c_Bis_Levels;

    l_Old_Bsc_Group_ID    := BSC_BIS_DIMENSION_PUB.Get_Bsc_Dimension_ID(l_Old_Dim_Short_Name);

    l_Bsc_Level_ID        := BSC_BIS_DIM_OBJ_PUB.Get_Bsc_Dim_Obj_ID(p_Dim_Obj_Short_Name);


    l_Sync_Flag  :=   TRUE;
    IF (p_Sync_Flag) THEN
        FOR cd IN c_Dim_Groups LOOP
            l_Bsc_Group_ID  := cd.Dim_Group_Id;

            IF (l_Old_Bsc_Group_ID = l_Bsc_Group_ID) THEN
                l_Sync_Flag  := FALSE;
                EXIT;
            END IF;
        END LOOP;
    END IF;

    IF (l_Sync_Flag) THEN
        IF (l_Bsc_Group_ID IS NOT NULL) THEN
            IF (c_Dim_Short_Name%ISOPEN) THEN
                CLOSE c_Dim_Short_Name;
            END IF;
            OPEN  c_Dim_Short_Name;
                FETCH   c_Dim_Short_Name INTO l_Dim_Short_Name;
            CLOSE  c_Dim_Short_Name;
        ELSE
            l_Dim_Short_Name    :=  BSC_BIS_DIMENSION_PUB.Unassigned_Dim;
        END IF;
        l_Bis_Group_ID  := BSC_BIS_DIMENSION_PUB.Get_Bis_Dimension_ID(l_Dim_Short_Name);

        IF (c_Dim_Level_Info%ISOPEN) THEN
      CLOSE c_Dim_Level_Info;
        END IF;

        OPEN  c_Dim_Level_Info;
      FETCH   c_Dim_Level_Info
      INTO    l_bis_dim_level_rec;
        CLOSE  c_Dim_Level_Info;

        --sync bis dimension objects also
        l_bis_dimension_level_rec.Dimension_Level_ID := l_bis_dim_level_rec.level_id;
        l_bis_dimension_level_rec.Level_Values_View_Name := l_bis_dim_level_rec.Level_Values_View_Name;
        l_bis_dimension_level_rec.where_Clause := l_bis_dim_level_rec.WHERE_CLAUSE;
        l_bis_dimension_level_rec.CREATION_DATE := l_bis_dim_level_rec.CREATION_DATE;
        l_bis_dimension_level_rec.CREATED_BY := l_bis_dim_level_rec.CREATED_BY;
        l_bis_dimension_level_rec.SOURCE := l_bis_dim_level_rec.SOURCE;
        l_bis_dimension_level_rec.COMPARISON_LABEL_CODE := l_bis_dim_level_rec.COMPARISON_LABEL_CODE;
        l_bis_dimension_level_rec.ATTRIBUTE_CODE := l_bis_dim_level_rec.ATTRIBUTE_CODE;
        l_bis_dimension_level_rec.APPLICATION_ID := l_bis_dim_level_rec.APPLICATION_ID;
        l_bis_dimension_level_rec.VIEW_OBJECT_NAME := l_bis_dim_level_rec.VIEW_OBJECT_NAME;
        l_bis_dimension_level_rec.DEFAULT_VALUES_API := l_bis_dim_level_rec.DEFAULT_VALUES_API;
        l_bis_dimension_level_rec.DEFAULT_SEARCH := l_bis_dim_level_rec.DEFAULT_SEARCH;
        l_bis_dimension_level_rec.LONG_LOV := l_bis_dim_level_rec.LONG_LOV;
        l_bis_dimension_level_rec.MASTER_LEVEL := l_bis_dim_level_rec.MASTER_LEVEL;
        l_bis_dimension_level_rec.ENABLED := l_bis_dim_level_rec.ENABLED;
        l_bis_dimension_level_rec.DRILL_TO_FORM_FUNCTION := l_bis_dim_level_rec.DRILL_TO_FORM_FUNCTION;
        l_bis_dimension_level_rec.Hide := l_bis_dim_level_rec.Hide_In_Design;


        l_bis_dimension_level_rec.Dimension_Level_Short_Name  :=  p_Dim_Obj_Short_Name;
        l_bis_dimension_level_rec.Dimension_ID                :=  l_Bis_Group_ID;
        l_bis_dimension_level_rec.Dimension_Short_Name        :=  l_Dim_Short_Name;

        l_bis_dimension_level_rec.Primary_Dim := FND_API.G_TRUE;

        BIS_DIMENSION_LEVEL_PUB.Update_Dimension_Level
        (       p_api_version           =>  1.0
            ,   p_commit                =>  FND_API.G_FALSE
            ,   p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL
            ,   p_Dimension_Level_Rec   =>  l_bis_dimension_level_rec
            ,   x_return_status         =>  x_return_status
            ,   x_error_Tbl             =>  l_error_tbl
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            IF (l_error_tbl.COUNT > 0) THEN
                x_msg_data  :=  l_error_tbl(l_error_tbl.COUNT).Error_Description;
                IF(INSTR(x_msg_data, ' ')  =  0 ) THEN
                    FND_MESSAGE.SET_NAME('BIS',x_msg_data);
                    FND_MSG_PUB.ADD;
                    x_msg_data  :=  NULL;
                END IF;
                RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;

    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO SyncPMFBSCDimsInPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NULL) THEN
            x_msg_data      :=  SQLERRM||' -> BSC_BIS_DIMENSION_PUB.Sync_Dimensions_In_Bis ';
        END IF;

END Sync_Dimensions_In_Bis;
/*********************************************************************************/
PROCEDURE Delete_Dim_Objs_In_DSet
(       p_MTab_Tbl              IN              BSC_BIS_DIMENSION_PUB.KPI_Dim_Set_Table_Type
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
BEGIN
    FOR i IN 0..(p_MTab_Tbl.COUNT-1) LOOP
        BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet
        (       p_commit             =>   FND_API.G_FALSE
            ,   p_kpi_id             =>   p_MTab_Tbl(i).p_kpi_id
            ,   p_dim_set_id         =>   p_MTab_Tbl(i).p_dim_set_id
            ,   x_return_status      =>   x_return_status
            ,   x_msg_count          =>   x_msg_count
            ,   x_msg_data           =>   x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
END Delete_Dim_Objs_In_DSet;
/*********************************************************************************/
PROCEDURE Create_Dim_Objs_In_DSet
(       p_MTab_Tbl              IN              BSC_BIS_DIMENSION_PUB.KPI_Dim_Set_Table_Type
    ,   p_kpi_flag_change       IN              VARCHAR2 := NULL
    ,   p_delete                IN              BOOLEAN  := FALSE
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
BEGIN
    FOR i IN 0..(p_MTab_Tbl.COUNT-1) LOOP
        BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet
        (       p_commit             =>   FND_API.G_FALSE
            ,   p_kpi_id             =>   p_MTab_Tbl(i).p_kpi_id
            ,   p_dim_set_id         =>   p_MTab_Tbl(i).p_dim_set_id
            ,   p_kpi_flag_change    =>   p_kpi_flag_change
            ,   p_delete             =>   p_delete
            ,   x_return_status      =>   x_return_status
            ,   x_msg_count          =>   x_msg_count
            ,   x_msg_data           =>   x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
END Create_Dim_Objs_In_DSet;

/**********************************************************************************

  The following overloaded API take dimension object old default value and new default
  value and sets the prototype flag of the corresponding objectives accordingly

***********************************************************************************/

PROCEDURE Create_Dim_Objs_In_DSet
(       p_MTab_Tbl              IN              BSC_BIS_DIMENSION_PUB.KPI_Dim_Set_Table_Type
    ,   p_delete                IN              BOOLEAN  := FALSE
    ,   p_old_default           IN              VARCHAR2
    ,   p_new_default           IN              VARCHAR2
    ,   p_dim_obj_short_name    IN              VARCHAR2
    ,   p_dim_obj_objs_tbl      IN OUT NOCOPY   BSC_BIS_DIMENSION_PUB.dimobj_obj_kpis_tbl_type
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
l_kpi_flag_change      VARCHAR2(1);

BEGIN

    FOR i IN 0..(p_MTab_Tbl.COUNT-1) LOOP
        l_kpi_flag_change := NULL;

        l_kpi_flag_change := get_kpi_flag_change(
                p_old_default        => p_old_default,
                p_new_default        => p_new_default,
                p_indicator          => p_MTab_Tbl(i).p_kpi_id,
                p_dim_obj_objs_tbl   => p_dim_obj_objs_tbl
               );

        BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet
        (       p_commit             =>   FND_API.G_FALSE
            ,   p_kpi_id             =>   p_MTab_Tbl(i).p_kpi_id
            ,   p_dim_set_id         =>   p_MTab_Tbl(i).p_dim_set_id
            ,   p_kpi_flag_change    =>   l_kpi_flag_change
            ,   p_delete             =>   p_delete
            ,   x_return_status      =>   x_return_status
            ,   x_msg_count          =>   x_msg_count
            ,   x_msg_data           =>   x_msg_data
        );

        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END LOOP;
END Create_Dim_Objs_In_DSet;

/*********************************************************************************/
PROCEDURE Store_Dim_Set_Records
(   p_dim_group_id    IN             NUMBER
  , p_dim_short_name  IN             VARCHAR2
  , x_MTab_Tbl        IN OUT NOCOPY  BSC_BIS_DIMENSION_PUB.KPI_Dim_Set_Table_Type
) IS
    CURSOR   c_dim_set_kpi IS
    SELECT   DISTINCT A.indicator  INDICATOR
          ,  A.dim_set_id          DIM_SET_ID
          ,  A.Dim_Group_Index
    FROM     BSC_KPI_DIM_GROUPS A
          ,  BSC_KPIS_B         B
    WHERE    A.INDICATOR    =  B.INDICATOR
    AND      B.share_flag  <>  2
    AND      A.dim_group_id =  p_dim_group_id
    ORDER BY A.Dim_Group_Index;

    l_count   NUMBER;
BEGIN
  l_count := 0;
  FOR cd IN c_dim_set_kpi LOOP
      x_MTab_Tbl(l_count).p_kpi_id      :=  cd.Indicator;
      x_MTab_Tbl(l_count).p_dim_set_id  :=  cd.Dim_Set_Id;
      x_MTab_Tbl(l_count).p_short_name  :=  p_dim_short_name;
      l_count :=  l_count + 1;
  END LOOP;
END Store_Dim_Set_Records;
/*********************************************************************************/

PROCEDURE store_dim_obj_objectives (
      p_dim_obj_short_name  IN          VARCHAR2,
      x_dim_obj_objs_tbl    OUT NOCOPY  BSC_BIS_DIMENSION_PUB.dimobj_obj_kpis_tbl_type
) IS
  l_count   NUMBER;
  CURSOR c_dim_obj_objectives IS
     SELECT a.indicator indicator, a.kpi_measure_id
     FROM   BSC_DB_DATASET_DIM_SETS_V a, bsc_kpi_dim_levels_vl b
     WHERE  a.indicator = b.indicator
      AND   a.dim_set_id = b.dim_set_id
      AND   b.level_shortname = p_dim_obj_short_name;

BEGIN
  l_count := 0;
  FOR cd IN c_dim_obj_objectives LOOP
      x_dim_obj_objs_tbl(l_count).p_indicator       :=  cd.indicator;
      x_dim_obj_objs_tbl(l_count).p_kpi_measure_id  :=  cd.kpi_measure_id;
      x_dim_obj_objs_tbl(l_count).p_short_name      :=  p_dim_obj_short_name;
      l_count :=  l_count + 1;
  END LOOP;
END store_dim_obj_objectives;

/********************************************************************************/

FUNCTION Is_More
(       p_dim_obj_short_names   IN  OUT NOCOPY  VARCHAR2
    ,   p_dim_obj_name          OUT NOCOPY      VARCHAR2
) RETURN BOOLEAN;



/*******************************************************************************
                  FUNCTION TO CHECK IF VALID ALPHA NUMERIC CHARACTER
********************************************************************************/
FUNCTION is_Valid_AlphaNum
(
    p_SQL_Ident IN VARCHAR2
) RETURN BOOLEAN
IS
    l_SQL_Ident VARCHAR2(30);
BEGIN
    IF (p_SQL_Ident IS NULL) THEN
        RETURN FALSE;
    END IF;
    l_SQL_Ident :=  UPPER(p_SQL_Ident);
    IF (REPLACE(TRANSLATE(l_SQL_Ident, '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_',
                                       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'), 'X', '') IS NOT NULL) THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END is_Valid_AlphaNum;

/*********************************************************************************
                                CREATE DIMENSION
*********************************************************************************/
PROCEDURE Create_Dimension
(       p_commit                IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name        IN              VARCHAR2
    ,   p_display_name          IN              VARCHAR2
    ,   p_description           IN              VARCHAR2
    ,   p_dim_obj_short_names   IN              VARCHAR2
    ,   p_application_id        IN              NUMBER
    ,   p_create_view           IN              NUMBER := 0
    ,   p_hide                  IN              VARCHAR2   := FND_API.G_FALSE
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
BEGIN
    SAVEPOINT CreateBSCDimensionPMD;

    FND_MSG_PUB.INITIALIZE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Create_Dimension(
       p_commit                => p_commit
     , p_dim_short_name        => p_dim_short_name
     , p_display_name          => p_display_name
     , p_description           => p_description
     , p_dim_obj_short_names   => p_dim_obj_short_names
     , p_application_id        => p_application_id
     , p_create_view           => p_create_view
     , p_hide                  => p_hide
     , p_is_default_short_name => 'F'
     , x_return_status         => x_return_status
     , x_msg_count             => x_msg_count
     , x_msg_data              => x_msg_data
    );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCDimensionPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCDimensionPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCDimensionPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Create_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Create_Dimension ';
        END IF;

    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCDimensionPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Create_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Create_Dimension ';
        END IF;

END Create_Dimension;

PROCEDURE Create_Dimension
(       p_commit                IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name        IN              VARCHAR2
    ,   p_display_name          IN              VARCHAR2
    ,   p_description           IN              VARCHAR2
    ,   p_dim_obj_short_names   IN              VARCHAR2
    ,   p_application_id        IN              NUMBER
    ,   p_create_view           IN              NUMBER := 0
    ,   p_hide                  IN              VARCHAR2   := FND_API.G_FALSE
    ,   p_is_default_short_name IN              VARCHAR2
    ,   p_Restrict_Dim_Validate IN              VARCHAR2   := NULL
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    l_bis_dimension_rec     BIS_DIMENSION_PUB.Dimension_Rec_Type;
    l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
    l_bsc_dimension_rec     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;

    l_dim_short_name        BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
    l_application_id        BIS_DIMENSIONS.Application_Id%TYPE;
    l_count                 NUMBER;

    l_alias                 VARCHAR2(4);
    l_flag                  BOOLEAN;
    l_temp_var              BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
    -- Start Granular Locking added by Aditya
    l_Dim_Obj_Tab           BSC_BIS_LOCKS_PUB.t_numberTable;
    l_dim_obj_names         VARCHAR2(32000);

    l_dim_obj_name          BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE;
    l_index                 NUMBER := 0;
    -- End Granular Locking added by Aditya

    l_pmf_disp_name         VARCHAR2(255); -- DispName
    l_mix_type_dim          BOOLEAN;
    l_dim_type              VARCHAR2(10);

BEGIN
    SAVEPOINT CreateBSCDimensionPMD;


    FND_MSG_PUB.INITIALIZE;

    IF((p_dim_short_name IS NOT NULL) AND
       (p_is_default_short_name <> 'T')) THEN
        l_dim_short_name    :=  p_dim_short_name;
        l_application_id    :=  p_application_id;
    ELSE
        SELECT  NVL(MAX(dim_group_id) + 1, 0)
        INTO    l_count
        FROM    BSC_SYS_DIM_GROUPS_TL;
        IF (p_dim_short_name IS NULL) THEN
          l_dim_short_name    := c_BSC_DIM ||l_count;
        ELSE
          l_dim_short_name    := p_dim_short_name;
        END IF;
        l_flag              :=  TRUE;
        l_alias             :=  NULL;
        l_temp_var          :=  l_dim_short_name;
        WHILE (l_flag) LOOP
            SELECT COUNT(1) INTO l_count
            FROM (SELECT COUNT(1) rec_count
                  FROM   BSC_SYS_DIM_GROUPS_VL
                  WHERE  UPPER(Short_Name) = UPPER(l_temp_var)
                  UNION
                  SELECT COUNT(1) rec_count
                  FROM   BIS_DIMENSIONS_VL
                  WHERE  UPPER(Short_Name) = UPPER(l_temp_var))
            WHERE rec_count > 0;
            IF (l_count = 0) THEN
                l_flag              :=  FALSE;
                l_dim_short_name    :=  l_temp_var;
            END IF;
            l_alias         :=  BSC_BIS_DIMENSION_PUB.get_Next_Alias(l_alias);
            l_temp_var      :=  l_dim_short_name||l_alias;
        END LOOP;
        IF(p_application_id = -1 OR p_application_id IS NULL) THEN
            l_application_id    :=  271;
        ELSE
            l_application_id    := p_application_id;
        END IF;

    END IF;

    IF (l_dim_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SHORT_NAME'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (NOT is_Valid_AlphaNum(l_dim_short_name)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_ALPHA_NUM_REQUIRED');
        FND_MESSAGE.SET_TOKEN('VALUE',  l_dim_short_name);
        FND_MESSAGE.SET_TOKEN('NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SHORT_NAME'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_display_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DISPLAY_NAME'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (l_application_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'APPLICATION_ID'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT  COUNT(1) INTO l_count
    FROM    BSC_SYS_DIM_GROUPS_TL
    WHERE   UPPER(short_name) = UPPER(l_dim_short_name);
    IF (l_count <> 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_UNIQUE_NAME_REQUIRED');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SHORT_NAME'));
        FND_MESSAGE.SET_TOKEN('NAME_VALUE',  l_dim_short_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT  COUNT(1) INTO l_count
    FROM    BIS_DIMENSIONS_VL
    WHERE   UPPER(short_name) = UPPER(l_dim_short_name);
    IF (l_count <> 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_UNIQUE_NAME_REQUIRED');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SHORT_NAME'));
        FND_MESSAGE.SET_TOKEN('NAME_VALUE', l_dim_short_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    l_mix_type_dim := FALSE;
    IF(p_dim_obj_short_names IS NOT NULL) THEN
        l_mix_type_dim := check_sametype_dimobjs
                          (     p_dim_name              =>  p_display_name
                            ,   p_dim_short_name        =>  p_dim_short_name
                            ,   p_dim_short_names       =>  p_dim_obj_short_names
                            ,   p_Restrict_Dim_Validate =>  p_Restrict_Dim_Validate
                            ,   x_dim_type              =>  l_dim_type
                            ,   x_return_status         =>  x_return_status
                            ,   x_msg_count             =>  x_msg_count
                            ,   x_msg_data              =>  x_msg_data
                          );
        IF (l_mix_type_dim) THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    l_pmf_disp_name := p_display_name;

    -- Enh#4172034: Validations
    IF ((l_dim_type IS NULL) OR (l_dim_type = 'BSC')) THEN

      SELECT  COUNT(1) INTO l_count
        FROM    BIS_DIMENSIONS_VL
        WHERE   UPPER(name)  = UPPER(p_display_name);

      WHILE(l_count > 0) LOOP
        l_pmf_disp_name := bsc_utility.get_Next_DispName(l_pmf_disp_name);

        SELECT  COUNT(1) INTO l_count
        FROM    BIS_DIMENSIONS_VL
        WHERE   UPPER(name)       = UPPER(l_pmf_disp_name);

      END LOOP;

    ELSE

      SELECT  COUNT(1) INTO l_count
        FROM    BSC_SYS_DIM_GROUPS_VL
        WHERE   UPPER(name) = UPPER(p_display_name);
      IF (l_count <> 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_UNIQUE_NAME_REQUIRED');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DISPLAY_NAME'));
        FND_MESSAGE.SET_TOKEN('NAME_VALUE', p_display_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      SELECT  COUNT(1) INTO l_count
        FROM    BIS_DIMENSIONS_VL
        WHERE   UPPER(name) = UPPER(p_display_name);
      IF (l_count <> 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_UNIQUE_NAME_REQUIRED');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DISPLAY_NAME'));
        FND_MESSAGE.SET_TOKEN('NAME_VALUE', p_display_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

    --assign values to bsc records
    --l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id          :=  BSC_DIMENSION_LEVELS_PVT.Get_Next_Value( 'BSC_SYS_DIM_GROUPS_TL', 'DIM_GROUP_ID');
    l_bsc_dimension_rec.Bsc_Dim_Level_Group_Name        :=  p_display_name;
    l_bsc_dimension_rec.Bsc_Dim_Level_Group_short_name  :=  l_dim_short_name;
    l_bsc_dimension_rec.Bsc_Dim_Level_Index             :=   1;
    l_bsc_dimension_rec.Bsc_Group_Level_Comp_Flag       :=  -1;
    l_bsc_dimension_rec.Bsc_Group_Level_Default_Value   :=  'T';
    l_bsc_dimension_rec.Bsc_Group_Level_Default_Type    :=   0;
    l_bsc_dimension_rec.Bsc_Group_Level_Filter_Col      :=  NULL;
    l_bsc_dimension_rec.Bsc_Group_Level_Filter_Value    :=   0;
    l_bsc_dimension_rec.Bsc_Group_Level_No_Items        :=   0;
    l_bsc_dimension_rec.Bsc_Group_Level_Parent_In_Tot   :=   2;
    l_bsc_dimension_rec.Bsc_Group_Level_Total_Flag      :=  -1;
    l_bsc_dimension_rec.Bsc_Language                    :=  NULL;
    l_bsc_dimension_rec.Bsc_Level_Id                    :=  NULL;
    l_bsc_dimension_rec.Bsc_Source_Language             :=  NULL;
    -- Start Granular Locking
    l_dim_obj_names :=  p_dim_obj_short_names;
    IF (p_dim_obj_short_names IS NOT NULL) THEN
        l_dim_obj_names   :=  p_dim_obj_short_names ;
        WHILE (is_more(     p_dim_obj_short_names   =>  l_dim_obj_names
                        ,   p_dim_obj_name          =>  l_dim_obj_name)
        ) LOOP
            l_Dim_Obj_Tab(l_index) := NVL(BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(l_dim_obj_name), -1);
            l_index := l_index + 1;
        END LOOP;
        -- Lock all the Dimension Objects to be assigned to the Dimension
        BSC_BIS_LOCKS_PUB.Lock_Create_Dimension
        (    p_selected_dim_objets   =>  l_Dim_Obj_Tab
          ,  x_return_status         =>  x_return_status
          ,  x_msg_count             =>  x_msg_count
          ,  x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- End Granular Locking
    BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_Dim_Grp_Rec           =>  l_bsc_dimension_rec
        ,   p_create_Dim_Levels     =>  FALSE
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --assign values to bis records -This is not required
    SELECT  dim_group_id
    INTO    l_bis_dimension_rec.Dim_Grp_Id
    FROM    BSC_SYS_DIM_GROUPS_VL
    WHERE   Short_Name = l_bsc_dimension_rec.Bsc_Dim_Level_Group_short_name;

    l_bis_dimension_rec.Dimension_Short_Name            :=  l_dim_short_name;
    l_bis_dimension_rec.Dimension_Name                  :=  l_pmf_disp_name;
    l_bis_dimension_rec.Description                     :=  p_description;
    l_bis_dimension_rec.Application_ID                  :=  l_application_id;
    l_bis_dimension_rec.Hide                            :=  p_hide;
    BIS_DIMENSION_PUB.Create_Dimension
    (       p_api_version       =>  1.0
        ,   p_commit            =>  FND_API.G_FALSE
        ,   p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL
        ,   p_Dimension_Rec     =>  l_bis_dimension_rec
        ,   x_return_status     =>  x_return_status
        ,   x_error_Tbl         =>  l_error_tbl
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        IF (l_error_tbl.COUNT > 0) THEN
            x_msg_data  :=  l_error_tbl(l_error_tbl.COUNT).Error_Description;
            IF(INSTR(x_msg_data, ' ')  =  0 ) THEN
                FND_MESSAGE.SET_NAME('BIS',x_msg_data);
                FND_MSG_PUB.ADD;
                x_msg_data  :=  NULL;
            END IF;
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF;
    IF (p_dim_obj_short_names IS NOT NULL) THEN
        BSC_BIS_DIMENSION_PUB.Assign_Dimension_Objects
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_dim_short_name        =>  l_dim_short_name
            ,   p_dim_obj_short_names   =>  p_dim_obj_short_names
            ,   p_create_view           =>  p_create_view
            ,   p_Restrict_Dim_Validate =>  p_Restrict_Dim_Validate
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;

    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCDimensionPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCDimensionPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCDimensionPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Create_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Create_Dimension ';
        END IF;

    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCDimensionPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Create_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Create_Dimension ';
        END IF;

END Create_Dimension;
/*********************************************************************************
                          ASSIGN DIMENSION OBJECTS TO DIMENSION
*********************************************************************************/
PROCEDURE Assign_Dimension_Objects
(       p_commit                IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name        IN              VARCHAR2
    ,   p_dim_obj_short_names   IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2    :=   NULL    -- Granular Locking
    ,   p_create_view           IN              NUMBER      := 0
    ,   p_Restrict_Dim_Validate IN              VARCHAR2   := NULL
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    l_dim_obj_names             VARCHAR2(32000);
    l_dim_obj_name              BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE;
    l_Source_Type               BSC_SYS_DIM_LEVELS_B.Source%TYPE;
    l_All_Flag                  BSC_SYS_DIM_LEVELS_BY_GROUP.Total_Flag%TYPE;

    l_assigns                   VARCHAR2(32000);
    l_assign                    BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE;
    l_MTab_Tbl                  BSC_BIS_DIMENSION_PUB.KPI_Dim_Set_Table_Type;
    l_MTab_DimRels1             BSC_BIS_DIMENSION_PUB.Dim_Obj_Table_Type;
    l_MTab_DimRels2             BSC_BIS_DIMENSION_PUB.Dim_Obj_Table_Type;

    l_dim_group_id              BSC_SYS_DIM_GROUPS_VL.Dim_Group_Id%TYPE;
    l_count                     NUMBER;
    l_count1                    NUMBER;
    l_flag                      BOOLEAN;
    l_bsc_dimension_rec         BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
    l_dim_level_id              BSC_SYS_DIM_LEVELS_B.Dim_Level_ID%TYPE;

    l_tab_index                 NUMBER;
    l_original_tab_index        NUMBER;
    l_struct_change             BOOLEAN := FALSE;

    CURSOR   c_dim_obj_index IS
    SELECT   B.Short_Name
          ,  B.Dim_Level_ID
    FROM     BSC_SYS_DIM_LEVELS_B        B
          ,  BSC_SYS_DIM_LEVELS_BY_GROUP A
    WHERE    A.dim_group_id =
             (  SELECT dim_group_id
                FROM   BSC_SYS_DIM_GROUPS_VL
                WHERE  Short_Name  = p_dim_short_name
             )
    AND      A.Dim_Level_Id = B.Dim_Level_Id
    ORDER BY A.Dim_Level_Index;

    CURSOR  cr_bsc_dim_id IS
    SELECT  dim_group_id
    FROM    BSC_SYS_DIM_GROUPS_VL
    WHERE   short_name     = p_dim_short_name;

    CURSOR  cr_bsc_dim_obj_id IS
    SELECT  Dim_Level_Id
          , Source
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   Short_Name     = l_dim_obj_name;
BEGIN

    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_dim_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_dim_obj_short_names IS NOT NULL) THEN
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        OPEN    cr_bsc_dim_id;
            FETCH   cr_bsc_dim_id
            INTO    l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id;
        CLOSE cr_bsc_dim_id;
        IF (l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id IS NULL) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
            FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'EDW_DIMENSION'), TRUE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (p_Restrict_Dim_Validate IS NOT NULL) THEN
          Restrict_Internal_Dim_Objs
          (       p_dim_short_name                => p_dim_short_name
              ,   p_assign_dim_obj_names          => p_dim_obj_short_names
              ,   p_unassign_dim_obj_names        => NULL
              ,   x_return_status                 => x_return_status
              ,   x_msg_count                     => x_msg_count
              ,   x_msg_data                      => x_msg_data
          );
        END IF;
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        BSC_BIS_DIMENSION_PUB.Store_Dim_Set_Records
        (       p_dim_group_id      =>  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
            ,   p_dim_short_name    =>  p_dim_short_name
            ,   x_MTab_Tbl          =>  l_MTab_Tbl
        );
        BSC_BIS_DIMENSION_PUB.Delete_Dim_Objs_In_DSet
        (       p_MTab_Tbl          =>  l_MTab_Tbl
            ,   x_return_status     =>  x_return_status
            ,   x_msg_count         =>  x_msg_count
            ,   x_msg_data          =>  x_msg_data
        );
        l_dim_obj_names      :=  p_dim_obj_short_names;
        WHILE (is_more(p_dim_obj_short_names   =>  l_dim_obj_names
                   ,   p_dim_obj_name          =>  l_dim_obj_name)
        ) LOOP
            IF (cr_bsc_dim_obj_id%ISOPEN) THEN
                CLOSE cr_bsc_dim_obj_id;
            END IF;
            OPEN    cr_bsc_dim_obj_id;
                FETCH   cr_bsc_dim_obj_id
                INTO    l_dim_level_id
                     ,  l_Source_Type;
            CLOSE cr_bsc_dim_obj_id;
            IF (l_dim_level_id IS NULL) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
                FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIMENSION_OBJECT'), TRUE);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (NOT BSC_BIS_DIMENSION_PUB.is_Relation_Exists(l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id, l_dim_level_id)) THEN
                l_struct_change  := TRUE;

                IF (l_Source_Type = 'BSC') THEN
                    l_All_Flag  :=  -1;

                ELSE
                    l_All_Flag  :=  BSC_BIS_DIMENSION_PUB.Get_Primary_All_Flag(l_dim_obj_name);

                END IF;
                BSC_BIS_DIMENSION_PUB.Assign_Dimension_Object
                (       p_commit                =>  FND_API.G_FALSE
                    ,   p_dim_short_name        =>  p_dim_short_name
                    ,   p_dim_obj_short_name    =>  l_dim_obj_name
                    ,   p_comp_flag             => -111 -- this value is acting like a flag
                    ,   p_no_items              =>  0
                    ,   p_parent_in_tot         =>  2
                    ,   p_total_flag            =>  l_All_Flag
                    ,   p_default_value         => 'T'
                    ,   p_time_stamp            =>  p_time_stamp     -- Granular Locking
                    ,   p_create_view           =>  p_create_view
                    ,   x_return_status         =>  x_return_status
                    ,   x_msg_count             =>  x_msg_count
                    ,   x_msg_data              =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END LOOP;
        --ordering logic of dimension level indexes starts here
        l_dim_group_id  :=  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id;
        l_count         :=  0;
        FOR cd IN c_dim_obj_index LOOP
            l_flag    :=  TRUE;
            l_assigns :=  p_dim_obj_short_names;
            l_count1  := 0;
            WHILE (is_more(     p_dim_obj_short_names   =>  l_assigns
                            ,   p_dim_obj_name          =>  l_assign)
            ) LOOP
                IF(cd.Short_Name = l_assign) THEN
                    l_flag  :=  FALSE;
                    l_MTab_DimRels2(l_count1).p_dim_obj_id  :=  cd.Dim_Level_ID;
                    EXIT;
                END IF;
                l_count1  :=  l_count1 + 1;
            END LOOP;
            IF(l_flag) THEN
                l_MTab_DimRels1(l_count).p_dim_obj_id     :=  cd.Dim_Level_ID;
                l_count  :=  l_count + 1;
            END IF;
        END LOOP;
        l_count :=  0;
        FOR i IN 0..(l_MTab_DimRels1.COUNT-1) LOOP
            SELECT Dim_Level_Index INTO l_original_tab_index
            FROM   BSC_SYS_DIM_LEVELS_BY_GROUP
            WHERE  Dim_Group_Id = l_dim_group_id
            AND    Dim_Level_ID = l_MTab_DimRels1(i).p_dim_obj_id;

            IF (l_original_tab_index <> l_count) THEN
                l_bsc_dimension_rec.Bsc_Dim_Level_Index     :=  l_count;
                l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id  :=  l_dim_group_id;
                l_bsc_dimension_rec.Bsc_Level_Id            :=  l_MTab_DimRels1(i).p_dim_obj_id;

                BSC_DIMENSION_GROUPS_PUB.Update_Dim_Levels_In_Group
                (       p_commit                =>  FND_API.G_FALSE
                    ,   p_Dim_Grp_Rec           =>  l_bsc_dimension_rec
                    ,   x_return_status         =>  x_return_status
                    ,   x_msg_count             =>  x_msg_count
                    ,   x_msg_data              =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
            l_count :=  l_count + 1;
        END LOOP;
        l_count1        :=  l_MTab_DimRels2.COUNT -1;
        l_tab_index     :=  0;
        WHILE (l_tab_index <= l_count1) LOOP
            IF (l_MTab_DimRels2.EXISTS(l_tab_index)) THEN
                SELECT Dim_Level_Index
                INTO   l_original_tab_index
                FROM   BSC_SYS_DIM_LEVELS_BY_GROUP
                WHERE  Dim_Group_Id = l_dim_group_id
                AND    Dim_Level_ID = l_MTab_DimRels2(l_tab_index).p_dim_obj_id;
                IF (l_original_tab_index <> l_count) THEN
                    l_bsc_dimension_rec.Bsc_Dim_Level_Index     :=  l_count;
                    l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id  :=  l_dim_group_id;
                    l_bsc_dimension_rec.Bsc_Level_Id            :=  l_MTab_DimRels2(l_tab_index).p_dim_obj_id;
                    l_struct_change                             :=  TRUE;

                    BSC_DIMENSION_GROUPS_PUB.Update_Dim_Levels_In_Group
                    (       p_commit                =>  FND_API.G_FALSE
                        ,   p_Dim_Grp_Rec           =>  l_bsc_dimension_rec
                        ,   x_return_status         =>  x_return_status
                        ,   x_msg_count             =>  x_msg_count
                        ,   x_msg_data              =>  x_msg_data
                    );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END IF;
                l_count :=  l_count + 1;
            END IF;
            l_tab_index := l_tab_index + 1;
        END LOOP;
        IF (l_struct_change) THEN
            BSC_BIS_DIMENSION_PUB.Create_Dim_Objs_In_DSet
            (    p_MTab_Tbl              =>  l_MTab_Tbl
              ,  x_return_status         =>  x_return_status
              ,  x_msg_count             =>  x_msg_count
              ,  x_msg_data              =>  x_msg_data
            );
        ELSE
            BSC_BIS_DIMENSION_PUB.Create_Dim_Objs_In_DSet
            (    p_MTab_Tbl              =>  l_MTab_Tbl
              ,  p_kpi_flag_change       =>  BSC_DESIGNER_PVT.G_ActionFlag.Normal
              ,  x_return_status         =>  x_return_status
              ,  x_msg_count             =>  x_msg_count
              ,  x_msg_data              =>  x_msg_data
            );
        END IF;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;

    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

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

    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Assign_Dimension_Objects ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Assign_Dimension_Objects ';
        END IF;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Assign_Dimension_Objects ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Assign_Dimension_Objects ';
        END IF;

END Assign_Dimension_Objects;
/*********************************************************************************
                      ASSIGN OR UPDATE A DIMENSION OBJECT TO DIMENSION
*********************************************************************************/
PROCEDURE Assign_Dimension_Object
(       p_commit                IN              VARCHAR2  := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name        IN              VARCHAR2
    ,   p_dim_obj_short_name    IN              VARCHAR2
    ,   p_comp_flag             IN              NUMBER
    ,   p_no_items              IN              NUMBER
    ,   p_parent_in_tot         IN              NUMBER
    ,   p_total_flag            IN              NUMBER
    ,   p_default_value         IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2  :=   NULL    -- Granular Locking
    ,   p_create_view           IN              NUMBER    :=   0
    ,   p_where_clause          IN              VARCHAR2  :=   NULL
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    l_Dim_Grp_Id                BSC_SYS_DIM_GROUPS_TL.Dim_Group_Id%TYPE;
    l_dim_lvl_name              VARCHAR2(400);
    l_default                   VARCHAR2(3);
    l_MTab_Tbl                  BSC_BIS_DIMENSION_PUB.KPI_Dim_Set_Table_Type;
    l_dim_obj_objs_tbl          BSC_BIS_DIMENSION_PUB.dimobj_obj_kpis_tbl_type;
    l_bsc_dimension_rec         BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
    l_count                     NUMBER;
    l_comp_count                NUMBER;

    l_valid_Assign              BOOLEAN := FALSE;
    l_do_not_cascade            BOOLEAN := TRUE;

    l_dim_obj_sht_name          BSC_SYS_DIM_LEVELS_VL.Short_Name%TYPE;
    l_Dim_Obj_Source            BSC_SYS_DIM_LEVELS_B.Source%TYPE;
    l_Dim_Obj_Name              BSC_SYS_DIM_LEVELS_TL.Name%TYPE;
    l_Rolling_Period            NUMBER;

    CURSOR cr_bsc_dim_obj_id IS
    SELECT dim_level_id   FROM BSC_SYS_DIM_LEVELS_B
    WHERE  short_name     = p_dim_obj_short_name;

    CURSOR cr_bsc_dim_id IS
    SELECT dim_group_id   FROM BSC_SYS_DIM_GROUPS_VL
    WHERE  short_name     = p_dim_short_name;

    /* Fix for the bug  3129610 */
    CURSOR  cr_bsc_dim_obj_count IS
    SELECT  B.Default_Value
          , C.Short_Name
          , C.Source
          , C.Name
    FROM    BSC_SYS_DIM_LEVELS_BY_GROUP B,
            BSC_SYS_DIM_GROUPS_VL       V,
            BSC_SYS_DIM_LEVELS_VL       C
    WHERE   V.Dim_Group_Id  =   B.Dim_Group_Id
    AND     B.Dim_Level_Id  =   C.Dim_Level_Id
    AND     V.Short_Name    =   p_Dim_Short_Name;

    CURSOR c_Defaut_Value IS
    SELECT Default_Value
    FROM   BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE  Dim_Group_Id =  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id;

    l_kpi_measure_props_rec  BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec;

    CURSOR c_kpi_meas_props IS
    SELECT a.indicator,
           a.kpi_measure_id
    FROM   bsc_db_dataset_dim_sets_v a,
           bsc_kpi_dim_levels_vl b
    WHERE  a.indicator =b.indicator
    AND    a.dim_set_id =b.dim_set_id
    AND    b.level_shortname =p_dim_obj_short_name;

BEGIN
    SAVEPOINT AssBSCDimObjectPMD;

    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_dim_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (cr_bsc_dim_id%ISOPEN) THEN
        CLOSE cr_bsc_dim_id;
    END IF;
    OPEN    cr_bsc_dim_id;
        FETCH   cr_bsc_dim_id
        INTO    l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id;
    CLOSE cr_bsc_dim_id;
    IF (l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'EDW_DIMENSION'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Check if the number of dimension objects within the dimension are greater than 1.
    -- if it is one it means that it is the current dimension object which we are trying to update.
    -- if the count is greater than 1 then do validate that if any of the dimension objects with in the
    -- dimension have default_value set to 'C'. ie. compariosn mode. if yes than throw the exception
    -- that in a dimension there cannot be more than one dimension object with comparison as the
    -- default value
    SELECT  COUNT(B.DEFAULT_VALUE)
    INTO    l_count
    FROM    BSC_SYS_DIM_LEVELS_BY_GROUP B
    WHERE   B.DIM_GROUP_ID = l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id;

    IF (l_count > 1) THEN
        l_comp_count := 0;
        FOR cd IN cr_bsc_dim_obj_count LOOP
            l_default           :=  cd.Default_Value;
            l_dim_obj_sht_name  :=  cd.Short_Name;
            l_Dim_Obj_Source    :=  cd.Source;
            IF ((l_default = 'C') AND (l_dim_obj_sht_name <> p_dim_obj_short_name)) THEN
                l_Dim_Obj_Name   :=  cd.Name;
                l_comp_count     :=  l_comp_count + 1;
                EXIT;
            END IF;
        END LOOP;
        IF ((l_comp_count > 0) AND (p_default_value = 'C')) THEN
            IF (l_Dim_Obj_Source = 'PMF') THEN
                FND_MESSAGE.SET_NAME('BIS', 'BIS_ONE_RNKLVL_IN_DIMGRP');
                FND_MESSAGE.SET_TOKEN('BIS_DIM_OBJ', l_Dim_Obj_Name, TRUE);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            ELSIF (l_Dim_Obj_Source = 'BSC') THEN
                FND_MESSAGE.SET_NAME('BSC', 'BSC_D_ONE_DIM_IN_COMPARISON');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;
    END IF;

     ----DEBUG('1..'||get_default_value());


    l_bsc_dimension_rec.Bsc_Dim_Level_Index                 :=  1;
    IF ((p_comp_flag IS NULL) OR ((p_comp_flag <> 0) AND (p_comp_flag <> -1)))  THEN
        l_bsc_dimension_rec.Bsc_Group_Level_Comp_Flag       := -1;
    ELSE
        l_bsc_dimension_rec.Bsc_Group_Level_Comp_Flag       :=  p_comp_flag;
    END IF;

    IF ((p_default_value IS NULL) OR ((p_default_value <> 'C') AND (p_default_value <> 'T'))) THEN
        l_bsc_dimension_rec.Bsc_Group_Level_Default_Value   := 'T';
    ELSE
        l_bsc_dimension_rec.Bsc_Group_Level_Default_Value   :=  p_default_value;
    END IF;

    l_bsc_dimension_rec.Bsc_Group_Level_Default_Type        :=  0;
    l_bsc_dimension_rec.Bsc_Group_Level_Filter_Col          :=  NULL;
    l_bsc_dimension_rec.Bsc_Group_Level_Filter_Value        :=  0;
    l_bsc_dimension_rec.Bsc_Group_Level_Where_Clause        :=  p_where_clause;
    IF ((p_no_items IS NULL) OR ((p_no_items <> 0) AND (p_no_items <> 1))) THEN
        l_bsc_dimension_rec.Bsc_Group_Level_No_Items        :=  0;
    ELSE
        l_bsc_dimension_rec.Bsc_Group_Level_No_Items        :=  p_no_items;
    END IF;

    IF ((p_parent_in_tot IS NULL) OR (p_parent_in_tot < 0) OR (p_parent_in_tot > 2)) THEN
        l_bsc_dimension_rec.Bsc_Group_Level_Parent_In_Tot   := 2;
    ELSE
        l_bsc_dimension_rec.Bsc_Group_Level_Parent_In_Tot   :=  p_parent_in_tot;
    END IF;

    IF ((p_total_flag IS NULL) OR ((p_total_flag <> 0) AND (p_total_flag <> -1)))  THEN
        l_bsc_dimension_rec.Bsc_Group_Level_Total_Flag      := -1;
    ELSE
        l_bsc_dimension_rec.Bsc_Group_Level_Total_Flag      :=  p_total_flag;     -- BSC_SYS_DIM_LEVELS_BY_GROUP.TOTAL_FLAG, true
    END IF;
    IF (p_dim_obj_short_name IS NOT NULL) THEN
        IF (cr_bsc_dim_obj_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_obj_id;
        END IF;
        OPEN    cr_bsc_dim_obj_id;
            FETCH   cr_bsc_dim_obj_id
            INTO    l_bsc_dimension_rec.Bsc_Level_Id;
        CLOSE cr_bsc_dim_obj_id;

        IF (l_bsc_dimension_rec.Bsc_Level_Id IS NULL) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
            FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIMENSION_OBJECT'), TRUE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Can test with 'LEGAL ENTITY', 'EDW_HR_PERM_SPSR1_L9'
        l_Rolling_Period := BIS_UTILITIES_PVT.Is_Rolling_Period_Level(p_dim_obj_short_name);
        IF (p_create_view = 1 AND l_Rolling_Period = 0) THEN
            IF NOT (BSC_BIS_DIMENSION_PUB.Attmpt_Recr_View(
                        p_dim_lvl_shrt_name => p_dim_obj_short_name
                    ,   x_dim_lvl_name      => l_dim_lvl_name)) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_UNAVAILABLE_LEVEL');
                FND_MESSAGE.SET_TOKEN('BSC_LEVEL', l_dim_lvl_name, TRUE);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;

        BSC_BIS_LOCKS_PUB.Lock_Update_Dim_Obj_In_Dim
        (     p_dim_object_id         =>  l_bsc_dimension_rec.Bsc_Level_Id
           ,  p_dimension_id          =>  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
           ,  p_time_stamp            =>  p_time_stamp     -- Granular Locking
           ,  x_return_status         =>  x_return_status
           ,  x_msg_count             =>  x_msg_count
           ,  x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN

             RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        ----DEBUG('2..'||get_default_value());
        -- END Granular Locking added by Aditya
        IF (p_comp_flag IS NOT NULL) AND (p_comp_flag = -111) THEN
            l_do_not_cascade    := FALSE;
        END IF;
        IF (l_do_not_cascade) THEN
            BSC_BIS_DIMENSION_PUB.Store_Dim_Set_Records
            (   p_dim_group_id    =>  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
              , p_dim_short_name  =>  p_dim_short_name
              , x_MTab_Tbl        =>  l_MTab_Tbl
            );

            store_dim_obj_objectives
            (    p_dim_obj_short_name  => p_dim_obj_short_name
              ,  x_dim_obj_objs_tbl    => l_dim_obj_objs_tbl
            );
            BSC_BIS_DIMENSION_PUB.Delete_Dim_Objs_In_DSet
            (       p_MTab_Tbl          =>  l_MTab_Tbl
                ,   x_return_status     =>  x_return_status
                ,   x_msg_count         =>  x_msg_count
                ,   x_msg_data          =>  x_msg_data
            );
        END IF;
        IF (BSC_BIS_DIMENSION_PUB.is_Relation_Exists
              (l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id, l_bsc_dimension_rec.Bsc_Level_Id)) THEN
            l_bsc_dimension_rec.Bsc_Dim_Level_Index := NULL;

            -- START Added by Aditya for Incremental Changes
            -- Create a Dynamic SQL to extract the current state of the Default values
            IF (c_Defaut_Value%ISOPEN) THEN
                CLOSE c_Defaut_Value;
            END IF;
            OPEN    c_Defaut_Value;
                FETCH   c_Defaut_Value
                INTO    l_default;
            CLOSE c_Defaut_Value;
            -- END  Added by Aditya for Incremental Changes
            BSC_DIMENSION_GROUPS_PUB.Update_Dim_Levels_In_Group
            (       p_commit                =>  FND_API.G_FALSE
                ,   p_Dim_Grp_Rec           =>  l_bsc_dimension_rec
                ,   x_return_status         =>  x_return_status
                ,   x_msg_count             =>  x_msg_count
                ,   x_msg_data              =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            ------DEBUG('3..'||get_default_value());
            IF (l_do_not_cascade) THEN
                    Create_Dim_Objs_In_DSet
                      (    p_MTab_Tbl         =>     l_MTab_Tbl
                       ,   p_old_default      =>     l_default
                       ,   p_new_default      =>     p_default_value
                       ,   p_dim_obj_short_name =>   p_dim_obj_short_name
                       ,   p_dim_obj_objs_tbl  =>    l_dim_obj_objs_tbl
                       ,   x_return_status    =>     x_return_status
                       ,   x_msg_count        =>     x_msg_count
                       ,   x_msg_data         =>     x_msg_data
                       );
                /*IF (p_default_value <> l_default) THEN
                    BSC_BIS_DIMENSION_PUB.Create_Dim_Objs_In_DSet
                    (       p_MTab_Tbl          =>  l_MTab_Tbl
                        ,   p_kpi_flag_change   =>  BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color
                        ,   x_return_status     =>  x_return_status
                        ,   x_msg_count         =>  x_msg_count
                        ,   x_msg_data          =>  x_msg_data
                    );

                    ----DEBUG('4..'||get_default_value());
                ELSE
                    BSC_BIS_DIMENSION_PUB.Create_Dim_Objs_In_DSet
                    (       p_MTab_Tbl          =>  l_MTab_Tbl
                        ,   p_kpi_flag_change   =>  BSC_DESIGNER_PVT.G_ActionFlag.Normal
                        ,   x_return_status     =>  x_return_status
                        ,   x_msg_count         =>  x_msg_count
                        ,   x_msg_data          =>  x_msg_data
                    );
                    ----DEBUG('5..'||get_default_value());
                END IF;*/
            END IF;
        ELSE
            --if Dimension is already assigned to "UNASSIGNED" Dimension
            l_Dim_Grp_Id    := BSC_BIS_DIMENSION_PUB.Get_Bsc_Dimension_ID(BSC_BIS_DIMENSION_PUB.Unassigned_Dim);
            IF (BSC_BIS_DIMENSION_PUB.is_Relation_Exists(l_Dim_Grp_Id, l_bsc_dimension_rec.Bsc_Level_Id)) THEN

                UPDATE BSC_SYS_DIM_LEVELS_BY_GROUP
                SET    Dim_Group_ID  =  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
                WHERE  Dim_Level_ID  =  l_bsc_dimension_rec.Bsc_Level_Id
                AND    Dim_Group_ID  =  l_Dim_Grp_Id;
            ELSE
                -- END - Added by Aditya for Incremental Changes
                BSC_DIMENSION_GROUPS_PUB.Create_Dim_Levels_In_Group
                (       p_commit                =>  FND_API.G_FALSE
                    ,   p_Dim_Grp_Rec           =>  l_bsc_dimension_rec
                    ,   x_return_status         =>  x_return_status
                    ,   x_msg_count             =>  x_msg_count
                    ,   x_msg_data              =>  x_msg_data
                );

                ----DEBUG('7..'||get_default_value());
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                IF (l_do_not_cascade) THEN
                    BSC_BIS_DIMENSION_PUB.Create_Dim_Objs_In_DSet
                    (       p_MTab_Tbl          =>  l_MTab_Tbl
                        ,   x_return_status     =>  x_return_status
                        ,   x_msg_count         =>  x_msg_count
                        ,   x_msg_data          =>  x_msg_data
                    );
                    ----DEBUG('8..'||get_default_value());
                END IF;
            END IF;
            --sync up with BIS Dimensions
            BSC_BIS_DIMENSION_PUB.Sync_Dimensions_In_Bis
            (       p_commit                =>  FND_API.G_FALSE
                ,   p_Dim_Obj_Short_Name    =>  p_dim_obj_short_name
                ,   p_Sync_Flag             =>  TRUE
                ,   x_return_status         =>  x_return_status
                ,   x_msg_count             =>  x_msg_count
                ,   x_msg_data              =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            ----DEBUG('9..'||get_default_value());
        END IF;
        /*************************************************************
         While updating the dimension object within the dimension we
         need to call the Validate_List_Button due to the following reason.
         For a List button to be enabled none of the dimension objects
         which are being used in the List button should have comparison
         as default.So after updating the dimension object properties
         we need to call the Sanity check API.
        /************************************************************/
        BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels_by_Dim
        (
              p_Dimension_Id    =>  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
            , x_return_status   =>  x_return_status
            , x_msg_count       =>  x_msg_count
            , x_msg_data        =>  x_msg_data
        );

        ----DEBUG('10..'||get_default_value());
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- START Granular Locking added by Aditya
        BSC_BIS_LOCKS_PUB.Set_Time_Stamp_Dim_Group
        (       p_dim_group_id          =>  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    IF (p_dim_short_name IS NOT NULL AND p_dim_short_name <> BSC_BIS_DIMENSION_PUB.Unassigned_Dim) THEN
        -- Bug 4997042
        BSC_BIS_DIM_OBJ_PUB.Cascade_Dim_Props_Into_Dim_Grp (
          p_Dim_Obj_Short_Name   =>  p_dim_obj_short_name
          , p_Dim_Short_Name     =>  p_dim_short_name
          , p_All_Flag           =>  p_total_flag
          , x_Return_Status      =>  x_return_status
          , x_Msg_Count          =>  x_msg_count
          , x_Msg_Data           =>  x_msg_data
       );
       IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       ----DEBUG('11..'||get_default_value());
    END IF;

    IF(p_dim_obj_short_name IS NOT NULL AND p_default_value IS NOT NULL) THEN
     --Here we need to cascade the changes to bsc_measure_props table.
     --when any of the dimension object is set to comparison mode then all
     --the kpis which are using this dimension object should be set to comparison mode

     FOR cd IN c_kpi_meas_props LOOP
      l_kpi_measure_props_rec.objective_id   := cd.indicator;
      l_kpi_measure_props_rec.kpi_measure_id := cd.kpi_measure_id;
      l_kpi_measure_props_rec.color_by_total := 1;

      IF(p_default_value='C') THEN
       l_kpi_measure_props_rec.color_by_total := 0;
      END IF;

        BSC_KPI_MEASURE_PROPS_PUB.Update_Kpi_Measure_Props
        (
            p_commit           => FND_API.G_FALSE
          , p_kpi_measure_rec  => l_kpi_measure_props_rec
          , p_cascade_shared   => TRUE
          , x_return_status    =>  x_return_status
          , x_msg_count        =>  x_msg_count
          , x_msg_data         =>  x_msg_data
        );
      IF (x_return_status  <> NULL AND x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     END LOOP;
    END IF;

    ----DEBUG('11..'||get_default_value());

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;

    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        IF (cr_bsc_dim_obj_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_obj_id;
        END IF;
        IF (c_Defaut_Value%ISOPEN) THEN
            CLOSE c_Defaut_Value;
        END IF;
        ROLLBACK TO AssBSCDimObjectPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        IF (cr_bsc_dim_obj_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_obj_id;
        END IF;
        IF (c_Defaut_Value%ISOPEN) THEN
            CLOSE c_Defaut_Value;
        END IF;
        ROLLBACK TO AssBSCDimObjectPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN NO_DATA_FOUND THEN
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        IF (cr_bsc_dim_obj_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_obj_id;
        END IF;
        IF (c_Defaut_Value%ISOPEN) THEN
            CLOSE c_Defaut_Value;
        END IF;
        ROLLBACK TO AssBSCDimObjectPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Assign_Dimension_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Assign_Dimension_Object ';
        END IF;

    WHEN OTHERS THEN
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        IF (cr_bsc_dim_obj_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_obj_id;
        END IF;
        IF (c_Defaut_Value%ISOPEN) THEN
            CLOSE c_Defaut_Value;
        END IF;
        ROLLBACK TO AssBSCDimObjectPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Assign_Dimension_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Assign_Dimension_Object ';
        END IF;

END Assign_Dimension_Object;

/*********************************************************************************
                       UNASSIGN DIMENSION OBJECTS FROM DIMENSION
*********************************************************************************/
PROCEDURE UnAssign_Dimension_Objects
(       p_commit                IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name        IN              VARCHAR2
    ,   p_dim_obj_short_names   IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2   := NULL    -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    l_bsc_dimension_rec     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
    l_Dim_Obj_Source        BSC_SYS_DIM_LEVELS_B.Source%TYPE := NULL;
    l_Dim_Grp_ID            BSC_SYS_DIM_GROUPS_TL.Dim_Group_Id%TYPE;
    l_Source_Type           BSC_SYS_DIM_LEVELS_B.Source%TYPE;
    l_dim_obj_names         VARCHAR2(32000);
    l_dim_obj_name          BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE;
    l_MTab_Tbl              BSC_BIS_DIMENSION_PUB.KPI_Dim_Set_Table_Type;
    l_Bis_Group_ID          BIS_DIMENSIONS.Dimension_ID%TYPE;
    l_kpi_cascade           BOOLEAN := FALSE;
    l_count                 NUMBER;
    -- START Granular Locking Declaration added by Aditya
    l_Dim_Obj_Tab           BSC_BIS_LOCKS_PUB.t_numberTable;
    l_index                 NUMBER := 0;
    -- END Granular Locking Declaration added by Aditya
    CURSOR  cr_bsc_dimension_id IS
    SELECT  Dim_Group_Id
    FROM    BSC_SYS_DIM_GROUPS_VL
    WHERE   Short_Name = p_dim_short_name;

    CURSOR  cr_bsc_dim_obj_id IS
    SELECT  Dim_Level_Id
          , Source
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   Short_Name     = l_dim_obj_name;

    CURSOR  cr_bis_dim_ids IS
    SELECT  Short_Name
    FROM    BIS_LEVELS
    WHERE   Dimension_Id = l_Bis_Group_ID;
BEGIN
    SAVEPOINT UnAssBSCDimObjectPMD;

    IF (p_dim_short_name <> BSC_BIS_DIMENSION_PUB.Unassigned_Dim) THEN
        FND_MSG_PUB.Initialize;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        IF (p_dim_short_name IS NULL) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
            FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SHORT_NAME'), TRUE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (cr_bsc_dimension_id%ISOPEN) THEN
            CLOSE cr_bsc_dimension_id;
        END IF;
        OPEN    cr_bsc_dimension_id;
            FETCH   cr_bsc_dimension_id
            INTO    l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id;
        CLOSE cr_bsc_dimension_id;
        IF (l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id IS NULL) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
            FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'EDW_DIMENSION'), TRUE);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- START Granular Locking Declaration added by Aditya
        -- Lock all the object that would be un-assigned to the Dimension
        l_dim_obj_names     :=  p_dim_obj_short_names;
        IF (p_dim_obj_short_names IS NOT NULL) THEN
            l_dim_obj_names   :=  p_dim_obj_short_names;
            WHILE (is_more(     p_dim_obj_short_names   =>  l_dim_obj_names
                            ,   p_dim_obj_name          =>  l_dim_obj_name)
            ) LOOP
                l_Dim_Obj_Tab(l_index) := nvl(BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(l_dim_obj_name), -1);
                l_index := l_index + 1;
            END LOOP;
            BSC_BIS_LOCKS_PUB.Lock_Update_Dimension
            (       p_dimension_id          =>  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
                ,   p_selected_dim_objets   =>  l_Dim_Obj_Tab
                ,   p_time_stamp            =>  p_time_stamp     -- Granular Locking
                ,   x_return_status         =>  x_return_status
                ,   x_msg_count             =>  x_msg_count
                ,   x_msg_data              =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        -- End Granular Locking
        IF (p_dim_obj_short_names IS NOT NULL) THEN
            l_Source_Type   := NVL(BSC_BIS_DIMENSION_PUB.Get_Dimension_Source(p_dim_short_name), 'BSC');
            /* -- Changed the position because must to go at the final when the metadata had
               -- been updated
            BSC_DIM_FILTERS_PUB.Check_Filters_Not_Apply
            (       p_Tab_Id         =>  NULL
                ,   x_return_status  =>  x_return_status
                ,   x_msg_count      =>  x_msg_count
                ,   x_msg_data       =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;*/
            BSC_BIS_DIMENSION_PUB.Store_Dim_Set_Records
            (       p_dim_group_id      =>  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
                ,   p_dim_short_name    =>  p_dim_short_name
                ,   x_MTab_Tbl          =>  l_MTab_Tbl
            );
            BSC_BIS_DIMENSION_PUB.Delete_Dim_Objs_In_DSet
            (       p_MTab_Tbl              =>  l_MTab_Tbl
                ,   x_return_status         =>  x_return_status
                ,   x_msg_count             =>  x_msg_count
                ,   x_msg_data              =>  x_msg_data
            );

            l_dim_obj_names   :=  p_dim_obj_short_names;
            WHILE (is_more(p_dim_obj_short_names   =>  l_dim_obj_names
                         , p_dim_obj_name          =>  l_dim_obj_name)
            ) LOOP
                IF (cr_bsc_dim_obj_id%ISOPEN) THEN
                    CLOSE cr_bsc_dim_obj_id;
                END IF;
                OPEN    cr_bsc_dim_obj_id;
                    FETCH   cr_bsc_dim_obj_id INTO l_bsc_dimension_rec.Bsc_Level_Id, l_Dim_Obj_Source;
                CLOSE cr_bsc_dim_obj_id;
                IF (l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id IS NULL) THEN
                    FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
                    FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIMENSION_OBJECT'), TRUE);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                IF (BSC_BIS_DIMENSION_PUB.is_Relation_Exists
                     (l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id, l_bsc_dimension_rec.Bsc_Level_Id)) THEN
                    l_kpi_cascade   := TRUE;
                    IF (l_Dim_Obj_Source = 'PMF') THEN
                        IF (BSC_BIS_DIMENSION_PUB.Get_Number_Of_Dimensions(l_bsc_dimension_rec.Bsc_Level_Id) = 1) THEN
                            l_Dim_Grp_ID    := BSC_BIS_DIMENSION_PUB.Get_Bsc_Dimension_ID(BSC_BIS_DIMENSION_PUB.Unassigned_Dim);
                            UPDATE BSC_SYS_DIM_LEVELS_BY_GROUP
                            SET    Dim_Group_Id = l_Dim_Grp_ID
                            WHERE  Dim_Group_Id = l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
                            AND    Dim_Level_Id = l_bsc_dimension_rec.Bsc_Level_Id;
                        END IF;
                    END IF;
                    IF ((l_Dim_Obj_Source = 'BSC') OR
                          (BSC_BIS_DIMENSION_PUB.Get_Number_Of_Dimensions(l_bsc_dimension_rec.Bsc_Level_Id) <> 1)) THEN
                        BSC_DIMENSION_GROUPS_PUB.Delete_Dim_Levels_In_Group
                        (       p_commit            =>  FND_API.G_FALSE
                            ,   p_Dim_Grp_Rec       =>  l_bsc_dimension_rec
                            ,   x_return_status     =>  x_return_status
                            ,   x_msg_count         =>  x_msg_count
                            ,   x_msg_data          =>  x_msg_data
                        );
                        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                        END IF;
                    END IF;
                END IF;
            END LOOP;
            --Update BSC_KPI_DIM_LEVELS_B with the current status
            IF (l_kpi_cascade) THEN
                BSC_BIS_DIMENSION_PUB.Create_Dim_Objs_In_DSet
                (    p_MTab_Tbl              =>  l_MTab_Tbl
                  ,  x_return_status         =>  x_return_status
                  ,  x_msg_count             =>  x_msg_count
                  ,  x_msg_data              =>  x_msg_data
                );
            ELSE
                BSC_BIS_DIMENSION_PUB.Create_Dim_Objs_In_DSet
                (    p_MTab_Tbl              =>  l_MTab_Tbl
                  ,  p_kpi_flag_change       =>  BSC_DESIGNER_PVT.G_ActionFlag.Normal
                  ,  x_return_status         =>  x_return_status
                  ,  x_msg_count             =>  x_msg_count
                  ,  x_msg_data              =>  x_msg_data
                );
            END IF;
            --sync up Dimensions in BIS
            l_Bis_Group_ID  := BSC_BIS_DIMENSION_PUB.Get_Bis_Dimension_ID(p_dim_short_name);
            FOR cd IN cr_bis_dim_ids LOOP
                BSC_BIS_DIMENSION_PUB.Sync_Dimensions_In_Bis
                (       p_commit                =>  FND_API.G_FALSE
                    ,   p_Dim_Obj_Short_Name    =>  cd.Short_Name
                    ,   p_Sync_Flag             =>  TRUE
                    ,   x_return_status         =>  x_return_status
                    ,   x_msg_count             =>  x_msg_count
                    ,   x_msg_data              =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                     RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END LOOP;
        END IF;

        -- This syncrinization mut to go at the final when all the metadata had
        -- been updated.
        IF (l_Source_Type = 'BSC') THEN
            BSC_DIM_FILTERS_PUB.Check_Filters_Not_Apply
            (       p_Tab_Id         =>  NULL
                ,   x_return_status  =>  x_return_status
                ,   x_msg_count      =>  x_msg_count
                ,   x_msg_data       =>  x_msg_data
            );
        END IF;
        -- Granular Locking : Change the Time Stamp of the Group, once it is changed
        BSC_BIS_LOCKS_PUB.Set_Time_Stamp_Dim_Group
        (       p_dim_group_id              =>  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
            ,   x_return_status             =>  x_return_status
            ,   x_msg_count                 =>  x_msg_count
            ,   x_msg_data                  =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Granular Locking : Change the Time Stamp of the Group, Once it is changed
        IF (p_commit = FND_API.G_TRUE) THEN
            COMMIT;
        END IF;
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (cr_bsc_dimension_id%ISOPEN) THEN
            CLOSE cr_bsc_dimension_id;
        END IF;
        IF (cr_bsc_dim_obj_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_obj_id;
        END IF;
        ROLLBACK TO UnAssBSCDimObjectPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (cr_bsc_dimension_id%ISOPEN) THEN
            CLOSE cr_bsc_dimension_id;
        END IF;
        IF (cr_bsc_dim_obj_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_obj_id;
        END IF;
        ROLLBACK TO UnAssBSCDimObjectPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN NO_DATA_FOUND THEN
        IF (cr_bsc_dimension_id%ISOPEN) THEN
            CLOSE cr_bsc_dimension_id;
        END IF;
        IF (cr_bsc_dim_obj_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_obj_id;
        END IF;
        ROLLBACK TO UnAssBSCDimObjectPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.UnAssign_Dimension_Objects ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.UnAssign_Dimension_Objects ';
        END IF;

    WHEN OTHERS THEN
        IF (cr_bsc_dimension_id%ISOPEN) THEN
            CLOSE cr_bsc_dimension_id;
        END IF;
        IF (cr_bsc_dim_obj_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_obj_id;
        END IF;
        ROLLBACK TO UnAssBSCDimObjectPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.UnAssign_Dimension_Objects ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.UnAssign_Dimension_Objects ';
        END IF;

END UnAssign_Dimension_Objects;

/*********************************************************************************
                    RESTRICT INTERNAL DIMENSION OBJECT FOR USE IN DD
*********************************************************************************/
PROCEDURE Restrict_Internal_Dim_Objs
(       p_dim_short_name                IN              VARCHAR2
    ,   p_assign_dim_obj_names          IN              VARCHAR2
    ,   p_unassign_dim_obj_names        IN              VARCHAR2
    ,   x_return_status                 OUT    NOCOPY   VARCHAR2
    ,   x_msg_count                     OUT    NOCOPY   NUMBER
    ,   x_msg_data                      OUT    NOCOPY   VARCHAR2
) IS
    l_dim_obj_sname                 VARCHAR2(32000);
    l_unassigns           VARCHAR2(32000);
    l_unassign            VARCHAR2(100);
    l_regions             VARCHAR2(32000);
    l_dim_name            VARCHAR2(300);
    l_dim_obj_name        VARCHAR2(300);

BEGIN
    IF (p_unassign_dim_obj_names IS NOT NULL) THEN
      l_unassigns := p_unassign_dim_obj_names;
      WHILE (is_more(     p_dim_obj_short_names   =>  l_unassigns
                      ,   p_dim_obj_name          =>  l_unassign)
      ) LOOP
        l_regions := BSC_UTILITY.Is_Dim_In_AKReport(p_dim_short_name||'+'||l_unassign);
        IF(l_regions IS NOT NULL) THEN
          SELECT DIM_NAME
          INTO   l_dim_name
          FROM   BSC_BIS_DIM_VL
          WHERE  SHORT_NAME = p_dim_short_name;

          SELECT NAME
          INTO   l_dim_obj_name
          FROM   BSC_BIS_DIM_OBJS_VL
          WHERE  SHORT_NAME = l_unassign;

          FND_MESSAGE.SET_NAME('BIS','BIS_DIM_OBJ_RPTASSOC_ERROR');
          FND_MESSAGE.SET_TOKEN('DIM_NAME', l_dim_name);
          FND_MESSAGE.SET_TOKEN('DIM_OBJ_NAME', l_dim_obj_name);
          FND_MESSAGE.SET_TOKEN('REPORTS_ASSOC', l_regions);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
    END IF;
    l_dim_obj_sname := p_assign_dim_obj_names;
    IF (p_unassign_dim_obj_names IS NOT NULL) THEN
      IF (l_dim_obj_sname IS NULL) THEN
        l_dim_obj_sname := p_unassign_dim_obj_names;
      ELSE
        l_dim_obj_sname := l_dim_obj_sname|| ',' || p_unassign_dim_obj_names;
      END IF;
    END IF;
    BSC_UTILITY.Enable_Dimensions_Entity(
        p_Entity_Type           => BSC_UTILITY.c_DIMENSION_OBJECT
      , p_Entity_Short_Names    => l_dim_obj_sname
      , p_Entity_Action_Type    => BSC_UTILITY.c_UPDATE
      , x_Return_Status         => x_return_status
      , x_Msg_Count             => x_msg_count
      , x_Msg_Data              => x_msg_data
    );
END Restrict_Internal_Dim_Objs;

/*********************************************************************************
                    ASSIGN & UNASSIGN DIMENSION OBJECTS TO DIMENSION
*********************************************************************************/
PROCEDURE Assign_Unassign_Dim_Objs
(       p_commit                        IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name                IN              VARCHAR2
    ,   p_assign_dim_obj_names          IN              VARCHAR2
    ,   p_unassign_dim_obj_names        IN              VARCHAR2
    ,   p_time_stamp                    IN              VARCHAR2   :=   NULL    -- Granular Locking
    ,   p_Restrict_Dim_Validate         IN              VARCHAR2   := NULL
    ,   x_return_status                 OUT    NOCOPY   VARCHAR2
    ,   x_msg_count                     OUT    NOCOPY   NUMBER
    ,   x_msg_data                      OUT    NOCOPY   VARCHAR2
) IS
    l_unassigns                 VARCHAR2(32000);
    l_assigns                   VARCHAR2(32000);
    l_unassign                  BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE;
    l_assign                    BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE;
    l_unassign_dim_objs         VARCHAR2(32000);
    l_flag                      BOOLEAN;

    l_dim_obj_sht_names         VARCHAR2(32000);
    l_dim_obj_sht_name          BIS_LEVELS.Short_Name%TYPE;

    l_dim_short_name            BIS_DIMENSIONS.short_name%TYPE;
    l_first_dim_short_name      BIS_DIMENSIONS.short_name%TYPE;
    CURSOR  c_dim_sht_names IS
    SELECT  B.SHORT_NAME
    FROM    BIS_LEVELS     A
         ,  BIS_DIMENSIONS B
    WHERE   B.DIMENSION_ID = A.DIMENSION_ID
    AND     A.SHORT_NAME   = l_dim_obj_sht_name;

    CURSOR  c_bsc_dim_sht_names IS
    SELECT  dim_short_name
    FROM    BSC_BIS_DIM_OBJ_BY_DIM_VL
    WHERE   obj_short_name = l_dim_obj_sht_name
    AND     dim_short_name <>p_dim_short_name;
BEGIN

    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_dim_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_unassign_dim_obj_names IS NOT NULL) THEN
        l_unassigns   :=  p_unassign_dim_obj_names;
        WHILE (is_more(     p_dim_obj_short_names   =>  l_unassigns
                        ,   p_dim_obj_name          =>  l_unassign)
        ) LOOP
            l_assigns   :=  p_assign_dim_obj_names;
            l_flag      :=  TRUE;
            WHILE (is_more(     p_dim_obj_short_names   =>  l_assigns
                            ,   p_dim_obj_name          =>  l_assign)
            ) LOOP
                IF(l_unassign = l_assign) THEN
                    l_flag  :=  FALSE;
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

            BSC_BIS_DIMENSION_PUB.UnAssign_Dimension_Objects
            (       p_commit                =>  FND_API.G_FALSE
                ,   p_dim_short_name        =>  p_dim_short_name
                ,   p_dim_obj_short_names   =>  l_unassign_dim_objs
                ,   p_time_stamp            =>  p_time_stamp     -- Granular Locking
                ,   x_return_status         =>  x_return_status
                ,   x_msg_count             =>  x_msg_count
                ,   x_msg_data              =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF;
    IF (p_Restrict_Dim_Validate IS NOT NULL) THEN
      Restrict_Internal_Dim_Objs
      (       p_dim_short_name                => p_dim_short_name
          ,   p_assign_dim_obj_names          => p_assign_dim_obj_names
          ,   p_unassign_dim_obj_names        => l_unassign_dim_objs
          ,   x_return_status                 => x_return_status
          ,   x_msg_count                     => x_msg_count
          ,   x_msg_data                      => x_msg_data
      );
      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
    IF (p_assign_dim_obj_names IS NOT NULL) THEN
        BSC_BIS_DIMENSION_PUB.Assign_Dimension_Objects
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_dim_short_name        =>  p_dim_short_name
            ,   p_dim_obj_short_names   =>  p_assign_dim_obj_names
            ,   p_time_stamp            =>  p_time_stamp                -- Granular Locking
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN

            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- Bug 3784852 validate empty dimension after unassign dim objs and remove those from dim sets for all objectives
    BSC_BIS_DIMENSION_PUB.Remove_Empty_Dims_For_DimSet
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_dim_short_names       =>  p_dim_short_name
            ,   p_time_stamp            =>  p_time_stamp                -- Granular Locking
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;

    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

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

    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Assign_Unassign_Dim_Objs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Assign_Unassign_Dim_Objs ';
        END IF;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Assign_Unassign_Dim_Objs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Assign_Unassign_Dim_Objs ';
        END IF;

END Assign_Unassign_Dim_Objs;
/*********************************************************************************
                        UPDATE DIMENSION
*********************************************************************************/
PROCEDURE Update_Dimension
(       p_commit                IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name        IN              VARCHAR2
    ,   p_display_name          IN              VARCHAR2
    ,   p_description           IN              VARCHAR2
    ,   p_application_id        IN              NUMBER
    ,   p_time_stamp            IN              VARCHAR2    :=   NULL    -- Granular Locking
    ,   p_hide                  IN              VARCHAR2   := FND_API.G_FALSE
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
)IS
    l_bis_dimension_rec     BIS_DIMENSION_PUB.Dimension_Rec_Type;
    l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
    l_bsc_dimension_rec     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
    l_dim_short_name        BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
    l_application_id        BIS_DIMENSIONS.Application_Id%TYPE;
    l_bis_create            BOOLEAN := FALSE;
    l_bsc_create            BOOLEAN := FALSE;

    l_count                 NUMBER;

    l_pmf_disp_name         VARCHAR2(255); -- DispName



    CURSOR  cr_bsc_dim_id IS
    SELECT  name, dim_group_id
    FROM    BSC_SYS_DIM_GROUPS_VL
    WHERE   short_name  = l_dim_short_name;

    CURSOR  cr_bis_dim_id IS
    SELECT  name, description, dimension_id
    FROM    BIS_DIMENSIONS_VL
    WHERE   short_name  = l_dim_short_name;
BEGIN
    SAVEPOINT UpdateBSCDimensionPMD;

    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF(p_dim_short_name IS NOT NULL) THEN
        l_application_id    :=  p_application_id;
    END IF;
    l_dim_short_name    :=  p_dim_short_name;
    IF (l_dim_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF (cr_bis_dim_id%ISOPEN) THEN
        CLOSE cr_bis_dim_id;
    END IF;
    OPEN    cr_bis_dim_id;
    FETCH   cr_bis_dim_id
    INTO    l_bis_dimension_rec.Dimension_Name
          , l_bis_dimension_rec.Description
          , l_bis_dimension_rec.dimension_id;
        IF (cr_bis_dim_id%ROWCOUNT = 0) THEN
            l_bis_create := TRUE; -- this flag indicates that the entries are not in the PMF metadata, so create it
        END IF;
    CLOSE cr_bis_dim_id;

    IF (cr_bsc_dim_id%ISOPEN) THEN
        CLOSE cr_bsc_dim_id;
    END IF;
    OPEN    cr_bsc_dim_id;
    FETCH   cr_bsc_dim_id
    INTO    l_bsc_dimension_rec.Bsc_Dim_Level_Group_Name
          , l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id;
        IF (cr_bsc_dim_id%ROWCOUNT = 0) THEN
            IF (l_bis_create) THEN
                l_bis_create := FALSE;
                FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
                FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'EDW_DIMENSION'), TRUE);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
            ELSE
                l_bsc_create := TRUE; -- this flag indicates that the entries are not in the PMF metadata, so create it
            END IF;
        END IF;
    CLOSE cr_bsc_dim_id;
    IF (l_dim_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --check uniqueness of display name
    IF (p_display_name IS NOT NULL) THEN
        IF (p_display_name <> l_bis_dimension_rec.Dimension_Name) THEN
            l_pmf_disp_name := p_display_name;
            SELECT  COUNT(1) INTO l_count
            FROM    BIS_DIMENSIONS_VL
            WHERE   UPPER(short_name) <> UPPER(l_dim_short_name)
            AND     UPPER(name)        = UPPER(p_display_name);
            WHILE(l_count > 0) LOOP
                l_pmf_disp_name := bsc_utility.get_Next_DispName(l_pmf_disp_name);
                SELECT  COUNT(1) INTO l_count
                FROM    BIS_DIMENSIONS_VL
                WHERE   UPPER(name)        = UPPER(l_pmf_disp_name);
            END LOOP;
        END IF;
    END IF;
    IF (l_bis_create) THEN
        IF (p_display_name IS NULL) THEN
            l_bis_dimension_rec.Dimension_Name      :=  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Name;
        ELSE
            l_bis_dimension_rec.Dimension_Name      :=  l_pmf_disp_name;
        END IF;

        l_bis_dimension_rec.Dimension_Short_Name    :=  l_dim_short_name;

        l_bis_dimension_rec.Application_ID          :=  l_application_id;

        l_bis_dimension_rec.Description             :=  p_description;

        l_bis_dimension_rec.Hide                    :=  p_Hide;

        BIS_DIMENSION_PUB.Create_Dimension
        (       p_api_version       =>  1.0
            ,   p_commit            =>  FND_API.G_FALSE
            ,   p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL
            ,   p_Dimension_Rec     =>  l_bis_dimension_rec
            ,   x_return_status     =>  x_return_status
            ,   x_error_Tbl         =>  l_error_tbl
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            IF (l_error_tbl.COUNT > 0) THEN
                x_msg_data  :=  l_error_tbl(l_error_tbl.COUNT).Error_Description;
                IF(INSTR(x_msg_data, ' ')  =  0 ) THEN
                    FND_MESSAGE.SET_NAME('BIS', x_msg_data);
                    FND_MSG_PUB.ADD;
                    x_msg_data  :=  NULL;
                END IF;
                RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSE
        l_bis_dimension_rec.Dimension_Name           :=  l_pmf_disp_name;

        l_bis_dimension_rec.Dimension_Short_Name     :=  l_dim_short_name;

        l_bis_dimension_rec.Application_ID           :=  l_application_id;

        l_bis_dimension_rec.Description              :=  p_description;

        l_bis_dimension_rec.Hide                     :=  p_Hide;

        BIS_DIMENSION_PUB.Update_Dimension
        (       p_api_version           =>  1.0
            ,   p_commit                =>  FND_API.G_FALSE
            ,   p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL
            ,   p_Dimension_Rec         =>  l_bis_dimension_rec
            ,   x_return_status         =>  x_return_status
            ,   x_error_Tbl             =>  l_error_tbl
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            IF (l_error_tbl.COUNT > 0) THEN
                x_msg_data  :=  l_error_tbl(l_error_tbl.COUNT).Error_Description;

                IF(INSTR(x_msg_data, ' ')  =  0 ) THEN
                    FND_MESSAGE.SET_NAME('BIS',x_msg_data);
                    FND_MSG_PUB.ADD;
                    x_msg_data  :=  NULL;
                END IF;
                RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    l_bsc_dimension_rec.Bsc_Dim_Level_Index             :=   1;
    l_bsc_dimension_rec.Bsc_Dim_Level_Group_short_name  :=   l_dim_short_name;
    l_bsc_dimension_rec.Bsc_Group_Level_Comp_Flag       :=  -1;
    l_bsc_dimension_rec.Bsc_Group_Level_Default_Value   :=  'T';
    l_bsc_dimension_rec.Bsc_Group_Level_Default_Type    :=   0;
    l_bsc_dimension_rec.Bsc_Group_Level_Filter_Col      :=   NULL;
    l_bsc_dimension_rec.Bsc_Group_Level_Filter_Value    :=   0;
    l_bsc_dimension_rec.Bsc_Group_Level_No_Items        :=   0;
    l_bsc_dimension_rec.Bsc_Group_Level_Parent_In_Tot   :=   2;
    l_bsc_dimension_rec.Bsc_Group_Level_Total_Flag      :=  -1;
    IF (l_bsc_create) THEN
        IF (p_display_name IS NULL) THEN
            l_bsc_dimension_rec.Bsc_Dim_Level_Group_Name  :=  l_bis_dimension_rec.Dimension_Name;
        ELSE
            l_bsc_dimension_rec.Bsc_Dim_Level_Group_Name  :=  p_display_name;
        END IF;

        BSC_DIMENSION_GROUPS_PUB.Create_Dimension_Group
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_Dim_Grp_Rec           =>  l_bsc_dimension_rec
            ,   p_create_Dim_Levels     =>  FALSE
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        --update grp id in BIS Diemension Tables
        --this call will be moved to CRUD APIs later
        UPDATE BIS_DIMENSIONS
        SET    Dim_Grp_ID   =
        (   SELECT  dim_group_id
            FROM    BSC_SYS_DIM_GROUPS_VL
            WHERE   Short_Name = l_bsc_dimension_rec.Bsc_Dim_Level_Group_short_name
        );
    ELSE
        l_bsc_dimension_rec.Bsc_Dim_Level_Group_Name        :=  p_display_name;

        l_bsc_dimension_rec.Bsc_Dim_Level_Group_short_name  :=  l_dim_short_name;
        BSC_DIMENSION_GROUPS_PUB.Update_Dimension_Group
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_Dim_Grp_Rec           =>  l_bsc_dimension_rec
            ,   p_create_Dim_Levels     =>  FALSE
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    l_bis_create    :=  FALSE;--Initialize with the default value
    l_bsc_create    :=  FALSE;
    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;

    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (cr_bis_dim_id%ISOPEN) THEN
            CLOSE cr_bis_dim_id;
        END IF;
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        ROLLBACK TO UpdateBSCDimensionPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (cr_bis_dim_id%ISOPEN) THEN
            CLOSE cr_bis_dim_id;
        END IF;
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        ROLLBACK TO UpdateBSCDimensionPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN NO_DATA_FOUND THEN
        IF (cr_bis_dim_id%ISOPEN) THEN
            CLOSE cr_bis_dim_id;
        END IF;
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        ROLLBACK TO UpdateBSCDimensionPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Update_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Update_Dimension ';
        END IF;

    WHEN OTHERS THEN
        IF (cr_bis_dim_id%ISOPEN) THEN
            CLOSE cr_bis_dim_id;
        END IF;
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        ROLLBACK TO UpdateBSCDimensionPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Update_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Update_Dimension ';
        END IF;

END Update_Dimension;

/*********************************************************************************
                        UPDATE DIMENSION
*********************************************************************************/
PROCEDURE Update_Dimension
(       p_commit                    IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name            IN              VARCHAR2
    ,   p_display_name              IN              VARCHAR2
    ,   p_description               IN              VARCHAR2
    ,   p_application_id            IN              NUMBER
    ,   p_assign_dim_obj_names      IN              VARCHAR2
    ,   p_unassign_dim_obj_names    IN              VARCHAR2
    ,   p_time_stamp                IN              VARCHAR2    :=   NULL    -- Granular Locking
    ,   p_hide                      IN              VARCHAR2   := FND_API.G_FALSE
    ,   p_Restrict_Dim_Validate     IN              VARCHAR2   := NULL
    ,   x_return_status             OUT    NOCOPY   VARCHAR2
    ,   x_msg_count                 OUT    NOCOPY   NUMBER
    ,   x_msg_data                  OUT    NOCOPY   VARCHAR2
)IS
    -- START Granular Locking Declaration added by Aditya
    l_bsc_dimension_rec     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;

    CURSOR  cr_bsc_dim_id IS
    SELECT  dim_group_id
    FROM    BSC_SYS_DIM_GROUPS_VL
    WHERE   short_name = p_dim_short_name;

    l_Dim_Obj_Tab           BSC_BIS_LOCKS_PUB.t_numberTable;
    l_dim_obj_names         VARCHAR2(32000);

    l_dim_obj_name          BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE;
    l_index                 NUMBER := 0;
    l_mix_type_dim          BOOLEAN;
    l_dim_type              VARCHAR2(10);
    l_count                 NUMBER;

    CURSOR c_indicators IS
    SELECT DISTINCT indicator
    FROM   BSC_KPI_DIM_GROUPS
    WHERE  dim_group_id = l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id;
    -- END Granular Locking Declaration added by Aditya
BEGIN
    -- START Granular Locking added by Aditya

    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_dim_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (cr_bsc_dim_id%ISOPEN) THEN
        CLOSE cr_bsc_dim_id;
    END IF;
    OPEN    cr_bsc_dim_id;
        FETCH   cr_bsc_dim_id
        INTO    l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id;
    CLOSE cr_bsc_dim_id;
    IF (l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'EDW_DIMENSION'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_mix_type_dim := FALSE;
    IF(p_assign_dim_obj_names IS NOT NULL) THEN
        l_mix_type_dim := check_sametype_dimobjs
                          (      p_dim_name              =>  p_display_name
                             ,   p_dim_short_name        =>  p_dim_short_name
                             ,   p_dim_short_names       =>  p_assign_dim_obj_names
                             ,   p_Restrict_Dim_Validate =>  p_Restrict_Dim_Validate
                             ,   x_dim_type              =>  l_dim_type
                             ,   x_return_status         =>  x_return_status
                             ,   x_msg_count             =>  x_msg_count
                             ,   x_msg_data              =>  x_msg_data
                          );
        IF (l_mix_type_dim) THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    -- Enh#4172034: Validations
    IF (l_dim_type = 'PMF') THEN

      SELECT  COUNT(1) INTO l_count
        FROM    BSC_SYS_DIM_GROUPS_VL
        WHERE   UPPER(short_name) <> UPPER(p_dim_short_name)
    AND     UPPER(name) = UPPER(p_display_name); -- already trimmed from JAVA
      IF (l_count <> 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_UNIQUE_NAME_REQUIRED');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DISPLAY_NAME'), TRUE);
        FND_MESSAGE.SET_TOKEN('NAME_VALUE', p_display_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      SELECT  COUNT(1) INTO l_count
        FROM    BIS_DIMENSIONS_VL
        WHERE   UPPER(short_name) <> UPPER(p_dim_short_name)
    AND     UPPER(name) = UPPER(p_display_name);
      IF (l_count <> 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_UNIQUE_NAME_REQUIRED');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DISPLAY_NAME'), TRUE);
        FND_MESSAGE.SET_TOKEN('NAME_VALUE', p_display_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;


    -- Lock all the object that would be assigned to the Dimension
    l_dim_obj_names :=  p_assign_dim_obj_names;
    IF (p_assign_dim_obj_names IS NOT NULL) THEN
        l_dim_obj_names   :=  p_assign_dim_obj_names ;
        WHILE (is_more(     p_dim_obj_short_names   =>  l_dim_obj_names
                        ,   p_dim_obj_name          =>  l_dim_obj_name)
        ) LOOP

            l_Dim_Obj_Tab(l_index) := NVL(BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(l_dim_obj_name), -1);
            l_index := l_index + 1;
        END LOOP;
    END IF;
    -- Lock all the object that would be un-assigned to the Dimension
    l_dim_obj_names :=  p_unassign_dim_obj_names;
    IF (p_unassign_dim_obj_names IS NOT NULL) THEN
        l_dim_obj_names   :=  p_unassign_dim_obj_names ;
        WHILE (is_more(     p_dim_obj_short_names   =>  l_dim_obj_names
                        ,   p_dim_obj_name          =>  l_dim_obj_name)
        ) LOOP
            l_Dim_Obj_Tab(l_index) := NVL(BSC_DIMENSION_LEVELS_PVT.get_Dim_Level_Id(l_dim_obj_name), -1);
            l_index := l_index + 1;
        END LOOP;
    END IF;
    -- Lock all the Dimension Objects to be assigned/unassigned to the Dimension
    -- Pass the time_stamp_value
    BSC_BIS_LOCKS_PUB.Lock_Update_Dimension
    (    p_dimension_id          =>  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
      ,  p_selected_dim_objets   =>  l_Dim_Obj_Tab
      ,  p_time_stamp            =>  p_time_stamp        -- Granular Locking
      ,  x_return_status         =>  x_return_status
      ,  x_msg_count             =>  x_msg_count
      ,  x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- End Granular Locking
    BSC_BIS_DIMENSION_PUB.Update_Dimension
    (       p_commit                =>  FND_API.G_FALSE
        ,   p_dim_short_name        =>  p_dim_short_name
        ,   p_display_name          =>  p_display_name
        ,   p_description           =>  p_description
        ,   p_application_id        =>  p_application_id
        ,   p_time_stamp            =>  NULL        -- Granular Locking
        ,   p_hide                  =>  p_hide
        ,   x_return_status         =>  x_return_status
        ,   x_msg_count             =>  x_msg_count
        ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    BSC_BIS_DIMENSION_PUB.Assign_Unassign_Dim_Objs
    (       p_commit                    =>  FND_API.G_FALSE
        ,   p_dim_short_name            =>  p_dim_short_name
        ,   p_assign_dim_obj_names      =>  p_assign_dim_obj_names
        ,   p_unassign_dim_obj_names    =>  p_unassign_dim_obj_names
        ,   p_time_stamp                =>  NULL
    ,   p_Restrict_Dim_Validate     =>  p_Restrict_Dim_Validate
        ,   x_return_status             =>  x_return_status
        ,   x_msg_count                 =>  x_msg_count
        ,   x_msg_data                  =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Granular Locking : Change the Time Stamp of the Group, once it is changed
    BSC_BIS_LOCKS_PUB.Set_Time_Stamp_Dim_Group
    (       p_dim_group_id              =>  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
        ,   x_return_status             =>  x_return_status
        ,   x_msg_count                 =>  x_msg_count
        ,   x_msg_data                  =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Granular Locking : Change the Time Stamp of the Group, Once it is changed
    BSC_COMMON_DIM_LEVELS_PUB.Check_Common_Dim_Levels_by_Dim
    (
          p_Dimension_Id    =>  l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
          , x_return_status     =>  x_return_status
          , x_msg_count         =>  x_msg_count
          , x_msg_data          =>  x_msg_data
       );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;

    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN NO_DATA_FOUND THEN
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Update_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Update_Dimension ';
        END IF;

    WHEN OTHERS THEN
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Update_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Update_Dimension ';
        END IF;

END Update_Dimension;

/*********************************************************************************
                        UPDATE DIMENSION
*********************************************************************************/
PROCEDURE Update_Dimension
(       p_commit                    IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name            IN              VARCHAR2
    ,   p_display_name              IN              VARCHAR2
    ,   p_description               IN              VARCHAR2
    ,   p_application_id            IN              NUMBER
    ,   p_dim_obj_short_names       IN              VARCHAR2
    ,   p_time_stamp                IN              VARCHAR2    :=   NULL    -- Granular Locking
    ,   p_hide                      IN              VARCHAR2   := FND_API.G_FALSE
    ,   p_Restrict_Dim_Validate     IN              VARCHAR2   := NULL
    ,   x_return_status             OUT    NOCOPY   VARCHAR2
    ,   x_msg_count                 OUT    NOCOPY   NUMBER
    ,   x_msg_data                  OUT    NOCOPY   VARCHAR2
)IS
    l_bsc_dimension_rec     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
    l_kpi_id                NUMBER;
    l_dim_set_id            NUMBER;
    l_count                 NUMBER;
    l_indp_dimobj           NUMBER;
    l_affected_kpis         VARCHAR2(32000);
    l_kpi_name              VARCHAR2(20000);
    l_is_kpi_affected        BOOLEAN;

    CURSOR  cr_bsc_dim_id IS
    SELECT  dim_group_id
    FROM    BSC_SYS_DIM_GROUPS_VL WHERE short_name = p_dim_short_name;

    CURSOR  cr_bsc_dim IS
    SELECT  short_name
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   dim_level_id IN (SELECT dim_level_id
    FROM    BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE   dim_group_id = l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id);

    CURSOR   cr_indicdimset_for_dimgrp IS
    SELECT   grp.indicator , grp.dim_set_id,count(kpi.dim_level_index)
    FROM     BSC_KPI_DIM_GROUPS grp,
             BSC_KPI_DIM_LEVELS_B kpi
    WHERE    kpi.indicator = grp.indicator
    AND      kpi.dim_set_id = grp.dim_set_id
    AND      grp.dim_group_id = l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
    GROUP BY grp.indicator,grp.dim_set_id;

    -- START Granular Locking Declaration added by Aditya
    l_Dim_Obj_Tab               BSC_BIS_LOCKS_PUB.t_numberTable;
    l_dim_obj_names             VARCHAR2(32000);

    l_unassign_dim_obj_names    VARCHAR2(32000);

    l_dim_obj_name              VARCHAR2(30);
    l_index                     NUMBER := 0;
    l_mix_type_dim              BOOLEAN;
    -- END Granular Locking Declaration added by Aditya

BEGIN

    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_dim_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF (cr_bsc_dim_id%ISOPEN) THEN
        CLOSE cr_bsc_dim_id;
    END IF;
    OPEN    cr_bsc_dim_id;
        FETCH   cr_bsc_dim_id
        INTO    l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id;
    CLOSE cr_bsc_dim_id;

    IF (l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'EDW_DIMENSION'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    FOR cd IN cr_bsc_dim LOOP
        IF (l_unassign_dim_obj_names IS NULL) THEN
            l_unassign_dim_obj_names    :=  cd.short_name;
        ELSE
            l_unassign_dim_obj_names    :=  l_unassign_dim_obj_names||', '||cd.short_name;
        END IF;
    END LOOP;
    BSC_BIS_DIMENSION_PUB.Update_Dimension
    (       p_commit                    =>  FND_API.G_FALSE
        ,   p_dim_short_name            =>  p_dim_short_name
        ,   p_display_name              =>  p_display_name
        ,   p_description               =>  p_description
        ,   p_application_id            =>  p_application_id
        ,   p_assign_dim_obj_names      =>  p_dim_obj_short_names
        ,   p_unassign_dim_obj_names    =>  l_unassign_dim_obj_names
        ,   p_time_stamp                =>  p_time_stamp -- Need to add timestamp
        ,   p_hide                      =>  p_hide
        ,   p_Restrict_Dim_Validate =>  p_Restrict_Dim_Validate
        ,   x_return_status             =>  x_return_status
        ,   x_msg_count                 =>  x_msg_count
        ,   x_msg_data                  =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    /********************************************************
            Check no of independent dimension objects in dimension set
    ********************************************************/
        l_is_kpi_affected := FALSE;
        OPEN cr_indicdimset_for_dimgrp;
        LOOP
            FETCH cr_indicdimset_for_dimgrp INTO l_kpi_id,l_dim_set_id,l_count;
            EXIT WHEN cr_indicdimset_for_dimgrp%NOTFOUND;
            IF( l_count > bsc_utility.NO_IND_DIM_OBJ_LIMIT) THEN

                l_indp_dimobj := 0;
                l_indp_dimobj := bsc_utility.get_nof_independent_dimobj
                                 (    p_Kpi_Id        =>  l_kpi_id
                                    , p_Dim_Set_Id    =>  l_dim_set_id
                                 );
                IF(l_indp_dimobj >bsc_utility.NO_IND_DIM_OBJ_LIMIT) THEN
                    SELECT NAME INTO l_kpi_name
                    FROM   BSC_KPIS_VL
                    WHERE  INDICATOR = l_kpi_id;

                    IF(l_affected_kpis IS NULL) THEN
                        l_affected_kpis := '['||l_kpi_name||']';
                    ELSE
                        IF(INSTR(l_affected_kpis,l_kpi_name) = 0) THEN
                            l_affected_kpis := l_affected_kpis ||','|| '['||l_kpi_name||']';
                        END IF;
                    END IF;
                    l_is_kpi_affected := TRUE;
                END IF;

            END IF;
        END LOOP;

        CLOSE cr_indicdimset_for_dimgrp;
        IF(l_is_kpi_affected) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_IND_DIMOBJ_LIMIT');
            FND_MESSAGE.SET_TOKEN('NAME_LIST',l_affected_kpis);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        /********************************************************/



    IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;

    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN NO_DATA_FOUND THEN
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Update_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Update_Dimension ';
        END IF;

    WHEN OTHERS THEN
        IF (cr_bsc_dim_id%ISOPEN) THEN
            CLOSE cr_bsc_dim_id;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Update_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Update_Dimension ';
        END IF;

END Update_Dimension;
/*********************************************************************************
                        DELETE DIMENSION
*********************************************************************************/
PROCEDURE Delete_Dimension
(       p_commit                IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name        IN              VARCHAR2
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS

    l_delete                BOOLEAN := TRUE;
    l_bis_dimension_rec     BIS_DIMENSION_PUB.Dimension_Rec_Type;
    l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
    l_bsc_dimension_rec     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
    l_Dim_Obj_Short_Name    BIS_LEVELS.Short_Name%TYPE;
    l_count                 NUMBER;
    l_delete_count          NUMBER := 0;
    l_Bis_Group_ID          BIS_DIMENSIONS.Dimension_ID%TYPE;
    l_regions               VARCHAR2(32000);

    CURSOR  cr_bis_dim_short_name IS
    SELECT  dimension_id
           ,name
    FROM    BIS_DIMENSIONS_VL
    WHERE   short_name = p_dim_short_name;

    CURSOR  cr_bsc_dimension_id IS
    SELECT  dim_group_id
          , name
    FROM    BSC_SYS_DIM_GROUPS_VL
    WHERE   short_name = p_dim_short_name;

    CURSOR  cr_bis_dim_ids IS
    SELECT  Short_Name
    FROM    BIS_LEVELS
    WHERE   Dimension_Id = l_bis_dimension_rec.dimension_id;
BEGIN
    SAVEPOINT DeleteBSCDimensionsPMD;

    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_dim_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --UNASSIGNED group can't be deleted
    IF (p_dim_short_name = BSC_BIS_DIMENSION_PUB.Unassigned_Dim) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_B_CAN_NOT_DELETE_GROUP');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --The Dimension [dimension display name] cannot be deleted.  If it is being used in a Measure, Report or Key Performance Indicator.
    IF (cr_bis_dim_short_name%ISOPEN) THEN
        CLOSE cr_bis_dim_short_name;
    END IF;
    OPEN    cr_bis_dim_short_name;
    FETCH   cr_bis_dim_short_name
    INTO    l_bis_dimension_rec.dimension_id
          , l_bis_dimension_rec.Dimension_Name;
        IF (cr_bis_dim_short_name%ROWCOUNT = 0) THEN
            l_delete    :=  FALSE;
        END IF;
    CLOSE cr_bis_dim_short_name;

    --sync up Dimensions in BIS
    l_Bis_Group_ID  := BSC_BIS_DIMENSION_PUB.Get_Bis_Dimension_ID(p_dim_short_name);
    FOR cd IN cr_bis_dim_ids LOOP
        BSC_BIS_DIMENSION_PUB.Sync_Dimensions_In_Bis
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_Dim_Obj_Short_Name    =>  cd.Short_Name
            ,   p_Sync_Flag             =>  FALSE
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
    --assign values to bis records

    l_bis_dimension_rec.Dimension_Short_Name            :=  p_dim_short_name;

    IF (l_delete) THEN
        SELECT COUNT(1) INTO l_count
        FROM   BIS_INDICATOR_DIMENSIONS
        WHERE  DIMENSION_ID = l_bis_dimension_rec.dimension_id;
        IF (l_count <> 0) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_NOT_DELETE_DIM_IN_MEASURE');
            FND_MESSAGE.SET_TOKEN('SHORT_NAME',  l_bis_dimension_rec.Dimension_Name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        BIS_DIMENSION_PUB.Delete_Dimension
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL
            ,   p_Dimension_Rec         =>  l_bis_dimension_rec
            ,   x_return_status         =>  x_return_status
            ,   x_error_Tbl             =>  l_error_tbl
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            IF (l_error_tbl.COUNT > 0) THEN
                x_msg_data  :=  l_error_tbl(l_error_tbl.COUNT).Error_Description;
                IF(INSTR(x_msg_data, ' ')  =  0 ) THEN
                    FND_MESSAGE.SET_NAME('BIS',x_msg_data);
                    FND_MSG_PUB.ADD;
                    x_msg_data  :=  NULL;
                END IF;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        l_delete_count  := l_delete_count + 1;
    ELSE
        l_delete    :=  TRUE;
    END IF;

    IF (cr_bsc_dimension_id%ISOPEN) THEN
        CLOSE cr_bsc_dimension_id;
    END IF;
    OPEN    cr_bsc_dimension_id;
    FETCH   cr_bsc_dimension_id
    INTO    l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
          , l_bsc_dimension_rec.Bsc_Dim_Level_Group_Name;
        IF (cr_bsc_dimension_id%ROWCOUNT = 0) THEN
            l_delete    :=  FALSE;
        END IF;
    CLOSE cr_bsc_dimension_id;

    --assign values to bsc records

    l_bsc_dimension_rec.Bsc_Dim_Level_Group_short_name  :=  p_dim_short_name;

    l_regions := BSC_UTILITY.Is_Dim_In_AKReport(p_dim_short_name, BSC_UTILITY.c_DIMENSION);
    IF(l_regions IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_DIM_RPTASSOC_ERROR');
      FND_MESSAGE.SET_TOKEN('DIM_NAME', l_bsc_dimension_rec.Bsc_Dim_Level_Group_Name);
      FND_MESSAGE.SET_TOKEN('REPORTS_ASSOC', l_regions);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_delete) THEN
        -- START: Granular Locking to Lock Dimension Group when it is being deleted.
        SELECT COUNT(1) INTO l_count
        FROM   BSC_KPI_DIM_GROUPS
        WHERE  dim_group_id = l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id;
        IF (l_count <> 0) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_NOT_DELETE_DIMENSIONS');
            FND_MESSAGE.SET_TOKEN('SHORT_NAME', l_bsc_dimension_rec.Bsc_Dim_Level_Group_Name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        BSC_BIS_LOCKS_PUB.Lock_Dim_Group
        (    p_dim_group_id        => l_bsc_dimension_rec.Bsc_Dim_Level_Group_Id
            ,p_time_stamp          => NULL     -- Granular Locking
            ,x_return_status       => x_return_status
            ,x_msg_count           => x_msg_count
            ,x_msg_data            => x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN

             RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- END: Granular Locking to Lock Dimension Group when it is being deleted.
        -- Aditya added incremental changes
        -- This will create a structural changes to all the KPIs that are currently using the
        -- Groups, which is going to be deleted.
        BSC_DESIGNER_PVT.Dimension_Change(p_dim_short_name, BSC_DESIGNER_PVT.G_ActionFlag.GAA_Structure);
        -- End incremental changes.
        BSC_DIMENSION_GROUPS_PUB.Delete_Dimension_Group
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_Dim_Grp_Rec           =>  l_bsc_dimension_rec
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN

            RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        l_delete_count  := l_delete_count + 1;
    ELSE
        l_delete    :=  TRUE;
    END IF;
    IF (l_delete_count  = 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'EDW_DIMENSION'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;

    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (cr_bis_dim_short_name%ISOPEN) THEN
            CLOSE cr_bis_dim_short_name;
        END IF;
        IF (cr_bsc_dimension_id%ISOPEN) THEN
            CLOSE cr_bsc_dimension_id;
        END IF;
        ROLLBACK TO DeleteBSCDimensionsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (cr_bis_dim_short_name%ISOPEN) THEN
            CLOSE cr_bis_dim_short_name;
        END IF;
        IF (cr_bsc_dimension_id%ISOPEN) THEN
            CLOSE cr_bsc_dimension_id;
        END IF;
        ROLLBACK TO DeleteBSCDimensionsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN NO_DATA_FOUND THEN
        IF (cr_bis_dim_short_name%ISOPEN) THEN
            CLOSE cr_bis_dim_short_name;
        END IF;
        IF (cr_bsc_dimension_id%ISOPEN) THEN
            CLOSE cr_bsc_dimension_id;
        END IF;
        ROLLBACK TO DeleteBSCDimensionsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Delete_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Delete_Dimension ';
        END IF;

    WHEN OTHERS THEN
        IF (cr_bis_dim_short_name%ISOPEN) THEN
            CLOSE cr_bis_dim_short_name;
        END IF;
        IF (cr_bsc_dimension_id%ISOPEN) THEN
            CLOSE cr_bsc_dimension_id;
        END IF;
        ROLLBACK TO DeleteBSCDimensionsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIMENSION_PUB.Delete_Dimension ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Delete_Dimension ';
        END IF;

END Delete_Dimension;
/*******************************************************************************
********************************************************************************/

FUNCTION Is_More
(       p_dim_obj_short_names IN  OUT NOCOPY  VARCHAR2
    ,   p_dim_obj_name        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
BEGIN
    IF (p_dim_obj_short_names IS NOT NULL) THEN
        l_pos_ids           := INSTR(p_dim_obj_short_names,   ',');
        IF (l_pos_ids > 0) THEN
            p_dim_obj_name          :=  TRIM(SUBSTR(p_dim_obj_short_names,    1,    l_pos_ids - 1));

            p_dim_obj_short_names   :=  TRIM(SUBSTR(p_dim_obj_short_names,    l_pos_ids + 1));
        ELSE
            p_dim_obj_name          :=  TRIM(p_dim_obj_short_names);

            p_dim_obj_short_names   :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;
/*******************************************************************************
********************************************************************************/
FUNCTION Get_Dimension_Source
(
    p_short_Name IN VARCHAR2
) RETURN VARCHAR2 IS
    l_Data_Source BSC_SYS_DIM_LEVELS_B.Source%TYPE := NULL;

    CURSOR  c_Dim_Obj_Data_Source IS
    SELECT  VL.Source
    FROM    BSC_SYS_DIM_GROUPS_TL       TL
          , BSC_SYS_DIM_LEVELS_BY_GROUP GP
          , BSC_SYS_DIM_LEVELS_B        VL
    WHERE   TL.Dim_Group_Id =   GP.Dim_Group_Id
    AND     GP.Dim_Level_Id =   VL.Dim_Level_Id
    AND     TL.Short_Name   =   p_short_Name;
BEGIN
    IF (p_short_Name IS NULL) THEN
        RETURN NULL;
    ELSIF (BSC_BIS_DIMENSION_PUB.Unassigned_Dim = p_short_Name) THEN
        RETURN 'PMF';
    ELSE
        IF (c_Dim_Obj_Data_Source%ISOPEN) THEN
            CLOSE c_Dim_Obj_Data_Source;
        END IF;
        OPEN c_Dim_Obj_Data_Source;
            FETCH    c_Dim_Obj_Data_Source INTO l_Data_Source;
        CLOSE c_Dim_Obj_Data_Source;
    END IF;
    RETURN  l_Data_Source;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_Dim_Obj_Data_Source%ISOPEN) THEN
            CLOSE c_Dim_Obj_Data_Source;
        END IF;
        RETURN NULL;
END Get_Dimension_Source;
/*******************************************************************************
********************************************************************************/
--  Modified for Bug#3739872
FUNCTION Attmpt_Recr_View
(       p_dim_lvl_shrt_name            VARCHAR2
    ,   x_dim_lvl_name      OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
    l_return_status           VARCHAR2(2);
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
BEGIN
    -- Underlying View does not exist.
    IF (BSC_BIS_DIM_OBJ_PUB.Get_Table_Type_Value(p_dim_lvl_shrt_name) = -1) THEN
        BSC_BIS_DIM_OBJ_PUB.Refresh_BSC_PMF_Dim_View
        (     p_Short_Name        =>  p_dim_lvl_shrt_name
            , x_return_status     =>  l_return_status
            , x_msg_count         =>  l_msg_count
            , x_msg_data          =>  l_msg_data
        );
        -- If the view has still not been created, then we need to return FALSE
        IF(BSC_BIS_DIM_OBJ_PUB.Get_Table_Type_Value(p_dim_lvl_shrt_name) = -1) THEN
            RETURN FALSE;
        END IF;
    END IF;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END Attmpt_Recr_View;
/*******************************************************************************
********************************************************************************/
PROCEDURE Get_Lvl_Dtls
(       p_dim_lvl_shrt_name                 VARCHAR2
    ,   x_source                OUT NOCOPY  VARCHAR2
    ,   x_dim_lvl_name          OUT NOCOPY  VARCHAR2
    ,   x_dim_lvl_view_name     OUT NOCOPY  VARCHAR2
    ,   x_dim_lvl_pk_key        OUT NOCOPY  VARCHAR2
    ,   x_dim_lvl_name_col      OUT NOCOPY  VARCHAR2
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
BEGIN
    IF (p_dim_lvl_shrt_name IS NOT NULL) THEN
        SELECT source, name, level_values_view_name, 'ID', 'value'
        INTO    x_source
            ,   x_dim_lvl_name
            ,   x_dim_lvl_view_name
            ,   x_dim_lvl_pk_key
            ,   x_dim_lvl_name_col
        FROM    bis_levels_vl
        WHERE   UPPER(short_name) = UPPER(p_dim_lvl_shrt_name);
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NULL) THEN
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Get_Lvl_Dtls ';
        END IF;
END Get_Lvl_Dtls;
/*******************************************************************************
********************************************************************************/
PROCEDURE Get_Spec_Edw_Dtls
(       p_dim_lvl_shrt_name                 VARCHAR2
    ,   x_dim_lvl_view_name     OUT NOCOPY  VARCHAR2
    ,   x_dim_lvl_pk_key        OUT NOCOPY  VARCHAR2
    ,   x_dim_lvl_name_col      OUT NOCOPY  VARCHAR2
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) IS
    l_dim_lvl_sql       VARCHAR2(2000);
    l_dim_lvl_shrt_name VARCHAR2(30);
    l_dim_lvl_prefix    VARCHAR2(30);
BEGIN
    l_dim_lvl_sql := 'SELECT dim.DIM_NAME dimshortname, lvl.LEVEL_PREFIX prefix '||
                     ' FROM '||
                     ' edw_dimensions_md_v dim, edw_levels_md_v lvl '||
                     ' WHERE '||
                     ' lvl.DIM_ID = dim.DIM_ID AND '||
                     ' lvl.LEVEL_NAME = :1 ';
    BEGIN
        EXECUTE IMMEDIATE l_dim_lvl_sql
        INTO    l_dim_lvl_shrt_name, l_dim_lvl_prefix
        USING   p_dim_lvl_shrt_name;
        IF (INSTR(l_dim_lvl_shrt_name,'EDW_GL_ACCT') <> 0)  THEN -- return TRUE case
            x_dim_lvl_view_name     := p_dim_lvl_shrt_name;
            x_dim_lvl_pk_key        := l_dim_lvl_prefix||'_NAME';
            x_dim_lvl_name_col      := l_dim_lvl_prefix||'_NAME';
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_dim_lvl_view_name := NULL;
            x_dim_lvl_pk_key    := NULL;
            x_dim_lvl_name_col  := NULL;
    END;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NULL) THEN
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Get_Spec_Edw_Dtls ';
        END IF;
END Get_Spec_Edw_Dtls;
/*******************************************************************************
********************************************************************************/
PROCEDURE Get_Gene_Edw_Dtls
(       p_dim_lvl_shrt_name                     VARCHAR2
    ,   x_dim_lvl_view_name     IN  OUT NOCOPY  VARCHAR2
    ,   x_dim_lvl_pk_key            OUT NOCOPY  VARCHAR2
    ,   x_dim_lvl_name_col          OUT NOCOPY  VARCHAR2
    ,   x_return_status             OUT NOCOPY  VARCHAR2
    ,   x_msg_count                 OUT NOCOPY  NUMBER
    ,   x_msg_data                  OUT NOCOPY  VARCHAR2
) IS
    l_edw_sql           VARCHAR2(2000);
    TYPE                Recdc_value IS REF CURSOR;
    dl_value            Recdc_value;
BEGIN
    IF (x_dim_lvl_view_name IS NOT NULL) THEN
        x_dim_lvl_view_name := p_dim_lvl_shrt_name||'_LTC';
    END IF;
    l_edw_sql := ' select distinct level_table_col_name ' ||
                 '   from edw_level_Table_atts_md_v ' ||
                 '  where key_type=''UK'' and ' ||
                 '  upper(level_Table_name) = upper(:1) and ' ||
                 '  upper(level_table_col_name) like ''%PK_KEY%''';

    OPEN dl_value FOR l_edw_sql USING x_dim_lvl_view_name;
        FETCH dl_value INTO x_dim_lvl_pk_key;
    CLOSE dl_value;

    l_edw_sql := 'select level_table_col_name ' ||
                 '  from edw_level_Table_atts_md_v ' ||
                 ' where upper(level_Table_name) = upper(:1) and ' ||
                 '  (upper(level_table_col_name) like ''%DESCRIPTION%'' or ' ||
                 '   upper(level_table_col_name) like ''NAME%'') ';

    OPEN dl_value FOR l_edw_sql USING x_dim_lvl_view_name;
        FETCH dl_value INTO x_dim_lvl_name_col;
    CLOSE dl_value;
EXCEPTION
    WHEN OTHERS THEN
        IF (dl_value%ISOPEN) THEN
            CLOSE dl_value;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF (x_msg_data IS NULL) THEN
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.Get_Gene_Edw_Dtls ';
        END IF;
END Get_Gene_Edw_Dtls;

/***************************************************************************
    WARNING: -
    This function will return false if any changes Dimension-Objects and
    Dimension Property will result in color changes. This is designed to
    fulfil the UI screen need and not a generic function so it should not
    be called internally from any other APIs without proper impact analysis.
****************************************************************************/
FUNCTION is_KPI_Flag_For_DimProp_Change
(       p_dim_short_name        IN          VARCHAR2
    ,   p_dim_Obj_Short_Name    IN          VARCHAR2
    ,   p_Default_Value         IN          VARCHAR2
) RETURN VARCHAR2 IS
    l_Msg_Data              VARCHAR2(32000);
    l_msg_count             NUMBER;

    l_default_Value         BSC_SYS_DIM_LEVELS_BY_GROUP.Default_Value%TYPE;
    l_new_default_Value     BSC_SYS_DIM_LEVELS_BY_GROUP.Default_Value%TYPE;
    l_Prod_Mode             BSC_SYS_INIT.Property_Value%TYPE;
    l_Struct_Flag           BOOLEAN := FALSE;
    l_kpi_names             VARCHAR2(32000);
    l_Dim_Grp_Id            BSC_SYS_DIM_GROUPS_VL.Dim_Group_Id%TYPE;
    l_Source                BSC_SYS_DIM_LEVELS_B.Source%TYPE;
    l_indicator_list        VARCHAR2(32000);
    l_obj_name              bsc_kpis_vl.name%TYPE;
    l_ind                   bsc_kpis_vl.indicator%TYPE;
    l_sql                   VARCHAR2(2000);
    l_is_color_change       NUMBER;

    CURSOR  c_default_Value IS
    SELECT  A.Default_Value
         ,  A.Dim_Group_ID
         ,  C.Source
    FROM    BSC_SYS_DIM_LEVELS_BY_GROUP  A
         ,  BSC_SYS_DIM_GROUPS_VL        B
         ,  BSC_SYS_DIM_LEVELS_B         C
    WHERE   A.Dim_Group_Id     =    B.Dim_Group_Id
    AND     A.Dim_Level_Id     =    C.Dim_Level_Id
    AND     B.Short_Name       =    p_Dim_Short_Name
    AND     C.Short_Name       =    p_dim_Obj_Short_Name;

    CURSOR   c_dim_set_kpi IS
    SELECT   a.indicator indicator,
             a.kpi_measure_id,
             c.color_by_total
      FROM   bsc_db_dataset_dim_sets_v a,
             bsc_kpi_dim_levels_vl b,
             bsc_kpi_measure_props c
     WHERE   a.indicator =b.indicator
       AND   a.dim_set_id =b.dim_set_id
       AND   c.indicator = a.indicator
       AND   c.kpi_measure_id = a.kpi_measure_id
       AND   b.level_shortname = p_dim_Obj_Short_Name;

    TYPE ref_cursor IS   REF CURSOR;
    ref_cur              ref_cursor;
BEGIN

    FND_MSG_PUB.Initialize;
    IF (p_dim_short_name IS NULL) THEN
        RETURN NULL;
    END IF;
    SELECT  Property_Value INTO l_Prod_Mode
    FROM    BSC_SYS_INIT
    WHERE   PROPERTY_CODE ='SYSTEM_STAGE';
    IF (l_Prod_Mode <> '2') THEN
        RETURN NULL;
    END IF;
    IF ((p_Default_Value IS NULL) OR ((p_Default_Value <> 'C') AND (p_Default_Value <> 'T'))) THEN
        l_new_default_Value   := 'T';
    ELSE
        l_new_default_Value   :=  p_Default_Value;
    END IF;
    OPEN c_default_Value;
        FETCH   c_default_Value INTO l_default_Value, l_Dim_Grp_Id, l_Source;
    CLOSE c_default_Value;

    IF ((l_Source IS NULL) OR (l_Source <> 'BSC')) THEN
        RETURN NULL;
    END IF;

    IF (l_default_Value IS NULL) THEN
      l_default_Value := 'T';
    END IF;

    FOR cd IN c_dim_set_kpi LOOP
       --If KPI comparison setting is ALL
       l_is_color_change := is_color_change_required (l_default_Value, l_new_default_Value, cd.indicator, cd.kpi_measure_id);

       IF (l_is_color_change =1) THEN
         IF (l_indicator_list IS NULL) THEN
           l_indicator_list := cd.indicator;
         ELSE
           l_indicator_list := l_indicator_list || ',' || cd.indicator;
         END IF;
       END IF;

    END LOOP;


    IF (l_indicator_list IS NOT NULL) THEN
      IF(ref_cur%ISOPEN) THEN
        CLOSE ref_cur;
      END IF;

      l_sql := 'SELECT name, indicator FROM bsc_kpis_vl WHERE indicator IN (' || l_indicator_list || ') AND prototype_flag = 0 AND source_indicator IS NULL';

      OPEN ref_cur FOR l_sql;
      LOOP
        FETCH ref_cur INTO  l_obj_name, l_ind;
        EXIT WHEN ref_cur%NOTFOUND;
        IF (l_kpi_names IS NULL) THEN
          l_kpi_names := l_obj_name || '[' || l_ind || ']';
        ELSE
          l_kpi_names := l_kpi_names ||', '||l_obj_name || '[' || l_ind || ']';
        END IF;
      END LOOP;
      IF(ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
      END IF;
    END IF;

    IF (l_kpi_names IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_PMD_KPI_COLOR_INVALID');
        FND_MESSAGE.SET_TOKEN('INDICATORS', l_kpi_names);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    RETURN NULL;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_default_Value%ISOPEN) THEN
            CLOSE c_default_Value;
        END IF;
        IF(ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;
        IF (l_Msg_Data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  l_Msg_Data
            );
        END IF;

        RETURN l_Msg_Data;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_default_Value%ISOPEN) THEN
            CLOSE c_default_Value;
        END IF;
        IF(ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;

        IF (l_Msg_Data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  l_Msg_Data
            );
        END IF;

        RETURN l_Msg_Data;
    WHEN OTHERS THEN
        IF (c_default_Value%ISOPEN) THEN
            CLOSE c_default_Value;
        END IF;
        IF(ref_cur%ISOPEN) THEN
          CLOSE ref_cur;
        END IF;
        RETURN NULL;
END is_KPI_Flag_For_DimProp_Change;

/********************************************************************************
    WARNING : -
    This function will return false if any changes Dimension-Objects within a Dimension
    will result in structural changes. This is designed to fulfil the UI screen
    need and not a generic function so it should not be called internally from any
    other APIs without proper impact analysis.
********************************************************************************/
FUNCTION is_KPI_Flag_For_Dimension
(       p_Dim_Short_Name        IN          VARCHAR2
    ,   p_Dim_Obj_Short_Names   IN          VARCHAR2
) RETURN VARCHAR2 IS
    l_Msg_Data              VARCHAR2(32000);
    l_msg_count             NUMBER;

    l_Dim_Obj_Name          BSC_SYS_DIM_LEVELS_B.short_name%TYPE;
    l_Dim_Obj_Old_Name      BSC_SYS_DIM_LEVELS_B.short_name%TYPE;
    l_Dim_Grp_Id            BSC_SYS_DIM_GROUPS_VL.Dim_Group_Id%TYPE;
    l_Source                BSC_SYS_DIM_LEVELS_B.Source%TYPE;

    l_old_dim_objects       VARCHAR2(8000)  := NULL;
    l_temp_dim_objcts       VARCHAR2(8000);
    l_temp_var              VARCHAR2(8000);
    l_kpi_names             VARCHAR2(32000);

    l_passed_index          NUMBER  := 0;
    l_Struct_Flag           BOOLEAN := FALSE;
    l_flag                  BOOLEAN;

    CURSOR   c_Dim_Old_Objects IS
    SELECT   C.Short_Name
          ,  B.Dim_Level_Index
          ,  A.Dim_Group_Id
          ,  C.Source
    FROM     BSC_SYS_DIM_GROUPS_VL        A
          ,  BSC_SYS_DIM_LEVELS_BY_GROUP  B
          ,  BSC_SYS_DIM_LEVELS_B         C
    WHERE    A.Dim_Group_Id   =   B.Dim_Group_Id
    AND      C.Dim_Level_Id   =   B.Dim_Level_Id
    AND      A.Short_Name     =   p_Dim_Short_Name
    ORDER BY B.Dim_Level_Index;

    CURSOR   c_dim_set_kpi IS
    SELECT   DISTINCT B.Name||'['||B.Indicator||']' INDICATOR
    FROM     BSC_KPI_DIM_GROUPS     A
          ,  BSC_KPIS_VL            B
          ,  BSC_SYS_DIM_GROUPS_VL  C
    WHERE    A.INDICATOR         =  B.INDICATOR
    AND      B.share_flag       <>  2
    AND      A.Dim_Group_Id      =  C.Dim_Group_Id
    AND      C.Short_Name        =  p_Dim_Short_Name;
BEGIN

    FND_MSG_PUB.Initialize;
    IF (p_Dim_Short_Name IS NULL) THEN
        RETURN NULL;
    END IF;
    IF (NOT BSC_UTILITY.isBscInProductionMode()) THEN
        RETURN NULL;
    END IF;

    FOR cd IN c_Dim_Old_Objects LOOP
        l_flag          :=  TRUE;
        l_temp_var      :=  p_Dim_Obj_Short_Names;
        l_passed_index  :=  0;
        l_Source        :=  cd.Source;
        IF (l_Source <> 'BSC') THEN
            EXIT;
        END IF;
        IF (l_old_dim_objects IS NULL) THEN
            l_Dim_Grp_Id        := cd.Dim_Group_ID;
            l_old_dim_objects   := cd.Short_Name;
        ELSE
            l_old_dim_objects   := l_old_dim_objects||','||cd.Short_Name;
        END IF;
        WHILE (is_more(p_dim_obj_short_names   =>  l_temp_var
                    ,  p_dim_obj_name          =>  l_dim_obj_name
        )) LOOP
            IF ((l_dim_obj_name = cd.Short_Name) AND (cd.Dim_Level_Index = l_passed_index)) THEN
                l_flag  :=  FALSE;
                EXIT;
            END IF;
            l_passed_index  := l_passed_index + 1;
        END LOOP;
        IF (l_flag) THEN
            l_Struct_Flag   :=  TRUE;
            EXIT;
        END IF;
    END LOOP;
    IF ((l_Source IS NOT NULL) AND (l_Source <> 'BSC')) THEN
        RETURN NULL;
    END IF;

    IF (NOT l_Struct_Flag) THEN
        l_temp_var      :=  p_Dim_Obj_Short_Names;
        WHILE (is_more(p_dim_obj_short_names   =>  l_temp_var
                    ,  p_dim_obj_name          =>  l_dim_obj_name
        )) LOOP
            l_flag              :=  TRUE;
            l_temp_dim_objcts   :=  l_old_dim_objects;
            WHILE (is_more(p_dim_obj_short_names   =>  l_temp_dim_objcts
                        ,  p_dim_obj_name          =>  l_Dim_Obj_Old_Name
            )) LOOP
                IF (l_Dim_Obj_Old_Name = l_dim_obj_name) THEN
                    l_flag  :=  FALSE;
                    EXIT;
                END IF;
            END LOOP;
            IF (l_flag) THEN

                l_Struct_Flag   := TRUE;
                EXIT;
            END IF;
        END LOOP;
    END IF;
    IF (l_Struct_Flag) THEN
        FOR cd IN c_dim_set_kpi LOOP
            IF (l_kpi_names IS NULL) THEN
                l_kpi_names := cd.Indicator;
            ELSE
                l_kpi_names := l_kpi_names||', '||cd.Indicator;
            END IF;
        END LOOP;
    END IF;

    IF ((l_Struct_Flag) AND (l_kpi_names IS NOT NULL)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_PMD_KPI_STRUCT_INVALID');
        FND_MESSAGE.SET_TOKEN('INDICATORS', l_kpi_names);
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

        RETURN l_Msg_Data;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (l_Msg_Data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  l_msg_count
               ,   p_data      =>  l_Msg_Data
            );
        END IF;

        RETURN l_Msg_Data;
    WHEN OTHERS THEN

        RETURN NULL;
END is_KPI_Flag_For_Dimension;
--=============================================================================
FUNCTION is_config_impact_dim
(       p_Dim_Short_Name        IN          VARCHAR2
        ,   p_Dim_Obj_Short_Names   IN          VARCHAR2
) RETURN VARCHAR2 IS
    l_dim_obj_short_names             VARCHAR2(32000);
    l_count_dim_objs                  NUMBER := 0;
    l_count_temp                      NUMBER;
    l_total_count                     NUMBER := 0;
    l_dim_short_name                  VARCHAR2(32000);
    l_kpi_id                          NUMBER;
    l_dim_set_id                      NUMBER;
    l_minus_count                     NUMBER;
    l_plus_count                      NUMBER;
    l_Msg_Data                        VARCHAR2(32000);
    l_msg_count                       NUMBER;
    l_found_dimobj                    BOOLEAN;
    l_dimobj_temp                     VARCHAR2(32000);
    TYPE index_by_table IS Record
    (
           p_no_dim_object       VARCHAR2(32000)
    );
    TYPE index_by_table_type IS TABLE OF index_by_table INDEX BY BINARY_INTEGER;
    TYPE index_by_table_kpi IS Record
    (
            kpi_id     NUMBER
        ,   dim_set_id NUMBER
    );
    TYPE index_by_table_type_kpi IS TABLE OF index_by_table_kpi INDEX BY BINARY_INTEGER;
    dim_objs_array index_by_table_type;
    kpi_dim_set_array index_by_table_type_kpi;
    dim_objs_in_dim index_by_table_type;

    CURSOR cr_kpidimset_dim IS
    SELECT   A. INDICATOR
           , A.DIM_SET_ID
    FROM     BSC_KPI_DIM_GROUPS A
           , BSC_SYS_DIM_GROUPS_VL B
    WHERE    A.DIM_GROUP_ID = B.DIM_GROUP_ID
    AND      B.SHORT_NAME =  p_Dim_Short_Name;

    CURSOR cr_dimobj_in_dimset IS
    SELECT B.SHORT_NAME
    FROM   BSC_SYS_DIM_LEVELS_B B
          ,BSC_KPI_DIM_LEVEL_PROPERTIES KDL
    WHERE  B.DIM_LEVEL_ID = KDL.DIM_LEVEL_ID
    AND    KDL.indicator = l_kpi_id
    AND    KDL.dim_set_id = l_dim_set_id;

    CURSOR cr_dimobjs_in_dim  IS
    SELECT BL.SHORT_NAME
    FROM BSC_SYS_DIM_LEVELS_BY_GROUP B
          ,BSC_SYS_DIM_GROUPS_VL  VL
          ,BSC_SYS_DIM_LEVELS_B  BL
    WHERE VL.DIM_GROUP_ID = B.DIM_GROUP_ID
    AND   BL.DIM_LEVEL_ID = B.DIM_LEVEL_ID
    AND   VL.SHORT_NAME = p_Dim_Short_Name;

    i NUMBER;
    l_no_dim_object       VARCHAR2(32000);

BEGIN
    FND_MSG_PUB.Initialize;
    l_dim_obj_short_names := p_Dim_Obj_Short_Names;
    WHILE(Is_More(p_dim_obj_short_names=>l_dim_obj_short_names,p_dim_obj_name=> l_dim_short_name)) LOOP
      l_count_dim_objs:= l_count_dim_objs +1;
    END LOOP;

    IF(l_count_dim_objs > BSC_BIS_KPI_MEAS_PUB.Config_Limit_Dim) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_PMD_IMPACT_KPI_SPACE');
      FND_MESSAGE.SET_TOKEN('CONTINUE', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'YES'), TRUE);
      FND_MESSAGE.SET_TOKEN('CANCEL', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'NO'), TRUE);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN cr_dimobjs_in_dim;
    -- bug#3405498 meastmon 28-jan-2004: The following is not supported in 8i
    --FETCH cr_dimobjs_in_dim  BULK COLLECT INTO dim_objs_in_dim;
    dim_objs_in_dim.delete;
    i := 0;
    LOOP
        FETCH cr_dimobjs_in_dim INTO l_no_dim_object;
        EXIT WHEN cr_dimobjs_in_dim%NOTFOUND;
        i:= i+1;
        dim_objs_in_dim(i).p_no_dim_object := l_no_dim_object;
    END LOOP;
    CLOSE cr_dimobjs_in_dim;


    IF(p_Dim_Obj_Short_Names IS NOT NULL) THEN
      OPEN cr_kpidimset_dim ;
      -- bug#3405498 meastmon 28-jan-2004: The following is not supported in 8i
      --FETCH cr_kpidimset_dim  BULK COLLECT INTO kpi_dim_set_array;
      kpi_dim_set_array.delete;
      i:= 0;
      LOOP
          FETCH cr_kpidimset_dim INTO l_kpi_id, l_dim_set_id;
          EXIT WHEN cr_kpidimset_dim%NOTFOUND;
          i:= i+1;
          kpi_dim_set_array(i).kpi_id := l_kpi_id;
          kpi_dim_set_array(i).dim_set_id := l_dim_set_id;
      END LOOP;
      CLOSE cr_kpidimset_dim;

      FOR index_loop IN 1..(kpi_dim_set_array.COUNT) LOOP
        l_kpi_id := kpi_dim_set_array(index_loop).kpi_id;
        l_dim_set_id  := kpi_dim_set_array(index_loop).dim_set_id;
        l_count_temp  :=  l_count_dim_objs;
        l_plus_count  := 0;
        l_minus_count := 0;
        IF(cr_dimobj_in_dimset%ISOPEN) THEN
          CLOSE cr_dimobj_in_dimset;
        END IF;
        OPEN cr_dimobj_in_dimset;
        -- bug#3405498 meastmon 28-jan-2004: The following is not supported in 8i
        --FETCH cr_dimobj_in_dimset  BULK COLLECT INTO dim_objs_array;
        dim_objs_array.delete;
        i:= 0;
        LOOP
            FETCH cr_dimobj_in_dimset INTO l_no_dim_object;
            EXIT WHEN cr_dimobj_in_dimset%NOTFOUND;
            i:= i+1;
            dim_objs_array(i).p_no_dim_object := l_no_dim_object;
        END LOOP;
        CLOSE cr_dimobj_in_dimset;

        l_dim_obj_short_names := p_Dim_Obj_Short_Names;

        WHILE(Is_More(p_dim_obj_short_names=>l_dim_obj_short_names,p_dim_obj_name=> l_dim_short_name)) LOOP

          l_found_dimobj := FALSE;
          FOR index_loop IN 1..(dim_objs_in_dim.COUNT) LOOP

            IF(l_dim_short_name = dim_objs_in_dim(index_loop).p_no_dim_object) THEN
              l_found_dimobj := TRUE;
            END IF;
          END LOOP;
          IF(NOT l_found_dimobj ) THEN
            l_plus_count := l_plus_count + 1;
          END IF;

        END LOOP;
        l_dim_obj_short_names := ','||p_Dim_Obj_Short_Names||',';
        FOR index_loop IN 1..(dim_objs_in_dim.COUNT) LOOP
        l_dimobj_temp         := ','||dim_objs_in_dim(index_loop).p_no_dim_object||',';
          IF(Instr(l_dim_obj_short_names, l_dimobj_temp) = 0) THEN
            l_minus_count := l_minus_count + 1;

          END IF;
        END LOOP;

        IF(( (dim_objs_array.COUNT)+l_plus_count-l_minus_count ) > BSC_BIS_KPI_MEAS_PUB.Config_Limit_Dim ) THEN

          FND_MESSAGE.SET_NAME('BSC','BSC_PMD_IMPACT_KPI_SPACE');
          FND_MESSAGE.SET_TOKEN('CONTINUE', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'YES'), TRUE);
          FND_MESSAGE.SET_TOKEN('CANCEL', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'NO'), TRUE);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
    END IF;
    IF(cr_dimobjs_in_dim%ISOPEN) THEN
      CLOSE cr_dimobjs_in_dim;
    END IF;
    IF(cr_kpidimset_dim%ISOPEN) THEN
      CLOSE cr_kpidimset_dim;
    END IF;
    IF(cr_dimobj_in_dimset%ISOPEN) THEN
      CLOSE cr_dimobj_in_dimset;
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
       IF(cr_kpidimset_dim%ISOPEN) THEN
         CLOSE cr_kpidimset_dim;
       END IF;
       IF(cr_dimobj_in_dimset%ISOPEN) THEN
         CLOSE cr_dimobj_in_dimset;
       END IF;
       IF(cr_dimobjs_in_dim%ISOPEN) THEN
         CLOSE cr_dimobjs_in_dim;
       END IF;
     RETURN  l_Msg_Data;
     WHEN OTHERS THEN
       IF(cr_kpidimset_dim%ISOPEN) THEN
         CLOSE cr_kpidimset_dim;
       END IF;
       IF(cr_dimobj_in_dimset%ISOPEN) THEN
         CLOSE cr_dimobj_in_dimset;
       END IF;
       IF(cr_dimobjs_in_dim%ISOPEN) THEN
         CLOSE cr_dimobjs_in_dim;
       END IF;

     RETURN NULL;
END is_config_impact_dim;
--============================================================================================

/**************************************************************************************************************
   Check if the Dimension/Dimensions is Empty
****************************************************************************************************************/
FUNCTION Is_Dim_Empty
(
 p_dim_short_names IN VARCHAR

) RETURN VARCHAR2 IS
    l_count                 NUMBER;
    l_dim_group_id          BSC_SYS_DIM_GROUPS_TL.Dim_Group_ID%TYPE;
    l_dim_short_names       VARCHAR2(32000);
    l_dim_short_name        BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
    l_return_value          VARCHAR2(1);



BEGIN
    l_dim_short_names :=  p_dim_short_names;
    l_return_value :=FND_API.G_FALSE;

     WHILE (is_more(p_dim_obj_short_names   =>  l_dim_short_names
                   , p_dim_obj_name    =>  l_dim_short_name )
   ) LOOP

   l_dim_group_id := BSC_BIS_DIMENSION_PUB.Get_Bsc_Dimension_ID(l_dim_short_name);

   SELECT  count(dim_level_id) into l_count
   FROM    BSC_SYS_DIM_LEVELS_BY_GROUP
   WHERE   dim_group_id = l_dim_group_id;

   IF (l_count =0) THEN

       l_return_value:= FND_API.G_TRUE;
       EXIT;
   END IF;
     END LOOP;

RETURN l_return_value; --Will return FND_API.G_TRUE even if 1 Dimension is Empty

END Is_Dim_Empty;


/**************************************************************************************************************
   Check if the Dimension/Dimensions has Single Dimension Object
****************************************************************************************************************/
FUNCTION Dim_With_Single_Dim_Obj
(
 p_dim_short_names IN VARCHAR

) RETURN VARCHAR2 IS
    l_count                 NUMBER;
    l_dim_group_id          BSC_SYS_DIM_GROUPS_TL.Dim_Group_ID%TYPE;
    l_dim_short_names       VARCHAR2(32000);
    l_dim_name              BSC_SYS_DIM_GROUPS_TL.Name%TYPE;
    l_dim_short_name        BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
    l_return_value          VARCHAR2(32000);



BEGIN



    l_dim_short_names :=  p_dim_short_names;
    l_return_value :='';





     WHILE (is_more( p_dim_obj_short_names   =>  l_dim_short_names
                   , p_dim_obj_name          =>  l_dim_short_name )
   ) LOOP

   l_dim_group_id := BSC_BIS_DIMENSION_PUB.Get_Bsc_Dimension_ID(l_dim_short_name);




   l_dim_name:= BSC_BIS_DIMENSION_PUB.Get_Bsc_Dimension_Name(l_dim_short_name);



   SELECT  count(dim_level_id) into l_count
            FROM    BSC_SYS_DIM_LEVELS_BY_GROUP
            WHERE   dim_group_id = l_dim_group_id;

           IF ((l_count =1) AND (BSC_BIS_DIMENSION_PUB.Is_Dimension_in_Ind( l_dim_group_id))) THEN


                 l_return_value:= l_return_value||l_dim_name||',';
           END IF;


       END LOOP;




RETURN l_return_value; --Will return Dimension Names of all Dimensions with Single Dimension Object

END Dim_With_Single_Dim_Obj;
/**************************************************************************************************************
   Summry: Check the passing list of dimensions, cascading remove empty BSC dimension from dim set
   Called in: 1.) BSC_BIS_DIMENSION_PUB.Assign_Unassign_Dim_Objs 2.) BSC_BIS_DIM_OBJ_PUB.Assign_Unassign_Dimensions
****************************************************************************************************************/
PROCEDURE Remove_Empty_Dims_For_DimSet
(   p_commit           IN             VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
  , p_dim_short_names  IN             VARCHAR2
  , p_time_stamp       IN             VARCHAR2   := NULL  -- Granular Locking
  , x_return_status         OUT    NOCOPY   VARCHAR2
  , x_msg_count             OUT    NOCOPY   NUMBER
  , x_msg_data              OUT    NOCOPY   VARCHAR2
) IS

    l_count                 NUMBER;
    l_dim_group_id          BSC_SYS_DIM_GROUPS_TL.Dim_Group_ID%TYPE;
    l_dim_short_names       VARCHAR2(32000);
    l_dim_short_name        BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
    l_source                BSC_SYS_DIM_LEVELS_B.Source%TYPE;

    CURSOR   c_dim_set_kpi IS
    SELECT   DISTINCT A.indicator  INDICATOR
          ,  A.dim_set_id          DIM_SET_ID
          ,  A.Dim_Group_Index
    FROM     BSC_KPI_DIM_GROUPS A
          ,  BSC_KPIS_B         B
    WHERE    A.INDICATOR    =  B.INDICATOR
    AND      B.share_flag  <>  2
    AND      A.dim_group_id =  l_dim_group_id
    ORDER BY A.Dim_Group_Index;

    CURSOR  c_dim_level_count IS
    SELECT  count(dim_level_id)
    FROM    BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE   dim_group_id = l_dim_group_id;

BEGIN

  l_dim_short_names :=  p_dim_short_names;


   -- For each dimension
   WHILE (is_more(p_dim_obj_short_names   =>  l_dim_short_names
               , p_dim_obj_name    =>  l_dim_short_name )
   ) LOOP
        l_source :=BSC_BIS_DIMENSION_PUB.Get_Dimension_Source(l_dim_short_name);


        -- check if it is bsc dimension
        IF ( l_source= 'BSC' or l_source is NULL) THEN --only need to unassign dimension from dim set for BSC

            l_dim_group_id := BSC_BIS_DIMENSION_PUB.Get_Bsc_Dimension_ID(l_dim_short_name);


            -- check if empty dimension
            SELECT  count(dim_level_id) into l_count
            FROM    BSC_SYS_DIM_LEVELS_BY_GROUP
            WHERE   dim_group_id = l_dim_group_id;

            IF (l_count =0) THEN
                -- Cascading unassign empty dimension from Objectives-dim sets
                FOR cd IN c_dim_set_kpi LOOP

                    BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_From_Dim_Set
                        (       p_commit                =>  FND_API.G_FALSE
                            ,   p_kpi_id                =>  cd.Indicator
                            ,   p_dim_set_id            =>  cd.Dim_Set_Id
                            ,   p_dim_short_names       =>  l_dim_short_name
                            ,   p_time_stamp            =>  p_time_stamp
                            ,   x_return_status         =>  x_return_status
                            ,   x_msg_count             =>  x_msg_count
                            ,   x_msg_data              =>  x_msg_data
                        );
                    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                END LOOP;
             END IF;
         END IF;

   END LOOP;

   IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;

   END IF;

END Remove_Empty_Dims_For_DimSet;
/****************************************************************************************
  this function checks the invalid dimenison objects in dimension
  dimension should not have both autogenerated and existing source dimension object at a time
****************************************************************************************/
FUNCTION check_sametype_dimobjs
(       p_dim_name              IN              VARCHAR2
    ,   p_dim_short_name        IN              VARCHAR2
    ,   p_dim_short_names       IN              VARCHAR2
    ,   p_Restrict_Dim_Validate IN              VARCHAR2 := NULL
    ,   x_dim_type              OUT    NOCOPY   VARCHAR2
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) RETURN BOOLEAN
IS

    CURSOR C_SOURCE_DIM IS
    SELECT source,name
    FROM   bsc_sys_dim_levels_vl
    WHERE  INSTR(','||p_dim_short_names ||',' , ','||short_name||',') > 0;

    l_source             VARCHAR2(20);
    l_true               BOOLEAN;
    l_dim_obj_name       VARCHAR2(32000);
    l_dim_name           VARCHAR2(32000);
    l_diff_source_cnt    NUMBER;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_true  := FALSE;

    -- added to relax checking for mixed type of Dimension Objects within a Dimension
    -- for Autogenerated reports and removing the disctiction, BSC 5.3
    IF (p_Restrict_Dim_Validate IS NOT NULL OR BIS_UTILITIES_PUB.Enable_Generated_Source_Report = FND_API.G_FALSE) THEN
        SELECT count(distinct(source))
        INTO   l_diff_source_cnt
        FROM   bsc_sys_dim_levels_vl
        WHERE  INSTR(','||p_dim_short_names ||',',','||short_name||',') > 0;

        IF(l_diff_source_cnt > 1) THEN
            l_true  :=  TRUE;
            FOR CD IN C_SOURCE_DIM LOOP
                l_dim_obj_name := CD.NAME;
                IF(l_source IS NULL) THEN
                    l_source := CD.source;
                END IF;
                IF ((p_dim_short_name = BSC_BIS_DIMENSION_PUB.Unassigned_Dim) AND
                     (l_source = 'BSC')) THEN

                    EXIT;
                END IF;

                IF(l_source <> CD.source) then
                    EXIT;

                END IF;
            END LOOP;

        END IF;

        IF (l_true) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_DIM_DIMOBJ_MIXED_TYPE');
            FND_MESSAGE.SET_TOKEN('DIMENSION',  p_dim_name);
            FND_MESSAGE.SET_TOKEN('DIM_OBJECT', l_dim_obj_name);
            FND_MSG_PUB.ADD;
        ELSE
            SELECT distinct(NVL(source, 'BSC'))
            INTO   x_dim_type
            FROM   bsc_sys_dim_levels_vl
            WHERE  INSTR(','||p_dim_short_names ||',',','||short_name||',') > 0;
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    RETURN l_true;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NULL) THEN
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.is_Valid_Dim_Grp_Rels ';
        END IF;

        RETURN l_true;
END check_sametype_dimobjs ;

/*********************************************************************************
         API TO Check if Dimension is Assigned to any KPI.
         Return 'T' if there's at least one Objective assigned, 'F' otherwise.
*********************************************************************************/
FUNCTION Is_Objective_Assigned
(
   p_dim_short_name     IN      VARCHAR2
) RETURN VARCHAR2
IS
l_retval    VARCHAR2(1) := 'T'; --be protective, set to true by default
l_count     NUMBER;
BEGIN
  SELECT COUNT(1) INTO l_count
  FROM   BSC_KPI_DIM_GROUPS    KG,
         BSC_SYS_DIM_GROUPS_VL G
  WHERE  KG.DIM_GROUP_ID = G.DIM_GROUP_ID
  AND    G.SHORT_NAME    = p_dim_short_name;

  IF (l_count = 0) THEN
    l_retval := 'F';
  END IF;

  RETURN l_retval;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'T';
END Is_Objective_Assigned;


/***************************************************************

  The following API determines whether a KPI needs color change
  prototype flag to set

 ****************************************************************/

FUNCTION is_color_change_required (
   p_old_default    IN  VARCHAR2,
   p_new_default    IN  VARCHAR2,
   p_obj_id         IN  bsc_kpis_b.indicator%TYPE,
   p_kpi_measure_id IN  bsc_kpi_measure_props.kpi_measure_id%TYPE
 )
RETURN NUMBER IS
l_color_change    NUMBER;
CURSOR   c_kpi_color IS
    SELECT   c.color_by_total
      FROM   bsc_kpi_measure_props c
     WHERE   c.indicator = p_obj_id
       AND   c.kpi_measure_id = p_kpi_measure_id;

BEGIN
   l_color_change := 0;
   FOR cd IN c_kpi_color LOOP

       --If KPI comparison setting is ALL
         IF (cd.color_by_total = 1 ) THEN
            IF (p_new_default = 'C') THEN
              l_color_change := 1;
            END IF;

         --If KPI comparison setting is WORST MEMBER COLOR
         ELSIF (cd.color_by_total = 0 ) THEN
            IF (p_old_default = 'C' AND p_new_default = 'T') THEN
              l_color_change := 1;
            END IF;
         END IF;
         EXIT;
   END LOOP;
   RETURN l_color_change;
END is_color_change_required;

/********************************************************************
   The following API returns 1 if the objective needs color change
   and returns 0 if the objective does not need color change
   ***************************************************************/

FUNCTION get_kpi_flag_change (
   p_old_default        IN            VARCHAR2,
   p_new_default        IN            VARCHAR2,
   p_indicator          IN            bsc_kpis_b.indicator%TYPE,
   p_dim_obj_objs_tbl   IN OUT NOCOPY BSC_BIS_DIMENSION_PUB.dimobj_obj_kpis_tbl_type
 )
RETURN NUMBER IS

l_color_change      NUMBER;
l_count             NUMBER;
l_result            NUMBER;
l_is_col_change     NUMBER;
l_ind               NUMBER;
l_mes_id            NUMBER;
l_color_rollup_type VARCHAR2(100);
l_obj_proto_flag    NUMBER;
l_default_kpi       NUMBER;
l_kpi_weight        NUMBER;

BEGIN

  SELECT count(0) INTO l_count
  FROM bsc_kpis_b WHERE
  indicator = p_indicator;
  l_result := BSC_DESIGNER_PVT.G_ActionFlag.Normal;

  IF (l_count = 1) THEN
    FOR i IN 0..(p_dim_obj_objs_tbl.COUNT-1) LOOP
       IF (p_indicator = p_dim_obj_objs_tbl(i).p_indicator) THEN

         l_is_col_change := is_color_change_required(
                                      p_old_default   =>    p_old_default,
                                      p_new_default   =>    p_new_default,
                                      p_obj_id        =>    p_dim_obj_objs_tbl(i).p_indicator,
                                      p_kpi_measure_id=>    p_dim_obj_objs_tbl(i).p_kpi_measure_id
                                     );

         IF (l_is_col_change = 1) THEN
           l_result := BSC_DESIGNER_PVT.G_ActionFlag.GAA_Color;
         END IF;
       END IF;
    END LOOP;

  END IF;

  RETURN l_result;

END get_kpi_flag_change;
END BSC_BIS_DIMENSION_PUB;

/
