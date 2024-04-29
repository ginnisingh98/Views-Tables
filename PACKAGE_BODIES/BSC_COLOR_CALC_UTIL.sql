--------------------------------------------------------
--  DDL for Package Body BSC_COLOR_CALC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_COLOR_CALC_UTIL" AS
/* $Header: BSCCUTLB.pls 120.6.12000000.1 2007/07/17 07:43:38 appldev noship $ */


FUNCTION get_weighted_obj_color (
  p_pbjective_id      IN NUMBER
, p_weighted_avg_val  IN NUMBER
)
RETURN NUMBER;

PROCEDURE get_rollup_obj_color (
  p_rollup_type IN bsc_kpis_b.color_rollup_type%TYPE
, p_colors      IN BSC_UPDATE_UTIL.t_array_of_number
, p_num_colors  IN NUMBER
, x_color       OUT NOCOPY NUMBER
, x_kpi_index   OUT NOCOPY NUMBER
);


/*
 * Get_Kpi_Measure_Threshold: Returns the Threshold properties as table.
 * First it checks threshold corresponding to KPI, in not defined then it
 * picks the Objective threshold for the KPI (Measure) threshold for color calculation.
 */
FUNCTION Get_Kpi_Measure_Threshold (
  p_indicator       IN         NUMBER
, p_kpi_measure_id  IN         NUMBER
) RETURN Threshold_Prop_Table IS

  l_color_range_id   NUMBER;
  l_threshold_Table  Threshold_Prop_Table;
  l_count            NUMBER;
  l_config_type      NUMBER;

  -- For P & L Objective threshold.
  CURSOR c_pl_color IS
    SELECT color_range_id
    FROM bsc_color_type_props
    WHERE indicator  = p_indicator
    --AND  kpi_measure_id = p_kpi_measure_id;
    AND  property_value = 1;
  -- For kpi_measure threshold.
  CURSOR c_kpi_measure_color IS
    SELECT color_range_id
    FROM bsc_color_type_props
    WHERE indicator  = p_indicator
    AND  kpi_measure_id = p_kpi_measure_id;

  -- For weight Objective threshold.
  CURSOR c_objective_color IS
    SELECT color_range_id
    FROM bsc_color_type_props
    WHERE indicator = p_indicator
    AND kpi_measure_id IS NULL;

  CURSOR c_threshold_values IS
    SELECT high, color_id
    FROM bsc_color_ranges
    WHERE color_range_id = l_color_range_id
    ORDER BY color_range_sequence;

BEGIN
  SELECT config_type
  INTO   l_config_type
  FROM   bsc_kpis_b
  WHERE  indicator = p_indicator;
  IF (l_config_type = 3 ) THEN
    FOR c_pl_color_range IN c_pl_color LOOP
      l_color_range_id := c_pl_color_range.color_range_id;
    END LOOP;
  ELSIF (p_kpi_measure_id IS NULL) THEN  -- Get Threshold for Weighted Objective.
    FOR c_objective_range IN c_objective_color LOOP
      l_color_range_id := c_objective_range.color_range_id;
    END LOOP;
  ELSE  -- Get Threshold for kpi_measure.
    FOR c_kpi_measure_range IN c_kpi_measure_color LOOP
      l_color_range_id := c_kpi_measure_range.color_range_id;
    END LOOP;
  END IF;

  l_count := 1;
  FOR c_thresholds IN c_threshold_values LOOP
    l_threshold_Table(l_count).THRESHOLD := c_thresholds.high;
    l_threshold_Table(l_count).COLOR_ID  := c_thresholds.color_id;
    l_count := l_count + 1;
  END LOOP;

  RETURN l_threshold_Table;
EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.Get_Kpi_Measure_Threshold');
    RETURN l_threshold_Table;
END Get_Kpi_Measure_Threshold;


FUNCTION get_color_perf_seq (
  p_color_id  IN  bsc_sys_colors_b.color_id%TYPE
)
RETURN NUMBER IS

  l_index         NUMBER;
  l_array_colors  BSC_COLOR_REPOSITORY.t_array_colors;
  l_color_rec     BSC_COLOR_REPOSITORY.t_color_rec;

BEGIN

  l_array_colors := BSC_COLOR_REPOSITORY.get_color_props();

  FOR l_index IN 1 .. l_array_colors.COUNT LOOP
    l_color_rec := l_array_colors(l_index);
    IF l_color_rec.color_id = p_color_id THEN
      RETURN l_color_rec.perf_seq;
    END IF;
  END LOOP;

  RETURN NULL;

EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.get_color_perf_seq');
    RETURN NULL;
END get_color_perf_seq;



FUNCTION get_objective_color_method (
  p_pbjective_id IN NUMBER
)
RETURN NUMBER IS
  CURSOR c_obj_color_prop IS
    SELECT weighted_color_method
      FROM bsc_kpis_b
      WHERE indicator = p_pbjective_id;

  l_color_method  NUMBER;

BEGIN
  IF c_obj_color_prop%ISOPEN THEN
    CLOSE c_obj_color_prop;
  END IF;

  OPEN c_obj_color_prop;
  FETCH c_obj_color_prop INTO l_color_method;
  IF c_obj_color_prop%NOTFOUND THEN
    RETURN NULL;
  END IF;

  CLOSE c_obj_color_prop;

  RETURN l_color_method;

EXCEPTION
  WHEN OTHERS THEN
    IF c_obj_color_prop%ISOPEN THEN
      CLOSE c_obj_color_prop;
    END IF;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.get_objective_color_method');
    RETURN NULL;
END get_objective_color_method;


FUNCTION get_kpi_measure_weight (
  p_objective_id    IN bsc_kpis_b.indicator%TYPE
, p_kpi_measure_id  IN bsc_kpi_measure_props.kpi_measure_id%TYPE
)
RETURN NUMBER IS
  CURSOR c_kpi_measure_weight IS
    SELECT weight
      FROM bsc_kpi_measure_weights
      WHERE kpi_measure_id = p_kpi_measure_id
      AND   indicator = p_objective_id;
  l_weight  NUMBER;
BEGIN
  l_weight := 0;
  IF c_kpi_measure_weight%ISOPEN THEN
    CLOSE c_kpi_measure_weight;
  END IF;

  OPEN c_kpi_measure_weight;
  FETCH c_kpi_measure_weight INTO l_weight;
  IF c_kpi_measure_weight%NOTFOUND THEN
    RETURN 0;
  END IF;

  CLOSE c_kpi_measure_weight;

  RETURN l_weight;

EXCEPTION
  WHEN OTHERS THEN
    IF c_kpi_measure_weight%ISOPEN THEN
      CLOSE c_kpi_measure_weight;
    END IF;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.get_kpi_measure_weight');
    RETURN 0;
END get_kpi_measure_weight;


FUNCTION get_color_numeric_equivalent (
  p_color_id  IN NUMBER
)
RETURN NUMBER IS

  l_index         NUMBER;
  l_array_colors  BSC_COLOR_REPOSITORY.t_array_colors;
  l_color_rec     BSC_COLOR_REPOSITORY.t_color_rec;

BEGIN

  l_array_colors := BSC_COLOR_REPOSITORY.get_color_props();
  FOR l_index IN 1 .. l_array_colors.COUNT LOOP
    l_color_rec := l_array_colors(l_index);
    IF l_color_rec.color_id = p_color_id THEN
      RETURN l_color_rec.numeric_eq;
    END IF;
  END LOOP;

  RETURN 0;

EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.get_color_numeric_equivalent');
    RETURN 0;
END get_color_numeric_equivalent;


FUNCTION get_max_count (
  p_array_of_number  IN BSC_UPDATE_UTIL.t_array_of_number
)
RETURN NUMBER IS
  l_counter    NUMBER;
  l_max_count  NUMBER;
BEGIN
  l_max_count := 0;

  IF p_array_of_number IS NOT NULL AND p_array_of_number.COUNT > 0 THEN
    l_counter := p_array_of_number.FIRST;
    WHILE l_counter IS NOT NULL LOOP
      IF l_max_count < p_array_of_number(l_counter) THEN
        l_max_count := p_array_of_number(l_counter);
      END IF;
      l_counter := p_array_of_number.NEXT(l_counter);
    END LOOP;
  END IF;

  RETURN l_max_count;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END get_max_count;



PROCEDURE initialize_color_array (
  p_array_of_number  IN OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number
)
IS
  l_index         NUMBER;
  l_array_colors  BSC_COLOR_REPOSITORY.t_array_colors;
  l_color_rec     BSC_COLOR_REPOSITORY.t_color_rec;

BEGIN

  l_array_colors := BSC_COLOR_REPOSITORY.get_color_props();
  FOR l_index IN 1 .. l_array_colors.COUNT LOOP
    l_color_rec := l_array_colors(l_index);
    p_array_of_number(l_color_rec.color_id) := 0;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END initialize_color_array;


FUNCTION Calc_Obj_Color_By_Weights (
  p_objective_color_rec  IN BSC_UPDATE_COLOR.t_objective_color_rec
)
RETURN BOOLEAN IS
  CURSOR c_dim_comb(p_indicator NUMBER, p_tab_id NUMBER) IS
    SELECT DISTINCT
           dim_level1 || dim_level2 || dim_level3 || dim_level4 || dim_level5 || dim_level6 || dim_level7 || dim_level8 || period_id dim_comb,
           dim_level1, dim_level2, dim_level3, dim_level4, dim_level5, dim_level6, dim_level7, dim_level8,
           period_id
      FROM bsc_sys_kpi_colors
      WHERE indicator = p_indicator
      AND   tab_id = p_tab_id;
  l_dim_comb  c_dim_comb%ROWTYPE;

  CURSOR c_kpi_colors(p_indicator NUMBER, p_tab_id NUMBER, p_dim_comb VARCHAR2) IS
    SELECT kpi_measure_id, kpi_color
      FROM bsc_sys_kpi_colors
      WHERE dim_level1 || dim_level2 || dim_level3 || dim_level4 || dim_level5 || dim_level6 || dim_level7 || dim_level8 ||  period_id = p_dim_comb
      AND   indicator = p_indicator
      AND   tab_id = p_tab_id
    UNION -- bsc_sys_kpi_colors may not contain a color entry for 'color enabled' KPIs for which data has not been loaded
    SELECT kpi_measure_id, BSC_COLOR_REPOSITORY.NO_COLOR kpi_color
      FROM bsc_kpi_measure_props
      WHERE indicator = p_indicator
      AND   disable_color = 'F'
      AND   kpi_measure_id NOT IN
                           ( SELECT kpi_measure_id FROM bsc_sys_kpi_colors
                             WHERE indicator = p_indicator
                             AND   tab_id = p_tab_id
                           );
  l_kpi_colors  c_kpi_colors%ROWTYPE;

  l_obj_color               NUMBER;
  l_kpi_weight              NUMBER;
  l_num_eq                  NUMBER;
  l_result                  NUMBER;
  l_weighted_average_val    NUMBER;
  l_set_no_color            BOOLEAN;
  e_unexpected_error        EXCEPTION;

BEGIN

  FOR l_dim_comb IN c_dim_comb(p_objective_color_rec.objective_id, p_objective_color_rec.tab_id) LOOP

    IF l_dim_comb.dim_comb IS NOT NULL THEN

      l_obj_color := BSC_COLOR_REPOSITORY.NO_COLOR;
      l_set_no_color := FALSE;
      l_weighted_average_val := 0;

      FOR l_kpi_colors IN c_kpi_colors(p_objective_color_rec.objective_id, p_objective_color_rec.tab_id, l_dim_comb.dim_comb) LOOP

        l_kpi_weight := get_kpi_measure_weight(p_objective_color_rec.objective_id, l_kpi_colors.kpi_measure_id);

        IF l_kpi_colors.kpi_color = BSC_COLOR_REPOSITORY.NO_COLOR AND l_kpi_weight <> 0 THEN
          l_obj_color := BSC_COLOR_REPOSITORY.NO_COLOR;
          l_set_no_color := TRUE;
          EXIT;
        END IF;

        l_num_eq := get_color_numeric_equivalent(l_kpi_colors.kpi_color);
        l_result := (l_kpi_weight/100) * l_num_eq;
        l_weighted_average_val := l_weighted_average_val + l_result;

      END LOOP;

      IF NOT l_set_no_color THEN
        l_obj_color := get_weighted_obj_color( p_objective_color_rec.objective_id
                                             , l_weighted_average_val
                                             );
        IF l_obj_color IS NULL THEN
	  RAISE e_unexpected_error;
        END IF;
      END IF;

      INSERT INTO bsc_sys_objective_colors
        (tab_id, indicator, dim_level1, dim_level2, dim_level3, dim_level4, dim_level5, dim_level6, dim_level7, dim_level8, period_id, obj_color, driving_kpi_measure_id)
        VALUES
          (p_objective_color_rec.tab_id, p_objective_color_rec.objective_id,
           l_dim_comb.dim_level1, l_dim_comb.dim_level2, l_dim_comb.dim_level3, l_dim_comb.dim_level4,
           l_dim_comb.dim_level5, l_dim_comb.dim_level6, l_dim_comb.dim_level7, l_dim_comb.dim_level8,
           l_dim_comb.period_id, l_obj_color, NULL);

    END IF;

  END LOOP;

  COMMIT;

  RETURN TRUE;

EXCEPTION
  WHEN e_unexpected_error THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_KPICOLOR_FAILED'),
                    x_source => 'BSC_COLOR_CALC_UTIL.Calc_Obj_Color_By_Weights');
    RETURN FALSE;
  WHEN OTHERS THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.Calc_Obj_Color_By_Weights');
    RETURN FALSE;
END Calc_Obj_Color_By_Weights;


FUNCTION get_weighted_obj_color (
  p_pbjective_id      IN NUMBER
, p_weighted_avg_val  IN NUMBER
)
RETURN NUMBER IS
  l_obj_color             NUMBER;
  l_obj_color_method      NUMBER;
  l_threshold_prop_table  threshold_prop_table;
BEGIN

  l_obj_color := BSC_COLOR_REPOSITORY.NO_COLOR;

  l_obj_color_method := get_objective_color_method(p_pbjective_id);

  l_threshold_prop_table := Get_Kpi_Measure_Threshold (p_pbjective_id, NULL);

  /*
   * threshold_prop_table will be formulated as below:
   *
   * On the UI, user can enter values in any order of threshold values.
   *
   * INCREASING_GOOD :-
   * The table of records will be ordered by the HIGH value of
   * the color ranges in ascending order.
   *
   * threshold_prop_table:
   * Operation		    Threshold               Color_Id
   *  <=  			20			1
   *  <=  			30			2
   *  <=  			50			3
   *  <=  			90			4
   *  > 90 or ELSE  	        NULL			5
   *
   *
   * DECREASING_GOOD OR WITHIN_RANGE:-
   * The table of records will be ordered by the HIGH value of
   * the color ranges in ascending order.
   *
   * threshold_prop_table:
   * Operation		    Threshold               Color_Id
   *  <  			20			1
   *  < 			30			2
   *  <  			50			3
   *  <  			90			4
   *  >= 90 or ELSE  	        NULL			5
   */

  IF l_threshold_prop_table.COUNT > 0 THEN

    IF l_obj_color_method = 1 OR    -- INCREASING_GOOD
       l_obj_color_method = 4 THEN  -- FLEXIBLE (not used today)

      FOR l_index IN 1..l_threshold_prop_table.COUNT LOOP

        IF l_threshold_prop_table(l_index).threshold IS NULL THEN
	  l_obj_color := l_threshold_prop_table(l_index).color_id;
	  EXIT;
	ELSIF p_weighted_avg_val <= l_threshold_prop_table(l_index).threshold THEN
	  l_obj_color := l_threshold_prop_table(l_index).color_id;
	  EXIT;
        END IF;

      END LOOP;

    ELSIF l_obj_color_method = 2 OR    -- DECREASING_GOOD
          l_obj_color_method = 3 THEN  -- WITHIN_RANGE

      FOR l_index IN 1..l_threshold_prop_table.COUNT LOOP

        IF l_threshold_prop_table(l_index).threshold IS NULL THEN
          l_obj_color := l_threshold_prop_table(l_index).color_id;
          EXIT;
        ELSIF p_weighted_avg_val < l_threshold_prop_table(l_index).threshold THEN
          l_obj_color := l_threshold_prop_table(l_index).color_id;
          EXIT;
        END IF;

      END LOOP;

    END IF;

  END IF;

  RETURN l_obj_color;

EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.get_weighted_obj_color');
    RETURN NULL;
END get_weighted_obj_color;

FUNCTION Get_Sim_Default_Kpi_Measure_Id (
  p_objective_id  IN NUMBER
)
RETURN NUMBER IS

  CURSOR c_default_node_dataset(p_indicator NUMBER) IS
    SELECT property_value dataset_id
      FROM  bsc_kpi_properties
      WHERE property_code = BSC_SIMULATION_VIEW_PUB.c_SIM_NODE_ID
      AND   indicator = p_indicator;
  l_default_node_dataset_id  bsc_kpi_properties.property_value%TYPE;

  CURSOR c_default_kpi(p_indicator NUMBER, p_dataset_id NUMBER) IS
    SELECT kpi_measure_id
      FROM bsc_kpi_analysis_measures_b anal_meas
      WHERE anal_meas.dataset_id = p_dataset_id
      AND   anal_meas.indicator = p_indicator;
  l_default_kpi_rec  c_default_kpi%ROWTYPE;

  l_default_kpi_measure_id   bsc_kpi_measure_props.kpi_measure_id%TYPE;

BEGIN

  l_default_kpi_measure_id := NULL;

  IF c_default_node_dataset%ISOPEN THEN
    CLOSE c_default_node_dataset;
  END IF;
  OPEN c_default_node_dataset (p_objective_id);
  FETCH c_default_node_dataset INTO l_default_node_dataset_id;
  IF c_default_node_dataset%NOTFOUND THEN
    RETURN NULL;
  END IF;
  CLOSE c_default_node_dataset;

  FOR l_default_kpi_rec IN c_default_kpi(p_objective_id, l_default_node_dataset_id) LOOP
    -- Ideally only 1 row must be returned since duplicate datasets are not allowed in Simulation Objective
    l_default_kpi_measure_id := l_default_kpi_rec.kpi_measure_id;
  END LOOP;

  RETURN l_default_kpi_measure_id;

EXCEPTION
  WHEN OTHERS THEN
    IF c_default_node_dataset%ISOPEN THEN
      CLOSE c_default_node_dataset;
    END IF;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.Get_Sim_Default_Kpi_Measure_Id');
    RETURN NULL;
END Get_Sim_Default_Kpi_Measure_Id;


PROCEDURE Calc_Obj_Color_By_Single_Kpi (
  p_objective_color_rec  IN BSC_UPDATE_COLOR.t_objective_color_rec
 ,p_rollup_type          IN bsc_kpis_b.color_rollup_type%TYPE
 ,x_kpi_measure_id       OUT NOCOPY NUMBER
 ,x_color_flag           OUT NOCOPY BOOLEAN

) IS

  CURSOR c_dim_comb(p_indicator NUMBER, p_tab_id NUMBER) IS
    SELECT DISTINCT
           dim_level1 || dim_level2 || dim_level3 || dim_level4 || dim_level5 || dim_level6 || dim_level7 || dim_level8 || period_id dim_comb,
           dim_level1, dim_level2, dim_level3, dim_level4, dim_level5, dim_level6, dim_level7, dim_level8,
           period_id
      FROM bsc_sys_kpi_colors
      WHERE indicator = p_indicator
      AND   tab_id = p_tab_id;
  l_dim_comb  c_dim_comb%ROWTYPE;

  CURSOR c_kpi_colors(p_indicator NUMBER, p_tab_id NUMBER, p_dim_comb VARCHAR2) IS
    SELECT kpi_color, kpi_measure_id
      FROM bsc_sys_kpi_colors
      WHERE dim_level1 || dim_level2 || dim_level3 || dim_level4 || dim_level5 || dim_level6 || dim_level7 || dim_level8 ||  period_id = p_dim_comb
      AND   indicator = p_indicator
      AND   tab_id = p_tab_id
    UNION  -- bsc_sys_kpi_colors may not contain a color entry for 'color enabled' KPIs for which data has not been loaded
    SELECT BSC_COLOR_REPOSITORY.NO_COLOR kpi_color, kpi_measure_id
      FROM bsc_kpi_measure_props
      WHERE indicator = p_indicator
      AND   disable_color = 'F'
      AND   kpi_measure_id NOT IN
                           ( SELECT kpi_measure_id FROM bsc_sys_kpi_colors
                             WHERE indicator = p_indicator
                             AND   tab_id = p_tab_id
                           );
  l_kpi_colors  c_kpi_colors%ROWTYPE;

  e_unexpected_error        EXCEPTION;
  l_default_kpi_measure_id  bsc_kpi_measure_props.kpi_measure_id%TYPE;
  l_colors                  BSC_UPDATE_UTIL.t_array_of_number;
  l_kpi_measures            BSC_UPDATE_UTIL.t_array_of_number;
  l_color_index             NUMBER;
  l_obj_color               NUMBER;
  l_kpi_index               NUMBER := -1;

BEGIN

  FOR l_dim_comb IN c_dim_comb(p_objective_color_rec.objective_id, p_objective_color_rec.tab_id) LOOP

    IF l_dim_comb.dim_comb IS NOT NULL THEN

      l_color_index := 0;
      l_obj_color := BSC_COLOR_REPOSITORY.NO_COLOR;

      FOR l_kpi_colors IN c_kpi_colors(p_objective_color_rec.objective_id, p_objective_color_rec.tab_id, l_dim_comb.dim_comb) LOOP

        l_color_index := l_color_index + 1;
        l_colors(l_color_index) := l_kpi_colors.kpi_color;
        l_kpi_measures(l_color_index) := l_kpi_colors.kpi_measure_id;

      END LOOP;

      get_rollup_obj_color( p_rollup_type => p_rollup_type
                          , p_colors      => l_colors
                          , p_num_colors  => l_color_index
                          , x_color       => l_obj_color
                          , x_kpi_index   => l_kpi_index
                          );

      IF l_obj_color IS NULL THEN
        RAISE e_unexpected_error;
      END IF;

      IF l_kpi_index >= 0 THEN
        x_kpi_measure_id := l_kpi_measures(l_kpi_index);
      ELSE
        x_kpi_measure_id := -1;
      END IF;

      INSERT INTO bsc_sys_objective_colors
        (tab_id, indicator, dim_level1, dim_level2, dim_level3, dim_level4, dim_level5, dim_level6, dim_level7, dim_level8, period_id, obj_color, driving_kpi_measure_id)
        VALUES
          (p_objective_color_rec.tab_id, p_objective_color_rec.objective_id,
           l_dim_comb.dim_level1, l_dim_comb.dim_level2, l_dim_comb.dim_level3, l_dim_comb.dim_level4,
           l_dim_comb.dim_level5, l_dim_comb.dim_level6, l_dim_comb.dim_level7, l_dim_comb.dim_level8,
           l_dim_comb.period_id, l_obj_color, x_kpi_measure_id);

    END IF;

  END LOOP;

  COMMIT;

  x_color_flag     := TRUE;
  --RETURN TRUE;

EXCEPTION
  WHEN e_unexpected_error THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_KPICOLOR_FAILED'),
                    x_source => 'BSC_COLOR_CALC_UTIL.Calc_Obj_Color_By_Single_Kpi');
    x_kpi_measure_id := -1;
    x_color_flag     := false;
    --RETURN FALSE;
  WHEN OTHERS THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.Calc_Obj_Color_By_Single_Kpi');
    x_kpi_measure_id := -1;
    x_color_flag     := false;
    --RETURN FALSE;
END Calc_Obj_Color_By_Single_Kpi;


/* Returns the worst color out of all the colors in the input array.
 * Worst color is based on BSC_SYS_COLORS_B.PERF_SEQUENCE.
 * If any of the KPI colors passed in is GRAY or NO_COLOR, color that
 * will be returned will also be GRAY.
*/
PROCEDURE get_worst_color (
  p_colors      IN BSC_UPDATE_UTIL.t_array_of_number
, p_num_colors  IN NUMBER
, x_color       OUT NOCOPY NUMBER
, x_kpi_index   OUT NOCOPY NUMBER
) IS

  l_index         NUMBER;
  l_max_perf_seq  NUMBER;
  l_perf_seq      NUMBER;
  l_worst_color   BSC_SYS_COLORS_B.color_id%TYPE;

BEGIN

  IF p_num_colors = 0 THEN

    x_color := BSC_COLOR_REPOSITORY.NO_COLOR;
    x_kpi_index := -1;

  ELSIF p_num_colors = 1 THEN

    x_color := p_colors(1);
    x_kpi_index := 1;

  ELSE

    l_max_perf_seq := get_color_perf_seq(p_colors(1));
    l_worst_color := p_colors(1);
    x_kpi_index   := 1;

    FOR l_index IN 1 .. p_num_colors LOOP
      -- we could have started counter from 2, but we are doing from 1 since we want
      -- to check for NO_COLOR for the first color p_colors(1) also.

      IF p_colors(l_index) = BSC_COLOR_REPOSITORY.NO_COLOR THEN
        x_color := BSC_COLOR_REPOSITORY.NO_COLOR;
        x_kpi_index := l_index;
        RETURN;
      END IF;

      l_perf_seq := get_color_perf_seq(p_colors(l_index));
      IF l_max_perf_seq < l_perf_seq THEN
        l_max_perf_seq := l_perf_seq;
        l_worst_color  := p_colors(l_index);
        x_kpi_index    := l_index;
      END IF;

    END LOOP;

    x_color := l_worst_color;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.get_worst_color');
    --RETURN NULL;
END get_worst_color;

/* Returns the best color out of all the colors in the input array.
 * Best color is based on BSC_SYS_COLORS_B.PERF_SEQUENCE.
 * If any of the KPI colors passed in is GRAY or NO_COLOR, color that
 * will be returned will also be GRAY.
*/
PROCEDURE get_best_color (
  p_colors      IN BSC_UPDATE_UTIL.t_array_of_number
, p_num_colors  IN NUMBER
, x_color       OUT NOCOPY NUMBER
, x_kpi_index OUT NOCOPY NUMBER
) IS

  l_index         NUMBER;
  l_min_perf_seq  NUMBER;
  l_perf_seq      NUMBER;
  l_best_color    BSC_SYS_COLORS_B.color_id%TYPE;

BEGIN

  IF p_num_colors = 0 THEN

    x_color := BSC_COLOR_REPOSITORY.NO_COLOR;
    x_kpi_index := -1;
    RETURN;

  ELSIF p_num_colors = 1 THEN

    x_color := p_colors(1);
    x_kpi_index := 1;
    RETURN;
  ELSE

    l_min_perf_seq := get_color_perf_seq(p_colors(1));
    l_best_color := p_colors(1);
    x_kpi_index  := 1;

    FOR l_index IN 1 .. p_num_colors LOOP
      -- we could have started counter from 2, but we are doing from 1 since we want
      -- to check for NO_COLOR for the first color p_colors(1) also.

      IF p_colors(l_index) = BSC_COLOR_REPOSITORY.NO_COLOR THEN
        x_color := BSC_COLOR_REPOSITORY.NO_COLOR;
        x_kpi_index := l_index;
        RETURN;
      END IF;

      l_perf_seq := get_color_perf_seq(p_colors(l_index));
      IF l_min_perf_seq > l_perf_seq THEN
        l_min_perf_seq := l_perf_seq;
        l_best_color := p_colors(l_index);
        x_kpi_index := l_index;
      END IF;

    END LOOP;

    x_color := l_best_color;
    RETURN;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.get_best_color');
    --RETURN NULL;
END get_best_color;


PROCEDURE get_colors_with_max_count (
  p_array_of_number  IN BSC_UPDATE_UTIL.t_array_of_number
, p_max_count        IN NUMBER
, p_colors_array     OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_number
, p_color_count      OUT NOCOPY NUMBER
)
IS
  l_index         NUMBER;
  l_array_colors  BSC_COLOR_REPOSITORY.t_array_colors;
  l_color_rec     BSC_COLOR_REPOSITORY.t_color_rec;

BEGIN

  p_color_count := 0;
  l_array_colors := BSC_COLOR_REPOSITORY.get_color_props();
  FOR l_index IN 1 .. l_array_colors.COUNT LOOP
    l_color_rec := l_array_colors(l_index);

    IF p_array_of_number(l_color_rec.color_id) = p_max_count THEN
      p_color_count := p_color_count + 1;
      p_colors_array(p_color_count) := l_color_rec.color_id;
    END IF;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END get_colors_with_max_count;


/* Returns the color which occurs maximum number of times out of all
 * the colors in the input array. If 2 or more colors have the same number
 * of occurences, then the worst color of those will be returned.
 * If any of the KPI colors passed in is GRAY or NO_COLOR, color that
 * will be returned will also be GRAY.
*/
PROCEDURE get_most_frequent_color (
  p_colors      IN BSC_UPDATE_UTIL.t_array_of_number
, p_num_colors  IN NUMBER
, x_color       OUT NOCOPY NUMBER
, x_kpi_index   OUT NOCOPY NUMBER
) IS

  l_index            NUMBER;
  l_min_perf_seq     NUMBER;
  l_perf_seq         NUMBER;
  l_most_freq_color  BSC_SYS_COLORS_B.color_id%TYPE;
  l_array_of_number  BSC_UPDATE_UTIL.t_array_of_number;
  l_colors_array     BSC_UPDATE_UTIL.t_array_of_number;
  l_color_count      NUMBER;
  l_max_count        NUMBER;
  i NUMBER;
BEGIN

  IF p_num_colors = 0 THEN

    x_color := BSC_COLOR_REPOSITORY.NO_COLOR;
    x_kpi_index := -1;

  ELSIF p_num_colors = 1 THEN

    x_color := p_colors(1);
    x_kpi_index := 1;

  ELSE

    l_most_freq_color := BSC_COLOR_REPOSITORY.NO_COLOR;
    x_kpi_index       := -1;
    initialize_color_array(l_array_of_number);

    FOR l_index IN 1 .. p_num_colors LOOP

      IF p_colors(l_index) = BSC_COLOR_REPOSITORY.NO_COLOR THEN
        x_color := BSC_COLOR_REPOSITORY.NO_COLOR;
        x_kpi_index := l_index;
        RETURN;
      END IF;


      IF l_array_of_number(p_colors(l_index)) > 0 THEN
        l_array_of_number(p_colors(l_index)) := l_array_of_number(p_colors(l_index)) + 1;
      ELSE
        l_array_of_number(p_colors(l_index)) := 1;
      END IF;

    END LOOP;

    l_max_count := get_max_count(l_array_of_number);

    get_colors_with_max_count(l_array_of_number
                            , l_max_count
                            , l_colors_array
                            , l_color_count);



    IF(l_color_count=1 and l_max_count > 1) THEN
       x_color := l_colors_array(1);
       FOR i in 1..p_colors.COUNT LOOP
          if( p_colors(i)=x_color) THEN
             x_kpi_index := i;
             EXIT;
           END IF;
        END LOOP;


    ELSE
             FOR i IN REVERSE 1..l_colors_array.COUNT LOOP
               x_color := l_colors_array(i);
               EXIT;
             END LOOP;
             FOR i IN 1..p_colors.COUNT LOOP
                IF(p_colors(i)=x_color) THEN
                   x_kpi_index := i;
                   EXIT;
                END IF;
             END LOOP;
   END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.get_most_frequent_color');
    --RETURN NULL;
END get_most_frequent_color;


PROCEDURE get_rollup_obj_color (
  p_rollup_type IN bsc_kpis_b.color_rollup_type%TYPE
, p_colors      IN BSC_UPDATE_UTIL.t_array_of_number
, p_num_colors  IN NUMBER
, x_color       OUT NOCOPY NUMBER
, x_kpi_index   OUT NOCOPY NUMBER
) IS
BEGIN
  IF p_rollup_type = BEST THEN
    get_best_color(p_colors, p_num_colors, x_color, x_kpi_index);
  ELSIF p_rollup_type = WORST THEN
    get_worst_color(p_colors, p_num_colors, x_color, x_kpi_index);
  ELSIF p_rollup_type = MOST_FREQUENT THEN
    get_most_frequent_color(p_colors, p_num_colors, x_color, x_kpi_index);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.get_rollup_obj_color');
    --RETURN NULL;
END get_rollup_obj_color;


FUNCTION Get_Default_Kpi_Measure_Id (
  p_objective_id  IN NUMBER
)
RETURN NUMBER IS

  CURSOR c_default_kpi(p_indicator NUMBER) IS
    SELECT m.kpi_measure_id
      FROM bsc_db_dataset_dim_sets_v m,
           bsc_db_color_ao_defaults_v d
      WHERE m.indicator = d.indicator
      AND   m.a0 = d.a0_default
      AND   m.a1 = d.a1_default
      AND   m.a2 = d.a2_default
      AND   m.default_value = 1
      AND   m.indicator = p_indicator;

  l_default_kpi_measure_id  bsc_kpi_measure_props.kpi_measure_id%TYPE;

BEGIN

  l_default_kpi_measure_id := NULL;

  IF c_default_kpi%ISOPEN THEN
    CLOSE c_default_kpi;
  END IF;
  OPEN c_default_kpi (p_objective_id);
  FETCH c_default_kpi INTO l_default_kpi_measure_id;
  IF c_default_kpi%NOTFOUND THEN
    RETURN NULL;
  END IF;
  CLOSE c_default_kpi;

  RETURN l_default_kpi_measure_id;

EXCEPTION
  WHEN OTHERS THEN
    IF c_default_kpi%ISOPEN THEN
      CLOSE c_default_kpi;
    END IF;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.Get_Default_Kpi_Measure_Id');
    RETURN NULL;
END Get_Default_Kpi_Measure_Id;


PROCEDURE Calc_Obj_Color_By_Default_Kpi (
  p_objective_color_rec  IN BSC_UPDATE_COLOR.t_objective_color_rec
 ,x_kpi_measure_id       OUT NOCOPY NUMBER
 ,x_color_flag           OUT NOCOPY BOOLEAN
) IS

  l_default_kpi_measure_id  bsc_kpi_measure_props.kpi_measure_id%TYPE;

BEGIN

  IF p_objective_color_rec.sim_flag THEN -- Simulation Objective
    l_default_kpi_measure_id := Get_Sim_Default_Kpi_Measure_Id(p_objective_color_rec.objective_id);
  ELSE
    l_default_kpi_measure_id := Get_Default_Kpi_Measure_Id(p_objective_color_rec.objective_id);
  END IF;

  IF l_default_kpi_measure_id IS NULL THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  INSERT /*+ append */
    INTO bsc_sys_objective_colors
    (tab_id, indicator, dim_level1, dim_level2, dim_level3, dim_level4, dim_level5, dim_level6, dim_level7, dim_level8, period_id, obj_color, driving_kpi_measure_id)
      SELECT tab_id, indicator, dim_level1, dim_level2, dim_level3, dim_level4, dim_level5, dim_level6, dim_level7, dim_level8, period_id, kpi_color, kpi_measure_id
        FROM bsc_sys_kpi_colors
        WHERE kpi_measure_id = l_default_kpi_measure_id
        AND   tab_id = p_objective_color_rec.tab_id
        AND   indicator = p_objective_color_rec.objective_id;

  COMMIT;

  x_kpi_measure_id := l_default_kpi_measure_id;
  x_color_flag     := true;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_COLOR_CALC_UTIL.Calc_Obj_Color_By_Default_Kpi');
    x_color_flag     := false;
    x_kpi_measure_id := -1;
    --RETURN FALSE;
END Calc_Obj_Color_By_Default_Kpi;


FUNCTION Get_Obj_Color_Rollup_Type (
  p_objective_id  IN NUMBER
)
RETURN VARCHAR2 IS

  CURSOR c_rollup_type(p_indicator NUMBER) IS
    SELECT color_rollup_type
      FROM bsc_kpis_b
      WHERE indicator = p_indicator;

  l_rollup_type  bsc_kpis_b.color_rollup_type%TYPE;

BEGIN

  l_rollup_type := NULL;

  IF p_objective_id IS NOT NULL THEN
    IF c_rollup_type%ISOPEN THEN
      CLOSE c_rollup_type;
    END IF;
    OPEN c_rollup_type (p_objective_id);
    FETCH c_rollup_type INTO l_rollup_type;
    IF c_rollup_type%NOTFOUND THEN
      RETURN NULL;
    END IF;
    CLOSE c_rollup_type;
  END IF;

  RETURN l_rollup_type;

EXCEPTION
  WHEN OTHERS THEN
    IF c_rollup_type%ISOPEN THEN
      CLOSE c_rollup_type;
    END IF;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source  => 'BSC_COLOR_CALC_UTIL.Get_Obj_Color_Rollup_Type');
    RETURN NULL;
END Get_Obj_Color_Rollup_Type;

END BSC_COLOR_CALC_UTIL;

/
