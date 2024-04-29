--------------------------------------------------------
--  DDL for Package Body PA_PAXPEJOB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXPEJOB_XMLP_PKG" AS
/* $Header: PAXPEJOBB.pls 120.0 2008/01/02 11:48:14 krreddy noship $ */
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
Sort_By_Name pa_lookups.meaning%TYPE;
begin
/*srw.user_exit('FND SRWINIT');*/null;
if P_SORT_BY is not null then
   select meaning into Sort_By_Name from pa_lookups
     where lookup_code = P_SORT_BY
       and lookup_type = 'JOB SORT BY';
end if;
C_Sort_By_Name := Sort_By_Name;
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
 Function C_Sort_By_Name_p return varchar2 is
	Begin
	 return C_Sort_By_Name;
	 END;
END PA_PAXPEJOB_XMLP_PKG ;


/
