--------------------------------------------------------
--  DDL for Package BIS_CUSTOMIZATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_CUSTOMIZATIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPCUSS.pls 115.0 2002/12/16 11:12:39 nkishore noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
-- dbdrv: checkfile:~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPCUSS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for shipping ak customizations at function level       |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 16-Dec-02 nkishore Creation                                           |
REM +=======================================================================+
*/
--
-- PROCEDUREs
--
-- creates rows into ak_customizations and tl tables
--
PROCEDURE Create_Customizations
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Customizations_Rec      IN  BIS_CUSTOMIZATIONS_PVT.customizations_type
, x_return_status    OUT NOCOPY VARCHAR2
);
--
--
--
-- PLEASE VERIFY COMMENT BELOW
-- Update_Customizations and tl
--
--
PROCEDURE Update_Customizations
( p_api_version   IN  NUMBER
, p_commit        IN  VARCHAR2   := 'N'
, p_Customizations_Rec      IN  BIS_CUSTOMIZATIONS_PVT.customizations_type
, x_return_status OUT NOCOPY VARCHAR2
);
--
--
-- creates rows into ak_custom_regions and tl tables
--
PROCEDURE Create_Custom_regions
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_regions_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_regions_type
, x_return_status    OUT NOCOPY VARCHAR2
);
--
--
-- updates rows into ak_custom_regions and tl tables
--
PROCEDURE Update_Custom_regions
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_regions_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_regions_type
, x_return_status    OUT NOCOPY VARCHAR2
);
--
--
-- creates rows into ak_custom_region_items and tl tables
--
PROCEDURE Create_Custom_region_items
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_region_items_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_region_items_type
, x_return_status    OUT NOCOPY VARCHAR2
);
--
--
-- updates rows into ak_custom_region_items and tl tables
--
PROCEDURE Update_Custom_region_items
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_region_items_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_region_items_type
, x_return_status    OUT NOCOPY VARCHAR2
);
--
--

END BIS_CUSTOMIZATIONS_PUB;

 

/
