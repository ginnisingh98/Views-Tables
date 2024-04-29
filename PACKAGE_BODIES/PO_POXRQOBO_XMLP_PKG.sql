--------------------------------------------------------
--  DDL for Package Body PO_POXRQOBO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRQOBO_XMLP_PKG" AS
/* $Header: POXRQOBOB.pls 120.2 2008/01/06 07:49:05 dwkrishn noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

QTY_PRECISION:=po_common_xmlp_pkg.get_precision(P_QTY_PRECISION);
  if (get_p_struct_num() <> TRUE )
    then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;

 null;


 null;
end;
DECLARE
l_message1      po_lookup_codes.description%TYPE ;
l_INDUSTRY      varchar2(100);
l_Oracle_schema  varchar2(100);
L_boolean_var boolean;
begin
  /*srw.user_exit('FND INSTALLATION OUTPUT_TYPE="STATUS"
                                 OUTPUT_FIELD="P_OE_STATUS"
                                         APPS="ONT"') ;*/null;


L_boolean_var:=fnd_installation.GET_APP_INFO('PO',P_OE_STATUS,l_INDUSTRY,l_Oracle_schema);

  if P_OE_STATUS <> 'I' then

 select description
 into l_message1
 from po_lookup_codes
 where lookup_type = 'SRW MESSAGE'
 and lookup_code = 'CANNOT RUN PROGRAM' ;

            /*srw.message(1,l_message1) ;*/null;

        return FALSE;
  end if;

  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
  select description
 into l_message1
 from po_lookup_codes
 where lookup_type = 'SRW MESSAGE'
 and lookup_code = 'FAILURE TO GET STATUS' ;

            /*srw.message(1,l_message1) ;*/null;

            return FALSE ;

End;


  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

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
return('nvl(wdd.requested_quantity,0)') ; end if;
RETURN NULL; end;

function C_whereFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I') then
return('AND     nvl(oel.source_document_line_id, -9)  =  prl.requisition_line_id
AND     oeh.orig_sys_document_ref       = prh.segment1
AND     oeh.order_source_id    = psp1.order_source_id
AND     oeh.header_id                       = oel.header_id
AND     oel.line_id = wdd.source_line_id
AND     wdd.source_code = ''OE''
AND     wdd.released_status = ''B''  ');

end if;

RETURN 'and 1=1'; end;

function C_fromFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I') then
return(',       oe_order_lines_all                              oel
 ,       oe_order_headers_all                             oeh
 ,       wsh_delivery_details                       wdd') ;
end if;

RETURN NULL; end;

function g_requisitiongroupfilter(backordered in number) return boolean is
begin

return (backordered > 0);
  return (TRUE);
end;

function C_ship_quantityFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I') then
return('nvl(oel.shipped_quantity, 0)');
else return ('to_number(null)');
end if;

RETURN NULL; end;

--Functions to refer Oracle report placeholders--

END PO_POXRQOBO_XMLP_PKG ;


/
