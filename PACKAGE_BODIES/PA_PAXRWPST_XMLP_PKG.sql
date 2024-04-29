--------------------------------------------------------
--  DDL for Package Body PA_PAXRWPST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWPST_XMLP_PKG" AS
/* $Header: PAXRWPSTB.pls 120.0 2008/01/02 12:12:52 krreddy noship $ */

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
closing_status pa_lookups.meaning%TYPE;
begin

/*srw.user_exit('FND SRWINIT');*/null;


if p_status_code is NOT NULL then
    select meaning into closing_status from
           pa_lookups
    where
       lookup_code = p_status_code
    and lookup_type = 'CLOSING STATUS';
end if;
C_closing_status := closing_status;
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
 Function C_Closing_Status_p return varchar2 is
	Begin
	 return C_Closing_Status;
	 END;
END PA_PAXRWPST_XMLP_PKG ;


/
