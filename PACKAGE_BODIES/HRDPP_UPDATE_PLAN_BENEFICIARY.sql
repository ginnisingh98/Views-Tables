--------------------------------------------------------
--  DDL for Package Body HRDPP_UPDATE_PLAN_BENEFICIARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_UPDATE_PLAN_BENEFICIARY" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 13:01:33
 * Generated for API: ben_plan_beneficiary_api.UPDATE_PLAN_BENEFICIARY
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
,P_PRMRY_CNTNGNT_CD in varchar2 default null
,P_PCT_DSGD_NUM in number default null
,I_PCT_DSGD_NUM in varchar2 default 'N'
,P_AMT_DSGD_VAL in number default null
,I_AMT_DSGD_VAL in varchar2 default 'N'
,P_DSGN_STRT_DT in date default null
,I_DSGN_STRT_DT in varchar2 default 'N'
,P_DSGN_THRU_DT in date default null
,I_DSGN_THRU_DT in varchar2 default 'N'
,P_ADDL_INSTRN_TXT in varchar2 default null
,P_PBN_ATTRIBUTE_CATEGORY in varchar2 default null
,P_PBN_ATTRIBUTE1 in varchar2 default null
,P_PBN_ATTRIBUTE2 in varchar2 default null
,P_PBN_ATTRIBUTE3 in varchar2 default null
,P_PBN_ATTRIBUTE4 in varchar2 default null
,P_PBN_ATTRIBUTE5 in varchar2 default null
,P_PBN_ATTRIBUTE6 in varchar2 default null
,P_PBN_ATTRIBUTE7 in varchar2 default null
,P_PBN_ATTRIBUTE8 in varchar2 default null
,P_PBN_ATTRIBUTE9 in varchar2 default null
,P_PBN_ATTRIBUTE10 in varchar2 default null
,P_PBN_ATTRIBUTE11 in varchar2 default null
,P_PBN_ATTRIBUTE12 in varchar2 default null
,P_PBN_ATTRIBUTE13 in varchar2 default null
,P_PBN_ATTRIBUTE14 in varchar2 default null
,P_PBN_ATTRIBUTE15 in varchar2 default null
,P_PBN_ATTRIBUTE16 in varchar2 default null
,P_PBN_ATTRIBUTE17 in varchar2 default null
,P_PBN_ATTRIBUTE18 in varchar2 default null
,P_PBN_ATTRIBUTE19 in varchar2 default null
,P_PBN_ATTRIBUTE20 in varchar2 default null
,P_PBN_ATTRIBUTE21 in varchar2 default null
,P_PBN_ATTRIBUTE22 in varchar2 default null
,P_PBN_ATTRIBUTE23 in varchar2 default null
,P_PBN_ATTRIBUTE24 in varchar2 default null
,P_PBN_ATTRIBUTE25 in varchar2 default null
,P_PBN_ATTRIBUTE26 in varchar2 default null
,P_PBN_ATTRIBUTE27 in varchar2 default null
,P_PBN_ATTRIBUTE28 in varchar2 default null
,P_PBN_ATTRIBUTE29 in varchar2 default null
,P_PBN_ATTRIBUTE30 in varchar2 default null
,P_PROGRAM_UPDATE_DATE in date default null
,I_PROGRAM_UPDATE_DATE in varchar2 default 'N'
,P_EFFECTIVE_DATE in date
,P_DATETRACK_MODE in varchar2
,P_MULTI_ROW_ACTN in boolean default null
,P_PL_BNF_USER_KEY in varchar2
,P_PRTT_ENRT_RSLT_USER_KEY in varchar2 default null
,P_BNF_PERSON_USER_KEY in varchar2 default null
,P_ORGANIZATION_NAME in varchar2 default null
,P_LANGUAGE_CODE in varchar2 default null
,P_TTEE_PERSON_USER_KEY in varchar2 default null
,P_AMT_DSGD_UOM in varchar2 default null
,P_PER_IN_LER_USER_KEY in varchar2 default null) is
blid number := p_data_pump_batch_line_id;
 L_MULTI_ROW_ACTN varchar2(5);
begin
if P_MULTI_ROW_ACTN is null then
 L_MULTI_ROW_ACTN := null;
elsif P_MULTI_ROW_ACTN then
 L_MULTI_ROW_ACTN := 'TRUE';
else 
 L_MULTI_ROW_ACTN := 'FALSE';
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
,pval049
,pval050
,pval051)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,567
,'U'
,p_user_sequence
,p_link_value
,P_PRMRY_CNTNGNT_CD
,nd(P_PCT_DSGD_NUM,I_PCT_DSGD_NUM)
,nd(P_AMT_DSGD_VAL,I_AMT_DSGD_VAL)
,dd(P_DSGN_STRT_DT,I_DSGN_STRT_DT)
,dd(P_DSGN_THRU_DT,I_DSGN_THRU_DT)
,P_ADDL_INSTRN_TXT
,P_PBN_ATTRIBUTE_CATEGORY
,P_PBN_ATTRIBUTE1
,P_PBN_ATTRIBUTE2
,P_PBN_ATTRIBUTE3
,P_PBN_ATTRIBUTE4
,P_PBN_ATTRIBUTE5
,P_PBN_ATTRIBUTE6
,P_PBN_ATTRIBUTE7
,P_PBN_ATTRIBUTE8
,P_PBN_ATTRIBUTE9
,P_PBN_ATTRIBUTE10
,P_PBN_ATTRIBUTE11
,P_PBN_ATTRIBUTE12
,P_PBN_ATTRIBUTE13
,P_PBN_ATTRIBUTE14
,P_PBN_ATTRIBUTE15
,P_PBN_ATTRIBUTE16
,P_PBN_ATTRIBUTE17
,P_PBN_ATTRIBUTE18
,P_PBN_ATTRIBUTE19
,P_PBN_ATTRIBUTE20
,P_PBN_ATTRIBUTE21
,P_PBN_ATTRIBUTE22
,P_PBN_ATTRIBUTE23
,P_PBN_ATTRIBUTE24
,P_PBN_ATTRIBUTE25
,P_PBN_ATTRIBUTE26
,P_PBN_ATTRIBUTE27
,P_PBN_ATTRIBUTE28
,P_PBN_ATTRIBUTE29
,P_PBN_ATTRIBUTE30
,dd(P_PROGRAM_UPDATE_DATE,I_PROGRAM_UPDATE_DATE)
,dc(P_EFFECTIVE_DATE)
,P_DATETRACK_MODE
,L_MULTI_ROW_ACTN
,P_PL_BNF_USER_KEY
,P_PRTT_ENRT_RSLT_USER_KEY
,P_BNF_PERSON_USER_KEY
,P_ORGANIZATION_NAME
,P_LANGUAGE_CODE
,P_TTEE_PERSON_USER_KEY
,P_AMT_DSGD_UOM
,P_PER_IN_LER_USER_KEY);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,dn,d(l.pval001)) p1,
decode(l.pval002,cn,dn,d(l.pval002)) p2,
decode(l.pval003,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval003,'BEN_PRMRY_CNTNGNT',d(l.pval041),l.pval048)) p3,
l.pval003 d3,
decode(l.pval004,cn,nn,vn,nh,n(l.pval004)) p4,
l.pval004 d4,
decode(l.pval005,cn,nn,vn,nh,n(l.pval005)) p5,
l.pval005 d5,
decode(l.pval006,cn,dn,vn,dh,d(l.pval006)) p6,
l.pval006 d6,
decode(l.pval007,cn,dn,vn,dh,d(l.pval007)) p7,
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
decode(l.pval040,cn,dn,vn,dh,d(l.pval040)) p40,
l.pval040 d40,
decode(l.pval041,cn,dn,d(l.pval041)) p41,
decode(l.pval042,cn,vn,l.pval042) p42,
decode(l.pval043,cn,vn,vn,null,l.pval043) p43,
l.pval043 d43,
decode(l.pval044,cn,vn,l.pval044) p44,
decode(l.pval045,cn,vn,vn,vn,l.pval045) p45,
l.pval045 d45,
decode(l.pval046,cn,vn,vn,vn,l.pval046) p46,
l.pval046 d46,
decode(l.pval047,cn,vn,vn,vh,l.pval047) p47,
l.pval047 d47,
decode(l.pval048,cn,vn,vn,vh,l.pval048) p48,
l.pval048 d48,
decode(l.pval049,cn,vn,vn,vn,l.pval049) p49,
l.pval049 d49,
decode(l.pval050,cn,vn,vn,vh,l.pval050) p50,
l.pval050 d50,
decode(l.pval051,cn,vn,vn,vn,l.pval051) p51,
l.pval051 d51
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_MULTI_ROW_ACTN boolean;
L_PL_BNF_ID number;
L_PRTT_ENRT_RSLT_ID number;
L_BNF_PERSON_ID number;
L_ORGANIZATION_ID number;
L_TTEE_PERSON_ID number;
L_AMT_DSGD_UOM varchar2(2000);
L_REQUEST_ID number;
L_PROGRAM_APPLICATION_ID number;
L_PROGRAM_ID number;
L_OBJECT_VERSION_NUMBER number;
L_PER_IN_LER_ID number;
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
if upper(c.p43) = 'TRUE' then
L_MULTI_ROW_ACTN := true;
elsif upper(c.p43) = 'FALSE' then
L_MULTI_ROW_ACTN := false;
elsif c.p43 is not null then
hr_utility.set_message(800,'HR_50327_DP_TYPE_ERR');
hr_utility.set_message_token('TYPE','BOOLEAN');
hr_utility.set_message_token('PARAMETER','P_MULTI_ROW_ACTN');
hr_utility.set_message_token('VALUE',c.p43);
hr_utility.set_message_token('TABLE','HR_PUMP_BATCH_LINES');
hr_utility.raise_error;
end if;
--
if c.p44 is null then
L_PL_BNF_ID:=nn;
else
L_PL_BNF_ID := 
hr_pump_get.get_pl_bnf_id
(P_PL_BNF_USER_KEY => c.p44);
end if;
--
if c.d45=cn then
L_PRTT_ENRT_RSLT_ID:=nn;
elsif c.d45 is null then 
L_PRTT_ENRT_RSLT_ID:=nh;
else
L_PRTT_ENRT_RSLT_ID := 
hr_pump_get.get_prtt_enrt_rslt_id
(P_PRTT_ENRT_RSLT_USER_KEY => c.p45);
end if;
--
if c.d46=cn then
L_BNF_PERSON_ID:=nn;
elsif c.d46 is null then 
L_BNF_PERSON_ID:=nh;
else
L_BNF_PERSON_ID := 
hr_pump_get.get_bnf_person_id
(P_BNF_PERSON_USER_KEY => c.p46);
end if;
--
if c.d47=cn or
c.p41 is null or
c.d48=cn then
L_ORGANIZATION_ID:=nn;
elsif c.d47 is null or
c.d48 is null then 
L_ORGANIZATION_ID:=nh;
else
L_ORGANIZATION_ID := 
hr_pump_get.get_organization_id
(P_ORGANIZATION_NAME => c.p47
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p41
,P_LANGUAGE_CODE => c.p48);
end if;
--
if c.d49=cn then
L_TTEE_PERSON_ID:=nn;
elsif c.d49 is null then 
L_TTEE_PERSON_ID:=nh;
else
L_TTEE_PERSON_ID := 
hr_pump_get.get_ttee_person_id
(P_TTEE_PERSON_USER_KEY => c.p49);
end if;
--
if c.d50=cn or
c.p41 is null then
L_AMT_DSGD_UOM:=vn;
elsif c.d50 is null then 
L_AMT_DSGD_UOM:=vh;
else
L_AMT_DSGD_UOM := 
hr_pump_get.GET_AMT_DSGD_UOM_CODE
(P_AMT_DSGD_UOM => c.p50
,P_EFFECTIVE_DATE => c.p41);
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
if c.p44 is null or
c.p41 is null then
L_OBJECT_VERSION_NUMBER:=nn;
else
L_OBJECT_VERSION_NUMBER := 
hr_pump_get.GET_PL_BNF_OVN
(P_PL_BNF_USER_KEY => c.p44
,P_EFFECTIVE_DATE => c.p41);
end if;
--
if c.d51=cn then
L_PER_IN_LER_ID:=nn;
elsif c.d51 is null then 
L_PER_IN_LER_ID:=nh;
else
L_PER_IN_LER_ID := 
hr_pump_get.get_per_in_ler_id
(P_PER_IN_LER_USER_KEY => c.p51);
end if;
--
hr_data_pump.api_trc_on;
ben_plan_beneficiary_api.UPDATE_PLAN_BENEFICIARY
(p_validate => l_validate
,P_PL_BNF_ID => L_PL_BNF_ID
,P_EFFECTIVE_START_DATE => c.p1
,P_EFFECTIVE_END_DATE => c.p2
,p_business_group_id => p_business_group_id
,P_PRTT_ENRT_RSLT_ID => L_PRTT_ENRT_RSLT_ID
,P_BNF_PERSON_ID => L_BNF_PERSON_ID
,P_ORGANIZATION_ID => L_ORGANIZATION_ID
,P_TTEE_PERSON_ID => L_TTEE_PERSON_ID
,P_PRMRY_CNTNGNT_CD => c.p3
,P_PCT_DSGD_NUM => c.p4
,P_AMT_DSGD_VAL => c.p5
,P_AMT_DSGD_UOM => L_AMT_DSGD_UOM
,P_DSGN_STRT_DT => c.p6
,P_DSGN_THRU_DT => c.p7
,P_ADDL_INSTRN_TXT => c.p8
,P_PBN_ATTRIBUTE_CATEGORY => c.p9
,P_PBN_ATTRIBUTE1 => c.p10
,P_PBN_ATTRIBUTE2 => c.p11
,P_PBN_ATTRIBUTE3 => c.p12
,P_PBN_ATTRIBUTE4 => c.p13
,P_PBN_ATTRIBUTE5 => c.p14
,P_PBN_ATTRIBUTE6 => c.p15
,P_PBN_ATTRIBUTE7 => c.p16
,P_PBN_ATTRIBUTE8 => c.p17
,P_PBN_ATTRIBUTE9 => c.p18
,P_PBN_ATTRIBUTE10 => c.p19
,P_PBN_ATTRIBUTE11 => c.p20
,P_PBN_ATTRIBUTE12 => c.p21
,P_PBN_ATTRIBUTE13 => c.p22
,P_PBN_ATTRIBUTE14 => c.p23
,P_PBN_ATTRIBUTE15 => c.p24
,P_PBN_ATTRIBUTE16 => c.p25
,P_PBN_ATTRIBUTE17 => c.p26
,P_PBN_ATTRIBUTE18 => c.p27
,P_PBN_ATTRIBUTE19 => c.p28
,P_PBN_ATTRIBUTE20 => c.p29
,P_PBN_ATTRIBUTE21 => c.p30
,P_PBN_ATTRIBUTE22 => c.p31
,P_PBN_ATTRIBUTE23 => c.p32
,P_PBN_ATTRIBUTE24 => c.p33
,P_PBN_ATTRIBUTE25 => c.p34
,P_PBN_ATTRIBUTE26 => c.p35
,P_PBN_ATTRIBUTE27 => c.p36
,P_PBN_ATTRIBUTE28 => c.p37
,P_PBN_ATTRIBUTE29 => c.p38
,P_PBN_ATTRIBUTE30 => c.p39
,P_REQUEST_ID => L_REQUEST_ID
,P_PROGRAM_APPLICATION_ID => L_PROGRAM_APPLICATION_ID
,P_PROGRAM_ID => L_PROGRAM_ID
,P_PROGRAM_UPDATE_DATE => c.p40
,P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER
,P_PER_IN_LER_ID => L_PER_IN_LER_ID
,P_EFFECTIVE_DATE => c.p41
,P_DATETRACK_MODE => c.p42
,P_MULTI_ROW_ACTN => L_MULTI_ROW_ACTN);
hr_data_pump.api_trc_off;

--
update hr_pump_batch_lines l set
l.pval001 = decode(c.p1,null,cn,dc(c.p1)),
l.pval002 = decode(c.p2,null,cn,dc(c.p2))
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
end hrdpp_UPDATE_PLAN_BENEFICIARY;

/