--------------------------------------------------------
--  DDL for Package Body PO_RFQ_VENDOR_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_RFQ_VENDOR_SV" as
/* $Header: POXSORVB.pls 115.1 2002/11/26 19:49:47 sbull ship $ */
/*==========================  PO_RFQ_VENDOR_SV  ============================*/


/*===========================================================================

  PROCEDURE NAME:	test_get_sequence_num()

===========================================================================*/

PROCEDURE test_get_sequence_num(X_po_header_id	IN	 NUMBER) IS

X_sequence_num		NUMBER := '';

BEGIN
  dbms_output.put_line('before call');

  po_rfq_vendor_sv.get_sequence_num(X_po_header_id,
			   	    X_sequence_num);

  dbms_output.put_line('The next sequence number is = '||X_sequence_num);

END test_get_sequence_num;


/*===========================================================================

  FUNCTION NAME:	get_sequence_num()

===========================================================================*/

PROCEDURE get_sequence_num
		(X_po_header_id		IN	NUMBER,
		 X_sequence_num		IN OUT	NOCOPY NUMBER) IS

x_progress VARCHAR2(3) := '';

CURSOR C is
	SELECT max(sequence_num) + 1
	FROM   po_rfq_vendors
	WHERE  po_header_id = X_po_header_id;

BEGIN

  dbms_output.put_line('Before_open_cursor');

  IF (X_po_header_id is not null) THEN
    x_progress := '010';
    OPEN C;
    x_progress := '020';

    /*
    ** Get the next sequence number.
    */
    FETCH C into X_sequence_num;
    CLOSE C;

    /*
    ** If there is no sequence number retrieved, then this is the first
    ** RFQ Vendor line to be created.  Default the sequence number to 1
    ** in this case.
    */
    IF (X_sequence_num is NULL) THEN
      X_sequence_num := 1;
    END IF;

    dbms_output.put_line('Next sequence number is: '||X_sequence_num);

  ELSE
    x_progress := '030';
    po_message_s.sql_error('no po_header_id', x_progress, sqlcode);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_sequence_num', x_progress, sqlcode);

END get_sequence_num;

/*===========================================================================

  PROCEDURE NAME:	test_val_seq_num_unique

===========================================================================*/
PROCEDURE test_val_seq_num_unique (X_po_header_id  	IN  NUMBER,
				   X_sequence_num  	IN  NUMBER) IS

X_seq_num_is_unique VARCHAR2(1) := '';

BEGIN

  dbms_output.put_line('before call');

  po_rfq_vendor_sv.val_seq_num_unique(X_po_header_id, X_sequence_num,
				      X_seq_num_is_unique);

  dbms_output.put_line('after call');
  dbms_output.put_line('Sequence unique = '||X_seq_num_is_unique);

END test_val_seq_num_unique;


/*===========================================================================

  PROCEDURE NAME:	val_seq_num_unique()

===========================================================================*/

PROCEDURE val_seq_num_unique
		(X_po_header_id		IN	NUMBER,
		 X_sequence_num		IN	NUMBER,
		 X_seq_num_is_unique	IN OUT	NOCOPY VARCHAR2) IS

x_progress VARCHAR2(3) := '';

BEGIN

  x_progress := '010';

  /*
  ** Verify uniqueness of the sequence number for the RFQ Vendor list.
  */
  SELECT MAX('N')
  INTO   X_seq_num_is_unique
  FROM   po_rfq_vendors
  WHERE  po_header_id = X_po_header_id
  AND    sequence_num = X_sequence_num;

  x_progress := '020';

  IF (X_seq_num_is_unique is NULL) THEN
    X_seq_num_is_unique := 'Y';
  END IF;

  dbms_output.put_line('Sequence is unique = '||X_seq_num_is_unique);

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('val_seq_num_unique', x_progress, sqlcode);

END val_seq_num_unique;

END PO_RFQ_VENDOR_SV;


/
