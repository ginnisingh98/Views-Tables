--------------------------------------------------------
--  DDL for Package Body PA_PAXPRWBS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXPRWBS_XMLP_PKG" AS
/* $Header: PAXPRWBSB.pls 120.0 2008/01/02 11:52:54 krreddy noship $ */

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
 tsk_number VARCHAR2(40);
 tsk_name VARCHAR2(40);
 proj_name VARCHAR2(40);
 proj_number VARCHAR2(40);
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



TOP_TASK_ID1:=top_task_id;


IF (top_task_id1 is not null
     and top_task_id <> 'All') then
    select task_name,task_number
    into tsk_name,tsk_number
    from pa_tasks where top_task_id1 = task_id;
end if;

c_top_task_number := tsk_number;
c_top_task_name := tsk_name;

IF proj is not null then
    select segment1,name
    into proj_number,proj_name
    from pa_projects where proj = project_id;
end if;
c_project_name := proj_name;
c_project_number := proj_number;

  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;
 IF (no_data_found_func <> TRUE) THEN
     RAISE init_failure;
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

FUNCTION NO_DATA_FOUND_FUNC RETURN BOOLEAN IS

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

function AfterReport return boolean is
begin

BEGIN
 /*srw.user_exit('FND SRWEXIT');*/null;

END;  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function c_no_data_found_p return varchar2 is
	Begin
	 return c_no_data_found;
	 END;
 Function C_top_task_number_p return varchar2 is
	Begin
	 return C_top_task_number;
	 END;
 Function C_top_task_name_p return varchar2 is
	Begin
	 return C_top_task_name;
	 END;
 Function C_project_number_p return varchar2 is
	Begin
	 return C_project_number;
	 END;
 Function c_project_name_p return varchar2 is
	Begin
	 return c_project_name;
	 END;
END PA_PAXPRWBS_XMLP_PKG ;


/
