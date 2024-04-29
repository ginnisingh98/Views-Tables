--------------------------------------------------------
--  DDL for Package Body HRDPP_UPDATE_ADI_TAX_CRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_UPDATE_ADI_TAX_CRP" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:56
 * Generated for API: HR_AU_TAX_API.UPDATE_ADI_TAX_CRP
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
,P_HIRE_DATE in date
,P_LEGAL_EMPLOYER in varchar2
,P_TAX_FILE_NUMBER in varchar2
,P_TAX_FREE_THRESHOLD in varchar2
,P_AUSTRALIAN_RESIDENT in varchar2
,P_HECS in varchar2
,P_SFSS in varchar2
,P_LEAVE_LOADING in varchar2
,P_BASIS_OF_PAYMENT in varchar2
,P_DECLARATION_SIGNED_DATE in varchar2
,P_MEDICARE_LEVY_SURCHARGE in varchar2
,P_MEDICARE_LEVY_EXEMPTION in varchar2
,P_MEDICARE_LEVY_DEP_CHILDREN in varchar2 default null
,P_MEDICARE_LEVY_SPOUSE in varchar2
,P_TAX_VARIATION_TYPE in varchar2
,P_TAX_VARIATION_AMOUNT in number default null
,I_TAX_VARIATION_AMOUNT in varchar2 default 'N'
,P_TAX_VARIATION_BONUS in varchar2
,P_REBATE_AMOUNT in number default null
,I_REBATE_AMOUNT in varchar2 default 'N'
,P_SAVINGS_REBATE in varchar2
,P_FTB_CLAIM in varchar2
,P_SENIOR_AUSTRALIAN in varchar2
,P_EFFECTIVE_DATE in date
,P_ASSIGNMENT_USER_KEY in varchar2
,P_PAYROLL_NAME in varchar2) is
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
,pval024)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,3620
,'U'
,p_user_sequence
,p_link_value
,dc(P_HIRE_DATE)
,P_LEGAL_EMPLOYER
,P_TAX_FILE_NUMBER
,P_TAX_FREE_THRESHOLD
,P_AUSTRALIAN_RESIDENT
,P_HECS
,P_SFSS
,P_LEAVE_LOADING
,P_BASIS_OF_PAYMENT
,P_DECLARATION_SIGNED_DATE
,P_MEDICARE_LEVY_SURCHARGE
,P_MEDICARE_LEVY_EXEMPTION
,P_MEDICARE_LEVY_DEP_CHILDREN
,P_MEDICARE_LEVY_SPOUSE
,P_TAX_VARIATION_TYPE
,nd(P_TAX_VARIATION_AMOUNT,I_TAX_VARIATION_AMOUNT)
,P_TAX_VARIATION_BONUS
,nd(P_REBATE_AMOUNT,I_REBATE_AMOUNT)
,P_SAVINGS_REBATE
,P_FTB_CLAIM
,P_SENIOR_AUSTRALIAN
,dc(P_EFFECTIVE_DATE)
,P_ASSIGNMENT_USER_KEY
,P_PAYROLL_NAME);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,dn,d(l.pval001)) p1,
decode(l.pval002,cn,vn,l.pval002) p2,
decode(l.pval003,cn,vn,l.pval003) p3,
decode(l.pval004,cn,vn,
 hr_pump_get.gl(l.pval004,'YES_NO',d(l.pval022),vn)) p4,
decode(l.pval005,cn,vn,
 hr_pump_get.gl(l.pval005,'YES_NO',d(l.pval022),vn)) p5,
decode(l.pval006,cn,vn,
 hr_pump_get.gl(l.pval006,'YES_NO',d(l.pval022),vn)) p6,
decode(l.pval007,cn,vn,
 hr_pump_get.gl(l.pval007,'YES_NO',d(l.pval022),vn)) p7,
decode(l.pval008,cn,vn,
 hr_pump_get.gl(l.pval008,'YES_NO',d(l.pval022),vn)) p8,
decode(l.pval009,cn,vn,
 hr_pump_get.gl(l.pval009,'AU_TAX_PAYMENT_BASIS',d(l.pval022),vn)) p9,
decode(l.pval010,cn,vn,l.pval010) p10,
decode(l.pval011,cn,vn,
 hr_pump_get.gl(l.pval011,'YES_NO',d(l.pval022),vn)) p11,
decode(l.pval012,cn,vn,
 hr_pump_get.gl(l.pval012,'AU_MED_LEV_VAR',d(l.pval022),vn)) p12,
decode(l.pval013,cn,vn,vn,vh,l.pval013) p13,
l.pval013 d13,
decode(l.pval014,cn,vn,
 hr_pump_get.gl(l.pval014,'YES_NO',d(l.pval022),vn)) p14,
decode(l.pval015,cn,vn,
 hr_pump_get.gl(l.pval015,'AU_TAX_VARIATION',d(l.pval022),vn)) p15,
decode(l.pval016,cn,nn,vn,nh,n(l.pval016)) p16,
l.pval016 d16,
decode(l.pval017,cn,vn,l.pval017) p17,
decode(l.pval018,cn,nn,vn,nh,n(l.pval018)) p18,
l.pval018 d18,
decode(l.pval019,cn,vn,
 hr_pump_get.gl(l.pval019,'YES_NO',d(l.pval022),vn)) p19,
decode(l.pval020,cn,vn,
 hr_pump_get.gl(l.pval020,'YES_NO',d(l.pval022),vn)) p20,
decode(l.pval021,cn,vn,
 hr_pump_get.gl(l.pval021,'AU_TAX_SENIOR',d(l.pval022),vn)) p21,
decode(l.pval022,cn,dn,d(l.pval022)) p22,
decode(l.pval023,cn,vn,l.pval023) p23,
decode(l.pval024,cn,vn,l.pval024) p24
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_ASSIGNMENT_ID number;
L_PAYROLL_ID number;
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
if c.p23 is null then
L_ASSIGNMENT_ID:=nn;
else
L_ASSIGNMENT_ID := 
hr_pump_get.GET_ASSIGNMENT_ID
(P_ASSIGNMENT_USER_KEY => c.p23);
end if;
--
if c.p24 is null or
c.p22 is null then
L_PAYROLL_ID:=nn;
else
L_PAYROLL_ID := 
hr_pump_get.GET_PAYROLL_ID
(P_PAYROLL_NAME => c.p24
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p22);
end if;
--
hr_data_pump.api_trc_on;
HR_AU_TAX_API.UPDATE_ADI_TAX_CRP
(p_validate => l_validate
,P_ASSIGNMENT_ID => L_ASSIGNMENT_ID
,P_HIRE_DATE => c.p1
,p_business_group_id => p_business_group_id
,P_PAYROLL_ID => L_PAYROLL_ID
,P_LEGAL_EMPLOYER => c.p2
,P_TAX_FILE_NUMBER => c.p3
,P_TAX_FREE_THRESHOLD => c.p4
,P_AUSTRALIAN_RESIDENT => c.p5
,P_HECS => c.p6
,P_SFSS => c.p7
,P_LEAVE_LOADING => c.p8
,P_BASIS_OF_PAYMENT => c.p9
,P_DECLARATION_SIGNED_DATE => c.p10
,P_MEDICARE_LEVY_SURCHARGE => c.p11
,P_MEDICARE_LEVY_EXEMPTION => c.p12
,P_MEDICARE_LEVY_DEP_CHILDREN => c.p13
,P_MEDICARE_LEVY_SPOUSE => c.p14
,P_TAX_VARIATION_TYPE => c.p15
,P_TAX_VARIATION_AMOUNT => c.p16
,P_TAX_VARIATION_BONUS => c.p17
,P_REBATE_AMOUNT => c.p18
,P_SAVINGS_REBATE => c.p19
,P_FTB_CLAIM => c.p20
,P_SENIOR_AUSTRALIAN => c.p21
,P_EFFECTIVE_DATE => c.p22);
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
end hrdpp_UPDATE_ADI_TAX_CRP;

/
