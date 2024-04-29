--------------------------------------------------------
--  DDL for Package BIS_DIMENSION_LEVEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_DIMENSION_LEVEL_PUB" AUTHID CURRENT_USER AS
/* $Header: BISPDMLS.pls 120.4 2006/01/06 03:25:49 akoduri noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPDMLS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     PUB.lic API for managing dimension levels for the
REM |     Key Performance Framework.
REM |
REM |     This package should be maintaind by EDW once it gets integrated
REM |     with BIS.
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 05-DEC-98 irchen   Creation
REM | 01-FEB-99 ansingha added required dimension api
REM | 25-JUL-02 jxyu     Modified for enhancement #2435226
REM |             Added Comparison_Label_Code for TYPE Dimension_Level_Rec_Type
REM | 20-FEB-03 PAJOHRI  Added Procedure Update_Dimension_Level             |
REM | 24-NOV-02 mahrao   Modified for enhancement #2668271
REM |             Added Attribute_Code for TYPE Dimension_Level_Rec_Type
REM | 17-MAR-03  PAJOHRI        Added procedures    DELETE_DIMENSION_LEVEL  |
REM |                                               CREATE_DIMENSION_LEVEL  |
REM | 17-MAR-03  PAJOHRI        Added Application_id for TYPE               |
REM |                                              Dimension_Level_Rec_Type |
REM | 13-JUN-03    MAHRAO       Added Procedure     Load_Dimension_Level    |
REM | 26-JUN-03 RCHANDRA  do away with hard coded length for name and       |
REM |                      description for bug 2910316                      |
REM |                      for dimension and dimension levels               |
REM | 10-JUL-2003 mahrao  bug#3042968 Added extra parameter to              |
REM |                                 Load_Dimension_Level                  |
REM | 29-OCT-03    MAHRAO enh of adding new attributes to dim objects       |
REM | 14-NOV-03    RCHANDRA enh  2997632, customization APIs                |
REM | arhegde 07/23/2004   bug# 3760735 dim object caching.                 |
REM | ankgoel 29-SEP-2004  Added WHO columns in Rec for Bug#3891748         |
REM | 21-DEC-04   vtulasi   Modified for bug#4045278 - Addtion of LUD       |
REM | 08-Feb-04   skchoudh  Enh#3873195 drill_to_form_function column       |
REM |                  is added                                             |
REM | 08-Feb-05   ankgoel   Enh#4172034 DD Seeding by Product Teams         |
REM | 21-Jun-05   ankgoel   Bug#4437121 bisdimld/v.ldt compatible in 409    |
REM | 07-NOV-05   akoduri   Bug#4696105,Added overloaded API                |
REM |                       get_customized_enabled                          |
REM | 12-Dec-05   ankgoel   Enh#4640165 - Select dim objects from Report    |
REM | 01-Jan-06   akoduri   Enh#4739401 - Hide Dimensions/Dim Objects       |
REM +=======================================================================+
*/
--
-- Data Types: Records
--
C_PARENT CONSTANT VARCHAR2(2) := 'P';
C_SIBLING CONSTANT VARCHAR2(2) := 'S';
C_NO_REL CONSTANT VARCHAR2(2) := 'R';
C_NO_MASTER CONSTANT VARCHAR2(2) := 'M';

TYPE Dimension_Level_Rec_Type IS RECORD
( Dimension_ID               NUMBER
, Dimension_Short_Name       VARCHAR2(30)
, Dimension_Name             bis_dimensions_tl.name%TYPE
, Dimension_Level_ID         NUMBER
, Dimension_Level_Short_Name VARCHAR2(30)
, Dimension_Level_Name       bis_levels_tl.name%TYPE
, Description                bis_levels_tl.Description%TYPE
, Level_Values_View_Name     VARCHAR2(30)
, where_Clause               VARCHAR2(2000)
, source                     VARCHAR2(30)
, Comparison_Label_Code      VARCHAR2(30)
, Attribute_Code             VARCHAR2(30)
, Application_ID             BIS_LEVELS.Application_Id%TYPE
, default_search             BIS_LEVELS.default_search%TYPE
, Long_Lov                   BIS_LEVELS.Long_Lov%TYPE
, Master_Level               BIS_LEVELS.Master_Level%TYPE
, View_Object_Name           BIS_LEVELS.View_Object_Name%TYPE
, Default_Values_Api         BIS_LEVELS.Default_Values_Api%TYPE
, Enabled                    BIS_LEVELS.Enabled%TYPE
, Drill_To_Form_Function     BIS_LEVELS.DRILL_TO_FORM_FUNCTION%TYPE
, Language                   BIS_LEVELS_TL.Language%TYPE
, Source_Lang                BIS_LEVELS_TL.Source_Lang%TYPE
-- ankgoel: bug#3891748
, Created_By                 BIS_LEVELS.CREATED_BY%TYPE
, Creation_Date              BIS_LEVELS.CREATION_DATE%TYPE
, Last_Updated_By            BIS_LEVELS.LAST_UPDATED_BY%TYPE
, Last_Update_Date           BIS_LEVELS.LAST_UPDATE_DATE%TYPE
, Last_Update_Login          BIS_LEVELS.LAST_UPDATE_LOGIN%TYPE
-- ankgoel: enh#4172034
, Primary_Dim                VARCHAR2(1) := FND_API.G_TRUE
, Hide                       BIS_LEVELS.HIDE_IN_DESIGN%TYPE := FND_API.G_FALSE
);
--
-- Data Types: Tables
--
TYPE Dimension_Level_Tbl_Type IS TABLE of Dimension_Level_Rec_Type
INDEX BY BINARY_INTEGER;
--
--
Procedure Retrieve_Dimension_Levels
( p_api_version         IN  NUMBER
, p_Dimension_Rec       IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_Dimension_Level_Tbl OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Retrieve_Dimension_Level
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dimension_Level_Rec IN OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Translate_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_OWNER               IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
Procedure Load_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_OWNER               IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
, p_force_mode          IN  BOOLEAN := FALSE
);
--
--
PROCEDURE Update_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2    := FND_API.G_FALSE
, p_validation_level    IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY  VARCHAR2
, x_error_Tbl           OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Create_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2    := FND_API.G_FALSE
, p_validation_level    IN  NUMBER      := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY  VARCHAR2
, x_error_Tbl           OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Delete_Dimension_Level
(
    p_commit                IN          VARCHAR2 := FND_API.G_FALSE
  , p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
  , p_Dimension_Level_Rec   IN          BIS_Dimension_Level_PUB.Dimension_Level_Rec_Type
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
PROCEDURE Load_Dimension_Level (
  p_Commit IN VARCHAR2 := FND_API.G_FALSE
 ,p_Dim_Grp_Rec IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
 ,p_Bsc_Pmf_Dim_Rec IN BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
 ,p_Bsc_Dim_Level_Rec IN BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_msg_count OUT NOCOPY NUMBER
 ,x_msg_data OUT NOCOPY VARCHAR2
 ,p_force_mode IN  BOOLEAN := FALSE
);
--

PROCEDURE Trans_DimObj_By_Given_Lang
(
      p_commit                IN          VARCHAR2 := FND_API.G_FALSE
  ,   p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,   p_Dimension_Level_Rec   IN          BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
  ,   x_return_status         OUT NOCOPY  VARCHAR2
  ,   x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
--=============================================================================
Procedure Retrieve_Dimension_Level_Wrap
( p_dim_level_short_name IN VARCHAR2
, p_master_dim_level_short_name IN VARCHAR2
, p_dim_short_name IN VARCHAR2
, x_dim_level_name OUT NOCOPY VARCHAR2
, x_dim_level_desc OUT NOCOPY VARCHAR2
, x_default_search OUT NOCOPY VARCHAR2
, x_long_lov OUT NOCOPY VARCHAR2
, x_master_level OUT NOCOPY VARCHAR2
, x_is_related_by_master OUT NOCOPY VARCHAR2
, x_view_object_name OUT NOCOPY VARCHAR2
, x_default_values_api OUT NOCOPY VARCHAR2
, x_enabled OUT NOCOPY VARCHAR2
, x_hide OUT NOCOPY VARCHAR2
, x_dim_group_id OUT NOCOPY  NUMBER
, x_dim_level_id OUT NOCOPY  NUMBER
, x_dim_level_index OUT NOCOPY  NUMBER
, x_total_flag OUT NOCOPY  NUMBER
, x_total_disp_name OUT NOCOPY  VARCHAR2
, x_dim_level_where_clause OUT NOCOPY VARCHAR2
, x_comparison_flag OUT NOCOPY  NUMBER
, x_comp_disp_name OUT NOCOPY  VARCHAR2
, x_filter_column OUT NOCOPY  VARCHAR2
, x_filter_value OUT NOCOPY  NUMBER
, x_default_value OUT NOCOPY  VARCHAR2
, x_default_type OUT NOCOPY  NUMBER
, x_parent_in_total OUT NOCOPY  NUMBER
, x_no_items OUT NOCOPY  NUMBER
, x_pmf_dim_id OUT NOCOPY  NUMBER
, x_pmf_dim_level_id OUT NOCOPY  NUMBER
, x_comparison_label_code OUT NOCOPY VARCHAR2
, x_level_values_view_name OUT NOCOPY VARCHAR2
, x_source OUT NOCOPY VARCHAR2
, x_attribute_code OUT NOCOPY VARCHAR2
, x_application_id OUT NOCOPY NUMBER
, x_drill_to_form_function OUT NOCOPY VARCHAR2
, x_dim_name OUT NOCOPY VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
, x_msg_count OUT NOCOPY VARCHAR2
, x_msg_data OUT NOCOPY VARCHAR2
);

--=============================================================================
-- get customized values for name , description and enabled
FUNCTION get_customized_name( p_dim_level_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_customized_description( p_dim_level_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_customized_enabled( p_dim_level_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_customized_enabled( p_dim_level_sht_name IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE validate_disabling (p_dim_level_id IN NUMBER);

Procedure Retrieve_Dim_Level_Cust_Wrap
( p_dim_level_short_name    IN VARCHAR2
, p_dim_short_name          IN VARCHAR2
, x_dim_level_cust_name    OUT NOCOPY VARCHAR2
, x_dim_level_cust_desc    OUT NOCOPY VARCHAR2
, x_dim_level_cust_enabled OUT NOCOPY VARCHAR2
);
--

Procedure Load_Dimension_Level_Wrapper
( p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_Dim_Grp_Rec         IN  BSC_DIMENSION_GROUPS_PUB.Bsc_Dim_Group_Rec_Type
, p_Bsc_Pmf_Dim_Rec     IN  BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
, p_Bsc_Dim_Level_Rec   IN  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
, p_Owner               IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, p_force_mode          IN  BOOLEAN := FALSE
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
);
--
Procedure Translate_Dim_Level_Wrapper
( p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_Bsc_Pmf_Dim_Rec     IN  BSC_PMF_UI_API_PUB.Bsc_Pmf_Dim_Rec_Type
, p_Bsc_Dim_Level_Rec   IN  BSC_DIMENSION_LEVELS_PUB.Bsc_Dim_Level_Rec_Type
, p_Owner               IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
);
--

PROCEDURE Update_Dim_Obj_Obsolete_Flag (
    p_commit                      IN VARCHAR2 := FND_API.G_FALSE,
    p_dim_obj_short_name          IN VARCHAR2,
    p_hide                        IN VARCHAR2,
    x_return_status               OUT nocopy VARCHAR2,
    x_Msg_Count                   OUT NOCOPY NUMBER,
    x_msg_data                    OUT nocopy VARCHAR2
);


END BIS_DIMENSION_LEVEL_PUB;

 

/
