--------------------------------------------------------
--  DDL for Package Body POS_AP_INVOICE_PAYMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_AP_INVOICE_PAYMENTS_PKG" AS
/* $Header: POSAPPAB.pls 115.0 2001/06/18 18:42:23 pkm ship        $ */

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
            type_trans      ap_lookup_codes.displayed_field%TYPE,
            method          ap_checks.payment_method_lookup_code%TYPE,
            method_trans    ap_lookup_codes.displayed_field%TYPE);

    -----------------------------------------------------------------------
    -- Declare generic cursor to get check number, check id, invoice number
    -- invoice id, payment type, payment method lookup code, and translated
    -- payment method
    --
    --togeorge 11/15/2000
    --changed org specific views to _all tables
    CURSOR payment_cursor (l_invoice_id NUMBER, l_payment_num NUMBER)
    RETURN payment_record IS
    SELECT ac.check_number,
           ac.check_id,
           ac.check_date,
           ai.invoice_num,
           ai.invoice_id,
           aip.accounting_date,
           aip.invoice_payment_type,
           alc1.displayed_field,
           ac.payment_method_lookup_code,
           alc2.displayed_field
    FROM   ap_invoice_payments_all aip, --ap_invoice_payments
           ap_checks_all           ac,  --ap_checks
           ap_invoices_all         ai,  --ap_invoices
           ap_lookup_codes     alc1,
           ap_lookup_codes     alc2
    WHERE  aip.invoice_id       = l_invoice_id
    AND    aip.payment_num      = l_payment_num
    AND    aip.check_id         = ac.check_id
    AND    aip.other_invoice_id = ai.invoice_id (+)
    AND    alc1.lookup_type     = 'NLS TRANSLATION'
    AND    alc1.lookup_code     = 'PREPAY'
    AND    alc2.lookup_type     = 'PAYMENT METHOD'
    AND    alc2.lookup_code     = ac.payment_method_lookup_code;

    -----------------------------------------------------------------------
    -- Function concat_document_num_type concatenates the document number
    -- to the document type
    --
    FUNCTION concat_document_num_type(l_payment_record IN PAYMENT_RECORD)
        RETURN VARCHAR2
    IS
        l_paid_by VARCHAR2(80);
    BEGIN

        IF (l_payment_record.type = 'PREPAY') THEN
            -------------------------------------------------------
            -- Get prepayment number concatenated to prepayment type
            --
            l_paid_by := l_payment_record.invoice_num ||' - '||
                         l_payment_record.type_trans;
        ELSE
            -------------------------------------------------------
            -- Get payment number concatenated to payment method type
            --
            l_paid_by := l_payment_record.check_number ||' - '||
                         l_payment_record.method_trans;
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

            l_paid_by := POS_AP_INVOICE_PAYMENTS_PKG.CONCAT_DOCUMENT_NUM_TYPE(
                                                        l_payment_record);

            IF (l_paid_by_list IS NOT NULL) THEN
                l_paid_by_list := l_paid_by_list || ', ';
            END IF;

            l_paid_by_list := l_paid_by_list || l_paid_by;

        END LOOP;

        CLOSE payment_cursor;

        RETURN(l_paid_by_list);

    END get_paid_by_list;

END POS_AP_INVOICE_PAYMENTS_PKG;

/
