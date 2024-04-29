--------------------------------------------------------
--  DDL for Package Body HRI_BPL_FACT_SUP_WCNT_CHG_SQL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_FACT_SUP_WCNT_CHG_SQL" AS
/* $Header: hribfwch.pkb 120.1 2005/06/03 08:06:16 jtitmas noship $ */

TYPE g_bind_rec_tab_type IS TABLE OF VARCHAR2(32000) INDEX BY VARCHAR2(80);

-- Table of bind strings in required format
g_binds                   g_bind_rec_tab_type;
g_binds_reset             g_bind_rec_tab_type;

-- Templates for SELECT columns
g_template_standard       VARCHAR2(1000);
g_template_bucket         VARCHAR2(1000);
g_template_sepcat         VARCHAR2(1000);
g_template_sepcat_bucket  VARCHAR2(1000);

g_rtn                     VARCHAR2(30) := '
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
/* All columns have one of a few standard formats. Global variables store     */
/* templates for these formats with tags in for swapping in and out parts     */
/* of the template (such as measure column, bucket column, bucket value)      */
/*                                                                            */
/* The columns in the select clause are controlled by various fields in the   */
/* input parameter record p_wcnt_chg_params:                                  */
/*   - include_hire:      hire count measures will be added                   */
/*   - include_trin:      transfer in count measures will be added            */
/*   - include_trout:     transfer out count measures will be added           */
/*   - include_term:      terminations count measures will be added           */
/*   - include_sep:       separations will be added                           */
/*   - include_sep_inv:   involuntary separations will be added               */
/*   - include_sep_vol:   voluntary separations will be added                 */
/*   - include_low:       length of work measures will be added               */
/*                                                                            */
/* All selected measure columns will be sampled for the current period.       */
/* Additionally the following fields in the same input parameter record       */
/* control sampling for other periods:                                        */
/*   - include_comp: all measures are sampled for the comparison period       */
/*                                                                            */
/* If a bucket dimension is specified then all measures will be sampled for   */
/* each period for each bucket value (in addition to the values across all    */
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
/* p_wcnt_chg_params the following field is set:                              */
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
PROCEDURE initialize_globals(p_use_snapshot  IN BOOLEAN) IS

BEGIN

  IF p_use_snapshot THEN

/* Define generic select column */
  g_template_standard :=
'SUM(CASE WHEN wcnt.effective_date = <end_date>
 THEN <measure_column>
 ELSE 0
END)';

/* Define generic bucketed select column */
  g_template_bucket :=
'SUM(CASE WHEN wcnt.effective_date = <end_date>
 AND <bucket_column> = <bucket_id>
 THEN <measure_column>
 ELSE 0
END)';

/* Special case separation category columns used for the following MVs */
/*  - hri_mdp_sup_wcnt_term_asg_mv                                     */
  g_template_sepcat :=
'SUM(CASE WHEN wcnt.effective_date = <end_date>
 AND separation_category = <sepcat_id>
 THEN separation_hdc
 ELSE 0
END)';

  g_template_sepcat_bucket :=
'SUM(CASE WHEN wcnt.effective_date = <end_date>
 AND separation_category = <sepcat_id>
 AND <bucket_column> = <bucket_id>
 THEN separation_hdc
 ELSE 0
END)';

  ELSE

/* Define generic select column */
  g_template_standard :=
'SUM(CASE WHEN wcnt.effective_date BETWEEN <start_date> AND <end_date>
 THEN <measure_column>
 ELSE 0
END)';

/* Define generic bucketed select column */
  g_template_bucket :=
'SUM(CASE WHEN wcnt.effective_date BETWEEN <start_date> AND <end_date>
 AND <bucket_column> = <bucket_id>
 THEN <measure_column>
 ELSE 0
END)';

/* Special case separation category columns used for the following MVs */
/*  - hri_mdp_sup_wcnt_term_asg_mv                                     */
  g_template_sepcat :=
'SUM(CASE WHEN wcnt.effective_date BETWEEN <start_date> AND <end_date>
 AND separation_category = <sepcat_id>
 THEN separation_hdc
 ELSE 0
END)';

  g_template_sepcat_bucket :=
'SUM(CASE WHEN wcnt.effective_date BETWEEN <start_date> AND <end_date>
 AND separation_category = <sepcat_id>
 AND <bucket_column> = <bucket_id>
 THEN separation_hdc
 ELSE 0
END)';

  END IF;

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
        l_parameter_name = 'JOB+JOB_FAMILY' OR
        l_parameter_name = 'JOB+JOB_FUNCTION' OR
        l_parameter_name = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X' OR
        l_parameter_name = 'HRI_PRSNTYP+HRI_WKTH_WKTYP' OR
        l_parameter_name = 'HRI_LOW+HRI_LOW_BAND_X' OR
        l_parameter_name = 'HRI_REASON+HRI_RSN_SEP_X' OR
        l_parameter_name = 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X') THEN

    /* Dynamically set conditions for parameter */
      p_fact_conditions := p_fact_conditions ||
        'AND wcnt.' || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                        (l_parameter_name).fact_viewby_col ||
        ' IN (' || g_binds(l_parameter_name) || ')' || g_rtn;

    /* Keep count of parameters set */
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
  p_include_hire    IN VARCHAR2,
  p_include_trin    IN VARCHAR2,
  p_include_trout   IN VARCHAR2,
  p_include_term    IN VARCHAR2,
  p_include_low     IN VARCHAR2,
  p_parameter_count IN PLS_INTEGER,
  p_single_param    IN VARCHAR2,
  p_use_snapshot    IN OUT NOCOPY BOOLEAN,
  p_fact_table      OUT NOCOPY VARCHAR2) IS

  l_wcnt_vby_table   VARCHAR2(30);
  l_wcnt_bkt_table   VARCHAR2(30);
  l_wcnt_prm_table   VARCHAR2(30);

BEGIN

/* Check whether a snapshot is available if called for the first time */
  IF (p_use_snapshot IS NULL) THEN
    p_use_snapshot := hri_oltp_pmv_util_snpsht.use_wcnt_chg_snpsht_for_mgr
                       (p_supervisor_id => p_parameter_rec.peo_supervisor_id,
                        p_effective_date => p_parameter_rec.time_curr_end_date);
  END IF;

/* Split logic for which table to return by snapshot or non-snapshot */
  IF p_use_snapshot THEN

/*----------------------------------------------------------------------------*/
/* Decide which of the fact tables to return.                                 */
/*                                                                            */
/* The logic goes as follows:                                                 */
/*                                                                            */
/* Parameter Count: 0                                                         */
/* ------------------                                                         */
/* 1) Check whether the supervisor level fact can be used                     */
/*    (no parameters, no buckets, no low, view by manager)                    */
/*                                                                            */
/* 2) Check the fact associated with the view by dimension level              */
/*    (no parameters, no bucket set, no hires or transfers                    */
/*                                                                            */
/* 3) Check the fact associated with the bucket dimension level               */
/*    (no parameters, bucket set, view by manager, no hires or transfers      */
/*                                                                            */
/* 4) Otherwise snapshot is not available - call function again for non-      */
/*    snapshot                                                                */
/*----------------------------------------------------------------------------*/

  /* Set the local variables for which fact table to use */
    l_wcnt_vby_table := hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                            (p_parameter_rec.view_by).sup_lvl_wcnt_mv_snp;
    IF p_bucket_dim IS NOT NULL THEN
      l_wcnt_bkt_table := hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                           (p_bucket_dim).sup_lvl_wcnt_mv_snp;
    END IF;
    IF p_single_param IS NOT NULL THEN
      l_wcnt_prm_table := hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                           (p_single_param).sup_lvl_wcnt_mv_snp;
    END IF;

  /* If no parameters are supplied use the viewby or bucket dimension table */
    IF (p_parameter_count = 0) THEN
      IF (p_bucket_dim IS NULL) THEN
        IF (p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H' AND
            p_include_low = 'N') THEN

  /* 1) no parameters, no buckets, no low, view by manager */
          p_fact_table := 'hri_mds_sup_wcnt_chg_mv';

        ELSE

  /* 2) no parameters, no bucket set, view by not manager */
          p_fact_table := l_wcnt_vby_table;

        END IF;

      ELSIF (p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H') THEN

  /* 3) no parameters, bucket set, view by manager */
        p_fact_table := l_wcnt_bkt_table;

      END IF;
    END IF;

    IF (p_fact_table IS NULL) THEN

/* 4) Snapshot not available - call function again for non-snapshot */
      p_use_snapshot := FALSE;
      set_fact_table
       (p_parameter_rec   => p_parameter_rec,
        p_bucket_dim      => p_bucket_dim,
        p_include_hire    => p_include_hire,
        p_include_trin    => p_include_trin,
        p_include_trout   => p_include_trout,
        p_include_term    => p_include_term,
        p_include_low     => p_include_low,
        p_parameter_count => p_parameter_count,
        p_single_param    => p_single_param,
        p_use_snapshot    => p_use_snapshot,
        p_fact_table      => p_fact_table);

    END IF;

  ELSE

/*----------------------------------------------------------------------------*/
/* Decide which fact table to return. The logic for non-snapshots is:         */
/*                                                                            */
/* 1) Check whether the supervisor level change fact can be used              */
/*    (no bucket, no length of work, no parameters)                           */
/*    AND the viewby selected is Manager                                      */
/*                                                                            */
/* 2) Check whether the supervisor level change fact can be used              */
/*    (no bucket, no length of work, no parameters)                           */
/*    AND the viewby selected is NOT Manager                                  */
/*                                                                            */
/* 3) Check whether the termination by assignment fact can be used            */
/*    (no hires or transfers)                                                 */
/*                                                                            */
/* 4) If neither 1) nor 2) nor 3 then return an invalid fact table message    */
/*                                                                            */
/* The logic is convoluted because the original MV does not support buckets,  */
/* other dimensions or the length of service measure and the new MV does not  */
/* support hires or transfers                                                 */
/*----------------------------------------------------------------------------*/

/* 1) no bucket (or person type bucket), no length of work, no parameters */
/*    VIEWBY Manager */
    IF ((p_bucket_dim IS NULL OR p_bucket_dim = 'HRI_PRSNTYP+HRI_WKTH_WKTYP') AND
        p_include_low = 'N' AND
        p_parameter_count = 0
        --
        and p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H'
        --
        ) THEN
      p_fact_table := 'hri_mdp_sup_wcnt_chg_mv';

/* 2) no bucket, no length of work, no parameters, viewby Manager */
    ELSIF (p_bucket_dim IS NULL AND
        p_include_low = 'N' AND
        p_parameter_count = 0
        --
        and p_parameter_rec.view_by <> 'HRI_PERSON+HRI_PER_USRDR_H'
        --
        ) THEN
      p_fact_table := 'hri_mdp_sup_wcnt_term_asg_mv';

    ELSIF (p_include_hire  = 'N' AND
           p_include_trin  = 'N' AND
           p_include_trout = 'N' AND
           p_include_term  = 'N') THEN
/* 3) no hires or transfers */
      p_fact_table := 'hri_mdp_sup_wcnt_term_asg_mv';
    ELSE
/* 4) invalid fact table */
      p_fact_table := 'invalid_fact_table';
    END IF;
  END IF;

END set_fact_table;


/******************************************************************************/
/* Replaces tags in a SELECT column template and formats it with an alias     */
/******************************************************************************/
FUNCTION format_column(p_column_string  IN VARCHAR2,
                       p_start_date     IN VARCHAR2,
                       p_end_date       IN VARCHAR2,
                       p_bucket_id      IN VARCHAR2,
                       p_column_alias   IN VARCHAR2)
    RETURN VARCHAR2 IS

  l_column_string   VARCHAR2(1000);

BEGIN

/* Replace the start date */
  l_column_string := REPLACE(p_column_string, '<start_date>', p_start_date);

/* Replace the end date */
  l_column_string := REPLACE(l_column_string, '<end_date>', p_end_date);

/* Replace the bucket identifier */
  l_column_string := REPLACE(l_column_string, '<bucket_id>', p_bucket_id);

/* Format the column string replacing the start date */
  l_column_string :=
','  || l_column_string || '  ' || p_column_alias || g_rtn;

  RETURN l_column_string;

END format_column;


/******************************************************************************/
/* This function returns a list of columns to be added to the SELECT clause   */
/* for a given measure. The input fields contain the templates to use for     */
/* the measure SELECT columns and various control fields.                     */
/*                                                                            */
/* The following fields control sampling across different periods             */
/*   - include_comp: the measure is sampled for the comparison period         */
/*                                                                            */
/* If a bucket dimension is specified then all measures will be sampled for   */
/* each period for each bucket value (in addition to the values across all    */
/* buckets).                                                                  */
/*   - bucket_dim: the measures is sampled for all buckets of dimension       */
/*                                                                            */
/******************************************************************************/
FUNCTION build_columns
    (p_parameter_rec      IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
     p_wcnt_chg_params    IN wcnt_chg_fact_param_type,
     p_template_standard  IN VARCHAR2,
     p_template_bucket    IN VARCHAR2,
     p_measure_alias      IN VARCHAR2)
   RETURN VARCHAR2 IS

/* Return string */
  l_column_list       VARCHAR2(5000);

/* Table of buckets for the given bucket dimension */
  l_bucket_tab        hri_mtdt_dim_lvl.dim_lvl_buckets_tabtype;

/* Column Templates */
  l_bucket_column        VARCHAR2(1000);

BEGIN

/* Always get the column for the current period */
/************************************************/
  l_column_list := l_column_list || format_column
     (p_column_string => p_template_standard
     ,p_start_date    => g_binds('TIME_CURR_START_DATE')
     ,p_end_date      => g_binds('TIME_CURR_END_DATE')
     ,p_bucket_id     => NULL
     ,p_column_alias  => 'curr_' || p_measure_alias);

/* Check for comparison period columns */
/***************************************/
  IF (p_wcnt_chg_params.include_comp = 'Y') THEN
    l_column_list := l_column_list || format_column
     (p_column_string => p_template_standard
     ,p_start_date    => g_binds('TIME_COMP_START_DATE')
     ,p_end_date      => g_binds('TIME_COMP_END_DATE')
     ,p_bucket_id     => NULL
     ,p_column_alias  => 'comp_' || p_measure_alias);
  END IF;

/* Checks for bucket dimension */
/*******************************/
  IF (p_wcnt_chg_params.bucket_dim IS NOT NULL) THEN

  /* Replace the bucket column tag in the bucket column template */
    l_bucket_column := REPLACE(p_template_bucket, '<bucket_column>',
                               hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
                                (p_wcnt_chg_params.bucket_dim).fact_viewby_col);

  /* Set buckets table */
    IF (p_wcnt_chg_params.bucket_dim = 'HRI_LOW+HRI_LOW_BAND_X') THEN
      hri_mtdt_dim_lvl.set_low_band_buckets(p_parameter_rec.wkth_wktyp_sk_fk);
      l_bucket_tab := hri_mtdt_dim_lvl.g_low_band_buckets_tab;
    ELSIF (p_wcnt_chg_params.bucket_dim = 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X') THEN
      l_bucket_tab := hri_mtdt_dim_lvl.g_prfmnc_band_buckets_tab;
    ELSIF (p_wcnt_chg_params.bucket_dim = 'JOB+PRIMARY_JOB_ROLE') THEN
      l_bucket_tab := hri_mtdt_dim_lvl.g_primary_job_role_tab;
    ELSIF (p_wcnt_chg_params.bucket_dim = 'HRI_PRSNTYP+HRI_WKTH_WKTYP') THEN
      l_bucket_tab := hri_mtdt_dim_lvl.g_wkth_wktyp_tab;
    END IF;

  /* Loop through buckets table to add required columns */
    FOR i IN l_bucket_tab.FIRST..l_bucket_tab.LAST LOOP

    /* Add the current period column for the bucket */
      l_column_list := l_column_list || format_column
         (p_column_string => l_bucket_column
         ,p_start_date    => g_binds('TIME_CURR_START_DATE')
         ,p_end_date      => g_binds('TIME_CURR_END_DATE')
         ,p_bucket_id     => l_bucket_tab(i).bucket_id_string
         ,p_column_alias  => 'curr_' || p_measure_alias || '_' ||
                             l_bucket_tab(i).bucket_name);

    /* Add the comparison period column for the bucket */
      IF (p_wcnt_chg_params.include_comp = 'Y') THEN
        l_column_list := l_column_list || format_column
         (p_column_string => l_bucket_column
         ,p_start_date    => g_binds('TIME_COMP_START_DATE')
         ,p_end_date      => g_binds('TIME_COMP_END_DATE')
         ,p_bucket_id     => l_bucket_tab(i).bucket_id_string
         ,p_column_alias  => 'comp_' || p_measure_alias || '_' ||
                             l_bucket_tab(i).bucket_name);
      END IF;

    END LOOP;

  END IF;

  RETURN l_column_list;

END build_columns;


/******************************************************************************/
/* Returns the final SQL statement for the PMV report.                        */
/*                                                                            */
/* The SQL returned is in the format:                                         */
/*                                                                            */
/* SELECT                                                                     */
/*  Grouping column (view by)                                                 */
/*  Specific measure columns, including sampling                              */
/*  across different periods and buckets                                      */
/* FROM                                                                       */
/*  Fact table                                                                */
/* WHERE                                                                      */
/*   Apply parameters corresponding to user selection                         */
/*   in the PMV report                                                        */
/*   Join to time dimension sampling all required periods                     */
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
   p_wcnt_chg_params  IN wcnt_chg_fact_param_type,
   p_use_snapshot     IN BOOLEAN,
   p_fact_table       IN VARCHAR2,
   p_fact_conditions  IN VARCHAR2)
   RETURN VARCHAR2 IS

/* Whether to format the SQL for the view by manager special case */
  l_view_by_manager        BOOLEAN;

/* Dynamic SQL columns */
/***********************/
/* Select */
  l_direct_ind              VARCHAR2(1000);
  l_col_list                VARCHAR2(10000);

/* From / Where */
  l_from_clause             VARCHAR2(1000);
  l_mgr_direct_condition    VARCHAR2(1000);
  l_gen_direct_condition    VARCHAR2(1000);
  l_date_condition          VARCHAR2(1000);
  l_snapshot_condition      VARCHAR2(1000);

/* Column Templates */
  l_template_sepcat         VARCHAR2(1000);
  l_template_sepcat_bucket  VARCHAR2(1000);

/* Return string */
  l_fact_sql                VARCHAR2(10000);

BEGIN

/******************************************************************************/
/* INITIALIZATION */
/******************/

/* Check for view by manager special case */
  IF (p_parameter_rec.view_by = 'HRI_PERSON+HRI_PER_USRDR_H' AND
      p_wcnt_chg_params.kpi_mode = 'N') THEN
    l_view_by_manager := TRUE;
  ELSE
    l_view_by_manager := FALSE;
  END IF;

/* Set table specific conditions/templates */
  IF (p_fact_table = 'hri_mdp_sup_wcnt_term_asg_mv') THEN
    l_mgr_direct_condition := 'AND (suph.sub_relative_level = 1 ' || g_rtn ||
                          '  OR wcnt.direct_ind = 1)' || g_rtn;
    l_template_sepcat := g_template_sepcat;
    l_template_sepcat_bucket := g_template_sepcat_bucket;
  ELSIF (p_fact_table = 'hri_mdp_sup_wcnt_chg_mv' OR
         p_fact_table = 'hri_mds_sup_wcnt_chg_mv') THEN
    l_mgr_direct_condition := 'AND 1 - suph.sub_relative_level = wcnt.direct_record_ind'
                          || g_rtn;
    l_gen_direct_condition := 'AND wcnt.direct_record_ind = 0' || g_rtn;
    l_template_sepcat := g_template_standard;
    l_template_sepcat_bucket := g_template_bucket;
  ELSE
    l_mgr_direct_condition := 'AND (suph.sub_relative_level = 1 ' || g_rtn ||
                          '  OR wcnt.direct_ind = 1)' || g_rtn;
    l_template_sepcat := g_template_standard;
    l_template_sepcat_bucket := g_template_bucket;
  END IF;

/* Set dynamic SQL based on view by (manager special case for non-KPI reports) */
  IF (l_view_by_manager) THEN

/******************************************************************************/
/* VIEW BY MANAGER SPECIAL CASE */
/********************************/

    l_direct_ind := '1 - suph.sub_relative_level';

    l_from_clause :=
' hri_cs_suph  suph
,' || p_fact_table || '  wcnt
WHERE suph.sup_person_id = ' || g_binds('HRI_PERSON+HRI_PER_USRDR_H') || '
AND suph.sub_relative_level <= 1
AND suph.sub_invalid_flag_code = ''N''
AND ' || g_binds('TIME_CURR_END_DATE') || ' BETWEEN suph.effective_start_date ' ||
                                           'AND suph.effective_end_date
AND suph.sub_person_id = wcnt.supervisor_person_id ' || g_rtn ||
  l_mgr_direct_condition;

/* View by anything else */
  ELSE

/******************************************************************************/
/* GENERIC (OTHER VIEW BYs) */
/****************************/

    l_direct_ind := '0';

    l_from_clause :=
' ' || p_fact_table || '  wcnt
WHERE wcnt.supervisor_person_id = ' || g_binds('HRI_PERSON+HRI_PER_USRDR_H') || g_rtn||
     l_gen_direct_condition;

  END IF;

/******************************************************************************/
/* SELECT CLAUSE */
/*****************/

/* Build up SELECT column list */
  IF (p_wcnt_chg_params.include_hire = 'Y') THEN
    l_col_list := l_col_list || build_columns
      (p_parameter_rec => p_parameter_rec,
       p_wcnt_chg_params => p_wcnt_chg_params,
       p_template_standard => REPLACE(g_template_standard, '<measure_column>', 'hire_hdc'),
       p_template_bucket => REPLACE(g_template_bucket, '<measure_column>', 'hire_hdc'),
       p_measure_alias => 'hire_hdc');
  END IF;

/* Build up SELECT column list */
  IF (p_wcnt_chg_params.include_trin = 'Y') THEN
    l_col_list := l_col_list || build_columns
      (p_parameter_rec => p_parameter_rec,
       p_wcnt_chg_params => p_wcnt_chg_params,
       p_template_standard => REPLACE(g_template_standard, '<measure_column>', 'transfer_in_hdc'),
       p_template_bucket => REPLACE(g_template_bucket, '<measure_column>', 'transfer_in_hdc'),
       p_measure_alias => 'transfer_in_hdc');
  END IF;

/* Build up SELECT column list */
  IF (p_wcnt_chg_params.include_trout = 'Y') THEN
    l_col_list := l_col_list || build_columns
      (p_parameter_rec => p_parameter_rec,
       p_wcnt_chg_params => p_wcnt_chg_params,
       p_template_standard => REPLACE(g_template_standard, '<measure_column>', 'transfer_out_hdc'),
       p_template_bucket => REPLACE(g_template_bucket, '<measure_column>', 'transfer_out_hdc'),
       p_measure_alias => 'transfer_out_hdc');
  END IF;

/* Build up SELECT column list */
  IF (p_wcnt_chg_params.include_term = 'Y') THEN
    l_col_list := l_col_list || build_columns
      (p_parameter_rec => p_parameter_rec,
       p_wcnt_chg_params => p_wcnt_chg_params,
       p_template_standard => REPLACE(g_template_standard, '<measure_column>', 'termination_hdc'),
       p_template_bucket => REPLACE(g_template_bucket, '<measure_column>', 'termination_hdc'),
       p_measure_alias => 'termination_hdc');
  END IF;

  IF (p_wcnt_chg_params.include_sep = 'Y') THEN
    l_col_list := l_col_list || build_columns
      (p_parameter_rec => p_parameter_rec,
       p_wcnt_chg_params => p_wcnt_chg_params,
       p_template_standard => REPLACE(g_template_standard, '<measure_column>', 'separation_hdc'),
       p_template_bucket => REPLACE(g_template_bucket, '<measure_column>', 'separation_hdc'),
       p_measure_alias => 'separation_hdc');
  END IF;

  IF (p_wcnt_chg_params.include_sep_vol = 'Y') THEN
    l_col_list := l_col_list || build_columns
      (p_parameter_rec => p_parameter_rec,
       p_wcnt_chg_params => p_wcnt_chg_params,
       p_template_standard => REPLACE(REPLACE(l_template_sepcat,
                                  '<sepcat_id>', '''SEP_VOL'''),
                                  '<measure_column>', 'sep_vol_hdc'),
       p_template_bucket => REPLACE(REPLACE(l_template_sepcat_bucket,
                                  '<sepcat_id>', '''SEP_VOL'''),
                                  '<measure_column>', 'sep_vol_hdc'),
       p_measure_alias => 'sep_vol_hdc');
  END IF;

  IF (p_wcnt_chg_params.include_sep_inv = 'Y') THEN
    l_col_list := l_col_list || build_columns
      (p_parameter_rec => p_parameter_rec,
       p_wcnt_chg_params => p_wcnt_chg_params,
       p_template_standard => REPLACE(REPLACE(l_template_sepcat,
                                  '<sepcat_id>', '''SEP_INV'''),
                                  '<measure_column>', 'sep_invol_hdc'),
       p_template_bucket => REPLACE(REPLACE(l_template_sepcat_bucket,
                                  '<sepcat_id>', '''SEP_INV'''),
                                  '<measure_column>', 'sep_invol_hdc'),
       p_measure_alias => 'sep_invol_hdc');
  END IF;

/* Build up SELECT column list */
  IF (p_wcnt_chg_params.include_low = 'Y') THEN
    l_col_list := l_col_list || build_columns
      (p_parameter_rec => p_parameter_rec,
       p_wcnt_chg_params => p_wcnt_chg_params,
       p_template_standard => REPLACE(g_template_standard, '<measure_column>', 'pow_months'),
       p_template_bucket => REPLACE(g_template_bucket, '<measure_column>', 'pow_months'),
       p_measure_alias => 'low_months');

    l_col_list := l_col_list || build_columns
      (p_parameter_rec => p_parameter_rec,
       p_wcnt_chg_params => p_wcnt_chg_params,
       p_template_standard => REPLACE(g_template_standard, '<measure_column>',
                                  'effective_date - pow_start_date'),
       p_template_bucket => REPLACE(g_template_bucket, '<measure_column>',
                                  'effective_date - pow_start_date'),
       p_measure_alias => 'low_days');
  END IF;

/******************************************************************************/
/* FROM CLAUSE */
/***************/

  IF p_use_snapshot THEN

    l_snapshot_condition :=
  'AND wcnt.period_type = &PERIOD_TYPE' || g_rtn;

    IF (p_wcnt_chg_params.include_comp = 'Y') THEN
      l_date_condition := l_date_condition ||
  'AND (wcnt.effective_date, wcnt.comparison_type) IN (
   ('|| g_binds('TIME_CURR_END_DATE') || ',''CURRENT''),
   ('|| g_binds('TIME_COMP_END_DATE') || ',&TIME_COMPARISON_TYPE)
)' || g_rtn;
    ELSE
      l_date_condition := l_date_condition ||
  'AND wcnt.effective_date = '|| g_binds('TIME_CURR_END_DATE') || g_rtn ||
  'AND wcnt.comparison_type = ''CURRENT''' || g_rtn;

    END IF;

  ELSE

  /* Set date condition depending on whether the previous period is set */
    IF (p_wcnt_chg_params.include_comp = 'Y') THEN
      l_date_condition := l_date_condition ||
  'AND wcnt.effective_date BETWEEN ' || g_binds('TIME_COMP_START_DATE') ||
                         ' AND ' || g_binds('TIME_CURR_END_DATE') || '
  AND wcnt.effective_date NOT BETWEEN ' || g_binds('TIME_COMP_END_DATE') || ' + 1 ' ||
                             'AND ' || g_binds('TIME_CURR_START_DATE') || ' - 1' || g_rtn;

    ELSE
      l_date_condition := l_date_condition ||
  'AND wcnt.effective_date BETWEEN ' || g_binds('TIME_CURR_START_DATE') ||
                         ' AND ' || g_binds('TIME_CURR_END_DATE') || g_rtn;
    END IF;

  END IF;

/******************************************************************************/
/* BUILD UP SQL STATEMENT */
/**************************/

  l_fact_sql :=
'SELECT /*+ NO_MERGE INDEX(wcnt) */
 ' ||  hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
        (p_parameter_rec.view_by).fact_viewby_col  || '  vby_id
,' || l_direct_ind || '  direct_ind ' || g_rtn ||
 l_col_list ||
'FROM' || g_rtn ||
 l_from_clause ||
 p_fact_conditions ||
 l_date_condition ||
 l_snapshot_condition ||
'GROUP BY
 '  || hri_mtdt_dim_lvl.g_dim_lvl_mtdt_tab
        (p_parameter_rec.view_by).fact_viewby_col || g_rtn ||
',' || l_direct_ind;

  RETURN l_fact_sql;

END build_sql;


/******************************************************************************/
/* Main entry point, takes PMV parameters and SQL control parameters          */
/* Returns the SQL statement for the PMV report.                              */
/******************************************************************************/
FUNCTION get_sql
 (p_parameter_rec    IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab         IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_wcnt_chg_params  IN wcnt_chg_fact_param_type)
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
    p_bind_format => p_wcnt_chg_params.bind_format);

/* Analyze parameters to build up fact condition and help decide */
/* which fact/function to use */
  analyze_parameters
   (p_bind_tab        => p_bind_tab,
    p_fact_conditions => l_fact_conditions,
    p_parameter_count => l_parameter_count,
    p_single_param    => l_single_param);

/* Decide which fact table(s) to use */
  set_fact_table
   (p_parameter_rec   => p_parameter_rec,
    p_bucket_dim      => p_wcnt_chg_params.bucket_dim,
    p_include_hire    => p_wcnt_chg_params.include_hire,
    p_include_trin    => p_wcnt_chg_params.include_trin,
    p_include_trout   => p_wcnt_chg_params.include_trout,
    p_include_term    => p_wcnt_chg_params.include_term,
    p_include_low     => p_wcnt_chg_params.include_low,
    p_parameter_count => l_parameter_count,
    p_single_param    => l_single_param,
    p_use_snapshot    => l_use_snapshot,
    p_fact_table      => l_fact_table);

/* Set column templates */
  initialize_globals(p_use_snapshot => l_use_snapshot);

/* Build SQL statement */
  l_return_sql := build_sql
   (p_parameter_rec   => p_parameter_rec,
    p_wcnt_chg_params => p_wcnt_chg_params,
    p_use_snapshot    => l_use_snapshot,
    p_fact_table      => l_fact_table,
    p_fact_conditions => l_fact_conditions);

  RETURN l_return_sql;

END get_sql;


/******************************************************************************/
/* Main entry point, takes PMV parameters and SQL control parameters          */
/* Returns the SQL statement for the PMV report.                              */
/* Version with debugging built in                                            */
/******************************************************************************/
FUNCTION get_sql
 (p_parameter_rec    IN hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE,
  p_bind_tab         IN hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE,
  p_wcnt_chg_params  IN wcnt_chg_fact_param_type,
  p_calling_module   IN VARCHAR2)
     RETURN VARCHAR2 IS

  l_wcnt_chg_params    wcnt_chg_fact_param_type;
  l_debug_mode         BOOLEAN := FALSE;
  l_debug_sql          VARCHAR2(32767);

BEGIN

/* If debugging is on log the calling module, parameters and debug sql */
  IF (l_debug_mode) THEN
    l_wcnt_chg_params := p_wcnt_chg_params;
    l_wcnt_chg_params.bind_format := 'SQL';
    l_debug_sql := get_sql
     (p_parameter_rec   => p_parameter_rec,
      p_bind_tab        => p_bind_tab,
      p_wcnt_chg_params => l_wcnt_chg_params);
--    call_debug_api(l_debug_sql);
  END IF;

  RETURN get_sql
          (p_parameter_rec   => p_parameter_rec,
           p_bind_tab        => p_bind_tab,
           p_wcnt_chg_params => p_wcnt_chg_params);

END get_sql;

END hri_bpl_fact_sup_wcnt_chg_sql;

/
