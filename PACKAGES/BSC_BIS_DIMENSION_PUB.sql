--------------------------------------------------------
--  DDL for Package BSC_BIS_DIMENSION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BIS_DIMENSION_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCGPMDS.pls 120.3 2006/01/06 03:22:23 akoduri noship $ */
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
REM | 13-SEP-2003 MAHRAO   Fix for bug# 3099977, Added p_create_view flag   |
REM | 04-NOV-2003 PAJOHRI  Bug #3152258                                     |
REM | 04-NOV-2003 PAJOHRI  Bug #3220613                                     |
REM | 04-NOV-2003 PAJOHRI  Bug #3232366                                     |
REM | 08-DEC-2003 KYADAMAK Bug #3225685                                     |
REM | 12-APR-2004 PAJOHRI  Bug #3426566, created the following new functions|
REM |                      Get_Bis_Dimension_ID()                           |
REM |                      Get_Bsc_Dimension_ID()                           |
REM | 09-AUG-2004 sawu     Added constant c_BSC_DIM                         |
REM | 11-AUG-2004 sawu     Added create_dimension() for bug#3819855 with    |
REM |                      p_is_default_short_name                          |
REM | 08-SEP-2004 visuri   Added Dim_With_Single_Dim_Obj() and              |
REM |                      Is_Dim_Empty() for bug #3784852                  |
REM | 09-SEP-2004 visuri   Shifted Remove_Empty_Dims_For_DimSet() from      |
REM |                      BSC_BIS_KPI_MEAS_PUB  for bug #3784852           |
REM | 27-OCT-2004 sawu     Bug#3947903: added Is_Objective_Assigned()       |
REM | 06-JUN-2005 mdamle   Enh#4403547 - Set default p_commit to false for  |
REM |                      dim. group apis called from EOs                  |
REM |  18-Jul-2005 ppandey  Enh #4417483, Restrict Internal/Calendar Dims   |
REM |  06-Jan-2006 akoduri  Enh#4739401 - Hide Dimensions/Dim Objects       |
REM +=======================================================================+
*/

UNASSIGNED_DIM              CONSTANT        VARCHAR2(10) := 'UNASSIGNED';
c_BSC_DIM                   CONSTANT        VARCHAR2(8) := 'BSC_DIM_';
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
);

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
);
/*********************************************************************************
                          ASSIGN DIMENSION OBJECTS TO DIMENSION
*********************************************************************************/

PROCEDURE Assign_Dimension_Objects
(       p_commit                IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name        IN              VARCHAR2
    ,   p_dim_obj_short_names   IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2    :=   NULL    -- Granular Locking
    ,   p_create_view           IN              NUMBER      :=   0
    ,   p_Restrict_Dim_Validate IN              VARCHAR2   := NULL
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);

/*********************************************************************************
                      ASSIGN OR UPDATE A DIMENSION OBJECT TO DIMENSION
*********************************************************************************/

PROCEDURE Assign_Dimension_Object
(       p_commit                IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name        IN              VARCHAR2
    ,   p_dim_obj_short_name    IN              VARCHAR2
    ,   p_comp_flag             IN              NUMBER
    ,   p_no_items              IN              NUMBER
    ,   p_parent_in_tot         IN              NUMBER
    ,   p_total_flag            IN              NUMBER
    ,   p_default_value         IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2    :=   NULL    -- Granular Locking
    ,   p_create_view           IN              NUMBER      :=   0
    ,   p_where_clause          IN              VARCHAR2    :=   NULL
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);

/*********************************************************************************
                    ASSIGN & UNASSIGN DIMENSION OBJECTS TO DIMENSION
*********************************************************************************/

PROCEDURE Assign_Unassign_Dim_Objs
(       p_commit                        IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name                IN              VARCHAR2
    ,   p_assign_dim_obj_names          IN              VARCHAR2
    ,   p_unassign_dim_obj_names        IN              VARCHAR2
    ,   p_time_stamp                    IN              VARCHAR2    :=   NULL    -- Granular Locking
    ,   p_Restrict_Dim_Validate         IN              VARCHAR2   := NULL
    ,   x_return_status                 OUT    NOCOPY   VARCHAR2
    ,   x_msg_count                     OUT    NOCOPY   NUMBER
    ,   x_msg_data                      OUT    NOCOPY   VARCHAR2
);

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
    ,   p_hide                  IN              VARCHAR2    := FND_API.G_FALSE
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);

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
);

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
);
/*********************************************************************************
                        DELETE DIMENSION
*********************************************************************************/
PROCEDURE Delete_Dimension
(       p_commit                IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name        IN              VARCHAR2
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);

/*********************************************************************************
                       UNASSIGN DIMENSION OBJECTS FROM DIMENSION
*********************************************************************************/
PROCEDURE Unassign_Dimension_Objects
(       p_commit                IN              VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
    ,   p_dim_short_name        IN              VARCHAR2
    ,   p_dim_obj_short_names   IN              VARCHAR2
    ,   p_time_stamp            IN              VARCHAR2    :=   NULL    -- Granular Locking
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);
/*********************************************************************************
                          GET DIMENSION SOURCE
*********************************************************************************/
FUNCTION Get_Dimension_Source
(
    p_short_Name IN VARCHAR2
) RETURN VARCHAR2;
--=============================================================================
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
);
--=============================================================================
PROCEDURE Get_Spec_Edw_Dtls
(       p_dim_lvl_shrt_name                 VARCHAR2
    ,   x_dim_lvl_view_name     OUT NOCOPY  VARCHAR2
    ,   x_dim_lvl_pk_key        OUT NOCOPY  VARCHAR2
    ,   x_dim_lvl_name_col      OUT NOCOPY  VARCHAR2
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);
--=============================================================================
PROCEDURE Get_Gene_Edw_Dtls
(       p_dim_lvl_shrt_name                     VARCHAR2
    ,   x_dim_lvl_view_name     IN OUT  NOCOPY  VARCHAR2
    ,   x_dim_lvl_pk_key        OUT     NOCOPY  VARCHAR2
    ,   x_dim_lvl_name_col      OUT     NOCOPY  VARCHAR2
    ,   x_return_status         OUT     NOCOPY  VARCHAR2
    ,   x_msg_count             OUT     NOCOPY  NUMBER
    ,   x_msg_data              OUT     NOCOPY  VARCHAR2
);
--=============================================================================
FUNCTION is_KPI_Flag_For_DimProp_Change
(       p_dim_short_name        IN          VARCHAR2
    ,   p_dim_Obj_Short_Name    IN          VARCHAR2
    ,   p_Default_Value         IN          VARCHAR2
) RETURN VARCHAR2;
--=============================================================================
FUNCTION is_KPI_Flag_For_Dimension
(       p_Dim_Short_Name        IN          VARCHAR2
    ,   p_Dim_Obj_Short_Names   IN          VARCHAR2
) RETURN VARCHAR2;
--*********** Checking configuration impacting adding dimension objects*****************
FUNCTION is_config_impact_dim
(       p_Dim_Short_Name        IN          VARCHAR2
     ,  p_Dim_Obj_Short_Names   IN          VARCHAR2
) RETURN VARCHAR2;
/*********************************************************************************************
                         Returns the Dim_Group_ID of BIS Dimension
*********************************************************************************************/
FUNCTION Get_Bis_Dimension_ID
(  p_Short_Name  IN BIS_DIMENSIONS.Short_Name%TYPE
) RETURN NUMBER;

/*********************************************************************************************
                            Returns the Dim_Group_ID of BSC Dimension
*********************************************************************************************/
FUNCTION Get_Bsc_Dimension_ID
(  p_Short_Name  IN BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE
) RETURN NUMBER;

/*********************************************************************************************
                            Returns the Name of BSC Dimension
*********************************************************************************************/
FUNCTION Get_Bsc_Dimension_Name
(  p_Short_Name  IN BSC_SYS_DIM_GROUPS_TL.Short_Name%TYPE
) RETURN VARCHAR2;
/*********************************************************************************************
                            Checks if a Dimension is Attached to a Objective
*********************************************************************************************/
FUNCTION Is_Dimension_in_Ind
(  p_dim_group_id  IN BSC_SYS_DIM_GROUPS_TL.Dim_Group_ID%TYPE
) RETURN BOOLEAN;

/**************************************************************************************************************
   API TO Check if the Dimension/Dimensions is Empty
****************************************************************************************************************/
FUNCTION Is_Dim_Empty
(
 p_dim_short_names IN VARCHAR

) RETURN VARCHAR2 ;
/**************************************************************************************************************
   API TO Check if the Dimension/Dimensions has Single Dimension Object
****************************************************************************************************************/
FUNCTION Dim_With_Single_Dim_Obj
(
 p_dim_short_names IN VARCHAR

) RETURN VARCHAR2 ;
/*********************************************************************************
         API TO REMOVE EMPTY DIMENSION FROM DIMENSION SET
*********************************************************************************/
PROCEDURE Remove_Empty_Dims_For_DimSet
(   p_commit           IN             VARCHAR2   := FND_API.G_FALSE -- mdamle 06/06/2005 - Set default p_commit to false for dim. group apis called from EO
  , p_dim_short_names  IN             VARCHAR2
  , p_time_stamp       IN             VARCHAR2   := NULL  -- Granular Locking
  , x_return_status         OUT    NOCOPY   VARCHAR2
  , x_msg_count             OUT    NOCOPY   NUMBER
  , x_msg_data              OUT    NOCOPY   VARCHAR2
);

/*********************************************************************************
         API TO Check if Dimension is Assigned to any KPI
*********************************************************************************/
FUNCTION Is_Objective_Assigned
(
   p_dim_short_name     IN      VARCHAR2
) RETURN VARCHAR2;


END BSC_BIS_DIMENSION_PUB;

 

/
