--------------------------------------------------------
--  DDL for Package Body PO_RCVTXRTR_NEW_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RCVTXRTR_NEW_XMLP_PKG" AS
/* $Header: RCVTXRTRB.pls 120.1.12010000.3 2014/01/03 07:24:46 liayang ship $ */

function BeforeReport return boolean is

l_org     org_organization_definitions.organization_name%type;
l_INDUSTRY varchar2(100);
l_ORACLE_SCHEMA varchar2(100);
l_fnd_install boolean;
begin
begin
if P_org_id is not null then

    select organization_name
    into l_org
    from org_organization_definitions
    where organization_id = P_org_id ;

    P_org_displayed := l_org;

else

    P_org_displayed := '' ;

end if;

end;
BEGIN
  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;

 null;

/*srw.user_exit('FND INSTALLATION OUTPUT_TYPE="STATUS"
                                 OUTPUT_FIELD=":P_INV_STATUS"
                                         APPS="INV"');*/null;

l_fnd_install := fnd_installation.GET_APP_INFO('INV',P_INV_STATUS,l_INDUSTRY,l_ORACLE_SCHEMA);


if (P_INV_STATUS = 'I') then

 null;
else
  P_FLEX_LOCATOR := 'TO_CHAR(NULL)';
end if;


 null;

 null;

 null;
   /*srw.message( 1003, ' The from ship No is ' || P_ship_num_from );*/null;

   /*srw.message( 1004, ' The To ship Num is '|| P_ship_num_to);*/null;


  RETURN TRUE;
END;
  return (TRUE);
end;

function get_p_struct_num return boolean is

l_p_struct_num number;

begin
        select structure_id
        into l_p_struct_num
        from mtl_default_sets_view
        where functional_area_id = 2 ;

        P_STRUCT_NUM1 := l_p_struct_num ;

        return(TRUE) ;

        RETURN NULL; exception
        when others then return(FALSE) ;
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

function G_src_and_typeGroupFilter return boolean is
begin


  return (TRUE);
end;

function AfterPForm return boolean is
begin

declare
req_numbering_type 	varchar2(240);
receipt_numbering_type	varchar2(240);
po_numbering_type	varchar2(240);

apostrophe_pos_from	number;
before_apos_from	varchar2(240);
after_apos_from		varchar2(240);
vend_length_from	varchar2(240);

apostrophe_pos_to	number;
before_apos_to		varchar2(240);
after_apos_to		varchar2(240);
vend_length_to		varchar2(240);

check_apos_from		number;
check_apos_to		number;


apostrophe_cust_from	number;
before_cust_from	varchar2(240);
after_cust_from		varchar2(240);
cust_length_from	varchar2(240);

apostrophe_cust_to	number;
before_cust_to		varchar2(240);
after_cust_to		varchar2(240);
cust_length_to		varchar2(240);

check_cust_from		number;
check_cust_to		number;

Begin
    /*SRW.USER_EXIT('FND SRWINIT');*/null;



	SELECT 	manual_po_num_type
	, 	manual_req_num_type
	,	manual_receipt_num_type
	INTO	po_numbering_type
	,	req_numbering_type
	,	receipt_numbering_type
	FROM 	po_system_parameters;



    Begin

	    SELECT 	rcvp.manual_receipt_num_type
	    INTO      	receipt_numbering_type
	    FROM	rcv_parameters rcvp
	    WHERE 	rcvp.organization_id=P_org_id;

	    exception
		When no_data_found Then
			null;
    End;




if (P_org_id is not null) then
   P_where_org_id := 'hru.organization_id =' || to_char(P_org_id);
else
   P_where_org_id := '1=1';
end if;

if (P_trx_type is not null) then
   P_where_trx_type := 'rct.transaction_type = :P_trx_type';
else
   P_where_trx_type := '1=1';
end if;


if ((P_receipt_num_from is not null) and (receipt_numbering_type = 'ALPHANUMERIC')) then
   P_where_receipt_num_from :=  'rsh.receipt_num >= :P_receipt_num_from';
elsif
   ((P_receipt_num_from is not null) and (receipt_numbering_type = 'NUMERIC')) then
   --P_where_receipt_num_from := 'decode(ltrim(rsh.receipt_num,''-0123456789''),NULL,to_number(rsh.receipt_num),-1) >= :P_receipt_num_from ';
   P_where_receipt_num_from := 'decode(decode(instr(rsh.receipt_num,''-'',2),0,ltrim(rsh.receipt_num,''-0123456789''),rsh.receipt_num),NULL,to_number(rsh.receipt_num),-1) >= :P_receipt_num_from '; --Bug17856007
else
   P_where_receipt_num_from := '1=1';
end if;

if ((P_receipt_num_to is not null) and (receipt_numbering_type = 'ALPHANUMERIC')) then
   P_where_receipt_num_to :=  'rsh.receipt_num <= :P_receipt_num_to ';
elsif
   ((P_receipt_num_to is not null) and (receipt_numbering_type = 'NUMERIC')) then
   --P_where_receipt_num_to :=  'decode(ltrim(rsh.receipt_num,''-0123456789''),NULL,to_number(rsh.receipt_num),:P_receipt_num_to +1) <= :P_receipt_num_to';
   P_where_receipt_num_to :=  'decode(decode(instr(rsh.receipt_num,''-'',2),0,ltrim(rsh.receipt_num,''-0123456789''),rsh.receipt_num),NULL,to_number(rsh.receipt_num),:P_receipt_num_to +1) <= :P_receipt_num_to';--Bug17856007
else
   P_where_receipt_num_to := '1=1';
end if;

if ((    P_receipt_num_from is not null)
     and (P_receipt_num_from = P_receipt_num_to)
     and (receipt_numbering_type = 'ALPHANUMERIC')) then

     P_where_receipt_num_from := 'rsh.receipt_num = :P_receipt_num_from ';
     P_where_receipt_num_to   := '1=1';

elsif ((    P_receipt_num_from is not null)
	and (P_receipt_num_from = P_receipt_num_to)
	and (receipt_numbering_type = 'NUMERIC')) then

     --P_where_receipt_num_from := 'decode(ltrim(rsh.receipt_num,''-0123456789''),NULL,to_number(rsh.receipt_num),-1) = :P_receipt_num_from ';
	 P_where_receipt_num_from := 'decode(decode(instr(rsh.receipt_num,''-'',2),0,ltrim(rsh.receipt_num,''-0123456789''),rsh.receipt_num),NULL,to_number(rsh.receipt_num),-1) = :P_receipt_num_from '; --Bug17856007
     P_where_receipt_num_to   := '1=1';
end if;


if ((P_po_num_from is not null) and (po_numbering_type = 'ALPHANUMERIC')) then
   P_where_po_num_from :=  'poh.segment1 >= :P_po_num_from ';
elsif
   ((P_po_num_from is not null) and (po_numbering_type = 'NUMERIC')) then
   P_where_po_num_from := 'decode(rtrim(poh.segment1,''0123456789''),NULL,to_number(poh.segment1),null) >= :P_po_num_from ';
else
   P_where_po_num_from := '1=1';
end if;

if ((P_po_num_to is not null) and (po_numbering_type = 'ALPHANUMERIC')) then
   P_where_po_num_to :=  'poh.segment1 <= :P_po_num_to ';
elsif
   ((P_po_num_to is not null) and (po_numbering_type = 'NUMERIC')) then
   P_where_po_num_to :=  'decode(rtrim(poh.segment1,''0123456789''),NULL,to_number(poh.segment1),null)
				 <= :P_po_num_to ';
else
   P_where_po_num_to := '1=1';
end if;

if ((P_po_num_to is not null)
    and (P_po_num_from = P_po_num_to)
    and (po_numbering_type = 'ALPHANUMERIC')) then
     P_where_po_num_from := 'poh.segment1 = :P_po_num_from ';
     P_where_po_num_to   := '1=1';
elsif
   ((P_po_num_to is not null)
    and (P_po_num_from = P_po_num_to)
    and (po_numbering_type = 'NUMERIC')) then
    P_where_po_num_from := 'decode(rtrim(poh.segment1,''0123456789''),NULL,to_number(poh.segment1),null)
				= :P_po_num_from';
     P_where_po_num_to   := '1=1';
end if;



if (P_buyer is not null) then
   P_where_buyer := 'p2.full_name = :P_buyer ';
else
   P_where_buyer := '1=1';
end if;




check_apos_from := instr(p_vendor_from,'''',1);
check_apos_to := instr(p_vendor_to,'''',1);



if check_apos_from > 0 then

	vend_length_from := NVL(length(p_vendor_from), 0);
	apostrophe_pos_from := instr(p_vendor_from,'''',1);
	before_apos_from := substr(p_vendor_from,1,apostrophe_pos_from - 1);
	after_apos_from := substr(p_vendor_from,apostrophe_pos_from + 1,vend_length_from);

	P_where_vendor_from := 'pov.vendor_name >= 			'||''''||before_apos_from||''''||''''||after_apos_from||'''';

else
	if (P_vendor_from is  null) then
   		P_where_vendor_from := '1=1';
	else
		P_where_vendor_from := 'pov.vendor_name >= :p_vendor_from ';
	end if;
end if;

if check_apos_to > 0 then

	vend_length_to := NVL(length(p_vendor_to), 0);
	apostrophe_pos_to := instr(p_vendor_to,'''',1);
	before_apos_to := substr(p_vendor_to,1,apostrophe_pos_to - 1);
	after_apos_to := substr(p_vendor_to,apostrophe_pos_to + 1,vend_length_to);

	P_where_vendor_to := 'pov.vendor_name <= '	||''''||before_apos_to||''''||''''||after_apos_to||'''';

else
	if (P_vendor_to is  null) then
   		P_where_vendor_to := '1=1';
	else
		P_where_vendor_to := 'pov.vendor_name <= :p_vendor_to ';
	end if;
end if;





check_cust_from := instr(p_customer_from,'''',1);
check_cust_to := instr(p_customer_to,'''',1);



if check_cust_from > 0 then

	cust_length_from := NVL(length(p_customer_from), 0);
	apostrophe_cust_from := instr(p_customer_from,'''',1);
	before_cust_from := substr(p_customer_from,1,apostrophe_cust_from - 1);
	after_cust_from := substr(p_customer_from,apostrophe_cust_from + 1,cust_length_from);

	P_where_customer_from := 'oev.name >= 			'||''''||before_cust_from||''''||''''||after_cust_from||'''';

else
	if (P_customer_from is  null) then
   		P_where_customer_from := '1=1';
	else
		P_where_customer_from := 'oev.name >= :p_customer_from ';
	end if;
end if;

if check_apos_to > 0 then

	cust_length_to := NVL(length(p_customer_to), 0);
	apostrophe_cust_to := instr(p_customer_to,'''',1);
	before_cust_to := substr(p_customer_to,1,apostrophe_cust_to - 1);
	after_cust_to := substr(p_customer_to,apostrophe_cust_to + 1,cust_length_to);

	P_where_customer_to := 'oev.name <= '	||''''||before_cust_to||''''||''''||after_cust_to||'''';

else
	if (P_customer_to is  null) then
   		P_where_customer_to := '1=1';
	else
		P_where_customer_to := 'oev.name <= :p_customer_to ';
	end if;
end if;





if (P_trx_date_from is not null) then
   P_where_trx_date_from := ' rct.transaction_date  >= trunc(:P_trx_date_from)';
else
   P_where_trx_date_from := '1=1';
end if;



if (P_trx_date_to is not null) then
   P_where_trx_date_to := ' rct.transaction_date  <  trunc(:P_trx_date_to)+1';
else
   P_where_trx_date_to := '1=1';
end if;

if (P_ship_num_from is not null) then
   P_where_ship_num_from := 'rsh.shipment_num >= :P_ship_num_from ';
    /*srw.message( 10001, ' The from ship  No is ' || P_ship_num_from ) ;*/null;

else
   P_where_ship_num_from := '1=1';
end if;

if (P_ship_num_to is not null) then
   P_where_ship_num_to := 'rsh.shipment_num <= :P_ship_num_to ';
    /*srw.message(1002, ' The to shipment No is '|| P_ship_num_to );*/null;

else
   P_where_ship_num_to := '1=1';
end if;

if ((P_ship_num_from is not null) and (P_ship_num_to = P_ship_num_from)) then
     P_where_ship_num_from := 'rsh.shipment_num = :P_ship_num_from ';
     P_where_ship_num_to   := '1=1';
end if;



if ((P_req_num_from is not null) and (req_numbering_type = 'ALPHANUMERIC')) then
   P_where_req_num_from := 'prh.segment1 >= :P_req_num_from ';
elsif
   ((P_req_num_from is not null) and (req_numbering_type = 'NUMERIC')) then
   P_where_req_num_from := 'decode( ltrim(prh.segment1,''0123456789'') , NULL , to_number(prh.segment1) , null ) >= :P_req_num_from'; else
   P_where_req_num_from := '1=1';
end if;

if ((P_req_num_to is not null) and (req_numbering_type = 'ALPHANUMERIC')) then
   P_where_req_num_to := 'prh.segment1 <= :P_req_num_to ';
elsif
   ((P_req_num_to is not null) and (req_numbering_type = 'NUMERIC')) then
   P_where_req_num_to := 'decode( ltrim(prh.segment1,''0123456789'') , NULL , to_number(prh.segment1) , null ) <= :P_req_num_to';else
   P_where_req_num_to := '1=1';
end if;

if ((P_req_num_from is not null)
    and (P_req_num_from = P_req_num_to)
    and (req_numbering_type IN( 'ALPHANUMERIC','NUMERIC'))) then
   P_where_req_num_from := 'prh.segment1 = :P_req_num_from ';
   P_where_req_num_to   := '1=1';
end if;


if (P_rma_num_from is not null) then
    P_where_rma_num_from := 'to_number(oeh.order_number) >= :P_rma_num_from';
else
    P_where_rma_num_from := '1=1';
end if;


if (P_rma_num_to is not null) then
    P_where_rma_num_to := 'to_number(oeh.order_number) <= :P_rma_num_to';
else
    P_where_rma_num_to := '1=1';
end if;

if ((P_rma_num_from is not null)
    and (P_rma_num_from = P_rma_num_to)) then
    P_where_rma_num_from := 'to_number(oeh.order_number) = :P_rma_num_from';
    P_where_rma_num_to  := '1=1';
end if;



End;  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function rcv_uom_convertformula(PO_UOM in varchar2, UOM in varchar2, ls_item_id in number, PRICE in number) return number is
	l_uom_rate number;
	l_new_price number;
BEGIN


       IF (PO_UOM IS NOT NULL AND UOM IS NOT NULL) THEN
		IF (PO_UOM <> UOM) THEN
      			l_uom_rate := po_uom_s.po_uom_convert(uom, po_uom,ls_item_id);

			l_new_price := PRICE * l_uom_rate;
			l_new_price := round(l_new_price,5);
		ELSE
			l_new_price := PRICE;

		END IF;
	 ELSE
		return(PRICE);
         END IF;

return(l_new_price);
END;

--Functions to refer Oracle report placeholders--

END PO_RCVTXRTR_new_XMLP_PKG ;


/
