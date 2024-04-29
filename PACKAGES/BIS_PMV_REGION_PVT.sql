--------------------------------------------------------
--  DDL for Package BIS_PMV_REGION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_REGION_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVREPS.pls 120.0 2005/06/01 17:31:57 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVREPS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Private API for Region                                    |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 02/03/04 nbarik   Created.                                            |
REM +=======================================================================+
*/

PROCEDURE CREATE_REGION
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_Report_Region_Rec     IN          BIS_AK_REGION_PUB.Bis_Region_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);

PROCEDURE UPDATE_REGION
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_Report_Region_Rec     IN          BIS_AK_REGION_PUB.Bis_Region_Rec_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);

PROCEDURE DELETE_REGION
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_Region_Code           IN          VARCHAR2
    ,   p_Region_Application_Id IN          NUMBER
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);

END BIS_PMV_REGION_PVT;

 

/
