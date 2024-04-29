--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPI_RCONDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPI_RCONDS_PKG" AS
/* $Header: IGSEI81B.pls 120.1 2006/04/16 23:48:24 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_spi_rconds%ROWTYPE;
  new_references igs_en_spi_rconds%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_return_condition                          IN     VARCHAR2,
    x_status_code                            IN     VARCHAR2,
    x_approved_dt                       IN     DATE,
    x_approved_by                       IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Susmitha Tutta
  ||  Created On : 12-MAR-2006
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_en_spi_rconds
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
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.start_dt                          := x_start_dt;
    new_references.logical_delete_date               := x_logical_delete_date;
    new_references.return_condition                          := x_return_condition;
    new_references.status_code                            := NVL(x_status_code,'PENDING');
    new_references.approved_dt                       := x_approved_dt;
    new_references.approved_by                       := x_approved_by;

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
  ||  Created By : Susmitha Tutta
  ||  Created On : 12-MAR-2006
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.return_condition = new_references.return_condition)) OR
        ((new_references.return_condition IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_intm_rconds_pkg.get_pk_for_validation (
                new_references.return_condition
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (
        (
         (old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.start_dt = new_references.start_dt) AND
         (old_references.logical_delete_date = new_references.logical_delete_date)
        ) OR
        (
	 (new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL) OR
	 (new_references.start_dt IS NULL) OR
	 (new_references.logical_delete_date IS NULL)
        )
       ) THEN
      NULL;
    ELSIF NOT igs_en_stdnt_ps_intm_pkg.get_pk_for_validation (
                new_references.person_id,
		new_references.course_cd,
		new_references.start_dt,
		new_references.logical_delete_date
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_return_condition                          IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Susmitha Tutta
  ||  Created On : 12-MAR-2006
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_spi_rconds
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      start_dt = x_start_dt
      AND      logical_delete_date = x_logical_delete_date
      AND      return_condition = x_return_condition
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


  PROCEDURE get_fk_igs_en_stdnt_ps_intm
  ( x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_start_dt IN DATE,
    x_logical_delete_date IN DATE
  ) AS
  -- Get the details of
  CURSOR cur_rowid IS
    SELECT rowid
      FROM igs_en_spi_rconds
     WHERE person_id = x_person_id
       AND course_cd =  x_course_cd
       AND start_dt = x_start_dt
       AND logical_delete_date = x_logical_delete_date;
  lv_rowid ROWID;
  BEGIN
  OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_INTM_CHLD_EXST');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_return_condition                          IN     VARCHAR2,
    x_status_code                            IN     VARCHAR2,
    x_approved_dt                       IN     DATE,
    x_approved_by                       IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Susmitha Tutta
  ||  Created On : 12-MAR-2006
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
      x_person_id,
      x_course_cd,
      x_start_dt,
      x_logical_delete_date,
      x_return_condition,
      x_status_code,
      x_approved_dt,
      x_approved_by,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.person_id,
             new_references.course_cd,
             new_references.start_dt,
             new_references.logical_delete_date,
             new_references.return_condition
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
             new_references.person_id,
             new_references.course_cd,
             new_references.start_dt,
             new_references.logical_delete_date,
             new_references.return_condition
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
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_return_condition                          IN     VARCHAR2,
    x_status_code                            IN     VARCHAR2,
    x_approved_dt                       IN     DATE,
    x_approved_by                       IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Susmitha Tutta
  ||  Created On : 12-MAR-2006
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
      fnd_message.set_token ('ROUTINE', 'IGS_EN_SPI_RCONDS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;


    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_start_dt                          => x_start_dt,
      x_logical_delete_date               => x_logical_delete_date,
      x_return_condition                          => x_return_condition,
      x_status_code                            => x_status_code,
      x_approved_dt                       => x_approved_dt,
      x_approved_by                       => x_approved_by,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_spi_rconds (
      person_id,
      course_cd,
      start_dt,
      logical_delete_date,
      return_condition,
      status_code,
      approved_dt,
      approved_by,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.person_id,
      new_references.course_cd,
      new_references.start_dt,
      new_references.logical_delete_date,
      new_references.return_condition,
      new_references.status_code,
      new_references.approved_dt,
      new_references.approved_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_return_condition                          IN     VARCHAR2,
    x_status_code                            IN     VARCHAR2,
    x_approved_dt                       IN     DATE,
    x_approved_by                       IN     NUMBER
  ) AS
  /*
  ||  Created By : Susmitha Tutta
  ||  Created On : 12-MAR-2006
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        status_code,
        approved_dt,
        approved_by
      FROM  igs_en_spi_rconds
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
        ((tlinfo.status_code = x_status_code) OR ((tlinfo.status_code IS NULL) AND (X_status_code IS NULL)))
        AND ((tlinfo.approved_dt = x_approved_dt) OR ((tlinfo.approved_dt IS NULL) AND (X_approved_dt IS NULL)))
        AND ((tlinfo.approved_by = x_approved_by) OR ((tlinfo.approved_by IS NULL) AND (X_approved_by IS NULL)))
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
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_return_condition                          IN     VARCHAR2,
    x_status_code                            IN     VARCHAR2,
    x_approved_dt                       IN     DATE,
    x_approved_by                       IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Susmitha Tutta
  ||  Created On : 12-MAR-2006
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
      fnd_message.set_token ('ROUTINE', 'IGS_EN_SPI_RCONDS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_start_dt                          => x_start_dt,
      x_logical_delete_date               => x_logical_delete_date,
      x_return_condition                  => x_return_condition,
      x_status_code                       => x_status_code,
      x_approved_dt                       => x_approved_dt,
      x_approved_by                       => x_approved_by,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_en_spi_rconds
      SET
        logical_delete_date               = new_references.logical_delete_date,
        status_code                       = new_references.status_code,
        approved_dt                       = new_references.approved_dt,
        approved_by                       = new_references.approved_by,
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
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_logical_delete_date               IN     DATE,
    x_return_condition                          IN     VARCHAR2,
    x_status_code                            IN     VARCHAR2,
    x_approved_dt                       IN     DATE,
    x_approved_by                       IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Susmitha Tutta
  ||  Created On : 12-MAR-2006
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_spi_rconds
      WHERE    person_id                         = x_person_id
      AND      course_cd                         = x_course_cd
      AND      start_dt                          = x_start_dt
      AND      logical_delete_date               = x_logical_delete_date
      AND      return_condition                          = x_return_condition;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_person_id,
        x_course_cd,
        x_start_dt,
        x_logical_delete_date,
        x_return_condition,
        x_status_code,
        x_approved_dt,
        x_approved_by,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_person_id,
      x_course_cd,
      x_start_dt,
      x_logical_delete_date,
      x_return_condition,
      x_status_code,
      x_approved_dt,
      x_approved_by,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Susmitha Tutta
  ||  Created On : 12-MAR-2006
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

    DELETE FROM igs_en_spi_rconds
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_en_spi_rconds_pkg;

/
