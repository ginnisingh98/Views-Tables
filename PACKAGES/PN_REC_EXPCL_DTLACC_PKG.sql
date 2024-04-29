--------------------------------------------------------
--  DDL for Package PN_REC_EXPCL_DTLACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_REC_EXPCL_DTLACC_PKG" AUTHID CURRENT_USER AS
/* $Header: PNRECLDS.pls 115.2 2003/05/13 18:22:52 ftanudja noship $ */

PROCEDURE insert_row(
             x_org_id                        pn_rec_expcl_dtlacc.org_id%TYPE,
             x_expense_class_line_id         pn_rec_expcl_dtlacc.expense_class_line_id%TYPE,
             x_expense_class_line_dtl_id     IN OUT NOCOPY pn_rec_expcl_dtlacc.expense_class_line_dtl_id%TYPE,
             x_expense_line_dtl_id           pn_rec_expcl_dtlacc.expense_line_dtl_id%TYPE,
             x_cls_line_dtl_share_pct        pn_rec_expcl_dtlacc.cls_line_dtl_share_pct%TYPE,
             x_cls_line_dtl_share_pct_ovr    pn_rec_expcl_dtlacc.cls_line_dtl_share_pct_ovr%TYPE,
             x_cls_line_dtl_fee_bf_ct        pn_rec_expcl_dtlacc.cls_line_dtl_fee_bf_contr%TYPE,
             x_cls_line_dtl_fee_bf_ct_ovr    pn_rec_expcl_dtlacc.cls_line_dtl_fee_bf_contr_ovr%TYPE,
             x_expense_account_id            pn_rec_expcl_dtlacc.expense_account_id%TYPE,
             x_expense_type_code             pn_rec_expcl_dtlacc.expense_type_code%TYPE,
             x_budgeted_amt                  pn_rec_expcl_dtlacc.budgeted_amt%TYPE,
             x_expense_amt                   pn_rec_expcl_dtlacc.expense_amt%TYPE,
             x_recoverable_amt               pn_rec_expcl_dtlacc.recoverable_amt%TYPE,
             x_computed_recoverable_amt      pn_rec_expcl_dtlacc.recoverable_amt%TYPE,
             x_last_update_date              pn_rec_expcl_dtlacc.last_update_date%TYPE,
             x_last_updated_by               pn_rec_expcl_dtlacc.last_updated_by%TYPE,
             x_creation_date                 pn_rec_expcl_dtlacc.creation_date%TYPE,
             x_created_by                    pn_rec_expcl_dtlacc.created_by%TYPE,
             x_last_update_login             pn_rec_expcl_dtlacc.last_update_login%TYPE
          );

PROCEDURE update_row(
             x_expense_class_line_dtl_id     pn_rec_expcl_dtlacc.expense_class_line_dtl_id%TYPE,
             x_expense_line_dtl_id           pn_rec_expcl_dtlacc.expense_line_dtl_id%TYPE,
             x_cls_line_dtl_share_pct        pn_rec_expcl_dtlacc.cls_line_dtl_share_pct%TYPE,
             x_cls_line_dtl_share_pct_ovr    pn_rec_expcl_dtlacc.cls_line_dtl_share_pct_ovr%TYPE,
             x_cls_line_dtl_fee_bf_ct        pn_rec_expcl_dtlacc.cls_line_dtl_fee_bf_contr%TYPE,
             x_cls_line_dtl_fee_bf_ct_ovr    pn_rec_expcl_dtlacc.cls_line_dtl_fee_bf_contr_ovr%TYPE,
             x_expense_account_id            pn_rec_expcl_dtlacc.expense_account_id%TYPE,
             x_expense_type_code             pn_rec_expcl_dtlacc.expense_type_code%TYPE,
             x_budgeted_amt                  pn_rec_expcl_dtlacc.budgeted_amt%TYPE,
             x_expense_amt                   pn_rec_expcl_dtlacc.expense_amt%TYPE,
             x_recoverable_amt               pn_rec_expcl_dtlacc.recoverable_amt%TYPE,
             x_computed_recoverable_amt      pn_rec_expcl_dtlacc.recoverable_amt%TYPE,
             x_last_update_date              pn_rec_expcl_dtlacc.last_update_date%TYPE,
             x_last_updated_by               pn_rec_expcl_dtlacc.last_updated_by%TYPE,
             x_creation_date                 pn_rec_expcl_dtlacc.creation_date%TYPE,
             x_created_by                    pn_rec_expcl_dtlacc.created_by%TYPE,
             x_last_update_login             pn_rec_expcl_dtlacc.last_update_login%TYPE
       );

PROCEDURE delete_row(x_expense_class_line_dtl_id    pn_rec_expcl_dtlacc.expense_class_line_dtl_id%TYPE);

END pn_rec_expcl_dtlacc_pkg;

 

/
