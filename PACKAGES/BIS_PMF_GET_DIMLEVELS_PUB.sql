--------------------------------------------------------
--  DDL for Package BIS_PMF_GET_DIMLEVELS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_PMF_GET_DIMLEVELS_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPGDLS.pls 120.2 2005/06/27 04:46:37 arhegde noship $ */
/*
REM dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=pls \
REM dbdrv: checkfile(115.13=120.2):~PROD:~PATH:~FILE
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVGDLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for getting the Select String for DimensionLevelValues|
REM |     This API will get the Select String from either EDW or BIS
REM |     depending on the profile option BIS_SOURCE
REM |                                                                       |
REM | HISTORY                                                               |
REM | December-2000 amkulkar Creation                                       |
REM | 09-MAY-2003   arhegde  Added record and table types for child and     |
REM |                         parent dim level info , enh 2819971           |
REM | 27-JUN-2005 arhegde bug# 4456833 Added ri_attribute_code to dimlvl &  |
REM |                dim rel rec                                            |
REM +=======================================================================+
*/
--
TYPE dimlvl_rec_type IS RECORD (
  dimension_short_name VARCHAR2(80) := NULL
 ,dimension_level_short_name VARCHAR2(80) := NULL
 ,dimension_level_value_id VARCHAR2(32000) := NULL
 ,ri_attribute_code VARCHAR2(2000) := NULL
);

TYPE dimlvl_tbl_type IS TABLE OF dimlvl_rec_type INDEX BY BINARY_INTEGER;

TYPE dim_rel_info_rec IS RECORD (
  dimension_short_name VARCHAR2(80) := NULL
 ,dimension_level_short_name VARCHAR2(80) := NULL
 ,parent_dimension_short_name VARCHAR2(80) := NULL
 ,parent_level_short_name VARCHAR2(80) := NULL
 ,parent_dim_level_value_id VARCHAR2(32000) := NULL
 ,relation_col VARCHAR2(80) := NULL
 ,relation_type NUMBER := NULL
 ,parent_ri_attribute_code VARCHAR2(2000) := NULL
);


PROCEDURE GET_DIMLEVEL_SELECT_STRING
(
 p_DimLevelShortName     IN  VARCHAR2
,p_bis_source            IN  VARCHAR2
,x_Select_String         OUT NOCOPY VARCHAR2
,x_table_name            OUT NOCOPY VARCHAR2
,x_id_name               OUT NOCOPY VARCHAR2
,x_value_name            OUT NOCOPY VARCHAR2
,x_return_status         OUT NOCOPY VARCHAR2
,x_msg_count             OUT NOCOPY NUMBER
,x_msg_data              OUT NOCOPY VARCHAR2
);
--
PROCEDURE GET_SORTED_SELECT_STRING
(
 p_DimLevelShortName     IN  VARCHAR2
,p_bis_source            IN  VARCHAR2
,x_Select_String         OUT NOCOPY VARCHAR2
,x_table_name            OUT NOCOPY VARCHAR2
,x_id_name               OUT NOCOPY VARCHAR2
,x_value_name            OUT NOCOPY VARCHAR2
,x_return_status         OUT NOCOPY VARCHAR2
,x_msg_count             OUT NOCOPY NUMBER
,x_msg_data              OUT NOCOPY VARCHAR2
);

END BIS_PMF_GET_DIMLEVELS_PUB;

 

/
