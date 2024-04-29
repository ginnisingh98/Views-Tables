--------------------------------------------------------
--  DDL for Package Body BSC_KPI_MEASURE_WEIGHTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_MEASURE_WEIGHTS_PUB" AS
/* $Header: BSCPKMWB.pls 120.0.12000000.1 2007/07/17 07:44:09 appldev noship $ */

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Kpi_Measure_Weights (
  p_commit                   IN            VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_weights_rec  IN            BSC_KPI_MEASURE_WEIGHTS_PUB.kpi_measure_weights_rec
, p_cascade_shared           IN            BOOLEAN := TRUE
, x_return_status            OUT NOCOPY    VARCHAR2
, x_msg_count                OUT NOCOPY    NUMBER
, x_msg_data                 OUT NOCOPY    VARCHAR2
)
IS
  CURSOR c_shared_obj(p_indicator NUMBER) IS
    SELECT indicator
    FROM   bsc_kpis_b
    WHERE  source_indicator = p_indicator
    AND    share_flag = 2 -- shared objective.
    AND    prototype_flag <> 2;

  l_kpi_measure_weights_rec  BSC_KPI_MEASURE_WEIGHTS_PUB.kpi_measure_weights_rec;
  l_kpi_measure_id           NUMBER;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscKpiMeasureWeightPub_Create;

  -- Any Business Logic Validation

  BSC_KPI_MEASURE_WEIGHTS_PVT.Create_Kpi_Measure_Weights
  ( p_commit                   => p_commit
  , p_kpi_measure_weights_rec  => p_kpi_measure_weights_rec
  , x_return_status            => x_return_status
  , x_msg_count                => x_msg_count
  , x_msg_data                 => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF p_cascade_shared THEN
    FOR c_shared IN c_shared_obj(p_kpi_measure_weights_rec.objective_id) LOOP

      l_kpi_measure_id := BSC_KPI_MEASURE_PROPS_PUB.get_shared_obj_kpi_measure
                          ( p_objective_id         => p_kpi_measure_weights_rec.objective_id
                          , p_kpi_measure_id       => p_kpi_measure_weights_rec.kpi_measure_id
                          , p_shared_objective_id  => c_shared.indicator
                          );
      IF l_kpi_measure_id IS NULL THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

      l_kpi_measure_weights_rec := p_kpi_measure_weights_rec;
      l_kpi_measure_weights_rec.objective_id := c_shared.indicator;
      l_kpi_measure_weights_rec.kpi_measure_id := l_kpi_measure_id;

      BSC_KPI_MEASURE_WEIGHTS_PVT.Create_Kpi_Measure_Weights
      ( p_commit                   => p_commit
      , p_kpi_measure_weights_rec  => l_kpi_measure_weights_rec
      , x_return_status            => x_return_status
      , x_msg_count                => x_msg_count
      , x_msg_data                 => x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPub_Create;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPub_Create;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasureWeightPub_Create;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PUB.Create_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PUB.Create_Kpi_Measure_Weights ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasureWeightPub_Create;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PUB.Create_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PUB.Create_Kpi_Measure_Weights ';
    END IF;
END Create_Kpi_Measure_Weights;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Update_Kpi_Measure_Weights (
  p_commit                   IN             VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_weights_rec  IN             BSC_KPI_MEASURE_WEIGHTS_PUB.kpi_measure_weights_rec
, p_cascade_shared           IN             BOOLEAN := TRUE
, x_return_status            OUT NOCOPY     VARCHAR2
, x_msg_count                OUT NOCOPY     NUMBER
, x_msg_data                 OUT NOCOPY     VARCHAR2
)
IS
  CURSOR c_shared_obj(p_indicator NUMBER) IS
    SELECT indicator
    FROM   bsc_kpis_b
    WHERE  source_indicator = p_indicator
    AND    share_flag = 2 -- shared objective.
    AND    prototype_flag <> 2;

  l_kpi_measure_weights_rec  BSC_KPI_MEASURE_WEIGHTS_PUB.kpi_measure_weights_rec;
  l_kpi_measure_id           NUMBER;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscKpiMeasureWeightPub_Update;

  -- Any Business Logic Validation

  BSC_KPI_MEASURE_WEIGHTS_PVT.Update_Kpi_Measure_Weights
  ( p_commit                   => p_commit
  , p_kpi_measure_weights_rec  => p_kpi_measure_weights_rec
  , x_return_status            => x_return_status
  , x_msg_count                => x_msg_count
  , x_msg_data                 => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF p_cascade_shared THEN
    FOR c_shared IN c_shared_obj(p_kpi_measure_weights_rec.objective_id) LOOP

      l_kpi_measure_id := BSC_KPI_MEASURE_PROPS_PUB.get_shared_obj_kpi_measure
                          ( p_objective_id         => p_kpi_measure_weights_rec.objective_id
                          , p_kpi_measure_id       => p_kpi_measure_weights_rec.kpi_measure_id
                          , p_shared_objective_id  => c_shared.indicator
                          );
      IF l_kpi_measure_id IS NULL THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

      l_kpi_measure_weights_rec := p_kpi_measure_weights_rec;
      l_kpi_measure_weights_rec.objective_id := c_shared.indicator;
      l_kpi_measure_weights_rec.kpi_measure_id := l_kpi_measure_id;

      BSC_KPI_MEASURE_WEIGHTS_PVT.Update_Kpi_Measure_Weights
      ( p_commit                   => p_commit
      , p_kpi_measure_weights_rec  => l_kpi_measure_weights_rec
      , x_return_status            => x_return_status
      , x_msg_count                => x_msg_count
      , x_msg_data                 => x_msg_data
      );
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPub_Update;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPub_Update;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasureWeightPub_Update;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PUB.Update_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PUB.Update_Kpi_Measure_Weights ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasureWeightPub_Update;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PUB.Update_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PUB.Update_Kpi_Measure_Weights ';
    END IF;
END Update_Kpi_Measure_Weights;

/************************************************************************************
************************************************************************************/
PROCEDURE Del_Kpi_Measure_Weights (
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

  SAVEPOINT BscKpiMeasureWeightPub_Delete;

  -- Any Business Logic Validation

  BSC_KPI_MEASURE_WEIGHTS_PVT.Del_Kpi_Measure_Weights
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

      l_kpi_measure_id := BSC_KPI_MEASURE_PROPS_PUB.get_shared_obj_kpi_measure
                        ( p_objective_id         => p_objective_id
                        , p_kpi_measure_id       => p_kpi_measure_id
                        , p_shared_objective_id  => c_shared.indicator
                        );
      IF l_kpi_measure_id IS NULL THEN
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

      BSC_KPI_MEASURE_WEIGHTS_PVT.Del_Kpi_Measure_Weights
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
    ROLLBACK TO BscKpiMeasureWeightPub_Delete;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPub_Delete;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasureWeightPub_Delete;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PUB.Del_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PUB.Del_Kpi_Measure_Weights ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasureWeightPub_Delete;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PUB.Del_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PUB.Del_Kpi_Measure_Weights ';
    END IF;
END Del_Kpi_Measure_Weights;

/************************************************************************************
************************************************************************************/
PROCEDURE Del_Obj_Kpi_Measure_Weights (
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

  SAVEPOINT BscKpiMeasureWeightPub_DelAll;

  -- Any Business Logic Validation

  BSC_KPI_MEASURE_WEIGHTS_PVT.Del_Obj_Kpi_Measure_Weights
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

      BSC_KPI_MEASURE_WEIGHTS_PVT.Del_Obj_Kpi_Measure_Weights
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
    ROLLBACK TO BscKpiMeasureWeightPub_DelAll;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPub_DelAll;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasureWeightPub_DelAll;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PUB.Del_Obj_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PUB.Del_Obj_Kpi_Measure_Weights ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasureWeightPub_DelAll;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PUB.Del_Obj_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PUB.Del_Obj_Kpi_Measure_Weights ';
    END IF;
END Del_Obj_Kpi_Measure_Weights;

/************************************************************************************
************************************************************************************/
PROCEDURE Retrieve_Kpi_Measure_Weights (
  p_objective_id             IN             NUMBER
, p_kpi_measure_id           IN             NUMBER
, x_kpi_measure_weights_rec  OUT NOCOPY     BSC_KPI_MEASURE_WEIGHTS_PUB.kpi_measure_weights_rec
, x_return_status            OUT NOCOPY     VARCHAR2
, x_msg_count                OUT NOCOPY     NUMBER
, x_msg_data                 OUT NOCOPY     VARCHAR2
)
IS
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Any Business Logic Validation

  BSC_KPI_MEASURE_WEIGHTS_PVT.Retrieve_Kpi_Measure_Weights
  ( p_objective_id            => p_objective_id
  , p_kpi_measure_id          => p_kpi_measure_id
  , x_kpi_measure_weights_rec => x_kpi_measure_weights_rec
  , x_return_status           => x_return_status
  , x_msg_count               => x_msg_count
  , x_msg_data                => x_msg_data
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
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PUB.Retrieve_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PUB.Retrieve_Kpi_Measure_Weights ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PUB.Retrieve_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PUB.Retrieve_Kpi_Measure_Weights ';
    END IF;
END Retrieve_Kpi_Measure_Weights;

END BSC_KPI_MEASURE_WEIGHTS_PUB;

/
