--------------------------------------------------------
--  DDL for Package Body GL_MC_INQUIRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_MC_INQUIRY_PKG" AS
/* $Header: glmcinqb.pls 120.5 2006/01/13 12:13:49 jvarkey noship $ */

   -- WRONG!! need to pass fa_book_type_code???
  FUNCTION mrc_enabled(
    n_application_id   NUMBER,
    n_primary_sob_id   NUMBER,
    n_org_id           NUMBER)
    RETURN BOOLEAN IS
  BEGIN
    RETURN(FALSE);
  END;

--
-- PROCEDURE    : get_associated_sobs
-- PARAMETERS   : n_sob_id       (IN) -- Primary SOB ID
--                n_appl_id      (IN) -- Application ID
--                n_org_id       (IN) -- Org ID
--                n_fa_book_code    (IN) -- FA BOOK Code
--                n_sob_list     (IN OUT) -- r_sob_list_type
-- DESCRIPTION  : Set of Books Array
--
  PROCEDURE get_associated_sobs(
    n_sob_id         IN NUMBER,
    n_appl_id        IN NUMBER,
    n_org_id         IN NUMBER,
    n_fa_book_code   IN VARCHAR2,
    n_num_rec        IN NUMBER,
    n_sob_list       IN OUT NOCOPY r_sob_list_type) IS
  BEGIN
    null;
  END get_associated_sobs;

  PROCEDURE query_balances(
    x_asset_id     NUMBER,
    x_book         VARCHAR2,
    x_period_ctr   NUMBER ,
    x_dist_id      NUMBER ,
    x_run_mode     VARCHAR2 ) IS
  BEGIN
    null;
  END query_balances;


-- Adds the current period's adjustments (ADJ_DRS) to the
-- financial info in the most recent depreciation row (DEST_DRS).
-- S.B. called right after get_adjustments.
-- This should go away in Rel11, where adjustments will update
-- deprn rows.


  PROCEDURE add_adj_to_deprn(
    x_adj_drs      IN OUT NOCOPY   fa_std_types.fa_deprn_row_struct,
    x_dest_drs     IN OUT NOCOPY   fa_std_types.fa_deprn_row_struct,
    x_book_type    IN       VARCHAR2,
    x_book_id      IN       NUMBER,
    x_calling_fn            VARCHAR2) IS
  BEGIN
    null;
  END add_adj_to_deprn;

  PROCEDURE query_balances_int(
    x_dpr_row                 IN OUT NOCOPY   fa_std_types.fa_deprn_row_struct,
    x_run_mode                         VARCHAR2,
    x_book_type               IN       VARCHAR2,
    x_book_id                 IN       NUMBER,
    x_calling_fn                       VARCHAR2,
    x_original_cost           IN OUT NOCOPY   NUMBER,
    x_salvage_value           IN OUT NOCOPY   NUMBER,
    x_reval_ceiling           IN OUT NOCOPY   NUMBER,
    x_reval_reserve           IN OUT NOCOPY   NUMBER,
    x_cost                    IN OUT NOCOPY   NUMBER,
    x_recoverable_cost        IN OUT NOCOPY   NUMBER,
    x_transaction_header_id   IN       NUMBER ) IS
  BEGIN
    null;
  END query_balances_int;


-- This procedure gets info related to the current period:
-- period counter, fiscal year, and number of periods in fiscal year



  PROCEDURE get_period_info(
    x_book                   VARCHAR2,
    x_cur_per_ctr   IN OUT NOCOPY   NUMBER,
    x_cur_fy        IN OUT NOCOPY   NUMBER,
    x_num_pers_fy   IN OUT NOCOPY   NUMBER,
    x_book_type     IN       VARCHAR2,
    x_book_id       IN       NUMBER,
    x_calling_fn             VARCHAR2) IS
  BEGIN
    null;
  END get_period_info;


-- Use this procedure to query summary-level information
-- from fa_deprn_summary in given period (or current period if 0)


  PROCEDURE query_deprn_summary(
    x_dpr_row            IN OUT NOCOPY   fa_std_types.fa_deprn_row_struct,
    x_found_per_ctr      IN OUT NOCOPY   NUMBER,
    x_run_mode                    VARCHAR2,
    x_book_type          IN       VARCHAR2,
    x_book_id            IN       NUMBER,
    x_original_cost      IN OUT NOCOPY   NUMBER,
    x_salvage_value      IN OUT NOCOPY   NUMBER,
    x_reval_ceiling      IN OUT NOCOPY   NUMBER,
    x_reval_reserve      IN OUT NOCOPY   NUMBER,
    x_cost               IN OUT NOCOPY   NUMBER,
    x_recoverable_cost   IN OUT NOCOPY   NUMBER,
    x_calling_fn                  VARCHAR2) IS

  BEGIN
    null;
  END query_deprn_summary;


-- Get info for any adjustments that occurred after the creation of
-- the deprn row from which we selected financial info.

  PROCEDURE get_adjustments_info(
    x_adj_row                 IN OUT NOCOPY   fa_std_types.fa_deprn_row_struct,
    x_found_per_ctr           IN OUT NOCOPY   NUMBER,
    x_run_mode                         VARCHAR2,
    x_transaction_header_id            NUMBER,
    x_book_type               IN       VARCHAR2,
    x_book_id                 IN       NUMBER,
    x_calling_fn                       VARCHAR2) IS
  BEGIN
    null;
  END get_adjustments_info;

  PROCEDURE ar_init_cash_receipts(p_cash_receipt_id IN NUMBER) IS
  BEGIN
    null;
  END;

  PROCEDURE init_invoice(l_inv_id IN NUMBER) IS
  BEGIN
    null;
  END init_invoice;

  PROCEDURE init_payment(l_pay_id IN NUMBER) IS

  BEGIN
    null;
  END init_payment;

  PROCEDURE transaction_balances(p_customer_trx_id IN NUMBER) IS
  BEGIN
    null;
  END;
END gl_mc_inquiry_pkg;

/
