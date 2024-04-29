--------------------------------------------------------
--  DDL for Package Body IGF_SL_CLCHSN_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_CLCHSN_DTLS_PKG" AS
/* $Header: IGFLI40B.pls 120.1 2005/09/15 23:34:53 appldev noship $ */
/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_SL_CLCHSN_DTLS_PKG
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | This package has a flag on the end of some of the procedures called   |
 | X_MODE. Pass either 'R' for runtime, or 'I' for Install-time.         |
 | This will control how the who columns are filled in; If you are       |
 | running in runtime mode, they are taken from the profiles, whereas in |
 | install-time mode they get defaulted with special values to indicate  |
 | that they were inserted by datamerge.                                 |
 |                                                                       |
 | The ADD_ROW routine will see whether a row exists by selecting        |
 | based on the primary key, and updates the row if it exists,           |
 | or inserts the row if it doesn't already exist.                       |
 |                                                                       |
 | This module is called by AutoInstall (afplss.drv) on install and      |
 | upgrade.  The WHENEVER SQLERROR and EXIT (at bottom) are required.    |
 |                                                                       |
 | HISTORY                                                               |
 *=======================================================================*/


  l_rowid VARCHAR2(25);
  old_references igf_sl_clchsn_dtls%ROWTYPE;
  new_references igf_sl_clchsn_dtls%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_clchgsnd_id                       IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_loan_number_txt                   IN     VARCHAR2,
    x_cl_version_code                   IN     VARCHAR2,
    x_change_field_code                 IN     VARCHAR2,
    x_change_record_type_txt            IN     VARCHAR2,
    x_change_code_txt                   IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_response_status_code              IN     VARCHAR2,
    x_old_value_txt                     IN     VARCHAR2,
    x_new_value_txt                     IN     VARCHAR2,
    x_old_date                          IN     DATE,
    x_new_date                          IN     DATE,
    x_old_amt                           IN     NUMBER,
    x_new_amt                           IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_change_issue_code                 IN     VARCHAR2,
    x_disbursement_cancel_date          IN     DATE,
    x_disbursement_cancel_amt           IN     NUMBER,
    x_disbursement_revised_amt          IN     NUMBER,
    x_disbursement_revised_date         IN     DATE,
    x_disbursement_reissue_code         IN     VARCHAR2,
    x_disbursement_reinst_code          IN     VARCHAR2,
    x_disbursement_return_amt           IN     NUMBER,
    x_disbursement_return_date          IN     DATE,
    x_disbursement_return_code          IN     VARCHAR2,
    x_post_with_disb_return_amt         IN     NUMBER,
    x_post_with_disb_return_date        IN     DATE,
    x_post_with_disb_return_code        IN     VARCHAR2,
    x_prev_with_disb_return_amt         IN     NUMBER,
    x_prev_with_disb_return_date        IN     DATE,
    x_school_use_txt                    IN     VARCHAR2,
    x_lender_use_txt                    IN     VARCHAR2,
    x_guarantor_use_txt                 IN     VARCHAR2,
    x_validation_edit_txt               IN     VARCHAR2,
    x_send_record_txt                   IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 13-OCT-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_sl_clchsn_dtls
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED1');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.clchgsnd_id                       := x_clchgsnd_id;
    new_references.award_id                          := x_award_id;
    new_references.loan_number_txt                   := x_loan_number_txt;
    new_references.cl_version_code                   := x_cl_version_code;
    new_references.change_field_code                 := x_change_field_code;
    new_references.change_record_type_txt            := x_change_record_type_txt;
    new_references.change_code_txt                   := x_change_code_txt;
    new_references.status_code                       := x_status_code;
    new_references.status_date                       := x_status_date;
    new_references.response_status_code              := x_response_status_code;
    new_references.old_value_txt                     := x_old_value_txt;
    new_references.new_value_txt                     := x_new_value_txt;
    new_references.old_date                          := x_old_date;
    new_references.new_date                          := x_new_date;
    new_references.old_amt                           := x_old_amt;
    new_references.new_amt                           := x_new_amt;
    new_references.disbursement_number               := x_disbursement_number;
    new_references.disbursement_date                 := x_disbursement_date;
    new_references.change_issue_code                 := x_change_issue_code;
    new_references.disbursement_cancel_date          := x_disbursement_cancel_date;
    new_references.disbursement_cancel_amt           := x_disbursement_cancel_amt;
    new_references.disbursement_revised_amt          := x_disbursement_revised_amt;
    new_references.disbursement_revised_date         := x_disbursement_revised_date;
    new_references.disbursement_reissue_code         := x_disbursement_reissue_code;
    new_references.disbursement_reinst_code          := x_disbursement_reinst_code;
    new_references.disbursement_return_amt           := x_disbursement_return_amt;
    new_references.disbursement_return_date          := x_disbursement_return_date;
    new_references.disbursement_return_code          := x_disbursement_return_code;
    new_references.post_with_disb_return_amt         := x_post_with_disb_return_amt;
    new_references.post_with_disb_return_date        := x_post_with_disb_return_date;
    new_references.post_with_disb_return_code        := x_post_with_disb_return_code;
    new_references.prev_with_disb_return_amt         := x_prev_with_disb_return_amt;
    new_references.prev_with_disb_return_date        := x_prev_with_disb_return_date;
    new_references.school_use_txt                    := x_school_use_txt;
    new_references.lender_use_txt                    := x_lender_use_txt;
    new_references.guarantor_use_txt                 := x_guarantor_use_txt;
    new_references.validation_edit_txt               := x_validation_edit_txt;
    new_references.send_record_txt                   := x_send_record_txt;

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

 PROCEDURE update_loan_change_status(p_loan_number igf_sl_loans.loan_number%TYPE)
  /*
  ||  Created By : bvisvana
  ||  Created On : 13-Sep-2005
  ||  Purpose : Bug # 4575843 - Updating the loan change status each time the disbursement is INSERTED or UPDATED
  ||            If any one is in 'Not Ready' state the loan change status goes as 'Not Ready'. Else 'Ready to Send'
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  AS
      CURSOR cur_loans(cp_loan_number igf_sl_loans.loan_number%TYPE) IS
        SELECT igf_sl_loans.* FROM igf_sl_loans
            WHERE NVL(external_loan_id_txt,loan_number) = cp_loan_number ;
      loan_rec cur_loans%ROWTYPE;

      CURSOR cur_chng_dtls(cp_loan_number igf_sl_loans.loan_number%TYPE) IS
        SELECT 'N' FROM igf_sl_clchsn_dtls WHERE loan_number_txt = cp_loan_number AND
        status_code  = 'N';
       chng_dtls_rec cur_chng_dtls%ROWTYPE;

      loan_chng_status VARCHAR2(1);

  BEGIN
          OPEN cur_chng_dtls(cp_loan_number => p_loan_number);
          FETCH cur_chng_dtls INTO chng_dtls_rec;

          IF cur_chng_dtls%NOTFOUND THEN
            loan_chng_status := 'G';
          ELSE
            loan_chng_status := 'N';
          END IF;
          CLOSE cur_chng_dtls;

          OPEN cur_loans(cp_loan_number => p_loan_number);
          FETCH cur_loans INTO loan_rec;
          igf_sl_loans_pkg.update_row (
            X_Mode                              => 'R',
            x_rowid                             => loan_rec.row_id,
            x_loan_id                           => loan_rec.loan_id,
            x_award_id                          => loan_rec.award_id,
            x_seq_num                           => loan_rec.seq_num,
            x_loan_number                       => loan_rec.loan_number,
            x_loan_per_begin_date               => loan_rec.loan_per_begin_date,
            x_loan_per_end_date                 => loan_rec.loan_per_end_date,
            x_loan_status                       => loan_rec.loan_status,
            x_loan_status_date                  => loan_rec.loan_status_date,
            x_loan_chg_status                   => loan_chng_status,
            x_loan_chg_status_date              => TRUNC(SYSDATE),
            x_active                            => loan_rec.active,
            x_active_date                       => loan_rec.active_date,
            x_borw_detrm_code                   => loan_rec.borw_detrm_code,
            x_legacy_record_flag                => NULL,
            x_external_loan_id_txt              => loan_rec.external_loan_id_txt
          );
          CLOSE cur_loans;
  END update_loan_change_status;

  PROCEDURE after_dml(p_action VARCHAR2) AS
  /*
  ||  Created By : bvisvana
  ||  Created On : 13-Sep-2005
  ||  Purpose : Bug # 4575843 - After DML actions
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
        IF (p_action IN ('INSERTING','UPDATING')) THEN
            update_loan_change_status(new_references.loan_number_txt);
        END IF;
  END after_dml;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 13-OCT-2004
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
     IF ((old_references.loan_number_txt = new_references.loan_number_txt))
        OR
        ((new_references.loan_number_txt IS NULL)) THEN
        NULL;
     ELSIF NOT igf_sl_loans_pkg.get_uk_for_validation (
                 x_loan_number => new_references.loan_number_txt
                )  THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED2');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
     END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_clchgsnd_id           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 13-OCT-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
      CURSOR cur_rowid IS
      SELECT rowid
      FROM   igf_sl_clchsn_dtls
      WHERE  clchgsnd_id = x_clchgsnd_id
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

  PROCEDURE get_ufk_igf_sl_loans (
  x_loan_number IN VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 13-OCT-2004
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

      CURSOR cur_rowid IS
      SELECT rowid
      FROM   igf_sl_clchsn_dtls
      WHERE  ((loan_number_txt = x_loan_number ));

      lv_rowid cur_rowid%ROWTYPE;
  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SL_CLCHGSND_LAR_UK_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igf_sl_loans;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_clchgsnd_id                       IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_loan_number_txt                   IN     VARCHAR2,
    x_cl_version_code                   IN     VARCHAR2,
    x_change_field_code                 IN     VARCHAR2,
    x_change_record_type_txt            IN     VARCHAR2,
    x_change_code_txt                   IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_response_status_code              IN     VARCHAR2,
    x_old_value_txt                     IN     VARCHAR2,
    x_new_value_txt                     IN     VARCHAR2,
    x_old_date                          IN     DATE,
    x_new_date                          IN     DATE,
    x_old_amt                           IN     NUMBER,
    x_new_amt                           IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_change_issue_code                 IN     VARCHAR2,
    x_disbursement_cancel_date          IN     DATE,
    x_disbursement_cancel_amt           IN     NUMBER,
    x_disbursement_revised_amt          IN     NUMBER,
    x_disbursement_revised_date         IN     DATE,
    x_disbursement_reissue_code         IN     VARCHAR2,
    x_disbursement_reinst_code          IN     VARCHAR2,
    x_disbursement_return_amt           IN     NUMBER,
    x_disbursement_return_date          IN     DATE,
    x_disbursement_return_code          IN     VARCHAR2,
    x_post_with_disb_return_amt         IN     NUMBER,
    x_post_with_disb_return_date        IN     DATE,
    x_post_with_disb_return_code        IN     VARCHAR2,
    x_prev_with_disb_return_amt         IN     NUMBER,
    x_prev_with_disb_return_date        IN     DATE,
    x_school_use_txt                    IN     VARCHAR2,
    x_lender_use_txt                    IN     VARCHAR2,
    x_guarantor_use_txt                 IN     VARCHAR2,
    x_validation_edit_txt               IN     VARCHAR2,
    x_send_record_txt                   IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 13-OCT-2004
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
      x_clchgsnd_id,
      x_award_id,
      x_loan_number_txt,
      x_cl_version_code,
      x_change_field_code,
      x_change_record_type_txt,
      x_change_code_txt,
      x_status_code,
      x_status_date,
      x_response_status_code,
      x_old_value_txt,
      x_new_value_txt,
      x_old_date,
      x_new_date,
      x_old_amt,
      x_new_amt,
      x_disbursement_number,
      x_disbursement_date,
      x_change_issue_code,
      x_disbursement_cancel_date,
      x_disbursement_cancel_amt,
      x_disbursement_revised_amt,
      x_disbursement_revised_date,
      x_disbursement_reissue_code,
      x_disbursement_reinst_code,
      x_disbursement_return_amt,
      x_disbursement_return_date,
      x_disbursement_return_code,
      x_post_with_disb_return_amt,
      x_post_with_disb_return_date,
      x_post_with_disb_return_code,
      x_prev_with_disb_return_amt,
      x_prev_with_disb_return_date,
      x_school_use_txt,
      x_lender_use_txt,
      x_guarantor_use_txt,
      x_validation_edit_txt,
      x_send_record_txt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.clchgsnd_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.

      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.clchgsnd_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    l_rowid := NULL;
  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clchgsnd_id                       IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_loan_number_txt                   IN     VARCHAR2,
    x_cl_version_code                   IN     VARCHAR2,
    x_change_field_code                 IN     VARCHAR2,
    x_change_record_type_txt            IN     VARCHAR2,
    x_change_code_txt                   IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_response_status_code              IN     VARCHAR2,
    x_old_value_txt                     IN     VARCHAR2,
    x_new_value_txt                     IN     VARCHAR2,
    x_old_date                          IN     DATE,
    x_new_date                          IN     DATE,
    x_old_amt                           IN     NUMBER,
    x_new_amt                           IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_change_issue_code                 IN     VARCHAR2,
    x_disbursement_cancel_date          IN     DATE,
    x_disbursement_cancel_amt           IN     NUMBER,
    x_disbursement_revised_amt          IN     NUMBER,
    x_disbursement_revised_date         IN     DATE,
    x_disbursement_reissue_code         IN     VARCHAR2,
    x_disbursement_reinst_code          IN     VARCHAR2,
    x_disbursement_return_amt           IN     NUMBER,
    x_disbursement_return_date          IN     DATE,
    x_disbursement_return_code          IN     VARCHAR2,
    x_post_with_disb_return_amt         IN     NUMBER,
    x_post_with_disb_return_date        IN     DATE,
    x_post_with_disb_return_code        IN     VARCHAR2,
    x_prev_with_disb_return_amt         IN     NUMBER,
    x_prev_with_disb_return_date        IN     DATE,
    x_school_use_txt                    IN     VARCHAR2,
    x_lender_use_txt                    IN     VARCHAR2,
    x_guarantor_use_txt                 IN     VARCHAR2,
    x_validation_edit_txt               IN     VARCHAR2,
    x_send_record_txt                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 13-OCT-2004
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      fnd_message.set_token ('ROUTINE', 'IGF_SL_CLCHSN_DTLS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_clchgsnd_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_clchgsnd_id                       => x_clchgsnd_id,
      x_award_id                          => x_award_id,
      x_loan_number_txt                   => x_loan_number_txt,
      x_cl_version_code                   => x_cl_version_code,
      x_change_field_code                 => x_change_field_code,
      x_change_record_type_txt            => x_change_record_type_txt,
      x_change_code_txt                   => x_change_code_txt,
      x_status_code                       => x_status_code,
      x_status_date                       => x_status_date,
      x_response_status_code              => x_response_status_code,
      x_old_value_txt                     => x_old_value_txt,
      x_new_value_txt                     => x_new_value_txt,
      x_old_date                          => x_old_date,
      x_new_date                          => x_new_date,
      x_old_amt                           => x_old_amt,
      x_new_amt                           => x_new_amt,
      x_disbursement_number               => x_disbursement_number,
      x_disbursement_date                 => x_disbursement_date,
      x_change_issue_code                 => x_change_issue_code,
      x_disbursement_cancel_date          => x_disbursement_cancel_date,
      x_disbursement_cancel_amt           => x_disbursement_cancel_amt,
      x_disbursement_revised_amt          => x_disbursement_revised_amt,
      x_disbursement_revised_date         => x_disbursement_revised_date,
      x_disbursement_reissue_code         => x_disbursement_reissue_code,
      x_disbursement_reinst_code          => x_disbursement_reinst_code,
      x_disbursement_return_amt           => x_disbursement_return_amt,
      x_disbursement_return_date          => x_disbursement_return_date,
      x_disbursement_return_code          => x_disbursement_return_code,
      x_post_with_disb_return_amt         => x_post_with_disb_return_amt,
      x_post_with_disb_return_date        => x_post_with_disb_return_date,
      x_post_with_disb_return_code        => x_post_with_disb_return_code,
      x_prev_with_disb_return_amt         => x_prev_with_disb_return_amt,
      x_prev_with_disb_return_date        => x_prev_with_disb_return_date,
      x_school_use_txt                    => x_school_use_txt,
      x_lender_use_txt                    => x_lender_use_txt,
      x_guarantor_use_txt                 => x_guarantor_use_txt,
      x_validation_edit_txt               => x_validation_edit_txt,
      x_send_record_txt                   => x_send_record_txt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_sl_clchsn_dtls (
      clchgsnd_id,
      award_id,
      loan_number_txt,
      cl_version_code,
      change_field_code,
      change_record_type_txt,
      change_code_txt,
      status_code,
      status_date,
      response_status_code,
      old_value_txt,
      new_value_txt,
      old_date,
      new_date,
      old_amt,
      new_amt,
      disbursement_number,
      disbursement_date,
      change_issue_code,
      disbursement_cancel_date,
      disbursement_cancel_amt,
      disbursement_revised_amt,
      disbursement_revised_date,
      disbursement_reissue_code,
      disbursement_reinst_code,
      disbursement_return_amt,
      disbursement_return_date,
      disbursement_return_code,
      post_with_disb_return_amt,
      post_with_disb_return_date,
      post_with_disb_return_code,
      prev_with_disb_return_amt,
      prev_with_disb_return_date,
      school_use_txt,
      lender_use_txt,
      guarantor_use_txt,
      validation_edit_txt,
      send_record_txt,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      igf_sl_clchsn_dtls_s.NEXTVAL,
      new_references.award_id,
      new_references.loan_number_txt,
      new_references.cl_version_code,
      new_references.change_field_code,
      new_references.change_record_type_txt,
      new_references.change_code_txt,
      new_references.status_code,
      new_references.status_date,
      new_references.response_status_code,
      new_references.old_value_txt,
      new_references.new_value_txt,
      new_references.old_date,
      new_references.new_date,
      new_references.old_amt,
      new_references.new_amt,
      new_references.disbursement_number,
      new_references.disbursement_date,
      new_references.change_issue_code,
      new_references.disbursement_cancel_date,
      new_references.disbursement_cancel_amt,
      new_references.disbursement_revised_amt,
      new_references.disbursement_revised_date,
      new_references.disbursement_reissue_code,
      new_references.disbursement_reinst_code,
      new_references.disbursement_return_amt,
      new_references.disbursement_return_date,
      new_references.disbursement_return_code,
      new_references.post_with_disb_return_amt,
      new_references.post_with_disb_return_date,
      new_references.post_with_disb_return_code,
      new_references.prev_with_disb_return_amt,
      new_references.prev_with_disb_return_date,
      new_references.school_use_txt,
      new_references.lender_use_txt,
      new_references.guarantor_use_txt,
      new_references.validation_edit_txt,
      new_references.send_record_txt,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID, clchgsnd_id INTO x_rowid, x_clchgsnd_id;

    after_dml(p_action => 'INSERTING');

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_clchgsnd_id                       IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_loan_number_txt                   IN     VARCHAR2,
    x_cl_version_code                   IN     VARCHAR2,
    x_change_field_code                 IN     VARCHAR2,
    x_change_record_type_txt            IN     VARCHAR2,
    x_change_code_txt                   IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_response_status_code              IN     VARCHAR2,
    x_old_value_txt                     IN     VARCHAR2,
    x_new_value_txt                     IN     VARCHAR2,
    x_old_date                          IN     DATE,
    x_new_date                          IN     DATE,
    x_old_amt                           IN     NUMBER,
    x_new_amt                           IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_change_issue_code                 IN     VARCHAR2,
    x_disbursement_cancel_date          IN     DATE,
    x_disbursement_cancel_amt           IN     NUMBER,
    x_disbursement_revised_amt          IN     NUMBER,
    x_disbursement_revised_date         IN     DATE,
    x_disbursement_reissue_code         IN     VARCHAR2,
    x_disbursement_reinst_code          IN     VARCHAR2,
    x_disbursement_return_amt           IN     NUMBER,
    x_disbursement_return_date          IN     DATE,
    x_disbursement_return_code          IN     VARCHAR2,
    x_post_with_disb_return_amt         IN     NUMBER,
    x_post_with_disb_return_date        IN     DATE,
    x_post_with_disb_return_code        IN     VARCHAR2,
    x_prev_with_disb_return_amt         IN     NUMBER,
    x_prev_with_disb_return_date        IN     DATE,
    x_school_use_txt                    IN     VARCHAR2,
    x_lender_use_txt                    IN     VARCHAR2,
    x_guarantor_use_txt                 IN     VARCHAR2,
    x_validation_edit_txt               IN     VARCHAR2,
    x_send_record_txt                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 13-OCT-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        clchgsnd_id,
        award_id,
        loan_number_txt,
        cl_version_code,
        change_field_code,
        change_record_type_txt,
        change_code_txt,
        status_code,
        status_date,
        response_status_code,
        old_value_txt,
        new_value_txt,
        old_date,
        new_date,
        old_amt,
        new_amt,
        disbursement_number,
        disbursement_date,
        change_issue_code,
        disbursement_cancel_date,
        disbursement_cancel_amt,
        disbursement_revised_amt,
        disbursement_revised_date,
        disbursement_reissue_code,
        disbursement_reinst_code,
        disbursement_return_amt,
        disbursement_return_date,
        disbursement_return_code,
        post_with_disb_return_amt,
        post_with_disb_return_date,
        post_with_disb_return_code,
        prev_with_disb_return_amt,
        prev_with_disb_return_date,
        school_use_txt,
        lender_use_txt,
        guarantor_use_txt,
        validation_edit_txt,
        send_record_txt
      FROM  igf_sl_clchsn_dtls
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED3');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.clchgsnd_id = x_clchgsnd_id)
        AND (tlinfo.award_id = x_award_id)
        AND (tlinfo.loan_number_txt = x_loan_number_txt)
        AND (tlinfo.cl_version_code = x_cl_version_code)
        AND (tlinfo.change_field_code = x_change_field_code)
        AND (tlinfo.change_record_type_txt = x_change_record_type_txt)
        AND (tlinfo.change_code_txt = x_change_code_txt)
        AND (tlinfo.status_code = x_status_code)
        AND (tlinfo.status_date = x_status_date)
        AND ((tlinfo.response_status_code = x_response_status_code) OR ((tlinfo.response_status_code IS NULL) AND (X_response_status_code IS NULL)))
        AND ((tlinfo.old_value_txt = x_old_value_txt) OR ((tlinfo.old_value_txt IS NULL) AND (X_old_value_txt IS NULL)))
        AND ((tlinfo.new_value_txt = x_new_value_txt) OR ((tlinfo.new_value_txt IS NULL) AND (X_new_value_txt IS NULL)))
        AND ((tlinfo.old_date = x_old_date) OR ((tlinfo.old_date IS NULL) AND (X_old_date IS NULL)))
        AND ((tlinfo.new_date = x_new_date) OR ((tlinfo.new_date IS NULL) AND (X_new_date IS NULL)))
        AND ((tlinfo.old_amt = x_old_amt) OR ((tlinfo.old_amt IS NULL) AND (X_old_amt IS NULL)))
        AND ((tlinfo.new_amt = x_new_amt) OR ((tlinfo.new_amt IS NULL) AND (X_new_amt IS NULL)))
        AND ((tlinfo.disbursement_number = x_disbursement_number) OR ((tlinfo.disbursement_number IS NULL) AND (X_disbursement_number IS NULL)))
        AND ((tlinfo.disbursement_date = x_disbursement_date) OR ((tlinfo.disbursement_date IS NULL) AND (X_disbursement_date IS NULL)))
        AND ((tlinfo.change_issue_code = x_change_issue_code) OR ((tlinfo.change_issue_code IS NULL) AND (X_change_issue_code IS NULL)))
        AND ((tlinfo.disbursement_cancel_date = x_disbursement_cancel_date) OR ((tlinfo.disbursement_cancel_date IS NULL) AND (X_disbursement_cancel_date IS NULL)))
        AND ((tlinfo.disbursement_cancel_amt = x_disbursement_cancel_amt) OR ((tlinfo.disbursement_cancel_amt IS NULL) AND (X_disbursement_cancel_amt IS NULL)))
        AND ((tlinfo.disbursement_revised_amt = x_disbursement_revised_amt) OR ((tlinfo.disbursement_revised_amt IS NULL) AND (X_disbursement_revised_amt IS NULL)))
        AND ((tlinfo.disbursement_revised_date = x_disbursement_revised_date) OR ((tlinfo.disbursement_revised_date IS NULL) AND (X_disbursement_revised_date IS NULL)))
        AND ((tlinfo.disbursement_reissue_code = x_disbursement_reissue_code) OR ((tlinfo.disbursement_reissue_code IS NULL) AND (X_disbursement_reissue_code IS NULL)))
        AND ((tlinfo.disbursement_reinst_code = x_disbursement_reinst_code) OR ((tlinfo.disbursement_reinst_code IS NULL) AND (X_disbursement_reinst_code IS NULL)))
        AND ((tlinfo.disbursement_return_amt = x_disbursement_return_amt) OR ((tlinfo.disbursement_return_amt IS NULL) AND (X_disbursement_return_amt IS NULL)))
        AND ((tlinfo.disbursement_return_date = x_disbursement_return_date) OR ((tlinfo.disbursement_return_date IS NULL) AND (X_disbursement_return_date IS NULL)))
        AND ((tlinfo.disbursement_return_code = x_disbursement_return_code) OR ((tlinfo.disbursement_return_code IS NULL) AND (X_disbursement_return_code IS NULL)))
        AND ((tlinfo.post_with_disb_return_amt = x_post_with_disb_return_amt) OR ((tlinfo.post_with_disb_return_amt IS NULL) AND (X_post_with_disb_return_amt IS NULL)))
        AND ((tlinfo.post_with_disb_return_date = x_post_with_disb_return_date) OR ((tlinfo.post_with_disb_return_date IS NULL) AND (X_post_with_disb_return_date IS NULL)))
        AND ((tlinfo.post_with_disb_return_code = x_post_with_disb_return_code) OR ((tlinfo.post_with_disb_return_code IS NULL) AND (X_post_with_disb_return_code IS NULL)))
        AND ((tlinfo.prev_with_disb_return_amt = x_prev_with_disb_return_amt) OR ((tlinfo.prev_with_disb_return_amt IS NULL) AND (X_prev_with_disb_return_amt IS NULL)))
        AND ((tlinfo.prev_with_disb_return_date = x_prev_with_disb_return_date) OR ((tlinfo.prev_with_disb_return_date IS NULL) AND (X_prev_with_disb_return_date IS NULL)))
        AND ((tlinfo.school_use_txt = x_school_use_txt) OR ((tlinfo.school_use_txt IS NULL) AND (X_school_use_txt IS NULL)))
        AND ((tlinfo.lender_use_txt = x_lender_use_txt) OR ((tlinfo.lender_use_txt IS NULL) AND (X_lender_use_txt IS NULL)))
        AND ((tlinfo.guarantor_use_txt = x_guarantor_use_txt) OR ((tlinfo.guarantor_use_txt IS NULL) AND (X_guarantor_use_txt IS NULL)))
        AND ((tlinfo.validation_edit_txt = x_validation_edit_txt) OR ((tlinfo.validation_edit_txt IS NULL) AND (X_validation_edit_txt IS NULL)))
        AND ((RTRIM(LTRIM(tlinfo.send_record_txt)) = RTRIM(LTRIM(x_send_record_txt))) OR ((RTRIM(LTRIM(tlinfo.send_record_txt)) IS NULL) AND (RTRIM(LTRIM(X_send_record_txt)) IS NULL)))
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
    x_clchgsnd_id                       IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_loan_number_txt                   IN     VARCHAR2,
    x_cl_version_code                   IN     VARCHAR2,
    x_change_field_code                 IN     VARCHAR2,
    x_change_record_type_txt            IN     VARCHAR2,
    x_change_code_txt                   IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_response_status_code              IN     VARCHAR2,
    x_old_value_txt                     IN     VARCHAR2,
    x_new_value_txt                     IN     VARCHAR2,
    x_old_date                          IN     DATE,
    x_new_date                          IN     DATE,
    x_old_amt                           IN     NUMBER,
    x_new_amt                           IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_change_issue_code                 IN     VARCHAR2,
    x_disbursement_cancel_date          IN     DATE,
    x_disbursement_cancel_amt           IN     NUMBER,
    x_disbursement_revised_amt          IN     NUMBER,
    x_disbursement_revised_date         IN     DATE,
    x_disbursement_reissue_code         IN     VARCHAR2,
    x_disbursement_reinst_code          IN     VARCHAR2,
    x_disbursement_return_amt           IN     NUMBER,
    x_disbursement_return_date          IN     DATE,
    x_disbursement_return_code          IN     VARCHAR2,
    x_post_with_disb_return_amt         IN     NUMBER,
    x_post_with_disb_return_date        IN     DATE,
    x_post_with_disb_return_code        IN     VARCHAR2,
    x_prev_with_disb_return_amt         IN     NUMBER,
    x_prev_with_disb_return_date        IN     DATE,
    x_school_use_txt                    IN     VARCHAR2,
    x_lender_use_txt                    IN     VARCHAR2,
    x_guarantor_use_txt                 IN     VARCHAR2,
    x_validation_edit_txt               IN     VARCHAR2,
    x_send_record_txt                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 13-OCT-2004
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  bvisvana        13-Sept-2005    Bug # 4575843 - Added after_dml after updation is complete.
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
      fnd_message.set_token ('ROUTINE', 'IGF_SL_CLCHSN_DTLS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_clchgsnd_id                       => x_clchgsnd_id,
      x_award_id                          => x_award_id,
      x_loan_number_txt                   => x_loan_number_txt,
      x_cl_version_code                   => x_cl_version_code,
      x_change_field_code                 => x_change_field_code,
      x_change_record_type_txt            => x_change_record_type_txt,
      x_change_code_txt                   => x_change_code_txt,
      x_status_code                       => x_status_code,
      x_status_date                       => x_status_date,
      x_response_status_code              => x_response_status_code,
      x_old_value_txt                     => x_old_value_txt,
      x_new_value_txt                     => x_new_value_txt,
      x_old_date                          => x_old_date,
      x_new_date                          => x_new_date,
      x_old_amt                           => x_old_amt,
      x_new_amt                           => x_new_amt,
      x_disbursement_number               => x_disbursement_number,
      x_disbursement_date                 => x_disbursement_date,
      x_change_issue_code                 => x_change_issue_code,
      x_disbursement_cancel_date          => x_disbursement_cancel_date,
      x_disbursement_cancel_amt           => x_disbursement_cancel_amt,
      x_disbursement_revised_amt          => x_disbursement_revised_amt,
      x_disbursement_revised_date         => x_disbursement_revised_date,
      x_disbursement_reissue_code         => x_disbursement_reissue_code,
      x_disbursement_reinst_code          => x_disbursement_reinst_code,
      x_disbursement_return_amt           => x_disbursement_return_amt,
      x_disbursement_return_date          => x_disbursement_return_date,
      x_disbursement_return_code          => x_disbursement_return_code,
      x_post_with_disb_return_amt         => x_post_with_disb_return_amt,
      x_post_with_disb_return_date        => x_post_with_disb_return_date,
      x_post_with_disb_return_code        => x_post_with_disb_return_code,
      x_prev_with_disb_return_amt         => x_prev_with_disb_return_amt,
      x_prev_with_disb_return_date        => x_prev_with_disb_return_date,
      x_school_use_txt                    => x_school_use_txt,
      x_lender_use_txt                    => x_lender_use_txt,
      x_guarantor_use_txt                 => x_guarantor_use_txt,
      x_validation_edit_txt               => x_validation_edit_txt,
      x_send_record_txt                   => x_send_record_txt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
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

    UPDATE igf_sl_clchsn_dtls
      SET
        clchgsnd_id                       = new_references.clchgsnd_id,
        award_id                          = new_references.award_id,
        loan_number_txt                   = new_references.loan_number_txt,
        cl_version_code                   = new_references.cl_version_code,
        change_field_code                 = new_references.change_field_code,
        change_record_type_txt            = new_references.change_record_type_txt,
        change_code_txt                   = new_references.change_code_txt,
        status_code                       = new_references.status_code,
        status_date                       = new_references.status_date,
        response_status_code              = new_references.response_status_code,
        old_value_txt                     = new_references.old_value_txt,
        new_value_txt                     = new_references.new_value_txt,
        old_date                          = new_references.old_date,
        new_date                          = new_references.new_date,
        old_amt                           = new_references.old_amt,
        new_amt                           = new_references.new_amt,
        disbursement_number               = new_references.disbursement_number,
        disbursement_date                 = new_references.disbursement_date,
        change_issue_code                 = new_references.change_issue_code,
        disbursement_cancel_date          = new_references.disbursement_cancel_date,
        disbursement_cancel_amt           = new_references.disbursement_cancel_amt,
        disbursement_revised_amt          = new_references.disbursement_revised_amt,
        disbursement_revised_date         = new_references.disbursement_revised_date,
        disbursement_reissue_code         = new_references.disbursement_reissue_code,
        disbursement_reinst_code          = new_references.disbursement_reinst_code,
        disbursement_return_amt           = new_references.disbursement_return_amt,
        disbursement_return_date          = new_references.disbursement_return_date,
        disbursement_return_code          = new_references.disbursement_return_code,
        post_with_disb_return_amt         = new_references.post_with_disb_return_amt,
        post_with_disb_return_date        = new_references.post_with_disb_return_date,
        post_with_disb_return_code        = new_references.post_with_disb_return_code,
        prev_with_disb_return_amt         = new_references.prev_with_disb_return_amt,
        prev_with_disb_return_date        = new_references.prev_with_disb_return_date,
        school_use_txt                    = new_references.school_use_txt,
        lender_use_txt                    = new_references.lender_use_txt,
        guarantor_use_txt                 = new_references.guarantor_use_txt,
        validation_edit_txt               = new_references.validation_edit_txt,
        send_record_txt                   = new_references.send_record_txt,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    after_dml(p_action => 'UPDATING');

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clchgsnd_id                       IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_loan_number_txt                   IN     VARCHAR2,
    x_cl_version_code                   IN     VARCHAR2,
    x_change_field_code                 IN     VARCHAR2,
    x_change_record_type_txt            IN     VARCHAR2,
    x_change_code_txt                   IN     VARCHAR2,
    x_status_code                       IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_response_status_code              IN     VARCHAR2,
    x_old_value_txt                     IN     VARCHAR2,
    x_new_value_txt                     IN     VARCHAR2,
    x_old_date                          IN     DATE,
    x_new_date                          IN     DATE,
    x_old_amt                           IN     NUMBER,
    x_new_amt                           IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_change_issue_code                 IN     VARCHAR2,
    x_disbursement_cancel_date          IN     DATE,
    x_disbursement_cancel_amt           IN     NUMBER,
    x_disbursement_revised_amt          IN     NUMBER,
    x_disbursement_revised_date         IN     DATE,
    x_disbursement_reissue_code         IN     VARCHAR2,
    x_disbursement_reinst_code          IN     VARCHAR2,
    x_disbursement_return_amt           IN     NUMBER,
    x_disbursement_return_date          IN     DATE,
    x_disbursement_return_code          IN     VARCHAR2,
    x_post_with_disb_return_amt         IN     NUMBER,
    x_post_with_disb_return_date        IN     DATE,
    x_post_with_disb_return_code        IN     VARCHAR2,
    x_prev_with_disb_return_amt         IN     NUMBER,
    x_prev_with_disb_return_date        IN     DATE,
    x_school_use_txt                    IN     VARCHAR2,
    x_lender_use_txt                    IN     VARCHAR2,
    x_guarantor_use_txt                 IN     VARCHAR2,
    x_validation_edit_txt               IN     VARCHAR2,
    x_send_record_txt                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 13-OCT-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  bvisvana        13-Sept-2005    Bug # 4575843 - Added after_dml after Inserting.
  */
      CURSOR c1 IS
      SELECT rowid
      FROM   igf_sl_clchsn_dtls
      WHERE  clchgsnd_id = x_clchgsnd_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_clchgsnd_id,
        x_award_id,
        x_loan_number_txt,
        x_cl_version_code,
        x_change_field_code,
        x_change_record_type_txt,
        x_change_code_txt,
        x_status_code,
        x_status_date,
        x_response_status_code,
        x_old_value_txt,
        x_new_value_txt,
        x_old_date,
        x_new_date,
        x_old_amt,
        x_new_amt,
        x_disbursement_number,
        x_disbursement_date,
        x_change_issue_code,
        x_disbursement_cancel_date,
        x_disbursement_cancel_amt,
        x_disbursement_revised_amt,
        x_disbursement_revised_date,
        x_disbursement_reissue_code,
        x_disbursement_reinst_code,
        x_disbursement_return_amt,
        x_disbursement_return_date,
        x_disbursement_return_code,
        x_post_with_disb_return_amt,
        x_post_with_disb_return_date,
        x_post_with_disb_return_code,
        x_prev_with_disb_return_amt,
        x_prev_with_disb_return_date,
        x_school_use_txt,
        x_lender_use_txt,
        x_guarantor_use_txt,
        x_validation_edit_txt,
        x_send_record_txt,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_clchgsnd_id,
      x_award_id,
      x_loan_number_txt,
      x_cl_version_code,
      x_change_field_code,
      x_change_record_type_txt,
      x_change_code_txt,
      x_status_code,
      x_status_date,
      x_response_status_code,
      x_old_value_txt,
      x_new_value_txt,
      x_old_date,
      x_new_date,
      x_old_amt,
      x_new_amt,
      x_disbursement_number,
      x_disbursement_date,
      x_change_issue_code,
      x_disbursement_cancel_date,
      x_disbursement_cancel_amt,
      x_disbursement_revised_amt,
      x_disbursement_revised_date,
      x_disbursement_reissue_code,
      x_disbursement_reinst_code,
      x_disbursement_return_amt,
      x_disbursement_return_date,
      x_disbursement_return_code,
      x_post_with_disb_return_amt,
      x_post_with_disb_return_date,
      x_post_with_disb_return_code,
      x_prev_with_disb_return_amt,
      x_prev_with_disb_return_date,
      x_school_use_txt,
      x_lender_use_txt,
      x_guarantor_use_txt,
      x_validation_edit_txt,
      x_send_record_txt,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 13-OCT-2004
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

    DELETE FROM igf_sl_clchsn_dtls
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_clchsn_dtls_pkg;

/
