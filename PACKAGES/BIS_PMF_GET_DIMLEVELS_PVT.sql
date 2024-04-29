--------------------------------------------------------
--  DDL for Package BIS_PMF_GET_DIMLEVELS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMF_GET_DIMLEVELS_PVT" AUTHID CURRENT_USER AS
/* $Header: BISVGDLS.pls 120.5 2007/04/02 10:17:00 ashankar ship $ */
/*
REM dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
REM dbdrv: checkfile:~PROD:~PATH:~FILE
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVGDLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for getting the Select String for DimensionLevelValues|
REM |     This API will get the Select String from either EDW or BIS
REM |     depending on the profile option BIS_SOURCE
REM |                                                                       |
REM | HISTORY                                                               |
REM | December-2000 amkulkar Creation                                       |
REM | 09-OCT-2002 MAHRAO Fix for 2617369                                    |
REM | 03-JAN-2003 RCHANDRA Bug 2721710, created record                      |
REM |                       dim_level_select_rec_Type to hold dim level     |
REM |                       info from API GET_DIMLEVEL_SELECT_STRING        |
REM | 09-MAY-2003   arhegde  Added record and table types for child and     |
REM |                         parent dim level info , enh 2819971
REM | 25-JAN-2004 gbhaloti bug#3388371 add support to get select string for |
REM |                      BSC dimension levels                             |
REM | 11-FEB-2004 ankgoel  bug#3426427 Added parameter p_add_distinct       |
REM | 30-JUN-2005 arhegde enh# 4456833 get_dimlevel_select_wrap() and       |
REM |  get_dimlevel_select_string() - added x_is_relation_recursive         |
REM | 27-Sep-2005 ankgoel  Bug#4625598,4626579 Uptake common API to get dim |
REM |                      level values                                     |
REM |     09-feb-2007 ashankar Simulation Tree Enhacement 5386112           |
REM |     09-Mar-2007 ashankar Fix for the bug #5920996                     |
REM | 29/03/07   ashankar Bug#5932973 Supporting filters and key items for SM tree |
REM +=======================================================================+
*/
--
-- Record to hold the results of GET_DIMLEVEL_SELECT_STRING API
TYPE dim_level_select_rec_Type IS RECORD
(Dim_level_sname      VARCHAR2(2000)
,Table_name           VARCHAR2(2000)
,Id_name              VARCHAR2(2000)
,Value_name           VARCHAR2(2000)
,Parent_name          VARCHAR2(2000)
,Select_String        VARCHAR2(32000)
,Time_level           VARCHAR2(2000)
);

TYPE BIS_PMF_QUERY_ATTRIBUTES_TABLE IS TABLE OF BIS_PMF_QUERY_ATTRIBUTES;

PROCEDURE GET_DIMLEVEL_SELECT_STRING
(p_DimLevelName     IN  VARCHAR2
,p_add_distinct     IN  VARCHAR2 := 'F'
,x_Select_String    OUT NOCOPY VARCHAR2
,x_table_name       OUT NOCOPY VARCHAR2
,x_id_name          OUT NOCOPY VARCHAR2
,x_value_name       OUT NOCOPY VARCHAR2
,x_time_level       OUT NOCOPY VARCHAR2
,x_return_status    OUT NOCOPY VARCHAR2
,x_msg_count        OUT NOCOPY NUMBER
,x_msg_data         OUT NOCOPY VARCHAR2
);
PROCEDURE GET_DIMLEVEL_SELECT_STRING
(p_DimLevelName     IN  VARCHAR2
,p_bis_source       IN  VARCHAR2
,x_Select_String    OUT NOCOPY VARCHAR2
,x_table_name       OUT NOCOPY VARCHAR2
,x_id_name          OUT NOCOPY VARCHAR2
,x_value_name       OUT NOCOPY VARCHAR2
,x_time_level       OUT NOCOPY VARCHAR2
,x_return_status    OUT NOCOPY VARCHAR2
,x_msg_count        OUT NOCOPY NUMBER
,x_msg_data         OUT NOCOPY VARCHAR2
);
FUNCTION  isAccounting_Flexfield
(p_dim_level_name  IN VARCHAR2
)
RETURN BOOLEAN;
PROCEDURE GET_EDW_SELECT_STRING
(p_dim_level_name       IN     VARCHAR2
,p_source               IN     VARCHAR2 := NULL -- 2617369
,x_table_name           OUT NOCOPY    VARCHAR2
,x_id_name              OUT NOCOPY    VARCHAR2
,x_value_name           OUT NOCOPY    VARCHAR2
,x_edw_select_String    OUT NOCOPY    VARCHAR2
,x_time_level           OUT NOCOPY    VARCHAR2
,x_return_status        OUT NOCOPY    VARCHAR2
,x_msg_count            OUT NOCOPY    NUMBER
,x_msg_data             OUT NOCOPY    VARCHAR2
);
PROCEDURE GET_BIS_SELECT_STRING
(p_dim_level_name       IN     VARCHAR2
,p_source               IN     VARCHAR2 := NULL -- 2617369
,p_add_distinct         IN     VARCHAR2 := 'F'
,x_table_name           OUT NOCOPY    VARCHAR2
,x_id_name              OUT NOCOPY    VARCHAR2
,x_value_name           OUT NOCOPY    VARCHAR2
,x_bis_select_string    OUT NOCOPY    VARCHAR2
,x_time_level           OUT NOCOPY    VARCHAR2
,x_return_status        OUT NOCOPY    VARCHAR2
,x_msg_count            OUT NOCOPY    NUMBER
,x_msg_data             OUT NOCOPY    VARCHAR2
);
PROCEDURE GET_DIMLEVEL_VALUES_DATA
(p_bis_dimlevel_id         IN   NUMBER
,x_dimlevel_short_name     OUT NOCOPY  VARCHAR2
,x_select_String           OUT NOCOPY  VARCHAR2
,x_table_name              OUT NOCOPY  VARCHAR2
,x_value_name              OUT NOCOPY  VARCHAR2
,x_id_name                 OUT NOCOPY  VARCHAR2
,x_level_name              OUT NOCOPY  VARCHAR2
,x_description             OUT NOCOPY  VARCHAR2
,x_return_status           OUT NOCOPY  VARCHAR2
,x_msg_count               OUT NOCOPY  NUMBER
,x_msg_data                OUT NOCOPY  VARCHAR2
);
--===========================================================
PROCEDURE get_dimlevel_select_string(
   p_dimlevel_rec          IN  BIS_PMF_GET_DIMLEVELS_PUB.dimlvl_rec_Type
  ,p_param_lists_tbl       IN  BIS_PMF_GET_DIMLEVELS_PUB.dimlvl_tbl_Type
  ,p_bis_source            IN  bis_levels.source%TYPE := NULL
  ,p_region_code           IN  ak_regions.region_code%TYPE
  ,x_select_string         OUT NOCOPY VARCHAR2
  ,x_table_name            OUT NOCOPY VARCHAR2
  ,x_where_clause          OUT NOCOPY VARCHAR2
  ,x_bind_params           OUT NOCOPY BIS_PMF_QUERY_ATTRIBUTES_TABLE
  ,x_id_name               OUT NOCOPY VARCHAR2
  ,x_value_name            OUT NOCOPY VARCHAR2
  ,x_parent_name           OUT NOCOPY VARCHAR2
  ,x_time_level            OUT NOCOPY VARCHAR2
  ,x_is_relation_recursive OUT NOCOPY VARCHAR2
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2

);

PROCEDURE get_dimlevel_select_wrap (
   p_dimLevel              IN VARCHAR2 -- can be an object
  ,p_paramlist             IN VARCHAR2 -- can be an object
  ,p_bis_source            IN VARCHAR2
  ,p_region_code           IN  ak_regions.region_code%TYPE
  ,x_select_string         OUT NOCOPY VARCHAR2
  ,x_table_name            OUT NOCOPY VARCHAR2
  ,x_where_clause          OUT NOCOPY VARCHAR2
  ,x_bind_param_string     OUT NOCOPY VARCHAR2
  ,x_id_name               OUT NOCOPY VARCHAR2
  ,x_value_name            OUT NOCOPY VARCHAR2
  ,x_parent_name           OUT NOCOPY VARCHAR2
  ,x_time_level            OUT NOCOPY VARCHAR2
  ,x_is_relation_recursive OUT NOCOPY VARCHAR2
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
);

PROCEDURE GET_DIMLEVEL_SELECT_STRING
(p_DimLevelName     IN  VARCHAR2
,p_bis_source       IN  VARCHAR2
,x_Select_String    OUT NOCOPY VARCHAR2
,x_table_name       OUT NOCOPY VARCHAR2
,x_id_name          OUT NOCOPY VARCHAR2
,x_value_name       OUT NOCOPY VARCHAR2
,x_parent_name      OUT NOCOPY VARCHAR2
,x_time_level       OUT NOCOPY VARCHAR2
,x_return_status    OUT NOCOPY VARCHAR2
,x_msg_count        OUT NOCOPY NUMBER
,x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE GET_BIS_SELECT_STRING
(p_dim_level_name       IN     VARCHAR2
,p_source               IN     VARCHAR2 := NULL -- 2617369
,p_add_distinct         IN     VARCHAR2 := 'F'
,x_table_name           OUT NOCOPY    VARCHAR2
,x_id_name              OUT NOCOPY    VARCHAR2
,x_value_name           OUT NOCOPY    VARCHAR2
,x_parent_name          OUT NOCOPY    VARCHAR2
,x_bis_select_string    OUT NOCOPY    VARCHAR2
,x_time_level           OUT NOCOPY    VARCHAR2
,x_return_status        OUT NOCOPY    VARCHAR2
,x_msg_count            OUT NOCOPY    NUMBER
,x_msg_data             OUT NOCOPY    VARCHAR2
);

FUNCTION get_dim_level_source (
  p_dim_level_short_name IN VARCHAR2
) RETURN VARCHAR2;

--===========================================================
END BIS_PMF_GET_DIMLEVELS_PVT;

/
