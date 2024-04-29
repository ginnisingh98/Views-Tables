--------------------------------------------------------
--  DDL for Package Body PA_PAXRWNLR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWNLR_XMLP_PKG" AS
/* $Header: PAXRWNLRB.pls 120.0 2008/01/02 12:00:45 krreddy noship $ */

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
org_name hr_organization_units.name%TYPE;
begin
/*srw.user_exit('FND SRWINIT');*/null;


if p_organization_id is not NULL then

    select substr(name, 1, 60) into org_name from
            hr_organization_units
    where organization_id = p_organization_id;
end if;
C_org_name := org_name;
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
 Function C_Org_Name_p return varchar2 is
	Begin
	 return C_Org_Name;
	 END;
END PA_PAXRWNLR_XMLP_PKG ;


/
