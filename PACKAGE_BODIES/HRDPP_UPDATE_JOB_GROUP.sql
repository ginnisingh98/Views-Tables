--------------------------------------------------------
--  DDL for Package Body HRDPP_UPDATE_JOB_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_UPDATE_JOB_GROUP" as
/*
 * Generated by hr_pump_meta_mapper at: 2013/08/29 22:08:00
 * Generated for API: PER_JOB_GROUP_API.UPDATE_JOB_GROUP
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
,P_LEGISLATION_CODE in varchar2 default null
,P_INTERNAL_NAME in varchar2
,P_DISPLAYED_NAME in varchar2
,P_ID_FLEX_NUM in number
,P_MASTER_FLAG in varchar2 default null
,P_JOB_GROUP_USER_KEY in varchar2) is
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
,pval007)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,1592
,'U'
,p_user_sequence
,p_link_value
,dc(P_EFFECTIVE_DATE)
,P_LEGISLATION_CODE
,P_INTERNAL_NAME
,P_DISPLAYED_NAME
,P_ID_FLEX_NUM
,P_MASTER_FLAG
,P_JOB_GROUP_USER_KEY);
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
decode(l.pval003,cn,vn,l.pval003) p3,
decode(l.pval004,cn,vn,l.pval004) p4,
decode(l.pval005,cn,nn,n(l.pval005)) p5,
decode(l.pval006,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval006,'YES_NO',d(l.pval001),vn)) p6,
l.pval006 d6,
decode(l.pval007,cn,vn,l.pval007) p7
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_JOB_GROUP_ID number;
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
if c.p7 is null then
L_JOB_GROUP_ID:=nn;
else
L_JOB_GROUP_ID := 
hr_pump_get.get_job_group_id
(P_JOB_GROUP_USER_KEY => c.p7);
end if;
--
if c.p7 is null then
L_OBJECT_VERSION_NUMBER:=nn;
else
L_OBJECT_VERSION_NUMBER := 
hr_pump_get.GET_JGR_OVN
(P_JOB_GROUP_USER_KEY => c.p7);
end if;
--
hr_data_pump.api_trc_on;
PER_JOB_GROUP_API.UPDATE_JOB_GROUP
(p_validate => l_validate
,P_EFFECTIVE_DATE => c.p1
,P_JOB_GROUP_ID => L_JOB_GROUP_ID
,p_business_group_id => p_business_group_id
,P_LEGISLATION_CODE => c.p2
,P_INTERNAL_NAME => c.p3
,P_DISPLAYED_NAME => c.p4
,P_ID_FLEX_NUM => c.p5
,P_MASTER_FLAG => c.p6
,P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER);
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
end hrdpp_UPDATE_JOB_GROUP;

/
