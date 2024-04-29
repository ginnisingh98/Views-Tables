--------------------------------------------------------
--  DDL for Package BSC_BIS_DIM_OBJ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BIS_DIM_OBJ_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCDPMDS.pls 120.8 2006/02/10 00:27:23 akoduri noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCDPMDS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper for Dimensions, part of PMD APIs                  |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 14-FEB-2003 PAJOHRI  Created.                                         |
REM | 20-OCT-2003 PAJOHRI  Bug#3179995                                      |
REM | 04-NOV-2003 PAJOHRI  Bug #3152258                                     |
REM | 04-NOV-2003 PAJOHRI  Bug #3220613                                     |
REM | 04-NOV-2003 PAJOHRI  Bug #3262631                                     |
REM | 08-DEC-2003 KYADAMAK Bug #3225685                                     |
REM | 12-APR-2004 PAJOHRI  Bug #3426566, created the following new functions|
REM |                      Get_Bis_Dim_Obj_ID()                             |
REM |                      Get_Bsc_Dim_Obj_ID()                             |
REM | 09-AUG-2004 sawu     Added constant c_BSC_DIM_OBJ                     |
REM | 11-AUG-2004 sawu     Added create_dim_obj() for bug#3819855 with      |
REM |                      p_is_default_short_name                          |
REM | 08-Feb-04   skchoudh  Enh#3873195 drill_to_form_function column       |
REM |                  is added                                             |
REM | 15-FEB-05   ppandey   Enh #4016669, support ID, Value for Autogen DO  |
REM | 11-Mar-05   ankgoel   Enh#2690720 - AG Report enh                     |
REM | 29-Mar-05   ankgoel   Bug#4257022 - Increased the length of constants |
REM | 05-APR-05   adrao     Bug#4284875 - Modified constant C_WHERE_CLAUSE  |
REM | 05-APR-05   ppandey   Bug#4305437 - C_WHERE_CLAUSE to use TO_CHAR(ID) |
REM |  18-Jul-2005 ppandey  Enh #4417483, Restrict Internal/Calendar Dims   |
REM | 27-Sep-05   ankgoel   Bug#4625598,4626579 Uptake common API to get dim|
REM |                       level values                                    |
REM | 06-Jan-06   akoduri   Enh#4739401 - Hide Dimensions/Dim Objects       |
REM | 31-JAN-06   adrao     Added API Get_Unique_Level_Pk_Col for           |
REM |                       Bug#4758995                                     |
REM | 10-FEB-06   akoduri   Bug#4997042 Cascade 'All' property from dim     |
REM |                       designer to dim groups of Reports               |
REM +=======================================================================+
*/
DIM_OBJ_CODE_MAX_SIZE       CONSTANT NUMBER := 999;
DIM_OBJ_CODE_MIN_SIZE       CONSTANT NUMBER := 5;
DIM_OBJ_CODE_DEFAULT_SIZE   CONSTANT NUMBER := 5;

DIM_OBJ_NAME_MAX_SIZE       CONSTANT NUMBER := 999;
DIM_OBJ_NAME_MIN_SIZE       CONSTANT NUMBER := 5;
DIM_OBJ_NAME_DEFAULT_SIZE   CONSTANT NUMBER := 15;

c_BSC_DIM_OBJ               CONSTANT VARCHAR(12) := 'BSC_DIM_OBJ_';

-- Added for ZERO Code issue in Dim Obj Views Bug#3739872
DIM_OBJ_VIEW_ZCODE          CONSTANT NUMBER := 0;
DIM_OBJ_VIEW_ZCODE_ALIAS    CONSTANT NUMBER := -99999999;

C_SELECT                    CONSTANT VARCHAR2(8) := ' SELECT ';
C_WHERE                     CONSTANT VARCHAR2(7) := ' WHERE ';
C_FROM                      CONSTANT VARCHAR2(6) := ' FROM ';

C_SELECT_CLAUSE             CONSTANT VARCHAR2(30) := ' ID, VALUE ';
C_SELECT_PARENT_CLAUSE      CONSTANT VARCHAR2(30) := ' ID, VALUE, PARENT_ID ';

C_WHERE_CLAUSE              CONSTANT VARCHAR2(40) := ' TO_CHAR(ID) = ''0'' AND ROWNUM < 2 ';

C_ORA_ERR_TAB_NOT_EXIST     CONSTANT NUMBER := -942;
C_ORA_ERR_COL_NOT_EXIST     CONSTANT NUMBER := -904;
C_ORA_ERR_COL_NOT_EXIST1    CONSTANT NUMBER := -6553;
C_ORA_ERR_NO_DATA_FOUND     CONSTANT NUMBER := 100;

C_SUCCESS_NO_ERROR          CONSTANT NUMBER := 0;
C_TABLE_NOT_EXIST           CONSTANT NUMBER := 1;
C_COLUMN_NOT_EXIST          CONSTANT NUMBER := 2;
C_UNKNOWN_ERROR             CONSTANT NUMBER := -1;

-- record type for BSC_SYS_DIM_LEVEL_COLS table
TYPE Proj_Dim_Cols_Rec_Type IS Record
(       Dim_level_id        BSC_SYS_DIM_LEVEL_COLS.dim_level_id%TYPE
    ,   Column_Name         BSC_SYS_DIM_LEVEL_COLS.column_name%TYPE
    ,   Column_Type         BSC_SYS_DIM_LEVEL_COLS.column_type%TYPE
);

TYPE Proj_Dim_Cols_Tbl_Type IS TABLE OF Proj_Dim_Cols_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Acct_Type_Rec_Type IS Record
(       Code        NUMBER
    ,   Name        VARCHAR2(15)
);

TYPE Acct_Type_Tbl_Type IS TABLE OF Acct_Type_Rec_Type INDEX BY BINARY_INTEGER;

Type Acct_Rec_Type IS Record
(       Code        NUMBER
    ,   Name        VARCHAR2(15)
    ,   Acct_Type   NUMBER(5)
    ,   Position    NUMBER(2)
);

TYPE Acct_Tbl_Type IS TABLE OF Acct_Rec_Type INDEX BY BINARY_INTEGER;

/*********************************************************************************
                            CREATE DIMENSION-LEVEL
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
    ,   p_Master_Level              IN          VARCHAR2   :=  NULL
    ,   p_Long_Lov                  IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   p_Search_Function           IN          VARCHAR2   :=  NULL
    ,   p_Dim_Obj_Enabled           IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   p_View_Object_Name          IN          VARCHAR2   :=  NULL
    ,   p_Default_Values_Api        IN          VARCHAR2   :=  NULL
    ,   p_All_Enabled               IN          NUMBER     :=  NULL
    ,   p_Drill_To_Form_Function    IN          VARCHAR2   :=  NULL
    ,   x_return_status             OUT NOCOPY  VARCHAR2
    ,   x_msg_count                 OUT NOCOPY  NUMBER
    ,   x_msg_data                  OUT NOCOPY  VARCHAR2
);

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
    ,   p_Master_Level              IN          VARCHAR2   :=  NULL
    ,   p_Long_Lov                  IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   p_Search_Function           IN          VARCHAR2   :=  NULL
    ,   p_Dim_Obj_Enabled           IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   p_View_Object_Name          IN          VARCHAR2   :=  NULL
    ,   p_Default_Values_Api        IN          VARCHAR2   :=  NULL
    ,   p_All_Enabled               IN          NUMBER     :=  NULL
    ,   p_is_default_short_name     IN          VARCHAR2
    ,   p_Drill_To_Form_Function    IN          VARCHAR2   :=  NULL
    ,   p_Restrict_Dim_Validate     IN          VARCHAR2   := NULL
    ,   x_return_status             OUT NOCOPY  VARCHAR2
    ,   x_msg_count                 OUT NOCOPY  NUMBER
    ,   x_msg_data                  OUT NOCOPY  VARCHAR2
);

PROCEDURE Create_Dim_Object
(       p_commit                    IN          VARCHAR2   := FND_API.G_FALSE
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
    ,   p_Master_Level              IN          VARCHAR2   :=  NULL
    ,   p_Long_Lov                  IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   p_Search_Function           IN          VARCHAR2   :=  NULL
    ,   p_Dim_Obj_Enabled           IN          VARCHAR2   :=  FND_API.G_FALSE
    ,   p_View_Object_Name          IN          VARCHAR2   :=  NULL
    ,   p_Default_Values_Api        IN          VARCHAR2   :=  NULL
    ,   p_All_Enabled               IN          NUMBER     :=  NULL
    ,   p_is_default_short_name     IN          VARCHAR2
    ,   p_Drill_To_Form_Function    IN          VARCHAR2   :=  NULL
    ,   p_Prototype_Values          IN          BIS_STRING_ARRAY
    ,   p_Force_Dimension_Create    IN          VARCHAR2
    ,   p_Restrict_Dim_Validate     IN          VARCHAR2   := NULL
    ,   x_return_status             OUT NOCOPY  VARCHAR2
    ,   x_msg_count                 OUT NOCOPY  NUMBER
    ,   x_msg_data                  OUT NOCOPY  VARCHAR2
);

/*********************************************************************************
                          UPDATE DIMENSION-LEVEL
*********************************************************************************/
PROCEDURE Update_Dim_Object
(       p_commit                    IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_short_name        IN          VARCHAR2
    ,   p_display_name              IN          VARCHAR2
    ,   p_application_id            IN          NUMBER
    ,   p_description               IN          VARCHAR2
    ,   p_data_source               IN          VARCHAR2
    ,   p_source_table              IN          VARCHAR2
    ,   p_where_clause              IN          VARCHAR2   :=   NULL
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
);

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
    ,   p_where_clause              IN          VARCHAR2   :=   NULL
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
    ,   p_time_stamp                IN          VARCHAR2   :=  NULL    -- Granular Locking
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
);

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
    ,   p_assign_dim_short_names    IN          VARCHAR2
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
);
/*********************************************************************************
                           DELETE DIMENSION-LEVEL
*********************************************************************************/
PROCEDURE Delete_Dim_Object
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_short_name    IN              VARCHAR2
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);
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
);
/*********************************************************************************
                    ASSIGN & UNASSIGN DIMENSIONS TO DIMENSION OBJECT
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
);
/*********************************************************************************
                       UNASSIGN DIMENSIONS FROM DIMENSION OBJECT
*********************************************************************************/
PROCEDURE Unassign_Dimensions
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_short_name    IN              VARCHAR2
    ,   p_dim_short_names       IN              VARCHAR2
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);

PROCEDURE validateBscDimensionToDelete
(       p_commit                IN              VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_short_name    IN              VARCHAR2
    ,   x_return_status         OUT     NOCOPY  VARCHAR2
    ,   x_msg_count             OUT     NOCOPY  NUMBER
    ,   x_msg_data              OUT     NOCOPY  VARCHAR2
);

FUNCTION get_Dimensions
(
    p_group_id  IN  NUMBER

)RETURN VARCHAR2;

FUNCTION get_Dimension_Objects
(
   p_dim_short_name  IN  VARCHAR2
) RETURN VARCHAR2;


FUNCTION get_bis_dimension_id
(
   p_dim_short_name  IN  VARCHAR2
) RETURN NUMBER;


/*******************************************************************************
                   FUNCTION TO INTIALIZE PMF DIMENSION RECORDS
********************************************************************************/
FUNCTION Initialize_Pmf_Recs
(       p_Dim_Level_Rec     IN  OUT   NOCOPY    BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT   NOCOPY    VARCHAR2
    ,   x_msg_count             OUT   NOCOPY    NUMBER
    ,   x_msg_data              OUT   NOCOPY    VARCHAR2
)
RETURN BOOLEAN;

/*******************************************************************************/
FUNCTION is_KPI_Flag_For_DimObject
(       p_dim_obj_short_name        IN          VARCHAR2
    ,   p_Source                    IN          VARCHAR2
    ,   p_source_table              IN          VARCHAR2
    ,   p_table_column              IN          VARCHAR2
    ,   p_prototype_default_value   IN          VARCHAR2
    ,   p_maximum_code_size         IN          NUMBER
    ,   p_maximum_name_size         IN          NUMBER
    ,   p_dim_short_names           IN          VARCHAR2
) RETURN VARCHAR2;
--*********** Checking configuration impacting adding dimension objects*****************
FUNCTION is_config_impact_dim_obj
(       p_Dim_Obj_Short_Name        IN          VARCHAR2
    ,   p_Dim_Short_Names           IN          VARCHAR2
) RETURN VARCHAR2;
/*******************************************************************************
********************************************************************************/
FUNCTION Get_Dim_Obj_Source
(   p_dim_obj_id IN NUMBER   := NULL
  , p_short_Name IN VARCHAR2 := NULL
) RETURN VARCHAR2;
/*********************************************************************************************
                         Returns the Dimension Object ID of BIS
*********************************************************************************************/
FUNCTION Get_Bis_Dim_Obj_ID
(  p_Short_Name  IN BIS_LEVELS.Short_Name%TYPE
) RETURN NUMBER;

/*********************************************************************************************
                         Returns the Dimension Object ID of BSC
*********************************************************************************************/
FUNCTION Get_Bsc_Dim_Obj_ID
(  p_Short_Name  IN BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE
) RETURN NUMBER;
/********************************************************************
      Check no of independent dimension objects in dimension set
*********************************************************************/

PROCEDURE check_indp_dimobjs
(
        p_dim_id                IN    NUMBER
    ,   x_return_status         OUT   NOCOPY    VARCHAR2
    ,   x_msg_count             OUT   NOCOPY    NUMBER
    ,   x_msg_data              OUT   NOCOPY    VARCHAR2
) ;
/*********************************************************************************************
                         Refresh BSC-PMF Dimension Object View of BSC
*********************************************************************************************/
PROCEDURE Refresh_BSC_PMF_Dim_View
(       p_Short_Name          IN             VARCHAR2
    ,   x_return_status       OUT NOCOPY     VARCHAR2
    ,   x_msg_count           OUT NOCOPY     NUMBER
    ,   x_msg_data            OUT NOCOPY     VARCHAR2
);

PROCEDURE Remove_BSC_PMF_EDW_Dim_View
(       x_return_status       OUT NOCOPY     VARCHAR2
    ,   x_msg_count           OUT NOCOPY     NUMBER
    ,   x_msg_data            OUT NOCOPY     VARCHAR2
);

PROCEDURE Init_Create_Pmf_Recs
(       p_Dim_Level_Rec     IN  OUT   NOCOPY    BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status         OUT   NOCOPY    VARCHAR2
    ,   x_msg_count             OUT   NOCOPY    NUMBER
    ,   x_msg_data              OUT   NOCOPY    VARCHAR2
);

FUNCTION Validate_PMF_Base_View (
             p_View_Name        IN VARCHAR2
           , p_Parent_Id_Exists IN VARCHAR2
           , p_Parent_Column    IN VARCHAR2
) RETURN NUMBER;


PROCEDURE Validate_PMF_Views
( p_Dim_Obj_Short_Name            IN  VARCHAR2
, p_Dim_Obj_View_Name             IN  VARCHAR2
, x_Return_Status                 OUT NOCOPY VARCHAR2
, x_Msg_Count                     OUT NOCOPY NUMBER
, x_Msg_Data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_Dim_object_Views
( p_Dim_Obj_Short_Name            IN  VARCHAR2
, p_Dim_Obj_View_Name             IN  VARCHAR2
, x_Return_Status                 OUT NOCOPY VARCHAR2
, x_Msg_Count                     OUT NOCOPY NUMBER
, x_Msg_Data                      OUT NOCOPY VARCHAR2
);

FUNCTION Get_Table_Type_Value(
             p_Short_Name IN BSC_SYS_DIM_LEVELS_B.Short_Name%TYPE
) RETURN NUMBER;

FUNCTION Is_Default_Value(
        p_value IN VARCHAR2
) RETURN BOOLEAN;

/******************************************************************************/
-- Added for Bug#4758995
-- This needs to be public because it could be used in a script.
FUNCTION Get_Unique_Level_Pk_Col
(       p_Dim_Level_Rec  IN  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
    ,   x_return_status  OUT NOCOPY   VARCHAR2
    ,   x_msg_count      OUT NOCOPY   NUMBER
    ,   x_msg_data       OUT NOCOPY   VARCHAR2
) RETURN VARCHAR2;
/******************************************************************************/


PROCEDURE Validate_Refresh_BSC_PMF_Views
( p_Dim_Obj_Short_Name            IN  VARCHAR2
, x_Return_Status                 OUT NOCOPY VARCHAR2
, x_Msg_Count                     OUT NOCOPY NUMBER
, x_Msg_Data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Cascade_Dim_Props_Into_Dim_Grp (
  p_Dim_Obj_Short_Name              IN  VARCHAR2
  , p_Dim_Short_Name                IN  VARCHAR2
  , p_All_Flag                      IN  NUMBER
  , x_Return_Status                 OUT NOCOPY VARCHAR2
  , x_Msg_Count                     OUT NOCOPY NUMBER
  , x_Msg_Data                      OUT NOCOPY VARCHAR2
);

END BSC_BIS_DIM_OBJ_PUB;

 

/
