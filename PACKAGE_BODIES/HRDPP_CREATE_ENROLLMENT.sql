--------------------------------------------------------
--  DDL for Package Body HRDPP_CREATE_ENROLLMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_CREATE_ENROLLMENT" as
/*
 * Generated by hr_pump_meta_mapper at: 2013/08/29 22:08:10
 * Generated for API: BEN_ENROLLMENT_PROCESS.CREATE_ENROLLMENT
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
,P_LIFE_EVENT_DATE in date
,P_ENDED_BNFT_VAL in number default null
,P_EFFECTIVE_DATE in date
,P_BNFT_VAL in number default null
,P_RT_VAL1 in number default null
,P_ANN_RT_VAL1 in number default null
,P_RT_STRT_DT1 in date default null
,P_RT_END_DT1 in date default null
,P_RT_VAL2 in number default null
,P_ANN_RT_VAL2 in number default null
,P_RT_STRT_DT2 in date default null
,P_RT_END_DT2 in date default null
,P_RT_VAL3 in number default null
,P_ANN_RT_VAL3 in number default null
,P_RT_STRT_DT3 in date default null
,P_RT_END_DT3 in date default null
,P_RT_VAL4 in number default null
,P_ANN_RT_VAL4 in number default null
,P_RT_STRT_DT4 in date default null
,P_RT_END_DT4 in date default null
,P_ENRT_CVG_STRT_DT in date default null
,P_ENRT_CVG_THRU_DT in date default null
,P_ORGNL_ENRT_DT in date default null
,P_PROC_CD in varchar2 default null
,P_RECORD_TYP_CD in varchar2
,P_PROGRAM in varchar2 default null
,P_PROGRAM_NUM in number default null
,P_PLAN in varchar2 default null
,P_PLAN_NUM in number default null
,P_OPTION in varchar2 default null
,P_OPTION_NUM in number default null
,P_LIFE_EVENT_REASON in varchar2
,P_ENDED_PLAN in varchar2 default null
,P_ENDED_PLAN_NUM in number default null
,P_ENDED_OPTION in varchar2 default null
,P_ENDED_OPTION_NUM in number default null
,P_EMPLOYEE_NUMBER in varchar2
,P_NATIONAL_IDENTIFIER in varchar2
,P_FULL_NAME in varchar2
,P_DATE_OF_BIRTH in date
,P_PERSON_NUM in number
,P_ACTY_BASE_RATE_NAME1 in varchar2 default null
,P_ACTY_BASE_RATE_NUM1 in number default null
,P_ACTY_BASE_RATE_NAME2 in varchar2 default null
,P_ACTY_BASE_RATE_NUM2 in number default null
,P_ACTY_BASE_RATE_NAME3 in varchar2 default null
,P_ACTY_BASE_RATE_NUM3 in number default null
,P_ACTY_BASE_RATE_NAME4 in varchar2 default null
,P_ACTY_BASE_RATE_NUM4 in number default null) is
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
,pval049)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,3845
,'U'
,p_user_sequence
,p_link_value
,dc(P_LIFE_EVENT_DATE)
,P_ENDED_BNFT_VAL
,dc(P_EFFECTIVE_DATE)
,P_BNFT_VAL
,P_RT_VAL1
,P_ANN_RT_VAL1
,dc(P_RT_STRT_DT1)
,dc(P_RT_END_DT1)
,P_RT_VAL2
,P_ANN_RT_VAL2
,dc(P_RT_STRT_DT2)
,dc(P_RT_END_DT2)
,P_RT_VAL3
,P_ANN_RT_VAL3
,dc(P_RT_STRT_DT3)
,dc(P_RT_END_DT3)
,P_RT_VAL4
,P_ANN_RT_VAL4
,dc(P_RT_STRT_DT4)
,dc(P_RT_END_DT4)
,dc(P_ENRT_CVG_STRT_DT)
,dc(P_ENRT_CVG_THRU_DT)
,dc(P_ORGNL_ENRT_DT)
,P_PROC_CD
,P_RECORD_TYP_CD
,P_PROGRAM
,P_PROGRAM_NUM
,P_PLAN
,P_PLAN_NUM
,P_OPTION
,P_OPTION_NUM
,P_LIFE_EVENT_REASON
,P_ENDED_PLAN
,P_ENDED_PLAN_NUM
,P_ENDED_OPTION
,P_ENDED_OPTION_NUM
,P_EMPLOYEE_NUMBER
,P_NATIONAL_IDENTIFIER
,P_FULL_NAME
,dc(P_DATE_OF_BIRTH)
,P_PERSON_NUM
,P_ACTY_BASE_RATE_NAME1
,P_ACTY_BASE_RATE_NUM1
,P_ACTY_BASE_RATE_NAME2
,P_ACTY_BASE_RATE_NUM2
,P_ACTY_BASE_RATE_NAME3
,P_ACTY_BASE_RATE_NUM3
,P_ACTY_BASE_RATE_NAME4
,P_ACTY_BASE_RATE_NUM4);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,dn,d(l.pval001)) p1,
decode(l.pval002,cn,nn,vn,nn,n(l.pval002)) p2,
l.pval002 d2,
decode(l.pval003,cn,dn,d(l.pval003)) p3,
decode(l.pval004,cn,nn,vn,nn,n(l.pval004)) p4,
l.pval004 d4,
decode(l.pval005,cn,nn,vn,nn,n(l.pval005)) p5,
l.pval005 d5,
decode(l.pval006,cn,nn,vn,nn,n(l.pval006)) p6,
l.pval006 d6,
decode(l.pval007,cn,dn,vn,dn,d(l.pval007)) p7,
l.pval007 d7,
decode(l.pval008,cn,dn,vn,dn,d(l.pval008)) p8,
l.pval008 d8,
decode(l.pval009,cn,nn,vn,nn,n(l.pval009)) p9,
l.pval009 d9,
decode(l.pval010,cn,nn,vn,nn,n(l.pval010)) p10,
l.pval010 d10,
decode(l.pval011,cn,dn,vn,dn,d(l.pval011)) p11,
l.pval011 d11,
decode(l.pval012,cn,dn,vn,dn,d(l.pval012)) p12,
l.pval012 d12,
decode(l.pval013,cn,nn,vn,nn,n(l.pval013)) p13,
l.pval013 d13,
decode(l.pval014,cn,nn,vn,nn,n(l.pval014)) p14,
l.pval014 d14,
decode(l.pval015,cn,dn,vn,dn,d(l.pval015)) p15,
l.pval015 d15,
decode(l.pval016,cn,dn,vn,dn,d(l.pval016)) p16,
l.pval016 d16,
decode(l.pval017,cn,nn,vn,nn,n(l.pval017)) p17,
l.pval017 d17,
decode(l.pval018,cn,nn,vn,nn,n(l.pval018)) p18,
l.pval018 d18,
decode(l.pval019,cn,dn,vn,dn,d(l.pval019)) p19,
l.pval019 d19,
decode(l.pval020,cn,dn,vn,dn,d(l.pval020)) p20,
l.pval020 d20,
decode(l.pval021,cn,dn,vn,dn,d(l.pval021)) p21,
l.pval021 d21,
decode(l.pval022,cn,dn,vn,dn,d(l.pval022)) p22,
l.pval022 d22,
decode(l.pval023,cn,dn,vn,dn,d(l.pval023)) p23,
l.pval023 d23,
decode(l.pval024,cn,vn,vn,vn,l.pval024) p24,
l.pval024 d24,
decode(l.pval025,cn,vn,l.pval025) p25,
decode(l.pval026,cn,vn,vn,vn,l.pval026) p26,
l.pval026 d26,
decode(l.pval027,cn,nn,vn,nn,n(l.pval027)) p27,
l.pval027 d27,
decode(l.pval028,cn,vn,vn,vn,l.pval028) p28,
l.pval028 d28,
decode(l.pval029,cn,nn,vn,nn,n(l.pval029)) p29,
l.pval029 d29,
decode(l.pval030,cn,vn,vn,vn,l.pval030) p30,
l.pval030 d30,
decode(l.pval031,cn,nn,vn,nn,n(l.pval031)) p31,
l.pval031 d31,
decode(l.pval032,cn,vn,l.pval032) p32,
decode(l.pval033,cn,vn,vn,vn,l.pval033) p33,
l.pval033 d33,
decode(l.pval034,cn,nn,vn,nn,n(l.pval034)) p34,
l.pval034 d34,
decode(l.pval035,cn,vn,vn,vn,l.pval035) p35,
l.pval035 d35,
decode(l.pval036,cn,nn,vn,nn,n(l.pval036)) p36,
l.pval036 d36,
decode(l.pval037,cn,vn,l.pval037) p37,
decode(l.pval038,cn,vn,l.pval038) p38,
decode(l.pval039,cn,vn,l.pval039) p39,
decode(l.pval040,cn,dn,d(l.pval040)) p40,
decode(l.pval041,cn,nn,n(l.pval041)) p41,
decode(l.pval042,cn,vn,vn,vn,l.pval042) p42,
l.pval042 d42,
decode(l.pval043,cn,nn,vn,nn,n(l.pval043)) p43,
l.pval043 d43,
decode(l.pval044,cn,vn,vn,vn,l.pval044) p44,
l.pval044 d44,
decode(l.pval045,cn,nn,vn,nn,n(l.pval045)) p45,
l.pval045 d45,
decode(l.pval046,cn,vn,vn,vn,l.pval046) p46,
l.pval046 d46,
decode(l.pval047,cn,nn,vn,nn,n(l.pval047)) p47,
l.pval047 d47,
decode(l.pval048,cn,vn,vn,vn,l.pval048) p48,
l.pval048 d48,
decode(l.pval049,cn,nn,vn,nn,n(l.pval049)) p49,
l.pval049 d49
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_PGM_ID number;
L_PL_ID number;
L_OPT_ID number;
L_LER_ID number;
L_ENDED_PL_ID number;
L_ENDED_OPT_ID number;
L_PERSON_ID number;
L_ACTY_BASE_RT_ID1 number;
L_ACTY_BASE_RT_ID2 number;
L_ACTY_BASE_RT_ID3 number;
L_ACTY_BASE_RT_ID4 number;
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
L_PGM_ID := 
BEN_PUMP_GET.GET_PGM_ID
(P_DATA_PUMP_ALWAYS_CALL => null
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_PROGRAM => c.p26
,P_PROGRAM_NUM => c.p27
,P_EFFECTIVE_DATE => c.p3);
--
L_PL_ID := 
BEN_PUMP_GET.GET_PL_ID
(P_DATA_PUMP_ALWAYS_CALL => null
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_PLAN => c.p28
,P_PLAN_NUM => c.p29
,P_EFFECTIVE_DATE => c.p3);
--
L_OPT_ID := 
BEN_PUMP_GET.GET_OPT_ID
(P_DATA_PUMP_ALWAYS_CALL => null
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_OPTION => c.p30
,P_OPTION_NUM => c.p31
,P_EFFECTIVE_DATE => c.p3);
--
if c.p32 is null or
c.p3 is null then
L_LER_ID:=nn;
else
L_LER_ID := 
hr_pump_get.GET_LER_ID
(P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_LIFE_EVENT_REASON => c.p32
,P_EFFECTIVE_DATE => c.p3);
end if;
--
L_ENDED_PL_ID := 
BEN_PUMP_GET.GET_ENDED_PL_ID
(P_DATA_PUMP_ALWAYS_CALL => null
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_ENDED_PLAN => c.p33
,P_ENDED_PLAN_NUM => c.p34
,P_EFFECTIVE_DATE => c.p3);
--
L_ENDED_OPT_ID := 
BEN_PUMP_GET.GET_ENDED_OPT_ID
(P_DATA_PUMP_ALWAYS_CALL => null
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_ENDED_OPTION => c.p35
,P_ENDED_OPTION_NUM => c.p36
,P_EFFECTIVE_DATE => c.p3);
--
L_PERSON_ID := 
BEN_PUMP_GET.GET_PEN_PERSON_ID
(P_DATA_PUMP_ALWAYS_CALL => null
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EMPLOYEE_NUMBER => c.p37
,P_NATIONAL_IDENTIFIER => c.p38
,P_FULL_NAME => c.p39
,P_DATE_OF_BIRTH => c.p40
,P_PERSON_NUM => c.p41
,P_EFFECTIVE_DATE => c.p3);
--
L_ACTY_BASE_RT_ID1 := 
BEN_PUMP_GET.GET_ACTY_BASE_RT_ID1
(P_DATA_PUMP_ALWAYS_CALL => null
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_ACTY_BASE_RATE_NAME1 => c.p42
,P_ACTY_BASE_RATE_NUM1 => c.p43
,P_EFFECTIVE_DATE => c.p3);
--
L_ACTY_BASE_RT_ID2 := 
BEN_PUMP_GET.GET_ACTY_BASE_RT_ID2
(P_DATA_PUMP_ALWAYS_CALL => null
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_ACTY_BASE_RATE_NAME2 => c.p44
,P_ACTY_BASE_RATE_NUM2 => c.p45
,P_EFFECTIVE_DATE => c.p3);
--
L_ACTY_BASE_RT_ID3 := 
BEN_PUMP_GET.GET_ACTY_BASE_RT_ID3
(P_DATA_PUMP_ALWAYS_CALL => null
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_ACTY_BASE_RATE_NAME3 => c.p46
,P_ACTY_BASE_RATE_NUM3 => c.p47
,P_EFFECTIVE_DATE => c.p3);
--
L_ACTY_BASE_RT_ID4 := 
BEN_PUMP_GET.GET_ACTY_BASE_RT_ID4
(P_DATA_PUMP_ALWAYS_CALL => null
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_ACTY_BASE_RATE_NAME4 => c.p48
,P_ACTY_BASE_RATE_NUM4 => c.p49
,P_EFFECTIVE_DATE => c.p3);
--
hr_data_pump.api_trc_on;
BEN_ENROLLMENT_PROCESS.CREATE_ENROLLMENT
(p_validate => l_validate
,P_PGM_ID => L_PGM_ID
,P_PL_ID => L_PL_ID
,P_OPT_ID => L_OPT_ID
,P_LER_ID => L_LER_ID
,P_LIFE_EVENT_DATE => c.p1
,P_ENDED_PL_ID => L_ENDED_PL_ID
,P_ENDED_OPT_ID => L_ENDED_OPT_ID
,P_ENDED_BNFT_VAL => c.p2
,P_EFFECTIVE_DATE => c.p3
,P_PERSON_ID => L_PERSON_ID
,P_BNFT_VAL => c.p4
,P_ACTY_BASE_RT_ID1 => L_ACTY_BASE_RT_ID1
,P_RT_VAL1 => c.p5
,P_ANN_RT_VAL1 => c.p6
,P_RT_STRT_DT1 => c.p7
,P_RT_END_DT1 => c.p8
,P_ACTY_BASE_RT_ID2 => L_ACTY_BASE_RT_ID2
,P_RT_VAL2 => c.p9
,P_ANN_RT_VAL2 => c.p10
,P_RT_STRT_DT2 => c.p11
,P_RT_END_DT2 => c.p12
,P_ACTY_BASE_RT_ID3 => L_ACTY_BASE_RT_ID3
,P_RT_VAL3 => c.p13
,P_ANN_RT_VAL3 => c.p14
,P_RT_STRT_DT3 => c.p15
,P_RT_END_DT3 => c.p16
,P_ACTY_BASE_RT_ID4 => L_ACTY_BASE_RT_ID4
,P_RT_VAL4 => c.p17
,P_ANN_RT_VAL4 => c.p18
,P_RT_STRT_DT4 => c.p19
,P_RT_END_DT4 => c.p20
,p_business_group_id => p_business_group_id
,P_ENRT_CVG_STRT_DT => c.p21
,P_ENRT_CVG_THRU_DT => c.p22
,P_ORGNL_ENRT_DT => c.p23
,P_PROC_CD => c.p24
,P_RECORD_TYP_CD => c.p25);
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
end hrdpp_CREATE_ENROLLMENT;

/