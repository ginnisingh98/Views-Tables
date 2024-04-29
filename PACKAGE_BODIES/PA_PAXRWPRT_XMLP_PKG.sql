--------------------------------------------------------
--  DDL for Package Body PA_PAXRWPRT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWPRT_XMLP_PKG" AS
/* $Header: PAXRWPRTB.pls 120.0 2008/01/02 12:12:14 krreddy noship $ */

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

function BeforeReport return boolean is
begin


declare
init_error exception;
begin
/*srw.user_exit('FND SRWINIT');*/null;

if ( get_company_name <> TRUE ) then
  raise init_error;
end if;
end;  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT') ;*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_Company_name_header_p return varchar2 is
	Begin
	 return C_Company_name_header;
	 END;
END PA_PAXRWPRT_XMLP_PKG ;


/
