--------------------------------------------------------
--  DDL for Package Body AP_PO_GAPLESS_SBI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_PO_GAPLESS_SBI_PKG" AS
/* $Header: apposbib.pls 120.1 2006/05/04 19:27:25 bghose noship $ */

function this_is_dup_inv_num(
    p_invoice_num                   IN VARCHAR2,
    p_selling_co_id                 IN VARCHAR2)

 RETURN BOOLEAN IS

   l_vendor_id                 AP_INVOICES_ALL.vendor_id%TYPE;
   l_org_id                    number(15);
   l_dup_invoices              AP_INVOICES_ALL.invoice_num%TYPE;
   l_dup_interface             AP_INVOICES_INTERFACE.invoice_num%TYPE;
   l_dup_history               AP_HISTORY_INVOICES_ALL.invoice_num%TYPE;

 BEGIN

   -- Deriving the Value of the Vendor_Id

    	SELECT vendor_id,
               org_id
	INTO   l_vendor_id,
               l_org_id
	FROM   PO_VENDOR_SITES
	WHERE  selling_company_identifier = p_selling_co_id
	AND rownum = 1;

   -- Checking for duplicates in AP_INVOICES_ALL table

    Begin
	SELECT invoice_num
	INTO l_dup_invoices
	FROM AP_INVOICES_ALL
	WHERE invoice_num = p_invoice_num
	AND vendor_id = l_vendor_id
        AND org_id = l_org_id;
    Exception
    When NO_DATA_FOUND Then
    l_dup_invoices := Null;
    End;

   -- Checking for duplicates in AP_INVOICES_INTERFACE table

   IF l_dup_invoices is Null  THEN
    Begin

	SELECT invoice_num
	INTO l_dup_interface
	FROM AP_INVOICES_INTERFACE
	WHERE invoice_num = p_invoice_num
	AND vendor_id = l_vendor_id
        AND status <> 'PROCESSED'
        AND rownum = 1;
    Exception
    When NO_DATA_FOUND Then
    l_dup_interface := NULL;
    End;

   END IF;

   -- Checking for duplicates in AP_HISTORY_INVOICES_ALL table

   IF (l_dup_interface is Null AND l_dup_invoices is Null) THEN
    Begin

        SELECT invoice_num
        INTO l_dup_history
        FROM AP_HISTORY_INVOICES_ALL
        WHERE invoice_num = p_invoice_num
        AND vendor_id = l_vendor_id
        AND org_id = l_org_id;
    Exception
      When NO_DATA_FOUND Then
      l_dup_history := Null;
    END;

   END IF;

   -- Setting the values of the out variables.

        IF ((l_dup_invoices IS NOT NULL) OR
           (l_dup_interface IS NOT NULL) OR
           (l_dup_history IS NOT NULL)) THEN
           RETURN(TRUE);
        ELSE
           RETURN(FALSE);
	END IF;

   EXCEPTION
   -- Trap unknown error
   WHEN OTHERS THEN
      RETURN(FALSE);
 END this_is_dup_inv_num;


PROCEDURE site_uses_gapless_num(
    p_site_id                       IN NUMBER,
    x_gapless_inv_num_flag          OUT NOCOPY VARCHAR2,
    x_selling_company_id            OUT NOCOPY VARCHAR2
    )

IS

	l_gapless_inv_num	VARCHAR2(1);
	l_selling_co_id         VARCHAR2(10);
        l_alt_site_id           NUMBER;      --Bug 3628373
	l_source_site_id        NUMBER;      --Bug 3628373

   BEGIN

	Select default_pay_site_id
  	Into l_alt_site_id
	From PO_VENDOR_SITES_ALL
	Where vendor_site_id = p_site_id;   --Bug 3628373

	If l_alt_site_id is Not Null THEN
           l_source_site_id := l_alt_site_id;
        Else l_source_site_id := p_site_id;
        End If;                             --Bug 3628373

	SELECT NVL(gapless_inv_num_flag, 'N'),  /* Bug 5197828 */
       	       selling_company_identifier
	INTO   x_gapless_inv_num_flag,
  	       x_selling_company_id
	FROM PO_VENDOR_SITES_ALL
	WHERE vendor_site_id = l_source_site_id;

        /* Bug 5197828 */
        --If l_gapless_inv_num is Not Null Then
        --     x_gapless_inv_num_flag := 'Y';
        --Else x_gapless_inv_num_flag := 'N';
        --End If;
        --x_selling_company_id := l_selling_co_id;

   EXCEPTION
   -- Trap unknown error
   WHEN OTHERS THEN
     x_gapless_inv_num_flag := 'N';
     x_selling_company_id := Null;

END site_uses_gapless_num;

END AP_PO_GAPLESS_SBI_PKG;


/
