--------------------------------------------------------
--  DDL for Package Body PO_POXFIPOL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXFIPOL_XMLP_PKG" AS
/* $Header: POXFIPOLB.pls 120.1 2007/12/25 10:58:08 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function select_rev(revision_sort_ordering in varchar2) return character is
begin
    if revision_sort_ordering is null then
       return(', null revision_ordering');
    else
       return(', plc1.displayed_field revision_ordering');
    end if;
RETURN NULL; end;

function from_rev(revision_sort_ordering in varchar2) return character is
begin
    if revision_sort_ordering is null then
       return('  ');
    else
       return(', po_lookup_codes plc1');
   end if;
RETURN NULL; end;

function where_rev(revision_sort_ordering in varchar2) return character is
begin
    if revision_sort_ordering is null then
       return('AND 1=1');
    else
       return('and (plc1.lookup_type = ''REVISION SORT ORDERING'' and to_number(plc1.lookup_code) = fsp.revision_sort_ordering)');
  end if;
RETURN NULL; end;

function BeforeReport return boolean is
begin
po_moac_utils_pvt.set_org_context(204);
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'srw_init');*/null;

END;
DECLARE
l_INDUSTRY      varchar2(100);
l_Oracle_schema  varchar2(100);
L_boolean_var boolean;
Begin

L_boolean_var:=fnd_installation.GET_APP_INFO('PO',P_OE_STATUS,l_INDUSTRY,l_Oracle_schema);


  /*srw.user_exit('FND INSTALLATION OUTPUT_TYPE="STATUS"
                                 OUTPUT_FIELD="P_OE_STATUS"
                                         APPS="ONT"') ;*/null;

  /*srw.message(1,'ONT Installation status is ' || P_OE_STATUS) ;*/null;

  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Failure to get ONT status.');*/null;

End;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Acc Flex');*/null;

END;
RETURN TRUE;   return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function C_select_order_typeFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I' ) then return ('sot.name') ;
else return('null') ;
end if;
RETURN NULL; end;

function C_select_order_sourceFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I' ) then return ('sos.name') ;
else return('null') ;
end if;
RETURN NULL; end;

function C_select_oe_tablesFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I' ) then return (',so_order_types sot,so_order_sources sos') ;
else return('  ') ;
end if;
RETURN NULL; end;

function C_from_oe_clauseFormula return VARCHAR2 is
begin

if (P_OE_STATUS = 'I') then return(' psp1.order_type_id=sot.order_type_id(+) AND psp1.order_source_id=sos.order_source_id(+)') ;
else return(' 1=1');
end if;

RETURN NULL; end;

--Functions to refer Oracle report placeholders--

END PO_POXFIPOL_XMLP_PKG ;


/
