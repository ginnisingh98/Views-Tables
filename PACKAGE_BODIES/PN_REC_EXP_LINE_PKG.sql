--------------------------------------------------------
--  DDL for Package Body PN_REC_EXP_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_REC_EXP_LINE_PKG" AS
/* $Header: PNREXLHB.pls 120.1 2005/07/25 07:43:48 appldev noship $ */

-------------------------------------------------------------------------------
-- PROCDURE     : INSERT_ROW
-- INVOKED FROM : insert_row procedure
-- PURPOSE      : inserts the row
-- HISTORY      :
-- 15-JUL-05  sdmahesh  o Replaced base views with their _ALL table.
-------------------------------------------------------------------------------
PROCEDURE insert_row(
             x_org_id                  pn_rec_exp_line.org_id%TYPE,
             x_expense_line_id         IN OUT NOCOPY pn_rec_exp_line.expense_line_id%TYPE,
             x_expense_extract_code    IN OUT NOCOPY pn_rec_exp_line.expense_extract_code%TYPE,
             x_currency_code           pn_rec_exp_line.currency_code%TYPE,
             x_as_of_date              pn_rec_exp_line.as_of_date%TYPE,
             x_from_date               pn_rec_exp_line.from_date%TYPE,
             x_to_date                 pn_rec_exp_line.to_date%TYPE,
             x_location_id             pn_rec_exp_line.location_id%TYPE,
             x_property_id             pn_rec_exp_line.property_id%TYPE,
             x_last_update_date        pn_rec_exp_line.last_update_date%TYPE,
             x_last_updated_by         pn_rec_exp_line.last_updated_by%TYPE,
             x_creation_date           pn_rec_exp_line.creation_date%TYPE,
             x_created_by              pn_rec_exp_line.created_by%TYPE,
             x_last_update_login       pn_rec_exp_line.last_update_login%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_exp_line_pkg.insert_row';
BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   INSERT INTO pn_rec_exp_line_all        /*sdm14jul*/
   (
      org_id,
      expense_line_id,
      expense_extract_code,
      currency_code,
      as_of_date,
      from_date,
      to_date,
      location_id,
      property_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login)
   VALUES(
      x_org_id,
      pn_rec_exp_line_s.nextval,
      nvl(x_expense_extract_code, pn_rec_exp_line_s.currval),
      x_currency_code,
      x_as_of_date,
      x_from_date,
      x_to_date,
      x_location_id,
      x_property_id,
      x_last_update_date,
      x_last_updated_by,
      x_creation_date,
      x_created_by,
      x_last_update_login
   ) RETURNING expense_line_id, expense_extract_code INTO x_expense_line_id, x_expense_extract_code;

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
             x_expense_line_id         pn_rec_exp_line.expense_line_id%TYPE,
             x_expense_extract_code    pn_rec_exp_line.expense_extract_code%TYPE,
             x_currency_code           pn_rec_exp_line.currency_code%TYPE,
             x_as_of_date              pn_rec_exp_line.as_of_date%TYPE,
             x_from_date               pn_rec_exp_line.from_date%TYPE,
             x_to_date                 pn_rec_exp_line.to_date%TYPE,
             x_location_id             pn_rec_exp_line.location_id%TYPE,
             x_property_id             pn_rec_exp_line.property_id%TYPE,
             x_last_update_date        pn_rec_exp_line.last_update_date%TYPE,
             x_last_updated_by         pn_rec_exp_line.last_updated_by%TYPE,
             x_creation_date           pn_rec_exp_line.creation_date%TYPE,
             x_created_by              pn_rec_exp_line.created_by%TYPE,
             x_last_update_login       pn_rec_exp_line.last_update_login%TYPE)
IS
   l_desc VARCHAR2(100) := 'pn_rec_exp_line_pkg.update_row';
BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   UPDATE pn_rec_exp_line_all             /*sdm_14jul*/
   SET
      expense_extract_code    = x_expense_extract_code,
      currency_code           = x_currency_code,
      as_of_date              = x_as_of_date,
      from_date               = x_from_date,
      to_date                 = x_to_date,
      location_id             = x_location_id,
      property_id             = x_property_id,
      last_update_date        = x_last_update_date,
      last_updated_by         = x_last_updated_by,
      creation_date           = x_creation_date,
      created_by              = x_created_by,
      last_update_login       = x_last_update_login
   WHERE expense_line_id      = x_expense_line_id;

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
PROCEDURE delete_row(x_expense_line_id      pn_rec_exp_line.expense_line_id%TYPE) IS
   l_desc VARCHAR2(100) := 'pn_rec_exp_line_pkg.delete_row';
BEGIN

   pnp_debug_pkg.debug(l_desc ||' (+)');

   DELETE pn_rec_exp_line_all          /*sdm14jul*/
   WHERE  expense_line_id = x_expense_line_id;

   pnp_debug_pkg.debug(l_desc ||' (-)');

EXCEPTION
   WHEN OTHERS THEN
     RAISE_APPLICATION_ERROR(-20001, to_char(sqlcode));
     app_exception.raise_exception;
END delete_row;

END pn_rec_exp_line_pkg;

/
