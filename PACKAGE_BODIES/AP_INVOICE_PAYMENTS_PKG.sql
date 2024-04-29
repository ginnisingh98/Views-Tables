--------------------------------------------------------
--  DDL for Package Body AP_INVOICE_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_INVOICE_PAYMENTS_PKG" AS
/* $Header: apiinpab.pls 120.3 2005/09/20 20:15:55 rlandows noship $ */

    -----------------------------------------------------------------------
    -- Declare record type used to hold records returned from generic cursor
    --
    TYPE PAYMENT_RECORD IS
    RECORD (check_number    ap_checks.check_number%TYPE,
	    check_id	    ap_checks.check_id%TYPE,
	    check_date	    ap_checks.check_date%TYPE,
	    invoice_num     ap_invoices.invoice_num%TYPE,
	    invoice_id      ap_invoices.invoice_id%TYPE,
	    gl_date	    ap_invoice_payments.accounting_date%TYPE,
	    type	    ap_invoice_payments.invoice_payment_type%TYPE,
	    type_trans      ap_lookup_codes.displayed_field%TYPE,
	    method	    ap_checks.payment_method_code%TYPE, --4552701
	    method_trans    ap_lookup_codes.displayed_field%TYPE);

    -----------------------------------------------------------------------
    -- Declare generic cursor to get check number, check id, invoice number
    -- invoice id, payment type, payment method lookup code, and translated
    -- payment method
    --
    -- MOAC.  Use table instead of SO views.
    CURSOR payment_cursor (l_invoice_id NUMBER, l_payment_num NUMBER)
    RETURN payment_record IS
    SELECT ac.check_number,
	   ac.check_id,
	   ac.check_date,
	   ai.invoice_num,
	   ai.invoice_id,
	   aip.accounting_date,
	   aip.invoice_payment_type,
	   iby.payment_method_name, --4552701
	   ac.payment_method_code, --4552701
	   iby.payment_method_name
    FROM   ap_invoice_payments_all aip,
	   ap_checks_all           ac,
	   ap_invoices_all       ai,
	   iby_payment_methods_vl iby
    WHERE  aip.invoice_id       = l_invoice_id
    AND    aip.payment_num      = l_payment_num
    AND    aip.check_id         = ac.check_id
    AND    aip.other_invoice_id = ai.invoice_id (+)
    AND    iby.payment_method_code     = ac.payment_method_code;


    -----------------------------------------------------------------------
    -- Function concat_document_num_type concatenates the document number
    -- to the document type
    --
    FUNCTION concat_document_num_type(l_payment_record IN PAYMENT_RECORD)
	RETURN VARCHAR2
    IS
	l_paid_by VARCHAR2(100);
    BEGIN

     -------------------------------------------------------
     -- Get payment number concatenated to payment method type
     --
     l_paid_by := l_payment_record.check_number ||' - '||
 		  l_payment_record.method_trans;

	RETURN(l_paid_by);

    END concat_document_num_type;


    -----------------------------------------------------------------------
    -- Function get_paid_by returns the document number concatenated to the
    -- document type if payment schedule is paid by a single invoice payment
    -- and the translated phrase 'Multiple Payments' if paid by multiple
    -- payments or if unpaid.
    --
    FUNCTION get_paid_by(l_invoice_id IN NUMBER, l_payment_num IN NUMBER)
        RETURN VARCHAR2
    IS
	l_paid_by 	 VARCHAR2(100);
	l_payment_record PAYMENT_RECORD;

    BEGIN

	OPEN payment_cursor(l_invoice_id, l_payment_num);

	LOOP
	    FETCH payment_cursor INTO l_payment_record;
	    EXIT WHEN payment_cursor%NOTFOUND;

	    IF (payment_cursor%ROWCOUNT = 1) THEN

		l_paid_by := AP_INVOICE_PAYMENTS_PKG.CONCAT_DOCUMENT_NUM_TYPE(
						l_payment_record);

	    ELSIF (payment_cursor%ROWCOUNT > 1) THEN
		-----------------------------------------------------------
		-- Get the translated phrase 'Multiple Payments'
	        --
	    	SELECT displayed_field
	     	INTO   l_paid_by
	     	FROM   ap_lookup_codes
	     	WHERE  lookup_type = 'NLS TRANSLATION'
	     	AND    lookup_code = 'MULTIPLE PAYMENTS';

	        EXIT;

	    END IF;

	END LOOP;

	CLOSE payment_cursor;

        RETURN(l_paid_by);

    END get_paid_by;


    -----------------------------------------------------------------------
    -- Function get_paid_by_list returns a list of document numbers
    -- concatenated to the document type used to pay this payment schedule
    -- or NULL if unpaid.
    --
    FUNCTION get_paid_by_list(l_invoice_id IN NUMBER, l_payment_num IN NUMBER)
        RETURN VARCHAR2
    IS
	l_paid_by 	 VARCHAR2(100);
        l_paid_by_list	 VARCHAR2(2000) := NULL;
	l_payment_record PAYMENT_RECORD;

    BEGIN

	OPEN payment_cursor(l_invoice_id, l_payment_num);

	LOOP
	    FETCH payment_cursor INTO l_payment_record;
	    EXIT WHEN payment_cursor%NOTFOUND;

	    l_paid_by := AP_INVOICE_PAYMENTS_PKG.CONCAT_DOCUMENT_NUM_TYPE(
							l_payment_record);

	    IF (l_paid_by_list IS NOT NULL) THEN
		l_paid_by_list := l_paid_by_list || ', ';
	    END IF;

	    l_paid_by_list := l_paid_by_list || l_paid_by;

	END LOOP;

	CLOSE payment_cursor;

        RETURN(l_paid_by_list);

    END get_paid_by_list;


    -----------------------------------------------------------------------
    -- Function get_paid_date returns the check date if the payment schedule
    -- is paid by a single invoice payment and NULL if paid by multiple
    -- payments or if unpaid.
    --
    FUNCTION get_paid_date(l_invoice_id IN NUMBER, l_payment_num IN NUMBER)
        RETURN DATE
    IS
	l_paid_date		DATE := NULL;
	l_payment_record	PAYMENT_RECORD;
    BEGIN

	OPEN payment_cursor(l_invoice_id, l_payment_num);

	LOOP
	    FETCH payment_cursor INTO l_payment_record;
	    EXIT WHEN payment_cursor%NOTFOUND;

	    IF (payment_cursor%ROWCOUNT = 1) THEN

		    -------------------------------------------------------
		    -- Get check date
	  	    --
	  	    l_paid_date := l_payment_record.check_date;

	    ELSIF (payment_cursor%ROWCOUNT > 1) THEN

		l_paid_date := NULL;

	        EXIT;

	    END IF;

	END LOOP;

	CLOSE payment_cursor;

        RETURN(l_paid_date);

    END get_paid_date;


    -----------------------------------------------------------------------
    -- Function get_payment_id returns the check id if payment schedule is
    -- paid by a single invoice payment and NULL if paid by multiple
    -- payments or if unpaid.
    --
    FUNCTION get_payment_id(l_invoice_id IN NUMBER, l_payment_num IN NUMBER)
        RETURN NUMBER
    IS
	l_payment_id		NUMBER := NULL;
	l_payment_record	PAYMENT_RECORD;

    BEGIN

	OPEN payment_cursor(l_invoice_id, l_payment_num);

	LOOP
	    FETCH payment_cursor INTO l_payment_record;
	    EXIT WHEN payment_cursor%NOTFOUND;

	    IF (payment_cursor%ROWCOUNT = 1) THEN

		    -------------------------------------------------------
		    -- Get check id
		    --
		    l_payment_id := l_payment_record.check_id;

	    ELSIF (payment_cursor%ROWCOUNT > 1) THEN

		l_payment_id := NULL;

	        EXIT;

	    END IF;

	END LOOP;

	CLOSE payment_cursor;

        RETURN(l_payment_id);

    END get_payment_id;


    -----------------------------------------------------------------------
    -- Function get_payment_type returns the check payment method if payment
    -- schedule is paid by a single invoice payment and NULL if paid by
    -- multiple payments or if unpaid.
    --
    FUNCTION get_payment_type(l_invoice_id IN NUMBER, l_payment_num IN NUMBER)
        RETURN VARCHAR2
    IS
	l_payment_type		VARCHAR2(25);
	l_payment_record	PAYMENT_RECORD;

    BEGIN

	OPEN payment_cursor(l_invoice_id, l_payment_num);

	LOOP
	    FETCH payment_cursor INTO l_payment_record;
	    EXIT WHEN payment_cursor%NOTFOUND;

	    IF (payment_cursor%ROWCOUNT = 1) THEN

		    -- Get check payment method
		    --
		    l_payment_type := l_payment_record.method;

	    ELSIF (payment_cursor%ROWCOUNT > 1) THEN

		l_payment_type := NULL;

	        EXIT;

	    END IF;

	END LOOP;

	CLOSE payment_cursor;

        RETURN(l_payment_type);

    END get_payment_type;


    -----------------------------------------------------------------------
    -- Function get_max_gl_date returns the latest accounting date for
    -- the invoice payments belonging to the check.
    --
    FUNCTION get_max_gl_date(l_check_id IN NUMBER)
      RETURN DATE
    IS
      gl_date DATE;
    BEGIN

      SELECT NVL(MAX(accounting_date), SYSDATE-9000)
        INTO gl_date
        FROM ap_invoice_payments_all
       WHERE check_id = l_check_id;

      RETURN gl_date;

    END get_max_gl_date;

END AP_INVOICE_PAYMENTS_PKG;

/
