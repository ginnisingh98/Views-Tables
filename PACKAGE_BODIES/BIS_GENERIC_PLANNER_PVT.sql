--------------------------------------------------------
--  DDL for Package Body BIS_GENERIC_PLANNER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_GENERIC_PLANNER_PVT" AS
/* $Header: BISVGPLB.pls 115.21 2003/01/27 13:35:23 mahrao ship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISVGPLB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Private API for the Generic Planning Service
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM |     APR-2000 irchen   Creation				            |
REM |     FEB-2002 sashaik  Fix for 2193340. Actual value can be null.      |
REM | 23-JAN-03    mahrao For having different local variables for IN and OUT
REM |                     parameters.
REM +=======================================================================+
*/
G_PKG_NAME CONSTANT VARCHAR2(30):= 'BIS_GENERIC_PLANNER_PVT';

--
-- Procedures
--

Procedure Sync_All_Fields
( p_measure_instance       IN BIS_MEASURE_PUB.Measure_Instance_type
, p_target_level_rec       IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, p_target_rec	           IN BIS_TARGET_PUB.Target_Rec_Type
, p_target_owners_rec      IN BIS_TARGET_PUB.Target_Owners_Rec_Type
, p_actual_rec	           IN BIS_ACTUAL_PUB.Actual_Rec_Type
, x_measure_instance       IN OUT NOCOPY BIS_MEASURE_PUB.Measure_Instance_type
);

Procedure Service_Planner_Request
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, p_alert_type	    	  IN VARCHAR2 := NULL
, p_alert_level	    	  IN VARCHAR2 := NULL
)
IS

  l_measure_instance    BIS_MEASURE_PUB.Measure_Instance_type;
  l_dim_level_value_tbl	BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type;
  l_target_level_rec    BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;
  l_target_rec          BIS_TARGET_PUB.Target_Rec_Type;
  l_target_owners_rec   BIS_TARGET_PUB.Target_Owners_Rec_Type;
  l_actual_rec          BIS_ACTUAL_PUB.Actual_Rec_Type;
  l_comparison_result   VARCHAR2(32000);

  l_return_status VARCHAR2(32000);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(32000);
  l_error_Tbl     BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_measure_instance_p    BIS_MEASURE_PUB.Measure_Instance_type;

BEGIN

  l_measure_instance := p_measure_instance;
  l_dim_level_value_tbl := p_dim_level_value_tbl;

  BIS_UTILITIES_PUB.put_line(p_text =>'Servicing planner request.');
  BIS_UTILITIES_PUB.put_line(p_text =>'Target level id: '||l_measure_instance.Target_level_id);

  /*
  BIS_UTILITIES_PUB.put_line(p_text =>'VGPLB:  org, id: '
  ||l_dim_level_value_tbl(1).dimension_level_short_name||' - '
  ||l_dim_level_value_tbl(1).dimension_level_value_id);

  BIS_UTILITIES_PUB.put_line(p_text =>'VGPLB:  time, id: '
  ||l_dim_level_value_tbl(2).dimension_level_short_name||' - '
  ||l_dim_level_value_tbl(2).dimension_level_value_id);

  BIS_UTILITIES_PUB.put_line(p_text =>'VGPLB:  dim1 id: '
  ||l_dim_level_value_tbl(3).dimension_level_short_name||' - '
  ||l_dim_level_value_tbl(3).dimension_level_value_id);

  BIS_UTILITIES_PUB.put_line(p_text =>'VGPLB:  dim2 id: '
  ||l_dim_level_value_tbl(4).dimension_level_short_name||' - '
  ||l_dim_level_value_tbl(4).dimension_level_value_id);
  */

  -- Retrieve Performance Target information
  --
  IF ((BIS_UTILITIES_PUB.Value_Missing(l_measure_instance.Target_level_id)
    = FND_API.G_TRUE)
  OR (BIS_UTILITIES_PUB.Value_Null(l_measure_instance.Target_level_id)
    = FND_API.G_TRUE))
  THEN
    BIS_PMF_DATA_SOURCE_PUB.Retrieve_Target_Level
    ( p_measure_instance       => l_measure_instance
    , p_dim_level_value_tbl    => l_dim_level_value_tbl
    , p_all_info   	       => FND_API.G_FALSE
    , x_target_level_rec       => l_target_level_rec
    );
    l_measure_instance_p := l_measure_instance;
		Sync_All_Fields
    ( p_measure_instance       => l_measure_instance_p
    , p_target_level_rec       => l_target_level_rec
    , p_target_rec	       => l_Target_Rec
    , p_target_owners_rec      => l_Target_Owners_Rec
    , p_actual_rec	       => l_Actual_Rec
    , x_measure_instance       => l_measure_instance
    );
    BIS_UTILITIES_PUB.put_line(p_text =>'Target level short name: '
    ||l_measure_instance.Target_Level_Short_Name);
  ELSE
    BIS_PMF_DATA_SOURCE_PVT.Form_Target_Level_rec
    ( p_measure_instance      => l_measure_instance
    , p_dim_level_value_tbl   => l_dim_level_value_tbl
    , x_target_level_rec      => l_Target_Level_Rec
    );
  END IF;

  -- Request target information
  --
  BIS_PMF_DATA_SOURCE_PUB.Retrieve_Target
  ( p_measure_instance       => l_measure_instance
  , p_dim_level_value_tbl    => l_dim_level_value_tbl
  , p_all_info               => FND_API.G_FALSE
  , x_target_rec             => l_target_rec
  );
  BIS_UTILITIES_PUB.put_line(p_text =>'Planner retrieved target: '||l_target_rec.target);

  -- Retrieve Performance Actual information
  --
  BIS_PMF_DATA_SOURCE_PUB.Retrieve_Actual
  ( p_measure_instance       => l_measure_instance
  , p_dim_level_value_tbl    => l_dim_level_value_tbl
  , p_all_info               => FND_API.G_FALSE
  , x_actual_rec             => l_actual_rec
  );
  BIS_UTILITIES_PUB.put_line(p_text =>'Planner retrieved actual: '||l_actual_rec.actual);

  -- post actual
  --
  IF (BIS_UTILITIES_PUB.Value_Not_Missing(l_actual_rec.Actual) = FND_API.G_TRUE)
  -- OR (BIS_UTILITIES_PUB.Value_Not_Null(l_actual_rec.Actual) = FND_API.G_TRUE))
  THEN
    BIS_ACTUAL_PUB.Post_Actual
    ( p_api_version       => 1.0
    , p_commit            => FND_API.G_TRUE
    , p_Actual_Rec        => l_actual_rec
    , x_return_status     => l_return_status
    , x_msg_count         => l_msg_count
    , x_msg_data          => l_msg_data
    , x_error_Tbl         => l_error_Tbl
    );
    BIS_UTILITIES_PUB.put_line(p_text =>'Actual posted: '||l_return_status);
  END IF;

  -- Comparison and notification
  --
  Compare_Values
  ( p_target_rec	 => l_Target_Rec
  , p_actual_rec	 => l_Actual_Rec
  , x_comparison_result  => l_comparison_result
  );
  BIS_UTILITIES_PUB.put_line(p_text =>'Target to actual comparison: out of range '||l_comparison_result);

  -- Assume Exception mode alert compare and notify Target owner
  -- when exceptions occur. No notification if result is normal.
  -- Start corrective action only if exception occured
  --
  IF l_comparison_result = G_COMP_RESULT_NORMAL
  THEN
    RETURN;
  ELSE
    BIS_PMF_DATA_SOURCE_PUB.Retrieve_Target_Owners
    ( p_measure_instance       => l_measure_instance
    , p_dim_level_value_tbl    => l_dim_level_value_tbl
    , p_all_info               => FND_API.G_FALSE
    , x_target_owners_rec      => l_Target_Owners_Rec
    );
    l_measure_instance_p := l_measure_instance;
		Sync_All_Fields
    ( p_measure_instance       => l_measure_instance_p
    , p_target_level_rec       => l_target_level_rec
    , p_target_rec	       => l_Target_Rec
    , p_target_owners_rec      => l_Target_Owners_Rec
    , p_actual_rec	       => l_Actual_Rec
    , x_measure_instance       => l_measure_instance
    );
    BIS_UTILITIES_PUB.put_line(p_text =>'Range 1 Owner: '||l_Target_Owners_Rec.Range1_Owner_Short_Name);
    BIS_UTILITIES_PUB.put_line(p_text =>'Range 2 Owner: '||l_Target_Owners_Rec.Range2_Owner_Short_Name);
    BIS_UTILITIES_PUB.put_line(p_text =>'Range 3 Owner: '||l_Target_Owners_Rec.Range3_Owner_Short_Name);

    BIS_CORRECTIVE_ACTION_PUB.Send_Alert
    ( p_measure_instance      => l_measure_instance
    , p_dim_level_value_tbl   => l_dim_level_value_tbl
    , p_comparison_result     => l_comparison_result
    );
  -- Following is an Incorrect Log. Please don't uncomment the following line

  --  BIS_UTILITIES_PUB.put_line(p_text =>'Send alert notification started');


    IF p_alert_type = BIS_PMF_REG_SERVICE_PVT.G_TARGET_LEVEL THEN
      BIS_CORRECTIVE_ACTION_PUB.Start_Corrective_Action
      ( p_measure_instance      => l_measure_instance
      , p_dim_level_value_tbl   => l_dim_level_value_tbl
      , p_comparison_result     => l_comparison_result
      );
      BIS_UTILITIES_PUB.put_line(p_text =>'Corrective action started');
    END IF;

  END IF;

  RETURN;
EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Service_planner_Request'
      );
      RETURN;
END Service_Planner_Request;

-- For future enhencements
-- Includes additional list of subscribers (enh. #1270301)
-- Public vs. private alerts (enh. #1270297)
--
Procedure Service_Planner_Request
( p_measure_instance      IN BIS_MEASURE_PUB.Measure_Instance_type
, p_dim_level_value_tbl	  IN BIS_DIM_LEVEL_VALUE_PUB.Dim_Level_Value_Tbl_Type
, P_notify_set	          IN VARCHAR2
, p_alert_type	          IN VARCHAR2
, p_alert_level	          IN VARCHAR2
)
IS

BEGIN

  null;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Service_Planner_Request'
      );
      RETURN;
END Service_Planner_Request;

Procedure Compare_Values
( p_target_rec		IN BIS_TARGET_PUB.Target_Rec_Type
, p_actual_rec		IN BIS_ACTUAL_PUB.Actual_Rec_Type
, x_comparison_result	OUT NOCOPY VARCHAR2
)
IS

  l_actual BISBV_ACTUALS.ACTUAL_VALUE%TYPE;
  l_target BISBV_TARGETS.TARGET%TYPE;
  l_range1_low  BISBV_TARGETS.RANGE1_LOW%TYPE;
  l_range1_high BISBV_TARGETS.RANGE1_HIGH%TYPE;
  l_range2_low  BISBV_TARGETS.RANGE2_LOW%TYPE;
  l_range2_high BISBV_TARGETS.RANGE2_HIGH%TYPE;
  l_range3_low  BISBV_TARGETS.RANGE3_LOW%TYPE;
  l_range3_high BISBV_TARGETS.RANGE3_HIGH%TYPE;
  l_comparison_result VARCHAR2(32000);

BEGIN

  l_actual := NVL(p_actual_rec.actual,0);
  l_target := NVL(p_target_rec.target,0);
  l_range1_low := p_target_rec.range1_low;
  l_range1_high := p_target_rec.range1_high;
  l_range2_low := p_target_rec.range2_low;
  l_range2_high := p_target_rec.range2_high;
  l_range3_low := p_target_rec.range3_low;
  l_range3_high := p_target_rec.range3_high;

  -- Compute the min, max value of tolerance ranges in percentages
  --
  l_range1_low  := l_target-((l_range1_low/100)*l_target);
  l_range1_high := l_target+((l_range1_high/100)*l_target);
  l_range2_low  := l_target-((l_range2_low/100)*l_target);
  l_range2_high := l_target+((l_range2_high/100)*l_target);
  l_range3_low  := l_target-((l_range3_low/100)*l_target);
  l_range3_high := l_target+((l_range3_high/100)*l_target);

  BIS_UTILITIES_PUB.put_line(p_text =>'Comparing values.');
  BIS_UTILITIES_PUB.put_line(p_text =>'Actual: '||l_actual||', Target: '||l_target);
  BIS_UTILITIES_PUB.put_line(p_text =>'Range 1 low: '||l_range1_low||', high: '||l_range1_high);
  BIS_UTILITIES_PUB.put_line(p_text =>'Range 2 low: '||l_range2_low||', high: '||l_range2_high);
  BIS_UTILITIES_PUB.put_line(p_text =>'Range 3 low: '||l_range3_low||', high: '||l_range3_high);

  -- Check if actual not equal to target
  --
  IF (l_actual <> l_target)
  THEN

    -- Check if actual is within the first range
    --
    IF (l_range1_low IS NOT NULL OR l_range1_high IS NOT NULL)
    AND (l_actual NOT BETWEEN
      NVL(l_range1_low,l_target) AND NVL(l_range1_High,l_target))
    AND (l_actual BETWEEN
        NVL(l_range2_low,l_actual) AND NVL(l_range2_High,l_actual))
    THEN
      l_comparison_result := G_COMP_RESULT_OUT_OF_RANGE1;
    -- Check if actual is within the second range
    --
    ELSIF (l_range2_low IS NOT NULL OR l_range2_high IS NOT NULL)
    AND (l_actual NOT BETWEEN
           NVL(l_range2_low,l_target) AND NVL(l_range2_High,l_target))
    AND (l_actual BETWEEN
           NVL(l_range3_low,l_actual) AND NVL(l_range3_High,l_actual))
    THEN
      l_comparison_result := G_COMP_RESULT_OUT_OF_RANGE2;

    -- Check if actual is within the third range
    --
    ELSIF (l_range3_low IS NOT NULL OR l_range3_high IS NOT NULL)
    AND  (l_actual NOT BETWEEN
          NVL(l_range3_low,l_target) AND NVL(l_range3_High,l_target))
    THEN
      l_comparison_result := G_COMP_RESULT_OUT_OF_RANGE3;

    ELSE
      -- within range
      --
      l_comparison_result := G_COMP_RESULT_NORMAL;
    END IF;
  ELSE
    -- actual match target.  send congratulation message
    -- (enh # )
    l_comparison_result := G_COMP_RESULT_NORMAL;
  END IF;

  x_comparison_result := l_comparison_result;

EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETURN;
   when others then
      BIS_UTILITIES_PVT.Add_Error_Message
      ( p_error_msg_id      => SQLCODE
      , p_error_description => SQLERRM
      , p_error_proc_name   => G_PKG_NAME||'.Compare_Values'
      );
      RETURN;

END Compare_Values;

Procedure Sync_All_Fields
( p_measure_instance       IN BIS_MEASURE_PUB.Measure_Instance_type
, p_target_level_rec       IN BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type
, p_target_rec	           IN BIS_TARGET_PUB.Target_Rec_Type
, p_target_owners_rec      IN BIS_TARGET_PUB.Target_Owners_Rec_Type
, p_actual_rec	           IN BIS_ACTUAL_PUB.Actual_Rec_Type
, x_measure_instance       IN OUT NOCOPY BIS_MEASURE_PUB.Measure_Instance_type
)
IS

  l_measure_instance    BIS_MEASURE_PUB.Measure_Instance_type;
  l_measure_instance_p  BIS_MEASURE_PUB.Measure_Instance_type;

BEGIN

  l_measure_instance := p_measure_instance;

  l_measure_instance.Measure_ID := p_target_level_rec.Measure_ID;
  l_measure_instance.Measure_Short_Name
    := p_target_level_rec.Measure_Short_Name;
  l_measure_instance.Measure_Name := p_target_level_rec.Measure_Name;

  l_measure_instance.Target_Level_ID := p_target_level_rec.Target_Level_ID;
  l_measure_instance.Target_Level_Short_Name
    := p_target_level_rec.Target_Level_Short_name;
  l_measure_instance.Target_Level_Name
    := p_target_level_rec.Target_Level_Name;

  l_measure_instance.plan_id := p_target_rec.plan_id  ;
  l_measure_instance.plan_short_name := p_target_rec.plan_short_name;
  l_measure_instance.plan_name := p_target_rec.plan_name;

  l_measure_instance.Actual := p_actual_rec.actual;

  l_measure_instance.Target_id   := p_target_rec.target_id  ;
  l_measure_instance.Target      := p_target_rec.target     ;
  l_measure_instance.range1_low  := p_target_rec.range1_low ;
  l_measure_instance.range1_high := p_target_rec.range1_high;
  l_measure_instance.range2_low  := p_target_rec.range2_low ;
  l_measure_instance.range2_high := p_target_rec.range2_high;
  l_measure_instance.range3_low  := p_target_rec.range3_low ;
  l_measure_instance.range3_high := p_target_rec.range3_high;
  l_measure_instance_p := l_measure_instance;
  BIS_PMF_DATA_SOURCE_PVT.Sync_Target_Measure_Owners
  ( p_measure_instance      => l_measure_instance_p
  , p_Target_owners_rec     => p_Target_owners_rec
  , x_measure_instance      => l_measure_instance
  );

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
      , p_error_proc_name   => G_PKG_NAME||'.Sync_All_Fields'
      );
      RETURN;

END Sync_All_Fields;


END BIS_GENERIC_PLANNER_PVT;

/
