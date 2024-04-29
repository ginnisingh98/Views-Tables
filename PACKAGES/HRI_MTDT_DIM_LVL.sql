--------------------------------------------------------
--  DDL for Package HRI_MTDT_DIM_LVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_MTDT_DIM_LVL" AUTHID CURRENT_USER AS
/* $Header: hrimdlv.pkh 120.2 2005/09/19 03:26:26 cbridge noship $ */

TYPE dim_lvl_metadata_rectype IS RECORD
  (fact_viewby_col         VARCHAR2(30)
  ,viewby_table            VARCHAR2(30)
  ,viewby_id_col           VARCHAR2(30)
  ,viewby_value_col        VARCHAR2(30)
  ,sup_lvl_wrkfc_mv_name   VARCHAR2(30)
  ,sup_lvl_wrkfc_mv_snp    VARCHAR2(30)
  ,sup_lvl_wcnt_mv_snp     VARCHAR2(30)
  ,sup_lvl_abs_mv_name     VARCHAR2(30)
  ,sup_lvl_abs_mv_snp      VARCHAR2(30)
);

TYPE dim_lvl_metadata_tabtype IS TABLE OF dim_lvl_metadata_rectype
                   INDEX BY VARCHAR2(80);

TYPE dim_lvl_buckets_rectype IS RECORD
  (bucket_id_string  VARCHAR2(30)
  ,bucket_name       VARCHAR2(30));

TYPE dim_lvl_buckets_tabtype IS TABLE OF dim_lvl_buckets_rectype
                   INDEX BY BINARY_INTEGER;

g_dim_lvl_mtdt_tab   dim_lvl_metadata_tabtype;

g_buckets_tab_reset          dim_lvl_buckets_tabtype;
g_low_band_buckets_tab       dim_lvl_buckets_tabtype;
g_prfmnc_band_buckets_tab    dim_lvl_buckets_tabtype;
g_country_buckets_tab        dim_lvl_buckets_tabtype;
g_abs_category_buckets_tab   dim_lvl_buckets_tabtype;
g_primary_job_role_tab       dim_lvl_buckets_tabtype;
g_wkth_wktyp_tab             dim_lvl_buckets_tabtype;

PROCEDURE set_low_band_buckets(p_wkth_wktyp_sk_fk  IN VARCHAR2);

END hri_mtdt_dim_lvl;

 

/
