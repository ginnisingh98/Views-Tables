--------------------------------------------------------
--  DDL for Package Body IGF_DB_CL_DISB_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_DB_CL_DISB_RESP_PKG" AS
/* $Header: IGFDI04B.pls 120.1 2006/08/08 06:28:49 ridas noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_db_cl_disb_resp_all%ROWTYPE;
  new_references igf_db_cl_disb_resp_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_cdbr_id                           IN     NUMBER  ,
    x_cbth_id                           IN     NUMBER  ,
    x_record_type                       IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER  ,
    x_b_last_name                       IN     VARCHAR2,
    x_b_first_name                      IN     VARCHAR2,
    x_b_middle_name                     IN     VARCHAR2,
    x_b_ssn                             IN     VARCHAR2,
    x_b_addr_line_1                     IN     VARCHAR2,
    x_b_addr_line_2                     IN     VARCHAR2,
    x_b_city                            IN     VARCHAR2,
    x_b_state                           IN     VARCHAR2,
    x_b_zip                             IN     NUMBER  ,
    x_b_zip_suffix                      IN     NUMBER  ,
    x_b_addr_chg_date                   IN     DATE    ,
    x_eft_auth_code                     IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_initial                  IN     VARCHAR2,
    x_s_ssn                             IN     VARCHAR2,
    x_school_id                         IN     NUMBER  ,
    x_school_use                        IN     VARCHAR2,
    x_loan_per_start_date               IN     DATE    ,
    x_loan_per_end_date                 IN     DATE    ,
    x_cl_loan_type                      IN     VARCHAR2,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_lender_use                        IN     VARCHAR2,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_tot_sched_disb                    IN     NUMBER  ,
    x_fund_release_date                 IN     DATE    ,
    x_disb_num                          IN     NUMBER  ,
    x_guarantor_id                      IN     VARCHAR2,
    x_guarantor_use                     IN     VARCHAR2,
    x_guarantee_date                    IN     DATE    ,
    x_guarantee_amt                     IN     NUMBER  ,
    x_gross_disb_amt                    IN     NUMBER  ,
    x_fee_1                             IN     NUMBER  ,
    x_fee_2                             IN     NUMBER  ,
    x_net_disb_amt                      IN     NUMBER  ,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_check_number                      IN     VARCHAR2,
    x_late_disb_ind                     IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_err_code1                         IN     VARCHAR2,
    x_err_code2                         IN     VARCHAR2,
    x_err_code3                         IN     VARCHAR2,
    x_err_code4                         IN     VARCHAR2,
    x_err_code5                         IN     VARCHAR2,
    x_fee_paid_2                        IN     NUMBER  ,
    x_lender_name                       IN     VARCHAR2,
    x_net_cancel_amt                    IN     NUMBER  ,
    x_duns_lender_id                    IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_pnote_code                        IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE    ,
    x_fee_paid_1                        IN     NUMBER  ,
    x_netted_cancel_amt                 IN     NUMBER  ,
    x_outstd_cancel_amt                 IN     NUMBER  ,
    x_sch_non_ed_brc_id                 IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_esign_src_typ_cd                  IN     VARCHAR2,
    x_direct_to_borr_flag               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_db_cl_disb_resp_all
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.cdbr_id                           := x_cdbr_id;
    new_references.cbth_id                           := x_cbth_id;
    new_references.record_type                       := x_record_type;
    new_references.loan_number                       := x_loan_number;
    new_references.cl_seq_number                     := x_cl_seq_number;
    new_references.b_last_name                       := x_b_last_name;
    new_references.b_first_name                      := x_b_first_name;
    new_references.b_middle_name                     := x_b_middle_name;
    new_references.b_ssn                             := x_b_ssn;
    new_references.b_addr_line_1                     := x_b_addr_line_1;
    new_references.b_addr_line_2                     := x_b_addr_line_2;
    new_references.b_city                            := x_b_city;
    new_references.b_state                           := x_b_state;
    new_references.b_zip                             := x_b_zip;
    new_references.b_zip_suffix                      := x_b_zip_suffix;
    new_references.b_addr_chg_date                   := x_b_addr_chg_date;
    new_references.eft_auth_code                     := x_eft_auth_code;
    new_references.s_last_name                       := x_s_last_name;
    new_references.s_first_name                      := x_s_first_name;
    new_references.s_middle_initial                  := x_s_middle_initial;
    new_references.s_ssn                             := x_s_ssn;
    new_references.school_id                         := x_school_id;
    new_references.school_use                        := x_school_use;
    new_references.loan_per_start_date               := x_loan_per_start_date;
    new_references.loan_per_end_date                 := x_loan_per_end_date;
    new_references.cl_loan_type                      := x_cl_loan_type;
    new_references.alt_prog_type_code                := x_alt_prog_type_code;
    new_references.lender_id                         := x_lender_id;
    new_references.lend_non_ed_brc_id                := x_lend_non_ed_brc_id;
    new_references.lender_use                        := x_lender_use;
    new_references.borw_confirm_ind                  := x_borw_confirm_ind;
    new_references.tot_sched_disb                    := x_tot_sched_disb;
    new_references.fund_release_date                 := x_fund_release_date;
    new_references.disb_num                          := x_disb_num;
    new_references.guarantor_id                      := x_guarantor_id;
    new_references.guarantor_use                     := x_guarantor_use;
    new_references.guarantee_date                    := x_guarantee_date;
    new_references.guarantee_amt                     := x_guarantee_amt;
    new_references.gross_disb_amt                    := x_gross_disb_amt;
    new_references.fee_1                             := x_fee_1;
    new_references.fee_2                             := x_fee_2;
    new_references.net_disb_amt                      := x_net_disb_amt;
    new_references.fund_dist_mthd                    := x_fund_dist_mthd;
    new_references.check_number                      := x_check_number;
    new_references.late_disb_ind                     := x_late_disb_ind;
    new_references.prev_reported_ind                 := x_prev_reported_ind;
    new_references.err_code1                         := x_err_code1;
    new_references.err_code2                         := x_err_code2;
    new_references.err_code3                         := x_err_code3;
    new_references.err_code4                         := x_err_code4;
    new_references.err_code5                         := x_err_code5;
    new_references.fee_paid_2                        := x_fee_paid_2;
    new_references.lender_name                       := x_lender_name;
    new_references.net_cancel_amt                    := x_net_cancel_amt;
    new_references.duns_lender_id                    := x_duns_lender_id;
    new_references.duns_guarnt_id                    := x_duns_guarnt_id;
    new_references.hold_rel_ind                      := x_hold_rel_ind;
    new_references.pnote_code                        := x_pnote_code;
    new_references.pnote_status_date                 := x_pnote_status_date;
    new_references.fee_paid_1                        := x_fee_paid_1;
    new_references.netted_cancel_amt                 := x_netted_cancel_amt;
    new_references.outstd_cancel_amt                 := x_outstd_cancel_amt;
    new_references.sch_non_ed_brc_id                 := x_sch_non_ed_brc_id;
    new_references.status                            := x_status;
    new_references.esign_src_typ_cd                  := x_esign_src_typ_cd;
    new_references.direct_to_borr_flag               := x_direct_to_borr_flag;


    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.cbth_id = new_references.cbth_id)) OR
        ((new_references.cbth_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_cl_batch_pkg.get_pk_for_validation (
                new_references.cbth_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_cdbr_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_db_cl_disb_resp_all
      WHERE    cdbr_id = x_cdbr_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

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


  PROCEDURE get_fk_igf_sl_cl_batch (
    x_cbth_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_db_cl_disb_resp_all
      WHERE   ((cbth_id = x_cbth_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_DB_CDBR_CBTH_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_cl_batch;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_cdbr_id                           IN     NUMBER  ,
    x_cbth_id                           IN     NUMBER  ,
    x_record_type                       IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER  ,
    x_b_last_name                       IN     VARCHAR2,
    x_b_first_name                      IN     VARCHAR2,
    x_b_middle_name                     IN     VARCHAR2,
    x_b_ssn                             IN     VARCHAR2,
    x_b_addr_line_1                     IN     VARCHAR2,
    x_b_addr_line_2                     IN     VARCHAR2,
    x_b_city                            IN     VARCHAR2,
    x_b_state                           IN     VARCHAR2,
    x_b_zip                             IN     NUMBER  ,
    x_b_zip_suffix                      IN     NUMBER  ,
    x_b_addr_chg_date                   IN     DATE    ,
    x_eft_auth_code                     IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_initial                  IN     VARCHAR2,
    x_s_ssn                             IN     VARCHAR2,
    x_school_id                         IN     NUMBER  ,
    x_school_use                        IN     VARCHAR2,
    x_loan_per_start_date               IN     DATE    ,
    x_loan_per_end_date                 IN     DATE    ,
    x_cl_loan_type                      IN     VARCHAR2,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_lender_use                        IN     VARCHAR2,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_tot_sched_disb                    IN     NUMBER  ,
    x_fund_release_date                 IN     DATE    ,
    x_disb_num                          IN     NUMBER  ,
    x_guarantor_id                      IN     VARCHAR2,
    x_guarantor_use                     IN     VARCHAR2,
    x_guarantee_date                    IN     DATE    ,
    x_guarantee_amt                     IN     NUMBER  ,
    x_gross_disb_amt                    IN     NUMBER  ,
    x_fee_1                             IN     NUMBER  ,
    x_fee_2                             IN     NUMBER  ,
    x_net_disb_amt                      IN     NUMBER  ,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_check_number                      IN     VARCHAR2,
    x_late_disb_ind                     IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_err_code1                         IN     VARCHAR2,
    x_err_code2                         IN     VARCHAR2,
    x_err_code3                         IN     VARCHAR2,
    x_err_code4                         IN     VARCHAR2,
    x_err_code5                         IN     VARCHAR2,
    x_fee_paid_2                        IN     NUMBER  ,
    x_lender_name                       IN     VARCHAR2,
    x_net_cancel_amt                    IN     NUMBER  ,
    x_duns_lender_id                    IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_pnote_code                        IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE    ,
    x_fee_paid_1                        IN     NUMBER  ,
    x_netted_cancel_amt                 IN     NUMBER  ,
    x_outstd_cancel_amt                 IN     NUMBER  ,
    x_sch_non_ed_brc_id                 IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_esign_src_typ_cd                  IN     VARCHAR2,
    x_direct_to_borr_flag               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_cdbr_id,
      x_cbth_id,
      x_record_type,
      x_loan_number,
      x_cl_seq_number,
      x_b_last_name,
      x_b_first_name,
      x_b_middle_name,
      x_b_ssn,
      x_b_addr_line_1,
      x_b_addr_line_2,
      x_b_city,
      x_b_state,
      x_b_zip,
      x_b_zip_suffix,
      x_b_addr_chg_date,
      x_eft_auth_code,
      x_s_last_name,
      x_s_first_name,
      x_s_middle_initial,
      x_s_ssn,
      x_school_id,
      x_school_use,
      x_loan_per_start_date,
      x_loan_per_end_date,
      x_cl_loan_type,
      x_alt_prog_type_code,
      x_lender_id,
      x_lend_non_ed_brc_id,
      x_lender_use,
      x_borw_confirm_ind,
      x_tot_sched_disb,
      x_fund_release_date,
      x_disb_num,
      x_guarantor_id,
      x_guarantor_use,
      x_guarantee_date,
      x_guarantee_amt,
      x_gross_disb_amt,
      x_fee_1,
      x_fee_2,
      x_net_disb_amt,
      x_fund_dist_mthd,
      x_check_number,
      x_late_disb_ind,
      x_prev_reported_ind,
      x_err_code1,
      x_err_code2,
      x_err_code3,
      x_err_code4,
      x_err_code5,
      x_fee_paid_2,
      x_lender_name,
      x_net_cancel_amt,
      x_duns_lender_id,
      x_duns_guarnt_id,
      x_hold_rel_ind,
      x_pnote_code,
      x_pnote_status_date,
      x_fee_paid_1,
      x_netted_cancel_amt,
      x_outstd_cancel_amt,
      x_sch_non_ed_brc_id,
      x_status,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_esign_src_typ_cd,
      x_direct_to_borr_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.cdbr_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.cdbr_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cdbr_id                           IN OUT NOCOPY NUMBER,
    x_cbth_id                           IN     NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_b_last_name                       IN     VARCHAR2,
    x_b_first_name                      IN     VARCHAR2,
    x_b_middle_name                     IN     VARCHAR2,
    x_b_ssn                             IN     VARCHAR2,
    x_b_addr_line_1                     IN     VARCHAR2,
    x_b_addr_line_2                     IN     VARCHAR2,
    x_b_city                            IN     VARCHAR2,
    x_b_state                           IN     VARCHAR2,
    x_b_zip                             IN     NUMBER,
    x_b_zip_suffix                      IN     NUMBER,
    x_b_addr_chg_date                   IN     DATE,
    x_eft_auth_code                     IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_initial                  IN     VARCHAR2,
    x_s_ssn                             IN     VARCHAR2,
    x_school_id                         IN     NUMBER,
    x_school_use                        IN     VARCHAR2,
    x_loan_per_start_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_cl_loan_type                      IN     VARCHAR2,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_lender_use                        IN     VARCHAR2,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_tot_sched_disb                    IN     NUMBER,
    x_fund_release_date                 IN     DATE,
    x_disb_num                          IN     NUMBER,
    x_guarantor_id                      IN     VARCHAR2,
    x_guarantor_use                     IN     VARCHAR2,
    x_guarantee_date                    IN     DATE,
    x_guarantee_amt                     IN     NUMBER,
    x_gross_disb_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_net_disb_amt                      IN     NUMBER,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_check_number                      IN     VARCHAR2,
    x_late_disb_ind                     IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_err_code1                         IN     VARCHAR2,
    x_err_code2                         IN     VARCHAR2,
    x_err_code3                         IN     VARCHAR2,
    x_err_code4                         IN     VARCHAR2,
    x_err_code5                         IN     VARCHAR2,
    x_fee_paid_2                        IN     NUMBER,
    x_lender_name                       IN     VARCHAR2,
    x_net_cancel_amt                    IN     NUMBER,
    x_duns_lender_id                    IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_pnote_code                        IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_netted_cancel_amt                 IN     NUMBER,
    x_outstd_cancel_amt                 IN     NUMBER,
    x_sch_non_ed_brc_id                 IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_esign_src_typ_cd                  IN     VARCHAR2,
    x_direct_to_borr_flag               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_db_cl_disb_resp_all
      WHERE    cdbr_id                           = x_cdbr_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                     igf_db_cl_disb_resp_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT igf_db_cl_disb_resp_s.NEXTVAL
           INTO  x_cdbr_id
           FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_cdbr_id                           => x_cdbr_id,
      x_cbth_id                           => x_cbth_id,
      x_record_type                       => x_record_type,
      x_loan_number                       => x_loan_number,
      x_cl_seq_number                     => x_cl_seq_number,
      x_b_last_name                       => x_b_last_name,
      x_b_first_name                      => x_b_first_name,
      x_b_middle_name                     => x_b_middle_name,
      x_b_ssn                             => x_b_ssn,
      x_b_addr_line_1                     => x_b_addr_line_1,
      x_b_addr_line_2                     => x_b_addr_line_2,
      x_b_city                            => x_b_city,
      x_b_state                           => x_b_state,
      x_b_zip                             => x_b_zip,
      x_b_zip_suffix                      => x_b_zip_suffix,
      x_b_addr_chg_date                   => x_b_addr_chg_date,
      x_eft_auth_code                     => x_eft_auth_code,
      x_s_last_name                       => x_s_last_name,
      x_s_first_name                      => x_s_first_name,
      x_s_middle_initial                  => x_s_middle_initial,
      x_s_ssn                             => x_s_ssn,
      x_school_id                         => x_school_id,
      x_school_use                        => x_school_use,
      x_loan_per_start_date               => x_loan_per_start_date,
      x_loan_per_end_date                 => x_loan_per_end_date,
      x_cl_loan_type                      => x_cl_loan_type,
      x_alt_prog_type_code                => x_alt_prog_type_code,
      x_lender_id                         => x_lender_id,
      x_lend_non_ed_brc_id                => x_lend_non_ed_brc_id,
      x_lender_use                        => x_lender_use,
      x_borw_confirm_ind                  => x_borw_confirm_ind,
      x_tot_sched_disb                    => x_tot_sched_disb,
      x_fund_release_date                 => x_fund_release_date,
      x_disb_num                          => x_disb_num,
      x_guarantor_id                      => x_guarantor_id,
      x_guarantor_use                     => x_guarantor_use,
      x_guarantee_date                    => x_guarantee_date,
      x_guarantee_amt                     => x_guarantee_amt,
      x_gross_disb_amt                    => x_gross_disb_amt,
      x_fee_1                             => x_fee_1,
      x_fee_2                             => x_fee_2,
      x_net_disb_amt                      => x_net_disb_amt,
      x_fund_dist_mthd                    => x_fund_dist_mthd,
      x_check_number                      => x_check_number,
      x_late_disb_ind                     => x_late_disb_ind,
      x_prev_reported_ind                 => x_prev_reported_ind,
      x_err_code1                         => x_err_code1,
      x_err_code2                         => x_err_code2,
      x_err_code3                         => x_err_code3,
      x_err_code4                         => x_err_code4,
      x_err_code5                         => x_err_code5,
      x_fee_paid_2                        => x_fee_paid_2,
      x_lender_name                       => x_lender_name,
      x_net_cancel_amt                    => x_net_cancel_amt,
      x_duns_lender_id                    => x_duns_lender_id,
      x_duns_guarnt_id                    => x_duns_guarnt_id,
      x_hold_rel_ind                      => x_hold_rel_ind,
      x_pnote_code                        => x_pnote_code,
      x_pnote_status_date                 => x_pnote_status_date,
      x_fee_paid_1                        => x_fee_paid_1,
      x_netted_cancel_amt                 => x_netted_cancel_amt,
      x_outstd_cancel_amt                 => x_outstd_cancel_amt,
      x_sch_non_ed_brc_id                 => x_sch_non_ed_brc_id,
      x_status                            => x_status,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_esign_src_typ_cd                  => x_esign_src_typ_cd,
      x_direct_to_borr_flag               => x_direct_to_borr_flag
    );

    INSERT INTO igf_db_cl_disb_resp_all (
      cdbr_id,
      cbth_id,
      record_type,
      loan_number,
      cl_seq_number,
      b_last_name,
      b_first_name,
      b_middle_name,
      b_ssn,
      b_addr_line_1,
      b_addr_line_2,
      b_city,
      b_state,
      b_zip,
      b_zip_suffix,
      b_addr_chg_date,
      eft_auth_code,
      s_last_name,
      s_first_name,
      s_middle_initial,
      s_ssn,
      school_id,
      school_use,
      loan_per_start_date,
      loan_per_end_date,
      cl_loan_type,
      alt_prog_type_code,
      lender_id,
      lend_non_ed_brc_id,
      lender_use,
      borw_confirm_ind,
      tot_sched_disb,
      fund_release_date,
      disb_num,
      guarantor_id,
      guarantor_use,
      guarantee_date,
      guarantee_amt,
      gross_disb_amt,
      fee_1,
      fee_2,
      net_disb_amt,
      fund_dist_mthd,
      check_number,
      late_disb_ind,
      prev_reported_ind,
      err_code1,
      err_code2,
      err_code3,
      err_code4,
      err_code5,
      fee_paid_2,
      lender_name,
      net_cancel_amt,
      duns_lender_id,
      duns_guarnt_id,
      hold_rel_ind,
      pnote_code,
      pnote_status_date,
      fee_paid_1,
      netted_cancel_amt,
      outstd_cancel_amt,
      sch_non_ed_brc_id,
      status,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      org_id,
      esign_src_typ_cd,
      direct_to_borr_flag
    ) VALUES (
      new_references.cdbr_id,
      new_references.cbth_id,
      new_references.record_type,
      new_references.loan_number,
      new_references.cl_seq_number,
      new_references.b_last_name,
      new_references.b_first_name,
      new_references.b_middle_name,
      new_references.b_ssn,
      new_references.b_addr_line_1,
      new_references.b_addr_line_2,
      new_references.b_city,
      new_references.b_state,
      new_references.b_zip,
      new_references.b_zip_suffix,
      new_references.b_addr_chg_date,
      new_references.eft_auth_code,
      new_references.s_last_name,
      new_references.s_first_name,
      new_references.s_middle_initial,
      new_references.s_ssn,
      new_references.school_id,
      new_references.school_use,
      new_references.loan_per_start_date,
      new_references.loan_per_end_date,
      new_references.cl_loan_type,
      new_references.alt_prog_type_code,
      new_references.lender_id,
      new_references.lend_non_ed_brc_id,
      new_references.lender_use,
      new_references.borw_confirm_ind,
      new_references.tot_sched_disb,
      new_references.fund_release_date,
      new_references.disb_num,
      new_references.guarantor_id,
      new_references.guarantor_use,
      new_references.guarantee_date,
      new_references.guarantee_amt,
      new_references.gross_disb_amt,
      new_references.fee_1,
      new_references.fee_2,
      new_references.net_disb_amt,
      new_references.fund_dist_mthd,
      new_references.check_number,
      new_references.late_disb_ind,
      new_references.prev_reported_ind,
      new_references.err_code1,
      new_references.err_code2,
      new_references.err_code3,
      new_references.err_code4,
      new_references.err_code5,
      new_references.fee_paid_2,
      new_references.lender_name,
      new_references.net_cancel_amt,
      new_references.duns_lender_id,
      new_references.duns_guarnt_id,
      new_references.hold_rel_ind,
      new_references.pnote_code,
      new_references.pnote_status_date,
      new_references.fee_paid_1,
      new_references.netted_cancel_amt,
      new_references.outstd_cancel_amt,
      new_references.sch_non_ed_brc_id,
      new_references.status,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      l_org_id,
      new_references.esign_src_typ_cd,
      new_references.direct_to_borr_flag
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_cdbr_id                           IN     NUMBER,
    x_cbth_id                           IN     NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_b_last_name                       IN     VARCHAR2,
    x_b_first_name                      IN     VARCHAR2,
    x_b_middle_name                     IN     VARCHAR2,
    x_b_ssn                             IN     VARCHAR2,
    x_b_addr_line_1                     IN     VARCHAR2,
    x_b_addr_line_2                     IN     VARCHAR2,
    x_b_city                            IN     VARCHAR2,
    x_b_state                           IN     VARCHAR2,
    x_b_zip                             IN     NUMBER,
    x_b_zip_suffix                      IN     NUMBER,
    x_b_addr_chg_date                   IN     DATE,
    x_eft_auth_code                     IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_initial                  IN     VARCHAR2,
    x_s_ssn                             IN     VARCHAR2,
    x_school_id                         IN     NUMBER,
    x_school_use                        IN     VARCHAR2,
    x_loan_per_start_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_cl_loan_type                      IN     VARCHAR2,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_lender_use                        IN     VARCHAR2,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_tot_sched_disb                    IN     NUMBER,
    x_fund_release_date                 IN     DATE,
    x_disb_num                          IN     NUMBER,
    x_guarantor_id                      IN     VARCHAR2,
    x_guarantor_use                     IN     VARCHAR2,
    x_guarantee_date                    IN     DATE,
    x_guarantee_amt                     IN     NUMBER,
    x_gross_disb_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_net_disb_amt                      IN     NUMBER,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_check_number                      IN     VARCHAR2,
    x_late_disb_ind                     IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_err_code1                         IN     VARCHAR2,
    x_err_code2                         IN     VARCHAR2,
    x_err_code3                         IN     VARCHAR2,
    x_err_code4                         IN     VARCHAR2,
    x_err_code5                         IN     VARCHAR2,
    x_fee_paid_2                        IN     NUMBER,
    x_lender_name                       IN     VARCHAR2,
    x_net_cancel_amt                    IN     NUMBER,
    x_duns_lender_id                    IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_pnote_code                        IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_netted_cancel_amt                 IN     NUMBER,
    x_outstd_cancel_amt                 IN     NUMBER,
    x_sch_non_ed_brc_id                 IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_esign_src_typ_cd                  IN     VARCHAR2,
    x_direct_to_borr_flag               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        cbth_id,
        record_type,
        loan_number,
        cl_seq_number,
        b_last_name,
        b_first_name,
        b_middle_name,
        b_ssn,
        b_addr_line_1,
        b_addr_line_2,
        b_city,
        b_state,
        b_zip,
        b_zip_suffix,
        b_addr_chg_date,
        eft_auth_code,
        s_last_name,
        s_first_name,
        s_middle_initial,
        s_ssn,
        school_id,
        school_use,
        loan_per_start_date,
        loan_per_end_date,
        cl_loan_type,
        alt_prog_type_code,
        lender_id,
        lend_non_ed_brc_id,
        lender_use,
        borw_confirm_ind,
        tot_sched_disb,
        fund_release_date,
        disb_num,
        guarantor_id,
        guarantor_use,
        guarantee_date,
        guarantee_amt,
        gross_disb_amt,
        fee_1,
        fee_2,
        net_disb_amt,
        fund_dist_mthd,
        check_number,
        late_disb_ind,
        prev_reported_ind,
        err_code1,
        err_code2,
        err_code3,
        err_code4,
        err_code5,
        fee_paid_2,
        lender_name,
        net_cancel_amt,
        duns_lender_id,
        duns_guarnt_id,
        hold_rel_ind,
        pnote_code,
        pnote_status_date,
        fee_paid_1,
        netted_cancel_amt,
        outstd_cancel_amt,
        sch_non_ed_brc_id,
        status,
        org_id,
        esign_src_typ_cd,
        direct_to_borr_flag
      FROM  igf_db_cl_disb_resp_all
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.cbth_id = x_cbth_id)
        AND ((tlinfo.record_type = x_record_type) OR ((tlinfo.record_type IS NULL) AND (X_record_type IS NULL)))
        AND (tlinfo.loan_number = x_loan_number)
        AND (tlinfo.cl_seq_number = x_cl_seq_number)
        AND ((tlinfo.b_last_name = x_b_last_name) OR ((tlinfo.b_last_name IS NULL) AND (X_b_last_name IS NULL)))
        AND ((tlinfo.b_first_name = x_b_first_name) OR ((tlinfo.b_first_name IS NULL) AND (X_b_first_name IS NULL)))
        AND ((tlinfo.b_middle_name = x_b_middle_name) OR ((tlinfo.b_middle_name IS NULL) AND (X_b_middle_name IS NULL)))
        AND ((tlinfo.b_ssn = x_b_ssn) OR ((tlinfo.b_ssn IS NULL) AND (X_b_ssn IS NULL)))
        AND ((tlinfo.b_addr_line_1 = x_b_addr_line_1) OR ((tlinfo.b_addr_line_1 IS NULL) AND (X_b_addr_line_1 IS NULL)))
        AND ((tlinfo.b_addr_line_2 = x_b_addr_line_2) OR ((tlinfo.b_addr_line_2 IS NULL) AND (X_b_addr_line_2 IS NULL)))
        AND ((tlinfo.b_city = x_b_city) OR ((tlinfo.b_city IS NULL) AND (X_b_city IS NULL)))
        AND ((tlinfo.b_state = x_b_state) OR ((tlinfo.b_state IS NULL) AND (X_b_state IS NULL)))
        AND ((tlinfo.b_zip = x_b_zip) OR ((tlinfo.b_zip IS NULL) AND (X_b_zip IS NULL)))
        AND ((tlinfo.b_zip_suffix = x_b_zip_suffix) OR ((tlinfo.b_zip_suffix IS NULL) AND (X_b_zip_suffix IS NULL)))
        AND ((tlinfo.b_addr_chg_date = x_b_addr_chg_date) OR ((tlinfo.b_addr_chg_date IS NULL) AND (X_b_addr_chg_date IS NULL)))
        AND ((tlinfo.eft_auth_code = x_eft_auth_code) OR ((tlinfo.eft_auth_code IS NULL) AND (X_eft_auth_code IS NULL)))
        AND ((tlinfo.s_last_name = x_s_last_name) OR ((tlinfo.s_last_name IS NULL) AND (X_s_last_name IS NULL)))
        AND ((tlinfo.s_first_name = x_s_first_name) OR ((tlinfo.s_first_name IS NULL) AND (X_s_first_name IS NULL)))
        AND ((tlinfo.s_middle_initial = x_s_middle_initial) OR ((tlinfo.s_middle_initial IS NULL) AND (X_s_middle_initial IS NULL)))
        AND ((tlinfo.s_ssn = x_s_ssn) OR ((tlinfo.s_ssn IS NULL) AND (X_s_ssn IS NULL)))
        AND (tlinfo.school_id = x_school_id)
        AND ((tlinfo.school_use = x_school_use) OR ((tlinfo.school_use IS NULL) AND (X_school_use IS NULL)))
        AND ((tlinfo.loan_per_start_date = x_loan_per_start_date) OR ((tlinfo.loan_per_start_date IS NULL) AND (X_loan_per_start_date IS NULL)))
        AND ((tlinfo.loan_per_end_date = x_loan_per_end_date) OR ((tlinfo.loan_per_end_date IS NULL) AND (X_loan_per_end_date IS NULL)))
        AND ((tlinfo.cl_loan_type = x_cl_loan_type) OR ((tlinfo.cl_loan_type IS NULL) AND (X_cl_loan_type IS NULL)))
        AND ((tlinfo.alt_prog_type_code = x_alt_prog_type_code) OR ((tlinfo.alt_prog_type_code IS NULL) AND (X_alt_prog_type_code IS NULL)))
        AND ((tlinfo.lender_id = x_lender_id) OR ((tlinfo.lender_id IS NULL) AND (X_lender_id IS NULL)))
        AND ((tlinfo.lend_non_ed_brc_id = x_lend_non_ed_brc_id) OR ((tlinfo.lend_non_ed_brc_id IS NULL) AND (X_lend_non_ed_brc_id IS NULL)))
        AND ((tlinfo.lender_use = x_lender_use) OR ((tlinfo.lender_use IS NULL) AND (X_lender_use IS NULL)))
        AND ((tlinfo.borw_confirm_ind = x_borw_confirm_ind) OR ((tlinfo.borw_confirm_ind IS NULL) AND (X_borw_confirm_ind IS NULL)))
        AND ((tlinfo.tot_sched_disb = x_tot_sched_disb) OR ((tlinfo.tot_sched_disb IS NULL) AND (X_tot_sched_disb IS NULL)))
        AND ((tlinfo.fund_release_date = x_fund_release_date) OR ((tlinfo.fund_release_date IS NULL) AND (X_fund_release_date IS NULL)))
        AND (tlinfo.disb_num = x_disb_num)
        AND ((tlinfo.guarantor_id = x_guarantor_id) OR ((tlinfo.guarantor_id IS NULL) AND (X_guarantor_id IS NULL)))
        AND ((tlinfo.guarantor_use = x_guarantor_use) OR ((tlinfo.guarantor_use IS NULL) AND (X_guarantor_use IS NULL)))
        AND ((tlinfo.guarantee_date = x_guarantee_date) OR ((tlinfo.guarantee_date IS NULL) AND (X_guarantee_date IS NULL)))
        AND ((tlinfo.guarantee_amt = x_guarantee_amt) OR ((tlinfo.guarantee_amt IS NULL) AND (X_guarantee_amt IS NULL)))
        AND ((tlinfo.gross_disb_amt = x_gross_disb_amt) OR ((tlinfo.gross_disb_amt IS NULL) AND (X_gross_disb_amt IS NULL)))
        AND ((tlinfo.fee_1 = x_fee_1) OR ((tlinfo.fee_1 IS NULL) AND (X_fee_1 IS NULL)))
        AND ((tlinfo.fee_2 = x_fee_2) OR ((tlinfo.fee_2 IS NULL) AND (X_fee_2 IS NULL)))
        AND ((tlinfo.net_disb_amt = x_net_disb_amt) OR ((tlinfo.net_disb_amt IS NULL) AND (X_net_disb_amt IS NULL)))
        AND ((tlinfo.fund_dist_mthd = x_fund_dist_mthd) OR ((tlinfo.fund_dist_mthd IS NULL) AND (X_fund_dist_mthd IS NULL)))
        AND ((tlinfo.check_number = x_check_number) OR ((tlinfo.check_number IS NULL) AND (X_check_number IS NULL)))
        AND ((tlinfo.late_disb_ind = x_late_disb_ind) OR ((tlinfo.late_disb_ind IS NULL) AND (X_late_disb_ind IS NULL)))
        AND ((tlinfo.prev_reported_ind = x_prev_reported_ind) OR ((tlinfo.prev_reported_ind IS NULL) AND (X_prev_reported_ind IS NULL)))
        AND ((tlinfo.err_code1 = x_err_code1) OR ((tlinfo.err_code1 IS NULL) AND (X_err_code1 IS NULL)))
        AND ((tlinfo.err_code2 = x_err_code2) OR ((tlinfo.err_code2 IS NULL) AND (X_err_code2 IS NULL)))
        AND ((tlinfo.err_code3 = x_err_code3) OR ((tlinfo.err_code3 IS NULL) AND (X_err_code3 IS NULL)))
        AND ((tlinfo.err_code4 = x_err_code4) OR ((tlinfo.err_code4 IS NULL) AND (X_err_code4 IS NULL)))
        AND ((tlinfo.err_code5 = x_err_code5) OR ((tlinfo.err_code5 IS NULL) AND (X_err_code5 IS NULL)))
        AND ((tlinfo.fee_paid_2 = x_fee_paid_2) OR ((tlinfo.fee_paid_2 IS NULL) AND (X_fee_paid_2 IS NULL)))
        AND ((tlinfo.lender_name = x_lender_name) OR ((tlinfo.lender_name IS NULL) AND (X_lender_name IS NULL)))
        AND ((tlinfo.net_cancel_amt = x_net_cancel_amt) OR ((tlinfo.net_cancel_amt IS NULL) AND (X_net_cancel_amt IS NULL)))
        AND ((tlinfo.duns_lender_id = x_duns_lender_id) OR ((tlinfo.duns_lender_id IS NULL) AND (X_duns_lender_id IS NULL)))
        AND ((tlinfo.duns_guarnt_id = x_duns_guarnt_id) OR ((tlinfo.duns_guarnt_id IS NULL) AND (X_duns_guarnt_id IS NULL)))
        AND ((tlinfo.hold_rel_ind = x_hold_rel_ind) OR ((tlinfo.hold_rel_ind IS NULL) AND (X_hold_rel_ind IS NULL)))
        AND ((tlinfo.pnote_code = x_pnote_code) OR ((tlinfo.pnote_code IS NULL) AND (X_pnote_code IS NULL)))
        AND ((tlinfo.pnote_status_date = x_pnote_status_date) OR ((tlinfo.pnote_status_date IS NULL) AND (X_pnote_status_date IS NULL)))
        AND ((tlinfo.fee_paid_1 = x_fee_paid_1) OR ((tlinfo.fee_paid_1 IS NULL) AND (X_fee_paid_1 IS NULL)))
        AND ((tlinfo.netted_cancel_amt = x_netted_cancel_amt) OR ((tlinfo.netted_cancel_amt IS NULL) AND (X_netted_cancel_amt IS NULL)))
        AND ((tlinfo.outstd_cancel_amt = x_outstd_cancel_amt) OR ((tlinfo.outstd_cancel_amt IS NULL) AND (X_outstd_cancel_amt IS NULL)))
        AND ((tlinfo.sch_non_ed_brc_id = x_sch_non_ed_brc_id) OR ((tlinfo.sch_non_ed_brc_id IS NULL) AND (X_sch_non_ed_brc_id IS NULL)))
        AND (tlinfo.status = x_status)
        AND ((tlinfo.esign_src_typ_cd = x_esign_src_typ_cd) OR ((tlinfo.esign_src_typ_cd IS NULL) AND (x_esign_src_typ_cd IS NULL)))
        AND ((tlinfo.direct_to_borr_flag = x_direct_to_borr_flag) OR ((tlinfo.direct_to_borr_flag IS NULL) AND (x_direct_to_borr_flag IS NULL)))
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
    x_rowid                             IN     VARCHAR2,
    x_cdbr_id                           IN     NUMBER,
    x_cbth_id                           IN     NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_b_last_name                       IN     VARCHAR2,
    x_b_first_name                      IN     VARCHAR2,
    x_b_middle_name                     IN     VARCHAR2,
    x_b_ssn                             IN     VARCHAR2,
    x_b_addr_line_1                     IN     VARCHAR2,
    x_b_addr_line_2                     IN     VARCHAR2,
    x_b_city                            IN     VARCHAR2,
    x_b_state                           IN     VARCHAR2,
    x_b_zip                             IN     NUMBER,
    x_b_zip_suffix                      IN     NUMBER,
    x_b_addr_chg_date                   IN     DATE,
    x_eft_auth_code                     IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_initial                  IN     VARCHAR2,
    x_s_ssn                             IN     VARCHAR2,
    x_school_id                         IN     NUMBER,
    x_school_use                        IN     VARCHAR2,
    x_loan_per_start_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_cl_loan_type                      IN     VARCHAR2,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_lender_use                        IN     VARCHAR2,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_tot_sched_disb                    IN     NUMBER,
    x_fund_release_date                 IN     DATE,
    x_disb_num                          IN     NUMBER,
    x_guarantor_id                      IN     VARCHAR2,
    x_guarantor_use                     IN     VARCHAR2,
    x_guarantee_date                    IN     DATE,
    x_guarantee_amt                     IN     NUMBER,
    x_gross_disb_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_net_disb_amt                      IN     NUMBER,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_check_number                      IN     VARCHAR2,
    x_late_disb_ind                     IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_err_code1                         IN     VARCHAR2,
    x_err_code2                         IN     VARCHAR2,
    x_err_code3                         IN     VARCHAR2,
    x_err_code4                         IN     VARCHAR2,
    x_err_code5                         IN     VARCHAR2,
    x_fee_paid_2                        IN     NUMBER,
    x_lender_name                       IN     VARCHAR2,
    x_net_cancel_amt                    IN     NUMBER,
    x_duns_lender_id                    IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_pnote_code                        IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_netted_cancel_amt                 IN     NUMBER,
    x_outstd_cancel_amt                 IN     NUMBER,
    x_sch_non_ed_brc_id                 IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_esign_src_typ_cd                  IN     VARCHAR2,
    x_direct_to_borr_flag               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_cdbr_id                           => x_cdbr_id,
      x_cbth_id                           => x_cbth_id,
      x_record_type                       => x_record_type,
      x_loan_number                       => x_loan_number,
      x_cl_seq_number                     => x_cl_seq_number,
      x_b_last_name                       => x_b_last_name,
      x_b_first_name                      => x_b_first_name,
      x_b_middle_name                     => x_b_middle_name,
      x_b_ssn                             => x_b_ssn,
      x_b_addr_line_1                     => x_b_addr_line_1,
      x_b_addr_line_2                     => x_b_addr_line_2,
      x_b_city                            => x_b_city,
      x_b_state                           => x_b_state,
      x_b_zip                             => x_b_zip,
      x_b_zip_suffix                      => x_b_zip_suffix,
      x_b_addr_chg_date                   => x_b_addr_chg_date,
      x_eft_auth_code                     => x_eft_auth_code,
      x_s_last_name                       => x_s_last_name,
      x_s_first_name                      => x_s_first_name,
      x_s_middle_initial                  => x_s_middle_initial,
      x_s_ssn                             => x_s_ssn,
      x_school_id                         => x_school_id,
      x_school_use                        => x_school_use,
      x_loan_per_start_date               => x_loan_per_start_date,
      x_loan_per_end_date                 => x_loan_per_end_date,
      x_cl_loan_type                      => x_cl_loan_type,
      x_alt_prog_type_code                => x_alt_prog_type_code,
      x_lender_id                         => x_lender_id,
      x_lend_non_ed_brc_id                => x_lend_non_ed_brc_id,
      x_lender_use                        => x_lender_use,
      x_borw_confirm_ind                  => x_borw_confirm_ind,
      x_tot_sched_disb                    => x_tot_sched_disb,
      x_fund_release_date                 => x_fund_release_date,
      x_disb_num                          => x_disb_num,
      x_guarantor_id                      => x_guarantor_id,
      x_guarantor_use                     => x_guarantor_use,
      x_guarantee_date                    => x_guarantee_date,
      x_guarantee_amt                     => x_guarantee_amt,
      x_gross_disb_amt                    => x_gross_disb_amt,
      x_fee_1                             => x_fee_1,
      x_fee_2                             => x_fee_2,
      x_net_disb_amt                      => x_net_disb_amt,
      x_fund_dist_mthd                    => x_fund_dist_mthd,
      x_check_number                      => x_check_number,
      x_late_disb_ind                     => x_late_disb_ind,
      x_prev_reported_ind                 => x_prev_reported_ind,
      x_err_code1                         => x_err_code1,
      x_err_code2                         => x_err_code2,
      x_err_code3                         => x_err_code3,
      x_err_code4                         => x_err_code4,
      x_err_code5                         => x_err_code5,
      x_fee_paid_2                        => x_fee_paid_2,
      x_lender_name                       => x_lender_name,
      x_net_cancel_amt                    => x_net_cancel_amt,
      x_duns_lender_id                    => x_duns_lender_id,
      x_duns_guarnt_id                    => x_duns_guarnt_id,
      x_hold_rel_ind                      => x_hold_rel_ind,
      x_pnote_code                        => x_pnote_code,
      x_pnote_status_date                 => x_pnote_status_date,
      x_fee_paid_1                        => x_fee_paid_1,
      x_netted_cancel_amt                 => x_netted_cancel_amt,
      x_outstd_cancel_amt                 => x_outstd_cancel_amt,
      x_sch_non_ed_brc_id                 => x_sch_non_ed_brc_id,
      x_status                            => x_status,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_esign_src_typ_cd                  => x_esign_src_typ_cd,
      x_direct_to_borr_flag               => x_direct_to_borr_flag
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igf_db_cl_disb_resp_all
      SET
        cbth_id                           = new_references.cbth_id,
        record_type                       = new_references.record_type,
        loan_number                       = new_references.loan_number,
        cl_seq_number                     = new_references.cl_seq_number,
        b_last_name                       = new_references.b_last_name,
        b_first_name                      = new_references.b_first_name,
        b_middle_name                     = new_references.b_middle_name,
        b_ssn                             = new_references.b_ssn,
        b_addr_line_1                     = new_references.b_addr_line_1,
        b_addr_line_2                     = new_references.b_addr_line_2,
        b_city                            = new_references.b_city,
        b_state                           = new_references.b_state,
        b_zip                             = new_references.b_zip,
        b_zip_suffix                      = new_references.b_zip_suffix,
        b_addr_chg_date                   = new_references.b_addr_chg_date,
        eft_auth_code                     = new_references.eft_auth_code,
        s_last_name                       = new_references.s_last_name,
        s_first_name                      = new_references.s_first_name,
        s_middle_initial                  = new_references.s_middle_initial,
        s_ssn                             = new_references.s_ssn,
        school_id                         = new_references.school_id,
        school_use                        = new_references.school_use,
        loan_per_start_date               = new_references.loan_per_start_date,
        loan_per_end_date                 = new_references.loan_per_end_date,
        cl_loan_type                      = new_references.cl_loan_type,
        alt_prog_type_code                = new_references.alt_prog_type_code,
        lender_id                         = new_references.lender_id,
        lend_non_ed_brc_id                = new_references.lend_non_ed_brc_id,
        lender_use                        = new_references.lender_use,
        borw_confirm_ind                  = new_references.borw_confirm_ind,
        tot_sched_disb                    = new_references.tot_sched_disb,
        fund_release_date                 = new_references.fund_release_date,
        disb_num                          = new_references.disb_num,
        guarantor_id                      = new_references.guarantor_id,
        guarantor_use                     = new_references.guarantor_use,
        guarantee_date                    = new_references.guarantee_date,
        guarantee_amt                     = new_references.guarantee_amt,
        gross_disb_amt                    = new_references.gross_disb_amt,
        fee_1                             = new_references.fee_1,
        fee_2                             = new_references.fee_2,
        net_disb_amt                      = new_references.net_disb_amt,
        fund_dist_mthd                    = new_references.fund_dist_mthd,
        check_number                      = new_references.check_number,
        late_disb_ind                     = new_references.late_disb_ind,
        prev_reported_ind                 = new_references.prev_reported_ind,
        err_code1                         = new_references.err_code1,
        err_code2                         = new_references.err_code2,
        err_code3                         = new_references.err_code3,
        err_code4                         = new_references.err_code4,
        err_code5                         = new_references.err_code5,
        fee_paid_2                        = new_references.fee_paid_2,
        lender_name                       = new_references.lender_name,
        net_cancel_amt                    = new_references.net_cancel_amt,
        duns_lender_id                    = new_references.duns_lender_id,
        duns_guarnt_id                    = new_references.duns_guarnt_id,
        hold_rel_ind                      = new_references.hold_rel_ind,
        pnote_code                        = new_references.pnote_code,
        pnote_status_date                 = new_references.pnote_status_date,
        fee_paid_1                        = new_references.fee_paid_1,
        netted_cancel_amt                 = new_references.netted_cancel_amt,
        outstd_cancel_amt                 = new_references.outstd_cancel_amt,
        sch_non_ed_brc_id                 = new_references.sch_non_ed_brc_id,
        status                            = new_references.status,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        esign_src_typ_cd                  = new_references.esign_src_typ_cd,
        direct_to_borr_flag               = new_references.direct_to_borr_flag
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cdbr_id                           IN OUT NOCOPY NUMBER,
    x_cbth_id                           IN     NUMBER,
    x_record_type                       IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_cl_seq_number                     IN     NUMBER,
    x_b_last_name                       IN     VARCHAR2,
    x_b_first_name                      IN     VARCHAR2,
    x_b_middle_name                     IN     VARCHAR2,
    x_b_ssn                             IN     VARCHAR2,
    x_b_addr_line_1                     IN     VARCHAR2,
    x_b_addr_line_2                     IN     VARCHAR2,
    x_b_city                            IN     VARCHAR2,
    x_b_state                           IN     VARCHAR2,
    x_b_zip                             IN     NUMBER,
    x_b_zip_suffix                      IN     NUMBER,
    x_b_addr_chg_date                   IN     DATE,
    x_eft_auth_code                     IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_middle_initial                  IN     VARCHAR2,
    x_s_ssn                             IN     VARCHAR2,
    x_school_id                         IN     NUMBER,
    x_school_use                        IN     VARCHAR2,
    x_loan_per_start_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_cl_loan_type                      IN     VARCHAR2,
    x_alt_prog_type_code                IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_lender_use                        IN     VARCHAR2,
    x_borw_confirm_ind                  IN     VARCHAR2,
    x_tot_sched_disb                    IN     NUMBER,
    x_fund_release_date                 IN     DATE,
    x_disb_num                          IN     NUMBER,
    x_guarantor_id                      IN     VARCHAR2,
    x_guarantor_use                     IN     VARCHAR2,
    x_guarantee_date                    IN     DATE,
    x_guarantee_amt                     IN     NUMBER,
    x_gross_disb_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_net_disb_amt                      IN     NUMBER,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_check_number                      IN     VARCHAR2,
    x_late_disb_ind                     IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_err_code1                         IN     VARCHAR2,
    x_err_code2                         IN     VARCHAR2,
    x_err_code3                         IN     VARCHAR2,
    x_err_code4                         IN     VARCHAR2,
    x_err_code5                         IN     VARCHAR2,
    x_fee_paid_2                        IN     NUMBER,
    x_lender_name                       IN     VARCHAR2,
    x_net_cancel_amt                    IN     NUMBER,
    x_duns_lender_id                    IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_pnote_code                        IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_netted_cancel_amt                 IN     NUMBER,
    x_outstd_cancel_amt                 IN     NUMBER,
    x_sch_non_ed_brc_id                 IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_esign_src_typ_cd                  IN     VARCHAR2,
    x_direct_to_borr_flag               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_db_cl_disb_resp_all
      WHERE    cdbr_id                           = x_cdbr_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_cdbr_id,
        x_cbth_id,
        x_record_type,
        x_loan_number,
        x_cl_seq_number,
        x_b_last_name,
        x_b_first_name,
        x_b_middle_name,
        x_b_ssn,
        x_b_addr_line_1,
        x_b_addr_line_2,
        x_b_city,
        x_b_state,
        x_b_zip,
        x_b_zip_suffix,
        x_b_addr_chg_date,
        x_eft_auth_code,
        x_s_last_name,
        x_s_first_name,
        x_s_middle_initial,
        x_s_ssn,
        x_school_id,
        x_school_use,
        x_loan_per_start_date,
        x_loan_per_end_date,
        x_cl_loan_type,
        x_alt_prog_type_code,
        x_lender_id,
        x_lend_non_ed_brc_id,
        x_lender_use,
        x_borw_confirm_ind,
        x_tot_sched_disb,
        x_fund_release_date,
        x_disb_num,
        x_guarantor_id,
        x_guarantor_use,
        x_guarantee_date,
        x_guarantee_amt,
        x_gross_disb_amt,
        x_fee_1,
        x_fee_2,
        x_net_disb_amt,
        x_fund_dist_mthd,
        x_check_number,
        x_late_disb_ind,
        x_prev_reported_ind,
        x_err_code1,
        x_err_code2,
        x_err_code3,
        x_err_code4,
        x_err_code5,
        x_fee_paid_2,
        x_lender_name,
        x_net_cancel_amt,
        x_duns_lender_id,
        x_duns_guarnt_id,
        x_hold_rel_ind,
        x_pnote_code,
        x_pnote_status_date,
        x_fee_paid_1,
        x_netted_cancel_amt,
        x_outstd_cancel_amt,
        x_sch_non_ed_brc_id,
        x_status,
        x_mode,
        x_esign_src_typ_cd,
        x_direct_to_borr_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_cdbr_id,
      x_cbth_id,
      x_record_type,
      x_loan_number,
      x_cl_seq_number,
      x_b_last_name,
      x_b_first_name,
      x_b_middle_name,
      x_b_ssn,
      x_b_addr_line_1,
      x_b_addr_line_2,
      x_b_city,
      x_b_state,
      x_b_zip,
      x_b_zip_suffix,
      x_b_addr_chg_date,
      x_eft_auth_code,
      x_s_last_name,
      x_s_first_name,
      x_s_middle_initial,
      x_s_ssn,
      x_school_id,
      x_school_use,
      x_loan_per_start_date,
      x_loan_per_end_date,
      x_cl_loan_type,
      x_alt_prog_type_code,
      x_lender_id,
      x_lend_non_ed_brc_id,
      x_lender_use,
      x_borw_confirm_ind,
      x_tot_sched_disb,
      x_fund_release_date,
      x_disb_num,
      x_guarantor_id,
      x_guarantor_use,
      x_guarantee_date,
      x_guarantee_amt,
      x_gross_disb_amt,
      x_fee_1,
      x_fee_2,
      x_net_disb_amt,
      x_fund_dist_mthd,
      x_check_number,
      x_late_disb_ind,
      x_prev_reported_ind,
      x_err_code1,
      x_err_code2,
      x_err_code3,
      x_err_code4,
      x_err_code5,
      x_fee_paid_2,
      x_lender_name,
      x_net_cancel_amt,
      x_duns_lender_id,
      x_duns_guarnt_id,
      x_hold_rel_ind,
      x_pnote_code,
      x_pnote_status_date,
      x_fee_paid_1,
      x_netted_cancel_amt,
      x_outstd_cancel_amt,
      x_sch_non_ed_brc_id,
      x_status,
      x_mode,
      x_esign_src_typ_cd,
      x_direct_to_borr_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igf_db_cl_disb_resp_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_db_cl_disb_resp_pkg;

/
