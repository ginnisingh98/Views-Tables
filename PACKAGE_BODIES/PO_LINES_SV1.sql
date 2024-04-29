--------------------------------------------------------
--  DDL for Package Body PO_LINES_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LINES_SV1" AS
/* $Header: POXPILSB.pls 120.0.12000000.1 2007/07/27 07:25:38 grohit noship $ */

/*================================================================

  FUNCTION NAME: 	val_line_num_uniqueness()

==================================================================*/
 FUNCTION val_line_num_uniqueness(x_line_num       IN NUMBER,
                                  x_rowid          IN VARCHAR2,
                                  x_po_header_id   IN NUMBER) RETURN BOOLEAN
 IS

   x_progress    varchar2(3) := null;
   x_temp        binary_integer := 0;

 BEGIN
   x_progress := '010';

   /* check to see if there are any non_unique line_num exists
      in po_lines */

   SELECT count(*)
     INTO x_temp
     FROM po_lines
    WHERE po_header_id = x_po_header_id
      AND line_num = x_line_num
      AND (rowid <> x_rowid OR x_rowid is null);

   IF x_temp = 0 THEN
      /* there are no duplicated line_num exists in po_lines */
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error
        ('val_line_num_uniqueness', x_progress, sqlcode);
      raise;
 END val_line_num_uniqueness;

/*================================================================

  FUNCTION NAME: 	val_line_id_uniqueness()

==================================================================*/
 FUNCTION val_line_id_uniqueness(x_po_line_id    IN NUMBER,
                                 x_rowid         IN VARCHAR2,
                                 x_po_header_id  IN NUMBER) RETURN BOOLEAN
 IS

   x_progress   varchar2(3) := null;
   x_temp       binary_integer := 0;

 BEGIN
   x_progress := '010';

   /* check to see if there are any non_unique line_id exists
      in po_lines */
   SELECT COUNT(*)
     INTO x_temp
     FROM po_lines
    WHERE po_header_id = x_po_header_id
      AND po_line_id = x_po_line_id
      AND (rowid <> x_rowid OR x_rowid is null);

   IF x_temp = 0 THEN   /* no duplicated line_id found */
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error('val_line_id_uniqueness', x_progress,sqlcode);
      raise;
 END val_line_id_uniqueness;

/*================================================================

  FUNCTION NAME: 	derive_po_line_id()

==================================================================*/

FUNCTION  derive_po_line_id(X_po_header_id IN NUMBER,
                            X_line_num IN NUMBER)
return NUMBER IS

X_progress       varchar2(3)     := NULL;
X_po_line_id_v   number           := NULL;

BEGIN

 X_progress := '010';

 /*  derive the po_line_id from po_lines based on the po_header_id and
     line_num from the input parameter */

 SELECT po_line_id
   INTO X_po_line_id_v
   FROM po_lines
  WHERE po_header_id = X_po_header_id
    AND line_num = X_line_num;

 RETURN X_po_line_id_v;

EXCEPTION
   When no_data_found then
     RETURN NULL;
   When others then
     po_message_s.sql_error('derive_po_line_id',X_progress, sqlcode);
     raise;
END derive_po_line_id;

END PO_LINES_SV1;

/
