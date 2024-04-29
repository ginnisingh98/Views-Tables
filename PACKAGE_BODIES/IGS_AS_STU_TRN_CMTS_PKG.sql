--------------------------------------------------------
--  DDL for Package Body IGS_AS_STU_TRN_CMTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_STU_TRN_CMTS_PKG" AS
/* $Header: IGSDI78B.pls 115.1 2003/10/14 07:58:21 kdande noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_as_stu_trn_cmts%ROWTYPE;
  new_references igs_as_stu_trn_cmts%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_comment_id                        IN     NUMBER,
    x_comment_type_code                 IN     VARCHAR2,
    x_comment_txt                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_course_type                       IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_as_stu_trn_cmts
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
    new_references.comment_id                        := x_comment_id;
    new_references.comment_type_code                 := x_comment_type_code;
    new_references.comment_txt                       := x_comment_txt;
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.course_type                       := x_course_type;
    new_references.award_cd                          := x_award_cd;
    new_references.load_cal_type                     := x_load_cal_type;
    new_references.load_ci_sequence_number           := x_load_ci_sequence_number;
    new_references.unit_set_cd                       := x_unit_set_cd;
    new_references.us_version_number                 := x_us_version_number;
    new_references.uoo_id                            := x_uoo_id;

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
  ||  Created On : 22-SEP-2003
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.comment_type_code,
           new_references.person_id,
           new_references.course_cd,
           new_references.course_type,
           new_references.award_cd,
           new_references.load_cal_type,
           new_references.load_ci_sequence_number,
           new_references.unit_set_cd,
           new_references.us_version_number,
           new_references.uoo_id
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
  ||  Created On : 22-SEP-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.load_cal_type = new_references.load_cal_type) AND
         (old_references.load_ci_sequence_number = new_references.load_ci_sequence_number)) OR
        ((new_references.load_cal_type IS NULL) OR
         (new_references.load_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.load_cal_type,
                new_references.load_ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_set_cd = new_references.unit_set_cd) AND
         (old_references.us_version_number = new_references.us_version_number)) OR
        ((new_references.unit_set_cd IS NULL) OR
         (new_references.us_version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_unit_set_pkg.get_pk_for_validation (
                new_references.unit_set_cd,
                new_references.us_version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.award_cd = new_references.award_cd)) OR
        ((new_references.award_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_awd_pkg.get_pk_for_validation (
                new_references.award_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.course_type = new_references.course_type)) OR
        ((new_references.course_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_type_pkg.get_pk_for_validation (
                new_references.course_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

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

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_stdnt_ps_att_pkg.get_pk_for_validation (
                new_references.person_id,
                new_references.course_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_comment_id                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_stu_trn_cmts
      WHERE    comment_id = x_comment_id
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
    x_comment_type_code                 IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_course_type                       IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_stu_trn_cmts
      WHERE    comment_type_code = x_comment_type_code
      AND      person_id = x_person_id
      AND      ((course_cd = x_course_cd) OR (course_cd IS NULL AND x_course_cd IS NULL))
      AND      ((course_type = x_course_type) OR (course_type IS NULL AND x_course_type IS NULL))
      AND      ((award_cd = x_award_cd) OR (award_cd IS NULL AND x_award_cd IS NULL))
      AND      ((load_cal_type = x_load_cal_type) OR (load_cal_type IS NULL AND x_load_cal_type IS NULL))
      AND      ((load_ci_sequence_number = x_load_ci_sequence_number) OR (load_ci_sequence_number IS NULL AND x_load_ci_sequence_number IS NULL))
      AND      ((unit_set_cd = x_unit_set_cd) OR (unit_set_cd IS NULL AND x_unit_set_cd IS NULL))
      AND      ((us_version_number = x_us_version_number) OR (us_version_number IS NULL AND x_us_version_number IS NULL))
      AND      ((uoo_id = x_uoo_id) OR (uoo_id IS NULL AND x_uoo_id IS NULL))
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
    x_sequence_number                   IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_stu_trn_cmts
      WHERE   ((load_cal_type = x_cal_type) AND
               (load_ci_sequence_number = x_sequence_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_CHILD_REC_XS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst;


  PROCEDURE get_fk_igs_en_unit_set (
    x_unit_set_cd                       IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_stu_trn_cmts
      WHERE   ((unit_set_cd = x_unit_set_cd) AND
               (us_version_number = x_version_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_CHILD_REC_XS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_unit_set;


  PROCEDURE get_fk_igs_ps_awd (
    x_award_cd                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_stu_trn_cmts
      WHERE   ((award_cd = x_award_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_CHILD_REC_XS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_awd;


  PROCEDURE get_fk_igs_ps_type (
    x_course_type                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_stu_trn_cmts
      WHERE   ((course_type = x_course_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_CHILD_REC_XS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_type;


  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_stu_trn_cmts
      WHERE   ((uoo_id = x_uoo_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_CHILD_REC_XS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ps_unit_ofr_opt;


  PROCEDURE get_fk_igs_en_stdnt_ps_att (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_stu_trn_cmts
      WHERE   ((course_cd = x_course_cd) AND
               (person_id = x_person_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_CHILD_REC_XS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_stdnt_ps_att;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_comment_id                        IN     NUMBER,
    x_comment_type_code                 IN     VARCHAR2,
    x_comment_txt                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_course_type                       IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
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
      x_comment_id,
      x_comment_type_code,
      x_comment_txt,
      x_person_id,
      x_course_cd,
      x_course_type,
      x_award_cd,
      x_load_cal_type,
      x_load_ci_sequence_number,
      x_unit_set_cd,
      x_us_version_number,
      x_uoo_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.comment_id
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
             new_references.comment_id
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

    IF (p_action IN ('VALIDATE_INSERT', 'VALIDATE_UPDATE', 'VALIDATE_DELETE')) THEN
      l_rowid := NULL;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_comment_id                        IN OUT NOCOPY NUMBER,
    x_comment_type_code                 IN     VARCHAR2,
    x_comment_txt                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_course_type                       IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_AS_STU_TRN_CMTS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_comment_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_comment_id                        => x_comment_id,
      x_comment_type_code                 => x_comment_type_code,
      x_comment_txt                       => x_comment_txt,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_course_type                       => x_course_type,
      x_award_cd                          => x_award_cd,
      x_load_cal_type                     => x_load_cal_type,
      x_load_ci_sequence_number           => x_load_ci_sequence_number,
      x_unit_set_cd                       => x_unit_set_cd,
      x_us_version_number                 => x_us_version_number,
      x_uoo_id                            => x_uoo_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_as_stu_trn_cmts (
      comment_id,
      comment_type_code,
      comment_txt,
      person_id,
      course_cd,
      course_type,
      award_cd,
      load_cal_type,
      load_ci_sequence_number,
      unit_set_cd,
      us_version_number,
      uoo_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_as_stu_trns_cmts_s.NEXTVAL,
      new_references.comment_type_code,
      new_references.comment_txt,
      new_references.person_id,
      new_references.course_cd,
      new_references.course_type,
      new_references.award_cd,
      new_references.load_cal_type,
      new_references.load_ci_sequence_number,
      new_references.unit_set_cd,
      new_references.us_version_number,
      new_references.uoo_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, comment_id INTO x_rowid, x_comment_id;

    l_rowid := NULL;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_comment_id                        IN     NUMBER,
    x_comment_type_code                 IN     VARCHAR2,
    x_comment_txt                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_course_type                       IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        comment_type_code,
        comment_txt,
        person_id,
        course_cd,
        course_type,
        award_cd,
        load_cal_type,
        load_ci_sequence_number,
        unit_set_cd,
        us_version_number,
        uoo_id
      FROM  igs_as_stu_trn_cmts
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
        (tlinfo.comment_type_code = x_comment_type_code)
        AND (tlinfo.comment_txt = x_comment_txt)
        AND (tlinfo.person_id = x_person_id)
        AND ((tlinfo.course_cd = x_course_cd) OR ((tlinfo.course_cd IS NULL) AND (X_course_cd IS NULL)))
        AND ((tlinfo.course_type = x_course_type) OR ((tlinfo.course_type IS NULL) AND (X_course_type IS NULL)))
        AND ((tlinfo.award_cd = x_award_cd) OR ((tlinfo.award_cd IS NULL) AND (X_award_cd IS NULL)))
        AND ((tlinfo.load_cal_type = x_load_cal_type) OR ((tlinfo.load_cal_type IS NULL) AND (X_load_cal_type IS NULL)))
        AND ((tlinfo.load_ci_sequence_number = x_load_ci_sequence_number) OR ((tlinfo.load_ci_sequence_number IS NULL) AND (X_load_ci_sequence_number IS NULL)))
        AND ((tlinfo.unit_set_cd = x_unit_set_cd) OR ((tlinfo.unit_set_cd IS NULL) AND (X_unit_set_cd IS NULL)))
        AND ((tlinfo.us_version_number = x_us_version_number) OR ((tlinfo.us_version_number IS NULL) AND (X_us_version_number IS NULL)))
        AND ((tlinfo.uoo_id = x_uoo_id) OR ((tlinfo.uoo_id IS NULL) AND (X_uoo_id IS NULL)))
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
    x_comment_id                        IN     NUMBER,
    x_comment_type_code                 IN     VARCHAR2,
    x_comment_txt                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_course_type                       IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_AS_STU_TRN_CMTS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_comment_id                        => x_comment_id,
      x_comment_type_code                 => x_comment_type_code,
      x_comment_txt                       => x_comment_txt,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_course_type                       => x_course_type,
      x_award_cd                          => x_award_cd,
      x_load_cal_type                     => x_load_cal_type,
      x_load_ci_sequence_number           => x_load_ci_sequence_number,
      x_unit_set_cd                       => x_unit_set_cd,
      x_us_version_number                 => x_us_version_number,
      x_uoo_id                            => x_uoo_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_as_stu_trn_cmts
      SET
        comment_type_code                 = new_references.comment_type_code,
        comment_txt                       = new_references.comment_txt,
        person_id                         = new_references.person_id,
        course_cd                         = new_references.course_cd,
        course_type                       = new_references.course_type,
        award_cd                          = new_references.award_cd,
        load_cal_type                     = new_references.load_cal_type,
        load_ci_sequence_number           = new_references.load_ci_sequence_number,
        unit_set_cd                       = new_references.unit_set_cd,
        us_version_number                 = new_references.us_version_number,
        uoo_id                            = new_references.uoo_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_comment_id                        IN OUT NOCOPY NUMBER,
    x_comment_type_code                 IN     VARCHAR2,
    x_comment_txt                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_course_type                       IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_as_stu_trn_cmts
      WHERE    comment_id                        = x_comment_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_comment_id,
        x_comment_type_code,
        x_comment_txt,
        x_person_id,
        x_course_cd,
        x_course_type,
        x_award_cd,
        x_load_cal_type,
        x_load_ci_sequence_number,
        x_unit_set_cd,
        x_us_version_number,
        x_uoo_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_comment_id,
      x_comment_type_code,
      x_comment_txt,
      x_person_id,
      x_course_cd,
      x_course_type,
      x_award_cd,
      x_load_cal_type,
      x_load_ci_sequence_number,
      x_unit_set_cd,
      x_us_version_number,
      x_uoo_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 22-SEP-2003
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

    DELETE FROM igs_as_stu_trn_cmts
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END delete_row;


END igs_as_stu_trn_cmts_pkg;

/
