--------------------------------------------------------
--  DDL for Package Body IGS_EN_ELGB_OVR_STEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ELGB_OVR_STEP_PKG" AS
/* $Header: IGSEI52B.pls 115.27 2003/06/03 12:58:28 savenkat ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_elgb_ovr_step%ROWTYPE;
  new_references igs_en_elgb_ovr_step%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_elgb_ovr_step_id                  IN     NUMBER      ,
    x_elgb_override_id                  IN     NUMBER      ,
    x_step_override_type                IN     VARCHAR2    ,
    x_step_override_dt                  IN     DATE        ,
    x_step_override_limit               IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 29-JUN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_ELGB_OVR_STEP
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
    new_references.elgb_ovr_step_id                  := x_elgb_ovr_step_id;
    new_references.elgb_override_id                  := x_elgb_override_id;
    new_references.step_override_type                := x_step_override_type;
    new_references.step_override_dt                  := x_step_override_dt;
    new_references.step_override_limit               := x_step_override_limit;

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


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 29-JUN-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.step_override_type,
           new_references.elgb_override_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 29-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.elgb_override_id = new_references.elgb_override_id)) OR
        ((new_references.elgb_override_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_elgb_ovr_pkg.get_pk_for_validation (
                new_references.elgb_override_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

  IGS_EN_ELGB_OVR_UOO_PKG.GET_FK_IGS_EN_ELGB_OVR_STEP(
  			old_references.elgb_ovr_step_id      );

  END Check_Child_Existance;

  FUNCTION get_pk_for_validation (
    x_elgb_ovr_step_id                  IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 29-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_elgb_ovr_step
      WHERE    elgb_ovr_step_id = x_elgb_ovr_step_id
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
    x_step_override_type                IN     VARCHAR2,
    x_elgb_override_id                  IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 29-JUN-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        06-JUL-2001    Handled Null columns which is a part of unique index
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_elgb_ovr_step
      WHERE    step_override_type = x_step_override_type
      AND      elgb_override_id = x_elgb_override_id
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


  PROCEDURE get_fk_igs_en_elgb_ovr (
    x_elgb_override_id                  IN     NUMBER
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 29-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_elgb_ovr_step
      WHERE   ((elgb_override_id = x_elgb_override_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_EOS_EOA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_elgb_ovr;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_elgb_ovr_step_id                  IN     NUMBER      ,
    x_elgb_override_id                  IN     NUMBER      ,
    x_step_override_type                IN     VARCHAR2    ,
    x_step_override_dt                  IN     DATE        ,
    x_step_override_limit               IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 29-JUN-2001
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
      x_elgb_ovr_step_id,
      x_elgb_override_id,
      x_step_override_type,
      x_step_override_dt,
      x_step_override_limit,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.elgb_ovr_step_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
	  Check_Child_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
	  Check_Child_Existance	  ;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.elgb_ovr_step_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'DELETE') THEN
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_elgb_ovr_step_id                  IN OUT NOCOPY NUMBER,
    x_elgb_override_id                  IN     NUMBER,
    x_step_override_type                IN     VARCHAR2,
    x_step_override_dt                  IN     DATE,
    x_step_override_limit               IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 29-JUN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_en_elgb_ovr_step
      WHERE    elgb_ovr_step_id                  = x_elgb_ovr_step_id;

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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igs_en_elgb_ovr_step_s.NEXTVAL
    INTO      x_elgb_ovr_step_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_elgb_ovr_step_id                  => x_elgb_ovr_step_id,
      x_elgb_override_id                  => x_elgb_override_id,
      x_step_override_type                => x_step_override_type,
      x_step_override_dt                  => x_step_override_dt,
      x_step_override_limit               => x_step_override_limit,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_elgb_ovr_step (
      elgb_ovr_step_id,
      elgb_override_id,
      step_override_type,
      step_override_dt,
      step_override_limit,
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
      new_references.elgb_ovr_step_id,
      new_references.elgb_override_id,
      new_references.step_override_type,
      new_references.step_override_dt,
      new_references.step_override_limit,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
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
    x_elgb_ovr_step_id                  IN     NUMBER,
    x_elgb_override_id                  IN     NUMBER,
    x_step_override_type                IN     VARCHAR2,
    x_step_override_dt                  IN     DATE,
    x_step_override_limit               IN     NUMBER
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 29-JUN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        elgb_override_id,
        step_override_type,
        step_override_dt,
        step_override_limit
      FROM  igs_en_elgb_ovr_step
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
        (tlinfo.elgb_override_id = x_elgb_override_id)
        AND (tlinfo.step_override_type = x_step_override_type)
        AND (tlinfo.step_override_dt = x_step_override_dt)
        AND ((tlinfo.step_override_limit = x_step_override_limit)
        OR ((tlinfo.step_override_limit IS NULL) AND (X_step_override_limit IS NULL)))
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
    x_elgb_ovr_step_id                  IN     NUMBER,
    x_elgb_override_id                  IN     NUMBER,
    x_step_override_type                IN     VARCHAR2,
    x_step_override_dt                  IN     DATE,
    x_step_override_limit               IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 29-JUN-2001
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
      x_elgb_ovr_step_id                  => x_elgb_ovr_step_id,
      x_elgb_override_id                  => x_elgb_override_id,
      x_step_override_type                => x_step_override_type,
      x_step_override_dt                  => x_step_override_dt,
      x_step_override_limit               => x_step_override_limit,
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

    UPDATE igs_en_elgb_ovr_step
      SET
        elgb_override_id                  = new_references.elgb_override_id,
        step_override_type                = new_references.step_override_type,
        step_override_dt                  = new_references.step_override_dt,
        step_override_limit               = new_references.step_override_limit,
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
    x_elgb_ovr_step_id                  IN OUT NOCOPY NUMBER,
    x_elgb_override_id                  IN     NUMBER,
    x_step_override_type                IN     VARCHAR2,
    x_step_override_dt                  IN     DATE,
    x_step_override_limit               IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 29-JUN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_elgb_ovr_step
      WHERE    elgb_ovr_step_id                  = x_elgb_ovr_step_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_elgb_ovr_step_id,
        x_elgb_override_id,
        x_step_override_type,
        x_step_override_dt,
        x_step_override_limit,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_elgb_ovr_step_id,
      x_elgb_override_id,
      x_step_override_type,
      x_step_override_dt,
      x_step_override_limit,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 29-JUN-2001
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

    DELETE FROM igs_en_elgb_ovr_step
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_en_elgb_ovr_step_pkg;

/
