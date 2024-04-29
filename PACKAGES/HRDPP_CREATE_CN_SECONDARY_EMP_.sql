--------------------------------------------------------
--  DDL for Package HRDPP_CREATE_CN_SECONDARY_EMP_
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRDPP_CREATE_CN_SECONDARY_EMP_" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:56
 * Generated for API: HR_CN_ASSIGNMENT_API.CREATE_CN_SECONDARY_EMP_ASG
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
,P_ASSIGNMENT_NUMBER in varchar2
,P_CHANGE_REASON in varchar2 default null
,P_COMMENTS in varchar2 default null
,P_DATE_PROBATION_END in date default null
,P_EMPLOYMENT_CATEGORY in varchar2 default null
,P_FREQUENCY in varchar2 default null
,P_INTERNAL_ADDRESS_LINE in varchar2 default null
,P_MANAGER_FLAG in varchar2 default null
,P_NORMAL_HOURS in number default null
,P_PERF_REVIEW_PERIOD in number default null
,P_PERF_REVIEW_PERIOD_FREQUENCY in varchar2 default null
,P_PROBATION_PERIOD in number default null
,P_PROBATION_UNIT in varchar2 default null
,P_SAL_REVIEW_PERIOD in number default null
,P_SAL_REVIEW_PERIOD_FREQUENCY in varchar2 default null
,P_SOURCE_TYPE in varchar2 default null
,P_TIME_NORMAL_FINISH in varchar2 default null
,P_TIME_NORMAL_START in varchar2 default null
,P_BARGAINING_UNIT_CODE in varchar2 default null
,P_LABOUR_UNION_MEMBER_FLAG in varchar2 default null
,P_HOURLY_SALARIED_CODE in varchar2 default null
,P_ASS_ATTRIBUTE_CATEGORY in varchar2 default null
,P_ASS_ATTRIBUTE1 in varchar2 default null
,P_ASS_ATTRIBUTE2 in varchar2 default null
,P_ASS_ATTRIBUTE3 in varchar2 default null
,P_ASS_ATTRIBUTE4 in varchar2 default null
,P_ASS_ATTRIBUTE5 in varchar2 default null
,P_ASS_ATTRIBUTE6 in varchar2 default null
,P_ASS_ATTRIBUTE7 in varchar2 default null
,P_ASS_ATTRIBUTE8 in varchar2 default null
,P_ASS_ATTRIBUTE9 in varchar2 default null
,P_ASS_ATTRIBUTE10 in varchar2 default null
,P_ASS_ATTRIBUTE11 in varchar2 default null
,P_ASS_ATTRIBUTE12 in varchar2 default null
,P_ASS_ATTRIBUTE13 in varchar2 default null
,P_ASS_ATTRIBUTE14 in varchar2 default null
,P_ASS_ATTRIBUTE15 in varchar2 default null
,P_ASS_ATTRIBUTE16 in varchar2 default null
,P_ASS_ATTRIBUTE17 in varchar2 default null
,P_ASS_ATTRIBUTE18 in varchar2 default null
,P_ASS_ATTRIBUTE19 in varchar2 default null
,P_ASS_ATTRIBUTE20 in varchar2 default null
,P_ASS_ATTRIBUTE21 in varchar2 default null
,P_ASS_ATTRIBUTE22 in varchar2 default null
,P_ASS_ATTRIBUTE23 in varchar2 default null
,P_ASS_ATTRIBUTE24 in varchar2 default null
,P_ASS_ATTRIBUTE25 in varchar2 default null
,P_ASS_ATTRIBUTE26 in varchar2 default null
,P_ASS_ATTRIBUTE27 in varchar2 default null
,P_ASS_ATTRIBUTE28 in varchar2 default null
,P_ASS_ATTRIBUTE29 in varchar2 default null
,P_ASS_ATTRIBUTE30 in varchar2 default null
,P_TITLE in varchar2 default null
,P_TAX_AREA_CODE in varchar2
,P_SIC_AREA_CODE in varchar2
,P_SALARY_PAYOUT_LOCN in varchar2 default null
,P_SPECIAL_TAX_EXMP_CATEGORY in varchar2 default null
,P_SCL_CONCAT_SEGMENTS in varchar2 default null
,P_PGP_SEGMENT1 in varchar2 default null
,P_PGP_SEGMENT2 in varchar2 default null
,P_PGP_SEGMENT3 in varchar2 default null
,P_PGP_SEGMENT4 in varchar2 default null
,P_PGP_SEGMENT5 in varchar2 default null
,P_PGP_SEGMENT6 in varchar2 default null
,P_PGP_SEGMENT7 in varchar2 default null
,P_PGP_SEGMENT8 in varchar2 default null
,P_PGP_SEGMENT9 in varchar2 default null
,P_PGP_SEGMENT10 in varchar2 default null
,P_PGP_SEGMENT11 in varchar2 default null
,P_PGP_SEGMENT12 in varchar2 default null
,P_PGP_SEGMENT13 in varchar2 default null
,P_PGP_SEGMENT14 in varchar2 default null
,P_PGP_SEGMENT15 in varchar2 default null
,P_PGP_SEGMENT16 in varchar2 default null
,P_PGP_SEGMENT17 in varchar2 default null
,P_PGP_SEGMENT18 in varchar2 default null
,P_PGP_SEGMENT19 in varchar2 default null
,P_PGP_SEGMENT20 in varchar2 default null
,P_PGP_SEGMENT21 in varchar2 default null
,P_PGP_SEGMENT22 in varchar2 default null
,P_PGP_SEGMENT23 in varchar2 default null
,P_PGP_SEGMENT24 in varchar2 default null
,P_PGP_SEGMENT25 in varchar2 default null
,P_PGP_SEGMENT26 in varchar2 default null
,P_PGP_SEGMENT27 in varchar2 default null
,P_PGP_SEGMENT28 in varchar2 default null
,P_PGP_SEGMENT29 in varchar2 default null
,P_PGP_SEGMENT30 in varchar2 default null
,P_PGP_CONCAT_SEGMENTS in varchar2 default null
,P_CAG_SEGMENT1 in varchar2 default null
,P_CAG_SEGMENT2 in varchar2 default null
,P_CAG_SEGMENT3 in varchar2 default null
,P_CAG_SEGMENT4 in varchar2 default null
,P_CAG_SEGMENT5 in varchar2 default null
,P_CAG_SEGMENT6 in varchar2 default null
,P_CAG_SEGMENT7 in varchar2 default null
,P_CAG_SEGMENT8 in varchar2 default null
,P_CAG_SEGMENT9 in varchar2 default null
,P_CAG_SEGMENT10 in varchar2 default null
,P_CAG_SEGMENT11 in varchar2 default null
,P_CAG_SEGMENT12 in varchar2 default null
,P_CAG_SEGMENT13 in varchar2 default null
,P_CAG_SEGMENT14 in varchar2 default null
,P_CAG_SEGMENT15 in varchar2 default null
,P_CAG_SEGMENT16 in varchar2 default null
,P_CAG_SEGMENT17 in varchar2 default null
,P_CAG_SEGMENT18 in varchar2 default null
,P_CAG_SEGMENT19 in varchar2 default null
,P_CAG_SEGMENT20 in varchar2 default null
,P_NOTICE_PERIOD in number default null
,P_NOTICE_PERIOD_UOM in varchar2 default null
,P_EMPLOYEE_CATEGORY in varchar2 default null
,P_WORK_AT_HOME in varchar2 default null
,P_JOB_POST_SOURCE_NAME in varchar2 default null
,P_CAGR_GRADE_DEF_ID in number
,P_ASSIGNMENT_USER_KEY in varchar2
,P_SOFT_CODING_KEYFLEX_ID in number
,P_PEOPLE_GROUP_ID in number
,P_PERSON_USER_KEY in varchar2
,P_ORGANIZATION_NAME in varchar2
,P_LANGUAGE_CODE in varchar2
,P_GRADE_NAME in varchar2 default null
,P_POSITION_NAME in varchar2 default null
,P_JOB_NAME in varchar2 default null
,P_USER_STATUS in varchar2 default null
,P_PAYROLL_NAME in varchar2 default null
,P_LOCATION_CODE in varchar2 default null
,P_SUPERVISOR_USER_KEY in varchar2 default null
,P_SPECIAL_CEILIN_STEP_USER_KEY in varchar2 default null
,P_PAY_BASIS_NAME in varchar2 default null
,P_DEFAULT_CODE_COMB_USER_KEY in varchar2 default null
,P_SET_OF_BOOKS_NAME in varchar2 default null
,P_EMPLOYER_NAME in varchar2
,P_CONTRACT_USER_KEY in varchar2 default null
,P_ESTABLISHMENT_ORG_NAME in varchar2 default null
,P_CAGR_NAME in varchar2 default null
,P_CAGR_ID_FLEX_NUM_USER_KEY in varchar2 default null);
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number);
end hrdpp_CREATE_CN_SECONDARY_EMP_;
 

/
