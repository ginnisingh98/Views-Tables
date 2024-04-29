--------------------------------------------------------
--  DDL for Package Body PO_ITEMS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ITEMS_SV1" AS
/* $Header: POXPISIB.pls 120.0.12000000.1 2007/01/16 23:04:37 appldev ship $ */

/*================================================================

  FUNCTION NAME: 	val_item_id()

==================================================================*/
 FUNCTION val_item_id(x_item_id                IN NUMBER,
                      x_organization_id        IN NUMBER,
                      x_outside_operation_flag IN VARCHAR2) RETURN BOOLEAN
 IS

   x_progress    varchar2(3) := null;
   x_temp        binary_integer := 0;

 BEGIN
   x_progress := '010';

   /* check to see if there are x_item_id exists in mtl_system_items table */
   SELECT count(*)
     INTO x_temp
     FROM mtl_system_items
    WHERE inventory_item_id = x_item_id
      AND organization_id = x_organization_id
      AND enabled_flag = 'Y'
      AND purchasing_item_flag = 'Y'
      AND purchasing_enabled_flag = 'Y'
      AND outside_operation_flag = x_outside_operation_flag
      AND TRUNC(nvl(start_date_active, sysdate)) <= TRUNC(sysdate)
      AND TRUNC(nvl(end_date_active, sysdate)) >= TRUNC(sysdate);

   IF x_temp = 0 THEN
      RETURN FALSE;   /* validation fails */
   ELSE
      RETURN TRUE;    /* validation succeeds */
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error
        ('val_inventory_item_id', x_progress, sqlcode);
      raise;
 END val_item_id;

/*================================================================

  FUNCTION NAME: 	derive_item_id()

==================================================================*/
FUNCTION  derive_item_id(X_item_number         IN VARCHAR2,
                         X_vendor_product_num  IN VARCHAR2,
                         X_vendor_id           IN NUMBER,
                         X_organization_id     IN VARCHAR2,
                         X_error_code          IN OUT NOCOPY VARCHAR2)
return NUMBER IS

  X_progress            varchar2(3)     := NULL;
  X_inventory_item_id_v number        := NULL;
  x_temp                binary_integer;

BEGIN

   X_progress := '010';
   IF (X_item_number is not null) THEN
    /* check to see if there are any inventory_item_id exists */

      SELECT inventory_item_id
        INTO X_inventory_item_id_v
        FROM mtl_system_items_kfv
       WHERE concatenated_segments = X_item_number
         AND organization_id = X_organization_id;

   ELSIF (X_vendor_product_num is not null) THEN
         /* item_number is null */
      X_progress := '020';
      BEGIN
         SELECT distinct b.item_id
           INTO X_inventory_item_id_v
           FROM po_headers a, po_lines b
          WHERE a.po_header_id = b.po_header_id
            AND b.vendor_product_num = X_vendor_product_num
            AND a.vendor_id = X_vendor_id
	    AND b.item_id is not NULL;
      EXCEPTION
         WHEN no_data_found THEN
              RETURN NULL;
         WHEN too_many_rows THEN
              X_error_code := 'PO_PDOI_MULT_BUYER_PART';
              RETURN NULL;
      END;
   END IF;

 RETURN X_inventory_item_id_v;

EXCEPTION
   WHEN no_data_found THEN
        RETURN NULL;
   When others then
     po_message_s.sql_error('derive_item_id',X_progress, sqlcode);
     raise;

END derive_item_id;

END PO_ITEMS_SV1;

/
