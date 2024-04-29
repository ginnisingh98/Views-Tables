--------------------------------------------------------
--  DDL for Package Body IGS_EN_PSV_TERM_IT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_PSV_TERM_IT_PKG" AS
/* $Header: IGSEI78B.pls 120.0 2005/06/01 18:06:37 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_psv_term_it%ROWTYPE;
  new_references igs_en_psv_term_it%ROWTYPE;


PROCEDURE Check_Parent_Existance AS
  /*----------------------------------------------------------------------------
  ||  Created By : vkarthik
  ||  Created On : 30-Mar-2004
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||
  ----------------------------------------------------------------------------*/
  BEGIN
     IF (((old_references.cal_type = new_references.cal_type) AND
         (old_references.sequence_number = new_references.sequence_number)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.sequence_number IS NULL))) THEN
        NULL;
     ELSE
        IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
                new_references.cal_type,
                new_references.sequence_number
                ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END IF;
    END IF;

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
        NULL;
     ELSE
        IF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
                new_references.course_cd,
                new_references.version_number
                ) THEN
                Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
        END IF;
    END IF;

  END Check_Parent_Existance;


  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_term_instruction_time             IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : vignesh.karthik@oracle.com
  ||  Created On : 01-MAR-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_en_psv_term_it
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
    new_references.cal_type                          := x_cal_type;
    new_references.sequence_number                   := x_sequence_number;
    new_references.course_cd                         := x_course_cd;
    new_references.version_number                    := x_version_number;
    new_references.term_instruction_time             := x_term_instruction_time;

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


  PROCEDURE GET_FK_IGS_CA_INST (
    X_CAL_TYPE IN VARCHAR2,
    X_SEQUENCE_NUMBER IN NUMBER
    ) AS
  /*
  ||  Created By : vkarthik
  ||  Created On : 10-MAR-2004
  ||  Purpose : Validates the Foreign Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT ROWID
      FROM   igs_en_psv_term_it
      WHERE  CAL_TYPE   = X_CAL_TYPE  AND
             SEQUENCE_NUMBER = X_SEQUENCE_NUMBER ;
    lv_rowid cur_rowid%ROWTYPE;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_PITO_CI_FK');
      Igs_Ge_Msg_Stack.ADD;
      CLOSE cur_rowid;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END GET_FK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS
  /*
  ||  Created By : vkarthik
  ||  Created On : 10-MAR-2004
  ||  Purpose : Validates the Foreign Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_en_psv_term_it
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number ;
    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_PITO_CRV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
  CLOSE cur_rowid;
  END GET_FK_IGS_PS_VER;

  FUNCTION get_pk_for_validation (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : vignesh.karthik@oracle.com
  ||  Created On : 01-MAR-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_psv_term_it
      WHERE    cal_type = x_cal_type
      AND      sequence_number = x_sequence_number
      AND      course_cd = x_course_cd
      AND      version_number = x_version_number
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
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_term_instruction_time             IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : vignesh.karthik@oracle.com
  ||  Created On : 01-MAR-2004
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
      x_cal_type,
      x_sequence_number,
      x_course_cd,
      x_version_number,
      x_term_instruction_time,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.cal_type,
             new_references.sequence_number,
             new_references.course_cd,
             new_references.version_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_EN_PRG_IT_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      Check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.cal_type,
             new_references.sequence_number,
             new_references.course_cd,
             new_references.version_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_EN_PRG_IT_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_term_instruction_time             IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : vignesh.karthik@oracle.com
  ||  Created On : 01-MAR-2004
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
      fnd_message.set_token ('ROUTINE', 'IGS_EN_PSV_TERM_IT_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_cal_type                          => x_cal_type,
      x_sequence_number                   => x_sequence_number,
      x_course_cd                         => x_course_cd,
      x_version_number                    => x_version_number,
      x_term_instruction_time             => x_term_instruction_time,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_psv_term_it (
      cal_type,
      sequence_number,
      course_cd,
      version_number,
      term_instruction_time,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.cal_type,
      new_references.sequence_number,
      new_references.course_cd,
      new_references.version_number,
      new_references.term_instruction_time,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_term_instruction_time             IN     NUMBER
  ) AS
  /*
  ||  Created By : vignesh.karthik@oracle.com
  ||  Created On : 01-MAR-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        term_instruction_time
      FROM  igs_en_psv_term_it
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
        (tlinfo.term_instruction_time = x_term_instruction_time)
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
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_term_instruction_time             IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : vignesh.karthik@oracle.com
  ||  Created On : 01-MAR-2004
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
      fnd_message.set_token ('ROUTINE', 'IGS_EN_PSV_TERM_IT_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_cal_type                          => x_cal_type,
      x_sequence_number                   => x_sequence_number,
      x_course_cd                         => x_course_cd,
      x_version_number                    => x_version_number,
      x_term_instruction_time             => x_term_instruction_time,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_en_psv_term_it
      SET
        term_instruction_time             = new_references.term_instruction_time,
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
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_term_instruction_time             IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : vignesh.karthik@oracle.com
  ||  Created On : 01-MAR-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_psv_term_it
      WHERE    cal_type                          = x_cal_type
      AND      sequence_number                   = x_sequence_number
      AND      course_cd                         = x_course_cd
      AND      version_number                    = x_version_number;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_cal_type,
        x_sequence_number,
        x_course_cd,
        x_version_number,
        x_term_instruction_time,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_cal_type,
      x_sequence_number,
      x_course_cd,
      x_version_number,
      x_term_instruction_time,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : vignesh.karthik@oracle.com
  ||  Created On : 01-MAR-2004
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

    DELETE FROM igs_en_psv_term_it
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_en_psv_term_it_pkg;

/
