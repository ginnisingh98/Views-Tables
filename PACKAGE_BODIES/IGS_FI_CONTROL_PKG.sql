--------------------------------------------------------
--  DDL for Package Body IGS_FI_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_CONTROL_PKG" AS
/* $Header: IGSSI78B.pls 120.2 2006/06/19 09:25:06 sapanigr ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_control_all%RowType;
  new_references igs_fi_control_all%RowType;

  PROCEDURE set_column_values (
    p_action                   IN VARCHAR2,
    x_rowid                    IN VARCHAR2 ,
    x_rec_installed            IN VARCHAR2 ,
    x_creation_date            IN DATE ,
    x_created_by               IN NUMBER ,
    x_last_update_date         IN DATE ,
    x_last_updated_by          IN NUMBER ,
    x_last_update_login        IN NUMBER ,
    x_accounting_method        IN VARCHAR2 ,
    x_set_of_books_id          IN NUMBER ,
    x_refund_dr_gl_ccid        IN NUMBER ,
    x_refund_cr_gl_ccid        IN NUMBER ,
    x_refund_dr_account_cd     IN VARCHAR2 ,
    x_refund_cr_account_cd     IN VARCHAR2 ,
    x_refund_dt_alias          IN VARCHAR2 ,
    x_fee_calc_mthd_code       IN VARCHAR2 ,
    x_planned_credits_ind      IN VARCHAR2 ,
    x_rec_gl_ccid              IN NUMBER ,
    x_cash_gl_ccid             IN NUMBER ,
    x_unapp_gl_ccid            IN NUMBER ,
    x_rec_account_cd           IN VARCHAR2 ,
    x_rev_account_cd           IN VARCHAR2 ,
    x_cash_account_cd          IN VARCHAR2 ,
    x_unapp_account_cd         IN VARCHAR2,
    x_conv_process_run_ind     IN NUMBER,
    x_currency_cd              IN VARCHAR2 ,
    x_rfnd_destination         IN VARCHAR2,
    x_ap_org_id                IN NUMBER,
    x_dflt_supplier_site_name  IN VARCHAR2,
    x_manage_accounts          IN VARCHAR2,
    x_acct_conv_flag           IN VARCHAR2,
    x_post_waiver_gl_flag      IN VARCHAR2,
    x_waiver_notify_finaid_flag IN VARCHAR2

  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  svuppala        14-JUL-2005     Enh 3392095 - Tution Waivers build
                                  Modified by adding two new columns post_waiver_gl_flag, waiver_notify_finaid_flag
  uudayapr        07-dec-2003      Enh#3167098 Modified the procedures BY  removing the reference to prg_chg_dt_alias
                                                and adding res_dt_alias.
  shtatiko        27-MAY-2003     Enh# 2831582, Removed references to columns lockbox_context, lockbox_number_attribute
                                  and ar_int_org_id.
  vvutukur        16-May-2003     Enh#2831572.Financial Accounting Build. Added column acct_conv_flag.
  pathipat        14-Apr-2003     Enh. 2831569 - Commercial Receivables Interface
                                  Removed references to columns interface_line_context, interface_line_attribute, term_id,
                                  batch_source_id, cust_trx_type_id. Added column manage_accounts
  smadathi        18-Feb-2002     Enh. Bug 2747329.Added new columns rfnd_destination, ap_org_id, dflt_supplier_site_name
  smadathi        01-Nov-2002     Enh Bug 2584986. Added new column currency_cd
  pathipat        02-OCT-2002     Added column  x_conv_process_run_ind, part of Enh Bug: 2562745
  smvk            24-Sep-2002     Added the columns rec_gl_ccid, cash_gl_ccid, unapp_gl_ccid,
                                  rec_account_cd, rev_account_cd, cash_account_cd and
                                  unapp_account_cd. As a part of Bug # 2564643.
  vchappid        01-Apr-2002     Bug# 2293676, Added column planned_credits_ind
  smvk            13-Mar-2002     Added four columns refund_cr_gl_ccid, refund_dr_gl_ccid
                                  refund_dr_account_cd, refund_cr_account_cd, refund_dt_alias and
                                  removed last_account_trans, last_payment_trans and
                                  last_pay_term_trans w.r.t. Bug # 2144600
  vvutukur        13-02-2002     Added a new column, ar_int_org_id for bug 2222272
  msrinivi        17 Jul, 2001   Added a new column, set_of_books_id
  ***************************************************************/
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_CONTROL_ALL
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.rec_installed := x_rec_installed;
    new_references.accounting_method := x_accounting_method;
    new_references.set_of_books_id := x_set_of_books_id;
    new_references.refund_dr_gl_ccid :=x_refund_dr_gl_ccid ;
    new_references.refund_cr_gl_ccid :=x_refund_cr_gl_ccid ;
    new_references.refund_dr_account_cd := x_refund_dr_account_cd ;
    new_references.refund_cr_account_cd  :=x_refund_cr_account_cd ;
    new_references.refund_dt_alias :=x_refund_dt_alias;
    new_references.fee_calc_mthd_code :=x_fee_calc_mthd_code;
    new_references.planned_credits_ind := x_planned_credits_ind;
    new_references.rec_gl_ccid := x_rec_gl_ccid;
    new_references.cash_gl_ccid := x_cash_gl_ccid;
    new_references.unapp_gl_ccid := x_unapp_gl_ccid;
    new_references.rec_account_cd  := x_rec_account_cd;
    new_references.rev_account_cd  := x_rev_account_cd;
    new_references.cash_account_cd := x_cash_account_cd;
    new_references.unapp_account_cd:= x_unapp_account_cd;
    new_references.conv_process_run_ind := x_conv_process_run_ind;
    new_references.currency_cd := x_currency_cd;
    new_references.rfnd_destination         := x_rfnd_destination;
    new_references.ap_org_id                := x_ap_org_id;
    new_references.dflt_supplier_site_name  := x_dflt_supplier_site_name;
    new_references.manage_accounts          := x_manage_accounts;
    new_references.acct_conv_flag           := x_acct_conv_flag;
    new_references.post_waiver_gl_flag      := x_post_waiver_gl_flag;
    new_references.waiver_notify_finaid_flag := x_waiver_notify_finaid_flag;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
  END set_column_values;


  PROCEDURE check_constraints (
                 Column_Name IN VARCHAR2  ,
                 Column_Value IN VARCHAR2   ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pathipat        14-Apr-2003     Enh. 2831569 - Commercial Receivables Interface
                                  Added constraint for new column manage_accounts
  smadathi        01-Nov-2002     Enh Bug 2584986. Added check constraint for new column currency_cd
  vchappid        01-Apr-2002     Bug# 2293676, Added check constraint for the Planned Credits Ind column
  smvk            13-Mar-2002     Added check for refund_dt_alias as one time setup field
  sarakshi        09-Jan-2002     replaced igs_fi_gen_005.finp_get_receivables_inst
                                  by new_references.accounting method in the line where comparing with 'N'
  agairola        09-May-01       Added the check for
                                  accounting method(not null)
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN
      IF column_name IS NULL THEN
        NULL;
      ELSIF UPPER(Column_Name) = 'ACCOUNTING_METHOD' THEN
        new_references.accounting_method := column_value;
      ELSIF UPPER(Column_Name) = 'CURRENCY_CD' THEN
        new_references.currency_cd := column_value;
      END IF;

-- Added the check for accounting method not null
      IF UPPER(column_name) = 'ACCOUNTING_METHOD' or column_name is NULL THEN
        IF new_references.accounting_method IS NULL  AND
          new_references.accounting_method <> 'N'   THEN
          fnd_message.set_name('IGS',
                               'IGS_FI_ACCNT_MTHD_NULL_NA');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
        END IF;
      END IF;

-- Added the check for refund_dt_alias as a one time initialisation field as Per Enh Bug # 2144600
        IF ((NOT old_references.refund_dt_alias IS NULL) AND
            (old_references.refund_dt_alias <> new_references.refund_dt_alias )) THEN
                fnd_message.set_name('IGS','IGS_FI_REFUND_DT_ONE_TIME_SET');
                igs_ge_msg_stack.add;
                app_exception.raise_exception;
        END IF;

-- Added the check for planned_credits_ind not null
        IF (( new_references.planned_credits_ind IS NOT NULL) AND ( new_references.planned_credits_ind NOT IN ('Y','N')))  THEN
                fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
                igs_ge_msg_stack.add;
                app_exception.raise_exception;
        END IF;


        IF (new_references.currency_cd IS NULL)
        THEN
          fnd_message.set_name('IGS','IGS_PE_DATA_MANDATORY');
          fnd_message.set_token('DATA_ELEMENT','CURRENCY_CD');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
        END IF;

        IF ((new_references.manage_accounts IS NOT NULL) AND (new_references.manage_accounts NOT IN ('STUDENT_FINANCE','OTHER'))
           ) THEN
           fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
        END IF;

  END check_constraints;

  PROCEDURE check_parent_existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  uudayapr        07-dec-2004     Enh 3167098 removed the reference prg_chg_dt_alias and added res_dt_alias
  pathipat        14-Apr-2003     Enh. 2831569 - Commercial Receivables Interface
                                  Removed references to term_id, batch_source_id, cust_trx_type_id.
  smadathi        18-Feb-2002     Enh. Bug 2747329.Added check parent existance for new column rfnd_destination
  smadathi        01-Nov-2002     Enh Bug 2584986. Added check parent existance for new column currency_cd
  smvk            24-Sep-2002     Added the check for rec_account_cd, rev_account_cd, cash_account_cd
                                  and unapp_account_cd.  As a part of Bug # 2564643.
  smvk            13-Mar-2002     Added to check for refund_cr_account_cd, refund_dr_account_cd and
                                  refund_dt_alias w.r.t Bug # 2144600
  (reverse chronological order - newest change first)
  ***************************************************************/
      CURSOR   cur_rowid4 IS
      SELECT   rowid
      FROM     fnd_currencies
      WHERE    currency_code  = new_references.currency_cd;

      l_rowid4 cur_rowid4%ROWTYPE;

  BEGIN

    IF (((old_references.accounting_method = new_references.accounting_method)) OR
        ((new_references.accounting_method IS NULL))) THEN
             NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation(
          'IGS_FI_ACCT_METHOD',
          new_references.accounting_method
          )THEN
            fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
    END IF;

   --Added by sarakshi,bug: 2162747
    IF (((old_references.fee_calc_mthd_code = new_references.fee_calc_mthd_code) OR
         (new_references.fee_calc_mthd_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation (
                        'IGS_FI_FEE_CALC_MTHD',
                         new_references.fee_calc_mthd_code
        )  THEN
         fnd_message.set_name ('FND','FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
         app_exception.raise_exception;
    END IF;

    -- Added for Refunds Build as per the Enhancement Bug # 2144600
    IF (((old_references.refund_dr_account_cd = new_references.refund_dr_account_cd) OR
         (new_references.refund_dr_account_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(igs_fi_acc_pkg.get_pk_for_validation(new_references.refund_dr_account_cd)) THEN
         fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
      END IF;
    END IF;

    IF (((old_references.refund_cr_account_cd= new_references.refund_cr_account_cd) OR
         (new_references.refund_cr_account_cd IS NULL))) THEN
      NULL;
    ELSE
       IF NOT(igs_fi_acc_pkg.get_pk_for_validation(new_references.refund_cr_account_cd)) THEN
          fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
       END IF;
    END IF;

    IF ((old_references.refund_dt_alias = new_references.refund_dt_alias) OR
         (new_references.refund_dt_alias IS NULL)) THEN
      NULL;
    ELSE
      IF NOT igs_ca_da_pkg.get_pk_for_validation (
               new_references.refund_dt_alias) THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    -- Added as a part of Subaccount Removal build. Enh Bug # 2564643
    IF ((old_references.rec_account_cd = new_references.rec_account_cd) OR
         (new_references.rec_account_cd IS NULL)) THEN
      NULL;
    ELSE
       IF NOT(igs_fi_acc_pkg.get_pk_for_validation(new_references.rec_account_cd)) THEN
         fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
       END IF;
    END IF;

    IF ((old_references.rev_account_cd = new_references.rev_account_cd) OR
         (new_references.rev_account_cd IS NULL)) THEN
      NULL;
    ELSE
        IF NOT(igs_fi_acc_pkg.get_pk_for_validation(new_references.rev_account_cd)) THEN
          fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
        END IF;
    END IF;

    IF ((old_references.cash_account_cd = new_references.cash_account_cd) OR
         (new_references.cash_account_cd IS NULL)) THEN
      NULL;
    ELSE
        IF NOT(igs_fi_acc_pkg.get_pk_for_validation(new_references.cash_account_cd)) THEN
           fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
        END IF;
    END IF;

    IF ((old_references.unapp_account_cd = new_references.unapp_account_cd) OR
         (new_references.unapp_account_cd IS NULL)) THEN
      NULL;
    ELSE
        IF NOT(igs_fi_acc_pkg.get_pk_for_validation(new_references.unapp_account_cd)) THEN
           fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
        END IF;
    END IF;

     IF (((old_references.currency_cd = new_references.currency_cd)) OR
        ((new_references.currency_cd IS NULL))) THEN
      NULL;
     ELSE
      OPEN  cur_rowid4;
      FETCH cur_rowid4 INTO l_rowid4;
      IF (cur_rowid4%NOTFOUND) THEN
        CLOSE cur_rowid4;
        fnd_message.set_name ('FND','FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      CLOSE cur_rowid4;
     END IF;

    IF (((old_references.rfnd_destination = new_references.rfnd_destination)) OR
        ((new_references.rfnd_destination IS NULL))) THEN
             NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation(
          'IGS_FI_REFUND_DESTINATION',
          new_references.rfnd_destination
          )THEN
            fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
            igs_ge_msg_stack.add;
            app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_rec_installed IN VARCHAR2
    ) RETURN BOOLEAN AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT   row_id
      FROM     igs_fi_control
      WHERE    rec_installed = x_rec_installed
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;
  END get_pk_for_validation;


  PROCEDURE before_dml (
    p_action                    IN VARCHAR2,
    x_rowid                     IN VARCHAR2 ,
    x_rec_installed             IN VARCHAR2 ,
    x_creation_date             IN DATE ,
    x_created_by                IN NUMBER ,
    x_last_update_date          IN DATE ,
    x_last_updated_by           IN NUMBER ,
    x_last_update_login         IN NUMBER ,
    x_accounting_method         IN VARCHAR2 ,
    x_set_of_books_id           IN NUMBER ,
    x_refund_dr_gl_ccid         IN NUMBER ,
    x_refund_cr_gl_ccid         IN NUMBER ,
    x_refund_dr_account_cd      IN VARCHAR2 ,
    x_refund_cr_account_cd      IN VARCHAR2 ,
    x_refund_dt_alias           IN VARCHAR2 ,
    x_fee_calc_mthd_code        IN VARCHAR2 ,
    x_planned_credits_ind       IN VARCHAR2 ,
    x_rec_gl_ccid               IN NUMBER ,
    x_cash_gl_ccid              IN NUMBER ,
    x_unapp_gl_ccid             IN NUMBER ,
    x_rec_account_cd            IN VARCHAR2 ,
    x_rev_account_cd            IN VARCHAR2 ,
    x_cash_account_cd           IN VARCHAR2 ,
    x_unapp_account_cd          IN VARCHAR2,
    x_conv_process_run_ind      IN NUMBER,
    x_currency_cd               IN VARCHAR2 ,
    x_rfnd_destination          IN VARCHAR2,
    x_ap_org_id                 IN NUMBER,
    x_dflt_supplier_site_name   IN VARCHAR2,
    x_manage_accounts           IN VARCHAR2,
    x_acct_conv_flag            IN VARCHAR2,
    x_post_waiver_gl_flag       IN VARCHAR2,
    x_waiver_notify_finaid_flag IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  svuppala        14-JUL-2005     Enh 3392095 - Tution Waivers build
                                  Modified by adding two new columns post_waiver_gl_flag, waiver_notify_finaid_flag
  uudayapr        07-dec-2003      Enh#3167098 Modified the procedures BY  removing the reference to prg_chg_dt_alias
                                                and adding res_dt_alias.
  shtatiko        27-MAY-2003     Enh# 2831582, Removed references to columns lockbox_context, lockbox_number_attribute
                                  and ar_int_org_id.
  vvutukur        16-May-2003     Enh#2831572.Financial Accounting Build. Added column acct_conv_flag.
  pathipat        14-Apr-2003     Enh. 2831569 - Commercial Receivables Interface
                                  Removed references to columns interface_line_context, interface_line_attribute, term_id,
                                  batch_source_id, cust_trx_type_id. Added column manage_accounts
  smadathi        18-Feb-2002     Enh. Bug 2747329.Added new columns rfnd_destination, ap_org_id, dflt_supplier_site_name
  smadathi        01-Nov-2002     Enh Bug 2584986. Added new column currency_cd
  pathipat        02-OCT-2002     Added column  x_conv_process_run_ind, part of Enh Bug: 2562745
  smvk            24-Sep-2002     Added the columns rec_gl_ccid, cash_gl_ccid, unapp_gl_ccid,
                                  rec_account_cd, rev_account_cd, cash_account_cd and
                                  unapp_account_cd. As a part of Bug # 2564643.
  vchappid        01-Apr-2002     Bug# 2293676, Added column planned_credits_ind
  smvk            13-Mar-2002     Added four columns refund_cr_gl_ccid, refund_dr_gl_ccid
                                  refund_dr_account_cd, refund_cr_account_cd, refund_dt_alias and
                                  removed last_account_trans, last_payment_trans and
                                  last_pay_term_trans w.r.t. Bug # 2144600
  vvutukur        13-02-2002     Added a new column, ar_int_org_id for bug 2222272
  msrinivi    17 Jul,2001    Added 1 new column, set_of_books_id
  ***************************************************************/
  BEGIN
    set_column_values (
      p_action,
      x_rowid,
      x_rec_installed,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_accounting_method,
      x_set_of_books_id,
      x_refund_dr_gl_ccid,
      x_refund_cr_gl_ccid,
      x_refund_dr_account_cd,
      x_refund_cr_account_cd,
      x_refund_dt_alias,
      x_fee_calc_mthd_code ,
      x_planned_credits_ind,
      x_rec_gl_ccid,
      x_cash_gl_ccid,
      x_unapp_gl_ccid ,
      x_rec_account_cd,
      x_rev_account_cd,
      x_cash_account_cd,
      x_unapp_account_cd,
      x_conv_process_run_ind,
      x_currency_cd,
      x_rfnd_destination,
      x_ap_org_id,
      x_dflt_supplier_site_name,
      x_manage_accounts,
      x_acct_conv_flag,
      x_post_waiver_gl_flag,
      x_waiver_notify_finaid_flag
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
             IF get_pk_for_validation(
                new_references.rec_installed)  THEN
               fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
             END IF;
      check_constraints;
      check_parent_existance;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
         -- Call all the procedures related to Before Insert.
      IF get_pk_for_validation (
                new_references.rec_installed)  THEN
               fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
             END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
    END IF;
  END before_dml;


  PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      NULL;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      NULL;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      NULL;
    END IF;
  END after_dml;


 PROCEDURE insert_row (
       x_rowid                     IN OUT NOCOPY VARCHAR2,
       x_rec_installed             IN VARCHAR2,
       x_mode                      IN VARCHAR2 ,
       x_accounting_method         IN VARCHAR2,
       x_set_of_books_id           IN NUMBER ,
       x_refund_dr_gl_ccid         IN NUMBER ,
       x_refund_cr_gl_ccid         IN NUMBER ,
       x_refund_dr_account_cd      IN VARCHAR2 ,
       x_refund_cr_account_cd      IN VARCHAR2 ,
       x_refund_dt_alias           IN VARCHAR2 ,
       x_fee_calc_mthd_code        IN VARCHAR2 ,
       x_planned_credits_ind       IN VARCHAR2 ,
       x_rec_gl_ccid               IN NUMBER ,
       x_cash_gl_ccid              IN NUMBER ,
       x_unapp_gl_ccid             IN NUMBER ,
       x_rec_account_cd            IN VARCHAR2 ,
       x_rev_account_cd            IN VARCHAR2 ,
       x_cash_account_cd           IN VARCHAR2 ,
       x_unapp_account_cd          IN VARCHAR2,
       x_conv_process_run_ind      IN NUMBER,
       x_currency_cd               IN VARCHAR2,
       x_rfnd_destination          IN VARCHAR2,
       x_ap_org_id                 IN NUMBER,
       x_dflt_supplier_site_name   IN VARCHAR2,
       x_manage_accounts           IN VARCHAR2,
       x_acct_conv_flag            IN VARCHAR2,
       x_post_waiver_gl_flag       IN VARCHAR2,
       x_waiver_notify_finaid_flag IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  svuppala        14-JUL-2005     Enh 3392095 - Tution Waivers build
                                  Modified by adding two new columns post_waiver_gl_flag, waiver_notify_finaid_flag
  uudayapr        07-dec-2003      Enh#3167098 Modified the procedures BY  removing the reference to prg_chg_dt_alias
                                                and adding res_dt_alias.
  shtatiko        27-MAY-2003     Enh# 2831582, Removed references to columns lockbox_context, lockbox_number_attribute
                                  and ar_int_org_id.
  vvutukur        16-May-2003     Enh#2831572.Financial Accounting Build. Added column acct_conv_flag.
  pathipat        14-Apr-2003     Enh. 2831569 - Commercial Receivables Interface
                                  Removed references to columns interface_line_context, interface_line_attribute, term_id,
                                  batch_source_id, cust_trx_type_id. Added column manage_accounts
  smadathi        18-Feb-2002     Enh. Bug 2747329.Added new columns rfnd_destination, ap_org_id, dflt_supplier_site_name
  smadathi        01-Nov-2002     Enh Bug 2584986. Added new column currency_cd
  pathipat        02-OCT-2002     Added column  x_conv_process_run_ind, part of Enh Bug: 2562745
  smvk            24-Sep-2002     Added the columns rec_gl_ccid, cash_gl_ccid, unapp_gl_ccid,
                                  rec_account_cd, rev_account_cd, cash_account_cd and
                                  unapp_account_cd. As a part of Bug # 2564643.
  vchappid        01-Apr-2002     Bug# 2293676, Added column planned_credits_ind
  smvk            13-Mar-2002     Added four columns refund_cr_gl_ccid, refund_dr_gl_ccid
                                  refund_dr_account_cd, refund_cr_account_cd, refund_dt_alias and
                                  removed last_account_trans, last_payment_trans and
                                  last_pay_term_trans w.r.t. Bug # 2144600
  vvutukur        13-02-2002     Added a new column, ar_int_org_id for bug 2222272
  msrinivi    17 Jul,2001    Added a new column, set_of_books_id
  ***************************************************************/
    CURSOR c IS
      SELECT ROWID
      FROM igs_fi_control
      WHERE rec_installed= x_rec_installed;

     x_last_update_date   DATE ;
     x_last_updated_by    NUMBER ;
     x_last_update_login  NUMBER ;

 BEGIN

     x_last_update_date := SYSDATE;

     IF (x_mode = 'I') THEN

        x_last_updated_by   := 1;
        x_last_update_login := 0;

     ELSIF (x_mode = 'R') THEN

        x_last_updated_by := FND_GLOBAL.USER_ID;

        IF x_last_updated_by IS NULL THEN
           x_last_updated_by := -1;
        END IF;

        x_last_update_login :=FND_GLOBAL.LOGIN_ID;

        IF x_last_update_login IS NULL THEN
           x_last_update_login := -1;
        END IF;
     ELSE
        fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
     END IF;

     --msrinivi : since this table has now been made a multi org, the following is added
     new_references.org_id := igs_ge_gen_003.get_org_id;

       before_dml(
               p_action                    =>'INSERT',
               x_rowid                     => x_rowid,
               x_rec_installed             => x_rec_installed,
               x_creation_date             => x_last_update_date,
               x_created_by                => x_last_updated_by,
               x_last_update_date          => x_last_update_date,
               x_last_updated_by           => x_last_updated_by,
               x_last_update_login         => x_last_update_login,
               x_accounting_method         => x_accounting_method,
               x_set_of_books_id           => x_set_of_books_id,
               x_refund_dr_gl_ccid         => x_refund_dr_gl_ccid,
               x_refund_cr_gl_ccid         => x_refund_cr_gl_ccid,
               x_refund_dr_account_cd      => x_refund_dr_account_cd,
               x_refund_cr_account_cd      => x_refund_cr_account_cd,
               x_refund_dt_alias           => x_refund_dt_alias,
               x_fee_calc_mthd_code        => x_fee_calc_mthd_code ,
               x_planned_credits_ind       => x_planned_credits_ind ,
               x_rec_gl_ccid               => x_rec_gl_ccid,
               x_cash_gl_ccid              => x_cash_gl_ccid,
               x_unapp_gl_ccid             => x_unapp_gl_ccid ,
               x_rec_account_cd            => x_rec_account_cd,
               x_rev_account_cd            => x_rev_account_cd,
               x_cash_account_cd           => x_cash_account_cd,
               x_unapp_account_cd          => x_unapp_account_cd,
               x_conv_process_run_ind      => x_conv_process_run_ind,
               x_currency_cd               => x_currency_cd,
               x_rfnd_destination          => x_rfnd_destination,
               x_ap_org_id                 => x_ap_org_id,
               x_dflt_supplier_site_name   => x_dflt_supplier_site_name,
               x_manage_accounts           => x_manage_accounts,
               x_acct_conv_flag            => x_acct_conv_flag,
               x_post_waiver_gl_flag       => x_post_waiver_gl_flag,
               x_waiver_notify_finaid_flag => x_waiver_notify_finaid_flag
               );

     INSERT INTO igs_fi_control_all (
                rec_installed,
                creation_date,
                created_by,
                last_update_date,
                last_updated_by,
                last_update_login,
                accounting_method,
                set_of_books_id,
                org_id,
                refund_dr_gl_ccid,
                refund_cr_gl_ccid,
                refund_dr_account_cd,
                refund_cr_account_cd,
                refund_dt_alias,
                fee_calc_mthd_code,
                planned_credits_ind,
                rec_gl_ccid,
                cash_gl_ccid,
                unapp_gl_ccid,
                rec_account_cd,
                rev_account_cd,
                cash_account_cd,
                unapp_account_cd,
                conv_process_run_ind,
                currency_cd,
                rfnd_destination,
                ap_org_id,
                dflt_supplier_site_name,
                manage_accounts,
                acct_conv_flag,
                post_waiver_gl_flag,
                waiver_notify_finaid_flag
             )
         VALUES (
                new_references.rec_installed,
                x_last_update_date,
                x_last_updated_by,
                x_last_update_date,
                x_last_updated_by,
                x_last_update_login,
                x_accounting_method,
                new_references.set_of_books_id,
                new_references.org_id,
                new_references.refund_dr_gl_ccid,
                new_references.refund_cr_gl_ccid,
                new_references.refund_dr_account_cd,
                new_references.refund_cr_account_cd,
                new_references.refund_dt_alias,
                new_references.fee_calc_mthd_code,
                new_references.planned_credits_ind,
                new_references.rec_gl_ccid,
                new_references.cash_gl_ccid,
                new_references.unapp_gl_ccid,
                new_references.rec_account_cd,
                new_references.rev_account_cd,
                new_references.cash_account_cd,
                new_references.unapp_account_cd,
                new_references.conv_process_run_ind,
                new_references.currency_cd,
                new_references.rfnd_destination,
                new_references.ap_org_id,
                new_references.dflt_supplier_site_name,
                new_references.manage_accounts,
                new_references.acct_conv_flag,
                new_references.post_waiver_gl_flag,
                new_references.waiver_notify_finaid_flag
                );

                OPEN c;
                FETCH c INTO X_ROWID;
                IF (c%NOTFOUND) THEN
                   CLOSE c;
                   RAISE NO_DATA_FOUND;
                END IF;
                CLOSE c;

    After_DML(
        p_action => 'INSERT' ,
        x_rowid => X_ROWID );

END insert_row;


 PROCEDURE lock_row (
       x_rowid                     IN VARCHAR2,
       x_rec_installed             IN VARCHAR2,
       x_accounting_method         IN VARCHAR2,
       x_set_of_books_id           IN NUMBER ,
       x_refund_dr_gl_ccid         IN NUMBER ,
       x_refund_cr_gl_ccid         IN NUMBER ,
       x_refund_dr_account_cd      IN VARCHAR2 ,
       x_refund_cr_account_cd      IN VARCHAR2 ,
       x_refund_dt_alias           IN VARCHAR2 ,
       x_fee_calc_mthd_code        IN VARCHAR2 ,
       x_planned_credits_ind       IN VARCHAR2 ,
       x_rec_gl_ccid               IN NUMBER ,
       x_cash_gl_ccid              IN NUMBER ,
       x_unapp_gl_ccid             IN NUMBER ,
       x_rec_account_cd            IN VARCHAR2 ,
       x_rev_account_cd            IN VARCHAR2 ,
       x_cash_account_cd           IN VARCHAR2 ,
       x_unapp_account_cd          IN VARCHAR2,
       x_conv_process_run_ind      IN NUMBER,
       x_currency_cd               IN VARCHAR2,
       x_rfnd_destination          IN VARCHAR2,
       x_ap_org_id                 IN NUMBER,
       x_dflt_supplier_site_name   IN VARCHAR2,
       x_manage_accounts           IN VARCHAR2,
       x_acct_conv_flag            IN VARCHAR2,
       x_post_waiver_gl_flag       IN VARCHAR2,
       x_waiver_notify_finaid_flag IN VARCHAR2
         ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  svuppala        14-JUL-2005     Enh 3392095 - Tution Waivers build
                                  Modified by adding two new columns post_waiver_gl_flag, waiver_notify_finaid_flag
  uudayapr        07-dec-2003      Enh#3167098 Modified the procedures BY  removing the reference to prg_chg_dt_alias
                                                and adding res_dt_alias.
  shtatiko        27-MAY-2003     Enh# 2831582, Removed references to columns lockbox_context, lockbox_number_attribute
                                  and ar_int_org_id.
  vvutukur        16-May-2003     Enh#2831572.Financial Accounting Build. Added column acct_conv_flag.
  pathipat        14-Apr-2003     Enh. 2831569 - Commercial Receivables Interface
                                  Removed references to columns interface_line_context, interface_line_attribute, term_id,
                                  batch_source_id, cust_trx_type_id. Added column manage_accounts
  smadathi        18-Feb-2002     Enh. Bug 2747329.Added new columns rfnd_destination, ap_org_id, dflt_supplier_site_name
  smadathi        01-Nov-2002     Enh Bug 2584986. Added new column currency_cd
  pathipat        02-OCT-2002     Added column  x_conv_process_run_ind, part of Enh Bug: 2562745
  smvk            24-Sep-2002     Added the columns rec_gl_ccid, cash_gl_ccid, unapp_gl_ccid,
                                  rec_account_cd, rev_account_cd, cash_account_cd and
                                  unapp_account_cd. As a part of Bug # 2564643.
  vchappid        01-Apr-2002     Bug# 2293676, Added column planned_credits_ind
  smvk            13-Mar-2002     Added four columns refund_cr_gl_ccid, refund_dr_gl_ccid
                                  refund_dr_account_cd, refund_cr_account_cd, refund_dt_alias and
                                  removed last_account_trans, last_payment_trans and
                                  last_pay_term_trans w.r.t. Bug # 2144600
  vvutukur        13-02-2002     Added a new column, ar_int_org_id for bug 2222272
  msrinivi    17 Jul,2001    Added 1 new column, set_of_books_id
  vvutukur    04 Jan 2002    Added logic for when accounting method
                             is null in IF condition
  ***************************************************************/
   CURSOR c1 IS
     SELECT accounting_method,
            set_of_books_id,
            refund_dr_gl_ccid ,
            refund_cr_gl_ccid,
            refund_dr_account_cd ,
            refund_cr_account_cd,
            refund_dt_alias ,
            fee_calc_mthd_code,
            planned_credits_ind,
            rec_gl_ccid,
            cash_gl_ccid,
            unapp_gl_ccid,
            rec_account_cd,
            rev_account_cd,
            cash_account_cd,
            unapp_account_cd,
            conv_process_run_ind,
            currency_cd,
            rfnd_destination,
            ap_org_id,
            dflt_supplier_site_name,
            manage_accounts,
            acct_conv_flag,
            post_waiver_gl_flag,
            waiver_notify_finaid_flag
     FROM igs_fi_control_all
     WHERE rowid = x_rowid
     FOR UPDATE NOWAIT;

     tlinfo c1%ROWTYPE;

BEGIN
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
        fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        CLOSE c1;
        app_exception.raise_exception;
        RETURN;
    END IF;
    CLOSE c1;

    IF    (((tlinfo.accounting_method = x_accounting_method) OR
          (tlinfo.accounting_method IS NULL OR x_accounting_method IS NULL))
      AND ((tlinfo.set_of_books_id = x_set_of_books_id) OR
          (tlinfo.set_of_books_id IS NULL AND x_set_of_books_id IS NULL))
      AND ((tlinfo.refund_dr_gl_ccid = x_refund_dr_gl_ccid ) OR
          (tlinfo.refund_dr_gl_ccid IS NULL AND x_refund_dr_gl_ccid IS NULL))
      AND ((tlinfo.refund_cr_gl_ccid = x_refund_cr_gl_ccid ) OR
          (tlinfo.refund_cr_gl_ccid IS NULL AND x_refund_cr_gl_ccid IS NULL))
      AND ((tlinfo.refund_dr_account_cd = x_refund_dr_account_cd ) OR
          (tlinfo.refund_dr_account_cd IS NULL AND x_refund_dr_account_cd IS NULL))
      AND ((tlinfo.refund_cr_account_cd = x_refund_cr_account_cd ) OR
          (tlinfo.refund_cr_account_cd IS NULL AND x_refund_cr_account_cd IS NULL))
      AND ((tlinfo.refund_dt_alias = x_refund_dt_alias ) OR
          (tlinfo.refund_dt_alias IS NULL AND x_refund_dt_alias IS NULL))
      AND ((tlinfo.fee_calc_mthd_code = x_fee_calc_mthd_code) OR
          (tlinfo.fee_calc_mthd_code IS NULL AND x_fee_calc_mthd_code IS NULL))
      AND ((tlinfo.planned_credits_ind = x_planned_credits_ind) OR
          (tlinfo.planned_credits_ind IS NULL AND x_planned_credits_ind IS NULL))
      AND ((tlinfo.rec_gl_ccid = x_rec_gl_ccid) OR
          (tlinfo.rec_gl_ccid IS NULL AND x_rec_gl_ccid IS NULL))
      AND ((tlinfo.cash_gl_ccid = x_cash_gl_ccid) OR
          (tlinfo.cash_gl_ccid IS NULL AND x_cash_gl_ccid IS NULL))
      AND ((tlinfo.unapp_gl_ccid = x_unapp_gl_ccid) OR
          (tlinfo.unapp_gl_ccid IS NULL AND x_unapp_gl_ccid IS NULL))
      AND ((tlinfo.rec_account_cd = x_rec_account_cd) OR
          (tlinfo.rec_account_cd IS NULL AND x_rec_account_cd IS NULL))
      AND ((tlinfo.rev_account_cd = x_rev_account_cd) OR
          (tlinfo.rev_account_cD IS NULL AND x_rev_account_cd IS NULL))
      AND ((tlinfo.cash_account_cd = x_cash_account_cd) OR
          (tlinfo.cash_account_cd IS NULL AND x_cash_account_cd IS NULL))
      AND ((tlinfo.unapp_account_cd = x_unapp_account_cd) OR
          (tlinfo.unapp_account_cd IS NULL AND x_unapp_account_cd IS NULL))
      AND ((tlinfo.conv_process_run_ind = x_conv_process_run_ind) OR
          (tlinfo.conv_process_run_ind IS NULL AND x_conv_process_run_ind IS NULL))
      AND ((tlinfo.currency_cd = x_currency_cd) OR
          (tlinfo.currency_cd IS NULL AND x_currency_cd IS NULL))
      AND ((tlinfo.rfnd_destination = x_rfnd_destination) OR
          (tlinfo.rfnd_destination IS NULL AND x_rfnd_destination IS NULL))
      AND ((tlinfo.ap_org_id = x_ap_org_id) OR
          (tlinfo.ap_org_id IS NULL AND x_ap_org_id IS NULL))
      AND ((tlinfo.dflt_supplier_site_name = x_dflt_supplier_site_name) OR
          (tlinfo.dflt_supplier_site_name IS NULL AND x_dflt_supplier_site_name IS NULL))
      AND ((tlinfo.manage_accounts = x_manage_accounts) OR
          (tlinfo.manage_accounts IS NULL AND x_manage_accounts IS NULL))
      AND ((tlinfo.acct_conv_flag = x_acct_conv_flag) OR
          (tlinfo.acct_conv_flag IS NULL AND x_acct_conv_flag IS NULL))
      AND ((tlinfo.post_waiver_gl_flag = x_post_waiver_gl_flag) OR
          (tlinfo.post_waiver_gl_flag IS NULL AND x_post_waiver_gl_flag IS NULL))
      AND ((tlinfo.waiver_notify_finaid_flag  = x_waiver_notify_finaid_flag ) OR
          (tlinfo.waiver_notify_finaid_flag  IS NULL AND x_waiver_notify_finaid_flag  IS NULL))
  ) THEN
    NULL;
  ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END IF;
  RETURN;
END lock_row;


PROCEDURE update_row (
       x_rowid                     IN VARCHAR2,
       x_rec_installed             IN VARCHAR2,
       x_mode                      IN VARCHAR2 ,
       x_accounting_method         IN VARCHAR2,
       x_set_of_books_id           IN NUMBER  ,
       x_refund_dr_gl_ccid         IN NUMBER ,
       x_refund_cr_gl_ccid         IN NUMBER ,
       x_refund_dr_account_cd      IN VARCHAR2 ,
       x_refund_cr_account_cd      IN VARCHAR2 ,
       x_refund_dt_alias           IN VARCHAR2 ,
       x_fee_calc_mthd_code        IN VARCHAR2 ,
       x_planned_credits_ind       IN VARCHAR2 ,
       x_rec_gl_ccid               IN NUMBER ,
       x_cash_gl_ccid              IN NUMBER ,
       x_unapp_gl_ccid             IN NUMBER ,
       x_rec_account_cd            IN VARCHAR2 ,
       x_rev_account_cd            IN VARCHAR2 ,
       x_cash_account_cd           IN VARCHAR2 ,
       x_unapp_account_cd          IN VARCHAR2,
       x_conv_process_run_ind      IN NUMBER,
       x_currency_cd               IN VARCHAR2,
       x_rfnd_destination          IN VARCHAR2,
       x_ap_org_id                 IN NUMBER,
       x_dflt_supplier_site_name   IN VARCHAR2,
       x_manage_accounts           IN VARCHAR2,
       x_acct_conv_flag            IN VARCHAR2,
       x_post_waiver_gl_flag       IN VARCHAR2,
       x_waiver_notify_finaid_flag IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  svuppala        14-JUL-2005     Enh 3392095 - Tution Waivers build
                                  Modified by adding two new columns post_waiver_gl_flag, waiver_notify_finaid_flag
  uudayapr        07-dec-2003      Enh#3167098 Modified the procedures BY  removing the reference to prg_chg_dt_alias
                                                and adding res_dt_alias.
  shtatiko        27-MAY-2003     Enh# 2831582, Removed references to columns lockbox_context, lockbox_number_attribute
                                  and ar_int_org_id.
  vvutukur        16-May-2003     Enh#2831572.Financial Accounting Build. Added column acct_conv_flag.
  pathipat        14-Apr-2003     Enh. 2831569 - Commercial Receivables Interface
                                  Removed references to columns interface_line_context, interface_line_attribute, term_id,
                                  batch_source_id, cust_trx_type_id. Added column manage_accounts
  smadathi        18-Feb-2002     Enh. Bug 2747329.Added new columns rfnd_destination, ap_org_id, dflt_supplier_site_name
  smadathi        01-Nov-2002     Enh Bug 2584986. Added new column currency_cd
  pathipat        02-OCT-2002     Added column  x_conv_process_run_ind, part of Enh Bug: 2562745
  smvk            24-Sep-2002     Added the columns rec_gl_ccid, cash_gl_ccid, unapp_gl_ccid,
                                  rec_account_cd, rev_account_cd, cash_account_cd and
                                  unapp_account_cd. As a part of Bug # 2564643.
  vchappid        01-Apr-2002     Bug# 2293676, Added column planned_credits_ind
  smvk            13-Mar-2002     Added four columns refund_cr_gl_ccid, refund_dr_gl_ccid
                                  refund_dr_account_cd, refund_cr_account_cd, refund_dt_alias and
                                  removed last_account_trans, last_payment_trans and
                                  last_pay_term_trans w.r.t. Bug # 2144600
  vvutukur        13-02-2002     Added a new column, ar_int_org_id for bug 2222272
  msrinivi    17 Jul,2001    Added 1 new column, set_of_books_id
  ***************************************************************/
     x_last_update_date  DATE ;
     x_last_updated_by   NUMBER ;
     x_last_update_login NUMBER ;

 BEGIN

     x_last_update_date := SYSDATE;

     IF  (x_mode = 'I') THEN
        x_last_updated_by   := 1;
        x_last_update_login := 0;
     ELSIF (x_mode = 'R') THEN
        x_last_updated_by := FND_GLOBAL.USER_ID;
        IF x_last_updated_by IS NULL THEN
           x_last_updated_by := -1;
        END IF;
        x_last_update_login :=FND_GLOBAL.LOGIN_ID;
        IF x_last_update_login IS NULL THEN
           x_last_update_login := -1;
        END IF;
     ELSE
        fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
     END IF;

     before_dml(
        p_action                    =>'UPDATE',
        x_rowid                     => x_rowid,
        x_rec_installed             => x_rec_installed,
        x_creation_date             => x_last_update_date,
        x_created_by                => x_last_updated_by,
        x_last_update_date          => x_last_update_date,
        x_last_updated_by           => x_last_updated_by,
        x_last_update_login         => x_last_update_login,
        x_accounting_method         => x_accounting_method,
        x_set_of_books_id           => x_set_of_books_id,
        x_refund_dr_gl_ccid         => x_refund_dr_gl_ccid,
        x_refund_cr_gl_ccid         => x_refund_cr_gl_ccid,
        x_refund_dr_account_cd      => x_refund_dr_account_cd,
        x_refund_cr_account_cd      => x_refund_cr_account_cd,
        x_refund_dt_alias           => x_refund_dt_alias,
        x_fee_calc_mthd_code        => x_fee_calc_mthd_code ,
        x_planned_credits_ind       => x_planned_credits_ind,
        x_rec_gl_ccid               => x_rec_gl_ccid,
        x_cash_gl_ccid              => x_cash_gl_ccid,
        x_unapp_gl_ccid             => x_unapp_gl_ccid ,
        x_rec_account_cd            => x_rec_account_cd,
        x_rev_account_cd            => x_rev_account_cd,
        x_cash_account_cd           => x_cash_account_cd,
        x_unapp_account_cd          => x_unapp_account_cd,
        x_conv_process_run_ind      => x_conv_process_run_ind ,
        x_currency_cd               => x_currency_cd,
        x_rfnd_destination          => x_rfnd_destination,
        x_ap_org_id                 => x_ap_org_id,
        x_dflt_supplier_site_name   => x_dflt_supplier_site_name,
        x_manage_accounts           => x_manage_accounts,
        x_acct_conv_flag            => x_acct_conv_flag,
        x_post_waiver_gl_flag       => x_post_waiver_gl_flag,
        x_waiver_notify_finaid_flag => x_waiver_notify_finaid_flag
     );

   UPDATE igs_fi_control_all
   SET
        rec_installed             = new_references.rec_installed,
        last_update_date          = new_references.last_update_date,
        last_updated_by           = new_references.last_updated_by,
        last_update_login         = new_references.last_update_login,
        accounting_method         = new_references.accounting_method,
        set_of_books_id           = new_references.set_of_books_id ,
        refund_dr_gl_ccid         = new_references.refund_dr_gl_ccid,
        refund_cr_gl_ccid         = new_references.refund_cr_gl_ccid,
        refund_dr_account_cd      = new_references.refund_dr_account_cd,
        refund_cr_account_cd      = new_references.refund_cr_account_cd,
        refund_dt_alias           = new_references.refund_dt_alias,
        fee_calc_mthd_code        = new_references.fee_calc_mthd_code,
        planned_credits_ind       = new_references.planned_credits_ind,
        rec_gl_ccid               = new_references.rec_gl_ccid,
        cash_gl_ccid              = new_references.cash_gl_ccid,
        unapp_gl_ccid             = new_references.unapp_gl_ccid,
        rec_account_cd            = new_references.rec_account_cd,
        rev_account_cd            = new_references.rev_account_cd,
        cash_account_cd           = new_references.cash_account_cd,
        unapp_account_cd          = new_references.unapp_account_cd,
        conv_process_run_ind      = new_references.conv_process_run_ind ,
        currency_cd               = new_references.currency_cd,
        rfnd_destination          = new_references.rfnd_destination,
        ap_org_id                 = new_references.ap_org_id,
        dflt_supplier_site_name   = new_references.dflt_supplier_site_name,
        manage_accounts           = new_references.manage_accounts,
        acct_conv_flag            = new_references.acct_conv_flag,
        post_waiver_gl_flag       = new_references.post_waiver_gl_flag,
        waiver_notify_finaid_flag = new_references.waiver_notify_finaid_flag

    WHERE rowid = x_rowid;

    IF (sql%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
    END IF;

    After_DML (
        p_action => 'UPDATE' ,
        x_rowid => X_ROWID
        );

END update_row;

PROCEDURE delete_row (
  x_rowid IN VARCHAR2
) AS
/*************************************************************
Created By :
Date Created By :
Purpose :
Know limitations, enhancements or remarks
Change History
Who             When            What
(reverse chronological order - newest change first)
***************************************************************/

  BEGIN

     Before_DML (
          p_action => 'DELETE',
          x_rowid => x_rowid
         );

     DELETE FROM IGS_FI_CONTROL_ALL
     WHERE rowid = x_rowid;
     IF (sql%NOTFOUND) THEN
        RAISE NO_DATA_FOUND;
     END IF;

     After_DML (
         p_action => 'DELETE',
         x_rowid => x_rowid
        );

   END delete_row;

PROCEDURE get_fk_igs_ca_da (
    x_dt_alias               IN     VARCHAR2
  ) AS
 /*******************************************************************************
  Created by  : svuppala , Oracle IDC
  Date created: 03-Apr-2006

  Purpose:
  This procedure is created as part of the bug 4025077 to add FK relation for refund_dt_alias
  coulmn in IGS_FI_CONTROL table with dt_alias coulmn in IGS_CA_DA table.

  Change History: (who, when, what: NO CREATION RECORDS HERE!)
  Who             When            What
  *******************************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_CONTROL_ALL
      WHERE   ((REFUND_DT_ALIAS = x_dt_alias));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_CTRL_DA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_da;

END igs_fi_control_pkg;

/
