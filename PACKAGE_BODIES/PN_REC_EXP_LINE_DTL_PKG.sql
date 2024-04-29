--------------------------------------------------------
--  DDL for Package Body PN_REC_EXP_LINE_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_REC_EXP_LINE_DTL_PKG" AS
/* $Header: PNREXLDB.pls 120.2 2005/11/30 23:40:33 appldev noship $ */

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 15-JUL-05  sdmahesh  o Replaced base views with their _ALL table.
-- 28-NOV-05  pikhar    o fetched org_id using cursor
-------------------------------------------------------------------------------
PROCEDURE insert_row(
             x_org_id                   pn_rec_exp_line_dtl.org_id%TYPE,
             x_expense_line_id          pn_rec_exp_line_dtl.expense_line_id%TYPE,
             x_expense_line_dtl_id      IN OUT NOCOPY pn_rec_exp_line_dtl.expense_line_dtl_id%TYPE,
             x_parent_expense_line_id   pn_rec_exp_line_dtl.parent_expense_line_id%TYPE,
             x_location_id              pn_rec_exp_line_dtl.location_id%TYPE,
             x_property_id              pn_rec_exp_line_dtl.property_id%TYPE,
             x_expense_type_code        pn_rec_exp_line_dtl.expense_type_code%TYPE,
             x_expense_account_id       pn_rec_exp_line_dtl.expense_account_id%TYPE,
             x_account_description      pn_rec_exp_line_dtl.account_description%TYPE,
             x_actual_amount            pn_rec_exp_line_dtl.actual_amount%TYPE,
             x_actual_amount_ovr        pn_rec_exp_line_dtl.actual_amount_ovr%TYPE,
             x_budgeted_amount          pn_rec_exp_line_dtl.budgeted_amount%TYPE,
             x_budgeted_amount_ovr      pn_rec_exp_line_dtl.budgeted_amount_ovr%TYPE,
             x_budgeted_pct             pn_rec_exp_line_dtl.budgeted_pct%TYPE,
             x_actual_pct               pn_rec_exp_line_dtl.actual_pct%TYPE,
             x_currency_code            pn_rec_exp_line_dtl.currency_code%TYPE,
             x_recoverable_flag         pn_rec_exp_line_dtl.recoverable_flag%TYPE,
             x_expense_line_indicator   pn_rec_exp_line_dtl.expense_line_indicator%TYPE,
             x_last_update_date         pn_rec_exp_line_dtl.last_update_date%TYPE,
             x_last_updated_by          pn_rec_exp_line_dtl.last_updated_by%TYPE,
             x_creation_date            pn_rec_exp_line_dtl.creation_date%TYPE,
             x_created_by               pn_rec_exp_line_dtl.created_by%TYPE,
             x_last_update_login        pn_rec_exp_line_dtl.last_update_login%TYPE,
             x_attribute_category       pn_rec_exp_line_dtl.attribute_category%TYPE,
             x_attribute1               pn_rec_exp_line_dtl.attribute1%TYPE,
             x_attribute2               pn_rec_exp_line_dtl.attribute2%TYPE,
             x_attribute3               pn_rec_exp_line_dtl.attribute3%TYPE,
             x_attribute4               pn_rec_exp_line_dtl.attribute4%TYPE,
             x_attribute5               pn_rec_exp_line_dtl.attribute5%TYPE,
             x_attribute6               pn_rec_exp_line_dtl.attribute6%TYPE,
             x_attribute7               pn_rec_exp_line_dtl.attribute7%TYPE,
             x_attribute8               pn_rec_exp_line_dtl.attribute8%TYPE,
             x_attribute9               pn_rec_exp_line_dtl.attribute9%TYPE,
             x_attribute10              pn_rec_exp_line_dtl.attribute10%TYPE,
             x_attribute11              pn_rec_exp_line_dtl.attribute11%TYPE,
             x_attribute12              pn_rec_exp_line_dtl.attribute12%TYPE,
             x_attribute13              pn_rec_exp_line_dtl.attribute13%TYPE,
             x_attribute14              pn_rec_exp_line_dtl.attribute14%TYPE,
             x_attribute15              pn_rec_exp_line_dtl.attribute15%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_exp_line_dtl_pkg.insert_row';

   CURSOR org_cur IS
    SELECT org_id
    FROM pn_rec_exp_line_all
    WHERE expense_line_id = x_expense_line_id;

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

   INSERT INTO pn_rec_exp_line_dtl_all(
      org_id,
      expense_line_id,
      expense_line_dtl_id,
      parent_expense_line_id,
      property_id,
      location_id,
      expense_type_code,
      expense_account_id,
      account_description,
      actual_amount,
      actual_amount_ovr,
      budgeted_amount,
      budgeted_amount_ovr,
      budgeted_pct,
      actual_pct,
      currency_code,
      recoverable_flag,
      expense_line_indicator,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15)
   VALUES(
      l_org_id,
      x_expense_line_id,
      pn_rec_exp_line_dtl_s.nextval,
      x_parent_expense_line_id,
      x_property_id,
      x_location_id,
      x_expense_type_code,
      x_expense_account_id,
      x_account_description,
      x_actual_amount,
      x_actual_amount_ovr,
      x_budgeted_amount,
      x_budgeted_amount_ovr,
      x_budgeted_pct,
      x_actual_pct,
      x_currency_code,
      x_recoverable_flag,
      x_expense_line_indicator,
      x_last_update_date,
      x_last_updated_by,
      x_creation_date,
      x_created_by,
      x_last_update_login,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15
   ) RETURNING expense_line_dtl_id INTO x_expense_line_dtl_id;

   pnp_debug_pkg.debug(l_desc ||' (-)');

EXCEPTION
 WHEN OTHERS THEN
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
             x_expense_line_dtl_id      pn_rec_exp_line_dtl.expense_line_dtl_id%TYPE,
             x_parent_expense_line_id   pn_rec_exp_line_dtl.parent_expense_line_id%TYPE,
             x_location_id              pn_rec_exp_line_dtl.location_id%TYPE,
             x_property_id              pn_rec_exp_line_dtl.property_id%TYPE,
             x_expense_type_code        pn_rec_exp_line_dtl.expense_type_code%TYPE,
             x_expense_account_id       pn_rec_exp_line_dtl.expense_account_id%TYPE,
             x_account_description      pn_rec_exp_line_dtl.account_description%TYPE,
             x_actual_amount            pn_rec_exp_line_dtl.actual_amount%TYPE,
             x_actual_amount_ovr        pn_rec_exp_line_dtl.actual_amount_ovr%TYPE,
             x_budgeted_amount          pn_rec_exp_line_dtl.budgeted_amount%TYPE,
             x_budgeted_amount_ovr      pn_rec_exp_line_dtl.budgeted_amount_ovr%TYPE,
             x_budgeted_pct             pn_rec_exp_line_dtl.budgeted_pct%TYPE,
             x_actual_pct               pn_rec_exp_line_dtl.actual_pct%TYPE,
             x_currency_code            pn_rec_exp_line_dtl.currency_code%TYPE,
             x_recoverable_flag         pn_rec_exp_line_dtl.recoverable_flag%TYPE,
             x_expense_line_indicator   pn_rec_exp_line_dtl.expense_line_indicator%TYPE,
             x_last_update_date         pn_rec_exp_line_dtl.last_update_date%TYPE,
             x_last_updated_by          pn_rec_exp_line_dtl.last_updated_by%TYPE,
             x_creation_date            pn_rec_exp_line_dtl.creation_date%TYPE,
             x_created_by               pn_rec_exp_line_dtl.created_by%TYPE,
             x_last_update_login        pn_rec_exp_line_dtl.last_update_login%TYPE,
             x_attribute_category       pn_rec_exp_line_dtl.attribute_category%TYPE,
             x_attribute1               pn_rec_exp_line_dtl.attribute1%TYPE,
             x_attribute2               pn_rec_exp_line_dtl.attribute2%TYPE,
             x_attribute3               pn_rec_exp_line_dtl.attribute3%TYPE,
             x_attribute4               pn_rec_exp_line_dtl.attribute4%TYPE,
             x_attribute5               pn_rec_exp_line_dtl.attribute5%TYPE,
             x_attribute6               pn_rec_exp_line_dtl.attribute6%TYPE,
             x_attribute7               pn_rec_exp_line_dtl.attribute7%TYPE,
             x_attribute8               pn_rec_exp_line_dtl.attribute8%TYPE,
             x_attribute9               pn_rec_exp_line_dtl.attribute9%TYPE,
             x_attribute10              pn_rec_exp_line_dtl.attribute10%TYPE,
             x_attribute11              pn_rec_exp_line_dtl.attribute11%TYPE,
             x_attribute12              pn_rec_exp_line_dtl.attribute12%TYPE,
             x_attribute13              pn_rec_exp_line_dtl.attribute13%TYPE,
             x_attribute14              pn_rec_exp_line_dtl.attribute14%TYPE,
             x_attribute15              pn_rec_exp_line_dtl.attribute15%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_exp_line_dtl_pkg.update_row';
BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   UPDATE pn_rec_exp_line_dtl_all
   SET parent_expense_line_id     = x_parent_expense_line_id,
       location_id                = x_location_id,
       property_id                = x_property_id,
       expense_type_code          = x_expense_type_code,
       expense_account_id         = x_expense_account_id,
       account_description        = x_account_description,
       actual_amount              = x_actual_amount,
       actual_amount_ovr          = x_actual_amount_ovr,
       budgeted_amount            = x_budgeted_amount,
       budgeted_amount_ovr        = x_budgeted_amount_ovr,
       budgeted_pct               = x_budgeted_pct,
       actual_pct                 = x_actual_pct,
       currency_code              = x_currency_code,
       recoverable_flag           = x_recoverable_flag,
       expense_line_indicator     = x_expense_line_indicator,
       last_update_date           = x_last_update_date,
       last_updated_by            = x_last_updated_by,
       creation_date              = x_creation_date,
       created_by                 = x_created_by,
       last_update_login          = x_last_update_login,
       attribute_category         = x_attribute_category,
       attribute1                 = x_attribute1,
       attribute2                 = x_attribute2,
       attribute3                 = x_attribute3,
       attribute4                 = x_attribute4,
       attribute5                 = x_attribute5,
       attribute6                 = x_attribute6,
       attribute7                 = x_attribute7,
       attribute8                 = x_attribute8,
       attribute9                 = x_attribute9,
       attribute10                = x_attribute10,
       attribute11                = x_attribute11,
       attribute12                = x_attribute12,
       attribute13                = x_attribute13,
       attribute14                = x_attribute14,
       attribute15                = x_attribute15
   WHERE expense_line_dtl_id      = x_expense_line_dtl_id;

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
PROCEDURE delete_row(x_expense_line_dtl_id      pn_rec_exp_line_dtl.expense_line_dtl_id%TYPE) IS
   l_desc VARCHAR2(100) := 'pn_rec_exp_line_dtl_pkg.delete_row';
BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   DELETE pn_rec_exp_line_dtl_all
   WHERE  expense_line_dtl_id = x_expense_line_dtl_id;

   pnp_debug_pkg.debug(l_desc ||' (-)');

EXCEPTION
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20001, to_char(sqlcode));
     app_exception.raise_exception;

END delete_row;

END pn_rec_exp_line_dtl_pkg;

/
