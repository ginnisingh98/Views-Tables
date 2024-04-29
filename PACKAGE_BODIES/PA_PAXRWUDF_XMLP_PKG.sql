--------------------------------------------------------
--  DDL for Package Body PA_PAXRWUDF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWUDF_XMLP_PKG" AS
/* $Header: PAXRWUDFB.pls 120.2 2008/06/24 11:00:00 krreddy noship $ */

FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                  gl_sets_of_books.name%TYPE;
BEGIN
 /* SELECT  gl.name
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

 Function C_Company_Name_Header_p return varchar2 is
	Begin
	 return C_Company_Name_Header;
	 END;
END PA_PAXRWUDF_XMLP_PKG ;


/
