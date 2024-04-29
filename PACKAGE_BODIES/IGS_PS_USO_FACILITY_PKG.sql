--------------------------------------------------------
--  DDL for Package Body IGS_PS_USO_FACILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_USO_FACILITY_PKG" AS
/* $Header: IGSPI2OB.pls 120.1 2005/06/29 03:27:25 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ps_uso_facility%ROWTYPE;
  new_references igs_ps_uso_facility%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_uso_facility_id                   IN     NUMBER      DEFAULT NULL,
    x_unit_section_occurrence_id        IN     NUMBER      DEFAULT NULL,
    x_facility_code                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
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
      FROM     IGS_PS_USO_FACILITY
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
    new_references.uso_facility_id                   := x_uso_facility_id;
    new_references.unit_section_occurrence_id        := x_unit_section_occurrence_id;
    new_references.facility_code                     := x_facility_code;

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
           new_references.unit_section_occurrence_id,
           new_references.facility_code
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

    IF (((old_references.unit_section_occurrence_id = new_references.unit_section_occurrence_id)) OR
        ((new_references.unit_section_occurrence_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_usec_occurs_pkg.get_pk_for_validation (
                new_references.unit_section_occurrence_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.facility_code = new_references.facility_code)) OR
        ((new_references.facility_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_media_equip_pkg.get_pk_for_validation (
                new_references.facility_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_uso_facility_id                   IN     NUMBER
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
      FROM     igs_ps_uso_facility
      WHERE    uso_facility_id = x_uso_facility_id
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
    x_unit_section_occurrence_id        IN     NUMBER,
    x_facility_code                     IN     VARCHAR2
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
      FROM     igs_ps_uso_facility
      WHERE    unit_section_occurrence_id = x_unit_section_occurrence_id
      AND      facility_code = x_facility_code
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


  PROCEDURE get_fk_igs_ps_usec_occurs (
    x_unit_section_occurrence_id        IN     NUMBER
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
      FROM     igs_ps_uso_facility
      WHERE   ((unit_section_occurrence_id = x_unit_section_occurrence_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_USO_USOF_FK1');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_usec_occurs;


  PROCEDURE get_fk_igs_ps_media_equip (
    x_media_code                        IN     VARCHAR2
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
      FROM     igs_ps_uso_facility
      WHERE   ((facility_code = x_media_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_ME_USOF_FK2');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_media_equip;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_uso_facility_id                   IN     NUMBER      DEFAULT NULL,
    x_unit_section_occurrence_id        IN     NUMBER      DEFAULT NULL,
    x_facility_code                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
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
      x_uso_facility_id,
      x_unit_section_occurrence_id,
      x_facility_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.uso_facility_id
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
             new_references.uso_facility_id
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

    l_rowid:=NULL;

  END before_dml;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : sarakshi
  Date Created By : 12-May-2005
  Purpose : To update the scheduling status to USER_UPDATE when record is created or deleted for the occurrence
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR c_occurs(cp_unit_section_occurrence_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
    SELECT uso.unit_section_occurrence_id
    FROM igs_ps_usec_occurs_all uso
    WHERE (uso.schedule_status IS NOT NULL AND uso.schedule_status NOT IN ('PROCESSING','USER_UPDATE'))
    AND uso.no_set_day_ind ='N'
    AND uso.unit_section_occurrence_id=cp_unit_section_occurrence_id;

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      --Update the schedule status of the occurrence to USER_UPDATE if inserting a record
      FOR l_occurs_rec IN c_occurs(new_references.unit_section_occurrence_id) LOOP
        igs_ps_usec_schedule.update_occurrence_status(l_occurs_rec.unit_section_occurrence_id,'USER_UPDATE','N');
      END LOOP;

    ELSIF (p_action = 'UPDATE') THEN
      --Update the schedule status of the occurrence to USER_UPDATE if updating a record
      FOR l_occurs_rec IN c_occurs(new_references.unit_section_occurrence_id) LOOP
        igs_ps_usec_schedule.update_occurrence_status(l_occurs_rec.unit_section_occurrence_id,'USER_UPDATE','N');
      END LOOP;


    ELSIF (p_action = 'DELETE') THEN
      --Update the schedule status of the occurrence to USER_UPDATE if updating a record
      FOR l_occurs_rec IN c_occurs(old_references.unit_section_occurrence_id) LOOP
        igs_ps_usec_schedule.update_occurrence_status(l_occurs_rec.unit_section_occurrence_id,'USER_UPDATE','N');
      END LOOP;

    END IF;

    l_rowid:=NULL;
  END After_DML;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_uso_facility_id                   IN OUT NOCOPY NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_facility_code                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
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
      FROM     igs_ps_uso_facility
      WHERE    uso_facility_id                   = x_uso_facility_id;

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

    SELECT    igs_ps_uso_facility_s.NEXTVAL
    INTO      x_uso_facility_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_uso_facility_id                   => x_uso_facility_id,
      x_unit_section_occurrence_id        => x_unit_section_occurrence_id,
      x_facility_code                     => x_facility_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ps_uso_facility (
      uso_facility_id,
      unit_section_occurrence_id,
      facility_code,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.uso_facility_id,
      new_references.unit_section_occurrence_id,
      new_references.facility_code,
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

    After_DML (
                p_action => 'INSERT' ,
                x_rowid => X_ROWID );

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_uso_facility_id                   IN     NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_facility_code                     IN     VARCHAR2
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
        unit_section_occurrence_id,
        facility_code
      FROM  igs_ps_uso_facility
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
        (tlinfo.unit_section_occurrence_id = x_unit_section_occurrence_id)
        AND (tlinfo.facility_code = x_facility_code)
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
    x_uso_facility_id                   IN     NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_facility_code                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
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
      x_uso_facility_id                   => x_uso_facility_id,
      x_unit_section_occurrence_id        => x_unit_section_occurrence_id,
      x_facility_code                     => x_facility_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ps_uso_facility
      SET
        unit_section_occurrence_id        = new_references.unit_section_occurrence_id,
        facility_code                     = new_references.facility_code,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    After_DML (
                p_action => 'UPDATE' ,
                x_rowid => X_ROWID );

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_uso_facility_id                   IN OUT NOCOPY NUMBER,
    x_unit_section_occurrence_id        IN     NUMBER,
    x_facility_code                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
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
      FROM     igs_ps_uso_facility
      WHERE    uso_facility_id                   = x_uso_facility_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_uso_facility_id,
        x_unit_section_occurrence_id,
        x_facility_code,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_uso_facility_id,
      x_unit_section_occurrence_id,
      x_facility_code,
      x_mode
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

    DELETE FROM igs_ps_uso_facility
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    After_DML (
                p_action => 'DELETE' ,
                x_rowid => X_ROWID );

  END delete_row;


END igs_ps_uso_facility_pkg;

/
