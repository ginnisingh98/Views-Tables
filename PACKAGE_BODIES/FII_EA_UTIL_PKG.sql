--------------------------------------------------------
--  DDL for Package Body FII_EA_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_EA_UTIL_PKG" AS
/* $Header: FIIEAUTILB.pls 120.12 2006/07/27 09:27:39 wywong noship $ */

g_min_start_date date;

TYPE viewby_dimension is RECORD (par_id NUMBER, id NUMBER, sort_order NUMBER, description VARCHAR2(100));
TYPE PL1 is table of viewby_dimension    index by binary_integer;
TYPE plsqltable IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE viewby IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
company_table PL1; -- table of records for company dimension
cc_table PL1; -- table of records for CC
fin_cat_table PL1; -- table of records for category
fud1_table PL1; -- table of records for fud1
fud2_table PL1; -- table of records for fud2
par_comp_id_aggrt_plsql plsqltable;
-- par_comp_id_aggrt_plsql depicts the plsql table for storing parent company id while inserting in fii_pmv_aggrt_gt
--table. similar explanation for other plsql variables

/* various plsql table's declaration */

comp_id_aggrt_plsql plsqltable;
par_cc_id_aggrt_plsql plsqltable;
cc_id_aggrt_plsql plsqltable;
par_fin_cat_id_aggrt_plsql plsqltable;
par_fud1_id_aggrt_plsql plsqltable;
fin_cat_id_aggrt_plsql plsqltable;
fud1_id_aggrt_plsql plsqltable;
fud2_id_aggrt_plsql plsqltable;
sort_order_aggrt_plsql plsqltable;
sort_order_nonaggrt_plsql plsqltable;
comp_id_nonaggrt_plsql plsqltable;
cc_id_nonaggrt_plsql plsqltable;
fin_cat_id_nonaggrt_plsql plsqltable;
fud1_id_nonaggrt_plsql plsqltable;
fud2_id_nonaggrt_plsql plsqltable;
aggrt_viewbydescription  viewby;
nonaggrt_viewbydescription  viewby;

l_cat_join VARCHAR2(10000);
l_fud1_join VARCHAR2(10000);
l_fud2_join VARCHAR2(10000);
l_aggrt_cat_join VARCHAR2(10000); -- gives category join while hitting aggrt MVs
l_nonaggrt_cat_join VARCHAR2(10000); -- -- gives category join while hitting non-aggrt MVs

l_aggrt_fud1_join VARCHAR2(10000); -- gives fud1 join while hitting aggrt MVs
l_nonaggrt_fud1_join VARCHAR2(10000); -- gives fud1 join while hitting non-aggrt MVs
-- -------------------------------------------------
-- Re-set the globals variables to NULL
-- -------------------------------------------------
PROCEDURE reset_globals IS
BEGIN

g_as_of_date            := NULL;
g_page_period_type      := NULL;
g_currency              := NULL;
g_view_by               := NULL;
g_time_comp             := NULL;
g_previous_asof_date	:= NULL;
g_company_id            := 'All';
g_parent_company_id     := NULL;
g_top_company_id        := NULL;
g_cost_center_id        := 'All';
g_parent_cost_center_id := NULL;
g_top_cost_center_id	:= NULL;
g_fin_category_id       := 'All';
g_parent_fin_category_id := NULL;
g_fin_cat_type          := 'OE';
g_ledger_id             := 'All';
g_fud1_id               := 'All';
g_parent_fud1_id        := NULL;
g_top_fud1_id           := NULL;
g_fud2_id               := 'All';
g_parent_fud2_id        := NULL;
g_top_fud2_id           := NULL;
g_curr_view             := NULL;
g_actual_bitand         := NULL;
g_budget_bitand         := NULL;
g_hist_actual_bitand    := NULL; -- used to display historical data in summary reports
g_forecast_bitand	:= NULL;
g_previous_one_end_date	:= NULL;
g_previous_two_end_date	:= NULL;
g_previous_three_end_date := NULL;
g_je_source_group       := NULL;
g_unassigned_id         := NULL;
g_coaid                 := NULL;
g_curr_per_start        := NULL;
g_curr_per_end          := NULL;
g_prior_per_start       := NULL;
g_prior_per_end         := NULL;
g_curr_month_start      := NULL;
g_hist_budget_bitand    := NULL;
g_amount_type           := NULL;
g_boundary              := NULL;
g_boundary_end          := NULL;
g_prior_boundary_end    := NULL;
g_amount_type_bitand    := NULL;
g_snapshot              := 'N';
g_maj_cat_id            := 'All';
g_fin_cat_top_node_count :=0;	-- g_fin_cat_top_node_count gives the # of Expenses/Revenue top nodes for financial category dimension
g_category_id 		:=0;	-- similar to g_fin_catgory_id.. when category parameter chosen is 'All' and we have only one top node,
				-- it will have top node id..for multiple top nodes scenario, it will be 0..else
				-- it will have the specific fin category's id..
g_udd1_id 		:=0;    -- similar to g_fud1_id.. when fud1 parameter chosen is 'All', it will have top node id else
				-- it will have the specific fud1 parameter's id..
g_dir_msg		:= NULL;
g_min_cat_id            := 'All';
g_region_code		:= NULL;
g_sd_prior		:= NULL;
g_sd_prior_prior	:= NULL;

/* 4439400 Budgets */
g_bud_as_of_date         := NULL;
g_previous_bud_asof_date := NULL;
g_id			:= -9999;
g_time_id		:= NULL; -- global var for storing time_id of g_as_of_date, based on period type
g_aggrt_gt_record_count :=0;
g_non_aggrt_gt_record_count :=0;
g_if_trend_sum_mv := 'N';
g_fin_aggregate_flag := 'N';
g_ud1_aggregate_flag := 'N';
g_company_count :=0;
g_cc_count :=0;
g_company_is_leaf := 'N';
g_cost_center_is_leaf := 'N';
g_fin_cat_is_leaf := 'N';
g_ud1_is_leaf := 'N';
g_ud2_is_leaf := 'N';
g_display_sequence := NULL;

-- Added for P&L Analysis
g_five_yr_back         := NULL;
g_py_sday              := NULL;
g_exp_asof_date        := NULL;
g_cy_period_end        := NULL;
g_ent_pyr_end          := NULL;
g_actual_period_type   := NULL;
g_budget_period_type   := NULL;
g_forecast_period_type := NULL;
g_where_period_type    := NULL;
g_ent_cyr_end          := NULL;
g_curr_per_sequence    := NULL;
g_period_type          := NULL;
g_exp_start            := NULL;
g_exp_begin_date       := NULL;
g_fin_type             := NULL;

END reset_globals;

PROCEDURE get_parameters (
  p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL) IS

  l_unassigned_vset_id   NUMBER;
  l_retcode              NUMBER;

  l_sys_month_start DATE;
  l_max_end_date DATE;
  l_period_count NUMBER;

  BUDGET_TIME_UNIT       VARCHAR2(1);
  FORECAST_TIME_UNIT     VARCHAR2(1);

BEGIN

  -- -------------------------------------------------
  -- Parse thru the parameter table and set globals
  -- -------------------------------------------------
  IF (p_page_parameter_tbl.count > 0) THEN
    FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

      IF p_page_parameter_tbl(i).parameter_name = 'AS_OF_DATE' THEN
        g_as_of_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD/MM/YYYY');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
        g_page_period_type := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' THEN
        g_currency := substr(p_page_parameter_tbl(i).parameter_id,2,11);
      ELSIF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
        g_view_by :=  p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'BIS_REGION_CODE' THEN
        g_region_code :=  p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME_COMPARISON_TYPE' THEN
        g_time_comp := p_page_parameter_tbl(i).parameter_value;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'BIS_PREVIOUS_ASOF_DATE' THEN
        g_previous_asof_date := to_date(p_page_parameter_tbl(i).parameter_value,'DD/MM/YYYY');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_COMPANIES+FII_COMPANIES' THEN
        g_company_id := nvl(replace(p_page_parameter_tbl(i).parameter_id,'''', null),'All');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+HRI_CL_ORGCC'  THEN
        g_cost_center_id := nvl(replace(p_page_parameter_tbl(i).parameter_id, '''', null),'All');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
	g_fin_category_id := nvl(replace(p_page_parameter_tbl(i).parameter_id, '''', null), 'All');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_LEDGER+FII_LEDGER' THEN
        g_ledger_id := nvl(replace(p_page_parameter_tbl(i).parameter_id, '''', null),'All');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN
        g_fud1_id := nvl(replace(p_page_parameter_tbl(i).parameter_id, '''', null),'All');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_USER_DEFINED+FII_USER_DEFINED_2' THEN
        g_fud2_id := nvl(replace(p_page_parameter_tbl(i).parameter_id, '''', null),'All');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_EA_JE_SOURCE_GROUP' THEN
        g_je_source_group := p_page_parameter_tbl(i).parameter_id;
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_ASSET_CATEGORIES+FII_ASSET_CAT_MAJOR' THEN
        g_maj_cat_id := nvl(replace(p_page_parameter_tbl(i).parameter_id,'''', null),'All');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'FII_ASSET_CATEGORIES+FII_ASSET_CAT_MINOR' THEN
        g_min_cat_id := nvl(replace(p_page_parameter_tbl(i).parameter_id,'''', null),'All');
      ELSIF p_page_parameter_tbl(i).parameter_name = 'BIS_ICX_SESSION_ID' THEN
        g_session_id := NVL(p_page_parameter_tbl(i).parameter_value,0);
      END IF;
    END LOOP;
  END IF;

  -- Following check is required for COGS Rolling Trend report (P&L Analysis)

     IF g_page_period_type IS NULL THEN
        g_page_period_type := 'FII_TIME_ENT_PERIOD';
     END IF;
  -- -----------------------------------------------------------
  -- Added for P&L Analysis
  -- Get budget/forecast levels FROM profile options
  -- Default assume budget & forecast are loaded at period level
  -- -----------------------------------------------------------
  BUDGET_TIME_UNIT   := NVL(FND_PROFILE.Value( 'FII_BUDGET_TIME_UNIT'),'P');
  FORECAST_TIME_UNIT := NVL(FND_PROFILE.Value( 'FII_FORECAST_TIME_UNIT'),'P');

  SELECT nvl(min(start_date), trunc(sysdate)) INTO g_min_start_date
  FROM	 fii_time_ent_period;

  SELECT nvl(max(end_date), trunc(sysdate)), count(1) INTO l_max_end_date, l_period_count
  FROM fii_time_ent_period;

  SELECT NVL(fii_time_api.ent_cper_START(trunc(sysdate)), l_max_end_date) INTO l_sys_month_start FROM DUAL;

/* 4439400 : Added g_bud_as_of_date for Public Sector Budgets */
  IF g_as_of_date > trunc(sysdate) THEN
        SELECT NVL(fii_time_api.ent_cper_END(g_as_of_date),l_max_end_date) INTO g_as_of_date FROM dual;
	g_bud_as_of_date := g_as_of_date;
  ELSIF g_as_of_date < trunc(sysdate) AND g_as_of_date >= l_sys_month_start THEN
        SELECT NVL(fii_time_api.ent_pper_END(g_as_of_date),l_max_end_date) INTO g_as_of_date FROM dual;
	g_bud_as_of_date := g_as_of_date;
  ELSIF g_as_of_date = trunc(sysdate) THEN
        g_as_of_date := nvl(to_date(FND_PROFILE.value('FII_TEST_SYSDATE'), 'DD/MM/YYYY'),trunc(sysdate));
        SELECT NVL(fii_time_api.ent_cper_END(g_as_of_date),l_max_end_date) INTO g_bud_as_of_date FROM dual;
        g_snapshot := 'Y';
        IF l_period_count = 0 THEN --time dimension is null, so join to fii_time_structures which is null to report no data found.
           g_snapshot := 'N';
        END IF;
  ELSE
	SELECT NVL(fii_time_api.ent_cper_END(g_as_of_date),l_max_end_date) INTO g_as_of_date FROM dual;
	g_bud_as_of_date := g_as_of_date;
  END IF;

  SELECT nvl(min(start_date), g_min_start_date) INTO g_curr_month_start
  FROM	 fii_time_ent_period
  WHERE  g_as_of_date between start_date and END_date;


  IF g_previous_asof_date IS NULL THEN
     g_previous_asof_date := g_min_start_date;
  END IF;

-- Added for P&L Analysis
  SELECT NVL( fii_time_api.sd_lyswk(g_as_of_date),g_min_start_date),
         NVL(fii_time_api.ent_pyr_end(g_as_of_date),g_min_start_date),
         NVL(fii_time_api.ent_cyr_end(g_as_of_date),g_min_start_date)
  INTO g_py_sday,
       g_ent_pyr_end,
       g_ent_cyr_end
  FROM dual;

  CASE g_page_period_type
    WHEN 'FII_TIME_WEEK'       THEN g_actual_period_type := 11;
    WHEN 'FII_TIME_ENT_PERIOD' THEN g_actual_period_type := 23;
    WHEN 'FII_TIME_ENT_QTR'    THEN g_actual_period_type := 55;
    WHEN 'FII_TIME_ENT_YEAR'   THEN g_actual_period_type := 119;
  END CASE;

  CASE g_page_period_type
    WHEN 'FII_TIME_WEEK'       THEN g_period_type := 16;
    WHEN 'FII_TIME_ENT_PERIOD' THEN g_period_type := 32;
    WHEN 'FII_TIME_ENT_QTR'    THEN g_period_type := 64;
    WHEN 'FII_TIME_ENT_YEAR'   THEN g_period_type := 128;
  END CASE;

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

CASE g_page_period_type
    WHEN 'FII_TIME_WEEK'       THEN g_where_period_type := 11;
    WHEN 'FII_TIME_ENT_PERIOD' THEN g_where_period_type := 279; --1+2+4+16+256
    WHEN 'FII_TIME_ENT_QTR'    THEN g_where_period_type := 823; --1+2+4+16+32+256+512
    WHEN 'FII_TIME_ENT_YEAR'   THEN g_where_period_type := 1015; --1+2+4+16+32+64+128+256+512
END CASE;

  -- -------------------------------------------------
  -- If user views in primary global, use 1st view which
  -- SELECTs the primary amount.  For secondary global
  -- currency, use 2nd view which SELECTs secondary amount
  -- Default assumed to be viewing data in primary global
  -- -------------------------------------------------
  IF g_currency = 'FII_GLOBAL1' THEN
      g_curr_view := '_p_v';
  ELSIF g_currency = 'FII_GLOBAL2' THEN
      g_curr_view := '_s_v';
  ELSE
      g_curr_view := '_p_v';
  END IF;

  SELECT NVL(fii_time_api.ent_sd_lysper_end(g_as_of_date), g_min_start_date) INTO g_sd_prior FROM DUAL;
  SELECT NVL(fii_time_api.ent_sd_lysper_end(fii_time_api.ent_sd_lysper_end(g_as_of_date)), g_min_start_date) INTO g_sd_prior_prior FROM DUAL;

/* Bug 4439400: Added g_previous_bud_asof_date for public sector budget */
  CASE g_page_period_type
    WHEN 'FII_TIME_ENT_PERIOD' THEN
      g_actual_bitand := 64;
      g_hist_actual_bitand := 64;
      g_budget_bitand := 4;
      g_hist_budget_bitand := 4;
      g_forecast_bitand := 4;
      IF g_time_comp = 'SEQUENTIAL' THEN
		SELECT NVL(fii_time_api.ent_sd_pper_end(g_as_of_date),g_min_start_date) INTO g_previous_asof_date FROM dual;
		SELECT NVL(fii_time_api.ent_sd_pper_end(g_bud_as_of_date),g_min_start_date) INTO g_previous_bud_asof_date FROM dual;
      ELSE
		SELECT NVL(fii_time_api.ent_sd_lysper_END(g_as_of_date),g_min_start_date) INTO g_previous_asof_date FROM dual;
		SELECT NVL(fii_time_api.ent_sd_lysper_END(g_bud_as_of_date),g_min_start_date) INTO g_previous_bud_asof_date FROM dual;
      END IF;
      SELECT NVL(fii_time_api.ent_cper_start(g_as_of_date), g_min_start_date) INTO g_curr_per_start FROM DUAL;
      SELECT NVL(fii_time_api.ent_cper_end(g_as_of_date), g_min_start_date) INTO g_curr_per_end FROM DUAL;
      SELECT NVL(fii_time_api.ent_cper_start(g_previous_asof_date), g_min_start_date) INTO g_prior_per_start FROM DUAL;
      SELECT NVL(fii_time_api.ent_cper_end(g_previous_asof_date), g_min_start_date) INTO g_prior_per_end FROM DUAL;

	SELECT	ent_period_id INTO g_time_id
	FROM	fii_time_ent_period per
	WHERE	g_as_of_date BETWEEN start_date AND end_date;

	-- Added for P&L Analysis
      SELECT NVL(fii_time_api.ent_pper_end(g_as_of_date),g_min_start_date),
             NVL(fii_time_api.ent_sd_lysper_end(g_as_of_date),g_min_start_date)
      INTO g_cy_period_end,
           g_exp_asof_date
      FROM DUAL;

      SELECT	DISTINCT a.sequence INTO g_curr_per_sequence
      FROM	fii_time_ent_period a
      WHERE	g_as_of_date BETWEEN a.START_DATE AND a.END_DATE;

      SELECT NVL(fii_time_api.ent_sd_lysper_end(g_exp_asof_date),g_min_start_date)
      INTO   g_exp_start
      FROM dual;

      g_exp_begin_date := g_exp_asof_date;

    WHEN 'FII_TIME_ENT_QTR' THEN
      g_actual_bitand := 128;
      g_hist_actual_bitand := 64;
      g_budget_bitand := 8;
      g_hist_budget_bitand := 4;
      g_forecast_bitand := 8;
	IF g_time_comp = 'SEQUENTIAL' THEN
		SELECT NVL(fii_time_api.ent_sd_pqtr_end(g_as_of_date),g_min_start_date) INTO g_previous_asof_date FROM dual;
		SELECT NVL(fii_time_api.ent_sd_pqtr_end(g_bud_as_of_date),g_min_start_date) INTO g_previous_bud_asof_date FROM dual;
	ELSE
		SELECT NVL(fii_time_api.ent_sd_lysqtr_end(g_as_of_date),g_min_start_date) INTO g_previous_asof_date FROM dual;
		SELECT NVL(fii_time_api.ent_sd_lysqtr_end(g_bud_as_of_date),g_min_start_date) INTO g_previous_bud_asof_date FROM dual;
        END IF;
      SELECT NVL(fii_time_api.ent_cqtr_start(g_as_of_date), g_min_start_date) INTO g_curr_per_start FROM DUAL;
      SELECT NVL(fii_time_api.ent_cqtr_end(g_as_of_date), g_min_start_date) INTO g_curr_per_end FROM DUAL;
      SELECT NVL(fii_time_api.ent_cqtr_start(g_previous_asof_date), g_min_start_date) INTO g_prior_per_start FROM DUAL;
      SELECT NVL(fii_time_api.ent_cqtr_end(g_previous_asof_date), g_min_start_date) INTO g_prior_per_end FROM DUAL;

	SELECT	ent_qtr_id INTO g_time_id
	FROM	fii_time_ent_period per
	WHERE	g_as_of_date BETWEEN start_date AND end_date;

     -- Added for P&L Analysis
      SELECT NVL( fii_time_api.ent_pqtr_end(g_as_of_date),g_min_start_date) INTO g_cy_period_end FROM dual;

      IF (g_time_comp = 'SEQUENTIAL') THEN
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

       WHEN 'FII_TIME_ENT_YEAR' THEN
      g_actual_bitand := 256;
      g_hist_actual_bitand := 128;
      g_budget_bitand := 16;
      g_hist_budget_bitand := 8;
      g_forecast_bitand := 16;
      SELECT NVL(fii_time_api.ent_sd_lyr_end(g_as_of_date),g_min_start_date) INTO g_previous_asof_date FROM dual;
      SELECT NVL(fii_time_api.ent_sd_lyr_end(g_bud_as_of_date),g_min_start_date) INTO g_previous_bud_asof_date FROM dual;
      SELECT NVL(fii_time_api.ent_cyr_start(g_as_of_date), g_min_start_date) INTO g_curr_per_start FROM DUAL;
      SELECT NVL(fii_time_api.ent_cyr_end(g_as_of_date), g_min_start_date) INTO g_curr_per_end FROM DUAL;
      SELECT NVL(fii_time_api.ent_cyr_start(g_previous_asof_date), g_min_start_date) INTO g_prior_per_start FROM DUAL;
      SELECT NVL(fii_time_api.ent_cyr_end(g_previous_asof_date), g_min_start_date) INTO g_prior_per_end FROM DUAL;

	SELECT	ent_year_id INTO g_time_id
	FROM	fii_time_ent_period per
	WHERE	g_as_of_date BETWEEN start_date AND end_date;

	SELECT	NVL(MAX(sequence),0)
	INTO	g_display_sequence
	FROM	fii_time_ent_period
	WHERE	start_date >= g_curr_per_start
		AND end_date <= g_as_of_date;

      -- Added for P&L Analysis
       g_cy_period_end := NULL;
       g_curr_per_sequence := NULL;
       g_exp_asof_date := NULL;
       g_exp_start     := NULL;

    ELSE  g_actual_bitand := 64;
  END CASE;

  FII_GL_EXTRACTION_UTIL.get_unassigned_id(g_unassigned_id, l_unassigned_vset_id, l_retcode);

  g_amount_type := NVL(FND_PROFILE.value('FII_PSI_AMOUNT_TYPE'), 'YTD');
  g_boundary := NVL(FND_PROFILE.value('FII_PSI_BOUNDARY'), 'Y');

  IF g_boundary = 'P' THEN
     g_boundary_end := NVL(fii_time_api.ent_cper_end(g_as_of_date), g_min_start_date);
     g_prior_boundary_end := NVL(fii_time_api.ent_cper_end(g_previous_asof_date), g_min_start_date);
  ELSIF g_boundary = 'Q' THEN
     g_boundary_end := NVL(fii_time_api.ent_cqtr_end(g_as_of_date), g_min_start_date);
     g_prior_boundary_end := NVL(fii_time_api.ent_cqtr_end(g_previous_asof_date), g_min_start_date);
  ELSIF g_boundary ='Y' THEN
     g_boundary_end := NVL(fii_time_api.ent_cyr_end(g_as_of_date), g_min_start_date);
     g_prior_boundary_end := NVL(fii_time_api.ent_cyr_end(g_previous_asof_date), g_min_start_date);
  END IF;

  IF g_amount_type ='PTD' THEN
     g_amount_type_bitand := 64;
  ELSIF g_amount_type ='QTD' THEN
     g_amount_type_bitand := 128;
  ELSIF g_amount_type ='YTD' THEN
     g_amount_type_bitand := 256;
  END IF;

g_dir_msg := FND_MESSAGE.get_string('FII', 'FII_GL_DIR');

END get_parameters;


PROCEDURE get_rolling_period
IS

BEGIN


  CASE g_page_period_type

    WHEN 'FII_TIME_ENT_YEAR' THEN
	SELECT NVL(fii_time_api.ent_pqtr_END(g_as_of_date),g_min_start_date) INTO g_previous_one_END_date FROM dual;
	SELECT NVL(fii_time_api.ent_pqtr_END(g_previous_one_END_date),g_min_start_date) INTO g_previous_two_END_date FROM dual;
	SELECT NVL(fii_time_api.ent_pqtr_END(g_previous_two_END_date),g_min_start_date) INTO g_previous_three_END_date FROM dual;
    WHEN 'FII_TIME_ENT_QTR' THEN
      SELECT NVL(fii_time_api.ent_pper_END(g_as_of_date),g_min_start_date) INTO g_previous_one_END_date FROM dual;
	SELECT NVL(fii_time_api.ent_pper_END(g_previous_one_END_date),g_min_start_date) INTO g_previous_two_END_date FROM dual;
	SELECT NVL(fii_time_api.ent_pper_END(g_previous_two_END_date),g_min_start_date) INTO g_previous_three_END_date FROM dual;
    WHEN 'FII_TIME_ENT_PERIOD' THEN
      g_previous_one_END_date := NULL;
      g_previous_two_END_date := NULL;
      g_previous_three_END_date :=NULL;
  END CASE;

END get_rolling_period;

PROCEDURE get_viewby_id(p_aggrt_viewby_id OUT NOCOPY VARCHAR2, p_snap_aggrt_viewby_id OUT NOCOPY VARCHAR2, p_nonaggrt_viewby_id OUT NOCOPY VARCHAR2) IS

-- fix for bug 4127077. The following cursor checks for the presence of any top node which is also a leaf node

CURSOR get_leaf_top_nodes(g_fin_cat_type VARCHAR2) IS
        SELECT a.fin_category_id
        FROM fii_fin_cat_type_assgns a, fii_fin_item_leaf_hiers b
        WHERE a.FIN_CAT_TYPE_CODE = g_fin_cat_type
        AND a.TOP_NODE_FLAG = 'Y'
        and a.fin_category_id = b.CHILD_FIN_CAT_ID
        and b.is_leaf_flag = 'Y';
BEGIN

FOR a IN get_leaf_top_nodes (g_fin_cat_type)
LOOP
		g_top_node_is_leaf := 'Y';
END LOOP;

CASE g_view_by
  WHEN 'FII_COMPANIES+FII_COMPANIES' THEN
    	p_aggrt_viewby_id := 'f.company_id';
    	p_snap_aggrt_viewby_id := 'f.company_id';
	p_nonaggrt_viewby_id := 'co_hier.parent_company_id';
  WHEN 'ORGANIZATION+HRI_CL_ORGCC' THEN
	p_aggrt_viewby_id := 'f.cost_center_id';
	p_snap_aggrt_viewby_id := 'f.cost_center_id';
	p_nonaggrt_viewby_id := 'cc_hier.parent_cc_id';
  WHEN 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
	IF g_fin_category_id = 'All' THEN
		SELECT count(*) INTO g_fin_cat_top_node_count
		FROM   fii_fin_cat_type_assgns a
		WHERE  a.FIN_CAT_TYPE_CODE = g_fin_cat_type
		       AND a.TOP_NODE_FLAG = 'Y';

		IF g_top_node_is_leaf = 'Y' THEN
			p_aggrt_viewby_id := 'f.fin_category_id';
			p_snap_aggrt_viewby_id := 'f.fin_category_id';
		ELSIF g_fin_cat_top_node_count = 1 THEN
			p_aggrt_viewby_id := 'f.fin_category_id';
			p_snap_aggrt_viewby_id := 'f.fin_category_id';
		ELSE
			p_aggrt_viewby_id := 'f.parent_fin_category_id';
			p_snap_aggrt_viewby_id := 'f.parent_fin_category_id';
		END IF;
	ELSE
		p_aggrt_viewby_id := 'f.fin_category_id';
		p_snap_aggrt_viewby_id := 'f.fin_category_id';
	END IF;
	p_nonaggrt_viewby_id := 'fin_hier.parent_fin_cat_id';

  WHEN 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN
	p_aggrt_viewby_id := 'f.fud1_id';
	p_snap_aggrt_viewby_id := 'f.fud1_id';
    	p_nonaggrt_viewby_id := 'fud1_hier.parent_value_id';
  WHEN 'FII_USER_DEFINED+FII_USER_DEFINED_2' THEN
	p_aggrt_viewby_id := 'inner_inline_view.fud2_id';
	p_snap_aggrt_viewby_id := 'gt.fud2_id';
	p_nonaggrt_viewby_id := 'fud2_hier.parent_value_id';
  END CASE;

END get_viewby_id;

----------------------------------------------------------

PROCEDURE insert_into_aggrt_gt IS

BEGIN

FOR a IN company_table.FIRST..company_table.LAST LOOP
   FOR b IN cc_table.FIRST..cc_table.LAST LOOP
FOR c IN fin_cat_table.FIRST..fin_cat_table.LAST LOOP
	FOR d IN fud1_table.FIRST..fud1_table.LAST LOOP
	   FOR e IN fud2_table.FIRST..fud2_table.LAST LOOP
                   g_aggrt_gt_record_count := g_aggrt_gt_record_count+1;
    par_comp_id_aggrt_plsql(g_aggrt_gt_record_count)     := company_table(a).par_id;
    comp_id_aggrt_plsql(g_aggrt_gt_record_count)         := company_table(a).id;
    par_cc_id_aggrt_plsql(g_aggrt_gt_record_count)       := cc_table(b).par_id;
    cc_id_aggrt_plsql(g_aggrt_gt_record_count)           := cc_table(b).id;
    par_fin_cat_id_aggrt_plsql(g_aggrt_gt_record_count)  := fin_cat_table(c).par_id;
    fin_cat_id_aggrt_plsql(g_aggrt_gt_record_count)      := fin_cat_table(c).id;
    par_fud1_id_aggrt_plsql(g_aggrt_gt_record_count)     := fud1_table(d).par_id;
    fud1_id_aggrt_plsql(g_aggrt_gt_record_count)         := fud1_table(d).id;
    fud2_id_aggrt_plsql(g_aggrt_gt_record_count)         := fud2_table(e).id;
CASE g_view_by
   WHEN 'FII_COMPANIES+FII_COMPANIES' THEN
           aggrt_viewbydescription(g_aggrt_gt_record_count)      := company_table(a).description;
	   sort_order_aggrt_plsql(g_aggrt_gt_record_count) := company_table(a).sort_order;
   WHEN 'ORGANIZATION+HRI_CL_ORGCC' THEN
           aggrt_viewbydescription(g_aggrt_gt_record_count)      := cc_table(b).description;
	   sort_order_aggrt_plsql(g_aggrt_gt_record_count) := cc_table(b).sort_order;
   WHEN 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
           aggrt_viewbydescription(g_aggrt_gt_record_count)      := fin_cat_table(c).description;
	   sort_order_aggrt_plsql(g_aggrt_gt_record_count) := fin_cat_table(c).sort_order;
   WHEN 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN
           aggrt_viewbydescription(g_aggrt_gt_record_count)      := fud1_table(d).description;
	   sort_order_aggrt_plsql(g_aggrt_gt_record_count) := fud1_table(d).sort_order;
   WHEN 'FII_USER_DEFINED+FII_USER_DEFINED_2' THEN
           aggrt_viewbydescription(g_aggrt_gt_record_count)      :=fud2_table(e).description;
	   sort_order_aggrt_plsql(g_aggrt_gt_record_count) := fud2_table(e).sort_order;
   ELSE
	   aggrt_viewbydescription(g_aggrt_gt_record_count) := NULL;
	   sort_order_aggrt_plsql(g_aggrt_gt_record_count) := NULL;
END CASE;
	   END LOOP;
   END LOOP;
  END LOOP;
       END LOOP;
END LOOP;

END insert_into_aggrt_gt;

PROCEDURE insert_into_non_aggrt_gt IS

BEGIN

FOR a IN company_table.FIRST..company_table.LAST LOOP
   FOR b IN cc_table.FIRST..cc_table.LAST LOOP
     FOR c IN fin_cat_table.FIRST..fin_cat_table.LAST LOOP
	FOR d IN fud1_table.FIRST..fud1_table.LAST LOOP
	   FOR e IN fud2_table.FIRST..fud2_table.LAST LOOP
                   g_non_aggrt_gt_record_count := g_non_aggrt_gt_record_count+1;
    comp_id_nonaggrt_plsql(g_non_aggrt_gt_record_count)     := company_table(a).id;
    cc_id_nonaggrt_plsql(g_non_aggrt_gt_record_count)       := cc_table(b).id;
    fin_cat_id_nonaggrt_plsql(g_non_aggrt_gt_record_count)  := fin_cat_table(c).id;
    fud1_id_nonaggrt_plsql(g_non_aggrt_gt_record_count)     := fud1_table(d).id;
    fud2_id_nonaggrt_plsql(g_non_aggrt_gt_record_count)     := fud2_table(e).id;
CASE g_view_by
   WHEN 'FII_COMPANIES+FII_COMPANIES' THEN
           nonaggrt_viewbydescription(g_non_aggrt_gt_record_count) := company_table(a).description;
	   sort_order_nonaggrt_plsql(g_non_aggrt_gt_record_count) := company_table(a).sort_order;
   WHEN 'ORGANIZATION+HRI_CL_ORGCC' THEN
           nonaggrt_viewbydescription(g_non_aggrt_gt_record_count) := cc_table(b).description;
   	   sort_order_nonaggrt_plsql(g_non_aggrt_gt_record_count) := cc_table(b).sort_order;
   WHEN 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
           nonaggrt_viewbydescription(g_non_aggrt_gt_record_count) := fin_cat_table(c).description;
   	   sort_order_nonaggrt_plsql(g_non_aggrt_gt_record_count) := fin_cat_table(c).sort_order;
   WHEN 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN
           nonaggrt_viewbydescription(g_non_aggrt_gt_record_count) := fud1_table(d).description;
   	   sort_order_nonaggrt_plsql(g_non_aggrt_gt_record_count) := fud1_table(d).sort_order;
   WHEN 'FII_USER_DEFINED+FII_USER_DEFINED_2' THEN
           nonaggrt_viewbydescription(g_non_aggrt_gt_record_count) :=fud2_table(e).description;
   	   sort_order_nonaggrt_plsql(g_non_aggrt_gt_record_count) := fud2_table(e).sort_order;
   ELSE
	   nonaggrt_viewbydescription(g_non_aggrt_gt_record_count) := NULL;
	   sort_order_nonaggrt_plsql(g_non_aggrt_gt_record_count) := NULL;
END CASE;
	   END LOOP;
   END LOOP;
  END LOOP;
       END LOOP;
END LOOP;

END insert_into_non_aggrt_gt;

/* below mentioned procedure forms join for company dimension, when company parameter chosen is All.
It also inserts records into company dimension PL/SQL table */

PROCEDURE form_all_company_join(p_comp_agg_flag IN VARCHAR2, p_cc_agg_flag IN VARCHAR2,p_company_id IN NUMBER) IS

l_company_sql VARCHAR2(10000);
l_company_join VARCHAR2(10000);
l_leaf_flag VARCHAR2(1);
l_comp_agg_flag VARCHAR2(1);


BEGIN

l_comp_agg_flag := p_comp_agg_flag;

		IF g_view_by =  'FII_COMPANIES+FII_COMPANIES' THEN

	     	   IF g_company_count = 1 THEN -- WHEN only 1 record in security
-- table FOR that user, we will check for_viewby_flag ELSE security table's aggregated_flag will be used

			SELECT for_viewby_flag INTO l_comp_agg_flag
			FROM fii_com_pmv_agrt_nodes
			WHERE company_id = p_company_id;

			check_if_leaf(p_company_id);

         	    IF g_company_is_leaf = 'Y' THEN
		IF g_if_trend_sum_mv = 'Y' OR (l_comp_agg_flag = 'Y' and p_cc_agg_flag = 'Y' and g_fin_aggregate_flag = 'Y' and g_ud1_aggregate_flag = 'Y') THEN
				SELECT     parent_company_id INTO g_parent_company_id
				FROM       fii_company_hierarchies
				WHERE      child_company_id = p_company_id
                   		   	   and parent_level = child_level-1;
				l_company_join := 'parent_company_id = '||g_parent_company_id||'
					   and child_company_id = '||p_company_id;
		       ELSE
					l_company_join := 'parent_company_id = '||p_company_id||'
							   and child_level = parent_level';
		       END IF;
		    ELSE
					l_company_join := 'parent_company_id = '||p_company_id||'
							   and child_level = parent_level+1';
       	           END IF;

                  ELSE -- we have > 1 record in company security table FOR that user

		IF g_if_trend_sum_mv = 'Y' OR (l_comp_agg_flag = 'Y' and p_cc_agg_flag = 'Y' and g_fin_aggregate_flag = 'Y' and g_ud1_aggregate_flag = 'Y')  THEN
			SELECT     parent_company_id INTO g_parent_company_id
			FROM       fii_company_hierarchies
			WHERE      child_company_id = p_company_id
                   		   and parent_level = child_level-1;
			l_company_join := 'parent_company_id = '||g_parent_company_id||'
					   and child_company_id = '||p_company_id;
		ELSE
			l_company_join := 'parent_company_id = '||p_company_id||'
					   and child_company_id = '||p_company_id;
		END IF;
	END IF;  -- END of IF g_company_count=1 IF LOOP

     ELSE -- non viewby company
	        IF g_if_trend_sum_mv = 'Y' OR (l_comp_agg_flag = 'Y' and p_cc_agg_flag = 'Y' and g_fin_aggregate_flag = 'Y' and g_ud1_aggregate_flag = 'Y')  THEN
      			SELECT     parent_company_id INTO g_parent_company_id
			FROM       fii_company_hierarchies
			WHERE      child_company_id = p_company_id
                   		   and parent_level = child_level-1;
			l_company_join := 'parent_company_id = '||g_parent_company_id||'
				   and child_company_id = '||p_company_id;
		ELSE
			l_company_join := 'parent_company_id = '||p_company_id||'
					   and child_company_id = '||p_company_id;
       		END IF;
    END IF; -- END of IF viewby company control structure

IF g_view_by = 'FII_COMPANIES+FII_COMPANIES' THEN
	l_company_sql := 'SELECT co_hier.parent_company_id, co_hier.next_level_company_id, co_hier.next_level_company_sort_order, viewby_dim.description
    		  	  FROM   fii_company_hierarchies co_hier, fnd_flex_values_tl viewby_dim
		    	  WHERE  viewby_dim.flex_value_id = co_hier.next_level_company_id
      				 and viewby_dim.language =   userenv(''LANG'')
			         and '||l_company_join;
ELSE -- we dont need to join to fnd_flex_values_tl hence passing NULL description
	l_company_sql := 'SELECT co_hier.parent_company_id, co_hier.next_level_company_id, NULL,NULL
    		  	  FROM   fii_company_hierarchies co_hier
			  WHERE  '||l_company_join;
END IF;

-- fetch records in company dimension's pl/sql table of records

EXECUTE IMMEDIATE l_company_sql BULK COLLECT INTO company_table;

END form_all_company_join;

/* below mentioned procedure forms join for company dimension, when any specific value is chosen for
company parameter. It also inserts records into company dimension PL/SQL table */

PROCEDURE form_specific_company_join(p_comp_aggregate_flag IN VARCHAR2, p_cc_agg_flag IN VARCHAR2) IS

l_company_sql VARCHAR2(10000);
l_company_join VARCHAR2(10000);
l_leaf_flag VARCHAR2(1);

BEGIN

     IF g_if_trend_sum_mv = 'Y' OR (p_comp_aggregate_flag = 'Y' and p_cc_agg_flag = 'Y' and g_fin_aggregate_flag = 'Y' and g_ud1_aggregate_flag = 'Y')  THEN
		IF g_view_by = 'FII_COMPANIES+FII_COMPANIES' THEN

				check_if_leaf(g_company_id);

			  IF g_company_is_leaf = 'Y' THEN
				SELECT     parent_company_id INTO g_parent_company_id
				FROM       fii_company_hierarchies
				WHERE      child_company_id = g_company_id
			   		   and parent_level = child_level-1;
				l_company_join := 'parent_company_id ='||g_parent_company_id||'
						   and child_company_id ='||g_company_id;
			  ELSE
				l_company_join := 'parent_company_id ='||g_company_id||'
						   and child_level = parent_level + 1';
			  END IF;
	       ELSE -- nonviewby company
			SELECT     parent_company_id INTO g_parent_company_id
			FROM       fii_company_hierarchies
			WHERE      child_company_id = g_company_id
                   		   and parent_level = child_level-1;
			l_company_join := 'parent_company_id ='||g_parent_company_id||'
					   and child_company_id ='||g_company_id;
	       END IF;
	ELSE -- non aggrt MV is being hit
		IF g_view_by = 'FII_COMPANIES+FII_COMPANIES' THEN

			check_if_leaf(g_company_id);

			IF g_company_is_leaf = 'Y' THEN
				l_company_join := 'parent_company_id ='||g_company_id||'
						   and child_company_id ='||g_company_id;
			ELSE
				l_company_join := 'parent_company_id ='||g_company_id||'
						   and child_level = parent_level + 1';
			END IF;
	        ELSE
				l_company_join := 'parent_company_id ='||g_company_id||'
						   and child_company_id ='||g_company_id;
	        END IF;
	END IF;

IF g_view_by = 'FII_COMPANIES+FII_COMPANIES' THEN
	l_company_sql := 'SELECT co_hier.parent_company_id,co_hier.next_level_company_id, co_hier.next_level_company_sort_order, viewby_dim.description
    			  FROM   fii_company_hierarchies co_hier, fnd_flex_values_tl viewby_dim
    			  WHERE  viewby_dim.flex_value_id = co_hier.next_level_company_id
      				 and viewby_dim.language =   userenv(''LANG'')
			         and '||l_company_join;
ELSE -- no need to join to tl table
	l_company_sql := 'SELECT co_hier.parent_company_id,co_hier.next_level_company_id, NULL, NULL
    			  FROM   fii_company_hierarchies co_hier
    			  WHERE  '||l_company_join;
END IF;

EXECUTE IMMEDIATE l_company_sql BULK COLLECT INTO company_table;

END form_specific_company_join;

/* below mentioned procedure forms join for cost center dimension, when cc parameter chosen is All.
It also inserts records into CC dimension PL/SQL table */

PROCEDURE form_all_cc_join(p_comp_agg_flag IN VARCHAR2, p_cc_agg_flag IN VARCHAR2, p_cc_id IN NUMBER) IS

l_cc_sql VARCHAR2(10000);
l_cc_join VARCHAR2(10000);
l_leaf_flag VARCHAR2(1);
l_cc_agg_flag VARCHAR2(1);


BEGIN

l_cc_agg_flag := p_cc_agg_flag;

		IF g_view_by = 'ORGANIZATION+HRI_CL_ORGCC' THEN

     		IF g_cc_count = 1 THEN
				SELECT for_viewby_flag INTO l_cc_agg_flag
				FROM fii_cc_pmv_agrt_nodes
				WHERE cost_center_id = p_cc_id;

			check_if_leaf(p_cc_id);

			IF g_cost_center_is_leaf = 'Y' THEN
	IF g_if_trend_sum_mv = 'Y' OR (p_comp_agg_flag = 'Y' and l_cc_agg_flag = 'Y' and g_fin_aggregate_flag = 'Y' and	g_ud1_aggregate_flag = 'Y') THEN
				SELECT     parent_cc_id INTO g_parent_cost_center_id
				FROM       fii_cost_ctr_hierarchies
				WHERE      child_cc_id = p_cc_id
                   		   	   and parent_level = child_level-1;
				l_cc_join := 'parent_cc_id = '||g_parent_cost_center_id||'
					   and child_cc_id = '||p_cc_id;
		       ELSE
					l_cc_join := 'parent_cc_id = '||p_cc_id||'
							   and child_level = parent_level';
		       END IF;
		    ELSE
					l_cc_join := 'parent_cc_id = '||p_cc_id||'
					    	      and child_level = parent_level+1';
       	           END IF;
                  ELSE -- we have > 1 record in cc security table FOR that user
		IF g_if_trend_sum_mv = 'Y' OR (p_comp_agg_flag = 'Y' and l_cc_agg_flag = 'Y' and g_fin_aggregate_flag = 'Y' and g_ud1_aggregate_flag = 'Y')  THEN
			SELECT     parent_cc_id INTO g_parent_cost_center_id
			FROM       fii_cost_ctr_hierarchies
			WHERE      child_cc_id = p_cc_id
                   		   and parent_level = child_level-1;
			l_cc_join := 'parent_cc_id = '||g_parent_cost_center_id||'
					   and child_cc_id = '||p_cc_id;
		ELSE
			l_cc_join := 'parent_cc_id = '||p_cc_id||'
					   and child_cc_id = '||p_cc_id;
		END IF;
	END IF ; -- END of IF g_cc_count=1 IF LOOP
     ELSE -- non viewby CC
	       IF g_if_trend_sum_mv = 'Y' OR (p_comp_agg_flag = 'Y' and l_cc_agg_flag = 'Y' and g_fin_aggregate_flag = 'Y' and g_ud1_aggregate_flag = 'Y')  THEN
      			SELECT     parent_cc_id INTO g_parent_cost_center_id
			FROM       fii_cost_ctr_hierarchies
			WHERE      child_cc_id = p_cc_id
                   		   and parent_level = child_level-1;
			l_cc_join := 'parent_cc_id = '||g_parent_cost_center_id||'
				   and child_cc_id = '||p_cc_id;
		ELSE
			l_cc_join := 'parent_cc_id = '||p_cc_id||'
					   and child_cc_id = '||p_cc_id;
       		END IF;
    END IF; -- END of IF viewby cc
IF g_view_by = 'ORGANIZATION+HRI_CL_ORGCC' THEN
	l_cc_sql := 'SELECT cc_hier.parent_cc_id, cc_hier.next_level_cc_id, cc_hier.next_level_cc_sort_order, viewby_dim.description
    		  FROM   fii_cost_ctr_hierarchies cc_hier, fnd_flex_values_tl viewby_dim
    		  WHERE  viewby_dim.flex_value_id = cc_hier.next_level_cc_id
      			 and viewby_dim.language =   userenv(''LANG'')
		         and '||l_cc_join;
ELSE
	l_cc_sql := 'SELECT cc_hier.parent_cc_id, cc_hier.next_level_cc_id, NULL, NULL
    		  FROM   fii_cost_ctr_hierarchies cc_hier
    		  WHERE  '||l_cc_join;
END IF;
-- fetch all records FOR CC in CC dimension's table of records
EXECUTE IMMEDIATE l_cc_sql BULK COLLECT INTO cc_table;

END form_all_cc_join;

/* below mentioned procedure forms join for cost center dimension, when any specific value is chosen for cc parameter.
It also inserts records into CC dimension PL/SQL table */

PROCEDURE form_specific_cc_join(p_comp_agg_flag IN VARCHAR2,p_cc_agg_flag IN VARCHAR2) IS

l_cc_sql VARCHAR2(10000);
l_cc_join VARCHAR2(10000);
l_leaf_flag VARCHAR2(1);

BEGIN

	IF g_if_trend_sum_mv = 'Y' OR (p_comp_agg_flag = 'Y' and p_cc_agg_flag = 'Y' and g_fin_aggregate_flag = 'Y' and g_ud1_aggregate_flag = 'Y')  THEN
		IF g_view_by = 'ORGANIZATION+HRI_CL_ORGCC' THEN

	                  check_if_leaf(g_cost_center_id);

		  IF g_cost_center_is_leaf = 'Y' THEN

			SELECT     parent_cc_id INTO g_parent_cost_center_id
			FROM       fii_cost_ctr_hierarchies
			WHERE      child_cc_id = g_cost_center_id
                   		   and parent_level = child_level-1;
			l_cc_join := 'parent_cc_id = '||g_parent_cost_center_id||'
					   and child_cc_id = '||g_cost_center_id;
		  ELSE
			l_cc_join := 'parent_cc_id = '||g_cost_center_id||'
					   and child_level = parent_level + 1';
		  END IF;
	     ELSE
			SELECT     parent_cc_id INTO g_parent_cost_center_id
			FROM       fii_cost_ctr_hierarchies
			WHERE      child_cc_id = g_cost_center_id
                   		   and parent_level = child_level-1;
			l_cc_join := 'parent_cc_id = '||g_parent_cost_center_id||'
					   and child_cc_id = '||g_cost_center_id;
	    END IF;
	ELSE
		IF g_view_by = 'ORGANIZATION+HRI_CL_ORGCC' THEN

			check_if_leaf(g_cost_center_id);

		  IF g_cost_center_is_leaf = 'Y' THEN
			l_cc_join := 'parent_cc_id ='||g_cost_center_id||'
					   and child_cc_id ='||g_cost_center_id;
		   ELSE
			l_cc_join := 'parent_cc_id ='||g_cost_center_id||'
					   and child_level = parent_level + 1';
		  END IF;
	      ELSE
			l_cc_join := 'parent_cc_id ='||g_cost_center_id||'
					   and child_cc_id ='||g_cost_center_id;
	      END IF;
	END IF;

IF g_view_by = 'ORGANIZATION+HRI_CL_ORGCC' THEN
	l_cc_sql := 'SELECT cc_hier.parent_cc_id, cc_hier.next_level_cc_id, cc_hier.next_level_cc_sort_order, viewby_dim.description
    			  FROM   fii_cost_ctr_hierarchies cc_hier, fnd_flex_values_tl viewby_dim
    			  WHERE  viewby_dim.flex_value_id = cc_hier.next_level_cc_id
      				 and viewby_dim.language =   userenv(''LANG'')
			         and '||l_cc_join;
ELSE
	l_cc_sql := 'SELECT cc_hier.parent_cc_id, cc_hier.next_level_cc_id, NULL, NULL
  		  FROM   fii_cost_ctr_hierarchies cc_hier
  		  WHERE  '||l_cc_join;
END IF;

EXECUTE IMMEDIATE l_cc_sql BULK COLLECT INTO cc_table;

END form_specific_cc_join;

/* below mentioned procedure inserts records into financial category, UD1 and UD2 dimension PL/SQL tables, based on their joins formed in earlier steps */

PROCEDURE other_misc_stuff(p_comp_agg_flag IN VARCHAR2, p_cc_agg_flag IN VARCHAR2, p_aggrt_gt_is_empty OUT NOCOPY VARCHAR2, p_non_aggrt_gt_is_empty OUT NOCOPY VARCHAR2) IS

l_fin_cat_sql VARCHAR2(10000);
l_fud1_sql VARCHAR2(10000);
l_fud2_sql VARCHAR2(10000);
l_company_join VARCHAR2(10000);
l_leaf_flag VARCHAR2(1);
l_comp_agg_flag VARCHAR2(1);

BEGIN

IF (g_if_trend_sum_mv = 'Y') OR (p_comp_agg_flag = 'Y' and p_cc_agg_flag = 'Y' and g_fin_aggregate_flag = 'Y' and g_ud1_aggregate_flag = 'Y')  THEN
		l_cat_join := l_aggrt_cat_join;
		l_fud1_join := l_aggrt_fud1_join;
	ELSE -- non-aggrt MVs
		l_cat_join := l_nonaggrt_cat_join;
		l_fud1_join := l_nonaggrt_fud1_join;
	END IF;

/* In the following if-then-else block, for 'All' chosen and single fin cat top node scenarios or a specific
   fin cat node, GT tables will store the description of next-level fin_cat_id else for multiple top nodes,
   it will store the description of parent fin_cat_ids..done as part of bug 4099357*/

IF g_fin_cat_type IS NULL THEN
	l_fin_cat_sql := 'SELECT  NULL, NULL, NULL, NULL FROM  dual';
ELSIF g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
	IF g_top_node_is_leaf = 'Y' THEN
		l_fin_cat_sql := 'SELECT	fin_hier.parent_fin_cat_id, fin_hier.next_level_fin_cat_id, fin_hier.next_level_fin_cat_sort_order, viewby_dim.description
				  FROM		fii_fin_item_leaf_hiers fin_hier, fnd_flex_values_tl viewby_dim
				  WHERE		viewby_dim.flex_value_id = fin_hier.next_level_fin_cat_id
						and viewby_dim.language =   userenv(''LANG'')
					        and '||l_cat_join;
	ELSIF (g_fin_cat_top_node_count = 1 or g_fin_cat_top_node_count = 0) THEN
		l_fin_cat_sql := 'SELECT	fin_hier.parent_fin_cat_id, fin_hier.next_level_fin_cat_id, fin_hier.next_level_fin_cat_sort_order, viewby_dim.description
				  FROM		fii_fin_item_leaf_hiers fin_hier, fnd_flex_values_tl viewby_dim
				  WHERE		viewby_dim.flex_value_id = fin_hier.next_level_fin_cat_id
						and viewby_dim.language =   userenv(''LANG'')
					        and '||l_cat_join;
	ELSE
		l_fin_cat_sql := 'SELECT	fin_hier.parent_fin_cat_id, fin_hier.next_level_fin_cat_id, fin_hier.next_level_fin_cat_sort_order, viewby_dim.description
				  FROM		fii_fin_item_leaf_hiers fin_hier, fnd_flex_values_tl viewby_dim
				  WHERE		viewby_dim.flex_value_id = fin_hier.parent_fin_cat_id
						and viewby_dim.language =   userenv(''LANG'')
					        and '||l_cat_join;
	END IF;
ELSE
	l_fin_cat_sql := 'SELECT  fin_hier.parent_fin_cat_id, fin_hier.next_level_fin_cat_id, NULL,NULL
			  FROM    fii_fin_item_leaf_hiers fin_hier
			  WHERE   '||l_cat_join;
END IF;
-- fetch all records FOR Category in category's table of records

IF g_fin_cat_type IS NULL THEN
	EXECUTE IMMEDIATE l_fin_cat_sql BULK COLLECT INTO fin_cat_table;
ELSIF g_fin_category_id = 'All' THEN
	EXECUTE IMMEDIATE l_fin_cat_sql BULK COLLECT INTO fin_cat_table using g_fin_cat_type;
ELSE
	EXECUTE IMMEDIATE l_fin_cat_sql BULK COLLECT INTO fin_cat_table;
END IF;

IF g_if_trend_sum_mv = 'Y' THEN
	l_fud1_sql := 'SELECT  NULL, NULL, NULL, NULL FROM  dual';
ELSIF g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN
	l_fud1_sql := '	SELECT	fud1_hier.parent_value_id, fud1_hier.next_level_value_id, fud1_hier.next_level_value_sort_order, viewby_dim.description
			FROM	fii_udd1_hierarchies fud1_hier, fnd_flex_values_tl viewby_dim
			WHERE	viewby_dim.flex_value_id = fud1_hier.next_level_value_id
				and viewby_dim.language =   userenv(''LANG'')
				and '||l_fud1_join;
ELSE
	l_fud1_sql := '	    SELECT  fud1_hier.parent_value_id, fud1_hier.next_level_value_id, NULL, null
			    FROM    fii_udd1_hierarchies fud1_hier
			    WHERE   '||l_fud1_join;
END IF;
-- fetch all records for FUD1 in fud1's table of records
EXECUTE IMMEDIATE l_fud1_sql BULK COLLECT INTO fud1_table;

IF g_if_trend_sum_mv = 'Y' THEN
	l_fud2_sql := 'SELECT  NULL, NULL, NULL, NULL FROM  dual';
ELSIF g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_2' THEN
	l_fud2_sql := '	SELECT  fud2_hier.parent_value_id, fud2_hier.next_level_value_id, fud2_hier.next_level_value_sort_order, viewby_dim.description
			FROM	fii_udd2_hierarchies fud2_hier, fnd_flex_values_tl viewby_dim
			WHERE	viewby_dim.flex_value_id = fud2_hier.next_level_value_id
				and viewby_dim.language =   userenv(''LANG'')
				and '||l_fud2_join;
ELSE
	l_fud2_sql := '	SELECT  fud2_hier.parent_value_id, fud2_hier.next_level_value_id, NULL, null
			FROM    fii_udd2_hierarchies fud2_hier
			WHERE   '||l_fud2_join;
END IF;
-- fetch all records for FUD2 in fud2's table of records
EXECUTE IMMEDIATE l_fud2_sql BULK COLLECT INTO fud2_table;

IF (g_if_trend_sum_mv = 'Y') OR (p_comp_agg_flag = 'Y' and p_cc_agg_flag = 'Y' and g_fin_aggregate_flag = 'Y' and g_ud1_aggregate_flag = 'Y') THEN
	p_aggrt_gt_is_empty := 'N';
	p_non_aggrt_gt_is_empty := 'Y';
	insert_into_aggrt_gt;
ELSE
	p_aggrt_gt_is_empty := 'Y';
	p_non_aggrt_gt_is_empty := 'N';
	insert_into_non_aggrt_gt;

END IF;

END other_misc_stuff;

PROCEDURE populate_security_gt_tables (p_aggrt_gt_is_empty OUT NOCOPY VARCHAR2,
				       p_non_aggrt_gt_is_empty OUT NOCOPY VARCHAR2) IS

/* variable declaration section  */

l_top_node		VARCHAR2(1000);
l_company_sql		VARCHAR2(10000);
l_cc_sql		VARCHAR2(10000);
l_fin_cat_sql		VARCHAR2(10000);
l_fud1_sql		VARCHAR2(10000);
l_fud2_sql		VARCHAR2(10000);
l_leaf_flag		VARCHAR2(1) := 'N';
l_company_aggregate_flag VARCHAR2(1);
l_cc_aggregate_flag	VARCHAR2(1);
l_company_join		VARCHAR2(10000);
l_cc_join		VARCHAR2(10000);
l_viewbydim		VARCHAR2(10000);
l_fud1_enabled_flag	VARCHAR2(1); -- flag to check if fud1 is enabled
l_fud2_enabled_flag	VARCHAR2(1);
l_schema_name		VARCHAR2(10);
l_debug_mode		VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

-- definition of company cursor

CURSOR company_cursor IS
        SELECT 	sec.company_id company_id, sec.aggregated_flag agg_flag
        FROM 	fii_company_grants sec
        WHERE 	sec.user_id = fnd_global.user_id
		and report_region_code = g_region_code;

-- definition of cost center cursor

CURSOR cost_center_cursor IS
        SELECT 	sec.cost_center_id cc_id, sec.aggregated_flag agg_flag
        FROM 	fii_cost_center_grants sec
        WHERE 	sec.user_id = fnd_global.user_id
		and report_region_code = g_region_code;

BEGIN

l_schema_name := FII_UTIL.get_schema_name('FII');
EXECUTE IMMEDIATE 'truncate table '||l_schema_name||'.fii_pmv_aggrt_gt';
EXECUTE IMMEDIATE 'truncate table '||l_schema_name||'.fii_pmv_non_aggrt_gt';

/* We set this variable to yes, (whenever current procedure is invoked from EA page portlets) OR
(view by <> UD1/UD2 AND param values for Fin category, UD1, UD2, ledger are 'All' */

IF g_region_code = 'FII_EA_PAGE' OR (g_view_by <> 'FII_USER_DEFINED+FII_USER_DEFINED_1' AND g_view_by <> 'FII_USER_DEFINED+FII_USER_DEFINED_2' AND g_fin_category_id = 'All' AND g_ledger_id = 'All' AND g_fud1_id = 'All' AND g_fud2_id = 'All') THEN
		g_if_trend_sum_mv := 'Y';
END IF;

p_aggrt_gt_is_empty := 'Y';
p_non_aggrt_gt_is_empty := 'Y';

-- Check whether fin category and UD1 parameter values are aggregated or not

IF g_fud1_id = 'All' THEN
		g_ud1_aggregate_flag := 'Y';
	ELSIF g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN
		SELECT for_viewby_flag INTO g_ud1_aggregate_flag
		FROM fii_udd1_pmv_agrt_nodes
		WHERE udd1_value_id=g_fud1_id;
	ELSE
		SELECT aggregated_flag INTO g_ud1_aggregate_flag FROM fii_udd1_pmv_agrt_nodes WHERE udd1_value_id=g_fud1_id;
	END IF;

	IF g_fin_category_id = 'All' THEN
		g_fin_aggregate_flag := 'Y';
	ELSIF g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
		SELECT for_viewby_flag INTO g_fin_aggregate_flag FROM fii_fc_pmv_agrt_nodes WHERE fin_category_id=g_fin_category_id;
	ELSE
		SELECT aggregated_flag INTO g_fin_aggregate_flag FROM fii_fc_pmv_agrt_nodes WHERE fin_category_id=g_fin_category_id;
	END IF;

-- fin category join is being formed. Child_level = parent_level check has been
--included to take care of loading of budget/forecast at summary nodes

IF g_fin_category_id = 'All' THEN -- this portion eliminates the need to use cursor for multiple top nodes for category

/* fix for bug 4127077. If we any top node which is also a leaf, then we pick up the
records with OM as parent category and top node as child from fii_gl_agrt_sum_mv ELSE we pick up
records with top nodes as parent categories and their next level children as child categories */

/* bug 4337351. For non-viewby fin category scenarios, while inserting records into fii_pmv_aggrt_gt table,
we earlier picked up top node as parent fin category id and its next-level children as child fin category ids.
This resulted in more NUMBER of records being inserted in gt tables which degraded performance. Instead, now,
for non-viewby category cases, we pick up the combination of Operating Margin-Top node(s) which results in significant perf improvement */


       IF g_view_by <> 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
		l_aggrt_cat_join := 'EXISTS ( SELECT 1
					FROM fii_fin_cat_type_assgns a
					   , fii_fin_item_leaf_hiers b
					WHERE a.FIN_CAT_TYPE_CODE = :g_fin_cat_type
					AND a.TOP_NODE_FLAG = ''Y''
					and a.fin_category_id = b.CHILD_FIN_CAT_ID
					and a.fin_category_id <> b.PARENT_FIN_CAT_ID
					AND a.fin_Category_id = fin_hier.child_fin_cat_id
				     ) and (child_level <> parent_level AND child_level = parent_level+1)';

	ELSIF g_top_node_is_leaf = 'N' THEN
		l_aggrt_cat_join := 'EXISTS ( SELECT 1
					FROM fii_fin_cat_type_assgns a
					   , fii_fin_item_leaf_hiers b
					WHERE a.FIN_CAT_TYPE_CODE = :g_fin_cat_type
					AND a.TOP_NODE_FLAG = ''Y''
					and a.fin_category_id = b.CHILD_FIN_CAT_ID
					and a.fin_category_id <> b.PARENT_FIN_CAT_ID
					AND a.fin_Category_id = fin_hier.parent_fin_cat_id
				     ) and (child_level = parent_level OR child_level = parent_level+1)';
	ELSE
		l_aggrt_cat_join := 'EXISTS ( SELECT 1
					FROM fii_fin_cat_type_assgns a
					   , fii_fin_item_leaf_hiers b
					WHERE a.FIN_CAT_TYPE_CODE = :g_fin_cat_type
					AND a.TOP_NODE_FLAG = ''Y''
					and a.fin_category_id = b.CHILD_FIN_CAT_ID
					and a.fin_category_id <> b.PARENT_FIN_CAT_ID
					AND a.fin_Category_id = fin_hier.child_fin_cat_id
				     ) and (child_level <> parent_level AND child_level = parent_level+1)';
	END IF;

		/* the following if-then-else block picks up self records for top nodes as well as their
		   next-level children's records, when we have only one fin cat top node else for multiple
		   top nodes, it pick up only self records for top nodes..done as part of bug 4099357 */

		IF g_if_trend_sum_mv = 'N' THEN
		    IF g_fin_cat_top_node_count = 1 THEN

			SELECT	a.fin_category_id INTO g_category_id
			FROM	fii_fin_cat_type_assgns a
			WHERE	a.FIN_CAT_TYPE_CODE = g_fin_cat_type
				and a.TOP_NODE_FLAG = 'Y';

			l_nonaggrt_cat_join := 'EXISTS ( SELECT 1
						FROM fii_fin_cat_type_assgns a
						   , fii_fin_item_leaf_hiers b
						WHERE a.FIN_CAT_TYPE_CODE = :g_fin_cat_type
						AND a.TOP_NODE_FLAG = ''Y''
						and a.fin_category_id = b.CHILD_FIN_CAT_ID
						and a.fin_category_id <> b.PARENT_FIN_CAT_ID
						AND a.fin_Category_id = fin_hier.parent_fin_cat_id
					     ) and (child_level = parent_level OR child_level = parent_level+1)';
		   ELSE
			l_nonaggrt_cat_join := 'EXISTS ( SELECT 1
						FROM fii_fin_cat_type_assgns a
						   , fii_fin_item_leaf_hiers b
						WHERE a.FIN_CAT_TYPE_CODE = :g_fin_cat_type
						AND a.TOP_NODE_FLAG = ''Y''
						and a.fin_category_id = b.CHILD_FIN_CAT_ID
						and a.fin_category_id <> b.PARENT_FIN_CAT_ID
						AND a.fin_Category_id = fin_hier.parent_fin_cat_id
					     ) and child_level = parent_level';
		   END IF;
		END IF;
END IF;

/* Below mentioned joins need to be formed, only when we are not hitting fii_gl_trend_sum_mv -

1. When specific financial category has been chosen i.e. formation of l_aggrt_cat_join and g_non_aggrt_cat_join
2. l_aggrt_fud1_join and l_nonaggrt_fud1_join
3. l_fud2_join

*/

IF g_if_trend_sum_mv = 'N' THEN
    IF g_fin_category_id <> 'All' THEN
	g_category_id := g_fin_category_id;

	IF g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN
-- we need to consider next_level category nodes

		check_if_leaf(g_fin_category_id);

		  IF g_fin_cat_is_leaf = 'Y' THEN

			SELECT	parent_fin_cat_id INTO g_parent_fin_category_id
			FROM	fii_fin_item_leaf_hiers
			WHERE	child_fin_cat_id = g_fin_category_id
				and parent_level=child_level-1;
				l_aggrt_cat_join := 'parent_fin_cat_id = '||g_parent_fin_category_id||'
						and child_fin_cat_id = '||g_fin_category_id;
			ELSE
				l_aggrt_cat_join := 'parent_fin_cat_id = '||g_fin_category_id||'
						and (child_level = parent_level OR child_level = parent_level+1)';

			END IF;
	ELSE -- we can pick up the parent category directly
			SELECT	parent_fin_cat_id INTO g_parent_fin_category_id
			FROM	fii_fin_item_leaf_hiers
			WHERE	child_fin_cat_id = g_fin_category_id
				and parent_level=child_level-1;
			l_aggrt_cat_join := 'parent_fin_cat_id = '||g_parent_fin_category_id||'
						and child_fin_cat_id = '||g_fin_category_id;
	END IF;

	SELECT  is_leaf_flag INTO l_leaf_flag
	FROM    fii_fin_item_leaf_hiers
	WHERE   parent_fin_cat_id=g_fin_category_id
       		 and parent_fin_cat_id = child_fin_cat_id;

			IF l_leaf_flag = 'Y' THEN
				l_nonaggrt_cat_join := 'parent_fin_cat_id = '||g_fin_category_id||'
						and child_fin_cat_id = '||g_fin_category_id;
			ELSE
				l_nonaggrt_cat_join := 'parent_fin_cat_id = '||g_fin_category_id||'
						and (child_level = parent_level OR child_level = parent_level+1)';
			END IF;
    END IF;

-- fud1 join is being formed
	SELECT     dbi_enabled_flag INTO l_fud1_enabled_flag
	FROM       fii_financial_dimensions
	WHERE      dimension_short_name = 'FII_USER_DEFINED_1';

	   IF l_fud1_enabled_flag = 'N' THEN
     		SELECT  parent_value_id INTO g_top_fud1_id
		FROM    fii_udd1_hierarchies;

		 g_udd1_id := g_top_fud1_id;

	        l_aggrt_fud1_join := 'parent_value_id = '||g_top_fud1_id||' and
            			child_value_id = '||g_top_fud1_id;
		l_nonaggrt_fud1_join := 'parent_value_id = '||g_top_fud1_id||' and
            			child_value_id = '||g_top_fud1_id;
	   ELSE
-- we need to consider next_level fud1 nodes
       		IF g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN
   			IF g_fud1_id = 'All' THEN
		           SELECT NVL(dbi_hier_top_node_id, -99999) INTO g_top_fud1_id
		           FROM    fii_financial_dimensions
		           WHERE dimension_short_name = 'FII_USER_DEFINED_1';

			   g_udd1_id := g_top_fud1_id;

			  l_aggrt_fud1_join := 'parent_value_id = '||g_top_fud1_id||'
		                          and (child_level = parent_level OR child_level = parent_level+1)';
			ELSE

			   g_udd1_id := g_fud1_id;

			   check_if_leaf(g_fud1_id);

			   IF g_ud1_is_leaf = 'Y' THEN

				SELECT     parent_value_id INTO g_parent_fud1_id
				FROM       fii_udd1_hierarchies
				WHERE      child_value_id = g_fud1_id
			                   and parent_level = child_level-1;
				l_aggrt_fud1_join :=  'parent_value_id = '||g_parent_fud1_id||'
                                      and child_value_id = '||g_fud1_id;
		           ELSE
				l_aggrt_fud1_join := 'parent_value_id = '||g_fud1_id||'
                          		        and (child_level = parent_level OR child_level = parent_level+1)';
	                   END IF;
		      END IF;
	       ELSE -- we can consider parent fud1 node directly
			IF g_fud1_id = 'All' THEN
				SELECT NVL(dbi_hier_top_node_id, -99999) INTO g_top_fud1_id
				FROM   fii_financial_dimensions
			        WHERE  dimension_short_name = 'FII_USER_DEFINED_1';

				g_udd1_id := g_top_fud1_id;

				l_aggrt_fud1_join := 'parent_value_id = -999
			                        and child_value_id = '||g_top_fud1_id;
		       ELSE
				g_udd1_id := g_fud1_id;

				SELECT     parent_value_id INTO g_parent_fud1_id
				FROM       fii_udd1_hierarchies
				WHERE      child_value_id = g_fud1_id
				           and parent_level=child_level-1;
				l_aggrt_fud1_join :=  'parent_value_id = '||g_parent_fud1_id||'
			                         and child_value_id = '||g_fud1_id;
	              END IF ;
	      END IF;
	  END IF;


-- l_nonaggrt_fud1_join is the join for fud1 WHEN non-aggrt tables are hit
		 IF g_fud1_id = 'All' THEN
	           	IF g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN
				l_nonaggrt_fud1_join := 'parent_value_id = '||g_top_fud1_id||'
                					and (child_level = parent_level OR child_level = parent_level+1)';
	           	ELSE
        			l_nonaggrt_fud1_join := 'parent_value_id = '||g_top_fud1_id||'
                      			   and child_value_id = '||g_top_fud1_id;
                   	END IF;
		  ELSE
           		IF g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN
		           l_nonaggrt_fud1_join := 'parent_value_id = '||g_fud1_id||'
                		           and (child_level = parent_level OR child_level = parent_level+1)';
		        ELSE
		           l_nonaggrt_fud1_join := 'parent_value_id = '||g_fud1_id||'
                			   and child_value_id = '||g_fud1_id;
           		END IF;
   	         END IF;

-- fud2 join is being formed

	SELECT     dbi_enabled_flag INTO l_fud2_enabled_flag
	FROM       fii_financial_dimensions
	WHERE      dimension_short_name = 'FII_USER_DEFINED_2';
		If l_fud2_enabled_flag = 'N' THEN
     			SELECT  parent_value_id INTO g_top_fud2_id
			FROM     fii_udd2_hierarchies;
			l_fud2_join := 'parent_value_id = '||g_top_fud2_id||' and
            				child_value_id = '||g_top_fud2_id;
		ELSE
			IF g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_2' THEN
				IF g_fud2_id = 'All' THEN
					SELECT NVL(dbi_hier_top_node_id, -99999) INTO g_top_fud2_id
					FROM    fii_financial_dimensions
					WHERE dimension_short_name = 'FII_USER_DEFINED_2';
					l_fud2_join := 'parent_value_id = '||g_top_fud2_id||'
        						and parent_level+1 = child_level';
				ELSE
					check_if_leaf(g_fud2_id);

					IF g_ud2_is_leaf = 'Y' THEN
							l_fud2_join :=  'parent_value_id = '||g_fud2_id||'
       		                         				and child_value_id = '||g_fud2_id;
	       				ELSE
							l_fud2_join := 'parent_value_id = '||g_fud2_id||'
                                					and parent_level+1 = child_level';
                       			END IF;
				END IF;
			ELSE
				IF g_fud2_id = 'All' THEN
					SELECT  NVL(dbi_hier_top_node_id, -99999) INTO g_top_fud2_id
					FROM    fii_financial_dimensions
					WHERE   dimension_short_name = 'FII_USER_DEFINED_2';
					l_fud2_join := 'parent_value_id = '||g_top_fud2_id||'
							and child_value_id = '||g_top_fud2_id;
				ELSE
					l_fud2_join :=  'parent_value_id = '||g_fud2_id||'
							and child_value_id = '||g_fud2_id;
				END IF ;
			END IF;
		END IF;
END IF;

--Now that we have formed joins for category, fud1 and fud2, we come to case1..

--------------------1st case--- both company and CC param All ------------------------
IF g_company_id = 'All' THEN
	SELECT	count(*) INTO g_company_count
	FROM	fii_company_grants
	WHERE	user_id = fnd_global.user_id
		and report_region_code = g_region_code;

    IF g_cost_center_id = 'All' THEN
		SELECT	count(*) INTO g_cc_count
		FROM	fii_cost_center_grants
		WHERE	user_id = fnd_global.user_id
			and report_region_code = g_region_code;

	FOR i in company_cursor LOOP
		FOR j in cost_center_cursor LOOP

-- call various procedures to populate PL/SQL tables for different dimensions

			form_all_company_join(i.agg_flag, j.agg_flag, i.company_id);
			form_all_cc_join(i.agg_flag, j.agg_flag, j.cc_id);
			other_misc_stuff(i.agg_flag, j.agg_flag, p_aggrt_gt_is_empty, p_non_aggrt_gt_is_empty);

		END LOOP;
	END LOOP;
	FORALL y in 1..g_aggrt_gt_record_count
		INSERT INTO fii_pmv_aggrt_gt VALUES (	par_comp_id_aggrt_plsql(y),comp_id_aggrt_plsql(y),par_cc_id_aggrt_plsql(y),
							cc_id_aggrt_plsql(y),par_fin_cat_id_aggrt_plsql(y),fin_cat_id_aggrt_plsql(y),
							par_fud1_id_aggrt_plsql(y),fud1_id_aggrt_plsql(y),fud2_id_aggrt_plsql(y),
							aggrt_viewbydescription(y), sort_order_aggrt_plsql(y));
	FORALL z in 1..g_non_aggrt_gt_record_count
		INSERT INTO fii_pmv_non_aggrt_gt VALUES (comp_id_nonaggrt_plsql(z),cc_id_nonaggrt_plsql(z),fin_cat_id_nonaggrt_plsql(z),
							 fud1_id_nonaggrt_plsql(z),fud2_id_nonaggrt_plsql(z),nonaggrt_viewbydescription(z),sort_order_nonaggrt_plsql(z));

	IF l_debug_mode = 'Y' THEN
		insert_into_debug_tables;
	END IF;

    ELSE
---------------2nd case----- company - All and specific cost center chosen-------------
		FOR i in company_cursor LOOP
				IF g_view_by = 'ORGANIZATION+HRI_CL_ORGCC' THEN
					SELECT for_viewby_flag
					INTO l_cc_aggregate_flag
					FROM fii_cc_pmv_agrt_nodes
					WHERE cost_center_id=g_cost_center_id;
	   			ELSE
					SELECT aggregated_flag INTO l_cc_aggregate_flag FROM fii_cc_pmv_agrt_nodes id
					WHERE cost_center_id=g_cost_center_id;
				END IF;

-- call various procedures to populate PL/SQL tables for different dimensions

			form_all_company_join(i.agg_flag, l_cc_aggregate_flag, i.company_id);
			form_specific_cc_join(i.agg_flag, l_cc_aggregate_flag);
			other_misc_stuff(i.agg_flag, l_cc_aggregate_flag, p_aggrt_gt_is_empty, p_non_aggrt_gt_is_empty);

		END LOOP;
		FORALL y in 1..g_aggrt_gt_record_count
			INSERT INTO fii_pmv_aggrt_gt VALUES (	par_comp_id_aggrt_plsql(y),comp_id_aggrt_plsql(y),par_cc_id_aggrt_plsql(y),
								cc_id_aggrt_plsql(y),par_fin_cat_id_aggrt_plsql(y),fin_cat_id_aggrt_plsql(y),
								par_fud1_id_aggrt_plsql(y),fud1_id_aggrt_plsql(y),fud2_id_aggrt_plsql(y),
								aggrt_viewbydescription(y), sort_order_aggrt_plsql(y));
		FORALL z in 1..g_non_aggrt_gt_record_count
			INSERT INTO fii_pmv_non_aggrt_gt VALUES (comp_id_nonaggrt_plsql(z),cc_id_nonaggrt_plsql(z),fin_cat_id_nonaggrt_plsql(z),
								 fud1_id_nonaggrt_plsql(z),fud2_id_nonaggrt_plsql(z),nonaggrt_viewbydescription(z),sort_order_nonaggrt_plsql(z));

	IF l_debug_mode = 'Y' THEN
		insert_into_debug_tables;
	END IF;
    END IF;
ELSE
	 IF g_cost_center_id = 'All' THEN
-------------------- 3rd case...------ specific company and Cost Center - All is chosen------------------------------
		SELECT count(*) INTO g_cc_count
		FROM	fii_cost_center_grants
		WHERE	user_id=fnd_global.user_id
			and report_region_code = g_region_code;

		FOR j in cost_center_cursor LOOP

			IF g_view_by = 'FII_COMPANIES+FII_COMPANIES' THEN
				SELECT	for_viewby_flag
				INTO	l_company_aggregate_flag
				FROM	fii_com_pmv_agrt_nodes
				WHERE	company_id=g_company_id;
			ELSE
				SELECT 	aggregated_flag INTO l_company_aggregate_flag
				FROM 	fii_com_pmv_agrt_nodes
				WHERE 	company_id=g_company_id;
			END IF;

-- call various procedures to populate PL/SQL tables for different dimensions

			form_specific_company_join(l_company_aggregate_flag, j.agg_flag);
			form_all_cc_join(l_company_aggregate_flag, j.agg_flag, j.cc_id);
			other_misc_stuff(l_company_aggregate_flag, j.agg_flag, p_aggrt_gt_is_empty, p_non_aggrt_gt_is_empty);

		END LOOP;
		FORALL y in 1..g_aggrt_gt_record_count
		 INSERT INTO fii_pmv_aggrt_gt VALUES (	par_comp_id_aggrt_plsql(y),comp_id_aggrt_plsql(y),par_cc_id_aggrt_plsql(y),
							cc_id_aggrt_plsql(y),par_fin_cat_id_aggrt_plsql(y),fin_cat_id_aggrt_plsql(y),
							par_fud1_id_aggrt_plsql(y),fud1_id_aggrt_plsql(y),fud2_id_aggrt_plsql(y),
							aggrt_viewbydescription(y), sort_order_aggrt_plsql(y));
		FORALL i in 1..g_non_aggrt_gt_record_count
		    INSERT INTO fii_pmv_non_aggrt_gt VALUES (comp_id_nonaggrt_plsql(i),cc_id_nonaggrt_plsql(i),fin_cat_id_nonaggrt_plsql(i),
							     fud1_id_nonaggrt_plsql(i),fud2_id_nonaggrt_plsql(i),nonaggrt_viewbydescription(i),sort_order_nonaggrt_plsql(i));

	     IF l_debug_mode = 'Y' THEN
		insert_into_debug_tables;
	     END IF;
	 ELSE
---------------- 4th case..both param specific ---------------------------------------------------

		IF g_view_by = 'FII_COMPANIES+FII_COMPANIES' THEN
			SELECT for_viewby_flag
			INTO l_company_aggregate_flag
			FROM fii_com_pmv_agrt_nodes
			WHERE company_id = g_company_id;
		ELSE
			SELECT 	aggregated_flag INTO l_company_aggregate_flag
			FROM 	fii_com_pmv_agrt_nodes
			WHERE 	company_id=g_company_id;
		END IF;

		IF g_view_by = 'ORGANIZATION+HRI_CL_ORGCC' THEN
			SELECT for_viewby_flag
			INTO l_cc_aggregate_flag
			FROM fii_cc_pmv_agrt_nodes
			WHERE cost_center_id = g_cost_center_id;
		ELSE
			SELECT 	aggregated_flag INTO l_cc_aggregate_flag
			FROM 	fii_cc_pmv_agrt_nodes
			WHERE 	cost_center_id=g_cost_center_id;
		END IF;

-- call various procedures to populate PL/SQL tables for different dimensions

		form_specific_company_join(l_company_aggregate_flag,l_cc_aggregate_flag);
		form_specific_cc_join(l_company_aggregate_flag, l_cc_aggregate_flag);
		other_misc_stuff(l_company_aggregate_flag, l_cc_aggregate_flag, p_aggrt_gt_is_empty, p_non_aggrt_gt_is_empty);

		FORALL y in 1..g_aggrt_gt_record_count
			    INSERT INTO fii_pmv_aggrt_gt VALUES (   par_comp_id_aggrt_plsql(y),comp_id_aggrt_plsql(y),par_cc_id_aggrt_plsql(y),
								    cc_id_aggrt_plsql(y),par_fin_cat_id_aggrt_plsql(y),fin_cat_id_aggrt_plsql(y),
								    par_fud1_id_aggrt_plsql(y),fud1_id_aggrt_plsql(y),fud2_id_aggrt_plsql(y),
								    aggrt_viewbydescription(y), sort_order_aggrt_plsql(y));
		FORALL i in 1..g_non_aggrt_gt_record_count
			    INSERT INTO fii_pmv_non_aggrt_gt VALUES (comp_id_nonaggrt_plsql(i),cc_id_nonaggrt_plsql(i),fin_cat_id_nonaggrt_plsql(i),
								     fud1_id_nonaggrt_plsql(i),fud2_id_nonaggrt_plsql(i),nonaggrt_viewbydescription(i),sort_order_nonaggrt_plsql(i));

		IF l_debug_mode = 'Y' THEN
			insert_into_debug_tables;
		END IF;

	END IF;
END IF;

EXCEPTION
	WHEN OTHERS THEN
		p_aggrt_gt_is_empty := 'Y';
		p_non_aggrt_gt_is_empty := 'Y';

END populate_security_gt_tables;

-----------------------------------------------------

PROCEDURE insert_into_debug_tables IS
/* logic for this api...
1. We first search for existence of debug table. If it doesn't exist, we create it else we delete the records inserted for the same session_id and region code.
2. We then insert all columns of corresponding gt table + session_id and report_region_code into debug tables.
*/

l_agrt_table_count NUMBER := 0;
l_non_agrt_table_count NUMBER := 0;
l_schema_name	VARCHAR2(10) := FII_UTIL.get_schema_name('FII');

BEGIN
-- g_aggrt_gt_record_count and g_non_aggrt_gt_record_count are the number of records in fii_pmv_aggrt_gt and fii_pmv_non_aggrt_gt tables respectively

IF g_aggrt_gt_record_count > 0 THEN -- it means that fii_pmv_aggrt_gt has been populated so only now, we should insert records into fii_debug_agrt table

	BEGIN

	SELECT	1 INTO l_agrt_table_count
	FROM	dba_tables
	WHERE	table_name = 'FII_DEBUG_AGRT'
		and owner = l_schema_name;

	EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        l_agrt_table_count := 0;
        END;

	IF l_agrt_table_count  = 0 THEN

		EXECUTE IMMEDIATE 'CREATE TABLE '||l_schema_name||'.FII_DEBUG_AGRT (PARENT_COMPANY_ID          NUMBER,
								COMPANY_ID                 NUMBER,
								PARENT_CC_ID               NUMBER,
								CC_ID                      NUMBER,
								PARENT_FIN_CATEGORY_ID     NUMBER,
								FIN_CATEGORY_ID            NUMBER,
								PARENT_FUD1_ID             NUMBER,
								FUD1_ID                    NUMBER,
								FUD2_ID                    NUMBER,
								VIEWBY                     VARCHAR2(100),
								SORT_ORDER                 NUMBER,
								SESSION_ID                 NUMBER,
								REGION_CODE		   VARCHAR2(50))';
	ELSE
		EXECUTE IMMEDIATE 'DELETE FROM '||l_schema_name||'.FII_DEBUG_AGRT WHERE REGION_CODE = '''||g_region_code||''' AND SESSION_ID = '||g_session_id;

	END IF;

		EXECUTE IMMEDIATE 'INSERT INTO '||l_schema_name||'.FII_DEBUG_AGRT (PARENT_COMPANY_ID,
								COMPANY_ID,
								PARENT_CC_ID,
								CC_ID,
								PARENT_FIN_CATEGORY_ID,
								FIN_CATEGORY_ID,
								PARENT_FUD1_ID,
								FUD1_ID,
								FUD2_ID,
								VIEWBY,
								SORT_ORDER,
								SESSION_ID,
								REGION_CODE)

				SELECT			gt.PARENT_COMPANY_ID,
							gt.COMPANY_ID,
							gt.PARENT_CC_ID,
							gt.CC_ID ,
							gt.PARENT_FIN_CATEGORY_ID,
							gt.FIN_CATEGORY_ID,
							gt.PARENT_FUD1_ID,
							gt.FUD1_ID,
							gt.FUD2_ID,
							gt.VIEWBY,
							gt.SORT_ORDER,
							'||g_session_id||','''||g_region_code||'''
				FROM			fii_pmv_aggrt_gt gt';
END IF;

IF g_non_aggrt_gt_record_count > 0 THEN -- it means that fii_pmv_non_aggrt_gt has been populated so only now, we should insert records into fii_debug_non_agrt table

	BEGIN

	SELECT	1 INTO l_non_agrt_table_count
	FROM	dba_tables
	WHERE	table_name = 'FII_DEBUG_NON_AGRT'
		and owner = l_schema_name;

	EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        l_non_agrt_table_count := 0;
        END;

	IF l_non_agrt_table_count  = 0 THEN

		EXECUTE IMMEDIATE 'CREATE TABLE '||l_schema_name||'.FII_DEBUG_NON_AGRT (
							COMPANY_ID        NUMBER,
							COST_CENTER_ID    NUMBER,
							FIN_CATEGORY_ID   NUMBER,
							FUD1_ID           NUMBER,
							FUD2_ID           NUMBER,
							VIEWBY            VARCHAR2(100),
							SORT_ORDER        NUMBER,
							SESSION_ID NUMBER,
							REGION_CODE VARCHAR2(50))';
	ELSE
		EXECUTE IMMEDIATE 'DELETE FROM '||l_schema_name||'.FII_DEBUG_NON_AGRT WHERE REGION_CODE = '''||g_region_code||''' AND SESSION_ID = '||g_session_id;
	END IF;
		EXECUTE IMMEDIATE 'INSERT INTO '||l_schema_name||'.FII_DEBUG_NON_AGRT (COMPANY_ID,
							COST_CENTER_ID,
							FIN_CATEGORY_ID,
							FUD1_ID,
							FUD2_ID,
							VIEWBY,
							SORT_ORDER,
							SESSION_ID,
							REGION_CODE)

					SELECT		gt.company_id,
							gt.cost_center_id,
							gt.fin_category_id,
							gt.fud1_id,
							gt.fud2_id,
							gt.viewby,
							gt.sort_order,
							'||g_session_id||','''||g_region_code||'''
				FROM			fii_pmv_non_aggrt_gt gt';
END IF;

END insert_into_debug_tables;

----------------------------------------------------------

FUNCTION period_label (p_as_of_date IN DATE) RETURN VARCHAR2 IS
  stmt VARCHAR2(240);
BEGIN
  IF g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
      SELECT name INTO stmt
      FROM fii_time_ent_year
      WHERE p_as_of_date between start_date and end_date;
  ELSIF g_page_period_type = 'FII_TIME_ENT_QTR' THEN
      SELECT name INTO stmt
      FROM fii_time_ent_qtr
      WHERE p_as_of_date between start_date and end_date;
  ELSIF g_page_period_type = 'FII_TIME_ENT_PERIOD' THEN
      SELECT name INTO stmt
      FROM fii_time_ent_period
      WHERE p_as_of_date between start_date and end_date;
  END IF;
  RETURN stmt;
END period_label;


FUNCTION curr_period_label RETURN VARCHAR2 IS
  stmt VARCHAR2(240);
BEGIN
  stmt := period_label(g_as_of_date);
  return stmt;
END curr_period_label;


FUNCTION prior_period_label RETURN VARCHAR2 IS
  stmt VARCHAR2(240);
BEGIN
  stmt := period_label(g_previous_asof_date);
  return stmt;
END prior_period_label;

FUNCTION change_label RETURN VARCHAR2 IS
  stmt VARCHAR2(240);
BEGIN
--  IF fii_ea_util_pkg.g_time_comp = 'BUDGET' THEN
--	stmt := fnd_message.get_string('FII', 'FII_GL_PCNT_BUDGET');
 -- ELSIF fii_ea_util_pkg.g_time_comp = 'FORECAST' THEN
--	stmt := fnd_message.get_string('FII', 'FII_GL_PCNT_FORECAST');
 -- ELSE
	stmt := fnd_message.get_string('FII', 'FII_GL_CHANGE');
  --END IF;

   return stmt;

END change_label;


FUNCTION get_ledger_for_detail RETURN VARCHAR2 IS
  l_stmt VARCHAR2(500);
BEGIN
-- bug 4249974. Removed join, when ledger parameter is "All".

  IF g_ledger_id <> 'All' THEN
    l_stmt := 'and f.ledger_id = &FII_LEDGER+FII_LEDGER ';
  END IF;

  return l_stmt;
END get_ledger_for_detail;

FUNCTION get_fud1_for_detail RETURN VARCHAR2 IS
  l_stmt VARCHAR2(200);
  l_enabled_flag VARCHAR2(1);
BEGIN
  SELECT dbi_enabled_flag INTO l_enabled_flag
  FROM fii_financial_dimensions
  WHERE dimension_short_name = 'FII_USER_DEFINED_1';

  IF l_enabled_flag = 'Y' THEN

    IF g_fud1_id = 'All' THEN
      IF g_fud2_id = 'All' THEN
        l_stmt := ' ';
      ELSE
        l_stmt := ' and f.fud1_id in (SELECT child_value_id FROM fii_full_udd1_hiers WHERE parent_value_id = -999)';
      END IF;
    ELSE
        l_stmt := ' and f.fud1_id in (SELECT child_value_id FROM fii_full_udd1_hiers WHERE parent_value_id = &FII_USER_DEFINED+FII_USER_DEFINED_1)';
    END IF;

  ELSE --FUD1 not enabled
    l_stmt := ' and f.fud1_id = :UNASSIGNED_ID';
  END IF;

  return l_stmt;
END get_fud1_for_detail;

FUNCTION get_fud2_for_detail RETURN VARCHAR2 IS
  l_stmt VARCHAR2(200);
  l_enabled_flag VARCHAR2(1);
BEGIN
  SELECT dbi_enabled_flag INTO l_enabled_flag
  FROM fii_financial_dimensions
  WHERE dimension_short_name = 'FII_USER_DEFINED_2';

  IF l_enabled_flag = 'Y' THEN

    IF g_fud2_id = 'All' THEN
      l_stmt := ' ';
    ELSE
      l_stmt := '  and f.fud2_id in (SELECT child_value_id FROM fii_full_udd2_hiers WHERE parent_value_id = &FII_USER_DEFINED+FII_USER_DEFINED_2)';
    END IF;

  ELSE --FUD2 not enabled.
    l_stmt := ' and f.fud2_id = :UNASSIGNED_ID';
  END IF;

  return l_stmt;
END get_fud2_for_detail;


FUNCTION get_curr RETURN VARCHAR2 IS

   stmt                VARCHAR2(240);

BEGIN

stmt := 'FII_GLOBAL1';

RETURN stmt;

END get_curr;

FUNCTION xtd ( p_page_id           IN     VARCHAR2,
	       p_user_id           IN     VARCHAR2,
	       p_session_id        IN     VARCHAR2,
	       p_function_name     IN     VARCHAR2
              ) RETURN VARCHAR2
IS

stmt           VARCHAR2(240);

BEGIN

stmt := BIS_PMV_PORTAL_UTIL_PUB.getTimeLevelLabel(p_page_id, p_user_id, p_session_id, p_function_name);

RETURN stmt;

END xtd;

FUNCTION prior_xtd( p_page_id           IN     VARCHAR2,
	            p_user_id           IN     VARCHAR2,
	            p_session_id        IN     VARCHAR2,
	            p_function_name     IN     VARCHAR2) RETURN VARCHAR2
IS

stmt                VARCHAR2(240);

BEGIN
	stmt := fnd_message.get_string('FII', 'FII_GL_PMV')||' ' ||BIS_PMV_PORTAL_UTIL_PUB.getTimeLevelLabel(p_page_id, p_user_id, p_session_id, p_function_name);

RETURN stmt;

END prior_xtd;

FUNCTION prior_graph( p_page_id           IN     VARCHAR2,
                    p_user_id           IN     VARCHAR2,
                    p_session_id        IN     VARCHAR2,
                    p_function_name     IN     VARCHAR2) RETURN VARCHAR2
IS

stmt                VARCHAR2(240);

BEGIN

IF fii_ea_util_pkg.g_time_comp = 'BUDGET' THEN
        stmt := fnd_message.get_string('FII', 'FII_GL_BUDGET');
ELSIF fii_ea_util_pkg.g_time_comp = 'FORECAST' THEN
        stmt := fnd_message.get_string('FII', 'FII_GL_FORECAST');
ELSIF fii_ea_util_pkg.g_region_code = 'FII_PL_GROSS_MARGIN_SUMM' OR fii_ea_util_pkg.g_region_code = 'FII_PL_OPER_MARGIN_SUMM' THEN
	stmt := fnd_message.get_string('FII', 'FII_PL_INCOME');
ELSE
	stmt := fnd_message.get_string('FII', 'FII_GL_PMV')||' ' ||BIS_PMV_PORTAL_UTIL_PUB.getTimeLevelLabel(p_page_id, p_user_id, p_session_id, p_function_name);
END IF;

RETURN stmt;

END prior_graph;


FUNCTION get_rolling_period_label(p_sequence IN VARCHAR2) RETURN VARCHAR2 IS

stmt		VARCHAR2(240);
l_asof_date     DATE := fii_ea_util_pkg.g_as_of_date;
l_temp_date	DATE := NULL;

BEGIN

IF fii_ea_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN

	CASE p_sequence

	WHEN '1' THEN
			l_temp_date := fii_time_api.ent_pqtr_END(fii_time_api.ent_pqtr_END(fii_time_api.ent_pqtr_END(l_asof_date)));
        WHEN '2' THEN
			l_temp_date := fii_time_api.ent_pqtr_END(fii_time_api.ent_pqtr_END(l_asof_date));
	WHEN '3' THEN
			l_temp_date := fii_time_api.ent_pqtr_END(l_asof_date);
	WHEN '4' THEN
			stmt := FND_Message.get_string('FII', 'FII_QTD');
			RETURN stmt;
	ELSE
		RETURN NULL;

        END CASE;

        SELECT name INTO  stmt
        FROM fii_time_ent_qtr
        WHERE l_temp_date = END_date;



ELSIF fii_ea_util_pkg.g_page_period_type = 'FII_TIME_ENT_QTR' THEN

	CASE p_sequence

	WHEN '1' THEN
			l_temp_date := fii_time_api.ent_pper_END(fii_time_api.ent_pper_END(fii_time_api.ent_pper_END(l_asof_date)));
        WHEN '2' THEN
			l_temp_date := fii_time_api.ent_pper_END(fii_time_api.ent_pper_END(l_asof_date));
	WHEN '3' THEN
			l_temp_date := fii_time_api.ent_pper_END(l_asof_date);
	WHEN '4' THEN
			stmt := FND_Message.get_string('FII', 'FII_MTD');
			RETURN stmt;
	ELSE
		RETURN NULL;

        END CASE;

        SELECT name INTO  stmt
        FROM fii_time_ent_period
        WHERE l_temp_date = END_date;

  ELSE
	RETURN NULL;

END IF;

RETURN stmt;

END get_rolling_period_label;

FUNCTION get_com_name RETURN VARCHAR2
IS
l_industry       VARCHAR2(10);
l_company_name   VARCHAR2(2000);

BEGIN

l_industry := fnd_profile.value('INDUSTRY');

IF l_industry = 'G' THEN
   l_company_name := fnd_message.get_string('FII','FII_DIM_FUND');
ELSE
   l_company_name := fnd_message.get_string('FII','FII_DIM_COMPANY');
END IF;

RETURN l_company_name;

END get_com_name;


-- Added as part of bug 4099419..this procedure checks if category and fud1 parameter chosen are leaf nodes

PROCEDURE check_if_leaf(p_id IN NUMBER) IS

BEGIN

IF g_view_by = 'FII_COMPANIES+FII_COMPANIES' THEN
	SELECT  is_leaf_flag INTO g_company_is_leaf
        FROM    fii_company_hierarchies
        WHERE   parent_company_id = p_id
		and parent_company_id = child_company_id;

ELSIF g_view_by = 'ORGANIZATION+HRI_CL_ORGCC' THEN
	SELECT  is_leaf_flag INTO g_cost_center_is_leaf
        FROM    fii_cost_ctr_hierarchies
        WHERE   parent_cc_id = p_id
		and parent_cc_id = child_cc_id;

ELSIF g_view_by = 'FINANCIAL ITEM+GL_FII_FIN_ITEM' THEN

	g_id := NVL(g_category_id,-9999);

	IF g_fin_cat_top_node_count = 1 or g_fin_cat_top_node_count = 0 THEN
		SELECT	is_leaf_flag INTO g_fin_cat_is_leaf
		FROM	fii_fin_item_leaf_hiers
		WHERE   parent_fin_cat_id = p_id
			and parent_fin_cat_id = child_fin_cat_id;
	END IF;

ELSIF g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_1' THEN

	g_id := NVL(g_udd1_id,-9999);

	SELECT	is_leaf_flag INTO g_ud1_is_leaf
	FROM	fii_udd1_hierarchies
	WHERE   parent_value_id = p_id
		and parent_value_id = child_value_id;

ELSIF g_view_by = 'FII_USER_DEFINED+FII_USER_DEFINED_2' THEN
	SELECT	is_leaf_flag INTO g_ud2_is_leaf
	FROM	fii_udd1_hierarchies
	WHERE   parent_value_id = p_id
		and parent_value_id = child_value_id;
END IF;

EXCEPTION
	WHEN OTHERS THEN
	NULL;

END check_if_leaf;

PROCEDURE Bind_Variable (p_sqlstmt IN Varchar2,
                         p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                         p_sql_output OUT NOCOPY Varchar2,
                         p_bind_output_table OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

l_bind_rec BIS_QUERY_ATTRIBUTES;

BEGIN

       p_bind_output_table := BIS_QUERY_ATTRIBUTES_TBL();
       l_bind_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
       p_sql_output := p_sqlstmt;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
       l_bind_rec.attribute_value := g_view_by;
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PREVIOUS_ASOF_DATE';
       l_bind_rec.attribute_value := to_char(g_previous_asof_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ASOF_DATE';
       l_bind_rec.attribute_value := to_char(g_as_of_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

/* Bug 4439400: Added ASOF_BUD_DATE and PREVIOUS_BUD_ASOF_DATE */
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':BUD_ASOF_DATE';
       l_bind_rec.attribute_value := to_char(g_bud_as_of_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PREVIOUS_BUD_ASOF_DATE';
       l_bind_rec.attribute_value := to_char(g_previous_bud_asof_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':COMPANY_ID';
       l_bind_rec.attribute_value := to_char(g_company_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PARENT_COMPANY_ID';
       l_bind_rec.attribute_value := to_char(g_parent_company_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':TOP_COMPANY_ID';
       l_bind_rec.attribute_value := to_char(g_top_company_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':COST_CENTER_ID';
       l_bind_rec.attribute_value := to_char(g_cost_center_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PARENT_COST_CENTER_ID';
       l_bind_rec.attribute_value := to_char(g_parent_cost_center_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':TOP_COST_CENTER_ID';
       l_bind_rec.attribute_value := to_char(g_top_cost_center_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIN_CATEGORY_ID';
       l_bind_rec.attribute_value := to_char(g_fin_category_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PARENT_FIN_CATEGORY_ID';
       l_bind_rec.attribute_value := to_char(g_parent_fin_category_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FUD1_ID';
       l_bind_rec.attribute_value := to_char(g_fud1_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PARENT_FUD1_ID';
       l_bind_rec.attribute_value := to_char(g_parent_fud1_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':TOP_FUD1_ID';
       l_bind_rec.attribute_value := to_char(g_top_fud1_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FUD2_ID';
       l_bind_rec.attribute_value := to_char(g_fud2_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PARENT_FUD2_ID';
       l_bind_rec.attribute_value := to_char(g_parent_fud2_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':TOP_FUD2_ID';
       l_bind_rec.attribute_value := to_char(g_top_fud2_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':LEDGER_ID';
       l_bind_rec.attribute_value := to_char(g_ledger_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_VIEW';
       l_bind_rec.attribute_value := to_char(g_curr_view);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURRENCY';
       l_bind_rec.attribute_value := to_char(g_currency);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ACTUAL_BITAND';
       l_bind_rec.attribute_value := to_char(g_actual_bitand);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

        p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':HIST_ACTUAL_BITAND';
       l_bind_rec.attribute_value := to_char(g_hist_actual_bitand);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':BUDGET_BITAND';
       l_bind_rec.attribute_value := to_char(g_budget_bitand);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':HIST_BUDGET_BITAND';
       l_bind_rec.attribute_value := to_char(g_hist_budget_bitand);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FORECAST_BITAND';
       l_bind_rec.attribute_value := to_char(g_forecast_bitand);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PREVIOUS_ONE_END_DATE';
       l_bind_rec.attribute_value := to_char(g_previous_one_END_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PREVIOUS_TWO_END_DATE';
       l_bind_rec.attribute_value := to_char(g_previous_two_END_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PREVIOUS_THREE_END_DATE';
       l_bind_rec.attribute_value := to_char(g_previous_three_END_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':YEAR_ID';
       l_bind_rec.attribute_value := to_char(g_year_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PRIOR_YEAR_ID';
       l_bind_rec.attribute_value := to_char(g_prior_year_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':COAID';
       l_bind_rec.attribute_value := to_char(g_coaid);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':SOURCE_GROUP';
       l_bind_rec.attribute_value := to_char(g_je_source_group);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PERIOD_SET_NAME';
       l_bind_rec.attribute_value := to_char(g_period_set_name);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ACCOUNTED_PERIOD_TYPE';
       l_bind_rec.attribute_value := to_char(g_accounted_period_type);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':UNASSIGNED_ID';
       l_bind_rec.attribute_value := to_char(g_unassigned_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_PERIOD_START';
       l_bind_rec.attribute_value := to_char(g_curr_per_start, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_PERIOD_END';
       l_bind_rec.attribute_value := to_char(g_curr_per_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PRIOR_PERIOD_START';
       l_bind_rec.attribute_value := to_char(g_prior_per_start, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PRIOR_PERIOD_END';
       l_bind_rec.attribute_value := to_char(g_prior_per_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_MONTH_START';
       l_bind_rec.attribute_value := to_char(g_curr_month_start, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':BOUNDARY_END';
       l_bind_rec.attribute_value := to_char(g_boundary_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PRIOR_BOUNDARY_END';
       l_bind_rec.attribute_value := to_char(g_prior_boundary_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':AMOUNT_TYPE_BITAND';
       l_bind_rec.attribute_value := to_char(g_amount_type_bitand);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':DIR_MSG';
       l_bind_rec.attribute_value := to_char(g_dir_msg);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':SD_PRIOR';
       l_bind_rec.attribute_value := to_char(g_sd_prior, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':SD_PRIOR_PRIOR';
       l_bind_rec.attribute_value := to_char(g_sd_prior_prior, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':MIN_CAT_ID';
       l_bind_rec.attribute_value := to_char(g_min_cat_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':G_ID';
       l_bind_rec.attribute_value := to_char(g_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':TIME_ID';
       l_bind_rec.attribute_value := to_char(g_time_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CATEGORY_ID';
       l_bind_rec.attribute_value := to_char(g_category_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':UDD1_ID';
       l_bind_rec.attribute_value := to_char(g_udd1_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':DISPLAY_SEQUENCE';
       l_bind_rec.attribute_value := to_char(g_display_sequence);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;


       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_PERIOD_START_ID';
       l_bind_rec.attribute_value := to_char(g_curr_per_start_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ASOF_DATE_ID';
       l_bind_rec.attribute_value := to_char(g_as_of_date_id);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

	-- Added for P&L Analysis
       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIVE_YR_BACK';
       l_bind_rec.attribute_value := to_char(g_five_yr_back, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PY_SAME_DAY';
       l_bind_rec.attribute_value := to_char(g_py_sday, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':P_EXP_ASOF';
       l_bind_rec.attribute_value := to_char(g_exp_asof_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;


       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CY_PERIOD_END';
       l_bind_rec.attribute_value := to_char(g_cy_period_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ENT_PYR_END';
       l_bind_rec.attribute_value := to_char(g_ent_pyr_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
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
       l_bind_rec.attribute_name := ':WHERE_PERIOD_TYPE';
       l_bind_rec.attribute_value := to_char(g_where_period_type);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':ENT_CYR_END';
       l_bind_rec.attribute_value := to_char(g_ent_cyr_end, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':CURR_EFFECTIVE_SEQ';
       l_bind_rec.attribute_value := to_char(g_curr_per_sequence);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':PERIOD_TYPE';
       l_bind_rec.attribute_value := to_char(g_period_type);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':P_EXP_START';
       l_bind_rec.attribute_value := to_char(g_exp_start, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':P_EXP_BEGIN';
       l_bind_rec.attribute_value := to_char(g_exp_begin_date, 'DD/MM/YYYY');
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

       p_bind_output_table.EXTEND;
       l_bind_rec.attribute_name := ':FIN_TYPE';
       l_bind_rec.attribute_value := to_char(g_fin_type);
       l_bind_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
       l_bind_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
       p_bind_output_table(p_bind_output_table.COUNT) := l_bind_rec;

END bind_variable;

END fii_ea_util_pkg;

/
