--------------------------------------------------------
--  DDL for Package Body HRDPP_UPDATE_IN_CONTACT_EXTRA_
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_UPDATE_IN_CONTACT_EXTRA_" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:25
 * Generated for API: hr_in_contact_extra_info_api.update_in_contact_extra_info
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
,P_INFORMATION_TYPE in varchar2 default null
,P_NOMINATION_TYPE in varchar2 default null
,P_PERCENT_SHARE in varchar2 default null
,P_NOMINATION_CHANGE_REASON in varchar2 default null
,P_CEI_ATTRIBUTE_CATEGORY in varchar2 default null
,P_CEI_ATTRIBUTE1 in varchar2 default null
,P_CEI_ATTRIBUTE2 in varchar2 default null
,P_CEI_ATTRIBUTE3 in varchar2 default null
,P_CEI_ATTRIBUTE4 in varchar2 default null
,P_CEI_ATTRIBUTE5 in varchar2 default null
,P_CEI_ATTRIBUTE6 in varchar2 default null
,P_CEI_ATTRIBUTE7 in varchar2 default null
,P_CEI_ATTRIBUTE8 in varchar2 default null
,P_CEI_ATTRIBUTE9 in varchar2 default null
,P_CEI_ATTRIBUTE10 in varchar2 default null
,P_CEI_ATTRIBUTE11 in varchar2 default null
,P_CEI_ATTRIBUTE12 in varchar2 default null
,P_CEI_ATTRIBUTE13 in varchar2 default null
,P_CEI_ATTRIBUTE14 in varchar2 default null
,P_CEI_ATTRIBUTE15 in varchar2 default null
,P_CEI_ATTRIBUTE16 in varchar2 default null
,P_CEI_ATTRIBUTE17 in varchar2 default null
,P_CEI_ATTRIBUTE18 in varchar2 default null
,P_CEI_ATTRIBUTE19 in varchar2 default null
,P_CEI_ATTRIBUTE20 in varchar2 default null
,P_CONTACT_USER_KEY in varchar2 default null
,P_CONTACTEE_USER_KEY in varchar2 default null
,P_CONTACT_EXTRA_INFO_USER_KEY in varchar2) is
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
,pval030
,pval031
,pval032)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,3222
,'U'
,p_user_sequence
,p_link_value
,dc(P_EFFECTIVE_DATE)
,P_DATETRACK_UPDATE_MODE
,P_INFORMATION_TYPE
,P_NOMINATION_TYPE
,P_PERCENT_SHARE
,P_NOMINATION_CHANGE_REASON
,P_CEI_ATTRIBUTE_CATEGORY
,P_CEI_ATTRIBUTE1
,P_CEI_ATTRIBUTE2
,P_CEI_ATTRIBUTE3
,P_CEI_ATTRIBUTE4
,P_CEI_ATTRIBUTE5
,P_CEI_ATTRIBUTE6
,P_CEI_ATTRIBUTE7
,P_CEI_ATTRIBUTE8
,P_CEI_ATTRIBUTE9
,P_CEI_ATTRIBUTE10
,P_CEI_ATTRIBUTE11
,P_CEI_ATTRIBUTE12
,P_CEI_ATTRIBUTE13
,P_CEI_ATTRIBUTE14
,P_CEI_ATTRIBUTE15
,P_CEI_ATTRIBUTE16
,P_CEI_ATTRIBUTE17
,P_CEI_ATTRIBUTE18
,P_CEI_ATTRIBUTE19
,P_CEI_ATTRIBUTE20
,P_CONTACT_USER_KEY
,P_CONTACTEE_USER_KEY
,P_CONTACT_EXTRA_INFO_USER_KEY);
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
decode(l.pval004,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval004,'IN_NOMINATION_TYPES',d(l.pval001),vn)) p4,
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
decode(l.pval028,cn,dn,d(l.pval028)) p28,
decode(l.pval029,cn,dn,d(l.pval029)) p29,
decode(l.pval030,cn,vn,vn,vn,l.pval030) p30,
l.pval030 d30,
decode(l.pval031,cn,vn,vn,vn,l.pval031) p31,
l.pval031 d31,
decode(l.pval032,cn,vn,l.pval032) p32
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_CONTACT_RELATIONSHIP_ID number;
L_CONTACT_EXTRA_INFO_ID number;
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
if c.d30=cn or
c.d31=cn then
L_CONTACT_RELATIONSHIP_ID:=nn;
elsif c.d30 is null or
c.d31 is null then 
L_CONTACT_RELATIONSHIP_ID:=nh;
else
L_CONTACT_RELATIONSHIP_ID := 
hr_pump_get.get_contact_relationship_id
(P_CONTACT_USER_KEY => c.p30
,P_CONTACTEE_USER_KEY => c.p31);
end if;
--
if c.p32 is null then
L_CONTACT_EXTRA_INFO_ID:=nn;
else
L_CONTACT_EXTRA_INFO_ID := 
PER_IN_DATA_PUMP.get_contact_extra_info_id
(P_CONTACT_EXTRA_INFO_USER_KEY => c.p32);
end if;
--
if c.p32 is null or
c.p1 is null then
L_OBJECT_VERSION_NUMBER:=nn;
else
L_OBJECT_VERSION_NUMBER := 
PER_IN_DATA_PUMP.GET_CONTACT_EXTRA_INFO_OVN
(P_CONTACT_EXTRA_INFO_USER_KEY => c.p32
,P_EFFECTIVE_DATE => c.p1);
end if;
--
hr_data_pump.api_trc_on;
hr_in_contact_extra_info_api.update_in_contact_extra_info
(p_validate => l_validate
,P_EFFECTIVE_DATE => c.p1
,P_DATETRACK_UPDATE_MODE => c.p2
,P_CONTACT_RELATIONSHIP_ID => L_CONTACT_RELATIONSHIP_ID
,P_INFORMATION_TYPE => c.p3
,P_NOMINATION_TYPE => c.p4
,P_PERCENT_SHARE => c.p5
,P_NOMINATION_CHANGE_REASON => c.p6
,P_CEI_ATTRIBUTE_CATEGORY => c.p7
,P_CEI_ATTRIBUTE1 => c.p8
,P_CEI_ATTRIBUTE2 => c.p9
,P_CEI_ATTRIBUTE3 => c.p10
,P_CEI_ATTRIBUTE4 => c.p11
,P_CEI_ATTRIBUTE5 => c.p12
,P_CEI_ATTRIBUTE6 => c.p13
,P_CEI_ATTRIBUTE7 => c.p14
,P_CEI_ATTRIBUTE8 => c.p15
,P_CEI_ATTRIBUTE9 => c.p16
,P_CEI_ATTRIBUTE10 => c.p17
,P_CEI_ATTRIBUTE11 => c.p18
,P_CEI_ATTRIBUTE12 => c.p19
,P_CEI_ATTRIBUTE13 => c.p20
,P_CEI_ATTRIBUTE14 => c.p21
,P_CEI_ATTRIBUTE15 => c.p22
,P_CEI_ATTRIBUTE16 => c.p23
,P_CEI_ATTRIBUTE17 => c.p24
,P_CEI_ATTRIBUTE18 => c.p25
,P_CEI_ATTRIBUTE19 => c.p26
,P_CEI_ATTRIBUTE20 => c.p27
,P_CONTACT_EXTRA_INFO_ID => L_CONTACT_EXTRA_INFO_ID
,P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER
,P_EFFECTIVE_START_DATE => c.p28
,P_EFFECTIVE_END_DATE => c.p29);
hr_data_pump.api_trc_off;

--
update hr_pump_batch_lines l set
l.pval028 = decode(c.p28,null,cn,dc(c.p28)),
l.pval029 = decode(c.p29,null,cn,dc(c.p29))
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
end hrdpp_update_in_contact_extra_;

/