--------------------------------------------------------
--  DDL for Package Body PO_POXBLREL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXBLREL_XMLP_PKG" AS
/* $Header: POXBLRELB.pls 120.1 2007/12/25 10:45:27 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

DECLARE
   l_sort       po_lookup_codes.displayed_field%type;
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

QTY_PRECISION:=PO_common_xmlp_pkg.GET_PRECISION(P_QTY_PRECISION);
  IF P_ORDERBY is NOT NULL THEN

    SELECT displayed_field
    INTO l_sort
    FROM po_lookup_codes
    WHERE lookup_code = P_ORDERBY
    AND lookup_type = 'SRS ORDER BY';

    P_ORDERBY_DISPLAYED := l_sort;

  ELSE

    P_ORDERBY_DISPLAYED := '';

  END IF;

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

if    upper(P_orderby) = 'VENDOR' then
      return('pov.vendor_name');
elsif upper(P_orderby) = 'PO NUMBER' then
      return('decode(psp1.manual_po_num_type,''NUMERIC'',
                     null,poh.segment1),
              decode(psp1.manual_po_num_type,''NUMERIC'',
                     to_number(poh.segment1),null)');
end if;
RETURN NULL; end;

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
begin

   /*srw.user_exit('FND SRWINIT');*/null;

  begin
       SELECT  psp.manual_po_num_type        manual_po_num_type
       into    P_Po_num_type
       FROM    po_system_parameters psp;

   exception
        when no_data_found then
             P_po_num_type := 'ALPHANUMERIC';
   end;


  If P_po_num_from = P_po_num_to THEN
	P_single_po_print := 1;
  END IF;

   if ( P_single_po_print = 1 ) then
     P_WHERE_QUERY :=  '  AND  poh.segment1 = :P_po_num_from ';

else

    IF ( P_po_num_type = 'NUMERIC' ) THEN

      P_WHERE_QUERY :=  ' AND decode(rtrim(poh.segment1,''0123456789''),NULL,to_number(poh.segment1),-1)
                 BETWEEN  decode(rtrim(nvl(nvl(:P_po_num_from,NULL),poh.segment1),''0123456789''),
                               NULL, to_number(nvl(nvl(:P_po_num_from ,NULL)
                      ,poh.segment1)),-1)  AND  decode(rtrim(nvl(nvl(:P_po_num_to ,NULL)
                      ,poh.segment1),''0123456789''),NULL, to_number(nvl(nvl(:P_po_num_to,NULL)
                      ,poh.segment1)),-1)'   ;

    ELSIF (P_PO_NUM_TYPE = 'ALPHANUMERIC' ) THEN

         IF (P_po_num_from IS NOT NULL AND P_po_num_to IS NOT NULL) THEN
       P_WHERE_QUERY :=  ' AND   poh.segment1 >= :P_po_num_from AND poh.segment1 <= :P_po_num_to ';

         ELSIF ( P_po_num_from IS NOT NULL AND P_po_num_to IS NULL ) THEN
        P_WHERE_QUERY :=  '  AND   poh.segment1 >= :P_po_num_from ' ;

         ELSIF ( P_po_num_from IS NULL AND P_po_num_to IS NOT NULL ) THEN
        P_WHERE_QUERY :=  '  AND   poh.segment1 <= :P_po_num_to ' ;

         ELSE
         P_WHERE_QUERY :=  ' AND   1 = 1  ' ;
         END IF;
    END IF;
  END iF;
  return (TRUE);

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXBLREL_XMLP_PKG ;


/
