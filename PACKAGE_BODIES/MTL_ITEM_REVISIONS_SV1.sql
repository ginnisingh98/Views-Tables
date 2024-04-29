--------------------------------------------------------
--  DDL for Package Body MTL_ITEM_REVISIONS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_ITEM_REVISIONS_SV1" AS
/* $Header: POXPIIRB.pls 120.0.12000000.1 2007/01/16 23:03:56 appldev ship $ */

/*================================================================

  FUNCTION NAME: 	val_item_revision()

==================================================================*/
 FUNCTION val_item_revision(x_item_revision      IN VARCHAR2,
                            x_inventory_item_id  IN NUMBER,
                            x_organization_id    IN NUMBER)
 RETURN BOOLEAN IS

   x_progress    varchar2(3) := null;
   x_temp        binary_integer := 0;

 BEGIN
   x_progress := '010';

   /* check to see if there are x_item_revision exists
      in mtl_item_revisions table */

   /* Bug 1833599 - Removed the organization_id check from the sql as the
   revision is just validated against the item and then in POXPISVB.pls, it is validated against
   the ship to org and item   */
   /* Note: I haven't removed the x_organization_id parameter because it would introduce dependencies
   right now  */

   SELECT count(*)
     INTO x_temp
     FROM mtl_item_revisions
    WHERE revision = x_item_revision
      AND inventory_item_id = x_inventory_item_id;

   IF x_temp = 0 THEN
      RETURN FALSE;   /* validation fails */
   ELSE
      RETURN TRUE;    /* validation succeeds */
   END IF;

 EXCEPTION
   WHEN others THEN
        po_message_s.sql_error
        ('val_item_revision', x_progress, sqlcode);
        raise;
 END val_item_revision;

END MTL_ITEM_REVISIONS_SV1;

/
