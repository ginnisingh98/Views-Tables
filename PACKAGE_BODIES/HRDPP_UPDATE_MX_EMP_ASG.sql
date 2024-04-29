--------------------------------------------------------
--  DDL for Package Body HRDPP_UPDATE_MX_EMP_ASG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_UPDATE_MX_EMP_ASG" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:27
 * Generated for API: HR_MX_ASSIGNMENT_API.UPDATE_MX_EMP_ASG
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
,P_DATETRACK_UPDATE_MODE in varchar2
,P_ASSIGNMENT_NUMBER in varchar2 default null
,P_CHANGE_REASON in varchar2 default null
,P_COMMENTS in varchar2 default null
,P_DATE_PROBATION_END in date default null
,I_DATE_PROBATION_END in varchar2 default 'N'
,P_FREQUENCY in varchar2 default null
,P_INTERNAL_ADDRESS_LINE in varchar2 default null
,P_MANAGER_FLAG in varchar2 default null
,P_NORMAL_HOURS in number default null
,I_NORMAL_HOURS in varchar2 default 'N'
,P_PERF_REVIEW_PERIOD in number default null
,I_PERF_REVIEW_PERIOD in varchar2 default 'N'
,P_PERF_REVIEW_PERIOD_FREQUENCY in varchar2 default null
,P_PROBATION_PERIOD in number default null
,I_PROBATION_PERIOD in varchar2 default 'N'
,P_PROBATION_UNIT in varchar2 default null
,P_SAL_REVIEW_PERIOD in number default null
,I_SAL_REVIEW_PERIOD in varchar2 default 'N'
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
,P_TIMECARD_REQUIRED in varchar2 default null
,P_GOV_EMP_SECTOR in varchar2 default null
,P_SS_SALARY_TYPE in varchar2 default null
,P_SCL_CONCAT_SEGMENTS in varchar2 default null
,P_CONCAT_SEGMENTS in varchar2 default null
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
,I_NOTICE_PERIOD in varchar2 default 'N'
,P_NOTICE_PERIOD_UOM in varchar2 default null
,P_EMPLOYEE_CATEGORY in varchar2 default null
,P_WORK_AT_HOME in varchar2 default null
,P_JOB_POST_SOURCE_NAME in varchar2 default null
,P_SS_LEAVING_REASON in varchar2 default null
,P_CAGR_GRADE_DEF_ID in number
,P_ASSIGNMENT_USER_KEY in varchar2
,P_SUPERVISOR_USER_KEY in varchar2 default null
,P_USER_STATUS in varchar2 default null
,P_LANGUAGE_CODE in varchar2 default null
,P_DEFAULT_CODE_COMB_USER_KEY in varchar2 default null
,P_SET_OF_BOOKS_NAME in varchar2 default null
,P_TAX_UNIT in varchar2 default null
,P_TIMECARD_APPROVER_USER_KEY in varchar2 default null
,P_WORK_SCHEDULE in varchar2 default null
,P_CONTRACT_USER_KEY in varchar2 default null
,P_ESTABLISHMENT_ORG_NAME in varchar2 default null
,P_CAGR_NAME in varchar2 default null
,P_CAGR_ID_FLEX_NUM_USER_KEY in varchar2 default null
,P_SVR_ASSIGNMENT_USER_KEY in varchar2 default null
,P_CON_SEG_USER_NAME in varchar2) is
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
,pval110)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,3858
,'U'
,p_user_sequence
,p_link_value
,dc(P_EFFECTIVE_DATE)
,P_DATETRACK_UPDATE_MODE
,P_ASSIGNMENT_NUMBER
,P_CHANGE_REASON
,P_COMMENTS
,dd(P_DATE_PROBATION_END,I_DATE_PROBATION_END)
,P_FREQUENCY
,P_INTERNAL_ADDRESS_LINE
,P_MANAGER_FLAG
,nd(P_NORMAL_HOURS,I_NORMAL_HOURS)
,nd(P_PERF_REVIEW_PERIOD,I_PERF_REVIEW_PERIOD)
,P_PERF_REVIEW_PERIOD_FREQUENCY
,nd(P_PROBATION_PERIOD,I_PROBATION_PERIOD)
,P_PROBATION_UNIT
,nd(P_SAL_REVIEW_PERIOD,I_SAL_REVIEW_PERIOD)
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
,P_TIMECARD_REQUIRED
,P_GOV_EMP_SECTOR
,P_SS_SALARY_TYPE
,P_SCL_CONCAT_SEGMENTS
,P_CONCAT_SEGMENTS
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
,nd(P_NOTICE_PERIOD,I_NOTICE_PERIOD)
,P_NOTICE_PERIOD_UOM
,P_EMPLOYEE_CATEGORY
,P_WORK_AT_HOME
,P_JOB_POST_SOURCE_NAME
,P_SS_LEAVING_REASON
,P_CAGR_GRADE_DEF_ID
,P_ASSIGNMENT_USER_KEY
,P_SUPERVISOR_USER_KEY
,P_USER_STATUS
,P_LANGUAGE_CODE
,P_DEFAULT_CODE_COMB_USER_KEY
,P_SET_OF_BOOKS_NAME
,P_TAX_UNIT
,P_TIMECARD_APPROVER_USER_KEY
,P_WORK_SCHEDULE
,P_CONTRACT_USER_KEY
,P_ESTABLISHMENT_ORG_NAME
,P_CAGR_NAME
,P_CAGR_ID_FLEX_NUM_USER_KEY
,P_SVR_ASSIGNMENT_USER_KEY
,P_CON_SEG_USER_NAME);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,dn,d(l.pval001)) p1,
decode(l.pval002,cn,vn,l.pval002) p2,
decode(l.pval003,cn,vn,vn,vh,l.pval003) p3,
l.pval003 d3,
decode(l.pval004,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval004,'EMP_ASSIGN_REASON',d(l.pval001),l.pval099)) p4,
l.pval004 d4,
decode(l.pval005,cn,vn,vn,vh,l.pval005) p5,
l.pval005 d5,
decode(l.pval006,cn,dn,vn,dh,d(l.pval006)) p6,
l.pval006 d6,
decode(l.pval007,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval007,'FREQUENCY',d(l.pval001),l.pval099)) p7,
l.pval007 d7,
decode(l.pval008,cn,vn,vn,vh,l.pval008) p8,
l.pval008 d8,
decode(l.pval009,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval009,'YES_NO',d(l.pval001),l.pval099)) p9,
l.pval009 d9,
decode(l.pval010,cn,nn,vn,nh,n(l.pval010)) p10,
l.pval010 d10,
decode(l.pval011,cn,nn,vn,nh,n(l.pval011)) p11,
l.pval011 d11,
decode(l.pval012,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval012,'FREQUENCY',d(l.pval001),l.pval099)) p12,
l.pval012 d12,
decode(l.pval013,cn,nn,vn,nh,n(l.pval013)) p13,
l.pval013 d13,
decode(l.pval014,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval014,'QUALIFYING_UNITS',d(l.pval001),l.pval099)) p14,
l.pval014 d14,
decode(l.pval015,cn,nn,vn,nh,n(l.pval015)) p15,
l.pval015 d15,
decode(l.pval016,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval016,'FREQUENCY',d(l.pval001),l.pval099)) p16,
l.pval016 d16,
decode(l.pval017,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval017,'REC_TYPE',d(l.pval001),l.pval099)) p17,
l.pval017 d17,
decode(l.pval018,cn,vn,vn,vh,l.pval018) p18,
l.pval018 d18,
decode(l.pval019,cn,vn,vn,vh,l.pval019) p19,
l.pval019 d19,
decode(l.pval020,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval020,'BARGAINING_UNIT_CODE',d(l.pval001),l.pval099)) p20,
l.pval020 d20,
decode(l.pval021,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval021,'YES_NO',d(l.pval001),l.pval099)) p21,
l.pval021 d21,
decode(l.pval022,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval022,'HOURLY_SALARIED_CODE',d(l.pval001),l.pval099)) p22,
l.pval022 d22,
decode(l.pval023,cn,vn,vn,vh,l.pval023) p23,
l.pval023 d23,
decode(l.pval024,cn,vn,vn,vh,l.pval024) p24,
l.pval024 d24,
decode(l.pval025,cn,vn,vn,vh,l.pval025) p25,
l.pval025 d25,
decode(l.pval026,cn,vn,vn,vh,l.pval026) p26,
l.pval026 d26,
decode(l.pval027,cn,vn,vn,vh,l.pval027) p27,
l.pval027 d27,
decode(l.pval028,cn,vn,vn,vh,l.pval028) p28,
l.pval028 d28,
decode(l.pval029,cn,vn,vn,vh,l.pval029) p29,
l.pval029 d29,
decode(l.pval030,cn,vn,vn,vh,l.pval030) p30,
l.pval030 d30,
decode(l.pval031,cn,vn,vn,vh,l.pval031) p31,
l.pval031 d31,
decode(l.pval032,cn,vn,vn,vh,l.pval032) p32,
l.pval032 d32,
decode(l.pval033,cn,vn,vn,vh,l.pval033) p33,
l.pval033 d33,
decode(l.pval034,cn,vn,vn,vh,l.pval034) p34,
l.pval034 d34,
decode(l.pval035,cn,vn,vn,vh,l.pval035) p35,
l.pval035 d35,
decode(l.pval036,cn,vn,vn,vh,l.pval036) p36,
l.pval036 d36,
decode(l.pval037,cn,vn,vn,vh,l.pval037) p37,
l.pval037 d37,
decode(l.pval038,cn,vn,vn,vh,l.pval038) p38,
l.pval038 d38,
decode(l.pval039,cn,vn,vn,vh,l.pval039) p39,
l.pval039 d39,
decode(l.pval040,cn,vn,vn,vh,l.pval040) p40,
l.pval040 d40,
decode(l.pval041,cn,vn,vn,vh,l.pval041) p41,
l.pval041 d41,
decode(l.pval042,cn,vn,vn,vh,l.pval042) p42,
l.pval042 d42,
decode(l.pval043,cn,vn,vn,vh,l.pval043) p43,
l.pval043 d43,
decode(l.pval044,cn,vn,vn,vh,l.pval044) p44,
l.pval044 d44,
decode(l.pval045,cn,vn,vn,vh,l.pval045) p45,
l.pval045 d45,
decode(l.pval046,cn,vn,vn,vh,l.pval046) p46,
l.pval046 d46,
decode(l.pval047,cn,vn,vn,vh,l.pval047) p47,
l.pval047 d47,
decode(l.pval048,cn,vn,vn,vh,l.pval048) p48,
l.pval048 d48,
decode(l.pval049,cn,vn,vn,vh,l.pval049) p49,
l.pval049 d49,
decode(l.pval050,cn,vn,vn,vh,l.pval050) p50,
l.pval050 d50,
decode(l.pval051,cn,vn,vn,vh,l.pval051) p51,
l.pval051 d51,
decode(l.pval052,cn,vn,vn,vh,l.pval052) p52,
l.pval052 d52,
decode(l.pval053,cn,vn,vn,vh,l.pval053) p53,
l.pval053 d53,
decode(l.pval054,cn,vn,vn,vh,l.pval054) p54,
l.pval054 d54,
decode(l.pval055,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval055,'YES_NO',d(l.pval001),l.pval099)) p55,
l.pval055 d55,
decode(l.pval056,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval056,'HR_MX_EMP_CAT',d(l.pval001),l.pval099)) p56,
l.pval056 d56,
decode(l.pval057,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval057,'HR_MX_SS_SALARY_TYPE',d(l.pval001),l.pval099)) p57,
l.pval057 d57,
decode(l.pval058,cn,vn,vn,vh,l.pval058) p58,
l.pval058 d58,
decode(l.pval059,cn,vn,vn,vh,l.pval059) p59,
l.pval059 d59,
decode(l.pval060,cn,vn,vn,vh,l.pval060) p60,
l.pval060 d60,
decode(l.pval061,cn,vn,vn,vh,l.pval061) p61,
l.pval061 d61,
decode(l.pval062,cn,vn,vn,vh,l.pval062) p62,
l.pval062 d62,
decode(l.pval063,cn,vn,vn,vh,l.pval063) p63,
l.pval063 d63,
decode(l.pval064,cn,vn,vn,vh,l.pval064) p64,
l.pval064 d64,
decode(l.pval065,cn,vn,vn,vh,l.pval065) p65,
l.pval065 d65,
decode(l.pval066,cn,vn,vn,vh,l.pval066) p66,
l.pval066 d66,
decode(l.pval067,cn,vn,vn,vh,l.pval067) p67,
l.pval067 d67,
decode(l.pval068,cn,vn,vn,vh,l.pval068) p68,
l.pval068 d68,
decode(l.pval069,cn,vn,vn,vh,l.pval069) p69,
l.pval069 d69,
decode(l.pval070,cn,vn,vn,vh,l.pval070) p70,
l.pval070 d70,
decode(l.pval071,cn,vn,vn,vh,l.pval071) p71,
l.pval071 d71,
decode(l.pval072,cn,vn,vn,vh,l.pval072) p72,
l.pval072 d72,
decode(l.pval073,cn,vn,vn,vh,l.pval073) p73,
l.pval073 d73,
decode(l.pval074,cn,vn,vn,vh,l.pval074) p74,
l.pval074 d74,
decode(l.pval075,cn,vn,vn,vh,l.pval075) p75,
l.pval075 d75,
decode(l.pval076,cn,vn,vn,vh,l.pval076) p76,
l.pval076 d76,
decode(l.pval077,cn,vn,vn,vh,l.pval077) p77,
l.pval077 d77,
decode(l.pval078,cn,vn,vn,vh,l.pval078) p78,
l.pval078 d78,
decode(l.pval079,cn,vn,vn,vh,l.pval079) p79,
l.pval079 d79,
decode(l.pval080,cn,nn,vn,nh,n(l.pval080)) p80,
l.pval080 d80,
decode(l.pval081,cn,vn,vn,vh,l.pval081) p81,
l.pval081 d81,
decode(l.pval082,cn,vn,vn,vh,l.pval082) p82,
l.pval082 d82,
decode(l.pval083,cn,vn,vn,vh,l.pval083) p83,
l.pval083 d83,
decode(l.pval084,cn,vn,vn,vh,l.pval084) p84,
l.pval084 d84,
decode(l.pval085,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval085,'MX_STAT_IMSS_LEAVING_REASON',d(l.pval001),l.pval099)) p85,
l.pval085 d85,
decode(l.pval086,cn,nn,n(l.pval086)) p86,
l.pval087 p87,
l.pval088 p88,
l.pval089 p89,
decode(l.pval090,cn,dn,d(l.pval090)) p90,
decode(l.pval091,cn,dn,d(l.pval091)) p91,
l.pval092 p92,
l.pval093 p93,
l.pval094 p94,
l.pval095 p95,
decode(l.pval096,cn,vn,l.pval096) p96,
decode(l.pval097,cn,vn,vn,vn,l.pval097) p97,
l.pval097 d97,
decode(l.pval098,cn,vn,vn,vh,l.pval098) p98,
l.pval098 d98,
decode(l.pval099,cn,vn,vn,vh,l.pval099) p99,
l.pval099 d99,
decode(l.pval100,cn,vn,vn,vn,l.pval100) p100,
l.pval100 d100,
decode(l.pval101,cn,vn,vn,vh,l.pval101) p101,
l.pval101 d101,
decode(l.pval102,cn,vn,vn,vh,l.pval102) p102,
l.pval102 d102,
decode(l.pval103,cn,vn,vn,vn,l.pval103) p103,
l.pval103 d103,
decode(l.pval104,cn,vn,vn,vh,l.pval104) p104,
l.pval104 d104,
decode(l.pval105,cn,vn,vn,vn,l.pval105) p105,
l.pval105 d105,
decode(l.pval106,cn,vn,vn,vh,l.pval106) p106,
l.pval106 d106,
decode(l.pval107,cn,vn,vn,vh,l.pval107) p107,
l.pval107 d107,
decode(l.pval108,cn,vn,vn,vn,l.pval108) p108,
l.pval108 d108,
decode(l.pval109,cn,vn,vn,vn,l.pval109) p109,
l.pval109 d109,
decode(l.pval110,cn,vn,l.pval110) p110
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_NO_MANAGERS_WARNING boolean;
L_OTHER_MANAGER_WARNING boolean;
L_HOURLY_SALARIED_WARNING boolean;
L_ASSIGNMENT_ID number;
L_OBJECT_VERSION_NUMBER number;
L_SUPERVISOR_ID number;
L_ASSIGNMENT_STATUS_TYPE_ID number;
L_DEFAULT_CODE_COMB_ID number;
L_SET_OF_BOOKS_ID number;
L_TAX_UNIT varchar2(2000);
L_TIMECARD_APPROVER varchar2(2000);
L_WORK_SCHEDULE varchar2(2000);
L_CONTRACT_ID number;
L_ESTABLISHMENT_ID number;
L_COLLECTIVE_AGREEMENT_ID number;
L_CAGR_ID_FLEX_NUM number;
L_SUPERVISOR_ASSIGNMENT_ID number;
L_SOFT_CODING_KEYFLEX_ID number;
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
if c.p96 is null then
L_ASSIGNMENT_ID:=nn;
else
L_ASSIGNMENT_ID := 
hr_pump_get.get_assignment_id
(P_ASSIGNMENT_USER_KEY => c.p96);
end if;
--
if c.p96 is null or
c.p1 is null then
L_OBJECT_VERSION_NUMBER:=nn;
else
L_OBJECT_VERSION_NUMBER := 
hr_pump_get.GET_ASG_OVN
(P_ASSIGNMENT_USER_KEY => c.p96
,P_EFFECTIVE_DATE => c.p1);
end if;
--
if c.d97=cn then
L_SUPERVISOR_ID:=nn;
elsif c.d97 is null then 
L_SUPERVISOR_ID:=nh;
else
L_SUPERVISOR_ID := 
hr_pump_get.get_supervisor_id
(P_SUPERVISOR_USER_KEY => c.p97);
end if;
--
if c.d98=cn or
c.d99=cn then
L_ASSIGNMENT_STATUS_TYPE_ID:=nn;
elsif c.d98 is null or
c.d99 is null then 
L_ASSIGNMENT_STATUS_TYPE_ID:=nh;
else
L_ASSIGNMENT_STATUS_TYPE_ID := 
hr_pump_get.get_assignment_status_type_id
(P_USER_STATUS => c.p98
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_LANGUAGE_CODE => c.p99);
end if;
--
if c.d100=cn then
L_DEFAULT_CODE_COMB_ID:=nn;
elsif c.d100 is null then 
L_DEFAULT_CODE_COMB_ID:=nh;
else
L_DEFAULT_CODE_COMB_ID := 
hr_pump_get.get_default_code_comb_id
(P_DEFAULT_CODE_COMB_USER_KEY => c.p100);
end if;
--
if c.d101=cn then
L_SET_OF_BOOKS_ID:=nn;
elsif c.d101 is null then 
L_SET_OF_BOOKS_ID:=nh;
else
L_SET_OF_BOOKS_ID := 
hr_pump_get.get_set_of_books_id
(P_SET_OF_BOOKS_NAME => c.p101);
end if;
--
if c.d102=cn then
L_TAX_UNIT:=vn;
elsif c.d102 is null then 
L_TAX_UNIT:=vh;
else
L_TAX_UNIT := 
PER_MX_DATA_PUMP.GET_TAX_UNIT_ID
(P_TAX_UNIT => c.p102
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID);
end if;
--
if c.d103=cn then
L_TIMECARD_APPROVER:=vn;
elsif c.d103 is null then 
L_TIMECARD_APPROVER:=vh;
else
L_TIMECARD_APPROVER := 
hr_pump_get.GET_TIMECARD_APPROVER_ID
(P_TIMECARD_APPROVER_USER_KEY => c.p103);
end if;
--
if c.d104=cn then
L_WORK_SCHEDULE:=vn;
elsif c.d104 is null then 
L_WORK_SCHEDULE:=vh;
else
L_WORK_SCHEDULE := 
PER_MX_DATA_PUMP.GET_WORK_SCHEDULE
(P_WORK_SCHEDULE => c.p104);
end if;
--
if c.d105=cn then
L_CONTRACT_ID:=nn;
elsif c.d105 is null then 
L_CONTRACT_ID:=nh;
else
L_CONTRACT_ID := 
hr_pump_get.get_contract_id
(P_CONTRACT_USER_KEY => c.p105);
end if;
--
if c.d106=cn or
c.p1 is null or
c.d99=cn then
L_ESTABLISHMENT_ID:=nn;
elsif c.d106 is null or
c.d99 is null then 
L_ESTABLISHMENT_ID:=nh;
else
L_ESTABLISHMENT_ID := 
hr_pump_get.GET_ESTABLISHMENT_ORG_ID
(P_ESTABLISHMENT_ORG_NAME => c.p106
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1
,P_LANGUAGE_CODE => c.p99);
end if;
--
if c.d107=cn or
c.p1 is null then
L_COLLECTIVE_AGREEMENT_ID:=nn;
elsif c.d107 is null then 
L_COLLECTIVE_AGREEMENT_ID:=nh;
else
L_COLLECTIVE_AGREEMENT_ID := 
hr_pump_get.get_collective_agreement_id
(P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_CAGR_NAME => c.p107
,P_EFFECTIVE_DATE => c.p1);
end if;
--
if c.d108=cn then
L_CAGR_ID_FLEX_NUM:=nn;
elsif c.d108 is null then 
L_CAGR_ID_FLEX_NUM:=nh;
else
L_CAGR_ID_FLEX_NUM := 
hr_pump_get.GET_CAGR_ID_FLEX_NUM
(P_CAGR_ID_FLEX_NUM_USER_KEY => c.p108);
end if;
--
if c.d109=cn then
L_SUPERVISOR_ASSIGNMENT_ID:=nn;
elsif c.d109 is null then 
L_SUPERVISOR_ASSIGNMENT_ID:=nh;
else
L_SUPERVISOR_ASSIGNMENT_ID := 
hr_pump_get.get_supervisor_assignment_id
(P_SVR_ASSIGNMENT_USER_KEY => c.p109);
end if;
--
if c.p110 is null or
c.p1 is null then
L_SOFT_CODING_KEYFLEX_ID:=nn;
else
L_SOFT_CODING_KEYFLEX_ID := 
hr_pump_get.get_soft_coding_keyflex_id
(P_CON_SEG_USER_NAME => c.p110
,P_EFFECTIVE_DATE => c.p1);
end if;
--
hr_data_pump.api_trc_on;
HR_MX_ASSIGNMENT_API.UPDATE_MX_EMP_ASG
(p_validate => l_validate
,P_EFFECTIVE_DATE => c.p1
,P_DATETRACK_UPDATE_MODE => c.p2
,P_ASSIGNMENT_ID => L_ASSIGNMENT_ID
,P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER
,P_SUPERVISOR_ID => L_SUPERVISOR_ID
,P_ASSIGNMENT_NUMBER => c.p3
,P_CHANGE_REASON => c.p4
,P_ASSIGNMENT_STATUS_TYPE_ID => L_ASSIGNMENT_STATUS_TYPE_ID
,P_COMMENTS => c.p5
,P_DATE_PROBATION_END => c.p6
,P_DEFAULT_CODE_COMB_ID => L_DEFAULT_CODE_COMB_ID
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
,P_TAX_UNIT => L_TAX_UNIT
,P_TIMECARD_APPROVER => L_TIMECARD_APPROVER
,P_TIMECARD_REQUIRED => c.p55
,P_WORK_SCHEDULE => L_WORK_SCHEDULE
,P_GOV_EMP_SECTOR => c.p56
,P_SS_SALARY_TYPE => c.p57
,P_SCL_CONCAT_SEGMENTS => c.p58
,P_CONCAT_SEGMENTS => c.p59
,P_CONTRACT_ID => L_CONTRACT_ID
,P_ESTABLISHMENT_ID => L_ESTABLISHMENT_ID
,P_COLLECTIVE_AGREEMENT_ID => L_COLLECTIVE_AGREEMENT_ID
,P_CAGR_ID_FLEX_NUM => L_CAGR_ID_FLEX_NUM
,P_CAG_SEGMENT1 => c.p60
,P_CAG_SEGMENT2 => c.p61
,P_CAG_SEGMENT3 => c.p62
,P_CAG_SEGMENT4 => c.p63
,P_CAG_SEGMENT5 => c.p64
,P_CAG_SEGMENT6 => c.p65
,P_CAG_SEGMENT7 => c.p66
,P_CAG_SEGMENT8 => c.p67
,P_CAG_SEGMENT9 => c.p68
,P_CAG_SEGMENT10 => c.p69
,P_CAG_SEGMENT11 => c.p70
,P_CAG_SEGMENT12 => c.p71
,P_CAG_SEGMENT13 => c.p72
,P_CAG_SEGMENT14 => c.p73
,P_CAG_SEGMENT15 => c.p74
,P_CAG_SEGMENT16 => c.p75
,P_CAG_SEGMENT17 => c.p76
,P_CAG_SEGMENT18 => c.p77
,P_CAG_SEGMENT19 => c.p78
,P_CAG_SEGMENT20 => c.p79
,P_NOTICE_PERIOD => c.p80
,P_NOTICE_PERIOD_UOM => c.p81
,P_EMPLOYEE_CATEGORY => c.p82
,P_WORK_AT_HOME => c.p83
,P_JOB_POST_SOURCE_NAME => c.p84
,P_SUPERVISOR_ASSIGNMENT_ID => L_SUPERVISOR_ASSIGNMENT_ID
,P_SS_LEAVING_REASON => c.p85
,P_CAGR_GRADE_DEF_ID => c.p86
,P_CAGR_CONCATENATED_SEGMENTS => c.p87
,P_CONCATENATED_SEGMENTS => c.p88
,P_SOFT_CODING_KEYFLEX_ID => L_SOFT_CODING_KEYFLEX_ID
,P_COMMENT_ID => c.p89
,P_EFFECTIVE_START_DATE => c.p90
,P_EFFECTIVE_END_DATE => c.p91
,P_NO_MANAGERS_WARNING => L_NO_MANAGERS_WARNING
,P_OTHER_MANAGER_WARNING => L_OTHER_MANAGER_WARNING
,P_HOURLY_SALARIED_WARNING => L_HOURLY_SALARIED_WARNING
,P_GSP_POST_PROCESS_WARNING => c.p95);
hr_data_pump.api_trc_off;
--
if L_NO_MANAGERS_WARNING then
c.p92 := 'TRUE';
else
c.p92 := 'FALSE';
end if;
--
if L_OTHER_MANAGER_WARNING then
c.p93 := 'TRUE';
else
c.p93 := 'FALSE';
end if;
--
if L_HOURLY_SALARIED_WARNING then
c.p94 := 'TRUE';
else
c.p94 := 'FALSE';
end if;
--
update hr_pump_batch_lines l set
l.pval086 = decode(c.p86,null,cn,c.p86),
l.pval087 = decode(c.p87,null,cn,c.p87),
l.pval088 = decode(c.p88,null,cn,c.p88),
l.pval089 = decode(c.p89,null,cn,c.p89),
l.pval090 = decode(c.p90,null,cn,dc(c.p90)),
l.pval091 = decode(c.p91,null,cn,dc(c.p91)),
l.pval092 = decode(c.p92,null,cn,c.p92),
l.pval093 = decode(c.p93,null,cn,c.p93),
l.pval094 = decode(c.p94,null,cn,c.p94),
l.pval095 = decode(c.p95,null,cn,c.p95)
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
end hrdpp_UPDATE_MX_EMP_ASG;

/
