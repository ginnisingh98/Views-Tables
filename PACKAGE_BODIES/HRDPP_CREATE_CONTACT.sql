--------------------------------------------------------
--  DDL for Package Body HRDPP_CREATE_CONTACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_CREATE_CONTACT" as
/*
 * Generated by hr_pump_meta_mapper at: 2018/06/16 10:06:06
 * Generated for API: HR_CONTACT_REL_API.CREATE_CONTACT
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
,P_START_DATE in date
,P_CONTACT_TYPE in varchar2
,P_CTR_COMMENTS in varchar2 default null
,P_PRIMARY_CONTACT_FLAG in varchar2 default null
,P_DATE_START in date default null
,P_DATE_END in date default null
,P_RLTD_PER_RSDS_W_DSGNTR_FLAG in varchar2 default null
,P_PERSONAL_FLAG in varchar2 default null
,P_SEQUENCE_NUMBER in number default null
,P_CONT_ATTRIBUTE_CATEGORY in varchar2 default null
,P_CONT_ATTRIBUTE1 in varchar2 default null
,P_CONT_ATTRIBUTE2 in varchar2 default null
,P_CONT_ATTRIBUTE3 in varchar2 default null
,P_CONT_ATTRIBUTE4 in varchar2 default null
,P_CONT_ATTRIBUTE5 in varchar2 default null
,P_CONT_ATTRIBUTE6 in varchar2 default null
,P_CONT_ATTRIBUTE7 in varchar2 default null
,P_CONT_ATTRIBUTE8 in varchar2 default null
,P_CONT_ATTRIBUTE9 in varchar2 default null
,P_CONT_ATTRIBUTE10 in varchar2 default null
,P_CONT_ATTRIBUTE11 in varchar2 default null
,P_CONT_ATTRIBUTE12 in varchar2 default null
,P_CONT_ATTRIBUTE13 in varchar2 default null
,P_CONT_ATTRIBUTE14 in varchar2 default null
,P_CONT_ATTRIBUTE15 in varchar2 default null
,P_CONT_ATTRIBUTE16 in varchar2 default null
,P_CONT_ATTRIBUTE17 in varchar2 default null
,P_CONT_ATTRIBUTE18 in varchar2 default null
,P_CONT_ATTRIBUTE19 in varchar2 default null
,P_CONT_ATTRIBUTE20 in varchar2 default null
,P_CONT_INFORMATION_CATEGORY in varchar2 default null
,P_CONT_INFORMATION1 in varchar2 default null
,P_CONT_INFORMATION2 in varchar2 default null
,P_CONT_INFORMATION3 in varchar2 default null
,P_CONT_INFORMATION4 in varchar2 default null
,P_CONT_INFORMATION5 in varchar2 default null
,P_CONT_INFORMATION6 in varchar2 default null
,P_CONT_INFORMATION7 in varchar2 default null
,P_CONT_INFORMATION8 in varchar2 default null
,P_CONT_INFORMATION9 in varchar2 default null
,P_CONT_INFORMATION10 in varchar2 default null
,P_CONT_INFORMATION11 in varchar2 default null
,P_CONT_INFORMATION12 in varchar2 default null
,P_CONT_INFORMATION13 in varchar2 default null
,P_CONT_INFORMATION14 in varchar2 default null
,P_CONT_INFORMATION15 in varchar2 default null
,P_CONT_INFORMATION16 in varchar2 default null
,P_CONT_INFORMATION17 in varchar2 default null
,P_CONT_INFORMATION18 in varchar2 default null
,P_CONT_INFORMATION19 in varchar2 default null
,P_CONT_INFORMATION20 in varchar2 default null
,P_THIRD_PARTY_PAY_FLAG in varchar2 default null
,P_BONDHOLDER_FLAG in varchar2 default null
,P_DEPENDENT_FLAG in varchar2 default null
,P_BENEFICIARY_FLAG in varchar2 default null
,P_LAST_NAME in varchar2 default null
,P_SEX in varchar2 default null
,P_PER_COMMENTS in varchar2 default null
,P_DATE_OF_BIRTH in date default null
,P_EMAIL_ADDRESS in varchar2 default null
,P_FIRST_NAME in varchar2 default null
,P_KNOWN_AS in varchar2 default null
,P_MARITAL_STATUS in varchar2 default null
,P_MIDDLE_NAMES in varchar2 default null
,P_NATIONALITY in varchar2 default null
,P_NATIONAL_IDENTIFIER in varchar2 default null
,P_PREVIOUS_LAST_NAME in varchar2 default null
,P_REGISTERED_DISABLED_FLAG in varchar2 default null
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
,P_CORRESPONDENCE_LANGUAGE in varchar2 default null
,P_HONORS in varchar2 default null
,P_PRE_NAME_ADJUNCT in varchar2 default null
,P_SUFFIX in varchar2 default null
,P_CREATE_MIRROR_FLAG in varchar2 default null
,P_MIRROR_TYPE in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE_CAT in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE1 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE2 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE3 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE4 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE5 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE6 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE7 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE8 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE9 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE10 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE11 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE12 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE13 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE14 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE15 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE16 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE17 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE18 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE19 in varchar2 default null
,P_MIRROR_CONT_ATTRIBUTE20 in varchar2 default null
,P_MIRROR_CONT_INFORMATION_CAT in varchar2 default null
,P_MIRROR_CONT_INFORMATION1 in varchar2 default null
,P_MIRROR_CONT_INFORMATION2 in varchar2 default null
,P_MIRROR_CONT_INFORMATION3 in varchar2 default null
,P_MIRROR_CONT_INFORMATION4 in varchar2 default null
,P_MIRROR_CONT_INFORMATION5 in varchar2 default null
,P_MIRROR_CONT_INFORMATION6 in varchar2 default null
,P_MIRROR_CONT_INFORMATION7 in varchar2 default null
,P_MIRROR_CONT_INFORMATION8 in varchar2 default null
,P_MIRROR_CONT_INFORMATION9 in varchar2 default null
,P_MIRROR_CONT_INFORMATION10 in varchar2 default null
,P_MIRROR_CONT_INFORMATION11 in varchar2 default null
,P_MIRROR_CONT_INFORMATION12 in varchar2 default null
,P_MIRROR_CONT_INFORMATION13 in varchar2 default null
,P_MIRROR_CONT_INFORMATION14 in varchar2 default null
,P_MIRROR_CONT_INFORMATION15 in varchar2 default null
,P_MIRROR_CONT_INFORMATION16 in varchar2 default null
,P_MIRROR_CONT_INFORMATION17 in varchar2 default null
,P_MIRROR_CONT_INFORMATION18 in varchar2 default null
,P_MIRROR_CONT_INFORMATION19 in varchar2 default null
,P_MIRROR_CONT_INFORMATION20 in varchar2 default null
,P_PER_PERSON_USER_KEY in varchar2
,P_PERSON_USER_KEY in varchar2
,P_CONTACT_PERSON_USER_KEY in varchar2 default null
,P_START_LIFE_REASON in varchar2 default null
,P_END_LIFE_REASON in varchar2 default null
,P_USER_PERSON_TYPE in varchar2 default null
,P_LANGUAGE_CODE in varchar2 default null) is
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
,pval130
,pval131
,pval132
,pval133
,pval134
,pval135
,pval136
,pval137
,pval138
,pval139
,pval140
,pval141
,pval142
,pval143
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
,pval164
,pval165
,pval166
,pval167
,pval168
,pval169
,pval170
,pval171
,pval172
,pval173
,pval174
,pval175
,pval176
,pval177
,pval178
,pval179
,pval180
,pval183
,pval191
,pval192
,pval193
,pval194
,pval195
,pval196)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,1238
,'U'
,p_user_sequence
,p_link_value
,dc(P_START_DATE)
,P_CONTACT_TYPE
,P_CTR_COMMENTS
,P_PRIMARY_CONTACT_FLAG
,dc(P_DATE_START)
,dc(P_DATE_END)
,P_RLTD_PER_RSDS_W_DSGNTR_FLAG
,P_PERSONAL_FLAG
,P_SEQUENCE_NUMBER
,P_CONT_ATTRIBUTE_CATEGORY
,P_CONT_ATTRIBUTE1
,P_CONT_ATTRIBUTE2
,P_CONT_ATTRIBUTE3
,P_CONT_ATTRIBUTE4
,P_CONT_ATTRIBUTE5
,P_CONT_ATTRIBUTE6
,P_CONT_ATTRIBUTE7
,P_CONT_ATTRIBUTE8
,P_CONT_ATTRIBUTE9
,P_CONT_ATTRIBUTE10
,P_CONT_ATTRIBUTE11
,P_CONT_ATTRIBUTE12
,P_CONT_ATTRIBUTE13
,P_CONT_ATTRIBUTE14
,P_CONT_ATTRIBUTE15
,P_CONT_ATTRIBUTE16
,P_CONT_ATTRIBUTE17
,P_CONT_ATTRIBUTE18
,P_CONT_ATTRIBUTE19
,P_CONT_ATTRIBUTE20
,P_CONT_INFORMATION_CATEGORY
,P_CONT_INFORMATION1
,P_CONT_INFORMATION2
,P_CONT_INFORMATION3
,P_CONT_INFORMATION4
,P_CONT_INFORMATION5
,P_CONT_INFORMATION6
,P_CONT_INFORMATION7
,P_CONT_INFORMATION8
,P_CONT_INFORMATION9
,P_CONT_INFORMATION10
,P_CONT_INFORMATION11
,P_CONT_INFORMATION12
,P_CONT_INFORMATION13
,P_CONT_INFORMATION14
,P_CONT_INFORMATION15
,P_CONT_INFORMATION16
,P_CONT_INFORMATION17
,P_CONT_INFORMATION18
,P_CONT_INFORMATION19
,P_CONT_INFORMATION20
,P_THIRD_PARTY_PAY_FLAG
,P_BONDHOLDER_FLAG
,P_DEPENDENT_FLAG
,P_BENEFICIARY_FLAG
,P_LAST_NAME
,P_SEX
,P_PER_COMMENTS
,dc(P_DATE_OF_BIRTH)
,P_EMAIL_ADDRESS
,P_FIRST_NAME
,P_KNOWN_AS
,P_MARITAL_STATUS
,P_MIDDLE_NAMES
,P_NATIONALITY
,P_NATIONAL_IDENTIFIER
,P_PREVIOUS_LAST_NAME
,P_REGISTERED_DISABLED_FLAG
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
,P_CORRESPONDENCE_LANGUAGE
,P_HONORS
,P_PRE_NAME_ADJUNCT
,P_SUFFIX
,P_CREATE_MIRROR_FLAG
,P_MIRROR_TYPE
,P_MIRROR_CONT_ATTRIBUTE_CAT
,P_MIRROR_CONT_ATTRIBUTE1
,P_MIRROR_CONT_ATTRIBUTE2
,P_MIRROR_CONT_ATTRIBUTE3
,P_MIRROR_CONT_ATTRIBUTE4
,P_MIRROR_CONT_ATTRIBUTE5
,P_MIRROR_CONT_ATTRIBUTE6
,P_MIRROR_CONT_ATTRIBUTE7
,P_MIRROR_CONT_ATTRIBUTE8
,P_MIRROR_CONT_ATTRIBUTE9
,P_MIRROR_CONT_ATTRIBUTE10
,P_MIRROR_CONT_ATTRIBUTE11
,P_MIRROR_CONT_ATTRIBUTE12
,P_MIRROR_CONT_ATTRIBUTE13
,P_MIRROR_CONT_ATTRIBUTE14
,P_MIRROR_CONT_ATTRIBUTE15
,P_MIRROR_CONT_ATTRIBUTE16
,P_MIRROR_CONT_ATTRIBUTE17
,P_MIRROR_CONT_ATTRIBUTE18
,P_MIRROR_CONT_ATTRIBUTE19
,P_MIRROR_CONT_ATTRIBUTE20
,P_MIRROR_CONT_INFORMATION_CAT
,P_MIRROR_CONT_INFORMATION1
,P_MIRROR_CONT_INFORMATION2
,P_MIRROR_CONT_INFORMATION3
,P_MIRROR_CONT_INFORMATION4
,P_MIRROR_CONT_INFORMATION5
,P_MIRROR_CONT_INFORMATION6
,P_MIRROR_CONT_INFORMATION7
,P_MIRROR_CONT_INFORMATION8
,P_MIRROR_CONT_INFORMATION9
,P_MIRROR_CONT_INFORMATION10
,P_MIRROR_CONT_INFORMATION11
,P_MIRROR_CONT_INFORMATION12
,P_MIRROR_CONT_INFORMATION13
,P_MIRROR_CONT_INFORMATION14
,P_MIRROR_CONT_INFORMATION15
,P_MIRROR_CONT_INFORMATION16
,P_MIRROR_CONT_INFORMATION17
,P_MIRROR_CONT_INFORMATION18
,P_MIRROR_CONT_INFORMATION19
,P_MIRROR_CONT_INFORMATION20
,P_PER_PERSON_USER_KEY
,P_PERSON_USER_KEY
,P_CONTACT_PERSON_USER_KEY
,P_START_LIFE_REASON
,P_END_LIFE_REASON
,P_USER_PERSON_TYPE
,P_LANGUAGE_CODE);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,dn,d(l.pval001)) p1,
decode(l.pval002,cn,vn,
 hr_pump_get.gl(l.pval002,'CONTACT',d(l.pval001),l.pval196)) p2,
decode(l.pval003,cn,vn,vn,vn,l.pval003) p3,
l.pval003 d3,
decode(l.pval004,cn,vn,vn,'N',
 hr_pump_get.gl(l.pval004,'YES_NO',d(l.pval001),l.pval196)) p4,
l.pval004 d4,
decode(l.pval005,cn,dn,vn,dn,d(l.pval005)) p5,
l.pval005 d5,
decode(l.pval006,cn,dn,vn,dn,d(l.pval006)) p6,
l.pval006 d6,
decode(l.pval007,cn,vn,vn,'N',
 hr_pump_get.gl(l.pval007,'YES_NO',d(l.pval001),l.pval196)) p7,
l.pval007 d7,
decode(l.pval008,cn,vn,vn,'N',
 hr_pump_get.gl(l.pval008,'YES_NO',d(l.pval001),l.pval196)) p8,
l.pval008 d8,
decode(l.pval009,cn,nn,vn,nn,n(l.pval009)) p9,
l.pval009 d9,
decode(l.pval010,cn,vn,vn,vn,l.pval010) p10,
l.pval010 d10,
decode(l.pval011,cn,vn,vn,vn,l.pval011) p11,
l.pval011 d11,
decode(l.pval012,cn,vn,vn,vn,l.pval012) p12,
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
decode(l.pval018,cn,vn,vn,vn,l.pval018) p18,
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
decode(l.pval052,cn,vn,vn,'N',
 hr_pump_get.gl(l.pval052,'YES_NO',d(l.pval001),l.pval196)) p52,
l.pval052 d52,
decode(l.pval053,cn,vn,vn,'N',
 hr_pump_get.gl(l.pval053,'YES_NO',d(l.pval001),l.pval196)) p53,
l.pval053 d53,
decode(l.pval054,cn,vn,vn,'N',
 hr_pump_get.gl(l.pval054,'YES_NO',d(l.pval001),l.pval196)) p54,
l.pval054 d54,
decode(l.pval055,cn,vn,vn,'N',
 hr_pump_get.gl(l.pval055,'YES_NO',d(l.pval001),l.pval196)) p55,
l.pval055 d55,
decode(l.pval056,cn,vn,vn,vn,l.pval056) p56,
l.pval056 d56,
decode(l.pval057,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval057,'SEX',d(l.pval001),l.pval196)) p57,
l.pval057 d57,
decode(l.pval058,cn,vn,vn,vn,l.pval058) p58,
l.pval058 d58,
decode(l.pval059,cn,dn,vn,dn,d(l.pval059)) p59,
l.pval059 d59,
decode(l.pval060,cn,vn,vn,vn,l.pval060) p60,
l.pval060 d60,
decode(l.pval061,cn,vn,vn,vn,l.pval061) p61,
l.pval061 d61,
decode(l.pval062,cn,vn,vn,vn,l.pval062) p62,
l.pval062 d62,
decode(l.pval063,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval063,'MAR_STATUS',d(l.pval001),l.pval196)) p63,
l.pval063 d63,
decode(l.pval064,cn,vn,vn,vn,l.pval064) p64,
l.pval064 d64,
decode(l.pval065,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval065,'NATIONALITY',d(l.pval001),l.pval196)) p65,
l.pval065 d65,
decode(l.pval066,cn,vn,vn,vn,l.pval066) p66,
l.pval066 d66,
decode(l.pval067,cn,vn,vn,vn,l.pval067) p67,
l.pval067 d67,
decode(l.pval068,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval068,'REGISTERED_DISABLED',d(l.pval001),l.pval196)) p68,
l.pval068 d68,
decode(l.pval069,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval069,'TITLE',d(l.pval001),l.pval196)) p69,
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
decode(l.pval124,cn,vn,vn,vn,l.pval124) p124,
l.pval124 d124,
decode(l.pval125,cn,vn,vn,vn,l.pval125) p125,
l.pval125 d125,
decode(l.pval126,cn,vn,vn,vn,l.pval126) p126,
l.pval126 d126,
decode(l.pval127,cn,vn,vn,vn,l.pval127) p127,
l.pval127 d127,
decode(l.pval128,cn,vn,vn,vn,l.pval128) p128,
l.pval128 d128,
decode(l.pval129,cn,vn,vn,vn,l.pval129) p129,
l.pval129 d129,
decode(l.pval130,cn,vn,vn,vn,l.pval130) p130,
l.pval130 d130,
decode(l.pval131,cn,vn,vn,vn,l.pval131) p131,
l.pval131 d131,
decode(l.pval132,cn,vn,vn,vn,l.pval132) p132,
l.pval132 d132,
decode(l.pval133,cn,vn,vn,vn,l.pval133) p133,
l.pval133 d133,
decode(l.pval134,cn,vn,vn,vn,l.pval134) p134,
l.pval134 d134,
decode(l.pval135,cn,vn,vn,vn,l.pval135) p135,
l.pval135 d135,
decode(l.pval136,cn,vn,vn,vn,l.pval136) p136,
l.pval136 d136,
decode(l.pval137,cn,vn,vn,'N',
 hr_pump_get.gl(l.pval137,'YES_NO',d(l.pval001),l.pval196)) p137,
l.pval137 d137,
decode(l.pval138,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval138,'CONTACT_TYPE',d(l.pval001),l.pval196)) p138,
l.pval138 d138,
decode(l.pval139,cn,vn,vn,vn,l.pval139) p139,
l.pval139 d139,
decode(l.pval140,cn,vn,vn,vn,l.pval140) p140,
l.pval140 d140,
decode(l.pval141,cn,vn,vn,vn,l.pval141) p141,
l.pval141 d141,
decode(l.pval142,cn,vn,vn,vn,l.pval142) p142,
l.pval142 d142,
decode(l.pval143,cn,vn,vn,vn,l.pval143) p143,
l.pval143 d143,
decode(l.pval144,cn,vn,vn,vn,l.pval144) p144,
l.pval144 d144,
decode(l.pval145,cn,vn,vn,vn,l.pval145) p145,
l.pval145 d145,
decode(l.pval146,cn,vn,vn,vn,l.pval146) p146,
l.pval146 d146,
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
l.pval164 d164,
decode(l.pval165,cn,vn,vn,vn,l.pval165) p165,
l.pval165 d165,
decode(l.pval166,cn,vn,vn,vn,l.pval166) p166,
l.pval166 d166,
decode(l.pval167,cn,vn,vn,vn,l.pval167) p167,
l.pval167 d167,
decode(l.pval168,cn,vn,vn,vn,l.pval168) p168,
l.pval168 d168,
decode(l.pval169,cn,vn,vn,vn,l.pval169) p169,
l.pval169 d169,
decode(l.pval170,cn,vn,vn,vn,l.pval170) p170,
l.pval170 d170,
decode(l.pval171,cn,vn,vn,vn,l.pval171) p171,
l.pval171 d171,
decode(l.pval172,cn,vn,vn,vn,l.pval172) p172,
l.pval172 d172,
decode(l.pval173,cn,vn,vn,vn,l.pval173) p173,
l.pval173 d173,
decode(l.pval174,cn,vn,vn,vn,l.pval174) p174,
l.pval174 d174,
decode(l.pval175,cn,vn,vn,vn,l.pval175) p175,
l.pval175 d175,
decode(l.pval176,cn,vn,vn,vn,l.pval176) p176,
l.pval176 d176,
decode(l.pval177,cn,vn,vn,vn,l.pval177) p177,
l.pval177 d177,
decode(l.pval178,cn,vn,vn,vn,l.pval178) p178,
l.pval178 d178,
decode(l.pval179,cn,vn,vn,vn,l.pval179) p179,
l.pval179 d179,
decode(l.pval180,cn,vn,vn,vn,l.pval180) p180,
l.pval180 d180,
l.pval181 p181,
l.pval182 p182,
l.pval183 p183,
l.pval184 p184,
decode(l.pval185,cn,dn,d(l.pval185)) p185,
decode(l.pval186,cn,dn,d(l.pval186)) p186,
l.pval187 p187,
l.pval188 p188,
l.pval189 p189,
l.pval190 p190,
decode(l.pval191,cn,vn,l.pval191) p191,
decode(l.pval192,cn,vn,vn,vn,l.pval192) p192,
l.pval192 d192,
decode(l.pval193,cn,vn,vn,vn,l.pval193) p193,
l.pval193 d193,
decode(l.pval194,cn,vn,vn,vn,l.pval194) p194,
l.pval194 d194,
decode(l.pval195,cn,vn,vn,vn,l.pval195) p195,
l.pval195 d195,
decode(l.pval196,cn,vn,vn,vn,l.pval196) p196,
l.pval196 d196
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_PER_PERSON_ID number;
L_NAME_COMBINATION_WARNING boolean;
L_ORIG_HIRE_WARNING boolean;
L_PERSON_ID number;
L_CONTACT_PERSON_ID number;
L_START_LIFE_REASON_ID number;
L_END_LIFE_REASON_ID number;
L_PERSON_TYPE_ID number;
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
if c.p191 is null then
L_PERSON_ID:=nn;
else
L_PERSON_ID := 
hr_pump_get.get_person_id
(P_PERSON_USER_KEY => c.p191);
end if;
--
if c.p192 is null then
L_CONTACT_PERSON_ID:=nn;
else
L_CONTACT_PERSON_ID := 
hr_pump_get.get_contact_person_id
(P_CONTACT_PERSON_USER_KEY => c.p192);
end if;
--
if c.p1 is null or
c.p193 is null then
L_START_LIFE_REASON_ID:=nn;
else
L_START_LIFE_REASON_ID := 
hr_pump_get.get_start_life_reason_id
(P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1
,P_START_LIFE_REASON => c.p193);
end if;
--
if c.p1 is null or
c.p194 is null then
L_END_LIFE_REASON_ID:=nn;
else
L_END_LIFE_REASON_ID := 
hr_pump_get.get_end_life_reason_id
(P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1
,P_END_LIFE_REASON => c.p194);
end if;
--
if c.p195 is null or
c.p196 is null then
L_PERSON_TYPE_ID:=nn;
else
L_PERSON_TYPE_ID := 
hr_pump_get.get_person_type_id
(P_USER_PERSON_TYPE => c.p195
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_LANGUAGE_CODE => c.p196);
end if;
--
hr_data_pump.api_trc_on;
HR_CONTACT_REL_API.CREATE_CONTACT
(p_validate => l_validate
,P_START_DATE => c.p1
,p_business_group_id => p_business_group_id
,P_PERSON_ID => L_PERSON_ID
,P_CONTACT_PERSON_ID => L_CONTACT_PERSON_ID
,P_CONTACT_TYPE => c.p2
,P_CTR_COMMENTS => c.p3
,P_PRIMARY_CONTACT_FLAG => c.p4
,P_DATE_START => c.p5
,P_START_LIFE_REASON_ID => L_START_LIFE_REASON_ID
,P_DATE_END => c.p6
,P_END_LIFE_REASON_ID => L_END_LIFE_REASON_ID
,P_RLTD_PER_RSDS_W_DSGNTR_FLAG => c.p7
,P_PERSONAL_FLAG => c.p8
,P_SEQUENCE_NUMBER => c.p9
,P_CONT_ATTRIBUTE_CATEGORY => c.p10
,P_CONT_ATTRIBUTE1 => c.p11
,P_CONT_ATTRIBUTE2 => c.p12
,P_CONT_ATTRIBUTE3 => c.p13
,P_CONT_ATTRIBUTE4 => c.p14
,P_CONT_ATTRIBUTE5 => c.p15
,P_CONT_ATTRIBUTE6 => c.p16
,P_CONT_ATTRIBUTE7 => c.p17
,P_CONT_ATTRIBUTE8 => c.p18
,P_CONT_ATTRIBUTE9 => c.p19
,P_CONT_ATTRIBUTE10 => c.p20
,P_CONT_ATTRIBUTE11 => c.p21
,P_CONT_ATTRIBUTE12 => c.p22
,P_CONT_ATTRIBUTE13 => c.p23
,P_CONT_ATTRIBUTE14 => c.p24
,P_CONT_ATTRIBUTE15 => c.p25
,P_CONT_ATTRIBUTE16 => c.p26
,P_CONT_ATTRIBUTE17 => c.p27
,P_CONT_ATTRIBUTE18 => c.p28
,P_CONT_ATTRIBUTE19 => c.p29
,P_CONT_ATTRIBUTE20 => c.p30
,P_CONT_INFORMATION_CATEGORY => c.p31
,P_CONT_INFORMATION1 => c.p32
,P_CONT_INFORMATION2 => c.p33
,P_CONT_INFORMATION3 => c.p34
,P_CONT_INFORMATION4 => c.p35
,P_CONT_INFORMATION5 => c.p36
,P_CONT_INFORMATION6 => c.p37
,P_CONT_INFORMATION7 => c.p38
,P_CONT_INFORMATION8 => c.p39
,P_CONT_INFORMATION9 => c.p40
,P_CONT_INFORMATION10 => c.p41
,P_CONT_INFORMATION11 => c.p42
,P_CONT_INFORMATION12 => c.p43
,P_CONT_INFORMATION13 => c.p44
,P_CONT_INFORMATION14 => c.p45
,P_CONT_INFORMATION15 => c.p46
,P_CONT_INFORMATION16 => c.p47
,P_CONT_INFORMATION17 => c.p48
,P_CONT_INFORMATION18 => c.p49
,P_CONT_INFORMATION19 => c.p50
,P_CONT_INFORMATION20 => c.p51
,P_THIRD_PARTY_PAY_FLAG => c.p52
,P_BONDHOLDER_FLAG => c.p53
,P_DEPENDENT_FLAG => c.p54
,P_BENEFICIARY_FLAG => c.p55
,P_LAST_NAME => c.p56
,P_SEX => c.p57
,P_PERSON_TYPE_ID => L_PERSON_TYPE_ID
,P_PER_COMMENTS => c.p58
,P_DATE_OF_BIRTH => c.p59
,P_EMAIL_ADDRESS => c.p60
,P_FIRST_NAME => c.p61
,P_KNOWN_AS => c.p62
,P_MARITAL_STATUS => c.p63
,P_MIDDLE_NAMES => c.p64
,P_NATIONALITY => c.p65
,P_NATIONAL_IDENTIFIER => c.p66
,P_PREVIOUS_LAST_NAME => c.p67
,P_REGISTERED_DISABLED_FLAG => c.p68
,P_TITLE => c.p69
,P_WORK_TELEPHONE => c.p70
,P_ATTRIBUTE_CATEGORY => c.p71
,P_ATTRIBUTE1 => c.p72
,P_ATTRIBUTE2 => c.p73
,P_ATTRIBUTE3 => c.p74
,P_ATTRIBUTE4 => c.p75
,P_ATTRIBUTE5 => c.p76
,P_ATTRIBUTE6 => c.p77
,P_ATTRIBUTE7 => c.p78
,P_ATTRIBUTE8 => c.p79
,P_ATTRIBUTE9 => c.p80
,P_ATTRIBUTE10 => c.p81
,P_ATTRIBUTE11 => c.p82
,P_ATTRIBUTE12 => c.p83
,P_ATTRIBUTE13 => c.p84
,P_ATTRIBUTE14 => c.p85
,P_ATTRIBUTE15 => c.p86
,P_ATTRIBUTE16 => c.p87
,P_ATTRIBUTE17 => c.p88
,P_ATTRIBUTE18 => c.p89
,P_ATTRIBUTE19 => c.p90
,P_ATTRIBUTE20 => c.p91
,P_ATTRIBUTE21 => c.p92
,P_ATTRIBUTE22 => c.p93
,P_ATTRIBUTE23 => c.p94
,P_ATTRIBUTE24 => c.p95
,P_ATTRIBUTE25 => c.p96
,P_ATTRIBUTE26 => c.p97
,P_ATTRIBUTE27 => c.p98
,P_ATTRIBUTE28 => c.p99
,P_ATTRIBUTE29 => c.p100
,P_ATTRIBUTE30 => c.p101
,P_PER_INFORMATION_CATEGORY => c.p102
,P_PER_INFORMATION1 => c.p103
,P_PER_INFORMATION2 => c.p104
,P_PER_INFORMATION3 => c.p105
,P_PER_INFORMATION4 => c.p106
,P_PER_INFORMATION5 => c.p107
,P_PER_INFORMATION6 => c.p108
,P_PER_INFORMATION7 => c.p109
,P_PER_INFORMATION8 => c.p110
,P_PER_INFORMATION9 => c.p111
,P_PER_INFORMATION10 => c.p112
,P_PER_INFORMATION11 => c.p113
,P_PER_INFORMATION12 => c.p114
,P_PER_INFORMATION13 => c.p115
,P_PER_INFORMATION14 => c.p116
,P_PER_INFORMATION15 => c.p117
,P_PER_INFORMATION16 => c.p118
,P_PER_INFORMATION17 => c.p119
,P_PER_INFORMATION18 => c.p120
,P_PER_INFORMATION19 => c.p121
,P_PER_INFORMATION20 => c.p122
,P_PER_INFORMATION21 => c.p123
,P_PER_INFORMATION22 => c.p124
,P_PER_INFORMATION23 => c.p125
,P_PER_INFORMATION24 => c.p126
,P_PER_INFORMATION25 => c.p127
,P_PER_INFORMATION26 => c.p128
,P_PER_INFORMATION27 => c.p129
,P_PER_INFORMATION28 => c.p130
,P_PER_INFORMATION29 => c.p131
,P_PER_INFORMATION30 => c.p132
,P_CORRESPONDENCE_LANGUAGE => c.p133
,P_HONORS => c.p134
,P_PRE_NAME_ADJUNCT => c.p135
,P_SUFFIX => c.p136
,P_CREATE_MIRROR_FLAG => c.p137
,P_MIRROR_TYPE => c.p138
,P_MIRROR_CONT_ATTRIBUTE_CAT => c.p139
,P_MIRROR_CONT_ATTRIBUTE1 => c.p140
,P_MIRROR_CONT_ATTRIBUTE2 => c.p141
,P_MIRROR_CONT_ATTRIBUTE3 => c.p142
,P_MIRROR_CONT_ATTRIBUTE4 => c.p143
,P_MIRROR_CONT_ATTRIBUTE5 => c.p144
,P_MIRROR_CONT_ATTRIBUTE6 => c.p145
,P_MIRROR_CONT_ATTRIBUTE7 => c.p146
,P_MIRROR_CONT_ATTRIBUTE8 => c.p147
,P_MIRROR_CONT_ATTRIBUTE9 => c.p148
,P_MIRROR_CONT_ATTRIBUTE10 => c.p149
,P_MIRROR_CONT_ATTRIBUTE11 => c.p150
,P_MIRROR_CONT_ATTRIBUTE12 => c.p151
,P_MIRROR_CONT_ATTRIBUTE13 => c.p152
,P_MIRROR_CONT_ATTRIBUTE14 => c.p153
,P_MIRROR_CONT_ATTRIBUTE15 => c.p154
,P_MIRROR_CONT_ATTRIBUTE16 => c.p155
,P_MIRROR_CONT_ATTRIBUTE17 => c.p156
,P_MIRROR_CONT_ATTRIBUTE18 => c.p157
,P_MIRROR_CONT_ATTRIBUTE19 => c.p158
,P_MIRROR_CONT_ATTRIBUTE20 => c.p159
,P_MIRROR_CONT_INFORMATION_CAT => c.p160
,P_MIRROR_CONT_INFORMATION1 => c.p161
,P_MIRROR_CONT_INFORMATION2 => c.p162
,P_MIRROR_CONT_INFORMATION3 => c.p163
,P_MIRROR_CONT_INFORMATION4 => c.p164
,P_MIRROR_CONT_INFORMATION5 => c.p165
,P_MIRROR_CONT_INFORMATION6 => c.p166
,P_MIRROR_CONT_INFORMATION7 => c.p167
,P_MIRROR_CONT_INFORMATION8 => c.p168
,P_MIRROR_CONT_INFORMATION9 => c.p169
,P_MIRROR_CONT_INFORMATION10 => c.p170
,P_MIRROR_CONT_INFORMATION11 => c.p171
,P_MIRROR_CONT_INFORMATION12 => c.p172
,P_MIRROR_CONT_INFORMATION13 => c.p173
,P_MIRROR_CONT_INFORMATION14 => c.p174
,P_MIRROR_CONT_INFORMATION15 => c.p175
,P_MIRROR_CONT_INFORMATION16 => c.p176
,P_MIRROR_CONT_INFORMATION17 => c.p177
,P_MIRROR_CONT_INFORMATION18 => c.p178
,P_MIRROR_CONT_INFORMATION19 => c.p179
,P_MIRROR_CONT_INFORMATION20 => c.p180
,P_CONTACT_RELATIONSHIP_ID => c.p181
,P_CTR_OBJECT_VERSION_NUMBER => c.p182
,P_PER_PERSON_ID => L_PER_PERSON_ID
,P_PER_OBJECT_VERSION_NUMBER => c.p184
,P_PER_EFFECTIVE_START_DATE => c.p185
,P_PER_EFFECTIVE_END_DATE => c.p186
,P_FULL_NAME => c.p187
,P_PER_COMMENT_ID => c.p188
,P_NAME_COMBINATION_WARNING => L_NAME_COMBINATION_WARNING
,P_ORIG_HIRE_WARNING => L_ORIG_HIRE_WARNING);
hr_data_pump.api_trc_off;
--
iuk(p_batch_line_id,c.p183,L_PER_PERSON_ID);
--
if L_NAME_COMBINATION_WARNING then
c.p189 := 'TRUE';
else
c.p189 := 'FALSE';
end if;
--
if L_ORIG_HIRE_WARNING then
c.p190 := 'TRUE';
else
c.p190 := 'FALSE';
end if;
--
update hr_pump_batch_lines l set
l.pval181 = decode(c.p181,null,cn,c.p181),
l.pval182 = decode(c.p182,null,cn,c.p182),
l.pval183 = decode(c.p183,null,cn,c.p183),
l.pval184 = decode(c.p184,null,cn,c.p184),
l.pval185 = decode(c.p185,null,cn,dc(c.p185)),
l.pval186 = decode(c.p186,null,cn,dc(c.p186)),
l.pval187 = decode(c.p187,null,cn,c.p187),
l.pval188 = decode(c.p188,null,cn,c.p188),
l.pval189 = decode(c.p189,null,cn,c.p189),
l.pval190 = decode(c.p190,null,cn,c.p190)
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
end hrdpp_CREATE_CONTACT;

/