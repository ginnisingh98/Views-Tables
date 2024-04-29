--------------------------------------------------------
--  DDL for Package Body BSC_BIS_DIM_OBJ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_BIS_DIM_OBJ_PUB" AS
/* $Header: BSCDPMDB.pls 120.30 2008/01/09 13:07:04 lbodired ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCDPMDB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper for Dimensions, part of PMD APIs                  |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 14-FEB-2003 PAJOHRI  Created.                                         |
REM | 15-MAY-2003 ADRAO    Added Incremental Changes                        |
REM | 06-JUN-2003 ADRAO    Added Granular Locking                           |
REM | 17-JUL-2003 ADRAO    Bug#3054935 Changed following procedures         |
REM |                      BSC_BIS_KPI_MEAS_PUB.Assign_Dims_To_Dim_Set()    |
REM |                      BSC_BIS_KPI_MEAS_PUB.Unassign_Dims_To_Dim_Set()  |
REM |                      to use 'NULL' timestamp                          |
REM | 17-JUL-2003 PAJOHRI  Bug #3053701, Fixed API Create_Pmf_Views         |
REM | 29-JUL-2003 PAJOHRI  Bug #3049659                                     |
REM | 11-AUG-2003 ADEULGAO fixed bug#3081595                                |
REM | 12-AUG-2003 ADRAO    Added new index for Loader Performance for       |
REM |                      for Dimension Object tables  Bug#3090828         |
REM | 20-OCT-2003 PAJOHRI  Bug #3179995                                     |
REM | 20-OCT-2003 PAJOHRI  Bug #3179995                                     |
REM | 29-OCT-2003 PAJOHRI  Bug #3120190                                     |
REM | 04-NOV-2003 PAJOHRI  Bug #3152258                                     |
REM | 04-NOV-2003 PAJOHRI  Bug #3220613                                     |
REM | 04-NOV-2003 PAJOHRI  Bug #3232366                                     |
REM | 04-NOV-2003 PAJOHRI  Bug #3262631                                     |
REM | 08-DEC-2003 KYADAMAK Bug #3225685                                     |
REM | 24-DEC-2003 MEASTMON Bug #3337923                                     |
REM | 26-FEB-2004 MEASTMON Bug #3458428                                     |
REM | 27-FEB-2004 adeulgao fixed bug#3431750                                |
REM | 02-MAR-2004 ankgoel  Bug #3464470                                     |
REM | 29-MAR-2004 PAJOHRI  Bug #3530886, Modified tablespaces for tables    |
REM | 30-MAR-2004 KYADAMAK BUG #3516466 Passing default appid as 271        |
REM | 12-APR-2004 PAJOHRI  Bug #3426566, modified the logic to use dimension|
REM |                      'UNASSIGNED' always if there if no Dimension/    |
REM |                      Dimension Object association for PMF and retain  |
REM |                      'All Enable' flag                                |
REM | 19-APR-2004 PAJOHRI  Bug #3583394, fix BIS_LEVELS UI Issues           |
REM |                      Other issues related to Autonmous Transactions,  |
REM |                      and performance also fixed,                      |
REM | 23-APR-2004 ASHANKAR  Bug #3518610,Added the fucntion Validate        |
REM |                       listbutton                                      |
REM | 16-JUN-2004 PAJOHRI   Bug #3659486, to support 'All Enable' flag in   |
REM |                       Dimension/Dimension Object Association Page     |
REM | 07-JUL-2004 WLEUNG    Bug 3751932, always create/replace PMF View     |
REM |                       modified Initialize_Pmf_Recs()                  |
REM | 09-AUG-2004 sawu      Used c_BSC_DIM_OBJ in create_dim_object         |
REM | 11-AUG-2004 sawu     Added create_dim_obj() for bug#3819855 with      |
REM |                      p_is_default_short_name                          |
REM | 17-AUG-2004 ADRAO    Modified Create_Pmf_Views to work with BSC511    |
REM |                      at the code level for Bug#3836170                |
REM |25-AUG-2004 visuri    Modified Initialize_Bsc_Recs() and               |
REM |                      Update_Dim_Object() for bug#3842366              |
REM | 17-AUG-2004 wleung   modified Bug#3784852 Assign_Unassign_Dimensions  |
REM | 09-SEP-2004 visuri   Shifted Remove_Empty_Dims_For_DimSet() from      |
REM |                      BSC_BIS_KPI_MEAS_PUB to BSC_BIS_DIMENSION_PUB    |
REM | 14-SEP-2004 KYADAMAK added function get_valid_ddlentry_frm_name()     |
REM | 08-OCT-2004 rpenneru added Modified for bug#3939995                   |
REM | 21-OCT-2004 akoduri added Modified for bug#3930280                    |
REM | 03-FEB-2005 kyadamak modified for the bug#4091924                     |
REM | 08-Feb-04   skchoudh  Enh#3873195 drill_to_form_function column       |
REM |                  is added                                             |
REM | 14-FEB-2005 ashankar modified Alter_One_By_N_Tables and               |
REM |                      Alter_M_By_N_Tables.Added the cascading logic    |
REM |                      to update RELATION_COL in BSC_SYS_DIM_LEVEL_RELS |
REM | 15-FEB-05   ppandey   Enh #4016669, support ID, Value for Autogen DO  |
REM | 16-FEB-2005 ashankar  Bug#4184438 Added the Synch Up API              |
REM |                       BSC_SYNC_MVLOGS.Sync_dim_table_mv_log           |
REM | 11-Mar-05   ankgoel   Enh#2690720 - AG Report enh                     |
REM | 30-Mar-05   ankgoel   Support 'All' enable/disable for BSC dim objects|
REM |                       from Report Designer                            |
REM | 31-MAR-05   adrao     Modified API check_sametype_dims to remove      |
REM |                       disctinction betweem BSC and BIS Dimesion Objs  |
REM |  08-APR-2005 kyadamak generating unique master table for PMF dimension|
REM |                       objects for the bug# 4290359                    |
REM |  02-May-2005 visuri   Modified for Bug#4323383                        |
REM |  18-Jul-2005 ppandey  Enh #4417483, Restrict Internal/Calendar Dims   |
REM |  20-Jul-2005 ppandey  Bug #4495539, MIXED Dim Obj not allowed from DD |
REM |  22-Jul-2005 kyadamak Modified for bug#4091924                        |
REM |  09-AUG-2005 adrao    Fixed Bug#4383962 for prototype value gen       |
REM |  11-AUG-2005 ppandey  Bug #4324947 Validation for Dim,Dim Obj in Rpt  |
REM |  27-Sep-2005 ankgoel  Bug#4625598,4626579 Uptake common API to get dim|
REM |                       level values                                    |
REM |  27-SEP-2005 ashankar Bug#4630859  Removed the duplicate objectives   |
REM |  28-SEP-2005 ashankar Bug#4630892  Added a new API is_Obj_Display_Frmt_Change |
REM |                       which will check for format changes and the API |
REM |                       is_KPI_Flag_For_DimObject check for Structural  |
REM |                       Changes                                         |
REM | 25-OCT-2005 kyadamak  Removed literals for Enhancement#4618419        |
REM | 27-DEC-2005 kyadamak  Calling BIA API for bug#4875047                 |
REM | 02-Jan-2006   akoduri Bug#4611303 - Support For Enable/Disable All    |
REM |                       In Report Designer                              |
REM | 06-Jan-2006   akoduri   Enh#4739401 - Hide Dimensions/Dim Objects     |
REM | 13-jan-2005 ashankar  Bug#4947293  calling the API sync_dimension_table|
REM |                       dynamically                                     |
REM | 31-JAN-2006 adrao     Added APIs                                      |
REM |                            - Is_Recursive_Relationship                |
REM |                            - Get_Unique_Level_Pk_Col                  |
REM |                                                                       |
REM |                       Also modified the logic to ensure that when a   |
REM |                       PMF DO is under a recursive relationship, the   |
REM |                       corresponding BSC View is also changed          |
REM | 10-FEB-2006 akoduri   Bug#4997042 Cascade 'All' property from dim     |
REM |                       designer to dim groups of Reports               |
REM | 15-FEB-2006 visuri    bug#4757375 Calendar Create Performance Issue   |
REM | 31-MAR-2006 akoduri   Bug #5048186 No View creation for obsoleted     |
REM |                       BIS Dimension objects                           |
REM | 26-Apr-2006  psomesul  Enh#5124125 - Creating BSC wrapper view of a   |
REM |                                 BIS type Dim. Obj.                    |
REM |  15-JUN-2006 ashankar Bug#5254737 Made changes to Create_Dim_Object   |
REM |                       Method.Removed the parameter value 'TRUE' in    |
REM |                       FND_MESSAGE.SET_TOKEN API                       |
REM | 20-FEB-2006  akoduri  Bug #5880618 Validate_PMF_Base_View API is      |
REM |                       is failing when more than one parent is passed  |
REM | 29-JUN-2007  akoduri  Bug #6155820 Structural change warning is not   |
REM |                       displayed during create dimension object        |
REM | 21-SEP-2007  ankgoel  Bug#6391292 - Handled validation of Manager's   |
REM |                       dim object view separately                      |
REM | 09-JAN-2008 lbodired  Bug#6707712 PL/SQL error while creating custom  |
REM |                       Period for the calendar                             |
REM +=======================================================================+
*/
CONFIG_LIMIT_DIM              CONSTANT        NUMBER := 8;
/*********************************************************************************/
TYPE KPI_Dim_Set_Type IS Record
(       p_kpi_id            BSC_KPI_DIM_SETS_TL.indicator%TYPE
    ,   p_dim_set_id        BSC_KPI_DIM_SETS_TL.dim_set_id%TYPE
    ,   p_Name              BSC_KPIS_VL.name%TYPE
);
/*********************************************************************************/

TYPE KPI_Dim_Set_Table_Type IS TABLE OF KPI_Dim_Set_Type INDEX BY BINARY_INTEGER;
/********************************************************************************
      FUNCTION TO CHECK IF PASSED PARAMETER IS IS KEY-WORD OR NOT
********************************************************************************/
FUNCTION is_SQL_Key_Word
(
    p_value   IN  VARCHAR2
) RETURN BOOLEAN;
/*******************************************************************************
               FUNCTION TO ALTER
               M x N Tables
********************************************************************************/
FUNCTION Alter_M_By_N_Tables
(       p_Dim_Level_Rec     IN              BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   p_Dim_Level_Rec_Old IN              BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
)
RETURN BOOLEAN;
/*******************************************************************************
               FUNCTION TO strip off invalid characters in the given string
********************************************************************************/

FUNCTION  get_valid_ddlentry_frm_name(
    p_name          IN VARCHAR2
)RETURN VARCHAR2;

/*******************************************************************************
               FUNCTION TO ALTER One x N Child Tables
********************************************************************************/
FUNCTION Alter_One_By_N_Tables
(       p_Dim_Level_Rec     IN              BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   p_Dim_Level_Rec_Old IN              BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
)
RETURN BOOLEAN;
/*******************************************************************************
               FUNCTION TO CREATE BSC DIMENSION OBJECTS MASTER TABLES
********************************************************************************/
FUNCTION Create_Bsc_Master_Tabs
(       p_Dim_Level_Rec     IN  OUT NOCOPY  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
)
RETURN BOOLEAN;
/*******************************************************************************
               FUNCTION TO ALTER BSC DIMENSION OBJECTS MASTER TABLES
********************************************************************************/
FUNCTION Alter_Bsc_Master_Tabs
(       p_Dim_Level_Rec     IN  OUT NOCOPY  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   p_Dim_Level_Rec_Old IN              BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
)
RETURN BOOLEAN;
/*******************************************************************************
                      FUNCTION TO CREATE PMF DIMENSION-OBJ VIEWS
********************************************************************************/
FUNCTION Create_Pmf_Views
(       p_Dim_Level_Rec     IN  OUT   NOCOPY    BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT   NOCOPY    VARCHAR2
    ,   x_msg_count             OUT   NOCOPY    NUMBER
    ,   x_msg_data              OUT   NOCOPY    VARCHAR2
)
RETURN BOOLEAN;
/*******************************************************************************/
FUNCTION check_sametype_dims
(       p_dim_obj_name              IN  VARCHAR2
    ,   p_dim_obj_short_name        IN  VARCHAR2
    ,   p_dim_obj_source            IN  VARCHAR2
    ,   p_dim_short_names       IN  VARCHAR2
    ,   p_Restrict_Dim_Validate     IN  VARCHAR2   := NULL
    ,   x_return_status             OUT    NOCOPY   VARCHAR2
    ,   x_msg_count                 OUT    NOCOPY   NUMBER
    ,   x_msg_data                  OUT    NOCOPY   VARCHAR2
)RETURN BOOLEAN;

/******************************************************************************/
FUNCTION is_Obj_Display_Frmt_Change
(       p_dim_obj_short_name        IN          VARCHAR2
    ,   p_Source                    IN          VARCHAR2
    ,   p_source_table              IN          VARCHAR2
    ,   p_table_column              IN          VARCHAR2
    ,   p_prototype_default_value   IN          VARCHAR2
    ,   p_maximum_code_size         IN          NUMBER
    ,   p_maximum_name_size         IN          NUMBER
    ,   p_dim_short_names           IN          VARCHAR2
    ,   x_obj_names                 OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN;

/******************************************************************************/
-- Added for Bug#4758995
FUNCTION Is_Recursive_Relationship
(
      p_Short_Name       IN VARCHAR2
    , x_Relation_Col     OUT NOCOPY VARCHAR2
    , x_Data_Source      OUT NOCOPY VARCHAR2
    , x_Data_Source_Type OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;
/******************************************************************************/

FUNCTION Validate_PMF_Base_View_Mgr (
  p_view_name        IN VARCHAR2
, p_parent_id_exists IN VARCHAR2
, p_parent_column    IN VARCHAR2
) RETURN NUMBER;
/******************************************************************************/

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

/*******************************************************************************
              FUNCTION TO CHECK IT THE IDENTIFIER IS VALID SQL IDENTIFIER
********************************************************************************/
FUNCTION is_Valid_Identifier
(
    p_SQL_Ident IN VARCHAR2
) RETURN BOOLEAN
IS
    l_SQL_Ident VARCHAR2(30);
BEGIN
    IF (p_SQL_Ident IS NULL) THEN
        RETURN FALSE;
    END IF;
    IF (LENGTH(p_SQL_Ident) > 30) THEN
        RETURN FALSE;
    END IF;
    IF (SUBSTR(p_SQL_Ident, 1,1) = '_') THEN
        RETURN FALSE;
    END IF;
    l_SQL_Ident :=  UPPER(p_SQL_Ident);
    IF(REPLACE(TRANSLATE(SUBSTR(l_SQL_Ident, 1, 1), '0123456789', '0000000000'), '0', '') IS NULL) THEN
        RETURN FALSE;
    END IF;
    IF (REPLACE(TRANSLATE(l_SQL_Ident, '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_',
                                       'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'), 'X', '') IS NOT NULL) THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END is_Valid_Identifier;

/*******************************************************************************
                      FUNCTION TO INITIALIZE BSC RECORDS
********************************************************************************/
FUNCTION Initialize_Bsc_Recs
(       p_Dim_Level_Rec     IN  OUT NOCOPY  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN;

/********************************************************************************
                   FUNCTION TO RETRIEVE CHILD DIM OBJECTS
 ********************************************************************************/
FUNCTION Get_Child_Dim_Objs
( p_Dim_Level_Id  IN NUMBER
) RETURN VARCHAR2 IS

l_child_dim_obj VARCHAR2(32000);

CURSOR c_Dim_Level_Child IS
SELECT dim_level_id
FROM BSC_SYS_DIM_LEVEL_RELS
WHERE parent_dim_level_id = p_Dim_Level_Id
AND RELATION_TYPE <> 2;

BEGIN
l_child_dim_obj := NULL;

FOR cdl in c_Dim_Level_Child LOOP
    IF (l_child_dim_obj IS NULL) THEN
        l_child_dim_obj := cdl.dim_level_id;
    ELSE
        l_child_dim_obj := l_child_dim_obj||','||cdl.dim_level_id;
    END IF;
END LOOP;

RETURN l_child_dim_obj;

END Get_Child_Dim_Objs;

/*********************************************************************************/

-- Modified this API for Bug#4383962
-- After A999 - this API will bomb, instead this API will user A - Z to increase
-- generation range. For example if A999 is passed, then B0 will be returned.
-- If D999 is passed E0 will be returned.
FUNCTION get_Next_Alias
(
    p_Alias        IN   VARCHAR2
) RETURN VARCHAR2
IS
    l_return    VARCHAR2(4);
    l_count     NUMBER;

    l_Alias_Prefix      VARCHAR2(8);
    l_Alias_Postfix     VARCHAR2(8);
    l_Alias_Postfix_Num NUMBER;
BEGIN
    IF (p_Alias IS NULL) THEN
        l_return :=  'A';
    ELSE
        l_Alias_Prefix  := SUBSTR(p_Alias, 1, 1);
        l_Alias_Postfix := SUBSTR(p_Alias, 2);

        l_Alias_Postfix_Num := TO_NUMBER(l_Alias_Postfix);

        l_count := LENGTH(p_Alias);

        IF (l_count = 1) THEN
            l_return   := l_Alias_Prefix || '0';
        ELSIF (l_count > 1) THEN
            IF(l_Alias_Postfix_Num >= 999) THEN
                l_Alias_Postfix     := '0';
                l_Alias_Prefix      := FND_GLOBAL.LOCAL_CHR(ASCII(SUBSTR(p_Alias, 1, 1))+1);
            ELSE
                l_Alias_Postfix     := TO_CHAR(l_Alias_Postfix_Num+1);
            END IF;

            l_return    := l_Alias_Prefix || l_Alias_Postfix;
        END IF;
    END IF;
    RETURN l_return;
EXCEPTION
    WHEN OTHERS THEN
        RETURN p_Alias;
END get_Next_Alias;

/*********************************************************************************/

FUNCTION Is_More
(       p_dim_short_names   IN  OUT NOCOPY  VARCHAR2
    ,   p_dim_name          OUT NOCOPY      VARCHAR2
) RETURN BOOLEAN;
/*********************************************************************************
   Set the ALL Enable Flag, must be called only for PMF type Dimension Objects
*********************************************************************************/
PROCEDURE Set_All_Enable_Flag
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_Dim_Obj_Short_Name    IN              VARCHAR2
    ,   p_All_Enabled           IN              NUMBER
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    l_Bsc_Dim_Obj_ID        BSC_SYS_DIM_LEVELS_B.Dim_Level_ID%TYPE;
    l_Bsc_Group_ID          BSC_SYS_DIM_GROUPS_TL.Dim_Group_ID%TYPE;
    l_Dim_Short_Name        BIS_DIMENSIONS.Short_Name%TYPE;

    CURSOR  c_Bis_Levels IS
    SELECT  B.Short_Name
    FROM    BIS_LEVELS     A
         ,  BIS_DIMENSIONS B
    WHERE   A.Short_Name   = p_Dim_Obj_Short_Name
    AND     A.Dimension_Id = B.Dimension_Id;
BEGIN

    SAVEPOINT SyncPMFAllInPMD;
    IF ((p_All_Enabled IS NOT NULL) AND ((p_All_Enabled = 0) OR (p_All_Enabled = -1))) THEN
        IF (c_Bis_Levels%ISOPEN) THEN
            CLOSE c_Bis_Levels;
        END IF;
        OPEN  c_Bis_Levels;
            FETCH   c_Bis_Levels
            INTO    l_Dim_Short_Name;
        CLOSE  c_Bis_Levels;
        l_Bsc_Group_ID     := BSC_BIS_DIMENSION_PUB.Get_Bsc_Dimension_ID(l_Dim_Short_Name);
        l_Bsc_Dim_Obj_ID   := BSC_BIS_DIM_OBJ_PUB.Get_Bsc_Dim_Obj_ID(p_Dim_Obj_Short_Name);

        UPDATE BSC_SYS_DIM_LEVELS_BY_GROUP
        SET    Total_Flag   =  p_All_Enabled
        WHERE  Dim_Level_Id =  l_Bsc_Dim_Obj_ID
        AND    Dim_Group_Id =  l_Bsc_Group_ID;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO SyncPMFAllInPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Set_All_Enable_Flag ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Set_All_Enable_Flag ';
        END IF;
END Set_All_Enable_Flag;

/*********************************************************************************************
                         update relation col in case of m_by_n relation type
                         Modified for bug#4091924
*********************************************************************************************/
PROCEDURE Update_M_By_N_Relation_col
( p_Dim_Level_Id          IN NUMBER
, p_Parent_Dim_Level_Id   IN NUMBER
, p_Relation_Col          IN VARCHAR2
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
) IS

  CURSOR c_Relation_Col IS
    SELECT K.indicator
          ,K.dim_set_id
          ,K.dim_level_index
          ,K.level_table_name
    FROM   bsc_kpi_dim_levels_vl K
          ,bsc_sys_dim_levels_b S
    WHERE  S.level_Table_name = K.level_table_name
    AND    S.dim_level_id     IN ( p_Dim_Level_Id,p_Parent_Dim_Level_Id)
    AND    K.parent_level_rel IS NOT NULL
    AND    K.table_relation   IS NOT NULL;

BEGIN
  BSC_APPS.Init_Bsc_Apps;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  UPDATE  bsc_sys_dim_level_rels
  SET     relation_col = p_Relation_Col
  WHERE   dim_level_id = p_Dim_Level_Id
  AND     parent_dim_level_id = p_Parent_Dim_Level_Id
  AND     relation_type = 2;

  UPDATE  bsc_sys_dim_level_rels
  SET     relation_col = p_Relation_Col
  WHERE   dim_level_id = p_Parent_Dim_Level_Id
  AND     parent_dim_level_id = p_Dim_Level_Id
  AND     relation_type = 2;

  FOR CD IN c_Relation_Col LOOP
    UPDATE bsc_kpi_dim_levels_b
    SET    table_relation  =  p_Relation_Col
    WHERE  indicator       =  CD.indicator
    AND    dim_set_id      =  CD.dim_set_id
    AND    dim_level_index =  CD.dim_level_index;
  END LOOP;


EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Refresh_BSC_Dim_View_In_Pmf';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Refresh_BSC_Dim_View_In_Pmf';
        END IF;
END Update_M_By_N_Relation_col;
--=======================================================================================

-- Called from Create and Update flow for BSC type dim objects only.
-- This will support enable/disable of 'All' flag from Report Designer.
PROCEDURE Set_Bsc_All_Enable_Flag
( p_commit              IN           VARCHAR2 := FND_API.G_TRUE
, p_Dim_Obj_Short_Name  IN           VARCHAR2
, p_Dim_Short_Name      IN           VARCHAR2 := NULL
, p_All_Enabled         IN           NUMBER
, x_return_status       OUT  NOCOPY  VARCHAR2
, x_msg_count           OUT  NOCOPY  NUMBER
, x_msg_data            OUT  NOCOPY  VARCHAR2
)
IS
BEGIN

  SAVEPOINT SyncBSCAllInPMD;

  IF ((p_All_Enabled IS NOT NULL) AND (p_All_Enabled = 0)) THEN
    IF (p_Dim_Short_Name IS NOT NULL) THEN  -- Update Mode
      UPDATE bsc_sys_dim_levels_by_group
        SET   total_flag   = p_All_Enabled
        WHERE dim_level_id = BSC_BIS_DIM_OBJ_PUB.Get_Bsc_Dim_Obj_ID(p_Dim_Obj_Short_Name)
        AND   dim_group_id = BSC_BIS_DIMENSION_PUB.Get_Bsc_Dimension_ID(p_Dim_Short_Name);
    ELSE -- Create Mode
      UPDATE bsc_sys_dim_levels_by_group
        SET   total_flag   = p_All_Enabled
        WHERE dim_level_id = BSC_BIS_DIM_OBJ_PUB.Get_Bsc_Dim_Obj_ID(p_Dim_Obj_Short_Name);
    END IF;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO SyncBSCAllInPMD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Set_Bsc_All_Enable_Flag ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Set_Bsc_All_Enable_Flag ';
    END IF;
END Set_Bsc_All_Enable_Flag;

/*********************************************************************************
                            CREATE DIMENSION
*********************************************************************************/
PROCEDURE Create_Dim_Object
(       p_commit                    IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_short_name        IN          VARCHAR2
    ,   p_display_name              IN          VARCHAR2
    ,   p_application_id            IN          NUMBER
    ,   p_description               IN          VARCHAR2
    ,   p_data_source               IN          VARCHAR2
    ,   p_source_table              IN          VARCHAR2
    ,   p_where_clause              IN          VARCHAR2   := NULL
    ,   p_comparison_label_code     IN          VARCHAR2
    ,   p_table_column              IN          VARCHAR2
    ,   p_source_type               IN          VARCHAR2
    ,   p_maximum_code_size         IN          NUMBER
    ,   p_maximum_name_size         IN          NUMBER
    ,   p_all_item_text             IN          VARCHAR2
    ,   p_comparison_item_text      IN          VARCHAR2
    ,   p_prototype_default_value   IN          VARCHAR2
    ,   p_dimension_values_order    IN          NUMBER
    ,   p_comparison_order          IN          NUMBER
    ,   p_dim_short_names           IN          VARCHAR2
    ,   p_Master_Level              IN          VARCHAR2   := NULL
    ,   p_Long_Lov                  IN          VARCHAR2   := FND_API.G_FALSE
    ,   p_Search_Function           IN          VARCHAR2   := NULL
    ,   p_Dim_Obj_Enabled           IN          VARCHAR2   := FND_API.G_FALSE
    ,   p_View_Object_Name          IN          VARCHAR2   := NULL
    ,   p_Default_Values_Api        IN          VARCHAR2   := NULL
    ,   p_All_Enabled               IN          NUMBER     := NULL
    ,   p_Drill_To_Form_Function    IN          VARCHAR2   := NULL
    ,   x_return_status             OUT NOCOPY  VARCHAR2
    ,   x_msg_count                 OUT NOCOPY  NUMBER
    ,   x_msg_data                  OUT NOCOPY  VARCHAR2
) IS
BEGIN
    SAVEPOINT CreateBSCDimObjPMD;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Create_Dim_Object
    (   p_commit                    => p_commit
    ,   p_dim_obj_short_name        => p_dim_obj_short_name
    ,   p_display_name              => p_display_name
    ,   p_application_id            => p_application_id
    ,   p_description               => p_description
    ,   p_data_source               => p_data_source
    ,   p_source_table              => p_source_table
    ,   p_where_clause              => p_where_clause
    ,   p_comparison_label_code     => p_comparison_label_code
    ,   p_table_column              => p_table_column
    ,   p_source_type               => p_source_type
    ,   p_maximum_code_size         => p_maximum_code_size
    ,   p_maximum_name_size         => p_maximum_name_size
    ,   p_all_item_text             => p_all_item_text
    ,   p_comparison_item_text      => p_comparison_item_text
    ,   p_prototype_default_value   => p_prototype_default_value
    ,   p_dimension_values_order    => p_dimension_values_order
    ,   p_comparison_order          => p_comparison_order
    ,   p_dim_short_names           => p_dim_short_names
    ,   p_Master_Level              => p_Master_Level
    ,   p_Long_Lov                  => p_Long_Lov
    ,   p_Search_Function           => p_Search_Function
    ,   p_Dim_Obj_Enabled           => p_Dim_Obj_Enabled
    ,   p_View_Object_Name          => p_View_Object_Name
    ,   p_Default_Values_Api        => p_Default_Values_Api
    ,   p_All_Enabled               => p_All_Enabled
    ,   p_is_default_short_name     => 'F'
    ,   p_Drill_To_Form_Function    =>  p_Drill_To_Form_Function
    ,   x_return_status             => x_return_status
    ,   x_msg_count                 => x_msg_count
    ,   x_msg_data                  => x_msg_data
   );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCDimObjPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCDimObjPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCDimObjPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object ';
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCDimObjPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object ';
        END IF;
END Create_Dim_Object;

/*
** Called from JAVA Dimension Designer
*/
PROCEDURE Create_Dim_Object
( p_commit                    IN          VARCHAR2   := FND_API.G_FALSE
, p_dim_obj_short_name        IN          VARCHAR2
, p_display_name              IN          VARCHAR2
, p_application_id            IN          NUMBER
, p_description               IN          VARCHAR2
, p_data_source               IN          VARCHAR2
, p_source_table              IN          VARCHAR2
, p_where_clause              IN          VARCHAR2   := NULL
, p_comparison_label_code     IN          VARCHAR2
, p_table_column              IN          VARCHAR2
, p_source_type               IN          VARCHAR2
, p_maximum_code_size         IN          NUMBER
, p_maximum_name_size         IN          NUMBER
, p_all_item_text             IN          VARCHAR2
, p_comparison_item_text      IN          VARCHAR2
, p_prototype_default_value   IN          VARCHAR2
, p_dimension_values_order    IN          NUMBER
, p_comparison_order          IN          NUMBER
, p_dim_short_names           IN          VARCHAR2
, p_Master_Level              IN          VARCHAR2   :=  NULL
, p_Long_Lov                  IN          VARCHAR2   :=  FND_API.G_FALSE
, p_Search_Function           IN          VARCHAR2   :=  NULL
, p_Dim_Obj_Enabled           IN          VARCHAR2   :=  FND_API.G_FALSE
, p_View_Object_Name          IN          VARCHAR2   :=  NULL
, p_Default_Values_Api        IN          VARCHAR2   :=  NULL
, p_All_Enabled               IN          NUMBER     :=  NULL
, p_is_default_short_name     IN          VARCHAR2
, p_Drill_To_Form_Function    IN          VARCHAR2   :=  NULL
, p_Prototype_Values          IN          BIS_STRING_ARRAY
, p_Force_Dimension_Create    IN          VARCHAR2
, p_Restrict_Dim_Validate     IN          VARCHAR2   := NULL
, x_return_status             OUT NOCOPY  VARCHAR2
, x_msg_count                 OUT NOCOPY  NUMBER
, x_msg_data                  OUT NOCOPY  VARCHAR2
) IS
  l_next_dim_grp_id        NUMBER;
  l_is_default_short_name  VARCHAR2(1);
BEGIN
    SAVEPOINT CreateBSCDimObjPMD;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_is_default_short_name := p_is_default_short_name;

    -- Create Dimension if p_Force_Dimension_Create = 'T' (AG)
    IF (p_Force_Dimension_Create = 'T') THEN

      BSC_BIS_DIMENSION_PUB.Create_Dimension
      ( p_commit               => FND_API.G_FALSE
      , p_dim_short_name       => p_dim_short_names
      , p_display_name         => p_display_name
      , p_description          => p_description
      , p_dim_obj_short_names  => NULL
      , p_application_id       => p_application_id
      , x_return_status        => x_return_status
      , x_msg_count            => x_msg_count
      , x_msg_data             => x_msg_data
      );

      IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_is_default_short_name := 'F';
    END IF;

    -- Create Dimension Object
    Create_Dim_Object
    ( p_commit                   => p_commit
    , p_dim_obj_short_name       => p_dim_obj_short_name
    , p_display_name             => p_display_name
    , p_application_id           => p_application_id
    , p_description              => p_description
    , p_data_source              => p_data_source
    , p_source_table             => p_source_table
    , p_where_clause             => p_where_clause
    , p_comparison_label_code    => p_comparison_label_code
    , p_table_column             => p_table_column
    , p_source_type              => p_source_type
    , p_maximum_code_size        => p_maximum_code_size
    , p_maximum_name_size        => p_maximum_name_size
    , p_all_item_text            => p_all_item_text
    , p_comparison_item_text     => p_comparison_item_text
    , p_prototype_default_value  => p_prototype_default_value
    , p_dimension_values_order   => p_dimension_values_order
    , p_comparison_order         => p_comparison_order
    , p_dim_short_names          => p_dim_short_names
    , p_Master_Level             => p_Master_Level
    , p_Long_Lov                 => p_Long_Lov
    , p_Search_Function          => p_Search_Function
    , p_Dim_Obj_Enabled          => p_Dim_Obj_Enabled
    , p_View_Object_Name         => p_View_Object_Name
    , p_Default_Values_Api       => p_Default_Values_Api
    , p_All_Enabled              => p_All_Enabled
    , p_is_default_short_name    => l_is_default_short_name  --p_is_default_short_name
    , p_Drill_To_Form_Function   => p_Drill_To_Form_Function
    , p_Restrict_Dim_Validate    => p_Restrict_Dim_Validate
    , x_return_status            => x_return_status
    , x_msg_count                => x_msg_count
    , x_msg_data                 => x_msg_data
   );

   IF ((x_return_status  IS NOT NULL) AND (x_return_status  <>  FND_API.G_RET_STS_SUCCESS)) THEN
     RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Save Prototype Values if NOT NULL (AG)
   IF (p_Prototype_Values.COUNT > 0) THEN
     BIS_UTIL.save_prototype_values
     ( p_dim_object  => p_dim_obj_short_name
     , p_PV_array    => p_Prototype_Values
     );
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CreateBSCDimObjPMD;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CreateBSCDimObjPMD;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO CreateBSCDimObjPMD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO CreateBSCDimObjPMD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object ';
    ELSE
      x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object ';
    END IF;
END Create_Dim_Object;

/*
    This procedure allow user to create a new dimension category whose records
    will be inserted into the following tables.
        1  BIS_LEVELS.
        2. BIS_LEVELS_TL
        3. BSC_SYS_DIM_LEVELS_B
        4. BSC_SYS_DIM_LEVELS_TL

    Key
        p_dim_obj_short_name

    Validations:
        1. p_dimension_id, p_dim_obj_short_name, p_display_name, p_data_source,  p_application_id
           and p_source_type must not be null.
        2. p_dim_obj_short_name and p_display_name must be unique.
*/

PROCEDURE Create_Dim_Object
(       p_commit                    IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_short_name        IN          VARCHAR2
    ,   p_display_name              IN          VARCHAR2
    ,   p_application_id            IN          NUMBER
    ,   p_description               IN          VARCHAR2
    ,   p_data_source               IN          VARCHAR2
    ,   p_source_table              IN          VARCHAR2
    ,   p_where_clause              IN          VARCHAR2   := NULL
    ,   p_comparison_label_code     IN          VARCHAR2
    ,   p_table_column              IN          VARCHAR2
    ,   p_source_type               IN          VARCHAR2
    ,   p_maximum_code_size         IN          NUMBER
    ,   p_maximum_name_size         IN          NUMBER
    ,   p_all_item_text             IN          VARCHAR2
    ,   p_comparison_item_text      IN          VARCHAR2
    ,   p_prototype_default_value   IN          VARCHAR2
    ,   p_dimension_values_order    IN          NUMBER
    ,   p_comparison_order          IN          NUMBER
    ,   p_dim_short_names           IN          VARCHAR2
    ,   p_Master_Level              IN          VARCHAR2   := NULL
    ,   p_Long_Lov                  IN          VARCHAR2   := FND_API.G_FALSE
    ,   p_Search_Function           IN          VARCHAR2   := NULL
    ,   p_Dim_Obj_Enabled           IN          VARCHAR2   := FND_API.G_FALSE
    ,   p_View_Object_Name          IN          VARCHAR2   := NULL
    ,   p_Default_Values_Api        IN          VARCHAR2   := NULL
    ,   p_All_Enabled               IN          NUMBER     := NULL
    ,   p_is_default_short_name     IN          VARCHAR2
    ,   p_Drill_To_Form_Function    IN          VARCHAR2   := NULL
    ,   p_Restrict_Dim_Validate     IN          VARCHAR2   := NULL
    ,   x_return_status             OUT NOCOPY  VARCHAR2
    ,   x_msg_count                 OUT NOCOPY  NUMBER
    ,   x_msg_data                  OUT NOCOPY  VARCHAR2
) IS
    l_bsc_dim_obj_rec       BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
    l_bis_dim_level_rec     BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
    l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
    l_level_table_name      BIS_LEVELS.LEVEL_VALUES_VIEW_NAME%TYPE;
    l_bis_short_name        BIS_LEVELS.Short_Name%TYPE;
    l_bis_name              BIS_LEVELS_TL.Name%TYPE;
    l_user_id               FND_USER.user_id%TYPE;
    l_login_id              NUMBER;
    l_count                 NUMBER;
    l_temp_var              BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE;
    l_alias                 VARCHAR2(4);

    l_dim_short_names       VARCHAR2(32000);
    l_flag                  BOOLEAN := FALSE;
    l_dim_obj_name          BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE;
    l_application_id        BIS_LEVELS.Application_Id%TYPE;
    -- Start Granular Locking added by Aditya
    l_Dim_Tab               BSC_BIS_LOCKS_PUB.t_numberTable;
    l_dim_Grp_names         VARCHAR2(32000);

    l_dim_Grp_name          BSC_SYS_DIM_GROUPS_TL.short_name%TYPE;
    l_index                 NUMBER := 0;
    l_first_dim             BOOLEAN := TRUE;
    -- End Granular Locking added by Aditya
    l_pmf_disp_name         VARCHAR2(255); -- DispName

    -- init new case when source='BSC' and short_name = null (or <Default>)
    l_source_table              VARCHAR(30);
    l_table_column              VARCHAR(30);
    l_prototype_default_value   VARCHAR2(255);
    l_mix_type_dim              BOOLEAN;

    CURSOR c_Master_Level IS
    SELECT Short_Name
         , Master_Level
         , Name
    FROM   BIS_LEVELS_VL
    WHERE  Short_Name = p_Master_Level;
BEGIN

    SAVEPOINT CreateBSCDimObjPMD;
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ((p_dim_obj_short_name IS NOT NULL) AND
        (p_is_default_short_name <> 'T')) THEN
        l_dim_obj_name      :=  TRIM(p_dim_obj_short_name);
        l_application_id    :=  p_application_id;
    ELSE
        SELECT  NVL(MAX(dim_level_id) + 1, 0)
        INTO    l_count
        FROM    BSC_SYS_DIM_LEVELS_B;
        IF (p_dim_obj_short_name IS NULL) THEN
          l_dim_obj_name      := c_BSC_DIM_OBJ||l_count;
        ELSE
          l_dim_obj_name      := p_dim_obj_short_name;
        END IF;
        l_flag              :=  TRUE;
        l_alias             :=  NULL;
        l_temp_var          :=  l_dim_obj_name;
        WHILE (l_flag) LOOP
            SELECT COUNT(1) INTO l_count
            FROM (SELECT COUNT(1) rec_count
                  FROM   BSC_SYS_DIM_LEVELS_VL
                  WHERE  UPPER(Short_Name) = UPPER(l_temp_var)
                  UNION
                  SELECT COUNT(1) rec_count
                  FROM   BIS_LEVELS_VL
                  WHERE  UPPER(Short_Name) = UPPER(l_temp_var))
            WHERE rec_count > 0;
            IF (l_count = 0) THEN
              l_flag              :=  FALSE;
              l_dim_obj_name      :=  l_temp_var;
            END IF;
            l_alias     :=  BSC_BIS_DIM_OBJ_PUB.get_Next_Alias(l_alias);
            l_temp_var  :=  l_dim_obj_name||l_alias;
        END LOOP;
        IF(p_application_id = -1 OR p_application_id IS NULL) THEN
            l_application_id    :=  271;
        ELSE
            l_application_id    := p_application_id;
        END IF;
    END IF;

    l_source_table := p_source_table;
    l_table_column := p_table_column;
    l_prototype_default_value := p_prototype_default_value;

    --check for not null fields
    IF (l_dim_obj_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_SHORT_NAME'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (NOT is_Valid_AlphaNum(l_dim_obj_name)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_ALPHA_NUM_REQUIRED');
        FND_MESSAGE.SET_TOKEN('VALUE',  l_dim_obj_name);
        FND_MESSAGE.SET_TOKEN('NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_SHORT_NAME'));
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
    IF (p_data_source IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DATA_SOURCE'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF ((p_data_source <> 'BSC') AND (p_data_source <> 'PMF')) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DATA_SOURCE');
        FND_MSG_PUB.ADD;
        RAISE           FND_API.G_EXC_ERROR;
    END IF;
    IF (p_data_source = 'BSC') THEN
        l_bsc_dim_obj_rec.Source        :=  'OLTP';
    ELSE
        IF ((p_source_type IS NULL) OR ((p_source_type <> 'OLTP') AND (p_source_type <> 'EDW'))) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SOURCE_TYPE');
            FND_MSG_PUB.ADD;
            RAISE           FND_API.G_EXC_ERROR;
        ELSE
            l_bsc_dim_obj_rec.Source    :=  p_source_type;
        END IF;
    END IF;
    --check for uniqueness of l_dim_obj_name in PMF's metadata
    SELECT  COUNT(1) INTO l_count
    FROM    BIS_LEVELS_VL
    WHERE   UPPER(short_name) = UPPER(l_dim_obj_name);
    IF (l_count > 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_UNIQUE_NAME_REQUIRED');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_SHORT_NAME'));
        FND_MESSAGE.SET_TOKEN('NAME_VALUE', l_dim_obj_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --check for uniqueness of l_dim_obj_name in BSC's metadata
    SELECT  COUNT(1) INTO l_count
    FROM    BSC_SYS_DIM_LEVELS_VL
    WHERE   UPPER(short_name) = UPPER(l_dim_obj_name);
    IF (l_count > 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_UNIQUE_NAME_REQUIRED');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_SHORT_NAME'));
        FND_MESSAGE.SET_TOKEN('NAME_VALUE', l_dim_obj_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    ---Check the dimensions that are being attached may contain both autogenerated and existing
    -- source type because of this
    l_mix_type_dim := FALSE;
    IF(p_dim_short_names IS NOT NULL) THEN
        l_mix_type_dim := check_sametype_dims
                            (       p_dim_obj_name          =>  p_display_name
                                ,   p_dim_obj_short_name    =>  p_dim_obj_short_name
                                ,   p_dim_obj_source        =>  p_data_source
                                ,   p_dim_short_names       =>  p_dim_short_names
                                ,   p_Restrict_Dim_Validate =>  p_Restrict_Dim_Validate
                                ,   x_return_status         =>  x_return_status
                                ,   x_msg_count             =>  x_msg_count
                                ,   x_msg_data              =>  x_msg_data
                            );
        IF (l_mix_type_dim) THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    -- start checkin for Default names
    l_pmf_disp_name := p_display_name;
    IF (p_data_source = 'PMF') THEN
        SELECT  COUNT(1) INTO l_count
        FROM    BIS_LEVELS_VL
        WHERE   UPPER(name)  = UPPER(p_display_name);
        IF (l_count <> 0) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_UNIQUE_NAME_REQUIRED');
            FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DISPLAY_NAME'));
            FND_MESSAGE.SET_TOKEN('NAME_VALUE', p_display_name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    ELSIF (p_data_source = 'BSC') THEN   -- Allow insertion into BSC Data Model, with the same display name
        SELECT  COUNT(1) INTO l_count
        FROM    BIS_LEVELS_VL
        WHERE   UPPER(name)  = UPPER(l_pmf_disp_name);
        WHILE(l_count > 0) LOOP
            l_pmf_disp_name := BSC_UTILITY.get_Next_DispName(l_pmf_disp_name);
            SELECT  COUNT(1) INTO l_count
            FROM    BIS_LEVELS_VL
            WHERE   UPPER(name)  = UPPER(l_pmf_disp_name);
        END LOOP;
    END IF;

    -- Start Granular Locking added by Aditya
    l_dim_Grp_names :=  p_dim_short_names;
    -- for PMF pick 1st one define a boolean variable first=true;, and
    IF (p_dim_short_names IS NOT NULL) THEN
        l_dim_Grp_names   :=  p_dim_short_names ;
        WHILE (is_more( p_dim_short_names  =>  l_dim_Grp_names
                      , p_dim_name         =>  l_dim_Grp_name)
        ) LOOP
            IF (l_first_dim) THEN
                l_first_dim := FALSE;
                l_bis_dim_level_rec.Dimension_Short_Name  := l_dim_Grp_name;
            END IF;
            l_Dim_Tab(l_index) := NVL(BSC_DIMENSION_GROUPS_PVT.get_Dim_Group_Id(l_dim_Grp_name), -1);
            l_index            := l_index + 1;
        END LOOP;
        -- Lock all the Dimension to be assigned to the Dimension Objects
        BSC_BIS_LOCKS_PUB.Lock_Create_Dimension_Object
        (    p_selected_dimensions   =>  l_Dim_Tab
          ,  x_return_status         =>  x_return_status
          ,  x_msg_count             =>  x_msg_count
          ,  x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSE
        l_bis_dim_level_rec.Dimension_Short_Name  :=  BSC_BIS_DIMENSION_PUB.Unassigned_Dim;
    END IF;
    -- End Granular Locking
    --BSC_SYS_DIM_LEVELS_B.dim_level_id
    l_bsc_dim_obj_rec.Bsc_Level_Id            :=  BSC_DIMENSION_LEVELS_PVT.Get_Next_Value('BSC_SYS_DIM_LEVELS_B', 'DIM_LEVEL_ID');
    l_bsc_dim_obj_rec.Bsc_Source              :=  p_data_source;--BSC_SYS_DIM_LEVELS_B.source
    l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size :=  p_maximum_code_size;--BSC_SYS_DIM_LEVELS_B.user_key_size
    l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size :=  p_maximum_name_size;--BSC_SYS_DIM_LEVELS_B.disp_key_size
    IF (l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size IS NULL) THEN
        l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size   :=  BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Code_Default_Size;
    END IF;
    IF (l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size IS NULL) THEN
        l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size   :=  BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Name_Default_Size;
    END IF;

    -- Bug#4383962
    -- Changed the substring to 7, since Get_Next_Alias can return upto 4 chars
    -- but UI validation is 11 chars only (8+4 = 12 in the older case)
    -- Modified the Get_Next_Alias API to generate better abbreviations.
    IF (l_prototype_default_value IS NULL) THEN
        IF ((p_dim_obj_short_name IS NULL) OR (p_is_default_short_name = 'T')) THEN
            l_bsc_dim_obj_rec.Bsc_Level_Abbreviation  := substr(get_valid_ddlentry_frm_name(p_display_name),1,7);
            IF(l_bsc_dim_obj_rec.Bsc_Level_Abbreviation IS NULL) THEN -- If the abbrevation generated based on display name is still null then generate on short name
                l_bsc_dim_obj_rec.Bsc_Level_Abbreviation  := substr(REPLACE(l_dim_obj_name, ' ', ''),1,7);
            END IF;
        ELSE
            l_bsc_dim_obj_rec.Bsc_Level_Abbreviation  :=  SUBSTR(REPLACE(l_dim_obj_name, ' ', ''), 1, 7);
        END IF;

    ELSE
        l_bsc_dim_obj_rec.Bsc_Level_Abbreviation  :=  SUBSTR(l_prototype_default_value, 1, 11);
    END IF;

    IF (l_bsc_dim_obj_rec.Bsc_Source = 'BSC') THEN
      SELECT COUNT(1) INTO l_count
      FROM   BSC_SYS_DIM_LEVELS_B
      WHERE  UPPER(abbreviation) = UPPER(l_bsc_dim_obj_rec.Bsc_Level_Abbreviation);
      IF (l_count <> 0) THEN
        l_flag          :=  TRUE;
        l_alias         :=  NULL;
        l_temp_var      :=  SUBSTR(l_bsc_dim_obj_rec.Bsc_Level_Abbreviation, 1, 7);
        WHILE (l_flag) LOOP
          SELECT COUNT(1) INTO l_count
          FROM   BSC_SYS_DIM_LEVELS_B
          WHERE  UPPER(abbreviation) = UPPER(l_temp_var);
          IF (l_count = 0) THEN
            l_flag                                      :=  FALSE;
            l_bsc_dim_obj_rec.Bsc_Level_Abbreviation    :=  l_temp_var;
          ELSE
            l_alias     :=  BSC_BIS_DIM_OBJ_PUB.get_Next_Alias(l_alias);
            l_temp_var  :=  SUBSTR(l_bsc_dim_obj_rec.Bsc_Level_Abbreviation, 1, 7)||l_alias;
          END IF;
        END LOOP;
      END IF;
    END IF;

    IF (l_bsc_dim_obj_rec.Bsc_Source = 'BSC') THEN
        IF ((l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size < BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Code_Min_Size) OR
              (l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size > BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Code_Max_Size) OR
                (l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size < BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Name_Min_Size) OR
                  (l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size > BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Name_Max_Size)) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_CODE_NAME_SIZE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;


    l_bsc_dim_obj_rec.Bsc_Level_Short_Name    :=  l_dim_obj_name;--BSC_SYS_DIM_LEVELS_B.short_name
    l_bsc_dim_obj_rec.Bsc_Pk_Col              :=  l_table_column;
    l_bsc_dim_obj_rec.Bsc_Level_Name          :=  l_source_table;
    IF (l_bsc_dim_obj_rec.Bsc_Source = 'BSC') THEN
        IF (l_bsc_dim_obj_rec.Bsc_Level_Name IS NULL) THEN
            IF ((p_dim_obj_short_name IS NULL) OR (p_is_default_short_name = 'T')) THEN
                l_bsc_dim_obj_rec.Bsc_Level_Name  :=  substr(get_valid_ddlentry_frm_name(p_display_name),1,30);
                IF(l_bsc_dim_obj_rec.Bsc_Level_Name IS NULL) THEN -- Generate level_table_name based on short name if it null
                    l_bsc_dim_obj_rec.Bsc_Level_Name  :=  substr(get_valid_ddlentry_frm_name(l_dim_obj_name),1,30);
                END IF;
                l_bsc_dim_obj_rec.Bsc_Level_Name  :=  'BSC_D_'||SUBSTR(l_bsc_dim_obj_rec.Bsc_Level_Name, 1, 21);
                IF (NOT is_Valid_Identifier(l_bsc_dim_obj_rec.Bsc_Level_Name)) THEN
                    FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SQL_IDENTIFIER');
                    FND_MESSAGE.SET_TOKEN('SQL_IDENT', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_TAB_NAME'));
                    FND_MESSAGE.SET_TOKEN('SQL_VALUE', l_bsc_dim_obj_rec.Bsc_Level_Name);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
                --generate unique table name if already exists
                l_flag          :=  TRUE;
                l_alias         :=  NULL;
                l_temp_var      :=  l_bsc_dim_obj_rec.Bsc_Level_Name;
                WHILE (l_flag) LOOP
                    SELECT COUNT(1) INTO l_count
                    FROM   BSC_SYS_DIM_LEVELS_B
                    WHERE  UPPER(Level_Table_Name) = UPPER(l_temp_var);
                    IF (l_count = 0) THEN
                        l_flag                           :=  FALSE;
                        l_bsc_dim_obj_rec.Bsc_Level_Name :=  l_temp_var;
                    END IF;
                    l_alias     :=  BSC_BIS_DIM_OBJ_PUB.get_Next_Alias(l_alias);
                    l_temp_var  :=  SUBSTR(l_bsc_dim_obj_rec.Bsc_Level_Name, 1, 18)||l_alias;
                END LOOP;
            ELSE
                l_bsc_dim_obj_rec.Bsc_Level_Name  :=  'BSC_D_'||SUBSTR(TRIM(l_dim_obj_name) , 1, 21);
            END IF;
        END IF;
        l_flag  :=  BSC_BIS_DIM_OBJ_PUB.Initialize_Bsc_Recs
                    (       p_Dim_Level_Rec     =>  l_bsc_dim_obj_rec
                        ,   x_return_status     =>  x_return_status
                        ,   x_msg_count         =>  x_msg_count
                        ,   x_msg_data          =>  x_msg_data
                    );
        IF(NOT l_flag) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSIF (l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
        IF ((l_bsc_dim_obj_rec.Source = 'OLTP') OR (l_bsc_dim_obj_rec.Source = 'EDW')) THEN
            l_flag  :=  BSC_BIS_DIM_OBJ_PUB.Initialize_Pmf_Recs
                        (       p_Dim_Level_Rec     =>  l_bsc_dim_obj_rec
                            ,   x_return_status     =>  x_return_status
                            ,   x_msg_count         =>  x_msg_count
                            ,   x_msg_data          =>  x_msg_data
                        );
            IF(NOT l_flag) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        ELSE
            FND_MESSAGE.SET_NAME('BSC','BSC_PRE_DIM_OBJ_SOURCE_TYPE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    --CALL PMF'S API
    l_user_id   :=  FND_GLOBAL.USER_ID;
    l_login_id  :=  FND_GLOBAL.LOGIN_ID;
    --   l_bis_dim_level_rec.Dimension_Short_Name        :=  'UNASSIGNED';--dummy name is required
    /* ADDED BY RAVI ************/
    l_bis_dim_level_rec.Dimension_ID               :=  get_bis_dimension_id(l_bis_dim_level_rec.Dimension_Short_Name);
    /****************/
    l_bis_dim_level_rec.Dimension_Name             :=  p_display_name;
    l_bis_dim_level_rec.Dimension_Level_Short_Name :=  l_dim_obj_name;
    l_bis_dim_level_rec.Dimension_Level_Name       :=  l_pmf_disp_name;
    l_bis_dim_level_rec.Description                :=  p_description;
    IF (l_bsc_dim_obj_rec.Bsc_Source = 'BSC') THEN
        l_bis_dim_level_rec.Level_Values_View_Name :=  l_bsc_dim_obj_rec.Bsc_Level_Name;
    ELSE
        l_bis_dim_level_rec.Level_Values_View_Name :=  l_source_table;
    END IF;
    IF ((l_bis_dim_level_rec.Level_Values_View_Name IS NOT NULL) AND
         (NOT is_Valid_Identifier(l_bis_dim_level_rec.Level_Values_View_Name))) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SQL_IDENTIFIER');
        FND_MESSAGE.SET_TOKEN('SQL_IDENT', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_VIEW_NAME'));
        FND_MESSAGE.SET_TOKEN('SQL_VALUE', l_bis_dim_level_rec.Level_Values_View_Name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_bis_dim_level_rec.where_Clause               :=  p_where_clause;
    l_bis_dim_level_rec.application_id             :=  l_application_id;
    l_bis_dim_level_rec.Source                     :=  l_bsc_dim_obj_rec.Source;
    l_bis_dim_level_rec.Comparison_Label_Code      :=  p_comparison_label_code;
    --SELECT bis_levels_s.NextVal INTO l_bis_dim_level_rec.Dimension_Level_ID FROM DUAL;

    IF ((p_Long_Lov IS NULL) OR ((p_Long_Lov <> FND_API.G_TRUE) AND (p_Long_Lov <> FND_API.G_FALSE))) THEN
        l_bis_dim_level_rec.Long_Lov               :=  FND_API.G_FALSE;
    ELSE
        l_bis_dim_level_rec.Long_Lov               :=  p_Long_Lov;
    END IF;

    IF ((p_Dim_Obj_Enabled IS NULL) OR ((p_Dim_Obj_Enabled <> FND_API.G_TRUE) AND (p_Dim_Obj_Enabled <> FND_API.G_FALSE))) THEN
        l_bis_dim_level_rec.Enabled                :=  FND_API.G_FALSE;
    ELSE
        l_bis_dim_level_rec.Enabled                :=  p_Dim_Obj_Enabled;
    END IF;
    IF (l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
        IF (p_Default_Values_Api IS NULL) THEN
            l_bis_dim_level_rec.Default_Values_Api :=  p_Default_Values_Api;
        ELSIF (p_Default_Values_Api <> '''''') THEN
            l_bis_dim_level_rec.Default_Values_Api :=  p_Default_Values_Api;
        END IF;
        l_bis_dim_level_rec.View_Object_Name       :=  p_View_Object_Name;
        l_bis_dim_level_rec.Attribute_Code         :=  l_bis_dim_level_rec.Dimension_Level_Short_Name;
    END IF;
    IF ((l_bsc_dim_obj_rec.Bsc_Source = 'PMF') AND (p_Master_Level IS NOT NULL)) THEN
        IF (p_Master_Level = l_bis_dim_level_rec.Dimension_Level_Short_Name) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_PMF_NO_SAME_DO');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (c_Master_Level%ISOPEN) THEN
            CLOSE c_Master_Level;
        END IF;
        OPEN    c_Master_Level;
            FETCH   c_Master_Level
            INTO    l_bis_dim_level_rec.Master_Level
                 ,  l_bis_short_name
                 ,  l_bis_name;
        CLOSE c_Master_Level;
        IF (l_bis_dim_level_rec.Master_Level IS NULL) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_LEVEL_NAME');
            FND_MESSAGE.SET_TOKEN('BSC_LEVEL_NAME', p_Master_Level);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (l_bis_short_name IS NOT NULL) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_PMF_LOV_NO_MASTER');
            FND_MESSAGE.SET_TOKEN('BIS_OBJ_LOV', l_bis_name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    l_bis_dim_level_rec.Default_Search     :=  p_Search_Function;

    -- Assigns Drill_To_Form_Function
    l_bis_dim_level_rec.Drill_To_Form_Function := p_Drill_To_Form_Function;
    BIS_DIMENSION_LEVEL_PUB.Create_Dimension_Level
    (       p_api_version           =>  1.0
        ,   p_commit                =>  FND_API.G_FALSE
        ,   p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL
        ,   p_Dimension_Level_Rec   =>  l_bis_dim_level_rec
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

    --CALL BSC API
    l_bsc_dim_obj_rec.Bsc_Dim_Comp_Disp_Name          :=  p_comparison_item_text;--BSC_SYS_DIM_LEVELS_TL.comp_disp_name
    l_bsc_dim_obj_rec.Bsc_Dim_Level_Long_Name         :=  p_display_name;--BSC_SYS_DIM_LEVELS_TL.name
    IF (p_description IS NULL) THEN
        l_bsc_dim_obj_rec.Bsc_Dim_Level_Help          :=  p_display_name;
    ELSE
        l_bsc_dim_obj_rec.Bsc_Dim_Level_Help          :=  p_description;--BSC_SYS_DIM_LEVELS_TL.help
    END IF;
    l_bsc_dim_obj_rec.Bsc_Dim_Tot_Disp_Name           :=  p_all_item_text;--BSC_SYS_DIM_LEVELS_TL.total_disp_name
    l_bsc_dim_obj_rec.Bsc_Language                    :=  NULL;--BSC_SYS_DIM_LEVELS_TL.language
    l_bsc_dim_obj_rec.Bsc_Level_Column_Name           :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Level_Column_Type           :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Level_Comp_Order_By         :=  p_comparison_order;--BSC_SYS_DIM_LEVELS_B.comp_order_by
    l_bsc_dim_obj_rec.Bsc_Level_Custom_Group          :=  0;--BSC_SYS_DIM_LEVELS_B.custom_group
    l_bsc_dim_obj_rec.Bsc_Level_Index                 :=  0;
    l_bsc_dim_obj_rec.Bsc_Level_Table_Type            :=  1;--BSC_SYS_DIM_LEVELS_B.table_type
    l_bsc_dim_obj_rec.Bsc_Level_Value_Order_By        :=  p_dimension_values_order;--BSC_SYS_DIM_LEVELS_B.value_order_by
    l_bsc_dim_obj_rec.Bsc_Source_Language             :=  NULL;--source_lang
    l_bsc_dim_obj_rec.Bsc_Source_Level_Long_Name      :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Relation_Column             :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Relation_Type               :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Parent_Level_Id             :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Parent_Level_Index          :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Parent_Level_Short_Name     :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Parent_Level_Source         :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Flag                        :=  NULL;
    IF (l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
        l_level_table_name                :=  l_bsc_dim_obj_rec.Bsc_Level_Name;
        l_bsc_dim_obj_rec.Bsc_Level_Name  :=  l_bsc_dim_obj_rec.Bsc_Level_View_Name;
    END IF;
    BSC_DIMENSION_LEVELS_PUB.Create_Dim_Level
    (       p_commit            =>  FND_API.G_FALSE
         ,  p_Dim_Level_Rec     =>  l_bsc_dim_obj_rec
         ,  p_create_tables     =>  FALSE
         ,  x_return_status     =>  x_return_status
         ,  x_msg_count         =>  x_msg_count
         ,  x_msg_data          =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
        BSC_BIS_DIM_OBJ_PUB.Assign_Dimensions
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_dim_obj_short_name    =>  l_dim_obj_name
            ,   p_dim_short_names       =>  BSC_BIS_DIMENSION_PUB.Unassigned_Dim
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        BSC_BIS_DIM_OBJ_PUB.Set_All_Enable_Flag
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_Dim_Obj_Short_Name    =>  l_dim_obj_name
            ,   p_All_Enabled           =>  p_All_Enabled
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    IF (p_dim_short_names IS NOT NULL) THEN
        BSC_BIS_DIM_OBJ_PUB.Assign_Unassign_Dimensions
        (       p_commit                        =>  FND_API.G_FALSE
            ,   p_dim_obj_short_name            =>  l_dim_obj_name
            ,   p_assign_dim_short_names        =>  p_dim_short_names
            ,   p_unassign_dim_short_names      =>  BSC_BIS_DIMENSION_PUB.Unassigned_Dim
            ,   p_Restrict_Dim_Validate         =>  p_Restrict_Dim_Validate
            ,   x_return_status                 =>  x_return_status
            ,   x_msg_count                     =>  x_msg_count
            ,   x_msg_data                      =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;

    /* Set 'All' flag for BSC type dim objects (specific to RPD)
       'All' flag is not supported from Dimension Designer for BSC type dim objects
       from Create/Update Dim Object screen. Only from RPD, 'All' flag can be '0' in
       Create case.
    */
    IF ((l_bsc_dim_obj_rec.Bsc_Source = 'BSC') AND (p_dim_short_names IS NOT NULL)) THEN
      BSC_BIS_DIM_OBJ_PUB.Set_Bsc_All_Enable_Flag
      ( p_commit                =>  FND_API.G_FALSE
      , p_Dim_Obj_Short_Name    =>  l_dim_obj_name
      , p_All_Enabled           =>  p_All_Enabled
      , x_return_status         =>  x_return_status
      , x_msg_count             =>  x_msg_count
      , x_msg_data              =>  x_msg_data
      );
    END IF;
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (l_bsc_dim_obj_rec.Bsc_Source = 'BSC') THEN
        l_flag  :=  BSC_BIS_DIM_OBJ_PUB.Create_Bsc_Master_Tabs
                    (       p_Dim_Level_Rec     =>  l_bsc_dim_obj_rec
                        ,   x_return_status     =>  x_return_status
                        ,   x_msg_count         =>  x_msg_count
                        ,   x_msg_data          =>  x_msg_data
                    );
        IF(NOT l_flag) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSIF (l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
        IF ((l_bsc_dim_obj_rec.Source = 'OLTP') OR (l_bsc_dim_obj_rec.Source = 'EDW')) THEN
            l_bsc_dim_obj_rec.Bsc_Level_Name  :=  l_level_table_name;
            l_flag  :=  BSC_BIS_DIM_OBJ_PUB.Create_Pmf_Views
                        (       p_Dim_Level_Rec     =>  l_bsc_dim_obj_rec
                            ,   x_return_status     =>  x_return_status
                            ,   x_msg_count         =>  x_msg_count
                            ,   x_msg_data          =>  x_msg_data
                        );
            IF(NOT l_flag) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        ELSE
            FND_MESSAGE.SET_NAME('BSC','BSC_PRE_DIM_OBJ_SOURCE_TYPE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    /********************************************************
      Check no of independent dimension objects in dimension set
    ********************************************************/

    check_indp_dimobjs
    (
            p_dim_id                    =>  l_bsc_dim_obj_rec.Bsc_Level_Id
        ,   x_return_status             =>  x_return_status
        ,   x_msg_count                 =>  x_msg_count
        ,   x_msg_data                  =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    /***********************************************************/


    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_Master_Level%ISOPEN) THEN
            CLOSE c_Master_Level;
        END IF;
        ROLLBACK TO CreateBSCDimObjPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_Master_Level%ISOPEN) THEN
            CLOSE c_Master_Level;
        END IF;
        ROLLBACK TO CreateBSCDimObjPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        IF (c_Master_Level%ISOPEN) THEN
            CLOSE c_Master_Level;
        END IF;
        ROLLBACK TO CreateBSCDimObjPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object ';
        END IF;
    WHEN OTHERS THEN
        IF (c_Master_Level%ISOPEN) THEN
            CLOSE c_Master_Level;
        END IF;
        ROLLBACK TO CreateBSCDimObjPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Create_Dim_Object ';
        END IF;
END Create_Dim_Object;

/*********************************************************************************
                          ASSIGN DIMENSIONS TO DIMENSION OBJECT
*********************************************************************************/
PROCEDURE Assign_Dimensions
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_short_name    IN              VARCHAR2
    ,   p_dim_short_names       IN              VARCHAR2
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    l_dim_short_names       VARCHAR2(32000);
    l_dim_name              BSC_SYS_DIM_GROUPS_TL.short_name%TYPE;
    l_dim_grp_id            BSC_SYS_DIM_GROUPS_TL.Dim_Group_Id%TYPE;

    l_count                 NUMBER;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_dim_obj_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_dim_short_names IS NOT NULL) THEN
        l_dim_short_names   :=  p_dim_short_names;
        WHILE (is_more(     p_dim_short_names   =>  l_dim_short_names
                        ,   p_dim_name          =>  l_dim_name)
        ) LOOP
            -- Granular Locking - Set the timestamp of Dimension Group
            l_dim_grp_id    :=  NVL(BSC_DIMENSION_GROUPS_PVT.get_Dim_Group_Id(l_dim_name), -1);
            BSC_BIS_LOCKS_PUB.Set_Time_Stamp_Dim_Group
            (    p_dim_group_id      =>  l_dim_grp_id
              ,  x_return_status     =>  x_return_status
              ,  x_msg_count         =>  x_msg_count
              ,  x_msg_data          =>  x_msg_data
            );
            IF ((x_return_status  =  FND_API.G_RET_STS_ERROR)  OR (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- Granular Locking - Set the timestamp of Dimension Group
            SELECT COUNT(1) INTO l_count
            FROM   BSC_SYS_DIM_LEVELS_BY_GROUP A
                 , BSC_SYS_DIM_LEVELS_B        B
            WHERE  A.Dim_Group_Id = l_dim_grp_id
            AND    A.Dim_Level_Id = B.Dim_Level_Id
            AND    B.Short_Name   = p_dim_obj_short_name;
            IF (l_count = 0) THEN
                BSC_BIS_DIMENSION_PUB.Assign_Dimension_Objects
                (       p_commit                =>  FND_API.G_FALSE
                    ,   p_dim_short_name        =>  l_dim_name
                    ,   p_dim_obj_short_names   =>  p_dim_obj_short_name
                    ,   p_time_stamp            =>  NULL
                    ,   x_return_status         =>  x_return_status
                    ,   x_msg_count             =>  x_msg_count
                    ,   x_msg_data              =>  x_msg_data
                );
                IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
        END LOOP;
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
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Assign_Dimensions ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Assign_Dimensions ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Assign_Dimensions ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Assign_Dimensions ';
        END IF;
END Assign_Dimensions;

/*********************************************************************************
                          ASSIGN DIMENSIONS TO DIMENSION OBJECT
*********************************************************************************/
PROCEDURE Unassign_Dimensions
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_short_name    IN              VARCHAR2
    ,   p_dim_short_names       IN              VARCHAR2
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    l_dim_short_names       VARCHAR2(32000);
    l_dim_name              BSC_SYS_DIM_GROUPS_TL.short_name%TYPE;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_dim_obj_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_dim_short_names IS NOT NULL) THEN
        l_dim_short_names   :=  p_dim_short_names;
        WHILE (is_more(     p_dim_short_names   =>  l_dim_short_names
                        ,   p_dim_name          =>  l_dim_name)
        ) LOOP

            -- Granular Locking - Set the timestamp of Dimension Group
            BSC_BIS_LOCKS_PUB.Set_Time_Stamp_Dim_Group
            (    p_dim_group_id      =>  NVL(BSC_DIMENSION_GROUPS_PVT.get_Dim_Group_Id(l_dim_name), -1)
              ,  x_return_status     =>  x_return_status
              ,  x_msg_count         =>  x_msg_count
              ,  x_msg_data          =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- Granular Locking - Set the timestamp of Dimension Group
            BSC_BIS_DIMENSION_PUB.Unassign_Dimension_Objects
            (       p_commit                =>  FND_API.G_FALSE
                ,   p_dim_short_name        =>  l_dim_name
                ,   p_dim_obj_short_names   =>  p_dim_obj_short_name
                ,   x_return_status         =>  x_return_status
                ,   x_msg_count             =>  x_msg_count
                ,   x_msg_data              =>  x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END LOOP;
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
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Unassign_Dimensions ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Unassign_Dimensions ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Unassign_Dimensions ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Unassign_Dimensions ';
        END IF;
END Unassign_Dimensions;

/*********************************************************************************
                          RESTRICT INTERNAL DIMENSION FOR USE IN DD
*********************************************************************************/
PROCEDURE Restrict_Internal_Dimensions
(       p_dim_obj_short_name            IN              VARCHAR2
    ,   p_assign_dim_short_names        IN              VARCHAR2
    ,   p_unassign_dim_short_names      IN              VARCHAR2
    ,   x_return_status                 OUT    NOCOPY   VARCHAR2
    ,   x_msg_count                     OUT    NOCOPY   NUMBER
    ,   x_msg_data                      OUT    NOCOPY   VARCHAR2
) IS
  l_assigns             VARCHAR2(32000);
  l_assign              BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
  l_assign_dim          VARCHAR2(32000);
  l_count               NUMBER;
BEGIN
    -- It is to find values from p_assign_dim_short_names which are not already assigned.
    l_assigns := p_assign_dim_short_names;
    WHILE (is_more(     p_dim_short_names   =>  l_assigns
                    ,   p_dim_name          =>  l_assign)
        ) LOOP
            SELECT COUNT(1)
            INTO l_count
            FROM BSC_SYS_DIM_LEVELS_BY_GROUP A
                ,BSC_SYS_DIM_LEVELS_B L
                ,BSC_SYS_DIM_GROUPS_TL D
            WHERE D.SHORT_NAME = l_assign
            AND   L.SHORT_NAME = p_dim_obj_short_name
            AND   L.DIM_LEVEL_ID = A.DIM_LEVEL_ID
            AND   D.DIM_GROUP_ID = A.DIM_GROUP_ID;

            IF(l_count = 0) THEN
              IF (l_assign_dim IS NULL) THEN
                  l_assign_dim    :=  l_assign;
              ELSE
                  l_assign_dim    :=  l_assign_dim||','||l_assign;
              END IF;
            END IF;
    END LOOP;
    IF (p_unassign_dim_short_names IS NOT NULL) THEN
      IF (l_assign_dim IS NULL) THEN
        l_assign_dim := p_unassign_dim_short_names;
      ELSE
        l_assign_dim := l_assign_dim ||','||p_unassign_dim_short_names;
      END IF;
    END IF;
    BSC_UTILITY.Enable_Dimensions_Entity(
        p_Entity_Type           => BSC_UTILITY.c_DIMENSION
      , p_Entity_Short_Names    => l_assign_dim
      , p_Entity_Action_Type    => BSC_UTILITY.c_UPDATE
      , x_Return_Status         => x_return_status
      , x_Msg_Count             => x_msg_count
      , x_Msg_Data              => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


END Restrict_Internal_Dimensions;


/*********************************************************************************
                          ASSIGN DIMENSIONS TO DIMENSION OBJECT
*********************************************************************************/
PROCEDURE Assign_Unassign_Dimensions
(       p_commit                        IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_short_name            IN              VARCHAR2
    ,   p_assign_dim_short_names        IN              VARCHAR2
    ,   p_unassign_dim_short_names      IN              VARCHAR2
    ,   p_Restrict_Dim_Validate         IN              VARCHAR2   := NULL
    ,   x_return_status                 OUT    NOCOPY   VARCHAR2
    ,   x_msg_count                     OUT    NOCOPY   NUMBER
    ,   x_msg_data                      OUT    NOCOPY   VARCHAR2
) IS
  l_unassigns           VARCHAR2(32000);
  l_assigns             VARCHAR2(32000);
  l_unassign            BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;
  l_assign              BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE;

  l_unassign_dims       VARCHAR2(32000);
  l_temp                VARCHAR2(32000);
  l_regions             VARCHAR2(32000);
  l_dim_name            VARCHAR2(300);
  l_dim_obj_name        VARCHAR2(300);
  l_flag                BOOLEAN;

BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (p_dim_obj_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_unassign_dim_short_names IS NOT NULL) THEN
        l_unassigns   :=  p_unassign_dim_short_names;
        WHILE (is_more(     p_dim_short_names   =>  l_unassigns
                        ,   p_dim_name          =>  l_unassign)
        ) LOOP
            l_assigns   :=  p_assign_dim_short_names;
            l_flag      :=  TRUE;
            WHILE (is_more(     p_dim_short_names   =>  l_assigns
                            ,   p_dim_name          =>  l_assign)
            ) LOOP
                IF(l_unassign = l_assign) THEN
                    l_flag  :=  FALSE;
                    EXIT;
                END IF;
            END LOOP;
            IF(l_flag) THEN
                IF (l_unassign_dims IS NULL) THEN
                    l_unassign_dims    :=  l_unassign;
                ELSE
                    l_unassign_dims    :=  l_unassign_dims||', '||l_unassign;
                END IF;

                IF (l_unassign <> BSC_BIS_DIMENSION_PUB.Unassigned_Dim) THEN

                  l_regions := BSC_UTILITY.Is_Dim_In_AKReport(l_unassign||'+'||p_dim_obj_short_name);
                  IF(l_regions IS NOT NULL) THEN
                    SELECT DIM_NAME
                    INTO   l_dim_name
                    FROM   BSC_BIS_DIM_VL
                    WHERE  SHORT_NAME = l_unassign;

                    SELECT NAME
                    INTO   l_dim_obj_name
                    FROM   BSC_BIS_DIM_OBJS_VL
                    WHERE  SHORT_NAME = p_dim_obj_short_name;

                    FND_MESSAGE.SET_NAME('BIS','BIS_DIM_OBJ_RPTASSOC_ERROR');
                    FND_MESSAGE.SET_TOKEN('DIM_NAME', l_dim_name);
                    FND_MESSAGE.SET_TOKEN('DIM_OBJ_NAME', l_dim_obj_name);
                    FND_MESSAGE.SET_TOKEN('REPORTS_ASSOC', l_regions);
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
                  END IF;
                END IF;
            END IF;
        END LOOP;
        IF (l_unassign_dims IS NOT NULL) THEN
            BSC_BIS_DIM_OBJ_PUB.Unassign_Dimensions
            (       p_commit                =>  FND_API.G_FALSE
                ,   p_dim_obj_short_name    =>  p_dim_obj_short_name
                ,   p_dim_short_names       =>  l_unassign_dims
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
      Restrict_Internal_Dimensions
      (       p_dim_obj_short_name            => p_dim_obj_short_name
          ,   p_assign_dim_short_names        => p_assign_dim_short_names
          ,   p_unassign_dim_short_names      => l_unassign_dims
          ,   x_return_status                 => x_return_status
          ,   x_msg_count                     => x_msg_count
          ,   x_msg_data                      => x_msg_data
      );
    END IF;
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_assign_dim_short_names IS NOT NULL) THEN
        BSC_BIS_DIM_OBJ_PUB.Assign_Dimensions
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_dim_obj_short_name    =>  p_dim_obj_short_name
            ,   p_dim_short_names       =>  p_assign_dim_short_names
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    -- Bug 3784852 validate empty dimension after unassign/assign dim objs. Remove empty from dim sets for all objectives
    IF (p_unassign_dim_short_names IS NOT NULL) THEN
        BSC_BIS_DIMENSION_PUB.Remove_Empty_Dims_For_DimSet
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_dim_short_names       =>  p_unassign_dim_short_names
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
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
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Assign_Unassign_Dimensions ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Assign_Unassign_Dimensions ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Assign_Unassign_Dimensions ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Assign_Unassign_Dimensions ';
        END IF;
END Assign_Unassign_Dimensions;

FUNCTION Retrieve_Primary_Dimension(
  p_Dim_Obj_Short_Name      IN    VARCHAR2
) RETURN VARCHAR2 IS
    l_Dim_Short_Name BIS_DIMENSIONS.SHORT_NAME%TYPE;
    CURSOR  c_Bis_Levels IS
    SELECT  B.Short_Name
    FROM    BIS_LEVELS     A
         ,  BIS_DIMENSIONS B
    WHERE   A.Short_Name   = p_Dim_Obj_Short_Name
    AND     A.Dimension_Id = B.Dimension_Id;
BEGIN
     OPEN  c_Bis_Levels;
     FETCH   c_Bis_Levels  INTO    l_Dim_Short_Name;
     CLOSE  c_Bis_Levels;
     RETURN l_Dim_Short_Name;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END   Retrieve_Primary_Dimension;

/*********************************************************************************
                            UPDATE DIMENSION
*********************************************************************************/
/*
    This procedure allows user to update a dimension. These changes will
    be reflected into the following metadata: -
        1  BIS_LEVELS.
        2. BIS_LEVELS_TL
        3. BSC_SYS_DIM_LEVELS_B
        4. BSC_SYS_DIM_LEVELS_TL

    Key:
        'p_dim_obj_short_name'

    Validations:
        1. p_dimension_id, p_dim_obj_short_name, p_display_name, p_data_source,  p_application_id
           and p_source_type must not be null.
        2. p_dim_obj_short_name and p_display_name must be unique.
*/
PROCEDURE Update_Dim_Object
(       p_commit                    IN          VARCHAR2   :=  FND_API.G_TRUE
    ,   p_dim_obj_short_name        IN          VARCHAR2
    ,   p_display_name              IN          VARCHAR2
    ,   p_application_id            IN          NUMBER
    ,   p_description               IN          VARCHAR2
    ,   p_data_source               IN          VARCHAR2
    ,   p_source_table              IN          VARCHAR2
    ,   p_where_clause              IN          VARCHAR2   :=  NULL
    ,   p_comparison_label_code     IN          VARCHAR2
    ,   p_table_column              IN          VARCHAR2
    ,   p_source_type               IN          VARCHAR2
    ,   p_maximum_code_size         IN          NUMBER
    ,   p_maximum_name_size         IN          NUMBER
    ,   p_all_item_text             IN          VARCHAR2
    ,   p_comparison_item_text      IN          VARCHAR2
    ,   p_prototype_default_value   IN          VARCHAR2
    ,   p_dimension_values_order    IN          NUMBER
    ,   p_comparison_order          IN          NUMBER
    ,   p_assign_dim_short_names    IN          VARCHAR2
    ,   p_unassign_dim_short_names  IN          VARCHAR2
    ,   p_time_stamp                IN          VARCHAR2   :=  NULL    -- Granular Locking
    ,   p_Master_Level              IN          VARCHAR2   :=  NULL
    ,   p_Long_Lov                  IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   p_Search_Function           IN          VARCHAR2   :=  NULL
    ,   p_Dim_Obj_Enabled           IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   p_View_Object_Name          IN          VARCHAR2   :=  NULL
    ,   p_Default_Values_Api        IN          VARCHAR2   :=  NULL
    ,   p_All_Enabled               IN          NUMBER     :=  NULL
    ,   p_Drill_To_Form_Function    IN          VARCHAR2   :=  NULL
    ,   p_Restrict_Dim_Validate     IN          VARCHAR2   := NULL
    ,   p_Hide                      IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   x_return_status             OUT NOCOPY  VARCHAR2
    ,   x_msg_count                 OUT NOCOPY  NUMBER
    ,   x_msg_data                  OUT NOCOPY  VARCHAR2
) IS
    l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
    l_bis_dim_level_rec     BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
    l_bsc_dim_obj_rec       BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
    l_bsc_drop_tables       BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
    l_MTab_Tbl              BSC_BIS_DIM_OBJ_PUB.KPI_Dim_Set_Table_Type;

    l_temp_var              BSC_SYS_DIM_LEVELS_B.abbreviation%TYPE;
    l_source_table          VARCHAR(33);
    l_bsc_dim_id            BSC_SYS_DIM_LEVELS_B.Dim_Level_Id%TYPE;
    l_level_table_name      BIS_LEVELS.LEVEL_VALUES_VIEW_NAME%TYPE;
    l_dim_obj_name          BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE;
    l_dim_Grp_name          BSC_SYS_DIM_GROUPS_TL.short_name%TYPE;
    l_application_id        BIS_LEVELS.Application_Id%TYPE;
    l_bis_short_name        BIS_LEVELS.Short_Name%TYPE;
    l_bis_name              BIS_LEVELS_TL.Name%TYPE;
    l_flag                  BOOLEAN := FALSE;
    l_struct_change         BOOLEAN := FALSE;
    l_child_struc           BOOLEAN := FALSE;
    l_create_pmf            BOOLEAN := FALSE;--must be false
    l_create_bsc            BOOLEAN := FALSE;--must be false
    l_mix_type_dim          BOOLEAN ;
    l_duplicate_flag        BOOLEAN ;


    l_Dim_Tab               BSC_BIS_LOCKS_PUB.t_numberTable;
    l_dim_Grp_names         VARCHAR2(32000);
    l_dim_short_names       VARCHAR2(32000);
    l_child_dim_obj_list    VARCHAR2(32000);
    l_pmf_disp_name         VARCHAR2(255); -- DispName

    l_index                 NUMBER := 0;
    l_count                 NUMBER;

    CURSOR  c_dimension_names IS
    SELECT  short_name
    FROM    BSC_SYS_DIM_GROUPS_VL
    WHERE   dim_group_id IN (SELECT dim_group_id
    FROM    BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE   dim_level_id = l_bsc_dim_obj_rec.Bsc_Level_Id);

    CURSOR  c_kpi_dim_set IS
    SELECT  DISTINCT A.indicator  Indicator
        ,   A.dim_set_id          Dim_Set_Id
    FROM    BSC_KPI_DIM_LEVELS_B    A
        ,   BSC_SYS_DIM_LEVELS_B    D
        ,   BSC_KPIS_B              B
    WHERE   A.Level_Table_Name      =  D.Level_Table_Name
    AND     B.Indicator             =  A.Indicator
    AND     B.Share_Flag           <>  2
    AND     D.Dim_Level_Id          =  l_bsc_dim_obj_rec.Bsc_Level_Id;

    /* ADDED BY RAVI *********/
    CURSOR  c_dim_short_name IS
    SELECT  B.SHORT_NAME
    FROM    BIS_LEVELS      A
         ,  BIS_DIMENSIONS  B
    WHERE   B.DIMENSION_ID  =   A.DIMENSION_ID
    AND     A.SHORT_NAME    =   p_dim_obj_short_name;
    --dimension_level_short_name = p_dim_obj_short_name;
    l_dim_short_name       BIS_DIMENSIONS.short_name%TYPE;
    l_dim_exist            BOOLEAN := FALSE;
    l_first_dim_short_name BIS_DIMENSIONS.short_name%TYPE;
    l_first                BOOLEAN := TRUE;
    l_primary_dim_sht_name BIS_DIMENSIONS.short_name%TYPE;
    /********************************/

    CURSOR c_Master_Level IS
    SELECT Short_Name
         , Master_Level
         , Name
    FROM   BIS_LEVELS_VL
    WHERE  Short_Name = p_Master_Level;


   CURSOR  c_Kpi_Dim_Set1 IS
   SELECT DISTINCT A.INDICATOR Indicator,
          A.DIM_SET_ID Dim_Set_Id
   FROM   BSC_KPI_DIM_LEVELS_VL A,
          BSC_SYS_DIM_LEVELS_VL B,
          BSC_KPIS_B            C
   WHERE  A.LEVEL_TABLE_NAME=B.LEVEL_TABLE_NAME
   AND    C.INDICATOR = A.INDICATOR
   AND    C.SHARE_FLAG <> 2
   AND    INSTR(','||l_child_dim_obj_list||',', ','||b.dim_level_id||',') > 0;
   ------------------------------------------------------------------

BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT UpdateBSCDimObjectPMD;
    IF(p_dim_obj_short_name IS NOT NULL) THEN
        l_application_id    :=  p_application_id;
    END IF;
    l_dim_obj_name      :=  p_dim_obj_short_name;

    IF (l_dim_obj_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
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
    IF (p_data_source = 'BSC') THEN
        l_bsc_dim_obj_rec.Source        :=  'OLTP';
    ELSE
        IF ((p_source_type IS NULL) OR ((p_source_type <> 'OLTP') AND (p_source_type <> 'EDW'))) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SOURCE_TYPE');
            FND_MSG_PUB.ADD;
            RAISE           FND_API.G_EXC_ERROR;
        ELSE
            l_bsc_dim_obj_rec.Source    :=  p_source_type;
        END IF;
    END IF;

    --check if short_name exists in the PMF system
    SELECT  COUNT(1) INTO l_count
    FROM    BIS_LEVELS
    WHERE   short_name  =   l_dim_obj_name;
    IF (l_count = 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIMENSION_OBJECT'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --check if short_name exists in the BSC system
    SELECT  COUNT(1)  INTO    l_count
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   Short_Name  =   l_dim_obj_name;
    IF (l_count = 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIMENSION_OBJECT'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    SELECT   dim_level_id
           , level_table_name
           , user_key_size
           , disp_key_size
           , NVL(source, 'BSC')
           , abbreviation
           , level_pk_col
           , name
           , level_view_name
    INTO     l_bsc_dim_obj_rec.Bsc_Level_Id
           , l_bsc_dim_obj_rec.Bsc_Level_Name          --p_source_table
           , l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size --p_maximum_code_size
           , l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size --p_maximum_name_size
           , l_bsc_dim_obj_rec.Bsc_Source              --p_data_source
           , l_bsc_dim_obj_rec.Bsc_Level_Abbreviation  --p_prototype_default_value
           , l_bsc_dim_obj_rec.Bsc_Pk_Col              --p_table_column
           , l_bis_dim_level_rec.Dimension_Level_Name
           , l_bsc_dim_obj_rec.Bsc_Level_View_Name
    FROM     BSC_SYS_DIM_LEVELS_VL
    WHERE    short_name = l_dim_obj_name;
    --check uniqueness of display name
    IF (p_display_name IS NOT NULL) THEN
        l_pmf_disp_name := p_display_name;
        IF (p_display_name <> l_bis_dim_level_rec.Dimension_Level_Name) THEN
             IF (p_data_source = 'PMF') THEN
                 SELECT  COUNT(1) INTO l_count
                 FROM    BIS_LEVELS_VL
                 WHERE   UPPER(short_name) <> UPPER(l_dim_obj_name)
                 AND     UPPER(name)       =  UPPER(p_display_name);
                 IF (l_count <> 0) THEN
                     FND_MESSAGE.SET_NAME('BSC','BSC_UNIQUE_NAME_REQUIRED');
                     FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DISPLAY_NAME'), TRUE);
                     FND_MESSAGE.SET_TOKEN('NAME_VALUE', p_display_name);
                     FND_MSG_PUB.ADD;
                     RAISE FND_API.G_EXC_ERROR;
                 END IF;
             ELSIF (p_data_source = 'BSC') THEN   -- Allow insertion into BSC Data Model, with the same display name
                 SELECT  COUNT(1) INTO l_count
                 FROM    BIS_LEVELS_VL
                 WHERE   UPPER(short_name) <> UPPER(l_dim_obj_name)
                 AND     UPPER(name)       =  UPPER(l_pmf_disp_name);

                 WHILE(l_count > 0) LOOP
                     l_pmf_disp_name := BSC_UTILITY.get_Next_DispName(l_pmf_disp_name);
                     SELECT  COUNT(1) INTO l_count
                     FROM    BIS_LEVELS_VL
                     WHERE   UPPER(name) = UPPER(l_pmf_disp_name);
                 END LOOP;
             END IF;
        END IF;
    END IF;
    ---Check the dimensions that are being attached may contain both autogenerated and existing
    -- source type because of this
    l_mix_type_dim := FALSE;
        IF(p_assign_dim_short_names IS NOT NULL) THEN
        l_mix_type_dim := check_sametype_dims
                            (       p_dim_obj_name          =>  p_display_name
                                ,   p_dim_obj_short_name    =>  p_dim_obj_short_name
                                ,   p_dim_obj_source        =>  p_data_source
                                ,   p_dim_short_names       =>  p_assign_dim_short_names
                                ,   p_Restrict_Dim_Validate =>  p_Restrict_Dim_Validate
                                ,   x_return_status         =>  x_return_status
                                ,   x_msg_count             =>  x_msg_count
                                ,   x_msg_data              =>  x_msg_data
                            );
        IF (l_mix_type_dim) THEN
            RAISE  FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    --intialize records with existing values
    l_bsc_drop_tables.Bsc_Level_Id              :=  l_bsc_dim_obj_rec.Bsc_Level_Id;
    l_bsc_drop_tables.Bsc_Level_Name            :=  l_bsc_dim_obj_rec.Bsc_Level_Name;
    l_bsc_drop_tables.Bsc_Level_User_Key_Size   :=  l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size;
    l_bsc_drop_tables.Bsc_Level_Disp_Key_Size   :=  l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size;
    l_bsc_drop_tables.Bsc_Source                :=  l_bsc_dim_obj_rec.Bsc_Source;
    l_bsc_drop_tables.Bsc_Level_Abbreviation    :=  l_bsc_dim_obj_rec.Bsc_Level_Abbreviation;
    l_bsc_drop_tables.Bsc_Pk_Col                :=  l_bsc_dim_obj_rec.Bsc_Pk_Col;
    l_bsc_drop_tables.Bsc_Level_View_Name       :=  l_bsc_dim_obj_rec.Bsc_Level_View_Name;

    --BSC_SYS_DIM_LEVELS_B.dim_level_id
    -- Dimension Object type can not be changed (BSC/PMF).
    IF ((p_data_source IS NOT NULL) AND (l_bsc_dim_obj_rec.Bsc_Source <> p_data_source)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_NO_UPDATE_DATA_SOURCE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_source_table  :=  p_source_table;
    IF ((p_source_table IS NOT NULL) AND (l_bsc_dim_obj_rec.Bsc_Source = 'BSC') AND (INSTR(l_source_table, 'BSC_D_') <> 1)) THEN
        l_source_table  :=  'BSC_D_'||UPPER(l_source_table);
    END IF;

    IF((LENGTHB(l_source_table) > 27) AND (l_bsc_dim_obj_rec.Bsc_Source = 'BSC')) THEN

                FND_MESSAGE.SET_NAME('BSC','BSC_DIM_OBJ_TABLE_NAME');
                FND_MESSAGE.SET_TOKEN('TAB_NAME', l_source_table);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_bsc_dim_obj_rec.Bsc_Source = 'BSC') THEN
        IF ((l_bsc_dim_obj_rec.Bsc_Level_Abbreviation <> NVL(p_prototype_default_value, l_bsc_dim_obj_rec.Bsc_Level_Abbreviation)) OR
             (l_bsc_dim_obj_rec.Bsc_Level_Name <> NVL(p_source_table, l_bsc_dim_obj_rec.Bsc_Level_Name)) OR
               (l_bsc_dim_obj_rec.Bsc_Pk_Col <> NVL(p_table_column, l_bsc_dim_obj_rec.Bsc_Pk_Col)) OR
                 (l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size <> NVL(p_maximum_code_size, l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size)) OR
                   (l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size <> NVL(p_maximum_name_size, l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size))) THEN
               l_create_bsc    :=  TRUE;
        END IF;
        IF((l_bsc_dim_obj_rec.Bsc_Level_Name <> NVL(p_source_table, l_bsc_dim_obj_rec.Bsc_Level_Name)) OR
           (l_bsc_dim_obj_rec.Bsc_Pk_Col <> NVL(p_table_column, l_bsc_dim_obj_rec.Bsc_Pk_Col)))THEN
           l_struct_change :=  TRUE;
        END IF;
    END IF;

    IF (l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
        IF (l_bsc_dim_obj_rec.Bsc_Level_Name <> NVL(l_source_table, l_bsc_dim_obj_rec.Bsc_Level_Name)) THEN
            l_create_pmf    :=  TRUE;
        END IF;
    END IF;
    IF (p_source_table IS NOT NULL) THEN
        l_bsc_dim_obj_rec.Bsc_Level_Name            :=  l_source_table;
    END IF;
    IF (p_maximum_code_size IS NOT NULL) THEN
        l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size   :=  p_maximum_code_size;
    END IF;
    IF (p_maximum_name_size IS NOT NULL) THEN
        l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size   :=  p_maximum_name_size;
    END IF;
    IF (p_table_column IS NOT NULL) THEN
        l_bsc_dim_obj_rec.Bsc_Pk_Col    :=  p_table_column;
    END IF;
    IF (p_prototype_default_value IS NOT NULL) THEN
        l_bsc_dim_obj_rec.Bsc_Level_Abbreviation    :=  SUBSTR(p_prototype_default_value, 1, 11);
    END IF;

    l_bsc_dim_obj_rec.Bsc_Level_Short_Name    :=  l_dim_obj_name;--BSC_SYS_DIM_LEVELS_B.short_name

    IF (c_dim_short_name%ISOPEN) THEN
        CLOSE c_dim_short_name;
    END IF;
    OPEN c_dim_short_name;
        FETCH c_dim_short_name INTO l_dim_short_name;
    CLOSE c_dim_short_name;
    l_dim_Grp_names :=  p_assign_dim_short_names;
    IF (p_assign_dim_short_names IS NOT NULL) THEN
        l_dim_Grp_names   :=  p_assign_dim_short_names ;
        WHILE (is_more(     p_dim_short_names   =>  l_dim_Grp_names
                        ,   p_dim_name          =>  l_dim_Grp_name)
        ) LOOP
            IF (l_first) THEN
                l_first                := FALSE;
                l_first_dim_short_name := l_dim_Grp_name;
            END IF;
            IF (l_dim_short_name = l_dim_Grp_name) THEN
                l_dim_exist                             :=  TRUE;
                l_bis_dim_level_rec.Dimension_Short_Name:= l_dim_Grp_name;
            END IF;
            l_Dim_Tab(l_index)  := NVL(BSC_DIMENSION_GROUPS_PVT.get_Dim_Group_Id(l_dim_Grp_name), -1);
            l_index             := l_index + 1;
        END LOOP;
    ELSE
        l_bis_dim_level_rec.Dimension_Short_Name        :=  BSC_BIS_DIMENSION_PUB.Unassigned_Dim;
    END IF;
    IF ((NOT l_dim_exist) AND (NOT l_first)) THEN
        l_bis_dim_level_rec.Dimension_Short_Name  := l_first_dim_short_name;
    END IF;
    l_dim_Grp_names :=  p_unassign_dim_short_names;
    -- Get all the Dimension Group that are going to be Unassigned
    IF (p_unassign_dim_short_names IS NOT NULL) THEN
        l_dim_Grp_names   :=  p_unassign_dim_short_names;
        WHILE (is_more(     p_dim_short_names   =>  l_dim_Grp_names
                        ,   p_dim_name          =>  l_dim_Grp_name)
        ) LOOP
            l_Dim_Tab(l_index) := NVL(BSC_DIMENSION_GROUPS_PVT.get_Dim_Group_Id(l_dim_Grp_name), -1);
            l_index := l_index + 1;
        END LOOP;
    END IF;
    -- Lock all the Dimension Groups to be assigned to the Dimension Objects
    BSC_BIS_LOCKS_PUB.Lock_Update_Dimension_Object
    (    p_Dim_Object_Id          => l_bsc_dim_obj_rec.Bsc_Level_Id
        ,p_Selected_Dimensions    => l_Dim_Tab
        ,p_time_stamp             => p_time_stamp  -- Granular Locking
        ,x_return_status          => x_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- End Granular Locking

    l_bsc_dim_obj_rec.Bsc_Level_Short_Name    :=  l_dim_obj_name;--BSC_SYS_DIM_LEVELS_B.short_name
    --generate unique abbreviation if source is BSC
    IF (l_bsc_dim_obj_rec.Bsc_Source = 'BSC') THEN
        IF ((l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size < l_bsc_drop_tables.Bsc_Level_User_Key_Size)
          OR (l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size < l_bsc_drop_tables.Bsc_Level_Disp_Key_Size)) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_CODE_SIZE_NOT_DECREASED');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF ((l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size < BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Code_Min_Size) OR
              (l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size > BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Code_Max_Size) OR
                (l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size < BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Name_Min_Size) OR
                  (l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size > BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Name_Max_Size)) THEN
                FND_MESSAGE.SET_NAME('BSC','BSC_CODE_NAME_SIZE');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        SELECT COUNT(1) INTO l_count
        FROM   BSC_SYS_DIM_LEVELS_B
        WHERE  UPPER(abbreviation)  = UPPER(l_bsc_dim_obj_rec.Bsc_Level_Abbreviation)
        AND    dim_level_id        <> l_bsc_dim_obj_rec.Bsc_Level_Id
        AND    Source               = 'BSC';
        IF (l_count <> 0) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_UNIQUE_NAME_REQUIRED');
            FND_MESSAGE.SET_TOKEN('SHORT_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'ABBREVIATION'), TRUE);
            FND_MESSAGE.SET_TOKEN('NAME_VALUE', l_bsc_dim_obj_rec.Bsc_Level_Abbreviation);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (l_bsc_dim_obj_rec.Bsc_Level_Name IS NULL) THEN
            l_bsc_dim_obj_rec.Bsc_Level_Name    :=  'BSC_D_'||SUBSTR(REPLACE(l_dim_obj_name, ' ', '_') , 1, 22);
        END IF;
        l_flag  :=  BSC_BIS_DIM_OBJ_PUB.Initialize_Bsc_Recs
                    (       p_Dim_Level_Rec     =>  l_bsc_dim_obj_rec
                        ,   x_return_status     =>  x_return_status
                        ,   x_msg_count         =>  x_msg_count
                        ,   x_msg_data          =>  x_msg_data
                    );
        IF(NOT l_flag) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSIF (l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
        IF ((l_bsc_dim_obj_rec.Source = 'OLTP') OR (l_bsc_dim_obj_rec.Source = 'EDW')) THEN

            l_bsc_dim_obj_rec.Bsc_Level_Name  :=  p_source_table;
            IF((l_bsc_dim_obj_rec.Bsc_Level_Name IS NOT NULL) AND
                (INSTR(l_bsc_dim_obj_rec.Bsc_Level_Name, 'BSC_D_') = 1)) THEN
                l_bsc_dim_obj_rec.Bsc_Level_Name   :=  SUBSTR(l_bsc_dim_obj_rec.Bsc_Level_Name, 7, LENGTH(l_bsc_dim_obj_rec.Bsc_Level_Name));
            END IF;
            l_flag  :=  BSC_BIS_DIM_OBJ_PUB.Initialize_Pmf_Recs
                        (       p_Dim_Level_Rec     =>  l_bsc_dim_obj_rec
                            ,   x_return_status     =>  x_return_status
                            ,   x_msg_count         =>  x_msg_count
                            ,   x_msg_data          =>  x_msg_data
                        );
            IF (NOT l_flag) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        ELSE
            FND_MESSAGE.SET_NAME('BSC','BSC_PRE_DIM_OBJ_SOURCE_TYPE');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    SELECT level_id INTO  l_bis_dim_level_rec.Dimension_Level_ID
    FROM   BIS_LEVELS
    WHERE  short_name = l_dim_obj_name;

    /********DISABLED BY RAVI ****************/
    --l_bis_dim_level_rec.Dimension_Short_Name        :=  'UNASSIGNED';
    l_bis_dim_level_rec.Dimension_ID                :=  get_bis_dimension_id(l_bis_dim_level_rec.Dimension_Short_Name) ;
    /*****************************************/
    l_bis_dim_level_rec.Dimension_Name              :=  NULL;
    l_bis_dim_level_rec.Dimension_Level_Short_Name  :=  l_dim_obj_name;
    l_bis_dim_level_rec.Dimension_Level_Name        :=  l_pmf_disp_name; -- PMF Dimension Name should be different
    l_bis_dim_level_rec.Description                 :=  p_description;
    IF (l_bsc_dim_obj_rec.Bsc_Source = 'BSC') THEN
        l_bis_dim_level_rec.Level_Values_View_Name  := l_bsc_dim_obj_rec.Bsc_Level_Name;
    ELSE
        l_bis_dim_level_rec.Level_Values_View_Name  :=  p_source_table;
    END IF;
    IF ((l_bis_dim_level_rec.Level_Values_View_Name IS NOT NULL) AND
         (NOT is_Valid_Identifier(l_bis_dim_level_rec.Level_Values_View_Name))) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SQL_IDENTIFIER');
        FND_MESSAGE.SET_TOKEN('SQL_IDENT', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_VIEW_NAME'), TRUE);
        FND_MESSAGE.SET_TOKEN('SQL_VALUE', l_bis_dim_level_rec.Level_Values_View_Name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_bis_dim_level_rec.where_Clause            :=  p_where_clause;
    l_bis_dim_level_rec.source                  :=  l_bsc_dim_obj_rec.Source;
    l_bis_dim_level_rec.application_id          :=  l_application_id;
    l_bis_dim_level_rec.Comparison_Label_Code   :=  p_comparison_label_code;
    IF ((p_Long_Lov IS NULL) OR ((p_Long_Lov <> FND_API.G_TRUE) AND (p_Long_Lov <> FND_API.G_FALSE))) THEN
        l_bis_dim_level_rec.Long_Lov            :=  FND_API.G_FALSE;
    ELSE
        l_bis_dim_level_rec.Long_Lov            :=  p_Long_Lov;
    END IF;

    IF ((p_Dim_Obj_Enabled IS NULL) OR ((p_Dim_Obj_Enabled <> FND_API.G_TRUE) AND (p_Dim_Obj_Enabled <> FND_API.G_FALSE))) THEN
        l_bis_dim_level_rec.Enabled                :=  FND_API.G_FALSE;
    ELSE
        l_bis_dim_level_rec.Enabled                :=  p_Dim_Obj_Enabled;
    END IF;

    IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_hide) = FND_API.G_TRUE ) THEN
      l_bis_dim_level_rec.hide := p_hide;
    END IF;

    IF (l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
        IF (p_Default_Values_Api IS NULL) THEN
            l_bis_dim_level_rec.Default_Values_Api :=  p_Default_Values_Api;
        ELSIF (p_Default_Values_Api <> '''''') THEN
            l_bis_dim_level_rec.Default_Values_Api :=  p_Default_Values_Api;
        END IF;
        l_bis_dim_level_rec.View_Object_Name       :=  p_View_Object_Name;
        l_bis_dim_level_rec.Attribute_Code         :=  l_bis_dim_level_rec.Dimension_Level_Short_Name;
    END IF;
    IF ((l_bsc_dim_obj_rec.Bsc_Source = 'PMF') AND (p_Master_Level IS NOT NULL)) THEN
        IF (p_Master_Level = l_bis_dim_level_rec.Dimension_Level_Short_Name) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_PMF_NO_SAME_DO');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (c_Master_Level%ISOPEN) THEN
            CLOSE c_Master_Level;
        END IF;
        OPEN    c_Master_Level;
            FETCH   c_Master_Level
            INTO    l_bis_dim_level_rec.Master_Level
                 ,  l_bis_short_name
                 ,  l_bis_name;
        CLOSE c_Master_Level;
        IF (l_bis_dim_level_rec.Master_Level IS NULL) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_LEVEL_NAME');
            FND_MESSAGE.SET_TOKEN('BSC_LEVEL_NAME', p_Master_Level);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (l_bis_short_name IS NOT NULL) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_PMF_LOV_NO_MASTER');
            FND_MESSAGE.SET_TOKEN('BIS_OBJ_LOV', l_bis_name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        SELECT COUNT(1) INTO l_Count
        FROM   BIS_LEVELS
        WHERE  Master_Level = l_bis_dim_level_rec.Dimension_Level_Short_Name;
        IF (l_Count <> 0) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_PMF_UPD_NO_MASTER');
            FND_MESSAGE.SET_TOKEN('BIS_OBJ_UPD', NVL(l_bis_dim_level_rec.Dimension_Level_Name, l_bis_dim_level_rec.Dimension_Level_Short_Name));
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    l_bis_dim_level_rec.Default_Search     :=  p_Search_Function;
    l_bis_dim_level_rec.Drill_To_Form_Function := p_Drill_To_Form_Function;
    -- Primary_Dim will be used only ine case of LDT upload in update mode it should take as provided from PMD API.
    l_bis_dim_level_rec.Primary_Dim := FND_API.G_TRUE;
    BIS_DIMENSION_LEVEL_PUB.Update_Dimension_Level
    (       p_api_version           =>  1.0
        ,   p_commit                =>  FND_API.G_FALSE
        ,   p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL
        ,   p_Dimension_Level_Rec   =>  l_bis_dim_level_rec
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
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --CALL API TO UPDATE INTO FND_LOOKUP_VALUES

    --CALL BSC API
    --Get BSC Dimension ID into 'l_bsc_dim_id'
    SELECT dim_level_id INTO    l_bsc_dim_id
    FROM   BSC_SYS_DIM_LEVELS_B
    WHERE  UPPER(short_name) = UPPER(l_dim_obj_name);

    l_bsc_dim_obj_rec.Bsc_Dim_Comp_Disp_Name          :=  p_comparison_item_text;
    l_bsc_dim_obj_rec.Bsc_Dim_Level_Long_Name         :=  p_display_name;
    l_bsc_dim_obj_rec.Bsc_Dim_Level_Help              :=  p_description;
    l_bsc_dim_obj_rec.Bsc_Dim_Tot_Disp_Name           :=  p_all_item_text;
    l_bsc_dim_obj_rec.Bsc_Language                    :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Level_Column_Name           :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Level_Column_Type           :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Level_Comp_Order_By         :=  p_comparison_order;
    l_bsc_dim_obj_rec.Bsc_Level_Custom_Group          :=  0;
    l_bsc_dim_obj_rec.Bsc_Level_Index                 :=  0;
    l_bsc_dim_obj_rec.Bsc_Level_Value_Order_By        :=  p_dimension_values_order;
    l_bsc_dim_obj_rec.Bsc_Source_Language             :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Source_Level_Long_Name      :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Relation_Column             :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Relation_Type               :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Parent_Level_Id             :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Parent_Level_Index          :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Parent_Level_Short_Name     :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Parent_Level_Source         :=  NULL;
    l_bsc_dim_obj_rec.Bsc_Flag                        :=  NULL;

    l_count := 0;
    --cascading is required for BSC types of Dimension Objects Only
    FOR cd IN c_kpi_dim_set LOOP
        l_MTab_Tbl(l_count).p_kpi_id      :=  cd.Indicator;
        l_MTab_Tbl(l_count).p_dim_set_id  :=  cd.Dim_Set_Id;
        l_count :=  l_count + 1;
    END LOOP;

    l_child_dim_obj_list := NULL;
    -- If l_child_Struct is true, then we need to refresh the Child Dimension Object's Kpis as well
    IF (l_child_struc) THEN
        l_child_dim_obj_list := Get_Child_Dim_Objs(p_Dim_Level_Id => l_bsc_dim_obj_rec.Bsc_Level_Id);


        IF (l_child_dim_obj_list IS NOT NULL) THEN
            FOR ckds IN c_Kpi_Dim_Set1 LOOP
                l_duplicate_flag := FALSE;
                FOR i IN 0..(l_MTab_Tbl.COUNT-1) LOOP
                    IF(l_MTab_Tbl(i).p_kpi_id=ckds.Indicator)THEN
                    l_duplicate_flag := TRUE;
                    EXIT;
                    END IF;
                END LOOP;
                IF(NOT l_duplicate_flag) THEN
                    l_MTab_Tbl(l_count).p_kpi_id      :=  ckds.Indicator;
                    l_MTab_Tbl(l_count).p_dim_set_id  :=  ckds.Dim_Set_Id;
                    l_count :=  l_count + 1;
                END IF;
            END LOOP;
        END IF;
    END IF;


    FOR i IN 0..(l_MTab_Tbl.COUNT-1) LOOP
        BSC_BIS_KPI_MEAS_PUB.Delete_Dim_Objs_In_DSet
        (       p_commit             =>   FND_API.G_FALSE
            ,   p_kpi_id             =>   l_MTab_Tbl(i).p_kpi_id
            ,   p_dim_set_id         =>   l_MTab_Tbl(i).p_dim_set_id
            ,   x_return_status      =>   x_return_status
            ,   x_msg_count          =>   x_msg_count
            ,   x_msg_data           =>   x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END LOOP;
    IF (l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
        l_level_table_name                :=  l_bsc_dim_obj_rec.Bsc_Level_Name;
        l_bsc_dim_obj_rec.Bsc_Level_Name  :=  l_bsc_dim_obj_rec.Bsc_Level_View_Name;
    END IF;
    BSC_DIMENSION_LEVELS_PUB.Update_Dim_Level
    (       p_commit            =>  FND_API.G_FALSE
        ,   p_Dim_Level_Rec     =>  l_bsc_dim_obj_rec
        ,   x_return_status     =>  x_return_status
        ,   x_msg_count         =>  x_msg_count
        ,   x_msg_data          =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    FOR i IN 0..(l_MTab_Tbl.COUNT-1) LOOP
        IF (l_struct_change) THEN
            BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet
            (       p_commit             =>   FND_API.G_FALSE
                ,   p_kpi_id             =>   l_MTab_Tbl(i).p_kpi_id
                ,   p_dim_set_id         =>   l_MTab_Tbl(i).p_dim_set_id
                ,   x_return_status      =>   x_return_status
                ,   x_msg_count          =>   x_msg_count
                ,   x_msg_data           =>   x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        ELSE
            BSC_BIS_KPI_MEAS_PUB.Create_Dim_Objs_In_DSet
            (       p_commit             =>   FND_API.G_FALSE
                ,   p_kpi_id             =>   l_MTab_Tbl(i).p_kpi_id
                ,   p_dim_set_id         =>   l_MTab_Tbl(i).p_dim_set_id
                ,   p_kpi_flag_change    =>   BSC_DESIGNER_PVT.G_ActionFlag.Normal
                ,   x_return_status      =>   x_return_status
                ,   x_msg_count          =>   x_msg_count
                ,   x_msg_data           =>   x_msg_data
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END LOOP;
    IF (l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
        BSC_BIS_DIM_OBJ_PUB.Set_All_Enable_Flag
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_Dim_Obj_Short_Name    =>  l_bis_dim_level_rec.Dimension_Level_Short_Name
            ,   p_All_Enabled           =>  p_All_Enabled
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    BSC_BIS_DIM_OBJ_PUB.Assign_Unassign_Dimensions
    (       p_commit                        =>  FND_API.G_FALSE
        ,   p_dim_obj_short_name            =>  l_dim_obj_name
        ,   p_assign_dim_short_names        =>  p_assign_dim_short_names
        ,   p_unassign_dim_short_names      =>  p_unassign_dim_short_names
        ,   p_Restrict_Dim_Validate         =>  p_Restrict_Dim_Validate
        ,   x_return_status                 =>  x_return_status
        ,   x_msg_count                     =>  x_msg_count
        ,   x_msg_data                      =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (l_bsc_dim_obj_rec.Bsc_Source = 'PMF') THEN
        BSC_BIS_DIM_OBJ_PUB.Set_All_Enable_Flag
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_Dim_Obj_Short_Name    =>  l_bis_dim_level_rec.Dimension_Level_Short_Name
            ,   p_All_Enabled           =>  p_All_Enabled
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    ELSIF ((l_bsc_dim_obj_rec.Bsc_Source = 'BSC') AND (p_assign_dim_short_names IS NOT NULL) AND (p_unassign_dim_short_names IS NULL) AND (INSTR(p_assign_dim_short_names, ',') = 0)) THEN
      /* Set 'All' flag for BSC type dim objects (specific to Auto Generated RPD - reserved for future)
         We are checking if p_assign_dim_short_names contains only 1 dimension
     and p_unassign_dim_short_names doesn't contain any dimension. This way
     we are safe not to update 'All' flag for other dimension-dim object
     relationships while coming from Dimension Designer.
      */
      BSC_BIS_DIM_OBJ_PUB.Set_Bsc_All_Enable_Flag
      ( p_commit                =>  FND_API.G_FALSE
      , p_Dim_Obj_Short_Name    =>  l_dim_obj_name
      , p_Dim_Short_Name        =>  p_assign_dim_short_names
      , p_All_Enabled           =>  p_All_Enabled
      , x_return_status         =>  x_return_status
      , x_msg_count             =>  x_msg_count
      , x_msg_data              =>  x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    l_primary_dim_sht_name := Retrieve_Primary_Dimension(l_dim_obj_name);
    IF (l_primary_dim_sht_name IS NOT NULL AND l_primary_dim_sht_name <> BSC_BIS_DIMENSION_PUB.Unassigned_Dim) THEN
    -- Bug 4997042
        BSC_BIS_DIM_OBJ_PUB.Cascade_Dim_Props_Into_Dim_Grp (
          p_Dim_Obj_Short_Name   =>  l_dim_obj_name
          , p_Dim_Short_Name     =>  l_primary_dim_sht_name
          , p_All_Flag           =>  p_All_Enabled
          , x_Return_Status      =>  x_return_status
          , x_Msg_Count          =>  x_msg_count
          , x_Msg_Data           =>  x_msg_data
       );
       IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    -- Start Granular Locking
    BSC_BIS_LOCKS_PUB.Set_Time_Stamp_Dim_Level
    (        p_dim_level_id          =>  l_bsc_dim_obj_rec.Bsc_Level_Id
         ,   x_return_status         =>  x_return_status
         ,   x_msg_count             =>  x_msg_count
         ,   x_msg_data              =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF ((l_create_pmf) AND (l_bsc_dim_obj_rec.Bsc_Source = 'PMF')) THEN
        BSC_DIMENSION_LEVELS_PUB.Drop_Dim_Level_Tabs
        (       p_Dim_Level_Rec     =>  l_bsc_drop_tables
            ,   x_return_status     =>  x_return_status
            ,   x_msg_count         =>  x_msg_count
            ,   x_msg_data          =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        l_bsc_dim_obj_rec.Bsc_Level_Name  :=  l_level_table_name;
        l_flag  :=  BSC_BIS_DIM_OBJ_PUB.Create_Pmf_Views
                    (       p_Dim_Level_Rec     =>  l_bsc_dim_obj_rec
                        ,   x_return_status     =>  x_return_status
                        ,   x_msg_count         =>  x_msg_count
                        ,   x_msg_data          =>  x_msg_data
                    );
        IF (NOT l_flag) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    IF ((l_create_bsc) AND (l_bsc_dim_obj_rec.Bsc_Source = 'BSC')) THEN
        l_flag  :=  BSC_BIS_DIM_OBJ_PUB.Alter_Bsc_Master_Tabs
                    (       p_Dim_Level_Rec       =>  l_bsc_dim_obj_rec
                        ,   p_Dim_Level_Rec_Old   =>  l_bsc_drop_tables
                        ,   x_return_status       =>  x_return_status
                        ,   x_msg_count           =>  x_msg_count
                        ,   x_msg_data            =>  x_msg_data
                    );
        IF(NOT l_flag) THEN
            RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    /*************************************************************
     When a dimension object is updated, it is possible to assign
     unassing the dimension objects from the dimensions.It is possible
     that these dimensions might be used in some Kpis and part of the
     list button. so we need to call the Validate_List_Button logic
     here.
    /************************************************************/
    IF (l_bsc_dim_obj_rec.Bsc_Source = 'BSC') THEN
       BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button
       (
                p_Kpi_Id        =>  NULL
          ,     p_Dim_Level_Id  =>  l_bsc_dim_obj_rec.Bsc_Level_Id
          ,     x_return_status =>  x_return_status
          ,     x_msg_count     =>  x_msg_count
          ,     x_msg_data      =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_Master_Level%ISOPEN) THEN
            CLOSE c_Master_Level;
        END IF;
        ROLLBACK TO UpdateBSCDimObjectPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_Master_Level%ISOPEN) THEN
            CLOSE c_Master_Level;
        END IF;
        ROLLBACK TO UpdateBSCDimObjectPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        IF (c_Master_Level%ISOPEN) THEN
            CLOSE c_Master_Level;
        END IF;
        ROLLBACK TO UpdateBSCDimObjectPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        END IF;
    WHEN OTHERS THEN
        IF (c_Master_Level%ISOPEN) THEN
            CLOSE c_Master_Level;
        END IF;
        ROLLBACK TO UpdateBSCDimObjectPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        END IF;
END Update_Dim_Object;

/*********************************************************************************
                            UPDATE DIMENSION
*********************************************************************************/
PROCEDURE Update_Dim_Object
(       p_commit                    IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_short_name        IN          VARCHAR2
    ,   p_display_name              IN          VARCHAR2
    ,   p_application_id            IN          NUMBER
    ,   p_description               IN          VARCHAR2
    ,   p_data_source               IN          VARCHAR2
    ,   p_source_table              IN          VARCHAR2
    ,   p_where_clause              IN          VARCHAR2   :=  NULL
    ,   p_comparison_label_code     IN          VARCHAR2
    ,   p_table_column              IN          VARCHAR2
    ,   p_source_type               IN          VARCHAR2
    ,   p_maximum_code_size         IN          NUMBER
    ,   p_maximum_name_size         IN          NUMBER
    ,   p_all_item_text             IN          VARCHAR2
    ,   p_comparison_item_text      IN          VARCHAR2
    ,   p_prototype_default_value   IN          VARCHAR2
    ,   p_dimension_values_order    IN          NUMBER
    ,   p_comparison_order          IN          NUMBER
    ,   p_time_stamp                IN          VARCHAR2   :=  NULL        -- Granular Locking
    ,   p_Master_Level              IN          VARCHAR2   :=  NULL
    ,   p_Long_Lov                  IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   p_Search_Function           IN          VARCHAR2   :=  NULL
    ,   p_Dim_Obj_Enabled           IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   p_View_Object_Name          IN          VARCHAR2   :=  NULL
    ,   p_Default_Values_Api        IN          VARCHAR2   :=  NULL
    ,   p_All_Enabled               IN          NUMBER     :=  NULL
    ,   p_Drill_To_Form_Function    IN          VARCHAR2   :=  NULL
    ,   p_Hide                      IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   x_return_status             OUT NOCOPY  VARCHAR2
    ,   x_msg_count                 OUT NOCOPY  NUMBER
    ,   x_msg_data                  OUT NOCOPY  VARCHAR2
) IS
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object
    (       p_commit                    =>  FND_API.G_FALSE
        ,   p_dim_obj_short_name        =>  p_dim_obj_short_name
        ,   p_display_name              =>  p_display_name
        ,   p_application_id            =>  p_application_id
        ,   p_description               =>  p_description
        ,   p_data_source               =>  p_data_source
        ,   p_source_table              =>  p_source_table
        ,   p_where_clause              =>  p_where_clause
        ,   p_comparison_label_code     =>  p_comparison_label_code
        ,   p_table_column              =>  p_table_column
        ,   p_source_type               =>  p_source_type
        ,   p_maximum_code_size         =>  p_maximum_code_size
        ,   p_maximum_name_size         =>  p_maximum_name_size
        ,   p_all_item_text             =>  p_all_item_text
        ,   p_comparison_item_text      =>  p_comparison_item_text
        ,   p_prototype_default_value   =>  p_prototype_default_value
        ,   p_dimension_values_order    =>  p_dimension_values_order
        ,   p_comparison_order          =>  p_comparison_order
        ,   p_assign_dim_short_names    =>  NULL
        ,   p_unassign_dim_short_names  =>  NULL
        ,   p_time_stamp                =>  p_time_stamp -- Granular Locking
        ,   p_Master_Level              =>  p_Master_Level
        ,   p_Long_Lov                  =>  p_Long_Lov
        ,   p_Search_Function           =>  p_Search_Function
        ,   p_Dim_Obj_Enabled           =>  p_Dim_Obj_Enabled
        ,   p_View_Object_Name          =>  p_View_Object_Name
        ,   p_Default_Values_Api        =>  p_Default_Values_Api
        ,   p_Drill_To_Form_Function    =>  p_Drill_To_Form_Function
        ,   p_All_Enabled               =>  p_All_Enabled
        ,   p_Hide                      =>  p_Hide
        ,   x_return_status             =>  x_return_status
        ,   x_msg_count                 =>  x_msg_count
        ,   x_msg_data                  =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
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
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        END IF;
END Update_Dim_Object;

/*********************************************************************************
                            UPDATE DIMENSION
*********************************************************************************/
PROCEDURE Update_Dim_Object
(       p_commit                    IN          VARCHAR2    :=  FND_API.G_TRUE
    ,   p_dim_obj_short_name        IN          VARCHAR2
    ,   p_display_name              IN          VARCHAR2
    ,   p_application_id            IN          NUMBER
    ,   p_description               IN          VARCHAR2
    ,   p_data_source               IN          VARCHAR2
    ,   p_source_table              IN          VARCHAR2
    ,   p_where_clause              IN          VARCHAR2    :=  NULL
    ,   p_comparison_label_code     IN          VARCHAR2
    ,   p_table_column              IN          VARCHAR2
    ,   p_source_type               IN          VARCHAR2
    ,   p_maximum_code_size         IN          NUMBER
    ,   p_maximum_name_size         IN          NUMBER
    ,   p_all_item_text             IN          VARCHAR2
    ,   p_comparison_item_text      IN          VARCHAR2
    ,   p_prototype_default_value   IN          VARCHAR2
    ,   p_dimension_values_order    IN          NUMBER
    ,   p_comparison_order          IN          NUMBER
    ,   p_assign_dim_short_names    IN          VARCHAR2
    ,   p_time_stamp                IN          VARCHAR2   :=  NULL        -- Granular Locking
    ,   p_Master_Level              IN          VARCHAR2   :=  NULL
    ,   p_Long_Lov                  IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   p_Search_Function           IN          VARCHAR2   :=  NULL
    ,   p_Dim_Obj_Enabled           IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   p_View_Object_Name          IN          VARCHAR2   :=  NULL
    ,   p_Default_Values_Api        IN          VARCHAR2   :=  NULL
    ,   p_All_Enabled               IN          NUMBER     :=  NULL
    ,   p_Drill_To_Form_Function    IN          VARCHAR2   :=  NULL
    ,   p_Restrict_Dim_Validate     IN          VARCHAR2   := NULL
    ,   p_Hide                      IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   x_return_status             OUT NOCOPY  VARCHAR2
    ,   x_msg_count                 OUT NOCOPY  NUMBER
    ,   x_msg_data                  OUT NOCOPY  VARCHAR2
) IS
    l_dim_level_id          BSC_SYS_DIM_LEVELS_BY_GROUP.dim_level_id%TYPE;
    l_unas_dim_short_names  VARCHAR2(32000);


    CURSOR  cr_bsc_dim_obj IS
    SELECT  dim_level_id
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   short_name     = p_dim_obj_short_name;

    CURSOR  c_dimension_names IS
    SELECT  short_name
    FROM    BSC_SYS_DIM_GROUPS_VL
    WHERE   dim_group_id IN (SELECT dim_group_id
    FROM    BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE   dim_level_id = l_dim_level_id);

BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_dim_obj_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (cr_bsc_dim_obj%ISOPEN) THEN
        CLOSE cr_bsc_dim_obj;
    END IF;
    OPEN    cr_bsc_dim_obj;
        FETCH   cr_bsc_dim_obj
        INTO    l_dim_level_id;
        IF (cr_bsc_dim_obj%ROWCOUNT = 0) THEN
            l_dim_level_id := -1;
        END IF;
    CLOSE cr_bsc_dim_obj;
    IF (l_dim_level_id = -1) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIMENSION_OBJECT'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR cd IN c_dimension_names LOOP
        IF (l_unas_dim_short_names IS NULL) THEN
            l_unas_dim_short_names  :=  cd.short_name;
        ELSE
            l_unas_dim_short_names  :=  l_unas_dim_short_names||', '||cd.short_name;
        END IF;
    END LOOP;
    BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object
    (       p_commit                    =>  FND_API.G_FALSE
        ,   p_dim_obj_short_name        =>  p_dim_obj_short_name
        ,   p_display_name              =>  p_display_name
        ,   p_application_id            =>  p_application_id
        ,   p_description               =>  p_description
        ,   p_data_source               =>  p_data_source
        ,   p_source_table              =>  p_source_table
        ,   p_where_clause              =>  p_where_clause
        ,   p_comparison_label_code     =>  p_comparison_label_code
        ,   p_table_column              =>  p_table_column
        ,   p_source_type               =>  p_source_type
        ,   p_maximum_code_size         =>  p_maximum_code_size
        ,   p_maximum_name_size         =>  p_maximum_name_size
        ,   p_all_item_text             =>  p_all_item_text
        ,   p_comparison_item_text      =>  p_comparison_item_text
        ,   p_prototype_default_value   =>  p_prototype_default_value
        ,   p_dimension_values_order    =>  p_dimension_values_order
        ,   p_comparison_order          =>  p_comparison_order
        ,   p_assign_dim_short_names    =>  p_assign_dim_short_names
        ,   p_unassign_dim_short_names  =>  l_unas_dim_short_names
        ,   p_time_stamp                =>  p_time_stamp        -- Granular Locking
        ,   p_Master_Level              =>  p_Master_Level
        ,   p_Long_Lov                  =>  p_Long_Lov
        ,   p_Search_Function           =>  p_Search_Function
        ,   p_Dim_Obj_Enabled           =>  p_Dim_Obj_Enabled
        ,   p_View_Object_Name          =>  p_View_Object_Name
        ,   p_Default_Values_Api        =>  p_Default_Values_Api
        ,   p_All_Enabled               =>  p_All_Enabled
        ,   p_Drill_To_Form_Function    =>  p_Drill_To_Form_Function
        ,   p_Restrict_Dim_Validate     =>  p_Restrict_Dim_Validate
        ,   p_Hide                      =>  p_Hide
        ,   x_return_status             =>  x_return_status
        ,   x_msg_count                 =>  x_msg_count
        ,   x_msg_data                  =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    /********************************************************
                Check no of independent dimension objects in dimension set
    ********************************************************/

    check_indp_dimobjs
    (
            p_dim_id                    =>  l_dim_level_id
        ,   x_return_status             =>  x_return_status
        ,   x_msg_count                 =>  x_msg_count
        ,   x_msg_data                  =>  x_msg_data
    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE   FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  /********************************************************/
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (cr_bsc_dim_obj%ISOPEN) THEN
            CLOSE cr_bsc_dim_obj;
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
        IF (cr_bsc_dim_obj%ISOPEN) THEN
            CLOSE cr_bsc_dim_obj;
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
        IF (cr_bsc_dim_obj%ISOPEN) THEN
            CLOSE cr_bsc_dim_obj;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        END IF;
    WHEN OTHERS THEN
        IF (cr_bsc_dim_obj%ISOPEN) THEN
            CLOSE cr_bsc_dim_obj;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        END IF;
END Update_Dim_Object;

/*********************************************************************************
                            DELETE DIMENSION
*********************************************************************************/
/*
    This procedure allows user to delete a dimension. Respective records will be
    deleted from the following metadata: -
        1  BIS_LEVELS.
        2. BIS_LEVELS_TL
        3. BSC_SYS_DIM_LEVELS_B
        4. BSC_SYS_DIM_LEVELS_TL

    Validations:
        1. dimension must not be associated with any group.
*/
PROCEDURE Delete_Dim_Object
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_short_name    IN              VARCHAR2
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
) IS
    l_bsc_dimension_rec     BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type;
    l_bsc_dim_obj_rec       BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
    l_bis_dim_level_rec     BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
    l_error_tbl             BIS_UTILITIES_PUB.Error_Tbl_Type;
    l_count                 NUMBER;
    l_dim_short_name        VARCHAR2(30);
    l_regions               VARCHAR2(2000);
    l_is_denorm_deleted     VARCHAR(1);
    l_delete_count          NUMBER := 0;
    l_Sql                   VARCHAR2(8000);

    CURSOR  c_bsc_levels IS
    SELECT  dim_level_id
          , source
          , name
    FROM    BSC_SYS_DIM_LEVELS_VL
    WHERE   short_name = p_dim_obj_short_name;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT DeleteBSCDimObjectPMD;

    IF (p_dim_obj_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- CALL PMF'S API
    --check if short_name exists in the PMF system
    SELECT  COUNT(1) INTO l_count FROM BIS_LEVELS
    WHERE   short_name  =   p_dim_obj_short_name;
    IF (l_count <> 0) THEN
        l_bis_dim_level_rec.Dimension_Level_Short_Name    :=  p_dim_obj_short_name;
        SELECT COUNT(1) INTO l_Count
        FROM   BIS_LEVELS
        WHERE  Master_Level = l_bis_dim_level_rec.Dimension_Level_Short_Name;
        IF (l_Count <> 0) THEN
            FND_MESSAGE.SET_NAME('BIS','BIS_MASTER_DELETE_DIM_OBJ');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        BIS_DIMENSION_LEVEL_PUB.Delete_Dimension_Level
        (       p_commit                =>  FND_API.G_FALSE
            ,   p_validation_level      =>  FND_API.G_VALID_LEVEL_FULL
            ,   p_Dimension_Level_Rec   =>  l_bis_dim_level_rec
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
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        l_delete_count  :=  l_delete_count + 1;
    END IF;

    --check if short_name exists in the BSC system
    IF (c_bsc_levels%ISOPEN) THEN
        CLOSE c_bsc_levels;
    END IF;
    OPEN    c_bsc_levels;
        FETCH   c_bsc_levels
        INTO    l_bsc_dim_obj_rec.Bsc_Level_Id
             ,  l_bsc_dim_obj_rec.Bsc_Source
             ,  l_bsc_dim_obj_rec.Bsc_Dim_Level_Long_Name;
    CLOSE c_bsc_levels;
    IF (l_bsc_dim_obj_rec.Bsc_Level_Id IS NOT NULL) THEN
        -- Granular Locking START
        BSC_BIS_LOCKS_PUB.Lock_Dim_Level
        (     p_dim_level_id       => l_bsc_dim_obj_rec.Bsc_Level_Id
             ,p_time_stamp         => NULL       -- Granular Locking
             ,x_return_status      => x_return_status
             ,x_msg_count          => x_msg_count
             ,x_msg_data            => x_msg_data
        ) ;
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE           FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Granular Locking END
        BSC_BIS_DIM_OBJ_PUB.validateBscDimensionToDelete
        (       p_dim_obj_short_name    =>  p_dim_obj_short_name
            ,   x_return_status         =>  x_return_status
            ,   x_msg_count             =>  x_msg_count
            ,   x_msg_data              =>  x_msg_data
        );
        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE           FND_API.G_EXC_ERROR;
        END IF;
        IF (l_bsc_dim_obj_rec.Bsc_Source = 'BSC') THEN
            BSC_DESIGNER_PVT.Dim_Object_Change(l_bsc_dim_obj_rec.Bsc_Level_Id);
        END IF;
        --remove association with unassigned Dimension if exists
        l_bsc_dimension_rec.Bsc_Dim_Level_Group_Short_Name  := BSC_BIS_DIMENSION_PUB.Unassigned_Dim;
        l_bsc_dimension_rec.Bsc_Level_Id                    := l_bsc_dim_obj_rec.Bsc_Level_Id;
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
        --CALL BSC API
        BSC_DIMENSION_LEVELS_PUB.Delete_Dim_Level
        (       p_commit            =>  FND_API.G_FALSE
             ,  p_Dim_Level_Rec     =>  l_bsc_dim_obj_rec
             ,  x_return_status     =>  x_return_status
             ,  x_msg_count         =>  x_msg_count
             ,  x_msg_data          =>  x_msg_data
        );
        IF ((x_return_status  =  FND_API.G_RET_STS_ERROR)  OR (x_return_status  =  FND_API.G_RET_STS_UNEXP_ERROR)) THEN
            RAISE            FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        /*************************************************************
          List Button validation.For a list button the condition is that
          all the dimesnion sets within the tab (irrespective of whether they are
          in the same KPI or different KPIs) the dimesnion objects should be the same
          So while deleting the dimension object validate if it is being used in
          the tabs.Validate_List_Button takes care of this.
     /************************************************************/
        IF (l_bsc_dim_obj_rec.Bsc_Source = 'BSC') THEN
            BSC_COMMON_DIM_LEVELS_PUB.Validate_List_Button
            (
                p_Kpi_Id         =>  NULL
              , p_Dim_Level_Id   =>  l_bsc_dim_obj_rec.Bsc_Level_Id
              , x_return_status  =>  x_return_status
              , x_msg_count      =>  x_msg_count
              , x_msg_data       =>  x_msg_data
            );

            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
        l_delete_count  :=  l_delete_count + 1;
        /****************************************************
        BSC_PMA_APIS_PUB.sync_dimension_table Should be called only when
        BSC53 is installed.So first we are checking if BSC53 is installed on the
        environment.Since this file is the part of MD/DD ARU we have made the call to
        the PL/SQL procedure "BSC_PMA_APIS_PUB.sync_dimension_table" dynamic so that
        the package gets complied on the pure BIS409 enviornments.
        /****************************************************/
        IF(BIS_UTILITIES_PUB.Enable_Generated_Source_Report = FND_API.G_TRUE) THEN
            l_is_denorm_deleted := FND_API.G_TRUE;
            BEGIN
                l_Sql := 'BEGIN IF(BSC_PMA_APIS_PUB.sync_dimension_table (:2,:3,:4)) THEN :1 :=FND_API.G_TRUE; ELSE :1:=FND_API.G_FALSE; END IF;END;';
                EXECUTE IMMEDIATE l_Sql USING IN p_dim_obj_short_name,IN BIS_UTIL.G_DROP_TABLE,OUT x_msg_data,OUT l_is_denorm_deleted;
            EXCEPTION
              WHEN OTHERS THEN
               NULL;
            END;
            IF(l_is_denorm_deleted=FND_API.G_FALSE) THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;
    END IF;
    IF (l_delete_count  = 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_MUSER_DELETE_MESSAGE');
        FND_MESSAGE.SET_TOKEN('TYPE', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIMENSION_OBJECT'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_bsc_levels%ISOPEN) THEN
            CLOSE c_bsc_levels;
        END IF;
        ROLLBACK TO DeleteBSCDimObjectPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_bsc_levels%ISOPEN) THEN
            CLOSE c_bsc_levels;
        END IF;
        ROLLBACK TO DeleteBSCDimObjectPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN NO_DATA_FOUND THEN
        IF (c_bsc_levels%ISOPEN) THEN
            CLOSE c_bsc_levels;
        END IF;
        ROLLBACK TO DeleteBSCDimObjectPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Delete_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Delete_Dim_Object ';
        END IF;
    WHEN OTHERS THEN
        IF (c_bsc_levels%ISOPEN) THEN
            CLOSE c_bsc_levels;
        END IF;
        ROLLBACK TO DeleteBSCDimObjectPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Delete_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Delete_Dim_Object ';
        END IF;
END Delete_Dim_Object;

/*********************************************************************************
                            FUNCTION validateBscDimensionToDelete
*********************************************************************************/
PROCEDURE validateBscDimensionToDelete
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_short_name    IN              VARCHAR2
    ,   x_return_status         OUT     NOCOPY  VARCHAR2
    ,   x_msg_count             OUT     NOCOPY  NUMBER
    ,   x_msg_data              OUT     NOCOPY  VARCHAR2
) IS
    l_bsc_dim_id    BSC_SYS_DIM_LEVELS_B.dim_level_id%TYPE;
    l_name          BSC_SYS_DIM_LEVELS_TL.Name%TYPE;
    l_count         NUMBER;
    l_edw_flag      BSC_SYS_DIM_LEVELS_B.Edw_Flag%TYPE;

    l_dim_Group_id  BSC_SYS_DIM_GROUPS_TL.Dim_Group_Id%TYPE;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_dim_Group_id  := BSC_BIS_DIMENSION_PUB.Get_Bsc_Dimension_ID(BSC_BIS_DIMENSION_PUB.Unassigned_Dim);
    IF (p_dim_obj_short_name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT dim_level_id
         , name
    INTO   l_bsc_dim_id
         , l_name
    FROM   BSC_SYS_DIM_LEVELS_VL
    WHERE  short_name = p_dim_obj_short_name;


    -- CAN'T DELETE DIMENSION, validataion one.
    /*SELECT Edw_Flag INTO l_edw_flag
    FROM   BSC_SYS_DIM_LEVELS_B
    WHERE  dim_level_id = l_bsc_dim_id;
    IF (l_edw_flag <> 1) THEN
        --this message is hard coded because it needs more investigation if it is really required
        x_msg_data      := 'The dimension object can''t be deleted, since BSC_SYS_DIM_LEVELS_B.Edw_Flag <> 1';
        RAISE           FND_API.G_EXC_ERROR;
    END IF;*/

    --check if the dimension is associated with any group, if so raise an exception
    SELECT  COUNT(1) INTO l_count
    FROM    BSC_SYS_DIM_LEVELS_BY_GROUP
    WHERE   Dim_Level_Id  = l_bsc_dim_id
    AND     Dim_Group_Id <> l_dim_Group_id;
    IF (l_count > 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_NOT_DELETE_DIM_OBJ_GRPS');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', l_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --check if the dimension is associated in relationships, if so raise an exception
    SELECT  COUNT(1) INTO l_count
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   dim_level_id         = l_bsc_dim_id
    OR      parent_dim_level_id  = l_bsc_dim_id;
    IF (l_count > 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_NOT_DELETE_DIM_OBJ_RELS');
        FND_MESSAGE.SET_TOKEN('SHORT_NAME', l_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
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
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.validateBscDimensionToDelete ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.validateBscDimensionToDelete ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.validateBscDimensionToDelete ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.validateBscDimensionToDelete ';
        END IF;
END validateBscDimensionToDelete;
/*********************************************************************************
                            FUNCTION GET DIMENSIONS
*********************************************************************************/
FUNCTION get_Dimensions
(
    p_group_id  IN  NUMBER
)RETURN VARCHAR2
IS
    l_dimension_names   VARCHAR2(32000);
    l_name              BSC_SYS_DIM_LEVELS_VL.Name%TYPE;

    CURSOR  c_dimesnion_names IS
    SELECT  V.NAME
    FROM    BSC_SYS_DIM_LEVELS_VL       V,
            BSC_SYS_DIM_LEVELS_BY_GROUP B
    WHERE   V.DIM_LEVEL_ID  =   B.DIM_LEVEL_ID
    AND      B.DIM_GROUP_ID  =   p_group_id
    ORDER BY B.DIM_LEVEL_INDEX;
BEGIN

    FOR cd IN c_dimesnion_names LOOP
        l_name :=   cd.name;
        IF (l_name IS NOT NULL)THEN
            IF (l_dimension_names IS NULL )THEN
                l_dimension_names :=l_name;
            ELSE
                l_dimension_names :=l_dimension_names ||', '|| l_name;
            END IF;
        END IF;
    END LOOP;

    RETURN l_dimension_names;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END get_Dimensions;

FUNCTION get_Dimension_Objects
(
   p_dim_short_name  IN  VARCHAR2
) RETURN VARCHAR2
IS
    l_dimObjects_names      VARCHAR2(32000);
    l_name                  BSC_SYS_DIM_GROUPS_TL.NAME%TYPE;

    CURSOR c_dimension_obj_name IS
    SELECT A.name
    FROM   BSC_SYS_DIM_LEVELS_VL       A
         , BSC_SYS_DIM_LEVELS_BY_GROUP B
    WHERE  A.dim_level_id = B.dim_level_id
    AND    B.dim_group_id = (SELECT dim_group_id
                             FROM   BSC_SYS_DIM_GROUPS_VL
                             WHERE  Short_Name = p_dim_short_name);
BEGIN
    FOR cd IN c_dimension_obj_name LOOP
        l_name := cd.name;
        IF (l_name IS NOT NULL) THEN
            IF (l_dimObjects_names IS NULL) THEN
                l_dimObjects_names := l_name;
            ELSE
                l_dimObjects_names := l_dimObjects_names ||', '|| l_name;
            END IF;
        END IF;
    END LOOP;
    RETURN l_dimObjects_names;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END get_Dimension_Objects;
/********************************************************************************/
FUNCTION Is_More
(       p_dim_short_names IN  OUT NOCOPY  VARCHAR2
    ,   p_dim_name        OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
BEGIN
    IF (p_dim_short_names IS NOT NULL) THEN
        l_pos_ids           := INSTR(p_dim_short_names,   ',');
        IF (l_pos_ids > 0) THEN
            p_dim_name          :=  TRIM(SUBSTR(p_dim_short_names,    1,    l_pos_ids - 1));
            p_dim_short_names   :=  TRIM(SUBSTR(p_dim_short_names,    l_pos_ids + 1));
        ELSE
            p_dim_name          :=  TRIM(p_dim_short_names);
            p_dim_short_names   :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;
/*******************************************************************************
                      FUNCTION TO INITIALIZE BSC RECORDS
********************************************************************************/
FUNCTION Initialize_Bsc_Recs
(       p_Dim_Level_Rec     IN  OUT NOCOPY  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
)
RETURN BOOLEAN IS
    l_flag          BOOLEAN         :=  TRUE;
    l_alias         VARCHAR(4);
    l_temp_var      VARCHAR(50);
    l_count         NUMBER          := 0;
    l_Bsc_Level_Name VARCHAR(33);
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF ((p_Dim_Level_Rec.Bsc_Source IS NULL) OR (p_Dim_Level_Rec.Bsc_Source <> 'BSC')) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DATA_SOURCE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_TAB_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --Initialize 'l_Dim_Level_Rec' record with the default values
    IF (p_Dim_Level_Rec.Bsc_Level_User_Key_Size IS NULL) THEN
        p_Dim_Level_Rec.Bsc_Level_User_Key_Size     :=  BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Code_Default_Size;  --default size
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Disp_Key_Size IS NULL) THEN
        p_Dim_Level_Rec.Bsc_Level_Disp_Key_Size     :=  BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Name_Default_Size; --default size
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Abbreviation IS NULL) THEN
        p_Dim_Level_Rec.Bsc_Level_Abbreviation      :=  SUBSTR(REPLACE(p_Dim_Level_Rec.Bsc_Level_Short_Name, ' ', ''), 1, 8);
    END IF;
    p_Dim_Level_Rec.Bsc_Level_Abbreviation          :=  UPPER(p_Dim_Level_Rec.Bsc_Level_Abbreviation);
    IF (NOT is_Valid_AlphaNum(p_Dim_Level_Rec.Bsc_Level_Abbreviation)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_ALPHA_NUM_REQUIRED');
        FND_MESSAGE.SET_TOKEN('VALUE',  p_Dim_Level_Rec.Bsc_Level_Abbreviation);
        FND_MESSAGE.SET_TOKEN('NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'ABBREVIATION'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF(INSTR(p_Dim_Level_Rec.Bsc_Level_Name, 'BSC_D_') = 1) THEN
        p_Dim_Level_Rec.Bsc_Level_Name   :=  SUBSTR(p_Dim_Level_Rec.Bsc_Level_Name, 7, LENGTH(p_Dim_Level_Rec.Bsc_Level_Name));
    END IF;
    l_Bsc_Level_Name  :=  'BSC_D_'||UPPER(p_Dim_Level_Rec.Bsc_Level_Name);
    IF(LENGTHB(l_Bsc_Level_Name) > 27) THEN

            FND_MESSAGE.SET_NAME('BSC','BSC_DIM_OBJ_TABLE_NAME');
            FND_MESSAGE.SET_TOKEN('TAB_NAME', l_Bsc_Level_Name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (NOT is_Valid_Identifier(l_Bsc_Level_Name)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SQL_IDENTIFIER');
        FND_MESSAGE.SET_TOKEN('SQL_IDENT', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_TAB_NAME'), TRUE);
        FND_MESSAGE.SET_TOKEN('SQL_VALUE',l_Bsc_Level_Name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    SELECT COUNT(1) INTO l_count
    FROM   BSC_SYS_DIM_LEVELS_B
    WHERE  DIM_LEVEL_ID           <> p_Dim_Level_Rec.Bsc_Level_Id
    AND    LEVEL_TABLE_NAME = l_Bsc_Level_Name;
    IF (l_count <> 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_D_TABLE_NAME_EXIST');
        FND_MESSAGE.SET_TOKEN('TABLE_NAME', l_Bsc_Level_Name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    p_Dim_Level_Rec.Bsc_Level_Name :=l_Bsc_Level_Name;

    p_Dim_Level_Rec.Bsc_Level_View_Name   :=  'BSC_D_'||p_Dim_Level_Rec.Bsc_Level_Id||'_VL';

    p_Dim_Level_Rec.Bsc_Pk_Col := BSC_BIS_DIM_OBJ_PUB.Get_Unique_Level_Pk_Col
                                    (       p_Dim_Level_Rec  => p_Dim_Level_Rec
                                        ,   x_return_status  => x_return_status
                                        ,   x_msg_count      => x_msg_count
                                        ,   x_msg_data       => x_msg_data
                                    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    RETURN TRUE;
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
        RETURN FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN FALSE;
    WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Initialize_Bsc_Recs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Initialize_Bsc_Recs ';
        END IF;
        RETURN FALSE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Initialize_Bsc_Recs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Initialize_Bsc_Recs ';
        END IF;
        RETURN FALSE;
END Initialize_Bsc_Recs;

/*******************************************************************************
                   FUNCTION TO INTIALIZE PMF DIMENSION RECORDS
********************************************************************************/
FUNCTION Initialize_Pmf_Recs
(       p_Dim_Level_Rec     IN  OUT   NOCOPY    BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT   NOCOPY    VARCHAR2
    ,   x_msg_count             OUT   NOCOPY    NUMBER
    ,   x_msg_data              OUT   NOCOPY    VARCHAR2
)
RETURN BOOLEAN IS
    l_count                     NUMBER;
    l_sql                       VARCHAR2(32000);
    l_dimshortname              VARCHAR2(32000);--the size is copied from PMF code
    l_prefix                    VARCHAR2(32000)  := '%PK_KEY%';
    l_flag                      BOOLEAN         :=  TRUE;
    l_Recursive                 VARCHAR2(1);

    --meastmon Fix bug#3337923 Performance issue: remove UPPER from left part to allow use of indexes
    CURSOR  allTabCol1 IS
    SELECT  Column_Name
    FROM    ALL_TAB_COLUMNS
    WHERE   Table_Name  =    UPPER(p_Dim_Level_Rec.Bsc_Level_Name)
    AND     Column_Name LIKE l_prefix
    AND     Owner       =    BSC_APPS.get_user_schema('APPS');

    --meastmon Fix bug#3337923 Performance issue: remove UPPER from left part to allow use of indexes
    CURSOR  allTabCol2 IS
    SELECT  Column_Name
    FROM    ALL_TAB_COLUMNS
    WHERE   Table_Name = UPPER(p_Dim_Level_Rec.Bsc_Level_Name)
    AND    (Column_Name LIKE '%DESCRIPTION%'
             OR Column_Name LIKE '%NAME%'
               OR Column_Name LIKE '%PK')
    AND     ROWNUM < 2
    AND     Owner  = BSC_APPS.get_user_schema('APPS');

BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Check if underlying View or table exists.

    --Default values if view does not exists
    p_Dim_Level_Rec.Bsc_Level_Name_Column       :=  'VALUE';
    p_Dim_Level_Rec.Bsc_Level_Pk_Key            :=  'ID';
    --BSC_SYS_DIM_LEVELS_B.Level_Pk_Col should be short_name to keep it unique
    --p_Dim_Level_Rec.Bsc_Pk_Col                  :=   p_Dim_Level_Rec.Bsc_Level_Short_Name;

    --Comented for Bug#4758995
    --p_Dim_Level_Rec.Bsc_Pk_Col                  :=   REPLACE(p_Dim_Level_Rec.Bsc_Level_Short_Name ,' ', '_');

    IF ((p_Dim_Level_Rec.Bsc_Source IS NULL) OR (p_Dim_Level_Rec.Bsc_Source <> 'PMF')) THEN
        RAISE           FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Short_Name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF ((p_Dim_Level_Rec.Source IS NULL) OR ((p_Dim_Level_Rec.Source <> 'OLTP') AND (p_Dim_Level_Rec.Source <> 'EDW'))) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SOURCE_TYPE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --Initialize 'l_Dim_Level_Rec' record with the default values
    IF (p_Dim_Level_Rec.Bsc_Level_User_Key_Size IS NULL) THEN
        p_Dim_Level_Rec.Bsc_Level_User_Key_Size     :=  BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Code_Default_Size;  --default size
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Disp_Key_Size IS NULL) THEN
        p_Dim_Level_Rec.Bsc_Level_Disp_Key_Size     :=  BSC_BIS_DIM_OBJ_PUB.Dim_Obj_Name_Default_Size; --default size
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Abbreviation IS NULL) THEN
        IF (p_Dim_Level_Rec.Bsc_Level_Short_Name IS NULL) THEN
            RAISE           FND_API.G_EXC_ERROR;
        ELSE
            p_Dim_Level_Rec.Bsc_Level_Abbreviation  :=  SUBSTR(REPLACE(p_Dim_Level_Rec.Bsc_Level_Short_Name, ' ', ''), 1, 8);
        END IF;
    END IF;

    -- Added for Bug#4758995
    p_Dim_Level_Rec.Bsc_Pk_Col := BSC_BIS_DIM_OBJ_PUB.Get_Unique_Level_Pk_Col
                                    (       p_Dim_Level_Rec  => p_Dim_Level_Rec
                                        ,   x_return_status  => x_return_status
                                        ,   x_msg_count      => x_msg_count
                                        ,   x_msg_data       => x_msg_data
                                    );
    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF (p_Dim_Level_Rec.Source = 'OLTP') THEN
        IF ((p_Dim_Level_Rec.Bsc_Level_Name IS NOT NULL)) THEN
            -- Bug 3751932 -- AND (NOT BSC_UTILITY.is_Table_View_Exists(p_Dim_Level_Rec.Bsc_Level_Name))) THEN
            p_Dim_Level_Rec.Bsc_Level_Name_Column       :=  'VALUE';
            p_Dim_Level_Rec.Bsc_Level_Pk_Key            :=  'ID';
        ELSE
            l_flag  := FALSE;
        END IF;
    ELSE -- IF EDW THEN
        IF (BSC_UTILITY.is_Table_View_Exists(p_Dim_Level_Rec.Bsc_Level_Name)) THEN
            p_Dim_Level_Rec.Bsc_Level_Name_Column   :=  'VALUE';
            p_Dim_Level_Rec.Bsc_Level_Pk_Key        :=  'ID';
        ELSIF (NOT BSC_UTILITY.is_Table_View_Exists(p_Dim_Level_Rec.Bsc_Level_Short_Name||'_LTC')) THEN
            IF (NOT BSC_UTILITY.is_Table_View_Exists(p_Dim_Level_Rec.Bsc_Level_Short_Name)) THEN
                l_prefix := '%PK_KEY%';
            ELSE
                p_Dim_Level_Rec.Bsc_Level_Name     :=  p_Dim_Level_Rec.Bsc_Level_Short_Name;
                IF (allTabCol1%ISOPEN) THEN
                    CLOSE allTabCol1;
                END IF;
                OPEN allTabCol1;
                    FETCH allTabCol1 INTO p_Dim_Level_Rec.Bsc_Level_Pk_Key;
                CLOSE allTabCol1;
                IF (allTabCol2%ISOPEN) THEN
                    CLOSE allTabCol2;
                END IF;
                OPEN allTabCol2;
                    FETCH allTabCol2 INTO p_Dim_Level_Rec.Bsc_Level_Name_Column;
                CLOSE allTabCol2;
            END IF;
        ELSE
            p_Dim_Level_Rec.Bsc_Level_Name     :=  p_Dim_Level_Rec.Bsc_Level_Short_Name||'_LTC';
            IF (allTabCol1%ISOPEN) THEN
                CLOSE allTabCol1;
            END IF;
            OPEN allTabCol1;
                FETCH allTabCol1 INTO p_Dim_Level_Rec.Bsc_Level_Pk_Key;
            CLOSE allTabCol1;

            IF (allTabCol2%ISOPEN) THEN
                CLOSE allTabCol2;
            END IF;
            OPEN allTabCol2;
                FETCH allTabCol2 INTO p_Dim_Level_Rec.Bsc_Level_Name_Column;
            CLOSE allTabCol2;
        END IF;
    END IF;
    --p_Dim_Level_Rec.Bsc_Level_View_Name will be NULL only in Create Case
    IF (p_Dim_Level_Rec.Bsc_Level_View_Name  IS NULL) THEN
        p_Dim_Level_Rec.Bsc_Level_View_Name   :=  bsc_utility.get_valid_bsc_master_tbl_name(p_Dim_Level_Rec.Bsc_Level_Short_Name);
    END IF;
    IF (NOT is_Valid_Identifier(p_Dim_Level_Rec.Bsc_Level_View_Name)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SQL_IDENTIFIER');
        FND_MESSAGE.SET_TOKEN('SQL_IDENT', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_VIEW_NAME'), TRUE);
        FND_MESSAGE.SET_TOKEN('SQL_VALUE', p_Dim_Level_Rec.Bsc_Level_View_Name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    SELECT COUNT(1) INTO l_count
    FROM   BSC_SYS_DIM_LEVELS_B
    WHERE  DIM_LEVEL_ID           <> p_Dim_Level_Rec.Bsc_Level_Id
    AND    UPPER(LEVEL_TABLE_NAME) = p_Dim_Level_Rec.Bsc_Level_View_Name;
    IF (l_count <> 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_D_TABLE_NAME_EXIST');
        FND_MESSAGE.SET_TOKEN('TABLE_NAME', p_Dim_Level_Rec.Bsc_Level_View_Name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    RETURN TRUE;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF (allTabCol1%ISOPEN) THEN
            CLOSE allTabCol1;
        END IF;
        IF (allTabCol2%ISOPEN) THEN
            CLOSE allTabCol2;
        END IF;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RETURN FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (allTabCol1%ISOPEN) THEN
            CLOSE allTabCol1;
        END IF;
        IF (allTabCol2%ISOPEN) THEN
            CLOSE allTabCol2;
        END IF;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN FALSE;
    WHEN NO_DATA_FOUND THEN
        IF (allTabCol1%ISOPEN) THEN
            CLOSE allTabCol1;
        END IF;
        IF (allTabCol2%ISOPEN) THEN
            CLOSE allTabCol2;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Initialize_Pmf_Recs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Initialize_Pmf_Recs ';
        END IF;
        RETURN FALSE;
    WHEN OTHERS THEN
        IF (allTabCol1%ISOPEN) THEN
            CLOSE allTabCol1;
        END IF;
        IF (allTabCol2%ISOPEN) THEN
            CLOSE allTabCol2;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Initialize_Pmf_Recs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Initialize_Pmf_Recs ';
        END IF;
        RETURN FALSE;
END Initialize_Pmf_Recs;


/* ---------------------------------------------------
   This procedure check if the End to End KPI is anabled
   in the database
   This return:
     'Y'     End to End KPI enabled in this environment
     'N'     End to End KPI disabled in this environment
----------------------------------------------------------*/
FUNCTION Check_END_TO_END_KPI_FLAG RETURN VARCHAR2
 IS
  cursor c_End_to_ent_kpi_flag IS
  SELECT property_value
  FROM bsc_sys_init
  WHERE property_code = 'TEMP_END_KPI';
  l_END_TO_END_KPI_FLAG VARCHAR2(1);

BEGIN
/*      *********  Please READ before chage this code **********
        About Check_END_TO_END_KPI_FLAG
        This is a temporary validation to support environments with
        end to end kpis internaly. A separate ARU will create a variable in
        bsc_sys_init to anable this procedure to create the views to support
        end to end kpis.  See login in Check_END_TO_END_KPI_FLAG.

        When End to end kpis be released We must to removed this validation and
        comment the old view defenition and force bscup.sql changing its version
        to force the system to updated the pmf view.
      *********  Please READ: **********  */

 l_END_TO_END_KPI_FLAG := 'N';
 for cd in c_End_to_ent_kpi_flag loop
    if cd.property_value = 'Y' then
        l_END_TO_END_KPI_FLAG :=  'Y';
    end if;
 end loop;
 RETURN l_END_TO_END_KPI_FLAG;

EXCEPTION
    WHEN OTHERS THEN
    RETURN 'N';

END Check_END_TO_END_KPI_FLAG;

/*******************************************************************************
                      FUNCTION TO CREATE PMF DIMENSION-OBJ VIEWS
********************************************************************************/

FUNCTION Create_Pmf_Views
(       p_Dim_Level_Rec     IN  OUT   NOCOPY    BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT   NOCOPY    VARCHAR2
    ,   x_msg_count             OUT   NOCOPY    NUMBER
    ,   x_msg_data              OUT   NOCOPY    VARCHAR2
)
RETURN BOOLEAN IS
    l_sql   VARCHAR2(32000);
    l_count NUMBER;
    l_Rel_Select1 VARCHAR2(1000);
    l_Rel_Select2 VARCHAR2(1000);
    l_Rel_Where   VARCHAR2(1000);
    l_Recursive   VARCHAR2(1);

    CURSOR  c_par_dim_ids IS
     SELECT
       b.relation_col AS rel_col,
       (SELECT level_pk_col
        FROM bsc_sys_dim_levels_b
        WHERE dim_level_id =b.parent_dim_level_id) AS pk_col
     FROM
       bsc_sys_dim_level_rels_v b
     WHERE
       b.dim_level_id= p_Dim_Level_Rec.Bsc_Level_Id;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT CreateBSCPmfViewPMD;

    BSC_APPS.Init_Bsc_Apps;
    IF ((p_Dim_Level_Rec.Bsc_Source IS NULL) OR (p_Dim_Level_Rec.Bsc_Source <> 'PMF')) THEN
        RAISE           FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Short_Name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_SHORT_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Pk_Key IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_PK_COL'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Name_Column IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_COL'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_View_Name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_VIEW_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF ((p_Dim_Level_Rec.Bsc_Level_Name IS NOT NULL) AND (is_Valid_Identifier(p_Dim_Level_Rec.Bsc_Level_Name))) THEN

       /**********  Please READ before chage this code **********
        About Check_END_TO_END_KPI_FLAG
        This is a temporary validation to support environments with
        end to end kpis internaly. A separate ARU will create a variable in
        bsc_sys_init to anable this procedure to create the views to support
        end to end kpis.  See login in Check_END_TO_END_KPI_FLAG.
        *********  Please READ: **********  */

        -- Modified for Zero Code issue for MVs for Bug#3739872
        -- added if condition enableVarchar2Implementation for Bug#3836170
        IF (BSC_BIS_CUSTOM_KPI_UTIL_PUB.enableVarchar2Implementation = FND_API.G_TRUE) THEN
           -- This defenition is to  support KPI END TO END

         FOR par_rec IN c_par_dim_ids LOOP
           l_Rel_Select1 := l_Rel_Select1 || ',' || par_rec.pk_col || ',' || par_rec.pk_col || '_USR';
           l_Rel_Select2 := l_Rel_Select2 || ','
                               || 'DECODE( ' || 'TO_CHAR(' || par_rec.rel_col || ') ' || ', '
                                             || 'TO_CHAR(' || BSC_BIS_DIM_OBJ_PUB.DIM_OBJ_VIEW_ZCODE || ') ' || ', '
                                             || 'TO_CHAR(' || BSC_BIS_DIM_OBJ_PUB.DIM_OBJ_VIEW_ZCODE_ALIAS || ') ' || ', '
                                             || 'TO_CHAR(' || par_rec.rel_col || ')) '
                               || ', ' ||' TO_CHAR('|| par_rec.rel_col || ') ';

         END LOOP;

         l_sql   :=  ' CREATE OR REPLACE VIEW ' || p_Dim_Level_Rec.Bsc_Level_View_Name ||
                        ' (CODE, USER_CODE, NAME' || l_Rel_Select1 || ') ' ||
                        ' AS SELECT DISTINCT ' ||
                        ' DECODE( ' || 'TO_CHAR(' || p_Dim_Level_Rec.Bsc_Level_Pk_Key       || ') ' || ', '
                                    || 'TO_CHAR(' || BSC_BIS_DIM_OBJ_PUB.DIM_OBJ_VIEW_ZCODE || ') ' || ', '
                                    || 'TO_CHAR(' || BSC_BIS_DIM_OBJ_PUB.DIM_OBJ_VIEW_ZCODE_ALIAS || ') ' || ', '
                                    || 'TO_CHAR(' || p_Dim_Level_Rec.Bsc_Level_Pk_Key       || ')) ' || ', ' ||
                          'TO_CHAR(' || p_Dim_Level_Rec.Bsc_Level_Pk_Key || ') ' || ', ' ||
                          p_Dim_Level_Rec.Bsc_Level_Name_Column || l_Rel_Select2 ||
                        ' FROM ' || p_Dim_Level_Rec.Bsc_Level_Name;
        ELSE
            --this is old view defenition, as in 11i.BSC.G
            l_sql   :=  ' CREATE OR REPLACE VIEW ' || p_Dim_Level_Rec.Bsc_Level_View_Name || '(' ||
                        ' CODE, USER_CODE, NAME) ' ||
                        ' AS SELECT ROWNUM, ROWNUM, A.' || p_Dim_Level_Rec.Bsc_Level_Name_Column ||
                        ' FROM (SELECT DISTINCT ' ||
                          p_Dim_Level_Rec.Bsc_Level_Name_Column ||
                        ' FROM ' || p_Dim_Level_Rec.Bsc_Level_Name ||
                        ' WHERE UPPER(' || p_Dim_Level_Rec.Bsc_Level_Name_Column || ') NOT LIKE ''UNASSIGNED%''' ||
                        ' AND UPPER(' || p_Dim_Level_Rec.Bsc_Level_Name_Column || ') NOT LIKE ''INVALID%''' ||
                        ' AND ROWNUM < 26) A';
        END IF;

        BEGIN
            --update Table_Type  =  1, which is a indication of view exists
            UPDATE BSC_SYS_DIM_LEVELS_B
            SET    Table_Type  =  1
            WHERE  Short_Name  =  p_Dim_Level_Rec.Bsc_Level_Short_Name;

            BSC_APPS.Do_Ddl_AT(l_sql, ad_ddl.create_view, p_Dim_Level_Rec.Bsc_Level_View_Name, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

        EXCEPTION
            --if exception, it means PMF View does not exists,
            --in this case update Table_Type  =  -1, which is a indication of view does not exists
            WHEN OTHERS THEN
                IF (NOT BSC_UTILITY.is_Table_View_Exists(p_Dim_Level_Rec.Bsc_Level_View_Name)) THEN
                    UPDATE BSC_SYS_DIM_LEVELS_B
                    SET    Table_Type  = -1
                    WHERE  Short_Name  =  p_Dim_Level_Rec.Bsc_Level_Short_Name;
                END IF;
        END;
    ELSE
        --update Table_Type  =  -1, which is a indication of view does not exists
        UPDATE BSC_SYS_DIM_LEVELS_B
        SET    Table_Type  = -1
        WHERE  Short_Name  =  p_Dim_Level_Rec.Bsc_Level_Short_Name;
    END IF;

    RETURN TRUE;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCPmfViewPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RETURN FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCPmfViewPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN FALSE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCPmfViewPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Create_Pmf_Views ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Create_Pmf_Views ';
        END IF;
        RETURN FALSE;
    WHEN OTHERS THEN
        ROLLBACK TO CreateBSCPmfViewPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Create_Pmf_Views ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Create_Pmf_Views ';
        END IF;
        RETURN FALSE;
END Create_Pmf_Views;

/*******************************************************************************
                         FUNCTION TO CREATE BSC DIMENSIONS
********************************************************************************/
FUNCTION Create_Bsc_Master_Tabs
(       p_Dim_Level_Rec     IN  OUT NOCOPY  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
)
RETURN BOOLEAN IS
    l_sql_stmt                  VARCHAR2(32000);

    l_master_table              BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;
    l_input_table               BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;
    l_view_name                 BSC_SYS_DIM_LEVELS_B.Level_View_Name%TYPE;
    l_col_names                 VARCHAR2(32000)  :=  NULL;
    l_code_name                 VARCHAR2(25);
    l_count                     NUMBER          := 0;

    CURSOR  c_view_cols IS
    SELECT  column_name
    FROM    ALL_TAB_COLUMNS
    WHERE   TABLE_NAME  = l_master_table
    AND     column_name NOT IN ('LANGUAGE', 'SOURCE_LANG')
    AND     column_name IS NOT NULL
    AND     OWNER = BSC_APPS.get_user_schema;

    l_rollback_ddl_stmts BSC_APPS.t_array_ddl_stmts;
    l_num_rollback_ddl_stmts NUMBER := 0;

BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT CreateBSCMasTabsPMD;

    BSC_APPS.Init_Bsc_Apps;
    IF ((p_Dim_Level_Rec.Bsc_Source IS NULL) OR (p_Dim_Level_Rec.Bsc_Source <> 'BSC')) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DATA_SOURCE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_TAB_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_View_Name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_VIEW_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Abbreviation IS NULL) THEN
        p_Dim_Level_Rec.Bsc_Level_Abbreviation  :=  SUBSTR(REPLACE(p_Dim_Level_Rec.Bsc_Level_Short_Name, ' ', ''), 1, 8);
    END IF;

    IF(INSTR(p_Dim_Level_Rec.Bsc_Level_Name, 'BSC_D_') = 1) THEN
        p_Dim_Level_Rec.Bsc_Level_Name   :=  SUBSTR(p_Dim_Level_Rec.Bsc_Level_Name, 7, LENGTH(p_Dim_Level_Rec.Bsc_Level_Name));
    END IF;
    l_master_table  :=  'BSC_D_'||UPPER(p_Dim_Level_Rec.Bsc_Level_Name);

    IF (NOT is_Valid_Identifier(l_master_table)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SQL_IDENTIFIER');
        FND_MESSAGE.SET_TOKEN('SQL_IDENT', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_TAB_NAME'), TRUE);
        FND_MESSAGE.SET_TOKEN('SQL_VALUE', l_master_table);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_input_table   :=  'BSC_DI_'||p_Dim_Level_Rec.Bsc_Level_Id;

    l_view_name     :=  'BSC_D_'||p_Dim_Level_Rec.Bsc_Level_Id||'_VL';

    IF (p_Dim_Level_Rec.Bsc_Pk_Col IS NULL) THEN
        p_Dim_Level_Rec.Bsc_Pk_Col          :=  SUBSTR(p_Dim_Level_Rec.Bsc_Level_Name , 1, 22)||'_CODE';
    END IF;

    p_Dim_Level_Rec.Bsc_Level_Name      :=  l_master_table;
    p_Dim_Level_Rec.Bsc_Level_View_Name :=  l_view_name;

    SELECT COUNT(1) INTO l_count
    FROM   BSC_SYS_DIM_LEVELS_B
    WHERE  DIM_LEVEL_ID <> p_Dim_Level_Rec.Bsc_Level_Id
    AND    LEVEL_TABLE_NAME = l_master_table
    AND    SOURCE <> 'PMF';

    IF (l_count <> 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_D_TABLE_NAME_EXIST');
        FND_MESSAGE.SET_TOKEN('TABLE_NAME', p_Dim_Level_Rec.Bsc_Level_Name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --Need to initiliaze in order to Do_DDL works fine

    l_sql_stmt  :=  ' SELECT COUNT(1) FROM   USER_OBJECTS '||
                    ' WHERE  OBJECT_NAME =   :1';

    EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_master_table;

    IF (l_count <> 0) THEN
        l_sql_stmt    := 'DROP TABLE '||l_master_table;
        BSC_APPS.Do_Ddl_AT(l_sql_stmt, ad_ddl.drop_table, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
    END IF;

    -- CHANGED THIS TO REARRANGE THE COLS MASTER TABLES
    -- BUG #3081595
    l_sql_stmt    :=  ' CREATE TABLE  '||l_master_table||
                      ' ( CODE           NUMBER        NOT NULL,'||
                      '   USER_CODE      VARCHAR2('||p_Dim_Level_Rec.Bsc_Level_User_Key_Size||'),  ' ||
                      '   NAME           VARCHAR2('||p_Dim_Level_Rec.Bsc_Level_Disp_Key_Size||'),  '||
                      '   LANGUAGE       VARCHAR2(4)   NOT NULL,'||
                      '   SOURCE_LANG    VARCHAR2(4)   NOT NULL )'||
                      ' '||' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Table_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause;

    BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.create_table, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

    -- in case we need to rollback the ddl
    l_num_rollback_ddl_stmts := l_num_rollback_ddl_stmts + 1;
    l_rollback_ddl_stmts(l_num_rollback_ddl_stmts).sql_stmt := 'DROP TABLE '||l_master_table;
    l_rollback_ddl_stmts(l_num_rollback_ddl_stmts).stmt_type := ad_ddl.drop_table;
    l_rollback_ddl_stmts(l_num_rollback_ddl_stmts).object_name := l_master_table;

    l_sql_stmt    :=  ' CREATE UNIQUE INDEX '||l_master_table||'_U1 '||
                      ' ON '||l_master_table||' (CODE,LANGUAGE) '||' '||
                      ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Index_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause;

    BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.create_index, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

    -- Create a new UNIQUE INDEX for Loader Performance - Bug #3090828
    l_sql_stmt    :=  ' CREATE UNIQUE INDEX '||l_master_table||'_U2 '||
                      ' ON '||l_master_table||' (USER_CODE,LANGUAGE) '||' '||
                      ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Index_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause;

    BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.create_index, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

    l_col_names   :=  NULL;
    --Bug #3081595
    l_col_names   :=  'USER_CODE, NAME ';

    l_sql_stmt  :=  ' SELECT COUNT(1) FROM   USER_OBJECTS '||
                    ' WHERE  OBJECT_NAME =   :1';

    EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_input_table;

    IF (l_count <> 0) THEN
        l_sql_stmt    := 'DROP TABLE '||l_input_table;
        BSC_APPS.Do_Ddl_AT(l_sql_stmt,    ad_ddl.drop_table,  l_input_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
    END IF;
    l_sql_stmt    :=  ' CREATE TABLE   '||l_input_table||' '||' TABLESPACE '||
                        BSC_APPS.Get_Tablespace_Name(BSC_APPS.Input_Table_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause||
                      ' AS SELECT '||l_col_names||' FROM   '||l_master_table||' WHERE 1 = 2';

    BSC_APPS.Do_Ddl_AT(l_sql_stmt, ad_ddl.create_table, l_input_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

    -- in case we need to rollback the ddl
    l_num_rollback_ddl_stmts := l_num_rollback_ddl_stmts + 1;
    l_rollback_ddl_stmts(l_num_rollback_ddl_stmts).sql_stmt := 'DROP TABLE '||l_input_table;
    l_rollback_ddl_stmts(l_num_rollback_ddl_stmts).stmt_type := ad_ddl.drop_table;
    l_rollback_ddl_stmts(l_num_rollback_ddl_stmts).object_name := l_input_table;

    l_sql_stmt    :=  ' CREATE UNIQUE INDEX '||l_input_table||'_U1 '||
                      ' ON '||l_input_table||' (USER_CODE) '||' '||
                      ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.Input_Index_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause;

    BSC_APPS.Do_Ddl_AT(l_sql_stmt, ad_ddl.create_index, l_input_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

    l_col_names :=  NULL;
    FOR cd IN c_view_cols LOOP
        IF (l_col_names IS NULL )THEN
            l_col_names   :=  cd.column_name;
        ELSE
            l_col_names   :=  l_col_names ||', '|| cd.column_name;
        END IF;
    END LOOP;

    l_sql_stmt  :=  ' CREATE OR REPLACE VIEW '||l_view_name||' AS ('  ||
                    ' SELECT '||l_col_names||
                    ' FROM   '||l_master_table||
                    ' WHERE LANGUAGE = USERENV(''LANG''))';

    BSC_APPS.Do_Ddl_AT(l_sql_stmt, ad_ddl.create_view, l_view_name, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

    -- in case we need to rollback the ddl
    l_num_rollback_ddl_stmts := l_num_rollback_ddl_stmts + 1;
    l_rollback_ddl_stmts(l_num_rollback_ddl_stmts).sql_stmt := 'DROP VIEW '||l_view_name;
    l_rollback_ddl_stmts(l_num_rollback_ddl_stmts).stmt_type := ad_ddl.drop_view;
    l_rollback_ddl_stmts(l_num_rollback_ddl_stmts).object_name := l_view_name;


    FOR i_project IN 0..5 LOOP
        IF (i_project = 0) THEN
            l_code_name := 'ALL';
        ELSE
            l_code_name := p_Dim_Level_Rec.Bsc_Level_Abbreviation || TO_CHAR(i_project);
        END IF;

       l_sql_stmt :=    ' INSERT  INTO '||l_master_table||
                        ' (CODE, USER_CODE, NAME, LANGUAGE, SOURCE_LANG)  '||
                        ' SELECT     '||i_project||' AS CODE, '||
                        ' '''||TO_CHAR(i_project)||''' AS USER_CODE, '||
                        ' '''||l_code_name||''' AS NAME,    L.LANGUAGE_CODE, '||
                        '  USERENV(''LANG'') '||
                        ' FROM    FND_LANGUAGES L '||
                        ' WHERE   L.INSTALLED_FLAG IN (''I'', ''B'') '||
                        ' AND     NOT EXISTS '||
                        ' ( SELECT NULL FROM   '||l_master_table||
                        ' T WHERE  T.CODE = :1 '||
                        ' AND    T.LANGUAGE     = L.LANGUAGE_CODE) ';

        EXECUTE IMMEDIATE l_sql_stmt USING i_project;
    END LOOP;
    --insert into BSC_DB_TABLES_RELS & BSC_DB_TABLES

    INSERT INTO BSC_DB_TABLES_RELS
                (Table_Name,  Source_Table_Name, Relation_Type)
    VALUES      (l_master_table, l_input_table, 0);

    INSERT INTO BSC_DB_TABLES
                (Table_Name, Table_Type, Periodicity_Id,
                 Source_Data_Type, Source_File_Name)
    VALUES      (l_input_table, 2, 0, 0, NULL);
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    RETURN TRUE;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CreateBSCMasTabsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;

        x_return_status :=  FND_API.G_RET_STS_ERROR;

        -- try to rollback ddl stmts
        BSC_APPS.Execute_DDL_Stmts_AT(l_rollback_ddl_stmts, l_num_rollback_ddl_stmts, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

        RETURN FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CreateBSCMasTabsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


        -- try to rollback ddl stmts
        BSC_APPS.Execute_DDL_Stmts_AT(l_rollback_ddl_stmts, l_num_rollback_ddl_stmts, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

        RETURN FALSE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO CreateBSCMasTabsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Create_Bsc_Master_Tabs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Create_Bsc_Master_Tabs ';
        END IF;

        -- try to rollback ddl stmts
        BSC_APPS.Execute_DDL_Stmts_AT(l_rollback_ddl_stmts, l_num_rollback_ddl_stmts, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

        RETURN FALSE;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Create_Bsc_Master_Tabs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Create_Bsc_Master_Tabs ';
        END IF;

        ROLLBACK TO CreateBSCMasTabsPMD;

        -- try to rollback ddl stmts
        BSC_APPS.Execute_DDL_Stmts_AT(l_rollback_ddl_stmts, l_num_rollback_ddl_stmts, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

        RETURN FALSE;
END Create_Bsc_Master_Tabs;
/*******************************************************************************
               FUNCTION TO ALTER BSC DIMENSION OBJECTS MASTER TABLES
********************************************************************************/
FUNCTION Alter_Bsc_Master_Tabs
(       p_Dim_Level_Rec     IN  OUT NOCOPY  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   p_Dim_Level_Rec_Old IN              BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
)
RETURN BOOLEAN IS
    l_sql_stmt                  VARCHAR2(32000);
    l_master_table              BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;
    l_input_table               BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;
    l_view_name                 BSC_SYS_DIM_LEVELS_B.Level_View_Name%TYPE;
    l_col_names                 VARCHAR2(32000)  :=  NULL;
    l_old_mas_name              VARCHAR2(60);
    l_abbr                      VARCHAR2(30);
    l_count                     NUMBER          := 0;
    l_flag                      BOOLEAN;
    l_Create_View               BOOLEAN := FALSE;
    l_bind_variable             VARCHAR2(100);
    e_mlog_exception            EXCEPTION;
    l_error_msg                 VARCHAR2(4000);

    CURSOR  c_view_cols IS
    SELECT  column_name
    FROM    ALL_TAB_COLUMNS
    WHERE   TABLE_NAME  = l_master_table
    AND     column_name IS NOT NULL
    AND     column_name NOT IN ('LANGUAGE', 'SOURCE_LANG')
    AND     OWNER = BSC_APPS.get_user_schema;

    --cursor to see, if this dimension object is used in many to many relations
    CURSOR  c_rel_type IS
    SELECT  parent_dim_level_id
    FROM    bsc_sys_dim_level_rels
    WHERE   dim_level_id  = p_Dim_Level_Rec.Bsc_Level_Id
    AND     relation_type = 2;

    CURSOR  c_db_tables IS
    SELECT  DISTINCT TAB.Table_Name                 AS TABLE_NAME
         ,  NVL(COL.Source_Column, COL.Column_Name) AS COLUMN_NAME
    FROM    BSC_DB_TABLES_COLS   COL
         ,  BSC_DB_TABLES        TAB
    WHERE   TAB.Table_Name           =  COL.Table_Name
    AND     TAB.Table_Type           =  0
    AND    (UPPER(COL.Column_Name))  =  UPPER(p_Dim_Level_Rec.Bsc_Pk_Col);

    CURSOR  c_One_To_N_Index IS
    SELECT  B.Level_Pk_Col
    FROM    BSC_SYS_DIM_LEVEL_RELS   A
         ,  BSC_SYS_DIM_LEVELS_B     B
    WHERE   A.Dim_Level_Id  = p_Dim_Level_Rec.Bsc_Level_Id
    AND     B.Dim_Level_Id  = A.Parent_Dim_Level_Id
    AND     A.Relation_Type = 1;

BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    SAVEPOINT AlterBSCMasTabsPMD;

    BSC_APPS.Init_Bsc_Apps;
    IF ((p_Dim_Level_Rec.Bsc_Source IS NULL) OR (p_Dim_Level_Rec.Bsc_Source <> 'BSC')) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_DATA_SOURCE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Id IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_ID'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_Name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_TAB_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_Dim_Level_Rec.Bsc_Level_View_Name IS NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_REQ_FIELD_MISSING');
        FND_MESSAGE.SET_TOKEN('FIELD_NAME', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_VIEW_NAME'), TRUE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    l_master_table  :=  UPPER(p_Dim_Level_Rec.Bsc_Level_Name);

    IF (NOT is_Valid_Identifier(l_master_table)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SQL_IDENTIFIER');
        FND_MESSAGE.SET_TOKEN('SQL_IDENT', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_TAB_NAME'), TRUE);
        FND_MESSAGE.SET_TOKEN('SQL_VALUE', l_master_table);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_input_table   :=  'BSC_DI_'||p_Dim_Level_Rec.Bsc_Level_Id;
    l_view_name     :=  'BSC_D_'||p_Dim_Level_Rec.Bsc_Level_Id||'_VL';

    SELECT COUNT(1) INTO l_count
    FROM   BSC_SYS_DIM_LEVELS_B
    WHERE  DIM_LEVEL_ID     <> p_Dim_Level_Rec.Bsc_Level_Id
    AND    LEVEL_TABLE_NAME = l_master_table;
    IF (l_count <> 0) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_D_TABLE_NAME_EXIST');
        FND_MESSAGE.SET_TOKEN('TABLE_NAME', p_Dim_Level_Rec.Bsc_Level_Name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --check if old master tables, views, input table exists in the system.
    --if they do not exists than call BSC_BIS_DIM_OBJ_PUB.Create_Bsc_Master_Tabs otherwise proceed further
    l_flag      :=  TRUE;
    l_sql_stmt  :=  ' SELECT COUNT(1) FROM   USER_OBJECTS '||
                    ' WHERE  OBJECT_NAME =   :1';

    EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING p_Dim_Level_Rec_Old.Bsc_Level_Name;
    IF (l_count = 0) THEN
        l_flag  := FALSE;
    END IF;
    l_sql_stmt  :=  ' SELECT COUNT(1) FROM   USER_OBJECTS '||
                    ' WHERE  OBJECT_NAME =   :1';
    l_bind_variable :=  'BSC_D_'||p_Dim_Level_Rec_Old.Bsc_Level_Id||'_VL';
    EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_bind_variable;
    IF (l_count = 0) THEN
        l_flag  := FALSE;
    END IF;
    l_sql_stmt  :=  ' SELECT COUNT(1) FROM   USER_OBJECTS '||
                    ' WHERE  OBJECT_NAME =   :1';

    l_bind_variable :=  'BSC_DI_'||p_Dim_Level_Rec_Old.Bsc_Level_Id;
    EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_bind_variable;
    IF (l_count = 0) THEN
        l_flag  := FALSE;
    END IF;
    IF (NOT l_flag) THEN
        --The following part of the code will only be executed if
        --master table, input table or view does not exists.
        --This secition will be called in the case of data corruption only.
        FND_MESSAGE.SET_NAME('BSC','BSC_DB_ERROR');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    ELSE
        --check if Level_Pk_Col is differnt, is so update table BSC_DB_TABLES_COLS
        IF(UPPER(p_Dim_Level_Rec.Bsc_Pk_Col) <> UPPER(p_Dim_Level_Rec_Old.Bsc_Pk_Col)) THEN
            UPDATE BSC_DB_TABLES_COLS
            SET    Source_Column         = p_Dim_Level_Rec_Old.Bsc_Pk_Col
            WHERE  UPPER(Column_Name)    = UPPER(p_Dim_Level_Rec_Old.Bsc_Pk_Col)
            AND    Source_Column IS NULL;

            UPDATE BSC_DB_TABLES_COLS
            SET    Column_Name         = p_Dim_Level_Rec.Bsc_Pk_Col
            WHERE  UPPER(Column_Name)  = UPPER(p_Dim_Level_Rec_Old.Bsc_Pk_Col);
        END IF;
        --check if user-code size and disp-key size are different
        IF ((p_Dim_Level_Rec.Bsc_Level_User_Key_Size <> p_Dim_Level_Rec_Old.Bsc_Level_User_Key_Size)
            OR (p_Dim_Level_Rec.Bsc_Level_Disp_Key_Size <> p_Dim_Level_Rec_Old.Bsc_Level_Disp_Key_Size)) THEN
            IF ((p_Dim_Level_Rec.Bsc_Level_User_Key_Size < p_Dim_Level_Rec_Old.Bsc_Level_User_Key_Size)
              OR (p_Dim_Level_Rec.Bsc_Level_Disp_Key_Size < p_Dim_Level_Rec_Old.Bsc_Level_Disp_Key_Size)) THEN
                    FND_MESSAGE.SET_NAME('BSC','BSC_CODE_SIZE_NOT_DECREASED');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
            END IF;
            l_Create_View := TRUE;

            l_sql_stmt  :=  'ALTER TABLE '||p_Dim_Level_Rec_Old.Bsc_Level_Name||
                            ' MODIFY USER_CODE VARCHAR2('||p_Dim_Level_Rec.Bsc_Level_User_Key_Size||') '||
                            ' MODIFY NAME   VARCHAR2('||p_Dim_Level_Rec.Bsc_Level_Disp_Key_Size||')  ';

            BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, p_Dim_Level_Rec_Old.Bsc_Level_Name, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);


            l_sql_stmt  :=  'ALTER TABLE BSC_DI_'||p_Dim_Level_Rec_Old.Bsc_Level_Id||'  '||
                            ' MODIFY USER_CODE VARCHAR2('||p_Dim_Level_Rec.Bsc_Level_User_Key_Size||') '||
                            ' MODIFY NAME   VARCHAR2('||p_Dim_Level_Rec.Bsc_Level_Disp_Key_Size||')  ';

            BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, 'BSC_DI_'||p_Dim_Level_Rec_Old.Bsc_Level_Id, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            IF ((p_Dim_Level_Rec.Bsc_Level_User_Key_Size <> p_Dim_Level_Rec_Old.Bsc_Level_User_Key_Size)) THEN
                FOR cd IN c_db_tables LOOP
                    l_sql_stmt  :=  ' ALTER TABLE '||cd.Table_Name||
                                    ' MODIFY '||cd.Column_Name||
                                    ' VARCHAR2('||p_Dim_Level_Rec.Bsc_Level_User_Key_Size||') ';
                    BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, cd.TABLE_NAME, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
                END LOOP;
            END IF;

            /********************************************************
             Here we will synch up the MLOG tables for the current dimension object
             ********************************************************/
            IF NOT (BSC_SYNC_MVLOGS.Sync_dim_table_mv_log(p_Dim_Level_Rec_Old.Bsc_Level_Name,l_error_msg)) THEN
              RAISE e_mlog_exception;
            END IF;
        END IF;
        IF (l_master_table <> UPPER(p_Dim_Level_Rec_Old.Bsc_Level_Name)) THEN
           l_Create_View := TRUE;
           l_sql_stmt  :=  ' SELECT COUNT(1) FROM   USER_OBJECTS '||
                            ' WHERE  OBJECT_NAME =   :1';

            EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_master_table;
            IF (l_count <> 0) THEN
                l_sql_stmt    := 'DROP TABLE '||l_master_table;
                BSC_APPS.Do_Ddl_AT(l_sql_stmt,    ad_ddl.drop_table,  l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            END IF;
            l_sql_stmt    :=  ' CREATE TABLE   '||l_master_table||' '||' TABLESPACE '||
                                BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Table_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause||
                              ' AS SELECT * FROM '||p_Dim_Level_Rec_Old.Bsc_Level_Name;

            BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.create_table, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            l_sql_stmt    :=  ' CREATE UNIQUE INDEX '||l_master_table||'_U1 '||
                              ' ON '||l_master_table||' (CODE, LANGUAGE) '||' '||
                              ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Index_Tbs_Type)||' '||BSC_APPS.Bsc_Storage_Clause;

            BSC_APPS.Do_Ddl_AT(l_sql_stmt, ad_ddl.create_index, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

            -- Create a new UNIQUE INDEX for Loader Performance - Bug #3090828
            l_sql_stmt    :=  ' CREATE UNIQUE INDEX '||l_master_table||'_U2 '||
                              ' ON '||l_master_table||' (USER_CODE, LANGUAGE) '||' '||
                              ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Index_Tbs_Type)||' '||BSC_APPS.Bsc_Storage_Clause;
            BSC_APPS.Do_Ddl_AT(l_sql_stmt, ad_ddl.create_index, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            l_count := 1;
            FOR cd IN c_One_To_N_Index LOOP
                -- Create a new Non-Unique INDEX for Loader Performance - Bug #3120190

                IF (LENGTH(l_master_table||'_N'||l_count) <= 30) THEN
                    l_sql_stmt    :=  ' CREATE INDEX '||l_master_table||'_N'||l_count||' '||
                                      ' ON '||l_master_table||' ('||cd.Level_Pk_Col||') '||' '||
                                      ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Index_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause;

                    BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.create_index, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
                    l_count := l_count + 1;
                ELSE
                    EXIT;
                END IF;
            END LOOP;
            l_sql_stmt    := 'DROP TABLE '||p_Dim_Level_Rec_Old.Bsc_Level_Name;

            BSC_APPS.Do_Ddl_AT(l_sql_stmt,    ad_ddl.drop_table,  p_Dim_Level_Rec_Old.Bsc_Level_Name, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            --update BSC_DB_TABLES_RELS
            UPDATE BSC_DB_TABLES_RELS
            SET    Table_Name         = l_master_table
            WHERE  Source_Table_Name  = l_input_table;
        END IF;
        IF (l_Create_View) THEN

            l_col_names :=  NULL;
            FOR cd IN c_view_cols LOOP
                IF (l_col_names IS NULL )THEN
                    l_col_names   :=  cd.column_name;
                ELSE
                    l_col_names   :=  l_col_names ||', '|| cd.column_name;
                END IF;
            END LOOP;

            l_sql_stmt  :=  ' CREATE OR REPLACE VIEW '||l_view_name||' AS ('  ||
                            ' SELECT '||l_col_names||
                            ' FROM   '||l_master_table||
                            ' WHERE LANGUAGE = USERENV(''LANG''))';

            BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.create_view, l_view_name, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
        END IF;
        l_flag  :=  BSC_BIS_DIM_OBJ_PUB.Alter_M_By_N_Tables
                    (       p_Dim_Level_Rec       =>  p_Dim_Level_Rec
                        ,   p_Dim_Level_Rec_Old   =>  p_Dim_Level_Rec_Old
                        ,   x_return_status       =>  x_return_status
                        ,   x_msg_count           =>  x_msg_count
                        ,   x_msg_data            =>  x_msg_data
                    );
                    IF (NOT l_flag) THEN
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
        l_flag  :=  BSC_BIS_DIM_OBJ_PUB.Alter_One_By_N_Tables
                    (       p_Dim_Level_Rec     =>  p_Dim_Level_Rec
                        ,   p_Dim_Level_Rec_Old =>  p_Dim_Level_Rec_Old
                        ,   x_return_status     =>  x_return_status
                        ,   x_msg_count         =>  x_msg_count
                        ,   x_msg_data          =>  x_msg_data
                    );
                    IF (NOT l_flag) THEN
                        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
        RETURN TRUE;
    END IF;
EXCEPTION
    WHEN e_mlog_exception THEN
        ROLLBACK TO AlterBSCMasTabsPMD;
        x_msg_data      := NULL;
        x_msg_data      := l_error_msg || ' -> BSC_BIS_DIM_OBJ_PUB.Alter_Bsc_Master_Tabs';
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RETURN FALSE;

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO AlterBSCMasTabsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RETURN FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO AlterBSCMasTabsPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN FALSE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO AlterBSCMasTabsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Alter_Bsc_Master_Tabs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Alter_Bsc_Master_Tabs ';
        END IF;
        RETURN FALSE;
    WHEN OTHERS THEN
        ROLLBACK TO AlterBSCMasTabsPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Alter_Bsc_Master_Tabs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Alter_Bsc_Master_Tabs ';
        END IF;
        RETURN FALSE;
END Alter_Bsc_Master_Tabs;
/*******************************************************************************
               FUNCTION TO ALTER M x N Tables
********************************************************************************/
FUNCTION Alter_M_By_N_Tables
(       p_Dim_Level_Rec     IN              BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   p_Dim_Level_Rec_Old IN              BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
)
RETURN BOOLEAN IS
    l_count             NUMBER;
    l_abbreviation      BSC_SYS_DIM_LEVELS_B.Abbreviation%TYPE;
    l_sql_stmt          VARCHAR2(32000);
    l_old_mas_name      BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;
    l_master_table      BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;
    l_input_table       BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;
    l_Tbl_Statements    BSC_APPS.Autonomous_Statements_Tbl_Type;
    e_mlog_exception    EXCEPTION;
    l_error_msg         VARCHAR2(4000);

    CURSOR  c_MN_Tables  IS
    SELECT  Dim_Level_Id
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   Parent_Dim_Level_Id = p_Dim_Level_Rec.Bsc_Level_Id
    AND     Relation_Type       = 2;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BSC_APPS.Init_Bsc_Apps;

    SAVEPOINT AlterBSCMxNPMD;
    IF ((p_Dim_Level_Rec.Bsc_Level_User_Key_Size = p_Dim_Level_Rec_Old.Bsc_Level_User_Key_Size) AND
         (UPPER(p_Dim_Level_Rec.Bsc_Level_Abbreviation) = UPPER(p_Dim_Level_Rec_Old.Bsc_Level_Abbreviation)) AND
          (UPPER(p_Dim_Level_Rec.Bsc_Pk_Col) = UPPER(p_Dim_Level_Rec_Old.Bsc_Pk_Col))) THEN
          RETURN TRUE;
    END IF;
    FOR cd IN c_MN_Tables LOOP
        SELECT  Abbreviation
        INTO    l_abbreviation
        FROM    BSC_SYS_DIM_LEVELS_B
        WHERE   dim_level_id = cd.Dim_Level_Id;

        IF (cd.Dim_Level_Id > p_Dim_Level_Rec.Bsc_Level_Id) THEN
            l_input_table :=  'BSC_DI_'||p_Dim_Level_Rec.Bsc_Level_Id||'_'||cd.Dim_Level_Id;
        ELSE
            l_input_table :=  'BSC_DI_'||cd.Dim_Level_Id||'_'||p_Dim_Level_Rec.Bsc_Level_Id;
        END IF;
        IF (l_abbreviation > p_Dim_Level_Rec.Bsc_Level_Abbreviation) THEN
            l_master_table  :=  'BSC_D_'||UPPER(p_Dim_Level_Rec.Bsc_Level_Abbreviation)||'_'||UPPER(l_abbreviation);
        ELSE
            l_master_table  :=  'BSC_D_'||UPPER(l_abbreviation)||'_'||UPPER(p_Dim_Level_Rec.Bsc_Level_Abbreviation);
        END IF;

        l_sql_stmt  :=  ' SELECT COUNT(1) FROM   USER_OBJECTS '||
                        ' WHERE  OBJECT_NAME =   :1';

        EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_input_table;
        IF (l_count = 0) THEN
            x_msg_data  :=  'Input Table does not exists '||l_input_table;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        --if abbreviation is different than drop and create master tables
        IF (UPPER(p_Dim_Level_Rec.Bsc_Level_Abbreviation) <> UPPER(p_Dim_Level_Rec_Old.Bsc_Level_Abbreviation)) THEN
            IF (UPPER(p_Dim_Level_Rec_Old.Bsc_Level_Abbreviation) > UPPER(l_abbreviation)) THEN
                l_old_mas_name  :=  'BSC_D_'||UPPER(l_abbreviation)||'_'||UPPER(p_Dim_Level_Rec_Old.Bsc_Level_Abbreviation);
            ELSE
                l_old_mas_name  :=  'BSC_D_'||UPPER(p_Dim_Level_Rec_Old.Bsc_Level_Abbreviation)||'_'||UPPER(l_abbreviation);
            END IF;

            l_sql_stmt  :=  ' SELECT COUNT(1) FROM   USER_OBJECTS '||
                            ' WHERE  OBJECT_NAME =   :1';

            EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_master_table;
            IF (l_count <> 0) THEN
                l_sql_stmt    := 'DROP TABLE '||l_master_table;
                BSC_APPS.Do_Ddl_AT(l_sql_stmt,    ad_ddl.drop_table,  l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            END IF;
            l_sql_stmt  :=  ' SELECT COUNT(1) FROM   USER_OBJECTS '||
                            ' WHERE  OBJECT_NAME =   :1';

            EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_old_mas_name;
            IF (l_count = 0) THEN
                x_msg_data  :=  'Master Table does not exists '||l_old_mas_name;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
            l_sql_stmt    :=  ' CREATE TABLE   '||l_master_table||' '||' TABLESPACE '||
                                BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Table_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause||
                              ' AS SELECT * FROM '||l_old_mas_name;

            BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.create_table, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

            --meastmon 02-27-2004: Here is missing the sql statement. I found this by casualty. So fixing
            -- -----
            ---Need to update the following table when there is change in abbrevation bug#4091924

            Update_M_By_N_Relation_col
            ( p_Dim_Level_Id         => cd.Dim_Level_Id
            , p_Parent_Dim_Level_Id  => p_Dim_Level_Rec.Bsc_Level_Id
            , p_Relation_Col         => l_master_table
            , x_return_status        => x_return_status
            , x_msg_count            => x_msg_count
            , x_msg_data             => x_msg_data
            );

            IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            l_sql_stmt    := 'DROP TABLE '||l_old_mas_name;
            -- -----
            BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.drop_table,   l_old_mas_name, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

            --update BSC_DB_TABLES_RELS
            UPDATE BSC_DB_TABLES_RELS
            SET    Table_Name         = l_master_table
            WHERE  Source_Table_Name  = l_input_table;
        END IF;
        --if level_pk_col is different than change the names of table columns
        IF (UPPER(p_Dim_Level_Rec.Bsc_Pk_Col) <> UPPER(p_Dim_Level_Rec_Old.Bsc_Pk_Col)) THEN

            l_Tbl_Statements.DELETE;
            l_sql_stmt  := 'ALTER TABLE '||l_master_table||' ADD ('||p_Dim_Level_Rec.Bsc_Pk_Col||' NUMBER )';

            --BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            l_Tbl_Statements(0).x_Fnd_Apps_Schema       :=  BSC_APPS.Fnd_Apps_Schema;
            l_Tbl_Statements(0).x_Bsc_Apps_Short_Name   :=  BSC_APPS.Bsc_Apps_Short_Name;
            l_Tbl_Statements(0).x_Statement_Type        :=  AD_DDL.Alter_Table;
            l_Tbl_Statements(0).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(0).x_Object_Name           :=  l_master_table;

            l_sql_stmt  := 'UPDATE '||l_master_table||' SET '||
                            p_Dim_Level_Rec.Bsc_Pk_Col||' = '||p_Dim_Level_Rec_Old.Bsc_Pk_Col;

            --EXECUTE IMMEDIATE l_sql_stmt;
            l_Tbl_Statements(1).x_Fnd_Apps_Schema       :=  NULL;
            l_Tbl_Statements(1).x_Bsc_Apps_Short_Name   :=  NULL;
            l_Tbl_Statements(1).x_Statement_Type        :=  NULL;
            l_Tbl_Statements(1).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(1).x_Object_Name           :=  NULL;

            l_sql_stmt  := 'ALTER TABLE '||l_master_table||' DROP COLUMN '||p_Dim_Level_Rec_Old.Bsc_Pk_Col;

            --BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            l_Tbl_Statements(2).x_Fnd_Apps_Schema       :=  BSC_APPS.Fnd_Apps_Schema;
            l_Tbl_Statements(2).x_Bsc_Apps_Short_Name   :=  BSC_APPS.Bsc_Apps_Short_Name;
            l_Tbl_Statements(2).x_Statement_Type        :=  AD_DDL.Alter_Table;
            l_Tbl_Statements(2).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(2).x_Object_Name           :=  l_master_table;
            BSC_APPS.Do_Ddl_AT(x_Statements_Tbl  => l_Tbl_Statements);

            l_Tbl_Statements.DELETE;
            l_sql_stmt  := 'ALTER TABLE '||l_input_table||' ADD ('||p_Dim_Level_Rec.Bsc_Pk_Col||'_USR '||
                           ' VARCHAR2('||p_Dim_Level_Rec.Bsc_Level_User_Key_Size||'))';

            --BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, l_input_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            l_Tbl_Statements(0).x_Fnd_Apps_Schema       :=  BSC_APPS.Fnd_Apps_Schema;
            l_Tbl_Statements(0).x_Bsc_Apps_Short_Name   :=  BSC_APPS.Bsc_Apps_Short_Name;
            l_Tbl_Statements(0).x_Statement_Type        :=  AD_DDL.Alter_Table;
            l_Tbl_Statements(0).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(0).x_Object_Name           :=  l_master_table;

            l_sql_stmt  := 'UPDATE '||l_input_table||' SET '||
                            p_Dim_Level_Rec.Bsc_Pk_Col||'_USR = '||p_Dim_Level_Rec_Old.Bsc_Pk_Col||'_USR';

            --EXECUTE IMMEDIATE l_sql_stmt;
            l_Tbl_Statements(1).x_Fnd_Apps_Schema       :=  NULL;
            l_Tbl_Statements(1).x_Bsc_Apps_Short_Name   :=  NULL;
            l_Tbl_Statements(1).x_Statement_Type        :=  NULL;
            l_Tbl_Statements(1).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(1).x_Object_Name           :=  NULL;

            l_sql_stmt  := 'ALTER TABLE '||l_input_table||' DROP COLUMN '||p_Dim_Level_Rec_Old.Bsc_Pk_Col||'_USR';

            --BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, l_input_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            l_Tbl_Statements(2).x_Fnd_Apps_Schema       :=  BSC_APPS.Fnd_Apps_Schema;
            l_Tbl_Statements(2).x_Bsc_Apps_Short_Name   :=  BSC_APPS.Bsc_Apps_Short_Name;
            l_Tbl_Statements(2).x_Statement_Type        :=  AD_DDL.Alter_Table;
            l_Tbl_Statements(2).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(2).x_Object_Name           :=  l_master_table;
            BSC_APPS.Do_Ddl_AT(x_Statements_Tbl  => l_Tbl_Statements);

        ELSIF (p_Dim_Level_Rec.Bsc_Level_User_Key_Size <> p_Dim_Level_Rec_Old.Bsc_Level_User_Key_Size) THEN
            l_sql_stmt  :=  ' ALTER TABLE '||l_input_table||
                            ' MODIFY '||p_Dim_Level_Rec.Bsc_Pk_Col||'_USR '||
                            ' VARCHAR2('||p_Dim_Level_Rec.Bsc_Level_User_Key_Size||') ';
            BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, l_input_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
        END IF;

        /********************************************************************
         Here we need to call the API BSC_SYNC_MVLOGS.Sync_dim_table_mv_log
         This API will synch up the data in MLOGS corresponding to the dimension
         object.
         We need to call this API in the following scenarios.
          1.When Name and USER_CODE size are changed.
          2.When parent col is added or removed from the child dimension object table.
        *******************************************************************/
        IF ((p_Dim_Level_Rec.Bsc_Level_User_Key_Size <> p_Dim_Level_Rec_Old.Bsc_Level_User_Key_Size)
            OR (p_Dim_Level_Rec.Bsc_Level_Disp_Key_Size <> p_Dim_Level_Rec_Old.Bsc_Level_Disp_Key_Size)) THEN
            IF NOT (BSC_SYNC_MVLOGS.Sync_dim_table_mv_log(l_master_table,l_error_msg)) THEN
                RAISE e_mlog_exception;
            END IF;
       END IF;
    END LOOP;

    RETURN TRUE;
EXCEPTION
    WHEN e_mlog_exception THEN
        ROLLBACK TO AlterBSCMxNPMD;
        x_msg_data      := NULL;
        x_msg_data      := l_error_msg || ' -> BSC_BIS_DIM_OBJ_PUB.Alter_M_By_N_Tables ';
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RETURN FALSE;
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO AlterBSCMxNPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RETURN FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO AlterBSCMxNPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN FALSE;
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO AlterBSCMxNPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Alter_M_By_N_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Alter_M_By_N_Tables ';
        END IF;
        RETURN FALSE;
    WHEN OTHERS THEN
        ROLLBACK TO AlterBSCMxNPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Alter_M_By_N_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Alter_M_By_N_Tables ';
        END IF;
        RETURN FALSE;
END Alter_M_By_N_Tables;

/*******************************************************************************
               FUNCTION TO ALTER One x N Child Tables
********************************************************************************/
FUNCTION Alter_One_By_N_Tables
(       p_Dim_Level_Rec     IN              BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   p_Dim_Level_Rec_Old IN              BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
)
RETURN BOOLEAN IS
    l_count             NUMBER;
    l_sql_stmt          VARCHAR2(32000);
    l_master_table      BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;
    l_input_table       BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;
    l_view_name         BSC_SYS_DIM_LEVELS_B.Level_Table_Name%TYPE;
    l_col_names         VARCHAR2(32000);
    l_index_Name        VARCHAR2(100) := NULL;
    l_index_Count       NUMBER;
    l_flag              BOOLEAN;
    l_Create_View       BOOLEAN := FALSE;
    l_Tbl_Statements    BSC_APPS.Autonomous_Statements_Tbl_Type;
    e_mlog_exception    EXCEPTION;
    l_error_msg         VARCHAR2(4000);

    --cursor to get the columns for creation of view based on master-table
    CURSOR  c_view_cols IS
    SELECT  column_name
    FROM    ALL_TAB_COLUMNS
    WHERE   TABLE_NAME  = l_master_table
    AND     column_name NOT IN ('LANGUAGE', 'SOURCE_LANG')
    AND     column_name IS NOT NULL
    AND     OWNER = BSC_APPS.get_user_schema;

    --cursor to know the index on Column
    CURSOR  c_Parent_Index_Name IS
    SELECT  Index_Name
    FROM    ALL_IND_COLUMNS
    WHERE   Table_Name  = l_master_table
    AND     Column_Name = UPPER(p_Dim_Level_Rec_Old.Bsc_Pk_Col)
    AND     INDEX_OWNER = BSC_APPS.get_user_schema;

    CURSOR  c_One_by_N IS
    SELECT  Dim_Level_Id
    FROM    BSC_SYS_DIM_LEVEL_RELS
    WHERE   parent_dim_level_id = p_Dim_Level_Rec.Bsc_Level_Id
    AND     relation_type = 1;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BSC_APPS.Init_Bsc_Apps;

    SAVEPOINT AlterBSCOnexNPMD;
    IF ((p_Dim_Level_Rec.Bsc_Level_User_Key_Size = p_Dim_Level_Rec_Old.Bsc_Level_User_Key_Size) AND
          (UPPER(p_Dim_Level_Rec.Bsc_Pk_Col) = UPPER(p_Dim_Level_Rec_Old.Bsc_Pk_Col))) THEN
          RETURN TRUE;
    END IF;
    FOR cd IN c_One_by_N LOOP
        l_Create_View   := FALSE;

        SELECT  Level_Table_Name
        INTO    l_master_table
        FROM    BSC_SYS_DIM_LEVELS_B
        WHERE   dim_level_id = cd.dim_level_id;

        l_master_table  :=   UPPER(l_master_table);
        l_input_table   :=  'BSC_DI_'||cd.Dim_Level_Id;
        l_view_name     :=  'BSC_D_'||cd.Dim_Level_Id||'_VL';

        l_sql_stmt  :=  ' SELECT COUNT(1) FROM   USER_OBJECTS '||
                        ' WHERE  OBJECT_NAME =   :1';

        EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_master_table;
        IF (l_count = 0) THEN
            x_msg_data  :=  'Master Table does not exists '||l_master_table;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_sql_stmt  :=  ' SELECT COUNT(1) FROM   USER_OBJECTS '||
                        ' WHERE  OBJECT_NAME =   :1';

        EXECUTE IMMEDIATE l_sql_stmt INTO l_count USING l_input_table;
        IF (l_count = 0) THEN
            x_msg_data  :=  'Input Table does not exists '||l_input_table;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        --if level_pk_col is different than change the names of table columns
        IF (UPPER(p_Dim_Level_Rec.Bsc_Pk_Col) <> UPPER(p_Dim_Level_Rec_Old.Bsc_Pk_Col)) THEN
            l_Create_View   := TRUE;
            --get the name of index on original column.
            l_index_Name  := NULL;
            OPEN  c_Parent_Index_Name;
                FETCH c_Parent_Index_Name INTO l_index_Name;
            CLOSE c_Parent_Index_Name;
            IF (l_index_Name IS NULL) THEN
                l_flag        := TRUE;
                l_index_Name  := l_master_table||'_N1';
                IF (LENGTH(l_index_Name) <= 30) THEN
                    l_index_Count := 2;
                    WHILE (l_flag) LOOP
                        SELECT  COUNT(1) INTO l_count
                        FROM    ALL_INDEXES
                        WHERE   INDEX_NAME = l_index_Name
                        AND     OWNER      = BSC_APPS.get_user_schema;

                        IF (l_count = 0) THEN
                            l_flag  := FALSE;
                            EXIT;
                        ELSE
                            l_index_Name  := l_master_table||'_N'||l_index_Count;
                            l_index_Count := l_index_Count + 1;
                        END IF;
                    END LOOP;
                END IF;
            END IF;
            l_Tbl_Statements.DELETE;
            l_sql_stmt  := 'ALTER TABLE '||l_master_table||' ADD ('||p_Dim_Level_Rec.Bsc_Pk_Col||' NUMBER)';

            --BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            l_Tbl_Statements(0).x_Fnd_Apps_Schema       :=  BSC_APPS.Fnd_Apps_Schema;
            l_Tbl_Statements(0).x_Bsc_Apps_Short_Name   :=  BSC_APPS.Bsc_Apps_Short_Name;
            l_Tbl_Statements(0).x_Statement_Type        :=  AD_DDL.Alter_Table;
            l_Tbl_Statements(0).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(0).x_Object_Name           :=  l_master_table;

            l_sql_stmt  := 'UPDATE '||l_master_table||' SET '||
                            p_Dim_Level_Rec.Bsc_Pk_Col ||' = '||p_Dim_Level_Rec_Old.Bsc_Pk_Col;

            --EXECUTE IMMEDIATE l_sql_stmt;
            l_Tbl_Statements(1).x_Fnd_Apps_Schema       :=  NULL;
            l_Tbl_Statements(1).x_Bsc_Apps_Short_Name   :=  NULL;
            l_Tbl_Statements(1).x_Statement_Type        :=  NULL;
            l_Tbl_Statements(1).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(1).x_Object_Name           :=  NULL;

            l_sql_stmt  := 'ALTER TABLE '||l_master_table||' DROP COLUMN '||p_Dim_Level_Rec_Old.Bsc_Pk_Col;

            --BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            l_Tbl_Statements(2).x_Fnd_Apps_Schema       :=  BSC_APPS.Fnd_Apps_Schema;
            l_Tbl_Statements(2).x_Bsc_Apps_Short_Name   :=  BSC_APPS.Bsc_Apps_Short_Name;
            l_Tbl_Statements(2).x_Statement_Type        :=  AD_DDL.Alter_Table;
            l_Tbl_Statements(2).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(2).x_Object_Name           :=  l_master_table;
            BSC_APPS.Do_Ddl_AT(x_Statements_Tbl  => l_Tbl_Statements);

            l_Tbl_Statements.DELETE;
            l_sql_stmt  := 'ALTER TABLE '||l_master_table||' ADD ('||p_Dim_Level_Rec.Bsc_Pk_Col||'_USR '||
                           ' VARCHAR2('||p_Dim_Level_Rec.Bsc_Level_User_Key_Size||'))';

            --BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            l_Tbl_Statements(0).x_Fnd_Apps_Schema       :=  BSC_APPS.Fnd_Apps_Schema;
            l_Tbl_Statements(0).x_Bsc_Apps_Short_Name   :=  BSC_APPS.Bsc_Apps_Short_Name;
            l_Tbl_Statements(0).x_Statement_Type        :=  AD_DDL.Alter_Table;
            l_Tbl_Statements(0).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(0).x_Object_Name           :=  l_master_table;


            l_sql_stmt  := 'UPDATE '||l_master_table||' SET '||
                            p_Dim_Level_Rec.Bsc_Pk_Col||'_USR = '||p_Dim_Level_Rec_Old.Bsc_Pk_Col||'_USR';

            --EXECUTE IMMEDIATE l_sql_stmt;
            l_Tbl_Statements(1).x_Fnd_Apps_Schema       :=  NULL;
            l_Tbl_Statements(1).x_Bsc_Apps_Short_Name   :=  NULL;
            l_Tbl_Statements(1).x_Statement_Type        :=  NULL;
            l_Tbl_Statements(1).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(1).x_Object_Name           :=  NULL;
            l_sql_stmt  := 'ALTER TABLE '||l_master_table||' DROP COLUMN '||
                            p_Dim_Level_Rec_Old.Bsc_Pk_Col||'_USR';

            --BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            l_Tbl_Statements(2).x_Fnd_Apps_Schema       :=  BSC_APPS.Fnd_Apps_Schema;
            l_Tbl_Statements(2).x_Bsc_Apps_Short_Name   :=  BSC_APPS.Bsc_Apps_Short_Name;
            l_Tbl_Statements(2).x_Statement_Type        :=  AD_DDL.Alter_Table;
            l_Tbl_Statements(2).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(2).x_Object_Name           :=  l_master_table;
            BSC_APPS.Do_Ddl_AT(x_Statements_Tbl  => l_Tbl_Statements);

            l_Tbl_Statements.DELETE;
            l_sql_stmt  := 'ALTER TABLE '||l_input_table||' ADD ('||p_Dim_Level_Rec.Bsc_Pk_Col||'_USR '||
                           ' VARCHAR2('||p_Dim_Level_Rec.Bsc_Level_User_Key_Size||'))';

            --BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, l_input_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            l_Tbl_Statements(0).x_Fnd_Apps_Schema       :=  BSC_APPS.Fnd_Apps_Schema;
            l_Tbl_Statements(0).x_Bsc_Apps_Short_Name   :=  BSC_APPS.Bsc_Apps_Short_Name;
            l_Tbl_Statements(0).x_Statement_Type        :=  AD_DDL.Alter_Table;
            l_Tbl_Statements(0).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(0).x_Object_Name           :=  l_master_table;

            l_sql_stmt  := 'UPDATE '||l_input_table||' SET '||
                            p_Dim_Level_Rec.Bsc_Pk_Col||'_USR = '||p_Dim_Level_Rec_Old.Bsc_Pk_Col||'_USR';

            --EXECUTE IMMEDIATE l_sql_stmt;
            l_Tbl_Statements(1).x_Fnd_Apps_Schema       :=  NULL;
            l_Tbl_Statements(1).x_Bsc_Apps_Short_Name   :=  NULL;
            l_Tbl_Statements(1).x_Statement_Type        :=  NULL;
            l_Tbl_Statements(1).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(1).x_Object_Name           :=  NULL;


            l_sql_stmt  := 'ALTER TABLE '||l_input_table||' DROP COLUMN '||
                            p_Dim_Level_Rec_Old.Bsc_Pk_Col||'_USR';

            --BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, l_input_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            l_Tbl_Statements(2).x_Fnd_Apps_Schema       :=  BSC_APPS.Fnd_Apps_Schema;
            l_Tbl_Statements(2).x_Bsc_Apps_Short_Name   :=  BSC_APPS.Bsc_Apps_Short_Name;
            l_Tbl_Statements(2).x_Statement_Type        :=  AD_DDL.Alter_Table;
            l_Tbl_Statements(2).x_Statement             :=  l_sql_stmt;
            l_Tbl_Statements(2).x_Object_Name           :=  l_master_table;
            BSC_APPS.Do_Ddl_AT(x_Statements_Tbl  => l_Tbl_Statements);

            /********************************************************
            Here we need to update the relation_col column in BSC_SYS_DIM_LEVEL_RELS
            table whenever we are changing the level_pk_col of the parent.
            /*******************************************************/
            UPDATE  BSC_SYS_DIM_LEVEL_RELS
            SET     RELATION_COL = p_Dim_Level_Rec.Bsc_Pk_Col
            WHERE   dim_level_id = cd.Dim_Level_Id
            AND     parent_dim_level_id = p_Dim_Level_Rec.Bsc_Level_Id
            AND     relation_type = 1;

            --Due to DB restrictions, index can't be created if length is > 30 characters.
            IF (LENGTH(l_index_Name) <= 30) THEN
                l_sql_stmt    :=  ' CREATE INDEX '||l_index_Name||' '||
                                  ' ON '||l_master_table||' ('||p_Dim_Level_Rec.Bsc_Pk_Col||') '||' '||
                                  ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.Dimension_Index_Tbs_Type)||' '||BSC_APPS.bsc_storage_clause;
                BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.create_index, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
            END IF;
        ELSIF (p_Dim_Level_Rec.Bsc_Level_User_Key_Size <> p_Dim_Level_Rec_Old.Bsc_Level_User_Key_Size) THEN
            l_Create_View   := TRUE;

            l_sql_stmt  :=  ' ALTER TABLE '||l_master_table||
                            ' MODIFY '||p_Dim_Level_Rec.Bsc_Pk_Col||'_USR '||
                            ' VARCHAR2('||p_Dim_Level_Rec.Bsc_Level_User_Key_Size||') ';

            BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, l_master_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);

            l_sql_stmt  :=  ' ALTER TABLE '||l_input_table||
                            ' MODIFY '||p_Dim_Level_Rec.Bsc_Pk_Col||'_USR '||
                            ' VARCHAR2('||p_Dim_Level_Rec.Bsc_Level_User_Key_Size||') ';

            BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.alter_table, l_input_table, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
        END IF;
        IF (l_Create_View) THEN
            l_col_names :=  NULL;
            FOR cd IN c_view_cols LOOP
                IF (l_col_names IS NULL )THEN
                    l_col_names   :=  cd.column_name;
                ELSE
                    l_col_names   :=  l_col_names ||', '|| cd.column_name;
                END IF;
            END LOOP;

            l_sql_stmt  :=  ' CREATE OR REPLACE VIEW '||l_view_name||' AS ('  ||
                            ' SELECT '||l_col_names||
                            ' FROM   '||l_master_table||
                            ' WHERE LANGUAGE = USERENV(''LANG''))';

            BSC_APPS.Do_Ddl_AT(l_sql_stmt,   ad_ddl.create_view, l_view_name, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
        END IF;

        --Now synch up the MLOG tables with the new User_Key_Size and Disp_Key_Size

        IF ((p_Dim_Level_Rec.Bsc_Level_User_Key_Size <> p_Dim_Level_Rec_Old.Bsc_Level_User_Key_Size)
            OR (p_Dim_Level_Rec.Bsc_Level_Disp_Key_Size <> p_Dim_Level_Rec_Old.Bsc_Level_Disp_Key_Size)
            OR(UPPER(p_Dim_Level_Rec.Bsc_Pk_Col) <> UPPER(p_Dim_Level_Rec_Old.Bsc_Pk_Col))) THEN
            IF NOT (BSC_SYNC_MVLOGS.Sync_dim_table_mv_log(l_master_table,l_error_msg)) THEN
                RAISE e_mlog_exception;
            END IF;
        END IF;
    END LOOP;

    RETURN TRUE;
EXCEPTION
    WHEN e_mlog_exception THEN
        IF (c_Parent_Index_Name%ISOPEN) THEN
          CLOSE c_Parent_Index_Name;
        END IF;
        ROLLBACK TO AlterBSCOnexNPMD;
        x_msg_data      := NULL;
        x_msg_data      := l_error_msg || ' -> BSC_BIS_DIM_OBJ_PUB.Alter_One_By_N_Tables ';
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RETURN FALSE;
    WHEN FND_API.G_EXC_ERROR THEN
        IF (c_Parent_Index_Name%ISOPEN) THEN
            CLOSE c_Parent_Index_Name;
        END IF;
        ROLLBACK TO AlterBSCOnexNPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        RETURN FALSE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (c_Parent_Index_Name%ISOPEN) THEN
            CLOSE c_Parent_Index_Name;
        END IF;
        ROLLBACK TO AlterBSCOnexNPMD;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN FALSE;
    WHEN NO_DATA_FOUND THEN
        IF (c_Parent_Index_Name%ISOPEN) THEN
            CLOSE c_Parent_Index_Name;
        END IF;
        ROLLBACK TO AlterBSCOnexNPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Alter_One_By_N_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Alter_One_By_N_Tables ';
        END IF;
        RETURN FALSE;
    WHEN OTHERS THEN
        IF (c_Parent_Index_Name%ISOPEN) THEN
            CLOSE c_Parent_Index_Name;
        END IF;
        ROLLBACK TO AlterBSCOnexNPMD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Alter_One_By_N_Tables ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Alter_One_By_N_Tables ';
        END IF;
        RETURN FALSE;
END Alter_One_By_N_Tables;
/********************************************************************************
      FUNCTION TO CHECK IF PASSED PARAMETER IS IS A SQL KEY-WORD OR NOT
********************************************************************************/
FUNCTION is_SQL_Key_Word
(
    p_value   IN  VARCHAR2
) RETURN BOOLEAN IS
    l_key_words VARCHAR2(3000);
    l_result    VARCHAR2(30);
    l_value     VARCHAR2(30);
    l_flag      BOOLEAN  :=  FALSE;
BEGIN
    IF(p_value IS NULL) THEN
        RETURN l_flag;
    ELSE
        l_key_words := 'ACCESS, ADD, ALL, ALTER, AND, ANY, ARRAY, AS, ASC, AT, AUDIT, AUTHID, AVG, BEGIN, BETWEEN, BINARY_INTEGER, ';
        l_key_words :=  l_key_words||'BODY, BOOLEAN, BULK, BY, CASE, CHAR, CHAR_BASE, CHECK, CLOSE, CLUSTER, COALESCE, COLLECT, ';
        l_key_words :=  l_key_words||'COLUMN, COMMENT, COMMIT, COMPRESS, CONNECT, CONSTANT, CREATE, CURRENT, CURRVAL, CURSOR, DATE, ';
        l_key_words :=  l_key_words||'DAY, DECIMAL, DECLARE, DEFAULT, DELETE, DESC, DISTINCT, DO, DROP, ELSE, ELSIF, END, ';
        l_key_words :=  l_key_words||'EXCEPTION, EXCLUSIVE, EXECUTE, EXISTS, EXIT, EXTENDS, EXTRACT, FALSE, FETCH, FILE, FLOAT, ';
        l_key_words :=  l_key_words||'FOR, FORALL, FROM, FUNCTION, GOTO, GRANT, GROUP, HAVING, HEAP, HOUR, IDENTIFIED, IF, ';
        l_key_words :=  l_key_words||'IMMEDIATE, IN, INCREMENT, INDEX, INDICATOR, INITIAL, INSERT, INTEGER, INTERFACE, ';
        l_key_words :=  l_key_words||'INTERSECT, INTERVAL, INTO, IS, ISOLATION, JAVA, LEVEL, LIKE, LIMITED, LOCK, LONG, LOOP, ';
        l_key_words :=  l_key_words||'MAX, MAXEXTENTS, MIN, MINUS, MINUTE, MLSLABEL, MOD, MODE, MODIFY, MONTH, NATURAL, NATURALN, ';
        l_key_words :=  l_key_words||'NEW, NEXTVAL, NOAUDIT, NOCOMPRESS, NOCOPY, NOT, NOWAIT, NULL, NULLIF, NUMBER, NUMBER_BASE, ';
        l_key_words :=  l_key_words||'OCIROWID, OF, OFFLINE, ON, ONLINE, OPAQUE, OPEN, OPERATOR, OPTION, OR, ORDER, ORGANIZATION, ';
        l_key_words :=  l_key_words||'OTHERS, OUT, PACKAGE, PARTITION, PCTFREE, PLS_INTEGER, POSITIVE, POSITIVEN, PRAGMA, PRIOR, ';
        l_key_words :=  l_key_words||'PRIVATE, PRIVILEGES, PROCEDURE, PUBLIC, RAISE, RANGE, RAW, REAL, RECORD, REF, RELEASE, ';
        l_key_words :=  l_key_words||'RENAME, RESOURCE, RETURN, REVERSE, REVOKE, ROLLBACK, ROW, ROWID, ROWNUM, ROWS, ROWTYPE, ';
        l_key_words :=  l_key_words||'SAVEPOINT, SECOND, SELECT, SEPARATE, SESSION, SET, SHARE, SIZE, SMALLINT, SPACE, SQL, ';
        l_key_words :=  l_key_words||'SQLCODE, SQLERRM, START, STDDEV, SUBTYPE, SUCCESSFUL, SUM, SYNONYM, SYSDATE, TABLE, THEN, ';
        l_key_words :=  l_key_words||'TIME, TIMESTAMP, TIMEZONE_ABBR, TIMEZONE_HOUR, TIMEZONE_MINUTE, TIMEZONE_REGION, TO, ';
        l_key_words :=  l_key_words||'TRIGGER, TRUE, TYPE, UI, UID, UNION, UNIQUE, UPDATE, USER, VALIDATE, VALUES, VARCHAR, ';
        l_key_words :=  l_key_words||'VARCHAR2, VIEW, WHENEVER, WHERE, WITH ';
        l_value     :=  UPPER(p_value);
        WHILE (is_more(     p_dim_short_names  =>  l_key_words
                        ,   p_dim_name         =>  l_result)
        ) LOOP
            IF(l_result = l_value) THEN
                l_flag  :=  TRUE;
                EXIT;
            END IF;
        END LOOP;
        RETURN l_flag;
    END IF;
END is_SQL_Key_Word;

FUNCTION get_bis_dimension_id
(
   p_dim_short_name   IN  VARCHAR2
) RETURN NUMBER IS
    CURSOR c_dim_short_name IS
    SELECT dimension_id
    FROM   BIS_DIMENSIONS
    WHERE  short_name = p_dim_short_name;

    l_dim_id    BISFV_DIMENSION_LEVELS.dimension_id%TYPE;
BEGIN
    IF (c_dim_short_name%ISOPEN) THEN
        CLOSE c_dim_short_name;
    END IF;
    OPEN  c_dim_short_name;
        FETCH  c_dim_short_name  INTO l_dim_id;
    CLOSE  c_dim_short_name;
    RETURN l_dim_id;
END get_bis_dimension_id;

/********************************************************************************
    WARNING : -
    This function will return false if any changes to Dimensions, Dimension-Objects
    will results in structural changes. This is designed to fulfil the UI screen
    need and not a generic function so it should not be called internally from any
    other APIs without proper impact analysis.
********************************************************************************/
FUNCTION is_KPI_Flag_For_DimObject
(       p_dim_obj_short_name        IN          VARCHAR2
    ,   p_Source                    IN          VARCHAR2
    ,   p_source_table              IN          VARCHAR2
    ,   p_table_column              IN          VARCHAR2
    ,   p_prototype_default_value   IN          VARCHAR2
    ,   p_maximum_code_size         IN          NUMBER
    ,   p_maximum_name_size         IN          NUMBER
    ,   p_dim_short_names           IN          VARCHAR2
) RETURN VARCHAR2 IS
    l_Msg_Data              VARCHAR2(32000);
    l_msg_count             NUMBER;

    l_bsc_dim_obj_rec       BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
    l_dim_Grp_name          BSC_SYS_DIM_GROUPS_TL.short_name%TYPE;
    l_MTab_Tbl              BSC_BIS_DIM_OBJ_PUB.KPI_Dim_Set_Table_Type;

    l_count                 NUMBER;
    l_strut_flag            BOOLEAN := FALSE;
    l_child_struct_flag     BOOLEAN := FALSE;
    l_flag                  BOOLEAN;
    l_counter               NUMBER := 0;
    l_duplicate_flag        BOOLEAN;

    l_kpi_names             VARCHAR2(8000);
    l_new_dim_Grps          VARCHAR2(8000);
    l_old_dim_Grps          VARCHAR2(8000);
    l_child_dim_obj_list    VARCHAR2 (32000);

    CURSOR   c_Old_Dim_Obj_Rec  IS
    SELECT   dim_level_id
          ,  level_table_name
          ,  user_key_size
          ,  disp_key_size
          ,  NVL(source, 'BSC')
          ,  abbreviation
          ,  level_pk_col
    FROM     BSC_SYS_DIM_LEVELS_VL
    WHERE    short_name = p_dim_obj_short_name;

    CURSOR   c_Dimension_Names IS
    SELECT   Short_Name
    FROM     BSC_SYS_DIM_GROUPS_VL
    WHERE    dim_group_id IN
            (SELECT  dim_group_id
             FROM    BSC_SYS_DIM_LEVELS_BY_GROUP
             WHERE   dim_level_id = l_bsc_dim_obj_rec.Bsc_Level_Id);

    CURSOR   c_Kpi_Dim_Set IS
    SELECT   DISTINCT C.Name||'['||C.Indicator||']' Name
            , C.Indicator
    FROM     BSC_KPI_DIM_LEVELS_B    A
          ,  BSC_SYS_DIM_LEVELS_B    D
          ,  BSC_KPIS_VL             C
    WHERE    A.Level_Table_Name      =  D.Level_Table_Name
    AND      D.Dim_Level_Id          =  l_bsc_dim_obj_rec.Bsc_Level_Id
    AND      C.share_flag           <>  2
    AND      C.Indicator             =  A.Indicator;

    CURSOR   c_Kpi_Dim_Set1 IS
    SELECT   DISTINCT C.Name||'['||C.Indicator||']' Name
            ,C.Indicator
    FROM     BSC_KPI_DIM_LEVELS_B    A
          ,  BSC_SYS_DIM_LEVELS_B    D
          ,  BSC_KPIS_VL             C
    WHERE    A.Level_Table_Name      =  D.Level_Table_Name
    AND      C.share_flag           <>  2
    AND      C.Indicator             =  A.Indicator
    AND      INSTR(','||l_child_dim_obj_list||',', ','||D.dim_level_id||',') > 0;

    CURSOR   c_Dim_Set_Kpi IS
    SELECT   DISTINCT B.Name||'['||B.Indicator||']' Name
            ,B.Indicator
    FROM     BSC_KPI_DIM_GROUPS     A
          ,  BSC_KPIS_VL            B
          ,  BSC_SYS_DIM_GROUPS_VL  C
    WHERE    A.INDICATOR      =  B.INDICATOR
    AND      A.dim_group_id   =  C.Dim_Group_ID
    AND      B.share_flag    <>  2
    AND      INSTR(l_new_dim_Grps, ','||C.Short_Name||',') > 0;
BEGIN

    FND_MSG_PUB.Initialize;
    IF ((p_dim_obj_short_name IS NULL) AND (p_Source IS NULL)) THEN
        RETURN NULL;
    END IF;
    IF (NOT BSC_UTILITY.isBscInProductionMode()) THEN
        RETURN NULL;
    END IF;

    IF (p_dim_obj_short_name IS NOT NULL) THEN
        OPEN c_old_dim_obj_rec;
            FETCH    c_old_dim_obj_rec
            INTO     l_bsc_dim_obj_rec.Bsc_Level_Id
                   , l_bsc_dim_obj_rec.Bsc_Level_Name
                   , l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size
                   , l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size
                   , l_bsc_dim_obj_rec.Bsc_Source
                   , l_bsc_dim_obj_rec.Bsc_Level_Abbreviation
                   , l_bsc_dim_obj_rec.Bsc_Pk_Col;
        CLOSE c_old_dim_obj_rec;
        IF (l_bsc_dim_obj_rec.Bsc_Level_Id IS NULL) THEN
           RETURN NULL;
        END IF;
        IF (l_bsc_dim_obj_rec.Bsc_Source <> 'BSC') THEN
            RETURN NULL;
        END IF;
        IF ((l_bsc_dim_obj_rec.Bsc_Level_Name <> NVL(p_source_table, l_bsc_dim_obj_rec.Bsc_Level_Name)) OR
                (l_bsc_dim_obj_rec.Bsc_Pk_Col <> NVL(p_table_column, l_bsc_dim_obj_rec.Bsc_Pk_Col)))THEN
                l_strut_flag := TRUE;
        END IF;

        l_counter :=0;

        IF (l_strut_flag) THEN
            FOR cd IN c_kpi_dim_set LOOP
                l_MTab_Tbl(l_counter).p_kpi_id :=  cd.Indicator;
                l_MTab_Tbl(l_counter).p_Name   :=  cd.Name;
                l_counter :=  l_counter + 1;
            END LOOP;
        END IF;
    ELSIF (p_Source <> 'BSC') THEN
        RETURN NULL;
    END IF;
    l_new_dim_Grps   :=  ',';
    IF ((l_bsc_dim_obj_rec.Bsc_Level_Id IS NULL) AND (p_dim_short_names IS NOT NULL)) THEN
        l_old_dim_Grps   :=  UPPER(p_dim_short_names);
        WHILE (is_more(p_dim_short_names   =>  l_old_dim_Grps
                   ,   p_dim_name          =>  l_dim_Grp_name
        )) LOOP
            l_strut_flag   :=  TRUE;
            l_new_dim_Grps :=  l_new_dim_Grps||l_dim_Grp_name||',';
        END LOOP;
    ELSIF (p_dim_short_names IS NOT NULL) THEN
        l_old_dim_Grps   :=  UPPER(p_dim_short_names);
        WHILE (is_more(p_dim_short_names   =>  l_old_dim_Grps
                     , p_dim_name          =>  l_dim_Grp_name
        )) LOOP
            SELECT  COUNT(0)
            INTO    l_count
            FROM    BSC_SYS_DIM_LEVELS_BY_GROUP   A
                 ,  BSC_SYS_DIM_GROUPS_VL         B
            WHERE   A.Dim_Level_Id      =    l_bsc_dim_obj_rec.Bsc_Level_Id
            AND     B.Short_Name        =    l_dim_Grp_name
            AND     B.Dim_Group_Id      =    A.Dim_Group_Id;

            IF (l_count = 0) THEN
                l_strut_flag   :=  TRUE;
                l_new_dim_Grps :=  l_new_dim_Grps||l_dim_Grp_name||',';
            END IF;
        END LOOP;
    END IF;

    IF (l_bsc_dim_obj_rec.Bsc_Level_Id IS NOT NULL) THEN
        FOR cd IN c_dimension_names LOOP
            l_flag           :=  TRUE;
            IF (p_dim_short_names IS NOT NULL) THEN
                l_old_dim_Grps   :=  UPPER(p_dim_short_names);

                WHILE (is_more(p_dim_short_names   =>  l_old_dim_Grps
                           ,   p_dim_name          =>  l_dim_Grp_name
                )) LOOP

                    IF (l_dim_Grp_name = cd.Short_Name) THEN
                       l_flag   := FALSE;
                       EXIT;
                    END IF;
                END LOOP;
            END IF;
            IF (l_flag) THEN
                l_new_dim_Grps :=  l_new_dim_Grps||cd.Short_Name||',';
            END IF;
        END LOOP;
    END IF;

    IF ((l_new_dim_Grps IS NOT NULL) AND (l_new_dim_Grps  <>  ',')) THEN
        FOR cd IN c_dim_set_kpi LOOP
            l_duplicate_flag := FALSE;
            FOR i IN 0..(l_MTab_Tbl.COUNT-1) LOOP
                IF(l_MTab_Tbl(i).p_kpi_id=cd.Indicator)THEN
                    l_duplicate_flag := TRUE;
                    EXIT;
                END IF;
            END LOOP;

            IF(NOT l_duplicate_flag) THEN
                l_MTab_Tbl(l_counter).p_kpi_id :=  cd.Indicator;
                l_MTab_Tbl(l_counter).p_Name   :=  cd.Name;
                l_counter :=  l_counter + 1;
            END IF;
        END LOOP;
    END IF;

    FOR i IN 0..(l_MTab_Tbl.COUNT-1) LOOP
      IF(l_kpi_names IS NULL)THEN
        l_kpi_names := l_MTab_Tbl(i).p_Name;
      ELSE
        l_kpi_names := l_kpi_names||', '||l_MTab_Tbl(i).p_Name;
      END IF;
    END LOOP;

    IF (l_kpi_names IS NOT NULL) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_PMD_KPI_STRUCT_INVALID');
        FND_MESSAGE.SET_TOKEN('INDICATORS', l_kpi_names);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    /***********************************************************
      Check for display format changes here
    /************************************************************/
    IF((l_kpi_names IS NULL) AND (p_Source ='BSC'))THEN
      IF(BSC_BIS_DIM_OBJ_PUB.is_Obj_Display_Frmt_Change
         (
                p_dim_obj_short_name     => p_dim_obj_short_name
            ,   p_Source                 => p_Source
            ,   p_source_table           => p_source_table
            ,   p_table_column           => p_table_column
            ,   p_prototype_default_value=> p_prototype_default_value
            ,   p_maximum_code_size      => p_maximum_code_size
            ,   p_maximum_name_size      => p_maximum_name_size
            ,   p_dim_short_names        => p_dim_short_names
            ,   x_obj_names              => l_kpi_names
         ))THEN
         IF(l_kpi_names IS NOT NULL)THEN
           FND_MESSAGE.SET_NAME('BSC','BSC_CHANG_OBJ_DISP_FORMAT');
           FND_MESSAGE.SET_TOKEN('OBJS', l_kpi_names);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
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
END is_KPI_Flag_For_DimObject;

FUNCTION is_config_impact_dim_obj
(       p_Dim_Obj_Short_Name        IN          VARCHAR2
    ,   p_Dim_Short_Names           IN          VARCHAR2
) RETURN VARCHAR2 IS

   TYPE index_by_table IS Record
   (       p_no_dim_object       VARCHAR2(32000)
   );
   TYPE index_by_table_type IS TABLE OF index_by_table INDEX BY BINARY_INTEGER;
   TYPE index_by_table_kpi IS Record
   (
           kpi_id     NUMBER
        ,  dim_set_id NUMBER
   );
   TYPE index_by_table_type_kpi IS TABLE OF index_by_table_kpi INDEX BY BINARY_INTEGER;
   dim_objs_array index_by_table_type;
   kpi_dim_set_array index_by_table_type_kpi;
   l_dim_sht_names       VARCHAR2(32000);
   l_dim_short_name      VARCHAR2(32000);
   l_kpi_id              NUMBER;
   l_dim_set_id          NUMBER;
   l_is_found            BOOLEAN;
   l_count_temp          NUMBER;
   l_Msg_Data            VARCHAR2(32000);
   l_msg_count           NUMBER;

   CURSOR cr_kpidimset_dim IS
   SELECT   A. INDICATOR
           ,A.DIM_SET_ID
   FROM     BSC_KPI_DIM_GROUPS A
           ,BSC_SYS_DIM_GROUPS_VL B
   WHERE    A.DIM_GROUP_ID = B.DIM_GROUP_ID
   AND      B.SHORT_NAME =  l_dim_short_name;

   CURSOR cr_dimobj_in_dimset IS
   SELECT B.SHORT_NAME
   FROM   BSC_SYS_DIM_LEVELS_B B
         ,BSC_KPI_DIM_LEVEL_PROPERTIES KDL
   WHERE  B.DIM_LEVEL_ID = KDL.DIM_LEVEL_ID
   AND    KDL.indicator = l_kpi_id
   AND    KDL.dim_set_id = l_dim_set_id;

   i NUMBER;
   l_no_dim_object       VARCHAR2(32000);

BEGIN

   FND_MSG_PUB.Initialize;
   IF(p_Dim_Short_Names IS NOT NULL) THEN
     l_dim_sht_names := p_Dim_Short_Names;
     WHILE(Is_More(p_dim_short_names => l_dim_sht_names,p_dim_name =>l_dim_short_name)) LOOP
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
         l_is_found := FALSE;
         IF(cr_dimobj_in_dimset%ISOPEN) THEN
           CLOSE cr_dimobj_in_dimset;
         END IF;
         OPEN  cr_dimobj_in_dimset;
         -- bug#3405498 meastmon 28-jan-2004: The following is not supported in 8i
         --FETCH cr_dimobj_in_dimset  BULK COLLECT INTO dim_objs_array;
         dim_objs_array.delete;
         i:= 0;
         LOOP
             FETCH cr_dimobj_in_dimset INTO l_no_dim_object;
             EXIT WHEN cr_dimobj_in_dimset%NOTFOUND;
             i := i+1;
             dim_objs_array(i).p_no_dim_object := l_no_dim_object;
         END LOOP;
         CLOSE cr_dimobj_in_dimset;

         FOR index_loop IN 1..(dim_objs_array.COUNT) LOOP
           IF(p_Dim_Obj_Short_Name = dim_objs_array(index_loop).p_no_dim_object) THEN
             l_is_found := TRUE;
           END IF;
         END LOOP;
         IF((l_is_found = FALSE) AND  (dim_objs_array.COUNT >= BSC_BIS_KPI_MEAS_PUB.Config_Limit_Dim)) THEN
           FND_MESSAGE.SET_NAME('BSC','BSC_PMD_IMPACT_KPI_SPACE');
           FND_MESSAGE.SET_TOKEN('CONTINUE', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'YES'), TRUE);
           FND_MESSAGE.SET_TOKEN('CANCEL', BSC_APPS.Get_Lookup_Value('BSC_UI_KPIDESIGNER', 'NO'), TRUE);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END LOOP;
     END LOOP;
   END IF;
   IF(cr_dimobj_in_dimset%ISOPEN) THEN
     CLOSE cr_dimobj_in_dimset;
   END IF;
   IF(cr_kpidimset_dim%ISOPEN) THEN
     CLOSE cr_kpidimset_dim;
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
     RETURN  l_Msg_Data;
   WHEN OTHERS THEN
     IF(cr_kpidimset_dim%ISOPEN) THEN
            CLOSE cr_kpidimset_dim;
     END IF;
     IF(cr_dimobj_in_dimset%ISOPEN) THEN
            CLOSE cr_dimobj_in_dimset;
     END IF;
   RETURN NULL;
END is_config_impact_dim_obj;
/*******************************************************************************
********************************************************************************/
FUNCTION Get_Dim_Obj_Source
(   p_dim_obj_id IN NUMBER   := NULL
  , p_short_Name IN VARCHAR2 := NULL
) RETURN VARCHAR2 IS
    l_Data_Source BSC_SYS_DIM_LEVELS_B.Source%TYPE := NULL;

    CURSOR  c_dim_obj_source_id IS
    SELECT  Source
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   Dim_Level_Id = p_dim_obj_id;

    CURSOR  c_dim_obj_source_name IS
    SELECT  Source
    FROM    BSC_SYS_DIM_LEVELS_B
    WHERE   Short_Name = p_short_Name;
BEGIN
    IF (p_dim_obj_id IS NOT NULL) THEN
        IF (c_dim_obj_source_id%ISOPEN) THEN
            CLOSE c_dim_obj_source_id;
        END IF;
        OPEN c_dim_obj_source_id;
            FETCH    c_dim_obj_source_id INTO l_Data_Source;
        CLOSE c_dim_obj_source_id;
    ELSIF (p_short_Name IS NOT NULL) THEN
        IF (c_dim_obj_source_name%ISOPEN) THEN
            CLOSE c_dim_obj_source_name;
        END IF;
        OPEN c_dim_obj_source_name;
            FETCH    c_dim_obj_source_name INTO l_Data_Source;
        CLOSE c_dim_obj_source_name;
    END IF;
    RETURN  l_Data_Source;
EXCEPTION
    WHEN OTHERS THEN
        IF (c_dim_obj_source_id%ISOPEN) THEN
            CLOSE c_dim_obj_source_id;
        END IF;
        IF (c_dim_obj_source_name%ISOPEN) THEN
            CLOSE c_dim_obj_source_name;
        END IF;
        RETURN NULL;
END Get_Dim_Obj_Source;
/*********************************************************************************************
                         Returns the Dimension Object ID of BIS
*********************************************************************************************/
FUNCTION Get_Bis_Dim_Obj_ID
(  p_Short_Name  IN BIS_LEVELS.Short_Name%TYPE
) RETURN NUMBER IS

    l_dim_id    BIS_LEVELS.Level_ID%TYPE;

    CURSOR  c_Dim_Group_Id IS
    SELECT  Level_ID
    FROM    BIS_LEVELS
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
END Get_Bis_Dim_Obj_ID;

/*********************************************************************************************
                         Returns the Dimension Object ID of BSC
*********************************************************************************************/
FUNCTION Get_Bsc_Dim_Obj_ID
(  p_Short_Name  IN BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE
) RETURN NUMBER IS

    l_dim_id    BSC_SYS_DIM_LEVELS_B.Dim_Level_ID%TYPE;

    CURSOR  c_Dim_Group_Id IS
    SELECT  Dim_Level_ID
    FROM    BSC_SYS_DIM_LEVELS_B
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
END Get_Bsc_Dim_Obj_ID;

/*********************************************************************************************
                         Refresh BSC-PMF Dimension Object View of BSC
*********************************************************************************************/
PROCEDURE Refresh_BSC_PMF_Dim_View
(       p_Short_Name          IN             VARCHAR2
    ,   x_return_status       OUT NOCOPY     VARCHAR2
    ,   x_msg_count           OUT NOCOPY     NUMBER
    ,   x_msg_data            OUT NOCOPY     VARCHAR2
) IS
    l_bsc_dim_obj_rec       BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
    l_flag                  BOOLEAN;

    CURSOR    c_Pmf_Dim_Obj is
    SELECT    A.Short_Name
            , A.Source       PMF_Source
            , A.Level_Values_View_Name
            , A.Hide_In_Design
            , B.Level_Table_Name
            , B.Dim_Level_Id
    FROM      BIS_LEVELS             A
            , BSC_SYS_DIM_LEVELS_B   B
    WHERE     A.Short_Name        =  B.Short_Name
    AND       B.Source            = 'PMF'
    AND       A.Source            = 'OLTP';

    -- Cursor to filter out by SHORT_NAME
    CURSOR    c_Pmf_Dim_Obj_SN is
    SELECT    A.Short_Name
            , A.Source       PMF_Source
            , A.Level_Values_View_Name
            , A.Hide_In_Design
            , B.Level_Table_Name
            , B.Dim_Level_Id
    FROM      BIS_LEVELS             A
            , BSC_SYS_DIM_LEVELS_B   B
    WHERE     A.Short_Name        =  B.Short_Name
    AND       B.Source            = 'PMF'
    AND       A.Source            = 'OLTP'
    AND       B.Short_Name        = p_Short_Name;
BEGIN

    IF (p_Short_Name IS NULL) THEN
        FOR PMF_CD IN c_Pmf_Dim_Obj LOOP
          IF (NVL(PMF_CD.Hide_In_Design,'F') <> 'T') THEN
            l_bsc_dim_obj_rec.Bsc_Source              :=  'PMF';
            l_bsc_dim_obj_rec.Bsc_Level_View_Name     :=   PMF_CD.Level_Table_Name;      -- name of BSC View to be refereshed
            l_bsc_dim_obj_rec.Bsc_Level_Name          :=   PMF_CD.Level_Values_View_Name;-- name of PMF View
            l_bsc_dim_obj_rec.Bsc_Level_Short_Name    :=   PMF_CD.Short_Name;
            l_bsc_dim_obj_rec.Source                  :=   PMF_CD.PMF_Source;
            l_bsc_dim_obj_rec.Bsc_Level_Id            :=   PMF_CD.Dim_Level_Id;

            -- Calls Initialize_Pmf_Recs and Create_Pmf_Views APIs
            BSC_BIS_DIM_OBJ_PUB.Init_Create_Pmf_Recs
            (       p_Dim_Level_Rec   => l_bsc_dim_obj_rec
                ,   x_return_status   => x_return_status
                ,   x_msg_count       => x_msg_count
                ,   x_msg_data        => x_msg_data
            );
          END IF;

        END LOOP;
    ELSE
        FOR PMF_CD IN c_Pmf_Dim_Obj_SN LOOP
          IF (NVL(PMF_CD.Hide_In_Design,'F') <> 'T') THEN
            l_bsc_dim_obj_rec.Bsc_Source              :=  'PMF';
            l_bsc_dim_obj_rec.Bsc_Level_View_Name     :=   PMF_CD.Level_Table_Name;      -- name of BSC View to be refereshed
            l_bsc_dim_obj_rec.Bsc_Level_Name          :=   PMF_CD.Level_Values_View_Name;-- name of PMF View
            l_bsc_dim_obj_rec.Bsc_Level_Short_Name    :=   PMF_CD.Short_Name;
            l_bsc_dim_obj_rec.Source                  :=   PMF_CD.PMF_Source;
            l_bsc_dim_obj_rec.Bsc_Level_Id            :=   PMF_CD.Dim_Level_Id;
            -- Calls Initialize_Pmf_Recs and Create_Pmf_Views APIs
            BSC_BIS_DIM_OBJ_PUB.Init_Create_Pmf_Recs
            (       p_Dim_Level_Rec   => l_bsc_dim_obj_rec
                ,   x_return_status   => x_return_status
                ,   x_msg_count       => x_msg_count
                ,   x_msg_data        => x_msg_data
            );
          END IF;

        END LOOP;
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
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Refresh_BSC_PMF_Dim_View';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Refresh_BSC_PMF_Dim_View';
        END IF;
END Refresh_BSC_PMF_Dim_View;
--=======================================================================================

/*********************************************************************************************
                         Remove BSC-PMF EDW Dimension Object View of BSC
*********************************************************************************************/
PROCEDURE Remove_BSC_PMF_EDW_Dim_View
(       x_return_status       OUT NOCOPY     VARCHAR2
    ,   x_msg_count           OUT NOCOPY     NUMBER
    ,   x_msg_data            OUT NOCOPY     VARCHAR2
) IS
    l_sql            VARCHAR2(50);
    CURSOR    c_Pmf_Dim_Obj_Edw is
    SELECT    A.Short_Name
            , B.Level_Table_Name
    FROM      BIS_LEVELS           A
           ,  BSC_SYS_DIM_LEVELS_B B
    WHERE     A.Short_Name =  B.Short_Name
    AND       B.Source     = 'PMF'
    AND       A.Source     = 'EDW'
    AND       B.TABLE_TYPE = 1; -- Identify EDW with existing Views
BEGIN

    FOR PMF_EDW IN c_Pmf_Dim_Obj_Edw LOOP
        UPDATE BSC_SYS_DIM_LEVELS_B
        SET    Table_Type  =  -1
        WHERE  Short_Name  =  PMF_EDW.Short_Name;

        l_sql := 'DROP VIEW ' || PMF_EDW.Level_Table_Name;
        BSC_APPS.Do_Ddl_AT(l_sql, ad_ddl.drop_view, PMF_EDW.Level_Table_Name, BSC_APPS.fnd_apps_schema, BSC_APPS.bsc_apps_short_name);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Remove_BSC_PMF_EDW_Dim_View';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Remove_BSC_PMF_EDW_Dim_View';
        END IF;
END Remove_BSC_PMF_EDW_Dim_View;
--=======================================================================================

PROCEDURE Init_Create_Pmf_Recs
(       p_Dim_Level_Rec     IN  OUT   NOCOPY    BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT   NOCOPY    VARCHAR2
    ,   x_msg_count             OUT   NOCOPY    NUMBER
    ,   x_msg_data              OUT   NOCOPY    VARCHAR2
) IS
    l_flag                      BOOLEAN         :=  TRUE;
BEGIN
    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_flag  :=  BSC_BIS_DIM_OBJ_PUB.Initialize_Pmf_Recs
                (     p_Dim_Level_Rec     =>  p_Dim_Level_Rec
                    , x_return_status     =>  x_return_status
                    , x_msg_count         =>  x_msg_count
                    , x_msg_data          =>  x_msg_data
                );

    IF (l_flag) THEN
        l_flag  :=  BSC_BIS_DIM_OBJ_PUB.Create_Pmf_Views
                    (    p_Dim_Level_Rec  =>  p_Dim_Level_Rec
                       , x_return_status  =>  x_return_status
                       , x_msg_count      =>  x_msg_count
                       , x_msg_data       =>  x_msg_data
                    );
    END IF;

    -- This is called from concurrent programs and upgrade scripts
    -- so, we need to process all the Dimension Objects, even if some fail
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
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Init_Create_Pmf_Recs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Init_Create_Pmf_Recs ';
        END IF;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Init_Create_Pmf_Recs ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Init_Create_Pmf_Recs ';
        END IF;
END Init_Create_Pmf_Recs;
--=======================================================================================
FUNCTION Get_Table_Type_Value(
             p_Short_Name IN BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE
) RETURN NUMBER IS

  l_Return NUMBER;

BEGIN

    SELECT TABLE_TYPE
    INTO   l_Return
    FROM   BSC_SYS_DIM_LEVELS_B
    WHERE  SHORT_NAME = p_Short_Name;

    RETURN l_Return;

EXCEPTION
    WHEN OTHERS THEN
        RETURN -1;
END Get_Table_Type_Value;


FUNCTION Is_Default_Value(
    p_value IN  VARCHAR2
) RETURN BOOLEAN IS
BEGIN
    IF (p_value is NULL) THEN
        RETURN FALSE;
    END IF;

    IF (UPPER(p_value) = 'PMD_1') THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END Is_Default_Value;
/********************************************************************
      Check no of independent dimension objects in dimension set
*********************************************************************/

PROCEDURE check_indp_dimobjs
(
        p_dim_id                IN    NUMBER
    ,   x_return_status         OUT   NOCOPY    VARCHAR2
    ,   x_msg_count             OUT   NOCOPY    NUMBER
    ,   x_msg_data              OUT   NOCOPY    VARCHAR2
) IS
    l_kpi_id                NUMBER;
    l_dim_set_id            NUMBER;
    l_count                 NUMBER;
    l_indp_dimobj           NUMBER;
    l_affected_kpis         VARCHAR2(32000);
    l_kpi_name              VARCHAR2(20000);
    l_is_kpi_affected       BOOLEAN;

    CURSOR   cr_kpi_dimset_dimobj IS
    SELECT   LEV.INDICATOR,LEV.dim_set_id,COUNT(LEV.dim_level_index)
    FROM     BSC_KPI_DIM_LEVELS_B LEV,
             BSC_KPI_DIM_LEVEL_PROPERTIES prop
    WHERE    lev.INDICATOR = prop.INDICATOR
    AND      lev.dim_Set_id = prop.dim_set_id
    AND      prop.dim_level_id = p_dim_id
    GROUP BY lev.INDICATOR,lev.dim_set_id;


BEGIN
    l_is_kpi_affected := FALSE;
    OPEN cr_kpi_dimset_dimobj;
    LOOP
        FETCH cr_kpi_dimset_dimobj INTO l_kpi_id,l_dim_set_id,l_count;
        EXIT WHEN cr_kpi_dimset_dimobj%NOTFOUND;
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
    CLOSE cr_kpi_dimset_dimobj;
    IF(l_is_kpi_affected) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_IND_DIMOBJ_LIMIT');
        FND_MESSAGE.SET_TOKEN('NAME_LIST',l_affected_kpis);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF (cr_kpi_dimset_dimobj%ISOPEN) THEN
            CLOSE cr_kpi_dimset_dimobj;
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
        IF (cr_kpi_dimset_dimobj%ISOPEN) THEN
            CLOSE cr_kpi_dimset_dimobj;
        END IF;
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
        IF (cr_kpi_dimset_dimobj%ISOPEN) THEN
            CLOSE cr_kpi_dimset_dimobj;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Update_Dim_Object ';
        END IF;

END check_indp_dimobjs;

/*=======================================================================================
    This procedure will strip off the invalid characters(NLS Characters,some invalid characters
    from the given string and returns the valid string
=======================================================================================*/
FUNCTION  get_valid_ddlentry_frm_name(
    p_name          IN VARCHAR2
)RETURN VARCHAR2 IS

l_asc           number;
l_valid_string   varchar2(80);
l_char          varchar2(1);
l_alias         VARCHAR2(30);

BEGIN
     l_valid_string := null;
        -- Valid values - numbers/alphabets/underscore
    for i in 1..length(p_name) loop
        begin
            l_char := substr(p_name, i, 1);
        exception
            when others then
                l_char := ' ';/* comsuming this exception as substr() will throw exception for NLS charactes and whole procedure is not being executed */
        end;

        l_asc := ascii(l_char);
        If ((l_asc >= 48 And l_asc <= 57)) or
            (l_asc >= 65 And l_asc <= 90) or
            (l_asc >= 97 And l_asc <= 122) or
            (l_asc = 95) Then
            l_valid_string := l_valid_string || l_char;
        end if;
    end loop;

    RETURN l_valid_string;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_valid_string;
END get_valid_ddlentry_frm_name;
--=======================================================================================
PROCEDURE Validate_PMF_Views
( p_Dim_Obj_Short_Name            IN  VARCHAR2
       , p_Dim_Obj_View_Name             IN  VARCHAR2
       , x_Return_Status                 OUT NOCOPY VARCHAR2
       , x_Msg_Count                     OUT NOCOPY NUMBER
       , x_Msg_Data                      OUT NOCOPY VARCHAR2
)
IS
  l_View_Return_Value   NUMBER;
  l_Count               NUMBER;
  l_Parent_Cols         VARCHAR2(2000);
  l_View_Name           VARCHAR2(30);
  l_Parent_Exists       VARCHAR2(1);

    CURSOR c_Rel_Levels IS
    SELECT   R.SHORT_NAME             CHILD_SHORT_NAME
           , R.RELATION_COL           PARENT_COL
           , L.LEVEL_VALUES_VIEW_NAME VIEW_NAME
    FROM     BSC_SYS_DIM_LEVEL_RELS_V R
           , BIS_LEVELS               L
    WHERE  R.SHORT_NAME  = L.SHORT_NAME
    AND    L.SHORT_NAME  = p_Dim_Obj_Short_Name
    AND    R.SOURCE      = 'PMF';

BEGIN

    FND_MSG_PUB.Initialize;
    x_Return_Status     := FND_API.G_RET_STS_SUCCESS;

    l_Count := 0;
    l_Parent_Cols := NULL;

    FOR cRelLevels IN c_Rel_Levels LOOP
      IF (l_Count = 0) THEN
         l_Parent_Cols := cRelLevels.PARENT_COL;
         l_View_Name   := cRelLevels.VIEW_NAME;
      ELSE
         l_Parent_Cols := l_Parent_Cols ||', '||cRelLevels.PARENT_COL;
      END IF;
      l_Count := l_Count + 1;

    END LOOP;

    l_Parent_Exists := FND_API.G_FALSE;

    IF (l_Count = 0) THEN
       IF (p_Dim_Obj_View_Name IS NOT NULL) THEN
          l_View_Name := p_Dim_Obj_View_Name;
       ELSE
         BEGIN
            SELECT L.LEVEL_VALUES_VIEW_NAME
            INTO   l_View_Name
            FROM   BIS_LEVELS L
            WHERE  L.SHORT_NAME = p_Dim_Obj_Short_Name;
         EXCEPTION
            WHEN OTHERS THEN
              l_View_Name := NULL;
         END;
       END IF;
    ELSIF (l_Count > 0) THEN
       l_Parent_Exists := FND_API.G_TRUE;
    END IF;

    IF (p_Dim_Obj_Short_Name = 'HRI_PER_USRDR_H') THEN
      l_View_Return_Value := BSC_BIS_DIM_OBJ_PUB.Validate_PMF_Base_View_Mgr(
                               p_View_Name        => l_View_Name
                             , p_Parent_Id_Exists => l_Parent_Exists
                             , p_Parent_Column    => l_Parent_Cols
                             );
    ELSE
      l_View_Return_Value := BSC_BIS_DIM_OBJ_PUB.Validate_PMF_Base_View(
                               p_View_Name        => l_View_Name
                             , p_Parent_Id_Exists => l_Parent_Exists
                             , p_Parent_Column    => l_Parent_Cols
                             );
    END IF;

    IF (l_View_Return_Value = C_TABLE_NOT_EXIST) THEN
       x_Msg_Data  :=  'BSC_DIM_VIEW_NOT_EXIST';
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_View_Return_Value = C_UNKNOWN_ERROR) THEN
       x_Msg_Data  :=  'BSC_DIM_VIEW_NOT_EXIST';
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_View_Return_Value = C_COLUMN_NOT_EXIST) THEN
       x_Msg_Data  :=  'BSC_DIM_VIEW_INVALID';
       RAISE FND_API.G_EXC_ERROR;
    END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        x_Msg_Data      :=  'BSC_DIM_VIEW_NOT_EXIST';
        x_Return_Status :=  FND_API.G_RET_STS_ERROR;
END Validate_PMF_Views;

/*
  Validates BSC type dim object view source
*/
PROCEDURE Validate_BSC_Views
( p_Dim_Obj_Short_Name            IN  VARCHAR2
, x_Return_Status                 OUT NOCOPY VARCHAR2
, x_Msg_Count                     OUT NOCOPY NUMBER
, x_Msg_Data                      OUT NOCOPY VARCHAR2
)
IS

  l_flag  bsc_sys_dim_levels_b.table_type%TYPE;
  CURSOR c_bsc_table_type_flag IS
    SELECT table_type
      FROM bsc_sys_dim_levels_b
      WHERE short_name = p_Dim_Obj_Short_Name;

BEGIN

  FND_MSG_PUB.Initialize;
  x_Return_Status := FND_API.G_RET_STS_SUCCESS;

  IF (c_bsc_table_type_flag%ISOPEN) THEN
    CLOSE c_bsc_table_type_flag;
  END IF;

  OPEN c_bsc_table_type_flag;
  FETCH c_bsc_table_type_flag INTO l_flag;

  IF (c_bsc_table_type_flag%FOUND) THEN
    IF (l_flag <> 1) THEN  -- '1' means that BSC view exists
      x_Msg_Data  :=  'BSC_DIM_VIEW_NOT_EXIST';
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  CLOSE c_bsc_table_type_flag;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    IF (c_bsc_table_type_flag%ISOPEN) THEN
      CLOSE c_bsc_table_type_flag;
    END IF;
  WHEN OTHERS THEN
    x_Msg_Data      :=  'BSC_DIM_VIEW_NOT_EXIST';
    x_Return_Status :=  FND_API.G_RET_STS_ERROR;
    IF (c_bsc_table_type_flag%ISOPEN) THEN
      CLOSE c_bsc_table_type_flag;
    END IF;
END Validate_BSC_Views;

/*
  Validates dim object view source.
  Called from Report Designer.
*/
PROCEDURE Validate_Dim_object_Views
( p_Dim_Obj_Short_Name            IN  VARCHAR2
, p_Dim_Obj_View_Name             IN  VARCHAR2
, x_Return_Status                 OUT NOCOPY VARCHAR2
, x_Msg_Count                     OUT NOCOPY NUMBER
, x_Msg_Data                      OUT NOCOPY VARCHAR2
)
IS
BEGIN

  FND_MSG_PUB.Initialize;
  x_Return_Status     := FND_API.G_RET_STS_SUCCESS;

  IF ('PMF' = BIS_PMF_GET_DIMLEVELS_PVT.get_dim_level_source(p_Dim_Obj_Short_Name)) THEN
    IF (INSTR(p_Dim_Obj_Short_Name, 'FII_ROLLING_') = 0) THEN
      Validate_PMF_Views
        ( p_Dim_Obj_Short_Name => p_Dim_Obj_Short_Name
        , p_Dim_Obj_View_Name  => p_Dim_Obj_View_Name
        , x_Return_Status      => x_Return_Status
        , x_Msg_Count          => x_Msg_Count
        , x_Msg_Data           => x_Msg_Data
        );
    END IF;
  ELSE
    Validate_BSC_Views
      ( p_Dim_Obj_Short_Name => p_Dim_Obj_Short_Name
      , x_Return_Status      => x_Return_Status
      , x_Msg_Count          => x_Msg_Count
      , x_Msg_Data           => x_Msg_Data
      );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_Return_Status :=  FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_Msg_Data      :=  'BSC_DIM_VIEW_NOT_EXIST';
    x_Return_Status :=  FND_API.G_RET_STS_ERROR;
END Validate_Dim_object_Views;

--=======================================================================================
FUNCTION Validate_PMF_Base_View (
             p_View_Name        IN VARCHAR2
           , p_Parent_Id_Exists IN VARCHAR2
           , p_Parent_Column    IN VARCHAR2
) RETURN NUMBER IS
  l_Sql            VARCHAR2(4000);
  l_Select_Clause  VARCHAR2(4000);
  l_Id             VARCHAR2(4000);
  l_Parent_Id      VARCHAR2(4000);
  l_Value          VARCHAR2(4000);

  l_Count          NUMBER := 0;
BEGIN

  IF (p_View_Name IS NULL) THEN
    RETURN C_TABLE_NOT_EXIST;
  END IF;

  IF (p_Parent_Id_Exists = FND_API.G_TRUE) THEN
     IF (p_Parent_Column IS NOT NULL) THEN
        l_Select_Clause := C_SELECT_CLAUSE || ', ' || p_Parent_Column || ' ';
     ELSE
        l_Select_Clause := C_SELECT_PARENT_CLAUSE;
     END IF;
  ELSE
     l_Select_Clause := C_SELECT_CLAUSE;
  END IF;

  l_Sql :=    C_SELECT   || l_Select_Clause
           || C_FROM     || p_View_Name
           || C_WHERE    || C_WHERE_CLAUSE ;

  IF (p_Parent_Id_Exists = FND_API.G_TRUE) THEN
    l_Sql := 'SELECT COUNT(1) FROM ('|| l_Sql || ')' ;
    EXECUTE IMMEDIATE l_Sql INTO l_Count;
  ELSE
    EXECUTE IMMEDIATE l_Sql INTO l_Id, l_Value;
  END IF;

  RETURN C_SUCCESS_NO_ERROR;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  -- Return success, view is ok, but there is no data
     RETURN C_SUCCESS_NO_ERROR;

  WHEN OTHERS THEN
    IF (SQLCODE = C_ORA_ERR_TAB_NOT_EXIST) THEN
      RETURN C_TABLE_NOT_EXIST;
    ELSIF ((SQLCODE = C_ORA_ERR_COL_NOT_EXIST) OR (SQLCODE = C_ORA_ERR_COL_NOT_EXIST1)) THEN
      RETURN C_COLUMN_NOT_EXIST;
    END IF;

    RETURN C_UNKNOWN_ERROR;
END Validate_PMF_Base_View;


FUNCTION Validate_PMF_Base_View_Mgr (
  p_view_name        IN VARCHAR2
, p_parent_id_exists IN VARCHAR2
, p_parent_column    IN VARCHAR2
) RETURN NUMBER
IS
  l_col_name       VARCHAR2(30);
  l_view_status    VARCHAR2(100);
  l_is_id          BOOLEAN := FALSE;
  l_is_value       BOOLEAN := FALSE;
  l_is_parent_id   BOOLEAN := FALSE;

  CURSOR c_column_names IS
    SELECT column_name
      FROM user_tab_columns
      WHERE table_name = p_view_name;

  CURSOR c_view_status IS
    SELECT status
      FROM user_objects
      WHERE object_name = p_view_name
      AND   object_type = 'VIEW';
BEGIN

  IF (p_view_name IS NULL) THEN
    RETURN C_TABLE_NOT_EXIST;
  END IF;

  IF (c_view_status%ISOPEN) THEN
    CLOSE c_view_status;
  END IF;
  OPEN c_view_status;
  FETCH c_view_status INTO l_view_status;
  IF (l_view_status IS NULL OR UPPER(l_view_status) <> 'VALID') THEN
    RETURN C_TABLE_NOT_EXIST;
  END IF;
  CLOSE c_view_status ;

  IF (c_column_names%ISOPEN) THEN
    CLOSE c_column_names;
  END IF;
  OPEN c_column_names;
  LOOP
    FETCH c_column_names INTO l_col_name;
    EXIT WHEN c_column_names%NOTFOUND;
    IF (UPPER(l_col_name) = 'ID') THEN
      l_is_id := TRUE;
    ELSIF (UPPER(l_col_name) = 'VALUE') THEN
      l_is_value := TRUE;
    ELSIF (UPPER(l_col_name) = p_parent_column) THEN
      l_is_parent_id := TRUE;
    END IF;
  END LOOP;
  CLOSE c_column_names ;

  IF (p_parent_id_exists = FND_API.G_TRUE AND p_parent_column IS NOT NULL) THEN
    IF ((NOT l_is_id) OR (NOT l_is_value) OR (NOT l_is_parent_id)) THEN
      RETURN C_COLUMN_NOT_EXIST;
    END IF;
  ELSE
    IF ((NOT l_is_id) OR (NOT l_is_value)) THEN
      RETURN C_COLUMN_NOT_EXIST;
    END IF;
  END IF;

  RETURN C_SUCCESS_NO_ERROR;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_column_names%ISOPEN) THEN
      CLOSE c_column_names;
    END IF;
    IF (c_view_status%ISOPEN) THEN
      CLOSE c_view_status;
    END IF;
    RETURN C_UNKNOWN_ERROR;
END Validate_PMF_Base_View_Mgr;


FUNCTION check_sametype_dims
(       p_dim_obj_name              IN  VARCHAR2
    ,   p_dim_obj_short_name        IN  VARCHAR2
    ,   p_dim_obj_source            IN  VARCHAR2
    ,   p_dim_short_names           IN  VARCHAR2
    ,   p_Restrict_Dim_Validate     IN  VARCHAR2   := NULL
    ,   x_return_status             OUT    NOCOPY   VARCHAR2
    ,   x_msg_count                 OUT    NOCOPY   NUMBER
    ,   x_msg_data                  OUT    NOCOPY   VARCHAR2
) RETURN BOOLEAN
IS

    l_source             VARCHAR2(20);
    l_true               BOOLEAN;
    l_dim_obj_name       VARCHAR2(32000);
    l_dim_name           VARCHAR2(32000);
    l_dim_grp_id         NUMBER;
    l_dim_short_name     VARCHAR2(32000);
    l_count              NUMBER;
    l_exist              NUMBER;

    CURSOR C_SOURCE_DIM IS
    SELECT DISTINCT SOURCE,DIM_NAME,DIM_ID,SHORT_NAME
    FROM BSC_BIS_DIM_VL
    WHERE SOURCE IS NOT NULL
    AND INSTR(','||p_dim_short_names ||',',','||short_name||',') > 0;

    CURSOR C_SOURCE_DIM_OBJS IS
    SELECT SYS.SOURCE,SYS.SHORT_NAME,SYS.NAME
    FROM   BSC_SYS_DIM_LEVELS_VL SYS,
           BSC_SYS_DIM_LEVELS_BY_GROUP GRP
    WHERE  SYS.dim_level_id = GRP.dim_level_id
    AND    GRP.dim_group_id = l_dim_grp_id;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_true  := FALSE;

    -- added to relax checking for mixed type of Dimension Objects within a Dimension
    -- for Autogenerated reports and removing the disctiction, BSC 5.3
    IF (p_Restrict_Dim_Validate IS NOT NULL OR BIS_UTILITIES_PUB.Enable_Generated_Source_Report = FND_API.G_FALSE) THEN
        FOR CTYPE IN C_SOURCE_DIM LOOP
            l_dim_name       := CTYPE.DIM_NAME;
            l_dim_grp_id     := CTYPE.DIM_ID;
            l_dim_short_name := CTYPE.SHORT_NAME;

            SELECT COUNT(1) into l_count
            FROM  BSC_SYS_DIM_LEVELS_BY_GROUP GRP
            WHERE GRP.dim_group_id = l_dim_grp_id;

            SELECT COUNT(1) into l_exist
            FROM   BSC_SYS_DIM_LEVELS_VL SYS,
                   BSC_SYS_DIM_LEVELS_BY_GROUP GRP
            WHERE  SYS.dim_level_id = GRP.dim_level_id
            AND    GRP.dim_group_id = l_dim_grp_id
            AND    SYS.SHORT_NAME = p_dim_obj_short_name;

            IF (l_count >= bsc_utility.MAX_DIM_IN_DIM_SET AND l_exist = 0 AND p_dim_obj_source = 'BSC' AND CTYPE.SOURCE = 'BSC') THEN
               FND_MESSAGE.SET_NAME('BSC','BSC_DIM_SHUTTLE_OVERFLOW');
               FND_MSG_PUB.ADD;
               return TRUE;
            END IF;

            IF(CTYPE.SOURCE <> p_dim_obj_source AND BSC_UTILITY.Is_Internal_Dimension(l_dim_short_name) = FND_API.G_FALSE) THEN
                l_true  :=  TRUE;
                FOR CD IN C_SOURCE_DIM_OBJS LOOP
                    l_dim_obj_name := cd.name;
                    IF(l_source IS NULL) THEN
                        l_source := CD.SOURCE;
                    END IF;
                    IF ((l_dim_short_name = BSC_BIS_DIMENSION_PUB.Unassigned_Dim) AND
                        (l_source = 'BSC')) THEN
                        EXIT;
                    END IF;
                    IF((l_source <> CD.SOURCE)OR (l_source <> p_dim_obj_source)) THEN
                        EXIT;
                    END IF;
                END LOOP;
                EXIT;
            END IF;
        END LOOP;

        IF (l_true) THEN
            FND_MESSAGE.SET_NAME('BSC','BSC_DIM_DIMOBJ_MIXED_TYPE');
            FND_MESSAGE.SET_TOKEN('DIMENSION',  l_dim_name);
            FND_MESSAGE.SET_TOKEN('DIM_OBJECT', p_dim_obj_name);
            FND_MSG_PUB.ADD;
            return l_true;
        END IF;
    END IF;

    x_return_status :=  FND_API.G_RET_STS_SUCCESS;
    RETURN l_true;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NULL) THEN
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIMENSION_PUB.is_Valid_Dim_Grp_Rels ';
        END IF;

        RETURN l_true;
END check_sametype_dims;


--=======================================================================================


--=======================================================================================

/************************************************************************
 Name   : is_Obj_Display_Frmt_Change
 Description    : This API will validate if the dimension object proeprties
                  will result in format changes.
                  Following properties of dimension object will result in
                  Format changes
                  1.p_maximum_code_size
                  2.p_maximum_name_size
                  3.p_prototype_default_value
Input :  p_dim_obj_short_name : dim object short name
         p_Source             : Source of the dimension object
         p_source_table       : dim object table name
         p_table_column       : column name of the dimension object
         p_prototype_default_value : prototype prefix value for dim level values
         p_maximum_code_size  : size of the user code
         p_maximum_name_size  : size of the display key name
         p_dim_short_names    :  dimension short names within which this dim obj is assigned
output   : x_obj_names  : comma separated objective names which are effected because of this change
           TRUE         : Display format has changed
           FALSE        : Display format has not changed
/************************************************************************/

FUNCTION is_Obj_Display_Frmt_Change
(       p_dim_obj_short_name        IN          VARCHAR2
    ,   p_Source                    IN          VARCHAR2
    ,   p_source_table              IN          VARCHAR2
    ,   p_table_column              IN          VARCHAR2
    ,   p_prototype_default_value   IN          VARCHAR2
    ,   p_maximum_code_size         IN          NUMBER
    ,   p_maximum_name_size         IN          NUMBER
    ,   p_dim_short_names           IN          VARCHAR2
    ,   x_obj_names                 OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN IS

  l_MTab_Tbl              BSC_BIS_DIM_OBJ_PUB.KPI_Dim_Set_Table_Type;
  l_bsc_dim_obj_rec       BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
  l_obj_names             VARCHAR2(8000);
  l_child_dim_obj_list    VARCHAR2 (32000);
  l_disp_format_flag      BOOLEAN := FALSE;
  l_child_disp_fm_flag    BOOLEAN := FALSE;
  l_counter               NUMBER;
  l_duplicate_flag        BOOLEAN;
  l_return_flag           BOOLEAN := FALSE;
  l_maximum_code_size     BSC_SYS_DIM_LEVELS_VL.user_key_size%TYPE;
  l_maximum_name_size     BSC_SYS_DIM_LEVELS_VL.disp_key_size%TYPE;


  CURSOR   c_Old_Dim_Obj_Rec  IS
  SELECT   dim_level_id
        ,  level_table_name
        ,  user_key_size
        ,  disp_key_size
        ,  NVL(source, 'BSC')
        ,  abbreviation
        ,  level_pk_col
  FROM     BSC_SYS_DIM_LEVELS_VL
  WHERE    short_name = p_dim_obj_short_name;

  CURSOR   c_Kpi_Dim_Set1 IS
  SELECT   DISTINCT C.Name||'['||C.Indicator||']' Name
          ,C.Indicator
  FROM     BSC_KPI_DIM_LEVELS_B    A
        ,  BSC_SYS_DIM_LEVELS_B    D
        ,  BSC_KPIS_VL             C
  WHERE    A.Level_Table_Name      =  D.Level_Table_Name
  AND      C.share_flag           <>  2
  AND      C.Indicator             =  A.Indicator
  AND      INSTR(','||l_child_dim_obj_list||',', ','||D.dim_level_id||',') > 0;

  CURSOR   c_Kpi_Dim_Set IS
  SELECT   DISTINCT C.Name||'['||C.Indicator||']' Name
          , C.Indicator
  FROM     BSC_KPI_DIM_LEVELS_B    A
        ,  BSC_SYS_DIM_LEVELS_B    D
        ,  BSC_KPIS_VL             C
  WHERE    A.Level_Table_Name      =  D.Level_Table_Name
  AND      D.Dim_Level_Id          =  l_bsc_dim_obj_rec.Bsc_Level_Id
  AND      C.share_flag           <>  2
  AND      C.Indicator             =  A.Indicator;

BEGIN
     IF (p_dim_obj_short_name IS NOT NULL) THEN

        OPEN   c_old_dim_obj_rec;
        FETCH  c_old_dim_obj_rec
        INTO   l_bsc_dim_obj_rec.Bsc_Level_Id
            ,  l_bsc_dim_obj_rec.Bsc_Level_Name
            ,  l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size
            ,  l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size
            ,  l_bsc_dim_obj_rec.Bsc_Source
            ,  l_bsc_dim_obj_rec.Bsc_Level_Abbreviation
            ,  l_bsc_dim_obj_rec.Bsc_Pk_Col;
        CLOSE c_old_dim_obj_rec;

        l_maximum_name_size := p_maximum_name_size;
        l_maximum_code_size := p_maximum_code_size;

        IF(l_maximum_code_size<BSC_BIS_DIM_OBJ_PUB.DIM_OBJ_CODE_MIN_SIZE )THEN
         l_maximum_code_size :=NULL;
        END IF;

        IF(l_maximum_name_size<BSC_BIS_DIM_OBJ_PUB.DIM_OBJ_NAME_MIN_SIZE )THEN
          l_maximum_name_size :=NULL;
        END IF;

        IF((l_bsc_dim_obj_rec.Bsc_Level_Abbreviation <> NVL(p_prototype_default_value, l_bsc_dim_obj_rec.Bsc_Level_Abbreviation)) OR
            (l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size <> NVL(l_maximum_code_size,l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size)) OR
             (l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size <> NVL(l_maximum_name_size, l_bsc_dim_obj_rec.Bsc_Level_Disp_Key_Size)))THEN
                l_disp_format_flag := TRUE;
        END IF;

        IF (l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size <> NVL(l_maximum_code_size, l_bsc_dim_obj_rec.Bsc_Level_User_Key_Size)) THEN
           l_child_disp_fm_flag := TRUE;
        END IF;
        l_counter :=0;

        IF (l_disp_format_flag) THEN
            FOR cd IN c_kpi_dim_set LOOP
                l_MTab_Tbl(l_counter).p_kpi_id :=  cd.Indicator;
                l_MTab_Tbl(l_counter).p_Name   :=  cd.Name;
                l_counter :=  l_counter + 1;
            END LOOP;

            l_child_dim_obj_list:= NULL;

            IF (l_child_disp_fm_flag) THEN
               l_child_dim_obj_list := Get_Child_Dim_Objs(p_Dim_Level_Id => l_bsc_dim_obj_rec.Bsc_Level_Id);
               IF (l_child_dim_obj_list IS NOT NULL) THEN
                    FOR ckds IN c_Kpi_Dim_Set1 LOOP
                       l_duplicate_flag := FALSE;
                       FOR i IN 0..(l_MTab_Tbl.COUNT-1) LOOP
                         IF(l_MTab_Tbl(i).p_kpi_id=ckds.Indicator)THEN
                           l_duplicate_flag := TRUE;
                           EXIT;
                         END IF;
                       END LOOP;

                       IF(NOT l_duplicate_flag) THEN
                         l_MTab_Tbl(l_counter).p_kpi_id :=  ckds.Indicator;
                         l_MTab_Tbl(l_counter).p_Name   :=  ckds.Name;
                         l_counter :=  l_counter + 1;
                       END IF;
                    END LOOP;
                END IF;
            END IF;
        END IF;
        FOR i IN 0..(l_MTab_Tbl.COUNT-1) LOOP
          IF(l_obj_names IS NULL)THEN
            l_obj_names := l_MTab_Tbl(i).p_Name;
          ELSE
            l_obj_names := l_obj_names||', '||l_MTab_Tbl(i).p_Name;
          END IF;
        END LOOP;
     END IF;

     x_obj_names := l_obj_names;
     IF(l_disp_format_flag)THEN
      l_return_flag := TRUE;
     END IF;

     RETURN l_return_flag;

END is_Obj_Display_Frmt_Change;

/******************************************************************************/
-- Added for Bug#4758995
FUNCTION Is_Recursive_Relationship
(
      p_Short_Name       IN VARCHAR2
    , x_Relation_Col     OUT NOCOPY VARCHAR2
    , x_Data_Source      OUT NOCOPY VARCHAR2
    , x_Data_Source_Type OUT NOCOPY VARCHAR2
) RETURN VARCHAR2 IS
    l_Count NUMBER;

    CURSOR c_Rels IS
        SELECT R.RELATION_COL,
               R.DATA_SOURCE,
               R.DATA_SOURCE_TYPE
        FROM  BSC_SYS_DIM_LEVEL_RELS_V R
        WHERE R.DIM_LEVEL_ID      = R.PARENT_DIM_LEVEL_ID
        AND   R.SHORT_NAME        = p_Short_Name
        AND   R.PARENT_SHORT_NAME = p_Short_Name
        AND   R.SOURCE            = BSC_UTILITY.c_PMF
        AND   R.PARENT_SOURCE     = BSC_UTILITY.c_PMF;
BEGIN
    l_Count := 0;

    FOR cRE IN c_Rels LOOP
        x_Relation_Col      := cRE.RELATION_COL;
        x_Data_Source       := cRE.DATA_SOURCE;
        x_Data_Source_Type  := cRE.DATA_SOURCE_TYPE;

        l_Count := l_Count + 1;
    END LOOP;

    IF (l_Count = 1) THEN
        RETURN FND_API.G_TRUE;
    ELSE
        RETURN FND_API.G_FALSE;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RETURN FND_API.G_FALSE;
END Is_Recursive_Relationship;
/******************************************************************************/


/******************************************************************************/
-- Added for Bug#4758995
FUNCTION Get_Unique_Level_Pk_Col
(       p_Dim_Level_Rec  IN  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status  OUT NOCOPY   VARCHAR2
    ,   x_msg_count      OUT NOCOPY   NUMBER
    ,   x_msg_data       OUT NOCOPY   VARCHAR2
) RETURN VARCHAR2 IS
    l_Dim_Object_Name BSC_SYS_DIM_LEVELS_VL.NAME%TYPE;
    l_Level_Pk_Col    BSC_SYS_DIM_LEVELS_VL.LEVEL_PK_COL%TYPE;
    l_temp_var        VARCHAR2(1000);
    l_alias           VARCHAR2(1000);
    l_flag            BOOLEAN;
    l_count           NUMBER;

    CURSOR c_Lvl_Pk_Col IS
      SELECT D.LEVEL_PK_COL
      FROM   BSC_SYS_DIM_LEVELS_B D
      WHERE  D.SHORT_NAME = p_Dim_Level_Rec.Bsc_Level_Short_Name;
BEGIN

    FND_MSG_PUB.Initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_Dim_Level_Rec.Bsc_Dim_Level_Long_Name IS NOT NULL) THEN
        l_Dim_Object_Name := REPLACE(p_Dim_Level_Rec.Bsc_Level_Name, ' ', '');
    ELSE
        l_Dim_Object_Name := REPLACE(p_Dim_Level_Rec.Bsc_Level_Short_Name ,' ', '_');
    END IF;

    l_Level_Pk_Col := p_Dim_Level_Rec.Bsc_Pk_Col;
    IF (l_Level_Pk_Col IS NULL) THEN
        FOR cLPK IN c_Lvl_Pk_Col LOOP
         l_Level_Pk_Col := cLPK.LEVEL_PK_COL;
        END LOOP;

        IF (l_Level_Pk_Col IS NULL) THEN
            l_Level_Pk_Col  :=  SUBSTR(l_Dim_Object_Name, 7, LENGTH(l_Dim_Object_Name))||'_CODE';
        END IF;

        IF (NOT is_Valid_Identifier(l_Level_Pk_Col)) THEN
	    IF (LENGTH(l_Level_Pk_Col) > 26) THEN
	       l_Level_Pk_Col := SUBSTR(l_Level_Pk_Col, 1, 26);
	    END IF;
            l_Level_Pk_Col  :=  'BSC_'||l_Level_Pk_Col;
        END IF;
    ELSIF (NOT is_Valid_Identifier(l_Level_Pk_Col)) THEN
        FND_MESSAGE.SET_NAME('BSC','BSC_INVALID_SQL_IDENTIFIER');
        FND_MESSAGE.SET_TOKEN('SQL_IDENT', BSC_APPS.Get_Lookup_Value('BSC_UI_COMMON', 'DIM_OBJ_PK_COL'), TRUE);
        FND_MESSAGE.SET_TOKEN('SQL_VALUE', l_Level_Pk_Col);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF(is_SQL_Key_Word(l_Level_Pk_Col)) THEN
        l_Level_Pk_Col  :=  l_Level_Pk_Col||'_CODE';
    END IF;

    l_Level_Pk_Col  :=  SUBSTR(l_Level_Pk_Col, 1, 26);
    l_flag          :=  TRUE;
    l_alias         :=  NULL;
    l_temp_var      :=  l_Level_Pk_Col;
    WHILE (l_flag) LOOP
        SELECT COUNT(1) INTO l_count
        FROM   BSC_SYS_DIM_LEVELS_B
        WHERE  SHORT_NAME       <> p_Dim_Level_Rec.Bsc_Level_Short_Name
        AND    UPPER(LEVEL_PK_COL)  = UPPER(l_temp_var);
        IF (l_count = 0) THEN
            l_flag            :=  FALSE;
            l_Level_Pk_Col    :=  l_temp_var;
        END IF;
        l_alias     :=  BSC_BIS_DIM_OBJ_PUB.get_Next_Alias(l_alias);
        l_temp_var  :=  SUBSTR(l_Level_Pk_Col, 1, 18)||l_alias||'_CODE';
    END LOOP;

    RETURN l_Level_Pk_Col;

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
        RETURN NULL;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF (x_msg_data IS NULL) THEN
            FND_MSG_PUB.Count_And_Get
            (      p_encoded   =>  FND_API.G_FALSE
               ,   p_count     =>  x_msg_count
               ,   p_data      =>  x_msg_data
            );
        END IF;
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN NULL;
    WHEN NO_DATA_FOUND THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Get_Unique_Level_Pk_Col ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Get_Unique_Level_Pk_Col ';
        END IF;
        RETURN NULL;
    WHEN OTHERS THEN
        x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (x_msg_data IS NOT NULL) THEN
            x_msg_data      :=  x_msg_data||' -> BSC_BIS_DIM_OBJ_PUB.Get_Unique_Level_Pk_Col ';
        ELSE
            x_msg_data      :=  SQLERRM||' at BSC_BIS_DIM_OBJ_PUB.Get_Unique_Level_Pk_Col ';
        END IF;
        RETURN NULL;
END Get_Unique_Level_Pk_Col;
/******************************************************************************/


/********************************************************************************
    This is a Public API, used by Backend to validate and create the BSC views
    for existing source dimension Objects. Bug #4992082
    It first validates if corresponding bis view is valid then try to create a
    BSC wrapper view on top of the existing valid view.
********************************************************************************/

PROCEDURE Validate_Refresh_BSC_PMF_Views
( p_Dim_Obj_Short_Name    IN  VARCHAR2
, x_Return_Status         OUT NOCOPY VARCHAR2
, x_Msg_Count             OUT NOCOPY NUMBER
, x_Msg_Data              OUT NOCOPY VARCHAR2
)
IS
l_name                VARCHAR2(300);
l_dim_obj_view_name   VARCHAR2(30);
l_source              VARCHAR2(5);
BEGIN

SELECT bsc.name, bis.LEVEL_VALUES_VIEW_NAME, bsc.source
INTO l_name, l_Dim_Obj_View_Name, l_source
FROM bsc_sys_dim_levels_vl bsc, bis_levels_vl bis
WHERE bsc.short_name = bis.short_name
AND bsc.short_name = p_Dim_Obj_Short_Name;

IF (l_source = BSC_UTILITY.c_PMF) THEN
  BSC_BIS_DIM_OBJ_PUB.Validate_PMF_Views(
    p_Dim_Obj_Short_Name => p_Dim_Obj_Short_Name
   ,p_Dim_Obj_View_Name  => l_Dim_Obj_View_Name
   ,x_Return_Status      => x_Return_Status
   ,x_Msg_Count          => x_Msg_Count
   ,x_Msg_Data           => x_Msg_Data
  );

  IF (x_Return_Status <> FND_API.G_RET_STS_SUCCESS AND x_Msg_Data IS NOT NULL) THEN
    FND_MESSAGE.SET_NAME('BSC',x_Msg_Data);
    FND_MESSAGE.SET_TOKEN('DIM_OBJ', l_name, TRUE);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
END IF;

BSC_BIS_DIM_OBJ_PUB.Refresh_BSC_PMF_Dim_View(
  p_Short_Name    => p_Dim_Obj_Short_Name
 ,x_return_status => x_Return_Status
 ,x_msg_count     => x_msg_count
 ,x_msg_data      => x_Msg_Data
);

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
    (   p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_Msg_Data
    );
END Validate_Refresh_BSC_PMF_Views;

/****************************************************************************************************
This API takes dimension and dimension object short Names, finds all the dimension groups of the
reports containing that dim+dimobject combination. It then cascades the "All Enable/Disable" property
to the dim groups. This API doesnot take care of where clauses as of now.
p_Dim_Obj_Short_Name : Dimension Object Short Name
p_Dim_Short_Name     : Dimension Short Name
p_All_Flag           : "All" flag value
****************************************************************************************************/

PROCEDURE Cascade_Dim_Props_Into_Dim_Grp (
  p_Dim_Obj_Short_Name              IN  VARCHAR2
  , p_Dim_Short_Name                IN  VARCHAR2
  , p_All_Flag                      IN  NUMBER
  , x_Return_Status                 OUT NOCOPY VARCHAR2
  , x_Msg_Count                     OUT NOCOPY NUMBER
  , x_Msg_Data                      OUT NOCOPY VARCHAR2
) IS
    l_Dim_DimObj_Sht_Name       VARCHAR2(1000);
    l_Dim_Short_Name            BIS_DIMENSIONS.SHORT_NAME%TYPE;
    CURSOR c_dim_groups IS
    SELECT
      bis_dim.short_name
    FROM
      ak_regions reg,
      ak_region_items reg_item,
      bis_dimensions bis_dim
    WHERE
      reg_item.attribute2    = l_Dim_DimObj_Sht_Name
      AND reg.region_code    = reg_item.region_code
      AND bis_dim.short_name = reg.attribute12
      AND bis_util.is_seeded(bis_dim.created_by,'T','F') = 'F'
      AND NVL(hide_in_design,'F') = 'T';
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    l_Dim_DimObj_Sht_Name := p_Dim_Short_Name || '+' || p_Dim_Obj_Short_Name;
    IF (l_Dim_DimObj_Sht_Name IS NOT NULL) THEN
      OPEN c_dim_groups;
      LOOP
        FETCH c_dim_groups INTO l_Dim_Short_Name;
        EXIT WHEN c_dim_groups%NOTFOUND;
          UPDATE
            bsc_sys_dim_levels_by_group
          SET
            total_flag = p_All_Flag
          WHERE
            dim_level_id = BSC_BIS_DIM_OBJ_PUB.Get_Bsc_Dim_Obj_ID(p_Dim_Obj_Short_Name)
            AND   dim_group_id = BSC_BIS_DIMENSION_PUB.Get_Bsc_Dimension_ID(l_Dim_Short_Name);
      END LOOP;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.Count_And_Get
    (   p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_Msg_Data
    );
    x_Return_Status :=  FND_API.G_RET_STS_ERROR;
END Cascade_Dim_Props_Into_Dim_Grp;


END BSC_BIS_DIM_OBJ_PUB;

/
