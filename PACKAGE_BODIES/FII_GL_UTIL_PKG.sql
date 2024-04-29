--------------------------------------------------------
--  DDL for Package Body FII_GL_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_UTIL_PKG" AS
/* $Header: FIIGLC5B.pls 120.9 2006/05/18 19:49:35 vkazhipu noship $ */

g_min_start_date date;
g_min_week_start_date date;
/*
reset_globals
2  When setting gid, also picked the mv to use
   These are one AND the same logic so it's good to go together
3  If substr or replace are needed on BIS parameters values, do them
   ahead of time so global variables get what we want.  Do not want
   to substr on globals everywhere unless necessary

get_mgr_pmv_sql
1  Introduce logic to handle when ccc_org_id is specified
2  Merged in logic for handling view by cost center cases
3  Re-organized the logic

get_lob_pmv_sql
1  Introduce logic to handle when ccc_org_id is specified
2  Re-organized the logic
3  Introduce logic to handle when lob parameter value is
   a leaf for a performance gain.  Introduced function get_lob,
   which has not been written but is similar to get_supervisor

get_ccc_pmv_sql
1  Re-organized logic given most code was merged INTO
   get_mgr_pmv_sql AND get_viewby_sql
2  Introduced function ccc_within_mgr_lob which is not yet written
   to check if a given ccc belongs to given mgr/lob
*/


-- -------------------------------------------------
-- Re-set the globals variables to NULL
-- -------------------------------------------------
PROCEDURE reset_globals IS
BEGIN
  g_period_type            := NULL;
  g_ent_period_type        := NULL;
  g_act_where_period_type  := NULL;
  g_where_period_type      := NULL;
  g_actual_period_type     := NULL;
  g_budget_period_type     := NULL;
  g_forecast_period_type   := NULL;
  g_view                   := NULL;
  g_view_by                := NULL;
  g_as_of_date             := NULL;
  g_previous_asof_date     := NULL;
  g_curr_start		   := NULL;
  g_curr_end		   := NULL;
  g_temp		   := NULL;
  g_prior_start		   := NULL;
  g_prior_end		   := NULL;
  g_mgr_id                 := NULL;
  g_fin_id                 := NULL;
  g_lob_id                 := NULL;
  g_ccc_id                 := NULL;
  g_time_comp              := NULL;
  g_currency               := NULL;
  g_gid                    := NULL;
  g_lob_from_clause        := NULL;
  g_mgr_from_clause        := NULL;
  g_lob_join               := NULL;
  g_cat_join               := NULL;
  g_mgr_join               := NULL;
  g_ccc_join               := NULL;
  g_viewby_from_clause     := NULL;
  g_viewby_join            := NULL;
  g_viewby_value           := NULL;
  g_viewby_id              := NULL;
  g_fin_type               := NULL;
  g_month_id               := NULL;
  g_page_period_type       := NULL;
  g_py_sper_end            := NULL;
  g_curr_per_sequence      := NULL;
  g_p_period_end           := NULL;
  g_p_p_period_end         := NULL;
  g_cy_period_end          := NULL;
  g_ent_pyr_start          := NULL;
  g_ent_pyr_end            := NULL;
  g_ent_cyr_start          := NULL;
  g_ent_cyr_end            := NULL;
  g_viewby_type            := NULL;
  g_total_hc               := NULL;
  g_py_sday                := NULL;
  g_begin_date             := NULL;
  g_rpt_begin_date         := NULL;
  g_global_curr_view       := NULL;
  g_non_ag_cat_from_clause := NULL;
  g_non_ag_cat_join 	   := NULL;
  g_rev_msg		   := NULL;
  g_exp_msg		   := NULL;
  g_cog_msg		   := NULL;
  g_dir_msg		   := NULL;
  g_prod_id		   := NULL;
  g_cat_join2		   := NULL;
  g_lob_is_top_node	   := 'N';
  g_cc_owner               := NULL;
  g_ccc_mgr_join           := NULL;
  g_ppy_sday               := NULL;
  g_new_date               := NULL;
  g_new_date2              := NULL;
  g_detail_start	   := NULL;
  g_detail_end		   := NULL;
  g_top_spend_start	   := NULL;
  g_top_spend_end	   := NULL;
  g_exp_asof_date          := NULL;
  g_exp_begin_date         := NULL;
  g_exp_start              := NULL;
  g_sd_lyr		   := NULL;
  g_five_yr_back	   := NULL;
  --added for bug fix 5002238
  --added by vkazhipu
  --changing l_id AND l_dim_flag to bind variables
  g_l_id		   := NULL;
  g_dim_flag		   := NULL;
  g_bitmask		   := NULL;
  --added for bug fix 4969910
  --added by hpoddar
  g_start_id		   := NULL;
  g_end_id		   := NULL;
  g_slice_type_flag	   := NULL;
  g_prev_mgr_id		   := NULL;
  g_emp_id		   := NULL;
  g_curr_start_period_id	   := NULL;
  g_curr_end_period_id		   := NULL;

 END reset_globals;

-- -------------------------------------------------
-- Parse thru the parameter talbe AND set globals
-- -------------------------------------------------
PROCEDURE get_parameters (
  p_page_parameter_tbl     IN BIS_PMV_PAGE_PARAMETER_TBL) IS

  l_lob_enabled_flag varchar2(1);
  l_date_range_check NUMBER;
BEGIN

  -- -------------------------------------------------
  -- Parse thru the parameter table AND set globals
  -- -------------------------------------------------
  IF (p_page_parameter_tbl.count > 0) THEN
    FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP
      IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
        g_page_period_type := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
        g_view_by :=  p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' THEN
        g_currency := substr(p_page_parameter_tbl(i).parameter_id,2,11);
      ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME_COMPARISON_TYPE' THEN
        g_time_comp := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
        g_as_of_date :=
                to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'BIS_PREVIOUS_ASOF_DATE' THEN
        g_previous_asof_date :=
                to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'LOB+FII_LOB' THEN
        g_lob_id := replace(get_first_string(p_page_parameter_tbl(i).parameter_id),'''', null);
      ELSIF p_page_parameter_tbl(i).parameter_name = 'HRI_PERSON+HRI_PER_USRDR_H' THEN
        g_mgr_id := replace(p_page_parameter_tbl(i).parameter_id, '''', null);
      ELSIF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+HRI_CL_ORGCC'  THEN
        g_ccc_id := NVL(
                replace(get_first_string(p_page_parameter_tbl(i).parameter_id), '''', null), -999);
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
        g_fin_id := NVL(
                replace(get_first_string(p_page_parameter_tbl(i).parameter_id), '''', null),-999);
      ELSIF p_page_parameter_tbl(i).parameter_name = 'fii_month+fii_month_level' THEN
         g_month_id := replace(p_page_parameter_tbl(i).parameter_id, '''', null);
      ELSIF p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT' THEN
         g_prod_id := replace(p_page_parameter_tbl(i).parameter_id, '''', null);
      END IF;
    END LOOP;
  END IF;



-- Added following line for bug 3893359
--moved to top by vkazhipu for bug 5098174 - 18-May 2006

   SELECT MIN(start_date) INTO g_min_start_date
   FROM fii_time_ent_period;
   SELECT MIN(start_date) INTO g_min_week_start_date
   FROM fii_time_week;

  --added by VKAZHIPU for bug  5098174
  -- This will prevent SQL errors when date is selected outside the range

  BEGIN

  	SELECT 1 into l_date_range_check FROM FII_TIME_DAY
  	where g_as_of_date between start_date and end_date;

  EXCEPTION

  WHEN OTHERS THEN

  g_as_of_date := g_min_start_date;

  END;

---when specific cost center is chosen exp/rev/cogs trend reports are performing bad.  so we
  IF ((g_ccc_id IS NOT NULL) AND (g_ccc_id <> -999)) THEN
     SELECT parent_manager_id
     INTO g_cc_owner
     FROM fii_com_cc_mappings
     WHERE company_cost_center_org_id = g_ccc_id;
  END IF;

/* When LOB chosen is All, we assign the top node LOB id to g_lob_id */

   -- Bug 4135136. Pick the top node id FROM pruned hierarchy table when the
   -- dimension is disabled, otherwise pick FROM fii_financial_dimensions table.

   SELECT     dbi_enabled_flag INTO l_lob_enabled_flag
   FROM       fii_financial_dimensions
   WHERE      dimension_short_name = 'FII_LOB';

 If l_lob_enabled_flag = 'N' THEN
  IF g_lob_id IS NULL OR g_lob_id = 'ALL' THEN
	SELECT  parent_lob_id INTO g_lob_id
	FROM    fii_lob_hierarchies;

	g_lob_is_top_node := 'N';

  END IF;
 ELSE
  IF g_lob_id IS NULL OR g_lob_id = 'ALL' THEN

        SELECT dbi_hier_top_node_id INTO g_lob_id
	FROM fii_financial_dimensions
	WHERE dimension_short_name = 'FII_LOB';

	g_lob_is_top_node := 'Y';
   END IF;
  END IF;

IF g_page_period_type IS NULL THEN
	g_page_period_type := 'FII_TIME_ENT_QTR';
END IF;

IF g_mgr_id IS NULL THEN
	g_mgr_id := -99999;
END IF;

IF g_time_comp IS NULL THEN
	g_time_comp := 'YEARLY';
END IF;

IF g_as_of_date IS NULL THEN
	g_as_of_date := trunc(sysdate);
END IF;

IF g_previous_asof_date IS NULL THEN
	g_previous_asof_date := trunc(sysdate);
END IF;

-- -------------------------------------------------
  -- Set time related global variables
  -- -------------------------------------------------
/* Commented out for bug 3893359 AND replaced with SELECT
  IF (g_as_of_date IS NOT NULL) THEN
    g_ent_pyr_start := fii_time_api.ent_pyr_start(g_as_of_date);
    g_ent_pyr_end:= fii_time_api.ent_pyr_end(g_as_of_date);
    g_ent_cyr_start := fii_time_api.ent_cyr_start(g_as_of_date);
    g_ent_cyr_end := fii_time_api.ent_cyr_end(g_as_of_date);
    g_p_period_end := fii_time_api.ent_sd_lysper_end(g_as_of_date);
    g_p_p_period_end := fii_time_api.ent_sd_lysper_end(g_p_period_end);

   END IF;
*/


  IF (g_as_of_date IS NOT NULL) THEN
    --g_ent_cyr_end := fii_time_api.ent_cyr_end(g_as_of_date);
    SELECT NVL(fii_time_api.ent_cyr_end(g_as_of_date),g_min_start_date) INTO g_ent_cyr_end from dual;
	SELECT	NVL(fii_time_api.ent_pyr_start(g_as_of_date),g_min_start_date),
		NVL(fii_time_api.ent_pyr_end(g_as_of_date),g_min_start_date),
		NVL(fii_time_api.ent_cyr_start(g_as_of_date),g_min_start_date),
		NVL( fii_time_api.ent_sd_lysper_end(g_as_of_date),g_min_start_date)
	INTO	g_ent_pyr_start,
		g_ent_pyr_end,
		g_ent_cyr_start,
		g_p_period_end
	FROM	dual;

	SELECT	NVL(fii_time_api.ent_sd_lysper_end(g_p_period_end),g_min_start_date)
	INTO	g_p_p_period_end
	FROM	dual;
  End IF;

--   End of 3893359

  -- -------------------------------------------------
  -- If user views in primary global, use 1st view which
  -- selects the primary amount.  For secondary global
  -- currency, use 2nd view which selects secondary amount
  -- Default assumed to be viewing data in primary global
  -- -------------------------------------------------
  IF g_currency = 'FII_GLOBAL1' THEN
      g_global_curr_view := '1';
  ELSIF g_currency = 'FII_GLOBAL2' THEN
      g_global_curr_view := '2';
  ELSE
      g_global_curr_view := '1';
  END IF;

  -- -------------------------------------------------
  -- Choose the MV to use AND set corronsponding gid
  -- Three cases:
  --   1 When query involves cost center ie cost center
  --     parameter populated or viewby is cost center,
  --     use the fii_gl_mgmt_ccc_mv, which has no gid
  --   2 When query involves lob but not cost center,
  --     use the 2nd group set of fii_gl_mgmt_sum_mv
  --   3 When query doesn't involve lob or cost center,
  --     use the 1st group set of fii_gl_mgmt_sum_mv
  -- -------------------------------------------------
  IF  (g_view_by = 'ORGANIZATION+HRI_CL_ORGCC') OR ((g_ccc_id IS NOT NULL) AND (g_ccc_id <> -999)) THEN
    g_gid := NULL;
    g_view := ' , FII_GL_MGMT_CCC_V'||g_global_curr_view||' f';
  ELSIF (g_view_by = 'LOB+FII_LOB') OR  ((g_lob_id IS NOT NULL) AND (g_lob_is_top_node <> 'Y')) THEN
    g_gid := ' AND f.gid = 0';
    g_view := ' , FII_GL_MGMT_SUM_V'||g_global_curr_view||' f';
  ELSE
    g_gid := ' AND f.gid = 4';
    g_view := ' , FII_GL_MGMT_SUM_V'||g_global_curr_view||' f';
  END IF;

  g_cog_msg := FND_MESSAGE.get_string('FII', 'FII_GL_X');
  g_exp_msg := FND_MESSAGE.get_string('FII', 'FII_GL_OE');
  g_rev_msg := FND_MESSAGE.get_string('FII', 'FII_GL_R');
  g_dir_msg := FND_MESSAGE.get_string('FII', 'FII_GL_DIR');

  --added for bug fix 5002238
  --by vkazhipu
  --changing l_id AND l_dim_flag to bind variables

  IF g_view_by = 'HRI_PERSON+HRI_PER_USRDR_H' THEN
		g_l_id := fii_gl_util_pkg.g_mgr_id;
		g_dim_flag := NVL(fii_gl_util_pkg.g_mgr_is_leaf,'N');


  ELSIF g_view_by = 'LOB+FII_LOB' THEN
		g_l_id := fii_gl_util_pkg.g_lob_id;
		g_dim_flag := fii_gl_util_pkg.g_lob_is_leaf;

  ELSIF g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
		g_l_id := fii_gl_util_pkg.g_fin_id;
		g_dim_flag := fii_gl_util_pkg.g_fincat_is_leaf;
  ELSE
		g_l_id := -9999;
		g_dim_flag := 'Y';
  END IF;

--added for bug fix 4969910
--added by hpoddar
--changing l_start, l_end and l_slice_type_flag to bind variables

CASE g_page_period_type
    WHEN 'FII_TIME_WEEK'	THEN	g_slice_type_flag := 'M';
					SELECT MIN(ent_period_id), MAX(ent_period_id) INTO g_start_id, g_end_id
					FROM fii_time_ent_period
					WHERE ENT_PERIOD_ID =
						(SELECT ENT_PERIOD_ID FROM fii_time_ent_period
						 WHERE g_as_of_date BETWEEN start_date AND end_date);

    WHEN 'FII_TIME_ENT_PERIOD'	THEN	g_slice_type_flag := 'M';
					SELECT MIN(ent_period_id), MAX(ent_period_id) INTO g_start_id, g_end_id
					FROM fii_time_ent_period
					WHERE ENT_PERIOD_ID =
						(SELECT ENT_PERIOD_ID FROM fii_time_ent_period
						 WHERE g_as_of_date BETWEEN start_date AND end_date);

    WHEN 'FII_TIME_ENT_QTR'	THEN	g_slice_type_flag := 'Q';
					SELECT MIN(ent_period_id), MAX(ent_period_id) INTO g_start_id, g_end_id
					FROM fii_time_ent_period
					WHERE ENT_QTR_ID =
						(SELECT ENT_QTR_ID FROM fii_time_ent_period
						 WHERE g_as_of_date BETWEEN start_date AND end_date);

    WHEN 'FII_TIME_ENT_YEAR'	THEN	g_slice_type_flag := 'Y';
					SELECT MIN(ent_period_id), MAX(ent_period_id) INTO g_start_id, g_end_id
					FROM fii_time_ent_period
					WHERE ENT_YEAR_ID =
						(SELECT ENT_YEAR_ID FROM fii_time_ent_period
						 WHERE g_as_of_date BETWEEN start_date AND end_date);
  END CASE;

END get_parameters;


-- RYLIU2, there are performance enhancements which are not being taken cared
-- of here.  I am not sure the differences BETWEEN these period types AND how
-- they are used.
--   g_period_type, g_where_period_type, g_act_where_period_type,
--   g_actual_period_type, g_ent_period_type
-- Can we discuss it in some details next week.


PROCEDURE get_bitmasks IS
  BUDGET_TIME_UNIT       VARCHAR2(1);
  FORECAST_TIME_UNIT     VARCHAR2(1);
  l_time_parameter       VARCHAR2(100) :=NULL;

BEGIN

  -- -----------------------------------------------------------
  -- Get budget/forecast levels FROM profile options
  -- Default assume budget & forecast are loaded at period level
  -- -----------------------------------------------------------
  BUDGET_TIME_UNIT   := NVL(FND_PROFILE.Value( 'FII_BUDGET_TIME_UNIT'),'P');
  FORECAST_TIME_UNIT := NVL(FND_PROFILE.Value( 'FII_FORECAST_TIME_UNIT'),'P');

  CASE g_page_period_type
    WHEN 'FII_TIME_WEEK'       THEN g_period_type := 16;
    WHEN 'FII_TIME_ENT_PERIOD' THEN g_period_type := 32;
    WHEN 'FII_TIME_ENT_QTR'    THEN g_period_type := 64;
    WHEN 'FII_TIME_ENT_YEAR'   THEN g_period_type := 128;
  END CASE;

  -- Get the correct masks for the period types
  CASE g_page_period_type
    WHEN 'FII_TIME_WEEK'       THEN g_where_period_type := 11;
    WHEN 'FII_TIME_ENT_PERIOD' THEN g_where_period_type := 279; --1+2+4+16+256
    WHEN 'FII_TIME_ENT_QTR'    THEN g_where_period_type := 823; --1+2+4+16+32+256+512
    WHEN 'FII_TIME_ENT_YEAR'   THEN g_where_period_type := 1015; --1+2+4+16+32+64+128+256+512
  END CASE;

  CASE g_page_period_type
    WHEN 'FII_TIME_WEEK'       THEN g_act_where_period_type := 11;
    WHEN 'FII_TIME_ENT_PERIOD' THEN g_act_where_period_type := 23; --1+2+4+16
    WHEN 'FII_TIME_ENT_QTR'    THEN g_act_where_period_type := 55; --1+2+4+16+32
    WHEN 'FII_TIME_ENT_YEAR'   THEN g_act_where_period_type := 247; --1+2+4+16+32+64+128
  END CASE;

  CASE g_page_period_type
    WHEN 'FII_TIME_WEEK'       THEN g_actual_period_type := 11;
    WHEN 'FII_TIME_ENT_PERIOD' THEN g_actual_period_type := 23;
    WHEN 'FII_TIME_ENT_QTR'    THEN g_actual_period_type := 55;
    WHEN 'FII_TIME_ENT_YEAR'   THEN g_actual_period_type := 119;
  END CASE;

  CASE g_page_period_type
    WHEN 'FII_TIME_WEEK'       THEN g_ent_period_type := 2048;
    WHEN 'FII_TIME_ENT_PERIOD' THEN g_ent_period_type := 256;
    WHEN 'FII_TIME_ENT_QTR'    THEN g_ent_period_type := 512;
    WHEN 'FII_TIME_ENT_YEAR'   THEN g_ent_period_type := 128;
  END CASE;

/* code modified by ilavenil on 02/20/03.  2808245 - budget should run for the entire period */
    CASE BUDGET_TIME_UNIT
    WHEN 'D' then
      g_budget_period_type := g_actual_period_type;
    WHEN 'P' THEN
      CASE g_page_period_type
        WHEN 'FII_TIME_WEEK'       THEN g_budget_period_type := 0;
        WHEN 'FII_TIME_ENT_PERIOD' THEN g_budget_period_type := 256;
        WHEN 'FII_TIME_ENT_QTR'    THEN g_budget_period_type := 512;
        WHEN 'FII_TIME_ENT_YEAR'   THEN g_budget_period_type := 128;
      END CASE;
    WHEN 'Q' THEN
      CASE g_page_period_type
        WHEN 'FII_TIME_WEEK'       THEN g_budget_period_type := 0;
        WHEN 'FII_TIME_ENT_PERIOD' THEN g_budget_period_type := 0;
        WHEN 'FII_TIME_ENT_QTR'    THEN g_budget_period_type := 512;
        WHEN 'FII_TIME_ENT_YEAR'   THEN g_budget_period_type := 128;
      END CASE;
    WHEN 'Y' THEN
      CASE g_page_period_type
        WHEN 'FII_TIME_WEEK'       THEN g_budget_period_type := 0;
        WHEN 'FII_TIME_ENT_PERIOD' THEN g_budget_period_type := 0;
        WHEN 'FII_TIME_ENT_QTR'    THEN g_budget_period_type := 0;
        WHEN 'FII_TIME_ENT_YEAR'   THEN g_budget_period_type := 128;
      END CASE;
    END CASE;

  CASE FORECAST_TIME_UNIT
    WHEN 'D' THEN
      g_forecast_period_type := g_actual_period_type;
    WHEN 'P' THEN
      CASE g_page_period_type
        WHEN 'FII_TIME_WEEK'       THEN g_forecast_period_type := 0;
        WHEN 'FII_TIME_ENT_PERIOD' THEN g_forecast_period_type := 256;
        WHEN 'FII_TIME_ENT_QTR'    THEN g_forecast_period_type := 512;
        WHEN 'FII_TIME_ENT_YEAR'   THEN g_forecast_period_type := 128;
      END CASE;
    WHEN 'Q' THEN
      CASE g_page_period_type
        WHEN 'FII_TIME_WEEK'       THEN g_forecast_period_type := 0;
        WHEN 'FII_TIME_ENT_PERIOD' THEN g_forecast_period_type := 0;
        WHEN 'FII_TIME_ENT_QTR'    THEN g_forecast_period_type := 512;
        WHEN 'FII_TIME_ENT_YEAR'   THEN g_forecast_period_type := 128;
      END CASE;
    WHEN 'Y' THEN
      CASE g_page_period_type
        WHEN 'FII_TIME_WEEK'       THEN g_forecast_period_type := 0;
        WHEN 'FII_TIME_ENT_PERIOD' THEN g_forecast_period_type := 0;
        WHEN 'FII_TIME_ENT_QTR'    THEN g_forecast_period_type := 0;
        WHEN 'FII_TIME_ENT_YEAR'   THEN g_forecast_period_type := 128;
      END CASE;
  END CASE;

--      Most of the following global variables are specific to the
--      Exp. per head AND T & E Trend reports. So the some of the bind names
--      AND global variable names are not intuitive

 SELECT NVL( fii_time_api.ent_sd_lysper_end(g_as_of_date),g_min_start_date) INTO g_sd_lyr FROM dual;

  CASE g_page_period_type

  WHEN 'FII_TIME_WEEK' THEN

       --g_curr_end := fii_time_api.cwk_end(g_as_of_date);
       SELECT NVL(fii_time_api.cwk_end(g_as_of_date),g_min_start_date) INTO g_curr_end FROM DUAL;

        SELECT	NVL(fii_time_api.cwk_end(g_previous_asof_date),g_min_start_date),
		NVL( fii_time_api.pwk_end(g_as_of_date),g_min_start_date),
		NVL( fii_time_api.sd_lyswk(g_as_of_date),g_min_start_date),
		NVL(DECODE(fii_time_api.cwk_start(g_as_of_date),g_min_week_start_date,g_min_start_date,fii_time_api.cwk_start(g_as_of_date)),g_min_start_date)
	INTO	g_py_sper_end,
		g_cy_period_end,
		g_py_sday,
		g_curr_start
	FROM    dual;

	SELECT	report_date_julian INTO g_curr_start_day_id FROM fii_time_day WHERE report_date = g_curr_start;
	SELECT	report_date_julian INTO g_curr_end_day_id FROM fii_time_day WHERE report_date = g_curr_end;

	g_temp := NULL;

	SELECT	NVL(DECODE(fii_time_api.cwk_start(g_previous_asof_date),g_min_week_start_date,g_min_start_date,fii_time_api.cwk_start(g_previous_asof_date)),g_min_start_date),
		NVL( fii_time_api.cwk_end(g_previous_asof_date),g_min_start_date),
		NVL( fii_time_api.sd_lyswk(g_as_of_date),g_min_start_date)
	INTO    g_prior_start,
		g_prior_end,
		g_exp_asof_date
	FROM    dual;

	SELECT  NVL(fii_time_api.sd_lyswk(g_exp_asof_date),g_min_start_date)
	INTO    g_exp_start
	FROM    dual;

	g_exp_begin_date := g_as_of_date - 91;

	SELECT	ent_period_start_date
	INTO	g_top_spend_start
	FROM	fii_time_day
	WHERE	report_date = g_as_of_date;

	SELECT	MAX(end_date) INTO g_top_spend_end
	FROM	fii_time_ent_period
	WHERE	ent_period_id = ( SELECT  ent_period_id
				  FROM	  fii_time_ent_period
			          WHERE   g_as_of_date BETWEEN start_date AND end_date);

	CASE g_time_comp
	WHEN 'BUDGET' THEN
	                        SELECT NVL( fii_time_api.cwk_start(g_as_of_date),g_min_start_date)
				INTO   g_prior_start
			        FROM	 dual;

		  	        --g_prior_end   := fii_time_api.cwk_end(g_as_of_date);
		  	        SELECT NVL(fii_time_api.cwk_end(g_as_of_date),g_min_start_date) INTO g_prior_end FROM DUAL;

	  			SELECT report_date_julian INTO g_prior_start_day_id FROM fii_time_day WHERE report_date = g_curr_start;
				SELECT report_date_julian INTO g_prior_end_day_id FROM fii_time_day WHERE report_date = g_curr_end;
	ELSE
				SELECT report_date_julian INTO g_prior_start_day_id FROM fii_time_day WHERE report_date = g_prior_start;
				SELECT report_date_julian INTO g_prior_end_day_id FROM fii_time_day WHERE report_date = g_prior_end;
	END CASE;

        SELECT NVL(fii_time_api.sd_lyswk(g_py_sday),g_min_start_date)
	INTO   g_rpt_begin_date
	FROM   dual;

        g_begin_date := g_as_of_date - 91;

        SELECT	DISTINCT a.sequence INTO g_curr_per_sequence
        FROM	fii_time_week a
        WHERE	g_as_of_date BETWEEN a.START_DATE AND a.END_DATE;

   WHEN 'FII_TIME_ENT_PERIOD' THEN
       IF (g_previous_asof_date IS NULL) THEN
	        SELECT NVL(fii_time_api.ent_sd_lysper_beg(g_as_of_date),g_min_start_date)
		INTO    g_previous_asof_date
	        FROM    dual;
       END IF;

        SELECT NVL( fii_time_api.ent_cper_end(g_previous_asof_date),g_min_start_date),
               NVL(fii_time_api.ent_pper_end(g_as_of_date),g_min_start_date),
               NVL( fii_time_api.ent_sd_lysper_end(g_as_of_date),g_min_start_date),
               NVL( fii_time_api.ent_sd_lysper_end(g_sd_lyr),g_min_start_date),
               NVL(fii_time_api.ent_cper_start(g_as_of_date),g_min_start_date),
	       NVL(fii_time_api.ent_cper_start(g_previous_asof_date),g_min_start_date),
               NVL(fii_time_api.ent_cper_end(g_previous_asof_date),g_min_start_date),
               NVL(fii_time_api.ent_sd_lysper_end(g_as_of_date),g_min_start_date)
       INTO    g_py_sper_end,
               g_cy_period_end,
               g_py_sday,
               g_ppy_sday,
               g_curr_start,
               g_prior_start,
               g_prior_end,
               g_exp_asof_date
       FROM    dual;

       SELECT NVL(fii_time_api.ent_sd_lysper_end(g_exp_asof_date),g_min_start_date)
       INTO   g_exp_start
       FROM dual;

       --g_curr_end := fii_time_api.ent_cper_end(g_as_of_date);
       SELECT NVL(fii_time_api.ent_cper_end(g_as_of_date),g_min_start_date) INTO g_curr_end FROM DUAL;

       SELECT ent_period_id INTO g_curr_start_period_id FROM fii_time_ent_period WHERE start_date = g_curr_start;
       SELECT ent_period_id INTO g_curr_end_period_id FROM fii_time_ent_period WHERE end_date = g_curr_end;
       SELECT report_date_julian INTO g_curr_start_day_id FROM fii_time_day WHERE report_date = g_curr_start;
       SELECT report_date_julian INTO g_curr_end_day_id FROM fii_time_day WHERE report_date = g_curr_end;

       g_temp := NULL;

       g_exp_begin_date := g_exp_asof_date;

       SELECT	 ent_period_start_date
       INTO	g_top_spend_start
       FROM	fii_time_day
       WHERE	report_date = g_as_of_date;

       SELECT	MAX(end_date)
       INTO	g_top_spend_end
       FROM	fii_time_ent_period
       WHERE	ent_period_id = ( SELECT  ent_period_id
			          FROM	  fii_time_ent_period
			          WHERE	  g_as_of_date BETWEEN start_date AND end_date);

       CASE g_time_comp
		WHEN 'BUDGET' THEN
			          SELECT NVL( fii_time_api.ent_cper_start(g_as_of_date),g_min_start_date)
		                  INTO	 g_prior_start
	                          FROM	 dual;

				  --g_prior_end   := fii_time_api.ent_cper_end(g_as_of_date);
				  SELECT NVL(fii_time_api.ent_cper_end(g_as_of_date),g_min_start_date) INTO g_prior_end FROM DUAL;

 				  SELECT report_date_julian INTO g_prior_start_day_id FROM fii_time_day WHERE report_date = g_curr_start;
			          SELECT report_date_julian INTO g_prior_end_day_id FROM fii_time_day WHERE report_date = g_curr_end;
		ELSE
				  SELECT report_date_julian INTO g_prior_start_day_id FROM fii_time_day WHERE report_date = g_prior_start;
				  SELECT report_date_julian INTO g_prior_end_day_id FROM fii_time_day WHERE report_date = g_prior_end;
       END CASE;

       SELECT NVL( fii_time_api.ent_sd_lysper_end(g_py_sday),g_min_start_date)
       INTO   g_rpt_begin_date
       FROM   dual;

       g_begin_date := g_py_sday;

       SELECT	DISTINCT a.sequence INTO g_curr_per_sequence
       FROM	fii_time_ent_period a
       WHERE	g_as_of_date BETWEEN a.START_DATE AND a.END_DATE;

  WHEN 'FII_TIME_ENT_QTR' THEN

       SELECT NVL(fii_time_api.ent_cqtr_end(g_previous_asof_date),g_min_start_date),
              NVL( fii_time_api.ent_pqtr_end(g_as_of_date),g_min_start_date),
              NVL( fii_time_api.ent_sd_lysqtr_end(g_as_of_date),g_min_start_date),
              NVL(fii_time_api.ent_cqtr_start(g_as_of_date),g_min_start_date),
	      NVL(fii_time_api.ent_cqtr_start(g_previous_asof_date),g_min_start_date),
              NVL(fii_time_api.ent_cqtr_end(g_previous_asof_date),g_min_start_date)
        INTO  g_py_sper_end,
              g_cy_period_end,
              g_py_sday,
              g_curr_start,
              g_prior_start,
              g_prior_end
        FROM  dual;

       --g_curr_end := fii_time_api.ent_cqtr_end(g_as_of_date);
       SELECT NVL(fii_time_api.ent_cqtr_end(g_as_of_date),g_min_start_date) INTO g_curr_end FROM DUAL;

       SELECT ent_period_id INTO g_curr_start_period_id FROM fii_time_ent_period WHERE start_date = g_curr_start;
       SELECT ent_period_id INTO g_curr_end_period_id FROM fii_time_ent_period WHERE end_date = g_curr_end;
       SELECT report_date_julian INTO g_curr_start_day_id FROM fii_time_day WHERE report_date = g_curr_start;
       SELECT report_date_julian INTO g_curr_end_day_id FROM fii_time_day WHERE report_date = g_curr_end;

       g_temp := NULL;

       SELECT	ent_qtr_start_date
       INTO	g_top_spend_start
       FROM	fii_time_day
       WHERE	report_date = g_as_of_date;

       SELECT	MAX(end_date)
       INTO	g_top_spend_end
       FROM	fii_time_ent_period
       WHERE	ent_qtr_id =( SELECT	ent_qtr_id
			      FROM	fii_time_ent_period
			      WHERE	g_as_of_date BETWEEN start_date AND end_date);

       SELECT	NVL(fii_time_api.ent_sd_lysqtr_end(g_py_sday),g_min_start_date)
       INTO	g_rpt_begin_date
       FROM	dual;

       IF (g_time_comp = 'SEQUENTIAL') THEN

		SELECT NVL(fii_time_api.ent_sd_lysqtr_end(g_rpt_begin_date),g_min_start_date)
		INTO   g_begin_date
		FROM   dual;

		SELECT DISTINCT a.ent_qtr_id INTO g_curr_per_sequence
		FROM   fii_time_ent_qtr a
		WHERE  g_as_of_date BETWEEN a.START_DATE AND a.END_DATE;

		SELECT  NVL(fii_time_api.ent_sd_lysqtr_end(g_as_of_date),g_min_start_date)
		INTO    g_exp_asof_date
		FROM    dual;

		SELECT  NVL(fii_time_api.ent_sd_lysqtr_end(fii_time_api.ent_sd_lysqtr_end(g_exp_asof_date)),g_min_start_date)
		INTO    g_exp_begin_date
		FROM    dual;
       ELSE
	        g_begin_date := g_py_sday;

		SELECT DISTINCT a.sequence INTO g_curr_per_sequence
		FROM   fii_time_ent_qtr a
		WHERE  g_as_of_date BETWEEN a.START_DATE AND a.END_DATE;

		SELECT  NVL(fii_time_api.ent_sd_lysqtr_end(g_as_of_date),g_min_start_date)
                INTO	g_exp_asof_date
                FROM	dual;

		g_exp_begin_date := g_exp_asof_date;

       END IF;

       SELECT	NVL(fii_time_api.ent_sd_lysqtr_end(g_exp_asof_date),g_min_start_date)
       INTO	g_exp_start
       FROM	dual;

       CASE g_time_comp
       WHEN 'BUDGET' THEN
				SELECT NVL( fii_time_api.ent_cqtr_start(g_as_of_date),g_min_start_date)
				INTO   g_prior_start
				FROM   dual;

				--g_prior_end  := fii_time_api.ent_cqtr_end(g_as_of_date);
				SELECT NVL(fii_time_api.ent_cqtr_end(g_as_of_date),g_min_start_date) INTO g_prior_end from dual;

				SELECT report_date_julian INTO g_prior_start_day_id FROM fii_time_day WHERE report_date = g_curr_start;
				SELECT report_date_julian INTO g_prior_end_day_id FROM fii_time_day WHERE report_date = g_curr_end;
       ELSE
				SELECT report_date_julian INTO g_prior_start_day_id FROM fii_time_day WHERE report_date = g_prior_start;
				SELECT report_date_julian INTO g_prior_end_day_id FROM fii_time_day WHERE report_date = g_prior_end;
       END CASE;

  WHEN 'FII_TIME_ENT_YEAR' THEN

       g_cy_period_end :=  NULL;
       g_py_sday := NULL;

       SELECT NVL( fii_time_api.ent_pyr_end(g_as_of_date),g_min_start_date),
              NVL( fii_time_api.ent_cyr_start(g_as_of_date),g_min_start_date),
              NVL( fii_time_api.ent_cper_start(g_as_of_date),g_min_start_date),
              NVL( fii_time_api.ent_cyr_start(g_previous_asof_date),g_min_start_date),
              NVL( fii_time_api.ent_cyr_end(g_previous_asof_date),g_min_start_date)
       INTO   g_py_sper_end,
              g_curr_start,
              g_temp,
              g_prior_start,
              g_prior_end
       FROM   dual;

       --g_curr_end := fii_time_api.ent_cyr_end(g_as_of_date);
       SELECT NVL(fii_time_api.ent_cyr_end(g_as_of_date),g_min_start_date) INTO g_curr_end FROM DUAL;

       SELECT ent_period_id INTO g_curr_start_period_id FROM fii_time_ent_period WHERE start_date = g_curr_start;
       SELECT ent_period_id INTO g_curr_end_period_id FROM fii_time_ent_period WHERE end_date = g_curr_end;
       SELECT report_date_julian INTO g_curr_start_day_id FROM fii_time_day WHERE report_date = g_curr_start;
       SELECT report_date_julian INTO g_curr_end_day_id FROM fii_time_day WHERE report_date = g_curr_end;

       g_exp_asof_date := NULL;
       g_exp_start := NULL;

       SELECT	ent_year_start_date
       INTO	g_top_spend_start
       FROM	fii_time_day
       WHERE	report_date = g_as_of_date;

       SELECT	MAX(end_date)
       INTO	g_top_spend_end
       FROM	fii_time_ent_period
       WHERE	ent_year_id = (  SELECT ent_year_id
			      FROM fii_time_ent_period
			      WHERE g_as_of_date BETWEEN start_date AND end_date);

       CASE g_time_comp
		WHEN 'BUDGET' THEN
			  SELECT NVL( fii_time_api.ent_cyr_start(g_as_of_date),g_min_start_date)
                          INTO   g_prior_start
                          FROM   dual;

		          --g_prior_end   := fii_time_api.ent_cyr_end(g_as_of_date);
		          SELECT NVL(fii_time_api.ent_cyr_end(g_as_of_date),g_min_start_date) INTO g_prior_end from dual;

			  SELECT report_date_julian INTO g_prior_start_day_id FROM fii_time_day WHERE report_date = g_curr_start;
		          SELECT report_date_julian INTO g_prior_end_day_id FROM fii_time_day WHERE report_date = g_curr_end;

		ELSE
			  SELECT report_date_julian INTO g_prior_start_day_id FROM fii_time_day WHERE report_date = g_prior_start;
			  SELECT report_date_julian INTO g_prior_end_day_id FROM fii_time_day WHERE report_date = g_prior_end;
       END CASE;

       g_rpt_begin_date := NULL;
       g_begin_date := NULL;
       g_curr_per_sequence := NULL;
   END CASE;

IF g_month_id IS NULL THEN NULL;
ELSE
	SELECT start_date, end_date
	INTO g_detail_start, g_detail_end
	FROM fii_time_ent_period
	WHERE ent_period_id = g_month_id;
END IF;

SELECT NVL(to_char(MIN(ent_period_id)),g_month_id)
INTO l_time_parameter
FROM fii_time_ent_period
WHERE g_as_of_date BETWEEN start_date AND end_date;

  IF (g_month_id <> l_time_parameter) THEN

	g_bitmask := 256;

	SELECT end_date
	INTO g_new_date
	FROM fii_time_ent_period
	WHERE ent_period_id = g_month_id;

	SELECT NVL(fii_time_api.ent_sd_lysper_end(g_new_date),g_min_start_date)
        INTO   g_new_date2
        FROM   dual;
  ELSE
	g_bitmask := 23;

	g_new_date := g_as_of_date;

	SELECT NVL(fii_time_api.ent_sd_lyr_end(g_as_of_date),g_min_start_date)
        INTO   g_new_date2
        FROM   dual;

 END IF;

END get_bitmasks;


-- -------------------------------------------------
-- Set the view by global variables depending
-- the view by for the given sql
-- -------------------------------------------------
PROCEDURE get_viewby_sql IS
BEGIN

  CASE g_view_by
    WHEN 'HRI_PERSON+HRI_PER_USRDR_H' THEN
      g_viewby_value := ' ppl.value ';
      g_viewby_id := ' f.person_id ';
      g_viewby_from_clause := ' hri_dbi_cl_per_n_v ppl ';
      g_viewby_join := ' ppl.id = f.viewby_id
        AND sysdate BETWEEN ppl.effective_start_date AND ppl.effective_end_date';
    WHEN 'LOB+FII_LOB' THEN
      get_lob;
      g_viewby_value := ' NVL(tl.description,tl.flex_value_meaning) ';
      IF g_lob_is_leaf = 'Y' THEN
        g_viewby_id := ' f.line_of_business_id ';
      ELSE
        g_viewby_id := ' lob.next_level_lob_id ';
      END IF;
      g_viewby_from_clause := ' fnd_flex_values_tl tl ';
      g_viewby_join := ' f.viewby_id  = tl.flex_value_id AND tl.language = userenv(''LANG'')';
    WHEN 'ORGANIZATION+HRI_CL_ORGCC' THEN
      g_viewby_value := ' cc.name ';
      g_viewby_id := ' f.cost_center_org_id ';
      g_viewby_from_clause := ' hr_all_organization_units_tl cc ';
      g_viewby_join := ' cc.organization_id = f.viewby_id AND cc.language = userenv(''LANG'')';
    WHEN 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
      g_viewby_value := ' NVL(tl.description,tl.flex_value_meaning) ';
      g_viewby_id := ' f.fin_category_id ';
      g_viewby_from_clause := ' fnd_flex_values_tl tl ';
      g_viewby_join := ' f.viewby_id = tl.flex_value_id AND tl.language = userenv(''LANG'')';
  END CASE;

END get_viewby_sql;

-- -------------------------------------------------
-- Set the manager related FROM/WHERE clauses
-- -------------------------------------------------
PROCEDURE get_mgr_pmv_sql IS
  l_mgr_mgr_id NUMBER;
BEGIN

  IF ((g_ccc_id IS NOT NULL) AND (g_ccc_id <> -999)) THEN
    -- ---------------------------------------------------------
    -- Whenever cost center parameter is specified, we no longer
    -- need any filter on mgr regardless of the view by
    -- ---------------------------------------------------------
      g_mgr_join := NULL;
      g_mgr_from_clause := NULL;

  ELSE
    if g_mgr_id <> -99999 then
    get_supervisor(l_mgr_mgr_id);
    END if;
    CASE g_view_by
    WHEN 'ORGANIZATION+HRI_CL_ORGCC' THEN
      -- ---------------------------------------------------------
      -- For viewby cost center, we join to mgr hierarchy table
      -- because fii_gl_mgmg_ccc_mv does not aggregate up mgr
      -- Exception when manager is leaf, we can directly query
      -- against the mv without going thru mgr hierarchy table
      -- ---------------------------------------------------------
      IF g_mgr_is_leaf = 'Y' THEN
        IF g_mgr_id = -99999 THEN g_mgr_join := ' AND f.manager_id = -99999 ';
	ELSE g_mgr_join := ' AND f.manager_id = &HRI_PERSON+HRI_PER_USRDR_H ';
	END IF;
      ELSE
        IF g_mgr_id = -99999 THEN g_mgr_join := ' AND h.mgr_id = -99999
            AND h.emp_id = f.manager_id ';
        g_mgr_from_clause := ', fii_cc_mgr_hierarchies h';
	ELSE
	g_mgr_join := ' AND h.mgr_id = &HRI_PERSON+HRI_PER_USRDR_H
            AND h.emp_id = f.manager_id ';
        g_mgr_from_clause := ', fii_cc_mgr_hierarchies h';
      END IF;
      END IF;

    WHEN 'HRI_PERSON+HRI_PER_USRDR_H' THEN
      -- ---------------------------------------------------------
      -- For viewby manager, we go to fii_gl_mgmt_sum_mv which
      -- does aggregate up mgr.  we filter on the column manager_id
      -- AND view by person id.  Exception when manager is leaf,
      -- we filter on the column person_id AND view by person_id
      -- because of the self vs Org records reduction at
      -- the leaf level
      -- ---------------------------------------------------------
      IF g_mgr_is_leaf = 'Y' THEN
        g_mgr_mgr_id := l_mgr_mgr_id;
        IF g_mgr_id = -99999 THEN g_mgr_join := ' AND f.person_id = -99999
            AND f.manager_id = :MGR_MGR_ID ';
	ELSE g_mgr_join := ' AND f.person_id = &HRI_PERSON+HRI_PER_USRDR_H
            AND f.manager_id = :MGR_MGR_ID ';
	    END IF;
      ELSE
        IF g_mgr_id = -99999 THEN g_mgr_join := ' AND f.manager_id = -99999 ';
	ELSE g_mgr_join := ' AND f.manager_id = &HRI_PERSON+HRI_PER_USRDR_H ';
	END IF;
      END IF;

    ELSE
      -- ---------------------------------------------------------
      -- All other viewby's have standard filter on manager_id AND
      -- person_id
      -- ---------------------------------------------------------
      g_mgr_mgr_id := l_mgr_mgr_id;
      IF g_mgr_id = -99999 THEN g_mgr_join := ' AND f.person_id = -99999 AND f.manager_id = :MGR_MGR_ID ';
	ELSE g_mgr_join := ' AND f.person_id = &HRI_PERSON+HRI_PER_USRDR_H
        AND f.manager_id = :MGR_MGR_ID ';
	END IF;
    END CASE;

  END IF;

END get_mgr_pmv_sql;

FUNCTION get_first_string (l_id IN VARCHAR2) RETURN VARCHAR2 IS

l_pos INTEGER := 0;
l_string VARCHAR2(100) := NULL;
BEGIN
    l_string := l_id;
    l_pos := instr(l_string, ',');
    IF l_pos <> 0 THEN
        l_string := substr(l_string, 0, l_pos - 1);
    END IF;

    return l_string;

END get_first_string;

-- -------------------------------------------------
-- Set the LOB related FROM/WHERE clauses
-- -------------------------------------------------
PROCEDURE get_lob_pmv_sql IS
BEGIN

  IF ((g_ccc_id IS NOT NULL) AND (g_ccc_id <> -999)) THEN
    -- ---------------------------------------------------------
    -- Whenever cost center parameter is specified, we no longer
    -- need any filter on lob regardless of the view by
    -- ---------------------------------------------------------
    g_lob_join := NULL;
    g_lob_from_clause := NULL;

  ELSE
    -- ---------------------------------------------------------
    -- When query involves LOB (LOB specified or is view by LOB)
    -- We need to add filter for LOB.  Two cases:
    --   1  LOB is leaf, we directly query the mv
    --   2  LOB specified is not leaf, we go thru lob hier table
    -- ---------------------------------------------------------
    IF (g_view_by =  'LOB+FII_LOB') OR (g_lob_is_top_node <> 'Y') THEN
	get_lob;
	IF (g_lob_is_leaf = 'Y') THEN
		g_lob_join := ' AND f.line_of_business_id = :LOB_ID ';
	ELSE
		g_lob_join := ' AND    lob.parent_lob_id = :LOB_ID
				AND    lob.child_lob_id = f.line_of_business_id';
		g_lob_from_clause := ' ,fii_lob_hierarchies lob';
	END IF;
    END IF;
END IF;

END get_lob_pmv_sql;


-- -------------------------------------------------
-- Set the cost center related FROM/WHERE clauses
-- -------------------------------------------------
PROCEDURE get_ccc_pmv_sql IS
BEGIN

  IF ((g_ccc_id IS NOT NULL) AND (g_ccc_id <> -999)) THEN
       g_ccc_mgr_join := ' AND f.manager_id = :CCC_OWNER ';
    -- ----------------------------------------------------
    -- If company cost center is specified, conditions on mgr
    -- or lob are no longer needed because ccc is at lower
    -- granularity.  However, if the given ccc does not belong to
    -- the given manager or lob parameter, the query will
    -- return no data.  In such a case, we simply give 1=2
    -- condition to void the whole query
    -- ----------------------------------------------------
    IF (ccc_within_mgr_lob(g_ccc_id, g_lob_id, g_mgr_id) = 'Y') THEN
      g_ccc_join := ' AND f.cost_center_org_id = &ORGANIZATION+HRI_CL_ORGCC ';
    ELSE
      g_ccc_join := ' AND 1 = 2 ';
    END IF;
  END IF;

END get_ccc_pmv_sql;



PROCEDURE get_cat_pmv_sql IS
  l_fin_id             NUMBER;
  l_parent_fin_id      NUMBER;
  -- Bug 4249917. Increased the size of the following variables to 32000.
  l_category_id        VARCHAR2(32000) := null;
  l_category_id2       VARCHAR2(32000) := null;
  l_category_id3       VARCHAR2(32000) := null;
  l_first              BOOLEAN := TRUE;
  type1 VARCHAR2(10);
  type2 VARCHAR2(10);
  type3 VARCHAR2(10);
  CURSOR get_top_nodes(type1 VARCHAR2, type2 VARCHAR2, type3 VARCHAR2) IS
        SELECT a.fin_category_id fin_category_id, b.PARENT_FIN_CAT_ID parent_fin_cat_id
        FROM fii_fin_cat_type_assgns a, fii_fin_item_hierarchies b
        WHERE a.FIN_CAT_TYPE_CODE IN (type1, type2, type3)
        AND a.TOP_NODE_FLAG = 'Y'
        AND a.fin_category_id = b.CHILD_FIN_CAT_ID
        AND a.fin_category_id <> b.PARENT_FIN_CAT_ID;


  -- ------------------------------------------------------
  --     CASE statement stes category types based on report
  --     Example: Expense related reports only need 'OE' etc.
  -- ------------------------------------------------------
BEGIN
     CASE g_fin_type
       WHEN 'R' THEN
       type1 := 'R';
       type2 := 'R';
       type3 := 'R';
       WHEN 'OE' THEN
       type1 := 'OE';
       type2 := 'OE';
       type3 := 'OE';
       WHEN 'CGS' THEN
       type1 := 'CGS';
       type2 := 'CGS';
       type3 := 'CGS';
       WHEN 'TE' THEN
       type1 := 'TE';
       type2 := 'TE';
       type3 := 'TE';
       WHEN 'OM' THEN
       type1 := 'R';
       type2 := 'OE';
       type3 := 'CGS';
       WHEN 'GM' THEN
       type1 := 'R';
       type2 := 'CGS';
       type3 := 'R';
     END CASE;

    IF (g_fin_id = -999 or g_fin_id IS NULL) THEN
       FOR a IN get_top_nodes (type1, type2, type3)
       LOOP
       l_fin_id := a.fin_category_id;
       get_fin_item(l_fin_id, l_parent_fin_id);
         IF (get_top_nodes%ROWCOUNT = 1) THEN
               IF (g_fincat_is_leaf = 'N') THEN
                    l_category_id := a.fin_category_id;
               ELSE
                    l_category_id3 := '('||a.fin_category_id||','||a.parent_fin_cat_id||')';
               END IF;
               IF (l_category_id IS NULL) THEN
                   l_category_id := '-999';
               END IF;
               IF (l_category_id3 IS NULL) THEN
                   l_category_id3 := '(-999 , -999)';
               END IF;
            l_category_id2 := '('||a.fin_category_id||','||a.parent_fin_cat_id||')';
            l_first := FALSE;
         ELSE
                IF (g_fincat_is_leaf = 'N') THEN
                    l_category_id := l_category_id ||','||a.fin_category_id;
                ELSE
                    l_category_id3 := l_category_id3 ||','||'('||a.fin_category_id||','||a.parent_fin_cat_id||')';
                END IF;
            l_category_id2 := l_category_id2 ||','||'('||a.fin_category_id||','||a.parent_fin_cat_id||')';
         END IF;
       END LOOP;
    END IF;

  -- ------------------------------------------------------
  --      If no top nodes are defined for the specified fin type/s,
  --     report should not error out. In this case,
  --     we use a category id that does not exist i.e. -999
    -- ------------------------------------------------------

   IF (l_category_id IS NULL) THEN
       l_category_id := '-999';
   END IF;

   IF (l_category_id2 IS NULL) THEN
       l_category_id2 := '(-999 , -999)';
   END IF;

      IF (l_category_id3 IS NULL) THEN
       l_category_id3 := '(-999 , -999)';
   END IF;

  l_fin_id := g_fin_id;
  get_fin_item(l_fin_id, l_parent_fin_id);

   IF g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
      IF (g_fin_id = -999 or g_fin_id IS NULL) THEN
         g_cat_join := ' AND (f.parent_fin_category_id  in  ('||l_category_id||')
                              or (f.fin_category_id, f.parent_fin_category_id) in ('||l_category_id3||'))';
/* Modified g_cat_join2 as part of bug fix for 3769162 */
	     g_cat_join2 := ' AND (cat_hier.parent_fin_cat_id  in  ('||l_category_id||')
                              or (cat_hier.child_fin_cat_id, cat_hier.parent_fin_cat_id) in ('||l_category_id3||'))';
      ELSE
         IF g_fincat_is_leaf = 'Y' THEN
            g_parent_fin_id := l_parent_fin_id;
            g_cat_join := ' AND f.parent_fin_category_id = :PARENT_FIN_ID
                            AND f.fin_category_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM';
         ELSE
            g_cat_join := ' AND f.parent_fin_category_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM';

         END IF;
          g_cat_join2 := ' AND cat_hier.parent_fin_cat_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM';
      END IF;

   ELSE

     IF (g_fin_id = -999 or g_fin_id IS NULL) THEN
     --If Category is not a paramater or view by, g_fin_id will be NULL
        g_cat_join := ' AND (f.fin_category_id, f.parent_fin_category_id) in ('||l_category_id2||')';

     ELSE
        g_parent_fin_id := l_parent_fin_id;
        g_cat_join := ' AND f.parent_fin_category_id = :PARENT_FIN_ID
        AND f.fin_category_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM';
     END IF;

   END IF;

END get_cat_pmv_sql;


PROCEDURE get_non_ag_cat_pmv_sql IS
  -- Bug 4249917. Increased the size of l_category_id to 32000.
  l_fin_id             NUMBER;
  l_parent_fin_id      NUMBER;
  l_category_id        VARCHAR2(32000) := null;
  l_first              BOOLEAN := TRUE;
  type1 VARCHAR2(10);
  CURSOR get_top_nodes(type1 VARCHAR2) IS
        SELECT a.fin_category_id fin_category_id, b.PARENT_FIN_CAT_ID parent_fin_cat_id
        FROM fii_fin_cat_type_assgns a, fii_fin_item_hierarchies b
        WHERE a.FIN_CAT_TYPE_CODE = type1
        AND a.TOP_NODE_FLAG = 'Y'
        AND a.fin_category_id = b.CHILD_FIN_CAT_ID;


  -- ------------------------------------------------------
  --     CASE statement stes category types based on report
  --     Example: Expense related reports only need 'OE' etc.
  -- ------------------------------------------------------
BEGIN

    IF (g_fin_id = -999 or g_fin_id IS NULL) THEN
       FOR a IN get_top_nodes (g_fin_type)
       LOOP
         IF (get_top_nodes%ROWCOUNT = 1) THEN
            l_category_id := a.fin_category_id;
            l_first := FALSE;
         ELSE
            l_category_id := l_category_id ||','||a.fin_category_id;
         END IF;
       END LOOP;
    END IF;

  -- ------------------------------------------------------
  --      If no top nodes are defined for the specified fin type/s,
  --     report should not error out. In this case,
  --     we use a category id that does not exist i.e. -999
    -- ------------------------------------------------------

   IF (l_category_id IS NULL) THEN
       l_category_id := '-999';
   END IF;

  l_fin_id := g_fin_id;
  get_fin_item(l_fin_id, l_parent_fin_id);

  g_non_ag_cat_from_clause := ', fii_fin_item_hierarchies fin';

  IF (g_fin_id = -999 OR g_fin_id IS NULL) THEN
         g_non_ag_cat_join := ' AND fin.parent_fin_cat_id  in
                        ('||l_category_id||')
				AND fin.child_fin_cat_id = f.fin_category_id';
      ELSE
         g_non_ag_cat_join := ' AND fin.parent_fin_cat_id = &FINANCIAL ITEM+GL_FII_FIN_ITEM
			    AND fin.child_fin_cat_id = f.fin_category_id';
      END IF;

END get_non_ag_cat_pmv_sql;

PROCEDURE Bind_Variable (p_sqlstmt IN Varchar2,
                         p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         p_sql_output OUT NOCOPY Varchar2,
                         p_bind_output_table OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

l_bind_rec BIS_QUERY_ATTRIBUTES;

BEGIN

       p_bind_output_table := BIS_QUERY_ATTRIBUTES_TBL();
       l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
       p_sql_output := p_sqlstmt;

    fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);

    IF (g_viewby_type IS NOT NULL) THEN

        p_bind_output_table.EXTEND;
        l_bind_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
            l_bind_rec.attribute_value := g_viewby_type;
            l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
        p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
    END IF;

-- RYLIU2, let's clean out any binds not really used
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PERIOD_TYPE';
       l_bind_rec.attribute_value := to_char(g_period_type);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':WHERE_PERIOD_TYPE';
       l_bind_rec.attribute_value := to_char(g_where_period_type);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ACT_WHERE_PERIOD_TYPE';
       l_bind_rec.attribute_value := to_char(g_act_where_period_type);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
        p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ENT_PERIOD_TYPE';
       l_bind_rec.attribute_value := to_char(g_ent_period_type);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ACTUAL_PERIOD_TYPE';
       l_bind_rec.attribute_value := to_char(g_actual_period_type);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':BUDGET_PERIOD_TYPE';
       l_bind_rec.attribute_value := to_char(g_budget_period_type);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FORECAST_PERIOD_TYPE';
       l_bind_rec.attribute_value := to_char(g_forecast_period_type);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':GLOBAL_CURR_VIEW';
       l_bind_rec.attribute_value := to_char(g_global_curr_view);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':VIEW_BY';
       l_bind_rec.attribute_value := to_char(g_view_by);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':LOB_ID';
       l_bind_rec.attribute_value := to_char(g_lob_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       IF (g_ccc_id = -999) THEN
	       p_bind_output_table.EXTEND;
	       l_bind_rec.attribute_name := ':CCC_ID';
	       l_bind_rec.attribute_value := 'All';
	       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
	       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       ELSE
	       p_bind_output_table.EXTEND;
	       l_bind_rec.attribute_name := ':CCC_ID';
	       l_bind_rec.attribute_value := to_char(g_ccc_id);
	       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
	       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       END IF;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PREVIOUS_ASOF_DATE';
       l_bind_rec.attribute_value := to_char(g_previous_asof_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ASOF_DATE';
       l_bind_rec.attribute_value := to_char(g_as_of_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':MGR_ID';
       l_bind_rec.attribute_value := to_char(g_mgr_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':MGR_MGR_ID';
       l_bind_rec.attribute_value := to_char(g_mgr_mgr_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIN_ID';
       l_bind_rec.attribute_value := to_char(g_fin_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PARENT_FIN_ID';
       l_bind_rec.attribute_value := to_char(g_parent_fin_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PY_SPER_END';
       l_bind_rec.attribute_value := to_char(g_py_sper_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_EFFECTIVE_SEQ';
       l_bind_rec.attribute_value := to_char(g_curr_per_sequence);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':P_PERIOD_END';
       l_bind_rec.attribute_value := to_char(g_p_period_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':P_P_PERIOD_END';
       l_bind_rec.attribute_value := to_char(g_p_p_period_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURRENCY';
       l_bind_rec.attribute_value := to_char(g_currency);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':GID';
       l_bind_rec.attribute_value := to_char(g_gid);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':MONTH_ID';
       l_bind_rec.attribute_value := to_char(g_month_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CY_PERIOD_END';
       l_bind_rec.attribute_value := to_char(g_cy_period_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ENT_PYR_START';
       l_bind_rec.attribute_value := to_char(g_ent_pyr_start, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ENT_PYR_END';
       l_bind_rec.attribute_value := to_char(g_ent_pyr_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ENT_CYR_START';
       l_bind_rec.attribute_value := to_char(g_ent_cyr_start, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PY_SAME_DAY';
       l_bind_rec.attribute_value := to_char(g_py_sday, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIVE_YR_BACK';
       l_bind_rec.attribute_value := to_char(g_five_yr_back, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':RPT_BEGIN_DATE';
       l_bind_rec.attribute_value := to_char(g_rpt_begin_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':BEGIN_DATE';
       l_bind_rec.attribute_value := to_char(g_begin_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ENT_CYR_END';
       l_bind_rec.attribute_value := to_char(g_ent_cyr_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':P_CURR_START';
       l_bind_rec.attribute_value := to_char(g_curr_start, 'DD-MM-YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':P_CURR_END';
       l_bind_rec.attribute_value := to_char(g_curr_end, 'DD-MM-YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':P_PRIOR_START';
       l_bind_rec.attribute_value := to_char(g_prior_start, 'DD-MM-YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':P_PRIOR_END';
       l_bind_rec.attribute_value := to_char(g_prior_end, 'DD-MM-YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':P_TEMP';
       l_bind_rec.attribute_value := to_char(g_temp, 'DD-MM-YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':REV_MSG';
       l_bind_rec.attribute_value := to_char(g_rev_msg);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':EXP_MSG';
       l_bind_rec.attribute_value := to_char(g_exp_msg);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':COG_MSG';
       l_bind_rec.attribute_value := to_char(g_cog_msg);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':DIR_MSG';
       l_bind_rec.attribute_value := to_char(g_dir_msg);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CCC_OWNER';
       l_bind_rec.attribute_value := to_char(g_cc_owner);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':PPY_SAME_DAY';
       l_bind_rec.attribute_value := to_char(g_ppy_sday, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':P_AS_OF';
       l_bind_rec.attribute_value := to_char(g_new_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':P_PREV_AS_OF';
       l_bind_rec.attribute_value := to_char(g_new_date2, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':P_DET_START';
       l_bind_rec.attribute_value := to_char(g_detail_start, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':P_DET_END';
       l_bind_rec.attribute_value := to_char(g_detail_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

	   l_bind_rec.attribute_name := ':P_TOP_SPEND_START';
       l_bind_rec.attribute_value := to_char(g_top_spend_start, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':P_TOP_SPEND_END';
       l_bind_rec.attribute_value := to_char(g_top_spend_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':P_EXP_ASOF';
       l_bind_rec.attribute_value := to_char(g_exp_asof_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':P_EXP_START';
       l_bind_rec.attribute_value := to_char(g_exp_start, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':P_EXP_BEGIN';
       l_bind_rec.attribute_value := to_char(g_exp_begin_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':P_SD_LYR';
       l_bind_rec.attribute_value := to_char(g_sd_lyr, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       --added by vkazhipu for bug fix 5002238

       l_bind_rec.attribute_name := ':L_ID';
       l_bind_rec.attribute_value := to_char(g_l_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;
       p_bind_output_table.EXTEND;

       l_bind_rec.attribute_name := ':DIM_FLAG';
       l_bind_rec.attribute_value := to_char(g_dim_flag);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIN_TYPE';
       l_bind_rec.attribute_value := to_char(g_fin_type);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':BITMASK';
       l_bind_rec.attribute_value := to_char(g_bitmask);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

	--added by hpoddar for bug fix 4969910

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':START_ID';
       l_bind_rec.attribute_value := to_char(g_start_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':END_ID';
       l_bind_rec.attribute_value := to_char(g_end_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':SLICE_TYPE_FLAG';
       l_bind_rec.attribute_value := to_char(g_slice_type_flag);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PREV_MGR_ID';
       l_bind_rec.attribute_value := to_char(g_prev_mgr_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':EMP_ID';
       l_bind_rec.attribute_value := to_char(g_emp_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       --added by hpoddar for bug fix 5002661

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':TOTAL_HC';
       l_bind_rec.attribute_value := to_char(g_total_hc);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_START_PERIOD_ID';
       l_bind_rec.attribute_value := to_char(g_curr_start_period_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_END_PERIOD_ID';
       l_bind_rec.attribute_value := to_char(g_curr_end_period_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       --added by hpoddar for bug fix 5002564

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_START_DAY_ID';
       l_bind_rec.attribute_value := to_char(g_curr_start_day_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_END_DAY_ID';
       l_bind_rec.attribute_value := to_char(g_curr_end_day_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PRIOR_START_DAY_ID';
       l_bind_rec.attribute_value := to_char(g_prior_start_day_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PRIOR_END_DAY_ID';
       l_bind_rec.attribute_value := to_char(g_prior_end_day_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

END bind_variable;

PROCEDURE get_supervisor (l_mgr_mgr_id OUT  NOCOPY NUMBER) IS

  l_mgr_mgr_level         NUMBER;
  l_mgr_level             NUMBER;

BEGIN

--  ----------------------------------------------------------
--  We do not need to SELECT mgr_level. We only need to
--  calculate it because the top node -999 is not defined
--  in the mgr hierarchies table.
--  Thus we get incorrect l_mgr_mgr_id for the
--  manager who is already top node.
--  ----------------------------------------------------------

   SELECT mgr_level INTO l_mgr_level
   FROM fii_cc_mgr_hierarchies
   WHERE EMP_ID = g_mgr_id
   AND DIRECT_ID = g_mgr_id
   AND MGR_ID = g_mgr_id;

    IF (l_mgr_level <> 1) THEN
        SELECT distinct MGR_ID INTO l_mgr_mgr_id
        FROM fii_cc_mgr_hierarchies
        WHERE DIRECT_ID = g_mgr_id
        AND EMP_ID = g_mgr_id
        AND (DIRECT_LEVEL = 1 OR MGR_ID <> DIRECT_ID);
    ELSE l_mgr_mgr_id := '-999';
    END IF;

    SELECT IS_LEAF_FLAG INTO g_mgr_is_leaf
    FROM fii_cc_mgr_hierarchies
    WHERE  EMP_ID = g_mgr_id
    AND MGR_ID = g_mgr_id;



--  RYLIU2, error handing when no rows retrieved
--  mbedekar Can we discuss how we want to do this?

END get_supervisor;

PROCEDURE get_lob IS

BEGIN

     IF (g_lob_is_top_node = 'Y') THEN
	g_lob_is_leaf := 'N';
     ELSE
     SELECT IS_LEAF_FLAG INTO g_lob_is_leaf
     FROM   fii_lob_hierarchies
     WHERE  CHILD_LOB_ID = g_lob_id
            AND PARENT_LOB_ID = g_lob_id;
     END IF;


END get_lob;

FUNCTION ccc_within_mgr_lob( g_ccc_id IN NUMBER,
                             g_lob_id IN VARCHAR2,
                             g_mgr_id IN NUMBER) return VARCHAR2  IS

 is_within_mgr       NUMBER;
 is_within_lob       NUMBER;
BEGIN
  is_within_mgr := 1;
  -- After implementing a dependent LOV for the cost center
  -- the cost center selected is always one owned by the
  -- manager selected or someone reporting to him.
  -- Therefore we set the variable to 1.

  IF g_lob_is_top_node = 'Y' THEN
	is_within_lob := 1;
  ELSE
	BEGIN

		SELECT  1
		INTO    is_within_lob
		FROM	fii_com_cc_mappings mapp,
			fii_lob_hierarchies x
		WHERE   mapp.COMPANY_COST_CENTER_ORG_ID = g_ccc_id
			AND x.parent_lob_id = g_lob_id
			AND x.child_lob_id = mapp.parent_lob_id
			AND rownum = 1;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			is_within_lob := 0;
	END;

  END IF;

  IF (is_within_mgr > 0 AND is_within_lob > 0) THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

END ccc_within_mgr_lob;

PROCEDURE get_fin_item ( l_fin_id IN NUMBER,
                         l_p_fin_id OUT NOCOPY NUMBER) IS

BEGIN

  IF (l_fin_id <> -999) THEN
    SELECT PARENT_FIN_CAT_ID INTO l_p_fin_id
    FROM fii_fin_item_hierarchies
    WHERE NEXT_LEVEL_FIN_CAT_ID = l_fin_id
    AND CHILD_FIN_CAT_ID = l_fin_id
    AND (NEXT_LEVEL = 1 or PARENT_FIN_CAT_ID <> NEXT_LEVEL_FIN_CAT_ID);
  ELSE l_p_fin_id := -999;
  END IF;

  IF (l_fin_id <> -999) THEN
	SELECT NEXT_LEVEL_IS_LEAF INTO g_fincat_is_leaf
	FROM fii_fin_item_hierarchies
	WHERE  CHILD_FIN_CAT_ID = l_fin_id
	AND NEXT_LEVEL_FIN_CAT_ID = l_fin_id
	AND PARENT_FIN_CAT_ID = l_fin_id;
  ELSE g_fincat_is_leaf := 'N';
END IF;

END get_fin_item;

END fii_gl_util_pkg;


/
