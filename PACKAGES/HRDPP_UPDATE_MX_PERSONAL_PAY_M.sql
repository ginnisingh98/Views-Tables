--------------------------------------------------------
--  DDL for Package HRDPP_UPDATE_MX_PERSONAL_PAY_M
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_UPDATE_MX_PERSONAL_PAY_M" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:09
 * Generated for API: HR_MX_PERSONAL_PAY_METHOD_API.UPDATE_MX_PERSONAL_PAY_METHOD
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
,P_DATETRACK_UPDATE_MODE in varchar2
,P_AMOUNT in number default null
,I_AMOUNT in varchar2 default 'N'
,P_COMMENTS in varchar2 default null
,P_PERCENTAGE in number default null
,I_PERCENTAGE in varchar2 default 'N'
,P_PRIORITY in number default null
,I_PRIORITY in varchar2 default 'N'
,P_ATTRIBUTE_CATEGORY in varchar2 default null
,P_ATTRIBUTE1 in varchar2 default null
,P_ATTRIBUTE2 in varchar2 default null
,P_ATTRIBUTE3 in varchar2 default null
,P_ATTRIBUTE4 in varchar2 default null
,P_ATTRIBUTE5 in varchar2 default null
,P_ATTRIBUTE6 in varchar2 default null
,P_ATTRIBUTE7 in varchar2 default null
,P_ATTRIBUTE8 in varchar2 default null
,P_ATTRIBUTE9 in varchar2 default null
,P_ATTRIBUTE10 in varchar2 default null
,P_ATTRIBUTE11 in varchar2 default null
,P_ATTRIBUTE12 in varchar2 default null
,P_ATTRIBUTE13 in varchar2 default null
,P_ATTRIBUTE14 in varchar2 default null
,P_ATTRIBUTE15 in varchar2 default null
,P_ATTRIBUTE16 in varchar2 default null
,P_ATTRIBUTE17 in varchar2 default null
,P_ATTRIBUTE18 in varchar2 default null
,P_ATTRIBUTE19 in varchar2 default null
,P_ATTRIBUTE20 in varchar2 default null
,P_BANK in varchar2 default null
,P_BRANCH in varchar2 default null
,P_ACCOUNT in varchar2 default null
,P_ACCOUNT_TYPE in varchar2 default null
,P_CLABE in varchar2 default null
,P_CONCAT_SEGMENTS in varchar2 default null
,P_PAYEE_TYPE in varchar2 default null
,P_PERSONAL_PAY_METHOD_USER_KEY in varchar2
,P_PAYEE_ORG in varchar2 default null
,P_PAYEE_PERSON_USER_KEY in varchar2 default null
,P_LANGUAGE_CODE in varchar2 default null);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_UPDATE_MX_PERSONAL_PAY_M;
 

/
