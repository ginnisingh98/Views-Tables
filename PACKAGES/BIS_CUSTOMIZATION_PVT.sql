--------------------------------------------------------
--  DDL for Package BIS_CUSTOMIZATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_CUSTOMIZATION_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVCTMS.pls 120.1 2006/02/14 13:16:33 hengliu noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile(115.1=120.1):~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVCTMS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for shipping ak customizations at function level      |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 27-Apr-2005 kyadamak Creation                                         |
REM | 14-Feb-2005 hengliu  Add Delete_Custom_Region_Items                   |
REM +=======================================================================+
*/
--
--
PROCEDURE Create_Custom_Region_Items
( p_api_version              IN  NUMBER
, p_commit                   IN  VARCHAR2  := FND_API.G_FALSE
, p_Custom_region_items_Rec  IN  BIS_CUSTOMIZATION_PUB.custom_region_items_type
, x_return_status            OUT NOCOPY  VARCHAR2
, x_msg_count                OUT NOCOPY  NUMBER
, x_msg_data                 OUT NOCOPY  VARCHAR2
);
--
--
-- updates rows into ak_custom_region_items and tl tables
--
PROCEDURE Update_Custom_Region_Items
( p_api_version              IN  NUMBER
, p_commit                   IN  VARCHAR2  := FND_API.G_FALSE
, p_Custom_region_items_Rec  IN  BIS_CUSTOMIZATION_PUB.custom_region_items_type
, x_return_status           OUT NOCOPY  VARCHAR2
, x_msg_count               OUT NOCOPY  NUMBER
, x_msg_data                OUT NOCOPY  VARCHAR2
);
--
-- delete row in ak_custom_region_items and tl tables
--
PROCEDURE Delete_Custom_Region_Items
( p_api_version              IN   NUMBER
, p_commit                   IN   VARCHAR2 := FND_API.G_FALSE
, p_Custom_region_items_Rec  IN   BIS_CUSTOMIZATION_PUB.custom_region_items_type
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
);
--
PROCEDURE Update_Customizations
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_Customizations_Rec  IN  BIS_CUSTOMIZATION_PUB.customizations_type
, x_return_status       OUT NOCOPY  VARCHAR2
, x_msg_count           OUT NOCOPY  NUMBER
, x_msg_data            OUT NOCOPY  VARCHAR2
);
--
--
-- creates rows into ak_custom_regions and tl tables
--
PROCEDURE Create_Customizations
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_Customizations_Rec  IN  BIS_CUSTOMIZATION_PUB.customizations_type
, x_return_status       OUT NOCOPY  VARCHAR2
, x_msg_count           OUT NOCOPY  NUMBER
, x_msg_data            OUT NOCOPY  VARCHAR2
);



END BIS_CUSTOMIZATION_PVT;

 

/
