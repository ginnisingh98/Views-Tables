--------------------------------------------------------
--  DDL for Package Body PO_LINE_LOCATIONS_PKG_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINE_LOCATIONS_PKG_S3" as
/* $Header: POXP4PSB.pls 115.4 2004/03/09 23:28:47 dreddy ship $ */

/*========================================================================
** PROCEDURE NAME : check_unique
** DESCRIPTION    : We need either the po_line_id OR po_release_id
**                  argument passed in. Since both are the same data type
**                  cannot use function overloading unless we to_number()
**                  one of them. For now please pass in a NULL or 0 if
**                  either of them is NOT relevant.
** ======================================================================*/


PROCEDURE check_unique (X_rowid		      VARCHAR2,
			X_shipment_num	      VARCHAR2,
                        X_po_line_id           NUMBER,
			X_po_release_id        NUMBER,
                        X_shipment_type       VARCHAR2) IS

  X_progress VARCHAR2(3) := NULL;
  dummy	   NUMBER;

BEGIN

  X_progress := '010';

  if ((X_shipment_type = 'SCHEDULED') OR
      (X_shipment_type = 'BLANKET')) then

  /* This is checking uniques for Release Shipments of
  ** both the SCHEDULED and BLANKET types */

  SELECT  1
  INTO    dummy
  FROM    DUAL
  WHERE  not exists (SELECT 1
		     FROM   po_line_locations
		     WHERE  po_release_id = X_po_release_id
                     AND    shipment_type = X_shipment_type
                     AND    shipment_num  = X_shipment_num
		     AND    ((X_rowid is null) or
                             (X_rowid <> rowid)));

 elsif ((X_shipment_type = 'STANDARD') OR
        (X_shipment_type = 'PLANNED')) then


 /* This is checking the uniques for Purchase Order Shipments
 ** of STANDARD AND PLANNED POS */

  SELECT  1
  INTO    dummy
  FROM    DUAL
  WHERE  not exists (SELECT 1
		     FROM   po_line_locations
                     WHERE  po_line_id      = X_po_line_id
                     AND    shipment_type in ('STANDARD','PLANNED')
                     AND    shipment_num    = X_shipment_num
                     AND   ((X_rowid IS NULL)
                            OR (X_rowid <> rowid)));

 elsif (X_shipment_type IN ('RFQ', 'QUOTATION')) then


 /* This is checking the uniques for RFQ or Quotation Shipments
 */

  SELECT  1
  INTO    dummy
  FROM    DUAL
  WHERE  not exists (SELECT 1
		     FROM   po_line_locations
                     WHERE  po_line_id      = X_po_line_id
                     AND    shipment_type   = X_shipment_type
                     AND    shipment_num    = X_shipment_num
                     AND   ((X_rowid IS NULL)
                            OR (X_rowid <> rowid)));

 elsif (X_shipment_type = 'PRICE BREAK') then

  /* This is checking uniques for PRICE BREAKS */

   SELECT  1
   INTO    dummy
   FROM    DUAL
   WHERE  not exists (SELECT 1
		      FROM   po_line_locations
                      WHERE  po_line_id      = X_po_line_id
                      AND    shipment_type   = 'PRICE BREAK'
                      AND    shipment_num    = X_shipment_num
                      AND   ((X_rowid          <> rowid)
                      OR     (X_rowid IS NULL)));
 end if;


exception
  when no_data_found then
    po_message_s.app_error('PO_PO_ENTER_UNIQUE_SHIP_NUM');
  when others then
    po_message_s.sql_error('check_uniue',X_progress,sqlcode);

end check_unique;

/*===========================================================================

  FUNCTION NAME:	check unique
                        Bug 3494974
===========================================================================*/
FUNCTION check_unique (	X_shipment_num	      VARCHAR2,
                        X_po_line_id           NUMBER,
                        X_shipment_type       VARCHAR2)
RETURN BOOLEAN IS

 X_progress VARCHAR2(3) := NULL;
 dummy	   NUMBER;

BEGIN

  X_progress := '010';

  SELECT  1
  INTO    dummy
  FROM    DUAL
  WHERE  not exists (SELECT 1
		     FROM   po_line_locations
                     WHERE  po_line_id      = X_po_line_id
                     AND    shipment_type   = X_shipment_type
                     AND    shipment_num    = X_shipment_num);


    Return TRUE;

exception
  when no_data_found then
    Return FALSE;
  when others then
    Return FALSE;

end check_unique;

/*===========================================================================

  FUNCTION NAME:	get_max_shipment_num

===========================================================================*/

 FUNCTION get_max_shipment_num
	(X_po_line_id   NUMBER,
         X_po_release_id NUMBER,
         X_shipment_type VARCHAR2) return number is

 x_max_shipment_num NUMBER;
 X_Progress   varchar2(3) := '';

 BEGIN
        X_Progress := '010';

        if ((X_shipment_type = 'STANDARD') OR
            (X_shipment_type = 'PLANNED')) then
           SELECT nvl(max(shipment_num),0)
           INTO   X_max_shipment_num
           FROM   po_line_locations
           WHERE  po_line_id   = X_po_line_id
           AND    shipment_type IN ('STANDARD','PLANNED');

	elsif (X_shipment_type IN ('RFQ', 'QUOTATION')) then
           SELECT nvl(max(shipment_num),0)
           INTO   X_max_shipment_num
           FROM   po_line_locations
           WHERE  po_line_id    = X_po_line_id
           AND    shipment_type = X_shipment_type;

        elsif (X_shipment_type = 'PRICE BREAK') then
           SELECT nvl(max(shipment_num),0)
           INTO   X_max_shipment_num
           FROM   po_line_locations
           WHERE  po_line_id    = X_po_line_id
           AND    shipment_type = 'PRICE BREAK';

       elsif ((X_shipment_type = 'SCHEDULED') OR
              (X_shipment_type = 'BLANKET')) then

	   SELECT nvl(max(shipment_num),0)
           INTO   X_max_shipment_num
           FROM   po_line_locations
           WHERE  po_release_id   = X_po_release_id ;

       end if;

   return(x_max_shipment_num);

   EXCEPTION
   WHEN OTHERS THEN
      return(0);
      RAISE;

 END get_max_shipment_num;

/*========================================================
**  PROCEDURE NAME : select_summary()
**=======================================================*/


 function   select_summary(X_po_release_id IN number)
             return number is

  X_rel_total  number;
  X_progress varchar2(3) := '';

begin
         X_Progress := '010';

/* Bug# 1499773: kagarwal
** Modified the following SQL to incorporate quantity_cancelled since
** Total Released in Enter Releases Form is showing wrong value
** when it has cancelled shipments.
*/

         select nvl(sum((nvl(quantity,0)-nvl(quantity_cancelled,0))*nvl(price_override,0)),0)
         into   X_rel_total
         from   po_line_locations
         where  po_release_id = X_po_release_id;

         return(X_rel_total);

exception
         when no_data_found then
              null;
         when others then
             -- po_message_s.sql_error('select_summary',X_Progress,sqlcode);
              raise;
end select_summary;

END PO_LINE_LOCATIONS_PKG_S3;

/
