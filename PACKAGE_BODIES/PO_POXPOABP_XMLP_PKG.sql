--------------------------------------------------------
--  DDL for Package Body PO_POXPOABP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXPOABP_XMLP_PKG" AS
/* $Header: POXPOABPB.pls 120.1 2007/12/25 11:07:13 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

DECLARE
   l_sort       po_lookup_codes.displayed_field%type;
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  IF P_ORDERBY is not NULL THEN
     SELECT displayed_field
     INTO l_sort
     FROM po_lookup_codes
     WHERE lookup_code = P_ORDERBY
     AND lookup_type = 'SRS ORDER BY';

   P_ORDERBY_DISPLAYED := l_sort;

   ELSE

     P_ORDERBY_DISPLAYED := '';

   END IF;
FORMAT_MASK := PO_common_xmlp_pkg.GET_PRECISION(P_QTY_PRECISION);
EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
   /*SRW.MESSAGE(1,'srw_init');*/null;

END;
BEGIN
  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;
END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Item Flex');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Cat Flex');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Categroy Orderby');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Item Orderby');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Category Where');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Item Where');*/null;

END;
RETURN TRUE;  return (TRUE);
end;

function orderby_clauseFormula return VARCHAR2 is
begin

if P_ORDERBY = 'CATEGORY' then
     return( ' 1 ');
else
     return(' 2 ');
end if;
--RETURN NULL; end;
RETURN('msi.inventory_item_id'); end;

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

function AfterPForm return boolean is
l_manual_numbering varchar2(30);




begin


     /*srw.user_exit('FND SRWINIT');*/null;


BEGIN
     Select manual_po_num_type into l_manual_numbering
     FROM po_system_parameters ;
EXCEPTION
   when NO_DATA_FOUND then
      l_manual_numbering := 'ALPHANUMERIC';
END;


if ( l_manual_numbering  = 'NUMERIC' ) then

 P_ITEMS_WHERE := ' decode(rtrim(poh1.segment1,''0123456789''),NULL,to_number(poh1.segment1),-1)
                    BETWEEN decode(rtrim(nvl(:P_blanket_po_num_from,poh1.segment1),''0123456789''),NULL, to_number(nvl(:P_blanket_po_num_from,poh1.segment1)),-1)
                    AND   decode(rtrim(nvl(:P_blanket_po_num_to,poh1.segment1),''0123456789''),NULL, to_number(nvl(:P_blanket_po_num_to,poh1.segment1)),-1) ' ;

else

  if ( P_blanket_po_num_from is not null and P_blanket_po_num_to is not null ) then
       P_ITEMS_WHERE := ' poh1.segment1 >= :P_blanket_po_num_from and poh1.segment1 <= :P_blanket_po_num_to ' ;
  elsif ( P_blanket_po_num_from is not null and P_blanket_po_num_to is null ) then
       P_ITEMS_WHERE := ' poh1.segment1 >= :P_blanket_po_num_from ' ;
  elsif ( P_blanket_po_num_from is null and P_blanket_po_num_to is not null ) then
       P_ITEMS_WHERE := ' poh1.segment1 <= :P_blanket_po_num_to ' ;
  else
       P_ITEMS_WHERE := ' 1 = 1 ' ;
  end if;

end if;
 return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXPOABP_XMLP_PKG ;


/
