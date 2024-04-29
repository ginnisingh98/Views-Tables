--------------------------------------------------------
--  DDL for Package Body PA_PAXAUMTC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXAUMTC_XMLP_PKG" AS
/* $Header: PAXAUMTCB.pls 120.0 2008/01/02 11:18:34 krreddy noship $ */
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
 msg varchar2(2000);
 init_failure exception;
 hold_employee_name  VARCHAR2(40);
 p_date_lo date;
 p_date_hi date;
 code VARCHAR2(80);
 org_name hr_organization_units.name%TYPE;
 person_name VARCHAR2(30);
 start_day NUMBER;

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







If employee_id is not null
  then
    select substr(full_name,1,40)
    into   hold_employee_name
    from   per_people_f
    where  person_id = employee_id
    and   ((sysdate between effective_start_date
		      and nvl(effective_end_date,sysdate + 1))
          or (effective_start_date > sysdate))
    and   (employee_number IS NOT NULL or npw_number IS NOT NULL);
end if;
c_employee_name := hold_employee_name;

IF incurred_org is not null then
   select substr(name,1,30)
   into org_name from
   hr_organization_units
   where organization_id = incurred_org;
END IF;
c_incurred_org := org_name;

IF supervisor is not null then
  select substr(full_name,1,30)
  into person_name
  from per_people_f
  where person_id = supervisor
  and   ((sysdate between effective_start_date
		    and nvl(effective_end_date,sysdate + 1))
        or (effective_start_date > sysdate))
  and   (employee_number IS NOT NULL or npw_number IS NOT NULL);

ELSE
 select '' into person_name from dual;
END IF;
c_supervisor := person_name;



 c_date_lo := date_lo;
 c_date_hi := date_hi;


  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;

EXCEPTION
  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;
  return (TRUE);
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

function AfterReport return boolean is
begin

BEGIN
 /*srw.user_exit('FND SRWEXIT');*/null;

END;  return (TRUE);
end;

function AfterPForm return boolean is

l_start_date varchar2(11);
l_end_date  varchar2(11) ;
l_dummy_date  varchar2(11);
l_dt_format varchar2(40) := 'dd-mon-rrrr';
begin
	/*srw.user_exit('FND SRWINIT');*/null;

	l_start_date := pa_utils.getweekending(date_lo);
  l_end_date   := pa_utils.getweekending(date_hi);
  l_dummy_date := l_start_date;
  if to_date(l_end_date, l_dt_format) > to_date(date_hi, l_dt_format)  then
  	l_end_date := to_date(l_end_date, l_dt_format) - 7;
  end if ;
	while to_date(l_dummy_date, l_dt_format) <= to_date(l_end_date, l_dt_format)
	 loop
    where_stmt := where_stmt||' union select to_date('||''''||l_dummy_date||''''|| ','||''''||l_dt_format||''''|| ') from dual';
    l_dummy_date  := to_date(l_dummy_date,l_dt_format) + 7;
	 end loop;
	 where_stmt := where_stmt || ' minus select distinct to_date(expenditure_ending_date,'||''''||l_dt_format||''''||') from pa_expenditures where expenditure_ending_date between :date_lo and :date_hi  and expenditure_class_code in (' || ''''
                        || 'PT' || '''' || ',' || '''' || 'OT' || '''' || ') order by 1' ;
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
 Function C_date_lo_p return date is
	Begin
	 return C_date_lo;
	 END;
 Function C_date_hi_p return date is
	Begin
	 return C_date_hi;
	 END;
 Function C_incurred_org_p return varchar2 is
	Begin
	 return C_incurred_org;
	 END;
 Function C_supervisor_p return varchar2 is
	Begin
	 return C_supervisor;
	 END;
END PA_PAXAUMTC_XMLP_PKG ;

/
