--------------------------------------------------------
--  DDL for Package PN_REC_EXP_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_REC_EXP_LINE_PKG" AUTHID CURRENT_USER AS
/* $Header: PNREXLHS.pls 115.2 2003/07/03 01:01:48 ftanudja noship $ */

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
             x_last_update_login       pn_rec_exp_line.last_update_login%TYPE);

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
             x_last_update_login       pn_rec_exp_line.last_update_login%TYPE);

PROCEDURE delete_row(x_expense_line_id      pn_rec_exp_line.expense_line_id%TYPE);

END pn_rec_exp_line_pkg;

 

/
