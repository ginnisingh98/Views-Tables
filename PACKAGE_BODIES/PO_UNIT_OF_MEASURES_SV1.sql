--------------------------------------------------------
--  DDL for Package Body PO_UNIT_OF_MEASURES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_UNIT_OF_MEASURES_SV1" AS
/* $Header: POXPIUMB.pls 120.0.12000000.1 2007/07/27 08:29:50 grohit noship $ */

/*================================================================

  FUNCTION NAME: 	val_unit_of_measure()

==================================================================*/
 FUNCTION val_unit_of_measure( x_unit_of_measure IN VARCHAR2,
    			       x_uom_code        IN VARCHAR2) RETURN BOOLEAN
 IS

   x_progress   varchar2(3) := null;
   x_temp       binary_integer := 0;

 BEGIN
   x_progress := '010';
   IF (X_unit_of_measure IS NULL AND
       X_uom_code IS NULL) THEN

      RETURN FALSE;     /* validation fails*/
			/* must either specify uom_code or unit_of_measure */
   END IF;

   /* check to see if x_uom_code is valid in po_units_of_measure_val_v */
   x_progress := '020';

   SELECT count(*)
     INTO x_temp
     FROM po_units_of_measure_val_v
    WHERE (uom_code = x_uom_code
		OR
	   X_uom_code IS NULL)
       AND (unit_of_measure = X_unit_of_measure
		OR
	   X_unit_of_measure IS NULL);

   IF x_temp = 1 THEN
      RETURN TRUE;    /* validation succeeds */
   ELSE
      RETURN FALSE;     /* validation fails*/
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error
        ('val_unit_of_measure', x_progress, sqlcode);
      raise;
 END val_unit_of_measure;

/*================================================================

  FUNCTION NAME: 	val_item_unit_of_measure ()

==================================================================*/
 FUNCTION val_item_unit_of_measure(x_item_unit_of_measure IN VARCHAR2,
                            x_item_id          IN NUMBER,
                            x_organization_id  IN NUMBER) RETURN BOOLEAN
 IS

   x_progress   varchar2(3) := null;
   x_temp       binary_integer := 0;

 BEGIN
   /* check to see if x_item_unit_of_measure is valid in mtl_item_uoms_view */
   x_progress := '010';

   SELECT count(*)
     INTO x_temp
     FROM mtl_item_uoms_view
    WHERE unit_of_measure = x_item_unit_of_measure
      AND inventory_item_id = x_item_id
      AND organization_id = x_organization_id;

   IF x_temp = 0 THEN
      RETURN FALSE;   /* validation fails */
   ELSE
      RETURN TRUE;    /* validation succeeds */
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('val_item_uom_code', x_progress,sqlcode);
      raise;
 END val_item_unit_of_measure ;

/*================================================================

  FUNCTION NAME: 	derive_unit_of_measure()

==================================================================*/
FUNCTION  derive_unit_of_measure (X_uom_code  IN VARCHAR2)
return VARCHAR2 IS

  X_progress             varchar2(3)     := NULL;
  X_unit_of_measure_v    varchar2(25);

BEGIN

 X_progress := '010';

  /* get the unit_of_measure from po_unit_of_measuresval_v table
     based on the x_uom_code which is provided from input para. */

 SELECT unit_of_measure
   INTO X_unit_of_measure_v
   FROM po_units_of_measure_val_v
  WHERE uom_code = X_uom_code;

 RETURN X_unit_of_measure_v;

EXCEPTION

   WHEN no_data_found THEN
        RETURN NULL;
   WHEN others THEN
        po_message_s.sql_error('derive_unit_of_measure',X_progress, sqlcode);
        raise;

END derive_unit_of_measure;

END PO_UNIT_OF_MEASURES_SV1;

/
