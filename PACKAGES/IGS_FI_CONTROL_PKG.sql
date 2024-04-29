--------------------------------------------------------
--  DDL for Package IGS_FI_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_CONTROL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI78S.pls 120.2 2006/06/19 09:29:53 sapanigr ship $ */

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.FMB

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  svuppala        14-JUL-2005     Enh 3392095 - Tution Waivers build
                                  Modified insert_row, lock_row, update_row and before_dml by adding two new columns
                                  post_waiver_gl_flag, waiver_notify_finaid_flag
  uudayapr        07-dec-2003      Enh#3167098 Modified the procedures BY  removing the reference to prg_chg_dt_alias
                                                and adding res_dt_alias.
  shtatiko        27-MAY-2003     Enh# 2831582, Removed references to columns lockbox_context, lockbox_number_attribute
                                                and ar_int_org_id.
  vvutukur        16-May-2003     Enh#2831572.Financial Accounting Build. Added column acct_conv_flag.
  pathipat        14-Apr-2003     Enh. 2831569 - Commercial Receivables build
                                  Added col manage_accounts, removed cols interface_line_context, interface_line_attribute,
                                  batch_source_id, cust_trx_type_id, term_id
  smadathi        18-Feb-2002     Enh. Bug 2747329.Added new columns rfnd_destination, ap_org_id, dflt_supplier_site_name
  smadathi        01-Nov-2002     Enh. Bug 2584986. Added new column currency_cd
  pathipat        02-OCT-2002     Added column  x_conv_process_run_ind, part of Enh Bug: 2562745
  smvk            24-Sep-2002     Added the columns rec_gl_ccid, cash_gl_ccid, unapp_gl_ccid,
                                  rec_account_cd, rev_account_cd, cash_account_cd and
                                  unapp_account_cd. As a part of Bug # 2564643.
  vchappid        01-Apr-2002     Bug# 2293676, Added column planned_credits_ind
  smvk            13-Mar-2002     Added four columns refund_dr_gl_ccid, refund_cr_gl_ccid,
                                  refund_dr_account_cd, refund_cr_account_cd, refund_dt_alias and
                                  removed last_account_trans, last_payment_trans,
                                  last_pay_term_trans w.r.t Bug # 2144600
  msrinivi        17 Jul,2001    Added 1 new col : set_of_books_id
  vvutukur        13-02-2002     Added new col   :  ar_int_org_id
  *******************************************************************************/
 PROCEDURE insert_row (
       x_rowid                      IN OUT NOCOPY VARCHAR2,
       x_rec_installed              IN VARCHAR2,
       x_mode                       IN VARCHAR2 DEFAULT 'R',
       x_accounting_method          IN VARCHAR2,
       x_set_of_books_id            IN NUMBER   DEFAULT NULL,
       x_refund_dr_gl_ccid          IN NUMBER   DEFAULT NULL,
       x_refund_cr_gl_ccid          IN NUMBER   DEFAULT NULL,
       x_refund_dr_account_cd       IN VARCHAR2 DEFAULT NULL,
       x_refund_cr_account_cd       IN VARCHAR2 DEFAULT NULL,
       x_refund_dt_alias            IN VARCHAR2 DEFAULT NULL,
       x_fee_calc_mthd_code         IN VARCHAR2 DEFAULT NULL,
       x_planned_credits_ind        IN VARCHAR2 DEFAULT NULL,
       x_rec_gl_ccid                IN NUMBER   DEFAULT NULL,
       x_cash_gl_ccid               IN NUMBER   DEFAULT NULL,
       x_unapp_gl_ccid              IN NUMBER   DEFAULT NULL,
       x_rec_account_cd             IN VARCHAR2 DEFAULT NULL,
       x_rev_account_cd             IN VARCHAR2 DEFAULT NULL,
       x_cash_account_cd            IN VARCHAR2 DEFAULT NULL,
       x_unapp_account_cd           IN VARCHAR2 DEFAULT NULL,
       x_conv_process_run_ind       IN NUMBER   DEFAULT NULL,
       x_currency_cd                IN VARCHAR2 DEFAULT NULL,
       x_rfnd_destination           IN VARCHAR2 DEFAULT NULL,
       x_ap_org_id                  IN NUMBER   DEFAULT NULL,
       x_dflt_supplier_site_name    IN VARCHAR2 DEFAULT NULL,
       x_manage_accounts            IN VARCHAR2 DEFAULT NULL,
       x_acct_conv_flag             IN VARCHAR2 DEFAULT NULL,
       x_post_waiver_gl_flag        IN VARCHAR2 DEFAULT NULL,
       x_waiver_notify_finaid_flag  IN VARCHAR2 DEFAULT NULL
  );


  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  svuppala        14-JUL-2005     Enh 3392095 - Tution Waivers build
                                  Modified by adding two new columns post_waiver_gl_flag, waiver_notify_finaid_flag
|  uudayapr        07-dec-2003      Enh#3167098 Modified the procedures BY  removing the reference to prg_chg_dt_alias
                                                and adding res_dt_alias.
  shtatiko        27-MAY-2003     Enh# 2831582, Removed references to columns lockbox_context, lockbox_number_attribute
                                                and ar_int_org_id.
  vvutukur        16-May-2003     Enh#2831572.Financial Accounting Build. Added column acct_conv_flag.
  pathipat        14-Apr-2003     Enh. 2831569 - Commercial Receivables build
                                  Added col manage_accounts, removed cols interface_line_context, interface_line_attribute,
                                  batch_source_id, cust_trx_type_id, term_id
  smadathi        18-Feb-2002     Enh. Bug 2747329.Added new columns rfnd_destination, ap_org_id, dflt_supplier_site_name
  smadathi        01-Nov-2002     Enh. Bug 2584986. Added new column currency_cd
  pathipat        02-OCT-2002     Added column  x_conv_process_run_ind, part of Enh Bug: 2562745
  smvk            24-Sep-2002     Added the columns rec_gl_ccid, cash_gl_ccid, unapp_gl_ccid,
                                  rec_account_cd, rev_account_cd, cash_account_cd and
                                  unapp_account_cd. As a part of Bug # 2564643.
  vchappid        01-Apr-2002     Bug# 2293676, Added column planned_credits_ind
  smvk            13-Mar-2002     Added four columns refund_dr_gl_ccid, refund_cr_gl_ccid,
                                  refund_dr_account_cd, refund_cr_account_cd, refund_dt_alias and
                                  removed last_account_trans, last_payment_trans,
                                  last_pay_term_trans w.r.t Bug # 2144600
  msrinivi        17 Jul,2001    Added 1 new col : set_of_books_id
  vvutukur        13-02-2002     Added new col   :  ar_int_org_id
  *******************************************************************************/
 PROCEDURE lock_row (
       x_rowid                      IN VARCHAR2,
       x_rec_installed              IN VARCHAR2,
       x_accounting_method          IN VARCHAR2,
       x_set_of_books_id            IN NUMBER   DEFAULT NULL,
       x_refund_dr_gl_ccid          IN NUMBER   DEFAULT NULL,
       x_refund_cr_gl_ccid          IN NUMBER   DEFAULT NULL,
       x_refund_dr_account_cd       IN VARCHAR2 DEFAULT NULL,
       x_refund_cr_account_cd       IN VARCHAR2 DEFAULT NULL,
       x_refund_dt_alias            IN VARCHAR2 DEFAULT NULL,
       x_fee_calc_mthd_code         IN VARCHAR2 DEFAULT NULL,
       x_planned_credits_ind        IN VARCHAR2 DEFAULT NULL,
       x_rec_gl_ccid                IN NUMBER   DEFAULT NULL,
       x_cash_gl_ccid               IN NUMBER   DEFAULT NULL,
       x_unapp_gl_ccid              IN NUMBER   DEFAULT NULL,
       x_rec_account_cd             IN VARCHAR2 DEFAULT NULL,
       x_rev_account_cd             IN VARCHAR2 DEFAULT NULL,
       x_cash_account_cd            IN VARCHAR2 DEFAULT NULL,
       x_unapp_account_cd           IN VARCHAR2 DEFAULT NULL,
       x_conv_process_run_ind       IN NUMBER   DEFAULT NULL,
       x_currency_cd                IN VARCHAR2 DEFAULT NULL,
       x_rfnd_destination           IN VARCHAR2 DEFAULT NULL,
       x_ap_org_id                  IN NUMBER   DEFAULT NULL,
       x_dflt_supplier_site_name    IN VARCHAR2 DEFAULT NULL,
       x_manage_accounts            IN VARCHAR2 DEFAULT NULL,
       x_acct_conv_flag             IN VARCHAR2 DEFAULT NULL,
       x_post_waiver_gl_flag        IN VARCHAR2 DEFAULT NULL,
       x_waiver_notify_finaid_flag  IN VARCHAR2 DEFAULT NULL
         );

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  svuppala        14-JUL-2005     Enh 3392095 - Tution Waivers build
                                  Modified by adding two new columns post_waiver_gl_flag, waiver_notify_finaid_flag
  uudayapr        07-dec-2003      Enh#3167098 Modified the procedures BY  removing the reference to prg_chg_dt_alias
                                                and adding res_dt_alias.
  shtatiko        27-MAY-2003     Enh# 2831582, Removed references to columns lockbox_context, lockbox_number_attribute
                                                and ar_int_org_id.
  vvutukur        16-May-2003     Enh#2831572.Financial Accounting Build. Added column acct_conv_flag.
  pathipat        14-Apr-2003     Enh. 2831569 - Commercial Receivables build
                                  Added col manage_accounts, removed cols interface_line_context, interface_line_attribute,
                                  batch_source_id, cust_trx_type_id, term_id
  smadathi        18-Feb-2002     Enh. Bug 2747329.Added new columns rfnd_destination, ap_org_id, dflt_supplier_site_name
  smadathi        01-Nov-2002     Enh. Bug 2584986. Added new column currency_cd
  pathipat        02-OCT-2002     Added column  x_conv_process_run_ind, part of Enh Bug: 2562745
  smvk            24-Sep-2002     Added the columns rec_gl_ccid, cash_gl_ccid, unapp_gl_ccid,
                                  rec_account_cd, rev_account_cd, cash_account_cd and
                                  unapp_account_cd. As a part of Bug # 2564643.
  vchappid        01-Apr-2002     Bug# 2293676, Added column planned_credits_ind
  smvk            13-Mar-2002     Added four columns refund_dr_gl_ccid, refund_cr_gl_ccid,
                                  refund_dr_account_cd, refund_cr_account_cd, refund_dt_alias and
                                  removed last_account_trans, last_payment_trans,
                                  last_pay_term_trans w.r.t Bug # 2144600
  msrinivi        17 Jul,2001    Added 1 new col : set_of_books_id
  vvutukur        13-02-2002     Added new col   :  ar_int_org_id
  *******************************************************************************/
 PROCEDURE update_row (
       x_rowid                      IN  VARCHAR2,
       x_rec_installed              IN VARCHAR2,
       x_mode                       IN VARCHAR2 DEFAULT 'R',
       x_accounting_method          IN VARCHAR2,
       x_set_of_books_id            IN NUMBER   DEFAULT NULL,
       x_refund_dr_gl_ccid          IN NUMBER   DEFAULT NULL,
       x_refund_cr_gl_ccid          IN NUMBER   DEFAULT NULL,
       x_refund_dr_account_cd       IN VARCHAR2 DEFAULT NULL,
       x_refund_cr_account_cd       IN VARCHAR2 DEFAULT NULL,
       x_refund_dt_alias            IN VARCHAR2 DEFAULT NULL,
       x_fee_calc_mthd_code         IN VARCHAR2 DEFAULT NULL,
       x_planned_credits_ind        IN VARCHAR2 DEFAULT NULL,
       x_rec_gl_ccid                IN NUMBER   DEFAULT NULL,
       x_cash_gl_ccid               IN NUMBER   DEFAULT NULL,
       x_unapp_gl_ccid              IN NUMBER   DEFAULT NULL,
       x_rec_account_cd             IN VARCHAR2 DEFAULT NULL,
       x_rev_account_cd             IN VARCHAR2 DEFAULT NULL,
       x_cash_account_cd            IN VARCHAR2 DEFAULT NULL,
       x_unapp_account_cd           IN VARCHAR2 DEFAULT NULL,
       x_conv_process_run_ind       IN NUMBER   DEFAULT NULL,
       x_currency_cd                IN VARCHAR2 DEFAULT NULL,
       x_rfnd_destination           IN VARCHAR2 DEFAULT NULL,
       x_ap_org_id                  IN NUMBER   DEFAULT NULL,
       x_dflt_supplier_site_name    IN VARCHAR2 DEFAULT NULL,
       x_manage_accounts            IN VARCHAR2 DEFAULT NULL,
       x_acct_conv_flag             IN VARCHAR2 DEFAULT NULL,
       x_post_waiver_gl_flag        IN VARCHAR2 DEFAULT NULL,
       x_waiver_notify_finaid_flag  IN VARCHAR2 DEFAULT NULL
  );


  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) ;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)
     1. Called from IGSTR007.FMB

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/


  FUNCTION get_pk_for_validation (
    x_rec_installed IN VARCHAR2
    ) RETURN BOOLEAN ;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/

  PROCEDURE get_fk_igs_ca_da (
    x_dt_alias           IN     VARCHAR2
  );
  /*******************************************************************************
  Created by  : svuppala , Oracle IDC
  Date created: 03-Apr-2006

  Purpose:
  This procedure is created as part of the bug 4025077 to add FK relation for refund_dt_alias
  coulmn in IGS_FI_CONTROL table with dt_alias coulmn in IGS_CA_DA table.

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/

  PROCEDURE check_constraints (
               column_name  IN VARCHAR2  DEFAULT NULL,
               column_value IN VARCHAR2  DEFAULT NULL ) ;

  /*******************************************************************************
  Created by  : Oracle IDC
  Date created:

  Purpose:
     1. This function returns the status of a tracking group

  Usage: (e.g. restricted, unrestricted, where to call from)

  Known limitations/enhancements/remarks:
     -

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  svuppala        14-JUL-2005     Enh 3392095 - Tution Waivers build
                                  Modified by adding two new columns post_waiver_gl_flag, waiver_notify_finaid_flag
  uudayapr        07-dec-2003      Enh#3167098 Modified the procedures BY  removing the reference to prg_chg_dt_alias
                                                and adding res_dt_alias.
  shtatiko        27-MAY-2003     Enh# 2831582, Removed references to columns lockbox_context, lockbox_number_attribute
                                                and ar_int_org_id.
  vvutukur        16-May-2003     Enh#2831572.Financial Accounting Build. Added column acct_conv_flag.
  pathipat        14-Apr-2003     Enh. 2831569 - Commercial Receivables build
                                  Added col manage_accounts, removed cols interface_line_context, interface_line_attribute,
                                  batch_source_id, cust_trx_type_id, term_id
  smadathi        18-Feb-2002     Enh. Bug 2747329.Added new columns rfnd_destination, ap_org_id, dflt_supplier_site_name
  smadathi        01-Nov-2002     Enh. Bug 2584986. Added new column currency_cd
  pathipat        02-OCT-2002     Added column  x_conv_process_run_ind, part of Enh Bug: 2562745
  smvk            24-Sep-2002     Added the columns rec_gl_ccid, cash_gl_ccid, unapp_gl_ccid,
                                  rec_account_cd, rev_account_cd, cash_account_cd and
                                  unapp_account_cd. As a part of Bug # 2564643.
  vchappid        01-Apr-2002     Bug# 2293676, Added column planned_credits_ind
  smvk            13-Mar-2002     Added four columns refund_dr_gl_ccid, refund_cr_gl_ccid,
                                  refund_dr_account_cd, refund_cr_account_cd, refund_dt_alias and
                                  removed last_account_trans, last_payment_trans,
                                  last_pay_term_trans w.r.t Bug # 2144600
  msrinivi        17 Jul,2001    Added 1 new col: set_of_books_id
  vvutukur        13-02-2002     Added new col  :  ar_int_org_id
  *******************************************************************************/

  PROCEDURE before_dml (
    p_action                     IN VARCHAR2,
    x_rowid                      IN VARCHAR2 DEFAULT NULL,
    x_rec_installed              IN VARCHAR2 DEFAULT NULL,
    x_creation_date              IN DATE     DEFAULT NULL,
    x_created_by                 IN NUMBER   DEFAULT NULL,
    x_last_update_date           IN DATE     DEFAULT NULL,
    x_last_updated_by            IN NUMBER   DEFAULT NULL,
    x_last_update_login          IN NUMBER   DEFAULT NULL,
    x_ACCOUNTING_METHOD          IN VARCHAR2 DEFAULT NULL,
    x_set_of_books_id            IN NUMBER   DEFAULT NULL,
    x_refund_dr_gl_ccid          IN NUMBER   DEFAULT NULL,
    x_refund_cr_gl_ccid          IN NUMBER   DEFAULT NULL,
    x_refund_dr_account_cd       IN VARCHAR2 DEFAULT NULL,
    x_refund_cr_account_cd       IN VARCHAR2 DEFAULT NULL,
    x_refund_dt_alias            IN VARCHAR2 DEFAULT NULL,
    x_fee_calc_mthd_code         IN VARCHAR2 DEFAULT NULL,
    x_planned_credits_ind        IN VARCHAR2 DEFAULT NULL,
    x_rec_gl_ccid                IN NUMBER   DEFAULT NULL,
    x_cash_gl_ccid               IN NUMBER   DEFAULT NULL,
    x_unapp_gl_ccid              IN NUMBER   DEFAULT NULL,
    x_rec_account_cd             IN VARCHAR2 DEFAULT NULL,
    x_rev_account_cd             IN VARCHAR2 DEFAULT NULL,
    x_cash_account_cd            IN VARCHAR2 DEFAULT NULL,
    x_unapp_account_cd           IN VARCHAR2 DEFAULT NULL,
    x_conv_process_run_ind       IN NUMBER   DEFAULT NULL,
    x_currency_cd                IN VARCHAR2 DEFAULT NULL,
    x_rfnd_destination           IN VARCHAR2 DEFAULT NULL,
    x_ap_org_id                  IN NUMBER   DEFAULT NULL,
    x_dflt_supplier_site_name    IN VARCHAR2 DEFAULT NULL,
    x_manage_accounts            IN VARCHAR2 DEFAULT NULL,
    x_acct_conv_flag             IN VARCHAR2 DEFAULT NULL,
    x_post_waiver_gl_flag        IN VARCHAR2 DEFAULT NULL,
    x_waiver_notify_finaid_flag  IN VARCHAR2 DEFAULT NULL
 );

END igs_fi_control_pkg;

 

/
