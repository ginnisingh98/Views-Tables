--------------------------------------------------------
--  DDL for Package HRDPP_CREATE_SALARY_BASIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_CREATE_SALARY_BASIS" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:31
 * Generated for API: HR_SALARY_BASIS_API.CREATE_SALARY_BASIS
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
,P_NAME in varchar2
,P_PAY_BASIS in varchar2
,P_RATE_BASIS in varchar2
,P_PAY_ANNUALIZATION_FACTOR in number default null
,P_GRADE_ANNUALIZATION_FACTOR in number default null
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
,P_LAST_UPDATE_DATE in date default null
,P_LAST_UPDATED_BY in number default null
,P_LAST_UPDATE_LOGIN in number default null
,P_CREATED_BY in number default null
,P_CREATION_DATE in date default null
,P_INFORMATION_CATEGORY in varchar2 default null
,P_INFORMATION1 in varchar2 default null
,P_INFORMATION2 in varchar2 default null
,P_INFORMATION3 in varchar2 default null
,P_INFORMATION4 in varchar2 default null
,P_INFORMATION5 in varchar2 default null
,P_INFORMATION6 in varchar2 default null
,P_INFORMATION7 in varchar2 default null
,P_INFORMATION8 in varchar2 default null
,P_INFORMATION9 in varchar2 default null
,P_INFORMATION10 in varchar2 default null
,P_INFORMATION11 in varchar2 default null
,P_INFORMATION12 in varchar2 default null
,P_INFORMATION13 in varchar2 default null
,P_INFORMATION14 in varchar2 default null
,P_INFORMATION15 in varchar2 default null
,P_INFORMATION16 in varchar2 default null
,P_INFORMATION17 in varchar2 default null
,P_INFORMATION18 in varchar2 default null
,P_INFORMATION19 in varchar2 default null
,P_INFORMATION20 in varchar2 default null
,P_INPUT_VALUE_NAME in varchar2
,P_ELEMENT_NAME in varchar2
,P_EFFECTIVE_DATE in date
,P_LANGUAGE_CODE in varchar2
,P_RATE_NAME in varchar2 default null);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_CREATE_SALARY_BASIS;
 

/
