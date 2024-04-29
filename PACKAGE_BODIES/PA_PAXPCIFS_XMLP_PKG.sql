--------------------------------------------------------
--  DDL for Package Body PA_PAXPCIFS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXPCIFS_XMLP_PKG" AS
/* $Header: PAXPCIFSB.pls 120.0 2008/01/02 11:42:17 krreddy noship $ */

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
 ndf VARCHAR2(80);
 org_name hr_organization_units.name%TYPE;
 member_name VARCHAR2(240);
 role_type VARCHAR2(80);
 enter_param VARCHAR2(80);
BEGIN

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
    select Substr(name, 1, 60) into org_name from hr_organization_units where          organization_id = p_start_organization_id;
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
   project_role_type = PA_PAXPCIFS_XMLP_PKG.project_role_type;
end if;

c_role_type := role_type;
bucket1_low := -999999999.99;
bucket1_high := 24999.99;
bucket2_low := 25000.00;
bucket2_high := 100000.00;
bucket3_low := 100000.01;
bucket3_high := 9999999999.99;


IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;
IF  (get_start_org <> TRUE) THEN
     RAISE init_failure;

END IF;
     select meaning into ndf from pa_lookups where
     lookup_code= 'NO_DATA_FOUND'
     and lookup_type = 'MESSAGE';
  C_no_data_found := ndf;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     select meaning into ndf from pa_lookups where
     lookup_code= 'NO_DATA_FOUND'
     and lookup_type = 'MESSAGE';
  C_no_data_found := ndf;
   c_dummy_data := 1;
  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;  return (TRUE);
end;

FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                gl_sets_of_books.name%TYPE;
  l_currency            gl_sets_of_books.currency_code%TYPE;

BEGIN
  SELECT  gl.name, gl.currency_code
  INTO    l_name, l_currency
  FROM    gl_sets_of_books gl,pa_implementations pi
  WHERE   gl.set_of_books_id = pi.set_of_books_id;

  c_company_name_header     := l_name;
  c_currency		     := l_currency;

  RETURN (TRUE);

EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION get_start_org RETURN BOOLEAN IS
  c_start_organization_id number(15);
BEGIN
select
 decode(p_start_organization_id,null,       start_organization_id,p_start_organization_id)
 into
     c_start_organization_id
 from
  pa_implementations;
insert
into
pa_org_reporting_sessions
(start_organization_id,session_id)
values
(c_start_organization_id,userenv('SESSIONID'));
RETURN (TRUE);
EXCEPTION WHEN OTHERS THEN
 RETURN (FALSE);
END;

function c_amountformula(C_amount1 in number, C_amount2 in number, C_amount3 in number) return number is
begin

 return ((nvl(C_amount1,0)+nvl(C_amount2,0)+nvl(C_amount3,0)));
end;

function c_countformula(c_count1 in number, c_count2 in number, c_count3 in number) return number is
begin

 return ((c_count1+c_count2+c_count3));
end;

function G_project_orgGroupFilter return boolean is
begin

BEGIN
 If p_start_organization_id is null then
    if project_member is null then
      return(FALSE);
    else
      return(TRUE);
    end if;
 else
    RETURN(TRUE);
 end if;
END;  return (TRUE);
end;

function AfterReport return boolean is
begin

BEGIN
 /*srw.user_exit('FND SRWEXIT');*/null;

 ROLLBACK;
END;  return (TRUE);
end;

function c_inv_amountformula(C_inv_amount1 in number, C_inv_amount2 in number, C_inv_amount3 in number) return number is
begin

 return ((nvl(C_inv_amount1,0)+nvl(C_inv_amount2,0)+nvl(C_inv_amount3,0)));
end;

function c_inv_countformula(c_inv_count1 in number, c_inv_count2 in number, c_inv_count3 in number) return number is
begin

 return ((c_inv_count1+c_inv_count2+c_inv_count3));
end;

function CF_CURRENCY_CODEFormula return VARCHAR2 is
begin
  return(pa_multi_currency.get_acct_currency_code);
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
 Function bucket1_low_p return number is
	Begin
	 return bucket1_low;
	 END;
 Function bucket1_high_p return number is
	Begin
	 return bucket1_high;
	 END;
 Function bucket2_low_p return number is
	Begin
	 return bucket2_low;
	 END;
 Function bucket2_high_p return number is
	Begin
	 return bucket2_high;
	 END;
 Function bucket3_low_p return number is
	Begin
	 return bucket3_low;
	 END;
 Function bucket3_high_p return number is
	Begin
	 return bucket3_high;
	 END;
 Function C_no_data_found_p return varchar2 is
	Begin
	 return C_no_data_found;
	 END;
 Function C_dummy_data_p return number is
	Begin
	 return C_dummy_data;
	 END;
 Function C_currency_p return varchar2 is
	Begin
	 return C_currency;
	 END;
END PA_PAXPCIFS_XMLP_PKG ;


/
