--------------------------------------------------------
--  DDL for Package Body HRDPP_UPDATE_FED_TAX_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_UPDATE_FED_TAX_RULE" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:03
 * Generated for API: PAY_FEDERAL_TAX_RULE_API.UPDATE_FED_TAX_RULE
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
,P_SUI_STATE_CODE in varchar2 default null
,P_ADDITIONAL_WA_AMOUNT in number default null
,I_ADDITIONAL_WA_AMOUNT in varchar2 default 'N'
,P_FILING_STATUS_CODE in varchar2 default null
,P_FIT_OVERRIDE_AMOUNT in number default null
,I_FIT_OVERRIDE_AMOUNT in varchar2 default 'N'
,P_FIT_OVERRIDE_RATE in number default null
,I_FIT_OVERRIDE_RATE in varchar2 default 'N'
,P_WITHHOLDING_ALLOWANCES in number default null
,I_WITHHOLDING_ALLOWANCES in varchar2 default 'N'
,P_CUMULATIVE_TAXATION in varchar2 default null
,P_EIC_FILING_STATUS_CODE in varchar2 default null
,P_FIT_ADDITIONAL_TAX in number default null
,I_FIT_ADDITIONAL_TAX in varchar2 default 'N'
,P_FIT_EXEMPT in varchar2 default null
,P_FUTA_TAX_EXEMPT in varchar2 default null
,P_MEDICARE_TAX_EXEMPT in varchar2 default null
,P_SS_TAX_EXEMPT in varchar2 default null
,P_STATUTORY_EMPLOYEE in varchar2 default null
,P_W2_FILED_YEAR in number default null
,I_W2_FILED_YEAR in varchar2 default 'N'
,P_SUPP_TAX_OVERRIDE_RATE in number default null
,I_SUPP_TAX_OVERRIDE_RATE in varchar2 default 'N'
,P_EXCESSIVE_WA_REJECT_DATE in date default null
,I_EXCESSIVE_WA_REJECT_DATE in varchar2 default 'N'
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
,P_FED_INFORMATION_CATEGORY in varchar2 default null
,P_FED_INFORMATION1 in varchar2 default null
,P_FED_INFORMATION2 in varchar2 default null
,P_FED_INFORMATION3 in varchar2 default null
,P_FED_INFORMATION4 in varchar2 default null
,P_FED_INFORMATION5 in varchar2 default null
,P_FED_INFORMATION6 in varchar2 default null
,P_FED_INFORMATION7 in varchar2 default null
,P_FED_INFORMATION8 in varchar2 default null
,P_FED_INFORMATION9 in varchar2 default null
,P_FED_INFORMATION10 in varchar2 default null
,P_FED_INFORMATION11 in varchar2 default null
,P_FED_INFORMATION12 in varchar2 default null
,P_FED_INFORMATION13 in varchar2 default null
,P_FED_INFORMATION14 in varchar2 default null
,P_FED_INFORMATION15 in varchar2 default null
,P_FED_INFORMATION16 in varchar2 default null
,P_FED_INFORMATION17 in varchar2 default null
,P_FED_INFORMATION18 in varchar2 default null
,P_FED_INFORMATION19 in varchar2 default null
,P_FED_INFORMATION20 in varchar2 default null
,P_FED_INFORMATION21 in varchar2 default null
,P_FED_INFORMATION22 in varchar2 default null
,P_FED_INFORMATION23 in varchar2 default null
,P_FED_INFORMATION24 in varchar2 default null
,P_FED_INFORMATION25 in varchar2 default null
,P_FED_INFORMATION26 in varchar2 default null
,P_FED_INFORMATION27 in varchar2 default null
,P_FED_INFORMATION28 in varchar2 default null
,P_FED_INFORMATION29 in varchar2 default null
,P_FED_INFORMATION30 in varchar2 default null
,P_EMP_FED_TAX_RULE_USER_KEY in varchar2) is
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
,pval084)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,1706
,'U'
,p_user_sequence
,p_link_value
,dc(P_EFFECTIVE_DATE)
,P_DATETRACK_UPDATE_MODE
,P_SUI_STATE_CODE
,nd(P_ADDITIONAL_WA_AMOUNT,I_ADDITIONAL_WA_AMOUNT)
,P_FILING_STATUS_CODE
,nd(P_FIT_OVERRIDE_AMOUNT,I_FIT_OVERRIDE_AMOUNT)
,nd(P_FIT_OVERRIDE_RATE,I_FIT_OVERRIDE_RATE)
,nd(P_WITHHOLDING_ALLOWANCES,I_WITHHOLDING_ALLOWANCES)
,P_CUMULATIVE_TAXATION
,P_EIC_FILING_STATUS_CODE
,nd(P_FIT_ADDITIONAL_TAX,I_FIT_ADDITIONAL_TAX)
,P_FIT_EXEMPT
,P_FUTA_TAX_EXEMPT
,P_MEDICARE_TAX_EXEMPT
,P_SS_TAX_EXEMPT
,P_STATUTORY_EMPLOYEE
,nd(P_W2_FILED_YEAR,I_W2_FILED_YEAR)
,nd(P_SUPP_TAX_OVERRIDE_RATE,I_SUPP_TAX_OVERRIDE_RATE)
,dd(P_EXCESSIVE_WA_REJECT_DATE,I_EXCESSIVE_WA_REJECT_DATE)
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
,P_FED_INFORMATION_CATEGORY
,P_FED_INFORMATION1
,P_FED_INFORMATION2
,P_FED_INFORMATION3
,P_FED_INFORMATION4
,P_FED_INFORMATION5
,P_FED_INFORMATION6
,P_FED_INFORMATION7
,P_FED_INFORMATION8
,P_FED_INFORMATION9
,P_FED_INFORMATION10
,P_FED_INFORMATION11
,P_FED_INFORMATION12
,P_FED_INFORMATION13
,P_FED_INFORMATION14
,P_FED_INFORMATION15
,P_FED_INFORMATION16
,P_FED_INFORMATION17
,P_FED_INFORMATION18
,P_FED_INFORMATION19
,P_FED_INFORMATION20
,P_FED_INFORMATION21
,P_FED_INFORMATION22
,P_FED_INFORMATION23
,P_FED_INFORMATION24
,P_FED_INFORMATION25
,P_FED_INFORMATION26
,P_FED_INFORMATION27
,P_FED_INFORMATION28
,P_FED_INFORMATION29
,P_FED_INFORMATION30
,P_EMP_FED_TAX_RULE_USER_KEY);
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
decode(l.pval004,cn,nn,vn,nh,n(l.pval004)) p4,
l.pval004 d4,
decode(l.pval005,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval005,'US_FIT_FILING_STATUS',d(l.pval001),vn)) p5,
l.pval005 d5,
decode(l.pval006,cn,nn,vn,nh,n(l.pval006)) p6,
l.pval006 d6,
decode(l.pval007,cn,nn,vn,nh,n(l.pval007)) p7,
l.pval007 d7,
decode(l.pval008,cn,nn,vn,nh,n(l.pval008)) p8,
l.pval008 d8,
decode(l.pval009,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval009,'YES_NO',d(l.pval001),vn)) p9,
l.pval009 d9,
decode(l.pval010,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval010,'US_EIC_FILING_STATUS',d(l.pval001),vn)) p10,
l.pval010 d10,
decode(l.pval011,cn,nn,vn,nh,n(l.pval011)) p11,
l.pval011 d11,
decode(l.pval012,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval012,'YES_NO',d(l.pval001),vn)) p12,
l.pval012 d12,
decode(l.pval013,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval013,'YES_NO',d(l.pval001),vn)) p13,
l.pval013 d13,
decode(l.pval014,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval014,'YES_NO',d(l.pval001),vn)) p14,
l.pval014 d14,
decode(l.pval015,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval015,'YES_NO',d(l.pval001),vn)) p15,
l.pval015 d15,
decode(l.pval016,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval016,'YES_NO',d(l.pval001),vn)) p16,
l.pval016 d16,
decode(l.pval017,cn,nn,vn,nh,n(l.pval017)) p17,
l.pval017 d17,
decode(l.pval018,cn,nn,vn,nh,n(l.pval018)) p18,
l.pval018 d18,
decode(l.pval019,cn,dn,vn,dh,d(l.pval019)) p19,
l.pval019 d19,
decode(l.pval020,cn,vn,vn,vh,l.pval020) p20,
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
decode(l.pval053,cn,vn,vn,vh,l.pval053) p53,
l.pval053 d53,
decode(l.pval054,cn,vn,vn,vh,l.pval054) p54,
l.pval054 d54,
decode(l.pval055,cn,vn,vn,vh,l.pval055) p55,
l.pval055 d55,
decode(l.pval056,cn,vn,vn,vh,l.pval056) p56,
l.pval056 d56,
decode(l.pval057,cn,vn,vn,vh,l.pval057) p57,
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
decode(l.pval080,cn,vn,vn,vh,l.pval080) p80,
l.pval080 d80,
decode(l.pval081,cn,vn,vn,vh,l.pval081) p81,
l.pval081 d81,
decode(l.pval082,cn,dn,d(l.pval082)) p82,
decode(l.pval083,cn,dn,d(l.pval083)) p83,
decode(l.pval084,cn,vn,l.pval084) p84
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_EMP_FED_TAX_RULE_ID number;
L_OBJECT_VERSION_NUMBER number;
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
if c.p84 is null then
L_EMP_FED_TAX_RULE_ID:=nn;
else
L_EMP_FED_TAX_RULE_ID := 
hr_pump_get.get_emp_fed_tax_rule_id
(P_EMP_FED_TAX_RULE_USER_KEY => c.p84);
end if;
--
if c.p84 is null or
c.p1 is null then
L_OBJECT_VERSION_NUMBER:=nn;
else
L_OBJECT_VERSION_NUMBER := 
hr_pump_get.GET_FED_TAX_RULE_OVN
(P_EMP_FED_TAX_RULE_USER_KEY => c.p84
,P_EFFECTIVE_DATE => c.p1);
end if;
--
hr_data_pump.api_trc_on;
PAY_FEDERAL_TAX_RULE_API.UPDATE_FED_TAX_RULE
(p_validate => l_validate
,P_EFFECTIVE_DATE => c.p1
,P_DATETRACK_UPDATE_MODE => c.p2
,P_EMP_FED_TAX_RULE_ID => L_EMP_FED_TAX_RULE_ID
,P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER
,P_SUI_STATE_CODE => c.p3
,P_ADDITIONAL_WA_AMOUNT => c.p4
,P_FILING_STATUS_CODE => c.p5
,P_FIT_OVERRIDE_AMOUNT => c.p6
,P_FIT_OVERRIDE_RATE => c.p7
,P_WITHHOLDING_ALLOWANCES => c.p8
,P_CUMULATIVE_TAXATION => c.p9
,P_EIC_FILING_STATUS_CODE => c.p10
,P_FIT_ADDITIONAL_TAX => c.p11
,P_FIT_EXEMPT => c.p12
,P_FUTA_TAX_EXEMPT => c.p13
,P_MEDICARE_TAX_EXEMPT => c.p14
,P_SS_TAX_EXEMPT => c.p15
,P_STATUTORY_EMPLOYEE => c.p16
,P_W2_FILED_YEAR => c.p17
,P_SUPP_TAX_OVERRIDE_RATE => c.p18
,P_EXCESSIVE_WA_REJECT_DATE => c.p19
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
,P_FED_INFORMATION_CATEGORY => c.p51
,P_FED_INFORMATION1 => c.p52
,P_FED_INFORMATION2 => c.p53
,P_FED_INFORMATION3 => c.p54
,P_FED_INFORMATION4 => c.p55
,P_FED_INFORMATION5 => c.p56
,P_FED_INFORMATION6 => c.p57
,P_FED_INFORMATION7 => c.p58
,P_FED_INFORMATION8 => c.p59
,P_FED_INFORMATION9 => c.p60
,P_FED_INFORMATION10 => c.p61
,P_FED_INFORMATION11 => c.p62
,P_FED_INFORMATION12 => c.p63
,P_FED_INFORMATION13 => c.p64
,P_FED_INFORMATION14 => c.p65
,P_FED_INFORMATION15 => c.p66
,P_FED_INFORMATION16 => c.p67
,P_FED_INFORMATION17 => c.p68
,P_FED_INFORMATION18 => c.p69
,P_FED_INFORMATION19 => c.p70
,P_FED_INFORMATION20 => c.p71
,P_FED_INFORMATION21 => c.p72
,P_FED_INFORMATION22 => c.p73
,P_FED_INFORMATION23 => c.p74
,P_FED_INFORMATION24 => c.p75
,P_FED_INFORMATION25 => c.p76
,P_FED_INFORMATION26 => c.p77
,P_FED_INFORMATION27 => c.p78
,P_FED_INFORMATION28 => c.p79
,P_FED_INFORMATION29 => c.p80
,P_FED_INFORMATION30 => c.p81
,P_EFFECTIVE_START_DATE => c.p82
,P_EFFECTIVE_END_DATE => c.p83);
hr_data_pump.api_trc_off;

--
update hr_pump_batch_lines l set
l.pval082 = decode(c.p82,null,cn,dc(c.p82)),
l.pval083 = decode(c.p83,null,cn,dc(c.p83))
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
end hrdpp_UPDATE_FED_TAX_RULE;

/
