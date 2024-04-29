--------------------------------------------------------
--  DDL for Package PN_REC_EXPCL_DTLLN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_REC_EXPCL_DTLLN_PKG" AUTHID CURRENT_USER AS
/* $Header: PNRECLNS.pls 115.2 2003/05/12 18:35:53 ftanudja noship $ */

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
       );

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
             x_last_update_login             pn_rec_expcl_dtlln.last_update_login%TYPE
       );

PROCEDURE delete_row(x_expense_class_line_id    pn_rec_expcl_dtlln.expense_class_line_id%TYPE);

END pn_rec_expcl_dtlln_pkg;

 

/
