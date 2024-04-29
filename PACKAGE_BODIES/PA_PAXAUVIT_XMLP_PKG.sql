--------------------------------------------------------
--  DDL for Package Body PA_PAXAUVIT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXAUVIT_XMLP_PKG" AS
/* $Header: PAXAUVITB.pls 120.0 2008/01/02 11:19:19 krreddy noship $ */
FUNCTION  get_cover_page_values   RETURN BOOLEAN IS
BEGIN
RETURN(TRUE);
EXCEPTION
WHEN OTHERS THEN
  RETURN(FALSE);
END;
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
function get_precision(qty_precision in number) return VARCHAR2 is
begin
if qty_precision = 0 then return('999G999G999G990');
elsif qty_precision = 1 then return('999G999G999G990D0');
elsif qty_precision = 3 then return('999G999G999G990D000');
elsif qty_precision = 4 then return('999G999G999G990D0000');
elsif qty_precision = 5 then return('999G999G999G990D00000');
elsif qty_precision = 6 then  return('999G999G999G990D000000');
else return('999G999G999G990D00');
end if;
end;
function BeforeReport return boolean is
begin
Declare
 init_failure exception;
 ndf char(80);
BEGIN
QTY_PRECISION:= get_precision(2);
/*srw.user_exit('FND SRWINIT');*/null;
/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;
/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;
IF (get_company_name <> TRUE) THEN       RAISE init_failure;
END IF;
   select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
    c_no_data_found := ndf;
 null;
IF (P_Report_Type = 'ER') THEN
    c_select_clause:='substrb(pov.vendor_name,1,10)||''/''||substrb(per.full_name,1,15)';
    c_from_clause:='PO_VENDORS pov,PER_PEOPLE_F per';
    c_where_clause:='pov.vendor_id=api.vendor_id and per.person_id=pae.incurred_by_person_id and
    (per.employee_number is not null OR per.npw_number IS NOT NULL) and trunc(sysdate) between per.effective_start_date and per.effective_end_date';
ELSE
    c_select_clause:='substrb(pov.vendor_name,1,25)';
    c_from_clause:='PO_VENDORS pov';
    c_where_clause:='pov.vendor_id=api.vendor_id';
END IF;
P_FROM_GL_DATE1 := TO_CHAR(P_FROM_GL_DATE,'DD-MON-YY');
P_TO_GL_DATE1 := TO_CHAR(P_TO_GL_DATE,'DD-MON-YY');
P_TO_TRANSFER_DATE1 := TO_CHAR(P_TO_TRANSFER_DATE,'DD-MON-YY');
P_FROM_TRANSFER_DATE1 := TO_CHAR(P_FROM_TRANSFER_DATE,'DD-MON-YY');
EXCEPTION
  WHEN  NO_DATA_FOUND THEN
   select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
  c_no_data_found := ndf;
   c_dummy_data := 1;
  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;
    null;
END;
  return (TRUE);
end;
function account_idformula(dr_code_combination_id in number) return char is
begin
  RETURN fnd_flex_ext.get_segs('SQLGL','GL#',p_coa_id,dr_code_combination_id);
end;
function account_flex_idformula(dr_code_combination_id1 in number) return char is
begin
  RETURN fnd_flex_ext.get_segs('SQLGL','GL#',p_coa_id,dr_code_combination_id1);
end;
procedure get_precision (id IN NUMBER) is
begin
/*srw.attr.mask        :=  SRW.FORMATMASK_ATTR;*/null;
if id = 0 then /*srw.attr.formatmask  := '-N,NN,NN,NN,NN,NN0';*/null;
else
if id = 1 then /*srw.attr.formatmask  := '-N,NN,NN,NN,NN,NN0.0';*/null;
else
if id = 3 then /*srw.attr.formatmask  :=  '-NN,NN,NN,NN,NN0.000';*/null;
else
if id = 4 then /*srw.attr.formatmask  :=   '-N,NN,NN,NN,NN0.0000';*/null;
else
if id = 5 then /*srw.attr.formatmask  :=    '-NN,NN,NN,NN0.00000';*/null;
else
if id = 6 then /*srw.attr.formatmask  :=    '-N,NN,NN,NN0.000000';*/null;
else
if id = 7 then /*srw.attr.formatmask  := '-NNNNNNNNNNN0';*/null;
else
if id = 8 then /*srw.attr.formatmask  := '-NNNNNNNNNNN0.0';*/null;
else
if id = 9 then /*srw.attr.formatmask  :=  '-NNNNNNNNNN0.00';*/null;
else
if id = 10 then /*srw.attr.formatmask  := '-NNNNNNNNNN0.000';*/null;
else
if id = 11 then /*srw.attr.formatmask  :=  '-NNNNNNNNN0.0000';*/null;
else
if id = 12 then /*srw.attr.formatmask  :=   '-NNNNNNNN0.00000';*/null;
else
if id = 13 then /*srw.attr.formatmask  :=    '-NNNNNNN0.000000';*/null;
else /*srw.attr.formatmask   :=  '-NN,NNN,NNN,NNN,NNN,NN0.00';*/null;
end if; end if; end if; end if; end if; end if;
end if; end if; end if; end if; end if; end if; end if;
/*srw.set_attr(0,srw.attr);*/null;
end;
function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT') ;*/null;
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
 Function C_WHERE_CC_p return varchar2 is
	Begin
	 return C_WHERE_CC;
	 END;
END PA_PAXAUVIT_XMLP_PKG ;


/
