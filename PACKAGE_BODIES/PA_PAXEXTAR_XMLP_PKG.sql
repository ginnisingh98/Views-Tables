--------------------------------------------------------
--  DDL for Package Body PA_PAXEXTAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXEXTAR_XMLP_PKG" AS
/* $Header: PAXEXTARB.pls 120.0 2008/01/02 11:32:06 krreddy noship $ */

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
 prj_num varchar2(25);
 prj_name varchar2(30);
 e_name VARCHAR2(30);
 tsk_name varchar2(30);
 tsk_num varchar2(25);
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







  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;

SELECT
	name
,	segment1
  INTO
	prj_name
,	prj_num
  FROM
	pa_projects p
 WHERE
	p.project_id = PROJECT;

C_project_name := prj_name;
C_project_num  := prj_num;

IF ( TASK IS NOT NULL ) THEN
SELECT
	task_name
,	task_number
  INTO
	tsk_name
,	tsk_num
  FROM
	pa_tasks
 WHERE
	task_id = TASK;

C_task_name := tsk_name;
C_task_num  := tsk_num;
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

function  get_task(
	      t_id  number ) return varchar2 is

		tsk	VARCHAR2(35);

BEGIN
	SELECT
		rpad( t.task_number, 18, ' ' )||
                rpad( t.task_name, 17, ' ' )
          INTO
	   	tsk
	  FROM
		pa_tasks t
	 WHERE
		t.task_id = t_id;


	RETURN ( tsk );


	 EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN ( ' ' );

END  get_task;

function c_taskformula(t_id in number) return varchar2 is
begin

 return (get_task ( t_id ));
end;

function AfterReport return boolean is
begin

BEGIN
 /*srw.user_exit('FND SRWEXIT');*/null;

END;
 return (TRUE);
end;

function get_project (t_id   NUMBER ,level in number) return varchar2 is

	prj	VARCHAR2(35);

BEGIN
	SELECT
		substr((lpad( ' ', 2*(level-1) )||
		rpad( p.segment1, 18, ' ' )||
		rpad( p.name, 17, ' ' )), 1, 35 )
          INTO
		prj
	  FROM
		pa_projects p
	,	pa_tasks t
	 WHERE
		p.project_id = t.project_id
	   AND  t.task_id = t_id;

	RETURN ( prj );

	 EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN ( ' ' );

END get_project;

function c_projectformula(t_id in number,level in number) return varchar2 is
begin

 return (get_project(
              t_id,level) );
end;

function CF_ACCT_CURRENCY_CODEFormula return Varchar2 is
begin
  return(pa_multi_currency.get_acct_currency_code);
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
 Function C_project_name_p return varchar2 is
	Begin
	 return C_project_name;
	 END;
 Function C_project_num_p return varchar2 is
	Begin
	 return C_project_num;
	 END;
 Function C_task_name_p return varchar2 is
	Begin
	 return C_task_name;
	 END;
 Function C_task_num_p return varchar2 is
	Begin
	 return C_task_num;
	 END;
END PA_PAXEXTAR_XMLP_PKG ;

/
