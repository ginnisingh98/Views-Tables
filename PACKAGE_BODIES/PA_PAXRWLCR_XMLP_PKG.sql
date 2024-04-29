--------------------------------------------------------
--  DDL for Package Body PA_PAXRWLCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWLCR_XMLP_PKG" AS
/* $Header: PAXRWLCRB.pls 120.0 2008/01/02 11:59:24 krreddy noship $ */

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
Sort_By_Name pa_lookups.meaning%TYPE;
begin
/*srw.user_exit('FND SRWINIT');*/null;

if SORT_BY is not NULL then
   select meaning into Sort_By_Name from pa_lookups
    where lookup_code = SORT_BY
      and lookup_type = 'LABOR RATE SORT BY';
end if;
C_Sort_By_Name := Sort_By_Name;
if ( get_company_name <> TRUE ) then
  raise init_error;
end if;
end;  return (TRUE);
end;

function AfterPForm return boolean is
begin

  return (TRUE);
end;

function BetweenPage return boolean is
begin

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function CF_Currency_CodeFormula return Char is
begin
  return(pa_multi_currency.get_acct_currency_code);
end;

--Functions to refer Oracle report placeholders--

 Function C_Company_Name_Header_p return varchar2 is
	Begin
	 return C_Company_Name_Header;
	 END;
 Function C_Sort_by_Name_p return varchar2 is
	Begin
	 return C_Sort_by_Name;
	 END;
END PA_PAXRWLCR_XMLP_PKG ;


/
