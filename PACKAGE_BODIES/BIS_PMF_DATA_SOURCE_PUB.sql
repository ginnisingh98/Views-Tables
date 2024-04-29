--------------------------------------------------------
--  DDL for Package Body BIS_PMF_DATA_SOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMF_DATA_SOURCE_PUB" AS
/* $Header: BISPDSCB.pls 115.19 2003/02/21 19:19:01 mdamle ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPDSCS.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Public API for the Data Source Connector			    |
REM |									    |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     APR-2000 irchen   Creation 				 	    |
REM | 27-JAN-03 arhegde For having different local variables for IN and OUT |
REM |                   parameters (bug#2758428)              	            |
REM | 30-JAN-03 sugopal FND_API.G_MISS_xxx should not be used in            |
REM |                   initialization or declaration (bug#2774644)         |
REM | 30-JAN-03 mdamle  SONAR Conversion to Java (APIs called from Java)    |
REM +=======================================================================+
*/
G_PKG_NAME CONSTANT VARCHAR2(30):= 'BIS_PMF_DATA_SOURCE_PUB';
--
-- Procedures
--

Procedure Retrieve_Target_Level
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_all_info         IN VARCHAR2 := FND_API.G_TRUE
, x_target_level_rec OUT NOCOPY BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
)
IS
  l_target_level_rec BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
  l_target_level_rec_p BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
  l_return_status    VARCHAR2(32000);
  l_error_Tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_target_level_rec := x_target_level_rec;

  BIS_PMF_DATA_SOURCE_PVT.Form_Target_Level_rec
  ( p_measure_instance      => p_measure_instance
  , p_dim_level_value_tbl   => p_dim_level_value_tbl
  , x_target_level_rec      => l_Target_Level_Rec
  );

  l_target_level_rec_p := l_Target_Level_Rec;

  BIS_Target_Level_PVT.Retrieve_Target_Level
  ( p_api_version         => 1.0
  , p_Target_Level_Rec    => l_target_level_rec_p
  , p_all_info            => p_all_info
  , x_Target_Level_Rec    => l_Target_Level_Rec
  , x_return_status       => l_return_status
  , x_error_Tbl           => l_error_Tbl
  );

  x_target_level_rec := l_target_level_rec;
  BIS_UTILITIES_PUB.put_line(p_text =>'Retrieved target level: '
  ||x_target_level_rec.target_level_short_Name);

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target_Level'
      );
      RETURN;
END Retrieve_Target_Level;

Procedure Retrieve_Target
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_all_info        IN VARCHAR2 := FND_API.G_TRUE
, x_target_rec      OUT NOCOPY BIS_TARGET_PUB.Target_Rec_Type
)
IS
  l_target_rec       BIS_TARGET_PUB.Target_Rec_Type;
  l_target_rec_p     BIS_TARGET_PUB.Target_Rec_Type;
  l_return_status    VARCHAR2(32000);
  l_error_Tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_target_rec := x_target_rec;

  BIS_PMF_DATA_SOURCE_PVT.Form_Target_rec
  ( p_measure_instance      => p_measure_instance
  , p_dim_level_value_tbl   => p_dim_level_value_tbl
  , x_target_rec            => l_Target_Rec
  );

  l_target_rec_p := l_Target_Rec;

  BIS_TARGET_PUB.Retrieve_Target
  ( p_api_version      => 1.0
  , p_Target_Rec       => l_target_rec_p
  , p_all_info         => p_all_info
  , x_Target_rec       => l_Target_rec
  , x_return_status    => l_return_status
  , x_error_Tbl        => l_error_Tbl
  );

  x_target_rec := l_target_rec;
  BIS_UTILITIES_PUB.put_line(p_text =>'Retrieved target: '||x_target_rec.target);

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
      );
      RETURN;
END Retrieve_Target;

Procedure Retrieve_Target_Owners
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_alert_type	   IN VARCHAR2 := NULL
, p_alert_level	   IN VARCHAR2 := NULL
, p_all_info       IN VARCHAR2 := FND_API.G_TRUE
, x_Target_owners_rec OUT NOCOPY BIS_TARGET_PUB.Target_Owners_Rec_Type
)
IS

  l_Target_owners_rec BIS_TARGET_PUB.Target_Owners_Rec_Type;
  l_Target_rec       BIS_TARGET_PUB.Target_Rec_Type;
  l_return_status    VARCHAR2(32000);
  l_error_Tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_Target_owners_rec := x_Target_owners_rec;

  BIS_PMF_DATA_SOURCE_PVT.Form_Target_rec
  ( p_measure_instance      => p_measure_instance
  , p_dim_level_value_tbl   => p_dim_level_value_tbl
  , x_target_rec            => l_Target_Rec
  );

  BIS_TARGET_PVT.Retrieve_Target_owners
  ( p_api_version      => 1.0
  , p_Target_Rec       => l_Target_Rec
  , p_all_info         => p_all_info
  , x_Target_owners_rec => l_Target_owners_rec
  , x_return_status    => l_return_status
  , x_error_Tbl        => l_error_Tbl
  );

  x_Target_owners_rec := l_Target_owners_rec;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Measure_Inst_Owners'
      );
      RETURN;

END Retrieve_Target_Owners;

Procedure Retrieve_Actual
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_all_info        IN VARCHAR2 := FND_API.G_TRUE
, x_actual_rec      OUT NOCOPY BIS_ACTUAL_PUB.Actual_Rec_Type
)
IS

 l_actual_rec       BIS_ACTUAL_PUB.Actual_Rec_Type;
 l_return_status    VARCHAR2(32000);
 l_error_Tbl        BIS_UTILITIES_PUB.Error_Tbl_Type;

BEGIN

  l_actual_rec := x_actual_rec;


  BIS_PMF_DATA_SOURCE_PVT.Form_Actual_rec
  ( p_measure_instance      => p_measure_instance
  , p_dim_level_value_tbl   => p_dim_level_value_tbl
  , x_actual_rec            => l_Actual_Rec
  );

  BIS_COMPUTED_ACTUAL_PVT.Retrieve_Actual_from_PMV
  ( p_api_version      => 1.0
  , p_all_info         => p_all_info
  , p_measure_instance => p_measure_instance
  , p_dim_level_value_tbl => p_dim_level_value_tbl
  , x_Actual_rec       => l_Actual_rec
  , x_return_status    => l_return_status
  , x_error_Tbl        => l_error_Tbl
  );

/*  BIS_COMPUTED_ACTUAL_PVT.Retrieve_Computed_Actual
  ( p_api_version      => 1.0
  , p_all_info         => p_all_info
  , p_measure_instance => p_measure_instance
  , p_dim_level_value_tbl => p_dim_level_value_tbl
  , x_Actual_rec       => l_Actual_rec
  , x_return_status    => l_return_status
  , x_error_Tbl        => l_error_Tbl
  ); */

  x_actual_rec := l_actual_rec;

  BIS_UTILITIES_PUB.put_line(p_text =>'Retrieved actual: '||x_actual_rec.actual);

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Actual'
      );
      RETURN;
END Retrieve_Actual;

Procedure Retrieve_Actual
( p_Measure_ID              IN NUMBER := NULL
, p_Target_Level_ID         IN NUMBER := NULL
, p_Plan_ID                 IN NUMBER := NULL
, p_Actual_ID               IN NUMBER := NULL
, p_Target_ID               IN NUMBER := NULL
, p_Dimension1_Level_ID       IN NUMBER := BIS_UTILITIES_PUB.G_NULL_NUM
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
, x_actual_value              OUT NOCOPY NUMBER
)
IS

  l_measure_instance  BIS_MEASURE_PUB.Measure_Instance_type;
  l_dim_level_value_tbl BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;
  l_actual_rec       BIS_ACTUAL_PUB.Actual_Rec_Type;
  l_return_status    VARCHAR2(32000);

BEGIN

  BIS_PMF_DATA_SOURCE_PVT.Form_Measure_Instance
  ( p_Measure_ID                => p_Measure_ID
  , p_Target_Level_ID           => p_Target_Level_ID
  , p_Plan_ID                   => p_Plan_ID
  , p_Actual_ID                 => p_Actual_ID
  , p_Target_ID                 => p_Target_ID
  , x_Measure_instance          => l_Measure_instance
  );

  BIS_PMF_DATA_SOURCE_PVT.Form_dim_level_value_tbl
  ( p_Dimension1_Level_ID       => p_Dimension1_Level_ID
  , p_Dimension1_Level_Value_ID => p_Dimension1_Level_Value_ID
  , p_Dimension2_Level_ID       => p_Dimension2_Level_ID
  , p_Dimension2_Level_Value_ID => p_Dimension2_Level_Value_ID
  , p_Dimension3_Level_ID       => p_Dimension3_Level_ID
  , p_Dimension3_Level_Value_ID => p_Dimension3_Level_Value_ID
  , p_Dimension4_Level_ID       => p_Dimension4_Level_ID
  , p_Dimension4_Level_Value_ID => p_Dimension4_Level_Value_ID
  , p_Dimension5_Level_ID       => p_Dimension5_Level_ID
  , p_Dimension5_Level_Value_ID => p_Dimension5_Level_Value_ID
  , p_Dimension6_Level_ID       => p_Dimension6_Level_ID
  , p_Dimension6_Level_Value_ID => p_Dimension6_Level_Value_ID
  , p_Dimension7_Level_ID       => p_Dimension7_Level_ID
  , p_Dimension7_Level_Value_ID => p_Dimension7_Level_Value_ID
  , x_dim_level_value_tbl       => l_dim_level_value_tbl
  );

  BIS_PMF_DATA_SOURCE_PVT.Form_Actual_rec
  ( p_measure_instance      => l_measure_instance
  , p_dim_level_value_tbl   => l_dim_level_value_tbl
  , x_actual_rec            => l_Actual_Rec
  );

  Retrieve_Actual
  ( p_measure_instance    => l_Measure_Instance
  , p_dim_level_value_tbl => l_Dim_Level_Value_Tbl
  , p_all_info            => FND_API.G_FALSE
  , x_actual_rec          => l_Actual_Rec
  );

  x_actual_value := l_actual_rec.actual;

  BIS_UTILITIES_PUB.put_line(p_text =>'Retrieved actual: '||x_actual_value);

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Actual'
      );
      RETURN;
END Retrieve_Actual;


-- mdamle 01/20/2003 - SONAR Conversion to Java - APIs called from Java
Procedure Retrieve_Target
( p_measure_id				IN NUMBER := NULL
, p_target_level_id			IN NUMBER
, p_plan_id				IN NUMBER := NULL
, p_dim1_level_value_id	 		IN VARCHAR2 := NULL
, p_dim2_level_value_id			IN VARCHAR2 := NULL
, p_dim3_level_value_id			IN VARCHAR2 := NULL
, p_dim4_level_value_id			IN VARCHAR2 := NULL
, p_dim5_level_value_id			IN VARCHAR2 := NULL
, p_dim6_level_value_id			IN VARCHAR2 := NULL
, p_dim7_level_value_id			IN VARCHAR2 := NULL
, x_target_id				OUT NOCOPY NUMBER
, x_target				OUT NOCOPY NUMBER
, x_range1_low				OUT NOCOPY NUMBER
, x_range1_high				OUT NOCOPY NUMBER
, x_range2_low				OUT NOCOPY NUMBER
, x_range2_high				OUT NOCOPY NUMBER
, x_range3_low				OUT NOCOPY NUMBER
, x_range3_high				OUT NOCOPY NUMBER
, x_notify_resp1_id			OUT NOCOPY NUMBER
, x_notify_resp1_short_name       	OUT NOCOPY VARCHAR2
, x_notify_resp1_name             	OUT NOCOPY VARCHAR2
, x_notify_resp2_id			OUT NOCOPY NUMBER
, x_notify_resp2_short_name       	OUT NOCOPY VARCHAR2
, x_notify_resp2_name             	OUT NOCOPY VARCHAR2
, x_notify_resp3_id			OUT NOCOPY NUMBER
, x_notify_resp3_short_name       	OUT NOCOPY VARCHAR2
, x_notify_resp3_name             	OUT NOCOPY VARCHAR2
, x_return_status    			OUT NOCOPY VARCHAR2
)
IS

  l_Measure_Instance BIS_MEASURE_PUB.Measure_Instance_type;
  l_Dim_Level_Value_Tbl BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;
  l_target_level_rec    BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
  l_target_rec          BIS_TARGET_PUB.Target_Rec_Type;
  l_return_status      	VARCHAR2(1000);
  l_return_msg         	VARCHAR2(32000);

BEGIN

  -- Debug messages should be printed irrespective of profile option.
  bis_utilities_pvt.set_debug_log_flag (  -- 2715218
    p_is_true         => TRUE
  , x_return_status   => l_return_status
  , x_return_msg      => l_return_msg
  ) ;

  BIS_UTILITIES_PUB.put_line(p_text =>' ------- Begin log file - Retrieve Target - From Java ------- ');

  -- Form a measure instance record
  --
  BIS_PMF_DATA_SOURCE_PVT.Form_Measure_Instance
  ( p_measure_id	=> p_measure_id
  , p_target_level_id	=> p_target_level_id
  , p_plan_id		=> p_plan_id
  , x_measure_instance	=> l_Measure_Instance
  );

  BIS_UTILITIES_PUB.put_line(p_text =>'Target level id: '||l_Measure_Instance.target_level_id);
  BIS_UTILITIES_PUB.put_line(p_text =>'Measure id: '||l_Measure_Instance.measure_id);


  -- Form a dimension level value table
  --
  BIS_PMF_DATA_SOURCE_PVT.Form_dim_level_value_tbl
  (
    p_dimension1_level_value_id	=> p_dim1_level_value_id
  , p_dimension2_level_value_id	=> p_dim2_level_value_id
  , p_dimension3_level_value_id	=> p_dim3_level_value_id
  , p_dimension4_level_value_id	=> p_dim4_level_value_id
  , p_dimension5_level_value_id	=> p_dim5_level_value_id
  , p_dimension6_level_value_id	=> p_dim6_level_value_id
  , p_dimension7_level_value_id	=> p_dim7_level_value_id
  , x_Dim_Level_Value_Tbl	=> l_Dim_Level_Value_Tbl
  );

  FOR i IN 1..7 LOOP
	  BIS_UTILITIES_PUB.put_line(p_text =>'Dim Level Value ' || i || ': '||l_Dim_Level_Value_Tbl(i).Dimension_Level_Value_ID);
  END LOOP;


  -- Request target information
  --
  BIS_PMF_DATA_SOURCE_PUB.Retrieve_Target
  ( p_measure_instance       => l_measure_instance
  , p_dim_level_value_tbl    => l_dim_level_value_tbl
  , p_all_info               => FND_API.G_FALSE
  , x_target_rec             => l_target_rec
  );

  x_target_id := l_target_rec.Target_id;
  x_target := l_target_rec.Target;
  x_range1_low := l_target_rec.Range1_low;
  x_range1_high := l_target_rec.Range1_high;
  x_range2_low := l_target_rec.Range2_low;
  x_range2_high := l_target_rec.Range2_high;
  x_range3_low := l_target_rec.Range3_low;
  x_range3_high := l_target_rec.Range3_high;
  x_notify_resp1_id := l_target_Rec.notify_resp1_id;
  x_notify_resp1_short_name := l_target_Rec.notify_resp1_short_name;
  x_notify_resp1_name := l_target_Rec.notify_resp1_name;
  x_notify_resp2_id := l_target_Rec.notify_resp2_id;
  x_notify_resp2_short_name := l_target_Rec.notify_resp2_short_name;
  x_notify_resp2_name := l_target_Rec.notify_resp2_name;
  x_notify_resp3_id := l_target_Rec.notify_resp3_id;
  x_notify_resp3_short_name := l_target_Rec.notify_resp3_short_name;
  x_notify_resp3_name := l_target_Rec.notify_resp3_name;


  BIS_UTILITIES_PUB.put_line(p_text =>' ------- End log file - Retrieve Target - From Java ------- ');

EXCEPTION
   when FND_API.G_EXC_ERROR then
      x_return_status := SQLERRM;
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := SQLERRM;
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Retrieve_Target'
      );
      RETURN;
END Retrieve_Target;

-- mdamle 01/20/2003 - SONAR Conversion to Java - APIs called from Java
PROCEDURE Post_Actual
(  p_Target_Level_ID		IN NUMBER
  ,p_Target_Level_Name          IN VARCHAR2
  ,p_Target_Level_Short_Name    IN VARCHAR2
  ,p_Dim1_Level_Value_ID        IN VARCHAR2
  ,p_Dim1_Level_Value_Name      IN VARCHAR2
  ,p_Dim2_Level_Value_ID        IN VARCHAR2
  ,p_Dim2_Level_Value_Name      IN VARCHAR2
  ,p_Dim3_Level_Value_ID        IN VARCHAR2
  ,p_Dim3_Level_Value_Name      IN VARCHAR2
  ,p_Dim4_Level_Value_ID        IN VARCHAR2
  ,p_Dim4_Level_Value_Name      IN VARCHAR2
  ,p_Dim5_Level_Value_ID        IN VARCHAR2
  ,p_Dim5_Level_Value_Name      IN VARCHAR2
  ,p_Dim6_level_Value_id	IN VARCHAR2
  ,p_Dim6_Level_Value_Name	IN VARCHAR2
  ,p_Dim7_Level_Value_ID        IN VARCHAR2
  ,p_Dim7_Level_Value_Name	IN VARCHAR2
  ,p_Actual                     IN NUMBER
  ,p_Report_Url                 IN VARCHAR2
  ,p_Comparison_actual_value    IN NUMBER
  ,x_return_status     		OUT NOCOPY VARCHAR2
) IS
  l_actual_rec 			BIS_ACTUAL_PUB.Actual_Rec_Type;
  l_msg_count         		NUMBER;
  l_msg_data          		VARCHAR2(32000);
  l_error_Tbl         		BIS_UTILITIES_PUB.Error_Tbl_Type;
BEGIN
  l_actual_rec.target_level_id := p_target_level_id;
  l_actual_rec.Target_Level_Name := p_Target_Level_Name;
  l_actual_rec.Target_Level_Short_Name := p_Target_Level_Short_Name;

  l_actual_rec.Dim1_Level_Value_ID := p_Dim1_Level_Value_ID;
  l_actual_rec.Dim1_Level_Value_Name := p_Dim1_Level_Value_Name;

  l_actual_rec.Dim2_Level_Value_ID := p_Dim2_Level_Value_ID;
  l_actual_rec.Dim2_Level_Value_Name := p_Dim2_Level_Value_Name;

  l_actual_rec.Dim3_Level_Value_ID := p_Dim3_Level_Value_ID;
  l_actual_rec.Dim3_Level_Value_Name := p_Dim3_Level_Value_Name;

  l_actual_rec.Dim4_Level_Value_ID := p_Dim4_Level_Value_ID;
  l_actual_rec.Dim4_Level_Value_Name := p_Dim4_Level_Value_Name;

  l_actual_rec.Dim5_Level_Value_ID := p_Dim5_Level_Value_ID;
  l_actual_rec.Dim5_Level_Value_Name := p_Dim5_Level_Value_Name;

  l_actual_rec.Dim6_Level_Value_ID := p_Dim6_Level_Value_ID;
  l_actual_rec.Dim6_Level_Value_Name := p_Dim6_Level_Value_Name;

  l_actual_rec.Dim7_Level_Value_ID := p_Dim7_Level_Value_ID;
  l_actual_rec.Dim7_Level_Value_Name := p_Dim7_Level_Value_Name;

  l_actual_rec.actual := p_actual;
  l_actual_rec.report_url := p_report_url;
  l_actual_rec.comparison_actual_value := p_comparison_actual_value;

    BIS_ACTUAL_PUB.Post_Actual
    ( p_api_version       => 1.0
    , p_commit            => FND_API.G_TRUE
    , p_Actual_Rec        => l_actual_rec
    , x_return_status     => x_return_status
    , x_msg_count         => l_msg_count
    , x_msg_data          => l_msg_data
    , x_error_Tbl         => l_error_Tbl
    );

    BIS_UTILITIES_PUB.put_line(p_text =>'Actual posted: '||x_return_status);

END Post_Actual;


END BIS_PMF_DATA_SOURCE_PUB;

/
