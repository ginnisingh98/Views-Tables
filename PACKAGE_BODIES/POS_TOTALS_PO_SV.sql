--------------------------------------------------------
--  DDL for Package Body POS_TOTALS_PO_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_TOTALS_PO_SV" as
/* $Header: POSPOTOB.pls 120.10.12010000.7 2012/08/09 04:41:03 ramkandu ship $ */

  FUNCTION get_po_total
	(X_header_id   number) return number is
    	 X_po_total     number;


x_min_unit		NUMBER;
x_precision		NUMBER;
l_document_type         varchar2(30);
l_revision_num          number;

  BEGIN
   /*  Always calculate the total from archive tables.  */

      select type_lookup_code, revision_num
      into l_document_type, l_revision_num
      from po_headers_archive_all
      where po_header_id = X_header_id and latest_external_flag = 'Y';

    X_po_total := POS_TOTALS_PO_SV.get_po_archive_total(X_header_id, l_revision_num,l_document_type);
    RETURN (X_po_total);

  EXCEPTION
    WHEN OTHERS then
       x_po_total := 0;
       return(x_po_total);
  END get_po_total;

FUNCTION get_amount_ordered
	(X_header_id   number,
	 X_revision_num number,
         X_doc_type varchar) return number is
    	 X_po_total     number;


x_min_unit		NUMBER;
x_precision		NUMBER;
x_global_agree_flag     VARCHAR2(1);

BEGIN

	  SELECT fc.minimum_accountable_unit,
		 fc.precision,
		 global_agreement_flag
	  INTO   x_min_unit,
        	 x_precision,
		 x_global_agree_flag
	  FROM   fnd_currencies			fc,
		 po_headers_archive_all         pha
	  WHERE  pha.po_header_id = X_header_id
		  AND	 pha.revision_num = X_revision_num
		  AND	 fc.currency_code   = pha.currency_code;

      if ( x_global_agree_flag = 'Y') then
	  if (x_min_unit is not null) then
			/* Bug 12997708 */
            SELECT  sum ( round (  (decode(pol.quantity, null, pol.amount,
		                                  (POL.QUANTITY * POL.UNIT_PRICE )))
                                  / x_min_unit )
                          * x_min_unit )
                      into x_po_total
	                FROM      po_lines_archive_all            pol
	                WHERE     pol.from_header_id = X_header_id
					AND       pol.latest_external_Flag = 'Y';
	  else
	    /* Bug 12997708 */
		SELECT    sum (decode(pol.quantity, null, pol.amount,
		                      (POL.QUANTITY * POL.UNIT_PRICE )))
		into x_po_total
	                FROM      po_lines_archive_all            pol
	                WHERE     pol.from_header_id = X_header_id
					AND       pol.latest_external_Flag = 'Y';


	  end if;
       ELSE

	if x_min_unit is null then

        	select sum(round(
	               decode(pll.quantity,
        	              null,
                	      (pll.amount - nvl(pll.amount_cancelled,0)),
	                      (pll.quantity - nvl(pll.quantity_cancelled,0))
        	              * nvl(pll.price_override,0)
                	     )
	               ,x_precision))
        	INTO   x_po_total
	        FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
	        WHERE  PLL.po_header_id   = x_header_id
		AND    PLL.LATEST_EXTERNAL_FLAG= 'Y'
	        AND    PLL.shipment_type in ('BLANKET','SCHEDULED');

      else

        select sum(round(
               decode(pll.quantity,
                      null,
                      (pll.amount - nvl(pll.amount_cancelled, 0)),
                      (pll.quantity - nvl(pll.quantity_cancelled, 0))
                      * nvl(pll.price_override,0)
                     )
               / x_min_unit)
               * x_min_unit)
        INTO   x_po_total
        FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
        WHERE  PLL.po_header_id   = x_header_id
	AND    PLL.LATEST_EXTERNAL_FLAG= 'Y'
        AND    PLL.shipment_type in ('BLANKET','SCHEDULED');



	END IF;
     END IF;

    RETURN (X_po_total);
EXCEPTION
    WHEN OTHERS then
       x_po_total := 0;
       return (X_po_total);

END get_amount_ordered;



FUNCTION get_po_archive_total
	(X_header_id   number,
	 X_revision_num number,
         X_doc_type varchar) return number is
    	 X_po_total     number;


x_min_unit		NUMBER;
x_precision		NUMBER;
x_org_id		NUMBER;

  BEGIN

  --togeorge 11/15/2000
  --changed org specific views to _all tables
  if (X_doc_type in ('STANDARD')) then

     select org_id
     into x_org_id
     from  po_headers_all
     where po_header_id = x_header_id;

     PO_MOAC_UTILS_PVT.set_org_context(x_org_id) ;


   --x_po_total := PO_CORE_S.get_archive_total_for_any_rev (x_header_id,'H','PO',x_doc_type,x_revision_num,'N');
   x_po_total := PO_DOCUMENT_TOTALS_PVT.getAmountOrdered('HEADER',x_header_id,'ARCHIVE',x_revision_num);

  elsif (X_doc_type in ('PLANNED')) then
	/* we should call the same PO api for PLANNED POs as well. Till PO enhaces the API, we will continue to duplicate */

	-- x_po_total := get_archive_total_for_any_rev (x_header_id,'H','PO',x_doc_type,x_revision_num,'N');

    SELECT   fc.minimum_accountable_unit,
	     fc.precision
      INTO   x_min_unit,
             x_precision
      FROM   fnd_currencies			fc,
	     po_headers_archive_all         pha
     WHERE   pha.po_header_id = X_header_id
     AND     pha.revision_num = X_revision_num
    AND      fc.currency_code   = pha.currency_code;

    if (x_min_unit is null) then
     select sum(round(
                      (plla1.quantity - nvl (plla1.quantity_cancelled, 0)) *
                      nvl(plla1.price_override, 0), x_precision)
                      )

            INTO  X_po_total
       FROM  po_line_locations_archive_all plla1
       where po_header_id = X_header_id
       and shipment_type in ('PLANNED')
       and revision_num = (
              SELECT max(plla2.revision_num)
                FROM PO_LINE_LOCATIONS_ARCHIVE_ALL plla2
               WHERE plla2.revision_num <= X_revision_num
                 AND plla2.line_location_id = plla1.line_location_id );
   else
   select sum(round((plla1.quantity -
                           nvl(plla1.quantity_cancelled,0)) *
                           nvl(plla1.price_override,0)/x_min_unit)*
                           x_min_unit)
        INTO   X_po_total
        FROM   po_line_locations_archive_all plla1 --po_line_locations_archive
        WHERE  po_header_id = X_header_id
        AND    shipment_type IN ('PLANNED')
        AND    revision_num = (
   		SELECT max( plla2.revision_num )
   		FROM  po_line_locations_archive_all plla2  --po_line_locations_archive
   		WHERE plla2.revision_num <= X_revision_num
   		AND   plla2.line_location_id = plla1.line_location_id ) ;
    end if;

   else
      SELECT BLANKET_TOTAL_AMOUNT
      INTO X_po_total
      FROM po_headers_archive_all
      WHERE revision_num = X_revision_num
      AND  po_header_id = X_header_id;
   end if;

    RETURN (X_po_total);
EXCEPTION
    WHEN OTHERS then
       x_po_total := 0;
       return (X_po_total);

END get_po_archive_total;




FUNCTION get_release_archive_total
	(X_release_id   number,
	 X_revision_num number) return number is
    	 X_po_total     number;


x_min_unit		NUMBER;
x_precision		NUMBER;

x_org_id		NUMBER;

  BEGIN



/* x_po_total := po_core_s.get_archive_total_for_any_rev (x_release_id,'R','PO','RELEASE',x_revision_num,'N'); */

  SELECT fc.minimum_accountable_unit,
	 fc.precision
  INTO   x_min_unit,
         x_precision
  FROM   fnd_currencies			fc,
	 po_headers_archive_all              pha,
	 po_releases_archive_all		pra
  WHERE  pha.po_header_id = pra.po_header_id
  AND    pha.LATEST_EXTERNAL_FLAG = 'Y'
  AND	 pra.po_release_id = X_release_id
  AND	 pra.revision_num = X_revision_num
  AND	 fc.currency_code   = pha.currency_code;



   if x_min_unit is null then
		select sum(round(
	               decode(plla1.quantity,
                      null,
                      (plla1.amount - nvl(plla1.amount_cancelled,0)),
                      ((plla1.quantity - nvl(plla1.quantity_cancelled,0)) *
                      nvl(plla1.price_override,0))
                     ) ,x_precision))
   	   into X_po_total
       FROM   po_line_locations_archive_all plla1
       WHERE  po_release_id = X_release_id
       AND    shipment_type IN ('BLANKET','SCHEDULED')
       AND    revision_num = (
   		SELECT max( plla2.revision_num )
   		FROM po_line_locations_archive_all plla2
   		WHERE plla2.revision_num <= X_revision_num
   		AND	plla2.line_location_id = plla1.line_location_id ) ;

  else

       select sum(round(decode(plla1.quantity,
			null,
			(plla1.amount - nvl(plla1.amount_cancelled,0)),
			((plla1.quantity -nvl(plla1.quantity_cancelled,0)) *
                           nvl(plla1.price_override,0)))/x_min_unit)*
                           x_min_unit)
       into X_po_total
       FROM   po_line_locations_archive_all plla1
       WHERE  po_release_id = X_release_id
       AND    shipment_type IN ('BLANKET','SCHEDULED')
       AND    revision_num = (
   		SELECT max( plla2.revision_num )
   		FROM po_line_locations_archive_all plla2
   		WHERE plla2.revision_num <= X_revision_num
   		AND	plla2.line_location_id = plla1.line_location_id ) ;
       end if;



    RETURN (X_po_total);

  EXCEPTION
    WHEN OTHERS then
       x_po_total := 0;
       return (X_po_total);

  END GET_RELEASE_ARCHIVE_TOTAL;




FUNCTION get_line_total
	(x_po_header_id in number,
	 x_po_release_id in number,
	 x_po_line_id   in number,
	 X_revision_num in number	 ) return number is

X_po_total     number;


x_min_unit		NUMBER;
x_precision		NUMBER;
x_org_id		NUMBER;


 BEGIN
--Bug 5159144
IF (PO_COMPLEX_WORK_PVT.is_financing_po(x_po_header_id)) THEN

	SELECT  fc.minimum_accountable_unit,
			fc.precision
		INTO   	x_min_unit,
			x_precision
		FROM	fnd_currencies			fc,
			po_headers_archive_all         poh
		WHERE   poh.revision_num = x_revision_num
		AND	poh.po_header_id = x_po_header_id
		AND     fc.currency_code   = poh.currency_code;

         if (x_min_unit is null) then
     		select round(
     		              decode(plaa1.quantity,
                                     null,
                                     plaa1.amount ,
                                    (plaa1.quantity
                                     * nvl(plaa1.unit_price,0)))
                             ,x_precision)
     		INTO  X_po_total
     		FROM  po_lines_archive_all plaa1
     		where plaa1.po_line_id = x_po_line_id
     		      and revision_num = (
     	                  SELECT max(plaa2.revision_num)
             	          FROM po_lines_archive_all plaa2
                          WHERE plaa2.revision_num <= x_revision_num
     	                  AND plaa2.po_line_id = plaa1.po_line_id );
     	 else
     		select round(
     		              decode(plaa1.quantity,
                                     null,
                                     plaa1.amount ,
                                     (plaa1.quantity
                                      * nvl(plaa1.unit_price,0)
                                      )
                                      )/x_min_unit)*x_min_unit
             	INTO    X_po_total
     	        FROM    po_lines_archive_all plaa1
     	        WHERE   plaa1.po_line_id = x_po_line_id
     	                AND	revision_num = (
        			SELECT max( plaa2.revision_num )
        			FROM  po_lines_archive_all plaa2
     	   		        WHERE plaa2.revision_num <= x_revision_num
        			AND   plaa2.po_line_id = plaa1.po_line_id ) ;
	 end if;


ELSE

	if x_po_release_id is not null then

		SELECT  fc.minimum_accountable_unit,
			fc.precision
		INTO   	x_min_unit,
			x_precision
		FROM    PO_HEADERS_ALL POH,
			FND_CURRENCIES			FC,
			PO_RELEASES_ARCHIVE_ALL POR
		WHERE  POR.po_release_id   = x_po_release_id
		      AND por.revision_num = x_revision_num
		      AND    POH.po_header_id    = POR.po_header_id
		      AND    FC.CURRENCY_CODE = POH.CURRENCY_CODE;
	else
		SELECT  fc.minimum_accountable_unit,
			fc.precision
		INTO   	x_min_unit,
			x_precision
		FROM	fnd_currencies			fc,
			po_headers_archive_all         poh
		WHERE   poh.revision_num = x_revision_num
		AND	poh.po_header_id = x_po_header_id
		AND     fc.currency_code   = poh.currency_code;

	end if;

  if (x_po_release_id is null) then
	if (x_min_unit is null) then
		select sum(round((
		decode(plla1.quantity,
                    null,
                    (plla1.amount - nvl(plla1.amount_cancelled, 0)),
                    (plla1.quantity - nvl(plla1.quantity_cancelled,0))
                    * nvl(plla1.price_override,0))),x_precision))
		INTO  X_po_total
		FROM  po_line_locations_archive_all plla1
		where plla1.po_line_id = x_po_line_id
		and shipment_type in ('STANDARD','PLANNED')
		and revision_num = (
	              SELECT max(plla2.revision_num)
        	        FROM PO_LINE_LOCATIONS_ARCHIVE_ALL plla2
               		WHERE plla2.revision_num <= x_revision_num
	                 AND plla2.line_location_id = plla1.line_location_id );
	else
		select sum(round((
		decode(plla1.quantity,
                    null,
                    (plla1.amount - nvl(plla1.amount_cancelled, 0)),
                    (plla1.quantity - nvl(plla1.quantity_cancelled,0))
                    * nvl(plla1.price_override,0)))/x_min_unit)*x_min_unit)
        	INTO    X_po_total
	        FROM    po_line_locations_archive_all plla1
	        WHERE   plla1.po_line_id = x_po_line_id
		AND 	shipment_type in ('STANDARD','PLANNED')
	        AND	revision_num = (
   			SELECT max( plla2.revision_num )
   			FROM  po_line_locations_archive_all plla2
	   		WHERE plla2.revision_num <= x_revision_num
   			AND   plla2.line_location_id = plla1.line_location_id ) ;
	end if;
   else /* po_release_id is not null */
	if (x_min_unit is null) then
		select sum(round((
             decode(plla1.quantity,
                    null,
                    (plla1.amount - nvl(plla1.amount_cancelled, 0)),
                    (plla1.quantity - nvl(plla1.quantity_cancelled,0))
                    * nvl(plla1.price_override,0))),x_precision))
		INTO  X_po_total
		FROM  po_line_locations_archive_all plla1
		where plla1.po_line_id = x_po_line_id
		and	plla1.po_release_id = x_po_release_id
		and shipment_type in ('BLANKET','SCHEDULED')
		and revision_num = (
        	      SELECT max(plla2.revision_num)
                	FROM PO_LINE_LOCATIONS_ARCHIVE_ALL plla2
	               WHERE plla2.revision_num <= x_revision_num
        	         AND plla2.line_location_id = plla1.line_location_id );
	   else
		select sum(round((
        	     decode(plla1.quantity,
                	    null,
	                    (plla1.amount - nvl(plla1.amount_cancelled, 0)),
	                    (plla1.quantity - nvl(plla1.quantity_cancelled,0))
	                    * nvl(plla1.price_override,0)))/x_min_unit)*x_min_unit)
	        INTO    X_po_total
	        FROM    po_line_locations_archive_all plla1
	        WHERE   plla1.po_line_id = x_po_line_id
		and	plla1.po_release_id = x_po_release_id
		AND 	shipment_type in ('BLANKET','SCHEDULED')
	        AND	revision_num = (
   			SELECT max( plla2.revision_num )
   			FROM  po_line_locations_archive_all plla2
	   		WHERE plla2.revision_num <= x_revision_num
   			AND   plla2.line_location_id = plla1.line_location_id ) ;
	    end if;
   end if;
END IF;/* IF not financing PO */
    RETURN (X_po_total);

EXCEPTION
    WHEN OTHERS then
       x_po_total := 0;
       return (X_po_total);

END get_line_total;



FUNCTION get_shipment_total
	(x_po_line_location_id   number,
	 X_revision_num number) return number is

X_po_total     number;


x_min_unit		NUMBER;
x_precision		NUMBER;
x_org_id		NUMBER;

  BEGIN

	SELECT  fc.minimum_accountable_unit,
		fc.precision
	INTO   	x_min_unit,
		x_precision
	FROM	fnd_currencies			fc,
		po_headers_all         pha,
		po_line_locations_archive_all poll
	WHERE   poll.line_location_id = x_po_line_location_id
	AND	poll.po_header_id = pha.po_header_id
	AND     fc.currency_code   = pha.currency_code
	AND     poll.latest_external_flag='Y';

    if (x_min_unit is null) then
	select round(
             decode(plla1.quantity,
                    null, (plla1.amount - nvl(plla1.amount_cancelled, 0)),
                    (plla1.quantity - nvl(plla1.quantity_cancelled,0))* nvl(plla1.price_override,0)), x_precision)
	INTO  X_po_total
	FROM  po_line_locations_archive_all plla1
	WHERE plla1.line_location_id = x_po_line_location_id
	AND   revision_num = (
		SELECT max(plla2.revision_num)
		FROM PO_LINE_LOCATIONS_ARCHIVE_ALL plla2
		WHERE plla2.revision_num <= X_revision_num
		AND plla2.line_location_id = plla1.line_location_id );
   else
	select round(
             decode(plla1.quantity,
                    null, (plla1.amount - nvl(plla1.amount_cancelled,0)),
                    (plla1.quantity - nvl(plla1.quantity_cancelled,0))* nvl(plla1.price_override,0)) / x_min_unit) * x_min_unit
        INTO    X_po_total
        FROM    po_line_locations_archive_all plla1
        WHERE   plla1.line_location_id = x_po_line_location_id
        AND	revision_num = (
   		SELECT max( plla2.revision_num )
   		FROM  po_line_locations_archive_all plla2
   		WHERE plla2.revision_num <= X_revision_num
   		AND   plla2.line_location_id = plla1.line_location_id ) ;
    end if;

    RETURN (X_po_total);

EXCEPTION
    WHEN OTHERS then
       x_po_total := 0;
       return (X_po_total);

END get_shipment_total;



PROCEDURE get_shipment_amounts (
	p_po_line_location_id	IN  NUMBER,
	p_revision_num 		IN  NUMBER,
	p_amount_ordered	OUT NOCOPY NUMBER,
	p_amount_received	OUT NOCOPY NUMBER,
	p_amount_billed		OUT NOCOPY NUMBER)
IS

x_min_unit		NUMBER;
x_precision		NUMBER;

  BEGIN

	SELECT  fc.minimum_accountable_unit,
		fc.precision
	INTO   	x_min_unit,
		x_precision
	FROM	fnd_currencies fc,
		po_headers_all pha,
		po_line_locations_archive_all poll
	WHERE   poll.line_location_id = p_po_line_location_id
	AND	poll.po_header_id = pha.po_header_id
	AND     fc.currency_code = pha.currency_code
	AND     poll.latest_external_flag='Y';

    if (x_min_unit is null) then
	select round(DECODE(PLLA.matching_basis,
                      'AMOUNT', NVL(PLLA.amount, 0) - NVL(PLLA.amount_cancelled, 0),
                      'QUANTITY', (NVL(PLLA.quantity,0)- NVL(PLLA.quantity_cancelled,0)) *
                                  NVL(PLLA.price_override, 0)),
                   x_precision)
	INTO  	p_amount_ordered
	FROM  PO_LINE_LOCATIONS_ARCHIVE_ALL PLLA
	WHERE plla.line_location_id = p_po_line_location_id
	AND   revision_num = (
		SELECT max(plla2.revision_num)
		FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL plla2
		WHERE  plla2.revision_num <= p_revision_num
		AND    plla2.line_location_id = plla.line_location_id );

        SELECT round(DECODE(PLL.matching_basis,
                      'AMOUNT', NVL(PLL.amount_received, 0),
                      'QUANTITY', NVL(PLL.quantity_received, 0)*NVL(PLL.price_override, 0)),
                   x_precision),
               round(DECODE(PLL.matching_basis,
                      'AMOUNT', NVL(PLL.amount_billed, 0),
                      'QUANTITY', NVL(PLL.quantity_billed, 0)*NVL(PLL.price_override, 0)),
                   x_precision)
	INTO  	p_amount_received,
		p_amount_billed
	FROM  PO_LINE_LOCATIONS_ALL PLL
	WHERE PLL.line_location_id = p_po_line_location_id;

   else
	select round((DECODE(PLLA.matching_basis,
                      'AMOUNT', NVL(PLLA.amount, 0) - NVL(PLLA.amount_cancelled, 0),
                      'QUANTITY', (NVL(PLLA.quantity,0)- nvl(PLLA.quantity_cancelled,0))
                                  * NVL(PLLA.price_override, 0))
                   / x_min_unit) * x_min_unit)
	INTO  	p_amount_ordered
        FROM    PO_LINE_LOCATIONS_ARCHIVE_ALL PLLA
        WHERE   plla.line_location_id = p_po_line_location_id
        AND	revision_num = (
   		SELECT max( plla2.revision_num )
   		FROM  po_line_locations_archive_all plla2
   		WHERE plla2.revision_num <= p_revision_num
   		AND   plla2.line_location_id = plla.line_location_id ) ;


        SELECT round((DECODE(PLL.matching_basis,
                      'AMOUNT', NVL(PLL.amount_received, 0),
                      'QUANTITY', NVL(PLL.quantity_received, 0)*NVL(PLL.price_override, 0))
                    / x_min_unit) * x_min_unit),
               round((DECODE(PLL.matching_basis,
                      'AMOUNT', NVL(PLL.amount_billed, 0),
                      'QUANTITY', NVL(PLL.quantity_billed, 0)*NVL(PLL.price_override, 0))
                    / x_min_unit) * x_min_unit)
	INTO  	p_amount_received,
		p_amount_billed
        FROM    PO_LINE_LOCATIONS_ALL PLL
        WHERE   pll.line_location_id = p_po_line_location_id;

    end if;

    select --sum(quantity_invoiced),
    nvl(sum(amount), 0)
    into p_amount_billed
    from ap_invoice_lines_all
    where po_line_location_id = p_po_line_location_id;


EXCEPTION
    WHEN OTHERS then
	p_amount_ordered := 0;
	p_amount_received := 0;
	p_amount_billed := 0;

END get_shipment_amounts;



FUNCTION get_release_total
	(X_release_id   number) return number is
    	 X_release_total     number;

x_min_unit		NUMBER;
x_precision		NUMBER;
l_revision_num          number;


  BEGIN

    select revision_num
    into l_revision_num
    from po_releases_archive_all
    where po_release_id = X_release_id
    and latest_external_flag = 'Y';

    X_release_total := get_release_archive_total
    	(X_release_id,l_revision_num);

    RETURN (X_release_total);

  EXCEPTION
    WHEN OTHERS then
       x_release_total := 0;
       return(x_release_total);
  END get_release_total;



FUNCTION get_po_total_received (
	p_po_header_id		NUMBER,
	p_po_release_id		NUMBER,
	p_revision_num 		NUMBER )
RETURN NUMBER IS

x_total_received	NUMBER := 0;
x_min_unit		NUMBER;
x_precision		NUMBER;


  BEGIN

	SELECT  fc.minimum_accountable_unit,
		fc.precision
	INTO   	x_min_unit,
		x_precision
	FROM	fnd_currencies fc,
		po_headers_archive_all pha
	WHERE   fc.currency_code = pha.currency_code
	AND     pha.po_header_id = p_po_header_id
	AND     pha.latest_external_flag='Y';


    if (x_min_unit is null) then

      if (p_po_header_id is not null and p_po_release_id is null) then

	select SUM(round(DECODE(PLL.matching_basis,
                      'AMOUNT', NVL(PLL.amount_received, 0),
                      'QUANTITY', NVL(PLL.quantity_received, 0)*NVL(PLL.price_override, 0)),
                   x_precision))
	INTO  x_total_received
	FROM  po_line_locations_all pll
	WHERE pll.po_header_id = p_po_header_id
	AND   pll.po_release_id is null;

      elsif (p_po_release_id is not null) then

	select SUM(round(DECODE(PLL.matching_basis,
                      'AMOUNT', NVL(PLL.amount_received, 0),
                      'QUANTITY', NVL(PLL.quantity_received, 0)*NVL(PLL.price_override, 0)),
                   x_precision))
	INTO  x_total_received
	FROM  po_line_locations_all pll
	WHERE pll.po_release_id = p_po_release_id;

      end if;

    ELSE

      if (p_po_header_id is not null and p_po_release_id is null) then
	select SUM(round(DECODE(PLL.matching_basis,
                      'AMOUNT', NVL(PLL.amount_received, 0),
                      'QUANTITY', NVL(PLL.quantity_received, 0)*NVL(PLL.price_override, 0))
                  / x_min_unit) * x_min_unit)
	INTO   x_total_received
        FROM   po_line_locations_all pll
        WHERE  pll.po_header_id = p_po_header_id
	AND    pll.po_release_id is null;

      elsif (p_po_release_id is not null) then

	select SUM(round(DECODE(PLL.matching_basis,
                      'AMOUNT', NVL(PLL.amount_received, 0),
                      'QUANTITY', NVL(PLL.quantity_received, 0)*NVL(PLL.price_override, 0))
                  / x_min_unit) * x_min_unit)
	INTO  x_total_received
	FROM  po_line_locations_all pll
	WHERE pll.po_release_id = p_po_release_id;

      end if;
    END IF;

    return x_total_received;

EXCEPTION
    WHEN OTHERS then
	x_total_received := -1;
        return x_total_received;

END get_po_total_received;

--bug 9208080: adding new function to get total_quantity_received

FUNCTION get_po_total_quantity_received (
	p_po_header_id		NUMBER,
	p_po_release_id		NUMBER,
	p_revision_num 		NUMBER )
RETURN NUMBER IS

x_total_quantity_received	NUMBER := 0;

  BEGIN

      if (p_po_header_id is not null and p_po_release_id is null) then

	select SUM(NVL(PLL.quantity_received, 0))
	INTO  x_total_quantity_received
	FROM  po_line_locations_all pll
	WHERE pll.po_header_id = p_po_header_id
	AND   pll.po_release_id is null;

      elsif (p_po_release_id is not null) then

	select SUM(NVL(PLL.quantity_received, 0))
	INTO  x_total_quantity_received
	FROM  po_line_locations_all pll
	WHERE pll.po_release_id = p_po_release_id;

      end if;

    return x_total_quantity_received;

EXCEPTION
    WHEN OTHERS then
	x_total_quantity_received := -1;
        return x_total_quantity_received;

END get_po_total_quantity_received;

FUNCTION get_po_total_invoiced (
	p_po_header_id		NUMBER,
	p_po_release_id		NUMBER,
	p_revision_num 		NUMBER )
RETURN NUMBER IS

x_total_invoiced	NUMBER := 0;
x_min_unit		NUMBER;
x_precision		NUMBER;


  BEGIN

/*
	SELECT  fc.minimum_accountable_unit,
		fc.precision
	INTO   	x_min_unit,
		x_precision
	FROM	fnd_currencies fc,
		po_headers_archive_all pha
	WHERE   fc.currency_code = pha.currency_code
	AND     pha.po_header_id = p_po_header_id
	AND     pha.latest_external_flag='Y';


    if (x_min_unit is null) then

      if (p_po_header_id is not null and p_po_release_id is null) then
	select SUM(round(DECODE(PLL.matching_basis,
                      'AMOUNT', NVL(PLL.amount_billed, 0),
                      'QUANTITY', NVL(PLL.quantity_billed, 0)*NVL(PLL.price_override, 0)),
                   x_precision))
	INTO  x_total_invoiced
	FROM  po_line_locations_all pll
	WHERE pll.po_header_id = p_po_header_id
	AND   pll.po_release_id is null;

      elsif (p_po_release_id is not null) then
	select SUM(round(DECODE(PLL.matching_basis,
                      'AMOUNT', NVL(PLL.amount_billed, 0),
                      'QUANTITY', NVL(PLL.quantity_billed, 0)*NVL(PLL.price_override, 0)),
                   x_precision))
	INTO  x_total_invoiced
	FROM  po_line_locations_all pll
	WHERE pll.po_release_id = p_po_release_id;

      end if;

    ELSE

      if (p_po_header_id is not null and p_po_release_id is null) then
	select SUM(round(DECODE(PLL.matching_basis,
                      'AMOUNT', NVL(PLL.amount_billed, 0),
                      'QUANTITY', NVL(PLL.quantity_billed, 0)*NVL(PLL.price_override, 0))
                  / x_min_unit) * x_min_unit)
	INTO   x_total_invoiced
        FROM   po_line_locations_all pll
        WHERE  pll.po_header_id = p_po_header_id
	AND    pll.po_release_id is null;

      elsif (p_po_release_id is not null) then

	select SUM(round(DECODE(PLL.matching_basis,
                      'AMOUNT', NVL(PLL.amount_billed, 0),
                      'QUANTITY', NVL(PLL.quantity_billed, 0)*NVL(PLL.price_override, 0))
                  / x_min_unit) * x_min_unit)
	INTO  x_total_invoiced
	FROM  po_line_locations_all pll
	WHERE pll.po_release_id = p_po_release_id;

      end if;
    END IF;
*/

    select --sum(quantity_invoiced),
    nvl(sum(amount), 0)
    into x_total_invoiced
    from ap_invoice_lines_all
    where (po_header_id = p_po_header_id and po_release_id = p_po_release_id and p_po_release_id is not null)
    or (po_header_id = p_po_header_id and po_release_id is null and p_po_release_id is null);


    return x_total_invoiced;

EXCEPTION
    WHEN OTHERS then
        raise;

END get_po_total_invoiced;

--bug 9208080: adding new function to get total_quantity_invoiced

FUNCTION get_po_total_quantity_invoiced (
	p_po_header_id		NUMBER,
	p_po_release_id		NUMBER,
	p_revision_num 		NUMBER )
RETURN NUMBER IS

x_total_quantity_invoiced	NUMBER := 0;

  BEGIN

    select nvl(sum(quantity_invoiced), 0)
    --nvl(sum(amount), 0)
    into x_total_quantity_invoiced
    from ap_invoice_lines_all
    where (po_header_id = p_po_header_id and po_release_id = p_po_release_id and p_po_release_id is not null)
    or (po_header_id = p_po_header_id and po_release_id is null and p_po_release_id is null);

    return x_total_quantity_invoiced;

EXCEPTION
    WHEN OTHERS then
        raise;

END get_po_total_quantity_invoiced;

FUNCTION get_po_payment_status (p_po_header_id 	NUMBER,
				p_po_release_id	NUMBER )
RETURN VARCHAR2 IS

  l_pay_status_flag VARCHAR2(1) := null;
  l_inv_paid_flag VARCHAR2(1) := null;

  CURSOR l_po_inv_paid_csr IS
      select NVL(AI.payment_status_flag, 'N')
        from AP_INVOICES_ALL AI,
             AP_INVOICE_DISTRIBUTIONS_ALL AID,
             PO_DISTRIBUTIONS_ALL POD
       where AI.invoice_id = AID.invoice_id
         and AID.po_distribution_id  = POD.po_distribution_id
         and POD.po_header_id = p_po_header_id
         and POD.po_release_id is null
	 and AI.CANCELLED_DATE is null --bug 9395048
	  and AID.reversal_flag <> 'Y'; --Bug#11906141

  CURSOR l_rel_inv_paid_csr IS
      select NVL(AI.payment_status_flag, 'N')
        from AP_INVOICES_ALL AI,
             AP_INVOICE_DISTRIBUTIONS_ALL AID,
             PO_DISTRIBUTIONS_ALL POD
       where AI.invoice_id = AID.invoice_id
         and AID.po_distribution_id  = POD.po_distribution_id
         and POD.po_header_id = p_po_header_id
         and POD.po_release_id = p_po_release_id
	 and AI.CANCELLED_DATE is null --bug 9395048
	  and AID.reversal_flag <> 'Y'; --Bug#11906141

BEGIN

  IF (p_po_release_id is null) THEN
    OPEN l_po_inv_paid_csr;
      LOOP
        FETCH l_po_inv_paid_csr INTO l_inv_paid_flag;
        EXIT WHEN l_po_inv_paid_csr%NOTFOUND;

        /* If any invoice is partially paid, then payment status is
           partially paid. */
        IF (l_inv_paid_flag = 'P') THEN
          l_pay_status_flag := 'P';
          EXIT;
        END IF;

        /* Assign the first rows value to the return flag. */
        IF (l_pay_status_flag is NULL) THEN
          l_pay_status_flag := l_inv_paid_flag;

        ELSIF ((l_pay_status_flag = 'N' and l_inv_paid_flag = 'Y') or
               (l_pay_status_flag = 'Y' and l_inv_paid_flag = 'N')) THEN
          l_pay_status_flag := 'P';
          EXIT;

        END IF;

      END LOOP;
    CLOSE l_po_inv_paid_csr;

  ELSE
    OPEN l_rel_inv_paid_csr;
      LOOP
        FETCH l_rel_inv_paid_csr INTO l_inv_paid_flag;
        EXIT WHEN l_rel_inv_paid_csr%NOTFOUND;

        /* If any invoice is partially paid, then payment status is
           partially paid. */
        IF (l_inv_paid_flag = 'P') THEN
          l_pay_status_flag := 'P';
          EXIT;
        END IF;

        /* Assign the first rows value to the return flag. */
        IF (l_pay_status_flag is NULL) THEN
          l_pay_status_flag := l_inv_paid_flag;

        ELSIF ((l_pay_status_flag = 'N' and l_inv_paid_flag = 'Y') or
               (l_pay_status_flag = 'Y' and l_inv_paid_flag = 'N')) THEN
          l_pay_status_flag := 'P';
          EXIT;

        END IF;

      END LOOP;
    CLOSE l_rel_inv_paid_csr;

  END IF;

  return NVL(l_pay_status_flag, 'N');

EXCEPTION
    WHEN OTHERS then
        return 'F';

END get_po_payment_status;



FUNCTION get_ship_payment_status (p_line_location_id 	NUMBER)
RETURN VARCHAR2 IS

  l_pay_status_flag VARCHAR2(1) := null;
  l_inv_paid_flag VARCHAR2(1) := 'N';

/*
  CURSOR l_inv_paid_csr IS
      select NVL(AI.payment_status_flag, 'N')
        from AP_INVOICES_ALL AI,
             AP_INVOICE_DISTRIBUTIONS_ALL AID,
             PO_DISTRIBUTIONS_ALL POD
       where AI.invoice_id = AID.invoice_id
         and AID.po_distribution_id  = POD.po_distribution_id
         and POD.line_location_id = p_line_location_id;
*/
  CURSOR l_inv_paid_csr IS
      select NVL(AI.payment_status_flag, 'N')
        from AP_INVOICES_ALL AI,
             AP_INVOICE_LINES_ALL AIL
       where AI.invoice_id = AIL.invoice_id
         and AIL.po_line_location_id = p_line_location_id;

BEGIN

    OPEN l_inv_paid_csr;
      LOOP
        FETCH l_inv_paid_csr INTO l_inv_paid_flag;
        EXIT WHEN l_inv_paid_csr%NOTFOUND;

        /* If any invoice is partially paid, then payment status is 'P'. */
        IF (l_inv_paid_flag = 'P') THEN
          l_pay_status_flag := 'P';
          EXIT;
        END IF;

        /* Assign the first rows value to the return flag. */
        IF (l_pay_status_flag is NULL) THEN
          l_pay_status_flag := l_inv_paid_flag;

        ELSIF ((l_pay_status_flag = 'N' and l_inv_paid_flag = 'Y') OR
               (l_pay_status_flag = 'Y' and l_inv_paid_flag = 'N')) THEN
          l_pay_status_flag := 'P';
          EXIT;

        END IF;

      END LOOP;
    CLOSE l_inv_paid_csr;

    return l_pay_status_flag;

EXCEPTION
    WHEN OTHERS then
        return 'F';

END get_ship_payment_status;

END POS_TOTALS_PO_SV;

/
