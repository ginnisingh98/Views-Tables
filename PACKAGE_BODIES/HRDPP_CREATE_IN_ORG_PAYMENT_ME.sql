--------------------------------------------------------
--  DDL for Package Body HRDPP_CREATE_IN_ORG_PAYMENT_ME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_CREATE_IN_ORG_PAYMENT_ME" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:02
 * Generated for API: pay_in_org_payment_method_api.create_in_org_payment_method
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
,P_LANGUAGE_CODE in varchar2 default null
,P_ORG_PAYMENT_METHOD_NAME in varchar2
,P_CURRENCY_CODE in varchar2 default null
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
,P_PAYABLE_AT in varchar2 default null
,P_COMMENTS in varchar2 default null
,P_ACCOUNT_NUMBER in varchar2 default null
,P_ACCOUNT_TYPE in varchar2 default null
,P_BANK_CODE in varchar2 default null
,P_BRANCH_CODE in varchar2 default null
,P_CONCAT_SEGMENTS in varchar2 default null
,P_GL_SEGMENT1 in varchar2 default null
,P_GL_SEGMENT2 in varchar2 default null
,P_GL_SEGMENT3 in varchar2 default null
,P_GL_SEGMENT4 in varchar2 default null
,P_GL_SEGMENT5 in varchar2 default null
,P_GL_SEGMENT6 in varchar2 default null
,P_GL_SEGMENT7 in varchar2 default null
,P_GL_SEGMENT8 in varchar2 default null
,P_GL_SEGMENT9 in varchar2 default null
,P_GL_SEGMENT10 in varchar2 default null
,P_GL_SEGMENT11 in varchar2 default null
,P_GL_SEGMENT12 in varchar2 default null
,P_GL_SEGMENT13 in varchar2 default null
,P_GL_SEGMENT14 in varchar2 default null
,P_GL_SEGMENT15 in varchar2 default null
,P_GL_SEGMENT16 in varchar2 default null
,P_GL_SEGMENT17 in varchar2 default null
,P_GL_SEGMENT18 in varchar2 default null
,P_GL_SEGMENT19 in varchar2 default null
,P_GL_SEGMENT20 in varchar2 default null
,P_GL_SEGMENT21 in varchar2 default null
,P_GL_SEGMENT22 in varchar2 default null
,P_GL_SEGMENT23 in varchar2 default null
,P_GL_SEGMENT24 in varchar2 default null
,P_GL_SEGMENT25 in varchar2 default null
,P_GL_SEGMENT26 in varchar2 default null
,P_GL_SEGMENT27 in varchar2 default null
,P_GL_SEGMENT28 in varchar2 default null
,P_GL_SEGMENT29 in varchar2 default null
,P_GL_SEGMENT30 in varchar2 default null
,P_GL_CONCAT_SEGMENTS in varchar2 default null
,P_THIRD_PARTY_PAYMENT in varchar2 default null
,P_ORG_PAYMENT_METHOD_USER_KEY in varchar2
,PAYMENT_TYPE_ID in number
,P_SETS_OF_BOOK_NAME in varchar2 default null) is
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
,pval072
,pval073)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,3223
,'U'
,p_user_sequence
,p_link_value
,dc(P_EFFECTIVE_DATE)
,P_LANGUAGE_CODE
,P_ORG_PAYMENT_METHOD_NAME
,P_CURRENCY_CODE
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
,P_PAYABLE_AT
,P_COMMENTS
,P_ACCOUNT_NUMBER
,P_ACCOUNT_TYPE
,P_BANK_CODE
,P_BRANCH_CODE
,P_CONCAT_SEGMENTS
,P_GL_SEGMENT1
,P_GL_SEGMENT2
,P_GL_SEGMENT3
,P_GL_SEGMENT4
,P_GL_SEGMENT5
,P_GL_SEGMENT6
,P_GL_SEGMENT7
,P_GL_SEGMENT8
,P_GL_SEGMENT9
,P_GL_SEGMENT10
,P_GL_SEGMENT11
,P_GL_SEGMENT12
,P_GL_SEGMENT13
,P_GL_SEGMENT14
,P_GL_SEGMENT15
,P_GL_SEGMENT16
,P_GL_SEGMENT17
,P_GL_SEGMENT18
,P_GL_SEGMENT19
,P_GL_SEGMENT20
,P_GL_SEGMENT21
,P_GL_SEGMENT22
,P_GL_SEGMENT23
,P_GL_SEGMENT24
,P_GL_SEGMENT25
,P_GL_SEGMENT26
,P_GL_SEGMENT27
,P_GL_SEGMENT28
,P_GL_SEGMENT29
,P_GL_SEGMENT30
,P_GL_CONCAT_SEGMENTS
,P_THIRD_PARTY_PAYMENT
,P_ORG_PAYMENT_METHOD_USER_KEY
,PAYMENT_TYPE_ID
,P_SETS_OF_BOOK_NAME);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,dn,d(l.pval001)) p1,
decode(l.pval002,cn,vn,vn,vn,l.pval002) p2,
l.pval002 d2,
decode(l.pval003,cn,vn,l.pval003) p3,
decode(l.pval004,cn,vn,vn,vn,l.pval004) p4,
l.pval004 d4,
decode(l.pval005,cn,vn,vn,vn,l.pval005) p5,
l.pval005 d5,
decode(l.pval006,cn,vn,vn,vn,l.pval006) p6,
l.pval006 d6,
decode(l.pval007,cn,vn,vn,vn,l.pval007) p7,
l.pval007 d7,
decode(l.pval008,cn,vn,vn,vn,l.pval008) p8,
l.pval008 d8,
decode(l.pval009,cn,vn,vn,vn,l.pval009) p9,
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
decode(l.pval029,cn,vn,vn,'SB',
 hr_pump_get.gl(l.pval029,'IN_ACCOUNT_TYPE',d(l.pval001),l.pval002)) p29,
l.pval029 d29,
decode(l.pval030,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval030,'IN_BANK',d(l.pval001),l.pval002)) p30,
l.pval030 d30,
decode(l.pval031,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval031,'IN_BANK_BRANCH',d(l.pval001),l.pval002)) p31,
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
l.pval065 p65,
decode(l.pval066,cn,dn,d(l.pval066)) p66,
decode(l.pval067,cn,dn,d(l.pval067)) p67,
l.pval068 p68,
l.pval069 p69,
l.pval070 p70,
l.pval071 p71,
decode(l.pval072,cn,nn,n(l.pval072)) p72,
decode(l.pval073,cn,vn,vn,vn,l.pval073) p73,
l.pval073 d73
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_ORG_PAYMENT_METHOD_ID number;
L_PAYMENT_TYPE_ID number;
L_SETS_OF_BOOK_ID number;
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
if c.p72 is null then
L_PAYMENT_TYPE_ID:=nn;
else
L_PAYMENT_TYPE_ID := 
PER_IN_DATA_PUMP.get_payment_type_id
(PAYMENT_TYPE_ID => c.p72);
end if;
--
if c.p73 is null then
L_SETS_OF_BOOK_ID:=nn;
else
L_SETS_OF_BOOK_ID := 
PER_IN_DATA_PUMP.get_sets_of_book_id
(P_SETS_OF_BOOK_NAME => c.p73);
end if;
--
hr_data_pump.api_trc_on;
pay_in_org_payment_method_api.create_in_org_payment_method
(p_validate => l_validate
,P_EFFECTIVE_DATE => c.p1
,P_LANGUAGE_CODE => c.p2
,p_business_group_id => p_business_group_id
,P_ORG_PAYMENT_METHOD_NAME => c.p3
,P_PAYMENT_TYPE_ID => L_PAYMENT_TYPE_ID
,P_CURRENCY_CODE => c.p4
,P_ATTRIBUTE_CATEGORY => c.p5
,P_ATTRIBUTE1 => c.p6
,P_ATTRIBUTE2 => c.p7
,P_ATTRIBUTE3 => c.p8
,P_ATTRIBUTE4 => c.p9
,P_ATTRIBUTE5 => c.p10
,P_ATTRIBUTE6 => c.p11
,P_ATTRIBUTE7 => c.p12
,P_ATTRIBUTE8 => c.p13
,P_ATTRIBUTE9 => c.p14
,P_ATTRIBUTE10 => c.p15
,P_ATTRIBUTE11 => c.p16
,P_ATTRIBUTE12 => c.p17
,P_ATTRIBUTE13 => c.p18
,P_ATTRIBUTE14 => c.p19
,P_ATTRIBUTE15 => c.p20
,P_ATTRIBUTE16 => c.p21
,P_ATTRIBUTE17 => c.p22
,P_ATTRIBUTE18 => c.p23
,P_ATTRIBUTE19 => c.p24
,P_ATTRIBUTE20 => c.p25
,P_PAYABLE_AT => c.p26
,P_COMMENTS => c.p27
,P_ACCOUNT_NUMBER => c.p28
,P_ACCOUNT_TYPE => c.p29
,P_BANK_CODE => c.p30
,P_BRANCH_CODE => c.p31
,P_CONCAT_SEGMENTS => c.p32
,P_GL_SEGMENT1 => c.p33
,P_GL_SEGMENT2 => c.p34
,P_GL_SEGMENT3 => c.p35
,P_GL_SEGMENT4 => c.p36
,P_GL_SEGMENT5 => c.p37
,P_GL_SEGMENT6 => c.p38
,P_GL_SEGMENT7 => c.p39
,P_GL_SEGMENT8 => c.p40
,P_GL_SEGMENT9 => c.p41
,P_GL_SEGMENT10 => c.p42
,P_GL_SEGMENT11 => c.p43
,P_GL_SEGMENT12 => c.p44
,P_GL_SEGMENT13 => c.p45
,P_GL_SEGMENT14 => c.p46
,P_GL_SEGMENT15 => c.p47
,P_GL_SEGMENT16 => c.p48
,P_GL_SEGMENT17 => c.p49
,P_GL_SEGMENT18 => c.p50
,P_GL_SEGMENT19 => c.p51
,P_GL_SEGMENT20 => c.p52
,P_GL_SEGMENT21 => c.p53
,P_GL_SEGMENT22 => c.p54
,P_GL_SEGMENT23 => c.p55
,P_GL_SEGMENT24 => c.p56
,P_GL_SEGMENT25 => c.p57
,P_GL_SEGMENT26 => c.p58
,P_GL_SEGMENT27 => c.p59
,P_GL_SEGMENT28 => c.p60
,P_GL_SEGMENT29 => c.p61
,P_GL_SEGMENT30 => c.p62
,P_GL_CONCAT_SEGMENTS => c.p63
,P_SETS_OF_BOOK_ID => L_SETS_OF_BOOK_ID
,P_THIRD_PARTY_PAYMENT => c.p64
,P_ORG_PAYMENT_METHOD_ID => L_ORG_PAYMENT_METHOD_ID
,P_EFFECTIVE_START_DATE => c.p66
,P_EFFECTIVE_END_DATE => c.p67
,P_OBJECT_VERSION_NUMBER => c.p68
,P_ASSET_CODE_COMBINATION_ID => c.p69
,P_COMMENT_ID => c.p70
,P_EXTERNAL_ACCOUNT_ID => c.p71);
hr_data_pump.api_trc_off;
--
iuk(p_batch_line_id,c.p65,L_ORG_PAYMENT_METHOD_ID);
--
update hr_pump_batch_lines l set
l.pval065 = decode(c.p65,null,cn,c.p65),
l.pval066 = decode(c.p66,null,cn,dc(c.p66)),
l.pval067 = decode(c.p67,null,cn,dc(c.p67)),
l.pval068 = decode(c.p68,null,cn,c.p68),
l.pval069 = decode(c.p69,null,cn,c.p69),
l.pval070 = decode(c.p70,null,cn,c.p70),
l.pval071 = decode(c.p71,null,cn,c.p71)
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
end hrdpp_create_in_org_payment_me;

/
