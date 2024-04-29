--------------------------------------------------------
--  DDL for Package Body HRDPP_CREATE_IN_SECONDARY_CWK_
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_CREATE_IN_SECONDARY_CWK_" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:36
 * Generated for API: hr_in_assignment_api.create_in_secondary_cwk_asg
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
,P_ASSIGNMENT_CATEGORY in varchar2 default null
,P_CHANGE_REASON in varchar2 default null
,P_COMMENTS in varchar2 default null
,P_FREQUENCY in varchar2 default null
,P_INTERNAL_ADDRESS_LINE in varchar2 default null
,P_LABOUR_UNION_MEMBER_FLAG in varchar2 default null
,P_MANAGER_FLAG in varchar2 default null
,P_NORMAL_HOURS in number default null
,P_PROJECT_TITLE in varchar2 default null
,P_SOURCE_TYPE in varchar2 default null
,P_TIME_NORMAL_FINISH in varchar2 default null
,P_TIME_NORMAL_START in varchar2 default null
,P_TITLE in varchar2 default null
,P_VENDOR_ASSIGNMENT_NUMBER in varchar2 default null
,P_VENDOR_EMPLOYEE_NUMBER in varchar2 default null
,P_PROJECTED_ASSIGNMENT_END in date default null
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
,P_ATTRIBUTE21 in varchar2 default null
,P_ATTRIBUTE22 in varchar2 default null
,P_ATTRIBUTE23 in varchar2 default null
,P_ATTRIBUTE24 in varchar2 default null
,P_ATTRIBUTE25 in varchar2 default null
,P_ATTRIBUTE26 in varchar2 default null
,P_ATTRIBUTE27 in varchar2 default null
,P_ATTRIBUTE28 in varchar2 default null
,P_ATTRIBUTE29 in varchar2 default null
,P_ATTRIBUTE30 in varchar2 default null
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
,P_SCL_CONCAT_SEGMENTS in varchar2 default null
,P_PGP_CONCAT_SEGMENTS in varchar2 default null
,P_ASSIGNMENT_USER_KEY in varchar2
,P_PERSON_USER_KEY in varchar2
,P_ORGANIZATION_NAME in varchar2
,P_LANGUAGE_CODE in varchar2
,P_USER_STATUS in varchar2 default null
,P_DEFAULT_CODE_COMB_USER_KEY in varchar2 default null
,P_ESTABLISHMENT_ORG_NAME in varchar2 default null
,P_JOB_NAME in varchar2 default null
,P_LOCATION_CODE in varchar2 default null
,P_POSITION_NAME in varchar2 default null
,P_GRADE_NAME in varchar2 default null
,P_SET_OF_BOOKS_NAME in varchar2 default null
,P_SUPERVISOR_USER_KEY in varchar2 default null
,P_VENDOR_NAME in varchar2 default null
,P_VENDOR_SITE_ID in number default null
,P_PO_HEADER_ID in number default null
,P_PO_LINE_ID in number default null
,P_SCL_CONTRACTOR_NAME in varchar2 default null
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
,pval110)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,3215
,'U'
,p_user_sequence
,p_link_value
,dc(P_EFFECTIVE_DATE)
,P_ASSIGNMENT_NUMBER
,P_ASSIGNMENT_CATEGORY
,P_CHANGE_REASON
,P_COMMENTS
,P_FREQUENCY
,P_INTERNAL_ADDRESS_LINE
,P_LABOUR_UNION_MEMBER_FLAG
,P_MANAGER_FLAG
,P_NORMAL_HOURS
,P_PROJECT_TITLE
,P_SOURCE_TYPE
,P_TIME_NORMAL_FINISH
,P_TIME_NORMAL_START
,P_TITLE
,P_VENDOR_ASSIGNMENT_NUMBER
,P_VENDOR_EMPLOYEE_NUMBER
,dc(P_PROJECTED_ASSIGNMENT_END)
,P_ATTRIBUTE_CATEGORY
,P_ATTRIBUTE1
,P_ATTRIBUTE2
,P_ATTRIBUTE3
,P_ATTRIBUTE4
,P_ATTRIBUTE5
,P_ATTRIBUTE6
,P_ATTRIBUTE7
,P_ATTRIBUTE8
,P_ATTRIBUTE9
,P_ATTRIBUTE10
,P_ATTRIBUTE11
,P_ATTRIBUTE12
,P_ATTRIBUTE13
,P_ATTRIBUTE14
,P_ATTRIBUTE15
,P_ATTRIBUTE16
,P_ATTRIBUTE17
,P_ATTRIBUTE18
,P_ATTRIBUTE19
,P_ATTRIBUTE20
,P_ATTRIBUTE21
,P_ATTRIBUTE22
,P_ATTRIBUTE23
,P_ATTRIBUTE24
,P_ATTRIBUTE25
,P_ATTRIBUTE26
,P_ATTRIBUTE27
,P_ATTRIBUTE28
,P_ATTRIBUTE29
,P_ATTRIBUTE30
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
,P_SCL_CONCAT_SEGMENTS
,P_PGP_CONCAT_SEGMENTS
,P_ASSIGNMENT_USER_KEY
,P_PERSON_USER_KEY
,P_ORGANIZATION_NAME
,P_LANGUAGE_CODE
,P_USER_STATUS
,P_DEFAULT_CODE_COMB_USER_KEY
,P_ESTABLISHMENT_ORG_NAME
,P_JOB_NAME
,P_LOCATION_CODE
,P_POSITION_NAME
,P_GRADE_NAME
,P_SET_OF_BOOKS_NAME
,P_SUPERVISOR_USER_KEY
,P_VENDOR_NAME
,P_VENDOR_SITE_ID
,P_PO_HEADER_ID
,P_PO_LINE_ID
,P_SCL_CONTRACTOR_NAME
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
decode(l.pval003,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval003,'CWK_ASG_CATEGORY',d(l.pval001),l.pval095)) p3,
l.pval003 d3,
decode(l.pval004,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval004,'CWK_ASSIGN_REASON',d(l.pval001),l.pval095)) p4,
l.pval004 d4,
decode(l.pval005,cn,vn,vn,vn,l.pval005) p5,
l.pval005 d5,
decode(l.pval006,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval006,'FREQUENCY',d(l.pval001),l.pval095)) p6,
l.pval006 d6,
decode(l.pval007,cn,vn,vn,vn,l.pval007) p7,
l.pval007 d7,
decode(l.pval008,cn,vn,vn,'N',
 hr_pump_get.gl(l.pval008,'YES_NO',d(l.pval001),l.pval095)) p8,
l.pval008 d8,
decode(l.pval009,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval009,'YES_NO',d(l.pval001),l.pval095)) p9,
l.pval009 d9,
decode(l.pval010,cn,nn,vn,nn,n(l.pval010)) p10,
l.pval010 d10,
decode(l.pval011,cn,vn,vn,vn,l.pval011) p11,
l.pval011 d11,
decode(l.pval012,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval012,'REC_TYPE',d(l.pval001),l.pval095)) p12,
l.pval012 d12,
decode(l.pval013,cn,vn,vn,vn,l.pval013) p13,
l.pval013 d13,
decode(l.pval014,cn,vn,vn,vn,l.pval014) p14,
l.pval014 d14,
decode(l.pval015,cn,vn,vn,vn,l.pval015) p15,
l.pval015 d15,
decode(l.pval016,cn,vn,vn,vn,l.pval016) p16,
l.pval016 d16,
decode(l.pval017,cn,vn,vn,vn,l.pval017) p17,
l.pval017 d17,
decode(l.pval018,cn,dn,vn,dn,d(l.pval018)) p18,
l.pval018 d18,
decode(l.pval019,cn,vn,vn,vn,l.pval019) p19,
l.pval019 d19,
decode(l.pval020,cn,vn,vn,vn,l.pval020) p20,
l.pval020 d20,
decode(l.pval021,cn,vn,vn,vn,l.pval021) p21,
l.pval021 d21,
decode(l.pval022,cn,vn,vn,vn,l.pval022) p22,
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
decode(l.pval055,cn,vn,vn,vn,l.pval055) p55,
l.pval055 d55,
decode(l.pval056,cn,vn,vn,vn,l.pval056) p56,
l.pval056 d56,
decode(l.pval057,cn,vn,vn,vn,l.pval057) p57,
l.pval057 d57,
decode(l.pval058,cn,vn,vn,vn,l.pval058) p58,
l.pval058 d58,
decode(l.pval059,cn,vn,vn,vn,l.pval059) p59,
l.pval059 d59,
decode(l.pval060,cn,vn,vn,vn,l.pval060) p60,
l.pval060 d60,
decode(l.pval061,cn,vn,vn,vn,l.pval061) p61,
l.pval061 d61,
decode(l.pval062,cn,vn,vn,vn,l.pval062) p62,
l.pval062 d62,
decode(l.pval063,cn,vn,vn,vn,l.pval063) p63,
l.pval063 d63,
decode(l.pval064,cn,vn,vn,vn,l.pval064) p64,
l.pval064 d64,
decode(l.pval065,cn,vn,vn,vn,l.pval065) p65,
l.pval065 d65,
decode(l.pval066,cn,vn,vn,vn,l.pval066) p66,
l.pval066 d66,
decode(l.pval067,cn,vn,vn,vn,l.pval067) p67,
l.pval067 d67,
decode(l.pval068,cn,vn,vn,vn,l.pval068) p68,
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
l.pval082 p82,
l.pval083 p83,
decode(l.pval084,cn,dn,d(l.pval084)) p84,
decode(l.pval085,cn,dn,d(l.pval085)) p85,
l.pval086 p86,
l.pval087 p87,
l.pval088 p88,
l.pval089 p89,
l.pval090 p90,
l.pval091 p91,
l.pval092 p92,
decode(l.pval093,cn,vn,l.pval093) p93,
decode(l.pval094,cn,vn,l.pval094) p94,
decode(l.pval095,cn,vn,l.pval095) p95,
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
decode(l.pval106,cn,nn,vn,nn,n(l.pval106)) p106,
l.pval106 d106,
decode(l.pval107,cn,nn,vn,nn,n(l.pval107)) p107,
l.pval107 d107,
decode(l.pval108,cn,nn,vn,nn,n(l.pval108)) p108,
l.pval108 d108,
decode(l.pval109,cn,vn,vn,vn,l.pval109) p109,
l.pval109 d109,
decode(l.pval110,cn,vn,vn,vn,l.pval110) p110,
l.pval110 d110
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
L_ASSIGNMENT_STATUS_TYPE_ID number;
L_DEFAULT_CODE_COMB_ID number;
L_ESTABLISHMENT_ID number;
L_JOB_ID number;
L_LOCATION_ID number;
L_POSITION_ID number;
L_GRADE_ID number;
L_SET_OF_BOOKS_ID number;
L_SUPERVISOR_ID number;
L_VENDOR_ID number;
L_VENDOR_SITE_ID number;
L_PO_HEADER_ID number;
L_PO_LINE_ID number;
L_SCL_CONTRACTOR_NAME varchar2(2000);
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
if c.p93 is null then
L_PERSON_ID:=nn;
else
L_PERSON_ID := 
hr_pump_get.get_person_id
(P_PERSON_USER_KEY => c.p93);
end if;
--
if c.p94 is null or
c.p1 is null or
c.p95 is null then
L_ORGANIZATION_ID:=nn;
else
L_ORGANIZATION_ID := 
hr_pump_get.get_organization_id
(P_ORGANIZATION_NAME => c.p94
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1
,P_LANGUAGE_CODE => c.p95);
end if;
--
if c.p96 is null or
c.p95 is null then
L_ASSIGNMENT_STATUS_TYPE_ID:=nn;
else
L_ASSIGNMENT_STATUS_TYPE_ID := 
hr_pump_get.get_assignment_status_type_id
(P_USER_STATUS => c.p96
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_LANGUAGE_CODE => c.p95);
end if;
--
if c.p97 is null then
L_DEFAULT_CODE_COMB_ID:=nn;
else
L_DEFAULT_CODE_COMB_ID := 
hr_pump_get.get_default_code_comb_id
(P_DEFAULT_CODE_COMB_USER_KEY => c.p97);
end if;
--
if c.p98 is null or
c.p1 is null or
c.p95 is null then
L_ESTABLISHMENT_ID:=nn;
else
L_ESTABLISHMENT_ID := 
hr_pump_get.GET_ESTABLISHMENT_ORG_ID
(P_ESTABLISHMENT_ORG_NAME => c.p98
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1
,P_LANGUAGE_CODE => c.p95);
end if;
--
if c.p99 is null or
c.p1 is null then
L_JOB_ID:=nn;
else
L_JOB_ID := 
hr_pump_get.get_job_id
(P_JOB_NAME => c.p99
,P_EFFECTIVE_DATE => c.p1
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID);
end if;
--
if c.p100 is null or
c.p95 is null then
L_LOCATION_ID:=nn;
else
L_LOCATION_ID := 
hr_pump_get.get_location_id
(P_LOCATION_CODE => c.p100
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_LANGUAGE_CODE => c.p95);
end if;
--
if c.p101 is null or
c.p1 is null then
L_POSITION_ID:=nn;
else
L_POSITION_ID := 
hr_pump_get.get_position_id
(P_POSITION_NAME => c.p101
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1);
end if;
--
if c.p102 is null or
c.p1 is null then
L_GRADE_ID:=nn;
else
L_GRADE_ID := 
hr_pump_get.get_grade_id
(P_GRADE_NAME => c.p102
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1);
end if;
--
if c.p103 is null then
L_SET_OF_BOOKS_ID:=nn;
else
L_SET_OF_BOOKS_ID := 
hr_pump_get.get_set_of_books_id
(P_SET_OF_BOOKS_NAME => c.p103);
end if;
--
if c.p104 is null then
L_SUPERVISOR_ID:=nn;
else
L_SUPERVISOR_ID := 
hr_pump_get.get_supervisor_id
(P_SUPERVISOR_USER_KEY => c.p104);
end if;
--
if c.p105 is null then
L_VENDOR_ID:=nn;
else
L_VENDOR_ID := 
hr_pump_get.get_vendor_id
(P_VENDOR_NAME => c.p105);
end if;
--
if c.p106 is null then
L_VENDOR_SITE_ID:=nn;
else
L_VENDOR_SITE_ID := 
PER_IN_DATA_PUMP.get_vendor_site_id
(P_VENDOR_SITE_ID => c.p106);
end if;
--
if c.p107 is null then
L_PO_HEADER_ID:=nn;
else
L_PO_HEADER_ID := 
PER_IN_DATA_PUMP.get_po_header_id
(P_PO_HEADER_ID => c.p107);
end if;
--
if c.p108 is null then
L_PO_LINE_ID:=nn;
else
L_PO_LINE_ID := 
PER_IN_DATA_PUMP.get_po_line_id
(P_PO_LINE_ID => c.p108);
end if;
--
if c.p109 is null then
L_SCL_CONTRACTOR_NAME:=vn;
else
L_SCL_CONTRACTOR_NAME := 
PER_IN_DATA_PUMP.GET_SCL_CONTRACTOR_ID
(P_SCL_CONTRACTOR_NAME => c.p109);
end if;
--
if c.p110 is null then
L_SUPERVISOR_ASSIGNMENT_ID:=nn;
else
L_SUPERVISOR_ASSIGNMENT_ID := 
hr_pump_get.get_supervisor_assignment_id
(P_SVR_ASSIGNMENT_USER_KEY => c.p110);
end if;
--
hr_data_pump.api_trc_on;
hr_in_assignment_api.create_in_secondary_cwk_asg
(p_validate => l_validate
,P_EFFECTIVE_DATE => c.p1
,p_business_group_id => p_business_group_id
,P_PERSON_ID => L_PERSON_ID
,P_ORGANIZATION_ID => L_ORGANIZATION_ID
,P_ASSIGNMENT_NUMBER => c.p2
,P_ASSIGNMENT_CATEGORY => c.p3
,P_ASSIGNMENT_STATUS_TYPE_ID => L_ASSIGNMENT_STATUS_TYPE_ID
,P_CHANGE_REASON => c.p4
,P_COMMENTS => c.p5
,P_DEFAULT_CODE_COMB_ID => L_DEFAULT_CODE_COMB_ID
,P_ESTABLISHMENT_ID => L_ESTABLISHMENT_ID
,P_FREQUENCY => c.p6
,P_INTERNAL_ADDRESS_LINE => c.p7
,P_JOB_ID => L_JOB_ID
,P_LABOUR_UNION_MEMBER_FLAG => c.p8
,P_LOCATION_ID => L_LOCATION_ID
,P_MANAGER_FLAG => c.p9
,P_NORMAL_HOURS => c.p10
,P_POSITION_ID => L_POSITION_ID
,P_GRADE_ID => L_GRADE_ID
,P_PROJECT_TITLE => c.p11
,P_SET_OF_BOOKS_ID => L_SET_OF_BOOKS_ID
,P_SOURCE_TYPE => c.p12
,P_SUPERVISOR_ID => L_SUPERVISOR_ID
,P_TIME_NORMAL_FINISH => c.p13
,P_TIME_NORMAL_START => c.p14
,P_TITLE => c.p15
,P_VENDOR_ASSIGNMENT_NUMBER => c.p16
,P_VENDOR_EMPLOYEE_NUMBER => c.p17
,P_VENDOR_ID => L_VENDOR_ID
,P_VENDOR_SITE_ID => L_VENDOR_SITE_ID
,P_PO_HEADER_ID => L_PO_HEADER_ID
,P_PO_LINE_ID => L_PO_LINE_ID
,P_PROJECTED_ASSIGNMENT_END => c.p18
,P_ATTRIBUTE_CATEGORY => c.p19
,P_ATTRIBUTE1 => c.p20
,P_ATTRIBUTE2 => c.p21
,P_ATTRIBUTE3 => c.p22
,P_ATTRIBUTE4 => c.p23
,P_ATTRIBUTE5 => c.p24
,P_ATTRIBUTE6 => c.p25
,P_ATTRIBUTE7 => c.p26
,P_ATTRIBUTE8 => c.p27
,P_ATTRIBUTE9 => c.p28
,P_ATTRIBUTE10 => c.p29
,P_ATTRIBUTE11 => c.p30
,P_ATTRIBUTE12 => c.p31
,P_ATTRIBUTE13 => c.p32
,P_ATTRIBUTE14 => c.p33
,P_ATTRIBUTE15 => c.p34
,P_ATTRIBUTE16 => c.p35
,P_ATTRIBUTE17 => c.p36
,P_ATTRIBUTE18 => c.p37
,P_ATTRIBUTE19 => c.p38
,P_ATTRIBUTE20 => c.p39
,P_ATTRIBUTE21 => c.p40
,P_ATTRIBUTE22 => c.p41
,P_ATTRIBUTE23 => c.p42
,P_ATTRIBUTE24 => c.p43
,P_ATTRIBUTE25 => c.p44
,P_ATTRIBUTE26 => c.p45
,P_ATTRIBUTE27 => c.p46
,P_ATTRIBUTE28 => c.p47
,P_ATTRIBUTE29 => c.p48
,P_ATTRIBUTE30 => c.p49
,P_PGP_SEGMENT1 => c.p50
,P_PGP_SEGMENT2 => c.p51
,P_PGP_SEGMENT3 => c.p52
,P_PGP_SEGMENT4 => c.p53
,P_PGP_SEGMENT5 => c.p54
,P_PGP_SEGMENT6 => c.p55
,P_PGP_SEGMENT7 => c.p56
,P_PGP_SEGMENT8 => c.p57
,P_PGP_SEGMENT9 => c.p58
,P_PGP_SEGMENT10 => c.p59
,P_PGP_SEGMENT11 => c.p60
,P_PGP_SEGMENT12 => c.p61
,P_PGP_SEGMENT13 => c.p62
,P_PGP_SEGMENT14 => c.p63
,P_PGP_SEGMENT15 => c.p64
,P_PGP_SEGMENT16 => c.p65
,P_PGP_SEGMENT17 => c.p66
,P_PGP_SEGMENT18 => c.p67
,P_PGP_SEGMENT19 => c.p68
,P_PGP_SEGMENT20 => c.p69
,P_PGP_SEGMENT21 => c.p70
,P_PGP_SEGMENT22 => c.p71
,P_PGP_SEGMENT23 => c.p72
,P_PGP_SEGMENT24 => c.p73
,P_PGP_SEGMENT25 => c.p74
,P_PGP_SEGMENT26 => c.p75
,P_PGP_SEGMENT27 => c.p76
,P_PGP_SEGMENT28 => c.p77
,P_PGP_SEGMENT29 => c.p78
,P_PGP_SEGMENT30 => c.p79
,P_SCL_CONTRACTOR_NAME => L_SCL_CONTRACTOR_NAME
,P_SCL_CONCAT_SEGMENTS => c.p80
,P_PGP_CONCAT_SEGMENTS => c.p81
,P_SUPERVISOR_ASSIGNMENT_ID => L_SUPERVISOR_ASSIGNMENT_ID
,P_ASSIGNMENT_ID => L_ASSIGNMENT_ID
,P_OBJECT_VERSION_NUMBER => c.p83
,P_EFFECTIVE_START_DATE => c.p84
,P_EFFECTIVE_END_DATE => c.p85
,P_ASSIGNMENT_SEQUENCE => c.p86
,P_COMMENT_ID => c.p87
,P_PEOPLE_GROUP_ID => c.p88
,P_PEOPLE_GROUP_NAME => c.p89
,P_OTHER_MANAGER_WARNING => L_OTHER_MANAGER_WARNING
,P_HOURLY_SALARIED_WARNING => L_HOURLY_SALARIED_WARNING
,P_SOFT_CODING_KEYFLEX_ID => c.p92);
hr_data_pump.api_trc_off;
--
iuk(p_batch_line_id,c.p82,L_ASSIGNMENT_ID);
--
if L_OTHER_MANAGER_WARNING then
c.p90 := 'TRUE';
else
c.p90 := 'FALSE';
end if;
--
if L_HOURLY_SALARIED_WARNING then
c.p91 := 'TRUE';
else
c.p91 := 'FALSE';
end if;
--
update hr_pump_batch_lines l set
l.pval002 = decode(c.p2,null,cn,c.p2),
l.pval082 = decode(c.p82,null,cn,c.p82),
l.pval083 = decode(c.p83,null,cn,c.p83),
l.pval084 = decode(c.p84,null,cn,dc(c.p84)),
l.pval085 = decode(c.p85,null,cn,dc(c.p85)),
l.pval086 = decode(c.p86,null,cn,c.p86),
l.pval087 = decode(c.p87,null,cn,c.p87),
l.pval088 = decode(c.p88,null,cn,c.p88),
l.pval089 = decode(c.p89,null,cn,c.p89),
l.pval090 = decode(c.p90,null,cn,c.p90),
l.pval091 = decode(c.p91,null,cn,c.p91),
l.pval092 = decode(c.p92,null,cn,c.p92)
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
end hrdpp_create_in_secondary_cwk_;

/
