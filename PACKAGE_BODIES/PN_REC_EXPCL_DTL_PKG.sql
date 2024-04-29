--------------------------------------------------------
--  DDL for Package Body PN_REC_EXPCL_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_REC_EXPCL_DTL_PKG" AS
/* $Header: PNRECLSB.pls 120.2 2005/11/30 23:39:30 appldev noship $ */

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 15-JUL-05  sdmahesh  o Replaced base views with their _ALL table.
-- 28-NOV-05  pikhar    o fetched org_id using cursor
-------------------------------------------------------------------------------
PROCEDURE insert_row(
             x_org_id                        pn_rec_expcl_dtl.org_id%TYPE,
             x_expense_class_id              pn_rec_expcl_dtl.expense_class_id%TYPE,
             x_expense_line_id               pn_rec_expcl_dtl.expense_line_id%TYPE,
             x_expense_class_dtl_id          IN OUT NOCOPY pn_rec_expcl_dtl.expense_class_dtl_id%TYPE,
             x_status                        pn_rec_expcl_dtl.status%TYPE,
             x_def_area_cls_id               pn_rec_expcl_dtl.default_area_class_id%TYPE,
             x_cls_line_fee_bf_ct            pn_rec_expcl_dtl.cls_line_fee_before_contr%TYPE,
             x_cls_line_fee_af_ct            pn_rec_expcl_dtl.cls_line_fee_after_contr%TYPE,
             x_cls_line_portion_pct          pn_rec_expcl_dtl.cls_line_portion_pct%TYPE,
             x_last_update_date              pn_rec_expcl_dtl.last_update_date%TYPE,
             x_last_updated_by               pn_rec_expcl_dtl.last_updated_by%TYPE,
             x_creation_date                 pn_rec_expcl_dtl.creation_date%TYPE,
             x_created_by                    pn_rec_expcl_dtl.created_by%TYPE,
             x_last_update_login             pn_rec_expcl_dtl.last_update_login%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_expcl_dtl_pkg.insert_row';

   CURSOR org_cur IS
    SELECT org_id
    FROM pn_rec_exp_line_all
    WHERE expense_line_id  = x_expense_line_id ;

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

   INSERT INTO pn_rec_expcl_dtl_all(
      org_id,
      expense_class_id,
      expense_line_id,
      expense_class_dtl_id,
      status,
      default_area_class_id,
      cls_line_fee_before_contr,
      cls_line_fee_after_contr,
      cls_line_portion_pct,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login )
   VALUES (
      l_org_id,
      x_expense_class_id,
      x_expense_line_id,
      pn_rec_expcl_dtl_s.nextval,
      x_status,
      x_def_area_cls_id,
      x_cls_line_fee_bf_ct,
      x_cls_line_fee_af_ct,
      x_cls_line_portion_pct,
      x_last_update_date,
      x_last_updated_by,
      x_creation_date,
      x_created_by,
      x_last_update_login
     ) RETURNING expense_class_dtl_id INTO x_expense_class_dtl_id;

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
             x_expense_class_id              pn_rec_expcl_dtl.expense_class_id%TYPE,
             x_expense_line_id               pn_rec_expcl_dtl.expense_line_id%TYPE,
             x_expense_class_dtl_id          pn_rec_expcl_dtl.expense_class_dtl_id%TYPE,
             x_status                        pn_rec_expcl_dtl.status%TYPE,
             x_def_area_cls_id               pn_rec_expcl_dtl.default_area_class_id%TYPE,
             x_cls_line_fee_bf_ct            pn_rec_expcl_dtl.cls_line_fee_before_contr%TYPE,
             x_cls_line_fee_af_ct            pn_rec_expcl_dtl.cls_line_fee_after_contr%TYPE,
             x_cls_line_portion_pct          pn_rec_expcl_dtl.cls_line_portion_pct%TYPE,
             x_last_update_date              pn_rec_expcl_dtl.last_update_date%TYPE,
             x_last_updated_by               pn_rec_expcl_dtl.last_updated_by%TYPE,
             x_creation_date                 pn_rec_expcl_dtl.creation_date%TYPE,
             x_created_by                    pn_rec_expcl_dtl.created_by%TYPE,
             x_last_update_login             pn_rec_expcl_dtl.last_update_login%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_expcl_dtl_pkg.update_row';
BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   UPDATE pn_rec_expcl_dtl_all
   SET
      expense_class_id                 = x_expense_class_id,
      expense_line_id                  = x_expense_line_id,
      status                           = x_status,
      default_area_class_id            = x_def_area_cls_id,
      cls_line_fee_before_contr        = x_cls_line_fee_bf_ct,
      cls_line_fee_after_contr         = x_cls_line_fee_af_ct,
      cls_line_portion_pct             = x_cls_line_portion_pct,
      last_update_date                 = x_last_update_date,
      last_updated_by                  = x_last_updated_by,
      creation_date                    = x_creation_date,
      created_by                       = x_created_by,
      last_update_login                = x_last_update_login
   WHERE expense_class_dtl_id          = x_expense_class_dtl_id;

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
PROCEDURE delete_row(x_expense_class_dtl_id      pn_rec_expcl_dtl.expense_class_dtl_id%TYPE) IS
   l_desc VARCHAR2(100) := 'pn_rec_expcl_dtl_pkg.delete_row';
BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   DELETE pn_rec_expcl_dtl_all
   WHERE  expense_class_dtl_id = x_expense_class_dtl_id;

   pnp_debug_pkg.debug(l_desc ||' (-)');

EXCEPTION
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20001, to_char(sqlcode));
     app_exception.raise_exception;
END delete_row;

END pn_rec_expcl_dtl_pkg;

/
