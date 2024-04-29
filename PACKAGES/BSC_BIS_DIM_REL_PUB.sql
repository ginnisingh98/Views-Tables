--------------------------------------------------------
--  DDL for Package BSC_BIS_DIM_REL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BIS_DIM_REL_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCRPMDS.pls 120.1 2007/02/08 10:14:25 psomesul ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCRPMDS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Wrapper for Dimension-Relationships, part of PMD APIs     |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 14-FEB-2003 PAJOHRI  Created.                                         |
REM | 04-NOV-2003 PAJOHRI  Bug #3152258                                     |
REM | 08-DEC-2003 KYADAMAK Bug #3225685                                     |
REM | 05-NOV-2004 ashankar bug #3459282                                     |
REM | 16-12-2006 PSOMESUL E#5678943 MIGRATE COMMON DIMENSIONS AND DIMENSION FILTERS TO SCORECARD DESIGNER|
REM +=======================================================================+
*/
/*********************************************************************************
                       ASSIGN DIMENSION-OBJECTS RELATIONSHIP
*********************************************************************************/
l_Child_Dim_Obj_Count       NUMBER:=0;
l_child_dim_objs            VARCHAR2(2000);

C_SELECT                    CONSTANT VARCHAR2(10) := ' SELECT ';
C_WHERE                     CONSTANT VARCHAR2(10) := ' WHERE ';
C_FROM                      CONSTANT VARCHAR2(10) := ' FROM ';

C_SELECT_CLAUSE             CONSTANT VARCHAR2(30) := ' CODE, USER_CODE ,NAME ';
C_WHERE_CLAUSE              CONSTANT VARCHAR2(20) := ' ROWNUM < 2 ';

PROCEDURE Assign_Dim_Obj_Rels
(
        p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_id            IN          NUMBER
    ,   p_parent_ids            IN          VARCHAR2
    ,   p_parent_rel_type       IN          VARCHAR2
    ,   p_parent_rel_column     IN          VARCHAR2
    ,   p_parent_data_type      IN          VARCHAR2
    ,   p_parent_data_source    IN          VARCHAR2
    ,   p_child_ids             IN          VARCHAR2
    ,   p_child_rel_type        IN          VARCHAR2
    ,   p_child_rel_column      IN          VARCHAR2
    ,   p_child_data_type       IN          VARCHAR2
    ,   p_child_data_source     IN          VARCHAR2
    ,   p_time_stamp            IN          VARCHAR2   := NULL   -- Granular Locking
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);
/*********************************************************************************
                       ASSIGN DIMENSION-OBJECTS RELATIONSHIPS
*********************************************************************************/
PROCEDURE Assign_New_Dim_Obj_Rels
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_id            IN          NUMBER
    ,   p_parent_ids            IN          VARCHAR2
    ,   p_parent_rel_type       IN          VARCHAR2
    ,   p_parent_rel_column     IN          VARCHAR2
    ,   p_parent_data_type      IN          VARCHAR2
    ,   p_parent_data_source    IN          VARCHAR2
    ,   p_child_ids             IN          VARCHAR2
    ,   p_child_rel_type        IN          VARCHAR2
    ,   p_child_rel_column      IN          VARCHAR2
    ,   p_child_data_type       IN          VARCHAR2
    ,   p_child_data_source     IN          VARCHAR2
    ,   p_time_stamp            IN          VARCHAR2   := NULL   -- Granular Locking
    ,   p_is_not_config         IN          BOOLEAN    := TRUE
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);
/*********************************************************************************
                      UNASSIGN DIMENSION-OBJECTS RELATIONSHIPS
*********************************************************************************/
PROCEDURE UnAssign_Dim_Obj_Rels
(
        p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_dim_obj_id            IN          NUMBER
    ,   p_parent_ids            IN          VARCHAR2
    ,   p_child_ids             IN          VARCHAR2
    ,   p_time_stamp            IN          VARCHAR2   := NULL   -- Granular Locking
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);

/*********************************************************************************
                            FUNCTION GET_PARENTS
*********************************************************************************/
FUNCTION get_parents
(
    p_dim_obj_id      IN      NUMBER
)
RETURN VARCHAR2;

/*********************************************************************************
                            FUNCTION GET_CHILDS
*********************************************************************************/
FUNCTION get_children
(
    p_dim_obj_id      IN      NUMBER
)
RETURN VARCHAR2;
/*********************************************************************************/
FUNCTION check_invalid_pmf_view_inrel
  (
          p_dim_obj_id            IN          NUMBER
      ,   p_parent_ids            IN          VARCHAR2
      ,   p_parent_rel_type       IN          VARCHAR2
      ,   p_parent_rel_column     IN          VARCHAR2
      ,   p_parent_data_type      IN          VARCHAR2
      ,   p_parent_data_source    IN          VARCHAR2
      ,   p_child_ids             IN          VARCHAR2
      ,   p_child_rel_type        IN          VARCHAR2
      ,   p_child_rel_column      IN          VARCHAR2
      ,   p_child_data_type       IN          VARCHAR2
      ,   p_child_data_source     IN          VARCHAR2
      ,   p_time_stamp            IN          VARCHAR2   := NULL   -- Granular Locking
  ) RETURN VARCHAR2;

/*********************************************************************************/
FUNCTION is_KPI_Flag_For_Dim_Obj_Rels
(       p_dim_obj_id            IN          NUMBER
    ,   p_parent_ids            IN          VARCHAR2
    ,   p_parent_rel_type       IN          VARCHAR2
    ,   p_child_ids             IN          VARCHAR2
    ,   p_child_rel_type        IN          VARCHAR2
) RETURN VARCHAR2;
/*********************************************************************************/
FUNCTION check_config_impact_rels
(
        p_dim_obj_id            IN          NUMBER
    ,   p_parent_ids            IN          VARCHAR2
    ,   p_parent_rel_type       IN          VARCHAR2
    ,   p_parent_rel_column     IN          VARCHAR2
    ,   p_parent_data_type      IN          VARCHAR2
    ,   p_parent_data_source    IN          VARCHAR2
    ,   p_child_ids             IN          VARCHAR2
    ,   p_child_rel_type        IN          VARCHAR2
    ,   p_child_rel_column      IN          VARCHAR2
    ,   p_child_data_type       IN          VARCHAR2
    ,   p_child_data_source     IN          VARCHAR2
    ,   p_time_stamp            IN          VARCHAR2   := NULL   -- Granular Locking

) RETURN VARCHAR2;


PROCEDURE Verify_Recreate_Filter_Views
(
       p_source            IN      NUMBER
    ,  p_level_view_name   IN      BSC_SYS_FILTERS_VIEWS.level_view_name%TYPE
    ,  p_dim_level_id      IN      BSC_SYS_FILTERS_VIEWS.dim_level_id%TYPE
    ,  x_return_status     OUT     NOCOPY  VARCHAR2
    ,  x_msg_count         OUT     NOCOPY  NUMBER
    ,  x_msg_data          OUT     NOCOPY  VARCHAR2
);

END BSC_BIS_DIM_REL_PUB;

/
