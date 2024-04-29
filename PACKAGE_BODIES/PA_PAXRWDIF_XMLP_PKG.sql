--------------------------------------------------------
--  DDL for Package Body PA_PAXRWDIF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWDIF_XMLP_PKG" AS
/* $Header: PAXRWDIFB.pls 120.0 2008/01/02 11:55:19 krreddy noship $ */
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
inv_format_name pa_invoice_formats.name%TYPE;
inv_group_name pa_invoice_groups.name%TYPE;
begin
/*srw.user_exit('FND SRWINIT');*/null;
if p_format is not NULL then
  select name into inv_format_name
         from pa_invoice_formats
  where
    invoice_format_id = p_format;
end if;
if p_group is not NULL then
   select name into inv_group_name
          from pa_invoice_groups
   where
     invoice_group_id = p_group;
end if;
C_Format_Name := inv_format_name;
C_Grouping_Name  := inv_group_name;
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
 Function C_Format_Name_p return varchar2 is
	Begin
	 return C_Format_Name;
	 END;
 Function C_Grouping_Name_p return varchar2 is
	Begin
	 return C_Grouping_Name;
	 END;
END PA_PAXRWDIF_XMLP_PKG ;


/
