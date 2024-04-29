--------------------------------------------------------
--  DDL for Package Body PA_PAXMGSLD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXMGSLD_XMLP_PKG" AS
/* $Header: PAXMGSLDB.pls 120.1 2008/01/03 11:15:05 krreddy noship $ */
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
 ndf VARCHAR2(80);
BEGIN

/*srw.user_exit('FND SRWINIT');*/null;
CP_from_date_1 := to_char(P_FROM_GL_DATE,'DD-MON-YY');
CP_to_date_1 := to_char(P_TO_GL_DATE,'DD-MON-YY');
/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;
/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;
  IF (get_company_name <> TRUE) THEN
     RAISE init_failure;
  END IF;
   select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
  c_no_data_found := ndf;
 null;
/*srw.reference(P_COA_ID);*/null;
 null;
 null;
  IF p_sort_type = 'P' AND p_project_id IS NOT NULL THEN
    select distinct project_number into p_from_project
     from pa_proj_cost_subledger_v
     where project_id = p_project_id ;
  END IF;
EXCEPTION
  WHEN  NO_DATA_FOUND THEN
   select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
  c_no_data_found := ndf;
   c_dummy_data := 1;
  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;
END;  return (TRUE);
end;
FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                  gl_sets_of_books.name%TYPE;
BEGIN
  SELECT  gl.name
  INTO    l_name
  FROM    gl_sets_of_books gl
  WHERE   gl.set_of_books_id = p_ca_set_of_books_id;
  c_company_name_header     := l_name;
  RETURN (TRUE);
EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);
END;
function cf_account_idformula(code_combination_id in number) return varchar2 is
begin
  RETURN fnd_flex_ext.get_segs('SQLGL', 'GL#', p_coa_id, code_combination_id);
end;
function cf_account_id1formula(code_combination_id1 in number) return varchar2 is
begin
  RETURN fnd_flex_ext.get_segs('SQLGL', 'GL#', p_coa_id, code_combination_id1);
end;
function CP_from_dateFormula return date is
begin
     RETURN p_from_gl_date ;
end;
function CP_to_dateFormula return Date is
begin
     RETURN p_to_gl_date ;
end;
function CF_CURR_CODEFormula return VARCHAR2 is
l_curr_code    varchar2(30);
begin
	select currency_code
	into l_curr_code
	from gl_sets_of_books
	where set_of_books_id = p_ca_set_of_books_id;
return (l_curr_code);
end;
function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;
function AfterPForm return boolean is
begin
return (TRUE);
end;
--Functions to refer Oracle report placeholders--
 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_no_data_found_p return varchar2 is
	Begin
	 return C_no_data_found;
	 END;
 Function C_dummy_data_p return number is
	Begin
	 return C_dummy_data;
	 END;
 Function C_where_p return varchar2 is
	Begin
	 return C_where;
	 END;
 Function C_FLEXDATA2_p return varchar2 is
	Begin
	 return C_FLEXDATA2;
	 END;
 Function C_FLEXDATA1_p return varchar2 is
	Begin
	 return C_FLEXDATA1;
	 END;
END PA_PAXMGSLD_XMLP_PKG ;


/
