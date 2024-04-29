--------------------------------------------------------
--  DDL for Package Body PA_PAXEMRAO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXEMRAO_XMLP_PKG" AS
/* $Header: PAXEMRAOB.pls 120.0 2008/01/02 11:26:48 krreddy noship $ */

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
 hold_employee_name    VARCHAR2(50);
 org_name  hr_organization_units.name%TYPE;
 yes_no VARCHAR2(40);
BEGIN

CP_DATE_LO := TO_CHAR(DATE_LO,'DD-MON-YY');
CP_DATE_HI := TO_CHAR(DATE_HI,'DD-MON-YY');

/*srw.user_exit('FND SRWINIT');*/null;



/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;






/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;








if start_org_id is not null then
select substr(name,1,40)
into   org_name
from   hr_organization_units
where  organization_id = start_org_id;
end if;
c_org_name := org_name;


If p_person_id is not null
  then
   select   substr(full_name,1,50)
   into     hold_employee_name
   from     per_people_f
   where    person_id = p_person_id
    and   sysdate between effective_start_date
					 and  nvl(effective_end_date,sysdate + 1)
    and   (employee_number IS NOT NULL OR npw_number IS NOT NULL );
   c_employee_name := hold_employee_name;
end if;

If display_detail is not null then
    select substr(meaning,1,40) into yes_no from fnd_lookups
    where lookup_code = display_detail
    and   lookup_type =  'YES_NO';
end if;
 c_display_details := yes_no;

  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
   END IF;
  IF (get_start_org <> TRUE) THEN
     RAISE init_failure;
  END IF;

IF (no_data_found_func <> TRUE) THEN
   RAISE init_failure;
END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   IF (no_data_found_func <> TRUE) THEN
   RAISE init_failure;
END IF;
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
select
 decode(start_org_id,null,
       start_organization_id,start_org_id)
 into
     c_start_organization_id
 from
  pa_implementations;
insert into
pa_org_reporting_sessions
(start_organization_id,session_id)
values(c_start_organization_id,userenv('SESSIONID'));
RETURN (TRUE);
EXCEPTION WHEN OTHERS THEN
 RETURN (FALSE);
END;

function G_projectGroupFilter return boolean is
begin


  return (TRUE);
end;

function c_utilizationformula(total_hours in number, billable_hours in number) return number is

 hold_result          number;
 hold_project_result  number;

begin




If total_hours > 0
  then
   hold_result := billable_hours / total_hours * 100;
   return(hold_result);
  else
    return(0);
End if;



end;

Function cal_util return NUMBER is

Begin
      null;


END;

function c_project_utilizationformula(c_project_tot_hours in number, c_project_tot_billable in number) return number is
hold_project_util    number;

Begin

If c_project_tot_hours > 0
  then
    hold_project_util :=
      c_project_tot_billable / c_project_tot_hours * 100;
    return(hold_project_util);
  else
    return(0);
End if;
end;

function cal_project_util return NUMBER is

Begin

null;
End;

function cal_org_util return NUMBER is

Begin

   null;

End;

function c_org_utilizationformula(c_org_tot_hours in number, c_org_tot_billable in number) return number is

hold_org_util    number;

Begin




If c_org_tot_hours > 0
  then
    hold_org_util :=
      c_org_tot_billable / c_org_tot_hours * 100;
    return(hold_org_util);
  else
    return(0);
End if;



end;

function AfterReport return boolean is
begin

Begin
 Rollback;
End;
 /*srw.user_exit('FND SRWEXIT');*/null;

 return (TRUE);
end;

Function no_data_found_func return boolean is
message_name VARCHAR2(80);
begin
 select meaning into message_name from pa_lookups
 where lookup_type = 'MESSAGE'
 and lookup_code = 'NO_DATA_FOUND';
 c_no_data_found := message_name;
return(TRUE);
EXCEPTION
WHEN OTHERS THEN
RETURN(FALSE);
END;

function G_emp_detGroupFilter return boolean is
begin

If display_detail = 'Y'
 then
  return(TRUE);
 else
  return(FALSE);
end if;
  return (TRUE);
end;

function G_emp_detailGroupFilter return boolean is
begin

If display_detail = 'Y'
 then
  return(TRUE);
 else
  return(FALSE);
end if;
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_org_name_p return varchar2 is
	Begin
	 return C_org_name;
	 END;
 Function C_employee_name_p return varchar2 is
	Begin
	 return C_employee_name;
	 END;
 Function C_no_data_found_p return varchar2 is
	Begin
	 return C_no_data_found;
	 END;
 Function C_display_details_p return varchar2 is
	Begin
	 return C_display_details;
	 END;
END PA_PAXEMRAO_XMLP_PKG ;


/
