--------------------------------------------------------
--  DDL for Package Body PO_NOTES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_NOTES_SV" AS
/* $Header: poxcenb.pls 115.1 99/09/24 16:18:55 porting ship $ */

FUNCTION get_entity_name (
  p_table_name  VARCHAR2
) RETURN VARCHAR2 IS
  x_entity_name VARCHAR2(40);
BEGIN

  IF    p_table_name='PO_HEADERS' THEN RETURN 'PO_HEADERS';
  ELSIF p_table_name='PO_LINES' THEN RETURN 'PO_LINES';
  ELSIF p_table_name='PO_LINE_LOCATIONS' THEN RETURN 'PO_SHIPMENTS';
  ELSIF p_table_name='PO_RELEASES' THEN RETURN 'PO_RELEASES';
  ELSIF p_table_name='PO_REQUISITION_HEADERS' THEN RETURN 'REQ_HEADERS';
  ELSIF p_table_name='PO_REQUISITION_LINES' THEN RETURN 'REQ_LINES';
  ELSIF p_table_name='RCV_SHIPMENT_HEADERS' THEN RETURN 'RCV_HEADERS';
  ELSIF p_table_name='RCV_SHIPMENT_LINES' THEN RETURN 'RCV_LINES';
  ELSIF p_table_name='RCV_TRANSACTIONS' THEN RETURN 'RCV_TRANSACTIONS';
  ELSIF p_table_name='RCV_TRANSACTIONS_INTERFACE' THEN RETURN 'RCV_TRANSACTIONS_INTERFACE';
  ELSIF p_table_name='MTL_SYSTEM_ITEMS' THEN RETURN 'MTL_SYSTEM_ITEMS';
  ELSIF p_table_name = 'PO_VENDORS' THEN return 'PO_VENDORS';
  ELSE RETURN 'NOT_PO_ENTITY';
  END IF;

END;

/*===========================================================================

  PROCEDURE NAME:	copy_notes

===========================================================================*/

PROCEDURE copy_notes(X_orig_id           IN NUMBER,
                     X_orig_column       IN VARCHAR2,
                     X_orig_table        IN VARCHAR2,
                     X_add_on_title      IN VARCHAR2,
		     X_new_id            IN NUMBER,
                     X_new_column        IN VARCHAR2,
                     X_new_table         IN VARCHAR2,
                     X_last_updated_by   IN NUMBER,
                     X_last_update_login IN NUMBER) IS

x_from_entity_name Varchar2(40);
x_to_entity_name Varchar2(40);

BEGIN
   /* X_add_on_title is not useful here, but for consistence, leave it there */
   x_from_entity_name := get_entity_name(X_orig_table);
   x_to_entity_name := get_entity_name(X_new_table);
   fnd_attached_documents2_pkg.copy_attachments(x_from_entity_name,
                                                X_orig_id,
                                                '',
                                                '',
                                                '',
                                                '',
                                                x_to_entity_name,
                                                X_new_id,
                                                '',
                                                '',
                                                '',
                                                '',
                                                X_last_updated_by,
						X_last_update_login,
                                                '',
                                                '',
                                                '');
   /* If something fails then return a 0 as failure */
   EXCEPTION
      WHEN OTHERS THEN
      raise;

END copy_notes;

END PO_NOTES_SV;


/
