--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_UTIL_PARAM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_UTIL_PARAM" AS
/* $Header: hrioputp.pkb 120.8 2005/12/20 06:08:48 jtitmas noship $ */

/* TYPE HRI_PMV_PARAM_REC_TYPE defined in package header */

/* Return character */
  g_rtn    VARCHAR2(30) := '
';

/******************************************************************************/
/* Checks whether a restricting parameter value is passed in                  */
/******************************************************************************/
FUNCTION is_parameter_set(p_parameter_value_id  IN VARCHAR2)
        RETURN BOOLEAN IS

BEGIN

/* Checks for NULL (no value) or All (all values) */
  IF (p_parameter_value_id IS NOT NULL AND
      p_parameter_value_id <> '''-1''' AND
      p_parameter_value_id <> '-1') THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;

END is_parameter_set;


/******************************************************************************/
/* Adds required parameters to the table of bind values                       */
/******************************************************************************/
PROCEDURE fill_in_bind_table
 (p_parameter_rec    IN OUT NOCOPY HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab         IN OUT NOCOPY HRI_PMV_BIND_TAB_TYPE) IS

  l_low_band_buckets_tab   hri_mtdt_dim_lvl.dim_lvl_buckets_tabtype;
  l_wkth_wktyp_bind        VARCHAR2(240);

BEGIN

/* Add the time dates to the binds table */
  p_bind_tab('TIME_CURR_START_DATE').pmv_bind_string :=
         hri_mtdt_param.g_param_mtdt_tab
          ('TIME_CURR_START_DATE').pmv_bind_string;
  p_bind_tab('TIME_CURR_START_DATE').sql_bind_string :=
'to_date(''' || to_char(p_parameter_rec.time_curr_start_date,'DD-MM-YYYY') || ''',''DD-MM-YYYY'')';

  p_bind_tab('TIME_CURR_END_DATE').pmv_bind_string :=
         hri_mtdt_param.g_param_mtdt_tab
          ('TIME_CURR_END_DATE').pmv_bind_string;
  p_bind_tab('TIME_CURR_END_DATE').sql_bind_string :=
'to_date(''' || to_char(p_parameter_rec.time_curr_end_date,'DD-MM-YYYY') || ''',''DD-MM-YYYY'')';

  p_bind_tab('TIME_CURR_ASOF_DATE').pmv_bind_string :=
         hri_mtdt_param.g_param_mtdt_tab
          ('TIME_CURR_ASOF_DATE').pmv_bind_string;
  p_bind_tab('TIME_CURR_ASOF_DATE').sql_bind_string :=
'to_date(''' || to_char(p_parameter_rec.time_curr_end_date,'DD-MM-YYYY') || ''',''DD-MM-YYYY'')';

  p_bind_tab('TIME_COMP_START_DATE').pmv_bind_string :=
         hri_mtdt_param.g_param_mtdt_tab
          ('TIME_COMP_START_DATE').pmv_bind_string;
  p_bind_tab('TIME_COMP_START_DATE').sql_bind_string :=
'to_date(''' || to_char(p_parameter_rec.time_comp_start_date,'DD-MM-YYYY') || ''',''DD-MM-YYYY'')';

  p_bind_tab('TIME_COMP_END_DATE').pmv_bind_string :=
         hri_mtdt_param.g_param_mtdt_tab
          ('TIME_COMP_END_DATE').pmv_bind_string;
  p_bind_tab('TIME_COMP_END_DATE').sql_bind_string :=
'to_date(''' || to_char(p_parameter_rec.time_comp_end_date,'DD-MM-YYYY') || ''',''DD-MM-YYYY'')';

  p_bind_tab('TIME_COMP_ASOF_DATE').pmv_bind_string :=
         hri_mtdt_param.g_param_mtdt_tab
          ('TIME_COMP_ASOF_DATE').pmv_bind_string;
  p_bind_tab('TIME_COMP_ASOF_DATE').sql_bind_string :=
'to_date(''' || to_char(p_parameter_rec.time_comp_end_date,'DD-MM-YYYY') || ''',''DD-MM-YYYY'')';

/* Add currency binds to bind table, if set */
  IF (p_parameter_rec.currency_code IS NOT NULL) THEN
    p_bind_tab('CURRENCY').pmv_bind_string :=
       hri_mtdt_param.g_param_mtdt_tab('CURRENCY').pmv_bind_string;
    p_bind_tab('CURRENCY').sql_bind_string := '''' || p_parameter_rec.currency_code || '''';
    p_bind_tab('RATE_TYPE').pmv_bind_string :=
       hri_mtdt_param.g_param_mtdt_tab('RATE_TYPE').pmv_bind_string;
    p_bind_tab('RATE_TYPE').sql_bind_string := '''' || p_parameter_rec.rate_type || '''';
  END IF;

/* Defaulting required parameters for bug 4134385
   usually due to the FND_USER not being assigned a Employee */
 IF NOT p_bind_tab.EXISTS('HRI_PERSON+HRI_PER_USRDR_H') THEN
     p_parameter_rec.peo_supervisor_id := '-1';
     p_bind_tab('HRI_PERSON+HRI_PER_USRDR_H').pmv_bind_string := '-1';
     p_bind_tab('HRI_PERSON+HRI_PER_USRDR_H').sql_bind_string := '-1';
 END IF;

/* Get worker type bind */
  l_wkth_wktyp_bind := hri_mtdt_ak_region.get_ak_region_wkth_wktyp
                        (p_ak_region_code => p_parameter_rec.bis_region_code);

/* Add worker type bind if set */
  IF (is_parameter_set(l_wkth_wktyp_bind)) THEN
    p_parameter_rec.wkth_wktyp_sk_fk := l_wkth_wktyp_bind;
    p_bind_tab('HRI_PRSNTYP+HRI_WKTH_WKTYP').pmv_bind_string :=
                  '''' || l_wkth_wktyp_bind || '''';
    p_bind_tab('HRI_PRSNTYP+HRI_WKTH_WKTYP').sql_bind_string :=
                  '''' || l_wkth_wktyp_bind || '''';
  END IF;

END fill_in_bind_table;


/******************************************************************************/
/* Reads parameter table and populates the parameter record and bind table    */
/******************************************************************************/
PROCEDURE get_parameters_from_table
           (p_page_parameter_tbl   IN BIS_PMV_PAGE_PARAMETER_TBL,
            p_parameter_rec        OUT NOCOPY HRI_PMV_PARAM_REC_TYPE,
            p_bind_tab             OUT NOCOPY HRI_PMV_BIND_TAB_TYPE) IS

  l_add_to_bind_table    BOOLEAN;
  l_currency_id          VARCHAR2(240);

BEGIN

/* Default the page period type */
  p_parameter_rec.page_period_type := 'DEFAULT';

/* Loop through the parameters passed in */
  FOR i IN p_page_parameter_tbl.FIRST..p_page_parameter_tbl.LAST LOOP

  /* Reset flag */
    l_add_to_bind_table := FALSE;

/******************************************************************************/
/* PMV Attributes */
/******************/

  /* Get the BIS region code */
    IF p_page_parameter_tbl(i).parameter_name = 'BIS_REGION_CODE' THEN
      p_parameter_rec.bis_region_code := p_page_parameter_tbl(i).parameter_value;

/******************************************************************************/
/* Report Display Parameters */
/*****************************/

  /* Get the ORDER BY string */
    ELSIF p_page_parameter_tbl(i).parameter_name = 'ORDERBY' THEN
      p_parameter_rec.order_by := p_page_parameter_tbl(i).parameter_value;

  /* Get the view by dimension */
    ELSIF p_page_parameter_tbl(i).parameter_name = 'VIEW_BY' THEN
      p_parameter_rec.view_by := p_page_parameter_tbl(i).parameter_value;

/******************************************************************************/
/* Report Data Parameters */
/**************************/

/* Central Parameters */
/**********************/

  /* Checks for time dimension */
    ELSIF substr(p_page_parameter_tbl(i).parameter_name, 1, 5) = 'TIME+' THEN

    /* Get the comparison period start date */
      IF p_page_parameter_tbl(i).parameter_name='TIME+FII_ROLLING_YEAR_PFROM' THEN
        p_parameter_rec.time_comp_start_date := p_page_parameter_tbl(i).period_date;
      ELSIF p_page_parameter_tbl(i).parameter_name='TIME+FII_ROLLING_MONTH_PFROM' THEN
        p_parameter_rec.time_comp_start_date := p_page_parameter_tbl(i).period_date;
      ELSIF p_page_parameter_tbl(i).parameter_name='TIME+FII_ROLLING_WEEK_PFROM' THEN
        p_parameter_rec.time_comp_start_date := p_page_parameter_tbl(i).period_date;
      ELSIF p_page_parameter_tbl(i).parameter_name='TIME+FII_ROLLING_QTR_PFROM' THEN
        p_parameter_rec.time_comp_start_date := p_page_parameter_tbl(i).period_date;

    /* Get the comparison period end date */
      ELSIF p_page_parameter_tbl(i).parameter_name='TIME+FII_ROLLING_YEAR_PTO' THEN
        p_parameter_rec.time_comp_end_date := p_page_parameter_tbl(i).period_date;
      ELSIF p_page_parameter_tbl(i).parameter_name='TIME+FII_ROLLING_MONTH_PTO' THEN
        p_parameter_rec.time_comp_end_date := p_page_parameter_tbl(i).period_date;
      ELSIF p_page_parameter_tbl(i).parameter_name='TIME+FII_ROLLING_WEEK_PTO' THEN
        p_parameter_rec.time_comp_end_date := p_page_parameter_tbl(i).period_date;
      ELSIF p_page_parameter_tbl(i).parameter_name='TIME+FII_ROLLING_QTR_PTO' THEN
        p_parameter_rec.time_comp_end_date := p_page_parameter_tbl(i).period_date;

    /* Get the current period start date */
      ELSIF p_page_parameter_tbl(i).parameter_name='TIME+FII_ROLLING_YEAR_FROM' THEN
        p_parameter_rec.time_curr_start_date := p_page_parameter_tbl(i).period_date;
      ELSIF p_page_parameter_tbl(i).parameter_name='TIME+FII_ROLLING_MONTH_FROM' THEN
        p_parameter_rec.time_curr_start_date  := p_page_parameter_tbl(i).period_date;
      ELSIF p_page_parameter_tbl(i).parameter_name='TIME+FII_ROLLING_WEEK_FROM' THEN
        p_parameter_rec.time_curr_start_date  := p_page_parameter_tbl(i).period_date;
      ELSIF p_page_parameter_tbl(i).parameter_name='TIME+FII_ROLLING_QTR_FROM' THEN
        p_parameter_rec.time_curr_start_date  := p_page_parameter_tbl(i).period_date;
      END IF;

  /* Get the current period end date */
    ELSIF p_page_parameter_tbl(i).parameter_name='AS_OF_DATE' THEN
      p_parameter_rec.time_curr_end_date :=
                   to_date(p_page_parameter_tbl(i).parameter_value,'DD-MM-YYYY');

  /* Get the page_period_type */
    ELSIF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
      p_parameter_rec.page_period_type := p_page_parameter_tbl(i).parameter_value;
      l_add_to_bind_table := TRUE;

  /* Get the time_comparison_type */
    ELSIF p_page_parameter_tbl(i).parameter_name = 'TIME_COMPARISON_TYPE' THEN
      p_parameter_rec.time_comparison_type := p_page_parameter_tbl(i).parameter_value;
      l_add_to_bind_table := TRUE;

   /* Get the currency and rate type */
    ELSIF p_page_parameter_tbl(i).parameter_name = 'CURRENCY+FII_CURRENCIES' THEN

      l_currency_id := ltrim(rtrim(p_page_parameter_tbl(i).parameter_id,''''),'''');

      IF l_currency_id = 'FII_GLOBAL1' THEN
        p_parameter_rec.currency_code := bis_common_parameters.get_currency_code;
        p_parameter_rec.rate_type := bis_common_parameters.get_rate_type;
      ELSIF l_currency_id = 'FII_GLOBAL2' THEN
        p_parameter_rec.currency_code := bis_common_parameters.get_secondary_currency_code;
        p_parameter_rec.rate_type := bis_common_parameters.get_secondary_rate_type;
      END IF;

  /* Get the top supervisor id */
    ELSIF p_page_parameter_tbl(i).parameter_name='HRI_PERSON+HRI_PER_USRDR_H' THEN
      p_parameter_rec.peo_supervisor_id :=
                   ltrim(rtrim(p_page_parameter_tbl(i).parameter_id,''''),'''');
      IF is_parameter_set(p_page_parameter_tbl(i).parameter_id) THEN
        l_add_to_bind_table := TRUE;
      END IF;

/* HRI Parameters */
/**********************/

  /* Get the supervisor rollup type */
    ELSIF p_page_parameter_tbl(i).parameter_name = 'HRI_PRSNDMGR+HRI_PDG_GENDER_X' THEN
      p_parameter_rec.peo_sup_rollup_flag :=
                   ltrim(rtrim(p_page_parameter_tbl(i).parameter_id,''''),'''');
    /* If All (no parameter value selected) is passed then default to Yes (rollup) */
      IF (p_parameter_rec.peo_sup_rollup_flag IS NULL OR
          p_parameter_rec.peo_sup_rollup_flag = '-1') THEN
        p_parameter_rec.peo_sup_rollup_flag := 'Y';
      END IF;

  /* Checks for separation type */
    ELSIF p_page_parameter_tbl(i).parameter_name = 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X' THEN
      p_parameter_rec.event_sep_type :=
                 ltrim(rtrim(p_page_parameter_tbl(i).parameter_id,''''),'''');
      IF is_parameter_set(p_page_parameter_tbl(i).parameter_id) THEN
        l_add_to_bind_table := TRUE;
      END IF;

  /* Checks for worker type */
    ELSIF (substr(p_page_parameter_tbl(i).parameter_name, 1, 12) = 'HRI_PRSNTYP+') THEN
      p_parameter_rec.wkth_wktyp_sk_fk :=
                  ltrim(rtrim(p_page_parameter_tbl(i).parameter_id,''''),'''');
      IF is_parameter_set(p_page_parameter_tbl(i).parameter_id) THEN
        p_bind_tab(p_page_parameter_tbl(i).parameter_name).pmv_bind_string :=
           '''' || p_parameter_rec.wkth_wktyp_sk_fk || '''';
        p_bind_tab(p_page_parameter_tbl(i).parameter_name).sql_bind_string :=
           '''' || p_parameter_rec.wkth_wktyp_sk_fk || '''';
      END IF;

-- START OF NEW ABSENCE PARAMETERS
  /* Checks for Absence Duration UOM */
    ELSIF p_page_parameter_tbl(i).parameter_name = 'HRI_ABSNC_M+HRI_ABSNC_M_DRTN_UOM' THEN
      p_parameter_rec.absence_duration_uom :=
                 ltrim(rtrim(p_page_parameter_tbl(i).parameter_id,''''),'''');
      IF is_parameter_set(p_page_parameter_tbl(i).parameter_id) THEN
        l_add_to_bind_table := TRUE;
      END IF;

  /* Checks for Absence Category */
    ELSIF p_page_parameter_tbl(i).parameter_name = 'HRI_ABSNC+HRI_ABSNC_CAT' THEN
      p_parameter_rec.absence_category :=
                 ltrim(rtrim(p_page_parameter_tbl(i).parameter_id,''''),'''');
      IF is_parameter_set(p_page_parameter_tbl(i).parameter_id) THEN
        l_add_to_bind_table := TRUE;
      END IF;


  /* Checks for Absence Type */
    ELSIF p_page_parameter_tbl(i).parameter_name = 'HRI_ABSNC+HRI_ABSNC_TYP' THEN
      p_parameter_rec.absence_type :=
                 ltrim(rtrim(p_page_parameter_tbl(i).parameter_id,''''),'''');
      IF is_parameter_set(p_page_parameter_tbl(i).parameter_id) THEN
        l_add_to_bind_table := TRUE;
      END IF;


  /* Checks for Absence Reason */
    ELSIF p_page_parameter_tbl(i).parameter_name = 'HRI_ABSNC+HRI_ABSNC_RSN' THEN
      p_parameter_rec.absence_reason :=
                 ltrim(rtrim(p_page_parameter_tbl(i).parameter_id,''''),'''');
      IF is_parameter_set(p_page_parameter_tbl(i).parameter_id) THEN
        l_add_to_bind_table := TRUE;
      END IF;

-- END OF NEW ABSENCE PARAMETERS

/* Multi-select dimension levels */
/*********************************/

    ELSIF (substr(p_page_parameter_tbl(i).parameter_name, 1, 10) = 'GEOGRAPHY+'
        OR substr(p_page_parameter_tbl(i).parameter_name, 1,  4) = 'JOB+'
        OR p_page_parameter_tbl(i).parameter_name = 'HRI_LOW+HRI_LOW_BAND_X'
        OR p_page_parameter_tbl(i).parameter_name = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X'
        OR p_page_parameter_tbl(i).parameter_name = 'HRI_REASON+HRI_RSN_SEP_X') THEN
      IF is_parameter_set(p_page_parameter_tbl(i).parameter_id) THEN
        l_add_to_bind_table := TRUE;
      END IF;

    END IF;

  /* Add the parameter information to the debug output */
    p_parameter_rec.debug_header := p_parameter_rec.debug_header || '-- ' ||
                          p_page_parameter_tbl(i).parameter_name || ':  ' ||
                          p_page_parameter_tbl(i).parameter_id || ' -> ' ||
                          p_page_parameter_tbl(i).parameter_value || g_rtn;

  /* Add the parameter details to the parameter table if the parameter is set */
    IF l_add_to_bind_table THEN
      p_bind_tab(p_page_parameter_tbl(i).parameter_name).pmv_bind_string :=
         hri_mtdt_param.g_param_mtdt_tab
          (p_page_parameter_tbl(i).parameter_name).pmv_bind_string;
      p_bind_tab(p_page_parameter_tbl(i).parameter_name).sql_bind_string :=
         p_page_parameter_tbl(i).parameter_id;
    END IF;

  END LOOP;

/* Add required parameters to bind table */
  fill_in_bind_table
   (p_parameter_rec => p_parameter_rec,
    p_bind_tab => p_bind_tab);

/* Add FND_GLOBAL variables we depend on in DBI to the debug header */
 p_parameter_rec.debug_header := p_parameter_rec.debug_header || '-- ' ||
                        'FND_GLOBAL.EMPLOYEE_ID: ' || FND_GLOBAL.EMPLOYEE_ID || g_rtn;

END get_parameters_from_table;

END hri_oltp_pmv_util_param;

/
