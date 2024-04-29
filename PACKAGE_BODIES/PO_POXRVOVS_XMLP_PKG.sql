--------------------------------------------------------
--  DDL for Package Body PO_POXRVOVS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRVOVS_XMLP_PKG" AS
/* $Header: POXRVOVSB.pls 120.1.12010000.2 2014/05/22 05:39:49 liayang ship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

declare
l_sort     po_lookup_codes.displayed_field%type ;
l_org_displayed     org_organization_definitions.organization_name%type ;
begin

if P_sort is not null then

    select displayed_field
    into l_sort
    from po_lookup_codes
    where lookup_code = P_sort
    and lookup_type = 'SRS ORDER BY';

    P_sort_disp := l_sort ;

else

    P_sort_disp := '' ;

end if;

if P_org_id is not null then

    select organization_name
    into l_org_displayed
    from org_organization_definitions
    where organization_id = P_org_id ;

    P_org_displayed := l_org_displayed ;

else

    P_org_displayed := '' ;

end if;

FORMAT_MASK := PO_COMMON_XMLP_PKG.GET_PRECISION(P_QTY_PRECISION);
end;
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

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
            /*SRW.MESSAGE(1,'Before Cat Flex');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Item Flex');*/null;

END;
RETURN TRUE;  return (TRUE);
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

if P_SORT = 'VENDOR' then
   return('3');
else
   return('20,21');
end if;
RETURN NULL; end;

FUNCTION AFTERPFORM RETURN BOOLEAN IS
begin
  DECLARE

  begin


			 IF (p_site IS NOT NULL) THEN
              P_WHERE_VD_SITE := 'pvs.vendor_site_code= :p_site';
            ELSE
              P_WHERE_VD_SITE := '1=1';
            END IF;

			IF (p_ship_to IS NOT NULL) THEN
              P_WHERE_ST := 'lot.location_code= :p_ship_to';
            ELSE
              P_WHERE_ST := '1=1';
            END IF;


			IF (p_vendor_from IS NOT NULL) THEN
              P_WHERE_VF := 'pov.vendor_name >= :p_vendor_from';
            ELSE
              P_WHERE_VF := '1=1';
            END IF;


			IF (p_vendor_to IS NOT NULL) THEN
              P_WHERE_VT := 'pov.vendor_name <= :p_vendor_to';
            ELSE
              P_WHERE_VT := '1=1';
            END IF;


			IF (P_trans_date_from IS NOT NULL) THEN
              P_WHERE_TXND_FO := 'rct.transaction_date >=:P_trans_date_from';
			  P_WHERE_TXND_FO1 := 'rct.transaction_date >=:P_trans_date_from';
            ELSE
              P_WHERE_TXND_FO := '1=1';
			  P_WHERE_TXND_FO1 := '1=1';
            END IF;


			IF (P_trans_date_to IS NOT NULL) THEN
              P_WHERE_TXND_TO := 'rct.transaction_date <=:P_trans_date_to';
			  P_WHERE_TXND_TO1 := 'rct.transaction_date <=:P_trans_date_to';
            ELSE
              P_WHERE_TXND_TO := '1=1';
			  P_WHERE_TXND_TO1 := '1=1';
            END IF;


			IF (P_receiver IS NOT NULL) THEN
              P_WHERE_RCER := 'ppf.full_name= :P_receiver';
			  P_WHERE_RCER1 := 'papf.full_name =:P_receiver';
            ELSE
              P_WHERE_RCER := '1=1';
			  P_WHERE_RCER1 := '1=1';
            END IF;

			IF (P_org_id IS NOT NULL) THEN
              P_WHERE_ORG := 'rct.organization_id= :P_org_id';
			  P_WHERE_ORG1 := 'rct.organization_id= :P_org_id';
            ELSE
              P_WHERE_ORG := '1=1';
			  P_WHERE_ORG1 := '1=1';
            END IF;

 RETURN (TRUE);
  end ;

END AFTERPFORM;

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

function AfterReport return boolean is
begin


  /*SRW.USER_EXIT('FND SRWEXIT');*/null;


  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXRVOVS_XMLP_PKG ;


/
