--------------------------------------------------------
--  DDL for Package Body PO_QUOTES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_QUOTES_SV" as
/* $Header: POXSOQUB.pls 115.1 2002/11/26 19:50:15 sbull ship $ */
/*============================  PO_QUOTES_SV  ==============================*/


/*===========================================================================

  PROCEDURE NAME:	test_val_header_delete()

===========================================================================*/

PROCEDURE test_val_header_delete(X_po_header_id	  IN	NUMBER) IS

X_allow_delete		BOOLEAN;

BEGIN

  dbms_output.put_line('Before_call');

  po_quotes_sv.val_header_delete(X_po_header_id, X_allow_delete);

  dbms_output.put_line('After call');

  if (X_allow_delete) then
    dbms_output.put_line('Allow Delete = TRUE');
  else
    dbms_output.put_line('Allow Delete = FALSE');
  end if;

END test_val_header_delete;

/*===========================================================================

  PROCEDURE NAME:	val_header_delete()

===========================================================================*/

PROCEDURE val_header_delete(X_po_header_id  IN		NUMBER,
			    X_allow_delete  IN OUT	NOCOPY BOOLEAN) IS

  x_progress 		VARCHAR2(3) := '';
  x_delete_test 	VARCHAR2(1) := 'Y';

BEGIN


  x_progress := '010';

  x_progress := '020';

  /*
  ** Verifies if this Quotation is referenced on a PO.
  **   If it is NOT, verify the document is not used in autosource rules.
  **   If it is, display message and prevent delete.
  */
  SELECT MAX('N')
  INTO   X_delete_test
  FROM   po_lines pol
  WHERE  pol.from_header_id = X_po_header_id;

  x_progress := '020';

  IF (nvl(X_delete_test,'Y') = 'Y') THEN
    /*
    ** Verify the Quotation is not used in autosource rules.
    **   If it is NOT, verify it is not on a req line.
    **   If it is, display message and prevent delete.
    **
    ** CMOK: If ASL installed, use po_asl_documents table.
    */


    SELECT MAX('N')
    INTO   X_delete_test
    FROM   po_asl_documents pad
    WHERE  pad.document_header_id = X_po_header_id;

    IF (nvl(X_delete_test,'Y') = 'Y') THEN
      /*
      ** Verify the Quotation is not referenced on a Requisition line.
      **   If it is NOT, allow the delete.
      **   If it is, display message and prevent delete.
      */
      SELECT MAX('N')
      INTO   X_delete_test
      FROM   po_requisition_lines prl
      WHERE  prl.blanket_po_header_id = X_po_header_id;

      IF (nvl(X_delete_test,'Y') = 'Y') THEN
        X_allow_delete := TRUE;
        dbms_output.put_line('Delete permitted');
      ELSE
        X_allow_delete := FALSE;
        po_message_s.app_error('PO_DELETE_QT_ON_REQ');
       /* DEBUG: this message needs to be added to the message dictionary */
      END IF;

    ELSE
      X_allow_delete := FALSE;
      po_message_s.app_error('PO_QT_DELETE_SOURCE');
    END IF;

  ELSE
    X_allow_delete := FALSE;
    po_message_s.app_error('PO_DELETE_QT_ON_PO_NA');
    /* DEBUG: this message needs to be added to the message dictionary */
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('In VAL exception');
    po_message_s.sql_error('val_header_delete', x_progress, sqlcode);

END val_header_delete;

/*===========================================================================

  PROCEDURE NAME:	test_val_line_delete()

===========================================================================*/

PROCEDURE test_val_line_delete(X_po_line_id	  IN	NUMBER,
			       X_po_line_num	  IN	NUMBER,
			       X_po_header_id	  IN	NUMBER) IS

X_allow_delete		VARCHAR2(1) := '';

BEGIN

  dbms_output.put_line('Before_call');

  po_quotes_sv.val_line_delete(X_po_line_id, X_po_line_num, X_po_header_id,
			       X_allow_delete);

  dbms_output.put_line('After call');
  dbms_output.put_line('Allow Delete = '||X_allow_delete);

END test_val_line_delete;

/*===========================================================================

  PROCEDURE NAME:	val_line_delete()

===========================================================================*/

PROCEDURE val_line_delete(X_po_line_id	  IN		NUMBER,
			  X_po_line_num	  IN		NUMBER,
			  X_po_header_id  IN		NUMBER,
			  X_allow_delete  IN OUT	NOCOPY VARCHAR2) IS

  x_progress 		 VARCHAR2(3) := '';
  x_fetched_on_po	 NUMBER	     := '';
  x_fetched_on_req	 NUMBER	     := '';
  x_sourced		 NUMBER	     := '';

  CURSOR C_ON_PO is
 	SELECT 	pol.po_line_id
	FROM	po_lines pol
	WHERE  	pol.from_header_id = X_po_header_id
	AND    	pol.from_line_id   = X_po_line_id;

  CURSOR C_ON_REQ is
	SELECT 	prl.blanket_po_line_num
	FROM 	po_requisition_lines prl
	WHERE 	prl.BLANKET_PO_HEADER_ID = X_po_header_id
	AND   	prl.BLANKET_PO_LINE_NUM  = X_po_line_num;

BEGIN


  x_progress := '005';

  dbms_output.put_line('Before open cursors');

  /*
  ** open all cursors
  */
  x_progress := '010';
  OPEN C_ON_PO;

  x_progress := '020';
  OPEN C_ON_REQ;

  /*
  ** and fetch values into all cursors.
  */

  x_progress := '030';
  FETCH C_ON_PO into x_fetched_on_po;
  FETCH C_ON_REQ into x_fetched_on_req;

  /*
  ** check to see if the Quotation line is referenced on a PO
  **   if it is NOT, verify it is not used in autosource rules.
  **   if it is, display message and prevent delete.
  */
  IF C_ON_PO%NOTFOUND THEN

    /*
    ** check to see if the Quotation line is used in ASL.
    **   if it is NOT, verify it is not on a req line.
    **   if it is, display message and prevent delete.
    **
    */


    x_progress := '040';
    SELECT 	count(*)
    INTO    x_sourced
    FROM  	po_asl_documents pad
    WHERE 	pad.DOCUMENT_HEADER_ID = X_po_header_id
    AND   	pad.DOCUMENT_LINE_ID   = X_po_line_id;


    IF (x_sourced = 0) THEN

      /*
      ** verify the Quotation line is not used for reference on
      ** a requisition line.
      **   if it is NOT, allow the delete.
      **   if it is, display message and prevent delete.
      */

      IF C_ON_REQ%NOTFOUND THEN
        X_allow_delete := 'Y';
        dbms_output.put_line('Allow delete = '||X_allow_delete);
      ELSE
    	X_allow_delete := 'N';
        po_message_s.app_error('PO_DELETE_REQS');
    	dbms_output.put_line('Allow delete = '||X_allow_delete);
      END IF;

    ELSE
      X_allow_delete := 'N';
      po_message_s.app_error('PO_QT_LINE_DELETE_SOURCE');
      dbms_output.put_line('Allow delete = '||X_allow_delete);
    END IF;

  ELSE
    X_allow_delete := 'N';
    po_message_s.app_error('PO_QT_LINE_DELETE_NA');
    dbms_output.put_line('Allow delete = '||X_allow_delete);
  END IF;

  /*
  ** close cursors
  */
  CLOSE C_ON_PO;
  CLOSE C_ON_REQ;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('In VAL exception');
    po_message_s.sql_error('val_line_delete', x_progress, sqlcode);

END val_line_delete;

/*===========================================================================

  PROCEDURE NAME:	test_val_reply()

===========================================================================*/

PROCEDURE test_val_reply
		(X_from_header_id	IN	NUMBER,
	 	 X_vendor_id		IN	NUMBER,
	 	 X_vendor_site_id	IN	NUMBER) IS

BEGIN

  dbms_output.put_line('Before_call');

  IF po_quotes_sv.val_reply(X_from_header_id, X_vendor_id, X_vendor_site_id) THEN
    dbms_output.put_line('Return TRUE');
  ELSE
    dbms_output.put_line('Return FALSE');
  END IF;

END test_val_reply;

/*===========================================================================

  FUNCTION NAME:	val_reply()

===========================================================================*/

FUNCTION val_reply
		(X_from_header_id	IN	NUMBER,
	 	 X_vendor_id		IN	NUMBER,
	 	 X_vendor_site_id	IN	NUMBER) RETURN BOOLEAN IS

x_progress 		VARCHAR2(3) := '';
x_duplicate_reply	VARCHAR2(1) := '';

BEGIN
  x_progress := '010';

  /*
  ** Check if a quotation already exists for a specific RFQ/Supplier/Site
  ** combination.  If it does, return TRUE.  Otherwise return FALSE.
  */
  SELECT MAX('Y')
    INTO x_duplicate_reply
    FROM po_headers
   WHERE from_header_id    	= X_from_header_id
     AND vendor_id         	= X_vendor_id
     AND vendor_site_id    	= X_vendor_site_id
     AND from_type_lookup_code 	= 'RFQ';

  x_progress := '020';

  IF (x_duplicate_reply is null) THEN
    RETURN (FALSE);
  ELSE
    RETURN (TRUE);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('In exception');
    po_message_s.sql_error('val_reply', x_progress, sqlcode);

END val_reply;

/*===========================================================================

  PROCEDURE NAME:	test_get_quote_status()

===========================================================================*/

PROCEDURE test_get_quote_status
			(X_po_header_id	  IN	NUMBER) IS

X_quote_referenced	VARCHAR2(1) := '';

BEGIN

  dbms_output.put_line('Before_call');

  po_quotes_sv.get_quote_status(X_po_header_id, X_quote_referenced);

  dbms_output.put_line('After call');
  dbms_output.put_line('Quote Referenced? => '||X_quote_referenced);

END test_get_quote_status;

/*===========================================================================

  PROCEDURE NAME:	get_quote_status()

===========================================================================*/

PROCEDURE get_quote_status(X_po_header_id  	IN	NUMBER,
			   X_quote_referenced	IN OUT	NOCOPY VARCHAR2) IS

x_progress VARCHAR2(3) := NULL;

BEGIN
  x_progress := '010';

  /*
  ** Check to see if quotation is referenced on a purchase order.
  */
  SELECT MAX('Y')
    INTO X_quote_referenced
    FROM po_lines pol
   WHERE pol.from_header_id = X_po_header_id;

  x_progress := '020';

  IF (X_quote_referenced is null) THEN

    x_progress := '030';

    /*
    ** Check to see if quotation is used for autosource rules.
    */
    SELECT MAX('Y')
      INTO X_quote_referenced
      FROM po_autosource_documents pad
     WHERE pad.DOCUMENT_HEADER_ID = X_po_header_id;

    x_progress := '040';

    IF (X_quote_referenced is null) THEN
      X_quote_referenced := 'N';
    END IF;

  END IF;

 dbms_output.put_line('Is Quote Referenced? => '||X_quote_referenced);


EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('In exception');
    po_message_s.sql_error('get_quote_status', x_progress, sqlcode);

END get_quote_status;

/*===========================================================================

  PROCEDURE NAME:	test_get_from_rfq_defaults()

===========================================================================*/

PROCEDURE test_get_from_rfq_defaults
		(X_from_header_id	   IN		NUMBER) IS

X_rfq_close_date	  DATE		:= '';
X_from_type_lookup_code   VARCHAR2(30)	:= '';
X_approval_required_flag  VARCHAR2(1)	:= '';


BEGIN
  dbms_output.put_line('before call');

  po_quotes_sv.get_from_rfq_defaults
				(X_from_header_id,
 	 	 		 X_rfq_close_date,
	 	 	 	 X_from_type_lookup_code,
			 	 X_approval_required_flag);

  dbms_output.put_line('RFQ Close Date = '||X_rfq_close_date);
  dbms_output.put_line('From Type Lookup Code = '||X_from_type_lookup_code);
  dbms_output.put_line('Acceptance Required = '||X_approval_required_flag);

END test_get_from_rfq_defaults;

/*===========================================================================

  PROCEDURE NAME:	get_from_rfq_defaults()

===========================================================================*/

PROCEDURE get_from_rfq_defaults
		(X_from_header_id	   IN		NUMBER,
 	 	 X_rfq_close_date	   IN OUT	NOCOPY DATE,
	 	 X_from_type_lookup_code   IN OUT	NOCOPY VARCHAR2,
	 	 X_approval_required_flag  IN OUT	NOCOPY VARCHAR2) IS

x_progress VARCHAR2(3) := '';

BEGIN
  x_progress := '010';

  IF (X_from_header_id is not null) THEN
    /*
    ** Get the defaults for the selected From RFQ number
    */
    SELECT poh.rfq_close_date,
           poh.type_lookup_code,
           poh.approval_required_flag
      INTO X_rfq_close_date,
           X_from_type_lookup_code,
           X_approval_required_flag
      FROM po_headers          poh
     WHERE poh.po_header_id = X_from_header_id;

  ELSE
    x_progress := '030';
    po_message_s.sql_error('from_header_id is null', x_progress, sqlcode);

  END IF;

  dbms_output.put_line('RFQ Close Date = '||X_rfq_close_date);
  dbms_output.put_line('From Type Lookup Code = '||X_from_type_lookup_code);
  dbms_output.put_line('Acceptance Required = '||X_approval_required_flag);

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('In exception');
    po_message_s.sql_error('get_from_rfq_defaults', x_progress, sqlcode);

END get_from_rfq_defaults;

/*===========================================================================

  PROCEDURE NAME:	get_approval_status()

===========================================================================*/

PROCEDURE get_approval_status
		(X_line_location_id	IN	NUMBER,
	 	 X_approval_status	IN OUT	NOCOPY VARCHAR2) IS

x_progress 		VARCHAR2(3) := '';

BEGIN
  x_progress := '010';
  X_approval_status := 'N';

  /*
  ** Check if the shipment has been approved.  If it has, set
  ** X_approval_status to 'Y', else it is 'N'.
  */
  SELECT MAX('Y')
    INTO X_approval_status
    FROM po_quotation_approvals
   WHERE line_location_id = X_line_location_id
     AND sysdate BETWEEN nvl(start_date_active, sysdate-1)
     		 AND     nvl(end_date_active, sysdate+1);

  x_progress := '020';

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('In exception');
    po_message_s.sql_error('get_approval_status', x_progress, sqlcode);

END get_approval_status;


END PO_QUOTES_SV;

/
