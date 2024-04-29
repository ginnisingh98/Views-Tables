--------------------------------------------------------
--  DDL for Package Body BEN_ORG_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ORG_DELETE" as
/* $Header: bebgdchk.pkb 120.0 2005/05/28 00:41:10 appldev noship $ */
procedure perform_ri_check(p_bg_id in number) is

cursor c1(p_bg_id NUMBER)
is select 1 from BEN_CBR_QUALD_BNF
where business_group_id = p_bg_id;

--cursor c2(p_bg_id NUMBER)
--is select 1 from BEN_HLTH_CVG_SLCTD_RT_F
--where business_group_id = p_bg_id;

cursor c3(p_bg_id NUMBER)
is select 1 from BEN_PER_INFO_CHG_CS_LER_F
where business_group_id = p_bg_id;

--cursor c4(p_bg_id NUMBER)
--is select 1 from BEN_PRTN_IN_ANTHR_PL_RT_F
--where business_group_id = p_bg_id;

--cursor c5(p_bg_id NUMBER)
--is select 1 from BEN_PRTT_PREM_BY_MO_CR_F
--where business_group_id = p_bg_id;

cursor c6(p_bg_id NUMBER)
is select 1 from BEN_RLTD_PER_CHG_CS_LER_F
where business_group_id = p_bg_id;

cursor c7(p_bg_id NUMBER)
is select 1 from BEN_PCT_FL_TM_FCTR
where business_group_id = p_bg_id;

cursor c8(p_bg_id NUMBER)
is select 1 from BEN_AGE_FCTR
where business_group_id = p_bg_id;

cursor c9(p_bg_id NUMBER)
is select 1 from BEN_BENFTS_GRP
where business_group_id = p_bg_id;

cursor c10(p_bg_id NUMBER)
is select 1 from BEN_GD_OR_SVC_TYP
where business_group_id = p_bg_id;

cursor c11(p_bg_id NUMBER)
is select 1 from BEN_LOS_FCTR
where business_group_id = p_bg_id;

cursor c12(p_bg_id NUMBER)
is select 1 from BEN_ELIGY_PRFL_F
where business_group_id = p_bg_id;

cursor c13(p_bg_id NUMBER)
is select 1 from BEN_ELIG_LVG_RSN_PRTE_F
where business_group_id = p_bg_id;

cursor c14(p_bg_id NUMBER)
is select 1 from BEN_ELIG_NO_OTHR_CVG_PRTE_F
where business_group_id = p_bg_id;

cursor c15(p_bg_id NUMBER)
is select 1 from BEN_ELIG_OPTD_MDCR_PRTE_F
where business_group_id = p_bg_id;

cursor c16(p_bg_id NUMBER)
is select 1 from BEN_ACTN_TYP
where business_group_id = p_bg_id;

cursor c17(p_bg_id NUMBER)
is select 1 from BEN_BATCH_ACTN_ITEM_INFO
where business_group_id = p_bg_id;

cursor c18(p_bg_id NUMBER)
is select 1 from BEN_BATCH_PARAMETER
where business_group_id = p_bg_id;

cursor c19(p_bg_id NUMBER)
is select 1 from BEN_BNFTS_BAL_F
where business_group_id = p_bg_id;

cursor c20(p_bg_id NUMBER)
is select 1 from BEN_CM_TYP_F
where business_group_id = p_bg_id;

cursor c21(p_bg_id NUMBER)
is select 1 from BEN_CM_TYP_TRGR_F
where business_group_id = p_bg_id;

cursor c22(p_bg_id NUMBER)
is select 1 from BEN_CNTNG_PRTN_ELIG_PRFL_F
where business_group_id = p_bg_id;

cursor c23(p_bg_id NUMBER)
is select 1 from BEN_COMP_ASSET
where business_group_id = p_bg_id;

cursor c24(p_bg_id NUMBER)
is select 1 from BEN_CSR_ACTIVITIES
where business_group_id = p_bg_id;

cursor c25(p_bg_id NUMBER)
is select 1 from BEN_ELIG_BRGNG_UNIT_PRTE_F
where business_group_id = p_bg_id;

cursor c26(p_bg_id NUMBER)
is select 1 from BEN_ELIG_FL_TM_PT_TM_PRTE_F
where business_group_id = p_bg_id;

cursor c27(p_bg_id NUMBER)
is select 1 from BEN_ELIG_HRLY_SLRD_PRTE_F
where business_group_id = p_bg_id;

cursor c28(p_bg_id NUMBER)
is select 1 from BEN_ELIG_LBR_MMBR_PRTE_F
where business_group_id = p_bg_id;

cursor c29(p_bg_id NUMBER)
is select 1 from BEN_ELIG_PER_TYP_PRTE_F
where business_group_id = p_bg_id;

cursor c30(p_bg_id NUMBER)
is select 1 from BEN_ELIG_PYRL_PRTE_F
where business_group_id = p_bg_id;

cursor c31(p_bg_id NUMBER)
is select 1 from BEN_ELIG_SCHEDD_HRS_PRTE_F
where business_group_id = p_bg_id;

cursor c32(p_bg_id NUMBER)
is select 1 from BEN_EXT_CHG_EVT_LOG
where business_group_id = p_bg_id;

cursor c33(p_bg_id NUMBER)
is select 1 from BEN_EXT_CRIT_PRFL
where business_group_id = p_bg_id;

cursor c34(p_bg_id NUMBER)
is select 1 from BEN_EXT_FILE
where business_group_id = p_bg_id;

cursor c35(p_bg_id NUMBER)
is select 1 from BEN_EXT_FLD
where business_group_id = p_bg_id;

cursor c36(p_bg_id NUMBER)
is select 1 from BEN_EXT_RCD
where business_group_id = p_bg_id;

cursor c37(p_bg_id NUMBER)
is select 1 from BEN_PIN
where business_group_id = p_bg_id;

cursor c38(p_bg_id NUMBER)
is select 1 from BEN_PL_TYP_F
where business_group_id = p_bg_id;

cursor c39(p_bg_id NUMBER)
is select 1 from BEN_POP_UP_MESSAGES
where business_group_id = p_bg_id;

cursor c40(p_bg_id NUMBER)
is select 1 from BEN_PSTL_ZIP_RNG_F
where business_group_id = p_bg_id;

cursor c41(p_bg_id NUMBER)
is select 1 from BEN_VSTG_SCHED_F
where business_group_id = p_bg_id;

cursor c42(p_bg_id NUMBER)
is select 1 from BEN_YR_PERD
where business_group_id = p_bg_id;

cursor c43(p_bg_id NUMBER)
is select 1 from BEN_CMBN_AGE_LOS_FCTR
where business_group_id = p_bg_id;

cursor c44(p_bg_id NUMBER)
is select 1 from BEN_CM_DLVRY_MTHD_TYP
where business_group_id = p_bg_id;

cursor c45(p_bg_id NUMBER)
is select 1 from BEN_CNTNU_PRTN_CTFN_TYP_F
where business_group_id = p_bg_id;

cursor c46(p_bg_id NUMBER)
is select 1 from BEN_ELIGY_PRFL_RL_F
where business_group_id = p_bg_id;

cursor c47(p_bg_id NUMBER)
is select 1 from BEN_ELIG_AGE_PRTE_F
where business_group_id = p_bg_id;

cursor c48(p_bg_id NUMBER)
is select 1 from BEN_ELIG_BENFTS_GRP_PRTE_F
where business_group_id = p_bg_id;

cursor c49(p_bg_id NUMBER)
is select 1 from BEN_ELIG_LOS_PRTE_F
where business_group_id = p_bg_id;

cursor c50(p_bg_id NUMBER)
is select 1 from BEN_ELIG_PCT_FL_TM_PRTE_F
where business_group_id = p_bg_id;

cursor c51(p_bg_id NUMBER)
is select 1 from BEN_ELIG_PSTL_CD_R_RNG_PRTE_F
where business_group_id = p_bg_id;

cursor c52(p_bg_id NUMBER)
is select 1 from BEN_ELIG_WK_LOC_PRTE_F
where business_group_id = p_bg_id;

cursor c53(p_bg_id NUMBER)
is select 1 from BEN_EXT_CRIT_TYP
where business_group_id = p_bg_id;

cursor c54(p_bg_id NUMBER)
is select 1 from BEN_EXT_DFN
where business_group_id = p_bg_id;

cursor c55(p_bg_id NUMBER)
is select 1 from BEN_ORG_UNIT_PRDCT_F
where business_group_id = p_bg_id;

cursor c56(p_bg_id NUMBER)
is select 1 from BEN_PER_BNFTS_BAL_F
where business_group_id = p_bg_id;

cursor c57(p_bg_id NUMBER)
is select 1 from BEN_PER_PIN_F
where business_group_id = p_bg_id;

cursor c58(p_bg_id NUMBER)
is select 1 from BEN_VSTG_AGE_RQMT
where business_group_id = p_bg_id;

cursor c59(p_bg_id NUMBER)
is select 1 from BEN_VSTG_FOR_ACTY_RT_F
where business_group_id = p_bg_id;

cursor c60(p_bg_id NUMBER)
is select 1 from BEN_WTHN_YR_PERD
where business_group_id = p_bg_id;

cursor c61(p_bg_id NUMBER)
is select 1 from BEN_CM_DLVRY_MED_TYP
where business_group_id = p_bg_id;

cursor c62(p_bg_id NUMBER)
is select 1 from BEN_ELIG_SVC_AREA_PRTE_F
where business_group_id = p_bg_id;

cursor c63(p_bg_id NUMBER)
is select 1 from BEN_EXT_CRIT_VAL
where business_group_id = p_bg_id;

cursor c64(p_bg_id NUMBER)
is select 1 from BEN_EXT_DATA_ELMT
where business_group_id = p_bg_id;

cursor c65(p_bg_id NUMBER)
is select 1 from BEN_EXT_RSLT
where business_group_id = p_bg_id;

cursor c66(p_bg_id NUMBER)
is select 1 from BEN_SVC_AREA_F
where business_group_id = p_bg_id;

cursor c67(p_bg_id NUMBER)
is select 1 from BEN_VSTG_LOS_RQMT
where business_group_id = p_bg_id;

cursor c68(p_bg_id NUMBER)
is select 1 from BEN_ELIG_CMBN_AGE_LOS_PRTE_F
where business_group_id = p_bg_id;

cursor c69(p_bg_id NUMBER)
is select 1 from BEN_EXT_CRIT_CMBN
where business_group_id = p_bg_id;

cursor c70(p_bg_id NUMBER)
is select 1 from BEN_EXT_DATA_ELMT_DECD
where business_group_id = p_bg_id;

cursor c71(p_bg_id NUMBER)
is select 1 from BEN_EXT_DATA_ELMT_IN_RCD
where business_group_id = p_bg_id;

cursor c72(p_bg_id NUMBER)
is select 1 from BEN_EXT_RSLT_DTL
where business_group_id = p_bg_id;

cursor c73(p_bg_id NUMBER)
is select 1 from BEN_SVC_AREA_PSTL_ZIP_RNG_F
where business_group_id = p_bg_id;

cursor c74(p_bg_id NUMBER)
is select 1 from BEN_COMP_LVL_FCTR
where business_group_id = p_bg_id;

cursor c75(p_bg_id NUMBER)
is select 1 from BEN_ELIG_LGL_ENTY_PRTE_F
where business_group_id = p_bg_id;

cursor c76(p_bg_id NUMBER)
is select 1 from BEN_ELIG_ORG_UNIT_PRTE_F
where business_group_id = p_bg_id;

cursor c77(p_bg_id NUMBER)
is select 1 from BEN_EXT_RSLT_ERR
where business_group_id = p_bg_id;

cursor c78(p_bg_id NUMBER)
is select 1 from BEN_REGN_F
where business_group_id = p_bg_id;

cursor c79(p_bg_id NUMBER)
is select 1 from BEN_EXT_INCL_DATA_ELMT
where business_group_id = p_bg_id;

cursor c80(p_bg_id NUMBER)
is select 1 from BEN_EXT_RCD_IN_FILE
where business_group_id = p_bg_id;

cursor c81(p_bg_id NUMBER)
is select 1 from BEN_REGN_FOR_REGY_BODY_F
where business_group_id = p_bg_id;

cursor c82(p_bg_id NUMBER)
is select 1 from BEN_EXT_INCL_CHG
where business_group_id = p_bg_id;

cursor c83(p_bg_id NUMBER)
is select 1 from BEN_EXT_WHERE_CLAUSE
where business_group_id = p_bg_id;

cursor c84(p_bg_id NUMBER)
is select 1 from BEN_RPTG_GRP
where business_group_id = p_bg_id;

cursor c85(p_bg_id NUMBER)
is select 1 from BEN_DPNT_CVG_ELIGY_PRFL_F
where business_group_id = p_bg_id;

cursor c86(p_bg_id NUMBER)
is select 1 from BEN_HRS_WKD_IN_PERD_FCTR
where business_group_id = p_bg_id;

cursor c87(p_bg_id NUMBER)
is select 1 from BEN_DPNT_CVG_RQD_RLSHP_F
where business_group_id = p_bg_id;

cursor c88(p_bg_id NUMBER)
is select 1 from BEN_DSGNTR_ENRLD_CVG_F
where business_group_id = p_bg_id;

cursor c89(p_bg_id NUMBER)
is select 1 from BEN_ELIG_COMP_LVL_PRTE_F
where business_group_id = p_bg_id;

cursor c90(p_bg_id NUMBER)
is select 1 from BEN_ELIG_DSBLD_STAT_CVG_F
where business_group_id = p_bg_id;

cursor c91(p_bg_id NUMBER)
is select 1 from BEN_ELIG_HRS_WKD_PRTE_F
where business_group_id = p_bg_id;

cursor c92(p_bg_id NUMBER)
is select 1 from BEN_ELIG_MLTRY_STAT_CVG_F
where business_group_id = p_bg_id;

cursor c93(p_bg_id NUMBER)
is select 1 from BEN_ELIG_MRTL_STAT_CVG_F
where business_group_id = p_bg_id;

cursor c94(p_bg_id NUMBER)
is select 1 from BEN_ELIG_STDNT_STAT_CVG_F
where business_group_id = p_bg_id;

cursor c95(p_bg_id NUMBER)
is select 1 from BEN_ELIG_AGE_CVG_F
where business_group_id = p_bg_id;

cursor c96(p_bg_id NUMBER)
is select 1 from BEN_ELIG_PSTL_CD_R_RNG_CVG_F
where business_group_id = p_bg_id;

cursor c97(p_bg_id NUMBER)
is select 1 from BEN_PTD_LMT_F
where business_group_id = p_bg_id;

cursor c98(p_bg_id NUMBER)
is select 1 from BEN_PTD_BAL_TYP_F
where business_group_id = p_bg_id;

cursor c99(p_bg_id NUMBER)
is select 1 from BEN_ELIG_GRD_PRTE_F
where business_group_id = p_bg_id;

cursor c100(p_bg_id NUMBER)
is select 1 from BEN_PER_DLVRY_MTHD_F
where business_group_id = p_bg_id;

cursor c101(p_bg_id NUMBER)
is select 1 from BEN_PER_IN_LGL_ENTY_F
where business_group_id = p_bg_id;

cursor c102(p_bg_id NUMBER)
is select 1 from BEN_PER_IN_ORG_UNIT_F
where business_group_id = p_bg_id;

cursor c103(p_bg_id NUMBER)
is select 1 from BEN_PER_IN_ORG_ROLE_F
where business_group_id = p_bg_id;

cursor c104(p_bg_id NUMBER)
is select 1 from BEN_ACRS_PTIP_CVG_F
where business_group_id = p_bg_id;

cursor c105(p_bg_id NUMBER)
is select 1 from BEN_PL_TYP_OPT_TYP_F
where business_group_id = p_bg_id;

cursor c106(p_bg_id NUMBER)
is select 1 from BEN_ENRT_PERD
where business_group_id = p_bg_id;

cursor c107(p_bg_id NUMBER)
is select 1 from BEN_OPT_F
where business_group_id = p_bg_id;

cursor c108(p_bg_id NUMBER)
is select 1 from BEN_LER_F
where business_group_id = p_bg_id;

cursor c109(p_bg_id NUMBER)
is select 1 from BEN_LER_RLTD_PER_CS_LER_F
where business_group_id = p_bg_id;

cursor c110(p_bg_id NUMBER)
is select 1 from BEN_CBR_PER_IN_LER
where business_group_id = p_bg_id;

cursor c111(p_bg_id NUMBER)
is select 1 from BEN_CSS_RLTD_PER_PER_IN_LER_F
where business_group_id = p_bg_id;

cursor c112(p_bg_id NUMBER)
is select 1 from BEN_LER_PER_INFO_CS_LER_F
where business_group_id = p_bg_id;

cursor c113(p_bg_id NUMBER)
is select 1 from BEN_LE_CLSN_N_RSTR
where business_group_id = p_bg_id;

cursor c114(p_bg_id NUMBER)
is select 1 from BEN_PER_IN_LER
where business_group_id = p_bg_id;

cursor c115(p_bg_id NUMBER)
is select 1 from BEN_PTNL_LER_FOR_PER
where business_group_id = p_bg_id;

cursor c116(p_bg_id NUMBER)
is select 1 from BEN_PGM_F
where business_group_id = p_bg_id;

cursor c117(p_bg_id NUMBER)
is select 1 from BEN_ELIG_ENRLD_ANTHR_PGM_F
where business_group_id = p_bg_id;

cursor c118(p_bg_id NUMBER)
is select 1 from BEN_ELIG_PRTT_ANTHR_PGM_F
where business_group_id = p_bg_id;

cursor c119(p_bg_id NUMBER)
is select 1 from BEN_PLIP_F
where business_group_id = p_bg_id;

cursor c120(p_bg_id NUMBER)
is select 1 from BEN_PL_F
where business_group_id = p_bg_id;

cursor c121(p_bg_id NUMBER)
is select 1 from BEN_PTIP_F
where business_group_id = p_bg_id;

cursor c122(p_bg_id NUMBER)
is select 1 from BEN_DPNT_CVRD_ANTHR_PL_CVG_F
where business_group_id = p_bg_id;

cursor c124(p_bg_id NUMBER)
is select 1 from BEN_ELIG_DPNT_CVRD_OTHR_PL_F
where business_group_id = p_bg_id;

cursor c125(p_bg_id NUMBER)
is select 1 from BEN_ELIG_ENRLD_ANTHR_PL_F
where business_group_id = p_bg_id;

cursor c126(p_bg_id NUMBER)
is select 1 from BEN_ENRT_ENRLD_ANTHR_PL_F
where business_group_id = p_bg_id;

cursor c127(p_bg_id NUMBER)
is select 1 from BEN_OIPLIP_F
where business_group_id = p_bg_id;

cursor c128(p_bg_id NUMBER)
is select 1 from BEN_OIPL_F
where business_group_id = p_bg_id;

cursor c129(p_bg_id NUMBER)
is select 1 from BEN_PGM_DPNT_CVG_CTFN_F
where business_group_id = p_bg_id;

cursor c130(p_bg_id NUMBER)
is select 1 from BEN_BNFT_PRVDR_POOL_F
where business_group_id = p_bg_id;

cursor c131(p_bg_id NUMBER)
is select 1 from BEN_CMBN_PLIP_F
where business_group_id = p_bg_id;

cursor c132(p_bg_id NUMBER)
is select 1 from BEN_CMBN_PTIP_F
where business_group_id = p_bg_id;

cursor c133(p_bg_id NUMBER)
is select 1 from BEN_CMBN_PTIP_OPT_F
where business_group_id = p_bg_id;

cursor c134(p_bg_id NUMBER)
is select 1 from BEN_CM_TYP_USG_F
where business_group_id = p_bg_id;

cursor c135(p_bg_id NUMBER)
is select 1 from BEN_DSGN_RQMT_F
where business_group_id = p_bg_id;

cursor c136(p_bg_id NUMBER)
is select 1 from BEN_ELIG_TO_PRTE_RSN_F
where business_group_id = p_bg_id;

cursor c137(p_bg_id NUMBER)
is select 1 from BEN_LER_CHG_PGM_ENRT_F
where business_group_id = p_bg_id;

cursor c138(p_bg_id NUMBER)
is select 1 from BEN_PL_BNF_CTFN_F
where business_group_id = p_bg_id;

cursor c139(p_bg_id NUMBER)
is select 1 from BEN_PL_DPNT_CVG_CTFN_F
where business_group_id = p_bg_id;

cursor c140(p_bg_id NUMBER)
is select 1 from BEN_PL_GD_OR_SVC_F
where business_group_id = p_bg_id;

cursor c141(p_bg_id NUMBER)
is select 1 from BEN_PL_REGN_F
where business_group_id = p_bg_id;

cursor c142(p_bg_id NUMBER)
is select 1 from BEN_PL_REGY_BOD_F
where business_group_id = p_bg_id;

cursor c143(p_bg_id NUMBER)
is select 1 from BEN_POPL_ACTN_TYP_F
where business_group_id = p_bg_id;

cursor c144(p_bg_id NUMBER)
is select 1 from BEN_POPL_ENRT_TYP_CYCL_F
where business_group_id = p_bg_id;

cursor c145(p_bg_id NUMBER)
is select 1 from BEN_POPL_ORG_F
where business_group_id = p_bg_id;

cursor c146(p_bg_id NUMBER)
is select 1 from BEN_WV_PRTN_RSN_PL_F
where business_group_id = p_bg_id;

cursor c147(p_bg_id NUMBER)
is select 1 from BEN_CRT_ORDR
where business_group_id = p_bg_id;

cursor c148(p_bg_id NUMBER)
is select 1 from BEN_ELIG_PRTT_ANTHR_PL_PRTE_F
where business_group_id = p_bg_id;

cursor c149(p_bg_id NUMBER)
is select 1 from BEN_ENRT_CTFN_F
where business_group_id = p_bg_id;

cursor c150(p_bg_id NUMBER)
is select 1 from BEN_LEE_RSN_F
where business_group_id = p_bg_id;

cursor c151(p_bg_id NUMBER)
is select 1 from BEN_PL_R_OIPL_ASSET_F
where business_group_id = p_bg_id;

cursor c152(p_bg_id NUMBER)
is select 1 from BEN_POPL_RPTG_GRP_F
where business_group_id = p_bg_id;

cursor c153(p_bg_id NUMBER)
is select 1 from BEN_POPL_YR_PERD
where business_group_id = p_bg_id;

cursor c154(p_bg_id NUMBER)
is select 1 from BEN_PRTN_ELIG_F
where business_group_id = p_bg_id;

cursor c155(p_bg_id NUMBER)
is select 1 from BEN_VALD_RLSHP_FOR_REIMB_F
where business_group_id = p_bg_id;

cursor c156(p_bg_id NUMBER)
is select 1 from BEN_VRBL_RT_PRFL_F
where business_group_id = p_bg_id;

cursor c157(p_bg_id NUMBER)
is select 1 from BEN_BNFT_RSTRN_CTFN_F
where business_group_id = p_bg_id;

cursor c158(p_bg_id NUMBER)
is select 1 from BEN_BRGNG_UNIT_RT_F
where business_group_id = p_bg_id;

cursor c159(p_bg_id NUMBER)
is select 1 from BEN_CMBN_AGE_LOS_RT_F
where business_group_id = p_bg_id;

cursor c160(p_bg_id NUMBER)
is select 1 from BEN_COMP_LVL_RT_F
where business_group_id = p_bg_id;

cursor c161(p_bg_id NUMBER)
is select 1 from BEN_DSGN_RQMT_RLSHP_TYP
where business_group_id = p_bg_id;

cursor c162(p_bg_id NUMBER)
is select 1 from BEN_ENRT_PERD_FOR_PL_F
where business_group_id = p_bg_id;

cursor c163(p_bg_id NUMBER)
is select 1 from BEN_LGL_ENTY_RT_F
where business_group_id = p_bg_id;

cursor c164(p_bg_id NUMBER)
is select 1 from BEN_LOS_RT_F
where business_group_id = p_bg_id;

cursor c165(p_bg_id NUMBER)
is select 1 from BEN_ORG_UNIT_RT_F
where business_group_id = p_bg_id;

cursor c166(p_bg_id NUMBER)
is select 1 from BEN_PCT_FL_TM_RT_F
where business_group_id = p_bg_id;

cursor c167(p_bg_id NUMBER)
is select 1 from BEN_PER_TYP_RT_F
where business_group_id = p_bg_id;

cursor c168(p_bg_id NUMBER)
is select 1 from BEN_PPL_GRP_RT_F
where business_group_id = p_bg_id;

cursor c169(p_bg_id NUMBER)
is select 1 from BEN_PSTL_ZIP_RT_F
where business_group_id = p_bg_id;

cursor c170(p_bg_id NUMBER)
is select 1 from BEN_PYRL_RT_F
where business_group_id = p_bg_id;

cursor c171(p_bg_id NUMBER)
is select 1 from BEN_SCHEDD_HRS_RT_F
where business_group_id = p_bg_id;

cursor c172(p_bg_id NUMBER)
is select 1 from BEN_SVC_AREA_RT_F
where business_group_id = p_bg_id;

cursor c173(p_bg_id NUMBER)
is select 1 from BEN_TBCO_USE_RT_F
where business_group_id = p_bg_id;

cursor c174(p_bg_id NUMBER)
is select 1 from BEN_TTL_CVG_VOL_RT_F
where business_group_id = p_bg_id;

cursor c175(p_bg_id NUMBER)
is select 1 from BEN_TTL_PRTT_RT_F
where business_group_id = p_bg_id;

cursor c176(p_bg_id NUMBER)
is select 1 from BEN_VRBL_MTCHG_RT_F
where business_group_id = p_bg_id;

cursor c177(p_bg_id NUMBER)
is select 1 from BEN_VRBL_RT_PRFL_RL_F
where business_group_id = p_bg_id;

cursor c178(p_bg_id NUMBER)
is select 1 from BEN_WK_LOC_RT_F
where business_group_id = p_bg_id;

cursor c179(p_bg_id NUMBER)
is select 1 from BEN_ACTL_PREM_F
where business_group_id = p_bg_id;

cursor c180(p_bg_id NUMBER)
is select 1 from BEN_CRT_ORDR_CVRD_PER
where business_group_id = p_bg_id;

cursor c181(p_bg_id NUMBER)
is select 1 from BEN_FL_TM_PT_TM_RT_F
where business_group_id = p_bg_id;

cursor c182(p_bg_id NUMBER)
is select 1 from BEN_GNDR_RT_F
where business_group_id = p_bg_id;

cursor c183(p_bg_id NUMBER)
is select 1 from BEN_GRADE_RT_F
where business_group_id = p_bg_id;

cursor c184(p_bg_id NUMBER)
is select 1 from BEN_HRLY_SLRD_RT_F
where business_group_id = p_bg_id;

cursor c185(p_bg_id NUMBER)
is select 1 from BEN_HRS_WKD_IN_PERD_RT_F
where business_group_id = p_bg_id;

cursor c186(p_bg_id NUMBER)
is select 1 from BEN_LBR_MMBR_RT_F
where business_group_id = p_bg_id;

cursor c187(p_bg_id NUMBER)
is select 1 from BEN_LER_BNFT_RSTRN_F
where business_group_id = p_bg_id;

cursor c188(p_bg_id NUMBER)
is select 1 from BEN_LER_RQRS_ENRT_CTFN_F
where business_group_id = p_bg_id;

cursor c189(p_bg_id NUMBER)
is select 1 from BEN_LER_BNFT_RSTRN_CTFN_F
where business_group_id = p_bg_id;

cursor c190(p_bg_id NUMBER)
is select 1 from BEN_APLD_DPNT_CVG_ELIG_PRFL_F
where business_group_id = p_bg_id;

cursor c191(p_bg_id NUMBER)
is select 1 from BEN_CVG_AMT_CALC_MTHD_F
where business_group_id = p_bg_id;

cursor c192(p_bg_id NUMBER)
is select 1 from BEN_DPNT_CVRD_ANTHR_OIPL_CVG_F
where business_group_id = p_bg_id;

cursor c193(p_bg_id NUMBER)
is select 1 from BEN_ELIG_DPNT_CVRD_OTHR_OIPL_F
where business_group_id = p_bg_id;

cursor c194(p_bg_id NUMBER)
is select 1 from BEN_ELIG_PER_F
where business_group_id = p_bg_id;

cursor c195(p_bg_id NUMBER)
is select 1 from BEN_ENRT_ENRLD_ANTHR_OIPL_F
where business_group_id = p_bg_id;

cursor c196(p_bg_id NUMBER)
is select 1 from BEN_LER_CHG_DPNT_CVG_F
where business_group_id = p_bg_id;

cursor c197(p_bg_id NUMBER)
is select 1 from BEN_LER_CHG_OIPL_ENRT_F
where business_group_id = p_bg_id;

cursor c198(p_bg_id NUMBER)
is select 1 from BEN_LER_CHG_PL_NIP_ENRT_F
where business_group_id = p_bg_id;

cursor c199(p_bg_id NUMBER)
is select 1 from BEN_PIL_ELCTBL_CHC_POPL
where business_group_id = p_bg_id;

cursor c200(p_bg_id NUMBER)
is select 1 from BEN_AGE_RT_F
where business_group_id = p_bg_id;

cursor c201(p_bg_id NUMBER)
is select 1 from BEN_ASNT_SET_RT_F
where business_group_id = p_bg_id;

cursor c202(p_bg_id NUMBER)
is select 1 from BEN_BENFTS_GRP_RT_F
where business_group_id = p_bg_id;

cursor c203(p_bg_id NUMBER)
is select 1 from BEN_PRTT_ENRT_RSLT_F
where business_group_id = p_bg_id;

cursor c204(p_bg_id NUMBER)
is select 1 from BEN_BNFT_VRBL_RT_F
where business_group_id = p_bg_id;

cursor c205(p_bg_id NUMBER)
is select 1 from BEN_ELIG_CVRD_DPNT_F
where business_group_id = p_bg_id;

cursor c206(p_bg_id NUMBER)
is select 1 from BEN_ELIG_PER_ELCTBL_CHC
where business_group_id = p_bg_id;

cursor c207(p_bg_id NUMBER)
is select 1 from BEN_ENRT_BNFT
where business_group_id = p_bg_id;

cursor c208(p_bg_id NUMBER)
is select 1 from BEN_PL_BNF_F
where business_group_id = p_bg_id;

cursor c209(p_bg_id NUMBER)
is select 1 from BEN_PL_R_OIPL_PREM_BY_MO_F
where business_group_id = p_bg_id;

cursor c210(p_bg_id NUMBER)
is select 1 from BEN_PRTT_PREM_F
where business_group_id = p_bg_id;

cursor c211(p_bg_id NUMBER)
is select 1 from BEN_ENRT_PREM
where business_group_id = p_bg_id;

cursor c212(p_bg_id NUMBER)
is select 1 from BEN_PRTN_ELIGY_RL_F
where business_group_id = p_bg_id;

cursor c213(p_bg_id NUMBER)
is select 1 from BEN_ELCTBL_CHC_CTFN
where business_group_id = p_bg_id;

cursor c214(p_bg_id NUMBER)
is select 1 from BEN_ACTL_PREM_VRBL_RT_RL_F
where business_group_id = p_bg_id;

cursor c215(p_bg_id NUMBER)
is select 1 from BEN_BNFT_VRBL_RT_RL_F
where business_group_id = p_bg_id;

cursor c216(p_bg_id NUMBER)
is select 1 from BEN_ELIG_PPL_GRP_PRTE_F
where business_group_id = p_bg_id;

cursor c217(p_bg_id NUMBER)
is select 1 from BEN_PRTN_ELIG_PRFL_F
where business_group_id = p_bg_id;

cursor c218(p_bg_id NUMBER)
is select 1 from BEN_WV_PRTN_RSN_CTFN_PL_F
where business_group_id = p_bg_id;

cursor c219(p_bg_id NUMBER)
is select 1 from BEN_ACTL_PREM_VRBL_RT_F
where business_group_id = p_bg_id;

cursor c220(p_bg_id NUMBER)
is select 1 from BEN_ELIG_PER_OPT_F
where business_group_id = p_bg_id;

cursor c221(p_bg_id NUMBER)
is select 1 from BEN_ELIG_PER_WV_PL_TYP_F
where business_group_id = p_bg_id;

cursor c222(p_bg_id NUMBER)
is select 1 from BEN_PL_GD_R_SVC_CTFN_F
where business_group_id = p_bg_id;

cursor c223(p_bg_id NUMBER)
is select 1 from BEN_PRMRY_CARE_PRVDR_F
where business_group_id = p_bg_id;

cursor c224(p_bg_id NUMBER)
is select 1 from BEN_PRTT_ENRT_ACTN_F
where business_group_id = p_bg_id;

cursor c225(p_bg_id NUMBER)
is select 1 from BEN_PRTT_ENRT_CTFN_PRVDD_F
where business_group_id = p_bg_id;

cursor c226(p_bg_id NUMBER)
is select 1 from BEN_ELIG_DPNT
where business_group_id = p_bg_id;

cursor c227(p_bg_id NUMBER)
is select 1 from BEN_LEE_RSN_RL_F
where business_group_id = p_bg_id;

cursor c228(p_bg_id NUMBER)
is select 1 from BEN_PL_REGY_PRP_F
where business_group_id = p_bg_id;

cursor c229(p_bg_id NUMBER)
is select 1 from BEN_SCHEDD_ENRT_RL_F
where business_group_id = p_bg_id;

cursor c230(p_bg_id NUMBER)
is select 1 from BEN_ELIG_OTHR_PTIP_PRTE_F
where business_group_id = p_bg_id;

cursor c231(p_bg_id NUMBER)
is select 1 from BEN_LER_CHG_PTIP_ENRT_F
where business_group_id = p_bg_id;

cursor c232(p_bg_id NUMBER)
is select 1 from BEN_LER_CHG_DPNT_CVG_CTFN_F
where business_group_id = p_bg_id;

cursor c233(p_bg_id NUMBER)
is select 1 from BEN_LER_CHG_OIPL_ENRT_RL_F
where business_group_id = p_bg_id;

cursor c234(p_bg_id NUMBER)
is select 1 from BEN_LER_CHG_PLIP_ENRT_F
where business_group_id = p_bg_id;

cursor c235(p_bg_id NUMBER)
is select 1 from BEN_LER_ENRT_CTFN_F
where business_group_id = p_bg_id;

cursor c236(p_bg_id NUMBER)
is select 1 from BEN_LER_CHG_PLIP_ENRT_RL_F
where business_group_id = p_bg_id;

cursor c237(p_bg_id NUMBER)
is select 1 from BEN_LER_CHG_PL_NIP_RL_F
where business_group_id = p_bg_id;

cursor c238(p_bg_id NUMBER)
is select 1 from BEN_PER_CM_F
where business_group_id = p_bg_id;

cursor c239(p_bg_id NUMBER)
is select 1 from BEN_PER_CM_TRGR_F
where business_group_id = p_bg_id;

cursor c240(p_bg_id NUMBER)
is select 1 from BEN_PL_BNF_CTFN_PRVDD_F
where business_group_id = p_bg_id;

cursor c241(p_bg_id NUMBER)
is select 1 from BEN_PTIP_DPNT_CVG_CTFN_F
where business_group_id = p_bg_id;

cursor c242(p_bg_id NUMBER)
is select 1 from BEN_WV_PRTN_RSN_PTIP_F
where business_group_id = p_bg_id;

cursor c243(p_bg_id NUMBER)
is select 1 from BEN_CVRD_DPNT_CTFN_PRVDD_F
where business_group_id = p_bg_id;

cursor c244(p_bg_id NUMBER)
is select 1 from BEN_PER_CM_USG_F
where business_group_id = p_bg_id;

cursor c245(p_bg_id NUMBER)
is select 1 from BEN_POPL_ORG_ROLE_F
where business_group_id = p_bg_id;

cursor c246(p_bg_id NUMBER)
is select 1 from BEN_ELIG_JOB_PRTE_F
where business_group_id = p_bg_id;

cursor c247(p_bg_id NUMBER)
is select 1 from BEN_WV_PRTN_RSN_CTFN_PTIP_F
where business_group_id = p_bg_id;

cursor c248(p_bg_id NUMBER)
is select 1 from BEN_BATCH_COMMU_INFO
where business_group_id = p_bg_id;

cursor c249(p_bg_id NUMBER)
is select 1 from BEN_BATCH_DPNT_INFO
where business_group_id = p_bg_id;

cursor c250(p_bg_id NUMBER)
is select 1 from BEN_BATCH_ELCTBL_CHC_INFO
where business_group_id = p_bg_id;

cursor c251(p_bg_id NUMBER)
is select 1 from BEN_BATCH_ELIG_INFO
where business_group_id = p_bg_id;

cursor c252(p_bg_id NUMBER)
is select 1 from BEN_BATCH_LER_INFO
where business_group_id = p_bg_id;

cursor c253(p_bg_id NUMBER)
is select 1 from BEN_BATCH_RATE_INFO
where business_group_id = p_bg_id;

cursor c254(p_bg_id NUMBER)
is select 1 from BEN_BENEFIT_ACTIONS
where business_group_id = p_bg_id;

cursor c255(p_bg_id NUMBER)
is select 1 from BEN_CLPSE_LF_EVT_F
where business_group_id = p_bg_id;

cursor c256(p_bg_id NUMBER)
is select 1 from BEN_PREM_CSTG_BY_SGMT_F
where business_group_id = p_bg_id;

cursor c257(p_bg_id NUMBER)
is select 1 from BEN_BATCH_PROC_INFO
where business_group_id = p_bg_id;

cursor c258(p_bg_id NUMBER)
is select 1 from BEN_PRTT_PREM_BY_MO_F
where business_group_id = p_bg_id;

cursor c259(p_bg_id NUMBER)
is select 1 from BEN_PER_CM_PRVDD_F
where business_group_id = p_bg_id;

cursor c260(p_bg_id NUMBER)
is select 1 from BEN_PRTT_REIMBMT_RQST_F
where business_group_id = p_bg_id;

cursor c261(p_bg_id NUMBER)
is select 1 from BEN_PRTT_CLM_GD_OR_SVC_TYP
where business_group_id = p_bg_id;

cursor c262(p_bg_id NUMBER)
is select 1 from BEN_ROLL_REIMB_RQST
where business_group_id = p_bg_id;

cursor c263(p_bg_id NUMBER)
is select 1 from BEN_ELIG_EE_STAT_PRTE_F
where business_group_id = p_bg_id;

cursor c264(p_bg_id NUMBER)
is select 1 from BEN_EE_STAT_RT_F
where business_group_id = p_bg_id;

cursor c265(p_bg_id NUMBER)
is select 1 from BEN_ELIG_ASNT_SET_PRTE_F
where business_group_id = p_bg_id;

cursor c266(p_bg_id NUMBER)
is select 1 from BEN_ACTY_BASE_RT_F
where business_group_id = p_bg_id;

cursor c267(p_bg_id NUMBER)
is select 1 from BEN_ACTY_RT_PTD_LMT_F
where business_group_id = p_bg_id;

cursor c268(p_bg_id NUMBER)
is select 1 from BEN_ACTY_RT_PYMT_SCHED_F
where business_group_id = p_bg_id;

cursor c269(p_bg_id NUMBER)
is select 1 from BEN_ACTY_VRBL_RT_F
where business_group_id = p_bg_id;

cursor c270(p_bg_id NUMBER)
is select 1 from BEN_APLCN_TO_BNFT_POOL_F
where business_group_id = p_bg_id;

cursor c271(p_bg_id NUMBER)
is select 1 from BEN_BNFT_POOL_RLOVR_RQMT_F
where business_group_id = p_bg_id;

cursor c272(p_bg_id NUMBER)
is select 1 from BEN_BNFT_PRVDD_LDGR_F
where business_group_id = p_bg_id;

cursor c273(p_bg_id NUMBER)
is select 1 from BEN_COMP_LVL_ACTY_RT_F
where business_group_id = p_bg_id;

cursor c274(p_bg_id NUMBER)
is select 1 from BEN_MTCHG_RT_F
where business_group_id = p_bg_id;

cursor c275(p_bg_id NUMBER)
is select 1 from BEN_PAIRD_RT_F
where business_group_id = p_bg_id;

cursor c276(p_bg_id NUMBER)
is select 1 from BEN_PRTL_MO_RT_PRTN_VAL_F
where business_group_id = p_bg_id;

cursor c277(p_bg_id NUMBER)
is select 1 from BEN_VRBL_RT_RL_F
where business_group_id = p_bg_id;

cursor c278(p_bg_id NUMBER)
is select 1 from BEN_DED_SCHED_PY_FREQ
where business_group_id = p_bg_id;

cursor c279(p_bg_id NUMBER)
is select 1 from BEN_ACTY_RT_DED_SCHED_F
where business_group_id = p_bg_id;

cursor c280(p_bg_id NUMBER)
is select 1 from BEN_PERD_TO_PROC
where business_group_id = p_bg_id;

cursor c281(p_bg_id NUMBER)
is select 1 from BEN_PYMT_SCHED_PY_FREQ
where business_group_id = p_bg_id;

cursor c282(p_bg_id NUMBER)
is select 1 from BEN_PRTT_ASSOCD_INSTN_F
where business_group_id = p_bg_id;

cursor c283(p_bg_id NUMBER)
is select 1 from BEN_PRTT_RT_VAL
where business_group_id = p_bg_id;

cursor c284(p_bg_id NUMBER)
is select 1 from BEN_PRTT_VSTG_F
where business_group_id = p_bg_id;

cursor c285(p_bg_id NUMBER)
is select 1 from BEN_ENRT_RT
where business_group_id = p_bg_id;

cursor c286(p_bg_id NUMBER)
is select 1 from BEN_PRTT_REIMBMT_RECON
where business_group_id = p_bg_id;

cursor c287(p_bg_id NUMBER)
is select 1 from BEN_ELIG_LOA_RSN_PRTE_F
where business_group_id = p_bg_id;

cursor c288(p_bg_id NUMBER)
is select 1 from BEN_LOA_RSN_RT_F
where business_group_id = p_bg_id;

cursor c289(p_bg_id NUMBER)
is select 1 from BEN_ELIG_PY_BSS_PRTE_F
where business_group_id = p_bg_id;

cursor c290(p_bg_id NUMBER)
is select 1 from BEN_PY_BSS_RT_F
where business_group_id = p_bg_id;

cursor c291(p_bg_id NUMBER)
is select 1 from BEN_ELIG_ENRLD_ANTHR_OIPL_F
where business_group_id = p_bg_id;

cursor c292(p_bg_id NUMBER)
is select 1 from BEN_PL_PCP
where business_group_id = p_bg_id;

cursor c293(p_bg_id NUMBER)
is select 1 from BEN_PL_PCP_TYP
where business_group_id = p_bg_id;

cursor c294(p_bg_id NUMBER)
is select 1 from BEN_OPTIP_F
where business_group_id = p_bg_id;


l_temp VARCHAR2(2);
BEGIN
--
-- Testing for values in BEN_CBR_QUALD_BNF
--
open c1(p_bg_id);
--
fetch c1 into l_temp;
if c1%found then
  close c1;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CBR_QUALD_BNF');
  fnd_message.raise_error;
end if;
--
close c1;

--
-- Testing for values in BEN_HLTH_CVG_SLCTD_RT_F
--
--open c2(p_bg_id);
--
--fetch c2 into l_temp;
--if c2%found then
--  close c2;
--  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
--  fnd_message.set_token('TABLE_NAME','BEN_HLTH_CVG_SLCTD_RT_F');
--  fnd_message.raise_error;
--end if;
--
--close c2;

--
-- Testing for values in BEN_PER_INFO_CHG_CS_LER_F
--
open c3(p_bg_id);
--
fetch c3 into l_temp;
if c3%found then
  close c3;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PER_INFO_CHG_CS_LER_F');
  fnd_message.raise_error;
end if;
--
close c3;

--
-- Testing for values in BEN_PRTN_IN_ANTHR_PL_RT_F
--
--open c4(p_bg_id);
--
--fetch c4 into l_temp;
--if c4%found then
--  close c4;
--  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
--  fnd_message.set_token('TABLE_NAME','BEN_PRTN_IN_ANTHR_PL_RT_F');
--  fnd_message.raise_error;
--end if;
--
--close c4;

--
-- Testing for values in BEN_PRTT_PREM_BY_MO_CR_F
--
--open c5(p_bg_id);
--
--fetch c5 into l_temp;
--if c5%found then
--  close c5;
--  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
--  fnd_message.set_token('TABLE_NAME','BEN_PRTT_PREM_BY_MO_CR_F');
--  fnd_message.raise_error;
--end if;
--
--close c5;

--
-- Testing for values in BEN_RLTD_PER_CHG_CS_LER_F
--
open c6(p_bg_id);
--
fetch c6 into l_temp;
if c6%found then
  close c6;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_RLTD_PER_CHG_CS_LER_F');
  fnd_message.raise_error;
end if;
--
close c6;

--
-- Testing for values in BEN_PCT_FL_TM_FCTR
--
open c7(p_bg_id);
--
fetch c7 into l_temp;
if c7%found then
  close c7;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PCT_FL_TM_FCTR');
  fnd_message.raise_error;
end if;
--
close c7;

--
-- Testing for values in BEN_AGE_FCTR
--
open c8(p_bg_id);
--
fetch c8 into l_temp;
if c8%found then
  close c8;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_AGE_FCTR');
  fnd_message.raise_error;
end if;
--
close c8;

--
-- Testing for values in BEN_BENFTS_GRP
--
open c9(p_bg_id);
--
fetch c9 into l_temp;
if c9%found then
  close c9;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BENFTS_GRP');
  fnd_message.raise_error;
end if;
--
close c9;

--
-- Testing for values in BEN_GD_OR_SVC_TYP
--
open c10(p_bg_id);
--
fetch c10 into l_temp;
if c10%found then
  close c10;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_GD_OR_SVC_TYP');
  fnd_message.raise_error;
end if;
--
close c10;

--
-- Testing for values in BEN_LOS_FCTR
--
open c11(p_bg_id);
--
fetch c11 into l_temp;
if c11%found then
  close c11;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LOS_FCTR');
  fnd_message.raise_error;
end if;
--
close c11;

--
-- Testing for values in BEN_ELIGY_PRFL_F
--
open c12(p_bg_id);
--
fetch c12 into l_temp;
if c12%found then
  close c12;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIGY_PRFL_F');
  fnd_message.raise_error;
end if;
--
close c12;

--
-- Testing for values in BEN_ELIG_LVG_RSN_PRTE_F
--
open c13(p_bg_id);
--
fetch c13 into l_temp;
if c13%found then
  close c13;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_LVG_RSN_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c13;

--
-- Testing for values in BEN_ELIG_NO_OTHR_CVG_PRTE_F
--
open c14(p_bg_id);
--
fetch c14 into l_temp;
if c14%found then
  close c14;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_NO_OTHR_CVG_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c14;

--
-- Testing for values in BEN_ELIG_OPTD_MDCR_PRTE_F
--
open c15(p_bg_id);
--
fetch c15 into l_temp;
if c15%found then
  close c15;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_OPTD_MDCR_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c15;

--
-- Testing for values in BEN_ACTN_TYP
--
open c16(p_bg_id);
--
fetch c16 into l_temp;
if c16%found then
  close c16;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ACTN_TYP');
  fnd_message.raise_error;
end if;
--
close c16;

--
-- Testing for values in BEN_BATCH_ACTN_ITEM_INFO
--
open c17(p_bg_id);
--
fetch c17 into l_temp;
if c17%found then
  close c17;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BATCH_ACTN_ITEM_INFO');
  fnd_message.raise_error;
end if;
--
close c17;

--
-- Testing for values in BEN_BATCH_PARAMETER
--
open c18(p_bg_id);
--
fetch c18 into l_temp;
if c18%found then
  close c18;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BATCH_PARAMETER');
  fnd_message.raise_error;
end if;
--
close c18;

--
-- Testing for values in BEN_BNFTS_BAL_F
--
open c19(p_bg_id);
--
fetch c19 into l_temp;
if c19%found then
  close c19;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BNFTS_BAL_F');
  fnd_message.raise_error;
end if;
--
close c19;

--
-- Testing for values in BEN_CM_TYP_F
--
open c20(p_bg_id);
--
fetch c20 into l_temp;
if c20%found then
  close c20;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CM_TYP_F');
  fnd_message.raise_error;
end if;
--
close c20;

--
-- Testing for values in BEN_CM_TYP_TRGR_F
--
open c21(p_bg_id);
--
fetch c21 into l_temp;
if c21%found then
  close c21;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CM_TYP_TRGR_F');
  fnd_message.raise_error;
end if;
--
close c21;

--
-- Testing for values in BEN_CNTNG_PRTN_ELIG_PRFL_F
--
open c22(p_bg_id);
--
fetch c22 into l_temp;
if c22%found then
  close c22;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CNTNG_PRTN_ELIG_PRFL_F');
  fnd_message.raise_error;
end if;
--
close c22;

--
-- Testing for values in BEN_COMP_ASSET
--
open c23(p_bg_id);
--
fetch c23 into l_temp;
if c23%found then
  close c23;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_COMP_ASSET');
  fnd_message.raise_error;
end if;
--
close c23;

--
-- Testing for values in BEN_CSR_ACTIVITIES
--
open c24(p_bg_id);
--
fetch c24 into l_temp;
if c24%found then
  close c24;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CSR_ACTIVITIES');
  fnd_message.raise_error;
end if;
--
close c24;

--
-- Testing for values in BEN_ELIG_BRGNG_UNIT_PRTE_F
--
open c25(p_bg_id);
--
fetch c25 into l_temp;
if c25%found then
  close c25;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_BRGNG_UNIT_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c25;

--
-- Testing for values in BEN_ELIG_FL_TM_PT_TM_PRTE_F
--
open c26(p_bg_id);
--
fetch c26 into l_temp;
if c26%found then
  close c26;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_FL_TM_PT_TM_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c26;

--
-- Testing for values in BEN_ELIG_HRLY_SLRD_PRTE_F
--
open c27(p_bg_id);
--
fetch c27 into l_temp;
if c27%found then
  close c27;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_HRLY_SLRD_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c27;

--
-- Testing for values in BEN_ELIG_LBR_MMBR_PRTE_F
--
open c28(p_bg_id);
--
fetch c28 into l_temp;
if c28%found then
  close c28;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_LBR_MMBR_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c28;

--
-- Testing for values in BEN_ELIG_PER_TYP_PRTE_F
--
open c29(p_bg_id);
--
fetch c29 into l_temp;
if c29%found then
  close c29;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_PER_TYP_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c29;

--
-- Testing for values in BEN_ELIG_PYRL_PRTE_F
--
open c30(p_bg_id);
--
fetch c30 into l_temp;
if c30%found then
  close c30;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_PYRL_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c30;

--
-- Testing for values in BEN_ELIG_SCHEDD_HRS_PRTE_F
--
open c31(p_bg_id);
--
fetch c31 into l_temp;
if c31%found then
  close c31;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_SCHEDD_HRS_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c31;

--
-- Testing for values in BEN_EXT_CHG_EVT_LOG
--
open c32(p_bg_id);
--
fetch c32 into l_temp;
if c32%found then
  close c32;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_CHG_EVT_LOG');
  fnd_message.raise_error;
end if;
--
close c32;

--
-- Testing for values in BEN_EXT_CRIT_PRFL
--
open c33(p_bg_id);
--
fetch c33 into l_temp;
if c33%found then
  close c33;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_CRIT_PRFL');
  fnd_message.raise_error;
end if;
--
close c33;

--
-- Testing for values in BEN_EXT_FILE
--
open c34(p_bg_id);
--
fetch c34 into l_temp;
if c34%found then
  close c34;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_FILE');
  fnd_message.raise_error;
end if;
--
close c34;

--
-- Testing for values in BEN_EXT_FLD
--
open c35(p_bg_id);
--
fetch c35 into l_temp;
if c35%found then
  close c35;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_FLD');
  fnd_message.raise_error;
end if;
--
close c35;

--
-- Testing for values in BEN_EXT_RCD
--
open c36(p_bg_id);
--
fetch c36 into l_temp;
if c36%found then
  close c36;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_RCD');
  fnd_message.raise_error;
end if;
--
close c36;

--
-- Testing for values in BEN_PIN
--
open c37(p_bg_id);
--
fetch c37 into l_temp;
if c37%found then
  close c37;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PIN');
  fnd_message.raise_error;
end if;
--
close c37;

--
-- Testing for values in BEN_PL_TYP_F
--
open c38(p_bg_id);
--
fetch c38 into l_temp;
if c38%found then
  close c38;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_TYP_F');
  fnd_message.raise_error;
end if;
--
close c38;

--
-- Testing for values in BEN_POP_UP_MESSAGES
--
open c39(p_bg_id);
--
fetch c39 into l_temp;
if c39%found then
  close c39;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_POP_UP_MESSAGES');
  fnd_message.raise_error;
end if;
--
close c39;

--
-- Testing for values in BEN_PSTL_ZIP_RNG_F
--
open c40(p_bg_id);
--
fetch c40 into l_temp;
if c40%found then
  close c40;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PSTL_ZIP_RNG_F');
  fnd_message.raise_error;
end if;
--
close c40;

--
-- Testing for values in BEN_VSTG_SCHED_F
--
open c41(p_bg_id);
--
fetch c41 into l_temp;
if c41%found then
  close c41;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_VSTG_SCHED_F');
  fnd_message.raise_error;
end if;
--
close c41;

--
-- Testing for values in BEN_YR_PERD
--
open c42(p_bg_id);
--
fetch c42 into l_temp;
if c42%found then
  close c42;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_YR_PERD');
  fnd_message.raise_error;
end if;
--
close c42;

--
-- Testing for values in BEN_CMBN_AGE_LOS_FCTR
--
open c43(p_bg_id);
--
fetch c43 into l_temp;
if c43%found then
  close c43;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CMBN_AGE_LOS_FCTR');
  fnd_message.raise_error;
end if;
--
close c43;

--
-- Testing for values in BEN_CM_DLVRY_MTHD_TYP
--
open c44(p_bg_id);
--
fetch c44 into l_temp;
if c44%found then
  close c44;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CM_DLVRY_MTHD_TYP');
  fnd_message.raise_error;
end if;
--
close c44;

--
-- Testing for values in BEN_CNTNU_PRTN_CTFN_TYP_F
--
open c45(p_bg_id);
--
fetch c45 into l_temp;
if c45%found then
  close c45;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CNTNU_PRTN_CTFN_TYP_F');
  fnd_message.raise_error;
end if;
--
close c45;

--
-- Testing for values in BEN_ELIGY_PRFL_RL_F
--
open c46(p_bg_id);
--
fetch c46 into l_temp;
if c46%found then
  close c46;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIGY_PRFL_RL_F');
  fnd_message.raise_error;
end if;
--
close c46;

--
-- Testing for values in BEN_ELIG_AGE_PRTE_F
--
open c47(p_bg_id);
--
fetch c47 into l_temp;
if c47%found then
  close c47;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_AGE_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c47;

--
-- Testing for values in BEN_ELIG_BENFTS_GRP_PRTE_F
--
open c48(p_bg_id);
--
fetch c48 into l_temp;
if c48%found then
  close c48;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_BENFTS_GRP_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c48;

--
-- Testing for values in BEN_ELIG_LOS_PRTE_F
--
open c49(p_bg_id);
--
fetch c49 into l_temp;
if c49%found then
  close c49;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_LOS_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c49;

--
-- Testing for values in BEN_ELIG_PCT_FL_TM_PRTE_F
--
open c50(p_bg_id);
--
fetch c50 into l_temp;
if c50%found then
  close c50;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_PCT_FL_TM_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c50;

--
-- Testing for values in BEN_ELIG_PSTL_CD_R_RNG_PRTE_F
--
open c51(p_bg_id);
--
fetch c51 into l_temp;
if c51%found then
  close c51;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_PSTL_CD_R_RNG_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c51;

--
-- Testing for values in BEN_ELIG_WK_LOC_PRTE_F
--
open c52(p_bg_id);
--
fetch c52 into l_temp;
if c52%found then
  close c52;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_WK_LOC_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c52;

--
-- Testing for values in BEN_EXT_CRIT_TYP
--
open c53(p_bg_id);
--
fetch c53 into l_temp;
if c53%found then
  close c53;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_CRIT_TYP');
  fnd_message.raise_error;
end if;
--
close c53;

--
-- Testing for values in BEN_EXT_DFN
--
open c54(p_bg_id);
--
fetch c54 into l_temp;
if c54%found then
  close c54;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_DFN');
  fnd_message.raise_error;
end if;
--
close c54;

--
-- Testing for values in BEN_ORG_UNIT_PRDCT_F
--
open c55(p_bg_id);
--
fetch c55 into l_temp;
if c55%found then
  close c55;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ORG_UNIT_PRDCT_F');
  fnd_message.raise_error;
end if;
--
close c55;

--
-- Testing for values in BEN_PER_BNFTS_BAL_F
--
open c56(p_bg_id);
--
fetch c56 into l_temp;
if c56%found then
  close c56;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PER_BNFTS_BAL_F');
  fnd_message.raise_error;
end if;
--
close c56;

--
-- Testing for values in BEN_PER_PIN_F
--
open c57(p_bg_id);
--
fetch c57 into l_temp;
if c57%found then
  close c57;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PER_PIN_F');
  fnd_message.raise_error;
end if;
--
close c57;

--
-- Testing for values in BEN_VSTG_AGE_RQMT
--
open c58(p_bg_id);
--
fetch c58 into l_temp;
if c58%found then
  close c58;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_VSTG_AGE_RQMT');
  fnd_message.raise_error;
end if;
--
close c58;

--
-- Testing for values in BEN_VSTG_FOR_ACTY_RT_F
--
open c59(p_bg_id);
--
fetch c59 into l_temp;
if c59%found then
  close c59;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_VSTG_FOR_ACTY_RT_F');
  fnd_message.raise_error;
end if;
--
close c59;

--
-- Testing for values in BEN_WTHN_YR_PERD
--
open c60(p_bg_id);
--
fetch c60 into l_temp;
if c60%found then
  close c60;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_WTHN_YR_PERD');
  fnd_message.raise_error;
end if;
--
close c60;

--
-- Testing for values in BEN_CM_DLVRY_MED_TYP
--
open c61(p_bg_id);
--
fetch c61 into l_temp;
if c61%found then
  close c61;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CM_DLVRY_MED_TYP');
  fnd_message.raise_error;
end if;
--
close c61;

--
-- Testing for values in BEN_ELIG_SVC_AREA_PRTE_F
--
open c62(p_bg_id);
--
fetch c62 into l_temp;
if c62%found then
  close c62;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_SVC_AREA_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c62;

--
-- Testing for values in BEN_EXT_CRIT_VAL
--
open c63(p_bg_id);
--
fetch c63 into l_temp;
if c63%found then
  close c63;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_CRIT_VAL');
  fnd_message.raise_error;
end if;
--
close c63;

--
-- Testing for values in BEN_EXT_DATA_ELMT
--
open c64(p_bg_id);
--
fetch c64 into l_temp;
if c64%found then
  close c64;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_DATA_ELMT');
  fnd_message.raise_error;
end if;
--
close c64;

--
-- Testing for values in BEN_EXT_RSLT
--
open c65(p_bg_id);
--
fetch c65 into l_temp;
if c65%found then
  close c65;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_RSLT');
  fnd_message.raise_error;
end if;
--
close c65;

--
-- Testing for values in BEN_SVC_AREA_F
--
open c66(p_bg_id);
--
fetch c66 into l_temp;
if c66%found then
  close c66;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_SVC_AREA_F');
  fnd_message.raise_error;
end if;
--
close c66;

--
-- Testing for values in BEN_VSTG_LOS_RQMT
--
open c67(p_bg_id);
--
fetch c67 into l_temp;
if c67%found then
  close c67;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_VSTG_LOS_RQMT');
  fnd_message.raise_error;
end if;
--
close c67;

--
-- Testing for values in BEN_ELIG_CMBN_AGE_LOS_PRTE_F
--
open c68(p_bg_id);
--
fetch c68 into l_temp;
if c68%found then
  close c68;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_CMBN_AGE_LOS_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c68;

--
-- Testing for values in BEN_EXT_CRIT_CMBN
--
open c69(p_bg_id);
--
fetch c69 into l_temp;
if c69%found then
  close c69;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_CRIT_CMBN');
  fnd_message.raise_error;
end if;
--
close c69;

--
-- Testing for values in BEN_EXT_DATA_ELMT_DECD
--
open c70(p_bg_id);
--
fetch c70 into l_temp;
if c70%found then
  close c70;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_DATA_ELMT_DECD');
  fnd_message.raise_error;
end if;
--
close c70;

--
-- Testing for values in BEN_EXT_DATA_ELMT_IN_RCD
--
open c71(p_bg_id);
--
fetch c71 into l_temp;
if c71%found then
  close c71;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_DATA_ELMT_IN_RCD');
  fnd_message.raise_error;
end if;
--
close c71;

--
-- Testing for values in BEN_EXT_RSLT_DTL
--
open c72(p_bg_id);
--
fetch c72 into l_temp;
if c72%found then
  close c72;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_RSLT_DTL');
  fnd_message.raise_error;
end if;
--
close c72;

--
-- Testing for values in BEN_SVC_AREA_PSTL_ZIP_RNG_F
--
open c73(p_bg_id);
--
fetch c73 into l_temp;
if c73%found then
  close c73;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_SVC_AREA_PSTL_ZIP_RNG_F');
  fnd_message.raise_error;
end if;
--
close c73;

--
-- Testing for values in BEN_COMP_LVL_FCTR
--
open c74(p_bg_id);
--
fetch c74 into l_temp;
if c74%found then
  close c74;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_COMP_LVL_FCTR');
  fnd_message.raise_error;
end if;
--
close c74;

--
-- Testing for values in BEN_ELIG_LGL_ENTY_PRTE_F
--
open c75(p_bg_id);
--
fetch c75 into l_temp;
if c75%found then
  close c75;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_LGL_ENTY_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c75;

--
-- Testing for values in BEN_ELIG_ORG_UNIT_PRTE_F
--
open c76(p_bg_id);
--
fetch c76 into l_temp;
if c76%found then
  close c76;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_ORG_UNIT_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c76;

--
-- Testing for values in BEN_EXT_RSLT_ERR
--
open c77(p_bg_id);
--
fetch c77 into l_temp;
if c77%found then
  close c77;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_RSLT_ERR');
  fnd_message.raise_error;
end if;
--
close c77;

--
-- Testing for values in BEN_REGN_F
--
open c78(p_bg_id);
--
fetch c78 into l_temp;
if c78%found then
  close c78;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_REGN_F');
  fnd_message.raise_error;
end if;
--
close c78;

--
-- Testing for values in BEN_EXT_INCL_DATA_ELMT
--
open c79(p_bg_id);
--
fetch c79 into l_temp;
if c79%found then
  close c79;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_INCL_DATA_ELMT');
  fnd_message.raise_error;
end if;
--
close c79;

--
-- Testing for values in BEN_EXT_RCD_IN_FILE
--
open c80(p_bg_id);
--
fetch c80 into l_temp;
if c80%found then
  close c80;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_RCD_IN_FILE');
  fnd_message.raise_error;
end if;
--
close c80;

--
-- Testing for values in BEN_REGN_FOR_REGY_BODY_F
--
open c81(p_bg_id);
--
fetch c81 into l_temp;
if c81%found then
  close c81;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_REGN_FOR_REGY_BODY_F');
  fnd_message.raise_error;
end if;
--
close c81;

--
-- Testing for values in BEN_EXT_INCL_CHG
--
open c82(p_bg_id);
--
fetch c82 into l_temp;
if c82%found then
  close c82;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_INCL_CHG');
  fnd_message.raise_error;
end if;
--
close c82;

--
-- Testing for values in BEN_EXT_WHERE_CLAUSE
--
open c83(p_bg_id);
--
fetch c83 into l_temp;
if c83%found then
  close c83;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EXT_WHERE_CLAUSE');
  fnd_message.raise_error;
end if;
--
close c83;

--
-- Testing for values in BEN_RPTG_GRP
--
open c84(p_bg_id);
--
fetch c84 into l_temp;
if c84%found then
  close c84;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_RPTG_GRP');
  fnd_message.raise_error;
end if;
--
close c84;

--
-- Testing for values in BEN_DPNT_CVG_ELIGY_PRFL_F
--
open c85(p_bg_id);
--
fetch c85 into l_temp;
if c85%found then
  close c85;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_DPNT_CVG_ELIGY_PRFL_F');
  fnd_message.raise_error;
end if;
--
close c85;

--
-- Testing for values in BEN_HRS_WKD_IN_PERD_FCTR
--
open c86(p_bg_id);
--
fetch c86 into l_temp;
if c86%found then
  close c86;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_HRS_WKD_IN_PERD_FCTR');
  fnd_message.raise_error;
end if;
--
close c86;

--
-- Testing for values in BEN_DPNT_CVG_RQD_RLSHP_F
--
open c87(p_bg_id);
--
fetch c87 into l_temp;
if c87%found then
  close c87;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_DPNT_CVG_RQD_RLSHP_F');
  fnd_message.raise_error;
end if;
--
close c87;

--
-- Testing for values in BEN_DSGNTR_ENRLD_CVG_F
--
open c88(p_bg_id);
--
fetch c88 into l_temp;
if c88%found then
  close c88;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_DSGNTR_ENRLD_CVG_F');
  fnd_message.raise_error;
end if;
--
close c88;

--
-- Testing for values in BEN_ELIG_COMP_LVL_PRTE_F
--
open c89(p_bg_id);
--
fetch c89 into l_temp;
if c89%found then
  close c89;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_COMP_LVL_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c89;

--
-- Testing for values in BEN_ELIG_DSBLD_STAT_CVG_F
--
open c90(p_bg_id);
--
fetch c90 into l_temp;
if c90%found then
  close c90;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_DSBLD_STAT_CVG_F');
  fnd_message.raise_error;
end if;
--
close c90;

--
-- Testing for values in BEN_ELIG_HRS_WKD_PRTE_F
--
open c91(p_bg_id);
--
fetch c91 into l_temp;
if c91%found then
  close c91;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_HRS_WKD_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c91;

--
-- Testing for values in BEN_ELIG_MLTRY_STAT_CVG_F
--
open c92(p_bg_id);
--
fetch c92 into l_temp;
if c92%found then
  close c92;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_MLTRY_STAT_CVG_F');
  fnd_message.raise_error;
end if;
--
close c92;

--
-- Testing for values in BEN_ELIG_MRTL_STAT_CVG_F
--
open c93(p_bg_id);
--
fetch c93 into l_temp;
if c93%found then
  close c93;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_MRTL_STAT_CVG_F');
  fnd_message.raise_error;
end if;
--
close c93;

--
-- Testing for values in BEN_ELIG_STDNT_STAT_CVG_F
--
open c94(p_bg_id);
--
fetch c94 into l_temp;
if c94%found then
  close c94;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_STDNT_STAT_CVG_F');
  fnd_message.raise_error;
end if;
--
close c94;

--
-- Testing for values in BEN_ELIG_AGE_CVG_F
--
open c95(p_bg_id);
--
fetch c95 into l_temp;
if c95%found then
  close c95;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_AGE_CVG_F');
  fnd_message.raise_error;
end if;
--
close c95;

--
-- Testing for values in BEN_ELIG_PSTL_CD_R_RNG_CVG_F
--
open c96(p_bg_id);
--
fetch c96 into l_temp;
if c96%found then
  close c96;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_PSTL_CD_R_RNG_CVG_F');
  fnd_message.raise_error;
end if;
--
close c96;

--
-- Testing for values in BEN_PTD_LMT_F
--
open c97(p_bg_id);
--
fetch c97 into l_temp;
if c97%found then
  close c97;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PTD_LMT_F');
  fnd_message.raise_error;
end if;
--
close c97;

--
-- Testing for values in BEN_PTD_BAL_TYP_F
--
open c98(p_bg_id);
--
fetch c98 into l_temp;
if c98%found then
  close c98;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PTD_BAL_TYP_F');
  fnd_message.raise_error;
end if;
--
close c98;

--
-- Testing for values in BEN_ELIG_GRD_PRTE_F
--
open c99(p_bg_id);
--
fetch c99 into l_temp;
if c99%found then
  close c99;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_GRD_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c99;

--
-- Testing for values in BEN_PER_DLVRY_MTHD_F
--
open c100(p_bg_id);
--
fetch c100 into l_temp;
if c100%found then
  close c100;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PER_DLVRY_MTHD_F');
  fnd_message.raise_error;
end if;
--
close c100;

--
-- Testing for values in BEN_PER_IN_LGL_ENTY_F
--
open c101(p_bg_id);
--
fetch c101 into l_temp;
if c101%found then
  close c101;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PER_IN_LGL_ENTY_F');
  fnd_message.raise_error;
end if;
--
close c101;

--
-- Testing for values in BEN_PER_IN_ORG_UNIT_F
--
open c102(p_bg_id);
--
fetch c102 into l_temp;
if c102%found then
  close c102;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PER_IN_ORG_UNIT_F');
  fnd_message.raise_error;
end if;
--
close c102;

--
-- Testing for values in BEN_PER_IN_ORG_ROLE_F
--
open c103(p_bg_id);
--
fetch c103 into l_temp;
if c103%found then
  close c103;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PER_IN_ORG_ROLE_F');
  fnd_message.raise_error;
end if;
--
close c103;

--
-- Testing for values in BEN_ACRS_PTIP_CVG_F
--
open c104(p_bg_id);
--
fetch c104 into l_temp;
if c104%found then
  close c104;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ACRS_PTIP_CVG_F');
  fnd_message.raise_error;
end if;
--
close c104;

--
-- Testing for values in BEN_PL_TYP_OPT_TYP_F
--
open c105(p_bg_id);
--
fetch c105 into l_temp;
if c105%found then
  close c105;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_TYP_OPT_TYP_F');
  fnd_message.raise_error;
end if;
--
close c105;

--
-- Testing for values in BEN_ENRT_PERD
--
open c106(p_bg_id);
--
fetch c106 into l_temp;
if c106%found then
  close c106;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ENRT_PERD');
  fnd_message.raise_error;
end if;
--
close c106;

--
-- Testing for values in BEN_OPT_F
--
open c107(p_bg_id);
--
fetch c107 into l_temp;
if c107%found then
  close c107;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_OPT_F');
  fnd_message.raise_error;
end if;
--
close c107;

--
-- Testing for values in BEN_LER_F
--
open c108(p_bg_id);
--
fetch c108 into l_temp;
if c108%found then
  close c108;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_F');
  fnd_message.raise_error;
end if;
--
close c108;

--
-- Testing for values in BEN_LER_RLTD_PER_CS_LER_F
--
open c109(p_bg_id);
--
fetch c109 into l_temp;
if c109%found then
  close c109;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_RLTD_PER_CS_LER_F');
  fnd_message.raise_error;
end if;
--
close c109;

--
-- Testing for values in BEN_CBR_PER_IN_LER
--
open c110(p_bg_id);
--
fetch c110 into l_temp;
if c110%found then
  close c110;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CBR_PER_IN_LER');
  fnd_message.raise_error;
end if;
--
close c110;

--
-- Testing for values in BEN_CSS_RLTD_PER_PER_IN_LER_F
--
open c111(p_bg_id);
--
fetch c111 into l_temp;
if c111%found then
  close c111;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CSS_RLTD_PER_PER_IN_LER_F');
  fnd_message.raise_error;
end if;
--
close c111;

--
-- Testing for values in BEN_LER_PER_INFO_CS_LER_F
--
open c112(p_bg_id);
--
fetch c112 into l_temp;
if c112%found then
  close c112;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_PER_INFO_CS_LER_F');
  fnd_message.raise_error;
end if;
--
close c112;

--
-- Testing for values in BEN_LE_CLSN_N_RSTR
--
open c113(p_bg_id);
--
fetch c113 into l_temp;
if c113%found then
  close c113;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LE_CLSN_N_RSTR');
  fnd_message.raise_error;
end if;
--
close c113;

--
-- Testing for values in BEN_PER_IN_LER
--
open c114(p_bg_id);
--
fetch c114 into l_temp;
if c114%found then
  close c114;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PER_IN_LER');
  fnd_message.raise_error;
end if;
--
close c114;

--
-- Testing for values in BEN_PTNL_LER_FOR_PER
--
open c115(p_bg_id);
--
fetch c115 into l_temp;
if c115%found then
  close c115;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PTNL_LER_FOR_PER');
  fnd_message.raise_error;
end if;
--
close c115;

--
-- Testing for values in BEN_PGM_F
--
open c116(p_bg_id);
--
fetch c116 into l_temp;
if c116%found then
  close c116;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PGM_F');
  fnd_message.raise_error;
end if;
--
close c116;

--
-- Testing for values in BEN_ELIG_ENRLD_ANTHR_PGM_F
--
open c117(p_bg_id);
--
fetch c117 into l_temp;
if c117%found then
  close c117;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_ENRLD_ANTHR_PGM_F');
  fnd_message.raise_error;
end if;
--
close c117;

--
-- Testing for values in BEN_ELIG_PRTT_ANTHR_PGM_F
--
open c118(p_bg_id);
--
fetch c118 into l_temp;
if c118%found then
  close c118;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_PRTT_ANTHR_PGM_F');
  fnd_message.raise_error;
end if;
--
close c118;

--
-- Testing for values in BEN_PLIP_F
--
open c119(p_bg_id);
--
fetch c119 into l_temp;
if c119%found then
  close c119;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PLIP_F');
  fnd_message.raise_error;
end if;
--
close c119;

--
-- Testing for values in BEN_PL_F
--
open c120(p_bg_id);
--
fetch c120 into l_temp;
if c120%found then
  close c120;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_F');
  fnd_message.raise_error;
end if;
--
close c120;

--
-- Testing for values in BEN_PTIP_F
--
open c121(p_bg_id);
--
fetch c121 into l_temp;
if c121%found then
  close c121;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PTIP_F');
  fnd_message.raise_error;
end if;
--
close c121;

--
-- Testing for values in BEN_DPNT_CVRD_ANTHR_PL_CVG_F
--
open c122(p_bg_id);
--
fetch c122 into l_temp;
if c122%found then
  close c122;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_DPNT_CVRD_ANTHR_PL_CVG_F');
  fnd_message.raise_error;
end if;
--
close c122;

--
-- Testing for values in BEN_ELIG_DPNT_CVRD_OTHR_PL_F
--
open c124(p_bg_id);
--
fetch c124 into l_temp;
if c124%found then
  close c124;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_DPNT_CVRD_OTHR_PL_F');
  fnd_message.raise_error;
end if;
--
close c124;

--
-- Testing for values in BEN_ELIG_ENRLD_ANTHR_PL_F
--
open c125(p_bg_id);
--
fetch c125 into l_temp;
if c125%found then
  close c125;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_ENRLD_ANTHR_PL_F');
  fnd_message.raise_error;
end if;
--
close c125;

--
-- Testing for values in BEN_ENRT_ENRLD_ANTHR_PL_F
--
open c126(p_bg_id);
--
fetch c126 into l_temp;
if c126%found then
  close c126;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ENRT_ENRLD_ANTHR_PL_F');
  fnd_message.raise_error;
end if;
--
close c126;

--
-- Testing for values in BEN_OIPLIP_F
--
open c127(p_bg_id);
--
fetch c127 into l_temp;
if c127%found then
  close c127;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_OIPLIP_F');
  fnd_message.raise_error;
end if;
--
close c127;

--
-- Testing for values in BEN_OIPL_F
--
open c128(p_bg_id);
--
fetch c128 into l_temp;
if c128%found then
  close c128;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_OIPL_F');
  fnd_message.raise_error;
end if;
--
close c128;

--
-- Testing for values in BEN_PGM_DPNT_CVG_CTFN_F
--
open c129(p_bg_id);
--
fetch c129 into l_temp;
if c129%found then
  close c129;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PGM_DPNT_CVG_CTFN_F');
  fnd_message.raise_error;
end if;
--
close c129;

--
-- Testing for values in BEN_BNFT_PRVDR_POOL_F
--
open c130(p_bg_id);
--
fetch c130 into l_temp;
if c130%found then
  close c130;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BNFT_PRVDR_POOL_F');
  fnd_message.raise_error;
end if;
--
close c130;

--
-- Testing for values in BEN_CMBN_PLIP_F
--
open c131(p_bg_id);
--
fetch c131 into l_temp;
if c131%found then
  close c131;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CMBN_PLIP_F');
  fnd_message.raise_error;
end if;
--
close c131;

--
-- Testing for values in BEN_CMBN_PTIP_F
--
open c132(p_bg_id);
--
fetch c132 into l_temp;
if c132%found then
  close c132;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CMBN_PTIP_F');
  fnd_message.raise_error;
end if;
--
close c132;

--
-- Testing for values in BEN_CMBN_PTIP_OPT_F
--
open c133(p_bg_id);
--
fetch c133 into l_temp;
if c133%found then
  close c133;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CMBN_PTIP_OPT_F');
  fnd_message.raise_error;
end if;
--
close c133;

--
-- Testing for values in BEN_CM_TYP_USG_F
--
open c134(p_bg_id);
--
fetch c134 into l_temp;
if c134%found then
  close c134;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CM_TYP_USG_F');
  fnd_message.raise_error;
end if;
--
close c134;

--
-- Testing for values in BEN_DSGN_RQMT_F
--
open c135(p_bg_id);
--
fetch c135 into l_temp;
if c135%found then
  close c135;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_DSGN_RQMT_F');
  fnd_message.raise_error;
end if;
--
close c135;

--
-- Testing for values in BEN_ELIG_TO_PRTE_RSN_F
--
open c136(p_bg_id);
--
fetch c136 into l_temp;
if c136%found then
  close c136;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_TO_PRTE_RSN_F');
  fnd_message.raise_error;
end if;
--
close c136;

--
-- Testing for values in BEN_LER_CHG_PGM_ENRT_F
--
open c137(p_bg_id);
--
fetch c137 into l_temp;
if c137%found then
  close c137;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_CHG_PGM_ENRT_F');
  fnd_message.raise_error;
end if;
--
close c137;

--
-- Testing for values in BEN_PL_BNF_CTFN_F
--
open c138(p_bg_id);
--
fetch c138 into l_temp;
if c138%found then
  close c138;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_BNF_CTFN_F');
  fnd_message.raise_error;
end if;
--
close c138;

--
-- Testing for values in BEN_PL_DPNT_CVG_CTFN_F
--
open c139(p_bg_id);
--
fetch c139 into l_temp;
if c139%found then
  close c139;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_DPNT_CVG_CTFN_F');
  fnd_message.raise_error;
end if;
--
close c139;

--
-- Testing for values in BEN_PL_GD_OR_SVC_F
--
open c140(p_bg_id);
--
fetch c140 into l_temp;
if c140%found then
  close c140;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_GD_OR_SVC_F');
  fnd_message.raise_error;
end if;
--
close c140;

--
-- Testing for values in BEN_PL_REGN_F
--
open c141(p_bg_id);
--
fetch c141 into l_temp;
if c141%found then
  close c141;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_REGN_F');
  fnd_message.raise_error;
end if;
--
close c141;

--
-- Testing for values in BEN_PL_REGY_BOD_F
--
open c142(p_bg_id);
--
fetch c142 into l_temp;
if c142%found then
  close c142;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_REGY_BOD_F');
  fnd_message.raise_error;
end if;
--
close c142;

--
-- Testing for values in BEN_POPL_ACTN_TYP_F
--
open c143(p_bg_id);
--
fetch c143 into l_temp;
if c143%found then
  close c143;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_POPL_ACTN_TYP_F');
  fnd_message.raise_error;
end if;
--
close c143;

--
-- Testing for values in BEN_POPL_ENRT_TYP_CYCL_F
--
open c144(p_bg_id);
--
fetch c144 into l_temp;
if c144%found then
  close c144;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_POPL_ENRT_TYP_CYCL_F');
  fnd_message.raise_error;
end if;
--
close c144;

--
-- Testing for values in BEN_POPL_ORG_F
--
open c145(p_bg_id);
--
fetch c145 into l_temp;
if c145%found then
  close c145;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_POPL_ORG_F');
  fnd_message.raise_error;
end if;
--
close c145;

--
-- Testing for values in BEN_WV_PRTN_RSN_PL_F
--
open c146(p_bg_id);
--
fetch c146 into l_temp;
if c146%found then
  close c146;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_WV_PRTN_RSN_PL_F');
  fnd_message.raise_error;
end if;
--
close c146;

--
-- Testing for values in BEN_CRT_ORDR
--
open c147(p_bg_id);
--
fetch c147 into l_temp;
if c147%found then
  close c147;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CRT_ORDR');
  fnd_message.raise_error;
end if;
--
close c147;

--
-- Testing for values in BEN_ELIG_PRTT_ANTHR_PL_PRTE_F
--
open c148(p_bg_id);
--
fetch c148 into l_temp;
if c148%found then
  close c148;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_PRTT_ANTHR_PL_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c148;

--
-- Testing for values in BEN_ENRT_CTFN_F
--
open c149(p_bg_id);
--
fetch c149 into l_temp;
if c149%found then
  close c149;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ENRT_CTFN_F');
  fnd_message.raise_error;
end if;
--
close c149;

--
-- Testing for values in BEN_LEE_RSN_F
--
open c150(p_bg_id);
--
fetch c150 into l_temp;
if c150%found then
  close c150;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LEE_RSN_F');
  fnd_message.raise_error;
end if;
--
close c150;

--
-- Testing for values in BEN_PL_R_OIPL_ASSET_F
--
open c151(p_bg_id);
--
fetch c151 into l_temp;
if c151%found then
  close c151;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_R_OIPL_ASSET_F');
  fnd_message.raise_error;
end if;
--
close c151;

--
-- Testing for values in BEN_POPL_RPTG_GRP_F
--
open c152(p_bg_id);
--
fetch c152 into l_temp;
if c152%found then
  close c152;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_POPL_RPTG_GRP_F');
  fnd_message.raise_error;
end if;
--
close c152;

--
-- Testing for values in BEN_POPL_YR_PERD
--
open c153(p_bg_id);
--
fetch c153 into l_temp;
if c153%found then
  close c153;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_POPL_YR_PERD');
  fnd_message.raise_error;
end if;
--
close c153;

--
-- Testing for values in BEN_PRTN_ELIG_F
--
open c154(p_bg_id);
--
fetch c154 into l_temp;
if c154%found then
  close c154;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTN_ELIG_F');
  fnd_message.raise_error;
end if;
--
close c154;

--
-- Testing for values in BEN_VALD_RLSHP_FOR_REIMB_F
--
open c155(p_bg_id);
--
fetch c155 into l_temp;
if c155%found then
  close c155;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_VALD_RLSHP_FOR_REIMB_F');
  fnd_message.raise_error;
end if;
--
close c155;

--
-- Testing for values in BEN_VRBL_RT_PRFL_F
--
open c156(p_bg_id);
--
fetch c156 into l_temp;
if c156%found then
  close c156;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_VRBL_RT_PRFL_F');
  fnd_message.raise_error;
end if;
--
close c156;

--
-- Testing for values in BEN_BNFT_RSTRN_CTFN_F
--
open c157(p_bg_id);
--
fetch c157 into l_temp;
if c157%found then
  close c157;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BNFT_RSTRN_CTFN_F');
  fnd_message.raise_error;
end if;
--
close c157;

--
-- Testing for values in BEN_BRGNG_UNIT_RT_F
--
open c158(p_bg_id);
--
fetch c158 into l_temp;
if c158%found then
  close c158;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BRGNG_UNIT_RT_F');
  fnd_message.raise_error;
end if;
--
close c158;

--
-- Testing for values in BEN_CMBN_AGE_LOS_RT_F
--
open c159(p_bg_id);
--
fetch c159 into l_temp;
if c159%found then
  close c159;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CMBN_AGE_LOS_RT_F');
  fnd_message.raise_error;
end if;
--
close c159;

--
-- Testing for values in BEN_COMP_LVL_RT_F
--
open c160(p_bg_id);
--
fetch c160 into l_temp;
if c160%found then
  close c160;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_COMP_LVL_RT_F');
  fnd_message.raise_error;
end if;
--
close c160;

--
-- Testing for values in BEN_DSGN_RQMT_RLSHP_TYP
--
open c161(p_bg_id);
--
fetch c161 into l_temp;
if c161%found then
  close c161;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_DSGN_RQMT_RLSHP_TYP');
  fnd_message.raise_error;
end if;
--
close c161;

--
-- Testing for values in BEN_ENRT_PERD_FOR_PL_F
--
open c162(p_bg_id);
--
fetch c162 into l_temp;
if c162%found then
  close c162;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ENRT_PERD_FOR_PL_F');
  fnd_message.raise_error;
end if;
--
close c162;

--
-- Testing for values in BEN_LGL_ENTY_RT_F
--
open c163(p_bg_id);
--
fetch c163 into l_temp;
if c163%found then
  close c163;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LGL_ENTY_RT_F');
  fnd_message.raise_error;
end if;
--
close c163;

--
-- Testing for values in BEN_LOS_RT_F
--
open c164(p_bg_id);
--
fetch c164 into l_temp;
if c164%found then
  close c164;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LOS_RT_F');
  fnd_message.raise_error;
end if;
--
close c164;

--
-- Testing for values in BEN_ORG_UNIT_RT_F
--
open c165(p_bg_id);
--
fetch c165 into l_temp;
if c165%found then
  close c165;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ORG_UNIT_RT_F');
  fnd_message.raise_error;
end if;
--
close c165;

--
-- Testing for values in BEN_PCT_FL_TM_RT_F
--
open c166(p_bg_id);
--
fetch c166 into l_temp;
if c166%found then
  close c166;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PCT_FL_TM_RT_F');
  fnd_message.raise_error;
end if;
--
close c166;

--
-- Testing for values in BEN_PER_TYP_RT_F
--
open c167(p_bg_id);
--
fetch c167 into l_temp;
if c167%found then
  close c167;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PER_TYP_RT_F');
  fnd_message.raise_error;
end if;
--
close c167;

--
-- Testing for values in BEN_PPL_GRP_RT_F
--
open c168(p_bg_id);
--
fetch c168 into l_temp;
if c168%found then
  close c168;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PPL_GRP_RT_F');
  fnd_message.raise_error;
end if;
--
close c168;

--
-- Testing for values in BEN_PSTL_ZIP_RT_F
--
open c169(p_bg_id);
--
fetch c169 into l_temp;
if c169%found then
  close c169;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PSTL_ZIP_RT_F');
  fnd_message.raise_error;
end if;
--
close c169;

--
-- Testing for values in BEN_PYRL_RT_F
--
open c170(p_bg_id);
--
fetch c170 into l_temp;
if c170%found then
  close c170;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PYRL_RT_F');
  fnd_message.raise_error;
end if;
--
close c170;

--
-- Testing for values in BEN_SCHEDD_HRS_RT_F
--
open c171(p_bg_id);
--
fetch c171 into l_temp;
if c171%found then
  close c171;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_SCHEDD_HRS_RT_F');
  fnd_message.raise_error;
end if;
--
close c171;

--
-- Testing for values in BEN_SVC_AREA_RT_F
--
open c172(p_bg_id);
--
fetch c172 into l_temp;
if c172%found then
  close c172;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_SVC_AREA_RT_F');
  fnd_message.raise_error;
end if;
--
close c172;

--
-- Testing for values in BEN_TBCO_USE_RT_F
--
open c173(p_bg_id);
--
fetch c173 into l_temp;
if c173%found then
  close c173;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_TBCO_USE_RT_F');
  fnd_message.raise_error;
end if;
--
close c173;

--
-- Testing for values in BEN_TTL_CVG_VOL_RT_F
--
open c174(p_bg_id);
--
fetch c174 into l_temp;
if c174%found then
  close c174;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_TTL_CVG_VOL_RT_F');
  fnd_message.raise_error;
end if;
--
close c174;

--
-- Testing for values in BEN_TTL_PRTT_RT_F
--
open c175(p_bg_id);
--
fetch c175 into l_temp;
if c175%found then
  close c175;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_TTL_PRTT_RT_F');
  fnd_message.raise_error;
end if;
--
close c175;

--
-- Testing for values in BEN_VRBL_MTCHG_RT_F
--
open c176(p_bg_id);
--
fetch c176 into l_temp;
if c176%found then
  close c176;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_VRBL_MTCHG_RT_F');
  fnd_message.raise_error;
end if;
--
close c176;

--
-- Testing for values in BEN_VRBL_RT_PRFL_RL_F
--
open c177(p_bg_id);
--
fetch c177 into l_temp;
if c177%found then
  close c177;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_VRBL_RT_PRFL_RL_F');
  fnd_message.raise_error;
end if;
--
close c177;

--
-- Testing for values in BEN_WK_LOC_RT_F
--
open c178(p_bg_id);
--
fetch c178 into l_temp;
if c178%found then
  close c178;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_WK_LOC_RT_F');
  fnd_message.raise_error;
end if;
--
close c178;

--
-- Testing for values in BEN_ACTL_PREM_F
--
open c179(p_bg_id);
--
fetch c179 into l_temp;
if c179%found then
  close c179;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ACTL_PREM_F');
  fnd_message.raise_error;
end if;
--
close c179;

--
-- Testing for values in BEN_CRT_ORDR_CVRD_PER
--
open c180(p_bg_id);
--
fetch c180 into l_temp;
if c180%found then
  close c180;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CRT_ORDR_CVRD_PER');
  fnd_message.raise_error;
end if;
--
close c180;

--
-- Testing for values in BEN_FL_TM_PT_TM_RT_F
--
open c181(p_bg_id);
--
fetch c181 into l_temp;
if c181%found then
  close c181;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_FL_TM_PT_TM_RT_F');
  fnd_message.raise_error;
end if;
--
close c181;

--
-- Testing for values in BEN_GNDR_RT_F
--
open c182(p_bg_id);
--
fetch c182 into l_temp;
if c182%found then
  close c182;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_GNDR_RT_F');
  fnd_message.raise_error;
end if;
--
close c182;

--
-- Testing for values in BEN_GRADE_RT_F
--
open c183(p_bg_id);
--
fetch c183 into l_temp;
if c183%found then
  close c183;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_GRADE_RT_F');
  fnd_message.raise_error;
end if;
--
close c183;

--
-- Testing for values in BEN_HRLY_SLRD_RT_F
--
open c184(p_bg_id);
--
fetch c184 into l_temp;
if c184%found then
  close c184;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_HRLY_SLRD_RT_F');
  fnd_message.raise_error;
end if;
--
close c184;

--
-- Testing for values in BEN_HRS_WKD_IN_PERD_RT_F
--
open c185(p_bg_id);
--
fetch c185 into l_temp;
if c185%found then
  close c185;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_HRS_WKD_IN_PERD_RT_F');
  fnd_message.raise_error;
end if;
--
close c185;

--
-- Testing for values in BEN_LBR_MMBR_RT_F
--
open c186(p_bg_id);
--
fetch c186 into l_temp;
if c186%found then
  close c186;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LBR_MMBR_RT_F');
  fnd_message.raise_error;
end if;
--
close c186;

--
-- Testing for values in BEN_LER_BNFT_RSTRN_F
--
open c187(p_bg_id);
--
fetch c187 into l_temp;
if c187%found then
  close c187;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_BNFT_RSTRN_F');
  fnd_message.raise_error;
end if;
--
close c187;

--
-- Testing for values in BEN_LER_RQRS_ENRT_CTFN_F
--
open c188(p_bg_id);
--
fetch c188 into l_temp;
if c188%found then
  close c188;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_RQRS_ENRT_CTFN_F');
  fnd_message.raise_error;
end if;
--
close c188;

--
-- Testing for values in BEN_LER_BNFT_RSTRN_CTFN_F
--
open c189(p_bg_id);
--
fetch c189 into l_temp;
if c189%found then
  close c189;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_BNFT_RSTRN_CTFN_F');
  fnd_message.raise_error;
end if;
--
close c189;

--
-- Testing for values in BEN_APLD_DPNT_CVG_ELIG_PRFL_F
--
open c190(p_bg_id);
--
fetch c190 into l_temp;
if c190%found then
  close c190;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_APLD_DPNT_CVG_ELIG_PRFL_F');
  fnd_message.raise_error;
end if;
--
close c190;

--
-- Testing for values in BEN_CVG_AMT_CALC_MTHD_F
--
open c191(p_bg_id);
--
fetch c191 into l_temp;
if c191%found then
  close c191;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CVG_AMT_CALC_MTHD_F');
  fnd_message.raise_error;
end if;
--
close c191;

--
-- Testing for values in BEN_DPNT_CVRD_ANTHR_OIPL_CVG_F
--
open c192(p_bg_id);
--
fetch c192 into l_temp;
if c192%found then
  close c192;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_DPNT_CVRD_ANTHR_OIPL_CVG_F');
  fnd_message.raise_error;
end if;
--
close c192;

--
-- Testing for values in BEN_ELIG_DPNT_CVRD_OTHR_OIPL_F
--
open c193(p_bg_id);
--
fetch c193 into l_temp;
if c193%found then
  close c193;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_DPNT_CVRD_OTHR_OIPL_F');
  fnd_message.raise_error;
end if;
--
close c193;

--
-- Testing for values in BEN_ELIG_PER_F
--
open c194(p_bg_id);
--
fetch c194 into l_temp;
if c194%found then
  close c194;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_PER_F');
  fnd_message.raise_error;
end if;
--
close c194;

--
-- Testing for values in BEN_ENRT_ENRLD_ANTHR_OIPL_F
--
open c195(p_bg_id);
--
fetch c195 into l_temp;
if c195%found then
  close c195;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ENRT_ENRLD_ANTHR_OIPL_F');
  fnd_message.raise_error;
end if;
--
close c195;

--
-- Testing for values in BEN_LER_CHG_DPNT_CVG_F
--
open c196(p_bg_id);
--
fetch c196 into l_temp;
if c196%found then
  close c196;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_CHG_DPNT_CVG_F');
  fnd_message.raise_error;
end if;
--
close c196;

--
-- Testing for values in BEN_LER_CHG_OIPL_ENRT_F
--
open c197(p_bg_id);
--
fetch c197 into l_temp;
if c197%found then
  close c197;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_CHG_OIPL_ENRT_F');
  fnd_message.raise_error;
end if;
--
close c197;

--
-- Testing for values in BEN_LER_CHG_PL_NIP_ENRT_F
--
open c198(p_bg_id);
--
fetch c198 into l_temp;
if c198%found then
  close c198;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_CHG_PL_NIP_ENRT_F');
  fnd_message.raise_error;
end if;
--
close c198;

--
-- Testing for values in BEN_PIL_ELCTBL_CHC_POPL
--
open c199(p_bg_id);
--
fetch c199 into l_temp;
if c199%found then
  close c199;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PIL_ELCTBL_CHC_POPL');
  fnd_message.raise_error;
end if;
--
close c199;

--
-- Testing for values in BEN_AGE_RT_F
--
open c200(p_bg_id);
--
fetch c200 into l_temp;
if c200%found then
  close c200;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_AGE_RT_F');
  fnd_message.raise_error;
end if;
--
close c200;

--
-- Testing for values in BEN_ASNT_SET_RT_F
--
open c201(p_bg_id);
--
fetch c201 into l_temp;
if c201%found then
  close c201;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ASNT_SET_RT_F');
  fnd_message.raise_error;
end if;
--
close c201;

--
-- Testing for values in BEN_BENFTS_GRP_RT_F
--
open c202(p_bg_id);
--
fetch c202 into l_temp;
if c202%found then
  close c202;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BENFTS_GRP_RT_F');
  fnd_message.raise_error;
end if;
--
close c202;

--
-- Testing for values in BEN_PRTT_ENRT_RSLT_F
--
open c203(p_bg_id);
--
fetch c203 into l_temp;
if c203%found then
  close c203;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTT_ENRT_RSLT_F');
  fnd_message.raise_error;
end if;
--
close c203;

--
-- Testing for values in BEN_BNFT_VRBL_RT_F
--
open c204(p_bg_id);
--
fetch c204 into l_temp;
if c204%found then
  close c204;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BNFT_VRBL_RT_F');
  fnd_message.raise_error;
end if;
--
close c204;

--
-- Testing for values in BEN_ELIG_CVRD_DPNT_F
--
open c205(p_bg_id);
--
fetch c205 into l_temp;
if c205%found then
  close c205;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_CVRD_DPNT_F');
  fnd_message.raise_error;
end if;
--
close c205;

--
-- Testing for values in BEN_ELIG_PER_ELCTBL_CHC
--
open c206(p_bg_id);
--
fetch c206 into l_temp;
if c206%found then
  close c206;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_PER_ELCTBL_CHC');
  fnd_message.raise_error;
end if;
--
close c206;

--
-- Testing for values in BEN_ENRT_BNFT
--
open c207(p_bg_id);
--
fetch c207 into l_temp;
if c207%found then
  close c207;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ENRT_BNFT');
  fnd_message.raise_error;
end if;
--
close c207;

--
-- Testing for values in BEN_PL_BNF_F
--
open c208(p_bg_id);
--
fetch c208 into l_temp;
if c208%found then
  close c208;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_BNF_F');
  fnd_message.raise_error;
end if;
--
close c208;

--
-- Testing for values in BEN_PL_R_OIPL_PREM_BY_MO_F
--
open c209(p_bg_id);
--
fetch c209 into l_temp;
if c209%found then
  close c209;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_R_OIPL_PREM_BY_MO_F');
  fnd_message.raise_error;
end if;
--
close c209;

--
-- Testing for values in BEN_PRTT_PREM_F
--
open c210(p_bg_id);
--
fetch c210 into l_temp;
if c210%found then
  close c210;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTT_PREM_F');
  fnd_message.raise_error;
end if;
--
close c210;

--
-- Testing for values in BEN_ENRT_PREM
--
open c211(p_bg_id);
--
fetch c211 into l_temp;
if c211%found then
  close c211;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ENRT_PREM');
  fnd_message.raise_error;
end if;
--
close c211;

--
-- Testing for values in BEN_PRTN_ELIGY_RL_F
--
open c212(p_bg_id);
--
fetch c212 into l_temp;
if c212%found then
  close c212;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTN_ELIGY_RL_F');
  fnd_message.raise_error;
end if;
--
close c212;

--
-- Testing for values in BEN_ELCTBL_CHC_CTFN
--
open c213(p_bg_id);
--
fetch c213 into l_temp;
if c213%found then
  close c213;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELCTBL_CHC_CTFN');
  fnd_message.raise_error;
end if;
--
close c213;

--
-- Testing for values in BEN_ACTL_PREM_VRBL_RT_RL_F
--
open c214(p_bg_id);
--
fetch c214 into l_temp;
if c214%found then
  close c214;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ACTL_PREM_VRBL_RT_RL_F');
  fnd_message.raise_error;
end if;
--
close c214;

--
-- Testing for values in BEN_BNFT_VRBL_RT_RL_F
--
open c215(p_bg_id);
--
fetch c215 into l_temp;
if c215%found then
  close c215;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BNFT_VRBL_RT_RL_F');
  fnd_message.raise_error;
end if;
--
close c215;

--
-- Testing for values in BEN_ELIG_PPL_GRP_PRTE_F
--
open c216(p_bg_id);
--
fetch c216 into l_temp;
if c216%found then
  close c216;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_PPL_GRP_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c216;

--
-- Testing for values in BEN_PRTN_ELIG_PRFL_F
--
open c217(p_bg_id);
--
fetch c217 into l_temp;
if c217%found then
  close c217;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTN_ELIG_PRFL_F');
  fnd_message.raise_error;
end if;
--
close c217;

--
-- Testing for values in BEN_WV_PRTN_RSN_CTFN_PL_F
--
open c218(p_bg_id);
--
fetch c218 into l_temp;
if c218%found then
  close c218;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_WV_PRTN_RSN_CTFN_PL_F');
  fnd_message.raise_error;
end if;
--
close c218;

--
-- Testing for values in BEN_ACTL_PREM_VRBL_RT_F
--
open c219(p_bg_id);
--
fetch c219 into l_temp;
if c219%found then
  close c219;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ACTL_PREM_VRBL_RT_F');
  fnd_message.raise_error;
end if;
--
close c219;

--
-- Testing for values in BEN_ELIG_PER_OPT_F
--
open c220(p_bg_id);
--
fetch c220 into l_temp;
if c220%found then
  close c220;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_PER_OPT_F');
  fnd_message.raise_error;
end if;
--
close c220;

--
-- Testing for values in BEN_ELIG_PER_WV_PL_TYP_F
--
open c221(p_bg_id);
--
fetch c221 into l_temp;
if c221%found then
  close c221;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_PER_WV_PL_TYP_F');
  fnd_message.raise_error;
end if;
--
close c221;

--
-- Testing for values in BEN_PL_GD_R_SVC_CTFN_F
--
open c222(p_bg_id);
--
fetch c222 into l_temp;
if c222%found then
  close c222;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_GD_R_SVC_CTFN_F');
  fnd_message.raise_error;
end if;
--
close c222;

--
-- Testing for values in BEN_PRMRY_CARE_PRVDR_F
--
open c223(p_bg_id);
--
fetch c223 into l_temp;
if c223%found then
  close c223;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRMRY_CARE_PRVDR_F');
  fnd_message.raise_error;
end if;
--
close c223;

--
-- Testing for values in BEN_PRTT_ENRT_ACTN_F
--
open c224(p_bg_id);
--
fetch c224 into l_temp;
if c224%found then
  close c224;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTT_ENRT_ACTN_F');
  fnd_message.raise_error;
end if;
--
close c224;

--
-- Testing for values in BEN_PRTT_ENRT_CTFN_PRVDD_F
--
open c225(p_bg_id);
--
fetch c225 into l_temp;
if c225%found then
  close c225;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTT_ENRT_CTFN_PRVDD_F');
  fnd_message.raise_error;
end if;
--
close c225;

--
-- Testing for values in BEN_ELIG_DPNT
--
open c226(p_bg_id);
--
fetch c226 into l_temp;
if c226%found then
  close c226;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_DPNT');
  fnd_message.raise_error;
end if;
--
close c226;

--
-- Testing for values in BEN_LEE_RSN_RL_F
--
open c227(p_bg_id);
--
fetch c227 into l_temp;
if c227%found then
  close c227;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LEE_RSN_RL_F');
  fnd_message.raise_error;
end if;
--
close c227;

--
-- Testing for values in BEN_PL_REGY_PRP_F
--
open c228(p_bg_id);
--
fetch c228 into l_temp;
if c228%found then
  close c228;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_REGY_PRP_F');
  fnd_message.raise_error;
end if;
--
close c228;

--
-- Testing for values in BEN_SCHEDD_ENRT_RL_F
--
open c229(p_bg_id);
--
fetch c229 into l_temp;
if c229%found then
  close c229;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_SCHEDD_ENRT_RL_F');
  fnd_message.raise_error;
end if;
--
close c229;

--
-- Testing for values in BEN_ELIG_OTHR_PTIP_PRTE_F
--
open c230(p_bg_id);
--
fetch c230 into l_temp;
if c230%found then
  close c230;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_OTHR_PTIP_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c230;

--
-- Testing for values in BEN_LER_CHG_PTIP_ENRT_F
--
open c231(p_bg_id);
--
fetch c231 into l_temp;
if c231%found then
  close c231;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_CHG_PTIP_ENRT_F');
  fnd_message.raise_error;
end if;
--
close c231;

--
-- Testing for values in BEN_LER_CHG_DPNT_CVG_CTFN_F
--
open c232(p_bg_id);
--
fetch c232 into l_temp;
if c232%found then
  close c232;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_CHG_DPNT_CVG_CTFN_F');
  fnd_message.raise_error;
end if;
--
close c232;

--
-- Testing for values in BEN_LER_CHG_OIPL_ENRT_RL_F
--
open c233(p_bg_id);
--
fetch c233 into l_temp;
if c233%found then
  close c233;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_CHG_OIPL_ENRT_RL_F');
  fnd_message.raise_error;
end if;
--
close c233;

--
-- Testing for values in BEN_LER_CHG_PLIP_ENRT_F
--
open c234(p_bg_id);
--
fetch c234 into l_temp;
if c234%found then
  close c234;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_CHG_PLIP_ENRT_F');
  fnd_message.raise_error;
end if;
--
close c234;

--
-- Testing for values in BEN_LER_ENRT_CTFN_F
--
open c235(p_bg_id);
--
fetch c235 into l_temp;
if c235%found then
  close c235;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_ENRT_CTFN_F');
  fnd_message.raise_error;
end if;
--
close c235;

--
-- Testing for values in BEN_LER_CHG_PLIP_ENRT_RL_F
--
open c236(p_bg_id);
--
fetch c236 into l_temp;
if c236%found then
  close c236;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_CHG_PLIP_ENRT_RL_F');
  fnd_message.raise_error;
end if;
--
close c236;

--
-- Testing for values in BEN_LER_CHG_PL_NIP_RL_F
--
open c237(p_bg_id);
--
fetch c237 into l_temp;
if c237%found then
  close c237;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LER_CHG_PL_NIP_RL_F');
  fnd_message.raise_error;
end if;
--
close c237;

--
-- Testing for values in BEN_PER_CM_F
--
open c238(p_bg_id);
--
fetch c238 into l_temp;
if c238%found then
  close c238;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PER_CM_F');
  fnd_message.raise_error;
end if;
--
close c238;

--
-- Testing for values in BEN_PER_CM_TRGR_F
--
open c239(p_bg_id);
--
fetch c239 into l_temp;
if c239%found then
  close c239;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PER_CM_TRGR_F');
  fnd_message.raise_error;
end if;
--
close c239;

--
-- Testing for values in BEN_PL_BNF_CTFN_PRVDD_F
--
open c240(p_bg_id);
--
fetch c240 into l_temp;
if c240%found then
  close c240;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_BNF_CTFN_PRVDD_F');
  fnd_message.raise_error;
end if;
--
close c240;

--
-- Testing for values in BEN_PTIP_DPNT_CVG_CTFN_F
--
open c241(p_bg_id);
--
fetch c241 into l_temp;
if c241%found then
  close c241;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PTIP_DPNT_CVG_CTFN_F');
  fnd_message.raise_error;
end if;
--
close c241;

--
-- Testing for values in BEN_WV_PRTN_RSN_PTIP_F
--
open c242(p_bg_id);
--
fetch c242 into l_temp;
if c242%found then
  close c242;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_WV_PRTN_RSN_PTIP_F');
  fnd_message.raise_error;
end if;
--
close c242;

--
-- Testing for values in BEN_CVRD_DPNT_CTFN_PRVDD_F
--
open c243(p_bg_id);
--
fetch c243 into l_temp;
if c243%found then
  close c243;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CVRD_DPNT_CTFN_PRVDD_F');
  fnd_message.raise_error;
end if;
--
close c243;

--
-- Testing for values in BEN_PER_CM_USG_F
--
open c244(p_bg_id);
--
fetch c244 into l_temp;
if c244%found then
  close c244;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PER_CM_USG_F');
  fnd_message.raise_error;
end if;
--
close c244;

--
-- Testing for values in BEN_POPL_ORG_ROLE_F
--
open c245(p_bg_id);
--
fetch c245 into l_temp;
if c245%found then
  close c245;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_POPL_ORG_ROLE_F');
  fnd_message.raise_error;
end if;
--
close c245;

--
-- Testing for values in BEN_ELIG_JOB_PRTE_F
--
open c246(p_bg_id);
--
fetch c246 into l_temp;
if c246%found then
  close c246;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_JOB_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c246;

--
-- Testing for values in BEN_WV_PRTN_RSN_CTFN_PTIP_F
--
open c247(p_bg_id);
--
fetch c247 into l_temp;
if c247%found then
  close c247;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_WV_PRTN_RSN_CTFN_PTIP_F');
  fnd_message.raise_error;
end if;
--
close c247;

--
-- Testing for values in BEN_BATCH_COMMU_INFO
--
open c248(p_bg_id);
--
fetch c248 into l_temp;
if c248%found then
  close c248;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BATCH_COMMU_INFO');
  fnd_message.raise_error;
end if;
--
close c248;

--
-- Testing for values in BEN_BATCH_DPNT_INFO
--
open c249(p_bg_id);
--
fetch c249 into l_temp;
if c249%found then
  close c249;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BATCH_DPNT_INFO');
  fnd_message.raise_error;
end if;
--
close c249;

--
-- Testing for values in BEN_BATCH_ELCTBL_CHC_INFO
--
open c250(p_bg_id);
--
fetch c250 into l_temp;
if c250%found then
  close c250;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BATCH_ELCTBL_CHC_INFO');
  fnd_message.raise_error;
end if;
--
close c250;

--
-- Testing for values in BEN_BATCH_ELIG_INFO
--
open c251(p_bg_id);
--
fetch c251 into l_temp;
if c251%found then
  close c251;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BATCH_ELIG_INFO');
  fnd_message.raise_error;
end if;
--
close c251;

--
-- Testing for values in BEN_BATCH_LER_INFO
--
open c252(p_bg_id);
--
fetch c252 into l_temp;
if c252%found then
  close c252;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BATCH_LER_INFO');
  fnd_message.raise_error;
end if;
--
close c252;

--
-- Testing for values in BEN_BATCH_RATE_INFO
--
open c253(p_bg_id);
--
fetch c253 into l_temp;
if c253%found then
  close c253;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BATCH_RATE_INFO');
  fnd_message.raise_error;
end if;
--
close c253;

--
-- Testing for values in BEN_BENEFIT_ACTIONS
--
open c254(p_bg_id);
--
fetch c254 into l_temp;
if c254%found then
  close c254;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BENEFIT_ACTIONS');
  fnd_message.raise_error;
end if;
--
close c254;

--
-- Testing for values in BEN_CLPSE_LF_EVT_F
--
open c255(p_bg_id);
--
fetch c255 into l_temp;
if c255%found then
  close c255;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_CLPSE_LF_EVT_F');
  fnd_message.raise_error;
end if;
--
close c255;

--
-- Testing for values in BEN_PREM_CSTG_BY_SGMT_F
--
open c256(p_bg_id);
--
fetch c256 into l_temp;
if c256%found then
  close c256;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PREM_CSTG_BY_SGMT_F');
  fnd_message.raise_error;
end if;
--
close c256;

--
-- Testing for values in BEN_BATCH_PROC_INFO
--
open c257(p_bg_id);
--
fetch c257 into l_temp;
if c257%found then
  close c257;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BATCH_PROC_INFO');
  fnd_message.raise_error;
end if;
--
close c257;

--
-- Testing for values in BEN_PRTT_PREM_BY_MO_F
--
open c258(p_bg_id);
--
fetch c258 into l_temp;
if c258%found then
  close c258;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTT_PREM_BY_MO_F');
  fnd_message.raise_error;
end if;
--
close c258;

--
-- Testing for values in BEN_PER_CM_PRVDD_F
--
open c259(p_bg_id);
--
fetch c259 into l_temp;
if c259%found then
  close c259;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PER_CM_PRVDD_F');
  fnd_message.raise_error;
end if;
--
close c259;

--
-- Testing for values in BEN_PRTT_REIMBMT_RQST_F
--
open c260(p_bg_id);
--
fetch c260 into l_temp;
if c260%found then
  close c260;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTT_REIMBMT_RQST_F');
  fnd_message.raise_error;
end if;
--
close c260;

--
-- Testing for values in BEN_PRTT_CLM_GD_OR_SVC_TYP
--
open c261(p_bg_id);
--
fetch c261 into l_temp;
if c261%found then
  close c261;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTT_CLM_GD_OR_SVC_TYP');
  fnd_message.raise_error;
end if;
--
close c261;

--
-- Testing for values in BEN_ROLL_REIMB_RQST
--
open c262(p_bg_id);
--
fetch c262 into l_temp;
if c262%found then
  close c262;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ROLL_REIMB_RQST');
  fnd_message.raise_error;
end if;
--
close c262;

--
-- Testing for values in BEN_ELIG_EE_STAT_PRTE_F
--
open c263(p_bg_id);
--
fetch c263 into l_temp;
if c263%found then
  close c263;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_EE_STAT_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c263;

--
-- Testing for values in BEN_EE_STAT_RT_F
--
open c264(p_bg_id);
--
fetch c264 into l_temp;
if c264%found then
  close c264;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_EE_STAT_RT_F');
  fnd_message.raise_error;
end if;
--
close c264;

--
-- Testing for values in BEN_ELIG_ASNT_SET_PRTE_F
--
open c265(p_bg_id);
--
fetch c265 into l_temp;
if c265%found then
  close c265;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_ASNT_SET_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c265;

--
-- Testing for values in BEN_ACTY_BASE_RT_F
--
open c266(p_bg_id);
--
fetch c266 into l_temp;
if c266%found then
  close c266;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ACTY_BASE_RT_F');
  fnd_message.raise_error;
end if;
--
close c266;

--
-- Testing for values in BEN_ACTY_RT_PTD_LMT_F
--
open c267(p_bg_id);
--
fetch c267 into l_temp;
if c267%found then
  close c267;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ACTY_RT_PTD_LMT_F');
  fnd_message.raise_error;
end if;
--
close c267;

--
-- Testing for values in BEN_ACTY_RT_PYMT_SCHED_F
--
open c268(p_bg_id);
--
fetch c268 into l_temp;
if c268%found then
  close c268;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ACTY_RT_PYMT_SCHED_F');
  fnd_message.raise_error;
end if;
--
close c268;

--
-- Testing for values in BEN_ACTY_VRBL_RT_F
--
open c269(p_bg_id);
--
fetch c269 into l_temp;
if c269%found then
  close c269;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ACTY_VRBL_RT_F');
  fnd_message.raise_error;
end if;
--
close c269;

--
-- Testing for values in BEN_APLCN_TO_BNFT_POOL_F
--
open c270(p_bg_id);
--
fetch c270 into l_temp;
if c270%found then
  close c270;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_APLCN_TO_BNFT_POOL_F');
  fnd_message.raise_error;
end if;
--
close c270;

--
-- Testing for values in BEN_BNFT_POOL_RLOVR_RQMT_F
--
open c271(p_bg_id);
--
fetch c271 into l_temp;
if c271%found then
  close c271;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BNFT_POOL_RLOVR_RQMT_F');
  fnd_message.raise_error;
end if;
--
close c271;

--
-- Testing for values in BEN_BNFT_PRVDD_LDGR_F
--
open c272(p_bg_id);
--
fetch c272 into l_temp;
if c272%found then
  close c272;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_BNFT_PRVDD_LDGR_F');
  fnd_message.raise_error;
end if;
--
close c272;

--
-- Testing for values in BEN_COMP_LVL_ACTY_RT_F
--
open c273(p_bg_id);
--
fetch c273 into l_temp;
if c273%found then
  close c273;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_COMP_LVL_ACTY_RT_F');
  fnd_message.raise_error;
end if;
--
close c273;

--
-- Testing for values in BEN_MTCHG_RT_F
--
open c274(p_bg_id);
--
fetch c274 into l_temp;
if c274%found then
  close c274;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_MTCHG_RT_F');
  fnd_message.raise_error;
end if;
--
close c274;

--
-- Testing for values in BEN_PAIRD_RT_F
--
open c275(p_bg_id);
--
fetch c275 into l_temp;
if c275%found then
  close c275;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PAIRD_RT_F');
  fnd_message.raise_error;
end if;
--
close c275;

--
-- Testing for values in BEN_PRTL_MO_RT_PRTN_VAL_F
--
open c276(p_bg_id);
--
fetch c276 into l_temp;
if c276%found then
  close c276;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTL_MO_RT_PRTN_VAL_F');
  fnd_message.raise_error;
end if;
--
close c276;

--
-- Testing for values in BEN_VRBL_RT_RL_F
--
open c277(p_bg_id);
--
fetch c277 into l_temp;
if c277%found then
  close c277;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_VRBL_RT_RL_F');
  fnd_message.raise_error;
end if;
--
close c277;

--
-- Testing for values in BEN_DED_SCHED_PY_FREQ
--
open c278(p_bg_id);
--
fetch c278 into l_temp;
if c278%found then
  close c278;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_DED_SCHED_PY_FREQ');
  fnd_message.raise_error;
end if;
--
close c278;

--
-- Testing for values in BEN_ACTY_RT_DED_SCHED_F
--
open c279(p_bg_id);
--
fetch c279 into l_temp;
if c279%found then
  close c279;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ACTY_RT_DED_SCHED_F');
  fnd_message.raise_error;
end if;
--
close c279;

--
-- Testing for values in BEN_PERD_TO_PROC
--
open c280(p_bg_id);
--
fetch c280 into l_temp;
if c280%found then
  close c280;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PERD_TO_PROC');
  fnd_message.raise_error;
end if;
--
close c280;

--
-- Testing for values in BEN_PYMT_SCHED_PY_FREQ
--
open c281(p_bg_id);
--
fetch c281 into l_temp;
if c281%found then
  close c281;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PYMT_SCHED_PY_FREQ');
  fnd_message.raise_error;
end if;
--
close c281;

--
-- Testing for values in BEN_PRTT_ASSOCD_INSTN_F
--
open c282(p_bg_id);
--
fetch c282 into l_temp;
if c282%found then
  close c282;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTT_ASSOCD_INSTN_F');
  fnd_message.raise_error;
end if;
--
close c282;

--
-- Testing for values in BEN_PRTT_RT_VAL
--
open c283(p_bg_id);
--
fetch c283 into l_temp;
if c283%found then
  close c283;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTT_RT_VAL');
  fnd_message.raise_error;
end if;
--
close c283;

--
-- Testing for values in BEN_PRTT_VSTG_F
--
open c284(p_bg_id);
--
fetch c284 into l_temp;
if c284%found then
  close c284;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTT_VSTG_F');
  fnd_message.raise_error;
end if;
--
close c284;

--
-- Testing for values in BEN_ENRT_RT
--
open c285(p_bg_id);
--
fetch c285 into l_temp;
if c285%found then
  close c285;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ENRT_RT');
  fnd_message.raise_error;
end if;
--
close c285;

--
-- Testing for values in BEN_PRTT_REIMBMT_RECON
--
open c286(p_bg_id);
--
fetch c286 into l_temp;
if c286%found then
  close c286;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PRTT_REIMBMT_RECON');
  fnd_message.raise_error;
end if;
--
close c286;

--
-- Testing for values in BEN_ELIG_LOA_RSN_PRTE_F
--
open c287(p_bg_id);
--
fetch c287 into l_temp;
if c287%found then
  close c287;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_LOA_RSN_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c287;

--
-- Testing for values in BEN_LOA_RSN_RT_F
--
open c288(p_bg_id);
--
fetch c288 into l_temp;
if c288%found then
  close c288;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_LOA_RSN_RT_F');
  fnd_message.raise_error;
end if;
--
close c288;

--
-- Testing for values in BEN_ELIG_PY_BSS_PRTE_F
--
open c289(p_bg_id);
--
fetch c289 into l_temp;
if c289%found then
  close c289;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_PY_BSS_PRTE_F');
  fnd_message.raise_error;
end if;
--
close c289;

--
-- Testing for values in BEN_PY_BSS_RT_F
--
open c290(p_bg_id);
--
fetch c290 into l_temp;
if c290%found then
  close c290;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PY_BSS_RT_F');
  fnd_message.raise_error;
end if;
--
close c290;

--
-- Testing for values in BEN_ELIG_ENRLD_ANTHR_OIPL_F
--
open c291(p_bg_id);
--
fetch c291 into l_temp;
if c291%found then
  close c291;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_ELIG_ENRLD_ANTHR_OIPL_F');
  fnd_message.raise_error;
end if;
--
close c291;
--
-- Testing for values in BEN_PL_PCP
--
open c292(p_bg_id);
--
fetch c292 into l_temp;
if c292%found then
  close c292;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_PCP');
  fnd_message.raise_error;
end if;
--
close c292;
--
-- Testing for values in BEN_PL_PCP_TYP
--
open c293(p_bg_id);
--
fetch c293 into l_temp;
if c293%found then
  close c293;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_PL_PCP_TYP');
  fnd_message.raise_error;
end if;
--
close c293;

-- Testing for values in BEN_OPTIP_F
--
open c294(p_bg_id);
--
fetch c294 into l_temp;
if c294%found then
  close c294;
  fnd_message.set_name('BEN','HR_7215_DT_CHILD_EXISTS');
  fnd_message.set_token('TABLE_NAME','BEN_OPTIP_F');
  fnd_message.raise_error;
end if;
--
close c294;


end perform_ri_check;

procedure delete_below_bg(p_bg_id NUMBER) is
BEGIN
delete from BEN_CBR_QUALD_BNF
where business_group_id = p_bg_id;

--delete from BEN_HLTH_CVG_SLCTD_RT_F
--where business_group_id = p_bg_id;

delete from BEN_PER_INFO_CHG_CS_LER_F
where business_group_id = p_bg_id;

--delete from BEN_PRTN_IN_ANTHR_PL_RT_F
--where business_group_id = p_bg_id;

--delete from BEN_PRTT_PREM_BY_MO_CR_F
--where business_group_id = p_bg_id;

delete from BEN_RLTD_PER_CHG_CS_LER_F
where business_group_id = p_bg_id;

delete from BEN_PCT_FL_TM_FCTR
where business_group_id = p_bg_id;

delete from BEN_AGE_FCTR
where business_group_id = p_bg_id;

delete from BEN_BENFTS_GRP
where business_group_id = p_bg_id;

delete from BEN_GD_OR_SVC_TYP
where business_group_id = p_bg_id;

delete from BEN_LOS_FCTR
where business_group_id = p_bg_id;

delete from BEN_ELIGY_PRFL_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_LVG_RSN_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_NO_OTHR_CVG_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_OPTD_MDCR_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ACTN_TYP
where business_group_id = p_bg_id;

delete from BEN_BATCH_ACTN_ITEM_INFO
where business_group_id = p_bg_id;

delete from BEN_BATCH_PARAMETER
where business_group_id = p_bg_id;

delete from BEN_BNFTS_BAL_F
where business_group_id = p_bg_id;

delete from BEN_CM_TYP_F
where business_group_id = p_bg_id;

delete from BEN_CM_TYP_TRGR_F
where business_group_id = p_bg_id;

delete from BEN_CNTNG_PRTN_ELIG_PRFL_F
where business_group_id = p_bg_id;

delete from BEN_COMP_ASSET
where business_group_id = p_bg_id;

delete from BEN_CSR_ACTIVITIES
where business_group_id = p_bg_id;

delete from BEN_ELIG_BRGNG_UNIT_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_FL_TM_PT_TM_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_HRLY_SLRD_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_LBR_MMBR_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_PER_TYP_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_PYRL_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_SCHEDD_HRS_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_EXT_CHG_EVT_LOG
where business_group_id = p_bg_id;

delete from BEN_EXT_CRIT_PRFL
where business_group_id = p_bg_id;

delete from BEN_EXT_FILE
where business_group_id = p_bg_id;

delete from BEN_EXT_FLD
where business_group_id = p_bg_id;

delete from BEN_EXT_RCD
where business_group_id = p_bg_id;

delete from BEN_PIN
where business_group_id = p_bg_id;

delete from BEN_PL_TYP_F
where business_group_id = p_bg_id;

delete from BEN_POP_UP_MESSAGES
where business_group_id = p_bg_id;

delete from BEN_PSTL_ZIP_RNG_F
where business_group_id = p_bg_id;

delete from BEN_VSTG_SCHED_F
where business_group_id = p_bg_id;

delete from BEN_YR_PERD
where business_group_id = p_bg_id;

delete from BEN_CMBN_AGE_LOS_FCTR
where business_group_id = p_bg_id;

delete from BEN_CM_DLVRY_MTHD_TYP
where business_group_id = p_bg_id;

delete from BEN_CNTNU_PRTN_CTFN_TYP_F
where business_group_id = p_bg_id;

delete from BEN_ELIGY_PRFL_RL_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_AGE_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_BENFTS_GRP_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_LOS_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_PCT_FL_TM_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_PSTL_CD_R_RNG_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_WK_LOC_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_EXT_CRIT_TYP
where business_group_id = p_bg_id;

delete from BEN_EXT_DFN
where business_group_id = p_bg_id;

delete from BEN_ORG_UNIT_PRDCT_F
where business_group_id = p_bg_id;

delete from BEN_PER_BNFTS_BAL_F
where business_group_id = p_bg_id;

delete from BEN_PER_PIN_F
where business_group_id = p_bg_id;

delete from BEN_VSTG_AGE_RQMT
where business_group_id = p_bg_id;

delete from BEN_VSTG_FOR_ACTY_RT_F
where business_group_id = p_bg_id;

delete from BEN_WTHN_YR_PERD
where business_group_id = p_bg_id;

delete from BEN_CM_DLVRY_MED_TYP
where business_group_id = p_bg_id;

delete from BEN_ELIG_SVC_AREA_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_EXT_CRIT_VAL
where business_group_id = p_bg_id;

delete from BEN_EXT_DATA_ELMT
where business_group_id = p_bg_id;

delete from BEN_EXT_RSLT
where business_group_id = p_bg_id;

delete from BEN_SVC_AREA_F
where business_group_id = p_bg_id;

delete from BEN_VSTG_LOS_RQMT
where business_group_id = p_bg_id;

delete from BEN_ELIG_CMBN_AGE_LOS_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_EXT_CRIT_CMBN
where business_group_id = p_bg_id;

delete from BEN_EXT_DATA_ELMT_DECD
where business_group_id = p_bg_id;

delete from BEN_EXT_DATA_ELMT_IN_RCD
where business_group_id = p_bg_id;

delete from BEN_EXT_RSLT_DTL
where business_group_id = p_bg_id;

delete from BEN_SVC_AREA_PSTL_ZIP_RNG_F
where business_group_id = p_bg_id;

delete from BEN_COMP_LVL_FCTR
where business_group_id = p_bg_id;

delete from BEN_ELIG_LGL_ENTY_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_ORG_UNIT_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_EXT_RSLT_ERR
where business_group_id = p_bg_id;

delete from BEN_REGN_F
where business_group_id = p_bg_id;

delete from BEN_EXT_INCL_DATA_ELMT
where business_group_id = p_bg_id;

delete from BEN_EXT_RCD_IN_FILE
where business_group_id = p_bg_id;

delete from BEN_REGN_FOR_REGY_BODY_F
where business_group_id = p_bg_id;

delete from BEN_EXT_INCL_CHG
where business_group_id = p_bg_id;

delete from BEN_EXT_WHERE_CLAUSE
where business_group_id = p_bg_id;

delete from BEN_RPTG_GRP
where business_group_id = p_bg_id;

delete from BEN_DPNT_CVG_ELIGY_PRFL_F
where business_group_id = p_bg_id;

delete from BEN_HRS_WKD_IN_PERD_FCTR
where business_group_id = p_bg_id;

delete from BEN_DPNT_CVG_RQD_RLSHP_F
where business_group_id = p_bg_id;

delete from BEN_DSGNTR_ENRLD_CVG_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_COMP_LVL_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_DSBLD_STAT_CVG_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_HRS_WKD_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_MLTRY_STAT_CVG_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_MRTL_STAT_CVG_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_STDNT_STAT_CVG_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_AGE_CVG_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_PSTL_CD_R_RNG_CVG_F
where business_group_id = p_bg_id;

delete from BEN_PTD_LMT_F
where business_group_id = p_bg_id;

delete from BEN_PTD_BAL_TYP_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_GRD_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_PER_DLVRY_MTHD_F
where business_group_id = p_bg_id;

delete from BEN_PER_IN_LGL_ENTY_F
where business_group_id = p_bg_id;

delete from BEN_PER_IN_ORG_UNIT_F
where business_group_id = p_bg_id;

delete from BEN_PER_IN_ORG_ROLE_F
where business_group_id = p_bg_id;

delete from BEN_ACRS_PTIP_CVG_F
where business_group_id = p_bg_id;

delete from BEN_PL_TYP_OPT_TYP_F
where business_group_id = p_bg_id;

delete from BEN_ENRT_PERD
where business_group_id = p_bg_id;

delete from BEN_OPT_F
where business_group_id = p_bg_id;

delete from BEN_LER_F
where business_group_id = p_bg_id;

delete from BEN_LER_RLTD_PER_CS_LER_F
where business_group_id = p_bg_id;

delete from BEN_CBR_PER_IN_LER
where business_group_id = p_bg_id;

delete from BEN_CSS_RLTD_PER_PER_IN_LER_F
where business_group_id = p_bg_id;

delete from BEN_LER_PER_INFO_CS_LER_F
where business_group_id = p_bg_id;

delete from BEN_LE_CLSN_N_RSTR
where business_group_id = p_bg_id;

delete from BEN_PER_IN_LER
where business_group_id = p_bg_id;

delete from BEN_PTNL_LER_FOR_PER
where business_group_id = p_bg_id;

delete from BEN_PGM_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_ENRLD_ANTHR_PGM_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_PRTT_ANTHR_PGM_F
where business_group_id = p_bg_id;

delete from BEN_PLIP_F
where business_group_id = p_bg_id;

delete from BEN_PL_F
where business_group_id = p_bg_id;

delete from BEN_PTIP_F
where business_group_id = p_bg_id;

delete from BEN_DPNT_CVRD_ANTHR_PL_CVG_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_DPNT_CVRD_OTHR_PL_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_ENRLD_ANTHR_PL_F
where business_group_id = p_bg_id;

delete from BEN_ENRT_ENRLD_ANTHR_PL_F
where business_group_id = p_bg_id;

delete from BEN_OIPLIP_F
where business_group_id = p_bg_id;

delete from BEN_OIPL_F
where business_group_id = p_bg_id;

delete from BEN_PGM_DPNT_CVG_CTFN_F
where business_group_id = p_bg_id;

delete from BEN_BNFT_PRVDR_POOL_F
where business_group_id = p_bg_id;

delete from BEN_CMBN_PLIP_F
where business_group_id = p_bg_id;

delete from BEN_CMBN_PTIP_F
where business_group_id = p_bg_id;

delete from BEN_CMBN_PTIP_OPT_F
where business_group_id = p_bg_id;

delete from BEN_CM_TYP_USG_F
where business_group_id = p_bg_id;

delete from BEN_DSGN_RQMT_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_TO_PRTE_RSN_F
where business_group_id = p_bg_id;

delete from BEN_LER_CHG_PGM_ENRT_F
where business_group_id = p_bg_id;

delete from BEN_PL_BNF_CTFN_F
where business_group_id = p_bg_id;

delete from BEN_PL_DPNT_CVG_CTFN_F
where business_group_id = p_bg_id;

delete from BEN_PL_GD_OR_SVC_F
where business_group_id = p_bg_id;

delete from BEN_PL_REGN_F
where business_group_id = p_bg_id;

delete from BEN_PL_REGY_BOD_F
where business_group_id = p_bg_id;

delete from BEN_POPL_ACTN_TYP_F
where business_group_id = p_bg_id;

delete from BEN_POPL_ENRT_TYP_CYCL_F
where business_group_id = p_bg_id;

delete from BEN_POPL_ORG_F
where business_group_id = p_bg_id;

delete from BEN_WV_PRTN_RSN_PL_F
where business_group_id = p_bg_id;

delete from BEN_CRT_ORDR
where business_group_id = p_bg_id;

delete from BEN_ELIG_PRTT_ANTHR_PL_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ENRT_CTFN_F
where business_group_id = p_bg_id;

delete from BEN_LEE_RSN_F
where business_group_id = p_bg_id;

delete from BEN_PL_R_OIPL_ASSET_F
where business_group_id = p_bg_id;

delete from BEN_POPL_RPTG_GRP_F
where business_group_id = p_bg_id;

delete from BEN_POPL_YR_PERD
where business_group_id = p_bg_id;

delete from BEN_PRTN_ELIG_F
where business_group_id = p_bg_id;

delete from BEN_VALD_RLSHP_FOR_REIMB_F
where business_group_id = p_bg_id;

delete from BEN_VRBL_RT_PRFL_F
where business_group_id = p_bg_id;

delete from BEN_BNFT_RSTRN_CTFN_F
where business_group_id = p_bg_id;

delete from BEN_BRGNG_UNIT_RT_F
where business_group_id = p_bg_id;

delete from BEN_CMBN_AGE_LOS_RT_F
where business_group_id = p_bg_id;

delete from BEN_COMP_LVL_RT_F
where business_group_id = p_bg_id;

delete from BEN_DSGN_RQMT_RLSHP_TYP
where business_group_id = p_bg_id;

delete from BEN_ENRT_PERD_FOR_PL_F
where business_group_id = p_bg_id;

delete from BEN_LGL_ENTY_RT_F
where business_group_id = p_bg_id;

delete from BEN_LOS_RT_F
where business_group_id = p_bg_id;

delete from BEN_ORG_UNIT_RT_F
where business_group_id = p_bg_id;

delete from BEN_PCT_FL_TM_RT_F
where business_group_id = p_bg_id;

delete from BEN_PER_TYP_RT_F
where business_group_id = p_bg_id;

delete from BEN_PPL_GRP_RT_F
where business_group_id = p_bg_id;

delete from BEN_PSTL_ZIP_RT_F
where business_group_id = p_bg_id;

delete from BEN_PYRL_RT_F
where business_group_id = p_bg_id;

delete from BEN_SCHEDD_HRS_RT_F
where business_group_id = p_bg_id;

delete from BEN_SVC_AREA_RT_F
where business_group_id = p_bg_id;

delete from BEN_TBCO_USE_RT_F
where business_group_id = p_bg_id;

delete from BEN_TTL_CVG_VOL_RT_F
where business_group_id = p_bg_id;

delete from BEN_TTL_PRTT_RT_F
where business_group_id = p_bg_id;

delete from BEN_VRBL_MTCHG_RT_F
where business_group_id = p_bg_id;

delete from BEN_VRBL_RT_PRFL_RL_F
where business_group_id = p_bg_id;

delete from BEN_WK_LOC_RT_F
where business_group_id = p_bg_id;

delete from BEN_ACTL_PREM_F
where business_group_id = p_bg_id;

delete from BEN_CRT_ORDR_CVRD_PER
where business_group_id = p_bg_id;

delete from BEN_FL_TM_PT_TM_RT_F
where business_group_id = p_bg_id;

delete from BEN_GNDR_RT_F
where business_group_id = p_bg_id;

delete from BEN_GRADE_RT_F
where business_group_id = p_bg_id;

delete from BEN_HRLY_SLRD_RT_F
where business_group_id = p_bg_id;

delete from BEN_HRS_WKD_IN_PERD_RT_F
where business_group_id = p_bg_id;

delete from BEN_LBR_MMBR_RT_F
where business_group_id = p_bg_id;

delete from BEN_LER_BNFT_RSTRN_F
where business_group_id = p_bg_id;

delete from BEN_LER_RQRS_ENRT_CTFN_F
where business_group_id = p_bg_id;

delete from BEN_LER_BNFT_RSTRN_CTFN_F
where business_group_id = p_bg_id;

delete from BEN_APLD_DPNT_CVG_ELIG_PRFL_F
where business_group_id = p_bg_id;

delete from BEN_CVG_AMT_CALC_MTHD_F
where business_group_id = p_bg_id;

delete from BEN_DPNT_CVRD_ANTHR_OIPL_CVG_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_DPNT_CVRD_OTHR_OIPL_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_PER_F
where business_group_id = p_bg_id;

delete from BEN_ENRT_ENRLD_ANTHR_OIPL_F
where business_group_id = p_bg_id;

delete from BEN_LER_CHG_DPNT_CVG_F
where business_group_id = p_bg_id;

delete from BEN_LER_CHG_OIPL_ENRT_F
where business_group_id = p_bg_id;

delete from BEN_LER_CHG_PL_NIP_ENRT_F
where business_group_id = p_bg_id;

delete from BEN_PIL_ELCTBL_CHC_POPL
where business_group_id = p_bg_id;

delete from BEN_AGE_RT_F
where business_group_id = p_bg_id;

delete from BEN_ASNT_SET_RT_F
where business_group_id = p_bg_id;

delete from BEN_BENFTS_GRP_RT_F
where business_group_id = p_bg_id;

delete from BEN_PRTT_ENRT_RSLT_F
where business_group_id = p_bg_id;

delete from BEN_BNFT_VRBL_RT_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_CVRD_DPNT_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_PER_ELCTBL_CHC
where business_group_id = p_bg_id;

delete from BEN_ENRT_BNFT
where business_group_id = p_bg_id;

delete from BEN_PL_BNF_F
where business_group_id = p_bg_id;

delete from BEN_PL_R_OIPL_PREM_BY_MO_F
where business_group_id = p_bg_id;

delete from BEN_PRTT_PREM_F
where business_group_id = p_bg_id;

delete from BEN_ENRT_PREM
where business_group_id = p_bg_id;

delete from BEN_PRTN_ELIGY_RL_F
where business_group_id = p_bg_id;

delete from BEN_ELCTBL_CHC_CTFN
where business_group_id = p_bg_id;

delete from BEN_ACTL_PREM_VRBL_RT_RL_F
where business_group_id = p_bg_id;

delete from BEN_BNFT_VRBL_RT_RL_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_PPL_GRP_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_PRTN_ELIG_PRFL_F
where business_group_id = p_bg_id;

delete from BEN_WV_PRTN_RSN_CTFN_PL_F
where business_group_id = p_bg_id;

delete from BEN_ACTL_PREM_VRBL_RT_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_PER_OPT_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_PER_WV_PL_TYP_F
where business_group_id = p_bg_id;

delete from BEN_PL_GD_R_SVC_CTFN_F
where business_group_id = p_bg_id;

delete from BEN_PRMRY_CARE_PRVDR_F
where business_group_id = p_bg_id;

delete from BEN_PRTT_ENRT_ACTN_F
where business_group_id = p_bg_id;

delete from BEN_PRTT_ENRT_CTFN_PRVDD_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_DPNT
where business_group_id = p_bg_id;

delete from BEN_LEE_RSN_RL_F
where business_group_id = p_bg_id;

delete from BEN_PL_REGY_PRP_F
where business_group_id = p_bg_id;

delete from BEN_SCHEDD_ENRT_RL_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_OTHR_PTIP_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_LER_CHG_PTIP_ENRT_F
where business_group_id = p_bg_id;

delete from BEN_LER_CHG_DPNT_CVG_CTFN_F
where business_group_id = p_bg_id;

delete from BEN_LER_CHG_OIPL_ENRT_RL_F
where business_group_id = p_bg_id;

delete from BEN_LER_CHG_PLIP_ENRT_F
where business_group_id = p_bg_id;

delete from BEN_LER_ENRT_CTFN_F
where business_group_id = p_bg_id;

delete from BEN_LER_CHG_PLIP_ENRT_RL_F
where business_group_id = p_bg_id;

delete from BEN_LER_CHG_PL_NIP_RL_F
where business_group_id = p_bg_id;

delete from BEN_PER_CM_F
where business_group_id = p_bg_id;

delete from BEN_PER_CM_TRGR_F
where business_group_id = p_bg_id;

delete from BEN_PL_BNF_CTFN_PRVDD_F
where business_group_id = p_bg_id;

delete from BEN_PTIP_DPNT_CVG_CTFN_F
where business_group_id = p_bg_id;

delete from BEN_WV_PRTN_RSN_PTIP_F
where business_group_id = p_bg_id;

delete from BEN_CVRD_DPNT_CTFN_PRVDD_F
where business_group_id = p_bg_id;

delete from BEN_PER_CM_USG_F
where business_group_id = p_bg_id;

delete from BEN_POPL_ORG_ROLE_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_JOB_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_WV_PRTN_RSN_CTFN_PTIP_F
where business_group_id = p_bg_id;

delete from BEN_BATCH_COMMU_INFO
where business_group_id = p_bg_id;

delete from BEN_BATCH_DPNT_INFO
where business_group_id = p_bg_id;

delete from BEN_BATCH_ELCTBL_CHC_INFO
where business_group_id = p_bg_id;

delete from BEN_BATCH_ELIG_INFO
where business_group_id = p_bg_id;

delete from BEN_BATCH_LER_INFO
where business_group_id = p_bg_id;

delete from BEN_BATCH_RATE_INFO
where business_group_id = p_bg_id;

delete from BEN_BENEFIT_ACTIONS
where business_group_id = p_bg_id;

delete from BEN_CLPSE_LF_EVT_F
where business_group_id = p_bg_id;

delete from BEN_PREM_CSTG_BY_SGMT_F
where business_group_id = p_bg_id;

delete from BEN_BATCH_PROC_INFO
where business_group_id = p_bg_id;

delete from BEN_PRTT_PREM_BY_MO_F
where business_group_id = p_bg_id;

delete from BEN_PER_CM_PRVDD_F
where business_group_id = p_bg_id;

delete from BEN_PRTT_REIMBMT_RQST_F
where business_group_id = p_bg_id;

delete from BEN_PRTT_CLM_GD_OR_SVC_TYP
where business_group_id = p_bg_id;

delete from BEN_ROLL_REIMB_RQST
where business_group_id = p_bg_id;

delete from BEN_ELIG_EE_STAT_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_EE_STAT_RT_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_ASNT_SET_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_ACTY_BASE_RT_F
where business_group_id = p_bg_id;

delete from BEN_ACTY_RT_PTD_LMT_F
where business_group_id = p_bg_id;

delete from BEN_ACTY_RT_PYMT_SCHED_F
where business_group_id = p_bg_id;

delete from BEN_ACTY_VRBL_RT_F
where business_group_id = p_bg_id;

delete from BEN_APLCN_TO_BNFT_POOL_F
where business_group_id = p_bg_id;

delete from BEN_BNFT_POOL_RLOVR_RQMT_F
where business_group_id = p_bg_id;

delete from BEN_BNFT_PRVDD_LDGR_F
where business_group_id = p_bg_id;

delete from BEN_COMP_LVL_ACTY_RT_F
where business_group_id = p_bg_id;

delete from BEN_MTCHG_RT_F
where business_group_id = p_bg_id;

delete from BEN_PAIRD_RT_F
where business_group_id = p_bg_id;

delete from BEN_PRTL_MO_RT_PRTN_VAL_F
where business_group_id = p_bg_id;

delete from BEN_VRBL_RT_RL_F
where business_group_id = p_bg_id;

delete from BEN_DED_SCHED_PY_FREQ
where business_group_id = p_bg_id;

delete from BEN_ACTY_RT_DED_SCHED_F
where business_group_id = p_bg_id;

delete from BEN_PERD_TO_PROC
where business_group_id = p_bg_id;

delete from BEN_PYMT_SCHED_PY_FREQ
where business_group_id = p_bg_id;

delete from BEN_PRTT_ASSOCD_INSTN_F
where business_group_id = p_bg_id;

delete from BEN_PRTT_RT_VAL
where business_group_id = p_bg_id;

delete from BEN_PRTT_VSTG_F
where business_group_id = p_bg_id;

delete from BEN_ENRT_RT
where business_group_id = p_bg_id;

delete from BEN_PRTT_REIMBMT_RECON
where business_group_id = p_bg_id;

delete from BEN_ELIG_LOA_RSN_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_LOA_RSN_RT_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_PY_BSS_PRTE_F
where business_group_id = p_bg_id;

delete from BEN_PY_BSS_RT_F
where business_group_id = p_bg_id;

delete from BEN_ELIG_ENRLD_ANTHR_OIPL_F
where business_group_id = p_bg_id;

delete from BEN_PL_PCP
where business_group_id = p_bg_id;

delete from BEN_PL_PCP_TYP
where business_group_id = p_bg_id;

delete from BEN_OPTIP_F
where business_group_id = p_bg_id;

end delete_below_bg;
procedure delete_below_org(p_org_id NUMBER) is
BEGIN
delete from BEN_ORG_UNIT_PRDCT_F
where organization_id = p_org_id;

delete from BEN_ELIG_LGL_ENTY_PRTE_F
where organization_id = p_org_id;

delete from BEN_ELIG_ORG_UNIT_PRTE_F
where organization_id = p_org_id;

delete from BEN_REGN_F
where organization_id = p_org_id;

delete from BEN_REGN_FOR_REGY_BODY_F
where organization_id = p_org_id;

delete from BEN_PER_IN_LGL_ENTY_F
where organization_id = p_org_id;

delete from BEN_PER_IN_ORG_UNIT_F
where organization_id = p_org_id;

delete from BEN_LE_CLSN_N_RSTR
where organization_id = p_org_id;

delete from BEN_PL_REGY_BOD_F
where organization_id = p_org_id;

delete from BEN_POPL_ORG_F
where organization_id = p_org_id;

delete from BEN_LGL_ENTY_RT_F
where organization_id = p_org_id;

delete from BEN_ORG_UNIT_RT_F
where organization_id = p_org_id;

delete from BEN_ACTL_PREM_F
where organization_id = p_org_id;

delete from BEN_PL_BNF_F
where organization_id = p_org_id;

delete from BEN_BENEFIT_ACTIONS
where organization_id = p_org_id;

end delete_below_org;
end ben_org_delete;

/
