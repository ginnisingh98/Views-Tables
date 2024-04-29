--------------------------------------------------------
--  DDL for Package Body PO_POXRQSDD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRQSDD_XMLP_PKG" AS
/* $Header: POXRQSDDB.pls 120.2 2008/01/08 07:16:40 dwkrishn noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

declare
l_sort     po_lookup_codes.displayed_field%type ;
begin
   FORMAT_MASK := PO_COMMON_XMLP_PKG.GET_PRECISION(P_qty_precision);
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


end;
DECLARE
l_message1	     po_lookup_codes.description%TYPE ;
l_INDUSTRY      varchar2(100);
l_Oracle_schema  varchar2(100);
L_boolean_var boolean;
Begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  /*srw.user_exit('FND INSTALLATION OUTPUT_TYPE="STATUS"
                                 OUTPUT_FIELD=":P_OE_STATUS"
                                         APPS="ONT"') ;*/null;

L_boolean_var:=fnd_installation.GET_APP_INFO('PO',P_OE_STATUS,l_INDUSTRY,l_Oracle_schema);

  if P_OE_STATUS <> 'I' then
	select description
	into l_message1
	from po_lookup_codes
	where lookup_type = 'SRW MESSAGE'
	and lookup_code = 'CANNOT RUN PROGRAM' ;

            /*srw.message(1,l_message1) ;*/null;

        return false;
  end if;

  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
	select description
	into l_message1
	from po_lookup_codes
	where lookup_type = 'SRW MESSAGE'
	and lookup_code = 'FAILURE TO GET STATUS' ;

            /*srw.message(1,l_message1) ;*/null;

            return false ;

End;
BEGIN

 null;
  RETURN TRUE;
END;  return (TRUE);
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

function orderby_clauseFormula return VARCHAR2 is
begin

if    upper(P_orderby) = 'CREATION DATE' then
      return('prl.creation_date');
elsif upper(P_orderby) = 'REQUESTOR' then
      return('papf.full_name');
elsif upper(P_orderby) = 'SUBINVENTORY' then
      return('prl.source_subinventory');
end if;
RETURN 'prl.creation_date'; end;

function C_shipped_qtyFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I') then return('oel.shipped_quantity') ;
end if;

RETURN NULL; end;

function C_selling_priceFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I') then return('oel.unit_selling_price') ;
end if;
RETURN NULL; end;

function C_fromFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I') then return(',        oe_order_lines_all                          oel
,        oe_order_headers_all                             oeh') ;
end if;

RETURN NULL; end;

function C_whereFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I') then return('AND      oel.orig_sys_line_ref = to_char(prl.line_num)
AND      oeh.orig_sys_document_ref      = prh.segment1
AND      oeh.order_source_id    = psp1.order_source_id
AND      oel.header_id                      = oeh.header_id
AND      oel.shipped_quantity is not null');
end if;

RETURN NULL; end;

function c_get_shipped_quantity (Quantity_delivered in number, unit_price in number, Line in number, Req_number in varchar2, p_Order_Source_id in number) return number is
begin
   select round(sum(oel.shipped_quantity),P_qty_precision)               Quantity_Shipped
,        round((nvl(sum(oel.shipped_quantity),0)
         - nvl(Quantity_delivered,0)),P_qty_precision)               Quantity_Variance
,        sum(nvl(oel.unit_selling_price,0) * nvl(oel.shipped_quantity,0)) -
         (nvl(unit_price,0) * nvl(Quantity_delivered,0))          Cost_Variance
   into    C_Quantity_Shipped,
           C_Quantity_Variance,
           C_Cost_Variance
   from   oe_order_lines_all                          oel,
          oe_order_headers_all                        oeh
where     oel.orig_sys_line_ref =   to_char(Line)
AND       oeh.orig_sys_document_ref      = Req_number
AND       oeh.order_source_id    =  p_Order_Source_id
AND       oel.header_id                      = oeh.header_id
AND       oel.shipped_quantity is not null
group by oeh.orig_sys_document_ref,oel.orig_sys_line_ref;

Return(1);
exception
 when no_data_found then
  Return(1);

end;

function get_shipped_quantity(orig_line_num in varchar2,orig_header_num varchar2,psp_order_source_id number)return number  is
   sum_shipped_quantity    number;
BEGIN
 select sum(oel.shipped_quantity)
  into  sum_shipped_quantity
   from   oe_order_lines_all                          oel,
          oe_order_headers_all                        oeh
where      oel.orig_sys_line_ref =  orig_line_num
AND      oeh.orig_sys_document_ref      = orig_header_num
AND      oeh.order_source_id    =  psp_order_source_id
AND      oel.header_id                      = oeh.header_id
AND      oel.shipped_quantity is not null;

Return  sum_shipped_quantity;
END;

function AfterPForm return boolean is
begin

     /*srw.user_exit('FND SRWINIT');*/null;


   begin
       SELECT  psp.manual_req_num_type        manual_req_num_type
       into    P_req_num_type
       FROM    po_system_parameters psp;

   exception
        when no_data_found then
             P_req_num_type := 'ALPHANUMERIC';
   end;


  If P_req_number_from = P_req_number_to THEN
	P_single_po_print := 1;
  END IF;

   if ( P_single_po_print = 1 ) then
     P_WHERE_QUERY :=  ' prh.segment1 = :P_req_number_from ';

else

    IF ( P_req_num_type = 'NUMERIC' ) THEN

      P_WHERE_QUERY :=  ' decode(rtrim(prh.segment1,''0123456789''),NULL,to_number(prh.segment1),-1)
                 BETWEEN  decode(rtrim(nvl(nvl(:P_req_number_from,NULL),prh.segment1),''0123456789''),
                               NULL, to_number(nvl(nvl(:P_req_number_from ,NULL)
                      ,prh.segment1)),-1)  AND  decode(rtrim(nvl(nvl(:P_req_number_to ,NULL)
                      ,prh.segment1),''0123456789''),NULL, to_number(nvl(nvl(:P_req_number_to,NULL)
                      ,prh.segment1)),-1)'   ;

    ELSIF (P_REQ_NUM_TYPE = 'ALPHANUMERIC' ) THEN

         IF (P_req_number_from IS NOT NULL AND P_req_number_to IS NOT NULL) THEN
       P_WHERE_QUERY :=  '   prh.segment1 >= :P_req_number_from AND prh.segment1 <= :P_req_number_to ';

         ELSIF ( P_req_number_from IS NOT NULL AND P_req_number_to IS NULL ) THEN
        P_WHERE_QUERY :=  'prh.segment1 >= :P_req_number_from ' ;

         ELSIF ( P_req_number_from IS NULL AND P_req_number_to IS NOT NULL ) THEN
        P_WHERE_QUERY :=  'prh.segment1 <= :P_req_number_to ' ;

         ELSE
         P_WHERE_QUERY :=  ' 1 = 1  ' ;
         END IF;
    END IF;
  END iF;
  return (TRUE);

end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_quantity_shipped_p return number is
	Begin
	 return C_quantity_shipped;
	 END;
 Function C_Quantity_Variance_p return number is
	Begin
	 return C_Quantity_Variance;
	 END;
 Function C_Cost_variance_p return number is
	Begin
	 return C_Cost_variance;
	 END;
END PO_POXRQSDD_XMLP_PKG ;


/
