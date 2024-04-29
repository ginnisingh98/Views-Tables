--------------------------------------------------------
--  DDL for Package Body PA_PAXAARUL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXAARUL_XMLP_PKG" AS
/* $Header: PAXAARULB.pls 120.1 2008/01/03 11:10:20 krreddy noship $ */

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
 tmp_rule VARCHAR2(60);
BEGIN

/*srw.user_exit('FND SRWINIT');*/null;


/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;


/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;











  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;
   select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
  c_no_data_found := ndf;

   IF p_rule_id IS NOT NULL THEN
 	SELECT rule_name INTO tmp_rule FROM pa_rules
   	WHERE  rule_id = p_rule_id ;
   END IF;

   c_rule_name := tmp_rule ;

EXCEPTION
  WHEN  NO_DATA_FOUND THEN
   select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
  c_no_data_found := ndf;
   c_dummy_data := 1;
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
 Function C_no_data_found_p return varchar2 is
	Begin
	 return C_no_data_found;
	 END;
 Function C_dummy_data_p return number is
	Begin
	 return C_dummy_data;
	 END;
 Function C_rule_name_p return varchar2 is
	Begin
	 return C_rule_name;
	 END;
END PA_PAXAARUL_XMLP_PKG ;


/
