--------------------------------------------------------
--  DDL for Package Body IGS_HE_EXT_RUN_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_EXT_RUN_DTLS_PKG" AS
/* $Header: IGSWI06B.pls 115.9 2002/12/20 08:46:30 bayadav noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_ext_run_dtls%ROWTYPE;
  new_references igs_he_ext_run_dtls%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_extract_run_id                    IN     NUMBER       ,
    x_submission_name                   IN     VARCHAR2     ,
    x_user_return_subclass              IN     VARCHAR2     ,
    x_return_name                       IN     VARCHAR2     ,
    x_extract_phase                     IN     VARCHAR2     ,
    x_conc_request_id                   IN     NUMBER       ,
    x_conc_request_status               IN     VARCHAR2     ,
    x_extract_run_date                  IN     DATE         ,
    x_file_name                         IN     VARCHAR2     ,
    x_file_location                     IN     VARCHAR2     ,
    x_date_file_sent                    IN     DATE         ,
    x_extract_override                  IN     VARCHAR2     ,
    x_validation_kit_result             IN     VARCHAR2     ,
    x_hesa_validation_result            IN     VARCHAR2     ,
    x_student_ext_run_id                IN     VARCHAR2     ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-JAN-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_EXT_RUN_DTLS
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
    new_references.extract_run_id                    := x_extract_run_id;
    new_references.submission_name                   := x_submission_name;
    new_references.user_return_subclass              := x_user_return_subclass;
    new_references.return_name                       := x_return_name;
    new_references.extract_phase                     := x_extract_phase;
    new_references.conc_request_id                   := x_conc_request_id;
    new_references.conc_request_status               := x_conc_request_status;
    new_references.extract_run_date                  := x_extract_run_date;
    new_references.file_name                         := x_file_name;
    new_references.file_location                     := x_file_location;
    new_references.date_file_sent                    := x_date_file_sent;
    new_references.extract_override                  := x_extract_override;
    new_references.validation_kit_result             := x_validation_kit_result;
    new_references.hesa_validation_result            := x_hesa_validation_result;
    new_references.student_ext_run_id                := x_student_ext_run_id;

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
  ||  Created By : rgopalan
  ||  Created On : 23-JAN-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.submission_name = new_references.submission_name) AND
         (old_references.user_return_subclass = new_references.user_return_subclass) AND
         (old_references.return_name = new_references.return_name)) OR
        ((new_references.submission_name IS NULL) OR
         (new_references.user_return_subclass IS NULL) OR
         (new_references.return_name IS NULL))) THEN
      NULL;
    ELSIF NOT igs_he_submsn_return_pkg.get_pk_for_validation (
                new_references.submission_name,
                new_references.user_return_subclass,
                new_references.return_name
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-JAN-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_he_ext_run_prms_pkg.get_fk_igs_he_ext_run_dtls (
      old_references.extract_run_id
    );

    igs_he_ex_rn_dat_ln_pkg.get_fk_igs_he_ext_run_dtls (
      old_references.extract_run_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_extract_run_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-JAN-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_ext_run_dtls
      WHERE    extract_run_id = x_extract_run_id
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


  PROCEDURE get_fk_igs_he_submsn_return (
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-JAN-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_ext_run_dtls
      WHERE   ((return_name = x_return_name) AND
               (submission_name = x_submission_name) AND
               (user_return_subclass = x_user_return_subclass));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HEERDTL_HESBRET_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_he_submsn_return;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_extract_run_id                    IN     NUMBER       ,
    x_submission_name                   IN     VARCHAR2     ,
    x_user_return_subclass              IN     VARCHAR2     ,
    x_return_name                       IN     VARCHAR2     ,
    x_extract_phase                     IN     VARCHAR2     ,
    x_conc_request_id                   IN     NUMBER       ,
    x_conc_request_status               IN     VARCHAR2     ,
    x_extract_run_date                  IN     DATE         ,
    x_file_name                         IN     VARCHAR2     ,
    x_file_location                     IN     VARCHAR2     ,
    x_date_file_sent                    IN     DATE         ,
    x_extract_override                  IN     VARCHAR2     ,
    x_validation_kit_result             IN     VARCHAR2     ,
    x_hesa_validation_result            IN     VARCHAR2     ,
    x_student_ext_run_id                IN     VARCHAR2     ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-JAN-2002
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
      x_extract_run_id,
      x_submission_name,
      x_user_return_subclass,
      x_return_name,
      x_extract_phase,
      x_conc_request_id,
      x_conc_request_status,
      x_extract_run_date,
      x_file_name,
      x_file_location,
      x_date_file_sent,
      x_extract_override,
      x_validation_kit_result,
      x_hesa_validation_result,
      x_student_ext_run_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.extract_run_id
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.extract_run_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_extract_run_id                    IN OUT NOCOPY NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_extract_phase                     IN     VARCHAR2,
    x_conc_request_id                   IN     NUMBER,
    x_conc_request_status               IN     VARCHAR2,
    x_extract_run_date                  IN     DATE,
    x_file_name                         IN     VARCHAR2,
    x_file_location                     IN     VARCHAR2,
    x_date_file_sent                    IN     DATE,
    x_extract_override                  IN     VARCHAR2,
    x_validation_kit_result             IN     VARCHAR2,
    x_hesa_validation_result            IN     VARCHAR2,
    x_student_ext_run_id                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-JAN-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_ext_run_dtls
      WHERE    extract_run_id                    = x_extract_run_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

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
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igs_he_ext_run_dtls_run_id_s.NEXTVAL
    INTO      x_extract_run_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_extract_run_id                    => x_extract_run_id,
      x_submission_name                   => x_submission_name,
      x_user_return_subclass              => x_user_return_subclass,
      x_return_name                       => x_return_name,
      x_extract_phase                     => x_extract_phase,
      x_conc_request_id                   => x_conc_request_id,
      x_conc_request_status               => x_conc_request_status,
      x_extract_run_date                  => x_extract_run_date,
      x_file_name                         => x_file_name,
      x_file_location                     => x_file_location,
      x_date_file_sent                    => x_date_file_sent,
      x_extract_override                  => x_extract_override,
      x_validation_kit_result             => x_validation_kit_result,
      x_hesa_validation_result            => x_hesa_validation_result,
      x_student_ext_run_id                => x_student_ext_run_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_he_ext_run_dtls (
      extract_run_id,
      submission_name,
      user_return_subclass,
      return_name,
      extract_phase,
      conc_request_id,
      conc_request_status,
      extract_run_date,
      file_name,
      file_location,
      date_file_sent,
      extract_override,
      validation_kit_result,
      hesa_validation_result,
      student_ext_run_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.extract_run_id,
      new_references.submission_name,
      new_references.user_return_subclass,
      new_references.return_name,
      new_references.extract_phase,
      new_references.conc_request_id,
      new_references.conc_request_status,
      new_references.extract_run_date,
      new_references.file_name,
      new_references.file_location,
      new_references.date_file_sent,
      new_references.extract_override,
      new_references.validation_kit_result,
      new_references.hesa_validation_result,
      new_references.student_ext_run_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
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
    x_extract_run_id                    IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_extract_phase                     IN     VARCHAR2,
    x_conc_request_id                   IN     NUMBER,
    x_conc_request_status               IN     VARCHAR2,
    x_extract_run_date                  IN     DATE,
    x_file_name                         IN     VARCHAR2,
    x_file_location                     IN     VARCHAR2,
    x_date_file_sent                    IN     DATE,
    x_extract_override                  IN     VARCHAR2,
    x_validation_kit_result             IN     VARCHAR2,
    x_hesa_validation_result            IN     VARCHAR2,
    x_student_ext_run_id                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-JAN-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        submission_name,
        user_return_subclass,
        return_name,
        extract_phase,
        conc_request_id,
        conc_request_status,
        extract_run_date,
        file_name,
        file_location,
        date_file_sent,
        extract_override,
        validation_kit_result,
        hesa_validation_result,
        student_ext_run_id
      FROM  igs_he_ext_run_dtls
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
        (tlinfo.submission_name = x_submission_name)
        AND (tlinfo.user_return_subclass = x_user_return_subclass)
        AND (tlinfo.return_name = x_return_name)
        AND (tlinfo.extract_phase = x_extract_phase)
        AND ((tlinfo.conc_request_id = x_conc_request_id) OR ((tlinfo.conc_request_id IS NULL) AND (X_conc_request_id IS NULL)))
        AND ((tlinfo.conc_request_status = x_conc_request_status) OR ((tlinfo.conc_request_status IS NULL) AND (X_conc_request_status IS NULL)))
        AND ((tlinfo.extract_run_date = x_extract_run_date) OR ((tlinfo.extract_run_date IS NULL) AND (X_extract_run_date IS NULL)))
        AND ((tlinfo.file_name = x_file_name) OR ((tlinfo.file_name IS NULL) AND (X_file_name IS NULL)))
        AND ((tlinfo.file_location = x_file_location) OR ((tlinfo.file_location IS NULL) AND (X_file_location IS NULL)))
        AND ((tlinfo.date_file_sent = x_date_file_sent) OR ((tlinfo.date_file_sent IS NULL) AND (X_date_file_sent IS NULL)))
        AND ((tlinfo.extract_override = x_extract_override) OR ((tlinfo.extract_override IS NULL) AND (X_extract_override IS NULL)))
        AND ((tlinfo.validation_kit_result = x_validation_kit_result) OR ((tlinfo.validation_kit_result IS NULL) AND (X_validation_kit_result IS NULL)))
        AND ((tlinfo.hesa_validation_result = x_hesa_validation_result) OR ((tlinfo.hesa_validation_result IS NULL) AND (X_hesa_validation_result IS NULL)))
        AND ((tlinfo.student_ext_run_id = x_student_ext_run_id) OR ((tlinfo.student_ext_run_id IS NULL) AND (X_student_ext_run_id IS NULL)))
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
    x_extract_run_id                    IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_extract_phase                     IN     VARCHAR2,
    x_conc_request_id                   IN     NUMBER,
    x_conc_request_status               IN     VARCHAR2,
    x_extract_run_date                  IN     DATE,
    x_file_name                         IN     VARCHAR2,
    x_file_location                     IN     VARCHAR2,
    x_date_file_sent                    IN     DATE,
    x_extract_override                  IN     VARCHAR2,
    x_validation_kit_result             IN     VARCHAR2,
    x_hesa_validation_result            IN     VARCHAR2,
    x_student_ext_run_id                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-JAN-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

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
      x_extract_run_id                    => x_extract_run_id,
      x_submission_name                   => x_submission_name,
      x_user_return_subclass              => x_user_return_subclass,
      x_return_name                       => x_return_name,
      x_extract_phase                     => x_extract_phase,
      x_conc_request_id                   => x_conc_request_id,
      x_conc_request_status               => x_conc_request_status,
      x_extract_run_date                  => x_extract_run_date,
      x_file_name                         => x_file_name,
      x_file_location                     => x_file_location,
      x_date_file_sent                    => x_date_file_sent,
      x_extract_override                  => x_extract_override,
      x_validation_kit_result             => x_validation_kit_result,
      x_hesa_validation_result            => x_hesa_validation_result,
      x_student_ext_run_id                => x_student_ext_run_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_he_ext_run_dtls
      SET
        submission_name                   = new_references.submission_name,
        user_return_subclass              = new_references.user_return_subclass,
        return_name                       = new_references.return_name,
        extract_phase                     = new_references.extract_phase,
        conc_request_id                   = new_references.conc_request_id,
        conc_request_status               = new_references.conc_request_status,
        extract_run_date                  = new_references.extract_run_date,
        file_name                         = new_references.file_name,
        file_location                     = new_references.file_location,
        date_file_sent                    = new_references.date_file_sent,
        extract_override                  = new_references.extract_override,
        validation_kit_result             = new_references.validation_kit_result,
        hesa_validation_result            = new_references.hesa_validation_result,
        student_ext_run_id                = new_references.student_ext_run_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_extract_run_id                    IN OUT NOCOPY NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_extract_phase                     IN     VARCHAR2,
    x_conc_request_id                   IN     NUMBER,
    x_conc_request_status               IN     VARCHAR2,
    x_extract_run_date                  IN     DATE,
    x_file_name                         IN     VARCHAR2,
    x_file_location                     IN     VARCHAR2,
    x_date_file_sent                    IN     DATE,
    x_extract_override                  IN     VARCHAR2,
    x_validation_kit_result             IN     VARCHAR2,
    x_hesa_validation_result            IN     VARCHAR2,
    x_student_ext_run_id                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-JAN-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_ext_run_dtls
      WHERE    extract_run_id                    = x_extract_run_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_extract_run_id,
        x_submission_name,
        x_user_return_subclass,
        x_return_name,
        x_extract_phase,
        x_conc_request_id,
        x_conc_request_status,
        x_extract_run_date,
        x_file_name,
        x_file_location,
        x_date_file_sent,
        x_extract_override,
        x_validation_kit_result,
        x_hesa_validation_result,
        x_student_ext_run_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_extract_run_id,
      x_submission_name,
      x_user_return_subclass,
      x_return_name,
      x_extract_phase,
      x_conc_request_id,
      x_conc_request_status,
      x_extract_run_date,
      x_file_name,
      x_file_location,
      x_date_file_sent,
      x_extract_override,
      x_validation_kit_result,
      x_hesa_validation_result,
      x_student_ext_run_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 23-JAN-2002
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

    DELETE FROM igs_he_ext_run_dtls
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_ext_run_dtls_pkg;

/
