--------------------------------------------------------
--  DDL for Package Body PO_POXPOVPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXPOVPS_XMLP_PKG" AS
/* $Header: POXPOVPSB.pls 120.2 2008/01/05 15:58:06 dwkrishn noship $ */
USER_EXIT_FAILURE EXCEPTION;
function BeforeReport return boolean is
begin
declare
l_sort     po_lookup_codes.displayed_field%type;
l_yes_no   fnd_lookups.meaning%type;
begin
P_CREATION_DATE_FROM_LP := to_char(P_CREATION_DATE_FROM,'DD-MON-YY');
P_CREATION_DATE_TO_LP	:= to_char(P_CREATION_DATE_TO,'DD-MON-YY');
if P_orderby is not null then
    select displayed_field
    into l_sort
    from po_lookup_codes
    where lookup_code = P_orderby
    and lookup_type = 'SRS ORDER BY';
    P_orderby_displayed := l_sort ;
else
    P_orderby_displayed := '' ;
end if;
IF P_SMALL_BUSINESS is NULL THEN
   P_SMALL_BUSINESS_DISP := '';
ELSE
   SELECT meaning
   INTO l_yes_no
   FROM fnd_lookups
   WHERE lookup_type = 'YES_NO'
   AND lookup_code = P_SMALL_BUSINESS;
   P_SMALL_BUSINESS_DISP := l_yes_no;
END IF;
IF P_WOMEN_OWNED is NULL THEN
   P_WOMEN_OWNED_DISP := '';
ELSE
   SELECT meaning
   INTO l_yes_no
   FROM fnd_lookups
   WHERE lookup_type = 'YES_NO'
   AND lookup_code = P_WOMEN_OWNED;
   P_WOMEN_OWNED_DISP := l_yes_no;
END IF;
IF P_MINORITY_OWNED is NULL THEN
   P_MINORITY_OWNED_DISP := '';
ELSE
   SELECT meaning
   INTO l_yes_no
   FROM fnd_lookups
   WHERE lookup_type = 'YES_NO'
   AND lookup_code = P_MINORITY_OWNED;
   P_MINORITY_OWNED_DISP := l_yes_no;
END IF;
/*SRW.USER_EXIT('FND SRWINIT');*/null;
LP_orderby_displayed:=P_orderby_displayed;
RETURN TRUE;
end;  return (TRUE);
end;
function orderby_clauseFormula return VARCHAR2 is
begin
if P_orderby = 'VENDOR TYPE' then
      return('pov.vendor_type_lookup_code, pov.vendor_name,
              pvs.vendor_site_code,
              decode(psp1.manual_po_num_type, ''NUMERIC'', null, poh.segment1),
              decode(psp1.manual_po_num_type, ''NUMERIC'',
                     to_number(poh.segment1), null)');
else
    return('pov.vendor_name, pov.vendor_type_lookup_code, 			pvs.vendor_site_code,
            decode(psp1.manual_po_num_type, ''NUMERIC'', null, poh.segment1),
            decode(psp1.manual_po_num_type, ''NUMERIC'',
                   to_number(poh.segment1), null)');
end if;
RETURN NULL; end;
function get_percent_wo(PO_CNT_WO in varchar2, Report_PO_Count in number) return number is
         percent_wo  number;
begin
        percent_wo := PO_CNT_WO/Report_PO_Count*100;
        return(percent_wo);
end;
function get_percent_mo(PO_CNT_MO in varchar2, Report_PO_Count in number) return number is
         percent_mo  number;
begin
        percent_mo := PO_CNT_MO/Report_PO_Count*100;
        return(percent_mo);
end;
function get_percent_sb(PO_CNT_SB in varchar2, Report_PO_Count in number) return number is
         percent_sb  number;
begin
        percent_sb := PO_CNT_SB/Report_PO_Count*100;
        return(percent_sb);
end;
function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
--Functions to refer Oracle report placeholders--
 Function C_amount_func_vendor_round_p return number is
	Begin
	 return C_amount_func_vendor_round;
	 END;
 Function C_amount_rep_round_p return number is
	Begin
	 return C_amount_rep_round;
	 END;
 Function C_amount_func_site_round_p return number is
	Begin
	 return C_amount_func_site_round;
	 END;
 Function C_amount_func_po_type_round_p return number is
	Begin
	 return C_amount_func_po_type_round;
	 END;
 Function C_amount_po_round_p return number is
	Begin
	 return C_amount_po_round;
	 END;
 Function C_amount_functional_round_p return number is
	Begin
	 return C_amount_functional_round;
	 END;
 Function C_AMOUNT_WO_ROUND_p return number is
	Begin
	 return C_AMOUNT_WO_ROUND;
	 END;
 Function C_AMOUNT_SB_ROUND_p return number is
	Begin
	 return C_AMOUNT_SB_ROUND;
	 END;
 Function C_AMOUNT_MO_ROUND_p return number is
	Begin
	 return C_AMOUNT_MO_ROUND;
	 END;
END PO_POXPOVPS_XMLP_PKG ;


/
