--------------------------------------------------------
--  DDL for Package Body BSC_KPI_MEASURE_PROPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_KPI_MEASURE_PROPS_PVT" AS
/* $Header: BSCVKMPB.pls 120.1.12000000.1 2007/07/17 07:44:45 appldev noship $ */

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Kpi_Measure_Props (
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_rec     IN            BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec
, x_return_status       OUT NOCOPY    VARCHAR2
, x_msg_count           OUT NOCOPY    NUMBER
, x_msg_data            OUT NOCOPY    VARCHAR2
)
IS
  l_count  NUMBER;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscKpiMeasurePvt_Create;

  IF (p_kpi_measure_rec.objective_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_OBJECTIVE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (p_kpi_measure_rec.kpi_measure_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_KPI_MEASURE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    SELECT COUNT(1) INTO l_count
      FROM  bsc_kpi_measure_props
      WHERE indicator = p_kpi_measure_rec.objective_id
      AND   kpi_measure_id = p_kpi_measure_rec.kpi_measure_id;
    IF (l_count > 0) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_OBJ_KPIMEASURE_EXISTS');
      FND_MESSAGE.SET_TOKEN('OBJECTIVE_ID', p_kpi_measure_rec.objective_id);
      FND_MESSAGE.SET_TOKEN('KPI_MEASURE_ID', p_kpi_measure_rec.kpi_measure_id);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  INSERT INTO bsc_kpi_measure_props
  ( indicator
  , kpi_measure_id
  , prototype_color_id
  , prototype_trend_id
  , color_by_total
  , disable_color
  , disable_trend
  , apply_color_flag
  , default_calculation
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  )
  VALUES
  ( p_kpi_measure_rec.objective_id
  , p_kpi_measure_rec.kpi_measure_id
  , p_kpi_measure_rec.prototype_color
  , p_kpi_measure_rec.prototype_trend
  , p_kpi_measure_rec.color_by_total
  , p_kpi_measure_rec.disable_color
  , p_kpi_measure_rec.disable_trend
  , p_kpi_measure_rec.apply_color_flag
  , p_kpi_measure_rec.default_calculation
  , NVL(p_kpi_measure_rec.creation_date, SYSDATE)
  , NVL(p_kpi_measure_rec.created_by, FND_GLOBAL.USER_ID)
  , NVL(p_kpi_measure_rec.last_update_date, SYSDATE)
  , NVL(p_kpi_measure_rec.last_updated_by, FND_GLOBAL.USER_ID)
  , NVL(p_kpi_measure_rec.last_update_login, FND_GLOBAL.LOGIN_ID)
  );

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasurePvt_Create;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasurePvt_Create;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasurePvt_Create;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PVT.Create_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PVT.Create_Kpi_Measure_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasurePvt_Create;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PVT.Create_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PVT.Create_Kpi_Measure_Props ';
    END IF;
END Create_Kpi_Measure_Props;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Update_Kpi_Measure_Props (
  p_commit              IN             VARCHAR2 := FND_API.G_FALSE
, p_kpi_measure_rec     IN             BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec
, x_return_status       OUT NOCOPY     VARCHAR2
, x_msg_count           OUT NOCOPY     NUMBER
, x_msg_data            OUT NOCOPY     VARCHAR2
)
IS
  l_kpi_measure_rec  BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscKpiMeasurePvt_Update;

  IF (p_kpi_measure_rec.objective_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_OBJECTIVE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (p_kpi_measure_rec.kpi_measure_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_KPI_MEASURE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  Retrieve_Kpi_Measure_Props
  ( p_objective_id     => p_kpi_measure_rec.objective_id
  , p_kpi_measure_id   => p_kpi_measure_rec.kpi_measure_id
  , x_kpi_measure_rec  => l_kpi_measure_rec
  , x_return_status    => x_return_status
  , x_msg_count        => x_msg_count
  , x_msg_data         => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.G_EXC_ERROR;
  END IF;

  l_kpi_measure_rec.default_calculation:= p_kpi_measure_rec.default_calculation;
  IF(p_kpi_measure_rec.prototype_color IS NOT NULL) THEN
    l_kpi_measure_rec.prototype_color := p_kpi_measure_rec.prototype_color;
  END IF;
  IF(p_kpi_measure_rec.prototype_trend IS NOT NULL) THEN
    l_kpi_measure_rec.prototype_trend:= p_kpi_measure_rec.prototype_trend;
  END IF;
  IF(p_kpi_measure_rec.color_by_total IS NOT NULL) THEN
    l_kpi_measure_rec.color_by_total:= p_kpi_measure_rec.color_by_total;
  END IF;
  IF(p_kpi_measure_rec.disable_color IS NOT NULL) THEN
    l_kpi_measure_rec.disable_color:= p_kpi_measure_rec.disable_color;
  END IF;
  IF(p_kpi_measure_rec.disable_trend IS NOT NULL) THEN
    l_kpi_measure_rec.disable_trend:= p_kpi_measure_rec.disable_trend;
  END IF;
  IF(p_kpi_measure_rec.apply_color_flag IS NOT NULL) THEN
    l_kpi_measure_rec.apply_color_flag:= p_kpi_measure_rec.apply_color_flag;
  END IF;
  IF(p_kpi_measure_rec.last_update_date IS NULL) THEN
    l_kpi_measure_rec.last_update_date := SYSDATE;
  ELSE
    l_kpi_measure_rec.last_update_date := p_kpi_measure_rec.last_update_date;
  END IF;
  IF (p_kpi_measure_rec.last_updated_by IS NULL) THEN
    l_kpi_measure_rec.last_updated_by := FND_GLOBAL.USER_ID;
  ELSE
    l_kpi_measure_rec.last_updated_by := p_kpi_measure_rec.last_updated_by;
  END IF;
  IF (p_kpi_measure_rec.last_update_login IS NULL) THEN
    l_kpi_measure_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
  ELSE
    l_kpi_measure_rec.last_update_login := p_kpi_measure_rec.last_update_login;
  END IF;

  UPDATE bsc_kpi_measure_props
    SET prototype_color_id  = l_kpi_measure_rec.prototype_color
      , prototype_trend_id  = l_kpi_measure_rec.prototype_trend
      , color_by_total      = l_kpi_measure_rec.color_by_total
      , disable_color       = l_kpi_measure_rec.disable_color
      , disable_trend       = l_kpi_measure_rec.disable_trend
      , apply_color_flag    = l_kpi_measure_rec.apply_color_flag
      , default_calculation = l_kpi_measure_rec.default_calculation
      , last_updated_by     = l_kpi_measure_rec.last_updated_by
      , last_update_date    = l_kpi_measure_rec.last_update_date
      , last_update_login   = l_kpi_measure_rec.last_update_login
    WHERE indicator = l_kpi_measure_rec.objective_id
    AND   kpi_measure_id = l_kpi_measure_rec.kpi_measure_id;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasurePvt_Update;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasurePvt_Update;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasurePvt_Update;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PVT.Update_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PVT.Update_Kpi_Measure_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasurePvt_Update;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PVT.Update_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PVT.Update_Kpi_Measure_Props ';
    END IF;
END Update_Kpi_Measure_Props;

/************************************************************************************
************************************************************************************/
PROCEDURE Delete_Kpi_Measure_Props (
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

  SAVEPOINT BscKpiMeasurePvt_Delete;

  IF (p_objective_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_OBJECTIVE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (p_kpi_measure_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_KPI_MEASURE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE FROM bsc_kpi_measure_props
    WHERE indicator = p_objective_id
    AND   kpi_measure_id = p_kpi_measure_id;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasurePvt_Delete;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasurePvt_Delete;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasurePvt_Delete;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PVT.Delete_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PVT.Delete_Kpi_Measure_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasurePvt_Delete;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PVT.Delete_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PVT.Delete_Kpi_Measure_Props ';
    END IF;
END Delete_Kpi_Measure_Props;

/************************************************************************************
************************************************************************************/
PROCEDURE Delete_Obj_Kpi_Measure_Props (
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

  SAVEPOINT BscKpiMeasurePvt_DeleteAll;

  IF (p_objective_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_OBJECTIVE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  DELETE FROM bsc_kpi_measure_props
    WHERE indicator = p_objective_id;

  IF (p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO BscKpiMeasurePvt_DeleteAll;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO BscKpiMeasurePvt_DeleteAll;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
      , p_count     =>  x_msg_count
      , p_data      =>  x_msg_data
      );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO BscKpiMeasurePvt_DeleteAll;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PVT.Delete_Obj_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PVT.Delete_Obj_Kpi_Measure_Props ';
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO BscKpiMeasurePvt_DeleteAll;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PVT.Delete_Obj_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PVT.Delete_Obj_Kpi_Measure_Props ';
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
  , prototype_color_id
  , prototype_trend_id
  , color_by_total
  , disable_color
  , disable_trend
  , apply_color_flag
  , default_calculation
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  INTO
    x_kpi_measure_rec.objective_id
  , x_kpi_measure_rec.kpi_measure_id
  , x_kpi_measure_rec.prototype_color
  , x_kpi_measure_rec.prototype_trend
  , x_kpi_measure_rec.color_by_total
  , x_kpi_measure_rec.disable_color
  , x_kpi_measure_rec.disable_trend
  , x_kpi_measure_rec.apply_color_flag
  , x_kpi_measure_rec.default_calculation
  , x_kpi_measure_rec.creation_date
  , x_kpi_measure_rec.created_by
  , x_kpi_measure_rec.last_update_date
  , x_kpi_measure_rec.last_updated_by
  , x_kpi_measure_rec.last_update_login
  FROM bsc_kpi_measure_props
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
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PVT.Retrieve_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PVT.Retrieve_Kpi_Measure_Props ';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data || ' -> BSC_KPI_MEASURE_PROPS_PVT.Retrieve_Kpi_Measure_Props ';
    ELSE
      x_msg_data := SQLERRM || ' at BSC_KPI_MEASURE_PROPS_PVT.Retrieve_Kpi_Measure_Props ';
    END IF;
END Retrieve_Kpi_Measure_Props;

END BSC_KPI_MEASURE_PROPS_PVT;

/
