--------------------------------------------------------
--  DDL for Package Body IGF_AW_FISAP_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_FISAP_REP_PKG" AS
/* $Header: IGFWI74B.pls 120.0 2005/09/13 09:52:46 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_fisap_rep%ROWTYPE;
  new_references igf_aw_fisap_rep%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_fisap_dtls_id                     IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_dependency_status                 IN     VARCHAR2,
    x_career_level                      IN     VARCHAR2,
    x_auto_zero_efc_flag                IN     VARCHAR2,
    x_fisap_income_amt                  IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_perkins_disb_amt                  IN     NUMBER,
    x_fws_disb_amt                      IN     NUMBER,
    x_fseog_disb_amt                    IN     NUMBER,
    x_part_ii_section_f_flag            IN     VARCHAR2,
    x_part_vi_section_a_flag            IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Uday Kiran Reddy
  ||  Created On : 13-JUN-2005
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_aw_fisap_rep
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
    new_references.fisap_dtls_id                     := x_fisap_dtls_id;
    new_references.batch_id                          := x_batch_id;
    new_references.isir_id                           := x_isir_id;
    new_references.dependency_status                 := x_dependency_status;
    new_references.career_level                      := x_career_level;
    new_references.auto_zero_efc_flag                := x_auto_zero_efc_flag;
    new_references.fisap_income_amt                  := x_fisap_income_amt;
    new_references.enrollment_status                 := x_enrollment_status;
    new_references.perkins_disb_amt                  := x_perkins_disb_amt;
    new_references.fws_disb_amt                      := x_fws_disb_amt;
    new_references.fseog_disb_amt                    := x_fseog_disb_amt;
    new_references.part_ii_section_f_flag            := x_part_ii_section_f_flag;
    new_references.part_vi_section_a_flag            := x_part_vi_section_a_flag;

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
  ||  Created By : Uday Kiran Reddy
  ||  Created On : 13-JUN-2005
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.batch_id = new_references.batch_id)) OR
        ((new_references.batch_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_fisap_batch_pkg.get_pk_for_validation (
                new_references.batch_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_fisap_dtls_id                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Uday Kiran Reddy
  ||  Created On : 13-JUN-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fisap_rep
      WHERE    fisap_dtls_id = x_fisap_dtls_id
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


  PROCEDURE get_fk_igf_aw_fisap_batch (
    x_batch_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : Uday Kiran Reddy
  ||  Created On : 13-JUN-2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fisap_rep
      WHERE   ((batch_id = x_batch_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_fisap_batch;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_fisap_dtls_id                     IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_dependency_status                 IN     VARCHAR2,
    x_career_level                      IN     VARCHAR2,
    x_auto_zero_efc_flag                IN     VARCHAR2,
    x_fisap_income_amt                  IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_perkins_disb_amt                  IN     NUMBER,
    x_fws_disb_amt                      IN     NUMBER,
    x_fseog_disb_amt                    IN     NUMBER,
    x_part_ii_section_f_flag            IN     VARCHAR2,
    x_part_vi_section_a_flag            IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Uday Kiran Reddy
  ||  Created On : 13-JUN-2005
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
      x_fisap_dtls_id,
      x_batch_id,
      x_isir_id,
      x_dependency_status,
      x_career_level,
      x_auto_zero_efc_flag,
      x_fisap_income_amt,
      x_enrollment_status,
      x_perkins_disb_amt,
      x_fws_disb_amt,
      x_fseog_disb_amt,
      x_part_ii_section_f_flag,
      x_part_vi_section_a_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.fisap_dtls_id
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
             new_references.fisap_dtls_id
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
    x_fisap_dtls_id                     IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_dependency_status                 IN     VARCHAR2,
    x_career_level                      IN     VARCHAR2,
    x_auto_zero_efc_flag                IN     VARCHAR2,
    x_fisap_income_amt                  IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_perkins_disb_amt                  IN     NUMBER,
    x_fws_disb_amt                      IN     NUMBER,
    x_fseog_disb_amt                    IN     NUMBER,
    x_part_ii_section_f_flag            IN     VARCHAR2,
    x_part_vi_section_a_flag            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Uday Kiran Reddy
  ||  Created On : 13-JUN-2005
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
      fnd_message.set_token ('ROUTINE', 'IGF_AW_FISAP_REP_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_fisap_dtls_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_fisap_dtls_id                     => x_fisap_dtls_id,
      x_batch_id                          => x_batch_id,
      x_isir_id                           => x_isir_id,
      x_dependency_status                 => x_dependency_status,
      x_career_level                      => x_career_level,
      x_auto_zero_efc_flag                => x_auto_zero_efc_flag,
      x_fisap_income_amt                  => x_fisap_income_amt,
      x_enrollment_status                 => x_enrollment_status,
      x_perkins_disb_amt                  => x_perkins_disb_amt,
      x_fws_disb_amt                      => x_fws_disb_amt,
      x_fseog_disb_amt                    => x_fseog_disb_amt,
      x_part_ii_section_f_flag            => x_part_ii_section_f_flag,
      x_part_vi_section_a_flag            => x_part_vi_section_a_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_aw_fisap_rep (
      fisap_dtls_id,
      batch_id,
      isir_id,
      dependency_status,
      career_level,
      auto_zero_efc_flag,
      fisap_income_amt,
      enrollment_status,
      perkins_disb_amt,
      fws_disb_amt,
      fseog_disb_amt,
      part_ii_section_f_flag,
      part_vi_section_a_flag,
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
      igf_aw_fisap_rep_s.NEXTVAL,
      new_references.batch_id,
      new_references.isir_id,
      new_references.dependency_status,
      new_references.career_level,
      new_references.auto_zero_efc_flag,
      new_references.fisap_income_amt,
      new_references.enrollment_status,
      new_references.perkins_disb_amt,
      new_references.fws_disb_amt,
      new_references.fseog_disb_amt,
      new_references.part_ii_section_f_flag,
      new_references.part_vi_section_a_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID, fisap_dtls_id INTO x_rowid, x_fisap_dtls_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fisap_dtls_id                     IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_dependency_status                 IN     VARCHAR2,
    x_career_level                      IN     VARCHAR2,
    x_auto_zero_efc_flag                IN     VARCHAR2,
    x_fisap_income_amt                  IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_perkins_disb_amt                  IN     NUMBER,
    x_fws_disb_amt                      IN     NUMBER,
    x_fseog_disb_amt                    IN     NUMBER,
    x_part_ii_section_f_flag            IN     VARCHAR2,
    x_part_vi_section_a_flag            IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Uday Kiran Reddy
  ||  Created On : 13-JUN-2005
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        batch_id,
        isir_id,
        dependency_status,
        career_level,
        auto_zero_efc_flag,
        fisap_income_amt,
        enrollment_status,
        perkins_disb_amt,
        fws_disb_amt,
        fseog_disb_amt,
        part_ii_section_f_flag,
        part_vi_section_a_flag
      FROM  igf_aw_fisap_rep
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
        (tlinfo.batch_id = x_batch_id)
        AND (tlinfo.isir_id = x_isir_id)
        AND (tlinfo.dependency_status = x_dependency_status)
        AND (tlinfo.career_level = x_career_level)
        AND (tlinfo.auto_zero_efc_flag = x_auto_zero_efc_flag)
        AND (tlinfo.fisap_income_amt = x_fisap_income_amt)
        AND ((tlinfo.enrollment_status = x_enrollment_status) OR ((tlinfo.enrollment_status IS NULL) AND (X_enrollment_status IS NULL)))
        AND ((tlinfo.perkins_disb_amt = x_perkins_disb_amt) OR ((tlinfo.perkins_disb_amt IS NULL) AND (X_perkins_disb_amt IS NULL)))
        AND ((tlinfo.fws_disb_amt = x_fws_disb_amt) OR ((tlinfo.fws_disb_amt IS NULL) AND (X_fws_disb_amt IS NULL)))
        AND ((tlinfo.fseog_disb_amt = x_fseog_disb_amt) OR ((tlinfo.fseog_disb_amt IS NULL) AND (X_fseog_disb_amt IS NULL)))
        AND ((tlinfo.part_ii_section_f_flag = x_part_ii_section_f_flag) OR ((tlinfo.part_ii_section_f_flag IS NULL) AND (X_part_ii_section_f_flag IS NULL)))
        AND ((tlinfo.part_vi_section_a_flag = x_part_vi_section_a_flag) OR ((tlinfo.part_vi_section_a_flag IS NULL) AND (X_part_vi_section_a_flag IS NULL)))
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
    x_fisap_dtls_id                     IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_dependency_status                 IN     VARCHAR2,
    x_career_level                      IN     VARCHAR2,
    x_auto_zero_efc_flag                IN     VARCHAR2,
    x_fisap_income_amt                  IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_perkins_disb_amt                  IN     NUMBER,
    x_fws_disb_amt                      IN     NUMBER,
    x_fseog_disb_amt                    IN     NUMBER,
    x_part_ii_section_f_flag            IN     VARCHAR2,
    x_part_vi_section_a_flag            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Uday Kiran Reddy
  ||  Created On : 13-JUN-2005
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
      fnd_message.set_token ('ROUTINE', 'IGF_AW_FISAP_REP_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_fisap_dtls_id                     => x_fisap_dtls_id,
      x_batch_id                          => x_batch_id,
      x_isir_id                           => x_isir_id,
      x_dependency_status                 => x_dependency_status,
      x_career_level                      => x_career_level,
      x_auto_zero_efc_flag                => x_auto_zero_efc_flag,
      x_fisap_income_amt                  => x_fisap_income_amt,
      x_enrollment_status                 => x_enrollment_status,
      x_perkins_disb_amt                  => x_perkins_disb_amt,
      x_fws_disb_amt                      => x_fws_disb_amt,
      x_fseog_disb_amt                    => x_fseog_disb_amt,
      x_part_ii_section_f_flag            => x_part_ii_section_f_flag,
      x_part_vi_section_a_flag            => x_part_vi_section_a_flag,
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

    UPDATE igf_aw_fisap_rep
      SET
        batch_id                          = new_references.batch_id,
        isir_id                           = new_references.isir_id,
        dependency_status                 = new_references.dependency_status,
        career_level                      = new_references.career_level,
        auto_zero_efc_flag                = new_references.auto_zero_efc_flag,
        fisap_income_amt                  = new_references.fisap_income_amt,
        enrollment_status                 = new_references.enrollment_status,
        perkins_disb_amt                  = new_references.perkins_disb_amt,
        fws_disb_amt                      = new_references.fws_disb_amt,
        fseog_disb_amt                    = new_references.fseog_disb_amt,
        part_ii_section_f_flag            = new_references.part_ii_section_f_flag,
        part_vi_section_a_flag            = new_references.part_vi_section_a_flag,
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
    x_fisap_dtls_id                     IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_dependency_status                 IN     VARCHAR2,
    x_career_level                      IN     VARCHAR2,
    x_auto_zero_efc_flag                IN     VARCHAR2,
    x_fisap_income_amt                  IN     NUMBER,
    x_enrollment_status                 IN     VARCHAR2,
    x_perkins_disb_amt                  IN     NUMBER,
    x_fws_disb_amt                      IN     NUMBER,
    x_fseog_disb_amt                    IN     NUMBER,
    x_part_ii_section_f_flag            IN     VARCHAR2,
    x_part_vi_section_a_flag            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Uday Kiran Reddy
  ||  Created On : 13-JUN-2005
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_fisap_rep
      WHERE    fisap_dtls_id                     = x_fisap_dtls_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_fisap_dtls_id,
        x_batch_id,
        x_isir_id,
        x_dependency_status,
        x_career_level,
        x_auto_zero_efc_flag,
        x_fisap_income_amt,
        x_enrollment_status,
        x_perkins_disb_amt,
        x_fws_disb_amt,
        x_fseog_disb_amt,
        x_part_ii_section_f_flag,
        x_part_vi_section_a_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_fisap_dtls_id,
      x_batch_id,
      x_isir_id,
      x_dependency_status,
      x_career_level,
      x_auto_zero_efc_flag,
      x_fisap_income_amt,
      x_enrollment_status,
      x_perkins_disb_amt,
      x_fws_disb_amt,
      x_fseog_disb_amt,
      x_part_ii_section_f_flag,
      x_part_vi_section_a_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Uday Kiran Reddy
  ||  Created On : 13-JUN-2005
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

    DELETE FROM igf_aw_fisap_rep
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_fisap_rep_pkg;

/
