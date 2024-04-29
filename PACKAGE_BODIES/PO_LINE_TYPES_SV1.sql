--------------------------------------------------------
--  DDL for Package Body PO_LINE_TYPES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINE_TYPES_SV1" AS
/* $Header: POXPILTB.pls 120.0.12000000.1 2007/07/27 08:34:08 grohit noship $ */

/*================================================================

  FUNCTION NAME: 	val_line_type_id()

==================================================================*/
 FUNCTION val_line_type_id(x_line_type_id IN NUMBER) RETURN BOOLEAN
 IS

   x_progress    varchar2(3) := null;
   x_temp        binary_integer := 0;

 BEGIN
   x_progress := '010';

   /* check to see if there are x_line_type_id exists in
      po_line_types_val_v table */

   SELECT count(*)
     INTO x_temp
     FROM po_line_types_val_v
    WHERE line_type_id = x_line_type_id;

   IF x_temp = 0 THEN
      RETURN FALSE;      /* validation fails */
   ELSE
      RETURN TRUE;       /* validation succeeds */
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error
        ('val_line_type_id', x_progress, sqlcode);
        raise;
 END val_line_type_id;

/*================================================================

  FUNCTION NAME: 	derive_line_type_id()

==================================================================*/
FUNCTION  derive_line_type_id(X_line_type  IN VARCHAR2) return NUMBER IS

  X_progress          varchar2(3)     := NULL;
  X_line_type_id_v    number        := NULL;

BEGIN

  X_progress := '010';

   /* derive line_type_id from po_line_types_val_v view based on
      line_type which is being provided from input parameter */

   SELECT line_type_id
    INTO X_line_type_id_v
    FROM po_line_types_val_v
   WHERE line_type = X_line_type;

  RETURN X_line_type_id_v;

EXCEPTION
   When no_data_found then
        RETURN NULL;
   When others then
        po_message_s.sql_error('derive_line_type_id',X_progress, sqlcode);
        raise;
END derive_line_type_id;

END PO_LINE_TYPES_SV1;

/
