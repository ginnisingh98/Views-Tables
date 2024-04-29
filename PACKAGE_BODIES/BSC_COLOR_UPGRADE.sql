--------------------------------------------------------
--  DDL for Package Body BSC_COLOR_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_COLOR_UPGRADE" AS
/* $Header: BSCCOLUB.pls 120.11.12000000.1 2007/07/17 07:43:28 appldev noship $ */


FUNCTION set_kpi_measure_ids (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS

  CURSOR c_kpi_measure IS
    SELECT DISTINCT indicator, analysis_option0, analysis_option1, analysis_option2, series_id
    FROM bsc_kpi_analysis_measures_b
    WHERE kpi_measure_id IS NULL
    ORDER BY indicator, analysis_option0, analysis_option1, analysis_option2, series_id;
  l_kpi_measure_rec  c_kpi_measure%ROWTYPE;

  l_id  NUMBER;

BEGIN

  FOR l_kpi_measure_rec IN c_kpi_measure LOOP
    BEGIN
      SELECT bsc_kpi_measure_s.NEXTVAL INTO l_id from dual;
      UPDATE bsc_kpi_analysis_measures_b
        SET kpi_measure_id = l_id
        WHERE indicator = l_kpi_measure_rec.indicator
        AND   analysis_option0 = l_kpi_measure_rec.analysis_option0
        AND   analysis_option1 = l_kpi_measure_rec.analysis_option1
        AND   analysis_option2 = l_kpi_measure_rec.analysis_option2
        AND   series_id = l_kpi_measure_rec.series_id
        AND   kpi_measure_id IS NULL;
    EXCEPTION
      WHEN OTHERS THEN
       BSC_MESSAGE.Add( x_message => 'set_kpi_measure_ids() failed for objective= ' || l_kpi_measure_rec.indicator || ' :-' ||SQLERRM
                       , x_source  => 'BSCCOLUB.pls'
                       , x_mode    => 'I'
                       );
    END;
  END LOOP;

  --COMMIT;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    --ROLLBACK;
    x_error_msg := SQLERRM;
    x_error_msg := 'BSC_COLOR_UPGRADE.set_kpi_measure_ids -> ' || x_error_msg;
    RETURN FALSE;
END set_kpi_measure_ids;


FUNCTION set_default_color_rollup (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS
BEGIN

  UPDATE bsc_kpis_b
    SET color_rollup_type = 'DEFAULT_KPI',
        last_update_date = SYSDATE,
        last_updated_by = FND_GLOBAL.USER_ID
    WHERE color_rollup_type IS NULL;

  --COMMIT;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    --ROLLBACK;
    x_error_msg := SQLERRM;
    x_error_msg := 'BSC_COLOR_UPGRADE.set_default_color_rollup -> ' || x_error_msg;
    RETURN FALSE;
END set_default_color_rollup;


FUNCTION set_obj_prototype_color (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS
BEGIN
  UPDATE bsc_kpis_b
    SET prototype_color_id = DECODE(prototype_color,
                                    'G', 24865,
                                    'Y', 49919,
                                    'R', 192,
                                    'X', 8421504,
                                    8421504
                                    ),
        last_update_date = SYSDATE,
        last_updated_by = FND_GLOBAL.USER_ID
    WHERE prototype_color_id IS NULL;
  --COMMIT;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    --ROLLBACK;
    x_error_msg := SQLERRM;
    x_error_msg := 'BSC_COLOR_UPGRADE.set_obj_prototype_color -> ' || x_error_msg;
    RETURN FALSE;
END set_obj_prototype_color;


FUNCTION get_prototype_color (
  p_objective_id            IN NUMBER
, p_kpi_measure_id          IN NUMBER
, p_default_kpi_measure_id  IN NUMBER
) RETURN NUMBER
IS
  l_prototype_color_id  NUMBER;
BEGIN

  l_prototype_color_id := 24865;  -- default to Acceptable

  IF (p_kpi_measure_id = p_default_kpi_measure_id) THEN
    SELECT prototype_color_id
      INTO l_prototype_color_id
      FROM bsc_kpis_b
      WHERE indicator = p_objective_id;
  END IF;

  RETURN l_prototype_color_id;

EXCEPTION
  WHEN OTHERS THEN
    -- dont let the caller fail
    RETURN l_prototype_color_id;
END get_prototype_color;


FUNCTION get_color_by_total (
  p_objective_id            IN NUMBER
, p_kpi_measure_id          IN NUMBER
, p_default_kpi_measure_id  IN NUMBER
) RETURN NUMBER
IS
  l_color_by_total  NUMBER;
BEGIN

  l_color_by_total := 1;  -- default to ALL

  IF (p_kpi_measure_id = p_default_kpi_measure_id) THEN
    SELECT property_value
      INTO l_color_by_total
      FROM bsc_kpi_properties
      WHERE indicator = p_objective_id
      AND   property_code = 'COLOR_BY_TOTAL';
  END IF;

  RETURN l_color_by_total;

EXCEPTION
  WHEN OTHERS THEN
    -- dont let the caller fail
    RETURN l_color_by_total;
END get_color_by_total;


FUNCTION get_disable_color (
  p_objective_id            IN NUMBER
, p_kpi_measure_id          IN NUMBER
, p_default_kpi_measure_id  IN NUMBER
) RETURN VARCHAR2
IS
  l_disable_color  VARCHAR2(1);
  l_source         VARCHAR2(10);
  l_obj_sh_name    BSC_KPIS_B.short_name%TYPE;

  CURSOR c_measure_source(pkpi_measure_id NUMBER) IS
    SELECT source
      FROM bsc_sys_datasets_b dts,
           bsc_kpi_analysis_measures_b am
      WHERE dts.dataset_id = am.dataset_id
      AND   am.kpi_measure_id = pkpi_measure_id;

  CURSOR c_objective_short_name(pIndicator NUMBER) IS
    SELECT short_name
      FROM bsc_kpis_b
      WHERE indicator = pIndicator;
BEGIN

  l_disable_color := 'T';  -- default to TRUE
  l_obj_sh_name := NULL;

  IF c_measure_source%ISOPEN THEN
    CLOSE c_measure_source;
  END IF;
  OPEN c_measure_source(p_kpi_measure_id);
  IF c_measure_source%NOTFOUND THEN
    RETURN l_disable_color;
  END IF;
  FETCH c_measure_source INTO l_source;
  CLOSE c_measure_source;

  IF c_objective_short_name%ISOPEN THEN
    CLOSE c_objective_short_name;
  END IF;
  OPEN c_objective_short_name(p_objective_id);
  IF c_objective_short_name%NOTFOUND THEN
    RETURN l_disable_color;
  END IF;
  FETCH c_objective_short_name INTO l_obj_sh_name;
  CLOSE c_objective_short_name;

  IF l_obj_sh_name IS NULL AND l_source = 'PMF' THEN
    -- Only those BIS KPIs which are non-AG and non-S2E will have color disabled
    l_disable_color := 'T';
  ELSE
    IF (p_kpi_measure_id = p_default_kpi_measure_id) THEN
      l_disable_color := 'F';
    END IF;
  END IF;

  RETURN l_disable_color;

EXCEPTION
  WHEN OTHERS THEN
    IF c_measure_source%ISOPEN THEN
      CLOSE c_measure_source;
    END IF;
    IF c_objective_short_name%ISOPEN THEN
      CLOSE c_objective_short_name;
    END IF;
    -- dont let the caller fail
    RETURN l_disable_color;
END get_disable_color;


FUNCTION get_apply_color_flag (
  p_objective_id            IN NUMBER
, p_kpi_measure_id          IN NUMBER
) RETURN NUMBER
IS
  CURSOR c_objective_type(p_indicator NUMBER) IS
    SELECT indicator_type
      FROM bsc_kpis_b
      WHERE indicator = p_indicator;
  l_apply_color_flag  NUMBER;
  l_multi_series      NUMBER;
BEGIN

  l_apply_color_flag := 0;  -- default to FALSE
  l_multi_series := 0;

  IF c_objective_type%ISOPEN THEN
    CLOSE c_objective_type;
  END IF;
  OPEN c_objective_type(p_objective_id);
  FETCH c_objective_type INTO l_multi_series;
  CLOSE c_objective_type;

  IF (l_multi_series = 10) THEN
    -- For multi-series, get the budget_flag from bsc_kpi_analysis_measures_b and push to KPI level
    SELECT budget_flag INTO l_apply_color_flag
      FROM bsc_kpi_analysis_measures_b
      WHERE indicator = p_objective_id
      AND   kpi_measure_id = p_kpi_measure_id;
  ELSE
    -- For single-bar Objective, get the apply_color_flag from Objective and push to KPI level
    SELECT apply_color_flag INTO l_apply_color_flag
      FROM bsc_kpis_b
      WHERE indicator = p_objective_id;
  END IF;

  RETURN l_apply_color_flag;

EXCEPTION
  WHEN OTHERS THEN
    IF (c_objective_type%ISOPEN) THEN
      CLOSE c_objective_type;
    END IF;
    -- dont let the caller fail
    RETURN l_apply_color_flag;
END get_apply_color_flag;


FUNCTION set_kpi_measure_props (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS
  CURSOR c_kpi_measure IS
    SELECT indicator, kpi_measure_id
    FROM bsc_kpi_analysis_measures_b
    ORDER BY kpi_measure_id;
  l_kpi_measure_rec        c_kpi_measure%ROWTYPE;

  CURSOR c_kpi_measure_props_exist(p_indicator NUMBER, p_kpi_measure_id NUMBER) IS
    SELECT COUNT(1)
    FROM bsc_kpi_measure_props
    WHERE indicator = p_indicator
    AND   kpi_measure_id = p_kpi_measure_id;

  l_kpi_measure_props_rec     BSC_KPI_MEASURE_PROPS_PUB.kpi_measure_props_rec;
  l_default_kpi_measure_id    NUMBER;
  l_kpi_measure_props_exist   NUMBER;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(4000);

BEGIN

  FOR l_kpi_measure_rec IN c_kpi_measure LOOP

    BEGIN
      l_kpi_measure_props_exist := 0;

      IF c_kpi_measure_props_exist%ISOPEN THEN
        CLOSE c_kpi_measure_props_exist;
      END IF;
      OPEN c_kpi_measure_props_exist(l_kpi_measure_rec.indicator, l_kpi_measure_rec.kpi_measure_id);
      FETCH c_kpi_measure_props_exist INTO l_kpi_measure_props_exist;
      IF c_kpi_measure_props_exist%NOTFOUND THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      CLOSE c_kpi_measure_props_exist;

      IF l_kpi_measure_props_exist = 0 THEN

        l_kpi_measure_props_rec.objective_id   := l_kpi_measure_rec.indicator;
        l_kpi_measure_props_rec.kpi_measure_id := l_kpi_measure_rec.kpi_measure_id;
        l_kpi_measure_props_rec.prototype_trend := BSC_KPI_MEASURE_PROPS_PUB.C_TREND_UNACC_DECREASE;
        l_kpi_measure_props_rec.disable_color := 'T';
        l_kpi_measure_props_rec.disable_trend := 'T';
        l_kpi_measure_props_rec.prototype_color := 24865;
        l_kpi_measure_props_rec.color_by_total := 1;
        l_kpi_measure_props_rec.created_by := FND_GLOBAL.USER_ID;
        l_kpi_measure_props_rec.creation_date := SYSDATE;
        l_kpi_measure_props_rec.last_updated_by := FND_GLOBAL.USER_ID;
        l_kpi_measure_props_rec.last_update_date := SYSDATE;
        l_kpi_measure_props_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

        l_kpi_measure_props_rec.apply_color_flag := get_apply_color_flag
                                                    ( l_kpi_measure_rec.indicator
                                                    , l_kpi_measure_rec.kpi_measure_id
                                                    );

        l_default_kpi_measure_id := BSC_COLOR_CALC_UTIL.Get_Default_Kpi_Measure_Id(l_kpi_measure_rec.indicator);
        IF l_default_kpi_measure_id IS NULL THEN
          x_error_msg := 'l_default_kpi_measure_id is NULL for Objective = ' || l_kpi_measure_rec.indicator || ' ;';
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF l_default_kpi_measure_id IS NOT NULL THEN
          l_kpi_measure_props_rec.disable_color := get_disable_color
  					         ( l_kpi_measure_rec.indicator
  					         , l_kpi_measure_rec.kpi_measure_id
  					         , l_default_kpi_measure_id
  					         );

          l_kpi_measure_props_rec.prototype_color := get_prototype_color
  					           ( l_kpi_measure_rec.indicator
  						   , l_kpi_measure_rec.kpi_measure_id
  						   , l_default_kpi_measure_id
  						   );

          l_kpi_measure_props_rec.color_by_total := get_color_by_total
  						  ( l_kpi_measure_rec.indicator
  						  , l_kpi_measure_rec.kpi_measure_id
  						  , l_default_kpi_measure_id
  						  );
        END IF;

        BSC_KPI_MEASURE_PROPS_PUB.Create_Kpi_Measure_Props
        ( p_commit           => FND_API.G_FALSE
        , p_kpi_measure_rec  => l_kpi_measure_props_rec
        , p_cascade_shared   => FALSE
        , x_return_status    => l_return_status
        , x_msg_count        => l_msg_count
        , x_msg_data         => l_msg_data
        );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_error_msg := l_msg_data;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
       BSC_MESSAGE.Add( x_message => 'set_kpi_measure_props() failed for objective= ' || l_kpi_measure_rec.indicator || ' :-' ||SQLERRM
                     , x_source  => 'BSCCOLUB.pls'
                     , x_mode    => 'I'
                     );
    END;
  END LOOP;

  --COMMIT;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    --ROLLBACK;
    IF c_kpi_measure_props_exist%ISOPEN THEN
      CLOSE c_kpi_measure_props_exist;
    END IF;
    IF (x_error_msg IS NULL) THEN
      x_error_msg := SQLERRM;
    END IF;
    x_error_msg := 'BSC_COLOR_UPGRADE.set_kpi_measure_props -> ' || x_error_msg;
    RETURN FALSE;
END set_kpi_measure_props;


FUNCTION set_kpimeasure_prototype_flag (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS
  CURSOR c_obj_prototype_flag IS
    SELECT DISTINCT indicator objective_id
         , prototype_flag prototype_flag
    FROM   bsc_kpis_b
    WHERE  prototype_flag <> 2;
  l_obj_prototype_flag_rec  c_obj_prototype_flag%ROWTYPE;
  l_default_kpi_measure_id  bsc_kpi_measure_props.kpi_measure_id%TYPE;
  l_update_flag             BOOLEAN;
  l_count                   NUMBER;

BEGIN

  FOR l_obj_prototype_flag_rec IN c_obj_prototype_flag LOOP

    BEGIN

      l_update_flag := FALSE;

      SELECT COUNT(1)
        INTO  l_count
        FROM  bsc_sys_kpi_colors
        WHERE kpi_measure_id IS NOT NULL
        AND   indicator = l_obj_prototype_flag_rec.objective_id;

      IF l_count = 0 THEN
        l_update_flag := TRUE;  -- either first time upgrade or no color has been calculated as yet.
      END IF;

      IF l_update_flag THEN

        l_default_kpi_measure_id := BSC_COLOR_CALC_UTIL.Get_Default_Kpi_Measure_Id(l_obj_prototype_flag_rec.objective_id);
        IF l_default_kpi_measure_id IS NULL THEN
          x_error_msg := 'l_default_kpi_measure_id is NULL for Objective = ' || l_obj_prototype_flag_rec.objective_id || ' ;';
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- We will update bsc_kpi_analysis_measures_b.prototype_flag always irrespective of the fact
        -- that whether this script has run before or not. We cannot check for prototype_flag = NULL
        -- before updating this column, since this column will not be NULL because of a generic UPDATE
        -- in bscup.sql to value 0. Anyway, updating this column everytime will not affect since we
        -- are updating it to 7 (color re-calculate). Only for default KPI, we are picking the flag
        -- from the Objective level value when it is 0.
        IF l_default_kpi_measure_id IS NOT NULL THEN

          UPDATE bsc_kpi_analysis_measures_b
          SET prototype_flag = DECODE(l_obj_prototype_flag_rec.prototype_flag,
                                         0, 0,
                                         7)
            WHERE indicator = l_obj_prototype_flag_rec.objective_id
            AND   kpi_measure_id = l_default_kpi_measure_id;

          UPDATE bsc_kpi_analysis_measures_b
            SET prototype_flag = 7
            WHERE indicator = l_obj_prototype_flag_rec.objective_id
            AND   kpi_measure_id <> l_default_kpi_measure_id;

        ELSE

          UPDATE bsc_kpi_analysis_measures_b
            SET prototype_flag = 7
            WHERE indicator = l_obj_prototype_flag_rec.objective_id;

        END IF;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
       BSC_MESSAGE.Add( x_message => 'set_kpimeasure_prototype_flag() failed for objective= ' || l_obj_prototype_flag_rec.objective_id || ' :-' ||SQLERRM
                       , x_source  => 'BSCCOLUB.pls'
                       , x_mode    => 'I'
                       );
    END;

  END LOOP;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    --ROLLBACK;
    IF (x_error_msg IS NULL) THEN
      x_error_msg := SQLERRM;
    END IF;
    x_error_msg := 'BSC_COLOR_UPGRADE.set_kpimeasure_prototype_flag -> ' || x_error_msg;
    RETURN FALSE;
END set_kpimeasure_prototype_flag;


FUNCTION set_kpi_measure_default_calc (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS
  CURSOR c_obj_default_calc IS
    SELECT indicator objective_id
         , calculation_id
    FROM bsc_kpi_calculations
    WHERE default_value = 1;

  l_obj_default_calc_rec    c_obj_default_calc%ROWTYPE;
  l_default_kpi_measure_id  bsc_kpi_measure_props.kpi_measure_id%TYPE;

BEGIN

  FOR l_obj_default_calc_rec IN c_obj_default_calc LOOP
    BEGIN

      l_default_kpi_measure_id := BSC_COLOR_CALC_UTIL.Get_Default_Kpi_Measure_Id(l_obj_default_calc_rec.objective_id);
      IF l_default_kpi_measure_id IS NULL THEN
        x_error_msg := 'l_default_kpi_measure_id is NULL for Objective = ' || l_obj_default_calc_rec.objective_id || ' ;';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_default_kpi_measure_id IS NOT NULL THEN
        UPDATE bsc_kpi_measure_props
          SET default_calculation = l_obj_default_calc_rec.calculation_id,
              last_update_date = SYSDATE,
              last_updated_by = FND_GLOBAL.USER_ID
          WHERE indicator = l_obj_default_calc_rec.objective_id
          AND   kpi_measure_id = l_default_kpi_measure_id
          AND   default_calculation IS NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
       BSC_MESSAGE.Add( x_message => 'set_kpi_measure_default_calc() failed for objective= ' || l_obj_default_calc_rec.objective_id || ' :-' ||SQLERRM
                     , x_source  => 'BSCCOLUB.pls'
                     , x_mode    => 'I'
                     );
    END;

  END LOOP;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    --ROLLBACK;
    IF (x_error_msg IS NULL) THEN
      x_error_msg := SQLERRM;
    END IF;
    x_error_msg := 'BSC_COLOR_UPGRADE.set_kpi_measure_default_calc -> ' || x_error_msg;
    RETURN FALSE;
END set_kpi_measure_default_calc;


FUNCTION set_default_kpi_measure_id (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS
  CURSOR c_default_kpi_color IS
    SELECT DISTINCT indicator
    FROM bsc_sys_kpi_colors
    ORDER BY indicator;
  l_default_kpi_color  c_default_kpi_color%ROWTYPE;

  l_default_kpi_measure_id  NUMBER;
BEGIN

  FOR l_default_kpi_color IN c_default_kpi_color LOOP
    BEGIN

      l_default_kpi_measure_id := BSC_COLOR_CALC_UTIL.Get_Default_Kpi_Measure_Id(l_default_kpi_color.indicator);
      IF l_default_kpi_measure_id IS NULL THEN
        x_error_msg := 'l_default_kpi_measure_id is NULL for Objective = ' || l_default_kpi_color.indicator || ' ;';
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF l_default_kpi_measure_id IS NOT NULL THEN
        UPDATE bsc_sys_kpi_colors
          SET kpi_measure_id = l_default_kpi_measure_id
          WHERE indicator = l_default_kpi_color.indicator
          AND   kpi_measure_id IS NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
       BSC_MESSAGE.Add( x_message => 'set_default_kpi_measure_id() failed for objective= ' || l_default_kpi_color.indicator || ' :-' ||SQLERRM
                     , x_source  => 'BSCCOLUB.pls'
                     , x_mode    => 'I'
                     );
    END;

  END LOOP;

  --COMMIT;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    --ROLLBACK;
    IF (x_error_msg IS NULL) THEN
      x_error_msg := SQLERRM;
    END IF;
    x_error_msg := 'BSC_COLOR_UPGRADE.set_default_kpi_measure_id -> ' || x_error_msg;
    RETURN FALSE;
END set_default_kpi_measure_id;


FUNCTION set_objective_color (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS
  CURSOR c_obj_colors_count IS
    SELECT COUNT(1)
    FROM bsc_sys_objective_colors;

  CURSOR c_kpi_colors_count IS
    SELECT COUNT(1)
    FROM bsc_sys_kpi_colors;

  l_obj_color_count  NUMBER := 0;
  l_kpi_color_count  NUMBER := 0;
BEGIN

  IF c_obj_colors_count%ISOPEN THEN
    CLOSE c_obj_colors_count;
  END IF;
  OPEN c_obj_colors_count;
  FETCH c_obj_colors_count INTO l_obj_color_count;
  IF c_obj_colors_count%NOTFOUND THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE c_obj_colors_count;

  IF l_obj_color_count = 0 THEN

    IF c_kpi_colors_count%ISOPEN THEN
      CLOSE c_kpi_colors_count;
    END IF;
    OPEN c_kpi_colors_count;
    FETCH c_kpi_colors_count INTO l_kpi_color_count;
    IF c_kpi_colors_count%NOTFOUND THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE c_kpi_colors_count;

    IF l_kpi_color_count > 0 THEN
      BEGIN

        INSERT INTO
          bsc_sys_objective_colors
          ( tab_id
          , indicator
          , dim_level1
          , dim_level2
          , dim_level3
          , dim_level4
          , dim_level5
          , dim_level6
          , dim_level7
          , dim_level8
          , period_id
          , obj_color
          , obj_trend
          , driving_kpi_measure_id
          )
          SELECT
            tab_id
          , indicator
          , dim_level1
          , dim_level2
          , dim_level3
          , dim_level4
          , dim_level5
          , dim_level6
          , dim_level7
          , dim_level8
          , period_id
          , kpi_color
          , kpi_trend
          , kpi_measure_id
          FROM bsc_sys_kpi_colors
          ORDER BY tab_id, indicator;
      EXCEPTION
        WHEN OTHERS THEN
         BSC_MESSAGE.Add( x_message => 'set_objective_color() failed upgrade data to bsc_sys_objective_colors' ||SQLERRM
                        , x_source  => 'BSCCOLUB.pls'
                        , x_mode    => 'I'
                        );
    END;

    END IF;

  END IF;

  --COMMIT;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    --ROLLBACK;
    IF c_obj_colors_count%ISOPEN THEN
      CLOSE c_obj_colors_count;
    END IF;
    IF c_kpi_colors_count%ISOPEN THEN
      CLOSE c_kpi_colors_count;
    END IF;
    IF (x_error_msg IS NULL) THEN
      x_error_msg := SQLERRM;
    END IF;
    x_error_msg := 'BSC_COLOR_UPGRADE.set_objective_color -> ' || x_error_msg;
    RETURN FALSE;
END set_objective_color;



FUNCTION upgrade_kpi_measures (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS

BEGIN

  -- Set KPI_Measure_Ids in BSC_KPI_ANALYSIS_MEASURES_B based on sequence
  IF NOT set_kpi_measure_ids(x_error_msg) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Populate BSC_KPI_MEASURE_PROPS
  IF NOT set_kpi_measure_props(x_error_msg) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Set Prototype Flag at KPI level
  IF NOT set_kpimeasure_prototype_flag(x_error_msg) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Set Default Calculation at KPI level
  IF NOT set_kpi_measure_default_calc(x_error_msg) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --COMMIT;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    --ROLLBACK;
    x_error_msg := 'BSC_COLOR_UPGRADE.upgrade_kpi_measures -> ' || x_error_msg;
    RETURN FALSE;
END upgrade_kpi_measures;


FUNCTION upgrade_objectives (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS

BEGIN

  -- Set BSC_KPIS_B.COLOR_ROLLUP_TYPE as DEFAULT_KPI for all existing Objectives
  IF NOT set_default_color_rollup(x_error_msg) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Set BSC_KPIS_B.PROTOTYPE_COLOR to BSC_SYS_COLORS_B.COLOR_ID instead of G,Y,R,X
  IF NOT set_obj_prototype_color(x_error_msg) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --COMMIT;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    --ROLLBACK;
    x_error_msg := 'BSC_COLOR_UPGRADE.upgrade_objectives -> ' || x_error_msg;
    RETURN FALSE;
END upgrade_objectives;


FUNCTION upgrade_calculated_colors (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS

BEGIN

  -- We need to populate BSC_SYS_KPI_COLORS.KPI_MEASURE_ID with the default KPI for the
  -- corresponding Objective.
  IF NOT set_default_kpi_measure_id(x_error_msg) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- From BSC_SYS_KPI_COLORS, we need to move all the colors to BSC_SYS_OBJECTIVE_COLORS
  -- (based on DEFAULT_KPI rollup). We dont actually need to find the default KPI for an Objective.
  -- Just simply moving all rows from BSC_SYS_KPI_COLORS to  BSC_SYS_OBJECTIVE_COLORS will do.
  IF NOT set_objective_color(x_error_msg) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --COMMIT;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    --ROLLBACK;
    x_error_msg := 'BSC_COLOR_UPGRADE.upgrade_calculated_colors -> ' || x_error_msg;
    RETURN FALSE;
END upgrade_calculated_colors;


FUNCTION upgrade_ag_calculated_kpis (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS
  CURSOR c_calc_meas IS
    SELECT bis_ind.short_name short_name,
           bsc_dts.name name,
           bsc_dts.help description,
           bsc_dts.dataset_id dataset_id,
           bis_ind.actual_data_source actual_data_source
    FROM bis_indicators bis_ind,
         bsc_sys_datasets_vl bsc_dts
    WHERE bis_ind.dataset_id = bsc_dts.dataset_id
    AND   bis_ind.measure_type = 'CDS_CALC';

  CURSOR c_region_obj(p_region_code VARCHAR2) IS
    SELECT attribute8
    FROM ak_regions
    WHERE region_code = p_region_code
    AND   attribute10 = 'BSC_DATA_SOURCE'
    AND   attribute8 IS NOT NULL;

  l_region_code   AK_REGIONS.region_code%TYPE;
  l_attribute8    AK_REGIONS.attribute8%TYPE;
  l_objective_id  NUMBER;
  l_anal_opt_rec  BSC_ANALYSIS_OPTION_PUB.bsc_option_rec_type;
  x_anal_opt_rec  BSC_ANALYSIS_OPTION_PUB.bsc_option_rec_type;
  x_return_status VARCHAR2(1);
  x_msg_count     NUMBER;

BEGIN
  -- Upgrade AG reports' calculated KPIs to have an entry as KPI measure and
  -- populate default color properties.

  FOR c_calc_meas_rec IN c_calc_meas LOOP
    BEGIN

      IF c_calc_meas_rec.actual_data_source IS NOT NULL THEN

        l_region_code := NULL;
        l_attribute8  := NULL;

        l_region_code := SUBSTR(c_calc_meas_rec.actual_data_source, 1, INSTR(c_calc_meas_rec.actual_data_source, '.') - 1);

        IF l_region_code IS NOT NULL THEN
          FOR c_region_obj_rec IN c_region_obj(l_region_code) LOOP

            l_attribute8 := c_region_obj_rec.attribute8;
            l_objective_id := TO_NUMBER(SUBSTR(l_attribute8, 1, INSTR(l_attribute8, '.') - 1));

            l_anal_opt_rec.Bsc_Kpi_Id                 := l_objective_id;
  	  l_anal_opt_rec.Bsc_Dataset_Id             := c_calc_meas_rec.dataset_id;
  	  l_anal_opt_rec.Bsc_Dataset_Default_Value  := 1;
  	  l_anal_opt_rec.Bsc_Measure_Long_Name      := c_calc_meas_rec.name;
            l_anal_opt_rec.Bsc_Measure_Help           := c_calc_meas_rec.description;

            BSC_ANALYSIS_OPTION_PUB.Create_Data_Series (
  	    p_commit        => FND_API.G_FALSE
  	  , p_anal_opt_rec  => l_anal_opt_rec
  	  , x_anal_opt_rec  => x_anal_opt_rec
  	  , x_return_status => x_return_status
  	  , x_msg_count     => x_msg_count
  	  , x_msg_data      => x_error_msg
            );
            IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
  	    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

          END LOOP;
        END IF;

      END IF;
    EXCEPTION
      WHEN OTHERS THEN
       BSC_MESSAGE.Add( x_message => 'upgrade_ag_calculated_kpis() failed for Measure actual data source = ' || c_calc_meas_rec.actual_data_source || ' :-' ||SQLERRM
                     , x_source  => 'BSCCOLUB.pls'
                     , x_mode    => 'I'
                     );
    END;

  END LOOP;

  --COMMIT;
  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    --ROLLBACK;
    x_error_msg := 'BSC_COLOR_UPGRADE.upgrade_ag_calculated_kpis -> ' || x_error_msg;
    RETURN FALSE;
END upgrade_ag_calculated_kpis;


FUNCTION upgrade_sys_colors (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

CURSOR c_sys_init_color IS
SELECT property_code, property_value, created_by,
       creation_date, last_updated_by, last_update_date, last_update_login
FROM bsc_sys_init
WHERE property_code IN ('LGREEN_COLOR', 'GREEN_COLOR', 'LYELLOW_COLOR'
                        ,'YELLOW_COLOR', 'LRED_COLOR', 'RED_COLOR'
                        ,'LGRAY_COLOR', 'DGRAY_COLOR');
BEGIN
  FOR c_init_colors IN c_sys_init_color LOOP
    BEGIN
      IF (c_init_colors.property_code = 'LGREEN_COLOR') THEN
        UPDATE bsc_sys_colors_b
        SET    user_forecast_color = c_init_colors.property_value,
               last_update_date = SYSDATE,
               last_updated_by = FND_GLOBAL.USER_ID
        WHERE  perf_sequence = (SELECT
               MIN(perf_sequence) FROM bsc_sys_colors_b);
      ELSIF (c_init_colors.property_code = 'GREEN_COLOR') THEN
        UPDATE bsc_sys_colors_b
        SET    user_color = c_init_colors.property_value,
               last_update_date = SYSDATE,
               last_updated_by = FND_GLOBAL.USER_ID
        WHERE  perf_sequence = (SELECT
               MIN(perf_sequence) FROM bsc_sys_colors_b);
      ELSIF (c_init_colors.property_code = 'LYELLOW_COLOR') THEN
        UPDATE bsc_sys_colors_b
        SET    user_forecast_color = c_init_colors.property_value,
               last_update_date = SYSDATE,
               last_updated_by = FND_GLOBAL.USER_ID
        WHERE  short_name = 'AVERAGE_COLOR';
      ELSIF (c_init_colors.property_code = 'YELLOW_COLOR') THEN
        UPDATE bsc_sys_colors_b
        SET    user_color = c_init_colors.property_value,
               last_update_date = SYSDATE,
               last_updated_by = FND_GLOBAL.USER_ID
        WHERE  short_name = 'AVERAGE_COLOR';
      ELSIF (c_init_colors.property_code = 'LRED_COLOR') THEN
        UPDATE bsc_sys_colors_b
        SET    user_forecast_color = c_init_colors.property_value,
               last_update_date = SYSDATE,
               last_updated_by = FND_GLOBAL.USER_ID
        WHERE  perf_sequence = (SELECT
               MAX(perf_sequence) FROM bsc_sys_colors_b);
      ELSIF (c_init_colors.property_code = 'RED_COLOR') THEN
        UPDATE bsc_sys_colors_b
        SET    user_color = c_init_colors.property_value,
               last_update_date = SYSDATE,
               last_updated_by = FND_GLOBAL.USER_ID
        WHERE  perf_sequence = (SELECT
               MAX(perf_sequence) FROM bsc_sys_colors_b);
      ELSIF (c_init_colors.property_code = 'LGRAY_COLOR') THEN
          UPDATE bsc_sys_colors_b
          SET    user_forecast_color = c_init_colors.property_value,
                 last_update_date = SYSDATE,
                 last_updated_by = FND_GLOBAL.USER_ID
          WHERE  perf_sequence IS NULL;
      ELSIF (c_init_colors.property_code = 'DGRAY_COLOR') THEN
          UPDATE bsc_sys_colors_b
          SET    user_color = c_init_colors.property_value,
                 last_update_date = SYSDATE,
                 last_updated_by = FND_GLOBAL.USER_ID
          WHERE  perf_sequence IS NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
       BSC_MESSAGE.Add( x_message => 'upgrade_sys_colors() system color upgraded fail for = ' || c_init_colors.property_code || ' :-' ||SQLERRM
                      , x_source  => 'BSCCOLUB.pls'
                      , x_mode    => 'I'
                      );
    END;
  END LOOP;

  -- Delete the data moved.
  BEGIN
    DELETE bsc_sys_init
    WHERE property_code IN ('LGREEN_COLOR', 'GREEN_COLOR', 'LYELLOW_COLOR'
                           ,'YELLOW_COLOR', 'LRED_COLOR', 'RED_COLOR'
                           ,'LGRAY_COLOR', 'DGRAY_COLOR');
  EXCEPTION
      WHEN OTHERS THEN
       BSC_MESSAGE.Add( x_message => 'set_kpi_measure_ids() failed for delete of old system colors :-' ||SQLERRM
                     , x_source  => 'BSCCOLUB.pls'
                     , x_mode    => 'I'
                     );
    END;
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    x_error_msg := 'BSC_COLOR_UPGRADE.upgrade_sys_colors -> ' || SQLERRM;
    RETURN FALSE;
END upgrade_sys_colors;


PROCEDURE create_color_thresholds (
  p_objective_id     IN NUMBER
, p_kpi_measure_id   IN NUMBER
, p_color_method     IN NUMBER
, p_color_type       IN VARCHAR2
, p_m1_l1            IN NUMBER
, p_m1_l2            IN NUMBER
, p_m2_l1            IN NUMBER
, p_m2_l2            IN NUMBER
, p_m3_l1            IN NUMBER
, p_m3_l2            IN NUMBER
, p_m3_l3            IN NUMBER
, p_m3_l4            IN NUMBER
)
IS
  l_threshold       THRESHOLD_ARRAY;
  l_property_value  NUMBER;
  x_return_status   VARCHAR2(1);
  x_msg_count       NUMBER(3);
  x_msg_data        VARCHAR2(2000);
BEGIN
  IF (p_color_method = 1 OR p_color_method IS NULL) THEN  -- Target Met Above plan
    l_threshold := threshold_array(1,2,3);
    l_threshold(1) := '1::'|| p_m1_l2 ||':'|| 192; -- Red
    l_threshold(2) := '2:'|| p_m1_l2||':'|| p_m1_l1 ||':'|| 49919; -- Yellow
    l_threshold(3) := '3:'|| p_m1_l1||'::'|| 24865;             --Green
    IF (p_color_method IS NULL) THEN
      l_property_value := 1;
    END IF;
    BSC_COLOR_RANGES_PUB.Create_Color_Prop_Ranges(p_objective_id    =>  p_objective_id
                                                 ,p_kpi_measure_id  =>  p_kpi_measure_id
                                                 ,p_color_type      =>  p_color_type
                                                 ,p_threshold_color =>  l_threshold
                                                 ,p_property_value  =>  l_property_value
                                                 ,x_return_status   =>  x_return_status
                                                 ,x_msg_count       =>  x_msg_count
                                                 ,x_msg_data        =>  x_msg_data );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  IF (p_color_method = 2 OR p_color_method IS NULL) THEN  -- Target Met Below plan
    l_threshold := threshold_array(1,2,3);
    l_threshold(1) := '1::'|| p_m2_l2 ||':'|| 24865; -- Green
    l_threshold(2) := '2:'|| p_m2_l2||':'|| p_m2_l1 ||':'|| 49919; -- Yellow
    l_threshold(3) := '3:'||p_m2_l1||'::'|| 192;             --Red
    IF (p_color_method IS NULL) THEN
      l_property_value := 2;
    END IF;
    BSC_COLOR_RANGES_PUB.Create_Color_Prop_Ranges(p_objective_id    =>  p_objective_id
                                                 ,p_kpi_measure_id  =>  p_kpi_measure_id
                                                 ,p_color_type      =>  p_color_type
                                                 ,p_threshold_color =>  l_threshold
                                                 ,p_property_value  =>  l_property_value
                                                 ,x_return_status   =>  x_return_status
                                                 ,x_msg_count       =>  x_msg_count
                                                 ,x_msg_data        =>  x_msg_data );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  IF (p_color_method = 3 OR p_color_method IS NULL) THEN  -- Target Met In Between
    l_threshold := threshold_array(1,2,3,4,5);
    l_threshold(1) := '1::'|| p_m3_l4 ||':'|| 192; -- Red
    l_threshold(2) := '2:'|| p_m3_l4||':'|| p_m3_l3 ||':'|| 49919; -- Yellow
    l_threshold(3) := '3:'|| p_m3_l3||':'|| p_m3_l2 ||':'|| 24865; --Green
    l_threshold(4) := '4:'|| p_m3_l2||':'|| p_m3_l1 ||':'|| 49919; --Yellow
    l_threshold(5) := '5:'|| p_m3_l1||'::'|| 192;             --Red
    IF (p_color_method IS NULL) THEN
      l_property_value := 3;
    END IF;
    BSC_COLOR_RANGES_PUB.Create_Color_Prop_Ranges(p_objective_id    =>  p_objective_id
                                                 ,p_kpi_measure_id  =>  p_kpi_measure_id
                                                 ,p_color_type      =>  p_color_type
                                                 ,p_threshold_color =>  l_threshold
                                                 ,p_property_value  =>  l_property_value
                                                 ,x_return_status   =>  x_return_status
                                                 ,x_msg_count       =>  x_msg_count
                                                 ,x_msg_data        =>  x_msg_data );
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
END create_color_thresholds;


FUNCTION upgrade_color_thresholds (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS
l_indicator        VARCHAR2(100);
l_m1_l1            NUMBER;
l_m1_l2            NUMBER;
l_m2_l1            NUMBER;
l_m2_l2            NUMBER;
l_m3_l1            NUMBER;
l_m3_l2            NUMBER;
l_m3_l3            NUMBER;
l_m3_l4            NUMBER;
l_color_method     NUMBER;
x_return_status    VARCHAR2(1);
x_msg_count        NUMBER(3);
x_msg_data         VARCHAR2(2000);

CURSOR c_objectives IS
SELECT indicator, config_type
FROM   bsc_kpis_b
WHERE  prototype_flag <> 2;

CURSOR c_anal_measures IS
SELECT  an.kpi_measure_id
       ,ds.color_method
FROM   bsc_kpi_analysis_measures_b an
      ,bsc_sys_datasets_b ds
WHERE an.dataset_id = ds.dataset_id
AND   an.indicator = l_indicator
AND   NOT EXISTS (SELECT
      NULL from bsc_color_type_props p
      WHERE p.kpi_measure_id = an.kpi_measure_id
      );

CURSOR c_obj_threshold IS
SELECT property_code, property_value
FROM   bsc_kpi_properties
WHERE  property_code in ('COL_M1_LEVEL1', 'COL_M1_LEVEL2', 'COL_M2_LEVEL1', 'COL_M2_LEVEL2',
                         'COL_M3_LEVEL1', 'COL_M3_LEVEL2', 'COL_M3_LEVEL3', 'COL_M3_LEVEL4')
AND indicator = l_indicator;

BEGIN

  FOR c_obj IN c_objectives LOOP

    BEGIN

      l_indicator := c_obj.indicator;
      FOR c_obj_thr IN c_obj_threshold LOOP
        IF (c_obj_thr.property_code = 'COL_M1_LEVEL1') THEN
          l_m1_l1 := c_obj_thr.property_value;
        ELSIF (c_obj_thr.property_code = 'COL_M1_LEVEL2') THEN
          l_m1_l2 := c_obj_thr.property_value;
        ELSIF (c_obj_thr.property_code = 'COL_M2_LEVEL1') THEN
          l_m2_l1 := c_obj_thr.property_value;
        ELSIF (c_obj_thr.property_code = 'COL_M2_LEVEL2') THEN
          l_m2_l2 := c_obj_thr.property_value;
        ELSIF (c_obj_thr.property_code = 'COL_M3_LEVEL1') THEN
          l_m3_l1 := c_obj_thr.property_value;
        ELSIF (c_obj_thr.property_code = 'COL_M3_LEVEL2') THEN
          l_m3_l2 := c_obj_thr.property_value;
        ELSIF (c_obj_thr.property_code = 'COL_M3_LEVEL3') THEN
          l_m3_l3 := c_obj_thr.property_value;
        ELSIF (c_obj_thr.property_code = 'COL_M3_LEVEL4') THEN
          l_m3_l4 := c_obj_thr.property_value;
        END IF;
      END LOOP;


      FOR c_anal_mes IN c_anal_measures LOOP

        IF (c_obj.config_type = 3) THEN
          l_color_method := NULL;
        ELSE
          l_color_method := c_anal_mes.color_method;
        END IF;

        create_color_thresholds (
          p_objective_id     => l_indicator
        , p_kpi_measure_id   => c_anal_mes.kpi_measure_id
        , p_color_method     => l_color_method
        , p_color_type       => 'PERCENT_OF_TARGET'
        , p_m1_l1            => l_m1_l1
        , p_m1_l2            => l_m1_l2
        , p_m2_l1            => l_m2_l1
        , p_m2_l2            => l_m2_l2
        , p_m3_l1            => l_m3_l1
        , p_m3_l2            => l_m3_l2
        , p_m3_l3            => l_m3_l3
        , p_m3_l4            => l_m3_l4
        );

      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
       BSC_MESSAGE.Add( x_message => 'upgrade_color_thresholds() failed for objective= ' || l_indicator || ' :-' ||SQLERRM
                      , x_source  => 'BSCCOLUB.pls'
                      , x_mode    => 'I'
                      );
    END;
  END LOOP;

  -- Delete the data moved.
  /*DELETE  bsc_kpi_properties
  WHERE  property_code in ('COL_M1_LEVEL1', 'COL_M1_LEVEL2', 'COL_M2_LEVEL1', 'COL_M2_LEVEL2',
                         'COL_M3_LEVEL1', 'COL_M3_LEVEL2', 'COL_M3_LEVEL3', 'COL_M3_LEVEL4');*/

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_error_msg := 'BSC_COLOR_UPGRADE.upgrade_color_thresholds ->' || x_msg_data;
    ELSE
      x_error_msg := 'BSC_COLOR_UPGRADE.upgrade_color_thresholds -> ' || SQLERRM;
    END IF;
    RETURN FALSE;
END upgrade_color_thresholds;


FUNCTION upgrade_simulation_objectives (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN
IS
  CURSOR c_old_sims IS
    SELECT indicator
      FROM   bsc_kpis_b
      WHERE  config_type = 7
      AND    prototype_flag <> 2
      AND    short_name IS NULL;

  l_return_status    VARCHAR2(1);
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(4000);

BEGIN

  FOR cd IN c_old_sims LOOP

    BEGIN

      BSC_PMF_UI_WRAPPER.Delete_Kpi
      ( p_commit              => FND_API.G_FALSE
      , p_kpi_id              => cd.indicator
      , x_return_status       => l_return_status
      , x_msg_count           => l_msg_count
      , x_msg_data            => l_msg_data
      );


      IF ((l_return_status IS NOT NULL) AND (l_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        BSC_MESSAGE.Add( x_message => 'upgrade_simulation_objectives() failed for objective= ' || cd.indicator || ' :-' || SQLERRM
                       , x_source  => 'BSCCOLUB.pls'
                       , x_mode    => 'I'
                       );
    END;

  END LOOP;

  DELETE FROM bsc_sys_files
    WHERE file_type = 'F1'
    AND INDICATOR = 0;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    IF ((l_return_status IS NOT NULL) AND (l_return_status  <> FND_API.G_RET_STS_SUCCESS)) THEN
      x_error_msg := 'BSC_COLOR_UPGRADE.upgrade_simulation_objectives ->' || l_msg_data;
    ELSE
      x_error_msg := 'BSC_COLOR_UPGRADE.upgrade_simulation_objectives -> ' || SQLERRM;
    END IF;
    RETURN FALSE;
END upgrade_simulation_objectives;


FUNCTION upgrade_assessments (
  x_error_msg  OUT NOCOPY VARCHAR2
) RETURN BOOLEAN IS

CURSOR c_old_kpi_comments IS
SELECT  comment_id
       ,indicator
       ,trend_flag
FROM   bsc_kpi_comments
WHERE nvl(trend_flag,0)<10
AND   trend_flag <>0
AND   indicator IS NOT NULL;

l_old_trend NUMBER;
l_new_trend NUMBER;
l_color     NUMBER;
BEGIN
  FOR c_kpi_comm IN c_old_kpi_comments LOOP
     l_old_trend := c_kpi_comm.trend_flag;
     l_color     := 0;
     l_new_trend := 0;
     IF l_old_trend = 1 THEN
        l_color     := 10;
        l_new_trend := 10;
     ELSIF l_old_trend = 2 THEN
        l_color     := 10;
        l_new_trend := 14;
     ELSIF l_old_trend = 3 THEN
        l_color     := 10;
        l_new_trend := 11;
     ELSIF l_old_trend = 4 THEN
        l_color     := 12;
        l_new_trend := 10;
     ELSIF l_old_trend = 5 THEN
        l_color     := 12;
        l_new_trend := 14;
     ELSIF l_old_trend = 6 THEN
        l_color     := 12;
        l_new_trend := 11;
     ELSIF l_old_trend = 7 THEN
        l_color     := 14;
        l_new_trend := 12;
     ELSIF l_old_trend = 8 THEN
        l_color     := 14;
        l_new_trend := 14;
     ELSIF l_old_trend = 9 THEN
        l_color     := 14;
        l_new_trend := 13;
     END IF;

     IF l_color<>0 AND l_new_trend <>0 THEN
       UPDATE bsc_kpi_comments
       SET    color_flag=l_color, trend_flag=l_new_trend
       WHERE  comment_id = c_kpi_comm.comment_id
       AND    indicator  = c_kpi_comm.indicator;
     END IF;

  END LOOP;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
      x_error_msg := 'BSC_COLOR_UPGRADE.upgrade_assessments -> ' || SQLERRM;
      RETURN FALSE;
END upgrade_assessments;


END BSC_COLOR_UPGRADE;

/
