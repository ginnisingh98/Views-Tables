--------------------------------------------------------
--  DDL for Package Body HRDPP_CREATE_RU_SECONDARY_EMP_
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_CREATE_RU_SECONDARY_EMP_" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:27
 * Generated for API: HR_RU_ASSIGNMENT_API.CREATE_RU_SECONDARY_EMP_ASG
 */
--
dh constant date := hr_api.g_date;
nh constant number := hr_api.g_number;
vh constant varchar2(64) := hr_api.g_varchar2;
c_sot constant date := to_date('01010001','DDMMYYYY');
cn constant varchar2(32) := '<NULL>';
dn constant date := null;
nn constant number := null;
vn constant varchar2(1) := null;
--
function dc(p in date) return varchar2 is
begin
if p<c_sot then
 if p<>trunc(p) then
  return to_char(p,'SYYYY/MM/DD HH24:MI:SS');
 end if;
 return to_char(p,'SYYYY/MM/DD');
elsif p<>trunc(p) then
 return to_char(p,'YYYY/MM/DD HH24:MI:SS');
end if;
return to_char(p,'YYYY/MM/DD');
end dc;
function d(p in varchar2) return date is
begin
if length(p)=10 then
return to_date(p,'YYYY/MM/DD');
elsif length(p)=19 then
return to_date(p,'YYYY/MM/DD HH24:MI:SS');
elsif length(p)=11 then
return to_date(p,'SYYYY/MM/DD');
elsif length(p)=20 then
return to_date(p,'SYYYY/MM/DD HH24:MI:SS');
end if;
-- Try default format as last resort.
return to_date(p,'YYYY/MM/DD');
end d;
function n(p in varchar2) return number is
begin
return to_number(p);
end n;
function dd(p in date,i in varchar2)
return varchar2 is
begin
if upper(i) = 'N' then return dc(p);
else return cn; end if;
end dd;
function nd(p in number,i in varchar2)
return varchar2 is
begin
if upper(i) = 'N' then return to_char(p);
else return cn; end if;
end nd;
--
procedure iuk
(p_batch_line_id  in number,
p_user_key_value in varchar2,
p_unique_key_id  in number)
is
begin
hr_data_pump.entry('ins_user_key');
insert into hr_pump_batch_line_user_keys
(user_key_id, batch_line_id,user_key_value,unique_key_id)
values
(hr_pump_batch_line_user_keys_s.nextval,
p_batch_line_id,
p_user_key_value,
p_unique_key_id);
hr_data_pump.exit('ins_user_key');
end iuk;
--
procedure insert_batch_lines
(p_batch_id      in number
,p_data_pump_batch_line_id in number default null
,p_data_pump_business_grp_name in varchar2 default null
,p_user_sequence in number default null
,p_link_value    in number default null
,P_EFFECTIVE_DATE in date
,P_ASSIGNMENT_NUMBER in varchar2
,P_START_REASON in varchar2 default null
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
,P_SEC_EMP in varchar2 default null
,P_CONTRACT_NUMBER in varchar2 default null
,P_ISSUE_DATE in date default null
,P_CONT_END_DATE in date default null
,P_LIMIT_REASON in varchar2 default null
,P_END_REASON in varchar2 default null
,P_TERRITORY_COND in varchar2 default null
,P_SPL_WORK_COND in varchar2 default null
,P_CSR in varchar2 default null
,P_CSR_ADD_INFO in varchar2 default null
,P_LSR in varchar2 default null
,P_LSR_ADD_INFO in varchar2 default null
,P_UNINT_SERVICE_REC in varchar2 default null
,P_TOTAL_SERVICE_REC in varchar2 default null
,P_PENSION_YEARS in varchar2 default null
,P_PENSION_MONTHS in varchar2 default null
,P_PENSION_DAYS in varchar2 default null
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
,P_EMPLOYER_NAME in varchar2 default null
,P_CONTRACT_USER_KEY in varchar2 default null
,P_ESTABLISHMENT_ORG_NAME in varchar2 default null
,P_CAGR_NAME in varchar2 default null
,P_CAGR_ID_FLEX_NUM_USER_KEY in varchar2 default null
,P_GRADE_LADDER_NAME in varchar2 default null
,P_SVR_ASSIGNMENT_USER_KEY in varchar2 default null) is
blid number := p_data_pump_batch_line_id;
begin
if blid is not null then
delete from hr_pump_batch_lines where batch_line_id = blid;
delete from hr_pump_batch_exceptions
where source_type = 'BATCH_LINE' and source_id = blid;
end if;
insert into hr_pump_batch_lines
(batch_id
,batch_line_id
,business_group_name
,api_module_id
,line_status
,user_sequence
,link_value
,pval001
,pval002
,pval003
,pval004
,pval005
,pval006
,pval007
,pval008
,pval009
,pval010
,pval011
,pval012
,pval013
,pval014
,pval015
,pval016
,pval017
,pval018
,pval019
,pval020
,pval021
,pval022
,pval023
,pval024
,pval025
,pval026
,pval027
,pval028
,pval029
,pval030
,pval031
,pval032
,pval033
,pval034
,pval035
,pval036
,pval037
,pval038
,pval039
,pval040
,pval041
,pval042
,pval043
,pval044
,pval045
,pval046
,pval047
,pval048
,pval049
,pval050
,pval051
,pval052
,pval053
,pval054
,pval055
,pval056
,pval057
,pval058
,pval059
,pval060
,pval061
,pval062
,pval063
,pval064
,pval065
,pval066
,pval067
,pval068
,pval069
,pval070
,pval071
,pval072
,pval073
,pval074
,pval075
,pval076
,pval077
,pval078
,pval079
,pval080
,pval081
,pval082
,pval083
,pval084
,pval085
,pval086
,pval087
,pval088
,pval089
,pval090
,pval091
,pval092
,pval093
,pval094
,pval095
,pval096
,pval097
,pval098
,pval099
,pval100
,pval101
,pval102
,pval103
,pval104
,pval105
,pval106
,pval107
,pval108
,pval109
,pval110
,pval111
,pval112
,pval113
,pval114
,pval115
,pval116
,pval117
,pval118
,pval119
,pval120
,pval121
,pval122
,pval123
,pval124
,pval125
,pval126
,pval127
,pval128
,pval129
,pval131
,pval144
,pval145
,pval146
,pval147
,pval148
,pval149
,pval150
,pval151
,pval152
,pval153
,pval154
,pval155
,pval156
,pval157
,pval158
,pval159
,pval160
,pval161
,pval162
,pval163
,pval164)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,3869
,'U'
,p_user_sequence
,p_link_value
,dc(P_EFFECTIVE_DATE)
,P_ASSIGNMENT_NUMBER
,P_START_REASON
,P_COMMENTS
,dc(P_DATE_PROBATION_END)
,P_EMPLOYMENT_CATEGORY
,P_FREQUENCY
,P_INTERNAL_ADDRESS_LINE
,P_MANAGER_FLAG
,P_NORMAL_HOURS
,P_PERF_REVIEW_PERIOD
,P_PERF_REVIEW_PERIOD_FREQUENCY
,P_PROBATION_PERIOD
,P_PROBATION_UNIT
,P_SAL_REVIEW_PERIOD
,P_SAL_REVIEW_PERIOD_FREQUENCY
,P_SOURCE_TYPE
,P_TIME_NORMAL_FINISH
,P_TIME_NORMAL_START
,P_BARGAINING_UNIT_CODE
,P_LABOUR_UNION_MEMBER_FLAG
,P_HOURLY_SALARIED_CODE
,P_ASS_ATTRIBUTE_CATEGORY
,P_ASS_ATTRIBUTE1
,P_ASS_ATTRIBUTE2
,P_ASS_ATTRIBUTE3
,P_ASS_ATTRIBUTE4
,P_ASS_ATTRIBUTE5
,P_ASS_ATTRIBUTE6
,P_ASS_ATTRIBUTE7
,P_ASS_ATTRIBUTE8
,P_ASS_ATTRIBUTE9
,P_ASS_ATTRIBUTE10
,P_ASS_ATTRIBUTE11
,P_ASS_ATTRIBUTE12
,P_ASS_ATTRIBUTE13
,P_ASS_ATTRIBUTE14
,P_ASS_ATTRIBUTE15
,P_ASS_ATTRIBUTE16
,P_ASS_ATTRIBUTE17
,P_ASS_ATTRIBUTE18
,P_ASS_ATTRIBUTE19
,P_ASS_ATTRIBUTE20
,P_ASS_ATTRIBUTE21
,P_ASS_ATTRIBUTE22
,P_ASS_ATTRIBUTE23
,P_ASS_ATTRIBUTE24
,P_ASS_ATTRIBUTE25
,P_ASS_ATTRIBUTE26
,P_ASS_ATTRIBUTE27
,P_ASS_ATTRIBUTE28
,P_ASS_ATTRIBUTE29
,P_ASS_ATTRIBUTE30
,P_TITLE
,P_SEC_EMP
,P_CONTRACT_NUMBER
,dc(P_ISSUE_DATE)
,dc(P_CONT_END_DATE)
,P_LIMIT_REASON
,P_END_REASON
,P_TERRITORY_COND
,P_SPL_WORK_COND
,P_CSR
,P_CSR_ADD_INFO
,P_LSR
,P_LSR_ADD_INFO
,P_UNINT_SERVICE_REC
,P_TOTAL_SERVICE_REC
,P_PENSION_YEARS
,P_PENSION_MONTHS
,P_PENSION_DAYS
,P_SCL_CONCAT_SEGMENTS
,P_PGP_SEGMENT1
,P_PGP_SEGMENT2
,P_PGP_SEGMENT3
,P_PGP_SEGMENT4
,P_PGP_SEGMENT5
,P_PGP_SEGMENT6
,P_PGP_SEGMENT7
,P_PGP_SEGMENT8
,P_PGP_SEGMENT9
,P_PGP_SEGMENT10
,P_PGP_SEGMENT11
,P_PGP_SEGMENT12
,P_PGP_SEGMENT13
,P_PGP_SEGMENT14
,P_PGP_SEGMENT15
,P_PGP_SEGMENT16
,P_PGP_SEGMENT17
,P_PGP_SEGMENT18
,P_PGP_SEGMENT19
,P_PGP_SEGMENT20
,P_PGP_SEGMENT21
,P_PGP_SEGMENT22
,P_PGP_SEGMENT23
,P_PGP_SEGMENT24
,P_PGP_SEGMENT25
,P_PGP_SEGMENT26
,P_PGP_SEGMENT27
,P_PGP_SEGMENT28
,P_PGP_SEGMENT29
,P_PGP_SEGMENT30
,P_PGP_CONCAT_SEGMENTS
,P_CAG_SEGMENT1
,P_CAG_SEGMENT2
,P_CAG_SEGMENT3
,P_CAG_SEGMENT4
,P_CAG_SEGMENT5
,P_CAG_SEGMENT6
,P_CAG_SEGMENT7
,P_CAG_SEGMENT8
,P_CAG_SEGMENT9
,P_CAG_SEGMENT10
,P_CAG_SEGMENT11
,P_CAG_SEGMENT12
,P_CAG_SEGMENT13
,P_CAG_SEGMENT14
,P_CAG_SEGMENT15
,P_CAG_SEGMENT16
,P_CAG_SEGMENT17
,P_CAG_SEGMENT18
,P_CAG_SEGMENT19
,P_CAG_SEGMENT20
,P_NOTICE_PERIOD
,P_NOTICE_PERIOD_UOM
,P_EMPLOYEE_CATEGORY
,P_WORK_AT_HOME
,P_JOB_POST_SOURCE_NAME
,P_CAGR_GRADE_DEF_ID
,P_ASSIGNMENT_USER_KEY
,P_PERSON_USER_KEY
,P_ORGANIZATION_NAME
,P_LANGUAGE_CODE
,P_GRADE_NAME
,P_POSITION_NAME
,P_JOB_NAME
,P_USER_STATUS
,P_PAYROLL_NAME
,P_LOCATION_CODE
,P_SUPERVISOR_USER_KEY
,P_SPECIAL_CEILIN_STEP_USER_KEY
,P_PAY_BASIS_NAME
,P_DEFAULT_CODE_COMB_USER_KEY
,P_SET_OF_BOOKS_NAME
,P_EMPLOYER_NAME
,P_CONTRACT_USER_KEY
,P_ESTABLISHMENT_ORG_NAME
,P_CAGR_NAME
,P_CAGR_ID_FLEX_NUM_USER_KEY
,P_GRADE_LADDER_NAME
,P_SVR_ASSIGNMENT_USER_KEY);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,dn,d(l.pval001)) p1,
decode(l.pval002,cn,vn,l.pval002) p2,
decode(l.pval003,cn,vn,vn,vn,l.pval003) p3,
l.pval003 d3,
decode(l.pval004,cn,vn,vn,vn,l.pval004) p4,
l.pval004 d4,
decode(l.pval005,cn,dn,vn,dn,d(l.pval005)) p5,
l.pval005 d5,
decode(l.pval006,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval006,'EMP_CAT',d(l.pval001),l.pval146)) p6,
l.pval006 d6,
decode(l.pval007,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval007,'FREQUENCY',d(l.pval001),l.pval146)) p7,
l.pval007 d7,
decode(l.pval008,cn,vn,vn,vn,l.pval008) p8,
l.pval008 d8,
decode(l.pval009,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval009,'YES_NO',d(l.pval001),l.pval146)) p9,
l.pval009 d9,
decode(l.pval010,cn,nn,vn,nn,n(l.pval010)) p10,
l.pval010 d10,
decode(l.pval011,cn,nn,vn,nn,n(l.pval011)) p11,
l.pval011 d11,
decode(l.pval012,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval012,'FREQUENCY',d(l.pval001),l.pval146)) p12,
l.pval012 d12,
decode(l.pval013,cn,nn,vn,nn,n(l.pval013)) p13,
l.pval013 d13,
decode(l.pval014,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval014,'QUALIFYING_UNITS',d(l.pval001),l.pval146)) p14,
l.pval014 d14,
decode(l.pval015,cn,nn,vn,nn,n(l.pval015)) p15,
l.pval015 d15,
decode(l.pval016,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval016,'FREQUENCY',d(l.pval001),l.pval146)) p16,
l.pval016 d16,
decode(l.pval017,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval017,'REC_TYPE',d(l.pval001),l.pval146)) p17,
l.pval017 d17,
decode(l.pval018,cn,vn,vn,vn,l.pval018) p18,
l.pval018 d18,
decode(l.pval019,cn,vn,vn,vn,l.pval019) p19,
l.pval019 d19,
decode(l.pval020,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval020,'BARGAINING_UNIT_CODE',d(l.pval001),l.pval146)) p20,
l.pval020 d20,
decode(l.pval021,cn,vn,vn,'N',
 hr_pump_get.gl(l.pval021,'YES_NO',d(l.pval001),l.pval146)) p21,
l.pval021 d21,
decode(l.pval022,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval022,'HOURLY_SALARIED_CODE',d(l.pval001),l.pval146)) p22,
l.pval022 d22,
decode(l.pval023,cn,vn,vn,vn,l.pval023) p23,
l.pval023 d23,
decode(l.pval024,cn,vn,vn,vn,l.pval024) p24,
l.pval024 d24,
decode(l.pval025,cn,vn,vn,vn,l.pval025) p25,
l.pval025 d25,
decode(l.pval026,cn,vn,vn,vn,l.pval026) p26,
l.pval026 d26,
decode(l.pval027,cn,vn,vn,vn,l.pval027) p27,
l.pval027 d27,
decode(l.pval028,cn,vn,vn,vn,l.pval028) p28,
l.pval028 d28,
decode(l.pval029,cn,vn,vn,vn,l.pval029) p29,
l.pval029 d29,
decode(l.pval030,cn,vn,vn,vn,l.pval030) p30,
l.pval030 d30,
decode(l.pval031,cn,vn,vn,vn,l.pval031) p31,
l.pval031 d31,
decode(l.pval032,cn,vn,vn,vn,l.pval032) p32,
l.pval032 d32,
decode(l.pval033,cn,vn,vn,vn,l.pval033) p33,
l.pval033 d33,
decode(l.pval034,cn,vn,vn,vn,l.pval034) p34,
l.pval034 d34,
decode(l.pval035,cn,vn,vn,vn,l.pval035) p35,
l.pval035 d35,
decode(l.pval036,cn,vn,vn,vn,l.pval036) p36,
l.pval036 d36,
decode(l.pval037,cn,vn,vn,vn,l.pval037) p37,
l.pval037 d37,
decode(l.pval038,cn,vn,vn,vn,l.pval038) p38,
l.pval038 d38,
decode(l.pval039,cn,vn,vn,vn,l.pval039) p39,
l.pval039 d39,
decode(l.pval040,cn,vn,vn,vn,l.pval040) p40,
l.pval040 d40,
decode(l.pval041,cn,vn,vn,vn,l.pval041) p41,
l.pval041 d41,
decode(l.pval042,cn,vn,vn,vn,l.pval042) p42,
l.pval042 d42,
decode(l.pval043,cn,vn,vn,vn,l.pval043) p43,
l.pval043 d43,
decode(l.pval044,cn,vn,vn,vn,l.pval044) p44,
l.pval044 d44,
decode(l.pval045,cn,vn,vn,vn,l.pval045) p45,
l.pval045 d45,
decode(l.pval046,cn,vn,vn,vn,l.pval046) p46,
l.pval046 d46,
decode(l.pval047,cn,vn,vn,vn,l.pval047) p47,
l.pval047 d47,
decode(l.pval048,cn,vn,vn,vn,l.pval048) p48,
l.pval048 d48,
decode(l.pval049,cn,vn,vn,vn,l.pval049) p49,
l.pval049 d49,
decode(l.pval050,cn,vn,vn,vn,l.pval050) p50,
l.pval050 d50,
decode(l.pval051,cn,vn,vn,vn,l.pval051) p51,
l.pval051 d51,
decode(l.pval052,cn,vn,vn,vn,l.pval052) p52,
l.pval052 d52,
decode(l.pval053,cn,vn,vn,vn,l.pval053) p53,
l.pval053 d53,
decode(l.pval054,cn,vn,vn,vn,l.pval054) p54,
l.pval054 d54,
decode(l.pval055,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval055,'YES_NO',d(l.pval001),l.pval146)) p55,
l.pval055 d55,
decode(l.pval056,cn,vn,vn,vn,l.pval056) p56,
l.pval056 d56,
decode(l.pval057,cn,dn,vn,dn,d(l.pval057)) p57,
l.pval057 d57,
decode(l.pval058,cn,dn,vn,dn,d(l.pval058)) p58,
l.pval058 d58,
decode(l.pval059,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval059,'RU_LIMITED_CONTRACT_REASON',d(l.pval001),l.pval146)) p59,
l.pval059 d59,
decode(l.pval060,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval060,'LEAV_REAS',d(l.pval001),l.pval146)) p60,
l.pval060 d60,
decode(l.pval061,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval061,'RU_TERRITORY_CONDITIONS',d(l.pval001),l.pval146)) p61,
l.pval061 d61,
decode(l.pval062,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval062,'RU_SPECIAL_WORK_CONDITIONS',d(l.pval001),l.pval146)) p62,
l.pval062 d62,
decode(l.pval063,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval063,'RU_CALC_RECORD_SERVICE',d(l.pval001),l.pval146)) p63,
l.pval063 d63,
decode(l.pval064,cn,vn,vn,vn,l.pval064) p64,
l.pval064 d64,
decode(l.pval065,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval065,'RU_LONG_SERVICE',d(l.pval001),l.pval146)) p65,
l.pval065 d65,
decode(l.pval066,cn,vn,vn,vn,l.pval066) p66,
l.pval066 d66,
decode(l.pval067,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval067,'YES_NO',d(l.pval001),l.pval146)) p67,
l.pval067 d67,
decode(l.pval068,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval068,'YES_NO',d(l.pval001),l.pval146)) p68,
l.pval068 d68,
decode(l.pval069,cn,vn,vn,vn,l.pval069) p69,
l.pval069 d69,
decode(l.pval070,cn,vn,vn,vn,l.pval070) p70,
l.pval070 d70,
decode(l.pval071,cn,vn,vn,vn,l.pval071) p71,
l.pval071 d71,
decode(l.pval072,cn,vn,vn,vn,l.pval072) p72,
l.pval072 d72,
decode(l.pval073,cn,vn,vn,vn,l.pval073) p73,
l.pval073 d73,
decode(l.pval074,cn,vn,vn,vn,l.pval074) p74,
l.pval074 d74,
decode(l.pval075,cn,vn,vn,vn,l.pval075) p75,
l.pval075 d75,
decode(l.pval076,cn,vn,vn,vn,l.pval076) p76,
l.pval076 d76,
decode(l.pval077,cn,vn,vn,vn,l.pval077) p77,
l.pval077 d77,
decode(l.pval078,cn,vn,vn,vn,l.pval078) p78,
l.pval078 d78,
decode(l.pval079,cn,vn,vn,vn,l.pval079) p79,
l.pval079 d79,
decode(l.pval080,cn,vn,vn,vn,l.pval080) p80,
l.pval080 d80,
decode(l.pval081,cn,vn,vn,vn,l.pval081) p81,
l.pval081 d81,
decode(l.pval082,cn,vn,vn,vn,l.pval082) p82,
l.pval082 d82,
decode(l.pval083,cn,vn,vn,vn,l.pval083) p83,
l.pval083 d83,
decode(l.pval084,cn,vn,vn,vn,l.pval084) p84,
l.pval084 d84,
decode(l.pval085,cn,vn,vn,vn,l.pval085) p85,
l.pval085 d85,
decode(l.pval086,cn,vn,vn,vn,l.pval086) p86,
l.pval086 d86,
decode(l.pval087,cn,vn,vn,vn,l.pval087) p87,
l.pval087 d87,
decode(l.pval088,cn,vn,vn,vn,l.pval088) p88,
l.pval088 d88,
decode(l.pval089,cn,vn,vn,vn,l.pval089) p89,
l.pval089 d89,
decode(l.pval090,cn,vn,vn,vn,l.pval090) p90,
l.pval090 d90,
decode(l.pval091,cn,vn,vn,vn,l.pval091) p91,
l.pval091 d91,
decode(l.pval092,cn,vn,vn,vn,l.pval092) p92,
l.pval092 d92,
decode(l.pval093,cn,vn,vn,vn,l.pval093) p93,
l.pval093 d93,
decode(l.pval094,cn,vn,vn,vn,l.pval094) p94,
l.pval094 d94,
decode(l.pval095,cn,vn,vn,vn,l.pval095) p95,
l.pval095 d95,
decode(l.pval096,cn,vn,vn,vn,l.pval096) p96,
l.pval096 d96,
decode(l.pval097,cn,vn,vn,vn,l.pval097) p97,
l.pval097 d97,
decode(l.pval098,cn,vn,vn,vn,l.pval098) p98,
l.pval098 d98,
decode(l.pval099,cn,vn,vn,vn,l.pval099) p99,
l.pval099 d99,
decode(l.pval100,cn,vn,vn,vn,l.pval100) p100,
l.pval100 d100,
decode(l.pval101,cn,vn,vn,vn,l.pval101) p101,
l.pval101 d101,
decode(l.pval102,cn,vn,vn,vn,l.pval102) p102,
l.pval102 d102,
decode(l.pval103,cn,vn,vn,vn,l.pval103) p103,
l.pval103 d103,
decode(l.pval104,cn,vn,vn,vn,l.pval104) p104,
l.pval104 d104,
decode(l.pval105,cn,vn,vn,vn,l.pval105) p105,
l.pval105 d105,
decode(l.pval106,cn,vn,vn,vn,l.pval106) p106,
l.pval106 d106,
decode(l.pval107,cn,vn,vn,vn,l.pval107) p107,
l.pval107 d107,
decode(l.pval108,cn,vn,vn,vn,l.pval108) p108,
l.pval108 d108,
decode(l.pval109,cn,vn,vn,vn,l.pval109) p109,
l.pval109 d109,
decode(l.pval110,cn,vn,vn,vn,l.pval110) p110,
l.pval110 d110,
decode(l.pval111,cn,vn,vn,vn,l.pval111) p111,
l.pval111 d111,
decode(l.pval112,cn,vn,vn,vn,l.pval112) p112,
l.pval112 d112,
decode(l.pval113,cn,vn,vn,vn,l.pval113) p113,
l.pval113 d113,
decode(l.pval114,cn,vn,vn,vn,l.pval114) p114,
l.pval114 d114,
decode(l.pval115,cn,vn,vn,vn,l.pval115) p115,
l.pval115 d115,
decode(l.pval116,cn,vn,vn,vn,l.pval116) p116,
l.pval116 d116,
decode(l.pval117,cn,vn,vn,vn,l.pval117) p117,
l.pval117 d117,
decode(l.pval118,cn,vn,vn,vn,l.pval118) p118,
l.pval118 d118,
decode(l.pval119,cn,vn,vn,vn,l.pval119) p119,
l.pval119 d119,
decode(l.pval120,cn,vn,vn,vn,l.pval120) p120,
l.pval120 d120,
decode(l.pval121,cn,vn,vn,vn,l.pval121) p121,
l.pval121 d121,
decode(l.pval122,cn,vn,vn,vn,l.pval122) p122,
l.pval122 d122,
decode(l.pval123,cn,vn,vn,vn,l.pval123) p123,
l.pval123 d123,
decode(l.pval124,cn,nn,vn,nn,n(l.pval124)) p124,
l.pval124 d124,
decode(l.pval125,cn,vn,vn,vn,l.pval125) p125,
l.pval125 d125,
decode(l.pval126,cn,vn,vn,vn,l.pval126) p126,
l.pval126 d126,
decode(l.pval127,cn,vn,vn,vn,l.pval127) p127,
l.pval127 d127,
decode(l.pval128,cn,vn,vn,vn,l.pval128) p128,
l.pval128 d128,
decode(l.pval129,cn,nn,n(l.pval129)) p129,
l.pval130 p130,
l.pval131 p131,
l.pval132 p132,
l.pval133 p133,
l.pval134 p134,
decode(l.pval135,cn,dn,d(l.pval135)) p135,
decode(l.pval136,cn,dn,d(l.pval136)) p136,
l.pval137 p137,
l.pval138 p138,
l.pval139 p139,
l.pval140 p140,
l.pval141 p141,
l.pval142 p142,
l.pval143 p143,
decode(l.pval144,cn,vn,l.pval144) p144,
decode(l.pval145,cn,vn,l.pval145) p145,
decode(l.pval146,cn,vn,l.pval146) p146,
decode(l.pval147,cn,vn,vn,vn,l.pval147) p147,
l.pval147 d147,
decode(l.pval148,cn,vn,vn,vn,l.pval148) p148,
l.pval148 d148,
decode(l.pval149,cn,vn,vn,vn,l.pval149) p149,
l.pval149 d149,
decode(l.pval150,cn,vn,vn,vn,l.pval150) p150,
l.pval150 d150,
decode(l.pval151,cn,vn,vn,vn,l.pval151) p151,
l.pval151 d151,
decode(l.pval152,cn,vn,vn,vn,l.pval152) p152,
l.pval152 d152,
decode(l.pval153,cn,vn,vn,vn,l.pval153) p153,
l.pval153 d153,
decode(l.pval154,cn,vn,vn,vn,l.pval154) p154,
l.pval154 d154,
decode(l.pval155,cn,vn,vn,vn,l.pval155) p155,
l.pval155 d155,
decode(l.pval156,cn,vn,vn,vn,l.pval156) p156,
l.pval156 d156,
decode(l.pval157,cn,vn,vn,vn,l.pval157) p157,
l.pval157 d157,
decode(l.pval158,cn,vn,vn,vn,l.pval158) p158,
l.pval158 d158,
decode(l.pval159,cn,vn,vn,vn,l.pval159) p159,
l.pval159 d159,
decode(l.pval160,cn,vn,vn,vn,l.pval160) p160,
l.pval160 d160,
decode(l.pval161,cn,vn,vn,vn,l.pval161) p161,
l.pval161 d161,
decode(l.pval162,cn,vn,vn,vn,l.pval162) p162,
l.pval162 d162,
decode(l.pval163,cn,vn,vn,vn,l.pval163) p163,
l.pval163 d163,
decode(l.pval164,cn,vn,vn,vn,l.pval164) p164,
l.pval164 d164
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_ASSIGNMENT_ID number;
L_OTHER_MANAGER_WARNING boolean;
L_HOURLY_SALARIED_WARNING boolean;
L_PERSON_ID number;
L_ORGANIZATION_ID number;
L_GRADE_ID number;
L_POSITION_ID number;
L_JOB_ID number;
L_ASSIGNMENT_STATUS_TYPE_ID number;
L_PAYROLL_ID number;
L_LOCATION_ID number;
L_SUPERVISOR_ID number;
L_SPECIAL_CEILING_STEP_ID number;
L_PAY_BASIS_ID number;
L_DEFAULT_CODE_COMB_ID number;
L_SET_OF_BOOKS_ID number;
L_EMPLOYER varchar2(2000);
L_CONTRACT_ID number;
L_ESTABLISHMENT_ID number;
L_COLLECTIVE_AGREEMENT_ID number;
L_CAGR_ID_FLEX_NUM number;
L_GRADE_LADDER_PGM_ID number;
L_SUPERVISOR_ASSIGNMENT_ID number;
--
begin
hr_data_pump.entry('call');
open cr;
fetch cr into c;
if cr%notfound then
hr_utility.set_message(800,'HR_50326_DP_NO_ROW');
hr_utility.set_message_token('TABLE','HR_PUMP_BATCH_LINES');
hr_utility.set_message_token('COLUMN','P_BATCH_LINE_ID');
hr_utility.set_message_token('VALUE',p_batch_line_id);
hr_utility.raise_error;
end if;
--
if c.p144 is null then
L_PERSON_ID:=nn;
else
L_PERSON_ID := 
hr_pump_get.get_person_id
(P_PERSON_USER_KEY => c.p144);
end if;
--
if c.p145 is null or
c.p1 is null or
c.p146 is null then
L_ORGANIZATION_ID:=nn;
else
L_ORGANIZATION_ID := 
hr_pump_get.get_organization_id
(P_ORGANIZATION_NAME => c.p145
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1
,P_LANGUAGE_CODE => c.p146);
end if;
--
if c.p147 is null or
c.p1 is null then
L_GRADE_ID:=nn;
else
L_GRADE_ID := 
hr_pump_get.get_grade_id
(P_GRADE_NAME => c.p147
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1);
end if;
--
if c.p148 is null or
c.p1 is null then
L_POSITION_ID:=nn;
else
L_POSITION_ID := 
hr_pump_get.get_position_id
(P_POSITION_NAME => c.p148
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1);
end if;
--
if c.p149 is null or
c.p1 is null then
L_JOB_ID:=nn;
else
L_JOB_ID := 
hr_pump_get.get_job_id
(P_JOB_NAME => c.p149
,P_EFFECTIVE_DATE => c.p1
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID);
end if;
--
if c.p150 is null or
c.p146 is null then
L_ASSIGNMENT_STATUS_TYPE_ID:=nn;
else
L_ASSIGNMENT_STATUS_TYPE_ID := 
hr_pump_get.get_assignment_status_type_id
(P_USER_STATUS => c.p150
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_LANGUAGE_CODE => c.p146);
end if;
--
if c.p151 is null or
c.p1 is null then
L_PAYROLL_ID:=nn;
else
L_PAYROLL_ID := 
hr_pump_get.get_payroll_id
(P_PAYROLL_NAME => c.p151
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1);
end if;
--
if c.p152 is null or
c.p146 is null then
L_LOCATION_ID:=nn;
else
L_LOCATION_ID := 
hr_pump_get.get_location_id
(P_LOCATION_CODE => c.p152
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_LANGUAGE_CODE => c.p146);
end if;
--
if c.p153 is null then
L_SUPERVISOR_ID:=nn;
else
L_SUPERVISOR_ID := 
hr_pump_get.get_supervisor_id
(P_SUPERVISOR_USER_KEY => c.p153);
end if;
--
if c.p154 is null then
L_SPECIAL_CEILING_STEP_ID:=nn;
else
L_SPECIAL_CEILING_STEP_ID := 
hr_pump_get.get_special_ceiling_step_id
(P_SPECIAL_CEILIN_STEP_USER_KEY => c.p154);
end if;
--
if c.p155 is null then
L_PAY_BASIS_ID:=nn;
else
L_PAY_BASIS_ID := 
hr_pump_get.get_pay_basis_id
(P_PAY_BASIS_NAME => c.p155
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID);
end if;
--
if c.p156 is null then
L_DEFAULT_CODE_COMB_ID:=nn;
else
L_DEFAULT_CODE_COMB_ID := 
hr_pump_get.get_default_code_comb_id
(P_DEFAULT_CODE_COMB_USER_KEY => c.p156);
end if;
--
if c.p157 is null then
L_SET_OF_BOOKS_ID:=nn;
else
L_SET_OF_BOOKS_ID := 
hr_pump_get.get_set_of_books_id
(P_SET_OF_BOOKS_NAME => c.p157);
end if;
--
if c.p158 is null or
c.p1 is null or
c.p146 is null then
L_EMPLOYER:=vn;
else
L_EMPLOYER := 
PER_RU_DATA_PUMP.GET_EMPLOYER_ID
(P_EMPLOYER_NAME => c.p158
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1
,P_LANGUAGE_CODE => c.p146);
end if;
--
if c.p159 is null then
L_CONTRACT_ID:=nn;
else
L_CONTRACT_ID := 
hr_pump_get.get_contract_id
(P_CONTRACT_USER_KEY => c.p159);
end if;
--
if c.p160 is null or
c.p1 is null or
c.p146 is null then
L_ESTABLISHMENT_ID:=nn;
else
L_ESTABLISHMENT_ID := 
hr_pump_get.GET_ESTABLISHMENT_ORG_ID
(P_ESTABLISHMENT_ORG_NAME => c.p160
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1
,P_LANGUAGE_CODE => c.p146);
end if;
--
if c.p161 is null or
c.p1 is null then
L_COLLECTIVE_AGREEMENT_ID:=nn;
else
L_COLLECTIVE_AGREEMENT_ID := 
hr_pump_get.get_collective_agreement_id
(P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_CAGR_NAME => c.p161
,P_EFFECTIVE_DATE => c.p1);
end if;
--
if c.p162 is null then
L_CAGR_ID_FLEX_NUM:=nn;
else
L_CAGR_ID_FLEX_NUM := 
hr_pump_get.GET_CAGR_ID_FLEX_NUM
(P_CAGR_ID_FLEX_NUM_USER_KEY => c.p162);
end if;
--
if c.p163 is null or
c.p1 is null then
L_GRADE_LADDER_PGM_ID:=nn;
else
L_GRADE_LADDER_PGM_ID := 
hr_pump_get.get_grade_ladder_pgm_id
(P_GRADE_LADDER_NAME => c.p163
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1);
end if;
--
if c.p164 is null then
L_SUPERVISOR_ASSIGNMENT_ID:=nn;
else
L_SUPERVISOR_ASSIGNMENT_ID := 
hr_pump_get.get_supervisor_assignment_id
(P_SVR_ASSIGNMENT_USER_KEY => c.p164);
end if;
--
hr_data_pump.api_trc_on;
HR_RU_ASSIGNMENT_API.CREATE_RU_SECONDARY_EMP_ASG
(p_validate => l_validate
,P_EFFECTIVE_DATE => c.p1
,P_PERSON_ID => L_PERSON_ID
,P_ORGANIZATION_ID => L_ORGANIZATION_ID
,P_GRADE_ID => L_GRADE_ID
,P_POSITION_ID => L_POSITION_ID
,P_JOB_ID => L_JOB_ID
,P_ASSIGNMENT_STATUS_TYPE_ID => L_ASSIGNMENT_STATUS_TYPE_ID
,P_PAYROLL_ID => L_PAYROLL_ID
,P_LOCATION_ID => L_LOCATION_ID
,P_SUPERVISOR_ID => L_SUPERVISOR_ID
,P_SPECIAL_CEILING_STEP_ID => L_SPECIAL_CEILING_STEP_ID
,P_PAY_BASIS_ID => L_PAY_BASIS_ID
,P_ASSIGNMENT_NUMBER => c.p2
,P_START_REASON => c.p3
,P_COMMENTS => c.p4
,P_DATE_PROBATION_END => c.p5
,P_DEFAULT_CODE_COMB_ID => L_DEFAULT_CODE_COMB_ID
,P_EMPLOYMENT_CATEGORY => c.p6
,P_FREQUENCY => c.p7
,P_INTERNAL_ADDRESS_LINE => c.p8
,P_MANAGER_FLAG => c.p9
,P_NORMAL_HOURS => c.p10
,P_PERF_REVIEW_PERIOD => c.p11
,P_PERF_REVIEW_PERIOD_FREQUENCY => c.p12
,P_PROBATION_PERIOD => c.p13
,P_PROBATION_UNIT => c.p14
,P_SAL_REVIEW_PERIOD => c.p15
,P_SAL_REVIEW_PERIOD_FREQUENCY => c.p16
,P_SET_OF_BOOKS_ID => L_SET_OF_BOOKS_ID
,P_SOURCE_TYPE => c.p17
,P_TIME_NORMAL_FINISH => c.p18
,P_TIME_NORMAL_START => c.p19
,P_BARGAINING_UNIT_CODE => c.p20
,P_LABOUR_UNION_MEMBER_FLAG => c.p21
,P_HOURLY_SALARIED_CODE => c.p22
,P_ASS_ATTRIBUTE_CATEGORY => c.p23
,P_ASS_ATTRIBUTE1 => c.p24
,P_ASS_ATTRIBUTE2 => c.p25
,P_ASS_ATTRIBUTE3 => c.p26
,P_ASS_ATTRIBUTE4 => c.p27
,P_ASS_ATTRIBUTE5 => c.p28
,P_ASS_ATTRIBUTE6 => c.p29
,P_ASS_ATTRIBUTE7 => c.p30
,P_ASS_ATTRIBUTE8 => c.p31
,P_ASS_ATTRIBUTE9 => c.p32
,P_ASS_ATTRIBUTE10 => c.p33
,P_ASS_ATTRIBUTE11 => c.p34
,P_ASS_ATTRIBUTE12 => c.p35
,P_ASS_ATTRIBUTE13 => c.p36
,P_ASS_ATTRIBUTE14 => c.p37
,P_ASS_ATTRIBUTE15 => c.p38
,P_ASS_ATTRIBUTE16 => c.p39
,P_ASS_ATTRIBUTE17 => c.p40
,P_ASS_ATTRIBUTE18 => c.p41
,P_ASS_ATTRIBUTE19 => c.p42
,P_ASS_ATTRIBUTE20 => c.p43
,P_ASS_ATTRIBUTE21 => c.p44
,P_ASS_ATTRIBUTE22 => c.p45
,P_ASS_ATTRIBUTE23 => c.p46
,P_ASS_ATTRIBUTE24 => c.p47
,P_ASS_ATTRIBUTE25 => c.p48
,P_ASS_ATTRIBUTE26 => c.p49
,P_ASS_ATTRIBUTE27 => c.p50
,P_ASS_ATTRIBUTE28 => c.p51
,P_ASS_ATTRIBUTE29 => c.p52
,P_ASS_ATTRIBUTE30 => c.p53
,P_TITLE => c.p54
,P_EMPLOYER => L_EMPLOYER
,P_SEC_EMP => c.p55
,P_CONTRACT_NUMBER => c.p56
,P_ISSUE_DATE => c.p57
,P_CONT_END_DATE => c.p58
,P_LIMIT_REASON => c.p59
,P_END_REASON => c.p60
,P_TERRITORY_COND => c.p61
,P_SPL_WORK_COND => c.p62
,P_CSR => c.p63
,P_CSR_ADD_INFO => c.p64
,P_LSR => c.p65
,P_LSR_ADD_INFO => c.p66
,P_UNINT_SERVICE_REC => c.p67
,P_TOTAL_SERVICE_REC => c.p68
,P_PENSION_YEARS => c.p69
,P_PENSION_MONTHS => c.p70
,P_PENSION_DAYS => c.p71
,P_SCL_CONCAT_SEGMENTS => c.p72
,P_PGP_SEGMENT1 => c.p73
,P_PGP_SEGMENT2 => c.p74
,P_PGP_SEGMENT3 => c.p75
,P_PGP_SEGMENT4 => c.p76
,P_PGP_SEGMENT5 => c.p77
,P_PGP_SEGMENT6 => c.p78
,P_PGP_SEGMENT7 => c.p79
,P_PGP_SEGMENT8 => c.p80
,P_PGP_SEGMENT9 => c.p81
,P_PGP_SEGMENT10 => c.p82
,P_PGP_SEGMENT11 => c.p83
,P_PGP_SEGMENT12 => c.p84
,P_PGP_SEGMENT13 => c.p85
,P_PGP_SEGMENT14 => c.p86
,P_PGP_SEGMENT15 => c.p87
,P_PGP_SEGMENT16 => c.p88
,P_PGP_SEGMENT17 => c.p89
,P_PGP_SEGMENT18 => c.p90
,P_PGP_SEGMENT19 => c.p91
,P_PGP_SEGMENT20 => c.p92
,P_PGP_SEGMENT21 => c.p93
,P_PGP_SEGMENT22 => c.p94
,P_PGP_SEGMENT23 => c.p95
,P_PGP_SEGMENT24 => c.p96
,P_PGP_SEGMENT25 => c.p97
,P_PGP_SEGMENT26 => c.p98
,P_PGP_SEGMENT27 => c.p99
,P_PGP_SEGMENT28 => c.p100
,P_PGP_SEGMENT29 => c.p101
,P_PGP_SEGMENT30 => c.p102
,P_PGP_CONCAT_SEGMENTS => c.p103
,P_CONTRACT_ID => L_CONTRACT_ID
,P_ESTABLISHMENT_ID => L_ESTABLISHMENT_ID
,P_COLLECTIVE_AGREEMENT_ID => L_COLLECTIVE_AGREEMENT_ID
,P_CAGR_ID_FLEX_NUM => L_CAGR_ID_FLEX_NUM
,P_CAG_SEGMENT1 => c.p104
,P_CAG_SEGMENT2 => c.p105
,P_CAG_SEGMENT3 => c.p106
,P_CAG_SEGMENT4 => c.p107
,P_CAG_SEGMENT5 => c.p108
,P_CAG_SEGMENT6 => c.p109
,P_CAG_SEGMENT7 => c.p110
,P_CAG_SEGMENT8 => c.p111
,P_CAG_SEGMENT9 => c.p112
,P_CAG_SEGMENT10 => c.p113
,P_CAG_SEGMENT11 => c.p114
,P_CAG_SEGMENT12 => c.p115
,P_CAG_SEGMENT13 => c.p116
,P_CAG_SEGMENT14 => c.p117
,P_CAG_SEGMENT15 => c.p118
,P_CAG_SEGMENT16 => c.p119
,P_CAG_SEGMENT17 => c.p120
,P_CAG_SEGMENT18 => c.p121
,P_CAG_SEGMENT19 => c.p122
,P_CAG_SEGMENT20 => c.p123
,P_NOTICE_PERIOD => c.p124
,P_NOTICE_PERIOD_UOM => c.p125
,P_EMPLOYEE_CATEGORY => c.p126
,P_WORK_AT_HOME => c.p127
,P_JOB_POST_SOURCE_NAME => c.p128
,P_GRADE_LADDER_PGM_ID => L_GRADE_LADDER_PGM_ID
,P_SUPERVISOR_ASSIGNMENT_ID => L_SUPERVISOR_ASSIGNMENT_ID
,P_CAGR_GRADE_DEF_ID => c.p129
,P_CAGR_CONCATENATED_SEGMENTS => c.p130
,P_ASSIGNMENT_ID => L_ASSIGNMENT_ID
,P_SOFT_CODING_KEYFLEX_ID => c.p132
,P_PEOPLE_GROUP_ID => c.p133
,P_OBJECT_VERSION_NUMBER => c.p134
,P_EFFECTIVE_START_DATE => c.p135
,P_EFFECTIVE_END_DATE => c.p136
,P_ASSIGNMENT_SEQUENCE => c.p137
,P_COMMENT_ID => c.p138
,P_CONCATENATED_SEGMENTS => c.p139
,P_GROUP_NAME => c.p140
,P_OTHER_MANAGER_WARNING => L_OTHER_MANAGER_WARNING
,P_HOURLY_SALARIED_WARNING => L_HOURLY_SALARIED_WARNING
,P_GSP_POST_PROCESS_WARNING => c.p143);
hr_data_pump.api_trc_off;
--
iuk(p_batch_line_id,c.p131,L_ASSIGNMENT_ID);
--
if L_OTHER_MANAGER_WARNING then
c.p141 := 'TRUE';
else
c.p141 := 'FALSE';
end if;
--
if L_HOURLY_SALARIED_WARNING then
c.p142 := 'TRUE';
else
c.p142 := 'FALSE';
end if;
--
update hr_pump_batch_lines l set
l.pval002 = decode(c.p2,null,cn,c.p2),
l.pval129 = decode(c.p129,null,cn,c.p129),
l.pval130 = decode(c.p130,null,cn,c.p130),
l.pval131 = decode(c.p131,null,cn,c.p131),
l.pval132 = decode(c.p132,null,cn,c.p132),
l.pval133 = decode(c.p133,null,cn,c.p133),
l.pval134 = decode(c.p134,null,cn,c.p134),
l.pval135 = decode(c.p135,null,cn,dc(c.p135)),
l.pval136 = decode(c.p136,null,cn,dc(c.p136)),
l.pval137 = decode(c.p137,null,cn,c.p137),
l.pval138 = decode(c.p138,null,cn,c.p138),
l.pval139 = decode(c.p139,null,cn,c.p139),
l.pval140 = decode(c.p140,null,cn,c.p140),
l.pval141 = decode(c.p141,null,cn,c.p141),
l.pval142 = decode(c.p142,null,cn,c.p142),
l.pval143 = decode(c.p143,null,cn,c.p143)
where l.rowid = c.myrowid;
--
close cr;
--
hr_data_pump.exit('call');
exception
 when hr_multi_message.error_message_exist then
   if cr%isopen then
    close cr;
   end if;
   hr_pump_utils.set_multi_msg_error_flag(true);
 when others then
 if cr%isopen then
  close cr;
 end if;
 raise;
end call;
end hrdpp_CREATE_RU_SECONDARY_EMP_;

/
