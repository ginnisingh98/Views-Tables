--------------------------------------------------------
--  DDL for Package BIS_PMV_REGION_ITEMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMV_REGION_ITEMS_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVRITS.pls 120.0 2005/06/01 17:39:32 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVRITS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Private API for Region Items                              |
REM |                                                                       |
REM | NOTES                                                                 |
REM | 02/03/04 nbarik   Created.                                            |
REM +=======================================================================+
*/

PROCEDURE CREATE_REGION_ITEMS
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_region_code           IN          VARCHAR2
    ,   p_region_application_id IN          NUMBER
    ,   p_Region_Item_Tbl       IN          BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);

PROCEDURE UPDATE_REGION_ITEMS
(       p_commit                IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_region_code           IN          VARCHAR2
    ,   p_region_application_id IN          NUMBER
    ,   p_Region_Item_Tbl       IN          BIS_AK_REGION_PUB.Bis_Region_Item_Tbl_Type
    ,   x_return_status         OUT NOCOPY  VARCHAR2
    ,   x_msg_count             OUT NOCOPY  NUMBER
    ,   x_msg_data              OUT NOCOPY  VARCHAR2
);

PROCEDURE DELETE_REGION_ITEMS
(       p_commit                      IN          VARCHAR2   := FND_API.G_TRUE
    ,   p_region_code                 IN          VARCHAR2
    ,   p_region_application_id       IN          NUMBER
    ,   p_Attribute_Code_Tbl          IN          BISVIEWER.t_char
    ,   p_Attribute_Appl_Id_Tbl       IN          BISVIEWER.t_num
    ,   x_return_status               OUT NOCOPY  VARCHAR2
    ,   x_msg_count                   OUT NOCOPY  NUMBER
    ,   x_msg_data                    OUT NOCOPY  VARCHAR2
);

END BIS_PMV_REGION_ITEMS_PVT;

 

/
