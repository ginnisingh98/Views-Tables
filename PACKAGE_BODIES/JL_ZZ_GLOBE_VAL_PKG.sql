--------------------------------------------------------
--  DDL for Package Body JL_ZZ_GLOBE_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_GLOBE_VAL_PKG" AS
/* $Header: jlzzglvb.pls 120.4 2005/10/30 02:05:51 appldev ship $ */

--
-- Procedure Name:
--   count_void_trx_type
-- Called From
--   RAXSUCTT_ZZ_RA_CUST_TTYPES_BV
-- Purpose
--   Return the number of Void Transaction Types
--
  FUNCTION  count_void_trx_type(
                      p_country_code     IN VARCHAR2,
                      p_cust_trx_type_id IN NUMBER) RETURN NUMBER IS

         l_count    NUMBER;
         l_category VARCHAR2(30);

  BEGIN

    IF p_country_code = 'CL' THEN
      l_category := 'JL.CL.RAXSUCTT.CUST_TRX_TYPES';
    ELSIF p_country_code = 'AR' THEN
      l_category := 'JL.AR.RAXSUCTT.CUST_TRX_TYPES';
    ELSIF p_country_code = 'CO' THEN
      l_category := 'JL.CO.RAXSUCTT.CUST_TRX_TYPES';
    END IF;

    SELECT  COUNT(*)
    INTO l_count
    FROM ra_cust_trx_types ct
    WHERE ct.global_attribute_category = l_category
    AND ct.global_attribute6 = 'Y'
    AND decode(p_cust_trx_type_id,null,-1,ct.cust_trx_type_id) <> nvl(p_cust_trx_type_id,-2);

    RETURN l_count;

  END;

--
-- Procedure Name:
--   get_copy_status
-- Called From:
--   ARXTWMAI_ZZ_TGW_HEADER_BV
-- Purpose:
--   Gets copy statuses
--
  PROCEDURE get_copy_status(
                      p_country_code         IN VARCHAR2,
                      p_customer_trx_id      IN NUMBER,
                      p_copy_status_code     OUT NOCOPY VARCHAR2,
                      p_copy_status_meaning  OUT NOCOPY VARCHAR2) IS

           l_category            VARCHAR2(30);

  BEGIN

    IF p_country_code = 'CL' THEN
      l_category := 'JL.CL.ARXTWMAI.TGW_HEADER';
    ELSIF p_country_code = 'AR' THEN
      l_category := 'JL.AR.ARXTWMAI.TGW_HEADER';
    ELSIF p_country_code = 'CO' THEN
      l_category := 'JL.CO.ARXTWMAI.TGW_HEADER';
    END IF;

    IF l_category IS NOT NULL THEN

      SELECT rc.global_attribute20, fl.meaning
      INTO   p_copy_status_code, p_copy_status_meaning
      FROM   ra_customer_trx rc, fnd_lookups fl
      WHERE  rc.customer_trx_id = p_customer_trx_id
      AND    rc.global_attribute_category = l_category
      AND    rc.global_attribute20 = fl.lookup_code
      AND    fl.lookup_type = 'JLZZ_COPY_STATUS';

    ELSE
      p_copy_status_code := '';
      p_copy_status_meaning := '';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_copy_status_code := '';
      p_copy_status_meaning := '';
  END;

--
-- Procedure Name:
--   get_orig_trx_type
-- Called From:
--   ARXTWMAI_ZZ_CP_ORIG_TRX_TYPE
-- Purpose:
--   Return cust_trx_type_id of specified transactions
--
  PROCEDURE get_orig_trx_type(
                      p_customer_trx_id      IN NUMBER,
                      p_cust_trx_type_id    OUT NOCOPY NUMBER) IS

  BEGIN

    IF p_customer_trx_id IS NOT NULL THEN

      SELECT cust_trx_type_id
        INTO p_cust_trx_type_id
        FROM ra_customer_trx
       WHERE customer_trx_id = p_customer_trx_id;

    ELSE

      p_cust_trx_type_id := '';

    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_cust_trx_type_id := '';
    WHEN OTHERS THEN
      RAISE PROGRAM_ERROR;
  END;

--
-- Procedure Name:
--   chk_company_name_unique
-- Called From:
--   PERWSLOC_ZZ_LOC_BV
-- Purpose:
--   To check uniqueness of company name(GLOBAL_ATTRIBUTE8 of AR/CL/CO).
--
  PROCEDURE chk_company_name_unique(
                      p_rowid        IN  VARCHAR2,
                      p_country_code IN  VARCHAR2,
                      p_company_name IN  VARCHAR2,
                      p_message_code OUT NOCOPY VARCHAR2) IS
    dummy           NUMBER;

  BEGIN

    select count(1) into dummy
    from hr_locations_all
    where global_attribute8 = p_company_name
    and substrb(nvl(global_attribute_category,'XX.XX'),4,2) = p_country_code
    and ((p_rowid is null) or (rowid <> p_rowid));

    if (dummy >= 1) then
      p_message_code := 'FALSE';
    else
      p_message_code := 'TRUE';
    end if;

  END chk_company_name_unique;

--
-- Procedure Name:
--   get_last_attrs
-- Called From:
--   FAXSUBCT_ZZ_LAST_REV_RUN_BV
-- Purpose:
--   Return last inflation adjusted, revaluation and closed period
--   for a given book.
--

  PROCEDURE get_last_attrs(
                      p_book_type_code       IN VARCHAR2,
                      p_last_inf_adj         OUT NOCOPY VARCHAR2,
                      p_last_reval           OUT NOCOPY VARCHAR2,
                      p_last_closed_period   OUT NOCOPY VARCHAR2,
                      p_last_period_posted   OUT NOCOPY VARCHAR2) IS

  BEGIN
      SELECT b.global_attribute2 last_inf_adj,
             b.global_attribute3 last_reval,
             b.global_attribute5 last_closed_period,
             b.global_attribute19 last_period_posted
      INTO p_last_inf_adj,p_last_reval,p_last_closed_period,p_last_period_posted
      FROM fa_book_controls b
      WHERE b.book_type_code = p_book_type_code;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE PROGRAM_ERROR;
  END get_last_attrs;

--
-- Procedure Name:
--   get_last_period_ctr
-- Called From:
--   JLCO_FA
-- Purpose:
--   Return last period counter
--   for a deprn calendar  given.
--

  PROCEDURE get_last_period_ctr(
                      p_deprn_calendar       IN  VARCHAR2,
                      p_current_fiscal_year  IN  NUMBER,
                      p_current_period_num   IN NUMBER,
                      p_last_period_counter  OUT NOCOPY NUMBER)IS

  BEGIN
	select	to_number(p_current_fiscal_year)
				* ct.number_per_fiscal_year
				+ to_number(p_current_period_num)-1
	into	p_last_period_counter
	from	fa_calendar_types ct
	where	ct.calendar_type = p_deprn_calendar;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE PROGRAM_ERROR;
  END get_last_period_ctr;

--
-- Function Name:
--   verify_adjust_flag
-- Called From:
--   FAXDPRUN_ZZ_DPRN_RUN_BV
-- Purpose:
-- If the book is adjustable, then verify if inflation adjustment
-- has been run.
--
-- 03/22/00   Santosh Vaze    Bug Fix 1235190 : Added a better suited
-- message for the situation where Colombian Generate JE process is not run.
-- The following package now returns different flags for different scenarios.

  FUNCTION verify_adjust_flag(
                      p_country_code    IN  VARCHAR2,
                      p_book_type_code  IN  VARCHAR2,
                      p_period_name     IN  VARCHAR2) RETURN NUMBER IS

   l_period_counter       NUMBER;
   l_period_cont          NUMBER;
   l_mass_reval_id        NUMBER;
   allowed                VARCHAR2(3);
   dummy                  NUMBER;

  BEGIN

       SELECT global_attribute1,TO_NUMBER(global_attribute2),
              global_attribute3,TO_NUMBER(global_attribute5)
       INTO allowed,l_period_counter,
            l_mass_reval_id,l_period_cont
       FROM fa_book_controls
       WHERE book_type_code = p_book_type_code;


       IF allowed = 'Y' THEN
         IF p_country_code = 'CO' AND (l_period_counter-l_period_cont > 1) THEN
           RETURN 1;
         END IF;

         SELECT count(*)
         INTO dummy
         FROM fa_deprn_periods c,fa_mass_revaluations a
         WHERE a.book_type_code = p_book_type_code
           AND a.status = 'COMPLETED'
           AND a.mass_reval_id  = l_mass_reval_id
           AND c.book_type_code = a.book_type_code
           AND c.period_name    = p_period_name
           AND c.period_counter = l_period_counter;
         --  AND c.period_counter = a.global_attribute1;    /* To fix bug 1013530 */

         IF dummy > 0  then
            RETURN 0;
         ELSE
            RETURN 2;
         END IF;
       ELSE
         RETURN 0;
       END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE PROGRAM_ERROR;
  END verify_adjust_flag;


--
-- Function Name:
--   verify_book_synchro
-- Called From:
--   FAXDPRUN_ZZ_DPRN_RUN_BV
-- Purpose:
--   Verify if the given book has 'Tax' or 'Corporative' associated
--   books, and if those books are or not out of synchrony in ran periods.
--

  FUNCTION verify_book_synchro(
                      p_book_type_code  IN  VARCHAR2,
                      p_period_name     IN  VARCHAR2) RETURN BOOLEAN IS
   dummy NUMBER;

  BEGIN

    SELECT 1
    INTO dummy
    FROM dual
    WHERE NOT EXISTS ( SELECT 1
                       FROM fa_book_controls b, fa_book_controls a
                       WHERE a.book_type_code = p_book_type_code
                       AND DECODE(a.book_class
                                , 'CORPORATE', a.book_type_code
                                , 'TAX' ,a.distribution_source_book) =
                           DECODE (a.book_class
                                , 'CORPORATE', b.distribution_source_book
                                ,'TAX' ,b.book_type_code)
                       AND b.allow_cip_assets_flag = 'YES'
                       AND b.rowid <> a.rowid
                       AND NOT EXISTS ( SELECT 1
                                        FROM fa_deprn_periods c
                                           , fa_deprn_periods d
                                        WHERE c.book_type_code =
                                              a.book_type_code
                                          AND c.period_name = p_period_name
                                          AND d.book_type_code =
                                              b.book_type_code
                                          AND d.period_close_date IS NULL
                                          AND c.period_counter <=
                                              d.period_counter));
      RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN FALSE;
  END verify_book_synchro;


/*
 * Function Name:
 *   is_foreign_supplier()
 * Called From:
 *   APXINWKB_AR_INV_SUM_FOLDER_BV
 * Purpose:
 *   Return TRUE if it is a foreign supplier; FALSE otherwise
 */
  FUNCTION is_foreign_supplier(p_vendor_id IN NUMBER) RETURN BOOLEAN IS
    l_count      NUMBER;
    l_is_foreign BOOLEAN;
  BEGIN
    SELECT count(*)
    INTO l_count
    FROM po_vendors pv
    WHERE pv.vendor_id = p_vendor_id AND
          pv.global_attribute9 = 'FOREIGN_ORIGIN';

    IF l_count = 1 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END is_foreign_supplier;


/*
 * Function Name:
 *   get_ship_to_location_code()
 * Called From:
 *   APXINWKB_AR_D_SUM_FOLDER_BV
 * Purpose:
 *   Return ship to location code
 */


  FUNCTION get_ship_to_location_code(p_po_distribution_id IN NUMBER) RETURN VARCHAR2 IS

    l_ship_to_location_code hr_locations_all.location_code%type; --bug 2238543: VARCHAR2(30);

  BEGIN
    SELECT hl.location_code
    INTO l_ship_to_location_code
    FROM hr_locations_all hl
    WHERE hl.location_id = (SELECT pll.ship_to_location_id
                            FROM po_line_locations_all pll
                            WHERE pll.line_location_id = (SELECT pd.line_location_id
                                                          FROM po_distributions_all pd
                                                          WHERE pd.po_distribution_id = p_po_distribution_id));
    RETURN l_ship_to_location_code;

  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN others THEN
      RETURN NULL;
  END get_ship_to_location_code;


/*
 * Function Name:
 *   get_vendor_name()
 * Called From:
 *   APXINWKB_ZZ_SPECIAL_MENU_SPC6
 * Purpose:
 *   Return vendor_name given the tax payer ID (Vendor Number)
 */
  FUNCTION get_vendor_name(p_taxpayer_id IN VARCHAR2) RETURN VARCHAR2 IS
    l_vendor_name VARCHAR2(80);
  BEGIN
    SELECT pv.vendor_name
    INTO l_vendor_name
    FROM po_vendors pv
    WHERE pv.segment1 = p_taxpayer_id;

    RETURN l_vendor_name;

  EXCEPTION
    WHEN others THEN
      RETURN NULL;
  END get_vendor_name;


/*
 * Function Name:
 *   get_vendor_id()
 * Called From:
 *   APXINWKB_ZZ_SPECIAL_MENU_SPC6
 * Purpose:
 *   Bug 4055807: Return vendor_id given the vendor number
 */
  FUNCTION get_vendor_id(p_vendor_number IN VARCHAR2) RETURN NUMBER IS
    l_vendor_id NUMBER;
  BEGIN
    SELECT pv.vendor_id
    INTO l_vendor_id
    FROM po_vendors pv
    WHERE pv.segment1 = p_vendor_number;

    RETURN l_vendor_id;

  EXCEPTION
    WHEN others THEN
      RETURN NULL;
  END get_vendor_id;


/*
 * Procedure Name:
 *   get_awt_type_attributes()
 * Called From:
 *   APXTADTC_AR_TAX_CODES_BV and APXTADTC_CO_TAX_CODES_BV
 * Purpose:
 *   Return Argentine and Colombian AWT type attributes given the AWT type code
 */
  PROCEDURE get_awt_type_attributes(p_awt_type_code             IN VARCHAR2,
                                    p_jurisdiction_type         OUT NOCOPY VARCHAR2,
                                    p_foreign_supplier_flag     OUT NOCOPY VARCHAR2,
                                    p_min_tax_amount_level      OUT NOCOPY VARCHAR2,
                                    p_min_wh_amount_level       OUT NOCOPY VARCHAR2,
                                    p_cumulative_payment_flag   OUT NOCOPY VARCHAR2,
                                    p_vat_inclusive_flag        OUT NOCOPY VARCHAR2,
                                    p_user_defined_formula_flag OUT NOCOPY VARCHAR2) IS
  BEGIN
    SELECT jurisdiction_type, foreign_supplier_flag, min_tax_amount_level,
           min_wh_amount_level, cumulative_payment_flag, vat_inclusive_flag,
           user_defined_formula_flag
    INTO p_jurisdiction_type, p_foreign_supplier_flag, p_min_tax_amount_level,
         p_min_wh_amount_level, p_cumulative_payment_flag, p_vat_inclusive_flag,
         p_user_defined_formula_flag
    FROM jl_zz_ap_awt_types
    WHERE awt_type_code = p_awt_type_code;

  EXCEPTION
    WHEN others THEN
      RAISE program_error;
  END get_awt_type_attributes;


/*
 * Function Name:
 *   exist_legal_address_site()
 * Called From:
 *   APXVDMVD_ZZ_SITE_BV
 * Purpose:
 *   Return TRUE if there is already a site chosen as the legal address;
 *   FALSE otherwise.
 */
  FUNCTION exist_legal_address_site(p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER) RETURN BOOLEAN IS
    l_count                    NUMBER;
    l_exist_legal_address_site BOOLEAN;
  BEGIN
    SELECT count(*)
    INTO l_count
    FROM ap_vendor_sites_v st
    WHERE st.vendor_id = p_vendor_id AND
          st.global_attribute17 = 'Y' AND
          vendor_site_id <> p_vendor_site_id;

    IF l_count = 1 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END exist_legal_address_site;

-- Procedure Name:
--   get_last_start_date
-- Called From:
--   FAXASSET_FA_ASSET_BV
-- Purpose:
--   Return last Inflation Start Date, for a given asset.
--

 PROCEDURE get_last_start_date( p_asset_id IN NUMBER,
                                p_last_start_date OUT NOCOPY VARCHAR2) IS

  BEGIN
      SELECT global_attribute1
      INTO p_last_start_date
      FROM fa_additions
      WHERE asset_id = p_asset_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE PROGRAM_ERROR;

  END get_last_start_date;


--
-- Function Name:
--   eval_asset_reval
-- Called From:
--   FAXASSET_FA_ASSET_BV
-- Purpose:
-- Verify is Inflation Adjustment has been applied at
-- least once to the given asset.
--

  FUNCTION eval_asset_reval( p_asset_id IN  NUMBER) RETURN BOOLEAN IS

   dummy                  NUMBER;

  BEGIN

       SELECT 1
       INTO dummy
       FROM dual
       WHERE EXISTS (SELECT 1
                     FROM fa_mass_revaluation_rules rr,
                          fa_mass_revaluations mr
                          WHERE rr.asset_id = p_asset_id
                          AND   rr.mass_reval_id = mr.mass_reval_id
                          AND   mr.status = 'COMPLETED');
       RETURN TRUE;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
  END eval_asset_reval;


PROCEDURE get_location_row_id(p_location_id IN NUMBER, p_row_id OUT NOCOPY VARCHAR2) IS
  l_rowid varchar2(100);
  BEGIN

         SELECT rowid into l_rowid
         FROM   hr_locations_all
         WHERE  location_id = p_location_id;
  p_row_id := l_rowid;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
           NULL;
  END;

END JL_ZZ_GLOBE_VAL_PKG;

/
