--------------------------------------------------------
--  DDL for Package Body IGS_AS_SUAAI_OUHIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SUAAI_OUHIST_PKG" AS
/* $Header: IGSDI59B.pls 115.7 2003/12/03 09:03:06 ijeddy noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_as_suaai_ouhist%ROWTYPE;
  new_references igs_as_suaai_ouhist%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_ass_id                            IN     NUMBER      DEFAULT NULL,
    x_creation_dt                       IN     DATE        DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_gs_version_number                 IN     NUMBER      DEFAULT NULL,
    x_grade                             IN     VARCHAR2    DEFAULT NULL,
    x_outcome_dt                        IN     DATE        DEFAULT NULL,
    x_mark                              IN     NUMBER      DEFAULT NULL,
    x_outcome_comment_code              IN     VARCHAR2    DEFAULT NULL,
    x_hist_start_dt                     IN     DATE        DEFAULT NULL,
    x_hist_end_dt                       IN     DATE        DEFAULT NULL,
    x_hist_who                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_sua_ass_item_group_id             IN     NUMBER      DEFAULT NULL,
    x_midterm_mandatory_type_code       IN     VARCHAR2    DEFAULT NULL,
    x_midterm_weight_qty                IN     NUMBER      DEFAULT NULL,
    x_final_mandatory_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_final_weight_qty                  IN     NUMBER      DEFAULT NULL,
    x_submitted_date                    IN     DATE        DEFAULT NULL,
    x_waived_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_penalty_applied_flag              IN     VARCHAR2    DEFAULT NULL

  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 28-DEC-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  svanukur        29-APR-03       Set the value of uoo_id as part of MUS build
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_as_suaai_ouhist
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
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.unit_cd                           := x_unit_cd;
    new_references.cal_type                          := x_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.ass_id                            := x_ass_id;
    new_references.creation_dt                       := x_creation_dt;
    new_references.grading_schema_cd                 := x_grading_schema_cd;
    new_references.gs_version_number                 := x_gs_version_number;
    new_references.grade                             := x_grade;
    new_references.outcome_dt                        := x_outcome_dt;
    new_references.mark                              := x_mark;
    new_references.outcome_comment_code              := x_outcome_comment_code;
    new_references.hist_start_dt                     := x_hist_start_dt;
    new_references.hist_end_dt                       := x_hist_end_dt;
    new_references.hist_who                          := x_hist_who;
    new_references.uoo_id                            := x_uoo_id;

    new_references.sua_ass_item_group_id           :=   x_sua_ass_item_group_id;
    new_references.midterm_mandatory_type_code     :=   x_midterm_mandatory_type_code;
    new_references.midterm_weight_qty              :=   x_midterm_weight_qty;
    new_references.final_mandatory_type_code       :=   x_final_mandatory_type_code;
    new_references.final_weight_qty                :=   x_final_weight_qty;
    new_references.submitted_date                  :=   x_submitted_date;
    new_references.waived_flag                     :=   x_waived_flag;
    new_references.penalty_applied_flag            :=   x_penalty_applied_flag;

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


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 28-DEC-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || Who        when               What
  || Aiyer      17-Apr-2002        Modified the parameter list for the call to the function
  ||                               igs_as_su_atmpt_itm_pkg.get_pk_For_validation for the code fix
  ||                               of the bug 2323692.Initially unit_cd field was being passes as parameter
  ||                               to the x_person_id field and vice versa. As person_id is a number and unit cd is a character, hence
  ||                               assignment of unit cd to person_id used to give a character to numeric conversion error.This has been rectified
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.ass_id = new_references.ass_id) AND
         (old_references.creation_dt = new_references.creation_dt) AND
         (old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL) OR
         (new_references.ass_id IS NULL) OR
         (new_references.creation_dt IS NULL) OR
         (new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_su_atmpt_itm_pkg.get_pk_For_validation (
               x_course_cd          =>  new_references.course_cd,
               x_person_id          =>  new_references.person_id,
               x_ass_id             =>  new_references.ass_id,
               x_creation_dt        =>  new_references.creation_dt,
               x_uoo_id             =>  new_references.uoo_id
              ) THEN

      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (old_references.sua_ass_item_group_id = new_references.sua_ass_item_group_id
         OR new_references.sua_ass_item_group_id IS NULL) THEN
      NULL;
    ELSIF NOT igs_as_sua_ai_group_pkg.get_pk_For_validation (
               x_sua_ass_item_group_id          =>  new_references.sua_ass_item_group_id) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_ass_id                            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_creation_dt                       IN     DATE,
    x_hist_start_dt                     IN     DATE,
    x_person_id                         IN     NUMBER,
    x_uoo_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 28-DEC-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  svanukur    29-APR-03    changed the PK columns as part of MUS build, # 2829262
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_suaai_ouhist
      WHERE    ass_id = x_ass_id
      AND      course_cd = x_course_cd
      AND      creation_dt = x_creation_dt
      AND      hist_start_dt = x_hist_start_dt
      AND      person_id = x_person_id
      AND      uoo_id = x_uoo_id
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


  PROCEDURE get_fk_igs_as_su_atmpt_itm (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_ass_id                            IN     NUMBER,
    x_creation_dt                       IN     DATE,
    x_uoo_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 28-DEC-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  svanukur    29-APR-03    changed where clause as part of MUS build, # 2829262
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_suaai_ouhist
      WHERE   ((ass_id = x_ass_id) AND
               (course_cd = x_course_cd) AND
               (creation_dt = x_creation_dt) AND
               (person_id = x_person_id) AND
               (uoo_id = x_uoo_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AS_ASHO_SUAAI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_as_su_atmpt_itm;

  PROCEDURE get_fk_igs_as_sua_ai_group (
    x_sua_ass_item_group_id            IN     NUMBER
  ) AS
  /*
  ||  Created By : imran.jeddy@oracle.com
  ||  Created On : 02-Dec-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_suaai_ouhist
      WHERE   ((sua_ass_item_group_id = x_sua_ass_item_group_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AS_ASHO_SUAAIG_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_as_sua_ai_group;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_ass_id                            IN     NUMBER      DEFAULT NULL,
    x_creation_dt                       IN     DATE        DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_gs_version_number                 IN     NUMBER      DEFAULT NULL,
    x_grade                             IN     VARCHAR2    DEFAULT NULL,
    x_outcome_dt                        IN     DATE        DEFAULT NULL,
    x_mark                              IN     NUMBER      DEFAULT NULL,
    x_outcome_comment_code              IN     VARCHAR2    DEFAULT NULL,
    x_hist_start_dt                     IN     DATE        DEFAULT NULL,
    x_hist_end_dt                       IN     DATE        DEFAULT NULL,
    x_hist_who                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_sua_ass_item_group_id             IN     NUMBER      DEFAULT NULL,
    x_midterm_mandatory_type_code       IN     VARCHAR2    DEFAULT NULL,
    x_midterm_weight_qty                IN     NUMBER      DEFAULT NULL,
    x_final_mandatory_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_final_weight_qty                  IN     NUMBER      DEFAULT NULL,
    x_submitted_date                    IN     DATE        DEFAULT NULL,
    x_waived_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_penalty_applied_flag              IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 28-DEC-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||svanukur    29-APR-03    Added uoo_id as part of MUS build, # 2829262
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_person_id,
      x_course_cd,
      x_unit_cd,
      x_cal_type,
      x_ci_sequence_number,
      x_ass_id,
      x_creation_dt,
      x_grading_schema_cd,
      x_gs_version_number,
      x_grade,
      x_outcome_dt,
      x_mark,
      x_outcome_comment_code,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_uoo_id,
      x_sua_ass_item_group_id,
      x_midterm_mandatory_type_code,
      x_midterm_weight_qty,
      x_final_mandatory_type_code,
      x_final_weight_qty,
      x_submitted_date,
      x_waived_flag,
      x_penalty_applied_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ass_id,
             new_references.course_cd,
             new_references.creation_dt,
             new_references.hist_start_dt,
             new_references.person_id,
             new_references.uoo_id
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
             new_references.ass_id,
             new_references.course_cd,
             new_references.creation_dt,
             new_references.hist_start_dt,
             new_references.person_id,
             new_references.uoo_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_ass_id                            IN     NUMBER,
    x_creation_dt                       IN     DATE,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_grade                             IN     VARCHAR2,
    x_outcome_dt                        IN     DATE,
    x_mark                              IN     NUMBER,
    x_outcome_comment_code              IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R' ,
    x_uoo_id                            IN     NUMBER,
    x_sua_ass_item_group_id             IN     NUMBER      DEFAULT NULL,
    x_midterm_mandatory_type_code       IN     VARCHAR2    DEFAULT NULL,
    x_midterm_weight_qty                IN     NUMBER      DEFAULT NULL,
    x_final_mandatory_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_final_weight_qty                  IN     NUMBER      DEFAULT NULL,
    x_submitted_date                    IN     DATE        DEFAULT NULL,
    x_waived_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_penalty_applied_flag              IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 28-DEC-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||svanukur    29-APR-03    Added uoo_id as part of MUS build, # 2829262
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_as_suaai_ouhist
      WHERE    ass_id                            = x_ass_id
      AND      course_cd                         = x_course_cd
      AND      creation_dt                       = x_creation_dt
      AND      hist_start_dt                     = x_hist_start_dt
      AND      person_id                         = x_person_id
      AND      uoo_id                            = x_uoo_id;

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
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_unit_cd                           => x_unit_cd,
      x_cal_type                          => x_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_ass_id                            => x_ass_id,
      x_creation_dt                       => x_creation_dt,
      x_grading_schema_cd                 => x_grading_schema_cd,
      x_gs_version_number                 => x_gs_version_number,
      x_grade                             => x_grade,
      x_outcome_dt                        => x_outcome_dt,
      x_mark                              => x_mark,
      x_outcome_comment_code              => x_outcome_comment_code,
      x_hist_start_dt                     => x_hist_start_dt,
      x_hist_end_dt                       => x_hist_end_dt,
      x_hist_who                          => x_hist_who,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_uoo_id                            => x_uoo_id,
      x_sua_ass_item_group_id             => x_sua_ass_item_group_id,
      x_midterm_mandatory_type_code       => x_midterm_mandatory_type_code,
      x_midterm_weight_qty                => x_midterm_weight_qty,
      x_final_mandatory_type_code         => x_final_mandatory_type_code,
      x_final_weight_qty                  => x_final_weight_qty,
      x_submitted_date                    => x_submitted_date,
      x_waived_flag                       => x_waived_flag,
      x_penalty_applied_flag              => x_penalty_applied_flag
    );

    INSERT INTO igs_as_suaai_ouhist (
      person_id,
      course_cd,
      unit_cd,
      cal_type,
      ci_sequence_number,
      ass_id,
      creation_dt,
      grading_schema_cd,
      gs_version_number,
      grade,
      outcome_dt,
      mark,
      outcome_comment_code,
      hist_start_dt,
      hist_end_dt,
      hist_who,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      uoo_id,
      sua_ass_item_group_id,
      midterm_mandatory_type_code,
      midterm_weight_qty,
      final_mandatory_type_code,
      final_weight_qty,
      submitted_date,
      waived_flag,
      penalty_applied_flag
    ) VALUES (
      new_references.person_id,
      new_references.course_cd,
      new_references.unit_cd,
      new_references.cal_type,
      new_references.ci_sequence_number,
      new_references.ass_id,
      new_references.creation_dt,
      new_references.grading_schema_cd,
      new_references.gs_version_number,
      new_references.grade,
      new_references.outcome_dt,
      new_references.mark,
      new_references.outcome_comment_code,
      new_references.hist_start_dt,
      new_references.hist_end_dt,
      new_references.hist_who,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.uoo_id,
      new_references.sua_ass_item_group_id,
      new_references.midterm_mandatory_type_code,
      new_references.midterm_weight_qty,
      new_references.final_mandatory_type_code,
      new_references.final_weight_qty,
      new_references.submitted_date,
      new_references.waived_flag,
      new_references.penalty_applied_flag
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
    x_course_cd                         IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_ass_id                            IN     NUMBER,
    x_creation_dt                       IN     DATE,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_grade                             IN     VARCHAR2,
    x_outcome_dt                        IN     DATE,
    x_mark                              IN     NUMBER,
    x_outcome_comment_code              IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_sua_ass_item_group_id             IN     NUMBER      DEFAULT NULL,
    x_midterm_mandatory_type_code       IN     VARCHAR2    DEFAULT NULL,
    x_midterm_weight_qty                IN     NUMBER      DEFAULT NULL,
    x_final_mandatory_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_final_weight_qty                  IN     NUMBER      DEFAULT NULL,
    x_submitted_date                    IN     DATE        DEFAULT NULL,
    x_waived_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_penalty_applied_flag              IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 28-DEC-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||svanukur    29-APR-03    Added uoo_id as part of MUS build, # 2829262
  */
    CURSOR c1 IS
      SELECT
        grading_schema_cd,
        gs_version_number,
        grade,
        outcome_dt,
        mark,
        outcome_comment_code,
        hist_end_dt,
        hist_who,
        sua_ass_item_group_id,
        midterm_mandatory_type_code,
        midterm_weight_qty,
        final_mandatory_type_code,
        final_weight_qty,
        submitted_date,
        waived_flag,
        penalty_applied_flag
      FROM  igs_as_suaai_ouhist
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
        ((tlinfo.grading_schema_cd = x_grading_schema_cd) OR ((tlinfo.grading_schema_cd IS NULL) AND (X_grading_schema_cd IS NULL)))
        AND ((tlinfo.gs_version_number = x_gs_version_number) OR ((tlinfo.gs_version_number IS NULL) AND (X_gs_version_number IS NULL)))
        AND ((tlinfo.grade = x_grade) OR ((tlinfo.grade IS NULL) AND (X_grade IS NULL)))
        AND (tlinfo.outcome_dt = x_outcome_dt)
        AND ((tlinfo.mark = x_mark) OR ((tlinfo.mark IS NULL) AND (X_mark IS NULL)))
        AND ((tlinfo.outcome_comment_code = x_outcome_comment_code) OR ((tlinfo.outcome_comment_code IS NULL) AND (X_outcome_comment_code IS NULL)))
        AND (tlinfo.hist_end_dt = x_hist_end_dt)
        AND (tlinfo.hist_who = x_hist_who)
        AND ((tlinfo.sua_ass_item_group_id       = x_sua_ass_item_group_id      ) OR ((tlinfo.sua_ass_item_group_id       IS NULL) AND (x_sua_ass_item_group_id       IS NULL)))
        AND ((tlinfo.midterm_mandatory_type_code = x_midterm_mandatory_type_code) OR ((tlinfo.midterm_mandatory_type_code IS NULL) AND (x_midterm_mandatory_type_code IS NULL)))
        AND ((tlinfo.midterm_weight_qty          = x_midterm_weight_qty         ) OR ((tlinfo.midterm_weight_qty          IS NULL) AND (x_midterm_weight_qty          IS NULL)))
        AND ((tlinfo.final_mandatory_type_code   = x_final_mandatory_type_code  ) OR ((tlinfo.final_mandatory_type_code   IS NULL) AND (x_final_mandatory_type_code   IS NULL)))
        AND ((tlinfo.final_weight_qty            = x_final_weight_qty           ) OR ((tlinfo.final_weight_qty            IS NULL) AND (x_final_weight_qty            IS NULL)))
        AND ((tlinfo.submitted_date              = x_submitted_date             ) OR ((tlinfo.submitted_date              IS NULL) AND (x_submitted_date              IS NULL)))
        AND ((tlinfo.waived_flag                 = x_waived_flag                ) OR ((tlinfo.waived_flag                 IS NULL) AND (x_waived_flag                 IS NULL)))
        AND ((tlinfo.penalty_applied_flag        = x_penalty_applied_flag       ) OR ((tlinfo.penalty_applied_flag        IS NULL) AND (x_penalty_applied_flag        IS NULL)))

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
    x_course_cd                         IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_ass_id                            IN     NUMBER,
    x_creation_dt                       IN     DATE,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_grade                             IN     VARCHAR2,
    x_outcome_dt                        IN     DATE,
    x_mark                              IN     NUMBER,
    x_outcome_comment_code              IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R' ,
    x_uoo_id                            IN     NUMBER,
    x_sua_ass_item_group_id             IN     NUMBER      DEFAULT NULL,
    x_midterm_mandatory_type_code       IN     VARCHAR2    DEFAULT NULL,
    x_midterm_weight_qty                IN     NUMBER      DEFAULT NULL,
    x_final_mandatory_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_final_weight_qty                  IN     NUMBER      DEFAULT NULL,
    x_submitted_date                    IN     DATE        DEFAULT NULL,
    x_waived_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_penalty_applied_flag              IN     VARCHAR2    DEFAULT NULL

  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 28-DEC-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||svanukur    29-APR-03    Added uoo_id as part of MUS build, # 2829262
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
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_unit_cd                           => x_unit_cd,
      x_cal_type                          => x_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_ass_id                            => x_ass_id,
      x_creation_dt                       => x_creation_dt,
      x_grading_schema_cd                 => x_grading_schema_cd,
      x_gs_version_number                 => x_gs_version_number,
      x_grade                             => x_grade,
      x_outcome_dt                        => x_outcome_dt,
      x_mark                              => x_mark,
      x_outcome_comment_code              => x_outcome_comment_code,
      x_hist_start_dt                     => x_hist_start_dt,
      x_hist_end_dt                       => x_hist_end_dt,
      x_hist_who                          => x_hist_who,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_uoo_id                            => x_uoo_id,
      x_sua_ass_item_group_id             => x_sua_ass_item_group_id,
      x_midterm_mandatory_type_code       => x_midterm_mandatory_type_code,
      x_midterm_weight_qty                => x_midterm_weight_qty,
      x_final_mandatory_type_code         => x_final_mandatory_type_code,
      x_final_weight_qty                  => x_final_weight_qty,
      x_submitted_date                    => x_submitted_date,
      x_waived_flag                       => x_waived_flag,
      x_penalty_applied_flag              => x_penalty_applied_flag
    );

    UPDATE igs_as_suaai_ouhist
      SET
        grading_schema_cd                 = new_references.grading_schema_cd,
        gs_version_number                 = new_references.gs_version_number,
        grade                             = new_references.grade,
        outcome_dt                        = new_references.outcome_dt,
        mark                              = new_references.mark,
        outcome_comment_code              = new_references.outcome_comment_code,
        hist_end_dt                       = new_references.hist_end_dt,
        hist_who                          = new_references.hist_who,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        sua_ass_item_group_id             = x_sua_ass_item_group_id,
        midterm_mandatory_type_code       = x_midterm_mandatory_type_code,
        midterm_weight_qty                = x_midterm_weight_qty,
        final_mandatory_type_code         = x_final_mandatory_type_code,
        final_weight_qty                  = x_final_weight_qty,
        submitted_date                    = x_submitted_date,
        waived_flag                       = x_waived_flag,
        penalty_applied_flag              = x_penalty_applied_flag
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_ass_id                            IN     NUMBER,
    x_creation_dt                       IN     DATE,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_grade                             IN     VARCHAR2,
    x_outcome_dt                        IN     DATE,
    x_mark                              IN     NUMBER,
    x_outcome_comment_code              IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R' ,
    x_uoo_id                            IN     NUMBER,
    x_sua_ass_item_group_id             IN     NUMBER      DEFAULT NULL,
    x_midterm_mandatory_type_code       IN     VARCHAR2    DEFAULT NULL,
    x_midterm_weight_qty                IN     NUMBER      DEFAULT NULL,
    x_final_mandatory_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_final_weight_qty                  IN     NUMBER      DEFAULT NULL,
    x_submitted_date                    IN     DATE        DEFAULT NULL,
    x_waived_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_penalty_applied_flag              IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 28-DEC-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||svanukur    29-APR-03    Added uoo_id as part of MUS build, # 2829262
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_as_suaai_ouhist
      WHERE    ass_id                            = x_ass_id
      AND      course_cd                         = x_course_cd
      AND      creation_dt                       = x_creation_dt
      AND      hist_start_dt                     = x_hist_start_dt
      AND      person_id                         = x_person_id
      AND      uoo_id                            = x_uoo_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_person_id,
        x_course_cd,
        x_unit_cd,
        x_cal_type,
        x_ci_sequence_number,
        x_ass_id,
        x_creation_dt,
        x_grading_schema_cd,
        x_gs_version_number,
        x_grade,
        x_outcome_dt,
        x_mark,
        x_outcome_comment_code,
        x_hist_start_dt,
        x_hist_end_dt,
        x_hist_who,
        x_mode,
        x_uoo_id,
        x_sua_ass_item_group_id,
        x_midterm_mandatory_type_code,
        x_midterm_weight_qty,
        x_final_mandatory_type_code,
        x_final_weight_qty,
        x_submitted_date,
        x_waived_flag,
        x_penalty_applied_flag
        );
       RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_person_id,
      x_course_cd,
      x_unit_cd,
      x_cal_type,
      x_ci_sequence_number,
      x_ass_id,
      x_creation_dt,
      x_grading_schema_cd,
      x_gs_version_number,
      x_grade,
      x_outcome_dt,
      x_mark,
      x_outcome_comment_code,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_mode,
      x_uoo_id,
      x_sua_ass_item_group_id,
      x_midterm_mandatory_type_code,
      x_midterm_weight_qty,
      x_final_mandatory_type_code,
      x_final_weight_qty,
      x_submitted_date,
      x_waived_flag,
      x_penalty_applied_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 28-DEC-2001
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||svanukur    29-APR-03    Added uoo_id as part of MUS build, # 2829262
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igs_as_suaai_ouhist
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_as_suaai_ouhist_pkg;

/
