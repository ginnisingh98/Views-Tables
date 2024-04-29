--------------------------------------------------------
--  DDL for Package Body BIS_PMF_GET_DIMLEVELS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMF_GET_DIMLEVELS_PUB" AS
/* $Header: BISPGDLB.pls 115.10 2003/04/02 11:28:32 smuruges ship $ */
/*
REM dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
REM dbdrv: checkfile:~PROD:~PATH:~FILE
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVGDLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public  API for getting the Select String for DimensionLevelValues|
REM |     This API will get the Select String from either EDW or BIS        |
REM |     depending on the profile option BIS_SOURCE                        |
REM |                                                                       |
REM | HISTORY                                                               |
REM | December-2000 amkulkar Creation                                       |
REM +=======================================================================+
*/
--
PROCEDURE GET_DIMLEVEL_SELECT_STRING
(
 p_DimLevelShortName         IN     VARCHAR2
,p_bis_source                IN     VARCHAR2
,x_Select_String             OUT NOCOPY    VARCHAR2
,x_table_name                OUT NOCOPY    VARCHAR2
,x_id_name                   OUT NOCOPY    VARCHAR2
,x_value_name                OUT NOCOPY    VARCHAR2
,x_return_status             OUT NOCOPY    VARCHAR2
,x_msg_count                 OUT NOCOPY    NUMBER
,x_msg_data                  OUT NOCOPY    VARCHAR2
)
IS
   l_time_level             VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.initialize;
  BIS_PMF_GET_DIMLEVELS_PVT.GET_DIMLEVEL_SELECT_STRING(
          p_DimLevelName  => p_DimLevelShortName
         ,p_bis_source    => p_bis_source
         ,x_Select_String => x_Select_String
         ,x_table_name    => x_table_name
         ,x_id_name       => x_id_name
         ,x_value_name    => x_value_name
         ,x_time_level    => l_time_level
         ,x_return_Status => x_return_Status
         ,x_msg_count     => x_msg_count
         ,x_msg_data      => x_msg_data
        );
END GET_DIMLEVEL_SELECT_STRING;
--
PROCEDURE GET_SORTED_SELECT_STRING
(
 p_DimLevelShortName         IN     VARCHAR2
,p_bis_source                IN     VARCHAR2
,x_Select_String             OUT NOCOPY    VARCHAR2
,x_table_name                OUT NOCOPY    VARCHAR2
,x_id_name                   OUT NOCOPY    VARCHAR2
,x_value_name                OUT NOCOPY    VARCHAR2
,x_return_status             OUT NOCOPY    VARCHAR2
,x_msg_count                 OUT NOCOPY    NUMBER
,x_msg_data                  OUT NOCOPY    VARCHAR2
)
IS
   l_time_level      varchar2(2000);
   l_order_by        varchar2(32000);
BEGIN
  FND_MSG_PUB.initialize;
  BIS_PMF_GET_DIMLEVELS_PVT.GET_DIMLEVEL_SELECT_STRING(
          p_DimLevelName  => p_DimLevelShortName
         ,p_bis_source    => p_bis_source
         ,x_Select_String => x_Select_String
         ,x_table_name    => x_table_name
         ,x_id_name       => x_id_name
         ,x_value_name    => x_value_name
         ,x_time_level    => l_time_level
         ,x_return_Status => x_return_Status
         ,x_msg_count     => x_msg_count
         ,x_msg_data      => x_msg_data
        );
   IF ((ltrim(rtrim(l_time_level))) = 'Y')
   THEN
      l_order_by := ' ORDER BY START_DATE';
   ELSE
      l_order_by := ' ORDER BY ' || x_id_name;
   END IF;
   x_select_string := x_select_string || l_order_by;

END GET_SORTED_SELECT_STRING;
END BIS_PMF_GET_DIMLEVELS_PUB;

/
