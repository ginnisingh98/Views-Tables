--------------------------------------------------------
--  DDL for Package Body IGS_PS_USO_CM_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_USO_CM_GRP_PKG" AS
/* $Header: IGSPI2NB.pls 115.4 2002/11/29 02:18:20 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ps_uso_cm_grp%ROWTYPE;
  new_references igs_ps_uso_cm_grp%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_class_meet_group_id               IN     NUMBER      ,
    x_class_meet_group_name             IN     VARCHAR2    ,
    x_cal_type                          IN     VARCHAR2    ,
    x_ci_sequence_number                IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_max_ovr_group                     IN     NUMBER      ,
    x_max_enr_group                     IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_USO_CM_GRP
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
    new_references.class_meet_group_id               := x_class_meet_group_id;
    new_references.class_meet_group_name             := x_class_meet_group_name;
    new_references.cal_type                          := x_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.max_ovr_group                     := x_max_ovr_group;
    new_references.max_enr_group                     := x_max_enr_group;

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
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.class_meet_group_name,
           new_references.cal_type,
           new_references.ci_sequence_number
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.cal_type,
                new_references.ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_ps_uso_clas_meet_pkg.get_fk_igs_ps_uso_cm_grp (
      old_references.class_meet_group_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_class_meet_group_id               IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_uso_cm_grp
      WHERE    class_meet_group_id = x_class_meet_group_id
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
    x_class_meet_group_name             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_uso_cm_grp
      WHERE    class_meet_group_name = x_class_meet_group_name
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
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


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_uso_cm_grp
      WHERE   ((cal_type = x_cal_type) AND
               (ci_sequence_number = x_ci_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_CI_CMG_FK1');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_class_meet_group_id               IN     NUMBER      ,
    x_class_meet_group_name             IN     VARCHAR2    ,
    x_cal_type                          IN     VARCHAR2    ,
    x_ci_sequence_number                IN     NUMBER      ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_max_ovr_group                     IN     NUMBER      ,
    x_max_enr_group                     IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
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
      x_class_meet_group_id,
      x_class_meet_group_name,
      x_cal_type,
      x_ci_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_max_ovr_group,
      x_max_enr_group
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.class_meet_group_id
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.class_meet_group_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_class_meet_group_id               IN OUT NOCOPY NUMBER,
    x_class_meet_group_name             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 ,
    x_max_ovr_group                     IN     NUMBER   ,
    x_max_enr_group                     IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ps_uso_cm_grp
      WHERE    class_meet_group_id               = x_class_meet_group_id;

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

    SELECT    igs_ps_uso_cm_grp_s.NEXTVAL
    INTO      x_class_meet_group_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_class_meet_group_id               => x_class_meet_group_id,
      x_class_meet_group_name             => x_class_meet_group_name,
      x_cal_type                          => x_cal_type,
      x_ci_sequence_number                   => x_ci_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_max_ovr_group                     => x_max_ovr_group,
      x_max_enr_group                     => x_max_enr_group);

    INSERT INTO igs_ps_uso_cm_grp (
      class_meet_group_id,
      class_meet_group_name,
      cal_type,
      ci_sequence_number,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      max_ovr_group,
      max_enr_group
    ) VALUES (
      new_references.class_meet_group_id,
      new_references.class_meet_group_name,
      new_references.cal_type,
      new_references.ci_sequence_number,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      new_references.max_ovr_group,
      new_references.max_enr_group
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
    x_class_meet_group_id               IN     NUMBER,
    x_class_meet_group_name             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_max_ovr_group                     IN     NUMBER   ,
    x_max_enr_group                     IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        class_meet_group_name,
        cal_type,
        ci_sequence_number,
        max_ovr_group,
        max_enr_group
      FROM  igs_ps_uso_cm_grp
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
        (tlinfo.class_meet_group_name = x_class_meet_group_name)
        AND (tlinfo.cal_type = x_cal_type)
        AND (tlinfo.ci_sequence_number = x_ci_sequence_number)
        AND ((tlinfo.max_ovr_group= x_max_ovr_group)
            OR ((tlinfo.max_ovr_group IS NULL)
                 AND (X_max_ovr_group IS NULL)))
        AND ((tlinfo.max_enr_group= x_max_enr_group)
            OR ((tlinfo.max_enr_group IS NULL)
                 AND (X_max_enr_group IS NULL)))
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
    x_class_meet_group_id               IN     NUMBER,
    x_class_meet_group_name             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 ,
    x_max_ovr_group                     IN     NUMBER   ,
    x_max_enr_group                     IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
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
      x_class_meet_group_id               => x_class_meet_group_id,
      x_class_meet_group_name             => x_class_meet_group_name,
      x_cal_type                          => x_cal_type,
      x_ci_sequence_number                   => x_ci_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_max_ovr_group                     => x_max_ovr_group,
      x_max_enr_group                     => x_max_enr_group);

    UPDATE igs_ps_uso_cm_grp
      SET
        class_meet_group_name             = new_references.class_meet_group_name,
        cal_type                          = new_references.cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        max_ovr_group                     = new_references.max_ovr_group,
        max_enr_group                     = new_references.max_enr_group
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_class_meet_group_id               IN OUT NOCOPY NUMBER,
    x_class_meet_group_name             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_max_ovr_group                     IN     NUMBER   ,
    x_max_enr_group                     IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ps_uso_cm_grp
      WHERE    class_meet_group_id               = x_class_meet_group_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_class_meet_group_id,
        x_class_meet_group_name,
        x_cal_type,
        x_ci_sequence_number,
        x_mode,
        x_max_ovr_group,
        x_max_enr_group
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_class_meet_group_id,
      x_class_meet_group_name,
      x_cal_type,
      x_ci_sequence_number,
      x_mode,
      x_max_ovr_group,
      x_max_enr_group
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
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

    DELETE FROM igs_ps_uso_cm_grp
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ps_uso_cm_grp_pkg;

/
