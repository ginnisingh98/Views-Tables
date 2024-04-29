--------------------------------------------------------
--  DDL for Package Body PA_PAXRWPCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWPCR_XMLP_PKG" AS
/* $Header: PAXRWPCRB.pls 120.0 2008/01/02 12:07:19 krreddy noship $ */

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

function BeforeReport return boolean is
begin


declare
init_error exception;
begin
/*srw.user_exit('FND SRWINIT');*/null;


end;  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT') ;*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_company_name_header_p return varchar2 is
	Begin
	 return C_company_name_header;
	 END;
END PA_PAXRWPCR_XMLP_PKG ;


/
