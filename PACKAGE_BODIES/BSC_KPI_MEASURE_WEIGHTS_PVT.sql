--------------------------------------------------------
--  DDL for Package Body BSC_KPI_MEASURE_WEIGHTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_MEASURE_WEIGHTS_PVT" AS
/* $Header: BSCVKMWB.pls 120.0.12000000.1 2007/07/17 07:44:49 appldev noship $ */

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Kpi_Measure_Weights (
  p_commit                   IN            VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_weights_rec  IN            BSC_KPI_MEASURE_WEIGHTS_PUB.kpi_measure_weights_rec
, x_return_status            OUT NOCOPY    VARCHAR2
, x_msg_count                OUT NOCOPY    NUMBER
, x_msg_data                 OUT NOCOPY    VARCHAR2
)
IS
  l_count  NUMBER;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscKpiMeasureWeightPvt_Create;

  IF (p_kpi_measure_weights_rec.objective_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_OBJECTIVE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (p_kpi_measure_weights_rec.kpi_measure_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_KPI_MEASURE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  INSERT INTO bsc_kpi_measure_weights
  ( indicator
  , kpi_measure_id
  , weight
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  )
  VALUES
  ( p_kpi_measure_weights_rec.objective_id
  , p_kpi_measure_weights_rec.kpi_measure_id
  , p_kpi_measure_weights_rec.weight
  , NVL(p_kpi_measure_weights_rec.creation_date, SYSDATE)
  , NVL(p_kpi_measure_weights_rec.created_by, FND_GLOBAL.USER_ID)
  , NVL(p_kpi_measure_weights_rec.last_update_date, SYSDATE)
  , NVL(p_kpi_measure_weights_rec.last_updated_by, FND_GLOBAL.USER_ID)
  , NVL(p_kpi_measure_weights_rec.last_update_login, FND_GLOBAL.LOGIN_ID)
  );

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_Create;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_Create;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_Create;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PVT.Create_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PVT.Create_Kpi_Measure_Weights ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_Create;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PVT.Create_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PVT.Create_Kpi_Measure_Weights ';
    END IF;
END Create_Kpi_Measure_Weights;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Update_Kpi_Measure_Weights (
  p_commit                   IN             VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_weights_rec  IN             BSC_KPI_MEASURE_WEIGHTS_PUB.kpi_measure_weights_rec
, x_return_status            OUT NOCOPY     VARCHAR2
, x_msg_count                OUT NOCOPY     NUMBER
, x_msg_data                 OUT NOCOPY     VARCHAR2
)
IS
  l_kpi_measure_weights_rec  BSC_KPI_MEASURE_WEIGHTS_PUB.kpi_measure_weights_rec;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscKpiMeasureWeightPvt_Update;

  IF (p_kpi_measure_weights_rec.objective_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_OBJECTIVE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (p_kpi_measure_weights_rec.kpi_measure_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_KPI_MEASURE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  Retrieve_Kpi_Measure_Weights
  ( p_objective_id             => p_kpi_measure_weights_rec.objective_id
  , p_kpi_measure_id           => p_kpi_measure_weights_rec.kpi_measure_id
  , x_kpi_measure_weights_rec  => l_kpi_measure_weights_rec
  , x_return_status            => x_return_status
  , x_msg_count                => x_msg_count
  , x_msg_data                 => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  IF(p_kpi_measure_weights_rec.weight IS NOT NULL) THEN
    l_kpi_measure_weights_rec.weight := p_kpi_measure_weights_rec.weight;
  END IF;
  IF(p_kpi_measure_weights_rec.last_update_date IS NULL) THEN
    l_kpi_measure_weights_rec.last_update_date := SYSDATE;
  ELSE
    l_kpi_measure_weights_rec.last_update_date := p_kpi_measure_weights_rec.last_update_date;
  END IF;
  IF (p_kpi_measure_weights_rec.last_updated_by IS NULL) THEN
    l_kpi_measure_weights_rec.last_updated_by := FND_GLOBAL.USER_ID;
  ELSE
    l_kpi_measure_weights_rec.last_updated_by := p_kpi_measure_weights_rec.last_updated_by;
  END IF;
  IF (p_kpi_measure_weights_rec.last_update_login IS NULL) THEN
    l_kpi_measure_weights_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
  ELSE
    l_kpi_measure_weights_rec.last_update_login := p_kpi_measure_weights_rec.last_update_login;
  END IF;

  UPDATE bsc_kpi_measure_weights
    SET weight            = l_kpi_measure_weights_rec.weight
      , last_updated_by   = l_kpi_measure_weights_rec.last_updated_by
      , last_update_date  = l_kpi_measure_weights_rec.last_update_date
      , last_update_login = l_kpi_measure_weights_rec.last_update_login
    WHERE indicator = l_kpi_measure_weights_rec.objective_id
    AND   kpi_measure_id = l_kpi_measure_weights_rec.kpi_measure_id;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_Update;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_Update;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_Update;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PVT.Update_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PVT.Update_Kpi_Measure_Weights ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_Update;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PVT.Update_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PVT.Update_Kpi_Measure_Weights ';
    END IF;
END Update_Kpi_Measure_Weights;

/************************************************************************************
************************************************************************************/
PROCEDURE Del_Kpi_Measure_Weights (
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
, p_objective_id        IN             NUMBER
, p_kpi_measure_id      IN             NUMBER
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
)
IS
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscKpiMeasureWeightPvt_Delete;

  IF (p_objective_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_OBJECTIVE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (p_kpi_measure_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_KPI_MEASURE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE FROM bsc_kpi_measure_weights
    WHERE indicator = p_objective_id
    AND   kpi_measure_id = p_kpi_measure_id;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_Delete;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_Delete;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_Delete;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PVT.Del_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PVT.Del_Kpi_Measure_Weights ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_Delete;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PVT.Del_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PVT.Del_Kpi_Measure_Weights ';
    END IF;
END Del_Kpi_Measure_Weights;

/************************************************************************************
************************************************************************************/
PROCEDURE Del_Obj_Kpi_Measure_Weights (
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
, p_objective_id        IN             NUMBER
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
)
IS
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscKpiMeasureWeightPvt_DelAll;

  IF (p_objective_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_OBJECTIVE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE FROM bsc_kpi_measure_weights
    WHERE indicator = p_objective_id;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_DelAll;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_DelAll;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_DelAll;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PVT.Del_Obj_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PVT.Del_Obj_Kpi_Measure_Weights ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasureWeightPvt_DelAll;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PVT.Del_Obj_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PVT.Del_Obj_Kpi_Measure_Weights ';
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

  IF (p_objective_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_OBJECTIVE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (p_kpi_measure_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_KPI_MEASURE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT
    indicator
  , kpi_measure_id
  , weight
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  INTO
    x_kpi_measure_weights_rec.objective_id
  , x_kpi_measure_weights_rec.kpi_measure_id
  , x_kpi_measure_weights_rec.weight
  , x_kpi_measure_weights_rec.creation_date
  , x_kpi_measure_weights_rec.created_by
  , x_kpi_measure_weights_rec.last_update_date
  , x_kpi_measure_weights_rec.last_updated_by
  , x_kpi_measure_weights_rec.last_update_login
  FROM bsc_kpi_measure_weights
  WHERE indicator = p_objective_id
  AND   kpi_measure_id = p_kpi_measure_id;

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
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PVT.Retrieve_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PVT.Retrieve_Kpi_Measure_Weights ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_WEIGHTS_PVT.Retrieve_Kpi_Measure_Weights ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_WEIGHTS_PVT.Retrieve_Kpi_Measure_Weights ';
    END IF;
END Retrieve_Kpi_Measure_Weights;

END BSC_KPI_MEASURE_WEIGHTS_PVT;

/
