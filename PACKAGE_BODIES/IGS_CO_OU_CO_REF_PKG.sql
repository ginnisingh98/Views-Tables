--------------------------------------------------------
--  DDL for Package Body IGS_CO_OU_CO_REF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_OU_CO_REF_PKG" AS
/* $Header: IGSLI15B.pls 115.8 2002/11/29 01:06:06 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_co_ou_co_ref_all%ROWTYPE;
  new_references igs_co_ou_co_ref_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_reference_number                  IN     NUMBER      DEFAULT NULL,
    x_issue_dt                          IN     DATE        DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_cv_version_number                 IN     NUMBER      DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_uv_version_number                 IN     NUMBER      DEFAULT NULL,
    x_s_other_reference_type            IN     VARCHAR2    DEFAULT NULL,
    x_other_reference                   IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CO_OU_CO_REF_ALL
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
    new_references.org_id                            := x_org_id;
    new_references.person_id                         := x_person_id;
    new_references.correspondence_type               := x_correspondence_type;
    new_references.reference_number                  := x_reference_number;
    new_references.issue_dt                          := x_issue_dt;
    new_references.sequence_number                   := x_sequence_number;
    new_references.cal_type                          := x_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.course_cd                         := x_course_cd;
    new_references.cv_version_number                 := x_cv_version_number;
    new_references.unit_cd                           := x_unit_cd;
    new_references.uv_version_number                 := x_uv_version_number;
    new_references.s_other_reference_type            := x_s_other_reference_type;
    new_references.other_reference                   := x_other_reference;

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


  PROCEDURE check_constraints (
    column_name    IN     VARCHAR2    DEFAULT NULL,
    column_value   IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the Check Constraint logic for the the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER(column_name) = 'REFERENCE_NUMBER') THEN
      new_references.reference_number := igs_ge_number.to_num (column_value);
    ELSIF (UPPER(column_name) = 'SEQUENCE_NUMBER') THEN
      new_references.sequence_number := igs_ge_number.to_num (column_value);
    ELSIF (UPPER(column_name) = 'CI_SEQUENCE_NUMBER') THEN
      new_references.ci_sequence_number := igs_ge_number.to_num (column_value);
    END IF;

    IF (UPPER(column_name) = 'REFERENCE_NUMBER' OR column_name IS NULL) THEN
      IF NOT (new_references.reference_number BETWEEN 1
              AND 999999)  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (UPPER(column_name) = 'SEQUENCE_NUMBER' OR column_name IS NULL) THEN
      IF NOT (new_references.sequence_number BETWEEN 1
              AND 999999)  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (UPPER(column_name) = 'CI_SEQUENCE_NUMBER' OR column_name IS NULL) THEN
      IF NOT (new_references.ci_sequence_number BETWEEN 1
              AND 999999)  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.uv_version_number = new_references.uv_version_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.uv_version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ver_pkg.get_pk_for_validation (
                new_references.unit_cd,
                new_references.uv_version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.cv_version_number = new_references.cv_version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.cv_version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_ver_pkg.get_pk_for_validation (
                new_references.course_cd,
                new_references.cv_version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.correspondence_type = new_references.correspondence_type) AND
         (old_references.reference_number = new_references.reference_number) AND
         (old_references.issue_dt = new_references.issue_dt)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.correspondence_type IS NULL) OR
         (new_references.reference_number IS NULL) OR
         (new_references.issue_dt IS NULL))) THEN
      NULL;
    ELSIF NOT igs_co_ou_co_pkg.get_pk_for_validation (
                new_references.person_id,
                new_references.correspondence_type,
                new_references.reference_number,
                new_references.issue_dt
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN     DATE,
    x_sequence_number                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_ou_co_ref_all
      WHERE    person_id = x_person_id
      AND      correspondence_type = x_correspondence_type
      AND      reference_number = x_reference_number
      AND      issue_dt = x_issue_dt
      AND      sequence_number = x_sequence_number
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


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_ou_co_ref_all
      WHERE   ((cal_type = x_cal_type) AND
               (ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;


  PROCEDURE get_fk_igs_ps_unit_ver (
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_ou_co_ref_all
      WHERE   ((unit_cd = x_unit_cd) AND
               (uv_version_number = x_version_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_unit_ver;


  PROCEDURE get_fk_igs_ps_ver (
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_ou_co_ref_all
      WHERE   ((course_cd = x_course_cd) AND
               (cv_version_number = x_version_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_ver;


  PROCEDURE get_fk_igs_co_ou_co (
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN     DATE
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_ou_co_ref_all
      WHERE   ((person_id = x_person_id) AND
               (correspondence_type = x_correspondence_type) AND
               (reference_number = x_reference_number) AND
               (issue_dt = x_issue_dt));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_co_ou_co;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_reference_number                  IN     NUMBER      DEFAULT NULL,
    x_issue_dt                          IN     DATE        DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_cv_version_number                 IN     NUMBER      DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_uv_version_number                 IN     NUMBER      DEFAULT NULL,
    x_s_other_reference_type            IN     VARCHAR2    DEFAULT NULL,
    x_other_reference                   IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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
      x_org_id,
      x_person_id,
      x_correspondence_type,
      x_reference_number,
      x_issue_dt,
      x_sequence_number,
      x_cal_type,
      x_ci_sequence_number,
      x_course_cd,
      x_cv_version_number,
      x_unit_cd,
      x_uv_version_number,
      x_s_other_reference_type,
      x_other_reference,
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
             new_references.correspondence_type,
             new_references.reference_number,
             new_references.issue_dt,
             new_references.sequence_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.person_id,
             new_references.correspondence_type,
             new_references.reference_number,
             new_references.issue_dt,
             new_references.sequence_number
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN OUT NOCOPY DATE,
    x_sequence_number                   IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cv_version_number                 IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_s_other_reference_type            IN     VARCHAR2,
    x_other_reference                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_co_ou_co_ref_all
      WHERE    person_id                         = x_person_id
      AND      correspondence_type               = x_correspondence_type
      AND      reference_number                  = x_reference_number
      AND      issue_dt                          = new_references.issue_dt
      AND      sequence_number                   = x_sequence_number;

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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_org_id                            => igs_ge_gen_003.get_org_id,
      x_person_id                         => x_person_id,
      x_correspondence_type               => x_correspondence_type,
      x_reference_number                  => x_reference_number,
      x_issue_dt                          => NVL (x_issue_dt,sysdate ),
      x_sequence_number                   => x_sequence_number,
      x_cal_type                          => x_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_course_cd                         => x_course_cd,
      x_cv_version_number                 => x_cv_version_number,
      x_unit_cd                           => x_unit_cd,
      x_uv_version_number                 => x_uv_version_number,
      x_s_other_reference_type            => x_s_other_reference_type,
      x_other_reference                   => x_other_reference,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_co_ou_co_ref_all (
      org_id,
      person_id,
      correspondence_type,
      reference_number,
      issue_dt,
      sequence_number,
      cal_type,
      ci_sequence_number,
      course_cd,
      cv_version_number,
      unit_cd,
      uv_version_number,
      s_other_reference_type,
      other_reference,
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
      new_references.org_id,
      new_references.person_id,
      new_references.correspondence_type,
      new_references.reference_number,
      new_references.issue_dt,
      new_references.sequence_number,
      new_references.cal_type,
      new_references.ci_sequence_number,
      new_references.course_cd,
      new_references.cv_version_number,
      new_references.unit_cd,
      new_references.uv_version_number,
      new_references.s_other_reference_type,
      new_references.other_reference,
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
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN     DATE,
    x_sequence_number                   IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cv_version_number                 IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_s_other_reference_type            IN     VARCHAR2,
    x_other_reference                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
       cal_type,
        ci_sequence_number,
        course_cd,
        cv_version_number,
        unit_cd,
        uv_version_number,
        s_other_reference_type,
        other_reference
      FROM  igs_co_ou_co_ref_all
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
         ((tlinfo.cal_type = x_cal_type) OR ((tlinfo.cal_type IS NULL) AND (X_cal_type IS NULL)))
        AND ((tlinfo.ci_sequence_number = x_ci_sequence_number) OR ((tlinfo.ci_sequence_number IS NULL) AND (X_ci_sequence_number IS NULL)))
        AND ((tlinfo.course_cd = x_course_cd) OR ((tlinfo.course_cd IS NULL) AND (X_course_cd IS NULL)))
        AND ((tlinfo.cv_version_number = x_cv_version_number) OR ((tlinfo.cv_version_number IS NULL) AND (X_cv_version_number IS NULL)))
        AND ((tlinfo.unit_cd = x_unit_cd) OR ((tlinfo.unit_cd IS NULL) AND (X_unit_cd IS NULL)))
        AND ((tlinfo.uv_version_number = x_uv_version_number) OR ((tlinfo.uv_version_number IS NULL) AND (X_uv_version_number IS NULL)))
        AND ((tlinfo.s_other_reference_type = x_s_other_reference_type) OR ((tlinfo.s_other_reference_type IS NULL) AND (X_s_other_reference_type IS NULL)))
        AND ((tlinfo.other_reference = x_other_reference) OR ((tlinfo.other_reference IS NULL) AND (X_other_reference IS NULL)))
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
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN     DATE,
    x_sequence_number                   IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cv_version_number                 IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_s_other_reference_type            IN     VARCHAR2,
    x_other_reference                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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
      x_person_id                         => x_person_id,
      x_correspondence_type               => x_correspondence_type,
      x_reference_number                  => x_reference_number,
      x_issue_dt                          => NVL (x_issue_dt,sysdate ),
      x_sequence_number                   => x_sequence_number,
      x_cal_type                          => x_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_course_cd                         => x_course_cd,
      x_cv_version_number                 => x_cv_version_number,
      x_unit_cd                           => x_unit_cd,
      x_uv_version_number                 => x_uv_version_number,
      x_s_other_reference_type            => x_s_other_reference_type,
      x_other_reference                   => x_other_reference,
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

    UPDATE igs_co_ou_co_ref_all
      SET
        cal_type                          = new_references.cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        course_cd                         = new_references.course_cd,
        cv_version_number                 = new_references.cv_version_number,
        unit_cd                           = new_references.unit_cd,
        uv_version_number                 = new_references.uv_version_number,
        s_other_reference_type            = new_references.s_other_reference_type,
        other_reference                   = new_references.other_reference,
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
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_issue_dt                          IN OUT NOCOPY DATE,
    x_sequence_number                   IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cv_version_number                 IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_s_other_reference_type            IN     VARCHAR2,
    x_other_reference                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_co_ou_co_ref_all
      WHERE    person_id                         = x_person_id
      AND      correspondence_type               = x_correspondence_type
      AND      reference_number                  = x_reference_number
      AND      issue_dt                         = NVL (x_issue_dt,SYSDATE)
      AND      sequence_number                   = x_sequence_number;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_org_id,
        x_person_id,
        x_correspondence_type,
        x_reference_number,
        x_issue_dt,
        x_sequence_number,
        x_cal_type,
        x_ci_sequence_number,
        x_course_cd,
        x_cv_version_number,
        x_unit_cd,
        x_uv_version_number,
        x_s_other_reference_type,
        x_other_reference,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_person_id,
      x_correspondence_type,
      x_reference_number,
      x_issue_dt,
      x_sequence_number,
      x_cal_type,
      x_ci_sequence_number,
      x_course_cd,
      x_cv_version_number,
      x_unit_cd,
      x_uv_version_number,
      x_s_other_reference_type,
      x_other_reference,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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

    DELETE FROM igs_co_ou_co_ref_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_co_ou_co_ref_pkg;

/
