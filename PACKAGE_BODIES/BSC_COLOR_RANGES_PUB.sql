--------------------------------------------------------
--  DDL for Package Body BSC_COLOR_RANGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_COLOR_RANGES_PUB" as
/* $Header: BSCPCRNB.pls 120.4.12000000.1 2007/07/17 07:43:52 appldev noship $ */
/*
 +======================================================================================+
 |    Copyright (c) 2001 Oracle Corporation, Redwood Shores, CA, USA                    |
 |                         All rights reserved.                                         |
 +======================================================================================+
 | FILENAME                                                                             |
 |                      BSCPCOLB.pls                                                    |
 |                                                                                      |
 | Creation Date:                                                                       |
 |                      October 26, 2006                                                |
 |                                                                                      |
 | Creator:                                                                             |
 |                      Pradeep Pandey                                                  |
 |                                                                                      |
 | Description:         Public Body version.                                            |
 |                      This package is to manage System level Color properties         |
 |                      and provide CRUD APIs for BSC_COLOR_RANGES_B related table      |
 |                                                                                      |
 |  26-JUN-2007 ankgoel   Bug#6132361 - Handled PL objectives                          |
 +======================================================================================+
*/

G_PKG_NAME              CONSTANT        VARCHAR2(30) := 'BSC_COLOR_RANGES_PUB';


FUNCTION get_Color_Threshold_Array(
  p_threshold_color     IN            VARCHAR2
) RETURN THRESHOLD_ARRAY;

/************************************************************************************
 ************************************************************************************/
FUNCTION Get_Def_Color_Range_Rec(
  p_color_method        NUMBER
) RETURN BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Color_Prop_Ranges(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_color_type          IN            VARCHAR2  -- PERCENT_OF_TARGET, PERCENT_OF_KPI, CONSTANT
 ,p_threshold_color     IN            THRESHOLD_ARRAY
 ,p_property_value      IN            VARCHAR2 := NULL
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS
  l_loop_count                  NUMBER;
  l_val                         VARCHAR2(200);
  l_threshold                   VARCHAR2(2000);
  l_Bsc_Kpi_Color_Range_Rec     BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec;
  l_range_id                    NUMBER;
  l_is_succ                     BOOLEAN;
  l_user_id                     FND_USER.user_id%TYPE;

  CURSOR c_shared_obj IS
  SELECT indicator
  FROM   bsc_kpis_b
  WHERE  source_indicator = p_objective_id
  AND    share_flag = 2 -- shared objective.
  AND    prototype_flag <> 2;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorRangePub_CrtColorRng;

  SELECT BSC_COLOR_RANGE_ID_S.NEXTVAL
  INTO   l_range_id
  FROM   DUAL;


  FOR l_loop_count IN 1..p_threshold_color.COUNT LOOP
    l_threshold := p_threshold_color(l_loop_count);
    l_is_succ := Get_Next_Token(l_threshold,':',l_Bsc_Kpi_Color_Range_Rec(l_loop_count).color_range_sequence);
    l_is_succ := Get_Next_Token(l_threshold,':',l_Bsc_Kpi_Color_Range_Rec(l_loop_count).low);
    l_is_succ := Get_Next_Token(l_threshold,':',l_Bsc_Kpi_Color_Range_Rec(l_loop_count).high);
    l_is_succ := Get_Next_Token(l_threshold,':',l_Bsc_Kpi_Color_Range_Rec(l_loop_count).color_id);

  END LOOP;

  BSC_COLOR_RANGE_PVT.Create_Color_Props(p_objective_id    => p_objective_id
                                        ,p_kpi_measure_id  => p_kpi_measure_id
                                        ,p_color_type      => p_color_type
                                        ,p_color_range_id  => l_range_id
                                        ,p_property_value  => p_property_value
                                        ,x_return_status   => x_return_status
                                        ,x_msg_count       => x_msg_count
                                        ,x_msg_data        => x_msg_data);
  IF (x_return_status <> 'S') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_user_id := FND_GLOBAL.USER_ID;
  BSC_COLOR_RANGE_PVT.Create_Color_Range(p_range_id                 => l_range_id
                                        ,p_Bsc_Kpi_Color_Range_Rec  => l_Bsc_Kpi_Color_Range_Rec
                                        ,p_user_id                  => l_user_id
                                        ,x_return_status            => x_return_status
                                        ,x_msg_count                => x_msg_count
                                        ,x_msg_data                 => x_msg_data);
  IF (x_return_status <> 'S') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_kpi_measure_id IS NULL) THEN -- Threshold is for objective.
    FOR c_shared IN c_shared_obj LOOP
      SELECT BSC_COLOR_RANGE_ID_S.NEXTVAL
      INTO   l_range_id
      FROM   DUAL;
      BSC_COLOR_RANGE_PVT.Create_Color_Props(p_objective_id    => c_shared.indicator
                                            ,p_kpi_measure_id  => p_kpi_measure_id
                                            ,p_color_type      => p_color_type
                                            ,p_color_range_id  => l_range_id
                                            ,p_property_value  => p_property_value
                                            ,x_return_status   => x_return_status
                                            ,x_msg_count       => x_msg_count
                                            ,x_msg_data        => x_msg_data);
      IF (x_return_status <> 'S') THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      BSC_COLOR_RANGE_PVT.Create_Color_Range(p_range_id                 => l_range_id
                                            ,p_Bsc_Kpi_Color_Range_Rec  => l_Bsc_Kpi_Color_Range_Rec
                                            ,p_user_id                  => l_user_id
                                            ,x_return_status            => x_return_status
                                            ,x_msg_count                => x_msg_count
                                            ,x_msg_data                 => x_msg_data);
      IF (x_return_status <> 'S') THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
  END IF;

  IF(p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO BscColorRangePub_CrtColorRng;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
       ,p_count     =>  x_msg_count
       ,p_data      =>  x_msg_data
      );
    END IF;
END Create_Color_Prop_Ranges;


PROCEDURE create_def_clr_prop_clr_mtd (
  p_commit          IN          VARCHAR2 := FND_API.G_FALSE
, p_objective_id    IN          NUMBER
, p_kpi_measure_id  IN          NUMBER
, p_color_method    IN          NUMBER
, p_property_value  IN          NUMBER := NULL
, p_cascade_shared  IN          BOOLEAN
, x_return_status   OUT NOCOPY  VARCHAR2
, x_msg_count       OUT NOCOPY  NUMBER
, x_msg_data        OUT NOCOPY  VARCHAR2
)
IS
  l_loop_count                  NUMBER;
  l_val                         VARCHAR2(200);
  l_threshold                   VARCHAR2(2000);
  l_Bsc_Kpi_Color_Range_Rec     BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec;
  l_range_id                    NUMBER;
  l_is_succ                     BOOLEAN;
  l_user_id                     FND_USER.user_id%TYPE;
  l_kpi_measure_id              NUMBER;
  l_color_type                  VARCHAR2(20);
  l_an_opt0                     NUMBER;
  l_an_opt1                     NUMBER;
  l_an_opt2                     NUMBER;
  l_series_id                   NUMBER;
  l_objective_id                NUMBER;

  CURSOR c_shared_obj IS
  SELECT indicator
  FROM   bsc_kpis_b
  WHERE  source_indicator = p_objective_id
  AND    share_flag = 2 -- shared objective.
  AND    prototype_flag <> 2;

BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorPub_CrtDefClrRngCM;

  IF (p_kpi_measure_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_KPI_MEASURE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT BSC_COLOR_RANGE_ID_S.NEXTVAL
  INTO   l_range_id
  FROM   DUAL;

  l_color_type := 'PERCENT_OF_TARGET';

  IF (p_color_method IS NULL OR p_color_method > 3) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_COLOR_METHOD_ISSUE');
    FND_MESSAGE.SET_TOKEN('BSC_COLOR_METHOD', p_color_method);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_Bsc_Kpi_Color_Range_Rec := Get_Def_Color_Range_Rec(p_color_method);

  BSC_COLOR_RANGE_PVT.Create_Color_Props(p_objective_id    => p_objective_id
                                        ,p_kpi_measure_id  => p_kpi_measure_id
                                        ,p_color_type      => l_color_type
                                        ,p_color_range_id  => l_range_id
                                        ,p_property_value  => p_property_value
                                        ,x_return_status   => x_return_status
                                        ,x_msg_count       => x_msg_count
                                        ,x_msg_data        => x_msg_data);
  IF (x_return_status <> 'S') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_user_id := FND_GLOBAL.USER_ID;
  BSC_COLOR_RANGE_PVT.Create_Color_Range(p_range_id                 => l_range_id
                                        ,p_Bsc_Kpi_Color_Range_Rec  => l_Bsc_Kpi_Color_Range_Rec
                                        ,p_user_id                  => l_user_id
                                        ,x_return_status            => x_return_status
                                        ,x_msg_count                => x_msg_count
                                        ,x_msg_data                 => x_msg_data);

  IF (x_return_status <> 'S') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (p_cascade_shared) THEN

    IF (p_kpi_measure_id IS NOT NULL) THEN
      SELECT am.analysis_option0,
             am.analysis_option1, am.analysis_option2, am.series_id
      INTO   l_an_opt0, l_an_opt1, l_an_opt2, l_series_id
      FROM   bsc_kpi_analysis_measures_b am
      WHERE  am.indicator = p_objective_id
      AND    am.kpi_measure_id = p_kpi_measure_id;
    END IF;

    FOR c_shared IN c_shared_obj LOOP
      l_objective_id := c_shared.indicator;

      SELECT BSC_COLOR_RANGE_ID_S.NEXTVAL
      INTO   l_range_id
      FROM   DUAL;

      IF (p_kpi_measure_id IS NOT NULL) THEN
        SELECT kpi_measure_id
        INTO   l_kpi_measure_id
        FROM   bsc_kpi_analysis_measures_b
        WHERE  indicator= c_shared.indicator
        AND    analysis_option0 = l_an_opt0
        AND    analysis_option1 = l_an_opt1
        AND    analysis_option2 = l_an_opt2
        AND    series_id        = l_series_id;

        BSC_COLOR_RANGE_PVT.Create_Color_Props(p_objective_id    => c_shared.indicator
                                              ,p_kpi_measure_id  => l_kpi_measure_id
                                              ,p_color_type      => l_color_type
                                              ,p_color_range_id  => l_range_id
                                              ,p_property_value  => p_property_value
                                              ,x_return_status   => x_return_status
                                              ,x_msg_count       => x_msg_count
                                              ,x_msg_data        => x_msg_data);
        IF (x_return_status <> 'S') THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_user_id := FND_GLOBAL.USER_ID;
        BSC_COLOR_RANGE_PVT.Create_Color_Range(p_range_id                 => l_range_id
                                              ,p_Bsc_Kpi_Color_Range_Rec  => l_Bsc_Kpi_Color_Range_Rec
                                              ,p_user_id                  => l_user_id
                                              ,x_return_status            => x_return_status
                                              ,x_msg_count                => x_msg_count
                                              ,x_msg_data                 => x_msg_data);
        IF (x_return_status <> 'S') THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END IF;
    END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO BscColorPub_CrtDefClrRngCM;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
       ,p_count     =>  x_msg_count
       ,p_data      =>  x_msg_data
      );
    END IF;

END create_def_clr_prop_clr_mtd;


PROCEDURE create_pl_def_clr_prop_ranges (
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_cascade_shared      IN            BOOLEAN
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS
BEGIN

  create_def_clr_prop_clr_mtd (
      p_commit          => p_commit
    , p_objective_id    => p_objective_id
    , p_kpi_measure_id  => p_kpi_measure_id
    , p_color_method    => 1
    , p_property_value  => 1
    , p_cascade_shared  => p_cascade_shared
    , x_return_status   => x_return_status
    , x_msg_count       => x_msg_count
    , x_msg_data        => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  create_def_clr_prop_clr_mtd (
      p_commit          => p_commit
    , p_objective_id    => p_objective_id
    , p_kpi_measure_id  => p_kpi_measure_id
    , p_color_method    => 2
    , p_property_value  => 2
    , p_cascade_shared  => p_cascade_shared
    , x_return_status   => x_return_status
    , x_msg_count       => x_msg_count
    , x_msg_data        => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;


  create_def_clr_prop_clr_mtd (
      p_commit          => p_commit
    , p_objective_id    => p_objective_id
    , p_kpi_measure_id  => p_kpi_measure_id
    , p_color_method    => 3
    , p_property_value  => 3
    , p_cascade_shared  => p_cascade_shared
    , x_return_status   => x_return_status
    , x_msg_count       => x_msg_count
    , x_msg_data        => x_msg_data
  );
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
       ,p_count     =>  x_msg_count
       ,p_data      =>  x_msg_data
      );
    END IF;
END create_pl_def_clr_prop_ranges;


/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Def_Color_Prop_Ranges(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_property_value      IN            NUMBER := NULL
 ,p_cascade_shared      IN            BOOLEAN
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
)
IS
  l_color_method                NUMBER;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_property_value IS NOT NULL) THEN
    l_color_method := p_property_value;
  ELSE
    SELECT ds.color_method
    INTO   l_color_method
    FROM   bsc_sys_datasets_b ds
          ,bsc_kpi_analysis_measures_b am
    WHERE  ds.dataset_id = am.dataset_id
    AND    am.indicator = p_objective_id
    AND    am.kpi_measure_id = p_kpi_measure_id;
  END IF;

  create_def_clr_prop_clr_mtd (
    p_commit          => p_commit
  , p_objective_id    => p_objective_id
  , p_kpi_measure_id  => p_kpi_measure_id
  , p_color_method    => l_color_method
  , p_property_value  => p_property_value
  , p_cascade_shared  => p_cascade_shared
  , x_return_status   => x_return_status
  , x_msg_count       => x_msg_count
  , x_msg_data        => x_msg_data
  );

  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
       ,p_count     =>  x_msg_count
       ,p_data      =>  x_msg_data
      );
    END IF;

END Create_Def_Color_Prop_Ranges;


/************************************************************************************
 ************************************************************************************/
--   API to be called from UI and other place,
--     it takes care of Create/Update/Default based on the parameters
PROCEDURE Save_Color_Prop_Ranges(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_color_type          IN            VARCHAR2  -- PERCENT_OF_TARGET, PERCENT_OF_KPI, CONSTANT
 ,p_threshold_color     IN            VARCHAR2
 ,p_property_value      IN            NUMBER := NULL
 ,p_cascade_shared      IN            BOOLEAN
 ,p_time_stamp          IN            DATE   := NULL  -- Granular Locking
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS
  l_threshold_array     THRESHOLD_ARRAY;
BEGIN
  IF (p_threshold_color IS NULL) THEN
    l_threshold_array := NULL;
  ELSE
    l_threshold_array := get_Color_Threshold_Array(p_threshold_color);
  END IF;
  Save_Color_Prop_Ranges(p_objective_id        => p_objective_id
                        ,p_kpi_measure_id      => p_kpi_measure_id
                        ,p_color_type          => p_color_type
                        ,p_threshold_color     => l_threshold_array
                        ,p_property_value      => p_property_value
                        ,p_cascade_shared      => p_cascade_shared
                        ,p_time_stamp          => p_time_stamp
                        ,x_return_status       => x_return_status
                        ,x_msg_count           => x_msg_count
                        ,x_msg_data            => x_msg_data);
END Save_Color_Prop_Ranges;

/************************************************************************************
 ************************************************************************************/
-- ppandey-> Create if range doesn't exists already, if threshold is null it will be
--   defaulted for create
-- If already exists update it.
-- This API is called from UI layer.
PROCEDURE Save_Color_Prop_Ranges(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_color_type          IN            VARCHAR2  -- PERCENT_OF_TARGET, PERCENT_OF_KPI, CONSTANT
 ,p_threshold_color     IN            THRESHOLD_ARRAY
 ,p_property_value      IN            NUMBER := NULL
 ,p_cascade_shared      IN            BOOLEAN
 ,p_time_stamp          IN            DATE   := NULL  -- Granular Locking
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS
  l_loop_count                  NUMBER;
  l_val                         VARCHAR2(200);
  l_threshold                   VARCHAR2(2000);
  l_Bsc_Kpi_Color_Range_Rec     BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec;
  l_range_id                    NUMBER;
  l_is_succ                     BOOLEAN;
  l_user_id                     FND_USER.user_id%TYPE;
  l_range_count                 NUMBER;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorRangePub_SaveColorRng;
  IF (p_kpi_measure_id IS NULL) THEN
    SELECT COUNT(1)
    INTO   l_range_count
    FROM   bsc_color_type_props
    WHERE  indicator = p_objective_id
    AND    kpi_measure_id IS NULL;
  ELSE
    IF (p_property_value IS NULL) THEN
      SELECT COUNT(1)
      INTO   l_range_count
      FROM   bsc_color_type_props
      WHERE  indicator = p_objective_id
      AND    kpi_measure_id = p_kpi_measure_id;
    ELSE
      SELECT COUNT(1)
      INTO   l_range_count
      FROM   bsc_color_type_props
      WHERE  indicator = p_objective_id
      AND    kpi_measure_id = p_kpi_measure_id
      AND    property_value = p_property_value;
    END IF;
  END IF;

  IF (l_range_count IS NULL OR l_range_count = 0) THEN -- Create Mode
    IF(p_threshold_color IS NULL) THEN
      Create_Def_Color_Prop_Ranges( p_objective_id        => p_objective_id
                                   ,p_kpi_measure_id      => p_kpi_measure_id
                                   ,p_property_value      => p_property_value
                                   ,p_cascade_shared      => p_cascade_shared
                                   ,x_return_status       => x_return_status
                                   ,x_msg_count           => x_msg_count
                                   ,x_msg_data            => x_msg_data);

      IF (x_return_status <> 'S') THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    ELSE
      Create_Color_Prop_Ranges(p_objective_id        => p_objective_id
                              ,p_kpi_measure_id      => p_kpi_measure_id
                              ,p_color_type          => p_color_type
                              ,p_threshold_color     => p_threshold_color
                              ,p_property_value      => p_property_value
                              ,x_return_status       => x_return_status
                              ,x_msg_count           => x_msg_count
                              ,x_msg_data            => x_msg_data);

      IF (x_return_status <> 'S') THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
  ELSE
    IF (p_threshold_color IS NOT NULL) THEN
      Update_Color_Prop_Ranges(p_objective_id    => p_objective_id
                              ,p_kpi_measure_id  => p_kpi_measure_id
                              ,p_color_type      => p_color_type
                              ,p_threshold_color => p_threshold_color
                              ,p_property_value  => p_property_value
                              ,p_time_stamp      => p_time_stamp
                              ,x_return_status   => x_return_status
                              ,x_msg_count       => x_msg_count
                              ,x_msg_data        => x_msg_data);
       IF (x_return_status <> 'S') THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
  END IF;

  IF(p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO BscColorRangePub_SaveColorRng;

      IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        ( p_encoded   =>  FND_API.G_FALSE
         ,p_count     =>  x_msg_count
         ,p_data      =>  x_msg_data
        );
      END IF;
END Save_Color_Prop_Ranges;

FUNCTION Get_Def_Color_Range_Rec(
  p_color_method        NUMBER
) RETURN BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec IS
  l_Bsc_Kpi_Color_Range_Rec            BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec;
  l_color_count_def                    VARCHAR2(1);
  l_color_count                        NUMBER;
  l_index                              NUMBER;
  l_low                                NUMBER;
  l_high                               NUMBER;
BEGIN
  SELECT property_value
  INTO   l_color_count
  FROM   bsc_sys_init
  WHERE  property_code = 'DEF_COLOR_COUNT';

  l_index := 1;

  IF (p_color_method = 1) THEN
    l_low   := NULL;
    l_high  := 90;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
    l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
    l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 192;
    l_low := l_high;
    l_index := l_index + 1;

    IF (l_color_count = '5') THEN
      l_high := 95;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
      l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
      l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 2;
      l_index := l_index + 1;
      l_low := l_high;
    END IF;
    l_high := 100;

    l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
    l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
    l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 49919;
    l_index := l_index + 1;
    l_low := l_high;

    IF (l_color_count = '5') THEN
      l_high := 105;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
      l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
      l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 1;
      l_index := l_index + 1;
      l_low := l_high;
    END IF;
    l_high := NULL;

    l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
    l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
    l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 24865;
  ELSIF  (p_color_method = 2) THEN
    l_low   := NULL;
    l_high  := 100;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
    l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
    l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 24865;
    l_low := l_high;
    l_index := l_index + 1;

    IF (l_color_count = '5') THEN
      l_high := 105;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
      l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
      l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 1;
      l_index := l_index + 1;
      l_low := l_high;
    END IF;
    l_high := 110;

    l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
    l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
    l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 49919;
    l_index := l_index + 1;
    l_low := l_high;

    IF (l_color_count = '5') THEN
      l_high := 115;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
      l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
      l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 2;
      l_index := l_index + 1;
      l_low := l_high;
    END IF;
    l_high := NULL;

    l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
    l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
    l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 192;
  ELSIF  (p_color_method = 3) THEN
    l_low   := NULL;
    IF (l_color_count = '5') THEN
      l_high  := 80;
    ELSE
      l_high  := 90;
    END IF;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
    l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
    l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 192;
    l_low := l_high;
    l_index := l_index + 1;

    IF (l_color_count = '5') THEN
      l_high := l_high + 5;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
      l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
      l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 2;
      l_index := l_index + 1;
      l_low := l_high;
    END IF;
    l_high := l_high + 5;

    l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
    l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
    l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 49919;
    l_index := l_index + 1;
    l_low := l_high;

    IF (l_color_count = '5') THEN
      l_high := l_high + 5;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
      l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
      l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 1;
      l_index := l_index + 1;
      l_low := l_high;
    END IF;
    l_high := l_high + 5;

    l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
    l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
    l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 24865;
    l_index := l_index + 1;
    l_low   := l_high;

    IF (l_color_count = '5') THEN
      l_high := l_high + 5;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
      l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
      l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 1;
      l_index := l_index + 1;
      l_low := l_high;
    END IF;
    l_high := l_high + 5;

    l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
    l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
    l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 49919;
    l_index := l_index + 1;
    l_low := l_high;

    IF (l_color_count = '5') THEN
      l_high := l_high + 5;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
      l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
      l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
      l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 2;
      l_index := l_index + 1;
      l_low := l_high;
    END IF;
    l_high := NULL;

    l_Bsc_Kpi_Color_Range_Rec(l_index).color_range_sequence := l_index;
    l_Bsc_Kpi_Color_Range_Rec(l_index).low := l_low;
    l_Bsc_Kpi_Color_Range_Rec(l_index).high := l_high;
    l_Bsc_Kpi_Color_Range_Rec(l_index).color_id := 192;
  END IF;
  RETURN l_Bsc_Kpi_Color_Range_Rec;
END Get_Def_Color_Range_Rec;

FUNCTION Get_Range_Id(
  p_objective_id    IN  NUMBER
, p_kpi_measure_id  IN  NUMBER
, p_property_value  IN  NUMBER := NULL
) RETURN NUMBER
IS

  CURSOR c_obj_range_id IS
  SELECT color_range_id
  FROM   bsc_color_type_props
  WHERE  indicator = p_objective_id;

  CURSOR c_kpi_range_id IS
  SELECT color_range_id
  FROM   bsc_color_type_props
  WHERE  indicator = p_objective_id
  AND    kpi_measure_id = p_kpi_measure_id
  AND    NVL(property_value, -1) = DECODE(p_property_value, NULL, -1, p_property_value);

BEGIN
  IF (p_kpi_measure_id IS NULL) THEN
    FOR c_obj_range in c_obj_range_id LOOP
      RETURN c_obj_range.color_range_id;
    END LOOP;
  END IF;
  FOR c_kpi_range IN c_kpi_range_id LOOP
    RETURN c_kpi_range.color_range_id;
  END LOOP;
  RETURN NULL;
END;
/************************************************************************************
 ************************************************************************************/
PROCEDURE Update_Color_Prop_Ranges(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_color_type          IN            VARCHAR2  -- PERCENT_OF_TARGET, PERCENT_OF_KPI, CONSTANT
 ,p_threshold_color     IN            THRESHOLD_ARRAY
 ,p_property_value      IN            NUMBER := NULL
 ,p_time_stamp          IN            DATE   := NULL  -- Granular Locking
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS
  l_loop_count          NUMBER;
  l_val                         VARCHAR2(200);
  l_threshold                   VARCHAR2(2000);
  l_Bsc_Kpi_Color_Range_Rec     BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec;
  l_range_id                    NUMBER;
  l_is_succ                     BOOLEAN;
  l_user_id                     FND_USER.user_id%TYPE;
  l_kpi_measure_id  NUMBER;
  l_an_opt0         NUMBER;
  l_an_opt1         NUMBER;
  l_an_opt2         NUMBER;
  l_series_id       NUMBER;
  l_range_lud       DATE;

  CURSOR c_color_range_ids IS
    SELECT color_range_id, last_update_date
      FROM  bsc_color_type_props
      WHERE indicator = p_objective_id
      AND   NVL(kpi_measure_id, -999) = NVL(p_kpi_measure_id, -999)
      AND   NVL(property_value, -1) = DECODE(p_property_value, NULL, -1, p_property_value);

  CURSOR c_shared_obj IS
  SELECT indicator
  FROM   bsc_kpis_b
  WHERE  source_indicator = p_objective_id
  AND    share_flag = 2 -- shared objective.
  AND    prototype_flag <> 2;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorRangePub_CrtColorRng;

  FOR l_loop_count IN 1..p_threshold_color.COUNT LOOP

    l_threshold := p_threshold_color(l_loop_count);
    l_is_succ := Get_Next_Token(l_threshold,':',l_Bsc_Kpi_Color_Range_Rec(l_loop_count).color_range_sequence);
    l_is_succ := Get_Next_Token(l_threshold,':',l_Bsc_Kpi_Color_Range_Rec(l_loop_count).low);
    l_is_succ := Get_Next_Token(l_threshold,':',l_Bsc_Kpi_Color_Range_Rec(l_loop_count).high);
    l_is_succ := Get_Next_Token(l_threshold,':',l_Bsc_Kpi_Color_Range_Rec(l_loop_count).color_id);

  END LOOP;

  FOR l_color_range_ids_rec IN c_color_range_ids LOOP

    IF (p_time_stamp IS NOT NULL AND l_color_range_ids_rec.last_update_date IS NOT NULL
        AND p_time_stamp <> l_color_range_ids_rec.last_update_date) THEN
      FND_MESSAGE.SET_NAME('BSC','BSC_UPDATED_KPI_MEASURE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (p_kpi_measure_id IS NULL) THEN
      UPDATE bsc_color_type_props
      SET    last_update_date = sysdate
            ,last_updated_by  = FND_GLOBAL.USER_ID
      WHERE  indicator = p_objective_id
      AND    kpi_measure_id IS NULL;
    ELSE
      UPDATE bsc_color_type_props
      SET    last_update_date = sysdate
            ,last_updated_by  = FND_GLOBAL.USER_ID
      WHERE  indicator = p_objective_id
      AND    kpi_measure_id = p_kpi_measure_id
      AND    NVL(property_value, -1) = DECODE(p_property_value, NULL, -1, p_property_value);
    END IF;

    BSC_COLOR_RANGE_PVT.Delete_Color_Ranges(p_color_range_id  => l_color_range_ids_rec.color_range_id
                                           ,x_return_status   => x_return_status
                                           ,x_msg_count       => x_msg_count
                                           ,x_msg_data        => x_msg_data);
    IF (x_return_status <> 'S') THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_user_id := FND_GLOBAL.USER_ID;

    BSC_COLOR_RANGE_PVT.Create_Color_Range(p_range_id                 => l_color_range_ids_rec.color_range_id
                                          ,p_Bsc_Kpi_Color_Range_Rec  => l_Bsc_Kpi_Color_Range_Rec
                                          ,p_user_id                  => l_user_id
                                          ,x_return_status            => x_return_status
                                          ,x_msg_count                => x_msg_count
                                          ,x_msg_data                 => x_msg_data);
    IF (x_return_status <> 'S') THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- ppandey- Get all the shared objectives and cascade the ranges to it.
    -- This is existing approach also, and it allows us to provide functionality
    --      to support different threashold for shared objective if needed in future.

    IF (p_kpi_measure_id IS NOT NULL) THEN
      SELECT  am.analysis_option0, am.analysis_option1,
              am.analysis_option2, am.series_id
      INTO   l_an_opt0, l_an_opt1, l_an_opt2, l_series_id
      FROM   bsc_color_type_props cprop, bsc_kpi_analysis_measures_b am
      WHERE  cprop.kpi_measure_id = am.kpi_measure_id
      AND    cprop.indicator  = am.indicator
      AND    color_range_id = l_color_range_ids_rec.color_range_id;
    END IF;

    FOR c_shared IN c_shared_obj LOOP
      IF (p_kpi_measure_id IS NULL) THEN
        SELECT color_range_id
        INTO   l_range_id
        FROM   bsc_color_type_props
        WHERE  indicator = c_shared.indicator
        AND    kpi_measure_id IS NULL;

        UPDATE bsc_color_type_props
        SET    last_update_date = sysdate
              ,last_updated_by  = FND_GLOBAL.USER_ID
        WHERE  indicator = c_shared.indicator
        AND    kpi_measure_id IS NULL;
      ELSE
        SELECT kpi_measure_id
        INTO   l_kpi_measure_id
        FROM   bsc_kpi_analysis_measures_b
        WHERE  indicator= c_shared.indicator
        AND    analysis_option0 = l_an_opt0
        AND    analysis_option1 = l_an_opt1
        AND    analysis_option2 = l_an_opt2
        AND    series_id        = l_series_id;

        UPDATE bsc_color_type_props
        SET    last_update_date = sysdate
              ,last_updated_by  = FND_GLOBAL.USER_ID
        WHERE  indicator = c_shared.indicator
        AND    kpi_measure_id = l_kpi_measure_id
        AND    NVL(property_value, -1) = DECODE(p_property_value, NULL, -1, p_property_value);

        l_range_id := Get_Range_Id(c_shared.indicator, l_kpi_measure_id, p_property_value);
      END IF;

      BSC_COLOR_RANGE_PVT.Delete_Color_Ranges(p_color_range_id  => l_range_id
                                             ,x_return_status   => x_return_status
                                             ,x_msg_count       => x_msg_count
                                             ,x_msg_data        => x_msg_data);

      IF (x_return_status <> 'S') THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      BSC_COLOR_RANGE_PVT.Create_Color_Range(p_range_id                 => l_range_id
                                            ,p_Bsc_Kpi_Color_Range_Rec  => l_Bsc_Kpi_Color_Range_Rec
                                            ,p_user_id                  => l_user_id
                                            ,x_return_status            => x_return_status
                                            ,x_msg_count                => x_msg_count
                                            ,x_msg_data                 => x_msg_data);
      IF (x_return_status <> 'S') THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;

  END LOOP;

  IF(p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
       ,p_count     =>  x_msg_count
       ,p_data      =>  x_msg_data
      );
    END IF;
END Update_Color_Prop_Ranges;


/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Color_Prop_Ranges(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_objective_id        IN            NUMBER
 ,p_kpi_measure_id      IN            NUMBER
 ,p_color_type          IN            VARCHAR2  -- PERCENT_OF_TARGET, PERCENT_OF_KPI, CONSTANT
 ,p_threshold_color     IN            VARCHAR2
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

  l_Count                       NUMBER;
  l_value                       VARCHAR2(200);
  l_range_id                    NUMBER;
  l_Bsc_Kpi_Color_Range_Rec     BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec;
BEGIN

  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorRangePub_CrtColorRng;

  SELECT BSC_COLOR_RANGE_ID_S.NEXTVAL
  INTO   l_range_id
  FROM   DUAL;

  -- ppandey get all the shared objectives and cascade the ranges to it.
  -- This is existing approach also, and it allows us to provide functionality
  --      to support different threashold for shared objective if needed in future.
  --  This case is when weaghted threshold is defined for master Objective.

  BSC_COLOR_RANGE_PVT.Create_Color_Props(p_objective_id    => p_objective_id
                                        ,p_kpi_measure_id  => p_kpi_measure_id
                                        ,p_color_type      => p_color_type
                                        ,p_color_range_id  => l_range_id
                                        ,x_return_status   => x_return_status
                                        ,x_msg_count       => x_msg_count
                                        ,x_msg_data        => x_msg_data);

  IF (x_return_status <> 'S') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  Create_Color_Ranges(p_color_range_id   => l_range_id
                     ,p_threshold_color  => p_threshold_color
                     ,x_return_status    => x_return_status
                     ,x_msg_count        => x_msg_count
                     ,x_msg_data         => x_msg_data);

  IF (x_return_status <> 'S') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF(p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
        ROLLBACK TO BscColorRangePub_CrtColorRng;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_COLOR_RANGES_PUB.Create_Color_Prop_Ranges';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_COLOR_RANGES_PUB.Create_Color_Prop_Ranges';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_COLOR_RANGES_PUB.Create_Color_Prop_Ranges';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_COLOR_RANGES_PUB.Create_Color_Prop_Ranges';
    END IF;
END Create_Color_Prop_Ranges;

/************************************************************************************
 ************************************************************************************/
FUNCTION get_Color_Threshold_Array(
  p_threshold_color     IN            VARCHAR2
) RETURN THRESHOLD_ARRAY IS
  l_Count                       NUMBER;
  l_value                       VARCHAR2(200);
  l_threshold_color             VARCHAR2(2000);
  l_threshold_array             THRESHOLD_ARRAY;
BEGIN

  -- p_threshold_color value will be in format -> 1:20:345;2:40:345;3:80:456
  l_threshold_color := p_threshold_color;

  l_count := 1;

  l_threshold_array := THRESHOLD_ARRAY(1);
  WHILE (Get_Next_Token(l_threshold_color,';',l_value)) LOOP
    IF(l_count > 1) THEN
      l_threshold_array.EXTEND;
    END IF;
    l_threshold_array(l_count) := l_value;
    l_count := l_count + 1;
  END LOOP;

  RETURN l_threshold_array;
END get_Color_Threshold_Array;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Create_Color_Ranges(
  p_commit              IN            VARCHAR2 := FND_API.G_FALSE
 ,p_color_range_id      IN            NUMBER
 ,p_threshold_color     IN            VARCHAR2
 ,x_return_status       OUT NOCOPY    VARCHAR2
 ,x_msg_count           OUT NOCOPY    NUMBER
 ,x_msg_data            OUT NOCOPY    VARCHAR2
) IS

  l_Count                       NUMBER;
  l_value                       VARCHAR2(200);
  l_threshold_color             VARCHAR2(2000);
  l_Bsc_Kpi_Color_Range_Rec     BSC_COLOR_RANGES_PUB.Bsc_Color_Range_Rec;
  l_format_issue                BOOLEAN:= FALSE;
BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF(p_color_range_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_COLOR_RANGE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- p_threshold_color value will be in format -> 1:20:345;2:40:345;3:80:456
  l_threshold_color := p_threshold_color;

  l_count := 1;
  WHILE (Get_Next_Token(l_threshold_color,';',l_value)) LOOP
    IF (NOT Get_Next_Token(l_value,':',l_Bsc_Kpi_Color_Range_Rec(l_count).color_range_sequence)) THEN
      l_format_issue := TRUE;
    END IF;
    IF (NOT Get_Next_Token(l_value,':',l_Bsc_Kpi_Color_Range_Rec(l_count).low)) THEN
     l_format_issue := TRUE;
    END IF;
    IF (NOT Get_Next_Token(l_value,':',l_Bsc_Kpi_Color_Range_Rec(l_count).high)) THEN
     l_format_issue := TRUE;
    END IF;
    IF (NOT Get_Next_Token(l_value,':',l_Bsc_Kpi_Color_Range_Rec(l_count).color_id)) THEN
      l_format_issue := TRUE;
    END IF;
    l_count := l_count + 1;
  END LOOP;
    -- ppandey: get all the shared objectives and cascade the ranges to it.
    -- This is existing approach also, and it allows us to provide functionality
    --      to support different threashold for shared objective if needed in future.
    BSC_COLOR_RANGE_PVT.Create_Color_Range(p_range_id                 => p_color_range_id
                                          ,p_Bsc_Kpi_Color_Range_Rec  => l_Bsc_Kpi_Color_Range_Rec
                                          ,p_user_id                  => FND_GLOBAL.user_id
                                          ,x_return_status            => x_return_status
                                          ,x_msg_count                => x_msg_count
                                          ,x_msg_data                 => x_msg_data);
  IF (x_return_status <> 'S') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF(p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (x_msg_data IS NULL) THEN
        ROLLBACK TO BscColorRangePub_CrtColorRng;
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_return_status :=  FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (x_msg_data IS NULL) THEN
        FND_MSG_PUB.Count_And_Get
        (      p_encoded   =>  FND_API.G_FALSE
           ,   p_count     =>  x_msg_count
           ,   p_data      =>  x_msg_data
        );
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Color';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Color';
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' -> BSC_KPI_PUB.Create_Color';
    ELSE
        x_msg_data      :=  SQLERRM||' at BSC_KPI_PUB.Create_Color';
    END IF;
END Create_Color_Ranges;

/************************************************************************************
 ************************************************************************************/
PROCEDURE Delete_Color_Prop_Ranges (
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_objective_id        IN             NUMBER
 ,p_kpi_measure_id      IN             NUMBER  := NULL
 ,p_cascade_shared      IN             BOOLEAN
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
  l_range_id            NUMBER;

  l_objective_id    NUMBER;
  l_kpi_measure_id  NUMBER;
  l_dataset_id      NUMBER;
  l_an_opt0         NUMBER;
  l_an_opt1         NUMBER;
  l_an_opt2         NUMBER;
  l_series_id       NUMBER;
  CURSOR c_shared_obj IS
  SELECT indicator
  FROM   bsc_kpis_b
  WHERE  source_indicator = p_objective_id
  AND    share_flag = 2 -- shared objective.
  AND    prototype_flag <> 2;

  CURSOR c_all_ranges IS
  SELECT color_range_id
  FROM   bsc_color_type_props ct
  WHERE  indicator = l_objective_id;

  CURSOR c_measure_ranges IS
  SELECT color_range_id
  FROM   bsc_color_type_props ct
  WHERE  indicator = l_objective_id
  AND    kpi_measure_id = l_kpi_measure_id;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorRangePub_DelColorRng;

  IF(p_objective_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_OBJECTIVE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  l_objective_id := p_objective_id;
  l_kpi_measure_id := p_kpi_measure_id;
  -- ppandey get all the shared objectives and cascade the ranges to it.
  -- This is existing approach also, and it allows us to provide functionality
  --      to support different threashold for shared objective if needed in future.
  -- If measure threshold- delete for measures in shared objective also.
  -- If objective threshold- Delete for shared objective also.
  IF (l_kpi_measure_id IS NULL) THEN
    FOR c_ranges IN c_all_ranges LOOP
      l_range_id := c_ranges.color_range_id;
      BSC_COLOR_RANGE_PVT.Delete_Color_Prop_Ranges(p_color_range_id  => l_range_id
                                                  ,x_return_status   => x_return_status
                                                  ,x_msg_count       => x_msg_count
                                                  ,x_msg_data        => x_msg_data);
      IF (x_return_status <> 'S') THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
  ELSE
    FOR c_ranges IN c_measure_ranges LOOP
      l_range_id := c_ranges.color_range_id;
      BSC_COLOR_RANGE_PVT.Delete_Color_Prop_Ranges(p_color_range_id  => l_range_id
                                                  ,x_return_status   => x_return_status
                                                  ,x_msg_count       => x_msg_count
                                                  ,x_msg_data        => x_msg_data);
      IF (x_return_status <> 'S') THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
  END IF;

  IF (p_cascade_shared) THEN

    IF (l_kpi_measure_id IS NOT NULL) THEN
      SELECT am.analysis_option0,
             am.analysis_option1, am.analysis_option2, am.series_id
      INTO   l_an_opt0, l_an_opt1, l_an_opt2, l_series_id
      FROM   bsc_kpi_analysis_measures_b am
      WHERE  am.indicator = p_objective_id
      AND    am.kpi_measure_id = l_kpi_measure_id;
    END IF;

    FOR c_shared IN c_shared_obj LOOP
      l_objective_id := c_shared.indicator;
      IF (l_kpi_measure_id IS NULL) THEN
        FOR c_ranges IN c_all_ranges LOOP
          l_range_id := c_ranges.color_range_id;
          BSC_COLOR_RANGE_PVT.Delete_Color_Prop_Ranges(p_color_range_id  => l_range_id
                                                      ,x_return_status   => x_return_status
                                                      ,x_msg_count       => x_msg_count
                                                      ,x_msg_data        => x_msg_data);
          IF (x_return_status <> 'S') THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END LOOP;
      ELSE
        SELECT kpi_measure_id
        INTO   l_kpi_measure_id
        FROM   bsc_kpi_analysis_measures_b
        WHERE  indicator= c_shared.indicator
        AND    analysis_option0 = l_an_opt0
        AND    analysis_option1 = l_an_opt1
        AND    analysis_option2 = l_an_opt2
        AND    series_id        = l_series_id;

        FOR c_ranges IN c_measure_ranges LOOP
          l_range_id := c_ranges.color_range_id;
          BSC_COLOR_RANGE_PVT.Delete_Color_Prop_Ranges(p_color_range_id  => l_range_id
                                                      ,x_return_status   => x_return_status
                                                      ,x_msg_count       => x_msg_count
                                                      ,x_msg_data        => x_msg_data);
          IF (x_return_status <> 'S') THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END LOOP;
      END IF;
    END LOOP;

  END IF;
  IF(p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO BscColorRangePub_DelColorRng;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
       ,p_count     =>  x_msg_count
       ,p_data      =>  x_msg_data
      );
    END IF;
END Delete_Color_Prop_Ranges;

/************************************************************************************
************************************************************************************/
-- This functionality not used any where right now, will be used on remove of KPI or delete of Objective.
--   and changing color rollup type from weighted to something else
PROCEDURE Delete_Color_Prop_Ranges (
  p_commit              IN             VARCHAR2:= FND_API.G_FALSE
 ,p_color_range_id      IN             NUMBER
 ,x_return_status       OUT NOCOPY     VARCHAR2
 ,x_msg_count           OUT NOCOPY     NUMBER
 ,x_msg_data            OUT NOCOPY     VARCHAR2
) IS
  l_range_id        NUMBER;
  l_property_value  NUMBER;
  l_objective_id    NUMBER;
  l_kpi_measure_id  NUMBER;
  l_dataset_id      NUMBER;
  l_an_opt0         NUMBER;
  l_an_opt1         NUMBER;
  l_an_opt2         NUMBER;
  l_series_id       NUMBER;

  CURSOR c_shared_obj IS
  SELECT indicator
  FROM   bsc_kpis_b
  WHERE  source_indicator = l_objective_id
  AND    share_flag = 2 -- shared objective.
  AND    prototype_flag <> 2;

BEGIN
  FND_MSG_PUB.Initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT BscColorRangePub_DelColorRng;

  IF(p_color_range_id IS NULL) THEN
    FND_MESSAGE.SET_NAME('BSC','BSC_RANGE_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  -- ppandey get all the shared objectives and cascade the ranges to it.
  -- This is existing approach also, and it allows us to provide functionality
  --      to support different threashold for shared objective if needed in future.
  -- If measure threshold- delete for measures in shared objective also.
  -- If objective threshold- Delete for shared objective also.
  l_range_id := p_color_range_id;
  BSC_COLOR_RANGE_PVT.Delete_Color_Prop_Ranges(p_color_range_id  => l_range_id
                                              ,x_return_status   => x_return_status
                                              ,x_msg_count       => x_msg_count
                                              ,x_msg_data        => x_msg_data);
  IF (x_return_status <> 'S') THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT cprop.indicator, am.analysis_option0,
         am.analysis_option1, am.analysis_option2, am.series_id,
         cprop.property_value
  INTO   l_objective_id, l_an_opt0, l_an_opt1, l_an_opt2, l_series_id, l_property_value
  FROM   bsc_color_type_props cprop, bsc_kpi_analysis_measures_b am
  WHERE  cprop.kpi_measure_id = am.kpi_measure_id
  AND    color_range_id = p_color_range_id;

  FOR c_shared IN c_shared_obj LOOP
    SELECT kpi_measure_id
    INTO   l_kpi_measure_id
    FROM   bsc_kpi_analysis_measures_b
    WHERE  indicator= c_shared.indicator
    AND    analysis_option0 = l_an_opt0
    AND    analysis_option1 = l_an_opt1
    AND    analysis_option2 = l_an_opt2
    AND    series_id        = l_series_id;

    l_range_id := Get_Range_Id(c_shared.indicator, l_kpi_measure_id, l_property_value);

    BSC_COLOR_RANGE_PVT.Delete_Color_Prop_Ranges(p_color_range_id  => l_range_id
                                                ,x_return_status   => x_return_status
                                                ,x_msg_count       => x_msg_count
                                                ,x_msg_data        => x_msg_data);
    IF (x_return_status <> 'S') THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END LOOP;

  IF(p_commit = FND_API.G_TRUE) THEN
    COMMIT;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ROLLBACK TO BscColorRangePub_DelColorRng;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.Count_And_Get
      ( p_encoded   =>  FND_API.G_FALSE
       ,p_count     =>  x_msg_count
       ,p_data      =>  x_msg_data
      );
    END IF;
END Delete_Color_Prop_Ranges;

FUNCTION Get_Next_Token(
  p_token_string      IN OUT NOCOPY  VARCHAR2
 ,p_tokenizer         IN             VARCHAR2
 ,x_value             OUT    NOCOPY  VARCHAR2
) RETURN BOOLEAN IS
  l_position       NUMBER;
BEGIN
  IF (p_token_string IS NULL) THEN
    RETURN FALSE;
  END IF;

  l_position := INSTR(p_token_string, p_tokenizer);
  IF (l_position > 0) THEN
    x_value := TRIM(SUBSTR(p_token_string,1,l_position-1));
    p_token_string := TRIM(SUBSTR(p_token_string, l_position+1));
  ELSE
    x_value := TRIM(p_token_string);
    p_token_string := NULL;
  END IF;

  RETURN TRUE;
END Get_Next_Token;

FUNCTION Get_Color_Method(
  p_objective_id       IN     NUMBER
 ,p_kpi_measure_id     IN     NUMBER
) RETURN NUMBER IS
  l_color_method       NUMBER;
BEGIN
  IF (p_kpi_measure_id IS NULL) THEN
    SELECT weighted_color_method
    INTO   l_color_method
    FROM   bsc_kpis_b
    WHERE  indicator = p_objective_id;
  ELSE
    SELECT color_method
    INTO   l_color_method
    FROM   bsc_kpi_analysis_measures_b am
          ,bsc_sys_datasets_b ds
    WHERE  am.dataset_id = ds.dataset_id
    AND    kpi_measure_id = p_kpi_measure_id;
  END IF;
  RETURN l_color_method;
END;

END BSC_COLOR_RANGES_PUB;

/
