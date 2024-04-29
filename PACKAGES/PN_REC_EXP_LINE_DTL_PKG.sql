--------------------------------------------------------
--  DDL for Package PN_REC_EXP_LINE_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_REC_EXP_LINE_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: PNREXLDS.pls 115.3 2003/08/15 23:13:01 ftanudja noship $ */

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
             x_attribute15              pn_rec_exp_line_dtl.attribute15%TYPE);

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
             x_attribute15              pn_rec_exp_line_dtl.attribute15%TYPE);

PROCEDURE delete_row(x_expense_line_dtl_id      pn_rec_exp_line_dtl.expense_line_dtl_id%TYPE);

END pn_rec_exp_line_dtl_pkg;

 

/
