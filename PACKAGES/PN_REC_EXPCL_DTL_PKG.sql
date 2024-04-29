--------------------------------------------------------
--  DDL for Package PN_REC_EXPCL_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_REC_EXPCL_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: PNRECLSS.pls 115.1 2003/05/12 18:35:08 ftanudja noship $ */

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
             x_last_update_login             pn_rec_expcl_dtl.last_update_login%TYPE
       );

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
             x_last_update_login             pn_rec_expcl_dtl.last_update_login%TYPE
       );

PROCEDURE delete_row(x_expense_class_dtl_id      pn_rec_expcl_dtl.expense_class_dtl_id%TYPE);

END pn_rec_expcl_dtl_pkg;

 

/
