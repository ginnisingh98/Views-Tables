--------------------------------------------------------
--  DDL for Package Body PA_PAXAASVL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXAASVL_XMLP_PKG" AS
/* $Header: PAXAASVLB.pls 120.0 2008/01/02 11:09:28 krreddy noship $ */

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
 hold_lookup_set_name  VARCHAR2(50);
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







If segment_lookup_set_id is not null
  then
    select segment_value_lookup_set_name
    into   hold_lookup_set_name
    from pa_segment_value_lookup_sets
    where segment_value_lookup_set_id =
          segment_lookup_set_id;
    c_lookup_set := hold_lookup_set_name;
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
  /*SELECT  gl.name
  INTO    l_name
  FROM    gl_sets_of_books gl,pa_implementations pi
  WHERE   gl.set_of_books_id = pi.set_of_books_id;*/
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

BEGIN
 /*srw.user_exit('FND SRWEXIT');*/null;

END;  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_lookup_set_p return varchar2 is
	Begin
	 return C_lookup_set;
	 END;
END PA_PAXAASVL_XMLP_PKG ;


/
