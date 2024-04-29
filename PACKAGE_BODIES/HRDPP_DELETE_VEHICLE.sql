--------------------------------------------------------
--  DDL for Package Body HRDPP_DELETE_VEHICLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_DELETE_VEHICLE" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:55
 * Generated for API: PQP_VEHICLE_REPOSITORY_API.DELETE_VEHICLE
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
,P_DATETRACK_MODE in varchar2
,P_VEHICLE_REPOSITORY_USER_KEY in varchar2) is
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
,pval005)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,2898
,'U'
,p_user_sequence
,p_link_value
,dc(P_EFFECTIVE_DATE)
,P_DATETRACK_MODE
,P_VEHICLE_REPOSITORY_USER_KEY);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,dn,d(l.pval001)) p1,
decode(l.pval002,cn,vn,l.pval002) p2,
decode(l.pval003,cn,dn,d(l.pval003)) p3,
decode(l.pval004,cn,dn,d(l.pval004)) p4,
decode(l.pval005,cn,vn,l.pval005) p5
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_VEHICLE_REPOSITORY_ID number;
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
if c.p5 is null then
L_VEHICLE_REPOSITORY_ID:=nn;
else
L_VEHICLE_REPOSITORY_ID := 
PQP_VEHICLE_REPOSITORY_MAPPING.get_vehicle_repository_id
(P_VEHICLE_REPOSITORY_USER_KEY => c.p5);
end if;
--
if c.p5 is null then
L_OBJECT_VERSION_NUMBER:=nn;
else
L_OBJECT_VERSION_NUMBER := 
PQP_VEHICLE_REPOSITORY_MAPPING.GET_VEHICLE_REPOSITORY_OVN
(P_VEHICLE_REPOSITORY_USER_KEY => c.p5);
end if;
--
hr_data_pump.api_trc_on;
PQP_VEHICLE_REPOSITORY_API.DELETE_VEHICLE
(p_validate => l_validate
,P_EFFECTIVE_DATE => c.p1
,P_DATETRACK_MODE => c.p2
,P_VEHICLE_REPOSITORY_ID => L_VEHICLE_REPOSITORY_ID
,P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER
,P_EFFECTIVE_START_DATE => c.p3
,P_EFFECTIVE_END_DATE => c.p4);
hr_data_pump.api_trc_off;

--
update hr_pump_batch_lines l set
l.pval003 = decode(c.p3,null,cn,dc(c.p3)),
l.pval004 = decode(c.p4,null,cn,dc(c.p4))
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
end hrdpp_DELETE_VEHICLE;

/
