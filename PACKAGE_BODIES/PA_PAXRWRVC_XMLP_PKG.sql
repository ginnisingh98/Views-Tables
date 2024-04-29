--------------------------------------------------------
--  DDL for Package Body PA_PAXRWRVC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWRVC_XMLP_PKG" AS
/* $Header: PAXRWRVCB.pls 120.0 2008/01/02 12:14:54 krreddy noship $ */

FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                  gl_sets_of_books.name%TYPE;
BEGIN





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
rev_category_name pa_lookups.meaning%TYPE;
begin
/*srw.user_exit('FND SRWINIT');*/null;


if p_revenue_category is not NULL then
    select meaning into rev_category_name from
            pa_lookups
    where
       lookup_code = p_revenue_category;
end if;
C_Revenue_Category:= rev_category_name;





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
 Function C_Revenue_Category_p return varchar2 is
	Begin
	 return C_Revenue_Category;
	 END;
END PA_PAXRWRVC_XMLP_PKG ;


/
