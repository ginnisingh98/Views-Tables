--------------------------------------------------------
--  DDL for Package Body PO_POXRQSIN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRQSIN_XMLP_PKG" AS
/* $Header: POXRQSINB.pls 120.1.12010000.2 2014/05/12 06:00:29 rkandima ship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

declare
l_status     po_lookup_codes.displayed_field%type ;
l_sort     po_lookup_codes.displayed_field%type ;
begin
if P_status is not null then

    select displayed_field
    into l_status
    from po_lookup_codes
    where lookup_code = P_status
    and lookup_type = 'AUTHORIZATION STATUS';

    P_status_displayed := l_status ;

else

    P_status_displayed := '' ;

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
FORMAT_MASK := PO_COMMON_XMLP_PKG.GET_PRECISION(P_QTY_PRECISION);
end;
DECLARE
l_message1	     po_lookup_codes.description%TYPE ;
Call_variable	boolean;
l_INDUSTRY	Varchar2(100);
l_ORACLE_SCHEMA Varchar2(100);
Begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  /*srw.user_exit('FND INSTALLATION OUTPUT_TYPE="STATUS"
                                 OUTPUT_FIELD=":P_OE_STATUS"
                                         APPS="ONT"') ;*/null;

Call_variable:= fnd_installation.GET_APP_INFO('PO',P_OE_STATUS,l_INDUSTRY,l_ORACLE_SCHEMA);


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
  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;

 null;


 null;
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

function orderby_clauseFormula return VARCHAR2 is
begin

if     upper(P_orderby) = 'REQUESTOR' then
       return ('3');
elsif  upper(P_orderby) = 'SUBINVENTORY' then
       return ('4');
elsif  upper(P_orderby) = 'CREATION DATE' then
       return ('2');
end if;
RETURN '3'; end;

function get_p_struct_num return boolean is

l_p_struct_num number;

begin
        select structure_id
        into l_p_struct_num
        from mtl_default_sets_view
        where functional_area_id = 2 ;

        P_STRUCT_NUM := l_p_struct_num ;

        return(TRUE) ;

        RETURN NULL; exception
        when others then return(FALSE) ;
end;

function C_backorderedFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I') then
  return ('decode(wdd.released_status,''B'',nvl(wdd.requested_quantity,0))') ;
else return('null');
end if;
RETURN NULL; end;

function C_fromFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I') then return(',       oe_order_lines_all                      oel
,       oe_order_headers_all                              oeh
,       wsh_delivery_details                       wdd') ;
end if;

RETURN NULL; end;

function C_whereFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I') then return ('AND     oel.orig_sys_line_ref         = to_char(prl.line_num)
AND     oeh.orig_sys_document_ref               = prh.segment1
AND     oeh.order_source_id            = psp1.order_source_id
AND     oeh.header_id                               = oel.header_id
AND     oel.line_id = wdd.source_line_id(+)
AND     wdd.source_code(+) = ''OE''  ');

else return('and 1=1') ;
end if;

RETURN NULL; end;

function C_interface_whereFormula return VARCHAR2 is
begin



if (P_OE_STATUS = 'I') then return ('AND exists
(select 1 from oe_headers_iface_all OEI
WHERE OEI.orig_sys_document_ref = PRH.requisition_header_id
AND   OEI.order_source_id = 10)');
else return('AND 1=2');
end if;
RETURN NULL; end;

function C_requiredFormula return VARCHAR2 is
begin

return ('prl.quantity - nvl(prl.quantity_cancelled, 0)');
end;

function c_ship_amountformula(required in number, unit_price in number) return number is
begin

return (required * unit_price);


end;

function C_ship_qtyFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I') then
return('nvl(oel.shipped_quantity, 0)');
else return ('to_number(null)');
end if;

RETURN NULL; end;

function P_WHERE_ITEMValidTrigger return boolean is
begin

  return (TRUE);
end;

function AfterPForm return boolean is
begin

   /*srw.user_exit('FND SRWINIT');*/null;

   begin


   P_CREATION_DATE_FROM1 := to_Char(P_CREATION_DATE_FROM,'dd-mon-yy');
   P_CREATION_DATE_TO1 := to_Char(P_CREATION_DATE_TO,'dd-mon-yy');

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
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXRQSIN_XMLP_PKG ;


/
