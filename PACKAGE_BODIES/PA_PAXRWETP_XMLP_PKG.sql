--------------------------------------------------------
--  DDL for Package Body PA_PAXRWETP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWETP_XMLP_PKG" AS
/* $Header: PAXRWETPB.pls 120.0 2008/01/02 11:57:23 krreddy noship $ */

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

  select name
  into l_name
  from gl_sets_of_books
  where set_of_books_id = fnd_profile.value('GL_SET_OF_BKS_ID');


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
END PA_PAXRWETP_XMLP_PKG ;


/
