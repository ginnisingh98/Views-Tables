--------------------------------------------------------
--  DDL for Package Body PO_TOTALS_PO_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_TOTALS_PO_SV" as
/* $Header: ICXPOTOB.pls 115.1 2001/05/02 21:08:02 pkm ship     $ */

  FUNCTION get_po_total
	(X_header_id   number) return number is
    	 X_po_total     number;


x_min_unit		NUMBER;
x_precision		NUMBER;

  BEGIN

  SELECT nvl(fc.minimum_accountable_unit,1),
	 fc.precision
  INTO   x_min_unit,
         x_precision
  FROM   fnd_currencies			fc,
	 po_headers			ph
  WHERE  ph.po_header_id = X_header_id
  AND	 fc.currency_code   = ph.currency_code;



    SELECT round(((nvl(SUM((quantity - quantity_cancelled) * price_override),0)
			* x_min_unit) / x_min_unit),
                 x_precision)
	   into X_po_total
    FROM   po_line_locations
    WHERE  po_header_id = X_header_id
    AND    shipment_type IN ('STANDARD','PLANNED','BLANKET');


    RETURN (X_po_total);

  EXCEPTION
    WHEN OTHERS then
       x_po_total := 0;
       return(x_po_total);
  END get_po_total;


  FUNCTION get_po_archive_total
	(X_header_id   number,
	 X_revision_num number) return number is
    	 X_po_total     number;


x_min_unit		NUMBER;
x_precision		NUMBER;

  BEGIN

  SELECT nvl(fc.minimum_accountable_unit,1),
	 fc.precision
  INTO   x_min_unit,
         x_precision
  FROM   fnd_currencies			fc,
	 po_headers_archive              pha
  WHERE  pha.po_header_id = X_header_id
  AND	 pha.revision_num = X_revision_num
  AND	 fc.currency_code   = pha.currency_code;



    SELECT round(((nvl(SUM((quantity - quantity_cancelled) * price_override),0)
			* x_min_unit) / x_min_unit),
                 x_precision)
	   into X_po_total
    FROM   po_line_locations_archive plla1
    WHERE  po_header_id = X_header_id
    AND    shipment_type IN ('STANDARD','PLANNED','BLANKET')
    AND    revision_num = (
		SELECT
			max( plla2.revision_num )
		FROM
			po_line_locations_archive plla2
		WHERE
			plla2.revision_num <= X_revision_num
		AND	plla2.line_location_id = plla1.line_location_id )
    ;


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

  BEGIN

-- Bug# 1666579 Added rownum < 2 to avoid too many rows error.
  SELECT nvl(fc.minimum_accountable_unit,1),
	 fc.precision
  INTO   x_min_unit,
         x_precision
  FROM   fnd_currencies			fc,
	 po_headers_archive              pha,
	 po_releases_archive		pra
  WHERE  pha.po_header_id = pra.po_header_id
  AND	 pra.po_release_id = X_release_id
  AND	 pha.revision_num = X_revision_num
  AND	 fc.currency_code   = pha.currency_code
  AND    rownum < 2 ;



    SELECT round(((nvl(SUM((quantity - quantity_cancelled) * price_override),0)
			* x_min_unit) / x_min_unit),
                 x_precision)
	   into X_po_total
    FROM   po_line_locations_archive plla1
    WHERE  po_release_id = X_release_id
    AND    shipment_type IN ('STANDARD','PLANNED','BLANKET')
    AND    revision_num = (
		SELECT
			max( plla2.revision_num )
		FROM
			po_line_locations_archive plla2
		WHERE
			plla2.revision_num <= X_revision_num
		AND	plla2.line_location_id = plla1.line_location_id )
    ;


    RETURN (X_po_total);

  EXCEPTION
    WHEN OTHERS then
       x_po_total := 0;
       return (X_po_total);

  END GET_RELEASE_ARCHIVE_TOTAL;


  FUNCTION get_release_total
	(X_release_id   number) return number is
    	 X_release_total     number;

x_min_unit		NUMBER;
x_precision		NUMBER;

  BEGIN

  SELECT nvl(fc.minimum_accountable_unit,1),
	 fc.precision
  INTO   x_min_unit,
         x_precision
  FROM   fnd_currencies			fc,
	 po_headers			ph,
	 po_releases			pr
  WHERE  ph.po_header_id = pr.po_header_id
  AND	 pr.po_release_id = X_release_id
  AND	 fc.currency_code   = ph.currency_code;


    SELECT round(((nvl(SUM((quantity - quantity_cancelled) * price_override),0)
			* x_min_unit) / x_min_unit),
                 x_precision)
	   into X_release_total
    FROM   po_line_locations
    WHERE  po_release_id = X_release_id;


    RETURN (X_release_total);

  EXCEPTION
    WHEN OTHERS then
       x_release_total := 0;
       return(x_release_total);
  END get_release_total;



END PO_TOTALS_PO_SV;

/
