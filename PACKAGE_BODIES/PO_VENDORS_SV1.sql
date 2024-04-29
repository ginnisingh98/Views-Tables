--------------------------------------------------------
--  DDL for Package Body PO_VENDORS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VENDORS_SV1" AS
/* $Header: POXPIVDB.pls 115.2 2002/11/23 02:50:28 sbull ship $ */

/*================================================================

  FUNCTION NAME: 	val_vendor_info()

==================================================================*/
 FUNCTION val_vendor_info(X_vendor_id         IN  NUMBER,
			  X_vendor_site_type  IN  VARCHAR2,
			  X_vendor_site_id    IN  NUMBER,
			  X_vendor_contact_id IN  NUMBER,
			  X_error_code        IN OUT NOCOPY VARCHAR2)
 RETURN BOOLEAN IS

   x_temp_1     binary_integer;
   x_temp_2     binary_integer;
   x_temp_3     binary_integer;
   x_temp_4     binary_integer;
   x_progress   varchar2(3) := null;

 BEGIN
   x_progress := '010';

   /* make sure that the vendor_id is valid in po_suppliers_val_v
      view */

    SELECT count(*)
    INTO   x_temp_1
    FROM   po_suppliers_val_v
    WHERE  vendor_id = X_vendor_id;

   IF x_temp_1 = 0 THEN
      X_error_code := 'PO_PDOI_INVALID_VENDOR';
      RETURN FALSE;
   END IF;

   IF (X_vendor_id IS NOT NULL) AND (X_vendor_site_id IS NOT NULL) THEN
      /* make sure the vendor_site_id is valid */

        IF (X_vendor_site_type NOT IN ('RFQ SITE')) THEN
           x_progress := '020';
           SELECT  count(*)
	    INTO   x_temp_2
            FROM    po_supplier_po_sites_val_v
            WHERE   vendor_id  = X_vendor_id
            AND     vendor_site_id = X_vendor_site_id;

           IF x_temp_2 = 0 THEN
              X_error_code := 'PO_PDOI_INVALID_VENDOR_SITE';
              RETURN FALSE;
           END IF;

        ELSE  /* vendor_site_type = 'RFQ SITE' */
           x_progress := '030';
           SELECT  count(*)
	    INTO   x_temp_3
            FROM    po_supplier_sites_val_v
            WHERE   vendor_id  = X_vendor_id
            AND     vendor_site_id = X_vendor_site_id;

           IF x_temp_3 = 0 THEN
              X_error_code := 'PO_PDOI_INVALID_VENDOR_SITE';
              RETURN FALSE;
           END IF;
	END IF;
   END IF;

   IF (X_vendor_id IS NOT NULL) AND (X_vendor_site_id is not null) AND
      (X_vendor_contact_id IS NOT NULL) THEN
      x_progress := '040';

      /* make sure the vendor_contact_id is valid */
       SELECT  count(*)
       INTO    x_temp_4
       FROM    po_vendor_contacts
       WHERE   vendor_site_id  = X_vendor_site_id
       AND     vendor_contact_id = X_vendor_contact_id;

       IF x_temp_4 = 0 THEN
          X_error_code := 'PO_PDOI_INVALID_VDR_CNTCT';
          RETURN FALSE;
       END IF;
   END IF;

   RETURN TRUE;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('val_vendor_info', x_progress,sqlcode);
        raise;
 END val_vendor_info;

/*==============================================================
  FUNCTION NAME : derive_vendor_id
===============================================================*/

FUNCTION  derive_vendor_id(X_vendor_name  IN VARCHAR2,
                           X_vendor_num   IN VARCHAR2)
                           return NUMBER IS

     X_progress       varchar2(3)     := NULL;
     X_vendor_name_v  number        := NULL;
     X_vendor_count   binary_integer := 0;

BEGIN

   X_progress := '010';
/*  We will select the vendor id from the po_suppliers_val_v view
    based on the input vendor name.                             */

   SELECT COUNT(*)
     INTO X_vendor_count
     FROM po_suppliers_val_v
    WHERE (vendor_name = X_vendor_name
           OR
           segment1 = X_vendor_num);

   IF X_vendor_count = 1 THEN
      X_progress := '020';

      SELECT  vendor_id
        INTO  X_vendor_name_v
        FROM  po_suppliers_val_v
       WHERE  (vendor_name = X_vendor_name
               OR
               segment1 = X_vendor_num);

      RETURN X_vendor_name_v;

   ELSIF (X_vendor_count = 0) OR (X_vendor_count > 1) THEN
       RETURN NULL;
   END IF;

EXCEPTION
   WHEN no_data_found THEN
        RETURN NULL;
   WHEN others THEN
        po_message_s.sql_error('derive_vendor_id',X_progress, sqlcode);
        raise;

END derive_vendor_id;

END PO_VENDORS_SV1;

/
