--------------------------------------------------------
--  DDL for Package Body PO_POXRQDDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRQDDR_XMLP_PKG" AS
/* $Header: POXRQDDRB.pls 120.1 2007/12/25 11:48:42 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

DECLARE
   l_yes_no      fnd_lookups.meaning%type;
BEGIN

  /*SRW.USER_EXIT('FND SRWINIT');*/null;
QTY_PRECISION:=PO_common_xmlp_pkg.GET_PRECISION(P_QTY_PRECISION);

  IF (get_p_chart_of_accounts_id <> TRUE) THEN
     /*SRW.MESSAGE('1','P_CHART_OF_ACCOUNTS_ID INIT failed.');*/null;

  END IF;

  IF P_FAILED_FUNDS is NULL THEN
     P_FAILED_FUNDS := 'N';
  END IF;

     SELECT meaning
     INTO l_yes_no
     FROM fnd_lookups
     WHERE lookup_type = 'YES_NO'
     AND lookup_code = P_FAILED_FUNDS;

     P_FAILED_FUNDS_DISP := l_yes_no;


 null;


 null;
P_failed_funds_lp := P_FAILED_FUNDS ;
  RETURN TRUE;
END;  return (TRUE);
end;

function AfterReport return boolean is
begin


/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

procedure get_precision is
begin
/*srw.attr.mask        :=  SRW.FORMATMASK_ATTR;*/null;

if P_qty_precision = 0 then /*srw.attr.formatmask  := '-NNN,NNN,NNN,NN0';*/null;

else
if P_qty_precision = 1 then /*srw.attr.formatmask  := '-NNN,NNN,NNN,NN0.0';*/null;

else
if P_qty_precision = 3 then /*srw.attr.formatmask  :=  '-NN,NNN,NNN,NN0.000';*/null;

else
if P_qty_precision = 4 then /*srw.attr.formatmask  :=   '-N,NNN,NNN,NN0.0000';*/null;

else
if P_qty_precision = 5 then /*srw.attr.formatmask  :=     '-NNN,NNN,NN0.00000';*/null;

else
if P_qty_precision = 6 then /*srw.attr.formatmask  :=      '-NN,NNN,NN0.000000';*/null;

else /*srw.attr.formatmask  :=  '-NNN,NNN,NNN,NN0.00';*/null;

end if; end if; end if; end if; end if; end if;
/*srw.set_attr(0,srw.attr);*/null;

end;

function select_failed_f return character is
begin
     if P_failed_funds = 'Y' then
         return(',prl.requisition_header_id, gl1.description Description1');     else
         return(',prl.requisition_header_id,''''');
     end if;
RETURN NULL; end;

function from_failed_f return character is
begin
     if P_failed_funds = 'Y' then
        return(',gl_code_combinations gcc, gl_lookups gl1');
     else
        return(',gl_code_combinations gcc');
     end if;
RETURN NULL; end;

function where_failed_f return character is
begin
     if P_failed_funds = 'Y' then
        return('and gcc.code_combination_id = prd.code_combination_id and prd.failed_funds_lookup_code = gl1.lookup_code and prd.failed_funds_lookup_code like ''F%'' and prd.encumbered_flag <>''Y'' and gl1.lookup_type=''FUNDS_CHECK_RESULT_CODE''');
     else
        return('and gcc.code_combination_id = prd.code_combination_id');
     end if;
RETURN NULL; end;

function get_p_chart_of_accounts_id return boolean is

l_p_chart_of_accounts_id  number;

begin
   select gsb.chart_of_accounts_id
   into l_p_chart_of_accounts_id
   from gl_sets_of_books gsb,
        financials_system_parameters fsp
   where gsb.set_of_books_id = fsp.set_of_books_id;

   P_chart_of_accounts_id := l_p_chart_of_accounts_id;

   return(true);

RETURN NULL; exception
   when others then return(false);
end;

function C_WHERE_REQ_NUMFormula return Char is
   numbering_type varchar2(40);
begin

  select psp.manual_req_num_type
                into numbering_type
                from po_system_parameters psp;

if (numbering_type = 'NUMERIC') then
RETURN (' AND decode(rtrim(prh.segment1,''0123456789''),NULL,to_number(prh.segment1),-1)
          BETWEEN decode(rtrim(nvl('||''''||p_req_num_from||''''||',prh.segment1),''0123456789''),NULL,to_number(nvl('||''''||p_req_num_from||''''||',prh.segment1)),-1)
              AND decode(rtrim(nvl('||''''||p_req_num_to||''''||',prh.segment1),''0123456789''),NULL,to_number(nvl('||''''||p_req_num_to||''''||',prh.segment1)),-1)' );
else
 return(' AND prh.segment1 BETWEEN
         nvl('||''''||P_req_num_from||''''||',prh.segment1)
         AND
         nvl('||''''||P_req_num_to||''''||',prh.segment1)');
end if;
RETURN NULL;
end;

--Functions to refer Oracle report placeholders--

END PO_POXRQDDR_XMLP_PKG ;


/
