--------------------------------------------------------
--  DDL for Package Body BIS_CUSTOMIZATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_CUSTOMIZATIONS_PUB" AS
/* $Header: BISPCUSB.pls 115.0 2002/12/16 11:13:10 nkishore noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile:~PROD:~PATH:~FILE

/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPCUSB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for creating ak Customization Data at function level   |
REM |                                                                       |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 16-Dec-02 nkishore Creation                                           |
REM |                                            			    |
REM +=======================================================================+
*/
--

-- creates rows in ak_customizations/tl
--
PROCEDURE Create_Customizations
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Customizations_Rec      IN  BIS_CUSTOMIZATIONS_PVT.customizations_type
, x_return_status    OUT NOCOPY VARCHAR2
)
IS

BEGIN
  BIS_CUSTOMIZATIONS_PVT.Create_Customizations
( p_api_version=>p_api_version
, p_commit     =>p_commit
, p_Customizations_Rec =>p_Customizations_Rec
, x_return_status => x_return_status
);

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Create_Customizations;
--
--

PROCEDURE Update_Customizations
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Customizations_Rec      IN  BIS_CUSTOMIZATIONS_PVT.customizations_type
, x_return_status    OUT NOCOPY VARCHAR2
)

IS
BEGIN

BIS_CUSTOMIZATIONS_PVT.Update_Customizations
( p_api_version=>p_api_version
, p_commit     =>p_commit
, p_Customizations_Rec =>p_Customizations_Rec
, x_return_status => x_return_status
);
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Update_Customizations;

PROCEDURE Create_Custom_Regions
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_Regions_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_regions_type
, x_return_status    OUT NOCOPY VARCHAR2
)

IS
BEGIN
BIS_CUSTOMIZATIONS_PVT.Create_Custom_Regions
( p_api_version=>p_api_version
, p_commit     =>p_commit
, p_Custom_Regions_Rec =>p_Custom_Regions_Rec
, x_return_status => x_return_status
);

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Create_Custom_Regions;
--
--
PROCEDURE Update_Custom_Regions
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_Regions_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_regions_type
, x_return_status    OUT NOCOPY VARCHAR2
)

IS
BEGIN

BIS_CUSTOMIZATIONS_PVT.Update_Custom_Regions
( p_api_version=>p_api_version
, p_commit     =>p_commit
, p_Custom_Regions_Rec =>p_Custom_Regions_Rec
, x_return_status => x_return_status
);
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Update_Custom_Regions;

PROCEDURE Create_Custom_Region_Items
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_Region_Items_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_region_items_type
, x_return_status    OUT NOCOPY VARCHAR2
)

IS
BEGIN
BIS_CUSTOMIZATIONS_PVT.Create_Custom_Region_Items
( p_api_version=>p_api_version
, p_commit     =>p_commit
, p_Custom_Region_Items_Rec =>p_Custom_Region_Items_Rec
, x_return_status => x_return_status
);


EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Create_Custom_Region_Items;
--
--
PROCEDURE Update_Custom_Region_Items
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := 'N'
, p_Custom_Region_Items_Rec      IN  BIS_CUSTOMIZATIONS_PVT.custom_Region_Items_type
, x_return_status    OUT NOCOPY VARCHAR2
)

IS
BEGIN

BIS_CUSTOMIZATIONS_PVT.Update_Custom_Region_Items
( p_api_version=>p_api_version
, p_commit     =>p_commit
, p_Custom_Region_Items_Rec =>p_Custom_Region_Items_Rec
, x_return_status => x_return_status
);
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Update_Custom_Region_items;


END BIS_CUSTOMIZATIONS_PUB;

/
