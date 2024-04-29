--------------------------------------------------------
--  DDL for Package HRDPP_UPDATE_ELIGIBLE_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_UPDATE_ELIGIBLE_PERSON" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 13:01:12
 * Generated for API: ben_eligible_person_api.UPDATE_ELIGIBLE_PERSON
 */
--
g_generator_version constant varchar2(128) default '$Revision: 120.4  $';
--

function dc(p in date) return varchar2;
pragma restrict_references(dc,WNDS);

function d(p in varchar2) return date;
pragma restrict_references(d,WNDS);
function n(p in varchar2) return number;
pragma restrict_references(n,WNDS);
function dd(p in date,i in varchar2) return varchar2;
pragma restrict_references(dd,WNDS);
function nd(p in number,i in varchar2) return varchar2;
pragma restrict_references(nd,WNDS);
--
procedure insert_batch_lines
(p_batch_id      in number
,p_data_pump_batch_line_id in number default null
,p_data_pump_business_grp_name in varchar2 default null
,p_user_sequence in number default null
,p_link_value    in number default null
,P_PER_IN_LER_ID in varchar2 default null
,P_DPNT_OTHR_PL_CVRD_RL_FLAG in varchar2 default null
,P_PRTN_OVRIDN_THRU_DT in date default null
,I_PRTN_OVRIDN_THRU_DT in varchar2 default 'N'
,P_PL_KEY_EE_FLAG in varchar2 default null
,P_PL_HGHLY_COMPD_FLAG in varchar2 default null
,P_ELIG_FLAG in varchar2 default null
,P_COMP_REF_AMT in number default null
,I_COMP_REF_AMT in varchar2 default 'N'
,P_CMBN_AGE_N_LOS_VAL in number default null
,I_CMBN_AGE_N_LOS_VAL in varchar2 default 'N'
,P_AGE_VAL in number default null
,I_AGE_VAL in varchar2 default 'N'
,P_LOS_VAL in number default null
,I_LOS_VAL in varchar2 default 'N'
,P_PRTN_END_DT in date default null
,I_PRTN_END_DT in varchar2 default 'N'
,P_PRTN_STRT_DT in date default null
,I_PRTN_STRT_DT in varchar2 default 'N'
,P_WAIT_PERD_CMPLTN_DT in date default null
,I_WAIT_PERD_CMPLTN_DT in varchar2 default 'N'
,P_WAIT_PERD_STRT_DT in date default null
,I_WAIT_PERD_STRT_DT in varchar2 default 'N'
,P_WV_CTFN_TYP_CD in varchar2 default null
,P_HRS_WKD_VAL in number default null
,I_HRS_WKD_VAL in varchar2 default 'N'
,P_HRS_WKD_BNDRY_PERD_CD in varchar2 default null
,P_PRTN_OVRIDN_FLAG in varchar2 default null
,P_NO_MX_PRTN_OVRID_THRU_FLAG in varchar2 default null
,P_PRTN_OVRIDN_RSN_CD in varchar2 default null
,P_AGE_UOM in varchar2 default null
,P_LOS_UOM in varchar2 default null
,P_OVRID_SVC_DT in date default null
,I_OVRID_SVC_DT in varchar2 default 'N'
,P_INELG_RSN_CD in varchar2 default null
,P_FRZ_LOS_FLAG in varchar2 default null
,P_FRZ_AGE_FLAG in varchar2 default null
,P_FRZ_CMP_LVL_FLAG in varchar2 default null
,P_FRZ_PCT_FL_TM_FLAG in varchar2 default null
,P_FRZ_HRS_WKD_FLAG in varchar2 default null
,P_FRZ_COMB_AGE_AND_LOS_FLAG in varchar2 default null
,P_DSTR_RSTCN_FLAG in varchar2 default null
,P_PCT_FL_TM_VAL in number default null
,I_PCT_FL_TM_VAL in varchar2 default 'N'
,P_WV_PRTN_RSN_CD in varchar2 default null
,P_PL_WVD_FLAG in varchar2 default null
,P_RT_COMP_REF_AMT in number default null
,I_RT_COMP_REF_AMT in varchar2 default 'N'
,P_RT_CMBN_AGE_N_LOS_VAL in number default null
,I_RT_CMBN_AGE_N_LOS_VAL in varchar2 default 'N'
,P_RT_AGE_VAL in number default null
,I_RT_AGE_VAL in varchar2 default 'N'
,P_RT_LOS_VAL in number default null
,I_RT_LOS_VAL in varchar2 default 'N'
,P_RT_HRS_WKD_VAL in number default null
,I_RT_HRS_WKD_VAL in varchar2 default 'N'
,P_RT_HRS_WKD_BNDRY_PERD_CD in varchar2 default null
,P_RT_AGE_UOM in varchar2 default null
,P_RT_LOS_UOM in varchar2 default null
,P_RT_PCT_FL_TM_VAL in number default null
,I_RT_PCT_FL_TM_VAL in varchar2 default 'N'
,P_RT_FRZ_LOS_FLAG in varchar2 default null
,P_RT_FRZ_AGE_FLAG in varchar2 default null
,P_RT_FRZ_CMP_LVL_FLAG in varchar2 default null
,P_RT_FRZ_PCT_FL_TM_FLAG in varchar2 default null
,P_RT_FRZ_HRS_WKD_FLAG in varchar2 default null
,P_RT_FRZ_COMB_AGE_AND_LOS_FLAG in varchar2 default null
,P_ONCE_R_CNTUG_CD in varchar2 default null
,P_PL_ORDR_NUM in number default null
,I_PL_ORDR_NUM in varchar2 default 'N'
,P_PLIP_ORDR_NUM in number default null
,I_PLIP_ORDR_NUM in varchar2 default 'N'
,P_PTIP_ORDR_NUM in number default null
,I_PTIP_ORDR_NUM in varchar2 default 'N'
,P_PEP_ATTRIBUTE_CATEGORY in varchar2 default null
,P_PEP_ATTRIBUTE1 in varchar2 default null
,P_PEP_ATTRIBUTE2 in varchar2 default null
,P_PEP_ATTRIBUTE3 in varchar2 default null
,P_PEP_ATTRIBUTE4 in varchar2 default null
,P_PEP_ATTRIBUTE5 in varchar2 default null
,P_PEP_ATTRIBUTE6 in varchar2 default null
,P_PEP_ATTRIBUTE7 in varchar2 default null
,P_PEP_ATTRIBUTE8 in varchar2 default null
,P_PEP_ATTRIBUTE9 in varchar2 default null
,P_PEP_ATTRIBUTE10 in varchar2 default null
,P_PEP_ATTRIBUTE11 in varchar2 default null
,P_PEP_ATTRIBUTE12 in varchar2 default null
,P_PEP_ATTRIBUTE13 in varchar2 default null
,P_PEP_ATTRIBUTE14 in varchar2 default null
,P_PEP_ATTRIBUTE15 in varchar2 default null
,P_PEP_ATTRIBUTE16 in varchar2 default null
,P_PEP_ATTRIBUTE17 in varchar2 default null
,P_PEP_ATTRIBUTE18 in varchar2 default null
,P_PEP_ATTRIBUTE19 in varchar2 default null
,P_PEP_ATTRIBUTE20 in varchar2 default null
,P_PEP_ATTRIBUTE21 in varchar2 default null
,P_PEP_ATTRIBUTE22 in varchar2 default null
,P_PEP_ATTRIBUTE23 in varchar2 default null
,P_PEP_ATTRIBUTE24 in varchar2 default null
,P_PEP_ATTRIBUTE25 in varchar2 default null
,P_PEP_ATTRIBUTE26 in varchar2 default null
,P_PEP_ATTRIBUTE27 in varchar2 default null
,P_PEP_ATTRIBUTE28 in varchar2 default null
,P_PEP_ATTRIBUTE29 in varchar2 default null
,P_PEP_ATTRIBUTE30 in varchar2 default null
,P_PROGRAM_UPDATE_DATE in date default null
,I_PROGRAM_UPDATE_DATE in varchar2 default 'N'
,P_EFFECTIVE_DATE in date
,P_DATETRACK_MODE in varchar2
,P_ELIG_PER_USER_KEY in varchar2
,P_PLAN in varchar2 default null
,P_PROGRAM in varchar2 default null
,P_PLIP_USER_KEY in varchar2 default null
,P_PTIP_USER_KEY in varchar2 default null
,P_LIFE_EVENT_REASON in varchar2 default null
,P_PERSON_USER_KEY in varchar2 default null
,P_COMP_REF_UOM in varchar2 default null
,P_RT_COMP_REF_UOM in varchar2 default null);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_UPDATE_ELIGIBLE_PERSON;
 

/