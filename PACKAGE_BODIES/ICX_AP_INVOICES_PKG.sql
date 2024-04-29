--------------------------------------------------------
--  DDL for Package Body ICX_AP_INVOICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_AP_INVOICES_PKG" AS
/* $Header: ICXAPINB.pls 115.0 99/08/09 17:21:48 porting ship $ */

     -----------------------------------------------------------------------
     -- Function get_po_number_list returns all the PO Numbers matched to
     -- this invoice (comma delimited) or NULL if not matched.
     --
     FUNCTION get_po_number_list(l_invoice_id IN NUMBER)
         RETURN VARCHAR2
     IS
         po_number      VARCHAR2(20);
         po_number_list VARCHAR2(2000) := NULL;

         ---------------------------------------------------------------------
         -- Declare cursor to retrieve the PO number
         --
         CURSOR po_number_cursor IS
         SELECT DISTINCT(ph.segment1)
         FROM   ap_invoice_distributions aid,
                po_distributions_ap_v    pd,
                po_headers               ph
         WHERE  aid.invoice_id         = l_invoice_id
         AND    aid.po_distribution_id = pd.po_distribution_id
         AND    pd.po_header_id        = ph.po_header_id;

     BEGIN

         OPEN po_number_cursor;

         LOOP
             FETCH po_number_cursor INTO po_number;
             EXIT WHEN po_number_cursor%NOTFOUND;

             IF (po_number_list IS NOT NULL) THEN
                 po_number_list := po_number_list || ', ';
             END IF;

             po_number_list := po_number_list || po_number;

         END LOOP;

         CLOSE po_number_cursor;

         RETURN(po_number_list);

     END get_po_number_list;

     -----------------------------------------------------------------------
     -- Function get_amount_withheld returns the AWT withheld amount on
     -- an invoice.
     --
     FUNCTION get_amount_withheld(l_invoice_id IN NUMBER)
         RETURN NUMBER
     IS
         amount_withheld           NUMBER := 0;
     BEGIN
         select (0 - sum(nvl(amount,0)))
         into   amount_withheld
         from   ap_invoice_distributions
         where  invoice_id = l_invoice_id
         and    line_type_lookup_code = 'AWT';

         return(amount_withheld);

     END get_amount_withheld;

END ICX_AP_INVOICES_PKG;

/
