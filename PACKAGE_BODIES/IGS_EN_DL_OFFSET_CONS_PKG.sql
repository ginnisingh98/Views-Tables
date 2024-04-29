--------------------------------------------------------
--  DDL for Package Body IGS_EN_DL_OFFSET_CONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_DL_OFFSET_CONS_PKG" AS
/* $Header: IGSEI45B.pls 120.0 2005/06/01 23:46:34 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_dl_offset_cons%ROWTYPE;
  new_references igs_en_dl_offset_cons%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_enr_dl_offset_cons_id             IN     NUMBER      DEFAULT NULL,
    x_offset_cons_type_cd               IN     VARCHAR2    DEFAULT NULL,
    x_constraint_condition              IN     VARCHAR2    DEFAULT NULL,
    x_constraint_resolution             IN     NUMBER      DEFAULT NULL,
    x_non_std_usec_dls_id               IN     NUMBER      DEFAULT NULL,
    x_deadline_type                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_DL_OFFSET_CONS
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
    new_references.enr_dl_offset_cons_id             := x_enr_dl_offset_cons_id;
    new_references.offset_cons_type_cd               := x_offset_cons_type_cd;
    new_references.constraint_condition              := x_constraint_condition;
    new_references.constraint_resolution             := x_constraint_resolution;
    new_references.non_std_usec_dls_id               := x_non_std_usec_dls_id;
    new_references.deadline_type                     := x_deadline_type;

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
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.offset_cons_type_cd,
           new_references.non_std_usec_dls_id,
           new_references.deadline_type
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_constraints(
				Column_Name 	IN	VARCHAR2	DEFAULT NULL,
				Column_Value 	IN	VARCHAR2	DEFAULT NULL) IS
    l_c_col_name VARCHAR2(30);
  BEGIN
        l_c_col_name := UPPER(Column_Name);
        IF l_c_col_name IS NULL THEN
                NULL;
        ELSIF l_c_col_name ='DEADLINE_TYPE' THEN
                new_references.deadline_type := Column_Value;
        ELSIF l_c_col_name ='CONSTRAINT_RESOLUTION' THEN
                new_references.constraint_resolution := Column_Value;
        END IF;

        IF l_c_col_name = 'DEADLINE_TYPE' OR Column_Name IS NULL THEN

                IF new_references.deadline_type NOT IN ( 'E' , 'R' ) THEN
                   fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
                   IGS_GE_MSG_STACK.ADD;
                   app_exception.raise_exception;
                END IF;

        END IF;

        IF l_c_col_name='CONSTRAINT_RESOLUTION' OR Column_Name IS NULL THEN
                IF new_references.constraint_resolution < -7 OR
                   new_references.constraint_resolution > 7  OR
                   new_references.constraint_resolution = 0  THEN
                   fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
                   IGS_GE_MSG_STACK.ADD;
                   app_exception.raise_exception;
                END IF;
        END IF;

  END check_constraints;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.non_std_usec_dls_id = new_references.non_std_usec_dls_id)) OR
        ((new_references.non_std_usec_dls_id IS NULL))) THEN
      NULL;
    ELSIF (new_references.deadline_type='E' AND   (NOT igs_en_nsu_dlstp_pkg.get_pk_for_validation (
                new_references.non_std_usec_dls_id
              ))) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    ELSIF (new_references.deadline_type='R' AND   (NOT igs_ps_nsus_rtn_pkg.get_pk_for_validation (
                new_references.non_std_usec_dls_id
              ))) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_enr_dl_offset_cons_id             IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_dl_offset_cons
      WHERE    enr_dl_offset_cons_id = x_enr_dl_offset_cons_id
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
    x_offset_cons_type_cd               IN     VARCHAR2,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_deadline_type                     IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_dl_offset_cons
      WHERE    offset_cons_type_cd = x_offset_cons_type_cd
      AND      non_std_usec_dls_id = x_non_std_usec_dls_id
      AND      deadline_type = x_deadline_type
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


  PROCEDURE get_fk_igs_en_nsu_dlstp_all (
    x_non_std_usec_dls_id               IN     NUMBER
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_dl_offset_cons
      WHERE   non_std_usec_dls_id = x_non_std_usec_dls_id
      AND     deadline_type = 'E' ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_DOSC_NSUD_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_nsu_dlstp_all;

  PROCEDURE get_fk_igs_ps_nsus_rtn (
    x_non_std_usec_dls_id               IN     NUMBER
    ) AS
    /*
    ||  Created By : Bhawani.Devarakonda@Oracle.com
    ||  Created On : 30-MAR-2001
    ||  Purpose : Validates the Foreign Keys for the table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */
    CURSOR cur_rowid IS
        SELECT   rowid
        FROM     igs_en_dl_offset_cons
        WHERE   non_std_usec_dls_id = x_non_std_usec_dls_id
        AND     DEADLINE_TYPE = 'R';

        lv_rowid cur_rowid%RowType;
  BEGIN

      OPEN cur_rowid;
      FETCH cur_rowid INTO lv_rowid;
      IF (cur_rowid%FOUND) THEN
        CLOSE cur_rowid;
        fnd_message.set_name ('IGS', 'IGS_EN_DOSC_NR_FK');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
        RETURN;
      END IF;
      CLOSE cur_rowid;

  END get_fk_igs_ps_nsus_rtn;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_enr_dl_offset_cons_id             IN     NUMBER      DEFAULT NULL,
    x_offset_cons_type_cd               IN     VARCHAR2    DEFAULT NULL,
    x_constraint_condition              IN     VARCHAR2    DEFAULT NULL,
    x_constraint_resolution             IN     NUMBER      DEFAULT NULL,
    x_non_std_usec_dls_id               IN     NUMBER      DEFAULT NULL,
    x_deadline_type                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
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
      x_enr_dl_offset_cons_id,
      x_offset_cons_type_cd,
      x_constraint_condition,
      x_constraint_resolution,
      x_non_std_usec_dls_id,
      x_deadline_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.enr_dl_offset_cons_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.enr_dl_offset_cons_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_constraints;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_enr_dl_offset_cons_id             IN OUT NOCOPY NUMBER,
    x_offset_cons_type_cd               IN     VARCHAR2,
    x_constraint_condition              IN     VARCHAR2,
    x_constraint_resolution             IN     NUMBER,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_deadline_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_en_dl_offset_cons
      WHERE    enr_dl_offset_cons_id             = x_enr_dl_offset_cons_id;

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

    SELECT    igs_en_dl_offset_cons_s.NEXTVAL
    INTO      x_enr_dl_offset_cons_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_enr_dl_offset_cons_id             => x_enr_dl_offset_cons_id,
      x_offset_cons_type_cd               => x_offset_cons_type_cd,
      x_constraint_condition              => x_constraint_condition,
      x_constraint_resolution             => x_constraint_resolution,
      x_non_std_usec_dls_id               => x_non_std_usec_dls_id,
      x_deadline_type                     => x_deadline_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_dl_offset_cons (
      enr_dl_offset_cons_id,
      offset_cons_type_cd,
      constraint_condition,
      constraint_resolution,
      non_std_usec_dls_id,
      deadline_type,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.enr_dl_offset_cons_id,
      new_references.offset_cons_type_cd,
      new_references.constraint_condition,
      new_references.constraint_resolution,
      new_references.non_std_usec_dls_id,
      new_references.deadline_type,
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
    x_enr_dl_offset_cons_id             IN     NUMBER,
    x_offset_cons_type_cd               IN     VARCHAR2,
    x_constraint_condition              IN     VARCHAR2,
    x_constraint_resolution             IN     NUMBER,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_deadline_type                     IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        offset_cons_type_cd,
        constraint_condition,
        constraint_resolution,
        non_std_usec_dls_id,
        deadline_type
      FROM  igs_en_dl_offset_cons
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
        (tlinfo.offset_cons_type_cd = x_offset_cons_type_cd)
        AND (tlinfo.constraint_condition = x_constraint_condition)
        AND (tlinfo.constraint_resolution = x_constraint_resolution)
        AND (tlinfo.non_std_usec_dls_id = x_non_std_usec_dls_id)
        AND (tlinfo.deadline_type = x_deadline_type)
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
    x_enr_dl_offset_cons_id             IN     NUMBER,
    x_offset_cons_type_cd               IN     VARCHAR2,
    x_constraint_condition              IN     VARCHAR2,
    x_constraint_resolution             IN     NUMBER,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_deadline_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
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
      x_enr_dl_offset_cons_id             => x_enr_dl_offset_cons_id,
      x_offset_cons_type_cd               => x_offset_cons_type_cd,
      x_constraint_condition              => x_constraint_condition,
      x_constraint_resolution             => x_constraint_resolution,
      x_non_std_usec_dls_id               => x_non_std_usec_dls_id,
      x_deadline_type                     => x_deadline_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_en_dl_offset_cons
      SET
        offset_cons_type_cd               = new_references.offset_cons_type_cd,
        constraint_condition              = new_references.constraint_condition,
        constraint_resolution             = new_references.constraint_resolution,
        non_std_usec_dls_id               = new_references.non_std_usec_dls_id,
        deadline_type                     = new_references.deadline_type,
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
    x_enr_dl_offset_cons_id             IN OUT NOCOPY NUMBER,
    x_offset_cons_type_cd               IN     VARCHAR2,
    x_constraint_condition              IN     VARCHAR2,
    x_constraint_resolution             IN     NUMBER,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_deadline_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_dl_offset_cons
      WHERE    enr_dl_offset_cons_id             = x_enr_dl_offset_cons_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_enr_dl_offset_cons_id,
        x_offset_cons_type_cd,
        x_constraint_condition,
        x_constraint_resolution,
        x_non_std_usec_dls_id,
        x_deadline_type,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_enr_dl_offset_cons_id,
      x_offset_cons_type_cd,
      x_constraint_condition,
      x_constraint_resolution,
      x_non_std_usec_dls_id,
      x_deadline_type,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
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

    DELETE FROM igs_en_dl_offset_cons
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_en_dl_offset_cons_pkg;

/
