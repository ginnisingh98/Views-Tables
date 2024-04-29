--------------------------------------------------------
--  DDL for Package Body HRI_MTDT_AK_REGION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_MTDT_AK_REGION" AS
/* $Header: hrimdakr.pkb 120.5 2005/09/20 05:55:10 jrstewar noship $ */

l_ak_region_mtdt_tab   ak_region_metadata_tabtype;

/*Called during package initialization */

PROCEDURE set_metadata IS

  l_ak_reg   VARCHAR2(45);

BEGIN

/* Worker Type Contingent KPI Reports             */
/**************************************************/
  l_ak_reg := 'HRI_K_WMV_C_ATVTY';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_K_WMV_C_ATVTY';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'CWK';

  l_ak_reg := 'HRI_K_WMV_C_LOW';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_K_WMV_C_LOW';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'CWK';

/* Worker Type Contingent Portlets / Reports      */
/**************************************************/

  l_ak_reg := 'HRI_P_WMV_C_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_C_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'CWK';

  l_ak_reg := 'HRI_P_WMV_C_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_C_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'CWK';

  l_ak_reg := 'HRI_P_WMV_C_BCKT_LOP_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_C_BCKT_LOP_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'CWK';

  l_ak_reg := 'HRI_P_WMV_C_BCKT_LOP_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_C_BCKT_LOP_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'CWK';

  l_ak_reg := 'HRI_P_WMV_C_BCKT_LOP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_C_BCKT_LOP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'CWK';

  l_ak_reg := 'HRI_P_WMV_C_EXTN_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_C_EXTN_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'CWK';

/* Worker Type Contingent Detail Reports          */
/**************************************************/

  l_ak_reg := 'HRI_P_WAC_C_HIR_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WAC_C_HIR_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'CWK';

  l_ak_reg := 'HRI_P_WAC_C_SEP_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WAC_C_SEP_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'CWK';

  l_ak_reg := 'HRI_P_WMV_C_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_C_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'CWK';

  l_ak_reg := 'HRI_P_WAC_C_IN_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WAC_C_IN_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'CWK';

  l_ak_reg := 'HRI_P_WAC_C_OUT_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WAC_C_OUT_SUP_DTL ';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'CWK';

/* Worker Type Employee KPI Reports               */
/**************************************************/

  l_ak_reg := 'HRI_K_ABS_WMV';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_K_ABS_WMV';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_K_SAL_KPI';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_K_SAL_KPI';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_K_WMV_TRN_PERF';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_K_WMV_TRN_PERF';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_K_WMV_LOW';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_K_WMV_LOW';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_K_WMV_SAL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_K_WMV_SAL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_K_WMV_TRN';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_K_WMV_TRN';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_K_TRN_LOW';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_K_TRN_LOW';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_K_WMV_PERF';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_K_WMV_PERF';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

/* Worker Type Employee Portlet / Reports         */
/**************************************************/

  l_ak_reg := 'HRI_P_WMV_ABS_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_ABS_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_ABS_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_ABS_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_ABS_WMV_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_ABS_WMV_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_AVSAL_CTR_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_AVSAL_CTR_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_BCKT_LOW';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_BCKT_LOW';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_BCKT_LOW_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_BCKT_LOW_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_BCKT_LOW_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_BCKT_LOW_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_BCKT_PERF';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_BCKT_PERF';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_BCKT_PERF_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_BCKT_PERF_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_BCKT_PERF_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_BCKT_PERF_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_CTR_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_CTR_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_SAL_CIT_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_SAL_CIT_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_SAL_CTR_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_SAL_CTR_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_SAL_CTR_SUP_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_SAL_CTR_SUP_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_SAL_JFMFN_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_SAL_JFMFN_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_SAL_JFM_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_SAL_JFM_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_SAL_RGN_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_SAL_RGN_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_SAL_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_SAL_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_SAL_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_SAL_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_SAL_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_SAL_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_BCKT_PERF';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_BCKT_PERF';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_TRN_BCKT_PERF_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_TRN_BCKT_PERF_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_BCKT_PERF_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_BCKT_PERF_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_BCKT_POW';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_BCKT_POW';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_BCKT_POW_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_BCKT_POW_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_CTR_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_CTR_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_CTR_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_CTR_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_JFN_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_JFN_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_SUMMARY';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_SUMMARY';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_SUMMARY_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_SUMMARY_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_SUP_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_SUP_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_V_RSN_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_V_RSN_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WRKFC_TRN_SUMMARY';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WRKFC_TRN_SUMMARY';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WRKFC_TRN_SUMMARY_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WRKFC_TRN_SUMMARY_PVT';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

/* Worker Type Employee Detail Reports            */
/**************************************************/

  l_ak_reg := 'HRI_P_WAC_HIR_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WAC_HIR_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WAC_IN_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WAC_IN_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WAC_OUT_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WAC_OUT_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WAC_SEP_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WAC_SEP_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_SAL_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_SAL_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

  l_ak_reg := 'HRI_P_WMV_TRN_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_TRN_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := 'EMP';

/* Worker Type "All" KPI Reports                  */
/**************************************************/
  l_ak_reg := 'HRI_K_WMV_WF';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_K_WMV_WF';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := NULL;

  l_ak_reg := 'HRI_K_WMV_HR';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_K_WMV_HR';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := NULL;

/* Worker Type "All" Portlets / Reports           */
/**************************************************/

  l_ak_reg := 'HRI_P_WMV_WF_R_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_WF_R_SUP_GRAPH';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := NULL;

  l_ak_reg := 'HRI_P_WMV_WF_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_WF_SUP';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := NULL;

  l_ak_reg := 'HRI_P_WMV_HR_CTR';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_HR_CTR';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := NULL;

/* Worker Type Contingent Detail Reports          */
/**************************************************/

  l_ak_reg := 'HRI_P_WMV_WF_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_WF_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := NULL;

  l_ak_reg := 'HRI_P_WAC_WF_OUT_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WAC_WF_IN_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := NULL;

  l_ak_reg := 'HRI_P_WAC_WF_IN_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WAC_WF_IN_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := NULL;

  l_ak_reg := 'HRI_P_WMV_HR_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).ak_region_code := 'HRI_P_WMV_HR_SUP_DTL';
  l_ak_region_mtdt_tab(l_ak_reg).wkth_wktyp_sk_fk := NULL;

END set_metadata;

FUNCTION get_ak_region_wkth_wktyp(p_ak_region_code IN  VARCHAR2)
         RETURN VARCHAR2 IS

  l_wkth_wktyp_sk_fk VARCHAR2(40);
  l_wkth_wktyp_sk_fk1 VARCHAR2(40);
BEGIN

  l_wkth_wktyp_sk_fk:= l_ak_region_mtdt_tab(p_ak_region_code).wkth_wktyp_sk_fk;

RETURN l_wkth_wktyp_sk_fk;

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'NA_EDW';

END GET_AK_REGION_WKTH_WKTYP;

/* Initialization - set metadata for parameters */
BEGIN

  set_metadata;

END HRI_MTDT_AK_REGION;


/
