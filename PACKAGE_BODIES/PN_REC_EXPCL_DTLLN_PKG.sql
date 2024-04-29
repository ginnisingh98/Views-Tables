--------------------------------------------------------
--  DDL for Package Body PN_REC_EXPCL_DTLLN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_REC_EXPCL_DTLLN_PKG" AS
/* $Header: PNRECLNB.pls 120.2 2005/11/30 23:38:27 appldev noship $ */

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 15-JUL-05  sdmahesh  o Replaced base views with their _ALL table.
-- 28-NOV-05  pikhar    o fetched org_id using cursor
-------------------------------------------------------------------------------
PROCEDURE insert_row(
             x_org_id                        pn_rec_expcl_dtlln.org_id%TYPE,
             x_expense_class_dtl_id          pn_rec_expcl_dtlln.expense_class_dtl_id%TYPE,
             x_expense_class_line_id IN OUT NOCOPY pn_rec_expcl_dtlln.expense_class_line_id%TYPE,
             x_location_id                   pn_rec_expcl_dtlln.location_id%TYPE,
             x_cust_space_assign_id          pn_rec_expcl_dtlln.cust_space_assign_id%TYPE,
             x_cust_account_id               pn_rec_expcl_dtlln.cust_account_id%TYPE,
             x_lease_id                      pn_rec_expcl_dtlln.lease_id%TYPE,
             x_recovery_space_std_code       pn_rec_expcl_dtlln.recovery_space_std_code%TYPE,
             x_recovery_type_code            pn_rec_expcl_dtlln.recovery_type_code%TYPE,
             x_budgeted_amt                  pn_rec_expcl_dtlln.budgeted_amt%TYPE,
             x_expense_amt                   pn_rec_expcl_dtlln.expense_amt%TYPE,
             x_recoverable_amt               pn_rec_expcl_dtlln.recoverable_amt%TYPE,
             x_computed_recoverable_amt      pn_rec_expcl_dtlln.computed_recoverable_amt%TYPE,
             x_cls_line_share_pct            pn_rec_expcl_dtlln.cls_line_share_pct%TYPE,
             x_cls_line_fee_bf_ct_ovr        pn_rec_expcl_dtlln.cls_line_fee_before_contr_ovr%TYPE,
             x_cls_line_fee_af_ct_ovr        pn_rec_expcl_dtlln.cls_line_fee_after_contr_ovr%TYPE,
             x_use_share_pct_flag            pn_rec_expcl_dtlln.use_share_pct_flag%TYPE,
             x_use_fee_before_contr_flag     pn_rec_expcl_dtlln.use_fee_before_contr_flag%TYPE,
             x_last_update_date              pn_rec_expcl_dtlln.last_update_date%TYPE,
             x_last_updated_by               pn_rec_expcl_dtlln.last_updated_by%TYPE,
             x_creation_date                 pn_rec_expcl_dtlln.creation_date%TYPE,
             x_created_by                    pn_rec_expcl_dtlln.created_by%TYPE,
             x_last_update_login             pn_rec_expcl_dtlln.last_update_login%TYPE
       )
IS
   l_desc VARCHAR2(100) := 'pn_rec_expcl_dtlln_pkg.insert_row';
   CURSOR org_cur IS
    SELECT org_id
    FROM pn_rec_expcl_dtl_all
    WHERE expense_class_dtl_id = x_expense_class_dtl_id;

   l_org_id NUMBER;


BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   IF x_org_id IS NULL THEN
    FOR rec IN org_cur LOOP
      l_org_id := rec.org_id;
    END LOOP;
   ELSE
    l_org_id := x_org_id;
   END IF;

   INSERT INTO pn_rec_expcl_dtlln_all
   (
      org_id,
      expense_class_dtl_id,
      expense_class_line_id,
      location_id,
      cust_space_assign_id,
      cust_account_id,
      lease_id,
      recovery_space_std_code,
      recovery_type_code,
      budgeted_amt,
      expense_amt,
      recoverable_amt,
      computed_recoverable_amt,
      cls_line_share_pct,
      cls_line_fee_before_contr_ovr,
      cls_line_fee_after_contr_ovr,
      use_share_pct_flag,
      use_fee_before_contr_flag,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login
     ) VALUES (
      l_org_id,
      x_expense_class_dtl_id,
      pn_rec_expcl_dtlln_s.nextval,
      x_location_id,
      x_cust_space_assign_id,
      x_cust_account_id,
      x_lease_id,
      x_recovery_space_std_code,
      x_recovery_type_code,
      x_budgeted_amt,
      x_expense_amt,
      x_recoverable_amt,
      x_computed_recoverable_amt,
      x_cls_line_share_pct,
      x_cls_line_fee_bf_ct_ovr,
      x_cls_line_fee_af_ct_ovr,
      x_use_share_pct_flag,
      x_use_fee_before_contr_flag,
      x_last_update_date,
      x_last_updated_by,
      x_creation_date,
      x_created_by,
      x_last_update_login
     ) RETURNING expense_class_line_id INTO x_expense_class_line_id;

   pnp_debug_pkg.debug(l_desc ||' (-)');

EXCEPTION
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20001, to_char(sqlcode));
     app_exception.raise_exception;
END insert_row;

-------------------------------------------------------------------------------
-- PROCDURE     : UPDATE_ROW
-- INVOKED FROM : update_row procedure
-- PURPOSE      : updates the row
-- HISTORY      :
-- 15-JUL-05  sdmahesh  o Replaced base views with their _ALL table.
-------------------------------------------------------------------------------
PROCEDURE update_row(
             x_expense_class_line_id         pn_rec_expcl_dtlln.expense_class_line_id%TYPE,
             x_location_id                   pn_rec_expcl_dtlln.location_id%TYPE,
             x_cust_space_assign_id          pn_rec_expcl_dtlln.cust_space_assign_id%TYPE,
             x_cust_account_id               pn_rec_expcl_dtlln.cust_account_id%TYPE,
             x_lease_id                      pn_rec_expcl_dtlln.lease_id%TYPE,
             x_recovery_space_std_code       pn_rec_expcl_dtlln.recovery_space_std_code%TYPE,
             x_recovery_type_code            pn_rec_expcl_dtlln.recovery_type_code%TYPE,
             x_budgeted_amt                  pn_rec_expcl_dtlln.budgeted_amt%TYPE,
             x_expense_amt                   pn_rec_expcl_dtlln.expense_amt%TYPE,
             x_recoverable_amt               pn_rec_expcl_dtlln.recoverable_amt%TYPE,
             x_computed_recoverable_amt      pn_rec_expcl_dtlln.computed_recoverable_amt%TYPE,
             x_cls_line_share_pct            pn_rec_expcl_dtlln.cls_line_share_pct%TYPE,
             x_cls_line_fee_bf_ct_ovr        pn_rec_expcl_dtlln.cls_line_fee_before_contr_ovr%TYPE,
             x_cls_line_fee_af_ct_ovr        pn_rec_expcl_dtlln.cls_line_fee_after_contr_ovr%TYPE,
             x_use_share_pct_flag            pn_rec_expcl_dtlln.use_share_pct_flag%TYPE,
             x_use_fee_before_contr_flag     pn_rec_expcl_dtlln.use_fee_before_contr_flag%TYPE,
             x_last_update_date              pn_rec_expcl_dtlln.last_update_date%TYPE,
             x_last_updated_by               pn_rec_expcl_dtlln.last_updated_by%TYPE,
             x_creation_date                 pn_rec_expcl_dtlln.creation_date%TYPE,
             x_created_by                    pn_rec_expcl_dtlln.created_by%TYPE,
             x_last_update_login             pn_rec_expcl_dtlln.last_update_login%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_expcl_dtlln_pkg.update_row';
BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   UPDATE pn_rec_expcl_dtlln_all
   SET
      expense_class_line_id            = x_expense_class_line_id,
      location_id                      = x_location_id,
      cust_space_assign_id             = x_cust_space_assign_id,
      cust_account_id                  = x_cust_account_id,
      lease_id                         = x_lease_id,
      recovery_space_std_code          = x_recovery_space_std_code,
      recovery_type_code               = x_recovery_type_code,
      budgeted_amt                     = x_budgeted_amt,
      expense_amt                      = x_expense_amt,
      recoverable_amt                  = x_recoverable_amt,
      computed_recoverable_amt         = x_computed_recoverable_amt,
      cls_line_share_pct               = x_cls_line_share_pct,
      cls_line_fee_before_contr_ovr    = x_cls_line_fee_bf_ct_ovr,
      cls_line_fee_after_contr_ovr     = x_cls_line_fee_af_ct_ovr,
      use_share_pct_flag               = x_use_share_pct_flag,
      use_fee_before_contr_flag        = x_use_fee_before_contr_flag,
      last_update_date                 = x_last_update_date,
      last_updated_by                  = x_last_updated_by,
      creation_date                    = x_creation_date,
      created_by                       = x_created_by,
      last_update_login                = x_last_update_login
   WHERE expense_class_line_id         = x_expense_class_line_id;

   pnp_debug_pkg.debug(l_desc ||' (-)');

EXCEPTION
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20001, to_char(sqlcode));
     app_exception.raise_exception;
END update_row;

-------------------------------------------------------------------------------
-- PROCDURE     : DELETE_ROW
-- INVOKED FROM : delete_row procedure
-- PURPOSE      : deletes the row
-- HISTORY      :
-- 15-JUL-05  sdmahesh  o Replaced base views with their _ALL table.
-------------------------------------------------------------------------------
PROCEDURE delete_row(x_expense_class_line_id    pn_rec_expcl_dtlln.expense_class_line_id%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_expcl_dtlln_pkg.delete_row';
BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   DELETE pn_rec_expcl_dtlln_all          /*sdm14jul*/
   WHERE  expense_class_line_id = x_expense_class_line_id;

   pnp_debug_pkg.debug(l_desc ||' (-)');

EXCEPTION
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20001, to_char(sqlcode));
     app_exception.raise_exception;
END delete_row;

END pn_rec_expcl_dtlln_pkg;

/
