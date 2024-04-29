--------------------------------------------------------
--  DDL for Package Body BEN_FASTFORMULA_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_FASTFORMULA_CHECK" AS
/* $Header: benffchk.pkb 120.0 2005/05/28 09:00:32 appldev noship $ */
/*============================================================================+
|                      Copyright (c) 1997 Oracle Corporation                  |
|                         Redwood Shores, California, USA                     |
|                            All rights reserved.                             |
|                        << BEN_FASTFORMULA_CHECK (B) >>                            |
+=============================================================================+
 * Name:
 *   Fast_Formula_Check
 * Purpose:
 *   This package is used to check the existence of given formula_type_id
 *   and formula_id in ben tables.
 * History:
 *   Date        Who            Version  What?
 *   ----------- ------------   -------  ------------------------------------
 *   01-SEP-2004 swjain         115.0    Created.
 *   01-SEP-2004 swjain         115.1    p_effective_date and p_business_group_id
 *										 defaulted to null
 *   02-SEP-2004 swjain         115.2    p_legislation_cd parameter added for
 *										 future use
 *   27-SEP-2004 swjain         115.3    case statements changed to if-elsif for
 *										 8i compatibility and few more formula_type_ids
 *										 added
 *   27-SEP-2004 swjain         115.4    Added check for formula_type_id -535 and -393
 * ===========================================================================
 */

--
-- Global variables declaration.
--
g_package varchar2(40) := 'ben_fastformula_check';

---
--- Types Declaration
---
TYPE ff_rec IS RECORD (table_name VARCHAR2(100), column_name VARCHAR2(100));
TYPE ff_table IS TABLE OF ff_rec INDEX BY binary_integer;
table_list ff_table;

--
-- ============================================================================
--                     <<Procedure: populate_table_list>>
-- Description:
--    Called by chk_formula_exists_in_ben function to populate the table list
--    depending on the formula_type_id.
-- ============================================================================
--
PROCEDURE populate_table_list(p_formula_type_id IN NUMBER) IS
  L_proc varchar2(80) := g_package||'.populate_table_list';
BEGIN
  hr_utility.set_location ('Entering '|| l_proc,5);

  -- to ensure the table is empty before use
  table_list.DELETE;

IF p_formula_type_id = -550 THEN
/* Formula Type  */
--
    hr_utility.set_location(' TO check table_nameBEN_PGM_F column_name SCORES_CALC_RL',10);
    table_list(1).table_name := 'BEN_PGM_F';
    table_list(1).column_name := 'SCORES_CALC_RL';
--
ELSIF p_formula_type_id = -549 THEN
/* Formula Type Rate Periodization */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTY_BASE_RT_F column_name RATE_PERIODIZATION_RL',10);
    table_list(1).table_name := 'BEN_ACTY_BASE_RT_F';
    table_list(1).column_name := 'RATE_PERIODIZATION_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ENRT_PERD column_name HRCHY_RL',10);
    table_list(2).table_name := 'BEN_ENRT_PERD';
    table_list(2).column_name := 'HRCHY_RL';
--
ELSIF p_formula_type_id = -548 THEN
/* Formula Type Scheduled Hours */
--
    hr_utility.set_location(' TO check table_nameBEN_SCHEDD_HRS_RT_F column_name SCHEDD_HRS_RL',10);
    table_list(1).table_name := 'BEN_SCHEDD_HRS_RT_F';
    table_list(1).column_name := 'SCHEDD_HRS_RL';
--
ELSIF p_formula_type_id = -535 THEN
/* Formula Type Extract Post Process */
--
    hr_utility.set_location(' TO check table_nameBEN_EXT_DFN column_name EXT_POST_PRCS_RL',10);
    table_list(1).table_name := 'BEN_EXT_DFN';
    table_list(1).column_name := 'EXT_POST_PRCS_RL';
--
ELSIF p_formula_type_id = -534 THEN
/* Formula Type Prorate Annual Election Value */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTY_BASE_RT_F column_name PRORT_MN_ANN_ELCN_VAL_RL',10);
    table_list(1).table_name := 'BEN_ACTY_BASE_RT_F';
    table_list(1).column_name := 'PRORT_MN_ANN_ELCN_VAL_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ACTY_BASE_RT_F column_name PRORT_MX_ANN_ELCN_VAL_RL',10);
    table_list(2).table_name := 'BEN_ACTY_BASE_RT_F';
    table_list(2).column_name := 'PRORT_MX_ANN_ELCN_VAL_RL';
--
ELSIF p_formula_type_id = -533 THEN
/* Formula Type Default Excess Treatment */
--
    hr_utility.set_location(' TO check table_nameBEN_BNFT_PRVDR_POOL_F column_name DFLT_EXCS_TRTMT_RL',10);
    table_list(1).table_name := 'BEN_BNFT_PRVDR_POOL_F';
    table_list(1).column_name := 'DFLT_EXCS_TRTMT_RL';
--
ELSIF p_formula_type_id = -532 THEN
/* Formula Type Rollover Value */
--
    hr_utility.set_location(' TO check table_nameBEN_BNFT_POOL_RLOVR_RQMT_F column_name RLOVR_VAL_RL',10);
    table_list(1).table_name := 'BEN_BNFT_POOL_RLOVR_RQMT_F';
    table_list(1).column_name := 'RLOVR_VAL_RL';
--
ELSIF p_formula_type_id = -529 THEN
/* Formula Type Variable Rate Add On Calculation */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTL_PREM_F column_name VRBL_RT_ADD_ON_CALC_RL',10);
    table_list(1).table_name := 'BEN_ACTL_PREM_F';
    table_list(1).column_name := 'VRBL_RT_ADD_ON_CALC_RL';
--
ELSIF p_formula_type_id = -528 THEN
/* Formula Type Partial Month Proration Rule */
--
    hr_utility.set_location(' TO check table_nameBEN_PRTL_MO_RT_PRTN_VAL_F column_name PRTL_MO_PRORTN_RL',10);
    table_list(1).table_name := 'BEN_PRTL_MO_RT_PRTN_VAL_F';
    table_list(1).column_name := 'PRTL_MO_PRORTN_RL';
--
ELSIF p_formula_type_id = -527 THEN
/* Formula Type Maximum Period of Enrollment Determination Date */
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_TO_PRTE_RSN_F column_name MX_POE_DET_DT_RL',10);
    table_list(1).table_name := 'BEN_ELIG_TO_PRTE_RSN_F';
    table_list(1).column_name := 'MX_POE_DET_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PRTN_ELIG_F column_name MX_POE_DET_DT_RL',10);
    table_list(2).table_name := 'BEN_PRTN_ELIG_F';
    table_list(2).column_name := 'MX_POE_DET_DT_RL';
--
ELSIF p_formula_type_id = -526 THEN
/* Formula Type Maximum Period of Enrollment */
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_TO_PRTE_RSN_F column_name MX_POE_RL',10);
    table_list(1).table_name := 'BEN_ELIG_TO_PRTE_RSN_F';
    table_list(1).column_name := 'MX_POE_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PRTN_ELIG_F column_name MX_POE_RL',10);
    table_list(2).table_name := 'BEN_PRTN_ELIG_F';
    table_list(2).column_name := 'MX_POE_RL';
--
ELSIF p_formula_type_id = -518 THEN
/* Formula Type Waiting Period Value and UOM */
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_TO_PRTE_RSN_F column_name WAIT_PERD_RL',10);
    table_list(1).table_name := 'BEN_ELIG_TO_PRTE_RSN_F';
    table_list(1).column_name := 'WAIT_PERD_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name MX_WTG_PERD_RL',10);
    table_list(2).table_name := 'BEN_PL_F';
    table_list(2).column_name := 'MX_WTG_PERD_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PRTN_ELIG_F column_name WAIT_PERD_RL',10);
    table_list(3).table_name := 'BEN_PRTN_ELIG_F';
    table_list(3).column_name := 'WAIT_PERD_RL';
--
ELSIF p_formula_type_id = -517 THEN
/* Formula Type Compensation Calculation */
--
    hr_utility.set_location(' TO check table_nameBEN_COMP_LVL_FCTR column_name COMP_CALC_RL',10);
    table_list(1).table_name := 'BEN_COMP_LVL_FCTR';
    table_list(1).column_name := 'COMP_CALC_RL';
--
-- -517 for salary_calc_mthd_rl is not confirmed.
--
    hr_utility.set_location(' TO check table_nameBEN_PGM_F column_name SALARY_CALC_MTHD_RL',10);
    table_list(2).table_name := 'BEN_PGM_F';
    table_list(2).column_name := 'SALARY_CALC_MTHD_RL';
--
ELSIF p_formula_type_id = -516 THEN
/* Formula Type Hours Worked Calculation */
--
    hr_utility.set_location(' TO check table_nameBEN_HRS_WKD_IN_PERD_FCTR column_name HRS_WKD_CALC_RL',10);
    table_list(1).table_name := 'BEN_HRS_WKD_IN_PERD_FCTR';
    table_list(1).column_name := 'HRS_WKD_CALC_RL';
--
ELSIF p_formula_type_id = -515 THEN
/* Formula Type Premium Upper Limit */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTL_PREM_F column_name UPR_LMT_CALC_RL',10);
    table_list(1).table_name := 'BEN_ACTL_PREM_F';
    table_list(1).column_name := 'UPR_LMT_CALC_RL';
--
ELSIF p_formula_type_id = -514 THEN
/* Formula Type Coverage Upper Limit */
--
    hr_utility.set_location(' TO check table_nameBEN_CVG_AMT_CALC_MTHD_F column_name UPR_LMT_CALC_RL',10);
    table_list(1).table_name := 'BEN_CVG_AMT_CALC_MTHD_F';
    table_list(1).column_name := 'UPR_LMT_CALC_RL';
--
ELSIF p_formula_type_id = -513 THEN
/* Formula Type Required Period of Enrollment */
--
    hr_utility.set_location(' TO check table_nameBEN_OIPL_F column_name RQD_PERD_ENRT_NENRT_RL',10);
    table_list(1).table_name := 'BEN_OIPL_F';
    table_list(1).column_name := 'RQD_PERD_ENRT_NENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name RQD_PERD_ENRT_NENRT_RL',10);
    table_list(2).table_name := 'BEN_PL_F';
    table_list(2).column_name := 'RQD_PERD_ENRT_NENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_OPT_F column_name RQD_PERD_ENRT_NENRT_RL',10);
    table_list(3).table_name := 'BEN_OPT_F';
    table_list(3).column_name := 'RQD_PERD_ENRT_NENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PTIP_F column_name RQD_PERD_ENRT_NENRT_RL',10);
    table_list(4).table_name := 'BEN_PTIP_F';
    table_list(4).column_name := 'RQD_PERD_ENRT_NENRT_RL';
--
ELSIF p_formula_type_id = -512 THEN
/* Formula Type Premium Lower Limit */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTL_PREM_F column_name LWR_LMT_CALC_RL',10);
    table_list(1).table_name := 'BEN_ACTL_PREM_F';
    table_list(1).column_name := 'LWR_LMT_CALC_RL';
--
ELSIF p_formula_type_id = -511 THEN
/* Formula Type Coverage Lower Limit */
--
    hr_utility.set_location(' TO check table_nameBEN_CVG_AMT_CALC_MTHD_F column_name LWR_LMT_CALC_RL',10);
    table_list(1).table_name := 'BEN_CVG_AMT_CALC_MTHD_F';
    table_list(1).column_name := 'LWR_LMT_CALC_RL';
--
ELSIF p_formula_type_id = -510 THEN
/* Formula Type Length of Service Calculation */
--
    hr_utility.set_location(' TO check table_nameBEN_LOS_FCTR column_name LOS_CALC_RL',10);
    table_list(1).table_name := 'BEN_LOS_FCTR';
    table_list(1).column_name := 'LOS_CALC_RL';
--
ELSIF p_formula_type_id = -508 THEN
/* Formula Type Formula Id */
--
    hr_utility.set_location(' TO check table_nameBEN_POP_UP_MESSAGES column_name FORMULA_ID',10);
    table_list(1).table_name := 'BEN_POP_UP_MESSAGES';
    table_list(1).column_name := 'FORMULA_ID';
--
ELSIF p_formula_type_id = -507 THEN
/* Formula Type Premium Value Calculation */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTL_PREM_F column_name VAL_CALC_RL',10);
    table_list(1).table_name := 'BEN_ACTL_PREM_F';
    table_list(1).column_name := 'VAL_CALC_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ACTL_PREM_VRBL_RT_RL_F column_name FORMULA_ID',10);
    table_list(2).table_name := 'BEN_ACTL_PREM_VRBL_RT_RL_F';
    table_list(2).column_name := 'FORMULA_ID';
--
--
    hr_utility.set_location(' TO check table_nameBEN_BNFT_VRBL_RT_RL_F column_name FORMULA_ID',10);
    table_list(3).table_name := 'BEN_BNFT_VRBL_RT_RL_F';
    table_list(3).column_name := 'FORMULA_ID';
--
--
    hr_utility.set_location(' TO check table_nameBEN_VRBL_RT_RL_F column_name FORMULA_ID',10);
    table_list(4).table_name := 'BEN_VRBL_RT_RL_F';
    table_list(4).column_name := 'FORMULA_ID';
--
ELSIF p_formula_type_id = -506 THEN
/* Formula Type Evaluation rule */
--
    hr_utility.set_location(' TO check table_nameBEN_CLPSE_LF_EVT_F column_name EVAL_RL',10);
    table_list(1).table_name := 'BEN_CLPSE_LF_EVT_F';
    table_list(1).column_name := 'EVAL_RL';
--
ELSIF p_formula_type_id = -505 THEN
/* Formula Type Life event reason determination rule */
--
    hr_utility.set_location(' TO check table_nameBEN_CLPSE_LF_EVT_F column_name EVAL_LER_DET_RL',10);
    table_list(1).table_name := 'BEN_CLPSE_LF_EVT_F';
    table_list(1).column_name := 'EVAL_LER_DET_RL';
--
ELSIF p_formula_type_id = -504 THEN
/* Formula Type Enrollment Period Start Date */
--
    hr_utility.set_location(' TO check table_nameBEN_LEE_RSN_F column_name ENRT_PERD_STRT_DT_RL',10);
    table_list(1).table_name := 'BEN_LEE_RSN_F';
    table_list(1).column_name := 'ENRT_PERD_STRT_DT_RL';
--
ELSIF p_formula_type_id = -503 THEN
/* Formula Type Enrollment Period End Date */
--
    hr_utility.set_location(' TO check table_nameBEN_LEE_RSN_F column_name ENRT_PERD_END_DT_RL',10);
    table_list(1).table_name := 'BEN_LEE_RSN_F';
    table_list(1).column_name := 'ENRT_PERD_END_DT_RL';
--
ELSIF p_formula_type_id = -502 THEN
/* Formula Type Waive Certification Required */
--
    hr_utility.set_location(' TO check table_nameBEN_WV_PRTN_RSN_CTFN_PL_F column_name CTFN_RQD_ELSIF_RL',10);
    table_list(1).table_name := 'BEN_WV_PRTN_RSN_CTFN_PL_F';
    table_list(1).column_name := 'CTFN_RQD_ELSIF_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_WV_PRTN_RSN_CTFN_PTIP_F column_name CTFN_RQD_WHEN_RL',10);
    table_list(2).table_name := 'BEN_WV_PRTN_RSN_CTFN_PTIP_F';
    table_list(2).column_name := 'CTFN_RQD_WHEN_RL';
--
ELSIF p_formula_type_id = -500 THEN
/* Formula Type Age Calculation */
--
    hr_utility.set_location(' TO check table_nameBEN_AGE_FCTR column_name AGE_CALC_RL',10);
    table_list(1).table_name := 'BEN_AGE_FCTR';
    table_list(1).column_name := 'AGE_CALC_RL';
--
ELSIF p_formula_type_id = -454 THEN
/* Formula Type Default to Assign Pending Action */
--
    hr_utility.set_location(' TO check table_nameBEN_LER_BNFT_RSTRN_F column_name DFLT_TO_ASN_PNDG_CTFN_RL',10);
    table_list(1).table_name := 'BEN_LER_BNFT_RSTRN_F';
    table_list(1).column_name := 'DFLT_TO_ASN_PNDG_CTFN_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PLIP_F column_name DFLT_TO_ASN_PNDG_CTFN_RL',10);
    table_list(2).table_name := 'BEN_PLIP_F';
    table_list(2).column_name := 'DFLT_TO_ASN_PNDG_CTFN_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name DFLT_TO_ASN_PNDG_CTFN_RL',10);
    table_list(3).table_name := 'BEN_PL_F';
    table_list(3).column_name := 'DFLT_TO_ASN_PNDG_CTFN_RL';
--
ELSIF p_formula_type_id = -453 THEN
/* Formula Type Life Event Reason Timeliness */
--
    hr_utility.set_location(' TO check table_nameBEN_LER_F column_name TMLNS_PERD_RL',10);
    table_list(1).table_name := 'BEN_LER_F';
    table_list(1).column_name := 'TMLNS_PERD_RL';
--
ELSIF p_formula_type_id = -449 THEN
/* Formula Type  */
--
    hr_utility.set_location(' TO check table_nameBEN_PGM_F column_name DFLT_STEP_RL',10);
    table_list(1).table_name := 'BEN_PGM_F';
    table_list(1).column_name := 'DFLT_STEP_RL';
--
ELSIF p_formula_type_id = -413 THEN
/* Formula Type Data element rule*/
--
    hr_utility.set_location(' TO check table_nameBEN_EXT_DATA_ELMT column_name DATA_ELMT_RL',10);
    table_list(1).table_name := 'BEN_EXT_DATA_ELMT';
    table_list(1).column_name := 'DATA_ELMT_RL';
--
ELSIF p_formula_type_id = -393 THEN
/* Formula Type Enrollment Opportunity */
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_OIPL_ENRT_F column_name ENRT_RL',10);
    table_list(1).table_name := 'BEN_LER_CHG_OIPL_ENRT_F';
    table_list(1).column_name := 'ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_PGM_ENRT_F column_name ENRT_RL',10);
    table_list(2).table_name := 'BEN_LER_CHG_PGM_ENRT_F';
    table_list(2).column_name := 'ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_PLIP_ENRT_F column_name ENRT_RL',10);
    table_list(3).table_name := 'BEN_LER_CHG_PLIP_ENRT_F';
    table_list(3).column_name := 'ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_PTIP_ENRT_F column_name ENRT_RL',10);
    table_list(4).table_name := 'BEN_LER_CHG_PTIP_ENRT_F';
    table_list(4).column_name := 'ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PTIP_F column_name ENRT_RL',10);
    table_list(5).table_name := 'BEN_PTIP_F';
    table_list(5).column_name := 'ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name ENRT_RL',10);
    table_list(6).table_name := 'BEN_PL_F';
    table_list(6).column_name := 'ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PLIP_F column_name ENRT_RL',10);
    table_list(7).table_name := 'BEN_PLIP_F';
    table_list(7).column_name := 'ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PGM_F column_name ENRT_RL',10);
    table_list(8).table_name := 'BEN_PGM_F';
    table_list(8).column_name := 'ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_OIPL_F column_name ENRT_RL',10);
    table_list(9).table_name := 'BEN_OIPL_F';
    table_list(9).column_name := 'ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_PL_NIP_ENRT_F column_name ENRT_RL',10);
    table_list(10).table_name := 'BEN_LER_CHG_PL_NIP_ENRT_F';
    table_list(10).column_name := 'ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_PL_NIP_RL_F column_name FORMULA_ID',10);
    table_list(11).table_name := 'BEN_LER_CHG_PL_NIP_RL_F';
    table_list(11).column_name := 'FORMULA_ID';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_PLIP_ENRT_RL_F column_name FORMULA_ID',10);
    table_list(12).table_name := 'BEN_LER_CHG_PLIP_ENRT_RL_F';
    table_list(12).column_name := 'FORMULA_ID';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_OIPL_ENRT_RL_F column_name FORMULA_ID',10);
    table_list(13).table_name := 'BEN_LER_CHG_OIPL_ENRT_RL_F';
    table_list(13).column_name := 'FORMULA_ID';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LEE_RSN_RL_F column_name FORMULA_ID',10);
    table_list(14).table_name := 'BEN_LEE_RSN_RL_F';
    table_list(14).column_name := 'FORMULA_ID';
--
--
    hr_utility.set_location(' TO check table_nameBEN_SCHEDD_ENRT_RL_F column_name FORMULA_ID',10);
    table_list(15).table_name := 'BEN_SCHEDD_ENRT_RL_F';
    table_list(15).column_name := 'FORMULA_ID';
--
ELSIF p_formula_type_id = -392 THEN
/* Formula Type Rate Lower Limit */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTY_BASE_RT_F column_name LWR_LMT_CALC_RL',10);
    table_list(1).table_name := 'BEN_ACTY_BASE_RT_F';
    table_list(1).column_name := 'LWR_LMT_CALC_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_VRBL_RT_PRFL_F column_name ULTMT_LWR_LMT_CALC_RL',10);
    table_list(2).table_name := 'BEN_VRBL_RT_PRFL_F';
    table_list(2).column_name := 'ULTMT_LWR_LMT_CALC_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_VRBL_RT_PRFL_F column_name LWR_LMT_CALC_RL',10);
    table_list(3).table_name := 'BEN_VRBL_RT_PRFL_F';
    table_list(3).column_name := 'LWR_LMT_CALC_RL';
--
ELSIF p_formula_type_id = -372 THEN
/* Formula Type Action Type Due Date */
--
    hr_utility.set_location(' TO check table_nameBEN_POPL_ACTN_TYP_F column_name ACTN_TYP_DUE_DT_RL',10);
    table_list(1).table_name := 'BEN_POPL_ACTN_TYP_F';
    table_list(1).column_name := 'ACTN_TYP_DUE_DT_RL';
--
ELSIF p_formula_type_id = -352 THEN
/* Formula Type Communication Usage */
--
    hr_utility.set_location(' TO check table_nameBEN_CM_TYP_USG_F column_name CM_USG_RL',10);
    table_list(1).table_name := 'BEN_CM_TYP_USG_F';
    table_list(1).column_name := 'CM_USG_RL';
--
ELSIF p_formula_type_id = -332 THEN
/* Formula Type Communication Type */
--
    hr_utility.set_location(' TO check table_nameBEN_CM_TYP_F column_name CM_TYP_RL',10);
    table_list(1).table_name := 'BEN_CM_TYP_F';
    table_list(1).column_name := 'CM_TYP_RL';
--
ELSIF p_formula_type_id = -313 THEN
/* Formula Type Inspection Required */
--
    hr_utility.set_location(' TO check table_nameBEN_CM_TYP_F column_name INSPN_RQD_RL',10);
    table_list(1).table_name := 'BEN_CM_TYP_F';
    table_list(1).column_name := 'INSPN_RQD_RL';
--
ELSIF p_formula_type_id = -312 THEN
/* Formula Type Communication Appropriate */
--
    hr_utility.set_location(' TO check table_nameBEN_CM_TYP_TRGR_F column_name CM_TYP_TRGR_RL',10);
    table_list(1).table_name := 'BEN_CM_TYP_TRGR_F';
    table_list(1).column_name := 'CM_TYP_TRGR_RL';
--
ELSIF p_formula_type_id = -294 THEN
/* Formula Type Participant Eligible to Rollover */
--
    hr_utility.set_location(' TO check table_nameBEN_BNFT_POOL_RLOVR_RQMT_F column_name PRTT_ELIG_RLOVR_RL',10);
    table_list(1).table_name := 'BEN_BNFT_POOL_RLOVR_RQMT_F';
    table_list(1).column_name := 'PRTT_ELIG_RLOVR_RL';
--
ELSIF p_formula_type_id = -293 THEN
/* Formula Type Rate Upper Limit */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTY_BASE_RT_F column_name UPR_LMT_CALC_RL',10);
    table_list(1).table_name := 'BEN_ACTY_BASE_RT_F';
    table_list(1).column_name := 'UPR_LMT_CALC_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_VRBL_RT_PRFL_F column_name UPR_LMT_CALC_RL',10);
    table_list(2).table_name := 'BEN_VRBL_RT_PRFL_F';
    table_list(2).column_name := 'UPR_LMT_CALC_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_VRBL_RT_PRFL_F column_name ULTMT_UPR_LMT_CALC_RL',10);
    table_list(3).table_name := 'BEN_VRBL_RT_PRFL_F';
    table_list(3).column_name := 'ULTMT_UPR_LMT_CALC_RL';
--
ELSIF p_formula_type_id = -215 THEN
/* Formula Type Postelection Edit */
--
    hr_utility.set_location(' TO check table_nameBEN_OIPL_F column_name POSTELCN_EDIT_RL',10);
    table_list(1).table_name := 'BEN_OIPL_F';
    table_list(1).column_name := 'POSTELCN_EDIT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name POSTELCN_EDIT_RL',10);
    table_list(2).table_name := 'BEN_PL_F';
    table_list(2).column_name := 'POSTELCN_EDIT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PLIP_F column_name POSTELCN_EDIT_RL',10);
    table_list(3).table_name := 'BEN_PLIP_F';
    table_list(3).column_name := 'POSTELCN_EDIT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PTIP_F column_name POSTELCN_EDIT_RL',10);
    table_list(4).table_name := 'BEN_PTIP_F';
    table_list(4).column_name := 'POSTELCN_EDIT_RL';
--
ELSIF p_formula_type_id = -214 THEN
/* Formula Type Person Selection rule*/
--
    hr_utility.set_location(' TO check table_nameBEN_BENEFIT_ACTIONS column_name PERSON_SELECTION_RL',10);
    table_list(1).table_name := 'BEN_BENEFIT_ACTIONS';
    table_list(1).column_name := 'PERSON_SELECTION_RL';
--
ELSIF p_formula_type_id = -213 THEN
/* Formula Type */
--
    hr_utility.set_location(' TO check table_nameBEN_BENEFIT_ACTIONS column_name COMP_SELECTION_RL',10);
    table_list(1).table_name := 'BEN_BENEFIT_ACTIONS';
    table_list(1).column_name := 'COMP_SELECTION_RL';
--
ELSIF p_formula_type_id = -174 THEN
/* Formula Type Compensation Determination Date */
--
    hr_utility.set_location(' TO check table_nameBEN_COMP_LVL_FCTR column_name COMP_LVL_DET_RL',10);
    table_list(1).table_name := 'BEN_COMP_LVL_FCTR';
    table_list(1).column_name := 'COMP_LVL_DET_RL';
--
ELSIF p_formula_type_id = -171 THEN
/* Formula Type Rate Value Calculation */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTY_BASE_RT_F column_name INPUT_VA_CALC_RL',10);
    table_list(1).table_name := 'BEN_ACTY_BASE_RT_F';
    table_list(1).column_name := 'INPUT_VA_CALC_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_VRBL_RT_PRFL_F column_name VAL_CALC_RL',10);
    table_list(2).table_name := 'BEN_VRBL_RT_PRFL_F';
    table_list(2).column_name := 'VAL_CALC_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ACTY_BASE_RT_F column_name VAL_CALC_RL',10);
    table_list(3).table_name := 'BEN_ACTY_BASE_RT_F';
    table_list(3).column_name := 'VAL_CALC_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_BNFT_VRBL_RT_RL_F column_name FORMULA_ID',10);
    table_list(4).table_name := 'BEN_BNFT_VRBL_RT_RL_F';
    table_list(4).column_name := 'FORMULA_ID';
--
--
    hr_utility.set_location(' TO check table_nameBEN_VRBL_RT_RL_F column_name FORMULA_ID',10);
    table_list(5).table_name := 'BEN_VRBL_RT_RL_F';
    table_list(5).column_name := 'FORMULA_ID';
--
ELSIF p_formula_type_id = -170 THEN
/* Formula Type Length of Service Determination Date */
--
    hr_utility.set_location(' TO check table_nameBEN_LOS_FCTR column_name LOS_DET_RL',10);
    table_list(1).table_name := 'BEN_LOS_FCTR';
    table_list(1).column_name := 'LOS_DET_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_VSTG_SCHED_F column_name LOS_DET_RL',10);
    table_list(2).table_name := 'BEN_VSTG_SCHED_F';
    table_list(2).column_name := 'LOS_DET_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_SCHEDD_HRS_RT_F column_name DETERMINATION_RL',10);
    table_list(3).table_name := 'BEN_SCHEDD_HRS_RT_F';
    table_list(3).column_name := 'DETERMINATION_RL';
--
ELSIF p_formula_type_id = -169 THEN
/* Formula Type Rounding */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTL_PREM_F column_name RNDG_RL',10);
    table_list(1).table_name := 'BEN_ACTL_PREM_F';
    table_list(1).column_name := 'RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ACTY_BASE_RT_F column_name RNDG_RL',10);
    table_list(2).table_name := 'BEN_ACTY_BASE_RT_F';
    table_list(2).column_name := 'RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_AGE_FCTR column_name RNDG_RL',10);
    table_list(3).table_name := 'BEN_AGE_FCTR';
    table_list(3).column_name := 'RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_BNFT_POOL_RLOVR_RQMT_F column_name PCT_RNDG_RL',10);
    table_list(4).table_name := 'BEN_BNFT_POOL_RLOVR_RQMT_F';
    table_list(4).column_name := 'PCT_RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_BNFT_PRVDR_POOL_F column_name PCT_RNDG_RL',10);
    table_list(5).table_name := 'BEN_BNFT_PRVDR_POOL_F';
    table_list(5).column_name := 'PCT_RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_BNFT_PRVDR_POOL_F column_name VAL_RNDG_RL',10);
    table_list(6).table_name := 'BEN_BNFT_PRVDR_POOL_F';
    table_list(6).column_name := 'VAL_RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_VRBL_RT_PRFL_F column_name RNDG_RL',10);
    table_list(7).table_name := 'BEN_VRBL_RT_PRFL_F';
    table_list(7).column_name := 'RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PRTL_MO_RT_PRTN_VAL_F column_name RNDG_RL',10);
    table_list(8).table_name := 'BEN_PRTL_MO_RT_PRTN_VAL_F';
    table_list(8).column_name := 'RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PCT_FL_TM_FCTR column_name RNDG_RL',10);
    table_list(9).table_name := 'BEN_PCT_FL_TM_FCTR';
    table_list(9).column_name := 'RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LOS_FCTR column_name RNDG_RL',10);
    table_list(10).table_name := 'BEN_LOS_FCTR';
    table_list(10).column_name := 'RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_HRS_WKD_IN_PERD_FCTR column_name RNDG_RL',10);
    table_list(11).table_name := 'BEN_HRS_WKD_IN_PERD_FCTR';
    table_list(11).column_name := 'RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_SCHEDD_HRS_PRTE_F column_name ROUNDING_RL',10);
    table_list(12).table_name := 'BEN_ELIG_SCHEDD_HRS_PRTE_F';
    table_list(12).column_name := 'ROUNDING_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_CVG_AMT_CALC_MTHD_F column_name RNDG_RL',10);
    table_list(13).table_name := 'BEN_CVG_AMT_CALC_MTHD_F';
    table_list(13).column_name := 'RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_COMP_LVL_FCTR column_name RNDG_RL',10);
    table_list(14).table_name := 'BEN_COMP_LVL_FCTR';
    table_list(14).column_name := 'RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_BNFT_POOL_RLOVR_RQMT_F column_name VAL_RNDG_RL',10);
    table_list(15).table_name := 'BEN_BNFT_POOL_RLOVR_RQMT_F';
    table_list(15).column_name := 'VAL_RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_VSTG_LOS_RQMT column_name RNDG_RL',10);
    table_list(16).table_name := 'BEN_VSTG_LOS_RQMT';
    table_list(16).column_name := 'RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_VSTG_AGE_RQMT column_name RNDG_RL',10);
    table_list(17).table_name := 'BEN_VSTG_AGE_RQMT';
    table_list(17).column_name := 'RNDG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_SCHEDD_HRS_RT_F column_name ROUNDING_RL',10);
    table_list(18).table_name := 'BEN_SCHEDD_HRS_RT_F';
    table_list(18).column_name := 'ROUNDING_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_POE_RT_F column_name RNDG_RL',10);
    table_list(19).table_name := 'BEN_POE_RT_F';
    table_list(19).column_name := 'RNDG_RL';
--
ELSIF p_formula_type_id = -168 THEN
/* Formula Type Related Person Change Causes Life Event */
--
    hr_utility.set_location(' TO check table_nameBEN_LER_RLTD_PER_CS_LER_F column_name LER_RLTD_PER_CS_CHG_RL',10);
    table_list(1).table_name := 'BEN_LER_RLTD_PER_CS_LER_F';
    table_list(1).column_name := 'LER_RLTD_PER_CS_CHG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_RLTD_PER_CHG_CS_LER_F column_name RLTD_PER_CHG_CS_LER_RL',10);
    table_list(2).table_name := 'BEN_RLTD_PER_CHG_CS_LER_F';
    table_list(2).column_name := 'RLTD_PER_CHG_CS_LER_RL';
--
ELSIF p_formula_type_id = -167 THEN
/* Formula Type */
--
    hr_utility.set_location(' TO check table_nameBEN_PTD_LMT_F column_name PTD_LMT_CALC_RL',10);
    table_list(1).table_name := 'BEN_PTD_LMT_F';
    table_list(1).column_name := 'PTD_LMT_CALC_RL';
--
ELSIF p_formula_type_id = -166 THEN
/* Formula Type Partial Year Coverage Restriction */
--
    hr_utility.set_location(' TO check table_nameBEN_PLIP_F column_name PRORT_PRTL_YR_CVG_RSTRN_RL',10);
    table_list(1).table_name := 'BEN_PLIP_F';
    table_list(1).column_name := 'PRORT_PRTL_YR_CVG_RSTRN_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name PRORT_PRTL_YR_CVG_RSTRN_RL',10);
    table_list(2).table_name := 'BEN_PL_F';
    table_list(2).column_name := 'PRORT_PRTL_YR_CVG_RSTRN_RL';
--
ELSIF p_formula_type_id = -165 THEN
/* Formula Type Partial Month Proration Method */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTL_PREM_F column_name PRTL_MO_DET_MTHD_RL',10);
    table_list(1).table_name := 'BEN_ACTL_PREM_F';
    table_list(1).column_name := 'PRTL_MO_DET_MTHD_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ACTY_BASE_RT_F column_name PRTL_MO_DET_MTHD_RL',10);
    table_list(2).table_name := 'BEN_ACTY_BASE_RT_F';
    table_list(2).column_name := 'PRTL_MO_DET_MTHD_RL';
--
ELSIF p_formula_type_id = -164 THEN
/* Formula Type Minimum Coverage Amount Calculation */
--
    hr_utility.set_location(' TO check table_nameBEN_LER_BNFT_RSTRN_F column_name MN_CVG_RL',10);
    table_list(1).table_name := 'BEN_LER_BNFT_RSTRN_F';
    table_list(1).column_name := 'MN_CVG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name MN_CVG_RL',10);
    table_list(2).table_name := 'BEN_PL_F';
    table_list(2).column_name := 'MN_CVG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PLIP_F column_name MN_CVG_RL',10);
    table_list(3).table_name := 'BEN_PLIP_F';
    table_list(3).column_name := 'MN_CVG_RL';
--
ELSIF p_formula_type_id = -162 THEN
/* Formula Type Maximum Waiting Period Date to Use */
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_TO_PRTE_RSN_F column_name WAIT_PERD_DT_TO_USE_RL',10);
    table_list(1).table_name := 'BEN_ELIG_TO_PRTE_RSN_F';
    table_list(1).column_name := 'WAIT_PERD_DT_TO_USE_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PRTN_ELIG_F column_name WAIT_PERD_DT_TO_USE_RL',10);
    table_list(2).table_name := 'BEN_PRTN_ELIG_F';
    table_list(2).column_name := 'WAIT_PERD_DT_TO_USE_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name MX_WTG_DT_TO_USE_RL',10);
    table_list(3).table_name := 'BEN_PL_F';
    table_list(3).column_name := 'MX_WTG_DT_TO_USE_RL';
--
ELSIF p_formula_type_id = -161 THEN
/* Formula Type Maximum Coverage Amount Calculation */
--
    hr_utility.set_location(' TO check table_nameBEN_LER_BNFT_RSTRN_F column_name MX_CVG_RL',10);
    table_list(1).table_name := 'BEN_LER_BNFT_RSTRN_F';
    table_list(1).column_name := 'MX_CVG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PLIP_F column_name MX_CVG_RL',10);
    table_list(2).table_name := 'BEN_PLIP_F';
    table_list(2).column_name := 'MX_CVG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name MX_CVG_RL',10);
    table_list(3).table_name := 'BEN_PL_F';
    table_list(3).column_name := 'MX_CVG_RL';
--
ELSIF p_formula_type_id = -160 THEN
/* Formula Type Matching rate Calculation */
--
    hr_utility.set_location(' TO check table_nameBEN_VRBL_MTCHG_RT_F column_name MTCHG_RT_CALC_RL',10);
    table_list(1).table_name := 'BEN_VRBL_MTCHG_RT_F';
    table_list(1).column_name := 'MTCHG_RT_CALC_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_MTCHG_RT_F column_name MTCHG_RT_CALC_RL',10);
    table_list(2).table_name := 'BEN_MTCHG_RT_F';
    table_list(2).column_name := 'MTCHG_RT_CALC_RL';
--
ELSIF p_formula_type_id = -159 THEN
/* Formula Type Mandatory Determination */
--
    hr_utility.set_location(' TO check table_nameBEN_OIPL_F column_name MNDTRY_RL',10);
    table_list(1).table_name := 'BEN_OIPL_F';
    table_list(1).column_name := 'MNDTRY_RL';
--
ELSIF p_formula_type_id = -157 THEN
/* Formula Type Evaluate Life Event */
--
    hr_utility.set_location(' TO check table_nameBEN_LER_F column_name LER_EVAL_RL',10);
    table_list(1).table_name := 'BEN_LER_F';
    table_list(1).column_name := 'LER_EVAL_RL';
--
ELSIF p_formula_type_id = -156 THEN
/* Formula Type Length of Service Date to Use */
--
    hr_utility.set_location(' TO check table_nameBEN_LOS_FCTR column_name LOS_DT_TO_USE_RL',10);
    table_list(1).table_name := 'BEN_LOS_FCTR';
    table_list(1).column_name := 'LOS_DT_TO_USE_RL';
--
ELSIF p_formula_type_id = -155 THEN
/* Formula Type Hours Worked Determination Date */
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_SCHEDD_HRS_PRTE_F column_name DETERMINATION_RL',10);
    table_list(1).table_name := 'BEN_ELIG_SCHEDD_HRS_PRTE_F';
    table_list(1).column_name := 'DETERMINATION_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_HRS_WKD_IN_PERD_FCTR column_name HRS_WKD_DET_RL',10);
    table_list(2).table_name := 'BEN_HRS_WKD_IN_PERD_FCTR';
    table_list(2).column_name := 'HRS_WKD_DET_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_SCHEDD_HRS_PRTE_F column_name SCHEDD_HRS_RL',10);
    table_list(3).table_name := 'BEN_ELIG_SCHEDD_HRS_PRTE_F';
    table_list(3).column_name := 'SCHEDD_HRS_RL';
--
ELSIF p_formula_type_id = -154 THEN
/* Formula Type Five percent ownership rule*/
--
    hr_utility.set_location(' TO check table_nameBEN_PL_REGN_F column_name FIVE_PCT_OWNR_RL',10);
    table_list(1).table_name := 'BEN_PL_REGN_F';
    table_list(1).column_name := 'FIVE_PCT_OWNR_RL';
--
ELSIF p_formula_type_id = -153 THEN
/* Formula Type Formula Id */
--
    hr_utility.set_location(' TO check table_nameBEN_VRBL_RT_PRFL_RL_F column_name FORMULA_ID',10);
    table_list(1).table_name := 'BEN_VRBL_RT_PRFL_RL_F';
    table_list(1).column_name := 'FORMULA_ID';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PRTN_ELIGY_RL_F column_name FORMULA_ID',10);
    table_list(2).table_name := 'BEN_PRTN_ELIGY_RL_F';
    table_list(2).column_name := 'FORMULA_ID';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIGY_PRFL_RL_F column_name FORMULA_ID',10);
    table_list(3).table_name := 'BEN_ELIGY_PRFL_RL_F';
    table_list(3).column_name := 'FORMULA_ID';
--
ELSIF p_formula_type_id = -151 THEN
/* Formula Type */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTY_RT_DED_SCHED_F column_name DED_SCHED_RL',10);
    table_list(1).table_name := 'BEN_ACTY_RT_DED_SCHED_F';
    table_list(1).column_name := 'DED_SCHED_RL';
--
ELSIF p_formula_type_id = -146 THEN
/* Formula Type Automatic Enrollment Method */
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_OIPL_ENRT_F column_name AUTO_ENRT_MTHD_RL',10);
    table_list(1).table_name := 'BEN_LER_CHG_OIPL_ENRT_F';
    table_list(1).column_name := 'AUTO_ENRT_MTHD_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_PL_NIP_ENRT_F column_name AUTO_ENRT_MTHD_RL',10);
    table_list(2).table_name := 'BEN_LER_CHG_PL_NIP_ENRT_F';
    table_list(2).column_name := 'AUTO_ENRT_MTHD_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PTIP_F column_name AUTO_ENRT_MTHD_RL',10);
    table_list(3).table_name := 'BEN_PTIP_F';
    table_list(3).column_name := 'AUTO_ENRT_MTHD_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name AUTO_ENRT_MTHD_RL',10);
    table_list(4).table_name := 'BEN_PL_F';
    table_list(4).column_name := 'AUTO_ENRT_MTHD_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PLIP_F column_name AUTO_ENRT_MTHD_RL',10);
    table_list(5).table_name := 'BEN_PLIP_F';
    table_list(5).column_name := 'AUTO_ENRT_MTHD_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PGM_F column_name AUTO_ENRT_MTHD_RL',10);
    table_list(6).table_name := 'BEN_PGM_F';
    table_list(6).column_name := 'AUTO_ENRT_MTHD_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_OIPL_F column_name AUTO_ENRT_MTHD_RL',10);
    table_list(7).table_name := 'BEN_OIPL_F';
    table_list(7).column_name := 'AUTO_ENRT_MTHD_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_PGM_ENRT_F column_name AUTO_ENRT_MTHD_RL',10);
    table_list(8).table_name := 'BEN_LER_CHG_PGM_ENRT_F';
    table_list(8).column_name := 'AUTO_ENRT_MTHD_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_PLIP_ENRT_F column_name AUTO_ENRT_MTHD_RL',10);
    table_list(9).table_name := 'BEN_LER_CHG_PLIP_ENRT_F';
    table_list(9).column_name := 'AUTO_ENRT_MTHD_RL';
--
ELSIF p_formula_type_id = -145 THEN
/* Formula Type Age Determination Date */
--
    hr_utility.set_location(' TO check table_nameBEN_AGE_FCTR column_name AGE_DET_RL',10);
    table_list(1).table_name := 'BEN_AGE_FCTR';
    table_list(1).column_name := 'AGE_DET_RL';
--
ELSIF p_formula_type_id = -143 THEN
/* Formula Type Enrollment Certification Required */
--
    hr_utility.set_location(' TO check table_nameBEN_BNFT_RSTRN_CTFN_F column_name CTFN_RQD_ELSIF_RL',10);
    table_list(1).table_name := 'BEN_BNFT_RSTRN_CTFN_F';
    table_list(1).column_name := 'CTFN_RQD_ELSIF_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ENRT_CTFN_F column_name CTFN_RQD_ELSIF_RL',10);
    table_list(2).table_name := 'BEN_ENRT_CTFN_F';
    table_list(2).column_name := 'CTFN_RQD_ELSIF_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_RQRS_ENRT_CTFN_F column_name CTFN_RQD_ELSIF_RL',10);
    table_list(3).table_name := 'BEN_LER_RQRS_ENRT_CTFN_F';
    table_list(3).column_name := 'CTFN_RQD_ELSIF_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_ENRT_CTFN_F column_name CTFN_RQD_ELSIF_RL',10);
    table_list(4).table_name := 'BEN_LER_ENRT_CTFN_F';
    table_list(4).column_name := 'CTFN_RQD_ELSIF_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_CNTNU_PRTN_CTFN_TYP_F column_name CTFN_RQD_WHEN_RL',10);
    table_list(5).table_name := 'BEN_CNTNU_PRTN_CTFN_TYP_F';
    table_list(5).column_name := 'CTFN_RQD_WHEN_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ACTY_BASE_RT_CTFN_F column_name CTFN_RQD_WHEN_RL',10);
    table_list(6).table_name := 'BEN_ACTY_BASE_RT_CTFN_F';
    table_list(6).column_name := 'CTFN_RQD_WHEN_RL';
--
ELSIF p_formula_type_id = -142 THEN
/* Formula Type Payment Must Be Received */
--
    hr_utility.set_location(' TO check table_nameBEN_CNTNG_PRTN_ELIG_PRFL_F column_name PYMT_MUST_BE_RCVD_RL',10);
    table_list(1).table_name := 'BEN_CNTNG_PRTN_ELIG_PRFL_F';
    table_list(1).column_name := 'PYMT_MUST_BE_RCVD_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_CNTNG_PRTN_PRFL_RT_F column_name PYMT_MUST_BE_RCVD_RL',10);
    table_list(2).table_name := 'BEN_CNTNG_PRTN_PRFL_RT_F';
    table_list(2).column_name := 'PYMT_MUST_BE_RCVD_RL';
--
ELSIF p_formula_type_id = -83 THEN
/* Formula Type Participation Eligibility End Date */
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_TO_PRTE_RSN_F column_name PRTN_EFF_END_DT_RL',10);
    table_list(1).table_name := 'BEN_ELIG_TO_PRTE_RSN_F';
    table_list(1).column_name := 'PRTN_EFF_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PRTN_ELIG_F column_name PRTN_EFF_END_DT_RL',10);
    table_list(2).table_name := 'BEN_PRTN_ELIG_F';
    table_list(2).column_name := 'PRTN_EFF_END_DT_RL';
--
ELSIF p_formula_type_id = -82 THEN
/* Formula Type Participation Eligibility Start Date */
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_TO_PRTE_RSN_F column_name PRTN_EFF_STRT_DT_RL',10);
    table_list(1).table_name := 'BEN_ELIG_TO_PRTE_RSN_F';
    table_list(1).column_name := 'PRTN_EFF_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PRTN_ELIG_F column_name PRTN_EFF_STRT_DT_RL',10);
    table_list(2).table_name := 'BEN_PRTN_ELIG_F';
    table_list(2).column_name := 'PRTN_EFF_STRT_DT_RL';
--
ELSIF p_formula_type_id = -67 THEN
/* Formula Type Rate End Date */
--
    hr_utility.set_location(' TO check table_nameBEN_ENRT_PERD column_name RT_END_DT_RL',10);
    table_list(1).table_name := 'BEN_ENRT_PERD';
    table_list(1).column_name := 'RT_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LEE_RSN_F column_name RT_END_DT_RL',10);
    table_list(2).table_name := 'BEN_LEE_RSN_F';
    table_list(2).column_name := 'RT_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PTIP_F column_name RT_END_DT_RL',10);
    table_list(3).table_name := 'BEN_PTIP_F';
    table_list(3).column_name := 'RT_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PLIP_F column_name RT_END_DT_RL',10);
    table_list(4).table_name := 'BEN_PLIP_F';
    table_list(4).column_name := 'RT_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name RT_END_DT_RL',10);
    table_list(5).table_name := 'BEN_PL_F';
    table_list(5).column_name := 'RT_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PGM_F column_name RT_END_DT_RL',10);
    table_list(6).table_name := 'BEN_PGM_F';
    table_list(6).column_name := 'RT_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ENRT_PERD_FOR_PL_F column_name RT_END_DT_RL',10);
    table_list(7).table_name := 'BEN_ENRT_PERD_FOR_PL_F';
    table_list(7).column_name := 'RT_END_DT_RL';
--
ELSIF p_formula_type_id = -66 THEN
/* Formula Type Rate Start Date */
--
    hr_utility.set_location(' TO check table_nameBEN_ENRT_PERD column_name RT_STRT_DT_RL',10);
    table_list(1).table_name := 'BEN_ENRT_PERD';
    table_list(1).column_name := 'RT_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ENRT_RT column_name RT_STRT_DT_RL',10);
    table_list(2).table_name := 'BEN_ENRT_RT';
    table_list(2).column_name := 'RT_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ENRT_PERD_FOR_PL_F column_name RT_STRT_DT_RL',10);
    table_list(3).table_name := 'BEN_ENRT_PERD_FOR_PL_F';
    table_list(3).column_name := 'RT_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PTIP_F column_name RT_STRT_DT_RL',10);
    table_list(4).table_name := 'BEN_PTIP_F';
    table_list(4).column_name := 'RT_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name RT_STRT_DT_RL',10);
    table_list(5).table_name := 'BEN_PL_F';
    table_list(5).column_name := 'RT_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PLIP_F column_name RT_STRT_DT_RL',10);
    table_list(6).table_name := 'BEN_PLIP_F';
    table_list(6).column_name := 'RT_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PGM_F column_name RT_STRT_DT_RL',10);
    table_list(7).table_name := 'BEN_PGM_F';
    table_list(7).column_name := 'RT_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LEE_RSN_F column_name RT_STRT_DT_RL',10);
    table_list(8).table_name := 'BEN_LEE_RSN_F';
    table_list(8).column_name := 'RT_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ENRT_RT_RBV column_name RT_STRT_DT_RL',10);
    table_list(9).table_name := 'BEN_ENRT_RT_RBV';
    table_list(9).column_name := 'RT_STRT_DT_RL';
--
ELSIF p_formula_type_id = -52 THEN
/* Formula Type Payment schedule */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTY_RT_PYMT_SCHED_F column_name PYMT_SCHED_RL',10);
    table_list(1).table_name := 'BEN_ACTY_RT_PYMT_SCHED_F';
    table_list(1).column_name := 'PYMT_SCHED_RL';
--
ELSIF p_formula_type_id = -49 THEN
/* Formula Type Coverage Amount Calculation */
--
    hr_utility.set_location(' TO check table_nameBEN_CVG_AMT_CALC_MTHD_F column_name VAL_CALC_RL',10);
    table_list(1).table_name := 'BEN_CVG_AMT_CALC_MTHD_F';
    table_list(1).column_name := 'VAL_CALC_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_BNFT_VRBL_RT_RL_F column_name FORMULA_ID',10);
    table_list(2).table_name := 'BEN_BNFT_VRBL_RT_RL_F';
    table_list(2).column_name := 'FORMULA_ID';
--
--
    hr_utility.set_location(' TO check table_nameBEN_VRBL_RT_RL_F column_name FORMULA_ID',10);
    table_list(3).table_name := 'BEN_VRBL_RT_RL_F';
    table_list(3).column_name := 'FORMULA_ID';
--
ELSIF p_formula_type_id = -48 THEN
/* Formula Type Partial Month Effective Date Determination */
--
    hr_utility.set_location(' TO check table_nameBEN_ACTY_BASE_RT_F column_name PRTL_MO_EFF_DT_DET_RL',10);
    table_list(1).table_name := 'BEN_ACTY_BASE_RT_F';
    table_list(1).column_name := 'PRTL_MO_EFF_DT_DET_RL';
--
ELSIF p_formula_type_id = -46 THEN
/* Formula Type Person Change Causes Life Event */
--
    hr_utility.set_location(' TO check table_nameBEN_LER_PER_INFO_CS_LER_F column_name LER_PER_INFO_CS_LER_RL',10);
    table_list(1).table_name := 'BEN_LER_PER_INFO_CS_LER_F';
    table_list(1).column_name := 'LER_PER_INFO_CS_LER_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PER_INFO_CHG_CS_LER_F column_name PER_INFO_CHG_CS_LER_RL',10);
    table_list(2).table_name := 'BEN_PER_INFO_CHG_CS_LER_F';
    table_list(2).column_name := 'PER_INFO_CHG_CS_LER_RL';
--
ELSIF p_formula_type_id = -45 THEN
/* Formula Type To Be Sent Date */
--
    hr_utility.set_location(' TO check table_nameBEN_CM_TYP_F column_name TO_BE_SENT_DT_RL',10);
    table_list(1).table_name := 'BEN_CM_TYP_F';
    table_list(1).column_name := 'TO_BE_SENT_DT_RL';
--
ELSIF p_formula_type_id = -43 THEN
/* Formula Type Certification Allow Reimbursement */
--
    hr_utility.set_location(' TO check table_nameBEN_PL_GD_R_SVC_CTFN_F column_name CTFN_RQD_ELSIF_RL',10);
    table_list(1).table_name := 'BEN_PL_GD_R_SVC_CTFN_F';
    table_list(1).column_name := 'CTFN_RQD_ELSIF_RL';
--
ELSIF p_formula_type_id = -42 THEN
/* Formula Type */
--
    hr_utility.set_location(' TO check table_nameBEN_PL_REGN_F column_name CNTR_NNDSCRN_RL',10);
    table_list(1).table_name := 'BEN_PL_REGN_F';
    table_list(1).column_name := 'CNTR_NNDSCRN_RL';
--
ELSIF p_formula_type_id = -41 THEN
/* Formula Type */
--
    hr_utility.set_location(' TO check table_nameBEN_PL_REGN_F column_name CVG_NNDSCRN_RL',10);
    table_list(1).table_name := 'BEN_PL_REGN_F';
    table_list(1).column_name := 'CVG_NNDSCRN_RL';
--
ELSIF p_formula_type_id = -39 THEN
/* Formula Type */
--
    hr_utility.set_location(' TO check table_nameBEN_PL_REGN_F column_name KEY_EE_DET_RL',10);
    table_list(1).table_name := 'BEN_PL_REGN_F';
    table_list(1).column_name := 'KEY_EE_DET_RL';
--
ELSIF p_formula_type_id = -36 THEN
/* Formula Type Change Dependent Coverage */
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_DPNT_CVG_F column_name LER_CHG_DPNT_CVG_RL',10);
    table_list(1).table_name := 'BEN_LER_CHG_DPNT_CVG_F';
    table_list(1).column_name := 'LER_CHG_DPNT_CVG_RL';
--
ELSIF p_formula_type_id = -35 THEN
/* Formula Type Dependent Eligibility */
--
    hr_utility.set_location(' TO check table_nameBEN_APLD_DPNT_CVG_ELIG_PRFL_F column_name APLD_DPNT_CVG_ELIG_RL',10);
    table_list(1).table_name := 'BEN_APLD_DPNT_CVG_ELIG_PRFL_F';
    table_list(1).column_name := 'APLD_DPNT_CVG_ELIG_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_DPNT_CVG_ELIGY_PRFL_F column_name DPNT_CVG_ELIG_DET_RL',10);
    table_list(2).table_name := 'BEN_DPNT_CVG_ELIGY_PRFL_F';
    table_list(2).column_name := 'DPNT_CVG_ELIG_DET_RL';
--
ELSIF p_formula_type_id = -32 THEN
/* Formula Type Default Enrollment */
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_OIPL_ENRT_F column_name DFLT_ENRT_RL',10);
    table_list(1).table_name := 'BEN_LER_CHG_OIPL_ENRT_F';
    table_list(1).column_name := 'DFLT_ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_PGM_ENRT_F column_name DFLT_ENRT_RL',10);
    table_list(2).table_name := 'BEN_LER_CHG_PGM_ENRT_F';
    table_list(2).column_name := 'DFLT_ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_PLIP_ENRT_F column_name DFLT_ENRT_RL',10);
    table_list(3).table_name := 'BEN_LER_CHG_PLIP_ENRT_F';
    table_list(3).column_name := 'DFLT_ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_PL_NIP_ENRT_F column_name DFLT_ENRT_RL',10);
    table_list(4).table_name := 'BEN_LER_CHG_PL_NIP_ENRT_F';
    table_list(4).column_name := 'DFLT_ENRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PLIP_F column_name DFLT_ENRT_DET_RL',10);
    table_list(5).table_name := 'BEN_PLIP_F';
    table_list(5).column_name := 'DFLT_ENRT_DET_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PTIP_F column_name DFLT_ENRT_DET_RL',10);
    table_list(6).table_name := 'BEN_PTIP_F';
    table_list(6).column_name := 'DFLT_ENRT_DET_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name NIP_DFLT_ENRT_DET_RL',10);
    table_list(7).table_name := 'BEN_PL_F';
    table_list(7).column_name := 'NIP_DFLT_ENRT_DET_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_OIPL_F column_name DFLT_ENRT_DET_RL',10);
    table_list(8).table_name := 'BEN_OIPL_F';
    table_list(8).column_name := 'DFLT_ENRT_DET_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_PTIP_ENRT_F column_name DFLT_ENRT_RL',10);
    table_list(9).table_name := 'BEN_LER_CHG_PTIP_ENRT_F';
    table_list(9).column_name := 'DFLT_ENRT_RL';
--
ELSIF p_formula_type_id = -31 THEN
/* Formula Type Highly computed determination*/
--
    hr_utility.set_location(' TO check table_nameBEN_PL_REGN_F column_name HGHLY_COMPD_DET_RL',10);
    table_list(1).table_name := 'BEN_PL_REGN_F';
    table_list(1).column_name := 'HGHLY_COMPD_DET_RL';
--
ELSIF p_formula_type_id = -30 THEN
/* Formula Type Enrollment End */
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_AGE_CVG_F column_name CVG_THRU_RL',10);
    table_list(1).table_name := 'BEN_ELIG_AGE_CVG_F';
    table_list(1).column_name := 'CVG_THRU_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_MLTRY_STAT_CVG_F column_name CVG_THRU_RL',10);
    table_list(2).table_name := 'BEN_ELIG_MLTRY_STAT_CVG_F';
    table_list(2).column_name := 'CVG_THRU_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_MRTL_STAT_CVG_F column_name CVG_THRU_RL',10);
    table_list(3).table_name := 'BEN_ELIG_MRTL_STAT_CVG_F';
    table_list(3).column_name := 'CVG_THRU_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PTIP_F column_name ENRT_CVG_END_DT_RL',10);
    table_list(4).table_name := 'BEN_PTIP_F';
    table_list(4).column_name := 'ENRT_CVG_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name ENRT_CVG_END_DT_RL',10);
    table_list(5).table_name := 'BEN_PL_F';
    table_list(5).column_name := 'ENRT_CVG_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PLIP_F column_name ENRT_CVG_END_DT_RL',10);
    table_list(6).table_name := 'BEN_PLIP_F';
    table_list(6).column_name := 'ENRT_CVG_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PGM_F column_name ENRT_CVG_END_DT_RL',10);
    table_list(7).table_name := 'BEN_PGM_F';
    table_list(7).column_name := 'ENRT_CVG_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_DPNT_CVG_F column_name CVG_EFF_END_RL',10);
    table_list(8).table_name := 'BEN_LER_CHG_DPNT_CVG_F';
    table_list(8).column_name := 'CVG_EFF_END_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LEE_RSN_F column_name ENRT_CVG_END_DT_RL',10);
    table_list(9).table_name := 'BEN_LEE_RSN_F';
    table_list(9).column_name := 'ENRT_CVG_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ENRT_PERD_FOR_PL_F column_name ENRT_CVG_END_DT_RL',10);
    table_list(10).table_name := 'BEN_ENRT_PERD_FOR_PL_F';
    table_list(10).column_name := 'ENRT_CVG_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ENRT_PERD column_name ENRT_CVG_END_DT_RL',10);
    table_list(11).table_name := 'BEN_ENRT_PERD';
    table_list(11).column_name := 'ENRT_CVG_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_STDNT_STAT_CVG_F column_name CVG_THRU_RL',10);
    table_list(12).table_name := 'BEN_ELIG_STDNT_STAT_CVG_F';
    table_list(12).column_name := 'CVG_THRU_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_DSBLD_STAT_CVG_F column_name CVG_THRU_RL',10);
    table_list(13).table_name := 'BEN_ELIG_DSBLD_STAT_CVG_F';
    table_list(13).column_name := 'CVG_THRU_RL';
--
ELSIF p_formula_type_id = -29 THEN
/* Formula Type Enrollment Coverage Start Date */
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_AGE_CVG_F column_name CVG_STRT_RL',10);
    table_list(1).table_name := 'BEN_ELIG_AGE_CVG_F';
    table_list(1).column_name := 'CVG_STRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_DSBLD_STAT_CVG_F column_name CVG_STRT_RL',10);
    table_list(2).table_name := 'BEN_ELIG_DSBLD_STAT_CVG_F';
    table_list(2).column_name := 'CVG_STRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_MLTRY_STAT_CVG_F column_name CVG_STRT_RL',10);
    table_list(3).table_name := 'BEN_ELIG_MLTRY_STAT_CVG_F';
    table_list(3).column_name := 'CVG_STRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PTIP_F column_name ENRT_CVG_STRT_DT_RL',10);
    table_list(4).table_name := 'BEN_PTIP_F';
    table_list(4).column_name := 'ENRT_CVG_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name ENRT_CVG_STRT_DT_RL',10);
    table_list(5).table_name := 'BEN_PL_F';
    table_list(5).column_name := 'ENRT_CVG_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PLIP_F column_name ENRT_CVG_STRT_DT_RL',10);
    table_list(6).table_name := 'BEN_PLIP_F';
    table_list(6).column_name := 'ENRT_CVG_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PGM_F column_name ENRT_CVG_STRT_DT_RL',10);
    table_list(7).table_name := 'BEN_PGM_F';
    table_list(7).column_name := 'ENRT_CVG_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_DPNT_CVG_F column_name CVG_EFF_STRT_RL',10);
    table_list(8).table_name := 'BEN_LER_CHG_DPNT_CVG_F';
    table_list(8).column_name := 'CVG_EFF_STRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_LEE_RSN_F column_name ENRT_CVG_STRT_DT_RL',10);
    table_list(9).table_name := 'BEN_LEE_RSN_F';
    table_list(9).column_name := 'ENRT_CVG_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ENRT_PERD_FOR_PL_F column_name ENRT_CVG_STRT_DT_RL',10);
    table_list(10).table_name := 'BEN_ENRT_PERD_FOR_PL_F';
    table_list(10).column_name := 'ENRT_CVG_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ENRT_PERD column_name ENRT_CVG_STRT_DT_RL',10);
    table_list(11).table_name := 'BEN_ENRT_PERD';
    table_list(11).column_name := 'ENRT_CVG_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_STDNT_STAT_CVG_F column_name CVG_STRT_RL',10);
    table_list(12).table_name := 'BEN_ELIG_STDNT_STAT_CVG_F';
    table_list(12).column_name := 'CVG_STRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_PER_ELCTBL_CHC column_name ENRT_CVG_STRT_DT_RL',10);
    table_list(13).table_name := 'BEN_ELIG_PER_ELCTBL_CHC';
    table_list(13).column_name := 'ENRT_CVG_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_MRTL_STAT_CVG_F column_name CVG_STRT_RL',10);
    table_list(14).table_name := 'BEN_ELIG_MRTL_STAT_CVG_F';
    table_list(14).column_name := 'CVG_STRT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_PER_ELCTBL_CHC_RBV column_name ENRT_CVG_STRT_DT_RL',10);
    table_list(15).table_name := 'BEN_ELIG_PER_ELCTBL_CHC_RBV';
    table_list(15).column_name := 'ENRT_CVG_STRT_DT_RL';
--
ELSIF p_formula_type_id = -28 THEN
/* Formula Type Dependent Coverage End Date */
--
    hr_utility.set_location(' TO check table_nameBEN_DPNT_CVG_RQD_RLSHP_F column_name CVG_THRU_DT_RL',10);
    table_list(1).table_name := 'BEN_DPNT_CVG_RQD_RLSHP_F';
    table_list(1).column_name := 'CVG_THRU_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PTIP_F column_name DPNT_CVG_END_DT_RL',10);
    table_list(2).table_name := 'BEN_PTIP_F';
    table_list(2).column_name := 'DPNT_CVG_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name DPNT_CVG_END_DT_RL',10);
    table_list(3).table_name := 'BEN_PL_F';
    table_list(3).column_name := 'DPNT_CVG_END_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PGM_F column_name DPNT_CVG_END_DT_RL',10);
    table_list(4).table_name := 'BEN_PGM_F';
    table_list(4).column_name := 'DPNT_CVG_END_DT_RL';
--
ELSIF p_formula_type_id = -27 THEN
/* Formula Type Dependent Coverage Start Date */
--
    hr_utility.set_location(' TO check table_nameBEN_DPNT_CVG_RQD_RLSHP_F column_name CVG_STRT_DT_RL',10);
    table_list(1).table_name := 'BEN_DPNT_CVG_RQD_RLSHP_F';
    table_list(1).column_name := 'CVG_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_PER_ELCTBL_CHC column_name DPNT_CVG_STRT_DT_RL',10);
    table_list(2).table_name := 'BEN_ELIG_PER_ELCTBL_CHC';
    table_list(2).column_name := 'DPNT_CVG_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PTIP_F column_name DPNT_CVG_STRT_DT_RL',10);
    table_list(3).table_name := 'BEN_PTIP_F';
    table_list(3).column_name := 'DPNT_CVG_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name DPNT_CVG_STRT_DT_RL',10);
    table_list(4).table_name := 'BEN_PL_F';
    table_list(4).column_name := 'DPNT_CVG_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PGM_F column_name DPNT_CVG_STRT_DT_RL',10);
    table_list(5).table_name := 'BEN_PGM_F';
    table_list(5).column_name := 'DPNT_CVG_STRT_DT_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_PER_ELCTBL_CHC_RBV column_name DPNT_CVG_STRT_DT_RL',10);
    table_list(6).table_name := 'BEN_ELIG_PER_ELCTBL_CHC_RBV';
    table_list(6).column_name := 'DPNT_CVG_STRT_DT_RL';
--
ELSIF p_formula_type_id = -26 THEN
/* Formula Type Dependent Certification Required */
--
    hr_utility.set_location(' TO check table_nameBEN_LER_CHG_DPNT_CVG_CTFN_F column_name CTFN_RQD_ELSIF_RL',10);
    table_list(1).table_name := 'BEN_LER_CHG_DPNT_CVG_CTFN_F';
    table_list(1).column_name := 'CTFN_RQD_ELSIF_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_DPNT_CVG_CTFN_F column_name CTFN_RQD_ELSIF_RL',10);
    table_list(2).table_name := 'BEN_PL_DPNT_CVG_CTFN_F';
    table_list(2).column_name := 'CTFN_RQD_ELSIF_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PGM_DPNT_CVG_CTFN_F column_name CTFN_RQD_ELSIF_RL',10);
    table_list(3).table_name := 'BEN_PGM_DPNT_CVG_CTFN_F';
    table_list(3).column_name := 'CTFN_RQD_ELSIF_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PTIP_DPNT_CVG_CTFN_F column_name CTFN_RQD_WHEN_RL',10);
    table_list(4).table_name := 'BEN_PTIP_DPNT_CVG_CTFN_F';
    table_list(4).column_name := 'CTFN_RQD_WHEN_RL';
--
ELSIF p_formula_type_id = -25 THEN
/* Formula Type Beneficiary Certification Required */
--
    hr_utility.set_location(' TO check table_nameBEN_LER_BNFT_RSTRN_CTFN_F column_name CTFN_RQD_ELSIF_RL',10);
    table_list(1).table_name := 'BEN_LER_BNFT_RSTRN_CTFN_F';
    table_list(1).column_name := 'CTFN_RQD_ELSIF_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_BNF_CTFN_F column_name CTFN_RQD_ELSIF_RL',10);
    table_list(2).table_name := 'BEN_PL_BNF_CTFN_F';
    table_list(2).column_name := 'CTFN_RQD_ELSIF_RL';
--
ELSIF p_formula_type_id = -21 THEN
/* Formula Type Family Member Determination */
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_TO_PRTE_RSN_F column_name VRFY_FMLY_MMBR_RL',10);
    table_list(1).table_name := 'BEN_ELIG_TO_PRTE_RSN_F';
    table_list(1).column_name := 'VRFY_FMLY_MMBR_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PGM_F column_name VRFY_FMLY_MMBR_RL',10);
    table_list(2).table_name := 'BEN_PGM_F';
    table_list(2).column_name := 'VRFY_FMLY_MMBR_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name VRFY_FMLY_MMBR_RL',10);
    table_list(3).table_name := 'BEN_PL_F';
    table_list(3).column_name := 'VRFY_FMLY_MMBR_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PTIP_F column_name VRFY_FMLY_MMBR_RL',10);
    table_list(4).table_name := 'BEN_PTIP_F';
    table_list(4).column_name := 'VRFY_FMLY_MMBR_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_PLIP_F column_name VRFY_FMLY_MMBR_RL',10);
    table_list(5).table_name := 'BEN_PLIP_F';
    table_list(5).column_name := 'VRFY_FMLY_MMBR_RL';
--
--
    hr_utility.set_location(' TO check table_nameBEN_OIPL_F column_name VRFY_FMLY_MMBR_RL',10);
    table_list(6).table_name := 'BEN_OIPL_F';
    table_list(6).column_name := 'VRFY_FMLY_MMBR_RL';
/*
--
-- Formula_type_id for the following table_name and column_name combination hasn't been found yet.
--

ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_TTL_CVG_VOL_PRTE_F column_name CVG_VOL_DET_RL',10);
    table_list(1).table_name := 'BEN_ELIG_TTL_CVG_VOL_PRTE_F';
    table_list(1).column_name := 'CVG_VOL_DET_RL';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_TTL_PRTT_PRTE_F column_name PRTT_DET_RL',10);
    table_list(1).table_name := 'BEN_ELIG_TTL_PRTT_PRTE_F';
    table_list(1).column_name := 'PRTT_DET_RL';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_PL_F column_name FRFS_DISTR_MTHD_RL',10);
    table_list(1).table_name := 'BEN_PL_F';
    table_list(1).column_name := 'FRFS_DISTR_MTHD_RL';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_PL_GD_R_SVC_CTFN_F column_name LACK_CTFN_DENY_RMBMT_RL',10);
    table_list(1).table_name := 'BEN_PL_GD_R_SVC_CTFN_F';
    table_list(1).column_name := 'LACK_CTFN_DENY_RMBMT_RL';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_VSTG_SCHED_F column_name FORMULA_ID',10);
    table_list(1).table_name := 'BEN_VSTG_SCHED_F';
    table_list(1).column_name := 'FORMULA_ID';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_VSTG_SCHED_F column_name BIS_RL',10);
    table_list(1).table_name := 'BEN_VSTG_SCHED_F';
    table_list(1).column_name := 'BIS_RL';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_VSTG_FOR_ACTY_RT_F column_name LOS_OVRID_RL',10);
    table_list(1).table_name := 'BEN_VSTG_FOR_ACTY_RT_F';
    table_list(1).column_name := 'LOS_OVRID_RL';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_VSTG_FOR_ACTY_RT_F column_name BIS_OVRID_RL',10);
    table_list(1).table_name := 'BEN_VSTG_FOR_ACTY_RT_F';
    table_list(1).column_name := 'BIS_OVRID_RL';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_VSTG_FOR_ACTY_RT_F column_name AGE_DET_OVRID_RL',10);
    table_list(1).table_name := 'BEN_VSTG_FOR_ACTY_RT_F';
    table_list(1).column_name := 'AGE_DET_OVRID_RL';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_PREM_CSTG_BY_SGMT_F column_name SGMT_CSTG_MTHD_RL',10);
    table_list(1).table_name := 'BEN_PREM_CSTG_BY_SGMT_F';
    table_list(1).column_name := 'SGMT_CSTG_MTHD_RL';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_TTL_PRTT_PRTE_F column_name PRTT_DET_RL',10);
    table_list(1).table_name := 'BEN_ELIG_TTL_PRTT_PRTE_F';
    table_list(1).column_name := 'PRTT_DET_RL';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_ELIG_TTL_CVG_VOL_PRTE_F column_name CVG_VOL_DET_RL',10);
    table_list(1).table_name := 'BEN_ELIG_TTL_CVG_VOL_PRTE_F';
    table_list(1).column_name := 'CVG_VOL_DET_RL';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_TTL_PRTT_RT_F column_name PRTT_DET_RL',10);
    table_list(1).table_name := 'BEN_TTL_PRTT_RT_F';
    table_list(1).column_name := 'PRTT_DET_RL';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_TTL_CVG_VOL_RT_F column_name CVG_VOL_DET_RL',10);
    table_list(1).table_name := 'BEN_TTL_CVG_VOL_RT_F';
    table_list(1).column_name := 'CVG_VOL_DET_RL';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_POP_UP_MESSAGES column_name NO_FORMULA_FLAG',10);
    table_list(1).table_name := 'BEN_POP_UP_MESSAGES';
    table_list(1).column_name := 'NO_FORMULA_FLAG';
--
ELSIF p_formula_type_id =  THEN
--
    hr_utility.set_location(' TO check table_nameBEN_PL_GD_R_SVC_CTFN_F column_name LACK_CTFN_DENY_RMBMT_RL',10);
    table_list(1).table_name := 'BEN_PL_GD_R_SVC_CTFN_F';
    table_list(1).column_name := 'LACK_CTFN_DENY_RMBMT_RL';
--    */
END IF;

	hr_utility.set_location ('Leaving ' || l_proc,10);

END populate_table_list;

--
-- ============================================================================
--               <<Function: chk_formula_exists_in_ben>>
-- ============================================================================
--
FUNCTION chk_formula_exists_in_ben(p_formula_id IN NUMBER,
                                   p_formula_type_id IN NUMBER,
								   p_effective_date IN DATE Default NULL,
								   p_business_group_id IN NUMBER Default NULL,
								   p_legislation_cd IN VARCHAR2 Default NULL
								   )
								   RETURN BOOLEAN IS
--
  L_proc        varchar2(80);
  g_debug       BOOLEAN;
--
BEGIN
  g_debug := hr_utility.debug_enabled;
  IF g_debug THEN
    l_proc := g_package||'.chk_formula_exists_in_ben';
    hr_utility.set_location ('Entering '|| l_proc,5);
  END IF;

  populate_table_list(p_formula_type_id);

  IF table_list.COUNT <> 0 THEN
     FOR i IN table_list.FIRST..table_list.LAST LOOP
       IF ben_batch_utils.rows_exist(table_list(i).table_name,
	                                 table_list(i).column_name,
            		                 p_formula_id) THEN
    -- one row exists so return true
          IF g_debug THEN
            hr_utility.set_location('Leaving:'||l_proc, 10);
          END IF;
          RETURN (TRUE);
	   END IF;
     END LOOP;
  END IF;
  -- return false as no rows exist
  IF g_debug THEN
	hr_utility.set_location ('Leaving ' || l_proc,10);
  END IF;
  RETURN (FALSE);
END;
--
END Ben_FastFormula_Check;

/
