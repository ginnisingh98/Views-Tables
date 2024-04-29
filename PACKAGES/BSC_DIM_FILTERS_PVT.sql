--------------------------------------------------------
--  DDL for Package BSC_DIM_FILTERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DIM_FILTERS_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCVFDLS.pls 120.2 2007/02/23 10:42:21 psomesul ship $ */
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
REM | 16-12-2006 PSOMESUL E#5678943 MIGRATE COMMON DIMENSIONS AND DIMENSION FILTERS TO SCORECARD DESIGNER|
REM +=======================================================================+
*/


FUNCTION get_Filter_View_Name
(       p_Tab_Id          NUMBER
    ,   p_Dim_Level_Id    NUMBER
) RETURN VARCHAR2;

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

/*-------------------------------------------------------------------------------------------------------------------
   Drop_Filter   :
      Delete a Filter View a and make cascading delete for child dimension Filter views
-------------------------------------------------------------------------------------------------------------------*/
PROCEDURE  Drop_Filter_objects
(       p_Tab_Id            IN      NUMBER
    ,   p_Dim_Level_Id      IN      NUMBER
    ,   x_return_status     OUT NOCOPY     VARCHAR2
    ,   x_msg_count         OUT NOCOPY     NUMBER
    ,   x_msg_data          OUT NOCOPY     VARCHAR2
);

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


END BSC_DIM_FILTERS_PVT;


/
