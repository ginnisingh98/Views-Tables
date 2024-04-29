--------------------------------------------------------
--  DDL for Package JL_ZZ_GLOBE_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_GLOBE_VAL_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzglvs.pls 120.4 2005/10/30 02:05:52 appldev ship $ */

--
-- Procedure Name:
--   count_void_trx_type
-- Called From:
--   RAXSUCTT_ZZ_RA_CUST_TTYPES_BV
-- Purpose:
--   Return the number of Void Transaction Types
--
  FUNCTION  count_void_trx_type(
                      p_country_code     IN VARCHAR2,
                      p_cust_trx_type_id IN NUMBER) RETURN NUMBER;

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
                      p_copy_status_code    OUT NOCOPY VARCHAR2,
                      p_copy_status_meaning OUT NOCOPY VARCHAR2);

--
-- Procedure Name:
--   get_orig_trx_type
-- Called From:
--   ARXTWMAI_ZZ_CP_ORIG_TRX_TYPE
-- Purpose:
--   Return cust_trx_type_id of specified customer_trx_id
--
  PROCEDURE get_orig_trx_type(
                      p_customer_trx_id      IN NUMBER,
                      p_cust_trx_type_id    OUT NOCOPY NUMBER);

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
                      p_message_code OUT NOCOPY VARCHAR2);

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
                      p_last_period_posted   OUT NOCOPY VARCHAR2);
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
                      p_last_period_counter  OUT NOCOPY NUMBER);

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
                      p_period_name     IN  VARCHAR2) RETURN NUMBER;

--
-- Function Name:
--   verify_book_synchro
-- Called From:
--   FAXDPRUN_ZZ_DPRN_RUN_BV
-- Purpose:
--   Verify if the given book has 'Tax' or 'Corporative' associated
--   books, and if those books are or not out NOCOPY of synchrony in ran periods.
--

  FUNCTION verify_book_synchro(
                      p_book_type_code  IN  VARCHAR2,
                      p_period_name     IN  VARCHAR2) RETURN BOOLEAN;



/*
 * Function Name:
 *   is_foreign_supplier()
 * Called From:
 *   APXINWKB_AR_INV_SUM_FOLDER_BV
 * Purpose:
 *   Return TRUE if it is a foreign supplier; FALSE otherwise
 */
  FUNCTION is_foreign_supplier(p_vendor_id IN NUMBER) RETURN BOOLEAN;


/*
 * Function Name:
 *   get_ship_to_location_code()
 * Called From:
 *   APXINWKB_AR_D_SUM_FOLDER_BV
 * Purpose:
 *   Return ship to location code
 */
  FUNCTION get_ship_to_location_code(p_po_distribution_id IN NUMBER) RETURN VARCHAR2;


/*
 * Function Name:
 *   get_vendor_name()
 * Called From:
 *   APXINWKB_ZZ_SPECIAL_MENU_SPC6
 * Purpose:
 *   Return vendor_name given the tax payer ID(Vendor Number)
 */
  FUNCTION get_vendor_name(p_taxpayer_id IN VARCHAR2) RETURN VARCHAR2;


/*
 * Function Name:
 *   get_vendor_id()
 * Called From:
 *   APXINWKB_ZZ_SPECIAL_MENU_SPC6
 * Purpose:
 *   Bug 4055807: Return vendor_id given the vendor number
 */
  FUNCTION get_vendor_id(p_vendor_number IN VARCHAR2) RETURN NUMBER;


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
                                    p_user_defined_formula_flag OUT NOCOPY VARCHAR2);


/*
 * Function Name:
 *   exist_legal_address_site()
 * Called From:
 *   APXVDMVD_ZZ_SITE_BV
 * Purpose:
 *   Return TRUE if there is already a site chosen as the legal address;
 *   FALSE otherwise.
 */
  FUNCTION exist_legal_address_site(p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER) RETURN BOOLEAN;

--
-- Procedure Name:
--   get_last_start_date
-- Called From:
--   FAXASSET_FA_ASSET_BV
-- Purpose:
--   Return last Inflation Start Date, for a given asset.
--

 PROCEDURE get_last_start_date( p_asset_id IN NUMBER,
                                p_last_start_date OUT NOCOPY VARCHAR2);


--
-- Function Name:
--   eval_asset_reval
-- Called From:
--   FAXASSET_FA_ASSET_BV
-- Purpose:
-- Verify is Inflation Adjustment has been applied at
-- least once to the given asset.
--

  FUNCTION eval_asset_reval( p_asset_id IN  NUMBER) RETURN BOOLEAN;

--
-- Procedure Name :
-- get_location_row_id
-- Called from PERWSLOC_ZZ_LOC_PREIU
-- Purpose :
--   To Verify Unique Company Name in Locations , This row id passed to
--   chk_company_name_unique procedure

 PROCEDURE get_location_row_id(p_location_id IN NUMBER, p_row_id OUT NOCOPY VARCHAR2);


END JL_ZZ_GLOBE_VAL_PKG;

 

/
