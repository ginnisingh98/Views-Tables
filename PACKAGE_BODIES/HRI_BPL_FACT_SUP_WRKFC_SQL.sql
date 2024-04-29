--------------------------------------------------------
--  DDL for Package Body HRI_BPL_FACT_SUP_WRKFC_SQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_FACT_SUP_WRKFC_SQL" AS
/* $Header: hribfwrk.pkb 120.6 2006/09/13 08:47:45 rkonduru noship $ */

TYPE g_bind_rec_tab_type IS TABLE OF VARCHAR2(32000) INDEX BY VARCHAR2(80);

-- Table of bind strings in required format
g_binds                  g_bind_rec_tab_type;
g_binds_reset            g_bind_rec_tab_type;

-- Templates for SELECT columns
g_template_standard      VARCHAR2(1000);
g_template_bucket        VARCHAR2(1000);
g_template_total         VARCHAR2(1000);
g_template_total_bucket  VARCHAR2(1000);

g_rtn                    VARCHAR2(30) := '
';

/******************************************************************************/
/* Package Design                                                             */
/* ==============                                                             */
/*                                                                            */
/* [Search for SELECT|FROM|WHERE|BIND to find procedures and functions that   */
/*  impact the respective parts of the SQL returned]                          */
/*                                                                            */
/* SELECT                                                                     */
/* ------                                                                     */
/* For details of the SELECT column list see package header                   */
/*                                                                            */
/* Note: Snapshot MVs have a different column format and are handled by       */
/*       a different set of functions                                         */
/*                                                                            */
/* All columns have one of a few standard formats. Global variables store     */
/* templates for these formats with tags in for swapping in and out parts     */
/* of the template (such as measure column, bucket column, bucket value)      */
/*                                                                            */
/* The columns in the select clause are controlled by various fields in the   */
/* input parameter record p_wrkfc_params:                                     */
/*   - include_hdc: headcount measures will be added to SELECT columns        */
/*   - include_sal: salary measures will be added to SELECT columns           */
/*   - include_low: length of work measures will be added to SELECT columns   */
/*                                                                            */
/* All selected measure columns will be sampled at the effective date.        */
/* Additionally the following fields in the same input parameter record       */
/* control sampling at other dates:                                           */
/*   - include_comp: all measures are sampled at comparison period end date   */
/*   - include_start: all affected measures are sampled at period start dates */
/*                                                                            */
/* Currently only headcount is affected by include_start.                     */
/*                                                                            */
/* If a bucket dimension is specified then all measures will be sampled for   */
/* each date for each bucket value (in addition to the values across all      */
/* buckets).                                                                  */
/*   - bucket_dim: all measures are sampled for all buckets of dimension      */
/*                                                                            */
/* FROM/WHERE                                                                 */
/* ----------                                                                 */
/* The FROM and WHERE clauses are separate depending on whether or not        */
/* the report is view by manager.                                             */
/*                                                                            */
/* The fact table is chosen based on the parameters selected in the PMV       */
/* report in the function set_fact_table. If snapshotting is available the    */
/* corresponding snapshot fact will be selected.                              */
/*                                                                            */
/* The parameters selected in the PMV report are analysed in the function     */
/* analyze_parameters. A condition is added to the WHERE clause for each      */
/* PMV report parameter that is set.                                          */
/*                                                                            */
/* VIEW BY                                                                    */
/* -------                                                                    */
/* The view by grouping is controlled by the parameter passed in by PMV. If   */
/* view by manager is selected then an additional level of the supervisor     */
/* hierarchy is brought in so that the result set is grouped by the top       */
/* manager's direct reports UNLESS in the input parameter record              */
/* p_wrkfc_params the following field is set:                                 */
/*   - kpi_mode: groups by top manager instead of their direct reports when   */
/*               view by of manager is selected                               */
/*                                                                            */
/* Binds                                                                      */
/* -----                                                                      */
/* Bind values are passed in using the p_bind_tab parameter. Depending on the */
/* bind format selected the corresponding bind strings are populated into the */
/* global g_binds table. Bind values are then substituted into the SQL from   */
/* this global throughout the package.                                        */
/*   - bind_format:  SQL (direct substitution) or PMV (run time substitution) */
/*                                                                            */
/******************************************************************************/


/******************************************************************************/
/* Initialization of global variables - called once at package initialization */
/*                                                                            */
/* Templates for the SELECT columns are set with tags to represent the parts  */
/* which vary.                                                                */
/******************************************************************************/
PROCEDURE initialize_globals IS

BEGIN

/* Define generic select column */
  g_template_standard :=
'SUM(CASE WHEN effective_date = <date_bind>
 THEN <measure_column>
 ELSE 0
END)';

/* Define generic bucket select column */
  g_template_bucket :=
'SUM(CASE WHEN effective_date = <date_bind>
 AND <bucket_column> = <bucket_id>
 THEN <measure_column>
 ELSE 0
END)';

/* Define generic total column */
  g_template_total :=
'SUM(CASE WHEN effective_date = <date_bind>
 AND direct_ind = 1
 THEN <measure_column>
 ELSE 0
END)';

/* Define generic total bucket column */
  g_template_total_bucket :=
'SUM(CASE WHEN effective_date = <date_bind>
 AND <bucket_column> = <bucket_id>
 AND direct_ind = 1
 THEN <measure_column>
 ELSE 0
END)';

END initialize_globals;


/******************************************************************************/
/* Populates g_binds with the selected BIND format                            */
/******************************************************************************/
PROCEDURE populate_global_bind_table
  (p_bind_tab     IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
   p_bind_format  IN VARCHAR2) IS

  l_parameter_name   VARCHAR2(100);

BEGIN

/* Initialize all parameters to be used */
  g_binds := g_binds_reset;
  g_binds('CURRENCY') := NULL;
  g_binds('RATE_TYPE') := NULL;
  g_binds('TIME_CURR_END_DATE') := NULL;
  g_binds('TIME_COMP_END_DATE') := NULL;
  g_binds('TIME_CURR_START_DATE') := NULL;
  g_binds('TIME_COMP_START_DATE') := NULL;

  l_parameter_name := p_bind_tab.FIRST;

  WHILE (l_parameter_name IS NOT NULL) LOOP

    IF (p_bind_format = 'SQL') THEN
      g_binds(l_parameter_name) := p_bind_tab(l_parameter_name).sql_bind_string;
    ELSIF (p_bind_format = 'PMV') THEN
      g_binds(l_parameter_name) := p_bind_tab(l_parameter_name).pmv_bind_string;
    ELSE
      g_binds(l_parameter_name) := l_parameter_name;
    END IF;

    l_parameter_name := p_bind_tab.NEXT(l_parameter_name);

  END LOOP;

END populate_global_bind_table;


/******************************************************************************/
/* Wraps the measure with the conversion function call                        */
/******************************************************************************/
FUNCTION add_conv_func(p_measure    IN VARCHAR2)
    RETURN VARCHAR2 IS

BEGIN

  RETURN
'hri_oltp_view_currency.convert_currency_amount' || g_rtn ||
' (wrkfc.anl_slry_currency' || g_rtn ||
' ,' || g_binds('CURRENCY') || g_rtn ||
' ,' || g_binds('TIME_CURR_END_DATE') || g_rtn ||
' ,' || p_measure || g_rtn ||
' ,' || g_binds('RATE_TYPE') || ')';

END add_conv_func;

/******************************************************************************/
/* Sets up a string with a list of dates to sample the fact.                  */
/*                                                                            */
/* The end date of the current period is always sampled. Additional dates are */
/* sampled depending on the value of the following parameters:                */
/*   p_wrkfc_params.include_comp   - Include the comparison period            */
/*   p_wrkfc_params.include_start  - Sample the start dates of each period    */
/******************************************************************************/
PROCEDURE set_date_list
       (p_wrkfc_params   IN wrkfc_fact_param_type,
        p_date_list      OUT NOCOPY VARCHAR2) IS

BEGIN

/* Always sample the effective date */
  p_date_list := g_binds('TIME_CURR_END_DATE');

/* Set date list for sampling workforce values */
  IF (p_wrkfc_params.include_comp = 'Y') THEN
    p_date_list := p_date_list || ', ' || g_binds('TIME_COMP_END_DATE');
    IF (p_wrkfc_params.include_start = 'Y') THEN
      p_date_list := p_date_list || ', ' || g_binds('TIME_CURR_START_DATE') || ' - 1';
      p_date_list := p_date_list || ', ' || g_binds('TIME_COMP_START_DATE') || ' - 1';
    END IF;
  ELSIF (p_wrkfc_params.include_start = 'Y') THEN
    p_date_list := p_date_list || ', ' || g_binds('TIME_CURR_START_DATE') || ' - 1';
  END IF;

END set_date_list;


/******************************************************************************/
/* For every report parameter that is set, a condition is added to the WHERE  */
/* clause.                                                                    */
/*                                                                            */
/* Also to help with deciding which fact table to use in the FROM clause, a   */
/* count is kept of the number of parameters that are set. If only one        */
/* parameter is set the name of that parameter is returned. This helps select */
/* the most efficient fact to retrieve the data from.                         */
/******************************************************************************/
PROCEDURE analyze_parameters
 (p_bind_tab         IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_fact_conditions  OUT NOCOPY VARCHAR2,
  p_parameter_count  OUT NOCOPY PLS_INTEGER,
  p_single_param     OUT NOCOPY VARCHAR2) IS

  l_single_param     VARCHAR2(100);
  l_parameter_name   VARCHAR2(100);

BEGIN

/* Initialize parameter count */
  p_parameter_count := 0;

/* Loop through parameters that have been set */
  l_parameter_name := p_bind_tab.FIRST;

  WHILE (l_parameter_name IS NOT NULL) LOOP
    IF (l_parameter_name = 'GEOGRAPHY+COUNTRY' OR
        l_parameter_name = 'GEOGRAPHY+AREA' OR
        l_parameter_name = 'JOB+JOB_FAMILY' OR
        l_parameter_name = 'JOB+JOB_FUNCTION' OR
        l_parameter_name = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
        l_parameter_name = 'HRI_PRSNTYP+HRI_WKTH_WKTYP' OR
        l_parameter_name = 'HRI_LOW+HRI_LOW_BAND_X') THEN

    /* Dynamically set conditions for parameter */
      p_fact_conditions := p_fact_conditions || g_rtn ||
        'AND wrkfc.' ||
        hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
               (l_parameter_name).fact_viewby_col ||
        ' IN (' || g_binds(l_parameter_name) || ')';

    /* Keep count of parameters set and last parameter used */
    /* Do not count person type as this is a global parameter */
      IF (l_parameter_name <> 'HRI_PRSNTYP+HRI_WKTH_WKTYP') THEN
        p_parameter_count := p_parameter_count + 1;
        l_single_param := l_parameter_name;
      END IF;

    END IF;

  /* Move to next parameter */
    l_parameter_name := p_bind_tab.NEXT(l_parameter_name);
  END LOOP;

/* Only pass back parameter name if there is only one parameter */
  IF (p_parameter_count = 1) THEN
    p_single_param := l_single_param;
  END IF;

END analyze_parameters;


/******************************************************************************/
/* Decide which fact to use in the main FROM clause based on                  */
/*   - number of parameters applied                                           */
/*   - viewby                                                                 */
/*   - buckets                                                                */
/*   - whether a snapshot fact table is available                             */
/*                                                                            */
/* If a fact table is selected that does not have a snapshot available then   */
/* p_use_snapshot is set accordingly                                          */
/******************************************************************************/
PROCEDURE set_fact_table
 (p_parameter_rec   IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bucket_dim      IN VARCHAR2,
  p_include_sal     IN VARCHAR2,
  p_parameter_count IN PLS_INTEGER,
  p_single_param    IN VARCHAR2,
  p_use_snapshot    IN OUT NOCOPY BOOLEAN,
  p_fact_table      OUT NOCOPY VARCHAR2) IS

/* Fact for headcount/low only for the supervisor dimension level */
  l_wrkfc_sup_table    VARCHAR2(30);

/* Fact corresponding to the single parameter dimension level */
  l_wrkfc_prm_table    VARCHAR2(30);

/* Fact corresponding to the view by dimension level */
  l_wrkfc_vby_table    VARCHAR2(30);

/* Fact corresponding to the bucket dimension level */
  l_wrkfc_bkt_table    VARCHAR2(30);

/* Fact to use if more than one dimension is required */
  l_wrkfc_pvt_table    VARCHAR2(30);

/* Return variables */
  l_fact_table         VARCHAR2(30);

/* Bucket dimension */
  l_bucket_dim         VARCHAR2(240);

BEGIN

/* If p_bucket_dim is person type discount it for determining the */
/* fact table to use since person type is on every fact */
  IF (p_bucket_dim = 'HRI_PRSNTYP+HRI_WKTH_WKTYP') THEN
    l_bucket_dim := NULL;
  ELSE
    l_bucket_dim := p_bucket_dim;
  END IF;

/* Check whether a snapshot is available for the given top manager if called */
/* for the first time */
  IF (p_use_snapshot IS NULL) THEN
    p_use_snapshot := hri_oltp_pmv_util_snpsht.use_wrkfc_snpsht_for_mgr
                       (p_supervisor_id => p_parameter_rec.peo_supervisor_id,
                        p_effective_date => p_parameter_rec.time_curr_end_date);

  END IF;

/*----------------------------------------------------------------------------*/
/* Set up the local variables with the following fact tables:                 */
/*   l_wrkfc_sup_table:  Supervisor level fact without currency in grain      */
/*   l_wrkfc_prm_table:  Fact corresponding to the single parameter level     */
/*   l_wrkfc_bkt_table:  Fact corresponding to the bucket dimension level     */
/*   l_wrkfc_vby_table:  Fact corresponding to the view by dimension level    */
/*   l_wrkfc_pvt_table:  Fact containing all dimension levels                 */
/*                                                                            */
/* For example, if the following PMV parameters have been passed in:          */
/*   VIEW BY:         GEOGRAPHY+COUNTRY                                       */
/*   JOB+JOB_FAMILY:  DEVELOPMENT (single parameter set)                      */
/*                                                                            */
/* and the following control parameters are:                                  */
/*   bucket_dim:      HRI_LOW+HRI_LOW_BAND_X                                  */
/*   p_use_snapshot:  N                                                       */
/*                                                                            */
/* Then the local variables would be set as follows:                          */
/*   l_wrkfc_sup_table:  HRI_MDP_SUP_WCNT_SUP_MV                              */
/*   l_wrkfc_prm_table:  HRI_MDP_SUP_WRKFC_JFM_MV                             */
/*   l_wrkfc_bkt_table:  HRI_MDP_SUP_WRKFC_E_MV                               */
/*   l_wrkfc_vby_table:  HRI_MDP_SUP_WRKFC_CTR_MV                             */
/*   l_wrkfc_pvt_table:  HRI_MDP_SUP_WRKFC_CJER_MV                            */
/*                                                                            */
/*----------------------------------------------------------------------------*/

/* Set the local variables for which fact table to use based on whether */
/* snapshots are available for the given manager or not */
  IF (p_use_snapshot) THEN
    IF (p_single_param IS NOT NULL) THEN
      l_wrkfc_prm_table := hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                            (p_single_param).sup_lvl_wrkfc_mv_snp;
    END IF;
    l_wrkfc_sup_table := 'hri_mds_sup_wmv_sup_mv';
    l_wrkfc_vby_table := hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                          (p_parameter_rec.view_by).sup_lvl_wrkfc_mv_snp;
    l_wrkfc_pvt_table := 'hri_mdp_sup_wrkfc_cjer_mv';

    IF (l_bucket_dim IS NOT NULL) THEN
      l_wrkfc_bkt_table := hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                            (l_bucket_dim).sup_lvl_wrkfc_mv_snp;
    END IF;
  ELSE
    IF (p_single_param IS NOT NULL) THEN
      l_wrkfc_prm_table := hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                            (p_single_param).sup_lvl_wrkfc_mv_name;
    END IF;
    l_wrkfc_sup_table := 'hri_mdp_sup_wcnt_sup_mv';
    l_wrkfc_vby_table := hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                          (p_parameter_rec.view_by).sup_lvl_wrkfc_mv_name;
    l_wrkfc_pvt_table := 'hri_mdp_sup_wrkfc_cjer_mv';

    IF (l_bucket_dim IS NOT NULL) THEN
      l_wrkfc_bkt_table := hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                            (l_bucket_dim).sup_lvl_wrkfc_mv_name;
    END IF;
  END IF;

/*----------------------------------------------------------------------------*/
/* Decide which of the fact tables to return.                                 */
/*                                                                            */
/* The logic goes as follows:                                                 */
/*                                                                            */
/* Parameter Count: 0                                                         */
/* ------------------                                                         */
/* 1) Check whether the supervisor level fact without currency can be used    */
/*    (no parameters, no buckets, no salary, view by manager)                 */
/*                                                                            */
/* 2) Check the fact associated with the view by dimension level              */
/*    (no parameters, no bucket set)                                          */
/*                                                                            */
/* 3) Check the fact associated with the bucket dimension level               */
/*    (no parameters, bucket set, view by manager)                            */
/*                                                                            */
/* 4) Use the pivot fact if bucket is set and view by is not manager          */
/*    (no parameters, bucket set, view by not manager)                        */
/*                                                                            */
/* Parameter Count: > 0                                                       */
/* --------------------                                                       */
/*                                                                            */
/* 5) Check the fact associated with the single parameter                     */
/*    (one parameter, no bucket set, view by manager)                         */
/*                                                                            */
/* 6) Use the pivot fact if one or more parameters and 5) is not met          */
/*                                                                            */
/*----------------------------------------------------------------------------*/

/* If no parameters are supplied use the viewby or bucket dimension table */
  IF (p_parameter_count = 0) THEN
    IF (l_bucket_dim IS NULL) THEN
      IF (p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H' AND
          p_include_sal = 'N') THEN
/* 1) no parameters, no buckets, no salary, view by manager */
        l_fact_table := l_wrkfc_sup_table;
      ELSE
/* 2) no parameters, no bucket set */
        l_fact_table := l_wrkfc_vby_table;
      END IF;
    ELSIF (p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H') THEN
/* 3) no parameters, bucket set, view by manager */
      l_fact_table := l_wrkfc_bkt_table;
    ELSE
/* 4) no parameters, bucket set, view by not manager */
      l_fact_table := l_wrkfc_pvt_table;

    /* Since the pivot table does not have the snapshot option */
      p_use_snapshot := FALSE;
    END IF;

/* If parameters are supplied from a single table, viewby is person and no */
/* bucket dimension is selected then use the parameter table */
  ELSIF (p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H' AND
         l_bucket_dim IS NULL AND
         p_parameter_count = 1) THEN
/* 5) one parameter, no bucket set, view by manager */
    l_fact_table := l_wrkfc_prm_table;

/* Otherwise use the lowest level table with all dimensions */
  ELSE
/* 6) No other options */
    l_fact_table := l_wrkfc_pvt_table;

  /* Since the pivot table does not have the snapshot option */
    p_use_snapshot := FALSE;

  END IF;

/* Not all snapshots are available, so check that a table has been found */
  IF (p_use_snapshot AND
      l_fact_table IS NULL) THEN
  /* No snapshot found - turn snapshots off and retry */
    p_use_snapshot := FALSE;

  /* Call procedure again without using snapshots */
    set_fact_table
     (p_parameter_rec   => p_parameter_rec,
      p_bucket_dim      => l_bucket_dim,
      p_include_sal     => p_include_sal,
      p_parameter_count => p_parameter_count,
      p_single_param    => p_single_param,
      p_use_snapshot    => p_use_snapshot,
      p_fact_table      => l_fact_table);

  END IF;

/* Set the fact table */
  p_fact_table := l_fact_table;

END set_fact_table;


/******************************************************************************/
/* Replaces tags in a SELECT column template and formats it with an alias     */
/******************************************************************************/
FUNCTION format_column(p_column_string  IN VARCHAR2,
                       p_date_bind      IN VARCHAR2,
                       p_bucket_id      IN VARCHAR2,
                       p_column_alias   IN VARCHAR2)
    RETURN VARCHAR2 IS

  l_column_string   VARCHAR2(1000);

BEGIN

/* Replace the bucket identifier */
  l_column_string := REPLACE(p_column_string, '<bucket_id>', p_bucket_id);

/* Replace the date bind */
  l_column_string := REPLACE(l_column_string, '<date_bind>', p_date_bind);

/* Format the column string */
  l_column_string := ','  || l_column_string || '  ' || p_column_alias || g_rtn;

  RETURN l_column_string;

END format_column;


/******************************************************************************/
/* This function returns a list of columns to be added to the SELECT clause   */
/* for a given measure. The input fields contain the templates to use for     */
/* the measure SELECT columns and various control fields.                     */
/*                                                                            */
/* The following fields control sampling across different dates               */
/*   - include_comp: the measure is sampled at comparison period end date     */
/*   - include_start: the measure is sampled at period start dates            */
/*                                                                            */
/* If a bucket dimension is specified then all measures will be sampled for   */
/* each date for each bucket value (in addition to the values across all      */
/* buckets).                                                                  */
/*   - bucket_dim: the measures is sampled for all buckets of dimension       */
/*                                                                            */
/******************************************************************************/
FUNCTION build_columns
    (p_parameter_rec    IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
     p_wrkfc_total      IN VARCHAR2,
     p_include_comp     IN VARCHAR2,
     p_include_start    IN VARCHAR2,
     p_bucket_dim       IN VARCHAR2,
     p_select_template  IN VARCHAR2,
     p_bucket_template  IN VARCHAR2,
     p_measure_alias    IN VARCHAR2)
   RETURN VARCHAR2 IS

  l_column_list       VARCHAR2(5000);
  l_bucket_condition  VARCHAR2(1000);
  l_bucket_tab        hri_mtdt_dim_lvl.dim_lvl_buckets_tabtype;

/* Column Templates */
  l_select_column     VARCHAR2(1000);
  l_bucket_column     VARCHAR2(1000);

BEGIN

/* Replace the measure tags in the column templates */
  l_select_column := REPLACE(p_select_template, '<measure_column>', p_measure_alias);
  l_bucket_column := REPLACE(p_bucket_template, '<measure_column>', p_measure_alias);

/* Check and add columns for current period start */
  IF (p_include_start = 'Y') THEN
    l_column_list := l_column_list || format_column
     (p_column_string => l_select_column
     ,p_date_bind     => g_binds('TIME_CURR_START_DATE') || ' - 1'
     ,p_bucket_id     => NULL
     ,p_column_alias  => 'curr_' || p_measure_alias || '_start');
  END IF;

/* Check and add columns for current period end */
  IF (p_wrkfc_total = 'N') THEN
    l_column_list := l_column_list || format_column
       (p_column_string => l_select_column
       ,p_date_bind     => g_binds('TIME_CURR_END_DATE')
       ,p_bucket_id     => NULL
       ,p_column_alias  => 'curr_' || p_measure_alias || '_end');
  END IF;

/* Check and add columns for comparison period start */
  IF (p_include_comp = 'Y' AND
      p_include_start = 'Y') THEN
    l_column_list := l_column_list || format_column
     (p_column_string => l_select_column
     ,p_date_bind     => g_binds('TIME_COMP_START_DATE') || ' - 1'
     ,p_bucket_id     => NULL
     ,p_column_alias  => 'comp_' || p_measure_alias || '_start');
  END IF;

/* Check and add columns for comparison period end */
  IF (p_include_comp = 'Y') THEN
    l_column_list := l_column_list || format_column
     (p_column_string => l_select_column
     ,p_date_bind     => g_binds('TIME_COMP_END_DATE')
     ,p_bucket_id     => NULL
     ,p_column_alias  => 'comp_' || p_measure_alias || '_end');
  END IF;

/* Add columns for the bucket dimension values if required */
  IF (p_bucket_dim IS NOT NULL) THEN

  /* Get a pl/sql table containing the bucket ids for the given */
  /* bucket dimension */
    IF (p_bucket_dim = 'HRI_LOW+HRI_LOW_BAND_X') THEN
      hri_mtdt_dim_lvl.set_low_band_buckets(p_parameter_rec.wkth_wktyp_sk_fk);
      l_bucket_tab := hri_mtdt_dim_lvl.g_low_band_buckets_tab;
    ELSIF (p_bucket_dim = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X') THEN
      l_bucket_tab := hri_mtdt_dim_lvl.g_prfmnc_band_buckets_tab;
    ELSIF (p_bucket_dim = 'JOB+PRIMARY_JOB_ROLE') THEN
      l_bucket_tab := hri_mtdt_dim_lvl.g_primary_job_role_tab;
    ELSIF (p_bucket_dim = 'HRI_PRSNTYP+HRI_WKTH_WKTYP') THEN
      l_bucket_tab := hri_mtdt_dim_lvl.g_wkth_wktyp_tab;
    END IF;

  /* Loop through bucket ids to add required columns */
    FOR i IN l_bucket_tab.FIRST..l_bucket_tab.LAST LOOP

    /* Add the current period column for the bucket */
      IF (p_wrkfc_total = 'N') THEN
        l_column_list := l_column_list || format_column
           (p_column_string => l_bucket_column
           ,p_date_bind     => g_binds('TIME_CURR_END_DATE')
           ,p_bucket_id     => l_bucket_tab(i).bucket_id_string
           ,p_column_alias  => 'curr_' || p_measure_alias || '_' ||
                               l_bucket_tab(i).bucket_name);
      END IF;

    /* Add the comparison period column for the bucket */
      IF (p_include_comp = 'Y') THEN
        l_column_list := l_column_list || format_column
         (p_column_string => l_bucket_column
         ,p_date_bind     => g_binds('TIME_COMP_END_DATE')
         ,p_bucket_id     => l_bucket_tab(i).bucket_id_string
         ,p_column_alias  => 'comp_' || p_measure_alias || '_' ||
                             l_bucket_tab(i).bucket_name);
      END IF;

    END LOOP;

  END IF;

  RETURN l_column_list;

END build_columns;


/******************************************************************************/
/* Returns a string containing columns to be added to the outer SELECT clause */
/* for the given measure.                                                     */
/******************************************************************************/
FUNCTION add_outer_measure_columns
 (p_parameter_rec       IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_wrkfc_params        IN wrkfc_fact_param_type,
  p_view_by_manager     IN BOOLEAN,
  p_sample_start_dates  IN VARCHAR2,
  p_measure_alias       IN VARCHAR2)
    RETURN VARCHAR2 IS

/* Column Templates */
  l_template_bucket        VARCHAR2(1000);
  l_template_total         VARCHAR2(1000);
  l_template_total_bucket  VARCHAR2(1000);

/* Whether to calculate measure value at start of period */
  l_include_start          VARCHAR2(30);

/* Return column list */
  l_column_list            VARCHAR2(10000);

BEGIN

/* Check for view by manager special case */
  IF (p_view_by_manager) THEN
    l_template_total_bucket := g_template_total_bucket;
    l_template_total := g_template_total;
  ELSE
    l_template_total_bucket := g_template_bucket;
    l_template_total := g_template_standard;
  END IF;

/* Set bucket column if applicable */
  IF (p_wrkfc_params.bucket_dim IS NOT NULL) THEN
    l_template_bucket := REPLACE(g_template_bucket, '<bucket_column>',
                               hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                                 (p_wrkfc_params.bucket_dim).fact_viewby_col);
    l_template_total_bucket := REPLACE(l_template_total_bucket, '<bucket_column>',
                                     hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                                       (p_wrkfc_params.bucket_dim).fact_viewby_col);
  END IF;

/* Set whether or not to sample the measure value at period start dates */
  IF (p_sample_start_dates = 'Y') THEN
    l_include_start := p_wrkfc_params.include_start;
  ELSE
    l_include_start := 'N';
  END IF;

/* Add measure columns and total columns for the given measure */
  l_column_list := build_columns
      (p_parameter_rec   => p_parameter_rec,
       p_wrkfc_total     => 'N',
       p_include_comp    => p_wrkfc_params.include_comp,
       p_include_start   => l_include_start,
       p_bucket_dim      => p_wrkfc_params.bucket_dim,
       p_select_template => g_template_standard,
       p_bucket_template => l_template_bucket,
       p_measure_alias   => p_measure_alias)
                || build_columns
      (p_parameter_rec   => p_parameter_rec,
       p_wrkfc_total     => 'Y',
       p_include_comp    => p_wrkfc_params.include_comp,
       p_include_start   => l_include_start,
       p_bucket_dim      => p_wrkfc_params.bucket_dim,
       p_select_template => l_template_total,
       p_bucket_template => l_template_total_bucket,
       p_measure_alias   => 'total_' || p_measure_alias);

  RETURN l_column_list;

END add_outer_measure_columns;


/******************************************************************************/
/* Returns the final SQL statement for the PMV report.                        */
/*                                                                            */
/* The SQL returned is in the format:                                         */
/*                                                                            */
/* SELECT -- outer                                                            */
/*  Grouping column (view by)                                                 */
/*  Specific measure columns, including totals and                            */
/*  sampling across different dates and buckets                               */
/* FROM                                                                       */
/* (SELECT -- inner                                                           */
/*   Raw measure columns, including function calls                            */
/*   e.g. to convert currency                                                 */
/*  FROM                                                                      */
/*   Fact table                                                               */
/*   Time dimension                                                           */
/*  WHERE                                                                     */
/*   Apply parameters corresponding to user selection                         */
/*   in the PMV report                                                        */
/*   Join to time dimension sampling all dates required                       */
/*  )                                                                         */
/* GROUP BY                                                                   */
/*  Grouping column (view by)                                                 */
/*                                                                            */
/* SELECT                                                                     */
/* ======                                                                     */
/* Calls build_columns for each measure selected to build up the SELECT       */
/* clause.                                                                    */
/*                                                                            */
/* For details of the SELECT column list see package header                   */
/*                                                                            */
/* FROM/WHERE                                                                 */
/* ==========                                                                 */
/* Puts together the FROM/WHERE clauses depending on whether the view by      */
/* manager special case is selected.                                          */
/******************************************************************************/
FUNCTION build_sql
  (p_parameter_rec    IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
   p_wrkfc_params     IN wrkfc_fact_param_type,
   p_fact_table       IN VARCHAR2,
   p_date_list        IN VARCHAR2,
   p_fact_conditions  IN VARCHAR2)
      RETURN VARCHAR2 IS

/* Whether to format the SQL for the view by manager special case */
  l_view_by_manager        BOOLEAN;

/* Dynamic SQL columns */
/***********************/
/* Select */
  l_direct_ind             VARCHAR2(100);
  l_inner_col_list         VARCHAR2(10000);
  l_outer_col_list         VARCHAR2(10000);

/* From / Where */
  l_inner_from             VARCHAR2(10000);

/* Measure columns */
  l_hdc_col                VARCHAR2(1000);
  l_sal_col                VARCHAR2(1000);
  l_low_col                VARCHAR2(1000);
  l_total_hdc_col          VARCHAR2(1000);
  l_total_sal_col          VARCHAR2(1000);
  l_pasg_cnt_col           VARCHAR2(1000);
  l_total_low_col          VARCHAR2(100);

/* Return string */
  l_sql_string           VARCHAR2(32767);

BEGIN

/******************************************************************************/
/* INITIALIZATION */
/******************/

/* Check for view by manager special case */
  IF (p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H' AND
      p_wrkfc_params.kpi_mode = 'N') THEN
    l_view_by_manager := TRUE;
  ELSE
    l_view_by_manager := FALSE;
  END IF;

/* Set total columns, which do not depend on the view by manager special case */
  l_total_hdc_col := 'wrkfc.total_headcount';

  l_total_sal_col :=
'hri_oltp_view_currency.convert_currency_amount' || g_rtn ||
' (wrkfc.anl_slry_currency' || g_rtn ||
' ,' || g_binds('CURRENCY') || g_rtn ||
' ,' || g_binds('TIME_CURR_END_DATE') || g_rtn ||
' ,wrkfc.total_anl_slry' || g_rtn ||
' ,' || g_binds('RATE_TYPE') || ')';

  l_total_low_col := 'wrkfc.total_primary_asg_pow + (wrkfc.total_primary_asg_cnt * ' ||
                     '(cal.id - wrkfc.effective_start_date))';

/* Set dynamic SQL based on view by (manager special case for non-KPI reports) */
  IF (l_view_by_manager) THEN

/******************************************************************************/
/* VIEW BY MANAGER SPECIAL CASE */
/********************************/

    l_direct_ind := '1 - suph.sub_relative_level';

    l_hdc_col := 'DECODE(suph.sub_relative_level,' ||
                         ' 0, wrkfc.direct_headcount,' ||
                       ' wrkfc.total_headcount)';
    l_sal_col := add_conv_func('DECODE(suph.sub_relative_level,' ||
                               '  0, wrkfc.direct_anl_slry,' ||
                               'wrkfc.total_anl_slry)');

    l_low_col := 'DECODE(suph.sub_relative_level,' || g_rtn ||
                 '   0, wrkfc.direct_primary_asg_pow + (wrkfc.direct_primary_asg_cnt * ' ||
                       '(cal.id - wrkfc.effective_start_date)),' || g_rtn ||
                 ' wrkfc.total_primary_asg_pow + (wrkfc.total_primary_asg_cnt * ' ||
                  '(cal.id - wrkfc.effective_start_date)))';

  /* FROM CLAUSE */
  /***************/
    l_inner_from :=
' fii_time_day_v  cal,
 hri_cs_suph   suph,
 ' || p_fact_table || '  wrkfc
WHERE cal.id IN (' || p_date_list || ')
AND cal.id BETWEEN wrkfc.effective_start_date ' ||
          'AND wrkfc.effective_end_date
AND ' || g_binds('TIME_CURR_END_DATE') || ' BETWEEN suph.effective_start_date ' ||
                                           'AND suph.effective_end_date
AND suph.sup_person_id = ' || g_binds('HRI_PERSON+HRI_PER_USRDR_H') || '
AND suph.sub_person_id = wrkfc.supervisor_person_id
AND suph.sub_invalid_flag_code = ''N''
AND suph.sub_relative_level <= 1' ||
 p_fact_conditions;

  ELSE

/******************************************************************************/
/* GENERIC (OTHER VIEW BYs) */
/****************************/

    l_direct_ind := '0';
    l_hdc_col := 'wrkfc.total_headcount';
    /* Added because of Bug 5461651 */
    l_pasg_cnt_col := 'wrkfc.total_primary_asg_cnt';
    l_sal_col :=
'hri_oltp_view_currency.convert_currency_amount' || g_rtn ||
' (wrkfc.anl_slry_currency' || g_rtn ||
' ,' || g_binds('CURRENCY') || g_rtn ||
' ,' || g_binds('TIME_CURR_END_DATE') || g_rtn ||
' ,wrkfc.total_anl_slry' || g_rtn ||
' ,' || g_binds('RATE_TYPE') || ')';

    l_low_col := 'wrkfc.total_primary_asg_pow + (wrkfc.total_primary_asg_cnt * ' ||
                   '(cal.id - wrkfc.effective_start_date))';

  /* FROM CLAUSE */
  /***************/
    l_inner_from :=
' fii_time_day_v  cal,
 ' ||  p_fact_table || '  wrkfc
WHERE cal.id IN (' || p_date_list || ')
AND cal.id BETWEEN wrkfc.effective_start_date ' ||
          'AND wrkfc.effective_end_date
AND wrkfc.supervisor_person_id = ' || g_binds('HRI_PERSON+HRI_PER_USRDR_H') ||
  p_fact_conditions;

  END IF;

/* SELECT CLAUSE */
/*****************/

/* Add bucket column to select clause if applicable */
  IF (p_wrkfc_params.bucket_dim IS NOT NULL) THEN
    l_inner_col_list := l_inner_col_list || ',' ||
                        hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                          (p_wrkfc_params.bucket_dim).fact_viewby_col || g_rtn;
  END IF;

/* Build up SELECT column list */
  IF (p_wrkfc_params.include_hdc = 'Y') THEN

    l_inner_col_list := l_inner_col_list ||
',' || l_hdc_col       || '  hdc'       || g_rtn ||
',' || l_total_hdc_col || '  total_hdc' || g_rtn;

    l_outer_col_list := l_outer_col_list ||
           add_outer_measure_columns
            (p_parameter_rec => p_parameter_rec,
             p_wrkfc_params  => p_wrkfc_params,
             p_view_by_manager => l_view_by_manager,
             p_sample_start_dates => 'Y',
             p_measure_alias => 'hdc');
  END IF;

/* Build up SELECT column list */
  IF (p_wrkfc_params.include_sal = 'Y') THEN

    l_inner_col_list := l_inner_col_list ||
',' || l_sal_col       || '  sal'       || g_rtn  ||
',' || l_total_sal_col || '  total_sal' || g_rtn;

    l_outer_col_list := l_outer_col_list ||
           add_outer_measure_columns
            (p_parameter_rec => p_parameter_rec,
             p_wrkfc_params  => p_wrkfc_params,
             p_view_by_manager => l_view_by_manager,
             p_sample_start_dates => 'N',
             p_measure_alias => 'sal');

  END IF;

/* Build up SELECT column list */
  IF (p_wrkfc_params.include_low = 'Y') THEN

    l_inner_col_list := l_inner_col_list ||
',' || l_low_col       || '  low'       || g_rtn ||
',' || l_total_low_col || '  total_low' || g_rtn;

    l_outer_col_list := l_outer_col_list ||
           add_outer_measure_columns
            (p_parameter_rec => p_parameter_rec,
             p_wrkfc_params  => p_wrkfc_params,
             p_view_by_manager => l_view_by_manager,
             p_sample_start_dates => 'N',
             p_measure_alias => 'low');

  END IF;
/* Added because of Bug 5461651 */
 /* Build up SELECT column list */

  IF (p_wrkfc_params.include_pasg_cnt = 'Y') THEN

    l_inner_col_list := l_inner_col_list ||
',' || l_pasg_cnt_col       || '  pasg_cnt'       || g_rtn ||
',' || l_pasg_cnt_col       || '  total_pasg_cnt'       || g_rtn;

    l_outer_col_list := l_outer_col_list ||
           add_outer_measure_columns
            (p_parameter_rec => p_parameter_rec,
             p_wrkfc_params  => p_wrkfc_params,
             p_view_by_manager => l_view_by_manager,
             p_sample_start_dates => 'N',
             p_measure_alias => 'pasg_cnt');
  END IF;

/* BUILD UP SQL STATEMENT */
/**************************/

  l_sql_string :=
'SELECT /*+ NO_MERGE */
 vby_id
,direct_ind' || g_rtn ||
/* Dynamically built column list */
 l_outer_col_list ||
'FROM (
  SELECT /*+ ORDERED INDEX(wrkfc) */
   ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
          (p_parameter_rec.view_by).fact_viewby_col || '  vby_id
  ,cal.id  effective_date
  ,' || l_direct_ind || '  direct_ind ' || g_rtn ||
   l_inner_col_list ||
'  FROM ' || g_rtn ||
   l_inner_from || '
)
GROUP BY
 vby_id
,direct_ind';

  RETURN l_sql_string;

END build_sql;


/******************************************************************************/
/* This function returns a list of columns to be added to the SELECT clause   */
/* for a given measure using snapshot fact. Analgous to build_columns         */
/******************************************************************************/
FUNCTION build_columns_snp
   (p_sample_start_dates  IN VARCHAR2,
    p_include_comp        IN VARCHAR2,
    p_measure_code        IN VARCHAR2,
    p_measure_alias       IN VARCHAR2,
    p_column_template     IN VARCHAR2,
    p_total_template      IN VARCHAR2,
    p_bucket_template     IN VARCHAR2,
    p_bucket_dim          IN VARCHAR2,
    p_bucket_tab          IN hri_mtdt_dim_lvl.dim_lvl_buckets_tabtype)
        RETURN VARCHAR2 IS

  l_col_list      VARCHAR2(10000);

BEGIN

/*****************/
/* Total Columns */
/*****************/

-- Add previous period end total
  l_col_list := l_col_list ||
',SUM(' || REPLACE(p_total_template,
                   '<total_measure>', 'wrkfc.comp_total_' || p_measure_code || '_end') || ')  ' ||
                           'comp_total_' || p_measure_alias || '_end' || g_rtn;

-- Add current and previous period start totals
  IF (p_sample_start_dates = 'Y') THEN
    l_col_list := l_col_list ||
',SUM(' || REPLACE(p_total_template,
                   '<total_measure>', 'wrkfc.comp_total_' || p_measure_code || '_start') || ')  ' ||
                           'comp_total_' || p_measure_alias || '_start
,SUM(' || REPLACE(p_total_template,
                   '<total_measure>', 'wrkfc.curr_total_' || p_measure_code || '_start') || ')  ' ||
                           'curr_total_' || p_measure_alias || '_start' || g_rtn;
  END IF;

/*******************/
/* Measure Columns */
/*******************/

-- Add current and previous period end measures
  l_col_list := l_col_list ||
',SUM(' || REPLACE(REPLACE(p_column_template,
                  '<total_measure>', 'wrkfc.curr_total_' || p_measure_code || '_end'),
          '<direct_measure>', 'wrkfc.curr_direct_' || p_measure_code || '_end') ||
   ')  curr_' || p_measure_alias || '_end
,SUM(' || REPLACE(REPLACE(p_column_template,
                  '<total_measure>', 'wrkfc.comp_total_' || p_measure_code || '_end'),
          '<direct_measure>', 'wrkfc.comp_direct_' || p_measure_code || '_end') ||
   ')  comp_' || p_measure_alias || '_end' || g_rtn;

-- Add current and previous period start measures
  IF (p_sample_start_dates = 'Y') THEN
    l_col_list := l_col_list ||
',SUM(' || REPLACE(REPLACE(p_column_template,
                  '<total_measure>', 'wrkfc.curr_total_' || p_measure_code || '_start'),
          '<direct_measure>', 'wrkfc.curr_direct_' || p_measure_code || '_start') ||
   ')  curr_' || p_measure_alias || '_start
,SUM(' || REPLACE(REPLACE(p_column_template,
                  '<total_measure>', 'wrkfc.comp_total_' || p_measure_code || '_start'),
          '<direct_measure>', 'wrkfc.comp_direct_' || p_measure_code || '_start') ||
   ')  comp_' || p_measure_alias || '_start' || g_rtn;
  END IF;

/******************/
/* Bucket Columns */
/******************/
  IF (p_bucket_dim IS NOT NULL) THEN

  /* Loop through bucket ids to add required columns */
    FOR i IN p_bucket_tab.FIRST..p_bucket_tab.LAST LOOP

  l_col_list := l_col_list ||
',SUM(' ||
  REPLACE(REPLACE(REPLACE(p_bucket_template,
                  '<total_measure>', 'wrkfc.curr_total_' || p_measure_code || '_end'),
          '<direct_measure>', 'wrkfc.curr_direct_' || p_measure_code || '_end'),
  '<bucket_id>', p_bucket_tab(i).bucket_id_string) ||
   ')  curr_' || p_measure_alias || '_' || p_bucket_tab(i).bucket_name || g_rtn;

    /* Add the comparison period column for the bucket */
      IF (p_include_comp = 'Y') THEN

  l_col_list := l_col_list ||
',SUM(' ||
  REPLACE(REPLACE(REPLACE(p_bucket_template,
                  '<total_measure>', 'wrkfc.comp_total_' || p_measure_code || '_end'),
          '<direct_measure>', 'wrkfc.comp_direct_' || p_measure_code || '_end'),
  '<bucket_id>', p_bucket_tab(i).bucket_id_string) ||
   ')  comp_' || p_measure_alias || '_' || p_bucket_tab(i).bucket_name || g_rtn;

      END IF;

    END LOOP;

  END IF;

  RETURN l_col_list;

END build_columns_snp;

/******************************************************************************/
/* Returns the final SQL statement for the PMV report.                        */
/*                                                                            */
/* The SQL returned is in the format:                                         */
/*                                                                            */
/* SELECT                                                                     */
/*  Grouping column (view by)                                                 */
/*  Specific measure columns, including totals and                            */
/*  sampling across different dates and buckets                               */
/* FROM                                                                       */
/*  Fact table                                                                */
/*  Time dimension                                                            */
/*  Supervisor table (if view by manager and non-kpi report)                  */
/* WHERE                                                                      */
/*  Apply parameters corresponding to user selection                          */
/*  in the PMV report                                                         */
/*  Join to time dimension sampling all dates required                        */
/* GROUP BY                                                                   */
/*  Grouping column (view by)                                                 */
/*                                                                            */
/* SELECT                                                                     */
/* ======                                                                     */
/* Adds columns for each measure selected to build up the SELECT clause       */
/*                                                                            */
/* For details of the SELECT column list see package header                   */
/*                                                                            */
/* FROM/WHERE                                                                 */
/* ==========                                                                 */
/* Puts together the FROM/WHERE clauses depending on whether the view by      */
/* manager special case is selected.                                          */
/******************************************************************************/
FUNCTION build_sql_snp
  (p_parameter_rec    IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
   p_wrkfc_params     IN wrkfc_fact_param_type,
   p_fact_table       IN VARCHAR2,
   p_date_list        IN VARCHAR2,
   p_fact_conditions  IN VARCHAR2)
      RETURN VARCHAR2 IS

/* Whether to format the SQL for the view by manager special case */
  l_view_by_manager      BOOLEAN;

/* Table of bucket values */
  l_bucket_tab           hri_mtdt_dim_lvl.dim_lvl_buckets_tabtype;

/* Column templates */
  l_column_template      VARCHAR2(1000);
  l_total_template       VARCHAR2(1000);
  l_bucket_template      VARCHAR2(1000);

/* Dynamic SQL columns */
/***********************/
/* Select */
  l_direct_ind           VARCHAR2(100);
  l_col_list             VARCHAR2(10000);
  l_from_clause          VARCHAR2(100);
  l_where_clause         VARCHAR2(10000);

/* Return string */
  l_sql_string           VARCHAR2(32767);

BEGIN

/******************************************************************************/
/* INITIALIZATION */
/******************/

/* Check for view by manager special case */
  IF (p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H' AND
      p_wrkfc_params.kpi_mode = 'N') THEN
    l_view_by_manager := TRUE;
    l_column_template :=
'DECODE(suph.sub_relative_level,
  0, <direct_measure>,
<total_measure>)';
    l_total_template :=
'DECODE(suph.sub_relative_level,
  0, <total_measure>,
0)';

  ELSE
    l_view_by_manager := FALSE;
    l_column_template := '<total_measure>';
    l_total_template  := '<total_measure>';
  END IF;

/* Set up a table of bucket ids if a bucket dimension is used */
  IF (p_wrkfc_params.bucket_dim IS NOT NULL) THEN

  /* Get a pl/sql table containing the bucket ids for the given */
  /* bucket dimension */
    IF (p_wrkfc_params.bucket_dim = 'HRI_LOW+HRI_LOW_BAND_X') THEN
      hri_mtdt_dim_lvl.set_low_band_buckets(p_parameter_rec.wkth_wktyp_sk_fk);
      l_bucket_tab := hri_mtdt_dim_lvl.g_low_band_buckets_tab;
    ELSIF (p_wrkfc_params.bucket_dim = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X') THEN
      l_bucket_tab := hri_mtdt_dim_lvl.g_prfmnc_band_buckets_tab;
    ELSIF (p_wrkfc_params.bucket_dim = 'JOB+PRIMARY_JOB_ROLE') THEN
      l_bucket_tab := hri_mtdt_dim_lvl.g_primary_job_role_tab;
    ELSIF (p_wrkfc_params.bucket_dim = 'HRI_PRSNTYP+HRI_WKTH_WKTYP') THEN
      l_bucket_tab := hri_mtdt_dim_lvl.g_wkth_wktyp_tab;
    END IF;

    l_bucket_template :=
'CASE WHEN ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                 (p_wrkfc_params.bucket_dim).fact_viewby_col || ' = <bucket_id>
      THEN ' || l_column_template || '
      ELSE 0
 END';

  END IF;

/* Set dynamic SQL based on view by (manager special case for non-KPI reports) */
  IF (l_view_by_manager) THEN

/******************************************************************************/
/* VIEW BY MANAGER SPECIAL CASE */
/********************************/

    l_direct_ind := '1 - suph.sub_relative_level';

    l_from_clause :=
' hri_cs_suph   suph
,' || p_fact_table || '  wrkfc' || g_rtn;

    l_where_clause :=
'AND suph.sup_person_id = ' || g_binds('HRI_PERSON+HRI_PER_USRDR_H') || '
AND suph.sub_person_id = wrkfc.supervisor_person_id
AND wrkfc.effective_date = ' || g_binds('TIME_CURR_END_DATE') || '
AND ' || g_binds('TIME_CURR_END_DATE') || ' BETWEEN suph.effective_start_date ' ||
                                           'AND suph.effective_end_date
AND suph.sub_invalid_flag_code = ''N''
AND suph.sub_relative_level <= 1' || g_rtn;

  ELSE

/******************************************************************************/
/* GENERIC (OTHER VIEW BYs) */
/****************************/

    l_direct_ind := '0';

    l_from_clause := ' ' || p_fact_table || '  wrkfc' || g_rtn;

    l_where_clause :=
'AND wrkfc.supervisor_person_id  = ' || g_binds('HRI_PERSON+HRI_PER_USRDR_H') || g_rtn;

  END IF;

/* SELECT CLAUSE */
/*****************/

/* Build up SELECT column list */
  IF (p_wrkfc_params.include_hdc = 'Y') THEN

    l_col_list := l_col_list || build_columns_snp
                                 (p_sample_start_dates => 'Y',
                                  p_include_comp => p_wrkfc_params.include_comp,
                                  p_measure_code => 'hdc',
                                  p_measure_alias => 'hdc',
                                  p_column_template => l_column_template,
                                  p_total_template => l_total_template,
                                  p_bucket_template => l_bucket_template,
                                  p_bucket_dim => p_wrkfc_params.bucket_dim,
                                  p_bucket_tab => l_bucket_tab);
  END IF;

/* Build up SELECT column list */
  IF (p_wrkfc_params.include_low = 'Y') THEN
    l_col_list := l_col_list || build_columns_snp
                                 (p_sample_start_dates => 'N',
                                  p_include_comp => p_wrkfc_params.include_comp,
                                  p_measure_code => 'pow',
                                  p_measure_alias => 'low',
                                  p_column_template => l_column_template,
                                  p_total_template => l_total_template,
                                  p_bucket_template => l_bucket_template,
                                  p_bucket_dim => p_wrkfc_params.bucket_dim,
                                  p_bucket_tab => l_bucket_tab);
  END IF;

/* Build up SELECT column list */
  IF (p_wrkfc_params.include_sal = 'Y') THEN
    l_col_list := l_col_list || build_columns_snp
                                 (p_sample_start_dates => 'N',
                                  p_include_comp => p_wrkfc_params.include_comp,
                                  p_measure_code => 'anl_slry',
                                  p_measure_alias => 'sal',
                                  p_column_template => add_conv_func(l_column_template),
                                  p_total_template => add_conv_func(l_total_template),
                                  p_bucket_template => add_conv_func(l_bucket_template),
                                  p_bucket_dim => p_wrkfc_params.bucket_dim,
                                  p_bucket_tab => l_bucket_tab);
  END IF;
/* Added because of Bug 5461651 */
/* Build up SELECT column list */
  IF (p_wrkfc_params.include_pasg_cnt = 'Y') THEN
    l_col_list := l_col_list || build_columns_snp
                                 (p_sample_start_dates => 'N',
                                  p_include_comp => p_wrkfc_params.include_comp,
                                  p_measure_code => 'pasg_cnt',
                                  p_measure_alias => 'pasg_cnt',
                                  p_column_template => l_column_template,
                                  p_total_template => l_total_template,
                                  p_bucket_template => l_bucket_template,
                                  p_bucket_dim => p_wrkfc_params.bucket_dim,
                                  p_bucket_tab => l_bucket_tab);
  END IF;
/* BUILD UP SQL STATEMENT */
/**************************/

  l_sql_string :=
'SELECT /*+ NO_MERGE ORDERED INDEX(wrkfc) */
 ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
          (p_parameter_rec.view_by).fact_viewby_col || '  vby_id
,' || l_direct_ind || '  direct_ind' || g_rtn ||
/* Dynamically built column list */
 l_col_list ||
'FROM' || g_rtn ||
 l_from_clause ||
'WHERE wrkfc.effective_date = ' || g_binds('TIME_CURR_END_DATE') || '
AND wrkfc.period_type = &PERIOD_TYPE
AND wrkfc.comparison_type = &TIME_COMPARISON_TYPE' || g_rtn ||
 l_where_clause ||
 p_fact_conditions ||
'GROUP BY
 ' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
          (p_parameter_rec.view_by).fact_viewby_col || '
,' || l_direct_ind;

  RETURN l_sql_string;

END build_sql_snp;

/******************************************************************************/
/* Main entry point, takes PMV parameters and SQL control parameters          */
/* Returns the SQL statement for the PMV report.                              */
/******************************************************************************/
FUNCTION get_sql
 (p_parameter_rec  IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab       IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_wrkfc_params   IN wrkfc_fact_param_type)
     RETURN VARCHAR2 IS

  l_date_list         VARCHAR2(3000);
  l_return_sql        VARCHAR2(32767);
  l_parameter_count   PLS_INTEGER;
  l_single_param      VARCHAR2(100);
  l_fact_table        VARCHAR2(30);
  l_fact_conditions   VARCHAR2(1000);
  l_use_snapshot      BOOLEAN;

BEGIN

/* Populate a global record with the PMV context in the given bind format */
  populate_global_bind_table
   (p_bind_tab    => p_bind_tab,
    p_bind_format => p_wrkfc_params.bind_format);

/* Get list of dates to process (current/previous start/end) */
  set_date_list
   (p_wrkfc_params  => p_wrkfc_params,
    p_date_list     => l_date_list);

/* Put dimension level parameter binds into a string to add to WHERE clause */
/* Return information about the parameters that are set to help decide */
/* which fact/function to use */
  analyze_parameters
   (p_bind_tab        => p_bind_tab,
    p_fact_conditions => l_fact_conditions,
    p_parameter_count => l_parameter_count,
    p_single_param    => l_single_param);

/* Decide which fact table to use */
  set_fact_table
   (p_parameter_rec   => p_parameter_rec,
    p_bucket_dim      => p_wrkfc_params.bucket_dim,
    p_include_sal     => p_wrkfc_params.include_sal,
    p_parameter_count => l_parameter_count,
    p_single_param    => l_single_param,
    p_use_snapshot    => l_use_snapshot,
    p_fact_table      => l_fact_table);

  IF (l_use_snapshot) THEN

/* Build SQL statement using snapshot procedure */
  l_return_sql := build_sql_snp
   (p_parameter_rec   => p_parameter_rec,
    p_wrkfc_params    => p_wrkfc_params,
    p_fact_table      => l_fact_table,
    p_date_list       => l_date_list,
    p_fact_conditions => l_fact_conditions);

  ELSE

/* Build SQL statement using standard procedure */
  l_return_sql := build_sql
   (p_parameter_rec   => p_parameter_rec,
    p_wrkfc_params    => p_wrkfc_params,
    p_fact_table      => l_fact_table,
    p_date_list       => l_date_list,
    p_fact_conditions => l_fact_conditions);

  END IF;

  RETURN l_return_sql;

END get_sql;


/******************************************************************************/
/* Main entry point, takes PMV parameters and SQL control parameters          */
/* Returns the SQL statement for the PMV report.                              */
/* Version with debugging built in                                            */
/******************************************************************************/
FUNCTION get_sql
 (p_parameter_rec   IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab        IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_wrkfc_params    IN wrkfc_fact_param_type,
  p_calling_module  IN VARCHAR2)
     RETURN VARCHAR2 IS

  l_wrkfc_params    wrkfc_fact_param_type;
  l_debug_mode      BOOLEAN := FALSE;
  l_debug_sql       VARCHAR2(32767);

BEGIN

/* If debugging is on log the calling module, parameters and debug sql */
  IF (l_debug_mode) THEN
    l_wrkfc_params := p_wrkfc_params;
    l_wrkfc_params.bind_format := 'SQL';
    l_debug_sql := get_sql
     (p_parameter_rec => p_parameter_rec,
      p_bind_tab      => p_bind_tab,
      p_wrkfc_params  => l_wrkfc_params);
--    call_debug_api(l_debug_sql);
  END IF;

  RETURN get_sql
          (p_parameter_rec => p_parameter_rec,
           p_bind_tab      => p_bind_tab,
           p_wrkfc_params  => p_wrkfc_params);

END get_sql;

/* Initialization - call procedure to set global variables */
BEGIN

  initialize_globals;

END hri_bpl_fact_sup_wrkfc_sql;

/
