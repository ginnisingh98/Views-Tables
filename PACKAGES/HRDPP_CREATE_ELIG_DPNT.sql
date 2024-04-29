--------------------------------------------------------
--  DDL for Package HRDPP_CREATE_ELIG_DPNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_CREATE_ELIG_DPNT" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 13:01:40
 * Generated for API: ben_elig_dpnt_api.CREATE_ELIG_DPNT
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
,P_ELIG_DPNT_USER_KEY in varchar2
,P_CREATE_DT in date default null
,P_ELIG_STRT_DT in date default null
,P_ELIG_THRU_DT in date default null
,P_OVRDN_FLAG in varchar2 default null
,P_OVRDN_THRU_DT in date default null
,P_INELG_RSN_CD in varchar2 default null
,P_DPNT_INELIG_FLAG in varchar2 default null
,P_EGD_ATTRIBUTE_CATEGORY in varchar2 default null
,P_EGD_ATTRIBUTE1 in varchar2 default null
,P_EGD_ATTRIBUTE2 in varchar2 default null
,P_EGD_ATTRIBUTE3 in varchar2 default null
,P_EGD_ATTRIBUTE4 in varchar2 default null
,P_EGD_ATTRIBUTE5 in varchar2 default null
,P_EGD_ATTRIBUTE6 in varchar2 default null
,P_EGD_ATTRIBUTE7 in varchar2 default null
,P_EGD_ATTRIBUTE8 in varchar2 default null
,P_EGD_ATTRIBUTE9 in varchar2 default null
,P_EGD_ATTRIBUTE10 in varchar2 default null
,P_EGD_ATTRIBUTE11 in varchar2 default null
,P_EGD_ATTRIBUTE12 in varchar2 default null
,P_EGD_ATTRIBUTE13 in varchar2 default null
,P_EGD_ATTRIBUTE14 in varchar2 default null
,P_EGD_ATTRIBUTE15 in varchar2 default null
,P_EGD_ATTRIBUTE16 in varchar2 default null
,P_EGD_ATTRIBUTE17 in varchar2 default null
,P_EGD_ATTRIBUTE18 in varchar2 default null
,P_EGD_ATTRIBUTE19 in varchar2 default null
,P_EGD_ATTRIBUTE20 in varchar2 default null
,P_EGD_ATTRIBUTE21 in varchar2 default null
,P_EGD_ATTRIBUTE22 in varchar2 default null
,P_EGD_ATTRIBUTE23 in varchar2 default null
,P_EGD_ATTRIBUTE24 in varchar2 default null
,P_EGD_ATTRIBUTE25 in varchar2 default null
,P_EGD_ATTRIBUTE26 in varchar2 default null
,P_EGD_ATTRIBUTE27 in varchar2 default null
,P_EGD_ATTRIBUTE28 in varchar2 default null
,P_EGD_ATTRIBUTE29 in varchar2 default null
,P_EGD_ATTRIBUTE30 in varchar2 default null
,P_PROGRAM_UPDATE_DATE in date default null
,P_EFFECTIVE_DATE in date
,P_ELIG_PER_ELCTBL_CHC_USER_KEY in varchar2 default null
,P_PER_IN_LER_USER_KEY in varchar2 default null
,P_ELIG_PER_USER_KEY in varchar2 default null
,P_ELIG_PER_OPT_USER_KEY in varchar2 default null
,P_ELIG_CVRD_DPNT_USER_KEY in varchar2 default null
,P_DPNT_PERSON_USER_KEY in varchar2 default null);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_CREATE_ELIG_DPNT;
 

/