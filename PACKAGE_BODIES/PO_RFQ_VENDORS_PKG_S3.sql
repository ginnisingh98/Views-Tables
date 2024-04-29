--------------------------------------------------------
--  DDL for Package Body PO_RFQ_VENDORS_PKG_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RFQ_VENDORS_PKG_S3" as
/* $Header: POXPIR4B.pls 115.0 99/07/17 01:50:03 porting ship $ */
/*========================================================================
** PROCEDURE NAME : check_unique
** DESCRIPTION    : We need either the po_line_id OR po_release_id
**                  argument passed in. Since both are the same data type
**                  cannot use function overloading unless we to_number()
**                  one of them. For now please pass in a NULL or 0 if
**                  either of them is NOT relevant.
** ======================================================================*/


PROCEDURE check_unique (X_rowid		      VARCHAR2,
			X_sequence_num	      NUMBER,
                        X_po_header_id        NUMBER) IS


  X_progress VARCHAR2(3) := NULL;
  dummy	   NUMBER;

BEGIN

  X_progress := '010';

  SELECT  1
  INTO    dummy
  FROM    DUAL
  WHERE  not exists (SELECT 1
		     FROM   po_rfq_vendors
		     WHERE  po_header_id = X_po_header_id
                     AND    sequence_num  = X_sequence_num
		     AND    ((X_rowid is null) or
                             (X_rowid != rowid)));
  X_progress := '020';

exception
  when no_data_found then
    po_message_s.app_error('PO_PO_ENTER_UNIQUE_SEQ_NUM');
  when others then
    po_message_s.sql_error('check_unique',X_progress,sqlcode);

end check_unique;

/*===========================================================================

  FUNCTION NAME:	get_max_sequence_num

===========================================================================*/

 FUNCTION get_max_sequence_num
	(X_po_header_id   NUMBER) return number is

 x_max_sequence_num NUMBER;
 X_Progress   varchar2(3) := '';

 BEGIN

  X_progress := '010';

   SELECT nvl(max(sequence_num),0)
   INTO   X_max_sequence_num
   FROM   po_rfq_vendors
   WHERE  po_header_id   = X_po_header_id;

  X_progress := '020';

   return(x_max_sequence_num);

   EXCEPTION
   WHEN OTHERS THEN
      return(0);
      RAISE;

 END get_max_sequence_num;

END PO_RFQ_VENDORS_PKG_S3;

/
