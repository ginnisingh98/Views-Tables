--------------------------------------------------------
--  DDL for Package Body HRDPP_UPDATE_US_PERSON_ADDRESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_UPDATE_US_PERSON_ADDRESS" as
/*
 * Generated by hr_pump_meta_mapper at: 2018/06/16 10:06:05
 * Generated for API: HR_PERSON_ADDRESS_API.UPDATE_US_PERSON_ADDRESS
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
,P_VALIDATE_COUNTY in boolean default null
,P_DATE_FROM in date default null
,I_DATE_FROM in varchar2 default 'N'
,P_DATE_TO in date default null
,I_DATE_TO in varchar2 default 'N'
,P_ADDRESS_TYPE in varchar2 default null
,P_COMMENTS in long default null
,P_ADDRESS_LINE1 in varchar2 default null
,P_ADDRESS_LINE2 in varchar2 default null
,P_ADDRESS_LINE3 in varchar2 default null
,P_CITY in varchar2 default null
,P_STATE in varchar2 default null
,P_ZIP_CODE in varchar2 default null
,P_COUNTY in varchar2 default null
,P_TELEPHONE_NUMBER_1 in varchar2 default null
,P_TELEPHONE_NUMBER_2 in varchar2 default null
,P_ADDR_ATTRIBUTE_CATEGORY in varchar2 default null
,P_ADDR_ATTRIBUTE1 in varchar2 default null
,P_ADDR_ATTRIBUTE2 in varchar2 default null
,P_ADDR_ATTRIBUTE3 in varchar2 default null
,P_ADDR_ATTRIBUTE4 in varchar2 default null
,P_ADDR_ATTRIBUTE5 in varchar2 default null
,P_ADDR_ATTRIBUTE6 in varchar2 default null
,P_ADDR_ATTRIBUTE7 in varchar2 default null
,P_ADDR_ATTRIBUTE8 in varchar2 default null
,P_ADDR_ATTRIBUTE9 in varchar2 default null
,P_ADDR_ATTRIBUTE10 in varchar2 default null
,P_ADDR_ATTRIBUTE11 in varchar2 default null
,P_ADDR_ATTRIBUTE12 in varchar2 default null
,P_ADDR_ATTRIBUTE13 in varchar2 default null
,P_ADDR_ATTRIBUTE14 in varchar2 default null
,P_ADDR_ATTRIBUTE15 in varchar2 default null
,P_ADDR_ATTRIBUTE16 in varchar2 default null
,P_ADDR_ATTRIBUTE17 in varchar2 default null
,P_ADDR_ATTRIBUTE18 in varchar2 default null
,P_ADDR_ATTRIBUTE19 in varchar2 default null
,P_ADDR_ATTRIBUTE20 in varchar2 default null
,P_ADD_INFORMATION13 in varchar2 default null
,P_ADD_INFORMATION14 in varchar2 default null
,P_ADD_INFORMATION15 in varchar2 default null
,P_ADD_INFORMATION16 in varchar2 default null
,P_ADD_INFORMATION17 in varchar2 default null
,P_ADD_INFORMATION18 in varchar2 default null
,P_ADD_INFORMATION19 in varchar2 default null
,P_ADD_INFORMATION20 in varchar2 default null
,P_ADDRESS_USER_KEY in varchar2
,P_COUNTRY in varchar2 default null) is
blid number := p_data_pump_batch_line_id;
 L_VALIDATE_COUNTY varchar2(5);
begin
if P_VALIDATE_COUNTY is null then
 L_VALIDATE_COUNTY := null;
elsif P_VALIDATE_COUNTY then
 L_VALIDATE_COUNTY := 'TRUE';
else 
 L_VALIDATE_COUNTY := 'FALSE';
end if;
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
,plongval
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
,pval046)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,1380
,'U'
,p_user_sequence
,p_link_value
,dc(P_EFFECTIVE_DATE)
,L_VALIDATE_COUNTY
,dd(P_DATE_FROM,I_DATE_FROM)
,dd(P_DATE_TO,I_DATE_TO)
,P_ADDRESS_TYPE
,P_COMMENTS
,P_ADDRESS_LINE1
,P_ADDRESS_LINE2
,P_ADDRESS_LINE3
,P_CITY
,P_STATE
,P_ZIP_CODE
,P_COUNTY
,P_TELEPHONE_NUMBER_1
,P_TELEPHONE_NUMBER_2
,P_ADDR_ATTRIBUTE_CATEGORY
,P_ADDR_ATTRIBUTE1
,P_ADDR_ATTRIBUTE2
,P_ADDR_ATTRIBUTE3
,P_ADDR_ATTRIBUTE4
,P_ADDR_ATTRIBUTE5
,P_ADDR_ATTRIBUTE6
,P_ADDR_ATTRIBUTE7
,P_ADDR_ATTRIBUTE8
,P_ADDR_ATTRIBUTE9
,P_ADDR_ATTRIBUTE10
,P_ADDR_ATTRIBUTE11
,P_ADDR_ATTRIBUTE12
,P_ADDR_ATTRIBUTE13
,P_ADDR_ATTRIBUTE14
,P_ADDR_ATTRIBUTE15
,P_ADDR_ATTRIBUTE16
,P_ADDR_ATTRIBUTE17
,P_ADDR_ATTRIBUTE18
,P_ADDR_ATTRIBUTE19
,P_ADDR_ATTRIBUTE20
,P_ADD_INFORMATION13
,P_ADD_INFORMATION14
,P_ADD_INFORMATION15
,P_ADD_INFORMATION16
,P_ADD_INFORMATION17
,P_ADD_INFORMATION18
,P_ADD_INFORMATION19
,P_ADD_INFORMATION20
,P_ADDRESS_USER_KEY
,P_COUNTRY);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,dn,d(l.pval001)) p1,
decode(l.pval002,cn,vn,vn,null,l.pval002) p2,
l.pval002 d2,
decode(l.pval003,cn,dn,vn,dh,d(l.pval003)) p3,
l.pval003 d3,
decode(l.pval004,cn,dn,vn,dh,d(l.pval004)) p4,
l.pval004 d4,
decode(l.pval005,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval005,'ADDRESS_TYPE',d(l.pval001),vn)) p5,
l.pval005 d5,
l.plongval plongval,
decode(l.pval007,cn,vn,vn,vh,l.pval007) p7,
l.pval007 d7,
decode(l.pval008,cn,vn,vn,vh,l.pval008) p8,
l.pval008 d8,
decode(l.pval009,cn,vn,vn,vh,l.pval009) p9,
l.pval009 d9,
decode(l.pval010,cn,vn,vn,vh,l.pval010) p10,
l.pval010 d10,
decode(l.pval011,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval011,'US_STATE',d(l.pval001),vn)) p11,
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
decode(l.pval045,cn,vn,l.pval045) p45,
decode(l.pval046,cn,vn,vn,vh,l.pval046) p46,
l.pval046 d46
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_VALIDATE_COUNTY boolean;
L_COMMENTS varchar2(32767);
L_ADDRESS_ID number;
L_OBJECT_VERSION_NUMBER number;
L_COUNTRY varchar2(2000);
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
if upper(c.p2) = 'TRUE' then
L_VALIDATE_COUNTY := true;
elsif upper(c.p2) = 'FALSE' then
L_VALIDATE_COUNTY := false;
elsif c.p2 is not null then
hr_utility.set_message(800,'HR_50327_DP_TYPE_ERR');
hr_utility.set_message_token('TYPE','BOOLEAN');
hr_utility.set_message_token('PARAMETER','P_VALIDATE_COUNTY');
hr_utility.set_message_token('VALUE',c.p2);
hr_utility.set_message_token('TABLE','HR_PUMP_BATCH_LINES');
hr_utility.raise_error;
end if;
--
L_COMMENTS := c.plongval;
if L_COMMENTS = cn then
L_COMMENTS := null;
end if;
--
if c.p45 is null then
L_ADDRESS_ID:=nn;
else
L_ADDRESS_ID := 
hr_pump_get.get_address_id
(P_ADDRESS_USER_KEY => c.p45);
end if;
--
if c.p45 is null or
c.p1 is null then
L_OBJECT_VERSION_NUMBER:=nn;
else
L_OBJECT_VERSION_NUMBER := 
hr_pump_get.GET_ADR_OVN
(P_ADDRESS_USER_KEY => c.p45
,P_EFFECTIVE_DATE => c.p1);
end if;
--
if c.d46=cn then
L_COUNTRY:=vn;
elsif c.d46 is null then 
L_COUNTRY:=vh;
else
L_COUNTRY := 
hr_pump_get.GET_COUNTRY
(P_COUNTRY => c.p46);
end if;
--
hr_data_pump.api_trc_on;
HR_PERSON_ADDRESS_API.UPDATE_US_PERSON_ADDRESS
(p_validate => l_validate
,P_EFFECTIVE_DATE => c.p1
,P_VALIDATE_COUNTY => L_VALIDATE_COUNTY
,P_ADDRESS_ID => L_ADDRESS_ID
,P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER
,P_DATE_FROM => c.p3
,P_DATE_TO => c.p4
,P_ADDRESS_TYPE => c.p5
,P_COMMENTS => L_COMMENTS
,P_ADDRESS_LINE1 => c.p7
,P_ADDRESS_LINE2 => c.p8
,P_ADDRESS_LINE3 => c.p9
,P_CITY => c.p10
,P_STATE => c.p11
,P_ZIP_CODE => c.p12
,P_COUNTY => c.p13
,P_COUNTRY => L_COUNTRY
,P_TELEPHONE_NUMBER_1 => c.p14
,P_TELEPHONE_NUMBER_2 => c.p15
,P_ADDR_ATTRIBUTE_CATEGORY => c.p16
,P_ADDR_ATTRIBUTE1 => c.p17
,P_ADDR_ATTRIBUTE2 => c.p18
,P_ADDR_ATTRIBUTE3 => c.p19
,P_ADDR_ATTRIBUTE4 => c.p20
,P_ADDR_ATTRIBUTE5 => c.p21
,P_ADDR_ATTRIBUTE6 => c.p22
,P_ADDR_ATTRIBUTE7 => c.p23
,P_ADDR_ATTRIBUTE8 => c.p24
,P_ADDR_ATTRIBUTE9 => c.p25
,P_ADDR_ATTRIBUTE10 => c.p26
,P_ADDR_ATTRIBUTE11 => c.p27
,P_ADDR_ATTRIBUTE12 => c.p28
,P_ADDR_ATTRIBUTE13 => c.p29
,P_ADDR_ATTRIBUTE14 => c.p30
,P_ADDR_ATTRIBUTE15 => c.p31
,P_ADDR_ATTRIBUTE16 => c.p32
,P_ADDR_ATTRIBUTE17 => c.p33
,P_ADDR_ATTRIBUTE18 => c.p34
,P_ADDR_ATTRIBUTE19 => c.p35
,P_ADDR_ATTRIBUTE20 => c.p36
,P_ADD_INFORMATION13 => c.p37
,P_ADD_INFORMATION14 => c.p38
,P_ADD_INFORMATION15 => c.p39
,P_ADD_INFORMATION16 => c.p40
,P_ADD_INFORMATION17 => c.p41
,P_ADD_INFORMATION18 => c.p42
,P_ADD_INFORMATION19 => c.p43
,P_ADD_INFORMATION20 => c.p44);
hr_data_pump.api_trc_off;

--

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
end hrdpp_UPDATE_US_PERSON_ADDRESS;

/
