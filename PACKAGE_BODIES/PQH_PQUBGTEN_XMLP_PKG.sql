--------------------------------------------------------
--  DDL for Package Body PQH_PQUBGTEN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQUBGTEN_XMLP_PKG" AS
/* $Header: PQUBGTENB.pls 120.3 2008/02/28 12:17:54 srikrish noship $ */

function BeforeReport return boolean is
errbuf varchar2(1000);
retcode varchar2(100);
pqh_pack_err exception;
l_batch varchar2(1);
cursor c_process_log is
select  '1'
  from pqh_process_log
 where module_cd = 'POSITION_BUDGET_ANALYSIS'
   and information12 = 'REPORT'
   and information11 like P_BATCH_NAME||'%';

Cursor c_curr_date is
Select trunc(sysdate)
  From dual;
cursor csr_org_struct_name IS
   SELECT name
   FROM   per_organization_structures
   WHERE  organization_structure_id = p_org_structure_id;
l_org_struct_name per_organization_structures.name%TYPE;
Cursor Csr_entity_name IS
    SELECT meaning
    FROM   hr_lookups
    WHERE  lookup_type IN ('PQH_BUDGET_ENTITY','UNDER_BDGT_EXTRA_TYPES')
    AND    lookup_code = p_entity_code;
  l_entity_name  varchar2(80);
begin
P_EFFECTIVE_DATE_T := to_char(P_EFFECTIVE_DATE,'DD-MON-YYYY');
--hr_standard.event('BEFORE REPORT');

cp_bg_name := hr_general.decode_organization(p_business_group_id);
CP_REPORT_TITLE:= hr_general.decode_lookup('PQH_REPORT_TITLES','PQHWSUBE');
If p_org_structure_id IS NOT NULL THEN
  OPEN csr_org_struct_name;
  FETCH csr_org_struct_name INTO l_org_struct_name;
  CLOSE csr_org_struct_name;
  cp_org_structure_name := l_org_struct_name;
End If;
If p_start_org_id IS NOT NULL THEN
  cp_start_org_name := hr_general.decode_organization(p_start_org_id);
End If;
OPEN csr_entity_name;
FETCH csr_entity_name INTO l_entity_name;
CLOSE csr_entity_name;
cp_entity_name := l_entity_name;
cp_uom := hr_general.decode_lookup('BUDGET_MEASUREMENT_TYPE',P_UNIT_OF_MEASURE);
pqh_budget_analysis_pkg.get_entity(
errbuf,
retcode,
p_batch_name,
to_char(p_effective_date, 'YYYY/MM/DD HH24:MI:SS'),
to_char(p_start_date, 'YYYY/MM/DD HH24:MI:SS'),
to_char(p_end_date, 'YYYY/MM/DD HH24:MI:SS'),
p_entity_code,
p_unit_of_measure,
p_business_group_id,
p_start_org_id,
p_org_structure_id);
commit;

OPEN c_process_log;
FETCH c_process_log INTO l_batch;
If c_process_log%notfound Then
  cp_no_data := null;
Else
  cp_no_data := '1';
End If;
CLOSE c_process_log;

OPEN c_curr_date;
FETCH c_curr_date Into cp_sysdate;
CLOSE c_curr_date;


if errbuf is not null then
raise pqh_pack_err;
return (FALSE);
else
  return (TRUE);
end if;



exception
when pqh_pack_err then
/*srw.message(100, errbuf);*/null;

--return (FALSE);
RETURN (TRUE);
when others then
/*srw.message(100, 'Unexpected error occured in the Before Report trigger for PQH_PQUBGTEN_XMLP_PKG report');*/null;

--return (FALSE);
RETURN (TRUE);
end;

function CP_sysdateFormula return Date is
begin
null;
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function cf_amount_format_maskformula(uom in varchar2) return char is
l_format_mask  varchar2(40);
l_currency_code varchar2(10);
l_leg_code   varchar2(10);
cursor csr_leg_code IS
    SELECT  bg.legislation_code
    FROM    per_business_groups_perf bg
    WHERE   bg.business_group_id = p_business_group_id;
begin
  l_currency_code := hr_general.default_currency_code(p_business_group_id => p_business_group_id);
  IF l_currency_code IS NULL THEN
    OPEN csr_leg_code;
    FETCH csr_leg_code INTO l_leg_code;
    CLOSE csr_leg_code;
    l_currency_code := hr_general.default_currency_code(p_legislation_code => l_leg_code);
  END IF;
  IF uom = 'MONEY' and l_currency_code IS NOT NULL THEN
      l_format_mask := fnd_currency.get_format_mask(l_currency_code,22);
  ELSE
    fnd_currency.build_format_mask(l_format_mask,22,2,null,null,null,null);
   END IF;
RETURN l_format_mask;

end;

function BeforePForm return boolean is
begin
  insert into fnd_sessions (session_id, effective_date)
 values(userenv('sessionid'),p_effective_date);
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_No_Data_p return varchar2 is
	Begin
	 return CP_No_Data;
	 END;
 Function CP_sysdate_p return date is
	Begin
	 return CP_sysdate;
	 END;
 Function CP_BG_NAME_p return varchar2 is
	Begin
	 return CP_BG_NAME;
	 END;
 Function CP_UOM_p return varchar2 is
	Begin
	 return CP_UOM;
	 END;
 Function CP_ENTITY_NAME_p return varchar2 is
	Begin
	 return CP_ENTITY_NAME;
	 END;
 Function CP_ORG_STRUCTURE_NAME_p return varchar2 is
	Begin
	 return CP_ORG_STRUCTURE_NAME;
	 END;
 Function CP_START_ORG_NAME_p return varchar2 is
	Begin
	 return CP_START_ORG_NAME;
	 END;
 Function CP_REPORT_TITLE_p return varchar2 is
	Begin
	 return CP_REPORT_TITLE;
	 END;
END PQH_PQUBGTEN_XMLP_PKG ;

/
