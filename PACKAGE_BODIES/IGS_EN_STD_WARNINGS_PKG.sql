--------------------------------------------------------
--  DDL for Package Body IGS_EN_STD_WARNINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_STD_WARNINGS_PKG" AS
/* $Header: IGSEI58B.pls 120.0 2005/09/13 10:01:24 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_std_warnings%ROWTYPE;
  new_references igs_en_std_warnings%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_warning_id                        IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_message_for                       IN     VARCHAR2,
    x_message_icon                      IN     VARCHAR2,
    x_message_name                      IN     VARCHAR2,
    x_message_text                      IN     VARCHAR2,
    x_message_action                    IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_p_parameters                      IN     VARCHAR2,
    x_step_type                         IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_creation_date                       IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 20-MAY-2005
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_en_std_warnings
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
    new_references.warning_id                        := x_warning_id;
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.uoo_id                            := x_uoo_id;
    new_references.term_cal_type                     := x_term_cal_type;
    new_references.term_ci_sequence_number           := x_term_ci_sequence_number;
    new_references.message_for                       := x_message_for;
    new_references.message_icon                      := x_message_icon;
    new_references.message_name                      := x_message_name;
    new_references.message_text                      := x_message_text;
    new_references.message_action                    := x_message_action;
    new_references.destination                       := x_destination;
    new_references.p_parameters                      := x_p_parameters;
    new_references.step_type                         := x_step_type;
    new_references.session_id                        := x_session_id;

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


  FUNCTION get_pk_for_validation (
    x_warning_id                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 20-MAY-2005
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_std_warnings
      WHERE    warning_id = x_warning_id
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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_warning_id                        IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_message_for                       IN     VARCHAR2,
    x_message_icon                      IN     VARCHAR2,
    x_message_name                      IN     VARCHAR2,
    x_message_text                      IN     VARCHAR2,
    x_message_action                    IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_p_parameters                      IN     VARCHAR2,
    x_step_type                         IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 20-MAY-2005
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
      x_warning_id,
      x_person_id,
      x_course_cd,
      x_uoo_id,
      x_term_cal_type,
      x_term_ci_sequence_number,
      x_message_for,
      x_message_icon,
      x_message_name,
      x_message_text,
      x_message_action,
      x_destination,
      x_p_parameters,
      x_step_type,
      x_session_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.warning_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.warning_id
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
    x_warning_id                        IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_message_for                       IN     VARCHAR2,
    x_message_icon                      IN     VARCHAR2,
    x_message_name                      IN     VARCHAR2,
    x_message_text                      IN     VARCHAR2,
    x_message_action                    IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_p_parameters                      IN     VARCHAR2,
    x_step_type                         IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 20-MAY-2005
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

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
      fnd_message.set_token ('ROUTINE', 'igs_en_std_warnings_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_warning_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_warning_id                        => x_warning_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_uoo_id                            => x_uoo_id,
      x_term_cal_type                     => x_term_cal_type,
      x_term_ci_sequence_number           => x_term_ci_sequence_number,
      x_message_for                       => x_message_for,
      x_message_icon                      => x_message_icon,
      x_message_name                      => x_message_name,
      x_message_text                      => x_message_text,
      x_message_action                    => x_message_action,
      x_destination                       => x_destination,
      x_p_parameters                      => x_p_parameters,
      x_step_type                         => x_step_type,
      x_session_id                        => x_session_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_std_warnings (
      warning_id,
      person_id,
      course_cd,
      uoo_id,
      term_cal_type,
      term_ci_sequence_number,
      message_for,
      message_icon,
      message_name,
      message_text,
      message_action,
      destination,
      p_parameters,
      step_type,
      session_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_en_std_warnings_s.NEXTVAL,
      new_references.person_id,
      new_references.course_cd,
      new_references.uoo_id,
      new_references.term_cal_type,
      new_references.term_ci_sequence_number,
      new_references.message_for,
      new_references.message_icon,
      new_references.message_name,
      new_references.message_text,
      new_references.message_action,
      new_references.destination,
      new_references.p_parameters,
      new_references.step_type,
      new_references.session_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, warning_id INTO x_rowid, x_warning_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_warning_id                        IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_message_for                       IN     VARCHAR2,
    x_message_icon                      IN     VARCHAR2,
    x_message_name                      IN     VARCHAR2,
    x_message_text                      IN     VARCHAR2,
    x_message_action                    IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_p_parameters                      IN     VARCHAR2,
    x_step_type                         IN     VARCHAR2,
    x_session_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 20-MAY-2005
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        course_cd,
        uoo_id,
        term_cal_type,
        term_ci_sequence_number,
        message_for,
        message_icon,
        message_name,
        message_text,
        message_action,
        destination,
        p_parameters,
        step_type,
        session_id
      FROM  igs_en_std_warnings
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
        (tlinfo.person_id = x_person_id)
        AND (tlinfo.course_cd = x_course_cd)
        AND (tlinfo.uoo_id = x_uoo_id)
        AND (tlinfo.term_cal_type = x_term_cal_type)
        AND (tlinfo.term_ci_sequence_number = x_term_ci_sequence_number)
        AND (tlinfo.message_for = x_message_for)
        AND (tlinfo.message_icon = x_message_icon)
        AND (tlinfo.message_name = x_message_name)
        AND (tlinfo.message_text = x_message_text)
        AND ((tlinfo.message_action = x_message_action) OR ((tlinfo.message_action IS NULL) AND (X_message_action IS NULL)))
        AND ((tlinfo.destination = x_destination) OR ((tlinfo.destination IS NULL) AND (X_destination IS NULL)))
        AND ((tlinfo.p_parameters = x_p_parameters) OR ((tlinfo.p_parameters IS NULL) AND (X_p_parameters IS NULL)))
        AND (tlinfo.step_type = x_step_type)
        AND (tlinfo.session_id = x_session_id)
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
    x_warning_id                        IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_message_for                       IN     VARCHAR2,
    x_message_icon                      IN     VARCHAR2,
    x_message_name                      IN     VARCHAR2,
    x_message_text                      IN     VARCHAR2,
    x_message_action                    IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_p_parameters                      IN     VARCHAR2,
    x_step_type                         IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 20-MAY-2005
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
      fnd_message.set_token ('ROUTINE', 'igs_en_std_warnings_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_warning_id                        => x_warning_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_uoo_id                            => x_uoo_id,
      x_term_cal_type                     => x_term_cal_type,
      x_term_ci_sequence_number           => x_term_ci_sequence_number,
      x_message_for                       => x_message_for,
      x_message_icon                      => x_message_icon,
      x_message_name                      => x_message_name,
      x_message_text                      => x_message_text,
      x_message_action                    => x_message_action,
      x_destination                       => x_destination,
      x_p_parameters                      => x_p_parameters,
      x_step_type                         => x_step_type,
      x_session_id                        => x_session_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_en_std_warnings
      SET
        person_id                         = new_references.person_id,
        course_cd                         = new_references.course_cd,
        uoo_id                            = new_references.uoo_id,
        term_cal_type                     = new_references.term_cal_type,
        term_ci_sequence_number           = new_references.term_ci_sequence_number,
        message_for                       = new_references.message_for,
        message_icon                      = new_references.message_icon,
        message_name                      = new_references.message_name,
        message_text                      = new_references.message_text,
        message_action                    = new_references.message_action,
        destination                       = new_references.destination,
        p_parameters                      = new_references.p_parameters,
        step_type                         = new_references.step_type,
        session_id                        = new_references.session_id,
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
    x_warning_id                        IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_ci_sequence_number           IN     NUMBER,
    x_message_for                       IN     VARCHAR2,
    x_message_icon                      IN     VARCHAR2,
    x_message_name                      IN     VARCHAR2,
    x_message_text                      IN     VARCHAR2,
    x_message_action                    IN     VARCHAR2,
    x_destination                       IN     VARCHAR2,
    x_p_parameters                      IN     VARCHAR2,
    x_step_type                         IN     VARCHAR2,
    x_session_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 20-MAY-2005
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_std_warnings
      WHERE    warning_id                        = x_warning_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_warning_id,
        x_person_id,
        x_course_cd,
        x_uoo_id,
        x_term_cal_type,
        x_term_ci_sequence_number,
        x_message_for,
        x_message_icon,
        x_message_name,
        x_message_text,
        x_message_action,
        x_destination,
        x_p_parameters,
        x_step_type,
        x_session_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_warning_id,
      x_person_id,
      x_course_cd,
      x_uoo_id,
      x_term_cal_type,
      x_term_ci_sequence_number,
      x_message_for,
      x_message_icon,
      x_message_name,
      x_message_text,
      x_message_action,
      x_destination,
      x_p_parameters,
      x_step_type,
      x_session_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 20-MAY-2005
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

    DELETE FROM igs_en_std_warnings
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_en_std_warnings_pkg;

/
