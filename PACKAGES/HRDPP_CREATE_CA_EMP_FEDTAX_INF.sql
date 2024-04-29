--------------------------------------------------------
--  DDL for Package HRDPP_CREATE_CA_EMP_FEDTAX_INF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_CREATE_CA_EMP_FEDTAX_INF" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:13
 * Generated for API: PAY_CA_EMP_FEDTAX_INF_API.CREATE_CA_EMP_FEDTAX_INF
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
,P_EMP_FED_TAX_INF_USER_KEY in varchar2
,P_LEGISLATION_CODE in varchar2 default null
,P_ASSIGNMENT_ID in number default null
,P_EMPLOYMENT_PROVINCE in varchar2 default null
,P_TAX_CREDIT_AMOUNT in number default null
,P_CLAIM_CODE in varchar2 default null
,P_BASIC_EXEMPTION_FLAG in varchar2 default null
,P_ADDITIONAL_TAX in number default null
,P_ANNUAL_DEDN in number default null
,P_TOTAL_EXPENSE_BY_COMMISSION in number default null
,P_TOTAL_REMNRTN_BY_COMMISSION in number default null
,P_PRESCRIBED_ZONE_DEDN_AMT in number default null
,P_OTHER_FEDTAX_CREDITS in varchar2 default null
,P_CPP_QPP_EXEMPT_FLAG in varchar2 default null
,P_FED_EXEMPT_FLAG in varchar2 default null
,P_EI_EXEMPT_FLAG in varchar2 default null
,P_TAX_CALC_METHOD in varchar2 default null
,P_FED_OVERRIDE_AMOUNT in number default null
,P_FED_OVERRIDE_RATE in number default null
,P_CA_TAX_INFORMATION_CATEGORY in varchar2 default null
,P_CA_TAX_INFORMATION1 in varchar2 default null
,P_CA_TAX_INFORMATION2 in varchar2 default null
,P_CA_TAX_INFORMATION3 in varchar2 default null
,P_CA_TAX_INFORMATION4 in varchar2 default null
,P_CA_TAX_INFORMATION5 in varchar2 default null
,P_CA_TAX_INFORMATION6 in varchar2 default null
,P_CA_TAX_INFORMATION7 in varchar2 default null
,P_CA_TAX_INFORMATION8 in varchar2 default null
,P_CA_TAX_INFORMATION9 in varchar2 default null
,P_CA_TAX_INFORMATION10 in varchar2 default null
,P_CA_TAX_INFORMATION11 in varchar2 default null
,P_CA_TAX_INFORMATION12 in varchar2 default null
,P_CA_TAX_INFORMATION13 in varchar2 default null
,P_CA_TAX_INFORMATION14 in varchar2 default null
,P_CA_TAX_INFORMATION15 in varchar2 default null
,P_CA_TAX_INFORMATION16 in varchar2 default null
,P_CA_TAX_INFORMATION17 in varchar2 default null
,P_CA_TAX_INFORMATION18 in varchar2 default null
,P_CA_TAX_INFORMATION19 in varchar2 default null
,P_CA_TAX_INFORMATION20 in varchar2 default null
,P_CA_TAX_INFORMATION21 in varchar2 default null
,P_CA_TAX_INFORMATION22 in varchar2 default null
,P_CA_TAX_INFORMATION23 in varchar2 default null
,P_CA_TAX_INFORMATION24 in varchar2 default null
,P_CA_TAX_INFORMATION25 in varchar2 default null
,P_CA_TAX_INFORMATION26 in varchar2 default null
,P_CA_TAX_INFORMATION27 in varchar2 default null
,P_CA_TAX_INFORMATION28 in varchar2 default null
,P_CA_TAX_INFORMATION29 in varchar2 default null
,P_CA_TAX_INFORMATION30 in varchar2 default null
,P_FED_LSF_AMOUNT in number default null
,P_EFFECTIVE_DATE in date);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_CREATE_CA_EMP_FEDTAX_INF;
 

/