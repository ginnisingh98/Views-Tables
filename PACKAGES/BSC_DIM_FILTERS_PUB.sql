--------------------------------------------------------
--  DDL for Package BSC_DIM_FILTERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DIM_FILTERS_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPFDLS.pls 120.3 2007/02/23 10:41:52 psomesul ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BSCCPMDB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: This Package Filtering Dimension object at tab level      |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 16-MAR-2004 WCANO    Created.                                         |
REM | 12-APR-2004 PAJOHRI  Bug #3426566, added a new function               |
REM |                      Get_Filter_View_Name                             |
REM | 16-12-2006 PSOMESUL E#5678943 MIGRATE COMMON DIMENSIONS AND DIMENSION FILTERS TO SCORECARD DESIGNER|
REM +=======================================================================+
*/

SOURCE_TYPE_TAB      NUMBER := 1;    -- Scorecard SOURCE TYPE
SOURCE_TYPE_SYSTEM   NUMBER := 0;    -- System SOURCE TYPE


/*-------------------------------------------------------------------------------------------------------------------
   Check_Filters_Not_Apply
   This procedure will check for filters that not apply any more to the tabs
   It will made one of the next options:
     1. Check for a all the dimension filters in a specific tab when  p_Dim_Level_Id is null and p_Tab_Id is not null
     2. Check for a all the dimension filters in all the  tab when  p_Dim_Level_Id is null and p_Tab_Id is null
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE  Check_Filters_Not_Apply
(       p_Tab_Id            IN     NUMBER   := NULL
    ,   x_return_status     OUT NOCOPY    VARCHAR2
    ,   x_msg_count         OUT NOCOPY    NUMBER
    ,   x_msg_data          OUT NOCOPY    VARCHAR2
);

PROCEDURE Check_Filters_Not_Apply_By_KPI
(       p_Kpi_Id                IN              BSC_KPIS_B.Indicator%TYPE
    ,   x_return_status         OUT    NOCOPY   VARCHAR2
    ,   x_msg_count             OUT    NOCOPY   NUMBER
    ,   x_msg_data              OUT    NOCOPY   VARCHAR2
);

/*-------------------------------------------------------------------------------------------------------------------
   Drop_Filter   :
      Delete a Filter View a and make cascading delete for child dimension Filter views
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE  Drop_Filter
(       p_Tab_Id            IN      NUMBER
    ,   p_Dim_Level_Id      IN      NUMBER
    ,   x_return_status     OUT NOCOPY     VARCHAR2
    ,   x_msg_count         OUT NOCOPY     NUMBER
    ,   x_msg_data          OUT NOCOPY     VARCHAR2
);

PROCEDURE Synch_Fiters_And_Kpi_Dim
(       p_Tab_Id            IN      NUMBER
    ,   x_return_status     OUT NOCOPY     VARCHAR2
    ,   x_msg_count         OUT NOCOPY     NUMBER
    ,   x_msg_data          OUT NOCOPY     VARCHAR2
);

PROCEDURE Drop_Filter_By_Dim_Obj
(       p_Dim_Level_Id      IN      NUMBER
    ,   x_return_status     OUT NOCOPY     VARCHAR2
    ,   x_msg_count         OUT NOCOPY     NUMBER
    ,   x_msg_data          OUT NOCOPY     VARCHAR2
);

PROCEDURE Drop_Filter_By_Tab
(       p_Tab_Id            IN      NUMBER
    ,   x_return_status     OUT NOCOPY     VARCHAR2
    ,   x_msg_count         OUT NOCOPY     NUMBER
    ,   x_msg_data          OUT NOCOPY     VARCHAR2
);

FUNCTION Get_Filter_View_Name
(   p_Kpi_Id        IN  BSC_KPIS_B.Indicator%TYPE
  , p_Dim_Level_Id  IN  BSC_SYS_DIM_LEVELS_B.Dim_Level_Id%TYPE
) RETURN VARCHAR2;



END BSC_DIM_FILTERS_PUB;

/
