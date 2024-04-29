--------------------------------------------------------
--  DDL for Package Body ICX_AP_CHECKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_AP_CHECKS_PKG" AS
/* $Header: ICXAPCKB.pls 115.3 2002/01/04 14:00:27 pkm ship      $ */
  -----------------------------------------------------------------------
  -- Function get_invoices_paid returns a comma delimited list of
  -- invoices paid by this check.
  --
  FUNCTION get_invoices_paid (l_check_id IN NUMBER)
      RETURN VARCHAR2
  IS
      l_inv_num         AP_INVOICES.INVOICE_NUM%TYPE;
      l_inv_num_list    VARCHAR2(4000) := NULL;
      l_inv_num_good    VARCHAR2(4000) := NULL; -- newly added

      -------------------------------------------------------------------
      -- Declare cursor to return the Invoice number
      --
      CURSOR inv_num_cursor IS
      SELECT ai.invoice_num
      FROM   ap_invoices         ai,
             ap_invoice_payments aip
      WHERE  aip.check_id   = l_check_id
      AND    aip.invoice_id = ai.invoice_id;

  BEGIN

      OPEN inv_num_cursor;

      LOOP
          FETCH inv_num_cursor INTO l_inv_num;
          EXIT WHEN inv_num_cursor%NOTFOUND;

          IF (l_inv_num_list IS NOT NULL) THEN
              l_inv_num_list := l_inv_num_list || ', ';
          END IF;

          l_inv_num_list := l_inv_num_list || l_inv_num;

          l_inv_num_good := l_inv_num_list;   -- newly added

      END LOOP;

      CLOSE inv_num_cursor;

      RETURN(l_inv_num_list);

 EXCEPTION       -- newly added
   WHEN OTHERS THEN   -- newly added

     RETURN(l_inv_num_good);  -- newly added

  END get_invoices_paid;

END ICX_AP_CHECKS_PKG;

/
