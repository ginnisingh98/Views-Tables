--------------------------------------------------------
--  DDL for Package HRDPP_CREATE_PROCESSED_ASSIGNM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_CREATE_PROCESSED_ASSIGNM" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:20
 * Generated for API: PER_BF_PROC_ASSIGNMENT_API.CREATE_PROCESSED_ASSIGNMENT
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
,P_EFFECTIVE_DATE in date
,P_BPA_ATTRIBUTE_CATEGORY in varchar2 default null
,P_BPA_ATTRIBUTE1 in varchar2 default null
,P_BPA_ATTRIBUTE2 in varchar2 default null
,P_BPA_ATTRIBUTE3 in varchar2 default null
,P_BPA_ATTRIBUTE4 in varchar2 default null
,P_BPA_ATTRIBUTE5 in varchar2 default null
,P_BPA_ATTRIBUTE6 in varchar2 default null
,P_BPA_ATTRIBUTE7 in varchar2 default null
,P_BPA_ATTRIBUTE8 in varchar2 default null
,P_BPA_ATTRIBUTE9 in varchar2 default null
,P_BPA_ATTRIBUTE10 in varchar2 default null
,P_BPA_ATTRIBUTE11 in varchar2 default null
,P_BPA_ATTRIBUTE12 in varchar2 default null
,P_BPA_ATTRIBUTE13 in varchar2 default null
,P_BPA_ATTRIBUTE14 in varchar2 default null
,P_BPA_ATTRIBUTE15 in varchar2 default null
,P_BPA_ATTRIBUTE16 in varchar2 default null
,P_BPA_ATTRIBUTE17 in varchar2 default null
,P_BPA_ATTRIBUTE18 in varchar2 default null
,P_BPA_ATTRIBUTE19 in varchar2 default null
,P_BPA_ATTRIBUTE20 in varchar2 default null
,P_BPA_ATTRIBUTE21 in varchar2 default null
,P_BPA_ATTRIBUTE22 in varchar2 default null
,P_BPA_ATTRIBUTE23 in varchar2 default null
,P_BPA_ATTRIBUTE24 in varchar2 default null
,P_BPA_ATTRIBUTE25 in varchar2 default null
,P_BPA_ATTRIBUTE26 in varchar2 default null
,P_BPA_ATTRIBUTE27 in varchar2 default null
,P_BPA_ATTRIBUTE28 in varchar2 default null
,P_BPA_ATTRIBUTE29 in varchar2 default null
,P_BPA_ATTRIBUTE30 in varchar2 default null
,P_EMPLOYEE_NUMBER in varchar2
,P_PAYROLL_RUN_USER_KEY in varchar2);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_CREATE_PROCESSED_ASSIGNM;
 

/