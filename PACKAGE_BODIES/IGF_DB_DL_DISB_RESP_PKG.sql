--------------------------------------------------------
--  DDL for Package Body IGF_DB_DL_DISB_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_DB_DL_DISB_RESP_PKG" AS
/* $Header: IGFDI03B.pls 115.8 2002/11/28 14:14:20 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_db_dl_disb_resp_all%ROWTYPE;
  new_references igf_db_dl_disb_resp_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ddrp_id                           IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_user_ident                        IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_school_id                         IN     VARCHAR2,
    x_sch_code_status                   IN     VARCHAR2,
    x_loan_num_status                   IN     VARCHAR2,
    x_disb_num_status                   IN     VARCHAR2,
    x_disb_activity_status              IN     VARCHAR2,
    x_trans_date_status                 IN     VARCHAR2,
    x_disb_seq_num_status               IN     VARCHAR2,
    x_loc_disb_gross_amt                IN     NUMBER,
    x_loc_fee_1                         IN     NUMBER,
    x_loc_disb_net_amt                  IN     NUMBER,
    x_servicer_refund_amt               IN     NUMBER,
    x_loc_int_rebate_amt                IN     NUMBER,
    x_loc_net_booked_loan               IN     NUMBER,
    x_ack_date                          IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 18-JAN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_db_dl_disb_resp_all
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
    new_references.ddrp_id                           := x_ddrp_id;
    new_references.dbth_id                           := x_dbth_id;
    new_references.loan_number                       := x_loan_number;
    new_references.disb_num                          := x_disb_num;
    new_references.disb_activity                     := x_disb_activity;
    new_references.transaction_date                  := x_transaction_date;
    new_references.disb_seq_num                      := x_disb_seq_num;
    new_references.disb_gross_amt                    := x_disb_gross_amt;
    new_references.fee_1                             := x_fee_1;
    new_references.disb_net_amt                      := x_disb_net_amt;
    new_references.int_rebate_amt                    := x_int_rebate_amt;
    new_references.user_ident                        := x_user_ident;
    new_references.disb_batch_id                     := x_disb_batch_id;
    new_references.school_id                         := x_school_id;
    new_references.sch_code_status                   := x_sch_code_status;
    new_references.loan_num_status                   := x_loan_num_status;
    new_references.disb_num_status                   := x_disb_num_status;
    new_references.disb_activity_status              := x_disb_activity_status;
    new_references.trans_date_status                 := x_trans_date_status;
    new_references.disb_seq_num_status               := x_disb_seq_num_status;
    new_references.loc_disb_gross_amt                := x_loc_disb_gross_amt;
    new_references.loc_fee_1                         := x_loc_fee_1;
    new_references.loc_disb_net_amt                  := x_loc_disb_net_amt;
    new_references.servicer_refund_amt               := x_servicer_refund_amt;
    new_references.loc_int_rebate_amt                := x_loc_int_rebate_amt;
    new_references.loc_net_booked_loan               := x_loc_net_booked_loan;
    new_references.ack_date                          := x_ack_date;
    new_references.affirm_flag                       := x_affirm_flag;
    new_references.status                            := x_status;

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
  ||  Created By : venagara
  ||  Created On : 18-JAN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.dbth_id = new_references.dbth_id)) OR
        ((new_references.dbth_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sl_dl_batch_pkg.get_pk_for_validation (
                new_references.dbth_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_ddrp_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 18-JAN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_db_dl_disb_resp_all
      WHERE    ddrp_id = x_ddrp_id
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


  PROCEDURE get_fk_igf_sl_dl_batch (
    x_dbth_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 18-JAN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_db_dl_disb_resp_all
      WHERE   ((dbth_id = x_dbth_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_DB_DDRP_DBTH_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sl_dl_batch;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ddrp_id                           IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_user_ident                        IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_school_id                         IN     VARCHAR2,
    x_sch_code_status                   IN     VARCHAR2,
    x_loan_num_status                   IN     VARCHAR2,
    x_disb_num_status                   IN     VARCHAR2,
    x_disb_activity_status              IN     VARCHAR2,
    x_trans_date_status                 IN     VARCHAR2,
    x_disb_seq_num_status               IN     VARCHAR2,
    x_loc_disb_gross_amt                IN     NUMBER,
    x_loc_fee_1                         IN     NUMBER,
    x_loc_disb_net_amt                  IN     NUMBER,
    x_servicer_refund_amt               IN     NUMBER,
    x_loc_int_rebate_amt                IN     NUMBER,
    x_loc_net_booked_loan               IN     NUMBER,
    x_ack_date                          IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 18-JAN-2001
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
      x_ddrp_id,
      x_dbth_id,
      x_loan_number,
      x_disb_num,
      x_disb_activity,
      x_transaction_date,
      x_disb_seq_num,
      x_disb_gross_amt,
      x_fee_1,
      x_disb_net_amt,
      x_int_rebate_amt,
      x_user_ident,
      x_disb_batch_id,
      x_school_id,
      x_sch_code_status,
      x_loan_num_status,
      x_disb_num_status,
      x_disb_activity_status,
      x_trans_date_status,
      x_disb_seq_num_status,
      x_loc_disb_gross_amt,
      x_loc_fee_1,
      x_loc_disb_net_amt,
      x_servicer_refund_amt,
      x_loc_int_rebate_amt,
      x_loc_net_booked_loan,
      x_ack_date,
      x_affirm_flag,
      x_status,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ddrp_id
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
             new_references.ddrp_id
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
    x_ddrp_id                           IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_user_ident                        IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_school_id                         IN     VARCHAR2,
    x_sch_code_status                   IN     VARCHAR2,
    x_loan_num_status                   IN     VARCHAR2,
    x_disb_num_status                   IN     VARCHAR2,
    x_disb_activity_status              IN     VARCHAR2,
    x_trans_date_status                 IN     VARCHAR2,
    x_disb_seq_num_status               IN     VARCHAR2,
    x_loc_disb_gross_amt                IN     NUMBER,
    x_loc_fee_1                         IN     NUMBER,
    x_loc_disb_net_amt                  IN     NUMBER,
    x_servicer_refund_amt               IN     NUMBER,
    x_loc_int_rebate_amt                IN     NUMBER,
    x_loc_net_booked_loan               IN     NUMBER,
    x_ack_date                          IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 18-JAN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_db_dl_disb_resp_all
      WHERE    ddrp_id                           = x_ddrp_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                     igf_db_dl_disb_resp_all.org_id%TYPE DEFAULT igf_aw_gen.get_org_id;

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

    SELECT igf_db_dl_disb_resp_s.NEXTVAL INTO x_ddrp_id FROM dual;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_ddrp_id                           => x_ddrp_id,
      x_dbth_id                           => x_dbth_id,
      x_loan_number                       => x_loan_number,
      x_disb_num                          => x_disb_num,
      x_disb_activity                     => x_disb_activity,
      x_transaction_date                  => x_transaction_date,
      x_disb_seq_num                      => x_disb_seq_num,
      x_disb_gross_amt                    => x_disb_gross_amt,
      x_fee_1                             => x_fee_1,
      x_disb_net_amt                      => x_disb_net_amt,
      x_int_rebate_amt                    => x_int_rebate_amt,
      x_user_ident                        => x_user_ident,
      x_disb_batch_id                     => x_disb_batch_id,
      x_school_id                         => x_school_id,
      x_sch_code_status                   => x_sch_code_status,
      x_loan_num_status                   => x_loan_num_status,
      x_disb_num_status                   => x_disb_num_status,
      x_disb_activity_status              => x_disb_activity_status,
      x_trans_date_status                 => x_trans_date_status,
      x_disb_seq_num_status               => x_disb_seq_num_status,
      x_loc_disb_gross_amt                => x_loc_disb_gross_amt,
      x_loc_fee_1                         => x_loc_fee_1,
      x_loc_disb_net_amt                  => x_loc_disb_net_amt,
      x_servicer_refund_amt               => x_servicer_refund_amt,
      x_loc_int_rebate_amt                => x_loc_int_rebate_amt,
      x_loc_net_booked_loan               => x_loc_net_booked_loan,
      x_ack_date                          => x_ack_date,
      x_affirm_flag                       => x_affirm_flag,
      x_status                            => x_status,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_db_dl_disb_resp_all (
      ddrp_id,
      dbth_id,
      loan_number,
      disb_num,
      disb_activity,
      transaction_date,
      disb_seq_num,
      disb_gross_amt,
      fee_1,
      disb_net_amt,
      int_rebate_amt,
      user_ident,
      disb_batch_id,
      school_id,
      sch_code_status,
      loan_num_status,
      disb_num_status,
      disb_activity_status,
      trans_date_status,
      disb_seq_num_status,
      loc_disb_gross_amt,
      loc_fee_1,
      loc_disb_net_amt,
      servicer_refund_amt,
      loc_int_rebate_amt,
      loc_net_booked_loan,
      ack_date,
      affirm_flag,
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
      org_id
    ) VALUES (
      new_references.ddrp_id,
      new_references.dbth_id,
      new_references.loan_number,
      new_references.disb_num,
      new_references.disb_activity,
      new_references.transaction_date,
      new_references.disb_seq_num,
      new_references.disb_gross_amt,
      new_references.fee_1,
      new_references.disb_net_amt,
      new_references.int_rebate_amt,
      new_references.user_ident,
      new_references.disb_batch_id,
      new_references.school_id,
      new_references.sch_code_status,
      new_references.loan_num_status,
      new_references.disb_num_status,
      new_references.disb_activity_status,
      new_references.trans_date_status,
      new_references.disb_seq_num_status,
      new_references.loc_disb_gross_amt,
      new_references.loc_fee_1,
      new_references.loc_disb_net_amt,
      new_references.servicer_refund_amt,
      new_references.loc_int_rebate_amt,
      new_references.loc_net_booked_loan,
      new_references.ack_date,
      new_references.affirm_flag,
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
      l_org_id
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
    x_ddrp_id                           IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_user_ident                        IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_school_id                         IN     VARCHAR2,
    x_sch_code_status                   IN     VARCHAR2,
    x_loan_num_status                   IN     VARCHAR2,
    x_disb_num_status                   IN     VARCHAR2,
    x_disb_activity_status              IN     VARCHAR2,
    x_trans_date_status                 IN     VARCHAR2,
    x_disb_seq_num_status               IN     VARCHAR2,
    x_loc_disb_gross_amt                IN     NUMBER,
    x_loc_fee_1                         IN     NUMBER,
    x_loc_disb_net_amt                  IN     NUMBER,
    x_servicer_refund_amt               IN     NUMBER,
    x_loc_int_rebate_amt                IN     NUMBER,
    x_loc_net_booked_loan               IN     NUMBER,
    x_ack_date                          IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_status                            IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 18-JAN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        dbth_id,
        loan_number,
        disb_num,
        disb_activity,
        transaction_date,
        disb_seq_num,
        disb_gross_amt,
        fee_1,
        disb_net_amt,
        int_rebate_amt,
        user_ident,
        disb_batch_id,
        school_id,
        sch_code_status,
        loan_num_status,
        disb_num_status,
        disb_activity_status,
        trans_date_status,
        disb_seq_num_status,
        loc_disb_gross_amt,
        loc_fee_1,
        loc_disb_net_amt,
        servicer_refund_amt,
        loc_int_rebate_amt,
        loc_net_booked_loan,
        ack_date,
        affirm_flag,
        status,
        org_id
      FROM  igf_db_dl_disb_resp_all
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
        (tlinfo.dbth_id = x_dbth_id)
        AND (tlinfo.loan_number = x_loan_number)
        AND (tlinfo.disb_num = x_disb_num)
        AND ((tlinfo.disb_activity = x_disb_activity) OR ((tlinfo.disb_activity IS NULL) AND (X_disb_activity IS NULL)))
        AND ((tlinfo.transaction_date = x_transaction_date) OR ((tlinfo.transaction_date IS NULL) AND (X_transaction_date IS NULL)))
        AND ((tlinfo.disb_seq_num = x_disb_seq_num) OR ((tlinfo.disb_seq_num IS NULL) AND (X_disb_seq_num IS NULL)))
        AND ((tlinfo.disb_gross_amt = x_disb_gross_amt) OR ((tlinfo.disb_gross_amt IS NULL) AND (X_disb_gross_amt IS NULL)))
        AND ((tlinfo.fee_1 = x_fee_1) OR ((tlinfo.fee_1 IS NULL) AND (X_fee_1 IS NULL)))
        AND ((tlinfo.disb_net_amt = x_disb_net_amt) OR ((tlinfo.disb_net_amt IS NULL) AND (X_disb_net_amt IS NULL)))
        AND ((tlinfo.int_rebate_amt = x_int_rebate_amt) OR ((tlinfo.int_rebate_amt IS NULL) AND (X_int_rebate_amt IS NULL)))
        AND ((tlinfo.user_ident = x_user_ident) OR ((tlinfo.user_ident IS NULL) AND (X_user_ident IS NULL)))
        AND ((tlinfo.disb_batch_id = x_disb_batch_id) OR ((tlinfo.disb_batch_id IS NULL) AND (X_disb_batch_id IS NULL)))
        AND ((tlinfo.school_id = x_school_id) OR ((tlinfo.school_id IS NULL) AND (X_school_id IS NULL)))
        AND ((tlinfo.sch_code_status = x_sch_code_status) OR ((tlinfo.sch_code_status IS NULL) AND (X_sch_code_status IS NULL)))
        AND ((tlinfo.loan_num_status = x_loan_num_status) OR ((tlinfo.loan_num_status IS NULL) AND (X_loan_num_status IS NULL)))
        AND ((tlinfo.disb_num_status = x_disb_num_status) OR ((tlinfo.disb_num_status IS NULL) AND (X_disb_num_status IS NULL)))
        AND ((tlinfo.disb_activity_status = x_disb_activity_status) OR ((tlinfo.disb_activity_status IS NULL) AND (X_disb_activity_status IS NULL)))
        AND ((tlinfo.trans_date_status = x_trans_date_status) OR ((tlinfo.trans_date_status IS NULL) AND (X_trans_date_status IS NULL)))
        AND ((tlinfo.disb_seq_num_status = x_disb_seq_num_status) OR ((tlinfo.disb_seq_num_status IS NULL) AND (X_disb_seq_num_status IS NULL)))
        AND ((tlinfo.loc_disb_gross_amt = x_loc_disb_gross_amt) OR ((tlinfo.loc_disb_gross_amt IS NULL) AND (X_loc_disb_gross_amt IS NULL)))
        AND ((tlinfo.loc_fee_1 = x_loc_fee_1) OR ((tlinfo.loc_fee_1 IS NULL) AND (X_loc_fee_1 IS NULL)))
        AND ((tlinfo.loc_disb_net_amt = x_loc_disb_net_amt) OR ((tlinfo.loc_disb_net_amt IS NULL) AND (X_loc_disb_net_amt IS NULL)))
        AND ((tlinfo.servicer_refund_amt = x_servicer_refund_amt) OR ((tlinfo.servicer_refund_amt IS NULL) AND (X_servicer_refund_amt IS NULL)))
        AND ((tlinfo.loc_int_rebate_amt = x_loc_int_rebate_amt) OR ((tlinfo.loc_int_rebate_amt IS NULL) AND (X_loc_int_rebate_amt IS NULL)))
        AND ((tlinfo.loc_net_booked_loan = x_loc_net_booked_loan) OR ((tlinfo.loc_net_booked_loan IS NULL) AND (X_loc_net_booked_loan IS NULL)))
        AND ((tlinfo.ack_date = x_ack_date) OR ((tlinfo.ack_date IS NULL) AND (X_ack_date IS NULL)))
        AND ((tlinfo.affirm_flag = x_affirm_flag) OR ((tlinfo.affirm_flag IS NULL) AND (X_affirm_flag IS NULL)))
        AND (tlinfo.status = x_status)
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
    x_ddrp_id                           IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_user_ident                        IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_school_id                         IN     VARCHAR2,
    x_sch_code_status                   IN     VARCHAR2,
    x_loan_num_status                   IN     VARCHAR2,
    x_disb_num_status                   IN     VARCHAR2,
    x_disb_activity_status              IN     VARCHAR2,
    x_trans_date_status                 IN     VARCHAR2,
    x_disb_seq_num_status               IN     VARCHAR2,
    x_loc_disb_gross_amt                IN     NUMBER,
    x_loc_fee_1                         IN     NUMBER,
    x_loc_disb_net_amt                  IN     NUMBER,
    x_servicer_refund_amt               IN     NUMBER,
    x_loc_int_rebate_amt                IN     NUMBER,
    x_loc_net_booked_loan               IN     NUMBER,
    x_ack_date                          IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 18-JAN-2001
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
      x_ddrp_id                           => x_ddrp_id,
      x_dbth_id                           => x_dbth_id,
      x_loan_number                       => x_loan_number,
      x_disb_num                          => x_disb_num,
      x_disb_activity                     => x_disb_activity,
      x_transaction_date                  => x_transaction_date,
      x_disb_seq_num                      => x_disb_seq_num,
      x_disb_gross_amt                    => x_disb_gross_amt,
      x_fee_1                             => x_fee_1,
      x_disb_net_amt                      => x_disb_net_amt,
      x_int_rebate_amt                    => x_int_rebate_amt,
      x_user_ident                        => x_user_ident,
      x_disb_batch_id                     => x_disb_batch_id,
      x_school_id                         => x_school_id,
      x_sch_code_status                   => x_sch_code_status,
      x_loan_num_status                   => x_loan_num_status,
      x_disb_num_status                   => x_disb_num_status,
      x_disb_activity_status              => x_disb_activity_status,
      x_trans_date_status                 => x_trans_date_status,
      x_disb_seq_num_status               => x_disb_seq_num_status,
      x_loc_disb_gross_amt                => x_loc_disb_gross_amt,
      x_loc_fee_1                         => x_loc_fee_1,
      x_loc_disb_net_amt                  => x_loc_disb_net_amt,
      x_servicer_refund_amt               => x_servicer_refund_amt,
      x_loc_int_rebate_amt                => x_loc_int_rebate_amt,
      x_loc_net_booked_loan               => x_loc_net_booked_loan,
      x_ack_date                          => x_ack_date,
      x_affirm_flag                       => x_affirm_flag,
      x_status                            => x_status,
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

    UPDATE igf_db_dl_disb_resp_all
      SET
        dbth_id                           = new_references.dbth_id,
        loan_number                       = new_references.loan_number,
        disb_num                          = new_references.disb_num,
        disb_activity                     = new_references.disb_activity,
        transaction_date                  = new_references.transaction_date,
        disb_seq_num                      = new_references.disb_seq_num,
        disb_gross_amt                    = new_references.disb_gross_amt,
        fee_1                             = new_references.fee_1,
        disb_net_amt                      = new_references.disb_net_amt,
        int_rebate_amt                    = new_references.int_rebate_amt,
        user_ident                        = new_references.user_ident,
        disb_batch_id                     = new_references.disb_batch_id,
        school_id                         = new_references.school_id,
        sch_code_status                   = new_references.sch_code_status,
        loan_num_status                   = new_references.loan_num_status,
        disb_num_status                   = new_references.disb_num_status,
        disb_activity_status              = new_references.disb_activity_status,
        trans_date_status                 = new_references.trans_date_status,
        disb_seq_num_status               = new_references.disb_seq_num_status,
        loc_disb_gross_amt                = new_references.loc_disb_gross_amt,
        loc_fee_1                         = new_references.loc_fee_1,
        loc_disb_net_amt                  = new_references.loc_disb_net_amt,
        servicer_refund_amt               = new_references.servicer_refund_amt,
        loc_int_rebate_amt                = new_references.loc_int_rebate_amt,
        loc_net_booked_loan               = new_references.loc_net_booked_loan,
        ack_date                          = new_references.ack_date,
        affirm_flag                       = new_references.affirm_flag,
        status                            = new_references.status,
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

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ddrp_id                           IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_disb_num                          IN     NUMBER,
    x_disb_activity                     IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_disb_seq_num                      IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_user_ident                        IN     VARCHAR2,
    x_disb_batch_id                     IN     VARCHAR2,
    x_school_id                         IN     VARCHAR2,
    x_sch_code_status                   IN     VARCHAR2,
    x_loan_num_status                   IN     VARCHAR2,
    x_disb_num_status                   IN     VARCHAR2,
    x_disb_activity_status              IN     VARCHAR2,
    x_trans_date_status                 IN     VARCHAR2,
    x_disb_seq_num_status               IN     VARCHAR2,
    x_loc_disb_gross_amt                IN     NUMBER,
    x_loc_fee_1                         IN     NUMBER,
    x_loc_disb_net_amt                  IN     NUMBER,
    x_servicer_refund_amt               IN     NUMBER,
    x_loc_int_rebate_amt                IN     NUMBER,
    x_loc_net_booked_loan               IN     NUMBER,
    x_ack_date                          IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 18-JAN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_db_dl_disb_resp_all
      WHERE    ddrp_id                           = x_ddrp_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ddrp_id,
        x_dbth_id,
        x_loan_number,
        x_disb_num,
        x_disb_activity,
        x_transaction_date,
        x_disb_seq_num,
        x_disb_gross_amt,
        x_fee_1,
        x_disb_net_amt,
        x_int_rebate_amt,
        x_user_ident,
        x_disb_batch_id,
        x_school_id,
        x_sch_code_status,
        x_loan_num_status,
        x_disb_num_status,
        x_disb_activity_status,
        x_trans_date_status,
        x_disb_seq_num_status,
        x_loc_disb_gross_amt,
        x_loc_fee_1,
        x_loc_disb_net_amt,
        x_servicer_refund_amt,
        x_loc_int_rebate_amt,
        x_loc_net_booked_loan,
        x_ack_date,
        x_affirm_flag,
        x_status,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ddrp_id,
      x_dbth_id,
      x_loan_number,
      x_disb_num,
      x_disb_activity,
      x_transaction_date,
      x_disb_seq_num,
      x_disb_gross_amt,
      x_fee_1,
      x_disb_net_amt,
      x_int_rebate_amt,
      x_user_ident,
      x_disb_batch_id,
      x_school_id,
      x_sch_code_status,
      x_loan_num_status,
      x_disb_num_status,
      x_disb_activity_status,
      x_trans_date_status,
      x_disb_seq_num_status,
      x_loc_disb_gross_amt,
      x_loc_fee_1,
      x_loc_disb_net_amt,
      x_servicer_refund_amt,
      x_loc_int_rebate_amt,
      x_loc_net_booked_loan,
      x_ack_date,
      x_affirm_flag,
      x_status,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 18-JAN-2001
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

    DELETE FROM igf_db_dl_disb_resp_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_db_dl_disb_resp_pkg;

/
