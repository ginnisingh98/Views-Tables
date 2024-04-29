--------------------------------------------------------
--  DDL for Package Body AP_WEB_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_PAYMENTS_PKG" AS
/* $Header: apwxpayb.pls 120.5.12010000.3 2009/08/12 08:48:52 dsadipir ship $ */

    -----------------------------------------------------------------------
    -- Declare record type used to hold records returned from generic cursor
    --
    TYPE PAYMENT_RECORD IS
    RECORD (check_number    ap_checks.check_number%TYPE,
            check_id        ap_checks.check_id%TYPE,
            check_date      ap_checks.check_date%TYPE,
            invoice_num     ap_invoices.invoice_num%TYPE,
            invoice_id      ap_invoices.invoice_id%TYPE,
            gl_date         ap_invoice_payments.accounting_date%TYPE,
            type            ap_invoice_payments.invoice_payment_type%TYPE,
            method          ap_checks.payment_method_lookup_code%TYPE,
            method_trans    ap_lookup_codes.displayed_field%TYPE);

    -----------------------------------------------------------------------
    -- Declare generic cursor to get check number, check id, invoice number
    -- invoice id, payment type, payment method lookup code, and translated
    -- payment method
    --
    CURSOR payment_cursor (l_invoice_id NUMBER, l_payment_num NUMBER)
    RETURN payment_record IS
    SELECT ac.check_number,
           ac.check_id,
           ac.check_date,
           ai.invoice_num,
           ai.invoice_id,
           aip.accounting_date,
           aip.invoice_payment_type,
           ac.payment_method_lookup_code,
           alc2.displayed_field
    FROM   ap_invoice_payments aip,
           ap_checks           ac,
           ap_invoices         ai,
           ap_lookup_codes     alc2
    WHERE  aip.invoice_id       = l_invoice_id
    AND    aip.payment_num      = l_payment_num
    AND    aip.check_id         = ac.check_id
    AND    aip.other_invoice_id = ai.invoice_id (+)
    AND    alc2.lookup_type     = 'PAYMENT METHOD'
    AND    alc2.lookup_code     = ac.payment_method_code
    UNION ALL
    SELECT ac.check_number,
           ac.check_id,
           ac.check_date,
           ai.invoice_num,
           ai.invoice_id,
           aip.accounting_date,
           aip.invoice_payment_type,
           ac.payment_method_lookup_code,
           alc2.displayed_field
    FROM   ap_invoice_payments aip,
           ap_checks           ac,
           ap_invoices         ai,
           ap_lookup_codes     alc2,
	   ap_invoice_lines ail1,
	   ap_invoice_lines ail2,
           ap_invoice_distributions aid1,
           ap_invoice_distributions aid2
    WHERE  aip.invoice_id       = ail2.invoice_id
    AND    ail1.invoice_id      = l_invoice_id
    AND    aip.payment_num      = l_payment_num
    AND    aid1.invoice_id = ail1.invoice_id
    AND    aid1.invoice_line_number = ail1.line_number
    AND    aid2.invoice_id = ail2.invoice_id
    AND    aid2.invoice_line_number = ail2.line_number
    AND    aip.check_id         = ac.check_id
    AND    aip.other_invoice_id = ai.invoice_id (+)
    AND    alc2.lookup_type     = 'PAYMENT METHOD'
    AND    alc2.lookup_code     = ac.payment_method_code
    AND   (ail1.line_type_lookup_code = 'PREPAY' OR
           ail1.line_type_lookup_code = 'TAX'    AND
           aid1.prepay_tax_parent_id IS NOT NULL
           )
    AND aid2.INVOICE_DISTRIBUTION_ID = aid1.prepay_distribution_id;

    -----------------------------------------------------------------------
    -- Function concat_document_num_type concatenates the document number
    -- to the document type
    --
    FUNCTION concat_document_num_type(l_payment_record IN PAYMENT_RECORD)
        RETURN VARCHAR2
    IS
        l_paid_by  VARCHAR2(80);
        type_trans ap_lookup_codes.displayed_field%TYPE;
    BEGIN

        IF (l_payment_record.type = 'PREPAY') THEN

            SELECT displayed_field
            INTO type_trans
            FROM ap_lookup_codes
            WHERE lookup_type     = 'NLS TRANSLATION'
            AND lookup_code     = 'PREPAY';

            -------------------------------------------------------
            -- Get prepayment number concatenated to prepayment type
            --
            l_paid_by := type_trans ||' #'||
                         l_payment_record.invoice_num;
        ELSE
            -------------------------------------------------------
            -- Get payment number concatenated to payment method type
            --
            l_paid_by := l_payment_record.method_trans ||' #'||
                         l_payment_record.check_number;
        END IF;

        RETURN(l_paid_by);

    END concat_document_num_type;


    -----------------------------------------------------------------------
    -- Function get_paid_by_list returns a list of document numbers
    -- concatenated to the document type used to pay this payment schedule
    -- or NULL if unpaid.
    --
    FUNCTION get_paid_by_list(l_invoice_id IN NUMBER, l_payment_num IN NUMBER)
        RETURN VARCHAR2
    IS
        l_paid_by        VARCHAR2(80);
        l_paid_by_list   VARCHAR2(2000) := NULL;
        l_payment_record PAYMENT_RECORD;

    BEGIN

        OPEN payment_cursor(l_invoice_id, l_payment_num);

        LOOP
            FETCH payment_cursor INTO l_payment_record;
            EXIT WHEN payment_cursor%NOTFOUND;

            l_paid_by := AP_WEB_PAYMENTS_PKG.CONCAT_DOCUMENT_NUM_TYPE(l_payment_record);

            IF (l_paid_by_list IS NOT NULL) THEN
                l_paid_by_list := l_paid_by_list || ', ';
            END IF;

            l_paid_by_list := l_paid_by_list || l_paid_by;

        END LOOP;

        l_paid_by_list := payment_cursor%ROWCOUNT||'*'||l_paid_by_list;

        CLOSE payment_cursor;

        RETURN(l_paid_by_list);

    END get_paid_by_list;

    -----------------------------------------------------------------------
    -- Function get_paid_by_list returns a list of document numbers
    -- concatenated to the document type used to pay this payment schedule
    -- or NULL if unpaid.
    --
    FUNCTION get_total_payments_made(l_invoice_id IN NUMBER)
        RETURN VARCHAR2
    IS
        l_total_payment_made   VARCHAR2(80);

    BEGIN
	SELECT SUM(AIP.AMOUNT)
	INTO l_total_payment_made
	FROM AP_INVOICE_PAYMENTS AIP, AP_INVOICES AI
	WHERE AIP.INVOICE_ID = AI.INVOICE_ID
	AND AI.INVOICE_ID = l_invoice_id;

        RETURN(l_total_payment_made);

	EXCEPTION
	 WHEN no_data_found  THEN
	  return(null);
	 WHEN OTHERS THEN
	  raise;
    END get_total_payments_made;

    -----------------------------------------------------------------------
    -- Function get_checkid returns the first Check ID for a
    -- given Invoice ID.
    FUNCTION get_checkid(l_invoice_id IN NUMBER)
        RETURN NUMBER
    IS
        l_check_id   NUMBER;

    BEGIN

        SELECT check_id
        INTO   l_check_id
        FROM
        (   SELECT ac.check_id check_id
            FROM ap_invoice_payments aip,
                 ap_checks ac
            WHERE aip.check_id = ac.check_id
            AND   aip.invoice_id = l_invoice_id
            UNION ALL
            SELECT ac.check_id check_id
            FROM ap_invoice_payments aip,
                 ap_checks ac,
	         ap_invoice_lines ail1,
 	         ap_invoice_lines ail2,
                 ap_invoice_distributions aid1,
                 ap_invoice_distributions aid2
            WHERE aip.check_id = ac.check_id
            AND   ail1.invoice_id = l_invoice_id
            AND   ail2.invoice_id = aip.invoice_id
	    AND   aid1.invoice_id = ail1.invoice_id
	    AND   aid1.invoice_line_number = ail1.line_number
	    AND   aid2.invoice_id = ail2.invoice_id
	    AND   aid2.invoice_line_number = ail2.line_number
            AND  (ail1.line_type_lookup_code = 'PREPAY'  OR
                  ail1.line_type_lookup_code = 'TAX'  AND
                  aid1.prepay_tax_parent_id IS NOT NULL
                 )
            AND aid2.invoice_distribution_id = aid1.prepay_distribution_id
        )
        WHERE ROWNUM = 1;


        RETURN(l_check_id);

	EXCEPTION
	 WHEN no_data_found  THEN
	  return(null);
	 WHEN OTHERS THEN
	  raise;
    END get_checkid;

    -----------------------------------------------------------------------
    -- Function get_last_payment_date returns the Payment Date. If multiple
    -- payments and advances are made for a particular invoice, then it
    -- returns the most recent Payment Date
    FUNCTION get_last_payment_date(l_invoice_id IN NUMBER)
        RETURN DATE
    IS
        l_last_payment_date   DATE;

    BEGIN
        SELECT MAX(check_date)
	INTO l_last_payment_date
        FROM
        (   SELECT ac.check_date check_date
            FROM ap_invoice_payments aip,
                 ap_checks ac
            WHERE aip.check_id = ac.check_id
            AND   aip.invoice_id = l_invoice_id
            UNION ALL
            SELECT ac.check_date check_date
            FROM ap_invoice_payments aip,
                 ap_checks ac,
	         ap_invoice_lines ail1,
 	         ap_invoice_lines ail2,
                 ap_invoice_distributions aid1,
                 ap_invoice_distributions aid2
            WHERE aip.check_id = ac.check_id
            AND   ail1.invoice_id = l_invoice_id
            AND   ail2.invoice_id = aip.invoice_id
	    AND   aid1.invoice_id = ail1.invoice_id
	    AND   aid1.invoice_line_number = ail1.line_number
	    AND   aid2.invoice_id = ail2.invoice_id
	    AND   aid2.invoice_line_number = ail2.line_number
            AND  (ail1.line_type_lookup_code = 'PREPAY'  OR
                  ail1.line_type_lookup_code = 'TAX'  AND
                  aid1.prepay_tax_parent_id IS NOT NULL
                 )
            AND aid2.invoice_distribution_id = aid1.prepay_distribution_id
        );


        RETURN(l_last_payment_date);

	EXCEPTION
	 WHEN no_data_found  THEN
	  return(null);
	 WHEN OTHERS THEN
	  raise;
    END get_last_payment_date;

FUNCTION get_prepay_amount_remaining(P_invoice_id IN number,
                                     p_Invoice_num IN VARCHAR2,
                                     p_employee_id IN NUMBER,
                                     p_currency IN VARCHAR2,
                                     P_header_id IN NUMBER DEFAULT NULL,
                                     p_resp_id IN NUMBER DEFAULT NULL,
                                     p_apps_id NUMBER DEFAULT NULL)
			       RETURN number
IS

l_prepay_amt_invoiced NUMBER;
l_prepay_amt_expensed NUMBER;
l_prepay_amt_available NUMBER;

BEGIN

     BEGIN
        IF (nvl(FND_PROFILE.VALUE_SPECIFIC('OIE_CARRY_ADVANCES_FORWARD',NULL,p_resp_id,p_apps_id),'Y') = 'Y' )THEN

            SELECT SUM(nvl(prepay_amount_remaining,amount))
            INTO  l_prepay_amt_invoiced
            FROM  ap_invoice_distributions aid,ap_invoices ai
            WHERE aid.invoice_id = P_invoice_id
            AND   aid.line_type_lookup_code IN ('ITEM','TAX')
            AND   nvl(aid.reversal_flag,'N') <> 'Y'
            AND  ai.invoice_id = P_invoice_id
            AND  ai.earliest_settlement_date IS NOT NULL
            AND  trunc(ai.earliest_settlement_date) <= trunc(SYSDATE);


        ELSE
            SELECT SUM(nvl(prepay_amount_remaining,amount))
            INTO  l_prepay_amt_invoiced
            FROM  ap_invoice_distributions aid,ap_invoices ai
            WHERE aid.invoice_id = P_invoice_id
            AND   aid.line_type_lookup_code IN ('ITEM','TAX')
            AND   nvl(aid.reversal_flag,'N') <> 'Y'
            AND  ai.invoice_id = P_invoice_id
            AND  ai.earliest_settlement_date IS NOT NULL
            AND  trunc(ai.earliest_settlement_date) <= trunc(SYSDATE)
            AND  nvl(prepay_amount_remaining,amount) = aid.amount;

        END IF;

     EXCEPTION WHEN NO_DATA_FOUND THEN
        l_prepay_amt_invoiced := 0;
     END;

     BEGIN

      IF(P_header_id IS NULL) THEN

        select nvl(sum(maximum_amount_to_apply),0)
        INTO l_prepay_amt_expensed
        from ap_expense_report_headers
        where employee_id = p_employee_id
        and vouchno = 0
        and default_currency_code = p_currency
        AND prepay_num = p_Invoice_num
        AND advance_invoice_to_apply = P_invoice_id;

    ELSE

        select nvl(sum(maximum_amount_to_apply),0)
        INTO l_prepay_amt_expensed
        from ap_expense_report_headers
        where employee_id = p_employee_id
        and vouchno = 0
        and default_currency_code = p_currency
        AND prepay_num = p_Invoice_num
        AND advance_invoice_to_apply = P_invoice_id
        AND report_header_id <> P_header_id;

    END IF;

     EXCEPTION WHEN NO_DATA_FOUND THEN
        l_prepay_amt_expensed :=0;
     END ;

     l_prepay_amt_available := l_prepay_amt_invoiced - l_prepay_amt_expensed;

     IF l_prepay_amt_available < 0 OR (nvl(FND_PROFILE.VALUE_SPECIFIC('OIE_CARRY_ADVANCES_FORWARD',NULL,p_resp_id,p_apps_id),'Y') = 'N' AND l_prepay_amt_expensed > 0)THEN
        l_prepay_amt_available := 0;
     END IF;

     RETURN l_prepay_amt_available;

EXCEPTION WHEN OTHERS THEN
     RETURN 0;
END get_prepay_amount_remaining;

FUNCTION get_prepay_balance(P_invoice_id IN number,
                            p_Invoice_num IN VARCHAR2,
                            p_employee_id IN NUMBER,
                            p_currency IN VARCHAR2)
		       RETURN number
IS

l_prepay_amt_invoiced NUMBER;
l_prepay_amt_expensed NUMBER;
l_prepay_amt_available NUMBER;

BEGIN

     BEGIN
         SELECT SUM(NVL(prepay_amount_remaining,amount))
         INTO  l_prepay_amt_invoiced
         FROM  ap_invoice_distributions aid,ap_invoices ai
         WHERE aid.invoice_id = P_invoice_id
         AND   aid.line_type_lookup_code IN ('ITEM','TAX')
         AND   NVL(aid.reversal_flag,'N') <> 'Y'
         AND  ai.invoice_id = P_invoice_id
         AND  ai.earliest_settlement_date IS NOT NULL
         AND  trunc(ai.earliest_settlement_date) <= TRUNC(SYSDATE);


         EXCEPTION WHEN NO_DATA_FOUND THEN
            l_prepay_amt_invoiced := 0;
     END;

     BEGIN

        SELECT NVL(SUM(maximum_amount_to_apply),0)
        INTO l_prepay_amt_expensed
        FROM ap_expense_report_headers
        WHERE employee_id = p_employee_id
        AND vouchno = 0
        AND default_currency_code = p_currency
        AND prepay_num = p_Invoice_num
        AND advance_invoice_to_apply = P_invoice_id;

        EXCEPTION WHEN NO_DATA_FOUND THEN
            l_prepay_amt_expensed :=0;
     END ;

     l_prepay_amt_available := l_prepay_amt_invoiced - l_prepay_amt_expensed;

     RETURN l_prepay_amt_available;

     EXCEPTION WHEN OTHERS THEN
     RETURN 0;
END get_prepay_balance;


FUNCTION get_line_prepay_balance(P_invoice_id IN number,
                                 line_id IN NUMBER)
		       RETURN number
IS

l_prepay_amt_available NUMBER;

BEGIN

     BEGIN
         SELECT SUM(NVL(aid.prepay_amount_remaining,aid.amount))
         INTO  l_prepay_amt_available
         FROM  ap_invoice_distributions aid,ap_invoice_lines al
         WHERE aid.invoice_id = al.invoice_id
         AND aid.invoice_line_number= al.line_number
	 and al.line_number=line_id
         AND   aid.line_type_lookup_code IN ('ITEM','TAX')
         AND   NVL(aid.reversal_flag,'N') <> 'Y'
         AND  al.invoice_id = P_invoice_id;


     END;


      RETURN l_prepay_amt_available;

     EXCEPTION WHEN OTHERS THEN
     RETURN 0;
END get_line_prepay_balance;


END AP_WEB_PAYMENTS_PKG;



/
