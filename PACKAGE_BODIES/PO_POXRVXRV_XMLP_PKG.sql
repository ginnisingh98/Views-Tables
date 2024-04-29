--------------------------------------------------------
--  DDL for Package Body PO_POXRVXRV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRVXRV_XMLP_PKG" AS
/* $Header: POXRVXRVB.pls 120.1.12010000.4 2011/09/22 08:05:11 liayang ship $ */

function BeforeReport return boolean is
begin

Declare
l_org_displayed		org_organization_definitions.organization_name%type;

Begin
QTY_PRECISION:= PO_common_xmlp_pkg.GET_PRECISION(P_QTY_PRECISION);
   /*Bug 12998409 to pass the location id once location entered*/
   if (P_location is not null) then

      select location_id
      into p_location_id
      from hr_locations_all
      where location_code = P_location;

   end if;
   /*End Bug 12998409*/
  	If (P_org_id is not null) then
	begin
		select organization_name
		into l_org_displayed
		from org_organization_definitions
		where organization_id = P_org_id ;

		P_org_displayed := l_org_displayed ;
	end;
	else begin
		P_org_displayed := '' ;
	end;
	End if;
End;
BEGIN
  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;

 null;


 null;


 null;


 null;
  RETURN TRUE;
  END;  return (TRUE);
end;

function AfterReport return boolean is
begin
 /*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function orderby_clauseFormula return VARCHAR2 is
begin

if P_orderby = 'PROMISED DATE' then
   return('1');
elsif P_orderby = 'VENDOR' then
     return('2');
ELSE
    return('1');
end if;
RETURN NULL; end;

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

else



if P_qty_precision = 7 then /*srw.attr.formatmask  :=  	'-NNNNNNNNNNNNNN0';*/null;

else
if P_qty_precision = 8 then /*srw.attr.formatmask  := 	'-NNNNNNNNNNNN0.0';*/null;

else
if P_qty_precision = 9 then /*srw.attr.formatmask  :=  	'-NNNNNNNNNNN0.00';*/null;

else
if P_qty_precision = 10 then /*srw.attr.formatmask  := 	'-NNNNNNNNNN0.000';*/null;

else
if P_qty_precision = 11 then /*srw.attr.formatmask  := 	'-NNNNNNNNN0.0000';*/null;

else
if P_qty_precision = 12 then /*srw.attr.formatmask  := 	'-NNNNNNNN0.00000';*/null;

else
if P_qty_precision = 13 then /*srw.attr.formatmask  := 	'-NNNNNNN0.000000';*/null;

else
  /*srw.attr.formatmask  :=  '-NNN,NNN,NNN,NN0.00';*/null;

end if; end if; end if; end if; end if; end if;
end if; end if; end if; end if; end if; end if; end if;
/*srw.set_attr(0,srw.attr);*/null;

end;

function get_p_struct_num return boolean is

l_p_struct_num number;

begin
        select structure_id
        into l_p_struct_num
        from mtl_default_sets_view
        where functional_area_id = 2 ;

        LP_STRUCT_NUM := l_p_struct_num ;

        return(TRUE) ;

        RETURN NULL; exception
        when others then return(FALSE) ;
end;

function AfterPForm return boolean is
begin
LP_VENDOR := P_VENDOR;
LP_STRUCT_NUM := P_STRUCT_NUM;
LP_CUSTOMER := P_CUSTOMER;

declare
req_numbering_type 	varchar2(240);
po_numbering_type	varchar2(240);
Begin
  /*SRW.USER_EXIT('FND SRWINIT');*/null;



	SELECT 	manual_po_num_type
	, 	manual_req_num_type
 	INTO	po_numbering_type
	,	req_numbering_type
 	FROM 	po_system_parameters;





if ((P_po_num_from is not null) and (po_numbering_type = 'ALPHANUMERIC')) then
   P_where_po_num_from :=  'poh.segment1 >= '|| ''''|| P_po_num_from || '''';
elsif
   ((P_po_num_from is not null) and (po_numbering_type = 'NUMERIC')) then
   P_where_po_num_from := 'decode(rtrim(poh.segment1,''0123456789''),NULL,to_number(poh.segment1),null) >= '|| P_po_num_from;
else
   P_where_po_num_from := '1=1';
end if;

if ((P_po_num_to is not null) and (po_numbering_type = 'ALPHANUMERIC')) then
   P_where_po_num_to :=  'poh.segment1 <= '|| ''''|| P_po_num_to|| '''';
elsif
   ((P_po_num_to is not null) and (po_numbering_type = 'NUMERIC')) then
   P_where_po_num_to :=  'decode(rtrim(poh.segment1,''0123456789''),NULL,to_number(poh.segment1),null)
				 <= '|| P_po_num_to;
else
   P_where_po_num_to := '1=1';
end if;

if ((P_po_num_to is not null)
    and (P_po_num_from = P_po_num_to)
    and (po_numbering_type = 'ALPHANUMERIC')) then
     P_where_po_num_from := 'poh.segment1 = '|| ''''|| P_po_num_from || '''';
     P_where_po_num_to   := '1=1';
elsif
   ((P_po_num_to is not null)
    and (P_po_num_from = P_po_num_to)
    and (po_numbering_type = 'NUMERIC')) then
    P_where_po_num_from := 'decode(rtrim(poh.segment1,''0123456789''),NULL,to_number(poh.segment1),null)
				= '|| P_po_num_from;
     P_where_po_num_to   := '1=1';
end if;

--Bug 12980455 The LP Vendor name was not in single quotes previously which was causing
-- ORA-00920: invalid relational operator error.

if (P_vendor is not null) then
         LP_vendor := replace(P_vendor,'''','''''');
         LP_vendor:=''''||LP_vendor ||'''';
   P_where_vendor := 'pov.vendor_name = '||LP_vendor;
else
   P_where_vendor := '1=1';
end if;


if ((P_req_num_from is not null) and (req_numbering_type = 'ALPHANUMERIC')) then
   P_where_req_num_from := 'prh.segment1 >= ' ||''''||P_req_num_from||'''';
elsif
   ((P_req_num_from is not null) and (req_numbering_type = 'NUMERIC')) then
   P_where_req_num_from := 'to_number(prh.segment1) >= ' ||P_req_num_from;
else
   P_where_req_num_from := '1=1';
end if;

if ((P_req_num_to is not null) and (req_numbering_type = 'ALPHANUMERIC')) then
   P_where_req_num_to := 'prh.segment1 <= '|| ''''||P_req_num_to||'''';
elsif
   ((P_req_num_to is not null) and (req_numbering_type = 'NUMERIC')) then
   P_where_req_num_to := 'to_number(prh.segment1) <= '|| P_req_num_to;
else
   P_where_req_num_to := '1=1';
end if;

if ((P_req_num_from is not null)
    and (P_req_num_from = P_req_num_to)
    and (req_numbering_type = 'ALPHANUMERIC')) then
   P_where_req_num_from := 'prh.segment1 = ' ||''''||P_req_num_from||'''';
   P_where_req_num_to   := '1=1';
elsif
  ((P_req_num_from is not null)
    and (P_req_num_from = P_req_num_to)
    and (req_numbering_type = 'NUMERIC')) then
   P_where_req_num_from := 'to_number(prh.segment1) ='|| P_req_num_from;
   P_where_req_num_to   := '1=1';
end if;


if (P_rma_num_from is not null) then
    P_where_rma_num_from := 'to_number(rcv.oe_order_num) >= ' || P_rma_num_from;
else
    P_where_rma_num_from := '1=1';
end if;

if (P_rma_num_to is not null) then
    P_where_rma_num_to := 'to_number(rcv.oe_order_num) <= ' || P_rma_num_to;
else
    P_where_rma_num_to := '1=1';
end if;

if (P_rma_num_from is not null
    and (P_rma_num_from = P_rma_num_to)) then
    P_where_rma_num_from := 'to_number(rcv.oe_order_num) = ' || P_rma_num_from;
    P_where_rma_num_to := '1=1';
end if;

--Bug 12980455 The LP Customer was not  there in single quotes which was causing
-- ORA-00920: invalid relational operator error.

if (P_customer is not null) then
   LP_customer := replace(P_customer,'''','''''');
   LP_customer := ''''||LP_customer ||'''';
   P_where_customer := 'rcv.source = '||LP_customer;
else
   P_where_customer := '1=1';
end if;

if( (P_po_num_from is NULL and P_po_num_to is NULL and
    (P_req_num_from is NOT NULL or P_req_num_to is NOT NULL or P_rma_num_from is NOT NULL or P_rma_num_to is NOT NULL))) then
    P_where_no_po_num := 'poh.po_header_id = -0';
end if;

if ( (P_req_num_from is NULL and P_req_num_to is NULL and
     (P_po_num_from is NOT NULL or P_po_num_to is NOT NULL or P_rma_num_from is NOT NULL or P_rma_num_to is NOT NULL))) then
    P_where_no_req_num := 'prh.requisition_header_id = -0';
end if;

if ( (P_rma_num_from is NULL and P_rma_num_to is NULL and
     (P_po_num_from is NOT NULL or P_po_num_to is NOT NULL or P_req_num_from is NOT NULL or P_req_num_to is NOT NULL))) then
     P_where_no_rma_num := 'rcv.oe_order_num = -0';
end if;



if ( P_org_id is not null ) then
   P_PO_ORG := ' AND pll.ship_to_organization_id = :P_org_id ';
   P_REQ_ORG := ' AND prl.destination_organization_id = :P_org_id ' ;
   P_RMA_ORG := ' AND rcv.to_organization_id = :P_org_id ';
end if;









if (P_location is not null) then

  if (P_org_id is not null) then


      P_PO_ORG  := P_PO_ORG  || ' AND pll.ship_to_location_id = :p_location_id ';
      P_REQ_ORG := P_REQ_ORG || ' AND prl.deliver_to_location_id = :p_location_id ';

  else

      P_PO_ORG  := ' AND pll.ship_to_location_id = :p_location_id ';
      P_REQ_ORG := ' AND prl.deliver_to_location_id = :p_location_id ';

  end if;
end if;

End;  return (TRUE);
end;

function P_STRUCT_NUMValidTrigger return boolean is
begin

  return (TRUE);
end;

function BeforePForm return boolean is
begin
 return (TRUE);
end;

function BetweenPage return boolean is
begin

  return (TRUE);
end;

function P_org_displayedValidTrigger return boolean is
begin

  return (TRUE);
end;

function location_code1formula(location in varchar2, Shipment_type in varchar2, location_id1 in number) return char is
x_location_code  hr_locations_all.location_code%TYPE := NULL ;

begin

x_location_code := location;


if (x_location_code = 'ABC') then



  IF (Shipment_type in ('STANDARD','BLANKET','SCHEDULED') ) THEN

     BEGIN

     select hrtl.location_code
     into  x_location_code
     from  hr_locations_all hrl,
           hr_locations_all_tl hrtl
     where hrl.location_id = location_id1
     and   hrl.location_id = hrtl.location_id
     and   hrtl.language   = userenv('LANG');

     EXCEPTION
     when no_data_found then

          select substr(rtrim(hz.address1)||'-'||rtrim(hz.city),1,20) location_code
          into x_location_code
          from  hz_locations hz
          where hz.location_id = location_id1;
    END;

  end if;
end if;

return(x_location_code);
end;

function P_LOCATIONValidTrigger return boolean is
begin

   if (P_location is not null) then

      select location_id
      into p_location_id
      from hr_locations_all
      where location_code = P_location;

   end if;

return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXRVXRV_XMLP_PKG ;


/
