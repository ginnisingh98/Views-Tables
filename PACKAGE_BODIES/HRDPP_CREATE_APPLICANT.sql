--------------------------------------------------------
--  DDL for Package Body HRDPP_CREATE_APPLICANT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_CREATE_APPLICANT" as
/*
 * Generated by hr_pump_meta_mapper at: 2018/06/16 10:06:11
 * Generated for API: HR_APPLICANT_API.CREATE_APPLICANT
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
,P_DATE_RECEIVED in date
,P_LAST_NAME in varchar2
,P_APPLICANT_NUMBER in varchar2
,P_PER_COMMENTS in varchar2 default null
,P_DATE_EMPLOYEE_DATA_VERIFIED in date default null
,P_DATE_OF_BIRTH in date default null
,P_EMAIL_ADDRESS in varchar2 default null
,P_EXPENSE_CHECK_SEND_TO_ADDRES in varchar2 default null
,P_FIRST_NAME in varchar2 default null
,P_KNOWN_AS in varchar2 default null
,P_MARITAL_STATUS in varchar2 default null
,P_MIDDLE_NAMES in varchar2 default null
,P_NATIONALITY in varchar2 default null
,P_NATIONAL_IDENTIFIER in varchar2 default null
,P_PREVIOUS_LAST_NAME in varchar2 default null
,P_REGISTERED_DISABLED_FLAG in varchar2 default null
,P_SEX in varchar2 default null
,P_TITLE in varchar2 default null
,P_WORK_TELEPHONE in varchar2 default null
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
,P_PER_INFORMATION_CATEGORY in varchar2 default null
,P_PER_INFORMATION1 in varchar2 default null
,P_PER_INFORMATION2 in varchar2 default null
,P_PER_INFORMATION3 in varchar2 default null
,P_PER_INFORMATION4 in varchar2 default null
,P_PER_INFORMATION5 in varchar2 default null
,P_PER_INFORMATION6 in varchar2 default null
,P_PER_INFORMATION7 in varchar2 default null
,P_PER_INFORMATION8 in varchar2 default null
,P_PER_INFORMATION9 in varchar2 default null
,P_PER_INFORMATION10 in varchar2 default null
,P_PER_INFORMATION11 in varchar2 default null
,P_PER_INFORMATION12 in varchar2 default null
,P_PER_INFORMATION13 in varchar2 default null
,P_PER_INFORMATION14 in varchar2 default null
,P_PER_INFORMATION15 in varchar2 default null
,P_PER_INFORMATION16 in varchar2 default null
,P_PER_INFORMATION17 in varchar2 default null
,P_PER_INFORMATION18 in varchar2 default null
,P_PER_INFORMATION19 in varchar2 default null
,P_PER_INFORMATION20 in varchar2 default null
,P_PER_INFORMATION21 in varchar2 default null
,P_PER_INFORMATION22 in varchar2 default null
,P_PER_INFORMATION23 in varchar2 default null
,P_PER_INFORMATION24 in varchar2 default null
,P_PER_INFORMATION25 in varchar2 default null
,P_PER_INFORMATION26 in varchar2 default null
,P_PER_INFORMATION27 in varchar2 default null
,P_PER_INFORMATION28 in varchar2 default null
,P_PER_INFORMATION29 in varchar2 default null
,P_PER_INFORMATION30 in varchar2 default null
,P_BACKGROUND_CHECK_STATUS in varchar2 default null
,P_BACKGROUND_DATE_CHECK in date default null
,P_FTE_CAPACITY in number default null
,P_HOLD_APPLICANT_DATE_UNTIL in date default null
,P_HONORS in varchar2 default null
,P_MAILSTOP in varchar2 default null
,P_OFFICE_NUMBER in varchar2 default null
,P_ON_MILITARY_SERVICE in varchar2 default null
,P_PRE_NAME_ADJUNCT in varchar2 default null
,P_PROJECTED_START_DATE in date default null
,P_RESUME_EXISTS in varchar2 default null
,P_RESUME_LAST_UPDATED in date default null
,P_STUDENT_STATUS in varchar2 default null
,P_WORK_SCHEDULE in varchar2 default null
,P_SUFFIX in varchar2 default null
,P_DATE_OF_DEATH in date default null
,P_RECEIPT_OF_DEATH_CERT_DATE in date default null
,P_COORD_BEN_MED_PLN_NO in varchar2 default null
,P_COORD_BEN_NO_CVG_FLAG in varchar2 default null
,P_USES_TOBACCO_FLAG in varchar2 default null
,P_DPDNT_ADOPTION_DATE in date default null
,P_DPDNT_VLNTRY_SVCE_FLAG in varchar2 default null
,P_ORIGINAL_DATE_OF_HIRE in date default null
,P_TOWN_OF_BIRTH in varchar2 default null
,P_REGION_OF_BIRTH in varchar2 default null
,P_COUNTRY_OF_BIRTH in varchar2 default null
,P_GLOBAL_PERSON_ID in varchar2 default null
,P_PARTY_ID in number default null
,P_PERSON_USER_KEY in varchar2
,P_ASSIGNMENT_USER_KEY in varchar2
,P_APPLICATION_USER_KEY in varchar2
,P_USER_PERSON_TYPE in varchar2 default null
,P_LANGUAGE_CODE in varchar2 default null
,P_CORRESPONDENCE_LANGUAGE in varchar2 default null
,P_BENEFIT_GROUP in varchar2 default null
,P_VACANCY_USER_KEY in varchar2 default null) is
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
,pval123
,pval124
,pval125
,pval126
,pval127)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,1339
,'U'
,p_user_sequence
,p_link_value
,dc(P_DATE_RECEIVED)
,P_LAST_NAME
,P_APPLICANT_NUMBER
,P_PER_COMMENTS
,dc(P_DATE_EMPLOYEE_DATA_VERIFIED)
,dc(P_DATE_OF_BIRTH)
,P_EMAIL_ADDRESS
,P_EXPENSE_CHECK_SEND_TO_ADDRES
,P_FIRST_NAME
,P_KNOWN_AS
,P_MARITAL_STATUS
,P_MIDDLE_NAMES
,P_NATIONALITY
,P_NATIONAL_IDENTIFIER
,P_PREVIOUS_LAST_NAME
,P_REGISTERED_DISABLED_FLAG
,P_SEX
,P_TITLE
,P_WORK_TELEPHONE
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
,P_PER_INFORMATION_CATEGORY
,P_PER_INFORMATION1
,P_PER_INFORMATION2
,P_PER_INFORMATION3
,P_PER_INFORMATION4
,P_PER_INFORMATION5
,P_PER_INFORMATION6
,P_PER_INFORMATION7
,P_PER_INFORMATION8
,P_PER_INFORMATION9
,P_PER_INFORMATION10
,P_PER_INFORMATION11
,P_PER_INFORMATION12
,P_PER_INFORMATION13
,P_PER_INFORMATION14
,P_PER_INFORMATION15
,P_PER_INFORMATION16
,P_PER_INFORMATION17
,P_PER_INFORMATION18
,P_PER_INFORMATION19
,P_PER_INFORMATION20
,P_PER_INFORMATION21
,P_PER_INFORMATION22
,P_PER_INFORMATION23
,P_PER_INFORMATION24
,P_PER_INFORMATION25
,P_PER_INFORMATION26
,P_PER_INFORMATION27
,P_PER_INFORMATION28
,P_PER_INFORMATION29
,P_PER_INFORMATION30
,P_BACKGROUND_CHECK_STATUS
,dc(P_BACKGROUND_DATE_CHECK)
,P_FTE_CAPACITY
,dc(P_HOLD_APPLICANT_DATE_UNTIL)
,P_HONORS
,P_MAILSTOP
,P_OFFICE_NUMBER
,P_ON_MILITARY_SERVICE
,P_PRE_NAME_ADJUNCT
,dc(P_PROJECTED_START_DATE)
,P_RESUME_EXISTS
,dc(P_RESUME_LAST_UPDATED)
,P_STUDENT_STATUS
,P_WORK_SCHEDULE
,P_SUFFIX
,dc(P_DATE_OF_DEATH)
,dc(P_RECEIPT_OF_DEATH_CERT_DATE)
,P_COORD_BEN_MED_PLN_NO
,P_COORD_BEN_NO_CVG_FLAG
,P_USES_TOBACCO_FLAG
,dc(P_DPDNT_ADOPTION_DATE)
,P_DPDNT_VLNTRY_SVCE_FLAG
,dc(P_ORIGINAL_DATE_OF_HIRE)
,P_TOWN_OF_BIRTH
,P_REGION_OF_BIRTH
,P_COUNTRY_OF_BIRTH
,P_GLOBAL_PERSON_ID
,P_PARTY_ID
,P_PERSON_USER_KEY
,P_ASSIGNMENT_USER_KEY
,P_APPLICATION_USER_KEY
,P_USER_PERSON_TYPE
,P_LANGUAGE_CODE
,P_CORRESPONDENCE_LANGUAGE
,P_BENEFIT_GROUP
,P_VACANCY_USER_KEY);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,dn,d(l.pval001)) p1,
decode(l.pval002,cn,vn,l.pval002) p2,
decode(l.pval003,cn,vn,l.pval003) p3,
decode(l.pval004,cn,vn,vn,vn,l.pval004) p4,
l.pval004 d4,
decode(l.pval005,cn,dn,vn,dn,d(l.pval005)) p5,
l.pval005 d5,
decode(l.pval006,cn,dn,vn,dn,d(l.pval006)) p6,
l.pval006 d6,
decode(l.pval007,cn,vn,vn,vn,l.pval007) p7,
l.pval007 d7,
decode(l.pval008,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval008,'HOME_OFFICE',d(l.pval001),l.pval124)) p8,
l.pval008 d8,
decode(l.pval009,cn,vn,vn,vn,l.pval009) p9,
l.pval009 d9,
decode(l.pval010,cn,vn,vn,vn,l.pval010) p10,
l.pval010 d10,
decode(l.pval011,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval011,'MAR_STATUS',d(l.pval001),l.pval124)) p11,
l.pval011 d11,
decode(l.pval012,cn,vn,vn,vn,l.pval012) p12,
l.pval012 d12,
decode(l.pval013,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval013,'NATIONALITY',d(l.pval001),l.pval124)) p13,
l.pval013 d13,
decode(l.pval014,cn,vn,vn,vn,l.pval014) p14,
l.pval014 d14,
decode(l.pval015,cn,vn,vn,vn,l.pval015) p15,
l.pval015 d15,
decode(l.pval016,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval016,'REGISTERED_DISABLED',d(l.pval001),l.pval124)) p16,
l.pval016 d16,
decode(l.pval017,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval017,'SEX',d(l.pval001),l.pval124)) p17,
l.pval017 d17,
decode(l.pval018,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval018,'TITLE',d(l.pval001),l.pval124)) p18,
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
decode(l.pval082,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval082,'YES_NO',d(l.pval001),l.pval124)) p82,
l.pval082 d82,
decode(l.pval083,cn,dn,vn,dn,d(l.pval083)) p83,
l.pval083 d83,
decode(l.pval084,cn,nn,vn,nn,n(l.pval084)) p84,
l.pval084 d84,
decode(l.pval085,cn,dn,vn,dn,d(l.pval085)) p85,
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
decode(l.pval091,cn,dn,vn,dn,d(l.pval091)) p91,
l.pval091 d91,
decode(l.pval092,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval092,'YES_NO',d(l.pval001),l.pval124)) p92,
l.pval092 d92,
decode(l.pval093,cn,dn,vn,dn,d(l.pval093)) p93,
l.pval093 d93,
decode(l.pval094,cn,vn,vn,vn,l.pval094) p94,
l.pval094 d94,
decode(l.pval095,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval095,'WORK_SCHEDULE',d(l.pval001),l.pval124)) p95,
l.pval095 d95,
decode(l.pval096,cn,vn,vn,vn,l.pval096) p96,
l.pval096 d96,
decode(l.pval097,cn,dn,vn,dn,d(l.pval097)) p97,
l.pval097 d97,
decode(l.pval098,cn,dn,vn,dn,d(l.pval098)) p98,
l.pval098 d98,
decode(l.pval099,cn,vn,vn,vn,l.pval099) p99,
l.pval099 d99,
decode(l.pval100,cn,vn,vn,vn,l.pval100) p100,
l.pval100 d100,
decode(l.pval101,cn,vn,vn,vn,l.pval101) p101,
l.pval101 d101,
decode(l.pval102,cn,dn,vn,dn,d(l.pval102)) p102,
l.pval102 d102,
decode(l.pval103,cn,vn,vn,vn,l.pval103) p103,
l.pval103 d103,
decode(l.pval104,cn,dn,vn,dn,d(l.pval104)) p104,
l.pval104 d104,
decode(l.pval105,cn,vn,vn,vn,l.pval105) p105,
l.pval105 d105,
decode(l.pval106,cn,vn,vn,vn,l.pval106) p106,
l.pval106 d106,
decode(l.pval107,cn,vn,vn,vn,l.pval107) p107,
l.pval107 d107,
decode(l.pval108,cn,vn,vn,vn,l.pval108) p108,
l.pval108 d108,
decode(l.pval109,cn,nn,vn,nn,n(l.pval109)) p109,
l.pval109 d109,
l.pval110 p110,
l.pval111 p111,
l.pval112 p112,
l.pval113 p113,
l.pval114 p114,
l.pval115 p115,
decode(l.pval116,cn,dn,d(l.pval116)) p116,
decode(l.pval117,cn,dn,d(l.pval117)) p117,
l.pval118 p118,
l.pval119 p119,
l.pval120 p120,
l.pval121 p121,
l.pval122 p122,
decode(l.pval123,cn,vn,vn,vn,l.pval123) p123,
l.pval123 d123,
decode(l.pval124,cn,vn,vn,vn,l.pval124) p124,
l.pval124 d124,
decode(l.pval125,cn,vn,vn,vn,l.pval125) p125,
l.pval125 d125,
decode(l.pval126,cn,vn,vn,vn,l.pval126) p126,
l.pval126 d126,
decode(l.pval127,cn,vn,vn,vn,l.pval127) p127,
l.pval127 d127
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_PERSON_ID number;
L_ASSIGNMENT_ID number;
L_APPLICATION_ID number;
L_NAME_COMBINATION_WARNING boolean;
L_ORIG_HIRE_WARNING boolean;
L_PERSON_TYPE_ID number;
L_CORRESPONDENCE_LANGUAGE varchar2(2000);
L_BENEFIT_GROUP_ID number;
L_VACANCY_ID number;
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
if c.p123 is null or
c.p124 is null then
L_PERSON_TYPE_ID:=nn;
else
L_PERSON_TYPE_ID := 
hr_pump_get.get_person_type_id
(P_USER_PERSON_TYPE => c.p123
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_LANGUAGE_CODE => c.p124);
end if;
--
if c.p125 is null then
L_CORRESPONDENCE_LANGUAGE:=vn;
else
L_CORRESPONDENCE_LANGUAGE := 
hr_pump_get.GET_CORRESPONDENCE_LANGUAGE
(P_CORRESPONDENCE_LANGUAGE => c.p125);
end if;
--
if c.p126 is null then
L_BENEFIT_GROUP_ID:=nn;
else
L_BENEFIT_GROUP_ID := 
hr_pump_get.get_benefit_group_id
(P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_BENEFIT_GROUP => c.p126);
end if;
--
if c.p127 is null then
L_VACANCY_ID:=nn;
else
L_VACANCY_ID := 
hr_pump_get.get_vacancy_id
(P_VACANCY_USER_KEY => c.p127);
end if;
--
hr_data_pump.api_trc_on;
HR_APPLICANT_API.CREATE_APPLICANT
(p_validate => l_validate
,P_DATE_RECEIVED => c.p1
,p_business_group_id => p_business_group_id
,P_LAST_NAME => c.p2
,P_PERSON_TYPE_ID => L_PERSON_TYPE_ID
,P_APPLICANT_NUMBER => c.p3
,P_PER_COMMENTS => c.p4
,P_DATE_EMPLOYEE_DATA_VERIFIED => c.p5
,P_DATE_OF_BIRTH => c.p6
,P_EMAIL_ADDRESS => c.p7
,P_EXPENSE_CHECK_SEND_TO_ADDRES => c.p8
,P_FIRST_NAME => c.p9
,P_KNOWN_AS => c.p10
,P_MARITAL_STATUS => c.p11
,P_MIDDLE_NAMES => c.p12
,P_NATIONALITY => c.p13
,P_NATIONAL_IDENTIFIER => c.p14
,P_PREVIOUS_LAST_NAME => c.p15
,P_REGISTERED_DISABLED_FLAG => c.p16
,P_SEX => c.p17
,P_TITLE => c.p18
,P_WORK_TELEPHONE => c.p19
,P_ATTRIBUTE_CATEGORY => c.p20
,P_ATTRIBUTE1 => c.p21
,P_ATTRIBUTE2 => c.p22
,P_ATTRIBUTE3 => c.p23
,P_ATTRIBUTE4 => c.p24
,P_ATTRIBUTE5 => c.p25
,P_ATTRIBUTE6 => c.p26
,P_ATTRIBUTE7 => c.p27
,P_ATTRIBUTE8 => c.p28
,P_ATTRIBUTE9 => c.p29
,P_ATTRIBUTE10 => c.p30
,P_ATTRIBUTE11 => c.p31
,P_ATTRIBUTE12 => c.p32
,P_ATTRIBUTE13 => c.p33
,P_ATTRIBUTE14 => c.p34
,P_ATTRIBUTE15 => c.p35
,P_ATTRIBUTE16 => c.p36
,P_ATTRIBUTE17 => c.p37
,P_ATTRIBUTE18 => c.p38
,P_ATTRIBUTE19 => c.p39
,P_ATTRIBUTE20 => c.p40
,P_ATTRIBUTE21 => c.p41
,P_ATTRIBUTE22 => c.p42
,P_ATTRIBUTE23 => c.p43
,P_ATTRIBUTE24 => c.p44
,P_ATTRIBUTE25 => c.p45
,P_ATTRIBUTE26 => c.p46
,P_ATTRIBUTE27 => c.p47
,P_ATTRIBUTE28 => c.p48
,P_ATTRIBUTE29 => c.p49
,P_ATTRIBUTE30 => c.p50
,P_PER_INFORMATION_CATEGORY => c.p51
,P_PER_INFORMATION1 => c.p52
,P_PER_INFORMATION2 => c.p53
,P_PER_INFORMATION3 => c.p54
,P_PER_INFORMATION4 => c.p55
,P_PER_INFORMATION5 => c.p56
,P_PER_INFORMATION6 => c.p57
,P_PER_INFORMATION7 => c.p58
,P_PER_INFORMATION8 => c.p59
,P_PER_INFORMATION9 => c.p60
,P_PER_INFORMATION10 => c.p61
,P_PER_INFORMATION11 => c.p62
,P_PER_INFORMATION12 => c.p63
,P_PER_INFORMATION13 => c.p64
,P_PER_INFORMATION14 => c.p65
,P_PER_INFORMATION15 => c.p66
,P_PER_INFORMATION16 => c.p67
,P_PER_INFORMATION17 => c.p68
,P_PER_INFORMATION18 => c.p69
,P_PER_INFORMATION19 => c.p70
,P_PER_INFORMATION20 => c.p71
,P_PER_INFORMATION21 => c.p72
,P_PER_INFORMATION22 => c.p73
,P_PER_INFORMATION23 => c.p74
,P_PER_INFORMATION24 => c.p75
,P_PER_INFORMATION25 => c.p76
,P_PER_INFORMATION26 => c.p77
,P_PER_INFORMATION27 => c.p78
,P_PER_INFORMATION28 => c.p79
,P_PER_INFORMATION29 => c.p80
,P_PER_INFORMATION30 => c.p81
,P_BACKGROUND_CHECK_STATUS => c.p82
,P_BACKGROUND_DATE_CHECK => c.p83
,P_CORRESPONDENCE_LANGUAGE => L_CORRESPONDENCE_LANGUAGE
,P_FTE_CAPACITY => c.p84
,P_HOLD_APPLICANT_DATE_UNTIL => c.p85
,P_HONORS => c.p86
,P_MAILSTOP => c.p87
,P_OFFICE_NUMBER => c.p88
,P_ON_MILITARY_SERVICE => c.p89
,P_PRE_NAME_ADJUNCT => c.p90
,P_PROJECTED_START_DATE => c.p91
,P_RESUME_EXISTS => c.p92
,P_RESUME_LAST_UPDATED => c.p93
,P_STUDENT_STATUS => c.p94
,P_WORK_SCHEDULE => c.p95
,P_SUFFIX => c.p96
,P_DATE_OF_DEATH => c.p97
,P_BENEFIT_GROUP_ID => L_BENEFIT_GROUP_ID
,P_RECEIPT_OF_DEATH_CERT_DATE => c.p98
,P_COORD_BEN_MED_PLN_NO => c.p99
,P_COORD_BEN_NO_CVG_FLAG => c.p100
,P_USES_TOBACCO_FLAG => c.p101
,P_DPDNT_ADOPTION_DATE => c.p102
,P_DPDNT_VLNTRY_SVCE_FLAG => c.p103
,P_ORIGINAL_DATE_OF_HIRE => c.p104
,P_TOWN_OF_BIRTH => c.p105
,P_REGION_OF_BIRTH => c.p106
,P_COUNTRY_OF_BIRTH => c.p107
,P_GLOBAL_PERSON_ID => c.p108
,P_PARTY_ID => c.p109
,P_VACANCY_ID => L_VACANCY_ID
,P_PERSON_ID => L_PERSON_ID
,P_ASSIGNMENT_ID => L_ASSIGNMENT_ID
,P_APPLICATION_ID => L_APPLICATION_ID
,P_PER_OBJECT_VERSION_NUMBER => c.p113
,P_ASG_OBJECT_VERSION_NUMBER => c.p114
,P_APL_OBJECT_VERSION_NUMBER => c.p115
,P_PER_EFFECTIVE_START_DATE => c.p116
,P_PER_EFFECTIVE_END_DATE => c.p117
,P_FULL_NAME => c.p118
,P_PER_COMMENT_ID => c.p119
,P_ASSIGNMENT_SEQUENCE => c.p120
,P_NAME_COMBINATION_WARNING => L_NAME_COMBINATION_WARNING
,P_ORIG_HIRE_WARNING => L_ORIG_HIRE_WARNING);
hr_data_pump.api_trc_off;
--
iuk(p_batch_line_id,c.p110,L_PERSON_ID);
--
iuk(p_batch_line_id,c.p111,L_ASSIGNMENT_ID);
--
iuk(p_batch_line_id,c.p112,L_APPLICATION_ID);
--
if L_NAME_COMBINATION_WARNING then
c.p121 := 'TRUE';
else
c.p121 := 'FALSE';
end if;
--
if L_ORIG_HIRE_WARNING then
c.p122 := 'TRUE';
else
c.p122 := 'FALSE';
end if;
--
update hr_pump_batch_lines l set
l.pval003 = decode(c.p3,null,cn,c.p3),
l.pval110 = decode(c.p110,null,cn,c.p110),
l.pval111 = decode(c.p111,null,cn,c.p111),
l.pval112 = decode(c.p112,null,cn,c.p112),
l.pval113 = decode(c.p113,null,cn,c.p113),
l.pval114 = decode(c.p114,null,cn,c.p114),
l.pval115 = decode(c.p115,null,cn,c.p115),
l.pval116 = decode(c.p116,null,cn,dc(c.p116)),
l.pval117 = decode(c.p117,null,cn,dc(c.p117)),
l.pval118 = decode(c.p118,null,cn,c.p118),
l.pval119 = decode(c.p119,null,cn,c.p119),
l.pval120 = decode(c.p120,null,cn,c.p120),
l.pval121 = decode(c.p121,null,cn,c.p121),
l.pval122 = decode(c.p122,null,cn,c.p122)
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
end hrdpp_CREATE_APPLICANT;

/
