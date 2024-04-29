--------------------------------------------------------
--  DDL for Package Body HRDPP_UPDATE_BAL_TYPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_UPDATE_BAL_TYPE" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:15
 * Generated for API: PAY_BALANCE_TYPES_API.UPDATE_BAL_TYPE
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
,P_BALANCE_NAME in varchar2 default null
,P_BALANCE_UOM in varchar2 default null
,P_CURRENCY_CODE in varchar2 default null
,P_ASSIGNMENT_REMUNERATION_FLAG in varchar2 default null
,P_COMMENTS in varchar2 default null
,P_REPORTING_NAME in varchar2 default null
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
,P_BALANCE_TYPE_USER_KEY in varchar2
,P_CATEGORY_NAME in varchar2 default null
,P_BASE_BALANCE_NAME in varchar2 default null
,P_ELEMENT_NAME in varchar2 default null
,P_INPUT_NAME in varchar2 default null) is
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
,pval031
,pval032
,pval033
,pval034
,pval035)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,3582
,'U'
,p_user_sequence
,p_link_value
,dc(P_EFFECTIVE_DATE)
,P_LANGUAGE_CODE
,P_BALANCE_NAME
,P_BALANCE_UOM
,P_CURRENCY_CODE
,P_ASSIGNMENT_REMUNERATION_FLAG
,P_COMMENTS
,P_REPORTING_NAME
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
,P_BALANCE_TYPE_USER_KEY
,P_CATEGORY_NAME
,P_BASE_BALANCE_NAME
,P_ELEMENT_NAME
,P_INPUT_NAME);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,dn,d(l.pval001)) p1,
decode(l.pval002,cn,vn,vn,vh,l.pval002) p2,
l.pval002 d2,
decode(l.pval003,cn,vn,vn,vh,l.pval003) p3,
l.pval003 d3,
decode(l.pval004,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval004,'UNITS',d(l.pval001),l.pval002)) p4,
l.pval004 d4,
decode(l.pval005,cn,vn,vn,vh,l.pval005) p5,
l.pval005 d5,
decode(l.pval006,cn,vn,vn,vh,l.pval006) p6,
l.pval006 d6,
decode(l.pval007,cn,vn,vn,vh,l.pval007) p7,
l.pval007 d7,
decode(l.pval008,cn,vn,vn,vh,l.pval008) p8,
l.pval008 d8,
decode(l.pval009,cn,vn,vn,vh,l.pval009) p9,
l.pval009 d9,
decode(l.pval010,cn,vn,vn,vh,l.pval010) p10,
l.pval010 d10,
decode(l.pval011,cn,vn,vn,vh,l.pval011) p11,
l.pval011 d11,
decode(l.pval012,cn,vn,vn,vh,l.pval012) p12,
l.pval012 d12,
decode(l.pval013,cn,vn,vn,vh,l.pval013) p13,
l.pval013 d13,
decode(l.pval014,cn,vn,vn,vh,l.pval014) p14,
l.pval014 d14,
decode(l.pval015,cn,vn,vn,vh,l.pval015) p15,
l.pval015 d15,
decode(l.pval016,cn,vn,vn,vh,l.pval016) p16,
l.pval016 d16,
decode(l.pval017,cn,vn,vn,vh,l.pval017) p17,
l.pval017 d17,
decode(l.pval018,cn,vn,vn,vh,l.pval018) p18,
l.pval018 d18,
decode(l.pval019,cn,vn,vn,vh,l.pval019) p19,
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
l.pval030 p30,
decode(l.pval031,cn,vn,l.pval031) p31,
decode(l.pval032,cn,vn,vn,vh,l.pval032) p32,
l.pval032 d32,
decode(l.pval033,cn,vn,vn,vh,l.pval033) p33,
l.pval033 d33,
decode(l.pval034,cn,vn,vn,vh,l.pval034) p34,
l.pval034 d34,
decode(l.pval035,cn,vn,vn,vh,l.pval035) p35,
l.pval035 d35
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_BALANCE_TYPE_ID number;
L_OBJECT_VERSION_NUMBER number;
L_BALANCE_CATEGORY_ID number;
L_BASE_BALANCE_TYPE_ID number;
L_INPUT_VALUE_ID number;
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
if c.p31 is null then
L_BALANCE_TYPE_ID:=nn;
else
L_BALANCE_TYPE_ID := 
PAY_BALANCE_TYPES_DATA_PUMP.get_balance_type_id
(P_BALANCE_TYPE_USER_KEY => c.p31);
end if;
--
if c.p31 is null then
L_OBJECT_VERSION_NUMBER:=nn;
else
L_OBJECT_VERSION_NUMBER := 
PAY_BALANCE_TYPES_DATA_PUMP.GET_BALANCE_TYPE_OVN
(P_BALANCE_TYPE_USER_KEY => c.p31);
end if;
--
if c.p1 is null or
c.d32=cn then
L_BALANCE_CATEGORY_ID:=nn;
elsif c.d32 is null then 
L_BALANCE_CATEGORY_ID:=nh;
else
L_BALANCE_CATEGORY_ID := 
PAY_BALANCE_TYPES_DATA_PUMP.GET_BALANCE_CATEGORY_ID
(P_EFFECTIVE_DATE => c.p1
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_CATEGORY_NAME => c.p32);
end if;
--
if c.d33=cn then
L_BASE_BALANCE_TYPE_ID:=nn;
elsif c.d33 is null then 
L_BASE_BALANCE_TYPE_ID:=nh;
else
L_BASE_BALANCE_TYPE_ID := 
PAY_BALANCE_TYPES_DATA_PUMP.GET_BASE_BALANCE_TYPE_ID
(P_BASE_BALANCE_NAME => c.p33
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID);
end if;
--
if c.d34=cn or
c.d35=cn or
c.p1 is null or
c.d2=cn then
L_INPUT_VALUE_ID:=nn;
elsif c.d34 is null or
c.d35 is null or
c.d2 is null then 
L_INPUT_VALUE_ID:=nh;
else
L_INPUT_VALUE_ID := 
PAY_BALANCE_TYPES_DATA_PUMP.GET_INPUT_VALUE_ID
(P_ELEMENT_NAME => c.p34
,P_INPUT_NAME => c.p35
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1
,P_LANGUAGE_CODE => c.p2);
end if;
--
hr_data_pump.api_trc_on;
PAY_BALANCE_TYPES_API.UPDATE_BAL_TYPE
(p_validate => l_validate
,P_EFFECTIVE_DATE => c.p1
,P_LANGUAGE_CODE => c.p2
,P_BALANCE_TYPE_ID => L_BALANCE_TYPE_ID
,P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER
,P_BALANCE_NAME => c.p3
,P_BALANCE_UOM => c.p4
,P_CURRENCY_CODE => c.p5
,P_ASSIGNMENT_REMUNERATION_FLAG => c.p6
,P_COMMENTS => c.p7
,P_REPORTING_NAME => c.p8
,P_ATTRIBUTE_CATEGORY => c.p9
,P_ATTRIBUTE1 => c.p10
,P_ATTRIBUTE2 => c.p11
,P_ATTRIBUTE3 => c.p12
,P_ATTRIBUTE4 => c.p13
,P_ATTRIBUTE5 => c.p14
,P_ATTRIBUTE6 => c.p15
,P_ATTRIBUTE7 => c.p16
,P_ATTRIBUTE8 => c.p17
,P_ATTRIBUTE9 => c.p18
,P_ATTRIBUTE10 => c.p19
,P_ATTRIBUTE11 => c.p20
,P_ATTRIBUTE12 => c.p21
,P_ATTRIBUTE13 => c.p22
,P_ATTRIBUTE14 => c.p23
,P_ATTRIBUTE15 => c.p24
,P_ATTRIBUTE16 => c.p25
,P_ATTRIBUTE17 => c.p26
,P_ATTRIBUTE18 => c.p27
,P_ATTRIBUTE19 => c.p28
,P_ATTRIBUTE20 => c.p29
,P_BALANCE_CATEGORY_ID => L_BALANCE_CATEGORY_ID
,P_BASE_BALANCE_TYPE_ID => L_BASE_BALANCE_TYPE_ID
,P_INPUT_VALUE_ID => L_INPUT_VALUE_ID
,P_BALANCE_NAME_WARNING => c.p30);
hr_data_pump.api_trc_off;

--
update hr_pump_batch_lines l set
l.pval030 = decode(c.p30,null,cn,c.p30)
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
end hrdpp_UPDATE_BAL_TYPE;

/