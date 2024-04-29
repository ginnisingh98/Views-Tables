--------------------------------------------------------
--  DDL for Package Body HRI_MTDT_DIM_LVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_MTDT_DIM_LVL" AS
/* $Header: hrimdlv.pkb 120.6 2005/09/19 06:03:03 cbridge noship $ */

g_rtn   VARCHAR2(30) := '
';

g_cache_pow_wktyp  VARCHAR2(30);

/* Called during package initialization */
PROCEDURE set_metadata IS

  l_dim_lvl   VARCHAR2(100);

BEGIN

/* Dimension level metadata */
/****************************/

  l_dim_lvl := 'HRI_PERSON+HRI_PER_USRDR_H';
  g_dim_lvl_mtdt_tab(l_dim_lvl).fact_viewby_col := 'supervisor_person_id';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'hri_dbi_cl_per_n_v';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_name := 'hri_mdp_sup_wrkfc_sup_mv';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_snp  := 'hri_mds_sup_wrkfc_sup_mv';

  l_dim_lvl := 'GEOGRAPHY+AREA';
  g_dim_lvl_mtdt_tab(l_dim_lvl).fact_viewby_col := 'geo_area_code';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'hri_dbi_cl_geo_area_v';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_name := 'hri_mdp_sup_wrkfc_ctr_mv';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_snp  := 'hri_mds_sup_wrkfc_ctr_mv';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wcnt_mv_snp  := 'hri_mds_sup_wcnt_term_ctr_mv';

  l_dim_lvl := 'GEOGRAPHY+COUNTRY';
  g_dim_lvl_mtdt_tab(l_dim_lvl).fact_viewby_col := 'geo_country_code';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'hri_dbi_cl_geo_country_v';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_name := 'hri_mdp_sup_wrkfc_ctr_mv';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_snp  := 'hri_mds_sup_wrkfc_ctr_mv';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wcnt_mv_snp  := 'hri_mds_sup_wcnt_term_ctr_mv';

  l_dim_lvl := 'JOB+JOB_FAMILY';
  g_dim_lvl_mtdt_tab(l_dim_lvl).fact_viewby_col := 'job_fmly_code';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'hri_cl_job_family_v';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_name := 'hri_mdp_sup_wrkfc_jfm_mv';

  l_dim_lvl := 'JOB+JOB_FUNCTION';
  g_dim_lvl_mtdt_tab(l_dim_lvl).fact_viewby_col := 'job_fnctn_code';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'hri_cl_job_function_v';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_name := 'hri_mdp_sup_wrkfc_jfn_mv';

  l_dim_lvl := 'JOB+PRIMARY_JOB_ROLE';
  g_dim_lvl_mtdt_tab(l_dim_lvl).fact_viewby_col := 'primary_job_role_code';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'hri_cl_job_job_role_v';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_name := 'hri_mdp_sup_wrkfc_jpr_mv';

  l_dim_lvl := 'HRI_LOW+HRI_LOW_BAND_X';
  g_dim_lvl_mtdt_tab(l_dim_lvl).fact_viewby_col := 'pow_band_sk_fk';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'hri_dbi_cl_pow_all_band_v';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_name := 'hri_mdp_sup_wrkfc_e_mv';

  l_dim_lvl := 'HRI_LOW+HRI_LOW_BAND_EMP';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'hri_dbi_cl_pow_service_band_v';

  l_dim_lvl := 'HRI_LOW+HRI_LOW_BAND_CWK';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'hri_dbi_cl_pow_plcmnt_band_v';

  l_dim_lvl := 'HRI_PRFRMNC+HRI_PRFMNC_RTNG_X';
  g_dim_lvl_mtdt_tab(l_dim_lvl).fact_viewby_col := 'perf_band';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'hri_cl_prfmnc_rtng_x_v';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_name := 'hri_mdp_sup_wrkfc_r_mv';

  l_dim_lvl := 'HRI_WRKACTVT+HRI_WAC_SEPCAT_X';
  g_dim_lvl_mtdt_tab(l_dim_lvl).fact_viewby_col := 'separation_category';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'HRI_CL_WAC_SEPCAT_X_V';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_name := '';

  l_dim_lvl := 'HRI_REASON+HRI_RSN_SEP_X';
  g_dim_lvl_mtdt_tab(l_dim_lvl).fact_viewby_col := 'leaving_reason_code';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'HRI_CL_RSN_SEP_X_V';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_name := '';

  l_dim_lvl := 'HRI_PRSNTYP+HRI_WKTH_WKTYP';
  g_dim_lvl_mtdt_tab(l_dim_lvl).fact_viewby_col := 'wkth_wktyp_sk_fk';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'HRI_CL_WKTH_WKTYP_V';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_name := 'hri_mdp_sup_wrkfc_sup_mv';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wrkfc_mv_snp  := 'hri_mds_sup_wrkfc_sup_mv';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_wcnt_mv_snp  := 'hri_mds_sup_wcnt_chg_mv';

  l_dim_lvl := 'HRI_ABSNC+HRI_ABSNC_CAT';
  g_dim_lvl_mtdt_tab(l_dim_lvl).fact_viewby_col := 'absence_category_code';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'HRI_CL_ABSNC_CAT_V';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_abs_mv_name := 'hri_mdp_sup_absnc_cat_mv';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_abs_mv_snp  := 'hri_mdp_sup_absnc_cat_mv ';

  l_dim_lvl := 'HRI_ABSNC+HRI_ABSNC_RSN';
  g_dim_lvl_mtdt_tab(l_dim_lvl).fact_viewby_col := 'absence_reason_code';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'HRI_CL_ABSNC_RSN_V';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_abs_mv_name := 'hri_mdp_sup_absnc_rsn_mv';
  g_dim_lvl_mtdt_tab(l_dim_lvl).sup_lvl_abs_mv_snp  := 'hri_mdp_sup_absnc_rsn_mv ';

  l_dim_lvl := 'HRI_ABSNC_M+HRI_ABSNC_M_DRTN_UOM';
  g_dim_lvl_mtdt_tab(l_dim_lvl).viewby_table := 'HRI_CL_ABSNC_M_DRTN_UOM_V';

/* Dimension level buckets */
/***************************/

  g_prfmnc_band_buckets_tab(0).bucket_id_string := '-5';
  g_prfmnc_band_buckets_tab(0).bucket_name      := 'na';

  g_prfmnc_band_buckets_tab(1).bucket_id_string := '1';
  g_prfmnc_band_buckets_tab(1).bucket_name      := 'b1';

  g_prfmnc_band_buckets_tab(2).bucket_id_string := '2';
  g_prfmnc_band_buckets_tab(2).bucket_name      := 'b2';

  g_prfmnc_band_buckets_tab(3).bucket_id_string := '3';
  g_prfmnc_band_buckets_tab(3).bucket_name      := 'b3';

  g_country_buckets_tab(1).bucket_id_string := ':GEO_COUNTRY_CODE1';
  g_country_buckets_tab(1).bucket_name      := 'ctr1';

  g_country_buckets_tab(2).bucket_id_string := ':GEO_COUNTRY_CODE2';
  g_country_buckets_tab(2).bucket_name      := 'ctr2';

  g_country_buckets_tab(3).bucket_id_string := ':GEO_COUNTRY_CODE3';
  g_country_buckets_tab(3).bucket_name      := 'ctr3';

  g_country_buckets_tab(4).bucket_id_string := ':GEO_COUNTRY_CODE4';
  g_country_buckets_tab(4).bucket_name      := 'ctr4';

  g_primary_job_role_tab(1).bucket_id_string := '''HR''';
  g_primary_job_role_tab(1).bucket_name      := 'hr';

  g_primary_job_role_tab(2).bucket_id_string := '''NA_EDW''';
  g_primary_job_role_tab(2).bucket_name      := 'other';

  g_wkth_wktyp_tab(1).bucket_id_string := '''EMP''';
  g_wkth_wktyp_tab(1).bucket_name      := 'emp';

  g_wkth_wktyp_tab(2).bucket_id_string := '''CWK''';
  g_wkth_wktyp_tab(2).bucket_name      := 'cwk';

  g_abs_category_buckets_tab(1).bucket_id_string := ':ABS_CATEGORY_CODE1';
  g_abs_category_buckets_tab(1).bucket_name      := 'absCat1';

  g_abs_category_buckets_tab(2).bucket_id_string := ':ABS_CATEGORY_CODE2';
  g_abs_category_buckets_tab(2).bucket_name      := 'absCat2';

  g_abs_category_buckets_tab(3).bucket_id_string := ':ABS_CATEGORY_CODE3';
  g_abs_category_buckets_tab(3).bucket_name      := 'absCat3';

  g_abs_category_buckets_tab(4).bucket_id_string := ':ABS_CATEGORY_CODE4';
  g_abs_category_buckets_tab(4).bucket_name      := 'absCat4';



END set_metadata;

-- Sets bucket table for LOW bands dynamically
-- based on the collected table for LOW bands
PROCEDURE set_low_band_buckets(p_wkth_wktyp_sk_fk  IN VARCHAR2) IS

  CURSOR low_band_buckets_csr IS
  SELECT
   pow.pow_band_sk_pk        bucket_id
  ,pow.band_sequence         bucket_no
  ,'b' || pow.band_sequence  bucket_label
  FROM hri_cs_pow_band_ct  pow
  WHERE pow.wkth_wktyp_sk_fk = p_wkth_wktyp_sk_fk;

BEGIN

-- Check whether cache hit
  IF (g_cache_pow_wktyp IS NULL OR
      g_cache_pow_wktyp <> p_wkth_wktyp_sk_fk) THEN

  -- Set cache
    g_cache_pow_wktyp := p_wkth_wktyp_sk_fk;

  -- Reset table
    g_low_band_buckets_tab := g_buckets_tab_reset;

  -- Loop through available buckets setting up global table
    FOR bucket_rec IN low_band_buckets_csr LOOP

      g_low_band_buckets_tab(bucket_rec.bucket_no).bucket_id_string :=
                 bucket_rec.bucket_id;
      g_low_band_buckets_tab(bucket_rec.bucket_no).bucket_name :=
                 bucket_rec.bucket_label;

    END LOOP;

  -- Add unassigned rows if there is no data found otherwise reports
  -- will crash as expected columns are not populated in the bucket tab
    IF (g_low_band_buckets_tab.COUNT < 1 OR
        g_low_band_buckets_tab.COUNT IS NULL) THEN

      g_low_band_buckets_tab(1).bucket_id_string := '-1';
      g_low_band_buckets_tab(1).bucket_name := 'b1';
      g_low_band_buckets_tab(2).bucket_id_string := '-1';
      g_low_band_buckets_tab(2).bucket_name := 'b2';
      g_low_band_buckets_tab(3).bucket_id_string := '-1';
      g_low_band_buckets_tab(3).bucket_name := 'b3';
      g_low_band_buckets_tab(4).bucket_id_string := '-1';
      g_low_band_buckets_tab(4).bucket_name := 'b4';
      g_low_band_buckets_tab(5).bucket_id_string := '-1';
      g_low_band_buckets_tab(5).bucket_name := 'b5';

    END IF;

  END IF;

END set_low_band_buckets;

/* Initialization - set metadata for parameters */
BEGIN

  set_metadata;

END hri_mtdt_dim_lvl;

/
