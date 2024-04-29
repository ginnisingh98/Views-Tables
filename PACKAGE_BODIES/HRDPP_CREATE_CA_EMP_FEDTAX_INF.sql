--------------------------------------------------------
--  DDL for Package Body HRDPP_CREATE_CA_EMP_FEDTAX_INF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_CREATE_CA_EMP_FEDTAX_INF" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:13
 * Generated for API: PAY_CA_EMP_FEDTAX_INF_API.CREATE_CA_EMP_FEDTAX_INF
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
,P_EFFECTIVE_DATE in date) is
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
,pval054
,pval055)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,1153
,'U'
,p_user_sequence
,p_link_value
,P_EMP_FED_TAX_INF_USER_KEY
,P_LEGISLATION_CODE
,P_ASSIGNMENT_ID
,P_EMPLOYMENT_PROVINCE
,P_TAX_CREDIT_AMOUNT
,P_CLAIM_CODE
,P_BASIC_EXEMPTION_FLAG
,P_ADDITIONAL_TAX
,P_ANNUAL_DEDN
,P_TOTAL_EXPENSE_BY_COMMISSION
,P_TOTAL_REMNRTN_BY_COMMISSION
,P_PRESCRIBED_ZONE_DEDN_AMT
,P_OTHER_FEDTAX_CREDITS
,P_CPP_QPP_EXEMPT_FLAG
,P_FED_EXEMPT_FLAG
,P_EI_EXEMPT_FLAG
,P_TAX_CALC_METHOD
,P_FED_OVERRIDE_AMOUNT
,P_FED_OVERRIDE_RATE
,P_CA_TAX_INFORMATION_CATEGORY
,P_CA_TAX_INFORMATION1
,P_CA_TAX_INFORMATION2
,P_CA_TAX_INFORMATION3
,P_CA_TAX_INFORMATION4
,P_CA_TAX_INFORMATION5
,P_CA_TAX_INFORMATION6
,P_CA_TAX_INFORMATION7
,P_CA_TAX_INFORMATION8
,P_CA_TAX_INFORMATION9
,P_CA_TAX_INFORMATION10
,P_CA_TAX_INFORMATION11
,P_CA_TAX_INFORMATION12
,P_CA_TAX_INFORMATION13
,P_CA_TAX_INFORMATION14
,P_CA_TAX_INFORMATION15
,P_CA_TAX_INFORMATION16
,P_CA_TAX_INFORMATION17
,P_CA_TAX_INFORMATION18
,P_CA_TAX_INFORMATION19
,P_CA_TAX_INFORMATION20
,P_CA_TAX_INFORMATION21
,P_CA_TAX_INFORMATION22
,P_CA_TAX_INFORMATION23
,P_CA_TAX_INFORMATION24
,P_CA_TAX_INFORMATION25
,P_CA_TAX_INFORMATION26
,P_CA_TAX_INFORMATION27
,P_CA_TAX_INFORMATION28
,P_CA_TAX_INFORMATION29
,P_CA_TAX_INFORMATION30
,P_FED_LSF_AMOUNT
,dc(P_EFFECTIVE_DATE));
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
l.pval001 p1,
decode(l.pval002,cn,dn,d(l.pval002)) p2,
decode(l.pval003,cn,dn,d(l.pval003)) p3,
decode(l.pval004,cn,vn,vn,vn,l.pval004) p4,
l.pval004 d4,
decode(l.pval005,cn,nn,vn,nn,n(l.pval005)) p5,
l.pval005 d5,
decode(l.pval006,cn,vn,vn,vn,l.pval006) p6,
l.pval006 d6,
decode(l.pval007,cn,nn,vn,nn,n(l.pval007)) p7,
l.pval007 d7,
decode(l.pval008,cn,vn,vn,vn,l.pval008) p8,
l.pval008 d8,
decode(l.pval009,cn,vn,vn,vn,l.pval009) p9,
l.pval009 d9,
decode(l.pval010,cn,nn,vn,nn,n(l.pval010)) p10,
l.pval010 d10,
decode(l.pval011,cn,nn,vn,nn,n(l.pval011)) p11,
l.pval011 d11,
decode(l.pval012,cn,nn,vn,nn,n(l.pval012)) p12,
l.pval012 d12,
decode(l.pval013,cn,nn,vn,nn,n(l.pval013)) p13,
l.pval013 d13,
decode(l.pval014,cn,nn,vn,nn,n(l.pval014)) p14,
l.pval014 d14,
decode(l.pval015,cn,vn,vn,vn,l.pval015) p15,
l.pval015 d15,
decode(l.pval016,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval016,'YES_NO',d(l.pval055),vn)) p16,
l.pval016 d16,
decode(l.pval017,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval017,'YES_NO',d(l.pval055),vn)) p17,
l.pval017 d17,
decode(l.pval018,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval018,'YES_NO',d(l.pval055),vn)) p18,
l.pval018 d18,
decode(l.pval019,cn,vn,vn,vn,l.pval019) p19,
l.pval019 d19,
decode(l.pval020,cn,nn,vn,nn,n(l.pval020)) p20,
l.pval020 d20,
decode(l.pval021,cn,nn,vn,nn,n(l.pval021)) p21,
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
l.pval053 p53,
decode(l.pval054,cn,nn,vn,nn,n(l.pval054)) p54,
l.pval054 d54,
decode(l.pval055,cn,dn,d(l.pval055)) p55
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_EMP_FED_TAX_INF_ID number;
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
hr_data_pump.api_trc_on;
PAY_CA_EMP_FEDTAX_INF_API.CREATE_CA_EMP_FEDTAX_INF
(p_validate => l_validate
,P_EMP_FED_TAX_INF_ID => L_EMP_FED_TAX_INF_ID
,P_EFFECTIVE_START_DATE => c.p2
,P_EFFECTIVE_END_DATE => c.p3
,P_LEGISLATION_CODE => c.p4
,P_ASSIGNMENT_ID => c.p5
,p_business_group_id => p_business_group_id
,P_EMPLOYMENT_PROVINCE => c.p6
,P_TAX_CREDIT_AMOUNT => c.p7
,P_CLAIM_CODE => c.p8
,P_BASIC_EXEMPTION_FLAG => c.p9
,P_ADDITIONAL_TAX => c.p10
,P_ANNUAL_DEDN => c.p11
,P_TOTAL_EXPENSE_BY_COMMISSION => c.p12
,P_TOTAL_REMNRTN_BY_COMMISSION => c.p13
,P_PRESCRIBED_ZONE_DEDN_AMT => c.p14
,P_OTHER_FEDTAX_CREDITS => c.p15
,P_CPP_QPP_EXEMPT_FLAG => c.p16
,P_FED_EXEMPT_FLAG => c.p17
,P_EI_EXEMPT_FLAG => c.p18
,P_TAX_CALC_METHOD => c.p19
,P_FED_OVERRIDE_AMOUNT => c.p20
,P_FED_OVERRIDE_RATE => c.p21
,P_CA_TAX_INFORMATION_CATEGORY => c.p22
,P_CA_TAX_INFORMATION1 => c.p23
,P_CA_TAX_INFORMATION2 => c.p24
,P_CA_TAX_INFORMATION3 => c.p25
,P_CA_TAX_INFORMATION4 => c.p26
,P_CA_TAX_INFORMATION5 => c.p27
,P_CA_TAX_INFORMATION6 => c.p28
,P_CA_TAX_INFORMATION7 => c.p29
,P_CA_TAX_INFORMATION8 => c.p30
,P_CA_TAX_INFORMATION9 => c.p31
,P_CA_TAX_INFORMATION10 => c.p32
,P_CA_TAX_INFORMATION11 => c.p33
,P_CA_TAX_INFORMATION12 => c.p34
,P_CA_TAX_INFORMATION13 => c.p35
,P_CA_TAX_INFORMATION14 => c.p36
,P_CA_TAX_INFORMATION15 => c.p37
,P_CA_TAX_INFORMATION16 => c.p38
,P_CA_TAX_INFORMATION17 => c.p39
,P_CA_TAX_INFORMATION18 => c.p40
,P_CA_TAX_INFORMATION19 => c.p41
,P_CA_TAX_INFORMATION20 => c.p42
,P_CA_TAX_INFORMATION21 => c.p43
,P_CA_TAX_INFORMATION22 => c.p44
,P_CA_TAX_INFORMATION23 => c.p45
,P_CA_TAX_INFORMATION24 => c.p46
,P_CA_TAX_INFORMATION25 => c.p47
,P_CA_TAX_INFORMATION26 => c.p48
,P_CA_TAX_INFORMATION27 => c.p49
,P_CA_TAX_INFORMATION28 => c.p50
,P_CA_TAX_INFORMATION29 => c.p51
,P_CA_TAX_INFORMATION30 => c.p52
,P_OBJECT_VERSION_NUMBER => c.p53
,P_FED_LSF_AMOUNT => c.p54
,P_EFFECTIVE_DATE => c.p55);
hr_data_pump.api_trc_off;
--
iuk(p_batch_line_id,c.p1,L_EMP_FED_TAX_INF_ID);
--
update hr_pump_batch_lines l set
l.pval001 = decode(c.p1,null,cn,c.p1),
l.pval002 = decode(c.p2,null,cn,dc(c.p2)),
l.pval003 = decode(c.p3,null,cn,dc(c.p3)),
l.pval053 = decode(c.p53,null,cn,c.p53)
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
end hrdpp_CREATE_CA_EMP_FEDTAX_INF;

/
