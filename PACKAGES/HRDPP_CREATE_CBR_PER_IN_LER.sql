--------------------------------------------------------
--  DDL for Package HRDPP_CREATE_CBR_PER_IN_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_CREATE_CBR_PER_IN_LER" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 13:01:20
 * Generated for API: ben_cbr_per_in_ler_api.CREATE_CBR_PER_IN_LER
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
,P_CBR_PER_IN_LER_USER_KEY in varchar2
,P_INIT_EVT_FLAG in varchar2 default null
,P_CNT_NUM in number default null
,P_PRVS_ELIG_PERD_END_DT in date default null
,P_CRP_ATTRIBUTE_CATEGORY in varchar2 default null
,P_CRP_ATTRIBUTE1 in varchar2 default null
,P_CRP_ATTRIBUTE2 in varchar2 default null
,P_CRP_ATTRIBUTE3 in varchar2 default null
,P_CRP_ATTRIBUTE4 in varchar2 default null
,P_CRP_ATTRIBUTE5 in varchar2 default null
,P_CRP_ATTRIBUTE6 in varchar2 default null
,P_CRP_ATTRIBUTE7 in varchar2 default null
,P_CRP_ATTRIBUTE8 in varchar2 default null
,P_CRP_ATTRIBUTE9 in varchar2 default null
,P_CRP_ATTRIBUTE10 in varchar2 default null
,P_CRP_ATTRIBUTE11 in varchar2 default null
,P_CRP_ATTRIBUTE12 in varchar2 default null
,P_CRP_ATTRIBUTE13 in varchar2 default null
,P_CRP_ATTRIBUTE14 in varchar2 default null
,P_CRP_ATTRIBUTE15 in varchar2 default null
,P_CRP_ATTRIBUTE16 in varchar2 default null
,P_CRP_ATTRIBUTE17 in varchar2 default null
,P_CRP_ATTRIBUTE18 in varchar2 default null
,P_CRP_ATTRIBUTE19 in varchar2 default null
,P_CRP_ATTRIBUTE20 in varchar2 default null
,P_CRP_ATTRIBUTE21 in varchar2 default null
,P_CRP_ATTRIBUTE22 in varchar2 default null
,P_CRP_ATTRIBUTE23 in varchar2 default null
,P_CRP_ATTRIBUTE24 in varchar2 default null
,P_CRP_ATTRIBUTE25 in varchar2 default null
,P_CRP_ATTRIBUTE26 in varchar2 default null
,P_CRP_ATTRIBUTE27 in varchar2 default null
,P_CRP_ATTRIBUTE28 in varchar2 default null
,P_CRP_ATTRIBUTE29 in varchar2 default null
,P_CRP_ATTRIBUTE30 in varchar2 default null
,P_EFFECTIVE_DATE in date
,P_PER_IN_LER_USER_KEY in varchar2 default null
,P_CBR_QUALD_BNF_USER_KEY in varchar2 default null);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_CREATE_CBR_PER_IN_LER;
 

/
