--------------------------------------------------------
--  DDL for Package Body HRDPP_UPDATE_GB_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_UPDATE_GB_PERSON" as
/*
 * Generated by hr_pump_meta_mapper at: 2018/06/16 10:06:13
 * Generated for API: HR_PERSON_API.UPDATE_GB_PERSON
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
,P_LAST_NAME in varchar2 default null
,P_APPLICANT_NUMBER in varchar2 default null
,P_COMMENTS in varchar2 default null
,P_DATE_EMPLOYEE_DATA_VERIFIED in date default null
,I_DATE_EMPLOYEE_DATA_VERIFIED in varchar2 default 'N'
,P_DATE_OF_BIRTH in date default null
,I_DATE_OF_BIRTH in varchar2 default 'N'
,P_EMAIL_ADDRESS in varchar2 default null
,P_EMPLOYEE_NUMBER in varchar2
,P_EXPENSE_CHECK_SEND_TO_ADDRES in varchar2 default null
,P_FIRST_NAME in varchar2 default null
,P_KNOWN_AS in varchar2 default null
,P_MARITAL_STATUS in varchar2 default null
,P_MIDDLE_NAMES in varchar2 default null
,P_NATIONALITY in varchar2 default null
,P_NI_NUMBER in varchar2 default null
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
,P_ETHNIC_ORIGIN in varchar2 default null
,P_DIRECTOR in varchar2 default null
,P_PENSIONER in varchar2 default null
,P_WORK_PERMIT_NUMBER in varchar2 default null
,P_ADDL_PENSION_YEARS in varchar2 default null
,P_ADDL_PENSION_MONTHS in varchar2 default null
,P_ADDL_PENSION_DAYS in varchar2 default null
,P_NI_MULTIPLE_ASG in varchar2 default null
,P_PAYE_AGGREGATE_ASSIGNMENT in varchar2 default null
,P_DATE_OF_DEATH in date default null
,I_DATE_OF_DEATH in varchar2 default 'N'
,P_BACKGROUND_CHECK_STATUS in varchar2 default null
,P_BACKGROUND_DATE_CHECK in date default null
,I_BACKGROUND_DATE_CHECK in varchar2 default 'N'
,P_BLOOD_TYPE in varchar2 default null
,P_FAST_PATH_EMPLOYEE in varchar2 default null
,P_FTE_CAPACITY in number default null
,I_FTE_CAPACITY in varchar2 default 'N'
,P_HOLD_APPLICANT_DATE_UNTIL in date default null
,I_HOLD_APPLICANT_DATE_UNTIL in varchar2 default 'N'
,P_HONORS in varchar2 default null
,P_INTERNAL_LOCATION in varchar2 default null
,P_LAST_MEDICAL_TEST_BY in varchar2 default null
,P_LAST_MEDICAL_TEST_DATE in date default null
,I_LAST_MEDICAL_TEST_DATE in varchar2 default 'N'
,P_MAILSTOP in varchar2 default null
,P_OFFICE_NUMBER in varchar2 default null
,P_ON_MILITARY_SERVICE in varchar2 default null
,P_PRE_NAME_ADJUNCT in varchar2 default null
,P_PROJECTED_START_DATE in date default null
,I_PROJECTED_START_DATE in varchar2 default 'N'
,P_REHIRE_AUTHORIZOR in varchar2 default null
,P_REHIRE_RECOMMENDATION in varchar2 default null
,P_RESUME_EXISTS in varchar2 default null
,P_RESUME_LAST_UPDATED in date default null
,I_RESUME_LAST_UPDATED in varchar2 default 'N'
,P_SECOND_PASSPORT_EXISTS in varchar2 default null
,P_STUDENT_STATUS in varchar2 default null
,P_WORK_SCHEDULE in varchar2 default null
,P_REHIRE_REASON in varchar2 default null
,P_SUFFIX in varchar2 default null
,P_RECEIPT_OF_DEATH_CERT_DATE in date default null
,I_RECEIPT_OF_DEATH_CERT_DATE in varchar2 default 'N'
,P_COORD_BEN_MED_PLN_NO in varchar2 default null
,P_COORD_BEN_NO_CVG_FLAG in varchar2 default null
,P_COORD_BEN_MED_EXT_ER in varchar2 default null
,P_COORD_BEN_MED_PL_NAME in varchar2 default null
,P_COORD_BEN_MED_INSR_CRR_NAME in varchar2 default null
,P_COORD_BEN_MED_INSR_CRR_IDENT in varchar2 default null
,P_COORD_BEN_MED_CVG_STRT_DT in date default null
,I_COORD_BEN_MED_CVG_STRT_DT in varchar2 default 'N'
,P_COORD_BEN_MED_CVG_END_DT in date default null
,I_COORD_BEN_MED_CVG_END_DT in varchar2 default 'N'
,P_USES_TOBACCO_FLAG in varchar2 default null
,P_DPDNT_ADOPTION_DATE in date default null
,I_DPDNT_ADOPTION_DATE in varchar2 default 'N'
,P_DPDNT_VLNTRY_SVCE_FLAG in varchar2 default null
,P_ORIGINAL_DATE_OF_HIRE in date default null
,I_ORIGINAL_DATE_OF_HIRE in varchar2 default 'N'
,P_ADJUSTED_SVC_DATE in date default null
,I_ADJUSTED_SVC_DATE in varchar2 default 'N'
,P_TOWN_OF_BIRTH in varchar2 default null
,P_REGION_OF_BIRTH in varchar2 default null
,P_COUNTRY_OF_BIRTH in varchar2 default null
,P_GLOBAL_PERSON_ID in varchar2 default null
,P_PARTY_ID in number default null
,I_PARTY_ID in varchar2 default 'N'
,P_NPW_NUMBER in varchar2 default null
,P_PERSON_USER_KEY in varchar2
,P_USER_PERSON_TYPE in varchar2 default null
,P_LANGUAGE_CODE in varchar2 default null
,P_VENDOR_NAME in varchar2 default null
,P_CORRESPONDENCE_LANGUAGE in varchar2 default null
,P_BENEFIT_GROUP in varchar2 default null) is
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
,pval114
,pval115
,pval116
,pval117
,pval118
,pval119)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,1392
,'U'
,p_user_sequence
,p_link_value
,dc(P_EFFECTIVE_DATE)
,P_DATETRACK_UPDATE_MODE
,P_LAST_NAME
,P_APPLICANT_NUMBER
,P_COMMENTS
,dd(P_DATE_EMPLOYEE_DATA_VERIFIED,I_DATE_EMPLOYEE_DATA_VERIFIED)
,dd(P_DATE_OF_BIRTH,I_DATE_OF_BIRTH)
,P_EMAIL_ADDRESS
,P_EMPLOYEE_NUMBER
,P_EXPENSE_CHECK_SEND_TO_ADDRES
,P_FIRST_NAME
,P_KNOWN_AS
,P_MARITAL_STATUS
,P_MIDDLE_NAMES
,P_NATIONALITY
,P_NI_NUMBER
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
,P_ETHNIC_ORIGIN
,P_DIRECTOR
,P_PENSIONER
,P_WORK_PERMIT_NUMBER
,P_ADDL_PENSION_YEARS
,P_ADDL_PENSION_MONTHS
,P_ADDL_PENSION_DAYS
,P_NI_MULTIPLE_ASG
,P_PAYE_AGGREGATE_ASSIGNMENT
,dd(P_DATE_OF_DEATH,I_DATE_OF_DEATH)
,P_BACKGROUND_CHECK_STATUS
,dd(P_BACKGROUND_DATE_CHECK,I_BACKGROUND_DATE_CHECK)
,P_BLOOD_TYPE
,P_FAST_PATH_EMPLOYEE
,nd(P_FTE_CAPACITY,I_FTE_CAPACITY)
,dd(P_HOLD_APPLICANT_DATE_UNTIL,I_HOLD_APPLICANT_DATE_UNTIL)
,P_HONORS
,P_INTERNAL_LOCATION
,P_LAST_MEDICAL_TEST_BY
,dd(P_LAST_MEDICAL_TEST_DATE,I_LAST_MEDICAL_TEST_DATE)
,P_MAILSTOP
,P_OFFICE_NUMBER
,P_ON_MILITARY_SERVICE
,P_PRE_NAME_ADJUNCT
,dd(P_PROJECTED_START_DATE,I_PROJECTED_START_DATE)
,P_REHIRE_AUTHORIZOR
,P_REHIRE_RECOMMENDATION
,P_RESUME_EXISTS
,dd(P_RESUME_LAST_UPDATED,I_RESUME_LAST_UPDATED)
,P_SECOND_PASSPORT_EXISTS
,P_STUDENT_STATUS
,P_WORK_SCHEDULE
,P_REHIRE_REASON
,P_SUFFIX
,dd(P_RECEIPT_OF_DEATH_CERT_DATE,I_RECEIPT_OF_DEATH_CERT_DATE)
,P_COORD_BEN_MED_PLN_NO
,P_COORD_BEN_NO_CVG_FLAG
,P_COORD_BEN_MED_EXT_ER
,P_COORD_BEN_MED_PL_NAME
,P_COORD_BEN_MED_INSR_CRR_NAME
,P_COORD_BEN_MED_INSR_CRR_IDENT
,dd(P_COORD_BEN_MED_CVG_STRT_DT,I_COORD_BEN_MED_CVG_STRT_DT)
,dd(P_COORD_BEN_MED_CVG_END_DT,I_COORD_BEN_MED_CVG_END_DT)
,P_USES_TOBACCO_FLAG
,dd(P_DPDNT_ADOPTION_DATE,I_DPDNT_ADOPTION_DATE)
,P_DPDNT_VLNTRY_SVCE_FLAG
,dd(P_ORIGINAL_DATE_OF_HIRE,I_ORIGINAL_DATE_OF_HIRE)
,dd(P_ADJUSTED_SVC_DATE,I_ADJUSTED_SVC_DATE)
,P_TOWN_OF_BIRTH
,P_REGION_OF_BIRTH
,P_COUNTRY_OF_BIRTH
,P_GLOBAL_PERSON_ID
,nd(P_PARTY_ID,I_PARTY_ID)
,P_NPW_NUMBER
,P_PERSON_USER_KEY
,P_USER_PERSON_TYPE
,P_LANGUAGE_CODE
,P_VENDOR_NAME
,P_CORRESPONDENCE_LANGUAGE
,P_BENEFIT_GROUP);
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
decode(l.pval004,cn,vn,vn,vh,l.pval004) p4,
l.pval004 d4,
decode(l.pval005,cn,vn,vn,vh,l.pval005) p5,
l.pval005 d5,
decode(l.pval006,cn,dn,vn,dh,d(l.pval006)) p6,
l.pval006 d6,
decode(l.pval007,cn,dn,vn,dh,d(l.pval007)) p7,
l.pval007 d7,
decode(l.pval008,cn,vn,vn,vh,l.pval008) p8,
l.pval008 d8,
decode(l.pval009,cn,vn,l.pval009) p9,
decode(l.pval010,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval010,'HOME_OFFICE',d(l.pval001),l.pval116)) p10,
l.pval010 d10,
decode(l.pval011,cn,vn,vn,vh,l.pval011) p11,
l.pval011 d11,
decode(l.pval012,cn,vn,vn,vh,l.pval012) p12,
l.pval012 d12,
decode(l.pval013,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval013,'MAR_STATUS',d(l.pval001),l.pval116)) p13,
l.pval013 d13,
decode(l.pval014,cn,vn,vn,vh,l.pval014) p14,
l.pval014 d14,
decode(l.pval015,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval015,'NATIONALITY',d(l.pval001),l.pval116)) p15,
l.pval015 d15,
decode(l.pval016,cn,vn,vn,vh,l.pval016) p16,
l.pval016 d16,
decode(l.pval017,cn,vn,vn,vh,l.pval017) p17,
l.pval017 d17,
decode(l.pval018,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval018,'REGISTERED_DISABLED',d(l.pval001),l.pval116)) p18,
l.pval018 d18,
decode(l.pval019,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval019,'SEX',d(l.pval001),l.pval116)) p19,
l.pval019 d19,
decode(l.pval020,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval020,'TITLE',d(l.pval001),l.pval116)) p20,
l.pval020 d20,
decode(l.pval021,cn,vn,vn,vh,l.pval021) p21,
l.pval021 d21,
decode(l.pval022,cn,vn,vn,vh,l.pval022) p22,
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
decode(l.pval053,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval053,'ETH_TYPE',d(l.pval001),l.pval116)) p53,
l.pval053 d53,
decode(l.pval054,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval054,'YES_NO',d(l.pval001),l.pval116)) p54,
l.pval054 d54,
decode(l.pval055,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval055,'YES_NO',d(l.pval001),l.pval116)) p55,
l.pval055 d55,
decode(l.pval056,cn,vn,vn,vh,l.pval056) p56,
l.pval056 d56,
decode(l.pval057,cn,vn,vn,vh,l.pval057) p57,
l.pval057 d57,
decode(l.pval058,cn,vn,vn,vh,l.pval058) p58,
l.pval058 d58,
decode(l.pval059,cn,vn,vn,vh,l.pval059) p59,
l.pval059 d59,
decode(l.pval060,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval060,'YES_NO',d(l.pval001),l.pval116)) p60,
l.pval060 d60,
decode(l.pval061,cn,vn,vn,vh,l.pval061) p61,
l.pval061 d61,
decode(l.pval062,cn,dn,vn,dh,d(l.pval062)) p62,
l.pval062 d62,
decode(l.pval063,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval063,'YES_NO',d(l.pval001),l.pval116)) p63,
l.pval063 d63,
decode(l.pval064,cn,dn,vn,dh,d(l.pval064)) p64,
l.pval064 d64,
decode(l.pval065,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval065,'BLOOD_TYPE',d(l.pval001),l.pval116)) p65,
l.pval065 d65,
decode(l.pval066,cn,vn,vn,vh,l.pval066) p66,
l.pval066 d66,
decode(l.pval067,cn,nn,vn,nh,n(l.pval067)) p67,
l.pval067 d67,
decode(l.pval068,cn,dn,vn,dh,d(l.pval068)) p68,
l.pval068 d68,
decode(l.pval069,cn,vn,vn,vh,l.pval069) p69,
l.pval069 d69,
decode(l.pval070,cn,vn,vn,vh,l.pval070) p70,
l.pval070 d70,
decode(l.pval071,cn,vn,vn,vh,l.pval071) p71,
l.pval071 d71,
decode(l.pval072,cn,dn,vn,dh,d(l.pval072)) p72,
l.pval072 d72,
decode(l.pval073,cn,vn,vn,vh,l.pval073) p73,
l.pval073 d73,
decode(l.pval074,cn,vn,vn,vh,l.pval074) p74,
l.pval074 d74,
decode(l.pval075,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval075,'YES_NO',d(l.pval001),l.pval116)) p75,
l.pval075 d75,
decode(l.pval076,cn,vn,vn,vh,l.pval076) p76,
l.pval076 d76,
decode(l.pval077,cn,dn,vn,dh,d(l.pval077)) p77,
l.pval077 d77,
decode(l.pval078,cn,vn,vn,vh,l.pval078) p78,
l.pval078 d78,
decode(l.pval079,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval079,'YES_NO',d(l.pval001),l.pval116)) p79,
l.pval079 d79,
decode(l.pval080,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval080,'YES_NO',d(l.pval001),l.pval116)) p80,
l.pval080 d80,
decode(l.pval081,cn,dn,vn,dh,d(l.pval081)) p81,
l.pval081 d81,
decode(l.pval082,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval082,'YES_NO',d(l.pval001),l.pval116)) p82,
l.pval082 d82,
decode(l.pval083,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval083,'STUDENT_STATUS',d(l.pval001),l.pval116)) p83,
l.pval083 d83,
decode(l.pval084,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval084,'WORK_SCHEDULE',d(l.pval001),l.pval116)) p84,
l.pval084 d84,
decode(l.pval085,cn,vn,vn,vh,l.pval085) p85,
l.pval085 d85,
decode(l.pval086,cn,vn,vn,vh,l.pval086) p86,
l.pval086 d86,
decode(l.pval087,cn,dn,vn,dh,d(l.pval087)) p87,
l.pval087 d87,
decode(l.pval088,cn,vn,vn,vh,l.pval088) p88,
l.pval088 d88,
decode(l.pval089,cn,vn,vn,vh,l.pval089) p89,
l.pval089 d89,
decode(l.pval090,cn,vn,vn,vh,l.pval090) p90,
l.pval090 d90,
decode(l.pval091,cn,vn,vn,vh,l.pval091) p91,
l.pval091 d91,
decode(l.pval092,cn,vn,vn,vh,l.pval092) p92,
l.pval092 d92,
decode(l.pval093,cn,vn,vn,vh,l.pval093) p93,
l.pval093 d93,
decode(l.pval094,cn,dn,vn,dh,d(l.pval094)) p94,
l.pval094 d94,
decode(l.pval095,cn,dn,vn,dh,d(l.pval095)) p95,
l.pval095 d95,
decode(l.pval096,cn,vn,vn,vh,l.pval096) p96,
l.pval096 d96,
decode(l.pval097,cn,dn,vn,dh,d(l.pval097)) p97,
l.pval097 d97,
decode(l.pval098,cn,vn,vn,vh,l.pval098) p98,
l.pval098 d98,
decode(l.pval099,cn,dn,vn,dh,d(l.pval099)) p99,
l.pval099 d99,
decode(l.pval100,cn,dn,vn,dh,d(l.pval100)) p100,
l.pval100 d100,
decode(l.pval101,cn,vn,vn,vh,l.pval101) p101,
l.pval101 d101,
decode(l.pval102,cn,vn,vn,vh,l.pval102) p102,
l.pval102 d102,
decode(l.pval103,cn,vn,vn,vh,l.pval103) p103,
l.pval103 d103,
decode(l.pval104,cn,vn,vn,vh,l.pval104) p104,
l.pval104 d104,
decode(l.pval105,cn,nn,vn,nh,n(l.pval105)) p105,
l.pval105 d105,
decode(l.pval106,cn,vn,vn,vh,l.pval106) p106,
l.pval106 d106,
decode(l.pval107,cn,dn,d(l.pval107)) p107,
decode(l.pval108,cn,dn,d(l.pval108)) p108,
l.pval109 p109,
l.pval110 p110,
l.pval111 p111,
l.pval112 p112,
l.pval113 p113,
decode(l.pval114,cn,vn,l.pval114) p114,
decode(l.pval115,cn,vn,vn,vh,l.pval115) p115,
l.pval115 d115,
decode(l.pval116,cn,vn,vn,vh,l.pval116) p116,
l.pval116 d116,
decode(l.pval117,cn,vn,vn,vh,l.pval117) p117,
l.pval117 d117,
decode(l.pval118,cn,vn,vn,vh,l.pval118) p118,
l.pval118 d118,
decode(l.pval119,cn,vn,vn,vh,l.pval119) p119,
l.pval119 d119
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_NAME_COMBINATION_WARNING boolean;
L_ASSIGN_PAYROLL_WARNING boolean;
L_ORIG_HIRE_WARNING boolean;
L_PERSON_ID number;
L_OBJECT_VERSION_NUMBER number;
L_PERSON_TYPE_ID number;
L_VENDOR_ID number;
L_CORRESPONDENCE_LANGUAGE varchar2(2000);
L_BENEFIT_GROUP_ID number;
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
if c.p114 is null then
L_PERSON_ID:=nn;
else
L_PERSON_ID := 
hr_pump_get.get_person_id
(P_PERSON_USER_KEY => c.p114);
end if;
--
if c.p114 is null or
c.p1 is null then
L_OBJECT_VERSION_NUMBER:=nn;
else
L_OBJECT_VERSION_NUMBER := 
hr_pump_get.GET_PER_OVN
(P_PERSON_USER_KEY => c.p114
,P_EFFECTIVE_DATE => c.p1);
end if;
--
if c.d115=cn or
c.d116=cn then
L_PERSON_TYPE_ID:=nn;
elsif c.d115 is null or
c.d116 is null then 
L_PERSON_TYPE_ID:=nh;
else
L_PERSON_TYPE_ID := 
hr_pump_get.get_person_type_id
(P_USER_PERSON_TYPE => c.p115
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_LANGUAGE_CODE => c.p116);
end if;
--
if c.d117=cn then
L_VENDOR_ID:=nn;
elsif c.d117 is null then 
L_VENDOR_ID:=nh;
else
L_VENDOR_ID := 
hr_pump_get.get_vendor_id
(P_VENDOR_NAME => c.p117);
end if;
--
if c.d118=cn then
L_CORRESPONDENCE_LANGUAGE:=vn;
elsif c.d118 is null then 
L_CORRESPONDENCE_LANGUAGE:=vh;
else
L_CORRESPONDENCE_LANGUAGE := 
hr_pump_get.GET_CORRESPONDENCE_LANGUAGE
(P_CORRESPONDENCE_LANGUAGE => c.p118);
end if;
--
if c.d119=cn then
L_BENEFIT_GROUP_ID:=nn;
elsif c.d119 is null then 
L_BENEFIT_GROUP_ID:=nh;
else
L_BENEFIT_GROUP_ID := 
hr_pump_get.get_benefit_group_id
(P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_BENEFIT_GROUP => c.p119);
end if;
--
hr_data_pump.api_trc_on;
HR_PERSON_API.UPDATE_GB_PERSON
(p_validate => l_validate
,P_EFFECTIVE_DATE => c.p1
,P_DATETRACK_UPDATE_MODE => c.p2
,P_PERSON_ID => L_PERSON_ID
,P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER
,P_PERSON_TYPE_ID => L_PERSON_TYPE_ID
,P_LAST_NAME => c.p3
,P_APPLICANT_NUMBER => c.p4
,P_COMMENTS => c.p5
,P_DATE_EMPLOYEE_DATA_VERIFIED => c.p6
,P_DATE_OF_BIRTH => c.p7
,P_EMAIL_ADDRESS => c.p8
,P_EMPLOYEE_NUMBER => c.p9
,P_EXPENSE_CHECK_SEND_TO_ADDRES => c.p10
,P_FIRST_NAME => c.p11
,P_KNOWN_AS => c.p12
,P_MARITAL_STATUS => c.p13
,P_MIDDLE_NAMES => c.p14
,P_NATIONALITY => c.p15
,P_NI_NUMBER => c.p16
,P_PREVIOUS_LAST_NAME => c.p17
,P_REGISTERED_DISABLED_FLAG => c.p18
,P_SEX => c.p19
,P_TITLE => c.p20
,P_VENDOR_ID => L_VENDOR_ID
,P_WORK_TELEPHONE => c.p21
,P_ATTRIBUTE_CATEGORY => c.p22
,P_ATTRIBUTE1 => c.p23
,P_ATTRIBUTE2 => c.p24
,P_ATTRIBUTE3 => c.p25
,P_ATTRIBUTE4 => c.p26
,P_ATTRIBUTE5 => c.p27
,P_ATTRIBUTE6 => c.p28
,P_ATTRIBUTE7 => c.p29
,P_ATTRIBUTE8 => c.p30
,P_ATTRIBUTE9 => c.p31
,P_ATTRIBUTE10 => c.p32
,P_ATTRIBUTE11 => c.p33
,P_ATTRIBUTE12 => c.p34
,P_ATTRIBUTE13 => c.p35
,P_ATTRIBUTE14 => c.p36
,P_ATTRIBUTE15 => c.p37
,P_ATTRIBUTE16 => c.p38
,P_ATTRIBUTE17 => c.p39
,P_ATTRIBUTE18 => c.p40
,P_ATTRIBUTE19 => c.p41
,P_ATTRIBUTE20 => c.p42
,P_ATTRIBUTE21 => c.p43
,P_ATTRIBUTE22 => c.p44
,P_ATTRIBUTE23 => c.p45
,P_ATTRIBUTE24 => c.p46
,P_ATTRIBUTE25 => c.p47
,P_ATTRIBUTE26 => c.p48
,P_ATTRIBUTE27 => c.p49
,P_ATTRIBUTE28 => c.p50
,P_ATTRIBUTE29 => c.p51
,P_ATTRIBUTE30 => c.p52
,P_ETHNIC_ORIGIN => c.p53
,P_DIRECTOR => c.p54
,P_PENSIONER => c.p55
,P_WORK_PERMIT_NUMBER => c.p56
,P_ADDL_PENSION_YEARS => c.p57
,P_ADDL_PENSION_MONTHS => c.p58
,P_ADDL_PENSION_DAYS => c.p59
,P_NI_MULTIPLE_ASG => c.p60
,P_PAYE_AGGREGATE_ASSIGNMENT => c.p61
,P_DATE_OF_DEATH => c.p62
,P_BACKGROUND_CHECK_STATUS => c.p63
,P_BACKGROUND_DATE_CHECK => c.p64
,P_BLOOD_TYPE => c.p65
,P_CORRESPONDENCE_LANGUAGE => L_CORRESPONDENCE_LANGUAGE
,P_FAST_PATH_EMPLOYEE => c.p66
,P_FTE_CAPACITY => c.p67
,P_HOLD_APPLICANT_DATE_UNTIL => c.p68
,P_HONORS => c.p69
,P_INTERNAL_LOCATION => c.p70
,P_LAST_MEDICAL_TEST_BY => c.p71
,P_LAST_MEDICAL_TEST_DATE => c.p72
,P_MAILSTOP => c.p73
,P_OFFICE_NUMBER => c.p74
,P_ON_MILITARY_SERVICE => c.p75
,P_PRE_NAME_ADJUNCT => c.p76
,P_PROJECTED_START_DATE => c.p77
,P_REHIRE_AUTHORIZOR => c.p78
,P_REHIRE_RECOMMENDATION => c.p79
,P_RESUME_EXISTS => c.p80
,P_RESUME_LAST_UPDATED => c.p81
,P_SECOND_PASSPORT_EXISTS => c.p82
,P_STUDENT_STATUS => c.p83
,P_WORK_SCHEDULE => c.p84
,P_REHIRE_REASON => c.p85
,P_SUFFIX => c.p86
,P_BENEFIT_GROUP_ID => L_BENEFIT_GROUP_ID
,P_RECEIPT_OF_DEATH_CERT_DATE => c.p87
,P_COORD_BEN_MED_PLN_NO => c.p88
,P_COORD_BEN_NO_CVG_FLAG => c.p89
,P_COORD_BEN_MED_EXT_ER => c.p90
,P_COORD_BEN_MED_PL_NAME => c.p91
,P_COORD_BEN_MED_INSR_CRR_NAME => c.p92
,P_COORD_BEN_MED_INSR_CRR_IDENT => c.p93
,P_COORD_BEN_MED_CVG_STRT_DT => c.p94
,P_COORD_BEN_MED_CVG_END_DT => c.p95
,P_USES_TOBACCO_FLAG => c.p96
,P_DPDNT_ADOPTION_DATE => c.p97
,P_DPDNT_VLNTRY_SVCE_FLAG => c.p98
,P_ORIGINAL_DATE_OF_HIRE => c.p99
,P_ADJUSTED_SVC_DATE => c.p100
,P_TOWN_OF_BIRTH => c.p101
,P_REGION_OF_BIRTH => c.p102
,P_COUNTRY_OF_BIRTH => c.p103
,P_GLOBAL_PERSON_ID => c.p104
,P_PARTY_ID => c.p105
,P_NPW_NUMBER => c.p106
,P_EFFECTIVE_START_DATE => c.p107
,P_EFFECTIVE_END_DATE => c.p108
,P_FULL_NAME => c.p109
,P_COMMENT_ID => c.p110
,P_NAME_COMBINATION_WARNING => L_NAME_COMBINATION_WARNING
,P_ASSIGN_PAYROLL_WARNING => L_ASSIGN_PAYROLL_WARNING
,P_ORIG_HIRE_WARNING => L_ORIG_HIRE_WARNING);
hr_data_pump.api_trc_off;
--
if L_NAME_COMBINATION_WARNING then
c.p111 := 'TRUE';
else
c.p111 := 'FALSE';
end if;
--
if L_ASSIGN_PAYROLL_WARNING then
c.p112 := 'TRUE';
else
c.p112 := 'FALSE';
end if;
--
if L_ORIG_HIRE_WARNING then
c.p113 := 'TRUE';
else
c.p113 := 'FALSE';
end if;
--
update hr_pump_batch_lines l set
l.pval009 = decode(c.p9,null,cn,c.p9),
l.pval107 = decode(c.p107,null,cn,dc(c.p107)),
l.pval108 = decode(c.p108,null,cn,dc(c.p108)),
l.pval109 = decode(c.p109,null,cn,c.p109),
l.pval110 = decode(c.p110,null,cn,c.p110),
l.pval111 = decode(c.p111,null,cn,c.p111),
l.pval112 = decode(c.p112,null,cn,c.p112),
l.pval113 = decode(c.p113,null,cn,c.p113)
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
end hrdpp_UPDATE_GB_PERSON;

/
