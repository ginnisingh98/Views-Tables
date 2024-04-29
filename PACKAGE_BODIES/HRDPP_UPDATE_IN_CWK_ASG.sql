--------------------------------------------------------
--  DDL for Package Body HRDPP_UPDATE_IN_CWK_ASG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRDPP_UPDATE_IN_CWK_ASG" as
/*
 * Generated by hr_pump_meta_mapper at: 2007/01/04 09:01:53
 * Generated for API: hr_in_assignment_api.update_in_cwk_asg
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
,P_ASSIGNMENT_CATEGORY in varchar2 default null
,P_ASSIGNMENT_NUMBER in varchar2 default null
,P_CHANGE_REASON in varchar2 default null
,P_COMMENTS in varchar2 default null
,P_FREQUENCY in varchar2 default null
,P_INTERNAL_ADDRESS_LINE in varchar2 default null
,P_LABOUR_UNION_MEMBER_FLAG in varchar2 default null
,P_MANAGER_FLAG in varchar2 default null
,P_NORMAL_HOURS in number default null
,I_NORMAL_HOURS in varchar2 default 'N'
,P_PROJECT_TITLE in varchar2 default null
,P_SOURCE_TYPE in varchar2 default null
,P_TIME_NORMAL_FINISH in varchar2 default null
,P_TIME_NORMAL_START in varchar2 default null
,P_TITLE in varchar2 default null
,P_VENDOR_ASSIGNMENT_NUMBER in varchar2 default null
,P_VENDOR_EMPLOYEE_NUMBER in varchar2 default null
,P_PROJECTED_ASSIGNMENT_END in date default null
,I_PROJECTED_ASSIGNMENT_END in varchar2 default 'N'
,P_CONCAT_SEGMENTS in varchar2 default null
,P_ATTRIBUTE_CATEGORY in varchar2 default null
,P_ATTRIBUTE1 in varchar2 default null
,P_ATTRIBUTE2 in varchar2 default null
,P_ATTRIBUTE3 in varchar2 default null
,P_ATTRIBUTE4 in varchar2 default null
,P_ATTRIBUTE5 in varchar2 default null
,P_ATTRIBUTE6 in varchar2 default null
,P_ATTRIBUTE7 in varchar2 default null
,P_ATTRIBUTE8 in varchar2 default null
,P_ATTRIBUTE9 in varchar2 default null
,P_ATTRIBUTE10 in varchar2 default null
,P_ATTRIBUTE11 in varchar2 default null
,P_ATTRIBUTE12 in varchar2 default null
,P_ATTRIBUTE13 in varchar2 default null
,P_ATTRIBUTE14 in varchar2 default null
,P_ATTRIBUTE15 in varchar2 default null
,P_ATTRIBUTE16 in varchar2 default null
,P_ATTRIBUTE17 in varchar2 default null
,P_ATTRIBUTE18 in varchar2 default null
,P_ATTRIBUTE19 in varchar2 default null
,P_ATTRIBUTE20 in varchar2 default null
,P_ATTRIBUTE21 in varchar2 default null
,P_ATTRIBUTE22 in varchar2 default null
,P_ATTRIBUTE23 in varchar2 default null
,P_ATTRIBUTE24 in varchar2 default null
,P_ATTRIBUTE25 in varchar2 default null
,P_ATTRIBUTE26 in varchar2 default null
,P_ATTRIBUTE27 in varchar2 default null
,P_ATTRIBUTE28 in varchar2 default null
,P_ATTRIBUTE29 in varchar2 default null
,P_ATTRIBUTE30 in varchar2 default null
,P_ASSIGNMENT_USER_KEY in varchar2
,P_DEFAULT_CODE_COMB_USER_KEY in varchar2 default null
,P_ESTABLISHMENT_ORG_NAME in varchar2 default null
,P_LANGUAGE_CODE in varchar2 default null
,P_SET_OF_BOOKS_NAME in varchar2 default null
,P_SUPERVISOR_USER_KEY in varchar2 default null
,P_VENDOR_NAME in varchar2 default null
,P_VENDOR_SITE_ID in number default null
,I_VENDOR_SITE_ID in varchar2 default 'N'
,P_PO_HEADER_ID in number default null
,I_PO_HEADER_ID in varchar2 default 'N'
,P_PO_LINE_ID in number default null
,I_PO_LINE_ID in varchar2 default 'N'
,P_USER_STATUS in varchar2 default null
,P_SCL_CONTRACTOR_NAME in varchar2 default null
,P_SVR_ASSIGNMENT_USER_KEY in varchar2 default null) is
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
,pval049
,pval050
,pval051
,pval061
,pval062
,pval063
,pval064
,pval065
,pval066
,pval067
,pval068
,pval069
,pval070
,pval071
,pval072
,pval073)
values
(p_batch_id
,nvl(blid,hr_pump_batch_lines_s.nextval)
,p_data_pump_business_grp_name
,3216
,'U'
,p_user_sequence
,p_link_value
,dc(P_EFFECTIVE_DATE)
,P_DATETRACK_UPDATE_MODE
,P_ASSIGNMENT_CATEGORY
,P_ASSIGNMENT_NUMBER
,P_CHANGE_REASON
,P_COMMENTS
,P_FREQUENCY
,P_INTERNAL_ADDRESS_LINE
,P_LABOUR_UNION_MEMBER_FLAG
,P_MANAGER_FLAG
,nd(P_NORMAL_HOURS,I_NORMAL_HOURS)
,P_PROJECT_TITLE
,P_SOURCE_TYPE
,P_TIME_NORMAL_FINISH
,P_TIME_NORMAL_START
,P_TITLE
,P_VENDOR_ASSIGNMENT_NUMBER
,P_VENDOR_EMPLOYEE_NUMBER
,dd(P_PROJECTED_ASSIGNMENT_END,I_PROJECTED_ASSIGNMENT_END)
,P_CONCAT_SEGMENTS
,P_ATTRIBUTE_CATEGORY
,P_ATTRIBUTE1
,P_ATTRIBUTE2
,P_ATTRIBUTE3
,P_ATTRIBUTE4
,P_ATTRIBUTE5
,P_ATTRIBUTE6
,P_ATTRIBUTE7
,P_ATTRIBUTE8
,P_ATTRIBUTE9
,P_ATTRIBUTE10
,P_ATTRIBUTE11
,P_ATTRIBUTE12
,P_ATTRIBUTE13
,P_ATTRIBUTE14
,P_ATTRIBUTE15
,P_ATTRIBUTE16
,P_ATTRIBUTE17
,P_ATTRIBUTE18
,P_ATTRIBUTE19
,P_ATTRIBUTE20
,P_ATTRIBUTE21
,P_ATTRIBUTE22
,P_ATTRIBUTE23
,P_ATTRIBUTE24
,P_ATTRIBUTE25
,P_ATTRIBUTE26
,P_ATTRIBUTE27
,P_ATTRIBUTE28
,P_ATTRIBUTE29
,P_ATTRIBUTE30
,P_ASSIGNMENT_USER_KEY
,P_DEFAULT_CODE_COMB_USER_KEY
,P_ESTABLISHMENT_ORG_NAME
,P_LANGUAGE_CODE
,P_SET_OF_BOOKS_NAME
,P_SUPERVISOR_USER_KEY
,P_VENDOR_NAME
,nd(P_VENDOR_SITE_ID,I_VENDOR_SITE_ID)
,nd(P_PO_HEADER_ID,I_PO_HEADER_ID)
,nd(P_PO_LINE_ID,I_PO_LINE_ID)
,P_USER_STATUS
,P_SCL_CONTRACTOR_NAME
,P_SVR_ASSIGNMENT_USER_KEY);
end insert_batch_lines;
--
procedure call
(p_business_group_id in number,
p_batch_line_id     in number) is
cursor cr is
select l.rowid myrowid,
decode(l.pval001,cn,dn,d(l.pval001)) p1,
decode(l.pval002,cn,vn,l.pval002) p2,
decode(l.pval003,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval003,'CWK_ASG_CATEGORY',d(l.pval001),l.pval064)) p3,
l.pval003 d3,
decode(l.pval004,cn,vn,vn,vh,l.pval004) p4,
l.pval004 d4,
decode(l.pval005,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval005,'CWK_ASSIGN_REASON',d(l.pval001),l.pval064)) p5,
l.pval005 d5,
decode(l.pval006,cn,vn,vn,vh,l.pval006) p6,
l.pval006 d6,
decode(l.pval007,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval007,'FREQUENCY',d(l.pval001),l.pval064)) p7,
l.pval007 d7,
decode(l.pval008,cn,vn,vn,vh,l.pval008) p8,
l.pval008 d8,
decode(l.pval009,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval009,'YES_NO',d(l.pval001),l.pval064)) p9,
l.pval009 d9,
decode(l.pval010,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval010,'YES_NO',d(l.pval001),l.pval064)) p10,
l.pval010 d10,
decode(l.pval011,cn,nn,vn,nh,n(l.pval011)) p11,
l.pval011 d11,
decode(l.pval012,cn,vn,vn,vh,l.pval012) p12,
l.pval012 d12,
decode(l.pval013,cn,vn,vn,vh,
 hr_pump_get.gl(l.pval013,'REC_TYPE',d(l.pval001),l.pval064)) p13,
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
decode(l.pval019,cn,dn,vn,dh,d(l.pval019)) p19,
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
decode(l.pval045,cn,vn,vn,vh,l.pval045) p45,
l.pval045 d45,
decode(l.pval046,cn,vn,vn,vh,l.pval046) p46,
l.pval046 d46,
decode(l.pval047,cn,vn,vn,vh,l.pval047) p47,
l.pval047 d47,
decode(l.pval048,cn,vn,vn,vh,l.pval048) p48,
l.pval048 d48,
decode(l.pval049,cn,vn,vn,vh,l.pval049) p49,
l.pval049 d49,
decode(l.pval050,cn,vn,vn,vh,l.pval050) p50,
l.pval050 d50,
decode(l.pval051,cn,vn,vn,vh,l.pval051) p51,
l.pval051 d51,
l.pval052 p52,
decode(l.pval053,cn,dn,d(l.pval053)) p53,
decode(l.pval054,cn,dn,d(l.pval054)) p54,
l.pval055 p55,
l.pval056 p56,
l.pval057 p57,
l.pval058 p58,
l.pval059 p59,
l.pval060 p60,
decode(l.pval061,cn,vn,l.pval061) p61,
decode(l.pval062,cn,vn,vn,vn,l.pval062) p62,
l.pval062 d62,
decode(l.pval063,cn,vn,vn,vh,l.pval063) p63,
l.pval063 d63,
decode(l.pval064,cn,vn,vn,vh,l.pval064) p64,
l.pval064 d64,
decode(l.pval065,cn,vn,vn,vh,l.pval065) p65,
l.pval065 d65,
decode(l.pval066,cn,vn,vn,vn,l.pval066) p66,
l.pval066 d66,
decode(l.pval067,cn,vn,vn,vh,l.pval067) p67,
l.pval067 d67,
decode(l.pval068,cn,nn,vn,nh,n(l.pval068)) p68,
l.pval068 d68,
decode(l.pval069,cn,nn,vn,nh,n(l.pval069)) p69,
l.pval069 d69,
decode(l.pval070,cn,nn,vn,nh,n(l.pval070)) p70,
l.pval070 d70,
decode(l.pval071,cn,vn,vn,vh,l.pval071) p71,
l.pval071 d71,
decode(l.pval072,cn,vn,vn,vh,l.pval072) p72,
l.pval072 d72,
decode(l.pval073,cn,vn,vn,vn,l.pval073) p73,
l.pval073 d73
from hr_pump_batch_lines l
where l.batch_line_id = p_batch_line_id;
--
c cr%rowtype;
l_validate boolean := false;
L_ORG_NOW_NO_MANAGER_WARNING boolean;
L_NO_MANAGERS_WARNING boolean;
L_OTHER_MANAGER_WARNING boolean;
L_HOURLY_SALARIED_WARNING boolean;
L_ASSIGNMENT_ID number;
L_OBJECT_VERSION_NUMBER number;
L_DEFAULT_CODE_COMB_ID number;
L_ESTABLISHMENT_ID number;
L_SET_OF_BOOKS_ID number;
L_SUPERVISOR_ID number;
L_VENDOR_ID number;
L_VENDOR_SITE_ID number;
L_PO_HEADER_ID number;
L_PO_LINE_ID number;
L_ASSIGNMENT_STATUS_TYPE_ID number;
L_SCL_CONTRACTOR_NAME varchar2(2000);
L_SUPERVISOR_ASSIGNMENT_ID number;
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
if c.p61 is null then
L_ASSIGNMENT_ID:=nn;
else
L_ASSIGNMENT_ID := 
hr_pump_get.get_assignment_id
(P_ASSIGNMENT_USER_KEY => c.p61);
end if;
--
if c.p61 is null or
c.p1 is null then
L_OBJECT_VERSION_NUMBER:=nn;
else
L_OBJECT_VERSION_NUMBER := 
hr_pump_get.GET_ASG_OVN
(P_ASSIGNMENT_USER_KEY => c.p61
,P_EFFECTIVE_DATE => c.p1);
end if;
--
if c.d62=cn then
L_DEFAULT_CODE_COMB_ID:=nn;
elsif c.d62 is null then 
L_DEFAULT_CODE_COMB_ID:=nh;
else
L_DEFAULT_CODE_COMB_ID := 
hr_pump_get.get_default_code_comb_id
(P_DEFAULT_CODE_COMB_USER_KEY => c.p62);
end if;
--
if c.d63=cn or
c.p1 is null or
c.d64=cn then
L_ESTABLISHMENT_ID:=nn;
elsif c.d63 is null or
c.d64 is null then 
L_ESTABLISHMENT_ID:=nh;
else
L_ESTABLISHMENT_ID := 
hr_pump_get.GET_ESTABLISHMENT_ORG_ID
(P_ESTABLISHMENT_ORG_NAME => c.p63
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_EFFECTIVE_DATE => c.p1
,P_LANGUAGE_CODE => c.p64);
end if;
--
if c.d65=cn then
L_SET_OF_BOOKS_ID:=nn;
elsif c.d65 is null then 
L_SET_OF_BOOKS_ID:=nh;
else
L_SET_OF_BOOKS_ID := 
hr_pump_get.get_set_of_books_id
(P_SET_OF_BOOKS_NAME => c.p65);
end if;
--
if c.d66=cn then
L_SUPERVISOR_ID:=nn;
elsif c.d66 is null then 
L_SUPERVISOR_ID:=nh;
else
L_SUPERVISOR_ID := 
hr_pump_get.get_supervisor_id
(P_SUPERVISOR_USER_KEY => c.p66);
end if;
--
if c.d67=cn then
L_VENDOR_ID:=nn;
elsif c.d67 is null then 
L_VENDOR_ID:=nh;
else
L_VENDOR_ID := 
hr_pump_get.get_vendor_id
(P_VENDOR_NAME => c.p67);
end if;
--
if c.d68=cn then
L_VENDOR_SITE_ID:=nn;
elsif c.d68 is null then 
L_VENDOR_SITE_ID:=nh;
else
L_VENDOR_SITE_ID := 
PER_IN_DATA_PUMP.get_vendor_site_id
(P_VENDOR_SITE_ID => c.p68);
end if;
--
if c.d69=cn then
L_PO_HEADER_ID:=nn;
elsif c.d69 is null then 
L_PO_HEADER_ID:=nh;
else
L_PO_HEADER_ID := 
PER_IN_DATA_PUMP.get_po_header_id
(P_PO_HEADER_ID => c.p69);
end if;
--
if c.d70=cn then
L_PO_LINE_ID:=nn;
elsif c.d70 is null then 
L_PO_LINE_ID:=nh;
else
L_PO_LINE_ID := 
PER_IN_DATA_PUMP.get_po_line_id
(P_PO_LINE_ID => c.p70);
end if;
--
if c.d71=cn or
c.d64=cn then
L_ASSIGNMENT_STATUS_TYPE_ID:=nn;
elsif c.d71 is null or
c.d64 is null then 
L_ASSIGNMENT_STATUS_TYPE_ID:=nh;
else
L_ASSIGNMENT_STATUS_TYPE_ID := 
hr_pump_get.get_assignment_status_type_id
(P_USER_STATUS => c.p71
,P_BUSINESS_GROUP_ID => P_BUSINESS_GROUP_ID
,P_LANGUAGE_CODE => c.p64);
end if;
--
if c.d72=cn then
L_SCL_CONTRACTOR_NAME:=vn;
elsif c.d72 is null then 
L_SCL_CONTRACTOR_NAME:=vh;
else
L_SCL_CONTRACTOR_NAME := 
PER_IN_DATA_PUMP.GET_SCL_CONTRACTOR_ID
(P_SCL_CONTRACTOR_NAME => c.p72);
end if;
--
if c.d73=cn then
L_SUPERVISOR_ASSIGNMENT_ID:=nn;
elsif c.d73 is null then 
L_SUPERVISOR_ASSIGNMENT_ID:=nh;
else
L_SUPERVISOR_ASSIGNMENT_ID := 
hr_pump_get.get_supervisor_assignment_id
(P_SVR_ASSIGNMENT_USER_KEY => c.p73);
end if;
--
hr_data_pump.api_trc_on;
hr_in_assignment_api.update_in_cwk_asg
(p_validate => l_validate
,P_EFFECTIVE_DATE => c.p1
,P_DATETRACK_UPDATE_MODE => c.p2
,P_ASSIGNMENT_ID => L_ASSIGNMENT_ID
,P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER
,P_ASSIGNMENT_CATEGORY => c.p3
,P_ASSIGNMENT_NUMBER => c.p4
,P_CHANGE_REASON => c.p5
,P_COMMENTS => c.p6
,P_DEFAULT_CODE_COMB_ID => L_DEFAULT_CODE_COMB_ID
,P_ESTABLISHMENT_ID => L_ESTABLISHMENT_ID
,P_FREQUENCY => c.p7
,P_INTERNAL_ADDRESS_LINE => c.p8
,P_LABOUR_UNION_MEMBER_FLAG => c.p9
,P_MANAGER_FLAG => c.p10
,P_NORMAL_HOURS => c.p11
,P_PROJECT_TITLE => c.p12
,P_SET_OF_BOOKS_ID => L_SET_OF_BOOKS_ID
,P_SOURCE_TYPE => c.p13
,P_SUPERVISOR_ID => L_SUPERVISOR_ID
,P_TIME_NORMAL_FINISH => c.p14
,P_TIME_NORMAL_START => c.p15
,P_TITLE => c.p16
,P_VENDOR_ASSIGNMENT_NUMBER => c.p17
,P_VENDOR_EMPLOYEE_NUMBER => c.p18
,P_VENDOR_ID => L_VENDOR_ID
,P_VENDOR_SITE_ID => L_VENDOR_SITE_ID
,P_PO_HEADER_ID => L_PO_HEADER_ID
,P_PO_LINE_ID => L_PO_LINE_ID
,P_PROJECTED_ASSIGNMENT_END => c.p19
,P_ASSIGNMENT_STATUS_TYPE_ID => L_ASSIGNMENT_STATUS_TYPE_ID
,P_CONCAT_SEGMENTS => c.p20
,P_ATTRIBUTE_CATEGORY => c.p21
,P_ATTRIBUTE1 => c.p22
,P_ATTRIBUTE2 => c.p23
,P_ATTRIBUTE3 => c.p24
,P_ATTRIBUTE4 => c.p25
,P_ATTRIBUTE5 => c.p26
,P_ATTRIBUTE6 => c.p27
,P_ATTRIBUTE7 => c.p28
,P_ATTRIBUTE8 => c.p29
,P_ATTRIBUTE9 => c.p30
,P_ATTRIBUTE10 => c.p31
,P_ATTRIBUTE11 => c.p32
,P_ATTRIBUTE12 => c.p33
,P_ATTRIBUTE13 => c.p34
,P_ATTRIBUTE14 => c.p35
,P_ATTRIBUTE15 => c.p36
,P_ATTRIBUTE16 => c.p37
,P_ATTRIBUTE17 => c.p38
,P_ATTRIBUTE18 => c.p39
,P_ATTRIBUTE19 => c.p40
,P_ATTRIBUTE20 => c.p41
,P_ATTRIBUTE21 => c.p42
,P_ATTRIBUTE22 => c.p43
,P_ATTRIBUTE23 => c.p44
,P_ATTRIBUTE24 => c.p45
,P_ATTRIBUTE25 => c.p46
,P_ATTRIBUTE26 => c.p47
,P_ATTRIBUTE27 => c.p48
,P_ATTRIBUTE28 => c.p49
,P_ATTRIBUTE29 => c.p50
,P_ATTRIBUTE30 => c.p51
,P_SCL_CONTRACTOR_NAME => L_SCL_CONTRACTOR_NAME
,P_SUPERVISOR_ASSIGNMENT_ID => L_SUPERVISOR_ASSIGNMENT_ID
,P_ORG_NOW_NO_MANAGER_WARNING => L_ORG_NOW_NO_MANAGER_WARNING
,P_EFFECTIVE_START_DATE => c.p53
,P_EFFECTIVE_END_DATE => c.p54
,P_COMMENT_ID => c.p55
,P_NO_MANAGERS_WARNING => L_NO_MANAGERS_WARNING
,P_OTHER_MANAGER_WARNING => L_OTHER_MANAGER_WARNING
,P_SOFT_CODING_KEYFLEX_ID => c.p58
,P_CONCATENATED_SEGMENTS => c.p59
,P_HOURLY_SALARIED_WARNING => L_HOURLY_SALARIED_WARNING);
hr_data_pump.api_trc_off;
--
if L_ORG_NOW_NO_MANAGER_WARNING then
c.p52 := 'TRUE';
else
c.p52 := 'FALSE';
end if;
--
if L_NO_MANAGERS_WARNING then
c.p56 := 'TRUE';
else
c.p56 := 'FALSE';
end if;
--
if L_OTHER_MANAGER_WARNING then
c.p57 := 'TRUE';
else
c.p57 := 'FALSE';
end if;
--
if L_HOURLY_SALARIED_WARNING then
c.p60 := 'TRUE';
else
c.p60 := 'FALSE';
end if;
--
update hr_pump_batch_lines l set
l.pval052 = decode(c.p52,null,cn,c.p52),
l.pval053 = decode(c.p53,null,cn,dc(c.p53)),
l.pval054 = decode(c.p54,null,cn,dc(c.p54)),
l.pval055 = decode(c.p55,null,cn,c.p55),
l.pval056 = decode(c.p56,null,cn,c.p56),
l.pval057 = decode(c.p57,null,cn,c.p57),
l.pval058 = decode(c.p58,null,cn,c.p58),
l.pval059 = decode(c.p59,null,cn,c.p59),
l.pval060 = decode(c.p60,null,cn,c.p60)
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
end hrdpp_update_in_cwk_asg;

/