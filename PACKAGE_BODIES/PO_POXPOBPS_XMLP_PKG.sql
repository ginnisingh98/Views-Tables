--------------------------------------------------------
--  DDL for Package Body PO_POXPOBPS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXPOBPS_XMLP_PKG" AS
/* $Header: POXPOBPSB.pls 120.1 2007/12/25 11:08:38 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

DECLARE
   l_sort       po_lookup_codes.displayed_field%type;
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

   QTY_PRECISION:=PO_COMMON_XMLP_PKG.GET_PRECISION(P_qty_precision);
  IF P_ORDERBY is not null THEN
    SELECT displayed_field
    INTO l_sort
    FROM po_lookup_codes
    WHERE lookup_code = P_ORDERBY
    AND lookup_type = 'SRS ORDER BY';

    P_ORDERBY_DISPLAYED := l_sort;

  ELSE

    P_ORDERBY_DISPLAYED := '';

  END IF;

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
            /*SRW.MESSAGE(1,'Before Category Where');*/null;

END;
RETURN TRUE;  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;

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

if upper(P_ORDERBY) = 'VENDOR'
 then return('pov.vendor_name');
elsif upper(P_ORDERBY) = 'PO NUMBER'
 then return('decode(psp1.manual_po_num_type, ''NUMERIC'',
                     null, poh.segment1),
              decode(psp1.manual_po_num_type, ''NUMERIC'',
                     to_number(poh.segment1), null)');
end if;
RETURN 'decode(psp1.manual_po_num_type,''NUMERIC'',null,poh.segment1), decode(psp1.manual_po_num_type,''NUMERIC'',to_number(poh.segment1),null)';
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

function cur_planned_amt_agreed(PO_type in varchar2, po_header_id1 in number) return number is

 X_TOTAL NUMBER;
BEGIN

/*SRW.REFERENCE(PO_TYPE);*/null;


IF PO_type = 'PLANNED' THEN

      SELECT SUM( (nvl(PLL.quantity,0) -
                   nvl(PLL.quantity_cancelled,0) ) *
                   nvl(PLL.price_override,0))
        INTO    X_TOTAL
        FROM    PO_LINE_LOCATIONS PLL
 	WHERE	PLL.po_header_id     = po_header_id1
 	 AND	PLL.shipment_type    = 'PLANNED';

ELSE
    X_TOTAL:= 0;
END IF;

IF X_TOTAL IS NOT NULL THEN
   RETURN(X_TOTAL);
ELSE
   RETURN(0);
END IF;

RETURN NULL; EXCEPTION

  WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
    RETURN(0);
END;

function cur_planned_amt_released(PO_type in varchar2, PO_HEADER_ID1 in number) return number is

 X_TOTAL NUMBER;
BEGIN


/*SRW.REFERENCE(PO_TYPE);*/null;


IF PO_type = 'PLANNED' THEN


      SELECT   sum((pll.quantity -
                nvl(pll.quantity_cancelled,0))*
                nvl(pll.price_override,0))
        INTO   X_TOTAL
        FROM   PO_LINE_LOCATIONS PLL
       WHERE   PLL.po_header_id   = PO_HEADER_ID1
         AND   PLL.shipment_type = 'SCHEDULED';


ELSE
    X_TOTAL:= 0;
END IF;

IF X_TOTAL IS NOT NULL THEN
   RETURN(X_TOTAL);
ELSE
   RETURN(0);
END IF;

RETURN NULL; EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(0);

  WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
    RETURN(0);
END;

function c_amount_rel(po_header_id1 in number) return number is

  X_RELEASED_AMT NUMBER;
  X_GA_FLAG  VARCHAR2(1);

BEGIN

/*srw.reference(PO_HEADER_ID1);*/null;


SELECT  nvl(global_agreement_flag,'N')
INTO    X_GA_FLAG
FROM    po_headers_all
WHERE   po_header_id = po_header_id1;

IF X_GA_FLAG = 'N' THEN


   SELECT   SUM (DECODE (POL.order_type_lookup_code,
                         'RATE', PLL.amount - NVL(PLL.amount_cancelled, 0),
                         'FIXED PRICE', PLL.amount - NVL(PLL.amount_cancelled, 0),
                         (NVL(PLL.quantity, 0) - NVL(PLL.quantity_cancelled, 0))
                                  * NVL(PLL.price_override, 0)))
   INTO X_RELEASED_AMT
   FROM     po_line_locations           pll,
            po_headers    poh,
            po_lines      POL
   WHERE    poh.po_header_id      = POL.po_header_id
   AND      POL.po_line_id = PLL.po_line_id
   AND      pll.shipment_type not in ('PRICE BREAK')
   AND      poh.po_header_id = po_header_id1;

ELSE



   SELECT   SUM (DECODE (POL.order_type_lookup_code,
                         'RATE', PLL.amount - NVL(PLL.amount_cancelled, 0),
                         'FIXED PRICE', PLL.amount - NVL(PLL.amount_cancelled, 0),
                         (NVL(PLL.quantity, 0) - NVL(PLL.quantity_cancelled, 0))
                                  * NVL(PLL.price_override, 0)))
   INTO X_RELEASED_AMT
   FROM     po_line_locations_all           pll,
            po_headers_all    poh,
            po_lines_all         POL
   WHERE    poh.po_header_id      = pll.from_header_id
   AND      POH.po_header_id = POL.po_header_id
   AND      POL.po_line_id = PLL.from_line_id
   AND      pll.shipment_type not in ('PRICE BREAK')
   AND      poh.po_header_id = po_header_id1;



END IF;

IF X_RELEASED_AMT IS NOT NULL THEN
   RETURN(X_RELEASED_AMT);
ELSE
   RETURN(0);
END IF;

EXCEPTION

  WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
    RETURN(0);

end;

function c_amount_rem(po_header_id1 in number) return number is

   X_REMAIN_AMT NUMBER;
   l_ga_flag varchar2(25);



BEGIN


/*srw.reference(PO_HEADER_ID1);*/null;

begin

select global_agreement_flag into l_ga_flag
from po_headers
where po_header_id=po_header_id1;
exception
	when others then
	 null;
end;
if(l_ga_flag='Y')then


	begin
		SELECT (min(poh.blanket_total_amount)- sum( round(
		(decode (pol.quantity, null, (pod.amount_ordered - pod.amount_cancelled),
		(( pod.quantity_ordered - pod.quantity_cancelled ) * poll.price_override)))
		))) REMAIN into x_remain_amt
		FROM po_distributions_all pod, po_line_locations_all poll, po_lines_all pol,po_headers poh
		WHERE pod.line_location_id = poll.line_location_id AND
		poll.po_line_id = pol.po_line_id AND
		pol.from_header_id =po_header_id1
		and poh.po_header_id=po_header_id1;

	exception
	when others then
		null;
	end;



else

SELECT (MIN(POH.blanket_total_amount) -
        SUM( DECODE (POL.order_type_lookup_code,
                     'RATE', PLL.amount - NVL(PLL.amount_cancelled, 0),
                     'FIXED PRICE', PLL.amount - NVL(PLL.amount_cancelled, 0),
                     (nvl(pll.quantity,0) - nvl(pll.quantity_cancelled,0))
                             * nvl(price_override,0)))) REMAIN
INTO X_REMAIN_AMT
FROM     po_line_locations           pll
,        po_headers    poh
,        po_lines     POL
WHERE    poh.po_header_id      = POL.po_header_id(+)
AND      POL.po_line_id        = PLL.po_line_id (+)
AND      pll.shipment_type not in ('PRICE BREAK')
AND      poh.po_header_id = po_header_id1;
end if;

IF X_REMAIN_AMT IS NOT NULL AND X_REMAIN_AMT >=0 THEN
   RETURN(X_REMAIN_AMT);
ELSE
   RETURN(0);
END IF;

EXCEPTION

  WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
    RETURN(0);
end;

function c_po_relformula(global_agreement_flag in varchar2, std_po in varchar2, Release in number) return char is

begin

/*srw.reference(global_agreement_flag);*/null;



IF nvl(global_agreement_flag,'N') = 'Y' THEN
   RETURN(std_po);
ELSE
   RETURN(to_number(Release));
END IF;

end;

function c_org_nameformula(po_org_id in number, global_agreement_flag in varchar2) return char is
X_ORG_NAME   varchar2(240);
begin

/*srw.reference(global_agreement_flag);*/null;

/*srw.reference(po_org_id);*/null;


SELECT  name
INTO  X_ORG_NAME
FROM  hr_organization_units
WHERE organization_id = po_org_id;

IF nvl(global_agreement_flag,'N') = 'Y' THEN
   RETURN(X_ORG_NAME);
ELSE
   RETURN(null);
END IF;
end;

--Functions to refer Oracle report placeholders--

END PO_POXPOBPS_XMLP_PKG ;


/
