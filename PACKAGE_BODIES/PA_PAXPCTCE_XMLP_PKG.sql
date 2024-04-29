--------------------------------------------------------
--  DDL for Package Body PA_PAXPCTCE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXPCTCE_XMLP_PKG" AS
/* $Header: PAXPCTCEB.pls 120.2 2008/01/03 12:15:04 krreddy noship $ */

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
 hold_employee_name  varchar2(240);
 org_name  hr_organization_units.name%TYPE;

BEGIN
DATE_LOW_1:=to_char(DATE_LOW,'DD-MON-YY');
DATE_HIGH_1:=to_char(DATE_HIGH,'DD-MON-YY');
/*srw.user_exit('FND SRWINIT');*/null;

/*srw.message(1,'Satyen This is ur report');*/null;

/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;





IF incurred_org is not null then
   select substr(name,1,30)
   into org_name from
   hr_organization_units
   where organization_id = incurred_org;
END IF;
c_incurred_org := org_name;


If employee_id is not null
  then
    select full_name
    into   hold_employee_name
    from   per_people_f
    where  person_id = PA_PAXPCTCE_XMLP_PKG.employee_id
    and   sysdate between effective_start_date
					 and     nvl(effective_end_date,sysdate + 1)
    and (  employee_number IS NOT NULL or npw_number IS NOT NULL);

    c_employee_name := substr(hold_employee_name,1,80);
end if;


  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;
EXCEPTION
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

function c_billable_timeformula(c_hours in number, c_billable_hour in number) return number is
  temp_value number := 0;
begin
  if c_hours <> 0 then
    temp_value := round((nvl(c_billable_hour,0)/c_hours)
                 ,4) * 100;
  end if;
  return(temp_value);
end;

function BeforePForm return boolean is
begin

  return (TRUE);
end;

function AfterPForm return boolean is
begin

  return (TRUE);
end;

function BetweenPage return boolean is
begin

  return (TRUE);
end;

function AfterReport return boolean is
begin

  /*srw.user_exit('FND SRWEXIT') ;*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_employee_name_p return varchar2 is
	Begin
	 return C_employee_name;
	 END;
 Function C_INCURRED_ORG_p return varchar2 is
	Begin
	 return C_INCURRED_ORG;
	 END;
END PA_PAXPCTCE_XMLP_PKG ;


/
