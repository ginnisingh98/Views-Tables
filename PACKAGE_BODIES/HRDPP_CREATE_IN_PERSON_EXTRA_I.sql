--------------------------------------------------------
--  DDL for Package Body HRDPP_CREATE_IN_PERSON_EXTRA_I
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_CREATE_IN_PERSON_EXTRA_I" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:57
 * Generated for API: hr_in_person_extra_info_api.create_in_person_extra_info
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
,P_PEI_ATTRIBUTE_CATEGORY in varchar2 default null
,P_PEI_ATTRIBUTE1 in varchar2 default null
,P_PEI_ATTRIBUTE2 in varchar2 default null
,P_PEI_ATTRIBUTE3 in varchar2 default null
,P_PEI_ATTRIBUTE4 in varchar2 default null
,P_PEI_ATTRIBUTE5 in varchar2 default null
,P_PEI_ATTRIBUTE6 in varchar2 default null
,P_PEI_ATTRIBUTE7 in varchar2 default null
,P_PEI_ATTRIBUTE8 in varchar2 default null
,P_PEI_ATTRIBUTE9 in varchar2 default null
,P_PEI_ATTRIBUTE10 in varchar2 default null
,P_PEI_ATTRIBUTE11 in varchar2 default null
,P_PEI_ATTRIBUTE12 in varchar2 default null
,P_PEI_ATTRIBUTE13 in varchar2 default null
,P_PEI_ATTRIBUTE14 in varchar2 default null
,P_PEI_ATTRIBUTE15 in varchar2 default null
,P_PEI_ATTRIBUTE16 in varchar2 default null
,P_PEI_ATTRIBUTE17 in varchar2 default null
,P_PEI_ATTRIBUTE18 in varchar2 default null
,P_PEI_ATTRIBUTE19 in varchar2 default null
,P_PEI_ATTRIBUTE20 in varchar2 default null
,P_RELIGION in varchar2 default null
,P_COMMUNITY in varchar2 default null
,P_CASTE_OR_TRIBE in varchar2 default null
,P_PERSON_EXTRA_INFO_USER_KEY in varchar2
,P_PERSON_USER_KEY in varchar2
,P_HEIGHT in varchar2 default null
,P_WEIGHT in varchar2 default null) is
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
,pval027
,pval028
,pval029)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,3209
,'U'
,p_user_sequence
,p_link_value
,P_PEI_ATTRIBUTE_CATEGORY
,P_PEI_ATTRIBUTE1
,P_PEI_ATTRIBUTE2
,P_PEI_ATTRIBUTE3
,P_PEI_ATTRIBUTE4
,P_PEI_ATTRIBUTE5
,P_PEI_ATTRIBUTE6
,P_PEI_ATTRIBUTE7
,P_PEI_ATTRIBUTE8
,P_PEI_ATTRIBUTE9
,P_PEI_ATTRIBUTE10
,P_PEI_ATTRIBUTE11
,P_PEI_ATTRIBUTE12
,P_PEI_ATTRIBUTE13
,P_PEI_ATTRIBUTE14
,P_PEI_ATTRIBUTE15
,P_PEI_ATTRIBUTE16
,P_PEI_ATTRIBUTE17
,P_PEI_ATTRIBUTE18
,P_PEI_ATTRIBUTE19
,P_PEI_ATTRIBUTE20
,P_RELIGION
,P_COMMUNITY
,P_CASTE_OR_TRIBE
,P_PERSON_EXTRA_INFO_USER_KEY
,P_PERSON_USER_KEY
,P_HEIGHT
,P_WEIGHT);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,vn,vn,vn,l.pval001) p1,
l.pval001 d1,
decode(l.pval002,cn,vn,vn,vn,l.pval002) p2,
l.pval002 d2,
decode(l.pval003,cn,vn,vn,vn,l.pval003) p3,
l.pval003 d3,
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
decode(l.pval022,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval022,'IN_RELEGION',dn,vn)) p22,
l.pval022 d22,
decode(l.pval023,cn,vn,vn,vn,
 hr_pump_get.gl(l.pval023,'IN_COMMUNITY',dn,vn)) p23,
l.pval023 d23,
decode(l.pval024,cn,vn,vn,vn,l.pval024) p24,
l.pval024 d24,
l.pval025 p25,
l.pval026 p26,
decode(l.pval027,cn,vn,l.pval027) p27,
decode(l.pval028,cn,vn,vn,vn,l.pval028) p28,
l.pval028 d28,
decode(l.pval029,cn,vn,vn,vn,l.pval029) p29,
l.pval029 d29
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_PERSON_EXTRA_INFO_ID number;
L_PERSON_ID number;
L_HEIGHT varchar2(2000);
L_WEIGHT varchar2(2000);
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
if c.p27 is null then
L_PERSON_ID:=nn;
else
L_PERSON_ID := 
hr_pump_get.get_person_id
(P_PERSON_USER_KEY => c.p27);
end if;
--
if c.p28 is null then
L_HEIGHT:=vn;
else
L_HEIGHT := 
PER_IN_DATA_PUMP.GET_HEIGHT
(P_HEIGHT => c.p28);
end if;
--
if c.p29 is null then
L_WEIGHT:=vn;
else
L_WEIGHT := 
PER_IN_DATA_PUMP.GET_WEIGHT
(P_WEIGHT => c.p29);
end if;
--
hr_data_pump.api_trc_on;
hr_in_person_extra_info_api.create_in_person_extra_info
(p_validate => l_validate
,P_PERSON_ID => L_PERSON_ID
,P_PEI_ATTRIBUTE_CATEGORY => c.p1
,P_PEI_ATTRIBUTE1 => c.p2
,P_PEI_ATTRIBUTE2 => c.p3
,P_PEI_ATTRIBUTE3 => c.p4
,P_PEI_ATTRIBUTE4 => c.p5
,P_PEI_ATTRIBUTE5 => c.p6
,P_PEI_ATTRIBUTE6 => c.p7
,P_PEI_ATTRIBUTE7 => c.p8
,P_PEI_ATTRIBUTE8 => c.p9
,P_PEI_ATTRIBUTE9 => c.p10
,P_PEI_ATTRIBUTE10 => c.p11
,P_PEI_ATTRIBUTE11 => c.p12
,P_PEI_ATTRIBUTE12 => c.p13
,P_PEI_ATTRIBUTE13 => c.p14
,P_PEI_ATTRIBUTE14 => c.p15
,P_PEI_ATTRIBUTE15 => c.p16
,P_PEI_ATTRIBUTE16 => c.p17
,P_PEI_ATTRIBUTE17 => c.p18
,P_PEI_ATTRIBUTE18 => c.p19
,P_PEI_ATTRIBUTE19 => c.p20
,P_PEI_ATTRIBUTE20 => c.p21
,P_RELIGION => c.p22
,P_COMMUNITY => c.p23
,P_CASTE_OR_TRIBE => c.p24
,P_HEIGHT => L_HEIGHT
,P_WEIGHT => L_WEIGHT
,P_PERSON_EXTRA_INFO_ID => L_PERSON_EXTRA_INFO_ID
,P_OBJECT_VERSION_NUMBER => c.p26);
hr_data_pump.api_trc_off;
--
iuk(p_batch_line_id,c.p25,L_PERSON_EXTRA_INFO_ID);
--
update hr_pump_batch_lines l set
l.pval025 = decode(c.p25,null,cn,c.p25),
l.pval026 = decode(c.p26,null,cn,c.p26)
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
end hrdpp_create_in_person_extra_i;

/
