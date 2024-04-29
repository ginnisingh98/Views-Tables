--------------------------------------------------------
--  DDL for Package HRDPP_UPDATE_ELIG_CVRD_DPNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_UPDATE_ELIG_CVRD_DPNT" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 13:01:27
 * Generated for API: ben_elig_cvrd_dpnt_api.UPDATE_ELIG_CVRD_DPNT
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
,P_CVG_STRT_DT in date default null
,I_CVG_STRT_DT in varchar2 default 'N'
,P_CVG_THRU_DT in date default null
,I_CVG_THRU_DT in varchar2 default 'N'
,P_CVG_PNDG_FLAG in varchar2 default null
,P_PDP_ATTRIBUTE_CATEGORY in varchar2 default null
,P_PDP_ATTRIBUTE1 in varchar2 default null
,P_PDP_ATTRIBUTE2 in varchar2 default null
,P_PDP_ATTRIBUTE3 in varchar2 default null
,P_PDP_ATTRIBUTE4 in varchar2 default null
,P_PDP_ATTRIBUTE5 in varchar2 default null
,P_PDP_ATTRIBUTE6 in varchar2 default null
,P_PDP_ATTRIBUTE7 in varchar2 default null
,P_PDP_ATTRIBUTE8 in varchar2 default null
,P_PDP_ATTRIBUTE9 in varchar2 default null
,P_PDP_ATTRIBUTE10 in varchar2 default null
,P_PDP_ATTRIBUTE11 in varchar2 default null
,P_PDP_ATTRIBUTE12 in varchar2 default null
,P_PDP_ATTRIBUTE13 in varchar2 default null
,P_PDP_ATTRIBUTE14 in varchar2 default null
,P_PDP_ATTRIBUTE15 in varchar2 default null
,P_PDP_ATTRIBUTE16 in varchar2 default null
,P_PDP_ATTRIBUTE17 in varchar2 default null
,P_PDP_ATTRIBUTE18 in varchar2 default null
,P_PDP_ATTRIBUTE19 in varchar2 default null
,P_PDP_ATTRIBUTE20 in varchar2 default null
,P_PDP_ATTRIBUTE21 in varchar2 default null
,P_PDP_ATTRIBUTE22 in varchar2 default null
,P_PDP_ATTRIBUTE23 in varchar2 default null
,P_PDP_ATTRIBUTE24 in varchar2 default null
,P_PDP_ATTRIBUTE25 in varchar2 default null
,P_PDP_ATTRIBUTE26 in varchar2 default null
,P_PDP_ATTRIBUTE27 in varchar2 default null
,P_PDP_ATTRIBUTE28 in varchar2 default null
,P_PDP_ATTRIBUTE29 in varchar2 default null
,P_PDP_ATTRIBUTE30 in varchar2 default null
,P_PROGRAM_UPDATE_DATE in date default null
,I_PROGRAM_UPDATE_DATE in varchar2 default 'N'
,P_OVRDN_FLAG in varchar2 default null
,P_OVRDN_THRU_DT in date default null
,I_OVRDN_THRU_DT in varchar2 default 'N'
,P_EFFECTIVE_DATE in date
,P_DATETRACK_MODE in varchar2
,P_MULTI_ROW_ACTN in boolean default null
,P_ELIG_CVRD_DPNT_USER_KEY in varchar2
,P_PRTT_ENRT_RSLT_USER_KEY in varchar2 default null
,P_DPNT_PERSON_USER_KEY in varchar2 default null
,P_PER_IN_LER_USER_KEY in varchar2 default null);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_UPDATE_ELIG_CVRD_DPNT;
 

/
