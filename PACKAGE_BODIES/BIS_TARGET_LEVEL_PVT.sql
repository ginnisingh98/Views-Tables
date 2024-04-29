--------------------------------------------------------
--  DDL for Package Body BIS_TARGET_LEVEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_TARGET_LEVEL_PVT" AS
/* $Header: BISVTALB.pls 120.1 2006/01/23 01:36:21 ankgoel noship $ */
--
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVINLB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for creating and managing Indicator Levels
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 28-NOV-98 irchen Creation
REM | 23-JAN-02 sashaik Added Retrieve_Org_level procedure for 1740789
REM | 15-FEB-02-- juwang bug#2225110
REM | 26-SEP-02 SASHAIK 2486702
REM | 29-SEP-02 arhegde bug#2528442 - added retrieve_mult_targ_levels()     |
REM | 09-OCT-02 arhegde Modified for bug#2616667			    |
REM | 23-JAN-03 sugopal For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)              	            |
REM | 17-MAR-03 smuruges Modified the WHERE clause for the cursor ind_res   |
REM |                    Replaced the OR clause with nvl on sysdate.        |
REM | 30-JUN-03 rchandra Selected DATASET_ID from bisfv_target_levels to    |
REM |                    populate BIS_Target_Level_PUB.Target_Level_Rec_Type|
REM |                    for bug 3004651                                    |
REM | 21-OCT-04 arhegde bug# 3634587 The SQL used shows up on performance   |
REM | repository top-20, Removed Retrieve_Measure_Notify_Resps()            |
REM | 05-jul-04 rpenneru Modified for bug#3735203                           |
REM | 21-Mar-05 ankagarw bug#4235732 - changing count(*) to count(1)        |
REM | 23-Jan-06 ankgoel  bug#4946492 - do not update creation date on UPDATE|
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):='BIS_TARGET_LEVEL_PVT';

TYPE lvl_tbl_type IS TABLE OF bis_levels.short_name%TYPE  -- Defn added for 2486702
  INDEX BY BINARY_INTEGER;

TYPE dim_tbl_type IS TABLE OF NUMBER -- Defn added for 2486702
  INDEX BY BINARY_INTEGER;

TYPE bind_variables_tbl_type IS TABLE OF VARCHAR2(100)
  INDEX BY BINARY_INTEGER;

--
-- PROCEDUREs
--
-- returns the record with the G_MISS_CHAR/G_MISS_NUM replaced
-- by null
--
PROCEDURE SetNULL
( p_Dimension_Level_Rec    IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dimension_Level_Rec    OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
);

--==================================================================

PROCEDURE retrieve_sql(
  p_target_level_tbl IN BIS_TARGET_LEVEL_PUB.Target_Level_Tbl_Type
 ,x_is_bind OUT NOCOPY BOOLEAN
 ,x_is_execute OUT NOCOPY BOOLEAN
 ,x_sql OUT NOCOPY VARCHAR2
 ,x_bind_variables_tbl OUT NOCOPY bind_variables_tbl_type
);

--==================================================================

PROCEDURE Level_Correspond_To_Dim -- Procedure added for 2486702
(
  p_target_level_rec 	IN BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_measure_rec 		IN BIS_MEASURE_PUB.MEASURE_REC_TYPE
, x_return_status 		OUT NOCOPY VARCHAR2
, x_return_msg 			OUT NOCOPY VARCHAR2
);


PROCEDURE COMPARE_LEVELS_DIMS  -- Procedure added for 2486702
( p_dim_tbl_type     IN  dim_tbl_type
, p_lvl_tbl_type     IN  lvl_tbl_type
, p_tl_short_name    IN  VARCHAR2
, p_pm_short_name    IN  VARCHAR2
, x_return_status 	 OUT NOCOPY VARCHAR2
, x_return_msg 		 OUT NOCOPY VARCHAR2
);


FUNCTION GET_DIM_ID_FRM_LVL_SHTNM  -- Function added for 2486702
( p_level_shtnm      IN VARCHAR2)
RETURN NUMBER;


PROCEDURE GET_MEASURE_DIMS_ARRAY  -- Procedure added for 2486702
( p_measure_rec 	 IN BIS_MEASURE_PUB.MEASURE_REC_TYPE
, x_dim_tbl_type     OUT NOCOPY dim_tbl_type
, x_num_dims		 OUT NOCOPY NUMBER
, x_return_status 	 OUT NOCOPY VARCHAR2
, x_return_msg 		 OUT NOCOPY VARCHAR2
);


PROCEDURE ADD_TO_MEASURE_ARRAY  -- Procedure added for 2486702
( p_dim_tbl_type     IN OUT NOCOPY dim_tbl_type
, p_dim_id           IN     NUMBER
);


PROCEDURE GET_TL_LVLS_ARRAY  -- Procedure added for 2486702
( p_target_level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_lvl_tbl_type     OUT NOCOPY lvl_tbl_type
, x_num_lvls		 OUT NOCOPY NUMBER
, x_return_status 	 OUT NOCOPY VARCHAR2
, x_return_msg 		 OUT NOCOPY VARCHAR2
);


PROCEDURE ADD_TO_LEVEL_ARRAY  -- Procedure added for 2486702
( p_lvl_tbl_type     IN OUT NOCOPY lvl_tbl_type
, p_short_name       IN     VARCHAR
);


FUNCTION CHECK_UNIQUE_DIMS  -- Function added for 2486702
(p_dim_tbl_type     IN dim_tbl_type)
RETURN BOOLEAN;


FUNCTION CHECK_UNIQUE_LEVELS  -- Function added for 2486702
(p_lvl_tbl_type     IN lvl_tbl_type)
RETURN BOOLEAN;


FUNCTION IS_ORG_OR_TIME_LEVEL  -- Function added for 2486702
(p_lvl_short_name     IN VARCHAR2)
RETURN BOOLEAN;


FUNCTION IS_NOT_NULL_MISSING_CHAR  -- Function added for 2486702
(p_string	IN VARCHAR2)
RETURN BOOLEAN;


FUNCTION IS_NOT_NULL_MISSING_NUM  -- Function added for 2486702
(p_number	IN NUMBER)
RETURN BOOLEAN;


--
PROCEDURE SetNULL
( p_Dimension_Level_Rec IN  BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_Dimension_Level_Rec OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
)
IS
BEGIN

  x_dimension_level_rec.Dimension_ID
    := BIS_UTILITIES_PUB.G_NULL_NUM;
  x_dimension_level_rec.Dimension_Short_Name
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.Dimension_Name
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.Dimension_Level_ID
    := BIS_UTILITIES_PUB.G_NULL_NUM;
  x_dimension_level_rec.Dimension_Level_Short_Name
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.Dimension_Level_Name
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.Description
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.Level_Values_View_Name
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.where_Clause
    := BIS_UTILITIES_PUB.G_NULL_CHAR;
  x_dimension_level_rec.source
    := BIS_UTILITIES_PUB.G_NULL_CHAR;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    RAISE
    ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    RAISE;
  WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END SetNULL;
PROCEDURE Set_NULL
( p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Target_Level_Rec OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
)
IS
BEGIN

  x_target_level_rec.Measure_ID                   :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Measure_ID);
  x_target_level_rec.Measure_Short_Name            :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Measure_Short_Name);
  x_target_level_rec.Measure_Name                  :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Measure_Name);
  x_target_level_rec.Target_Level_ID              :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Target_Level_ID);
  x_target_level_rec.Target_Level_Short_Name       :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Target_Level_Short_Name);
  x_target_level_rec.Target_Level_Name             :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Target_Level_Name);
  x_target_level_rec.Description                   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Description);
  x_target_level_rec.Org_Level_ID          :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Org_Level_ID);
  x_target_level_rec.Org_Level_Short_Name   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Org_Level_Short_Name);
  x_target_level_rec.Org_Level_Name         :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Org_Level_Name);
  x_target_level_rec.Time_Level_ID          :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Time_Level_ID);
  x_target_level_rec.Time_Level_Short_Name   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Time_Level_Short_Name);
  x_target_level_rec.Time_Level_Name         :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Time_Level_Name);
  x_target_level_rec.Dimension1_Level_ID          :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Dimension1_Level_ID);
  x_target_level_rec.Dimension1_Level_Short_Name   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension1_Level_Short_Name);
  x_target_level_rec.Dimension1_Level_Name         :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension1_Level_Name);
  x_target_level_rec.Dimension2_Level_ID          :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Dimension2_Level_ID);
  x_target_level_rec.Dimension2_Level_Short_Name   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension2_Level_Short_Name);
  x_target_level_rec.Dimension2_Level_Name         :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension2_Level_Name);
  x_target_level_rec.Dimension3_Level_ID          :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Dimension3_Level_ID);
  x_target_level_rec.Dimension3_Level_Short_Name   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension3_Level_Short_Name);
  x_target_level_rec.Dimension3_Level_Name         :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension3_Level_Name);
  x_target_level_rec.Dimension4_Level_ID          :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Dimension4_Level_ID);
  x_target_level_rec.Dimension4_Level_Short_Name   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension4_Level_Short_Name);
  x_target_level_rec.Dimension4_Level_Name         :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension4_Level_Name);
  x_target_level_rec.Dimension5_Level_ID          :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Dimension5_Level_ID);
  x_target_level_rec.Dimension5_Level_Short_Name   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension5_Level_Short_Name);
  x_target_level_rec.Dimension5_Level_Name         :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension5_Level_Name);
  x_target_level_rec.Dimension6_Level_ID          :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Dimension6_Level_ID);
  x_target_level_rec.Dimension6_Level_Short_Name   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension6_Level_Short_Name);
  x_target_level_rec.Dimension6_Level_Name         :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension6_Level_Name);
  x_target_level_rec.Dimension7_Level_ID          :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Dimension7_Level_ID);
  x_target_level_rec.Dimension7_Level_Short_Name   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension7_Level_Short_Name);
  x_target_level_rec.Dimension7_Level_Name         :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Dimension7_Level_Name);
  x_target_level_rec.Workflow_Process_Short_Name   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Workflow_Process_Short_Name);
  x_target_level_rec.Workflow_Process_Name         :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Workflow_Process_Name);
  x_target_level_rec.Workflow_Item_Type            :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Workflow_Item_Type);
  x_target_level_rec.Default_Notify_Resp_ID       :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Default_Notify_Resp_ID);
  x_target_level_rec.Default_Notify_Resp_short_name:=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Default_Notify_Resp_short_name);
  x_target_level_rec.Default_Notify_Resp_Name      :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Default_Notify_Resp_Name);
  x_target_level_rec.Computing_Function_ID        :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Computing_Function_ID);
  x_target_level_rec.Computing_Function_Name       :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Computing_Function_Name);
  x_target_level_rec.Computing_User_Function_Name  :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Computing_User_Function_Name);
  x_target_level_rec.Report_Function_ID           :=
  BIS_UTILITIES_PVT.CheckMissNum(p_target_level_rec.Report_Function_ID);
  x_target_level_rec.Report_Function_Name          :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Report_Function_Name);
  x_target_level_rec.Report_User_Function_Name     :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Report_User_Function_Name);
  x_target_level_rec.Unit_Of_Measure               :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.Unit_Of_Measure);
  x_target_level_rec.System_Flag                   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.System_Flag);
  x_target_level_rec.SOURCE                   :=
  BIS_UTILITIES_PVT.CheckMissChar(p_target_level_rec.SOURCE);
END;

FUNCTION Get_Level_Id_From_Short_Name
( p_tl_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
) RETURN NUMBER
IS
cursor short_name_cursor IS
select target_level_id
from bis_target_levels
where short_name like p_tl_rec.target_level_short_name;
l_dummy number := NULL;
BEGIN

  open short_name_cursor;
  fetch short_name_cursor into l_dummy;
  if (short_name_cursor%NOTFOUND) then
    close short_name_cursor;
    return NULL;
  end if;
  close short_name_cursor;

  return l_dummy;

END Get_Level_Id_From_Short_Name;

FUNCTION Get_Level_Id_From_Dimlevels
( p_tl_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
) RETURN NUMBER
IS
--changed cursor
cursor dimlevel_cursor(p_tl_curs_rec BIS_Target_Level_PUB.Target_Level_Rec_Type) IS
select target_level_id
from bis_target_levels
where NVL(INDICATOR_ID, -1) = NVL(p_tl_curs_rec.Measure_Id, -1)
AND (p_tl_curs_rec.Org_Level_Id IS NULL OR NVL(ORG_LEVEL_ID, -1)   = NVL(p_tl_curs_rec.Org_Level_Id, -1))
AND (p_tl_curs_rec.Time_Level_Id IS NULL OR NVL(TIME_LEVEL_ID, -1)  = NVL(p_tl_curs_rec.Time_Level_Id, -1))
AND NVL(DIMENSION1_LEVEL_ID, -1) = NVL(p_tl_curs_rec.Dimension1_Level_Id, -1)
AND NVL(DIMENSION2_LEVEL_ID, -1) = NVL(p_tl_curs_rec.Dimension2_Level_Id, -1)
AND NVL(DIMENSION3_LEVEL_ID, -1) = NVL(p_tl_curs_rec.Dimension3_Level_Id, -1)
AND NVL(DIMENSION4_LEVEL_ID, -1) = NVL(p_tl_curs_rec.Dimension4_Level_Id, -1)
AND NVL(DIMENSION5_LEVEL_ID, -1) = NVL(p_tl_curs_rec.Dimension5_Level_Id, -1)
AND NVL(DIMENSION6_LEVEL_ID, -1) = NVL(p_tl_curs_rec.Dimension6_Level_Id, -1)
AND NVL(DIMENSION7_LEVEL_ID, -1) = NVL(p_tl_curs_rec.Dimension7_Level_Id, -1);

l_dummy number;
l_tl_Rec BIS_Target_Level_PUB.Target_Level_Rec_Type;
BEGIN
  --set null first
  Set_NULL(  p_Target_Level_Rec   => p_tl_Rec
          , x_Target_Level_Rec   => l_tl_Rec);

  open dimlevel_cursor(l_tl_Rec);
  fetch dimlevel_cursor into l_dummy;

  if (dimlevel_cursor%NOTFOUND) then
    close dimlevel_cursor;
    return NULL;
  end if;
  close dimlevel_cursor;

  return l_dummy;

END Get_Level_Id_From_Dimlevels;

-----------------------------------------------------------------------------
-- New Function to return TargetLevelId given the DimensionLevel ShortNames
-- and the Measure Short Name

FUNCTION Get_Id_From_DimLevelShortNames
( p_target_level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
) RETURN NUMBER
IS

l_target_level_id number;

l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
l_Measure_Rec BIS_MEASURE_PUB.Measure_Rec_Type;
l_target_level_rec BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_return_status VARCHAR2(100);
l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_Measure_Rec_p BIS_MEASURE_PUB.Measure_Rec_Type;
l_Dimension_Level_Rec_p BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;

BEGIN
   if (BIS_UTILITIES_PUB.Value_Missing(p_target_level_rec.Measure_ID)
                       = FND_API.G_TRUE) then
      if (BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.Measure_Short_Name)
                       = FND_API.G_TRUE) then

         l_Measure_Rec.Measure_Short_Name := p_target_level_rec.Measure_Short_Name;

	 l_Measure_Rec_p := l_Measure_Rec;
         BIS_Measure_PVT.Measure_Value_ID_Conversion
         ( p_api_version   => 1.0
	 , p_Measure_Rec   => l_Measure_Rec_p
	 , x_Measure_Rec   => l_Measure_Rec
	 , x_return_status => l_return_status
	 , x_error_Tbl     => l_error_Tbl
	 );
         if(l_return_status = FND_API.G_RET_STS_SUCCESS) then
           l_target_level_rec.Measure_ID := l_Measure_Rec.Measure_ID;

         end if;
      end if;
   else
      l_target_level_rec.Measure_ID := p_target_level_rec.Measure_ID;
   end if;

   if (BIS_UTILITIES_PUB.Value_Missing(p_target_level_rec.Org_Level_ID)
                       = FND_API.G_TRUE) then
      if (BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.Org_Level_Short_Name)
                       = FND_API.G_TRUE) then
         l_Dimension_Level_Rec.Dimension_Level_Short_Name := p_target_level_rec.Org_Level_Short_Name;

         l_Dimension_Level_Rec_p := l_Dimension_Level_Rec;
         BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
         ( p_api_version         => 1.0
         , p_Dimension_Level_Rec => l_Dimension_Level_Rec_p
         , x_Dimension_Level_Rec => l_Dimension_Level_Rec
         , x_return_status       => l_return_status
         , x_error_Tbl           => l_error_tbl
         );
         if(l_return_status = FND_API.G_RET_STS_SUCCESS) then
           l_target_level_rec.Org_Level_ID := l_Dimension_Level_Rec.Dimension_Level_Id;

         end if;
      end if;
   else
      l_target_level_rec.Org_Level_ID := p_target_level_rec.Org_Level_ID;

   end if;
   l_Dimension_Level_Rec.Dimension_Level_Short_Name := BIS_UTILITIES_PUB.G_NULL_CHAR;
   l_Dimension_Level_Rec.Dimension_Level_Id := BIS_UTILITIES_PUB.G_NULL_NUM;

   if (BIS_UTILITIES_PUB.Value_Missing(p_target_level_rec.Time_Level_ID)
                       = FND_API.G_TRUE) then
      if (BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.Time_Level_Short_Name)
                       = FND_API.G_TRUE) then
         l_Dimension_Level_Rec.Dimension_Level_Short_Name := p_target_level_rec.Time_Level_Short_Name;

         l_Dimension_Level_Rec_p := l_Dimension_Level_Rec;
         BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
         ( p_api_version         => 1.0
         , p_Dimension_Level_Rec => l_Dimension_Level_Rec_p
         , x_Dimension_Level_Rec => l_Dimension_Level_Rec
         , x_return_status       => l_return_status
         , x_error_Tbl           => l_error_tbl
         );
         if(l_return_status = FND_API.G_RET_STS_SUCCESS) then
           l_target_level_rec.Time_Level_ID := l_Dimension_Level_Rec.Dimension_Level_Id;

         end if;
      end if;
   else
      l_target_level_rec.Time_Level_ID := p_target_level_rec.Time_Level_ID;

   end if;
   l_Dimension_Level_Rec.Dimension_Level_Short_Name := BIS_UTILITIES_PUB.G_NULL_CHAR;
   l_Dimension_Level_Rec.Dimension_Level_Id := BIS_UTILITIES_PUB.G_NULL_NUM;


   if (BIS_UTILITIES_PUB.Value_Missing(p_target_level_rec.Dimension1_Level_ID)
                       = FND_API.G_TRUE) then
      if (BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.Dimension1_Level_Short_Name)
                       = FND_API.G_TRUE) then
         l_Dimension_Level_Rec.Dimension_Level_Short_Name := p_target_level_rec.Dimension1_Level_Short_Name;

	 l_Dimension_Level_Rec_p := l_Dimension_Level_Rec;
         BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
         ( p_api_version         => 1.0
         , p_Dimension_Level_Rec => l_Dimension_Level_Rec_p
         , x_Dimension_Level_Rec => l_Dimension_Level_Rec
         , x_return_status       => l_return_status
         , x_error_Tbl           => l_error_tbl
         );
         if(l_return_status = FND_API.G_RET_STS_SUCCESS) then
           l_target_level_rec.Dimension1_Level_ID := l_Dimension_Level_Rec.Dimension_Level_Id;

         end if;
      end if;
   else
      l_target_level_rec.Dimension1_Level_ID := p_target_level_rec.Dimension1_Level_ID;

   end if;
   l_Dimension_Level_Rec.Dimension_Level_Short_Name := BIS_UTILITIES_PUB.G_NULL_CHAR;
   l_Dimension_Level_Rec.Dimension_Level_Id := BIS_UTILITIES_PUB.G_NULL_NUM;


   if (BIS_UTILITIES_PUB.Value_Missing(p_target_level_rec.Dimension2_Level_ID)
                       = FND_API.G_TRUE) then
      if (BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.Dimension2_Level_Short_Name)
                       = FND_API.G_TRUE) then
         l_Dimension_Level_Rec.Dimension_Level_Short_Name := p_target_level_rec.Dimension2_Level_Short_Name;

	 l_Dimension_Level_Rec_p := l_Dimension_Level_Rec;
         BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
         ( p_api_version         => 1.0
         , p_Dimension_Level_Rec => l_Dimension_Level_Rec_p
         , x_Dimension_Level_Rec => l_Dimension_Level_Rec
         , x_return_status       => l_return_status
         , x_error_Tbl           => l_error_tbl
         );
         if(l_return_status = FND_API.G_RET_STS_SUCCESS) then
           l_target_level_rec.Dimension2_Level_ID := l_Dimension_Level_Rec.Dimension_Level_Id;

         end if;
      end if;
   else
      l_target_level_rec.Dimension2_Level_ID := p_target_level_rec.Dimension2_Level_ID;

   end if;
   l_Dimension_Level_Rec.Dimension_Level_Short_Name := BIS_UTILITIES_PUB.G_NULL_CHAR;
   l_Dimension_Level_Rec.Dimension_Level_Id := BIS_UTILITIES_PUB.G_NULL_NUM;

  if (BIS_UTILITIES_PUB.Value_Missing(p_target_level_rec.Dimension3_Level_ID)
                       = FND_API.G_TRUE) then
      if (BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.Dimension3_Level_Short_Name)
                       = FND_API.G_TRUE) then
         l_Dimension_Level_Rec.Dimension_Level_Short_Name := p_target_level_rec.Dimension3_Level_Short_Name;

	 l_Dimension_Level_Rec_p := l_Dimension_Level_Rec;
         BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
         ( p_api_version         => 1.0
         , p_Dimension_Level_Rec => l_Dimension_Level_Rec_p
         , x_Dimension_Level_Rec => l_Dimension_Level_Rec
         , x_return_status       => l_return_status
         , x_error_Tbl           => l_error_tbl
         );
         if(l_return_status = FND_API.G_RET_STS_SUCCESS) then
           l_target_level_rec.Dimension3_Level_ID := l_Dimension_Level_Rec.Dimension_Level_Id;

         end if;
       end if;
   else
      l_target_level_rec.Dimension3_Level_ID := p_target_level_rec.Dimension3_Level_ID;

   end if;
   l_Dimension_Level_Rec.Dimension_Level_Short_Name := BIS_UTILITIES_PUB.G_NULL_CHAR;
   l_Dimension_Level_Rec.Dimension_Level_Id := BIS_UTILITIES_PUB.G_NULL_NUM;


   if (BIS_UTILITIES_PUB.Value_Missing(p_target_level_rec.Dimension4_Level_ID)
                       = FND_API.G_TRUE) then
      if (BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.Dimension4_Level_Short_Name)
                       = FND_API.G_TRUE) then
         l_Dimension_Level_Rec.Dimension_Level_Short_Name := p_target_level_rec.Dimension4_Level_Short_Name;

         l_Dimension_Level_Rec_p := l_Dimension_Level_Rec;
         BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
         ( p_api_version         => 1.0
         , p_Dimension_Level_Rec => l_Dimension_Level_Rec_p
         , x_Dimension_Level_Rec => l_Dimension_Level_Rec
         , x_return_status       => l_return_status
         , x_error_Tbl           => l_error_tbl
         );
         if(l_return_status = FND_API.G_RET_STS_SUCCESS) then
           l_target_level_rec.Dimension4_Level_ID := l_Dimension_Level_Rec.Dimension_Level_Id;

         end if;
       end if;
   else
      l_target_level_rec.Dimension4_Level_ID := p_target_level_rec.Dimension4_Level_ID;

   end if;
   l_Dimension_Level_Rec.Dimension_Level_Short_Name := BIS_UTILITIES_PUB.G_NULL_CHAR;
   l_Dimension_Level_Rec.Dimension_Level_Id := BIS_UTILITIES_PUB.G_NULL_NUM;

   if (BIS_UTILITIES_PUB.Value_Missing(p_target_level_rec.Dimension5_Level_ID)
                       = FND_API.G_TRUE) then
      if (BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.Dimension5_Level_Short_Name)
                       = FND_API.G_TRUE) then
         l_Dimension_Level_Rec.Dimension_Level_Short_Name := p_target_level_rec.Dimension5_Level_Short_Name;
	 l_Dimension_Level_Rec_p := l_Dimension_Level_Rec;
         BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
         ( p_api_version         => 1.0
         , p_Dimension_Level_Rec => l_Dimension_Level_Rec_p
         , x_Dimension_Level_Rec => l_Dimension_Level_Rec
         , x_return_status       => l_return_status
         , x_error_Tbl           => l_error_tbl
         );
         if(l_return_status = FND_API.G_RET_STS_SUCCESS) then
           l_target_level_rec.Dimension5_Level_ID := l_Dimension_Level_Rec.Dimension_Level_Id;
         end if;
       end if;
   else
      l_target_level_rec.Dimension5_Level_ID := p_target_level_rec.Dimension5_Level_ID;
   end if;
   l_Dimension_Level_Rec.Dimension_Level_Short_Name := BIS_UTILITIES_PUB.G_NULL_CHAR;
   l_Dimension_Level_Rec.Dimension_Level_Id := BIS_UTILITIES_PUB.G_NULL_NUM;

   if (BIS_UTILITIES_PUB.Value_Missing(p_target_level_rec.Dimension6_Level_ID)
                       = FND_API.G_TRUE) then
      if (BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.Dimension6_Level_Short_Name)
                       = FND_API.G_TRUE) then
         l_Dimension_Level_Rec.Dimension_Level_Short_Name := p_target_level_rec.Dimension6_Level_Short_Name;
	 l_Dimension_Level_Rec_p := l_Dimension_Level_Rec;
         BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
         ( p_api_version         => 1.0
         , p_Dimension_Level_Rec => l_Dimension_Level_Rec_p
         , x_Dimension_Level_Rec => l_Dimension_Level_Rec
         , x_return_status       => l_return_status
         , x_error_Tbl           => l_error_tbl
         );
         if(l_return_status = FND_API.G_RET_STS_SUCCESS) then
           l_target_level_rec.Dimension6_Level_ID := l_Dimension_Level_Rec.Dimension_Level_Id;
         end if;
       end if;
   else
      l_target_level_rec.Dimension6_Level_ID := p_target_level_rec.Dimension6_Level_ID;
   end if;
   l_Dimension_Level_Rec.Dimension_Level_Short_Name := BIS_UTILITIES_PUB.G_NULL_CHAR;
   l_Dimension_Level_Rec.Dimension_Level_Id := BIS_UTILITIES_PUB.G_NULL_NUM;

   if (BIS_UTILITIES_PUB.Value_Missing(p_target_level_rec.Dimension7_Level_ID)
                       = FND_API.G_TRUE) then
      if (BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.Dimension7_Level_Short_Name)
                       = FND_API.G_TRUE) then
         l_Dimension_Level_Rec.Dimension_Level_Short_Name := p_target_level_rec.Dimension7_Level_Short_Name;
	 l_Dimension_Level_Rec_p := l_Dimension_Level_Rec;
         BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
         ( p_api_version         => 1.0
         , p_Dimension_Level_Rec => l_Dimension_Level_Rec_p
         , x_Dimension_Level_Rec => l_Dimension_Level_Rec
         , x_return_status       => l_return_status
         , x_error_Tbl           => l_error_tbl
         );
         if(l_return_status = FND_API.G_RET_STS_SUCCESS) then
           l_target_level_rec.Dimension7_Level_ID := l_Dimension_Level_Rec.Dimension_Level_Id;
         end if;
       end if;
   else
      l_target_level_rec.Dimension7_Level_ID := p_target_level_rec.Dimension7_Level_ID;
   end if;
   l_Dimension_Level_Rec.Dimension_Level_Short_Name := BIS_UTILITIES_PUB.G_NULL_CHAR;
   l_Dimension_Level_Rec.Dimension_Level_Id := BIS_UTILITIES_PUB.G_NULL_NUM;

   l_target_level_id := Get_Level_Id_From_Dimlevels(l_target_level_rec);

  return l_target_level_id;
END Get_Id_From_DimLevelShortNames;
----------------------------



-- creates one Indicator Level
PROCEDURE Create_Target_Level
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Create_Target_Level
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Target_Level_Rec  => p_Target_Level_Rec
  , p_owner             => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

--commented RAISE
EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --Added last two parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Create_Target_Level'
    , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Create_Target_Level;
--
-- creates one Indicator Level for the given owner
PROCEDURE Create_Target_Level
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_owner            IN  VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id          NUMBER;
l_login_id         NUMBER;
l_id               NUMBER;
l_Target_Level_Rec BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Target_Level_Id  NUMBER;
l_error_tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;

-- l_msg		VARCHAR2(3000); -- 2515991


DUPLICATE_DIMENSION_VALUE EXCEPTION;
PRAGMA EXCEPTION_INIT(DUPLICATE_DIMENSION_VALUE, -1);

BEGIN

  /* -- 2515991
  fnd_message.set_name('BIS', 'BIS_SUMLVL_NOT_CREATED');
  fnd_message.set_token('NAME', p_Target_Level_Rec.target_level_name );
  l_msg := fnd_message.get;

  l_msg := ' The Summary level ' || nvl( p_Target_Level_Rec.target_level_name , ' ' ) ;
  l_msg := l_msg || ' could not be created/updated.';
  */

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  Set_NULL(  p_Target_Level_Rec   => p_Target_Level_Rec
           , x_Target_Level_Rec   => l_Target_Level_Rec);


  Validate_Target_Level
  ( p_api_version      	  => p_api_version
  , p_validation_level 	  => p_validation_level
  , p_Target_Level_Rec    => p_Target_Level_Rec
  , x_return_status    	  => x_return_status
  , x_error_Tbl        	  => x_error_Tbl
  );


  --
  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  l_target_level_Id := Get_Level_Id_From_Short_Name(p_target_level_rec);
  if (l_target_level_id is NOT NULL) then
  --added last two params
  l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_TRG_LVL_SHORT_NAME_UNIQUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Create_Target_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_target_level_Id := Get_Level_Id_From_dimlevels(p_target_level_rec);

  if (l_target_level_id is NOT NULL) then
    --added last two params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_TRG_LVL_DIMLEVELS_UNIQUE'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Create_Target_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  end if;

  IF p_owner = BIS_UTILITIES_PUB.G_SEED_OWNER THEN
    l_user_id := BIS_UTILITIES_PUB.G_SEED_USER_ID;
  ELSE
    l_user_id := fnd_global.user_id;
  END IF;
  l_login_id := fnd_global.LOGIN_ID;

  IF (BIS_UTILITIES_PUB.Value_Missing(l_Target_Level_Rec.system_flag)
        = FND_API.G_TRUE)
  OR (BIS_UTILITIES_PUB.Value_NULL(l_Target_Level_Rec.system_flag)
        = FND_API.G_TRUE)
  THEN
    l_Target_Level_Rec.system_flag := 'N';
  END IF;



  select bis_target_levels_s.NEXTVAL into l_id from dual;
  --

  insert into bis_TARGET_LEVELS (
    TARGET_LEVEL_ID,
    INDICATOR_ID,
    SHORT_NAME,
    ORG_LEVEL_ID,
    TIME_LEVEL_ID,
    DIMENSION1_LEVEL_ID,
    DIMENSION2_LEVEL_ID,
    DIMENSION3_LEVEL_ID,
    DIMENSION4_LEVEL_ID,
    DIMENSION5_LEVEL_ID,
    DIMENSION6_LEVEL_ID,
    DIMENSION7_LEVEL_ID,
    WF_PROCESS,
    WF_ITEM_TYPE,
    REPORT_FUNCTION_ID,
    DEFAULT_COMPUTING_FUNCTION_ID,
--    UNIT_OF_MEASURE,
    DEFAULT_ROLE_ID,
    DEFAULT_ROLE,
    SYSTEM_FLAG,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SOURCE
  )
  values
  ( l_id
  , l_Target_Level_Rec.Measure_ID
  , l_Target_Level_Rec.Target_Level_Short_Name
  , l_Target_Level_Rec.Org_Level_ID
  , l_Target_Level_Rec.Time_Level_ID
  , l_Target_Level_Rec.Dimension1_Level_ID
  , l_Target_Level_Rec.Dimension2_Level_ID
  , l_Target_Level_Rec.Dimension3_Level_ID
  , l_Target_Level_Rec.Dimension4_Level_ID
  , l_Target_Level_Rec.Dimension5_Level_ID
  , l_Target_Level_Rec.Dimension6_Level_ID
  , l_Target_Level_Rec.Dimension7_Level_ID
  , l_Target_Level_Rec.Workflow_Process_Short_Name
  , l_Target_Level_Rec.Workflow_Item_Type
  , l_Target_Level_Rec.Report_Function_ID
  , l_target_level_rec.Computing_function_ID
--  , l_Target_Level_Rec.Unit_Of_Measure
  , l_Target_Level_Rec.Default_Notify_Resp_ID
  , l_Target_Level_Rec.Default_Notify_Resp_short_name
    , l_Target_Level_Rec.system_flag
  , SYSDATE
  , l_user_id
  , SYSDATE
  , l_user_id
  , l_login_id
  , l_target_level_rec.Source
  );

  insert into bis_TARGET_LEVELS_TL (
    TARGET_LEVEL_ID,
    LANGUAGE,
    NAME,
    DESCRIPTION,
    UNIT_OF_MEASURE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    TRANSLATED,
    SOURCE_LANG
  ) select
    l_id
  , L.LANGUAGE_CODE
  , l_Target_Level_Rec.Target_Level_Name
  , l_Target_Level_Rec.Description
  , l_Target_Level_Rec.Unit_Of_Measure
  , SYSDATE
  , l_user_id
  , SYSDATE
  , l_user_id
  , l_login_id
  ,  'Y'
  , userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from bis_TARGET_LEVELS_TL T
    where T.TARGET_LEVEL_ID = l_id
    and T.LANGUAGE = L.LANGUAGE_CODE);

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

--commented RAISE
EXCEPTION
   --added this
   WHEN DUPLICATE_DIMENSION_VALUE THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_TAR_LEVEL_UNIQUENESS_ERROR'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Create_Target_Level'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      -- BIS_UTILITIES_PUB.put_line(p_text => l_msg ) ; -- 2515991

   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      -- BIS_UTILITIES_PUB.put_line(p_text => l_msg ) ;-- 2515991

   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      -- BIS_UTILITIES_PUB.put_line(p_text => l_msg ) ;  -- 2515991

   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      -- BIS_UTILITIES_PUB.put_line(p_text => l_msg ) ; -- 2515991

      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Create_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );

END Create_Target_Level;
--
PROCEDURE Count_Target_Levels
( p_api_version         IN  NUMBER
, p_Measure_Rec         IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_count               OUT NOCOPY NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  select count(1) into x_count
    from bis_target_levels
    where indicator_id = p_Measure_Rec.Measure_id;

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Count_Target_Levels'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Count_Target_Levels;
--
-- Gets All Indicator Levels
-- If information about the dimensions are not required, set all_info to
-- FALSE
PROCEDURE Retrieve_Target_Levels
( p_api_version         IN  NUMBER
, p_all_info            IN  VARCHAR2   := FND_API.G_TRUE
, p_Measure_Rec         IN  BIS_MEASURE_PUB.Measure_Rec_Type
, x_Target_Level_tbl OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Tbl_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

i                     NUMBER := 0;
l_Measure_id          NUMBER;
l_Target_Level_rec    BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_error_tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;

cursor tar_level_bv IS
    Select measure_id
  	 , TARGET_LEVEL_ID
  	 , TARGET_LEVEL_SHORT_NAME
  	 , TARGET_LEVEL_NAME
  	 , DESCRIPTION
  	 , ORG_LEVEL_ID
  	 , TIME_LEVEL_ID
  	 , DIMENSION1_LEVEL_ID
  	 , DIMENSION2_LEVEL_ID
  	 , DIMENSION3_LEVEL_ID
  	 , DIMENSION4_LEVEL_ID
  	 , DIMENSION5_LEVEL_ID
  	 , DIMENSION6_LEVEL_ID
  	 , DIMENSION7_LEVEL_ID
  	 , WORKFLOW_ITEM_TYPE
  	 , WORKFLOW_PROCESS_SHORT_NAME
  	 , DEFAULT_NOTIFY_RESP_ID
  	 , DEFAULT_NOTIFY_RESP_SHORT_NAME
  	 , COMPUTING_FUNCTION_ID
  	 , REPORT_FUNCTION_ID
  	 , UNIT_OF_MEASURE
  	 , SYSTEM_FLAG
    from bisbv_target_levels
    where measure_id = l_Measure_id;

cursor tar_level_fv IS
    select TARGET_LEVEL_ID
         , TARGET_LEVEL_SHORT_NAME
         , TARGET_LEVEL_NAME
         , DESCRIPTION
         , MEASURE_ID
         , MEASURE_SHORT_NAME
         , MEASURE_NAME
         , ORG_LEVEL_ID
         , ORG_LEVEL_SHORT_NAME
         , ORG_LEVEL_NAME
         , TIME_LEVEL_ID
         , TIME_LEVEL_SHORT_NAME
         , TIME_LEVEL_NAME
         , DIMENSION1_LEVEL_ID
         , DIMENSION1_LEVEL_SHORT_NAME
         , DIMENSION1_LEVEL_NAME
         , DIMENSION2_LEVEL_ID
         , DIMENSION2_LEVEL_SHORT_NAME
         , DIMENSION2_LEVEL_NAME
         , DIMENSION3_LEVEL_ID
         , DIMENSION3_LEVEL_SHORT_NAME
         , DIMENSION3_LEVEL_NAME
         , DIMENSION4_LEVEL_ID
         , DIMENSION4_LEVEL_SHORT_NAME
         , DIMENSION4_LEVEL_NAME
         , DIMENSION5_LEVEL_ID
         , DIMENSION5_LEVEL_SHORT_NAME
         , DIMENSION5_LEVEL_NAME
         , DIMENSION6_LEVEL_ID
         , DIMENSION6_LEVEL_SHORT_NAME
         , DIMENSION6_LEVEL_NAME
         , DIMENSION7_LEVEL_ID
         , DIMENSION7_LEVEL_SHORT_NAME
         , DIMENSION7_LEVEL_NAME
         , WORKFLOW_ITEM_TYPE
         , WORKFLOW_PROCESS_SHORT_NAME
         , WORKFLOW_PROCESS_NAME
         , DEFAULT_NOTIFY_RESP_ID
         , DEFAULT_NOTIFY_RESP_SHORT_NAME
         , DEFAULT_NOTIFY_RESP_NAME
         , COMPUTING_FUNCTION_ID
         , COMPUTING_FUNCTION_NAME
         , COMPUTING_USER_FUNCTION_NAME
         , REPORT_FUNCTION_ID
         , REPORT_FUNCTION_NAME
         , REPORT_USER_FUNCTION_NAME
         , UNIT_OF_MEASURE
         , SYSTEM_FLAG
         , DATASET_ID
    from bisfv_target_levels
    where measure_id = l_Measure_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_measure_id := p_Measure_Rec.Measure_id;

  if (p_all_info = FND_API.G_FALSE) then
    FOR cr in tar_level_bv LOOP
      i := i+1;

      l_Target_Level_rec.measure_id                    := cr.measure_id;
      l_Target_Level_rec.Target_Level_id	       := cr.TARGET_LEVEL_ID;
      l_Target_Level_rec.Target_Level_short_name       := cr.TARGET_LEVEL_SHORT_NAME;
      l_Target_Level_rec.Target_Level_name	       := cr.TARGET_LEVEL_NAME;
      l_Target_Level_rec.description		       := cr.DESCRIPTION;
      l_Target_Level_rec.org_level_id	            := cr.ORG_LEVEL_ID;
      l_Target_Level_rec.time_level_id	            := cr.TIME_LEVEL_ID;
      l_Target_Level_rec.dimension1_level_id	    := cr.DIMENSION1_LEVEL_ID;
      l_Target_Level_rec.dimension2_level_id	    := cr.DIMENSION2_LEVEL_ID;
      l_Target_Level_rec.dimension3_level_id	    := cr.DIMENSION3_LEVEL_ID;
      l_Target_Level_rec.dimension4_level_id	    := cr.DIMENSION4_LEVEL_ID;
      l_Target_Level_rec.dimension5_level_id	    := cr.DIMENSION5_LEVEL_ID;
      l_Target_Level_rec.dimension6_level_id	    := cr.DIMENSION6_LEVEL_ID;
      l_Target_Level_rec.dimension7_level_id	    := cr.DIMENSION7_LEVEL_ID;
      l_Target_Level_rec.Workflow_Item_Type	    := cr.WORKFLOW_ITEM_TYPE;
      l_Target_Level_rec.Workflow_process_short_name :=
	                                        cr.WORKFLOW_PROCESS_SHORT_NAME;
      l_Target_Level_rec.Default_Notify_Resp_ID	 := cr.DEFAULT_NOTIFY_RESP_ID;
      l_Target_Level_rec.Default_Notify_Resp_short_name :=
	                                     cr.DEFAULT_NOTIFY_RESP_SHORT_NAME;
      l_Target_Level_rec.Computing_Function_Id	:= cr.COMPUTING_FUNCTION_ID;
      l_Target_Level_rec.Report_Function_ID	:= cr.REPORT_FUNCTION_ID;
      l_Target_Level_rec.Unit_Of_Measure	:= cr.UNIT_OF_MEASURE;
      l_Target_Level_rec.system_flag	        := cr.SYSTEM_FLAG;

      x_Target_Level_Tbl(i) := l_Target_Level_rec;
    END LOOP;

  else

    FOR cr in tar_level_fv LOOP
      i := i+1;

      l_target_level_rec.TARGET_LEVEL_ID         := cr.TARGET_LEVEL_ID;
      l_target_level_rec.TARGET_LEVEL_SHORT_NAME := cr.TARGET_LEVEL_SHORT_NAME;
      l_target_level_rec.TARGET_LEVEL_NAME       := cr.TARGET_LEVEL_NAME;
      l_target_level_rec.DESCRIPTION             := cr.DESCRIPTION;
      l_target_level_rec.MEASURE_ID              := cr.MEASURE_ID;
      l_target_level_rec.MEASURE_SHORT_NAME      := cr.MEASURE_SHORT_NAME;
      l_target_level_rec.MEASURE_NAME            := cr.MEASURE_NAME;
      l_target_level_rec.ORG_LEVEL_ID     := cr.ORG_LEVEL_ID;
      l_target_level_rec.ORG_LEVEL_SHORT_NAME :=
                                                cr.ORG_LEVEL_SHORT_NAME;
      l_target_level_rec.ORG_LEVEL_NAME   := cr.ORG_LEVEL_NAME;
      l_target_level_rec.TIME_LEVEL_ID     := cr.TIME_LEVEL_ID;
      l_target_level_rec.TIME_LEVEL_SHORT_NAME :=
                                                cr.TIME_LEVEL_SHORT_NAME;
      l_target_level_rec.TIME_LEVEL_NAME   := cr.TIME_LEVEL_NAME;
      l_target_level_rec.DIMENSION1_LEVEL_ID     := cr.DIMENSION1_LEVEL_ID;
      l_target_level_rec.DIMENSION1_LEVEL_SHORT_NAME :=
                                                cr.DIMENSION1_LEVEL_SHORT_NAME;
      l_target_level_rec.DIMENSION1_LEVEL_NAME   := cr.DIMENSION1_LEVEL_NAME;
      l_target_level_rec.DIMENSION2_LEVEL_ID     := cr.DIMENSION2_LEVEL_ID;
      l_target_level_rec.DIMENSION2_LEVEL_SHORT_NAME :=
                                                cr.DIMENSION2_LEVEL_SHORT_NAME;
      l_target_level_rec.DIMENSION2_LEVEL_NAME   := cr.DIMENSION2_LEVEL_NAME;
      l_target_level_rec.DIMENSION3_LEVEL_ID     := cr.DIMENSION3_LEVEL_ID;
      l_target_level_rec.DIMENSION3_LEVEL_SHORT_NAME :=
	                                        cr.DIMENSION3_LEVEL_SHORT_NAME;
      l_target_level_rec.DIMENSION3_LEVEL_NAME   := cr.DIMENSION3_LEVEL_NAME;
      l_target_level_rec.DIMENSION4_LEVEL_ID     := cr.DIMENSION4_LEVEL_ID;
      l_target_level_rec.DIMENSION4_LEVEL_SHORT_NAME :=
	                                        cr.DIMENSION4_LEVEL_SHORT_NAME;
      l_target_level_rec.DIMENSION4_LEVEL_NAME  := cr.DIMENSION4_LEVEL_NAME;
      l_target_level_rec.DIMENSION5_LEVEL_ID    := cr.DIMENSION5_LEVEL_ID;
      l_target_level_rec.DIMENSION5_LEVEL_SHORT_NAME :=
	                                        cr.DIMENSION5_LEVEL_SHORT_NAME;
      l_target_level_rec.DIMENSION5_LEVEL_NAME := cr.DIMENSION5_LEVEL_NAME;
      l_target_level_rec.DIMENSION6_LEVEL_ID    := cr.DIMENSION6_LEVEL_ID;
      l_target_level_rec.DIMENSION6_LEVEL_SHORT_NAME :=
	                                        cr.DIMENSION6_LEVEL_SHORT_NAME;
      l_target_level_rec.DIMENSION6_LEVEL_NAME := cr.DIMENSION6_LEVEL_NAME;
      l_target_level_rec.DIMENSION7_LEVEL_ID    := cr.DIMENSION7_LEVEL_ID;
      l_target_level_rec.DIMENSION7_LEVEL_SHORT_NAME :=
	                                        cr.DIMENSION7_LEVEL_SHORT_NAME;
      l_target_level_rec.DIMENSION7_LEVEL_NAME := cr.DIMENSION7_LEVEL_NAME;
      l_target_level_rec.WORKFLOW_ITEM_TYPE    := cr.WORKFLOW_ITEM_TYPE;
      l_target_level_rec.WORKFLOW_PROCESS_SHORT_NAME :=
	                                        cr.WORKFLOW_PROCESS_SHORT_NAME;
      l_target_level_rec.WORKFLOW_PROCESS_NAME  := cr.WORKFLOW_PROCESS_NAME;
      l_target_level_rec.DEFAULT_NOTIFY_RESP_ID := cr.DEFAULT_NOTIFY_RESP_ID;
      l_target_level_rec.DEFAULT_NOTIFY_RESP_SHORT_NAME :=
	                                     cr.DEFAULT_NOTIFY_RESP_SHORT_NAME;
      l_target_level_rec.DEFAULT_NOTIFY_RESP_NAME:=cr.DEFAULT_NOTIFY_RESP_NAME;
      l_target_level_rec.COMPUTING_FUNCTION_ID   := cr.COMPUTING_FUNCTION_ID;
      l_target_level_rec.COMPUTING_FUNCTION_NAME := cr.COMPUTING_FUNCTION_NAME;
      l_target_level_rec.COMPUTING_USER_FUNCTION_NAME  :=
	                                       cr.COMPUTING_USER_FUNCTION_NAME;
      l_target_level_rec.REPORT_FUNCTION_ID     := cr.REPORT_FUNCTION_ID;
      l_target_level_rec.REPORT_FUNCTION_NAME   := cr.REPORT_FUNCTION_NAME;
      l_target_level_rec.REPORT_USER_FUNCTION_NAME :=
	                                         cr.REPORT_USER_FUNCTION_NAME;
      l_target_level_rec.UNIT_OF_MEASURE               := cr.UNIT_OF_MEASURE;
      l_target_level_rec.SYSTEM_FLAG                   := cr.SYSTEM_FLAG;
      l_Target_Level_rec.Dataset_ID	               := cr.DATASET_ID;

      x_Target_Level_Tbl(i) := l_Target_Level_rec;

    END LOOP;

    IF tar_level_fv%ISOPEN THEN CLOSE tar_level_fv; END IF;
    IF tar_level_bv%ISOPEN THEN CLOSE tar_level_bv; END IF;

  end if;

  --added this check and message
  if ( i= 0) then
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_MEASURE_ID'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target_Levels'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    end if;
--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      IF tar_level_fv%ISOPEN THEN CLOSE tar_level_fv; END IF;
      IF tar_level_bv%ISOPEN THEN CLOSE tar_level_bv; END IF;
      x_return_status := FND_API.G_RET_STS_ERROR ;
   --   RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      IF tar_level_fv%ISOPEN THEN CLOSE tar_level_fv; END IF;
      IF tar_level_bv%ISOPEN THEN CLOSE tar_level_bv; END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      IF tar_level_fv%ISOPEN THEN CLOSE tar_level_fv; END IF;
      IF tar_level_bv%ISOPEN THEN CLOSE tar_level_bv; END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target_Levels'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Target_Levels;
--
--
-- Gets Information for one Indicator Level
-- If information about the dimension are not required, set all_info to FALSE.
PROCEDURE Retrieve_Target_Level
( p_api_version         IN  NUMBER
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_all_info            IN  VARCHAR2   := FND_API.G_TRUE
, x_Target_Level_Rec IN OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_ID NUMBER;
l_indicator_id NUMBER;
l_Target_Level_rec BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_wf_process_short_name VARCHAR2(30);
l_wf_process_name VARCHAR2(80);
l_Def_Notify_Resp_short_name VARCHAR2(100);
l_Def_Notify_Resp_name VARCHAR2(240);
l_Def_Notify_Resp_ID NUMBER;
l_dimension_level_rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_Target_Level_rec := x_Target_Level_rec;

  if (p_all_info = FND_API.G_FALSE) then
    Select measure_id
  	 , TARGET_LEVEL_ID
  	 , TARGET_LEVEL_SHORT_NAME
  	 , TARGET_LEVEL_NAME
  	 , DESCRIPTION
  	 , ORG_LEVEL_ID
  	 , TIME_LEVEL_ID
  	 , DIMENSION1_LEVEL_ID
  	 , DIMENSION2_LEVEL_ID
  	 , DIMENSION3_LEVEL_ID
  	 , DIMENSION4_LEVEL_ID
  	 , DIMENSION5_LEVEL_ID
  	 , DIMENSION6_LEVEL_ID
  	 , DIMENSION7_LEVEL_ID
  	 , WORKFLOW_ITEM_TYPE
  	 , WORKFLOW_PROCESS_SHORT_NAME
  	 , DEFAULT_NOTIFY_RESP_ID
  	 , DEFAULT_NOTIFY_RESP_SHORT_NAME
  	 , COMPUTING_FUNCTION_ID
  	 , REPORT_FUNCTION_ID
  	 , UNIT_OF_MEASURE
  	 , SYSTEM_FLAG
    into   l_Target_Level_rec.measure_id
  	 , l_Target_Level_rec.Target_Level_id
  	 , l_Target_Level_rec.Target_Level_short_name
  	 , l_Target_Level_rec.Target_Level_name
  	 , l_Target_Level_rec.description
  	 , l_Target_Level_rec.org_level_id
  	 , l_Target_Level_rec.time_level_id
  	 , l_Target_Level_rec.dimension1_level_id
  	 , l_Target_Level_rec.dimension2_level_id
  	 , l_Target_Level_rec.dimension3_level_id
  	 , l_Target_Level_rec.dimension4_level_id
  	 , l_Target_Level_rec.dimension5_level_id
  	 , l_Target_Level_rec.dimension6_level_id
  	 , l_Target_Level_rec.dimension7_level_id
  	 , l_Target_Level_rec.Workflow_Item_Type
  	 , l_Target_Level_rec.Workflow_process_short_name
  	 , l_Target_Level_rec.Default_Notify_Resp_ID
  	 , l_Target_Level_rec.Default_Notify_Resp_short_name
  	 , l_Target_Level_rec.Computing_Function_Id
  	 , l_Target_Level_rec.Report_Function_ID
  	 , l_Target_Level_rec.Unit_Of_Measure
  	 , l_Target_Level_rec.system_flag
    from   bisbv_target_levels
    where target_level_ID = p_Target_Level_rec.Target_Level_ID;
  -- 2528450
  ELSIF (NOT p_Target_Level_Rec.is_wf_info_needed) THEN
    SELECT INDICATOR_ID
         , TARGET_LEVEL_ID
         , SHORT_NAME
         , DIMENSION1_LEVEL_ID
         , DIMENSION2_LEVEL_ID
         , DIMENSION3_LEVEL_ID
         , DIMENSION4_LEVEL_ID
         , DIMENSION5_LEVEL_ID
         , DIMENSION6_LEVEL_ID
         , DIMENSION7_LEVEL_ID
    into   l_target_level_rec.MEASURE_ID
         , l_target_level_rec.TARGET_LEVEL_ID
         , l_target_level_rec.TARGET_LEVEL_SHORT_NAME
         , l_target_level_rec.DIMENSION1_LEVEL_ID
         , l_target_level_rec.DIMENSION2_LEVEL_ID
         , l_target_level_rec.DIMENSION3_LEVEL_ID
         , l_target_level_rec.DIMENSION4_LEVEL_ID
         , l_target_level_rec.DIMENSION5_LEVEL_ID
         , l_target_level_rec.DIMENSION6_LEVEL_ID
         , l_target_level_rec.DIMENSION7_LEVEL_ID
    FROM   BIS_TARGET_LEVELS
    WHERE  TARGET_LEVEL_ID = p_Target_Level_rec.Target_Level_ID;
  -- end of 2528450
  else -- p_all_info = true and  p_Target_Level_Rec.is_wf_info_needed = true
    select TARGET_LEVEL_ID
         , TARGET_LEVEL_SHORT_NAME
         , TARGET_LEVEL_NAME
         , DESCRIPTION
         , MEASURE_ID
         , MEASURE_SHORT_NAME
         , MEASURE_NAME
         , ORG_LEVEL_ID
         , ORG_LEVEL_SHORT_NAME
         , ORG_LEVEL_NAME
         , TIME_LEVEL_ID
         , TIME_LEVEL_SHORT_NAME
         , TIME_LEVEL_NAME
         , DIMENSION1_LEVEL_ID
         , DIMENSION1_LEVEL_SHORT_NAME
         , DIMENSION1_LEVEL_NAME
         , DIMENSION2_LEVEL_ID
         , DIMENSION2_LEVEL_SHORT_NAME
         , DIMENSION2_LEVEL_NAME
         , DIMENSION3_LEVEL_ID
         , DIMENSION3_LEVEL_SHORT_NAME
         , DIMENSION3_LEVEL_NAME
         , DIMENSION4_LEVEL_ID
         , DIMENSION4_LEVEL_SHORT_NAME
         , DIMENSION4_LEVEL_NAME
         , DIMENSION5_LEVEL_ID
         , DIMENSION5_LEVEL_SHORT_NAME
         , DIMENSION5_LEVEL_NAME
         , DIMENSION6_LEVEL_ID
         , DIMENSION6_LEVEL_SHORT_NAME
         , DIMENSION6_LEVEL_NAME
         , DIMENSION7_LEVEL_ID
         , DIMENSION7_LEVEL_SHORT_NAME
         , DIMENSION7_LEVEL_NAME
         , WORKFLOW_ITEM_TYPE
         , WORKFLOW_PROCESS_SHORT_NAME
         , WORKFLOW_PROCESS_NAME
         , DEFAULT_NOTIFY_RESP_ID
         , DEFAULT_NOTIFY_RESP_SHORT_NAME
         , DEFAULT_NOTIFY_RESP_NAME
         , COMPUTING_FUNCTION_ID
         , COMPUTING_FUNCTION_NAME
         , COMPUTING_USER_FUNCTION_NAME
         , REPORT_FUNCTION_ID
         , REPORT_FUNCTION_NAME
         , REPORT_USER_FUNCTION_NAME
         , UNIT_OF_MEASURE
         , SYSTEM_FLAG
         , DATASET_ID
    into   l_target_level_rec.TARGET_LEVEL_ID
         , l_target_level_rec.TARGET_LEVEL_SHORT_NAME
         , l_target_level_rec.TARGET_LEVEL_NAME
         , l_target_level_rec.DESCRIPTION
         , l_target_level_rec.MEASURE_ID
         , l_target_level_rec.MEASURE_SHORT_NAME
         , l_target_level_rec.MEASURE_NAME
         , l_target_level_rec.ORG_LEVEL_ID
         , l_target_level_rec.ORG_LEVEL_SHORT_NAME
         , l_target_level_rec.ORG_LEVEL_NAME
         , l_target_level_rec.TIME_LEVEL_ID
         , l_target_level_rec.TIME_LEVEL_SHORT_NAME
         , l_target_level_rec.TIME_LEVEL_NAME
         , l_target_level_rec.DIMENSION1_LEVEL_ID
         , l_target_level_rec.DIMENSION1_LEVEL_SHORT_NAME
         , l_target_level_rec.DIMENSION1_LEVEL_NAME
         , l_target_level_rec.DIMENSION2_LEVEL_ID
         , l_target_level_rec.DIMENSION2_LEVEL_SHORT_NAME
         , l_target_level_rec.DIMENSION2_LEVEL_NAME
         , l_target_level_rec.DIMENSION3_LEVEL_ID
         , l_target_level_rec.DIMENSION3_LEVEL_SHORT_NAME
         , l_target_level_rec.DIMENSION3_LEVEL_NAME
         , l_target_level_rec.DIMENSION4_LEVEL_ID
         , l_target_level_rec.DIMENSION4_LEVEL_SHORT_NAME
         , l_target_level_rec.DIMENSION4_LEVEL_NAME
         , l_target_level_rec.DIMENSION5_LEVEL_ID
         , l_target_level_rec.DIMENSION5_LEVEL_SHORT_NAME
         , l_target_level_rec.DIMENSION5_LEVEL_NAME
         , l_target_level_rec.DIMENSION6_LEVEL_ID
         , l_target_level_rec.DIMENSION6_LEVEL_SHORT_NAME
         , l_target_level_rec.DIMENSION6_LEVEL_NAME
         , l_target_level_rec.DIMENSION7_LEVEL_ID
         , l_target_level_rec.DIMENSION7_LEVEL_SHORT_NAME
         , l_target_level_rec.DIMENSION7_LEVEL_NAME
         , l_target_level_rec.WORKFLOW_ITEM_TYPE
         , l_target_level_rec.WORKFLOW_PROCESS_SHORT_NAME
         , l_target_level_rec.WORKFLOW_PROCESS_NAME
         , l_target_level_rec.DEFAULT_NOTIFY_RESP_ID
         , l_target_level_rec.DEFAULT_NOTIFY_RESP_SHORT_NAME
         , l_target_level_rec.DEFAULT_NOTIFY_RESP_NAME
         , l_target_level_rec.COMPUTING_FUNCTION_ID
         , l_target_level_rec.COMPUTING_FUNCTION_NAME
         , l_target_level_rec.COMPUTING_USER_FUNCTION_NAME
         , l_target_level_rec.REPORT_FUNCTION_ID
         , l_target_level_rec.REPORT_FUNCTION_NAME
         , l_target_level_rec.REPORT_USER_FUNCTION_NAME
         , l_target_level_rec.UNIT_OF_MEASURE
         , l_target_level_rec.SYSTEM_FLAG
         , l_target_level_rec.DATASET_ID
    from   bisfv_target_levels
    where target_level_ID = p_Target_Level_rec.Target_Level_ID;
  end if;

  x_Target_Level_rec := l_Target_Level_rec;

--commented RAISE
EXCEPTION
   --added NO DATA FOUND
   WHEN NO_DATA_FOUND THEN
       --added this error message

       l_error_tbl := x_error_tbl;
       BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_TARGET_LEVEL_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target_Level'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
    --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_Target_Level;
--

--====================================================================
-- Retrieves target level records into table given
-- multiple target level short names.
-- This is used in KPI portlet as of now to retrieve
-- details of all required target level short names with one call.
-- As of now, the input table structure into this should start from 1 incremented by 1
PROCEDURE retrieve_mult_targ_levels(
  p_api_version IN NUMBER
 ,p_target_level_tbl IN BIS_TARGET_LEVEL_PUB.target_level_tbl_type
 ,p_all_info IN VARCHAR2 := FND_API.G_TRUE
 ,x_target_level_tbl OUT NOCOPY BIS_TARGET_LEVEL_PUB.target_level_tbl_type
 ,x_return_status OUT NOCOPY VARCHAR2
 ,x_error_Tbl OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  TYPE ref_cursor_type IS REF CURSOR;
  c_targ_level_details ref_cursor_type;

  l_target_level_rec BIS_TARGET_LEVEL_PUB.target_level_rec_type;
  l_bind_var_tbl bind_variables_tbl_type;
  l_index NUMBER;
  l_sql VARCHAR2(32000);
  l_is_bind BOOLEAN := FALSE;
  l_is_execute BOOLEAN := FALSE;
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_target_level_tbl.COUNT = 0) THEN
    RETURN;
  END IF;

  retrieve_sql(
     p_target_level_tbl => p_target_level_tbl
    ,x_is_bind => l_is_bind
    ,x_is_execute => l_is_execute
    ,x_sql => l_sql
    ,x_bind_variables_tbl => l_bind_var_tbl
  );

  IF ( (l_is_execute) AND (l_sql IS NOT NULL) ) THEN

    IF (c_targ_level_details%ISOPEN) THEN
      close c_targ_level_details;
    END IF;

    IF (l_is_bind) THEN
      OPEN c_targ_level_details FOR l_sql USING l_bind_var_tbl(1), l_bind_var_tbl(2), l_bind_var_tbl(3), l_bind_var_tbl(4),
        l_bind_var_tbl(5), l_bind_var_tbl(6), l_bind_var_tbl(7), l_bind_var_tbl(8), l_bind_var_tbl(9), l_bind_var_tbl(10);
    ELSE
      OPEN c_targ_level_details FOR l_sql;
    END IF;

    l_index := 1;
    LOOP

      FETCH c_targ_level_details INTO
        l_target_level_rec.MEASURE_ID
       ,l_target_level_rec.TARGET_LEVEL_ID
       ,l_target_level_rec.TARGET_LEVEL_SHORT_NAME
       ,l_target_level_rec.DIMENSION1_LEVEL_ID
       ,l_target_level_rec.DIMENSION2_LEVEL_ID
       ,l_target_level_rec.DIMENSION3_LEVEL_ID
       ,l_target_level_rec.DIMENSION4_LEVEL_ID
       ,l_target_level_rec.DIMENSION5_LEVEL_ID
       ,l_target_level_rec.DIMENSION6_LEVEL_ID
       ,l_target_level_rec.DIMENSION7_LEVEL_ID;

      EXIT WHEN c_targ_level_details%NOTFOUND;

      x_target_level_tbl(l_index) := l_target_level_rec;
      l_index := l_index + 1;
    END LOOP;
    CLOSE c_targ_level_details;

  END IF; -- end of execution

EXCEPTION
  WHEN OTHERS THEN
    IF (c_targ_level_details%ISOPEN) THEN
      CLOSE c_targ_level_details;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message(
        p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.retrieve_multiple_target_levels'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
END retrieve_mult_targ_levels;

--====================================================================

PROCEDURE retrieve_sql(
  p_target_level_tbl IN BIS_TARGET_LEVEL_PUB.Target_Level_Tbl_Type
 ,x_is_bind OUT NOCOPY BOOLEAN
 ,x_is_execute OUT NOCOPY BOOLEAN
 ,x_sql OUT NOCOPY VARCHAR2
 ,x_bind_variables_tbl OUT NOCOPY bind_variables_tbl_type
)
IS
  l_all_targ_short_nm VARCHAR2(32000);
BEGIN
  x_is_execute := FALSE;

  x_sql := 'SELECT INDICATOR_ID
         , TARGET_LEVEL_ID
         , SHORT_NAME
         , DIMENSION1_LEVEL_ID
         , DIMENSION2_LEVEL_ID
         , DIMENSION3_LEVEL_ID
         , DIMENSION4_LEVEL_ID
         , DIMENSION5_LEVEL_ID
         , DIMENSION6_LEVEL_ID
         , DIMENSION7_LEVEL_ID
        FROM   BIS_TARGET_LEVELS
	WHERE short_name IN (';

  IF (p_target_level_tbl.COUNT <= 10) THEN
    x_is_bind := TRUE;
    FOR i IN p_target_level_tbl.FIRST .. p_target_level_tbl.LAST LOOP
      IF (p_target_level_tbl(i).target_level_short_name IS NOT NULL) THEN
        x_is_execute := TRUE;
        x_bind_variables_tbl(i) := p_target_level_tbl(i).target_level_short_name;
      ELSE
        x_bind_variables_tbl(i) := NULL;
      END IF;
    END LOOP;

    FOR i IN p_target_level_tbl.LAST + 1 .. 10 LOOP
      x_bind_variables_tbl(i) := NULL;
    END LOOP;

    x_sql := x_sql || ':1, :2, :3, :4, :5, :6, :7, :8, :9, :10)';

  ELSE -- If more than 10, then use literals.

    FOR i IN p_target_level_tbl.FIRST .. p_target_level_tbl.LAST LOOP
      IF (p_target_level_tbl(i).target_level_short_name IS NOT NULL) THEN
	x_is_execute := TRUE;
        IF (l_all_targ_short_nm IS NOT NULL) THEN
          l_all_targ_short_nm := l_all_targ_short_nm || ', ''' || p_target_level_tbl(i).target_level_short_name || '''';
	ELSE
	  l_all_targ_short_nm := '''' || p_target_level_tbl(i).target_level_short_name || '''';
	END IF;
      END IF;
    END LOOP;

    x_sql := x_sql || l_all_targ_short_nm || ')';

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_is_execute := FALSE;
    RETURN;
END retrieve_sql;

--=================================================================

Procedure Check_Changed
( p_Target_Level_Rec  IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_Target_Level_Rec1 IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_up_loaded         IN  VARCHAR2 := FND_API.G_TRUE
, x_changed           OUT NOCOPY VARCHAR2
)
IS
a BIS_Target_Level_PUB.Target_Level_Rec_Type;
b BIS_Target_Level_PUB.Target_Level_Rec_Type;

BEGIN

  a := p_target_level_rec1;
  b := p_target_level_rec;

  Set_NULL(  p_Target_Level_Rec   => p_target_level_rec1
           , x_Target_Level_Rec   => a);
  Set_NULL(  p_Target_Level_Rec   => p_target_level_rec
           , x_Target_Level_Rec   => b);

/*
htp.p( 'a.Measure_ID               ='||a.Measure_ID               ||', b = '||b.Measure_ID               );
htp.p( 'a.Target_Level_ID          ='||a.Target_Level_ID          ||', b = '||b.Target_Level_ID          );
htp.p( 'a.Target_Level_Short_Name  ='||a.Target_Level_Short_Name  ||', b = '||b.Target_Level_Short_Name  );
htp.p( 'a.Target_Level_Name        ='||a.Target_Level_Name        ||', b = '||b.Target_Level_Name        );
htp.p( 'a.Description              ='||a.Description              ||', b = '||b.Description              );
htp.p( 'a.Dimension1_Level_ID      ='||a.Dimension1_Level_ID      ||', b = '||b.Dimension1_Level_ID);
htp.p( 'a.Dimension2_Level_ID      ='||a.Dimension2_Level_ID      ||', b = '||b.Dimension2_Level_ID      );
htp.p( 'a.Dimension3_Level_ID      ='||a.Dimension3_Level_ID      ||', b = '||b.Dimension3_Level_ID      );
htp.p( 'a.Dimension4_Level_ID      ='||a.Dimension4_Level_ID      ||', b = '||b.Dimension4_Level_ID      );
htp.p( 'a.Dimension5_Level_ID      ='||a.Dimension5_Level_ID      ||', b = '||b.Dimension5_Level_ID      );
htp.p( 'a.Unit_of_Measure          ='||a.Unit_of_Measure          ||', b = '||b.Unit_of_Measure          );
htp.p( 'a.WF_Process_Short_Name    ='||a.workflow_Process_Short_Name||', b = '||b.workflow_Process_Short_Name);
htp.p( 'a.workflow_item_type       ='||a.workflow_item_type       ||', b = '||b.workflow_item_type);
htp.p( 'a.Def_Notify_Res.ID        ='||a.Default_Notify_Resp_ID   ||', b = '||b.Default_Notify_Resp_ID       );
htp.p( 'a.Default_Cmp_Target_ID    ='||a.Computing_function_ID    ||', b = '||b.computing_function_ID    );
htp.p( 'a.System_Flag              ='||a.System_Flag              ||', b = '||b.System_Flag              );
*/

  IF     a.Measure_ID                       = b.Measure_ID
    AND  a.Target_Level_ID                  = b.Target_Level_ID
    AND  a.Target_Level_Short_Name          = b.Target_Level_Short_Name
    AND  a.Target_Level_Name                = b.Target_Level_Name
    AND  NVL(a.org_Level_Id,-999)           = NVL(b.org_Level_Id,-999)
    AND  NVL(a.time_Level_Id,-999)          = NVL(b.time_Level_Id,-999)
    AND  NVL(a.dimension1_Level_Id,-999)    = NVL(b.dimension1_Level_Id,-999)
    AND  NVL(a.dimension2_Level_Id,-999)    = NVL(b.dimension2_Level_Id,-999)
    AND  NVL(a.dimension3_Level_Id,-999)    = NVL(b.dimension3_Level_Id,-999)
    AND NVL(a.dimension4_Level_Id,-999)     = NVL(b.dimension4_Level_Id,-999)
    AND NVL(a.dimension5_Level_Id,-999)     = NVL(b.dimension5_Level_Id,-999)
    AND NVL(a.dimension6_Level_Id,-999)     = NVL(b.dimension6_Level_Id,-999)
    AND NVL(a.dimension7_Level_Id,-999)     = NVL(b.dimension7_Level_Id,-999)
    AND NVL(a.Unit_Of_Measure, 'NULL')     = NVL(b.Unit_Of_Measure,'NULL')
  THEN

  IF p_up_loaded = FND_API.G_TRUE THEN
    x_changed := FND_API.G_FALSE;

  ELSE

    IF  NVL(a.Workflow_Process_Short_Name,'NULL')
      = NVL(b.Workflow_Process_Short_Name,'NULL')
      AND NVL(a.Workflow_Item_Type,'NULL') = NVL(b.Workflow_Item_Type,'NULL')
--      AND NVL(a.Default_Notify_Resp_ID,-999)
--        = NVL(b.Default_Notify_Resp_ID,-999)
      AND NVL(a.Computing_Function_ID,-999)
        = NVL(b.Computing_Function_ID,-999)
      AND  NVL(a.Description,'NULL') = NVL(b.Description,'NULL')
    THEN
      x_changed := FND_API.G_FALSE;
    ELSE
      x_changed := FND_API.G_TRUE;
    END IF;
  END IF;

  ELSE
    x_changed := FND_API.G_TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END Check_Changed;
--
PROCEDURE Update_Target_Level_Rec
( p_Target_Level_Rec  IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_Target_Level_Rec1 IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_up_loaded         IN  VARCHAR2 := FND_API.G_TRUE
, x_Target_Level_Rec  OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_changed           OUT NOCOPY VARCHAR2
)
IS
a BIS_Target_Level_PUB.Target_Level_Rec_Type;
b BIS_Target_Level_PUB.Target_Level_Rec_Type;

BEGIN

  a := p_target_level_rec1;
  b := p_target_level_rec;

  Set_NULL(  p_Target_Level_Rec   => p_target_level_rec1
           , x_Target_Level_Rec   => a);
  Set_NULL(  p_Target_Level_Rec   => p_target_level_rec
           , x_Target_Level_Rec   => b);
  x_Target_Level_Rec := a;

  -- First check if the input record has changed from the original
  --
  Check_Changed
  ( p_Target_Level_Rec  => b
  , p_Target_Level_Rec1 => a
  , p_up_loaded         => p_up_loaded
  , x_changed           => x_changed
  );

  -- If input record changed, then update record
  --
    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Target_Level_Short_Name) = FND_API.G_FALSE) THEN
      x_target_level_rec.Target_Level_Short_Name :=
                                    p_target_level_rec.Target_Level_Short_Name;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Target_Level_Name) = FND_API.G_FALSE) THEN
      x_target_level_rec.Target_Level_Name :=
                                          p_target_level_rec.Target_Level_Name;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Description) = FND_API.G_FALSE) THEN
      x_target_level_rec.Description := p_target_level_rec.Description;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.org_Level_ID) = FND_API.G_FALSE) THEN
      x_target_level_rec.org_Level_ID :=
                                        p_target_level_rec.org_Level_ID;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.time_Level_ID) = FND_API.G_FALSE) THEN
      x_target_level_rec.time_Level_ID :=
                                        p_target_level_rec.time_Level_ID;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Dimension1_Level_ID) = FND_API.G_FALSE) THEN
      x_target_level_rec.Dimension1_Level_ID :=
                                        p_target_level_rec.Dimension1_Level_ID;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Dimension2_Level_ID) = FND_API.G_FALSE) THEN
      x_target_level_rec.Dimension2_Level_ID :=
                                        p_target_level_rec.Dimension2_Level_ID;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Dimension3_Level_ID) = FND_API.G_FALSE) THEN
      x_target_level_rec.Dimension3_Level_ID :=
                                        p_target_level_rec.Dimension3_Level_ID;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Dimension4_Level_ID) = FND_API.G_FALSE) THEN
      x_target_level_rec.Dimension4_Level_ID :=
                                        p_target_level_rec.Dimension4_Level_ID;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Dimension5_Level_ID) = FND_API.G_FALSE) THEN
      x_target_level_rec.Dimension5_Level_ID :=
                                        p_target_level_rec.Dimension5_Level_ID;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Dimension6_Level_ID) = FND_API.G_FALSE) THEN
      x_target_level_rec.Dimension6_Level_ID :=
                                        p_target_level_rec.Dimension6_Level_ID;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Dimension7_Level_ID) = FND_API.G_FALSE) THEN
      x_target_level_rec.Dimension7_Level_ID :=
                                        p_target_level_rec.Dimension7_Level_ID;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
       (p_Target_Level_Rec.Workflow_Process_Short_Name) = FND_API.G_FALSE) THEN
	    -- bug# 3735203
	    IF(p_Target_Level_Rec.Workflow_Process_Short_Name <> '-1') THEN
           x_target_level_rec.Workflow_Process_Short_Name :=
                                p_target_level_rec.Workflow_Process_Short_Name;
		ELSE
		   x_target_level_rec.Workflow_Process_Short_Name := NULL;
		END IF;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Default_Notify_Resp_ID) = FND_API.G_FALSE) THEN
      x_target_level_rec.Default_Notify_Resp_ID :=
                                     p_target_level_rec.Default_Notify_Resp_ID;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
      (p_Target_Level_Rec.Default_Notify_Resp_short_name)=FND_API.G_FALSE) THEN
      x_target_level_rec.Default_Notify_Resp_short_name :=
                             p_target_level_rec.Default_Notify_Resp_short_name;
    END IF;


    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Computing_function_ID) = FND_API.G_FALSE) THEN
	    -- bug# 3735203
		IF (p_Target_Level_Rec.Computing_function_ID <> -1) THEN
            x_target_level_rec.Computing_function_ID :=
                                 p_target_level_rec.Computing_function_ID;
	    ELSE
       		x_target_level_rec.Computing_function_ID := NULL;
		END IF;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Workflow_Item_Type) = FND_API.G_FALSE) THEN
	    -- bug# 3735203
	     IF( p_Target_Level_Rec.Workflow_Item_Type <> '-1') THEN
             x_target_level_rec.Workflow_Item_Type :=
                                   p_target_level_rec.Workflow_Item_Type;
		 ELSE
		     x_target_level_rec.Workflow_Item_Type := NULL;
		 END IF;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Report_Function_ID) = FND_API.G_FALSE) THEN
      x_target_level_rec.Report_Function_ID :=
                                   p_target_level_rec.Report_Function_ID;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Unit_Of_Measure) = FND_API.G_FALSE) THEN
      x_target_level_rec.Unit_Of_Measure :=
                                   p_target_level_rec.Unit_Of_Measure;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.System_Flag) = FND_API.G_FALSE) THEN
      x_target_level_rec.System_Flag :=
                                   p_target_level_rec.System_Flag;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

    IF (BIS_UTILITIES_PUB.Value_Missing
        (p_Target_Level_Rec.Source) = FND_API.G_FALSE) THEN
      x_target_level_rec.Source :=
                                   p_target_level_rec.Source;
      -- x_changed :=  FND_API.G_TRUE;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
  htp.p('Exception in Update_Target_Level_Rec: '||SQLERRM);
END Update_Target_Level_Rec;
--
-- Update_Target_Levels
PROCEDURE Update_Target_Level
( p_api_version         IN  NUMBER
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Update_Target_Level
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Target_Level_Rec  => p_Target_Level_Rec
  , p_owner             => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , p_up_loaded         => FND_API.G_FALSE
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

--commented RAISE
EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --added last two params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Update_Target_Level'
    , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Target_Level;
--
-- Update_Target_Levels
PROCEDURE Update_Target_Level
( p_api_version      IN  NUMBER
, p_commit           IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_owner            IN  VARCHAR2
, p_up_loaded        IN  VARCHAR2 := FND_API.G_FALSE
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id          NUMBER;
l_login_id         NUMBER;
l_Target_Level_Rec BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_Target_Level_orig BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_changed          VARCHAR2(10) := FND_API.G_FALSE;
l_target_level_id  NUMBER;
l_Target_Tbl       BIS_TARGET_PUB.Target_Tbl_Type;
l_error_tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;

--added  this
DUPLICATE_DIMENSION_VALUE EXCEPTION;
PRAGMA EXCEPTION_INIT(DUPLICATE_DIMENSION_VALUE, -1);

BEGIN

  Validate_Target_Level
  ( p_api_version      	  => p_api_version
  , p_validation_level 	  => p_validation_level
  , p_Target_Level_Rec    => p_Target_Level_Rec
  , x_return_status    	  => x_return_status
  , x_error_Tbl        	  => x_error_Tbl
  );

  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  BIS_TARGET_LEVEL_PVT.Retrieve_Target_Level
  ( p_api_version         => 1.0
  , p_Target_Level_Rec    => p_Target_Level_Rec
  , p_all_info            => FND_API.G_FALSE
  , x_Target_Level_Rec    => l_target_level_orig
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_tbl
  );

  --added this check
  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
  l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_INVALID_TAR_LEVEL_ID'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Update_Target_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
    , x_error_table       => x_error_tbl
    );
    RAISE FND_API.G_EXC_ERROR;
  END IF;



  Update_Target_Level_Rec
  ( p_target_level_rec  => p_target_level_rec
  , p_target_level_rec1 => l_target_level_orig
  , p_up_loaded         => p_up_loaded
  , x_target_level_rec  => l_target_level_rec
  , x_changed           => l_changed
  );

  IF (   l_changed = FND_API.G_TRUE
     AND l_target_level_orig.System_Flag = 'Y')
  THEN

    -- ADD error message
    --added last two params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_NO_CHANGE_SEED_TARGET_LVL'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Update_Target_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );

    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_target_level_Id := Get_Level_Id_From_Short_Name(p_target_level_rec);

  if (l_target_level_id is NOT NULL) then
    if (l_target_level_id <> p_target_level_Rec.Target_Level_Id) then

       --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_TRG_LVL_SHORT_NAME_UNIQUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Update_Target_Level'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;

  BIS_TARGET_PVT.Retrieve_Targets( p_api_version
                                 , p_Target_Level_Rec
                                 , FND_API.G_FALSE
                                 , l_Target_Tbl
                                 , x_return_status
                                 , x_error_Tbl
                                 );

  l_target_level_Id := Get_Level_Id_From_dimlevels(p_target_level_rec);

  if (l_target_level_id is NOT NULL) then
    if (l_target_level_id <> p_target_level_Rec.Target_Level_Id) then
        --added last two params
	l_error_tbl := x_error_tbl;
  	BIS_UTILITIES_PVT.Add_Error_Message
  	( p_error_msg_name    => 'BIS_TRG_LVL_DIMLEVELS_UNIQUE'
  	, p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
  	, p_error_proc_name   => G_PKG_NAME||'.Update_Target_Level'
  	, p_error_type        => BIS_UTILITIES_PUB.G_ERROR
  	, p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
  	);
  	RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;

  IF p_owner = BIS_UTILITIES_PUB.G_SEED_OWNER THEN
    l_user_id := BIS_UTILITIES_PUB.G_SEED_USER_ID;
  ELSE
    l_user_id := fnd_global.user_id;
  END IF;
  l_login_id := fnd_global.LOGIN_ID;
  --
  /*
  ----------------
  --Adding this for the source column
  IF (BIS_UTILITIES_PUB.Value_Missing(l_Target_Level_Rec.source)
        = FND_API.G_TRUE)
  OR (BIS_UTILITIES_PUB.Value_NULL(l_Target_Level_Rec.source)
        = FND_API.G_TRUE)
  THEN
    l_Target_Level_Rec.source := FND_PROFILE.value('BIS_SOURCE');
  END IF;
  ------------------
  */


  UPDATE BIS_TARGET_LEVELS
  set
    INDICATOR_ID        = l_Target_Level_Rec.Measure_ID
  , SHORT_NAME          = l_Target_Level_Rec.Target_Level_Short_Name
  , ORG_LEVEL_ID	= l_Target_Level_Rec.org_Level_ID
  , TIME_LEVEL_ID	= l_Target_Level_Rec.time_Level_ID
  , DIMENSION1_LEVEL_ID	= l_Target_Level_Rec.Dimension1_Level_ID
  , DIMENSION2_LEVEL_ID	= l_Target_Level_Rec.Dimension2_Level_ID
  , DIMENSION3_LEVEL_ID = l_Target_Level_Rec.Dimension3_Level_ID
  , DIMENSION4_LEVEL_ID	= l_Target_Level_Rec.Dimension4_Level_ID
  , DIMENSION5_LEVEL_ID	= l_Target_Level_Rec.Dimension5_Level_ID
  , DIMENSION6_LEVEL_ID	= l_Target_Level_Rec.Dimension6_Level_ID
  , DIMENSION7_LEVEL_ID	= l_Target_Level_Rec.Dimension7_Level_ID
  , WF_PROCESS          = l_Target_Level_Rec.Workflow_Process_Short_Name
  , WF_ITEM_TYPE        = l_Target_Level_Rec.Workflow_Item_Type
  , REPORT_FUNCTION_ID  = l_Target_Level_Rec.Report_Function_ID
--  , UNIT_OF_MEASURE     = l_Target_Level_Rec.Unit_Of_Measure
  , DEFAULT_ROLE_ID	= l_Target_Level_Rec.Default_Notify_Resp_ID
  , DEFAULT_ROLE	= l_Target_Level_Rec.Default_Notify_Resp_short_name
  , SYSTEM_FLAG         = l_Target_Level_Rec.System_Flag
  , DEFAULT_COMPUTING_FUNCTION_ID = l_target_level_rec.Computing_function_ID
-- , CREATION_DATE	= SYSDATE
  , CREATED_BY		= l_user_id
  , LAST_UPDATE_DATE    = SYSDATE
  , LAST_UPDATED_BY	= l_user_id
  , LAST_UPDATE_LOGIN	= l_login_id
  , SOURCE             	= l_Target_Level_Rec.Source
  where TARGET_LEVEL_ID = l_Target_Level_Rec.Target_Level_Id;

  Translate_Target_Level
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Target_Level_Rec  => l_Target_Level_Rec
  , p_owner             => p_owner
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

--commented RAISE
EXCEPTION
   --added this
   WHEN DUPLICATE_DIMENSION_VALUE THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
     ( p_error_msg_name    => 'BIS_TAR_LEVEL_UNIQUENESS_ERROR'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Update_Target_Level'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
      --RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Update_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Update_Target_Level;
--
--
Procedure Translate_Target_Level
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec  IN  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl		BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  Translate_Target_Level
  ( p_api_version       => p_api_version
  , p_commit            => p_commit
  , p_validation_level  => p_validation_level
  , p_Target_Level_Rec  => p_Target_Level_Rec
  , p_owner             => BIS_UTILITIES_PUB.G_CUSTOM_OWNER
  , x_return_status     => x_return_status
  , x_error_Tbl         => x_error_Tbl
  );

--commented RAISE
EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --added last two params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Translate_Target_Level'
    , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Translate_Target_Level;
--
Procedure Translate_Target_Level
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2   := FND_API.G_FALSE
, p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec  IN  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, p_owner             IN  VARCHAR2
, x_return_status     OUT NOCOPY VARCHAR2
, x_error_Tbl         OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_user_id           NUMBER;
l_login_id          NUMBER;
l_count             NUMBER := 0;
l_changed           VARCHAR2(10) := FND_API.G_FALSE;
l_Target_Level_rec  BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_Target_Level_orig BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
l_error_tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_Target_Level_rec  := p_Target_Level_Rec;

  BIS_TARGET_LEVEL_PVT.Retrieve_Target_Level
  ( p_api_version         => 1.0
  , p_Target_Level_Rec    => l_Target_Level_Rec
  , p_all_info            => FND_API.G_FALSE
  , x_Target_Level_Rec    => l_target_level_orig
  , x_return_status       => x_return_status
  , x_error_Tbl           => x_error_tbl
  );

  Validate_Target_Level
  ( p_api_version      	  => p_api_version
  , p_validation_level 	  => p_validation_level
  , p_Target_Level_Rec    => l_Target_Level_orig
  , x_return_status    	  => x_return_status
  , x_error_Tbl        	  => x_error_Tbl
  );
  --
  IF( x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --

/*
  if (l_target_level_Orig.target_level_id is NOT NULL) then
    if (l_target_level_Orig.target_level_id <>
        l_Target_Level_Rec.Target_Level_Id) then
        --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_TARGET_LEVEL_SHORT_NAME_UNIQUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Target_Level'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      RAISE FND_API.G_EXC_ERROR;
    end if;
  end if;

  Update_Target_Level_Rec
  ( p_target_level_rec  => p_target_level_rec
  , p_target_level_rec1 => l_target_level_orig
  , x_target_level_rec  => l_target_level_rec
  , x_changed           => l_changed
  );
*/

  l_target_level_rec.target_level_id := l_target_level_Orig.target_level_id;
  --
  IF p_owner = BIS_UTILITIES_PUB.G_SEED_OWNER THEN
    l_user_id := BIS_UTILITIES_PUB.G_SEED_USER_ID;
  ELSE
    l_user_id := fnd_global.user_id;
  END IF;

  l_login_id := fnd_global.LOGIN_ID;
  --

  Update BIS_TARGET_LEVELS_TL
  set
    NAME              = l_Target_Level_Rec.Target_Level_Name
  , DESCRIPTION       = l_Target_Level_Rec.description
  , UNIT_OF_MEASURE   = l_Target_Level_Rec.Unit_Of_Measure
  , LAST_UPDATE_DATE  = SYSDATE
  , LAST_UPDATED_BY   = l_user_id
  , LAST_UPDATE_LOGIN = l_login_id
  , SOURCE_LANG       = userenv('LANG')
  where TARGET_LEVEL_ID  = l_Target_Level_Rec.Target_Level_Id
  and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Translate_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
    --  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Translate_Target_Level;
--
-- deletes one Target_Level
PROCEDURE Delete_Target_Level
( p_api_version         IN  NUMBER
, p_force_delete        IN  NUMBER := 0--gbhaloti #3148615
, p_commit              IN  VARCHAR2   := FND_API.G_FALSE
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_Target_Tbl           BIS_TARGET_PUB.Target_Tbl_Type;
l_error_tbl            BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BIS_TARGET_PVT.Retrieve_Targets( p_api_version
                                 , p_Target_Level_Rec
                                 , FND_API.G_FALSE
                                 , l_Target_Tbl
                                 , x_return_status
                                 , x_error_Tbl
                                 );

   /*
  --added this check and message and RAISE
  if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      RAISE FND_API.G_EXC_ERROR;
  end if;
  */
  if (l_Target_Tbl.COUNT > 0 AND p_force_delete = 0) then
    --added last two params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_name    => 'BIS_NO_DELETE_TARGET_LEVEL'
    , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
    , p_error_proc_name   => G_PKG_NAME||'.Delete_Target_Level'
    , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
    , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );


    RAISE FND_API.G_EXC_ERROR;
  end if;

  delete from bis_TARGET_LEVELS
  where TARGET_LEVEL_ID = p_Target_Level_Rec.Target_Level_Id;

  delete from bis_TARGET_LEVELS_TL
  where TARGET_LEVEL_ID = p_Target_Level_Rec.Target_Level_Id;

  BIS_MEASURE_SECURITY_PVT.Delete_Measure_Security( p_api_version
                                                  , p_commit
                                                  , p_Target_Level_Rec
                                                  , x_return_status
                                                  , x_error_Tbl
                                                  );

  delete from bis_indicator_resps
  where target_level_id = p_Target_Level_Rec.Target_Level_Id;

  if (p_commit = FND_API.G_TRUE) then
    COMMIT;
  end if;

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Delete_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Delete_Target_Level;
--
-- Validates measure
--PROCEDURE @Target_Level
PROCEDURE Validate_Target_Level
( p_api_version         IN  NUMBER
, p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_Tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_error     VARCHAR2(10) := FND_API.G_FALSE;
l_error_Tbl_p BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    BIS_TARGET_LEVEL_VALIDATE_PVT.Validate_org_Level_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_Target_Level_Rec   	 => p_Target_Level_Rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => l_error_Tbl
    );
    --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
  END;

  BEGIN
    BIS_TARGET_LEVEL_VALIDATE_PVT.Validate_time_Level_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_Target_Level_Rec   	 => p_Target_Level_Rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => l_error_Tbl
    );
    --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
  END;

  BEGIN
    BIS_TARGET_LEVEL_VALIDATE_PVT.Validate_Dimension1_Level_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_Target_Level_Rec   	 => p_Target_Level_Rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => l_error_Tbl
    );
    --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
  END;

  BEGIN
    BIS_TARGET_LEVEL_VALIDATE_PVT.Validate_Dimension2_Level_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_Target_Level_Rec   	 => p_Target_Level_Rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => l_error_Tbl
    );
  --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  BEGIN
    BIS_TARGET_LEVEL_VALIDATE_PVT.Validate_Dimension3_Level_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_Target_Level_Rec   	 => p_Target_Level_Rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => l_error_Tbl
    );
  --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  BEGIN
    BIS_TARGET_LEVEL_VALIDATE_PVT.Validate_Dimension4_Level_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_Target_Level_Rec   	 => p_Target_Level_Rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => l_error_Tbl
    );
 -- EXCEPTION
    --when FND_API.G_EXC_ERROR then
   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  BEGIN
    BIS_TARGET_LEVEL_VALIDATE_PVT.Validate_Dimension5_Level_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_Target_Level_Rec   	 => p_Target_Level_Rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => l_error_Tbl
    );
  --EXCEPTION
    --when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  BEGIN
    BIS_TARGET_LEVEL_VALIDATE_PVT.Validate_Dimension6_Level_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_Target_Level_Rec   	 => p_Target_Level_Rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => l_error_Tbl
    );
 -- EXCEPTION
   -- when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  BEGIN
    BIS_TARGET_LEVEL_VALIDATE_PVT.Validate_Dimension7_Level_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_Target_Level_Rec   	 => p_Target_Level_Rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => l_error_Tbl
    );
 -- EXCEPTION
   -- when FND_API.G_EXC_ERROR then
    IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  BEGIN
  -- bug# 3735203
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Level_Rec.Workflow_Process_Short_Name)  =FND_API.G_TRUE  ) THEN
    IF(p_Target_Level_Rec.Workflow_Process_Short_Name <> '-1') THEN
      BIS_TARGET_LEVEL_VALIDATE_PVT.Validate_WF_Process_Short_Name
      ( p_api_version      => p_api_version
      , p_validation_level => p_validation_level
      , p_Target_Level_Rec   	 => p_Target_Level_Rec
      , x_return_status 	 => x_return_status
      , x_error_Tbl     	 => l_error_Tbl
      );
	END IF;
  END IF;

--  EXCEPTION
  --  when FND_API.G_EXC_ERROR then
   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  BEGIN
    BIS_TARGET_LEVEL_VALIDATE_PVT.Validate_Def_Notify_Resp_Id
    ( p_api_version      => p_api_version
    , p_validation_level => p_validation_level
    , p_Target_Level_Rec   	 => p_Target_Level_Rec
    , x_return_status 	 => x_return_status
    , x_error_Tbl     	 => l_error_Tbl
    );

--  EXCEPTION
  --  when FND_API.G_EXC_ERROR then
   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  BEGIN
  -- bug# 3735203
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Level_Rec.Computing_function_ID)  =FND_API.G_TRUE  ) THEN
    IF(p_Target_Level_Rec.Computing_function_ID <> -1) THEN
      BIS_TARGET_LEVEL_VALIDATE_PVT.Validate_Df_computed_target_Id
      ( p_api_version      => p_api_version
      , p_validation_level => p_validation_level
      , p_Target_Level_Rec => p_Target_Level_Rec
      , x_return_status 	 => x_return_status
      , x_error_Tbl     	 => l_error_Tbl
      );
	END IF;
  END IF;

--  EXCEPTION
  --  when FND_API.G_EXC_ERROR then
   IF(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
      l_error := FND_API.G_TRUE;
      l_error_Tbl_p := x_error_Tbl;
      BIS_UTILITIES_PVT.concatenateErrorTables( l_error_Tbl_p
                                              , l_error_Tbl
                                              , x_error_tbl
                                              );
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END;

  if (l_error = FND_API.G_TRUE) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

--added this
-- x_error_tbl := l_error_tbl;
--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
    --  RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Validate_Target_Level'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
   --   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Validate_Target_Level;
--
PROCEDURE Check_Value_id_Conversion
( p_dim_level_id         in NUMBER
, p_Dim_level_short_name in VARCHAR2
, p_Dime_Level_NAME      in VARCHAR2
, x_dim_level_id         OUT NOCOPY NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_convert VARCHAR2(10);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID( p_dim_level_id
                                              , p_Dim_level_short_name
                                              , p_Dime_Level_NAME
                                              );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_DIMENSION_LEVEL_PVT.Value_ID_Conversion
      ( 1.0
      , p_Dim_level_short_name
      , p_Dime_Level_NAME
      , x_dim_level_id
      , x_return_status
      , x_error_Tbl
      );
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        NULL;
    END;
  else
    x_dim_level_id := p_dim_level_id;
  end if;

END Check_Value_id_Conversion;

-- Value - ID conversion
PROCEDURE Value_ID_Conversion
( p_api_version         IN  NUMBER
, p_Target_Level_Rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Target_Level_Rec OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_convert VARCHAR2(10);
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
l_Target_Level_Rec BIS_Target_Level_PUB.Target_Level_Rec_Type;
BEGIN
  x_return_status  := FND_API.G_RET_STS_SUCCESS;
  x_Target_Level_Rec := p_Target_Level_Rec;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                                ( x_Target_Level_Rec.Target_Level_id
                                , x_Target_Level_Rec.Target_Level_Short_Name
                                , x_Target_Level_Rec.Target_Level_Name
                                );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_Target_Level_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Target_Level_Rec.Target_Level_Short_Name
      , x_Target_Level_Rec.Target_Level_Name
      , x_Target_Level_Rec.Target_Level_ID
      , x_return_status
      , x_error_Tbl
      );
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        NULL;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                                ( x_Target_Level_Rec.Measure_id
                                , x_Target_Level_Rec.Measure_Short_Name
                                , x_Target_Level_Rec.Measure_Name
                                );
  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_MEASURE_PVT.Value_ID_Conversion
      ( p_api_version
      , x_Target_Level_Rec.Measure_Short_Name
      , x_Target_Level_Rec.Measure_Name
      , x_Target_Level_Rec.Measure_ID
      , x_return_status
      , x_error_Tbl
      );
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        NULL;
    END;
  end if;

  l_Target_Level_Rec.org_Level_id := x_Target_Level_Rec.org_Level_id;
  Check_Value_id_Conversion
  ( p_dim_level_id         => l_Target_Level_Rec.org_Level_id
  , p_Dim_level_short_name => x_Target_Level_Rec.org_Level_Short_Name
  , p_Dime_Level_NAME      => x_Target_Level_Rec.org_Level_Name
  , x_dim_level_id         => x_Target_Level_Rec.org_Level_ID
  , x_return_status        => x_return_status
  , x_error_Tbl            => x_error_Tbl
  );

  l_Target_Level_Rec.time_Level_id := x_Target_Level_Rec.time_Level_id;
  Check_Value_id_Conversion
  ( p_dim_level_id         => l_Target_Level_Rec.time_Level_id
  , p_Dim_level_short_name => x_Target_Level_Rec.time_Level_Short_Name
  , p_Dime_Level_NAME      => x_Target_Level_Rec.time_Level_Name
  , x_dim_level_id         => x_Target_Level_Rec.time_Level_ID
  , x_return_status        => x_return_status
  , x_error_Tbl            => x_error_Tbl
  );

  l_Target_Level_Rec.Dimension1_Level_id := x_Target_Level_Rec.Dimension1_Level_id;
  Check_Value_id_Conversion
  ( p_dim_level_id         => l_Target_Level_Rec.Dimension1_Level_id
  , p_Dim_level_short_name => x_Target_Level_Rec.Dimension1_Level_Short_Name
  , p_Dime_Level_NAME      => x_Target_Level_Rec.Dimension1_Level_Name
  , x_dim_level_id         => x_Target_Level_Rec.Dimension1_Level_ID
  , x_return_status        => x_return_status
  , x_error_Tbl            => x_error_Tbl
  );

  l_Target_Level_Rec.Dimension2_Level_id := x_Target_Level_Rec.Dimension2_Level_id;
  Check_Value_id_Conversion
  ( p_dim_level_id         => l_Target_Level_Rec.Dimension2_Level_id
  , p_Dim_level_short_name => x_Target_Level_Rec.Dimension2_Level_Short_Name
  , p_Dime_Level_NAME      => x_Target_Level_Rec.Dimension2_Level_Name
  , x_dim_level_id         => x_Target_Level_Rec.Dimension2_Level_ID
  , x_return_status        => x_return_status
  , x_error_Tbl            => x_error_Tbl
  );

  l_Target_Level_Rec.Dimension3_Level_id := x_Target_Level_Rec.Dimension3_Level_id;
  Check_Value_id_Conversion
  ( p_dim_level_id         => l_Target_Level_Rec.Dimension3_Level_id
  , p_Dim_level_short_name => x_Target_Level_Rec.Dimension3_Level_Short_Name
  , p_Dime_Level_NAME      => x_Target_Level_Rec.Dimension3_Level_Name
  , x_dim_level_id         => x_Target_Level_Rec.Dimension3_Level_ID
  , x_return_status        => x_return_status
  , x_error_Tbl            => x_error_Tbl
  );

  l_Target_Level_Rec.Dimension4_Level_id := x_Target_Level_Rec.Dimension4_Level_id;
  Check_Value_id_Conversion
  ( p_dim_level_id         => l_Target_Level_Rec.Dimension4_Level_id
  , p_Dim_level_short_name => x_Target_Level_Rec.Dimension4_Level_Short_Name
  , p_Dime_Level_NAME      => x_Target_Level_Rec.Dimension4_Level_Name
  , x_dim_level_id         => x_Target_Level_Rec.Dimension4_Level_ID
  , x_return_status        => x_return_status
  , x_error_Tbl            => x_error_Tbl
  );

  l_Target_Level_Rec.Dimension5_Level_id := x_Target_Level_Rec.Dimension5_Level_id;
  Check_Value_id_Conversion
  ( p_dim_level_id         => l_Target_Level_Rec.Dimension5_Level_id
  , p_Dim_level_short_name => x_Target_Level_Rec.Dimension5_Level_Short_Name
  , p_Dime_Level_NAME      => x_Target_Level_Rec.Dimension5_Level_Name
  , x_dim_level_id         => x_Target_Level_Rec.Dimension5_Level_ID
  , x_return_status        => x_return_status
  , x_error_Tbl            => x_error_Tbl
  );

  l_Target_Level_Rec.Dimension6_Level_id := x_Target_Level_Rec.Dimension6_Level_id;
  Check_Value_id_Conversion
  ( p_dim_level_id         => l_Target_Level_Rec.Dimension6_Level_id
  , p_Dim_level_short_name => x_Target_Level_Rec.Dimension6_Level_Short_Name
  , p_Dime_Level_NAME      => x_Target_Level_Rec.Dimension6_Level_Name
  , x_dim_level_id         => x_Target_Level_Rec.Dimension6_Level_ID
  , x_return_status        => x_return_status
  , x_error_Tbl            => x_error_Tbl
  );

  l_Target_Level_Rec.Dimension7_Level_id := x_Target_Level_Rec.Dimension7_Level_id;
  Check_Value_id_Conversion
  ( p_dim_level_id         => l_Target_Level_Rec.Dimension7_Level_id
  , p_Dim_level_short_name => x_Target_Level_Rec.Dimension7_Level_Short_Name
  , p_Dime_Level_NAME      => x_Target_Level_Rec.Dimension7_Level_Name
  , x_dim_level_id         => x_Target_Level_Rec.Dimension7_Level_ID
  , x_return_status        => x_return_status
  , x_error_Tbl            => x_error_Tbl
  );

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Target_Level_Rec.Default_Notify_Resp_id
                            , x_Target_Level_Rec.Default_Notify_Resp_Short_Name
                            , x_Target_Level_Rec.Default_Notify_Resp_Name
                            );

  if (l_convert = FND_API.G_TRUE) then
    BEGIN
      BIS_RESPONSIBILITY_PVT.DFR_Value_ID_Conversion
      ( p_api_version
      , x_Target_Level_Rec.Default_Notify_Resp_Short_Name
      , x_Target_Level_Rec.Default_Notify_Resp_Name
      , x_Target_Level_Rec.Default_Notify_Resp_ID
      , x_return_status
      , x_error_Tbl
      );
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        NULL;
    END;
  end if;

  l_convert := BIS_UTILITIES_PVT.Convert_to_ID
                            ( x_Target_Level_Rec.Computing_Function_id
                            , x_Target_Level_Rec.Computing_Function_Name
                            , x_Target_Level_Rec.Computing_user_Function_Name
                            );

  if (l_convert = FND_API.G_TRUE) then

--  if (BIS_UTILITIES_PUB.Value_Missing
--      (x_Target_Level_Rec.Computing_Function_ID) = FND_API.G_TRUE) then
    BEGIN
      BIS_COMPUTED_TARGET_PVT.Value_ID_Conversion
      ( p_api_version          => p_api_version
      , p_Computed_Target_Short_Name
         => x_Target_Level_Rec.Computing_Function_Name
      , p_Computed_Target_Name
         => x_Target_Level_Rec.Computing_User_Function_Name
      , x_Computed_Target_ID
         => x_Target_Level_Rec.Computing_Function_ID
      , x_return_status        => x_return_status
      , x_error_Tbl            => x_error_Tbl
       );

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR then
        NULL;
    END;
  end if;


  -- BUGBUG Value Id Conversion of UOM code, WF_ITEM_TYPE and report function
  -- NOT done

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_ID_Conversion;
--
PROCEDURE Value_ID_Conversion
( p_api_version                IN  NUMBER
, p_Target_Level_Short_Name IN  VARCHAR2
, p_Target_Level_Name       IN  VARCHAR2
, x_Target_Level_ID         OUT NOCOPY NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
, x_error_Tbl                  OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  if (BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Level_Short_Name)
                       = FND_API.G_TRUE) then
    SELECT Target_Level_id into x_Target_Level_ID
    FROM bisbv_Target_Levels
    WHERE target_level_short_name = p_Target_Level_Short_Name;
  elsif (BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Level_Name)
                       = FND_API.G_TRUE) then
    SELECT Target_Level_id into x_Target_Level_ID
    FROM bisbv_Target_Levels
    WHERE target_level_name = p_Target_Level_Name;
  else
    -- POLPULATE ERROR TABLE
    --added last two params
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

--commented RAISE
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
    --  RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Value_ID_Conversion'
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Value_ID_Conversion;
--
Procedure Retrieve_User_Target_Levels
( p_api_version      IN NUMBER
, p_user_id          IN NUMBER
, p_all_info         IN VARCHAR2 := FND_API.G_TRUE
, x_Target_Level_Tbl OUT NOCOPY BIS_Target_LEVEL_PUB.Target_Level_Tbl_Type
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_flag NUMBER :=0;
-- juwang bug#2225110 needs to check if end date and start date
-- expires in fnd_user_resp_groups
CURSOR ind_res IS
  select distinct ir.target_level_id, target_level_name
  from bis_indicator_resps  ir
     , fnd_user_resp_groups ur
     , bisbv_target_levels  il
  where ur.user_id           = p_user_id
  and   ir.responsibility_id = ur.responsibility_id
  AND   ur.start_date <= sysdate
  AND   nvl(ur.end_date, sysdate) >= sysdate
  and   il.target_level_id   = ir.target_level_id
  order by UPPER(target_level_name);

l_Target_Level_rec BIS_Target_LEVEL_PUB.Target_Level_Rec_Type;
l_Target_Level_rec_p BIS_Target_LEVEL_PUB.Target_Level_Rec_Type;
l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  for cr in ind_res loop
     l_flag :=1 ;
     l_Target_Level_rec.target_level_id := cr.target_level_id;

     l_Target_Level_rec_p := l_Target_Level_rec;
     BIS_Target_Level_PVT.Retrieve_Target_Level
     ( p_api_version      => 1.0
     , p_Target_Level_Rec => l_Target_Level_rec_p
     , p_all_info         => p_all_info
     , x_Target_Level_Rec => l_Target_Level_rec
     , x_return_status    => x_return_status
     , x_error_Tbl        => x_error_tbl
     );

     x_Target_Level_Tbl(x_Target_Level_Tbl.count + 1) := l_Target_Level_rec;
  end loop;

  if ind_res%isopen then close ind_res; end if;

  --added this check
  if(l_flag = 0) then
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_TARGET_LEVEL_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_User_Target_Levels'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
      RAISE FND_API.G_EXC_ERROR;
  end if;

--commented RAISE
EXCEPTION
   when FND_API.G_EXC_ERROR then
      if ind_res%isopen then close ind_res; end if;
      x_return_status := FND_API.G_RET_STS_ERROR ;
     -- RAISE FND_API.G_EXC_ERROR;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if ind_res%isopen then close ind_res; end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   when others then
      if ind_res%isopen then close ind_res; end if;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      --added last two params
      l_error_tbl := x_error_tbl;
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_User_Target_Levels'
       , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
      );
     -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_User_Target_Levels;

--
--
PROCEDURE Retrieve_Last_Update_Date
( p_api_version      IN  NUMBER
, p_Target_Level_Rec      IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_last_update_date OUT NOCOPY DATE
, x_return_status    OUT NOCOPY VARCHAR2
, x_error_Tbl        OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
  l_date_char VARCHAR2(32000);
  l_error_tbl BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  IF( BIS_UTILITIES_PUB.Value_Not_Missing(p_Target_Level_Rec.Target_Level_ID)
      = FND_API.G_TRUE
    ) THEN
    SELECT NVL(LAST_UPDATE_DATE, CREATION_DATE)
    INTO x_last_update_date
    FROM BIS_TARGET_LEVELS
    WHERE TARGET_LEVEL_ID = p_Target_Level_Rec.Target_Level_ID;
  END IF;

  --
  --commented RAISE
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    --added this message
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_name    => 'BIS_INVALID_TARGET_LEVEL_VALUE'
      , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Last_Update_Date'
      , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
      , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
    x_return_status := FND_API.G_RET_STS_ERROR;
   -- RAISE FND_API.G_EXC_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
  --  RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added last two params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Last_Update_Date'
    , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
   -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Retrieve_Last_Update_Date;
--
--
PROCEDURE Lock_Record
( p_api_version   IN  NUMBER
, p_Target_Level_Rec   IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_timestamp     IN  VARCHAR  := NULL
, x_return_status OUT NOCOPY VARCHAR2
, x_error_Tbl     OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
--
l_form_date        DATE;
l_last_update_date DATE;
l_Target_Level_Rec      BIS_Target_Level_PUB.Target_Level_Rec_Type;
l_error_tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  l_Target_Level_Rec.Target_Level_Id := p_Target_Level_Rec.Target_Level_Id;
  BIS_Target_Level_PVT.Retrieve_Last_Update_Date
                 ( p_api_version      => 1.0
                 , p_Target_Level_Rec => p_Target_Level_Rec
                 , x_last_update_date => l_last_update_date
                 , x_return_status    => x_return_status
                 , x_error_Tbl        => x_error_Tbl
                 );
  IF(p_timestamp IS NOT NULL) THEN
    l_form_date := TO_DATE(p_timestamp, BIS_UTILITIES_PVT.G_DATE_FORMAT);

    IF(l_form_date = l_last_update_date) THEN
      x_return_status := FND_API.G_TRUE;
    ELSE
      x_return_status := FND_API.G_FALSE;
    END IF;
  ELSE
    x_return_status := FND_API.G_FALSE;
  END IF;
  --
  --commented RAISE
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
   -- RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   -- RAISE;
  WHEN OTHERS THEN
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    --added last two params
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.BIS_Target_Level_PVT'
    , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--
END Lock_Record;
--

-- Retrieves the time level for the given target level
--
PROCEDURE Retrieve_Time_level
( p_api_version         IN  NUMBER
, p_Target_Level_Rec    IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Dimension_Level_Rec OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_dimension_level_number OUT NOCOPY NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_time_dimension_id NUMBER;
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_dimension_level_tbl BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type;
  l_found	      NUMBER := 0;
  l_error_tbl         BIS_UTILITIES_PUB.Error_Tbl_Type;

  CURSOR cr_tl_id_dim_level(p_target_level_id NUMBER) IS
    select
      dimension1_level_id,
      dimension2_level_id,
      dimension3_level_id,
      dimension4_level_id,
      dimension5_level_id,
      dimension6_level_id,
      dimension7_level_id
    from bisbv_target_levels
    where target_level_id = p_target_level_id;

  CURSOR cr_tl_sn_dim_level(p_target_level_short_name VARCHAR2) IS
    select
      dimension1_level_id,
      dimension2_level_id,
      dimension3_level_id,
      dimension4_level_id,
      dimension5_level_id,
      dimension6_level_id,
      dimension7_level_id
    from bisbv_target_levels
    where target_level_short_name = p_target_level_short_name;

BEGIN

  IF (BIS_UTILITIES_PVT.Value_Not_Missing(p_Target_Level_Rec.target_level_id)
      = FND_API.G_TRUE)
  AND (BIS_UTILITIES_PVT.Value_Not_Null(p_Target_Level_Rec.target_level_id)
      = FND_API.G_TRUE)
  THEN
    OPEN cr_tl_id_dim_level(p_Target_Level_Rec.target_level_id);
    FETCH cr_tl_id_dim_level INTO
      l_dimension_level_tbl(1).dimension_level_id,
      l_dimension_level_tbl(2).dimension_level_id,
      l_dimension_level_tbl(3).dimension_level_id,
      l_dimension_level_tbl(4).dimension_level_id,
      l_dimension_level_tbl(5).dimension_level_id,
      l_dimension_level_tbl(6).dimension_level_id,
      l_dimension_level_tbl(7).dimension_level_id;

       --added this
      if cr_tl_id_dim_level%NOTFOUND then
        --added this message
	l_error_tbl := x_error_tbl;
        BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_TARGET_LEVEL_VALUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Time_Level_Value'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
       );
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
      end if;

    CLOSE cr_tl_id_dim_level;
    --------
    Select dimension_id
    into l_time_dimension_id
    from bisbv_dimensions
    --'TIME'
    where upper(dimension_short_name) =
    BIS_UTILITIES_PVT.Get_Time_Dimension_Name_TL(p_Target_Level_Rec.target_level_id,NULL);
    --------
  ELSE
    OPEN cr_tl_sn_dim_level(p_Target_Level_Rec.target_level_short_name);
    FETCH cr_tl_sn_dim_level INTO
      l_dimension_level_tbl(1).dimension_level_id,
      l_dimension_level_tbl(2).dimension_level_id,
      l_dimension_level_tbl(3).dimension_level_id,
      l_dimension_level_tbl(4).dimension_level_id,
      l_dimension_level_tbl(5).dimension_level_id,
      l_dimension_level_tbl(6).dimension_level_id,
      l_dimension_level_tbl(7).dimension_level_id;

      --added this
      if cr_tl_sn_dim_level%NOTFOUND then
        --added this message
	l_error_tbl := x_error_tbl;
        BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_TARGET_LEVEL_VALUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Time_Level_Value'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
       );
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
      end if;

    CLOSE cr_tl_sn_dim_level;
     --------
    Select dimension_id
    into l_time_dimension_id
    from bisbv_dimensions
    --'TIME'
    where upper(dimension_short_name) =
    BIS_UTILITIES_PVT.Get_Time_Dimension_Name_TL(NULL,p_Target_Level_Rec.target_level_short_name);
    --------
  END IF;
  --moved this in the if condition for tl id and shortname
/*
  Select dimension_id
  into l_time_dimension_id
  from bisbv_dimensions
  --'TIME'
  where upper(dimension_short_name) =
  BIS_UTILITIES_PVT.Get_Time_Dimension_Name;
*/
  FOR i IN 1..l_dimension_level_tbl.COUNT LOOP
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level
    ( p_api_version
    , p_Dimension_Level_Rec => l_dimension_level_tbl(i)
    , x_Dimension_Level_Rec => l_Dimension_Level_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );
    IF l_Dimension_Level_Rec.DIMENSION_ID = l_time_dimension_id THEN
      x_Dimension_Level_Rec := l_Dimension_Level_Rec;
      x_dimension_level_number := i;
      l_found := 1;
      -- BIS_UTILITIES_PUB.put_line(p_text =>'Target level time dim level is: '||x_dimension_level_number);
      EXIT;
    END IF;
  END LOOP;

  IF (l_found = 0) then
    x_Dimension_Level_Rec.dimension_id := null;
    x_Dimension_Level_Rec.dimension_short_name := null;
    x_Dimension_Level_Rec.dimension_level_id := null;
    x_Dimension_Level_Rec.dimension_level_short_name := null;
    x_dimension_level_number := null;
  END IF;

EXCEPTION

  --added this
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
       IF cr_tl_sn_dim_level%ISOPEN THEN CLOSE cr_tl_sn_dim_level; END IF;
       IF cr_tl_id_dim_level%ISOPEN THEN CLOSE cr_tl_id_dim_level; END IF;
  WHEN OTHERS THEN
    --dbms_output('Error while getting time level: '||SQLERRM);
    IF cr_tl_sn_dim_level%ISOPEN THEN CLOSE cr_tl_sn_dim_level; END IF;
    IF cr_tl_id_dim_level%ISOPEN THEN CLOSE cr_tl_id_dim_level; END IF;
     x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
     l_error_Tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );

END Retrieve_Time_level;

-- Retrieves the time level for the given target level
--
PROCEDURE Retrieve_Time_level
( p_api_version                IN  NUMBER
, p_Target_Level_id            IN  NUMBER
, x_Dimension_Level_id         OUT NOCOPY NUMBER
, x_Dimension_Level_short_Name OUT NOCOPY NUMBER
, x_Dimension_Level_name       OUT NOCOPY NUMBER
, x_dimension_level_number     OUT NOCOPY NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
)
IS

  l_Target_Level_Rec       BIS_Target_Level_PUB.Target_Level_Rec_Type;
  l_Dimension_Level_Rec    BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_dimension_level_number NUMBER;
  l_error_Tbl              BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_return_status          VARCHAR2(32000);

BEGIN

  l_Target_Level_Rec.Target_Level_id := p_Target_Level_id;

  Retrieve_Time_level
  ( p_api_version             => 1.0
  , p_Target_Level_Rec        => l_Target_Level_Rec
  , x_Dimension_Level_Rec     => l_Dimension_Level_Rec
  , x_dimension_level_number  => l_dimension_level_number
  , x_return_status           => x_return_status
  , x_error_Tbl               => l_error_Tbl
  );

  x_Dimension_Level_id         := l_Dimension_Level_Rec.Dimension_Level_id;
  x_Dimension_Level_short_Name
    := l_Dimension_Level_Rec.Dimension_Level_short_Name;
  x_Dimension_Level_name       := l_Dimension_Level_Rec.Dimension_Level_name;
  x_dimension_level_number     := l_dimension_level_number;

END Retrieve_Time_level;


--
-- Retrieves the Org level for the given target level
--

PROCEDURE Retrieve_Org_level
( p_api_version         IN  NUMBER
, p_Target_Level_Rec    IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Dimension_Level_Rec OUT NOCOPY BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type
, x_dimension_level_number OUT NOCOPY NUMBER
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS

  l_org_dimension_id NUMBER;
  l_dimension_short_name VARCHAR2(80);
  l_Dimension_Level_Rec BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Rec_Type;
  l_dimension_level_tbl BIS_DIMENSION_LEVEL_PUB.Dimension_Level_Tbl_Type;
  l_err_track	NUMBER := 0;
  l_error_tbl   BIS_UTILITIES_PUB.Error_Tbl_Type;


  CURSOR cr_ol_id_dim_level(p_target_level_id NUMBER) IS
    select
      dimension1_level_id,
      dimension2_level_id,
      dimension3_level_id,
      dimension4_level_id,
      dimension5_level_id,
      dimension6_level_id,
      dimension7_level_id
    from bisbv_target_levels
    where target_level_id = p_target_level_id;

  CURSOR cr_ol_sn_dim_level(p_target_level_short_name VARCHAR2) IS
    select
      dimension1_level_id,
      dimension2_level_id,
      dimension3_level_id,
      dimension4_level_id,
      dimension5_level_id,
      dimension6_level_id,
      dimension7_level_id
    from bisbv_target_levels
    where target_level_short_name = p_target_level_short_name;

BEGIN

  -- BIS_UTILITIES_PUB.put_line(p_text =>' test inside bisvtalb tgt lvl id = ' || p_Target_Level_Rec.target_level_id );

  l_err_track := 100;

  IF (BIS_UTILITIES_PVT.Value_Not_Missing(p_Target_Level_Rec.target_level_id)
      = FND_API.G_TRUE)
  AND (BIS_UTILITIES_PVT.Value_Not_Null(p_Target_Level_Rec.target_level_id)
      = FND_API.G_TRUE)
  THEN

    l_err_track := 200;

    OPEN cr_ol_id_dim_level(p_Target_Level_Rec.target_level_id);
    FETCH cr_ol_id_dim_level INTO
      l_dimension_level_tbl(1).dimension_level_id,
      l_dimension_level_tbl(2).dimension_level_id,
      l_dimension_level_tbl(3).dimension_level_id,
      l_dimension_level_tbl(4).dimension_level_id,
      l_dimension_level_tbl(5).dimension_level_id,
      l_dimension_level_tbl(6).dimension_level_id,
      l_dimension_level_tbl(7).dimension_level_id;

       --added this
      if cr_ol_id_dim_level%NOTFOUND then
        --added this message
	l_error_tbl := x_error_tbl;
        BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_TARGET_LEVEL_VALUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Org_Level'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
       );
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
      end if;

      l_err_track := 300;

    CLOSE cr_ol_id_dim_level;


    --------

    l_err_track := 400;

    l_dimension_short_name := BIS_UTILITIES_PVT.Get_Org_Dimension_Name_TL(p_Target_Level_Rec.target_level_id,NULL);

    -- BIS_UTILITIES_PUB.put_line(p_text => ' dim short name = ' || l_dimension_short_name ) ;

    l_err_track := 500;

    Select dimension_id
    into l_org_dimension_id
    from bisbv_dimensions  -- 'ORG'
    where upper(dimension_short_name) = l_dimension_short_name;

    l_err_track := 600;

    --------


  ELSE


  OPEN cr_ol_sn_dim_level(p_Target_Level_Rec.target_level_short_name);

    FETCH cr_ol_sn_dim_level INTO
      l_dimension_level_tbl(1).dimension_level_id,
      l_dimension_level_tbl(2).dimension_level_id,
      l_dimension_level_tbl(3).dimension_level_id,
      l_dimension_level_tbl(4).dimension_level_id,
      l_dimension_level_tbl(5).dimension_level_id,
      l_dimension_level_tbl(6).dimension_level_id,
      l_dimension_level_tbl(7).dimension_level_id;


      if cr_ol_sn_dim_level%NOTFOUND then

        l_error_tbl := x_error_tbl;
        BIS_UTILITIES_PVT.Add_Error_Message
        ( p_error_msg_name    => 'BIS_INVALID_TARGET_LEVEL_VALUE'
        , p_error_msg_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
        , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Org_Level'
        , p_error_type        => BIS_UTILITIES_PUB.G_ERROR
        , p_error_table       => l_error_tbl
        , x_error_table       => x_error_tbl
       );

       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;

      end if;

    CLOSE cr_ol_sn_dim_level;

    --------

    l_dimension_short_name := BIS_UTILITIES_PVT.Get_Org_Dimension_Name_TL(NULL, p_Target_Level_Rec.target_level_short_name);

    Select dimension_id
    into l_org_dimension_id
    from bisbv_dimensions  --''ORG''
    where upper(dimension_short_name) = l_dimension_short_name;

    --------

  END IF;


  -- BIS_UTILITIES_PUB.put_line(p_text =>' test inside bisvtalb  ' );
  -- BIS_UTILITIES_PUB.put_line(p_text => ' l_org_dimension_id inside bisvtalb is = ' || l_org_dimension_id ) ;

  x_dimension_level_number := 0;

  FOR i IN 1..l_dimension_level_tbl.COUNT
  LOOP

    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level
    ( p_api_version
    , p_Dimension_Level_Rec => l_dimension_level_tbl(i)
    , x_Dimension_Level_Rec => l_Dimension_Level_Rec
    , x_return_status       => x_return_status
    , x_error_Tbl           => x_error_Tbl
    );

    IF l_Dimension_Level_Rec.DIMENSION_ID = l_org_dimension_id THEN
      x_Dimension_Level_Rec := l_Dimension_Level_Rec;
      x_dimension_level_number := i;
      BIS_UTILITIES_PUB.put_line(p_text =>'Target level org dim level is: '||x_dimension_level_number);
      EXIT;
    END IF;

  END LOOP;

  if (x_dimension_level_number = 0) then
    BIS_UTILITIES_PUB.put_line(p_text =>' bisvtalb: Org level could not be found for this target level ' ) ;
  end if;


EXCEPTION


  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
       IF cr_ol_sn_dim_level%ISOPEN THEN CLOSE cr_ol_sn_dim_level; END IF;
       IF cr_ol_id_dim_level%ISOPEN THEN CLOSE cr_ol_id_dim_level; END IF;
  WHEN OTHERS THEN
    BIS_UTILITIES_PUB.put_line(p_text =>'Error while getting org level: bisvtalb ' || l_err_track || SQLERRM);
    IF cr_ol_sn_dim_level%ISOPEN THEN CLOSE cr_ol_sn_dim_level; END IF;
    IF cr_ol_id_dim_level%ISOPEN THEN CLOSE cr_ol_id_dim_level; END IF;
    x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
    l_error_Tbl := x_error_Tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
                      ( p_error_table       => l_error_Tbl
                      , p_error_msg_id      => SQLCODE
                      , p_error_description => SQLERRM
                      , x_error_table       => x_error_Tbl
                      );

END Retrieve_Org_level;




-- New Procedure to return TargetLevel given the DimensionLevel ShortNames in any sequence
-- and the Measure Short Name

PROCEDURE Retrieve_TL_From_DimLvlShNms
(
  p_api_version   IN  NUMBER
, p_target_level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_Target_Level_Rec OUT NOCOPY BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_return_status       OUT NOCOPY VARCHAR2
, x_error_Tbl           OUT NOCOPY BIS_UTILITIES_PUB.Error_Tbl_Type
)
IS
l_measure_rec		      BIS_MEASURE_PUB.MEASURE_REC_TYPE;
l_measure_rec_p               BIS_MEASURE_PUB.MEASURE_REC_TYPE;
l_dim_level_rec               BIS_DIMENSION_LEVEL_PUB.DIMENSION_LEVEL_REC_TYPE;
l_dim_level_rec_p             BIS_DIMENSION_LEVEL_PUB.DIMENSION_LEVEL_REC_TYPE;
l_target_level_id             NUMBER;
l_error_tbl		      BIS_UTILITIES_PUB.Error_Tbl_Type;

l_dim1_id	   	      NUMBER;
l_dim2_id		      NUMBER;
l_dim3_id		      NUMBER;
l_dim4_id		      NUMBER;
l_dim5_id		      NUMBER;
l_dim6_id		      NUMBER;
l_dim7_id		      NUMBER;
l_dim1_level_id               NUMBER;
l_dim2_level_id               NUMBER;
l_dim3_level_id               NUMBER;
l_dim4_level_id               NUMBER;
l_dim5_level_id               NUMBER;
l_dim6_level_id               NUMBER;
l_dim7_level_id               NUMBER;

l_dim1_level_short_name       VARCHAR2(32000);
l_dim2_level_short_name       VARCHAR2(32000);
l_dim3_level_short_name       VARCHAR2(32000);
l_dim4_level_short_name       VARCHAR2(32000);
l_dim5_level_short_name       VARCHAR2(32000);
l_dim6_level_short_name       VARCHAR2(32000);
l_dim7_level_short_name       VARCHAR2(32000);

l_dim1_level_name       VARCHAR2(32000);
l_dim2_level_name       VARCHAR2(32000);
l_dim3_level_name       VARCHAR2(32000);
l_dim4_level_name       VARCHAR2(32000);
l_dim5_level_name       VARCHAR2(32000);
l_dim6_level_name       VARCHAR2(32000);
l_dim7_level_name       VARCHAR2(32000);

CURSOR c_dim_lvl(p_dim_level_short_name in varchar2) IS
SELECT level_id , name
FROM bis_levels_vl
WHERE short_name=p_dim_level_short_name;

BEGIN


  IF (p_target_level_rec.measure_short_name IS NOT NULL
   AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.measure_short_name) = FND_API.G_TRUE) THEN
     l_measure_rec.measure_short_name := p_target_level_rec.measure_short_name;
  END IF;
  IF (p_target_level_rec.measure_id IS NOT NULL
    AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.measure_id) = FND_API.G_TRUE) THEN
     l_measure_rec.measure_id := p_target_level_rec.measure_id;
  END IF;
  --Populate the measure record with all the relevant values
  l_measure_rec_p := l_measure_rec;
  BIS_MEASURE_PUB.RETRIEVE_MEASURE( p_api_version => p_api_version
			           ,p_measure_rec => l_measure_rec_p
			           ,p_all_info  =>FND_API.G_TRUE
				   ,x_measure_rec => l_measure_rec
                                   ,x_return_status => x_return_status
                                   ,x_error_tbl     => x_error_tbl
				   );


  IF (p_target_level_rec.dimension1_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension1_level_short_name) = FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(p_target_level_rec.dimension1_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension1_level_id,x_target_level_rec.dimension1_level_name;
     CLOSE c_dim_lvl;
  END IF;
  IF (p_target_level_rec.dimension2_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension2_level_short_name)= FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(p_target_level_rec.dimension2_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension2_level_id,x_target_level_rec.dimension2_level_name;
     CLOSE c_dim_lvl;
  END IF;
  IF (p_target_level_rec.dimension3_level_short_name IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension3_level_short_name)= FND_API.G_TRUE) THEN
      OPEN c_dim_lvl(p_target_level_rec.dimension3_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension3_level_id,x_target_level_rec.dimension3_level_name;
     CLOSE c_dim_lvl;
  END IF;
  IF (p_target_level_rec.dimension4_level_short_name IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension4_level_short_name)= FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(p_target_level_rec.dimension4_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension4_level_id,x_target_level_rec.dimension4_level_name;
     CLOSE c_dim_lvl;
  END IF;
  IF (p_target_level_rec.dimension5_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension5_level_short_name)= FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(p_target_level_rec.dimension5_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension5_level_id,x_target_level_rec.dimension5_level_name;
     CLOSE c_dim_lvl;
  END IF;
  IF (p_target_level_rec.dimension6_level_short_name IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension6_level_short_name)= FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(p_target_level_rec.dimension6_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension6_level_id,x_target_level_rec.dimension6_level_name;
     CLOSE c_dim_lvl;
  END IF;
  IF (p_target_level_rec.dimension7_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(p_target_level_rec.dimension7_level_short_name)= FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(p_target_level_rec.dimension7_level_short_name);
     FETCH c_dim_lvl INTO x_target_level_rec.dimension7_level_id,x_target_level_rec.dimension7_level_name;
     CLOSE c_dim_lvl;
  END IF;
  x_target_level_rec.measure_name := l_measure_rec.measure_name;
  x_target_level_Rec.measure_id := l_measure_rec.measure_id;

  --Get the dimension ids for all the dimension level ids. This will be later used to
  --sequence the dimension levels
  IF (x_target_level_rec.dimension1_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension1_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension1_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
								   );
    l_dim1_id := BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;

  IF (x_target_level_rec.dimension2_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension2_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension2_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                     		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
						   );
    l_dim2_id :=  BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;

  IF (x_target_level_rec.dimension3_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension3_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension3_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                     		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
						   );
    l_dim3_id := BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;

  IF (x_target_level_rec.dimension4_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension4_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension4_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                     		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
						   );
    l_dim4_id := BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;

  IF (x_target_level_rec.dimension5_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension5_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension5_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                     		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
						   );
    l_dim5_id := BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;

  IF (x_target_level_rec.dimension6_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension6_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension6_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                     		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
						   );
    l_dim6_id := BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;

  IF (x_target_level_rec.dimension7_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(x_target_level_rec.dimension7_level_id)= FND_API.G_TRUE) THEN
    SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := x_target_level_rec.dimension7_level_id;
    l_dim_level_rec_p := l_dim_level_rec;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version  => p_api_version
		                     		   ,p_Dimension_Level_Rec => l_dim_level_rec_p
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => x_return_status
						   ,x_error_Tbl           => x_error_tbl
						   );
    l_dim7_id := BIS_UTILITIES_PVT.checkmissnum(l_dim_level_rec.dimension_id);
  END IF;


  IF (l_measure_rec.dimension1_id = l_dim1_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension1_level_id;
      l_dim1_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension1_level_name;
      --l_dim1_level_value_id := p_dim1_level_value_id;
  ELSIF (l_measure_rec.dimension2_id = l_dim1_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension1_level_id;
      l_dim2_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension1_level_name;
     -- l_dim2_level_value_id := p_dim1_level_value_id;
  ELSIF (l_measure_rec.dimension3_id = l_dim1_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension1_level_id;
      l_dim3_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension1_level_name;
      --l_dim3_level_value_id := p_dim1_level_value_id;
  ELSIF (l_measure_rec.dimension4_id = l_dim1_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension1_level_id;
      l_dim4_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension1_level_name;
     -- l_dim4_level_value_id := p_dim1_level_value_id;
  ELSIF (l_measure_rec.dimension5_id = l_dim1_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension1_level_id;
      l_dim5_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension1_level_name;
     -- l_dim5_level_value_id := p_dim1_level_value_id;
  ELSIF (l_measure_rec.dimension6_id = l_dim1_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension1_level_id;
      l_dim6_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension1_level_name;
     -- l_dim6_level_value_id := p_dim1_level_value_id;
  ELSIF (l_measure_rec.dimension7_id = l_dim1_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension1_level_id;
      l_dim7_level_short_name := p_target_level_rec.dimension1_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension1_level_name;
     -- l_dim7_level_value_id := p_dim1_level_value_id;
  END IF;
  IF (l_measure_rec.dimension1_id = l_dim2_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension2_level_id;
      l_dim1_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension2_level_name;
     -- l_dim1_level_value_id := p_dim2_level_value_id;
  ELSIF (l_measure_rec.dimension2_id = l_dim2_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension2_level_id;
      l_dim2_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension2_level_name;
     -- l_dim2_level_value_id := p_dim2_level_value_id;
  ELSIF (l_measure_rec.dimension3_id = l_dim2_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension2_level_id;
      l_dim3_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension2_level_name;
     -- l_dim3_level_value_id := p_dim2_level_value_id;
  ELSIF (l_measure_rec.dimension4_id = l_dim2_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension2_level_id;
      l_dim4_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension2_level_name;
     -- l_dim4_level_value_id := p_dim2_level_value_id;
  ELSIF (l_measure_rec.dimension5_id = l_dim2_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension2_level_id;
      l_dim5_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension2_level_name;
      --l_dim5_level_value_id := p_dim2_level_value_id;
  ELSIF (l_measure_rec.dimension6_id = l_dim2_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension2_level_id;
      l_dim6_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension2_level_name;
      --l_dim6_level_value_id := p_dim2_level_value_id;
  ELSIF (l_measure_rec.dimension7_id = l_dim2_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension2_level_id;
      l_dim7_level_short_name := p_target_level_rec.dimension2_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension2_level_name;
     -- l_dim7_level_value_id := p_dim2_level_value_id;
  END IF;
  IF (l_measure_rec.dimension1_id = l_dim3_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension3_level_id;
      l_dim1_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension3_level_name;
      --l_dim1_level_value_id := p_dim3_level_value_id;
  ELSIF (l_measure_rec.dimension2_id = l_dim3_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension3_level_id;
      l_dim2_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension3_level_name;
      --l_dim2_level_value_id := p_dim3_level_value_id;
  ELSIF (l_measure_rec.dimension3_id = l_dim3_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension3_level_id;
      l_dim3_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension3_level_name;
      --l_dim3_level_value_id := p_dim3_level_value_id;
  ELSIF (l_measure_rec.dimension4_id = l_dim3_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension3_level_id;
      l_dim4_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension3_level_name;
     -- l_dim4_level_value_id := p_dim3_level_value_id;
  ELSIF (l_measure_rec.dimension5_id = l_dim3_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension3_level_id;
      l_dim5_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension3_level_name;
     -- l_dim5_level_value_id := p_dim3_level_value_id;
  ELSIF (l_measure_rec.dimension6_id = l_dim3_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension3_level_id;
      l_dim6_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension3_level_name;
      --l_dim6_level_value_id := p_dim3_level_value_id;
  ELSIF (l_measure_rec.dimension7_id = l_dim3_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension3_level_id;
      l_dim7_level_short_name := p_target_level_rec.dimension3_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension3_level_name;
     -- l_dim7_level_value_id := p_dim3_level_value_id;
  END IF;
  IF (l_measure_rec.dimension1_id = l_dim4_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension4_level_id;
      l_dim1_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension4_level_name;
     -- l_dim1_level_value_id := p_dim4_level_value_id;
  ELSIF (l_measure_rec.dimension2_id = l_dim4_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension4_level_id;
      l_dim2_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension4_level_name;
     -- l_dim2_level_value_id := p_dim4_level_value_id;
  ELSIF (l_measure_rec.dimension3_id = l_dim4_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension4_level_id;
      l_dim3_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension4_level_name;
     -- l_dim3_level_value_id := p_dim4_level_value_id;
  ELSIF (l_measure_rec.dimension4_id = l_dim4_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension4_level_id;
      l_dim4_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension4_level_name;
     -- l_dim4_level_value_id := p_dim4_level_value_id;
  ELSIF (l_measure_rec.dimension5_id = l_dim4_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension4_level_id;
      l_dim5_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension4_level_name;
     -- l_dim5_level_value_id := p_dim4_level_value_id;
  ELSIF (l_measure_rec.dimension6_id = l_dim4_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension4_level_id;
      l_dim6_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension4_level_name;
    --  l_dim6_level_value_id := p_dim4_level_value_id;
  ELSIF (l_measure_rec.dimension7_id = l_dim4_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension4_level_id;
      l_dim7_level_short_name := p_target_level_rec.dimension4_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension4_level_name;
    --  l_dim7_level_value_id := p_dim4_level_value_id;
  END IF;
  IF (l_measure_rec.dimension1_id = l_dim5_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension5_level_id;
      l_dim1_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension5_level_name;
    --  l_dim1_level_value_id := p_dim5_level_value_id;
  ELSIF (l_measure_rec.dimension2_id = l_dim5_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension5_level_id;
      l_dim2_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension5_level_name;
    --  l_dim2_level_value_id := p_dim5_level_value_id;
  ELSIF (l_measure_rec.dimension3_id = l_dim5_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension5_level_id;
      l_dim3_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension5_level_name;
     -- l_dim3_level_value_id := p_dim5_level_value_id;
  ELSIF (l_measure_rec.dimension4_id = l_dim5_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension5_level_id;
      l_dim4_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension5_level_name;
    --  l_dim4_level_value_id := p_dim5_level_value_id;
  ELSIF (l_measure_rec.dimension5_id = l_dim5_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension5_level_id;
      l_dim5_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension5_level_name;
    --  l_dim5_level_value_id := p_dim5_level_value_id;
  ELSIF (l_measure_rec.dimension6_id = l_dim5_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension5_level_id;
      l_dim6_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension5_level_name;
    --  l_dim6_level_value_id := p_dim5_level_value_id;
  ELSIF (l_measure_rec.dimension7_id = l_dim5_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension5_level_id;
      l_dim7_level_short_name := p_target_level_rec.dimension5_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension5_level_name;
     -- l_dim7_level_value_id := p_dim5_level_value_id;
  END IF;
  IF (l_measure_rec.dimension1_id = l_dim6_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension6_level_id;
      l_dim1_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension6_level_name;
     -- l_dim1_level_value_id := p_dim6_level_value_id;
  ELSIF (l_measure_rec.dimension2_id = l_dim6_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension6_level_id;
      l_dim2_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension6_level_name;
    --  l_dim2_level_value_id := p_dim6_level_value_id;
  ELSIF (l_measure_rec.dimension3_id = l_dim6_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension6_level_id;
      l_dim3_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension6_level_name;
    --  l_dim3_level_value_id := p_dim6_level_value_id;
  ELSIF (l_measure_rec.dimension4_id = l_dim6_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension6_level_id;
      l_dim4_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension6_level_name;
     -- l_dim4_level_value_id := p_dim6_level_value_id;
  ELSIF (l_measure_rec.dimension5_id = l_dim6_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension6_level_id;
      l_dim5_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension6_level_name;
    --  l_dim5_level_value_id := p_dim6_level_value_id;
  ELSIF (l_measure_rec.dimension6_id = l_dim6_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension6_level_id;
      l_dim6_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension6_level_name;
    --  l_dim6_level_value_id := p_dim6_level_value_id;
  ELSIF (l_measure_rec.dimension7_id = l_dim6_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension6_level_id;
      l_dim7_level_short_name := p_target_level_rec.dimension6_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension6_level_name;
    --  l_dim7_level_value_id := p_dim6_level_value_id;
  END IF;
  IF (l_measure_rec.dimension1_id = l_dim7_id) THEN
      l_dim1_level_id := x_target_level_rec.dimension7_level_id;
      l_dim1_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim1_level_name := x_target_level_rec.dimension7_level_name;
    --  l_dim1_level_value_id := p_dim7_level_value_id;
  ELSIF (l_measure_rec.dimension2_id = l_dim7_id) THEN
      l_dim2_level_id := x_target_level_rec.dimension7_level_id;
      l_dim2_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim2_level_name := x_target_level_rec.dimension7_level_name;
     -- l_dim2_level_value_id := p_dim7_level_value_id;
  ELSIF (l_measure_rec.dimension3_id = l_dim7_id) THEN
      l_dim3_level_id := x_target_level_rec.dimension7_level_id;
      l_dim3_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim3_level_name := x_target_level_rec.dimension7_level_name;
      --l_dim3_level_value_id := p_dim7_level_value_id;
  ELSIF (l_measure_rec.dimension4_id = l_dim7_id) THEN
      l_dim4_level_id := x_target_level_rec.dimension7_level_id;
      l_dim4_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim4_level_name := x_target_level_rec.dimension7_level_name;
    --  l_dim4_level_value_id := p_dim7_level_value_id;
  ELSIF (l_measure_rec.dimension5_id = l_dim7_id) THEN
      l_dim5_level_id := x_target_level_rec.dimension7_level_id;
      l_dim5_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim5_level_name := x_target_level_rec.dimension7_level_name;
    --  l_dim5_level_value_id := p_dim7_level_value_id;
  ELSIF (l_measure_rec.dimension6_id = l_dim7_id) THEN
      l_dim6_level_id := x_target_level_rec.dimension7_level_id;
      l_dim6_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim6_level_name := x_target_level_rec.dimension7_level_name;
    --  l_dim6_level_value_id := p_dim7_level_value_id;
  ELSIF (l_measure_rec.dimension7_id = l_dim7_id) THEN
      l_dim7_level_id := x_target_level_rec.dimension7_level_id;
      l_dim7_level_short_name := p_target_level_rec.dimension7_level_short_name;
      l_dim7_level_name := x_target_level_rec.dimension7_level_name;
    --  l_dim7_level_value_id := p_dim7_level_value_id;
  END IF;

  x_Target_Level_Rec.Measure_ID := l_Measure_Rec.Measure_ID;
  x_Target_Level_Rec.Dimension1_Level_ID := NVL(l_DIM1_LEVEL_ID,BIS_UTILITIES_PUB.G_NULL_NUM);
  x_Target_Level_Rec.Dimension2_Level_ID := NVL(l_DIM2_LEVEL_ID,BIS_UTILITIES_PUB.G_NULL_NUM);
  x_Target_Level_Rec.Dimension3_Level_ID := NVL(l_DIM3_LEVEL_ID,BIS_UTILITIES_PUB.G_NULL_NUM);
  x_Target_Level_Rec.Dimension4_Level_ID := NVL(l_DIM4_LEVEL_ID,BIS_UTILITIES_PUB.G_NULL_NUM);
  x_Target_Level_Rec.Dimension5_Level_ID := NVL(l_DIM5_LEVEL_ID,BIS_UTILITIES_PUB.G_NULL_NUM);
  x_Target_Level_Rec.Dimension6_Level_ID := NVL(l_DIM6_LEVEL_ID,BIS_UTILITIES_PUB.G_NULL_NUM);
  x_Target_Level_Rec.Dimension7_Level_ID := NVL(l_DIM7_LEVEL_ID,BIS_UTILITIES_PUB.G_NULL_NUM);
  l_target_level_id := Get_Level_Id_From_Dimlevels(x_target_level_rec)	;
  x_Target_Level_Rec.Target_Level_Id := l_target_level_id;
  x_Target_Level_Rec.Dimension1_Level_Short_Name := NVL(l_DIM1_LEVEL_SHORT_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);
  x_Target_Level_Rec.Dimension2_Level_Short_Name := NVL(l_DIM2_LEVEL_SHORT_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);
  x_Target_Level_Rec.Dimension3_Level_Short_Name := NVL(l_DIM3_LEVEL_SHORT_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);
  x_Target_Level_Rec.Dimension4_Level_Short_Name := NVL(l_DIM4_LEVEL_SHORT_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);
  x_Target_Level_Rec.Dimension5_Level_Short_Name := NVL(l_DIM5_LEVEL_SHORT_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);
  x_Target_Level_Rec.Dimension6_Level_Short_Name := NVL(l_DIM6_LEVEL_SHORT_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);
  x_Target_Level_Rec.Dimension7_Level_Short_Name := NVL(l_DIM7_LEVEL_SHORT_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);
  x_Target_Level_Rec.Dimension1_Level_Name := NVL(l_DIM1_LEVEL_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);
  x_Target_Level_Rec.Dimension2_Level_Name := NVL(l_DIM2_LEVEL_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);
  x_Target_Level_Rec.Dimension3_Level_Name := NVL(l_DIM3_LEVEL_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);
  x_Target_Level_Rec.Dimension4_Level_Name := NVL(l_DIM4_LEVEL_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);
  x_Target_Level_Rec.Dimension5_Level_Name := NVL(l_DIM5_LEVEL_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);
  x_Target_Level_Rec.Dimension6_Level_Name := NVL(l_DIM6_LEVEL_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);
  x_Target_Level_Rec.Dimension7_Level_Name := NVL(l_DIM7_LEVEL_NAME,BIS_UTILITIES_PUB.G_NULL_CHAR);

EXCEPTION
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --Added last two parameters
    l_error_tbl := x_error_tbl;
    BIS_UTILITIES_PVT.Add_Error_Message
    ( p_error_msg_id      => SQLCODE
    , p_error_description => SQLERRM
    , p_error_proc_name   => G_PKG_NAME||'.Create_Target_Level'
    , p_error_table       => l_error_tbl
      , x_error_table       => x_error_tbl
    );
    --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Retrieve_TL_From_DimLvlShNms;
--------------------------------

-- Given a target level short name update the
--  bis_target_levels, bis_target_levels_tl
-- for last_updated_by , created_by as 1
PROCEDURE updt_tl_attributes(p_tl_short_name  IN VARCHAR2
                       ,p_tl_new_short_name  IN VARCHAR2
                       ,x_return_status OUT NOCOPY VARCHAR2) AS
  CURSOR c_updt1 IS
   SELECT target_level_id , last_updated_by , created_by
   FROM bis_target_levels
   WHERE short_name = p_tl_short_name FOR UPDATE OF last_updated_by , created_by;

   l_pm_count NUMBER := 0;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR i IN c_updt1 LOOP

    l_pm_count := l_pm_count + 1;

    IF p_tl_new_short_name IS NOT NULL THEN
      UPDATE bis_target_levels SET  last_updated_by = 1 , created_by = 1, short_name = p_tl_new_short_name
      WHERE current of c_updt1;
    ELSE
      UPDATE bis_target_levels SET  last_updated_by = 1 , created_by = 1
      WHERE current of c_updt1;
    END IF;

    UPDATE bis_target_levels_tl SET last_updated_by = 1 , created_by = 1
    WHERE target_level_id = i.target_level_id;

  END LOOP;

  if l_pm_count = 0 then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  end if;

EXCEPTION
  WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF c_updt1%ISOPEN THEN
      CLOSE c_updt1;
    END IF;

END updt_tl_attributes;



PROCEDURE Validate_Dimensions -- Procedure added for 2486702
(
  p_target_level_rec 	IN  BIS_Target_Level_PUB.Target_Level_Rec_Type,
  x_return_status 	OUT NOCOPY VARCHAR2,
  x_return_msg 		OUT NOCOPY VARCHAR2
) IS
  l_measure_id 		NUMBER;
  l_measure_rec 	      BIS_MEASURE_PUB.MEASURE_REC_TYPE;
  l_measure_rec_p             BIS_MEASURE_PUB.MEASURE_REC_TYPE;
  l_return_status  	VARCHAR2(100);
  l_return_msg  	      VARCHAR2(3000);
  l_level_short_nm      bis_levels.short_name%TYPE;
  l_dim_short_nm	      bis_dimensions.short_name%TYPE;
  l_error_Tbl     	BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  SELECT indicator_id
  INTO l_measure_id
  FROM bis_indicators
  WHERE short_name = p_Target_Level_rec.Measure_short_Name;

  l_measure_rec.measure_id := l_measure_id ;

  l_measure_rec_p := l_measure_rec;
  BIS_MEASURE_PVT.Retrieve_Measure
  ( p_api_version   	=> 1.0
  , p_Measure_Rec   	=> l_measure_rec_p
  , p_all_info      	=> FND_API.G_TRUE
  , x_Measure_Rec   	=> l_measure_rec
  , x_return_status 	=> l_return_status
  , x_error_Tbl     	=> l_error_Tbl
  );

  IF (l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  Level_Correspond_To_Dim
  (
    p_target_level_rec => p_target_level_rec,
    p_measure_rec 	   => l_measure_rec,
    x_return_status    => l_return_status,
    x_return_msg       => l_return_msg
  );

  x_return_status := l_return_status ;

  IF (l_return_status = 'E') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := 'E';
    /* -- 2515991
    BIS_UTILITIES_PUB.put_line(p_text => 'Error in validation of Performance Measure for the Summary Level '
 	       || nvl (p_target_level_rec.target_level_short_name, ' ' )
             || '. ' || sqlerrm
		 || ' The measure ' || nvl(p_Target_Level_rec.Measure_short_Name, ' ')
		 || ' was not found in the target system. '
		 || ' This Summary Level will not be created. ') ;
    */

  WHEN OTHERS THEN
    x_return_status := 'E';
    /* -- 2515991
    BIS_UTILITIES_PUB.put_line(p_text => 'Error in validation of dimension levels for the Summary Level '
	     || nvl (p_target_level_rec.target_level_short_name, ' ' ) || '.'
             || ' This Summary Level will not be created. ') ;
    */

END;


PROCEDURE Level_Correspond_To_Dim -- Procedure added for 2486702
(
  p_target_level_rec 	IN BIS_Target_Level_PUB.Target_Level_Rec_Type
, p_measure_rec 		IN BIS_MEASURE_PUB.MEASURE_REC_TYPE
, x_return_status 	OUT NOCOPY VARCHAR2
, x_return_msg 		OUT NOCOPY VARCHAR2
) IS

  l_return_status1 	VARCHAR2(100);
  l_return_status2 	VARCHAR2(100);
  l_unique_levels 	BOOLEAN;
  l_unique_dims 	BOOLEAN;
  l_return_status4 	VARCHAR2(100);
  l_return_msg  		VARCHAR2(3000);
  l_num_dims		NUMBER := 0;
  l_num_levels		NUMBER := 0;
  l_dim_array       dim_tbl_type;
  l_lvl_array       lvl_tbl_type;
  l_error_msg		VARCHAR2(1000);

BEGIN

  GET_MEASURE_DIMS_ARRAY
  ( p_measure_rec 	 => p_measure_rec
  , x_dim_tbl_type   => l_dim_array
  , x_num_dims		 => l_num_dims
  , x_return_status  => l_return_status1
  , x_return_msg 	 => l_return_msg
  );

  l_unique_levels := CHECK_UNIQUE_DIMS
                     (p_dim_tbl_type    => l_dim_array);


  GET_TL_LVLS_ARRAY
  ( p_target_level_rec => p_target_level_rec
  , x_lvl_tbl_type     => l_lvl_array
  , x_num_lvls		   => l_num_levels
  , x_return_status    => l_return_status2
  , x_return_msg 	   => l_return_msg
  );


  l_unique_dims := CHECK_UNIQUE_LEVELS
                   (p_lvl_tbl_type    => l_lvl_array);


  IF (   (l_return_status1 = 'E')
      OR (l_return_status2 = 'E')
      OR (NOT(l_unique_levels))
      OR (NOT(l_unique_dims)) ) THEN

    RAISE FND_API.G_EXC_ERROR;

  END IF;

  COMPARE_LEVELS_DIMS
  ( p_dim_tbl_type     => l_dim_array
  , p_lvl_tbl_type     => l_lvl_array
  , p_tl_short_name    => p_target_level_rec.target_level_short_name
  , p_pm_short_name    => p_target_level_rec.measure_short_name
  , x_return_status    => l_return_status1
  , x_return_msg 	   => l_return_msg
  );

  IF (l_return_status1 = 'E') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_return_status := 'S';


EXCEPTION
  WHEN OTHERS THEN
    -- BIS_UTILITIES_PUB.put_line(p_text => ' Error in Level_Correspond_To_Dim in BIS_TARGET_LEVEL_PVT -- ' || sqlerrm ) ; -- 2515991
    x_return_status := 'E';

END Level_Correspond_To_Dim;


PROCEDURE COMPARE_LEVELS_DIMS  -- Procedure added for 2486702
( p_dim_tbl_type     IN  dim_tbl_type
, p_lvl_tbl_type     IN  lvl_tbl_type
, p_tl_short_name    IN  VARCHAR2
, p_pm_short_name    IN  VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_return_msg 	     OUT NOCOPY VARCHAR2
)
IS

  i                  NUMBER;
  j                  NUMBER;
  l_dim_id           NUMBER;
  l_match 	     BOOLEAN;
  l_dim_short_name   bis_dimensions.short_name%TYPE := NULL;
  l_lvl_short_name   bis_levels.short_name%TYPE := NULL;
  l_exists           NUMBER := NULL;
  l_dim_present	   BOOLEAN;
  l_lvl_present	   BOOLEAN;
  -- l_error_msg	   VARCHAR2(1000);

BEGIN


  FOR i IN 1..p_lvl_tbl_type.COUNT LOOP

    l_lvl_short_name := p_lvl_tbl_type(i);

    l_match := FALSE;

    l_dim_id := GET_DIM_ID_FRM_LVL_SHTNM
	            ( p_level_shtnm  => l_lvl_short_name);

    IF NOT(IS_NOT_NULL_MISSING_NUM(l_dim_id)) THEN
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR j IN 1..p_dim_tbl_type.COUNT LOOP
	IF (l_dim_id = p_dim_tbl_type(j)) THEN
	  l_match := TRUE; -- l_dim_short_name := GET_DIM_SHTNM_FRM_ID ( p_dim_id => l_dim_id);
	  EXIT;
	END IF;
    END LOOP;

    IF (l_match = FALSE) THEN

      /* -- 2515991
      l_error_msg :=  'In the definition of Summary Level '
                      || nvl( p_tl_short_name , ' ')
                      || ' for the Performance Measure '
                      || nvl( p_pm_short_name , ' ' )
		      || ' , there is no Dimension corresponding to the Level '
		      || nvl( l_lvl_short_name, ' ' )
		      || '. Upload of this Summary Level is therefore aborted.';

      BIS_UTILITIES_PUB.put_line(p_text => l_error_msg ) ;
      */

      RAISE FND_API.G_EXC_ERROR;

    END IF;

  END LOOP;


  FOR i IN 1..p_dim_tbl_type.COUNT LOOP

    l_match := FALSE;

    FOR j IN 1..p_lvl_tbl_type.COUNT LOOP

      l_lvl_short_name := p_lvl_tbl_type(j);

      l_dim_id := GET_DIM_ID_FRM_LVL_SHTNM
	            ( p_level_shtnm  => l_lvl_short_name);

	IF (l_dim_id = p_dim_tbl_type(i)) THEN
	  l_match := TRUE;
	  EXIT;
	END IF;
    END LOOP;

    IF (l_match = FALSE) THEN

      SELECT short_name
      INTO l_dim_short_name
      FROM bis_dimensions
      WHERE dimension_id = p_dim_tbl_type(i);

      /*  -- 2515991
      l_error_msg :=  'In the definition of Summary Level '
					  || nvl( p_tl_short_name , ' ')
					  || ' for the Performance Measure '
					  || nvl( p_pm_short_name , ' ' )
					  || ' , there is no Dimension Level corresponding to the Dimension '
					  || nvl( l_dim_short_name , ' ' )
					  || '. Upload of this Summary Level is therefore aborted.';
      BIS_UTILITIES_PUB.put_line(p_text => l_error_msg ) ;
      */

      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END LOOP;

  x_return_status := 'S';


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
    -- BIS_UTILITIES_PUB.put_line(p_text => ' Error in COMPARE_LEVELS_DIMS in BIS_TARGET_LEVEL_PVT -- ' || sqlerrm ) ; -- 2515991

END COMPARE_LEVELS_DIMS;



FUNCTION GET_DIM_ID_FRM_LVL_SHTNM  -- Function added for 2486702
( p_level_shtnm      IN VARCHAR2)
RETURN NUMBER
IS
  l_dim_id         NUMBER := NULL;

BEGIN

  SELECT dimension_id
  INTO   l_dim_id
  FROM   bis_levels
  WHERE  short_name = p_level_shtnm;

  RETURN l_dim_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- BIS_UTILITIES_PUB.put_line(p_text => 'There is no dimension corresponding to level ' || nvl( p_level_shtnm , ' ' ) ); -- 2515991
    RETURN NULL;
  WHEN OTHERS THEN
    -- BIS_UTILITIES_PUB.put_line(p_text => ' Error in GET_DIM_ID_FRM_LVL_SHTNM in BIS_TARGET_LEVEL_PVT -- ' || sqlerrm );-- 2515991
    RETURN NULL;
END GET_DIM_ID_FRM_LVL_SHTNM;



PROCEDURE GET_MEASURE_DIMS_ARRAY  -- Procedure added for 2486702
( p_measure_rec 	 IN BIS_MEASURE_PUB.MEASURE_REC_TYPE
, x_dim_tbl_type     OUT NOCOPY dim_tbl_type
, x_num_dims		 OUT NOCOPY NUMBER
, x_return_status 	 OUT NOCOPY VARCHAR2
, x_return_msg 		 OUT NOCOPY VARCHAR2
)
IS
  l_num_dims       NUMBER := 0;
  l_dim_tbl_type   dim_tbl_type;

BEGIN

  SELECT COUNT(1)
  INTO l_num_dims
  FROM BIS_INDICATOR_DIMENSIONS
  WHERE indicator_id = p_measure_rec.measure_id;

  IF (  (l_num_dims > 0)
	AND (l_num_dims < 8) ) THEN

    add_to_measure_array( p_dim_tbl_type => l_dim_tbl_type
	                  , p_dim_id       => p_measure_rec.dimension1_id );
    add_to_measure_array( p_dim_tbl_type => l_dim_tbl_type
	                  , p_dim_id       => p_measure_rec.dimension2_id );
    add_to_measure_array( p_dim_tbl_type => l_dim_tbl_type
	                  , p_dim_id       => p_measure_rec.dimension3_id );
    add_to_measure_array( p_dim_tbl_type => l_dim_tbl_type
	                  , p_dim_id       => p_measure_rec.dimension4_id );
    add_to_measure_array( p_dim_tbl_type => l_dim_tbl_type
	                  , p_dim_id       => p_measure_rec.dimension5_id );
    add_to_measure_array( p_dim_tbl_type => l_dim_tbl_type
	                  , p_dim_id       => p_measure_rec.dimension6_id );
    add_to_measure_array( p_dim_tbl_type => l_dim_tbl_type
	                  , p_dim_id       => p_measure_rec.dimension7_id );

    x_dim_tbl_type  := l_dim_tbl_type;
    x_num_dims      := l_num_dims;
    x_return_status := 'S';

  ELSE
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
    x_num_dims := 0;
    -- BIS_UTILITIES_PUB.put_line(p_text => 'The number of dimensions = ' || nvl (l_num_dims, 0) || ' is incorrect. ' ) ; -- 2515991
END GET_MEASURE_DIMS_ARRAY;


PROCEDURE ADD_TO_MEASURE_ARRAY  -- Procedure added for 2486702
( p_dim_tbl_type     IN OUT NOCOPY dim_tbl_type
, p_dim_id           IN     NUMBER
)
IS
BEGIN

  IF IS_NOT_NULL_MISSING_NUM(p_dim_id) THEN
    p_dim_tbl_type(p_dim_tbl_type.COUNT+1) := p_dim_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
    -- BIS_UTILITIES_PUB.put_line(p_text => 'Error in ADD_TO_MEASURE_ARRAY in BIS_TARGET_LEVEL_PVT  -- ' || sqlerrm ) ; -- 2515991
END ADD_TO_MEASURE_ARRAY;


PROCEDURE GET_TL_LVLS_ARRAY  -- Procedure added for 2486702
( p_target_level_rec IN  BIS_Target_Level_PUB.Target_Level_Rec_Type
, x_lvl_tbl_type     OUT NOCOPY lvl_tbl_type
, x_num_lvls		 OUT NOCOPY NUMBER
, x_return_status 	 OUT NOCOPY VARCHAR2
, x_return_msg 		 OUT NOCOPY VARCHAR2
)
IS

  l_num_levels		NUMBER := 0;
  l_lvl_tbl_type    lvl_tbl_type;

BEGIN

  ADD_TO_LEVEL_ARRAY( p_lvl_tbl_type => l_lvl_tbl_type
                    , p_short_name   => p_target_level_rec.ORG_LEVEL_SHORT_NAME);

  ADD_TO_LEVEL_ARRAY( p_lvl_tbl_type => l_lvl_tbl_type
                    , p_short_name   => p_target_level_rec.TIME_LEVEL_SHORT_NAME);

  ADD_TO_LEVEL_ARRAY( p_lvl_tbl_type => l_lvl_tbl_type
                    , p_short_name   => p_target_level_rec.dimension1_level_short_name);

  ADD_TO_LEVEL_ARRAY( p_lvl_tbl_type => l_lvl_tbl_type
                    , p_short_name   => p_target_level_rec.dimension2_level_short_name);

  ADD_TO_LEVEL_ARRAY( p_lvl_tbl_type => l_lvl_tbl_type
                    , p_short_name   => p_target_level_rec.dimension3_level_short_name);

  ADD_TO_LEVEL_ARRAY( p_lvl_tbl_type => l_lvl_tbl_type
                    , p_short_name   => p_target_level_rec.dimension4_level_short_name);

  ADD_TO_LEVEL_ARRAY( p_lvl_tbl_type => l_lvl_tbl_type
                    , p_short_name   => p_target_level_rec.dimension5_level_short_name);

  ADD_TO_LEVEL_ARRAY( p_lvl_tbl_type => l_lvl_tbl_type
                    , p_short_name   => p_target_level_rec.dimension6_level_short_name);

  ADD_TO_LEVEL_ARRAY( p_lvl_tbl_type => l_lvl_tbl_type
                    , p_short_name   => p_target_level_rec.dimension7_level_short_name);

  l_num_levels := l_lvl_tbl_type.COUNT;
  IF ( IS_NOT_NULL_MISSING_NUM(l_num_levels) ) THEN
    IF ( (l_num_levels>0) AND (l_num_levels<10)) THEN
      x_num_lvls      := l_num_levels;
    ELSE
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_lvl_tbl_type  := l_lvl_tbl_type;
  x_return_status := 'S';

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
    x_num_lvls := 0;
    -- BIS_UTILITIES_PUB.put_line(p_text => 'The number of dimension levels = ' || nvl(l_num_levels, 0) || ' is incorrect. ' ) ; -- 2515991
    -- BIS_UTILITIES_PUB.put_line(p_text => ' Error in GET_TL_LVLS_ARRAY in BIS_TARGET_LEVEL_PVT  -- ' || sqlerrm ) ;
END GET_TL_LVLS_ARRAY;



FUNCTION CHECK_UNIQUE_DIMS  -- Function added for 2486702
(p_dim_tbl_type     IN dim_tbl_type)
RETURN BOOLEAN IS

  i    		     NUMBER;
  j    		     NUMBER;
  l_num_dims           NUMBER;
  l_dim_short_name     bis_dimensions.short_name%TYPE;

BEGIN

  l_num_dims := p_dim_tbl_type.COUNT;

  IF NOT(IS_NOT_NULL_MISSING_NUM(l_num_dims)) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR i IN 1..l_num_dims LOOP
    FOR j IN (i+1)..l_num_dims LOOP
      IF ( p_dim_tbl_type(i) = p_dim_tbl_type(j) ) THEN

        SELECT short_name
	INTO   l_dim_short_name
	FROM   BIS_DIMENSIONS
	WHERE  dimension_id = p_dim_tbl_type(i);

        -- BIS_UTILITIES_PUB.put_line(p_text =>'The dimension ' || nvl(l_dim_short_name, ' ') || ' is not unique. ' ); -- 2515991

        RAISE FND_API.G_EXC_ERROR;

      END IF;
    END LOOP;
  END LOOP;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END CHECK_UNIQUE_DIMS;



PROCEDURE ADD_TO_LEVEL_ARRAY  -- Procedure added for 2486702
( p_lvl_tbl_type     IN OUT NOCOPY lvl_tbl_type
, p_short_name       IN     VARCHAR
)
IS
BEGIN

  IF IS_NOT_NULL_MISSING_CHAR(p_short_name) THEN
    p_lvl_tbl_type(p_lvl_tbl_type.COUNT+1) := p_short_name;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
    -- BIS_UTILITIES_PUB.put_line(p_text => 'The level ' || nvl(p_short_name, ' ') || ' is invalid. ' ) ; -- 2515991
END ADD_TO_LEVEL_ARRAY;



FUNCTION CHECK_UNIQUE_LEVELS  -- Function added for 2486702
(p_lvl_tbl_type     IN lvl_tbl_type)
RETURN BOOLEAN IS

  i    		     NUMBER;
  j    		     NUMBER;
  l_num_levels         NUMBER;
  l_count              NUMBER;
  l_dim_short_name     bis_dimensions.short_name%TYPE;

BEGIN

  l_num_levels := p_lvl_tbl_type.COUNT;

  IF NOT(IS_NOT_NULL_MISSING_NUM(l_num_levels)) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  FOR i IN 1..l_num_levels LOOP

    l_count := 0;

    FOR j IN (i+1)..l_num_levels LOOP
	IF (p_lvl_tbl_type(i) = p_lvl_tbl_type(j)) THEN
        IF (IS_ORG_OR_TIME_LEVEL(p_lvl_tbl_type(i))) THEN
	    l_count := l_count + 1;
	  ELSE
	    -- BIS_UTILITIES_PUB.put_line(p_text =>'The level ' || nvl(p_lvl_tbl_type(i), ' ') || ' is not unique. ' ); -- 2515991
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;
      END IF;
    END LOOP;

    IF (l_count > 1) THEN

      -- BIS_UTILITIES_PUB.put_line(p_text =>'The dimension level corresponding to Organization or Time dimension appears -- 2515991
      -- more than twice in the definition of this Summary Level.' );

      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END LOOP;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    -- BIS_UTILITIES_PUB.put_line(p_text => ' Error in CHECK_UNIQUE_LEVELS in BIS_TARGET_LEVEL_PVT  -- ' || sqlerrm ) ; -- 2515991
    RETURN FALSE;
END CHECK_UNIQUE_LEVELS;



FUNCTION IS_ORG_OR_TIME_LEVEL  -- Function added for 2486702
(p_lvl_short_name     IN VARCHAR2)
RETURN BOOLEAN IS

  l_dim_short_name  bis_dimensions.short_name%TYPE;

BEGIN

  SELECT D.short_name
  INTO l_dim_short_name
  FROM BIS_LEVELS L,
       BIS_DIMENSIONS D
  WHERE
       L.short_name = p_lvl_short_name
   AND L.dimension_id = D.dimension_id;

  IF (l_dim_short_name IN ('EDW_ORGANIZATION_M',
                           'ORGANIZATION',
			   'EDW_TIME_M',
			   'TIME')) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    -- BIS_UTILITIES_PUB.put_line(p_text => ' Error in IS_ORG_OR_TIME_LEVEL in BIS_TARGET_LEVEL_PVT  -- ' || sqlerrm ) ; -- 2515991
    RETURN FALSE;
END IS_ORG_OR_TIME_LEVEL;



FUNCTION IS_NOT_NULL_MISSING_CHAR  -- Function added for 2486702
(p_string	IN VARCHAR2)
RETURN BOOLEAN IS
BEGIN
  IF (
      (BIS_UTILITIES_PVT.Value_Not_Missing(p_string) = FND_API.G_TRUE)
	  AND
      (BIS_UTILITIES_PVT.Value_Not_Null(p_string) = FND_API.G_TRUE)
     ) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END IS_NOT_NULL_MISSING_CHAR;


FUNCTION IS_NOT_NULL_MISSING_NUM  -- Function added for 2486702
(p_number	IN NUMBER)
RETURN BOOLEAN IS
BEGIN
  IF (
      (BIS_UTILITIES_PVT.Value_Not_Missing(p_number) = FND_API.G_TRUE)
	  AND
      (BIS_UTILITIES_PVT.Value_Not_Null(p_number) = FND_API.G_TRUE)
     ) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END IS_NOT_NULL_MISSING_NUM;


END BIS_Target_Level_PVT;

/
