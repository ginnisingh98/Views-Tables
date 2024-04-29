--------------------------------------------------------
--  DDL for Package Body BIS_PMF_GET_DIMLEVELS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMF_GET_DIMLEVELS_PVT" AS
/* $Header: BISVGDLB.pls 120.19 2007/12/27 13:33:25 lbodired ship $ */
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
REM |     Private API for getting the Select String for DimensionLevelValues|
REM |     This API will get the Select String from either EDW or BIS        |
REM |     depending on the profile option BIS_SOURCE                        |
REM |                                                                       |
REM | HISTORY                                                               |
REM | December-2000 amkulkar Creation                                       |
REM | 09-OCT-2002 MAHRAO Fix for 2617369                                    |
REM | 17-OCT-2002 MAHRAO Fix for 2525408                                    |
REM | 23-DEC-2002 MAHRAO Fix for 2668693                                    |
REM | 03-JAN-2003 RCHANDRA Bug 2721710, populate the global variable        |
REM |                       G_DIM_LEVEL_SELECT_INFO_REC; reuse info if the  |
REM |                       same the API is called for the same dimensionlevel
REM | 08-JAN-2003 RCHANDRA Bug 2721710,
REM |                       added proc cahce_dim_lvl_Select_info
REM |                       to copy values into the global variable
REM | 05-MAY-2003 arhegde  enh#2819971 overload get_dim_level_select_string |
REM | 16-MAY-2003 rchandra bug#2959622 logic to parse p_paramlist           |
REM |                       get_dimlevel_select_wrap                        |
REM | 11-JUL-2003 rchandra bug#3014105, added support for EDW dimensions    |
REM |                       level relationships thru API get_oltp_edw_cols  |
REM | 25-JAN-2004 gbhaloti bug#3388371 add support to get select string for |
REM |                      BSC dimension levels                             |
REM | 25-JAN-2004 gbhaloti bug#3395623 Removed "ORGANIZATION/               |
REM |         INV ORGANIZATION" from DimLvlList                             |
REM | 11-FEB-2004 ankgoel  bug#3426427 Added parameter p_add_distinct and   |
REM |         included "ORGANIZATION/INV ORGANIZATION" in DimLvlList        |
REM | 12-FEB-2004 ankgoel  bug#3436329 Removed whitespaces from "NAME" in   |
REM |         GET_EDW_SELECT_STRING procedure                               |
REM | 15-FEB-05   ppandey   Enh #4016669, support ID, Value for Autogen DO  |
REM | 27-JUN-05 arhegde enh# 4456833 - SQL + where clause for bis/bsc       |
REM |             dim level relationship from main API that PMV calls       |
REM | 29-JUN-05 arhegde enh# 4456833 - Chgd where clause + filtered "All"   |
REM | 30-JUN-05 arhegde enh# 4456833 - isRecursive in wrap API + BSC dim    |
REM |    level without parent_id is handled                                 |
REM | 13-JUL-05 adrao added condition to check if it is a Periodicity time  |
REM |           dimension object in the API GET_BIS_SELECT_STRING           |
REM | 27-Sep-05 ankgoel  Bug#4625598,4626579 Uptake common API to get dim   |
REM |                    level values                                       |
REM | 19-Oct-05 arhegde enh# 4456833 parent-child whereclause relationship  |
REM | 26-Oct-05 arhegde bug# 4699787 hierarchial where clause changes       |
REM | 26-Oct-05 arhegde bug# 4699787 is_append_where_clause() pre-seeded    |
REM |             relationships do not send back dynamic where clause       |
REM | 17-Nov-05 arhegde bug# 4697700 BSC DOs used in VBR fails.Passed back  |
REM |      code, value and bsc datasource for BSC DOs (get_bis_select_string|
REM | 11-Jan-06 arhegde bug# 4914929 Parent_Id is not passed back from SQL  |
REM |    unless it is a recursive dim object                                |
REM | 02-Feb-06 ashankar Bug#4871663 For BSC dim objects passing user_code  |
REM |                    instead of code                                    |
REM | 10-Feb-06 arhegde bug# 5029245 is_append_where_clause modified to     |
REM |           return true for non-seeded recursive dim object relations   |
REM | 17-Feb-06 arhegde bug# 5041300 Reverting fix for bug# 4871663 due to  |
REM |   other issues such as parameter passing. Will fix bug# 4871663 later |
REM |     09-feb-2007 ashankar Simulation Tree Enhacement 5386112           |
REM |     09-Mar-2007 ashankar Fix for the bug #5920996                     |
REM | 29/03/07   ashankar Bug#5932973 Supporting filters and key items for SM tree |
REM | 12/19/07   bijain   Bug Fix 5945766                                   |
REM +=======================================================================+
*/
--
-- CONSTANTS
   EDW_ACCT_FLEXFIELD           VARCHAR2(200) := 'EDW_GL_ACCT';
   EDW_LVL_TBL_SUFFIX           VARCHAR2(200) := '_LTC';
   EDW_LVL_FLEX_PK_SUFFIX       VARCHAR2(200) := '_NAME';
   EDW_PK_KEY                   VARCHAR2(200) := '%PK_KEY';
   G_PKG_NAME                   VARCHAR2(200) := 'BIS_PMF_GET_DIMLEVELS_PVT';
   G_DIM_LEVEL_SELECT_INFO_REC  BIS_PMF_GET_DIMLEVELS_PVT.dim_level_select_rec_Type;

   G_PMF_BIND_VAR               VARCHAR2(200) := ':PARENT_DIMLVL_VALUE_ID';
   G_BIND_INTEGER               NUMBER(2)     := 1;
   G_BIND_VARCHAR2              NUMBER(2)     := 2;
   G_BIND_DATE                  NUMBER(2)     := 3;
   G_BIND_NUMERIC               NUMBER(2)     := 4;
   G_ID_NAME                    VARCHAR2(80) := 'Id';
   G_VALUE_NAME                 VARCHAR2(80) := 'Value';
   G_PARENT_NAME                VARCHAR2(80)  := 'Parent';

   G_OLTP                       VARCHAR2(10) := 'OLTP';
   G_EDW                        VARCHAR2(10) := 'EDW';

   /* For bug #3388371 */
   G_BSC_ID_NAME        VARCHAR2(80)   := 'Code';
   G_BSC_VALUE_NAME     VARCHAR2(80)   := 'Name';

TYPE DimLvlList IS   VARRAY(100)  of  VARCHAR2(100);
-- This list is prepared with dimension levels under 'EDW_ORGANIZATION_M', 'ORGANIZATION', 'EDW_MTL_INVENTORY_LOC_M',
-- 'INVENTORY LOCATION' dimensions (as existed, but validated thru. code) + HRI_PER_USRDR_H
-- EDW_TIME_CAL_PERIOD, EDW_TIME_CAL_MONTH, EDW_TIME_CAL_YEAR
Dlist  DimLvlList := DimLvlList('EDW_ORGA_LEG_ENTITY', 'EDW_ORGA_TREE1_LVL2', 'EDW_ORGA_TREE1_LVL6', 'EDW_ORGANIZATION_A',
                     'EDW_ORGA_BUSINESS_GRP', 'EDW_ORGA_OPER_UNIT', 'EDW_ORGA_ORG', 'EDW_ORGA_TREE1_LVL1',
                     'EDW_ORGA_TREE1_LVL3', 'EDW_ORGA_TREE1_LVL4', 'EDW_ORGA_TREE1_LVL5', 'EDW_ORGA_TREE1_LVL7',
                     'EDW_ORGA_TREE1_LVL8', 'OPERATING UNIT', 'ORGANIZATION', 'INV ORGANIZATION', 'LEGAL ENTITY', 'BUSINESS GROUP',
                     'HR ORGANIZATION', 'TOTAL_ORGANIZATIONS', 'OPM COMPANY', 'SET OF BOOKS', 'PJI_ORGANIZATIONS',
                     'PJI_SUBORG', 'JTF_RESOURCE_GROUP_MEM', 'JTF_ORG_INTERACTION_CENTER_GRP', 'JTF_ORG_SALES_GROUP',
                     'FII_OPERATING_UNITS', 'HRI_CL_ORGCC', 'HRI_ORG_BGR_HX', 'HRI_ORG_HRCYVRSN_BX', 'HRI_ORG_HRCY_BX',
                     'HRI_ORG_HR_H', 'HRI_ORG_HR_HX', 'HRI_ORG_INHV_H', 'HRI_ORG_SRHL', 'HRI_ORG_SSUP_H', 'HRI_PER_USRDR_H',
                     'EDW_MTL_ILDM_OU', 'EDW_MTL_ILDM_SUB_INV', 'EDW_MTL_ILDM_LOCATOR', 'EDW_MTL_ILDM_PCMP', 'EDW_MTL_ILDM_PLANT',
                     'EDW_MTL_ILDM_PORG', 'EDW_MTL_INVENTORY_LOC_A', 'OPM ORGANIZATION', 'OPM WAREHOUSE',
                     'SUBINVENTORY', 'TOTAL INV LOCATIONS', 'EDW_TIME_CAL_PERIOD', 'EDW_TIME_CAL_QTR', 'EDW_TIME_CAL_YEAR');

--====================================================================
PROCEDURE get_oltp_edw_cols (
   p_Dim_Level_Short_Name IN VARCHAR2
  ,p_Source IN VARCHAR2
  ,x_Table_Name OUT NOCOPY VARCHAR2
  ,x_Id_Name OUT NOCOPY VARCHAR2
  ,x_Value_Name OUT NOCOPY VARCHAR2
  ,x_return_status OUT NOCOPY VARCHAR2
  ,x_msg_count OUT NOCOPY NUMBER
  ,x_msg_data OUT NOCOPY VARCHAR2
);
--====================================================================

PROCEDURE get_select_string (
   p_bis_source            IN VARCHAR2
  ,p_is_relation_recursive IN VARCHAR2
  ,p_is_relationship_found IN VARCHAR2
  ,p_dim_rel_info_rec      IN bis_pmf_get_dimlevels_pub.dim_rel_info_rec
  ,p_region_code           IN  ak_regions.region_code%TYPE
  ,x_select_string         OUT NOCOPY VARCHAR2
  ,x_bind_params            OUT NOCOPY BIS_PMF_QUERY_ATTRIBUTES_TABLE-- (attribute_value, attribute_data_type)
  ,x_where_clause          OUT NOCOPY VARCHAR2
  ,x_data_source           OUT NOCOPY VARCHAR2
  ,x_id_name               OUT NOCOPY VARCHAR2
  ,x_value_name            OUT NOCOPY VARCHAR2
  ,x_parent_name           OUT NOCOPY VARCHAR2
  ,x_time_level            OUT NOCOPY VARCHAR2
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2

);
--================================================================
PROCEDURE get_pmf_data_source(
   p_bis_source            IN VARCHAR2
  ,p_dim_rel_info_rec      IN bis_pmf_get_dimlevels_pub.dim_rel_info_rec
  ,p_is_relation_recursive IN VARCHAR2
  ,x_select_string         OUT NOCOPY VARCHAR2
  ,x_bind_params           OUT NOCOPY BIS_PMF_QUERY_ATTRIBUTES_TABLE
  ,x_data_source           OUT NOCOPY VARCHAR2
  ,x_id_name               OUT NOCOPY VARCHAR2
  ,x_value_name            OUT NOCOPY VARCHAR2
  ,x_parent_name           OUT NOCOPY VARCHAR2
  ,x_time_level            OUT NOCOPY VARCHAR2
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
);

--================================================================
PROCEDURE get_bsc_data_source(
   p_dim_rel_info_rec           IN bis_pmf_get_dimlevels_pub.dim_rel_info_rec
  ,p_region_code                IN  ak_regions.region_code%TYPE
  ,x_id_name                    OUT NOCOPY VARCHAR2
  ,x_value_name                 OUT NOCOPY VARCHAR2
  ,x_parent_name                OUT NOCOPY VARCHAR2
  ,x_select_string              OUT NOCOPY VARCHAR2
  ,x_data_source                OUT NOCOPY VARCHAR2
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
);
--================================================================

PROCEDURE get_relationship_details (
   p_child_dimlvl_rec      IN bis_pmf_get_dimlevels_pub.dimlvl_rec_type
  ,p_parent_dimlvl_tbl     IN bis_pmf_get_dimlevels_pub.dimlvl_tbl_type
  ,x_is_relation_recursive OUT NOCOPY VARCHAR2
  ,x_is_relationship_found OUT NOCOPY VARCHAR2
  ,x_dim_rel_info_rec      OUT NOCOPY bis_pmf_get_dimlevels_pub.dim_rel_info_rec
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
);
--================================================================

PROCEDURE get_bsc_relationship_data (
   p_child_dimlvl_rec   IN bis_pmf_get_dimlevels_pub.dimlvl_rec_type
  ,p_parent_dimlvl_rec  IN bis_pmf_get_dimlevels_pub.dimlvl_rec_type
  ,x_bsc_dim_rel_info_rec   OUT NOCOPY bsc_dimension_levels_pub.bsc_dim_level_rec_type
  ,x_is_relationship_found OUT NOCOPY VARCHAR2
  ,x_is_relation_recursive OUT NOCOPY VARCHAR2
  ,x_return_status OUT NOCOPY VARCHAR2
  ,x_msg_count OUT NOCOPY NUMBER
  ,x_msg_data OUT NOCOPY VARCHAR2
);
--================================================================

FUNCTION get_source (
  p_dim_level_short_name IN VARCHAR2
)RETURN VARCHAR2;
--================================================================

FUNCTION needs_time_cols (
   p_source       IN bis_levels.source%TYPE
  ,p_data_source  IN bis_levels.level_values_view_name%TYPE
  ,p_lvlshortname IN bis_levels.short_name%TYPE
  ,p_dimshortname IN bis_dimensions.short_name%TYPE
) RETURN BOOLEAN;

--====================================================================
FUNCTION IS_DISTINCT_USED
(p_Dimension_Level_Short_Name  IN   bis_levels.short_name%TYPE
) RETURN BOOLEAN;

-- Private function used to to see if the dim level info is already cached
FUNCTION IS_DIM_LVL_INFO_CACHED
(p_DimLevelSName               IN  bis_levels.short_name%TYPE
,x_Select_String               OUT NOCOPY VARCHAR2
,x_table_name                  OUT NOCOPY VARCHAR2
,x_id_name                     OUT NOCOPY VARCHAR2
,x_value_name                  OUT NOCOPY VARCHAR2
,x_parent_name                 OUT NOCOPY VARCHAR2
,x_time_level                  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN;

-- private function to Store the values into the Global variable
PROCEDURE cache_dim_lvl_Select_info
(p_DimLevelSName               IN  VARCHAR2
,p_Select_String               IN  VARCHAR2
,p_table_name                  IN  VARCHAR2
,p_id_name                     IN  VARCHAR2
,p_value_name                  IN  VARCHAR2
,p_parent_name                 IN  VARCHAR2
,p_time_level                  IN  VARCHAR2
) ;

FUNCTION is_append_where_clause(
  p_dim_rel_info_rec      IN bis_pmf_get_dimlevels_pub.dim_rel_info_rec
 ,p_is_relation_recursive IN VARCHAR2
) RETURN BOOLEAN;

--==================================================================
PROCEDURE Get_Bsc_Dim_Obj_details
(
   p_dim_rel_info_rec       IN          bis_pmf_get_dimlevels_pub.dim_rel_info_rec
  ,p_region_code            IN          ak_regions.region_code%TYPE
  ,x_child_level_pk_col     OUT NOCOPY  BSC_SYS_DIM_LEVELS_B.LEVEL_PK_COL%TYPE
  ,x_child_level_view_name  OUT NOCOPY  BSC_SYS_DIM_LEVELS_B.LEVEL_VIEW_NAME%TYPE
  ,x_parent_level_pk_col    OUT NOCOPY  BSC_SYS_DIM_LEVELS_B.LEVEL_PK_COL%TYPE
  ,x_parent_level_view_name OUT NOCOPY  BSC_SYS_DIM_LEVELS_B.LEVEL_VIEW_NAME%TYPE
  ,x_return_status          OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2

);

PROCEDURE GET_DIMLEVEL_SELECT_STRING
(p_DimLevelName         IN     VARCHAR2
,p_add_distinct         IN     VARCHAR2 := 'F'
,x_Select_String        OUT NOCOPY    VARCHAR2
,x_table_name           OUT NOCOPY    VARCHAR2
,x_id_name              OUT NOCOPY    VARCHAR2
,x_value_name           OUT NOCOPY    VARCHAR2
,x_time_level           OUT NOCOPY    VARCHAR2
,x_return_status        OUT NOCOPY    VARCHAR2
,x_msg_count            OUT NOCOPY    NUMBER
,x_msg_data             OUT NOCOPY    VARCHAR2
)
IS
  l_api_name            VARCHAR2(200) :=' GET_DIMLEVEL_SELECT_STRING';
  CURSOR c_dims IS
  SELECT source, level_values_view_name
  FROM  bis_levels
  WHERE short_name = p_DimLevelName
  ;
  l_source     VARCHAR2(2000);
  l_level_values_view_name   VARCHAR2(32000);
  l_parent_name VARCHAR2(100);

  /* 3388371- gbhaloti FOR BSC LEVELS */
--  l_bsc_source VARCHAR(10);

BEGIN
  FND_MSG_PUB.initialize;
-- Reuse the value from the global record if it is the same dimension level
  IF (IS_DIM_LVL_INFO_CACHED (p_DimLevelSName   => p_DimLevelName
                          ,x_Select_String   => x_Select_String
                          ,x_table_name      => x_table_name
                          ,x_id_name         => x_id_name
                          ,x_value_name      => x_value_name
                    ,x_parent_name     => l_parent_name
                          ,x_time_level      => x_time_level ) ) THEN

    x_return_status     := FND_API.G_RET_STS_SUCCESS ;

    RETURN;
  END IF;

  /* 3388371- gbhaloti FOR BSC LEVELS */
--  l_bsc_source := get_dim_level_source (p_DimLevelName);


  OPEN c_dims;
  FETCH c_dims INTO l_Source, l_level_Values_view_name;
  IF (c_dims%NOTFOUND) THEN
     FND_MESSAGE.SET_NAME('BIS','BIS_INAVLID_LEVEL_SHORT_NAME');
     FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_DimLevelName);
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_dims;
  --IF (fnd_profile.value('BIS_SOURCE') = 'EDW')
  IF ((l_source = 'EDW')  and
       (l_level_values_view_name IS NULL))-- OR l_level_values_view_name='AAA'))
  THEN
      BIS_PMF_GET_DIMLEVELS_PVT.GET_EDW_SELECT_STRING
      (p_dim_level_name    => p_DimLevelName
      ,p_source            => l_source
      ,x_table_name        => x_table_name
      ,x_id_name           => x_id_name
      ,x_value_name        => x_value_name
      ,x_edw_select_String => x_Select_String
      ,x_time_level    => x_time_level
      ,x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data           => x_msg_data
      );
   ELSE
        BIS_PMF_GET_DIMLEVELS_PVT.GET_BIS_SELECT_STRING
     (p_dim_level_name     => p_DimLevelName
     ,p_source            => l_source
     ,p_add_distinct      => p_add_distinct
     ,x_table_name         => x_table_name
     ,x_id_name            => x_id_name
     ,x_value_name         => x_value_name
     ,x_bis_select_string  => x_select_string
     ,x_time_level     => x_time_level
     ,x_return_status     => x_return_status
     ,x_msg_count         => x_msg_count
     ,x_msg_data           => x_msg_data
     );
  END IF;


  -- Store the values into the Global variable
  cache_dim_lvl_Select_info
    (p_DimLevelSName               => p_DimLevelName
    ,p_Select_String               => x_Select_String
    ,p_table_name                  => x_table_name
    ,p_id_name                     => x_id_name
    ,p_value_name                  => x_value_name
    ,p_parent_name                 => l_parent_name
    ,p_time_level                  => x_time_level
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count    =>    x_msg_count,
        p_data     =>    x_msg_data
      );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count    =>    x_msg_count,
        p_data     =>    x_msg_data
      );
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
          FND_MSG_PUB.Add_Exc_Msg
          ( G_PKG_NAME,
            l_api_name
          );
       END IF;
       FND_MSG_PUB.Count_And_Get
       ( p_count    =>    x_msg_count,
         p_data     =>    x_msg_data
       );
END;
--

PROCEDURE get_dimlevel_select_string (
   p_DimLevelName         IN     VARCHAR2
  ,p_bis_source           IN     VARCHAR2
  ,x_Select_String        OUT NOCOPY    VARCHAR2
  ,x_table_name           OUT NOCOPY    VARCHAR2
  ,x_id_name              OUT NOCOPY    VARCHAR2
  ,x_value_name           OUT NOCOPY    VARCHAR2
  ,x_time_level           OUT NOCOPY    VARCHAR2
  ,x_return_status        OUT NOCOPY    VARCHAR2
  ,x_msg_count            OUT NOCOPY    NUMBER
  ,x_msg_data             OUT NOCOPY    VARCHAR2
)
IS
  l_parent_name VARCHAR2(100);
BEGIN

  GET_DIMLEVEL_SELECT_STRING (
    p_DimLevelName        => p_DimLevelName
   ,p_bis_source          => p_bis_source
   ,x_Select_String       => x_Select_String
   ,x_table_name          => x_table_name
   ,x_id_name             => x_id_name
   ,x_value_name          => x_value_name
   ,x_parent_name         => l_parent_name
   ,x_time_level          => x_time_level
   ,x_return_status       => x_return_status
   ,x_msg_count           => x_msg_count
   ,x_msg_data            => x_msg_data
);

END;

--Overloaded to get the parent_name
PROCEDURE GET_DIMLEVEL_SELECT_STRING
(p_DimLevelName         IN     VARCHAR2
,p_bis_source           IN     VARCHAR2
,x_Select_String        OUT NOCOPY    VARCHAR2
,x_table_name           OUT NOCOPY    VARCHAR2
,x_id_name              OUT NOCOPY    VARCHAR2
,x_value_name           OUT NOCOPY    VARCHAR2
,x_parent_name          OUT NOCOPY    VARCHAR2
,x_time_level           OUT NOCOPY    VARCHAR2
,x_return_status        OUT NOCOPY    VARCHAR2
,x_msg_count            OUT NOCOPY    NUMBER
,x_msg_data             OUT NOCOPY    VARCHAR2
)
IS
  l_api_name            VARCHAR2(200) :=' GET_DIMLEVEL_SELECT_STRING';
  CURSOR c_dims IS
  SELECT source, level_values_view_name
  FROM  bis_levels
  WHERE short_name = p_DimLevelName
  ;
  l_source     VARCHAR2(2000);
  l_level_values_view_name   VARCHAR2(32000);

  /* 3388371- gbhaloti FOR BSC LEVELS */
--  l_bsc_source VARCHAR(10);
BEGIN
  FND_MSG_PUB.initialize;
-- Reuse the value from the global record if it is the same dimension level
  IF (IS_DIM_LVL_INFO_CACHED (p_DimLevelSName   => p_DimLevelName
                          ,x_Select_String   => x_Select_String
                          ,x_table_name      => x_table_name
                          ,x_id_name         => x_id_name
                          ,x_value_name      => x_value_name
              ,x_parent_name     => x_parent_name
                          ,x_time_level      => x_time_level ) ) THEN

    x_return_status     := FND_API.G_RET_STS_SUCCESS ;

    RETURN;
  END IF;

  /* 3388371- gbhaloti FOR BSC LEVELS */
--  l_bsc_source := get_dim_level_source (p_DimLevelName);

  l_source := p_bis_source;
  --IF (l_source IS null)
  --THEN
      OPEN c_dims;
      FETCH c_dims INTO l_Source, l_level_values_view_name;
      IF (c_dims%NOTFOUND) THEN
         FND_MESSAGE.SET_NAME('BIS','BIS_INAVLID_LEVEL_SHORT_NAME');
         FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_DimLevelName);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE c_dims;
  --END IF;
  --IF (fnd_profile.value('BIS_SOURCE') = 'EDW')
  IF ((l_source = 'EDW')  and (l_level_values_view_name IS NULL))
  THEN
      BIS_PMF_GET_DIMLEVELS_PVT.GET_EDW_SELECT_STRING
      (p_dim_level_name    => p_DimLevelName
      ,p_source            => l_source
      ,x_table_name        => x_table_name
      ,x_id_name           => x_id_name
      ,x_value_name        => x_value_name
      ,x_edw_select_String => x_Select_String
      ,x_time_level    => x_time_level
      ,x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data           => x_msg_data
      );
   ELSE
      BIS_PMF_GET_DIMLEVELS_PVT.GET_BIS_SELECT_STRING
     (p_dim_level_name     => p_DimLevelName
     ,p_source             => l_source
     ,x_table_name         => x_table_name
     ,x_id_name            => x_id_name
     ,x_value_name         => x_value_name
     ,x_parent_name        => x_parent_name
     ,x_bis_select_string  => x_select_string
     ,x_time_level     => x_time_level
     ,x_return_status     => x_return_status
     ,x_msg_count         => x_msg_count
     ,x_msg_data           => x_msg_data
     );
  END IF;


  -- Store the values into the Global variable
  cache_dim_lvl_Select_info
    (p_DimLevelSName               => p_DimLevelName
    ,p_Select_String               => x_Select_String
    ,p_table_name                  => x_table_name
    ,p_id_name                     => x_id_name
    ,p_value_name                  => x_value_name
    ,p_parent_name                 => x_parent_name
    ,p_time_level                  => x_time_level
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count    =>    x_msg_count,
        p_data     =>    x_msg_data
      );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count    =>    x_msg_count,
        p_data     =>    x_msg_data
      );
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
          FND_MSG_PUB.Add_Exc_Msg
          ( G_PKG_NAME,
            l_api_name
          );
       END IF;
       FND_MSG_PUB.Count_And_Get
       ( p_count    =>    x_msg_count,
         p_data     =>    x_msg_data
       );
END;
FUNCTION  isAccounting_Flexfield
(p_dim_level_name  IN VARCHAR2
)
RETURN BOOLEAN
IS
 l_dimshortname    varchar2(32000);
 l_dim_lvl_sql     varchar2(32000);

BEGIN
-- 2214178
  l_dim_lvl_sql := 'SELECT dim.DIM_NAME dimshortname '||
                   ' FROM '||
                   ' edw_dimensions_md_v dim, edw_levels_md_v lvl '||
                   ' WHERE '||
                   ' lvl.DIM_ID = dim.DIM_ID AND '||
                   ' lvl.LEVEL_NAME = :p_dim_level_name ';

  BEGIN
    EXECUTE IMMEDIATE  l_dim_lvl_sql INTO
          l_dimshortname
          USING p_dim_level_name;
  EXCEPTION WHEN NO_DATA_FOUND THEN
        NULL;
  END;
  IF (instr(l_dimshortname,EDW_ACCT_FLEXFIELD) <> 0)
  THEN
       RETURN true;
  ELSE
      RETURN false;
  END IF;
END;

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
)
IS
 l_api_name          VARCHAR2(200) :=' GET_EDW_SELECT_STRING';
 --Commented out NOCOPY the TYPE declaration to not depend on OWB/EDW objects
 l_lvlshortname      VARCHAR2(32000);--CMPLEVEL_V.name%TYPE;
 l_dimshortname      VARCHAR2(32000);--CMPWBDIMENSION_V.name%TYPE;
 l_dimname           VARCHAR2(32000);--CMPWBDIMENSION_V.longname%TYPE;
 l_dimdesc           VARCHAR2(32000);--CMPWBDIMENSION_V.description%TYPE;
 l_lvlname           VARCHAR2(32000);--CMPLEVEL_V.longname%TYPE;
 l_lvldesc           VARCHAR2(32000);--CMPLEVEL_V.description%TYPE;
 l_prefix            VARCHAR2(32000);--CMPLEVEL_V.prefix%TYPE;
 l_pkkey             VARCHAR(2000);
 l_valuename         VARCHAR2(2000);
 l_tablename         VARCHAR2(2000);
 l_distinct          VARCHAR2(2000);
 l_select_string     VARCHAR2(32000);
 l_temp_tablename   VARCHAR2(32000);
 l_sql_string        VARCHAR2(32000);
 l_lvlshortname_ltc  VARCHAR2(32000);

 l_dimshortname_time  VARCHAR2(32000);
 l_lvlshortname_total VARCHAR2(32000);
 l_time_columns               VARCHAR2(2000);
 l_dim_lvl_sql                VARCHAR2(32000);
 l_pkkey_sql                  VARCHAR2(32000);
BEGIN
-- 2214178
  l_dim_lvl_sql := 'SELECT dim.DIM_NAME dimshortname, dim.DIM_LONG_NAME dimname, dim.DIM_DESCRIPTION dimdesc'||
                   ',lvl.LEVEL_NAME lvlshortname, lvl.LEVEL_LONG_NAME lvlname, lvl.description lvldesc'||
                   ',lvl.LEVEL_PREFIX prefix'||
                   ' FROM '||
                   ' edw_dimensions_md_v dim, edw_levels_md_v lvl '||
                   ' WHERE '||
                   ' lvl.DIM_ID = dim.DIM_ID AND '||
                   ' lvl.LEVEL_NAME = :p_dim_level_name ';

  BEGIN
    EXECUTE IMMEDIATE  l_dim_lvl_sql INTO
          l_dimshortname, l_dimname,l_dimdesc, l_lvlshortname, l_lvlname, l_lvldesc, l_prefix
          USING p_dim_level_name;
  EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME ('BIS','BIS_INVALID_LEVEL_SHORT_NAME');
        FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME',p_dim_level_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
  END;
  IF (BIS_PMF_GET_DIMLEVELS_PVT.isAccounting_Flexfield(l_lvlshortname))
  THEN
     l_pkkey := l_prefix||EDW_LVL_FLEX_PK_SUFFIX;
     l_tablename := l_dimshortname;
     l_distinct  := ' DISTINCT ';
     l_valuename := l_prefix||EDW_LVL_FLEX_PK_SUFFIX;
     l_sql_string := 'SELECT '||l_pkkey||' from '||l_tablename|| ' where rownum < 2';
     BEGIN
         EXECUTE IMMEDIATE l_sql_string ;
     EXCEPTION
     WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF (SQLCODE = -942) THEN
               FND_MESSAGE.SET_NAME ('BIS', 'BIS_NO_LTC_TABLE');
               FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_dim_level_name);
               FND_MSG_PUB.ADD;
           END IF;
           IF (SQLCODE= -904) THEN
              FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_EDW_PK_KEY');
              FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME',p_dim_level_name);
              FND_MSG_PUB.ADD;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
           FND_MSG_PUB.Count_And_Get
           (p_count    =>    x_msg_count,
            p_data     =>    x_msg_data
           );
      END;
  ELSE
     BEGIN
        l_lvlshortname_ltc := l_lvlshortname || '_LTC';
        l_pkkey_sql := ' SELECT level_table_col_name '||
                       ' FROM edw_level_Table_atts_md_v '||
                       ' WHERE key_type=''UK'' AND '||
                       ' upper(level_Table_name) = upper(:l_lvlshortname) AND '||
                       ' level_table_col_name like '''||EDW_PK_KEY||'''';

        EXECUTE IMMEDIATE l_pkkey_sql INTO  l_pkkey USING l_lvlshortname_ltc;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_EDW_PK_KEY');
        FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME',p_dim_level_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END;
     l_tablename := l_lvlshortname || EDW_LVL_TBL_SUFFIX ;
     l_sql_string := 'SELECT '||l_pkkey||' from '||l_tablename|| ' where rownum < 2';
     BEGIN
       EXECUTE IMMEDIATE l_sql_string ;
     EXCEPTION
     WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF (SQLCODE = -942) THEN
               FND_MESSAGE.SET_NAME ('BIS', 'BIS_NO_LTC_TABLE');
               FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_dim_level_name);
               FND_MSG_PUB.ADD;
           END IF;
           IF (SQLCODE= -904) THEN
              FND_MESSAGE.SET_NAME ('BIS', 'BIS_INVALID_EDW_PK_KEY');
              FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_dim_level_name);
              FND_MSG_PUB.ADD;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
     END;
     l_valuename := 'NAME';
   END IF;
   IF p_source IS NOT NULL THEN -- 2617369
     l_dimshortname_time  := BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_SRC(p_source => p_source);
     l_lvlshortname_total := BIS_UTILITIES_PVT.GET_TOTAL_DIMLEVEL_NAME_SRC(p_dim_short_name=>l_dimshortname
                                                                          ,p_source => p_source
                                              );
   ELSE
     l_dimshortname_time := BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME(p_DimLevelId => NULL
                                                                     ,p_DimLevelName =>l_lvlshortname
                                         );
     l_lvlshortname_total := BIS_UTILITIES_PVT.GET_TOTAL_DIMLEVEL_NAME(p_dim_short_name=>l_dimshortname
                                                                      ,p_DimLevelId => NULL
                                                                      ,p_DimLevelName => l_lvlshortname
                                      );
   END IF;
   IF ((l_dimshortname = l_dimshortname_time) AND
       (l_lvlshortname <> l_lvlshortname_total)
      ) THEN
       l_time_columns := ' ,start_date, end_date ';
       x_time_level   := 'Y';
       l_sql_string   := 'SELECT start_date from '||l_tablename||' where rownum < 2';
       BEGIN
           EXECUTE IMMEDIATE l_sql_string ;
       EXCEPTION
       WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF (SQLCODE = -942) THEN
               FND_MESSAGE.SET_NAME ('BIS', 'BIS_NO_LTC_TABLE');
               FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_dim_level_name);
               FND_MSG_PUB.ADD;
           END IF;
           IF (SQLCODE= -904) THEN
              FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_START_DATE');
              FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME',p_dim_level_name);
              FND_MSG_PUB.ADD;
           END IF;
          RAISE FND_API.G_EXC_ERROR;
       END;
       l_sql_string   := 'SELECT end_date from '||l_tablename||' where rownum < 2';
       BEGIN
           EXECUTE IMMEDIATE l_sql_string ;
       EXCEPTION
       WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF (SQLCODE = -942) THEN
               FND_MESSAGE.SET_NAME ('BIS', 'BIS_NO_LTC_TABLE');
               FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_dim_level_name);
               FND_MSG_PUB.ADD;
           END IF;
           IF (SQLCODE= -904) THEN
              FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_EDW_END_DATEY');
              FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME',p_dim_level_name);
              FND_MSG_PUB.ADD;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
       END;

   ELSE
      l_time_columns := '';
   END IF;
   l_sql_string := 'SELECT '||l_valuename||' from '||l_tablename|| ' where rownum < 2';
   BEGIN
      EXECUTE IMMEDIATE l_sql_string ;
   EXCEPTION
      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF (SQLCODE = -942) THEN
               FND_MESSAGE.SET_NAME ('BIS', 'BIS_NO_LTC_TABLE');
               FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_dim_level_name);
               FND_MSG_PUB.ADD;
           END IF;
           IF (SQLCODE= -904) THEN
              FND_MESSAGE.SET_NAME ('BIS', 'BIS_INVALID_VALUE');
              FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_dim_level_name);
              FND_MSG_PUB.ADD;
           END IF;
           RAISE FND_API.G_EXC_ERROR;
   END;

   x_edw_select_string := 'select '||l_distinct||' '|| l_pkkey ||'  id , ' ||
                           l_valuename ||'  value '||l_time_columns|| ' FROM '|| l_tablename;
   x_table_name := l_tablename;
   x_id_name    := l_pkkey;
   x_value_name := l_valuename;
   x_return_status :=  FND_API.G_RET_STS_SUCCESS;
   FND_MSG_PUB.Count_And_Get
   (p_count    =>    x_msg_count,
    p_data     =>    x_msg_data
   );


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count    =>    x_msg_count,
        p_data     =>    x_msg_data
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count    =>    x_msg_count,
        p_data     =>    x_msg_data
      );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME,
          l_api_name
         );
      END IF;
      FND_MSG_PUB.Count_And_Get
      (p_count    =>    x_msg_count,
       p_data     =>    x_msg_data
      );
END;
--
PROCEDURE GET_BIS_SELECT_STRING (
 p_dim_level_name       IN   VARCHAR2
,p_source               IN   VARCHAR2 := NULL -- 2617369
,p_add_distinct         IN   VARCHAR2 := 'F'
,x_table_name           OUT NOCOPY  VARCHAR2
,x_id_name              OUT NOCOPY  VARCHAR2
,x_value_name           OUT NOCOPY  VARCHAR2
,x_bis_select_string    OUT NOCOPY  VARCHAR2
,x_time_level           OUT NOCOPY  VARCHAR2
,x_return_status        OUT NOCOPY  VARCHAR2
,x_msg_count            OUT NOCOPY  NUMBER
,x_msg_data             OUT NOCOPY  VARCHAR2
)
IS
  l_parent_name VARCHAR2(100);
BEGIN

GET_BIS_SELECT_STRING (
   p_dim_level_name     =>  p_dim_level_name
  ,p_source             =>  p_source
  ,p_add_distinct       =>  p_add_distinct
  ,x_table_name         =>  x_table_name
  ,x_id_name            =>  x_id_name
  ,x_value_name         =>  x_value_name
  ,x_parent_name        =>  l_parent_name
  ,x_bis_select_string  =>  x_bis_select_string
  ,x_time_level         =>  x_time_level
  ,x_return_status      =>  x_return_status
  ,x_msg_count          =>  x_msg_count
  ,x_msg_data           =>  x_msg_data
);

END;


-- overloaded for parent name
PROCEDURE GET_BIS_SELECT_STRING
(p_dim_level_name       IN   VARCHAR2
,p_source               IN   VARCHAR2 := NULL -- 2617369
,p_add_distinct         IN   VARCHAR2 := 'F'
,x_table_name           OUT NOCOPY  VARCHAR2
,x_id_name              OUT NOCOPY  VARCHAR2
,x_value_name           OUT NOCOPY  VARCHAR2
,x_parent_name          OUT NOCOPY VARCHAR2
,x_bis_select_string    OUT NOCOPY  VARCHAR2
,x_time_level           OUT NOCOPY  VARCHAR2
,x_return_status        OUT NOCOPY  VARCHAR2
,x_msg_count            OUT NOCOPY  NUMBER
,x_msg_data             OUT NOCOPY  VARCHAR2
)
IS
  CURSOR c_dimlvls IS
  SELECT lvl.short_name, dim.short_name, lvl.level_values_view_name, bscdl.source, bscdl.level_view_name
  FROM   bis_levels lvl, bis_dimensions dim, bsc_sys_dim_levels_b bscdl
  WHERE  lvl.dimension_id = dim.dimension_id AND
         (lvl.short_name = p_dim_level_name AND p_dim_level_name IS NOT NULL)
         AND bscdl.short_name = lvl.short_name
  ;
  l_lvlshortname          bis_levels.short_name%TYPE;
  l_levelvalueview        bis_levels.level_values_view_name%TYPE;
  l_dimshortname          bis_dimensions.short_name%TYPE;
  l_time_columns          VARCHAR2(2000);
  l_Api_name              VARCHAR2(200) := 'GET_BIS_SELECT_STRING';
  l_Is_Rolling_Period_Level NUMBER;  -- 2408906
  l_dimshortname_time     bis_dimensions.short_name%TYPE;
  l_pmfBscSource          VARCHAR2(30);
  l_bscLevelViewName      VARCHAR2(30);
  l_id                    VARCHAR2(30) := 'ID';
  l_value                 VARCHAR2(30) := 'VALUE';
BEGIN

  OPEN c_dimlvls;
  FETCH c_dimlvls INTO l_lvlshortname, l_dimshortname, l_levelvalueview, l_pmfBscSource, l_bscLevelViewName;
  IF c_dimlvls%NOTFOUND THEN
     FND_MESSAGE.SET_NAME('BIS', 'BIS_INVALID_LEVEL_SHORTNAME');
     FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_dim_level_name);
     FND_MSG_PUB.ADD;
     RAISE   FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_dimlvls;
  l_Is_Rolling_Period_Level := BIS_UTILITIES_PVT.Is_Rolling_Period_Level(  -- 2408906
                                    p_level_short_name => l_lvlshortname);

  IF ( l_Is_Rolling_Period_Level = 1 ) THEN -- 2408906

    x_bis_select_string := ' select -1 Id, '
                   || ''''
                   || BIS_UTILITIES_PVT.GET_FND_MESSAGE( 'BIS_ALL_VALUE_ROLLING' )
                   || ''''
                   || ' Value, sysdate start_date, sysdate end_date from dual ' ;
            -- ' select -1 Id, ' || '''All''' || ' Value from dual ' ;
                -- ' select id, value, start_date, end_date from BIS_ROLLING_LEVEL_002 ' ;

    x_table_name        := 'dual'; -- 'BIS_ROLLING_LEVEL_002'; -- 'dual'; --
    x_id_name           := 'ID';
    x_value_name        := 'VALUE';
    x_time_level        := 'Y'; -- rolling period should not be checking if x_time_level is null
    x_return_status     :=  FND_API.G_RET_STS_SUCCESS;


  ELSE

    IF p_source IS NOT NULL THEN -- 2617369
      l_dimshortname_time := BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_SRC(p_Source => p_source);
    ELSE
      l_dimshortname_time := BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME(p_DimLevelId => NULL
                                                                     , p_DimLevelName => l_lvlshortname);
    END IF;

    -- Added condition to check if it is a Periodicity time Dimension Object
    IF ((l_dimshortname = l_dimshortname_time) OR
        (BSC_UTILITY.Is_Dim_Object_Periodicity_Type(l_lvlshortname) = FND_API.G_TRUE)) THEN
      l_time_columns := ' , start_date, end_date ';
      x_time_level   := 'Y';
    ELSE
      l_time_columns := '';
    END IF;

    IF ( IS_DISTINCT_USED (p_Dimension_Level_Short_Name => l_lvlshortname) AND (p_add_distinct = 'T') )THEN
      x_bis_select_string := 'SELECT DISTINCT id , value '|| l_time_columns ||' FROM ' || l_levelvalueview;
    ELSE
      IF (l_pmfBscSource IS NOT NULL AND l_pmfBscSource = 'PMF') THEN
        x_bis_select_string := 'SELECT id , value '|| l_time_columns ||' FROM ' || l_levelvalueview;
      ELSE
        l_levelvalueview := l_bscLevelViewName;
        l_id := 'CODE';
        l_value := 'NAME';
        x_bis_select_string := 'SELECT code , name '|| l_time_columns ||' FROM ' || l_bscLevelViewName;
      END IF;
    END IF;

     --------------- bug1906157
    IF (l_dimshortname = 'GL COMPANY' and p_dim_level_name <> 'TOTAL GL COMPANIES')
    THEN
      x_parent_name := 'PARENT_ID'; -- check
      x_bis_select_string := 'SELECT id , value , set_of_books_id '|| l_time_columns ||' FROM ' ||
                 l_levelvalueview;
    END IF;
    ----------

    --------------- bug 2381087
    IF (l_dimshortname = 'GL SECONDARY MEASURE' and p_dim_level_name <> 'TOTAL GL SECONDARY MEASURES')
    THEN
      x_parent_name := 'PARENT_ID'; -- check
      x_bis_select_string := 'SELECT id , value , set_of_books_id '|| l_time_columns ||' FROM ' ||
                 l_levelvalueview;
    END IF;
    ----------

    --  x_bis_select_string := 'SELECT id , value '|| l_time_columns ||' FROM ' ||
    --                 l_levelvalueview;
    x_table_name        := l_levelvalueview;
    x_id_name           := l_id;
    x_value_name        := l_value;
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    FND_MSG_PUB.Count_And_Get
    (p_count    =>    x_msg_count,
     p_data     =>    x_msg_data
    );

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count    =>    x_msg_count,
        p_data     =>    x_msg_data
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count    =>    x_msg_count,
        p_data     =>    x_msg_data
      );
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
     (p_count => x_msg_count,
      p_data   => x_msg_data
     );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg
        (G_PKG_NAME,
         l_api_name
        );
      END IF;
      FND_MSG_PUB.Count_And_Get
      (p_count    =>    x_msg_count,
       p_data     =>    x_msg_data
      );
END;
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
,x_msg_Count               OUT NOCOPY  NUMBER
,x_msg_data                OUT NOCOPY  VARCHAR2
)
IS
  l_api_name            VARCHAR2(200) :=' GET_DIMLEVEL_SELECT_STRING';
  CURSOR c_dims IS
  SELECT source, name,description , short_name, level_values_view_name
  FROM  bis_levels_vl
  WHERE level_id = p_bis_dimlevel_id
  ;
  l_short_name  BIS_LEVELS_VL.SHORT_NAME%TYPE;
  l_source      BIS_LEVELS_VL.SOURCE%TYPE;
  l_level_name  BIS_LEVELS_VL.NAME%TYPE;
  l_description BIS_LEVELS_VL.DESCRIPTION%TYPE;
  l_time_level  VARCHAR2(2001);
  l_level_values_view_name VARCHAR2(32000);
BEGIN
  FND_MSG_PUB.initialize;
  OPEN c_dims;
  FETCH c_dims INTO l_Source,l_level_name, l_description,l_short_name,l_level_values_view_name;
  IF (c_dims%NOTFOUND) THEN
     FND_MESSAGE.SET_NAME('BIS','BIS_INAVLID_LEVEL_SHORT_NAME');
     FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', l_short_name);
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_dims;
  --IF (fnd_profile.value('BIS_SOURCE') = 'EDW')
  IF ((l_source = 'EDW') AND (l_level_Values_view_name IS NULL))
  THEN
      BIS_PMF_GET_DIMLEVELS_PVT.GET_EDW_SELECT_STRING
      (p_dim_level_name    => l_Short_name
      ,p_source            => l_source
      ,x_table_name        => x_table_name
      ,x_id_name           => x_id_name
      ,x_value_name        => x_value_name
      ,x_edw_select_String => x_Select_String
      ,x_time_level        => l_time_level
      ,x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data           => x_msg_data
      );
   ELSE
      BIS_PMF_GET_DIMLEVELS_PVT.GET_BIS_SELECT_STRING
     (p_dim_level_name     => l_short_name
     ,p_source             => l_source
     ,x_table_name         => x_table_name
     ,x_id_name            => x_id_name
     ,x_value_name         => x_value_name
     ,x_bis_select_string  => x_select_string
     ,x_time_level        => l_time_level
     ,x_return_status     => x_return_status
     ,x_msg_count         => x_msg_count
     ,x_msg_data           => x_msg_data
     );
  END IF;
  x_level_name := l_level_name;
  x_Description := l_description;
  x_dimlevel_short_name := l_short_name;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count    =>    x_msg_count,
        p_data     =>    x_msg_data
      );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count    =>    x_msg_count,
        p_data     =>    x_msg_data
      );
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
          FND_MSG_PUB.Add_Exc_Msg
          ( G_PKG_NAME,
            l_api_name
          );
       END IF;
       FND_MSG_PUB.Count_And_Get
       ( p_count    =>    x_msg_count,
         p_data     =>    x_msg_data
       );
END;
-- Fix for 2668693
FUNCTION IS_DISTINCT_USED
(p_Dimension_Level_Short_Name  IN   bis_levels.short_name%TYPE
) RETURN BOOLEAN IS
BEGIN

  FOR i IN 1..Dlist.Count LOOP
    IF (Dlist(i) = p_Dimension_Level_Short_Name) THEN
      RETURN TRUE;
    END IF;
  END LOOP;
  RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END IS_DISTINCT_USED ;

-- procedure to Store the values into the Global variable
PROCEDURE cache_dim_lvl_Select_info
(p_DimLevelSName               IN  VARCHAR2
,p_Select_String               IN  VARCHAR2
,p_table_name                  IN  VARCHAR2
,p_id_name                     IN  VARCHAR2
,p_value_name                  IN  VARCHAR2
,p_parent_name                 IN  VARCHAR2
,p_time_level                  IN  VARCHAR2
) IS
BEGIN

  -- Store the values into the Global variable
  G_DIM_LEVEL_SELECT_INFO_REC.Dim_level_sname      := p_DimLevelSName ;
  G_DIM_LEVEL_SELECT_INFO_REC.Table_name           := p_table_name ;
  G_DIM_LEVEL_SELECT_INFO_REC.Id_name              := p_id_name ;
  G_DIM_LEVEL_SELECT_INFO_REC.Value_name           := p_value_name ;
  G_DIM_LEVEL_SELECT_INFO_REC.parent_name          := p_parent_name ;
  G_DIM_LEVEL_SELECT_INFO_REC.Select_String        := p_select_String ;
  G_DIM_LEVEL_SELECT_INFO_REC.Time_level           := p_time_level ;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END cache_dim_lvl_Select_info;

-- Private function to see if the dim level info is already cached
--  if so return the values from the global variable
FUNCTION IS_DIM_LVL_INFO_CACHED
(p_DimLevelSName               IN  bis_levels.short_name%TYPE
,x_Select_String               OUT NOCOPY VARCHAR2
,x_table_name                  OUT NOCOPY VARCHAR2
,x_id_name                     OUT NOCOPY VARCHAR2
,x_value_name                  OUT NOCOPY VARCHAR2
,x_parent_name                 OUT NOCOPY VARCHAR2
,x_time_level                  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
BEGIN

  IF ( UPPER(G_DIM_LEVEL_SELECT_INFO_REC.Dim_level_sname) = UPPER(p_DimLevelSName) ) THEN
    x_table_name        := G_DIM_LEVEL_SELECT_INFO_REC.Table_name    ;
    x_id_name           := G_DIM_LEVEL_SELECT_INFO_REC.Id_name       ;
    x_value_name        := G_DIM_LEVEL_SELECT_INFO_REC.Value_name    ;
    x_parent_name       := G_DIM_LEVEL_SELECT_INFO_REC.Parent_name   ;
    x_Select_String     := G_DIM_LEVEL_SELECT_INFO_REC.Select_String ;
    x_time_level        := G_DIM_LEVEL_SELECT_INFO_REC.Time_level    ;

    RETURN TRUE;
  END IF;

  RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END IS_DIM_LVL_INFO_CACHED ;



--=======================================================================
--=======================================================================
PROCEDURE get_dimlevel_select_wrap (
   p_dimLevel              IN VARCHAR2
  ,p_paramlist             IN VARCHAR2
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
)
IS
  l_dimlevelrec           BIS_PMF_GET_DIMLEVELS_PUB.dimlvl_rec_Type;
  l_parlevelrec           BIS_PMF_GET_DIMLEVELS_PUB.dimlvl_rec_Type;
  l_dimleveltbl           BIS_PMF_GET_DIMLEVELS_PUB.dimlvl_tbl_Type;
  l_bind_params           BIS_PMF_QUERY_ATTRIBUTES_TABLE;
  l_count                 NUMBER;
--  l_parent_name             VARCHAR2(300);
--  l_time_level            VARCHAR2(300);
  l_param_list            VARCHAR2(32000);
  l_index                 PLS_INTEGER;
err_msg            VARCHAR2(32000);
BEGIN
  IF (p_dimlevel IS NOT NULL) THEN
      l_dimlevelrec.dimension_short_name := SUBSTR(p_dimlevel, 1, INSTR (p_dimlevel, '^', 1, 1)-1);
      l_dimlevelrec.dimension_level_short_name := SUBSTR(p_dimlevel, INSTR (p_dimlevel, '^', 1, 1)+1, INSTR (p_dimlevel, '^', 1, 2) - INSTR (p_dimlevel, '^', 1, 1) -1);
      l_dimlevelrec.dimension_level_value_id := SUBSTR(p_dimlevel, INSTR (p_dimlevel, '^', 1, 2)+1, INSTR (p_dimlevel, '^', 1, 3) - INSTR (p_dimlevel, '^', 1, 2) -1);
          l_dimlevelrec.ri_attribute_code := SUBSTR(p_dimlevel, INSTR (p_dimlevel, '^', 1, 3)+1);
        -- put p_dimlevel string into p_dimlevelrecord
  END IF;

  IF (p_paramlist IS NOT NULL) THEN
    l_count := 1;
    l_param_list := p_paramlist;

    l_index := INSTR (l_param_list, '~*');
    WHILE (l_index > 0 ) LOOP

      l_parlevelrec.dimension_short_name       := SUBSTR(l_param_list, 1, (INSTR (l_param_list, '^', 1, 1)-1));
      l_parlevelrec.dimension_level_short_name := SUBSTR(l_param_list, (INSTR (l_param_list, '^', 1, 1)+1), (INSTR (l_param_list, '^', 1, 2) - INSTR (l_param_list, '^', 1, 1) -1));
      l_parlevelrec.dimension_level_value_id   := SUBSTR(l_param_list, (INSTR (l_param_list, '^', 1, 2)+1), (INSTR (l_param_list, '^', 1, 3) - INSTR (l_param_list, '^', 1, 2) -1));
      l_parlevelrec.ri_attribute_code := SUBSTR(l_param_list, (INSTR (l_param_list, '^', 1, 3)+1),
                                                      l_index - (INSTR (l_param_list, '^', 1, 3)) - 1);
      l_dimleveltbl(l_count) := l_parlevelrec;
      l_param_list := substr (l_param_list , l_index+2, length(l_param_list));
      l_index := INSTR (l_param_list, '~*');
      l_count := l_count+1;

    END LOOP;

    l_parlevelrec.dimension_short_name       := SUBSTR(l_param_list, 1, (INSTR (l_param_list, '^', 1, 1)-1));
    l_parlevelrec.dimension_level_short_name := SUBSTR(l_param_list, (INSTR (l_param_list, '^', 1, 1)+1), (INSTR (l_param_list, '^', 1, 2) - INSTR (l_param_list, '^', 1, 1) -1));
    l_parlevelrec.dimension_level_value_id   := SUBSTR(l_param_list, (INSTR (l_param_list, '^', 1, 2)+1), (INSTR (l_param_list, '^', 1, 3) - INSTR (l_param_list, '^', 1, 2) -1));
    l_parlevelrec.ri_attribute_code := SUBSTR(l_param_list, (INSTR (l_param_list, '^', 1, 3)+1),
                                                      (LENGTH(l_param_list)) - (INSTR (l_param_list, '^', 1, 3)));

    l_dimleveltbl(l_count) := l_parlevelrec;

  -- put p_paramlist string into p_paramlist table
  END IF;

  get_dimlevel_select_string(
    p_dimlevel_rec          => l_dimlevelrec
   ,p_param_lists_tbl       => l_dimleveltbl
   ,p_bis_source            => p_bis_source
   ,x_select_string         => x_select_string
   ,x_table_name            => x_table_name
   ,x_where_clause          => x_where_clause
   ,x_bind_params           => l_bind_params
   ,x_id_name               => x_id_name
   ,x_value_name            => x_value_name
   ,x_parent_name           => x_parent_name
   ,x_time_level            => x_time_level
   ,x_is_relation_recursive => x_is_relation_recursive
   ,x_return_status         => x_return_status
   ,x_msg_count             => x_msg_count
   ,x_msg_data              => x_msg_data
   ,p_region_code           => p_region_code
  );

  IF ( l_bind_params IS NOT NULL AND l_bind_params.COUNT > 0) THEN
    FOR i IN l_bind_params.FIRST..l_bind_params.LAST LOOP
      x_bind_param_string := x_bind_param_string || l_bind_params(i).attribute_name|| '^^';
      x_bind_param_string := x_bind_param_string || l_bind_params(i).attribute_value|| '^^';
      x_bind_param_string := x_bind_param_string || l_bind_params(i).attribute_data_type;
      IF (i <> l_bind_params.LAST) THEN
        x_bind_param_string := x_bind_param_string || '~*';
      END IF;
    END LOOP;
  END IF;

-- Here put l_bind_params into x_bind_param_string with ~* as separators for each record
EXCEPTION
  WHEN OTHERS THEN
  null;
  err_msg := SQLERRM;
END GET_DIMLEVEL_SELECT_WRAP;

--================================================================

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
)
IS
  l_bis_source bis_levels.source%TYPE;
  l_is_relationship_found VARCHAR2(10);
  l_dim_level_short_name VARCHAR2(80);
  l_dim_rel_info_rec bis_pmf_get_dimlevels_pub.dim_rel_info_rec;
  l_is_pmf_bsc_source BSC_SYS_DIM_LEVELS_B.SOURCE%TYPE;
  l_dim_un_rel_info_rec bis_pmf_get_dimlevels_pub.dim_rel_info_rec;
BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
  l_bis_source := p_bis_source;
  IF (l_bis_source IS NULL) THEN
    l_bis_source := get_source(p_dim_level_short_name => l_dim_level_short_name);
  END IF;

  get_relationship_details(
     p_child_dimlvl_rec      => p_dimlevel_rec
    ,p_parent_dimlvl_tbl     => p_param_lists_tbl -- p_parent_dimlvl_tbl
    ,x_is_relation_recursive => x_is_relation_recursive
    ,x_is_relationship_found => l_is_relationship_found
    ,x_dim_rel_info_rec      => l_dim_rel_info_rec
    ,x_return_status         => x_return_status
    ,x_msg_count             => x_msg_count
    ,x_msg_data              => x_msg_data
  );


  IF ( (l_is_relationship_found = FND_API.G_FALSE)) THEN
    -- Since relationship data not present in bsc data model, call existing code.
    l_is_pmf_bsc_source := get_dim_level_source (p_dimlevel_rec.dimension_level_short_name);
    IF (l_is_pmf_bsc_source = 'PMF') THEN
       get_dimlevel_select_string(
         p_DimLevelName   => p_dimlevel_rec.dimension_level_short_name
        ,p_bis_source     => l_bis_source
        ,x_Select_String  => x_select_string
        ,x_table_name     => x_table_name
        ,x_id_name        => x_id_name
        ,x_value_name     => x_value_name
        ,x_parent_name    => x_parent_name
        ,x_time_level     => x_time_level
        ,x_return_status  => x_return_status
        ,x_msg_count      => x_msg_count
        ,x_msg_data       => x_msg_data
      );
    ELSE -- BSC type when there are no relationships
      l_dim_un_rel_info_rec.dimension_short_name := p_dimlevel_rec.dimension_short_name;
      l_dim_un_rel_info_rec.dimension_level_short_name := p_dimlevel_rec.dimension_level_short_name;
      -- This API will return the source, id, value, sql, etc as id, value (without parent) since
      -- the l_dim_un_rel_info_rec does not pass in the parent info + relation info.
      get_bsc_data_source(
         p_dim_rel_info_rec  => l_dim_un_rel_info_rec
        ,x_id_name           => x_id_name
        ,x_value_name        => x_value_name
        ,x_parent_name       => x_parent_name
        ,x_select_string     => x_select_string
        ,x_data_source       => x_table_name
        ,x_return_status     => x_return_status
        ,x_msg_count         => x_msg_count
        ,x_msg_data          => x_msg_data
        ,p_region_code       => p_region_code
      );
    END IF;
  ELSIF ( (l_is_relationship_found = FND_API.G_TRUE) AND (l_dim_rel_info_rec.relation_col IS NULL) ) THEN
    -- throw exception if relation found but relation column is null
    FND_MESSAGE.SET_NAME('BIS','BIS_PMF_REL_COL_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSE -- relationship is found - both BIS and BSC is handled by this API.
    get_select_string(
      p_bis_source            => l_bis_source
     ,p_is_relation_recursive => x_is_relation_recursive
     ,p_is_relationship_found => l_is_relationship_found
     ,p_dim_rel_info_rec      => l_dim_rel_info_rec
     ,x_select_string         => x_select_string
     ,x_bind_params           => x_bind_params-- (attribute_value, attribute_data_type)
     ,x_where_clause          => x_where_clause
     ,x_data_source           => x_table_name
     ,x_id_name               => x_id_name
     ,x_value_name            => x_value_name
     ,x_parent_name           => x_parent_name
     ,x_time_level            => x_time_level
     ,x_return_status         => x_return_status
     ,x_msg_count             => x_msg_count
     ,x_msg_data              => x_msg_data
     ,p_region_code           => p_region_code

    );
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
END get_dimlevel_select_string;

--==================================================================
FUNCTION INITIALIZE_QUERY_TYPE
RETURN BIS_PMF_QUERY_ATTRIBUTES
IS
  l_query_attributes BIS_PMF_QUERY_ATTRIBUTES := BIS_PMF_QUERY_ATTRIBUTES(null,null,null);
BEGIN
  RETURN l_query_attributes;
END INITIALIZE_QUERY_TYPE;

--===================================================================
-- It is assumed that "distinct" and "set_of_books_id" (hardcode for GL Sec Measure), etc in
-- the apis above will not be done below, since the relationship select
-- and where clause will handle this
PROCEDURE get_select_string (
   p_bis_source            IN VARCHAR2
  ,p_is_relation_recursive IN VARCHAR2
  ,p_is_relationship_found IN VARCHAR2
  ,p_dim_rel_info_rec      IN bis_pmf_get_dimlevels_pub.dim_rel_info_rec
  ,p_region_code           IN  ak_regions.region_code%TYPE
  ,x_select_string         OUT NOCOPY VARCHAR2
  ,x_bind_params           OUT NOCOPY BIS_PMF_QUERY_ATTRIBUTES_TABLE-- (attribute_value, attribute_data_type)
  ,x_where_clause          OUT NOCOPY VARCHAR2
  ,x_data_source           OUT NOCOPY VARCHAR2
  ,x_id_name               OUT NOCOPY VARCHAR2
  ,x_value_name            OUT NOCOPY VARCHAR2
  ,x_parent_name           OUT NOCOPY VARCHAR2
  ,x_time_level            OUT NOCOPY VARCHAR2
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
)
IS
  l_is_pmf_bsc_source BSC_SYS_DIM_LEVELS_B.SOURCE%TYPE;
BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  l_is_pmf_bsc_source := get_dim_level_source (p_dim_rel_info_rec.dimension_level_short_name);

  IF (l_is_pmf_bsc_source = 'PMF') THEN
    get_pmf_data_source(
       p_bis_source => p_bis_source
      ,p_dim_rel_info_rec => p_dim_rel_info_rec
      ,p_is_relation_recursive => p_is_relation_recursive
      ,x_select_string => x_select_string
      ,x_bind_params => x_bind_params
      ,x_data_source => x_data_source
      ,x_id_name => x_id_name
      ,x_value_name => x_value_name
      ,x_parent_name => x_parent_name
      ,x_time_level => x_time_level
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
    );
  ELSE
    get_bsc_data_source(
       p_dim_rel_info_rec => p_dim_rel_info_rec
      ,x_Id_Name => x_Id_Name
      ,x_Value_Name => x_Value_Name
      ,x_parent_name => x_parent_name
      ,x_select_string => x_select_string
      ,x_data_source => x_data_source
      ,x_return_status => x_return_status
      ,x_msg_count => x_msg_count
      ,x_msg_data => x_msg_data
      ,p_region_code => p_region_code
    );
  END IF;
  -- the source will alias the actual parent column with parent_id always.
  -- if ALL is selected in the parent, then do not filter the child dim level values.
  -- Always use "IN" and not "=", so both multi-select and single select is taken care of.

  IF (p_dim_rel_info_rec.parent_ri_attribute_code IS NOT NULL) THEN
    IF (is_append_where_clause(p_dim_rel_info_rec => p_dim_rel_info_rec, p_is_relation_recursive => p_is_relation_recursive)) THEN
      IF (p_is_relation_recursive IS NOT NULL AND p_is_relation_recursive = FND_API.G_TRUE) THEN
        -- recursive relationship should bring itself, its children and its parent.
        x_where_clause := ' AND (( ''ALL'' IN ({' || p_dim_rel_info_rec.parent_ri_attribute_code || '}) OR ' || x_parent_name || ' IN ({' || p_dim_rel_info_rec.parent_ri_attribute_code || '}))' ||
                              ' OR ( ' || x_id_name || ' IN ({' || p_dim_rel_info_rec.parent_ri_attribute_code || '}))' ||
                              ' OR ( ' || x_id_name || ' IN (SELECT ' || x_parent_name || ' FROM ' || x_data_source || ' WHERE ' || x_id_name || ' IN ({' || p_dim_rel_info_rec.parent_ri_attribute_code || '}))))';
      ELSE
        x_where_clause := ' AND ( ''ALL'' IN ({' || p_dim_rel_info_rec.parent_ri_attribute_code || '}) OR ' || x_parent_name || ' IN ({' || p_dim_rel_info_rec.parent_ri_attribute_code || '}))';
      END IF;
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
END get_select_string;

--================================================================
PROCEDURE get_pmf_data_source(
   p_bis_source            IN VARCHAR2
  ,p_dim_rel_info_rec      IN bis_pmf_get_dimlevels_pub.dim_rel_info_rec
  ,p_is_relation_recursive IN VARCHAR2
  ,x_select_string         OUT NOCOPY VARCHAR2
  ,x_bind_params           OUT NOCOPY BIS_PMF_QUERY_ATTRIBUTES_TABLE
  ,x_data_source           OUT NOCOPY VARCHAR2
  ,x_id_name               OUT NOCOPY VARCHAR2
  ,x_value_name            OUT NOCOPY VARCHAR2
  ,x_parent_name           OUT NOCOPY VARCHAR2
  ,x_time_level            OUT NOCOPY VARCHAR2
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
)
IS
  l_data_source BIS_LEVELS.level_values_view_name%TYPE;
  l_dim_short_name          VARCHAR2(80);
  l_dimlvl_short_name           VARCHAR2(80);
  l_parent_dim_short_name       VARCHAR2(80);
  l_parent_dimlvl_short_name    VARCHAR2(80);
  l_parent_lvl_value_id         VARCHAR2(32000);
  l_relation_col                  VARCHAR2(80);
  l_relation_col_in_select      VARCHAR2(300);
  l_time_columns VARCHAR2(100);

BEGIN
  l_dim_short_name              := p_dim_rel_info_rec.dimension_short_name ;
  l_dimlvl_short_name           := p_dim_rel_info_rec.dimension_level_short_name ;
  l_parent_dim_short_name       := p_dim_rel_info_rec.parent_dimension_short_name ;
  l_parent_dimlvl_short_name    := p_dim_rel_info_rec.parent_level_short_name ;
  l_parent_lvl_value_id         := p_dim_rel_info_rec.parent_dim_level_value_id;
  l_relation_col                := p_dim_rel_info_rec.relation_col;
  -- EDW may not be needed anymore since EDW dim levels do not show up on the UI
  -- and hence relationships cannot be defined for them.

  get_oltp_edw_cols (
     p_Dim_Level_Short_Name => p_dim_rel_info_rec.dimension_level_short_name
    ,p_Source => p_bis_source
    ,x_Table_Name => l_data_source
    ,x_Id_Name => x_Id_Name
    ,x_Value_Name => x_Value_Name
    ,x_return_status => x_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data => x_msg_data
  );

  IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ( needs_time_cols(--check if this is fine for both edw and oltp
       p_source           => p_bis_source
      ,p_data_source      => l_data_source
      ,p_lvlshortname     => l_dimlvl_short_name
    ,p_dimshortname     => l_dim_short_name
      )) THEN
    l_time_columns := ' ,start_date, end_date ';
    x_time_level := FND_API.G_TRUE;
  END IF;

  /* Removed code for get_binds() for enh# 4456833 - not needed now - binds etc are not used. No values are passed
     into this API but keeping in the original API signature in DimLevelUtil for backward compatibility.
  */
  -- PMV does not need the parent_id column in the select statement unless it is recursive - bug# 4914929.
  IF (p_is_relation_recursive IS NOT NULL AND p_is_relation_recursive = FND_API.G_TRUE) THEN
    l_relation_col_in_select := ', ' || l_relation_col || ' as parent_id ';
  END IF;
  x_select_string := 'SELECT '|| x_Id_Name ||' , '|| x_Value_Name || l_relation_col_in_select || l_time_columns || ' FROM '|| l_data_source;
  x_data_source    := l_data_source ;
  x_parent_name := l_relation_col; -- 'PARENT_ID'; -- parent_id is the alias always.


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
END get_pmf_data_source;

--================================================================
PROCEDURE get_bsc_data_source(
   p_dim_rel_info_rec           IN  bis_pmf_get_dimlevels_pub.dim_rel_info_rec
  ,p_region_code                IN  ak_regions.region_code%TYPE
  ,x_id_name                    OUT NOCOPY VARCHAR2
  ,x_value_name                 OUT NOCOPY VARCHAR2
  ,x_parent_name                OUT NOCOPY VARCHAR2
  ,x_select_string              OUT NOCOPY VARCHAR2
  ,x_data_source                OUT NOCOPY VARCHAR2
  ,x_return_status              OUT NOCOPY VARCHAR2
  ,x_msg_count                  OUT NOCOPY NUMBER
  ,x_msg_data                   OUT NOCOPY VARCHAR2
)
IS

  l_relation_type           BSC_SYS_DIM_LEVEL_RELS.RELATION_TYPE%TYPE;
  l_child_level_pk_col      BSC_SYS_DIM_LEVELS_B.LEVEL_PK_COL%TYPE;
  l_child_level_view_name   BSC_SYS_DIM_LEVELS_B.LEVEL_VIEW_NAME%TYPE;
  l_parent_level_pk_col     BSC_SYS_DIM_LEVELS_B.LEVEL_PK_COL%TYPE;
  l_parent_level_view_name  BSC_SYS_DIM_LEVELS_B.LEVEL_VIEW_NAME%TYPE;
  l_restrict_all_value      VARCHAR2(100);

BEGIN

    l_relation_type := p_dim_rel_info_rec.relation_type;

    BIS_PMF_GET_DIMLEVELS_PVT.Get_Bsc_Dim_Obj_details
    (
       p_dim_rel_info_rec        =>  p_dim_rel_info_rec
      ,p_region_code             =>  p_region_code
      ,x_child_level_pk_col      =>  l_child_level_pk_col
      ,x_child_level_view_name   =>  l_child_level_view_name
      ,x_parent_level_pk_col     =>  l_parent_level_pk_col
      ,x_parent_level_view_name  =>  l_parent_level_view_name
      ,x_return_status           =>  x_return_status
      ,x_msg_count               =>  x_msg_count
      ,x_msg_data                =>  x_msg_data
    );
    IF(x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    /* PMV appends "All" based on All enabled/disabled (bsc_sys_dim_levels_by_group.total_flag.
     * In PMF views (level_values_view_name), All is not present (or restricted by product team where clause).
     * In BSC views (level_view_name), All is always present with code as 0. This needs to be filtered out so that
     * PMV can continue the same logic irrespective of a PMF or BSC dim level.
     */
    l_restrict_all_value := ' a.code <> 0';
    -- if it is a 1 X n relationship or not related (no entries in bsc_sys_dim_level_rels)
    IF (l_relation_type IS NULL OR l_relation_type = 1) THEN
      IF (p_dim_rel_info_rec.relation_col IS NOT NULL) THEN -- entry in bsc_sys_dim_level_rels.
        x_data_source := ' (SELECT a.code id, a.name value, ' || p_dim_rel_info_rec.relation_col || ' parent_id FROM '|| l_child_level_view_name || ' a WHERE ' || l_restrict_all_value || ')';
        x_select_string := 'SELECT id, value FROM ' || x_data_source;
        x_parent_name := 'PARENT_ID';
      ELSE -- only for a un-related BSC dim level - to prepare the data source similar to BIS.
        x_data_source := ' (SELECT a.code id, a.name value FROM '|| l_child_level_view_name || ' a WHERE ' || l_restrict_all_value || ')';
        x_select_string := 'SELECT id, value FROM ' || x_data_source;
      END IF;
    ELSE -- l_relation_type = 2 - if it is a m X n relationship
      x_data_source := ' (SELECT a.code id, a.name value, c.'  || l_parent_level_pk_col || ' parent_id FROM ' || l_child_level_view_name
                         || ' a, ' || l_parent_level_view_name || ' b,' || p_dim_rel_info_rec.relation_col || ' c WHERE a.code'
                         || ' = c.' || l_child_level_pk_col || ' AND b.code = ' || 'c.' || l_parent_level_pk_col || ' AND ' || l_restrict_all_value || ')';
      -- Parent_id is removed from select string and distinct added since mXn will result in duplicate values when "All"
      -- is selected in the parent. bug# 4914929.
      x_select_string := 'SELECT distinct id, value FROM ' || x_data_source;
      x_parent_name := 'PARENT_ID';
    END IF;
    x_id_name := G_ID_NAME;
    x_value_name := G_VALUE_NAME;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                             ,p_data  =>      x_msg_data);

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
END get_bsc_data_source;

--===================================================================
/**
 *
 * This method will return with details of the first occurrence of a
 * parent-child relationship. The child short name
 * (p_child_dimlvl_rec.dimension_level_short_name) is used as the
 * parent and child for the "recursive parent-child relationship" check
 *
 */
--===================================================================

PROCEDURE get_relationship_details (
   p_child_dimlvl_rec      IN bis_pmf_get_dimlevels_pub.dimlvl_rec_type
  ,p_parent_dimlvl_tbl     IN bis_pmf_get_dimlevels_pub.dimlvl_tbl_type
  ,x_is_relation_recursive OUT NOCOPY VARCHAR2
  ,x_is_relationship_found OUT NOCOPY VARCHAR2
  ,x_dim_rel_info_rec      OUT NOCOPY bis_pmf_get_dimlevels_pub.dim_rel_info_rec
  ,x_return_status         OUT NOCOPY VARCHAR2
  ,x_msg_count             OUT NOCOPY NUMBER
  ,x_msg_data              OUT NOCOPY VARCHAR2
)
IS
  l_bsc_dim_rel_info_rec bsc_dimension_levels_pub.bsc_dim_level_rec_type;
  l_parent_dimlvl_tbl bis_pmf_get_dimlevels_pub.dimlvl_tbl_type;
  l_count NUMBER;
  err_msg VARCHAR2(3000);
BEGIN
  l_parent_dimlvl_tbl := p_parent_dimlvl_tbl;
  x_is_relation_recursive := FND_API.G_FALSE;
  x_is_relationship_found := FND_API.G_FALSE;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  -- check for recursive parent-child relationship.
  -- For this, append the child to the parent table type.
  -- Recursive takes precedence and hence it is added as the first.
  l_count := l_parent_dimlvl_tbl.COUNT;
  l_parent_dimlvl_tbl(l_count+1) := p_child_dimlvl_rec;

  FOR i IN REVERSE 1 .. l_parent_dimlvl_tbl.COUNT LOOP
    get_bsc_relationship_data (
      p_child_dimlvl_rec      => p_child_dimlvl_rec
     ,p_parent_dimlvl_rec     => l_parent_dimlvl_tbl(i)
     ,x_bsc_dim_rel_info_rec  => l_bsc_dim_rel_info_rec
     ,x_is_relationship_found => x_is_relationship_found
     ,x_is_relation_recursive => x_is_relation_recursive
     ,x_return_status         => x_return_status
     ,x_msg_count             => x_msg_count
     ,x_msg_data              => x_msg_data
    );
    IF (x_is_relationship_found = FND_API.G_TRUE) THEN
      x_dim_rel_info_rec.dimension_short_name := p_child_dimlvl_rec.dimension_short_name;
      x_dim_rel_info_rec.dimension_level_short_name := l_bsc_dim_rel_info_rec.bsc_level_short_name;
      x_dim_rel_info_rec.parent_dimension_short_name := l_parent_dimlvl_tbl(i).dimension_short_name;
      x_dim_rel_info_rec.parent_level_short_name := l_bsc_dim_rel_info_rec.bsc_parent_level_short_name;
      x_dim_rel_info_rec.parent_dim_level_value_id := l_parent_dimlvl_tbl(i).dimension_level_value_id;
      x_dim_rel_info_rec.relation_col := l_bsc_dim_rel_info_rec.bsc_relation_column;
      x_dim_rel_info_rec.relation_type := l_bsc_dim_rel_info_rec.bsc_relation_type;
      x_dim_rel_info_rec.parent_ri_attribute_code := l_parent_dimlvl_tbl(i).ri_attribute_code;
      RETURN;
    END IF;

  END LOOP;
  -- Reach here concludes that there is no parent-child relationship defined for this.

EXCEPTION
  WHEN OTHERS THEN
    err_msg := SQLERRM;
END get_relationship_details;

--=====================================================

PROCEDURE get_bsc_relationship_data (
   p_child_dimlvl_rec   IN bis_pmf_get_dimlevels_pub.dimlvl_rec_type
  ,p_parent_dimlvl_rec  IN bis_pmf_get_dimlevels_pub.dimlvl_rec_type
  ,x_bsc_dim_rel_info_rec   OUT NOCOPY bsc_dimension_levels_pub.bsc_dim_level_rec_type
  ,x_is_relationship_found OUT NOCOPY VARCHAR2
  ,x_is_relation_recursive OUT NOCOPY VARCHAR2
  ,x_return_status OUT NOCOPY VARCHAR2
  ,x_msg_count OUT NOCOPY NUMBER
  ,x_msg_data OUT NOCOPY VARCHAR2
)
IS
  l_bsc_dim_level_rec BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type;
 -- l_return_status VARCHAR2(10);
--  l_msg_count NUMBER;
--  l_msg_data VARCHAR2(3000);
BEGIN
  x_is_relationship_found := FND_API.G_FALSE;
  x_is_relation_recursive := FND_API.G_FALSE;
  l_bsc_dim_level_rec.bsc_level_short_name := p_child_dimlvl_rec.dimension_level_short_name;
  l_bsc_dim_level_rec.bsc_parent_level_short_name := p_parent_dimlvl_rec.dimension_level_short_name;

   -- check if a direct parent-child relationship exists
   BSC_DIMENSION_LEVELS_PUB.Retrieve_Relationship (
     p_Dim_Level_Rec  => l_bsc_dim_level_rec
    ,x_Dim_Level_Rec  => x_bsc_dim_rel_info_rec
    ,x_return_status  => x_return_status
    ,x_msg_count      => x_msg_count
    ,x_msg_data       => x_msg_data
   );

   IF ( ((x_return_status IS NULL) OR (x_return_status = FND_API.G_RET_STS_SUCCESS)) AND (x_bsc_dim_rel_info_rec.bsc_level_short_name IS NOT NULL) ) THEN -- This shows that relationship exists
     x_is_relationship_found := FND_API.G_TRUE;
     -- if parent child, then check for recursive relationship
     IF ( UPPER(p_child_dimlvl_rec.dimension_level_short_name) = UPPER(p_parent_dimlvl_rec.dimension_level_short_name) ) THEN
       x_is_relation_recursive := FND_API.G_TRUE;
     END IF;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
  NULL;
END get_bsc_relationship_data;
--===================================================================
/* bug# 4699787
 * For pre-seeded relationships, do not append the dynamic where clause
 * for parent-child relationship.
 * bsc_sys_dim_level_rels does not have WHO columns.
 */
FUNCTION is_append_where_clause(
  p_dim_rel_info_rec      IN bis_pmf_get_dimlevels_pub.dim_rel_info_rec
 ,p_is_relation_recursive IN VARCHAR2
) RETURN BOOLEAN
IS
  l_created_by NUMBER;
  l_created_by_parent NUMBER;
BEGIN
  SELECT created_by INTO l_created_by FROM bis_levels WHERE short_name = p_dim_rel_info_rec.dimension_level_short_name;

  IF ((p_dim_rel_info_rec.parent_level_short_name IS NOT NULL) AND (p_is_relation_recursive IS NULL OR p_is_relation_recursive = FND_API.G_FALSE)) THEN
    SELECT created_by INTO l_created_by_parent FROM bis_levels WHERE short_name = p_dim_rel_info_rec.parent_level_short_name;
  ELSE
    l_created_by_parent := l_created_by;
  END IF;
 --Followed the logic from AFLDUTLB.pls
  IF (l_created_by IN ('1', '2', '120','121','122','123','124','125','126','127','128','129') AND l_created_by_parent IN ('1', '2', '120','121','122','123','124','125','126','127','128','129')) THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
  RETURN FALSE;
END;

--===================================================================
/**
 * Returns the source from bis_levels table, given the
 * dim level short name
 */
----=================================================================
FUNCTION get_source (
  p_dim_level_short_name IN VARCHAR2
) RETURN VARCHAR2
IS
  l_source BIS_LEVELS.SOURCE%TYPE;
  CURSOR c_dim_source(cp_dimLevelName IN bis_levels.source%TYPE) IS
    SELECT source
    FROM  bis_levels
    WHERE short_name = cp_dimLevelName ;
BEGIN

  IF ( c_dim_source%ISOPEN) THEN
    CLOSE c_dim_source;
  END IF;

  OPEN c_dim_source(cp_DimLevelName => p_dim_level_short_name );
  FETCH c_dim_source INTO l_source ;
  IF (c_dim_source%NOTFOUND) THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_INAVLID_LEVEL_SHORT_NAME');
      FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_dim_level_short_name);
      FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_dim_source;

  RETURN l_source;

EXCEPTION
  WHEN OTHERS THEN
  IF ( c_dim_source%ISOPEN) THEN
    CLOSE c_dim_source;
  END IF;
  RAISE FND_API.G_EXC_ERROR;
END get_source;

--=================================================================
FUNCTION needs_time_cols (
   p_source       IN bis_levels.source%TYPE
  ,p_data_source  IN bis_levels.level_values_view_name%TYPE
  ,p_lvlshortname IN bis_levels.short_name%TYPE
  ,p_dimshortname IN bis_dimensions.short_name%TYPE
) RETURN BOOLEAN
IS
  l_dimshortname_time   bis_dimensions.short_name%TYPE;
  l_lvlshortname_total  bis_levels.short_name%TYPE;
BEGIN
  IF p_source IS NOT NULL THEN
    l_dimshortname_time  := BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME_SRC(p_source => p_source);

    IF ((p_source = 'EDW') AND (p_data_source IS NULL)) THEN
      l_lvlshortname_total := BIS_UTILITIES_PVT.GET_TOTAL_DIMLEVEL_NAME_SRC(p_dim_short_name=>p_dimshortname
                                                                         ,p_source => p_source
                                             );
    END IF;
  ELSE -- if source is null, it is oltp case
    l_dimshortname_time := BIS_UTILITIES_PVT.GET_TIME_DIMENSION_NAME(p_DimLevelId => NULL
                                                                    ,p_DimLevelName =>p_lvlshortname
                                                                    );
  END IF;

  IF (p_source = 'EDW' AND p_data_source IS NULL) THEN
    IF ((p_dimshortname = l_dimshortname_time) AND (p_lvlshortname <> l_lvlshortname_total)) THEN
      RETURN TRUE;
    END IF;
  ELSE -- oltp case
    IF (p_dimshortname = l_dimshortname_time) THEN
      RETURN TRUE;
    END IF;
  END IF;

  RETURN FALSE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END needs_time_cols;

--======================================================================
PROCEDURE get_oltp_edw_cols (
   p_Dim_Level_Short_Name IN VARCHAR2
  ,p_Source IN VARCHAR2
  ,x_Table_Name OUT NOCOPY VARCHAR2
  ,x_Id_Name OUT NOCOPY VARCHAR2
  ,x_Value_Name OUT NOCOPY VARCHAR2
  ,x_return_status OUT NOCOPY VARCHAR2
  ,x_msg_count OUT NOCOPY NUMBER
  ,x_msg_data OUT NOCOPY VARCHAR2
) IS
  CURSOR c_bis_levels_source (cp_dimLevel_short_name IN bis_levels.short_name%TYPE) IS
    SELECT level_values_view_name
    FROM  bis_levels
    WHERE short_name = cp_dimLevel_short_name ;

  l_select_string VARCHAR2(1000);
  l_time_level VARCHAR2(100);
  l_data_source BIS_LEVELS.level_values_view_name%TYPE;

  /* 3388371- gbhaloti FOR BSC LEVELS */
  --l_bsc_source VARCHAR(10);
BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  /* 3388371- gbhaloti FOR BSC LEVELS */
  --l_bsc_source := get_dim_level_source (p_Dim_Level_Short_Name);

  IF ( c_bis_levels_source%ISOPEN) THEN
    CLOSE c_bis_levels_source;
  END IF;

  OPEN c_bis_levels_source(cp_dimLevel_short_name => p_Dim_Level_Short_Name );
  FETCH c_bis_levels_source INTO l_data_source ;
  IF (c_bis_levels_source%NOTFOUND) THEN
    FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_LEVEL_SHORTNAME');
    FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_Dim_Level_Short_Name);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_bis_levels_source;

  IF ((p_Source = G_EDW) AND (l_data_source  IS NULL)) THEN
    BIS_PMF_GET_DIMLEVELS_PVT.GET_EDW_SELECT_STRING
      (p_dim_level_name    => p_Dim_Level_Short_Name
      ,p_source            => p_Source
      ,x_table_name        => x_table_name
      ,x_id_name           => x_id_name
      ,x_value_name        => x_value_name
      ,x_edw_select_String => l_Select_String
      ,x_time_level        => l_time_level
      ,x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
    );

  ELSE
    IF (l_data_source IS NULL) THEN -- check - should use existing API
      FND_MESSAGE.SET_NAME('BIS','BIS_PMF_NULL_DATA_SOURCE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    x_id_name := G_ID_NAME;
    x_value_name := G_VALUE_NAME;
    x_table_name := l_data_source;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF ( c_bis_levels_source%ISOPEN) THEN
      CLOSE c_bis_levels_source;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF ( c_bis_levels_source%ISOPEN) THEN
      CLOSE c_bis_levels_source;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
    ( p_count    =>    x_msg_count,
      p_data     =>    x_msg_data
    );
  WHEN OTHERS THEN
    IF ( c_bis_levels_source%ISOPEN) THEN
      CLOSE c_bis_levels_source;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
       FND_MSG_PUB.Add_Exc_Msg
       (G_PKG_NAME,
        'GET_OLTP_EDW_COLS'
       );
    END IF;
    FND_MSG_PUB.Count_And_Get
    (p_count    =>    x_msg_count,
     p_data     =>    x_msg_data
    );
END get_oltp_edw_cols;

--===================================================================
/**
 * Returns the source from bsc_sys_dim_levels_b table, given the
 * dim level short name
 */
----=================================================================
FUNCTION get_dim_level_source (
  p_dim_level_short_name IN VARCHAR2
) RETURN VARCHAR2
IS
  l_source BSC_SYS_DIM_LEVELS_B.SOURCE%TYPE;
  CURSOR c_dim_source(cp_dimLevelName IN VARCHAR2) IS
    SELECT source
    FROM  bsc_sys_dim_levels_b
    WHERE short_name = cp_dimLevelName ;
BEGIN

  IF ( c_dim_source%ISOPEN) THEN
    CLOSE c_dim_source;
  END IF;

  OPEN c_dim_source(cp_DimLevelName => p_dim_level_short_name );
  FETCH c_dim_source INTO l_source ;
  IF (c_dim_source%NOTFOUND) THEN
      FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_LEVEL_SHORTNAME');
      FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', p_dim_level_short_name);
      FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_dim_source;

  RETURN l_source;

EXCEPTION
  WHEN OTHERS THEN
  IF ( c_dim_source%ISOPEN) THEN
    CLOSE c_dim_source;
  END IF;
  RAISE FND_API.G_EXC_ERROR;
END get_dim_level_source;


PROCEDURE Get_Bsc_Dim_Obj_details
(
   p_dim_rel_info_rec       IN          bis_pmf_get_dimlevels_pub.dim_rel_info_rec
  ,p_region_code            IN          ak_regions.region_code%TYPE
  ,x_child_level_pk_col     OUT NOCOPY  BSC_SYS_DIM_LEVELS_B.LEVEL_PK_COL%TYPE
  ,x_child_level_view_name  OUT NOCOPY  BSC_SYS_DIM_LEVELS_B.LEVEL_VIEW_NAME%TYPE
  ,x_parent_level_pk_col    OUT NOCOPY  BSC_SYS_DIM_LEVELS_B.LEVEL_PK_COL%TYPE
  ,x_parent_level_view_name OUT NOCOPY  BSC_SYS_DIM_LEVELS_B.LEVEL_VIEW_NAME%TYPE
  ,x_return_status          OUT NOCOPY  VARCHAR2
  ,x_msg_count              OUT NOCOPY  NUMBER
  ,x_msg_data               OUT NOCOPY  VARCHAR2

) IS
  CURSOR c_bsc_level_metadata(cp_dimlevelSN IN BSC_SYS_DIM_LEVELS_B.SHORT_NAME%TYPE) IS
  SELECT level_pk_col
        ,level_view_name
  FROM   bsc_sys_dim_levels_vl
  WHERE  short_name = cp_dimlevelSN;

  --/////////////////Added for Simulation Tree  Enhancement for supporting filter views ////////////

  CURSOR c_bsc_obj_dim_level_metadata(cp_dimlevelSN IN BSC_KPI_DIM_LEVELS_VL.LEVEL_SHORTNAME%TYPE,cp_objId IN BSC_KPIS_B.INDICATOR%TYPE) IS
  SELECT level_pk_col
        ,level_view_name
  FROM   bsc_kpi_dim_levels_vl
  WHERE  indicator = cp_objId
  AND    level_shortname =cp_dimlevelSN;

  --//Not filtering for simulation objectives,because we can use it for AG reports also
  --//if we open up filters for AG reports.

  CURSOR c_kpi_cur IS
  SELECT indicator
  FROM   bsc_kpis_b
  WHERE  short_name = p_region_code;


  l_dimlevel_short_name         BSC_SYS_DIM_LEVELS_B.SHORT_NAME%TYPE;
  l_parent_dimlevel_short_name  BSC_SYS_DIM_LEVELS_B.SHORT_NAME%TYPE;
  l_relation_type               BSC_SYS_DIM_LEVEL_RELS.RELATION_TYPE%TYPE;
  l_child_level_pk_col          BSC_SYS_DIM_LEVELS_B.LEVEL_PK_COL%TYPE;
  l_child_level_view_name       BSC_SYS_DIM_LEVELS_B.LEVEL_VIEW_NAME%TYPE;
  l_parent_level_pk_col         BSC_SYS_DIM_LEVELS_B.LEVEL_PK_COL%TYPE;
  l_parent_level_view_name      BSC_SYS_DIM_LEVELS_B.LEVEL_VIEW_NAME%TYPE;
  l_restrict_all_value          VARCHAR2(100);

  l_region_code                 ak_regions.region_code%TYPE;
  l_indicator                   bsc_kpis_b.indicator%TYPE;
  l_count                       NUMBER :=0;

BEGIN
    FND_MSG_PUB.INITIALIZE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_dimlevel_short_name := p_dim_rel_info_rec.dimension_level_short_name;
    l_parent_dimlevel_short_name := p_dim_rel_info_rec.parent_level_short_name;
    l_relation_type := p_dim_rel_info_rec.relation_type;


    l_region_code := p_region_code;

    FOR cd IN c_kpi_cur LOOP
      l_indicator := cd.indicator;
    END LOOP;

    IF (c_bsc_obj_dim_level_metadata%ISOPEN) THEN
     CLOSE c_bsc_obj_dim_level_metadata;
    END IF;

    OPEN c_bsc_obj_dim_level_metadata(l_dimlevel_short_name,l_indicator);
    FETCH c_bsc_obj_dim_level_metadata INTO l_child_level_pk_col, l_child_level_view_name;
    CLOSE c_bsc_obj_dim_level_metadata;


    IF(l_region_code IS NULL OR l_child_level_view_name IS NULL) THEN
     -- BSC types will be handled using the table names from bsc data model and using the datasource as a subquery
     -- for a id, value, parent_id SQL.
       IF (c_bsc_level_metadata%ISOPEN) THEN
         CLOSE c_bsc_level_metadata;
       END IF;

       OPEN c_bsc_level_metadata(l_dimlevel_short_name);
       FETCH c_bsc_level_metadata INTO l_child_level_pk_col, l_child_level_view_name;
       IF (c_bsc_level_metadata%NOTFOUND) THEN
         FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_LEVEL_SHORTNAME');
         FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', l_dimlevel_short_name);
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE c_bsc_level_metadata;

       IF (l_parent_dimlevel_short_name IS NOT NULL) THEN
         OPEN c_bsc_level_metadata(l_parent_dimlevel_short_name);
         FETCH c_bsc_level_metadata INTO l_parent_level_pk_col, l_parent_level_view_name;
         IF (c_bsc_level_metadata%NOTFOUND) THEN
           FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_LEVEL_SHORTNAME');
           FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', l_parent_dimlevel_short_name);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE c_bsc_level_metadata;
       END IF;
    ELSE
       IF (l_parent_dimlevel_short_name IS NOT NULL) THEN
         OPEN c_bsc_obj_dim_level_metadata(l_parent_dimlevel_short_name,l_indicator);
         FETCH c_bsc_obj_dim_level_metadata INTO l_parent_level_pk_col, l_parent_level_view_name;
         IF (c_bsc_obj_dim_level_metadata%NOTFOUND) THEN
           FND_MESSAGE.SET_NAME('BIS','BIS_INVALID_LEVEL_SHORTNAME');
           FND_MESSAGE.SET_TOKEN('DIMLEVEL_SHORT_NAME', l_parent_dimlevel_short_name);
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
         CLOSE c_bsc_obj_dim_level_metadata;
       END IF;
    END IF;

    x_child_level_pk_col    := l_child_level_pk_col;
    x_child_level_view_name := l_child_level_view_name;
    x_parent_level_pk_col   := l_parent_level_pk_col ;
    x_parent_level_view_name:= l_parent_level_view_name;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (c_bsc_level_metadata%ISOPEN) THEN
      CLOSE c_bsc_level_metadata;
    END IF;
    IF (c_bsc_obj_dim_level_metadata%ISOPEN) THEN
      CLOSE c_bsc_obj_dim_level_metadata;
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    IF (c_bsc_level_metadata%ISOPEN) THEN
      CLOSE c_bsc_level_metadata;
    END IF;
    IF (c_bsc_obj_dim_level_metadata%ISOPEN) THEN
      CLOSE c_bsc_obj_dim_level_metadata;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);

END Get_Bsc_Dim_Obj_details;


--======================================================================

END BIS_PMF_GET_DIMLEVELS_PVT;

/
