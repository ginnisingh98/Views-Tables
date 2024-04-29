--------------------------------------------------------
--  DDL for Package Body PA_PAXPCEGS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXPCEGS_XMLP_PKG" AS
/* $Header: PAXPCEGSB.pls 120.0 2008/01/02 11:39:50 krreddy noship $ */
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
 c_org_name hr_organization_units.name%TYPE;
BEGIN
  P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
  ENDING_DATE_1:=to_char(ENDING_DATE,'DD-MON-YY');
/*srw.user_exit('FND SRWINIT');*/null;
/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;
/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;
  IF (get_company_name <> TRUE) THEN
     RAISE init_failure;
   END IF;
  IF (get_start_org <> TRUE) THEN
      RAISE init_failure;
  END IF;
IF P_START_ORGANIZATION_ID is not null then
select
 Substr(name, 1, 60)  into
 c_org_name
from
 hr_organization_units
where
 organization_id =  p_start_organization_id;
END IF;
start_organization := c_org_name;
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
FUNCTION get_start_org RETURN BOOLEAN IS
  c_start_organization_id number(15);
BEGIN
select
nvl(p_start_organization_id,start_organization_id)
into
 c_start_organization_id
from
 pa_implementations;
insert into pa_org_reporting_sessions
    (start_organization_id,session_id)
values
    (c_start_organization_id,userenv('SESSIONID'));
RETURN (TRUE);
EXCEPTION
 WHEN OTHERS THEN
  RETURN (FALSE);
END;
function AfterReport return boolean is
begin
BEGIN
   delete from pa_org_reporting_sessions
   where session_id = userenv( 'SESSIONID' );
EXCEPTION
  WHEN OTHERS THEN
      NULL;
END;
/*srw.user_exit('FND SRWEXIT') ;*/null;
return (TRUE);
end;
--Functions to refer Oracle report placeholders--
 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function Start_organization_p return varchar2 is
	Begin
	 return Start_organization;
	 END;
END PA_PAXPCEGS_XMLP_PKG ;


/
