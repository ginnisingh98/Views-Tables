--------------------------------------------------------
--  DDL for Package Body PO_POXSERPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXSERPR_XMLP_PKG" AS
/* $Header: POXSERPRB.pls 120.1 2007/12/25 12:24:54 krreddy noship $ */

function BeforeReport return boolean is

l_person_id   PER_ALL_PEOPLE_F.person_id%TYPE;
l_inv_org_id  FINANCIALS_SYSTEM_PARAMETERS.inventory_organization_id%TYPE;
l_vendor_name_where   VARCHAR2(1000);
l_buyer_where_h       VARCHAR2(400);
l_buyer_where_r       VARCHAR2(400);
l_creation_date_where_h VARCHAR2(400);
l_creation_date_where_r VARCHAR2(400);
l_item_query_filter   VARCHAR2(2000);
begin




BEGIN
QTY_PRECISION:=po_common_xmlp_pkg.GET_PRECISION(P_qty_precision);
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  IF (get_p_struct_num <> TRUE)
    THEN /*SRW.MESSAGE('1','P Struct Num init failed');*/null;

  END IF;


 null;

 null;

 null;



l_vendor_name_where := ' ';
l_creation_date_where_h := ' ';
l_creation_date_where_r := ' ';
l_buyer_where_h := ' ';
l_buyer_where_r := ' ';




IF ((P_VENDOR_FROM IS NOT NULL)
   AND (P_VENDOR_TO IS NOT NULL)) THEN

  l_vendor_name_where := ' AND pov.vendor_name BETWEEN ' || ''''
                       || replace(P_VENDOR_FROM,'''','''''') || '''' || ' AND '
                       || '''' || replace(P_VENDOR_TO,'''','''''') || '''' || ' ';

ELSIF (P_VENDOR_FROM IS NOT NULL) THEN

  l_vendor_name_where := ' AND pov.vendor_name >= ' || ''''
                       || replace(P_VENDOR_FROM,'''','''''') || '''' || ' ';

ELSIF (P_VENDOR_TO IS NOT NULL) THEN

  l_vendor_name_where := ' AND pov.vendor_name <= ' || ''''
                       || replace(P_VENDOR_TO,'''','''''') || '''' || ' ';

END IF;

IF ((P_CREATION_DATE_FROM IS NOT NULL)
   AND (P_CREATION_DATE_FROM IS NOT NULL)) THEN

  l_creation_date_where_h := ' AND poh.creation_date BETWEEN trunc(to_date('
                || '''' || P_CREATION_DATE_FROM || ''''
                || ',' || '''' || 'YYYY/MM/DD HH24:MI:SS' || ''''
                || ')) AND trunc(to_date('
                || '''' || P_CREATION_DATE_TO || ''''
                || ',' || '''' || 'YYYY/MM/DD HH24:MI:SS' || ''''
                || ')) + 0.99999 ';

  l_creation_date_where_r := ' AND por.creation_date BETWEEN trunc(to_date('
                || '''' || P_CREATION_DATE_FROM || ''''
                || ',' || '''' || 'YYYY/MM/DD HH24:MI:SS' || ''''
                || ')) AND trunc(to_date('
                || '''' || P_CREATION_DATE_TO || ''''
                || ',' || '''' || 'YYYY/MM/DD HH24:MI:SS' || ''''
                || ')) + 0.99999 ';



ELSIF (P_CREATION_DATE_FROM IS NOT NULL) THEN

  l_creation_date_where_h := ' AND poh.creation_date >= trunc(to_date('
                || '''' || P_CREATION_DATE_FROM || ''''
                || ',' || '''' || 'YYYY/MM/DD HH24:MI:SS' || ''''
                || ')) ';
  l_creation_date_where_r := ' AND por.creation_date >= trunc(to_date('
                || '''' || P_CREATION_DATE_FROM || ''''
                || ',' || '''' || 'YYYY/MM/DD HH24:MI:SS' || ''''
                || ')) ';


ELSIF (P_CREATION_DATE_TO IS NOT NULL) THEN

  l_creation_date_where_h := ' AND poh.creation_date <= trunc(to_date('
                || '''' || P_CREATION_DATE_TO || ''''
                || ',' || '''' || 'YYYY/MM/DD HH24:MI:SS' || ''''
                || ')) + 0.99999 ';
  l_creation_date_where_r := ' AND por.creation_date <= trunc(to_date('
                || '''' || P_CREATION_DATE_TO || ''''
                || ',' || '''' || 'YYYY/MM/DD HH24:MI:SS' || ''''
                || ')) + 0.99999 ';

END IF;


IF (P_BUYER IS NOT NULL) THEN

  SELECT papf.person_id
  INTO l_person_id
  FROM per_all_people_f  papf
  WHERE papf.business_group_id = (
                    SELECT nvl(max(fsp.business_group_id),0)
                    FROM financials_system_parameters fsp)
    AND trunc(sysdate) BETWEEN
                papf.effective_start_date and papf.effective_end_date
    AND decode(hr_general.get_xbg_profile,'Y', papf.business_group_id
            , hr_general.get_business_group_id) = papf.business_group_id
    AND papf.full_name = nvl(P_BUYER,papf.full_name);

  l_buyer_where_h := 'AND poh.agent_id = ' || l_person_id;
  l_buyer_where_r := 'AND por.agent_id = ' || l_person_id;

END IF;


If ((P_ITEM_FROM IS NOT NULL) or (P_ITEM_TO IS NOT NULL) or (P_CATEGORY_FROM IS NOT NULL) or (P_CATEGORY_TO IS NOT NULL))
THEN

    SELECT fsp.inventory_organization_id
  INTO l_inv_org_id
  FROM financials_system_parameters fsp;

  IF ((P_ITEM_FROM IS NOT NULL) or (P_ITEM_TO IS NOT NULL))
  THEN

    l_item_query_filter := ' pol.item_id IN '
       || '            ( '
       || '               SELECT msi.inventory_item_id '
       || '               FROM mtl_system_items msi '
       || '               WHERE nvl(msi.organization_id, ' || l_inv_org_id || ' ) = ' || l_inv_org_id
       || '               AND ' || P_WHERE_ITEM
       || '            )';


    IF ((P_CATEGORY_FROM IS NOT NULL) or (P_CATEGORY_TO IS NOT NULL))
    THEN

      l_item_query_filter := l_item_query_filter || ' AND '
       || '            pol.category_id IN '
       || '            ( '
       || '              SELECT mca.category_id FROM mtl_categories mca '
       || '              WHERE ' || P_WHERE_CAT
       || '            ) ';

    END IF;

  ELSE

      l_item_query_filter :=  '            pol.category_id IN '
       || '            ( '
       || '              SELECT mca.category_id FROM mtl_categories mca '
       || '              WHERE ' || P_WHERE_CAT
       || '            ) ';

  END IF;



  P_VENDOR_QUERY := ' UNION '
       || ' SELECT DISTINCT pov.vendor_name Vendor '
       || '               , pov.segment1    Vendor_Number '
       || '               , pov.vendor_id   Parent_vendor_id '
       || ' FROM po_headers poh, po_vendors pov '
       || ' WHERE poh.vendor_id = pov.vendor_id '
       || l_buyer_where_h
       || l_creation_date_where_h
       || l_vendor_name_where
       || '   AND EXISTS '
       || '       ( '
       || '         SELECT 1 '
       || '         FROM rcv_transactions rct '
       || '         WHERE rct.po_header_id = poh.po_header_id '
       || '           AND rct.transaction_type = ''RECEIVE'' '
       || '           AND rct.po_release_id IS NULL '
       || '       ) '
       || '   AND poh.po_header_id IN '
       || '       ( '
       || '         SELECT DISTINCT pol.po_header_id '
       || '         FROM po_lines pol '
       || '         WHERE ' || l_item_query_filter
       || '        ) '
       || ' UNION '
       || ' SELECT DISTINCT pov.vendor_name Vendor '
       || '               , pov.segment1    Vendor_Number '
       || '               , pov.vendor_id   Parent_vendor_id '
       || ' FROM po_headers poh, po_releases_all por, po_vendors pov '
       || ' WHERE poh.vendor_id = pov.vendor_id '
       || '   AND poh.org_id = por.org_id '
       || '   AND por.po_header_id = poh.po_header_id '
       || l_buyer_where_r
       || l_creation_date_where_r
       || l_vendor_name_where
       || '   AND EXISTS '
       || '       ( '
       || '         SELECT 1 '
       || '         FROM rcv_transactions rct '
       || '         WHERE rct.po_header_id = poh.po_header_id '
       || '           AND rct.transaction_type = ''RECEIVE'' '
       || '           AND rct.po_release_id IS NOT NULL '
       || '       ) '
       || '   AND por.po_release_id IN '
       || '       ( '
       || '         SELECT DISTINCT pll.po_release_id '
       || '         FROM po_lines_all pol, po_line_locations pll '
       || '         WHERE pol.po_line_id = pll.po_line_id '
       || '           AND pol.org_id = pll.org_id '
       || '           AND ' || l_item_query_filter
       || '        ) ';


ELSIF ((P_BUYER IS NOT NULL) or (P_CREATION_DATE_FROM IS NOT NULL) or (P_CREATION_DATE_TO IS NOT NULL))
THEN
    P_VENDOR_QUERY := ' UNION '
       || ' SELECT DISTINCT pov.vendor_name Vendor  '
       || '               , pov.segment1    Vendor_Number '
       || '               , pov.vendor_id   Parent_vendor_id '
       || ' FROM po_headers poh, po_vendors pov '
       || ' WHERE poh.vendor_id = pov.vendor_id '
       || l_buyer_where_h
       || l_creation_date_where_h
       || l_vendor_name_where
       || '   AND EXISTS '
       || '     ( '
       || '       SELECT 1 '
       || '       FROM rcv_transactions rct '
       || '       WHERE rct.po_header_id = poh.po_header_id '
       || '         AND rct.transaction_type = ''RECEIVE'' '
       || '         AND rct.po_release_id IS NULL '
       || '     ) '
       || ' UNION '
       || ' SELECT DISTINCT pov.vendor_name Vendor '
       || '               , pov.segment1    Vendor_Number '
       || '               , pov.vendor_id   Parent_vendor_id '
       || ' FROM po_releases por, po_headers poh, po_vendors pov '
       || ' WHERE poh.vendor_id = pov.vendor_id '
       || ' AND por.po_header_id = poh.po_header_id '
       || l_buyer_where_r
       || l_creation_date_where_r
       || l_vendor_name_where
       || '   AND EXISTS '
       || '     ( '
       || '       SELECT 1 '
       || '       FROM rcv_transactions rct '
       || '       WHERE rct.po_header_id = poh.po_header_id '
       || '         AND rct.transaction_type = ''RECEIVE'' '
       || '         AND rct.po_release_id IS NOT NULL '
       || '     ) ';


ELSE
    P_VENDOR_QUERY := ' UNION '
       || ' SELECT pov.vendor_name Vendor, pov.segment1 Vendor_Number, pov.vendor_id Parent_vendor_id'
       || ' FROM po_vendors pov'
       || ' WHERE'
       || ' ( '
       || '   EXISTS  '
       || '   (  '
       || '    SELECT 1 '
       || '    FROM po_headers poh '
       || '    WHERE poh.vendor_id = pov.vendor_id '
       || '     AND EXISTS '
       || '        ( '
       || '          SELECT 1 '
       || '          FROM rcv_transactions rct '
       || '          WHERE rct.po_header_id = poh.po_header_id '
       || '          AND rct.transaction_type = ''RECEIVE'' '
       || '          AND rct.po_release_id IS NULL '
       || '        ) '
       || '    ) '
       || ' OR EXISTS '
       || '    ( '
       || '     SELECT 1 '
       || '     FROM po_releases por, po_headers poh '
       || '     WHERE poh.vendor_id = pov.vendor_id '
       || '     AND por.po_header_id = poh.po_header_id '
       || '     AND EXISTS '
       || '        ( '
       || '         SELECT 1 '
       || '         FROM rcv_transactions rct '
       || '         WHERE rct.po_header_id = poh.po_header_id '
       || '         AND rct.transaction_type = ''RECEIVE'' '
       || '         AND rct.po_release_id IS NOT NULL '
       || '        ) '
       || '     ) '
       || '  ) '
       || l_vendor_name_where;

END IF;



  RETURN TRUE;
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

else /*srw.attr.formatmask  :=  '-NNN,NNN,NN0.00';*/null;

end if; end if; end if; end if; end if; end if;
/*srw.set_attr(0,srw.attr);*/null;

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

function locationformula(PO_RECEIVED in number, PO_WRONG_LOCATION in number) return number is
begin

/*SRW.REFERENCE(PO_RECEIVED);*/null;

/*SRW.REFERENCE(PO_WRONG_LOCATION) ;*/null;

if (PO_RECEIVED = 0 ) then return(0) ;
else return (round((PO_WRONG_LOCATION / PO_RECEIVED),P_qty_precision+2) * 100 ) ;
end if;
RETURN NULL; end;

function on_timeformula(PO_ORDERED in number, PO_RECEIVED in number, PO_ON_TIME in number) return number is
begin

/*SRW.REFERENCE(PO_ORDERED) ;*/null;

/*SRW.REFERENCE(PO_ON_TIME) ;*/null;

/*SRW.REFERENCE(PO_RECEIVED) ;*/null;

IF (PO_ORDERED > PO_RECEIVED) then
begin
	if (PO_ORDERED = 0 ) then return (0) ;
	else return ( round((PO_ON_TIME / PO_ORDERED ),P_qty_precision+2) * 100 ) ;
	end if;
end;
else begin
	if (PO_RECEIVED = 0 ) then return (0) ;
	else return ( round((PO_ON_TIME / PO_RECEIVED ),P_qty_precision+2) * 100 ) ;
	end if;
end ;
end if;

RETURN NULL; end;

function lateformula(PO_ORDERED in number, PO_RECEIVED in number, PO_LATE in number) return number is
begin

/*SRW.REFERENCE(PO_ORDERED) ;*/null;

/*SRW.REFERENCE(PO_LATE) ;*/null;

/*SRW.REFERENCE(PO_RECEIVED) ;*/null;

IF (PO_ORDERED > PO_RECEIVED) then
begin
	if (PO_ORDERED = 0 ) then return (0) ;
	else return ( round((PO_LATE / PO_ORDERED ),P_qty_precision+2) * 100 ) ;
	end if;
end;
else begin
	if (PO_RECEIVED = 0 ) then return (0) ;
	else return ( round((PO_LATE / PO_RECEIVED ),P_qty_precision+2) * 100 ) ;
	end if;
end ;
end if;

RETURN NULL; end;

function earlyformula(PO_ORDERED in number, PO_RECEIVED in number, PO_EARLY in number) return number is
begin

/*SRW.REFERENCE(PO_ORDERED) ;*/null;

/*SRW.REFERENCE(PO_EARLY) ;*/null;

/*SRW.REFERENCE(PO_RECEIVED) ;*/null;

IF (PO_ORDERED > PO_RECEIVED) then
begin
	if (PO_ORDERED = 0 ) then return (0) ;
	else return ( round((PO_EARLY / PO_ORDERED ),P_qty_precision+2) * 100 ) ;
	end if;
end;
else begin
	if (PO_RECEIVED = 0 ) then return (0) ;
	else return ( round((PO_EARLY / PO_RECEIVED ),P_qty_precision+2) * 100 ) ;
	end if;
end ;
end if;

RETURN NULL; end;

function varianceformula(PO_RECEIVED in number, PO_DAYS_QTY in number) return number is
begin

/*SRW.REFERENCE(PO_DAYS_QTY) ;*/null;

/*SRW.REFERENCE(PO_RECEIVED) ;*/null;

if (PO_RECEIVED = 0 ) then return (0) ;
else return ( round(( PO_DAYS_QTY / PO_RECEIVED),P_qty_precision)  ) ;
end if;
RETURN NULL; end;

function c_per_item_earlyformula(C_item_sum_ord in number, C_item_sum_rec in number, C_item_sum_early in number) return number is
begin

/*SRW.REFERENCE(C_ITEM_SUM_ORD) ;*/null;

/*SRW.REFERENCE(C_ITEM_SUM_REC) ;*/null;

/*SRW.REFERENCE(C_ITEM_SUM_EARLY) ;*/null;

if (C_item_sum_ord > C_item_sum_rec) then
begin
	if (C_item_sum_ord = 0 ) then return (0) ;
	else return ( round((C_item_sum_early / C_item_sum_ord ),P_qty_precision+2) * 100 ) ;
	end if;
end;
else
begin
	if (C_item_sum_rec = 0 ) then return (0) ;
	else return ( round((C_item_sum_early / C_item_sum_rec ),P_qty_precision+2) * 100 ) ;
	end if;
end;
end if;

RETURN NULL; end;

function c_per_item_lateformula(C_item_sum_ord in number, C_item_sum_rec in number, C_item_sum_late in number) return number is
begin

/*SRW.REFERENCE(C_ITEM_SUM_ORD) ;*/null;

/*SRW.REFERENCE(C_ITEM_SUM_REC) ;*/null;

/*SRW.REFERENCE(C_ITEM_SUM_LATE) ;*/null;

if (C_item_sum_ord > C_item_sum_rec) then
begin
	if (C_item_sum_ord = 0 ) then return (0) ;
	else return ( round((C_item_sum_late / C_item_sum_ord ),P_qty_precision+2) * 100 ) ;
	end if;
end;
else
begin
	if (C_item_sum_rec = 0 ) then return (0) ;
	else return ( round((C_item_sum_late / C_item_sum_rec ),P_qty_precision+2) * 100 ) ;
	end if;
end;
end if;
RETURN NULL; end;

function c_per_item_on_timeformula(C_item_sum_ord in number, C_item_sum_rec in number, C_item_sum_on_time in number) return number is
begin

/*SRW.REFERENCE(C_ITEM_SUM_ORD) ;*/null;

/*SRW.REFERENCE(C_ITEM_SUM_REC) ;*/null;

/*SRW.REFERENCE(C_ITEM_SUM_ON_TIME) ;*/null;

if (C_item_sum_ord > C_item_sum_rec) then
begin
	if (C_item_sum_ord = 0 ) then return (0) ;
	else return ( round((C_item_sum_on_time / C_item_sum_ord ),P_qty_precision+2) * 100 ) ;
	end if;
end;
else
begin
	if (C_item_sum_rec = 0 ) then return (0) ;
	else return ( round((C_item_sum_on_time / C_item_sum_rec ),P_qty_precision+2) * 100 ) ;
	end if;
end;
end if;
RETURN NULL; end;

function c_per_item_locformula(C_item_sum_rec in number, C_item_sum_w_loc in number) return number is
begin

/*srw.reference(C_item_sum_w_loc) ;*/null;

/*srw.reference(C_item_sum_rec) ;*/null;

if (C_item_sum_rec = 0 ) then return(0) ;
else return (round((C_item_sum_w_loc / C_item_sum_rec),P_qty_precision+2) * 100 ) ;
end if;
RETURN NULL; end;

function c_per_item_rejformula(C_item_sum_rec in number, C_item_sum_rej in number) return number is
begin

/*srw.reference(C_item_sum_rej) ;*/null;

/*srw.reference(C_item_sum_rec) ;*/null;

if (C_item_sum_rec = 0 ) then return (0) ;
else return ( round(( C_item_sum_rej / C_item_sum_rec ),P_qty_precision+2) * 100 ) ;
end if;
RETURN NULL; end;

function c_per_item_varformula(C_item_sum_rec in number, C_item_sum_days_qty in number) return number is
begin

/*srw.reference(C_item_sum_days_qty) ;*/null;

/*srw.reference(C_item_sum_rec) ;*/null;

if (C_item_sum_rec = 0 ) then return (0) ;
else return ( round(( (C_item_sum_days_qty) / C_item_sum_rec ),P_qty_precision) ) ;
end if;
RETURN NULL; end;

function orderedformula(shipment_conversion_rate in varchar2, pll_quantity_ordered in number) return number is
begin

/*srw.reference(shipment_conversion_rate) ;*/null;

/*srw.reference(pll_quantity_ordered) ;*/null;

return (shipment_conversion_rate * pll_quantity_ordered) ;
end;

function rejectedformula(shipment_conversion_rate in varchar2, pll_quantity_rejected in number) return number is
begin

/*srw.reference(shipment_conversion_rate) ;*/null;

/*srw.reference(pll_quantity_rejected) ;*/null;

return (shipment_conversion_rate * pll_quantity_rejected) ;
end;

function per_rejectedformula(PO_received in number, PO_rejected in number) return number is
begin

/*srw.reference(PO_received) ;*/null;

if (PO_received = 0 ) then return (0) ;
else return ( round(( PO_rejected / PO_received ),P_qty_precision+2) * 100 ) ;
end if;
RETURN NULL; end;

function openformula(Received in number, Ordered in number, cutoff_date in date) return number is
begin

/*srw.reference(Ordered) ;*/null;

/*srw.reference(Received) ;*/null;

/*srw.reference(promised_date) ;*/null;

if (Received >= Ordered) then return 0;
else begin
	if (trunc(sysdate) > trunc(nvl(cutoff_date,sysdate)))
	then return 0;
	else return(Ordered - Received) ;
	end if;
end;
end if;

RETURN NULL; end;

function past_dueformula(Received in number, Ordered in number, cutoff_date in date) return number is
begin

/*srw.reference(Ordered) ;*/null;

/*srw.reference(Received) ;*/null;

/*srw.reference(promised_date) ;*/null;

if (Received >= Ordered) then return 0;
else begin
	if (trunc(sysdate) <= trunc(nvl(cutoff_date,sysdate)))
	then return 0;
	else return(Ordered - Received) ;
	end if;
end;
end if;

RETURN NULL; end;

function p_openformula(PO_ORDERED in number, PO_RECEIVED in number, PO_OPEN in number) return number is
begin

/*SRW.REFERENCE(PO_ORDERED) ;*/null;

/*SRW.REFERENCE(PO_OPEN) ;*/null;

/*SRW.REFERENCE(PO_RECEIVED) ;*/null;

IF (PO_ORDERED > PO_RECEIVED) then
begin
	if (PO_ORDERED = 0 ) then return (0) ;
	else return ( round((PO_OPEN / PO_ORDERED ),P_qty_precision+2) * 100 ) ;
	end if;
end;
else begin
	if (PO_RECEIVED = 0 ) then return (0) ;
	else return ( round((PO_OPEN / PO_RECEIVED ),P_qty_precision+2) * 100 ) ;
	end if;
end ;
end if;

RETURN NULL; end;

function p_past_dueformula(PO_ORDERED in number, PO_RECEIVED in number, PO_PAST_DUE in number) return number is
begin

/*SRW.REFERENCE(PO_ORDERED) ;*/null;

/*SRW.REFERENCE(PO_PAST_DUE) ;*/null;

/*SRW.REFERENCE(PO_RECEIVED) ;*/null;

IF (PO_ORDERED > PO_RECEIVED) then
begin
	if (PO_ORDERED = 0 ) then return (0) ;
	else return ( round((PO_PAST_DUE / PO_ORDERED ),P_qty_precision+2) * 100 ) ;
	end if;
end;
else begin
	if (PO_RECEIVED = 0 ) then return (0) ;
	else return ( round((PO_PAST_DUE / PO_RECEIVED ),P_qty_precision+2) * 100 ) ;
	end if;
end ;
end if;

RETURN NULL; end;

function c_per_item_openformula(C_item_sum_ord in number, C_item_sum_rec in number, C_item_sum_open in number) return number is
begin

/*SRW.REFERENCE(C_ITEM_SUM_ORD) ;*/null;

/*SRW.REFERENCE(C_ITEM_SUM_REC) ;*/null;

/*SRW.REFERENCE(C_ITEM_SUM_OPEN) ;*/null;

if (C_item_sum_ord > C_item_sum_rec) then
begin
	if (C_item_sum_ord = 0 ) then return (0) ;
	else return ( round((C_item_sum_open / C_item_sum_ord ),P_qty_precision+2) * 100 ) ;
	end if;
end;
else
begin
	if (C_item_sum_rec = 0 ) then return (0) ;
	else return ( round((C_item_sum_open / C_item_sum_rec ),P_qty_precision+2) * 100 ) ;
	end if;
end;
end if;
RETURN NULL; end;

function c_per_item_past_dueformula(C_item_sum_ord in number, C_item_sum_rec in number, C_item_sum_past_due in number) return number is
begin

/*SRW.REFERENCE(C_ITEM_SUM_ORD) ;*/null;

/*SRW.REFERENCE(C_ITEM_SUM_REC) ;*/null;

/*SRW.REFERENCE(C_ITEM_SUM_PAST_DUE) ;*/null;

if (C_item_sum_ord > C_item_sum_rec) then
begin
	if (C_item_sum_ord = 0 ) then return (0) ;
	else return ( round((C_item_sum_past_due / C_item_sum_ord ),P_qty_precision+2) * 100 ) ;
	end if;
end;
else
begin
	if (C_item_sum_rec = 0 ) then return (0) ;
	else return ( round((C_item_sum_past_due / C_item_sum_rec ),P_qty_precision+2) * 100 ) ;
	end if;
end;
end if;
RETURN NULL; end;

function quantity_received_on_timeformu(quantity_received_total in number, quantity_received_early in number, quantity_received_late in number) return number is
begin

/*srw.reference(quantity_received_total) ;*/null;

/*srw.reference(quantity_received_early) ;*/null;

/*srw.reference(quantity_received_late) ;*/null;

return (quantity_received_total - quantity_received_early - quantity_received_late );

end;

function receivedformula(quantity_received_total in number) return number is
begin

/*srw.reference(quantity_received_total);*/null;

return(quantity_received_total);
end;

function days_total_late_or_earlyformul(days_received_early in number, days_received_late in number) return number is
begin

/*srw.reference(days_received_early);*/null;

/*srw.reference(days_received_late);*/null;


return(days_received_early + days_received_late);

end;

--Functions to refer Oracle report placeholders--

END PO_POXSERPR_XMLP_PKG ;


/
