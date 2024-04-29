--------------------------------------------------------
--  DDL for Package Body HRDPP_CREATE_TAXABILITY_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_CREATE_TAXABILITY_RULES" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:10
 * Generated for API: PAY_AC_TAXABILITY_WRAPPER.CREATE_TAXABILITY_RULES
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
,P_CLASSIFICATION_ID in number
,P_TAX_CATEGORY in varchar2
,P_JURISDICTION in varchar2 default null
,P_LEGISLATION_CODE in varchar2 default null
,P_INPUT_TAX_TYPE_VALUE1 in varchar2 default null
,P_INPUT_TAX_TYPE_VALUE2 in varchar2 default null
,P_INPUT_TAX_TYPE_VALUE3 in varchar2 default null
,P_INPUT_TAX_TYPE_VALUE4 in varchar2 default null
,P_INPUT_TAX_TYPE_VALUE5 in varchar2 default null
,P_INPUT_TAX_TYPE_VALUE6 in varchar2 default null
,P_INPUT_TAX_TYPE_VALUE7 in varchar2 default null
,P_INPUT_TAX_TYPE_VALUE8 in varchar2 default null
,P_INPUT_TAX_TYPE_VALUE9 in varchar2 default null
,P_INPUT_TAX_TYPE_VALUE10 in varchar2 default null
,P_INPUT_TAX_TYPE_VALUE11 in varchar2 default null
,P_SPREADSHEET_IDENTIFIER in varchar2 default null) is
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
,pval016)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,3849
,'U'
,p_user_sequence
,p_link_value
,P_CLASSIFICATION_ID
,P_TAX_CATEGORY
,P_JURISDICTION
,P_LEGISLATION_CODE
,P_INPUT_TAX_TYPE_VALUE1
,P_INPUT_TAX_TYPE_VALUE2
,P_INPUT_TAX_TYPE_VALUE3
,P_INPUT_TAX_TYPE_VALUE4
,P_INPUT_TAX_TYPE_VALUE5
,P_INPUT_TAX_TYPE_VALUE6
,P_INPUT_TAX_TYPE_VALUE7
,P_INPUT_TAX_TYPE_VALUE8
,P_INPUT_TAX_TYPE_VALUE9
,P_INPUT_TAX_TYPE_VALUE10
,P_INPUT_TAX_TYPE_VALUE11
,P_SPREADSHEET_IDENTIFIER);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,nn,n(l.pval001)) p1,
decode(l.pval002,cn,vn,l.pval002) p2,
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
l.pval016 d16
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
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
PAY_AC_TAXABILITY_WRAPPER.CREATE_TAXABILITY_RULES
(P_CLASSIFICATION_ID => c.p1
,P_TAX_CATEGORY => c.p2
,P_JURISDICTION => c.p3
,P_LEGISLATION_CODE => c.p4
,P_INPUT_TAX_TYPE_VALUE1 => c.p5
,P_INPUT_TAX_TYPE_VALUE2 => c.p6
,P_INPUT_TAX_TYPE_VALUE3 => c.p7
,P_INPUT_TAX_TYPE_VALUE4 => c.p8
,P_INPUT_TAX_TYPE_VALUE5 => c.p9
,P_INPUT_TAX_TYPE_VALUE6 => c.p10
,P_INPUT_TAX_TYPE_VALUE7 => c.p11
,P_INPUT_TAX_TYPE_VALUE8 => c.p12
,P_INPUT_TAX_TYPE_VALUE9 => c.p13
,P_INPUT_TAX_TYPE_VALUE10 => c.p14
,P_INPUT_TAX_TYPE_VALUE11 => c.p15
,P_SPREADSHEET_IDENTIFIER => c.p16);
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
end hrdpp_CREATE_TAXABILITY_RULES;

/
