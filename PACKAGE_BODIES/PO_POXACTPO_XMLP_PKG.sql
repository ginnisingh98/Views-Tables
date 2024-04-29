--------------------------------------------------------
--  DDL for Package Body PO_POXACTPO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXACTPO_XMLP_PKG" AS
/* $Header: POXACTPOB.pls 120.2 2008/01/05 12:07:11 dwkrishn noship $ */

function BeforeReport return boolean is
DATE_FORMAT varchar2(30):='DD'||'-MON-'||'YY';
begin

/*srw.user_exit ('FND SRWINIT');*/null;




declare

l_po_type     po_lookup_codes.displayed_field%type ;
l_sort     po_lookup_codes.displayed_field%type ;


begin

if P_type is not null then

    select displayed_field
    into l_po_type
    from po_lookup_codes
    where lookup_code = P_type
    and lookup_type = 'PO TYPE';

    P_type_displayed := l_po_type ;

else

    P_type_displayed := '' ;

end if;

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
LP_CREATION_DATE_FROM:=to_char(P_CREATION_DATE_FROM,DATE_FORMAT);
LP_CREATION_DATE_TO:=to_char(P_CREATION_DATE_TO,DATE_FORMAT);

RETURN TRUE;
end;

RETURN NULL; end ;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function orderby_clauseFormula return VARCHAR2 is
begin

If P_ORDERBY = 'DATE' then
   return('1');
elsif P_ORDERBY = 'BUYER' then
     return('5');
end if;
--RETURN NULL; end;
RETURN('1'); end;

function round_amount(c_amount in number, c_po_currency_precision in number) return number is
begin
/*srw.reference(c_amount);*/null;

/*srw.reference(c_po_currency_precision);*/null;


return (round(c_amount, c_po_currency_precision));

end;

function base_amount_round(c_base_amount in number, c_precision in number) return number is
begin

/*srw.reference(c_base_amount);*/null;

/*srw.reference(c_precision);*/null;


return (round(c_base_amount, c_precision));

end;

function AfterPForm return boolean is
begin

/*srw.user_exit ('FND SRWINIT');*/null;


declare
l_sysparam_sob_id number;
begin
IF p_ca_set_of_books_id <> -1999
THEN
BEGIN
 select decode(mrc_sob_type_code,'R','R','P'),currency_code
 into p_mrcsobtype,p_base_currency
from gl_sets_of_books
 where set_of_books_id = p_ca_set_of_books_id;
EXCEPTION
 WHEN OTHERS THEN
 p_mrcsobtype := 'P';
END;
ELSE
p_mrcsobtype := 'P';
 END IF;


BEGIN
  select set_of_books_id
  into l_sysparam_sob_id
  from financials_system_parameters;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.set_name('SQLGL', 'MRC_SYSTEM_OPTIONS_NOT_FOUND');
        FND_MESSAGE.set_token('MODULE', 'PO_POXACTPO_XMLP_PKG');
        /*srw.message(2000, FND_MESSAGE.get);*/null;

        raise;
    WHEN OTHERS THEN
        FND_MESSAGE.set_name('SQLGL', 'MRC_TABLE_ERROR');
        FND_MESSAGE.set_token('MODULE', 'PO_POXACTPO_XMLP_PKG');
        FND_MESSAGE.set_token('TABLE', 'FINANCIALS_SYSTEM_PARAMETERS');
        /*srw.message('1000',fnd_message.get);*/null;

        raise;
END;

  lp_fin_system_parameters := 'financials_system_parameters';
  lp_fin_system_parameters_all := 'financials_system_params_all';
  lp_po_headers := 'po_headers';
  lp_po_headers_all := 'po_headers_all';
  lp_po_distributions := 'po_distributions';
  lp_po_distributions_all := 'po_distributions_all';
  lp_rcv_shipment_headers := 'rcv_shipment_headers';
  lp_rcv_transactions := 'rcv_transactions';
  lp_rcv_sub_ledger_details := 'rcv_sub_ledger_details';
  lp_rcv_receiving_sub_ledger := 'rcv_receiving_sub_ledger';

END;





if P_creation_date_from is Null and P_creation_date_to is Null then

	P_poh_Creation_Date_clause := ' AND 1 = 1 ';

	P_por_Creation_Date_clause := ' AND 1 = 1 ';

elsif P_Creation_date_from is Null then

	P_poh_Creation_Date_clause := ' AND poh.creation_date <= '''|| (P_creation_date_to + 1) ||'''';

	P_por_Creation_Date_clause := ' AND por.creation_date <= '''|| (P_creation_date_to + 1) ||'''';

elsif P_Creation_date_to is Null then

	P_poh_Creation_Date_clause := ' AND poh.creation_date >= '''||P_creation_date_from || '''';

	P_por_Creation_Date_clause := ' AND por.creation_date >= '''||P_creation_date_from || '''';

else

	P_poh_Creation_Date_clause := ' AND poh.creation_date BETWEEN '''||P_creation_date_from || ''' And '''|| (P_creation_date_to + 1) ||'''';

	P_por_Creation_Date_clause := ' AND por.creation_date BETWEEN '''||P_creation_date_from || ''' And '''|| (P_creation_date_to + 1) ||'''';


End if;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXACTPO_XMLP_PKG ;


/
