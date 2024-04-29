--------------------------------------------------------
--  DDL for Package Body BEN_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_UTILITY" as
/* $Header: beutilit.pkb 120.6 2006/07/03 06:11:46 gsehgal ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= 'ben_utility.';  -- Global package name
--
----------------------------------------------------------------------------
---------------------------< decode_table_name >----------------------------
----------------------------------------------------------------------------
FUNCTION decode_table_name
   (
    p_table_name           IN VARCHAR2
) RETURN VARCHAR2
IS
  --
  l_return              VARCHAR2(240);
  --
BEGIN
  --
  IF p_table_name = 'BEN_PL_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94163_COMP_OBJ_TITLE_PLN');
  elsif p_table_name = 'BEN_OIPL_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94164_COMP_OBJ_TITLE_COP');
  elsif p_table_name = 'BEN_PL_REGY_BOD_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94165_COMP_OBJ_TITLE_PRB');
  elsif p_table_name = 'BEN_POPL_ENRT_TYP_CYCL_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94166_COMP_OBJ_TITLE_PET');
  elsif p_table_name = 'BEN_VALD_RLSHP_FOR_REIMB_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94167_COMP_OBJ_TITLE_VRP');
  elsif p_table_name = 'BEN_LER_CHG_PL_NIP_ENRT_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94168_COMP_OBJ_TITLE_LPE');
  elsif p_table_name = 'BEN_PL_GD_OR_SVC_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94169_COMP_OBJ_TITLE_VGS');
  elsif p_table_name = 'BEN_PLIP_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94170_COMP_OBJ_TITLE_CPP');
  elsif p_table_name = 'BEN_PL_REGN_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94171_COMP_OBJ_TITLE_PRG');
  elsif p_table_name = 'BEN_ELIG_TO_PRTE_RSN_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94172_COMP_OBJ_TITLE_PEO');
  elsif p_table_name = 'BEN_PRTN_ELIG_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94173_COMP_OBJ_TITLE_EPA');
  elsif p_table_name = 'BEN_CVG_AMT_CALC_MTHD_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94174_COMP_OBJ_TITLE_CCM');
  elsif p_table_name = 'BEN_LER_CHG_DPNT_CVG_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94175_COMP_OBJ_TITLE_LDC');
  elsif p_table_name = 'BEN_POPL_ORG_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94176_COMP_OBJ_TITLE_CPO');
  elsif p_table_name = 'BEN_ELIG_PER_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94177_COMP_OBJ_TITLE_PEP');
  elsif p_table_name = 'BEN_ACTY_BASE_RT_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94178_COMP_OBJ_TITLE_ABR');
  elsif p_table_name = 'BEN_PL_DPNT_CVG_CTFN_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94179_COMP_OBJ_TITLE_PND');
  elsif p_table_name = 'BEN_PL_BNF_CTFN_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94180_COMP_OBJ_TITLE_PCX');
  elsif p_table_name = 'BEN_POPL_RPTG_GRP_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94181_COMP_OBJ_TITLE_RGR');
  elsif p_table_name = 'BEN_PRTT_REIMBMT_RQST_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94182_COMP_OBJ_TITLE_PRC');
  elsif p_table_name = 'BEN_APLD_DPNT_CVG_ELIG_PRFL_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94183_COMP_OBJ_TITLE_ADE');
  elsif p_table_name = 'BEN_DSGN_RQMT_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94184_COMP_OBJ_TITLE_DDR');
  elsif p_table_name = 'BEN_ELIG_PRTT_ANTHR_PL_PRTE_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94185_COMP_OBJ_TITLE_EPP');
  elsif p_table_name = 'BEN_PL_R_OIPL_ASSET_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94186_COMP_OBJ_TITLE_POA');
  elsif p_table_name = 'BEN_PRTT_ENRT_RSLT_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94187_COMP_OBJ_TITLE_PEN');
  elsif p_table_name = 'BEN_VRBL_RT_PRFL_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94188_COMP_OBJ_TITLE_VPF');
  elsif p_table_name = 'BEN_WV_PRTN_RSN_PL_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94189_COMP_OBJ_TITLE_WPN');
  elsif p_table_name = 'BEN_BNFT_RSTRN_CTFN_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94190_COMP_OBJ_TITLE_BRC');
  elsif p_table_name = 'BEN_ELIG_PER_OPT_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94191_COMP_OBJ_TITLE_EPO');
  elsif p_table_name = 'BEN_PL_TYP_OPT_TYP_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94192_COMP_OBJ_TITLE_PON');
  elsif p_table_name = 'BEN_OPT_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94193_COMP_OBJ_TITLE_OPT');
  elsif p_table_name = 'BEN_ELIGY_PRFL_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94194_COMP_OBJ_TITLE_ELP');
  elsif p_table_name = 'BEN_VRBL_RT_ELIG_PRFL_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94195_COMP_OBJ_TITLE_VEP');
  elsif p_table_name = 'BEN_ACTL_PREM_VRBL_RT_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94196_COMP_OBJ_TITLE_APV');
  elsif p_table_name = 'BEN_ACTY_VRBL_RT_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94197_COMP_OBJ_TITLE_AVR');
  elsif p_table_name = 'BEN_BNFT_VRBL_RT_F'
  then
    l_return := fnd_message.get_string('BEN','BEN_94198_COMP_OBJ_TITLE_BVR');
  elsif p_table_name = 'BEN_ELIGY_PRFL_CRITERIA'
  then
    l_return := fnd_message.get_string('BEN','BEN_94199_COMP_OBJ_TITLE_XXX');
  elsif p_table_name = 'BEN_VRBL_RT_PRFL_CRITERIA'
  then
    l_return := fnd_message.get_string('BEN','BEN_94200_COMP_OBJ_TITLE_YYY');
  end if;
  --
  return l_return;
  --
END decode_table_name;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< child_exists_error >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE child_exists_error (
   p_table_name           IN   all_tables.table_name%TYPE,
   p_parent_table_name    IN   all_tables.table_name%TYPE DEFAULT NULL,
   p_parent_entity_name   IN   VARCHAR2 DEFAULT NULL
)
IS
--
  l_proc 	                varchar2(72) := g_package || 'child_exists_error';
  l_table_name                  all_tables.table_name%TYPE := null;
  l_parent_table_name           all_tables.table_name%TYPE := null;
  l_parent_user_table_name      varchar2(240);
  l_user_table_name             varchar2(240);
--
Begin
  --
  l_table_name := upper(p_table_name);
  l_parent_table_name := upper(p_parent_table_name);
  --
  IF l_parent_table_name IS NULL
  THEN
     --
     if l_table_name = 'BEN_ACTL_PREM_F' then
        fnd_message.set_name('BEN', 'BEN_91022_APR_EXISTS');
     -- elsif l_table_name = 'BEN_ACTN_TYP' then
     --   fnd_message.set_name('BEN', 'BEN_91000_ACT_EXISTS');
      elsif l_table_name = 'BEN_ACTY_BASE_RT_F' then
        fnd_message.set_name('BEN', 'BEN_91151_ABR_EXISTS');
      elsif l_table_name = 'BEN_ACTY_RT_DED_SCHED_F' then
        fnd_message.set_name('BEN', 'BEN_91165_ADS_EXISTS');
      elsif l_table_name = 'BEN_ELIG_SVC_AREA_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_91810_ESA_EXISTS');

     -- elsif l_table_name = 'BEN_ACTY_RT_FRGN_DED_SCHED_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_AFD_EXISTS');
     -- elsif l_table_name = 'BEN_ACTY_RT_FRGN_PYMT_SCHED_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_AFP_EXISTS');
     elsif l_table_name = 'BEN_ACTY_RT_PTD_LMT_F' then
       fnd_message.set_name('BEN', 'BEN_91772_APL_EXISTS');
      elsif l_table_name = 'BEN_ACTY_RT_PYMT_SCHED_F' then
        fnd_message.set_name('BEN', 'BEN_91993_APF_EXISTS');
      elsif l_table_name = 'BEN_ACTL_PREM_VRBL_RT_F' then
        fnd_message.set_name('BEN', 'BEN_91984_APV_EXISTS');

      elsif l_table_name = 'BEN_ACTL_PREM_VRBL_RT_RL_F' then
        fnd_message.set_name('BEN', 'BEN_91985_AVA_EXISTS');

      elsif l_table_name = 'BEN_ACTY_VRBL_RT_F' then
        fnd_message.set_name('BEN', 'BEN_91169_AVR_EXISTS');
     -- elsif l_table_name = 'BEN_AGE_FCTR' then
     --   fnd_message.set_name('BEN', 'BEN_91000_AGF_EXISTS');
        elsif l_table_name = 'BEN_AGE_RT_F' then
          fnd_message.set_name('BEN', 'BEN_91073_ART_EXISTS');
        elsif l_table_name = 'BEN_APLCN_TO_BNFT_POOL_F' then
          fnd_message.set_name('BEN', 'BEN_91994_ABP_EXISTS');

        elsif l_table_name = 'BEN_BNFT_POOL_RLOVR_RQMT_F' then
          fnd_message.set_name('BEN', 'BEN_91995_BPR_EXISTS');

        elsif l_table_name = 'BEN_BNFT_PRVDD_LDGR_F' then
          fnd_message.set_name('BEN', 'BEN_91996_BPL_EXISTS');

        elsif l_table_name = 'BEN_BNFT_PRVDR_POOL_F' then
          fnd_message.set_name('BEN', 'BEN_92019_BPP_EXISTS');

        elsif l_table_name = 'BEN_BNFT_VRBL_RT_F' then
          fnd_message.set_name('BEN', 'BEN_92031_BVR_EXISTS');

        elsif l_table_name = 'BEN_BNFT_VRBL_RT_RL_F' then
          fnd_message.set_name('BEN', 'BEN_92032_BRR_EXISTS');

        elsif l_table_name = 'BEN_CM_TYP_USG_F' then
          fnd_message.set_name('BEN', 'BEN_91890_CTU_EXISTS');

        elsif l_table_name = 'BEN_CM_TYP_TRGR_F' then
          fnd_message.set_name('BEN', 'BEN_91891_CTT_EXISTS');

      elsif l_table_name = 'BEN_APLD_DPNT_CVG_ELIG_PRFL_F' then
        fnd_message.set_name('BEN', 'BEN_91122_ADE_EXISTS');
     -- elsif l_table_name = 'BEN_ASNT_SET_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_AR_EXISTS');
     -- elsif l_table_name = 'BEN_BAL_TYP_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_BTP_EXISTS');
      elsif l_table_name = 'BEN_COMP_LVL_ACTY_RT_F' then
        fnd_message.set_name('BEN', 'BEN_91170_BTR_EXISTS');
     -- elsif l_table_name = 'BEN_BAL_TYP_RL_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_BRL_EXISTS');
     -- elsif l_table_name = 'BEN_BENEFICIARIES_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000__EXISTS');
      elsif l_table_name = 'BEN_BENEFIT_ACTIONS' then
        fnd_message.set_name('BEN', 'BEN_91805_BFT_EXISTS');

     -- elsif l_table_name = 'BEN_BENEFIT_CLASSIFICATIONS' then
     --   fnd_message.set_name('BEN', 'BEN_91000_BCL_EXISTS');
     -- elsif l_table_name = 'BEN_BENEFIT_CONTRIBUTIONS_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_BCO_EXISTS');
     -- elsif l_table_name = 'BEN_BENFTS_GRP' then
     --   fnd_message.set_name('BEN', 'BEN_91000_BNG_EXISTS');
     elsif l_table_name = 'BEN_BENFTS_GRP_RT_F' then
        fnd_message.set_name('BEN', 'BEN_92012_BRG_EXISTS');
     -- elsif l_table_name = 'BEN_BRGNG_UNIT_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_BUR_EXISTS');
        elsif l_table_name = 'BEN_CMBN_AGE_LOS_FCTR' then
          fnd_message.set_name('BEN', 'BEN_91074_CLA_EXISTS');
      elsif l_table_name = 'BEN_CMBN_AGE_LOS_RT_F' then
        fnd_message.set_name('BEN', 'BEN_92018_CMR_EXISTS');
     -- elsif l_table_name = 'BEN_CM_DLVRY_MED_TYP' then
     --   fnd_message.set_name('BEN', 'BEN_91000_CMD_EXISTS');
        elsif l_table_name = 'BEN_CM_DLVRY_MTHD_TYP' then
          fnd_message.set_name('BEN', 'BEN_91895_CMT_EXISTS');
        elsif l_table_name = 'BEN_CM_TYP_F' then
          fnd_message.set_name('BEN', 'BEN_91897_CCT_EXISTS');
      elsif l_table_name = 'BEN_CNTNG_PRTN_ELIG_PRFL_F' then
        fnd_message.set_name('BEN', 'BEN_92042_CGP_EXISTS');
      elsif l_table_name = 'BEN_CNTNU_PRTN_CTFN_TYP_F' then
        fnd_message.set_name('BEN', 'BEN_92022_CPC_EXISTS');
     -- elsif l_table_name = 'BEN_COMP_ASSET' then
     --   fnd_message.set_name('BEN', 'BEN_91000_CMA_EXISTS');
     -- elsif l_table_name = 'BEN_COMP_ELIG_PRFL_RL_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_CPF_EXISTS');
     -- elsif l_table_name = 'BEN_COMP_LVL_FCTR' then
     --   fnd_message.set_name('BEN', 'BEN_91000_CLF_EXISTS');
        elsif l_table_name = 'BEN_COMP_LVL_RT_F' then
          fnd_message.set_name('BEN', 'BEN_91077_CLR_EXISTS');
     -- elsif l_table_name = 'BEN_CONTROL' then
     --   fnd_message.set_name('BEN', 'BEN_91000_CTRL_EXISTS');
     -- elsif l_table_name = 'BEN_COVERED_DEPENDENTS_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000__EXISTS');
     -- elsif l_table_name = 'BEN_CRT_ORDR_CLMNT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_COC_EXISTS');
     elsif l_table_name = 'BEN_CRT_ORDR_CVRD_PER' then
        fnd_message.set_name('BEN', 'BEN_92030_CRD_EXISTS');

      elsif l_table_name = 'BEN_CR_MAY_BE_RLD_INTO_PL_F' then
        fnd_message.set_name('BEN', 'BEN_91287_CRP_EXISTS');
      elsif l_table_name = 'BEN_CSS_RLTD_PER_PER_IN_LER_F' then
        fnd_message.set_name('BEN', 'BEN_91023_CSR_EXISTS');
      elsif l_table_name = 'BEN_CVG_AMT_CALC_MTHD_F' then
        fnd_message.set_name('BEN', 'BEN_91078_CCM_EXISTS');
      elsif l_table_name = 'BEN_CVRD_DPNT_CTFN_PRVDD_F' then
        fnd_message.set_name('BEN', 'BEN_92061_CCP_EXISTS');

      elsif l_table_name = 'BEN_CBR_QUALD_BNF' then
        fnd_message.set_name('BEN', 'BEN_92510_CQB_EXISTS');

      elsif l_table_name = 'BEN_DED_SCHED_PY_FREQ' then
        fnd_message.set_name('BEN', 'BEN_92002_DSQ_EXISTS');
     -- elsif l_table_name = 'BEN_DPNT_CVG_ELG_PR_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_DCE_EXISTS');
      elsif l_table_name = 'BEN_DPNT_CVG_RQD_RLSHP_F' then
        fnd_message.set_name('BEN', 'BEN_92034_DCR_EXISTS');
      elsif l_table_name = 'BEN_DPNT_CVRD_ANTHR_PL_CVG_F' then
        fnd_message.set_name('BEN', 'BEN_92242_DPNT_PRFL_EXISTS');
      elsif l_table_name = 'BEN_DSGNTR_ENRLD_CVG_F' then
        fnd_message.set_name('BEN', 'BEN_92242_DPNT_PRFL_EXISTS');
      elsif l_table_name = 'BEN_DSGN_RQMT_F' then
        fnd_message.set_name('BEN', 'BEN_91806_DDR_EXISTS');

      elsif l_table_name = 'BEN_DSGN_RQMT_RLSHP_TYP' then
        fnd_message.set_name('BEN', 'BEN_92041_DRR_EXISTS');

     -- elsif l_table_name = 'BEN_EE_STAT_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_ESR_EXISTS');
     -- elsif l_table_name = 'BEN_ELIGY_PRFL_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_ELP_EXISTS');
      elsif l_table_name = 'BEN_ELIGY_PRFL_RL_F' then
        fnd_message.set_name('BEN', 'BEN_92043_ERL_EXISTS');
     -- elsif l_table_name = 'BEN_ELIGY_RL_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_CER_EXISTS');
      elsif l_table_name = 'BEN_ELIG_AGE_CVG_F' then
        fnd_message.set_name('BEN', 'BEN_92007_EAC_EXISTS');
        elsif l_table_name = 'BEN_ELIG_AGE_PRTE_F' then
          fnd_message.set_name('BEN', 'BEN_91075_EAP_EXISTS');
      elsif l_table_name = 'BEN_ELIG_ASNT_SET_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92045_EAN_EXISTS');
      elsif l_table_name = 'BEN_ELIG_BENFTS_GRP_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92013_EBN_EXISTS');
     -- elsif l_table_name = 'BEN_ELIG_BRGNG_UNIT_PRTE_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_EBU_EXISTS');
     elsif l_table_name = 'BEN_ELIG_CMBN_AGE_LOS_PRTE_F' then
       fnd_message.set_name('BEN', 'BEN_91963_ECP_EXISTS');
      elsif l_table_name = 'BEN_ELIG_COMP_LVL_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_91079_ECL_EXISTS');
      elsif l_table_name = 'BEN_ELIG_CVRD_DPNT_F' then
        fnd_message.set_name('BEN', 'BEN_91037_PDP_EXISTS');
      elsif l_table_name = 'BEN_ELIG_DPNT_CVRD_OTHR_PL_F' then
        fnd_message.set_name('BEN', 'BEN_92240_PRTN_PRFL_EXISTS');
      elsif l_table_name = 'BEN_ELIG_DSBLD_STAT_CVG_F' then
        fnd_message.set_name('BEN', 'BEN_92035_EDC_EXISTS');
      elsif l_table_name = 'BEN_ELIG_EE_STAT_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92046_EES_EXISTS');
      elsif l_table_name = 'BEN_ELIG_ENRLD_ANTHR_PGM_F' then
        fnd_message.set_name('BEN', 'BEN_92240_PRTN_PRFL_EXISTS');
      elsif l_table_name = 'BEN_ELIG_ENRLD_ANTHR_PL_F' then
        fnd_message.set_name('BEN', 'BEN_92240_PRTN_PRFL_EXISTS');
      elsif l_table_name = 'BEN_ELIG_ENRLD_ANTHR_OIPL_F' then
        fnd_message.set_name('BEN', 'BEN_92240_PRTN_PRFL_EXISTS');
      elsif l_table_name = 'BEN_ELIG_FL_TM_PT_TM_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92047_EFP_EXISTS');
      elsif l_table_name = 'BEN_ELIG_GRD_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92048_EGR_EXISTS');
      elsif l_table_name = 'BEN_ELIG_HRLY_SLRD_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92049_EHS_EXISTS');
      elsif l_table_name = 'BEN_ELIG_HRS_WKD_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_91080_EHW_EXISTS');
      elsif l_table_name = 'BEN_ELIG_JOB_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92050_EJP_EXISTS');
      elsif l_table_name = 'BEN_ELIG_LVG_RSN_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92240_PRTN_PRFL_EXISTS');
      elsif l_table_name = 'BEN_ELIG_LBR_MMBR_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92051_ELU_EXISTS');
      elsif l_table_name = 'BEN_ELIG_LGL_ENTY_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92052_ELN_EXISTS');
      elsif l_table_name = 'BEN_ELIG_LOA_RSN_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92053_ELR_EXISTS');
      elsif l_table_name = 'BEN_ELIG_LOS_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_91083_ELS_EXISTS');
      elsif l_table_name = 'BEN_ELIG_MLTRY_STAT_CVG_F' then
        fnd_message.set_name('BEN', 'BEN_92036_EMC_EXISTS');
      elsif l_table_name = 'BEN_ELIG_MRTL_STAT_CVG_F' then
        fnd_message.set_name('BEN', 'BEN_92037_EMS_EXISTS');
      elsif l_table_name = 'BEN_ELIG_NO_OTHR_CVG_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92240_PRTN_PRFL_EXISTS');
      elsif l_table_name = 'BEN_ELIG_OPTD_MDCR_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92240_PRTN_PRFL_EXISTS');
      elsif l_table_name = 'BEN_ELIG_ORG_UNIT_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92054_EOU_EXISTS');
      elsif l_table_name = 'BEN_ELIG_OTHR_PTIP_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92240_PRTN_PRFL_EXISTS');
      elsif l_table_name = 'BEN_ELIG_PCT_FL_TM_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_91085_EPF_EXISTS');
      elsif l_table_name = 'BEN_ELIG_PER_ELCTBL_CHC' then
        fnd_message.set_name('BEN', 'BEN_91152_EPE_EXISTS');
      elsif l_table_name = 'BEN_ELIG_PPL_GRP_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_91972_EPG_EXISTS');
     -- elsif l_table_name = 'BEN_ELIG_PER_ENRT_EVT_ACTN' then
     --   fnd_message.set_name('BEN', 'BEN_91000_EEA_EXISTS');
      elsif l_table_name = 'BEN_ELIG_PER_F' then
        fnd_message.set_name('BEN', 'BEN_91024_PEP_EXISTS');
      elsif l_table_name = 'BEN_ELIG_PER_OPT_F' then
        fnd_message.set_name('BEN', 'BEN_91802_EPO_EXISTS');
      elsif l_table_name = 'BEN_ELIG_PER_TYP_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92055_EPT_EXISTS');

      elsif l_table_name = 'BEN_ELIG_PRTT_ANTHR_PLN_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92240_PRTN_PRFL_EXISTS');
      elsif l_table_name = 'BEN_ELIG_PSTL_CD_R_RNG_CVG_F' then
        fnd_message.set_name('BEN', 'BEN_92038_EPL_EXISTS');

      elsif l_table_name = 'BEN_ELIG_PSTL_CD_R_RNG_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92056_EPZ_EXISTS');
      elsif l_table_name = 'BEN_ELIG_PYRL_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92057_EPY_EXISTS');
      elsif l_table_name = 'BEN_ELIG_PY_BSS_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92058_EPB_EXISTS');
      elsif l_table_name = 'BEN_ELIG_SCHEDD_HRS_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92059_ESH_EXISTS');
      elsif l_table_name = 'BEN_ELIG_STDNT_STAT_CVG_F' then
        fnd_message.set_name('BEN', 'BEN_92039_ESC_EXISTS');
      elsif l_table_name = 'BEN_ELIG_TO_PRTE_RSN_F' then
        fnd_message.set_name('BEN', 'BEN_91025_PEO_EXISTS');
      elsif l_table_name = 'BEN_ELIG_WK_LOC_PRTE_F' then
        fnd_message.set_name('BEN', 'BEN_92060_EWL_EXISTS');
      elsif l_table_name = 'BEN_ENRT_BNFT' then
        fnd_message.set_name('BEN', 'BEN_92026_ENB_EXISTS');

     -- elsif l_table_name = 'BEN_ENRT_CM_PRVDD' then
     --   fnd_message.set_name('BEN', 'BEN_91000_EPV_EXISTS');
      elsif l_table_name = 'BEN_ENRT_RT' then
        fnd_message.set_name('BEN', 'BEN_91986_ECR_EXISTS');
      elsif l_table_name = 'BEN_ENRT_PERD' then
        fnd_message.set_name('BEN', 'BEN_91112_ENP_EXISTS');
      elsif l_table_name = 'BEN_ELIG_CBR_QUALD_BNF_F' then
        fnd_message.set_name('BEN', 'BEN_92511_EQC_EXISTS');

     -- elsif l_table_name = 'BEN_FF_CMPTBL_PY_FREQ' then
     --   fnd_message.set_name('BEN', 'BEN_91000_FCF_EXISTS');
     -- elsif l_table_name = 'BEN_FL_TM_PT_TM_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_FTR_EXISTS');
     -- elsif l_table_name = 'BEN_FRGN_DED_SCHED_FREQ_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_FDF_EXISTS');
      elsif l_table_name = 'BEN_FRGN_PYMT_SCHED_FREQ' then
        fnd_message.set_name('BEN', 'BEN_91171_FSF_EXISTS');
     -- elsif l_table_name = 'BEN_GD_OR_SVC_TYP' then
     --   fnd_message.set_name('BEN', 'BEN_91000_GOS_EXISTS');
     -- elsif l_table_name = 'BEN_GNDR_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_GNR_EXISTS');
     -- elsif l_table_name = 'BEN_GRADE_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_GRR_EXISTS');
     -- elsif l_table_name = 'BEN_HLTH_CVG_SLCTD_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91356_HCR_EXISTS');
     -- elsif l_table_name = 'BEN_HRLY_SLRD_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_HSR_EXISTS');
     -- elsif l_table_name = 'BEN_HRS_WKD_IN_PERD_FCTR' then
     --   fnd_message.set_name('BEN', 'BEN_91000_HWF_EXISTS');
      elsif l_table_name = 'BEN_HRS_WKD_IN_PERD_RT_F' then
        fnd_message.set_name('BEN', 'BEN_91081_HWR_EXISTS');
     -- elsif l_table_name = 'BEN_LBR_MMBR_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_LMR1_EXISTS');
      elsif l_table_name = 'BEN_LEE_RSN_CM_F' then
        fnd_message.set_name('BEN', 'BEN_91113_LEC_EXISTS');
      elsif l_table_name = 'BEN_LEE_RSN_CM_RL_F' then
        fnd_message.set_name('BEN', 'BEN_91114_LMR_EXISTS');
      elsif l_table_name = 'BEN_LEE_RSN_F' then
        fnd_message.set_name('BEN', 'BEN_91026_LEN_EXISTS');
      elsif l_table_name = 'BEN_LEE_RSN_RL_F' then
        fnd_message.set_name('BEN', 'BEN_91115_LRR_EXISTS');
     -- elsif l_table_name = 'BEN_LEGISLATIVE_BUSINESS_UNIT' then
     --   fnd_message.set_name('BEN', 'BEN_91000_LIBG_EXISTS');
      elsif l_table_name = 'BEN_LER_CHG_DPNT_CVG_F' then
        fnd_message.set_name('BEN', 'BEN_91027_LDC_EXISTS');
      elsif l_table_name = 'BEN_LER_CHG_DPNT_CVG_CTFN_F' then
        fnd_message.set_name('BEN', 'BEN_91116_LCC_EXISTS');
      elsif l_table_name = 'BEN_LER_CHG_OIPL_ENRT_F' then
        fnd_message.set_name('BEN', 'BEN_91028_LOP_EXISTS');
      elsif l_table_name = 'BEN_LER_CHG_OIPL_ENRT_RL_F' then
        fnd_message.set_name('BEN', 'BEN_91354_LOU_EXISTS');
      elsif l_table_name = 'BEN_LER_CHG_PGM_ENRT_F' then
        fnd_message.set_name('BEN', 'BEN_91029_LPG_EXISTS');
      elsif l_table_name = 'BEN_LER_CHG_PLIP_ENRT_F' then
        fnd_message.set_name('BEN', 'BEN_91030_LPR_EXISTS');
      elsif l_table_name = 'BEN_LER_CHG_PLIP_ENRT_RL_F' then
        fnd_message.set_name('BEN', 'BEN_91118_LOR_EXISTS');
      elsif l_table_name = 'BEN_LER_CHG_PL_NIP_ENRT_F' then
        fnd_message.set_name('BEN', 'BEN_91031_LPE_EXISTS');
      elsif l_table_name = 'BEN_LER_CHG_PL_NIP_RL_F' then
        fnd_message.set_name('BEN', 'BEN_91355_LNR_EXISTS');
      elsif l_table_name = 'BEN_LER_CM_F' then
        fnd_message.set_name('BEN', 'BEN_91032_LCX_EXISTS');
      elsif l_table_name = 'BEN_LER_CM_RL_F' then
        fnd_message.set_name('BEN', 'BEN_91033_LRL_EXISTS');
     -- elsif l_table_name = 'BEN_LER_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_LER_EXISTS');
      elsif l_table_name = 'BEN_LER_PER_INFO_CS_LER_F' then
        fnd_message.set_name('BEN', 'BEN_91034_LPL_EXISTS');
      elsif l_table_name = 'BEN_LER_RLTD_PER_CS_LER_F' then
        fnd_message.set_name('BEN', 'BEN_91035_LRC_EXISTS');
     -- elsif l_table_name = 'BEN_LGL_ENTY_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_LER1_EXISTS');
     -- elsif l_table_name = 'BEN_LOA_RSN_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_LAR_EXISTS');
     -- elsif l_table_name = 'BEN_LOS_FCTR' then
     --   fnd_message.set_name('BEN', 'BEN_91000_LSF_EXISTS');
      elsif l_table_name = 'BEN_LOS_RT_F' then
        fnd_message.set_name('BEN', 'BEN_91082_LSR_EXISTS');
     -- elsif l_table_name = 'BEN_MTCHG_RT_CALC_RL_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_MCR_EXISTS');
      elsif l_table_name = 'BEN_MTCHG_RT_F' then
        fnd_message.set_name('BEN', 'BEN_91997_MTR_EXISTS');
      elsif l_table_name = 'BEN_OIPL_F' then
        fnd_message.set_name('BEN', 'BEN_91360_COP_EXISTS');
      elsif l_table_name = 'BEN_OPT_F' then
        fnd_message.set_name('BEN', 'BEN_92020_OPT_EXISTS');
     -- elsif l_table_name = 'BEN_ORG_UNIT_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_OUR_EXISTS');
      elsif l_table_name = 'BEN_PAIRD_RT_F' then
        fnd_message.set_name('BEN', 'BEN_91166_PRD_EXISTS');
     -- elsif l_table_name = 'BEN_PCT_FL_TM_FCTR' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PFF_EXISTS');
      elsif l_table_name = 'BEN_PCT_FL_TM_RT_F' then
        fnd_message.set_name('BEN', 'BEN_91086_PFR_EXISTS');

      elsif l_table_name = 'BEN_PER_BNFTS_BAL_F' then
        fnd_message.set_name('BEN', 'BEN_92015_PBB_EXISTS');

      elsif l_table_name = 'BEN_PER_CM_F' then
        fnd_message.set_name('BEN', 'BEN_91858_PCM_EXISTS');
      elsif l_table_name = 'BEN_PER_CM_PRVDD_F' then
        fnd_message.set_name('BEN', 'BEN_91857_PCD_EXISTS');
      elsif l_table_name = 'BEN_PER_CM_TRGR_F' then
        fnd_message.set_name('BEN', 'BEN_91856_PCR_EXISTS');

      elsif l_table_name = 'BEN_PER_CM_USG_F' then
        fnd_message.set_name('BEN', 'BEN_91853_PCU_EXISTS');

      elsif l_table_name = 'BEN_PERD_TO_PROC' then
        fnd_message.set_name('BEN', 'BEN_92033_PPC_EXISTS');

     -- elsif l_table_name = 'BEN_PER_INFO_CHG_CS_LER' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PSL_EXISTS');
      elsif l_table_name = 'BEN_PER_IN_LER_CM_PRVDD' then
        fnd_message.set_name('BEN', 'BEN_91274_PCP_EXISTS');
      elsif l_table_name = 'ben_per_in_ler' then
        fnd_message.set_name('BEN', 'BEN_91036_PIL_EXISTS');
     -- elsif l_table_name = 'BEN_PER_IN_LGL_ENTY_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PLE_EXISTS');
     -- elsif l_table_name = 'BEN_PER_IN_ORG_ROLE_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PSR_EXISTS');
     -- elsif l_table_name = 'BEN_PER_IN_ORG_UNIT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_POR_EXISTS');
     -- elsif l_table_name = 'BEN_PER_PIN_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PPN_EXISTS');
     -- elsif l_table_name = 'BEN_PER_RELSHP_TYP' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PRT_EXISTS');
     -- elsif l_table_name = 'BEN_PER_TYP' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PRY_EXISTS');
     -- elsif l_table_name = 'BEN_PER_TYP_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PTR_EXISTS');
      elsif l_table_name = 'BEN_PGM_DPNT_CVG_CTFN_F' then
        fnd_message.set_name('BEN', 'BEN_91153_PGC_EXISTS');
     -- elsif l_table_name = 'BEN_PGM_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PGM_EXISTS');
      elsif l_table_name = 'BEN_PGM_UNCRS_TRTMT_F' then
        fnd_message.set_name('BEN', 'BEN_91154_PGE_EXISTS');
      elsif l_table_name = 'BEN_PLAPT_F' then
        fnd_message.set_name('BEN', 'BEN_91361_CTY_EXISTS');
      elsif l_table_name = 'BEN_PLIP_F' then
     --   fnd_message.set_name('BEN', 'BEN_91155_CPP_EXISTS'); -- Bug 3110981
        fnd_message.set_name('BEN', 'BEN_93671_PLIP_EXISTS');
      elsif l_table_name = 'BEN_PL_BNF_CTFN_F' then
        fnd_message.set_name('BEN', 'BEN_91362_PCX_EXISTS');
      elsif l_table_name = 'BEN_PL_BNF_F' then
        fnd_message.set_name('BEN', 'BEN_91363_PBN_EXISTS');
      elsif l_table_name = 'BEN_PL_DPNT_CVG_CTFN_F' then
        fnd_message.set_name('BEN', 'BEN_91364_PND_EXISTS');
      elsif l_table_name = 'BEN_PL_F' then
        fnd_message.set_name('BEN', 'BEN_91987_PLN_EXISTS');
      elsif l_table_name = 'BEN_PL_GD_OR_SVC_F' then
        fnd_message.set_name('BEN', 'BEN_91365_VGS_EXISTS');
      elsif l_table_name = 'BEN_PL_GD_R_SVC_CTFN_F' then
        fnd_message.set_name('BEN', 'BEN_91366_PCT_EXISTS');
      elsif l_table_name = 'BEN_PL_LEE_RSN_CTFN_F' then
        fnd_message.set_name('BEN', 'BEN_91367_PEC_EXISTS');
      elsif l_table_name = 'BEN_PL_REGN_F' then
        fnd_message.set_name('BEN', 'BEN_91103_PRG_EXISTS');
      elsif l_table_name = 'BEN_PL_REGY_BOD_F' then
        fnd_message.set_name('BEN', 'BEN_91105_PRB_EXISTS');
      elsif l_table_name = 'BEN_PL_REGY_PRP_F' then
        fnd_message.set_name('BEN', 'BEN_91106_PRP_EXISTS');
      elsif l_table_name = 'BEN_PL_R_OIPL_ASSET_F' then
        fnd_message.set_name('BEN', 'BEN_92025_POA_EXISTS');
     -- elsif l_table_name = 'BEN_PL_TYP_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PTP_EXISTS');
      elsif l_table_name = 'BEN_PL_TYP_OPT_TYP_F' then
        fnd_message.set_name('BEN', 'BEN_91803_PON_EXISTS');
      elsif l_table_name = 'BEN_PL_TYP_OPT_TYP_F_1' then  -- 4395957
        fnd_message.set_name('BEN', 'BEN_94260_PON_EXISTS');
      elsif l_table_name = 'BEN_POPL_ACTN_TYP_F' then
        fnd_message.set_name('BEN', 'BEN_91991_PAT_EXISTS');

      elsif l_table_name = 'BEN_POPL_ENRT_TYP_CYCL_F' then
        fnd_message.set_name('BEN', 'BEN_91156_PET_EXISTS');
      elsif l_table_name = 'BEN_POPL_ORG_F' then
        fnd_message.set_name('BEN', 'BEN_91157_CPO_EXISTS');
     -- elsif l_table_name = 'BEN_POPL_ORG_ROLE_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_CPR_EXISTS');
      elsif l_table_name = 'BEN_POPL_RPTG_GRP_F' then
        fnd_message.set_name('BEN', 'BEN_91104_RGR_EXISTS');
      elsif l_table_name = 'BEN_POPL_YR_PERD' then
        fnd_message.set_name('BEN', 'BEN_91158_CPY_EXISTS');
      elsif l_table_name = 'BEN_PRMRY_CARE_PRVDR_F' then
        fnd_message.set_name('BEN', 'BEN_91817_PPR_EXISTS');
      elsif l_table_name = 'BEN_PRTL_MO_RT_PRTN_VAL_F' then
        fnd_message.set_name('BEN', 'BEN_91998_PPV_EXISTS');
      elsif l_table_name = 'BEN_PRTN_ELIG_F' then
        fnd_message.set_name('BEN', 'BEN_91357_EPA_EXISTS');
      elsif l_table_name = 'BEN_PRTT_ENRT_CTFN_PRVDD_F' then
        fnd_message.set_name('BEN', 'BEN_92413_PCS_EXISTS');

      elsif l_table_name = 'BEN_PRTN_ELIG_PRFL_F' then
        fnd_message.set_name('BEN', 'BEN_91159_CEP_EXISTS');
     -- elsif l_table_name = 'BEN_PRTN_IN_ANTHR_PL_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PPR_EXISTS');
     -- elsif l_table_name = 'BEN_PRTT_ASSOCD_INSTN_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PAI_EXISTS');
     -- elsif l_table_name = 'BEN_PRTT_CLM_GD_OR_SVC_TYP' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PCG_EXISTS');
      elsif l_table_name = 'BEN_PRTT_ENRT_ACTN_F' then
        fnd_message.set_name('BEN', 'BEN_91992_PEA_EXISTS');

      elsif l_table_name = 'BEN_PRTT_ENRT_RSLT' then
        fnd_message.set_name('BEN', 'BEN_91038_PEN_EXISTS');
      elsif l_table_name = 'BEN_PRTT_PREM_F' then
        fnd_message.set_name('BEN', 'BEN_92235_PPE_EXISTS');
     -- elsif l_table_name = 'BEN_PRTT_REIMBMT_RQST_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PRC_EXISTS');
      elsif l_table_name = 'BEN_PRTT_RT_VAL' then
        fnd_message.set_name('BEN', 'BEN_91988_PRV_EXISTS');

     -- elsif l_table_name = 'BEN_PRTT_VSTG_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PVS_EXISTS');
     -- elsif l_table_name = 'BEN_PSTL_ZIP_RATE_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PZR_EXISTS');
     -- elsif l_table_name = 'BEN_PSTL_ZIP_RNG_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_RZR_EXISTS');
     elsif l_table_name = 'BEN_PTD_BAL_TYP_F' then
       fnd_message.set_name('BEN', 'BEN_91773_PBY_EXISTS');
      elsif l_table_name = 'BEN_PTD_LMT_F' then
        fnd_message.set_name('BEN', 'BEN_92027_PDL_EXISTS');
      elsif l_table_name = 'BEN_PTIP_DPNT_CVG_CTFN_F' then
        fnd_message.set_name('BEN', 'BEN_91162_PYD_EXISTS');
      elsif l_table_name = 'BEN_PTIP_F' then
        fnd_message.set_name('BEN', 'BEN_91160_CTP_EXISTS');
     -- elsif l_table_name = 'BEN_PTNL_LER_FOR_PER_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PPL_EXISTS');
      elsif l_table_name = 'BEN_PYMT_SCHED_PY_FREQ' then
        fnd_message.set_name('BEN', 'BEN_92006_PSQ_EXISTS');
     -- elsif l_table_name = 'BEN_PYRL_FCTR' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PYF_EXISTS');
     -- elsif l_table_name = 'BEN_PYRL_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PR_EXISTS');
     -- elsif l_table_name = 'BEN_PY_BSS_FCTR' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PBF_EXISTS');
     -- elsif l_table_name = 'BEN_PY_BSS_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_PBR_EXISTS');
     -- elsif l_table_name = 'BEN_RECRUITMENT_ACTIVITY' then
     --   fnd_message.set_name('BEN', 'BEN_91000_REA_EXISTS');
     -- elsif l_table_name = 'BEN_REGN_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_REG_EXISTS');
     -- elsif l_table_name = 'BEN_REGN_FOR_REGY_BODY_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_RRB_EXISTS');
     -- elsif l_table_name = 'BEN_RLTD_PER_CHG_CS_LER' then
     --   fnd_message.set_name('BEN', 'BEN_91000_RCL_EXISTS');
     -- elsif l_table_name = 'BEN_ROLL_REIMB_RQST' then
     --   fnd_message.set_name('BEN', 'BEN_91000_RRR_EXISTS');
      elsif l_table_name = 'BEN_RPTG_GRP' then
        fnd_message.set_name('BEN', 'BEN_91161_BNR_EXISTS');
      elsif l_table_name = 'BEN_SCHEDD_ENRT_CM_F' then
        fnd_message.set_name('BEN', 'BEN_91119_SEC_EXISTS');
      elsif l_table_name = 'BEN_SCHEDD_ENRT_CM_RL_F' then
        fnd_message.set_name('BEN', 'BEN_91120_SCR_EXISTS');
      elsif l_table_name = 'BEN_SCHEDD_ENRT_RL_F' then
        fnd_message.set_name('BEN', 'BEN_91121_SER_EXISTS');
     -- elsif l_table_name = 'BEN_SCHEDD_HRS_FCTR' then
     --   fnd_message.set_name('BEN', 'BEN_91000_SHF_EXISTS');
     -- elsif l_table_name = 'BEN_SCHEDD_HRS_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_SHR_EXISTS');
      elsif l_table_name = 'BEN_SVC_AREA_PSTL_ZIP_RNG_F' then
        fnd_message.set_name('BEN', 'BEN_91811_SAZ_EXISTS');
      elsif l_table_name = 'BEN_SVC_AREA_RT_F' then
        fnd_message.set_name('BEN', 'BEN_91812_SAR_EXISTS');
     -- elsif l_table_name = 'BEN_TBCO_USE_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_TUR_EXISTS');
     -- elsif l_table_name = 'BEN_TPA_CLNT_RECON_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_TCR_EXISTS');
     -- elsif l_table_name = 'BEN_TPA_CM_INFO_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_TCI_EXISTS');
     -- elsif l_table_name = 'BEN_TPA_IMPRT_EXPORT_DTA_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_TPA_EXISTS');
      elsif l_table_name = 'BEN_TPA_PER_CVRD_F' then
        fnd_message.set_name('BEN', 'BEN_91358_TCV_EXISTS');
     -- elsif l_table_name = 'BEN_VALD_RLSHP_FOR_REIMB_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_VRP_EXISTS');
     -- elsif l_table_name = 'BEN_VALID_DEPENDENT_TYPES' then
     --   fnd_message.set_name('BEN', 'BEN_91000_VDT_EXISTS');
     -- elsif l_table_name = 'BEN_VRBL_MTCHG_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_VMR_EXISTS');
      elsif l_table_name = 'BEN_VRBL_RT_PRFL_F' then
        fnd_message.set_name('BEN', 'BEN_92028_VPF_EXISTS');
     -- elsif l_table_name = 'BEN_VRBL_RT_PRFL_RL_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_VPR_EXISTS');
      elsif l_table_name = 'BEN_VRBL_RT_RL_F' then
        fnd_message.set_name('BEN', 'BEN_91999_VRR_EXISTS');
        elsif l_table_name = 'BEN_VSTG_AGE_RQMT' then
          fnd_message.set_name('BEN', 'BEN_91076_VAR_EXISTS');
     -- elsif l_table_name = 'BEN_VSTG_FOR_ACTY_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_VRT_EXISTS');
      elsif l_table_name = 'BEN_VSTG_LOS_RQMT' then
        fnd_message.set_name('BEN', 'BEN_91084_VLS_EXISTS');
     -- elsif l_table_name = 'BEN_VSTG_SCHED_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_VSC_EXISTS');
     -- elsif l_table_name = 'BEN_WK_LOC_RT_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_WLR_EXISTS');
     -- elsif l_table_name = 'BEN_WV_PRTN_RSN_CTFN_PL_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_WCN_EXISTS');
     -- elsif l_table_name = 'BEN_WV_PRTN_RSN_CTFN_PTIP_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_WCT_EXISTS');
     -- elsif l_table_name = 'BEN_WV_PRTN_RSN_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_WRS_EXISTS');
     -- elsif l_table_name = 'BEN_WV_PRTN_RSN_PL_F' then
     --   fnd_message.set_name('BEN', 'BEN_91000_WPN_EXISTS');
      elsif l_table_name = 'BEN_WV_PRTN_RSN_PTIP_F' then
        fnd_message.set_name('BEN', 'BEN_91163_WPT_EXISTS');
     -- elsif l_table_name = 'BEN_YR_PERD' then
     --   fnd_message.set_name('BEN', 'BEN_91000_YRP_EXISTS');
      elsif l_table_name = 'BEN_EXT_DFN' then
        fnd_message.set_name('BEN', 'BEN_91827_XDF_EXISTS');
      elsif l_table_name = 'BEN_EXT_CRIT_TYP' then
        fnd_message.set_name('BEN', 'BEN_91828_XCT_EXISTS');
      elsif l_table_name = 'BEN_EXT_CRIT_VAL' then
        fnd_message.set_name('BEN', 'BEN_91829_XCV_EXISTS');
      elsif l_table_name = 'BEN_EXT_CRIT_CMBN' then
        fnd_message.set_name('BEN', 'BEN_92189_XCC_EXISTS');
      elsif l_table_name = 'BEN_EXT_DATA_ELMT' then
        fnd_message.set_name('BEN', 'BEN_92071_XEL_EXISTS');
      elsif l_table_name = 'BEN_EXT_INCL_DATA_ELMT' then
        fnd_message.set_name('BEN', 'BEN_92066_XID_EXISTS');
      elsif l_table_name = 'BEN_EXT_INCL_CHG' then
        fnd_message.set_name('BEN', 'BEN_92067_XIC_EXISTS');
      elsif l_table_name = 'BEN_EXT_RCD_IN_FILE' then
        fnd_message.set_name('BEN', 'BEN_92068_XRF_EXISTS');
      elsif l_table_name = 'BEN_EXT_RCD_IN_FILE2' then
        fnd_message.set_name('BEN', 'BEN_92073_XRF_EXISTS2');
      elsif l_table_name = 'BEN_EXT_DATA_ELMT_IN_RCD' then
        fnd_message.set_name('BEN', 'BEN_92069_XER_EXISTS1');
      elsif l_table_name = 'BEN_EXT_DATA_ELMT_IN_RCD2' then
        fnd_message.set_name('BEN', 'BEN_92070_XER_EXISTS2');
      elsif l_table_name = 'BEN_EXT_DATA_ELMT_DECD' then
        fnd_message.set_name('BEN', 'BEN_92072_XDD_EXISTS');
      elsif l_table_name = 'BEN_PL_PCP_TYP' then
        fnd_message.set_name('BEN', 'BEN_92607_PTY_EXISTS');
      elsif l_table_name = 'BEN_PTIP_F_1' then
          fnd_message.set_name('BEN', 'BEN_93608_PTIP_EXISTS');
     elsif l_table_name = 'BEN_BNFT_RSTRN_CTFN_F' then
          fnd_message.set_name('BEN', 'BEN_93871_BRC_EXISTS');

     Else
            fnd_message.set_name('BEN', 'BEN_91039_INVALID_TABLE');
            fnd_message.set_token('tablename', p_table_name);
            fnd_message.set_token('procname', l_proc);
     End If;
     fnd_message.raise_error;
     ---
  ELSIF l_parent_table_name IS NOT NULL
  THEN
     --
     l_user_table_name := decode_table_name(l_table_name);
     l_parent_user_table_name := decode_table_name(l_parent_table_name);
     --
     fnd_message.set_name('BEN', 'BEN_94162_CHILD_ERROR_GENERIC');
     fnd_message.set_token('PARENT_NAME', l_parent_user_table_name );
     fnd_message.set_token('ENTITY_NAME', p_parent_entity_name );
     fnd_message.set_token('CHILD_NAME', l_user_table_name );
     fnd_message.raise_error;
     --
  END IF;
  --
End child_exists_error;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< parent_integrity_error >------------------------|
-- ----------------------------------------------------------------------------
Procedure parent_integrity_error
         (p_table_name in   all_tables.table_name%TYPE) Is
--
  l_proc 	varchar2(72) := g_package||'parent_integrity_error';
  l_table_name   all_tables.table_name%TYPE := null;
--
Begin
  --
  l_table_name := upper(p_table_name);
  if l_table_name = 'FF_FORMULAS_F' then
     fnd_message.set_name('BEN', 'BEN_91102_RULE_INTG_ERR');
   elsif l_table_name = 'BEN_ACTL_PREM_F' then
     fnd_message.set_name('BEN', 'BEN_91990_APR_INTG_ERR');
   -- bug: 5367301
   elsif l_table_name = 'PAY_ELEMENT_TYPES_F' then
     fnd_message.set_name('BEN', 'BEN_94691_ELEMNT_INTG_ERR');
   -- end bug: 5367301
  -- elsif l_table_name = 'BEN_ACTN_TYP' then
  --   fnd_message.set_name('BEN', 'BEN_91000_ACT_INTG_ERR');
   elsif l_table_name = 'BEN_ACTY_BASE_RT_F' then
     fnd_message.set_name('BEN', 'BEN_92003_ABR_INTG_ERR');
  -- elsif l_table_name = 'BEN_ACTY_RT_DED_SCHED_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_ADS_INTG_ERR');
  -- elsif l_table_name = 'BEN_ACTY_RT_FRGN_DED_SCHED_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_AFD_INTG_ERR');
  -- elsif l_table_name = 'BEN_ACTY_RT_FRGN_PYMT_SCHED_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_AFP_INTG_ERR');
  -- elsif l_table_name = 'BEN_ACTY_RT_PTD_LMT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_APL_INTG_ERR');
   elsif l_table_name = 'BEN_ACTY_RT_PYMT_SCHED_F' then
     fnd_message.set_name('BEN', 'BEN_91167_APF_INTG_ERR');
  -- elsif l_table_name = 'BEN_ACTY_VRBL_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_AVR_INTG_ERR');
   elsif l_table_name = 'BEN_AGE_FCTR' then
     fnd_message.set_name('BEN', 'BEN_92008_AGF_INTG_ERR');
  --   elsif l_table_name = 'BEN_AGE_RT_F' then
  --    fnd_message.set_name('BEN', 'BEN_91073_ART_INTG_ERR');
  -- elsif l_table_name = 'BEN_APLD_DPNT_CVG_ELIG_PRFL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_ADE_INTG_ERR');
  -- elsif l_table_name = 'BEN_ASNT_SET_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_AR_INTG_ERR');
  -- elsif l_table_name = 'BEN_BAL_TYP_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_BTP_INTG_ERR');
  -- elsif l_table_name = 'BEN_COMP_LVL_ACTY_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_BTR_INTG_ERR');
  -- elsif l_table_name = 'BEN_BAL_TYP_RL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_BRL_INTG_ERR');
  -- elsif l_table_name = 'BEN_BENEFICIARIES_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000__INTG_ERR');
   elsif l_table_name = 'BEN_BENEFIT_ACTIONS' then
     fnd_message.set_name('BEN', 'BEN_92010_BFT_INTG_ERR');

  -- elsif l_table_name = 'BEN_BENEFIT_CLASSIFICATIONS' then
  --   fnd_message.set_name('BEN', 'BEN_91000_BCL_INTG_ERR');
  -- elsif l_table_name = 'BEN_BENEFIT_CONTRIBUTIONS_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_BCO_INTG_ERR');
  -- elsif l_table_name = 'BEN_BENFTS_GRP' then
  --   fnd_message.set_name('BEN', 'BEN_91000_BNG_INTG_ERR');
  -- elsif l_table_name = 'BEN_BENFTS_GRP_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_BRG_INTG_ERR');
     elsif l_table_name = 'BEN_BNFT_PRVDR_POOL_F' then
       fnd_message.set_name('BEN', 'BEN_92009_BPP_INTG_ERR');

     elsif l_table_name = 'BEN_BNFTS_BAL_F' then
       fnd_message.set_name('BEN', 'BEN_92029_BNB_INTG_ERR');

  -- elsif l_table_name = 'BEN_BRGNG_UNIT_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_BUR_INTG_ERR');
  --   elsif l_table_name = 'BEN_CMBN_AGE_LOS_FCTR' then
  --     fnd_message.set_name('BEN', 'BEN_91074_CLA_INTG_ERR');
  -- elsif l_table_name = 'BEN_CMBN_AGE_LOS_RT' then
  --   fnd_message.set_name('BEN', 'BEN_91000_CMR_INTG_ERR');
   elsif l_table_name = 'BEN_CMBN_PLIP_F' then
     fnd_message.set_name('BEN', 'BEN_92016_CPL_INTG_ERR');

   elsif l_table_name = 'BEN_CMBN_PTIP_F' then
     fnd_message.set_name('BEN', 'BEN_92000_CBP_INTG_ERR');

   elsif l_table_name = 'BEN_CMBN_PTIP_OPT_F' then
     fnd_message.set_name('BEN', 'BEN_91807_CPT_INTG_ERR');

  -- elsif l_table_name = 'BEN_CM_DLVRY_MED_TYP' then
  --   fnd_message.set_name('BEN', 'BEN_91000_CMD_INTG_ERR');
  -- elsif l_table_name = 'BEN_CM_DLVRY_MTHD_TYP' then
  --   fnd_message.set_name('BEN', 'BEN_91000_CMT_INTG_ERR');
   elsif l_table_name = 'BEN_CM_TYP_F' then
     fnd_message.set_name('BEN', 'BEN_91134_CCT_INTG_ERR');

   elsif l_table_name = 'BEN_CM_TYP_TRGR_F' then
    fnd_message.set_name('BEN', 'BEN_92021_CTT_INTG_ERR');

   elsif l_table_name = 'BEN_CM_TRGR_F' then
    fnd_message.set_name('BEN', 'BEN_91854_CTR_INTG_ERR');

   elsif l_table_name = 'BEN_CM_TYP_USG_F' then
    fnd_message.set_name('BEN', 'BEN_91852_CTU_INTG_ERR');

   elsif l_table_name = 'BEN_CNTNG_PRTN_ELIG_PRFL_F' then
     fnd_message.set_name('BEN', 'BEN_92024_CGP_INTG_ERR');
  -- elsif l_table_name = 'BEN_CNTNU_PRTN_CTFN_TYP' then
  --   fnd_message.set_name('BEN', 'BEN_91000_CPC_INTG_ERR');
  -- elsif l_table_name = 'BEN_COMP_ASSET' then
  --   fnd_message.set_name('BEN', 'BEN_91000_CMA_INTG_ERR');
  -- elsif l_table_name = 'BEN_COMP_ELIG_PRFL_RL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_CPF_INTG_ERR');
  elsif l_table_name = 'BEN_COMP_LVL_FCTR' then
     fnd_message.set_name('BEN', 'BEN_91771_CLF_INTG_ERR');
  --   elsif l_table_name = 'BEN_COMP_LVL_RT_F' then
  --     fnd_message.set_name('BEN', 'BEN_91077_CLR_INTG_ERR');
  -- elsif l_table_name = 'BEN_CONTROL' then
  --   fnd_message.set_name('BEN', 'BEN_91000_CTRL_INTG_ERR');
  -- elsif l_table_name = 'BEN_COVERED_DEPENDENTS_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_INTG_ERR');
  -- elsif l_table_name = 'BEN_CRT_ORDR_CLMNT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_COC_INTG_ERR');
  elsif l_table_name = 'BEN_CR_MAY_BE_RLD_INTO_PL_F' then
     fnd_message.set_name('BEN', 'BEN_91000_CRP_INTG_ERR');
  -- elsif l_table_name = 'BEN_CSS_RLTD_PER_PER_IN_LER_F' then
  --   fnd_message.set_name('BEN', 'BEN_91023_CSR_INTG_ERR');
   elsif l_table_name = 'BEN_CVG_AMT_CALC_MTHD_F' then
     fnd_message.set_name('BEN', 'BEN_92017_CCM_INTG_ERR');
   elsif l_table_name = 'BEN_DED_SCHED_PY_FREQ' then
     fnd_message.set_name('BEN', 'BEN_92004_DSQ_INTG_ERR');
   elsif l_table_name = 'BEN_DPNT_CVG_ELIGY_PRFL_F' then
     fnd_message.set_name('BEN', 'BEN_91123_DCE_INTG_ERR');
  -- elsif l_table_name = 'BEN_DPNT_CVG_RQD_RLSHP_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_DCR_INTG_ERR');
  -- elsif l_table_name = 'BEN_EE_STAT_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_ESR_INTG_ERR');
   elsif l_table_name = 'BEN_ELIGY_PRFL_F' then
     fnd_message.set_name('BEN', 'BEN_92023_ELP_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIGY_PRFL_RL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EPR_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIGY_RL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_CER_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_AGE_CVG_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EAC_INTG_ERR');
  --   elsif l_table_name = 'BEN_ELIG_AGE_PRTE_F' then
  --     fnd_message.set_name('BEN', 'BEN_91075_EAP_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_ASNT_SET_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EAN_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_BENFTS_GRP_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EBN_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_BRGNG_UNIT_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EBU_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_CMBN_AGE_LOS_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_ECP_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_COMP_LVL_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91079_ECL_INTG_ERR');
   elsif l_table_name = 'BEN_ELIG_CVRD_DPNT_F' then
     fnd_message.set_name('BEN', 'BEN_91822_PDP_INTG_ERROR');
  -- elsif l_table_name = 'BEN_ELIG_DSBLD_STAT_CVG_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EDC_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_EE_STAT_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EES_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_FL_TM_PT_TM_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EFP_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_GRD_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EGR_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_HRLY_SLRD_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EHS_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_HRS_WKD_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91080_EHW_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_JOB_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EJP_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_LBR_MMBR_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_ELU_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_LGL_ENTY_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_ELN_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_LOA_RSN__PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_ELR_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_LOS_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91083_ELS_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_MLTRY_STAT_CVG_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EMC_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_MRTL_STAT_CVG_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EMS_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_ORG_UNIT_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EOU_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_PCT_FL_TM_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91085_EPF_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_PER_ELCTBL_CHC' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EPE_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_PER_ENRT_EVT_ACTN' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EEA_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_PER_F' then
  --   fnd_message.set_name('BEN', 'BEN_91024_PEP_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_PER_OPT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EPO_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_PER_TYP_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EPT_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_PSTL_CD_R_RNG_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EPZ_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_PYRL_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EPY_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_PY_BSS_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EPB_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_SCHEDD_HRS_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_ESH_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_STDNT_STAT_CVG_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_ESC_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_TO_PRTE_RSN_F' then
  --   fnd_message.set_name('BEN', 'BEN_91025_PEO_INTG_ERR');
  -- elsif l_table_name = 'BEN_ELIG_WK_LOC_PRTE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EWL_INTG_ERR');
  -- elsif l_table_name = 'BEN_ENRT_CM_PRVDD' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EPV_INTG_ERR');
   elsif l_table_name = 'BEN_ENRT_RT_F' then
     fnd_message.set_name('BEN', 'BEN_92353_ECR_INTG_ERR');
   elsif l_table_name = 'BEN_ENRT_PERD' then
     fnd_message.set_name('BEN', 'BEN_91138_ENP_INTG_ERR');
  -- elsif l_table_name = 'BEN_FF_CMPTBL_PY_FREQ' then
  --   fnd_message.set_name('BEN', 'BEN_91000_FCF_INTG_ERR');
  -- elsif l_table_name = 'BEN_FL_TM_PT_TM_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_FTR_INTG_ERR');
  -- elsif l_table_name = 'BEN_FRGN_DED_SCHED_FREQ_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_FDF_INTG_ERR');
  -- elsif l_table_name = 'BEN_FRGN_PYMT_SCHED_FREQ' then
  --   fnd_message.set_name('BEN', 'BEN_91000_FSF_INTG_ERR');
  -- elsif l_table_name = 'BEN_GD_OR_SVC_TYP' then
  --   fnd_message.set_name('BEN', 'BEN_91000_GOS_INTG_ERR');
  -- elsif l_table_name = 'BEN_GNDR_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_GNR_INTG_ERR');
  -- elsif l_table_name = 'BEN_GRADE_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_GRR_INTG_ERR');
  -- elsif l_table_name = 'BEN_HLTH_CVG_SLCTD_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_HCR_INTG_ERR');
  -- elsif l_table_name = 'BEN_HRLY_SLRD_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_HSR_INTG_ERR');
   elsif l_table_name = 'BEN_HRS_WKD_IN_PERD_FCTR' then
     fnd_message.set_name('BEN', 'BEN_92014_HWF_INTG_ERR');
  -- elsif l_table_name = 'BEN_HRS_WKD_IN_PERD_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_HWR_INTG_ERR');
  -- elsif l_table_name = 'BEN_LBR_MMBR_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_LMR1_INTG_ERR');
   elsif l_table_name = 'BEN_LEE_RSN_CM_F' then
     fnd_message.set_name('BEN', 'BEN_91132_LEC_INTG_ERR');
   elsif l_table_name = 'BEN_LEE_RSN_CM_RL_F' then
     fnd_message.set_name('BEN', 'BEN_91133_LMR_INTG_ERR');
   elsif l_table_name = 'BEN_LEE_RSN_F' then
     fnd_message.set_name('BEN', 'BEN_91131_LEN_INTG_ERR');
  -- elsif l_table_name = 'BEN_LEE_RSN_RL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_LRR_INTG_ERR');
  -- elsif l_table_name = 'BEN_LEGISLATIVE_BUSINESS_UNIT' then
  --   fnd_message.set_name('BEN', 'BEN_91000_LIBG_INTG_ERR');
   elsif l_table_name = 'BEN_LER_CHG_DPNT_CVG_F' then
     fnd_message.set_name('BEN', 'BEN_91130_LDC_INTG_ERR');
  -- elsif l_table_name = 'BEN_LER_CHG_DPNT_CVG_CTFN_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_LCC_INTG_ERR');
   elsif l_table_name = 'BEN_LER_CHG_OIPL_ENRT_F' then
     fnd_message.set_name('BEN', 'BEN_91369_LOP_INTG_ERR');
  -- elsif l_table_name = 'BEN_LER_CHG_OIPL_ENRT_RL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_LOU_INTG_ERR');
   elsif l_table_name = 'BEN_LER_CHG_PGM_ENRT_F' then
     fnd_message.set_name('BEN', 'BEN_91136_LPG_INTG_ERR');
   elsif l_table_name = 'BEN_LER_CHG_PLIP_ENRT_F' then
     fnd_message.set_name('BEN', 'BEN_91135_LPR_INTG_ERR');
  -- elsif l_table_name = 'BEN_LER_CHG_PLIP_ENRT_RL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_LOR_INTG_ERR');
   elsif l_table_name = 'BEN_LER_CHG_PL_NIP_ENRT_F' then
     fnd_message.set_name('BEN', 'BEN_91368_LPE_INTG_ERR');
  -- elsif l_table_name = 'BEN_LER_CHG_PL_NIP_RL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_LNR_INTG_ERR');
   elsif l_table_name = 'BEN_LER_CM_F' then
     fnd_message.set_name('BEN', 'BEN_91032_LCX_INTG_ERR');
  -- elsif l_table_name = 'BEN_LER_CM_RL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91033_LRL_INTG_ERR');
   elsif l_table_name = 'BEN_LER_F' then
     fnd_message.set_name('BEN', 'BEN_91101_LER_INTG_ERR');
  -- elsif l_table_name = 'BEN_LER_PER_INFO_CS_LER_F' then
  --   fnd_message.set_name('BEN', 'BEN_91034_LPL_INTG_ERR');
  -- elsif l_table_name = 'BEN_LER_RLTD_PER_CS_LER_F' then
  --   fnd_message.set_name('BEN', 'BEN_91035_LRC_INTG_ERR');
  -- elsif l_table_name = 'BEN_LGL_ENTY_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_LER1_INTG_ERR');
  -- elsif l_table_name = 'BEN_LOA_RSN_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_LAR_INTG_ERR');
  -- elsif l_table_name = 'BEN_LOS_FCTR' then
  --   fnd_message.set_name('BEN', 'BEN_91000_LSF_INTG_ERR');
  -- elsif l_table_name = 'BEN_LOS_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91082_LSR_INTG_ERR');
  -- elsif l_table_name = 'BEN_MTCHG_RT_CALC_RL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_MCR_INTG_ERR');
  -- elsif l_table_name = 'BEN_MTCHG_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_MTR_INTG_ERR');
   elsif l_table_name = 'BEN_OIPL_F' then
     fnd_message.set_name('BEN', 'BEN_91370_COP_INTG_ERR');
   elsif l_table_name = 'BEN_DSGN_RQMT_F' then
     fnd_message.set_name('BEN', 'BEN_91804_DDR_INTG_ERR');

   elsif l_table_name = 'BEN_OPT_F' then
     fnd_message.set_name('BEN', 'BEN_91371_OPT_INTG_ERR');
  -- elsif l_table_name = 'BEN_ORG_UNIT_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_OUR_INTG_ERR');
  -- elsif l_table_name = 'BEN_PAIRD_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PRD_INTG_ERR');
  -- elsif l_table_name = 'BEN_PCT_FL_TM_FCTR' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PFF_INTG_ERR');
  -- elsif l_table_name = 'BEN_PCT_FL_TM_RT_F' then
  --  fnd_message.set_name('BEN', 'BEN_91086_PFR_INTG_ERR');
   elsif l_table_name = 'BEN_PER_CM_F' then
    fnd_message.set_name('BEN', 'BEN_91851_PCM_INTG_ERR');
  -- elsif l_table_name = 'BEN_PER_INFO_CHG_CS_LER' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PSL_INTG_ERR');
  -- elsif l_table_name = 'BEN_PER_IN_LER_CM_PRVDD' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PCP_INTG_ERR');
    elsif l_table_name = 'ben_per_in_ler' then
     fnd_message.set_name('BEN', 'BEN_92011_PIL_INTG_ERR');
  -- elsif l_table_name = 'BEN_PER_IN_LGL_ENTY_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PLE_INTG_ERR');
  -- elsif l_table_name = 'BEN_PER_IN_ORG_ROLE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PSR_INTG_ERR');
  -- elsif l_table_name = 'BEN_PER_IN_ORG_UNIT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_POR_INTG_ERR');
  -- elsif l_table_name = 'BEN_PER_PIN_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PPN_INTG_ERR');
  -- elsif l_table_name = 'BEN_PER_RELSHP_TYP' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PRT_INTG_ERR');
  -- elsif l_table_name = 'BEN_PER_TYP' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PRY_INTG_ERR');
  -- elsif l_table_name = 'BEN_PER_TYP_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PTR_INTG_ERR');
  -- elsif l_table_name = 'BEN_PGM_DPNT_CVG_CTFN_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PGC_INTG_ERR');
   elsif l_table_name = 'BEN_PGM_F' then
     fnd_message.set_name('BEN', 'BEN_91124_PGM_INTG_ERR');
   elsif l_table_name = 'BEN_ACTN_TYP' then
     fnd_message.set_name('BEN', 'BEN_91896_EAT_INTG_ERR');

  -- elsif l_table_name = 'BEN_PGM_UNCRS_TRTMT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PGE_INTG_ERR');
  -- elsif l_table_name = 'BEN_PLAPT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_CTY_INTG_ERR');
   elsif l_table_name = 'BEN_PLIP_F' then
     fnd_message.set_name('BEN', 'BEN_91125_PLN_INTG_ERR');  --bug 4380484
  -- elsif l_table_name = 'BEN_PL_BNF_CTFN_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PCX_INTG_ERR');
  -- elsif l_table_name = 'BEN_PL_BNF_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PBN_INTG_ERR');
  -- elsif l_table_name = 'BEN_PL_DPNT_CVG_CTFN_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PND_INTG_ERR');
   elsif l_table_name = 'BEN_PL_F' then
     fnd_message.set_name('BEN', 'BEN_91125_PLN_INTG_ERR');
  -- elsif l_table_name = 'BEN_PL_GD_OR_SVC_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_VGS_INTG_ERR');
  -- elsif l_table_name = 'BEN_PL_GD_R_SVC_CTFN_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PCT_INTG_ERR');
  -- elsif l_table_name = 'BEN_PL_LEE_RSN_CTFN_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PEC_INTG_ERR');
  -- elsif l_table_name = 'BEN_PL_REGN_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PRG_INTG_ERR');
     elsif l_table_name = 'BEN_PL_REGY_BOD_F' then
       fnd_message.set_name('BEN', 'BEN_91105_PRB_INTG_ERR');
  -- elsif l_table_name = 'BEN_PL_REGY_PRP_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PRP_INTG_ERR');
  -- elsif l_table_name = 'BEN_PL_R_OIPL_ASSET_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_POA_INTG_ERR');
   elsif l_table_name = 'BEN_PL_TYP_F' then
     fnd_message.set_name('BEN', 'BEN_91164_PTP_INTG_ERR');
  -- elsif l_table_name = 'BEN_PL_TYP_OPT_TYP_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PON_INTG_ERR');
   elsif l_table_name = 'BEN_POPL_ENRT_TYP_CYCL_F' then
     fnd_message.set_name('BEN', 'BEN_91129_PET_INTG_ERR');
  -- elsif l_table_name = 'BEN_POPL_ORG_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_CPO_INTG_ERR');
  -- elsif l_table_name = 'BEN_POPL_ORG_ROLE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_CPR_INTG_ERR');
  -- elsif l_table_name = 'BEN_POPL_RPTG_GRP_F' then
  --   fnd_message.set_name('BEN', 'BEN_91104_RGR_INTG_ERR');
  -- elsif l_table_name = 'BEN_POPL_YR_PERD' then
  --   fnd_message.set_name('BEN', 'BEN_91000_CPY_INTG_ERR');
  -- elsif l_table_name = 'BEN_PRTL_MO_RT_PRTN_VAL' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PMRPV_INTG_ERR');
  -- elsif l_table_name = 'BEN_PRTN_ELIG_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_EPA_INTG_ERR');
  -- elsif l_table_name = 'BEN_PRTN_ELIG_PRFL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_CEP_INTG_ERR');
  -- elsif l_table_name = 'BEN_PRTN_IN_ANTHR_PL_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PPR_INTG_ERR');
  -- elsif l_table_name = 'BEN_PRTT_ASSOCD_INSTN_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PAI_INTG_ERR');
  -- elsif l_table_name = 'BEN_PRTT_CLM_GD_OR_SVC_TYP' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PCG_INTG_ERR');
   elsif l_table_name = 'BEN_PRTT_ENRT_ACTN_F' then
     fnd_message.set_name('BEN', 'BEN_91855_PEA_INTG_ERROR');
   elsif l_table_name = 'BEN_PRTT_ENRT_RSLT_F' then
     fnd_message.set_name('BEN', 'BEN_91821_PEN_INTG_ERROR');
  elsif l_table_name = 'BEN_PRTT_PREM_F' then
     fnd_message.set_name('BEN', 'BEN_92238_PRE_INTG_ERR');
  -- elsif l_table_name = 'BEN_PRTT_REIMBMT_RQST_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PRC_INTG_ERR');
  -- elsif l_table_name = 'BEN_PRTT_VSTG_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PVS_INTG_ERR');
  -- elsif l_table_name = 'BEN_PSTL_ZIP_RATE_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PZR_INTG_ERR');
   elsif l_table_name = 'BEN_PSTL_ZIP_RNG_F' then
     fnd_message.set_name('BEN', 'BEN_91814_RZR_INTG_ERR');
   elsif l_table_name = 'BEN_SVC_AREA_F' then
     fnd_message.set_name('BEN', 'BEN_91813_SVA_INTG_ERR');
  -- elsif l_table_name = 'BEN_PTD_BAL_TYP_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PBT_INTG_ERR');
   elsif l_table_name = 'BEN_PTD_LMT_F' then
     fnd_message.set_name('BEN', 'BEN_92005_PDL_INTG_ERR');
  -- elsif l_table_name = 'BEN_PTIP_DPNT_CVG_CTFN_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PYD_INTG_ERR');
   elsif l_table_name = 'BEN_PTIP_F' then
     fnd_message.set_name('BEN', 'BEN_91126_CTP_INTG_ERR');
  -- elsif l_table_name = 'BEN_PTNL_LER_FOR_PER_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PPL_INTG_ERR');
  -- elsif l_table_name = 'BEN_PYMT_SCHED_PY_FREQ' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PSQ_INTG_ERR');
  -- elsif l_table_name = 'BEN_PYRL_FCTR' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PYF_INTG_ERR');
  -- elsif l_table_name = 'BEN_PYRL_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PR_INTG_ERR');
  -- elsif l_table_name = 'BEN_PY_BSS_FCTR' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PBF_INTG_ERR');
  -- elsif l_table_name = 'BEN_PY_BSS_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_PBR_INTG_ERR');
  -- elsif l_table_name = 'BEN_RECRUITMENT_ACTIVITY' then
  --   fnd_message.set_name('BEN', 'BEN_91000_REA_INTG_ERR');
   elsif l_table_name = 'BEN_REGN_F' then
     fnd_message.set_name('BEN', 'BEN_92040_REG_INTG_ERR');
  -- elsif l_table_name = 'BEN_REGN_FOR_REGY_BODY_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_RRB_INTG_ERR');
  -- elsif l_table_name = 'BEN_RLTD_PER_CHG_CS_LER' then
  --   fnd_message.set_name('BEN', 'BEN_91000_RCL_INTG_ERR');
  -- elsif l_table_name = 'BEN_ROLL_REIMB_RQST' then
  --   fnd_message.set_name('BEN', 'BEN_91000_RRR_INTG_ERR');
  -- elsif l_table_name = 'BEN_RPTG_GRP' then
  --   fnd_message.set_name('BEN', 'BEN_91000_BNR_INTG_ERR');
   elsif l_table_name = 'BEN_SCHEDD_ENRT_CM_F' then
     fnd_message.set_name('BEN', 'BEN_91137_SEC_INTG_ERR');
  -- elsif l_table_name = 'BEN_SCHEDD_ENRT_CM_RL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_SCR_INTG_ERR');
  -- elsif l_table_name = 'BEN_SCHEDD_ENRT_RL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_SER_INTG_ERR');
  -- elsif l_table_name = 'BEN_SCHEDD_HRS_FCTR' then
  --   fnd_message.set_name('BEN', 'BEN_91000_SHF_INTG_ERR');
  -- elsif l_table_name = 'BEN_SCHEDD_HRS_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_SHR_INTG_ERR');
  -- elsif l_table_name = 'BEN_TBCO_USE_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_TUR_INTG_ERR');
  -- elsif l_table_name = 'BEN_TPA_CLNT_RECON_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_TCR_INTG_ERR');
  -- elsif l_table_name = 'BEN_TPA_CM_INFO_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_TCI_INTG_ERR');
  -- elsif l_table_name = 'BEN_TPA_IMPRT_EXPORT_DTA_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_TPA_INTG_ERR');
  -- elsif l_table_name = 'BEN_TPA_PER_CVRD_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_TCV_INTG_ERR');
  -- elsif l_table_name = 'BEN_VALD_RLSHP_FOR_REIMB_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_VRP_INTG_ERR');
  -- elsif l_table_name = 'BEN_VALID_DEPENDENT_TYPES' then
  --   fnd_message.set_name('BEN', 'BEN_91000_VDT_INTG_ERR');
  -- elsif l_table_name = 'BEN_VRBL_MTCHG_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_VMR_INTG_ERR');
   elsif l_table_name = 'BEN_VRBL_RT_PRFL_F' then
     fnd_message.set_name('BEN', 'BEN_91989_VPF_INTG_ERR');
  -- elsif l_table_name = 'BEN_VRBL_RT_PRFL_RL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_VPR_INTG_ERR');
   elsif l_table_name = 'BEN_VRBL_RT_RL_F' then
     fnd_message.set_name('BEN', 'BEN_91168_VRR_INTG_ERR');
  --   elsif l_table_name = 'BEN_VSTG_AGE_RQMT' then
  --     fnd_message.set_name('BEN', 'BEN_91076_VAR_INTG_ERR');
   elsif l_table_name = 'BEN_VSTG_FOR_ACTY_RT_F' then
     fnd_message.set_name('BEN', 'BEN_92001_VRT_INTG_ERR');
  -- elsif l_table_name = 'BEN_VSTG_LOS_RQMT' then
  --   fnd_message.set_name('BEN', 'BEN_91084_VLS_INTG_ERR');
  -- elsif l_table_name = 'BEN_VSTG_SCHED_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_VSC_INTG_ERR');
  -- elsif l_table_name = 'BEN_WK_LOC_RT_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_WLR_INTG_ERR');
  -- elsif l_table_name = 'BEN_WV_PRTN_RSN_CTFN_PL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_WCN_INTG_ERR');
  -- elsif l_table_name = 'BEN_WV_PRTN_RSN_CTFN_PTIP_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_WCT_INTG_ERR');
  -- elsif l_table_name = 'BEN_WV_PRTN_RSN_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_WRS_INTG_ERR');
  -- elsif l_table_name = 'BEN_WV_PRTN_RSN_PL_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_WPN_INTG_ERR');
  -- elsif l_table_name = 'BEN_WV_PRTN_RSN_PTIP_F' then
  --   fnd_message.set_name('BEN', 'BEN_91000_WPT_INTG_ERR');
   elsif l_table_name = 'BEN_YR_PERD' then
     fnd_message.set_name('BEN', 'BEN_91128_YRP_INTG_ERR');
   elsif l_table_name = 'BEN_EXT_CRIT_PRFL' then
     fnd_message.set_name('BEN', 'BEN_91000_XCR_INTG_ERR');
   elsif l_table_name = 'BEN_EXT_CRIT_TYP' then
     fnd_message.set_name('BEN', 'BEN_91000_XCT_INTG_ERR');
   elsif l_table_name = 'BEN_EXT_DATA_ELMT' then
     fnd_message.set_name('BEN', 'BEN_91000_XEL_EXISTS');

   elsif l_table_name = 'BEN_EXT_RCD' then
     fnd_message.set_name('BEN', 'BEN_91000_XRC_EXISTS');

   elsif l_table_name = 'PAY_COST_ALLOCATION_KEYFLEX_F' then
     fnd_message.set_name('BEN', 'BEN_91273_CAK_INTG_ERR');

   elsif l_table_name = 'PER_PEOPLE_F' then
     fnd_message.set_name('BEN', 'BEN_91273_PER_INTG_ERR');
   elsif l_table_name = 'PER_ALL_PEOPLE_F' then
     fnd_message.set_name('BEN', 'BEN_91273_PER_INTG_ERR');
  Else
    fnd_message.set_name('PAY', 'HR_7216_DT_UPD_INTEGRITY_ERR');
    fnd_message.set_token('TABLE_NAME', l_table_name);
    fnd_message.raise_error;
  End If;
  fnd_message.raise_error;
  --
End parent_integrity_error;
--
function get_preferred_currency ( p_itemType in varchar2, p_itemKey in varchar2
)
                    return varchar2 is
l_approver    varchar2(320);
l_approver_id number;
l_prof_val    varchar2(240);
begin
    l_approver := wf_engine.GetItemAttrText(
                                   p_itemtype
                                  ,p_itemkey
                                  ,'FORWARD_TO_USERNAME');
   -- If no approver, means user is in the review page for the first time,
   -- process not yet submitted. Fetch the profile for the current user .
    if (l_approver IS null) then
       l_prof_val := fnd_profile.VALUE (
                      NAME     => 'ICX_PREFERRED_CURRENCY' );

    else -- Approver found, fetch profile value for the user.
       select user_id into l_approver_id from fnd_user where user_name = l_approver;
       l_prof_val := fnd_profile.VALUE_SPECIFIC(
                      NAME     => 'ICX_PREFERRED_CURRENCY',
                      USER_ID  => l_approver_id );
    end if;


    return l_prof_val;
exception
  when no_data_found then
      return null;
  when others then
      raise;
end get_preferred_currency;
--
end ben_utility;

/
