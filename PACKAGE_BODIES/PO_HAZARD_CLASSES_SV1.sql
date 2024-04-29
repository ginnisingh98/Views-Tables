--------------------------------------------------------
--  DDL for Package Body PO_HAZARD_CLASSES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HAZARD_CLASSES_SV1" AS
/* $Header: POXPIHCB.pls 120.0.12000000.1 2007/07/27 09:07:04 grohit noship $ */

/*================================================================

  FUNCTION NAME: 	val_hazard_class_id()

==================================================================*/
 FUNCTION val_hazard_class_id(x_hazard_class_id IN NUMBER) RETURN BOOLEAN
 IS

   x_progress    varchar2(3) := null;
   x_temp        binary_integer := 0;

 BEGIN
   x_progress := '010';

   /* check to see if there are x_hazard_class_id exists in
      po_hazard_classes_val_v table */

   SELECT count(*)
     INTO x_temp
     FROM po_hazard_classes_val_v
    WHERE hazard_class_id = x_hazard_class_id;

   IF x_temp = 0 THEN
      RETURN FALSE;       /* validation fails */
   ELSE
      RETURN TRUE;        /* validation succeeds */
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error
        ('val_hazard_class_id', x_progress, sqlcode);
        raise;
 END val_hazard_class_id;


/*================================================================

  FUNCTION NAME: 	derive_hazard_class_id()

==================================================================*/
FUNCTION  derive_hazard_class_id(X_hazard_class IN VARCHAR2)
                               return NUMBER IS

X_progress       varchar2(3)     := NULL;
X_hazard_class_id_v number        := NULL;

BEGIN

 X_progress := '010';

  /* get the hazardclass_id from po_hazard_class_val_v table
      based on hazard_class which is provided from input para. */

 SELECT hazard_class_id
 INTO X_hazard_class_id_v
 FROM po_hazard_classes_val_v
 WHERE hazard_class = X_hazard_class;

 RETURN X_hazard_class_id_v;

EXCEPTION

   When no_data_found then
     RETURN NULL;
   When others then
     po_message_s.sql_error('derive_hazard_class_id',X_progress, sqlcode);
   raise;

END derive_hazard_class_id;
END PO_HAZARD_CLASSES_SV1;

/
