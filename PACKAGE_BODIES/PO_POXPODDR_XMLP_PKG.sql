--------------------------------------------------------
--  DDL for Package Body PO_POXPODDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXPODDR_XMLP_PKG" AS
/* $Header: POXPODDRB.pls 120.1.12010000.2 2014/07/16 02:22:32 shipwu ship $ */

USER_EXIT_FAILURE EXCEPTION;

function AfterReport return boolean is
begin


/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function BeforeReport return boolean is
begin

DECLARE
   l_sort     po_lookup_codes.displayed_field%type;
   l_yes_no   fnd_lookups.meaning%type;

BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  P_CREATION_DATE_FROM1:=to_char(P_CREATION_DATE_FROM,'DD-MON-YY');
    P_CREATION_DATE_TO1:=to_char(P_CREATION_DATE_TO,'DD-MON-YY');

  IF P_ORDERBY is NOT NULL THEN

     SELECT displayed_field
     INTO l_sort
     FROM po_lookup_codes
     WHERE lookup_code = P_ORDERBY
     AND lookup_type = 'SRS ORDER BY';

     P_ORDERBY_DISP := l_sort;

  ELSE

     P_ORDERBY_DISP := '';

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


  RETURN (TRUE);

END;
  return (TRUE);
end;

function select_failed_f return character is
begin
    if P_failed_funds = 'Y' then
       return(',pol.po_header_id, gl1.description Description1');
    else
       return(',pol.po_header_id,''''');
    end if;
RETURN NULL; end;

function where_failed_f return character is
begin
     if P_failed_funds = 'Y' then
        return('and gcc.code_combination_id = pod.code_combination_id and pod.failed_funds_lookup_code = gl1.lookup_code and pod.failed_funds_lookup_code like ''F%''and gl1.lookup_type =''FUNDS_CHECK_RESULT_CODE''');
     else
        return('and gcc.code_combination_id = pod.code_combination_id');
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

function orderby_clauseFormula return VARCHAR2 is
begin

if    upper(P_orderby) = 'PO NUMBER' then
      return('decode(psp1.manual_po_num_type,''NUMERIC'',
                      decode(rtrim(poh.segment1,''0123456789''),null,
                    to_number(poh.segment1),-1),null)

	      , decode(psp1.manual_po_num_type,''NUMERIC'',
			null,poh.segment1)');
elsif upper(P_orderby) = 'VENDOR' then
      return('pov.vendor_name');
end if;

RETURN 'decode(psp1.manual_po_num_type,''NUMERIC'',null,poh.segment1), decode(psp1.manual_po_num_type,''NUMERIC'',decode(rtrim(poh.segment1, ''0123456789''),null,to_number(poh.segment1),-1),null)';
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

function get_dist_func_amount(shipment_type in varchar2, dist_quantity_ordered in number, c_dist_rls_qty in number, unit_price in number, rate in number, order_type_lookup_code in varchar2, dist_amount_ordered in number) return number is
begin



  if (shipment_type = 'PLANNED') then

    return(((dist_quantity_ordered - c_dist_rls_qty)
	     * unit_price) * nvl(rate,1));

  else


    IF (order_type_lookup_code IN ('RATE', 'FIXED PRICE')) THEN
      RETURN (dist_amount_ordered * NVL(rate, 1));
    ELSE
      return((dist_quantity_ordered * unit_price) * nvl(rate,1));
    END IF;


  end if;

RETURN NULL; end get_dist_func_amount;

function get_dist_cur_amount(shipment_type in varchar2, dist_quantity_ordered in number, c_dist_rls_qty in number, unit_price in number, order_type_lookup_code in varchar2, dist_amount_ordered in number) return number is
begin



  if (shipment_type = 'PLANNED') then

    return(((dist_quantity_ordered - c_dist_rls_qty)
	     * unit_price));

  else


    IF (order_type_lookup_code IN ('RATE', 'FIXED PRICE')) THEN
        RETURN dist_amount_ordered;
    ELSE
        return((dist_quantity_ordered * unit_price));
    END IF;

      end if;

RETURN NULL; end get_dist_cur_amount;

function get_ship_quantity(shipment_type in varchar2, ship_qty_ordered in number, c_ship_rls_qty in number) return number is
begin



  if (shipment_type = 'PLANNED') then
    return (ship_qty_ordered - c_ship_rls_qty);
  else
    return (ship_qty_ordered);
  end if;


RETURN NULL; end get_ship_quantity;

function AfterPForm return boolean is
 P_po_num_type po_system_parameters.manual_po_num_type%TYPE;
begin

/*srw.user_exit ('FND SRWINIT');*/null;

declare
l_sysparam_sob_id number;
begin

IF p_ca_set_of_books_id <> -1999
THEN
  BEGIN
   select decode(mrc_sob_type_code,'R','R','P')
   into p_mrcsobtype
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
        FND_MESSAGE.set_token('MODULE', 'PO_POXPODDR_XMLP_PKG');
        /*srw.message(2000, FND_MESSAGE.get);*/null;

        raise;
    WHEN OTHERS THEN
        FND_MESSAGE.set_name('SQLGL', 'MRC_TABLE_ERROR');
        FND_MESSAGE.set_token('MODULE', 'PO_POXPODDR_XMLP_PKG');
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



 begin

    SELECT  psp.manual_po_num_type
    into    P_po_num_type
    FROM    po_system_parameters psp;

 exception
    when no_data_found then
     P_po_num_type := 'ALPHANUMERIC';
 end;

 if P_po_num_from = P_po_num_to then
  where_performance := ' AND poh.segment1 = :P_po_num_from ';

 else

     if (P_po_num_type = 'NUMERIC') then
        where_performance := ' AND  decode(rtrim(poh.segment1,''0123456789''),NULL,to_number(poh.segment1),-1) BETWEEN
                                     decode(rtrim(nvl(:P_po_num_from,poh.segment1),''0123456789''),NULL,to_number(nvl(:P_po_num_from,poh.segment1)),-1)  AND
                                     decode(rtrim(nvl(:P_po_num_to,poh.segment1),''0123456789''),NULL,to_number(nvl(:P_po_num_to,poh.segment1)),-1) ';
     elsif (P_po_num_type = 'ALPHANUMERIC') and
           (P_po_num_from is not null)    and
           (P_po_num_to   is not null)    then
           where_performance :=   ' AND   poh.segment1 >= :P_po_num_from AND poh.segment1 <= :P_po_num_to ';
     elsif (P_po_num_type = 'ALPHANUMERIC') and
           (P_po_num_from is not null)    and
           (P_po_num_to   is  null)      then
               where_performance :=   ' AND   poh.segment1 >= :P_po_num_from ';
     elsif (P_po_num_type = 'ALPHANUMERIC') and
           (P_po_num_from is  null)       and
           (P_po_num_to   is  not null)  then
               where_performance :=  ' AND    poh.segment1 <= :P_po_num_to ' ;
     elsif (P_po_num_type = 'ALPHANUMERIC') and
           (P_po_num_from is  null)       and
           (P_po_num_to   is  null)      then
              where_performance := ' AND 1=1 ';
     end if;
 end if;


--Bug 18323614 Start: define a new parameter "where_vendor_performance" to
--replace 'nvl' condition in the where clause to improve performance.
if (P_vendor_from is not null) and (P_vendor_to is not null) then
    where_vendor_performance := ' AND pov.vendor_name >= :P_vendor_from AND pov.vendor_name <= :P_vendor_to ';
elsif (P_vendor_from is not null) and (P_vendor_to is null) then
    where_vendor_performance := ' AND pov.vendor_name >= :P_vendor_from ';
elsif (P_vendor_from is null) and (P_vendor_to is not null) then
    where_vendor_performance := ' AND pov.vendor_name <= :P_vendor_to ';
elsif (P_vendor_from is null) and (P_vendor_to is null) then
    where_vendor_performance := ' AND 1=1 ';
end if;
--Bug 18323614 End



  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_amount_func_sub_round_p return number is
	Begin
	 return C_amount_func_sub_round;
	 END;
 Function C_amount_cur_round_p(C_DIST_AMT_CUR in number,PO_CURRENCY_PRECISION in  number) return number is
	Begin
	 C_amount_cur_round := round(C_DIST_AMT_CUR,PO_CURRENCY_PRECISION);
	 return C_amount_cur_round;
	 END;
 Function C_amount_fun_round_p(C_DIST_AMT_FUNC in number,PO_CURRENCY_PRECISION in  number) return number is
	Begin
	 C_amount_fun_round := round(C_DIST_AMT_FUNC,PO_CURRENCY_PRECISION);
	 return C_amount_fun_round;
	 END;
 Function C_amount_func_tot_round_p return number is
	Begin
	 return C_amount_func_tot_round;
	 END;
END PO_POXPODDR_XMLP_PKG ;


/
