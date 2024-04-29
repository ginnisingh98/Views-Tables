--------------------------------------------------------
--  DDL for Package Body HRDPP_CREATE_PRTT_PREM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_CREATE_PRTT_PREM" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 13:01:35
 * Generated for API: ben_prtt_prem_api.CREATE_PRTT_PREM
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
,P_PRTT_PREM_USER_KEY in varchar2
,P_STD_PREM_VAL in number default null
,P_PPE_ATTRIBUTE_CATEGORY in varchar2 default null
,P_PPE_ATTRIBUTE1 in varchar2 default null
,P_PPE_ATTRIBUTE2 in varchar2 default null
,P_PPE_ATTRIBUTE3 in varchar2 default null
,P_PPE_ATTRIBUTE4 in varchar2 default null
,P_PPE_ATTRIBUTE5 in varchar2 default null
,P_PPE_ATTRIBUTE6 in varchar2 default null
,P_PPE_ATTRIBUTE7 in varchar2 default null
,P_PPE_ATTRIBUTE8 in varchar2 default null
,P_PPE_ATTRIBUTE9 in varchar2 default null
,P_PPE_ATTRIBUTE10 in varchar2 default null
,P_PPE_ATTRIBUTE11 in varchar2 default null
,P_PPE_ATTRIBUTE12 in varchar2 default null
,P_PPE_ATTRIBUTE13 in varchar2 default null
,P_PPE_ATTRIBUTE14 in varchar2 default null
,P_PPE_ATTRIBUTE15 in varchar2 default null
,P_PPE_ATTRIBUTE16 in varchar2 default null
,P_PPE_ATTRIBUTE17 in varchar2 default null
,P_PPE_ATTRIBUTE18 in varchar2 default null
,P_PPE_ATTRIBUTE19 in varchar2 default null
,P_PPE_ATTRIBUTE20 in varchar2 default null
,P_PPE_ATTRIBUTE21 in varchar2 default null
,P_PPE_ATTRIBUTE22 in varchar2 default null
,P_PPE_ATTRIBUTE23 in varchar2 default null
,P_PPE_ATTRIBUTE24 in varchar2 default null
,P_PPE_ATTRIBUTE25 in varchar2 default null
,P_PPE_ATTRIBUTE26 in varchar2 default null
,P_PPE_ATTRIBUTE27 in varchar2 default null
,P_PPE_ATTRIBUTE28 in varchar2 default null
,P_PPE_ATTRIBUTE29 in varchar2 default null
,P_PPE_ATTRIBUTE30 in varchar2 default null
,P_PROGRAM_UPDATE_DATE in date default null
,P_EFFECTIVE_DATE in date
,P_STD_PREM_UOM in varchar2 default null
,P_ACTUAL_PREMIUM in varchar2 default null
,P_PRTT_ENRT_RSLT_USER_KEY in varchar2 default null
,P_PER_IN_LER_USER_KEY in varchar2) is
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
,pval037
,pval038
,pval039
,pval040
,pval041
,pval042)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,1009
,'U'
,p_user_sequence
,p_link_value
,P_PRTT_PREM_USER_KEY
,P_STD_PREM_VAL
,P_PPE_ATTRIBUTE_CATEGORY
,P_PPE_ATTRIBUTE1
,P_PPE_ATTRIBUTE2
,P_PPE_ATTRIBUTE3
,P_PPE_ATTRIBUTE4
,P_PPE_ATTRIBUTE5
,P_PPE_ATTRIBUTE6
,P_PPE_ATTRIBUTE7
,P_PPE_ATTRIBUTE8
,P_PPE_ATTRIBUTE9
,P_PPE_ATTRIBUTE10
,P_PPE_ATTRIBUTE11
,P_PPE_ATTRIBUTE12
,P_PPE_ATTRIBUTE13
,P_PPE_ATTRIBUTE14
,P_PPE_ATTRIBUTE15
,P_PPE_ATTRIBUTE16
,P_PPE_ATTRIBUTE17
,P_PPE_ATTRIBUTE18
,P_PPE_ATTRIBUTE19
,P_PPE_ATTRIBUTE20
,P_PPE_ATTRIBUTE21
,P_PPE_ATTRIBUTE22
,P_PPE_ATTRIBUTE23
,P_PPE_ATTRIBUTE24
,P_PPE_ATTRIBUTE25
,P_PPE_ATTRIBUTE26
,P_PPE_ATTRIBUTE27
,P_PPE_ATTRIBUTE28
,P_PPE_ATTRIBUTE29
,P_PPE_ATTRIBUTE30
,dc(P_PROGRAM_UPDATE_DATE)
,dc(P_EFFECTIVE_DATE)
,P_STD_PREM_UOM
,P_ACTUAL_PREMIUM
,P_PRTT_ENRT_RSLT_USER_KEY
,P_PER_IN_LER_USER_KEY);
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
decode(l.pval004,cn,nn,vn,nn,n(l.pval004)) p4,
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
l.pval036 p36,
decode(l.pval037,cn,dn,vn,dn,d(l.pval037)) p37,
l.pval037 d37,
decode(l.pval038,cn,dn,d(l.pval038)) p38,
decode(l.pval039,cn,vn,vn,vn,l.pval039) p39,
l.pval039 d39,
decode(l.pval040,cn,vn,vn,vn,l.pval040) p40,
l.pval040 d40,
decode(l.pval041,cn,vn,vn,vn,l.pval041) p41,
l.pval041 d41,
decode(l.pval042,cn,vn,l.pval042) p42
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_PRTT_PREM_ID number;
L_STD_PREM_UOM varchar2(2000);
L_ACTL_PREM_ID number;
L_PRTT_ENRT_RSLT_ID number;
L_PER_IN_LER_ID number;
L_REQUEST_ID number;
L_PROGRAM_APPLICATION_ID number;
L_PROGRAM_ID number;
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
if c.p39 is null or
c.p38 is null then
L_STD_PREM_UOM:=vn;
else
L_STD_PREM_UOM := 
hr_pump_get.GET_STD_PREM_UOM_CODE
(P_STD_PREM_UOM => c.p39
,P_EFFECTIVE_DATE => c.p38);
end if;
--
if c.p40 is null or
c.p38 is null then
L_ACTL_PREM_ID:=nn;
else
L_ACTL_PREM_ID := 
hr_pump_get.get_actl_prem_id
(P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_ACTUAL_PREMIUM => c.p40
,P_EFFECTIVE_DATE => c.p38);
end if;
--
if c.p41 is null then
L_PRTT_ENRT_RSLT_ID:=nn;
else
L_PRTT_ENRT_RSLT_ID := 
hr_pump_get.get_prtt_enrt_rslt_id
(P_PRTT_ENRT_RSLT_USER_KEY => c.p41);
end if;
--
if c.p42 is null then
L_PER_IN_LER_ID:=nn;
else
L_PER_IN_LER_ID := 
hr_pump_get.get_per_in_ler_id
(P_PER_IN_LER_USER_KEY => c.p42);
end if;
--
L_REQUEST_ID := 
hr_pump_get.get_request_id;
--
L_PROGRAM_APPLICATION_ID := 
hr_pump_get.get_program_application_id;
--
L_PROGRAM_ID := 
hr_pump_get.get_program_id;
--
hr_data_pump.api_trc_on;
ben_prtt_prem_api.CREATE_PRTT_PREM
(p_validate => l_validate
,P_PRTT_PREM_ID => L_PRTT_PREM_ID
,P_EFFECTIVE_START_DATE => c.p2
,P_EFFECTIVE_END_DATE => c.p3
,P_STD_PREM_UOM => L_STD_PREM_UOM
,P_STD_PREM_VAL => c.p4
,P_ACTL_PREM_ID => L_ACTL_PREM_ID
,P_PRTT_ENRT_RSLT_ID => L_PRTT_ENRT_RSLT_ID
,P_PER_IN_LER_ID => L_PER_IN_LER_ID
,p_business_group_id => p_business_group_id
,P_PPE_ATTRIBUTE_CATEGORY => c.p5
,P_PPE_ATTRIBUTE1 => c.p6
,P_PPE_ATTRIBUTE2 => c.p7
,P_PPE_ATTRIBUTE3 => c.p8
,P_PPE_ATTRIBUTE4 => c.p9
,P_PPE_ATTRIBUTE5 => c.p10
,P_PPE_ATTRIBUTE6 => c.p11
,P_PPE_ATTRIBUTE7 => c.p12
,P_PPE_ATTRIBUTE8 => c.p13
,P_PPE_ATTRIBUTE9 => c.p14
,P_PPE_ATTRIBUTE10 => c.p15
,P_PPE_ATTRIBUTE11 => c.p16
,P_PPE_ATTRIBUTE12 => c.p17
,P_PPE_ATTRIBUTE13 => c.p18
,P_PPE_ATTRIBUTE14 => c.p19
,P_PPE_ATTRIBUTE15 => c.p20
,P_PPE_ATTRIBUTE16 => c.p21
,P_PPE_ATTRIBUTE17 => c.p22
,P_PPE_ATTRIBUTE18 => c.p23
,P_PPE_ATTRIBUTE19 => c.p24
,P_PPE_ATTRIBUTE20 => c.p25
,P_PPE_ATTRIBUTE21 => c.p26
,P_PPE_ATTRIBUTE22 => c.p27
,P_PPE_ATTRIBUTE23 => c.p28
,P_PPE_ATTRIBUTE24 => c.p29
,P_PPE_ATTRIBUTE25 => c.p30
,P_PPE_ATTRIBUTE26 => c.p31
,P_PPE_ATTRIBUTE27 => c.p32
,P_PPE_ATTRIBUTE28 => c.p33
,P_PPE_ATTRIBUTE29 => c.p34
,P_PPE_ATTRIBUTE30 => c.p35
,P_OBJECT_VERSION_NUMBER => c.p36
,P_REQUEST_ID => L_REQUEST_ID
,P_PROGRAM_APPLICATION_ID => L_PROGRAM_APPLICATION_ID
,P_PROGRAM_ID => L_PROGRAM_ID
,P_PROGRAM_UPDATE_DATE => c.p37
,P_EFFECTIVE_DATE => c.p38);
hr_data_pump.api_trc_off;
--
iuk(p_batch_line_id,c.p1,L_PRTT_PREM_ID);
--
update hr_pump_batch_lines l set
l.pval001 = decode(c.p1,null,cn,c.p1),
l.pval002 = decode(c.p2,null,cn,dc(c.p2)),
l.pval003 = decode(c.p3,null,cn,dc(c.p3)),
l.pval036 = decode(c.p36,null,cn,c.p36)
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
end hrdpp_CREATE_PRTT_PREM;

/