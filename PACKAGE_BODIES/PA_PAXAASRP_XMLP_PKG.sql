--------------------------------------------------------
--  DDL for Package Body PA_PAXAASRP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXAASRP_XMLP_PKG" AS
/* $Header: PAXAASRPB.pls 120.1 2008/01/03 11:11:36 krreddy noship $ */

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
 hold_function_name  VARCHAR2(40);

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







If p_function_code is not null
  then
    select substr(function_name, 1, 40)
    into   hold_function_name
    from   pa_functions
    where  function_code = p_function_code;
end if;
    c_function_name := hold_function_name;


  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
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
 Function C_function_name_p return varchar2 is
	Begin
	 return C_function_name;
	 END;
END PA_PAXAASRP_XMLP_PKG ;


/
