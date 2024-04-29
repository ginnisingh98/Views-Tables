--------------------------------------------------------
--  DDL for Package Body PQH_PQHWSOPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQHWSOPS_XMLP_PKG" AS
/* $Header: PQHWSOPSB.pls 120.3 2008/01/11 08:31:45 srikrish noship $ */

function BeforeReport return boolean is

val boolean;
begin
P_START_DATE_1 := NVL(P_START_DATE,TO_DATE('01-01-1990','DD-MM-YYYY'));
P_END_DATE_1 := NVL(P_END_DATE,TO_DATE('01-01-2020','DD-MM-YYYY'));
p_organization_id_1 := NVL(p_organization_id,202);
p_business_group_id_1 := NVL(p_business_group_id,202);
p_session_date_1 := NVL(p_session_date,TO_DATE('26-10-2000','DD-MM-YYYY'));
p_effective_date_1 := p_effective_date;

declare


CURSOR csr_org_name IS
SELECT name
FROM hr_all_organization_units_tl
WHERE language = userenv('LANG')
  AND organization_id = p_organization_id;

CURSOR csr_posn_type IS
SELECT meaning
FROM hr_lookups
WHERE lookup_type = 'PQH_POSITION_TYPE'
  AND  lookup_code = p_position_type;

Cursor csr_currency_name IS
SELECT name
FROM  FND_CURRENCIES_ACTIVE_V
WHERE currency_code <>'STAT'
AND currency_code = p_currency_code;

CURSOR csr_session_date IS
SELECT sysdate
FROM dual;

begin

val:= BeforePForm;
 null;
 /*srw.user_exit('FND SRWINIT');*/null;


   OPEN csr_currency_name;
        FETCH csr_currency_name into  cp_currency;
  CLOSE csr_currency_name;

  OPEN csr_org_name;
    FETCH csr_org_name INTO cp_organization_name;
  CLOSE csr_org_name;


  OPEN csr_posn_type;
     FETCH csr_posn_type INTO  cp_position_type;
   CLOSE csr_posn_type;


       P_REPORT_TITLE := hr_general.decode_lookup('PQH_REPORT_TITLES','PQHWSOPS');

 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);

OPEN csr_session_date;
  FETCH csr_session_date INTO cp_session_dt;
CLOSE csr_session_date;

end;

return (TRUE);
end;

function cf_1formula(Budget_Unit_id1 in number, actual_amt in number, committed_amt in number) return number is
Cursor Shared_types is
Select System_Type_cd
from Per_Shared_types
Where Shared_type_id = Budget_Unit_id1;

L_Shared_type_Cd  Per_Shared_Types.System_Type_Cd%TYPE;
begin
Open Shared_types;
Fetch Shared_types into l_Shared_Type_Cd;
Close ShaRED_TYPES;
IF L_SHARED_TYPE_CD = 'MONEY' THEN
   return (NVL(actual_amt,0) + NVL(committed_amt,0) ) ;
Else
   return (NVL(actual_amt,0)) ;
End If;
end;

function cf_def_ex_amtformula(budgeted_amt in number, cf_projected_exp in number) return number is
begin
  return (NVL(budgeted_amt,0) - NVL(cf_projected_exp,0));
end;

function BeforePForm return boolean is
begin
  insert into fnd_sessions(session_id, effective_date)
  values(userenv('sessionid'), p_effective_date);

  return (TRUE);
end;

function cf_act_performula(budgeted_amt in number, actual_amt in number) return number is
begin
  if budgeted_amt = 0 then
    return 0;
  else
     return (NVL(actual_amt,0) / budgeted_amt ) * 100 ;
   end if;
end;

function cf_com_performula(budgeted_amt in number, committed_amt in number) return number is
begin
  if budgeted_amt = 0 then
    return 0;
  else
     return (NVL(committed_amt,0) / budgeted_amt ) * 100 ;
   end if;
end;

function cf_proj_performula(budgeted_amt in number, cf_projected_exp in number) return number is
begin
  if budgeted_amt = 0 then
    return 0;
  else
     return (NVL(cf_projected_exp,0) / budgeted_amt ) * 100 ;
   end if;
end;

function cf_def_ex_performula(budgeted_amt in number, cf_def_ex_amt in number) return number is
begin
  if budgeted_amt = 0 then
    return 0;
  else
     return (NVL(cf_def_ex_amt,0) / budgeted_amt ) * 100 ;
   end if;
end;

function cf_org_budgeted_amtformula(organization_id1 in number, budget_unit_id in number) return number is

l_amt number(15,2);

begin

 l_amt := pqh_mgmt_rpt_pkg.get_org_posn_budget_amt
          (
           organization_id1,
           p_start_date,
           p_end_date,
           budget_unit_id,
	   p_currency_code
       ) ;

  return NVL(l_amt,0);
end;

function cf_org_actual_amtformula(organization_id1 in number, budget_unit_id in number) return number is

l_amt number(15,2);

begin

 l_amt := pqh_mgmt_rpt_pkg.get_org_posn_actual_cmmtmnts
       (
        organization_id1,
        p_start_date,
        p_end_date,
        budget_unit_id,
        'A',
p_currency_code
       ) ;

  return NVL(l_amt,0);

end;

function cf_org_act_performula(cf_org_budgeted_amt in number, cf_org_actual_amt in number) return number is
begin
 if cf_org_budgeted_amt = 0 then
    return 0;
  else
     return (NVL(cf_org_actual_amt,0) / cf_org_budgeted_amt ) * 100 ;
  end if;
end;

function cf_org_committed_amtformula(organization_id1 in number, budget_unit_id in number) return number is
l_amt number(15,2);

begin

 l_amt := pqh_mgmt_rpt_pkg.get_org_posn_actual_cmmtmnts
       (
        organization_id1,
        p_start_date,
        p_end_date,
        budget_unit_id,
        'C',
p_currency_code
       ) ;

  return NVL(l_amt,0);

end;

function cf_org_com_performula(cf_org_budgeted_amt in number, cf_org_committed_amt in number) return number is
begin
   if cf_org_budgeted_amt = 0 then
    return 0;
  else
     return (NVL(cf_org_committed_amt,0) / cf_org_budgeted_amt ) * 100 ;
   end if;
end;

function cf_org_projected_expformula(Budget_Unit_id in number, cf_org_actual_amt in number, cf_org_committed_amt in number) return number is
Cursor Shared_types is
Select System_Type_cd
from Per_Shared_types
Where Shared_type_id = Budget_Unit_id;

L_Shared_type_Cd  Per_Shared_Types.System_Type_Cd%TYPE;
begin
Open Shared_types;
Fetch Shared_types into l_Shared_Type_Cd;
Close ShaRED_TYPES;
IF L_SHARED_TYPE_CD = 'MONEY' THEN
    return (NVL(cf_org_actual_amt,0) + NVL(cf_org_committed_amt,0) ) ;
Else
    return (NVL(cf_org_actual_amt,0) ) ;
End If;
end;

function cf_org_proj_performula(cf_org_budgeted_amt in number, cf_org_projected_exp in number) return number is
begin
  if cf_org_budgeted_amt = 0 then
    return 0;
  else
     return (NVL(cf_org_projected_exp,0) / cf_org_budgeted_amt ) * 100 ;
  end if;
end;

function cf_org_def_ex_amtformula(cf_org_budgeted_amt in number, cf_org_projected_exp in number) return number is
begin
  return (NVL(cf_org_budgeted_amt,0) - NVL(cf_org_projected_exp,0));
end;

function cf_org_def_ex_performula(cf_org_budgeted_amt in number, cf_org_def_ex_amt in number) return number is
begin
   if cf_org_budgeted_amt = 0 then
    return 0;
  else
     return (NVL(cf_org_def_ex_amt,0) / cf_org_budgeted_amt ) * 100 ;
   end if;
end;

function cf_format_mask1(budget_unit_id in number) return char is
cursor csr_uom is
        select system_type_cd
          from per_shared_types
          where shared_type_id = budget_unit_id and
                lookup_type = 'BUDGET_MEASUREMENT_TYPE';

l_budget_measurement_type per_shared_types.shared_type_name%TYPE;
l_format_mask varchar2(50);
BEGIN
     open csr_uom;
      fetch csr_uom into l_budget_measurement_type;
     close csr_uom;

     if l_budget_measurement_type = 'MONEY' then
          l_format_mask := fnd_currency.get_format_mask(p_currency_code,22);
     else
          fnd_currency.build_format_mask(l_format_mask,22,2,null,null,null,null);
     end if;
return l_format_mask;
end;

function cf_format_mask2(budget_unit_id1 in number) return char is
cursor csr_uom is
        select system_type_cd
          from per_shared_types
          where shared_type_id = budget_unit_id1 and
                lookup_type = 'BUDGET_MEASUREMENT_TYPE';

l_budget_measurement_type per_shared_types.shared_type_name%TYPE;
l_format_mask varchar2(50);
BEGIN
     open csr_uom;
      fetch csr_uom into l_budget_measurement_type;
     close csr_uom;

     if l_budget_measurement_type = 'MONEY' then
          l_format_mask := fnd_currency.get_format_mask(p_currency_code,22);
     else
          fnd_currency.build_format_mask(l_format_mask,22,2,null,null,null,null);
     end if;
return l_format_mask;
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function CP_organization_name_p return varchar2 is
	Begin
	 return CP_organization_name;
	 END;
 Function CP_position_type_p return varchar2 is
	Begin
	 return CP_position_type;
	 END;
 Function CP_currency_p return varchar2 is
	Begin
	 return CP_currency;
	 END;
 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function cp_session_dt_p return date is
	Begin
	 return cp_session_dt;
	 END;
END PQH_PQHWSOPS_XMLP_PKG ;

/
