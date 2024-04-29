--------------------------------------------------------
--  DDL for Package Body PO_POXRQRSR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRQRSR_XMLP_PKG" AS
/* $Header: POXRQRSRB.pls 120.1 2007/12/25 11:54:52 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  IF (get_p_struct_num <> TRUE)
    THEN /*SRW.MESSAGE('1','P_Struct_Num Init failed.');*/null;

  END IF;

 null;


 null;

  FORMAT_MASK := PO_COMMON_XMLP_PKG.GET_PRECISION(P_qty_precision);

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

function get_p_struct_num return boolean is

l_p_struct_num  number;

begin
   select structure_id
   into l_p_struct_num
   from mtl_default_sets_view
   where functional_area_id = 2;

   P_struct_num := l_p_struct_num;

   return(TRUE);

RETURN NULL; exception
   when others then return(FALSE);
end;

function C_WHERE_REQ_NUMFormula return Char is
   numbering_type varchar2(40);
 begin
  select psp.manual_req_num_type
                into numbering_type
                from po_system_parameters psp;

if (numbering_type = 'NUMERIC') then
 RETURN  (' AND decode(rtrim(prh.segment1,''0123456789''),NULL,to_number(prh.segment1),-1)
                 BETWEEN  decode(rtrim(nvl( ' ||nvl(P_req_num_from, 'NULL' ) ||
                      ',prh.segment1),''0123456789''),NULL, to_number(nvl( ' || nvl(P_req_num_from , 'NULL')||
                      ',prh.segment1)),-1)  AND  decode(rtrim(nvl( ' ||nvl(P_req_num_to ,'NULL')||
                      ',prh.segment1),''0123456789''),NULL, to_number(nvl(' ||nvl(P_req_num_to,'NULL')||
                      ',prh.segment1)),-1)'   );

else
 return(' AND prh.segment1 BETWEEN
         nvl('||''''||P_req_num_from||''''||',prh.segment1)
         AND
         nvl('||''''||P_req_num_to||''''||',prh.segment1)');
end if;
RETURN NULL;
end;

function cf_locationsformula(deliver_to_location in varchar2, deliver_to_location_id in number) return char is
x_address varchar2(1000);
begin
 if deliver_to_location is not null then
    return deliver_to_location ;
else
    select address1 || ' ' || address2 || ' ' || address3 into x_address
    from hz_locations where location_id = deliver_to_location_id;
    return(x_address);
end if;
end;

--Functions to refer Oracle report placeholders--

END PO_POXRQRSR_XMLP_PKG ;


/
