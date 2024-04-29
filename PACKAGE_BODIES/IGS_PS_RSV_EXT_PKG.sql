--------------------------------------------------------
--  DDL for Package Body IGS_PS_RSV_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_RSV_EXT_PKG" AS
/* $Header: IGSPI2WB.pls 115.8 2003/02/19 13:58:38 shtatiko ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ps_rsv_ext%ROWTYPE;
  new_references igs_ps_rsv_ext%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_rsv_ext_id                        IN     NUMBER      ,
    x_uoo_id                            IN     NUMBER      ,
    x_priority_id                       IN     NUMBER      ,
    x_preference_id                     IN     NUMBER      ,
    x_rsv_level                         IN     VARCHAR2    ,
    x_actual_seat_enrolled              IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-JUN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_RSV_EXT
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
    new_references.rsv_ext_id                        := x_rsv_ext_id;
    new_references.uoo_id                            := x_uoo_id;
    new_references.priority_id                       := x_priority_id;
    new_references.preference_id                     := x_preference_id;
    new_references.rsv_level                         := x_rsv_level;
    new_references.actual_seat_enrolled              := x_actual_seat_enrolled;

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
  ||  Created By :
  ||  Created On : 28-JUN-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.uoo_id,
           new_references.priority_id,
           new_references.preference_id,
           new_references.rsv_level
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By :
  ||  Created On : 28-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ofr_opt_pkg.get_uk_For_validation (
                new_references.uoo_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_rsv_ext_id                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 28-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  shtatiko        18-FEB-2003     Enh# 2797116, Removed FOR UPDATE NOWAIT
  ||                                  clause from the cursor, cur_rowid.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_rsv_ext
      WHERE    rsv_ext_id = x_rsv_ext_id ;

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
    x_uoo_id                            IN     NUMBER,
    x_priority_id                       IN     NUMBER,
    x_preference_id                     IN     NUMBER,
    x_rsv_level                         IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 28-JUN-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_rsv_ext
      WHERE    uoo_id = x_uoo_id
      AND      priority_id = x_priority_id
      AND      preference_id = x_preference_id
      AND      rsv_level = x_rsv_level
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


  PROCEDURE get_ufk_igs_ps_unit_ofr_opt(
    x_uoo_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_rsv_ext
      WHERE   ((uoo_id = x_uoo_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_RSE_UOO_UFK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ps_unit_ofr_opt;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_rsv_ext_id                        IN     NUMBER      ,
    x_uoo_id                            IN     NUMBER      ,
    x_priority_id                       IN     NUMBER      ,
    x_preference_id                     IN     NUMBER      ,
    x_rsv_level                         IN     VARCHAR2    ,
    x_actual_seat_enrolled              IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-JUN-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  shtatiko        18-FEB-2003     Enh# 2797116, Removed cases of
  ||                                  p_action = 'DELETE' and 'VALIDATE_DELETE'.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_rsv_ext_id,
      x_uoo_id,
      x_priority_id,
      x_preference_id,
      x_rsv_level,
      x_actual_seat_enrolled,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.rsv_ext_id
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
             new_references.rsv_ext_id
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
    x_rsv_ext_id                        IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_priority_id                       IN     NUMBER,
    x_preference_id                     IN     NUMBER,
    x_rsv_level                         IN     VARCHAR2,
    x_actual_seat_enrolled              IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-JUN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ps_rsv_ext
      WHERE    rsv_ext_id                        = x_rsv_ext_id;

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

    SELECT    igs_ps_rsv_ext_s.NEXTVAL
    INTO      x_rsv_ext_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_rsv_ext_id                        => x_rsv_ext_id,
      x_uoo_id                            => x_uoo_id,
      x_priority_id                       => x_priority_id,
      x_preference_id                     => x_preference_id,
      x_rsv_level                         => x_rsv_level,
      x_actual_seat_enrolled              => x_actual_seat_enrolled,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ps_rsv_ext (
      rsv_ext_id,
      uoo_id,
      priority_id,
      preference_id,
      rsv_level,
      actual_seat_enrolled,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.rsv_ext_id,
      new_references.uoo_id,
      new_references.priority_id,
      new_references.preference_id,
      new_references.rsv_level,
      new_references.actual_seat_enrolled,
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
    x_rsv_ext_id                        IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_priority_id                       IN     NUMBER,
    x_preference_id                     IN     NUMBER,
    x_rsv_level                         IN     VARCHAR2,
    x_actual_seat_enrolled              IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-JUN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        uoo_id,
        priority_id,
        preference_id,
        rsv_level,
        actual_seat_enrolled
      FROM  igs_ps_rsv_ext
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
        (tlinfo.uoo_id = x_uoo_id)
        AND (tlinfo.priority_id = x_priority_id)
        AND (tlinfo.preference_id = x_preference_id)
        AND (tlinfo.rsv_level = x_rsv_level)
        AND (tlinfo.actual_seat_enrolled = x_actual_seat_enrolled)
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
    x_rsv_ext_id                        IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_priority_id                       IN     NUMBER,
    x_preference_id                     IN     NUMBER,
    x_rsv_level                         IN     VARCHAR2,
    x_actual_seat_enrolled              IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-JUN-2001
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
      x_rsv_ext_id                        => x_rsv_ext_id,
      x_uoo_id                            => x_uoo_id,
      x_priority_id                       => x_priority_id,
      x_preference_id                     => x_preference_id,
      x_rsv_level                         => x_rsv_level,
      x_actual_seat_enrolled              => x_actual_seat_enrolled,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ps_rsv_ext
      SET
        uoo_id                            = new_references.uoo_id,
        priority_id                       = new_references.priority_id,
        preference_id                     = new_references.preference_id,
        rsv_level                         = new_references.rsv_level,
        actual_seat_enrolled              = new_references.actual_seat_enrolled,
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
    x_rsv_ext_id                        IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_priority_id                       IN     NUMBER,
    x_preference_id                     IN     NUMBER,
    x_rsv_level                         IN     VARCHAR2,
    x_actual_seat_enrolled              IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 28-JUN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ps_rsv_ext
      WHERE    rsv_ext_id                        = x_rsv_ext_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_rsv_ext_id,
        x_uoo_id,
        x_priority_id,
        x_preference_id,
        x_rsv_level,
        x_actual_seat_enrolled,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_rsv_ext_id,
      x_uoo_id,
      x_priority_id,
      x_preference_id,
      x_rsv_level,
      x_actual_seat_enrolled,
      x_mode
    );

  END add_row;

END igs_ps_rsv_ext_pkg;

/
