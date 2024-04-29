--------------------------------------------------------
--  DDL for Package HRDPP_UPDATE_CA_EMP_PRVTAX_INF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_UPDATE_CA_EMP_PRVTAX_INF" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:15
 * Generated for API: PAY_CA_EMP_PRVTAX_INF_API.UPDATE_CA_EMP_PRVTAX_INF
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
,P_LEGISLATION_CODE in varchar2 default null
,P_ASSIGNMENT_ID in number default null
,I_ASSIGNMENT_ID in varchar2 default 'N'
,P_PROVINCE_CODE in varchar2 default null
,P_JURISDICTION_CODE in varchar2 default null
,P_TAX_CREDIT_AMOUNT in number default null
,I_TAX_CREDIT_AMOUNT in varchar2 default 'N'
,P_BASIC_EXEMPTION_FLAG in varchar2 default null
,P_DEDUCTION_CODE in varchar2 default null
,P_EXTRA_INFO_NOT_PROVIDED in varchar2 default null
,P_MARRIAGE_STATUS in varchar2 default null
,P_NO_OF_INFIRM_DEPENDANTS in number default null
,I_NO_OF_INFIRM_DEPENDANTS in varchar2 default 'N'
,P_NON_RESIDENT_STATUS in varchar2 default null
,P_DISABILITY_STATUS in varchar2 default null
,P_NO_OF_DEPENDANTS in number default null
,I_NO_OF_DEPENDANTS in varchar2 default 'N'
,P_ANNUAL_DEDN in number default null
,I_ANNUAL_DEDN in varchar2 default 'N'
,P_TOTAL_EXPENSE_BY_COMMISSION in number default null
,I_TOTAL_EXPENSE_BY_COMMISSION in varchar2 default 'N'
,P_TOTAL_REMNRTN_BY_COMMISSION in number default null
,I_TOTAL_REMNRTN_BY_COMMISSION in varchar2 default 'N'
,P_PRESCRIBED_ZONE_DEDN_AMT in number default null
,I_PRESCRIBED_ZONE_DEDN_AMT in varchar2 default 'N'
,P_ADDITIONAL_TAX in number default null
,I_ADDITIONAL_TAX in varchar2 default 'N'
,P_PROV_OVERRIDE_RATE in number default null
,I_PROV_OVERRIDE_RATE in varchar2 default 'N'
,P_PROV_OVERRIDE_AMOUNT in number default null
,I_PROV_OVERRIDE_AMOUNT in varchar2 default 'N'
,P_PROV_EXEMPT_FLAG in varchar2 default null
,P_PMED_EXEMPT_FLAG in varchar2 default null
,P_WC_EXEMPT_FLAG in varchar2 default null
,P_QPP_EXEMPT_FLAG in varchar2 default null
,P_TAX_CALC_METHOD in varchar2 default null
,P_OTHER_TAX_CREDIT in number default null
,I_OTHER_TAX_CREDIT in varchar2 default 'N'
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
,P_PROV_LSP_AMOUNT in number default null
,I_PROV_LSP_AMOUNT in varchar2 default 'N'
,P_EFFECTIVE_DATE in date
,P_DATETRACK_MODE in varchar2
,P_PPIP_EXEMPT_FLAG in varchar2 default null
,P_EMP_PROV_TAX_INF_USER_KEY in varchar2);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_UPDATE_CA_EMP_PRVTAX_INF;
 

/