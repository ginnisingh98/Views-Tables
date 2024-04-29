--------------------------------------------------------
--  DDL for Package Body IGS_AS_INC_GRD_CPROF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_INC_GRD_CPROF_PKG" AS
/* $Header: IGSDI56B.pls 115.6 2002/11/28 23:24:49 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_as_inc_grd_cprof%ROWTYPE;
  new_references igs_as_inc_grd_cprof%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_inc_grd_cprof_id                  IN     NUMBER      DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_incomplete_grade                  IN     VARCHAR2    DEFAULT NULL,
    x_number_unit_time                  IN     NUMBER      DEFAULT NULL,
    x_type_unit_time                    IN     VARCHAR2    DEFAULT NULL,
    x_comp_after_dt_alias               IN     VARCHAR2    DEFAULT NULL,
    x_default_grade                     IN     VARCHAR2    DEFAULT NULL,
    x_default_mark                      IN     NUMBER      DEFAULT NULL,
    x_instructor_update_ind             IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_INC_GRD_CPROF
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
    new_references.inc_grd_cprof_id                  := x_inc_grd_cprof_id;
    new_references.grading_schema_cd                 := x_grading_schema_cd;
    new_references.version_number                    := x_version_number;
    new_references.org_unit_cd                       := x_org_unit_cd;
    new_references.incomplete_grade                  := x_incomplete_grade;
    new_references.number_unit_time                  := x_number_unit_time;
    new_references.type_unit_time                    := x_type_unit_time;
    new_references.comp_after_dt_alias               := x_comp_after_dt_alias;
    new_references.default_grade                     := x_default_grade;
    new_references.default_mark                      := x_default_mark;
    new_references.instructor_update_ind             := x_instructor_update_ind;

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
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.version_number,
           new_references.grading_schema_cd,
           new_references.org_unit_cd,
           new_references.incomplete_grade
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.default_grade = new_references.default_grade)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.default_grade IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_grd_sch_grade_pkg.get_pk_for_validation (
                new_references.grading_schema_cd,
                new_references.version_number,
                new_references.default_grade
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.incomplete_grade = new_references.incomplete_grade)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.incomplete_grade IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_grd_sch_grade_pkg.get_pk_for_validation (
                new_references.grading_schema_cd,
                new_references.version_number,
                new_references.incomplete_grade
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.comp_after_dt_alias = new_references.comp_after_dt_alias)) OR
        ((new_references.comp_after_dt_alias IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_da_pkg.get_pk_for_validation (
                new_references.comp_after_dt_alias
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_grd_schema_pkg.get_pk_for_validation (
                new_references.grading_schema_cd,
                new_references.version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_inc_grd_cprof_id                  IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_inc_grd_cprof
      WHERE    inc_grd_cprof_id = x_inc_grd_cprof_id
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
    x_version_number                    IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_incomplete_grade                  IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_inc_grd_cprof
      WHERE    version_number = x_version_number
      AND      grading_schema_cd = x_grading_schema_cd
      AND      org_unit_cd = x_org_unit_cd
      AND      incomplete_grade = x_incomplete_grade
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


  PROCEDURE get_fk_igs_as_grd_sch_grade (
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_grade                             IN     VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_inc_grd_cprof
      WHERE   ((default_grade = x_grade) AND
               (grading_schema_cd = x_grading_schema_cd) AND
               (version_number = x_version_number))
      OR      ((grading_schema_cd = x_grading_schema_cd) AND
               (incomplete_grade = x_grade) AND
               (version_number = x_version_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AS_IGCP_CSG_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_as_grd_sch_grade;


  PROCEDURE get_fk_igs_ca_da (
    x_dt_alias                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_inc_grd_cprof
      WHERE   ((comp_after_dt_alias = x_dt_alias));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AS_IGCP_DA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_da;


  PROCEDURE get_fk_igs_as_grd_schema (
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_inc_grd_cprof
      WHERE   ((grading_schema_cd = x_grading_schema_cd) AND
               (version_number = x_version_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AS_IGCP_GS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_as_grd_schema;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_inc_grd_cprof_id                  IN     NUMBER      DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_incomplete_grade                  IN     VARCHAR2    DEFAULT NULL,
    x_number_unit_time                  IN     NUMBER      DEFAULT NULL,
    x_type_unit_time                    IN     VARCHAR2    DEFAULT NULL,
    x_comp_after_dt_alias               IN     VARCHAR2    DEFAULT NULL,
    x_default_grade                     IN     VARCHAR2    DEFAULT NULL,
    x_default_mark                      IN     NUMBER      DEFAULT NULL,
    x_instructor_update_ind             IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
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
      x_inc_grd_cprof_id,
      x_grading_schema_cd,
      x_version_number,
      x_org_unit_cd,
      x_incomplete_grade,
      x_number_unit_time,
      x_type_unit_time,
      x_comp_after_dt_alias,
      x_default_grade,
      x_default_mark,
      x_instructor_update_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.inc_grd_cprof_id
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
             new_references.inc_grd_cprof_id
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
    x_inc_grd_cprof_id                  IN OUT NOCOPY NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_incomplete_grade                  IN     VARCHAR2,
    x_number_unit_time                  IN     NUMBER,
    x_type_unit_time                    IN     VARCHAR2,
    x_comp_after_dt_alias               IN     VARCHAR2,
    x_default_grade                     IN     VARCHAR2,
    x_default_mark                      IN     NUMBER,
    x_instructor_update_ind             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_as_inc_grd_cprof
      WHERE    inc_grd_cprof_id                  = x_inc_grd_cprof_id;

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

    SELECT    igs_as_inc_grd_cprof_s.NEXTVAL
    INTO      x_inc_grd_cprof_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_inc_grd_cprof_id                  => x_inc_grd_cprof_id,
      x_grading_schema_cd                 => x_grading_schema_cd,
      x_version_number                    => x_version_number,
      x_org_unit_cd                       => x_org_unit_cd,
      x_incomplete_grade                  => x_incomplete_grade,
      x_number_unit_time                  => x_number_unit_time,
      x_type_unit_time                    => x_type_unit_time,
      x_comp_after_dt_alias               => x_comp_after_dt_alias,
      x_default_grade                     => x_default_grade,
      x_default_mark                      => x_default_mark,
      x_instructor_update_ind             => x_instructor_update_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_as_inc_grd_cprof (
      inc_grd_cprof_id,
      grading_schema_cd,
      version_number,
      org_unit_cd,
      incomplete_grade,
      number_unit_time,
      type_unit_time,
      comp_after_dt_alias,
      default_grade,
      default_mark,
      instructor_update_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.inc_grd_cprof_id,
      new_references.grading_schema_cd,
      new_references.version_number,
      new_references.org_unit_cd,
      new_references.incomplete_grade,
      new_references.number_unit_time,
      new_references.type_unit_time,
      new_references.comp_after_dt_alias,
      new_references.default_grade,
      new_references.default_mark,
      new_references.instructor_update_ind,
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
    x_inc_grd_cprof_id                  IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_incomplete_grade                  IN     VARCHAR2,
    x_number_unit_time                  IN     NUMBER,
    x_type_unit_time                    IN     VARCHAR2,
    x_comp_after_dt_alias               IN     VARCHAR2,
    x_default_grade                     IN     VARCHAR2,
    x_default_mark                      IN     NUMBER,
    x_instructor_update_ind             IN     VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        grading_schema_cd,
        version_number,
        org_unit_cd,
        incomplete_grade,
        number_unit_time,
        type_unit_time,
        comp_after_dt_alias,
        default_grade,
        default_mark,
        instructor_update_ind
      FROM  igs_as_inc_grd_cprof
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
        (tlinfo.grading_schema_cd = x_grading_schema_cd)
        AND (tlinfo.version_number = x_version_number)
        AND ((tlinfo.org_unit_cd = x_org_unit_cd) OR ( tlinfo.org_unit_cd IS NULL AND x_org_unit_cd IS NULL ))
        AND (tlinfo.incomplete_grade = x_incomplete_grade)
        AND (tlinfo.number_unit_time = x_number_unit_time)
        AND (tlinfo.type_unit_time = x_type_unit_time)
        AND (tlinfo.comp_after_dt_alias = x_comp_after_dt_alias)
        AND ((tlinfo.default_grade = x_default_grade) OR ( tlinfo.default_grade is null and x_default_grade IS NULL ))
        AND ((tlinfo.default_mark = x_default_mark)  OR  ( tlinfo.default_mark IS NULL AND x_default_mark IS NULL ))
        AND (tlinfo.instructor_update_ind = x_instructor_update_ind)
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
    x_inc_grd_cprof_id                  IN     NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_incomplete_grade                  IN     VARCHAR2,
    x_number_unit_time                  IN     NUMBER,
    x_type_unit_time                    IN     VARCHAR2,
    x_comp_after_dt_alias               IN     VARCHAR2,
    x_default_grade                     IN     VARCHAR2,
    x_default_mark                      IN     NUMBER,
    x_instructor_update_ind             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
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
      x_inc_grd_cprof_id                  => x_inc_grd_cprof_id,
      x_grading_schema_cd                 => x_grading_schema_cd,
      x_version_number                    => x_version_number,
      x_org_unit_cd                       => x_org_unit_cd,
      x_incomplete_grade                  => x_incomplete_grade,
      x_number_unit_time                  => x_number_unit_time,
      x_type_unit_time                    => x_type_unit_time,
      x_comp_after_dt_alias               => x_comp_after_dt_alias,
      x_default_grade                     => x_default_grade,
      x_default_mark                      => x_default_mark,
      x_instructor_update_ind             => x_instructor_update_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_as_inc_grd_cprof
      SET
        grading_schema_cd                 = new_references.grading_schema_cd,
        version_number                    = new_references.version_number,
        org_unit_cd                       = new_references.org_unit_cd,
        incomplete_grade                  = new_references.incomplete_grade,
        number_unit_time                  = new_references.number_unit_time,
        type_unit_time                    = new_references.type_unit_time,
        comp_after_dt_alias               = new_references.comp_after_dt_alias,
        default_grade                     = new_references.default_grade,
        default_mark                      = new_references.default_mark,
        instructor_update_ind             = new_references.instructor_update_ind,
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
    x_inc_grd_cprof_id                  IN OUT NOCOPY NUMBER,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_incomplete_grade                  IN     VARCHAR2,
    x_number_unit_time                  IN     NUMBER,
    x_type_unit_time                    IN     VARCHAR2,
    x_comp_after_dt_alias               IN     VARCHAR2,
    x_default_grade                     IN     VARCHAR2,
    x_default_mark                      IN     NUMBER,
    x_instructor_update_ind             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_as_inc_grd_cprof
      WHERE    inc_grd_cprof_id                  = x_inc_grd_cprof_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_inc_grd_cprof_id,
        x_grading_schema_cd,
        x_version_number,
        x_org_unit_cd,
        x_incomplete_grade,
        x_number_unit_time,
        x_type_unit_time,
        x_comp_after_dt_alias,
        x_default_grade,
        x_default_mark,
        x_instructor_update_ind,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_inc_grd_cprof_id,
      x_grading_schema_cd,
      x_version_number,
      x_org_unit_cd,
      x_incomplete_grade,
      x_number_unit_time,
      x_type_unit_time,
      x_comp_after_dt_alias,
      x_default_grade,
      x_default_mark,
      x_instructor_update_ind,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 25-JUL-2001
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

    DELETE FROM igs_as_inc_grd_cprof
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_as_inc_grd_cprof_pkg;

/
