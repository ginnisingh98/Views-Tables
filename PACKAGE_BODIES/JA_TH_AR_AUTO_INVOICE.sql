--------------------------------------------------------
--  DDL for Package Body JA_TH_AR_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_TH_AR_AUTO_INVOICE" as
/* $Header: jathraib.pls 120.2 2005/10/30 01:47:55 appldev ship $ */

  FUNCTION validate_tax_invoice(p_request_id  IN NUMBER)
  RETURN NUMBER IS

    CURSOR tax_invoice_headers(c_request_id NUMBER) IS
      SELECT distinct
             l.customer_trx_id,
             l.cust_trx_type_id,
             l.trx_date,
             fnd_date.canonical_to_date(t.global_attribute2) last_issued_date,
             to_number(t.global_attribute3) advance_days,
             l.tax_code, -- 1971523
             l.vat_tax_id,
             l.line_type
      FROM   ra_interface_lines_gt l,
             ra_cust_trx_types t
      WHERE  l.request_id = c_request_id
      AND    t.cust_trx_type_id = l.cust_trx_type_id
      AND    nvl(t.global_attribute1, 'N') = 'Y';

    return_code  NUMBER;
    validation1  NUMBER;
    validation2  NUMBER;
    validation3  NUMBER;

  BEGIN
    arp_standard.debug('ja_th_auto_invoice.validate_tax_invoice()+');

    return_code := 1;

    FOR h IN tax_invoice_headers(p_request_id)
    LOOP

      validation1 := ja_th_ar_tax_invoice.validate_trx_date(
                       h.customer_trx_id,
                       h.trx_date,
                       h.last_issued_date,
                       h.advance_days,
                       'RAXTRX');

      -- Bug 1971523
      IF h.line_type = 'LINE' AND (h.tax_code IS NULL OR h.vat_tax_id IS NULL) THEN
        validation2 := 1;
      ELSE
        validation2 := ja_th_ar_tax_invoice.validate_tax_code(
                       h.customer_trx_id,
                       'RAXTRX');
      END IF;

      IF validation1 = 1 AND validation2 = 1 THEN
        validation3 := ja_th_ar_tax_invoice.update_last_issued_date(
                         h.customer_trx_id,
                         h.cust_trx_type_id,
                         h.trx_date,
                         'RAXTRX');
      END IF;

      IF validation1 = -1 OR validation2 = -1 OR validation3 = -1 THEN
        -- At the first sign of Fatal error, quite validation with
        -- return_code=0.
        return_code := 0;
        exit;
      END IF;

    END LOOP;

    arp_standard.debug('ja_th_auto_invoice.validate_tax_invoice()-');

    return(return_code);

  EXCEPTION
    WHEN others THEN

      arp_standard.debug('-- Return From Exception when others');
      arp_standard.debug('-- Return Code: 0');
      arp_standard.debug('ja_th_auto_invoice.validate_gdff()-');

      return(0);

  END validate_tax_invoice;

END ja_th_ar_auto_invoice;

/
