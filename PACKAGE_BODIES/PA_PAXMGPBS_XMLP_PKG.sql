--------------------------------------------------------
--  DDL for Package Body PA_PAXMGPBS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXMGPBS_XMLP_PKG" AS
/* $Header: PAXMGPBSB.pls 120.1 2008/01/03 11:14:05 krreddy noship $ */

FUNCTION  get_cover_page_values   RETURN BOOLEAN IS

BEGIN

RETURN(TRUE);

EXCEPTION
WHEN OTHERS THEN
  RETURN(FALSE);

END;

function BeforeReport return boolean is
begin


Declare
 init_failure exception;
 org_name hr_organization_units.name%TYPE;
 member_name VARCHAR2(240);
 role_type VARCHAR2(80);
 enter_param VARCHAR2(80);
 p_number VARCHAR2(40);
 p_name VARCHAR2(40);
 p_never_billed VARCHAR2(80);
 p_billing_method VARCHAR2(80);
BEGIN
  CP_BILL_THRU_DATE:=TO_CHAR(BILL_THRU_DATE,'DD-MON-YY');

/*srw.user_exit('FND SRWINIT');*/null;



/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;







/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;







if (p_start_organization_id is null and
   project_member is null) then
select meaning into enter_param from pa_lookups where
lookup_type = 'ENTER VALUE' and
lookup_code = 'ENTER_ORG_MGR';
end if;
c_enter := enter_param;

If p_start_organization_id is not null then
    select substr(name,1,60) into org_name from hr_organization_units where
      organization_id = p_start_organization_id;
end if;
c_start_org := org_name;

IF project_member is not null then
   select full_name into member_name from per_people_f where
    person_id = project_member
    and   sysdate between effective_start_date
	 and     nvl(effective_end_date,sysdate + 1)
and (Current_NPW_Flag='Y' OR Current_Employee_Flag='Y')
    and Decode(Current_NPW_Flag,'Y',NPW_Number,employee_number) IS NOT NULL ;
end if;
c_project_member := member_name;

if project_role_type is not null then
   select meaning into role_type
   from pa_project_role_types where
   project_role_type = PA_PAXMGPBS_XMLP_PKG.project_role_type;
end if;
c_role_type := role_type;

if project is not null then
   select segment1 into p_number
   from pa_projects where
   project = project_id;
end if;
c_proj_number := p_number;

if project is not null then
   select name into p_name
   from pa_projects where
   project = project_id;
end if;
c_proj_name := p_name;

if never_billed is not null then
   select meaning into p_never_billed
   from fnd_lookups where
   never_billed = lookup_code
   and lookup_type = 'YES_NO';
end if;
c_never_billed := p_never_billed;

if billing_method is not null then
   select meaning into p_billing_method
   from pa_lookups where
   billing_method = lookup_code
   and lookup_type = 'BILLING_TYPE';
end if;
c_billing_method := p_billing_method;


IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;

IF  (get_start_org <> TRUE) THEN
     RAISE init_failure;
END IF;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
  null;
  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;  return (TRUE);
end;

FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                  gl_sets_of_books.name%TYPE;
BEGIN
  SELECT  gl.name
  INTO    l_name
  FROM    gl_sets_of_books gl,pa_implementations pi
  WHERE   gl.set_of_books_id = pi.set_of_books_id;

  c_company_name_header     := l_name;

  RETURN (TRUE);

 EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION get_start_org RETURN BOOLEAN IS
  c_start_organization_id number;
BEGIN
IF project is null then
    select
       decode(p_start_organization_id,null,
     start_organization_id,p_start_organization_id)
    into
     c_start_organization_id
    from
     pa_implementations;
ELSIF
   project is not null then
    select null
    into c_start_organization_id
    from sys.dual;
END IF;
   insert into
    pa_org_reporting_sessions
    (start_organization_id,session_id)
   values
    (c_start_organization_id,userenv('SESSIONID'));

RETURN (TRUE);
EXCEPTION
WHEN NO_DATA_FOUND THEN
 null;
WHEN OTHERS THEN
 RETURN (FALSE);
END;

function AfterReport return boolean is
begin

BEGIN
  /*srw.user_exit('FND SRWEXIT');*/null;

  ROLLBACK;
END;  return (TRUE);
end;

function CF_CURRECNY_CODEFormula return VARCHAR2 is
begin
  return(pa_multi_currency.get_acct_currency_code);
end;

function cf_ubrformula(projfunc_ubr_amount in number) return number is
ubr number := null;
begin





return(NVL(projfunc_ubr_amount,0));
end;

function cf_1formula(enable_top_task_inv_mth_flag in varchar2) return varchar2 is
  l_meaning varchar2(20);
begin
  select meaning
    into l_meaning
    from pa_lookups
   where lookup_type = 'YES_NO'
     and lookup_code = nvl(enable_top_task_inv_mth_flag, 'N');

   return l_meaning;
end;

--Functions to refer Oracle report placeholders--

 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_start_org_p return varchar2 is
	Begin
	 return C_start_org;
	 END;
 Function C_project_member_p return varchar2 is
	Begin
	 return C_project_member;
	 END;
 Function C_role_type_p return varchar2 is
	Begin
	 return C_role_type;
	 END;
 Function C_enter_p return varchar2 is
	Begin
	 return C_enter;
	 END;
 Function C_proj_number_p return varchar2 is
	Begin
	 return C_proj_number;
	 END;
 Function C_proj_name_p return varchar2 is
	Begin
	 return C_proj_name;
	 END;
 Function C_never_billed_p return varchar2 is
	Begin
	 return C_never_billed;
	 END;
 Function C_billing_method_p return varchar2 is
	Begin
	 return C_billing_method;
	 END;
END PA_PAXMGPBS_XMLP_PKG ;


/
