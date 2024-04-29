--------------------------------------------------------
--  DDL for Package Body BSC_KPI_COLOR_PROPERTIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_COLOR_PROPERTIES_PUB" AS
/* $Header: BSCPKCPB.pls 120.2.12000000.1 2007/07/17 07:44:02 appldev noship $ */


/************************************************************************************
 ************************************************************************************/

PROCEDURE Update_Kpi_Color_Properties (
  p_commit              IN              VARCHAR2 := FND_API.G_FALSE
, p_objective_id	IN		BSC_KPIS_B.indicator%TYPE
, p_kpi_measure_id      IN      	BSC_KPI_ANALYSIS_MEASURES_B.kpi_measure_id%TYPE
, p_disable_color	IN		BSC_KPI_MEASURE_PROPS.disable_color%TYPE
, p_kpi_prototype_color	IN		BSC_KPI_MEASURE_PROPS.prototype_color_id%TYPE
, p_kpi_prototype_trend	IN		BSC_KPI_MEASURE_PROPS.prototype_trend_id%TYPE
, p_color_by_total	IN		BSC_KPI_MEASURE_PROPS.color_by_total%TYPE
, p_disable_trend	IN		BSC_KPI_MEASURE_PROPS.disable_trend%TYPE
, p_need_color_recalc	IN		VARCHAR2 := 'N'
, x_return_status       OUT NOCOPY     	VARCHAR2
, x_msg_count           OUT NOCOPY     	NUMBER
, x_msg_data            OUT NOCOPY     	VARCHAR2
)
IS
  l_kpi_measure_rec BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec;
  l_obj_prototype_flag BSC_KPIS_B.prototype_flag%TYPE;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Any Business Logic Validation

  BSC_KPI_MEASURE_PROPS_PUB.Retrieve_Kpi_Measure_Props
  ( p_objective_id     => p_objective_id
  , p_kpi_measure_id   => p_kpi_measure_id
  , x_kpi_measure_rec  => l_kpi_measure_rec
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  l_kpi_measure_rec.disable_color := p_disable_color;
  l_kpi_measure_rec.disable_trend := p_disable_trend;
  l_kpi_measure_rec.prototype_color := p_kpi_prototype_color;
  l_kpi_measure_rec.prototype_trend := p_kpi_prototype_trend;
  l_kpi_measure_rec.color_by_total := p_color_by_total;

  BSC_KPI_MEASURE_PROPS_PUB.Update_Kpi_Measure_Props
  ( p_commit           => p_commit
  , p_kpi_measure_rec  => l_kpi_measure_rec
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF (p_need_color_recalc = 'Y') THEN

    Change_Prototype_Flag
    ( p_objective_id   => p_objective_id
    , p_kpi_measure_id => p_kpi_measure_id
    , p_prototype_flag => 7
    , x_return_status  => x_return_status
    , x_msg_count      => x_msg_count
    , x_msg_data       => x_msg_data
    );


  END IF;



EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Update_Kpi_Color_Properties ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Update_Kpi_Color_Properties ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Update_Kpi_Color_Properties ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Update_Kpi_Color_Properties ';
    END IF;

END Update_Kpi_Color_Properties;



/************************************************************************************
 ************************************************************************************/

PROCEDURE Update_Obj_Color_Properties (
  p_commit              	IN              VARCHAR2 := FND_API.G_FALSE
, p_objective_id		IN		BSC_KPIS_B.indicator%TYPE
, p_obj_prototype_color_id	IN		BSC_KPIS_B.prototype_color_id%TYPE
, p_obj_prototype_trend_id	IN		BSC_KPIS_B.prototype_trend_id%TYPE
, p_color_rollup_type		IN		BSC_KPIS_B.color_rollup_type%TYPE
, p_weighted_color_method	IN		BSC_KPIS_B.weighted_color_method%TYPE
, p_need_color_recalc		IN		VARCHAR2 := 'Y'
, x_return_status       	OUT NOCOPY     	VARCHAR2
, x_msg_count           	OUT NOCOPY     	NUMBER
, x_msg_data            	OUT NOCOPY     	VARCHAR2
)
IS
  l_objective_rec BSC_KPI_PUB.Bsc_Kpi_Entity_Rec;

  CURSOR c_shared_obj(p_indicator NUMBER) IS
    SELECT indicator
    FROM   bsc_kpis_b
    WHERE  source_indicator = p_indicator
    AND    share_flag = 2 -- shared objective.
    AND    prototype_flag <> 2;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Any Business Logic Validation

  l_objective_rec.Bsc_Kpi_Id := p_objective_id;

  IF (p_obj_prototype_color_id IS NOT NULL) THEN
    l_objective_rec.Bsc_Prototype_Color_Id := p_obj_prototype_color_id;
  END IF;

  IF (p_obj_prototype_trend_id IS NOT NULL) THEN
    l_objective_rec.Bsc_Prototype_Trend_Id := p_obj_prototype_trend_id;
  END IF;

  IF (p_color_rollup_type IS NOT NULL) THEN
    l_objective_rec.Bsc_Color_Rollup_Type := p_color_rollup_type;
  END IF;

  IF (p_weighted_color_method IS NOT NULL) THEN
    l_objective_rec.Bsc_Weighted_Color_Method := p_weighted_color_method;
  END IF;


  BSC_KPI_PVT.Update_Kpi
  ( p_commit               => p_commit
  , p_Bsc_Kpi_Entity_Rec   => l_objective_rec
  , x_return_status        => x_return_status
  , x_msg_count            => x_msg_count
  , x_msg_data             => x_msg_data
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  FOR c_shared IN c_shared_obj(p_objective_id) LOOP
    l_objective_rec.Bsc_Kpi_Id := c_shared.indicator;
    BSC_KPI_PVT.Update_Kpi
    ( p_commit               => p_commit
    , p_Bsc_Kpi_Entity_Rec   => l_objective_rec
    , x_return_status        => x_return_status
    , x_msg_count            => x_msg_count
    , x_msg_data             => x_msg_data
    );
  END LOOP;


  IF (p_need_color_recalc = 'Y') THEN

    Obj_Prototype_Flag_Change
    ( p_objective_id   => p_objective_id
    , p_prototype_flag => 7
    , x_return_status  => x_return_status
    , x_msg_count      => x_msg_count
    , x_msg_data       => x_msg_data
    );


  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Update_Obj_Color_Properties ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Update_Obj_Color_Properties ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Update_Obj_Color_Properties ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Update_Obj_Color_Properties ';
    END IF;


END Update_Obj_Color_Properties;



/************************************************************************************
 ************************************************************************************/

PROCEDURE Create_Update_Kpi_Mes_Weights (
  p_commit              IN              VARCHAR2 := FND_API.G_FALSE
, p_objective_id	IN		BSC_KPIS_B.indicator%TYPE
, p_kpi_measure_id      IN      	BSC_KPI_ANALYSIS_MEASURES_B.kpi_measure_id%TYPE
, p_kpi_weight		IN		BSC_KPI_MEASURE_WEIGHTS.weight%TYPE
, x_return_status       OUT NOCOPY     	VARCHAR2
, x_msg_count           OUT NOCOPY     	NUMBER
, x_msg_data            OUT NOCOPY     	VARCHAR2
)
IS
  l_kpi_measure_weights_rec BSC_KPI_MEASURE_WEIGHTS_PUB.kpi_measure_weights_rec;
  l_num VARCHAR(2);
  l_obj_prototype_flag BSC_KPIS_B.prototype_flag%TYPE;
  l_color_rollup_type BSC_KPIS_B.color_rollup_type%TYPE;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Any Business Logic Validation

  l_kpi_measure_weights_rec.objective_id := p_objective_id;
  l_kpi_measure_weights_rec.kpi_measure_id := p_kpi_measure_id;
  l_kpi_measure_weights_rec.weight := p_kpi_weight;

  SELECT count(1) INTO l_num FROM bsc_kpi_measure_weights WHERE indicator = p_objective_id AND kpi_measure_id = p_kpi_measure_id;

  IF (l_num = 0) THEN

    BSC_KPI_MEASURE_WEIGHTS_PUB.Create_Kpi_Measure_Weights
    ( p_commit               	  => p_commit
    , p_kpi_measure_weights_rec   => l_kpi_measure_weights_rec
    , p_cascade_shared		  => TRUE
    , x_return_status        	  => x_return_status
    , x_msg_count           	  => x_msg_count
    , x_msg_data             	  => x_msg_data
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

  ELSE

    BSC_KPI_MEASURE_WEIGHTS_PUB.Update_Kpi_Measure_Weights
    ( p_commit               	  => p_commit
    , p_kpi_measure_weights_rec   => l_kpi_measure_weights_rec
    , p_cascade_shared		  => TRUE
    , x_return_status        	  => x_return_status
    , x_msg_count           	  => x_msg_count
    , x_msg_data             	  => x_msg_data
    );

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  /*SELECT prototype_flag INTO l_obj_prototype_flag
  FROM bsc_kpis_b
  WHERE indicator = p_objective_id;*/

  SELECT bk.color_rollup_type, bk.prototype_flag
  INTO   l_color_rollup_type, l_obj_prototype_flag
  FROM bsc_db_color_ao_defaults_v dd, bsc_kpi_analysis_measures_vl km, bsc_kpis_b bk
  WHERE km.indicator = p_objective_id AND
        bk.indicator = km.indicator AND
        km.indicator = dd.indicator AND
        dd.a0_default = km.analysis_option0 AND
        dd.a1_default = km.analysis_option1 AND
        dd.a2_default = km.analysis_option2 AND
        km.default_value = 1;

  IF (l_obj_prototype_flag <> 2 AND l_obj_prototype_flag <> 7
      AND l_color_rollup_type = BSC_COLOR_CALC_UTIL.WEIGHTED_AVERAGE) THEN

    Obj_Prototype_Flag_Change
    ( p_objective_id   => p_objective_id
    , p_prototype_flag => 7
    , x_return_status  => x_return_status
    , x_msg_count      => x_msg_count
    , x_msg_data       => x_msg_data
    );

    END IF;



EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Create_Update_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Create_Update_Kpi_Measure_Weights ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Create_Update_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Create_Update_Kpi_Measure_Weights ';
    END IF;

END Create_Update_Kpi_Mes_Weights;


/************************************************************************************
 ************************************************************************************/

PROCEDURE Obj_Prototype_Flag_Change (
  p_objective_id	IN		BSC_KPIS_B.indicator%TYPE
, p_prototype_flag      IN      	NUMBER
, x_return_status       OUT NOCOPY     	VARCHAR2
, x_msg_count           OUT NOCOPY     	NUMBER
, x_msg_data            OUT NOCOPY     	VARCHAR2
)
IS

  CURSOR c_shared_obj(p_indicator NUMBER) IS
    SELECT indicator
    FROM   bsc_kpis_b
    WHERE  source_indicator = p_indicator
    AND    share_flag = 2 -- shared objective.
    AND    prototype_flag <> 2;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Any Business Logic Validation

    BSC_DESIGNER_PVT.ActionFlag_Change_Cascade
    ( p_indicator     => p_objective_id
    , p_newflag       => p_prototype_flag
    , p_cascade_color => FALSE
    );


    FOR c_shared IN c_shared_obj(p_objective_id) LOOP
      BSC_DESIGNER_PVT.ActionFlag_Change_Cascade
      ( p_indicator     => c_shared.indicator
      , p_newflag       => p_prototype_flag
      , p_cascade_color => FALSE
      );
    END LOOP;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Obj_Prototype_Flag_Change ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Obj_Prototype_Flag_Change ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Obj_Prototype_Flag_Change ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Obj_Prototype_Flag_Change ';
    END IF;

END Obj_Prototype_Flag_Change;


/************************************************************************************
 ************************************************************************************/

PROCEDURE Kpi_Prototype_Flag_Change (
  p_objective_id	IN		BSC_KPIS_B.indicator%TYPE
, p_kpi_measure_id      IN      	BSC_KPI_ANALYSIS_MEASURES_B.kpi_measure_id%TYPE
, p_prototype_flag      IN      	NUMBER
, x_return_status       OUT NOCOPY     	VARCHAR2
, x_msg_count           OUT NOCOPY     	NUMBER
, x_msg_data            OUT NOCOPY     	VARCHAR2
)
IS
  l_kpi_measure_id NUMBER;

  CURSOR c_shared_obj(p_indicator NUMBER) IS
    SELECT indicator
    FROM   bsc_kpis_b
    WHERE  source_indicator = p_indicator
    AND    share_flag = 2 -- shared objective.
    AND    prototype_flag <> 2;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Any Business Logic Validation

  BSC_DESIGNER_PVT.Update_Kpi_Prototype_Flag
  ( p_objective_id   => p_objective_id
  , p_kpi_measure_id => p_kpi_measure_id
  , p_flag           => p_prototype_flag
  );

  FOR c_shared IN c_shared_obj(p_objective_id) LOOP

    l_kpi_measure_id := BSC_KPI_MEASURE_PROPS_PUB.get_shared_obj_kpi_measure
                        ( p_objective_id         => p_objective_id
                        , p_kpi_measure_id       => p_kpi_measure_id
                        , p_shared_objective_id  => c_shared.indicator
                        );

    IF l_kpi_measure_id IS NULL THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;

    BSC_DESIGNER_PVT.Update_Kpi_Prototype_Flag
    ( p_objective_id   => c_shared.indicator
    , p_kpi_measure_id => l_kpi_measure_id
    , p_flag           => p_prototype_flag
    );


  END LOOP;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Kpi_Prototype_Flag_Change ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Kpi_Prototype_Flag_Change ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Kpi_Prototype_Flag_Change ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Kpi_Prototype_Flag_Change ';
    END IF;

END Kpi_Prototype_Flag_Change;


/************************************************************************************
 ************************************************************************************/

PROCEDURE Change_Prototype_Flag (
  p_objective_id        IN		BSC_KPIS_B.indicator%TYPE
, p_kpi_measure_id      IN      	BSC_KPI_ANALYSIS_MEASURES_B.kpi_measure_id%TYPE
, p_prototype_flag      IN      	NUMBER
, x_return_status       OUT NOCOPY     	VARCHAR2
, x_msg_count           OUT NOCOPY     	NUMBER
, x_msg_data            OUT NOCOPY     	VARCHAR2
)
IS
  l_obj_prototype_flag BSC_KPIS_B.prototype_flag%TYPE;
  l_color_rollup_type BSC_KPIS_B.color_rollup_type%TYPE;
  l_def_kpi_measure_id BSC_KPI_ANALYSIS_MEASURES_VL.kpi_measure_id%TYPE;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Any Business Logic Validation

  Kpi_Prototype_Flag_Change
  ( p_objective_id   => p_objective_id
  , p_kpi_measure_id => p_kpi_measure_id
  , p_prototype_flag => p_prototype_flag
  , x_return_status  => x_return_status
  , x_msg_count      => x_msg_count
  , x_msg_data       => x_msg_data
  );

  /*SELECT prototype_flag INTO l_obj_prototype_flag
  FROM bsc_kpis_b
  WHERE indicator = p_objective_id;*/

  SELECT bk.color_rollup_type, km.kpi_measure_id, bk.prototype_flag
  INTO   l_color_rollup_type, l_def_kpi_measure_id, l_obj_prototype_flag
  FROM bsc_db_color_ao_defaults_v dd, bsc_kpi_analysis_measures_vl km, bsc_kpis_b bk
  WHERE km.indicator = p_objective_id AND
        bk.indicator = km.indicator AND
        km.indicator = dd.indicator AND
        dd.a0_default = km.analysis_option0 AND
        dd.a1_default = km.analysis_option1 AND
        dd.a2_default = km.analysis_option2 AND
        km.default_value = 1;

  IF (l_obj_prototype_flag <> 2 AND
      l_obj_prototype_flag <> p_prototype_flag AND
      ((l_color_rollup_type = BSC_COLOR_CALC_UTIL.DEFAULT_KPI AND l_def_kpi_measure_id = p_kpi_measure_id)
            OR (l_color_rollup_type <> BSC_COLOR_CALC_UTIL.DEFAULT_KPI))) THEN

    Obj_Prototype_Flag_Change
    ( p_objective_id   => p_objective_id
    , p_prototype_flag => p_prototype_flag
    , x_return_status  => x_return_status
    , x_msg_count      => x_msg_count
    , x_msg_data       => x_msg_data
    );

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Obj_Prototype_Flag_Change ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Obj_Prototype_Flag_Change ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Obj_Prototype_Flag_Change ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Obj_Prototype_Flag_Change ';
    END IF;

END Change_Prototype_Flag;


/************************************************************************************
 ************************************************************************************/

PROCEDURE Save_Disable_Color_Of_Kpi (
  p_commit              IN              VARCHAR2 := FND_API.G_FALSE
, p_objective_id	IN		BSC_KPIS_B.indicator%TYPE
, p_kpi_measure_id      IN      	BSC_KPI_ANALYSIS_MEASURES_B.kpi_measure_id%TYPE
, p_disable_color	IN		BSC_KPI_MEASURE_PROPS.disable_color%TYPE
, p_need_color_recalc	IN		VARCHAR2 := 'N'
, x_return_status       OUT NOCOPY     	VARCHAR2
, x_msg_count           OUT NOCOPY     	NUMBER
, x_msg_data            OUT NOCOPY     	VARCHAR2
)
IS
  l_kpi_measure_rec BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec;
  l_obj_prototype_flag BSC_KPIS_B.prototype_flag%TYPE;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Any Business Logic Validation

  BSC_KPI_MEASURE_PROPS_PUB.Retrieve_Kpi_Measure_Props
  ( p_objective_id     => p_objective_id
  , p_kpi_measure_id   => p_kpi_measure_id
  , x_kpi_measure_rec  => l_kpi_measure_rec
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  l_kpi_measure_rec.disable_color := p_disable_color;

  BSC_KPI_MEASURE_PROPS_PUB.Update_Kpi_Measure_Props
  ( p_commit           => p_commit
  , p_kpi_measure_rec  => l_kpi_measure_rec
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF (p_need_color_recalc = 'Y') THEN

    Change_Prototype_Flag
    ( p_objective_id   => p_objective_id
    , p_kpi_measure_id => p_kpi_measure_id
    , p_prototype_flag => 7
    , x_return_status  => x_return_status
    , x_msg_count      => x_msg_count
    , x_msg_data       => x_msg_data
    );


  END IF;



EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Save_Disable_Color_Of_Kpi ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Save_Disable_Color_Of_Kpi ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_COLOR_PROPERTIES_PUB.Save_Disable_Color_Of_Kpi ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_COLOR_PROPERTIES_PUB.Save_Disable_Color_Of_Kpi ';
    END IF;

END Save_Disable_Color_Of_Kpi;


END BSC_KPI_COLOR_PROPERTIES_PUB;

/
