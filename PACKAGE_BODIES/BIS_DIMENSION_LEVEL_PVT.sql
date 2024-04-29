--------------------------------------------------------
--  DDL for Package Body BIS_DIMENSION_LEVEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_DIMENSION_LEVEL_PVT" AS
/* $Header: BISVDMLB.pls 120.3 2006/01/06 03:34:31 akoduri noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVDMLB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for managing dimension levels for the
REM |     Key Performance Framework.
REM |
REM |     This package should be maintaind by EDW once it gets integrated
REM |     with BIS.
REM |
REM | NOTES                                                                 |
REM |    juwang 15-APR-2002 Retrieve_Dimension_Level added source column    |
REM |    25-JUL-2002    jxyu   Modified for enhancement #2435226            |
REM |    21-OCT-02 arhegde Added retrieve_mult_dim_levels                   |
REM | 27-JAN-03 arhegde For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)                            |
REM | 24-NOV-02    MAHRAO     Modified for enhancement #2668271             |
REM | 23-FEB-03    PAJOHRI    Added procedures      DELETE_DIMENSION_LEVEL  |
REM | 23-FEB-03    PAJOHRI    Modified the package, to handle Application_ID|
REM | 29-OCT-03    MAHRAO enh of adding new attributes to dim objects       |
REM | 15-NOV-03    RCHANDRA enh 2997632 , added methods to check if it is   |
REM |                       ok to disable a dimension level                 |
REM | 25-NOV-03    ADEULGAO fixed Bug#3266503                               |
REM | 01-DEC-03    ADRAO Fixed Bug #3266561  Removed an additional check    |
REM |              to default Comparison_Label_Code & Default_Search to null|
REM |              if passed as null from UI                                |
REM | 25-JUN-04    ANKGOEL  Modified for bug#3567463                        |
REM | 30-Jul-04   rpenneru  Modified for enhancemen#3748519                 |
REM | 29-SEP-2004 ankgoel   Added WHO columns in Rec for Bug#3891748        |
REM | 21-DEC-04   vtulasi   Modified for bug#4045278 - Addtion of LUD       |
REM | 08-Feb-04   skchoudh  Enh#3873195 drill_to_form_function column       |
REM |                  is added                                             |
REM | 08-Feb-05   ankgoel   Enh#4172034 DD Seeding by Product Teams         |
REM | 26-Sep-05   ankgoel   Bug#4625611 - enable all BSC type dim objects   |
REM | 07-NOV-05   akoduri   Bug#4696105,Added overloaded API                |
REM |                       get_customized_enabled                          |
REM | 06-Jan-06   akoduri   Enh#4739401 - Hide Dimensions/Dim Objects       |
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_DIMENSION_LEVEL_PVT';

TYPE bind_variables_tbl_type IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

-- private functions
FUNCTION isPMFDimensionLevel(p_dim_level_id IN NUMBER) RETURN BOOLEAN ;
FUNCTION  IS_TARGET_DEFINED( p_dim_level_id IN  NUMBER) RETURN BOOLEAN;
FUNCTION  IS_ASSIGNED_TO_KPI( p_dim_level_id IN  NUMBER) RETURN BOOLEAN ;
PROCEDURE validate_disabling (p_dim_level_id   IN  NUMBER
                          ,   p_error_Tbl      IN  BIS_UTILITIES_PUB.Error_Tbl_Type
                          ,   x_return_status  OUT NOCOPY  VARCHAR2
                          ,   x_error_Tbl      OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
);

--
--

PROCEDURE Create_New_Dimension_Level
( p_level_id            IN NUMBER,      -- l_id
  p_level_short_name        IN VARCHAR2,  -- l_Dimension_Rec.Dimension_Short_Name
  p_dimension_id        IN NUMBER,
  p_level_values_view_name  IN VARCHAR2,
  p_where_clause        IN VARCHAR2,
  p_source          IN VARCHAR2,
  p_created_by            IN NUMBER,    -- created_by
  p_last_updated_by       IN NUMBER,    -- last_updated_by
  p_login_id            IN NUMBER,  -- l_login_id
  p_level_name          IN VARCHAR2,    -- l_Dimension_Rec.Dimension_Name
  p_description         IN VARCHAR2,   -- l_Dimension_Rec.Description
  p_comparison_label_code   IN VARCHAR2,
  p_attribute_code          IN VARCHAR2,
  p_application_id          IN NUMBER := NULL,
  p_default_search IN VARCHAR2,
  p_long_lov IN VARCHAR2,
  p_master_level IN VARCHAR2,
  p_view_object_name IN VARCHAR2,
  p_default_values_api IN VARCHAR2,
  p_enabled IN VARCHAR2,
  p_drill_to_form_function IN VARCHAR2,
  p_last_update_date IN DATE := SYSDATE,
  p_hide IN VARCHAR2  := FND_API.G_FALSE
);
--
-- returns the record with the G_MISS_CHAR/G_MISS_NUM replaced
-- by null
--
PROCEDURE SetNULL
( p_Dimension_Level_Rec    IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dimension_Level_Rec    OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
);
--
-- queries database to retrieve the dimension level from the database
-- updates the record with the changes sent in
--
PROCEDURE UpdateRecord
( p_Dimension_Level_Rec BIS_Dimension_Level_PUB.Dimension_Level_Rec_Type
, x_Dimension_Level_Rec OUT NOCOPY BIS_Dimension_Level_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
);
--
FUNCTION Is_Level_Name_Used
(
  p_level_name        IN VARCHAR2
, p_source                IN VARCHAR2
, p_dimension_id      IN NUMBER
)
RETURN BOOLEAN;

--==================================================================
PROCEDURE retrieve_sql(
  p_all_dim_levels_tbl IN BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type
 ,x_is_bind            OUT NOCOPY BOOLEAN
 ,x_is_execute         OUT NOCOPY BOOLEAN
 ,x_sql                OUT NOCOPY VARCHAR2
 ,x_bind_variables_tbl OUT NOCOPY bind_variables_tbl_type
);

--==================================================================
--
PROCEDURE SetNULL
( p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dimension_Level_Rec OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
)
IS
BEGIN

  x_dimension_level_rec.Dimension_ID
    := BIS_UTILITIES_PVT.CheckMissNum(p_dimension_level_rec.Dimension_ID);
  x_dimension_level_rec.Dimension_Short_Name
    := BIS_UTILITIES_PVT.CheckMissChar(
                         p_dimension_level_rec.Dimension_Short_Name);
  x_dimension_level_rec.Dimension_Name
    := BIS_UTILITIES_PVT.CheckMissChar(
                         p_dimension_level_rec.Dimension_Name);

  x_dimension_level_rec.Dimension_Level_ID
    := BIS_UTILITIES_PVT.CheckMissNum(
                         p_dimension_level_rec.Dimension_Level_ID);
  x_dimension_level_rec.Dimension_Level_Short_Name
    := BIS_UTILITIES_PVT.CheckMissChar(
                         p_dimension_level_rec.Dimension_Level_Short_Name);
  x_dimension_level_rec.Dimension_Level_Name
    := BIS_UTILITIES_PVT.CheckMissChar(
                         p_dimension_level_rec.Dimension_Level_Name);
  x_dimension_level_rec.Description
    := BIS_UTILITIES_PVT.CheckMissChar(p_dimension_level_rec.Description);
  x_dimension_level_rec.Level_Values_View_Name
    := BIS_UTILITIES_PVT.CheckMissChar(
                         p_dimension_level_rec.Level_Values_View_Name);
  x_dimension_level_rec.where_Clause
    := BIS_UTILITIES_PVT.CheckMissChar(p_dimension_level_rec.where_Clause);
  x_dimension_level_rec.source
    := BIS_UTILITIES_PVT.CheckMissChar(p_dimension_level_rec.source);
  --jxyu added for #2435226
  x_dimension_level_rec.Comparison_Label_Code
    := BIS_UTILITIES_PVT.CheckMissChar(p_dimension_level_rec.Comparison_Label_Code);
  x_dimension_level_rec.Attribute_Code
    := BIS_UTILITIES_PVT.CheckMissChar(p_dimension_level_rec.Attribute_Code);
  x_dimension_level_rec.Application_ID
    := BIS_UTILITIES_PVT.CheckMissNum(p_dimension_level_rec.Application_ID);
  x_dimension_level_rec.default_search
    := BIS_UTILITIES_PVT.CheckMissChar(p_dimension_level_rec.default_search);
  x_dimension_level_rec.Long_Lov
    := BIS_UTILITIES_PVT.CheckMissChar(p_dimension_level_rec.Long_Lov);
  x_dimension_level_rec.Master_Level
    := BIS_UTILITIES_PVT.CheckMissChar(p_dimension_level_rec.Master_Level);
  x_dimension_level_rec.View_Object_Name
    := BIS_UTILITIES_PVT.CheckMissChar(p_dimension_level_rec.View_Object_Name);
  x_dimension_level_rec.Default_Values_Api
    := BIS_UTILITIES_PVT.CheckMissChar(p_dimension_level_rec.Default_Values_Api);
  x_dimension_level_rec.Enabled
    := BIS_UTILITIES_PVT.CheckMissChar(p_dimension_level_rec.Enabled);
  x_dimension_level_rec.Drill_To_Form_Function
    := BIS_UTILITIES_PVT.CheckMissChar(p_dimension_level_rec.Drill_To_Form_Function);
  x_dimension_level_rec.Hide
    := BIS_UTILITIES_PVT.CheckMissChar(p_dimension_level_rec.Hide);
  x_dimension_level_rec.Created_By := BIS_UTILITIES_PVT.CheckMissNum(p_dimension_level_rec.Created_By);
  x_dimension_level_rec.Creation_Date := BIS_UTILITIES_PVT.CheckMissDate(p_dimension_level_rec.Creation_Date);
  x_dimension_level_rec.Last_Updated_By := BIS_UTILITIES_PVT.CheckMissNum(p_dimension_level_rec.Last_Updated_By);
  x_dimension_level_rec.Last_Update_Date := BIS_UTILITIES_PVT.CheckMissDate(p_dimension_level_rec.Last_Update_Date);
  x_dimension_level_rec.Last_Update_Login := BIS_UTILITIES_PVT.CheckMissNum(p_dimension_level_rec.Last_Update_Login);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE
    ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END SetNULL;
--
PROCEDURE UpdateRecord
( p_Dimension_Level_Rec BIS_Dimension_Level_PUB.Dimension_Level_Rec_Type
, x_Dimension_Level_Rec OUT NOCOPY BIS_Dimension_Level_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
  l_Dimension_Level_Rec BIS_Dimension_Level_PUB.Dimension_Level_Rec_Type;
  l_return_status       VARCHAR2(10);
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN

  -- retrieve record from db
  BIS_Dimension_Level_PVT.Retrieve_Dimension_Level
  ( p_api_version         => 1.0
  , p_Dimension_Level_Rec => p_Dimension_Level_Rec
  , x_Dimension_Level_Rec => l_Dimension_Level_Rec
  , x_return_status       => l_return_status
  , x_error_Tbl           => x_error_Tbl
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- apply changes

  -- Primary dimension starts
  IF( (BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Rec.Dimension_ID) = FND_API.G_TRUE) AND (p_Dimension_Level_Rec.Primary_Dim = FND_API.G_TRUE) ) THEN
    l_Dimension_Level_Rec.Dimension_ID  := p_Dimension_Level_Rec.Dimension_ID;
  END IF;
  --
  IF( (BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Rec.Dimension_Short_Name) = FND_API.G_TRUE) AND(p_Dimension_Level_Rec.Primary_Dim = FND_API.G_TRUE) ) THEN
    l_Dimension_Level_Rec.Dimension_Short_Name := p_Dimension_Level_Rec.Dimension_Short_Name ;
  END IF;
  --
  IF( (BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Rec.Dimension_Name) = FND_API.G_TRUE)  AND (p_Dimension_Level_Rec.Primary_Dim = FND_API.G_TRUE) ) THEN
    l_Dimension_Level_Rec.Dimension_Name := p_Dimension_Level_Rec.Dimension_Name;
  END IF;
  -- Primary dimension ends

  IF( BIS_UTILITIES_PUB.Value_Not_Missing(
                        p_Dimension_Level_Rec.Dimension_Level_ID)
      = FND_API.G_TRUE
    ) THEN
    l_Dimension_Level_Rec.Dimension_Level_ID
      := p_Dimension_Level_Rec.Dimension_Level_ID;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(
                        p_Dimension_Level_Rec.Dimension_Level_Short_Name)
      = FND_API.G_TRUE
    ) THEN
    l_Dimension_Level_Rec.Dimension_Level_Short_Name
      := p_Dimension_Level_Rec.Dimension_Level_Short_Name ;
  END IF;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(
                        p_Dimension_Level_Rec.Dimension_Level_Name)
      = FND_API.G_TRUE
    ) THEN
    l_Dimension_Level_Rec.Dimension_Level_Name
      := p_Dimension_Level_Rec.Dimension_Level_Name;
  END IF;
  --
  -- jxyu added AND condition
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Rec.Description)
      = FND_API.G_TRUE)
  AND (p_Dimension_Level_Rec.Description IS NOT NULL) THEN
    l_Dimension_Level_Rec.Description
      := p_Dimension_Level_Rec.Description;
  END IF;
  --
  -- jxyu added AND condition
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Rec.Level_Values_View_Name) = FND_API.G_TRUE)
  AND (p_Dimension_Level_Rec.Level_Values_View_Name IS NOT NULL) THEN
    l_Dimension_Level_Rec.Level_Values_View_Name
      := p_Dimension_Level_Rec.Level_Values_View_Name;
  END IF;
  --
  -- jxyu added AND condition
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Rec.where_Clause  )
      = FND_API.G_TRUE)
  AND (p_Dimension_Level_Rec.where_Clause IS NOT NULL) THEN
    l_Dimension_Level_Rec.where_Clause
      := p_Dimension_Level_Rec.where_Clause;
  END IF;
  --
  --jxyu modified the condition
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Rec.source  )
      = FND_API.G_TRUE)
  AND (p_Dimension_Level_Rec.source IS NOT NULL) THEN
    l_Dimension_Level_Rec.source
      := p_Dimension_Level_Rec.source;
  END IF;

  --jxyu added for #2435226
  -- Bug #3266561 -removed condition to default comparision to NULL when passed from UI;
  l_Dimension_Level_Rec.Comparison_Label_Code  := p_Dimension_Level_Rec.Comparison_Label_Code;

  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Rec.Attribute_Code ) = FND_API.G_TRUE)
  AND (p_Dimension_Level_Rec.Attribute_Code IS NOT NULL) THEN
    l_Dimension_Level_Rec.Attribute_Code
      := p_Dimension_Level_Rec.Attribute_Code;
  END IF;

  IF(BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Rec.Application_ID) = FND_API.G_TRUE)
  AND (p_Dimension_Level_Rec.Application_ID IS NOT NULL) THEN
    l_Dimension_Level_Rec.Application_ID := p_Dimension_Level_Rec.Application_ID;
  END IF;

  -- Bug #3266561 -removed condition to default default_search to NULL when passed from UI;
  l_Dimension_Level_Rec.default_search  := p_Dimension_Level_Rec.Default_Search;

  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Rec.Long_Lov ) = FND_API.G_TRUE)
  AND (p_Dimension_Level_Rec.Long_Lov IS NOT NULL) THEN
    l_Dimension_Level_Rec.Long_Lov
      := p_Dimension_Level_Rec.Long_Lov;
  END IF;

  l_Dimension_Level_Rec.Master_Level  := p_Dimension_Level_Rec.Master_Level;


  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Rec.View_Object_Name ) = FND_API.G_TRUE)
  AND (p_Dimension_Level_Rec.View_Object_Name IS NOT NULL) THEN
    l_Dimension_Level_Rec.View_Object_Name
      := p_Dimension_Level_Rec.View_Object_Name;
  END IF;

  -- Bug #3567463 -removed condition to default Default_Values_Api to NULL when passed from UI;
  l_Dimension_Level_Rec.Default_Values_Api := p_Dimension_Level_Rec.Default_Values_Api;

  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Rec.Enabled ) = FND_API.G_TRUE)
  AND (p_Dimension_Level_Rec.Enabled IS NOT NULL) THEN
    l_Dimension_Level_Rec.Enabled
      := p_Dimension_Level_Rec.Enabled;
  END IF;

  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Rec.Hide ) = FND_API.G_TRUE)
  AND (p_Dimension_Level_Rec.Hide IS NOT NULL) THEN
    l_Dimension_Level_Rec.Hide   := p_Dimension_Level_Rec.Hide;
  END IF;

  l_Dimension_Level_Rec.Drill_To_Form_Function := p_Dimension_Level_Rec.Drill_To_Form_Function;

  x_Dimension_Level_Rec := l_Dimension_Level_Rec;
  --
--commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
    --RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UpdateRecord;
--
--
Procedure Retrieve_Dimension_Levels
( p_api_version         IN  NUMBER
, p_Dimension_Rec       IN  BIS_DIMENSION_PUB.Dimension_Rec_Type
, x_Dimension_Level_Tbl OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_dimension_rec  BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_dim_level_rec  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  --flag to check if there is an error
  l_flag NUMBER :=0;
cursor cr_dim_id is
  select dimension_id
       , dimension_short_name
       , dimension_name
       , dimension_level_id
       , dimension_level_short_name
       , dimension_level_name
       , description
       , Level_Values_View_Name
       , where_clause
       , source
       , comparison_label_code
       , attribute_code
       , application_id
       , default_search
       , long_lov
       , master_level
       , view_object_name
       , default_values_api
       , enabled
       , drill_to_form_function
       , hide_in_design
  from bisfv_dimension_levels
  where dimension_id = p_Dimension_Rec.dimension_id;

cursor cr_dim_short_name is
  select dimension_id
       , dimension_short_name
       , dimension_name
       , dimension_level_id
       , dimension_level_short_name
       , dimension_level_name
       , description
       , Level_Values_View_Name
       , where_clause
       , source
       , comparison_label_code
       , attribute_code
       , application_id
       , default_search
       , long_lov
       , master_level
       , view_object_name
       , default_values_api
       , enabled
       , drill_to_form_function
       , hide_in_design
  from bisfv_dimension_levels
  where dimension_short_name = p_Dimension_Rec.dimension_short_name;

cursor cr_dim_name is
   select dimension_id
       , dimension_short_name
       , dimension_name
       , dimension_level_id
       , dimension_level_short_name
       , dimension_level_name
       , description
       , Level_Values_View_Name
       , where_clause
       , source
       , comparison_label_code
       , attribute_code
       , application_id
       , default_search
       , long_lov
       , master_level
       , view_object_name
       , default_values_api
       , enabled
       , drill_to_form_function
       , hide_in_design
  from bisfv_dimension_levels
  where dimension_name = p_Dimension_Rec.dimension_name;

BEGIN

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  IF BIS_UTILITIES_PUB.Value_Not_Missing(
                       p_Dimension_Rec.dimension_id)
  = FND_API.G_TRUE
  THEN

    for cr in cr_dim_id loop
      l_flag := 1;
      l_dim_level_rec.dimension_id               := cr.dimension_id;
      l_dim_level_rec.dimension_short_name       := cr.dimension_short_name;
      l_dim_level_rec.dimension_name             := cr.dimension_name;

      l_dim_level_rec.dimension_level_id         := cr.dimension_level_id;
      l_dim_level_rec.dimension_level_short_name := cr.dimension_level_short_name;
      l_dim_level_rec.dimension_level_name       := cr.dimension_level_name;
      l_dim_level_rec.description                := cr.description;
      l_dim_level_rec.level_values_view_name     := cr.level_values_view_name;
      l_dim_level_rec.where_clause               := cr.where_clause;
      l_dim_level_rec.source                     := cr.source;
      l_dim_level_rec.comparison_label_code      := cr.comparison_label_code;
      l_dim_level_rec.attribute_code             := cr.attribute_code;
      l_dim_level_rec.application_id             := cr.application_id;

      l_dim_level_rec.default_search             := cr.default_search;
      l_dim_level_rec.long_lov                   := cr.long_lov;
      l_dim_level_rec.master_level               := cr.master_level;

      l_dim_level_rec.view_object_name           := cr.view_object_name;
      l_dim_level_rec.default_values_api         := cr.default_values_api;
      l_dim_level_rec.enabled                    := cr.enabled;
      l_dim_level_rec.hide                       := cr.hide_in_design;
      l_dim_level_rec.drill_to_form_function     := cr.drill_to_form_function;
      x_dimension_level_tbl(x_dimension_level_tbl.count+1) := l_dim_level_rec;

    end loop;

  ELSIF BIS_UTILITIES_PUB.Value_Not_Missing(
                       p_Dimension_Rec.dimension_short_name)
  = FND_API.G_TRUE
  THEN

    for cr in cr_dim_short_name loop
      l_flag := 1;
      l_dim_level_rec.dimension_id               := cr.dimension_id;
      l_dim_level_rec.dimension_short_name       := cr.dimension_short_name;
      l_dim_level_rec.dimension_name             := cr.dimension_name;

      l_dim_level_rec.dimension_level_id         := cr.dimension_level_id;
      l_dim_level_rec.dimension_level_short_name := cr.dimension_level_short_name;
      l_dim_level_rec.dimension_level_name       := cr.dimension_level_name;
      l_dim_level_rec.description                := cr.description;
      l_dim_level_rec.level_values_view_name     := cr.level_values_view_name;
      l_dim_level_rec.where_clause               := cr.where_clause;
      l_dim_level_rec.source                     := cr.source;
      l_dim_level_rec.comparison_label_code      := cr.comparison_label_code;
      l_dim_level_rec.attribute_code             := cr.attribute_code;
      l_dim_level_rec.application_id             := cr.application_id;
      l_dim_level_rec.default_search             := cr.default_search;
      l_dim_level_rec.long_lov                   := cr.long_lov;
      l_dim_level_rec.master_level               := cr.master_level;
      l_dim_level_rec.view_object_name           := cr.view_object_name;
      l_dim_level_rec.default_values_api         := cr.default_values_api;
      l_dim_level_rec.enabled                    := cr.enabled;
      l_dim_level_rec.hide                       := cr.hide_in_design;
      l_dim_level_rec.drill_to_form_function     := cr.drill_to_form_function;

      x_dimension_level_tbl(x_dimension_level_tbl.count+1) := l_dim_level_rec;

    end loop;
  ELSIF BIS_UTILITIES_PUB.Value_Not_Missing(
                       p_Dimension_Rec.dimension_name)
  = FND_API.G_TRUE
  THEN

    for cr in cr_dim_name loop
      l_flag := 1;
      l_dim_level_rec.dimension_id               := cr.dimension_id;
      l_dim_level_rec.dimension_short_name       := cr.dimension_short_name;
      l_dim_level_rec.dimension_name             := cr.dimension_name;

      l_dim_level_rec.dimension_level_id         := cr.dimension_level_id;
      l_dim_level_rec.dimension_level_short_name := cr.dimension_level_short_name;
      l_dim_level_rec.dimension_level_name       := cr.dimension_level_name;
      l_dim_level_rec.description                := cr.description;
      l_dim_level_rec.level_values_view_name     := cr.level_values_view_name;
      l_dim_level_rec.where_clause               := cr.where_clause;
      l_dim_level_rec.source                     := cr.source;
      l_dim_level_rec.comparison_label_code      := cr.comparison_label_code;
      l_dim_level_rec.attribute_code             := cr.attribute_code;
      l_dim_level_rec.application_id             := cr.application_id;
      l_dim_level_rec.default_search             := cr.default_search;
      l_dim_level_rec.long_lov                   := cr.long_lov;
      l_dim_level_rec.master_level               := cr.master_level;
      l_dim_level_rec.view_object_name           := cr.view_object_name;
      l_dim_level_rec.default_values_api         := cr.default_values_api;
      l_dim_level_rec.enabled                    := cr.enabled;
      l_dim_level_rec.hide                       := cr.hide_in_design;
      l_dim_level_rec.drill_to_form_function     := cr.drill_to_form_function;

      x_dimension_level_tbl(x_dimension_level_tbl.count+1) := l_dim_level_rec;

    end loop;

  ELSE
       --added Add Error Message
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension_Levels'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

     RAISE FND_API.G_EXC_ERROR;
  END IF;

  --added this check
  IF l_flag = 0 then
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIMENSION_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension_Levels'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

     RAISE FND_API.G_EXC_ERROR;
  END IF;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension_Levels'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Retrieve_Dimension_Levels;
--
Procedure Retrieve_Dimension_Level
( p_api_version         IN  NUMBER
, p_Dimension_level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dimension_level_Rec IN OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_dim_id NUMBER;
  l_dim_short_name varchar2(30);
  l_dim_name varchar2(80);
  l_dimension_rec  BIS_DIMENSION_PUB.Dimension_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
cursor cr_lev_id is
  select dimension_id
       , dimension_short_name
       , dimension_name
       , dimension_level_id
       , dimension_level_short_name
       , dimension_level_name
       , description
       , Level_Values_View_Name
       , where_clause
       , source
       , comparison_label_code
       , attribute_code
       , application_id
       , default_search
       , long_lov
       , master_level
       , view_object_name
       , default_values_api
       , enabled
       , drill_to_form_function
       , hide_in_design
  from bisfv_dimension_levels
  where dimension_level_id = p_Dimension_level_Rec.dimension_level_id;

cursor cr_lev_short_name is
  select dimension_id
       , dimension_short_name
       , dimension_name
       , dimension_level_id
       , dimension_level_short_name
       , dimension_level_name
       , description
       , Level_Values_View_Name
       , where_clause
       , source
       , comparison_label_code
       , attribute_code
       , application_id
       , default_search
       , long_lov
       , master_level
       , view_object_name
       , default_values_api
       , enabled
       , drill_to_form_function
       , hide_in_design
  from bisfv_dimension_levels
  where dimension_level_short_name
        = p_Dimension_level_Rec.dimension_level_short_name;

cursor cr_lev_name is
   select dimension_id
       , dimension_short_name
       , dimension_name
       , dimension_level_id
       , dimension_level_short_name
       , dimension_level_name
       , description
       , Level_Values_View_Name
       , where_clause
       , source
       , comparison_label_code
       , attribute_code
       , application_id
       , default_search
       , long_lov
       , master_level
       , view_object_name
       , default_values_api
       , enabled
       , drill_to_form_function
       , hide_in_design
  from bisfv_dimension_levels
  where dimension_level_name = p_Dimension_level_Rec.dimension_level_name;

BEGIN

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  IF BIS_UTILITIES_PUB.Value_Not_Missing(
                       p_Dimension_level_Rec.dimension_level_id)
  = FND_API.G_TRUE
  THEN
     OPEN cr_lev_id;
     FETCH cr_lev_id INTO
         x_Dimension_level_Rec.dimension_id
       , x_Dimension_level_Rec.dimension_short_name
       , x_Dimension_level_Rec.dimension_name
       , x_Dimension_level_Rec.dimension_level_id
       , x_Dimension_level_Rec.dimension_level_short_name
       , x_Dimension_level_Rec.dimension_level_name
       , x_Dimension_level_Rec.description
       , x_dimension_level_rec.level_values_view_name
       , x_dimension_level_rec.where_clause
       , x_dimension_level_rec.source
       , x_dimension_level_rec.comparison_label_code
       , x_dimension_level_rec.attribute_code
       , x_Dimension_level_Rec.application_id
       , x_Dimension_level_Rec.default_search
       , x_Dimension_level_Rec.long_lov
       , x_Dimension_level_Rec.master_level
       , x_Dimension_level_Rec.view_object_name
       , x_Dimension_level_Rec.default_values_api
       , x_Dimension_level_Rec.enabled
       , x_Dimension_level_Rec.drill_to_form_function
       , x_Dimension_level_Rec.hide;
       --
     IF cr_lev_id%ROWCOUNT = 0 THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     CLOSE cr_lev_id;

  ELSIF BIS_UTILITIES_PUB.Value_Not_Missing(
                       p_Dimension_level_Rec.dimension_level_short_name)
  = FND_API.G_TRUE
  THEN
     OPEN cr_lev_short_name;
     FETCH cr_lev_short_name INTO
         x_Dimension_level_Rec.dimension_id
       , x_Dimension_level_Rec.dimension_short_name
       , x_Dimension_level_Rec.dimension_name
       , x_Dimension_level_Rec.dimension_level_id
       , x_Dimension_level_Rec.dimension_level_short_name
       , x_Dimension_level_Rec.dimension_level_name
       , x_Dimension_level_Rec.description
       , x_dimension_level_rec.level_values_view_name
       , x_dimension_level_rec.where_clause
       , x_dimension_level_rec.source
       , x_dimension_level_rec.comparison_label_code
       , x_dimension_level_rec.attribute_code
       , x_Dimension_level_Rec.application_id
       , x_Dimension_level_Rec.default_search
       , x_Dimension_level_Rec.long_lov
       , x_Dimension_level_Rec.master_level
       , x_Dimension_level_Rec.view_object_name
       , x_Dimension_level_Rec.default_values_api
       , x_Dimension_level_Rec.enabled
       , x_Dimension_level_Rec.drill_to_form_function
       , x_Dimension_level_Rec.hide;
       --
     IF cr_lev_short_name%ROWCOUNT = 0 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     CLOSE cr_lev_short_name;

  ELSIF BIS_UTILITIES_PUB.Value_Not_Missing(
                       p_Dimension_level_Rec.dimension_level_name)
  = FND_API.G_TRUE
  THEN
     OPEN cr_lev_name;
     FETCH cr_lev_name INTO
         x_Dimension_level_Rec.dimension_id
       , x_Dimension_level_Rec.dimension_short_name
       , x_Dimension_level_Rec.dimension_name
       , x_Dimension_level_Rec.dimension_level_id
       , x_Dimension_level_Rec.dimension_level_short_name
       , x_Dimension_level_Rec.dimension_level_name
       , x_Dimension_level_Rec.description
       , x_dimension_level_rec.level_values_view_name
       , x_dimension_level_rec.where_clause
       , x_dimension_level_rec.source
       , x_dimension_level_rec.comparison_label_code
       , x_dimension_level_rec.attribute_code
       , x_Dimension_level_Rec.application_id
       , x_Dimension_level_Rec.default_search
       , x_Dimension_level_Rec.long_lov
       , x_Dimension_level_Rec.master_level
       , x_Dimension_level_Rec.view_object_name
       , x_Dimension_level_Rec.default_values_api
       , x_Dimension_level_Rec.enabled
       , x_Dimension_level_Rec.drill_to_form_function
       , x_Dimension_level_Rec.hide;
       --
     IF cr_lev_name%ROWCOUNT = 0 THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
     CLOSE cr_lev_name;
  ELSE
      l_error_tbl := x_error_tbl;
      --added Error Msg
      BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  --added this check
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_VALUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
     RAISE FND_API.G_EXC_ERROR;
  END IF;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
       x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
    --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Dimension_Level'
      , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END Retrieve_Dimension_Level;

--===================================================================
-- p_all_dim_levels_tbl contains different dimension level ids.
-- x_all_dim_levels_tbl contains all records for the input dimension
-- level ids from bisfv_dimension_levels.
-- The output plsql table will be indexed by dimension level id

PROCEDURE retrieve_mult_dim_levels(
  p_api_version        IN NUMBER
 ,p_all_dim_levels_tbl IN BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type
 ,x_all_dim_levels_tbl OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type
 ,x_return_status      OUT NOCOPY VARCHAR2
 ,x_error_Tbl          OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  TYPE ref_cursor_type IS REF CURSOR;
  c_dim_level_details ref_cursor_type;

  l_dimension_level_rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_bind_var_tbl bind_variables_tbl_type;
  l_sql VARCHAR2(32000);
  l_is_bind BOOLEAN := FALSE;
  l_is_execute BOOLEAN := FALSE;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_all_dim_levels_tbl.COUNT = 0) THEN
    RETURN;
  END IF;

  retrieve_sql(
     p_all_dim_levels_tbl => p_all_dim_levels_tbl
    ,x_is_bind => l_is_bind
    ,x_is_execute => l_is_execute
    ,x_sql => l_sql
    ,x_bind_variables_tbl => l_bind_var_tbl
  );

  IF ( (l_is_execute) AND (l_sql IS NOT NULL) ) THEN

    IF (c_dim_level_details%ISOPEN) THEN
      close c_dim_level_details;
    END IF;

    IF (l_is_bind) THEN
      OPEN c_dim_level_details FOR l_sql USING l_bind_var_tbl(1), l_bind_var_tbl(2), l_bind_var_tbl(3), l_bind_var_tbl(4),
        l_bind_var_tbl(5), l_bind_var_tbl(6), l_bind_var_tbl(7), l_bind_var_tbl(8), l_bind_var_tbl(9), l_bind_var_tbl(10);
    ELSE
      OPEN c_dim_level_details FOR l_sql;
    END IF;

    LOOP

      FETCH c_dim_level_details INTO
         l_dimension_level_rec.dimension_id
       , l_dimension_level_rec.dimension_short_name
       , l_dimension_level_rec.dimension_name
       , l_dimension_level_rec.dimension_level_id
       , l_dimension_level_rec.dimension_level_short_name
       , l_dimension_level_rec.dimension_level_name
       , l_dimension_level_rec.description
       , l_dimension_level_rec.level_values_view_name
       , l_dimension_level_rec.where_clause
       , l_dimension_level_rec.source
       , l_dimension_level_rec.comparison_label_code
       , l_dimension_level_rec.attribute_code
       , l_Dimension_level_Rec.application_id
       , l_Dimension_level_Rec.default_search
       , l_Dimension_level_Rec.long_lov
       , l_Dimension_level_Rec.master_level
       , l_Dimension_level_Rec.view_object_name
       , l_Dimension_level_Rec.default_values_api
       , l_Dimension_level_Rec.enabled
       , l_Dimension_level_Rec.drill_to_form_function
       , l_Dimension_level_Rec.hide;

      EXIT WHEN c_dim_level_details%NOTFOUND;

      x_all_dim_levels_tbl(l_dimension_level_rec.dimension_level_id) := l_dimension_level_rec;

    END LOOP;
    CLOSE c_dim_level_details;

  END IF; -- end of execution

EXCEPTION
  WHEN OTHERS THEN
    IF (c_dim_level_details%ISOPEN) THEN
      CLOSE c_dim_level_details;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message(
        p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.retrieve_multiple_dim_levels'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
END retrieve_mult_dim_levels;

--====================================================================

PROCEDURE retrieve_sql(
  p_all_dim_levels_tbl IN BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type
 ,x_is_bind            OUT NOCOPY BOOLEAN
 ,x_is_execute         OUT NOCOPY BOOLEAN
 ,x_sql                OUT NOCOPY VARCHAR2
 ,x_bind_variables_tbl OUT NOCOPY bind_variables_tbl_type
)
IS
  l_all_dim_level_ids_lit VARCHAR2(32000);
  l_index NUMBER;
  l_tbl_index NUMBER;

BEGIN

  x_is_execute := FALSE;

  x_sql := ' SELECT dimension_id
           , dimension_short_name
           , dimension_name
           , dimension_level_id
           , dimension_level_short_name
           , dimension_level_name
           , description
           , Level_Values_View_Name
           , where_clause
           , source
           , comparison_label_code
           , attribute_code
           , application_id
           , default_search
           , long_lov
           , master_level
           , view_object_name
           , default_values_api
           , enabled
           , drill_to_form_function
           , hide_in_design
         FROM bisfv_dimension_levels
             WHERE dimension_level_id IN (';

  IF (p_all_dim_levels_tbl.COUNT <= 10) THEN -- lesser than 10 use bind variables
    l_index := 1;
    x_is_bind := TRUE;
    -- The input and returned plsql table will be indexed by dimension level id to avoid loops
    l_tbl_index := p_all_dim_levels_tbl.FIRST;
    WHILE l_tbl_index IS NOT NULL LOOP
      IF (p_all_dim_levels_tbl(l_tbl_index).dimension_level_id IS NOT NULL) THEN
        x_is_execute := TRUE;
        x_bind_variables_tbl(l_index) := p_all_dim_levels_tbl(l_tbl_index).dimension_level_id;
      ELSE
        x_bind_variables_tbl(l_index) := NULL;
      END IF;
      l_index := l_index + 1;
      l_tbl_index := p_all_dim_levels_tbl.NEXT(l_tbl_index);
    END LOOP;

    FOR i IN l_index .. 10 LOOP
      x_bind_variables_tbl(i) := NULL;
    END LOOP;

    x_sql := x_sql || ':1, :2, :3, :4, :5, :6, :7, :8, :9, :10)';

  ELSE -- If more than 10, then use literals.
    l_tbl_index := p_all_dim_levels_tbl.FIRST;
    WHILE l_tbl_index IS NOT NULL LOOP
      IF (p_all_dim_levels_tbl(l_tbl_index).dimension_level_id IS NOT NULL) THEN
    x_is_execute := TRUE;
        IF (l_all_dim_level_ids_lit IS NOT NULL) THEN
          l_all_dim_level_ids_lit := l_all_dim_level_ids_lit || ', ''' || p_all_dim_levels_tbl(l_tbl_index).dimension_level_id || '''';
    ELSE
      l_all_dim_level_ids_lit := '''' || p_all_dim_levels_tbl(l_tbl_index).dimension_level_id || '''';
    END IF;
      END IF;
      l_tbl_index := p_all_dim_levels_tbl.NEXT(l_tbl_index);
    END LOOP;

    x_sql := x_sql || l_all_dim_level_ids_lit || ')';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_is_execute := FALSE;
    RETURN;
END retrieve_sql;

--=====================================================================

--
Procedure Create_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
BEGIN


  l_Dimension_Level_Rec := p_Dimension_Level_Rec;
  l_Dimension_Level_Rec.Last_Update_Date := NVL(p_Dimension_Level_Rec.Last_Update_Date, SYSDATE);
  Create_Dimension_Level
  ( p_api_version         => p_api_version
  , p_commit              => p_commit
  , p_validation_level    => p_validation_level
  , p_Dimension_Level_Rec => l_Dimension_Level_Rec
  , p_owner               => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );

--commented RAISE
EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_error_tbl := x_error_tbl;
    --added last two parameters
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Create_Dimension_Level'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_Dimension_Level;
--
PROCEDURE Create_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_owner               IN  VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_user_id             NUMBER;
  l_login_id            NUMBER;
  l_id                  NUMBER;
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_level_name_is_used  BOOLEAN;
  l_msg                 VARCHAR2(1000);
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

DUPLICATE_DIMENSION_VALUE EXCEPTION;
PRAGMA EXCEPTION_INIT(DUPLICATE_DIMENSION_VALUE, -1);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SetNULL
  ( p_dimension_level_Rec => p_dimension_level_Rec
  , x_dimension_level_Rec => l_dimension_level_Rec
  );

  IF  (BIS_UTILITIES_PUB.Value_Missing(l_Dimension_Level_Rec.Dimension_id) = FND_API.G_TRUE )
       OR (BIS_UTILITIES_PUB.Value_NULL(l_Dimension_Level_Rec.Dimension_id) = FND_API.G_TRUE )
  THEN

    BIS_DIMENSION_PVT.Value_ID_Conversion
                       ( p_api_version
               , l_Dimension_Level_Rec.Dimension_Short_Name
               , l_Dimension_Level_Rec.Dimension_Name
               , l_Dimension_Level_Rec.Dimension_ID
               , x_return_status
               , x_error_Tbl
                       );

  END IF;


  Validate_Dimension_Level
  ( p_api_version
  , p_validation_level
  , l_Dimension_Level_Rec
  , x_return_status
  , x_error_Tbl
  );


  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_NAME_SHORT_NAME_MISSING'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Create_Dimension_Level'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

      RAISE FND_API.G_EXC_ERROR;

  END IF;

  -- ankgoel: bug#3891748 - Created_By will take precedence over Owner.
  -- Last_Updated_By can be different from Created_By while creating dim levels
  -- during sync-up
  IF (l_Dimension_Level_Rec.Created_By IS NULL) THEN
    l_Dimension_Level_Rec.Created_By := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  END IF;
  IF (l_Dimension_Level_Rec.Last_Updated_By IS NULL) THEN
    l_Dimension_Level_Rec.Last_Updated_By := l_Dimension_Level_Rec.Created_By;
  END IF;
  IF (l_Dimension_Level_Rec.Last_Update_Login IS NULL) THEN
    l_Dimension_Level_Rec.Last_Update_Login := fnd_global.LOGIN_ID;
  END IF;

  IF (BIS_UTILITIES_PUB.Value_Missing(l_Dimension_Level_Rec.source)
        = FND_API.G_TRUE)
  OR (BIS_UTILITIES_PUB.Value_NULL(l_Dimension_Level_Rec.source)
        = FND_API.G_TRUE)
  THEN
    l_Dimension_Level_Rec.source := FND_PROFILE.value('BIS_SOURCE');
  END IF;



  l_level_name_is_used :=  Is_Level_Name_Used
               (
                 p_level_name => l_Dimension_Level_Rec.Dimension_Level_Name
               , p_source     => l_Dimension_Level_Rec.source
               , p_dimension_id => l_Dimension_Level_Rec.Dimension_ID
               );


  IF  ( l_level_name_is_used = FALSE ) THEN

    select bis_levels_s.NextVal into l_id from dual;

    l_Dimension_Level_Rec.Last_Update_Date := NVL(p_Dimension_Level_Rec.Last_Update_Date, SYSDATE);

    Create_New_Dimension_Level
    ( p_level_id        => l_id
    , p_level_short_name        => l_Dimension_Level_Rec.Dimension_Level_Short_Name
    , p_dimension_id        => l_Dimension_Level_Rec.Dimension_ID
    , p_level_values_view_name  => l_Dimension_Level_Rec.Level_Values_View_Name
    , p_where_clause        => l_Dimension_Level_Rec.Where_Clause
    , p_source          => l_Dimension_Level_Rec.Source
    , p_created_by         => l_Dimension_Level_Rec.Created_By
    , p_last_updated_by    => l_Dimension_Level_Rec.Last_Updated_By
    , p_login_id        => l_Dimension_Level_Rec.Last_Update_Login
    , p_level_name      => l_Dimension_Level_Rec.Dimension_Level_Name
    , p_description     => l_Dimension_Level_Rec.Description
    , p_comparison_label_code   => l_Dimension_Level_Rec.Comparison_Label_Code
    , p_attribute_code      => l_Dimension_Level_Rec.attribute_code
    , p_application_id          => l_Dimension_Level_Rec.Application_Id
    , p_default_search => l_Dimension_Level_Rec.default_search
    , p_long_lov => l_Dimension_Level_Rec.long_lov
    , p_master_level => l_Dimension_Level_Rec.master_level
    , p_view_object_name => l_Dimension_Level_Rec.view_object_name
    , p_default_values_api => l_Dimension_Level_Rec.default_values_api
    , p_enabled            => l_Dimension_Level_Rec.enabled
    , p_drill_to_form_function      => l_DImension_Level_Rec.Drill_To_Form_Function
    , p_hide                        => l_Dimension_Level_Rec.Hide
    , p_last_update_date  => l_Dimension_Level_Rec.Last_Update_Date
    );

    if (p_commit = FND_API.G_TRUE) then
      COMMIT;
    end if;

  ELSE

    /*
    fnd_message.set_name('BIS', 'BIS_LVL_UPLD_FAIL');
    fnd_message.set_token('SHORT_NAME', l_Dimension_Level_Rec.Dimension_Level_Short_Name);
    fnd_message.set_token('NAME', l_Dimension_Level_Rec.Dimension_Level_Name);
    l_msg := fnd_message.get;
    */

    l_msg := 'Failed to upload ' || nvl(l_Dimension_Level_Rec.Dimension_Level_Short_Name, ' ');
    l_msg := l_msg || ' Level name: ' || nvl(l_Dimension_Level_Rec.Dimension_Level_Name, ' ');
    l_msg := l_msg || ' already exists in the database. ' ;
    BIS_UTILITIES_PUB.put_line(p_text =>l_msg);

  END IF;


EXCEPTION

    WHEN DUPLICATE_DIMENSION_VALUE THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_DIM_LEVEL_UNIQUENESS_ERROR'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Create_Dimension_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Dimension_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Create_Dimension_Level;
--

-- Should not create a new level with same name as existing ones
-- for the same dimension and source ('EDW' or 'OLTP').
FUNCTION Is_Level_Name_Used
(
  p_level_name        IN VARCHAR2
, p_source                IN VARCHAR2
, p_dimension_id      IN NUMBER
)
RETURN BOOLEAN
IS

  l_level_id    NUMBER;
  l_is_used     BOOLEAN;

BEGIN

  SELECT level_id
  INTO   l_level_id
  FROM   bis_levels_vl
  WHERE
        name = p_level_name
    AND source = p_source
    AND dimension_id = p_dimension_id;

  RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;

  WHEN TOO_MANY_ROWS THEN
    RETURN TRUE;

  WHEN OTHERS THEN
    RETURN TRUE;

END;

--

PROCEDURE Create_New_Dimension_Level
( p_level_id            IN NUMBER,      -- l_id
  p_level_short_name        IN VARCHAR2,  -- l_Dimension_Rec.Dimension_Short_Name
  p_dimension_id        IN NUMBER,
  p_level_values_view_name  IN VARCHAR2,
  p_where_clause        IN VARCHAR2,
  p_source          IN VARCHAR2,
  p_created_by          IN NUMBER,  -- created_by
  p_last_updated_by     IN NUMBER,  -- last_updated_by
  p_login_id            IN NUMBER,  -- l_login_id
  p_level_name          IN VARCHAR2,    -- l_Dimension_Rec.Dimension_Name
  p_description         IN VARCHAR2,   -- l_Dimension_Rec.Description
  p_comparison_label_code   IN VARCHAR2,
  p_attribute_code          IN VARCHAR2,
  p_application_id          IN NUMBER := NULL,
  p_default_search IN VARCHAR2,
  p_long_lov IN VARCHAR2,
  p_master_level IN VARCHAR2,
  p_view_object_name IN VARCHAR2,
  p_default_values_api IN VARCHAR2,
  p_enabled IN VARCHAR2,
  p_drill_to_form_function IN VARCHAR2,
  p_last_update_date IN DATE := SYSDATE,
  p_Hide IN VARCHAR2 := FND_API.G_FALSE
)
IS

 l_msg      VARCHAR2(3000);

BEGIN


  SAVEPOINT InsertIntoBISLevels;

  insert into bis_levels(
    LEVEL_ID
  , SHORT_NAME
  , DIMENSION_ID
  , LEVEL_VALUES_VIEW_NAME
  , WHERE_CLAUSE
  , CREATION_DATE
  , CREATED_BY
  , LAST_UPDATE_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  , SOURCE
  , COMPARISON_LABEL_CODE
  , ATTRIBUTE_CODE
  , APPLICATION_ID
  , default_search
  , LONG_LOV
  , MASTER_LEVEL
  , VIEW_OBJECT_NAME
  , DEFAULT_VALUES_API
  , ENABLED
  , DRILL_TO_FORM_FUNCTION
  , HIDE_IN_DESIGN
  )
  values
  ( p_level_id
  , p_level_short_name
  , p_dimension_id
  , p_level_values_view_name
  , p_where_clause
  , p_last_update_date
  , p_created_by
  , p_last_update_date
  , p_last_updated_by
  , p_login_id
  , p_source
  , p_comparison_label_code
  , UPPER(p_attribute_code)
  , p_application_id
  , p_default_search
  , NVL(p_long_lov, 'F')
  , p_master_level
  , p_view_object_name
  , p_default_values_api
  , NVL(p_enabled, FND_API.G_TRUE)
  , p_drill_to_form_function
  , p_hide
  );

  insert into bis_LEVELS_TL (
    LEVEL_ID,
    LANGUAGE,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    TRANSLATED,
    SOURCE_LANG
  ) select
    DL.LEVEL_ID
  , L.LANGUAGE_CODE
  , p_level_name
  , p_description
  , p_last_update_date
  , p_created_by
  , p_last_update_date
  , p_last_updated_by
  , p_login_id
  ,  'Y'
  , userenv('LANG')
  from FND_LANGUAGES L
     , BIS_LEVELS DL
  where L.INSTALLED_FLAG in ('I', 'B')
  and DL.SHORT_NAME = p_level_short_name
  and not exists
    (select 'EXIST'
    from BIS_LEVELS_TL TL
       , BIS_LEVELS T
    where T.level_ID = TL.level_id
    and T.SHORT_NAME = p_level_short_name
    and TL.LANGUAGE = L.LANGUAGE_CODE);


EXCEPTION

  WHEN OTHERS THEN

    /*
    fnd_message.set_name('BIS', 'BIS_LVL_UPLD_FAIL');
    fnd_message.set_token('SHORT_NAME', p_level_short_name);
    fnd_message.set_token('NAME', p_level_name);
    l_msg := fnd_message.get;
    BIS_UTILITIES_PUB.put_line(p_text =>l_msg);
    */

    l_msg := 'Failed to upload ' || nvl ( p_level_short_name , ' ' );
    l_msg := l_msg || ' Level name: ' || nvl ( p_level_name , ' ' );
    l_msg := l_msg || ' already exists in the database. ' ;
    BIS_UTILITIES_PUB.put_line(p_text =>l_msg);


    ROLLBACK TO InsertIntoBISLevels;
    RAISE;

END Create_New_Dimension_Level;


--
PROCEDURE Update_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  l_Dimension_Level_Rec := p_Dimension_Level_Rec;
  l_Dimension_Level_Rec.Last_Update_Date := NVL(p_Dimension_Level_Rec.Last_Update_Date, SYSDATE);

  Update_Dimension_Level
  ( p_api_version         => p_api_version
  , p_commit              => p_commit
  , p_validation_level    => p_validation_level
  , p_Dimension_Level_Rec => l_Dimension_Level_Rec
  , p_owner               => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );

--commented RAISE
EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_error_tbl := x_error_tbl;
    --added last two paramaters
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Update_Dimension_Level'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Dimension_Level;
--
PROCEDURE Update_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_owner               IN  VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_user_id                  NUMBER;
  l_login_id                 NUMBER;
  l_Dimension_Level_Rec      BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_count                    NUMBER := 0;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
--exception

DUPLICATE_DIMENSION_VALUE EXCEPTION;
PRAGMA EXCEPTION_INIT(DUPLICATE_DIMENSION_VALUE, -1);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- retrieve record from database and apply changes
  UpdateRecord
  ( p_Dimension_Level_Rec => p_Dimension_Level_Rec
  , x_Dimension_Level_Rec => l_Dimension_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );

  Validate_Dimension_Level
  ( p_api_version
  , p_validation_level
  , l_Dimension_Level_Rec
  , x_return_status
  , x_error_Tbl
  );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    l_error_tbl := x_error_tbl;
     --added Error Msg--------
      BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_DIM_LEVEL_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Update_Dimension_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF ((l_Dimension_Level_Rec.Enabled IS NULL) OR (l_Dimension_Level_Rec.Enabled = FND_API.G_FALSE)) THEN
    validate_disabling
        (p_dim_level_id  => l_Dimension_Level_Rec.dimension_level_id
        ,p_error_tbl     => l_error_tbl
        ,x_return_status => x_return_status
        ,x_error_tbl     => x_error_tbl
        );
    IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  l_user_id := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  l_login_id := fnd_global.LOGIN_ID;

  ----------------
  --Adding this for the source column
  IF (BIS_UTILITIES_PUB.Value_Missing(l_Dimension_Level_Rec.source)
        = FND_API.G_TRUE)
  OR (BIS_UTILITIES_PUB.Value_NULL(l_Dimension_Level_Rec.source)
        = FND_API.G_TRUE)
  THEN
    l_Dimension_Level_Rec.source := FND_PROFILE.value('BIS_SOURCE');
  END IF;
  ------------------

  l_Dimension_Level_Rec.Last_Update_Date := NVL(p_Dimension_Level_Rec.Last_Update_Date, SYSDATE);
  Update bis_Levels
  set
    SHORT_NAME             = l_Dimension_Level_Rec.Dimension_Level_Short_Name
  , DIMENSION_ID           = l_Dimension_Level_Rec.Dimension_ID
  , LEVEL_VALUES_VIEW_NAME = l_Dimension_Level_Rec.Level_Values_View_Name
  , WHERE_CLAUSE           = l_Dimension_Level_Rec.Where_Clause
  , LAST_UPDATE_DATE       = l_Dimension_Level_Rec.Last_Update_Date
  , LAST_UPDATED_BY        = l_user_id
  , LAST_UPDATE_LOGIN      = l_login_id
  , SOURCE                 = l_Dimension_Level_Rec.Source
  , COMPARISON_LABEL_CODE  = l_Dimension_Level_Rec.Comparison_Label_Code
  , ATTRIBUTE_CODE         = UPPER(l_Dimension_Level_Rec.Attribute_Code)
  , APPLICATION_ID         = l_Dimension_Level_Rec.Application_ID
  , default_search         = l_Dimension_Level_Rec.default_search
  , LONG_LOV               = NVL(l_Dimension_Level_Rec.Long_Lov, 'F')
  , MASTER_LEVEL           = l_Dimension_Level_Rec.Master_Level
  , VIEW_OBJECT_NAME       = l_Dimension_Level_Rec.View_Object_Name
  , DEFAULT_VALUES_API     = l_Dimension_Level_Rec.Default_Values_Api
  , ENABLED                = NVL(l_Dimension_Level_Rec.Enabled,FND_API.G_TRUE)
  , DRILL_TO_FORM_FUNCTION = l_Dimension_Level_Rec.Drill_To_Form_Function
  , HIDE_IN_DESIGN         = l_Dimension_Level_Rec.Hide
  where Level_ID  = l_Dimension_Level_Rec.Dimension_Level_Id;

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

  Translate_dimension_level
  ( p_api_version         => p_api_version
  , p_commit              => p_commit
  , p_validation_level    => p_validation_level
  , p_Dimension_level_Rec => l_Dimension_level_Rec
  , p_owner               => p_owner
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );

--commented RAISE
EXCEPTION
    --new exception
    WHEN DUPLICATE_DIMENSION_VALUE THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_DIM_LEVEL_UNIQUENESS_ERROR'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Update_Dimension_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Dimension_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Dimension_Level;
--
--
--
Procedure Translate_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
BEGIN

  l_Dimension_Level_Rec := p_Dimension_Level_Rec;
  l_Dimension_Level_Rec.Last_Update_Date := NVL(p_Dimension_Level_Rec.Last_Update_Date, SYSDATE);

  Translate_Dimension_Level
  ( p_api_version         => p_api_version
  , p_commit              => p_commit
  , p_validation_level    => p_validation_level
  , p_Dimension_Level_Rec => l_Dimension_Level_Rec
  , p_owner               => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );

--commented RAISE
EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    l_error_tbl := x_error_tbl;
    --added last two paramaters
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Translate_Dimension_Level'
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Translate_Dimension_Level;
--
Procedure Translate_Dimension_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, p_owner               IN  VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_user_id           NUMBER;
  l_login_id          NUMBER;
  l_count             NUMBER := 0;
  l_Dimension_Level_Rec      BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- retrieve record from database and apply changes
  UpdateRecord
  ( p_Dimension_Level_Rec => p_Dimension_Level_Rec
  , x_Dimension_Level_Rec => l_Dimension_Level_Rec
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_Tbl
  );

  Validate_Dimension_Level
  ( p_api_version
  , p_validation_level
  , l_Dimension_Level_Rec
  , x_return_status
  , x_error_Tbl
  );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  l_user_id := BIS_UTILITIES_PUB.Get_Owner_Id(p_owner);
  l_login_id := fnd_global.LOGIN_ID;
  --
  l_Dimension_Level_Rec.Last_Update_Date := NVL(p_Dimension_Level_Rec.Last_Update_Date, SYSDATE);
  Update bis_levels_TL
  set
    NAME              = l_Dimension_Level_Rec.Dimension_Level_Name
  , DESCRIPTION       = l_Dimension_Level_Rec.description
  , LAST_UPDATE_DATE  = l_Dimension_Level_Rec.Last_Update_Date
  , LAST_UPDATED_BY   = l_user_id
  , LAST_UPDATE_LOGIN = l_login_id
  , SOURCE_LANG       = userenv('LANG')
  where LEVEL_ID  = l_Dimension_Level_Rec.Dimension_Level_Id
  and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Dimension_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Translate_Dimension_Level;
--
--
-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version         IN  NUMBER
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dimension_Level_Rec OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
is
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
begin

  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_Dimension_Level_Rec := p_Dimension_Level_Rec;

  if (BIS_UTILITIES_PUB.Value_Missing
          (x_Dimension_Level_Rec.Dimension_level_id) = FND_API.G_TRUE
    AND ( BIS_UTILITIES_PUB.Value_Not_Missing
          (x_Dimension_Level_Rec.Dimension_level_short_name) = FND_API.G_TRUE
       OR BIS_UTILITIES_PUB.Value_Not_Missing
          (x_Dimension_Level_Rec.Dimension_level_name) = FND_API.G_TRUE)
     ) then
    BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
                             ( p_api_version
                 , x_Dimension_Level_Rec.Dimension_Level_Short_Name
                 , x_Dimension_Level_Rec.Dimension_Level_Name
                 , x_Dimension_Level_Rec.Dimension_Level_ID
                 , x_return_status
                 , x_error_Tbl
                             );
  end if;

  if (BIS_UTILITIES_PUB.Value_Missing
          (x_Dimension_Level_Rec.Dimension_id) = FND_API.G_TRUE
    AND ( BIS_UTILITIES_PUB.Value_Not_Missing
          (x_Dimension_Level_Rec.Dimension_short_name) = FND_API.G_TRUE
       OR BIS_UTILITIES_PUB.Value_Not_Missing
          (x_Dimension_Level_Rec.Dimension_name) = FND_API.G_TRUE)
     ) then
    BIS_DIMENSION_PVT.Value_ID_Conversion
                       ( p_api_version
               , x_Dimension_Level_Rec.Dimension_Short_Name
               , x_Dimension_Level_Rec.Dimension_Name
               , x_Dimension_Level_Rec.Dimension_ID
               , x_return_status
               , x_error_Tbl
                       );
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


end Value_ID_Conversion;
--
PROCEDURE Value_ID_Conversion
( p_api_version                IN  NUMBER
, p_Dimension_Level_Short_Name IN  VARCHAR2
, p_Dimension_Level_Name       IN  VARCHAR2
, x_Dimension_Level_ID         OUT NOCOPY NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
, x_error_Tbl                  OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
is
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
begin

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  if (BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Short_Name)
                       = FND_API.G_TRUE) then
    SELECT dimension_level_id into x_Dimension_Level_ID
    FROM bisbv_dimension_levels
    WHERE dimension_level_short_name = p_Dimension_Level_Short_Name;
  elsif (BIS_UTILITIES_PUB.Value_Not_Missing(p_Dimension_Level_Name)
                          = FND_API.G_TRUE) then
    SELECT dimension_level_id into x_Dimension_Level_ID
    FROM bisbv_dimension_levels
    WHERE dimension_level_name = p_Dimension_Level_Name;
  else

    -- POPULATE THE ERROR TABLE: added last two parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_NAME_SHORT_NAME_MISSING'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );

    RAISE FND_API.G_EXC_ERROR;
  end if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

end Value_ID_Conversion;
--
-- Validates Dimension_Level
PROCEDURE Validate_Dimension_Level
( p_api_version         IN  NUMBER
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_error     VARCHAR2(10) := FND_API.G_FALSE;
  l_error_tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  BEGIN
    BIS_DIM_LEVEL_VALIDATE_PVT.Validate_Record
    ( p_api_version         => p_api_version
    , p_validation_level    => p_validation_level
    , p_Dimension_Level_Rec => p_Dimension_Level_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => l_error_Tbl
    );
  EXCEPTION
    when FND_API.G_EXC_ERROR then
      l_error := FND_API.G_TRUE;
      l_error_tbl_p := x_error_tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_tbl_p
                          , l_error_Tbl
                          , x_error_tbl
                          );
      x_return_status := FND_API.G_RET_STS_ERROR;
  END;

  if (l_error = FND_API.G_TRUE) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl_p := x_error_tbl;
      --added last two parameters
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Dimension_Level'
      , p_error_table       => l_error_tbl_p
    , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Dimension_Level;
--
PROCEDURE Delete_Dimension_Level
(
    p_commit                IN          VARCHAR2 := FND_API.G_FALSE
  , p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
  , p_Dimension_Level_Rec   IN          BIS_Dimension_Level_PUB.Dimension_Level_Rec_Type
  , x_return_status         OUT NOCOPY  VARCHAR2
  , x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
) IS
    l_dim_level_id              NUMBER;
    l_error_tbl                 BIS_UTILITIES_PUB.Error_Tbl_Type;

    CURSOR  cr_dim_short_name IS
    SELECT  level_id
    FROM    BIS_LEVELS
    WHERE   short_name = p_Dimension_Level_Rec.Dimension_Level_Short_Name;
BEGIN
  SAVEPOINT DeleteFromBISDimLevs;

  IF (p_Dimension_Level_Rec.Dimension_Level_ID IS NOT NULL) THEN
    l_dim_level_id  := p_Dimension_Level_Rec.Dimension_Level_ID;

  ELSIF (p_Dimension_Level_Rec.Dimension_Level_Short_Name IS NOT NULL) THEN
    IF (cr_dim_short_name%ISOPEN) THEN
      CLOSE cr_dim_short_name;
    END IF;
    OPEN    cr_dim_short_name;
    FETCH   cr_dim_short_name
    INTO    l_dim_level_id;
  ELSE
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_NAME_SHORT_NAME_MISSING'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Dimension_Level'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF(l_dim_level_id IS NOT NULL) THEN
    DELETE FROM bis_levels
    WHERE  level_id = l_dim_level_id;

    DELETE FROM bis_levels_tl
    WHERE  level_id = l_dim_level_id;
  END IF;
  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END if;
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF (cr_dim_short_name%ISOPEN) THEN
        CLOSE cr_dim_short_name;
      END IF;
      ROLLBACK TO DeleteFromBISDimLevs;
   WHEN OTHERS THEN
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Dimension_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      IF (cr_dim_short_name%ISOPEN) THEN
        CLOSE cr_dim_short_name;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO DeleteFromBISDimLevs;
END Delete_Dimension_Level;
--

--=============================================================================

PROCEDURE Trans_DimObj_By_Given_Lang
(
      p_commit                IN          VARCHAR2 := FND_API.G_FALSE
  ,   p_validation_level      IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL
  ,   p_Dimension_Level_Rec   IN          BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
  ,   x_return_status         OUT NOCOPY  VARCHAR2
  ,   x_error_Tbl             OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
) IS

      l_dim_level_id              NUMBER;
      l_error_tbl                 BIS_UTILITIES_PUB.Error_Tbl_Type;
      l_user_id           NUMBER;
      l_login_id          NUMBER;

BEGIN
       SAVEPOINT TransDimObjByLangPvt;

       l_user_id := FND_GLOBAL.USER_ID;

       l_login_id := fnd_global.LOGIN_ID;


       SELECT LEVEL_ID
       INTO   l_dim_level_id
       FROM   BIS_LEVELS
       WHERE  SHORT_NAME = p_Dimension_Level_Rec.Dimension_Level_Short_Name;

       UPDATE BIS_LEVELS_TL
       SET    NAME          = p_Dimension_Level_Rec.Dimension_Level_Name
           ,  DESCRIPTION   = p_Dimension_Level_Rec.Description
           ,  SOURCE_LANG   = p_Dimension_Level_Rec.Source_Lang
           ,  LAST_UPDATED_BY   = l_user_id
           ,  LAST_UPDATE_LOGIN = l_login_id
       WHERE  LEVEL_ID      = l_dim_level_id
       AND    LANGUAGE      = p_Dimension_Level_Rec.Language;

       IF (p_commit = FND_API.G_TRUE) THEN
         COMMIT;
       END if;
       x_return_status :=  FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO TransDimObjByLangPvt;
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      ROLLBACK TO TransDimObjByLangPvt;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      ROLLBACK TO TransDimObjByLangPvt;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl     := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Trans_DimObj_By_Given_Lang'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      ROLLBACK TO TransDimObjByLangPvt;
END Trans_DimObj_By_Given_Lang;

--=============================================================================

-------------------- Get customized name ----------------------
FUNCTION get_customized_name( p_dim_level_id IN NUMBER) RETURN VARCHAR2 AS
  CURSOR c_cust IS SELECT
       NAME ,
       USER_ID,
       APPLICATION_ID,
       RESPONSIBILITY_ID,
       ORG_ID,
       SITE_ID
       FROM BIS_LEVELS_CUSTOMIZATIONS_VL
     WHERE LEVEL_ID = p_dim_level_id
       AND (user_id = fnd_global.user_id
       OR  responsibility_id = fnd_global.RESP_ID
       OR  application_id = fnd_global.RESP_APPL_ID
       OR  org_id = fnd_global.ORG_ID
       OR  site_id = 0) ;
  l_dim_lvl_custom_name_usr      bis_levels_customizations_tl.name%TYPE;
  l_dim_lvl_custom_name_resp     bis_levels_customizations_tl.name%TYPE;
  l_dim_lvl_custom_name_appl     bis_levels_customizations_tl.name%TYPE;
  l_dim_lvl_custom_name_org      bis_levels_customizations_tl.name%TYPE;
  l_dim_lvl_custom_name_site     bis_levels_customizations_tl.name%TYPE;
BEGIN
    IF (c_cust%ISOPEN) THEN
      CLOSE c_cust;
    END IF;

    FOR cr IN c_cust LOOP
      IF (cr.user_id IS NOT NULL) THEN
        l_dim_lvl_custom_name_usr := cr.name;
      ELSIF (cr.responsibility_id IS NOT NULL) THEN
        l_dim_lvl_custom_name_resp := cr.name;
      ELSIF (cr.application_id IS NOT NULL) THEN
        l_dim_lvl_custom_name_appl := cr.name;
      ELSIF (cr.org_id IS NOT NULL) THEN
        l_dim_lvl_custom_name_org := cr.name;
      ELSIF (cr.site_id IS NOT NULL) THEN
        l_dim_lvl_custom_name_site := cr.name;
      END IF;
    END LOOP;

    IF ( l_dim_lvl_custom_name_usr IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_name_usr ;
    ELSIF (l_dim_lvl_custom_name_resp IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_name_resp ;
    ELSIF (l_dim_lvl_custom_name_appl IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_name_appl ;
    ELSIF (l_dim_lvl_custom_name_org IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_name_org ;
    ELSIF (l_dim_lvl_custom_name_site IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_name_site ;
    END IF;

    RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN
    IF (c_cust%ISOPEN) THEN
      CLOSE c_cust;
    END IF;
    RETURN NULL;
END get_customized_name;

-------------------- get_customized_desc --------------------
FUNCTION get_customized_description( p_dim_level_id IN NUMBER) RETURN VARCHAR2 AS
  CURSOR c_cust IS SELECT
       DESCRIPTION ,
       USER_ID,
       APPLICATION_ID,
       RESPONSIBILITY_ID,
       ORG_ID,
       SITE_ID
       FROM BIS_LEVELS_CUSTOMIZATIONS_VL
     WHERE LEVEL_ID = p_dim_level_id
       AND (user_id = fnd_global.user_id
       OR  responsibility_id = fnd_global.RESP_ID
       OR  application_id = fnd_global.RESP_APPL_ID
       OR  org_id = fnd_global.ORG_ID
       OR  site_id = 0) ;
  l_dim_lvl_custom_desc_usr      bis_levels_customizations_tl.description%TYPE;
  l_dim_lvl_custom_desc_resp     bis_levels_customizations_tl.description%TYPE;
  l_dim_lvl_custom_desc_appl     bis_levels_customizations_tl.description%TYPE;
  l_dim_lvl_custom_desc_org      bis_levels_customizations_tl.description%TYPE;
  l_dim_lvl_custom_desc_site     bis_levels_customizations_tl.description%TYPE;
BEGIN
    IF (c_cust%ISOPEN) THEN
      CLOSE c_cust;
    END IF;

    FOR cr IN c_cust LOOP
      IF (cr.user_id IS NOT NULL) THEN
        l_dim_lvl_custom_desc_usr := cr.description;
      ELSIF (cr.responsibility_id IS NOT NULL) THEN
        l_dim_lvl_custom_desc_resp := cr.description;
      ELSIF (cr.application_id IS NOT NULL) THEN
        l_dim_lvl_custom_desc_appl := cr.description;
      ELSIF (cr.org_id IS NOT NULL) THEN
        l_dim_lvl_custom_desc_org := cr.description;
      ELSIF (cr.site_id IS NOT NULL) THEN
        l_dim_lvl_custom_desc_site := cr.description;
      END IF;
    END LOOP;

    IF ( l_dim_lvl_custom_desc_usr IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_desc_usr ;
    ELSIF (l_dim_lvl_custom_desc_resp IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_desc_resp ;
    ELSIF (l_dim_lvl_custom_desc_appl IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_desc_appl ;
    ELSIF (l_dim_lvl_custom_desc_org IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_desc_org ;
    ELSIF (l_dim_lvl_custom_desc_site IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_desc_site ;
    END IF;

    RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN
    IF (c_cust%ISOPEN) THEN
      CLOSE c_cust;
    END IF;
    RETURN NULL;
END get_customized_description;

FUNCTION get_customized_enabled( p_dim_level_sht_name IN VARCHAR2) RETURN VARCHAR2 AS
  l_dim_level_id              bis_levels.level_id%TYPE;
  l_dim_level_enabled         bis_levels.enabled%TYPE;
  l_dim_level_custom_enabled  bis_levels_customizations.enabled%TYPE;
BEGIN
  SELECT LEVEL_ID,ENABLED
  INTO l_dim_level_id,l_dim_level_enabled
  FROM BIS_LEVELS
  WHERE short_name = p_dim_level_sht_name;

  IF l_dim_level_id IS NOT NULL THEN
    l_dim_level_custom_enabled := get_customized_enabled(l_dim_level_id);
    RETURN NVL(l_dim_level_custom_enabled,l_dim_level_enabled);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_customized_enabled;


------------- get_customized_enabled -----------------
FUNCTION get_customized_enabled( p_dim_level_id IN NUMBER) RETURN VARCHAR2 AS
  CURSOR c_cust IS SELECT
       ENABLED ,
       USER_ID,
       APPLICATION_ID,
       RESPONSIBILITY_ID,
       ORG_ID,
       SITE_ID
       FROM BIS_LEVELS_CUSTOMIZATIONS
     WHERE LEVEL_ID = p_dim_level_id
       AND (user_id = fnd_global.user_id
       OR  responsibility_id = fnd_global.RESP_ID
       OR  application_id = fnd_global.RESP_APPL_ID
       OR  org_id = fnd_global.ORG_ID
       OR  site_id = 0) ;
  l_dim_lvl_custom_enabled_usr      bis_levels_customizations.enabled%TYPE;
  l_dim_lvl_custom_enabled_resp     bis_levels_customizations.enabled%TYPE;
  l_dim_lvl_custom_enabled_appl     bis_levels_customizations.enabled%TYPE;
  l_dim_lvl_custom_enabled_org      bis_levels_customizations.enabled%TYPE;
  l_dim_lvl_custom_enabled_site     bis_levels_customizations.enabled%TYPE;
BEGIN
    IF (c_cust%ISOPEN) THEN
      CLOSE c_cust;
    END IF;

    FOR cr IN c_cust LOOP
      IF (cr.user_id IS NOT NULL) THEN
        l_dim_lvl_custom_enabled_usr := cr.enabled;
      ELSIF (cr.responsibility_id IS NOT NULL) THEN
        l_dim_lvl_custom_enabled_resp := cr.enabled;
      ELSIF (cr.application_id IS NOT NULL) THEN
        l_dim_lvl_custom_enabled_appl := cr.enabled;
      ELSIF (cr.org_id IS NOT NULL) THEN
        l_dim_lvl_custom_enabled_org := cr.enabled;
      ELSIF (cr.site_id IS NOT NULL) THEN
        l_dim_lvl_custom_enabled_site := cr.enabled;
      END IF;
    END LOOP;

    IF ( l_dim_lvl_custom_enabled_usr IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_enabled_usr ;
    ELSIF (l_dim_lvl_custom_enabled_resp IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_enabled_resp ;
    ELSIF (l_dim_lvl_custom_enabled_appl IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_enabled_appl ;
    ELSIF (l_dim_lvl_custom_enabled_org IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_enabled_org ;
    ELSIF (l_dim_lvl_custom_enabled_site IS NOT NULL) THEN
      RETURN l_dim_lvl_custom_enabled_site ;
    END IF;

    RETURN NULL;
EXCEPTION
  WHEN OTHERS THEN
    IF (c_cust%ISOPEN) THEN
      CLOSE c_cust;
    END IF;
    RETURN NULL;
END get_customized_enabled;

FUNCTION isPMFDimensionLevel(p_dim_level_id IN NUMBER) RETURN BOOLEAN AS
  l_do_source                BSC_SYS_DIM_LEVELS_B.SOURCE%TYPE;
  CURSOR c_do_src(cp_dim_level_id IN VARCHAR2) IS
    SELECT do.source FROM bsc_sys_dim_levels_b do, bis_levels dl WHERE do.short_name = dl.short_name
       AND dl.level_id = cp_dim_level_id;
BEGIN
-- check if the dimension level type is of PMF and then check if this can be disabled.
  IF (c_do_src%ISOPEN) THEN
    CLOSE c_do_src;
  END IF;
  OPEN c_do_src(cp_dim_level_id => p_dim_level_id);
  FETCH c_do_src INTO l_do_source;
  CLOSE c_do_src;

  IF ( l_do_source = 'PMF')  THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF (c_do_src%ISOPEN) THEN
      CLOSE c_do_src;
    END IF;
    RETURN FALSE;
END isPMFDimensionLevel;

FUNCTION IS_TARGET_DEFINED( p_dim_level_id IN  NUMBER) RETURN BOOLEAN IS
  l_target_usage      NUMBER;
BEGIN
  SELECT COUNT(1) INTO l_target_usage FROM bis_target_levels tl, bis_target_values tv
  WHERE  (   tl.TIME_LEVEL_ID       = p_dim_level_id OR
             tl.ORG_LEVEL_ID        = p_dim_level_id OR
             tl.DIMENSION1_LEVEL_ID = p_dim_level_id OR
             tl.DIMENSION2_LEVEL_ID = p_dim_level_id OR
             tl.DIMENSION3_LEVEL_ID = p_dim_level_id OR
             tl.DIMENSION4_LEVEL_ID = p_dim_level_id OR
             tl.DIMENSION5_LEVEL_ID = p_dim_level_id OR
             tl.DIMENSION6_LEVEL_ID = p_dim_level_id OR
             tl.DIMENSION7_LEVEL_ID = p_dim_level_id
           ) AND tl.target_level_id = tv.target_level_id ;

  IF ( l_target_usage > 0 ) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

END IS_TARGET_DEFINED;

FUNCTION IS_ASSIGNED_TO_KPI( p_dim_level_id IN  NUMBER) RETURN BOOLEAN IS
  l_kpi_assing_usage  NUMBER;
BEGIN
  SELECT COUNT(1) INTO l_kpi_assing_usage FROM bsc_kpi_dim_levels_b kpi,
  bsc_sys_dim_levels_b do , bis_levels lvl
  WHERE  do.level_table_name = kpi.level_table_name
    AND  do.short_name       = lvl.short_name
    AND  lvl.level_id        = p_dim_level_id;

  IF ( l_kpi_assing_usage > 0 ) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

END IS_ASSIGNED_TO_KPI;

PROCEDURE validate_disabling (p_dim_level_id   IN  NUMBER
                          ,   p_error_Tbl      IN  BIS_UTILITIES_PUB.Error_Tbl_Type
                          ,   x_return_status  OUT NOCOPY  VARCHAR2
                          ,   x_error_Tbl      OUT NOCOPY  BIS_UTILITIES_PUB.Error_Tbl_Type
) IS
BEGIN
-- check if the dimension level type is of PMF and then check if this can be disabled.
  IF ( isPMFDimensionLevel( p_dim_level_id => p_dim_level_id )) THEN

-- check if this dimension level is used to set target
    IF ( IS_TARGET_DEFINED(p_dim_level_id => p_dim_level_id) ) THEN
        BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_PMF_DIM_LVL_USED_IN_TARGET'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Update_Dimension_Level'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => p_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;

-- check if this dimension level is assigned to a KPI
    IF ( IS_ASSIGNED_TO_KPI(p_dim_level_id => p_dim_level_id) ) THEN
        BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_BSC_DIM_LVL_KPI_ASSIGNED'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Update_Dimension_Level'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => p_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status :=  FND_API.G_RET_STS_ERROR ;
  WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END validate_disabling;

-- for the table handler , app_exception is needed. Otherwise it does not throws up in
--  customization APIs

PROCEDURE validate_disabling (p_dim_level_id IN NUMBER) IS
BEGIN
-- check if the dimension level type is of PMF and then check if this can be disabled.
  IF ( isPMFDimensionLevel( p_dim_level_id => p_dim_level_id )) THEN
-- check if this dimension level is used to set target
    IF ( IS_TARGET_DEFINED(p_dim_level_id => p_dim_level_id) ) THEN
      fnd_message.set_name('BIS','BIS_PMF_DIM_LVL_USED_IN_TARGET');
      app_exception.raise_exception;
    END IF;

-- check if this dimension level is assigned to a KPI
    IF ( IS_ASSIGNED_TO_KPI(p_dim_level_id => p_dim_level_id) ) THEN
      fnd_message.set_name('BIS', 'BIS_BSC_DIM_LVL_KPI_ASSIGNED');
      app_exception.raise_exception;
    END IF;
  END IF;
END validate_disabling;

END BIS_DIMENSION_LEVEL_PVT;

/
