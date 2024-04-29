--------------------------------------------------------
--  DDL for Package Body IGF_GR_RFMS_DISB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_GR_RFMS_DISB_PKG" AS
/* $Header: IGFGI06B.pls 115.13 2002/11/28 14:16:27 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igf_gr_rfms_disb_all%ROWTYPE;
  new_references igf_gr_rfms_disb_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_rfmd_id                           IN     NUMBER  ,
    x_origination_id                    IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_dt                           IN     DATE    ,
    x_disb_amt                          IN     NUMBER  ,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_ack_act_status               IN     VARCHAR2,
    x_disb_status_dt                    IN     DATE    ,
    x_accpt_disb_dt                     IN     DATE    ,
    x_disb_accpt_amt                    IN     NUMBER  ,
    x_accpt_db_cr_flag                  IN     VARCHAR2,
    x_disb_ytd_amt                      IN     NUMBER  ,
    x_pymt_prd_start_dt                 IN     DATE    ,
    x_accpt_pymt_prd_start_dt           IN     DATE    ,
    x_edit_code                         IN     VARCHAR2,
    x_rfmb_id                           IN     NUMBER  ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_ed_use_flags                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JAN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_GR_RFMS_DISB_ALL
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
    new_references.rfmd_id                           := x_rfmd_id;
    new_references.origination_id                    := x_origination_id;
    new_references.disb_ref_num                      := x_disb_ref_num;
    new_references.disb_dt                           := x_disb_dt;
    new_references.disb_amt                          := x_disb_amt;
    new_references.db_cr_flag                        := x_db_cr_flag;
    new_references.disb_ack_act_status               := x_disb_ack_act_status;
    new_references.disb_status_dt                    := x_disb_status_dt;
    new_references.accpt_disb_dt                     := x_accpt_disb_dt;
    new_references.disb_accpt_amt                    := x_disb_accpt_amt;
    new_references.accpt_db_cr_flag                  := x_accpt_db_cr_flag;
    new_references.disb_ytd_amt                      := x_disb_ytd_amt;
    new_references.pymt_prd_start_dt                 := x_pymt_prd_start_dt;
    new_references.accpt_pymt_prd_start_dt           := x_accpt_pymt_prd_start_dt;
    new_references.edit_code                         := x_edit_code;
    new_references.rfmb_id                           := x_rfmb_id;

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
    new_references.ed_use_flags                      := x_ed_use_flags;

  END set_column_values;


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JAN-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.disb_ref_num,
           new_references.origination_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JAN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.rfmb_id = new_references.rfmb_id)) OR
        ((new_references.rfmb_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_gr_rfms_batch_pkg.get_pk_for_validation (
                new_references.rfmb_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.origination_id = new_references.origination_id)) OR
        ((new_references.origination_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_gr_rfms_pkg.get_pk_for_validation (
                new_references.origination_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_rfmd_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JAN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_rfms_disb_all
      WHERE    rfmd_id = x_rfmd_id
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


  FUNCTION get_uk_for_validation (
    x_disb_ref_num                      IN     VARCHAR2,
    x_origination_id                    IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JAN-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_rfms_disb_all
      WHERE    disb_ref_num = x_disb_ref_num
      AND      origination_id = x_origination_id
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


  PROCEDURE get_fk_igf_gr_rfms_batch (
    x_rfmb_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JAN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_rfms_disb_all
      WHERE   ((rfmb_id = x_rfmb_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_GR_RFMD_RFMB_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_gr_rfms_batch;


  PROCEDURE get_fk_igf_gr_rfms (
    x_origination_id                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JAN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_gr_rfms_disb_all
      WHERE   ((origination_id = x_origination_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_GR_RFMD_RFMS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_gr_rfms;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_rfmd_id                           IN     NUMBER  ,
    x_origination_id                    IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_dt                           IN     DATE    ,
    x_disb_amt                          IN     NUMBER  ,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_ack_act_status               IN     VARCHAR2,
    x_disb_status_dt                    IN     DATE    ,
    x_accpt_disb_dt                     IN     DATE    ,
    x_disb_accpt_amt                    IN     NUMBER  ,
    x_accpt_db_cr_flag                  IN     VARCHAR2,
    x_disb_ytd_amt                      IN     NUMBER  ,
    x_pymt_prd_start_dt                 IN     DATE    ,
    x_accpt_pymt_prd_start_dt           IN     DATE    ,
    x_edit_code                         IN     VARCHAR2,
    x_rfmb_id                           IN     NUMBER  ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_ed_use_flags                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JAN-2001
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
      x_rfmd_id,
      x_origination_id,
      x_disb_ref_num,
      x_disb_dt,
      x_disb_amt,
      x_db_cr_flag,
      x_disb_ack_act_status,
      x_disb_status_dt,
      x_accpt_disb_dt,
      x_disb_accpt_amt,
      x_accpt_db_cr_flag,
      x_disb_ytd_amt,
      x_pymt_prd_start_dt,
      x_accpt_pymt_prd_start_dt,
      x_edit_code,
      x_rfmb_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_ed_use_flags
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.rfmd_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.rfmd_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rfmd_id                           IN OUT NOCOPY NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_disb_amt                          IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_ack_act_status               IN     VARCHAR2,
    x_disb_status_dt                    IN     DATE,
    x_accpt_disb_dt                     IN     DATE,
    x_disb_accpt_amt                    IN     NUMBER,
    x_accpt_db_cr_flag                  IN     VARCHAR2,
    x_disb_ytd_amt                      IN     NUMBER,
    x_pymt_prd_start_dt                 IN     DATE,
    x_accpt_pymt_prd_start_dt           IN     DATE,
    x_edit_code                         IN     VARCHAR2,
    x_rfmb_id                           IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_ed_use_flags                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JAN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_gr_rfms_disb_all
      WHERE    rfmd_id                           = x_rfmd_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id			 igf_gr_rfms_disb_all.org_id%TYPE;

  BEGIN

    l_org_id			 := igf_aw_gen.get_org_id;

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

		SELECT igf_gr_rfms_disb_s.nextval INTO x_rfmd_id FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_rfmd_id                           => x_rfmd_id,
      x_origination_id                    => x_origination_id,
      x_disb_ref_num                      => x_disb_ref_num,
      x_disb_dt                           => x_disb_dt,
      x_disb_amt                          => x_disb_amt,
      x_db_cr_flag                        => x_db_cr_flag,
      x_disb_ack_act_status               => x_disb_ack_act_status,
      x_disb_status_dt                    => x_disb_status_dt,
      x_accpt_disb_dt                     => x_accpt_disb_dt,
      x_disb_accpt_amt                    => x_disb_accpt_amt,
      x_accpt_db_cr_flag                  => x_accpt_db_cr_flag,
      x_disb_ytd_amt                      => x_disb_ytd_amt,
      x_pymt_prd_start_dt                 => x_pymt_prd_start_dt,
      x_accpt_pymt_prd_start_dt           => x_accpt_pymt_prd_start_dt,
      x_edit_code                         => x_edit_code,
      x_rfmb_id                           => x_rfmb_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_ed_use_flags                      => x_ed_use_flags

    );

    INSERT INTO igf_gr_rfms_disb_all (
      rfmd_id,
      origination_id,
      disb_ref_num,
      disb_dt,
      disb_amt,
      db_cr_flag,
      disb_ack_act_status,
      disb_status_dt,
      accpt_disb_dt,
      disb_accpt_amt,
      accpt_db_cr_flag,
      disb_ytd_amt,
      pymt_prd_start_dt,
      accpt_pymt_prd_start_dt,
      edit_code,
      rfmb_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date ,
      org_id,
      ed_use_flags
    ) VALUES (
      new_references.rfmd_id,
      new_references.origination_id,
      new_references.disb_ref_num,
      new_references.disb_dt,
      new_references.disb_amt,
      new_references.db_cr_flag,
      new_references.disb_ack_act_status,
      new_references.disb_status_dt,
      new_references.accpt_disb_dt,
      new_references.disb_accpt_amt,
      new_references.accpt_db_cr_flag,
      new_references.disb_ytd_amt,
      new_references.pymt_prd_start_dt,
      new_references.accpt_pymt_prd_start_dt,
      new_references.edit_code,
      new_references.rfmb_id,
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
      new_references.ed_use_flags
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
    x_rfmd_id                           IN     NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_disb_amt                          IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_ack_act_status               IN     VARCHAR2,
    x_disb_status_dt                    IN     DATE,
    x_accpt_disb_dt                     IN     DATE,
    x_disb_accpt_amt                    IN     NUMBER,
    x_accpt_db_cr_flag                  IN     VARCHAR2,
    x_disb_ytd_amt                      IN     NUMBER,
    x_pymt_prd_start_dt                 IN     DATE,
    x_accpt_pymt_prd_start_dt           IN     DATE,
    x_edit_code                         IN     VARCHAR2,
    x_rfmb_id                           IN     NUMBER,
    x_ed_use_flags                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JAN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        origination_id,
        disb_ref_num,
        disb_dt,
        disb_amt,
        db_cr_flag,
        disb_ack_act_status,
        disb_status_dt,
        accpt_disb_dt,
        disb_accpt_amt,
        accpt_db_cr_flag,
        disb_ytd_amt,
        pymt_prd_start_dt,
        accpt_pymt_prd_start_dt,
        edit_code,
        rfmb_id,
        ed_use_flags
      FROM  igf_gr_rfms_disb_all
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
        (tlinfo.origination_id = x_origination_id)
        AND (tlinfo.disb_ref_num = x_disb_ref_num)
        AND ((tlinfo.disb_dt = x_disb_dt) OR ((tlinfo.disb_dt IS NULL) AND (X_disb_dt IS NULL)))
        AND (tlinfo.disb_amt = x_disb_amt)
        AND (tlinfo.db_cr_flag = x_db_cr_flag)
        AND ((tlinfo.disb_ack_act_status = x_disb_ack_act_status) OR ((tlinfo.disb_ack_act_status IS NULL) AND (X_disb_ack_act_status IS NULL)))
        AND ((tlinfo.disb_status_dt = x_disb_status_dt) OR ((tlinfo.disb_status_dt IS NULL) AND (X_disb_status_dt IS NULL)))
        AND ((tlinfo.accpt_disb_dt = x_accpt_disb_dt) OR ((tlinfo.accpt_disb_dt IS NULL) AND (X_accpt_disb_dt IS NULL)))
        AND ((tlinfo.disb_accpt_amt = x_disb_accpt_amt) OR ((tlinfo.disb_accpt_amt IS NULL) AND (X_disb_accpt_amt IS NULL)))
        AND ((tlinfo.accpt_db_cr_flag = x_accpt_db_cr_flag) OR ((tlinfo.accpt_db_cr_flag IS NULL) AND (X_accpt_db_cr_flag IS NULL)))
        AND ((tlinfo.disb_ytd_amt = x_disb_ytd_amt) OR ((tlinfo.disb_ytd_amt IS NULL) AND (X_disb_ytd_amt IS NULL)))
        AND ((tlinfo.pymt_prd_start_dt = x_pymt_prd_start_dt) OR ((tlinfo.pymt_prd_start_dt IS NULL) AND (X_pymt_prd_start_dt IS NULL)))
        AND ((tlinfo.accpt_pymt_prd_start_dt = x_accpt_pymt_prd_start_dt) OR ((tlinfo.accpt_pymt_prd_start_dt IS NULL) AND (X_accpt_pymt_prd_start_dt IS NULL)))
        AND ((tlinfo.edit_code = x_edit_code) OR ((tlinfo.edit_code IS NULL) AND (X_edit_code IS NULL)))
        AND ((tlinfo.rfmb_id = x_rfmb_id) OR ((tlinfo.rfmb_id IS NULL) AND (X_rfmb_id IS NULL)))
        AND ((tlinfo.ed_use_flags = x_ed_use_flags) OR ((tlinfo.ed_use_flags IS NULL) AND (X_ed_use_flags IS NULL)))
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
    x_rfmd_id                           IN     NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_disb_amt                          IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_ack_act_status               IN     VARCHAR2,
    x_disb_status_dt                    IN     DATE,
    x_accpt_disb_dt                     IN     DATE,
    x_disb_accpt_amt                    IN     NUMBER,
    x_accpt_db_cr_flag                  IN     VARCHAR2,
    x_disb_ytd_amt                      IN     NUMBER,
    x_pymt_prd_start_dt                 IN     DATE,
    x_accpt_pymt_prd_start_dt           IN     DATE,
    x_edit_code                         IN     VARCHAR2,
    x_rfmb_id                           IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_ed_use_flags                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JAN-2001
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
      x_rfmd_id                           => x_rfmd_id,
      x_origination_id                    => x_origination_id,
      x_disb_ref_num                      => x_disb_ref_num,
      x_disb_dt                           => x_disb_dt,
      x_disb_amt                          => x_disb_amt,
      x_db_cr_flag                        => x_db_cr_flag,
      x_disb_ack_act_status               => x_disb_ack_act_status,
      x_disb_status_dt                    => x_disb_status_dt,
      x_accpt_disb_dt                     => x_accpt_disb_dt,
      x_disb_accpt_amt                    => x_disb_accpt_amt,
      x_accpt_db_cr_flag                  => x_accpt_db_cr_flag,
      x_disb_ytd_amt                      => x_disb_ytd_amt,
      x_pymt_prd_start_dt                 => x_pymt_prd_start_dt,
      x_accpt_pymt_prd_start_dt           => x_accpt_pymt_prd_start_dt,
      x_edit_code                         => x_edit_code,
      x_rfmb_id                           => x_rfmb_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_ed_use_flags                      => x_ed_use_flags
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

    UPDATE igf_gr_rfms_disb_all
      SET
        origination_id                    = new_references.origination_id,
        disb_ref_num                      = new_references.disb_ref_num,
        disb_dt                           = new_references.disb_dt,
        disb_amt                          = new_references.disb_amt,
        db_cr_flag                        = new_references.db_cr_flag,
        disb_ack_act_status               = new_references.disb_ack_act_status,
        disb_status_dt                    = new_references.disb_status_dt,
        accpt_disb_dt                     = new_references.accpt_disb_dt,
        disb_accpt_amt                    = new_references.disb_accpt_amt,
        accpt_db_cr_flag                  = new_references.accpt_db_cr_flag,
        disb_ytd_amt                      = new_references.disb_ytd_amt,
        pymt_prd_start_dt                 = new_references.pymt_prd_start_dt,
        accpt_pymt_prd_start_dt           = new_references.accpt_pymt_prd_start_dt,
        edit_code                         = new_references.edit_code,
        rfmb_id                           = new_references.rfmb_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        ed_use_flags                      = new_references.ed_use_flags
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rfmd_id                           IN OUT NOCOPY NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_disb_amt                          IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_ack_act_status               IN     VARCHAR2,
    x_disb_status_dt                    IN     DATE,
    x_accpt_disb_dt                     IN     DATE,
    x_disb_accpt_amt                    IN     NUMBER,
    x_accpt_db_cr_flag                  IN     VARCHAR2,
    x_disb_ytd_amt                      IN     NUMBER,
    x_pymt_prd_start_dt                 IN     DATE,
    x_accpt_pymt_prd_start_dt           IN     DATE,
    x_edit_code                         IN     VARCHAR2,
    x_rfmb_id                           IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_ed_use_flags                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JAN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_gr_rfms_disb_all
      WHERE    rfmd_id                           = x_rfmd_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_rfmd_id,
        x_origination_id,
        x_disb_ref_num,
        x_disb_dt,
        x_disb_amt,
        x_db_cr_flag,
        x_disb_ack_act_status,
        x_disb_status_dt,
        x_accpt_disb_dt,
        x_disb_accpt_amt,
        x_accpt_db_cr_flag,
        x_disb_ytd_amt,
        x_pymt_prd_start_dt,
        x_accpt_pymt_prd_start_dt,
        x_edit_code,
        x_rfmb_id,
        x_mode,
        x_ed_use_flags
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_rfmd_id,
      x_origination_id,
      x_disb_ref_num,
      x_disb_dt,
      x_disb_amt,
      x_db_cr_flag,
      x_disb_ack_act_status,
      x_disb_status_dt,
      x_accpt_disb_dt,
      x_disb_accpt_amt,
      x_accpt_db_cr_flag,
      x_disb_ytd_amt,
      x_pymt_prd_start_dt,
      x_accpt_pymt_prd_start_dt,
      x_edit_code,
      x_rfmb_id,
      x_mode,
      x_ed_use_flags
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 12-JAN-2001
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

    DELETE FROM igf_gr_rfms_disb_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_gr_rfms_disb_pkg;

/
