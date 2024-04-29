--------------------------------------------------------
--  DDL for Package Body BSC_UPDATE_COLOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_UPDATE_COLOR" AS
/* $Header: BSCDCOLB.pls 120.15.12010000.3 2008/09/18 09:40:23 bijain ship $ */


FUNCTION Color_Kpi_Measure (
  p_kpi_measure_id       IN NUMBER
, p_objective_color_rec  IN t_objective_color_rec
, p_dim_combination      IN BSC_UPDATE_UTIL.t_array_of_number
, p_num_families         IN NUMBER
)
RETURN BOOLEAN;

FUNCTION Calculate_KPI_Color (
  p_objective_id        IN NUMBER
, p_kpi_measure_id      IN NUMBER
, p_calc_color_flag     IN BOOLEAN
)
RETURN BOOLEAN;

PROCEDURE Calculate_Objective_Color (
  p_objective_color_rec  IN BSC_UPDATE_COLOR.t_objective_color_rec
 ,x_kpi_measure_id       OUT NOCOPY NUMBER
 ,x_color_flag           OUT NOCOPY BOOLEAN
);

FUNCTION calculate_kpi_trend_icon (
  x_tab_id        IN NUMBER
, x_indicator     IN NUMBER
, x_measure_id    IN NUMBER
, x_color_method  IN NUMBER
, x_calc_obj_trend IN BOOLEAN
, x_not_pl_not_initiative in BOOLEAN
) RETURN BOOLEAN;

--BugFix 6142563
FUNCTION is_ytd_default_calc(
    p_indicator IN NUMBER
 ,  p_kpi_measure_id IN NUMBER
 ) RETURN BOOLEAN IS

 CURSOR c_default_calc IS
 SELECT default_calculation
 FROM   bsc_kpi_measure_props
 WHERE  indicator      = p_indicator
 AND    kpi_measure_id = p_kpi_measure_id;

 l_default_calc bsc_kpi_measure_props.default_calculation%TYPE;
BEGIN
   OPEN  c_default_calc;
   FETCH c_default_calc INTO l_default_calc;
   CLOSE c_default_calc;

   IF l_default_calc = 2 THEN
     RETURN TRUE;
   ELSE
     RETURN FALSE;
   END IF;

  EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_COLOR.is_ytd_default_calc');
    RETURN FALSE;
END is_ytd_default_calc;



FUNCTION Color_Kpis_In_Objective (
  p_objective_color_rec  IN t_objective_color_rec
)
RETURN BOOLEAN IS

  e_unexpected_error EXCEPTION;
  /* Modified the code to not calculate colors for
   * calculated Kpi for AGReport but do calculate
   * colors for calculated kpi in case of simtree.
   */
  CURSOR c_objective_kpis(p_indicator NUMBER) IS
   SELECT  kpi_props.kpi_measure_id,
	   kpi_props.disable_color,
           sys_dset.source
   FROM bsc_kpi_measure_props kpi_props,
           bsc_kpi_analysis_measures_b kpi_meas,
           bsc_sys_datasets_b sys_dset
   WHERE kpi_props.indicator = p_indicator
     AND kpi_props.kpi_measure_id = kpi_meas.kpi_measure_id
     AND kpi_meas.dataset_id = sys_dset.dataset_id;

  l_objective_kpis  c_objective_kpis%ROWTYPE;

  TYPE t_cursor IS REF CURSOR;
  h_cursor t_cursor;

  h_sql              VARCHAR2(2000);
  h_dim_combination  BSC_UPDATE_UTIL.t_array_of_number;
  h_num_families     NUMBER;
  h_last_com_index   NUMBER;
  h_com_index        NUMBER;
  h_family_index     NUMBER;
  h_dim_index        NUMBER;
  l_message          VARCHAR2(4000);

  l_ag_report        BOOLEAN;
  l_config_type      BSC_KPIS_B.CONFIG_TYPE%TYPE;
  l_short_name       BSC_KPIS_B.SHORT_NAME%TYPE;
BEGIN

    SELECT config_type, short_name into l_config_type,l_short_name
    FROM bsc_kpis_b
    WHERE indicator=p_objective_color_rec.objective_id;

    l_ag_report := (l_short_name is not null) and l_config_type <> 7;
  FOR l_objective_kpis IN c_objective_kpis(p_objective_color_rec.objective_id) LOOP

    -- We will force the color calculation of all the KPIs under the Objective irrespective of the
    -- prototype_flag being 7 or not.
    IF (l_objective_kpis.disable_color IS NULL OR l_objective_kpis.disable_color <> 'T') THEN
     IF(l_ag_report = FALSE OR (l_ag_report = TRUE and l_objective_kpis.source <> 'CDS')) THEN
      l_message := BSC_UPDATE_UTIL.Get_Message('BSC_COLOR_KPI_START');
      l_message := BSC_UPDATE_UTIL.Replace_Token(l_message, 'KPI_MEASURE_ID', TO_CHAR(l_objective_kpis.kpi_measure_id));
      BSC_UPDATE_LOG.Write_Line_log(l_message, BSC_UPDATE_LOG.OUTPUT);

      -- color per each combination of dimension of different families
      -- in the tab list

      -- Number of families of the tab list
      h_num_families := 0;

      h_sql := 'SELECT COM_INDEX, FAMILY_INDEX, DIM_INDEX'||
                 ' FROM BSC_TMP_TAB_COM'||
                 ' WHERE TAB_ID = :1'||
                 ' ORDER BY COM_INDEX, FAMILY_INDEX';

      h_last_com_index := -1;

      OPEN h_cursor FOR h_sql USING p_objective_color_rec.tab_id;
      FETCH h_cursor INTO h_com_index, h_family_index, h_dim_index;
      WHILE h_cursor%FOUND LOOP
        IF (h_last_com_index <> h_com_index) AND (h_last_com_index <> -1) THEN
          --AW_INTEGRATION: pass h_aw_flag to this function
          IF NOT Color_Kpi_Measure ( l_objective_kpis.kpi_measure_id
    	                           , p_objective_color_rec
    	                           , h_dim_combination
                                   , h_num_families) THEN
            RAISE e_unexpected_error;
          END IF;
        END IF;

        h_num_families := h_family_index + 1;
        h_dim_combination(h_family_index) := h_dim_index;

        h_last_com_index := h_com_index;

        FETCH h_cursor INTO h_com_index, h_family_index, h_dim_index;

      END LOOP;
      CLOSE h_cursor;

      --AW_INTEGRATION: pass h_aw_flag to this function
      IF NOT Color_Kpi_Measure ( l_objective_kpis.kpi_measure_id
                               , p_objective_color_rec
                               , h_dim_combination
                               , h_num_families) THEN
        RAISE e_unexpected_error;
      END IF;

      l_message := BSC_UPDATE_UTIL.Get_Message('BSC_COLOR_KPI_COMPLETE');
      l_message := BSC_UPDATE_UTIL.Replace_Token(l_message, 'KPI_MEASURE_ID', TO_CHAR(l_objective_kpis.kpi_measure_id));
      BSC_UPDATE_LOG.Write_Line_log(l_message, BSC_UPDATE_LOG.OUTPUT);

      COMMIT;

    ELSE
      l_message := BSC_UPDATE_UTIL.Get_Message('BSC_COLOR_KPI_SKIP');
      l_message := BSC_UPDATE_UTIL.Replace_Token(l_message, 'KPI_MEASURE_ID', TO_CHAR(l_objective_kpis.kpi_measure_id));
      BSC_UPDATE_LOG.Write_Line_log(l_message, BSC_UPDATE_LOG.OUTPUT);
    END IF;
   END IF;
  END LOOP;

  RETURN TRUE;

EXCEPTION
  WHEN e_unexpected_error THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_KPICOLOR_FAILED'),
                    x_source => 'BSC_UPDATE_COLOR.Color_Kpis_In_Objective');
    RETURN FALSE;
  WHEN OTHERS THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_COLOR.Color_Kpis_In_Objective');
    RETURN FALSE;
END Color_Kpis_In_Objective;


FUNCTION Color_Kpi_Measure (
  p_kpi_measure_id       IN NUMBER
, p_objective_color_rec  IN t_objective_color_rec
, p_dim_combination      IN BSC_UPDATE_UTIL.t_array_of_number
, p_num_families         IN NUMBER
)
RETURN BOOLEAN IS

  e_unexpected_error EXCEPTION;
  l_kpi_dim_props    BSC_UPDATE_UTIL.t_kpi_dim_props_rec;
  l_measure_formula  bsc_db_color_measures_v.measure_formula%TYPE;
  l_color_by_total   bsc_kpi_measure_props.color_by_total%TYPE;
  l_apply_color_flag bsc_kpi_measure_props.apply_color_flag%TYPE;
  l_calc_color_flag  BOOLEAN;

BEGIN

  -- Get the dim_set_id and  comp_level_pk_col for the KPI Measure
  BSC_UPDATE_UTIL.Get_Kpi_Dim_Props ( p_objective_id   => p_objective_color_rec.objective_id
                                    , p_kpi_measure_id => p_kpi_measure_id
                                    , x_dim_props_rec  => l_kpi_dim_props
                                    );

  -- Get the measure formula
  l_measure_formula := BSC_UPDATE_UTIL.Get_Measure_Formula ( p_objective_id   => p_objective_color_rec.objective_id
                                                           , p_kpi_measure_id => p_kpi_measure_id
                                                           , p_sim_objective  => p_objective_color_rec.sim_flag
                                                           );

  l_measure_formula := BSC_UPDATE_UTIL.Get_Free_Div_Zero_Expression(l_measure_formula);
  IF l_measure_formula IS NULL THEN
    RAISE e_unexpected_error;
  END IF;

  l_color_by_total := BSC_UPDATE_UTIL.Get_Color_By_Total ( p_objective_id   => p_objective_color_rec.objective_id
                                                         , p_kpi_measure_id => p_kpi_measure_id
                                                         );

  IF l_color_by_total IS NULL THEN
    RAISE e_unexpected_error;
  END IF;

  l_apply_color_flag := BSC_UPDATE_UTIL.Get_Apply_Color_Flag ( p_objective_id   => p_objective_color_rec.objective_id
                                                             , p_kpi_measure_id => p_kpi_measure_id
                                                             --, p_sim_objective  => p_objective_color_rec.sim_flag
                                                             );

  IF l_apply_color_flag IS NULL THEN
    RAISE e_unexpected_error;
  ELSE
    IF l_apply_color_flag = 1 THEN
      l_calc_color_flag := TRUE;
    ELSE
      l_calc_color_flag := FALSE;
    END IF;
  END IF;

  IF NOT Color_Indic_Dim_Combination( p_objective_color_rec.objective_id
                                    , p_kpi_measure_id
                           	    , l_calc_color_flag
                                    , p_objective_color_rec.obj_pl_flag
                                    , p_objective_color_rec.obj_initiatives_flag
                                    , p_objective_color_rec.obj_precalculated_flag
                                    , p_objective_color_rec.tab_id
                                    , p_dim_combination
                                    , p_num_families
                                    , p_objective_color_rec.periodicity_id
                                    , l_kpi_dim_props.comp_level_pk_col
                                    , l_kpi_dim_props.dim_set_id
                                    , l_color_by_total
                                    , l_measure_formula
                                    , p_objective_color_rec.current_fy
                                    , p_objective_color_rec.aw_flag
                                    ) THEN
    RAISE e_unexpected_error;
  END IF;

  RETURN TRUE;

EXCEPTION
  WHEN e_unexpected_error THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_KPICOLOR_FAILED'),
                    x_source => 'BSC_UPDATE_COLOR.Color_Kpi_Measure');
    RETURN FALSE;
  WHEN OTHERS THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_COLOR.Color_Kpi_Measure');
    RETURN FALSE;
END Color_Kpi_Measure;


FUNCTION Get_Color_Method (
  p_objective_id     IN NUMBER
 ,p_kpi_measure_id   IN NUMBER
) RETURN NUMBER IS
  l_color_method   NUMBER;
  l_config_type    NUMBER;
BEGIN
  SELECT config_type
  INTO   l_config_type
  FROM   bsc_kpis_b
  WHERE  indicator=p_objective_id;

  IF( l_config_type = 3) THEN
    l_color_method := 1;

  ELSE
    SELECT color_method
    INTO   l_color_method
    FROM   bsc_sys_datasets_b ds
          ,bsc_kpi_analysis_measures_b am
    WHERE  ds.dataset_id = am.dataset_id
    AND    am.indicator = p_objective_id
    AND    am.kpi_measure_id = p_kpi_measure_id;
  END IF;

  RETURN l_color_method;
END;


FUNCTION update_actual_budget_for_mcc (
  p_objective_id    IN NUMBER
, p_kpi_measure_id  IN NUMBER
, p_tab_id          IN NUMBER
, p_lst_keys_insert IN VARCHAR2
) RETURN BOOLEAN
IS
  TYPE t_cursor IS REF CURSOR;
  l_color_method        NUMBER;
  l_sql_mcc             VARCHAR2(32700);
  l_sql_mcc_actual_plan VARCHAR2(32700);
  l_dim_comb            VARCHAR2(100);
  l_lst_keys_insert     VARCHAR2(100);
  l_period              NUMBER;
  l_mcc_color           NUMBER;
  l_mcc_perf_seq        NUMBER;
  l_real                NUMBER;
  l_plan                NUMBER;
  l_cumpercent          NUMBER;
  l_tmp_cumpercent      NUMBER;
  l_mcc_real            NUMBER;
  l_mcc_plan            NUMBER;
  l_tmp_cumpercent_diff NUMBER;
  l_num_keys            NUMBER;
  l_mcc_cursor             t_cursor;
  l_mcc_actual_plan_cursor t_cursor;
  l_lst_keys_insert_array  BSC_UPDATE_UTIL.t_array_of_varchar2;
  l_lst_keys_array         BSC_UPDATE_UTIL.t_array_of_varchar2;

BEGIN

  -- p_lst_keys_insert can be of the following format:
  -- KEY1, 0, 0, 0, 0, 0, 0, 0,
  -- 0, KEY1, 0, 0, 0, 0, 0, 0,
  -- Remove trailing comma (,)
  l_lst_keys_insert := SUBSTR(p_lst_keys_insert, 1, instr(p_lst_keys_insert, ',', -1) - 1);
  l_num_keys := BSC_UPDATE_UTIL.decompose_varchar2_list(l_lst_keys_insert, l_lst_keys_insert_array, ',');
  FOR l_index IN 1 .. l_lst_keys_insert_array.COUNT LOOP
    IF (l_lst_keys_insert_array(l_index) = '0') THEN
      l_lst_keys_insert_array(l_index) := '''$#''';
    END IF;
  END LOOP;
  l_lst_keys_insert := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(l_lst_keys_insert_array, l_num_keys);

  l_color_method := get_color_method(p_objective_id, p_kpi_measure_id);

  l_sql_mcc := 'SELECT ' || l_lst_keys_insert || ', period, col_b.color_id FROM ( ' ||
	       ' SELECT ' || l_lst_keys_insert || ', period ,  MAX(col_b.perf_sequence) mcc ' ||
	       ' FROM bsc_tmp_colors tem_c, bsc_sys_colors_b col_b ' ||
	       ' WHERE tem_c.color = col_b.color_id ' ||
	       ' GROUP BY ' || l_lst_keys_insert || ' , period ' ||
	       ' ) bsc_tmp_colors_mcc, bsc_sys_colors_b col_b ' ||
               ' WHERE bsc_tmp_colors_mcc.mcc = col_b.perf_sequence ';

  OPEN l_mcc_cursor FOR l_sql_mcc;
  FETCH l_mcc_cursor INTO l_lst_keys_array(1), l_lst_keys_array(2), l_lst_keys_array(3), l_lst_keys_array(4), l_lst_keys_array(5), l_lst_keys_array(6), l_lst_keys_array(7), l_lst_keys_array(8) , l_period, l_mcc_color;
  WHILE l_mcc_cursor%FOUND LOOP

    l_tmp_cumpercent := NULL;
    l_tmp_cumpercent_diff := NULL;
    l_mcc_real := NULL;
    l_mcc_plan := NULL;

    l_sql_mcc_actual_plan := 'SELECT vreal, vplan, cumpercent ' ||
                             ' FROM bsc_tmp_colors tem_c ' ||
                             ' WHERE tem_c.color = ' || l_mcc_color;

    FOR l_index IN 1 .. l_lst_keys_insert_array.COUNT LOOP
      l_sql_mcc_actual_plan := l_sql_mcc_actual_plan ||
                               ' AND ' || l_lst_keys_insert_array(l_index) || ' = DECODE(''' || l_lst_keys_array(l_index) || ''', ''$#'', ' || l_lst_keys_insert_array(l_index) || ', ''' || l_lst_keys_array(l_index) || ''') ';
    END LOOP;
    l_sql_mcc_actual_plan := l_sql_mcc_actual_plan ||
                             ' AND period = ' || l_period;

    OPEN l_mcc_actual_plan_cursor FOR l_sql_mcc_actual_plan;
    FETCH l_mcc_actual_plan_cursor INTO l_real, l_plan, l_cumpercent;
    WHILE l_mcc_actual_plan_cursor%FOUND LOOP
      -- For a single call to this API, only one of the following conditions will be TRUE
      IF (l_color_method = 1) THEN
        -- the one with lowest cumpercent will be chosen
        IF l_tmp_cumpercent IS NULL THEN
          l_tmp_cumpercent := l_cumpercent;
          l_mcc_plan := l_plan;
          l_mcc_real := l_real;
        ELSE
          -- (l_real < l_mcc_real) is just a convention being followed so that we get unique values
          IF (l_cumpercent < l_tmp_cumpercent) OR (l_cumpercent = l_tmp_cumpercent AND l_real < l_mcc_real) THEN
            l_mcc_plan := l_plan;
            l_mcc_real := l_real;
            l_tmp_cumpercent := l_cumpercent;
          END IF;
        END IF;
      ELSIF (l_color_method = 2) THEN
        -- the one with highest cumpercent will be chosen
        IF l_tmp_cumpercent IS NULL THEN
          l_tmp_cumpercent := l_cumpercent;
          l_mcc_plan := l_plan;
          l_mcc_real := l_real;
        ELSE
          -- (l_real > l_mcc_real) is just a convention being followed so that we get unique values
          IF (l_cumpercent > l_tmp_cumpercent) OR (l_cumpercent = l_tmp_cumpercent AND l_real > l_mcc_real) THEN
            l_mcc_plan := l_plan;
            l_mcc_real := l_real;
            l_tmp_cumpercent := l_cumpercent;
          END IF;
        END IF;
      ELSIF (l_color_method = 3) THEN
        -- the one with cumpercent closest to 100 will be chosen
        IF l_tmp_cumpercent_diff IS NULL THEN
          l_tmp_cumpercent_diff := ABS(l_cumpercent - 100);
          l_mcc_plan := l_plan;
          l_mcc_real := l_real;
        ELSE
          -- (l_real > l_mcc_real) is just a convention being followed so that we get unique values
          IF (ABS(l_cumpercent - 100) > l_tmp_cumpercent_diff) OR (ABS(l_cumpercent - 100) = l_tmp_cumpercent_diff AND l_real > l_mcc_real) THEN
            l_mcc_plan := l_plan;
            l_mcc_real := l_real;
            l_tmp_cumpercent_diff := ABS(l_cumpercent - 100);
          END IF;
        END IF;
      END IF;

      FETCH l_mcc_actual_plan_cursor INTO l_real, l_plan, l_cumpercent;
    END LOOP;
    CLOSE l_mcc_actual_plan_cursor;

    IF l_mcc_real IS NOT NULL THEN

      UPDATE bsc_sys_kpi_colors
        SET actual_data = l_mcc_real, budget_data = l_mcc_plan
        WHERE tab_id    = p_tab_id
        AND   indicator = p_objective_id
        AND   kpi_measure_id = p_kpi_measure_id
        AND   dim_level1 = DECODE(l_lst_keys_array(1), '$#', '0', l_lst_keys_array(1))
        AND   dim_level2 = DECODE(l_lst_keys_array(2), '$#', '0', l_lst_keys_array(2))
        AND   dim_level3 = DECODE(l_lst_keys_array(3), '$#', '0', l_lst_keys_array(3))
        AND   dim_level4 = DECODE(l_lst_keys_array(4), '$#', '0', l_lst_keys_array(4))
        AND   dim_level5 = DECODE(l_lst_keys_array(5), '$#', '0', l_lst_keys_array(5))
        AND   dim_level6 = DECODE(l_lst_keys_array(6), '$#', '0', l_lst_keys_array(6))
        AND   dim_level7 = DECODE(l_lst_keys_array(7), '$#', '0', l_lst_keys_array(7))
        AND   dim_level8 = DECODE(l_lst_keys_array(8), '$#', '0', l_lst_keys_array(8))
        AND   period_id = l_period;

    END IF;

    FETCH l_mcc_cursor INTO l_lst_keys_array(1), l_lst_keys_array(2), l_lst_keys_array(3), l_lst_keys_array(4), l_lst_keys_array(5), l_lst_keys_array(6), l_lst_keys_array(7), l_lst_keys_array(8) , l_period, l_mcc_color;
  END LOOP;
  CLOSE l_mcc_cursor;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source  => 'BSC_UPDATE_COLOR.update_actual_budget_for_mcc');
    RETURN FALSE;
END update_actual_budget_for_mcc;


FUNCTION get_trend_flag(p_color_method IN NUMBER,
                        p_actual       IN NUMBER,
                        p_prior        IN NUMBER
) RETURN NUMBER
IS
 l_trendflag NUMBER;
BEGIN
  IF(p_color_method=1) THEN
    IF (p_actual>p_prior) THEN
       l_trendflag := 0;
    ELSIF (p_actual<p_prior) THEN
       l_trendflag := 3;
    ELSE
       l_trendflag := 4;
    END IF;
  ELSIF (p_color_method=2) THEN
    IF (p_actual>p_prior) THEN
       l_trendflag := 2;
    ELSIF (p_actual<p_prior) THEN
       l_trendflag := 1;
    ELSE
       l_trendflag := 4;
    END IF;
  ELSIF (p_color_method=3) THEN
    IF (p_actual>p_prior) THEN
       l_trendflag := 2;
    ELSIF (p_actual<p_prior) THEN
       l_trendflag := 3;
    ELSE
       l_trendflag := 4;
    END IF;
  END IF;

  RETURN l_trendflag;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_COLOR.get_trend_flag');
    RETURN 5;--No Data
END get_trend_flag;

--BugFix 6000042 Trend for Comparison Mode
PROCEDURE update_trend_for_comparison(
        p_indic_code                IN NUMBER,
        p_kpi_measure_id            IN NUMBER,
        p_tab_id                    IN NUMBER,
        p_lst_keys_insert           IN VARCHAR2,
        p_sql_mcc                   IN VARCHAR2
          ) IS

    TYPE t_cursor IS REF CURSOR;
    h_sql_trend            VARCHAR2(32700);
    h_actualvalue_sql      VARCHAR2(32700);
    h_priorvalue_sql       VARCHAR2(32700);
    h_match_sql            VARCHAR2(32700);
    h_match_cursor         t_cursor;
    h_trend_cursor         t_cursor;
    h_actual_value_cursor  t_cursor;
    h_prior_value_cursor   t_cursor;
    h_trend_period  NUMBER;
    h_trend_color   NUMBER;

    h_trend_vreal   NUMBER;
    h_color_method   NUMBER;
    h_key1 NUMBER;
    h_key2 NUMBER;
    h_key3 NUMBER;
    h_key4 NUMBER;
    h_key5 NUMBER;
    h_key6 NUMBER;
    h_key7 NUMBER;
    h_key8 NUMBER;
    --Added today
    h_prev_period NUMBER;
    h_trend_keys  VARCHAR2(100);
    l_index       NUMBER := 1;
    l_key_rec     t_key_rec;
    l_key_tbl     BSC_UPDATE_COLOR.t_key_tbl_type;
    l_first_time  BOOLEAN := true;
    l_prev_real   NUMBER;
    l_count       NUMBER;
    --l_starttime   timestamp;
    --l_endtime     timestamp;
BEGIN
   --l_starttime := sysdate;
   --BugFix 6142563
   IF is_ytd_default_calc( p_indicator      => p_indic_code
                         , p_kpi_measure_id => p_kpi_measure_id) THEN
       RETURN;
   END IF;
   h_color_method := Get_Color_Method(p_indic_code,p_kpi_measure_id);
   h_sql_trend := ' SELECT '||p_lst_keys_insert||'PERIOD, COL_B.COLOR_ID '||
                 ' FROM ('||p_sql_mcc||') BSC_TMP_COLORS_MCC, BSC_SYS_COLORS_B COL_B'||
                 ' WHERE BSC_TMP_COLORS_MCC.MCC = COL_B.PERF_SEQUENCE '||
                 ' ORDER BY PERIOD ';
   OPEN h_trend_cursor FOR h_sql_trend;
   FETCH h_trend_cursor INTO h_key1,h_key2,h_key3,h_key4,h_key5,h_key6,h_key7,h_key8,h_trend_period, h_trend_color;
   WHILE h_trend_cursor%FOUND LOOP
        h_actualvalue_sql := 'SELECT VREAL, nvl(key1,0)||nvl(key2,0)||nvl(key3,0)||nvl(key4,0)||nvl(key5,0)||nvl(key6,0)||nvl(key7,0)||nvl(key8,0) DV_COMB '||
                        ' FROM BSC_TMP_COLORS '||
                        ' WHERE PERIOD=:1 AND COLOR=:2 '||
                        ' AND ('||h_key1||'=0 OR nvl(key1,0)='||h_key1||')'||
                        ' AND ('||h_key2||'=0 OR nvl(key2,0)='||h_key2||')'||
                        ' AND ('||h_key3||'=0 OR nvl(key3,0)='||h_key3||')'||
                        ' AND ('||h_key4||'=0 OR nvl(key4,0)='||h_key4||')'||
                        ' AND ('||h_key5||'=0 OR nvl(key5,0)='||h_key5||')'||
                        ' AND ('||h_key6||'=0 OR nvl(key6,0)='||h_key6||')'||
                        ' AND ('||h_key7||'=0 OR nvl(key7,0)='||h_key7||')'||
                        ' AND ('||h_key8||'=0 OR nvl(key8,0)='||h_key8||')'||
                        ' ORDER BY PERIOD, DV_COMB ';
        l_first_time := true;

        OPEN h_actual_value_cursor FOR h_actualvalue_sql USING h_trend_period, h_trend_color;-- USING h_key1,h_key2,h_key3,h_key4,h_key5,h_key6,h_key7,h_key8,h_trend_period, h_trend_color;
        FETCH h_actual_value_cursor INTO h_trend_vreal, h_trend_keys;
        WHILE h_actual_value_cursor%FOUND LOOP
          l_count := 0;
          h_match_sql := ' SELECT count(*) FROM bsc_sys_kpi_colors '||
                        ' WHERE tab_id=:1 AND indicator=:2 AND kpi_measure_id=:3 '||
                        ' AND PERIOD_ID=:4 AND KPI_COLOR=:5 '||
                        ' AND ACTUAL_DATA=:6 '||
                        ' AND ('||h_key1||'=0 OR nvl(DIM_LEVEL1,0)='||h_key1||')'||
                        ' AND ('||h_key2||'=0 OR nvl(DIM_LEVEL2,0)='||h_key2||')'||
                        ' AND ('||h_key3||'=0 OR nvl(DIM_LEVEL3,0)='||h_key3||')'||
                        ' AND ('||h_key4||'=0 OR nvl(DIM_LEVEL4,0)='||h_key4||')'||
                        ' AND ('||h_key5||'=0 OR nvl(DIM_LEVEL5,0)='||h_key5||')'||
                        ' AND ('||h_key6||'=0 OR nvl(DIM_LEVEL6,0)='||h_key6||')'||
                        ' AND ('||h_key7||'=0 OR nvl(DIM_LEVEL7,0)='||h_key7||')'||
                        ' AND ('||h_key8||'=0 OR nvl(DIM_LEVEL8,0)='||h_key8||')';

          OPEN h_match_cursor FOR h_match_sql USING p_tab_id, p_indic_code, p_kpi_measure_id, h_trend_period, h_trend_color, h_trend_vreal;
          FETCH h_match_cursor INTO l_count;
          CLOSE h_match_cursor;

          IF ( (l_count > 0) AND (l_first_time) ) THEN
            l_key_rec.dimvalues := h_key1||h_key2||h_key3||h_key4||h_key5||h_key6||h_key7||h_key8;
            l_key_rec.period    := h_trend_period;
            l_key_rec.vreal     := h_trend_vreal;
            IF (h_trend_period = 1) THEN
              l_key_rec.trend   := 5;
              l_key_rec.vprev   := null;
            ELSE
              l_key_rec.trend   := 5;
              h_priorvalue_sql := 'SELECT VREAL, nvl(key1,0)||nvl(key2,0)||nvl(key3,0)||nvl(key4,0)||nvl(key5,0)||nvl(key6,0)||nvl(key7,0)||nvl(key8,0) DV_COMB '||
                        ' FROM BSC_TMP_COLORS '||
                        ' WHERE PERIOD=:1 '||
                        ' AND nvl(key1,0)||nvl(key2,0)||nvl(key3,0)||nvl(key4,0)||nvl(key5,0)||nvl(key6,0)||nvl(key7,0)||nvl(key8,0)=:2 '||
                        ' ORDER BY PERIOD, DV_COMB ';
              h_prev_period := h_trend_period - 1;
              OPEN h_prior_value_cursor FOR h_priorvalue_sql USING h_prev_period, h_trend_keys;
              FETCH h_prior_value_cursor INTO l_prev_real, h_trend_keys;
              WHILE h_prior_value_cursor%FOUND LOOP
                 IF (l_prev_real IS NULL) THEN
                   l_key_rec.trend   := 5;
                   l_key_rec.vprev   := null;
                 ELSE
                   l_key_rec.trend := get_trend_flag(h_color_method, h_trend_vreal, l_prev_real);
                   l_key_rec.vprev   := l_prev_real;
                 END IF;
                FETCH h_prior_value_cursor INTO l_prev_real, h_trend_keys;
              END LOOP;
              CLOSE h_prior_value_cursor;
            END IF;
            l_key_tbl(l_index)  := l_key_rec;
            l_index := l_index + 1;
            l_first_time := false;

          END IF;
          FETCH h_actual_value_cursor INTO h_trend_vreal, h_trend_keys;
       END LOOP;
       CLOSE h_actual_value_cursor;
       FETCH h_trend_cursor INTO h_key1,h_key2,h_key3,h_key4,h_key5,h_key6,h_key7,h_key8, h_trend_period, h_trend_color;

   END LOOP;
   CLOSE h_trend_cursor;

   IF (l_key_tbl.COUNT > 0) THEN
      FOR i in l_key_tbl.FIRST..l_key_tbl.LAST LOOP
          l_key_rec := l_key_tbl(i);

          UPDATE bsc_sys_kpi_colors
          SET    kpi_trend      = l_key_rec.trend
          WHERE  tab_id         = p_tab_id
          AND    indicator      = p_indic_code
          AND    kpi_measure_id = p_kpi_measure_id
          AND    period_id      = l_key_rec.period
          AND    nvl(dim_level1,0)||nvl(dim_level2,0)||nvl(dim_level3,0)||nvl(dim_level4,0)||nvl(dim_level5,0)||nvl(dim_level6,0)||nvl(dim_level7,0)||nvl(dim_level8,0) = l_key_rec.dimvalues;
      END LOOP;
   END IF;

   --l_endtime := sysdate;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_COLOR.update_trend_for_comparison');
END update_trend_for_comparison;

/*===========================================================================+
| FUNCTION  Color_Indic_Dim_Combination
+============================================================================*/

FUNCTION Color_Indic_Dim_Combination(
        x_indic_code                IN NUMBER,
        x_kpi_measure_id            IN NUMBER,
        x_calc_color_flag           IN BOOLEAN,
        x_indic_pl_flag             IN BOOLEAN,
        x_indic_initiatives_flag    IN BOOLEAN,
        x_indic_precalculated_flag  IN BOOLEAN,
        x_tab_id                    IN NUMBER,
        x_dim_combination           IN BSC_UPDATE_UTIL.t_array_of_number,
        x_num_families              IN NUMBER,
        x_periodicity_id            IN NUMBER,
        x_comp_level_pk_col         IN VARCHAR2,
        x_dim_set_id                IN NUMBER,
        x_color_by_total            IN NUMBER,
        x_measure_formula           IN VARCHAR2,
        x_current_fy                IN NUMBER,
        x_aw_flag                   IN BOOLEAN -- AW_INTEGRATION: need this new parameter
        )
    RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;
    e_no_data_table_error EXCEPTION;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;
    h_cursor1 t_cursor;

    h_i NUMBER;

    h_sql VARCHAR2(32700);
    h_where VARCHAR2(32700);

    h_dim_level_index NUMBER;
    h_family_index NUMBER;
    h_level_pk_col VARCHAR2(30);
    h_level_table_name VARCHAR2(30);

    h_dim_com_keys BSC_UPDATE_UTIL.t_array_of_varchar2;

    -- same info than h_dim_com_keys but the array is from 1 to x_num_families
    h_dim_com_keys_1 BSC_UPDATE_UTIL.t_array_of_varchar2;

    h_table_name VARCHAR2(30);

    h_condition VARCHAR2(2000);
    h_condition_b VARCHAR2(2000);

    h_arr_keys BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_key_columns_temp BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_keys NUMBER;
    h_lst_keys VARCHAR2(2000);
    h_lst_keys_temp VARCHAR2(2000);
    h_key_index NUMBER;

    h_lst_select VARCHAR2(2000);
    h_lst_where VARCHAR2(2000);

    h_lst_keys_insert VARCHAR2(2000);

    h_i_family NUMBER;

    h_i_dimension NUMBER;

    h_dim_level_index_child NUMBER;
    h_level_pk_col_child VARCHAR2(30);
    h_level_table_name_child VARCHAR2(30);

    h_dim_level_index_parent NUMBER;
    h_level_pk_col_parent VARCHAR2(30);
    h_level_table_name_parent VARCHAR2(30);

    h_yearly_flag NUMBER;

    h_sql_mcc VARCHAR2(32000);

    -- BSC-BIS-DIMENSIONS: Need to use varchar2 to suppoer NUMBER/VARCHAR2
    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_varchar2;
    h_num_bind_vars NUMBER;

    h_num_bind_vars_1 NUMBER;
    h_level_comb VARCHAR2(30);

    h_bind_vars_values_n BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars_n NUMBER;

    CURSOR c_table_columns (p_table_name VARCHAR2, p_column_type VARCHAR2) IS
        SELECT column_name
        FROM bsc_db_tables_cols
        WHERE table_name = p_table_name AND column_type = p_column_type;

    h_column_type VARCHAR2(1);
    h_column_name VARCHAR2(30);
    h_lst_tab_columns VARCHAR2(32700);
    h_fact_table VARCHAR2(32700);
    h_mv_name VARCHAR2(30);
    h_data_source VARCHAR2(10);
    h_sql_stmt VARCHAR2(32700);

    --AW_INTEGRATION: new variables
    h_aw_limit_tbl BIS_PMV_PAGE_PARAMETER_TBL;
    h_aw_limit_rec BIS_PMV_PAGE_PARAMETER_REC;
    h_calendar_id NUMBER;
    h_min_per NUMBER;
    h_max_per NUMBER;
    h_per_parameter_value VARCHAR2(100);
    l_ytd_flag  NUMBER;


BEGIN

    h_sql := NULL;
    h_where := NULL;
    h_table_name := NULL;
    h_condition := NULL;
    h_condition_b := NULL;
    h_num_keys := 0;
    h_lst_keys := NULL;
    h_lst_keys_temp := NULL;
    h_lst_select := NULL;
    h_lst_where := NULL;
    h_lst_keys_insert := NULL;

    -- AW_INTEGRATION: init h_aw_limit_tbl
    h_aw_limit_tbl := BIS_PMV_PAGE_PARAMETER_TBL();
    h_aw_limit_tbl.delete;

    -- AW_INTEGRATION: move this line here
    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(x_periodicity_id);
    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(x_periodicity_id);

    -- Initialize the array h_dim_com_keys: key column names of dimension combinations
    -- Example: BRACH_CODE|PROD_CODE

    IF x_num_families > 0 THEN
        FOR h_i IN 0 .. x_num_families - 1 LOOP
            IF h_where IS NULL THEN
                h_where := '(FAMILY_INDEX = '||h_i||' AND DIM_INDEX = '||x_dim_combination(h_i)||')';
            ELSE
                h_where := h_where||' OR'||
                           '(FAMILY_INDEX = '||h_i||' AND DIM_INDEX = '||x_dim_combination(h_i)||')';
            END IF;
        END LOOP;

        h_sql := 'SELECT FAMILY_INDEX, LEVEL_PK_COL'||
                 ' FROM BSC_TMP_TAB_DEF'||
                 ' WHERE TAB_ID = :1'||
                 ' AND ('||h_where||')'||
                 ' ORDER BY FAMILY_INDEX';
        OPEN h_cursor FOR h_sql USING x_tab_id;
        FETCH h_cursor INTO h_family_index, h_level_pk_col;
        WHILE h_cursor%FOUND LOOP
            h_dim_com_keys(h_family_index) := h_level_pk_col;

            FETCH h_cursor INTO h_family_index, h_level_pk_col;
        END LOOP;
        CLOSE h_cursor;
    END IF;

    -- Get the table used by the indicator in this drill combination

    -- NOTE about special indicators
    -- PL Indicators ALWAYS have x_comp_level_pk_col = ACCOUNT_CODE and x_color_by_total = 0.
    -- So the table is going to have ACCOUNT_CODE.
    -- Initiatives Strategic Indicators ALWAYS have x_comp_level_pk_col = PROJECT_CODE
    -- and x_color_by_total = 0. So the table is going to have PROJECT_CODE.
    h_table_name := Get_Table_Used_To_Color(x_indic_code,
                                            x_periodicity_id,
                                            x_dim_set_id,
                                            x_comp_level_pk_col,
                                            x_color_by_total,
                                            h_dim_com_keys,
                                            x_num_families,
                                            h_level_comb);
    IF h_table_name IS NULL THEN
        -- SUPPORT_BSC_BIS_MEASURES: if there is no data table we simply do not calculate the color
        RETURN TRUE;
    END IF;

    -- I don't need the current period of the indicator because i'm going to color
    -- all the current year

    -- Get the condition on the table to get the records for this drill combination

    --AW_INTEGRATION: pass x_aw_flag and h_aw_limit
    IF NOT Get_Condition_On_Color_Table(x_indic_code,
                                        x_aw_flag,
                                        x_indic_pl_flag,
                                        x_indic_precalculated_flag,
                                        x_dim_set_id,
                                        h_table_name,
                                        x_dim_combination,
                                        h_dim_com_keys,
                                        x_num_families,
                                        x_comp_level_pk_col,
                                        x_color_by_total,
                                        h_condition,
                                        h_bind_vars_values,
                                        h_num_bind_vars,
                                        h_aw_limit_tbl
                                        ) THEN
        RAISE e_unexpected_error;
    END IF;

    IF h_condition IS NOT NULL THEN
        h_condition := h_condition||' AND ';
    END IF;

    --BSC-MV Note: In this architecture the data is in the MV.
    --I will color only the periods existing in the MV
    --If the summary table is used to store projections, I wont color
    --projected periods. Currently, BSC does not use those colors.
    IF BSC_APPS.bsc_mv THEN
        h_condition := h_condition||'PERIODICITY_ID = :'||(h_num_bind_vars + 1);
        h_num_bind_vars := h_num_bind_vars + 1;
        h_bind_vars_values(h_num_bind_vars) := x_periodicity_id;

        -- AW_INTEGRATION: Limit type, periodicity_id and measures
        IF x_aw_flag THEN
            -- limit TYPE with 0 and 1
            -- Fix bug#4574713: package become invalid after bis team added a new property in this record
            -- actually we do not need this call
            h_aw_limit_rec := BIS_PMV_PAGE_PARAMETER_REC(null,null,null,null,null,null);
            h_aw_limit_rec.parameter_name := 'TYPE';
            h_aw_limit_rec.parameter_value := '0';
            h_aw_limit_rec.dimension := 'DIMENSION';
            h_aw_limit_tbl.extend;
            h_aw_limit_tbl(h_aw_limit_tbl.LAST) := h_aw_limit_rec;

            h_aw_limit_rec := BIS_PMV_PAGE_PARAMETER_REC(null,null,null,null,null,null);
            h_aw_limit_rec.parameter_name := 'TYPE';
            h_aw_limit_rec.parameter_value := '1';
            h_aw_limit_rec.dimension := 'DIMENSION';
            h_aw_limit_tbl.extend;
            h_aw_limit_tbl(h_aw_limit_tbl.LAST) := h_aw_limit_rec;

            --limit periodicity
            IF h_yearly_flag = 1 THEN
               -- Annual periodicity
               select min(year), max(year)
               into h_min_per, h_max_per
               from bsc_db_calendar
               where calendar_id = h_calendar_id;

               h_per_parameter_value := h_min_per||'.'||h_min_per||' TO '||h_max_per||'.'||h_max_per;
            ELSE
                -- Other periodicity
                h_sql := 'select min('||BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_periodicity_id)||'),'||
                         ' max('||BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(x_periodicity_id)||')'||
                         ' from bsc_db_calendar'||
                         ' where calendar_id = :1 and year = :2';
                OPEN h_cursor FOR h_sql USING h_calendar_id, x_current_fy;
                FETCH h_cursor INTO h_min_per, h_max_per;
                CLOSE h_cursor;

                h_per_parameter_value := h_min_per||'.'||x_current_fy||' TO '||
                                                 h_max_per||'.'||x_current_fy;
            END IF;
            h_aw_limit_rec := BIS_PMV_PAGE_PARAMETER_REC(null,null,null,null,null,null);
            h_aw_limit_rec.parameter_name := x_periodicity_id;
            h_aw_limit_rec.parameter_value := h_per_parameter_value;
            h_aw_limit_rec.dimension := 'PERIODICITY';
            h_aw_limit_tbl.extend;
            h_aw_limit_tbl(h_aw_limit_tbl.LAST) := h_aw_limit_rec;

            -- limit the measures
            h_column_type := 'A';
            OPEN c_table_columns(h_table_name, h_column_type);
            LOOP
                FETCH c_table_columns INTO h_column_name;
                EXIT WHEN c_table_columns%NOTFOUND;
                h_aw_limit_rec := BIS_PMV_PAGE_PARAMETER_REC(null,null,null,null,null,null);
                h_aw_limit_rec.parameter_name := h_column_name;
                h_aw_limit_rec.dimension := 'MEASURE';
                h_aw_limit_tbl.extend;
                h_aw_limit_tbl(h_aw_limit_tbl.LAST) := h_aw_limit_rec;
            END LOOP;
            CLOSE c_table_columns;

            FOR h_i IN 1..h_aw_limit_tbl.LAST LOOP
                h_aw_limit_rec := h_aw_limit_tbl(h_i);
                BSC_UPDATE_LOG.Write_Line_log(h_aw_limit_rec.parameter_name||' '||
                                              h_aw_limit_rec.parameter_value||' '||
                                              h_aw_limit_rec.dimension, BSC_UPDATE_LOG.OUTPUT);
            END LOOP;
            -- Now we are ready to limit the dimensions of the indicator
            bsc_aw_read.limit_dimensions(x_indic_code, x_dim_set_id, h_aw_limit_tbl);
        END IF;

        -- BSC-BIS-DIMENSIONS: Bind variables are varchar2
        h_condition_b := h_condition;
        FOR h_i IN REVERSE 1..h_num_bind_vars LOOP
            h_condition_b := REPLACE(h_condition_b, ':'||h_i, ''''||h_bind_vars_values(h_i)||'''');
        END LOOP;

        -- BSC_MV Note: If there is no list button I can use only the data source
        -- specified in h_level_comb.
        -- If there is list button, I need to do UNION ALL to have all the zero codes
        -- and detailed info in the same source. List button need to color detailed
        -- info as well as total info
        IF x_num_families > 0 THEN
            -- There is list button

            -- Get list of columns of the table
            h_column_type := 'P';
            h_lst_tab_columns := NULL;
            OPEN c_table_columns(h_table_name, h_column_type);
            LOOP
                FETCH c_table_columns INTO h_column_name;
                EXIT WHEN c_table_columns%NOTFOUND;
                -- Fix bug#3779410: Since End To End Kpi (BSC-BIS-DIMENSIONS), the key columns in the zero mv
                -- are always varchar2 and may differ from the mv. So we are going to use
                -- to_char in the key columns because the UNION ALL fails if the
                -- data type of the key columns is not the same.
                h_lst_tab_columns := h_lst_tab_columns||'TO_CHAR('||h_column_name||') '||h_column_name||', ';
            END LOOP;
            CLOSE c_table_columns;
            h_lst_tab_columns := h_lst_tab_columns||'PERIODICITY_ID, YEAR, TYPE, PERIOD';

            h_column_type := 'A';
            OPEN c_table_columns(h_table_name, h_column_type);
            LOOP
                FETCH c_table_columns INTO h_column_name;
                EXIT WHEN c_table_columns%NOTFOUND;
                h_lst_tab_columns := h_lst_tab_columns||', '||h_column_name;
            END LOOP;
            CLOSE c_table_columns;

            h_fact_table := NULL;
            h_sql := 'SELECT DISTINCT mv_name, data_source, sql_stmt'||
                     ' FROM bsc_kpi_data_tables'||
                     ' WHERE indicator = :1 AND periodicity_id = :2'||
                     ' AND dim_set_id = :3 AND table_name = :4';

            OPEN h_cursor FOR h_sql USING x_indic_code, x_periodicity_id, x_dim_set_id, h_table_name;
            LOOP
                FETCH h_cursor INTO h_mv_name, h_data_source, h_sql_stmt;
                EXIT WHEN h_cursor%NOTFOUND;

                -- Not all the zero codes queries are needed. There are few of them that
                -- we really need acccording to the condition
                -- Check if the sql or MV has rows for that condition. In that case we
                -- involve it in the union.

                IF h_data_source = 'MV' THEN
                    h_sql := 'SELECT 1 FROM '||h_mv_name||
                             ' WHERE '||h_condition_b||' AND ROWNUM = 1';
                ELSE
                    h_sql := 'SELECT 1 FROM ('||h_sql_stmt||') F'||
                             ' WHERE '||h_condition_b||' AND ROWNUM = 1';
                END IF;
                h_i := NULL;
                OPEN h_cursor1 FOR h_sql;
                FETCH h_cursor1 INTO h_i;
                CLOSE h_cursor1;

                IF NOT (h_i IS NULL) THEN
                    -- The sql or mv has records for the condition, then add it to the union
                    IF NOT (h_fact_table IS NULL) THEN
                        h_fact_table := h_fact_table||' UNION ALL ';
                    END IF;

                    IF h_data_source = 'MV' THEN
                        h_fact_table := h_fact_table||
                                        ' SELECT '||h_lst_tab_columns||
                                        ' FROM '||h_mv_name;
                    ELSE
                        -- data source is 'SQL'
                        h_fact_table := h_fact_table||
                                        ' SELECT '||h_lst_tab_columns||
                                        ' FROM ('||h_sql_stmt||')';
                    END IF;
                END IF;
            END LOOP;
            CLOSE h_cursor;

            IF h_fact_table IS NULL THEN
                -- There is no data to color, no reason to continue.. and also the query will be invalid
                RETURN TRUE;
            END IF;

            h_fact_table := '('||h_fact_table||')';

        ELSE
            -- There is no list button (Common case)
            h_sql := 'SELECT mv_name, data_source, sql_stmt'||
                     ' FROM bsc_kpi_data_tables'||
                     ' WHERE indicator = :1 AND periodicity_id = :2'||
                     ' AND dim_set_id = :3 AND level_comb = :4';
            OPEN h_cursor FOR h_sql USING x_indic_code, x_periodicity_id, x_dim_set_id, h_level_comb;
            FETCH h_cursor INTO h_mv_name, h_data_source, h_sql_stmt;
            CLOSE h_cursor;
            IF h_data_source = 'MV' THEN
                h_fact_table := h_mv_name;
            ELSE
                h_fact_table := '('||h_sql_stmt||')';
            END IF;
        END IF;

        h_condition := h_condition||' AND ';
    END IF;

    -- Make the array and list of keys of the combination and comparison key
    FOR h_i IN 0 .. x_num_families - 1 LOOP
        h_num_keys := h_num_keys + 1;
        h_arr_keys(h_num_keys) := h_dim_com_keys(h_i);
        h_key_columns_temp(h_num_keys) := 'KEY'||h_num_keys;
        h_dim_com_keys_1(h_i + 1) := h_dim_com_keys(h_i);
    END LOOP;

    IF (x_comp_level_pk_col IS NOT NULL) AND (x_color_by_total = 0) AND (NOT x_indic_pl_flag) THEN
        -- If the indicator enters in comparison we need the data by that drill also.
        -- Note: I exclude the PL indicator because this indicator has x_comp_level_pk_col = 'ACCOUNT_CODE'
        -- and x_color_by_total = 0, but the color of a PL indicator is based on the profit account.
        -- Note: If the indicator is  Initiatives Strategic then x_comp_level_pk_col = 'PROJECT_CODE'
        -- and x_color_by_total = 0. So we include the project key to get data by this dimension also.

        h_num_keys := h_num_keys + 1;
        h_arr_keys(h_num_keys) := x_comp_level_pk_col;
        h_key_columns_temp(h_num_keys) := 'KEY'||h_num_keys;
    END IF;

    h_lst_keys := BSC_UPDATE_UTIL.Make_Lst_From_Array_Varchar2(h_arr_keys, h_num_keys);
    h_lst_keys_temp := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('KEY', h_num_keys);
    IF h_lst_keys IS NOT NULL THEN
        h_lst_keys := h_lst_keys||', ';
        h_lst_keys_temp := h_lst_keys_temp||', ';
    END IF;

    -- Insert into temporal table BSC_TMP_DATA_COLOR the base data to calculate the color
    -- Clean current records
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_DATA_COLOR');

    -- I use h_num_bind_vars_1 because h_num_bind_vars is used in the next query
    h_num_bind_vars_1 := h_num_bind_vars;

    IF h_yearly_flag = 1 THEN

        h_sql := 'INSERT /*+ append */ INTO BSC_TMP_DATA_COLOR ('||h_lst_keys_temp||'PERIOD, TYPE, TOTAL)'||
                 ' SELECT '||h_lst_keys||'YEAR AS PERIOD, TYPE, '||x_measure_formula||' AS TOTAL';

        IF BSC_APPS.bsc_mv THEN
            h_sql := h_sql||
                 ' FROM '||h_fact_table||' F';
        ELSE
            h_sql := h_sql||
                 ' FROM '||h_table_name;
        END IF;
        h_sql := h_sql||
                 ' WHERE '||h_condition||'(TYPE = 0 OR TYPE = 1)'||
                 ' GROUP BY '||h_lst_keys||'YEAR, TYPE';
    ELSE

        h_sql := 'INSERT /*+ append */ INTO BSC_TMP_DATA_COLOR ('||h_lst_keys_temp||'PERIOD, TYPE, TOTAL)'||
                 ' SELECT '||h_lst_keys||'PERIOD, TYPE, '||x_measure_formula||' AS TOTAL';

        IF BSC_APPS.bsc_mv THEN
            h_sql := h_sql||
                 ' FROM '||h_fact_table||' F';
        ELSE
            h_sql := h_sql||
                 ' FROM '||h_table_name;
        END IF;
        h_sql := h_sql||
                 ' WHERE '||h_condition||'YEAR = :'||(h_num_bind_vars_1 + 1)||
                 ' AND (TYPE = 0 OR TYPE = 1)'||
                 ' GROUP BY '||h_lst_keys||'PERIOD, TYPE';
        h_num_bind_vars_1 := h_num_bind_vars_1 + 1;
        h_bind_vars_values(h_num_bind_vars_1) := x_current_fy;

    END IF;

    BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars_1);
    COMMIT;

    -- Get the YTD Flag
    l_ytd_flag := BSC_UPDATE_UTIL.get_ytd_flag(x_indic_code, x_kpi_measure_id);

    -- Calculate YTD Data if the indicator enter in YTD calculation
    IF l_ytd_flag = 1 THEN
        -- Update BSC_TMP_DATA_COLOR with the YTD data
        -- Drop table if exits

        h_lst_where := BSC_UPDATE_UTIL.Make_Lst_Cond_Join('B', h_arr_keys, 'A', h_key_columns_temp, h_num_keys, 'AND');

        IF h_num_keys > 0 THEN
            h_lst_where := h_lst_where||' AND ';
        END IF;

        h_num_bind_vars_1 := h_num_bind_vars;

        h_sql := 'UPDATE BSC_TMP_DATA_COLOR A'||
                 ' SET TOTAL = ('||
                 '   SELECT '||x_measure_formula;
        IF BSC_APPS.bsc_mv THEN
            h_sql := h_sql||
                 '   FROM '||h_fact_table||' B';
        ELSE
            h_sql := h_sql||
                 '   FROM '||h_table_name||' B';
        END IF;
        h_sql := h_sql||
                 '   WHERE '||h_lst_where||h_condition||'B.YEAR=:'||(h_num_bind_vars_1 + 1)||
                 '   AND B.TYPE=A.TYPE AND B.PERIOD<=A.PERIOD'||
                 ' )';
        h_num_bind_vars_1 := h_num_bind_vars_1 + 1;
        h_bind_vars_values(h_num_bind_vars_1) := x_current_fy;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars_1);
        commit;
    END IF;

    -- Initialize temporal table BSC_TMP_COLORS
    -- Clean current records
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_COLORS');

    h_sql := 'INSERT /*+ append */ INTO BSC_TMP_COLORS ('||h_lst_keys_temp||'PERIOD, VPLAN, VREAL, CUMPERCENT, COLOR)'||
             ' SELECT '||h_lst_keys_temp||'BSC_TMP_ALL_PERIODS.PERIOD, '||
             ' NULL AS VPLAN, NULL AS VREAL, NULL AS CUMPERCENT, '||GRAY||' AS COLOR'||
             ' FROM BSC_TMP_DATA_COLOR, BSC_TMP_ALL_PERIODS'||
             ' GROUP BY '||h_lst_keys_temp||'BSC_TMP_ALL_PERIODS.PERIOD';

    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);

    commit;

    -- Get plan data
    h_lst_where := BSC_UPDATE_UTIL.Make_Lst_Cond_Join('BSC_TMP_COLORS', h_key_columns_temp, 'BSC_TMP_DATA_COLOR', h_key_columns_temp, h_num_keys, 'AND');

    IF h_num_keys > 0 THEN
        h_lst_where := h_lst_where||' AND ';
    END IF;

    h_sql := 'UPDATE BSC_TMP_COLORS'||
             ' SET VPLAN = ('||
             ' SELECT TOTAL'||
             ' FROM BSC_TMP_DATA_COLOR'||
             ' WHERE '||h_lst_where||' BSC_TMP_COLORS.PERIOD = BSC_TMP_DATA_COLOR.PERIOD'||
             ' AND BSC_TMP_DATA_COLOR.TYPE = 1'||
             ')'||
             ' WHERE 0 = ('||
             ' SELECT 0'||
             ' FROM BSC_TMP_DATA_COLOR'||
             ' WHERE '||h_lst_where||' BSC_TMP_COLORS.PERIOD = BSC_TMP_DATA_COLOR.PERIOD'||
             ' AND BSC_TMP_DATA_COLOR.TYPE = 1'||
             ')';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    COMMIT;

    -- Get real data
    h_sql := 'UPDATE BSC_TMP_COLORS'||
             ' SET VREAL = ('||
             ' SELECT TOTAL'||
             ' FROM BSC_TMP_DATA_COLOR'||
             ' WHERE '||h_lst_where||' BSC_TMP_COLORS.PERIOD = BSC_TMP_DATA_COLOR.PERIOD'||
             ' AND BSC_TMP_DATA_COLOR.TYPE = 0'||
             ')'||
             ' WHERE 0 = ('||
             ' SELECT 0'||
             ' FROM BSC_TMP_DATA_COLOR'||
             ' WHERE '||h_lst_where||' BSC_TMP_COLORS.PERIOD = BSC_TMP_DATA_COLOR.PERIOD'||
             ' AND BSC_TMP_DATA_COLOR.TYPE = 0'||
             ')';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    COMMIT;

    -- Calculate the color and store in TEMP table BSC_TMP_COLORS
    IF NOT Calculate_KPI_Color
           ( p_objective_id     => x_indic_code
           , p_kpi_measure_id   => x_kpi_measure_id
           , p_calc_color_flag  => x_calc_color_flag
           ) THEN
      RAISE e_unexpected_error;
    END IF;

      -- Make the list of keys to insert into BSC_SYS_KPI_COLORS (h_lst_keys_insert)
      -- Example: '0, BRANCH_CODE, 0, 0, 0, 0, 0, 0' (8 dim levels in the table)
      h_lst_keys_insert := NULL;
      h_i := 0;
      h_key_index := 1;

      h_sql := 'SELECT DIM_LEVEL_INDEX, LEVEL_PK_COL'||
               ' FROM BSC_TMP_TAB_DEF'||
               ' WHERE TAB_ID = :1'||
               ' ORDER BY DIM_LEVEL_INDEX';

      OPEN h_cursor FOR h_sql USING x_tab_id;
      FETCH h_cursor INTO h_dim_level_index, h_level_pk_col;
      WHILE h_cursor%FOUND LOOP
          IF BSC_UPDATE_UTIL.Item_Belong_To_Array_Varchar2(h_level_pk_col, h_arr_keys, h_num_keys) THEN
              h_lst_keys_insert := h_lst_keys_insert||'KEY'||h_key_index||', ';
              h_key_index := h_key_index + 1;
          ELSE
              h_lst_keys_insert := h_lst_keys_insert||'0, ';
          END IF;

          h_i := h_i + 1;

          FETCH h_cursor INTO h_dim_level_index, h_level_pk_col;
      END LOOP;
      CLOSE h_cursor;

      IF x_indic_initiatives_flag THEN
          -- The indicator is a Initiatives indicator. The project dimension is added to the end of the
          -- list dimension.
          h_lst_keys_insert := h_lst_keys_insert||'KEY'||h_key_index||', ';
          h_key_index := h_key_index + 1;
          h_i := h_i + 1;
      END IF;

      WHILE h_i < 8 LOOP
          h_lst_keys_insert := h_lst_keys_insert||'0, ';
          h_i := h_i + 1;
      END LOOP;


      -- If the indicator enter in comparison we need to calculate the minimum common color
      -- Otherwise we are ready to insert the colors directly in BSC_SYS_KPI_COLORS
      IF (x_comp_level_pk_col IS NOT NULL) AND (x_color_by_total = 0) AND
        (NOT x_indic_pl_flag) AND (NOT x_indic_initiatives_flag) THEN
        -- The indicator enter in comparison.
        -- Note: I exclude the PL indicator because this indicator has x_comp_level_pk_col = 'ACCOUNT_CODE'
        -- and x_color_by_total = 0, but the color of a PL indicator is based on the profit account.
        -- Note: I exclude the Initiatives indicator because this indicator has x_comp_level_pk_col = 'PROJECT_CODE'
        -- and x_color_by_total = 0 but we dont calculte the minimum color. Instead we put the color of each project
        -- directly in BSC_SYS_KPI_COLORS in the last dimension level.

        h_lst_select := BSC_UPDATE_UTIL.Make_Lst_Fixed_Column('KEY', x_num_families);
        IF h_lst_select IS NOT NULL THEN
            h_lst_select := h_lst_select||', ';
        END IF;

        h_sql_mcc := 'SELECT '||h_lst_select||'PERIOD, '||
                     ' MAX(COL_B.PERF_SEQUENCE) MCC'||
                     ' FROM BSC_TMP_COLORS TEM_C, BSC_SYS_COLORS_B COL_B'||
                     ' WHERE TEM_C.COLOR = COL_B.COLOR_ID'||
                     ' GROUP BY '||h_lst_select||'PERIOD';

        -- We are ready to insert the colors directly in BSC_SYS_KPI_COLORS
        h_sql := 'INSERT INTO BSC_SYS_KPI_COLORS (TAB_ID, INDICATOR, KPI_MEASURE_ID, DIM_LEVEL1, DIM_LEVEL2,'||
                 ' DIM_LEVEL3, DIM_LEVEL4, DIM_LEVEL5, DIM_LEVEL6, DIM_LEVEL7, DIM_LEVEL8,'||
                 ' PERIOD_ID, KPI_COLOR, USER_COLOR)'||
                 ' SELECT :1, :2, :3, '||h_lst_keys_insert||'PERIOD,'|| ' COL_B.COLOR_ID, COL_B.COLOR_ID ' ||
                 ' FROM ('||h_sql_mcc||') BSC_TMP_COLORS_MCC, BSC_SYS_COLORS_B COL_B'||
                 ' WHERE BSC_TMP_COLORS_MCC.MCC = COL_B.PERF_SEQUENCE';

        h_bind_vars_values_n.delete;
        h_bind_vars_values_n(1) := x_tab_id;
        h_bind_vars_values_n(2) := x_indic_code;
        h_bind_vars_values_n(3) := x_kpi_measure_id;
        h_num_bind_vars_n := 3;

        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values_n, h_num_bind_vars_n);

        COMMIT;

        IF NOT update_actual_budget_for_mcc( p_objective_id    => x_indic_code
	                                   , p_kpi_measure_id  => x_kpi_measure_id
	                                   , p_tab_id          => x_tab_id
	                                   , p_lst_keys_insert => h_lst_keys_insert
                                           ) THEN
          RAISE e_unexpected_error;
        END IF;

        COMMIT;

        update_trend_for_comparison( p_indic_code      => x_indic_code
                                   , p_kpi_measure_id  => x_kpi_measure_id
                                   , p_tab_id          => x_tab_id
                                   , p_lst_keys_insert => h_lst_keys_insert
                                   , p_sql_mcc         => h_sql_mcc);

        COMMIT;
      ELSE

        -- The indicator doesnt enter in comparison. We are ready to insert the colors directly in BSC_SYS_KPI_COLORS
        h_sql := 'INSERT /*+ append */ INTO BSC_SYS_KPI_COLORS (TAB_ID, INDICATOR, KPI_MEASURE_ID, DIM_LEVEL1, DIM_LEVEL2,'||
                 ' DIM_LEVEL3, DIM_LEVEL4, DIM_LEVEL5, DIM_LEVEL6, DIM_LEVEL7, DIM_LEVEL8,'||
                 ' PERIOD_ID, KPI_COLOR, USER_COLOR, ACTUAL_DATA, BUDGET_DATA)'||
                 ' SELECT :1, :2, :3, '||h_lst_keys_insert||'PERIOD,'||
                 ' COLOR, COLOR, VREAL, VPLAN'||
                 ' FROM BSC_TMP_COLORS';
        h_bind_vars_values_n.delete;
        h_bind_vars_values_n(1) := x_tab_id;
        h_bind_vars_values_n(2) := x_indic_code;
        h_bind_vars_values_n(3) := x_kpi_measure_id;
        h_num_bind_vars_n := 3;

        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values_n, h_num_bind_vars_n);

        COMMIT;
      END IF;

      --
      -- Complete the values for parent dimensions
      --
      FOR h_i_family IN 0 .. x_num_families - 1 LOOP

          IF x_dim_combination(h_i_family) > 0 THEN
              -- Get the following information of the child dimension in the family:
              -- dim_level_index
              -- level_pk_col
              -- level_table_name

              h_sql := 'SELECT DIM_LEVEL_INDEX, LEVEL_PK_COL, LEVEL_TABLE_NAME'||
                       ' FROM BSC_TMP_TAB_DEF'||
                       ' WHERE TAB_ID = :1'||
                       ' AND FAMILY_INDEX = :2'||
                       ' AND DIM_INDEX = :3';

              OPEN h_cursor FOR h_sql USING x_tab_id, h_i_family, x_dim_combination(h_i_family);
              FETCH h_cursor INTO h_dim_level_index_child, h_level_pk_col_child, h_level_table_name_child;
              IF h_cursor%NOTFOUND THEN
                  RAISE e_unexpected_error;
              END IF;
              CLOSE h_cursor;

              FOR h_i_dimension IN REVERSE 0 .. x_dim_combination(h_i_family) - 1 LOOP
                  -- Get the following information of the parent dimension in the family:
                  -- dim_level_index
                  -- level_pk_col
                  -- level_table_name

                  h_sql := 'SELECT DIM_LEVEL_INDEX, LEVEL_PK_COL, LEVEL_TABLE_NAME'||
                           ' FROM BSC_TMP_TAB_DEF'||
                           ' WHERE TAB_ID = :1'||
                           ' AND FAMILY_INDEX = :2'||
                           ' AND DIM_INDEX = :3';

                  OPEN h_cursor FOR h_sql USING x_tab_id, h_i_family, h_i_dimension;
                  FETCH h_cursor INTO h_dim_level_index_parent, h_level_pk_col_parent, h_level_table_name_parent;
                  IF h_cursor%NOTFOUND THEN
                      RAISE e_unexpected_error;
                  END IF;
                  CLOSE h_cursor;

                  h_sql := 'UPDATE BSC_SYS_KPI_COLORS'||
                           ' SET DIM_LEVEL'||(h_dim_level_index_parent + 1)||' = ('||
                           ' SELECT '||h_level_pk_col_parent||
                           ' FROM '||h_level_table_name_child||
                           ' WHERE BSC_SYS_KPI_COLORS.DIM_LEVEL'||(h_dim_level_index_child + 1)||
                           ' = '||h_level_table_name_child||'.CODE'||
                           ')'||
                           ' WHERE TAB_ID = :1 AND '||
                           ' INDICATOR = :2 AND '||
                           ' DIM_LEVEL'||(h_dim_level_index_child + 1)||' <> ''0''';
                  h_bind_vars_values_n.delete;
                  h_bind_vars_values_n(1) := x_tab_id;
                  h_bind_vars_values_n(2) := x_indic_code;
                  h_num_bind_vars_n := 2;
                  BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values_n, h_num_bind_vars_n);
                  commit;

                  h_dim_level_index_child := h_dim_level_index_parent;
                  h_level_pk_col_child := h_level_pk_col_parent;
                  h_level_table_name_child := h_level_table_name_parent;

              END LOOP;
          END IF;
    END LOOP;

    RETURN TRUE;

EXCEPTION
    WHEN e_no_data_table_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_DIMDATA_NOT_FOUND'),
                        x_source => 'BSC_UPDATE_COLOR.Color_Indic_Dim_Combination');
        RETURN FALSE;

    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_KPICOLOR_FAILED'),
                        x_source => 'BSC_UPDATE_COLOR.Color_Indic_Dim_Combination');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => 'x_indic_code='||x_indic_code,
                        x_source => 'BSC_UPDATE_COLOR.Color_Indic_Dim_Combination');
        BSC_MESSAGE.Add(x_message => 'h_table_name='||h_table_name,
                        x_source => 'BSC_UPDATE_COLOR.Color_Indic_Dim_Combination');
        BSC_MESSAGE.Add(x_message => 'h_level_comb='||h_level_comb,
                        x_source => 'BSC_UPDATE_COLOR.Color_Indic_Dim_Combination');
        BSC_MESSAGE.Add(x_message => 'h_condition='||h_condition,
                        x_source => 'BSC_UPDATE_COLOR.Color_Indic_Dim_Combination');
        BSC_MESSAGE.Add(x_message => 'h_sql='||SUBSTR(h_sql, 1, 200),
                        x_source => 'BSC_UPDATE_COLOR.Color_Indic_Dim_Combination');
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_COLOR.Color_Indic_Dim_Combination');
        RETURN FALSE;

END Color_Indic_Dim_Combination;


FUNCTION Calculate_KPI_Color (
  p_objective_id     IN NUMBER
, p_kpi_measure_id   IN NUMBER
, p_calc_color_flag  IN BOOLEAN
)
RETURN BOOLEAN
IS

  h_sql VARCHAR2(32700);
  h_bind_vars_values_n BSC_UPDATE_UTIL.t_array_of_number;
  h_num_bind_vars_n  NUMBER;
  l_color_method     NUMBER;
  C_ALFA             VARCHAR2(10);
  C_BETA             VARCHAR2(10);
  x_color_level1     NUMBER;
  x_color_level2     NUMBER;
  x_color_level3     NUMBER;
  x_color_level4     NUMBER;

  threshold_Prop_Table   BSC_COLOR_CALC_UTIL.Threshold_Prop_Table;

  min_perf           BSC_SYS_COLORS_B.PERF_SEQUENCE%TYPE;
  max_perf           BSC_SYS_COLORS_B.PERF_SEQUENCE%TYPE;
  min_perf_color_id  BSC_SYS_COLORS_B.COLOR_ID%TYPE;
  max_perf_color_id  BSC_SYS_COLORS_B.COLOR_ID%TYPE;
  nodata_color_id    BSC_SYS_COLORS_B.COLOR_ID%TYPE;

  h_sql_else         VARCHAR2(500);
  l_comp_op          VARCHAR2(2); --> different operator for color_method
                                  --1. <=, 2. <, 3 <  any other case <=
  l_array_colors     BSC_COLOR_REPOSITORY.t_array_colors;
  l_color_rec        BSC_COLOR_REPOSITORY.t_color_rec;


  CURSOR c_sys_colors IS
      SELECT COLOR_ID, PERF_SEQUENCE, COLOR
      FROM bsc_sys_colors_b;

BEGIN

  -- ppandey -> Get the system color properties Enh #4012218
  l_array_colors := BSC_COLOR_REPOSITORY.get_color_props();

  FOR l_index IN 1 .. l_array_colors.COUNT LOOP
    l_color_rec := l_array_colors(l_index);

    IF (l_color_rec.PERF_SEQ IS NULL) THEN
      nodata_color_id := l_color_rec.COLOR_ID;
    ELSE
      IF (min_perf IS NULL OR min_perf < l_color_rec.PERF_SEQ) THEN
        min_perf_color_id := l_color_rec.COLOR_ID;
        min_perf := l_color_rec.PERF_SEQ;
      --ELS
      END IF;
      IF (max_perf IS NULL OR max_perf > l_color_rec.PERF_SEQ) THEN
        max_perf_color_id := l_color_rec.COLOR_ID;
        max_perf := l_color_rec.PERF_SEQ;
      END IF;
    END IF;
  END LOOP;


    C_ALFA := '0.000005';
    C_BETA := '100000';

    -- Trunc real and plan to 5 decimal
    h_sql := 'UPDATE BSC_TMP_COLORS'||
             ' SET VREAL = DECODE(VREAL, NULL, VREAL, TRUNC((VREAL + '||C_ALFA||') * '||C_BETA||') / '||C_BETA||'), '||
             ' VPLAN = DECODE(VPLAN, NULL, VPLAN, TRUNC((VPLAN + '||C_ALFA||') * '||C_BETA||') / '||C_BETA||')';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    commit;

    -- Calculate percent of variation
    -- 0 Fix Bug# 2580240 Case Plan=Real=0
    h_sql := 'UPDATE BSC_TMP_COLORS'||
             ' SET CUMPERCENT = 100'||
             ' WHERE (VREAL = 0) AND (VPLAN = 0)';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    commit;

    -- 1
    h_sql := 'UPDATE BSC_TMP_COLORS'||
             ' SET CUMPERCENT = TRUNC((((VREAL / VPLAN)*100) + '||C_ALFA||') * '||C_BETA||') / '||C_BETA||
             ' WHERE (VREAL IS NOT NULL) AND (VPLAN > 0)';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    commit;
    -- 2
    h_sql := 'UPDATE BSC_TMP_COLORS'||
             ' SET CUMPERCENT = TRUNC((((2 + ABS(VREAL / VPLAN))*100) + '||C_ALFA||') * '||C_BETA||') / '||C_BETA||
             ' WHERE (VREAL > 0) AND (VPLAN < 0)';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    commit;

    -- 3
    h_sql := 'UPDATE BSC_TMP_COLORS'||
             ' SET CUMPERCENT = TRUNC((((2 - (VREAL / VPLAN))*100) + '||C_ALFA||') * '||C_BETA||') / '||C_BETA||
             ' WHERE (VREAL <= 0) AND (VPLAN < 0)';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    commit;

    l_color_method := Get_Color_Method(p_objective_id, p_kpi_measure_id);

    -- Calculate the color
    IF p_calc_color_flag THEN

      threshold_Prop_Table := BSC_COLOR_CALC_UTIL.Get_Kpi_Measure_Threshold (p_objective_id, p_kpi_measure_id);

      l_comp_op := '<=';

      IF l_color_method = 1 THEN

          h_sql := 'UPDATE BSC_TMP_COLORS'||
                   ' SET COLOR = CASE WHEN VREAL > VPLAN THEN '||max_perf_color_id||
                   ' ELSE '||min_perf_color_id||' END '||
                   ' WHERE (VREAL = 0 OR VPLAN = 0) '||
                   ' AND VREAL <> VPLAN';

          BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
          commit;
          l_comp_op := '<=';

      ELSIF l_color_method = 2 THEN

        h_sql := 'UPDATE BSC_TMP_COLORS'||
                 ' SET COLOR = CASE WHEN VREAL > VPLAN THEN '||max_perf_color_id||
                 ' ELSE '||min_perf_color_id||' END '||
                 ' WHERE (VREAL = 0 OR VPLAN = 0) '||
                 ' AND VREAL <> VPLAN';
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
        commit;
        l_comp_op := '<';


      ELSIF l_color_method = 3 THEN
          h_sql := 'UPDATE BSC_TMP_COLORS'||
                   ' SET COLOR = '||min_perf_color_id||
                   ' WHERE ((VREAL = 0) AND (VPLAN <> 0)) OR ((VREAL <> 0) AND (VPLAN = 0))';
          BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
          commit;

          l_comp_op := '<';


      END IF;

      IF (threshold_Prop_Table.COUNT > 0) THEN  -- COUNT will not be 0 ideally.
        h_bind_vars_values_n.delete;
        h_num_bind_vars_n := 0;

        h_sql := 'UPDATE BSC_TMP_COLORS'||
                 ' SET COLOR = CASE';

        FOR th IN 1..threshold_Prop_Table.COUNT LOOP
          IF (threshold_Prop_Table(th).threshold IS NOT NULL) THEN
            h_sql := h_sql || ' WHEN CUMPERCENT '|| l_comp_op || threshold_Prop_Table(th).threshold ||' THEN '||threshold_Prop_Table(th).color_id;
          ELSE
            h_sql := h_sql || ' ELSE '|| threshold_Prop_Table(th).color_id || ' END';
          END IF;
        END LOOP;

        h_sql := h_sql || ' WHERE ((VREAL = 0 AND VPLAN = 0) OR (VREAL <> 0 AND VPLAN <> 0))';
        h_num_bind_vars_n := 0;

        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values_n, h_num_bind_vars_n);
        commit;
      END IF;
    END IF;

    RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_COLOR.Calculate_KPI_Color');
    RETURN FALSE;
END Calculate_KPI_Color;


FUNCTION calculate_trend_icon (
  p_tab_id        IN NUMBER
, p_objective_id  IN NUMBER
, p_kpi_measure_id IN NUMBER
, p_not_pl_not_initiative IN BOOLEAN
) RETURN BOOLEAN
IS
  CURSOR c_objective_kpis(p_indicator NUMBER) IS
      SELECT kpi_measure_id
        FROM bsc_kpi_measure_props kpi_meas
      WHERE kpi_meas.indicator = p_indicator;
  l_objective_kpis  c_objective_kpis%ROWTYPE;

  l_color_method      NUMBER;
  e_unexpected_error  EXCEPTION;
  l_calculate_obj_trend BOOLEAN := false;


BEGIN

  FOR l_objective_kpis IN c_objective_kpis(p_objective_id) LOOP
    l_color_method := Get_Color_Method ( p_objective_id   => p_objective_id
                                       , p_kpi_measure_id => l_objective_kpis.kpi_measure_id);
    IF l_objective_kpis.kpi_measure_id = p_kpi_measure_id THEN
      l_calculate_obj_trend := true;
    ELSE
      l_calculate_obj_trend := false;
    END IF;
    IF NOT calculate_kpi_trend_icon( x_tab_id       => p_tab_id
                                   , x_indicator    => p_objective_id
                                   , x_measure_id   => l_objective_kpis.kpi_measure_id
                                   , x_color_method   => l_color_method
                                   , x_calc_obj_trend => l_calculate_obj_trend
                                   , x_not_pl_not_initiative => p_not_pl_not_initiative) THEN
      RAISE e_unexpected_error;
    END IF;
  END LOOP;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_COLOR.calculate_trend_icon');
    RETURN FALSE;
END calculate_trend_icon;

/*===========================================================================+
| FUNCTION  Color_Indicator
|
| This API will calculate the color of all the KPIs under an Objective.
| Also, it will then roll-up the KPI colors to get the Objective color.
| Objective color can have the following roll-ups on the KPI colors:
| WORST, BEST, MOST_FREQUENT, WEIGHTED_AVERAGE, DEFAULT_KPI
|
+============================================================================*/
FUNCTION Color_Indicator (
  x_indic_code IN NUMBER
) RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

    CURSOR c_objective_color_props(p_indicator NUMBER) IS
    SELECT ti.tab_id,
           kpi.periodicity_id,
           --kpi.apply_color_flag,
           kpi.indicator_type,
           kpi.config_type
      FROM bsc_tab_indicators ti,
           bsc_kpis_b kpi
      WHERE ti.indicator = kpi.indicator
      AND   kpi.prototype_flag <> 2
      AND   kpi.indicator = p_indicator;
    l_objective_color_props  c_objective_color_props%ROWTYPE;

    l_objective_color_rec  t_objective_color_rec;

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    CURSOR c_indic_type ( pIndicator number ) is
    SELECT indicator_type, config_type
    FROM bsc_kpis_b
    WHERE indicator = pIndicator ;

    TYPE t_indic_type IS RECORD (
      indicator_type  bsc_kpis_b.indicator_type%TYPE
    , config_type     bsc_kpis_b.config_type%TYPE
    );
    h_indic_type t_indic_type;

    CURSOR c_indic_transformation(pIndicator number,pPropertyCode varchar2) is
      SELECT property_value
        FROM bsc_kpi_properties
        WHERE indicator = pIndicator
        AND property_code = pPropertyCode ;

    h_db_transform             VARCHAR2(50);
    h_indic_transformation     NUMBER;
    h_indic_precalculated_flag BOOLEAN;
    h_indic_pl_flag            BOOLEAN;
    h_indic_initiatives_flag   BOOLEAN;
    h_sql                      VARCHAR2(2000);
    h_current_fy               NUMBER;
    h_calc_color_flag          BOOLEAN;
    h_yearly_flag              NUMBER;
    h_calendar_id              NUMBER;
    h_calendar_edw_flag        NUMBER;
    h_edw_flag                 NUMBER;
    h_num_of_years             NUMBER;
    h_previous_years           NUMBER;
    h_init_period              NUMBER;
    h_end_period               NUMBER;
    h_i                        NUMBER;
    h_bind_vars_values         BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars            NUMBER;
    -- AW_INTEGRATION: new variables
    h_aw_flag                  BOOLEAN;
    l_sim_indicator_flag       BOOLEAN;
    l_kpi_measure_id           NUMBER;
    l_color_flag               BOOLEAN;
    l_not_pl_not_initiative    BOOLEAN := false;

BEGIN

  h_indic_pl_flag := FALSE;
  h_indic_initiatives_flag := FALSE;
  h_db_transform := 'DB_TRANSFORM';
  h_indic_precalculated_flag := FALSE;
  h_yearly_flag := 0;
  h_edw_flag := 0;

  -- AW_INTEGRATION: Get implementation type
  IF BSC_UPDATE_UTIL.Get_Kpi_Impl_Type(x_indic_code) = 2 THEN
    h_aw_flag := TRUE;
  ELSE
    h_aw_flag := FALSE;
  END IF;

  -- Get the type of the indicator
  OPEN c_indic_type (x_indic_code);
  FETCH c_indic_type INTO h_indic_type;
  IF c_indic_type%NOTFOUND THEN
    RAISE e_unexpected_error;
  END IF;
  CLOSE c_indic_type;

  IF (h_indic_type.indicator_type = 1) AND (h_indic_type.config_type = 3) THEN
    h_indic_pl_flag := TRUE;
  ELSIF (h_indic_type.indicator_type = 1) AND (h_indic_type.config_type = 4) THEN
    h_indic_initiatives_flag := TRUE;
  END IF;

  -- Know if the indicator is precalculated or not
  OPEN c_indic_transformation (x_indic_code, h_db_transform);
  FETCH c_indic_transformation INTO h_indic_transformation;
  IF c_indic_transformation%FOUND THEN
    IF h_indic_transformation = 0 THEN
      h_indic_precalculated_flag := TRUE;
    END IF;
  END IF;
  CLOSE c_indic_transformation;


  OPEN c_objective_color_props (x_indic_code);
  FETCH c_objective_color_props INTO l_objective_color_props;
  IF c_objective_color_props%FOUND THEN

    l_sim_indicator_flag := FALSE;
    IF l_objective_color_props.INDICATOR_TYPE = 1 AND l_objective_color_props.CONFIG_TYPE = 7 THEN
      l_sim_indicator_flag := TRUE;
    END IF;

    -- Get information about the periodicity
    h_calendar_id := BSC_UPDATE_UTIL.Get_Calendar_Id(l_objective_color_props.periodicity_id);
    h_calendar_edw_flag := BSC_UPDATE_UTIL.Get_Calendar_EDW_Flag(h_calendar_id);
    h_yearly_flag := BSC_UPDATE_UTIL.Get_Periodicity_Yearly_Flag(l_objective_color_props.periodicity_id);

    -- Get the current fiscal year
    h_current_fy := BSC_UPDATE_UTIL.Get_Calendar_Fiscal_Year(h_calendar_id);

    -- Insert into BSC_TMP_ALL_PERIODS all periods
    -- of the periodicity by which the indicator is going to be colored in
    -- this tab.

    -- Delete current records
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_ALL_PERIODS');

    IF h_yearly_flag = 1 THEN
      -- Get the number of years and previous years of the indicator
      IF NOT BSC_UPDATE_UTIL.Get_Indic_Range_Of_Years(x_indic_code,
                                                      l_objective_color_props.periodicity_id,
                                                      h_num_of_years,
                                                      h_previous_years) THEN
        RAISE e_unexpected_error;
      END IF;

      h_init_period := h_current_fy - h_previous_years;
      h_end_period := h_init_period + h_num_of_years - 1;

      FOR h_i IN h_init_period..h_end_period LOOP
        h_sql := 'INSERT /*+ append */ INTO BSC_TMP_ALL_PERIODS (PERIOD)'||
                 ' VALUES (:1)';
        h_bind_vars_values.delete;
        h_bind_vars_values(1) := h_i;
        h_num_bind_vars := 1;

        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
        COMMIT;
      END LOOP;

    ELSE
      -- Periodicity different to Annual
      IF  h_calendar_edw_flag = 0 THEN
        -- BSC periodicity
        h_sql := 'INSERT /*+ append */ INTO BSC_TMP_ALL_PERIODS'||
                   ' SELECT DISTINCT ' || BSC_UPDATE_UTIL.Get_Calendar_Table_Col_Name(l_objective_color_props.periodicity_id) ||
                   ' AS PERIOD'||
                   ' FROM BSC_DB_CALENDAR'||
                   ' WHERE YEAR = :1 AND CALENDAR_ID = :2';
        h_bind_vars_values.delete;
        h_bind_vars_values(1) := h_current_fy;
        h_bind_vars_values(2) := h_calendar_id;
        h_num_bind_vars := 2;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
        COMMIT;

      ELSE
        -- EDW periodicity
        h_init_period := 1;
        h_end_period := BSC_INTEGRATION_APIS.Get_Number_Of_Periods(h_current_fy,
                                                                   l_objective_color_props.periodicity_id,
                                                                   h_calendar_id);
        IF BSC_APPS.CheckError('BSC_INTEGRATION_APIS.Get_Number_Of_Periods') THEN
          RAISE e_unexpected_error;
        END IF;

        FOR h_i IN h_init_period..h_end_period LOOP
          h_sql := 'INSERT /*+ append */ INTO BSC_TMP_ALL_PERIODS (PERIOD)'||
                   ' VALUES (:1)';
          h_bind_vars_values(1) := h_i;
          h_num_bind_vars := 1;
          BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
          COMMIT;
        END LOOP;

      END IF;

    END IF;

  END IF;
  CLOSE c_objective_color_props;

  -- Delete the colors of the indicator for this tab
  DELETE FROM bsc_sys_kpi_colors
    WHERE tab_id = l_objective_color_props.tab_id AND indicator = x_indic_code;
  DELETE FROM bsc_sys_objective_colors
    WHERE tab_id = l_objective_color_props.tab_id AND indicator = x_indic_code;
  COMMIT;

  l_objective_color_rec.tab_id                 := l_objective_color_props.tab_id;
  l_objective_color_rec.objective_id           := x_indic_code;
  l_objective_color_rec.obj_pl_flag            := h_indic_pl_flag;
  l_objective_color_rec.obj_initiatives_flag   := h_indic_initiatives_flag;
  l_objective_color_rec.obj_precalculated_flag := h_indic_precalculated_flag;
  l_objective_color_rec.periodicity_id         := l_objective_color_props.periodicity_id;
  l_objective_color_rec.current_fy             := h_current_fy;
  l_objective_color_rec.aw_flag                := h_aw_flag;
  l_objective_color_rec.sim_flag               := l_sim_indicator_flag;


  -- Calculate color for all KPIS in the Objective
  IF NOT Color_Kpis_In_Objective( p_objective_color_rec => l_objective_color_rec) THEN
    RAISE e_unexpected_error;
  END IF;

  -- Roll-up KPI colors to get the Objective color
  Calculate_Objective_Color( p_objective_color_rec => l_objective_color_rec
                            ,x_kpi_measure_id      => l_kpi_measure_id
                            ,x_color_flag          => l_color_flag);
  IF NOT l_color_flag THEN
    RAISE e_unexpected_error;
  END IF;

  COMMIT;

   IF ( (NOT l_objective_color_rec.obj_pl_flag) AND (NOT l_objective_color_rec.obj_initiatives_flag) ) THEN
    l_not_pl_not_initiative := true;
  END IF;

  -- Calculate Trend icons
  IF NOT calculate_trend_icon(p_tab_id => l_objective_color_props.tab_id, p_objective_id => x_indic_code,
                              p_kpi_measure_id => l_kpi_measure_id, p_not_pl_not_initiative => l_not_pl_not_initiative) THEN
    RAISE e_unexpected_error;
  END IF;

  COMMIT;

  RETURN TRUE;

EXCEPTION
  WHEN e_unexpected_error THEN
    IF c_indic_type%ISOPEN THEN
      CLOSE c_indic_type;
    END IF;
    IF c_indic_transformation%ISOPEN THEN
      CLOSE c_indic_transformation;
    END IF;
    IF c_objective_color_props%ISOPEN THEN
      CLOSE c_objective_color_props;
    END IF;
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_KPICOLOR_FAILED'),
                    x_source => 'BSC_UPDATE_COLOR.Color_Indicator');
    RETURN FALSE;

  WHEN OTHERS THEN
    IF c_indic_type%ISOPEN THEN
      CLOSE c_indic_type;
    END IF;
    IF c_indic_transformation%ISOPEN THEN
      CLOSE c_indic_transformation;
    END IF;
    IF c_objective_color_props%ISOPEN THEN
      CLOSE c_objective_color_props;
    END IF;
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_COLOR.Color_Indicator');
    RETURN FALSE;

END Color_Indicator;


--LOCKING: new function
/*===========================================================================+
| FUNCTION  Color_Indicator_AT
+============================================================================*/
FUNCTION Color_Indicator_AT(
    x_indic_code IN NUMBER
    ) RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Color_Indicator(x_indic_code);
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Color_Indicator_AT;


/*===========================================================================+
| FUNCTION  Create_Temp_Tab_Tables
+============================================================================*/
FUNCTION Create_Temp_Tab_Tables RETURN BOOLEAN IS
    e_unexpected_error EXCEPTION;

    h_sql VARCHAR2(2000);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    cursor c_tabs is
         SELECT tab_id, dim_level_index, parent_level_index
         FROM bsc_sys_com_dim_levels
         ORDER BY tab_id, dim_level_index;

    TYPE t_tabs IS RECORD (
    tab_id          bsc_sys_com_dim_levels.tab_id%TYPE,
    dim_level_index     bsc_sys_com_dim_levels.dim_level_index%TYPE,
    parent_level_index  bsc_sys_com_dim_levels.parent_level_index%TYPE
    );
    h_tab t_tabs;

    h_last_tab_id NUMBER;
    h_family_index NUMBER;
    h_dim_index NUMBER;

    h_tab_id NUMBER;
    h_num_dimensions NUMBER;

    -- Array with the number of dimensions of each family
    h_num_dimensions_by_family BSC_UPDATE_UTIL.t_array_of_number;
    h_max_family_index NUMBER;

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

    h_table_name VARCHAR2(30);
    h_table_columns BSC_UPDATE_UTIL.t_array_temp_table_cols;
    h_num_columns NUMBER;

BEGIN
    h_max_family_index := 0;

    -- Create temporal table BSC_TMP_TAB_DEF with the name of key column and table
    -- name of each dimension of the list of each tab. Additionally I create a column
    -- with the family id and index within the family for the dimensions in the list.
    -- Example
    -- TAB_ID DIM_LEVEL_INDEX LEVEL_PK_COL LEVEL_TABLE_NAME FAMILY_INDEX DIM_INDEX
    -- ------ --------------- ------------ ---------------- ------------ ---------
    --      0               0 REGION_CODE  BSC_MREGION                 0         0
    --      0               1 BRANCH_CODE  BSC_MBRANCH                 0         1
    --      0               2 PROD_CODE    BSC_MPRODUCT                1         0

    h_table_name := 'BSC_TMP_TAB_DEF';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'TAB_ID';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'DIM_LEVEL_INDEX';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 3;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'LEVEL_PK_COL';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 30;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'LEVEL_TABLE_NAME';
    h_table_columns(h_num_columns).data_type := 'VARCHAR2';
    h_table_columns(h_num_columns).data_size := 30;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'FAMILY_INDEX';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'DIM_INDEX';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    --Fix bug#4139837
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_TAB_DEF');

    h_sql := 'INSERT /*+ append */ INTO BSC_TMP_TAB_DEF'||
             ' SELECT C.TAB_ID, C.DIM_LEVEL_INDEX,'||
             ' D.LEVEL_PK_COL, D.LEVEL_VIEW_NAME,'||
             ' 0 AS FAMILY_INDEX, 0 AS DIM_INDEX'||
             ' FROM BSC_SYS_COM_DIM_LEVELS C, BSC_SYS_DIM_LEVELS_B D'||
             ' WHERE C.DIM_LEVEL_ID = D.DIM_LEVEL_ID';
    BSC_UPDATE_UTIL.Execute_Immediate(h_sql);
    commit;

    -- Update columns FAMILY_ID and DIM_WITHIN_FAMILY
    -- RESTRICTION: The list only can be as following:
    --              dim1 --< dim2 --< dim3    dim4 --< dim5 ...
    --              - only 1-n relationships
    --              - no more than one parent
    --              - The dimension specified in (dim_level_index + 1) can be child
    --              - of the dimension specified id (dim_level_index) or the father
    --              - of the next familiy.

    h_last_tab_id := -1;

    -- OPEN c_tabs FOR c_tabs_sql;
    OPEN c_tabs ;
    FETCH c_tabs INTO h_tab;
    WHILE c_tabs%FOUND LOOP
        IF h_tab.tab_id <> h_last_tab_id THEN
            h_family_index := 0;
            h_dim_index := 0;
        ELSIF (h_tab.parent_level_index IS NULL) THEN
            h_family_index := h_family_index + 1;
            h_dim_index := 0;
        ELSE
            h_dim_index := h_dim_index + 1;
        END IF;

        h_sql := 'UPDATE BSC_TMP_TAB_DEF'||
                 ' SET FAMILY_INDEX = :1,'||
                 ' DIM_INDEX = :2'||
                 ' WHERE TAB_ID = :3'||
                 ' AND DIM_LEVEL_INDEX = :4';
        h_bind_vars_values.delete;
        h_bind_vars_values(1) := h_family_index;
        h_bind_vars_values(2) := h_dim_index;
        h_bind_vars_values(3) := h_tab.tab_id;
        h_bind_vars_values(4) := h_tab.dim_level_index;
        h_num_bind_vars := 4;
        BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
        commit;

        h_last_tab_id := h_tab.tab_id;

        FETCH c_tabs INTO h_tab;
    END LOOP;
    CLOSE c_tabs;

    COMMIT;


    -- Create temporal table BSC_TMP_TAB_COM with the different combinations
    -- of tab dimensions.
    -- Example:
    -- Suppose tab 0 have a list with two families:
    -- Family 0: dimension 0 - Region, dimension 1 - Branch
    -- Family 1: dimension 0 - Product
    -- There is two combination:
    -- Combination 0: Region, Product
    -- Combination 1: Branch, Product

    -- TAB_ID COM_INDEX FAMILY_INDEX DIM_INDEX
    -- ------ --------- ------------ ---------
    --      0         0            0         0
    --      0         0            1         0
    --      0         1            0         1
    --      0         1            1         0

    h_table_name := 'BSC_TMP_TAB_COM';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'TAB_ID';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'COM_INDEX';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'FAMILY_INDEX';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'DIM_INDEX';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    --Fix bug#4139837
    BSC_UPDATE_UTIL.Truncate_Table('BSC_TMP_TAB_COM');

    -- Insert records
    h_sql := 'SELECT TAB_ID, FAMILY_INDEX, COUNT(DIM_INDEX)'||
             ' FROM BSC_TMP_TAB_DEF'||
             ' GROUP BY TAB_ID, FAMILY_INDEX'||
             ' ORDER BY TAB_ID, FAMILY_INDEX';

    h_last_tab_id := -1;

    OPEN h_cursor FOR h_sql;
    FETCH h_cursor INTO h_tab_id, h_family_index, h_num_dimensions;
    WHILE h_cursor%FOUND LOOP
        IF (h_last_tab_id <> h_tab_id) AND (h_last_tab_id <> -1) THEN
            IF NOT Insert_Tab_Combinations(h_last_tab_id, h_num_dimensions_by_family, h_max_family_index) THEN
                RAISE e_unexpected_error;
            END IF;
        END IF;

        h_max_family_index := h_family_index;
        h_num_dimensions_by_family(h_family_index) := h_num_dimensions;

        h_last_tab_id := h_tab_id;

        FETCH h_cursor INTO h_tab_id, h_family_index, h_num_dimensions;
    END LOOP;
    CLOSE h_cursor;

    IF h_last_tab_id <> -1 THEN
        IF NOT Insert_Tab_Combinations(h_last_tab_id, h_num_dimensions_by_family, h_max_family_index) THEN
            RAISE e_unexpected_error;
        END IF;
    END IF;

    COMMIT;

    -- Create temporal table BSC_TMP_ALL_PERIODS
    h_table_name := 'BSC_TMP_ALL_PERIODS';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PERIOD';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;


    -- Create temporal table BSC_TMP_DATA_COLOR
    -- Key columns are for common dimensions. Like BSC_SYS_KPI_COLORS I will
    -- create 8 key columns
    h_table_name := 'BSC_TMP_DATA_COLOR';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PERIOD';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'Y';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'TYPE';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 3;
    h_table_columns(h_num_columns).add_to_index := 'Y';
    --Bug#4099338 move the key columns here, since the generic function that create the index
    -- will start taking off last columns if the index cannot be created due to error ORA-01450
    FOR h_i IN 1..8 LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'KEY'||h_i;
        h_table_columns(h_num_columns).data_type := 'VARCHAR2';
        h_table_columns(h_num_columns).data_size := 400;
        h_table_columns(h_num_columns).add_to_index := 'Y';
    END LOOP;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'TOTAL';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    -- Create temporal table BSC_TMP_COLORS
    -- Key columns are for common dimensions. Like BSC_SYS_KPI_COLORS I will
    -- create 8 key columns
    h_table_name := 'BSC_TMP_COLORS';
    h_table_columns.delete;
    h_num_columns := 0;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'PERIOD';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := 5;
    h_table_columns(h_num_columns).add_to_index := 'Y';
    --Bug#4099338 move the key columns here, since the generic function that create the index
    -- will start taking off last columns if the index cannot be created due to error ORA-01450
    FOR h_i IN 1..8 LOOP
        h_num_columns := h_num_columns + 1;
        h_table_columns(h_num_columns).column_name := 'KEY'||h_i;
        h_table_columns(h_num_columns).data_type := 'VARCHAR2';
        h_table_columns(h_num_columns).data_size := 400;
        h_table_columns(h_num_columns).add_to_index := 'Y';
    END LOOP;
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'VPLAN';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'VREAL';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'CUMPERCENT';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    h_num_columns := h_num_columns + 1;
    h_table_columns(h_num_columns).column_name := 'COLOR';
    h_table_columns(h_num_columns).data_type := 'NUMBER';
    h_table_columns(h_num_columns).data_size := NULL;
    h_table_columns(h_num_columns).add_to_index := 'N';
    IF NOT BSC_UPDATE_UTIL.Create_Global_Temp_Table(h_table_name, h_table_columns, h_num_columns) THEN
        RAISE e_unexpected_error;
    END IF;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_TEMP_TABTABLES_FAILED'),
                        x_source => 'BSC_UPDATE_COLOR.Create_Temp_Tab_Tables');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_COLOR.Create_Temp_Tab_Tables');

        RETURN FALSE;

END Create_Temp_Tab_Tables;

--LOCKING: new function
/*===========================================================================+
| FUNCTION  Create_Temp_Tab_Tables_AT
+============================================================================*/
FUNCTION Create_Temp_Tab_Tables_AT RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;
    h_b BOOLEAN;
BEGIN
    h_b := Create_Temp_Tab_Tables;
    commit; -- all autonomous transaction needs to commit
    RETURN h_b;
END Create_Temp_Tab_Tables_AT;


/*===========================================================================+
| FUNCTION  Drop_Temp_Tab_Tables
+============================================================================*/
FUNCTION Drop_Temp_Tab_Tables RETURN BOOLEAN IS

    e_unexpected_error EXCEPTION;

BEGIN
    -- We are not going to drop global temporary tables
    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_COLOR.Drop_Temp_Tab_Tables');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_COLOR.Drop_Temp_Tab_Tables');
        RETURN FALSE;

END Drop_Temp_Tab_Tables;


/*===========================================================================+
| FUNCTION  Get_Condition_On_Color_Table
+============================================================================*/
FUNCTION Get_Condition_On_Color_Table(
        x_indic_code IN NUMBER,
        x_aw_flag IN BOOLEAN, -- AW_INTEGRATION: new parameter
        x_indic_pl_flag IN BOOLEAN,
        x_indic_precalculated_flag IN BOOLEAN,
        x_dim_set_id IN NUMBER,
        x_table_name IN VARCHAR2,
        x_dim_combination IN BSC_UPDATE_UTIL.t_array_of_number,
        x_dim_com_keys IN BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_families IN NUMBER,
        x_comp_level_pk_col IN VARCHAR2,
        x_color_by_total IN NUMBER,
        x_condition OUT NOCOPY VARCHAR2,
        x_bind_vars_values OUT NOCOPY BSC_UPDATE_UTIL.t_array_of_varchar2,
        x_num_bind_vars OUT NOCOPY NUMBER,
        x_aw_limit_tbl IN OUT NOCOPY BIS_PMV_PAGE_PARAMETER_TBL --AW_INTEGRATION: new parameter
        ) RETURN BOOLEAN IS

    -- BSC-BIS-DIMENSIONS: I have changed the type of x_bind_vars_values to use VARCHAR2
    -- This is to support NUMBER/VHARCHAR2 in key columns

    e_unexpected_error EXCEPTION;

    h_i NUMBER;
    h_sql VARCHAR2(2000);

    TYPE t_cursor IS REF CURSOR;
    h_cursor t_cursor;

    cursor c_pl_dimension_info ( pLevelPkCol varchar2) is
    SELECT e.level_view_name, r.relation_col
    FROM bsc_sys_dim_levels_b e, bsc_sys_dim_level_rels r
    WHERE e.dim_level_id = r.dim_level_id AND
    e.level_pk_col = pLevelPkCol ;

    h_pl_account_table_name VARCHAR2(30);
    h_pl_type_of_account_key VARCHAR2(30);
    h_pl_profit_account NUMBER;

    cursor c_table_keys (pTableName varchar2, pColType varchar2) is
    SELECT column_name
    FROM bsc_db_tables_cols
    WHERE table_name = pTableName
    AND column_type = pColType ;

    h_column_type_p VARCHAR2(1);

    h_table_key VARCHAR2(30);
    h_key_belong_to_list BOOLEAN;

    cursor c_key_item ( pIndicator number, pDimSetId number, pLevelPkCol varchar2) is
    SELECT default_key_value
    FROM bsc_kpi_dim_levels_b
    WHERE indicator = pIndicator
    AND dim_set_id =  pDimSetId
    AND level_pk_col = pLevelPkCol
    AND default_key_value IS NOT NULL ;

    -- BSC-BIS-DIMENSIONS: The default key value may be NUMBER or VARCHAR2. So changing the type
    -- of this variable.
    h_default_key_value VARCHAR2(4000);

    h_new_condition VARCHAR2(200);

    h_key_value NUMBER;

    --AW_INTEGRATION: new variables
    h_aw_limit_rec BIS_PMV_PAGE_PARAMETER_REC;

BEGIN
    h_column_type_p := 'P';

    x_num_bind_vars := 0;
    x_condition := NULL;

    IF x_indic_pl_flag THEN
        -- The indicator is a PL indicator. We need the condition
        -- ACCOUNT_CODE = 6 (In the example 6 is the profit account)

        -- In a PL indicator the name of the accont key (example: ACCOUNT_CODE)
        -- is in x_comp_level_pk_col parameter

        IF x_comp_level_pk_col IS NULL THEN
            RAISE e_unexpected_error;
        END IF;

        -- Get the name of account dimension table and the name of type of account column
        --OPEN c_pl_dimension_info FOR c_pl_dimension_info_sql USING x_comp_level_pk_col;
        OPEN c_pl_dimension_info (x_comp_level_pk_col);
        FETCH c_pl_dimension_info INTO h_pl_account_table_name, h_pl_type_of_account_key;
        IF c_pl_dimension_info%NOTFOUND THEN
            RAISE e_unexpected_error;
        END IF;
        CLOSE c_pl_dimension_info;

        -- Get the profit account
        h_sql := 'SELECT CODE'||
                 ' FROM '||h_pl_account_table_name||
                 ' WHERE '||h_pl_type_of_account_key||' = :1';

        OPEN h_cursor FOR h_sql USING 3;
        FETCH h_cursor INTO h_pl_profit_account;
        IF h_cursor%NOTFOUND THEN
            RAISE e_unexpected_error;
        END IF;
        CLOSE h_cursor;

        -- Make the condition
        x_num_bind_vars := x_num_bind_vars + 1;
        x_condition := '('||x_comp_level_pk_col||' = :'||x_num_bind_vars||')';
        x_bind_vars_values(x_num_bind_vars) := h_pl_profit_account;

        --AW_INTEGRATION: This is to limit the dimension before querying the view.
        IF x_aw_flag THEN
            h_aw_limit_rec := BIS_PMV_PAGE_PARAMETER_REC(null,null,null,null,null,null);
            h_aw_limit_rec.parameter_name := BSC_UPDATE_UTIL.Get_Dim_Level_Table_Name(x_comp_level_pk_col);
            h_aw_limit_rec.parameter_value := h_pl_profit_account;
            h_aw_limit_rec.dimension := 'DIMENSION';
            x_aw_limit_tbl.extend;
            x_aw_limit_tbl(x_aw_limit_tbl.LAST) := h_aw_limit_rec;
        END IF;
    END IF;


    -- Get the table keys and try to figure out the condition on each one of them
    OPEN c_table_keys (x_table_name, h_column_type_p);
    FETCH c_table_keys INTO h_table_key;
    WHILE c_table_keys%FOUND LOOP
        h_new_condition := NULL;
        h_key_belong_to_list := FALSE;

        -- If the key is part of the current condition we dont add another condition on this key
        IF NVL(INSTR(x_condition, h_table_key), 0) = 0 THEN
            FOR h_i IN 0 .. x_num_families - 1 LOOP
                IF h_table_key = x_dim_com_keys(h_i) THEN
                    -- If the key belong to the list and is the first drill in his family then
                    -- we need all records in the table including the zero code.
                    -- Otherwise we dont need the zero code.

                    -- BSC-BIS-DIMENSIONS: To support NUMBER/VARCHAR2 I will use '0' and
                    -- instead of > '0' I will use <> '0' that will not impact the purpose of the
                    -- query
                    IF x_dim_combination(h_i) > 0 THEN
                        x_num_bind_vars := x_num_bind_vars + 1;
                        h_new_condition := h_table_key||' <> :'||x_num_bind_vars;
                        x_bind_vars_values(x_num_bind_vars) := '0';
                    END IF;

                    --AW_INTEGRATION: Add all the values (including 0 code) of this dimension to the limit table
                    IF x_aw_flag THEN
                        h_aw_limit_rec := BIS_PMV_PAGE_PARAMETER_REC(null,null,null,null,null,null);
                        h_aw_limit_rec.parameter_name := BSC_UPDATE_UTIL.Get_Dim_Level_Table_Name(h_table_key);
                        h_aw_limit_rec.parameter_value := '^ALL';
                        h_aw_limit_rec.dimension := 'DIMENSION';
                        x_aw_limit_tbl.extend;
                        x_aw_limit_tbl(x_aw_limit_tbl.LAST) := h_aw_limit_rec;
                    END IF;

                    h_key_belong_to_list := TRUE;

                    EXIT;
                END IF;
            END LOOP;

            IF NOT h_key_belong_to_list THEN
                IF (h_table_key = x_comp_level_pk_col) AND (x_color_by_total = 0) THEN
                    -- If the key is the drill that is in comparison then we dont need the zero code

                    -- BSC-BIS-DIMENSIONS: To support NUMBER/VARCHAR2 I will use '0' and
                    -- instead of > '0' I will use <> '0' that will not impact the purpose of the
                    -- query
                    x_num_bind_vars := x_num_bind_vars + 1;
                    h_new_condition := h_table_key||' <> :'||x_num_bind_vars;
                    x_bind_vars_values(x_num_bind_vars) := '0';

                    --AW_INTEGRATION: Add all the values of this dimension (including 0 code) to the limit table
                    IF x_aw_flag THEN
                        h_aw_limit_rec := BIS_PMV_PAGE_PARAMETER_REC(null,null,null,null,null,null);
                        h_aw_limit_rec.parameter_name := BSC_UPDATE_UTIL.Get_Dim_Level_Table_Name(h_table_key);
                        h_aw_limit_rec.parameter_value := '^ALL';
                        h_aw_limit_rec.dimension := 'DIMENSION';
                        x_aw_limit_tbl.extend;
                        x_aw_limit_tbl(x_aw_limit_tbl.LAST) := h_aw_limit_rec;
                    END IF;

                ELSE
                    OPEN c_key_item (x_indic_code, x_dim_set_id, h_table_key);
                    FETCH c_key_item INTO h_default_key_value;
                    IF c_key_item%FOUND THEN
                        -- If the drill enter in an item the condition is that
                        x_num_bind_vars := x_num_bind_vars + 1;
                        h_new_condition := h_table_key||' = :'||x_num_bind_vars;
                        x_bind_vars_values(x_num_bind_vars) := h_default_key_value;

                        --AW_INTEGRATION: Add this key item to the limit table
                        IF x_aw_flag THEN
                            h_aw_limit_rec := BIS_PMV_PAGE_PARAMETER_REC(null,null,null,null,null,null);
                            h_aw_limit_rec.parameter_name := BSC_UPDATE_UTIL.Get_Dim_Level_Table_Name(h_table_key);
                            h_aw_limit_rec.parameter_value := h_default_key_value;
                            h_aw_limit_rec.dimension := 'DIMENSION';
                            x_aw_limit_tbl.extend;
                            x_aw_limit_tbl(x_aw_limit_tbl.LAST) := h_aw_limit_rec;
                        END IF;

                    ELSE
                        --BSC-MV Note: I am reviewing this logic.
                        -- If this drill is not part of the list button, it is not in comparison,
                        -- and there is no key item then
                        -- by design the table used to color is the one where the drill is in total
                        -- BSC Calculate zero codes always so the condition should be to look
                        -- for the zero code. Even if the indicator is precalculated
                        -- we request the user to input all the zero codes combinations

                        -- BSC-BIS-DIMENSIONS: To support NUMBER/VARCHAR2 I will use '0'

                        x_num_bind_vars := x_num_bind_vars + 1;
                        h_new_condition := h_table_key||' = :'||x_num_bind_vars;
                        x_bind_vars_values(x_num_bind_vars) := '0';

                        -- AW_INTEGRATION: Add to the limit table
                        IF x_aw_flag THEN
                            h_aw_limit_rec := BIS_PMV_PAGE_PARAMETER_REC(null,null,null,null,null,null);
                            h_aw_limit_rec.parameter_name := BSC_UPDATE_UTIL.Get_Dim_Level_Table_Name(h_table_key);
                            h_aw_limit_rec.parameter_value := '0';
                            h_aw_limit_rec.dimension := 'DIMENSION';
                            x_aw_limit_tbl.extend;
                            x_aw_limit_tbl(x_aw_limit_tbl.LAST) := h_aw_limit_rec;
                        END IF;

                    END IF;
                    CLOSE c_key_item;
                END IF;
            END IF;
        END IF;

        IF h_new_condition IS NOT NULL THEN
            IF x_condition IS NULL THEN
                x_condition := '('||h_new_condition||')';
            ELSE
                x_condition := x_condition||' AND ('||h_new_condition||')';
            END IF;
        END IF;

        FETCH c_table_keys INTO h_table_key;
    END LOOP;
    CLOSE c_table_keys;

    RETURN TRUE;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_COLORTABLE_COND_FAILED'),
                        x_source => 'BSC_UPDATE_COLOR.Get_Condition_On_Color_Table');
        RETURN FALSE;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_COLOR.Get_Condition_On_Color_Table');
        RETURN FALSE;

END Get_Condition_On_Color_Table;


FUNCTION Get_Table_For_Drill_Comb (
  p_indic_code      IN NUMBER
, p_periodicity_id  IN NUMBER
, p_dim_set_id      IN NUMBER
, p_drill_comb      IN VARCHAR2
, x_level_comb      OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2
IS
  e_unexpected_error EXCEPTION;

  h_level_comb VARCHAR2(20);
  h_table_name VARCHAR2(30);
  h_i NUMBER;
  h_match BOOLEAN;
  h_status_1 VARCHAR2(1);
  h_status_2 VARCHAR2(1);


  CURSOR c_indic_tables(pIndicator NUMBER, pPeriodicity NUMBER, pDimSetId NUMBER) IS
    SELECT level_comb, table_name
      FROM bsc_kpi_data_tables
      WHERE indicator =  pIndicator
      AND   periodicity_id =  pPeriodicity
      AND   dim_set_id = pDimSetId
      AND   table_name IS NOT NULL;

BEGIN

  OPEN c_indic_tables (p_indic_code, p_periodicity_id, p_dim_set_id);
  FETCH c_indic_tables INTO h_level_comb, h_table_name;
  IF c_indic_tables%NOTFOUND THEN
    RAISE e_unexpected_error;
  END IF;

  WHILE c_indic_tables%FOUND LOOP

    IF LENGTH(p_drill_comb) = LENGTH(h_level_comb) THEN

      h_match := TRUE;

      FOR h_i IN 1 .. LENGTH(p_drill_comb) LOOP

        h_status_1 := SUBSTR(p_drill_comb, h_i, 1);
        h_status_2 := SUBSTR(h_level_comb, h_i, 1);

        IF NOT((h_status_1 = h_status_2) OR (h_status_1 = '?') OR (h_status_2 = '?')) THEN
          h_match := FALSE;
          EXIT;
        END IF;

      END LOOP;

      IF h_match THEN

        CLOSE c_indic_tables;
        x_level_comb := h_level_comb;

        RETURN h_table_name;

      END IF;

    END IF;

    FETCH c_indic_tables INTO h_level_comb, h_table_name;

  END LOOP;

  CLOSE c_indic_tables;

  RETURN NULL;

EXCEPTION
  WHEN e_unexpected_error THEN
    IF c_indic_tables%ISOPEN THEN
      CLOSE c_indic_tables;
    END IF;
    BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_RETR_COLORTABLE_FAILED'),
                    x_source => 'BSC_UPDATE_COLOR.Get_Table_For_Drill_Comb');
    RETURN NULL;

  WHEN OTHERS THEN
    IF c_indic_tables%ISOPEN THEN
      CLOSE c_indic_tables;
    END IF;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_COLOR.Get_Table_For_Drill_Comb');
    RETURN NULL;
END Get_Table_For_Drill_Comb;


/*===========================================================================+
| FUNCTION Get_Table_Used_To_Color
+============================================================================*/
FUNCTION Get_Table_Used_To_Color(
    x_indic_code IN NUMBER,
    x_periodicity_id IN NUMBER,
    x_dim_set_id IN NUMBER,
    x_comp_level_pk_col IN VARCHAR2,
    x_color_by_total IN NUMBER,
    x_selected_dim_keys IN BSC_UPDATE_UTIL.t_array_of_varchar2,
    x_num_selected_dim_keys IN NUMBER,
    x_level_comb OUT NOCOPY VARCHAR2
    ) RETURN VARCHAR2 IS

    e_unexpected_error EXCEPTION;

    h_level_pk_col VARCHAR2(30);

    TYPE t_cursor IS REF CURSOR;

    cursor c_drill_index(pIndicator number, pDimSetId number, pLevelPkCol varchar2) is
    SELECT dim_level_index
    FROM bsc_kpi_dim_levels_b
    WHERE indicator = pIndicator
    AND dim_set_id = pDimSetId
    AND level_pk_col = pLevelPkCol;

    cursor c_key_items(pIndicator number, pDimSetId number, pStatus varchar2) is
    SELECT dim_level_index
    FROM bsc_kpi_dim_levels_b
    WHERE indicator = pIndicator
    AND dim_set_id = pDimSetId
    AND status = pStatus
    AND default_key_value IS NOT NULL ;

    cursor c_indic_drills(pIndicator number, pDImSetId number, pStatus varchar2) is
    SELECT dim_level_index
    FROM bsc_kpi_dim_levels_b
    WHERE indicator = pIndicator
    AND dim_set_id = pDImSetId
    AND status = pStatus
    ORDER BY dim_level_index ;

    h_dim_level_index NUMBER;

    h_level_comb VARCHAR2(20);
    h_table_name VARCHAR2(30);

    h_selected_drills BSC_UPDATE_UTIL.t_array_of_number;
    h_num_selected_drills NUMBER;

    h_drill_comb VARCHAR2(20);

    h_i NUMBER;

BEGIN
    h_num_selected_drills := 0;
    h_drill_comb := NULL;

    -- Insert into h_selected_drills the internal drill index of selected drills

    FOR h_i IN 0 .. x_num_selected_dim_keys - 1 LOOP
        h_level_pk_col := x_selected_dim_keys(h_i);

        OPEN c_drill_index (x_indic_code, x_dim_set_id, h_level_pk_col);
        FETCH c_drill_index INTO h_dim_level_index;
        IF c_drill_index%NOTFOUND THEN
            RAISE e_unexpected_error;
        END IF;
        CLOSE c_drill_index;

        h_num_selected_drills := h_num_selected_drills + 1;
        h_selected_drills(h_num_selected_drills):= h_dim_level_index;

    END LOOP;

    -- Insert into h_selected_drill the internal drill index of comparison drill

    IF (x_comp_level_pk_col IS NOT NULL) AND (x_color_by_total = 0) THEN
        h_level_pk_col := x_comp_level_pk_col;

        OPEN c_drill_index (x_indic_code, x_dim_set_id, h_level_pk_col);
        FETCH c_drill_index INTO h_dim_level_index;
        IF c_drill_index%NOTFOUND THEN
            RAISE e_unexpected_error;
        END IF;
        CLOSE c_drill_index;

        h_num_selected_drills := h_num_selected_drills + 1;
        h_selected_drills(h_num_selected_drills) := h_dim_level_index;

    END IF;

    -- Insert into h_selected_drill the internal drill index of drills that
    -- enter in a specific item
    OPEN c_key_items (x_indic_code, x_dim_set_id, 2);
    FETCH c_key_items INTO h_dim_level_index;
    WHILE c_key_items%FOUND LOOP
        IF NOT BSC_UPDATE_UTIL.Item_Belong_To_Array_Number(h_dim_level_index,
                                                           h_selected_drills,
                                                           h_num_selected_drills) THEN
            h_num_selected_drills := h_num_selected_drills + 1;
            h_selected_drills(h_num_selected_drills) := h_dim_level_index;

        END IF;

        FETCH c_key_items INTO h_dim_level_index;
    END LOOP;
    CLOSE c_key_items;

    -- Get the list of drills of indicator
    OPEN c_indic_drills (x_indic_code, x_dim_set_id, 2);
    FETCH c_indic_drills INTO h_dim_level_index;

    IF c_indic_drills%NOTFOUND THEN
      -- The indicator in the given configuration (dimension set)
      -- doesnt have any drill. So, the table that use the indicator
      -- is the only one it has.

      h_drill_comb := '?';

      h_table_name := Get_Table_For_Drill_Comb
	                ( p_indic_code      => x_indic_code
	                , p_periodicity_id  => x_periodicity_id
	                , p_dim_set_id      => x_dim_set_id
	                , p_drill_comb      => h_drill_comb
	                , x_level_comb      => x_level_comb
                        );

      IF h_table_name IS NULL THEN

	RAISE e_unexpected_error;
      END IF;

      CLOSE c_indic_drills;

      RETURN h_table_name;
    END IF;

    -- Create a string with the combination of drills base on the selected drills
    h_drill_comb := NULL;

    WHILE c_indic_drills%FOUND LOOP
        IF BSC_UPDATE_UTIL.Item_Belong_To_Array_Number(h_dim_level_index,
                                                       h_selected_drills,
                                                       h_num_selected_drills) THEN
            h_drill_comb := h_drill_comb||'0';
        ELSE
            h_drill_comb := h_drill_comb||'1';
        END IF;

        FETCH c_indic_drills INTO h_dim_level_index;
    END LOOP;
    CLOSE c_indic_drills;

    -- Look into indicator tables to see which table match the drill combination
    h_table_name := Get_Table_For_Drill_Comb
                    ( p_indic_code      => x_indic_code
                    , p_periodicity_id  => x_periodicity_id
                    , p_dim_set_id      => x_dim_set_id
                    , p_drill_comb      => h_drill_comb
                    , x_level_comb      => x_level_comb
                    );

    RETURN h_table_name;

EXCEPTION
    WHEN e_unexpected_error THEN
        BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_RETR_COLORTABLE_FAILED'),
                        x_source => 'BSC_UPDATE_COLOR.Get_Table_Used_To_Color');
         RETURN NULL;

    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_COLOR.Get_Table_Used_To_Color');
         RETURN NULL;
END Get_Table_Used_To_Color;


/*===========================================================================+
| FUNCTION  Insert_Tab_Combinations
+============================================================================*/
FUNCTION Insert_Tab_Combinations(
    x_tab_id IN NUMBER,
        x_num_dimensions_by_family IN BSC_UPDATE_UTIL.t_array_of_number,
        x_max_family_index IN NUMBER
    ) RETURN BOOLEAN IS

    h_num_combinations NUMBER;

    h_i_family NUMBER;
    h_i_combination NUMBER;

    h_times NUMBER;
    h_repeat NUMBER;

    h_i_times NUMBER;
    h_i_repeat NUMBER;

    h_i_dim NUMBER;

    h_sql VARCHAR2(2000);

    h_bind_vars_values BSC_UPDATE_UTIL.t_array_of_number;
    h_num_bind_vars NUMBER;

BEGIN

    h_num_combinations := 1;
    FOR h_i_family IN 0 .. x_max_family_index LOOP
        h_num_combinations := h_num_combinations * x_num_dimensions_by_family(h_i_family);
    END LOOP;


    h_times := 1;
    h_repeat := h_num_combinations;

    FOR h_i_family IN 0 .. x_max_family_index LOOP
        h_i_combination := 0;

        h_repeat := h_repeat / x_num_dimensions_by_family(h_i_family);
        FOR h_i_times IN 1 .. h_times LOOP
            FOR h_i_dim IN 0 .. x_num_dimensions_by_family(h_i_family) - 1 LOOP
                FOR h_i_repeat IN 1 .. h_repeat LOOP
                    h_sql := 'INSERT /*+ append */ INTO BSC_TMP_TAB_COM (TAB_ID, COM_INDEX, FAMILY_INDEX, DIM_INDEX)'||
                             ' VALUES (:1, :2, :3, :4)';
                    h_bind_vars_values.delete;
                    h_bind_vars_values(1) := x_tab_id;
                    h_bind_vars_values(2) := h_i_combination;
                    h_bind_vars_values(3) := h_i_family;
                    h_bind_vars_values(4) := h_i_dim;
                    h_num_bind_vars := 4;
                    BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values, h_num_bind_vars);
                    commit;

                    h_i_combination := h_i_combination + 1;
                END LOOP;
            END LOOP;
        END LOOP;

        h_times := h_times *  x_num_dimensions_by_family(h_i_family);
    END LOOP;

    RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN
        BSC_MESSAGE.Add(x_message => SQLERRM,
                        x_source => 'BSC_UPDATE_COLOR.Insert_Tab_Combinations');


        RETURN FALSE;

END Insert_Tab_Combinations;

/*===========================================================================+
|
|   Name:          Get_KPI_Property_Value
|
|   Description:   This function return the property vaue for a given kpi and
|                  property_code
|
|   Returns:       It return the property value
|   Notes:         Bug #3236356
|
+============================================================================*/
FUNCTION Get_KPI_Property_Value(
                      x_indicator     NUMBER,
                      x_property_code VARCHAR2,
                      x_default_value NUMBER
) RETURN NUMBER is

  l_property_value NUMBER;

  CURSOR c_Kpi_Property_Value IS
  SELECT PROPERTY_VALUE
  FROM   BSC_KPI_PROPERTIES
  WHERE  INDICATOR     = x_indicator
  AND    PROPERTY_CODE = x_property_code;

BEGIN

    OPEN c_Kpi_Property_Value;
    FETCH c_Kpi_Property_Value INTO l_property_value;
        IF c_Kpi_Property_Value%NOTFOUND  THEN
         l_property_value := x_default_value;
        END IF;
    CLOSE c_Kpi_Property_Value;

    RETURN l_property_value;

END Get_KPI_Property_Value;


/*  Once the KPI colors are calculated and stored in BSC_SYS_KPI_COLORS,
 *  this API will calculate the Objective color based on the rollup type.
 *  The objective color will be stored in BSC_SYS_OBJECTIVE_COLORS.
 *  Rollup type can be one of: BEST, WORST, MOST_FREQUENT, WEIGHTED_AVERAGE,
 *  DEFAULT_KPI. For Simulation Objective, the color will be based on the
 *  default (color) node as of today.
 */
PROCEDURE Calculate_Objective_Color (
  p_objective_color_rec  IN BSC_UPDATE_COLOR.t_objective_color_rec
 ,x_kpi_measure_id       OUT NOCOPY NUMBER
 ,x_color_flag           OUT NOCOPY BOOLEAN
) IS

  l_rollup_type  bsc_kpis_b.color_rollup_type%TYPE;
  e_unexpected_error EXCEPTION;

BEGIN

  l_rollup_type := BSC_COLOR_CALC_UTIL.Get_Obj_Color_Rollup_Type(p_objective_color_rec.objective_id);

  IF l_rollup_type IS NOT NULL THEN
    IF l_rollup_type = BSC_COLOR_CALC_UTIL.DEFAULT_KPI THEN
      BSC_COLOR_CALC_UTIL.Calc_Obj_Color_By_Default_Kpi( p_objective_color_rec => p_objective_color_rec
                                                       , x_kpi_measure_id      => x_kpi_measure_id
                                                       , x_color_flag          => x_color_flag
                                                       );
    ELSIF l_rollup_type = BSC_COLOR_CALC_UTIL.BEST OR l_rollup_type = BSC_COLOR_CALC_UTIL.WORST OR l_rollup_type = BSC_COLOR_CALC_UTIL.MOST_FREQUENT THEN
      BSC_COLOR_CALC_UTIL.Calc_Obj_Color_By_Single_Kpi( p_objective_color_rec => p_objective_color_rec
                                                      , p_rollup_type         => l_rollup_type
                                                      , x_kpi_measure_id      => x_kpi_measure_id
                                                      , x_color_flag          => x_color_flag
                                                             );
    ELSIF l_rollup_type = BSC_COLOR_CALC_UTIL.WEIGHTED_AVERAGE THEN
      x_color_flag := BSC_COLOR_CALC_UTIL.Calc_Obj_Color_By_Weights( p_objective_color_rec => p_objective_color_rec
                                                                   );
    END IF;
  END IF;

  --RETURN TRUE;

EXCEPTION
  WHEN e_unexpected_error THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => BSC_UPDATE_UTIL.Get_Message('BSC_KPICOLOR_FAILED'),
                    x_source => 'BSC_UPDATE_COLOR.Calculate_Objective_Color');
    x_color_flag     := false;
    x_kpi_measure_id := -1;
    --RETURN FALSE;
  WHEN OTHERS THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_COLOR.Calculate_Objective_Color');
    x_color_flag     := false;
    x_kpi_measure_id := -1;
    --RETURN FALSE;
END Calculate_Objective_Color;

FUNCTION calculate_kpi_trend_icon (
  x_tab_id        IN NUMBER
, x_indicator     IN NUMBER
, x_measure_id    IN NUMBER
, x_color_method  IN NUMBER
, x_calc_obj_trend IN BOOLEAN
, x_not_pl_not_initiative IN BOOLEAN
) RETURN BOOLEAN
IS
  CURSOR c_dim_comb IS
    SELECT DISTINCT
           dim_level1 || dim_level2 || dim_level3 || dim_level4 || dim_level5 || dim_level6 || dim_level7 || dim_level8 dim_comb,
           dim_level1, dim_level2, dim_level3, dim_level4, dim_level5, dim_level6, dim_level7, dim_level8,
           period_id, actual_data, budget_data, kpi_color, kpi_trend
      FROM bsc_sys_kpi_colors
      WHERE indicator = x_indicator
      AND   tab_id = x_tab_id
      AND   kpi_measure_id = x_measure_id
      ORDER BY dim_comb,period_id;

  CURSOR c_obj_dim_comb(cp_dim_comb VARCHAR2, cp_period_id NUMBER) IS
    SELECT DISTINCT
           dim_level1 || dim_level2 || dim_level3 || dim_level4 || dim_level5 || dim_level6 || dim_level7 || dim_level8 dim_comb,
           period_id, obj_color, obj_trend
      FROM bsc_sys_objective_colors
      WHERE indicator = x_indicator
      AND   tab_id = x_tab_id
      AND   dim_level1 || dim_level2 || dim_level3 || dim_level4 || dim_level5 || dim_level6 || dim_level7 || dim_level8  = cp_dim_comb
      AND   period_id = cp_period_id
      ORDER BY dim_comb, period_id;
  l_dim_comb  c_dim_comb%ROWTYPE;
  l_prev_period NUMBER;
  l_prev_value NUMBER;
  l_prev_dim_levels  VARCHAR2(240);
  l_trendflag NUMBER;
  l_obj_dimcomb VARCHAR2(240);
  l_obj_periodid NUMBER;
  l_obj_color NUMBER;
  l_obj_trend NUMBER;
  l_calc_trend BOOLEAN := false;
  l_rollup_type VARCHAR2(240);
  h_bind_vars_values_n BSC_UPDATE_UTIL.t_array_of_number;
  h_num_bind_vars_n NUMBER;
  h_sql  VARCHAR2(3000);
  h_obj_bind_vars_values_n BSC_UPDATE_UTIL.t_array_of_number;
  h_obj_num_bind_vars_n NUMBER;
  h_obj_sql  VARCHAR2(3000);
  l_kpi_dim_props    BSC_UPDATE_UTIL.t_kpi_dim_props_rec;
  l_color_by_total   bsc_kpi_measure_props.color_by_total%TYPE;
  l_comparison       BOOLEAN := false;
  l_values_obtained  BOOLEAN := false;

BEGIN

   --BugFix 6142563
   IF is_ytd_default_calc( p_indicator      => x_indicator
                         , p_kpi_measure_id => x_measure_id) THEN
       RETURN TRUE;
   END IF;
  l_prev_period := -999;
  l_prev_dim_levels :='xxxxxxxx';
  l_rollup_type := BSC_COLOR_CALC_UTIL.Get_Obj_Color_Rollup_Type(x_indicator);
  l_values_obtained := false;

    FOR l_dim_comb IN c_dim_comb LOOP
        IF( (l_prev_period=-999) OR (l_prev_dim_levels<>l_dim_comb.dim_comb)
           OR (l_dim_comb.period_id<=l_prev_period) OR (l_dim_comb.actual_data IS NULL)
           OR (l_prev_value IS NULL)) THEN
          l_trendflag := 5;
        ELSE
          l_trendflag := get_trend_flag(p_color_method => x_color_method
                        ,p_actual       => l_dim_comb.actual_data
                        ,p_prior        => l_prev_value);
        END IF;
        --BugFix 6000042 Trend for Comparison Mode
        IF ( (l_dim_comb.kpi_trend IS NOT NULL) AND (x_not_pl_not_initiative)
            AND (NOT l_values_obtained)) THEN
            BSC_UPDATE_UTIL.Get_Kpi_Dim_Props ( p_objective_id   => x_indicator
                              , p_kpi_measure_id => x_measure_id
                              , x_dim_props_rec  => l_kpi_dim_props
                              );
            l_color_by_total := BSC_UPDATE_UTIL.Get_Color_By_Total ( p_objective_id   => x_indicator
                                                   , p_kpi_measure_id => x_measure_id
                                                   );

            IF ((l_kpi_dim_props.comp_level_pk_col IS NOT NULL) AND (l_color_by_total = 0)) THEN
               l_comparison := true;
            END IF;
            l_values_obtained := true;

        END IF;

        IF (NOT l_comparison) THEN

          h_sql := 'UPDATE bsc_sys_kpi_colors'||
                 ' SET kpi_trend = '||l_trendflag||
                 ' WHERE indicator =:1 '||
                 ' AND tab_id = :2 '||
                 ' AND kpi_measure_id = :3 '||
                 ' AND period_id = :4 '||
                 ' AND dim_level1 || dim_level2 || dim_level3 || dim_level4 || dim_level5 || dim_level6 || dim_level7 || dim_level8 = :5';

          h_bind_vars_values_n.delete;
          h_bind_vars_values_n(1) := x_indicator;
          h_bind_vars_values_n(2) := x_tab_id;
          h_bind_vars_values_n(3) := x_measure_id;
          h_bind_vars_values_n(4) := l_dim_comb.period_id;
          h_bind_vars_values_n(5) := l_dim_comb.dim_comb;
          h_num_bind_vars_n := 5;
          BSC_UPDATE_UTIL.Execute_Immediate(h_sql, h_bind_vars_values_n, h_num_bind_vars_n);

          COMMIT;
        END IF;


        IF c_obj_dim_comb%ISOPEN THEN
           CLOSE c_obj_dim_comb;
        END IF;

        IF l_rollup_type = BSC_COLOR_CALC_UTIL.DEFAULT_KPI THEN
          l_calc_trend := x_calc_obj_trend;

          IF (l_comparison) THEN
            l_trendflag := l_dim_comb.kpi_trend;
          END IF;

        ELSE

          OPEN c_obj_dim_comb(l_dim_comb.dim_comb , l_dim_comb.period_id);
          FETCH c_obj_dim_comb INTO l_obj_dimcomb, l_obj_periodid, l_obj_color, l_obj_trend;
          IF c_obj_dim_comb%NOTFOUND THEN
             RETURN NULL;
          END IF;
          CLOSE c_obj_dim_comb;

          IF l_obj_color=l_dim_comb.kpi_color AND l_obj_trend IS NULL THEN
            l_calc_trend := true;
          ELSE
            l_calc_trend := false;
          END IF;

          IF ((l_comparison) AND (l_calc_trend) AND (l_dim_comb.kpi_trend IS NOT NULL)) THEN
            l_trendflag := l_dim_comb.kpi_trend;
          END IF;
        END IF;
        --BugFix 6137542
        IF l_rollup_type = BSC_COLOR_CALC_UTIL.WEIGHTED_AVERAGE THEN
          l_calc_trend := false;
        END IF;

        IF l_calc_trend THEN

          h_obj_sql := 'UPDATE bsc_sys_objective_colors'||
                       ' SET obj_trend = '||l_trendflag||
                       ' WHERE indicator =:1 '||
                       ' AND tab_id = :2 '||
                       ' AND period_id = :3 '||
                       ' AND dim_level1 || dim_level2 || dim_level3 || dim_level4 || dim_level5 || dim_level6 || dim_level7 || dim_level8 = :4';
          h_obj_bind_vars_values_n.delete;
          h_obj_bind_vars_values_n(1) := x_indicator;
          h_obj_bind_vars_values_n(2) := x_tab_id;
          h_obj_bind_vars_values_n(3) := l_dim_comb.period_id;
          h_obj_bind_vars_values_n(4) := l_dim_comb.dim_comb;
          h_obj_num_bind_vars_n := 4;
          BSC_UPDATE_UTIL.Execute_Immediate(h_obj_sql, h_obj_bind_vars_values_n, h_obj_num_bind_vars_n);

          COMMIT;
        END IF;

        l_prev_value := l_dim_comb.actual_data;
        l_prev_period := l_dim_comb.period_id;
        l_prev_dim_levels := l_dim_comb.dim_comb;

  END LOOP;

  COMMIT;

  RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    BSC_MESSAGE.Add(x_message => SQLERRM,
                    x_source => 'BSC_UPDATE_COLOR.calculate_kpi_trend_icon');
    RETURN FALSE;
END calculate_kpi_trend_icon;

END BSC_UPDATE_COLOR;

/
