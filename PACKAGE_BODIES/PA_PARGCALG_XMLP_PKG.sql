--------------------------------------------------------
--  DDL for Package Body PA_PARGCALG_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PARGCALG_XMLP_PKG" AS
/* $Header: PARGCALGB.pls 120.1 2008/01/03 11:09:31 krreddy noship $ */

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);

end;

function BeforeReport return boolean is
 x_status       VARCHAR2(1);
 x_count        NUMBER;
 x_data         VARCHAR2(250);

begin

/*srw.user_exit('FND SRWINIT');*/null;



/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;









/*srw.user_exit('FND GETPROFILE
NAME="CURRENCY:MIXED_PRECISION"
FIELD=":p_min_precision"
PRINT_ERROR="N"');*/null;



 IF (UPPER(p_run_mode) = 'R') THEN
  PA_SCHEDULE_PUB.create_new_cal_schedules(p_start_calendar_name,
                           p_end_calendar_name,
                           x_status,x_count,x_data);
 ELSIF (UPPER(p_run_mode) = 'S' ) THEN
  PA_SCHEDULE_PUB.create_new_cal_schedules(p_start_calendar_name,
                           p_start_calendar_name,
                           x_status,x_count,x_data);
 END IF;

   return(TRUE);
EXCEPTION
  WHEN OTHERS THEN
       Raise;
return (TRUE);
end;

function CF_company_nameFormula return Char is
 v_company_name  gl_sets_of_books.name%type;

begin

  select glb.name into v_company_name
  from gl_sets_of_books glb, pa_implementations pi
  where glb.set_of_books_id=pi.set_of_books_id;
  cp_company_name:=v_company_name;
   return  cp_company_name;
 exception
    when others then
     null;
     return  cp_company_name;
end;

--Functions to refer Oracle report placeholders--

 Function CP_company_name_p return varchar2 is
	Begin
	 return CP_company_name;
	 END;
 Function CP_NODATAFOUND_p return varchar2 is
	Begin
	 return CP_NODATAFOUND;
	 END;
END PA_PARGCALG_XMLP_PKG ;


/
