--------------------------------------------------------
--  DDL for Package Body AP_IMPORT_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_IMPORT_VALIDATION_PKG" AS
/* $Header: apiimvtb.pls 120.121.12010000.75 2010/12/24 06:39:39 pgayen ship $ */

------------------------------------------------------------------------
-- This function is used to perform invoice header level validations.
--
------------------------------------------------------------------------

-- bug 8497933
l_is_inv_date_null	 VARCHAR2(1);
-- bug 8497933

FUNCTION v_check_invoice_validation(
           p_invoice_rec                 IN OUT NOCOPY
             AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
           p_match_mode                     OUT NOCOPY VARCHAR2,
           p_min_acct_unit_inv_curr         OUT NOCOPY NUMBER,
           p_precision_inv_curr             OUT NOCOPY NUMBER,
	   p_positive_price_tolerance      OUT NOCOPY      NUMBER,
	   p_negative_price_tolerance      OUT NOCOPY      NUMBER,
	   p_qty_tolerance                 OUT NOCOPY      NUMBER,
	   p_qty_rec_tolerance             OUT NOCOPY      NUMBER,
	   p_max_qty_ord_tolerance         OUT NOCOPY      NUMBER,
	   p_max_qty_rec_tolerance         OUT NOCOPY      NUMBER,
	   p_amt_tolerance		   OUT NOCOPY      NUMBER,
	   p_amt_rec_tolerance		   OUT NOCOPY	   NUMBER,
	   p_max_amt_ord_tolerance         OUT NOCOPY      NUMBER,
	   p_max_amt_rec_tolerance         OUT NOCOPY      NUMBER,
	   p_goods_ship_amt_tolerance      OUT NOCOPY      NUMBER,
	   p_goods_rate_amt_tolerance      OUT NOCOPY      NUMBER,
	   p_goods_total_amt_tolerance     OUT NOCOPY      NUMBER,
	   p_services_ship_amt_tolerance   OUT NOCOPY      NUMBER,
	   p_services_rate_amt_tolerance   OUT NOCOPY      NUMBER,
	   p_services_total_amt_tolerance  OUT NOCOPY      NUMBER,
           p_base_currency_code          IN            VARCHAR2,
           p_multi_currency_flag         IN            VARCHAR2,
           p_set_of_books_id             IN            NUMBER,
           p_default_exchange_rate_type  IN            VARCHAR2,
           p_make_rate_mandatory_flag    IN            VARCHAR2,
           p_default_last_updated_by     IN            NUMBER,
           p_default_last_update_login   IN            NUMBER,
           p_fatal_error_flag            OUT NOCOPY    VARCHAR2,
           p_current_invoice_status      IN OUT NOCOPY VARCHAR2,
           p_calc_user_xrate             IN            VARCHAR2,
           p_prepay_period_name          IN OUT NOCOPY VARCHAR2,
	   p_prepay_invoice_id		 OUT NOCOPY    NUMBER,
	   p_prepay_case_name		 OUT NOCOPY    VARCHAR2,
           p_request_id                  IN            NUMBER,
	   p_allow_interest_invoices     IN	       VARCHAR2, --Bug4113223
           p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN IS

  check_inv_validation_failure  EXCEPTION;
  import_invoice_failure	EXCEPTION;

  l_current_invoice_status      VARCHAR2(1) := 'Y';
  l_vendor_id                   PO_VENDORS.VENDOR_ID%TYPE;
  l_vendor_site_id              PO_VENDOR_SITES.VENDOR_SITE_ID%TYPE;
  l_vendor_site_id_per_po       PO_VENDOR_SITES.VENDOR_SITE_ID%TYPE;
  l_invoice_num                 AP_INVOICES.INVOICE_NUM%TYPE;
  l_inv_currency_code           AP_INVOICES.INVOICE_CURRENCY_CODE%TYPE;
  l_exchange_rate               AP_INVOICES.EXCHANGE_RATE%TYPE;
  l_exchange_date               AP_INVOICES.EXCHANGE_DATE%TYPE;
  l_invoice_type_lookup_code    AP_INVOICES.INVOICE_TYPE_LOOKUP_CODE%TYPE;
  l_awt_group_id                AP_INVOICES.AWT_GROUP_ID%TYPE;
  l_pay_awt_group_id            AP_INVOICES.PAY_AWT_GROUP_ID%TYPE;--bug6639866
  l_terms_id                    AP_INVOICES.TERMS_ID%TYPE;
  l_terms_date                  AP_INVOICES.TERMS_DATE%TYPE;
  l_pay_currency_code           AP_INVOICES.PAYMENT_CURRENCY_CODE%TYPE;
  l_pay_cross_rate_date         AP_INVOICES.PAYMENT_CROSS_RATE_DATE%TYPE;
  l_pay_cross_rate              AP_INVOICES.PAYMENT_CROSS_RATE%TYPE;
  l_pay_cross_rate_type         AP_INVOICES.PAYMENT_CROSS_RATE_TYPE%TYPE;
  l_invoice_base_amount         AP_INVOICES.BASE_AMOUNT%TYPE;
  l_temp_invoice_status         VARCHAR2(1) := 'Y';
  l_po_exists_flag              VARCHAR2(1) := 'N';
  current_calling_sequence      VARCHAR2(2000);
  debug_info                    VARCHAR2(500);
  l_terms_date_basis            VARCHAR2(25);
  l_primary_paysite_id          PO_VENDOR_SITES.VENDOR_SITE_ID%TYPE;
  --For bug 2713327 Added temporary variable to hold the value of
  --vendor_id in the interface table
  l_temp_vendor_id                NUMBER(15) := p_invoice_rec.vendor_id;
  --Bug 4051803
  l_positive_price_tolerance      NUMBER;
  l_negative_price_tolerance      NUMBER;
  l_qty_tolerance                 NUMBER;
  l_qty_rec_tolerance             NUMBER;
  l_max_qty_ord_tolerance         NUMBER;
  l_max_qty_rec_tolerance         NUMBER;
  l_max_amt_ord_tolerance         NUMBER;
  l_max_amt_rec_tolerance         NUMBER;
  l_ship_amt_tolerance            NUMBER;
  l_rate_amt_tolerance            NUMBER;
  l_total_amt_tolerance           NUMBER;

  l_party_site_id                 NUMBER(15);
  /* 9738820 additional parameters */
  l_country_code                  HR_LOCATIONS_ALL.COUNTRY%TYPE;
  l_return_status                 VARCHAR2(1);
  l_msg_count                     NUMBER;
  l_msg_data                      VARCHAR2(1000);
  /* End Bug 9738820 parameters */

BEGIN

  -- Update the calling sequence
  current_calling_sequence :=
             'AP_IMPORT_VALIDATION_PKG.v_check_invoice_validation<-'
             ||P_calling_sequence;

  --------------------------------------------------------------------------
  -- Step 0a
  -- Initialize invoice_date if null
  --------------------------------------------------------------------------
  debug_info := '(Check Invoice Validation 0) Initialize invoice_date if null';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  IF (p_invoice_rec.invoice_date IS NULL) THEN
    p_invoice_rec.invoice_date := trunc(AP_IMPORT_INVOICES_PKG.g_inv_sysdate);
    -- bug 8497933
    l_is_inv_date_null := 'Y';
  ELSE
    l_is_inv_date_null := 'N';
    -- bug 8497933
  END IF;

  --------------------------------------------------------------------------
  -- Step 1
  -- Check for Invalid or Inactive PO
  --------------------------------------------------------------------------
  debug_info :=
     '(Check Invoice Validation 1) Check for Invalid and Inactive PO';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;
  --
  IF (p_invoice_rec.po_number IS NOT NULL) THEN
    -- IF PO Number is given , we should not check for Supplier Number
    -- or Supplier Site.  PO Number can also be used for this check, but a
    -- flag is set for this purpose.
    l_po_exists_flag := 'Y';

    IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_po (
          p_invoice_rec,                                  -- IN
          p_default_last_updated_by,                      -- IN
          p_default_last_update_login,                    -- IN
          l_temp_invoice_status,                          -- OUT
          p_po_vendor_id      => l_vendor_id,             -- OUT
          p_po_vendor_site_id => l_vendor_site_id_per_po, -- OUT
          p_po_exists_flag    => l_po_exists_flag,        -- OUT
          p_calling_sequence  => current_calling_sequence) <> TRUE )THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                     'v_check_invalid_po<-'||current_calling_sequence);
      END IF;
      RAISE check_inv_validation_failure;
    END IF;

    -- We need to set the current status to 'N' only if the temp invoice status
    -- returns 'N'. So all temp returns of 'N' will overwrite the current
    -- invoice status to 'N' which finally would be returned to the calling
    -- function.
    IF (l_temp_invoice_status = 'N') THEN
      l_current_invoice_status := l_temp_invoice_status;
    END IF;

    --
    -- show output values (only if debug_switch = 'Y')
    --
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                '------------------>
                l_temp_invoice_status   = '||l_temp_invoice_status
            ||' l_vendor_id             = '||to_char(l_vendor_id)
            ||' l_vendor_site_id_per_po = '||to_char(l_vendor_site_id_per_po)
            ||' l_po_exists_flag        = '||l_po_exists_flag);
    END IF;

    -- It is possible to create a PO for a Supplier / Supplier Site
    -- that has been end dated or in some other way invalidated
    -- before running  the import.  If the PO exists it is assumed
    -- that the Supplier /  Supplier Site is valid.  This allows an
    -- invoice to be created for an invalid Supplier / Supplier Site.
    -- We no longer check the PO flag before validating the Supplier
    -- info.  Also since we are no longer assuming a correct Supplier
    -- if the PO exists, we have to get the  vendor_id from the PO if
    -- it is not in the Interface table row.
    IF (p_invoice_rec.vendor_id IS NULL AND l_po_exists_flag = 'Y') then
      p_invoice_rec.vendor_id := l_vendor_id;
    END IF;

  END IF; -- p_invoice_rec.po_number is not null

  ---------------------------------------------------------------------------
  -- Step 2
  -- Check for Invalid or Inconsistent Legal Entity Name and Id
  ---------------------------------------------------------------------------
  debug_info := '(Check Invoice Validation 2) Check for Invalid Legal Entity';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

-- YIDSAL.  Include here call the validate function for the LE Id and NaMe
--  Surekha will give us the API name.

  ---------------------------------------------------------------------------
  -- Step 3
  -- Check for Invalid Supplier or Inconsistent Supplier
  ---------------------------------------------------------------------------
  debug_info := '(Check Invoice Validation 2) Check for Invalid Supplier';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  -- Added party validation for payment request project
  IF p_invoice_rec.invoice_type_lookup_code = 'PAYMENT REQUEST' THEN

     IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_party (
        p_invoice_rec,                                       -- IN
        p_default_last_updated_by,                           -- IN
        p_default_last_update_login,                         -- IN
        p_current_invoice_status => l_temp_invoice_status,   -- IN OUT
        p_calling_sequence       => current_calling_sequence) <> TRUE )THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'v_check_invalid_party <-'||current_calling_sequence);
        END IF;
        RAISE check_inv_validation_failure;
      END IF;

  ELSE

      IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_supplier (
            p_invoice_rec,                                       -- IN
            p_default_last_updated_by,                           -- IN
            p_default_last_update_login,                         -- IN
            p_return_vendor_id       => l_vendor_id,             -- OUT
            p_current_invoice_status => l_temp_invoice_status,   -- IN OUT
            p_calling_sequence       => current_calling_sequence) <> TRUE )THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'v_check_invalid_supplier<-'||current_calling_sequence);
        END IF;
        RAISE check_inv_validation_failure;
      END IF;

      IF p_invoice_rec.vendor_id IS NULL  THEN
         p_invoice_rec.vendor_id := l_vendor_id;

      END IF;

  END IF;

 --For bug 2713327 changed p_invoice_rec.vendor_id to l_temp_vendor_id
 --At this point the value of p_invoice_rec.vendor_id will not be NULL as
 --it would have been retrieved from PO if one exists or it would have been keyed in.
 --So the value of vendor id in interface table should be updated with correct value
 --for retrieving the output as it is checking for ii.vendor_id=i.vendor_id in
 --the query Q_AUDIT

 --added nvl for bug 7314487
  IF l_temp_vendor_id is NULL
              AND nvl(p_invoice_rec.invoice_type_lookup_code,'STANDARD') <> 'PAYMENT REQUEST'
  THEN UPDATE ap_invoices_interface
       SET vendor_id = l_vendor_id
       WHERE invoice_id = p_invoice_rec.invoice_id;
  END IF;

  IF (l_temp_invoice_status = 'N') THEN
    l_current_invoice_status := l_temp_invoice_status;
  END IF;

  debug_info := '(Check Invoice Validation 2) Validated Supplier';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;
  --
  -- show output values (only if debug_switch = 'Y')
  --
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '------------------>
            l_temp_invoice_status  = '||l_temp_invoice_status
        ||' l_vendor_id             = '||to_char(l_vendor_id));
  END IF;

  IF (p_invoice_rec.vendor_id is NOT NULL)
           OR (p_invoice_rec.party_id IS NOT NULL) THEN

    -------------------------------------------------------------------------
    -- Step 4
    -- Check for Invalid Supplier Site only if there is a valid Supplier
    -- Also, populate vendor_site_id if all the following
    -- conditions are met:
    -- 1) vendor_site_id is null
    -- 2) vendor_site_id could be derived in the find primary paysite function
    --    or the vendor site check function
    -- 3) if either the find primary paysite succeded or the vendor site
    --    check function returned that the invoice is valid
    --    as far as vendor site is concerned.
    -------------------------------------------------------------------------
    debug_info := '(Check Invoice Validation 3) '||
                   'Check for Invalid Supplier Site, if Supplier is valid';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;


    -- Payment Request: Added Payment Request invoice type to the IF condition

    -- Check for invalid supplier site.  If an invalid supplier site exists,
    -- or inconsistent data exists, this is a fatal error.
    -- Do not perform further validation.  If a valid vendor site exists,
    -- the function will return the value of the vendor site.
    IF ((p_invoice_rec.vendor_site_id is null) and
        (p_invoice_rec.vendor_site_code is null) and
        --(p_invoice_rec.invoice_type_lookup_code <> 'PAYMENT REQUEST')) Then   .. B# 8528132
        (nvl(p_invoice_rec.invoice_type_lookup_code, 'STANDARD') <> 'PAYMENT REQUEST')) Then   -- B# 8528132

      debug_info := '(Check Invoice Validation 3.1) Supplier Site is per PO';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.find_vendor_primary_paysite(
            p_vendor_id                  => p_invoice_rec.vendor_id, -- IN
            p_vendor_primary_paysite_id  => l_primary_paysite_id,    -- OUT
            p_calling_sequence           => current_calling_sequence)
            <> true ) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'find_vendor_primary_paysite<-'||current_calling_sequence);
        END IF;
        RAISE check_inv_validation_failure;
      END IF;

      IF (l_primary_paysite_id is NOT NULL ) THEN
        p_invoice_rec.vendor_site_id := l_primary_paysite_id;
      ELSE
        p_invoice_rec.vendor_site_id := l_vendor_site_id_per_po;
      END IF;

    ELSE
      debug_info := '(Check Invoice Validation 3.2) Supplier Site is per EDI';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          debug_info);
      END IF;

    END IF;


    --Bug8323165 Start
    IF (p_invoice_rec.invoice_type_lookup_code = 'PAYMENT REQUEST' AND
        NVL(p_invoice_rec.source,'A') NOT IN
       ('CREDIT CARD','SelfService','Both Pay','XpenseXpress')) THEN

        IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_party_site (
              p_invoice_rec,                                       -- IN
              p_default_last_updated_by,                           -- IN
              p_default_last_update_login,                         -- IN
              p_return_party_site_id    => l_party_site_id,        -- OUT
              p_terms_date_basis        => l_terms_date_basis,     -- OUT
              p_current_invoice_status  => l_temp_invoice_status,  -- IN OUT
              p_calling_sequence => current_calling_sequence) <> TRUE ) THEN

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  'v_check_invalid_party_site<-'
                                  ||current_calling_sequence);
          END IF;
          RAISE check_inv_validation_failure;
        END IF;
        p_invoice_rec.party_site_id := l_party_site_id;
    ELSE
        IF (p_invoice_rec.invoice_type_lookup_code = 'PAYMENT REQUEST'
            OR (p_invoice_rec.invoice_type_lookup_code = 'EXPENSE REPORT'
            AND p_invoice_rec.party_site_id IS NOT NULL)
            AND NVL(p_invoice_rec.source,'A') IN ('CREDIT CARD','SelfService'
                ,'Both Pay','XpenseXpress')) THEN

            IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_party_site (
              p_invoice_rec,                                       -- IN
              p_default_last_updated_by,                           -- IN
              p_default_last_update_login,                         -- IN
              p_return_party_site_id    => l_party_site_id,        -- OUT
              p_terms_date_basis        => l_terms_date_basis,     -- OUT
              p_current_invoice_status  => l_temp_invoice_status,  -- IN OUT
              p_calling_sequence => current_calling_sequence) <> TRUE ) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                  AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  'v_check_invalid_party_site<-'
                                  ||current_calling_sequence);
              END IF;
              RAISE check_inv_validation_failure;
            END IF;
            p_invoice_rec.party_site_id := l_party_site_id;
        END IF;

        IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_supplier_site (
            p_invoice_rec,                                       -- IN
            l_vendor_site_id_per_po,                             -- IN
            p_default_last_updated_by,                           -- IN
            p_default_last_update_login,                         -- IN
            p_return_vendor_site_id   => l_vendor_site_id,       -- OUT
            p_terms_date_basis        => l_terms_date_basis,     -- OUT
            p_current_invoice_status  => l_temp_invoice_status,  -- IN OUT
            p_calling_sequence => current_calling_sequence) <> TRUE ) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      'v_check_invalid_supplier_site<-'
                                      ||current_calling_sequence);
              END IF;
              RAISE check_inv_validation_failure;
            END IF;
            p_invoice_rec.vendor_site_id := l_vendor_site_id;
    END IF;
    --Bug8323165 End

    IF (l_temp_invoice_status = 'N') THEN
      l_current_invoice_status := l_temp_invoice_status;
    /*ELSE
      --Bug 6711062
      IF (p_invoice_rec.invoice_type_lookup_code = 'PAYMENT REQUEST'
            OR (p_invoice_rec.invoice_type_lookup_code = 'EXPENSE REPORT' --Bug 8247859
            AND p_invoice_rec.party_site_id is NOT NULL))  THEN --Bug 8247859
         p_invoice_rec.party_site_id := l_party_site_id;
      ELSE
         p_invoice_rec.vendor_site_id := l_vendor_site_id;
         p_invoice_rec.party_site_id := l_party_site_id;
      END IF;*/ --Removed this assignment immediately after calling validation of party site and vendor site
    END IF;

    debug_info := '(Check Invoice Validation 3) Validated Supplier Site';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    --
    -- show output values (only if debug_switch = 'Y')
    --
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------>
            l_temp_invoice_status        = '||l_temp_invoice_status
        ||' l_vendor_site_id         = '||to_char(l_vendor_site_id)
        ||' l_party_site_id          = '||to_char(l_party_site_id));

    END IF;



    --we should make sure the party and supplier info is consistent as well as
    --populate the id's that may be missing

    if(AP_IMPORT_VALIDATION_PKG.v_check_party_vendor(
        p_invoice_rec,
        l_temp_invoice_status,
        current_calling_sequence,
        p_default_last_updated_by,
        p_default_last_update_login) <> TRUE) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        'v_check_party_vendor<-'
                                        ||current_calling_sequence);
      END IF;
      RAISE check_inv_validation_failure;
    END IF;

    IF (l_temp_invoice_status = 'N') THEN
      l_current_invoice_status := l_temp_invoice_status;
    END IF;

    debug_info := '(Check Invoice Validation 3.5) Validated party and vendor info ' ||
                  'l_temp_invoice_status = '||l_temp_invoice_status;
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;



    --Bug:4051803
    --Contract Payments: Tolerances Redesign, added the max_amt_ord and max_amt_rec
    --tolerances.
    IF (p_invoice_rec.vendor_site_id IS NOT NULL AND
          --p_invoice_rec.invoice_type_lookup_code <> 'PAYMENT REQUEST') THEN   .. B# 8528132
          nvl(p_invoice_rec.invoice_type_lookup_code, 'STANDARD') <> 'PAYMENT REQUEST') Then   -- B# 8528132
       IF ( ap_import_utilities_pkg.get_tolerance_info(
       		p_invoice_rec.vendor_site_id,   -- IN
		p_positive_price_tolerance,     -- OUT
		p_negative_price_tolerance,     -- OUT
	        p_qty_tolerance,                -- OUT
	        p_qty_rec_tolerance,            -- OUT
	        p_max_qty_ord_tolerance,        -- OUT
	        p_max_qty_rec_tolerance,        -- OUT
		p_amt_tolerance,		-- OUT
		p_amt_rec_tolerance,		-- OUT
		p_max_amt_ord_tolerance,        -- OUT
	        p_max_amt_rec_tolerance,        -- OUT
	        p_goods_ship_amt_tolerance,     -- OUT
	        p_goods_rate_amt_tolerance,     -- OUT
	        p_goods_total_amt_tolerance,    -- OUT
		p_services_ship_amt_tolerance,  -- OUT
	        p_services_rate_amt_tolerance,  -- OUT
	        p_services_total_amt_tolerance, -- OUT
	        current_calling_sequence
	        ) <> TRUE) THEN

             if AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' then
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, 'get_tolerance_info()<-'||
	                     current_calling_sequence);
             end if;
             RAISE import_invoice_failure;
        END IF;
    END IF;


    IF ((p_invoice_rec.vendor_site_id is NOT NULL)
            OR (p_invoice_rec.party_site_id IS NOT NULL)) THEN

      -----------------------------------------------------------------------
      -- Step 5
      -- Check for invoice number already in use within either
      -- the permanent tables or interface tables.  If the invoice
      -- number is already in use, this is a fatal error.  Do not
      -- perform further validation checking.
      -- Check performed only if there is a valid Supplier and Supplier Site
      -----------------------------------------------------------------------
      debug_info := '(Check Invoice Validation 4) '||
                     'Check for Invalid Invoice Number '||
                     ',if Supplier Site is valid';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_invoice_num (
            p_invoice_rec,                                           -- IN
	    --bug4113223
	    p_allow_interest_invoices,				     -- IN
            l_invoice_num,                                           -- OUT
            p_default_last_updated_by,                               -- IN
            p_default_last_update_login,                             -- IN
            p_current_invoice_status     => l_temp_invoice_status,   -- IN OUT
            p_calling_sequence           => current_calling_sequence)
            <> TRUE ) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'v_check_invalid_invoice_num<- '||current_calling_sequence);
        END IF;
        RAISE check_inv_validation_failure;
      END IF;

      IF (l_temp_invoice_status = 'N') THEN
        l_current_invoice_status := l_temp_invoice_status;
      ELSE
        IF (p_invoice_rec.invoice_num is NULL AND
        l_invoice_num is not NULL) THEN
          p_invoice_rec.invoice_num := l_invoice_num;
        END IF;
      END IF;

      --
      -- show output values (only if debug_switch = 'Y')
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '------------------> l_temp_invoice_status  = '||l_temp_invoice_status);
      END IF;

      -- only continue if a valid invoice number was found
      IF l_current_invoice_status = 'Y' THEN

        -----------------------------------------------------------------------
        -- Step 6
        -- Check for Invalid Currency Code only if there is a valid Invoice No
        -- Also, populate currency code if all the following
        -- conditions are met:
        -- 1) invoice_currency_code is null
        -- 2) invoice_currency_code could be derived in the inv curr
        --    check function
        -- 3) the inv curr check function returned that the invoice is valid
        --    as far as inv currency code is concerned.
        -----------------------------------------------------------------------
        debug_info := '(Check Invoice Validation 5) Check for Currency Code ,'
                      ||'if Invoice No. is valid';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_inv_curr_code (
            p_invoice_rec,                                             -- IN
            p_inv_currency_code      => l_inv_currency_code,           -- OUT
            p_min_acc_unit_inv_curr  => p_min_acct_unit_inv_curr,      -- OUT
            p_precision_inv_curr     => p_precision_inv_curr,          -- OUT
            p_default_last_updated_by => p_default_last_updated_by,    -- IN
            p_default_last_update_login => p_default_last_update_login,-- IN
            p_current_invoice_status => l_temp_invoice_status,         -- IN OUT
            p_calling_sequence       => current_calling_sequence)
              <> TRUE ) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'v_check_invalid_currency_code<-'||current_calling_sequence);
          END IF;
          RAISE check_inv_validation_failure;
        END IF;

        IF (l_temp_invoice_status = 'N') THEN
          l_current_invoice_status := l_temp_invoice_status;
        ELSE
          IF (p_invoice_rec.invoice_currency_code is NULL AND
              l_inv_currency_code is not NULL) THEN
            p_invoice_rec.invoice_currency_code := l_inv_currency_code;
          END IF;
        END IF;
        --

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '--------------> l_temp_invoice_status  = ' ||l_temp_invoice_status
            ||' l_inv_currency_code = '|| l_inv_currency_code);
        END IF;

        ----------------------------------------------------------------------
        -- Step 7
        -- Check for Invalid Invoice Lookup Code and Amt.
        -- only if there is a valid Invoice No.
        -- Also, populate invoice type lookup code if all the following
        -- conditions are met:
        -- 1) invoice_type_lookup_code is null null
        -- 2) invoice_type lookup_code could be derived in the invoice type
        --    check function and
        -- 3) the invoice type check function returned that the invoice is
        --    valid as far as invoice type/amount information is concerned.
        ----------------------------------------------------------------------
        debug_info := '(Check Invoice Validation 6) Check for Invoice Lookup '
                      ||'Code and Amount ,if Invoice No. is valid';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF (AP_IMPORT_VALIDATION_PKG.v_check_invoice_type_amount (
              p_invoice_rec,                                          -- IN
              l_invoice_type_lookup_code,                             -- OUT
              p_match_mode,                                           -- OUT
              p_precision_inv_curr,                                   -- IN
              p_default_last_updated_by,                              -- IN
              p_default_last_update_login,                            -- IN
              p_current_invoice_status     => l_temp_invoice_status,  -- IN OUT
              p_calling_sequence           => current_calling_sequence)
              <> TRUE ) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'v_check_invoice_type_amount<-'||current_calling_sequence);
          END IF;
          RAISE check_inv_validation_failure;
        END IF;

        IF (l_temp_invoice_status = 'N') THEN
          l_current_invoice_status := l_temp_invoice_status;
        ELSE
          IF (p_invoice_rec.invoice_type_lookup_code is NULL AND
              l_invoice_type_lookup_code is not NULL) THEN
            p_invoice_rec.invoice_type_lookup_code :=
                                l_invoice_type_lookup_code;
          END IF;
        END IF;

        --
        -- show output values (only if debug_switch = 'Y')
        --
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------>
            l_temp_invoice_status  = '||l_temp_invoice_status
            ||' p_match_mode = '||p_match_mode);
        END IF;

        ----------------------------------------------------------------------
        -- Step 8
        -- Check for Invalid AWT Group only if there is a valid Invoice No.
        -- Also, populate awt_group_id if all the following conditions are met:
        -- 1) awt_group_id is null
        -- 2) awt_group_id could be derived in the awt group check function
        -- 3) the awt group check function returned that the invoice is valid
        --    as far as awt group information is concerned.
        ----------------------------------------------------------------------
        debug_info := '(Check Invoice Validation 7) Check for AWT Group ,'
                       ||'if Invoice No. is valid';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_awt_group(
           p_invoice_rec,                                             -- IN
           p_awt_group_id              => l_awt_group_id,             -- OUT
           p_default_last_updated_by   => p_default_last_updated_by,  -- IN
           p_default_last_update_login => p_default_last_update_login,-- IN
           p_current_invoice_status  => l_temp_invoice_status,      -- IN OUT
           p_calling_sequence        => current_calling_sequence)
              <> TRUE ) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'v_check_invalid_awt_group<-'||current_calling_sequence);
          END IF;
          RAISE check_inv_validation_failure;
        END IF;

        --
        IF (l_temp_invoice_status = 'N') THEN
          l_current_invoice_status := l_temp_invoice_status;
        ELSE
          IF (p_invoice_rec.awt_group_id is NULL AND
              l_awt_group_id is NOT NULL) THEN
            p_invoice_rec.awt_group_id := l_awt_group_id;
          END IF;
        END IF;

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------>
            l_temp_invoice_status  = '||l_temp_invoice_status);
        END IF;
       --bug6639866
        ----------------------------------------------------------------------
        -- Step 8.1
        -- Check for Invalid pay AWT Group only if there is a valid Invoice No.
        -- Also, populate pay_awt_group_id if all the following conditions are met:
        -- 1) pay_awt_group_id is null
        -- 2) pay_awt_group_id could be derived in the pay awt group check function
        -- 3) the pay awt group check function returned that the invoice is valid
        --    as far as pay awt group information is concerned.
        ----------------------------------------------------------------------
        debug_info := '(Check Invoice Validation 7) Check for pay AWT Group ,'
                       ||'if Invoice No. is valid';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_pay_awt_group(
           p_invoice_rec,                                             -- IN
           p_pay_awt_group_id              => l_pay_awt_group_id,     -- OUT
           p_default_last_updated_by   => p_default_last_updated_by,  -- IN
           p_default_last_update_login => p_default_last_update_login,-- IN
           p_current_invoice_status  => l_temp_invoice_status,      -- IN OUT
           p_calling_sequence        => current_calling_sequence)
              <> TRUE ) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'v_check_invalid_pay_awt_group<-'||current_calling_sequence);
          END IF;
          RAISE check_inv_validation_failure;
        END IF;

        --
        IF (l_temp_invoice_status = 'N') THEN
          l_current_invoice_status := l_temp_invoice_status;
        ELSE
        IF (p_invoice_rec.pay_awt_group_id is NULL AND
              l_pay_awt_group_id is NOT NULL) THEN
            p_invoice_rec.pay_awt_group_id := l_pay_awt_group_id;
          END IF;
        END IF;

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------>
            l_temp_invoice_status  = '||l_temp_invoice_status);
        END IF;

        ----------------------------------------------------------------------
        -- Step 9
        -- Check for Invalid Exchange Rate Type only if there is a valid
        -- Invoice No.
        -- Also, populate exchange_rate, exchange_rate_type and
        -- exchange_rate_date if all the following conditions are met:
        -- 1) exchange_rate, exchange_rate_type and/or exchange_rate_date are
        --    null
        -- 2) the exchange rate type check could derived value for those
        --    columns
        -- 3) the exchange rate type check returned that the invoice is valid
        --    as far as exchange rate is concerned.
        ----------------------------------------------------------------------
        debug_info := '(Check Invoice Validation 8) Check for Exchange Rate '
                       ||'Type ,if Invoice No. is valid';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF (AP_IMPORT_VALIDATION_PKG.v_check_exchange_rate_type (
            p_invoice_rec,                                        -- IN
            p_exchange_rate            => l_exchange_rate,        -- OUT
            p_exchange_date            => l_exchange_date,        -- OUT
            p_base_currency_code => p_base_currency_code,         -- IN
            p_multi_currency_flag => p_multi_currency_flag,       -- IN
            p_set_of_books_id => p_set_of_books_id,               -- IN
            p_default_exchange_rate_type => p_default_exchange_rate_type, -- IN
            p_make_rate_mandatory_flag => p_make_rate_mandatory_flag,  -- IN
            p_default_last_updated_by => p_default_last_updated_by,    -- IN
            p_default_last_update_login => p_default_last_update_login,-- IN
            p_current_invoice_status    => l_temp_invoice_status, -- IN OUT
            p_calling_sequence          => current_calling_sequence)
              <> TRUE ) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'v_check_exchange_rate_type<-'||current_calling_sequence);
          END IF;
          RAISE check_inv_validation_failure;
        END IF;

        IF (l_temp_invoice_status = 'N') THEN
          l_current_invoice_status := l_temp_invoice_status;
        ELSE
          IF (p_invoice_rec.exchange_rate_type IS NULL AND
              p_default_exchange_rate_type IS NOT NULL AND
              p_invoice_rec.invoice_currency_code <> p_base_currency_code) THEN
            p_invoice_rec.exchange_rate_type := p_default_exchange_rate_type;
          END IF;
          IF (p_invoice_rec.exchange_rate is NULL AND
              l_exchange_rate is NOT NULL) THEN
            p_invoice_rec.exchange_rate := l_exchange_rate;
          END IF;
          IF (p_invoice_rec.exchange_date is NULL AND
              l_exchange_date is NOT NULL) THEN
            p_invoice_rec.exchange_date := l_exchange_date;
          END IF;
	  /*Bug 8887650 begin*/
           IF (p_invoice_rec.invoice_currency_code = p_base_currency_code)
	      AND NOT (p_invoice_rec.exchange_rate_type IS NULL
	               AND p_invoice_rec.exchange_rate is NULL
		       AND p_invoice_rec.exchange_date is NULL) THEN

              p_invoice_rec.exchange_rate_type := NULL;
              p_invoice_rec.exchange_rate := NULL;
              p_invoice_rec.exchange_date := NULL;
           END IF;
	  /*Bug 8887650 End*/
        END IF;

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           '------------------>
            l_temp_invoice_status  = '||l_temp_invoice_status);
        END IF;

        ---------------------------------------------------------------------
        -- Step 10
        -- Check for Invalid Terms Info only if there is a valid Invoice No.
        -- If PO Number exists then get terms from PO.
        -- Also, populate terms_id and terms_date if all the following
        -- conditions are met:
        -- 1) terms id and/or terms date are null
        -- 2) values for terms id and/or terms date could be derived
        --    in the terms check function
        -- 3) the terms date function returned that the invoice is valid
        --    as far as terms are concerned.
        ----------------------------------------------------------------------
        debug_info := '(Check Invoice Validation 9) Check for Terms Info ,'
                      ||'if Invoice No. is valid';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_terms (
              p_invoice_rec,                                         -- IN
              p_terms_id                  => l_terms_id,             -- OUT
              p_terms_date                => l_terms_date,           -- OUT
              p_terms_date_basis          => l_terms_date_basis,     -- IN
              p_default_last_updated_by => p_default_last_updated_by,    -- IN
              p_default_last_update_login => p_default_last_update_login,-- IN
              p_current_invoice_status    => l_temp_invoice_status,  -- IN OUT
              p_calling_sequence          => current_calling_sequence)
              <> TRUE ) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'v_check_invalid_terms<-'||current_calling_sequence);
          END IF;
          RAISE check_inv_validation_failure;
        END IF;

        IF (l_temp_invoice_status = 'N') THEN
          l_current_invoice_status := l_temp_invoice_status;
        ELSE
          IF (p_invoice_rec.terms_id is NULL AND
              l_terms_id is NOT NULL) THEN
            p_invoice_rec.terms_id := l_terms_id;
        END IF;
      IF (p_invoice_rec.terms_date IS NULL AND
          l_terms_date IS NOT NULL) THEN
        p_invoice_rec.terms_date := l_terms_date;
      END IF;
        END IF;

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------>
            l_temp_invoice_status  = '||l_temp_invoice_status
            ||'terms_id = '||to_char(l_terms_id) );
        END IF;

        ----------------------------------------------------------------------
        -- Step 11
        -- Check for Misc Invoice info
        ----------------------------------------------------------------------
        debug_info := '(Check Invoice Validation 10) Check for Misc Info ';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;
        IF (AP_IMPORT_VALIDATION_PKG.v_check_misc_invoice_info (
              p_invoice_rec,                                         -- IN
              p_set_of_books_id,                                     -- IN
              p_default_last_updated_by,                             -- IN
              p_default_last_update_login,                           -- IN
              p_current_invoice_status     => l_temp_invoice_status, -- IN OUT
              p_calling_sequence           => current_calling_sequence)
              <> TRUE ) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'v_check_misc_invoice_info<-'||current_calling_sequence);
          END IF;
          RAISE check_inv_validation_failure;
        END IF;

        IF (l_temp_invoice_status = 'N') THEN
          l_current_invoice_status := l_temp_invoice_status;
        END IF;

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------>
            l_temp_invoice_status  = '||l_temp_invoice_status);
        END IF;

         /* -------------------------------------------------------------------
            Step 11a: Get/Validate Legal Entity Information
               There are two forms of LE derivation.
               1) Internal products could optionally pass the LE in the
                  LEGAL_ENTITY_ID Column. This will be validated by the API
                  provided by LE Team.

               2)For the invoices coming via EDI, XML, they could
                 provide us with Customer Registration CODE/Numbers, which
                 will be used to derive the LE using a LE API.
        --------------------------------------------------------------------*/
        debug_info := '(Check Invoice Validation 11a) Check for LE Info ';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF (AP_IMPORT_VALIDATION_PKG.v_check_Legal_Entity_info (
              p_invoice_rec,                                         -- IN OUT
              p_set_of_books_id,                                     -- IN
              p_default_last_updated_by,                             -- IN
              p_default_last_update_login,                           -- IN
              p_current_invoice_status     => l_temp_invoice_status, -- IN OUT
              p_calling_sequence           => current_calling_sequence)
              <> TRUE ) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'v_check_Legal_Entity_info<-'||current_calling_sequence);
          END IF;
          RAISE check_inv_validation_failure;
        END IF;

        IF (l_temp_invoice_status = 'N') THEN
          l_current_invoice_status := l_temp_invoice_status;
        END IF;

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------>
            l_temp_invoice_status  = '||l_temp_invoice_status);
        END IF;

        ----------------------------------------------------------------------
        -- Step 12
        -- Check for Invalid Payment Currency Info only if there is a valid
        -- Invoice No.
        -- Also, populate payment_currency_code and payment cross rate
        -- information if all the following conditions are met:
        -- 1) payment currency code and/or payment cross rate information are
        --    null
        -- 2) payment currency code and/or payment cross rate information was
        --    derived as part of the pay curr check.
        -- 3) the pay curr check function returned that the invoice is valid
        --    as far as pay curr info is concerned.
        ----------------------------------------------------------------------
        debug_info := '(Check Invoice Validation 11) Check for '||
                       'Payment Currency Info ,if Invoice No. is valid';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          debug_info);
        END IF;

        IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_pay_curr (
              p_invoice_rec,                                           -- IN
              p_pay_currency_code            => l_pay_currency_code,   -- OUT
              p_payment_cross_rate_date      => l_pay_cross_rate_date, -- OUT
              p_payment_cross_rate           => l_pay_cross_rate,      --OUT
              p_payment_cross_rate_type      => l_pay_cross_rate_type, --OUT
              p_default_last_updated_by   => p_default_last_updated_by,-- IN
              p_default_last_update_login => p_default_last_update_login,-- IN
              p_current_invoice_status    => l_temp_invoice_status, -- IN OUT
              p_calling_sequence          => current_calling_sequence)
              <> TRUE ) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'v_check_invalid_pay_curr<-'||current_calling_sequence);
          END IF;
          RAISE check_inv_validation_failure;
        END IF;

        IF (l_temp_invoice_status = 'N') THEN
          l_current_invoice_status := l_temp_invoice_status;
        ELSE
          IF (p_invoice_rec.payment_currency_code is NULL AND
              l_pay_currency_code is NOT NULL) THEN
            p_invoice_rec.payment_currency_code := l_pay_currency_code;
          END IF;
          IF (p_invoice_rec.payment_cross_rate_date is NULL AND
              l_pay_cross_rate_date is NOT NULL) THEN
            p_invoice_rec.payment_cross_rate_date := l_pay_cross_rate_date;
          END IF;
          IF ((p_invoice_rec.payment_cross_rate is NULL AND
               l_pay_cross_rate is NOT NULL) OR
          (p_invoice_rec.payment_cross_rate is NOT NULL AND
           l_pay_cross_rate is NOT NULL AND
           p_invoice_rec.payment_cross_rate <> l_pay_cross_rate)) THEN
            p_invoice_rec.payment_cross_rate := l_pay_cross_rate;
          END IF;
          IF (p_invoice_rec.payment_cross_rate_type is NULL AND
              l_pay_cross_rate_type is NOT NULL) THEN
            p_invoice_rec.payment_cross_rate_type := l_pay_cross_rate_type;
          END IF;
        END IF;
        --
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------>
            l_temp_invoice_status  = '||l_temp_invoice_status);
        END IF;

/* Bug 4014019: Commenting the call to jg_globe_flex_val due to build issues.

        ----------------------------------------------------------------------
        -- Step 13
        -- Check for Invalid Global Flexfield Value.
        -- Retropricing: This may require JG modifications as parent table can
        -- now also be the Temp table AP_PPA_INVOICES_GT
        ----------------------------------------------------------------------
        debug_info := '(Check Invoice Validation 13) Check for GDFF';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;
        jg_globe_flex_val.check_attr_value(
                      'APXIIMPT',
                      p_invoice_rec.global_attribute_category,
                      p_invoice_rec.global_attribute1,
                      p_invoice_rec.global_attribute2,
                      p_invoice_rec.global_attribute3,
                      p_invoice_rec.global_attribute4,
                      p_invoice_rec.global_attribute5,
                      p_invoice_rec.global_attribute6,
                      p_invoice_rec.global_attribute7,
                      p_invoice_rec.global_attribute8,
                      p_invoice_rec.global_attribute9,
                      p_invoice_rec.global_attribute10,
                      p_invoice_rec.global_attribute11,
                      p_invoice_rec.global_attribute12,
                      p_invoice_rec.global_attribute13,
                      p_invoice_rec.global_attribute14,
                      p_invoice_rec.global_attribute15,
                      p_invoice_rec.global_attribute16,
                      p_invoice_rec.global_attribute17,
                      p_invoice_rec.global_attribute18,
                      p_invoice_rec.global_attribute19,
                      p_invoice_rec.global_attribute20,
                      TO_CHAR(p_set_of_books_id),
                      fnd_date.date_to_canonical(p_invoice_rec.invoice_date),
                      AP_IMPORT_INVOICES_PKG.g_invoices_table,  --Retropricing
                      TO_CHAR(p_invoice_rec.invoice_id),
                      TO_CHAR(p_default_last_updated_by),
                      TO_CHAR(p_default_last_update_login),
                      current_calling_sequence,
                      TO_CHAR(p_invoice_rec.vendor_site_id), -- arg 8
                      p_invoice_rec.payment_currency_code,   -- arg 9
                      NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                      NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                      NULL,NULL,NULL,NULL,
                      p_current_status => l_temp_invoice_status);

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'Global Flexfield Header Processed  '|| l_temp_invoice_status);
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'Invoice_id  '|| to_char(p_invoice_rec.invoice_id));
        END IF;
        IF (l_temp_invoice_status = 'N') THEN
          l_current_invoice_status := l_temp_invoice_status;
        END IF;

*/

        ----------------------------------------------------------------------
        -- Step 14
        -- Check for Valid Prepayment Info.
        -- Retropricing: All prepayment fields will be NULL for PPA's
        ----------------------------------------------------------------------
        IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN   --Retropricing
            debug_info :=
                     '(Check Invoice Validation 14) Check for Prepayment Info.';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            debug_info);
            END IF;

            IF (AP_IMPORT_VALIDATION_PKG.v_check_prepay_info(
                  p_invoice_rec,                                       -- IN OUT
                  p_base_currency_code,                                -- IN
                  p_prepay_period_name,                                -- IN OUT
		  p_prepay_invoice_id,				       -- OUT
		  p_prepay_case_name,				       -- OUT
                  p_request_id,                                        -- IN
                  p_default_last_updated_by,                           -- IN
                  p_default_last_update_login,                         -- IN
                  p_current_invoice_status   => l_temp_invoice_status, -- IN OUT
                  p_calling_sequence         => current_calling_sequence)
                  <> TRUE ) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'v_check_prepay_info<-' ||current_calling_sequence);
              END IF;
              RAISE check_inv_validation_failure;

            END IF;

            IF (l_temp_invoice_status = 'N') THEN
              l_current_invoice_status := l_temp_invoice_status;
            END IF;

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                            '------------------>
                      l_temp_invoice_status  = '||l_temp_invoice_status);
            END IF;
        END IF;
        ----------------------------------------------------------------------
        -- Step 15
        -- Check for Tax info at invoice level
        -- Although all eTax related fields(control_amount,tax_related_invoice_id,
        -- calc_tax_during_import_flag will be NULL on the Invoice Header
        -- some sql statemnts in the v_check_tax_info will get executed.
        ----------------------------------------------------------------------
        IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN   --Retropricing
            debug_info :=
              '(Check Invoice Validation 15) Check for tax drivers or invoice level '||
              'tax validations.';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            debug_info);
            END IF;

            IF (AP_IMPORT_VALIDATION_PKG.v_check_tax_info(
               p_invoice_rec                => p_invoice_rec,
               p_default_last_updated_by    => p_default_last_updated_by,
               p_default_last_update_login  => p_default_last_update_login,
               p_current_invoice_status     => l_temp_invoice_status,
               p_calling_sequence           => current_calling_sequence)
                  <> TRUE ) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'v_check_tax_info<-' ||current_calling_sequence);
              END IF;
              RAISE check_inv_validation_failure;

            END IF;

            IF (l_temp_invoice_status = 'N') THEN
              l_current_invoice_status := l_temp_invoice_status;
            END IF;

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                '------------------> l_temp_invoice_status  = '
                ||l_temp_invoice_status);

            END IF;
        END IF;

   ------------------------------------------------
   /* Step 15.a.  Populate default taxation_county
                  when null.  Bug 9738820        */
   ------------------------------------------------
   IF p_invoice_rec.taxation_country is null THEN
     BEGIN
       xle_utilities_grp.get_fp_countrycode_ou (
                             p_api_version       => 1.0,
                             p_init_msg_list     => FND_API.G_FALSE,
                             p_commit            => FND_API.G_FALSE,
                             x_return_status     => l_return_status,
                             x_msg_count         => l_msg_count,
                             x_msg_data          => l_msg_data,
                             p_operating_unit    => p_invoice_rec.org_id,
                             x_country_code      => l_country_code);
       p_invoice_rec.taxation_country := l_country_code;
     /* taxation_country is not required so we will continue
        processing without a rejection when it can't be populated */
     EXCEPTION
       WHEN OTHERS THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'Error when attempting to set default taxation_country.');
          END IF;
     END;

   END IF;
   /* End Bug 9738820 */

   ------------------------------------------------
    -- Step 16
    -- Check for Invalid Remit to Supplier
   ------------------------------------------------

   debug_info := 'Check for Invalid Remit to Supplier';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
        END IF;

        IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_remit_supplier (
            p_invoice_rec			=>	p_invoice_rec, -- IN OUT
            p_default_last_updated_by =>	p_default_last_updated_by, -- IN
            p_default_last_update_login =>	p_default_last_update_login,                           -- IN
            p_current_invoice_status     =>	l_temp_invoice_status, -- IN OUT
            p_calling_sequence		=>	current_calling_sequence) <> TRUE )THEN
	      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
		  AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
			'v_check_invalid_remit_supplier<-'||current_calling_sequence);
	      END IF;
	      RAISE check_inv_validation_failure;
        END IF;

	IF (l_temp_invoice_status = 'N') THEN
              l_current_invoice_status := l_temp_invoice_status;
        END IF;

	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
		'------------------> l_temp_invoice_status  = '
		||l_temp_invoice_status);
	END IF;

        ----------------------------------------------------------------------
        -- Step 17
        -- Check for User Xrate information
        -- Also populate no_xrate_base_amount to be used as base amount if
        -- the following conditions are met:
        -- 1) no_xrate_base_amount is null
        -- 2) invoice currency code is different than base currency
        -- 3) base amount could be derived as part of no xrate base amt check
        -- 4) no xrate base amount check function returned that the invoice
        --    is valid as far as xrate is concerned.
        -- Retropricing:
        -- Although the function calculates invoice_base_amount, for PPA's the
        -- base_Amount is provided in the PPA Invoice. Also since base amounts
        -- are re-calculated during validation, there is no need to call the
        -- validation below for PPA's
        ----------------------------------------------------------------------
        IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN   --Retropricing
            debug_info :=
                    '(Check Invoice Validation 16) Check for Exchange Rate Info.';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            debug_info);
            END IF;

            IF (AP_IMPORT_VALIDATION_PKG.v_check_no_xrate_base_amount (
                  p_invoice_rec,                                          -- IN
                  p_base_currency_code,                                   -- IN
                  p_multi_currency_flag,                                  -- IN
                  p_calc_user_xrate,                                      -- IN
                  p_default_last_updated_by,                              -- IN
                     p_default_last_update_login,                            -- IN
                  p_invoice_base_amount        => l_invoice_base_amount,  -- OUT
                  p_current_invoice_status     => l_temp_invoice_status,  -- IN OUT
                  p_calling_sequence           => current_calling_sequence)
                  <> TRUE ) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                  AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'v_check_inavlid_currency_code<-' ||current_calling_sequence);
              END IF;
              RAISE check_inv_validation_failure;
            END IF;

            IF (l_temp_invoice_status = 'N' )THEN
              l_current_invoice_Status := l_temp_invoice_status;
            ELSE
              IF (p_invoice_rec.no_xrate_base_amount IS NULL AND
                  l_invoice_base_amount IS NOT NULL AND
                  p_invoice_rec.invoice_currency_code <> p_base_currency_code) THEN
                 p_invoice_rec.no_xrate_base_amount := l_invoice_base_amount;
              END IF;
            END IF;
        END IF;  --Retropricing

        debug_info := '(Check Invoice Validation 17) Check Payment Info ';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF (AP_IMPORT_VALIDATION_PKG.v_check_payment_defaults (
              p_invoice_rec,
              l_temp_invoice_status,
              current_calling_sequence,
              p_default_last_updated_by,
              p_default_last_update_login)
              <> TRUE ) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'v_check_payment_defaults<-'||current_calling_sequence);
          END IF;
          RAISE check_inv_validation_failure;
        END IF;

        IF (l_temp_invoice_status = 'N') THEN
          l_current_invoice_status := l_temp_invoice_status;
        END IF;

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------>
            l_temp_invoice_status  = '||l_temp_invoice_status);
        END IF;







      END IF; -- status not N after validating invoice number

    ELSE -- IF (p_invoice_rec.vendor_site_id or party_site_id is NOT NULL)
      -- fatal error - no valid vendor site found - stop processing for
      -- this invoice.  A row was already inserted into
      -- AP_INTERFACE_REJECTIONS within CHECK_INVALID_SUPPLIER_SITE
      p_fatal_error_flag := 'Y';
      l_current_invoice_status := 'N';
    END IF; -- IF (p_invoice_rec.vendor_site_id is NOT NULL) THEN

  ELSE -- IF (p_invoice_rec.vendor_id or party_id is NOT NULL)
    -- fatal error - no valid vendor found - stop processing for this
    -- invoice.  A row was already inserted into AP_INTERFACE_REJECTIONS
    -- within CHECK_INVALID_SUPPLIER
    p_fatal_error_flag := 'Y';
    l_current_invoice_status := 'N';
  END IF; -- IF (p_invoice_rec.vendor_id or party_id is NOT NULL)

  -- Bug 9452076. Start
  -- Added condition.
  IF (l_current_invoice_status = 'N') THEN
     p_current_invoice_status := l_current_invoice_status;
  END IF ;
  -- Bug 9452076. End

RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_invoice_validation;


-----------------------------------------------------------------------------
-- This function is used to perform PO validation.
--
FUNCTION v_check_invalid_po (
           p_invoice_rec    IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
           p_default_last_updated_by   IN             NUMBER,
           p_default_last_update_login IN             NUMBER,
           p_current_invoice_status    IN OUT NOCOPY  VARCHAR2,
           p_po_vendor_id                 OUT NOCOPY  NUMBER,
           p_po_vendor_site_id            OUT NOCOPY  NUMBER,
           p_po_exists_flag               OUT NOCOPY  VARCHAR2,
           p_calling_sequence          IN             VARCHAR2) RETURN BOOLEAN
IS

invalid_po_check_failure    EXCEPTION;
l_current_invoice_status    VARCHAR2(1) := 'Y';
l_closed_date               DATE;
l_vendor_id                 NUMBER;
l_vendor_site_id            NUMBER;
l_po_exists_flag            VARCHAR2(1) := 'N';
current_calling_sequence    VARCHAR2(2000);
debug_info                  VARCHAR2(500);
l_invoice_vendor_name       po_vendors.vendor_name%TYPE := '';
l_closed_code               VARCHAR2(25);  /* 1Off Bug 10288184 / 11i Bug 8410175 */

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=  'AP_IMPORT_VALIDATION_PKG.v_check_invalid_po<-'
                                ||P_calling_sequence;

  -- differentiate PO from RFQ and Quotation
  SELECT closed_date, vendor_id, vendor_site_id, closed_code /* Added closed_code - 1Off Bug 10288184 / 11i Bug 8410175 */
    INTO l_closed_date ,l_vendor_id, l_vendor_site_id, l_closed_code /* Added l_closed_code - 1Off Bug 10288184 / 11i Bug 8410175 */
    FROM po_headers
   WHERE segment1 = p_invoice_rec.po_number
     AND type_lookup_code in ('BLANKET', 'PLANNED', 'STANDARD')
   /* BUG  2902452 added*/
   AND nvl(authorization_status,'INCOMPLETE') in ('APPROVED','REQUIRES REAPPROVAL','IN PROCESS');--Bug5687122 --Added In Process condition

  IF (l_vendor_id IS NOT NULL) Then
    l_po_exists_flag := 'Y';
  END IF;

  --------------------------------------------------------------------------
  -- Step 1
  -- Check for Inactive PO NUMBER.
  --------------------------------------------------------------------------
  debug_info := '(Check PO Number 1) Check for Inactive PO Number.';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;
  --Bypass this rejections for PPA's  --Retropricing
  /* Added l_closed_code condition to avoid rejecting the PO's that are 'CLOSED - 1Off Bug 10288184 / 11i Bug 8410175 */
  IF (l_closed_date is not null AND
      AP_IMPORT_INVOICES_PKG.g_source <> 'PPA'
      AND l_closed_code in ('FINALLY CLOSED')
      ) THEN
    -- PO has been closed
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoices_table,
          p_invoice_rec.invoice_id,
          'INACTIVE PO',
          p_default_last_updated_by,
          p_default_last_update_login,
          current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      'insert_rejections<-'||
                                      current_calling_sequence);
      END IF;
      RAISE invalid_po_check_failure;
    END IF;

    l_current_invoice_status := 'N';

  ELSE
    ------------------------------------------------------------------------
    -- Step 2
    -- Check for Inconsistent PO Vendor.
    ------------------------------------------------------------------------
    debug_info := '(Check PO Number 2) Check for Inconsistent PO Vendor.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (l_vendor_id <> nvl(p_invoice_rec.vendor_id, l_vendor_id)) THEN
    --Retropricing There is no need for the IF statement mentioned below
      IF (AP_IMPORT_INVOICES_PKG.g_source = 'XML GATEWAY' ) THEN
        BEGIN
          -- Get contextual Information for XML Gateway
          SELECT vendor_name
            INTO l_invoice_vendor_name
            FROM po_vendors
           WHERE vendor_id = p_invoice_rec.vendor_id;

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
              (AP_IMPORT_INVOICES_PKG.g_invoices_table,
               p_invoice_rec.invoice_id,
               'INCONSISTENT PO SUPPLIER',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence,
               'Y',
               'SUPPLIER NAME',
               l_invoice_vendor_name) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE invalid_po_check_failure;
          END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
      ELSE
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
             (AP_IMPORT_INVOICES_PKG.g_invoices_table,
              p_invoice_rec.invoice_id,
              'INCONSISTENT PO SUPPLIER',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||
              current_calling_sequence);
          END IF;
          RAISE invalid_po_check_failure;
        END IF;

      END IF; -- g_source = 'XML GATEWAY'

      l_current_invoice_status := 'N';

    END IF; -- vendor id <> vendor id on interface invoice
  END IF;  -- closed date is not null

  p_po_vendor_id := l_vendor_id;
  p_po_vendor_site_id := l_vendor_site_id;
  p_po_exists_flag := l_po_exists_flag;
  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION
  WHEN no_data_found THEN

    -------------------------------------------------------------------------
    -- Step 3
    -- Invalid PO NUMBER.
    -------------------------------------------------------------------------
    debug_info := '(Check PO Number 3) Check for Invalid PO Number.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    -- include context for XML GATEWAY
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                            p_invoice_rec.invoice_id,
                           'INVALID PO NUM',
                            p_default_last_updated_by,
                            p_default_last_update_login,
                            current_calling_sequence,
                            'Y',
                            'PO NUMBER',
                            p_invoice_rec.po_number) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      'insert_rejections<-'||
                                       current_calling_sequence);
      END IF;
      RAISE invalid_po_check_failure;
    END IF;

    p_po_exists_flag := l_po_exists_flag;
    l_current_invoice_status := 'N';
    p_current_invoice_status := l_current_invoice_status;
    RETURN (TRUE);

  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_invalid_po;


-----------------------------------------------------------------------------
-- This function is used to perform Supplier validation
--
-----------------------------------------------------------------------------
FUNCTION v_check_invalid_supplier(
         p_invoice_rec   IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_default_last_updated_by     IN            NUMBER,
         p_default_last_update_login   IN            NUMBER,
         p_return_vendor_id               OUT NOCOPY NUMBER,
         p_current_invoice_status      IN OUT NOCOPY VARCHAR2,
         p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN IS

supplier_check_failure      EXCEPTION;
l_vendor_id                 PO_VENDORS.VENDOR_ID%TYPE :=
                              p_invoice_rec.vendor_id;
l_vendor_id_per_num         PO_VENDORS.VENDOR_ID%TYPE;
l_vendor_id_per_name        PO_VENDORS.VENDOR_ID%TYPE;
l_current_invoice_status    VARCHAR2(1) := 'Y';
return_vendor_id            NUMBER(15);
current_calling_sequence    VARCHAR2(2000);
debug_info                  VARCHAR2(500);


BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_invalid_supplier<-'
    ||P_calling_sequence;

  IF ((p_invoice_rec.vendor_id is NULL) AND
      (p_invoice_rec.vendor_num is NULL) AND
      (p_invoice_rec.vendor_name is NULL)) THEN

    -------------------------------------------------------------------------
    -- Step 1
    -- Check for Null Supplier.
    -------------------------------------------------------------------------
    debug_info := '(Check Invalid Supplier 1) Check for Null Supplier.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
            (AP_IMPORT_INVOICES_PKG.g_invoices_table,
             p_invoice_rec.invoice_id,
             'NO SUPPLIER',
             p_default_last_updated_by,
             p_default_last_update_login,
             current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE supplier_check_failure;
    END IF;
    return_vendor_id := null;

  ELSE

     IF (p_invoice_rec.vendor_id is NOT NULL) THEN

       ----------------------------------------------------------------------
       -- Step 2
       -- validate vendor id
       ----------------------------------------------------------------------
       debug_info := '(Check Invalid Supplier 2) Validate vendor id.';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
       END IF;

       SELECT vendor_id
         INTO l_vendor_id
         FROM po_vendors pv
        WHERE vendor_id = p_invoice_rec.vendor_id
          AND nvl(trunc(PV.START_DATE_ACTIVE),
                  AP_IMPORT_INVOICES_PKG.g_inv_sysdate)
              <= AP_IMPORT_INVOICES_PKG.g_inv_sysdate
          AND nvl(trunc(PV.END_DATE_ACTIVE),
                  AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
              > AP_IMPORT_INVOICES_PKG.g_inv_sysdate ;

     END IF;

     IF (p_invoice_rec.vendor_num is NOT NULL) THEN

       ----------------------------------------------------------------------
       -- Step 3
       -- Validate vendor number and retrieve vendor id
       ----------------------------------------------------------------------
       debug_info := '(Check Invalid Supplier 3) Validate vendor number and '
                      ||'retrieve vendor id';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
       END IF;

       SELECT vendor_id
         INTO l_vendor_id_per_num
         FROM po_vendors PV
        WHERE segment1 = p_invoice_rec.vendor_num
          AND nvl(trunc(PV.START_DATE_ACTIVE),
                  AP_IMPORT_INVOICES_PKG.g_inv_sysdate)
              <= AP_IMPORT_INVOICES_PKG.g_inv_sysdate
          AND nvl(trunc(PV.END_DATE_ACTIVE),
                  AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
              > AP_IMPORT_INVOICES_PKG.g_inv_sysdate;

     END IF;

     IF (p_invoice_rec.vendor_name is NOT NULL) THEN

       ----------------------------------------------------------------------
       -- Step 4
       -- Validate vendor name and retrieve vendor id
       ----------------------------------------------------------------------
       debug_info := '(Check Invalid Supplier 4) Validate vendor name and '
                     ||'retrieve vendor id';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
       END IF;

       SELECT vendor_id
         INTO l_vendor_id_per_name
         FROM po_vendors PV
        WHERE vendor_name = p_invoice_rec.vendor_name
          AND nvl(trunc(PV.START_DATE_ACTIVE),
                  AP_IMPORT_INVOICES_PKG.g_inv_sysdate)
              <= AP_IMPORT_INVOICES_PKG.g_inv_sysdate
          AND nvl(trunc(PV.END_DATE_ACTIVE),
                  AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
              > AP_IMPORT_INVOICES_PKG.g_inv_sysdate ;

     END IF;

     IF ((l_vendor_id is NOT NULL)                           AND
                 (((l_vendor_id_per_num is NOT NULL) AND
                   (l_vendor_id <> l_vendor_id_per_num))     OR
                 ((l_vendor_id_per_name is NOT NULL) AND
                  (l_vendor_id <> l_vendor_id_per_name)))
        ) THEN

       -----------------------------------------------------------------------
       -- Step 5
       -- Check for Inconsitent Supplier based on not null supplier id provided
       -----------------------------------------------------------------------
       debug_info := '(Check Invalid Supplier 5) Check for inconsistent '
                     ||'Supplier - supplier id not null';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
       END IF;

       IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                       (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                        p_invoice_rec.invoice_id,
                        'INCONSISTENT SUPPLIER',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence) <> TRUE) THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                         'insert_rejections<-'
                                          ||current_calling_sequence);
         END IF;
         RAISE supplier_check_failure;
       END IF;

       l_current_invoice_status := 'N';

     END IF;


     IF ((l_vendor_id_per_num is NOT NULL) AND
         (l_vendor_id_per_name is NOT NULL) AND
         (l_vendor_id_per_num <> l_vendor_id_per_name) AND
         (l_current_invoice_status = 'Y')) THEN

       ----------------------------------------------------------------------
       -- Step 6
       -- Check for Inconsitent Supplier number and Name.
       ----------------------------------------------------------------------
       debug_info := '(Check Invalid Supplier 6) Check for inconsistent '
                     ||'Supplier Number and Name.';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
       END IF;

       IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                  (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                   p_invoice_rec.invoice_id,
                   'INCONSISTENT SUPPLIER',
                   p_default_last_updated_by,
                   p_default_last_update_login,
                   current_calling_sequence) <> TRUE) THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections<-'||current_calling_sequence);
         END IF;
         RAISE supplier_check_failure;
       END IF;

       l_current_invoice_status := 'N';

     END IF;

     IF (l_current_invoice_status = 'Y') THEN

       ----------------------------------------------------------------------
       -- Step 7
       -- Save Supplier id for further processing.
       ----------------------------------------------------------------------
       debug_info := '(Check Invalid Supplier 7) Save Supplier id for '
                     ||'further processing.';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
       END IF;

       IF (l_vendor_id is NULL) THEN

         IF (l_vendor_id_per_num is NOT NULL) THEN
           return_vendor_id := l_vendor_id_per_num;
         ELSE
           return_vendor_id := l_vendor_id_per_name;
         END IF;
       ELSE
         return_vendor_id := l_vendor_id;
       END IF;
     END IF;

  END IF;
  p_return_vendor_id := return_vendor_id;
  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);
EXCEPTION
  WHEN no_data_found THEN

    -------------------------------------------------------------------------
    -- Step 8
    -- Check for invalid Supplier.
    -------------------------------------------------------------------------
    debug_info := '(Check Invalid Supplier 8) Check for invalid Supplier.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID SUPPLIER',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE supplier_check_failure;

    END IF;
    l_current_invoice_status := 'N';
    p_return_vendor_id := return_vendor_id;
    p_current_invoice_status := l_current_invoice_status;
    RETURN (TRUE);


  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_invalid_supplier;


------------------------------------------------------------------
-- This function is used to perform Supplier Site validation
--
------------------------------------------------------------------
FUNCTION v_check_invalid_supplier_site (
         p_invoice_rec  IN  AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_vendor_site_id_per_po      IN            NUMBER,
         p_default_last_updated_by    IN            NUMBER,
         p_default_last_update_login  IN            NUMBER,
         p_return_vendor_site_id         OUT NOCOPY NUMBER,
         p_terms_date_basis              OUT NOCOPY VARCHAR2,
         p_current_invoice_status     IN OUT NOCOPY VARCHAR2,
         p_calling_sequence           IN VARCHAR2) RETURN BOOLEAN
IS

supplier_site_check_failure        EXCEPTION;
l_vendor_site_id                   NUMBER(15);
l_vendor_site_id_per_code          NUMBER(15);
l_check_vendor_id                  NUMBER;
l_current_invoice_status           VARCHAR2(1):='Y';
l_valid_vendor                     VARCHAR2(1);
return_vendor_site_id              NUMBER(15);
l_pay_site_flag                    VARCHAR2(1);
l_pay_site_flag_per_code           VARCHAR2(1);
current_calling_sequence           VARCHAR2(2000);
debug_info                         VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_invalid_supplier_site<-'
     ||P_calling_sequence;

  debug_info := '(Check Invalid Site 1) Check Supplier Site';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  IF ((p_invoice_rec.vendor_site_id is null) AND
      (p_invoice_rec.vendor_site_code is null) AND
      (p_vendor_site_id_per_po is null)) THEN

    debug_info := '(Check Invalid Site 2) No Supplier Site, Reject';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    -- no supplier site exists
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
           (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'NO SUPPLIER SITE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      'insert_rejections<-'
                                      ||current_calling_sequence);
      END IF;
      RAISE supplier_site_check_failure;
    END IF;

    return_vendor_site_id := null;
    l_current_invoice_status := 'N';

  ELSE

    IF p_invoice_rec.vendor_site_id is not null THEN
      debug_info := '(Check Invalid Site 3) Get Supplier Site details '
                    ||'from p_invoice_rec.vendor_site_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
    /*Bug5503712 Done the code changes so that if vendor site id is not null
      CADIP will not reject PPA invoices in following cases.
        1.  primary pay site is present  OR
        2.  only 1 pay site is present. */
      BEGIN
        --validate vendor site id
        SELECT vendor_site_id, pay_site_flag, terms_date_basis
        INTO l_vendor_site_id, l_pay_site_flag, p_terms_date_basis
        FROM po_vendor_sites pvs
        WHERE vendor_site_id = p_invoice_rec.vendor_site_id
         AND nvl(trunc(PVS.INACTIVE_DATE),
                 AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
             > AP_IMPORT_INVOICES_PKG.g_inv_sysdate ;
      EXCEPTION
        WHEN no_data_found THEN
          /* Added the if condition AP_IMPORT_INVOICES_PKG.g_source <> 'PPA'
             for bug#9727865 */
          IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN
             IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                  (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                       p_invoice_rec.invoice_id,
                       'INVALID SUPPLIER SITE',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence) <> TRUE
                ) THEN
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      'insert_rejections<-'
                                      ||current_calling_sequence);
                END IF;
                RAISE supplier_site_check_failure;
             END IF;
             return_vendor_site_id := null;
             l_current_invoice_status := 'N';
          ELSE

             BEGIN
              --Get Primary Pay site
              SELECT vendor_site_id, pay_site_flag, terms_date_basis
              INTO l_vendor_site_id, l_pay_site_flag, p_terms_date_basis
              FROM po_vendor_sites pvs
              WHERE vendor_id = p_invoice_rec.vendor_id
              AND   nvl(Primary_pay_site_flag,'N')='Y'
              AND   pvs.Org_id=p_invoice_rec.org_id
              AND nvl(trunc(PVS.INACTIVE_DATE),
                    AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
                        > AP_IMPORT_INVOICES_PKG.g_inv_sysdate ;

              UPDATE AP_ppa_invoices_gt H
                 SET vendor_site_id = l_vendor_site_id
               WHERE invoice_id = p_invoice_rec.invoice_id;


      EXCEPTION
        WHEN no_data_found THEN

          BEGIN
           --Get pay site id if only one pay site is present
           SELECT vendor_site_id, pay_site_flag, terms_date_basis
             INTO l_vendor_site_id, l_pay_site_flag, p_terms_date_basis
             FROM po_vendor_sites pvs
            WHERE vendor_id = p_invoice_rec.vendor_id
              AND pvs.Org_id=p_invoice_rec.org_id
              AND NVL(pvs.pay_site_flag,'N')='Y'
              AND nvl(trunc(PVS.INACTIVE_DATE),
                     AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
                         > AP_IMPORT_INVOICES_PKG.g_inv_sysdate ;

              UPDATE AP_ppa_invoices_gt H
                 SET vendor_site_id = l_vendor_site_id
               WHERE invoice_id = p_invoice_rec.invoice_id;

          EXCEPTION
             WHEN OTHERS THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INVALID SUPPLIER SITE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    'insert_rejections<-'
                                    ||current_calling_sequence);
          END IF;
          RAISE supplier_site_check_failure;
        END IF;
        return_vendor_site_id := null;
        l_current_invoice_status := 'N';
      END;
     END;
     END IF; -- AP_IMPORT_INVOICES_PKG.g_source <> 'PPA'
    END;

    END IF; -- p_invoice_rec.vendor_site_id is not null

    IF p_invoice_rec.vendor_site_code is not null THEN

      debug_info := '(Check Invalid Site 4) Get Supplier Site details '
                   ||'from p_invoice_rec.vendor_site_code';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
      END IF;

      --validate vendor site code and retrieve vendor site id
      BEGIN
        SELECT vendor_site_id, pay_site_flag,
            terms_date_basis
        INTO l_vendor_site_id_per_code, l_pay_site_flag_per_code,
            p_terms_date_basis
        FROM po_vendor_sites
        WHERE vendor_site_code = p_invoice_rec.vendor_site_code
        AND vendor_id = p_invoice_rec.vendor_id
        AND nvl(trunc(INACTIVE_DATE),AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
            > AP_IMPORT_INVOICES_PKG.g_inv_sysdate ;
       EXCEPTION

        -- Bug 5579196
        WHEN too_many_rows THEN
          IF p_invoice_rec.org_id is NULL then
             NULL;
           END IF;

        WHEN no_data_found THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INVALID SUPPLIER SITE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    'insert_rejections<-'
                                    ||current_calling_sequence);
          END IF;
          RAISE supplier_site_check_failure;
        END IF;
        return_vendor_site_id := null;
        l_current_invoice_status := 'N';

      END;

    END IF; -- p_invoice_rec.vendor_site_code is not null


    IF l_vendor_site_id iS NOT NULL AND
      l_vendor_site_id_per_code IS NOT NULL AND
      l_vendor_site_id <> l_vendor_site_id_per_code THEN
      debug_info :=
       '(Check Invalid Site 5) Supplier Site info is inconsistent';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
      END IF;

      --vendor site id and vendor site code inconsistent
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
           (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INCONSISTENT SUPPL SITE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       'insert_rejections<-'
                                       ||current_calling_sequence);
         END IF;
         RAISE supplier_site_check_failure;
       END IF;
       return_vendor_site_id := null;
       l_current_invoice_status := 'N';

     END IF; -- vendor site id is not null, site id from code
           -- is not null and they differ

     -- Make sure the vendor site and vendor match
     --
     IF ((l_vendor_site_id is not null OR
       l_vendor_site_id_per_code is not null) AND
       p_invoice_rec.vendor_id IS NOT NULL) THEN
       debug_info := '(Check Invalid Site 6) Check Supplier Site for'
                   ||' given vendor';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
       END IF;

       BEGIN
         SELECT 'X'
         INTO l_valid_vendor
         FROM po_vendor_sites
         WHERE vendor_site_id = nvl(l_vendor_site_id ,l_vendor_site_id_per_code)
         AND vendor_id = p_invoice_rec.vendor_id;

       EXCEPTION
         WHEN no_data_found THEN
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INCONSISTENT SUPPL SITE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    'insert_rejections<-'
                                    ||current_calling_sequence);
            END IF;
            RAISE supplier_site_check_failure;
         END IF;
         return_vendor_site_id := null;
         l_current_invoice_status := 'N';
       END;

       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   '------------------> l_valid_vendor = '|| l_valid_vendor);
       END IF;

     END IF; -- Make sure vendor site and vendor match

     IF l_current_invoice_status = 'Y' THEN
     -- Make sure that the EDI site and
     -- the PO site belong to the same supplier
     -- if not then reject
       IF (((l_vendor_site_id is not null) OR
          (l_vendor_site_id_per_code is not null)) AND
          (p_vendor_site_id_per_po is not null)) THEN

         debug_info := '(Check Invalid Site 7) Check Supplier Site info for EDI'
                     ||' and PO site';
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
         END IF;

         BEGIN
           SELECT distinct vendor_id
           INTO l_check_vendor_id
           FROM po_vendor_sites
           WHERE vendor_site_id IN (l_vendor_site_id, p_vendor_site_id_per_po,
                l_vendor_site_id_per_code);

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
           debug_info := '(Check Invalid Site 8) EDI and PO site are '
                         ||'invalid: Reject';
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
           END IF;

           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                 p_invoice_rec.invoice_id,
                 'INCONSISTENT SUPPL SITE',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'insert_rejections<-'||current_calling_sequence);
             END IF;
             RAISE supplier_site_check_failure;
           END IF;

           l_current_invoice_status := 'N';

         WHEN TOO_MANY_ROWS THEN
           debug_info := '(Check Invalid Site 9) EDI and PO site are '
                         ||'for different supplier';
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
           END IF;

           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                 p_invoice_rec.invoice_id,
                 'INCONSISTENT SUPPL SITE',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'insert_rejections<-' ||current_calling_sequence);
             END IF;
             RAISE supplier_site_check_failure;
           END IF;

           l_current_invoice_status := 'N';

       END;
     END IF; -- Do vendor site, vendor site per code and per po
             -- belong to same supplier?

     if l_vendor_site_id is null THEN
       if nvl(l_pay_site_flag_per_code, 'N') = 'N' THEN
         -- pay site is not a pay site
         debug_info := '(Check Invalid Site 10) Not a pay site per '
                       ||'supplier site code';
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
         END IF;

         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
              (AP_IMPORT_INVOICES_PKG.g_invoices_table,
               p_invoice_rec.invoice_id,
              'NOT PAY SITE',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence) <> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<-' ||current_calling_sequence);
           END IF;
           RAISE supplier_site_check_failure;
         END IF;
         l_current_invoice_status := 'N';
       END IF; -- Pay site flag per code is N

     ELSE -- Vendor site id is not null
       if nvl(l_pay_site_flag, 'N') = 'N' THEN
         -- pay site is not a pay site
         debug_info := '(Check Invalid Site 11) Not a pay site '
                       ||'per supplier site id';
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
         END IF;

         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
           (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'NOT PAY SITE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections<-'||current_calling_sequence);
           END IF;
           RAISE supplier_site_check_failure;
         END IF;
         l_current_invoice_status := 'N';
       END IF; -- vendor site pay site flag is N

     END IF; -- Vendor site id is null

   END IF; -- Make sure site and PO site  belong to the same supplier

   -- if all checks passed successfully, save vendor_site_id
   if l_current_invoice_status = 'Y' THEN
     if l_vendor_site_id is null THEN
       return_vendor_site_id := l_vendor_site_id_per_code;
     else
       return_vendor_site_id := l_vendor_site_id;
     end if;
   end if;

 END IF; -- p_invoice_rec.vendor_site_id is null
         -- p_invoice_rec.vendor_site_code is null AND
         -- p_vendor_site_id_per_po is null

 p_return_vendor_site_id := return_vendor_site_id;
 p_current_invoice_status := l_current_invoice_status;
 RETURN (TRUE);

EXCEPTION
  WHEN no_data_found THEN
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INVALID SUPPLIER SITE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    'insert_rejections<-'
                                    ||current_calling_sequence);
      END IF;
      RAISE supplier_site_check_failure;
    END IF;

    l_current_invoice_status := 'N';

    p_return_vendor_site_id := return_vendor_site_id;
    p_current_invoice_status := l_current_invoice_status;
    RETURN (TRUE);

  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN (FALSE);

END v_check_invalid_supplier_site;



-----------------------------------------------------------------------------
-- This function is used to perform Party validation
--
-----------------------------------------------------------------------------
FUNCTION v_check_invalid_party(
         p_invoice_rec   IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_default_last_updated_by     IN            NUMBER,
         p_default_last_update_login   IN            NUMBER,
         p_current_invoice_status      IN OUT NOCOPY VARCHAR2,
         p_calling_sequence            IN            VARCHAR2)
RETURN BOOLEAN IS

party_check_failure         EXCEPTION;
l_party_id                  NUMBER;
l_current_invoice_status    VARCHAR2(1) := 'Y';
current_calling_sequence    VARCHAR2(2000);
debug_info                  VARCHAR2(500);


BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_invalid_party<-'
    ||P_calling_sequence;

  IF (p_invoice_rec.party_id is NULL) THEN

    -------------------------------------------------------------------------
    -- Step 1
    -- Check for Null Party.
    -------------------------------------------------------------------------
    debug_info := '(Check Invalid Party 1) Check for Null Party.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
            (AP_IMPORT_INVOICES_PKG.g_invoices_table,
             p_invoice_rec.invoice_id,
             'INVALID PARTY',
             p_default_last_updated_by,
             p_default_last_update_login,
             current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE party_check_failure;
    END IF;

  ELSE

     IF (p_invoice_rec.party_id is NOT NULL) THEN
       ----------------------------------------------------------------------
       -- Step 2
       -- validate party id
       ----------------------------------------------------------------------
       debug_info := '(Check Invalid Party 2) Validate party id.';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
       END IF;

       SELECT party_id
         INTO l_party_id
         FROM hz_parties hzp
        WHERE party_id = p_invoice_rec.party_id;

     END IF;

  END IF;

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION
  WHEN no_data_found THEN

    -------------------------------------------------------------------------
    -- Step 8
    -- Check for invalid Party.
    -------------------------------------------------------------------------
    debug_info := '(Check Invalid Party 8) Check for invalid Party.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID PARTY',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE party_check_failure;

    END IF;
    l_current_invoice_status := 'N';
    p_current_invoice_status := l_current_invoice_status;
    RETURN (TRUE);


  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_invalid_party;



------------------------------------------------------------------
-- This function is used to perform Party Site validation
--
------------------------------------------------------------------
FUNCTION v_check_invalid_party_site (
         p_invoice_rec  IN  AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_default_last_updated_by    IN            NUMBER,
         p_default_last_update_login  IN            NUMBER,
         p_return_party_site_id       OUT NOCOPY    NUMBER,
         p_terms_date_basis           OUT NOCOPY    VARCHAR2,
         p_current_invoice_status     IN OUT NOCOPY VARCHAR2,
         p_calling_sequence           IN            VARCHAR2)
RETURN BOOLEAN IS

party_site_check_failure        EXCEPTION;
l_party_site_id                 NUMBER(15);
l_current_invoice_status        VARCHAR2(1):='Y';
return_party_site_id            NUMBER(15);
current_calling_sequence        VARCHAR2(2000);
debug_info                      VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_invalid_party_site<-'
     ||P_calling_sequence;

  debug_info := '(Check Invalid Party Site 1) Check Party Site';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  IF (p_invoice_rec.party_site_id is null) THEN

      BEGIN
        SELECT party_site_id
        INTO   l_party_site_id
        FROM   HZ_Party_Sites HPS
        WHERE  HPS.Party_ID = p_invoice_rec.party_id
        AND    HPS.Identifying_Address_Flag = 'Y'
        AND    NVL(HPS.Start_Date_Active, AP_IMPORT_INVOICES_PKG.g_inv_sysdate)
                         <= AP_IMPORT_INVOICES_PKG.g_inv_sysdate
        AND    NVL(HPS.End_Date_Active, AP_IMPORT_INVOICES_PKG.g_inv_sysdate)
                         >= AP_IMPORT_INVOICES_PKG.g_inv_sysdate;

      EXCEPTION
        when no_data_found then
             debug_info := '(Check Invalid Party Site 2) No Party Site, Reject';

             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                 AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
             END IF;

             -- no party site exists
             IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                      p_invoice_rec.invoice_id,
                      'INVALID PARTY SITE',
                      p_default_last_updated_by,
                      p_default_last_update_login,
                      current_calling_sequence) <> TRUE) THEN
                   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       'insert_rejections<-'
                                       ||current_calling_sequence);
                   END IF;
                   RAISE party_site_check_failure;
             END IF;
             l_current_invoice_status := 'N';
       END;

  ELSE

      debug_info := '(Check Invalid Party Site 3) Check Party Site ';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      BEGIN
        --validate party site id
        SELECT party_site_id
        INTO   l_party_site_id
        FROM   hz_party_sites hps
        WHERE  party_site_id = p_invoice_rec.party_site_id
        AND    party_id = p_invoice_rec.party_id
        AND    status = 'A'
        AND    NVL(HPS.Start_Date_Active, AP_IMPORT_INVOICES_PKG.g_inv_sysdate)
                         <= AP_IMPORT_INVOICES_PKG.g_inv_sysdate
        AND    NVL(HPS.End_Date_Active, AP_IMPORT_INVOICES_PKG.g_inv_sysdate)
                         >= AP_IMPORT_INVOICES_PKG.g_inv_sysdate;

      EXCEPTION
        when no_data_found then
             debug_info := '(Check Invalid Party Site 2) Invalid Party Site, Reject';
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                 AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
             END IF;

             -- invalid party site
             IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                      p_invoice_rec.invoice_id,
                      'INVALID PARTY SITE',
                      p_default_last_updated_by,
                      p_default_last_update_login,
                      current_calling_sequence) <> TRUE) THEN
                   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       'insert_rejections<-'
                                       ||current_calling_sequence);
                   END IF;
                   RAISE party_site_check_failure;
             END IF;
             l_current_invoice_status := 'N';
       END;

    END IF;


    -- Get terms_date_basis from ap_system_parameters
    /*SELECT terms_date_basis
    INTO   p_terms_date_basis
    FROM   ap_system_parameters
    WHERE  org_id = p_invoice_rec.org_id;*/ --Bug8323165

    SELECT terms_date_basis
    INTO   p_terms_date_basis
    FROM   ap_product_setup;--Bug8323165



    -- if all checks passed successfully, save party_site_id
    if l_current_invoice_status = 'Y' THEN
       return_party_site_id := l_party_site_id;
    end if;


  p_return_party_site_id := return_party_site_id;
  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION

  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       SQLERRM);
      END IF;
    END IF;
    RETURN (FALSE);

END v_check_invalid_party_site;


------------------------------------------------------------------------------
-- This function is used to validate that the invoice num is
-- neither null, nor a duplicate of an existing or interface
-- invoice.
--
-----------------------------------------------------------------------------
FUNCTION v_check_invalid_invoice_num (
   p_invoice_rec                 IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_allow_interest_invoices     IN VARCHAR2,   --Bug4113223
   p_invoice_num                    OUT NOCOPY VARCHAR2,
   p_default_last_updated_by     IN            NUMBER,
   p_default_last_update_login   IN            NUMBER,
   p_current_invoice_status      IN OUT NOCOPY VARCHAR2,
   p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN
IS

invoice_num_check_failure    EXCEPTION;
l_invoice_count              NUMBER;
l_count_in_history_invoices  NUMBER;
l_invoice_num                AP_INVOICES.INVOICE_NUM%TYPE;
l_current_invoice_status     VARCHAR2(1) := 'Y';
current_calling_sequence     VARCHAR2(2000);
debug_info                   VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_invalid_invoice_num<-'
    ||P_calling_sequence;

  IF (p_invoice_rec.invoice_num IS NULL) Then
    l_invoice_num := to_char(nvl(p_invoice_rec.invoice_date,
                                 AP_IMPORT_INVOICES_PKG.g_inv_sysdate),
                             'DD/MM/RR');
  ELSE
    l_invoice_num := p_invoice_rec.invoice_num;
  End If;


  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                        '------------------> l_invoice_num  =
                        '||l_invoice_num);
  END IF;

  IF (l_invoice_num is NULL) THEN

     ------------------------------------------------------------------------
     -- Step 1
     -- Check for NULL Invoice NUMBER.
     -- This should never happen
     ------------------------------------------------------------------------
     debug_info := '(Check Invoice Number 1) Check for Null Invoice Number.';
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
     END IF;

     IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'NO INVOICE NUMBER',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       'insert_rejections<-'
                                       ||current_calling_sequence);
       END IF;
       RAISE invoice_num_check_failure;
     END IF;

     l_current_invoice_status := 'N';

  ELSE
     ------------------------------------------------------------------------
     -- Step 2
     -- Check for Invalid Invoice NUMBER.
     ------------------------------------------------------------------------

     /* Bugfix: 4113223
     Raise an exception if the invoice number has more than 45 characters
     and interest invoices option is enabled*/

     debug_info := '(Check Invoice Number 2) Check for Invalid Invoice Number.';
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
     END IF;

     IF (nvl(p_allow_interest_invoices,'N') = 'Y'
         AND LENGTH(l_invoice_num) > 45) THEN

	IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                       (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                        p_invoice_rec.invoice_id,
                        'INVALID INVOICE NUMBER',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'INVOICE NUMBER',
                        l_invoice_num) <> TRUE) THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections<-'||current_calling_sequence);
         END IF;
         RAISE invoice_num_check_failure;
       END IF;

       l_current_invoice_status := 'N';

     END IF;

     ------------------------------------------------------------------------
     -- Step 3
     -- Check for Duplicate Invoice NUMBER.
     ------------------------------------------------------------------------
     debug_info := '(Check Invoice Number 3) Check for Duplicate '
                   ||'Invoice Number.';
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
     END IF;

     SELECT count(*)
      INTO  l_invoice_count
      FROM  ap_invoices
     WHERE  vendor_id = p_invoice_rec.vendor_id
       AND  invoice_num = l_invoice_num
       AND (party_site_id = p_invoice_rec.party_site_id /*Bug9105666*/
 	OR (party_site_id is null and p_invoice_rec.party_site_id is null)) /*Bug9105666*/
       AND  rownum = 1;


     SELECT count(*)
       INTO l_count_in_history_invoices
       FROM ap_history_invoices ahi,
            ap_supplier_sites ass /*Bug9105666*/
       WHERE ahi.vendor_id = ass.vendor_id /*Bug9105666*/
 	 AND ahi.org_id = ass.org_id /*Bug9105666*/
 	 AND ahi.vendor_id = p_invoice_rec.vendor_id
 	 AND (ass.party_site_id = p_invoice_rec.party_site_id /*Bug9105666*/
 	      OR (ass.party_site_id is null and p_invoice_rec.party_site_id is null)) /*Bug9105666*/
 	 AND ahi.invoice_num = l_invoice_num;


     IF ((l_invoice_count > 0) OR (l_count_in_history_invoices > 0)) THEN

       -- Pass context for XML GATEWAY
       IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                       (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                        p_invoice_rec.invoice_id,
                        'DUPLICATE INVOICE NUMBER',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'INVOICE NUMBER',
                        l_invoice_num) <> TRUE) THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections<-'||current_calling_sequence);
         END IF;
         RAISE invoice_num_check_failure;
       END IF;

       l_current_invoice_status := 'N';

     END IF;
  END IF;

  p_current_invoice_status := l_current_invoice_status;
  p_invoice_num := l_invoice_num;
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_invalid_invoice_num;


------------------------------------------------------------------
-- This function is used to validate that the invoice currency code
-- is neither inactive, nor invalid.
--
------------------------------------------------------------------
FUNCTION v_check_invalid_inv_curr_code (
           p_invoice_rec IN    AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
           p_inv_currency_code            OUT NOCOPY VARCHAR2,
           p_min_acc_unit_inv_curr        OUT NOCOPY NUMBER,
           p_precision_inv_curr           OUT NOCOPY NUMBER,
           p_default_last_updated_by   IN            NUMBER,
           p_default_last_update_login IN            NUMBER,
           p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
           p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN
IS

invalid_inv_curr_code_failure  EXCEPTION;
l_current_invoice_status       VARCHAR2(1) := 'Y';
l_start_date_active            DATE;
l_end_date_active              DATE;
current_calling_sequence       VARCHAR2(2000);
debug_info                     VARCHAR2(500);
l_min_acc_unit_inv_curr        fnd_currencies.minimum_accountable_unit%TYPE;
l_precision_inv_curr           fnd_currencies.precision%TYPE;
l_enabled_flag                 fnd_currencies.enabled_flag%TYPE;

l_valid_inv_currency           fnd_currencies.currency_code%TYPE;

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_invalid_inv_curr_code<-'
    ||P_calling_sequence;

  p_inv_currency_code := p_invoice_rec.invoice_currency_code;


  --------------------------------------------------------------------------
  -- Step 1
  -- If Invoice Currency Code is null ,default from PO Vendor Sites
  --------------------------------------------------------------------------
  IF (p_invoice_rec.invoice_currency_code IS NULL) Then
    debug_info := '(Check Invoice Currency Code 1) Invoice Currency Code is '
                  ||'null ,default from PO Vendor Sites.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    -- Added for payment requests project --commented for Bug9184247
/*    IF (p_invoice_rec.party_site_id IS NOT NULL) THEN
        -- If No curr code in vendor site ,then the default exception
        -- will reject.
        SELECT Invoice_currency_code
          INTO p_inv_currency_code
          FROM AP_System_Parameters
         WHERE Org_ID = p_invoice_rec.org_id;

    ELSE
        -- If No curr code in vendor site ,then the default exception
        -- will reject.
        SELECT Invoice_currency_code
          INTO p_inv_currency_code
          FROM po_vendor_sites
         WHERE vendor_site_id = p_invoice_rec.vendor_site_id;
    END IF;*/ --commented for Bug9184247
  --Start Bug9184247
            IF p_invoice_rec.vendor_site_id IS NOT NULL
            THEN
            BEGIN
                SELECT Invoice_currency_code
                INTO p_inv_currency_code
                FROM po_vendor_sites
                WHERE vendor_site_id = p_invoice_rec.vendor_site_id;
            EXCEPTION
              WHEN OTHERS THEN
                p_inv_currency_code := null;
            END;
          END IF;

          IF p_inv_currency_code IS NULL
          THEN
            SELECT Invoice_currency_code
              INTO p_inv_currency_code
              FROM AP_System_Parameters
             WHERE Org_ID = p_invoice_rec.org_id;
          END IF;

--End Bug9184247
  END IF;

  --------------------------------------------------------------------------
  -- Step 2
  -- Get the state of the invoice currency and precision and mau
  --------------------------------------------------------------------------
  debug_info := '(Check Invoice Currency Code 2) Get precision, '
                ||'mau for Invoice Currency Code.';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  /*SELECT start_date_active, end_date_active,
         minimum_accountable_unit, precision, enabled_flag
    INTO l_start_date_active, l_end_date_active,
         l_min_acc_unit_inv_curr,l_precision_inv_curr, l_enabled_flag
    FROM fnd_currencies
   WHERE currency_code = p_inv_currency_code; */

   -- Bug 5448579
  FOR i IN AP_IMPORT_INVOICES_PKG.g_fnd_currency_tab.First..AP_IMPORT_INVOICES_PKG.g_fnd_currency_tab.Last
  LOOP
    IF AP_IMPORT_INVOICES_PKG.g_fnd_currency_tab(i).currency_code = p_inv_currency_code THEN
        l_valid_inv_currency  := AP_IMPORT_INVOICES_PKG.g_fnd_currency_tab(i).currency_code;
        l_start_date_active   := AP_IMPORT_INVOICES_PKG.g_fnd_currency_tab(i).start_date_active;
        l_end_date_active     := AP_IMPORT_INVOICES_PKG.g_fnd_currency_tab(i).end_date_active;
        l_min_acc_unit_inv_curr := AP_IMPORT_INVOICES_PKG.g_fnd_currency_tab(i).minimum_accountable_unit;
        l_precision_inv_curr  := AP_IMPORT_INVOICES_PKG.g_fnd_currency_tab(i).precision;
        l_enabled_flag        := AP_IMPORT_INVOICES_PKG.g_fnd_currency_tab(i).enabled_flag;
      EXIT;
    END IF;
  END LOOP;

  debug_info := 'l_valid_inv_currency: '||l_valid_inv_currency;
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
  END IF;


  p_min_acc_unit_inv_curr := l_min_acc_unit_inv_curr;
  p_precision_inv_curr := l_precision_inv_curr;

  IF ((trunc(AP_IMPORT_INVOICES_PKG.g_inv_sysdate) <
       nvl(l_start_date_active,
           trunc(AP_IMPORT_INVOICES_PKG.g_inv_sysdate))) OR
      (AP_IMPORT_INVOICES_PKG.g_inv_sysdate >=
       nvl(l_end_date_active,
           AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1))) OR
      l_enabled_flag <> 'Y' THEN

    -------------------------------------------------------------------------
    -- Step 3
    -- Check for Inactive Invoice Currency Code.
    -------------------------------------------------------------------------
    debug_info := '(Check Invoice Currency Code 3) Check for Inactive Invoice'
                  ||' Currency Code.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INACTIVE CURRENCY CODE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                            'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE invalid_inv_curr_code_failure;
    END IF;

    l_current_invoice_status := 'N';
  END IF;

  --Bug8770461
  IF( l_valid_inv_currency is null) then
    --------------------------------------------------------------------------
    -- Step 4
    -- Check for Invalid Invoice Currency Code.
    --------------------------------------------------------------------------
    debug_info := '(Check Invoice Currency Code 4) Check for Invalid Invoice '
                  ||'Currency Code.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INVALID CURRENCY CODE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE invalid_inv_curr_code_failure;
    END IF;
	l_current_invoice_status := 'N';
  END IF;
  --End of Bug8770461

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION
  --Bug8770461: This exception block is not required since the
  -- query was commented for bug5448579.
  /*
  WHEN no_data_found THEN

    --------------------------------------------------------------------------
    -- Step 4
    -- Check for Invalid Invoice Currency Code.
    --------------------------------------------------------------------------
    debug_info := '(Check Invoice Currency Code 4) Check for Invalid Invoice '
                  ||'Currency Code.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INVALID CURRENCY CODE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE invalid_inv_curr_code_failure;
    END IF;

    l_current_invoice_status := 'N';
    p_current_invoice_status := l_current_invoice_status;
    RETURN (TRUE);
    End of bug8770461*/
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_invalid_inv_curr_code;


------------------------------------------------------------------------------
-- This function is used to validate that the invoice type and
-- amount are appropriate.  It also reads the invoice type if
-- null and also sets the match mode based on invoice type.
--
------------------------------------------------------------------------------
FUNCTION v_check_invoice_type_amount (
         p_invoice_rec               IN
          AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_invoice_type_lookup_code     OUT NOCOPY VARCHAR2,
         p_match_mode                   OUT NOCOPY VARCHAR2,
         p_precision_inv_curr        IN            NUMBER,
         p_default_last_updated_by   IN            NUMBER,
         p_default_last_update_login IN            NUMBER,
         p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
         p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN
IS

invalid_type_lookup_failure    EXCEPTION;
l_current_invoice_status       VARCHAR2(1) := 'Y';
l_lines_amount_sum             NUMBER := 0;
l_no_of_lines                  NUMBER := 0;
current_calling_sequence       VARCHAR2(2000);
debug_info                     VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_INVOICES_PKG.v_check_invoice_type_amount<-'
    ||P_calling_sequence;

  --------------------------------------------------------------------------
  -- Step 1
  -- Check for Invalid Invoice type lookup code.
  --------------------------------------------------------------------------
  debug_info := '(Check Invoice Type and Amount 1) Check for Invalid Invoice'
                ||' type lookup code.';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  p_invoice_type_lookup_code := p_invoice_rec.invoice_type_lookup_code;

  -- We only support importing invoice types 'STANDARD', 'CREDIT',
  -- 'PREPAYMENT'  -- Contract Payments
  -- and 'PO PRICE ADJUST' --Retropricing
  -- and 'DEBIT' -- Debit Memo
  -- Also we check for invalid lookup code only if it is not null
  -- Else we populate STANDARD for invoice amount >=0 and CREDIT for
  -- invoice amount <0

  --Bug 4410499 Added EXPENSE REPORT  to the list of
  --invoice types we support thru open interface import

  --Contract Payments : Added 'PREPAYMENT' to the IF condition.
  --Payment Requests : Added 'PAYMENT REQUEST' to the IF condition
  --Bug 7299826 EC Subcon Project : Added 'DEBIT' to the IF condition
  IF ((p_invoice_rec.invoice_type_lookup_code IS NOT NULL) AND
     (p_invoice_rec.invoice_type_lookup_code NOT IN (
                  'STANDARD','CREDIT', 'DEBIT', 'PO PRICE ADJUST','PREPAYMENT','EXPENSE REPORT',
                  'PAYMENT REQUEST')))
    THEN

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INVALID INV TYPE LOOKUP',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE invalid_type_lookup_failure;
    END IF;

    l_current_invoice_status := 'N';

  ELSIF ((p_invoice_rec.invoice_type_lookup_code IS NULL) AND
         (p_invoice_rec.invoice_amount >=0)) THEN

    debug_info := '(Check Invoice Type and Amount 2) Invoice type lookup '
                  ||'code is null, setting to STANDARD.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    p_invoice_type_lookup_code := 'STANDARD';

  ELSIF ((p_invoice_rec.invoice_type_lookup_code IS NULL) AND
         (p_invoice_rec.invoice_amount < 0)) THEN

    debug_info := '(Check Invoice Type and Amount 2) Invoice type lookup '
                  ||'code is null, setting to CREDIT.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    p_invoice_type_lookup_code := 'CREDIT';

  END IF;

  --------------------------------------------------------------------------
  -- Step 2
  -- Check for Null Invoice Amount.
  --------------------------------------------------------------------------
  debug_info := '(Check Invoice Type and Amount 2) Check for Null Invoice'
                ||' amount.';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(
    AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  IF (p_invoice_rec.invoice_amount IS NULL) THEN

    -- Set contextual information for XML GATEWAY
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                         (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                          p_invoice_rec.invoice_id,
                          'INVALID INVOICE AMOUNT',
                          p_default_last_updated_by,
                          p_default_last_update_login,
                          current_calling_sequence,
                          'Y') <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE invalid_type_lookup_failure;
    END IF;

    l_current_invoice_status := 'N';

  ELSE

    --------------------------------------------------------------------------
    -- Step 3
    -- Check for Invalid Invoice amount.
    --------------------------------------------------------------------------
    debug_info := '(Check Invoice Type and Amount 3) Check for Invalid '
                  ||'Invoice amount.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    --Contract Payments: Modified the IF condition to add 'Prepayment' type
    --Payment Requests: Added 'PAYMENT REQUEST' type to the IF condition
    IF (((nvl(p_invoice_type_lookup_code,'DUMMY')
                    IN ('Standard','STANDARD','Prepayment','PREPAYMENT'/*, -- Bug 7002267
                        'PAYMENT REQUEST'*/)) AND
                       (p_invoice_rec.invoice_amount < 0))  OR
       ((nvl(p_invoice_type_lookup_code,'DUMMY') IN ('CREDIT', 'DEBIT')) AND --Bug 7299826 - Added DEBIT
          (p_invoice_rec.invoice_amount > 0))) THEN        -- Bug 2822878

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
           (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INCONSISTENT INV TYPE/AMT',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE invalid_type_lookup_failure;
      END IF;
      l_current_invoice_status := 'N';
    END IF;

    --------------------------------------------------------------------------
    -- Step 4
    -- Check for Invoice amount to match sum of invoice lines amount.
    -- Also check that number of lines is not 0.
    -- The amount check will only be done for EDI GATEWAY invoices since all
    -- other type of invoices should go through as they would in the Invoice
    -- Workbench. Specifically, this change came about due to the need to have
    -- ERS invoices entered with lines exclusive of tax and no tax line in
    -- which case the invoice amount will not total the sum of the lines.
    -- The tax is then calculated through either calculate tax in the invoice
    -- workbench or approval.  In any case, if the total of the lines does
    -- not equal the invoice total the invoice would go on hold.
    -------------------------------------------------------------------------
    --Retropricing
    IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN
        debug_info := '(Check Invoice Type and Amount 4) Check for Invoice amount'
                      ||' to match sum of invoice line amounts.';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        SELECT nvl(sum(amount),0) , count(*)
          INTO l_lines_amount_sum, l_no_of_lines
          FROM ap_invoice_lines_interface
         WHERE invoice_id = p_invoice_rec.invoice_id;

        IF (AP_IMPORT_INVOICES_PKG.g_source = 'EDI GATEWAY') THEN
          debug_info := '(Check Invoice step 4) Check Invoice amount to match '
                        ||'sum of invoice line amounts for EDI only.';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                          debug_info);
          END IF;

          IF (l_lines_amount_sum <> p_invoice_rec.invoice_amount) THEN

            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVOICE AMOUNT INCORRECT',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
              END IF;
              RAISE invalid_type_lookup_failure;
            END IF;
            l_current_invoice_status := 'N';
          END IF;
        END IF; -- Source EDI GATEWAY

        IF (l_no_of_lines = 0) THEN
          debug_info := '(Check Invoice Type and Amount 4) No Lines for this '
                        ||'invoice.';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                          debug_info);
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
              (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'NO INVOICE LINES',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE invalid_type_lookup_failure;
          END IF;
          l_current_invoice_status := 'N';
        END IF; -- No of lines is 0
    END IF; --source <> PPA

    --------------------------------------------------------------------------
    -- Step 5
    -- Check for appropriate formatting of the invoice amount.
    --------------------------------------------------------------------------
    IF LENGTH((ABS(p_invoice_rec.invoice_amount) -
                 TRUNC(ABS(p_invoice_rec.invoice_amount)))) - 1
               > NVL(p_precision_inv_curr,0) THEN
      debug_info := '(Check Invoice Type and Amount 5) Invoice or Lines '
                    ||'amount exceeds precision.';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                       (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                        p_invoice_rec.invoice_id,
                        'AMOUNT EXCEEDS PRECISION',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE invalid_type_lookup_failure;
      END IF;
      l_current_invoice_status := 'N';
    END IF; -- Precision exceeded

  END IF; -- Invoice amount is null

  --------------------------------------------------------------------------
  -- Step 6
  -- Determine match mode.
  --------------------------------------------------------------------------
  debug_info := '(Check Invoice Type and Amount 6) Determine Match Mode.';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  If (p_invoice_type_lookup_code = 'PO PRICE ADJUST') Then

      p_match_mode := 'PO PRICE ADJUSTMENT';

  End If;

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
  RETURN(FALSE);

END v_check_invoice_type_amount;


----------------------------------------------------------------------------
-- This function is used to validate that the awt information
-- is valid and consistent.
--
----------------------------------------------------------------------------
FUNCTION v_check_invalid_awt_group (
    p_invoice_rec        IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_awt_group_id                  OUT NOCOPY NUMBER,
    p_default_last_updated_by    IN            NUMBER,
    p_default_last_update_login  IN            NUMBER,
    p_current_invoice_status     IN OUT NOCOPY VARCHAR2,
    p_calling_sequence           IN            VARCHAR2) RETURN BOOLEAN
IS

awt_group_check_failure     EXCEPTION;
l_current_invoice_status    VARCHAR2(1) := 'Y';
l_awt_group_id              AP_INVOICES.AWT_GROUP_ID%TYPE;
l_awt_group_id_per_name     AP_INVOICES.AWT_GROUP_ID%TYPE;
l_inactive_date             DATE;
l_inactive_date_per_name    DATE;
current_calling_sequence    VARCHAR2(2000);
debug_info                  VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_invalid_awt_group<-'
    ||P_calling_sequence;

  IF p_invoice_rec.awt_group_id is not null THEN

    --validate awt_group_id
    SELECT group_id, inactive_date
      INTO l_awt_group_id, l_inactive_date
      FROM ap_awt_groups
     WHERE group_id = p_invoice_rec.awt_group_id;

  END IF;

  IF (p_invoice_rec.awt_group_name is NOT NULL) THEN
    --validate awt group name and retrieve awt group id
    SELECT group_id, inactive_date
      INTO l_awt_group_id_per_name, l_inactive_date_per_name
      FROM ap_awt_groups
     WHERE name = p_invoice_rec.awt_group_name;
  END IF;

  IF (l_awt_group_id is NOT NULL) AND
     (l_awt_group_id_per_name is NOT NULL) AND
     (l_awt_group_id <> l_awt_group_id_per_name) THEN

    -------------------------------------------------------------------------
    -- Step 1
    -- Check for AWT Group Id and Group Name Inconsistency.
    -------------------------------------------------------------------------
    debug_info := '(Check AWT Group 1) Check for AWT Group Id and Group Name'
                  ||' Inconsistency.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INCONSISTENT AWT GROUP',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE awt_group_check_failure;
    END IF;
    l_current_invoice_status := 'N';

  ELSE

    ------------------------------------------------------------------------
    -- Step 2
    -- Check for Inactive AWT Group
    ------------------------------------------------------------------------
    debug_info := '(Check AWT Group 2) Check for Inactive AWT Group';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF ((l_awt_group_id is NULL) and
        (l_awt_group_id_per_name is NOT NULL)) THEN

      IF AP_IMPORT_INVOICES_PKG.g_inv_sysdate >=
         nvl(l_inactive_date_per_name,
             AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1) THEN
        --------------------------------------------------------------
        -- inactive AWT group (per name)
        --
        ---------------------------------------------------------------
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                             (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                            p_invoice_rec.invoice_id,
            'INACTIVE AWT GROUP',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE awt_group_check_failure;
        END IF;

        l_current_invoice_status := 'N';

      END IF; -- Inactive AWT Group per name

    ELSIF (((l_awt_group_id is NOT NULL) and
            (l_awt_group_id_per_name is NULL)) OR
           ((l_awt_group_id is NOT NULL) and
            (l_awt_group_id_per_name is NOT NULL) and
            (l_awt_group_id = l_awt_group_id_per_name))) THEN

      IF AP_IMPORT_INVOICES_PKG.g_inv_sysdate >=
         nvl(l_inactive_date, AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1) THEN

        --------------------------------------------------------------
        -- inactive AWT group (as per id)
        --
        --------------------------------------------------------------
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INACTIVE AWT GROUP',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE awt_group_check_failure;
        END IF;

        l_current_invoice_status := 'N';

      END IF; -- Inactive AWT Group per id

    END IF; -- awt group id is null and awt group id per name is not null

  END IF; -- awt group id is not null, awt group id per name is not null
          -- but they differ

  IF (l_awt_group_id is not null) then
    p_awt_group_id := l_awt_group_id;
  ELSIF (l_awt_group_id_per_name IS NOT NULL) THEN
    p_awt_group_id := l_awt_group_id_per_name;
  ELSE
    IF ((l_current_invoice_status <> 'N') AND
           (p_invoice_rec.invoice_type_lookup_code <> 'PAYMENT REQUEST')) THEN
       -- Get awt group id from supplier site
      BEGIN
        SELECT awt_group_id
          INTO p_awt_group_id
      FROM po_vendor_sites
         WHERE vendor_id = p_invoice_rec.vendor_id
         AND vendor_site_id = p_invoice_rec.vendor_site_id;
      EXCEPTION
    WHEN no_data_found THEN
      RAISE awt_group_check_failure;
    WHEN OTHERS THEN
      RAISE awt_group_check_failure;
      END;
    END IF;
  END IF;


  p_current_invoice_status := l_current_invoice_status;

  RETURN (TRUE);

EXCEPTION
  WHEN no_data_found THEN
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
       (AP_IMPORT_INVOICES_PKG.g_invoices_table,
         p_invoice_rec.invoice_id,
         'INVALID AWT GROUP',
         p_default_last_updated_by,
         p_default_last_update_login,
         current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE awt_group_check_failure;
    END IF;

    l_current_invoice_status := 'N';
    p_current_invoice_status := l_current_invoice_status;
    RETURN (TRUE);

  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_invalid_awt_group;

--bug6639866
----------------------------------------------------------------------------
-- This function is used to validate that the pay awt information
-- is valid and consistent.
--
----------------------------------------------------------------------------
FUNCTION v_check_invalid_pay_awt_group (
    p_invoice_rec        IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_pay_awt_group_id                  OUT NOCOPY NUMBER,
    p_default_last_updated_by    IN            NUMBER,
    p_default_last_update_login  IN            NUMBER,
    p_current_invoice_status     IN OUT NOCOPY VARCHAR2,
    p_calling_sequence           IN            VARCHAR2) RETURN BOOLEAN
IS

pay_awt_group_check_failure     EXCEPTION;
l_current_invoice_status    VARCHAR2(1) := 'Y';
l_pay_awt_group_id              AP_INVOICES.pay_AWT_GROUP_ID%TYPE;
l_pay_awt_group_id_per_name     AP_INVOICES.pay_AWT_GROUP_ID%TYPE;
l_inactive_date             DATE;
l_inactive_date_per_name    DATE;
current_calling_sequence    VARCHAR2(2000);
debug_info                  VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_invalid_pay_awt_group<-'
    ||P_calling_sequence;

  IF p_invoice_rec.pay_awt_group_id is not null THEN

    --validate pay_awt_group_id
    SELECT group_id, inactive_date
    INTO l_pay_awt_group_id, l_inactive_date
      FROM ap_awt_groups
     WHERE group_id = p_invoice_rec.pay_awt_group_id;

  END IF;

  IF (p_invoice_rec.pay_awt_group_name is NOT NULL) THEN
    --validate pay awt group name and retrieve pay awt group id
    SELECT group_id, inactive_date
      INTO l_pay_awt_group_id_per_name, l_inactive_date_per_name
      FROM ap_awt_groups
     WHERE name = p_invoice_rec.pay_awt_group_name;
  END IF;

  IF (l_pay_awt_group_id is NOT NULL) AND
     (l_pay_awt_group_id_per_name is NOT NULL) AND
     (l_pay_awt_group_id <> l_pay_awt_group_id_per_name) THEN

    -------------------------------------------------------------------------
    -- Step 1
    -- Check for pay AWT Group Id and Group Name Inconsistency.
    -------------------------------------------------------------------------
    debug_info := '(Check AWT Group 1) Check for pay AWT Group Id and pay Group Name'
                  ||' Inconsistency.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INCONSISTENT PAY AWT GROUP',
            p_default_last_updated_by,
            p_default_last_update_login,
current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE pay_awt_group_check_failure;
    END IF;
    l_current_invoice_status := 'N';

  ELSE

    ------------------------------------------------------------------------
    -- Step 2
    -- Check for Inactive pay AWT Group
    ------------------------------------------------------------------------
    debug_info := '(Check AWT Group 2) Check for Inactive pay AWT Group';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF ((l_pay_awt_group_id is NULL) and
        (l_pay_awt_group_id_per_name is NOT NULL)) THEN

      IF AP_IMPORT_INVOICES_PKG.g_inv_sysdate >=
         nvl(l_inactive_date_per_name,
             AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1) THEN
        --------------------------------------------------------------
        -- inactive pay AWT group (per name)
        --
        ---------------------------------------------------------------
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
           (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INACTIVE PAY AWT GROUP',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE pay_awt_group_check_failure;
        END IF;

        l_current_invoice_status := 'N';

      END IF; -- Inactive pay AWT Group per name

    ELSIF (((l_pay_awt_group_id is NOT NULL) and
            (l_pay_awt_group_id_per_name is NULL)) OR
           ((l_pay_awt_group_id is NOT NULL) and
            (l_pay_awt_group_id_per_name is NOT NULL) and
            (l_pay_awt_group_id = l_pay_awt_group_id_per_name))) THEN

      IF AP_IMPORT_INVOICES_PKG.g_inv_sysdate >=
         nvl(l_inactive_date, AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1) THEN

        --------------------------------------------------------------
        -- inactive pay AWT group (as per id)
        --
        --------------------------------------------------------------
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INACTIVE PAY AWT GROUP',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE pay_awt_group_check_failure;
        END IF;

        l_current_invoice_status := 'N';

      END IF; -- Inactive pay AWT Group per id

    END IF; -- pay awt group id is null and pay awt group id per name is not null

  END IF; -- pay awt group id is not null, pay awt group id per name is not null
          -- but they differ

  IF (l_pay_awt_group_id is not null) then
    p_pay_awt_group_id := l_pay_awt_group_id;
  ELSIF (l_pay_awt_group_id_per_name IS NOT NULL) THEN
    p_pay_awt_group_id := l_pay_awt_group_id_per_name;
  ELSE
    IF ((l_current_invoice_status <> 'N') AND
           (p_invoice_rec.invoice_type_lookup_code <> 'PAYMENT REQUEST')) THEN
       -- Get pay awt group id from supplier site
      BEGIN
        SELECT pay_awt_group_id
          INTO p_pay_awt_group_id
      FROM po_vendor_sites
         WHERE vendor_id = p_invoice_rec.vendor_id
         AND vendor_site_id = p_invoice_rec.vendor_site_id;
      EXCEPTION
    WHEN no_data_found THEN
      RAISE pay_awt_group_check_failure;
    WHEN OTHERS THEN
      RAISE pay_awt_group_check_failure;
      END;
     END IF;
    END IF;


  p_current_invoice_status := l_current_invoice_status;

  RETURN (TRUE);

EXCEPTION
  WHEN no_data_found THEN
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
       (AP_IMPORT_INVOICES_PKG.g_invoices_table,
         p_invoice_rec.invoice_id,
         'INVALID PAY AWT GROUP',
         p_default_last_updated_by,
         p_default_last_update_login,
         current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE pay_awt_group_check_failure;
    END IF;

    l_current_invoice_status := 'N';
    p_current_invoice_status := l_current_invoice_status;
    RETURN (TRUE);

  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
 IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_invalid_pay_awt_group;

----------------------------------------------------------------------------
-- This function is used to validate exchange rate information
-- for the invoice.
----------------------------------------------------------------------------
FUNCTION v_check_exchange_rate_type (
    p_invoice_rec     IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_exchange_rate                 OUT NOCOPY  NUMBER,
    p_exchange_date                 OUT NOCOPY  DATE,
    p_base_currency_code         IN             VARCHAR2,
    p_multi_currency_flag        IN             VARCHAR2,
    p_set_of_books_id            IN             NUMBER,
    p_default_exchange_rate_type IN             VARCHAR2,
    p_make_rate_mandatory_flag   IN             VARCHAR2,
    p_default_last_updated_by    IN             NUMBER,
    p_default_last_update_login  IN             NUMBER,
    p_current_invoice_status     IN OUT NOCOPY  VARCHAR2,
    p_calling_sequence           IN             VARCHAR2) RETURN BOOLEAN
IS

exchange_rate_type_failure    EXCEPTION;
l_conversion_type             VARCHAR2(30) := p_invoice_rec.exchange_rate_type;
l_exchange_date               DATE := p_invoice_rec.exchange_date;
l_exchange_rate               NUMBER := p_invoice_rec.exchange_rate;
l_current_invoice_status      VARCHAR2(1) := 'Y';
l_valid_conversion_type       VARCHAR2(30);
current_calling_sequence      VARCHAR2(2000);
debug_info                    VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_invalid_inv_curr_code<-'
    ||P_calling_sequence;

  IF (NVL(p_multi_currency_flag,'N') = 'Y') AND
     (p_base_currency_code <> p_invoice_rec.invoice_currency_code) Then

    -------------------------------------------------------------------------
    -- Step 1
    -- Check for invalid exchange rate type
    -------------------------------------------------------------------------
    debug_info := '(Check Exchange Rate Type 1) Check for invalid Exchange '
                  ||'Rate Type';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (l_conversion_type is NULL) Then
      debug_info := '(Check Exchange Rate Type 1a) Get Default Exchange '
                    ||'Rate Type';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      l_conversion_type := p_default_exchange_rate_type;
    END IF;

    IF (l_conversion_type is NOT NULL) Then
      debug_info :=
           '(Check Exchange Rate Type 1b) Check if Rate Type is valid';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      BEGIN
        SELECT 'X'
          INTO l_valid_conversion_type
          FROM gl_daily_conversion_types
          WHERE conversion_type = l_conversion_type;

      EXCEPTION
        WHEN no_data_found THEN
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                   (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                    p_invoice_rec.invoice_id,
                    'INVALID EXCH RATE TYPE',
                    p_default_last_updated_by,
                    p_default_last_update_login,
                    current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE exchange_rate_type_failure;
          END IF;
          l_current_invoice_status := 'N';

      END;

    END IF; -- conversion type not null

    -------------------------------------------------------------------------
    -- Step 2
    -- Get exchange date
    -------------------------------------------------------------------------
    IF (p_invoice_rec.exchange_date IS NULL) THEN
      debug_info :=
          '(Check Exchange Rate Type 2) Get Sysdate as Exchange Date';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      -- Invoice date was initialized to sysdate if null at the beginning
      -- of the invoice validation process.
      l_exchange_date := nvl(p_invoice_rec.gl_date,
                 p_invoice_rec.invoice_date);
    END IF;


    IF (l_valid_conversion_type ='X') Then
      ----------------------------------------------------------------------
      -- Step 3
      -- Check for Inconsistent exchange rate
      ----------------------------------------------------------------------
      debug_info := '(Check Exchange Rate Type 3a) Check for inconsistent '
                    ||'Exchange Rate, if type valid';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      debug_info := 'l_coversion_type: '||l_conversion_type ||'  '||
                     'p_invoice_rec.exchange_rate: '||p_invoice_rec.exchange_rate;

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

--Start of bug8766019
      IF (p_invoice_rec.exchange_rate <= 0) THEN
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                    (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                     p_invoice_rec.invoice_id,
                     'INVALID EXCH RATE',
                     p_default_last_updated_by,
                     p_default_last_update_login,
                     current_calling_sequence) <> TRUE) THEN
               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                 AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<-'||current_calling_sequence);
               END IF;
               RAISE exchange_rate_type_failure;
         END IF;
         l_current_invoice_status := 'N';
--End of bug8766019
      ELSIF ((l_conversion_type <> 'User') AND
          (p_invoice_rec.exchange_rate is NOT NULL)) AND   -- Bug 5003374
           nvl(ap_utilities_pkg.get_exchange_rate(       -- Added this Condition.
                                p_invoice_rec.invoice_currency_code,
                                p_base_currency_code,
                                l_conversion_type,
                                l_exchange_date,
                                current_calling_sequence),-999) <> p_exchange_rate THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
            (AP_IMPORT_INVOICES_PKG.g_invoices_table,
              p_invoice_rec.invoice_id,
             'INCONSISTENT RATE',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE exchange_rate_type_failure;
        END IF;

        l_current_invoice_status := 'N';

      ELSIF ((l_conversion_type = 'User') AND
              (p_invoice_rec.exchange_rate is NULL))  AND
             (AP_UTILITIES_PKG.calculate_user_xrate (
                  p_invoice_rec.invoice_currency_code,
                  p_base_currency_code,
                  l_exchange_date,
                  l_conversion_type) <> 'Y') THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                                     (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                                      p_invoice_rec.invoice_id,
                                     'NO EXCHANGE RATE',
                                      p_default_last_updated_by,
                                      p_default_last_update_login,
                                      current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE exchange_rate_type_failure;
        END IF;

        l_current_invoice_status := 'N';

      ELSIF ((l_conversion_type <> 'User') AND
       (p_invoice_rec.exchange_rate is NULL))   Then
        null;

        debug_info := '(Check Exchange Rate Type 3b) Get Exchange Rate for'
                      ||' type other than User';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        l_exchange_rate := ap_utilities_pkg.get_exchange_rate(
                p_invoice_rec.invoice_currency_code,
                p_base_currency_code,
                l_conversion_type,
                l_exchange_date,
                current_calling_sequence);
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '----------------> exchange_rate = '|| to_char(l_exchange_rate)
          ||'set_of_books_id = '||to_char(p_set_of_books_id)
          ||'invoice_currency_code = '||p_invoice_rec.invoice_currency_code
          ||'exchange_date= '||to_char(l_exchange_date)
          ||'conversion_type = '||l_conversion_type);
        END IF;

        IF (l_exchange_rate IS NULL) THEN

          IF (NVL(p_make_rate_mandatory_flag,'N') = 'Y') then
            debug_info :=
              '(Check Exchange Rate Type 3c) Reject:No Exchange Rate ';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                    (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                     p_invoice_rec.invoice_id,
                     'NO EXCHANGE RATE',
                     p_default_last_updated_by,
                     p_default_last_update_login,
                     current_calling_sequence) <> TRUE) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
              END IF;
              RAISE exchange_rate_type_failure;
            END IF;

            l_current_invoice_status := 'N';

          ELSE
            debug_info := '(Check Exchange Rate Type 3d) No Exchange'
                          ||' Rate:Rate Not Reqd ';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                     AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

          END IF; -- make_rate_mandatory

        END IF;  -- exchange_rate is null
            --4091870
       ELSIF ((l_conversion_type = 'User') AND
                    (p_exchange_rate <= 0))  then

                IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                    (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                     p_invoice_rec.invoice_id,
                     'INVALID EXCH RATE',
                     p_default_last_updated_by,
                     p_default_last_update_login,
                     current_calling_sequence) <> TRUE) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
              END IF;
              RAISE exchange_rate_type_failure;
            END IF;

                l_current_invoice_status := 'N';
              --4091870 end
      END IF; -- l_conversion_type <>User


      IF ((l_conversion_type <> 'User') AND
          (p_invoice_rec.exchange_rate is NOT NULL) AND
          (p_invoice_rec.exchange_rate <> l_exchange_rate)) Then

        debug_info := '(Check Exchange Rate Type 3e) Exchange rate in '
                      ||'interface differs rate defined';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
             (AP_IMPORT_INVOICES_PKG.g_invoices_table,
              p_invoice_rec.invoice_id,
              'INCONSISTENT RATE',
              p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE exchange_rate_type_failure;
        END IF;
        l_current_invoice_status := 'N';

      END IF; -- exchange rate in interface other than defined in system

    END IF; -- l_valid_conversion_type = 'X'

  ELSIF ((nvl(p_multi_currency_flag,'N') = 'N') AND
         (p_base_currency_code <> p_invoice_rec.invoice_currency_code)) THEN

    -------------------------------------------------------------------------
    -- Step 4
    -- Check for Inconsistent Information Entered
    -------------------------------------------------------------------------
    debug_info := '(Check Exchange Rate Type 9) Check for inconsistent '
                  ||'Information Entered';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
        (AP_IMPORT_INVOICES_PKG.g_invoices_table,
          p_invoice_rec.invoice_id,
         'INCONSISTENT INFO ENTERED',
          p_default_last_updated_by,
          p_default_last_update_login,
          current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE exchange_rate_type_failure;
    END IF;

    l_current_invoice_status := 'N';
    /*bug 8887650 begin*/
  ELSIF (p_base_currency_code = p_invoice_rec.invoice_currency_code)
       AND NOT(p_invoice_rec.exchange_rate_type IS NULL AND
               p_invoice_rec.exchange_date IS NULL AND
	       p_invoice_rec.exchange_rate IS NULL) THEN

    ------------------------------------------------------------------------------
    -- Step 4.a
    -- Check for Inconsistent Information Entered when base and funct curr is same
    ------------------------------------------------------------------------------
    debug_info := '(Check Exchange Rate Type 9.a) Check for inconsistent exchange '
                  ||'Information Entered';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

       IF nvl(p_invoice_rec.exchange_rate,1) <> 1 THEN

         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                    (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                     p_invoice_rec.invoice_id,
		     'INCONSISTENT RATE',
		     p_default_last_updated_by,
		     p_default_last_update_login,
		     current_calling_sequence) <> TRUE) THEN

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<-'||current_calling_sequence);
            END IF;
           RAISE exchange_rate_type_failure;

         END IF;

         l_current_invoice_status := 'N';
      ELSE
       --Need not populate exchange rate infos when base and func currency
       --are same. This will forbade accounting issues out of base amount calculation.

         l_exchange_rate := NULL;
         l_exchange_date := NULL;

	debug_info := '(Check Exchange Rate Type 9.b) Exchange'
                          ||' Rate info :Nullified ';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;

      END IF;
     /*bug 8887650 end*/

  END IF; -- multi currency flag and foreign currency invoice

  p_exchange_rate := l_exchange_rate;
  p_exchange_date := l_exchange_date;
  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

  IF (SQLCODE < 0) then
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
    END IF;
  END IF;

  RETURN(FALSE);

END v_check_exchange_rate_type;

------------------------------------------------------------------
-- This function is used to validate payment terms information.
--
------------------------------------------------------------------
FUNCTION v_check_invalid_terms (
    p_invoice_rec  IN      AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_terms_id                      OUT NOCOPY NUMBER,
    p_terms_date                    OUT NOCOPY DATE,
    p_terms_date_basis           IN            VARCHAR2,
    p_default_last_updated_by    IN            NUMBER,
    p_default_last_update_login  IN            NUMBER,
    p_current_invoice_status     IN OUT NOCOPY VARCHAR2,
    p_calling_sequence           IN            VARCHAR2) RETURN BOOLEAN
IS

terms_check_failure           EXCEPTION;
l_current_invoice_status      VARCHAR2(1) := 'Y';
l_term_id                     NUMBER := Null;
l_term_id_per_name            NUMBER := Null;
l_start_date_active           DATE;
l_end_date_active             DATE;
l_start_date_active_per_name  DATE;
l_end_date_active_per_name    DATE;
current_calling_sequence      VARCHAR2(2000);
debug_info                    VARCHAR2(500);

l_term_name                     VARCHAR2(50);--Bug 4115712
l_no_calendar_exists            VARCHAR2(1); --Bug 4115712

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
     'AP_IMPORT_VALIDATION_PKG.v_check_invalid_terms<-'
     ||P_calling_sequence;
  --------------------------------------------------------------------------
  -- Fidelity needs to ignore terms info if you have PO as well.
  -- In this case we should not check/reject for inconsistency
  -- instead take the terms from PO / Supplier.
  -- terms defaulting: If terms provided in the interface (default
  -- from supplier using IG) use them unconditionally. If terms not provided
  -- and PO exists, use PO terms else default terms from Supplier Site.
  --------------------------------------------------------------------------
  BEGIN

    IF (p_invoice_rec.terms_id is not null) THEN
     --validate term_id
     SELECT term_id, start_date_active, end_date_active
       INTO l_term_id, l_start_date_active, l_end_date_active
       FROM ap_terms
      WHERE term_id = p_invoice_rec.terms_id;
    END IF;

    IF (p_invoice_rec.terms_name is not null) THEN
     --validate terms name and retrieve term id
     SELECT term_id, start_date_active, end_date_active
       INTO l_term_id_per_name, l_start_date_active_per_name,
            l_end_date_active_per_name
       FROM ap_terms
      WHERE name = p_invoice_rec.terms_name;
    END IF;

  EXCEPTION

    WHEN no_data_found THEN
      ----------------------------------------------------------------------
      -- Step 1
      -- Check invalid terms.
      ----------------------------------------------------------------------
     debug_info := '(Check Invalid Terms 1) Check for invalid Terms.';
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
     END IF;

     IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INVALID TERMS',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
         'insert_rejections<- '||current_calling_sequence);
       END IF;
       RAISE terms_check_failure;
    END IF;

    l_current_invoice_status := 'N';
    p_current_invoice_status := l_current_invoice_status;

  END;

  --------------------------------------------------------------
  -- Step 2
  -- If no payment term, get from PO or Supplier Site.
  -- Retropricing: For PPA's p_invoice_rec.terms_id is NOT NULL
  --------------------------------------------------------------
  IF ((p_invoice_rec.terms_id is NULL) AND
      (p_invoice_rec.terms_name is NULL)) THEN

    IF (p_invoice_rec.po_number is NOT NULL) Then
      debug_info :=
          '(Check Invalid Terms 2.1) Get term_id from header po_number';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      SELECT terms_id
        INTO l_term_id
        FROM po_headers
       WHERE segment1 = p_invoice_rec.po_number
         AND type_lookup_code in ('BLANKET', 'PLANNED', 'STANDARD');
    END IF;

    -- no term from header level po_number, try lines level po_number
    IF (l_term_id is null ) THEN
      debug_info :=
         '(Check Invalid Terms 2.2) Get term_id from lines po_numbers';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      BEGIN
        SELECT p.terms_id
          INTO l_term_id
          FROM po_headers p, ap_invoice_lines_interface l
         WHERE p.type_lookup_code in ('BLANKET', 'PLANNED', 'STANDARD')
           AND ((l.po_header_id = p.po_header_id) OR
                (l.po_number    = p.segment1))
           AND l.invoice_id = p_invoice_rec.invoice_id
           AND p.terms_id IS NOT NULL
         GROUP BY p.terms_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN TOO_MANY_ROWS THEN
          l_term_id        := null;
          l_current_invoice_status := 'N';
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                                 p_invoice_rec.invoice_id,
                                 'INCONSISTENT TERMS INFO',
                                 p_default_last_updated_by,
                                 p_default_last_update_login,
                                 current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<- '||current_calling_sequence);
            END IF;
            RAISE terms_check_failure;
          END IF;
      END;

      -- no term from line level PO, try line level receipt
      IF (l_term_id is null) THEN
        debug_info := '(Check Invalid Terms 2.3) Get term_id from lines'
                      ||' receipt';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;
        BEGIN
          SELECT p.terms_id
            INTO l_term_id
            FROM rcv_transactions r,
                 po_headers p,
                 ap_invoice_lines_interface l
           WHERE p.po_header_id = r.po_header_id
             AND r.transaction_id = l.rcv_transaction_id
             AND l.invoice_id = p_invoice_rec.invoice_id
             AND p.terms_id IS NOT NULL
           GROUP BY p.terms_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
          WHEN TOO_MANY_ROWS THEN
            debug_info := 'too many rows';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;
            l_term_id        := null;
            l_current_invoice_status := 'N';
            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                                  (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                                   p_invoice_rec.invoice_id,
                                   'INCONSISTENT TERMS INFO',
                                   p_default_last_updated_by,
                                   p_default_last_update_login,
                                   current_calling_sequence) <> TRUE) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<- '||current_calling_sequence);
              END IF;
              RAISE terms_check_failure;
            END IF;
        END;

      END IF; -- end get term from line level receipt

    END IF; -- end get term from line level

    -- no term from header or line level
    IF ( (nvl(l_current_invoice_status,'Y') = 'Y') AND -- not rejected already
         (l_term_id is null) AND
         (p_invoice_rec.invoice_type_lookup_code <> 'PAYMENT REQUEST') ) Then

      debug_info := '(Check Invalid Terms 2.4) Get term_id from supplier site';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      SELECT terms_id
      INTO   l_term_id
      FROM   po_vendor_sites
      WHERE  vendor_id      = p_invoice_rec.vendor_id
      AND    vendor_site_id = p_invoice_rec.vendor_site_id;

    ELSIF ( (nvl(l_current_invoice_status,'Y') = 'Y') AND -- not rejected already
         (l_term_id is null) AND
         (p_invoice_rec.invoice_type_lookup_code = 'PAYMENT REQUEST') ) Then

      debug_info := '(Check Invalid Terms 2.4) Get term_id from financials options';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      SELECT terms_id
      INTO   l_term_id
      FROM   ap_product_setup;
      -- Bug 5519299. Terms_Id for Payment request based on ap_product_setup
      -- FROM   financials_system_parameters
      -- WHERE  org_id = p_invoice_rec.org_id;

    END IF;

    IF ( nvl(l_current_invoice_status,'Y') = 'Y' ) THEN
      IF ( l_term_id is null ) THEN
        debug_info := '(Check Invalid Terms 2.5) no term_id found, '
                      ||'invoice rejected';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                             (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                              p_invoice_rec.invoice_id,
                              'NO TERMS INFO',
                              p_default_last_updated_by,
                              p_default_last_update_login,
                              current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<- '||current_calling_sequence);
          END IF;
          RAISE terms_check_failure;
        END IF;

        l_current_invoice_status := 'N';

      ELSE
        debug_info := '(Check Invalid Terms 2.6) getting term active date';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        SELECT start_date_active, end_date_active
          INTO l_start_date_active, l_end_date_active
          FROM ap_terms
         WHERE term_id = l_term_id;

      END IF; -- l_terms_id is null
    END IF; -- nvl(l_current_invoice_status,'Y') = 'Y'

  END IF; -- interface invoice terms_id and terms_name are null

  --------------------------------------------------------------------------
  -- Step 3
  -- Check Inconsistent and Inactive terms info.
  ---------------------------------------------------------------------------
  IF ((l_term_id is not null) AND
      (l_term_id_per_name is not null) AND
      (l_term_id <> l_term_id_per_name)) THEN

    debug_info := '(Check Invalid Terms 3) Check for inconsistent Terms id '
                   ||'and Name.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INCONSISTENT TERMS INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        'insert_rejections<- '||current_calling_sequence);
      END IF;
      RAISE terms_check_failure;
    END IF;

    l_current_invoice_status := 'N';

  ELSIF ((l_term_id is null) and
         (l_term_id_per_name is NOT NULL)) THEN

    IF (not((AP_IMPORT_INVOICES_PKG.g_inv_sysdate >
             nvl(l_start_date_active_per_name,
                 AP_IMPORT_INVOICES_PKG.g_inv_sysdate - 1))
        AND (AP_IMPORT_INVOICES_PKG.g_inv_sysdate <
             nvl(l_end_date_active_per_name,
                 AP_IMPORT_INVOICES_PKG.g_inv_sysdate + 1)))) THEN

      -----------------------------------------------------------------------
      -- Step 4
      -- Check inactive terms per name
      -----------------------------------------------------------------------
      debug_info :=
        '(Check Invalid Terms 4) Check for inactive Terms as per Terms Name.';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INACTIVE TERMS',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<- '||current_calling_sequence);
        END IF;
        RAISE terms_check_failure;
      END IF;

      l_current_invoice_status := 'N';
    ELSE
       p_terms_id := l_term_id_per_name;

    END IF;

  ELSIF ((l_term_id is NOT NULL) AND
         ((l_term_id_per_name is NULL) OR
          (l_term_id_per_name is NOT NULL AND
           l_term_id = l_term_id_per_name))) THEN

    IF (not((AP_IMPORT_INVOICES_PKG.g_inv_sysdate >
             nvl(l_start_date_active,
                 AP_IMPORT_INVOICES_PKG.g_inv_sysdate - 1))
        AND (AP_IMPORT_INVOICES_PKG.g_inv_sysdate <
             nvl(l_end_date_active,
                 AP_IMPORT_INVOICES_PKG.g_inv_sysdate + 1)))) THEN

      ----------------------------------------------------------------------
      -- Step 5
      -- Check inactive terms as per id
      ----------------------------------------------------------------------
      debug_info :=
        '(Check Invalid Terms 5) Check for inactive Terms as per Terms Id.';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INACTIVE TERMS',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<- '||current_calling_sequence);
        END IF;
        RAISE terms_check_failure;
      END IF;

      l_current_invoice_status := 'N';

    ELSE

      p_terms_id := l_term_id;

    END IF;

  END IF; -- Check Inconsistent and Inactive Terms

  --------------------------------------------------------------------------
  -- Step 6
  -- Check for Invoice and Goods Received Date.
  -- Reject the invoice if the Invoice and Goods Received Date is null
  -- but the terms date basis is set to Invoice Received or Goods Received.
  --
  --------------------------------------------------------------------------
  debug_info := '(Check Invalid Terms 6a) Check for Terms Date provided as input :'
                ||p_invoice_rec.terms_date;
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  /* Added following validation for bug 9918860
  As per PM input, if p_invoice_rec.terms_date is populated then we do not
  need to verify whether p_invoice_rec.invoice_received_date and
  p_invoice_rec.goods_received_date are populated. */

  IF p_invoice_rec.terms_date IS NULL THEN
	debug_info := '(Check Invalid Terms 6b) Check for Invoice and Goods '
					||'Received Date';
	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
									debug_info);
	END IF;

	IF (p_terms_date_basis = 'Invoice Received' AND
		p_invoice_rec.invoice_received_date is null) THEN

		IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
						(AP_IMPORT_INVOICES_PKG.g_invoices_table,
						p_invoice_rec.invoice_id,
						'DATE INVOICE RECEIVED REQ',
						p_default_last_updated_by,
						p_default_last_update_login,
						current_calling_sequence) <> TRUE) THEN
			IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
				AP_IMPORT_UTILITIES_PKG.Print(
				AP_IMPORT_INVOICES_PKG.g_debug_switch,
				'insert_rejections<-'||current_calling_sequence);
			END IF;
			RAISE terms_check_failure;
		END IF;

		l_current_invoice_status := 'N';

	ELSIF (p_terms_date_basis = 'Goods Received' AND
			p_invoice_rec.goods_received_date is null) THEN
		IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                     (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                      p_invoice_rec.invoice_id,
                      'DATE GOODS RECEIVED REQ',
                      p_default_last_updated_by,
                      p_default_last_update_login,
                      current_calling_sequence) <> TRUE) THEN
			IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
				AP_IMPORT_UTILITIES_PKG.Print(
				AP_IMPORT_INVOICES_PKG.g_debug_switch,
				'insert_rejections<-'||current_calling_sequence);
			END IF;
			RAISE terms_check_failure;
		END IF;

		l_current_invoice_status := 'N';
	END IF;

  	--------------------------------------------------------------------------
   	-- Step 7
  	-- Derive terms date if possible
	--
  	--------------------------------------------------------------------------
	IF (l_current_invoice_status <> 'N') THEN

		/* Commented for bug 9918860 since this validation has been placed
		at the top before checking for other dates related to terms */
		-- IF (p_invoice_rec.terms_date IS NULL) THEN
		IF (p_terms_date_basis = 'Invoice Received') THEN
			p_terms_date := p_invoice_rec.invoice_received_date;
		ELSIF (p_terms_date_basis = 'Goods Received') THEN
			p_terms_date := p_invoice_rec.goods_received_date;
		ELSIF (p_terms_date_basis = 'Invoice') THEN
			p_terms_date := p_invoice_rec.invoice_date;
		ELSIF (p_terms_date_basis = 'Current') THEN
			p_terms_date := AP_IMPORT_INVOICES_PKG.g_inv_sysdate;
		ELSE
			p_terms_date := AP_IMPORT_INVOICES_PKG.g_inv_sysdate;
		END IF;
	END IF;

  ELSE /*Bug 7635794*/
      p_terms_date := p_invoice_rec.terms_date; --bug 7635794
  END IF; -- p_invoice_rec.terms_date is null

  p_terms_date := nvl(p_terms_date, AP_IMPORT_INVOICES_PKG.g_inv_sysdate);
  --END IF; -- Commented for bug 9918860

 -- Bug 4115712
 ------------------------------------------------------------------------------
  -- Step 8
  -- For calendar based payment terms :
  -- Check if special calendar exists for the period
  -- in which the terms date falls, else fail insert.
  -----------------------------------------------------------------------------
   debug_info := '(Check Invalid Terms 8) Check calendar based payment terms';

   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
   END IF;

   --Bug:4115712
   IF (l_term_id IS NOT NULL)  THEN
    -- Bug 5448579. Calendar will be verified based on term_id

    --  select name
    --  into l_term_name
    --  from ap_terms
    --  where term_id = l_term_id;

    -- END IF;

     AP_IMPORT_UTILITIES_PKG.Check_For_Calendar_Term(
       P_Terms_Id         =>  l_term_id,
       P_Terms_Date       =>  p_terms_date,
       P_No_Cal           =>  l_no_calendar_exists,
       P_Calling_Sequence =>  'v_check_invalidate_terms');

     IF (l_no_calendar_exists = 'Y') THEN
       IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                     (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                      p_invoice_rec.invoice_id,
                      'NO SPECIAL CALENDAR FOR TERMS',
                      p_default_last_updated_by,
                      p_default_last_update_login,
                      current_calling_sequence) <> TRUE) THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
         END IF;
         RAISE terms_check_failure;
       END IF;
       l_current_invoice_status := 'N';
     END IF;

   END IF;

--End bug 4115712

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_invalid_terms;


----------------------------------------------------------------------------
-- This function is used to validate several elements in the
-- invoice: liability account, payment method, pay group,
-- voucher num and requester.
--
----------------------------------------------------------------------------
FUNCTION v_check_misc_invoice_info (
    p_invoice_rec           IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    --Bug 6509776
    p_set_of_books_id           IN            NUMBER,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER,
    p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2)
RETURN BOOLEAN IS

misc_invoice_info_failure    EXCEPTION;
l_valid_info                 VARCHAR2(1);
l_current_invoice_status     VARCHAR2(1) := 'Y';
current_calling_sequence     VARCHAR2(2000);
debug_info                   VARCHAR2(500);
l_invoice_count              NUMBER;
l_emp_count                  NUMBER;
l_chart_of_accounts_id       NUMBER;
l_catsegs                    VARCHAR2(200);
l_acct_type                  VARCHAR2(1);
-- Bug 5448579
l_valid_pay_group            PO_LOOKUP_CODES.Lookup_Code%TYPE;
-- Bug 6509776
l_ccid                       GL_CODE_COMBINATIONS.Code_Combination_ID%TYPE;

BEGIN
  --
  -- Update the calling sequence
  --
  current_calling_sequence :=
   'AP_IMPORT_VALIDATION_PKG.v_check_misc_invoice_info<-'||P_calling_sequence;

    -- 7531219
    -------------------------------------------------------------------------------
    -- step 0.1
    -- default the liability ccid if no liability account is entered
    -- This is required here as we need to validate the defaulted liability accounts too
    --------------------------------------------------------------------------------
    if p_invoice_rec.accts_pay_code_concatenated is null
       and p_invoice_rec.accts_pay_code_combination_id is null
    then
       debug_info := '(step 10.1 default the liability account';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
       END IF;

      begin
       if (p_invoice_rec.invoice_type_lookup_code = 'PAYMENT REQUEST') then
         SELECT fsp.accts_pay_code_combination_id
           INTO p_invoice_rec.accts_pay_code_combination_id
           FROM ap_system_parameters asp,
                financials_system_parameters fsp
          WHERE asp.org_id = p_invoice_rec.org_id
            AND asp.org_id = fsp.org_id;
       else
         SELECT accts_pay_code_combination_id
           INTO p_invoice_rec.accts_pay_code_combination_id
           FROM ap_supplier_sites_all
          WHERE vendor_id = p_invoice_rec.vendor_id
            AND vendor_site_id = p_invoice_rec.vendor_site_id;
       end if;
      exception
         when others then
            debug_info := '(step 0.1 default the liability account';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            debug_info);
            END IF;
      end;
    end if;

  --
  -- Bug 6509776 - Adds validation for accts_pay_code_concatenated
  --
  IF (p_invoice_rec.accts_pay_code_concatenated is NOT NULL) THEN
    -------------------------------------------------------------------------
    -- Step 1 a
    -- Check for Liab account if entered
    -- Else we would default the liability account from the supplier site
    -- Note: No validation is done for the liab acct from the supplier, we
    -- just transfer the liabilty from the supplier as such. If at later
    -- point need be, the supplier site liab account validation logic
    -- can be included here.
    -------------------------------------------------------------------------
    debug_info :=
      '(Check Misc Invoice Info 1 a) Check for valid accts_pay_concat.';
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
     END IF;

     -- Validate liability account concat
     BEGIN
     IF AP_IMPORT_INVOICES_PKG.g_segment_delimiter <> '-' THEN
        p_invoice_rec.accts_pay_code_concatenated :=
        TRANSLATE(p_invoice_rec.accts_pay_code_concatenated, '-',
                  AP_IMPORT_INVOICES_PKG.g_segment_delimiter);
     END IF;

       --Fetch chart of accounts
       SELECT chart_of_accounts_id
         INTO l_chart_of_accounts_id
         FROM gl_sets_of_books
        WHERE set_of_books_id = p_set_of_books_id;

         IF (fnd_flex_keyval.validate_segs
                      ('CREATE_COMB_NO_AT', --bugfix:3888581
                       'SQLGL',
                       'GL#',
                        l_chart_of_accounts_id,
                        p_invoice_rec.accts_pay_code_concatenated,
                        'V',
                        nvl(p_invoice_rec.gl_date,sysdate),  -- BUG 3000219
                        'ALL',
                        NULL,
                    -- Bug 4102147
                    -- '\nSUMMARY_FLAG\nI\nAPPL=SQLGL;' ||
                    -- 'NAME=GL_CTAX_SUMMARY_ACCOUNT\nN',
                        'GL_GLOBAL\nDETAIL_POSTING_ALLOWED\nI\nAPPL=SQLGL;'||
  'NAME=GL_CTAX_DETAIL_POSTING\nY\0GL_GLOBAL\nSUMMARY_FLAG\nI\nAPPL=SQLGL;'||
                        'NAME=GL_CTAX_SUMMARY_ACCOUNT\nN',
                    -- End bug 4102147
                        NULL,
                        NULL,
                        FALSE,
                        FALSE,
                        NULL,
                        NULL,
                        NULL))  THEN
            l_ccid := fnd_flex_keyval.combination_id;
          ELSE
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             '(v_check_misc_invoice_info 1 a) Invalid accts_pay_concat');
           END IF;

           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                  p_invoice_rec.invoice_id,
                  'INVALID LIABILITY ACCT',
                  p_default_last_updated_by,
                  p_default_last_update_login,
                  current_calling_sequence) <> TRUE) THEN
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<- '||current_calling_sequence);
             END IF;
             RAISE misc_invoice_info_failure;
           END IF;
           l_current_invoice_status := 'N';
         END IF; -- If validate segments is TRUE

       SELECT account_type
         INTO l_acct_type
         FROM gl_code_combinations
        WHERE code_combination_id = l_ccid;

       IF l_acct_type <> 'L' THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,
           '(v_check_misc_invoice_info 1 a) Invalid accts_pay_concat');
         END IF;

         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                 p_invoice_rec.invoice_id,
                 'INVALID LIABILITY ACCT',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections<- '||current_calling_sequence);
           END IF;
           RAISE misc_invoice_info_failure;
         END IF;

         l_current_invoice_status := 'N';

       END IF; -- Account type is other than L

       -- If liab acct ccid is not null, compare both
       -- if not same reject as inconsistent
       IF p_invoice_rec.accts_pay_code_combination_id IS NOT NULL THEN
          IF p_invoice_rec.accts_pay_code_combination_id <> l_ccid THEN
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                 AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                '(v_check_misc_invoice_info 1 a) Inconsistent accts_pay');
             END IF;

             IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                    (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                      p_invoice_rec.invoice_id,
                      'INCONSISTENT LIAB ACCOUNT INFO',
                      p_default_last_updated_by,
                      p_default_last_update_login,
                      current_calling_sequence) <> TRUE) THEN
               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                  AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<- '||current_calling_sequence);
               END IF;
                RAISE misc_invoice_info_failure;
             END IF;
             l_current_invoice_status := 'N';
           END IF;   -- END IF invoice liab ccid not equal to concat ccid
        ELSIF p_invoice_rec.accts_pay_code_combination_id IS NULL THEN
           p_invoice_rec.accts_pay_code_combination_id := l_ccid;
        END IF;


     EXCEPTION
       WHEN NO_DATA_FOUND Then
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,
           '(v_check_misc_invoice_info 1 a) Invalid accts_pay_concat ');
         END IF;

         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID LIABILITY ACCT',
                p_default_last_updated_by,
                p_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections<-'||current_calling_sequence);
           END IF;
          RAISE misc_invoice_info_failure;
         END IF;

         l_current_invoice_status := 'N';

     END; -- valdiate liab acct concat
  END IF;
  -- Bug 6509776

  IF (p_invoice_rec.accts_pay_code_combination_id is NOT NULL) THEN

    -------------------------------------------------------------------------
    -- Step 1
    -- Check for Liab account if entered
    -- Else we would default the liability account from the supplier site
    -- Note: No validation is done for the liab acct from the supplier, we
    -- just transfer the liabilty from the supplier as such. If at later
    -- point need be, the supplier site liab account validation logic
    -- can be included here.
    -------------------------------------------------------------------------
    debug_info :=
      '(Check Misc Invoice Info 1) Check for valid accts_pay_ccid.';
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
     END IF;

     -- Validate liability account information
     BEGIN
       SELECT account_type
         INTO l_acct_type
         FROM gl_code_combinations
        WHERE code_combination_id =
                p_invoice_rec.accts_pay_code_combination_id;

       SELECT chart_of_accounts_id
         INTO l_chart_of_accounts_id
         FROM gl_sets_of_books
        WHERE set_of_books_id = p_set_of_books_id;

       IF l_acct_type <> 'L' THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,
           '(v_check_misc_invoice_info 1) Invalid accts_pay_ccid');
         END IF;

         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                 p_invoice_rec.invoice_id,
                 'INVALID LIABILITY ACCT',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections<- '||current_calling_sequence);
           END IF;
           RAISE misc_invoice_info_failure;
         END IF;

         l_current_invoice_status := 'N';

       END IF; -- Account type is other than L

       IF fnd_flex_keyval.validate_ccid(
            appl_short_name  => 'SQLGL',
            key_flex_code    => 'GL#',
            structure_number => l_chart_of_accounts_id,
            combination_id   => p_invoice_rec.accts_pay_code_combination_id)
         THEN
         l_catsegs := fnd_flex_keyval.concatenated_values;

           --For BUG 3000219. CCID is to be validated with respect to
           --GL_DATE. Changed sysdate to p_invoice_rec.gl_date for validation

         IF (fnd_flex_keyval.validate_segs
                      ('CREATE_COMB_NO_AT', --bugfix:3888581
                       'SQLGL',
                       'GL#',
                        l_chart_of_accounts_id,
                        l_catsegs,
                        'V',
                        nvl(p_invoice_rec.gl_date,sysdate),  -- BUG 3000219
                        'ALL',
                        NULL,
                    -- Bug 4102147
                    -- '\nSUMMARY_FLAG\nI\nAPPL=SQLGL;' ||
                    -- 'NAME=GL_CTAX_SUMMARY_ACCOUNT\nN',
                         'GL_GLOBAL\nDETAIL_POSTING_ALLOWED\nI\nAPPL=SQLGL;'||
  'NAME=GL_CTAX_DETAIL_POSTING\nY\0GL_GLOBAL\nSUMMARY_FLAG\nI\nAPPL=SQLGL;'||
                        'NAME=GL_CTAX_SUMMARY_ACCOUNT\nN',
                    -- End bug 4102147
                        NULL,
                        NULL,
                        FALSE,
                        FALSE,
                        NULL,
                        NULL,
                        NULL)<>TRUE)  THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             '(v_check_misc_invoice_info 1) Invalid accts_pay_ccid');
           END IF;

           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                  p_invoice_rec.invoice_id,
                  'INVALID LIABILITY ACCT',
                  p_default_last_updated_by,
                  p_default_last_update_login,
                  current_calling_sequence) <> TRUE) THEN
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<- '||current_calling_sequence);
             END IF;
             RAISE misc_invoice_info_failure;
           END IF;

           l_current_invoice_status := 'N';

         END IF; -- If validate segments is other than TRUE

       ELSE -- Validate CCID returned false
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,
           '(v_check_misc_invoice_info 1) Invalid accts_pay_ccid');
         END IF;

         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                              (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                               p_invoice_rec.invoice_id,
                               'INVALID LIABILITY ACCT',
                               p_default_last_updated_by,
                               p_default_last_update_login,
                               current_calling_sequence) <> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections<- '||current_calling_sequence);
           END IF;
           RAISE misc_invoice_info_failure;
         END IF;

         l_current_invoice_status := 'N';

       END IF; -- Validate CCID returned TRUE

     EXCEPTION -- Validate liability account information
       WHEN NO_DATA_FOUND Then
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,
           '(v_check_misc_invoice_info 1) Invalid accts_pay_ccid ');
         END IF;

         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID LIABILITY ACCT',
                p_default_last_updated_by,
                p_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections<-'||current_calling_sequence);
           END IF;
          RAISE misc_invoice_info_failure;
         END IF;

         l_current_invoice_status := 'N';

     END; -- Validate liability account information

  END IF; -- liab account is not null


  IF (p_invoice_rec.pay_group_lookup_code is NOT NULL) THEN

    -------------------------------------------------------------------------
    -- Step 3
    -- Check for pay group
    -------------------------------------------------------------------------
    debug_info := '(Check Misc Invoice Info 3) Check for valid pay group';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    -- Bug 5448579
    FOR i IN AP_IMPORT_INVOICES_PKG.g_pay_group_tab.First..AP_IMPORT_INVOICES_PKG.g_pay_group_tab.Last
    LOOP
      IF AP_IMPORT_INVOICES_PKG.g_pay_group_tab(i).pay_group = p_invoice_rec.pay_group_lookup_code THEN
        l_valid_pay_group  := AP_IMPORT_INVOICES_PKG.g_pay_group_tab(i).pay_group;
        EXIT;
      END IF;
    END LOOP;

    debug_info := 'l_valid_pay_group: '||l_valid_pay_group;
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF l_valid_pay_group IS NULL THEN


      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '(v_check_misc_invoice_info 3) Invalid pay group');
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID PAY GROUP',
                p_default_last_updated_by,
                p_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE misc_invoice_info_failure;
      END IF;

      l_current_invoice_status := 'N';

    END IF;

  END IF; -- pay group is not nul
   /*  -- Invalid Info
    BEGIN
      SELECT 'X'
        INTO l_valid_info
        FROM po_lookup_codes
       WHERE lookup_code = p_invoice_rec.pay_group_lookup_code
         AND lookup_type = 'PAY GROUP'
         AND DECODE(SIGN(NVL(inactive_date,
                             AP_IMPORT_INVOICES_PKG.g_inv_sysdate) -
                         AP_IMPORT_INVOICES_PKG.g_inv_sysdate),
                    -1,'','*') = '*';

    EXCEPTION
      WHEN NO_DATA_FOUND Then
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '(v_check_misc_invoice_info 3) Invalid pay group');
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID PAY GROUP',
                p_default_last_updated_by,
                p_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE misc_invoice_info_failure;
        END IF;

        l_current_invoice_status := 'N';
    END; */


  IF (p_invoice_rec.voucher_num IS NOT NULL) THEN

    --------------------------------------------------------------------------
    -- Step 4
    -- Check for duplicate voucher number.
    -- Retropricing: For PPA Invoices voucher num is NULL
    --------------------------------------------------------------------------
    debug_info :=
      '(Check Misc Invoice Info 4) Check for duplicate voucher number';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    SELECT count(*)
      INTO l_invoice_count
      FROM ap_invoices
     WHERE voucher_num = p_invoice_rec.voucher_num;

    IF (l_invoice_count > 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '(v_check_misc_invoice_info 4) Reject: Duplicate Voucher Number');
      END IF;

      -- if data is found, an error exists
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'DUPLICATE VOUCHER',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE misc_invoice_info_failure;
      END IF;

      l_current_invoice_status := 'N';

    END IF; -- invoice count > 0

  END IF; -- voucher number is not null

-- Commented the below validation for Bug 5064959

 /* IF (p_invoice_rec.voucher_num IS NOT NULL) THEN

 --Bug 4158851 has added this step

     ------------------------------------------------------------------------------------
     -- Step 4.1
     -- Check for voucher number length (intended <= 8)
     ------------------------------------------------------------------------------------
     debug_info := '(Check Misc Invoice Info 4.1) Check for voucher number length <= 8';

    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;


     IF (length(p_invoice_rec.voucher_num) > 8) THEN

    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    end if;

         -- if data is found, an error exists

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                       (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                        p_invoice_rec.invoice_id,
                        'INVALID REQUESTER',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
        END IF;
         RAISE misc_invoice_info_failure;
         END IF;

         l_current_invoice_status := 'N';

     END IF;

  END IF; */-- voucher number is not null
  --------------------------------------------------------------------------
  -- Step 5
  -- Check for valid employee
  --------------------------------------------------------------------------
  debug_info := '(Check Misc Invoice Info 5) Check for valid employee';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  /* start Bug10084709 */
  If(Ap_Import_Invoices_Pkg.G_Source <> 'PPA') Then

	IF (p_invoice_rec.requester_id IS NOT NULL) THEN

		SELECT count(*)
		INTO l_emp_count
		FROM hr_employees_current_v
		WHERE employee_id = p_invoice_rec.requester_id;

		IF l_emp_count = 0 THEN

			IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                       (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                        p_invoice_rec.invoice_id,
                        'INVALID REQUESTER',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence) <> TRUE) THEN
				IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
				AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
				'insert_rejections<-'||current_calling_sequence);
				END IF;

				RAISE misc_invoice_info_failure;
			END IF;

			l_current_invoice_status := 'N';

		END IF; -- employee count is 0
	ELSIF
         (P_Invoice_Rec.Requester_last_Name Is Not Null And
          P_Invoice_Rec.Requester_First_Name Is Not Null) Then

		Begin
                  Select Employee_Id
                  INTO p_invoice_rec.requester_id
                  From Hr_Employees_Current_V
                  Where (Last_Name) =(P_Invoice_Rec.requester_Last_Name)
                  And (First_Name) =(P_Invoice_Rec.Requester_First_Name);

		Exception
		When Others Then
                	IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                       	(AP_IMPORT_INVOICES_PKG.g_invoices_table,
                        	p_invoice_rec.invoice_id,
                        	'INVALID REQUESTER',
                        	p_default_last_updated_by,
                        	p_default_last_update_login,
                        	Current_Calling_Sequence) <> True) Then
                   	   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                           AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                           'insert_rejections<-'||Current_Calling_Sequence);
                   	   End If;

			Raise Misc_Invoice_Info_Failure;
                	End If;

			l_Current_Invoice_Status := 'N';
		End;
	END IF; -- requester id is not null
	/* end  Bug10084709 */
  p_current_invoice_status := l_current_invoice_status;
END IF; /* g_source <> PPA */

  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;

    RETURN(FALSE);

END v_check_misc_invoice_info;

----------------------------------------------------------------------------
-- This function is used to validate the Legal Entity information of the
-- invoice that is being imported.
--
----------------------------------------------------------------------------
FUNCTION v_check_Legal_Entity_info (
    p_invoice_rec               IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_set_of_books_id           IN            NUMBER,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER,
    p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN
IS

le_invoice_info_failure         EXCEPTION;
l_valid_info                    VARCHAR2(1);
l_current_invoice_status        VARCHAR2(1) := 'Y';
current_calling_sequence        VARCHAR2(2000);
debug_info                      VARCHAR2(500);

l_ptop_le_info                  XLE_BUSINESSINFO_GRP.ptop_le_rec;
l_le_return_status              varchar2(1);
l_msg_data                      varchar2(1000);
l_bill_to_location_id           NUMBER(15);
l_supp_site_liab_ccid           NUMBER(15);
l_ccid_to_api                   NUMBER(15);
l_valid_le                      VARCHAR2(100);

BEGIN
  --
  -- Update the calling sequence
  --
  current_calling_sequence :=
   'AP_IMPORT_VALIDATION_PKG.v_check_legal_entity_info<-'||P_calling_sequence;

     IF (p_invoice_rec.legal_entity_id IS NOT NULL) THEN
         ----------------------------------------------------------------------
         -- Step 1
         -- LE ID is provided. Validate if it is a valid LE.
         -----------------------------------------------------------------------
         debug_info :=
               '(Check Legal Entity Info 1) Check Valid LE ID';
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
         END IF;

         XLE_UTILITIES_GRP.IsLegalEntity_LEID
                           (l_le_return_status,
                            l_msg_data,
                            p_invoice_rec.legal_entity_id,
                            l_valid_le);

         IF l_le_return_status = FND_API.G_RET_STS_SUCCESS THEN
            IF l_valid_le = FND_API.G_FALSE THEN
              ------------------------------------------------------------------
              -- Step 1.1
              -- Invalid LE ID Case
              --
              ------------------------------------------------------------------
              debug_info :=
                         '(Check Legal Entity Info 1.1) InValid LE ID Flow';
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                 AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            debug_info);
              END IF;
              IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                   (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                     p_invoice_rec.invoice_id,
                     'INVALID LEGAL ENTITY',
                     p_default_last_updated_by,
                     p_default_last_update_login,
                     current_calling_sequence) <> TRUE) THEN
                  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                     AP_IMPORT_UTILITIES_PKG.Print(
                            AP_IMPORT_INVOICES_PKG.g_debug_switch,
                           'insert_rejections<- '||current_calling_sequence);
                  END IF;
                  l_current_invoice_status := 'N';
                  RAISE le_invoice_info_failure;
              END IF;
            END IF;
         END IF;
     END IF;

     IF ((p_invoice_rec.cust_registration_code IS NOT NULL) AND
        (p_invoice_rec.cust_registration_number IS NOT NULL)) OR
         /* Bug 4516037. Added the following condition */
         (p_invoice_rec.legal_entity_id IS NULL) THEN
         -----------------------------------------------------------------------
         -- Step 2
         -- This case the registration code and the number are provided
         -- Call the LE API to validate the registration code and number to
         -- get the right LE information.
         --
         -----------------------------------------------------------------------
         debug_info :=
               '(Check Legal Entity Info 2) Check for reg code/number and Get LE.';
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
         END IF;
         -----------------------------------------------------------------------
         -- Step 2.1
         -- Get Bill TO Location ID from Supplier Site
         --
         -----------------------------------------------------------------------

         -- Bug 5518886 . Added the following condition If
         IF p_invoice_rec.invoice_type_lookup_code <> 'PAYMENT REQUEST' THEN

           debug_info :=
               '(Check Legal Entity Info 2.1) Get Bill TO Location ID';
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
           END IF;


           BEGIN
             SELECT bill_to_location_id,
                    accts_pay_code_combination_id
             INTO   l_bill_to_location_id,
                    l_supp_site_liab_ccid
             FROM   po_vendor_sites
             WHERE  vendor_site_id = p_invoice_rec.vendor_site_id;

             l_ccid_to_api := NVL(p_invoice_rec.accts_pay_code_combination_id,
                                l_supp_site_liab_ccid);
           EXCEPTION
             WHEN OTHERS THEN
               l_bill_to_location_id := NULL;
               l_ccid_to_api := p_invoice_rec.accts_pay_code_combination_id;
           END;

         ELSE

           debug_info :=
               '(Check Legal Entity Info 2.1) For Payment Request Legal Entity will '
               || 'based on interface accts_pay_code_combination_id ';
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
           END IF;

           l_ccid_to_api := p_invoice_rec.accts_pay_code_combination_id;

         END IF;

         ----------------------------------------------------------------------
         -- Step 2.2
         -- Call the LE API
         --
         ----------------------------------------------------------------------
         debug_info :=
               '(Check Legal Entity Info 2.2) Call LE API';
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
         END IF;

         XLE_BUSINESSINFO_GRP.Get_PurchasetoPay_Info
                              (l_le_return_status,
                               l_msg_data,
                               p_invoice_rec.cust_registration_code,
                               p_invoice_rec.cust_registration_number,
                               l_bill_to_location_id,
                               l_ccid_to_api,
                               p_invoice_rec.org_id,
                               l_ptop_le_info);
         IF (l_le_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            --------------------------------------------------------------------
            -- Step 2.3
            -- Valid LE Returned by the API.
            --
            -------------------------------------------------------------------
            debug_info :=
                       '(Check Legal Entity Info 2.3) Valid LE Flow';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            debug_info);
            END IF;
            IF p_invoice_rec.legal_entity_id IS NOT NULL THEN
               IF p_invoice_rec.legal_entity_id <>
                  l_ptop_le_info.legal_entity_id THEN
                  -------------------------------------------------------------
                  -- Step 2.4
                  -- Inconsistent LE Info
                  --
                  -------------------------------------------------------------
                  debug_info :=
                             '(Check Legal Entity Info 2.4) Inconsistent LE Info';
                  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                                 debug_info);
                  END IF;
                  IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                     (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                            p_invoice_rec.invoice_id,
                            'INCONSISTENT LE INFO',
                            p_default_last_updated_by,
                            p_default_last_update_login,
                            current_calling_sequence) <> TRUE) THEN
                     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                         AP_IMPORT_UTILITIES_PKG.Print(
                           AP_IMPORT_INVOICES_PKG.g_debug_switch,
                          'insert_rejections<- '||current_calling_sequence);
                     END IF;
                     l_current_invoice_status := 'N';
                     RAISE le_invoice_info_failure;
                  END IF;
               END IF;
            END IF;
            p_invoice_rec.legal_entity_id := l_ptop_le_info.legal_entity_id;
            /* Bug 4516037. Added the following debug info for printing
               legal entity id */
            debug_info :=
                     '(Check Legal Entity Info 2.4a) Legal Entity ID: '||
                       p_invoice_rec.legal_entity_id;
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                           debug_info);
            END IF;






         ELSE
            -------------------------------------------------------------------
            -- Step 2.5
            -- Invalid LE Case
            --
            -------------------------------------------------------------------
            debug_info :=
                       '(Check Legal Entity Info 2.5) InValid LE Flow';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            debug_info);
            END IF;
            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                 (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                   p_invoice_rec.invoice_id,
                   'INVALID LEGAL ENTITY',
                   p_default_last_updated_by,
                   p_default_last_update_login,
                   current_calling_sequence) <> TRUE) THEN
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                   AP_IMPORT_UTILITIES_PKG.Print(
                          AP_IMPORT_INVOICES_PKG.g_debug_switch,
                         'insert_rejections<- '||current_calling_sequence);
                END IF;
                l_current_invoice_status := 'N';
                RAISE le_invoice_info_failure;
            END IF;
         END IF;
     END IF;

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);
EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);
END v_check_Legal_Entity_info;

------------------------------------------------------------------------------
-- This function is used to validate payment currency.
--
------------------------------------------------------------------------------
FUNCTION v_check_invalid_pay_curr (
         p_invoice_rec            IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_pay_currency_code            OUT NOCOPY VARCHAR2,
         p_payment_cross_rate_date      OUT NOCOPY DATE,
         p_payment_cross_rate           OUT NOCOPY NUMBER,
         p_payment_cross_rate_type      OUT NOCOPY VARCHAR2,
         p_default_last_updated_by   IN            NUMBER,
         p_default_last_update_login IN            NUMBER,
         p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
         p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN
IS

invalid_pay_curr_code_failure    EXCEPTION;
l_current_invoice_status         VARCHAR2(1) := 'Y';
l_start_date_active              DATE;
l_end_date_active                DATE;
l_payment_cross_rate             AP_INVOICES_INTERFACE.payment_cross_rate%TYPE;
l_warning                        VARCHAR2(240);
current_calling_sequence         VARCHAR2(2000);
debug_info                       VARCHAR2(500);

l_fnd_currency_table             AP_IMPORT_INVOICES_PKG.Fnd_Currency_Tab_Type;
l_valid_pay_currency             FND_CURRENCIES.Currency_Code%TYPE;

BEGIN
  --
  -- Update the calling sequence
  --
  current_calling_sequence :=
   'AP_IMPORT_VALIDATION_PKG.v_check_invalid_pay_curr<-'||P_calling_sequence;

  -- Bug 5448579
  debug_info := '(Check Invalid Pay Currency 0)  Calling Caching Function for Currency';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;
  IF (AP_IMPORT_UTILITIES_PKG.Cache_Fnd_Currency (
           P_Fnd_Currency_Table   => l_fnd_currency_table,
           P_Calling_Sequence     => current_calling_sequence ) <> TRUE) THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'Cache_Fnd_Currency <-'||current_calling_sequence);
    END IF;
    Raise invalid_pay_curr_code_failure;
  END IF;

  IF (p_invoice_rec.payment_currency_code IS NOT NULL) THEN
    -------------------------------------------------------------------------
    -- Step 1
    -- Check if the payment currency is inactive. If no data found then
    -- payment currency is invalid and will be handled in EXCEPTION clause
    -------------------------------------------------------------------------

    /*SELECT start_date_active, end_date_active
      INTO l_start_date_active, l_end_date_active
      FROM fnd_currencies
     WHERE currency_code = p_invoice_rec.payment_currency_code; */

     -- Bug 5448579
    FOR i IN l_fnd_currency_table.First..l_fnd_currency_table.Last LOOP
      IF l_fnd_currency_table(i).currency_code = p_invoice_rec.payment_currency_code THEN
        l_valid_pay_currency  := l_fnd_currency_table(i).currency_code;
        l_start_date_active   := l_fnd_currency_table(i).start_date_active;
        l_end_date_active     := l_fnd_currency_table(i).end_date_active;
        EXIT;
      END IF;
    END LOOP;

    debug_info := 'l_valid_pay_currency: '||l_valid_pay_currency;
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF l_valid_pay_currency IS NOT NULL THEN
      IF ((trunc(AP_IMPORT_INVOICES_PKG.g_inv_sysdate) <
        nvl(l_start_date_active,
            trunc(AP_IMPORT_INVOICES_PKG.g_inv_sysdate))) OR
        (AP_IMPORT_INVOICES_PKG.g_inv_sysdate >=
         nvl(l_end_date_active, AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1))) THEN

        debug_info := '(Check Payment Currency Code 1) Check for Inactive '
                    ||'Payment Currency Code.';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INACTIVE PAY CURR CODE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE invalid_pay_curr_code_failure;
        END IF;

        l_current_invoice_status := 'N';
      END IF; -- Test of inactive payment currency code
    ELSE
      debug_info := '(Check Payment Currency Code 1.1) Check for Inactive '
                    ||'Payment Currency Code.';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INACTIVE PAY CURR CODE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections <-'||current_calling_sequence);
         END IF;
         RAISE invalid_pay_curr_code_failure;
       END IF;

    END IF;
    --------------------------------------------------------------------------
    -- Step 2
    -- Check if the payment cross rate date is null. If yes, assign the
    -- invoice_date to it.
    --------------------------------------------------------------------------
    IF (p_invoice_rec.payment_cross_rate_date IS NULL) THEN
      p_payment_cross_rate_date := p_invoice_rec.invoice_date;
    ELSE
      p_payment_cross_rate_date := p_invoice_rec.payment_cross_rate_date;
    END IF;

    --------------------------------------------------------------------------
    -- Step 3
    -- Check if the invoice and payment currency have fixed rate relationship.
    --------------------------------------------------------------------------
    IF ( p_invoice_rec.payment_currency_code <>
             p_invoice_rec.invoice_currency_code) THEN

      IF ( gl_currency_api.is_fixed_rate(
               p_invoice_rec.invoice_currency_code,
               p_invoice_rec.payment_currency_code,
               p_payment_cross_rate_date) <> 'Y' ) THEN

        debug_info := '(Check Payment Currency Code 3.1) Check for fixed '
                      ||'payment cross rate.';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoices_table,
                 p_invoice_rec.invoice_id,
                 'PAY X RATE NOT FIXED',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE invalid_pay_curr_code_failure;
        END IF;

        l_current_invoice_status := 'N';
      ELSE
        p_payment_cross_rate_type := 'EMU FIXED';
        l_payment_cross_rate := ap_utilities_pkg.get_exchange_rate(
                                    p_invoice_rec.invoice_currency_code,
                                    p_invoice_rec.payment_currency_code,
                                    p_payment_cross_rate_type,
                                    p_payment_cross_rate_date,
                                    current_calling_sequence);
        debug_info := '(Check Payment Currency Code 3.2) Check for fixed '
                      ||' and get payment cross rate.';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF ( (l_payment_cross_rate <> p_invoice_rec.payment_cross_rate) AND
             (p_invoice_rec.payment_cross_rate IS NOT NULL)) THEN
          BEGIN
            SELECT  description
              INTO  l_warning
              FROM  ap_lookup_codes
             WHERE  lookup_type = 'REJECT CODE'
               AND  lookup_code = 'PAY RATE OVERWRITTEN';
             debug_info := '(Check Payment Currency Code 3.3) Check for fixed '
                          || l_warning;
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
             END IF;
          EXCEPTION WHEN no_data_found THEN
            NULL;
          END;
        END IF;
        p_payment_cross_rate := l_payment_cross_rate;
      END IF; -- end of gl_is_fix rate api call
    ELSE

      -- pay_curr_code = inv_curr_code case
      debug_info := '(Check Payment Currency Code 3.3) Check for fixed '
                      ||' pay_currency_code = inv_currency_code';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              debug_info);
      END IF;

      p_pay_currency_code := p_invoice_rec.invoice_currency_code;
      IF (p_invoice_rec.payment_cross_rate_date IS NULL) THEN
        p_payment_cross_rate_date := p_invoice_rec.invoice_date;
      END IF;

      p_payment_cross_rate := 1;
      p_payment_cross_rate_type := NULL;

    END IF; -- Payment currency code is other than invoice currency code

  ELSIF (p_invoice_rec.payment_currency_code is NULL ) THEN

    p_pay_currency_code := p_invoice_rec.invoice_currency_code;
    IF (p_invoice_rec.payment_cross_rate_date IS NULL) THEN
      p_payment_cross_rate_date := p_invoice_rec.invoice_date;
    END IF;

    p_payment_cross_rate := 1;
    p_payment_cross_rate_type := NULL;

  END IF; -- endif for payment currency code not null

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION
  WHEN no_data_found THEN

    -------------------------------------------------------------------------
    -- Step 4
    -- Check for Invalid Payment Currency Code.
    -------------------------------------------------------------------------
    debug_info := '(Check Invoice Currency Code 4) Check for Invalid Invoice'
                  ||' Currency Code.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
            p_invoice_rec.invoice_id,
            'INVALID PAY CURR CODE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE invalid_pay_curr_code_failure;
    END IF;

    l_current_invoice_status := 'N';
    p_current_invoice_status := l_current_invoice_status;
    RETURN (TRUE);

  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_invalid_pay_curr;

-----------------------------------------------------------------------------
-- This function is used to validate prepayment information for
-- application.
-----------------------------------------------------------------------------

FUNCTION v_check_prepay_info(
          p_invoice_rec               IN OUT NOCOPY
                                      AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
          p_base_currency_code        IN            VARCHAR2,
          p_prepay_period_name        IN OUT NOCOPY VARCHAR2,
	  p_prepay_invoice_id	      OUT NOCOPY    NUMBER,
	  p_prepay_case_name	      OUT NOCOPY    VARCHAR2,
          p_request_id                IN            NUMBER,
          p_default_last_updated_by   IN            NUMBER,
          p_default_last_update_login IN            NUMBER,
          p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
          p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN
IS

l_current_invoice_status        VARCHAR2(1);
l_reject_code                   VARCHAR2(30);
current_calling_sequence        VARCHAR2(2000);
debug_info                      VARCHAR2(500);
check_prepay_failure            EXCEPTION;
l_count_lines_matched	        NUMBER;

BEGIN
  --
  --bug 9326733
  l_current_invoice_status := p_current_invoice_status;

  current_calling_sequence :=  'AP_IMPORT_VALIDATION_PKG.v_check_prepay_info<-'
                                ||P_calling_sequence;

  l_count_lines_matched  := 0;

  --Contract Payments: Added the below IF condition so that we reject the invoices
  --which are of type 'PREPAYMENT' and have provided the prepayment application
  --information too.

  IF (((p_invoice_rec.prepay_num          IS NOT NULL) OR
       (p_invoice_rec.prepay_line_num     IS NOT NULL) OR
       (p_invoice_rec.prepay_apply_amount IS NOT NULL) OR
       (p_invoice_rec.prepay_gl_date      IS NOT NULL) OR
       (p_invoice_rec.invoice_includes_prepay_flag IS NOT NULL)) AND
      p_invoice_rec.invoice_type_lookup_code = 'PREPAYMENT')THEN

       debug_info := '(Check Prepayment Info 1) Check if it is a Prepayment Invoice';

       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
		                                    debug_info);
       END IF;

       IF (AP_IMPORT_UTILITIES_PKG.insert_rejections (
                 AP_IMPORT_INVOICES_PKG.g_invoices_table,
		 p_invoice_rec.invoice_id,
		 'INCONSISTENT PREPAY APPL INFO',
		 p_default_last_updated_by,
		 p_default_last_update_login,
		 current_calling_sequence) <> TRUE) THEN
	   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
			           'insert_rejections<-'||current_calling_sequence);
	   END IF;
	   RAISE check_prepay_failure;
       END IF;

       l_current_invoice_status := 'N';

  END IF;

  --Contract Payments: If the prepayment invoice is matched to financing pay items,
  --reject the invoice, as manual recoupment is not allowed.
  IF ((p_invoice_rec.prepay_num IS NOT NULL) AND
      (p_invoice_rec.invoice_type_lookup_code <> 'PREPAYMENT')) THEN

     debug_info := '(Check Prepayment Info 2) Check if it is a Prepayment Invoice matched'||
     				' to a complex works po';

    -- debug_info := 'p_invoice_rec.prepay_num , p_invoice_rec.org_id '|| p_invoice_rec.prepay_num||','||p_invoice_rec.org_id;

     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                               debug_info);
     END IF;


     BEGIN

        SELECT count(*)
        INTO l_count_lines_matched
        FROM ap_invoice_lines ail,
          ap_invoices ai,
          po_line_locations pll
        WHERE ai.invoice_num = p_invoice_rec.prepay_num
        AND ai.org_id = p_invoice_rec.org_id
        AND ail.invoice_id = ai.invoice_id
        AND ail.po_line_location_id = pll.line_location_id
        AND pll.shipment_type = 'PREPAYMENT';

     EXCEPTION WHEN OTHERS THEN
       debug_info := '(Check Prepayment Info 2.1) In others exception and the error is '||sqlerrm;
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
	                                            debug_info);
       END IF;


     END ;


     IF (l_count_lines_matched > 0) THEN

	debug_info := 'Reject as Cannot manually recoup ';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
		                                    debug_info);
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections (
                 AP_IMPORT_INVOICES_PKG.g_invoices_table,
		 p_invoice_rec.invoice_id,
		 'CANNOT MANUALLY RECOUP',
		 p_default_last_updated_by,
		 p_default_last_update_login,
		 current_calling_sequence) <> TRUE) THEN
	    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
			           'insert_rejections<-'||current_calling_sequence);
	    END IF;
 	    RAISE check_prepay_failure;
        END IF;

        l_current_invoice_status := 'N';

     END IF;

  END IF;


  IF (p_invoice_rec.invoice_type_lookup_code <> 'PREPAYMENT') THEN

     IF NOT ((p_invoice_rec.prepay_num          IS NULL) AND
             (p_invoice_rec.prepay_line_num     IS NULL) AND
             (p_invoice_rec.prepay_apply_amount IS NULL)
	    ) THEN
       --------------------------------------------------------------------------
       -- Step 1
       -- Check Prepayment Info.
       --------------------------------------------------------------------------

       debug_info := '(Check Prepayment Info 1) Call Check Prepayment Function.';

       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
       END IF;
       --
       l_reject_code := AP_PREPAY_PKG.check_prepay_info_import(
      			    	p_invoice_rec.prepay_num,
          			p_invoice_rec.prepay_line_num,
          			p_invoice_rec.prepay_apply_amount,
          			p_invoice_rec.invoice_amount,
          			p_invoice_rec.prepay_gl_date,
          			p_prepay_period_name,
          			p_invoice_rec.vendor_id,
          			p_invoice_rec.invoice_includes_prepay_flag,
          			p_invoice_rec.invoice_id,
          			p_invoice_rec.source,
          			p_invoice_rec.apply_advances_flag,
          			p_invoice_rec.invoice_date,
          			p_base_currency_code,
          			p_invoice_rec.invoice_currency_code,
          			p_invoice_rec.payment_currency_code,
          			current_calling_sequence,
          			p_request_id,
          			p_prepay_case_name,
          			p_prepay_invoice_id,
				p_invoice_rec.invoice_type_lookup_code);  -- Bug 7004765;
    	--
    	-- show input/output values (only if debug_switch = 'Y')

    	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          	'------------------> prepay_num = '|| p_invoice_rec.prepay_num
        	||' prepay_line_num  = '||to_char(p_invoice_rec.prepay_line_num)
        	||' prepay_apply_amount = '||to_char(p_invoice_rec.prepay_apply_amount)
        	||' invoice_amount  = '||to_char(p_invoice_rec.invoice_amount)
        	||' prepay_gl_date  = '||to_char(p_invoice_rec.prepay_gl_date)
        	||' prepay_period_name  = '|| NULL
        	||' vendor_id    = '||to_char(p_invoice_rec.vendor_id)
        	||' base_currency_code = '||p_base_currency_code
        	||' invoice_currency_code  = '||p_invoice_rec.invoice_currency_code
        	||' payment_currency_code  = '||p_invoice_rec.payment_currency_code);
    	END IF;

    	IF (l_reject_code IS NOT NULL) THEN

      	   IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                  AP_IMPORT_INVOICES_PKG.g_invoices_table,
          	  p_invoice_rec.invoice_id,
                  l_reject_code,
                  p_default_last_updated_by,
                  p_default_last_update_login,
                  current_calling_sequence) <> TRUE) THEN
               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          	  AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          	  'insert_rejections<-' ||current_calling_sequence);
               END IF;
               RAISE check_prepay_failure;
           END IF;

           l_current_invoice_status := 'N';

        END IF;  -- reject code is not null

     END IF; -- If not prepayment information is available

  END IF; --p_invoice_rec.invoice_type_lookup_code <> 'PREPAYMENT'

  p_current_invoice_status := l_current_invoice_status;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_prepay_info;


-----------------------------------------------------------------------------
-- This function is used to validate information provided to
-- calculate rate based on base amount.
--
-----------------------------------------------------------------------------
FUNCTION v_check_no_xrate_base_amount (
         p_invoice_rec               IN
             AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_base_currency_code        IN            VARCHAR2,
         p_multi_currency_flag       IN            VARCHAR2,
         p_calc_user_xrate           IN            VARCHAR2,
         p_default_last_updated_by   IN            NUMBER,
         p_default_last_update_login IN            NUMBER,
     p_invoice_base_amount          OUT NOCOPY NUMBER,
         p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
         p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN
IS

no_xrate_base_amount_failure    EXCEPTION;
l_current_invoice_status    VARCHAR2(1) := 'Y';
current_calling_sequence      VARCHAR2(2000);
debug_info           VARCHAR2(500);

--bug 9326733 starts
l_make_rate_mand_flag	AP_SYSTEM_PARAMETERS_ALL.MAKE_RATE_MANDATORY_FLAG%TYPE;

CURSOR c_get_rate_mand_flag(l_org_id IN NUMBER) IS
   select nvl(make_rate_mandatory_flag, 'N')
   from ap_system_parameters_all
   where org_id = l_org_id
   and multi_currency_flag = 'Y';
--bug 9326733 ends

BEGIN

  -- Update the calling sequence
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_no_xrate_base_amount<-'
     ||P_calling_sequence;

  -------------------------------------------------------------------------
  -- Step 1 - Check for invalid no_xrate_base_amount
  -------------------------------------------------------------------------
  debug_info := '(Check No Xrate Base Amount 1) Is Xrate_Base_Amount invalid?';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   debug_info);
  END IF;

  IF (nvl(p_multi_currency_flag,'N') = 'Y') AND
         (p_base_currency_code <> p_invoice_rec.invoice_currency_code) THEN

    IF ((p_calc_user_xrate <> 'Y') AND
        (p_invoice_rec.no_xrate_base_amount IS NOT NULL)) THEN
      debug_info := 'Trying to reject due to no_x_Curr';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                      debug_info);
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
            (AP_IMPORT_INVOICES_PKG.g_invoices_table,
              p_invoice_rec.invoice_id,
              'BASE AMOUNT NOT ALLOWED',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE no_xrate_base_amount_failure;
      END IF;

      l_current_invoice_status := 'N';

    ELSIF (p_calc_user_xrate = 'Y') AND
          ((p_invoice_rec.exchange_rate_type <> 'User') AND
           (p_invoice_rec.no_xrate_base_amount IS NOT NULL)) THEN

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
            (AP_IMPORT_INVOICES_PKG.g_invoices_table,
              p_invoice_rec.invoice_id,
              'INVALID EXCH RATE TYPE',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE no_xrate_base_amount_failure;
      END IF;

      l_current_invoice_status := 'N';

    ELSIF (p_calc_user_xrate = 'Y') AND
          ((p_invoice_rec.exchange_rate_type = 'User') AND
           (p_invoice_rec.no_xrate_base_amount IS NOT NULL) AND
           (p_invoice_rec.invoice_amount IS NOT NULL) AND
           (p_invoice_rec.exchange_rate is NOT NULL)) THEN

      IF (ap_utilities_pkg.ap_round_currency(
           (p_invoice_rec.invoice_amount*p_invoice_rec.exchange_rate),
           p_base_currency_code) <> p_invoice_rec.no_xrate_base_amount)
        THEN

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
            (AP_IMPORT_INVOICES_PKG.g_invoices_table,
              p_invoice_rec.invoice_id,
             'INCONSISTENT XRATE INFO',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE no_xrate_base_amount_failure;
        END IF;

        l_current_invoice_status := 'N';
      END IF;

    ELSIF (p_calc_user_xrate = 'Y') AND
          ((p_invoice_rec.exchange_rate_type = 'User') AND
           (p_invoice_rec.no_xrate_base_amount IS NULL) AND
           (p_invoice_rec.exchange_rate is NULL)) THEN

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                       (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                        p_invoice_rec.invoice_id,
                        'NO EXCHANGE RATE',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE no_xrate_base_amount_failure;
      END IF;

      l_current_invoice_status := 'N';

    END IF; -- Calculate user xrate is not Y and xrate base amount provided
  END IF; -- Multi currency flag is Y and this is a foreign currency invoice

  -------------------------------------------------------------------------
  -- Step 2 - Obtain base amount if no_xrate_base_amount null,
  --          invoice valid and it is a foreign currency invoice.
  -------------------------------------------------------------------------
  IF (l_current_invoice_status <> 'N' AND
      p_invoice_rec.no_xrate_base_amount IS NULL AND
      p_base_currency_code <> p_invoice_rec.invoice_currency_code) THEN

    debug_info := '(Check No Xrate Base Amount 2) Get invoice base amount';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   debug_info);
    END IF;

    -- bug 9326733 starts
    OPEN c_get_rate_mand_flag(p_invoice_rec.org_id);
    FETCH c_get_rate_mand_flag into l_make_rate_mand_flag;
    CLOSE c_get_rate_mand_flag;
    -- bug 9326733 ends

    IF (p_invoice_rec.exchange_rate_type <> 'User' AND
    AP_UTILITIES_PKG.calculate_user_xrate (
                  p_invoice_rec.invoice_currency_code,
                  p_base_currency_code,
                  p_invoice_rec.exchange_date,
                  p_invoice_rec.exchange_rate_type) = 'N') THEN
	--Bug8739726
	BEGIN
           p_invoice_base_amount := gl_currency_api.convert_amount(
                        p_invoice_rec.invoice_currency_code,
                                        p_base_currency_code,
                                        p_invoice_rec.exchange_date,
                          p_invoice_rec.exchange_rate_type,
                    p_invoice_rec.invoice_amount);
	EXCEPTION
		  WHEN OTHERS THEN
		--bug 9326733. Added if clause to avoid rejection records, in case of
		-- rate is not mandatory.
		IF (l_make_rate_mand_flag = 'Y') THEN
			IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
							   (AP_IMPORT_INVOICES_PKG.g_invoices_table,
								p_invoice_rec.invoice_id,
								'NO EXCHANGE RATE',
								p_default_last_updated_by,
								p_default_last_update_login,
								current_calling_sequence) <> TRUE) THEN
				IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
				  AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
				  'insert_rejections<-'||current_calling_sequence);
				END IF;
				RAISE no_xrate_base_amount_failure;
			  END IF;

			  l_current_invoice_status := 'N';
		ELSE
			l_current_invoice_status := 'Y';
		END IF;

	END;
	--End of Bug8739726
    ELSE
      p_invoice_base_amount := ap_utilities_pkg.ap_round_currency(
                       (p_invoice_rec.invoice_amount *
                        p_invoice_rec.exchange_rate),
                        p_base_currency_code);
    END IF;
  END IF;

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;

    RETURN(FALSE);

END v_check_no_xrate_base_amount;


FUNCTION v_check_lines_validation (
	 -- bug 8495005 : Change IN to IN OUT NOCOPY for p_invoice_rec parameter
         p_invoice_rec        IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_invoice_lines_tab  IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.t_lines_table,
         p_gl_date_from_get_info        IN            DATE,
         p_gl_date_from_receipt_flag    IN            VARCHAR2,
         p_positive_price_tolerance     IN            NUMBER,
         p_pa_installed                 IN            VARCHAR2,
         p_qty_ord_tolerance            IN            NUMBER,
	 p_amt_ord_tolerance            IN            NUMBER,
         p_max_qty_ord_tolerance        IN            NUMBER,
	 p_max_amt_ord_tolerance	IN	      NUMBER,
         p_min_acct_unit_inv_curr       IN            NUMBER,
         p_precision_inv_curr           IN            NUMBER,
         p_base_currency_code           IN            VARCHAR2,
         p_base_min_acct_unit           IN            NUMBER,
         p_base_precision               IN            NUMBER,
         p_set_of_books_id              IN            NUMBER,
         p_asset_book_type              IN            VARCHAR2,  -- Bug 5448579
         p_chart_of_accounts_id         IN            NUMBER,
         p_freight_code_combination_id  IN            NUMBER,
         p_purch_encumbrance_flag       IN            VARCHAR2,
	 p_retainage_ccid		IN	      NUMBER,
         p_default_last_updated_by      IN            NUMBER,
         p_default_last_update_login    IN            NUMBER,
         p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
         p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN



IS

/* For Bug - 2823140. Added trim to trailing spaces wherever necessary */
/* For Bug - 6349739 Added NVL to tax classification code
 * Added handling for retek generated concatenated accts */

CURSOR    invoice_lines IS
SELECT    rowid, -- BUG 1714845
          invoice_line_id,
          line_type_lookup_code,
          line_number,
          line_group_number,
          amount,
          NULL, -- base amount
          accounting_date,
          NULL, --period name
          deferred_acctg_flag,
          def_acctg_start_date,
          def_acctg_end_date,
          def_acctg_number_of_periods,
          def_acctg_period_type,
          trim(description),
          prorate_across_flag,
          NULL, -- match_type
          po_header_id,
          po_number,
          po_line_id,
          po_line_number,
          po_release_id,
          release_num,
          po_line_location_id,
          po_shipment_num,
          po_distribution_id,
          po_distribution_num,
          unit_of_meas_lookup_code,
          inventory_item_id,
          item_description,
          quantity_invoiced,
          ship_to_location_code,
          unit_price,
          final_match_flag,
          distribution_set_id,
          distribution_set_name,
          NULL, -- partial segments
          -- bug 6349739
          DECODE(AP_IMPORT_INVOICES_PKG.g_source,
          'RETEK',
          TRANSLATE(RTRIM(dist_code_concatenated,'-'),
                    '-',
                    AP_IMPORT_INVOICES_PKG.g_segment_delimiter),
          dist_code_concatenated), -- 6349739
          dist_code_combination_id,
          awt_group_id,
          awt_group_name,
          pay_awt_group_id,--bug6639866
          pay_awt_group_name,--bug6639866
          balancing_segment,
          cost_center_segment,
          account_segment,
          trim(attribute_category),
          trim(attribute1),
          trim(attribute2),
          trim(attribute3),
          trim(attribute4),
          trim(attribute5),
          trim(attribute6),
          trim(attribute7),
          trim(attribute8),
          trim(attribute9),
          trim(attribute10),
          trim(attribute11),
          trim(attribute12),
          trim(attribute13),
          trim(attribute14),
          trim(attribute15),
          trim(global_attribute_category),
          trim(global_attribute1),
          trim(global_attribute2),
          trim(global_attribute3),
          trim(global_attribute4),
          trim(global_attribute5),
          trim(global_attribute6),
          trim(global_attribute7),
          trim(global_attribute8),
          trim(global_attribute9),
          trim(global_attribute10),
          trim(global_attribute11),
          trim(global_attribute12),
          trim(global_attribute13),
          trim(global_attribute14),
          trim(global_attribute15),
          trim(global_attribute16),
          trim(global_attribute17),
          trim(global_attribute18),
          trim(global_attribute19),
          trim(global_attribute20),
          project_id,
          task_id,
          award_id,
          expenditure_type,
          expenditure_item_date,
          expenditure_organization_id,
          pa_addition_flag,
          pa_quantity,
          stat_amount,
          type_1099,
          income_tax_region,
          assets_tracking_flag,
          asset_book_type_code,
          asset_category_id,
          serial_number,
          manufacturer,
          model_number,
          warranty_number,
          price_correction_flag,
          price_correct_inv_num,
          NULL, -- corrected_inv_id.
                -- This will populated based on the price_correct_inv_num
          price_correct_inv_line_num,
          receipt_number,
          receipt_line_number,
          rcv_transaction_id,
	  NULL,               -- bug 7344899
          match_option,
          packing_slip,
          vendor_item_num,
          taxable_flag,
          pa_cc_ar_invoice_id,
          pa_cc_ar_invoice_line_num,
          pa_cc_processed_code,
          reference_1,
          reference_2,
          credit_card_trx_id,
          requester_id,
          org_id,
          NULL, -- program_application_id
          NULL, -- program_id
          NULL, -- request_id
          NULL,  -- program_update_date
          control_amount,
          assessable_value,
          default_dist_ccid,
          primary_intended_use,
          ship_to_location_id,
          product_type,
          product_category,
          product_fisc_classification,
          user_defined_fisc_class,
          trx_business_category,
          tax_regime_code,
          tax,
          tax_jurisdiction_code,
          tax_status_code,
          tax_rate_id,
          tax_rate_code,
          tax_rate,
          incl_in_taxable_line_flag,
	  application_id,
	  product_table,
	  reference_key1,
	  reference_key2,
	  reference_key3,
	  reference_key4,
	  reference_key5,
	  purchasing_category_id,
	  purchasing_category,
	  cost_factor_id,
	  cost_factor_name,
	  source_application_id,
	  source_entity_code,
	  source_event_class_code,
	  source_trx_id,
	  source_line_id,
	  source_trx_level_type,
	  nvl(tax_classification_code, tax_code), --bug 6349739
	  NULL, -- retained_amount
	  amount_includes_tax_flag,
	  --Bug6167068 starts Added the following columns to get related data for Expense reports
	  cc_reversal_flag,
	  company_prepaid_invoice_id,
	  expense_group,
	  justification,
	  merchant_document_number,
	  merchant_name,
	  merchant_reference,
	  merchant_taxpayer_id,
	  merchant_tax_reg_number,
	  receipt_conversion_rate,
	  receipt_currency_amount,
	  receipt_currency_code,
	  country_of_supply
	  --Bug6167068 ends
	  --bug 8658097 starts
	  ,expense_start_date
	  ,expense_end_date
	  --bug 8658097 ends
	  /* Added for bug 10226070 */
	  ,Requester_last_name
      	  ,Requester_first_name
     FROM ap_invoice_lines_interface
    WHERE invoice_id = p_invoice_rec.invoice_id
 ORDER BY invoice_line_id;
--   FOR UPDATE OF invoice_line_id; -- Bug 1714845

/* Bug 6369356:
 * For Retek invoices having multiple tax lines with same tax code,
 * we need to summarize the tax amounts on tax classification code.*/

CURSOR    invoice_lines_tax_summarized IS
SELECT    rowid, -- BUG 1714845
          invoice_line_id,
          line_type_lookup_code,
          line_number,
          line_group_number,
          --amount,
          -- Bug 6369356 summarize tax lines
          DECODE(line_type_lookup_code , 'TAX',
                 (SELECT SUM(ail3.amount)
                  FROM   ap_invoice_lines_interface ail3
                  WHERE  ail3.tax_code = ail.tax_code
                  AND    ail3.line_type_lookup_code = 'TAX'
                  AND    ail3.invoice_id = ail.invoice_id
                  GROUP BY tax_code),
                  amount) amount,
          -- Bug 6369356
          NULL, -- base amount
          accounting_date,
          NULL, --period name
          deferred_acctg_flag,
          def_acctg_start_date,
          def_acctg_end_date,
          def_acctg_number_of_periods,
          def_acctg_period_type,
          trim(description),
          prorate_across_flag,
          NULL, -- match_type
          po_header_id,
          po_number,
          po_line_id,
          po_line_number,
          po_release_id,
          release_num,
          po_line_location_id,
          po_shipment_num,
          po_distribution_id,
          po_distribution_num,
          unit_of_meas_lookup_code,
          inventory_item_id,
          item_description,
          quantity_invoiced,
          ship_to_location_code,
          unit_price,
          final_match_flag,
          distribution_set_id,
          distribution_set_name,
          NULL, -- partial segments
          -- bug 6349739
          DECODE(AP_IMPORT_INVOICES_PKG.g_source,
          'RETEK',
          TRANSLATE(RTRIM(dist_code_concatenated,'-'),
                    '-',
                    AP_IMPORT_INVOICES_PKG.g_segment_delimiter),
          dist_code_concatenated), -- 6349739
          dist_code_combination_id,
          awt_group_id,
          awt_group_name,
          pay_awt_group_id,--bug6639866
          pay_awt_group_name,--bug6639866
          balancing_segment,
          cost_center_segment,
          account_segment,
          trim(attribute_category),
          trim(attribute1),
          trim(attribute2),
          trim(attribute3),
          trim(attribute4),
          trim(attribute5),
          trim(attribute6),
          trim(attribute7),
          trim(attribute8),
          trim(attribute9),
          trim(attribute10),
          trim(attribute11),
          trim(attribute12),
          trim(attribute13),
          trim(attribute14),
          trim(attribute15),
          trim(global_attribute_category),
          trim(global_attribute1),
          trim(global_attribute2),
          trim(global_attribute3),
          trim(global_attribute4),
          trim(global_attribute5),
          trim(global_attribute6),
          trim(global_attribute7),
          trim(global_attribute8),
          trim(global_attribute9),
          trim(global_attribute10),
          trim(global_attribute11),
          trim(global_attribute12),
          trim(global_attribute13),
          trim(global_attribute14),
          trim(global_attribute15),
          trim(global_attribute16),
          trim(global_attribute17),
          trim(global_attribute18),
          trim(global_attribute19),
          trim(global_attribute20),
          project_id,
          task_id,
          award_id,
          expenditure_type,
          expenditure_item_date,
          expenditure_organization_id,
          pa_addition_flag,
          pa_quantity,
          stat_amount,
          type_1099,
          income_tax_region,
          assets_tracking_flag,
          asset_book_type_code,
          asset_category_id,
          serial_number,
          manufacturer,
          model_number,
          warranty_number,
          price_correction_flag,
          price_correct_inv_num,
          NULL, -- corrected_inv_id.
                -- This will populated based on the price_correct_inv_num
          price_correct_inv_line_num,
          receipt_number,
          receipt_line_number,
          rcv_transaction_id,
	  NULL,               -- bug 7344899
          match_option,
          packing_slip,
          vendor_item_num,
          taxable_flag,
          pa_cc_ar_invoice_id,
          pa_cc_ar_invoice_line_num,
          pa_cc_processed_code,
          reference_1,
          reference_2,
          credit_card_trx_id,
          requester_id,
          org_id,
          NULL, -- program_application_id
          NULL, -- program_id
          NULL, -- request_id
          NULL,  -- program_update_date
          control_amount,
          assessable_value,
          default_dist_ccid,
          primary_intended_use,
          ship_to_location_id,
          product_type,
          product_category,
          product_fisc_classification,
          user_defined_fisc_class,
          trx_business_category,
          tax_regime_code,
          tax,
          tax_jurisdiction_code,
          tax_status_code,
          tax_rate_id,
          tax_rate_code,
          tax_rate,
          incl_in_taxable_line_flag,
          application_id,
          product_table,
          reference_key1,
          reference_key2,
          reference_key3,
          reference_key4,
          reference_key5,
          purchasing_category_id,
          purchasing_category,
          cost_factor_id,
          cost_factor_name,
          source_application_id,
          source_entity_code,
          source_event_class_code,
          source_trx_id,
          source_line_id,
          source_trx_level_type,
          NVL(tax_classification_code, tax_code), --bug 6349739
          NULL, -- retained_amount
          amount_includes_tax_flag,
          --Bug6167068 starts Added the following columns to get related data
          --           for Expense reports
          cc_reversal_flag,
          company_prepaid_invoice_id,
          expense_group,
          justification,
          merchant_document_number,
          merchant_name,
          merchant_reference,
          merchant_taxpayer_id,
          merchant_tax_reg_number,
          receipt_conversion_rate,
          receipt_currency_amount,
          receipt_currency_code,
          country_of_supply
          --Bug6167068 ends
	  --bug 8658097 starts
	  ,expense_start_date
	  ,expense_end_date
	  --bug 8658097 ends
	  /* Added for bug 10226070 */
	  ,Requester_last_name
      	  ,Requester_first_name
     FROM ap_invoice_lines_interface ail
    WHERE invoice_id = p_invoice_rec.invoice_id
    -- Bug 6369356
    AND   ((line_type_lookup_code <> 'TAX')
          OR ( line_type_lookup_code = 'TAX' AND
          rowid =(SELECT max(ail2.rowid)
                  FROM   ap_invoice_lines_interface ail2
                  WHERE  ail2.tax_code = ail.tax_code
                  AND    ail2.line_type_lookup_code = 'TAX'
                  AND    ail2.invoice_id = ail.invoice_id
                  GROUP BY tax_code)
                  )
                  )
    -- Bug 6369356
 ORDER BY invoice_line_id;
--   FOR UPDATE OF invoice_line_id; -- Bug 1714845

check_lines_failure          EXCEPTION;
l_current_invoice_status      VARCHAR2(1) := 'Y';
l_temp_line_status          VARCHAR2(1) := 'Y';
l_max_line_number             NUMBER;
l_employee_id                  NUMBER;
l_error_message              VARCHAR2(200);
l_pa_built_account            NUMBER := 0;
current_calling_sequence      VARCHAR2(2000);
debug_info                 VARCHAR2(500);
/* bug 5039042 */
l_product_registered       VARCHAR2(1) := 'N';
l_dummy                    VARCHAR2(100);


BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_lines_validation<-'||P_calling_sequence;

  --------------------------------------------------------
  -- Step 1
  -- Get Employee ID for PA Related Invoice Line
  ---------------------------------------------------------

  --Payment Requests: Added IF condition for Payment Requests
  --IF (p_invoice_rec.invoice_type_lookup_code <> 'PAYMENT REQUEST') THEN    .. B# 8528132
  IF (nvl(p_invoice_rec.invoice_type_lookup_code, 'STANDARD') <> 'PAYMENT REQUEST') THEN    -- B# 8528132

     debug_info := '(Check_lines 1) Call Get_employee_id';
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
     END IF;

     IF (AP_IMPORT_UTILITIES_PKG.get_employee_id(
           p_invoice_rec.invoice_id,
           p_invoice_rec.vendor_id,
           l_employee_id,                -- OUT
           p_default_last_updated_by,
           p_default_last_update_login,
           l_temp_line_status,           -- OUT
           p_calling_sequence    => current_calling_sequence) <> TRUE ) THEN
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                         'get_employee_id<-' ||current_calling_sequence);
       END IF;
       RAISE check_lines_failure;
     END IF;
  END IF;

  --
  -- show output values (only if debug_switch = 'Y')
  --
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
    '------------------> l_temp_line_status = '||l_temp_line_status
    ||' l_employee_id = '||to_char(l_employee_id));
  END IF;

  -- Since vendor is already validated
  -- Rejection should happen only if the Project Related
  -- invoices do not have a valid employee_id in PO_vendors

  IF (l_temp_line_status = 'N') THEN
     l_current_invoice_status := l_temp_line_status;
  END IF;

  --------------------------------------------------------------------------
  -- Step 2
  -- Get max line number for the invoice to be used in case a line does not
  -- provide a line number
  --------------------------------------------------------------------------
  debug_info := '(Check Lines 2) Get Max Line Number';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;
  --
  IF AP_IMPORT_INVOICES_PKG.g_source = 'RETEK' THEN
      BEGIN
          SELECT NVL(MAX(line_number),0)
          INTO l_max_line_number
          FROM ap_invoice_lines_interface ail
         WHERE invoice_id = p_invoice_rec.invoice_id
         AND   ((line_type_lookup_code <> 'TAX')
          OR ( line_type_lookup_code = 'TAX' AND
          rowid =(SELECT MAX(ail2.rowid)
                  FROM   ap_invoice_lines_interface ail2
                  WHERE  ail2.tax_code = ail.tax_code
                  AND    ail2.line_type_lookup_code = 'TAX'
                  AND    ail2.invoice_id = ail.invoice_id
                  GROUP BY tax_code)
                  )
                  );
      EXCEPTION
        WHEN OTHERS THEN
          RAISE check_lines_failure;
      END;
  -- Bug 6369356
  --
  ELSIF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN   --Retropricing
      BEGIN
	--bugfix:4745899 , added the NVL condition
        SELECT NVL(MAX(line_number),0)
          INTO l_max_line_number
          FROM ap_invoice_lines_interface
         WHERE invoice_id = p_invoice_rec.invoice_id;

      EXCEPTION
        WHEN OTHERS THEN
          RAISE check_lines_failure;
      END;
  ELSE
    --
    l_max_line_number :=   p_invoice_lines_tab.COUNT;
    --
  END IF;
  --------------------------------------------------------------------------
  -- Step 3
  -- Open invoice_lines cursor.
  -- Retropricing: For PPA's the p_invoice_lines_tab is populated from
  -- AP_PPA_LINES_GT
  --------------------------------------------------------------------------
  debug_info := '(Check Lines 3) Open Cursor: invoice_lines';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  -- Bug 6369356
  IF AP_IMPORT_INVOICES_PKG.g_source = 'RETEK' THEN
      OPEN invoice_lines_tax_summarized;
      FETCH invoice_lines_tax_summarized BULK COLLECT INTO p_invoice_lines_tab;
      CLOSE invoice_lines_tax_summarized;
  ELSIF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN   --Retropricing
      OPEN invoice_lines;
      FETCH invoice_lines BULK COLLECT INTO p_invoice_lines_tab;
      CLOSE invoice_lines;
  END IF;

  FOR i IN 1..p_invoice_lines_tab.COUNT  --Retropricing
  LOOP
    --------------------------------------------------------------------------
    -- Step 4
    -- Loop through fetched invoice lines
    --------------------------------------------------------------------------
    debug_info := '(Check Lines 4) Looping through fetched invoice lines';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    -- Retropricing: Base Amount is populated for proposed PPA Lines
    IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN
        p_invoice_lines_tab(i).base_amount :=
             ap_utilities_pkg.ap_round_currency(
                p_invoice_lines_tab(i).amount*p_invoice_rec.exchange_rate,
                p_base_currency_code );
    END IF;

    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch ,
      '------------------>  invoice_line_id = '
        ||to_char(p_invoice_lines_tab(i).invoice_line_id )
      ||' line_type_lookup_code = '
        || p_invoice_lines_tab(i).line_type_lookup_code
      || 'line_number = '    || to_char(p_invoice_lines_tab(i).line_number)
      || 'line_group_number = '
        || to_char(p_invoice_lines_tab(i).line_group_number)
      || 'amount = '            || to_char(p_invoice_lines_tab(i).amount)
      || 'base amount  '
        || to_char(p_invoice_lines_tab(i).base_amount)
      || 'accounting_date = '
        || to_char(p_invoice_lines_tab(i).accounting_date)
      || 'deferred_acctg_flag = '|| p_invoice_lines_tab(i).deferred_acctg_flag
      || 'def_acctg_start_date = '
        || to_char(p_invoice_lines_tab(i).def_acctg_start_date)
      || 'def_acctg_end_date = '
        || to_char(p_invoice_lines_tab(i).def_acctg_end_date)
      || 'def_acctg_number_of_period = '
        || to_char(p_invoice_lines_tab(i).def_acctg_number_of_periods)
      || 'def_acctg_period_type = '
        || p_invoice_lines_tab(i).def_acctg_period_type
      || 'description = '    || p_invoice_lines_tab(i).description
      || 'prorate_across_flag = '
        || p_invoice_lines_tab(i).prorate_across_flag
      || 'po_header_id = ' ||    to_char(p_invoice_lines_tab(i).po_header_id)
      || 'po_number = '    || to_char(p_invoice_lines_tab(i).po_number)
      || 'po_line_id = '    || to_char(p_invoice_lines_tab(i).po_line_id)
      || 'po_line_number = ' || to_char(p_invoice_lines_tab(i).po_line_number)
      || 'po_release_id = '    || to_char(p_invoice_lines_tab(i).po_release_id)
      || 'release_num = '    || to_char(p_invoice_lines_tab(i).release_num)
      || 'po_line_location_id = '
        || to_char(p_invoice_lines_tab(i).po_line_location_id)
      || 'po_shipment_num = '
        || to_char(p_invoice_lines_tab(i).po_shipment_num)
      || 'po_distribution_id = '
        || to_char(p_invoice_lines_tab(i).po_distribution_id)
      || 'po_distribution_num = '
        || to_char(p_invoice_lines_tab(i).po_distribution_num)
      || 'unit_of_meas_lookup_code = '
        || p_invoice_lines_tab(i).unit_of_meas_lookup_code
      || 'inventory_item_id = '
        || to_char(p_invoice_lines_tab(i).inventory_item_id)
      || 'item_description = '    || p_invoice_lines_tab(i).item_description
      || 'purchasing_category_id = '   || p_invoice_lines_tab(i).purchasing_category_id
      || 'purchasing_category = '  || p_invoice_lines_tab(i).purchasing_category
      || 'quantity_invoiced = '
        || to_char(p_invoice_lines_tab(i).quantity_invoiced)
      || 'ship_to_location_code = '
        || p_invoice_lines_tab(i).ship_to_location_code
      || 'unit_price = '
        || to_char(p_invoice_lines_tab(i).unit_price)
      || 'final_match_flag = '    || p_invoice_lines_tab(i).final_match_flag
      || 'distribution_set_id = '
        || to_char(p_invoice_lines_tab(i).distribution_set_id)
      || 'distribution_set_name = '
     || p_invoice_lines_tab(i).distribution_set_name
      || 'dist_code_concatenated = '
        || p_invoice_lines_tab(i).dist_code_concatenated
      || 'dist_code_combination_id = '
        || to_char(p_invoice_lines_tab(i).dist_code_combination_id)
      || 'awt_group_id = '
        || to_char(p_invoice_lines_tab(i).awt_group_id)
      || 'awt_group_name = '    || p_invoice_lines_tab(i).awt_group_name
      || 'balancing_segment = '    || p_invoice_lines_tab(i).balancing_segment
      || 'cost_center_segment = ' || p_invoice_lines_tab(i).cost_center_segment
      || 'account_segment = '      || p_invoice_lines_tab(i).account_segment
      || 'attribute_category = '  || p_invoice_lines_tab(i).attribute_category
      || 'attribute1 = '    || p_invoice_lines_tab(i).attribute1
      || 'attribute2 = '    || p_invoice_lines_tab(i).attribute2
      || 'attribute3 = '    || p_invoice_lines_tab(i).attribute3
      || 'attribute4 = '    || p_invoice_lines_tab(i).attribute4
      || 'attribute5 = '    || p_invoice_lines_tab(i).attribute5
      || 'attribute6 = '    || p_invoice_lines_tab(i).attribute6
      || 'attribute7 = '    || p_invoice_lines_tab(i).attribute7
      || 'attribute8 = '    || p_invoice_lines_tab(i).attribute8
      || 'attribute9 = '    || p_invoice_lines_tab(i).attribute9
      || 'attribute10 = '    || p_invoice_lines_tab(i).attribute10
      || 'attribute11 = '    || p_invoice_lines_tab(i).attribute11
      || 'attribute12 = '    || p_invoice_lines_tab(i).attribute12
      || 'attribute13 = '    || p_invoice_lines_tab(i).attribute13
      || 'attribute14 = '    || p_invoice_lines_tab(i).attribute14
      || 'attribute15 = '    || p_invoice_lines_tab(i).attribute15
      || 'global_attribute_category = '
        || p_invoice_lines_tab(i).global_attribute_category
      || 'global_attribute1 = '    || p_invoice_lines_tab(i).global_attribute1
      || 'global_attribute2 = '    || p_invoice_lines_tab(i).global_attribute2
      || 'global_attribute3 = '    || p_invoice_lines_tab(i).global_attribute3
      || 'global_attribute4 = '    || p_invoice_lines_tab(i).global_attribute4
      || 'global_attribute5 = '    || p_invoice_lines_tab(i).global_attribute5
      || 'global_attribute6 = '    || p_invoice_lines_tab(i).global_attribute6
      || 'global_attribute7 = '    || p_invoice_lines_tab(i).global_attribute7
      || 'global_attribute8 = '    || p_invoice_lines_tab(i).global_attribute8
      || 'global_attribute9 = '    || p_invoice_lines_tab(i).global_attribute9
      || 'global_attribute10 = '|| p_invoice_lines_tab(i).global_attribute10
      || 'global_attribute11 = '|| p_invoice_lines_tab(i).global_attribute11
      || 'global_attribute12 = '|| p_invoice_lines_tab(i).global_attribute12
      || 'global_attribute13 = '|| p_invoice_lines_tab(i).global_attribute13
      || 'global_attribute14 = '|| p_invoice_lines_tab(i).global_attribute14
      || 'global_attribute15 = '|| p_invoice_lines_tab(i).global_attribute15
      || 'global_attribute16 = '|| p_invoice_lines_tab(i).global_attribute16
      || 'global_attribute17 = '|| p_invoice_lines_tab(i).global_attribute17
      || 'global_attribute18 = '|| p_invoice_lines_tab(i).global_attribute18
      || 'global_attribute19 = '|| p_invoice_lines_tab(i).global_attribute19
      || 'global_attribute20 = '|| p_invoice_lines_tab(i).global_attribute20
      || 'project_id = '         || to_char(p_invoice_lines_tab(i).project_id)
      || 'task_id = '           || to_char(p_invoice_lines_tab(i).task_id)
      || 'award_id = '            || to_char(p_invoice_lines_tab(i).award_id)
      || 'expenditure_type = '    || p_invoice_lines_tab(i).expenditure_type
      || 'expenditure_item_date = '
        || to_char(p_invoice_lines_tab(i).expenditure_item_date)
      || 'expenditure_organization_id = '
        || p_invoice_lines_tab(i).expenditure_organization_id
      || 'pa_addition_flag = '    || p_invoice_lines_tab(i).pa_addition_flag
      || 'pa_quantity = '    || to_char(p_invoice_lines_tab(i).pa_quantity)
      || 'stat_amount = '    || to_char(p_invoice_lines_tab(i).stat_amount)
      || 'type_1099 = '    || p_invoice_lines_tab(i).type_1099
      || 'income_tax_region = '    || p_invoice_lines_tab(i).income_tax_region
      || 'asset_tracking_flag = '
        || p_invoice_lines_tab(i).assets_tracking_flag
      || 'asset_book_type_code = '
        || p_invoice_lines_tab(i).asset_book_type_code
      || 'asset_category_id = '
        || to_char(p_invoice_lines_tab(i).asset_category_id)
      || 'serial_number = '    || to_char(p_invoice_lines_tab(i).serial_number)
      || 'manufacturer = '    || p_invoice_lines_tab(i).manufacturer
      || 'model_number = '    || p_invoice_lines_tab(i).model_number
      || 'warranty_number = '    || p_invoice_lines_tab(i).warranty_number
      || 'price_correction_flag = '
        || p_invoice_lines_tab(i).price_correction_flag
      || 'price_correct_inv_num = '
        || p_invoice_lines_tab(i).price_correct_inv_num
      || 'price_correct_inv_id = '
        || p_invoice_lines_tab(i).corrected_inv_id
      || 'price_correct_inv_line_num = '
        || p_invoice_lines_tab(i).price_correct_inv_line_num
      || 'receipt_number = '    || p_invoice_lines_tab(i).receipt_number
      || 'receipt_line_number = '
        || p_invoice_lines_tab(i).receipt_line_number
      || 'rcv_transaction_id = '
        || to_char(p_invoice_lines_tab(i).rcv_transaction_id)
      || 'match_option = '    || p_invoice_lines_tab(i).match_option
      || 'packing_slip = '    || p_invoice_lines_tab(i).packing_slip
      || 'vendor_item_num = '    || p_invoice_lines_tab(i).vendor_item_num
      || 'pa_cc_ar_invoice_id = '
        || to_char(p_invoice_lines_tab(i).pa_cc_ar_invoice_id)
      || 'pa_cc_ar_invoice_line_num = '
        ||to_char(p_invoice_lines_tab(i).pa_cc_ar_invoice_line_num)
      ||'pa_cc_processed_code = ' || p_invoice_lines_tab(i).pa_cc_processed_code
      || 'reference_1 = '    || p_invoice_lines_tab(i).reference_1
      || 'reference_2 = '    || p_invoice_lines_tab(i).reference_2
      || 'credit_card_trx_id = '
        || to_char(p_invoice_lines_tab(i).credit_card_trx_id)
      || 'requester_id = '    || to_char(p_invoice_lines_tab(i).requester_id)
      || 'org_id = '    || to_char(p_invoice_lines_tab(i).org_id)
    );
    END IF;

    -------------------------------------------------------------------------
    -- Step 5
    -- Validate line's org_id.
    -- Retropricing: Org Id's are populated for PPA Lines
    -------------------------------------------------------------------------
    IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN   --Retropricing
        debug_info := '(Check Lines 5) Validate org id for line';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF p_invoice_lines_tab(i).org_id IS NOT NULL THEN
          debug_info := '(Check_lines 5.0) Org Id Is Not Null';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                          debug_info);
          END IF;

          IF p_invoice_lines_tab(i).org_id <> p_invoice_rec.org_id THEN

            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                                (AP_IMPORT_INVOICES_PKG.g_invoices_table,  -- Bug 9452076.
                                  p_invoice_rec.invoice_id,
                                  'INCONSISTENT OPERATING UNITS',
                                  p_default_last_updated_by,
                                  p_default_last_update_login,
                                  current_calling_sequence) <> TRUE ) Then
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<- '      ||current_calling_sequence);
              END IF;
              RAISE check_lines_failure;
            END IF;

            l_current_invoice_status := 'N';
            EXIT;
          END IF;

        ELSE

          UPDATE ap_invoice_lines_interface
             SET org_id = p_invoice_rec.org_id
           WHERE rowid = p_invoice_lines_tab(i).row_id;

          p_invoice_lines_tab(i).org_id := p_invoice_rec.org_id;
        END IF;
    END IF;   -- source <> PPA
    --------------------------------------------------------------------
    -- Step 6
    -- Get new invoice line id.
    -- Retropricing: The code below will not execute for PPA's.
    -- Invoice_line_id is present for PPA's
    --------------------------------------------------------------------
    IF (p_invoice_lines_tab(i).invoice_line_id is NULL) THEN
        --
      debug_info := '(Check_lines 6.1) Get new invoice_line_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      debug_info := '(Check_lines 6.2) Update new invoice_line_id to '
                    ||'ap_invoice_lines_interface';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      UPDATE ap_invoice_lines_interface
         SET invoice_line_id =  ap_invoice_lines_interface_s.NEXTVAL
       WHERE rowid = p_invoice_lines_tab(i).row_id
      RETURNING invoice_line_id INTO p_invoice_lines_tab(i).invoice_line_id;
    END IF;

    ------------------------------------------------------------------------
    -- Step 7
    -- Check for partial segments
    -- Retropricing: The code below will not execute for PPA's.
    ------------------------------------------------------------------------
    IF (p_invoice_lines_tab(i).dist_code_concatenated IS NOT NULL) THEN
      debug_info := '(v_check_lines 7.0) Check for partial Segments';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      IF (AP_UTILITIES_PKG.Check_partial(
            p_invoice_lines_tab(i).dist_code_concatenated,  -- IN
             P_invoice_lines_tab(i).partial_segments,        -- OUT
            p_set_of_books_id,                              -- IN
            l_error_message,                                 -- OUT
            current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'AP_UTILITIES_PKG.Check_Partial<-'||current_calling_sequence);
        END IF;
        RAISE check_lines_failure;
      END IF;

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------> partial_segments = '
            || p_invoice_lines_tab(i).partial_segments
            ||'l_error_message = '||l_error_message
            ||'dist_code_concatenated = '
            || p_invoice_lines_tab(i).dist_code_concatenated);
      END IF;
    END IF; --dist_code_concatenated

    -------------------------------------------------
    -- step 8
    -- Firstly we need to check line amount is NULL
    -- checking for the precision of the lines amount
    -------------------------------------------------
    -- Added for bug 9484163
    IF ( p_invoice_lines_tab(i).amount is null) THEN
         debug_info := '(Check Invoice Line amount 8.1) Invoice Line '
                    ||'Amount is null';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_tab(i).invoice_line_id,
                'LINE AMOUNT IS NULL',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                  AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                           'insert_rejections<-'||current_calling_sequence);
           END IF;
           RAISE check_lines_failure;
      END IF;
      l_temp_line_status :='N';

    ELSE -- Bug 9484163 ends

	IF (p_invoice_lines_tab(i).amount <> 0 AND
		p_invoice_lines_tab(i).invoice_line_id is not null)  THEN

		debug_info := '(Check Invoice Line amount 8) Check for invoice line '
			    ||'amount if it is not exceeding precision';
		IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
			AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
		END IF;
		IF (AP_IMPORT_VALIDATION_PKG.v_check_invoice_line_amount (
				p_invoice_lines_tab(i),
			        p_precision_inv_curr,
				p_default_last_updated_by,
				p_default_last_update_login,
				p_current_invoice_status => l_temp_line_status,  --IN OUT
				p_calling_sequence  => current_calling_sequence) <> TRUE )THEN
			IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
				AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					'v_check_line_amount<-'||current_calling_sequence);
		        END IF;
			RAISE check_lines_failure;

	      END IF;
	      /*(IF (l_temp_line_status = 'N') THEN
		l_current_invoice_status := l_temp_line_status;
	      END IF;
		--
		-- show output values (only if debug_switch = 'Y')
		--
	      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
			AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
			'------------------>
			l_temp_invoice_status  = '||l_temp_line_status);
	      END IF;*/ -- Commented and moved this code out of this IF Loop for bug 9484163

	END IF;
    END IF; -- Invoice line amount is null
    -- For bug 9484163
    IF (l_temp_line_status = 'N') THEN
        l_current_invoice_status := l_temp_line_status;
    END IF;
      --
      -- show output values (only if debug_switch = 'Y')
      --
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
         '------------------>
         l_temp_invoice_status  = '||l_temp_line_status);
    END IF; -- bug 9484163 ends

    --------------------------------------------------------
    -- Step 9
    -- check for PO Information
    -- only for ITEM Lines
    ---------------------------------------------------------
    debug_info := '(Check_lines 9) Call v_check_po_info only for ITEM Lines';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (nvl(p_invoice_lines_tab(i).line_type_lookup_code, 'ITEM' )
         IN ('ITEM','RETROITEM')) THEN
      debug_info := '(Check_lines 9.1) This is an ITEM Line';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      IF (AP_IMPORT_VALIDATION_PKG.v_check_line_po_info(
           p_invoice_rec,                        -- IN
           p_invoice_lines_tab(i),                -- IN OUT
           p_set_of_books_id,                      -- IN
           p_positive_price_tolerance,             -- IN
           p_qty_ord_tolerance,                    -- IN
	   p_amt_ord_tolerance,			   -- IN
           p_max_qty_ord_tolerance,                -- IN
	   p_max_amt_ord_tolerance,		   -- IN
           p_default_last_updated_by,              -- IN
           p_default_last_update_login,            -- IN
           p_current_invoice_status => l_temp_line_status,  -- IN OUT NOCOPY
           p_calling_sequence       => current_calling_sequence)
          <> TRUE )THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'v_check_po_info<-' ||current_calling_sequence);
        END IF;
        RAISE check_lines_failure;
      END IF;

      --
      -- show output values (only if debug_switch = 'Y')
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '------------------> l_temp_line_status = '|| l_temp_line_status);
      END IF;

      -- We need to set the current status to 'N' only if the temp line status
      -- returns 'N'. So all temp returns of 'N' will overwrite the current
      -- invoice status to 'N' which finally would be returned to the calling
      -- function.
      IF (l_temp_line_status = 'N') THEN
        l_current_invoice_status := l_temp_line_status;
      END IF;

    END IF; -- for ITEM line type lookup

    --------------------------------------------------------
    -- Step 10
    -- Check for receipt information if match option = 'R'
    --------------------------------------------------------
    debug_info := '(Check_lines 10) Call v_check_receipt_info';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

--Bug 5225547 added the below condition to call v_check_receipt_info

  IF (p_invoice_lines_tab(i).match_option = 'R') Then

    IF (AP_IMPORT_VALIDATION_PKG.v_check_receipt_info (
         p_invoice_rec	,			 -- IN
         p_invoice_lines_tab(i),                 -- IN
         p_default_last_updated_by,              -- IN
         p_default_last_update_login,            -- IN
         p_temp_line_status           => l_temp_line_status, -- OUT NOCOPY
         p_calling_sequence           => current_calling_sequence)
         <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        'v_check_receipt_info<-' ||current_calling_sequence);
      END IF;
      RAISE check_lines_failure;
    END IF;
   END IF;

    --
    -- show output values (only if debug_switch = 'Y')
    --
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   '------------------> l_temp_line_status = '||
            l_temp_line_status);
    END IF;

    -- We need to set the current status to 'N' only if the temp line status
    -- returns 'N'. So all temp returns of 'N' will overwrite the current
    -- invoice status to 'N' which finally would be returned to the calling
    -- function.
    IF (l_temp_line_status = 'N') THEN
      l_current_invoice_status := l_temp_line_status;
    END IF;


    -----------------------------------------------------------------
    -- Step 11
    --Validate the purchasing_category information.
    -----------------------------------------------------------------
    IF (p_invoice_lines_tab(i).purchasing_category_id IS NOT NULL OR
         p_invoice_lines_tab(i).purchasing_category IS NOT NULL) THEN

      debug_info := '(Check Purchasing Category Info 11) Check if valid '
                    ||'purchasing category information is provided';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      IF (AP_IMPORT_VALIDATION_PKG.v_check_line_purch_category(
                p_invoice_lines_tab(i),
                p_default_last_updated_by,
                p_default_last_update_login,
                p_current_invoice_status => l_temp_line_status,  --IN OUT
                p_calling_sequence  => current_calling_sequence) <> TRUE )THEN

         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           'v_check_purchasing_category<-'||current_calling_sequence);
         END IF;
         RAISE check_lines_failure;

      END IF;

      IF (l_temp_line_status = 'N') THEN
        l_current_invoice_status := l_temp_line_status;
      END IF;
      --
      -- show output values (only if debug_switch = 'Y')
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '------------------>
          l_temp_invoice_status  = '||l_temp_line_status);
      END IF;

    END IF;


    -----------------------------------------------------------------
    -- Step 12
    --Validate the Cost_Factor information.
    -----------------------------------------------------------------
    IF (p_invoice_lines_tab(i).cost_factor_id IS NOT NULL OR
         p_invoice_lines_tab(i).cost_factor_name IS NOT NULL) THEN

      debug_info := '(Check Cost Factor Info 12) Check if valid '
                    ||'cost factor information is provided';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      IF (AP_IMPORT_VALIDATION_PKG.v_check_line_cost_factor(
                p_invoice_lines_tab(i),
                p_default_last_updated_by,
                p_default_last_update_login,
                p_current_invoice_status => l_temp_line_status,  --IN OUT
                p_calling_sequence  => current_calling_sequence) <> TRUE )THEN

         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           'v_check_line_cost_factor<-'||current_calling_sequence);
         END IF;
         RAISE check_lines_failure;

      END IF;

      IF (l_temp_line_status = 'N') THEN
        l_current_invoice_status := l_temp_line_status;
      END IF;
      --
      -- show output values (only if debug_switch = 'Y')
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '------------------>
          l_temp_invoice_status  = '||l_temp_line_status);
      END IF;

    END IF;


    -------------------------------------------------------
    --bugfix:5565310
    --Step 12a
    --Populate PO Tax Attributes on the line if it is a po/rct
    --matched.
    ----------------------------------------------------------
    IF(p_invoice_lines_tab(i).po_line_location_id IS NOT NULL) THEN

       IF (v_check_line_get_po_tax_attr(p_invoice_rec  =>  p_invoice_rec,
       				      p_invoice_lines_rec =>p_invoice_lines_tab(i),
				      p_calling_sequence => current_calling_sequence)
				      <> TRUE) THEN

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
		              'v_check_line_populate_po_tax_attr<-' ||current_calling_sequence);
            END IF;
            RAISE check_lines_failure;

       END IF;

    END IF;
    --------------------------------------------------------
    -- Step 13
    -- check for accounting date Information
    ---------------------------------------------------------
    debug_info := '(Check_lines 13) Call v_check_line_accounting_date';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (AP_IMPORT_VALIDATION_PKG.v_check_line_accounting_date(
         p_invoice_rec,                          -- IN
         p_invoice_lines_tab(i),                -- IN OUT NOCOPY
         p_gl_date_from_get_info,                -- IN
         p_gl_date_from_receipt_flag,            -- IN
         p_set_of_books_id,                      -- IN
         p_purch_encumbrance_flag,               -- IN
         p_default_last_updated_by,              -- IN
         p_default_last_update_login,            -- IN
         p_current_invoice_status   => l_temp_line_status,-- IN OUT NOCOPY
         p_calling_sequence         => current_calling_sequence)
         <> TRUE )THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'v_check_line_accounting_date<-' ||current_calling_sequence);
      END IF;
      RAISE check_lines_failure;
    END IF;

    --
    -- show output values (only if debug_switch = 'Y')
    --
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
      '------------------> l_temp_line_status = '|| l_temp_line_status);
    END IF;
    --
    IF (l_temp_line_status = 'N') THEN
      l_current_invoice_status := l_temp_line_status;
    END IF;


    --------------------------------------------------------
    -- Step 14
    -- check for project information
    ---------------------------------------------------------
    debug_info := '(Check_lines 14) Call v_check_line_project_info';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    --bugfix:4773191 , added the IF condition to bypass the pa flexbuild
    --validation since this is already done in OIE during the creation
    --of expense report before populating the records into interface table.
    --IF (p_invoice_rec.invoice_type_lookup_code <> 'EXPENSE REPORT') THEN    .. B# 8528132
    IF (nvl(p_invoice_rec.invoice_type_lookup_code, 'STANDARD') <> 'EXPENSE REPORT') THEN    -- B# 8528132
       l_pa_built_account := 0;

       IF (AP_IMPORT_VALIDATION_PKG.v_check_line_project_info (
         p_invoice_rec,                              -- IN
         p_invoice_lines_tab(i),                        -- IN OUT NOCOPY
         nvl(p_invoice_lines_tab(i).accounting_date, --  IN p_accounting_date
             p_gl_date_from_get_info),
         p_pa_installed,                             -- IN
         l_employee_id,                              -- IN
         p_base_currency_code,                         -- IN
         p_set_of_books_id,                           -- IN
         p_chart_of_accounts_id,                     -- IN
         p_default_last_updated_by,                     -- IN
         p_default_last_update_login,                 -- IN
         p_pa_built_account         => l_pa_built_account, -- OUT NOCOPY
         p_current_invoice_status   => l_temp_line_status, -- IN OUT NOCOPY
         p_calling_sequence         => current_calling_sequence)
         <> TRUE )THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'v_check_line_project_info<-' ||current_calling_sequence);
         END IF;
         RAISE check_lines_failure;
       END IF;

       --
       -- show output values (only if debug_switch = 'Y')
       --
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             '------------------> l_temp_line_status = '|| l_temp_line_status
            ||' dist_code_combination_id = '
            || to_char(p_invoice_lines_tab(i).dist_code_combination_id));
       END IF;
       --
       --
       IF (l_temp_line_status = 'N') THEN
          l_current_invoice_status := l_temp_line_status;
       END IF;

    END IF; --bugfix:4773191

    -------------------------------------------------------------------
    -- Step 15.0
    -- Check for Product Registration in AP_PRODUCT_REGISTRATIONS
    -- If source application is registered for DISTRIBUTION_GENERATION
    -- then no need to validate lien account info
    -------------------------------------------------------------------

    debug_info := '(Check_lines 15.0) Call Is_Product_Registered';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    End if;

    /* bug 5039042. Whether Source Application is registered for
       Distribution Generation Via Ap_Product_Registrations */
    /* Bug 5448579. Added the IF condition */
    IF (p_invoice_lines_tab(i).application_id IS NULL) THEN
      l_product_registered := 'N';
    ELSE
      IF (Ap_Import_Utilities_Pkg.Is_Product_Registered(
                P_application_id => p_invoice_lines_tab(i).application_id,
                X_registration_api    => l_dummy,
                X_registration_view   => l_dummy,
                P_calling_sequence    => current_calling_sequence)) THEN
        l_product_registered := 'Y';
      ELSE
        l_product_registered := 'N';
      END IF;
    END IF;

   /* bug 5121735 */
   debug_info := '(Check_lines 15.1) l_product_registered: '||l_product_registered;
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(
     AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
   End if;

    -------------------------------------------------------------------
    -- Step 15
    -- check for account Information.
    -- Retropricing: The account validation is not needed for PPA
    -- as the ccid will be copied from the corrected_invoice_dist or from
    -- po/rcv transaction
    ------------------------------------------------------------------
    /* bug 5039042. If Source Application is registered for
       Ditribution Generation Via Ap_Product_Registrations
       Then no need to validate the line account info */

    IF (AP_IMPORT_INVOICES_PKG.g_source <> 'PPA') THEN
      IF (l_product_registered = 'N') THEN   /* bug 5121735 */
        debug_info := '(Check_lines 15) Call v_check_line_account_info';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        End if;

        /*Start of bug 4386299*/
        --If distribution_set_id is null or accounting information is not there
        --then we would default from vendor-sites
        IF (
            (p_invoice_lines_tab(i).dist_code_concatenated IS NULL
            OR p_invoice_lines_tab(i).partial_segments = 'Y')
        AND p_invoice_lines_tab(i).dist_code_combination_id IS NULL
        AND p_invoice_rec.po_number IS NULL                 --default po number
        AND p_invoice_lines_tab(i).po_number IS NULL
        AND p_invoice_lines_tab(i).po_header_id IS NULL
        AND p_invoice_lines_tab(i).distribution_set_id IS NULL
        AND p_invoice_lines_tab(i).distribution_set_name IS NULL
        AND (p_invoice_rec.vendor_id IS NOT NULL
            AND p_invoice_rec.vendor_site_id IS NOT NULL)
        )
        THEN
          begin
            select distribution_set_id
              into p_invoice_lines_tab(i).distribution_set_id
              from po_vendor_sites
             where vendor_id=p_invoice_rec.vendor_id
               and vendor_site_id=p_invoice_rec.vendor_site_id;
          exception
           when no_data_found then
            p_invoice_lines_tab(i).distribution_set_id:=null;
          end;
        END IF;
        /*End of bug 4386299*/

            IF (AP_IMPORT_VALIDATION_PKG.v_check_line_account_info (
             p_invoice_lines_tab(i),                       -- IN OUT NOCOPY
             p_freight_code_combination_id,                -- IN
             l_pa_built_account,                        -- IN
             nvl(p_invoice_lines_tab(i).accounting_date, -- IN p_accounting_date
                 p_gl_date_from_get_info),
             p_set_of_books_id,                          -- IN
             p_chart_of_accounts_id,                       -- IN
             p_default_last_updated_by,                    -- IN
             p_default_last_update_login,                -- IN
             p_current_invoice_status => l_temp_line_status,-- IN OUT NOCOPY
             p_calling_sequence       => current_calling_sequence) <> TRUE
             ) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'v_check_line_account_info<-' ||current_calling_sequence);
          END IF;
          RAISE check_lines_failure;
        END IF;
        --
        -- show output values (only if debug_switch = 'Y')
        --
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------> l_temp_line_status = '||
            l_temp_line_status ||'dist_code_combination_id = '
            ||to_char(p_invoice_lines_tab(i).dist_code_combination_id));
        END IF;
        --
        IF (l_temp_line_status = 'N') THEN
          l_current_invoice_status := l_temp_line_status;
        END IF;
     END IF;  -- l_product_registered /* bug 5121735 */
    END IF;  --source <> PPA

    --------------------------------------------------------------------------
    -- Step 16
    -- check for deferred accounting Information
    -- Retropricing: For PPA Lines deferred_acctg_flag = 'N' and the validation
    -- w.r.t deferred accounting is not required.
    --------------------------------------------------------------------------
    IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN

        debug_info := '(Check_lines 16) Call v_check_deferred_accounting';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                         debug_info);
        END IF;

        IF (AP_IMPORT_VALIDATION_PKG.v_check_deferred_accounting (
             p_invoice_lines_tab(i),                     -- IN OUT NOCOPY
             p_set_of_books_id,                        -- IN
             p_default_last_updated_by,                -- IN
             p_default_last_update_login,              -- IN
             p_current_invoice_status => l_temp_line_status,-- IN OUT NOCOPY
             p_calling_sequence       => current_calling_sequence) <> TRUE )THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'v_check_deferred_accounting<-' ||current_calling_sequence);
          end if;
          RAISE check_lines_failure;
        END IF;

        --
        -- show output values (only if debug_switch = 'Y')
        --
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             '------------------> l_temp_line_status = '||
            l_temp_line_status);
        END IF;
        --
        IF (l_temp_line_status = 'N') THEN
          l_current_invoice_status := l_temp_line_status;
        END IF;

    END IF; --source <> PPA
    --------------------------------------------------------
    -- Step 17
    -- check distribution set information
    -- Retropricing: For PPA Lines dist set is NULL and the validation
    -- w.r.t Dist Set is not required.
    ---------------------------------------------------------
     IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN
        --
        debug_info := '(Check_lines 17) Call v_check_line_dist_set';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;
        --
        IF (nvl(p_invoice_lines_tab(i).line_type_lookup_code, 'ITEM' )
             = 'ITEM') THEN
          IF  (AP_IMPORT_VALIDATION_PKG.v_check_line_dist_set (
               p_invoice_rec,                         -- IN
               p_invoice_lines_tab(i),                -- IN OUT NOCOPY
               p_base_currency_code,                  -- IN
               l_employee_id,                         -- IN
               p_gl_date_from_get_info,               -- IN
               p_set_of_books_id,                     -- IN
               p_chart_of_accounts_id,                -- IN
               p_pa_installed,                        -- IN
               p_default_last_updated_by,             -- IN
               p_default_last_update_login,           -- IN
               p_current_invoice_status   => l_temp_line_status,-- IN OUT NOCOPY
               p_calling_sequence         => current_calling_sequence)
              <> TRUE )THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             AP_IMPORT_UTILITIES_PKG.Print(
                          AP_IMPORT_INVOICES_PKG.g_debug_switch,
                      'v_check_line_dist_set<-' ||current_calling_sequence);
            END IF;
            RAISE check_lines_failure;
          END IF;
          --
          -- show output values (only if debug_switch = 'Y')
          --
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             '------------------> l_temp_line_status = '|| l_temp_line_status);
          END IF;
          --
          IF (l_temp_line_status = 'N') THEN
        l_current_invoice_status := l_temp_line_status;
          END IF;
        END IF; -- Check dist set info, only for ITEM type lines.
        --
    END IF; --source <> PPA

   --------------------------------------------------------
   -- Step 18
   -- Validate Qty related information for non PO/RCV matched lines
   ---------------------------------------------------------
   debug_info := '(Check_lines 18) Call v_check_qty_uom_info';
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
   END IF;

   -- check for invalid qty related information for non PO/RCV matched lines
   IF (AP_IMPORT_VALIDATION_PKG.v_check_qty_uom_non_po (
         p_invoice_rec,                     -- IN
         p_invoice_lines_tab(i),               -- IN OUT NOCOPY
         p_default_last_updated_by,          -- IN
         p_default_last_update_login,        -- IN
         p_current_invoice_status   => l_temp_line_status,  -- IN OUT NOCOPY
         p_calling_sequence         => current_calling_sequence) <> TRUE) THEN
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           'v_check_invalid_awt_group<-' ||current_calling_sequence);
     END IF;
     RAISE check_lines_failure;
   END IF;
   --
   -- show output values (only if debug_switch = 'Y')
   --
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
      '------------------> l_temp_line_status = '|| l_temp_line_status);
   END IF;

   --
   IF (l_temp_line_status = 'N') THEN
     l_current_invoice_status := l_temp_line_status;
   END IF;


   --------------------------------------------------------
   -- Step 19
   -- check for AWT group
   ---------------------------------------------------------
   debug_info := '(Check_lines 19) Call v_check_invalid_awt_group';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
     debug_info);
    END IF;

   -- check for invalid AWT group
   IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_line_awt_group(
       p_invoice_rec,                              -- IN
       p_invoice_lines_tab(i),                     -- IN OUT NOCOPY
       p_default_last_updated_by,                -- IN
       p_default_last_update_login,               -- IN
       p_current_invoice_status    => l_temp_line_status, -- IN OUT NOCOPY
       p_calling_sequence          => current_calling_sequence) <> TRUE )THEN
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
       'v_check_invalid_awt_group<-' ||current_calling_sequence);
     END IF;
     RAISE check_lines_failure;
   END IF;
   --
   -- show output values (only if debug_switch = 'Y')
   --
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
       '------------------> l_temp_line_status = '|| l_temp_line_status);
   END IF;
   --
   IF (l_temp_line_status = 'N') THEN
     l_current_invoice_status := l_temp_line_status;
   END IF;

   --bug6639866
   --------------------------------------------------------
   -- Step 19.1
   -- check for pay AWT group
   ---------------------------------------------------------
   debug_info := '(Check_lines 19) Call v_check_invalid_line_pay_awt_g';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
     debug_info);
    END IF;

   -- check for invalid AWT group
   IF (AP_IMPORT_VALIDATION_PKG.v_check_invalid_line_pay_awt_g(
       p_invoice_rec,                              -- IN
       p_invoice_lines_tab(i),                     -- IN OUT NOCOPY
       p_default_last_updated_by,                -- IN
       p_default_last_update_login,               -- IN
       p_current_invoice_status    => l_temp_line_status, -- IN OUT NOCOPY
       p_calling_sequence          => current_calling_sequence) <> TRUE )THEN
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
       'v_check_invalid_pay_awt_group<-' ||current_calling_sequence);
     END IF;
     RAISE check_lines_failure;
   END IF;
   --
   -- show output values (only if debug_switch = 'Y')
   --
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
       '------------------> l_temp_line_status = '|| l_temp_line_status);
   END IF;
   --
   IF (l_temp_line_status = 'N') THEN
     l_current_invoice_status := l_temp_line_status;
   END IF;




   --------------------------------------------------------
   -- Step 20
   -- check for Duplicate Line Num
   -- Retropricing: This check is not needed for PPA's
   ---------------------------------------------------------
   IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN
       debug_info := '(Check_lines 20) Call v_check_duplicate_line_num';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
       END IF;

       IF (AP_IMPORT_VALIDATION_PKG.v_check_duplicate_line_num(
             p_invoice_rec,                          -- IN
             p_invoice_lines_tab(i),                 -- IN OUT NOCOPY
             p_default_last_updated_by,              -- IN
             p_default_last_update_login,            -- IN
             p_current_invoice_status     => l_temp_line_status,-- IN OUT
             p_calling_sequence           => current_calling_sequence)
             <> TRUE )THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'v_check_duplicate_line_num<-' ||current_calling_sequence);
          END IF;
          RAISE check_lines_failure;
       END IF;
       --
       -- show output values (only if debug_switch = 'Y')
       --
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           '------------------> l_temp_line_status = '|| l_temp_line_status);
       END IF;
       --
       IF (l_temp_line_status = 'N') THEN
         l_current_invoice_status := l_temp_line_status;
       ELSE
         IF (p_invoice_lines_tab(i).line_number is NULL) then
           p_invoice_lines_tab(i).line_number := l_max_line_number + 1;
           l_max_line_number := l_max_line_number + 1;
         END IF;
       END IF;
   END IF;

   --------------------------------------------------------
   -- Step 21
   -- check Asset Info
   ---------------------------------------------------------
   debug_info := '(Check_lines 21) Call v_check_asset_info';
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(
       AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
   End if;

   IF (AP_IMPORT_VALIDATION_PKG.v_check_asset_info (
       p_invoice_lines_tab(i),                   -- IN OUT NOCOPY
       p_set_of_books_id,                   -- IN
       P_asset_book_type,                      -- IN  VARCHAR2
       p_default_last_updated_by,               -- IN
       p_default_last_update_login,             -- IN
       p_current_invoice_status   => l_temp_line_status,-- IN OUT NOCOPY
       p_calling_sequence         => current_calling_sequence)
       <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
       'v_check_misc_line_info<-' ||current_calling_sequence);
      END IF;
      RAISE check_lines_failure;
   END IF;
   --
   -- show output values (only if debug_switch = 'Y')
   --
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
      '------------------> l_temp_line_status = '|| l_temp_line_status);
   END IF;

   --
   IF (l_temp_line_status = 'N') THEN
     l_current_invoice_status := l_temp_line_status;
   END IF;


   --------------------------------------------------------
   -- Step 22
   -- check for Misc Line Info
   ---------------------------------------------------------
   debug_info := '(Check_lines 22) Call v_check_misc_line_info';
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
   END IF;

   IF (AP_IMPORT_VALIDATION_PKG.v_check_misc_line_info(
         p_invoice_rec,		            --7599916
         p_invoice_lines_tab(i),            -- IN OUT NOCOPY
         p_default_last_updated_by,         -- IN
         p_default_last_update_login,        -- IN
         p_current_invoice_status    => l_temp_line_status, -- IN OUT NOCOPY
         p_calling_sequence          => current_calling_sequence)
        <> TRUE )THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
         'v_check_misc_line_info<-' ||current_calling_sequence);
      END IF;
      RAISE check_lines_failure;
   END IF;
   --
   -- show output values (only if debug_switch = 'Y')
   --
   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '------------------> l_temp_line_status = '||
        l_temp_line_status);
   END IF;

   --
   IF (l_temp_line_status = 'N') THEN
     l_current_invoice_status := l_temp_line_status;
   END IF;

   --------------------------------------------------------------------------
   -- Step 23
   -- Check for Tax line info.
   -- Retropricing: Tax line would be created by Validation or Calculate Tax
   -------------------------------------------------------------------------
   IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN
       debug_info := '(Check_lines 23) Call v_check_tax_line_info';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
       END IF;

       IF (AP_IMPORT_VALIDATION_PKG.v_check_tax_line_info(
             p_invoice_lines_tab(i),            -- IN OUT NOCOPY
             p_default_last_updated_by,         -- IN
             p_default_last_update_login,       -- IN
             p_current_invoice_status    => l_temp_line_status, -- IN OUT NOCOPY
             p_calling_sequence          => current_calling_sequence)
            <> TRUE )THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'v_check_tax_line_info<-' ||current_calling_sequence);
          END IF;
          RAISE check_lines_failure;
       END IF;
       --
       -- show output values (only if debug_switch = 'Y')
       --
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------> l_temp_line_status = '||
                    l_temp_line_status);
       END IF;

       --
       IF (l_temp_line_status = 'N') THEN
         l_current_invoice_status := l_temp_line_status;
       END IF;
   END IF;

/* Bug 4014019: Commenting the call to jg_globe_flex_val due to build issues.

   --------------------------------------------------------
   -- Step 24
   -- check for Invalid Line Global Flexfield
   ---------------------------------------------------------
   debug_info := '(Check Lines 24) Check for Line Global Flexfield';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                   debug_info);
    END IF;
   jg_globe_flex_val.check_attr_value(
            'APXIIMPT',
            p_invoice_lines_tab(i).global_attribute_category,
            p_invoice_lines_tab(i).global_attribute1,
            p_invoice_lines_tab(i).global_attribute2,
            p_invoice_lines_tab(i).global_attribute3,
            p_invoice_lines_tab(i).global_attribute4,
            p_invoice_lines_tab(i).global_attribute5,
            p_invoice_lines_tab(i).global_attribute6,
            p_invoice_lines_tab(i).global_attribute7,
            p_invoice_lines_tab(i).global_attribute8,
            p_invoice_lines_tab(i).global_attribute9,
            p_invoice_lines_tab(i).global_attribute10,
            p_invoice_lines_tab(i).global_attribute11,
            p_invoice_lines_tab(i).global_attribute12,
            p_invoice_lines_tab(i).global_attribute13,
            p_invoice_lines_tab(i).global_attribute14,
            p_invoice_lines_tab(i).global_attribute15,
            p_invoice_lines_tab(i).global_attribute16,
            p_invoice_lines_tab(i).global_attribute17,
            p_invoice_lines_tab(i).global_attribute18,
            p_invoice_lines_tab(i).global_attribute19,
            p_invoice_lines_tab(i).global_attribute20,
            TO_CHAR(p_set_of_books_id),
            fnd_date.date_to_canonical(p_invoice_rec.invoice_date),
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,   -- Retropricing: global need to modify
            TO_CHAR(p_invoice_lines_tab(i).invoice_line_id),-- the API to handle PPA tables.
            TO_CHAR(p_default_last_updated_by),
            TO_CHAR(p_default_last_update_login),
            current_calling_sequence,
            NULL,NULL,
            p_invoice_lines_tab(i).line_type_lookup_code,
            NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
            NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
            p_current_status => l_temp_line_status);


    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
     'Global Flexfield Lines Processed '|| l_temp_line_status);
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
         '------------------> l_temp_line_status = '||l_temp_line_status);
    END IF;

    IF (l_temp_line_status = 'N') THEN
      l_current_invoice_status := l_temp_line_status;
    END IF;

*/

    --------------------------------------------------------
    -- Step 25
    -- Check proration information for non item lines
    -- Retropricing: The code below won't be executed for PPA
    -- Lines as the prorate_across_flag is N  for RETROITEM
    ---------------------------------------------------------
    debug_info := '(Check Lines 25) Checking the total dist amount to be '
                   ||'prorated';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                   debug_info);
    END IF;

    IF (nvl(p_invoice_lines_tab(i).line_type_lookup_code,'ITEM') <> 'ITEM' AND
        nvl(p_invoice_lines_tab(i).prorate_across_flag,'N') = 'Y')  THEN
      IF (AP_IMPORT_VALIDATION_PKG.v_check_prorate_info (
             p_invoice_rec,                                 -- IN
             p_invoice_lines_tab(i),                        -- IN OUT NOCOPY
             p_default_last_updated_by,                     -- IN
             p_default_last_update_login,                   -- IN
             p_current_invoice_status  =>l_temp_line_status,-- IN OUT NOCOPY
             p_calling_sequence        => current_calling_sequence)
             <> TRUE )THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'v_check_prorate_info<-' ||current_calling_sequence);
        END IF;
        RAISE check_lines_failure;
      END IF;
      --
      -- show output values (only if debug_switch = 'Y')
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           '------------------> l_temp_line_status = '||l_temp_line_status);
      END IF;

      --
      IF (l_temp_line_status = 'N') THEN
        l_current_invoice_status := l_temp_line_status;
      END IF;

    END IF; -- End for line type <> ITEM and prorate = Y

    --------------------------------------------------------
    -- Step 26
    -- Check if retainage account is available if the po shipment
    -- has retainage.
    ---------------------------------------------------------
    IF (p_invoice_lines_tab(i).po_line_location_id IS NOT NULL AND
        nvl(p_invoice_rec.invoice_type_lookup_code, 'STANDARD') <> 'PREPAYMENT') THEN

	debug_info := '(Check Lines 26) Checking for retainage account ';
	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
	END IF;

	IF (AP_IMPORT_VALIDATION_PKG.v_check_line_retainage(
		p_invoice_lines_tab(i),				-- IN OUT
		p_retainage_ccid,
		p_default_last_updated_by,
		p_default_last_update_login,
		p_current_invoice_status => l_temp_line_status, -- IN OUT
		p_calling_sequence       => current_calling_sequence) <> TRUE )THEN

		IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
		    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                                  'v_check_line_retainage<-' ||current_calling_sequence);
		END IF;
		RAISE check_lines_failure;
	END IF;

	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  '------------------> l_temp_line_status = '|| l_temp_line_status);
	END IF;

	IF (l_temp_line_status = 'N') THEN
		l_current_invoice_status := l_temp_line_status;
	END IF;
    END IF;

    -- bug 6989166 start
    --------------------------------------------------------
    -- Step 27
    -- Check valid ship to location code, when ship to
    -- location id is null.
    ---------------------------------------------------------
    IF (p_invoice_lines_tab(i).ship_to_location_code IS NOT NULL AND
		p_invoice_lines_tab(i).ship_to_location_id IS NULL) THEN

	debug_info := '(Check Lines 27) Checking for ship to location code ';
	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
	END IF;

	IF (AP_IMPORT_VALIDATION_PKG.v_check_ship_to_location_code(
		p_invoice_rec,
		p_invoice_lines_tab(i),
		p_default_last_updated_by,
		p_default_last_update_login,
		p_current_invoice_status => l_temp_line_status, -- IN OUT
		p_calling_sequence       => current_calling_sequence) <> TRUE )THEN

		IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
		    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                                  'v_check_ship_to_location_code<-' ||current_calling_sequence);
		END IF;
		RAISE check_lines_failure;
	END IF;

	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  '------------------> ship_to_location_id = '
					  || p_invoice_lines_tab(i).ship_to_location_id);
	END IF;

	IF (l_temp_line_status = 'N') THEN
		l_current_invoice_status := l_temp_line_status;
	END IF;

    END IF;

    -- bug 6989166 end

  END LOOP; -- for lines

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                   debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     SQLERRM);
      END IF;
    END IF;

    IF (invoice_lines%ISOPEN) THEN
       CLOSE invoice_lines;
    END IF;
    RETURN (FALSE);

END v_check_lines_validation;

-----------------------------------------------------------------------------
-- This function is used to validate the precision of a line amount.
--
FUNCTION v_check_invoice_line_amount (
         p_invoice_lines_rec          IN AP_IMPORT_INVOICES_PKG.r_line_info_rec,
         p_precision_inv_curr           IN            NUMBER,
         p_default_last_updated_by      IN            NUMBER,
         p_default_last_update_login    IN            NUMBER,
         p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
         p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN
IS

check_lines_failure        EXCEPTION;
debug_info                 VARCHAR2(250);
current_calling_sequence   VARCHAR2(2000);
l_current_invoice_status   VARCHAR2(1)    :='Y';

BEGIN

  -- Updating the calling sequence
  current_calling_sequence :=
     'AP_IMPORT_VALIDATION_PKG.v_check_invoice_line_amount<-'
     ||P_calling_sequence;

  IF LENGTH((ABS(p_invoice_lines_rec.amount) -
             TRUNC(ABS(p_invoice_lines_rec.amount))))-1  >
     NVL(p_precision_inv_curr,0) THEN

    debug_info :=
      '(Check Invoice Line Amount 1) Lines amount exceeds precision.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
               'LINE AMOUNT EXCEEDS PRECISION',
               p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE check_lines_failure;
    END IF;
    l_current_invoice_status :='N';
  END IF;

  p_current_invoice_status := l_current_invoice_status;

  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_invoice_line_amount;


-----------------------------------------------------------------------------
-- This function is used to validate PO information at line level.
--
FUNCTION v_check_line_po_info (
         p_invoice_rec
           IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_invoice_lines_rec
           IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
         p_set_of_books_id              IN            NUMBER,
         p_positive_price_tolerance     IN            NUMBER,
         p_qty_ord_tolerance            IN            NUMBER,
	 p_amt_ord_tolerance		IN	      NUMBER,
         p_max_qty_ord_tolerance        IN            NUMBER,
	 p_max_amt_ord_tolerance	IN	      NUMBER,
         p_default_last_updated_by      IN            NUMBER,
         p_default_last_update_login    IN            NUMBER,
         p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
         p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN


IS

check_po_failure                   EXCEPTION;
l_po_number                           VARCHAR2(20) := p_invoice_lines_rec.po_number;
l_po_header_id                    NUMBER := p_invoice_lines_rec.po_header_id;
l_po_line_id                    NUMBER := p_invoice_lines_rec.po_line_id;
l_po_release_id                    NUMBER := p_invoice_lines_rec.po_release_id;
l_po_line_location_id            NUMBER := p_invoice_lines_rec.po_line_location_id;
l_po_distribution_id            NUMBER := p_invoice_lines_rec.po_distribution_id;
l_match_option                    VARCHAR2(25);
l_calc_quantity_invoiced        NUMBER;
l_calc_unit_price               NUMBER;
l_po_is_valid_flag                   VARCHAR2(1) := 'N';
l_po_is_consistent_flag         VARCHAR2(1) := 'N';
l_po_line_is_valid_flag            VARCHAR2(1) := 'N';
l_po_line_is_consistent_flag    VARCHAR2(1) := 'N';
l_po_release_is_valid_flag      VARCHAR2(1)    := 'N';
l_po_rel_is_consistent_flag     VARCHAR2(1) := 'N';
l_po_shipment_is_valid_flag     VARCHAR2(1)    := 'N';
l_po_shipment_is_consis_flag    VARCHAR2(1) := 'N';
l_po_dist_is_valid_flag            VARCHAR2(1)    := 'N';
l_po_dist_is_consistent_flag    VARCHAR2(1) := 'N';
l_po_inv_curr_is_consis_flag    VARCHAR2(1)    := 'N';
l_current_invoice_status        VARCHAR2(1) := 'Y';
l_po_is_not_blanket             VARCHAR2(1) := 'N';
l_vendor_id                        NUMBER;
l_purchasing_category_id	AP_INVOICE_LINES_ALL.PURCHASING_CATEGORY_ID%TYPE;
current_calling_sequence         VARCHAR2(2000);
debug_info                       VARCHAR2(500);

-- Contextual Information for XML Gateway
l_po_currency_code              VARCHAR2(15) := '';
l_invoice_vendor_name           po_vendors.vendor_name%TYPE := '';

l_price_correct_inv_id          NUMBER;
l_pc_inv_valid                  VARCHAR2(1);
l_base_match_amount		NUMBER;
l_base_match_quantity		NUMBER;
l_correction_amount		NUMBER;
l_match_basis    		PO_LINE_TYPES.MATCHING_BASIS%TYPE;
l_pc_po_amt_billed              NUMBER;
l_line_amt_calculated           NUMBER;
l_total_amount_invoiced		NUMBER;
l_total_quantity_invoiced	NUMBER;
l_total_amount_billed		NUMBER;
l_total_quantity_billed		NUMBER;
l_correction_dist_amount	NUMBER;
l_shipment_finally_closed	VARCHAR2(1);
l_corrupt_po_distributions      NUMBER;
l_calc_line_amount		NUMBER;
l_accrue_on_receipt_flag        po_line_locations.accrue_on_receipt_flag%TYPE;
l_temp_match_option             VARCHAR2(25); --Bug5225547
l_item_description              VARCHAR2(240); --Bug8546486

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_line_po_info<-'
    ||P_calling_sequence;

IF (nvl(p_invoice_lines_rec.line_type_lookup_code, 'ITEM' )
         IN ('ITEM','RETROITEM')) THEN
  -----------------------------------------------------------
  -- Case 1.0,  Default PO Number from Invoice Header if
  -- po_header_id and po_number are null
  -----------------------------------------------------------
  IF ((l_po_header_id IS NULL) and
      (p_invoice_lines_rec.po_number IS NULL) and
      (p_invoice_rec.po_number is NOT NULL)) THEN
    --
    debug_info := '(v_check_line_po_info 1) Default PO Number from invoice '
                  ||'header and get l_po_header_id';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;
    --

    BEGIN
      SELECT 'Y', po_header_id
        INTO l_po_is_valid_flag, l_po_header_id
        FROM po_headers
       WHERE segment1 = p_invoice_rec.po_number
    AND type_lookup_code in ('BLANKET', 'PLANNED', 'STANDARD')
    /* BUG 2902452 added*/
    AND nvl(authorization_status,'INCOMPLETE') in ('APPROVED','REQUIRES REAPPROVAL','IN PROCESS');--Bug5687122 --Added In Process condition

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po number is invalid
        -- set contextual information for XML GATEWAY
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                               (AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                                p_invoice_lines_rec.invoice_line_id,
                                'INVALID PO NUM',
                                p_default_last_updated_by,
                                p_default_last_update_login,
                                current_calling_sequence,
                                'Y',
                                'PO NUMBER',
                                p_invoice_rec.po_number) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;

        END IF;
        l_current_invoice_status := 'N';
    END;

  END IF;

  -----------------------------------------------------------
  -- Case 1.1,  Reject if po_header_id is invalid
  -----------------------------------------------------------
  IF (l_po_header_id IS NOT NULL) THEN
      --
    BEGIN
      debug_info := '(v_check_line_po_info 1) Validate po_header_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y'
        INTO l_po_is_valid_flag
        FROM po_headers ph
       WHERE ph.po_header_id = l_po_header_id
       AND ph.type_lookup_code in ('BLANKET', 'PLANNED', 'STANDARD')
      /* BUG 2902452 added */
       AND nvl(authorization_status,'INCOMPLETE') in ('APPROVED','REQUIRES REAPPROVAL','IN PROCESS');--Bug5687122 --Added In Process condition

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po header id is invalid
        -- set  contextual information for XML GATEWAY
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                               (AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                                p_invoice_lines_rec.invoice_line_id,
                                'INVALID PO NUM',
                                p_default_last_updated_by,
                                p_default_last_update_login,
                                current_calling_sequence,
                                'Y',
                                'PO NUMBER',
                                p_invoice_lines_rec.po_number) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;

        l_current_invoice_status := 'N';
    END;

  END IF;
  -----------------------------------------------------------
  -- Case 1.2,  Reject if po_number is missing
  -- Bug  7366317 Additional Check for XML Gateway Invoices
  -- If Doc type is 'PurchaseOrder' and no PO Info is provided
  -- Throw the 'Missing PO NUM' Rejection
  -----------------------------------------------------------

   IF (p_invoice_rec.SOURCE= 'XML GATEWAY' AND
       UPPER(p_invoice_lines_rec.reference_1) = 'PURCHASEORDER' AND
       p_invoice_lines_rec.po_number IS NULL) THEN
         BEGIN
       -- po number is missing
       -- set  contextual information for XML GATEWAY
       IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
            (AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
             p_invoice_lines_rec.invoice_line_id,
             'MISSING PO NUM',
             p_default_last_updated_by,
             p_default_last_update_login,
             current_calling_sequence,
             'Y',
             'LINE NUMBER',
             p_invoice_lines_rec.line_number) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
       END IF;
       l_current_invoice_status := 'N';
     END;
   END IF;

  -----------------------------------------------------------
  -- Case 2, Reject if po_number is invalid
  -----------------------------------------------------------
  IF ((p_invoice_lines_rec.po_number IS NOT NULL) AND
      (l_po_header_id IS NULL)) THEN
      --
    BEGIN
      debug_info := '(v_check_line_po_info 2) Validate po_number';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y', ph.po_header_id
        INTO l_po_is_valid_flag, l_po_header_id
        FROM po_headers ph
       WHERE segment1 = p_invoice_lines_rec.po_number
         AND type_lookup_code in ('BLANKET', 'PLANNED', 'STANDARD')
      /*BUG 2902452 added*/
      AND nvl(authorization_status,'INCOMPLETE') in ('APPROVED','REQUIRES REAPPROVAL','IN PROCESS');--Bug5687122 --Added In Process condition

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po number is invalid
        -- set contextual information for XML GATEWAY
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
                               (AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                                p_invoice_lines_rec.invoice_line_id,
                                'INVALID PO NUM',
                                p_default_last_updated_by,
                                p_default_last_update_login,
                                current_calling_sequence,
                                'Y',
                                'PO NUMBER',
                                p_invoice_lines_rec.po_number) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;

        l_current_invoice_status := 'N';
    END;

  END IF;

  ---------------------------------------------------------------------------
  -- Case 3, Reject if po_header_id and po_number is inconsistent
  ---------------------------------------------------------------------------
  IF ((l_po_header_id IS NOT NULL) AND
      (p_invoice_lines_rec.po_number IS NOT NULL)) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 3) Check inconsistence for '
                    ||'po_number and po_header_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y'
        INTO l_po_is_consistent_flag
        FROM po_headers ph
       WHERE segment1 = p_invoice_lines_rec.po_number
         AND po_header_id = l_po_header_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po number is inconsistent
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
              (AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
               'INCONSISTENT PO INFO',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
         RAISE check_po_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
    END;

  END IF;

  -----------------------------------------------------------
  -- Case 4,  Reject if po_line_id is invalid
  -----------------------------------------------------------
  IF (l_po_line_id IS NOT NULL) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 4) Validate po_line_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y'
        INTO l_po_line_is_valid_flag
        FROM po_lines
       WHERE po_line_id = l_po_line_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po line id is invalid
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID PO LINE NUM',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
         RAISE check_po_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
    END;

  END IF;

  ------------------------------------------------------------
  -- Case 5, Reject if po_line_number is invalid
  ------------------------------------------------------------
  IF ((p_invoice_lines_rec.po_line_number IS NOT NULL) AND
      (l_po_line_id IS NULL) AND
      (l_po_header_id IS NOT NULL)) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 5) Validate po_line_number';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      --
      SELECT 'Y', po_line_id
        INTO l_po_line_is_valid_flag, l_po_line_id
        FROM po_lines
       WHERE line_num = p_invoice_lines_rec.po_line_number
         AND po_header_id = l_po_header_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po line number is invalid
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID PO LINE NUM',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
         RAISE check_po_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
    END;

  END IF;

  ---------------------------------------------------------------------------
  -- Case 6, Reject if po_line_id and po_line_number is inconsistent
  ---------------------------------------------------------------------------
  IF ((l_po_line_id IS NOT NULL) AND
      (p_invoice_lines_rec.po_line_number IS NOT NULL)) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 6) Check inconsistence for '
                    ||'po_line_number and po_line_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y'
        INTO l_po_line_is_consistent_flag
        FROM po_lines
       WHERE line_num = p_invoice_lines_rec.po_line_number
         AND po_line_id = l_po_line_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po number is inconsistent
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INCONSISTENT PO LINE INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
         RAISE check_po_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
    END;

  END IF;

  -----------------------------------------------------------
  -- Case 7,  Reject if po_release_id is invalid
  -----------------------------------------------------------
  IF (l_po_release_id IS NOT NULL) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 7) Validate po_release_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      --
      SELECT 'Y'
        INTO l_po_release_is_valid_flag
        FROM po_releases
       WHERE po_release_id = l_po_release_id
       /* For bug 4038403. Added by lgopalsa
          Need to validate the lines for matching */
       and nvl(authorization_status, 'INCOMPLETE') in ('APPROVED',
                                                       'REQUIRES REAPPROVAL','IN PROCESS');--Bug5687122 --Added In Process condition

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         -- po release id is invalid
         -- set contextual information for XML GATEWAY
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INVALID PO RELEASE NUM',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence) <> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<-'||current_calling_sequence);
           END IF;
           RAISE check_po_failure;
         END IF;

         l_current_invoice_status := 'N';
    END;

  END IF;

  ------------------------------------------------------------
  -- Case 8, Reject if po_release_num is invalid
  ------------------------------------------------------------
  IF ((p_invoice_lines_rec.release_num IS NOT NULL) AND
      (l_po_release_id IS NULL) AND
      (l_po_header_id IS NOT NULL)) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 8) Validate po_release_num';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y',
         po_release_id
        INTO l_po_release_is_valid_flag,
         l_po_release_id
        FROM po_releases
       WHERE release_num = p_invoice_lines_rec.release_num
         AND po_header_id = l_po_header_id
       /* For bug 4038403
          Need to validate the lines for matching */
       and nvl(authorization_status, 'INCOMPLETE') in ('APPROVED',
                                                       'REQUIRES REAPPROVAL','IN PROCESS');--Bug5687122 --Added In Process condition

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po release number is invalid
        -- Set contextual information for XML GATEWAY
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INVALID PO RELEASE NUM',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'PO RELEASE NUMBER',
                        p_invoice_lines_rec.release_num) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;

        l_current_invoice_status := 'N';
    END;

  END IF;


  ---------------------------------------------------------------------------
  -- Case 9, Reject if po_release_id and release_num is inconsistent
  ---------------------------------------------------------------------------
  IF ((l_po_release_id IS NOT NULL) AND
      (p_invoice_lines_rec.release_num IS NOT NULL)) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 9) Check inconsistence for '
                    ||'release_num and po_release_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y'
        INTO l_po_rel_is_consistent_flag
        FROM po_releases
       WHERE release_num = p_invoice_lines_rec.release_num
         AND po_release_id = l_po_release_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po release information is inconsistent
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INCONSISTENT RELEASE INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
           RAISE check_po_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
    END;
  END IF;

  ---------------------------------------------------------------------------
  -- Case 10, Reject if po_release_id and po_line_id is inconsistent
  ---------------------------------------------------------------------------
  IF ((l_po_release_id IS NOT NULL) AND
      (l_po_line_id IS NOT NULL)) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 10) Check inconsistence for '
                    ||'po_line_id and po_release_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y'
        INTO l_po_rel_is_consistent_flag
        FROM po_line_locations
       WHERE po_line_id = l_po_line_id
         AND po_release_id = l_po_release_id
      /*Bug 2787396 we need to validate the shipment level for matching */
         AND nvl(approved_flag, 'N' ) = 'Y'
         AND rownum <=1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po release/line is inconsistent
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INCONSISTENT RELEASE INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
         RAISE check_po_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
    END;
  END IF;

  ---------------------------------------------------------------------------
  -- Case 10.1, Reject if po_release has more than 1 line no line info is given
  ---------------------------------------------------------------------------
  IF ((l_po_release_id IS NOT NULL) AND
      (l_po_line_id IS NULL)) THEN
    --
    BEGIN
      debug_info :=
        '(v_check_line_po_info 10.1) Check lines for po_release_id ';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT DISTINCT po_line_id
        INTO l_po_line_id
        FROM po_line_locations
       WHERE po_release_id = l_po_release_id
      /* For bug 4038403
         we should check at line location level approved flag
         as we can do invoicing for the line/shipment for which
         receipt is allowed and the document is already
         undergone approval. */
         AND approved_flag ='Y'
      /* Bug 9853166 no rejection necessary when shipment_num has
         been specified and it will differentiate the lines */
         AND nvl(shipment_num, -99) = coalesce(p_invoice_lines_rec.po_shipment_num
                                          , shipment_num, -99);



    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po release/line is inconsistent
        -- set contextual information for XML GATEWAY
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INVALID PO RELEASE INFO',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'PO RELEASE NUMBER',
                        p_invoice_lines_rec.release_num,
                        'PO SHIPMENT NUMBER',
                        p_invoice_lines_rec.po_shipment_num,
                        'PO LINE NUMBER',
                        p_invoice_lines_rec.po_line_number) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;

        l_current_invoice_status := 'N';

      WHEN TOO_MANY_ROWS THEN
        -- po release
        IF ((p_invoice_lines_rec.po_line_number IS NULL)      AND
            (p_invoice_lines_rec.inventory_item_id IS NULL)   AND
            (p_invoice_lines_rec.vendor_item_num IS NULL)     AND
            (p_invoice_lines_rec.item_description IS NULL)    AND
            (l_po_line_location_id IS NULL) AND
            (l_po_distribution_id IS NULL)) THEN

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'CAN MATCH TO ONLY 1 LINE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE check_po_failure;
          END IF;

          l_current_invoice_status := 'N';
        END IF;

    END;

  END IF;

--case 10.2 added for bug 4525041
 ---------------------------------------------------------------------------
  -- Case 10.2, Reject if release_num and po_line_number is inconsistent
 ---------------------------------------------------------------------------
  IF ((p_invoice_lines_rec.release_num IS NOT NULL) AND (p_invoice_lines_rec.po_line_number IS NOT NULL)
       AND (l_po_header_id is not null OR p_invoice_lines_rec.po_number is not null)) THEN

      BEGIN
      debug_info :=
      '(v_check_line_po_info 10.2) Check lines for po_release_id ';
      /* For bug 4038403
        Removed the 'STANDARD' from the condition  from both
         the queries as there is no need to validate the release
         details for standard PO */

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
     End if;

      IF l_po_header_id IS NOT NULL THEN -- Fix for 2809177
        SELECT 'Y'
          INTO l_po_rel_is_consistent_flag
          FROM po_line_locations
          WHERE po_line_id = (
                select po_line_id
                  from po_lines pol, po_headers poh
                where poh.po_header_id = pol.po_header_id
                  -- and poh.po_header_id = nvl(l_po_header_id, poh.po_header_id)
                  -- fix for bug 2809177 commented above line and wrote the below one
                  and poh.po_header_id = l_po_header_id
                  -- Commented below line as a fix for bug 2809177
                  -- and poh.segment1 = nvl(p_invoice_lines_rec.po_number, poh.segment1)
                  and poh.type_lookup_code in ('BLANKET', 'PLANNED') --, 'STANDARD')
                  and pol.po_line_id = nvl(l_po_line_id, pol.po_line_id)
                  and pol.line_num = p_invoice_lines_rec.po_line_number )
            AND po_release_id = (
                select po_release_id
                  from po_releases por, po_headers poh
                where poh.po_header_id = por.po_header_id
                  -- and poh.po_header_id = nvl(l_po_header_id, poh.po_header_id)
                  -- fix for bug 2809177 commented above line and wrote the below one
                  and poh.po_header_id = l_po_header_id
                  -- Commented below line as a fix for bug 2809177
                  -- and poh.segment1 = nvl(p_invoice_lines_rec.po_number, poh.segment1)
                  and poh.type_lookup_code in ('BLANKET', 'PLANNED')--, 'STANDARD')
                  and por.po_header_id = l_po_header_id  -- Added as a fix for bug 2809177
                  and por.release_num = p_invoice_lines_rec.release_num )
            AND rownum <=1;
      ELSIF p_invoice_lines_rec.po_number IS NOT NULL THEN
        SELECT 'Y'
          INTO l_po_rel_is_consistent_flag
          FROM po_line_locations
          WHERE po_line_id = (
                select po_line_id
                  from po_lines pol, po_headers poh
                where poh.po_header_id = pol.po_header_id
                  -- and poh.po_header_id = nvl(l_po_header_id, poh.po_header_id)
                  -- and poh.segment1 = nvl(p_invoice_lines_rec.po_number, poh.segment1)
                  -- fix for bug 2809177 commented above two lines and wrote the below one
                  and poh.segment1 = p_invoice_lines_rec.po_number
                  and poh.type_lookup_code in ('BLANKET', 'PLANNED', 'STANDARD')
                  and pol.po_line_id = nvl(l_po_line_id, pol.po_line_id)
                  and pol.line_num = p_invoice_lines_rec.po_line_number )
            AND po_release_id = (
                select po_release_id
                  from po_releases por, po_headers poh
                where poh.po_header_id = por.po_header_id
                  -- and poh.po_header_id = nvl(l_po_header_id, poh.po_header_id)
                  -- and poh.segment1 = nvl(p_invoice_lines_rec.po_number, poh.segment1)
                  -- fix for bug 2809177 commented above two line and wrote the below one
                  and poh.segment1 = p_invoice_lines_rec.po_number
                  and poh.type_lookup_code in ('BLANKET', 'PLANNED', 'STANDARD')
                  and por.release_num = p_invoice_lines_rec.release_num )
            AND rownum <=1;
      END IF ;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
          -- po release/line is inconsistent
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INCONSISTENT RELEASE INFO',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence
                        ) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
END IF;
      END;
END IF;
  ------------------------------------------------------------
  -- Case 11, Reject if p_inventory_item_id is invalid
  ------------------------------------------------------------
  IF ((p_invoice_lines_rec.inventory_item_id IS NOT NULL) AND
      (l_po_line_id IS NULL) AND
      (l_po_release_id IS NULL) AND
      (l_po_header_id IS NOT NULL)) THEN
    --
    BEGIN
      debug_info :=
        '(v_check_line_po_info 11) Validate p_inventory_item_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y', po_line_id
        INTO l_po_is_valid_flag, l_po_line_id
        FROM po_lines
       WHERE item_id = p_invoice_lines_rec.inventory_item_id
         AND po_header_id = l_po_header_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po item id is invalid
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID ITEM',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
           RAISE check_po_failure;
        END IF;
        --
        l_current_invoice_status := 'N';

      WHEN TOO_MANY_ROWS Then
        IF ((l_po_line_id    IS NULL) AND
            (p_invoice_lines_rec.po_line_number IS NULL) AND
            (l_po_line_location_id IS NULL) AND
            (l_po_distribution_id IS NULL)) Then
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                 p_invoice_lines_rec.invoice_line_id,
                'CAN MATCH TO ONLY 1 LINE',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE check_po_failure;
          END IF;

          l_current_invoice_status := 'N';

        END IF;
    END;
  END IF;

  -----------------------------------------------------------------------
  -- Case 11.5, Reject if p_vendor_item_num is invalid -- Bug 1873251
  -- changed (p_po_line_id is NULL) to (l_po_line_id is NULL) Bug 2642098
  -----------------------------------------------------------------------
  IF ((p_invoice_lines_rec.vendor_item_num IS NOT NULL) AND
      (l_po_line_id IS NULL) AND
      (l_po_release_id IS NULL) AND
      (l_po_header_id IS NOT NULL)) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 11.5) Validate p_vendor_item_num';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y', po_line_id
        INTO l_po_is_valid_flag, l_po_line_id
        FROM po_lines
       WHERE vendor_product_num = p_invoice_lines_rec.vendor_item_num
         AND po_header_id = l_po_header_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po item id is invalid
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                       AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INVALID ITEM',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'SUPPLIER ITEM NUMBER',
                        p_invoice_lines_rec.vendor_item_num ) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;

        l_current_invoice_status := 'N';

      WHEN TOO_MANY_ROWS THEN
        IF ((l_po_line_id    IS NULL)         AND
            (p_invoice_lines_rec.po_line_number IS NULL)      AND
        (l_po_line_location_id IS NULL) AND
            (l_po_distribution_id IS NULL)) THEN

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                 p_invoice_lines_rec.invoice_line_id,
                 'CAN MATCH TO ONLY 1 LINE',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                  current_calling_sequence,
                 'Y',
                 'SUPPLIER ITEM NUMBER',
                 p_invoice_lines_rec.vendor_item_num ) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE check_po_failure;
          END IF;

          l_current_invoice_status := 'N';

        END IF;
    END;
  END IF;

  ---------------------------------------------------------------------------
  -- Case 12, Reject if p_item_description is invalid
  -- changed (p_po_line_id is NULL) to (l_po_line_id is NULL) Bug 2642098
  ---------------------------------------------------------------------------
  IF ((p_invoice_lines_rec.item_description IS NOT NULL) AND
      (l_po_line_id IS NULL) AND
      (l_po_release_id IS NULL) AND
      (l_po_header_id IS NOT NULL)) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 12) Validate p_item_description';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y', po_line_id
        INTO l_po_is_valid_flag, l_po_line_id
        FROM po_lines
       WHERE item_description like p_invoice_lines_rec.item_description
         AND po_header_id = l_po_header_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po item id is invalid
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID ITEM',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
           RAISE check_po_failure;
        END IF;
        l_current_invoice_status := 'N';

      WHEN TOO_MANY_ROWS Then

        IF ((l_po_line_id    IS NULL)     AND
        (p_invoice_lines_rec.po_line_number IS NULL)    AND
        (l_po_line_location_id IS NULL) AND
        (l_po_distribution_id IS NULL)) THEN

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                 p_invoice_lines_rec.invoice_line_id,
                'CAN MATCH TO ONLY 1 LINE',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE check_po_failure;
          END IF;

          l_current_invoice_status := 'N';

        END IF;

    END;

  END IF;

  ---------------------------------------------------------------------------
  -- Case 13, Reject if po_inventory_item_id, p_vendor_item_num
  --                          and po_item_description are inconsistent
  --
  --  Added consistency check for Supplier Item Number too as part of
  --  the effort to support Supplier Item Number in Invoice Import
  --                                                         bug 1873251
  ---------------------------------------------------------------------------

  IF ((p_invoice_lines_rec.inventory_item_id IS NOT NULL) AND
      (p_invoice_lines_rec.vendor_item_num IS NOT NULL) AND
      (l_po_header_id IS NOT NULL)) THEN
      --
     BEGIN
      debug_info := '(v_check_line_po_info 13.1) Check inconsistency for '
                    ||'po_inventory_item_id and po_vendor_item_num';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y'
        INTO l_po_line_is_consistent_flag
        FROM po_lines
       WHERE item_id = p_invoice_lines_rec.inventory_item_id
         AND vendor_product_num = p_invoice_lines_rec.vendor_item_num
         AND po_header_id = l_po_header_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        -- po line information is inconsistent
        -- bug 2581097 added contextual information for XML GATEWAY
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INCONSISTENT PO LINE INFO',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'SUPPLIER ITEM NUMBER',
                        p_invoice_lines_rec.vendor_item_num ) <> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<-'||current_calling_sequence);
           END IF;
           RAISE check_po_failure;
         END IF;

         l_current_invoice_status := 'N';

       WHEN TOO_MANY_ROWS Then

              IF ((l_po_line_id    IS NULL)          AND
              (p_invoice_lines_rec.po_line_number IS NULL)      AND
              (l_po_line_location_id IS NULL) AND
              (l_po_distribution_id IS NULL)) THEN

                  -- bug 2581097 added contextual information for XML GATEWAY

                  IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'CAN MATCH TO ONLY 1 LINE',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'SUPPLIER ITEM NUMBER',
                        p_invoice_lines_rec.vendor_item_num ) <> TRUE) THEN

                    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
                    END IF;
                    RAISE check_po_failure;
                  END IF;

                l_current_invoice_status := 'N';

              END IF;
     END;

  ELSIF ((p_invoice_lines_rec.inventory_item_id IS NOT NULL) AND
         (p_invoice_lines_rec.item_description IS NOT NULL)  AND
         (l_po_header_id IS NOT NULL))     THEN
      --
     BEGIN
      debug_info := '(v_check_line_po_info 13.2) Check inconsistency for '
                    ||'po_inventory_item_id and po_item_description'||l_po_line_location_id;
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      /* Added the code for Bug#10026073 Start */
      IF l_po_line_location_id IS NOT NULL
      THEN
        SELECT 'Y'
          INTO l_po_line_is_consistent_flag
          FROM po_lines pl
             , po_line_locations pll
         WHERE pl.item_id = p_invoice_lines_rec.inventory_item_id
           AND nvl(pll.description, pl.item_description) like p_invoice_lines_rec.item_description
           AND pl.po_header_id      = pll.po_header_id
           AND pll.po_header_id     = l_po_header_id
           AND pll.line_location_id = l_po_line_location_id;

      ELSE
        SELECT 'Y'
          INTO l_po_line_is_consistent_flag
          FROM po_lines
         WHERE item_id = p_invoice_lines_rec.inventory_item_id
           AND item_description like p_invoice_lines_rec.item_description
           AND po_header_id = l_po_header_id;
      END IF;
      /* Added the code for Bug#10026073 End */
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         -- po line information is inconsistent
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INCONSISTENT PO LINE INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN

       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'insert_rejections<-'||current_calling_sequence);
           END IF;
           RAISE check_po_failure;
         END IF;
         l_current_invoice_status := 'N';

        WHEN TOO_MANY_ROWS Then

          IF ((l_po_line_id    IS NULL) AND
              (p_invoice_lines_rec.po_line_number IS NULL) AND
          (l_po_line_location_id IS NULL) AND
          (l_po_distribution_id IS NULL)) Then

             IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                  AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                       p_invoice_lines_rec.invoice_line_id,
                      'CAN MATCH TO ONLY 1 LINE',
                       p_default_last_updated_by,
                       p_default_last_update_login,
                       current_calling_sequence) <> TRUE) THEN

             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                  AP_IMPORT_UTILITIES_PKG.Print(
                           AP_IMPORT_INVOICES_PKG.g_debug_switch,
                          'insert_rejections<-'||current_calling_sequence);
                END IF;
          RAISE check_po_failure;
              END IF;

              l_current_invoice_status := 'N';

            END IF;
     END;

  END IF;

  ---------------------------------------------------------------------------
  -- Case 14, Reject if po_line_id and p_inventory_item_id are inconsistent
  ---------------------------------------------------------------------------

  IF ((l_po_line_id IS NOT NULL) AND
      (p_invoice_lines_rec.inventory_item_id IS NOT NULL)) THEN
      --
     BEGIN
       debug_info := '(v_check_line_po_info 14) Check inconsistency for '
                     ||'po_line_id and po_inventory_item_id';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
       END IF;
       --
       --
       SELECT 'Y'
       INTO l_po_line_is_consistent_flag
     FROM po_lines
        WHERE item_id = p_invoice_lines_rec.inventory_item_id
      AND po_line_id = l_po_line_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         -- po line information is inconsistent
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
             p_invoice_lines_rec.invoice_line_id,
            'INCONSISTENT PO LINE INFO',
             p_default_last_updated_by,
             p_default_last_update_login,
             current_calling_sequence) <> TRUE) THEN

       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
           END IF;
           RAISE check_po_failure;
         END IF;
         --
         l_current_invoice_status := 'N';
     END;

  END IF;

  ---------------------------------------------------------------------------
  -- Case 15, Reject if po_line_id and p_vendor_item_num are inconsistent
  --      Support for Supplier Item Number     , bug 1873251
  ---------------------------------------------------------------------------

  IF ((l_po_line_id IS NOT NULL) AND
      (p_invoice_lines_rec.vendor_item_num IS NOT NULL)) THEN
      --
     BEGIN
       debug_info := '(v_check_line_po_info 15) Check inconsistency for '
                     ||'po_line_id and po_vendor_item_num';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
       END IF;

       --
       SELECT 'Y'
           INTO l_po_line_is_consistent_flag
         FROM po_lines
        WHERE vendor_product_num = p_invoice_lines_rec.vendor_item_num
          AND po_line_id = l_po_line_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         -- po line information is inconsistent
         -- bug 2581097 added contextual information for XML GATEWAY
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INCONSISTENT PO LINE INFO',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'SUPPLIER ITEM NUMBER',
                        p_invoice_lines_rec.vendor_item_num ) <> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
           END IF;
           RAISE check_po_failure;
         END IF;

         l_current_invoice_status := 'N';
     END;

  END IF;

  ---------------------------------------------------------------------------
  -- Case 15.1, Reject if po_line_id and vendor_item_num are inconsistent
  --      Support for Supplier Item Number
  -- Amount Based Matching - Line should be rejected if Supplier item  No is
  -- supplied for service order line. However due to complex work project
  -- match basis will be moved at po shipment level hence all the matching
  -- basis related validation  will moved to shipment level.
  ---------------------------------------------------------------------------

  IF ((p_invoice_lines_rec.po_line_number IS NOT NULL) AND
      (p_invoice_lines_rec.vendor_item_num IS NOT NULL) AND
      (l_po_header_id IS NOT NULL)) THEN
      --
     BEGIN
       debug_info := '(v_check_line_po_info 15.1) Check inconsistency for '
                     ||'po_line_number and po_vendor_item_num';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
       END IF;

       --
       SELECT 'Y'
       INTO l_po_line_is_consistent_flag
       FROM po_lines pl
      WHERE pl.line_num = p_invoice_lines_rec.po_line_number
        AND vendor_product_num = p_invoice_lines_rec.vendor_item_num
        AND pl.po_header_id = l_po_header_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         -- po line information is inconsistent
         -- bug 2581097 added contextual information for XML GATEWAY
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INCONSISTENT PO LINE INFO',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'SUPPLIER ITEM NUMBER',
                        p_invoice_lines_rec.vendor_item_num ) <> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
           END IF;
           RAISE check_po_failure;
         END IF;

         l_current_invoice_status := 'N';
     END;

  END IF;

  ---------------------------------------------------------------------------
  -- Case 15.2, Reject if po_line_id and vendor_item_num are inconsistent
  --      Support for Supplier Item Number
  -- Amount Based Matching - Line should be rejected if inventory item  No is
  -- supplied for service order line. However due to complex work project
  -- match basis will be moved at po shipment level hence all the matching
  -- basis related validation  will moved to shipment level.
  ---------------------------------------------------------------------------

  IF ((p_invoice_lines_rec.po_line_number IS NOT NULL) AND
      (p_invoice_lines_rec.inventory_item_id IS NOT NULL) AND
      (l_po_header_id IS NOT NULL)) THEN
      --
     BEGIN
       debug_info := '(v_check_line_po_info 15.1) Check inconsistency for '
                     ||'po_line_number and inventory_item_id';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
       END IF;

       --
       SELECT 'Y'
       INTO l_po_line_is_consistent_flag
       FROM po_lines pl
      WHERE pl.line_num = p_invoice_lines_rec.po_line_number
        -- Bug 6734046 changed vendor_product_num to item_id
        AND pl.item_id = p_invoice_lines_rec.inventory_item_id
        AND pl.po_header_id = l_po_header_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         -- po line information is inconsistent
         -- bug 2581097 added contextual information for XML GATEWAYi
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
             p_invoice_lines_rec.invoice_line_id,
            'INCONSISTENT PO LINE INFO',
             p_default_last_updated_by,
             p_default_last_update_login,
             current_calling_sequence) <> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
           END IF;
           RAISE check_po_failure;
         END IF;

         l_current_invoice_status := 'N';
     END;

  END IF;

/* Start changes for CLM project bug9503239*/
 ---------------------------------------------------------
 -- Case 15.3, Reject if po_line is only information line
 -- for CLM PO's
 ----------------------------------------------------------

IF ((ap_clm_pvt_pkg.is_clm_installed ='Y' ) and (l_po_header_id is not null )) THEN

 IF(ap_clm_pvt_pkg.is_clm_po(p_po_header_id => l_po_header_id) = 'Y')THEN
---------------------------------------------------------
-- Reject if po_line is only information line for CLM PO's
-- and po_line_num is provided.
---------------------------------------------------------
   IF (p_invoice_lines_rec.po_line_number IS NOT NULL) THEN
      BEGIN
       debug_info := '(v_check_line_po_info 15.3) Check whether PO line is information line'
                         ||p_invoice_lines_rec.po_line_number;
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
           END IF;

           SELECT 'Y'
           INTO l_po_line_is_consistent_flag
           FROM po_lines_trx_v pltv,
                po_lines pl
           WHERE pl.line_num = p_invoice_lines_rec.po_line_number
           AND pl.po_line_id = pltv.po_line_id
           AND pl.po_header_id = l_po_header_id;
      EXCEPTION
       WHEN NO_DATA_FOUND THEN
         -- po line is information line
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
             AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
             p_invoice_lines_rec.invoice_line_id,
             'INVALID PO LINE NUM',
             p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN

           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        'insert_rejections<-' ||current_calling_sequence);
           END IF;
          RAISE check_po_failure;
        END IF;
         l_current_invoice_status := 'N';
      END;
   END IF;

---------------------------------------------------------
-- Reject if po_line is only information line for CLM PO's
-- and po_line_id is provided
----------------------------------------------------------
   IF (l_po_line_id IS NOT NULL ) THEN
       BEGIN
          debug_info := '(v_check_line_po_info 15.3) Check whether PO line is information line '
                                        ||p_invoice_lines_rec.po_line_number;
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

           SELECT 'Y'
           INTO l_po_line_is_consistent_flag
           FROM po_lines_trx_v
           WHERE po_line_id = l_po_line_id
           AND po_header_id = l_po_header_id;
       EXCEPTION
       	WHEN NO_DATA_FOUND THEN
          -- po line is information line
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                                 AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                                 p_invoice_lines_rec.invoice_line_id,
                                 'INVALID PO LINE NUM',
                                 p_default_last_updated_by,
                                 p_default_last_update_login,
                                 current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
               AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                          'insert_rejections<-'||current_calling_sequence);
            END IF;
           RAISE check_po_failure;
          END IF;
       l_current_invoice_status := 'N';
       END;
      END IF;
  END IF;
END IF;

/* End changes for CLM project bug9503239 */

  -----------------------------------------------------------
  -- Case 16,  Reject if po_line_location_id is invalid
  -----------------------------------------------------------

  IF (l_po_line_location_id IS NOT NULL ) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 16) Validate po_line_location_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y'
        INTO l_po_shipment_is_valid_flag
        FROM po_line_locations
       WHERE line_location_id = l_po_line_location_id
       /* For bug 4038403
             Need to check the validation for
             line location approved_flag */
         and approved_flag ='Y';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po line location id is invalid
        -- bug 2581097 added contextual information for XML GATEWAY
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                 AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                  p_invoice_lines_rec.invoice_line_id,
                 'INVALID PO SHIPMENT NUM',
                  p_default_last_updated_by,
                  p_default_last_update_login,
                  current_calling_sequence,
                 'Y',
                 'PO SHIPMENT NUMBER',
                  p_invoice_lines_rec.po_shipment_num) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;

      l_current_invoice_status := 'N';
    END;

  END IF;


  ------------------------------------------------------------
  -- Case 17, Reject if po_shipment_num is invalid
  ------------------------------------------------------------

  IF ((p_invoice_lines_rec.po_shipment_num IS NOT NULL) AND
      (l_po_line_location_id IS NULL) AND
      (l_po_header_id IS NOT NULL)    AND
      (l_po_line_id IS NOT NULL)      AND
      (l_po_release_id IS NULL))     THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 17) Validate po_shipment_num';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --

      SELECT 'Y', line_location_id
         INTO l_po_shipment_is_valid_flag, l_po_line_location_id
        FROM po_line_locations
       WHERE shipment_num = p_invoice_lines_rec.po_shipment_num
         AND po_header_id = l_po_header_id
         AND po_line_id = l_po_line_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po shipment number is invalid
        -- bug 2581097 added contextual information for XML GATEWAY
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INVALID PO SHIPMENT NUM',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'PO SHIPMENT NUMBER',
                        p_invoice_lines_rec.po_shipment_num) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;

        l_current_invoice_status := 'N';
      WHEN TOO_MANY_ROWS THEN
        -- po release info is required
        -- bug 2581097 added contextual information for XML GATEWAY
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INVALID PO RELEASE INFO',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'PO RELEASE NUMBER',
                        p_invoice_lines_rec.release_num,
                        'PO SHIPMENT NUMBER',
                        p_invoice_lines_rec.po_shipment_num,
                        'PO LINE NUMBER',
                        p_invoice_lines_rec.po_line_number ) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;
        l_current_invoice_status := 'N';
    END;

  END IF;


  ------------------------------------------------------------
  -- Case 18, Reject if p_ship_to_location_code is invalid
  ------------------------------------------------------------

  IF ((p_invoice_lines_rec.ship_to_location_code IS NOT NULL) AND
      (l_po_line_location_id IS NULL) AND
      (l_po_header_id IS NOT NULL) AND
      (l_po_line_id IS NOT NULL) AND
      (l_po_release_id IS NULL)) THEN
      --
    BEGIN
     debug_info := '(v_check_line_po_info 18) Validate p_ship_to_location_code';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --

      SELECT 'Y', line_location_id
         INTO l_po_shipment_is_valid_flag, l_po_line_location_id
        FROM po_line_locations pll,
             hr_locations hl
       WHERE hl.location_code = p_invoice_lines_rec.ship_to_location_code
         AND hl.location_id = pll.ship_to_location_id
          AND pll.po_header_id = l_po_header_id
         AND pll.po_line_id = l_po_line_id;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         -- po shipment number is invalid
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID LOCATION CODE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN

       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<-'||current_calling_sequence);
           END IF;
           RAISE check_po_failure;
         END IF;
         --
         l_current_invoice_status := 'N';

       WHEN TOO_MANY_ROWS THEN
         IF (p_invoice_lines_rec.po_shipment_num IS NULL) Then
           -- po shipment to Location is not unique for a Line
           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                 p_invoice_lines_rec.invoice_line_id,
                 'NON UNIQUE LOCATION CODE',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN

         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
             END IF;
             RAISE check_po_failure;
             END IF;
           --
           l_current_invoice_status := 'N';

         END IF;
     END;

  END IF;

  ------------------------------------------------------------
  -- Case 19, Reject if po_shipment_num is invalid
  ------------------------------------------------------------

  IF ((p_invoice_lines_rec.po_shipment_num IS NOT NULL) AND
      (l_po_line_location_id IS NULL) AND
      (l_po_header_id IS NOT NULL)    AND
      (l_po_release_id IS NOT NULL)) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 19) Validate po_shipment_num';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y', line_location_id,
      	     po_line_id
        INTO l_po_shipment_is_valid_flag, l_po_line_location_id,
  	     l_po_line_id
        FROM po_line_locations
       WHERE shipment_num = p_invoice_lines_rec.po_shipment_num
         AND po_header_id = l_po_header_id
         AND po_release_id = l_po_release_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po shipment number is invalid
        -- bug 2581097 added contextual information for XML GATEWAY
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                       AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INVALID PO SHIPMENT NUM',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'PO SHIPMENT NUMBER',
                        p_invoice_lines_rec.po_shipment_num) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;

        l_current_invoice_status := 'N';
    END;

  END IF;


  ------------------------------------------------------------
  -- Case 20, Reject if p_ship_to_location_code is invalid
  ------------------------------------------------------------

  IF ((p_invoice_lines_rec.ship_to_location_code IS NOT NULL) AND
      (l_po_line_location_id IS NULL) AND
      (l_po_header_id IS NOT NULL) AND
      (l_po_release_id IS NOT NULL)) THEN
      --
    BEGIN
      debug_info :=
        '(v_check_line_po_info 20) Validate p_ship_to_location_code';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y', line_location_id,
             po_line_id
        INTO l_po_shipment_is_valid_flag, l_po_line_location_id,
	     l_po_line_id
        FROM po_line_locations pll, hr_locations hl
       WHERE hl.location_code = p_invoice_lines_rec.ship_to_location_code
         AND hl.location_id = pll.ship_to_location_id
          AND pll.po_header_id = l_po_header_id
         AND pll.po_release_id = l_po_release_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- po shipment number is invalid
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
           AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID LOCATION CODE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
  -- CHANGES FOR BUG - 2772949  ** STARTS **
	WHEN TOO_MANY_ROWS THEN
		NULL;
  -- CHANGES FOR BUG - 2772949  ** ENDS   **
  END;
  END IF;

  ---------------------------------------------------------------------------
  -- Case 21, Reject if po_line_location_id and po_shipment_num is inconsistent
  ---------------------------------------------------------------------------

  IF ((l_po_line_location_id IS NOT NULL) AND
      (p_invoice_lines_rec.po_shipment_num IS NOT NULL))    THEN
      --
    BEGIN
      debug_info := '(v_check_line_po_info 21) Check inconsistence for '
                    ||'po_shipment_num and po_line_location_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y'
      INTO l_po_shipment_is_consis_flag
    FROM po_line_locations
       WHERE shipment_num = p_invoice_lines_rec.po_shipment_num
     AND line_location_id = l_po_line_location_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INCONSISTENT PO SHIPMENT',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
    END;

  END IF;

  ---------------------------------------------------------------------------
  -- Case 22, Reject if po_line_location_id and p_ship_to_location_code is
  -- inconsistent
  ---------------------------------------------------------------------------
  IF ((l_po_line_location_id IS NOT NULL) AND
      (p_invoice_lines_rec.ship_to_location_code IS NOT NULL)) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 22) Check inconsistence for '
                    ||'p_ship_to_location_code and po_line_location_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --

      SELECT 'Y'
          INTO l_po_shipment_is_consis_flag
        FROM po_line_locations pll,
             hr_locations hl
       WHERE hl.location_code = p_invoice_lines_rec.ship_to_location_code
         AND hl.location_id = pll.ship_to_location_id
         AND line_location_id = l_po_line_location_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INCONSISTENT PO SHIPMENT',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
    END;

  END IF;

  ---------------------------------------------------------------------------
  -- Case 23, Reject if p_po_shipment_num and p_ship_to_location_code is
  -- inconsistent
  ---------------------------------------------------------------------------
  IF ((p_invoice_lines_rec.po_shipment_num IS NOT NULL)       AND
      (p_invoice_lines_rec.ship_to_location_code IS NOT NULL) AND
      (l_po_header_id IS NOT NULL)                            AND
      (l_po_line_id IS NOT NULL)                              AND
      (l_po_release_id IS NULL))                             THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 23) Check inconsistence for '
                    ||'p_ship_to_location_code and p_po_shipment_num';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y'
        INTO l_po_shipment_is_consis_flag
        FROM po_line_locations pll,
             hr_locations hl
       WHERE hl.location_code = p_invoice_lines_rec.ship_to_location_code
         AND hl.location_id = pll.ship_to_location_id
         AND po_line_id = l_po_line_id
         AND shipment_num = p_invoice_lines_rec.po_shipment_num
         AND po_header_id = l_po_header_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
            'INCONSISTENT PO SHIPMENT',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
          END IF;
          --
          RAISE check_po_failure;
          --
        END IF;
        --
        l_current_invoice_status := 'N';
    END;
    --
  END IF;


-- 7531219 moving the following code to case 35.1 (before po overlay procedure - step 36)

/* Bug 4121338*/
  ----------------------------------------------------------
  -- Case 23.1, Reject if accrue on receipt is on but
  -- overlay gl account is provided in line

  ----------------------------------------------------------
/*
 IF (p_invoice_lines_rec.dist_code_combination_id IS NOT NULL OR
          p_invoice_lines_rec.dist_code_concatenated IS NOT NULL OR
              p_invoice_lines_rec.balancing_segment IS NOT NULL OR
              p_invoice_lines_rec.account_segment IS NOT NULL OR
              p_invoice_lines_rec.cost_center_segment IS NOT NULL) THEN

    IF ((p_invoice_lines_rec.po_shipment_num IS NOT NULL or p_invoice_lines_rec.po_line_location_id IS NOT NULL) AND
      (l_po_header_id IS NOT NULL) AND
      ((l_po_line_id IS NOT NULL AND l_po_release_id IS NULL) OR
       (l_po_release_id IS NOT NULL AND l_po_line_id IS NULL) OR
       (l_po_line_id IS NOT NULL AND l_po_release_id IS NOT NULL))) THEN -- Bug 4254606
      BEGIN

        debug_info := '(v_check_line_po_info 23.1) Validate po_shipment_num';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                debug_info);
        END IF;
        --
        --

        SELECT NVL(accrue_on_receipt_flag, 'N')
        INTO l_accrue_on_receipt_flag
        FROM po_line_locations
        WHERE ((shipment_num = p_invoice_lines_rec.po_shipment_num
                AND p_invoice_lines_rec.po_shipment_num IS NOT NULL
                AND p_invoice_lines_rec.po_line_location_id IS NULL)
             OR (line_location_id = p_invoice_lines_rec.po_line_location_id
                AND p_invoice_lines_rec.po_line_location_id IS NOT NULL
                AND p_invoice_lines_rec.po_shipment_num IS NULL)
             OR (p_invoice_lines_rec.po_shipment_num IS NOT NULL
                AND p_invoice_lines_rec.po_line_location_id IS NOT NULL
                AND shipment_num = p_invoice_lines_rec.po_shipment_num
                AND  line_location_id = p_invoice_lines_rec.po_line_location_id))
        AND po_header_id = l_po_header_id
        AND ((po_release_id = l_po_release_id
 AND l_po_line_id IS NULL)
            OR (po_line_id = l_po_line_id
             AND l_po_release_id IS NULL)
            OR (po_line_id = l_po_line_id  -- Bug 4254606
             AND po_release_id = l_po_release_id));
      EXCEPTION
        WHEN OTHERS THEN
          Null;
      END;

      IF l_accrue_on_receipt_flag = 'Y' THEN

 	IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'ACCRUE ON RECEIPT',  -- Bug 5235675
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
            END IF;
             RAISE check_po_failure;
          END IF;


        l_current_invoice_status := 'N';

      END IF;

    END IF;

  END IF;

  -- End Bug 4121338
*/


  ---------------------------------------------------------------------------
  -- Case 23, Reject if p_po_shipment_num and p_ship_to_location_code is
  -- inconsistent
  ---------------------------------------------------------------------------
  IF ((p_invoice_lines_rec.po_shipment_num IS NOT NULL) AND
      (p_invoice_lines_rec.ship_to_location_code IS NOT NULL) AND
      (l_po_header_id IS NOT NULL) AND
      (l_po_release_id IS  NOT NULL)) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 23) Check inconsistence for '
                     ||'p_ship_to_location_code and p_po_shipment_num';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y'
    INTO l_po_shipment_is_consis_flag
        FROM po_line_locations pll,
             hr_locations hl
       WHERE hl.location_code = p_invoice_lines_rec.ship_to_location_code
         AND hl.location_id = pll.ship_to_location_id
         AND po_release_id = l_po_release_id
         AND shipment_num = p_invoice_lines_rec.po_shipment_num
         AND po_header_id = l_po_header_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INCONSISTENT PO SHIPMENT',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
      END;

  END IF;


  -----------------------------------------------------------
  -- Case 25,  Reject if invalid p_po_distribution_id
  -----------------------------------------------------------

  IF (l_po_distribution_id IS NOT NULL ) THEN
     --
     BEGIN
      debug_info := '(v_check_line_po_info 25) Validate p_po_distribution_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y'
        INTO l_po_dist_is_valid_flag
        FROM po_distributions
       WHERE po_distribution_id = l_po_distribution_id
         AND line_location_id IS NOT NULL; /* BUG 3253594 */
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID PO DIST NUM',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
           END IF;
            RAISE check_po_failure;
         END IF;
         --
         l_current_invoice_status := 'N';
     END;

  END IF;

  -----------------------------------------------------------
  -- Case 26,  Reject if it is invalid p_po_distribution_num
  -----------------------------------------------------------

  IF ((l_po_distribution_id IS NULL) and
      (p_invoice_lines_rec.po_distribution_num IS NOT NULL) and
      (l_po_line_location_id IS NOT NULL) and
      (l_po_line_id IS NOT NULL) and
      (l_po_release_id IS NULL) and
      (l_po_header_id IS NOT NULL)) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 26) Validate p_po_distribution_num';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y' , po_distribution_id
      INTO l_po_dist_is_valid_flag,
             l_po_distribution_id
        FROM po_distributions
       WHERE distribution_num = p_invoice_lines_rec.po_distribution_num
         AND po_line_id = l_po_line_id
     AND line_location_id = l_po_line_location_id
         AND po_header_id = l_po_header_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID PO DIST NUM',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
    END;

  END IF;

  ----------------------------------------------------------------------------
  -- Case 27,  Reject if  is invalid p_po_distribution_num
  ----------------------------------------------------------------------------
  IF ((l_po_distribution_id IS NULL) and
      (p_invoice_lines_rec.po_distribution_num IS NOT NULL) and
      (l_po_release_id IS NOT NULL) and
      (l_po_line_location_id IS NOT NULL) and
      (l_po_header_id IS NOT NULL)) THEN
    --
    BEGIN
      debug_info := '(v_check_line_po_info 27) Validate p_po_distribution_num';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y' , po_distribution_id
        INTO l_po_dist_is_valid_flag, l_po_distribution_id
        FROM po_distributions
       WHERE distribution_num = p_invoice_lines_rec.po_distribution_num
     AND po_release_id = l_po_release_id
     AND line_location_id = l_po_line_location_id
     AND po_header_id = l_po_header_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID PO DIST NUM',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
    END;

  END IF;

  ---------------------------------------------------------------------------
  -- Case 28, Reject if p_po_distribution_num and p_po_distribution_id is
  -- inconsistent
  ---------------------------------------------------------------------------

  IF ((p_invoice_lines_rec.po_distribution_num IS NOT NULL) AND
      (l_po_distribution_id IS NOT NULL)) THEN
      --
     BEGIN
      debug_info := '(v_check_line_po_info 28) Check inconsistence for '
                    ||'p_po_distribution_num and p_po_distribution_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      SELECT 'Y'
        INTO l_po_dist_is_consistent_flag
        FROM po_distributions
       WHERE po_distribution_id = l_po_distribution_id
         AND distribution_num = p_invoice_lines_rec.po_distribution_num
         AND line_location_id IS NOT NULL; /* BUG 3253594 */
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INCONSISTENT PO DIST INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN

       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
           END IF;
           RAISE check_po_failure;
         END IF;
         --
         l_current_invoice_status := 'N';
     END;

  END IF;

  --------------------------------------------
  -- Get Valid PO Info only if PO information
  -- was not rejected so far
  --------------------------------------------
  IF (l_current_invoice_status = 'Y') Then

    IF (l_po_number IS NULL) THEN

    ------------------------------------------------------------------------
    -- PO step 29,Get po number if it's null
    ------------------------------------------------------------------------
      ------------------------------------------------
      -- Case 1, if po_number is null, then we should try to
      -- get it from po_header_id first.  Note that po_header_id
      -- would be based on po_number from invoice level if po_number
      -- was given at invoice header and line information did not
      -- contain either po_header_id or po_number
      ------------------------------------------------

      IF (l_po_header_id IS NOT NULL) THEN

        BEGIN
          debug_info := '(v_check_line_po_info 29.1) Get po number from '
                          ||'po_header_id';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

          SELECT segment1
            INTO l_po_number
            FROM po_headers
           WHERE po_header_id = l_po_header_id
             AND type_lookup_code in ('BLANKET', 'PLANNED', 'STANDARD');
        EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
        END;

      END IF; -- Step 29 - Case 1: l_po_header_id is not null

      ----------------------------------------------------
      -- Case 2, If l_po_number is still null, get both po_number
      --         and po_header_id from l_po_line_id if po_release_id
      --         is not available.
      ----------------------------------------------------
      IF (l_po_number is null) THEN

        IF ((l_po_line_id IS NOT NULL) and (l_po_release_id IS NULL)) THEN

          BEGIN
            debug_info :=
              '(v_check_line_po_info 29.2) Get po number from po_line_id';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

            SELECT pl.po_header_id,
               ph.segment1
          INTO l_po_header_id,
               l_po_number
           FROM po_headers ph,
                   po_lines pl
             WHERE pl.po_line_id = l_po_line_id
               AND pl.po_header_id = ph.po_header_id;

          EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

      ----------------------------------------------------
      -- Case 3, If l_po_number is still null and po_release_id
      --         is not null, get both po_number
      --         and po_header_id from l_po_release_id
      ----------------------------------------------------

        ELSIF (l_po_release_id IS NOT NULL) Then

          BEGIN
            debug_info := '(v_check_line_po_info 29.3) Get po number from'
                          ||' po_release_id';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

        SELECT pr.po_header_id,
               ph.segment1
          INTO l_po_header_id,
               l_po_number
           FROM po_headers ph,
               po_releases pr
             WHERE pr.po_release_id = l_po_release_id
               AND pr.po_header_id = ph.po_header_id;
          EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
          END;

        END IF; -- l_po_release_id is null and po_line_id is not null

      END IF; -- Step 29 - Case 2 and 3: l_po_number is null

      ----------------------------------------------------
      -- Case 4, If l_po_number is still null, get both po_number
      --         and po_header_id from l_po_line_location_id
      ----------------------------------------------------
      IF (l_po_number is null) THEN
        IF (l_po_line_location_id IS NOT NULL) THEN
          --
          -- get po_header_id and po_number from po_line_location_id
          --
          BEGIN

            debug_info := '(v_check_line_po_info 29.4) Get po number from '
                          ||'po_line_location_id';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

        SELECT pll.po_header_id,
               ph.segment1
          INTO l_po_header_id,
               l_po_number
           FROM po_headers ph,
               po_line_locations pll
             WHERE pll.line_location_id = l_po_line_location_id
               AND pll.po_header_id = ph.po_header_id;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
          NULL;
          END;

        END IF; -- l_po_line_location_id is not null
      END IF; -- Step 29 - Case 4: l_po_number is null

      ----------------------------------------------------
      -- Case 5, If l_po_number is still null, get both
      --         po_number and po_header_id from
      --           po_distribution_id
      ----------------------------------------------------
      IF (l_po_number is null) THEN
        IF (l_po_distribution_id IS NOT NULL) THEN
          --
          -- get po_header_id and po_number from po_distribution_id
          --
          BEGIN

            debug_info := '(v_check_line_po_info 29.5) Get po number from '
                          ||'po_distribution_id';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

            SELECT pd.po_header_id,
               ph.segment1
          INTO l_po_header_id,
               l_po_number
           FROM po_headers ph,
               po_distributions pd
             WHERE pd.po_distribution_id = l_po_distribution_id
               AND pd.po_header_id = ph.po_header_id
               AND pd.line_location_id IS NOT NULL; /* BUG 3253594 */
          EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

        END IF; -- l_po_distribution_id is not NULL
      END IF; -- Step 29 - Case 5: l_po_number is null

    END IF;  -- (PO step 29) -- l_po_number is null

    -----------------------------------------------------------------------
    -- Step 30
    -- Get po_header_id from po_number if still null
    -----------------------------------------------------------------------
    IF ((l_po_number IS NOT NULL) AND
        (l_po_header_id IS NULL)) THEN

      debug_info :=
          '(v_check_line_po_info 30) Get po_header_id from po_number';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --bug2268553 to differentiate PO from RFQ and Quotation
      SELECT po_header_id
        INTO l_po_header_id
        FROM po_headers
       WHERE segment1 = l_po_number
         AND type_lookup_code in ('BLANKET', 'PLANNED', 'STANDARD');

    END IF; -- Step 30: po_number is not null but po_header_id is null

    -- Get other po infomation
    -- only if l_po_header_id is not null
    --

    IF (l_po_header_id IS NOT NULL) THEN
      ------------------------------------------------------------------------
      -- Step 31
      -- Get po_line_id
      ------------------------------------------------------------------------
      debug_info := '(v_check_line_po_info 31) Get po_line_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      -------------------------------------------------------
      -- Case 1, If po_line_id is still null, get it from
      --  l_po_line_location_id if po_line_location_id is not null
      --------------------------------------------------------
      IF (l_po_line_id IS NULL) THEN
        IF (l_po_line_location_id IS NOT NULL) THEN

      BEGIN

            debug_info := '(v_check_line_po_info 31.1) Get po_line_id from '
                          ||'po_line_location_id';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

        SELECT po_line_id
          INTO l_po_line_id
          FROM po_line_locations
          WHERE line_location_id = l_po_line_location_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
              NULL;
      END;

        END IF; --  l_po_line_location_id is not null
      END IF; -- Step 31 - Case 1: l_po_line_id is null

      -------------------------------------------------------
      -- Case 2, If l_po_line_id is still null, get it from
      --  po_distribution_id if po_distribution_id is not null
      --------------------------------------------------------
      IF (l_po_line_id IS NULL) THEN
      IF (l_po_distribution_id IS NOT NULL) THEN

      BEGIN

            debug_info := '(v_check_line_po_info 31.2) Get po_line_id from '
                          ||'po_distribution_id';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

        SELECT po_line_id
          INTO l_po_line_id
          FROM po_distributions
          WHERE po_distribution_id = l_po_distribution_id
            AND line_location_id IS NOT NULL; /* BUG 3253594 */
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
              NULL;
      END;

    END IF; -- l_po_distribution_id is not null

   END IF; -- Step 31 - Case 2: l_po_line_id is null

      -------------------------------------------------------
      -- Case 3, If po_line_id is still null, default to
      -- the first line (it should be one line)
      -- If more than 1 line then reject NO PO LINE NUM
      --------------------------------------------------------
   IF (l_po_line_id IS NULL) THEN

        BEGIN

          debug_info := '(v_check_line_po_info 31.3) Default po_line_id from '
                        ||'the first line, if only one line';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
          END IF;

          SELECT po_line_id
            INTO l_po_line_id
            FROM po_lines
           WHERE po_header_id = l_po_header_id;

        EXCEPTION
          WHEN NO_DATA_FOUND Then
            NULL;

          WHEN TOO_MANY_ROWS Then
            debug_info := '(v_check_line_po_info 31.4) Too many po lines';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
            END IF;

            -- bug 2581097 added contextual information for XML GATEWAY

            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'NO PO LINE NUM',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'PO NUMBER',
                        l_po_number) <> TRUE) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'insert_rejections<-'||current_calling_sequence);
              END IF;
              RAISE check_po_failure;
            END IF;
            --
            l_current_invoice_status := 'N';
            --
        END;

      END IF; -- Step 31 - Case 3: l_po_line_id is null

    END IF; -- Step 31: (l_po_header_id IS NOT NULL - get po_line_id if null)

    -- Bug # 1042447
    --
    -- Get  po shipment infomation
    -- only if p_po_header_id is not null and po_line_id is not null

    IF (l_po_header_id IS NOT NULL) AND (l_po_line_id is not NULL) THEN
      -----------------------------------------------------------------------
      -- Step 32
      -- Get Get po_line_location_id
      -----------------------------------------------------------------------
      debug_info := '(v_check_line_po_info 32) Get po_line_location_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      END IF;

      -------------------------------------------------------
      -- Case 1, If l_po_line_location_id id still null, get it from
      --  po_distribution_id
      --------------------------------------------------------
      IF (l_po_line_location_id IS NULL) THEN
        IF (l_po_distribution_id IS NOT NULL) THEN

          BEGIN
            --
            debug_info := '(v_check_line_po_info 32.1) Get po_line_id from '
                           ||'po_distribution_id';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

            SELECT line_location_id
              INTO l_po_line_location_id
              FROM po_distributions
              WHERE po_distribution_id = l_po_distribution_id
                AND line_location_id IS NOT NULL; /* BUG 3253594 */
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
                  NULL;
          END;
          --
        END IF; -- l_po_distribution_id is not null
      END IF; -- l_po_line_location_id is null

      -------------------------------------------------------
      -- Case 2, If po_line_location_id id still null, default to
      -- the first line (it should be one one line)
      -- If more than 1 line then reject NO SHIPMENT LINE NUM
      --------------------------------------------------------
      IF (l_po_line_location_id IS NULL) THEN

        BEGIN

          debug_info := '(v_check_line_po_info 32.2) Default '
                         ||'po_line_location_id from the first line, '
                         ||'if only one line';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

	  /*--------------------------------------------------------------------+
	  | --Contract Payments:						|
	  | 1.For the case of complex works purchase order, if it is a		|
	  |   A)Prepayment Invoice,we should not reject if we can derive        |
	  |     a single shipment of type 'Prepayment' from the PO line		|
	  |    we should not reject it.						|
          |   B)Any other invoice (Std, credit,debit, mixed), we should		|
	  |    not reject if we are able to derive a single actual('Standard') 	|
	  |    shipment.							|
	  +---------------------------------------------------------------------*/

            SELECT line_location_id
            INTO l_po_line_location_id
            FROM po_line_locations pll
           WHERE po_header_id = l_po_header_id
            AND po_line_id = l_po_line_id
	    AND
	     (
	      (p_invoice_rec.invoice_type_lookup_code = 'PREPAYMENT' and
	       ((pll.payment_type IS NOT NULL and pll.shipment_type = 'PREPAYMENT') or
	        (pll.payment_type IS NULL)
               )
              ) OR
            --(p_invoice_rec.invoice_type_lookup_code <> 'PREPAYMENT' and    .. B# 8528132
              (nvl(p_invoice_rec.invoice_type_lookup_code, 'STANDARD') <> 'PREPAYMENT' and    -- B# 8528132
	       ((pll.payment_type IS NOT NULL and pll.shipment_type <> 'PREPAYMENT') or
		(pll.payment_type IS NULL)
	       )
              )
             );

        EXCEPTION
          WHEN NO_DATA_FOUND Then
                NULL;

          WHEN TOO_MANY_ROWS Then

            debug_info :=
              '(v_check_line_po_info 32.2) Too many po shipments';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                   AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                     p_invoice_lines_rec.invoice_line_id,
                'NO PO SHIPMENT NUM',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence) <> TRUE) THEN
               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                   AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<-'||current_calling_sequence);
               END IF;
                RAISE check_po_failure;
            END IF;
            l_current_invoice_status := 'N';

        END;

      END IF; -- step 31 - CASE 2: po_line_location_id IS still null

    END IF; -- Step 31 - po_header_id and po_line_id are not null


    ---------------------------------------------------------------------------
    -- 31.1 - Amount Based Matching
    -- If match basis is still null derive it based po_line_location_id
    -- if it is not null. Complex Work Project matching basis will be
    -- poulated at shipment level.
    -- Bug8546486 fetching the Description at line level from PO tables.
    ---------------------------------------------------------------------------
    IF (l_po_line_location_id IS NOT NULL) THEN
      debug_info := '(v_check_line_po_info 31.1) Get Match Basis Based '||
                                  'on line_location_id';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      END IF;

      SELECT pll.matching_basis,pll.description-- Bug8546486
        INTO l_match_basis,l_item_description  -- Bug8546486
        FROM po_line_locations pll
       WHERE pll.line_location_id = l_po_line_location_id;

    END IF;

    /*Bug8546486 fetching the Description if it is not present at
          po_line_locations_all table level*/
    IF (l_item_description IS NULL and l_po_line_id IS NOT NULL) THEN

      SELECT pl.item_description
        INTO l_item_description
        FROM po_lines pl
       WHERE pl.po_line_id = l_po_line_id;

    END IF;
    --End Bug8546486

    ---------------------------------------------------------------------------
    -- 31.2: Check for Corrupt PO data - Amount Based Matching
    -- Forward Bug 3253594. Po team made the po_line_id, line_location_id,
    -- code_combination_id and quantity_ordered fields of the po_distributions
    -- table nullable for certain types of PO's (i.e. Blanket Agreements and
    -- Global Agreements). These fields must be not not null in the types of
    -- PO's that the 'Payables Open Interface Import' concurrent program
    -- handles. Thus, if a distribution with any of these fields null is
    -- encountered then we can import the invoice because it references
    -- corrupt po distributions
    -- Complex Work Project. Matching Basis will be derived from po shipment.
    ---------------------------------------------------------------------------

    IF (l_po_header_id IS NOT NULL) THEN
      debug_info := '(v_check_line_po_info 31.2) Check for corrupt PO data';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      END IF;

     --start of bug 5292782
     declare
     l_blanket varchar2(10);
     begin
     select type_lookup_code, vendor_id  -- Bug 5448579
     into   l_blanket, l_vendor_id
     from po_headers
     where po_header_id=l_po_header_id;
     --end of select for 5292782

IF (l_blanket<>'BLANKET') THEN /* Bug10103888 */

      SELECT COUNT(*)
        INTO l_corrupt_po_distributions
        FROM po_distributions
       WHERE po_header_id = l_po_header_id
         AND (line_location_id IS NULL
              OR po_line_id IS NULL
              OR code_combination_id IS NULL)
         AND  rownum = 1;  -- Bug 5448579

      IF (l_corrupt_po_distributions = 0) THEN

        SELECT COUNT(*)
          INTO l_corrupt_po_distributions
          FROM po_distributions pod,
               po_line_locations pll
         WHERE pod.po_header_id = l_po_header_id
           AND pod.line_location_id = pll.line_location_id
           AND ((pll.matching_basis = 'QUANTITY'
                AND pod.quantity_ordered IS NULL)
             OR (pll.matching_basis = 'AMOUNT'
                AND pod.amount_ordered IS NULL))
           AND rownum = 1; -- Bug 5448579

      END IF;

   /*  IF (l_blanket<>'BLANKET') THEN --bug 5292782  Moved above for bug 10103888 */
      IF (l_corrupt_po_distributions > 0) THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INVALID PO NUM',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'CORRUPT PONUMBER',
                        l_po_header_id) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;

        l_current_invoice_status := 'N';

      END IF;
     END IF;--Bug 5292782
     end; --Bug 5292782

    END IF;

    -- Misc Checks Here
    -- At this point we should have all the information in
    -- terms of id's

    -------------------------------------------------------------------
    -- Step 33   Misc Checks
    -- 1. Verify there is no vendor mismatch between invoice and PO
    -- 2. Verify that if it is a blanket PO, then release information was
    --    provided.  Otherwise, reject.
    -- 3. Verify that all PO info provided is correct i.e. points to
    --    existing PO data.  Otherwise, reject.
    -- 4. If no shipment info could be derived (either there is no shipments
    --    for the provided po data or too many) reject.
    -- 5. Verify if invoice currency is the same as PO currency and
    --    reject otherwise.
    -------------------------------------------------------------------
    IF (l_po_header_id IS NOT NULL) Then

      debug_info := '(v_check_line_po_info 33.1) Find if PO vendor does not '
                     ||'match interface vendor:Get PO Vendor';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
      END IF;
     -- Bug 5448579. L_vendor_id is already derived
    /*  SELECT vendor_id
        INTO l_vendor_id
        FROM po_headers
       WHERE po_header_id = l_po_header_id; */

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '------------------> l_vendor_id :per PO = '||
          to_char(l_vendor_id));
      END IF;
      debug_info :=
        '(v_check_line_po_info 33.1) Check for Inconsistent PO Vendor.';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      IF (l_vendor_id <> nvl(p_invoice_rec.vendor_id, l_vendor_id)) THEN
        IF ( AP_IMPORT_INVOICES_PKG.g_source = 'XML GATEWAY' ) THEN
           BEGIN

             SELECT vendor_name
               INTO l_invoice_vendor_name
               FROM po_vendors
              WHERE vendor_id = p_invoice_rec.vendor_id;

             IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                         AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                       p_invoice_lines_rec.invoice_line_id,
                       'INCONSISTENT PO SUPPLIER',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                       current_calling_sequence,
                       'Y',
                       'SUPPLIER NAME',
                       l_invoice_vendor_name) <> TRUE) THEN

               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                 AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch,
                      'insert_rejections<-'||current_calling_sequence);
               END IF;
                RAISE check_po_failure;
         END IF;

           EXCEPTION
             WHEN NO_DATA_FOUND THEN
               NULL;
           END;

        ELSE
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                      AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                     p_invoice_lines_rec.invoice_line_id,
                    'INCONSISTENT PO SUPPLIER',
                    p_default_last_updated_by,
                     p_default_last_update_login,
                    current_calling_sequence) <> TRUE) THEN

                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                   AP_IMPORT_UTILITIES_PKG.Print(
                     AP_IMPORT_INVOICES_PKG.g_debug_switch,
                     'insert_rejections<-'||current_calling_sequence);
                END IF;
                RAISE check_po_failure;
          END IF;

        END IF;  -- g_source = 'XML GATEWAY'

          l_current_invoice_status := 'N';

      END IF; -- vendor_id in po_header is different than in invoice record

      IF ((p_invoice_lines_rec.release_num IS NULL) AND
          (l_po_release_id IS NULL)) THEN
      DECLARE
         l_blanket varchar2(10); --4019310
      BEGIN
         l_blanket:='BLANKET'; --4019310

         debug_info := '(v_check_line_po_info 33.2) Find if PO is BLANKET';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

          SELECT 'Y'
            INTO l_po_is_not_blanket
            FROM po_headers
           WHERE po_header_id = l_po_header_id
             AND type_lookup_code <> l_blanket; --4019310

        EXCEPTION
      WHEN NO_DATA_FOUND THEN
            -- po header is BLANKET
            -- bug 2581097 added contextual information for XML GATEWAY

            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'RELEASE MISSING',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'PO NUMBER',
                        l_po_number) <> TRUE) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                     AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);
              END IF;
              RAISE check_po_failure;
            END IF;
            l_current_invoice_status := 'N';
        END;

      END IF; -- release info is null

      IF ((l_po_line_id IS NOT NULL) AND
          (l_po_release_id IS NOT NULL) AND
          (l_po_line_location_id is NOT NULL)) THEN

        BEGIN

          debug_info :=
            '(v_check_line_po_info 33.3) Find if PO info is consistent';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
          END IF;

          SELECT 'X'
            INTO l_po_is_not_blanket
            FROM po_line_locations pll,
             po_releases pr
           WHERE pr.po_header_id = l_po_header_id
             AND pr.po_release_id = l_po_release_id
             AND pll.po_release_id = pr.po_release_id
             AND pll.po_line_id = l_po_line_id
             AND pll.line_location_id = l_po_line_location_id;

          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            -- Reject
            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INVALID PO INFO',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'PO RECEIPT NUMBER',
                        p_invoice_lines_rec.receipt_number,
                        'PO NUMBER',
                        p_invoice_lines_rec.po_number,
                        'PO LINE NUMBER',
                        p_invoice_lines_rec.po_line_number,
                        'PO SHIPMENT NUMBER',
                        p_invoice_lines_rec.po_shipment_num,
                        'PO RELEASE NUMBER',
                        p_invoice_lines_rec.release_num ) <> TRUE) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                     AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);
              END IF;
              RAISE check_po_failure;

            END IF;

            l_current_invoice_status := 'N';
          END;

      END IF; -- po_line_id, po_release_id and po_line_location_id not null

      ---------------------------------------------------------
      -- Check if invoice currency is the same as PO currency
      ---------------------------------------------------------
      BEGIN
        debug_info := '(v_check_line_po_info 33.5) Check if inv curr is same is '
                      ||'po curr';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

        SELECT 'Y'
          INTO l_po_inv_curr_is_consis_flag
          FROM po_headers
         WHERE po_header_id = l_po_header_id
           AND currency_code = p_invoice_rec.invoice_currency_code;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        debug_info :=
          '(v_check_line_po_info 33.5) Reject: Inconsistent currencies';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
          END IF;
          -- Reject
          IF ( AP_IMPORT_INVOICES_PKG.g_source = 'XML GATEWAY') THEN
            SELECT currency_code
              INTO l_po_currency_code
              FROM po_headers
             WHERE po_header_id = l_po_header_id ;

            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                    AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                         p_invoice_lines_rec.invoice_line_id,
                         'INCONSISTENT CURR',
                         p_default_last_updated_by,
                         p_default_last_update_login,
                         current_calling_sequence,
                        'Y',
                        'INVOICE CURRENCY CODE',
                         p_invoice_rec.invoice_currency_code,
                        'PO CURRENCY CODE',
                         l_po_currency_code ) <> TRUE) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);
              END IF;
               RAISE check_po_failure;
               END IF;

          ELSE

            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                  AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                      p_invoice_lines_rec.invoice_line_id,
                    'INCONSISTENT CURR',
                     p_default_last_updated_by,
                     p_default_last_update_login,
                      current_calling_sequence) <> TRUE) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);
              END IF;
               RAISE check_po_failure;

            END IF;

          END IF; -- g_source = 'XML GATEWAY'

          l_current_invoice_status := 'N';

        END;

    END IF; -- Step 33 - Misc checks: po_header_id is not null


  --------------------------------------------------------
  -- Step 34.1
  -- Check price correction information
  -- Retropricing: Please Note that the code for Price
  -- Corrections should not be executed for source = 'PPA'.
  -- For PPA Lines p_invoice_lines_rec.price_correction_flag
  -- should be NULL
  ---------------------------------------------------------
  IF (AP_IMPORT_INVOICES_PKG.g_source <> 'PPA') THEN
    IF p_invoice_lines_rec.price_correction_flag = 'Y' then

     debug_info := '(v_check_line_po_info 34.1) Check for price correction information on'||
     			' prepayment invoices';
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
       AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                     debug_info);
     END IF;

     IF(p_invoice_rec.invoice_type_lookup_code = 'PREPAYMENT') THEN

         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'CANNOT PRICE CORRECT PREPAY',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                     AP_IMPORT_UTILITIES_PKG.Print(
	                      AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                'insert_rejections<-'||current_calling_sequence);
            END IF;

            RAISE check_po_failure;

         END IF;

         l_current_invoice_status := 'N';

      END IF;

      debug_info := '(v_check_line_po_info 34.2) Check price correction information';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      IF p_invoice_lines_rec.price_correct_inv_num is null then

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
              'PRICE CORRECT INV NUM REQUIRED',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence)<> TRUE) THEN

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'insert_rejections<-'||current_calling_sequence);
          END IF;

          RAISE check_po_failure;
        END IF;

        l_current_invoice_status := 'N';

      END IF;


    --Check if price_correct_inv_line_num is NULL, if so reject the invoice.
    IF p_invoice_lines_rec.price_correct_inv_line_num is null then

       debug_info := '(v_check_line_po_info 34.3) Check price correction line information';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
       END IF;

       IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
              'INCOMPLETE PO INFO',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence)<> TRUE) THEN

         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'insert_rejections<-'||current_calling_sequence);
         END IF;
         RAISE check_po_failure;
       END IF;
       l_current_invoice_status := 'N';

    END IF;

    --check if this is a valid invoice and invoice line is provided
    --for a price correction
    IF (p_invoice_lines_rec.price_correct_inv_num is not null and
        p_invoice_lines_rec.price_correct_inv_line_num is not null) THEN
     BEGIN

      debug_info := '(v_check_line_po_info 34.4) Check if price correcting invoice line'
		    ||'is valid';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      SELECT DISTINCT ai.invoice_id, ail.amount
      INTO l_price_correct_inv_id, l_base_match_amount
      FROM ap_invoices ai, ap_invoice_lines ail, ap_invoice_distributions aid
      WHERE ai.invoice_num = p_invoice_lines_rec.price_correct_inv_num
      AND ail.invoice_id = ai.invoice_id
      AND ail.line_number = p_invoice_lines_rec.price_correct_inv_line_num
      AND aid.invoice_id = ail.invoice_id
      AND aid.po_distribution_id is not null
      AND aid.corrected_invoice_dist_id is null
      AND nvl(ail.discarded_flag,'N') = 'N'
      AND nvl(ail.cancelled_flag,'N') = 'N'
      AND ai.vendor_id = p_invoice_rec.vendor_id
      AND rownum <= 1;


    EXCEPTION
      WHEN NO_DATA_FOUND THEN
       IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
              'INVALID PO INFO',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence)<> TRUE) THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                     AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);
         END IF;
         RAISE check_po_failure;
       END IF;
       l_current_invoice_status := 'N';
    END;

   END IF;

   --Check match_basis. Amount Based  Matching.
   --Match Basis is already dervied in section 31.1
   IF (l_price_correct_inv_id IS NOT NULL
	and p_invoice_lines_rec.price_correct_inv_line_num IS NOT NULL) THEN
     BEGIN

       debug_info := '(v_check_line_po_info 34.5) Check if price correction line is matched to'
			||' a service order shipment';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                       debug_info);
       END IF;


       IF (l_match_basis = 'AMOUNT') THEN

           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INCONSISTENT PO INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN

                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN

                     AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);

                END IF;

                RAISE check_po_failure;

           END IF;

	   l_current_invoice_status := 'N';

        END IF;
     EXCEPTION WHEN OTHERS THEN
       NULL;
     END;

   END IF;  /* check match_basis */


   IF l_po_distribution_id is not null then

      debug_info := '(v_check_line_po_info 34.6) Check pc invoice is matched '
                    ||'to po dist';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      BEGIN
        --the query below will ensure the invoice has at least one base matched
        --distribution matched to this po distribution

        SELECT 'Y'
        INTO    l_pc_inv_valid
        FROM    ap_invoice_distributions
        WHERE   invoice_id = l_price_correct_inv_id
	AND     invoice_line_number = p_invoice_lines_rec.price_correct_inv_line_num
        AND     po_distribution_id = l_po_distribution_id;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
              'INVALID PO INFO',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence)<> TRUE) THEN

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE check_po_failure;
          END IF;
          l_current_invoice_status := 'N';
        WHEN TOO_MANY_ROWS THEN
          NULL;
      END;

    END IF;


    IF (l_po_distribution_id is null and
        l_po_line_location_id is not null) THEN

      debug_info := '(v_check_line_po_info 34.7) Check pc invoice is matched'
                    ||' to shipment';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      BEGIN
        --the query below will ensure the invoice has at least one base matched
        --distribution matched to one of the po dists for this shipment

        SELECT 'Y'
          INTO l_pc_inv_valid
          FROM ap_invoice_distributions
         WHERE invoice_id = l_price_correct_inv_id
           AND invoice_line_number = p_invoice_lines_rec.price_correct_inv_line_num
           AND po_distribution_id IN (
                 SELECT po_distribution_id
                   FROM po_distributions
                   WHERE line_location_id = l_po_line_location_id);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
               'INVALID PO INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                     AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE check_po_failure;
          END IF;
          l_current_invoice_status := 'N';
        WHEN TOO_MANY_ROWS THEN
          NULL;
      END;

    END IF;


    --No price corrections should not be performed against finally closed POs.
    BEGIN

       debug_info := '(v_check_line_po_info 34.8) Check if po shipment is finally closed';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
       END IF;

       SELECT 'Y'
       INTO l_shipment_finally_closed
       FROM ap_invoice_lines ail, po_line_locations pll
       WHERE ail.invoice_id = l_price_correct_inv_id
       AND ail.line_number = p_invoice_lines_rec.price_correct_inv_line_num
       AND pll.line_location_id = ail.po_line_location_id
       AND pll.closed_code = 'FINALLY CLOSED';

       IF (nvl(l_shipment_finally_closed,'N') = 'Y') THEN

	  IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INVALID PO INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN

                     AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);

              END IF;
              RAISE check_po_failure;

          END IF;

          l_current_invoice_status := 'N';

       END IF;

    EXCEPTION
       WHEN OTHERS THEN
	  NULL;

    END ;


    --Quantity Invoiced must be always be positive or NULL for price corrections regardless of
    --the invoice type.
    debug_info := '(v_check_line_po_info 34.9) Check if Quantity_Invoiced for the price corrections'
			||'to be either NULL or positive';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
    END IF;

    IF (p_invoice_lines_rec.quantity_invoiced IS NOT NULL AND
  	p_invoice_lines_rec.quantity_invoiced < 0) THEN

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INVALID PO INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN

           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN

                     AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);

           END IF;
           RAISE check_po_failure;

       END IF;

       l_current_invoice_status := 'N';

    END IF;


    --Unit Price must be always be positive for STANDARD invoices, and negative
    --for CREDIT/DEBIT memos, and postive or negative for MIXED type of invoices.
    debug_info := '(v_check_line_po_info 34.10) Check the sign of the unit_price against'
		  ||'the invoice type';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
    END IF;

    --Contract Payments: Modified the IF condition to add 'PREPAYMENT'.

    IF ((p_invoice_rec.invoice_type_lookup_code IN ('STANDARD','PREPAYMENT') and
         p_invoice_lines_rec.unit_price < 0) OR
        (p_invoice_rec.invoice_type_lookup_code IN ('CREDIT','DEBIT') and
	 p_invoice_lines_rec.unit_price > 0)) THEN

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INVALID PO INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN

           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN

                     AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);

           END IF;
           RAISE check_po_failure;

       END IF;

       l_current_invoice_status := 'N';

    END IF;

    BEGIN

      debug_info := '(v_check_line_po_info 34.11) Check if quantity_invoiced for price correction'
		  ||' exceeds the quantity_invoiced on the base match';

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      BEGIN

         SELECT ail.quantity_invoiced
         INTO l_base_match_quantity
         FROM ap_invoice_lines ail
         WHERE ail.invoice_id = l_price_correct_inv_id
         AND ail.line_number = p_invoice_lines_rec.price_correct_inv_line_num;


      --bugfix:5640388
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
       			       AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                       	       p_invoice_lines_rec.invoice_line_id,
                               'PRICE CORRECT INV INVALID',
	                       p_default_last_updated_by,
			       p_default_last_update_login,
			       current_calling_sequence)<> TRUE) THEN
	       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	           AP_IMPORT_UTILITIES_PKG.Print(
	                          AP_IMPORT_INVOICES_PKG.g_debug_switch,
	                          'insert_rejections<-'||current_calling_sequence);
																								                 END IF;
	             RAISE check_po_failure;
               END IF;
               l_current_invoice_status := 'N';
         WHEN TOO_MANY_ROWS THEN
           NULL;
         END;


      IF ( p_invoice_lines_rec.quantity_invoiced > l_base_match_quantity) THEN

         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'AMOUNT BILLED BELOW ZERO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN

             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN

                     AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);

             END IF;
             RAISE check_po_failure;

          END IF;

          l_current_invoice_status := 'N';

      END IF;

     END ;


    --Amount_Billed against the Purchase Order Shipment should not go below 0 IN
    --absolute terms and relative to the base match. The amount billed for the
    --base match should be calculated based on quantity being corrected and any
    --previous existing price corrections against the base match.
    BEGIN

      debug_info := '(v_check_line_po_info 34.12) Check if amount_billed against PO Shipment/Dist'
		  ||'goes below zero due to this price correction relative to the base match';


      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      l_line_amt_calculated :=
      nvl(ap_utilities_pkg.ap_round_currency(
           p_invoice_lines_rec.unit_price*
           p_invoice_lines_rec.quantity_invoiced,
           p_invoice_rec.invoice_currency_code)
          ,0);

      IF (p_invoice_lines_rec.amount < 0 OR l_line_amt_calculated < 0) THEN

         BEGIN

            SELECT nvl(sum(ail.amount),0)
            INTO l_correction_amount
            FROM ap_invoice_lines ail
            WHERE ail.invoice_id = l_price_correct_inv_id
            AND ail.line_number = p_invoice_lines_rec.price_correct_inv_line_num
            AND ail.match_type IN ('PRICE_CORRECTION','QTY_CORRECTION');

	    --bugfix:5640388
	    EXCEPTION
	        WHEN NO_DATA_FOUND THEN
	            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
	                     AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
	                     p_invoice_lines_rec.invoice_line_id,
	                     'PRICE CORRECT INV INVALID',
	                     p_default_last_updated_by,
	                     p_default_last_update_login,
	                     current_calling_sequence)<> TRUE) THEN
	                  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	                        AP_IMPORT_UTILITIES_PKG.Print(
	                                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
	                                  'insert_rejections<-'||current_calling_sequence);
	                  END IF;
	                 RAISE check_po_failure;
		     END IF;
		     l_current_invoice_status := 'N';
	        WHEN TOO_MANY_ROWS THEN
	            NULL;
	END;

        IF (abs(nvl(p_invoice_lines_rec.amount,l_line_amt_calculated)) >
	 				(l_base_match_amount + l_correction_amount)) THEN

           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'AMOUNT BILLED BELOW ZERO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN

             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN

                     AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);

             END IF;
             RAISE check_po_failure;

           END IF;

           l_current_invoice_status := 'N';

         END IF;

       END IF; /* p_invoice_lines_rec.line_amount < 0 */

    END ;



    --make sure we won't reduce the amount billed below zero on
    --the po dists relative to the base match
    --this requires we use the proration logic used in the matching code
    --which, for price corrections, is to prorate based upon amount if the
    --quantity billed on the po is zero, otherwise prorate by quantity billed

    IF  l_po_distribution_id IS NULL AND
        l_po_line_location_id IS NOT NULL AND
        (nvl(p_invoice_lines_rec.amount,0) < 0 OR
        l_line_amt_calculated < 0) THEN

      debug_info := '(v_check_line_po_info 34.13) Ensure amount billed on po '
                     ||'distributions wont be reduced below zero for shipment';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      BEGIN

         SELECT amount, quantity_invoiced
         INTO l_total_amount_invoiced, l_total_quantity_invoiced
         FROM ap_invoice_lines ail
         WHERE ail.invoice_id = l_price_correct_inv_id
         AND ail.line_number = p_invoice_lines_rec.price_correct_inv_line_num;

         --bugfix:5640388
         EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
	                     AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
	                     p_invoice_lines_rec.invoice_line_id,
	                     'PRICE CORRECT INV INVALID',
	                     p_default_last_updated_by,
	                     p_default_last_update_login,
	                     current_calling_sequence)<> TRUE) THEN
	          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	               AP_IMPORT_UTILITIES_PKG.Print(
	                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
	                       'insert_rejections<-'||current_calling_sequence);
	          END IF;
	          RAISE check_po_failure;
	      END IF;
	      l_current_invoice_status := 'N';
          WHEN TOO_MANY_ROWS THEN
             NULL;
      END;

      IF l_total_quantity_invoiced = 0 THEN
        IF (l_total_amount_invoiced + l_correction_amount + nvl(p_invoice_lines_rec.amount,l_line_amt_calculated) < 0) THEN

               IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                    AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                     p_invoice_lines_rec.invoice_line_id,
                     'AMOUNT BILLED BELOW ZERO',
                     p_default_last_updated_by,
                     p_default_last_update_login,
                     current_calling_sequence)<> TRUE) THEN

                 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                      AP_IMPORT_UTILITIES_PKG.Print(
                          AP_IMPORT_INVOICES_PKG.g_debug_switch,
                         'insert_rejections<-'||current_calling_sequence);
                 END IF;
                 RAISE check_po_failure;
               END IF;
               l_current_invoice_status := 'N';

         END IF;
      END IF;


      IF l_total_quantity_invoiced > 0 then

        FOR pc_inv_dists IN (SELECT quantity_invoiced, amount, invoice_distribution_id
			    FROM ap_invoice_distributions
			    WHERE invoice_id = l_price_correct_inv_id
			    AND invoice_line_number = p_invoice_lines_rec.price_correct_inv_line_num)

        LOOP

	  BEGIN

             SELECT sum(aid.amount)
             INTO l_correction_dist_amount
	     FROM ap_invoice_distributions aid
             WHERE corrected_invoice_dist_id = pc_inv_dists.invoice_distribution_id
	     GROUP BY corrected_invoice_dist_id ;

          EXCEPTION WHEN OTHERS THEN
	     l_correction_dist_amount := 0;
          END ;

          IF (pc_inv_dists.quantity_invoiced/ l_total_quantity_invoiced *
              p_invoice_lines_rec.amount + l_correction_dist_amount + pc_inv_dists.amount) < 0 OR
             (pc_inv_dists.quantity_invoiced/ l_total_quantity_invoiced *
              l_line_amt_calculated + l_correction_dist_amount + pc_inv_dists.amount) < 0  THEN

             IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                 AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                 p_invoice_lines_rec.invoice_line_id,
                 'AMOUNT BILLED BELOW ZERO',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence)<> TRUE)  THEN
               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                   AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<-'||current_calling_sequence);
               END IF;
               RAISE check_po_failure;
             END IF;
             l_current_invoice_status := 'N';

          END IF;

        END LOOP;

       END IF;

     END IF;  --end of checking if the qty billed on the shipment's dists
             --will fall below zero relative to the base match distribution's amount_billed



    --Make sure we won't reduce the amount billed below zero on the po dist absolutely
    IF (l_po_distribution_id IS NOT NULL AND
        (nvl(p_invoice_lines_rec.amount,0) < 0 OR
         l_line_amt_calculated < 0)) THEN

      debug_info := '(v_check_line_po_info 34.14) Ensure amount billed on po '
                    ||'dist wont be reduced below zero, l_po_distribution_id is: '||l_po_distribution_id;
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

   BEGIN
      BEGIN
	--Contract Payments: Modified the SELECT clause
        SELECT decode(distribution_type,'PREPAYMENT',nvl(amount_financed,0),nvl(amount_billed,0))
        INTO l_pc_po_amt_billed
        FROM po_distributions
        WHERE po_distribution_id = l_po_distribution_id
          AND line_location_id IS NOT NULL; /* BUG 3253594 */

      --bugfix:5640388
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                   AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                   p_invoice_lines_rec.invoice_line_id,
                   'PRICE CORRECT INV INVALID',
                   p_default_last_updated_by,
                   p_default_last_update_login,
                   current_calling_sequence)<> TRUE) THEN
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                    AP_IMPORT_UTILITIES_PKG.Print(
                              AP_IMPORT_INVOICES_PKG.g_debug_switch,
                              'insert_rejections<-'||current_calling_sequence);
                END IF;
                RAISE check_po_failure;
           END IF;
           l_current_invoice_status := 'N';
        WHEN TOO_MANY_ROWS THEN
           NULL;
        END;

        IF (l_pc_po_amt_billed + nvl(p_invoice_lines_rec.amount,0) < 0) or
           (l_pc_po_amt_billed + l_line_amt_calculated < 0) then

           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
              'AMOUNT BILLED BELOW ZERO',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence)<> TRUE) THEN
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
             END IF;
             RAISE check_po_failure;
           END IF;
           l_current_invoice_status := 'N';
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

    END IF;


    --make sure we won't reduce the amount billed below zero on the po dists
    --this requires we use the proration logic used in the matching code
    --which, for price corrections, is to prorate based upon amount if the
    --quantity billed on the po is zero, otherwise prorate by quantity billed

    IF  l_po_distribution_id IS NULL AND
        l_po_line_location_id IS NOT NULL AND
        (nvl(p_invoice_lines_rec.amount,0) < 0 OR
        l_line_amt_calculated < 0) THEN

      debug_info := '(v_check_line_po_info 34.15) Ensure amount billed on po '
                     ||'distribtuions wont be reduced below zero for shipment';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;


      --Contract Payments: Modified the SELECT clause
      BEGIN

        SELECT nvl(SUM(decode(distribution_type,'PREPAYMENT',nvl(amount_financed,0),nvl(amount_billed,0))),0),
               nvl(SUM(decode(distribution_type,'PREPAYMENT',nvl(quantity_financed,0),nvl(quantity_billed,0))),0)
        INTO l_total_amount_billed, l_total_quantity_billed
        FROM po_distributions
        WHERE line_location_id = l_po_line_location_id
        AND po_distribution_id IN (SELECT po_distribution_id
                                 FROM   ap_invoice_distributions
                                 WHERE  invoice_id = l_price_correct_inv_id
				 AND    invoice_line_number = p_invoice_lines_rec.price_correct_inv_line_num);

        --bugfix:5640388
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
              IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                      AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                      p_invoice_lines_rec.invoice_line_id,
                      'PRICE CORRECT INV INVALID',
                      p_default_last_updated_by,
                      p_default_last_update_login,
                      current_calling_sequence)<> TRUE) THEN
                   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                       AP_IMPORT_UTILITIES_PKG.Print(
                                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    'insert_rejections<-'||current_calling_sequence);
                   END IF;
                   RAISE check_po_failure;
               END IF;
               l_current_invoice_status := 'N';
          WHEN TOO_MANY_ROWS THEN
               NULL;
       END;

       IF l_total_quantity_billed = 0 THEN
        IF (l_total_amount_billed + nvl(p_invoice_lines_rec.amount,0) < 0) OR
           (l_total_amount_billed + l_line_amt_calculated < 0) THEN

               IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                    AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                     p_invoice_lines_rec.invoice_line_id,
                     'AMOUNT BILLED BELOW ZERO',
                     p_default_last_updated_by,
                     p_default_last_update_login,
                     current_calling_sequence)<> TRUE) THEN

                 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                      AP_IMPORT_UTILITIES_PKG.Print(
                          AP_IMPORT_INVOICES_PKG.g_debug_switch,
                         'insert_rejections<-'||current_calling_sequence);
                 END IF;
                 RAISE check_po_failure;
               END IF;
               l_current_invoice_status := 'N';

         END IF;
      END IF;


      IF l_total_quantity_billed > 0 then

	--Contract Payments: Modified the SELECT clause
        FOR pc_po_dists IN (SELECT decode(pod.distribution_type,'PREPAYMENT',nvl(pod.quantity_financed,0),
					 nvl(pod.quantity_billed,0)) quantity_billed,
				   decode(pod.distribution_type,'PREPAYMENT',nvl(pod.amount_financed,0),
				         nvl(pod.amount_billed,0)) amount_billed
                            FROM po_distributions pod
                            WHERE pod.line_location_id = l_po_line_location_id
                            AND pod.po_distribution_id IN (
                                 SELECT aid.po_distribution_id
                                 FROM ap_invoice_distributions aid
                                 WHERE  aid.invoice_id = l_price_correct_inv_id
			         AND   aid.invoice_line_number = p_invoice_lines_rec.price_correct_inv_line_num))
        LOOP

          IF (pc_po_dists.quantity_billed / l_total_quantity_billed *
              p_invoice_lines_rec.amount + pc_po_dists.amount_billed) < 0 OR
             (pc_po_dists.quantity_billed / l_total_quantity_billed *
              l_line_amt_calculated + pc_po_dists.amount_billed) < 0  THEN

             IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                 AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                 p_invoice_lines_rec.invoice_line_id,
                 'AMOUNT BILLED BELOW ZERO',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence)<> TRUE)  THEN
               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                   AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<-'||current_calling_sequence);
               END IF;
               RAISE check_po_failure;
             END IF;
             l_current_invoice_status := 'N';

          END IF;

        END LOOP;

       END IF;

     END IF;  --end of checking if the qty billed on the shipment's dists
             --will fall below zero

   END IF;   -- p_price_correction_flag = 'Y'

 END IF ; /* g_source <> 'PPA' */

--Bug 5225547 added the following
 -------------------------------------------------------------------------
  -- Validate Match Option if populated
  -------------------------------------------------------------------------
  If ( l_po_line_location_id is  null) and  (l_po_number is not null) and  ( p_invoice_lines_rec.po_shipment_num is not null) then
         BEGIN
                SELECT po_header_id
                INTO l_po_header_id
                FROM po_headers
                WHERE segment1 = l_po_number
                AND type_lookup_code in ('BLANKET', 'PLANNED', 'STANDARD');
         EXCEPTION
         when NO_DATA_FOUND then
         null;
         END;

        BEGIN
                SELECT po_line_id
                INTO l_po_line_id
                FROM po_lines
                WHERE po_header_id = l_po_header_id
                AND ROWNUM <= 1;
        EXCEPTION
        when NO_DATA_FOUND then
        null;
        END;

         BEGIN
                SELECT line_location_id
                INTO l_po_line_location_id
                FROM po_line_locations
                WHERE po_header_id = l_po_header_id
                AND po_line_id = l_po_line_id
                AND shipment_num = p_invoice_lines_rec.po_shipment_num ;
        EXCEPTION
         when NO_DATA_FOUND then
         null;
         END;

  End if;
IF (l_po_line_location_id IS NULL) THEN

     IF (l_po_distribution_id IS NOT NULL) THEN
        BEGIN

            SELECT line_location_id
            INTO l_po_line_location_id
            FROM po_distributions
            WHERE po_distribution_id = l_po_distribution_id;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
 NULL;
  END;

     END IF;
 END IF;

  If ( l_po_line_location_id is not null) then

      debug_info := '(v_check_line_po_info) :Get Match Option from po shipment';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

        Select nvl(match_option,'P')
        Into l_temp_match_option
        From po_line_locations
        Where line_location_id = l_po_line_location_id;

    If (l_temp_match_option is not null) then

   --bug 9292033 : modified below condition to allow prepayment invoices with match option as 'P' and 'R' on PO

     /*IF (p_invoice_lines_rec.match_option IS NOT NULL AND
              p_invoice_lines_rec.match_option <> l_temp_match_option) THEN*/

        If ( p_invoice_lines_rec.match_option is not null
	     and ((nvl(p_invoice_rec.invoice_type_lookup_code,'STANDARD') = 'PREPAYMENT'
	           AND p_invoice_lines_rec.match_option = 'R'
		   AND l_temp_match_option = 'P')
		OR
		   (nvl(p_invoice_rec.invoice_type_lookup_code,'STANDARD') <> 'PREPAYMENT'
                    AND p_invoice_lines_rec.match_option <> l_temp_match_option))) then

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
              'INVALID MATCH OPTION',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'insert_rejections<-'||current_calling_sequence);
               END IF;
                raise check_po_failure;
           End if;
           l_current_invoice_status := 'N';

        End if;

        p_invoice_lines_rec.match_option := nvl(l_temp_match_option , p_invoice_lines_rec.match_option);

    End if;
 End if;

--End of bug 5225547



    --------------------------------------------------------------------
    -- Rest of the PO Validation should be done now
    --------------------------------------------------------------------
 IF (l_current_invoice_status <>'N') THEN

      ---------------------------------------------------------
      -- Step 35
      -- check for additional PO validation
      ---------------------------------------------------------
      debug_info := '(v_check_line_po_info 35) Call v_check_line_po_info2';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;

      IF (AP_IMPORT_VALIDATION_PKG.v_check_line_po_info2 (
         p_invoice_rec,                                             -- IN
         p_invoice_lines_rec,                                     -- IN
         p_positive_price_tolerance,                               -- IN
         p_qty_ord_tolerance,                                     -- IN
	 p_amt_ord_tolerance,					  -- IN
         p_max_qty_ord_tolerance,                                 -- IN
	 p_max_amt_ord_tolerance,				  -- IN
         p_po_header_id           => l_po_header_id,                -- IN
         p_po_line_id            => l_po_line_id,                     -- IN
         p_po_line_location_id => l_po_line_location_id,         -- IN
         p_po_distribution_id  => l_po_distribution_id,             -- IN
         p_match_option           => l_match_option,             -- OUT NOCOPY
         p_calc_quantity_invoiced => l_calc_quantity_invoiced,   -- OUT NOCOPY
         p_calc_unit_price          => l_calc_unit_price,        -- OUT NOCOPY
         p_calc_line_amount         => l_calc_line_amount,       -- OUT NOCOPY /* ABM */
         p_default_last_updated_by => p_default_last_updated_by, -- IN
         p_default_last_update_login => p_default_last_update_login,  -- IN
         p_current_invoice_status   => l_current_invoice_status,      -- IN OUT
         p_match_basis             =>  l_match_basis,        -- IN /*Amount Based Matching */
             p_calling_sequence         => current_calling_sequence) <> TRUE )THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           'v_check_po_line_info2<-' ||current_calling_sequence);
        END IF;
        RAISE check_po_failure;
      END IF;

      --
      -- show output values (only if debug_switch = 'Y')
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '------------------> l_current_invoice_status = '||
        l_current_invoice_status);
      END IF;

      -- 7531219 moved the following code from Case 23.1
     /* Bug 4121338*/
      ----------------------------------------------------------
      -- Case 35.1, Reject if accrue on receipt is on but
      -- overlay gl account is provided in line
      ----------------------------------------------------------
     IF (p_invoice_lines_rec.dist_code_combination_id IS NOT NULL OR
              p_invoice_lines_rec.dist_code_concatenated IS NOT NULL OR
                  p_invoice_lines_rec.balancing_segment IS NOT NULL OR
                  p_invoice_lines_rec.account_segment IS NOT NULL OR
                  p_invoice_lines_rec.cost_center_segment IS NOT NULL) THEN

       -- 7531219 replaced p_invoice_lines_rec.po_line_location_id with l_po_line_location_id
       IF ((p_invoice_lines_rec.po_shipment_num IS NOT NULL or l_po_line_location_id /*p_invoice_lines_rec.po_line_location_id*/ IS NOT NULL) AND
          (l_po_header_id IS NOT NULL) AND
          ((l_po_line_id IS NOT NULL AND l_po_release_id IS NULL) OR
           (l_po_release_id IS NOT NULL AND l_po_line_id IS NULL) OR
           (l_po_line_id IS NOT NULL AND l_po_release_id IS NOT NULL))) THEN /* Bug 4254606 */
          BEGIN

            debug_info := '(v_check_line_po_info 35.1) check accrue on receipt but overlay info is provided';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
            END IF;

            -- 7531219 replaced p_invoice_lines_rec.po_line_location_id with l_po_line_location_id
            SELECT NVL(accrue_on_receipt_flag, 'N')
            INTO l_accrue_on_receipt_flag
            FROM po_line_locations
            WHERE ((shipment_num = p_invoice_lines_rec.po_shipment_num
                    AND p_invoice_lines_rec.po_shipment_num IS NOT NULL
                    AND p_invoice_lines_rec.po_line_location_id IS NULL)
                 OR (line_location_id = l_po_line_location_id --p_invoice_lines_rec.po_line_location_id
                    and l_po_line_location_id is not null
                    --AND p_invoice_lines_rec.po_line_location_id IS NOT NULL
                    AND p_invoice_lines_rec.po_shipment_num IS NULL)
                 OR (p_invoice_lines_rec.po_shipment_num IS NOT NULL
                    AND p_invoice_lines_rec.po_line_location_id IS NOT NULL
                    AND shipment_num = p_invoice_lines_rec.po_shipment_num
                    AND  line_location_id = l_po_line_location_id /*p_invoice_lines_rec.po_line_location_id*/))
            AND po_header_id = l_po_header_id
            AND ((po_release_id = l_po_release_id
     AND l_po_line_id IS NULL)
                OR (po_line_id = l_po_line_id
                 AND l_po_release_id IS NULL)
                OR (po_line_id = l_po_line_id  /* Bug 4254606 */
                 AND po_release_id = l_po_release_id));
          EXCEPTION
            WHEN OTHERS THEN
              Null;
          END;

          IF l_accrue_on_receipt_flag = 'Y' THEN

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                    AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                    p_invoice_lines_rec.invoice_line_id,
                    'ACCRUE ON RECEIPT',  -- Bug 5235675
                    p_default_last_updated_by,
                    p_default_last_update_login,
                    current_calling_sequence) <> TRUE) THEN
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                    AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                      'insert_rejections<-'||current_calling_sequence);
                END IF;
                 RAISE check_po_failure;
              END IF;


            l_current_invoice_status := 'N';

          END IF;

        END IF;

      END IF;

      /* End Bug 4121338 */

      --------------------------------------------------------
      -- Step 36
      -- PO Overlay.
      -- Retropricing: PO Overlay is not needed for PPA's
      ---------------------------------------------------------
      IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN
          debug_info := '(v_check_line_po_info 36) Call v_check_po_overlay';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                         debug_info);
          END IF;

          IF (AP_IMPORT_VALIDATION_PKG.v_check_po_overlay(
		p_invoice_rec,					   -- IN
                p_invoice_lines_rec,                               -- IN
                NVL(l_po_line_id, p_invoice_lines_rec.po_line_id), -- IN
                NVL(l_po_line_location_id,
                    p_invoice_lines_rec.po_line_location_id),      -- IN
                NVL(l_po_distribution_id,
                    p_invoice_lines_rec.po_distribution_id),       -- IN
                p_set_of_books_id,                                   -- IN
                p_default_last_updated_by,                         -- IN
                p_default_last_update_login,                       -- IN
                p_current_invoice_status   => l_current_invoice_status, -- IN OUT
                p_calling_sequence         => current_calling_sequence) <> TRUE )THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                      'v_check_po_overlay<-' ||current_calling_sequence);
            END IF;
            RAISE check_po_failure;
          END IF;

          --
          -- show output values (only if debug_switch = 'Y')
          --
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             '------------------> l_current_invoice_status = '||
             l_current_invoice_status);
          END IF;
      END IF; ---source <> PPA
     END IF; -- Step 35 and Step 36: Invoice Status <> 'N'

   END IF; -- Step 29: Invoice Status <> 'N'


 ELSIF (p_invoice_lines_rec.line_type_lookup_code IN ('FREIGHT','MISCELLANEOUS','TAX')) THEN

   IF(p_invoice_lines_rec.price_correction_flag = 'Y') THEN


	debug_info := '(v_check_line_po_info 37) Cannot associate charge lines with price corrections';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
              'INVALID PO INFO',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN

           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'insert_rejections<-'||current_calling_sequence);
           END IF;

           RAISE check_po_failure;

         END IF;

         l_current_invoice_status := 'N';

    END IF;

 END IF; /*nvl(p_invoice_lines_rec.line_type_lookup_code, 'ITEM'... */
  --
  -- Return value
  p_current_invoice_status := l_current_invoice_status;

  IF (l_po_header_id IS NOT NULL) Then
    p_invoice_lines_rec.po_header_id := l_po_header_id;
  End IF;

  IF (l_po_release_id IS NOT NULL) then
    p_invoice_lines_rec.po_release_id := l_po_release_id;
  END IF;

  IF (l_po_line_id IS NOT NULL) then
    p_invoice_lines_rec.po_line_id := l_po_line_id;
  END IF;

  IF (l_po_line_location_id IS NOT NULL) Then
    p_invoice_lines_rec.po_line_location_id := l_po_line_location_id;
  END IF;

  IF (l_po_distribution_id IS NOT NULL) THEN
    p_invoice_lines_rec.po_distribution_id := l_po_distribution_id;
  END IF;

  IF (l_match_option IS NOT NULL AND
    p_invoice_lines_rec.match_option IS NULL) THEN
    p_invoice_lines_rec.match_option := l_match_option;
  END IF;

  IF (l_calc_quantity_invoiced IS NOT NULL AND
    p_invoice_lines_rec.quantity_invoiced IS NULL) then
    p_invoice_lines_rec.quantity_invoiced := l_calc_quantity_invoiced;
  END IF;

  IF (l_calc_unit_price IS NOT NULL AND
    p_invoice_lines_rec.unit_price is NULL) then
    p_invoice_lines_rec.unit_price := l_calc_unit_price;
  END IF;

  /* Amount Based Matching */
  IF (l_calc_line_amount IS NOT NULL AND
    p_invoice_lines_rec.amount is NULL) then
    p_invoice_lines_rec.amount := l_calc_line_amount;
  END IF;

  /* Bug 5400087 */
  --7045958
--bug 7532498 - added OR Condition.
 --Bug9138771 Quantity Billed is null for EDI Invoices imported through
        --    the interface for a Receipt matched invoices as the
        --    import treats them as PO matched.Hence no debit memo's are created.

  IF(p_invoice_lines_rec.match_option = 'R') THEN   --Bug9138771
    IF (l_match_basis = 'AMOUNT') THEN
      p_invoice_lines_rec.match_type := 'ITEM_TO_SERVICE_RECEIPT';
    ELSE
      p_invoice_lines_rec.match_type := 'ITEM_TO_RECEIPT';
    END IF;
  ELSE
    IF (p_invoice_lines_rec.po_line_location_id IS NOT NULL) THEN
      IF (l_match_basis = 'AMOUNT') THEN
        p_invoice_lines_rec.match_type := 'ITEM_TO_SERVICE_PO';
      ELSE
        p_invoice_lines_rec.match_type := 'ITEM_TO_PO';
      END IF;
    END IF;
  END IF;

  IF (p_invoice_lines_rec.price_correction_flag = 'Y') THEN
    p_invoice_lines_rec.corrected_inv_id := l_price_correct_inv_id;
    p_invoice_lines_rec.match_type := 'PRICE_CORRECTION'; /* 5400087 */
  END IF;

  /*Bug8546486 Assigning the description fetched from PO to be inserted
         into ap_invoice_lines and ap_invoice_distributions*/
  IF (l_item_description IS NOT NULL) then
    IF (p_invoice_lines_rec.description IS NULL) then  /* B 9569917 ... added IF condition */
	p_invoice_lines_rec.description := l_item_description;
    END IF;
    p_invoice_lines_rec.item_description := l_item_description;
  END IF;
  --End Bug8546486

  RETURN (TRUE);

EXCEPTION

  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_line_po_info;


-----------------------------------------------------------------------------
-- This function is used to validate PO information at line level.
--
FUNCTION v_check_line_po_info2 (
    p_invoice_rec         IN  AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_invoice_lines_rec   IN  AP_IMPORT_INVOICES_PKG.r_line_info_rec,
    p_positive_price_tolerance     IN             NUMBER,
    p_qty_ord_tolerance            IN             NUMBER,
    p_amt_ord_tolerance		   IN		  NUMBER,
    p_max_qty_ord_tolerance        IN             NUMBER,
    p_max_amt_ord_tolerance	   IN		  NUMBER,
    p_po_header_id                   IN             NUMBER,
    p_po_line_id                   IN                NUMBER,
    p_po_line_location_id           IN               NUMBER,
    p_po_distribution_id           IN               NUMBER,
    p_match_option                       OUT NOCOPY VARCHAR2,
    p_calc_quantity_invoiced           OUT NOCOPY NUMBER,
    p_calc_unit_price                  OUT NOCOPY NUMBER,
    p_calc_line_amount                 OUT NOCOPY NUMBER, /* Amount Based Matching */
    p_default_last_updated_by      IN             NUMBER,
    p_default_last_update_login    IN             NUMBER,
    p_current_invoice_status       IN  OUT NOCOPY  VARCHAR2,
    p_match_basis                  IN             VARCHAR2, /* Amount Based matching */
    p_calling_sequence             IN             VARCHAR2) RETURN BOOLEAN
IS

check_po_failure          EXCEPTION;
l_po_header_id              NUMBER := nvl(p_invoice_lines_rec.po_header_id,
                                        p_po_header_id);
l_po_line_id              NUMBER := nvl(p_invoice_lines_rec.po_line_id,
                                        p_po_line_id);
l_po_line_location_id      NUMBER := nvl(p_invoice_lines_rec.po_line_location_id,
                                        p_po_line_location_id);
l_po_distribution_id      NUMBER := nvl(p_invoice_lines_rec.po_distribution_id,
                                        p_po_distribution_id);
l_unit_price              NUMBER := p_invoice_lines_rec.unit_price;
l_po_unit_price              NUMBER;
l_dec_unit_price          NUMBER;
l_unit_of_measure          VARCHAR2(25) := 'N';
l_current_invoice_status  VARCHAR2(1)  := p_current_invoice_status;
l_price_break              VARCHAR2(1);
l_calc_line_amount          NUMBER:=0;
l_overbill                  VARCHAR2(1);
l_qty_based_rejection     VARCHAR2(1);
l_amt_based_rejection	  VARCHAR2(1);
l_quantity_invoiced          NUMBER;
l_qty_invoiced              NUMBER;
l_total_qty_billed          NUMBER;
l_quantity_outstanding      NUMBER;
l_quantity_ordered          NUMBER;
l_qty_already_billed      NUMBER;
l_amount_outstanding      NUMBER;
l_amount_ordered          NUMBER;
l_amt_already_billed      NUMBER;
l_outstanding		  NUMBER;
l_ordered		  NUMBER;
l_already_billed	  NUMBER;
l_po_line_matching_basis  PO_LINES_ALL.MATCHING_BASIS%TYPE;
l_invalid_shipment_type      VARCHAR2(1):= '';
l_invalid_shipment_count  NUMBER;
l_positive_price_variance NUMBER;
l_total_match_amount      NUMBER;
l_temp_match_option          VARCHAR2(25);
current_calling_sequence  VARCHAR2(2000);
debug_info                 VARCHAR2(500);
l_line_amount             NUMBER;  /* Amount Based Matching */
l_temp_shipment_type      PO_LINE_LOCATIONS_ALL.SHIPMENT_TYPE%TYPE;

BEGIN

  -- Update the calling sequence
  --
  current_calling_sequence:= 'AP_IMPORT_VALIDATION_PKG.v_check_line_po_info2<-'
                             ||P_calling_sequence;

  l_qty_based_rejection := 'N';
  l_amt_based_rejection := 'N';

  -----------------------------------------------------------
  -- Step 1
  -- Check for Active PO
  -----------------------------------------------------------
  IF ((l_po_header_id IS NOT NULL) AND
      (l_po_line_id IS NOT NULL)) THEN

     l_quantity_invoiced := NULL;  --Bug 7446306 - For the Fixed Price Service PO the TERV line is not generated as this is not
                              -- initialized to NULL.

    IF (l_po_distribution_id IS NOT NULL) Then
      debug_info := '(v_check_line_po_info2 1) Check Valid Shipment Type from '
                    ||'l_po_distribution_id ';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                debug_info);
      END IF;

      BEGIN

	--Contract Payments: Modified the WHERE condition so that we check for
        --'Prepayment' type shipments for complex work pos for Prepayment invoices and otherwise
        --Standard/Blanket/Scheduled shipments are valid for Standard/Credit invoices.
        SELECT 'X'
            INTO l_invalid_shipment_type
          FROM po_distributions pd,
               po_line_locations pll
         WHERE pd.line_location_id   = pll.line_location_id
           AND pd.po_distribution_id = l_po_distribution_id
           AND
             (
              --(p_invoice_rec.invoice_type_lookup_code <> 'PREPAYMENT' and    .. B# 8528132
              (nvl(p_invoice_rec.invoice_type_lookup_code, 'STANDARD') <> 'PREPAYMENT' and    -- B# 8528132
	       pll.SHIPMENT_TYPE IN ('STANDARD','BLANKET','SCHEDULED')
              ) OR
              (p_invoice_rec.invoice_type_lookup_code = 'PREPAYMENT' and
               ((pll.payment_type IS NOT NULL and pll.shipment_type = 'PREPAYMENT') or
                (pll.payment_type IS NULL and pll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED'))
               )
              )
             )
           AND pll.APPROVED_FLAG     = 'Y'
           AND (nvl(pll.CLOSED_CODE, 'OPEN') <> 'FINALLY CLOSED')
           AND nvl(pll.consigned_flag,'N')   <> 'Y';
      EXCEPTION
        WHEN NO_DATA_FOUND Then
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INVALID SHIPMENT TYPE',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
            END IF;
             RAISE check_po_failure;
          END IF;
          --
          l_current_invoice_status := 'N';

      END;

    ELSIF (l_po_line_location_id IS NOT NULL) THEN
      -- elsif to po_distribution_id is not null

      debug_info := '(v_check_line_po_info2 1) Check Valid Shipment Type from '
                    ||'l_po_line_location_id ';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      --Contract Payments: Modified the WHERE condition so that we check for
      --'Prepayment' type shipments for complex work pos for Prepayment invoices and otherwise
      --Standard/Blanket/Scheduled shipments are valid for Standard/Credit invoices.
      BEGIN
        SELECT    'X'
          INTO  l_invalid_shipment_type
          FROM  po_line_locations pll
         WHERE  line_location_id = l_po_line_location_id
           AND(
               --(p_invoice_rec.invoice_type_lookup_code <> 'PREPAYMENT' and    .. B# 8528132
               (nvl(p_invoice_rec.invoice_type_lookup_code, 'STANDARD') <> 'PREPAYMENT' and    -- B# 8528132
	        pll.SHIPMENT_TYPE IN ('STANDARD','BLANKET','SCHEDULED')
               ) OR
               (p_invoice_rec.invoice_type_lookup_code = 'PREPAYMENT' and
                ((pll.payment_type IS NOT NULL and pll.shipment_type = 'PREPAYMENT') or
                 (pll.payment_type IS NULL and pll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED'))
                )
               )
              )
           AND  APPROVED_FLAG    = 'Y'
           AND  (nvl(CLOSED_CODE, 'OPEN') <> 'FINALLY CLOSED')
           AND  nvl(consigned_flag,'N')   <> 'Y';

      EXCEPTION
        WHEN NO_DATA_FOUND Then
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID SHIPMENT TYPE',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
            END IF;
             RAISE check_po_failure;
            END IF;
          --
          l_current_invoice_status := 'N';

      END;

      -------------------------------------------------------------------------
      -- Validate Match Option if populated
      -------------------------------------------------------------------------
      IF ( l_po_line_location_id is not null) THEN
        debug_info := '(v_check_line_po_info2) :Get Match Option from po shipment';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

        SELECT nvl(match_option,'P')
          INTO l_temp_match_option
             FROM po_line_locations
         WHERE line_location_id = l_po_line_location_id;

          --bug 9292033 : modified below condition to allow prepayment invoices with match option as 'P' and 'R' on PO

          /*IF (p_invoice_lines_rec.match_option IS NOT NULL AND
              p_invoice_lines_rec.match_option <> l_temp_match_option) THEN*/

          IF (p_invoice_lines_rec.match_option IS NOT NULL
	     AND ((nvl(p_invoice_rec.invoice_type_lookup_code,'STANDARD') = 'PREPAYMENT'
	           AND p_invoice_lines_rec.match_option = 'R'
		   AND l_temp_match_option = 'P')
		OR
		   (nvl(p_invoice_rec.invoice_type_lookup_code,'STANDARD') <> 'PREPAYMENT'
                    AND p_invoice_lines_rec.match_option <> l_temp_match_option))) THEN

            -- Reject for invalid Match option
            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INVALID MATCH OPTION',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) Then
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'insert_rejections <-'||current_calling_sequence);
              END IF;
          RAISE check_po_failure;
            END IF;
          l_current_invoice_status := 'N';

          END IF;

        -- set the ouput parameter
        p_match_option := nvl(l_temp_match_option ,
                              p_invoice_lines_rec.match_option);
      END IF; -- if l_po_line_location_id is not null

    ELSIF ((l_po_line_id IS NOT NULL) AND
           (l_po_line_location_id IS NULL)) Then
           -- elsif to po_distribution_id is not null
      debug_info := '(v_check_line_po_info2 1) Check Valid Shipment Type from'
                    ||' l_po_line_id ';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      BEGIN
        SELECT count(*)
          INTO l_invalid_shipment_count
          FROM po_line_locations pll
         WHERE pll.po_line_id = l_po_line_id
          AND(
	      (
               --(p_invoice_rec.invoice_type_lookup_code <> 'PREPAYMENT' and    .. B# 8528132
               (nvl(p_invoice_rec.invoice_type_lookup_code, 'STANDARD') <> 'PREPAYMENT' and    -- B# 8528132
	        pll.SHIPMENT_TYPE NOT IN ('STANDARD','BLANKET','SCHEDULED')
               ) OR
               (p_invoice_rec.invoice_type_lookup_code = 'PREPAYMENT' and
                ((pll.payment_type IS NOT NULL and pll.shipment_type <> 'PREPAYMENT') or
                 (pll.payment_type IS NULL and pll.shipment_type NOT IN ('STANDARD','BLANKET','SCHEDULED'))
                )
               )
              )
             /* Bug 4038403 removed these two conditions and added the below condition
              OR (APPROVED_FLAG <> 'Y')
              OR (APPROVED_FLAG IS NULL) */

              OR nvl(APPROVED_FLAG, 'N') <> 'Y'
            )
            OR (nvl(CLOSED_CODE, 'OPEN') = 'FINALLY CLOSED')
            OR (nvl(consigned_flag,'N') = 'Y');

          IF (l_invalid_shipment_count > 0) Then
            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INVALID SHIPMENT TYPE',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                  AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'insert_rejections<-'||current_calling_sequence);
               END IF;
                RAISE check_po_failure;
            END IF;
            --
            l_current_invoice_status := 'N';

          END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND Then
        NULL;
      END;

      -- Check for PO line price break
      -- Cannot have a line level match if price break is on
      -- Retropricing: Don't know what this rejection means???.
      -- For PPA's irrespective of the fact if the line has price breaks
      -- or not, we should not reject it. Price breaks is a feature in PO
      -- and AP does matching at the ship level.
      IF (AP_IMPORT_INVOICES_PKG.g_source <> 'PPA') THEN
          debug_info := '(v_check_line_po_info2 1) Check Price Break for PO '
                        ||'Line(Line Level Match) ';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
          END IF;
          --
          BEGIN
            SELECT allow_price_override_flag
              INTO l_price_break
              FROM po_lines
             WHERE po_line_id = l_po_line_id;

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                  AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    '------------------> l_price_break= '|| l_price_break);
              END IF;
              --
              IF (nvl(l_price_break,'N') ='Y' ) Then
                IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                    AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                    p_invoice_lines_rec.invoice_line_id,
                    'LINE HAS PRICE BREAK',
                    p_default_last_updated_by,
                    p_default_last_update_login,
                    current_calling_sequence) <> TRUE) THEN
                  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                      AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);
                  END IF;
                    RAISE check_po_failure;
                  END IF;
                --
                l_current_invoice_status := 'N';
                --
              END IF;

          EXCEPTION
            WHEN NO_DATA_FOUND Then
            Null;

          END;
          --
      END IF; -- source <> 'PPA'
    END IF; -- if to po_distribution_id is not null

    ---------------------------------------------------------------------------
    -- Step 1.1, Reject if po_inventory_item_id, p_vendor_item_num
    --                          and po_item_description are inconsistent
    --
    --  Added consistency check for Supplier Item Number too as part of
    --  the effort to support Supplier Item Number in Invoice Import
    --                                                         bug 1873251
    --  Amount Based Matching. Reject if any of the lines' match basis
    --  is Amount. However due to complex work project match basis will be
    --  at po shipment level hence all the matching basis related validation
    --  has been moved to shipment level.
    ---------------------------------------------------------------------------

    IF l_po_line_location_id IS NOT NULL THEN

       Select shipment_type
	 Into l_temp_shipment_type
	 From po_line_locations
	Where line_location_id = l_po_line_location_id;

    END IF;

    IF ((p_invoice_lines_rec.vendor_item_num IS NOT NULL) AND
       (p_match_basis = 'AMOUNT') AND
       (nvl(l_temp_shipment_type,'X') <> 'PREPAYMENT')) THEN
      --
      debug_info := '(v_check_line_po_info2 1.1) Check inconsistency for '
                    ||'po_vendor_item_num '
                    ||'shipment level match basis is AMOUNT';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INCONSISTENT SHIPMENT INFO',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'SUPPLIER ITEM NUMBER',
                        p_invoice_lines_rec.vendor_item_num ) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE check_po_failure;
      END IF;

      l_current_invoice_status := 'N';
    --Bug 9279395 Removed item_description is not null clause
    ELSIF ((p_invoice_lines_rec.inventory_item_id IS NOT NULL) AND
          (p_match_basis = 'AMOUNT') AND
	  (nvl(l_temp_shipment_type,'X') <> 'PREPAYMENT')) THEN
      --
      debug_info := '(v_check_line_po_info2 1.1) Check inconsistency for '
                    ||'po_inventory_item_id and po_item_description '
                    ||'shipment level match basis is AMOUNT';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      --
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INCONSISTENT SHIPMENT INFO',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence ) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE check_po_failure;
      END IF;

      l_current_invoice_status := 'N';

    END IF;

    ------------------------------------------------------
    -- Step 2
    -- Check for Invalid Distribution Set with PO
    -- Retropricing: Distribution Set is always NULL for PPA's
    ------------------------------------------------------
    IF ((p_invoice_lines_rec.distribution_set_id is NOT NULL) OR
        (p_invoice_lines_rec.distribution_set_name is NOT NULL)) Then
        debug_info := '(v_check_line_po_info2 2) Check for Invalid '
                    ||'Distribution Set with PO';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                   AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                   p_invoice_lines_rec.invoice_line_id,
                   'INVALID DIST SET WITH PO',
                   p_default_last_updated_by,
                   p_default_last_update_login,
                   current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE check_po_failure;
      END IF;
      l_current_invoice_status := 'N';

    END IF;

    -----------------------------------------------------
    -- Step 3
    -- Get Unit Price and UOM from PO Lines
    ------------------------------------------------------
    debug_info :=
      '(v_check_line_po_info2 3) Get Unit Price / UOM from PO Lines';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
    --
    --bug2878889.Commented the following code and added the code below.
/*    IF (l_po_line_location_id IS NOT NULL) THEN
      SELECT pll.price_override, pll.unit_meas_lookup_code
        INTO l_po_unit_price,l_unit_of_measure
        FROM po_line_locations pll
        WHERE  pll.line_location_id = l_po_line_location_id;
    ELSE
      SELECT unit_price,unit_meas_lookup_code
        INTO l_po_unit_price,l_unit_of_measure
        FROM po_lines
       WHERE po_line_id = l_po_line_id;
    END IF;*/

    IF (/* Bug 9326135 (p_invoice_lines_rec.quantity_invoiced IS NULL)
             AND */ (l_po_unit_price IS NULL)
             AND (p_invoice_lines_rec.po_release_id IS NOT NULL) ) THEN

             SELECT NVL(price_override,unit_price),unit_meas_lookup_code
             INTO l_po_unit_price,l_unit_of_measure
             FROM po_line_locations_release_v
             WHERE po_line_id = l_po_line_id
	     -- bug7328060, added the below condition
             AND line_location_id = nvl(l_po_line_location_id, line_location_id)
             AND po_release_id = p_invoice_lines_rec.po_release_id;

    ELSIF ( (l_po_line_location_id IS NOT NULL)
             /* Bug 9326135 AND (p_invoice_lines_rec.quantity_invoiced IS NULL) */
             AND (l_po_unit_price IS NULL)
             AND (p_invoice_lines_rec.po_release_id IS NULL) ) THEN

             SELECT pll.price_override, pll.unit_meas_lookup_code
             INTO l_po_unit_price,l_unit_of_measure
             FROM po_line_locations pll
             WHERE  pll.line_location_id = l_po_line_location_id;

    ELSIF (  (l_po_line_id IS NOT NULL)
              /* Bug 9326135 AND  (p_invoice_lines_rec.quantity_invoiced IS NULL)*/
              AND (l_po_unit_price IS NULL)
              AND (p_invoice_lines_rec.po_release_id IS NULL) ) THEN

              SELECT unit_price,unit_meas_lookup_code
              INTO l_po_unit_price,l_unit_of_measure
              FROM po_lines
              WHERE po_line_id = l_po_line_id;

    ELSIF (   (p_invoice_lines_rec.quantity_invoiced IS NOT NULL)
             AND (l_po_line_id IS NOT NULL)
	     AND (l_po_unit_price is NULL)
	     AND (p_invoice_lines_rec.amount is NOT NULL)) THEN

              IF (p_invoice_lines_rec.quantity_invoiced=0) THEN
                 l_po_unit_price :=0;
             ELSE
  		 l_po_unit_price := ap_utilities_pkg.ap_round_currency (
  	        		    p_invoice_lines_rec.amount /
				    p_invoice_lines_rec.quantity_invoiced,
		                    p_invoice_rec.invoice_currency_code);
 	     END IF; --Bug6932650

		SELECT unit_meas_lookup_code
		INTO l_unit_of_measure
		FROM po_lines
		WHERE po_line_id = l_po_line_id;

    END IF;
    --bug2878889 ends

    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  '------------------>
                        l_po_unit_price = '||to_char(l_po_unit_price)
                        ||' l_unit_of_measure = '||l_unit_of_measure);
    END IF;
    --
    -----------------------------------------------------
    -- Step 4
    -- Check for Invalid Line Quantity
    -- For credits we can have -ve qty
    -- Amount Based Matching. Line Amount can not be -ve
    -- if match basis is 'AMOUNT'
    ------------------------------------------------------
    --Contract Payments: Modified the IF condition to add 'PREPAYMENT'.

    IF ((p_invoice_lines_rec.quantity_invoiced) <= 0 AND
        (p_invoice_rec.invoice_type_lookup_code IN ('STANDARD','PREPAYMENT'))) Then
      debug_info :=
        '(v_check_line_po_info2 4) Check for Invalid Line Quantity';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID QUANTITY',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence,
            'Y',
            'QUANTITY INVOICED',
            p_invoice_lines_rec.quantity_invoiced) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE check_po_failure;
      END IF;

      l_current_invoice_status := 'N';

    END IF;

    ELSIF (p_match_basis = 'AMOUNT') THEN
      IF ((p_invoice_lines_rec.amount) <= 0 AND
        (p_invoice_rec.invoice_type_lookup_code = 'STANDARD')) Then
         debug_info :=
          '(v_check_line_po_info2 4) Check for Invalid Line Amount';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID QUANTITY',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence,
            'Y',
            'QUANTITY INVOICED',
            p_invoice_lines_rec.amount) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;

        l_current_invoice_status := 'N';

      END IF;

    END IF; -- end if match basis

    ------------------------------------------------------
    -- Step 5
    -- Check for Invalid Unit of Measure against PO Line
    -- Amount Based Matching. No need to check for UOM
    -- if match basis is 'AMOUNT'
    ------------------------------------------------------
    IF (p_match_basis = 'QUANTITY') THEN
    IF (p_invoice_lines_rec.unit_of_meas_lookup_code <> l_unit_of_measure)
        AND (p_match_option = 'P') THEN
      debug_info := '(v_check_line_po_info2 5) Check for Unit of Measure'
                    ||' against PO';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'UOM DOES NOT MATCH PO',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE check_po_failure;
      END IF;
      l_current_invoice_status := 'N';

    END IF;
    END IF;  -- Match Basis QUANTITY

    ----------------------------------------------------------------
    -- Step 6
    -- Check for Valid unit_price, quantity_invoiced and line_amount
    -- Amount Based Matching. Nso need to validate line amount based
    -- on unit_price and quantity_invoiced, or unit_price based on
    -- line_amount and quantity_invoiced, or calculate quantity_inv
    -- oiced based on line_amount and unit_price
    ----------------------------------------------------------------
    IF (p_match_basis = 'QUANTITY') THEN
    IF ((p_invoice_lines_rec.quantity_invoiced IS NOT NULL) AND
        (p_invoice_lines_rec.unit_price IS NOT NULL) AND
        (p_invoice_lines_rec.amount IS NOT NULL)) Then
      debug_info := '(v_check_line_po_info2 7) Check for valid unit_price, '
                     ||'quantity_invoiced and line_amount';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      END IF;

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        'quantity_invoiced = '||to_char(p_invoice_lines_rec.quantity_invoiced)||
        ' unit_price = '||to_char(p_invoice_lines_rec.unit_price)||
        ' amount = '||to_char(p_invoice_lines_rec.amount));
      END IF;

      -- The following can have rounding issues so use line_amount
      -- for consistency check.
      -- l_calculated_unit_price :=
      -- p_invoice_lines_rec.amount / p_quantity_invoiced;
      l_calc_line_amount := ap_utilities_pkg.ap_round_currency (
        p_invoice_lines_rec.unit_price * p_invoice_lines_rec.quantity_invoiced,
        p_invoice_rec.invoice_currency_code);
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '------------------>
        l_calc_line_amount = '||to_char(l_calc_line_amount));
      END IF;

      -- Bug 5469166. Added the g_source <> 'PPA' condition

      IF (l_calc_line_amount <> p_invoice_lines_rec.amount) OR
/*
2830338 : Raise INVALID PRICE/QUANTITY if Amount does not have the
                  same sign as Quantity
*/
      --Bug6836072
        ((SIGN(p_invoice_lines_rec.amount) <> SIGN(p_invoice_lines_rec.quantity_invoiced)
         AND
         (NVL(p_invoice_lines_rec.amount, 0) <> 0))
        AND AP_IMPORT_INVOICES_PKG.g_source <> 'PPA')
        THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                       AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INVALID PRICE/QUANTITY/AMOUNT',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'QUANTITY INVOICED',
                        p_invoice_lines_rec.quantity_invoiced,
                        'UNIT PRICE',
                        p_invoice_lines_rec.unit_price,
                        'INVOICE LINE AMOUNT',
                        p_invoice_lines_rec.amount) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;
        l_current_invoice_status := 'N';
      END IF;
    ELSIF ((p_invoice_lines_rec.quantity_invoiced IS NOT NULL) AND
           (P_INVOICE_LINES_REC.UNIT_PRICE IS NULL) AND
           (p_invoice_lines_rec.amount IS NOT NULL)) Then
      debug_info := '(v_check_line_po_info2 7) Get unit_price from '
                    ||'quantity_invoiced and line_amount';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      END IF;
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        'inside the else condition ');
      END IF;

/*
2830338 : Raise INVALID PRICE/QUANTITY if Amount does not have the
                  same sign as Quantity
*/
      --Bug6836072
      IF ((NVL(p_invoice_lines_rec.amount, 0) <> 0)
          AND SIGN(p_invoice_lines_rec.amount) <> SIGN(p_invoice_lines_rec.quantity_invoiced))
      THEN
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                       AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INVALID PRICE/QUANTITY/AMOUNT',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'QUANTITY INVOICED',
                        p_invoice_lines_rec.quantity_invoiced,
                        'UNIT PRICE',
                        p_invoice_lines_rec.unit_price,
                        'INVOICE LINE AMOUNT',
                        p_invoice_lines_rec.amount) <> TRUE) THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;
        l_current_invoice_status := 'N';
      END IF;

      -- We should calc the unit price instead of using the one from PO
      -- Use from PO only if both p_unit_price and p_quantity_invoiced are null
      /*Bug 5495483 Added the below IF condition*/
      /*l_unit_price := p_invoice_lines_rec.amount /
                    p_invoice_lines_rec.quantity_invoiced;*/
      IF (p_invoice_lines_rec.quantity_invoiced=0) THEN
            l_unit_price :=0;
      ELSE
            l_unit_price := p_invoice_lines_rec.amount /p_invoice_lines_rec.quantity_invoiced;
      END IF;

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '------------------>
          l_unit_price = '||to_char(l_unit_price));
      END IF;

    END IF;

  -- Calculate qty invoiced.
  -- Retropricing: Qnantity_invoiced will not be calculated
  -- for PPA Lines

    -- bug8587322
    l_dec_unit_price := nvl(l_unit_price,nvl(l_po_unit_price,1));
    IF (p_invoice_lines_rec.quantity_invoiced IS NULL) Then
      -- Quantity is not being rounded
      --l_dec_unit_price := nvl(l_unit_price,nvl(l_po_unit_price,1));

      IF (l_dec_unit_price = 0) Then
         l_quantity_invoiced := p_invoice_lines_rec.amount;
      ELSE
         l_quantity_invoiced := ROUND(p_invoice_lines_rec.amount/l_dec_unit_price,15) ;
      END IF;

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             '------------------>
          l_quantity_invoiced = '||to_char(l_quantity_invoiced)
      ||' line_amount = '||to_char(p_invoice_lines_rec.amount)
      ||' unit_price = '||to_char(l_unit_price));
      END IF;

    END IF;

    END IF; -- Match Basis QUANTITY

    ------------------------------------------------------------
    -- Step 7
    -- Calculate line_amount if unit_price and quantiy_invoiced
    -- are provided in case of Amount Based Matching
    ------------------------------------------------------------
    IF (p_match_basis = 'AMOUNT' AND
        p_invoice_lines_rec.amount IS NULL) THEN
      IF ((p_invoice_lines_rec.quantity_invoiced IS NOT NULL) AND
        (p_invoice_lines_rec.unit_price IS NOT NULL)) THEN
        debug_info := '(v_check_line_po_info2 7) Calculate line_amount, '
                     ||'in case of match basis is AMOUNT';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

        -- The following can have rounding issues so use line_amount
        -- for consistency check.
        -- l_calculated_unit_price :=
        -- p_invoice_lines_rec.amount / p_quantity_invoiced;
        l_calc_line_amount := ap_utilities_pkg.ap_round_currency (
          p_invoice_lines_rec.unit_price * p_invoice_lines_rec.quantity_invoiced,
          p_invoice_rec.invoice_currency_code);
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '------------------>
          l_calc_line_amount = '||to_char(l_calc_line_amount));
        END IF;
      ELSE
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                       AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                        p_invoice_lines_rec.invoice_line_id,
                        'INSUFFICIENT AMOUNT INFO',
                        p_default_last_updated_by,
                        p_default_last_update_login,
                        current_calling_sequence,
                        'Y',
                        'QUANTITY INVOICED',
                        p_invoice_lines_rec.quantity_invoiced,
                        'UNIT PRICE',
                        p_invoice_lines_rec.unit_price,
                        'INVOICE LINE AMOUNT',
                        p_invoice_lines_rec.amount) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF;
        l_current_invoice_status := 'N';
      END IF;
    END IF;

    -------------------------------------------------------------
    -- Step 8
    -- Check for Invalid Unit Price against PO
    -- Retropricing:
    -- We assume that PO will not allow to retroprice a PO again
    -- if there are pending PO shipment instructions in the
    -- AP_INVOICE_LINES_INTERFACE. If the PO's unit price is not
    -- equal to the unit price on the PPA, then it should
    -- be rejected . Currently UNIT PRC NOT EQUAL TO PO
    -- rejection is only meant for EDI-GATEWAY.
    -- Thia step should not be executed in context of PPA's.
    -- Amount Based Matching. Reject for negative total amount
    -- invoiced against given PO
    -------------------------------------------------------------
    IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN
        --
        IF (l_po_line_location_id IS NOT NULL) THEN
          l_qty_invoiced := nvl(p_invoice_lines_rec.quantity_invoiced,
                              l_quantity_invoiced);
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              '------------------>
              Decoded l_qty_invoiced = '||to_char(l_qty_invoiced));
          END IF;
          --
          -- For Invoice import, we should always average out the price for
          -- all matched for a given line_location.
          -- This will account for all invoices , credit memos as well as positive
          -- price corrections.
          --Retropricing: PPA'should be excluded from the quantity_invoiced.

          SELECT NVL(SUM(DECODE(L.MATCH_TYPE,
                                'PRICE_CORRECTION', 0,
                                'PO_PRICE_ADJUSTMENT', 0,
                                'ADJUSTMENT_CORRECTION', 0,
                                 NVL(L.quantity_invoiced, 0))),0) +
                                 NVL(l_qty_invoiced,0),
                                 ROUND(NVL(p_invoice_lines_rec.amount +
                                 NVL(SUM(NVL(L.amount, 0)),0),0),5)
            INTO l_total_qty_billed,
                   l_total_match_amount
            FROM ap_invoice_lines L
           WHERE l.po_line_location_id = l_po_line_location_id;

          -- If total qty billed is below zero
          -- we should reject. In invoice workbench the form takes care of this.
          -- Amount Based Matching
          IF (l_total_qty_billed < 0 AND
             p_match_basis = 'QUANTITY') Then
            debug_info := '(v_check_line_po_info2 8) Reject for negative total '
                          ||'quantity invoiced against given PO ';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
            END IF;

            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
               'NEGATIVE QUANTITY BILLED', --Bug 5134622
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence,
               'Y',
               'QUANTITY INVOICED',
               l_total_qty_billed ) <> TRUE) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                 AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<-'||current_calling_sequence);
              END IF;
              RAISE check_po_failure;
            END IF;
            l_current_invoice_status := 'N';

          END IF; -- total qty billed is less than 0

          -- If total qty billed is zero and total match amount is not equal to zero
          -- Case I: total match amount is positive; this will never happen in
          -- the above scenario
          -- Case II: total match amount is -ve ; essentially we have an extra
          -- credit for supplier
          -- Discussed with Subir, since the invoice workbench allows this ,
          -- we would not reject
          IF ((l_total_qty_billed = 0 ) AND
              (l_total_match_amount <> 0))Then
            debug_info := '(v_check_line_po_info2 9) Extra credit for '||
                          'supplier:Negative total match amount against given PO ';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                              debug_info);
            END IF;

          END IF;

          IF p_invoice_lines_rec.unit_price >
             p_positive_price_tolerance * l_po_unit_price THEN
              l_positive_price_variance := 1;
          ELSE
              l_positive_price_variance :=0;
          END IF;

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              '------------------>
              l_positive_price_varaince = '||to_char(l_positive_price_variance)
          ||' l_total_qty_billed = '||to_char(l_total_qty_billed));
          END IF;

          -- Reject even if tolerance is not set
          --
          IF (AP_IMPORT_INVOICES_PKG.g_source = 'EDI GATEWAY') THEN
            IF (l_positive_price_variance > 0) then --modified for 1939078
              debug_info := '(v_check_line_po_info2 9) Check for Invalid Unit '
                            ||'Price against PO';
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
              END IF;

              IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                           AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                            p_invoice_lines_rec.invoice_line_id,
                            'UNIT PRC NOT EQUAL TO PO',
                            p_default_last_updated_by,
                            p_default_last_update_login,
                            current_calling_sequence) <> TRUE) THEN
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                    AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||current_calling_sequence);
                END IF;
                RAISE check_po_failure;
              END IF;
              l_current_invoice_status := 'N';

            END IF; -- l_total_price_variance

          END IF; -- g_source

        ELSIF ((l_po_line_location_id IS NULL) AND
               (l_po_line_id IS NOT NULL)) THEN
               -- else if po line location is not null
          l_qty_invoiced := nvl(p_invoice_lines_rec.quantity_invoiced,
                                l_quantity_invoiced);
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    '------------------>
                l_qty_invoiced = '||to_char(l_qty_invoiced));
          END IF;
          --
          SELECT  NVL(SUM(DECODE(L.MATCH_TYPE, 'PRICE_CORRECTION', 0,
                                 'PO_PRICE_ADJUSTMENT', 0,
                                 'ADJUSTMENT_CORRECTION', 0,
                                  NVL(L.quantity_invoiced, 0))),0) +
                  NVL(l_qty_invoiced,0),
                  NVL(SUM(NVL(PLL.amount,0)),0) +
                  NVL(p_invoice_lines_rec.amount, l_line_amount)
            INTO  l_total_qty_billed,
                  l_total_match_amount  /* Amount Based Matching */
            FROM  ap_invoice_lines L,
                  po_line_locations PLL
           WHERE  L.po_line_location_id = PLL.line_location_id
             AND  PLL.po_line_id = l_po_line_id;

          -- If total qty billed is below zero
          -- we should reject. In invoice workbench the form takes care of this.
           -- Amount Based Matching
          IF (l_total_qty_billed < 0 AND
              p_match_basis = 'QUANTITY') Then
              debug_info := '(v_check_line_po_info2 8) Reject for negative total '
                 ||'quantity invoiced against given PO(for PO Line match) ';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                     AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                     p_invoice_lines_rec.invoice_line_id,
                    'NEGATIVE QUANTITY BILLED', --Bug 5134622
                     p_default_last_updated_by,
                     p_default_last_update_login,
                     current_calling_sequence,
                     'Y',
                     'QUANTITY INVOICED',
                     l_total_qty_billed ) <> TRUE) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'insert_rejections<-'||current_calling_sequence);
              END IF;
              RAISE check_po_failure;
            END IF;
            l_current_invoice_status := 'N';

          /* Amount Based Matching */
          -- If total amount is billed zero, We should reject.
          -- In Invoice workbench form take care of this
          ELSIF (l_total_match_amount < 0 AND
                 p_match_basis = 'AMOUNT') Then
            debug_info := '(v_check_line_po_info2 8) Reject for negative total '
                          ||'amount matched against given PO ';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
          END IF;

            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
               'INVALID LINE AMOUNT',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence,
               'Y',
               'AMOUNT INVOICED',
               l_total_match_amount ) <> TRUE) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                 AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<-'||current_calling_sequence);
              END IF;
              RAISE check_po_failure;
            END IF;
            l_current_invoice_status := 'N';

          END IF; -- total qty billed is less than 0

          IF p_invoice_lines_rec.unit_price >
             p_positive_price_tolerance * l_po_unit_price THEN
              l_positive_price_variance := 1;
          ELSE
              l_positive_price_variance :=0;
          END IF;

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                '------------------>
                l_positive_price_variance = '||to_char(l_positive_price_variance)
                ||' l_total_qty_billed = '||to_char(l_total_qty_billed));
          END IF;

          IF (AP_IMPORT_INVOICES_PKG.g_source = 'EDI GATEWAY') Then
            IF (l_positive_price_variance > 0) THEN --modified for 1939078
              debug_info := '(v_check_line_po_info2 9) Check for Invalid Unit  '
                            ||'Price against PO';
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
              END IF;

              IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                          p_invoice_lines_rec.invoice_line_id,
                          'UNIT PRC NOT EQUAL TO PO',
                          p_default_last_updated_by,
                          p_default_last_update_login,
                          current_calling_sequence) <> TRUE) THEN
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                  AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                      'insert_rejections<-'||current_calling_sequence);
                END IF;
                RAISE check_po_failure;
              END IF;
              l_current_invoice_status := 'N';

            END IF; -- l_total_price_variance

          END IF; -- g_source

        END IF; -- po line location id is not null
    END IF; -- source <> PPA
    ----------------------------------------------------------------
    -- Step 10
    -- Check for Overbill, if yes then reject. Only if tolerances are set
    -- This is as per Aetna's requirement. This can later be implemented
    -- as system options. Discussed this with Subir and Lauren 11/5/97
    -- Even here we assume zero for null quantity ordered tolerance
    -- Only for EDI GATEWAY source 5/4/98
    -- Retropricing:
    -- Overbill rejection is meant only for EDI Gateway. The following
    -- code should not reject PPA Invoice Lines. Adding the IF condition
    -- so that the code is not executed for PPA's.
    -----------------------------------------------------------------
    IF (AP_IMPORT_INVOICES_PKG.g_source <> 'PPA') THEN

       IF (l_po_line_location_id IS NOT NULL) THEN
          debug_info := '(v_check_line_po_info2 10) Check for quantity overbill '
                        ||'for PO Shipment';

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.get_overbill_for_shipment(
                l_po_line_location_id,              -- IN
                NVL(p_invoice_lines_rec.quantity_invoiced,
                l_quantity_invoiced),               -- IN
		p_invoice_lines_rec.amount,         --IN
                l_overbill,                         -- OUT NOCOPY
                l_quantity_outstanding,             -- OUT NOCOPY
                l_quantity_ordered,                 -- OUT NOCOPY
                l_qty_already_billed,               -- OUT NOCOPY
		l_amount_outstanding,		    -- OUT NOCOPY
		l_amount_ordered,		    -- OUT NOCOPY
		l_amt_already_billed,		    -- OUT NOCOPY
                current_calling_sequence) <> TRUE) THEN

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'get_overbill_for_shipment<-'||current_calling_sequence);
            END IF;
            RAISE check_po_failure;
          END IF;

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
               '------------------> l_overbill = '||l_overbill
            ||' l_quantity_outstanding = ' ||to_char(l_quantity_outstanding)
            ||' l_quantity_ordered =  '    ||to_char(l_quantity_ordered)
            ||' l_qty_already_billed =  '  ||to_char(l_qty_already_billed)
	    ||' l_amount_outstanding = '   ||to_char(l_amount_outstanding)
	    ||' l_amount_ordered =  '      ||to_char(l_amount_ordered)
	    ||' l_amt_already_billed =  '  ||to_char(l_amt_already_billed)
            ||' p_max_qty_ord_tolerance = '||to_char(p_max_qty_ord_tolerance)
	    ||' p_max_amt_ord_tolerance = '||to_char(p_max_amt_ord_tolerance)
            ||' p_qty_ord_tolerance  = '   ||to_char(p_qty_ord_tolerance)
	    ||' p_amt_ord_tolerance  = '   ||to_char(p_amt_ord_tolerance));

          END IF;

          -- This is as per EDI requirements. We might need to address this later
          -- with quick invoices.

          IF (AP_IMPORT_INVOICES_PKG.g_source = 'EDI GATEWAY') Then

            IF(p_match_basis = 'QUANTITY') THEN

		IF (p_qty_ord_tolerance is not null) then -- Added for bug 9381715
	              IF ((NVL(p_invoice_lines_rec.quantity_invoiced,l_quantity_invoiced) +
		               l_qty_already_billed) >
			    (NVL(p_qty_ord_tolerance,1) * l_quantity_ordered)) THEN
	                    debug_info := '(v_check_line_po_info2 11) Reject for '
		            ||'p_qty_ord_tolerance';
	                 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
			         AP_IMPORT_UTILITIES_PKG.Print(
				AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
	                 END IF;
			l_qty_based_rejection := 'Y';
	              END IF;
		-- Added for bug 9381715
		ELSE
			l_qty_based_rejection := 'N';
		END IF; -- bug 9381715 ends

              IF (p_max_qty_ord_tolerance IS NOT NULL) Then

                 IF ((NVL(p_invoice_lines_rec.quantity_invoiced,l_quantity_invoiced) +
                       l_qty_already_billed) >
                      (p_max_qty_ord_tolerance + l_quantity_ordered)) THEN
                    debug_info := '(v_check_line_po_info2 12) Reject for '
                               ||'p_max_qty_ord_tolerance';
                    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                      AP_IMPORT_UTILITIES_PKG.Print(
                         AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
                    END IF;
                    l_qty_based_rejection := 'Y';

                 END IF;

              END IF;

              IF (nvl(l_qty_based_rejection,'N') = 'Y') Then
                 debug_info := '(v_check_line_po_info2 13) Reject for Quantity '
                            ||'overbill for PO Shipment';
                 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                      AP_IMPORT_UTILITIES_PKG.Print(
                 	     AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
                 END IF;

                 IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                            p_invoice_lines_rec.invoice_line_id,
                            'INVALID INVOICE QUANTITY',
                            p_default_last_updated_by,
                            p_default_last_update_login,
                            current_calling_sequence) <> TRUE) THEN

                      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                         AP_IMPORT_UTILITIES_PKG.Print(
                            AP_IMPORT_INVOICES_PKG.g_debug_switch,
                               'insert_rejections<-'||current_calling_sequence);
                      END IF;

                      RAISE check_po_failure;
                  END IF;
                  l_current_invoice_status := 'N';

               END IF; -- l_qty_based_rejection = 'Y'

	   ELSIF (p_match_basis = 'AMOUNT') THEN

	       IF ((p_invoice_lines_rec.amount + l_amt_already_billed) >
                   (NVL(p_amt_ord_tolerance,1) * l_amount_ordered)) THEN

                 debug_info := '(v_check_line_po_info2 14) Reject for '
                            ||'p_amt_ord_tolerance';
                 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                     AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
                 END IF;

                 l_amt_based_rejection := 'Y';

               END IF;

               IF (p_max_amt_ord_tolerance IS NOT NULL) Then

                  IF ((p_invoice_lines_rec.amount + l_amt_already_billed) >
                      (p_max_amt_ord_tolerance + l_amount_ordered)) THEN

                      debug_info := '(v_check_line_po_info2 15) Reject for '
                               ||'p_max_amt_ord_tolerance';
                      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                         AP_IMPORT_UTILITIES_PKG.Print(
                            AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
                      END IF;
                      l_amt_based_rejection := 'Y';

                  END IF;

               END IF;

               IF (nvl(l_amt_based_rejection,'N') = 'Y') Then

                  debug_info := '(v_check_line_po_info2 16) Reject for Amount '
                            ||'overbill for PO Shipment';
                  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                      AP_IMPORT_UTILITIES_PKG.Print(
                          AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
                  END IF;

                  IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                            p_invoice_lines_rec.invoice_line_id,
                            'LINE AMOUNT EXCEEDED TOLERANCE',
                            p_default_last_updated_by,
                            p_default_last_update_login,
                            current_calling_sequence) <> TRUE) THEN

                      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                           AP_IMPORT_UTILITIES_PKG.Print(
                               AP_IMPORT_INVOICES_PKG.g_debug_switch,
                               'insert_rejections<-'||current_calling_sequence);
                      END IF;

                      RAISE check_po_failure;
                  END IF;

                  l_current_invoice_status := 'N';

               END IF; -- nvl(l_amt_based_rejection,'N') = 'Y'

            END IF; --p_match_basis = 'QUANTITY'

          END IF; -- g_source = 'EDI GATEWAY'

       ELSIF ((l_po_line_location_id IS NULL)AND
               (l_po_line_id IS NOT NULL)) THEN
          -- po line location id is not null
          debug_info := '(v_check_line_po_info2 17) Check for quantity overbill '
                        ||'for PO Line';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.get_overbill_for_po_line(
              l_po_line_id,
              NVL(p_invoice_lines_rec.quantity_invoiced, l_quantity_invoiced),
	      p_invoice_lines_rec.amount,  --IN
              l_overbill,                  -- OUT
              l_outstanding,     	   -- OUT
              l_ordered,         	   -- OUT
              l_already_billed,            -- OUT
	      l_po_line_matching_basis,    -- OUT
              current_calling_sequence) <> TRUE) THEN

              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'get_overbill_for_po_line<-'||current_calling_sequence);
              END IF;
              RAISE check_po_failure;
          END IF;

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
               '------------------> l_overbill = '||l_overbill
               ||' l_outstanding quantity/amount = '||to_char(l_outstanding)
              ||' l_ordered quantity/amount = '||to_char(l_ordered)
              ||' l_already_billed quantity/amount = '||to_char(l_already_billed)
              ||' p_max_qty_ord_tolerance  = '||to_char(p_max_qty_ord_tolerance)
	      ||' p_max_amt_ord_tolerance = '||to_char(p_max_amt_ord_tolerance)
              ||' p_qty_ord_tolerance  = '||to_char(p_qty_ord_tolerance)
	      ||' p_amt_ord_tolerance  = '||to_char(p_amt_ord_tolerance));

          END IF;

          -- This is as per EDI requirements. We might need to address this later
          -- with quick invoices.
          IF (AP_IMPORT_INVOICES_PKG.g_source = 'EDI GATEWAY') Then

	     IF (l_po_line_matching_basis = 'QUANTITY') THEN

		IF (p_qty_ord_tolerance is not null) then -- Added for bug 9381715
			IF ((NVL(p_invoice_lines_rec.quantity_invoiced,l_quantity_invoiced) +
               			 l_already_billed) >
	                    (NVL(p_qty_ord_tolerance,1) * l_ordered)) THEN
		             debug_info := '(v_check_line_po_info2 18) Reject for '
				            ||'p_qty_ord_tolerance';
	                   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	                      AP_IMPORT_UTILITIES_PKG.Print(
		                  AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
			   END IF;
			   l_qty_based_rejection := 'Y';
	                END IF;
		-- Added for bug 9381715
		ELSE
			l_qty_based_rejection := 'N';
		END IF; -- bug 9381715 ends

                IF (p_max_qty_ord_tolerance IS NOT NULL) Then
                   IF ((NVL(p_invoice_lines_rec.quantity_invoiced,l_quantity_invoiced) +
                          l_already_billed) >
                       (p_max_qty_ord_tolerance + l_ordered)) THEN

                       debug_info := '(v_check_line_po_info2 19) Reject for '
                              ||'p_max_qty_ord_tolerance';
                        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                  	   AP_IMPORT_UTILITIES_PKG.Print(
                    		AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
                	END IF;
                	l_qty_based_rejection := 'Y';
                   END IF;
                END IF;

                IF (nvl(l_qty_based_rejection,'N') = 'Y') THEN
                   debug_info := '(v_check_line_po_info2 20) Reject for Quantity '
                             ||'overbill for PO Line';
                   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                	AP_IMPORT_UTILITIES_PKG.Print(
                  		AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
              	   END IF;

              	   IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                            p_invoice_lines_rec.invoice_line_id,
                            'INVALID INVOICE QUANTITY',
                            p_default_last_updated_by,
                            p_default_last_update_login,
                            current_calling_sequence) <> TRUE) THEN
                        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                  	   AP_IMPORT_UTILITIES_PKG.Print(
                    		AP_IMPORT_INVOICES_PKG.g_debug_switch,
                      		'insert_rejections<-'||current_calling_sequence);
                	END IF;
                	RAISE check_po_failure;
              	   END IF;

                   l_current_invoice_status := 'N';

                END IF; /* nvl(l_qty_based_rejection,'N') = 'Y' */

            ELSIF (l_po_line_matching_basis = 'AMOUNT') THEN

               IF ((p_invoice_lines_rec.amount + l_already_billed) >
                  (NVL(p_amt_ord_tolerance,1) * l_ordered)) THEN
                  debug_info := '(v_check_line_po_info2 21) Reject for '
                                 ||'p_amt_ord_tolerance';

                  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                     AP_IMPORT_UTILITIES_PKG.Print(
                       AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
                  END IF;
                  l_amt_based_rejection := 'Y';

               END IF;

               IF (p_max_amt_ord_tolerance IS NOT NULL) Then

                  IF ((p_invoice_lines_rec.amount + l_already_billed) >
                     (p_max_amt_ord_tolerance + l_ordered)) THEN

                     debug_info := '(v_check_line_po_info2 22) Reject for '
                                  ||'p_max_amt_ord_tolerance';
                     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                        AP_IMPORT_UTILITIES_PKG.Print(
                          AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
                     END IF;

                     l_amt_based_rejection := 'Y';

                  END IF;

               END IF;

               IF (nvl(l_amt_based_rejection,'N') = 'Y') THEN
                  debug_info := '(v_check_line_po_info2 23) Reject for Amount '
                               ||'overbill for PO Line';
                  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                    AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
                  END IF;

                  IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                            p_invoice_lines_rec.invoice_line_id,
                            'LINE AMOUNT EXCEEDED TOLERANCE',
                            p_default_last_updated_by,
                            p_default_last_update_login,
                            current_calling_sequence) <> TRUE) THEN
                     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
                       AP_IMPORT_UTILITIES_PKG.Print(
                           AP_IMPORT_INVOICES_PKG.g_debug_switch,
                           'insert_rejections<-'||current_calling_sequence);
                     END IF;
                     RAISE check_po_failure;
                  END IF;

                  l_current_invoice_status := 'N';

               END IF;

	    END IF; --l_po_line_matching_basis = 'QUANTITY'

          END IF ; --g_source = 'EDI'...

   --     END IF; -- overbill

      END IF; -- l_po_header_id is NOT NULL

  END IF; --source <> PPA

  p_current_invoice_status := l_current_invoice_status;
  p_calc_quantity_invoiced := l_quantity_invoiced;
  p_calc_unit_price        := l_dec_unit_price;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_line_po_info2;

FUNCTION v_check_po_overlay (
   p_invoice_rec	       IN  AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec         IN  AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_po_line_id                IN            NUMBER,
   p_po_line_location_id       IN            NUMBER,
   p_po_distribution_id        IN            NUMBER,
   p_set_of_books_id           IN            NUMBER,
   p_default_last_updated_by   IN            NUMBER,
   p_default_last_update_login IN            NUMBER,
   p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
   p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN
IS
   check_po_failure              EXCEPTION;
   l_po_line_id                NUMBER    := p_po_line_id;
   l_po_line_location_id    NUMBER    := p_po_line_location_id;
   l_po_distribution_id        NUMBER    := p_po_distribution_id;
   l_unbuilt_flex           VARCHAR2(240):='';
   l_reason_unbuilt_flex    VARCHAR2(2000):='';
   l_code_combination_id    NUMBER;
   l_current_invoice_status    VARCHAR2(1) := p_current_invoice_status;
   l_dist_code_concatenated    VARCHAR2(2000):='';
   current_calling_sequence VARCHAR2(2000);
   debug_info               VARCHAR2(500);

CURSOR    po_distributions_cur IS
   SELECT code_combination_id
     FROM po_distributions
    WHERE line_location_id = l_po_line_location_id
    AND nvl(accrue_on_receipt_flag,'N') <> 'Y' --Bug 2667171 added this Condition
    ORDER BY distribution_num;

--Contract Payments: Modified the where clause
CURSOR    po_line_locations_cur IS
   SELECT pd.code_combination_id
     FROM po_distributions pd,
      po_line_locations pll
    WHERE pd.line_location_id = pll.line_location_id
      AND pll.po_line_id = l_po_line_id
      AND(
          --(p_invoice_rec.invoice_type_lookup_code <> 'PREPAYMENT' and                  .. B# 8528132
          (nvl(p_invoice_rec.invoice_type_lookup_code, 'STANDARD') <> 'PREPAYMENT' and   -- B# 8528132
           pll.SHIPMENT_TYPE IN ('STANDARD','BLANKET','SCHEDULED')
          ) OR
          (p_invoice_rec.invoice_type_lookup_code = 'PREPAYMENT' and
           ((pll.payment_type IS NOT NULL and pll.shipment_type = 'PREPAYMENT') or
            (pll.payment_type IS NULL and pll.shipment_type IN ('STANDARD','BLANKET','SCHEDULED'))
           )
          )
         )
      AND pll.APPROVED_FLAG = 'Y'
    ORDER BY pll.shipment_num,pd.distribution_num;

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=  'v_check_po_overlay<-'||P_calling_sequence;

  ----------------------------------------------------------
  -- Check Account Overlay
  -- Step 1
  ----------------------------------------------------------
  IF ((l_current_invoice_status <> 'N') AND
      ((p_invoice_lines_rec.dist_code_concatenated IS NOT NULL) OR
       (p_invoice_lines_rec.balancing_segment IS NOT NULL) OR
       (p_invoice_lines_rec.cost_center_segment IS NOT NULL) OR
       (p_invoice_lines_rec.account_segment IS NOT NULL)) ) THEN
    IF (p_invoice_lines_rec.dist_code_concatenated IS NOT NULL) THEN
      l_dist_code_concatenated := p_invoice_lines_rec.dist_code_concatenated;
    END IF;

    IF (l_po_distribution_id IS NOT NULL) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           '(v_check_po_overlay 1) Get l_code_combination_id FROM '
           ||'l_po_distribution_id ');
      END IF;

      SELECT code_combination_id
        INTO l_code_combination_id
        FROM po_distributions
       WHERE po_distribution_id = l_po_distribution_id
         AND line_location_id IS NOT NULL; /* BUG 3253594 */
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '------------------> l_code_combination_id  = '
          || to_char(l_code_combination_id)
          ||'balancing_segment ='||p_invoice_lines_rec.balancing_segment
          ||'cost_center_segment ='||p_invoice_lines_rec.cost_center_segment
          ||'account_segment ='||p_invoice_lines_rec.account_segment
          ||'dist_code_concatenated ='
          ||p_invoice_lines_rec.dist_code_concatenated);
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '(v_check_po_overlay 2) Check Overlay Segments fOR '
        ||'l_po_distribution_id ');
      END IF;

      IF (AP_UTILITIES_PKG.overlay_segments(
           p_invoice_lines_rec.balancing_segment,
           p_invoice_lines_rec.cost_center_segment,
           p_invoice_lines_rec.account_segment,
           l_dist_code_concatenated,
           l_code_combination_id , -- OUT NOCOPY
           p_set_of_books_id ,
           'CHECK' , -- Overlay Mode
           l_unbuilt_flex , -- OUT NOCOPY
           l_reason_unbuilt_flex , -- OUT NOCOPY
           FND_GLOBAL.RESP_APPL_ID,
           FND_GLOBAL.RESP_ID,
           FND_GLOBAL.USER_ID,
           current_calling_sequence ,
           NULL,
           p_invoice_lines_rec.accounting_date) <> TRUE) THEN --7531219
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '(v_check_po_overlay 2) Overlay_Segments<-'
             ||current_calling_sequence);
        END IF;
        Raise check_po_failure;
      ELSE
        -- show output values (only IF debug_switch = 'Y')
        --
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------> l_unbuilt_flex = '|| l_unbuilt_flex
            ||'l_reason_unbuilt_flex = '||l_reason_unbuilt_flex
            ||'l_code_combination_id = '|| to_char(l_code_combination_id));
        END IF;

        -- 7531219 changed the if condition
        IF (l_unbuilt_flex is not null or l_reason_unbuilt_flex is not null /*l_code_combination_id = -1*/) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              '(v_check_po_overlay 3) Invalid code_combination_id overlay');
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
               'INVALID ACCT OVERLAY',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_po_failure;
        END IF; -- Code combination id is -1
        l_current_invoice_status := 'N';
        END IF; -- added by iyas for code_combination_id
      END IF; -- IF overlay segments is other than TRUE
    ELSIF (l_po_line_location_id IS NOT NULL) THEN
      -- IF po distribution id is not NULL
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '(v_check_po_overlay 1) Get l_code_combination_id FROM '
          ||'l_po_line_location_id ');
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '(v_check_po_overlay 1) Open po_distributions ');
      END IF;

      OPEN po_distributions_cur;

      LOOP
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             '(v_check_po_overlay 2) Fetch po_distributions_cur ');
      END IF;

      FETCH po_distributions_cur  INTO
                l_code_combination_id;
      --
      EXIT WHEN po_distributions_cur%NOTFOUND OR
                po_distributions_cur%NOTFOUND IS NULL;

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------> l_code_combination_id  = '
         || to_char(l_code_combination_id)
         ||'balancing_segment ='||p_invoice_lines_rec.balancing_segment
         ||'cost_center_segment ='||p_invoice_lines_rec.cost_center_segment
         ||'account_segment ='||p_invoice_lines_rec.account_segment
         ||'l_dist_code_concatenated ='||l_dist_code_concatenated);

        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '(v_check_po_overlay 3) Check Overlay Segments fOR '
          ||'l_po_line_location_id ');
      END IF;

      IF (AP_UTILITIES_PKG.overlay_segments(
             p_invoice_lines_rec.balancing_segment,
             p_invoice_lines_rec.cost_center_segment,
             p_invoice_lines_rec.account_segment,
             l_dist_code_concatenated,
             l_code_combination_id ,         -- OUT NOCOPY
             p_set_of_books_id ,
             'CHECK' ,                 -- Overlay Mode
             l_unbuilt_flex ,             -- OUT NOCOPY
             l_reason_unbuilt_flex ,         -- OUT NOCOPY
             FND_GLOBAL.RESP_APPL_ID,
             FND_GLOBAL.RESP_ID,
             FND_GLOBAL.USER_ID,
             current_calling_sequence,
             NULL,
             p_invoice_lines_rec.accounting_date ) <> TRUE) THEN --7531219
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '(v_check_po_overlay 3) Overlay_Segments<-'
             ||current_calling_sequence);
        END IF;
        CLOSE po_distributions_cur;
        RAISE check_po_failure;
      ELSE
        -- show output values (only IF debug_switch = 'Y')
        --
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '------------------> l_unbuilt_flex = '||l_unbuilt_flex
            ||'l_reason_unbuilt_flex = '||l_reason_unbuilt_flex
            ||'l_code_combination_id = '|| to_char(l_code_combination_id));
        END IF;

        -- 7531219 changed the if condition
        IF (l_unbuilt_flex is not null or l_reason_unbuilt_flex is not null/*l_code_combination_id = -1*/) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             '(v_check_po_overlay 4) Invalid code_combination_id overlay');
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
             AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
             p_invoice_lines_rec.invoice_line_id,
             'INVALID ACCT OVERLAY',
             p_default_last_updated_by,
             p_default_last_update_login,
             current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
          END IF;
          CLOSE po_distributions_cur;
          RAISE check_po_failure;
            --
          END IF;
          l_current_invoice_status := 'N';
        END IF; -- code combination id is -1
      END IF; --overlay segments

      END LOOP;
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '(v_check_po_overlay 5) Close po_distributions ');
      END IF;
      CLOSE po_distributions_cur;
    ELSIF ((l_po_line_id IS NOT NULL) AND
           (l_po_line_location_id IS NULL)) THEN
         -- po distribution id is not NULL
      -- PO Line Level Matching
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '(v_check_po_overlay 1) Get l_code_combination_id FROM l_po_line_id ');
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '(v_check_po_overlay 1) Open po_line_locations ');
      END IF;

      OPEN po_line_locations_cur;

      LOOP
      --
      --
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '(v_check_po_overlay 2) Fetch po_line_locations_cur ');
      END IF;

      FETCH po_line_locations_cur  INTO l_code_combination_id;
      --
      EXIT WHEN po_line_locations_cur%NOTFOUND OR
                po_line_locations_cur%NOTFOUND IS NULL;

      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '------------------> l_code_combination_id  = '||
          to_char(l_code_combination_id)
          ||'balancing_segment ='||p_invoice_lines_rec.balancing_segment
          ||'cost_center_segment ='||p_invoice_lines_rec.cost_center_segment
          ||'account_segment ='||p_invoice_lines_rec.account_segment
          ||'l_dist_code_concatenated ='||l_dist_code_concatenated);
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '(v_check_po_overlay 3) Check Overlay Segments fOR l_po_line_id ');
      END IF;

      IF (AP_UTILITIES_PKG.overlay_segments(
          p_invoice_lines_rec.balancing_segment,
          p_invoice_lines_rec.cost_center_segment,
          p_invoice_lines_rec.account_segment,
          l_dist_code_concatenated,
          l_code_combination_id,             -- OUT NOCOPY
          p_set_of_books_id,
          'CHECK' ,                 -- Overlay Mode
          l_unbuilt_flex ,                 -- OUT NOCOPY
          l_reason_unbuilt_flex ,             -- OUT NOCOPY
          FND_GLOBAL.RESP_APPL_ID,
          FND_GLOBAL.RESP_ID,
          FND_GLOBAL.USER_ID,
          current_calling_sequence ,
          NULL,
          p_invoice_lines_rec.accounting_date) <> TRUE) THEN --7531219
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '(v_check_po_overlay 3) Overlay_Segments<-'
            ||current_calling_sequence);
        END IF;
        CLOSE po_line_locations_cur;
        Raise check_po_failure;
      ELSE
        -- show output values (only IF debug_switch = 'Y')
        --
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             '------------------>
           l_unbuilt_flex = '||l_unbuilt_flex
             ||'l_reason_unbuilt_flex = '||l_reason_unbuilt_flex
             ||'l_code_combination_id = '|| to_char(l_code_combination_id));
        END IF;

        -- 7531219 changed the if condition
        IF (l_unbuilt_flex is not null or l_reason_unbuilt_flex is not null/*l_code_combination_id = -1*/) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              '(v_check_po_overlay 4) Invalid code_combination_id overlay');
          END IF;
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
             AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INVALID ACCT OVERLAY',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
            END IF;
            CLOSE po_line_locations_cur;
            RAISE check_po_failure;
            --
          END IF; -- insert rejections
          l_current_invoice_status := 'N';
        END IF; -- code combination id is -1
      END IF;  -- overlay segments

      END LOOP;
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '(v_check_po_overlay 5) Close po_line_locations ');
      END IF;
      CLOSE po_line_locations_cur;
    END IF; -- po distribution id is not NULL
  ELSE -- invoice status <> 'N'
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
         '(v_check_po_overlay 1) No Overlay Required ');
    END IF;

  END IF; -- invoice status <> 'N'

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_po_overlay;


------------------------------------------------------------------------------
-- This function is used to validate RCV information.
-- Retropricing:Step 1 and 3 don't execute for PPA's
------------------------------------------------------------------------------
FUNCTION v_check_receipt_info (
   p_invoice_rec	IN    AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec  IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_default_last_updated_by      IN            NUMBER,
   p_default_last_update_login    IN            NUMBER,
   p_temp_line_status                OUT NOCOPY VARCHAR2,
   p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN
IS
   check_receipt_failure        EXCEPTION;
   l_temp_rcv_txn_id            NUMBER;
   l_temp_ship_line_id          NUMBER;     --Bug 7344899 variable added
   l_temp_value                    VARCHAR2(1);
   l_qty_billed_sum                NUMBER;
   l_rcv_uom                    VARCHAR2(30);
   l_qty_billed                    NUMBER;
   debug_info                    VARCHAR2(2000);
   current_calling_sequence        VARCHAR2(2000);
   l_cascade_receipts_flag      VARCHAR2(1);
   l_price_correct_inv_id	AP_INVOICES.INVOICE_ID%TYPE;

   --Contract Payments
   l_shipment_type		PO_LINE_LOCATIONS_ALL.SHIPMENT_TYPE%TYPE;

BEGIN

  -- Update   the calling sequence
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_receipt_info <-' ||p_calling_sequence;

  --Contract Payments: Cannot match a Prepayment invoice to receipt.
  IF (p_invoice_rec.invoice_type_lookup_code = 'PREPAYMENT' AND
      (p_invoice_lines_rec.rcv_transaction_id IS NOT NULL OR
       p_invoice_lines_rec.match_option = 'R' OR
       p_invoice_lines_rec.receipt_number IS NOT NULL
      )
     ) THEN

      debug_info := '(Check Receipt Info 1) Check if invoice type is'||
      		   ' Prepayment and receipt info is provided';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
         AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                   AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                   p_invoice_lines_rec.invoice_line_id,
                   'INVALID MATCHING INFO',
                   p_default_last_updated_by,
                   p_default_last_update_login,
                   current_calling_sequence)<> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections <-'||current_calling_sequence);
          END IF;
          Raise check_receipt_failure;
      END IF;

      p_temp_line_status := 'N';

  END IF;

  ---------------------------------------------------------------------------
  -- Step 1 : Validate receipt info IF source is EDI GATEWAY AND type = ITEM
  ---------------------------------------------------------------------------

  /* Commented for bug#9857975 Start
  IF (AP_IMPORT_INVOICES_PKG.g_source = 'EDI GATEWAY') AND
     (p_invoice_lines_rec.line_type_lookup_code = 'ITEM') AND
     (p_invoice_lines_rec.match_option = 'R') THEN


    -- Case a : receipt_num AND id are NULL
    IF (p_invoice_lines_rec.receipt_number is NULL ) AND
       (p_invoice_lines_rec.rcv_transaction_id is NULL) AND
       (p_invoice_lines_rec.po_line_location_id is not NULL) THEN

       debug_info := '(Check Receipt Info 1) Case a';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      BEGIN
       SELECT rcv_transaction_id
         INTO l_temp_rcv_txn_id
         FROM po_ap_receipt_match_v
        WHERE po_line_location_id = p_invoice_lines_rec.po_line_location_id;

      EXCEPTION
        When no_data_found THEN
           -- reject fOR INSUFFICIENT RECEIPT INFORMATION
           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INSUFFICIENT RECEIPT INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections <-'||current_calling_sequence);
             END IF;
              Raise check_receipt_failure;
           END IF;
           p_temp_line_status := 'N';
        When too_many_rows THEN
             l_cascade_receipts_flag := 'Y';
          l_temp_rcv_txn_id := NULL;
      END;

      -- Case c : receipt num is not NULL, id is NULL
    ELSIF (p_invoice_lines_rec.receipt_number is not NULL) AND
        (p_invoice_lines_rec.rcv_transaction_id is NULL) THEN
      debug_info := '(Check Receipt Info 1) Case c';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      BEGIN
       SELECT rcv_transaction_id
         INTO l_temp_rcv_txn_id
         FROM po_ap_receipt_match_v
        WHERE receipt_number = p_invoice_lines_rec.receipt_number
          AND po_line_location_id = p_invoice_lines_rec.po_line_location_id;

       Exception
         When no_data_found THEN
       --reject fOR INVALID RECEIPT INFORMATION
       IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID RECEIPT INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence)<> TRUE) THEN
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections <-'||current_calling_sequence);
             END IF;
         Raise check_receipt_failure;
       END IF;
       p_temp_line_status := 'N';
         WHEN too_many_rows THEN
           l_cascade_receipts_flag := 'Y';
       l_temp_rcv_txn_id := NULL;
      END;

    -- Case d : receipt_num is NULL AND id is not NULL
    ELSIF (p_invoice_lines_rec.receipt_number is NULL) AND
    (p_invoice_lines_rec.rcv_transaction_id is not NULL) THEN
      debug_info := '(Check Receipt Info 1) Case d';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      BEGIN
       SELECT rcv_transaction_id
       INTO l_temp_rcv_txn_id
       FROM po_ap_receipt_match_v
       WHERE rcv_transaction_id = p_invoice_lines_rec.rcv_transaction_id
       AND po_line_location_id = p_invoice_lines_rec.po_line_location_id;

       EXCEPTION
         When Others THEN
     -- reject fOR INVALID RECEIPT INFORMATION
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID RECEIPT INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence)<> TRUE) THEN
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections <-'||current_calling_sequence);
             END IF;
         Raise check_receipt_failure;
       END IF;
       p_temp_line_status := 'N';
      END;

    -- Case d : receipt num is not NULL AND id is not NULL
    ELSIF (p_invoice_lines_rec.receipt_number is not NULL) AND
          (p_invoice_lines_rec.rcv_transaction_id is not NULL) THEN
      debug_info := '(Check Receipt Info 1) Case e';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;
      BEGIN
       SELECT rcv_transaction_id
         INTO l_temp_rcv_txn_id
         FROM po_ap_receipt_match_v
        WHERE rcv_transaction_id = p_invoice_lines_rec.rcv_transaction_id
          AND receipt_number = p_invoice_lines_rec.receipt_number
          AND po_line_location_id = p_invoice_lines_rec.po_line_location_id;


      Exception
         When Others THEN
     -- reject fOR INCONSISTENT RECEIPT INFORMATION
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INCONSISTENT RECEIPT INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence)<> TRUE) THEN
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
               AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections <-'||current_calling_sequence);
           END IF;
       Raise check_receipt_failure;
     END IF;
     p_temp_line_status := 'N';
       END;
    END IF; -- Case a receipt number AND id are NULL


    -------------------------------------------------------------------
    -- Step 1.A  Validate UOM AND Quantity IF cascade flag = 'Y'
    -- Context: Source = 'EDI GATEWAY', line type = 'ITEM' AND
    -- Match Option = 'R'
    -------------------------------------------------------------------
    IF (nvl(l_cascade_receipts_flag,'N') = 'Y' )THEN
      -- Validate UOM
      IF (p_invoice_lines_rec.unit_of_meas_lookup_code is not NULL) THEN
        debug_info := 'validate the UOM';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

        BEGIN
        SELECT distinct receipt_uom_lookup_code
          INTO l_rcv_uom
          FROM po_ap_receipt_match_v
         WHERE po_line_location_id = p_invoice_lines_rec.po_line_location_id
           AND receipt_number = NVL(p_invoice_lines_rec.receipt_number,
                                        receipt_number)
           AND rcv_transaction_id = nvl(p_invoice_lines_rec.rcv_transaction_id,
                                        rcv_transaction_id);
        EXCEPTION
        WHEN OTHERS THEN
          -- reject with   UOM DOES NOT MATCH RECEIPT
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'UOM DOES NOT MATCH RECPT',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections <-'||current_calling_sequence);
                END IF;
            Raise check_receipt_failure;
          END IF;
         END;

       IF (l_rcv_uom <> p_invoice_lines_rec.unit_of_meas_lookup_code) THEN
          -- reject with   UOM DOES NOT MATCH RECEIPT
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'UOM DOES NOT MATCH RECPT',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                      'insert_rejections <-'||current_calling_sequence);
                END IF;
            Raise check_receipt_failure;
          END IF;
        END IF;

      END IF; -- unit of measure is not NULL

      -- Validate quantity billed does not become less than zero
      debug_info := 'Check IF quantity billed will be less than zero';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      BEGIN
      --bug 5118518:Removed the view reference
          SELECT nvl(sum(nvl(RT.quantity_billed,0)),0)
            INTO l_qty_billed_sum
            FROM rcv_transactions RT ,
                 rcv_shipment_headers SH ,
                 po_headers_all PH ,
                 po_line_locations_all PS ,
                 po_releases_all PR ,
                 per_all_people_f BU
          WHERE  RT.po_line_location_id = p_invoice_lines_rec.po_line_location_id
            AND  SH.receipt_num     = nvl(p_invoice_lines_rec.receipt_number,sh.receipt_num)
            AND RT.transaction_id  = nvl(p_invoice_lines_rec.rcv_transaction_id, RT.transaction_id)
            AND RT.SHIPMENT_HEADER_ID  = SH.SHIPMENT_HEADER_ID
            AND RT.PO_HEADER_ID        = PH.PO_HEADER_ID
            AND RT.PO_LINE_LOCATION_ID = PS.LINE_LOCATION_ID
            AND RT.PO_RELEASE_ID       = PR.PO_RELEASE_ID(+)
            AND PH.AGENT_ID            = BU.PERSON_ID(+)
            AND SH.receipt_source_code = 'VENDOR'
            AND RT.TRANSACTION_TYPE IN ('RECEIVE', 'MATCH')
            AND BU.EFFECTIVE_START_DATE(+) <= TRUNC(SYSDATE)
            AND BU.EFFECTIVE_END_DATE(+)   >= TRUNC(SYSDATE)
            AND ((PS.PO_RELEASE_ID IS NOT NULL AND PR.PCARD_ID IS NULL) OR (PS.PO_RELEASE_ID IS NULL AND PH.PCARD_ID IS NULL ));

          IF ((p_invoice_lines_rec.quantity_invoiced + l_qty_billed_sum) < 0) THEN
          -- reject with   INVALID QUANTITY
            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                 AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                 p_invoice_lines_rec.invoice_line_id,
                 'INVALID QUANTITY',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence,
                 'Y',
                 'QUANTITY INVOICED',
                 p_invoice_lines_rec.quantity_invoiced + l_qty_billed_sum )
                 <> TRUE) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections <-'||current_calling_sequence);
              END IF;
              Raise check_receipt_failure;
            END IF;
          END IF;
      END;
    END IF; -- cascade receipts flag = 'Y' --Step 1.A

  -------------------------------------------------------------------------
  -- Step 2 : Validate receipt info IF source is not
  -- EDI GATEWAY AND type = ITEM
  -- Retropricing: Match_option is populated as null for PPA Invoice lines,
  -- however the in v_check_line_po_info2, the value of match_option is determined and
  -- is assigned to p_invoice_lines_rec.match_option for further validation.
  -------------------------------------------------------------------------
  ELSIF (AP_IMPORT_INVOICES_PKG.g_source <> 'EDI GATEWAY') AND
  Commented for bug#9857975 End */

  IF (p_invoice_lines_rec.line_type_lookup_code IN ('ITEM', 'RETROITEM')) AND
     (p_invoice_lines_rec.match_option = 'R') THEN

    -- Case a : receipt_num AND id are NULL
    IF  (p_invoice_lines_rec.receipt_number is NULL ) AND
        (p_invoice_lines_rec.rcv_transaction_id is NULL) AND
        (p_invoice_lines_rec.po_line_location_id is not NULL) THEN
      debug_info := '(Check Receipt Info 2) Case a';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;
      -- reject fOR INSUFFICIENT RECEIPT INFORMATION
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INSUFFICIENT RECEIPT INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence)<> TRUE) THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections <-'||current_calling_sequence);
         END IF;
         Raise check_receipt_failure;
      END IF;
      p_temp_line_status := 'N';

      -- Case b : receipt num is not NULL, id is NULL
    ELSIF (p_invoice_lines_rec.receipt_number is not NULL) AND
           (p_invoice_lines_rec.rcv_transaction_id is NULL) THEN
       debug_info := '(Check Receipt Info 2) Case b';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
       END IF;
       BEGIN
        SELECT rcv_transaction_id
          INTO l_temp_rcv_txn_id
          FROM po_ap_receipt_match_v
         WHERE receipt_number = p_invoice_lines_rec.receipt_number
           AND po_line_location_id = p_invoice_lines_rec.po_line_location_id;

        Exception
          When no_data_found THEN
          --reject fOR INVALID RECEIPT INFORMATION
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INVALID RECEIPT INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                    AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch,
                        'insert_rejections <-'||current_calling_sequence);
                END IF;
            Raise check_receipt_failure;
          END IF;
          p_temp_line_status := 'N';
        When too_many_rows THEN
            -- reject fOR INSUFFICIENT RECEIPT INFORMATION
            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                    AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                    p_invoice_lines_rec.invoice_line_id,
                    'INSUFFICIENT RECEIPT INFO',
                    p_default_last_updated_by,
                    p_default_last_update_login,
                    current_calling_sequence)<> TRUE) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'insert_rejections <-'||current_calling_sequence);
              END IF;
              Raise check_receipt_failure;
            END IF;
            p_temp_line_status := 'N';
        END;

     -- Case c : receipt_num is NULL AND id is not NULL
    ELSIF (p_invoice_lines_rec.receipt_number is NULL) AND
       (p_invoice_lines_rec.rcv_transaction_id is not NULL) THEN
       debug_info := '(Check Receipt Info 2) Case c';
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
       END IF;

       BEGIN
        SELECT rcv_transaction_id
          INTO l_temp_rcv_txn_id
          FROM po_ap_receipt_match_v
         WHERE rcv_transaction_id = p_invoice_lines_rec.rcv_transaction_id
           AND po_line_location_id = p_invoice_lines_rec.po_line_location_id;

       Exception
       WHEN Others THEN
         -- reject fOR INVALID RECEIPT INFORMATION
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INVALID RECEIPT INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN
               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections <-'||current_calling_sequence);
               END IF;
           Raise check_receipt_failure;
         END IF;
         p_temp_line_status := 'N';
       END;

     -- Case d : receipt num is not NULL AND id is not NULL
    ELSIF (p_invoice_lines_rec.receipt_number is not NULL) AND
      (p_invoice_lines_rec.rcv_transaction_id is not NULL) THEN
        debug_info := '(Check Receipt Info 2) Case d';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;

        BEGIN
            SELECT rcv_transaction_id
              INTO l_temp_rcv_txn_id
              FROM po_ap_receipt_match_v
             WHERE rcv_transaction_id = p_invoice_lines_rec.rcv_transaction_id
               AND receipt_number = p_invoice_lines_rec.receipt_number
               AND po_line_location_id = p_invoice_lines_rec.po_line_location_id;

        EXCEPTION
        When Others THEN
            -- reject fOR INCONSISTENT RECEIPT INFORMATION
            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                    AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                    p_invoice_lines_rec.invoice_line_id,
                    'INCONSISTENT RECEIPT INFO',
                    p_default_last_updated_by,
                    p_default_last_update_login,
                    current_calling_sequence)<> TRUE) THEN
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections <-'||current_calling_sequence);
                END IF;
                Raise check_receipt_failure;
            END IF;
        p_temp_line_status := 'N';
        END;
     END IF; -- Receipt number AND id are NULL

  -------------------------------------------------------------------------
  -- Step 3 : Validate receipt info IF type is not ITEM or RETROITEM AND
  -- some receipt info given
  -------------------------------------------------------------------------
  ELSIF (p_invoice_lines_rec.line_type_lookup_code IN
        ('TAX', 'MISCELLANEOUS','FREIGHT') AND
        (p_invoice_lines_rec.receipt_number IS NOT NULL OR
         p_invoice_lines_rec.rcv_transaction_id IS NOT NULL)) THEN

    -- Case a : receipt_num AND id are NULL
    -- ignore matching to receipt

    -- Case b : receipt num is not NULL, id is NULL
    IF (p_invoice_lines_rec.receipt_number is not NULL) AND
       (p_invoice_lines_rec.rcv_transaction_id is NULL) THEN
      debug_info := '(Check Receipt Info 3) Case b';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
         AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      END IF;
      BEGIN
       SELECT rcv_transaction_id
         INTO l_temp_rcv_txn_id
         FROM po_ap_receipt_match_v
         WHERE receipt_number = p_invoice_lines_rec.receipt_number;
       Exception
       When no_data_found THEN
           --reject fOR INVALID RECEIPT INFORMATION
           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INVALID RECEIPT INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN
                 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   AP_IMPORT_UTILITIES_PKG.Print(
                     AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections <-'||current_calling_sequence);
                 END IF;
             Raise check_receipt_failure;
           END IF;
           p_temp_line_status := 'N';
       When too_many_rows THEN
       -- reject fOR INSUFFICIENT RECEIPT INFORMATION
           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INSUFFICIENT RECEIPT INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN
                 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   AP_IMPORT_UTILITIES_PKG.Print(
                     AP_IMPORT_INVOICES_PKG.g_debug_switch,
                     'insert_rejections <-'||current_calling_sequence);
                 END IF;
             Raise check_receipt_failure;
           END IF;
           p_temp_line_status := 'N';
       END;

    -- Case c : receipt_num is NULL AND id is not NULL
    ELSIF (p_invoice_lines_rec.receipt_number is NULL) AND
          (p_invoice_lines_rec.rcv_transaction_id is not NULL) THEN
      debug_info := '(Check Receipt Info 3) Case c';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      END IF;
      BEGIN
       SELECT rcv_transaction_id
         INTO l_temp_rcv_txn_id
         FROM po_ap_receipt_match_v
        WHERE rcv_transaction_id = p_invoice_lines_rec.rcv_transaction_id;
       Exception
         When Others THEN
           -- reject fOR INVALID RECEIPT INFORMATION
           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID RECEIPT INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence)<> TRUE) THEN
                 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   AP_IMPORT_UTILITIES_PKG.Print(
                     AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections <-'||current_calling_sequence);
                 END IF;
             Raise check_receipt_failure;
           END IF;
           p_temp_line_status := 'N';
       END;

    -- Case d : receipt num is not NULL AND id is not NULL
    ELSIF (p_invoice_lines_rec.receipt_number is not NULL) AND
      (p_invoice_lines_rec.rcv_transaction_id is not NULL) THEN
      debug_info := '(Check Receipt Info 3) Case d';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
         AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;
      BEGIN
       SELECT rcv_transaction_id
         INTO l_temp_rcv_txn_id
         FROM po_ap_receipt_match_v
        WHERE rcv_transaction_id = p_invoice_lines_rec.rcv_transaction_id
          AND receipt_number = p_invoice_lines_rec.receipt_number;
       Exception
         When Others THEN
             -- reject for inconsistent receipt information
             IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                    AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                    p_invoice_lines_rec.invoice_line_id,
                    'INCONSISTENT RECEIPT INFO',
                    p_default_last_updated_by,
                    p_default_last_update_login,
                    current_calling_sequence)<> TRUE) THEN
                 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   AP_IMPORT_UTILITIES_PKG.Print(
                     AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections <-'||current_calling_sequence);
                 END IF;
                 Raise check_receipt_failure;
             END IF;
             p_temp_line_status := 'N';
               END;
            END IF; -- receipt number AND id are NULL.
  END IF; -- Source, line type AND match option (Step 1)

  -- copy l_temp_rcv_txn_id back to rcv_transaction id IF not NULL
  p_invoice_lines_rec.rcv_transaction_id :=
        nvl(l_temp_rcv_txn_id, p_invoice_lines_rec.rcv_transaction_id);

	-- Getting the value of rcv_shipment_line_id -- Bug 7344899

   IF (p_invoice_lines_rec.rcv_transaction_id is not NULL)  THEN
        debug_info := '(Get the value of rcv_shipment_line_id) ';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
         AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      END IF;
      BEGIN
       SELECT rcv_shipment_line_id
       INTO   l_temp_ship_line_id
       FROM po_ap_receipt_match_v
	   WHERE rcv_transaction_id = p_invoice_lines_rec.rcv_transaction_id;
       Exception
       When no_data_found THEN
           --reject fOR INVALID RECEIPT INFORMATION
           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INVALID RECEIPT INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN
                 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   AP_IMPORT_UTILITIES_PKG.Print(
                     AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections <-'||current_calling_sequence);
                 END IF;
             Raise check_receipt_failure;
           END IF;
           p_temp_line_status := 'N';
       When too_many_rows THEN
       -- reject fOR INSUFFICIENT RECEIPT INFORMATION
           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INSUFFICIENT RECEIPT INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence)<> TRUE) THEN
                 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                   AP_IMPORT_UTILITIES_PKG.Print(
                     AP_IMPORT_INVOICES_PKG.g_debug_switch,
                     'insert_rejections <-'||current_calling_sequence);
                 END IF;
             Raise check_receipt_failure;
           END IF;
           p_temp_line_status := 'N';

       END;
       END IF;
	   --copy l_temp_ship_line_id back to rcv_shipment_line_id  IF not NULL

	   p_invoice_lines_rec.rcv_shipment_line_id := l_temp_ship_line_id ; --Bug 7344899


  ---------------------------------------------------------------------------
  -- Step 4:  Validate the final match flag <> 'Y'
  ---------------------------------------------------------------------------
  debug_info := '(check receipt info 4) : Final Match flag';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  IF (p_invoice_lines_rec.match_option = 'R') AND
     (nvl(p_invoice_lines_rec.final_match_flag,'N') = 'Y' ) THEN
    -- reject fOR INVALID FINAL MATCH FLAG
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
        p_invoice_lines_rec.invoice_line_id,
        'INVALID FINAL MATCH FLAG',
        p_default_last_updated_by,
        p_default_last_update_login,
        current_calling_sequence)<> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections <-'||current_calling_sequence);
      END IF;
      Raise check_receipt_failure;
    END IF;
    p_temp_line_status := 'N';
  END IF;

  ----------------------------------------------------------------------------
  -- Step 5 : Validate the UOM  IF rcv_txn_id is not NULL
  ----------------------------------------------------------------------------
  IF (p_invoice_lines_rec.rcv_transaction_id IS NOT NULL)  AND
     (p_invoice_lines_rec.match_option = 'R') AND
     (p_invoice_lines_rec.unit_of_meas_lookup_code IS NOT NULL) THEN

    debug_info := '(check receipt info 5) : Validate UOM';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;
    BEGIN
      SELECT 'Y'
        INTO l_temp_value
        FROM po_ap_receipt_match_v
       WHERE rcv_transaction_id = p_invoice_lines_rec.rcv_transaction_id
         AND receipt_uom_lookup_code =
             p_invoice_lines_rec.unit_of_meas_lookup_code;
    EXCEPTION
      WHEN OTHERS THEN
        -- reject for uom does not match receipt
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'UOM DOES NOT MATCH RECPT',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence)<> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections <-'||current_calling_sequence);
          END IF;
      Raise check_receipt_failure;
        END IF;
        p_temp_line_status := 'N';
    END;
  END IF;

  ----------------------------------------------------------------------------
  -- Step 6 : Validate IF prorate is checked AND receipt info provided
  -- for non Item.
  -- Retropricing: PPA Invoice Line will not have TAX and there the code
  -- below will not get executed.
  ----------------------------------------------------------------------------
  debug_info := '(check receipt info 6) : Check prorate flag';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  IF (p_invoice_lines_rec.line_type_lookup_code IN
     ('MISCELLANEOUS', 'FREIGHT','TAX') AND
      NVL(p_invoice_lines_rec.prorate_across_flag,'N') = 'Y' AND
      (p_invoice_lines_rec.receipt_number is not NULL OR
      p_invoice_lines_rec.rcv_transaction_id is not NULL) ) THEN

    -- reject for inconsistent allocation info
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INCONSISTENT ALLOC INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence)<> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections <-'||current_calling_sequence);
      END IF;
      Raise check_receipt_failure;
    END IF;
    p_temp_line_status := 'N';
  END IF;

  ---------------------------------------------------------------------------
  -- step 7 : Validate quantity billed does not become less than zero ,
  --          IF rcv_transaction-id is not NULL AND is valid.
  -- Retropricing: Quantity Billed is not affected by Retropricing. This
  -- validation should be bypassed for PPA's.
  ---------------------------------------------------------------------------
  IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA' THEN
      IF (p_invoice_lines_rec.rcv_transaction_id is not NULL) AND
         (p_temp_line_status <> 'N') AND
         (p_invoice_lines_rec.match_option = 'R') AND
         (p_invoice_lines_rec.quantity_invoiced is not NULL) THEN
        debug_info := '(Check receipt info 7) : check Quantity billed';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;

        BEGIN
          SELECT nvl(quantity_billed,0)
            INTO l_qty_billed
            FROM rcv_transactions
           WHERE transaction_id = p_invoice_lines_rec.rcv_transaction_id;

          IF (l_qty_billed +  p_invoice_lines_rec.quantity_invoiced ) < 0 THEN
            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
               'INVALID QUANTITY',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence,
               'Y',
               'QUANTITY INVOICED',
               l_qty_billed + p_invoice_lines_rec.quantity_invoiced )<> TRUE) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'insert_rejections <-'||current_calling_sequence);
              END IF;
              Raise check_receipt_failure;
            END IF;
            p_temp_line_status := 'N';
          END IF;
        END;
      END IF; -- rcv_txn_id not NULL
  END IF; --source <> PPA
  -- p_temp_line_status has the return value
  RETURN (TRUE);

EXCEPTION
  When OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;
    Return(FALSE);

END v_check_receipt_info;



-----------------------------------------------------------------------------
-- This function is used to validate line level accounting date information.
--
FUNCTION v_check_line_accounting_date (
   p_invoice_rec        IN
    AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec  IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_gl_date_from_get_info        IN            DATE,
   p_gl_date_from_receipt_flag    IN            VARCHAR2,
   p_set_of_books_id              IN            NUMBER,
   p_purch_encumbrance_flag       IN            VARCHAR2,
   p_default_last_updated_by      IN            NUMBER,
   p_default_last_update_login    IN            NUMBER,
   p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
   p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN
IS
   check_accounting_date_failure  EXCEPTION;
   l_period_name                  VARCHAR2(15);
   l_dummy                          VARCHAR2(100);
   l_key                            VARCHAR2(1000);
   l_numof_values                   NUMBER;
   l_valueOut                   fnd_plsql_cache.generic_cache_value_type;
   l_values                     fnd_plsql_cache.generic_cache_values_type;
   l_ret_code                      VARCHAR2(1);
   l_exception                     VARCHAR2(10);
   l_current_invoice_status         VARCHAR2(1) := 'Y';
   l_accounting_date             DATE := p_invoice_lines_rec.accounting_date;
   current_calling_sequence       VARCHAR2(2000);
   debug_info                    VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
     'AP_IMPORT_VALIDATION_PKG.v_check_line_accounting_date<-'
     ||P_calling_sequence;

  --------------------------------------------------------------------------
  -- IF the accounting date is not specified in the Lines Interface use
  -- gl_date_from_invoice, IF null, THEN use gl_date_from_get_info as the
  -- acct date. Logic for deriving p_gl_date_from_get_info : Use GL Date
  -- from  Report input params
  -- IF null ,THEN
  --   IF p_gl_date_from_receipt_flag = 'I','N' THEN Invoice Date is
  --   used as the Gl Date
  --     IF invoice date is null use the sysdate as the invoice date/ GL_Date
  --   ElsIF p_gl_date_from_receipt_flag IN 'S','Y'   ,THEN use sydate as
  -- the GL Date.
  ---------------------------------------------------------------------------
  IF (l_accounting_date IS NULL) AND (p_invoice_rec.gl_date IS NOT NULL) THEN
    debug_info := '(Check_line_accounting_date 1) Default '
                  ||'line_accounting_date from Invoice gl_date';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    l_accounting_date := p_invoice_rec.gl_date;

  ELSIF (l_accounting_date IS NULL) AND (p_gl_date_from_get_info IS NOT NULL)
    THEN
    debug_info := '(v_check_line_accounting_date 1) GL Date is Null in '
                  ||'Interface, Use gl_date from Get Info';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;
    l_accounting_date := p_gl_date_from_get_info;
  END IF;

  IF ((l_accounting_date IS NULL) AND
      (p_gl_date_from_receipt_flag IN ('I','N')) AND
      (p_invoice_rec.invoice_date is NOT NULL)) THEN
    debug_info := '(v_check_line_accounting_date 2) GL Date is Invoice Date';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;
    l_accounting_date := p_invoice_rec.invoice_date;
  ELSIF((l_accounting_date IS NULL) AND
        (p_gl_date_from_receipt_flag IN ('I','N')) AND
        (p_invoice_rec.invoice_date is NULL)) THEN
    debug_info := '(v_check_line_accounting_date 2) GL Date is sysdate';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
    l_accounting_date := AP_IMPORT_INVOICES_PKG.g_inv_sysdate;
  END IF;

  ------------------------------------------------------------------------
  -- Reject IF account_date is not in open period
  ------------------------------------------------------------------------
  debug_info := '(v_check_line_accounting_date 3) Check IF gl date is not '
                ||'in open period';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
      AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
  END IF;

  -- bug 2496185 by isartawi .. cache the code_combination_ids
  l_key := TO_CHAR(p_set_of_books_id)||' '||
           TO_CHAR(NVL(l_accounting_date,
                       AP_IMPORT_INVOICES_PKG.g_inv_sysdate),'dd-mm-yyyy');

  fnd_plsql_cache.generic_1tom_get_values(
              AP_IMPORT_INVOICES_PKG.lg_many_controller,
              AP_IMPORT_INVOICES_PKG.lg_generic_storage,
              l_key,
              l_numof_values,
              l_values,
              l_ret_code);

  IF l_ret_code = '1' THEN --  means l_key found in cache
    l_period_name := l_values(1).varchar2_1;
    l_exception   := l_values(1).varchar2_2;
    IF l_exception = 'TRUE' THEN
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
          p_invoice_lines_rec.invoice_line_id,
          'ACCT DATE NOT IN OPEN PD',
          p_default_last_updated_by,
          p_default_last_update_login,
          current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE check_accounting_date_failure;
      END IF;

        --Bug3302807 Setting the l_current_invoice_status to 'N' if rejected
         l_current_invoice_status := 'N';

   END IF; -- l_exception TRUE
  ELSE  -- IF l_key not found in cache(l_ret_code other than 1) .. cache it
    BEGIN
      SELECT period_name
        INTO l_period_name
        FROM gl_period_statuses
       WHERE application_id = 200
         AND set_of_books_id = p_set_of_books_id
         AND trunc(nvl(l_accounting_date,AP_IMPORT_INVOICES_PKG.g_inv_sysdate))
             between start_date and END_date
         AND closing_status in ('O', 'F')
         AND NVL(adjustment_period_flag, 'N') = 'N';

      l_exception           := 'FALSE';
      l_valueOut.varchar2_1 := l_period_name;
      l_valueOut.varchar2_2 := l_exception;
      l_values(1)           := l_valueOut;
      l_numof_values        := 1;

      fnd_plsql_cache.generic_1tom_put_values(
                  AP_IMPORT_INVOICES_PKG.lg_many_controller,
                  AP_IMPORT_INVOICES_PKG.lg_generic_storage,
                  l_key,
                  l_numof_values,
                  l_values);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'Accounting date is not in open period');
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
             p_invoice_lines_rec.invoice_line_id,
            'ACCT DATE NOT IN OPEN PD',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_accounting_date_failure;
        END IF;
        l_current_invoice_status := 'N';
        l_exception              := 'TRUE';
        l_valueOut.varchar2_1    := NULL;
        l_valueOut.varchar2_2    := l_exception;
        l_values(1)              := l_valueOut;
        l_numof_values           := 1;

        fnd_plsql_cache.generic_1tom_put_values(
                    AP_IMPORT_INVOICES_PKG.lg_many_controller,
                    AP_IMPORT_INVOICES_PKG.lg_generic_storage,
                    l_key,
                    l_numof_values,
                    l_values);
    END;
  END IF; -- IF ret_code is 1
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '------------------> l_period_name = '|| l_period_name
    ||'l_accounting_date = '||to_char(l_accounting_date));
  END IF;

  --------------------------------------------------------------------------
  -- Reject IF the year of gl date is beyond encumbrance year
  -- only IF purch_encumbrance_flag = 'Y'
  --------------------------------------------------------------------------
  IF (p_purch_encumbrance_flag = 'Y') THEN
    BEGIN
      debug_info := '(v_check_line_accounting_date 4) Reject IF the year of '
                    ||'gl date is beyond encumbrance year';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      SELECT 'The period is NOT beyond latest encumbrance year'
        INTO l_DUMMY
        FROM GL_PERIOD_STATUSES gps1,
             GL_SETS_OF_BOOKS gsob
       WHERE gps1.period_year <= gsob.latest_encumbrance_year
         AND gsob.SET_OF_BOOKS_ID = p_set_of_books_id
         AND gps1.APPLICATION_ID = 200
         AND gps1.SET_OF_BOOKS_ID = gsob.SET_OF_BOOKS_ID
         AND trunc(nvl(l_accounting_date,AP_IMPORT_INVOICES_PKG.g_inv_sysdate))
             BETWEEN gps1.START_DATE AND gps1.END_DATE
         AND gps1.closing_status in ('O', 'F')
         AND NVL(gps1.adjustment_period_flag, 'N') = 'N';

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'Accounting date is beyond encumbrance year');
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
           AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'ACCT DATE BEYOND ENC YEAR',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_accounting_date_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
    END;
  END IF; -- purch encumbrance flag is Y

  IF (l_current_invoice_status = 'Y') THEN
    IF (l_accounting_date is not NULL) THEN
      p_invoice_lines_rec.accounting_date := l_accounting_date;
    END IF;
    IF (l_period_name is not NULL) THEN
      p_invoice_lines_rec.period_name := l_period_name;
    END IF;
  END IF;
  -- Return value
  p_current_invoice_status := l_current_invoice_status;

  RETURN (TRUE);
EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_line_accounting_date;

------------------------------------------------------------------------------
-- This function is used to validate line level project information.
-- Retropricing:
-- For the validation of PPA Invoice Lines , we will not be calling the
-- PA Flexbuilder. We only verify if the Project level infomation
-- is correct. Also we will bypass the rejection -- 'INCONSISTENT DIST INFO
-- when both po and pa information co-exist.
------------------------------------------------------------------------------

FUNCTION v_check_line_project_info (
   p_invoice_rec         IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec   IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_accounting_date           IN            DATE,
   p_pa_installed              IN            VARCHAR2,
   p_employee_id               IN            NUMBER,
   p_base_currency_code        IN            VARCHAR2,
   p_set_of_books_id           IN            NUMBER,
   p_chart_of_accounts_id      IN            NUMBER,
   p_default_last_updated_by   IN            NUMBER,
   p_default_last_update_login IN            NUMBER,
   p_pa_built_account             OUT NOCOPY NUMBER,
   p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
   p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN
IS

check_project_failure          EXCEPTION;
l_current_invoice_status      VARCHAR2(1) := 'Y';
l_error_found                  VARCHAR2(1) := 'N';
l_pa_default_dist_ccid          NUMBER;
l_pa_concatenated_segments    VARCHAR2(2000):='';
l_dist_code_combination_id    NUMBER ;
l_award_id                      NUMBER;
l_unbuilt_flex                VARCHAR2(240):='';
l_reason_unbuilt_flex         VARCHAR2(2000):='';
current_calling_sequence      VARCHAR2(2000);
debug_info                     VARCHAR2(500);
l_key                         VARCHAR2(1000);
l_numof_values                NUMBER;
l_valueOut                    fnd_plsql_cache.generic_cache_value_type;
l_values                      fnd_plsql_cache.generic_cache_values_type;
l_ret_code                    VARCHAR2(1);
l_validate_res                VARCHAR2(10);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_line_project_info<-'
    ||P_calling_sequence;

  l_award_id := p_invoice_lines_rec.award_id ;

  IF (p_invoice_lines_rec.project_id IS NOT NULL  AND
      AP_IMPORT_INVOICES_PKG.g_source <> 'PPA') THEN

    ---------------------------------------------------------------------
    -- Step 1 - Reject IF line has PA info and it is PO matched
    -- or contains a default account (conflict of account sources)

    ---------------------------------------------------------------------
    debug_info := '(v_check_line_project_info 1) Check IF line has PA Info'
                  ||' and other account info as well';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF ( p_invoice_lines_rec.po_number IS NOT NULL    OR
         p_invoice_lines_rec.po_header_id IS NOT NULL ) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '(v_check_line_project_info 2) Line with additional account'
            ||' info:Reject');
      END IF;


      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
           p_invoice_lines_rec.invoice_line_id,
             'INCONSISTENT DIST INFO',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE check_project_failure;
      END IF;

      --
      l_current_invoice_status := 'N';

    END IF; -- po number or po header id are not null

    --------------------------------------------------------------
    -- Step 2
    -- Check for minimum info required for PA Flexbuild
    -- Else reject
    --------------------------------------------------------------
    IF (p_invoice_lines_rec.expenditure_item_date is NULL) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '(v_check_line_project_info 2) Get expenditure item date');
      END IF;

        p_invoice_lines_rec.expenditure_item_date :=
          AP_INVOICES_PKG.get_expenditure_item_date(
            p_invoice_rec.invoice_id,
            p_invoice_rec.invoice_date,
            p_accounting_date,
            NULL,
            NULL,
            l_error_found);

      IF (l_error_found = 'Y') then
        RAISE check_project_failure;
      END IF;
    END IF; -- Expenditure item date is null

    IF ((p_invoice_lines_rec.project_id IS NULL) OR
        (p_invoice_lines_rec.task_id IS NULL) OR
        (p_invoice_lines_rec.expenditure_type IS NULL) OR
        (p_invoice_lines_rec.expenditure_item_date IS NULL) OR
        (p_invoice_lines_rec.expenditure_organization_id IS NULL)) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '(v_check_line_project_info 2) Insufficient PA Info:Reject');
      END IF;

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
             p_invoice_lines_rec.invoice_line_id,
            'INSUFFICIENT PA INFO',
             p_default_last_updated_by,
             p_default_last_update_login,
             current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE check_project_failure;
      END IF;
      --
      l_current_invoice_status := 'N';
    END IF;

    -- We need to call the GMS API only when the current invoice status
    -- is 'Y' and l_award_id is not null
    -- Else ignore the call.
    IF ( l_current_invoice_status = 'Y' AND p_invoice_lines_rec.project_id is not null ) THEN
      debug_info := 'AWARD_ID_REQUEST :(v_check_line_award_info 1) Check  '
                    ||'GMS Info ';
      IF GMS_AP_API.gms_debug_switch(AP_IMPORT_INVOICES_PKG.g_debug_switch) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;
      END IF;

        /*Bug#10235692 - passing 'APTXNIMP' to p_calling_sequence */
      IF    ( GMS_AP_API.v_check_line_award_info (
                  p_invoice_lines_rec.invoice_line_id,
                  p_invoice_lines_rec.amount,
                  p_invoice_lines_rec.base_amount,
                  p_invoice_lines_rec.dist_code_concatenated,
                  p_invoice_lines_rec.dist_code_combination_id,
                  p_invoice_rec.po_number,
                  p_invoice_lines_rec.po_number,
                  p_invoice_lines_rec.po_header_id,
                  p_invoice_lines_rec.distribution_set_id,
                  p_invoice_lines_rec.distribution_set_name,
                  p_set_of_books_id,
                  p_base_currency_code,
                  p_invoice_rec.invoice_currency_code,
                  p_invoice_rec.exchange_rate,
                  p_invoice_rec.exchange_rate_type,
                  p_invoice_rec.exchange_date,
                  p_invoice_lines_rec.project_id,
                  p_invoice_lines_rec.task_id,
                  p_invoice_lines_rec.expenditure_type,
                  p_invoice_lines_rec.expenditure_item_date,
                  p_invoice_lines_rec.expenditure_organization_id,
                  NULL, -- project_accounting_context
                  p_invoice_lines_rec.pa_addition_flag,
                  p_invoice_lines_rec.pa_quantity,
                  p_employee_id,
                  p_invoice_rec.vendor_id,
                  p_chart_of_accounts_id,
                  p_pa_installed,
                  p_invoice_lines_rec.prorate_across_flag,
                  p_invoice_lines_rec.attribute_category,
                  p_invoice_lines_rec.attribute1,
                  p_invoice_lines_rec.attribute2,
                  p_invoice_lines_rec.attribute3,
                  p_invoice_lines_rec.attribute4,
                  p_invoice_lines_rec.attribute5,
                  p_invoice_lines_rec.attribute6,
                  p_invoice_lines_rec.attribute7,
                  p_invoice_lines_rec.attribute8,
                  p_invoice_lines_rec.attribute9,
                  p_invoice_lines_rec.attribute10,
                  p_invoice_lines_rec.attribute11,
                  p_invoice_lines_rec.attribute12,
                  p_invoice_lines_rec.attribute13,
                  p_invoice_lines_rec.attribute14,
                  p_invoice_lines_rec.attribute15,
                  p_invoice_rec.attribute_category,
                  p_invoice_rec.attribute1,
                  p_invoice_rec.attribute2,
                  p_invoice_rec.attribute3,
                  p_invoice_rec.attribute4,
                  p_invoice_rec.attribute5,
                  p_invoice_rec.attribute6,
                  p_invoice_rec.attribute7,
                  p_invoice_rec.attribute8,
                  p_invoice_rec.attribute9,
                  p_invoice_rec.attribute10,
                  p_invoice_rec.attribute11,
                  p_invoice_rec.attribute12,
                  p_invoice_rec.attribute13,
                  p_invoice_rec.attribute14,
                  p_invoice_rec.attribute15,
                  p_invoice_lines_rec.partial_segments,
                  p_default_last_updated_by,
                  p_default_last_update_login,
                  'APTXNIMP',
                  l_award_id,
                  'AWARD_SET_ID_REQUEST' ) <> TRUE ) THEN
        IF GMS_AP_API.gms_debug_switch(AP_IMPORT_INVOICES_PKG.g_debug_switch)
          THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '(v_check_line_project_info 3) Invalid GMS Info:Reject');
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INSUFFICIENT GMS INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_project_failure;
        END IF;
        --
        l_current_invoice_status := 'N';
      END IF;
    END IF; -- l_current_invoice_status = 'Y' and l_award_id is not null

    ------------------------------------------------------------------------
    -- Step 3
    -- IF invoice status is Y THEN Flexbuild
    ------------------------------------------------------------------------
    IF (l_current_invoice_status = 'Y') THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          '(v_check_line_project_info 4) Call pa_flexbuild');
      END IF;
      IF (AP_IMPORT_INVOICES_PKG.g_source <> 'PPA')  THEN
          IF (AP_IMPORT_UTILITIES_PKG.pa_flexbuild(
                 p_invoice_rec,                      -- IN
                 p_invoice_lines_rec,                -- IN OUT NOCOPY
                 p_accounting_date,                      -- IN
                 p_pa_installed,                     -- IN
                 p_employee_id,                     -- IN
                 p_base_currency_code,                -- IN
                 p_chart_of_accounts_id,             -- IN
                 p_default_last_updated_by,          -- IN
                 p_default_last_update_login,        -- IN
                 p_pa_default_dist_ccid     => l_pa_default_dist_ccid,    -- OUT NOCOPY
                 p_pa_concatenated_segments => l_pa_concatenated_segments,-- OUT NOCOPY
                 p_current_invoice_status   => l_current_invoice_status,  -- OUT NOCOPY
                 p_calling_sequence         => current_calling_sequence) <> TRUE) THEN


            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE check_project_failure;
          END IF; -- pa flexbuild
      END IF; -- source <> PPA

      -- Added following IF condition so that GMS API will be
      -- called only when award_id is not null
      IF (l_current_invoice_status = 'Y' AND l_award_id is not null) THEN
        debug_info := 'AWARD_ID_REMOVE :(v_check_line_award_info 1) Check  GMS Info ';
        IF GMS_AP_API.gms_debug_switch(AP_IMPORT_INVOICES_PKG.g_debug_switch)
          THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;
        END IF;

        /*Bug#10235692 - passing 'APTXNIMP' to p_calling_sequence */
        IF GMS_AP_API.v_check_line_award_info (
                    p_invoice_lines_rec.invoice_line_id    ,
                    p_invoice_lines_rec.amount,
                    p_invoice_lines_rec.base_amount,
                    p_invoice_lines_rec.dist_code_concatenated,
                    p_invoice_lines_rec.dist_code_combination_id,
                    p_invoice_rec.po_number,
                    p_invoice_lines_rec.po_number,
                    p_invoice_lines_rec.po_header_id,
                    p_invoice_lines_rec.distribution_set_id,
                    p_invoice_lines_rec.distribution_set_name,
                    p_set_of_books_id,
                    p_base_currency_code,
                    p_invoice_rec.invoice_currency_code,
                    p_invoice_rec.exchange_rate,
                    p_invoice_rec.exchange_rate_type,
                    p_invoice_rec.exchange_date,
                    p_invoice_lines_rec.project_id,
                    p_invoice_lines_rec.task_id,
                    p_invoice_lines_rec.expenditure_type,
                    p_invoice_lines_rec.expenditure_item_date,
                    p_invoice_lines_rec.expenditure_organization_id,
                    NULL, --p_project_accounting_context
                    p_invoice_lines_rec.pa_addition_flag,
                    p_invoice_lines_rec.pa_quantity,
                    p_employee_id,
                    p_invoice_rec.vendor_id,
                    p_chart_of_accounts_id,
                    p_pa_installed,
                    p_invoice_lines_rec.prorate_across_flag,
                    p_invoice_lines_rec.attribute_category,
                    p_invoice_lines_rec.attribute1,
                    p_invoice_lines_rec.attribute2,
                    p_invoice_lines_rec.attribute3,
                    p_invoice_lines_rec.attribute4,
                    p_invoice_lines_rec.attribute5,
                    p_invoice_lines_rec.attribute6,
                    p_invoice_lines_rec.attribute7,
                    p_invoice_lines_rec.attribute8,
                    p_invoice_lines_rec.attribute9,
                    p_invoice_lines_rec.attribute10,
                    p_invoice_lines_rec.attribute11,
                    p_invoice_lines_rec.attribute12,
                    p_invoice_lines_rec.attribute13,
                    p_invoice_lines_rec.attribute14,
                    p_invoice_lines_rec.attribute15,
                    p_invoice_rec.attribute_category,
                    p_invoice_rec.attribute1,
                    p_invoice_rec.attribute2,
                    p_invoice_rec.attribute3,
                    p_invoice_rec.attribute4,
                    p_invoice_rec.attribute5,
                    p_invoice_rec.attribute6,
                    p_invoice_rec.attribute7,
                    p_invoice_rec.attribute8,
                    p_invoice_rec.attribute9,
                    p_invoice_rec.attribute10,
                    p_invoice_rec.attribute11,
                    p_invoice_rec.attribute12,
                    p_invoice_rec.attribute13,
                    p_invoice_rec.attribute14,
                    p_invoice_rec.attribute15,
                    p_invoice_lines_rec.partial_segments,
                    p_default_last_updated_by,
                    p_default_last_update_login,
                    'APTXNIMP',
                    l_award_id,
                    'AWARD_SET_ID_REMOVE' ) <> TRUE  THEN
          IF GMS_AP_API.gms_debug_switch(AP_IMPORT_INVOICES_PKG.g_debug_switch)
            THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  '(v_check_line_project_info 3) Invalid GMS Info:Reject');
            END IF;
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                 p_invoice_lines_rec.invoice_line_id,
                'INSUFFICIENT GMS INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
            END IF;
             RAISE check_project_failure;
          END IF;
          --
          l_current_invoice_status := 'N';
        END IF; -- GMS
      END IF; -- l_current_invoice_Status ='Y' AND l_award_id is not null

      --------------------------------------------------------------
      -- Step 4
      -- IF flexbuild is successful THEN get ccid
      --------------------------------------------------------------
      -- IF ccid is created THEN fine
      -- Else get ccid from concat segments since it is new
      IF AP_IMPORT_INVOICES_PKG.g_source <> 'PPA'  THEN
          IF (l_current_invoice_status = 'Y') THEN
            IF (l_pa_default_dist_ccid = -1) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  '(v_check_line_project_info 4) Create new ccid from concat segs');
              END IF;

              -- Create new ccid
              -- IF creation fails THEN reject
              -- Bug 1414119 Changed operation from CREATE_COMBINATION to
              -- CREATE_COMB_NO_AT at all the places to avoid the autonomous
              -- transaction insert for new code combinations when dynamic
              -- insert is on.
              -- bug 2496185 by isartawi .. cache the code_combination_ids

              l_key := to_char(nvl(p_chart_of_accounts_id,0))||' '
                       ||l_pa_concatenated_segments||' '
                       ||to_char(AP_IMPORT_INVOICES_PKG.g_inv_sysdate,'dd-mm-yyyy');
              fnd_plsql_cache.generic_1tom_get_values(
                          AP_IMPORT_INVOICES_PKG.lg_many_controller1,
                          AP_IMPORT_INVOICES_PKG.lg_generic_storage1,
                          l_key,
                          l_numof_values,
                          l_values,
                          l_ret_code);

              IF l_ret_code = '1' THEN --  means l_key found in cache
                l_dist_code_combination_id := to_number(l_values(1).varchar2_1);
                l_validate_res             := l_values(1).varchar2_2;
                l_reason_unbuilt_flex      := l_values(1).varchar2_3;

              ELSE  -- IF l_key not found in cache .. cache it
           -- For BUG 3000219. Changed g_inv_sysdate to p_accounting_date
                IF (fnd_flex_keyval.validate_segs(
                   'CREATE_COMB_NO_AT' ,
                   'SQLGL',
                   'GL#',
                   p_chart_of_accounts_id,
                   l_pa_concatenated_segments,
                   'V',
                   p_accounting_date,   --BUG 3000219.Changed from AP_IMPORT_INVOICES_PKG.g_inv_sysdate
                   'ALL',
                   NULL,
                   NULL,
                   'GL_global\\nSUMMARY_FLAG\\nI\\nAPPL=SQLAP;NAME=AP_ALL_PARENT_FLEX_NA\\nN',
                   NULL,
                   FALSE,
                   FALSE,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL,
                   NULL) <> TRUE) THEN
                  l_validate_res := 'FALSE';
                ELSE
                  l_validate_res := 'TRUE';
                END IF;

                l_dist_code_combination_id := fnd_flex_keyval.combination_id;
                l_reason_unbuilt_flex  := fnd_flex_keyval.error_message;

                l_valueOut.varchar2_1 := to_char(l_dist_code_combination_id);
                l_valueOut.varchar2_2 := l_validate_res;
                l_valueOut.varchar2_3 := l_reason_unbuilt_flex;
                l_values(1) := l_valueOut;
                l_numof_values := 1;

                fnd_plsql_cache.generic_1tom_put_values(
                            AP_IMPORT_INVOICES_PKG.lg_many_controller1,
                            AP_IMPORT_INVOICES_PKG.lg_generic_storage1,
                            l_key,
                            l_numof_values,
                            l_values);
              END IF;

              IF (l_validate_res <> 'TRUE') THEN
                --Invalid Creation combination
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                      '(v_check_line_project_info 4) Invalid ccid:Reject');
                END IF;

                IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                   AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                    p_invoice_lines_rec.invoice_line_id,
                    'INVALID PA ACCT',
                    p_default_last_updated_by,
                    p_default_last_update_login,
                    current_calling_sequence) <> TRUE) THEN
                  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                    AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch,
                        'insert_rejections<-'||current_calling_sequence);
                  END IF;
                   RAISE check_project_failure;
                END IF;
                --
                l_current_invoice_status := 'N';
                l_dist_code_combination_id := 0;
                l_unbuilt_flex := l_pa_concatenated_segments;
              Else
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  '(v_check_line_project_info 4) Valid ccid created for project');
                END IF;

                -- Valid Creation Combination
                l_reason_unbuilt_flex := NULL;
                l_unbuilt_flex := NULL;

              END IF; -- Validate res <> TRUE

              --
              -- show output values (only IF debug_switch = 'Y')
              --
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    '------------------>  l_dist_code_combination_id= '||
                to_char(l_dist_code_combination_id)
                ||' l_reason_unbuilt_flex = '||l_reason_unbuilt_flex
                ||' l_unbuilt_flex = '||l_unbuilt_flex
                ||' l_current_invoice_status = '||l_current_invoice_status);
              END IF;

            Else -- pa default ccid is valid
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  '(v_check_line_project_info 5) Valid ccid from PA Flexbuild');
              END IF;

              l_dist_code_combination_id := l_pa_default_dist_ccid;

            END IF; --pa_default_ccid = -1

            --------------------------------------------------------------
            -- Step 5
            -- Return PA generated ccid to calling module for evaluation
            -- with overlay information.
            --------------------------------------------------------------

            -- Overlay will be done in check Account info
            --
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             '(v_check_line_project_info 6) Set OUT parameter with PA ccid');
            END IF;

            p_pa_built_account := l_dist_code_combination_id;
          END IF; -- current_invoice_status(IF before l_pa_default_dist_ccid)
      END IF; -- source <> 'PPA'
    END IF; -- l_current_invoice_status( IF before pa_flexbuild)

  ELSE
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '(v_check_line_project_info) No Project Id');
    END IF;
  END IF; -- PA Info

  p_current_invoice_status := l_current_invoice_status;

  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_line_project_info;


------------------------------------------------------------------------------
-- This function is used to validate line level accounting information.
--
------------------------------------------------------------------------------
FUNCTION v_check_line_account_info (
   p_invoice_lines_rec IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_freight_code_combination_id  IN            NUMBER,
   p_pa_built_account             IN            NUMBER,
   p_accounting_date              IN            DATE,
   p_set_of_books_id              IN            NUMBER,
   p_chart_of_accounts_id         IN            NUMBER,
   p_default_last_updated_by      IN            NUMBER,
   p_default_last_update_login    IN            NUMBER,
   p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
   p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN
IS
   check_account_failure          EXCEPTION;
   l_current_invoice_status          VARCHAR2(1) := 'Y';
   l_valid_dist_code              VARCHAR(1);
   l_dist_code_combination_id      NUMBER;
   l_overlayed_ccid               NUMBER;
   l_catsegs                      VARCHAR2(200);
   l_unbuilt_flex                 VARCHAR2(240):='';
   l_reason_unbuilt_flex          VARCHAR2(2000):='';
   l_key                          VARCHAR2(1000);
   l_numof_values                   NUMBER;
   l_valueOut                   fnd_plsql_cache.generic_cache_value_type;
   l_values                     fnd_plsql_cache.generic_cache_values_type;
   l_ret_code                       VARCHAR2(1);
   l_validate_res                 VARCHAR2(10);
   current_calling_sequence        VARCHAR2(2000);
   debug_info                     VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
       'AP_IMPORT_VALIDATION_PKG.v_check_line_account_info<-'
       ||P_calling_sequence;

  l_dist_code_combination_id :=
    nvl(p_invoice_lines_rec.dist_code_combination_id, p_pa_built_account);
  -----------------------------------------------------------
  -- Step 1. Initialize account to freight system account if
  -- line is of type FREIGHT and no ccid was provided for it
  -- either as a default ccid or through projects.
  -----------------------------------------------------------
  debug_info := '(v_check_line_account_info 1) '||
                 'Check IF item line doesnt have account info';

  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(
     AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
  END IF;

  --Assigning system freight account if no freight account is specified
  --Change made for bug#2709960
  IF (p_invoice_lines_rec.line_type_lookup_code = 'FREIGHT' AND
      l_dist_code_combination_id is NULL) THEN
    l_dist_code_combination_id := p_freight_code_combination_id;
    p_invoice_lines_rec.dist_code_combination_id :=
                                  p_freight_code_combination_id;
  END IF;

  ---------------------------------------------------------------
   -- bug 7531219
   -- step 1.1 : validate the overlay balancing segment if entered
   --            to avoid importing invalid overlay balancing segment
   ---------------------------------------------------------------
   IF p_invoice_lines_rec.balancing_segment IS NOT NULL
   THEN
     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              '(v_check_line_account_info 1.1) '
              || 'Check Overlay Balancing Segment if entered');
     END IF;

     IF (AP_UTILITIES_PKG.is_balancing_segment_valid(
          p_set_of_books_id     => p_set_of_books_id,
          p_balancing_segment_value => p_invoice_lines_rec.balancing_segment,
          p_date      => p_accounting_date,
          p_calling_sequence     => current_calling_sequence) <> TRUE )
     THEN
        -- Raise check_account_failure;
         IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                    AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                    p_invoice_lines_rec.invoice_line_id,
                    'INVALID OVERLAY BAL SEGMENT',
                     p_default_last_updated_by,
                    p_default_last_update_login,
                     current_calling_sequence) <> TRUE)
         THEN
                   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                      AP_IMPORT_UTILITIES_PKG.Print(
                                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                 'insert_rejections<-'||current_calling_sequence);
                   END IF;
                   RAISE check_account_failure;
         END IF;
         l_current_invoice_status := 'N';
      END IF;
    END IF;

   -------------------------------------------------------------------------
    -- bug 7531219
    -- Step 1.2:  validate distribution code combination id if entered
    --            to avoid importing invalid distribution account
    -------------------------------------------------------------------------
  IF (l_dist_code_combination_id is NOT NULL and l_dist_code_combination_id <> -1) THEN

     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              '(v_check_line_account_info 1.2) '
              || 'Check distribution code combination id if entered');
     END IF;


     -- Validate distribution code combination id information
     IF fnd_flex_keyval.validate_ccid(
         appl_short_name => 'SQLGL',
         key_flex_code => 'GL#',
         structure_number => p_chart_of_accounts_id,
         combination_id => l_dist_code_combination_id) THEN
      l_catsegs := fnd_flex_keyval.concatenated_values;

      IF (fnd_flex_keyval.validate_segs(
                        'CHECK_COMBINATION',
                        'SQLGL',
                        'GL#',
                        p_chart_of_accounts_id,
                        l_catsegs,
                        'V',
                        nvl(p_accounting_date, sysdate),
                        'ALL',
                        NULL,
                        '\nSUMMARY_FLAG\nI\nAPPL=SQLGL;' ||
                        'NAME=GL_CTAX_SUMMARY_ACCOUNT\nN',
                        NULL,
                        NULL,
                        FALSE,
                        FALSE,
                        FND_GLOBAL.RESP_APPL_ID,
                        FND_GLOBAL.RESP_ID,
                        FND_GLOBAL.USER_ID)<>TRUE)  THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
             '(v_check_line_account_info 1.2) Invalid dist_code_combination_id');
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
              'INVALID DISTRIBUTION ACCT',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||
                  current_calling_sequence);
          END IF;
          RAISE check_account_failure;
        END IF; -- insert rejections
        l_current_invoice_status := 'N';
      END IF; -- validate segments
    ELSE -- Validate ccid
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,
                '((v_check_line_account_info 1.2) - '||
                ' Invalid Code Combination id');
      END IF;
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
             AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
             'INVALID DISTRIBUTION ACCT',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<-'||
                   current_calling_sequence);
        END IF;
        RAISE check_account_failure;
      END IF; -- insert rejections
      l_current_invoice_status := 'N';
    END IF; -- validate ccid

  END IF; -- l_dist_code_combination_id is not null

  ------------------------------------------------------------------------
  -- Step 2. Performs several checks if line did not provide distribution
  --         set as source.
  -- a. Validate account (source of account is line code combination id
  --    or pa_built_account) with overlay information if account is not
  --    null or concatenated segments on the line are a partial set
  --    but only if line is either not project related or projects allows
  --    account override.  Do not reject if the account (source of account
  --    was line code combination id or pa_built_account) is null and the
  --    concatenated segments was a partial set.
  -- b. Validate account if concatenated segments is a full set and account
  --    was null.  Obtain ccid from cache and validate it.  Also, if other
  --    overlay information was provided verify that it generates a valid
  --    account.
  ------------------------------------------------------------------------
  IF ((p_invoice_lines_rec.distribution_set_id is NULL AND
       p_invoice_lines_rec.distribution_set_name is null)) THEN

     /*  Overlay lines before we validate in
        case the base Code Combination is invalid, but the overlay
        Code Combination is not.  */

    -- 7531219 no need to validate in case of po as the validation is already done
    IF ((l_dist_code_combination_id IS NOT NULL OR
     (p_invoice_lines_rec.dist_code_concatenated IS NOT NULL AND
          p_invoice_lines_rec.partial_segments <> 'N'AND
           p_invoice_lines_rec.po_number IS NULL AND
           p_invoice_lines_rec.po_header_id IS NULL)) AND
        (p_invoice_lines_rec.dist_code_concatenated IS NOT NULL  OR
         p_invoice_lines_rec.balancing_segment      IS NOT NULL  OR
         p_invoice_lines_rec.cost_center_segment    IS NOT NULL  OR
         p_invoice_lines_rec.account_segment        IS NOT NULL) AND
        (p_invoice_lines_rec.project_id IS NULL OR
     (p_invoice_lines_rec.project_id IS NOT NULL AND
      AP_IMPORT_INVOICES_PKG.g_pa_allows_overrides = 'Y'))) THEN

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              '(v_check_line_account_info 2) '
              || 'Check Overlay Segments for line');
          END IF;

          l_overlayed_ccid := l_dist_code_combination_id;

      IF (AP_UTILITIES_PKG.overlay_segments
            (p_invoice_lines_rec.balancing_segment,
             p_invoice_lines_rec.cost_center_segment,
             p_invoice_lines_rec.account_segment,
             p_invoice_lines_rec.dist_code_concatenated,
             l_overlayed_ccid ,                 -- IN OUT NOCOPY
             p_set_of_books_id ,
             'CREATE_COMB_NO_AT',    -- Overlay Mode
             l_unbuilt_flex ,                           -- OUT NOCOPY
             l_reason_unbuilt_flex ,                    -- OUT NOCOPY
             FND_GLOBAL.RESP_APPL_ID,
             FND_GLOBAL.RESP_ID,
             FND_GLOBAL.USER_ID,
             current_calling_sequence,
             NULL,
             p_accounting_date ) <> TRUE) THEN --7531219

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '(v_check_line_account_info 2) '||
            'Overlay_Segments<-'||current_calling_sequence);
        END IF;
        -- Bug 6124714
		-- Raise check_account_failure;
		IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
             'INVALID DISTRIBUTION ACCT',
                p_default_last_updated_by,
              p_default_last_update_login,
               current_calling_sequence) <> TRUE) THEN
			IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||
                   current_calling_sequence);
			END IF;
			RAISE check_account_failure;
        END IF; -- insert rejections
      ELSE -- overlay segs

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           '------------------> l_unbuilt_flex = '||
                  l_unbuilt_flex||'l_reason_unbuilt_flex = '||
                  l_reason_unbuilt_flex||'l_overlayed_ccid = '||
                  to_char(l_overlayed_ccid));
        END IF;

        IF (l_overlayed_ccid = -1 AND
        l_dist_code_combination_id IS NOT NULL) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,
               '(v_check_line_account_info 2)' ||
               ' Invalid dist_code_combination_id overlay');
          END IF;
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
               'INVALID ACCT OVERLAY',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'
                 || current_calling_sequence);
            END IF;
            RAISE check_account_failure;
             --
          END IF; -- insert rejections
          l_current_invoice_status := 'N';
        ELSE -- overlayed_ccid <> -1
          BEGIN
            SELECT 'X'
              INTO l_valid_dist_code
              FROM gl_code_combinations
             WHERE code_combination_id = l_overlayed_ccid
               AND enabled_flag='Y'
               AND NVL(END_date_active, p_accounting_date) --Bug 2923286 Changed gl_inv_sysdate to p_accounting_date
                   >= p_accounting_date
               AND NVL(start_date_active, p_accounting_date)
                   <= p_accounting_date;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                   AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   '(v_check_line_account_info 4) '||
                   ' Invalid overlayed ccid ');
              END IF;

              IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                  AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                    p_invoice_lines_rec.invoice_line_id,
                  'INVALID DISTRIBUTION ACCT',
                     p_default_last_updated_by,
                   p_default_last_update_login,
                    current_calling_sequence) <> TRUE) THEN
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch,
                    'insert_rejections<-'
                   ||current_calling_sequence);
                END IF;
                 RAISE check_account_failure;
              END IF; -- insert rejections
              --
              l_current_invoice_status := 'N';
          END;

        END IF; -- l_dist_code_combination_id is -1
      END IF; --overlay segments

    ELSIF (l_dist_code_combination_id IS NULL AND
           p_invoice_lines_rec.dist_code_concatenated IS NOT NULL AND
           p_invoice_lines_rec.partial_segments = 'N' AND
           p_invoice_lines_rec.po_number IS NULL AND
           p_invoice_lines_rec.po_header_id IS NULL) THEN

      -- bug 2496185 by isartawi .. cache the code_combination_ids
      l_key := TO_CHAR(NVL(p_chart_of_accounts_id,0))||' '||
               p_invoice_lines_rec.dist_code_concatenated||' '||
           to_char(p_accounting_date,'dd-mm-yyyy');

      fnd_plsql_cache.generic_1tom_get_values(
               AP_IMPORT_INVOICES_PKG.lg_many_controller1,
               AP_IMPORT_INVOICES_PKG.lg_generic_storage1,
               l_key,
               l_numof_values,
               l_values,
               l_ret_code);
      IF l_ret_code = '1' THEN --  means l_key found in cache
        l_dist_code_combination_id := to_number(l_values(1).varchar2_1);
        l_validate_res             := l_values(1).varchar2_2;
         -- Bug 5533471
        p_invoice_lines_rec.dist_code_combination_id := l_dist_code_combination_id;

      ELSE  -- IF l_key not found in cache .. cache it
        IF (fnd_flex_keyval.validate_segs
                ('CREATE_COMB_NO_AT' ,   --Bug6624362
                 'SQLGL',
                 'GL#',
                 p_chart_of_accounts_id,
                 p_invoice_lines_rec.dist_code_concatenated,
                 'V',
                 p_accounting_date,
                 'ALL',
                 NULL,
                 '\nSUMMARY_FLAG\nI\nAPPL=SQLGL;' ||
                 'NAME=GL_CTAX_SUMMARY_ACCOUNT\nN',
                 NULL,
                 NULL,
                 FALSE,
                 FALSE,
                 FND_GLOBAL.RESP_APPL_ID,
                 FND_GLOBAL.RESP_ID,
                 FND_GLOBAL.USER_ID) <> TRUE) THEN
          l_validate_res := 'FALSE';
        ELSE --validate_segs
          l_validate_res := 'TRUE';
        END IF;
        l_dist_code_combination_id := fnd_flex_keyval.combination_id;
        l_valueOut.varchar2_1      := to_char(l_dist_code_combination_id);
        l_valueOut.varchar2_2      := l_validate_res;
        l_values(1)                := l_valueOut;
        l_numof_values             := 1;

        fnd_plsql_cache.generic_1tom_put_values(
                  AP_IMPORT_INVOICES_PKG.lg_many_controller1,
                  AP_IMPORT_INVOICES_PKG.lg_generic_storage1,
                  l_key,
                  l_numof_values,
                  l_values);
      END IF; -- l_ret_code='1'

       -- Bug 5533471
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'l_dist_code_combination_id: '|| l_dist_code_combination_id
           ||', l_validate_res: '||l_validate_res);
      END IF;

      IF (l_validate_res <> 'TRUE')  THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '(v_check_line_account_info 2) '||
            'Invalid dist_code_concatenated ');
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '(v_check_line_account_info 2) '||
            'Error create account infomation : '||
            FND_FLEX_KEYVAL.error_message);
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
             'INVALID DISTRIBUTION ACCT',
                p_default_last_updated_by,
              p_default_last_update_login,
               current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||
                   current_calling_sequence);
          END IF;
          RAISE check_account_failure;
        END IF; -- insert rejections
        --
        l_current_invoice_status := 'N';

      ELSE -- validate res is TRUE
        IF ((l_current_invoice_status <> 'N') AND
            ((p_invoice_lines_rec.balancing_segment IS NOT NULL) OR
          (p_invoice_lines_rec.cost_center_segment IS NOT NULL) OR
         (p_invoice_lines_rec.account_segment IS NOT NULL))) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                      '(v_check_line_account_info 2) '||
                      'Check Overlay Segments for dist_code_concatenated ');
          END IF;

          l_overlayed_ccid := l_dist_code_combination_id;

          IF (AP_UTILITIES_PKG.overlay_segments(
                  p_invoice_lines_rec.balancing_segment,
                  p_invoice_lines_rec.cost_center_segment,
                  p_invoice_lines_rec.account_segment,
                  NULL,
                  l_overlayed_ccid ,                     -- IN OUT NOCOPY
                  p_set_of_books_id ,
                  'CREATE_COMB_NO_AT' , -- Overlay Mode
                  l_unbuilt_flex ,                       -- OUT NOCOPY
                  l_reason_unbuilt_flex ,                -- OUT NOCOPY
                  FND_GLOBAL.RESP_APPL_ID,
                  FND_GLOBAL.RESP_ID,
                  FND_GLOBAL.USER_ID,
                  current_calling_sequence,
                  Null,
                  p_accounting_date ) <> TRUE) THEN --7531219
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                 AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                '(v_check_line_account_info 2) '||
                ' Overlay_Segments<-'||current_calling_sequence);
            END IF;
            -- Bug 6124714
		    -- Raise check_account_failure;
		IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
             'INVALID DISTRIBUTION ACCT',
                p_default_last_updated_by,
              p_default_last_update_login,
               current_calling_sequence) <> TRUE) THEN
			IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||
                   current_calling_sequence);
			END IF;
			RAISE check_account_failure;
        END IF; -- insert rejections

          ELSE -- overlay segs
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  '-----------------> l_unbuilt_flex = '||
                  l_unbuilt_flex||' l_reason_unbuilt_flex = '||
                  l_reason_unbuilt_flex||'l_overlayed_ccid: '||
                  to_char(l_overlayed_ccid));
            END IF;

            IF (l_overlayed_ccid = -1) THEN
              IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 '(v_check_line_account_info 4) '||
                 'Invalid dist_code_combination_id  overlay');
              END IF;

              IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                  AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                   p_invoice_lines_rec.invoice_line_id,
                  'INVALID ACCT OVERLAY',
                   p_default_last_updated_by,
                   p_default_last_update_login,
                    current_calling_sequence) <> TRUE) THEN
                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                     AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||
                     current_calling_sequence);
                END IF;
                RAISE check_account_failure;
              END IF; -- insert rejections
              l_current_invoice_status := 'N';
            END IF; -- overlayed dist code combination id is -1
          END IF; --overlay segments

        -- Bug 5533471
        ELSIF  ((l_current_invoice_status <> 'N')
                AND (l_dist_code_combination_id = -1))  THEN

          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 '(v_check_line_account_info 4.1) '||
                 'Invalid dist_code_combination_id  overlay');
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                  AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                   p_invoice_lines_rec.invoice_line_id,
                  'INVALID ACCT OVERLAY',
                   p_default_last_updated_by,
                   p_default_last_update_login,
                    current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                     AP_IMPORT_INVOICES_PKG.g_debug_switch,
                       'insert_rejections<-'||
                     current_calling_sequence);
            END IF;
                RAISE check_account_failure;
          END IF; -- insert rejections
          l_current_invoice_status := 'N';

         -- Bug 5533471
        ELSIF  ((l_current_invoice_status <> 'N')
                AND (l_dist_code_combination_id <> -1))  THEN

          p_invoice_lines_rec.dist_code_combination_id := l_dist_code_combination_id;

        END IF; -- Invoice Status
      END IF; -- Validate res
    END IF; -- accounting information exists
  END IF; -- distribution set id is null

  ------------------------------------------------------------------
  -- Step 3. Validate account information relative to po and receipt
  ------------------------------------------------------------------
  -- Made changes to the following stmt for receipt matching project
  -- We should NOT reject a non-item line IF it has account information,
  -- po information and receipt information.
  -- But we should Reject IF it has acct info, po info and no receipt info.
 -- Bug 7487507
 -- Changed the paranthesis in the If condition
    IF ((p_invoice_lines_rec.line_type_lookup_code <> 'ITEM' AND
       (p_invoice_lines_rec.distribution_set_id IS NOT NULL OR
        p_invoice_lines_rec.distribution_set_name IS NOT NULL) AND
       (l_dist_code_combination_id IS NOT NULL OR l_overlayed_ccid IS NOT NULL))
OR
      ((p_invoice_lines_rec.line_type_lookup_code <> 'ITEM')  AND
       ((p_invoice_lines_rec.po_header_id is not null) OR
        (p_invoice_lines_rec.po_number is not null)) AND
       ((p_invoice_lines_rec.receipt_number is null) AND
        (p_invoice_lines_rec.rcv_transaction_id is null)))   OR
       (((p_invoice_lines_rec.po_header_id is NOT NULL) OR
         (p_invoice_lines_rec.po_number IS NOT NULL)) AND
        ((p_invoice_lines_rec.distribution_set_id is NOT NULL) OR
         (p_invoice_lines_rec.distribution_set_name is NOT NULL))) ) THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
        '(v_check_line_account_info 3) '||
        'Inconsistent dist Info ');
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
        p_invoice_lines_rec.invoice_line_id,
        'INCONSISTENT DIST INFO',
        p_default_last_updated_by,
        p_default_last_update_login,
        current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||
          current_calling_sequence);
      END IF;
      RAISE check_account_failure;
    END IF; -- insert rejections
    l_current_invoice_status := 'N';
  END IF; -- Step 3

-- 7531219, commented out following code
-- validation of dist ccid should be done before overlay itself as
-- we need to avoid importing invalid dist ccids
/*
  -------------------------------------------------------------------------
  -- Step 4. Validate account
  -------------------------------------------------------------------------
  debug_info := '(v_check_line_account_info 4) calling parent validation ';
  IF ((l_dist_code_combination_id is not NULL AND
       l_dist_code_combination_id <> -1)          OR
      (l_overlayed_ccid IS NOT NULL AND l_overlayed_ccid <> -1))  THEN
    debug_info := '(v_check_line_account_info 4) Inside parent validation';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;
    IF (l_overlayed_ccid IS NULL OR l_overlayed_ccid = -1) THEN
      l_overlayed_ccid := l_dist_code_combination_id;
    END IF;
    IF fnd_flex_keyval.validate_ccid(
       appl_short_name => 'SQLGL',
       key_flex_code => 'GL#',
       structure_number => p_chart_of_accounts_id,
       combination_id => l_overlayed_ccid) THEN
      l_catsegs := fnd_flex_keyval.concatenated_values;

      IF (fnd_flex_keyval.validate_segs(
                        'CHECK_COMBINATION',
                        'SQLGL',
                        'GL#',
                        p_chart_of_accounts_id,
                        l_catsegs,
                        'V',
                        p_accounting_date,
                        'ALL',
                        NULL,
                        '\nSUMMARY_FLAG\nI\nAPPL=SQLGL;' ||
                        'NAME=GL_CTAX_SUMMARY_ACCOUNT\nN',
                        NULL,
                        NULL,
                        FALSE,
                        FALSE,
                        FND_GLOBAL.RESP_APPL_ID,
                        FND_GLOBAL.RESP_ID,
                        FND_GLOBAL.USER_ID)<>TRUE)  THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  '((v_check_line_account_info 4) - '||
                  ' Invalid Code Combination id');
        END IF;
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
              'INVALID DISTRIBUTION ACCT',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||
                  current_calling_sequence);
          END IF;
          RAISE check_account_failure;
        END IF; -- insert rejections
        l_current_invoice_status := 'N';
      END IF; -- validate segments
    ELSE -- Validate ccid
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,
                '((v_check_line_account_info 4) - '||
                ' Invalid Code Combination id');
      END IF;
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
             AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
             'INVALID DISTRIBUTION ACCT',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<-'||
                   current_calling_sequence);
        END IF;
        RAISE check_account_failure;
      END IF; -- insert rejections
      l_current_invoice_status := 'N';
    END IF; -- Validate ccid
  END IF; -- either dist ccid or overlayed ccid are not null
*/
  -- Return value
  p_current_invoice_status := l_current_invoice_status;

  RETURN (TRUE);


EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;
RETURN(FALSE);

END v_check_line_account_info;




-----------------------------------------------------------------------------
-- This function is used to validate line level deferred accounting
-- information.
-----------------------------------------------------------------------------
FUNCTION v_check_deferred_accounting (
         p_invoice_lines_rec
           IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
         p_set_of_books_id              IN            NUMBER,
         p_default_last_updated_by      IN            NUMBER,
         p_default_last_update_login    IN            NUMBER,
         p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
         p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN

IS

check_defer_acctg_failure      EXCEPTION;
l_period_name                  VARCHAR2(15);
l_valid_period_type           VARCHAR2(30);
l_current_invoice_status      VARCHAR2(1) := 'Y';
current_calling_sequence        VARCHAR2(2000);
debug_info                     VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_deferred_accounting<-'
    ||P_calling_sequence;

  ----------------------------------------------------------------------------
  --Step 1 - Validate the deferred accounting flag.  Value should be either
  -- Null, N or Y.
  --
  ----------------------------------------------------------------------------
  IF (((nvl(p_invoice_lines_rec.deferred_acctg_flag, 'N') <> 'N')  AND
       (nvl(p_invoice_lines_rec.deferred_acctg_flag, 'Y') <> 'Y')) OR
      ((nvl(p_invoice_lines_rec.deferred_acctg_flag, 'N') = 'N') AND
       (p_invoice_lines_rec.def_acctg_start_date IS NOT NULL OR
        p_invoice_lines_rec.def_acctg_end_date IS NOT NULL OR
        p_invoice_lines_rec.def_acctg_number_of_periods IS NOT NULL OR
        p_invoice_lines_rec.def_acctg_period_type IS NOT NULL))) THEN
    debug_info := '(Check_deferred_accounting 1)Validate appropriate def data';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
        p_invoice_lines_rec.invoice_line_id,
        'INVALID DEFERRED FLAG',
        p_default_last_updated_by,
        p_default_last_update_login,
        current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE check_defer_acctg_failure;
    END IF;
    l_current_invoice_status := 'N';
  END IF;

  ----------------------------------------------------------------------------
  -- Step 2 - Validate that mandatory deferred accounting data is populated if
  -- deferred accounting is requested.
  -- Also validate that if start date is populated it falls in an open period
  -- which is the same period as the period for the line.
  --
  -----------------------------------------------------------------------------
  IF (nvl(p_invoice_lines_rec.deferred_acctg_flag, 'N') = 'Y') then
    debug_info := '(Check_deferred_accounting 2) Validate start date';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (p_invoice_lines_rec.def_acctg_start_date IS NULL OR
    (p_invoice_lines_rec.def_acctg_number_of_periods IS NULL AND
         p_invoice_lines_rec.def_acctg_end_date IS NULL)) THEN
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INCOMPLETE DEF ACCTG INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE check_defer_acctg_failure;
      END IF;
      l_current_invoice_status := 'N';
    END IF;

    IF (p_invoice_lines_rec.def_acctg_start_date IS NOT NULL) THEN
      BEGIN
        SELECT period_name
          INTO l_period_name
          FROM gl_period_statuses
         WHERE application_id = 200
           AND set_of_books_id = p_set_of_books_id
           AND trunc(p_invoice_lines_rec.def_acctg_start_date)
               between start_date and end_date
           AND closing_status in ('O', 'F')
           AND NVL(adjustment_period_flag, 'N') = 'N';

        IF (l_period_name <> p_invoice_lines_rec.period_name) then
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'Def Acctg Start Date is not is same period as line');
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
               'INVALID DEF START DATE',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE check_defer_acctg_failure;
          END IF;
          l_current_invoice_status := 'N';
        END IF; -- period name is other than line period name

      EXCEPTION
        WHEN NO_DATA_FOUND then
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'Def Acctg Start Date is not in open period');
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
               'INVALID DEF START DATE',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                  'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE check_defer_acctg_failure;
          END IF;
          l_current_invoice_status := 'N';
      END;
    END IF; -- def acctg start date is not null

  END IF; -- step 2

  ----------------------------------------------------------------------------
  -- Step 3 - Validate that the end date is larger than start date if the
  -- deferred flag is Y and the start date is not null.
  --
  -----------------------------------------------------------------------------
  IF (nvl(p_invoice_lines_rec.deferred_acctg_flag, 'N') = 'Y' AND
      p_invoice_lines_rec.def_acctg_start_date is not null AND
      p_invoice_lines_rec.def_acctg_end_date is not null) then
    debug_info := '(Check_deferred_accounting 3) Validate end date';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (trunc(p_invoice_lines_rec.def_acctg_start_date) >
        trunc(p_invoice_lines_rec.def_acctg_end_date)) then
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
          p_invoice_lines_rec.invoice_line_id,
          'INVALID DEF END DATE',
          p_default_last_updated_by,
          p_default_last_update_login,
          current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE check_defer_acctg_failure;
      END IF;
      l_current_invoice_status := 'N';
    END IF;
  END IF; -- Deferred flag is Y and both start date and end dates are not null

  ---------------------------------------------------------------------------
  -- Step 4 - Validate that Number of periods is a positive integer and
  -- Populated if period type is populated but only if deferred flag is Y.
  --
  ---------------------------------------------------------------------------
  IF (nvl(p_invoice_lines_rec.deferred_acctg_flag, 'N') = 'Y' AND
      p_invoice_lines_rec.def_acctg_period_type IS NOT NULL) THEN
    debug_info := '(Check_deferred_accounting 4) Validate number of periods';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                              debug_info);
    END IF;

    IF (p_invoice_lines_rec.def_acctg_number_of_periods is NULL OR
        p_invoice_lines_rec.def_acctg_number_of_periods < 0 OR
        floor(p_invoice_lines_rec.def_acctg_number_of_periods) <>
        ceil(p_invoice_lines_rec.def_acctg_number_of_periods)) THEN
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
          p_invoice_lines_rec.invoice_line_id,
          'INVALID DEF NUM OF PER',
          p_default_last_updated_by,
          p_default_last_update_login,
          current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE check_defer_acctg_failure;
      END IF;
      l_current_invoice_status := 'N';

    END IF;

    BEGIN
      SELECT 'Valid Period Type'
        INTO l_valid_period_type
        FROM xla_lookups
       WHERE lookup_type = 'XLA_DEFERRED_PERIOD_TYPE'
    AND lookup_code = p_invoice_lines_rec.def_acctg_period_type;

    EXCEPTION
      When NO_DATA_FOUND THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
              'INVALID DEF PER TYPE',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,
                   'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE check_defer_acctg_failure;
        END IF;
        l_current_invoice_status := 'N';

    END;
  END IF; -- Deferred flag is Y and period type is populated.

  ---------------------------------------------------------------------------
 -- Step 5 - Validate that Period Type is populated if number of periods is
 -- Populated.  Also validate that it contains a valid type and that it is
 -- Not simulatneously populated with end date.
  --
  ---------------------------------------------------------------------------
  IF (nvl(p_invoice_lines_rec.deferred_acctg_flag, 'N') = 'Y' AND
      p_invoice_lines_rec.def_acctg_number_of_periods IS NOT NULL) THEN
    debug_info := '(Check_deferred_accounting 5) Validate period type';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    End if;

    IF (p_invoice_lines_rec.def_acctg_period_type IS NULL OR
        (p_invoice_lines_rec.def_acctg_period_type IS NOT NULL AND
         p_invoice_lines_rec.def_acctg_end_date IS NOT NULL)) THEN
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
           AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
           p_invoice_lines_rec.invoice_line_id,
           'INVALID DEF PER TYPE',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE check_defer_acctg_failure;
      END IF;
      l_current_invoice_status := 'N';

    END IF; -- period type is null or
            -- it is not null and end date is also not null

  END IF; -- deferred flag is Y and number of periods is populated

  --
  -- Return value
  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);


EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_deferred_accounting;


------------------------------------------------------------------------------
-- This function is used to validate distribution set information.
--
------------------------------------------------------------------------------
FUNCTION v_check_line_dist_set (
         p_invoice_rec                  IN
         AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_invoice_lines_rec            IN OUT NOCOPY
         AP_IMPORT_INVOICES_PKG.r_line_info_rec,
         p_base_currency_code           IN            VARCHAR2,
         p_employee_id                  IN            NUMBER,
         p_gl_date_from_get_info        IN            DATE,
         p_set_of_books_id              IN            NUMBER,
         p_chart_of_accounts_id         IN            NUMBER,
         p_pa_installed                 IN            VARCHAR2,
         p_default_last_updated_by      IN            NUMBER,
         p_default_last_update_login    IN            NUMBER,
         p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
         p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN
IS

  dist_set_check_failure      EXCEPTION;
  current_calling_sequence    VARCHAR2(2000);
  debug_info                  VARCHAR2(500);
  l_current_invoice_status    VARCHAR2(1) := 'Y';
  l_dist_set_id
      NUMBER(15) := p_invoice_lines_rec.distribution_set_id;
  l_dist_set_id_per_name      NUMBER(15);
  l_inactive_date             DATE;
  l_inactive_date_per_name    DATE;
  l_total_percent_distribution
    AP_DISTRIBUTION_SETS.TOTAL_PERCENT_DISTRIBUTION%TYPE;
  l_dset_lines_tab            AP_IMPORT_VALIDATION_PKG.dset_line_tab_type;
  l_expd_item_date            ap_invoice_lines.expenditure_item_date%TYPE:= '';
  l_error_found               VARCHAR2(1);
  i                           BINARY_INTEGER := 0;
  l_running_total_amount      NUMBER := 0;
  l_running_total_base_amt    NUMBER := 0;
  l_max_amount                NUMBER := 0;
  l_max_i                     BINARY_INTEGER := 0;
  l_running_total_pa_qty      NUMBER := 0;
  l_max_pa_quantity           NUMBER := 0;
  l_max_i_pa_qty              BINARY_INTEGER := 0;
  l_first_pa_qty              BOOLEAN := TRUE;
  l_award_set_id              AP_DISTRIBUTION_SET_LINES.award_id%TYPE;
  l_award_id                  AP_DISTRIBUTION_SET_LINES.award_id%TYPE;
  l_msg_application           VARCHAR2(25);
  l_msg_type                  VARCHAR2(25);
  l_msg_token1                VARCHAR2(30);
  l_msg_token2                VARCHAR2(30);
  l_msg_token3                VARCHAR2(30);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(500);
  l_billable_flag             VARCHAR2(60) := '';
  l_overlayed_ccid            NUMBER;
  l_unbuilt_flex              VARCHAR2(240):='';
  l_reason_unbuilt_flex       VARCHAR2(2000):='';


  CURSOR dist_set_lines IS
  SELECT DSL.dist_code_combination_id,
         DSL.percent_distribution,
         DSL.type_1099,
         DSL.description,
         DSL.distribution_set_line_number,
         DSL.attribute_category,
         DSL.attribute1,
         DSL.attribute2,
         DSL.attribute3,
         DSL.attribute4,
         DSL.attribute5,
         DSL.attribute6,
         DSL.attribute7,
         DSL.attribute8,
         DSL.attribute9,
         DSL.attribute10,
         DSL.attribute11,
         DSL.attribute12,
         DSL.attribute13,
         DSL.attribute14,
         DSL.attribute15,
         'DIST_SET_LINE',
         DSL.project_accounting_context,
         DSL.project_id,
         DSL.task_id,
         DSL.expenditure_organization_id,
         DSL.expenditure_type,
         NULL, -- pa_quantity
         NULL, -- pa_addition_flag
         DSL.org_id,
         DSL.award_id,
         0,    -- amount
         0     -- base_amount
    FROM ap_distribution_set_lines DSL
   WHERE DSL.distribution_set_id = l_dist_set_id
   ORDER BY distribution_set_line_number;

   l_sys_link_function varchar2(2); ---bugfix:5725904
  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence :='AP_IMPORT_VALIDATION_PKG.v_check_line_dist_set'
                               || '<-' ||P_calling_sequence;

    ------------------------------------------------------------------------
    -- Step 1
    -- Validate Distribution Set Id
    ------------------------------------------------------------------------
    debug_info := '(Check Line Dist Set 1) Validate Distribution Set Id';
    ------------------------------------------------------------------------
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,
          debug_info);
    END IF;

    BEGIN
      IF (p_invoice_lines_rec.distribution_set_id IS NOT NULL) THEN
        SELECT distribution_set_id , inactive_date, total_percent_distribution
          INTO l_dist_set_id, l_inactive_date, l_total_percent_distribution
          FROM ap_distribution_sets
         WHERE distribution_set_id = p_invoice_lines_rec.distribution_set_id;
      END IF;

      IF (p_invoice_lines_rec.distribution_set_name IS NOT NULL) THEN
        SELECT distribution_set_id , inactive_date, total_percent_distribution
          INTO l_dist_set_id_per_name, l_inactive_date_per_name,
           l_total_percent_distribution
          FROM ap_distribution_sets
         WHERE distribution_set_name
               = p_invoice_lines_rec.distribution_set_name;
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INVALID DISTRIBUTION SET',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<- '||current_calling_sequence);
          END IF;
          RAISE dist_set_check_failure;
        END IF;

        l_current_invoice_status := 'N';
        p_current_invoice_status := l_current_invoice_status;
      RETURN (TRUE);
    END;


    IF ((l_dist_set_id is NOT NULL) AND
        (l_dist_set_id_per_name is NOT NULL) AND
        (l_dist_set_id <> l_dist_set_id_per_name)) Then
      -----------------------------------------------------------------------
      -- Step 2
      -- Check for INCONSISTENT DIST SET
      -----------------------------------------------------------------------
      debug_info := '(Check Line Dist Set 2) Check for INCONSISTENT DIST SET';
      -----------------------------------------------------------------------
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            debug_info);
      End if;

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
              'INCONSISTENT DIST SET',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-' ||current_calling_sequence);
        END IF;
        RAISE dist_set_check_failure;
      END IF;

      l_current_invoice_status := 'N';

    ELSE
      ----------------------------------------------------------------------
      -- Step 3
      -- look for inactive DIST SET
      ----------------------------------------------------------------------
      debug_info := '(Check Line Dist Set 3.1) Check for inactive DIST SET';
      ----------------------------------------------------------------------
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            debug_info);
      END IF;

      IF (( AP_IMPORT_INVOICES_PKG.g_inv_sysdate >=
            nvl(trunc(l_inactive_date), AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1))
            OR
           (AP_IMPORT_INVOICES_PKG.g_inv_sysdate >=
            nvl(trunc(l_inactive_date_per_name),
                AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1))) THEN

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
                'INACTIVE DISTRIBUTION SET',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<- '||current_calling_sequence);
          END IF;
          RAISE dist_set_check_failure;
        END IF; -- end of insert_rejection

        l_current_invoice_status := 'N';
      END IF;  -- end of check l_active_date
      ----------------------------------------------------------------------
      debug_info := '(Check Line Dist Set 3.2) Use dist_set_id_per_name';
      ----------------------------------------------------------------------
      IF ((l_dist_set_id is Null) AND
          (l_dist_set_id_per_name is Not Null)) THEN

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;
        l_dist_set_id := l_dist_set_id_per_name;
      END IF;
    END IF; -- end of step 2 and step 3

    ----------------------------------------------------------------------
    -- Step 4
    -- Validate the info. in distribution set lines before proceeding
    -- further. At this point we have validated the basic distribution
    -- set information.  Now we need to validate project, task,
    -- expenditure details and award for each distribution set lines.
    -- Also we need to validate the account and overlayed accounts if any.
    ----------------------------------------------------------------------
    IF (l_dist_set_id is not null) THEN
      --------------------------------------------------------------------
      debug_info := '(v_check_line_dist_set 4.1) Get all ' ||
                    'the information in the distribution sets';
      --------------------------------------------------------------------
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      END IF;
      l_dset_lines_tab.DELETE;
      OPEN dist_set_lines;
      FETCH dist_set_lines BULK COLLECT INTO l_dset_lines_tab;
      CLOSE dist_set_lines;


      ------------------------------------------------------------------
      debug_info := '(v_check_line_dist_set 4.2) Loop through read '||
                'dset lines and validate';
      ------------------------------------------------------------------
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
      END IF;

      FOR i IN l_dset_lines_tab.first..l_dset_lines_tab.last
      LOOP

        ----------------------------------------------------------------
     debug_info := '(v_check_line_dist_set 4.2.a) Get expenditure '||
      'item date if null and dist set line will be project related';
    ----------------------------------------------------------------
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

        IF (p_invoice_lines_rec.expenditure_item_date IS NULL AND
        l_expd_item_date IS NULL AND
        (p_invoice_lines_rec.project_id IS NOT NULL OR
         l_dset_lines_tab(i).project_id IS NOT NULL)) THEN
          l_expd_item_date := AP_INVOICES_PKG.get_expenditure_item_date(
                 p_invoice_rec.invoice_id,
                 p_invoice_rec.invoice_date,
                 nvl(p_invoice_lines_rec.accounting_date,
                     p_gl_date_from_get_info),
                 NULL,
                 NULL,
             l_error_found);
       IF (l_error_found = 'Y') then
             RAISE dist_set_check_failure;
           END IF;
        ELSIF (p_invoice_lines_rec.expenditure_item_date IS NOT NULL AND
           l_expd_item_date IS NULL) THEN
          l_expd_item_date := p_invoice_lines_rec.expenditure_item_date;
        END IF;

        -----------------------------------------------------------------
    debug_info := '(v_check_line_dist_set 4.2.b) Populate amount '||
      'and base amount for the distribution into PL/SQL table';
    -----------------------------------------------------------------
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;
        IF (l_total_percent_distribution <> 100) THEN
          l_dset_lines_tab(i).amount := 0;
      l_dset_lines_tab(i).base_amount := 0;
    ELSE
      l_dset_lines_tab(i).amount := AP_UTILITIES_PKG.Ap_Round_Currency(
                              NVL(l_dset_lines_tab(i).percent_distribution,0)
                     * NVL(p_invoice_lines_rec.amount,0)/100,
                  p_invoice_rec.invoice_currency_code);
          l_dset_lines_tab(i).base_amount :=
                          AP_UTILITIES_PKG.Ap_Round_Currency(
                 NVL(l_dset_lines_tab(i).amount, 0)
                 * NVL(p_invoice_rec.exchange_rate, 1),
                                 p_base_currency_code);
        END IF;

    --
    -- Maintain the running totals of the amounts for rounding
    l_running_total_amount := l_running_total_amount +
      l_dset_lines_tab(i).amount;
    l_running_total_base_amt := l_running_total_base_amt +
      l_dset_lines_tab(i).base_amount;

    -- Keep track of the particular distribution with the max
    -- amount.  That is the distribution that will take the
    -- rounding if any.
        IF (ABS(l_max_amount) <= ABS(l_dset_lines_tab(i).amount) OR
        i = 0) THEN
          l_max_amount := l_dset_lines_tab(i).amount;
      l_max_i := i;
    END IF;

    ----------------------------------------------------------------
    debug_info := '(v_check_line_dist_set 4.2.c) Populate project '||
      'info if either dist set line has it or invoice line has it';
    -------------------------------------------------------------------
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    -- If the distribution set line does not contain project
    -- information but the line does, then copy project information
    -- from the line.
    IF (l_dset_lines_tab(i).project_id IS NULL AND
         p_invoice_lines_rec.project_id IS NOT NULL) THEN
      l_dset_lines_tab(i).project_source := 'INVOICE_LINE';
      l_dset_lines_tab(i).project_accounting_context := 'Yes';
          l_dset_lines_tab(i).project_id := p_invoice_lines_rec.project_id;
      l_dset_lines_tab(i).task_id := p_invoice_lines_rec.task_id;
          l_dset_lines_tab(i).expenditure_type :=
        p_invoice_lines_rec.expenditure_type;
      l_dset_lines_tab(i).expenditure_organization_id :=
        p_invoice_lines_rec.expenditure_organization_id;
    END IF;

    -- Regardless of where the project information came from,
    -- track the pa quantity but only if this is not a skeleton
    -- distribution set and only if the distribution turns out to
    -- be project related.
    IF (l_dset_lines_tab(i).project_id IS NOT NULL) THEN
      IF (l_total_percent_distribution <> 100) THEN
        NULL;
      ELSE
        IF (p_invoice_lines_rec.pa_quantity IS NOT NULL AND
            p_invoice_lines_rec.amount <> 0) THEN
          l_dset_lines_tab(i).pa_quantity :=
      			     p_invoice_lines_rec.pa_quantity
               				* l_dset_lines_tab(i).amount /
               				p_invoice_lines_rec.amount;
        END IF;
      END IF;

      -- Keep track of the particular distribution with the max
      -- pa quantity.  That is the distribution that will take the
      -- rounding if any.
      IF (l_first_pa_qty AND
          l_dset_lines_tab(i).pa_quantity IS NOT NULL) THEN
            l_max_pa_quantity := l_dset_lines_tab(i).pa_quantity;
            l_max_i_pa_qty := i;
            l_first_pa_qty := FALSE;
      ELSIF (l_dset_lines_tab(i).pa_quantity IS NOT NULL AND
             NOT l_first_pa_qty ) THEN
        IF (ABS(l_max_pa_quantity) <=
            ABS(l_dset_lines_tab(i).pa_quantity)) THEN
          l_max_pa_quantity := l_dset_lines_tab(i).pa_quantity;
          l_max_i_pa_qty := i;
        END IF;
      END IF;

      l_running_total_pa_qty := Nvl(l_dset_lines_tab(i).pa_quantity,0);
      l_dset_lines_tab(i).pa_addition_flag := 'N';

    ELSE
      l_dset_lines_tab(i).pa_addition_flag := 'E';

    END IF; -- project id is not null

    -----------------------------------------------------------------
    debug_info := '(v_check_line_dist_set 4.2.d) Populate/validate '||
      'award information';
    -----------------------------------------------------------------
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;
    --
    -- Default award id from line if award id is not populated
    -- for the distribution set line.
    --
        IF ( l_current_invoice_status = 'Y') THEN

	   IF (l_dset_lines_tab(i).award_id IS NOT NULL) THEN
	       l_award_set_id := l_dset_lines_tab(i).award_id;
	   ELSIF (p_invoice_lines_rec.award_id IS NOT NULL) THEN
	      l_dset_lines_tab(i).award_id := p_invoice_lines_rec.award_id;
	      l_award_id := p_invoice_lines_rec.award_id;
	   END IF;

	   IF (l_award_set_id IS NOT NULL) THEN
	       GMS_AP_API.GET_DIST_SET_AWARD(
		                l_dist_set_id,
		                l_dset_lines_tab(i).distribution_set_line_number,
		                l_award_set_id,
		                l_award_id);

	      l_dset_lines_tab(i).award_id:= l_award_id ;
	  END IF;


          debug_info := '(v_check_line_dist_set 4.2.d.1) - ' ||
                        'Call GMS API to validate award info->temp award dist';
          IF ( AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' ) THEN
            AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

          ----------------------------------------------------------------
          debug_info := '(v_check_line_dist_set 4.2.d.1) - ' ||
                        'Get award id from award set from GMS' ;
          ----------------------------------------------------------------
          IF ( AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' ) THEN
            AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;
          -- Get the value of award_id from GMS API
          -- Note that the award in the distribution set line or interface
          -- invoice line record is truly an award set id, we need GMS
          -- to derive the actual award id and the same must be stored in
          -- the distributions when they are created.
          -- The call is commented out because it does not exist in 11.6 yet.
          IF (l_award_set_id IS NOT NULL) THEN
             GMS_AP_API.GET_DIST_SET_AWARD(
                l_dist_set_id,
                l_dset_lines_tab(i).distribution_set_line_number,
                l_award_set_id,
                l_award_id);
          END IF;

          ---------------------------------------------------------------------
          debug_info := '(v_check_line_dist_set 4.2.d.2) - ' ||
                        'Call GMS API - validate award -l_award_id->' ||
                         to_char(l_award_id) ;
          ---------------------------------------------------------------------
          IF ( AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' ) THEN
            AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

          /*Bug#10235692 - passing 'APTXNIMP' to p_calling_sequence */
          IF (GMS_AP_API.v_check_line_award_info (
              p_invoice_line_id  => p_invoice_lines_rec.invoice_line_id,
              p_line_amount      => l_dset_lines_tab(i).amount,
              p_base_line_amount => l_dset_lines_tab(i).base_amount,
              p_dist_code_concatenated   =>
            			          p_invoice_lines_rec.dist_code_concatenated,
              p_dist_code_combination_id =>
        			          l_dset_lines_tab(i).dist_code_combination_id,
              p_default_po_number        => NULL,
              p_po_number                => NULL,
              p_po_header_id             => NULL,
              p_distribution_set_id      => l_dist_set_id,
              p_distribution_set_name    =>
                			p_invoice_lines_rec.distribution_set_name ,
              p_set_of_books_id          => p_set_of_books_id,
              p_base_currency_code       => p_base_currency_code,
              p_invoice_currency_code    =>
                			p_invoice_rec.invoice_currency_code ,
              p_exchange_rate            => p_invoice_rec.exchange_rate,
              p_exchange_rate_type       =>
                			p_invoice_rec.exchange_rate_type,
              p_exchange_rate_date       =>
                			p_invoice_rec.exchange_date,
              p_project_id               => l_dset_lines_tab(i).project_id,
              p_task_id                  => l_dset_lines_tab(i).task_id,
              p_expenditure_type         =>
            				l_dset_lines_tab(i).expenditure_type,
              p_expenditure_item_date    => l_expd_item_date,
              p_expenditure_organization_id =>
                			l_dset_lines_tab(i).expenditure_organization_id,
              p_project_accounting_context =>
            				l_dset_lines_tab(i).project_accounting_context,
              p_pa_addition_flag           =>
            				l_dset_lines_tab(i).pa_addition_flag,
              p_pa_quantity                =>
                			l_dset_lines_tab(i).pa_quantity,
              p_employee_id                => p_employee_id,
              p_vendor_id                  => p_invoice_rec.vendor_id,
              p_chart_of_accounts_id       => p_chart_of_accounts_id,
              p_pa_installed               => p_pa_installed,
              p_prorate_across_flag        =>
                			NVL(p_invoice_lines_rec.prorate_across_flag, 'N'),
              p_lines_attribute_category   =>
                			p_invoice_lines_rec.attribute_category,
              p_lines_attribute1   => p_invoice_lines_rec.attribute1,
              p_lines_attribute2   => p_invoice_lines_rec.attribute2,
              p_lines_attribute3   => p_invoice_lines_rec.attribute3,
              p_lines_attribute4   => p_invoice_lines_rec.attribute4,
              p_lines_attribute5   => p_invoice_lines_rec.attribute5,
              p_lines_attribute6   => p_invoice_lines_rec.attribute6,
              p_lines_attribute7   => p_invoice_lines_rec.attribute7,
              p_lines_attribute8   => p_invoice_lines_rec.attribute8,
              p_lines_attribute9   => p_invoice_lines_rec.attribute9,
              p_lines_attribute10  => p_invoice_lines_rec.attribute10,
              p_lines_attribute11  => p_invoice_lines_rec.attribute11,
              p_lines_attribute12  => p_invoice_lines_rec.attribute12,
              p_lines_attribute13  => p_invoice_lines_rec.attribute13,
              p_lines_attribute14  => p_invoice_lines_rec.attribute14,
              p_lines_attribute15  => p_invoice_lines_rec.attribute15,
              p_attribute_category => l_dset_lines_tab(i).attribute_category,
              p_attribute1         => l_dset_lines_tab(i).attribute1,
              p_attribute2         => l_dset_lines_tab(i).attribute2,
              p_attribute3         => l_dset_lines_tab(i).attribute3,
              p_attribute4         => l_dset_lines_tab(i).attribute4,
              p_attribute5         => l_dset_lines_tab(i).attribute5,
              p_attribute6         => l_dset_lines_tab(i).attribute6,
              p_attribute7         => l_dset_lines_tab(i).attribute7,
              p_attribute8         => l_dset_lines_tab(i).attribute8,
              p_attribute9         => l_dset_lines_tab(i).attribute9,
              p_attribute10        => l_dset_lines_tab(i).attribute10,
              p_attribute11        => l_dset_lines_tab(i).attribute11,
              p_attribute12        => l_dset_lines_tab(i).attribute12,
              p_attribute13        => l_dset_lines_tab(i).attribute13,
              p_attribute14        => l_dset_lines_tab(i).attribute14,
              p_attribute15        => l_dset_lines_tab(i).attribute15,
              p_partial_segments_flag      =>
                                   p_invoice_lines_rec.partial_segments,
              p_default_last_updated_by    => p_default_last_updated_by,
              p_default_last_update_login  => p_default_last_update_login,
              p_calling_sequence   => 'APTXNIMP',
              p_award_id           => l_award_id,
              p_event              => 'AWARD_SET_ID_REQUEST' ) <> TRUE ) THEN
            --------------------------------------------------------------
            debug_info := '(v_check_line_dist_set 4.2.d.3) - ' ||
                          'After Call GMS API - Invalid GMS Info:Reject';
            --------------------------------------------------------------
            IF ( AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' ) THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

            IF ( AP_IMPORT_UTILITIES_PKG.insert_rejections(
                     AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                      p_invoice_lines_rec.invoice_line_id,
                      'INSUFFICIENT GMS INFO',
                      p_default_last_updated_by,
                      p_default_last_update_login,
                      current_calling_sequence) <> TRUE) THEN
              RAISE dist_set_check_failure;
            END IF;
            l_current_invoice_status := 'N';
          END IF; -- End of gms_ap_api.v_check_line_award_info.
        END IF; -- end of check l_current_invoice_status

        -----------------------------------------------------------
        debug_info := '(v_check_line_dist_set 4.2.e) - ' ||
                  'Validate project information';
        -----------------------------------------------------------
        IF ( AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' ) THEN
          AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;
        IF (l_dset_lines_tab(i).project_id is not null AND
        l_current_invoice_status = 'Y') THEN

	  --bugfxi:5725904
	  If (p_invoice_rec.invoice_type_lookup_code ='EXPENSE REPORT') Then
	        l_sys_link_function :='ER' ;
	  Else
	        l_sys_link_function :='VI' ;
	  End if;

          PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION(
            X_PROJECT_ID          => l_dset_lines_tab(i).project_id,
            X_TASK_ID             => l_dset_lines_tab(i).task_id,
            X_EI_DATE             => l_expd_item_date,
            X_EXPENDITURE_TYPE    => l_dset_lines_tab(i).expenditure_type,
            X_NON_LABOR_RESOURCE  => null,
            X_PERSON_ID           => p_employee_id,
            X_QUANTITY            => NVL(l_dset_lines_tab(i).pa_quantity,'1'),
            X_denom_currency_code => p_invoice_rec.invoice_currency_code,
            X_acct_currency_code  => p_base_currency_code,
            X_denom_raw_cost      => l_dset_lines_tab(i).amount,
            X_acct_raw_cost       => l_dset_lines_tab(i).base_amount,
            X_acct_rate_type      => p_invoice_rec.exchange_rate_type,
            X_acct_rate_date      => p_invoice_rec.exchange_date,
            X_acct_exchange_rate  => p_invoice_rec.exchange_rate,
            X_TRANSFER_EI         => null,
            X_INCURRED_BY_ORG_ID  =>
          	l_dset_lines_tab(i).expenditure_organization_id,
            X_NL_RESOURCE_ORG_ID  => null,
            X_TRANSACTION_SOURCE  => l_sys_link_function,--Bug 3487412 --bug:5725904
            X_CALLING_MODULE      => 'apiimptb.pls',
            X_VENDOR_ID           => p_invoice_rec.vendor_id,
            X_ENTERED_BY_USER_ID  => to_number(FND_GLOBAL.USER_ID),
            X_ATTRIBUTE_CATEGORY  => l_dset_lines_tab(i).attribute_category,
            X_ATTRIBUTE1          => l_dset_lines_tab(i).attribute1,
            X_ATTRIBUTE2          => l_dset_lines_tab(i).attribute2,
            X_ATTRIBUTE3          => l_dset_lines_tab(i).attribute3,
            X_ATTRIBUTE4          => l_dset_lines_tab(i).attribute4,
            X_ATTRIBUTE5          => l_dset_lines_tab(i).attribute5,
            X_ATTRIBUTE6          => l_dset_lines_tab(i).attribute6,
            X_ATTRIBUTE7          => l_dset_lines_tab(i).attribute7,
            X_ATTRIBUTE8          => l_dset_lines_tab(i).attribute8,
            X_ATTRIBUTE9          => l_dset_lines_tab(i).attribute9,
            X_ATTRIBUTE10         => l_dset_lines_tab(i).attribute10,
            X_ATTRIBUTE11         => l_dset_lines_tab(i).attribute11,
            X_ATTRIBUTE12         => l_dset_lines_tab(i).attribute12,
            X_ATTRIBUTE13         => l_dset_lines_tab(i).attribute13,
            X_ATTRIBUTE14         => l_dset_lines_tab(i).attribute14,
            X_ATTRIBUTE15         => l_dset_lines_tab(i).attribute15,
            X_msg_application     => l_msg_application,
            X_msg_type            => l_msg_type,
            X_msg_token1          => l_msg_token1,
            X_msg_token2          => l_msg_token2,
            X_msg_token3          => l_msg_token3,
            X_msg_count           => l_msg_count,
            X_msg_data            => l_msg_data,
            X_BILLABLE_FLAG       => l_billable_flag,
            P_Document_Type       => p_invoice_rec.invoice_type_lookup_code,
            P_Document_Line_Type  => p_invoice_lines_rec.line_type_lookup_code);

          IF (l_msg_data IS NOT NULL) THEN
            --------------------------------------------------------------
         debug_info := '(v_check_line_dist_set 4.2.e.1) - Project '
                      ||'validate '
                          ||'PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION Fails'
                          ||'->Insert Rejection';
            --------------------------------------------------------------
            IF ( AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' ) THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

             -- Bug 5214592 . Added the debug message.
             debug_info := SUBSTR(l_msg_data,1,80);
             IF ( AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' ) THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                  AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
              END IF;


            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                      AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                      p_invoice_lines_rec.invoice_line_id,
                      'PA FLEXBUILD FAILED',
                      p_default_last_updated_by,
                      p_default_last_update_login,
                      current_calling_sequence) <> TRUE) THEN
              RAISE dist_set_check_failure;
            END IF;

            l_current_invoice_status := 'N';

          END IF; -- end of check l_msg_data is not null
        END IF;-- end of l_project_id not null/l_current_invoice_status = 'Y'

        -----------------------------------------------------------------
        -- Validate account and account overlay depending on set of
    -- available data
        --
        debug_info := '(v_check_line_dist_set 4.2.f) - ' ||
                      'validate account';
        -----------------------------------------------------------------
        IF ( AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' ) THEN
          AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

        IF ((l_dset_lines_tab(i).project_id IS NULL AND
         p_invoice_lines_rec.dist_code_combination_id IS NULL) OR
        (l_dset_lines_tab(i).project_id IS NOT NULL AND
         l_dset_lines_tab(i).project_source <> 'INVOICE_LINE')) THEN
      --
          -- Account source is not at the line. Overlay may happen.
          -- We need to avoid redoing the account validations done
      -- at the line.  If there is no default account (dist_code
      -- combination_id at the line is null) and either there is
      -- no project info in this distribution or the project info
      -- does not come from the line, then new account sources
      -- are considered and we do need to validate.
      --
          IF (p_invoice_lines_rec.dist_code_combination_id IS NULL AND
              p_invoice_lines_rec.dist_code_concatenated is NULL AND
              p_invoice_lines_rec.balancing_segment is NULL AND
              p_invoice_lines_rec.account_segment is NULL AND
              p_invoice_lines_rec.cost_center_segment is NULL) THEN

            -------------------------------------------------------------
        	debug_info := '(v_check_line_dist_set 4.2.f.1) - ' ||
                  'validate account from dist set line - no overlay';
            -------------------------------------------------------------
            IF ( AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' ) THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

            IF ( NOT (AP_UTILITIES_PKG.IS_CCID_VALID(
                        l_dset_lines_tab(i).dist_code_combination_id,
                	p_chart_of_accounts_id,
            		nvl(p_invoice_lines_rec.accounting_date,
                        p_gl_date_from_get_info),
                  	current_calling_sequence))) THEN
              IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                    AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                    p_invoice_lines_rec.invoice_line_id,
                    'INVALID DISTRIBUTION ACCT',
                    p_default_last_updated_by,
                    p_default_last_update_login,
                    current_calling_sequence) <> TRUE) THEN
                RAISE dist_set_check_failure;
              END IF;

              l_current_invoice_status := 'N';

            END IF; -- end of call function IS_CCID_VALID

          --
      -- Again don't overlay and validate if the concatenated segments
      -- is other than partial, since that has already been done at
      -- line level and that would completely override the dist set line
          -- account so, no new validation would be performed.
      --
          ELSIF (p_invoice_lines_rec.dist_code_combination_id IS NULL AND
         (p_invoice_lines_rec.dist_code_concatenated IS NOT NULL OR
          p_invoice_lines_rec.balancing_segment is NOT NULL OR
                  p_invoice_lines_rec.account_segment is NOT NULL OR
                  p_invoice_lines_rec.cost_center_segment is NOT NULL)) THEN
        --
            -- Make sure we don't go through the overlay and validation
            -- if the concatenated segments was full or if the line is
        -- project related and projects does not allow override
        --
        -- 7531219 need to do overlay and validate even in case of full overlay
        -- as we are not doing earlier

            IF (/*(p_invoice_lines_rec.dist_code_concatenated IS NULL OR
         (p_invoice_lines_rec.dist_code_concatenated IS NOT NULL AND
          p_invoice_lines_rec.partial_segments <> 'N')) AND */
        (l_dset_lines_tab(i).project_id IS NULL OR
         AP_IMPORT_INVOICES_PKG.g_pa_allows_overrides = 'Y')) THEN
          l_overlayed_ccid := l_dset_lines_tab(i).dist_code_combination_id;

          -----------------------------------------------------------
          debug_info := '(v_check_line_dist_set 4.2.f.2) - ' ||
                 'overlay dist set line account with line overlay data';
              -----------------------------------------------------------
              IF ( AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' ) THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
              END IF;
              IF ( NOT (AP_UTILITIES_PKG.OVERLAY_SEGMENTS (
                          p_invoice_lines_rec.balancing_segment,
                          p_invoice_lines_rec.cost_center_segment,
                          p_invoice_lines_rec.account_segment,
                          p_invoice_lines_rec.dist_code_concatenated,
                          l_overlayed_ccid,
                          p_set_of_books_id,
                          'CREATE_COMB_NO_AT',
                          l_unbuilt_flex,
                          l_reason_unbuilt_flex,
                          FND_GLOBAL.RESP_APPL_ID,
                          FND_GLOBAL.RESP_ID,
                          FND_GLOBAL.USER_ID,
                          current_calling_sequence,
                          NULL,
                          p_invoice_lines_rec.accounting_date))) THEN  --7531219
        --------------------------------------------------------
        debug_info := 'Failure found during overlay';
        debug_info := debug_info || '-> l_unbuilt_flex= ' ||
                            l_unbuilt_flex ||
                            '-> l_dist_ccid=' ||
                            to_char(l_overlayed_ccid);
                --------------------------------------------------------
                IF ( AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' ) THEN
                  AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
                END IF;
                RAISE dist_set_check_failure;
          ELSE
            IF (l_overlayed_ccid = -1) THEN
              ----------------------------------------------------------
              -- debug_info := 'Overlay return -1';
          ----------------------------------------------------------
                  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
                      AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
                  END IF;

                  IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                      AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                       p_invoice_lines_rec.invoice_line_id,
                      'INVALID ACCT OVERLAY',
                       p_default_last_updated_by,
                       p_default_last_update_login,
                       current_calling_sequence) <> TRUE) THEN
                    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          		    AP_IMPORT_UTILITIES_PKG.Print(
             			AP_IMPORT_INVOICES_PKG.g_debug_switch,
                         	  'insert_rejections<-'||current_calling_sequence);
                    END IF;
                    RAISE dist_set_check_failure;

                  END IF;

                  l_current_invoice_status := 'N';

                END IF; -- Code combination id is -1

              END IF; -- Overlay returned other than TRUE

            END IF; -- Overlay info is available, and we should try overlay

          END IF; -- Overaly info is available

        END IF; -- The distribution may require overlay or at least validation
               -- of the account since the account won't come from the line
            -- which has already validated its account/overlay.

        -------------------------------------------------------------------
        -- Call Grants - Clean up
        --
        debug_info := '(v_check_line_dist_set 4.2.g) - ' ||
                      'AWARD_ID_REMOVE: Check  GMS Info ';
        -------------------------------------------------------------------
        IF (l_current_invoice_status = 'Y' AND l_award_id is not null) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

	  GMS_AP_API.validate_transaction
              ( x_project_id		=> l_dset_lines_tab(i).project_id,
		x_task_id		=> l_dset_lines_tab(i).task_id,
		x_award_id		=> l_award_id,
		x_expenditure_type	=> l_dset_lines_tab(i).expenditure_type,
		x_expenditure_item_date => l_expd_item_date,
		x_calling_sequence      => 'AWARD_ID',
		x_msg_application       => l_msg_application,
		x_msg_type              => l_msg_type,
		x_msg_count             => l_msg_count,
		x_msg_data              => l_msg_data ) ;

	  IF (l_msg_data IS NOT NULL) THEN
	      --------------------------------------------------------------
	      debug_info := '(v_check_line_dist_set 4.2.d.3) - ' ||
				'After Call GMS API - Invalid GMS Info:Reject';
	      --------------------------------------------------------------
	      IF ( AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' ) THEN
	           AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
	      END IF;

	      IF ( AP_IMPORT_UTILITIES_PKG.insert_rejections(
	      	      	      AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
	      	      	      p_invoice_lines_rec.invoice_line_id,
	      	      	      'INSUFFICIENT GMS INFO',
	      	      	      p_default_last_updated_by,
	      	      	      p_default_last_update_login,
	      	      	      current_calling_sequence) <> TRUE) THEN

	      	      RAISE dist_set_check_failure;
	      END IF;
	      l_current_invoice_status := 'N';
	  END IF;

        END IF; -- l_current_invoice_Status ='Y' AND l_award_id is not null

      END LOOP;

      -----------------------------------------------------------------------
      -- Step 5 - Re-Validate PA info if it is not a skeleton distribution set
      -- and there was rounding in the amount
      -----------------------------------------------------------------------

      IF ( l_current_invoice_status = 'Y'  AND
           l_total_percent_distribution = 100 AND
       (p_invoice_lines_rec.amount <> l_running_total_amount OR
        p_invoice_lines_rec.base_amount <> l_running_total_base_amt OR
        Nvl(p_invoice_lines_rec.pa_quantity, 0) <>
        Nvl(l_running_total_pa_qty,0))) THEN

    --
    -- If rounding in the amount for a project related distribution
    -- then lump all rounding onto the same distribution.
    -- Else, find the distribution for any pa quantity rounding.
    --
    IF (l_dset_lines_tab(l_max_i).project_id IS NOT NULL) THEN

          l_dset_lines_tab(l_max_i).amount := l_dset_lines_tab(l_max_i).amount
        + p_invoice_lines_rec.amount
        - l_running_total_amount;
      l_dset_lines_tab(l_max_i).base_amount :=
        l_dset_lines_tab(l_max_i).base_amount
        + p_invoice_lines_rec.base_amount
        - l_running_total_base_amt;
      IF (l_dset_lines_tab(l_max_i).pa_quantity IS NOT NULL) THEN
          l_dset_lines_tab(l_max_i).pa_quantity :=
          l_dset_lines_tab(l_max_i).pa_quantity
          + p_invoice_lines_rec.pa_quantity
          - l_running_total_pa_qty;
      END IF;

    ELSIF l_dset_lines_tab.exists(l_max_i_pa_qty) THEN  -- Bug 5713771
      IF   (l_dset_lines_tab(l_max_i_pa_qty).project_id IS NOT NULL AND
           l_dset_lines_tab(l_max_i_pa_qty).pa_quantity IS NOT NULL) THEN

        l_dset_lines_tab(l_max_i_pa_qty).pa_quantity :=
        l_dset_lines_tab(l_max_i_pa_qty).pa_quantity
        + p_invoice_lines_rec.pa_quantity
        - l_running_total_pa_qty;
        l_max_i := l_max_i_pa_qty;
      END IF;
    END IF;

    IF (l_dset_lines_tab(l_max_i).project_id IS NOT NULL) THEN

          If (p_invoice_rec.invoice_type_lookup_code ='EXPENSE REPORT') Then
              l_sys_link_function :='ER' ;
          Else
	      l_sys_link_function :='VI' ;
	  End if;

          PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION(
          X_PROJECT_ID          => l_dset_lines_tab(l_max_i).project_id,
          X_TASK_ID             => l_dset_lines_tab(l_max_i).task_id,
          X_EI_DATE             => l_expd_item_date,
          X_EXPENDITURE_TYPE    => l_dset_lines_tab(l_max_i).expenditure_type,
          X_NON_LABOR_RESOURCE  => null,
          X_PERSON_ID           => p_employee_id,
          X_QUANTITY            => Nvl(l_dset_lines_tab(l_max_i).pa_quantity,
                                       '1'),
          X_denom_currency_code => p_invoice_rec.invoice_currency_code,
          X_acct_currency_code  => p_base_currency_code,
          X_denom_raw_cost      => l_dset_lines_tab(l_max_i).amount,
          X_acct_raw_cost       => l_dset_lines_tab(l_max_i).base_amount,
          X_acct_rate_type      => p_invoice_rec.exchange_rate_type,
          X_acct_rate_date      => p_invoice_rec.exchange_date,
          X_acct_exchange_rate  => p_invoice_rec.exchange_rate,
          X_TRANSFER_EI         => null,
          X_INCURRED_BY_ORG_ID  =>
             l_dset_lines_tab(l_max_i).expenditure_organization_id,
          X_NL_RESOURCE_ORG_ID  => null,
          X_TRANSACTION_SOURCE  => l_sys_link_function,--Bug 3487412 made the change
          X_CALLING_MODULE      => 'apiimptb.pls',
          X_VENDOR_ID           => p_invoice_rec.vendor_id,
          X_ENTERED_BY_USER_ID  => to_number(FND_GLOBAL.USER_ID),
          X_ATTRIBUTE_CATEGORY  =>
              l_dset_lines_tab(l_max_i).attribute_category,
          X_ATTRIBUTE1          => l_dset_lines_tab(l_max_i).attribute1,
          X_ATTRIBUTE2          => l_dset_lines_tab(l_max_i).attribute2,
          X_ATTRIBUTE3          => l_dset_lines_tab(l_max_i).attribute3,
          X_ATTRIBUTE4          => l_dset_lines_tab(l_max_i).attribute4,
          X_ATTRIBUTE5          => l_dset_lines_tab(l_max_i).attribute5,
          X_ATTRIBUTE6          => l_dset_lines_tab(l_max_i).attribute6,
          X_ATTRIBUTE7          => l_dset_lines_tab(l_max_i).attribute7,
          X_ATTRIBUTE8          => l_dset_lines_tab(l_max_i).attribute8,
          X_ATTRIBUTE9          => l_dset_lines_tab(l_max_i).attribute9,
          X_ATTRIBUTE10         => l_dset_lines_tab(l_max_i).attribute10,
          X_ATTRIBUTE11         => l_dset_lines_tab(l_max_i).attribute11,
          X_ATTRIBUTE12         => l_dset_lines_tab(l_max_i).attribute12,
          X_ATTRIBUTE13         => l_dset_lines_tab(l_max_i).attribute13,
          X_ATTRIBUTE14         => l_dset_lines_tab(l_max_i).attribute14,
          X_ATTRIBUTE15         => l_dset_lines_tab(l_max_i).attribute15,
          X_msg_application     => l_msg_application,
          X_msg_type            => l_msg_type,
          X_msg_token1          => l_msg_token1,
          X_msg_token2          => l_msg_token2,
          X_msg_token3          => l_msg_token3,
          X_msg_count           => l_msg_count,
          X_msg_data            => l_msg_data,
          X_BILLABLE_FLAG       => l_billable_flag,
          P_Document_Type       => p_invoice_rec.invoice_type_lookup_code,
          P_Document_Line_Type  => p_invoice_lines_rec.line_type_lookup_code);
          IF (l_msg_data IS NOT NULL) THEN
            -----------------------------------------------------------------
            debug_info := '(v_check_line_dist_set 5.1) - Project validate '
                            || 'PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION Fails'
                            || 'for rounding ->Insert Rejection';
            -----------------------------------------------------------------
            IF ( AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y' ) THEN
              AP_IMPORT_UTILITIES_PKG.Print(
                    AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;

            IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                      AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                      p_invoice_lines_rec.invoice_line_id,
                      'PA FLEXBUILD FAILED',
                      p_default_last_updated_by,
                      p_default_last_update_login,
                      current_calling_sequence) <> TRUE) THEN
              RAISE dist_set_check_failure;
            END IF;

            l_current_invoice_status := 'N';

          END IF; -- end of check l_msg_data is not null
        END IF; -- end of check l_project_id is not null

      END IF;  -- rounding existed

      l_dset_lines_tab.DELETE;

    END IF; -- end of l_dist_set_id is not null


    IF  (l_current_invoice_status <> 'N') THEN
      IF (l_dist_set_id is not NULL) THEN
        p_invoice_lines_rec.distribution_set_id := l_dist_set_id;
      END IF;
    END IF;

    p_current_invoice_status := l_current_invoice_status;
    RETURN (TRUE);

  EXCEPTION
    WHEN OTHERS THEN
      -- Clean up
      IF ( Dist_Set_Lines%ISOPEN ) THEN
        CLOSE Dist_Set_Lines;
      END IF;
      l_dset_lines_tab.DELETE;

      debug_info := '(v_check_line_dist_set ) -> ' ||
      'exception occurs ->' ;
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
            debug_info);
      END IF;

      IF (SQLCODE < 0) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
                SQLERRM);
        END IF;
      END IF;
      RETURN(FALSE);
END v_check_line_dist_set;

------------------------------------------------------------------------------
-- This function is used to validate qty/UOM information for non PO/RCV
-- matched lines
--
------------------------------------------------------------------------------
FUNCTION v_check_qty_uom_non_po (
         p_invoice_rec  IN  AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
         p_invoice_lines_rec IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
         p_default_last_updated_by      IN            NUMBER,
         p_default_last_update_login    IN            NUMBER,
         p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
         p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN

IS

qty_uom_check_failure            EXCEPTION;
l_uom_is_valid                       VARCHAR2(30);
l_current_invoice_status         VARCHAR2(1) := 'Y';
current_calling_sequence          VARCHAR2(2000);
debug_info                       VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_qty_uom_non_po <-'||P_calling_sequence;

  IF (p_invoice_lines_rec.po_header_id is NOT NULL OR
      p_invoice_lines_rec.rcv_transaction_id is NOT NULL) THEN
    --------------------------------------------------------------------------
    -- Step 1
    -- Nothing to do since this is PO/RCV matched
    --------------------------------------------------------------------------
    debug_info := '(Check Qty UOM non PO 1) Nothing to do.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    p_current_invoice_status := l_current_invoice_status;
    RETURN (TRUE);

  ELSE
    -------------------------------------------------------------------------
    -- Step 2
    -- Check that if quantity related information was provided the line type
    -- is Item
    -------------------------------------------------------------------------
    debug_info :=
      '(Check Qty UOM non PO 2) Check Qty related information vs line type.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (p_invoice_lines_rec.line_type_lookup_code NOT IN ( 'ITEM', 'RETROITEM') AND
        (p_invoice_lines_rec.quantity_invoiced IS NOT NULL OR
         p_invoice_lines_rec.unit_of_meas_lookup_code IS NOT NULL OR
         p_invoice_lines_rec.unit_price IS NOT NULL)) THEN
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
         AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
          p_invoice_lines_rec.invoice_line_id,
         'INVALID QTY INFO',
          p_default_last_updated_by,
          p_default_last_update_login,
          current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE qty_uom_check_failure;
      END IF;

      l_current_invoice_status := 'N';

    END IF;
    /* Bug 5763126 Checking in step 3 is not required
     --The validation is already done in step 2
    --------------------------------------------------------------------------
    -- Step 3
    -- Check that if quantity related information  was provided so was the UOM.
    --  Only do this check for Item lines.
    -------------------------------------------------------------------------
    debug_info := '(Check Qty UOM non PO 3) Check Qty information vs UOM';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (p_invoice_lines_rec.line_type_lookup_code  IN ('ITEM', 'RETROITEM') AND
        (p_invoice_lines_rec.quantity_invoiced IS NOT NULL OR
         p_invoice_lines_rec.unit_price IS NOT NULL) AND
        p_invoice_lines_rec.unit_of_meas_lookup_code is NULL) THEN

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
           AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
           p_invoice_lines_rec.invoice_line_id,
          'INCOMPLETE QTY INFO',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE qty_uom_check_failure;
      END IF;

      l_current_invoice_status := 'N';

    END IF;
       */   -- Bug 5763126 End
    -------------------------------------------------------------------------
    -- Step 4
    -- Check that if UOM is provided, then either quantity invoiced is
    -- provided or can be derived from amount and unit price.  Only do this
    -- check for Item lines. Also derive unit price if possible and verify
    -- consistency of unit price, qty and amount for the line.
    -------------------------------------------------------------------------
    debug_info := '(Check Qty UOM non PO 4) Check Qty information when UOM '
                  ||'populated';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                   debug_info);
    END IF;

    IF (p_invoice_lines_rec.line_type_lookup_code IN  ('ITEM', 'RETROITEM') AND
        p_invoice_lines_rec.unit_of_meas_lookup_code IS NOT NULL) THEN
      -----------------------------------------------------------------------
      -- Step 4a
      -- If quantity invoiced is null and unit price and line amount are not,
      -- derive the quantity invoiced.
      -----------------------------------------------------------------------
      IF (p_invoice_lines_rec.quantity_invoiced is NULL) THEN
        debug_info := '(Check Qty UOM non PO 4a) Qty invoiced is null.  Try '
                       ||'to derive it';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF (p_invoice_lines_rec.amount IS NOT NULL AND
            p_invoice_lines_rec.unit_price IS NOT NULL) THEN
         IF (p_invoice_lines_rec.unit_price = 0) THEN
            p_invoice_lines_rec.quantity_invoiced :=
              p_invoice_lines_rec.amount;
          ELSE
            p_invoice_lines_rec.quantity_invoiced :=
              p_invoice_lines_rec.amount / p_invoice_lines_rec.unit_price;
          END IF;

        ELSE -- We dont have enough data to get quantity invoiced
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
             'INCOMPLETE QTY INFO',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE qty_uom_check_failure;
          END IF;
          l_current_invoice_status := 'N';
        END IF; -- amount and unit price are not null
      END IF; -- quantity invoiced is null

      -----------------------------------------------------------------------
      -- Step 4b
      -- If quantity invoiced provided, verify that it is non 0
      --
      -----------------------------------------------------------------------
      IF (p_invoice_lines_rec.quantity_invoiced is NOT NULL AND
          p_invoice_lines_rec.quantity_invoiced = 0) THEN
        debug_info := '(Check Qty UOM non PO 4b) Verify qty invoice is non 0';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        END IF;

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
            'INVALID QTY INFO',
             p_default_last_updated_by,
             p_default_last_update_login,
             current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
                 AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE qty_uom_check_failure;
        END IF;
      END IF;

      ------------------------------------------------------------------------
      -- Step 4c
      -- If quantity invoiced and line amount are not null but unit price is
      -- null, derive unit price.
      ------------------------------------------------------------------------
      IF (p_invoice_lines_rec.quantity_invoiced is NOT NULL AND
          p_invoice_lines_rec.amount is NOT NULL AND
          p_invoice_lines_rec.unit_price is NULL) THEN
        debug_info :=
          '(Check Qty UOM non PO 4c) Unit price is null.  Try to derive it';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            debug_info);
        END IF;
        IF (p_invoice_lines_rec.quantity_invoiced <> 0) THEN
          p_invoice_lines_rec.unit_price := p_invoice_lines_rec.amount/
                                 p_invoice_lines_rec.quantity_invoiced;
        END IF;
      END IF;

      -----------------------------------------------------------------------
      -- Step 4d
      -- If quantity invoiced, unit_price and line amount are populated,
      -- verify consistency.
      ------------------------------------------------------------------------
      IF (p_invoice_lines_rec.quantity_invoiced is NOT NULL AND
          p_invoice_lines_rec.unit_price is NOT NULL AND
          p_invoice_lines_rec.amount is NOT NULL AND
          p_invoice_lines_rec.amount <> ap_utilities_pkg.ap_round_currency(
                 p_invoice_lines_rec.quantity_invoiced *
                 p_invoice_lines_rec.unit_price,
                 p_invoice_rec.invoice_currency_code)) THEN
        debug_info :=
          '(Check Qty UOM non PO 4d) Verify consistency in qty information';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                        debug_info);
        End if;
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                p_invoice_lines_rec.invoice_line_id,
               'INCONSISTENT QTY RELATED INFO',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE qty_uom_check_failure;
        END IF;
        l_current_invoice_status := 'N';
      END IF;

      ------------------------------------------------------------------------
      -- Step 4e
      -- Verify unit of measure provided is valid.
      --
      ------------------------------------------------------------------------
      debug_info :=
        '(Check Qty UOM non PO 4e) Verify unit of measure is valid';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      debug_info);
      END IF;
      BEGIN
        SELECT 'Valid UOM'
          INTO l_uom_is_valid
          FROM mtl_units_of_measure
         WHERE unit_of_measure = p_invoice_lines_rec.unit_of_meas_lookup_code
           AND AP_IMPORT_INVOICES_PKG.g_inv_sysdate
            < nvl(disable_date, AP_IMPORT_INVOICES_PKG.g_inv_sysdate + 1) ;
      EXCEPTION
        WHEN no_data_found THEN
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
              AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
              'INVALID UOM',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(
                AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<-'||current_calling_sequence);
            END IF;
            RAISE qty_uom_check_failure;
          END IF;
          l_current_invoice_status := 'N';
      END;

    END IF; -- line type is ITEM and unit of measure is not null
  END IF; -- po header id or rcv transaction id are not null

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_qty_uom_non_po;


-----------------------------------------------------------------------------
-- This function is used to validate line level awt group information.
-----------------------------------------------------------------------------
FUNCTION v_check_invalid_line_awt_group (
   p_invoice_rec          IN     AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec    IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_default_last_updated_by     IN            NUMBER,
   p_default_last_update_login   IN            NUMBER,
   p_current_invoice_status      IN OUT NOCOPY VARCHAR2,
   p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN
IS
   awt_group_check_failure       EXCEPTION;
   l_current_invoice_status      VARCHAR2(1) := 'Y';
   l_awt_group_id                NUMBER;
   l_awt_group_id_per_name       NUMBER;
   l_inactive_date               DATE;
   l_inactive_date_per_name      DATE;
   current_calling_sequence      VARCHAR2(2000);
   debug_info                    VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
      'AP_IMPORT_VALIDATION_PKG.v_check_invalid_line_awt_group<-'
      ||P_calling_sequence;

  IF p_invoice_lines_rec.awt_group_id is not null THEN
    --validate awt_group_id
    SELECT group_id, inactive_date
      INTO l_awt_group_id, l_inactive_date
      FROM ap_awt_groups
     WHERE group_id = p_invoice_lines_rec.awt_group_id;
  END IF;

  IF (p_invoice_lines_rec.awt_group_name is NOT NULL) THEN
    --validate awt group name and retrieve awt group id
    SELECT group_id, inactive_date
      INTO l_awt_group_id_per_name, l_inactive_date_per_name
      FROM ap_awt_groups
     WHERE name = p_invoice_lines_rec.awt_group_name;
  END IF;

  IF (l_awt_group_id is NOT NULL) AND
     (l_awt_group_id_per_name is NOT NULL) AND
     (l_awt_group_id <> l_awt_group_id_per_name) THEN

    --------------------------------------------------------------------------
    -- Step 1
    -- Check for AWT Group Id and Group Name Inconsistency.
    --------------------------------------------------------------------------
    debug_info := '(Check AWT Group 1) Check for AWT Group Id and Group Name '
                  ||'Inconsistency.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
         p_invoice_lines_rec.invoice_line_id,
        'INCONSISTENT AWT GROUP',
         p_default_last_updated_by,
         p_default_last_update_login,
         current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE awt_group_check_failure;
    END IF;
    l_current_invoice_status := 'N';
  ELSE
    --------------------------------------------------------------------------
    -- Step 2
    -- Check for Inactive AWT Group
    --------------------------------------------------------------------------
    debug_info := '(Check AWT Group 2) Check for Inactive AWT Group';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF ((l_awt_group_id IS NOT NULL AND
         l_awt_group_id_per_name IS NOT NULL) OR
        (l_awt_group_id IS NOT NULL AND
         l_awt_group_id_per_name IS NULL)) THEN
      IF AP_IMPORT_INVOICES_PKG.g_inv_sysdate >=
       NVL(l_inactive_date,
           AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1) THEN
    --------------------------------------------------------------
        -- inactive AWT group (as per id)
        --------------------------------------------------------------
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
             AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
             'INACTIVE AWT GROUP',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE awt_group_check_failure;
        END IF;
        l_current_invoice_status := 'N';
      END IF;
    ELSIF ((l_awt_group_id is NULL) AND
           (l_awt_group_id_per_name is NOT NULL)) THEN
      IF AP_IMPORT_INVOICES_PKG.g_inv_sysdate >=
            nvl(l_inactive_date_per_name,
                AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1) THEN
        ---------------------------------------------------------------
        -- inactive AWT group (per name)
        --
        ---------------------------------------------------------------
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
             AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
             'INACTIVE AWT GROUP',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE awt_group_check_failure;
        END IF;
        l_current_invoice_status := 'N';
      END IF;
    END IF;
  END IF; -- inconsistent awt group

  IF (l_current_invoice_status <> 'N' AND
      p_invoice_lines_rec.awt_group_id IS NULL) THEN
    IF (l_awt_group_id_per_name is not null) THEN
      p_invoice_lines_rec.awt_group_id := l_awt_group_id_per_name;
    ELSIF (p_invoice_rec.awt_group_id is not null) THEN
      p_invoice_lines_rec.awt_group_id := p_invoice_rec.awt_group_id;
    END IF;
  END IF;
  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);


EXCEPTION
  WHEN no_data_found THEN
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
       AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
        p_invoice_lines_rec.invoice_line_id,
       'INVALID AWT GROUP',
        p_default_last_updated_by,
        p_default_last_update_login,
        current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE awt_group_check_failure;
    END IF;
    l_current_invoice_status := 'N';
    p_current_invoice_status := l_current_invoice_status;
    RETURN (TRUE);

  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_invalid_line_awt_group;

    --bug6639866
----------------------------------------------------------------------------
-- This function is used to validate line level pay awt group information.
-----------------------------------------------------------------------------
FUNCTION v_check_invalid_line_pay_awt_g (
   p_invoice_rec          IN     AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec    IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_default_last_updated_by     IN            NUMBER,
   p_default_last_update_login   IN            NUMBER,
   p_current_invoice_status      IN OUT NOCOPY VARCHAR2,
   p_calling_sequence            IN            VARCHAR2) RETURN BOOLEAN
IS
   pay_awt_group_check_failure       EXCEPTION;
   l_current_invoice_status      VARCHAR2(1) := 'Y';
   l_pay_awt_group_id                NUMBER;
   l_pay_awt_group_id_per_name       NUMBER;
   l_inactive_date               DATE;
   l_inactive_date_per_name      DATE;
   current_calling_sequence      VARCHAR2(2000);
   debug_info                    VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
      'AP_IMPORT_VALIDATION_PKG.v_check_invalid_line_pay_awt_g<-'
      ||P_calling_sequence;

  IF p_invoice_lines_rec.pay_awt_group_id is not null THEN
    --validate pay_awt_group_id
    SELECT group_id, inactive_date
      INTO l_pay_awt_group_id, l_inactive_date
      FROM ap_awt_groups
     WHERE group_id = p_invoice_lines_rec.pay_awt_group_id;
  END IF;

  IF (p_invoice_lines_rec.pay_awt_group_name is NOT NULL) THEN
 --validate pay awt group name and retrieve pay awt group id
    SELECT group_id, inactive_date
      INTO l_pay_awt_group_id_per_name, l_inactive_date_per_name
      FROM ap_awt_groups
     WHERE name = p_invoice_lines_rec.pay_awt_group_name;
  END IF;

  IF (l_pay_awt_group_id is NOT NULL) AND
     (l_pay_awt_group_id_per_name is NOT NULL) AND
     (l_pay_awt_group_id <> l_pay_awt_group_id_per_name) THEN

    --------------------------------------------------------------------------
    -- Step 1
    -- Check for Pay AWT Group Id and Pay Group Name Inconsistency.
    --------------------------------------------------------------------------
    debug_info := '(Check Pay AWT Group 1) Check for Pay AWT Group Id and Pay Group Name '
                  ||'Inconsistency.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
         p_invoice_lines_rec.invoice_line_id,
        'INCONSISTENT PAY AWT GROUP',
         p_default_last_updated_by,
         p_default_last_update_login,
         current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE pay_awt_group_check_failure;
    END IF;
 l_current_invoice_status := 'N';
  ELSE
    --------------------------------------------------------------------------
    -- Step 2
    -- Check for Inactive Pay AWT Group
    --------------------------------------------------------------------------
    debug_info := '(Check Pay AWT Group 2) Check for Inactive Pay AWT Group';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF ((l_pay_awt_group_id IS NOT NULL AND
         l_pay_awt_group_id_per_name IS NOT NULL) OR
        (l_pay_awt_group_id IS NOT NULL AND
         l_pay_awt_group_id_per_name IS NULL)) THEN
      IF AP_IMPORT_INVOICES_PKG.g_inv_sysdate >=
       NVL(l_inactive_date,
           AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1) THEN
        --------------------------------------------------------------
        -- inactive pay AWT group (as per id)
        --------------------------------------------------------------
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
             AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
             'INACTIVE PAY AWT GROUP',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE pay_awt_group_check_failure;
        END IF;
        l_current_invoice_status := 'N';
      END IF;
    ELSIF ((l_pay_awt_group_id is NULL) AND
           (l_pay_awt_group_id_per_name is NOT NULL)) THEN
      IF AP_IMPORT_INVOICES_PKG.g_inv_sysdate >=
            nvl(l_inactive_date_per_name,
                AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1) THEN
        ---------------------------------------------------------------
        -- inactive pay AWT group (per name)
        --
        ---------------------------------------------------------------
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
             AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
              p_invoice_lines_rec.invoice_line_id,
             'INACTIVE PAY AWT GROUP',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
          END IF;
          RAISE pay_awt_group_check_failure;
        END IF;
        l_current_invoice_status := 'N';
      END IF;
    END IF;
  END IF; -- inconsistent pay awt group

  IF (l_current_invoice_status <> 'N' AND
      p_invoice_lines_rec.pay_awt_group_id IS NULL) THEN
    IF (l_pay_awt_group_id_per_name is not null) THEN
      p_invoice_lines_rec.pay_awt_group_id := l_pay_awt_group_id_per_name;
 ELSIF (p_invoice_rec.pay_awt_group_id is not null) THEN
      p_invoice_lines_rec.pay_awt_group_id := p_invoice_rec.pay_awt_group_id;
    END IF;
  END IF;
  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);


EXCEPTION
  WHEN no_data_found THEN
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
       AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
        p_invoice_lines_rec.invoice_line_id,
       'INVALID PAY AWT GROUP',
        p_default_last_updated_by,
        p_default_last_update_login,
        current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
      END IF;
      RAISE pay_awt_group_check_failure;
    END IF;
    l_current_invoice_status := 'N';
    p_current_invoice_status := l_current_invoice_status;
    RETURN (TRUE);

  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_invalid_line_pay_awt_g;


-----------------------------------------------------------------------------
-- This function is used to validate that there is no duplicate line number
-----------------------------------------------------------------------------
FUNCTION v_check_duplicate_line_num (
   p_invoice_rec     IN            AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec  IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_default_last_updated_by      IN            NUMBER,
   p_default_last_update_login    IN            NUMBER,
   p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
   p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN
IS

line_num_check_failure        EXCEPTION;
l_line_count                   NUMBER;
l_current_invoice_status    VARCHAR2(1) := 'Y';
current_calling_sequence    VARCHAR2(2000);
debug_info                  VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
      'AP_IMPORT_VALIDATION_PKG.v_check_duplicate_line_num<-'
     ||P_calling_sequence;

  IF (p_invoice_lines_rec.line_number is NOT NULL) THEN

    --------------------------------------------------------------------------
    -- Step 1
    -- Check for Duplicate Line NUMBER.
    --------------------------------------------------------------------------
    debug_info := '(Check Duplicate Line Number 1) Check for Duplicate '
                  ||'Line Number.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    SELECT count(*)
      INTO l_line_count
      FROM ap_invoice_lines_interface
     WHERE invoice_id = p_invoice_rec.invoice_id
       AND line_number = p_invoice_lines_rec.line_number;

    IF (l_line_count > 1) THEN
      debug_info := '(Check Duplicate Line Number 2) Duplicate Line '
                    ||'Number Found.';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      -- bug 2581097 added context for XML GATEWAY
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
        AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
           p_invoice_lines_rec.invoice_line_id,
           'DUPLICATE LINE NUMBER',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence,
           'Y',
           'INVOICE LINE NUMBER',
           p_invoice_lines_rec.line_number) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
        END IF;
        RAISE line_num_check_failure;
      END IF;
      l_current_invoice_status := 'N';
    END IF;
  END IF;

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);
EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_duplicate_line_num;


-----------------------------------------------------------------------------
-- This function is used to validate that miscellaneous line level information
-----------------------------------------------------------------------------
FUNCTION v_check_misc_line_info (
   p_invoice_rec          		  IN
						AP_IMPORT_INVOICES_PKG.r_invoice_info_rec, --bug 7599916
   p_invoice_lines_rec   IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_default_last_updated_by      IN            NUMBER,
   p_default_last_update_login    IN            NUMBER,
   p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
   p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN

IS

misc_line_info_failure        EXCEPTION;
l_valid_info                VARCHAR2(1);
l_current_invoice_status    VARCHAR2(1) := 'Y';
current_calling_sequence    VARCHAR2(2000);
debug_info                  VARCHAR2(500);
-- Bug 5572876. Caching Income Tax Type and Income Tax Region
l_key                            VARCHAR2(1000);
l_numof_values                   NUMBER;
l_valueOut                   fnd_plsql_cache.generic_cache_value_type;
l_values                     fnd_plsql_cache.generic_cache_values_type;
l_ret_code                      VARCHAR2(1);
l_exception                     VARCHAR2(10);
l_key1                          VARCHAR2(1000);
l_numof_values1                 NUMBER;
l_valueOut1                  fnd_plsql_cache.generic_cache_value_type;
l_values1                    fnd_plsql_cache.generic_cache_values_type;
l_ret_code1                  VARCHAR2(1);
l_exception1                    VARCHAR2(10);
l_income_tax_type               ap_income_tax_types.income_tax_type%TYPE;
l_income_tax_region             ap_income_tax_regions.region_short_name%TYPE;

-- Bug 9189995
l_income_tax_region_flag        ap_system_parameters_all.income_tax_region_flag%TYPE;

        -- Bug 7599916
	Cursor c_type_1099(c_vendor_id NUMBER) Is
	Select pov.type_1099
	From   po_vendors 		   pov
	Where  pov.vendor_id    = c_vendor_id;
	-- Bug 7599916

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_misc_line_info<-'
    ||P_calling_sequence;

  --Retropricing
  IF (nvl(p_invoice_lines_rec.line_type_lookup_code,'DUMMY')
     NOT IN ('FREIGHT','ITEM','MISCELLANEOUS','TAX','AWT', 'RETROITEM', 'RETROTAX')) THEN

    --------------------------------------------------------------------------
    -- Step 1
    -- Check for Invalid Line type lookup code.
    --------------------------------------------------------------------------
    debug_info :=
       '(Check Misc Line Info 1) Check for Invalid Line type lookup code.';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
      AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
         p_invoice_lines_rec.invoice_line_id,
         'INVALID LINE TYPE LOOKUP',
         p_default_last_updated_by,
         p_default_last_update_login,
         current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-' ||current_calling_sequence);
      END IF;
      RAISE misc_line_info_failure;
    END IF;

    l_current_invoice_status := 'N';

  ELSIF (p_invoice_lines_rec.line_type_lookup_code ='AWT') THEN

    ----------------------------------------------------------------------
    -- Step 2
    -- Line type lookup code cannot be AWT
    ----------------------------------------------------------------------
    debug_info := '(Check Misc Line Info 2) Line type lookup code '
                  ||'cannot be AWT';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
      AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
       p_invoice_lines_rec.invoice_line_id,
       'LINE TYPE CANNOT BE AWT',
       p_default_last_updated_by,
       p_default_last_update_login,
       current_calling_sequence) <> TRUE) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-' ||current_calling_sequence);
      END IF;
      RAISE misc_line_info_failure;
    END IF;
    l_current_invoice_status := 'N';
  END IF; -- line type

    -- Bug 7599916
	IF (p_invoice_lines_rec.type_1099 is NULL) THEN
	--------------------------------------------------------------------------
    -- Step 3.1
    -- defaulting type_1099 from supplier if null in interface table
    --------------------------------------------------------------------------

	debug_info := '(Check Misc Line Info 3) Defaulting type 1099 from
	supplier';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

	Open  c_type_1099(p_invoice_rec.vendor_id);
	Fetch c_type_1099 Into p_invoice_lines_rec.type_1099;
	Close c_type_1099;

	END IF;
	-- Bug 7599916

   IF (p_invoice_lines_rec.type_1099 is NOT NULL) THEN
     -- Bug 9727834.
     -- Added 'NA' validation for type_1099.
     -- Setting type_1099 to null if 'NA'.

     IF (p_invoice_lines_rec.type_1099 = 'NA') THEN
        debug_info := '(Check Misc Line Info 3) Check Type 1099. ' ||
                       'Type 1099 is NA. Setting type 1099 to null.';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
        END IF;

        p_invoice_lines_rec.type_1099 := null ;
     ELSE

    --------------------------------------------------------------------------
    -- Step 3.2
    -- Invalid type_1099
    --------------------------------------------------------------------------
    debug_info := '(Check Misc Line Info 3) Check Type 1099';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    -- Invalid Info

    l_key := p_invoice_lines_rec.type_1099;

    fnd_plsql_cache.generic_1tom_get_values(
              AP_IMPORT_INVOICES_PKG.lg_incometax_controller,
              AP_IMPORT_INVOICES_PKG.lg_incometax_storage,
              l_key,
              l_numof_values,
              l_values,
              l_ret_code);

    IF l_ret_code = '1' THEN --  means l_key found in cache
      l_income_tax_type := l_values(1).varchar2_1;
      l_exception   := l_values(1).varchar2_2;
      IF l_exception = 'TRUE' THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
           p_invoice_lines_rec.invoice_line_id,
          'INVALID TYPE 1099',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-' ||current_calling_sequence);
          END IF;
           RAISE misc_line_info_failure;
        END IF;

        l_current_invoice_status := 'N';
      END IF;

    ELSE -- IF l_key not found in cache(l_ret_code other than 1) .. cache it
      debug_info := '(Check Misc Line Info 3.1) Check Type 1099 in Else';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

       BEGIN
        SELECT income_tax_type
        INTO l_income_tax_type
        FROM ap_income_tax_types
        WHERE income_tax_type = p_invoice_lines_rec.type_1099
         AND AP_IMPORT_INVOICES_PKG.g_inv_sysdate
           < NVL(inactive_date, AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1) ;

        l_exception           := 'FALSE';
        l_valueOut.varchar2_1 := l_income_tax_type;
        l_valueOut.varchar2_2 := l_exception;
        l_values(1)           := l_valueOut;
        l_numof_values        := 1;

        fnd_plsql_cache.generic_1tom_put_values(
                  AP_IMPORT_INVOICES_PKG.lg_incometax_controller,
                  AP_IMPORT_INVOICES_PKG.lg_incometax_storage,
                  l_key,
                  l_numof_values,
                  l_values);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch,
              '(v_check_misc_line_info 3) Invalid Type 1099');
          END IF;

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
            p_invoice_lines_rec.invoice_line_id,
           'INVALID TYPE 1099',
            p_default_last_updated_by,
            p_default_last_update_login,
            current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-' ||current_calling_sequence);
            END IF;
            RAISE misc_line_info_failure;
          END IF;
          --
          l_current_invoice_status := 'N';
          l_exception              := 'TRUE';
          l_valueOut.varchar2_1    := NULL;
          l_valueOut.varchar2_2    := l_exception;
          l_values(1)              := l_valueOut;
          l_numof_values           := 1;

            fnd_plsql_cache.generic_1tom_put_values(
                    AP_IMPORT_INVOICES_PKG.lg_incometax_controller,
                    AP_IMPORT_INVOICES_PKG.lg_incometax_storage,
                    l_key,
                    l_numof_values,
                    l_values);

      END;

    END IF;
   END IF; -- type 1099 is NOT 'NA'.
  END IF; -- type 1099 is not null

  -- Bug 9189995 - Defaulting logic for Income Tax Region Added
  IF ((p_invoice_lines_rec.income_tax_region is NULL) AND
      (p_invoice_lines_rec.type_1099 is NOT NULL)         ) THEN

    --------------------------------------------------------------------------
    -- Step 4.1
    -- Default income_tax_region if null in interface table
    -- we default only if type_1099 is not null
    --------------------------------------------------------------------------
      begin
        select asp.income_tax_region,
               NVL(asp.income_tax_region_flag, 'N')
        into   l_income_tax_region,
               l_income_tax_region_flag
        from   ap_system_parameters asp
        where  asp.org_id = p_invoice_rec.org_id;

       if (l_income_tax_region_flag = 'Y') then
         select pvs.state
         into   l_income_tax_region
         from   po_vendor_sites pvs
         where  pvs.vendor_id = p_invoice_rec.vendor_id
         and    pvs.vendor_site_id = p_invoice_rec.vendor_site_id;
       end if;
       p_invoice_lines_rec.income_tax_region := l_income_tax_region;
      exception
         when others then
            debug_info := '(step 4.1 default the income_tax_region';
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            debug_info);
            END IF;
      end;

  END IF; --p_invoice_lines_rec.income_tax_region is NULL

  IF (p_invoice_lines_rec.income_tax_region is NOT NULL) THEN

    --------------------------------------------------------------------------
    -- Step 4.2
    -- Invalid income_tax_region
    --------------------------------------------------------------------------
    debug_info := '(Check Misc Line Info 4) Check income_tax_region';
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    -- Invalid Info
    l_key1 := p_invoice_lines_rec.income_tax_region;

    fnd_plsql_cache.generic_1tom_get_values(
              AP_IMPORT_INVOICES_PKG.lg_incometaxr_controller,
              AP_IMPORT_INVOICES_PKG.lg_incometaxr_storage,
              l_key1,
              l_numof_values1,
              l_values1,
              l_ret_code1);

    IF l_ret_code1 = '1' THEN --  means l_key found in cache
      l_income_tax_region := l_values1(1).varchar2_1;
      l_exception1   := l_values1(1).varchar2_2;
      IF l_exception1 = 'TRUE' THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
           p_invoice_lines_rec.invoice_line_id,
          'INVALID TAX REGION',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-' ||current_calling_sequence);
          END IF;
          RAISE misc_line_info_failure;
        END IF;

        l_current_invoice_status := 'N';
      END IF;

    ELSE
      debug_info := '(Check Misc Line Info 4.1) Check income_tax_region in Else';
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      BEGIN
        SELECT region_short_name
        INTO l_income_tax_region
        FROM ap_income_tax_regions
        WHERE region_short_name = p_invoice_lines_rec.income_tax_region
         AND AP_IMPORT_INVOICES_PKG.g_inv_sysdate
        BETWEEN NVL(active_date, AP_IMPORT_INVOICES_PKG.g_inv_sysdate) AND
        NVL(inactive_date, AP_IMPORT_INVOICES_PKG.g_inv_sysdate);

        l_exception1           := 'FALSE';
        l_valueOut1.varchar2_1 := l_income_tax_region;
        l_valueOut1.varchar2_2 := l_exception1;
        l_values1(1)           := l_valueOut1;
        l_numof_values1        := 1;

        fnd_plsql_cache.generic_1tom_put_values(
                  AP_IMPORT_INVOICES_PKG.lg_incometaxr_controller,
                  AP_IMPORT_INVOICES_PKG.lg_incometaxr_storage,
                  l_key1,
                  l_numof_values1,
                  l_values1);

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            '(v_check_misc_line_info 4) Invalid income tax region');
          END IF;
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
            AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
             p_invoice_lines_rec.invoice_line_id,
            'INVALID TAX REGION',
             p_default_last_updated_by,
             p_default_last_update_login,
             current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
              AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-' ||current_calling_sequence);
            END IF;
            RAISE misc_line_info_failure;
          END IF;
          l_current_invoice_status := 'N';
          l_exception1             := 'TRUE';
          l_valueOut1.varchar2_1   := NULL;
          l_valueOut1.varchar2_2   := l_exception1;
          l_values1(1)             := l_valueOut1;
          l_numof_values1          := 1;

          fnd_plsql_cache.generic_1tom_put_values(
                    AP_IMPORT_INVOICES_PKG.lg_incometaxr_controller,
                    AP_IMPORT_INVOICES_PKG.lg_incometaxr_storage,
                    l_key1,
                    l_numof_values1,
                    l_values1);

      END;

    END IF;

  END IF;

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_misc_line_info;

---------------------------------------------------------------------------------
-- This function verifies proration of non item lines
--
FUNCTION v_check_prorate_info (
   p_invoice_rec                  IN
     AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
   p_invoice_lines_rec   IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
   p_default_last_updated_by      IN            NUMBER,
   p_default_last_update_login    IN            NUMBER,
   p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
   p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN

IS

prorate_line_info_failure       EXCEPTION;
l_item_line_total               NUMBER;
l_count_non_item_lines          NUMBER := 0;
l_count_item_lines		NUMBER := 0; -- Bug 9700233
l_current_invoice_status    VARCHAR2(1) := 'Y';
current_calling_sequence      VARCHAR2(2000);
debug_info                   VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
    'AP_IMPORT_VALIDATION_PKG.v_check_prorate_info<-' ||P_calling_sequence;

  ---------------------------------------------------------------------------
  -- Step 1
  -- Sum of lines to prorate against cannot be 0
  ---------------------------------------------------------------------------
  debug_info := '(Check Prorate Info 1) Checking the total dist amount to be '
               ||'prorated';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
   AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                 debug_info);
  END IF;

  SELECT   SUM(nvl(AIL.amount,0))
    INTO   l_item_line_total
    FROM   ap_invoice_lines_interface AIL
   WHERE   AIL.invoice_id = p_invoice_rec.invoice_id
     AND   ((line_group_number = p_invoice_lines_rec.line_group_number AND
             p_invoice_lines_rec.line_group_number IS NOT NULL)         OR
            p_invoice_lines_rec.line_group_number is NULL)
     AND    line_type_lookup_code = 'ITEM';

  IF (l_item_line_total = 0 ) THEN
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
        AP_IMPORT_INVOICES_PKG.g_invoices_table,
     p_invoice_lines_rec.invoice_line_id,
        'CANNOT PRORATE TO ZERO',
     p_default_last_updated_by,
     p_default_last_update_login,
     current_calling_sequence) <> TRUE ) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           'insert_rejections<- '||current_calling_sequence);
      END IF;
      RAISE prorate_line_info_failure;
    END IF;
    l_current_invoice_status := 'N';
  END IF; -- Total of amount for item lines to prorate across is 0

  ---------------------------------------------------------------------------
  -- Step 2
  -- Prorating across non-item lines is not allowed
  ---------------------------------------------------------------------------
  debug_info := '(Check Prorate Info 2) Checking lines to prorate across.';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
   AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                 debug_info);
  END IF;

  IF (p_invoice_lines_rec.line_group_number IS NOT NULL) THEN

	-- Added for bug 9700233
	-- There should be atleast one ITEM line for the line group number
	-- which belongs to other than ITEM line
	-- For TAX line, prorate_across_flag should be Y

	SELECT COUNT(*)
	INTO   l_count_item_lines
	FROM   ap_invoice_lines_interface AIL
	WHERE   AIL.invoice_id = p_invoice_rec.invoice_id
	AND   line_group_number = p_invoice_lines_rec.line_group_number
	AND   (line_type_lookup_code = 'ITEM'
	       OR (line_type_lookup_code = 'TAX' AND prorate_across_flag = 'Y'));

	IF (l_count_item_lines = 0) THEN
	      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
	          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
			p_invoice_lines_rec.invoice_line_id,
			'CANNOT PRORATE TO NON ITEM',
			p_default_last_updated_by,
			p_default_last_update_login,
			current_calling_sequence) <> TRUE ) THEN
		IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
	          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
		     'insert_rejections<- '||current_calling_sequence);
	        END IF;
		l_current_invoice_status := 'N';
		RAISE prorate_line_info_failure;
	      END IF;
	      l_current_invoice_status := 'N';
	 END IF; -- count of item line equal to 0

/* Commented for bug 9700233
    SELECT   COUNT(*)
      INTO   l_count_non_item_lines
      FROM   ap_invoice_lines_interface AIL
     WHERE   AIL.invoice_id = p_invoice_rec.invoice_id
       AND   line_group_number = p_invoice_lines_rec.line_group_number
       AND   line_type_lookup_code <> 'ITEM';

    -- If number of lines other than Item is more than 1 (1 is itself)
    -- raise rejection
    IF (l_count_non_item_lines > 1) THEN
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoices_table,
       p_invoice_lines_rec.invoice_line_id,
          'CANNOT PRORATE TO NON ITEM',
       p_default_last_updated_by,
       p_default_last_update_login,
           current_calling_sequence) <> TRUE ) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections<- '||current_calling_sequence);
        END IF;
        RAISE prorate_line_info_failure;
      END IF;
    END IF; -- count of non item lines is > 1
*/

  END IF; -- line group number is not null

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_prorate_info;

-----------------------------------------------------------------------------
-- This function verifies and populates asset information
--
FUNCTION v_check_asset_info (
         p_invoice_lines_rec
           IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
         p_set_of_books_id              IN            NUMBER,
         p_asset_book_type              IN            VARCHAR2, -- 5448579
         p_default_last_updated_by      IN            NUMBER,
         p_default_last_update_login    IN            NUMBER,
         p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
         p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN
IS

asset_line_info_failure         EXCEPTION;
l_valid_asset_book             VARCHAR2(30);
l_asset_book_count             NUMBER;
l_valid_asset_category         VARCHAR2(30);
l_current_invoice_status        VARCHAR2(1) := 'Y';
current_calling_sequence       VARCHAR2(2000);
debug_info                    VARCHAR2(500);

BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence := 'AP_IMPORT_UTILITIES_PKG.v_check_asset_ifno<-'
                              ||P_calling_sequence;

  -------------------------------------------------------------------------------
  -- Step 1 - If line type is other than item and any of the asset fields is
  -- populated, reject appropriately.
  --
  ----------------------------------------------------------------------------
  debug_info := '(Check Asset Book 1) Verify asset info not on non-item line';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  --Retropricing
  IF (p_invoice_lines_rec.line_type_lookup_code NOT IN ('ITEM', 'RETROITEM')) THEN
    IF (p_invoice_lines_rec.serial_number IS NOT NULL) THEN
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
           p_invoice_lines_rec.invoice_line_id,
           'INVALID SERIAL NUMBER INFO',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE ) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections<- '||current_calling_sequence);
        END IF;
        RAISE asset_line_info_failure;
      END IF;
      l_current_invoice_status := 'N';
    END IF; -- Serial number is not null

    IF (p_invoice_lines_rec.manufacturer IS NOT NULL) THEN
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
           p_invoice_lines_rec.invoice_line_id,
           'INVALID MANUFACTURER INFO',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE ) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<- '||current_calling_sequence);
        END IF;
        RAISE asset_line_info_failure;
      END IF;
      l_current_invoice_status := 'N';
    END IF; -- Manufacturer is not null

    IF (p_invoice_lines_rec.model_number IS NOT NULL) THEN
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
           p_invoice_lines_rec.invoice_line_id,
           'INVALID MODEL NUMBER INFO',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE ) Then
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           'insert_rejections<- '||current_calling_sequence);
        END IF;
        RAISE asset_line_info_failure;
      END IF;
      l_current_invoice_status := 'N';
    END IF; -- Model Number is not null

    IF (p_invoice_lines_rec.warranty_number is not null) then
     IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
           p_invoice_lines_rec.invoice_line_id,
           'INVALID WARRANTY NUM INFO',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE ) Then
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
         AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
           'insert_rejections<- '||current_calling_sequence);
        END IF;
        RAISE asset_line_info_failure;
      END IF;
      l_current_invoice_status := 'N';
    END IF; -- Warranty Number is not null

  END IF; -- Line type is other than ITEM, RETROITEM

  ----------------------------------------------------------------------------
 -- Step 2 - If asset book type code is populated verify that it is correct.
 -- If it is not populated, populate based on set of books if a single asset
 -- book is found.
 --
  ----------------------------------------------------------------------------
  debug_info := '(Check Asset Book 2) Verify asset book if not null';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  IF (p_invoice_lines_rec.asset_book_type_code IS NOT NULL) THEN
    debug_info := 'Verify Asset Book since it is not null';
    BEGIN
      SELECT 'Asset Book Found'
        INTO l_valid_asset_book
        FROM fa_book_controls bc
       WHERE bc.set_of_books_id = p_set_of_books_id
         AND bc.book_type_code = p_invoice_lines_rec.asset_book_type_code
         AND bc.date_ineffective IS NULL;

    EXCEPTION
      WHEN no_data_found then
       IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
           p_invoice_lines_rec.invoice_line_id,
           'INVALID ASSET BOOK CODE',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE ) Then
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
              AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<- '||current_calling_sequence);
          END IF;
          RAISE asset_line_info_failure;
       END IF;
       l_current_invoice_status := 'N';
      WHEN OTHERS THEN
        RAISE asset_line_info_failure;
    END;

  ELSE -- Asset book is null
    debug_info := 'Get asset book if null and a single one exists for sob';
    -- Bug 5448579
    p_invoice_lines_rec.asset_book_type_code  := p_asset_book_type;

  END IF; -- Asset book type code is not null

  ----------------------------------------------------------------------------
  -- Step 3 - If asset category is populated, verify that it is appropriate
  --
  ----------------------------------------------------------------------------
  debug_info := '(Check Asset Book 3) Verify asset category if not null';
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  End if;

  If (p_invoice_lines_rec.asset_category_id is not null) then
    debug_info := 'Verify Asset Category since it is not null';
    BEGIN
      SELECT 'Asset Category found'
        INTO l_valid_asset_category
        FROM fa_categories
       WHERE category_id = p_invoice_lines_rec.asset_category_id;

    EXCEPTION
      WHEN no_data_found then
       If (AP_IMPORT_UTILITIES_PKG.insert_rejections(
           AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
           p_invoice_lines_rec.invoice_line_id,
           'INVALID ASSET CATEGORY ID',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE ) Then
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
           AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
             'insert_rejections<- '||current_calling_sequence);
          END IF;
          RAISE asset_line_info_failure;
       END IF;
       l_current_invoice_status := 'N';
      WHEN OTHERS THEN
        RAISE asset_line_info_failure;
    END;

  END IF; -- Asset category is not null

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);
EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_asset_info;

/*=============================================================================
 |  FUNCTION - V_Check_Tax_Info()
 |
 |  DESCRIPTION
 |      This function will validate the following fields included in the
 |      ap_invoices_interface table as part of the eTax Uptake project:
 |        control_amount
 |        tax_related_invoice_id
 |        calc_tax_during_import_flag
 |
 |      The other tax fields will be validated by the eTax API.  See DLD for
 |      details.
 |
 |  PARAMETERS
 |    p_invoice_rec - record for invoice header
 |    p_default_last_updated_by - default last updated by
 |    p_default_last_update_login - default last update login
 |    p_current_invoice_status - return the status of the invoice after the
 |                               validation
 |    P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    20-JAN-2004   SYIDNER        Created
 |
 *============================================================================*/

FUNCTION v_check_tax_info(
     p_invoice_rec               IN AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
     p_default_last_updated_by   IN            NUMBER,
     p_default_last_update_login IN            NUMBER,
     p_current_invoice_status    IN OUT NOCOPY VARCHAR2,
     p_calling_sequence          IN            VARCHAR2) RETURN BOOLEAN
IS

  l_current_invoice_status        VARCHAR2(1);
  l_reject_code                   VARCHAR2(30);
  current_calling_sequence        VARCHAR2(2000);

  debug_info                      VARCHAR2(500);
  check_tax_failure               EXCEPTION;

  l_related_inv_id                ap_invoices_all.invoice_id%TYPE;
  l_exist_tax_line                ap_invoices_all.invoice_id%TYPE;
  l_alloc_not_provided            VARCHAR2(1);
  l_tax_lines_cannot_coexist      VARCHAR2(1);
  l_tax_found_in_nontax_line      VARCHAR2(1);

BEGIN

  current_calling_sequence :=  'AP_IMPORT_VALIDATION_PKG.v_check_tax_info<-'
                                ||P_calling_sequence;

  -------------------------------------------------------------------------
  debug_info := '(Check tax info 1) Check for control_amount';
  -------------------------------------------------------------------------
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
  END IF;

  --bug 9326733
  l_current_invoice_status := p_current_invoice_status;

  --Contract Payments: Modified the IF condition to add 'PREPAYMENT'.

  IF ( (p_invoice_rec.invoice_type_lookup_code IN ('STANDARD','PREPAYMENT') and
        NVL(p_invoice_rec.control_amount, 0) > NVL(p_invoice_rec.invoice_amount, 0)) OR
       (p_invoice_rec.invoice_type_lookup_code IN ('CREDIT', 'DEBIT') and -- bug 7299826
        NVL(abs(p_invoice_rec.control_amount), NVL(abs(p_invoice_rec.invoice_amount),0)) > NVL(abs(p_invoice_rec.invoice_amount),0))  --Bug 6925674 (Base bug6905106)
     ) THEN

    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
      (AP_IMPORT_INVOICES_PKG.g_invoices_table,
       p_invoice_rec.invoice_id,
       'INVALID CONTROL AMOUNT',
       p_default_last_updated_by,
       p_default_last_update_login,
       current_calling_sequence) <> TRUE) THEN

       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
          'insert_rejections<-'||current_calling_sequence);
       END IF;
       RAISE check_tax_failure;

    END IF;
    l_current_invoice_status := 'N';
  END IF;

  -------------------------------------------------------------------------
  debug_info := '(Check tax info 2) Check for tax_related_invoice_id';
  -------------------------------------------------------------------------
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
  END IF;

  IF ( p_invoice_rec.tax_related_invoice_id IS NOT NULL) THEN

    BEGIN
      SELECT invoice_id
        INTO l_related_inv_id
        FROM ap_invoices_all
       WHERE invoice_id = p_invoice_rec.tax_related_invoice_id
         AND vendor_id = p_invoice_rec.vendor_id
         AND vendor_site_id = p_invoice_rec.vendor_site_id
         AND cancelled_date IS NULL
         AND cancelled_by IS NULL;

    EXCEPTION
      WHEN no_data_found THEN

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
          (AP_IMPORT_INVOICES_PKG.g_invoices_table,
           p_invoice_rec.invoice_id,
           'INVALID TAX RELATED INVOICE ID',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE) THEN

           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
           END IF;
           RAISE check_tax_failure;

        END IF;
        l_current_invoice_status := 'N';
    END;
  END IF;  -- Validate only if tax_related_invoice_id is populated

  -------------------------------------------------------------------------
  debug_info := '(Check tax info 3) Check for calc_tax_during_import_flag';
  -------------------------------------------------------------------------
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
  END IF;

  IF ( p_invoice_rec.calc_tax_during_import_flag = 'Y') THEN

    BEGIN
      SELECT invoice_id
        INTO l_exist_tax_line
        FROM ap_invoice_lines_interface
       WHERE invoice_id = p_invoice_rec.invoice_id
         AND line_type_lookup_code = 'TAX'
         AND ROWNUM =1;

    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;

    IF (l_exist_tax_line IS NOT NULL) THEN

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
        (AP_IMPORT_INVOICES_PKG.g_invoices_table,
         p_invoice_rec.invoice_id,
         'CANNOT CONTAIN TAX LINES',
         p_default_last_updated_by,
         p_default_last_update_login,
         current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
         END IF;
         RAISE check_tax_failure;
       END IF;
      l_current_invoice_status := 'N';

    END IF;
  END IF;  -- Validate calc_tax_during_import_flag

  -------------------------------------------------------------------------
  debug_info := '(Check tax info 4) Validate if allocation structure is '||
                'provided for inclusive lines when the invoice has more than '||
                'one item line.';
  -------------------------------------------------------------------------
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
  END IF;

  BEGIN
    SELECT 'Y'
      INTO l_alloc_not_provided
      FROM ap_invoices_interface aii
     WHERE aii.invoice_id = p_invoice_rec.invoice_id
       AND 1 < (SELECT COUNT(*)
                  FROM ap_invoice_lines_interface aili
                 WHERE aili.line_type_lookup_code <> 'TAX'
                   AND aili.invoice_id = aii.invoice_id)
       AND EXISTS (SELECT 'Y'
                    FROM ap_invoice_lines_interface ail2
                   WHERE ail2.invoice_id = aii.invoice_id
                     AND ail2.line_type_lookup_code = 'TAX'
                     AND ail2.line_group_number IS NULL
                     AND NVL(ail2.incl_in_taxable_line_flag, 'N') = 'Y');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_alloc_not_provided := 'N';

  END;

  IF (l_alloc_not_provided = 'Y') THEN
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
       (AP_IMPORT_INVOICES_PKG.g_invoices_table,
       p_invoice_rec.invoice_id,
       'NO ALLOCATION RULES FOUND',
       p_default_last_updated_by,
       p_default_last_update_login,
       current_calling_sequence) <> TRUE) THEN
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
       END IF;
       RAISE check_tax_failure;
    END IF;

    l_current_invoice_status := 'N';
  END IF; -- end of validation if inclusive and alloc structure is not provided

  -------------------------------------------------------------------------
  debug_info := '(Check tax info 5) Check if any non-tax line has tax information';
  -------------------------------------------------------------------------
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  BEGIN
    SELECT 'Y'
      INTO l_tax_found_in_nontax_line
      FROM ap_invoices_interface aii
     WHERE aii.invoice_id = p_invoice_rec.invoice_id
       AND EXISTS (SELECT 'Y'
                     FROM ap_invoice_lines_interface ail2
                    WHERE ail2.invoice_id = aii.invoice_id
                      AND ail2.line_type_lookup_code <> 'TAX'
                      AND (ail2.tax_regime_code IS NOT NULL OR
                           ail2.tax IS NOT NULL OR
                           ail2.tax_jurisdiction_code IS NOT NULL OR
                           ail2.tax_status_code IS NOT NULL OR
                           ail2.tax_rate_id IS NOT NULL OR
                           ail2.tax_rate_code IS NOT NULL OR
                           ail2.tax_rate IS NOT NULL OR
                           ail2.incl_in_taxable_line_flag IS NOT NULL));
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_tax_found_in_nontax_line := 'N';

  END;

  IF (l_tax_found_in_nontax_line = 'Y') THEN
    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
       (AP_IMPORT_INVOICES_PKG.g_invoices_table,
       p_invoice_rec.invoice_id,
       'TAX DATA FOUND ON NONTAX LINES',
       p_default_last_updated_by,
       p_default_last_update_login,
       current_calling_sequence) <> TRUE) THEN
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-'||current_calling_sequence);
       END IF;
       RAISE check_tax_failure;
    END IF;

    l_current_invoice_status := 'N';
  END IF; -- end of validation if nont-tax lines have tax information

  -------------------------------------------------------------------------
  debug_info := '(Check tax info 6) Check if an invoice has a tax line '||
                'matched to receipt and another allocated to item lines';
  -------------------------------------------------------------------------
  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                  debug_info);
  END IF;

  -- Validation:  A tax-only invoice should not have a tax line matched to receipt and
  -- a tax line allocated to an item line
  -- This validation is only for tax-only invoices since if the invoice has a
  -- tax line matched to receipt in an invoice with item lines the rcv info is
  -- not taken into consideration.
  IF (NVL(p_invoice_rec.tax_only_flag, 'N') = 'Y') THEN
    BEGIN
      SELECT 'Y'
        INTO l_tax_lines_cannot_coexist
        FROM ap_invoices_interface aii
       WHERE aii.invoice_id = p_invoice_rec.invoice_id
         AND EXISTS (SELECT 'Y'
                       FROM ap_invoice_lines_interface ail2
                      WHERE ail2.invoice_id = aii.invoice_id
                        AND ail2.line_type_lookup_code = 'TAX'
                        AND ail2.rcv_transaction_id IS NOT NULL)
         AND EXISTS (SELECT 'Y'
                       FROM ap_invoice_lines_interface ail3
                      WHERE ail3.invoice_id = aii.invoice_id
                        AND ail3.line_type_lookup_code = 'TAX'
                        AND ail3.rcv_transaction_id IS NULL);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_tax_lines_cannot_coexist := 'N';

    END;

    IF (l_tax_lines_cannot_coexist = 'Y') THEN
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
         (AP_IMPORT_INVOICES_PKG.g_invoices_table,
         p_invoice_rec.invoice_id,
         'TAX LINE TYPES CANNOT COEXIST',
         p_default_last_updated_by,
         p_default_last_update_login,
         current_calling_sequence) <> TRUE) THEN
         IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-'||current_calling_sequence);
         END IF;
         RAISE check_tax_failure;
      END IF;

      l_current_invoice_status := 'N';
    END IF; -- end of validation for tax lines matched to receipts and allocated
            -- to item lines
  END IF;  -- Is invoice tax-only?

  p_current_invoice_status := l_current_invoice_status;

  RETURN(TRUE);

EXCEPTION
  WHEN OTHERS THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
      AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
    END IF;

    IF (SQLCODE < 0) then
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                      SQLERRM);
      END IF;
    END IF;
    RETURN(FALSE);

END v_check_tax_info;

/*=============================================================================
 |  FUNCTION - V_Check_Tax_Line_Info()
 |
 |  DESCRIPTION
 |      This function will validate the following fields included in the
 |      ap_invoice_lines_interface table as part of the eTax Uptake project:
 |        control_amount
 |        assessable_value
 |        incl_in_taxable_line_flag
 |
 |      The other tax fields will be validated by the eTax API.  See DLD for
 |      details.
 |
 |  PARAMETERS
 |    p_invoice_rec - record for invoice header
 |    p_default_last_updated_by - default last updated by
 |    p_default_last_update_login - default last update login
 |    p_current_invoice_status - return the status of the invoice after the
 |                               validation
 |    P_calling_sequence -  Calling sequence
 |
 |  MODIFICATION HISTORY
 |    DATE          Author         Action
 |    20-JAN-2004   SYIDNER        Created
 |
 *============================================================================*/
  FUNCTION v_check_tax_line_info (
     p_invoice_lines_rec   IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
     p_default_last_updated_by      IN            NUMBER,
     p_default_last_update_login    IN            NUMBER,
     p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
     p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN

  IS

    tax_line_info_failure      EXCEPTION;
    l_valid_info                VARCHAR2(1);
    l_current_invoice_status    VARCHAR2(1) := 'Y';
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(500);

    --6412397
    l_po_line_location_id      ap_invoice_lines_interface.po_line_location_id%TYPE;
    l_location_id              zx_transaction_lines_gt.ship_from_location_id%type;
    l_ship_to_location_id      ap_supplier_sites_all.ship_to_location_id%type;
    l_bill_to_location_id      zx_transaction_lines_gt.bill_to_location_id%TYPE;
    l_fob_point                po_vendor_sites_all.fob_lookup_code%TYPE;

    l_dflt_tax_class_code      zx_transaction_lines_gt.input_tax_classification_code%type;
    l_allow_tax_code_override  varchar2(10);
    l_dummy                    number;
    -- Purchase Order Info
    l_ref_doc_application_id   zx_transaction_lines_gt.ref_doc_application_id%TYPE;
    l_ref_doc_entity_code      zx_transaction_lines_gt.ref_doc_entity_code%TYPE;
    l_ref_doc_event_class_code zx_transaction_lines_gt.ref_doc_event_class_code%TYPE;
    l_ref_doc_line_quantity    zx_transaction_lines_gt.ref_doc_line_quantity%TYPE;
    l_ref_doc_trx_level_type   zx_transaction_lines_gt.ref_doc_trx_level_type%TYPE;
    l_ref_doc_trx_id           zx_transaction_lines_gt.ref_doc_trx_id%TYPE;
    l_product_org_id           zx_transaction_lines_gt.product_org_id%TYPE;

    l_po_header_curr_conv_rate po_headers_all.rate%TYPE;
    l_uom_code                 mtl_units_of_measure.uom_code%TYPE;

    l_error_code               VARCHAR2(500);
    l_inv_hdr_org_id           ap_invoices_interface.org_id%TYPE;
    l_inv_hdr_vendor_id        ap_invoices_interface.vendor_id%TYPE;
    l_inv_hdr_vendor_site_id   ap_invoices_interface.vendor_site_id%TYPE;
    l_inv_hdr_inv_type         ap_invoices_interface.invoice_type_lookup_code%TYPE;

    l_event_class_code           zx_trx_headers_gt.event_class_code%TYPE;
    --6412397

  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence := 'AP_IMPORT_VALIDATION_PKG.v_check_tax_line_info<-'
      ||P_calling_sequence;

/* Bug 5206170: Removed the check for assessable value
    --------------------------------------------------------------------------
    debug_info := '(Check Tax Line Info 1) Check for Invalid sign in the '||
                  'assessable value';
    --------------------------------------------------------------------------
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (NVL(p_invoice_lines_rec.assessable_value, 0) <> 0) THEN
      IF (SIGN(p_invoice_lines_rec.assessable_value) <>
          SIGN(p_invoice_lines_rec.amount)) THEN
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
          AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
             p_invoice_lines_rec.invoice_line_id,
             'INVALID SIGN ASSESSABLE VALUE',
             p_default_last_updated_by,
             p_default_last_update_login,
             current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
              'insert_rejections<-' ||current_calling_sequence);
          END IF;
          RAISE tax_line_info_failure;
        END IF;

        l_current_invoice_status := 'N';

      END IF;
    END IF;  -- end of validation for assessable value
*/

    --------------------------------------------------------------------------
    debug_info := '(Check Tax Line Info 2) Check for control_amount greater '||
                   'than line amount';
    --------------------------------------------------------------------------
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (NVL(p_invoice_lines_rec.control_amount, 0) <> 0) THEN

      /*  --Bug 6925674 (Base bug6905106) Starts
        BEGIN
	        SELECT aii.invoice_type_lookup_code
	        INTO   l_inv_hdr_inv_type
	        FROM   ap_invoices_interface aii,
	               ap_invoice_lines_interface aili
	        WHERE  aii.invoice_id = aili.invoice_id
	        AND    aili.ROWID = p_invoice_lines_rec.row_id;

            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
               AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
            END IF;
        EXCEPTION
        WHEN OTHERS THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
               AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
            END IF;
        END;  Commented for Bug9852580 */

        IF((sign(NVL(p_invoice_lines_rec.control_amount,0)))= (sign(NVL(p_invoice_lines_rec.amount,0))) AND /* Added for Bug9852580 */
        /*(l_inv_hdr_inv_type IN ('CREDIT', 'DEBIT') AND --Bug 7299826  Added DEBIT , Commented for Bug9852580 */
          (abs(p_invoice_lines_rec.control_amount) >
           abs(p_invoice_lines_rec.amount))) THEN

           IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
             AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
             p_invoice_lines_rec.invoice_line_id,
             'INVALID CONTROL AMOUNT ',
             p_default_last_updated_by,
             p_default_last_update_login,
             current_calling_sequence) <> TRUE) THEN

             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                 AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'insert_rejections<-' ||current_calling_sequence);
             END IF;

             RAISE tax_line_info_failure;

          END IF;
          l_current_invoice_status := 'N';
          --Bug 6925674 (Base bug6905106) Ends
        ELSIF ((sign(NVL(p_invoice_lines_rec.control_amount,0))<> sign(NVL(p_invoice_lines_rec.amount,0))) AND /* Added for Bug9852580 */
       /*( (l_inv_hdr_inv_type NOT IN ('CREDIT', 'DEBIT') and    --bug 7299826 Commented for Bug9852580 */
        (p_invoice_lines_rec.control_amount > p_invoice_lines_rec.amount)) THEN
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
             AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
             p_invoice_lines_rec.invoice_line_id,
             'INVALID CONTROL AMOUNT ',
             p_default_last_updated_by,
             p_default_last_update_login,
             current_calling_sequence) <> TRUE) THEN
             IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
               AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
               'insert_rejections<-' ||current_calling_sequence);
             END IF;

	     RAISE tax_line_info_failure;
          END IF;

          l_current_invoice_status := 'N';

        END IF;
    END IF;  -- end of validation for control amount

    --------------------------------------------------------------------------
    debug_info := '(Check Tax Line Info 3) Tax should not be inclusive if '||
                  'tax line is PO matched';
    --------------------------------------------------------------------------
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (p_invoice_lines_rec.line_type_lookup_code = 'TAX'
        AND NVL(p_invoice_lines_rec.incl_in_taxable_line_flag, 'N') = 'Y'
        AND (p_invoice_lines_rec.po_header_id IS NOT NULL OR
             p_invoice_lines_rec.po_number IS NOT NULL OR
             p_invoice_lines_rec.po_line_id IS NOT NULL OR
             p_invoice_lines_rec.po_line_number IS NOT NULL OR
             p_invoice_lines_rec.po_line_location_id IS NOT NULL OR
             p_invoice_lines_rec.po_shipment_num IS NOT NULL OR
             p_invoice_lines_rec.po_distribution_id IS NOT NULL OR
             p_invoice_lines_rec.po_distribution_num IS NOT NULL)) THEN

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
       AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
          p_invoice_lines_rec.invoice_line_id,
           'TAX CANNOT BE INCLUDED',
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-' ||current_calling_sequence);
        END IF;
        RAISE tax_line_info_failure;
      END IF;

      l_current_invoice_status := 'N';

    END IF;  -- end of validation for incl_in_taxable_line_flag

    --Bug 6412397
    --------------------------------------------------------------------------
    debug_info := '(Check Tax Line Info 4) Tax_regime_code and tax are '||
                  'required in tax lines to be imported';
    --------------------------------------------------------------------------
    IF (p_invoice_lines_rec.line_type_lookup_code = 'TAX' AND
        p_invoice_lines_rec.tax_classification_code IS NULL AND
        p_invoice_lines_rec.tax_rate_code IS NULL) THEN

    --
    --  Fetch header vendor_id, vendor_site_id, invoice type
    --

    BEGIN
        SELECT NVL(p_invoice_lines_rec.org_id, aii.org_id),
               aii.vendor_id,
               aii.vendor_site_id,
               aii.invoice_type_lookup_code
        INTO   l_inv_hdr_org_id,
               l_inv_hdr_vendor_id,
               l_inv_hdr_vendor_site_id,
               l_inv_hdr_inv_type
        FROM   ap_invoices_interface aii,
               ap_invoice_lines_interface aili
        WHERE  aii.invoice_id = aili.invoice_id
        AND    aili.ROWID = p_invoice_lines_rec.row_id;

        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
        END IF;
    END;
    ----------------------------------------------------------------------
    debug_info := 'Step 4.1: Get location_id for vendor site';
    ----------------------------------------------------------------------
        BEGIN
          SELECT location_id,   ship_to_location_id,   fob_lookup_code
            INTO l_location_id, l_ship_to_location_id, l_fob_point
            FROM ap_supplier_sites_all
           WHERE vendor_site_id = l_inv_hdr_vendor_site_id;

        EXCEPTION
          WHEN no_data_found THEN
            l_location_id           := null;
            l_ship_to_location_id   := null;
            l_fob_point            := null;
        END;
    ----------------------------------------------------------------------
    debug_info := 'Step 4.2: Get location_id for org_id';
    ----------------------------------------------------------------------
        BEGIN
          SELECT location_id
            INTO l_bill_to_location_id
            FROM hr_all_organization_units
           WHERE organization_id = l_inv_hdr_org_id;

        EXCEPTION
          WHEN no_data_found THEN
             l_bill_to_location_id := null;
        END;

    -------------------------------------------------------------------
    debug_info := 'Step 4.5: Get Additional PO matched  info ';
    -------------------------------------------------------------------
        IF ( p_invoice_lines_rec.po_line_location_id IS NOT NULL) THEN

          -- this assignment is required since the p_po_line_location_id
          -- parameter is IN/OUT.  However, in this case it will not be
          -- modified because the po_distribution_id is not provided

        l_po_line_location_id := p_invoice_lines_rec.po_line_location_id;

        IF NOT (AP_ETAX_UTILITY_PKG.Get_PO_Info(
           P_Po_Line_Location_Id         => l_po_line_location_id,
           P_PO_Distribution_Id          => null,
           P_Application_Id              => l_ref_doc_application_id,
           P_Entity_code                 => l_ref_doc_entity_code,
           P_Event_Class_Code            => l_ref_doc_event_class_code,
           P_PO_Quantity                 => l_ref_doc_line_quantity,
           P_Product_Org_Id              => l_product_org_id,
           P_Po_Header_Id                => l_ref_doc_trx_id,
           P_Po_Header_curr_conv_rate    => l_po_header_curr_conv_rate,
           P_Uom_Code                   => l_uom_code,
           P_Dist_Qty                    => l_dummy,
           P_Ship_Price                  => l_dummy,
           P_Error_Code                  => l_error_code,
           P_Calling_Sequence            => current_calling_sequence)) THEN

           debug_info := 'Step 4.5: Get Additional PO matched info failed: '||
l_error_code;
        END IF;

        l_ref_doc_trx_level_type := 'SHIPMENT';

        ELSE
         l_ref_doc_application_id     := Null;
         l_ref_doc_entity_code        := Null;
         l_ref_doc_event_class_code   := Null;
         l_ref_doc_line_quantity      := Null;
         l_product_org_id             := Null;
         l_ref_doc_trx_id             := Null;
         l_ref_doc_trx_level_type     := Null;
        END IF;

    -------------------------------------------------------------------
    debug_info := 'Step 4.6: Get event class code';
    -------------------------------------------------------------------

        IF NOT(AP_ETAX_UTILITY_PKG.Get_Event_Class_Code(
          P_Invoice_Type_Lookup_Code => l_inv_hdr_inv_type,
          P_Event_Class_Code         => l_event_class_code,
          P_error_code               => l_error_code,
          P_calling_sequence         => current_calling_sequence)) THEN

          debug_info := 'Step 4.6: Get event class code failed: '||
l_error_code;

        END IF;

    -------------------------------------------------------------------
    debug_info := 'Step 4.7: Call tax classification code defaulting api';
    -------------------------------------------------------------------

        ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification
        (p_ref_doc_application_id           => l_ref_doc_application_id,
         p_ref_doc_entity_code              => l_ref_doc_entity_code,
         p_ref_doc_event_class_code         => l_ref_doc_event_class_code,
         p_ref_doc_trx_id                   => l_ref_doc_trx_id,
         p_ref_doc_line_id                  =>
p_invoice_lines_rec.po_line_location_id,
         p_ref_doc_trx_level_type           => l_ref_doc_trx_level_type,
--'SHIPMENT',
         p_vendor_id                        => l_inv_hdr_vendor_id,
         p_vendor_site_id                   => l_inv_hdr_vendor_site_id,
         p_code_combination_id              =>
p_invoice_lines_rec.default_dist_ccid,
         p_concatenated_segments            => null,
         p_templ_tax_classification_cd      => null,
         p_ship_to_location_id              =>
nvl(p_invoice_lines_rec.ship_to_location_id,
                                                   l_ship_to_location_id),
         p_ship_to_loc_org_id               => null,
         p_inventory_item_id                =>
p_invoice_lines_rec.inventory_item_id,
         p_item_org_id                      => l_product_org_id,
         p_tax_classification_code          => l_dflt_tax_class_code,
         p_allow_tax_code_override_flag     => l_allow_tax_code_override,
         APPL_SHORT_NAME                    => 'SQLAP',
         FUNC_SHORT_NAME                    => 'NONE',
         p_calling_sequence                 => current_calling_sequence,
--'AP_ETAX_SERVICES_PKG',
         p_event_class_code                 => NULL, --p_event_class_code,
         p_entity_code                      => 'AP_INVOICES',
         p_application_id                   => 200,
         p_internal_organization_id         => l_inv_hdr_org_id );


         p_invoice_lines_rec.tax_classification_code := l_dflt_tax_class_code;
    END IF;
    -- After validation check again
    -- End Bug 6412397

    --------------------------------------------------------------------------
    debug_info := '(Check Tax Line Info 4.8) Tax_regime_code and tax are '||
                  'required in tax lines to be imported'; -- Bug 6412397
    --------------------------------------------------------------------------
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (p_invoice_lines_rec.line_type_lookup_code = 'TAX' AND
        p_invoice_lines_rec.tax_classification_code is null --6255826
          and p_invoice_lines_rec.TAX_RATE_CODE is null   --6255826
        )  THEN

      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
       AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
          p_invoice_lines_rec.invoice_line_id,
           'INSUFFICIENT TAX INFO', --bug6255826 Replaced TAX INFO REQUIRED
           p_default_last_updated_by,
           p_default_last_update_login,
           current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
            'insert_rejections<-' ||current_calling_sequence);
        END IF;
        RAISE tax_line_info_failure;
      END IF;

      l_current_invoice_status := 'N';

    END IF;  -- end of validation tax_Regime_code and tax column in tax lines

  p_current_invoice_status := l_current_invoice_status;
  RETURN (TRUE);

  EXCEPTION
    WHEN OTHERS THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
          AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
      END IF;

      IF (SQLCODE < 0) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
          AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
        END IF;
      END IF;
      RETURN(FALSE);

  END v_check_tax_line_info;


 FUNCTION v_check_line_purch_category(
	p_invoice_lines_rec   IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
        p_default_last_updated_by      IN            NUMBER,
        p_default_last_update_login    IN            NUMBER,
        p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
        p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN

  IS
    purch_category_check_failure EXCEPTION;
    l_purchasing_category_id	AP_INVOICE_LINES_ALL.PURCHASING_CATEGORY_ID%TYPE;
    l_current_invoice_status    VARCHAR2(1) := 'Y';
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(500);

  BEGIN

    -- Update the calling sequence
    --
    current_calling_sequence := 'AP_IMPORT_VALIDATION_PKG.v_check_line_purch_category<-'
      ||P_calling_sequence;

    --------------------------------------------------------------------------
    debug_info := '(Check Line Purchasing_Category Info 1) If purchasing_category_id and '||
		   'concatenated segments are provided'||
		   ' then cross validate the info from concatenated segments';
    --------------------------------------------------------------------------
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    -- Bug 5448579
    IF AP_IMPORT_INVOICES_PKG.g_structure_id IS NULL THEN
      p_invoice_lines_rec.purchasing_category_id := NULL;
      p_invoice_lines_rec.purchasing_category := NULL;
    END IF;

    IF (p_invoice_lines_rec.line_type_lookup_code <> 'ITEM') THEN

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
               'INCONSISTENT CATEGORY',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence,
               'Y',
               'INVOICE LINE NUMBER',
               p_invoice_lines_rec.line_number) <> TRUE) THEN

               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                 AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
               END IF;

               RAISE purch_category_check_failure;

          END IF;

          l_current_invoice_status := 'N';

    END IF;

    IF (p_invoice_lines_rec.purchasing_category_id IS NOT NULL AND
        p_invoice_lines_rec.purchasing_category IS NOT NULL) THEN

          l_purchasing_category_id := FND_FLEX_EXT.GET_CCID('INV', 'MCAT',
           AP_IMPORT_INVOICES_PKG.g_structure_id,
           to_char(sysdate,'YYYY/MM/DD HH24:MI:SS'),p_invoice_lines_rec.purchasing_category);

          IF (l_purchasing_category_id <> p_invoice_lines_rec.purchasing_category_id) THEN

	     IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
               'INCONSISTENT CATEGORY',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence,
               'Y',
               'INVOICE LINE NUMBER',
               p_invoice_lines_rec.line_number) <> TRUE) THEN

               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                 AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
               END IF;

               RAISE purch_category_check_failure;

             END IF;

             l_current_invoice_status := 'N';

          END IF;

    ELSIF (p_invoice_lines_rec.purchasing_category IS NOT NULL) THEN

       --------------------------------------------------------------------------
       debug_info := '(Check Line purchasing_Category Info 2) If just concatenated segments'||
		     'are provided then derive the purchasing_category_id from that info';
       --------------------------------------------------------------------------
       IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
         AP_IMPORT_UTILITIES_PKG.Print(
         AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
       END IF;

       l_purchasing_category_id := FND_FLEX_EXT.GET_CCID('INV', 'MCAT',
          AP_IMPORT_INVOICES_PKG.g_structure_id,
          to_char(sysdate,'YYYY/MM/DD HH24:MI:SS'),p_invoice_lines_rec.purchasing_category);

       IF ((l_purchasing_category_id is not null) and (l_purchasing_category_id <> 0 )) THEN
          p_invoice_lines_rec.purchasing_category_id := l_purchasing_category_id;

       ELSE

          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
               AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
               p_invoice_lines_rec.invoice_line_id,
               'INVALID CATEGORY',
               p_default_last_updated_by,
               p_default_last_update_login,
               current_calling_sequence,
               'Y',
               'INVOICE LINE NUMBER',
               p_invoice_lines_rec.line_number) <> TRUE) THEN

               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                 AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
               END IF;

               RAISE purch_category_check_failure;

             END IF;

             l_current_invoice_status := 'N';

       END IF;

    END IF;

    --------------------------------------------------------
      -- Validate Item Category Information
      -- If both Purchasing_Category and PO Information is provided
      -- then validate the Purchasing_Category info provided in interface
      -- against the one on the PO_Line.
    --------------------------------------------------------
    IF (l_current_invoice_status = 'Y' AND
	 p_invoice_lines_rec.purchasing_category_id IS NOT NULL AND
          (p_invoice_lines_rec.po_line_id is not null or
	   p_invoice_lines_rec.po_line_location_id is not null)) THEN

       BEGIN

	  IF (p_invoice_lines_rec.po_line_id IS NOT NULL) THEN
   	     SELECT category_id
	     INTO l_purchasing_category_id
	     FROM po_lines_all
	     WHERE po_line_id = p_invoice_lines_rec.po_line_id;

	  ELSE
	     SELECT pl.category_id
	     INTO l_purchasing_category_id
	     FROM po_lines_all pl, po_line_locations_all pll
	     WHERE pll.line_location_id = p_invoice_lines_rec.po_line_location_id
	     AND pl.po_line_id = pll.po_line_id;

	  END IF;

	  IF (l_purchasing_category_id <> p_invoice_lines_rec.purchasing_category_id) THEN

             IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                 AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                 p_invoice_lines_rec.invoice_line_id,
                 'INCONSISTENT CATEGORY',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence,
                 'Y',
                 'INVOICE LINE NUMBER',
                 p_invoice_lines_rec.line_number) <> TRUE) THEN

               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                 AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
               END IF;

               RAISE purch_category_check_failure;

             END IF;

             l_current_invoice_status := 'N';

          /* if the information provided and the information on the PO Line is the same
	   then we do not REJECT, but ignore the value provided by the user, since we will
	   not be denormalizing the purchasing category info of the PO Line onto the
	   invoice lines for matched cases */

          ELSE

	     p_invoice_lines_rec.purchasing_category_id := NULL;

          END IF;

        END;

     END IF;

     p_current_invoice_status := l_current_invoice_status;

     RETURN (TRUE);

 END v_check_line_purch_category;


 FUNCTION v_check_line_cost_factor(
	p_invoice_lines_rec   IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
        p_default_last_updated_by      IN            NUMBER,
        p_default_last_update_login    IN            NUMBER,
        p_current_invoice_status       IN OUT NOCOPY VARCHAR2,
        p_calling_sequence             IN            VARCHAR2) RETURN BOOLEAN

  IS
    cost_factor_check_failure EXCEPTION;
    l_cost_factor_id	AP_INVOICE_LINES_ALL.COST_FACTOR_ID%TYPE;
    l_valid_cost_factor VARCHAR2(1);
    l_current_invoice_status    VARCHAR2(1) := 'Y';
    current_calling_sequence    VARCHAR2(2000);
    debug_info                  VARCHAR2(500);

  BEGIN
    -- Update the calling sequence
    --
    current_calling_sequence := 'AP_IMPORT_VALIDATION_PKG.v_check_line_cost_factor<-'
      ||P_calling_sequence;

    --------------------------------------------------------------------------
    debug_info := '(Check Line Cost_Factor Info 1) If cost_factor_id and '||
		   'cost_factor_name provided'||
		   ' then cross validate the info';
    --------------------------------------------------------------------------
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
        AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
    END IF;

    IF (p_invoice_lines_rec.line_type_lookup_code IN ('TAX','FREIGHT','MISCELLANEOUS')) THEN

      IF (p_invoice_lines_rec.cost_factor_name IS NOT NULL) THEN
 	debug_info := '(Check Line Cost_Factor Info 2) Check if cost_factor_name is provided'
		   ||' then derive cost_factor_id';
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(
           AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

        BEGIN

   	  SELECT price_element_type_id
	  INTO l_cost_factor_id
	  FROM pon_price_element_types_vl
	  WHERE name = p_invoice_lines_rec.cost_factor_name;

    	  EXCEPTION WHEN OTHERS THEN

  	     IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                 AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                 p_invoice_lines_rec.invoice_line_id,
                 'INVALID COST FACTOR INFO',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence,
                 'Y',
                 'INVOICE LINE NUMBER',
                 p_invoice_lines_rec.line_number) <> TRUE) THEN

               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                 AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
               END IF;

               RAISE cost_factor_check_failure;

             END IF;

             l_current_invoice_status := 'N';
        END;

      END IF;  /* IF p_invoice_lines_rec.cost_factor_name IS NOT NULL */


      IF (l_current_invoice_status = 'Y') THEN

        IF (p_invoice_lines_rec.cost_factor_id IS NOT NULL and
	  p_invoice_lines_rec.cost_factor_name IS NOT NULL) THEN

 	  debug_info := '(Check Line Cost_Factor Info 2) Cross validate '||
			'cost_factor_name and cost_factor_id information';
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
          END IF;

	  IF (l_cost_factor_id <> p_invoice_lines_rec.cost_factor_id) THEN

    	     IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                 AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                 p_invoice_lines_rec.invoice_line_id,
                 'INVALID COST FACTOR INFO',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence,
                 'Y',
                 'INVOICE LINE NUMBER',
                 p_invoice_lines_rec.line_number) <> TRUE) THEN

                IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                  AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                 'insert_rejections<-'||current_calling_sequence);
                END IF;

                RAISE cost_factor_check_failure;

              END IF;

              l_current_invoice_status := 'N';

  	   END IF;

         ELSIF (p_invoice_lines_rec.cost_factor_id IS NULL) THEN

  	   debug_info := '(Check Line Cost_Factor Info 4) If cost_factor_id is null and '||
		   'cost_factor_name is provided, then assign the derived cost_factor_id'
		   ||' then derive cost_factor_id';
           IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
           END IF;

           p_invoice_lines_rec.cost_factor_id := l_cost_factor_id;

         ELSIF (p_invoice_lines_rec.cost_factor_id IS NOT NULL) THEN

	   debug_info := '(Check Line Cost Factor Info 5) If cost_factor_id is'||
	   		' not null , then validate it against the valid set of'||
			' cost factors';
	   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
             AP_IMPORT_UTILITIES_PKG.Print(
             AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
           END IF;

           BEGIN
	      SELECT 'Y'
	      INTO l_valid_cost_factor
	      FROM pon_price_element_types_vl
	      WHERE price_element_type_id = p_invoice_lines_rec.cost_factor_id;

      	    EXCEPTION WHEN OTHERS THEN

  	     IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
                 AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
                 p_invoice_lines_rec.invoice_line_id,
                 'INVALID COST FACTOR INFO',
                 p_default_last_updated_by,
                 p_default_last_update_login,
                 current_calling_sequence,
                 'Y',
                 'INVOICE LINE NUMBER',
                 p_invoice_lines_rec.line_number) <> TRUE) THEN

               IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
                 AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                'insert_rejections<-'||current_calling_sequence);
               END IF;

               RAISE cost_factor_check_failure;

             END IF;

             l_current_invoice_status := 'N';

           END;

         END IF;

      END IF; /* l_current_invoice_status = 'Y' */

    --if cost_factor information is provided on non-charge lines, then do not
    --perform any validation, just ignore the value in this fields, and make sure
    --to not insert the values onto the non-charge lines.
    ELSE

      p_invoice_lines_rec.cost_factor_id := NULL;
      p_invoice_lines_rec.cost_factor_name := NULL;

    END IF ;  /* IF p_invoice_lines_rec.line_type_lookup_code ... */

    p_current_invoice_status := l_current_invoice_status;

    RETURN (TRUE);

  END v_check_line_cost_factor;

  FUNCTION v_check_line_retainage(
        p_invoice_lines_rec		IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
	p_retainage_ccid		IN            NUMBER,
	p_default_last_updated_by	IN            NUMBER,
	p_default_last_update_login	IN            NUMBER,
	p_current_invoice_status	IN OUT NOCOPY VARCHAR2,
	p_calling_sequence		IN            VARCHAR2) RETURN BOOLEAN IS

	l_ret_status          Varchar2(100);
	l_msg_data            Varchar2(4000);

	l_retained_amount     Number;

	retainage_check_failure     EXCEPTION;
	l_current_invoice_status    VARCHAR2(1) := 'Y';
	current_calling_sequence    VARCHAR2(2000);
	debug_info                  VARCHAR2(500);

  Begin
	-- Update the calling sequence
	--
	current_calling_sequence := 'AP_IMPORT_VALIDATION_PKG.v_check_line_retainage<-'
					||P_calling_sequence;

	--------------------------------------------------------------------------
	debug_info := '(Check Retainage 1) Get retained amount based on po shipment and line amount';
	--------------------------------------------------------------------------
	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

	l_retained_amount := ap_invoice_lines_utility_pkg.get_retained_amount
					(p_invoice_lines_rec.po_line_location_id,
					 p_invoice_lines_rec.amount);

	--------------------------------------------------------------------------
	debug_info := '(Check Retainage 2) Check for retainage account';
	--------------------------------------------------------------------------
	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
            AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
        END IF;

	If l_retained_amount IS NOT NULL Then

	   If p_retainage_ccid IS NULL Then

		If (AP_IMPORT_UTILITIES_PKG.insert_rejections(
				AP_IMPORT_INVOICES_PKG.g_invoice_lines_table,
				p_invoice_lines_rec.invoice_line_id,
				'RETAINAGE ACCT REQD',
				p_default_last_updated_by,
				p_default_last_update_login,
				current_calling_sequence,
				'Y',
				'INVOICE LINE NUMBER',
				p_invoice_lines_rec.line_number) <> TRUE) Then

			If (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') Then
			    AP_IMPORT_UTILITIES_PKG.Print
				(AP_IMPORT_INVOICES_PKG.g_debug_switch, 'insert_rejections<-'||current_calling_sequence);
			End If;

			RAISE retainage_check_failure;
		End If;

                l_current_invoice_status := 'N';
	   Else

		p_invoice_lines_rec.retained_amount := l_retained_amount;

	   End If;
	End If;

	p_current_invoice_status := l_current_invoice_status;
	RETURN (TRUE);

  EXCEPTION
	WHEN OTHERS THEN
		IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
			AP_IMPORT_UTILITIES_PKG.Print(
				AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
		END IF;

		IF (SQLCODE < 0) THEN
			IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
				AP_IMPORT_UTILITIES_PKG.Print(
					AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
			END IF;
		END IF;
		RETURN(FALSE);

  End v_check_line_retainage;




  FUNCTION v_check_payment_defaults(
    p_invoice_rec               IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_current_invoice_status	IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER) return boolean is


  debug_info                  VARCHAR2(500);
  l_current_invoice_status    VARCHAR2(1) := 'Y';
  current_calling_sequence    VARCHAR2(2000);
  l_dummy                     varchar2(1);
  pmt_attr_validation_failure exception;
  l_IBY_PAYMENT_METHOD        varchar2(80);
  l_PAYMENT_REASON            varchar2(80);
  l_BANK_CHARGE_BEARER_DSP    varchar2(80);
  l_DELIVERY_CHANNEL          varchar2(80);
  l_SETTLEMENT_PRIORITY_DSP   varchar2(80);
  l_bank_account_num          varchar2(100);
  l_bank_account_name         varchar2(80);
  l_bank_branch_name          varchar2(360);
  l_bank_branch_num           varchar2(30);
  l_bank_name                 varchar2(360);
  l_bank_number               varchar2(30);




  l_PAYMENT_METHOD_CODE       varchar2(30);
  l_PAYMENT_REASON_CODE       varchar2(30);
  l_BANK_CHARGE_BEARER        varchar2(30);
  l_DELIVERY_CHANNEL_CODE     varchar2(30);
  l_SETTLEMENT_PRIORITY       varchar2(30);
  l_PAY_ALONE                 varchar2(30);
  l_external_bank_account_id  number;
  l_exclusive_payment_flag    varchar2(1);
  l_payment_reason_comments   varchar2(240); --4874927
  -- Bug 5448579
  l_valid_payment_method      IBY_PAYMENT_METHODS_VL.Payment_Method_Code%TYPE;

  --Bug 8213679
  l_remit_party_id	AP_INVOICES_ALL.PARTY_ID%TYPE;
  l_remit_party_site_id	AP_INVOICES_ALL.PARTY_SITE_ID%TYPE;
  --Bug 8213679


  begin


    current_calling_sequence := 'AP_IMPORT_VALIDATION_PKG.v_check_payment_defaults<-'
					||P_calling_sequence;

    debug_info := 'Check the payment reason';

    if p_invoice_rec.payment_reason_code is not null then

      begin
        select 'x'
        into l_dummy
        from iby_payment_reasons_vl
        where payment_reason_code = p_invoice_rec.payment_reason_code
        and rownum = 1;

      exception
        when no_data_found then
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID PAYMENT REASON',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            'insert_rejections<-'
                                            ||current_calling_sequence);
            END IF;
            RAISE pmt_attr_validation_failure;
          END IF;

          l_current_invoice_status := 'N';

       end;
    end if;



    debug_info := 'Check the bank charge bearer';

    if p_invoice_rec.bank_charge_bearer is not null then

      begin
        select 'x'
        into l_dummy
        from fnd_lookups
        where lookup_type = 'IBY_BANK_CHARGE_BEARER'
        and lookup_code = p_invoice_rec.bank_charge_bearer
        and rownum = 1;

      exception
        when no_data_found then
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID BANK CHARGE BEARER',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            'insert_rejections<-'
                                            ||current_calling_sequence);
            END IF;
            RAISE pmt_attr_validation_failure;
          END IF;

          l_current_invoice_status := 'N';

       end;
    end if;



    debug_info := 'Check the delivery channel code';

    if p_invoice_rec.delivery_channel_code is not null then

      begin
        select 'x'
        into l_dummy
        from iby_delivery_channels_vl
        where delivery_channel_code = p_invoice_rec.delivery_channel_code
        and rownum = 1;

      exception
        when no_data_found then
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID DELIVERY CHANNEL CODE',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            'insert_rejections<-'
                                            ||current_calling_sequence);
            END IF;
            RAISE pmt_attr_validation_failure;
          END IF;

          l_current_invoice_status := 'N';

       end;
    end if;





    debug_info := 'Check the settlement priority';

    if p_invoice_rec.settlement_priority is not null then

      begin
        select 'x'
        into l_dummy
        from fnd_lookups
        where lookup_type = 'IBY_SETTLEMENT_PRIORITY'
        and lookup_code = p_invoice_rec.settlement_priority
        and rownum = 1;

      exception
        when no_data_found then
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID SETTLEMENT PRIORITY',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            'insert_rejections<-'
                                            ||current_calling_sequence);
            END IF;
            RAISE pmt_attr_validation_failure;
          END IF;

          l_current_invoice_status := 'N';

       end;
    end if;






    debug_info := 'Check the external bank account id is defined';

    if p_invoice_rec.external_bank_account_id is not null then

      begin
        select 'x'
        into l_dummy
        from iby_ext_bank_accounts_v
        where ext_bank_account_id = p_invoice_rec.external_bank_account_id
        and rownum = 1;

      exception
        when no_data_found then
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID EXTERNAL BANK ACCT ID',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            'insert_rejections<-'
                                            ||current_calling_sequence);
            END IF;
            RAISE pmt_attr_validation_failure;
          END IF;

          l_current_invoice_status := 'N';

       end;
    end if;


    debug_info := 'Check the paymemt_method_code is defined';

    if p_invoice_rec.payment_method_code is not null then
       -- Bug 5448579
      FOR i IN AP_IMPORT_INVOICES_PKG.g_payment_method_tab.First.. AP_IMPORT_INVOICES_PKG.g_payment_method_tab.Last
      LOOP
        IF  AP_IMPORT_INVOICES_PKG.g_payment_method_tab(i).payment_method = p_invoice_rec.payment_method_code THEN
          l_valid_payment_method  :=  AP_IMPORT_INVOICES_PKG.g_payment_method_tab(i).payment_method;
          EXIT;
        END IF;
      END LOOP;

      debug_info := 'l_valid_payment_method: '||l_valid_payment_method;
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                    debug_info);
      END IF;

      IF l_valid_payment_method IS NULL THEN

        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID PAY METHOD',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            'insert_rejections<-'
                                            ||current_calling_sequence);
          END IF;
          RAISE pmt_attr_validation_failure;
        END IF;

        l_current_invoice_status := 'N';

      END IF;

    end if;

    /*  begin
        select 'x'
        into l_dummy
        from iby_payment_methods_vl --4393358
        where payment_method_code = p_invoice_rec.payment_method_code
        and rownum = 1;

      exception
        when no_data_found then
          IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID PAY METHOD',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            'insert_rejections<-'
                                            ||current_calling_sequence);
            END IF;
            RAISE pmt_attr_validation_failure;
          END IF;

          l_current_invoice_status := 'N';

       end; */




    --iby's api requires the pay proc trxn type and payment function, so we
    --need to determine them for AP if not populated

    -- As per the discussion with Omar/Jayanta, we will only
    -- have payables payment function and no more employee expenses
    -- payment function.

    if p_invoice_rec.invoice_type_lookup_code is not null and
       p_invoice_rec.payment_function is null then
        p_invoice_rec.payment_function := 'PAYABLES_DISB';
    end if;

    /* bug 5115632 */
    if p_invoice_rec.invoice_type_lookup_code = 'EXPENSE REPORT'
      and p_invoice_rec.pay_proc_trxn_type_code is null then
      p_invoice_rec.pay_proc_trxn_type_code := 'EMPLOYEE_EXP';
    end if;

    if p_invoice_rec.invoice_type_lookup_code  <> 'EXPENSE REPORT'
      and  p_invoice_rec.pay_proc_trxn_type_code is null then
      if p_invoice_rec.payment_function = 'AR_CUSTOMER_REFUNDS' then
        p_invoice_rec.pay_proc_trxn_type_code := 'AR_CUSTOMER_REFUND';
      elsif p_invoice_rec.payment_function = 'LOANS_PAYMENTS' then
        p_invoice_rec.pay_proc_trxn_type_code := 'LOAN_PAYMENT';
      else
        p_invoice_rec.pay_proc_trxn_type_code := 'PAYABLES_DOC';
      end if;
    end if;



    --now get defaults...
    -- modified below if condition as part of bug 8345877
    if p_invoice_rec.legal_entity_id is not null and
       p_invoice_rec.org_id is not null and
       p_invoice_rec.party_id is not null and
       --Bug8488565: OR condition for party_site_id and vendor_site_id
       (p_invoice_rec.party_site_id is not null or
       p_invoice_rec.vendor_site_id is not null ) and
       p_invoice_rec.payment_currency_code is not null and
       p_invoice_rec.invoice_amount is not null and
       p_invoice_rec.payment_function is not null and
       p_invoice_rec.pay_proc_trxn_type_code is not null then



      debug_info := 'Get iby defaults';

      --Bug 8245830
      IF (p_invoice_rec.invoice_type_lookup_code  <> 'PAYMENT REQUEST'  AND
		(p_invoice_rec.remit_to_supplier_id is not null AND
		p_invoice_rec.remit_to_supplier_site_id is not null)
	)THEN
        --Bug 8213679
        select party_id
        into l_remit_party_id
        from ap_suppliers
        where vendor_id = p_invoice_rec.remit_to_supplier_id;

        select party_site_id
        into l_remit_party_site_id
        from ap_supplier_sites_all
        where vendor_site_id = p_invoice_rec.remit_to_supplier_site_id
        and org_id = p_invoice_rec.org_id;
        --Bug 8213679
      ELSE
	  -- modified below code as part of bug 8345877
          --l_remit_party_id      := p_invoice_rec.party_id;
	  --l_remit_party_site_id := p_invoice_rec.party_site_id;
          l_remit_party_id      := null;
	 --Bug 9133220 handle expense reports with null party site id.
	 IF p_invoice_rec.party_site_id is null
	    AND p_invoice_rec.invoice_type_lookup_code  <> 'PAYMENT REQUEST'
	    AND nvl(p_invoice_rec.vendor_site_id, -1) > 0 THEN
		select party_site_id
		into l_remit_party_site_id
		from ap_supplier_sites_all
		where vendor_site_id = p_invoice_rec.vendor_site_id
		and org_id = p_invoice_rec.org_id;
	 ELSE
	     l_remit_party_site_id := null;
	 END If;
	 --end Bug 9133220
      END IF;


      ap_invoices_pkg.get_payment_attributes(
        p_le_id                     =>p_invoice_rec.legal_entity_id,
        p_org_id                    =>p_invoice_rec.org_id,
        p_payee_party_id            =>nvl(l_remit_party_id,p_invoice_rec.party_id),	--Bug 8345877
        p_payee_party_site_id       =>nvl(l_remit_party_site_id,p_invoice_rec.party_site_id), --Bug 8345877
        p_supplier_site_id          =>nvl(p_invoice_rec.remit_to_supplier_site_id,p_invoice_rec.vendor_site_id), --Bug 8345877
        p_payment_currency          =>p_invoice_rec.payment_currency_code,
        p_payment_amount            =>p_invoice_rec.invoice_amount,
        p_payment_function          =>p_invoice_rec.payment_function,
        p_pay_proc_trxn_type_code   =>p_invoice_rec.pay_proc_trxn_type_code,

        p_PAYMENT_METHOD_CODE       => l_payment_method_code,
        p_PAYMENT_REASON_CODE       => l_payment_reason_code,
        p_BANK_CHARGE_BEARER        => l_bank_charge_bearer,
        p_DELIVERY_CHANNEL_CODE     => l_delivery_channel_code,
        p_SETTLEMENT_PRIORITY       => l_settlement_priority,
        p_PAY_ALONE                 => l_exclusive_payment_flag,
        p_external_bank_account_id  => l_external_bank_account_id,

        p_IBY_PAYMENT_METHOD        => l_IBY_PAYMENT_METHOD,
        p_PAYMENT_REASON            => l_PAYMENT_REASON,
        p_BANK_CHARGE_BEARER_DSP    => l_BANK_CHARGE_BEARER_DSP,
        p_DELIVERY_CHANNEL          => l_DELIVERY_CHANNEL,
        p_SETTLEMENT_PRIORITY_DSP   => l_SETTLEMENT_PRIORITY_DSP,
        p_bank_account_num          => l_bank_account_num,
        p_bank_account_name         => l_bank_account_name,
        p_bank_branch_name          => l_bank_branch_name,
        p_bank_branch_num           => l_bank_branch_num,
        p_bank_name                 => l_bank_name,
        p_bank_number               => l_bank_number,
        p_payment_reason_comments   => l_payment_reason_comments, -- 4874927
        p_application_id            => p_invoice_rec.application_id);  --5115632





      debug_info := 'assign iby defaults to null fields';

      if p_invoice_rec.payment_method_code is null then
        p_invoice_rec.payment_method_code := l_payment_method_code;
      end if;

      if p_invoice_rec.payment_reason_code is null then
        p_invoice_rec.payment_reason_code := l_payment_reason_code;
      end if;

      if p_invoice_rec.bank_charge_bearer is null then
        p_invoice_rec.bank_charge_bearer := l_bank_charge_bearer;
      end if;

      if p_invoice_rec.delivery_channel_code is null then
        p_invoice_rec.delivery_channel_code := l_delivery_channel_code;
      end if;

      if p_invoice_rec.settlement_priority is null then
        p_invoice_rec.settlement_priority := l_settlement_priority;
      end if;

      if p_invoice_rec.exclusive_payment_flag is null then
        p_invoice_rec.exclusive_payment_flag := l_exclusive_payment_flag;
      end if;

      if p_invoice_rec.external_bank_account_id is null then
        p_invoice_rec.external_bank_account_id := l_external_bank_account_id;
      end if;

      --4874927
      if p_invoice_rec.payment_reason_comments is null then
        p_invoice_rec.payment_reason_comments := l_payment_reason_comments;
      end if;


    end if;

    --the payment method code is a required field so we should reject if it's
    --not present at this point (no default was found)
    if p_invoice_rec.payment_method_code is null then
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
               (AP_IMPORT_INVOICES_PKG.g_invoices_table,
                p_invoice_rec.invoice_id,
                'INVALID PAY METHOD',
                p_default_last_updated_by,
                p_default_last_update_login,
                current_calling_sequence) <> TRUE) THEN
            IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
              AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                            'insert_rejections<-'
                                            ||current_calling_sequence);
            END IF;
            RAISE pmt_attr_validation_failure;
      END IF;
      l_current_invoice_status := 'N';
    end if;



    p_current_invoice_status := l_current_invoice_status;

  return(true);

  EXCEPTION
	WHEN OTHERS THEN
		IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
			AP_IMPORT_UTILITIES_PKG.Print(
				AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
		END IF;

		IF (SQLCODE < 0) THEN
			IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
				AP_IMPORT_UTILITIES_PKG.Print(
					AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
			END IF;
		END IF;
		RETURN(FALSE);
  end v_check_payment_defaults;



FUNCTION v_check_party_vendor(
    p_invoice_rec               IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
    p_current_invoice_status	IN OUT NOCOPY VARCHAR2,
    p_calling_sequence          IN            VARCHAR2,
    p_default_last_updated_by   IN            NUMBER,
    p_default_last_update_login IN            NUMBER
    ) return boolean is

l_dummy varchar2(1);
l_current_invoice_status varchar2(1):='Y';
debug_info                  VARCHAR2(500);
current_calling_sequence    VARCHAR2(2000);
vendor_party_failure        exception;

-- Bug 7871425.
l_vendor_type_lookup_code   ap_suppliers.vendor_type_lookup_code%type ;

begin

  current_calling_sequence := 'AP_IMPORT_VALIDATION_PKG.v_check_party_vendor<-'
					||P_calling_sequence;
  debug_info := 'Check vendor and party info are consistent';




  --if the vendor and party are populated, I think we should make sure they are
  --consistent, the same goes for vedor site and party site
  -- Release won't be able to seed a rejection for the 2 cases below before the
  -- freeze.  So for now I am using existin ones.

  if p_invoice_rec.party_id is not null and p_invoice_rec.vendor_id is not null then
    begin
      select 'x'
      into l_dummy
      from po_vendors
      where vendor_id = p_invoice_rec.vendor_id
      and party_id = p_invoice_rec.party_id;
    exception
      when no_data_found then
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
             (AP_IMPORT_INVOICES_PKG.g_invoices_table,
              p_invoice_rec.invoice_id,
              'INCONSISTENT SUPPLIER',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                          'insert_rejections<-'
                                          ||current_calling_sequence);
          END IF;
          RAISE vendor_party_failure;
        END IF;
      l_current_invoice_status := 'N';
    end;
  end if;



  if p_invoice_rec.party_site_id is not null and
     p_invoice_rec.vendor_site_id is not null then
    begin
      select 'x'
      into l_dummy
      from po_vendor_sites
      where vendor_site_id = p_invoice_rec.vendor_site_id
      and party_site_id = p_invoice_rec.party_site_id;
    exception
      when no_data_found then
        IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
             (AP_IMPORT_INVOICES_PKG.g_invoices_table,
              p_invoice_rec.invoice_id,
              'INCONSISTENT SUPPL SITE',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
          IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                          'insert_rejections<-'
                                          ||current_calling_sequence);
          END IF;
          RAISE vendor_party_failure;
        END IF;
      l_current_invoice_status := 'N';
    end;
  end if;





  --according to Shelley, we want to populate a negative application
  --id when we have party info but no vendor info

  if p_invoice_rec.party_id is not null and p_invoice_rec.vendor_id is null then
    p_invoice_rec.vendor_id := -1 * p_invoice_rec.application_id;
  end if;

  if p_invoice_rec.party_site_id is not null and p_invoice_rec.vendor_site_id is null then
    p_invoice_rec.vendor_site_id := -1 * p_invoice_rec.application_id;
  end if;

  -- Bug 7871425.

  IF (nvl(p_invoice_rec.invoice_type_lookup_code, 'STANDARD') = 'EXPENSE REPORT'
      AND p_invoice_rec.party_site_id is null) THEN

    select vendor_type_lookup_code into l_vendor_type_lookup_code
    from ap_suppliers where vendor_id = p_invoice_rec.vendor_id ;

  END IF ;

  -- Bug 7871425.
  -- Populate the party_site_id for expense reports created for non-employee
  -- type suppliers. Now party site id will be populated if invoice type is
  -- EXPENSE REPORT and vendor type is not EMPLOYEE.

  --if we just have vendor info then also populate the party info
  if p_invoice_rec.vendor_site_id is not null and p_invoice_rec.party_site_id is null
     and (nvl(p_invoice_rec.invoice_type_lookup_code, 'STANDARD') <> 'EXPENSE REPORT'
     or(nvl(p_invoice_rec.invoice_type_lookup_code, 'STANDARD') = 'EXPENSE REPORT'
        and nvl(l_vendor_type_lookup_code, 'VENDOR') <> 'EMPLOYEE')) then
    Begin
      select party_site_id
      into p_invoice_rec.party_site_id
      from po_vendor_sites
      where vendor_site_id = p_invoice_rec.vendor_site_id;
    Exception
      when no_data_found then
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
             (AP_IMPORT_INVOICES_PKG.g_invoices_table,
              p_invoice_rec.invoice_id,
              'INCONSISTENT SUPPL SITE',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                          'insert_rejections<-'
                                          ||current_calling_sequence);
        END IF;
        RAISE vendor_party_failure;  --bug6367302
      END IF;
      --RAISE vendor_party_failure;
    End;
  end if;

  if p_invoice_rec.vendor_id is not null and p_invoice_rec.party_id is null then
    Begin
      select party_id
      into p_invoice_rec.party_id
      from po_vendors
      where vendor_id = p_invoice_rec.vendor_id;
    Exception
      when no_data_found then
      IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
             (AP_IMPORT_INVOICES_PKG.g_invoices_table,
              p_invoice_rec.invoice_id,
              'INCONSISTENT SUPPLIER',
              p_default_last_updated_by,
              p_default_last_update_login,
              current_calling_sequence) <> TRUE) THEN
        IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
            AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
                                          'insert_rejections<-'
                                          ||current_calling_sequence);
        END IF;
        RAISE vendor_party_failure;  --bug6367302
      END IF;
      --RAISE vendor_party_failure;
    End;
  end if;



  p_current_invoice_status := l_current_invoice_status;
  return(true);

EXCEPTION
  WHEN OTHERS THEN
		IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
			AP_IMPORT_UTILITIES_PKG.Print(
				AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
		END IF;

		IF (SQLCODE < 0) THEN
			IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
				AP_IMPORT_UTILITIES_PKG.Print(
					AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
			END IF;
		END IF;
		RETURN(FALSE);
end v_check_party_vendor;


--bugfix:5565310
FUNCTION v_check_line_get_po_tax_attr(
		-- bug 8495005 : Changed IN as IN OUT NOCOPY for p_invoice_rec parameter
		p_invoice_rec IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
                p_invoice_lines_rec IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_line_info_rec,
	        p_calling_sequence IN VARCHAR2) return boolean  IS

 l_ref_doc_application_id      zx_transaction_lines_gt.ref_doc_application_id%TYPE;
 l_ref_doc_entity_code         zx_transaction_lines_gt.ref_doc_entity_code%TYPE;
 l_ref_doc_event_class_code    zx_transaction_lines_gt.ref_doc_event_class_code%TYPE;
 l_ref_doc_line_quantity       zx_transaction_lines_gt.ref_doc_line_quantity%TYPE;
 l_po_header_curr_conv_rat     po_headers_all.rate%TYPE;
 l_ref_doc_trx_level_type      zx_transaction_lines_gt.ref_doc_trx_level_type%TYPE;
 l_po_header_curr_conv_rate    po_headers_all.rate%TYPE;
 l_uom_code                    mtl_units_of_measure.uom_code%TYPE;
 l_ref_doc_trx_id              po_headers_all.po_header_id%TYPE;
 l_error_code                  varchar2(2000);
 current_calling_sequence VARCHAR2(2000);
 l_success		       boolean;
 l_intended_use                  zx_lines_det_factors.line_intended_use%type;
 l_product_type                  zx_lines_det_factors.product_type%type;
 l_product_category              zx_lines_det_factors.product_category%type;
 l_product_fisc_class            zx_lines_det_factors.product_fisc_classification%type;
 l_user_defined_fisc_class       zx_lines_det_factors.user_defined_fisc_class%type;
 l_assessable_value              zx_lines_det_factors.assessable_value%type;
 l_dflt_tax_class_code           zx_transaction_lines_gt.input_tax_classification_code%type;
 l_dummy			 number;
 debug_info			 varchar2(1000);
   -- bug 8495005 fix starts
 l_taxation_country	zx_lines_det_factors.default_taxation_country%type;
 l_trx_biz_category	zx_lines_det_factors.trx_business_category%type;
 -- bug 8495005 fix ends

 -- bug 8483345: start
 l_product_org_id              ap_invoices.org_id%TYPE;
 l_allow_tax_code_override     varchar2(10);
 l_dflt_tax_class_code2         zx_transaction_lines_gt.input_tax_classification_code%type;
 -- bug 8483345: end
BEGIN


    IF (p_invoice_lines_rec.primary_intended_use IS NULL OR
        p_invoice_lines_rec.product_fisc_classification IS NULL OR
	p_invoice_lines_rec.product_type IS NULL OR
	p_invoice_lines_rec.product_category IS NULL OR
	p_invoice_lines_rec.user_defined_fisc_class IS NULL OR
	p_invoice_lines_rec.assessable_value IS NULL OR
	p_invoice_lines_rec.tax_classification_code IS NULL OR
	-- bug 8495005 fix starts
	p_invoice_rec.taxation_country IS NULL OR
	p_invoice_lines_rec.trx_business_category IS NULL
	-- bug 8495005 fix ends
	) THEN

	debug_info := 'Call Ap_Etx_Utility_Pkg.Get_PO_Info';
	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
	                                      debug_info);
        END IF;

        l_success := AP_ETAX_UTILITY_PKG.Get_PO_Info(
	                  P_Po_Line_Location_Id         => p_invoice_lines_rec.po_line_location_id,
			  P_PO_Distribution_Id          => null,
			  P_Application_Id              => l_ref_doc_application_id,
			  P_Entity_code                 => l_ref_doc_entity_code,
			  P_Event_Class_Code            => l_ref_doc_event_class_code,
			  P_PO_Quantity                 => l_ref_doc_line_quantity,
			  P_Product_Org_Id              => l_product_org_id, -- 8483345
			  P_Po_Header_Id                => l_ref_doc_trx_id,
			  P_Po_Header_curr_conv_rate    => l_po_header_curr_conv_rate,
			  P_Uom_Code                    => l_uom_code,
			  P_Dist_Qty                    => l_dummy,
			  P_Ship_Price                  => l_dummy,
			  P_Error_Code                  => l_error_code,
			  P_Calling_Sequence            => current_calling_sequence);

	          -- bug 8483345: start
 	     debug_info := 'Get Default Tax Classification';
 	     IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
 	             AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch, debug_info);
 	     END IF;

 	     ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification
 	                     (p_ref_doc_application_id           => l_ref_doc_application_id,
 	                      p_ref_doc_entity_code              => l_ref_doc_entity_code,
 	                      p_ref_doc_event_class_code         => l_ref_doc_event_class_code,
 	                      p_ref_doc_trx_id                   => l_ref_doc_trx_id,
 	                      p_ref_doc_line_id                  => p_invoice_lines_rec.po_line_location_id,
 	                      p_ref_doc_trx_level_type           => 'SHIPMENT',
 	                      p_vendor_id                        => p_invoice_rec.vendor_id,
 	                      p_vendor_site_id                   => p_invoice_rec.vendor_site_id,
 	                      p_code_combination_id              => p_invoice_lines_rec.dist_code_combination_id,
 	                      p_concatenated_segments            => null,
 	                      p_templ_tax_classification_cd      => null,
 	                      p_ship_to_location_id              => null,
 	                      p_ship_to_loc_org_id               => null,
 	                      p_inventory_item_id                => null,
 	                      p_item_org_id                      => l_product_org_id,
 	                      p_tax_classification_code          => l_dflt_tax_class_code,
 	                      p_allow_tax_code_override_flag     => l_allow_tax_code_override,
 	                      APPL_SHORT_NAME                    => 'SQLAP',
 	                      FUNC_SHORT_NAME                    => 'NONE',
 	                      p_calling_sequence                 => 'AP_ETAX_SERVICES_PKG',
 	                      p_event_class_code                 => l_ref_doc_event_class_code,
 	                      p_entity_code                      => 'AP_INVOICES',
 	                      p_application_id                   => 200,
 	                      p_internal_organization_id         => p_invoice_lines_rec.org_id);
 	          -- bug 8483345: end

	 debug_info := 'Call ap_etx_servies_pkg.get_po_tax_attributes';
	 IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	     AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
	                                       debug_info);
         END IF;

	-- bug 8495005 fix starts
	 IF (p_invoice_rec.source = 'ERS') THEN
		 AP_Etax_Services_Pkg.Get_Po_Tax_Attributes(
				  p_application_id              => l_ref_doc_application_id,
				  p_org_id                      => p_invoice_lines_rec.org_id,
				  p_entity_code                 => l_ref_doc_entity_code,
				  p_event_class_code            => l_ref_doc_event_class_code,
				  p_trx_level_type              => 'SHIPMENT',
				  p_trx_id                      => l_ref_doc_trx_id,
				  p_trx_line_id                 => p_invoice_lines_rec.po_line_location_id,
				  x_line_intended_use           => l_intended_use,
				  x_product_type                => l_product_type,
				  x_product_category            => l_product_category,
				  x_product_fisc_classification => l_product_fisc_class,
				  x_user_defined_fisc_class     => l_user_defined_fisc_class,
				  x_assessable_value            => l_assessable_value,
				  x_tax_classification_code     => l_dflt_tax_class_code2, -- bug 8483345
				  x_taxation_country		=> l_taxation_country,
				  x_trx_biz_category		=> l_trx_biz_category
				  );
	 ELSE
		 AP_Etax_Services_Pkg.Get_Po_Tax_Attributes(
				  p_application_id              => l_ref_doc_application_id,
				  p_org_id                      => p_invoice_lines_rec.org_id,
				  p_entity_code                 => l_ref_doc_entity_code,
				  p_event_class_code            => l_ref_doc_event_class_code,
				  p_trx_level_type              => 'SHIPMENT',
				  p_trx_id                      => l_ref_doc_trx_id,
				  p_trx_line_id                 => p_invoice_lines_rec.po_line_location_id,
				  x_line_intended_use           => l_intended_use,
				  x_product_type                => l_product_type,
				  x_product_category            => l_product_category,
				  x_product_fisc_classification => l_product_fisc_class,
				  x_user_defined_fisc_class     => l_user_defined_fisc_class,
				  x_assessable_value            => l_assessable_value,
				  x_tax_classification_code     => l_dflt_tax_class_code2 -- bug 8483345
				  );
  	 END IF;
	 -- bug 8495005 fix ends

      -- bug 8483345: start
         -- if tax classification code not retrieved from hierarchy
         -- retrieve it from PO
         IF (l_dflt_tax_class_code is null) THEN
             l_dflt_tax_class_code := l_dflt_tax_class_code2;
         END IF;
      -- bug 8483345: end

	  debug_info := 'populate the lines record with tax attr info';
	  IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
	        AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
	                                         debug_info);
	  END IF;

          IF (p_invoice_lines_rec.primary_intended_use IS NULL) THEN
              p_invoice_lines_rec.primary_intended_use := l_intended_use;
	  END IF;

	  IF (p_invoice_lines_rec.product_type IS NULL) THEN
	      p_invoice_lines_rec.product_type := l_product_type;
	  END IF;

	  IF (p_invoice_lines_rec.product_category IS NULL) THEN
	      p_invoice_lines_rec.product_category := l_product_category;
	  END IF;

	  IF (p_invoice_lines_rec.product_fisc_classification IS NULL) THEN
	      p_invoice_lines_rec.product_fisc_classification:= l_product_fisc_class;
	  END IF;

	  IF (p_invoice_lines_rec.USER_DEFINED_FISC_CLASS IS NULL) THEN
	    p_invoice_lines_rec.USER_DEFINED_FISC_CLASS := l_user_defined_fisc_class;
	  END IF;

	  IF (p_invoice_lines_rec.assessable_value IS NULL) THEN
	     p_invoice_lines_rec.assessable_value := l_assessable_value;
	  END IF;

	  IF (p_invoice_lines_rec.tax_classification_code IS NULL) THEN
	      p_invoice_lines_rec.tax_classification_code := l_dflt_tax_class_code;
	  END IF;

	  -- bug 8495005 fix starts
	  IF (p_invoice_rec.source = 'ERS') THEN
		IF (p_invoice_rec.taxation_country IS NULL) THEN
		   p_invoice_rec.taxation_country := l_taxation_country;
		END IF;

		IF (p_invoice_lines_rec.trx_business_category IS NULL) THEN
		   p_invoice_lines_rec.trx_business_category := l_trx_biz_category;
		END IF;
	  END IF;
	  -- bug 8495005 fix ends

    END IF;

   return(true);

EXCEPTION
  WHEN OTHERS THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
       END IF;

  IF (SQLCODE < 0) THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
     END IF;
  END IF;
  RETURN(FALSE);


END v_check_line_get_po_tax_attr;

--bug# 6989166 starts
FUNCTION v_check_ship_to_location_code(
		p_invoice_rec	IN  AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
		p_invoice_line_rec  IN AP_IMPORT_INVOICES_PKG.r_line_info_rec,
                p_default_last_updated_by      IN            NUMBER,
		p_default_last_update_login    IN            NUMBER,
		p_current_invoice_status	IN OUT NOCOPY VARCHAR2,
	        p_calling_sequence IN VARCHAR2) return boolean  IS

  Cursor c_ship_to_location (p_ship_to_loc_code HR_LOCATIONS.LOCATION_CODE%TYPE) Is
  Select ship_to_location_id
  From   hr_locations
  Where  location_code = p_ship_to_loc_code
  and	nvl(ship_to_site_flag, 'N') = 'Y';

  l_ship_to_location_id  ap_supplier_sites_all.ship_to_location_id%type;
  current_calling_sequence VARCHAR2(2000);
  debug_info			 varchar2(1000);
  ship_to_location_code_failure EXCEPTION;
  l_current_invoice_status    VARCHAR2(1) := 'Y';

BEGIN

	current_calling_sequence := 'AP_IMPORT_VALIDATION_PKG.v_check_ship_to_location_code<-'
				||P_calling_sequence;
	debug_info := 'Check valid ship to location code';


 	Open  c_ship_to_location (p_invoice_line_rec.ship_to_location_code);
	Fetch c_ship_to_location
	Into  l_ship_to_location_id;


	IF (c_ship_to_location%NOTFOUND) THEN
		IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
			(AP_IMPORT_INVOICES_PKG.g_invoices_table,
						p_invoice_rec.invoice_id,
						'INVALID LOCATION CODE',
					        p_default_last_updated_by,
						p_default_last_update_login,
						current_calling_sequence) <> TRUE) THEN

			IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
			    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
							  'insert_rejections<-'
							  ||current_calling_sequence);

		        END IF;

			Close c_ship_to_location;
			RAISE ship_to_location_code_failure;

		END IF;
		l_current_invoice_status := 'N';
	END IF;

   Close c_ship_to_location;

   p_current_invoice_status := l_current_invoice_status;

   return(true);

EXCEPTION
  WHEN OTHERS THEN
      IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
           AP_IMPORT_UTILITIES_PKG.Print(
               AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
       END IF;

  IF (SQLCODE < 0) THEN
    IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
        AP_IMPORT_UTILITIES_PKG.Print(
            AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
     END IF;
  END IF;
  RETURN(FALSE);


END v_check_ship_to_location_code;
--bug# 6989166 ends

FUNCTION v_check_invalid_remit_supplier(
             p_invoice_rec      IN OUT NOCOPY AP_IMPORT_INVOICES_PKG.r_invoice_info_rec,
             p_default_last_updated_by     IN            NUMBER,
             p_default_last_update_login   IN            NUMBER,
             p_current_invoice_status      IN OUT NOCOPY VARCHAR2,
             p_calling_sequence           IN            VARCHAR2)
    RETURN BOOLEAN IS

  current_calling_sequence VARCHAR2(2000);
  debug_info			varchar2(1000);

  l_remit_supplier_name       VARCHAR2(240) := NULL;
  l_remit_supplier_id            NUMBER := NULL;
  l_remit_supplier_num            VARCHAR2(30) := NULL;
  l_remit_supplier_site         VARCHAR2(240) := NULL;
  l_remit_supplier_site_id     NUMBER := NULL;
  l_remit_party_id            NUMBER := NULL;
  l_remit_party_site_id            NUMBER := NULL;
  l_relationship_id           NUMBER;
  l_result                    VARCHAR2(25);

  --bug 8345877
  l_dummy_flag VARCHAR2(1);

  invalid_remit_supplier_failure  EXCEPTION;

  /* Added for bug#9852174 Start */
  TYPE refcurtyp IS REF CURSOR;
  refcur         REFCURTYP;
  l_sql_stmt     LONG;
  /* Added for bug#9852174 End */

BEGIN
	current_calling_sequence := 'AP_IMPORT_VALIDATION_PKG.v_check_invalid_remit_supplier<-'
					      ||P_calling_sequence;

	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
		debug_info := 'Check valid remit to supplier details';
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);

		debug_info := 'Remit to supplier Name '||p_invoice_rec.remit_to_supplier_name;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);

		debug_info := 'Remit to supplier Id '||p_invoice_rec.remit_to_supplier_id;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);

		debug_info := 'Remit to supplier Site Id '||p_invoice_rec.remit_to_supplier_site_id;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);

		debug_info := 'Remit to supplier Site Name '||p_invoice_rec.remit_to_supplier_site;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);
	END IF;

	If(p_invoice_rec.remit_to_supplier_name IS NOT NULL) then
		BEGIN
			select vendor_name
			into l_remit_supplier_name
			from ap_suppliers
			where vendor_name = p_invoice_rec.remit_to_supplier_name
			-- bug 8504185
			AND nvl(trunc(START_DATE_ACTIVE),
				AP_IMPORT_INVOICES_PKG.g_inv_sysdate)
				<= AP_IMPORT_INVOICES_PKG.g_inv_sysdate
			AND nvl(trunc(END_DATE_ACTIVE),
				AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
				> AP_IMPORT_INVOICES_PKG.g_inv_sysdate;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				BEGIN
					SELECT party_name
					INTO l_remit_supplier_name
					FROM hz_parties
					WHERE party_name = p_invoice_rec.remit_to_supplier_name;
				EXCEPTION
					WHEN NO_DATA_FOUND THEN
						IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
										AP_IMPORT_INVOICES_PKG.g_invoices_table,
										p_invoice_rec.invoice_id,
										'INVALID REMIT TO SUPPLIER NAME',
										p_default_last_updated_by,
										p_default_last_update_login,
										current_calling_sequence) <> TRUE) THEN
						   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
							AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
							'insert_rejections<-'||current_calling_sequence);
						   END IF;

						END IF;

						RAISE invalid_remit_supplier_failure;
				END;
		END;
	END IF;

	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
		debug_info := 'If Remit to supplier Name '||l_remit_supplier_name;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);
	END IF;

	if(p_invoice_rec.remit_to_supplier_id IS NOT NULL) then
		BEGIN
			select vendor_id
			into l_remit_supplier_id
			from ap_suppliers
			where vendor_id = p_invoice_rec.remit_to_supplier_id
			-- bug 8504185
			AND nvl(trunc(START_DATE_ACTIVE),
				AP_IMPORT_INVOICES_PKG.g_inv_sysdate)
				<= AP_IMPORT_INVOICES_PKG.g_inv_sysdate
			AND nvl(trunc(END_DATE_ACTIVE),
				AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
				> AP_IMPORT_INVOICES_PKG.g_inv_sysdate;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
								AP_IMPORT_INVOICES_PKG.g_invoices_table,
								p_invoice_rec.invoice_id,
								 'INVALID REMIT TO SUPPLIER ID',
								p_default_last_updated_by,
								p_default_last_update_login,
								current_calling_sequence) <> TRUE) THEN
				   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
					AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					'insert_rejections<-'||current_calling_sequence);
				   END IF;

				END IF;

				RAISE invalid_remit_supplier_failure;
		END;
	END IF;

	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
		debug_info := 'If Remit to supplier Id '||l_remit_supplier_id;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);
	END IF;

	if(p_invoice_rec.remit_to_supplier_num IS NOT NULL) then
		BEGIN
			select segment1
			into l_remit_supplier_num
			from ap_suppliers
			where segment1= p_invoice_rec.remit_to_supplier_num	-- bug 7836976
			-- bug 8504185
			AND nvl(trunc(START_DATE_ACTIVE),
				AP_IMPORT_INVOICES_PKG.g_inv_sysdate)
				<= AP_IMPORT_INVOICES_PKG.g_inv_sysdate
			AND nvl(trunc(END_DATE_ACTIVE),
				AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
				> AP_IMPORT_INVOICES_PKG.g_inv_sysdate;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
								AP_IMPORT_INVOICES_PKG.g_invoices_table,
								p_invoice_rec.invoice_id,
								 'INVALID REMIT TO SUPPLIER NUM',
								p_default_last_updated_by,
								p_default_last_update_login,
								current_calling_sequence) <> TRUE) THEN
				   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
					AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					'insert_rejections<-'||current_calling_sequence);
				   END IF;

				END IF;

				RAISE invalid_remit_supplier_failure;
		END;
	END IF;

	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
		debug_info := 'Remit to supplier Num '||l_remit_supplier_num;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);
	END IF;

	--BEGIN
		--bug 8474864
		If NOT (p_invoice_rec.remit_to_supplier_id is NULL and
			p_invoice_rec.remit_to_supplier_name is NULL and
			p_invoice_rec.remit_to_supplier_num is NULL) THEN

              /* Added for bug#9852174 Start */
              l_sql_stmt := ' SELECT party_id FROM ap_suppliers ' ||
                            '  WHERE nvl(trunc(START_DATE_ACTIVE), :p_inv_sysdate ) <= :p_inv_sysdate'||
		            '    AND nvl(trunc(END_DATE_ACTIVE),:p_inv_sysdate +1) > :p_inv_sysdate';

              IF p_invoice_rec.remit_to_supplier_id IS NOT NULL
              THEN
                 l_sql_stmt := l_sql_stmt || ' AND vendor_id = :p_remit_to_supplier_id';
              ELSE
                 l_sql_stmt := l_sql_stmt || ' AND nvl(:p_remit_to_supplier_id, -9999) = -9999 ';
              END IF;

              IF p_invoice_rec.remit_to_supplier_name IS NOT NULL
              THEN
                 l_sql_stmt := l_sql_stmt || ' AND vendor_name = :p_remit_to_supplier_name';
              ELSE
                 l_sql_stmt := l_sql_stmt || ' AND nvl(:p_remit_to_supplier_name, -9999) = -9999 ';
              END IF;

              IF p_invoice_rec.remit_to_supplier_num IS NOT NULL
              THEN
                 l_sql_stmt := l_sql_stmt || ' AND SEGMENT1 = :p_remit_to_supplier_num';
              ELSE
                 l_sql_stmt := l_sql_stmt || ' AND nvl(:p_remit_to_supplier_num, -9999) = -9999 ';
              END IF;

              OPEN refcur FOR l_sql_stmt
                USING AP_IMPORT_INVOICES_PKG.g_inv_sysdate
                    , AP_IMPORT_INVOICES_PKG.g_inv_sysdate
                    , AP_IMPORT_INVOICES_PKG.g_inv_sysdate
                    , AP_IMPORT_INVOICES_PKG.g_inv_sysdate
                    , p_invoice_rec.remit_to_supplier_id
                    , p_invoice_rec.remit_to_supplier_name
                    , p_invoice_rec.remit_to_supplier_num;

              FETCH refcur
               INTO l_remit_party_id;

              IF refcur%rowcount = 0
              THEN
		IF (AP_IMPORT_UTILITIES_PKG.insert_rejections
		       ( AP_IMPORT_INVOICES_PKG.g_invoices_table,
			 p_invoice_rec.invoice_id,
			 'INCONSISTENT REMIT SUPPLIER',
			 p_default_last_updated_by,
			 p_default_last_update_login,
			 current_calling_sequence) <> TRUE)
		THEN
		   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
			AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
			'insert_rejections<-'||current_calling_sequence);
		   END IF;
		END IF;
		RAISE invalid_remit_supplier_failure;
              END IF;
              /* Added for bug#9852174 End */

              /* Commented for bug#9852174 Start
				-- bug 8504185
				SELECT party_id
				INTO l_remit_party_id
				FROM ap_suppliers
				WHERE vendor_id = nvl(p_invoice_rec.remit_to_supplier_id,vendor_id)
				AND vendor_name = nvl(p_invoice_rec.remit_to_supplier_name,vendor_name)
				AND SEGMENT1 = nvl(p_invoice_rec.remit_to_supplier_num,SEGMENT1)
				-- bug 8504185
				AND nvl(trunc(START_DATE_ACTIVE),
					AP_IMPORT_INVOICES_PKG.g_inv_sysdate)
					<= AP_IMPORT_INVOICES_PKG.g_inv_sysdate
				AND nvl(trunc(END_DATE_ACTIVE),
					AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
					> AP_IMPORT_INVOICES_PKG.g_inv_sysdate;
              Commented for bug#9852174 End */
		 END IF;
        /* Commented for bug#9852174 Start
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
							AP_IMPORT_INVOICES_PKG.g_invoices_table,
							p_invoice_rec.invoice_id,
							 'INCONSISTENT REMIT SUPPLIER',
							p_default_last_updated_by,
							p_default_last_update_login,
							current_calling_sequence) <> TRUE) THEN
			   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
				AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
				'insert_rejections<-'||current_calling_sequence);
			   END IF;

			END IF;

			RAISE invalid_remit_supplier_failure;
	END;
	Commented for bug#9852174 End */

	if(p_invoice_rec.remit_to_supplier_site_id IS NOT NULL) then
		BEGIN
			select vendor_site_id
			into l_remit_supplier_site_id
			from ap_supplier_sites_all
			where vendor_site_id = p_invoice_rec.remit_to_supplier_site_id
			and org_id = p_invoice_rec.org_id;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
								AP_IMPORT_INVOICES_PKG.g_invoices_table,
								p_invoice_rec.invoice_id,
								'INVALID REMIT TO SUPP SITE ID',
								p_default_last_updated_by,
								p_default_last_update_login,
								current_calling_sequence) <> TRUE) THEN
				   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
					AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					'insert_rejections<-'||current_calling_sequence);
				   END IF;

				END IF;

				RAISE invalid_remit_supplier_failure;
		END;
	END IF;

	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
		debug_info := 'Remit to supplier Site Id '||l_remit_supplier_site_id;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);
	END IF;

	if(p_invoice_rec.remit_to_supplier_site IS NOT NULL) then
		BEGIN
			If (l_remit_supplier_site_id IS NOT NULL) then
				select vendor_site_code
				 into l_remit_supplier_site
				from ap_supplier_sites_all
				where vendor_site_code = p_invoice_rec.remit_to_supplier_site
				and org_id = p_invoice_rec.org_id
				and vendor_site_id = p_invoice_rec.remit_to_supplier_site_id;
			elsif(l_remit_supplier_id IS NOT NULL) then
				select vendor_site_code
				 into l_remit_supplier_site
				from ap_supplier_sites_all
				where vendor_site_code = p_invoice_rec.remit_to_supplier_site
				and org_id = p_invoice_rec.org_id
				and vendor_id = p_invoice_rec.remit_to_supplier_id;
			elsif(l_remit_supplier_num IS NOT NULL) then
				select a.vendor_site_code
				 into l_remit_supplier_site
				from ap_supplier_sites_all a,
					ap_suppliers b
				where a.vendor_site_code = p_invoice_rec.remit_to_supplier_site
				and a.org_id = p_invoice_rec.org_id
				and a.vendor_id = b.vendor_id
				and b.segment1 = p_invoice_rec.remit_to_supplier_num;
			elsif(l_remit_supplier_name IS NOT NULL) then
				select a.vendor_site_code
				 into l_remit_supplier_site
				from ap_supplier_sites_all a,
					ap_suppliers b
				where a.vendor_site_code = p_invoice_rec.remit_to_supplier_site
				and a.org_id = p_invoice_rec.org_id
				and a.vendor_id = b.vendor_id
				and b.vendor_name = p_invoice_rec.remit_to_supplier_name;
			end if;

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
								AP_IMPORT_INVOICES_PKG.g_invoices_table,
								p_invoice_rec.invoice_id,
								'INVALID REMIT TO SUPPLIER SITE',
								p_default_last_updated_by,
								p_default_last_update_login,
								current_calling_sequence) <> TRUE) THEN
				   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
					AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					'insert_rejections<-'||current_calling_sequence);
				   END IF;

				END IF;

				RAISE invalid_remit_supplier_failure;
		END;
	END IF;

	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
		debug_info := 'Remit to supplier Site '||l_remit_supplier_site;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);

		debug_info := 'Data To IBY ';
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);

		debug_info := 'Party Id '||p_invoice_rec.party_id;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);

		debug_info := 'Vendor Site id '||p_invoice_rec.vendor_site_id;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);

		debug_info := 'Invoice Date '||p_invoice_rec.invoice_date;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);
	END IF;

	/* commented below code as part of bug 8504185
	IF (p_invoice_rec.remit_to_supplier_id is not null and p_invoice_rec.remit_to_supplier_id > 0) THEN
		SELECT party_id
		INTO l_remit_party_id
		FROM ap_suppliers
		WHERE vendor_id = p_invoice_rec.remit_to_supplier_id
		-- bug 8504185
		AND nvl(trunc(START_DATE_ACTIVE),
			AP_IMPORT_INVOICES_PKG.g_inv_sysdate)
			<= AP_IMPORT_INVOICES_PKG.g_inv_sysdate
		AND nvl(trunc(END_DATE_ACTIVE),
			AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
			> AP_IMPORT_INVOICES_PKG.g_inv_sysdate;
	ELS*/IF (p_invoice_rec.remit_to_supplier_name is not null) THEN
		BEGIN
			SELECT party_id
			INTO l_remit_party_id
			FROM ap_suppliers
			WHERE vendor_name = p_invoice_rec.remit_to_supplier_name
			-- bug 8504185
			AND nvl(trunc(START_DATE_ACTIVE),
				AP_IMPORT_INVOICES_PKG.g_inv_sysdate)
				<= AP_IMPORT_INVOICES_PKG.g_inv_sysdate
			AND nvl(trunc(END_DATE_ACTIVE),
				AP_IMPORT_INVOICES_PKG.g_inv_sysdate+1)
				> AP_IMPORT_INVOICES_PKG.g_inv_sysdate;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				SELECT party_id
				INTO l_remit_party_id
				FROM hz_parties
				WHERE party_name = p_invoice_rec.remit_to_supplier_name;
		END;
	END IF;

	IF (p_invoice_rec.remit_to_supplier_site_id is null and p_invoice_rec.remit_to_supplier_site is not null) THEN
		SELECT vendor_site_id
		INTO l_remit_supplier_site_id
		FROM ap_supplier_sites_all
		WHERE org_id = p_invoice_rec.org_id
		AND vendor_site_code = p_invoice_rec.remit_to_supplier_site;
	END IF;

	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
		debug_info := 'Remit Party Id '||l_remit_party_id;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);

		debug_info := 'Remit Supplier Site Id '||l_remit_supplier_site_id;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);
	END IF;

	l_relationship_id := p_invoice_rec.relationship_id;	-- bug 8224788

	IBY_EXT_PAYEE_RELSHIPS_PKG.import_Ext_Payee_Relationship(
		p_party_id => p_invoice_rec.party_id,
		p_supplier_site_id => p_invoice_rec.vendor_site_id,
		p_date => p_invoice_rec.invoice_date,
		x_result => l_result,
		x_remit_party_id => l_remit_party_id,
		x_remit_supplier_site_id => l_remit_supplier_site_id,
		x_relationship_id => l_relationship_id
		);

	IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
		debug_info := 'Data From IBY ';
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);

		debug_info := 'x_result : ' || l_result;
		AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
					  debug_info);
	END IF;

	IF (l_result = FND_API.G_TRUE) THEN
		IF (l_relationship_id <> -1) THEN	-- bug 8345877
		-- Bug 7675510
		-- Added AND condition so as to Select data from ap_supplier_sites_all when
		-- l_remit_supplier_site_id is having a Positive value
		-- Negative value of l_remit_supplier_site_id does not have any data in ap_supplier_sites_all
		-- This negative value is assigned to p_invoice_rec.vendor_site_id in
		-- FUNCTION v_check_party_vendor earlier in this package

		   IF (l_remit_supplier_site_id is not null AND
			l_remit_supplier_site_id > 0) THEN
		-- Bug 7675510 ends
			SELECT vendor_site_id, vendor_site_code
			INTO l_remit_supplier_site_id, l_remit_supplier_site
			FROM ap_supplier_sites_all
			WHERE vendor_site_id = l_remit_supplier_site_id
			and org_id = p_invoice_rec.org_id;
		   END IF;

		   p_invoice_rec.remit_to_supplier_site_id := l_remit_supplier_site_id;
		   p_invoice_rec.remit_to_supplier_site := l_remit_supplier_site;

		   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
			   debug_info := 'Invoice Type Lookup Code '||p_invoice_rec.invoice_type_lookup_code;
			    AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
						     debug_info);
		   END IF;

		-- Bug 7675510
		-- Added the invoice_type_lookup_code condition to populate the l_remit_supplier_id,
		-- l_remit_supplier_name, l_remit_supplier_num from HZ_PARTIES table in case of PAYMENT REQUEST
		-- since the data is not available in AP_SUPPLIERS table for PAYMENT REQUEST type


		  -- commented below IF part as part of bug 8345877.
		  -- After TPP re-modelling, remit to supplier fields need not be populated.
		  -- Since, payment request type of invoices will not have any relationships
		  -- and expected to have the same trading partner values in remit to supplier fields,
		  -- we need not derive the other values based on values returned from IBY API.

		   /*IF (p_invoice_rec.invoice_type_lookup_code = 'PAYMENT REQUEST') THEN

			IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
				AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
			END IF;

			IF (l_remit_party_id is not null) THEN
			    --Bug 7860631 Removed the party_id field into the supplier_id field.
				SELECT party_name, party_number
				INTO   l_remit_supplier_name, l_remit_supplier_num
				FROM hz_parties
				WHERE party_id = l_remit_party_id;
			   --Bug 7860631 Defaulting the remit_supplier_id from the invoice
			   l_remit_supplier_id :=p_invoice_rec.vendor_id;
			END IF;

		   ELSE*/

		   -- bug 7629217 starts- dcshanmu - changed l_party_id to l_remit_party_id
			   IF (l_remit_party_id is not null) THEN
				SELECT vendor_id, vendor_name, segment1
				INTO l_remit_supplier_id, l_remit_supplier_name, l_remit_supplier_num
				FROM ap_suppliers
				WHERE party_id = l_remit_party_id;
			END IF;
		   -- bug 7629217 starts- dcshanmu ends

		   --END IF ;
		   -- commented above END IF as part of bug 8345877
		-- Bug 7675510 ends

		   p_invoice_rec.remit_to_supplier_id := l_remit_supplier_id;
		   p_invoice_rec.remit_to_supplier_name := l_remit_supplier_name;
		   p_invoice_rec.remit_to_supplier_num := l_remit_supplier_num;
		   p_invoice_rec.relationship_id := l_relationship_id;

		   p_current_invoice_status := 'Y';

		   -- bug 8497933
		   IF (l_is_inv_date_null = 'Y') THEN
			p_invoice_rec.payment_method_code := null;
			p_invoice_rec.payment_reason_code := null;
			p_invoice_rec.bank_charge_bearer := null;
			p_invoice_rec.delivery_channel_code := null;
			p_invoice_rec.settlement_priority := null;
			p_invoice_rec.exclusive_payment_flag := null;
			p_invoice_rec.external_bank_account_id := null;
			p_invoice_rec.payment_reason_comments := null;
		   END IF;
		   -- bug 8497933

		   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
			   debug_info := 'Remit To Party Id  '||l_remit_party_id;
			   AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
						     debug_info);

			   debug_info := 'Remit To Supplier Id '||l_remit_supplier_id;
			   AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
						     debug_info);

			   debug_info := 'Remit To Supplier '||l_remit_supplier_name;
			   AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
						     debug_info);

			   debug_info := 'Remit To Supplier Num '||l_remit_supplier_num;
			   AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
						    debug_info);

			   debug_info := 'Relationship Id '||l_relationship_id;
			   AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
						     debug_info);
		   END IF;

		ELSE		-- if relationship_id <> -1 -- bug 8345877
			p_invoice_rec.remit_to_supplier_id := null;
			p_invoice_rec.remit_to_supplier_name := null;
			p_invoice_rec.remit_to_supplier_num := null;
			p_invoice_rec.remit_to_supplier_site_id := null;
			p_invoice_rec.remit_to_supplier_site := null;
			p_invoice_rec.relationship_id := null;
		END IF; -- if relationship_id <> -1 -- bug 8345877

	ELSE

	    IF (AP_IMPORT_UTILITIES_PKG.insert_rejections(
						AP_IMPORT_INVOICES_PKG.g_invoices_table,
						p_invoice_rec.invoice_id,
						'INVALID THIRD PARTY RELATION',
						p_default_last_updated_by,
						p_default_last_update_login,
						current_calling_sequence) <> TRUE) THEN
		   IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') then
			AP_IMPORT_UTILITIES_PKG.Print(AP_IMPORT_INVOICES_PKG.g_debug_switch,
			'insert_rejections<-'||current_calling_sequence);
		   END IF;
	    END IF;

	    RAISE invalid_remit_supplier_failure;
	END IF;

	RETURN TRUE;

EXCEPTION
	WHEN invalid_remit_supplier_failure THEN

		p_current_invoice_status := 'N';
		RETURN FALSE;
	WHEN OTHERS THEN
		p_current_invoice_status := 'N';

		IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
		   AP_IMPORT_UTILITIES_PKG.Print(
		       AP_IMPORT_INVOICES_PKG.g_debug_switch,debug_info);
		END IF;

		IF (SQLCODE < 0) THEN
			IF (AP_IMPORT_INVOICES_PKG.g_debug_switch = 'Y') THEN
			AP_IMPORT_UTILITIES_PKG.Print(
			    AP_IMPORT_INVOICES_PKG.g_debug_switch, SQLERRM);
			END IF;
		END IF;
		RETURN FALSE;

END v_check_invalid_remit_supplier;

END AP_IMPORT_VALIDATION_PKG;

/
