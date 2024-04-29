--------------------------------------------------------
--  DDL for Package Body PO_LINE_LOCATIONS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINE_LOCATIONS_SV1" AS
/* $Header: POXPILLB.pls 120.0 2005/06/02 00:30:35 appldev noship $ */


/*================================================================

  FUNCTION NAME: 	val_shipment_num()

==================================================================*/
 FUNCTION val_shipment_num(x_shipment_num   IN NUMBER,
                           x_shipment_type  IN VARCHAR2,
                           x_po_header_id   IN NUMBER,
                           x_po_line_id     IN NUMBER,
                           x_rowid          IN VARCHAR2) RETURN BOOLEAN
 IS

   x_progress   varchar2(3) := null;
   x_temp       binary_integer := 0;
 BEGIN
   x_progress := '010';

   /* check to see if there are any non_unique shipment_num exists
      in po_shipments_all_v table */
   --Bug4040677 Start
   --Removed "AND shipment_type = 'PRICE BREAK'" clause. This clause was overriding
   --the clause "shipment_type = x_shipment_type" and the code was breaking for QUOTATIONS.
   SELECT count(*)
     INTO x_temp
     FROM po_line_locations
    WHERE shipment_num = x_shipment_num
      AND shipment_type = x_shipment_type
      AND po_header_id = x_po_header_id
      AND po_line_id = x_po_line_id
      AND (rowid <> x_rowid OR x_rowid is null);
   --Bug4040677 End

   IF x_temp = 0 THEN
      RETURN TRUE;    /* shipment_num is unique */
   ELSE
      RETURN FALSE;    /* shipment_num is not unique */
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error
        ('val_shipment_num', x_progress, sqlcode);
         raise;
 END val_shipment_num;

/*================================================================

  FUNCTION NAME: 	val_shipment_type()

==================================================================*/
 FUNCTION val_shipment_type(x_shipment_type  IN VARCHAR2,
                            x_lookup_code    IN VARCHAR2) RETURN BOOLEAN
 IS

   x_progress   varchar2(3) := null;

 BEGIN
   x_progress := '010';
-- we only support shipment_type of 'QUOTATION' and 'BLANKET'

   IF x_lookup_code = 'QUOTATION' THEN
      IF (x_shipment_type = 'QUOTATION') THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   ELSIF x_lookup_code = 'BLANKET' THEN
      IF (x_shipment_type = 'PRICE BREAK') THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
-- VRANKAIY
   ELSIF x_lookup_code = 'STANDARD' THEN
      RETURN TRUE;
   END IF;
 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('val_shipment_type', x_progress,sqlcode);
      raise;
 END val_shipment_type;

/*================================================================

  FUNCTION NAME: 	derive_line_location_id()

==================================================================*/
 FUNCTION  derive_line_location_id(X_po_header_id IN NUMBER,
                                   X_po_line_id   IN NUMBER,
                                   X_shipment_num IN NUMBER)
 return NUMBER IS

   X_progress           varchar2(3)     := NULL;
   X_line_location_id_v number           := NULL;

 BEGIN

   X_progress := '010';

   /* derive the line_location_id from po_line_locations based on
      po_header_id, po_line_id and shipment_num which was provided
      from the input parameter and shipment type of PRICE BREAK */
   --Bug4040677 Start
   --This SQL only considers BPAs. Added shipment_type clauses for SPO and QUOTATIONS.
   --Its OK because a line will only have one type of shipments listed.

   SELECT line_location_id
     INTO X_line_location_id_v
     FROM po_line_locations
    WHERE po_header_id = X_po_header_id
      AND po_line_id = X_po_line_id
      AND shipment_num = X_shipment_num
      AND shipment_type in ('PRICE BREAK','QUOTATION', 'STANDARD');
  --Bug4040677 End

   RETURN X_line_location_id_v;

 EXCEPTION
   When no_data_found then
        RETURN NULL;
   When others then
        po_message_s.sql_error('derive_line_location_id',X_progress, sqlcode);
        raise;
 END derive_line_location_id;

/*===============================================================

    FUNCTION NAME : derive_location_id()

===============================================================*/

FUNCTION  derive_location_id(X_location_code  IN VARCHAR2,
                             X_location_usage IN VARCHAR2)
return NUMBER IS

    X_progress       varchar2(3)     := NULL;
    X_location_id_v  number      := NULL;

BEGIN

    X_progress := '010';

    /* get the location_id from po_locations_val_v view based on the
       location_code and location_usages which are provided from
       input parameter */

    SELECT location_id
    INTO   X_location_id_v
    FROM   po_locations_val_v
    WHERE  location_code =  X_location_code
    AND    DECODE(X_location_usage,
                  'SHIP_TO', NVL(ship_to_site_flag,'N'),
                  'BILL_TO', NVL(bill_to_site_flag,'N'),
                  'RECEIVING',NVL(receiving_site_flag,'N'),
                  'OFFICE',NVL(OFFICE_SITE_FLAG,'N')) = 'Y';

    RETURN X_location_id_v;

EXCEPTION
   WHEN NO_DATA_FOUND then
        RETURN NULL;
   WHEN OTHERS THEN
        po_message_s.sql_error('derive_location_id',X_progress, sqlcode);
        RAISE;

END derive_location_id;
/*==================================================================

  FUNCTION NAME: 	val_location_id()

==================================================================*/
 FUNCTION val_location_id(X_location_id     IN NUMBER,
		          X_location_type   IN VARCHAR2)
 RETURN BOOLEAN
 IS

   x_progress   varchar2(3) := null;
   x_temp       binary_integer := 0;

 BEGIN
   x_progress := '010';

   /*** make sure location_id is a valid and active location based
   on the location type. ***/

   SELECT count(*)
     INTO x_temp
     FROM po_locations_val_v
    WHERE location_id = X_location_id
    AND   DECODE(X_location_type,
                 'SHIP_TO', NVL(ship_to_site_flag, 'N'),
                 'BILL_TO', NVL(bill_to_site_flag, 'N'),
                 'RECEIVING', NVL(receiving_site_flag, 'N'),
                 'OFFICE',  NVL(office_site_flag, 'N') )
          = 'Y';

   IF x_temp = 0 THEN
      RETURN FALSE;    /* validation fails */
   ELSE
      RETURN TRUE;     /* validation succeeds */
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('val_location_id', x_progress,sqlcode);
        raise;
 END val_location_id;


END PO_LINE_LOCATIONS_SV1;

/
