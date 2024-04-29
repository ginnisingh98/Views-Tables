--------------------------------------------------------
--  DDL for Package Body BSC_KPI_MEASURE_PROPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_MEASURE_PROPS_PUB" AS
/* $Header: BSCPKMPB.pls 120.3 2008/04/24 06:34:34 bijain noship $ */


FUNCTION get_shared_obj_kpi_measure (
  p_objective_id         IN NUMBER
, p_kpi_measure_id       IN NUMBER
, p_shared_objective_id  IN NUMBER
) RETURN NUMBER
IS
  CURSOR c_analysis_option_comb(p_indicator NUMBER, p_kpi_measure_id NUMBER) IS
    SELECT analysis_option0, analysis_option1, analysis_option2, series_id
    FROM   bsc_kpi_analysis_measures_b
    WHERE  indicator = p_indicator
    AND    kpi_measure_id = p_kpi_measure_id;
  c_analysis_option_comb_rec  c_analysis_option_comb%ROWTYPE;

  CURSOR c_kpi_measure_id(p_indicator NUMBER, p_analysis_option0 NUMBER,
                          p_analysis_option1 NUMBER, p_analysis_option2 NUMBER, p_series_id NUMBER) IS
    SELECT kpi_measure_id
    FROM   bsc_kpi_analysis_measures_b
    WHERE  indicator = p_indicator
    AND    analysis_option0 = p_analysis_option0
    AND    analysis_option1 = p_analysis_option1
    AND    analysis_option2 = p_analysis_option2
    AND    series_id = p_series_id;

  l_kpi_measure_id   NUMBER;

BEGIN
  l_kpi_measure_id := NULL;

  IF p_objective_id IS NOT NULL AND p_kpi_measure_id IS NOT NULL AND p_shared_objective_id IS NOT NULL THEN

    IF c_analysis_option_comb%ISOPEN THEN
      CLOSE c_analysis_option_comb;
    END IF;
    OPEN c_analysis_option_comb(p_objective_id, p_kpi_measure_id);
    FETCH c_analysis_option_comb INTO c_analysis_option_comb_rec;
    IF c_analysis_option_comb%NOTFOUND THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_analysis_option_comb;

    IF c_kpi_measure_id%ISOPEN THEN
      CLOSE c_kpi_measure_id;
    END IF;
    OPEN c_kpi_measure_id(p_shared_objective_id,
                          c_analysis_option_comb_rec.analysis_option0,
                          c_analysis_option_comb_rec.analysis_option1,
                          c_analysis_option_comb_rec.analysis_option2,
                          c_analysis_option_comb_rec.series_id);
    FETCH c_kpi_measure_id INTO l_kpi_measure_id;
    IF c_kpi_measure_id%NOTFOUND THEN
      RAISE  FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_kpi_measure_id;

    RETURN l_kpi_measure_id;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF c_analysis_option_comb%ISOPEN THEN
      CLOSE c_analysis_option_comb;
    END IF;
    IF c_kpi_measure_id%ISOPEN THEN
      CLOSE c_kpi_measure_id;
    END IF;
    RETURN NULL;
END get_shared_obj_kpi_measure;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Kpi_Measure_Props (
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_rec     IN            BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec
, p_cascade_shared      IN            BOOLEAN := TRUE
, x_return_status       OUT NOCOPY    VARCHAR2
, x_msg_count           OUT NOCOPY    NUMBER
, x_msg_data            OUT NOCOPY    VARCHAR2
)
IS
  CURSOR c_shared_obj(p_indicator NUMBER) IS
    SELECT indicator
    FROM   bsc_kpis_b
    WHERE  source_indicator = p_indicator
    AND    share_flag = 2 -- shared objective.
    AND    prototype_flag <> 2;

  l_kpi_measure_rec  BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec;
  l_kpi_measure_id   NUMBER;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscKpiMeasurePub_Create;

  -- Any Business Logic Validation

  BSC_KPI_MEASURE_PROPS_PVT.Create_Kpi_Measure_Props
  ( p_commit           => p_commit
  , p_kpi_measure_rec  => p_kpi_measure_rec
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF p_cascade_shared THEN
    FOR c_shared IN c_shared_obj(p_kpi_measure_rec.objective_id) LOOP

      l_kpi_measure_id := get_shared_obj_kpi_measure
                          ( p_objective_id         => p_kpi_measure_rec.objective_id
                          , p_kpi_measure_id       => p_kpi_measure_rec.kpi_measure_id
                          , p_shared_objective_id  => c_shared.indicator
                          );
      IF l_kpi_measure_id IS NULL THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

      l_kpi_measure_rec := p_kpi_measure_rec;
      l_kpi_measure_rec.objective_id := c_shared.indicator;
      l_kpi_measure_rec.kpi_measure_id := l_kpi_measure_id;

      BSC_KPI_MEASURE_PROPS_PVT.Create_Kpi_Measure_Props
      ( p_commit           => p_commit
      , p_kpi_measure_rec  => l_kpi_measure_rec
      , x_return_status    => x_return_status
      , x_msg_count        => x_msg_count
      , x_msg_data         => x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasurePub_Create;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasurePub_Create;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasurePub_Create;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PUB.Create_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PUB.Create_Kpi_Measure_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasurePub_Create;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PUB.Create_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PUB.Create_Kpi_Measure_Props ';
    END IF;
END Create_Kpi_Measure_Props;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Default_Kpi_Meas_Props (
  p_commit          IN            VARCHAR2 := FND_API.G_FALSE
, p_objective_id    IN            NUMBER
, p_kpi_measure_id  IN            NUMBER
, p_cascade_shared  IN            BOOLEAN := TRUE
, x_return_status   OUT NOCOPY    VARCHAR2
, x_msg_count       OUT NOCOPY    NUMBER
, x_msg_data        OUT NOCOPY    VARCHAR2
)
IS
  CURSOR c_shared_obj(p_indicator NUMBER) IS
    SELECT indicator
    FROM   bsc_kpis_b
    WHERE  source_indicator = p_indicator
    AND    share_flag = 2 -- shared objective.
    AND    prototype_flag <> 2;

  l_kpi_measure_rec  BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec;
  l_kpi_measure_id   NUMBER;
  l_short_name       VARCHAR2(30);
  l_config_type      BSC_KPIS_B.CONFIG_TYPE%TYPE;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscKpiMeasurePub_CreateDef;

  l_kpi_measure_rec.objective_id        := p_objective_id;
  l_kpi_measure_rec.kpi_measure_id      := p_kpi_measure_id;
  l_kpi_measure_rec.prototype_color     := BSC_COLOR_REPOSITORY.EXCELLENT_COLOR;
  l_kpi_measure_rec.prototype_trend     := C_TREND_UNACC_DECREASE;
  l_kpi_measure_rec.color_by_total      := 1;
  l_kpi_measure_rec.disable_color       := 'F';
  l_kpi_measure_rec.disable_trend       := 'F';
  l_kpi_measure_rec.apply_color_flag    := 1;
  l_kpi_measure_rec.default_calculation := NULL;
  l_kpi_measure_rec.created_by          := FND_GLOBAL.USER_ID;
  l_kpi_measure_rec.creation_date       := SYSDATE;
  l_kpi_measure_rec.last_updated_by     := FND_GLOBAL.USER_ID;
  l_kpi_measure_rec.last_update_date    := SYSDATE;
  l_kpi_measure_rec.last_update_login   := FND_GLOBAL.LOGIN_ID;

  BEGIN
    SELECT short_name,config_type into l_short_name,l_config_type
    FROM bsc_kpis_b
    WHERE indicator = p_objective_id;
  EXCEPTION
    WHEN OTHERS THEN
      l_short_name := NULL;
  END;

  IF l_short_name IS NOT NULL AND l_config_type <> 7 THEN
    l_kpi_measure_rec.disable_color       := 'T';
    l_kpi_measure_rec.disable_trend       := 'T';
  END IF;

  BSC_KPI_MEASURE_PROPS_PVT.Create_Kpi_Measure_Props
  ( p_commit           => p_commit
  , p_kpi_measure_rec  => l_kpi_measure_rec
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF p_cascade_shared THEN
    FOR c_shared IN c_shared_obj(l_kpi_measure_rec.objective_id) LOOP

      l_kpi_measure_id := get_shared_obj_kpi_measure
                          ( p_objective_id         => l_kpi_measure_rec.objective_id
                          , p_kpi_measure_id       => l_kpi_measure_rec.kpi_measure_id
                          , p_shared_objective_id  => c_shared.indicator
                          );
      IF l_kpi_measure_id IS NULL THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

      --l_kpi_measure_rec := p_kpi_measure_rec;
      l_kpi_measure_rec.objective_id := c_shared.indicator;
      l_kpi_measure_rec.kpi_measure_id := l_kpi_measure_id;

      BSC_KPI_MEASURE_PROPS_PVT.Create_Kpi_Measure_Props
      ( p_commit           => p_commit
      , p_kpi_measure_rec  => l_kpi_measure_rec
      , x_return_status    => x_return_status
      , x_msg_count        => x_msg_count
      , x_msg_data         => x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasurePub_CreateDef;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasurePub_CreateDef;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasurePub_CreateDef;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PUB.Create_Default_Kpi_Meas_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PUB.Create_Default_Kpi_Meas_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasurePub_CreateDef;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PUB.Create_Default_Kpi_Meas_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PUB.Create_Default_Kpi_Meas_Props ';
    END IF;
END Create_Default_Kpi_Meas_Props;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Update_Kpi_Measure_Props (
  p_commit              IN             VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_rec     IN             BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec
, p_cascade_shared      IN             BOOLEAN := TRUE
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
)
IS
  CURSOR c_shared_obj(p_indicator NUMBER) IS
    SELECT indicator
    FROM   bsc_kpis_b
    WHERE  source_indicator = p_indicator
    AND    share_flag = 2 -- shared objective.
    AND    prototype_flag <> 2;

  l_kpi_measure_rec  BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec;
  l_kpi_measure_id   NUMBER;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscKpiMeasurePub_Update;

  -- Any Business Logic Validation

  BSC_KPI_MEASURE_PROPS_PVT.Update_Kpi_Measure_Props
  ( p_commit           => p_commit
  , p_kpi_measure_rec  => p_kpi_measure_rec
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF p_cascade_shared THEN
    FOR c_shared IN c_shared_obj(p_kpi_measure_rec.objective_id) LOOP

      l_kpi_measure_id := get_shared_obj_kpi_measure
                          ( p_objective_id         => p_kpi_measure_rec.objective_id
                          , p_kpi_measure_id       => p_kpi_measure_rec.kpi_measure_id
                          , p_shared_objective_id  => c_shared.indicator
                          );
      IF l_kpi_measure_id IS NULL THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

      l_kpi_measure_rec := p_kpi_measure_rec;
      l_kpi_measure_rec.objective_id := c_shared.indicator;
      l_kpi_measure_rec.kpi_measure_id := l_kpi_measure_id;

      BSC_KPI_MEASURE_PROPS_PVT.Update_Kpi_Measure_Props
      ( p_commit           => p_commit
      , p_kpi_measure_rec  => l_kpi_measure_rec
      , x_return_status    => x_return_status
      , x_msg_count        => x_msg_count
      , x_msg_data         => x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasurePub_Update;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasurePub_Update;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasurePub_Update;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PUB.Update_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PUB.Update_Kpi_Measure_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasurePub_Update;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PUB.Update_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PUB.Update_Kpi_Measure_Props ';
    END IF;
END Update_Kpi_Measure_Props;

/************************************************************************************
************************************************************************************/
PROCEDURE Delete_Kpi_Measure_Props (
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
, p_objective_id        IN             NUMBER
, p_kpi_measure_id      IN             NUMBER
, p_cascade_shared      IN             BOOLEAN := TRUE
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
)
IS
  CURSOR c_shared_obj(p_indicator NUMBER) IS
    SELECT indicator
    FROM   bsc_kpis_b
    WHERE  source_indicator = p_indicator
    AND    share_flag = 2 -- shared objective.
    AND    prototype_flag <> 2;

  l_kpi_measure_id   NUMBER;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscKpiMeasurePub_Delete;

  -- Any Business Logic Validation

  BSC_KPI_MEASURE_PROPS_PVT.Delete_Kpi_Measure_Props
  ( p_commit           => p_commit
  , p_objective_id     => p_objective_id
  , p_kpi_measure_id   => p_kpi_measure_id
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF p_cascade_shared THEN

    FOR c_shared IN c_shared_obj(p_objective_id) LOOP

      l_kpi_measure_id := get_shared_obj_kpi_measure
                        ( p_objective_id         => p_objective_id
                        , p_kpi_measure_id       => p_kpi_measure_id
                        , p_shared_objective_id  => c_shared.indicator
                        );
      IF l_kpi_measure_id IS NULL THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

      BSC_KPI_MEASURE_PROPS_PVT.Delete_Kpi_Measure_Props
      ( p_commit           => p_commit
      , p_objective_id     => c_shared.indicator
      , p_kpi_measure_id   => l_kpi_measure_id
      , x_return_status    => x_return_status
      , x_msg_count        => x_msg_count
      , x_msg_data         => x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasurePub_Delete;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasurePub_Delete;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasurePub_Delete;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PUB.Delete_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PUB.Delete_Kpi_Measure_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasurePub_Delete;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PUB.Delete_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PUB.Delete_Kpi_Measure_Props ';
    END IF;
END Delete_Kpi_Measure_Props;

/************************************************************************************
************************************************************************************/
PROCEDURE Delete_Obj_Kpi_Measure_Props (
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
, p_objective_id        IN             NUMBER
, p_cascade_shared      IN             BOOLEAN := TRUE
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
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

  SAVEPOINT BscKpiMeasurePub_DeleteAll;

  -- Any Business Logic Validation

  BSC_KPI_MEASURE_PROPS_PVT.Delete_Obj_Kpi_Measure_Props
  ( p_commit           => p_commit
  , p_objective_id     => p_objective_id
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF p_cascade_shared THEN

    FOR c_shared IN c_shared_obj(p_objective_id) LOOP

      BSC_KPI_MEASURE_PROPS_PVT.Delete_Obj_Kpi_Measure_Props
      ( p_commit           => p_commit
      , p_objective_id     => c_shared.indicator
      , x_return_status    => x_return_status
      , x_msg_count        => x_msg_count
      , x_msg_data         => x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;

  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasurePub_DeleteAll;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasurePub_DeleteAll;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasurePub_DeleteAll;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PUB.Delete_Obj_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PUB.Delete_Obj_Kpi_Measure_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasurePub_DeleteAll;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PUB.Delete_Obj_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PUB.Delete_Obj_Kpi_Measure_Props ';
    END IF;
END Delete_Obj_Kpi_Measure_Props;

/************************************************************************************
************************************************************************************/
PROCEDURE Retrieve_Kpi_Measure_Props (
  p_objective_id        IN             NUMBER
, p_kpi_measure_id      IN             NUMBER
, x_kpi_measure_rec     OUT NOCOPY     BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
)
IS
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Any Business Logic Validation

  BSC_KPI_MEASURE_PROPS_PVT.Retrieve_Kpi_Measure_Props
  ( p_objective_id     => p_objective_id
  , p_kpi_measure_id   => p_kpi_measure_id
  , x_kpi_measure_rec  => x_kpi_measure_rec
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
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
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PUB.Delete_Obj_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PUB.Delete_Obj_Kpi_Measure_Props ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PUB.Delete_Obj_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PUB.Delete_Obj_Kpi_Measure_Props ';
    END IF;
END Retrieve_Kpi_Measure_Props;

END BSC_KPI_MEASURE_PROPS_PUB;

/
