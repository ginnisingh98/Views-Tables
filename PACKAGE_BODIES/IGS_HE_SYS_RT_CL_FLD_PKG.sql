--------------------------------------------------------
--  DDL for Package Body IGS_HE_SYS_RT_CL_FLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_SYS_RT_CL_FLD_PKG" AS
/* $Header: IGSWI14B.pls 120.1 2006/02/06 21:06:34 anwest noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_sys_rt_cl_fld%ROWTYPE;
  new_references igs_he_sys_rt_cl_fld%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_system_return_class_type          IN     VARCHAR2    ,
    x_field_number                      IN     NUMBER      ,
    x_field_name                        IN     VARCHAR2    ,
    x_field_description                 IN     VARCHAR2    ,
    x_datatype                          IN     VARCHAR2    ,
    x_length                            IN     NUMBER      ,
    x_mandatory_flag                    IN     VARCHAR2    ,
    x_closed_flag                       IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_SYS_RT_CL_FLD
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
    new_references.system_return_class_type          := x_system_return_class_type;
    new_references.field_number                      := x_field_number;
    new_references.field_name                        := x_field_name;
    new_references.field_description                 := x_field_description;
    new_references.datatype                          := x_datatype;
    new_references.length                            := x_length;
    new_references.mandatory_flag                    := x_mandatory_flag;
    new_references.closed_flag                       := x_closed_flag;

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


  PROCEDURE check_child_existance IS
    /*
    ||  Created By : ANWEST Oracle ADC
    ||  Created On : 09-JAN-2006
    ||  Purpose : Checks for the existance of Child records.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  ANWEST          09-JAN-2006     Changes as per HE305
    */
    BEGIN

      igs_he_sys_rt_cl_ass_pkg.get_fk_igs_he_sys_rt_cl_fld (
        old_references.system_return_class_type,
        old_references.field_number
        );

    END check_child_existance;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.system_return_class_type = new_references.system_return_class_type)) OR
        ((new_references.system_return_class_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_he_sys_rtn_clas_seed_pkg.get_pk_for_validation (
                new_references.system_return_class_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_sys_rt_cl_fld
      WHERE    system_return_class_type = x_system_return_class_type
      AND      field_number = x_field_number
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


  PROCEDURE get_fk_igs_he_sys_rtn_clas (
    x_system_return_class_type          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_sys_rt_cl_fld
      WHERE   ((system_return_class_type = x_system_return_class_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HESRCFD_HESRCD_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_he_sys_rtn_clas;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_system_return_class_type          IN     VARCHAR2    ,
    x_field_number                      IN     NUMBER      ,
    x_field_name                        IN     VARCHAR2    ,
    x_field_description                 IN     VARCHAR2    ,
    x_datatype                          IN     VARCHAR2    ,
    x_length                            IN     NUMBER      ,
    x_mandatory_flag                    IN     VARCHAR2    ,
    x_closed_flag                       IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
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
      x_system_return_class_type,
      x_field_number,
      x_field_name,
      x_field_description,
      x_datatype,
      x_length,
      x_mandatory_flag,
      x_closed_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.system_return_class_type,
             new_references.field_number
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
             new_references.system_return_class_type,
             new_references.field_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_field_name                        IN     VARCHAR2,
    x_field_description                 IN     VARCHAR2,
    x_datatype                          IN     VARCHAR2,
    x_length                            IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_sys_rt_cl_fld
      WHERE    system_return_class_type          = x_system_return_class_type
      AND      field_number                      = x_field_number;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_system_return_class_type          => x_system_return_class_type,
      x_field_number                      => x_field_number,
      x_field_name                        => x_field_name,
      x_field_description                 => x_field_description,
      x_datatype                          => x_datatype,
      x_length                            => x_length,
      x_mandatory_flag                    => x_mandatory_flag,
      x_closed_flag                       => x_closed_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_he_sys_rt_cl_fld (
      system_return_class_type,
      field_number,
      field_name,
      field_description,
      datatype,
      length,
      mandatory_flag,
      closed_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.system_return_class_type,
      new_references.field_number,
      new_references.field_name,
      new_references.field_description,
      new_references.datatype,
      new_references.length,
      new_references.mandatory_flag,
      new_references.closed_flag,
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
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_field_name                        IN     VARCHAR2,
    x_field_description                 IN     VARCHAR2,
    x_datatype                          IN     VARCHAR2,
    x_length                            IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        field_name,
        field_description,
        datatype,
        length,
        mandatory_flag,
        closed_flag
      FROM  igs_he_sys_rt_cl_fld
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
        (tlinfo.field_name = x_field_name)
        AND (tlinfo.field_description = x_field_description)
        AND (tlinfo.datatype = x_datatype)
        AND (tlinfo.length = x_length)
        AND (tlinfo.mandatory_flag = x_mandatory_flag)
        AND (tlinfo.closed_flag = x_closed_flag)
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
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_field_name                        IN     VARCHAR2,
    x_field_description                 IN     VARCHAR2,
    x_datatype                          IN     VARCHAR2,
    x_length                            IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
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
      x_system_return_class_type          => x_system_return_class_type,
      x_field_number                      => x_field_number,
      x_field_name                        => x_field_name,
      x_field_description                 => x_field_description,
      x_datatype                          => x_datatype,
      x_length                            => x_length,
      x_mandatory_flag                    => x_mandatory_flag,
      x_closed_flag                       => x_closed_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_he_sys_rt_cl_fld
      SET
        field_name                        = new_references.field_name,
        field_description                 = new_references.field_description,
        datatype                          = new_references.datatype,
        length                            = new_references.length,
        mandatory_flag                    = new_references.mandatory_flag,
        closed_flag                       = new_references.closed_flag,
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
    x_system_return_class_type          IN     VARCHAR2,
    x_field_number                      IN     NUMBER,
    x_field_name                        IN     VARCHAR2,
    x_field_description                 IN     VARCHAR2,
    x_datatype                          IN     VARCHAR2,
    x_length                            IN     NUMBER,
    x_mandatory_flag                    IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_sys_rt_cl_fld
      WHERE    system_return_class_type          = x_system_return_class_type
      AND      field_number                      = x_field_number;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_system_return_class_type,
        x_field_number,
        x_field_name,
        x_field_description,
        x_datatype,
        x_length,
        x_mandatory_flag,
        x_closed_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_system_return_class_type,
      x_field_number,
      x_field_name,
      x_field_description,
      x_datatype,
      x_length,
      x_mandatory_flag,
      x_closed_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
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

    DELETE FROM igs_he_sys_rt_cl_fld
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_sys_rt_cl_fld_pkg;

/
