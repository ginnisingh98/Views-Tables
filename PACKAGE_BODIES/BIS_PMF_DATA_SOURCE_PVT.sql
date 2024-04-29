--------------------------------------------------------
--  DDL for Package Body BIS_PMF_DATA_SOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMF_DATA_SOURCE_PVT" AS
/* $Header: BISVDSCB.pls 115.16 2003/01/30 09:10:11 sugopal ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVDSCB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for the Data Source Connector
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     APR-2000 irchen   Creation
REM | 30-JAN-03 sugopal FND_API.G_MISS_xxx should not be used in            |
REM |                   initialization or declaration (bug#2774644)         |
REM +=======================================================================+
*/
G_PKG_NAME CONSTANT VARCHAR2(30):= 'BIS_PMF_DATA_SOURCE_PVT';
--
-- Constants
--


--
-- Procedures
--

Procedure Form_Target_Level_rec
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_target_level_rec OUT NOCOPY BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
)
IS

 l_target_level_rec BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;

BEGIN

  l_target_level_rec := x_target_level_rec;

  l_target_level_rec.measure_Id := p_measure_instance.Measure_ID;
  l_target_level_rec.measure_short_name
    := p_measure_instance.Measure_short_name;
  l_target_level_rec.measure_name := p_measure_instance.Measure_name;

  l_target_level_rec.Target_Level_Id := p_measure_instance.Target_Level_ID;
  l_target_level_rec.Target_Level_short_name
    := p_measure_instance.Target_Level_short_name;
  l_target_level_rec.Target_Level_name := p_measure_instance.Target_Level_name;

  x_target_level_rec := l_target_level_rec;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'. Form_Target_Level_rec'
      );
      RETURN;
END  Form_Target_Level_rec;

Procedure Form_Target_rec
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_target_rec      OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
)
IS

 l_target_rec BIS_TARGET_PUB.Target_Rec_Type;

BEGIN

  l_target_rec := x_target_rec;

  l_target_rec.Target_Level_Id := p_measure_instance.Target_Level_ID;
  l_target_rec.Target_Level_short_name
    := p_measure_instance.Target_Level_short_name;
  l_target_rec.Target_Level_name := p_measure_instance.Target_Level_name;

  l_target_rec.plan_Id := p_measure_instance.plan_ID;
  l_target_rec.plan_short_name := p_measure_instance.plan_short_name;
  l_target_rec.plan_name := p_measure_instance.plan_name;

  l_target_rec.Target_id := p_measure_instance.target_id;
  l_target_rec.Target := p_measure_instance.target;

  l_target_rec.range1_low := p_measure_instance.range1_low;
  l_target_rec.range1_high := p_measure_instance.range1_high;
  l_target_rec.range2_low := p_measure_instance.range2_low;
  l_target_rec.range2_high := p_measure_instance.range2_high;
  l_target_rec.range3_low := p_measure_instance.range3_low;
  l_target_rec.range3_high := p_measure_instance.range3_high;

  l_target_rec.Notify_Resp1_ID := p_measure_instance.Range1_Owner_ID;
  l_target_rec.Notify_Resp1_Short_Name
    := p_measure_instance.Range1_Owner_Short_Name;
  l_target_rec.Notify_Resp1_Name := p_measure_instance.Range1_Owner_Name;
  l_target_rec.Notify_Resp2_ID := p_measure_instance.Range2_Owner_ID;
  l_target_rec.Notify_Resp2_Short_Name
    := p_measure_instance.Range2_Owner_Short_Name;
  l_target_rec.Notify_Resp2_Name := p_measure_instance.Range2_Owner_Name;
  l_target_rec.Notify_Resp3_ID := p_measure_instance.Range3_Owner_ID;
  l_target_rec.Notify_Resp3_Short_Name
    := p_measure_instance.Range3_Owner_Short_Name;
  l_target_rec.Notify_Resp3_Name := p_measure_instance.Range3_Owner_Name;

  l_target_rec.Dim1_Level_Value_ID
    := p_dim_level_value_tbl(1).Dimension_Level_Value_ID;
  l_target_rec.Dim1_Level_Value_Name
    := p_dim_level_value_tbl(1).Dimension_Level_Value_name;
  l_target_rec.Dim2_Level_Value_ID
    := p_dim_level_value_tbl(2).Dimension_Level_Value_ID;
  l_target_rec.Dim2_Level_Value_Name
    := p_dim_level_value_tbl(2).Dimension_Level_Value_name;
/*
  l_target_rec.Org_Level_Value_ID
    := p_dim_level_value_tbl(1).Dimension_Level_Value_ID;
  l_target_rec.Org_Level_Value_Name
    := p_dim_level_value_tbl(1).Dimension_Level_Value_name;
  l_target_rec.Time_Level_Value_ID
    := p_dim_level_value_tbl(2).Dimension_Level_Value_ID;
  l_target_rec.Time_Level_Value_Name
    := p_dim_level_value_tbl(2).Dimension_Level_Value_name;
*/
  l_target_rec.Dim3_Level_Value_ID
    := p_dim_level_value_tbl(3).Dimension_Level_Value_ID;
  l_target_rec.Dim3_Level_Value_Name
    := p_dim_level_value_tbl(3).Dimension_Level_Value_name;
  l_target_rec.Dim4_Level_Value_ID
    := p_dim_level_value_tbl(4).Dimension_Level_Value_ID;
  l_target_rec.Dim4_Level_Value_Name
    := p_dim_level_value_tbl(4).Dimension_Level_Value_name;
  l_target_rec.Dim5_Level_Value_ID
    := p_dim_level_value_tbl(5).Dimension_Level_Value_ID;
  l_target_rec.Dim5_Level_Value_Name
    := p_dim_level_value_tbl(5).Dimension_Level_Value_name;
  l_target_rec.Dim6_Level_Value_ID
    := p_dim_level_value_tbl(6).Dimension_Level_Value_ID;
  l_target_rec.Dim6_Level_Value_Name
    := p_dim_level_value_tbl(6).Dimension_Level_Value_name;
  l_target_rec.Dim7_Level_Value_ID
    := p_dim_level_value_tbl(7).Dimension_Level_Value_ID;
  l_target_rec.Dim7_Level_Value_Name
    := p_dim_level_value_tbl(7).Dimension_Level_Value_name;

  x_target_rec := l_target_rec;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Form_Target_rec'
      );
      RETURN;
END Form_Target_rec;

Procedure Form_Actual_rec
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, x_actual_rec      OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
)
IS

 l_actual_rec BIS_ACTUAL_PUB.Actual_Rec_Type;

BEGIN

  l_actual_rec := x_actual_rec;

  l_actual_rec.target_Level_Id := p_measure_instance.Target_Level_ID;
  l_actual_rec.Target_Level_short_name
    := p_measure_instance.Target_Level_short_name;
  l_actual_rec.Target_Level_name := p_measure_instance.Target_Level_name;

  l_actual_rec.Actual_id := p_measure_instance.actual_id;
  l_actual_rec.Actual := p_measure_instance.actual;

  l_actual_rec.Dim1_Level_Value_ID
    := p_dim_level_value_tbl(1).Dimension_Level_Value_ID;
  l_actual_rec.Dim1_Level_Value_Name
    := p_dim_level_value_tbl(1).Dimension_Level_Value_name;
  l_actual_rec.Dim2_Level_Value_ID
    := p_dim_level_value_tbl(2).Dimension_Level_Value_ID;
  l_actual_rec.Dim2_Level_Value_Name
    := p_dim_level_value_tbl(2).Dimension_Level_Value_name;
/*
  l_actual_rec.Org_Level_Value_ID
    := p_dim_level_value_tbl(1).Dimension_Level_Value_ID;
  l_actual_rec.Org_Level_Value_Name
    := p_dim_level_value_tbl(1).Dimension_Level_Value_name;
  l_actual_rec.Time_Level_Value_ID
    := p_dim_level_value_tbl(2).Dimension_Level_Value_ID;
  l_actual_rec.Time_Level_Value_Name
    := p_dim_level_value_tbl(2).Dimension_Level_Value_name;
*/
  l_actual_rec.Dim3_Level_Value_ID
    := p_dim_level_value_tbl(3).Dimension_Level_Value_ID;
  l_actual_rec.Dim3_Level_Value_Name
    := p_dim_level_value_tbl(3).Dimension_Level_Value_name;
  l_actual_rec.Dim4_Level_Value_ID
    := p_dim_level_value_tbl(4).Dimension_Level_Value_ID;
  l_actual_rec.Dim4_Level_Value_Name
    := p_dim_level_value_tbl(4).Dimension_Level_Value_name;
  l_actual_rec.Dim5_Level_Value_ID
    := p_dim_level_value_tbl(5).Dimension_Level_Value_ID;
  l_actual_rec.Dim5_Level_Value_Name
    := p_dim_level_value_tbl(5).Dimension_Level_Value_name;
  l_actual_rec.Dim6_Level_Value_ID
    := p_dim_level_value_tbl(6).Dimension_Level_Value_ID;
  l_actual_rec.Dim6_Level_Value_Name
    := p_dim_level_value_tbl(6).Dimension_Level_Value_name;
  l_actual_rec.Dim7_Level_Value_ID
    := p_dim_level_value_tbl(7).Dimension_Level_Value_ID;
  l_actual_rec.Dim7_Level_Value_Name
    := p_dim_level_value_tbl(7).Dimension_Level_Value_name;

  x_actual_rec := l_actual_rec;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Form_Actual_rec'
      );
      RETURN;
END Form_Actual_rec;

Procedure Form_Measure_Instance
( p_Measure_ID              IN NUMBER := NULL
, p_Target_Level_ID         IN NUMBER := NULL
, p_Plan_ID                 IN NUMBER := NULL
, p_Actual_ID               IN NUMBER := NULL
, p_Target_ID               IN NUMBER := NULL
, x_Measure_instance        OUT NOCOPY BIS_MEASURE_PUB.Measure_Instance_type
)
IS

  l_Measure_instance  BIS_MEASURE_PUB.Measure_Instance_type;

BEGIN

  l_Measure_instance := x_Measure_instance;

  l_measure_instance.Measure_ID      := p_Measure_ID;
  l_measure_instance.Target_Level_ID := p_Target_Level_ID;
  l_measure_instance.Plan_ID         := p_Plan_ID;
  l_measure_instance.Actual_ID       := p_Actual_ID;
  l_measure_instance.Target_ID       := p_Target_ID;

  x_Measure_instance := l_Measure_instance;

END Form_Measure_Instance;

Procedure Form_dim_level_value_tbl
( p_Dimension1_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension1_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, p_Dimension2_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension2_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, p_Dimension3_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension3_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, p_Dimension4_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension4_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, p_Dimension5_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension5_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, p_Dimension6_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension6_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, p_Dimension7_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
, p_Dimension7_Level_Value_ID IN VARCHAR2 := BIS_UTILITIES_PUB.G_NULL_CHAR
, x_dim_level_value_tbl	  OUT NOCOPY BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
)
IS

  l_dim_level_value_tbl	BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;

BEGIN

  l_dim_level_value_tbl := x_dim_level_value_tbl;

  l_dim_level_value_tbl(1).Dimension_Level_ID
    := p_Dimension1_Level_ID;
  l_dim_level_value_tbl(2).Dimension_Level_ID
    := p_Dimension2_Level_ID;
  l_dim_level_value_tbl(3).Dimension_Level_ID
    := p_Dimension3_Level_ID;
  l_dim_level_value_tbl(4).Dimension_Level_ID
    := p_Dimension4_Level_ID;
  l_dim_level_value_tbl(5).Dimension_Level_ID
    := p_Dimension5_Level_ID;
  l_dim_level_value_tbl(6).Dimension_Level_ID
    := p_Dimension6_Level_ID;
  l_dim_level_value_tbl(7).Dimension_Level_ID
    := p_Dimension7_Level_ID;

  l_dim_level_value_tbl(1).Dimension_Level_Value_ID
    := p_Dimension1_Level_Value_ID;
  l_dim_level_value_tbl(2).Dimension_Level_Value_ID
    := p_Dimension2_Level_Value_ID;
  l_dim_level_value_tbl(3).Dimension_Level_Value_ID
    := p_Dimension3_Level_Value_ID;
  l_dim_level_value_tbl(4).Dimension_Level_Value_ID
    := p_Dimension4_Level_Value_ID;
  l_dim_level_value_tbl(5).Dimension_Level_Value_ID
    := p_Dimension5_Level_Value_ID;
  l_dim_level_value_tbl(6).Dimension_Level_Value_ID
    := p_Dimension6_Level_Value_ID;
  l_dim_level_value_tbl(7).Dimension_Level_Value_ID
    := p_Dimension7_Level_Value_ID;

  x_dim_level_value_tbl := l_dim_level_value_tbl;

END Form_dim_level_value_tbl;

Procedure Sync_Target_Measure_Owners
( p_measure_instance     IN BIS_MEASURE_PUB.Measure_Instance_type
, p_Target_owners_rec    IN BIS_TARGET_PUB.Target_Owners_Rec_Type
, x_measure_instance     IN OUT NOCOPY BIS_MEASURE_PUB.Measure_Instance_type
)
IS

  l_measure_instance BIS_MEASURE_PUB.Measure_Instance_type;

BEGIN

  l_measure_instance := p_measure_instance;

  l_measure_instance.Range1_Owner_ID := p_target_owners_rec.Range1_Owner_ID;
  l_measure_instance.Range1_Owner_Short_Name
    := p_target_owners_rec.Range1_Owner_Short_Name;
  l_measure_instance.Range1_Owner_Name
    := p_target_owners_rec.Range1_Owner_Name;

  l_measure_instance.Range2_Owner_ID := p_target_owners_rec.Range2_Owner_ID;
  l_measure_instance.Range2_Owner_Short_Name
    := p_target_owners_rec.Range2_Owner_Short_Name;
  l_measure_instance.Range2_Owner_Name
    := p_target_owners_rec.Range2_Owner_Name;

  l_measure_instance.Range3_Owner_ID := p_target_owners_rec.Range3_Owner_ID;
  l_measure_instance.Range3_Owner_Short_Name
    := p_target_owners_rec.Range3_Owner_Short_Name;
  l_measure_instance.Range3_Owner_Name
    := p_target_owners_rec.Range3_Owner_Name;

  x_measure_instance := l_measure_instance;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Sync_Target_Measure_Owners'
      );
      RETURN;

END Sync_Target_Measure_Owners;


END BIS_PMF_DATA_SOURCE_PVT;

/
