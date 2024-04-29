--------------------------------------------------------
--  DDL for Package Body IGS_AS_SU_ATMPTOUT_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SU_ATMPTOUT_H_PKG" AS
/* $Header: IGSDI05B.pls 115.8 2003/12/11 09:50:36 kdande ship $ */
  l_rowid        VARCHAR2 (25);
  old_references igs_as_su_atmptout_h_all%ROWTYPE;
  new_references igs_as_su_atmptout_h_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2 DEFAULT NULL,
    x_org_id                       IN     NUMBER DEFAULT NULL,
    x_person_id                    IN     NUMBER DEFAULT NULL,
    x_course_cd                    IN     VARCHAR2 DEFAULT NULL,
    x_unit_cd                      IN     VARCHAR2 DEFAULT NULL,
    x_cal_type                     IN     VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number           IN     NUMBER DEFAULT NULL,
    x_outcome_dt                   IN     DATE DEFAULT NULL,
    x_hist_start_dt                IN     DATE DEFAULT NULL,
    x_hist_end_dt                  IN     DATE DEFAULT NULL,
    x_hist_who                     IN     NUMBER DEFAULT NULL,
    x_grading_schema_cd            IN     VARCHAR2 DEFAULT NULL,
    x_version_number               IN     NUMBER DEFAULT NULL,
    x_grade                        IN     VARCHAR2 DEFAULT NULL,
    x_s_grade_creation_method_type IN     VARCHAR2 DEFAULT NULL,
    x_finalised_outcome_ind        IN     VARCHAR2 DEFAULT NULL,
    x_mark                         IN     NUMBER DEFAULT NULL,
    x_number_times_keyed           IN     NUMBER DEFAULT NULL,
    x_translated_grading_schema_cd IN     VARCHAR2 DEFAULT NULL,
    x_translated_version_number    IN     NUMBER DEFAULT NULL,
    x_translated_grade             IN     VARCHAR2 DEFAULT NULL,
    x_translated_dt                IN     DATE DEFAULT NULL,
    x_creation_date                IN     DATE DEFAULT NULL,
    x_created_by                   IN     NUMBER DEFAULT NULL,
    x_last_update_date             IN     DATE DEFAULT NULL,
    x_last_updated_by              IN     NUMBER DEFAULT NULL,
    x_last_update_login            IN     NUMBER DEFAULT NULL,
    x_uoo_id                       IN     NUMBER DEFAULT NULL,
    x_mark_capped_flag             IN     VARCHAR2 DEFAULT NULL,
    x_show_on_academic_histry_flag IN     VARCHAR2 DEFAULT NULL,
    x_release_date                 IN     DATE DEFAULT NULL,
    x_manual_override_flag         IN     VARCHAR2 DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT *
      FROM   igs_as_su_atmptout_h_all
      WHERE  ROWID = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;

    IF  (cur_old_ref_values%NOTFOUND)
        AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      CLOSE cur_old_ref_values;
      app_exception.raise_exception;
      RETURN;
    END IF;

    CLOSE cur_old_ref_values;
    -- Populate New Values.
    new_references.org_id := x_org_id;
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.unit_cd := x_unit_cd;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.outcome_dt := x_outcome_dt;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.grading_schema_cd := x_grading_schema_cd;
    new_references.version_number := x_version_number;
    new_references.grade := x_grade;
    new_references.s_grade_creation_method_type := x_s_grade_creation_method_type;
    new_references.finalised_outcome_ind := x_finalised_outcome_ind;
    new_references.mark := x_mark;
    new_references.number_times_keyed := x_number_times_keyed;
    new_references.translated_grading_schema_cd := x_translated_grading_schema_cd;
    new_references.translated_version_number := x_translated_version_number;
    new_references.translated_grade := x_translated_grade;
    new_references.translated_dt := x_translated_dt;
    new_references.uoo_id := x_uoo_id;
    new_references.mark_capped_flag := x_mark_capped_flag;
    new_references.show_on_academic_histry_flag := x_show_on_academic_histry_flag;
    new_references.release_date := x_release_date;
    new_references.manual_override_flag := x_manual_override_flag;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;

    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
  END set_column_values;

  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --svanukur    29-APR-03    Added uoo_id  as part of MUS build, # 2829262
  -------------------------------------------------------------------------------------------
  FUNCTION get_pk_for_validation (
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_outcome_dt                   IN     DATE,
    x_hist_start_dt                IN     DATE,
    x_uoo_id                       IN     NUMBER
  )
    RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT     ROWID
      FROM       igs_as_su_atmptout_h_all
      WHERE      person_id = x_person_id
      AND        course_cd = x_course_cd
      AND        outcome_dt = x_outcome_dt
      AND        hist_start_dt = x_hist_start_dt
      AND        uoo_id = x_uoo_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%ROWTYPE;
  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN (TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN (FALSE);
    END IF;
  END get_pk_for_validation;

  PROCEDURE before_dml (
    p_action                       IN     VARCHAR2,
    x_rowid                        IN     VARCHAR2 DEFAULT NULL,
    x_org_id                       IN     NUMBER DEFAULT NULL,
    x_person_id                    IN     NUMBER DEFAULT NULL,
    x_course_cd                    IN     VARCHAR2 DEFAULT NULL,
    x_unit_cd                      IN     VARCHAR2 DEFAULT NULL,
    x_cal_type                     IN     VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number           IN     NUMBER DEFAULT NULL,
    x_outcome_dt                   IN     DATE DEFAULT NULL,
    x_hist_start_dt                IN     DATE DEFAULT NULL,
    x_hist_end_dt                  IN     DATE DEFAULT NULL,
    x_hist_who                     IN     NUMBER DEFAULT NULL,
    x_grading_schema_cd            IN     VARCHAR2 DEFAULT NULL,
    x_version_number               IN     NUMBER DEFAULT NULL,
    x_grade                        IN     VARCHAR2 DEFAULT NULL,
    x_s_grade_creation_method_type IN     VARCHAR2 DEFAULT NULL,
    x_finalised_outcome_ind        IN     VARCHAR2 DEFAULT NULL,
    x_mark                         IN     NUMBER DEFAULT NULL,
    x_number_times_keyed           IN     NUMBER DEFAULT NULL,
    x_translated_grading_schema_cd IN     VARCHAR2 DEFAULT NULL,
    x_translated_version_number    IN     NUMBER DEFAULT NULL,
    x_translated_grade             IN     VARCHAR2 DEFAULT NULL,
    x_translated_dt                IN     DATE DEFAULT NULL,
    x_creation_date                IN     DATE DEFAULT NULL,
    x_created_by                   IN     NUMBER DEFAULT NULL,
    x_last_update_date             IN     DATE DEFAULT NULL,
    x_last_updated_by              IN     NUMBER DEFAULT NULL,
    x_last_update_login            IN     NUMBER DEFAULT NULL,
    x_uoo_id                       IN     NUMBER DEFAULT NULL,
    x_mark_capped_flag             IN     VARCHAR2 DEFAULT NULL,
    x_show_on_academic_histry_flag IN     VARCHAR2 DEFAULT NULL,
    x_release_date                 IN     DATE DEFAULT NULL,
    x_manual_override_flag         IN     VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN
    set_column_values (
      p_action,
      x_rowid,
      x_org_id,
      x_person_id,
      x_course_cd,
      x_unit_cd,
      x_cal_type,
      x_ci_sequence_number,
      x_outcome_dt,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_grading_schema_cd,
      x_version_number,
      x_grade,
      x_s_grade_creation_method_type,
      x_finalised_outcome_ind,
      x_mark,
      x_number_times_keyed,
      x_translated_grading_schema_cd,
      x_translated_version_number,
      x_translated_grade,
      x_translated_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_uoo_id,
      x_mark_capped_flag,
      x_show_on_academic_histry_flag,
      x_release_date,
      x_manual_override_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF get_pk_for_validation (
           new_references.person_id,
           new_references.course_cd,
           new_references.outcome_dt,
           new_references.hist_start_dt,
           new_references.uoo_id
         ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_constraints;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF get_pk_for_validation (
           new_references.person_id,
           new_references.course_cd,
           new_references.outcome_dt,
           new_references.hist_start_dt,
           new_references.uoo_id
         ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    END IF;
  END before_dml;

  PROCEDURE insert_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_org_id                       IN     NUMBER,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_hist_start_dt                IN     DATE,
    x_hist_end_dt                  IN     DATE,
    x_hist_who                     IN     NUMBER,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_number_times_keyed           IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2 DEFAULT 'N',
    x_show_on_academic_histry_flag IN     VARCHAR2 DEFAULT 'Y',
    x_release_date                 IN     DATE DEFAULT NULL,
    x_manual_override_flag         IN     VARCHAR2 DEFAULT 'N'
  ) IS
    CURSOR c IS
      SELECT ROWID
      FROM   igs_as_su_atmptout_h_all
      WHERE  person_id = x_person_id
      AND    course_cd = x_course_cd
      AND    uoo_id = x_uoo_id
      AND    outcome_dt = x_outcome_dt
      AND    hist_start_dt = x_hist_start_dt;

    x_last_update_date  DATE;
    x_last_updated_by   NUMBER;
    x_last_update_login NUMBER;
  BEGIN
    x_last_update_date := SYSDATE;

    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;

      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;

      x_last_update_login := fnd_global.login_id;

      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    before_dml (
      p_action                       => 'INSERT',
      x_rowid                        => x_rowid,
      x_org_id                       => igs_ge_gen_003.get_org_id,
      x_cal_type                     => x_cal_type,
      x_ci_sequence_number           => x_ci_sequence_number,
      x_course_cd                    => x_course_cd,
      x_finalised_outcome_ind        => x_finalised_outcome_ind,
      x_grade                        => x_grade,
      x_grading_schema_cd            => x_grading_schema_cd,
      x_hist_end_dt                  => x_hist_end_dt,
      x_hist_start_dt                => x_hist_start_dt,
      x_hist_who                     => x_hist_who,
      x_mark                         => x_mark,
      x_number_times_keyed           => x_number_times_keyed,
      x_outcome_dt                   => x_outcome_dt,
      x_person_id                    => x_person_id,
      x_s_grade_creation_method_type => x_s_grade_creation_method_type,
      x_translated_dt                => x_translated_dt,
      x_translated_grade             => x_translated_grade,
      x_translated_grading_schema_cd => x_translated_grading_schema_cd,
      x_translated_version_number    => x_translated_version_number,
      x_unit_cd                      => x_unit_cd,
      x_version_number               => x_version_number,
      x_creation_date                => x_last_update_date,
      x_created_by                   => x_last_updated_by,
      x_last_update_date             => x_last_update_date,
      x_last_updated_by              => x_last_updated_by,
      x_last_update_login            => x_last_update_login,
      x_uoo_id                       => x_uoo_id,
      x_mark_capped_flag             => x_mark_capped_flag,
      x_show_on_academic_histry_flag => x_show_on_academic_histry_flag,
      x_release_date                 => x_release_date,
      x_manual_override_flag         => x_manual_override_flag
    );

    INSERT INTO igs_as_su_atmptout_h_all
                (org_id, person_id, course_cd, unit_cd,
                 cal_type, ci_sequence_number, outcome_dt,
                 hist_start_dt, hist_end_dt, hist_who,
                 grading_schema_cd, version_number, grade,
                 s_grade_creation_method_type, finalised_outcome_ind, mark,
                 number_times_keyed, translated_grading_schema_cd,
                 translated_version_number, translated_grade,
                 translated_dt, creation_date, created_by, last_update_date,
                 last_updated_by, last_update_login, uoo_id, mark_capped_flag,
                 show_on_academic_histry_flag, release_date, manual_override_flag)
         VALUES (new_references.org_id, new_references.person_id, new_references.course_cd, new_references.unit_cd,
                 new_references.cal_type, new_references.ci_sequence_number, new_references.outcome_dt,
                 new_references.hist_start_dt, new_references.hist_end_dt, new_references.hist_who,
                 new_references.grading_schema_cd, new_references.version_number, new_references.grade,
                 new_references.s_grade_creation_method_type, new_references.finalised_outcome_ind, new_references.mark,
                 new_references.number_times_keyed, new_references.translated_grading_schema_cd,
                 new_references.translated_version_number, new_references.translated_grade,
                 new_references.translated_dt, x_last_update_date, x_last_updated_by, x_last_update_date,
                 x_last_updated_by, x_last_update_login, new_references.uoo_id,
                 new_references.mark_capped_flag, new_references.show_on_academic_histry_flag,
                 new_references.release_date, new_references.manual_override_flag);

    OPEN c;
    FETCH c INTO x_rowid;

    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE c;
  END insert_row;

  PROCEDURE lock_row (
    x_rowid                        IN     VARCHAR2,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_hist_start_dt                IN     DATE,
    x_hist_end_dt                  IN     DATE,
    x_hist_who                     IN     NUMBER,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_number_times_keyed           IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2 DEFAULT 'N',
    x_show_on_academic_histry_flag IN     VARCHAR2 DEFAULT 'Y',
    x_release_date                 IN     DATE DEFAULT NULL,
    x_manual_override_flag         IN     VARCHAR2 DEFAULT 'N'
  ) IS
    CURSOR c1 IS
      SELECT     hist_end_dt,
                 hist_who,
                 grading_schema_cd,
                 version_number,
                 grade,
                 s_grade_creation_method_type,
                 finalised_outcome_ind,
                 mark,
                 number_times_keyed,
                 translated_grading_schema_cd,
                 translated_version_number,
                 translated_grade,
                 translated_dt,
                 mark_capped_flag,
                 show_on_academic_histry_flag,
                 release_date,
                 manual_override_flag
      FROM       igs_as_su_atmptout_h_all
      WHERE      ROWID = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;
  BEGIN
    OPEN c1;
    FETCH c1 INTO tlinfo;

    IF (c1%NOTFOUND) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
      CLOSE c1;
      RETURN;
    END IF;

    CLOSE c1;

    IF ((tlinfo.hist_end_dt = x_hist_end_dt)
        AND (tlinfo.hist_who = x_hist_who)
        AND ((tlinfo.grading_schema_cd = x_grading_schema_cd)
             OR ((tlinfo.grading_schema_cd IS NULL)
                 AND (x_grading_schema_cd IS NULL)
                )
            )
        AND ((tlinfo.version_number = x_version_number)
             OR ((tlinfo.version_number IS NULL)
                 AND (x_version_number IS NULL)
                )
            )
        AND ((tlinfo.grade = x_grade)
             OR ((tlinfo.grade IS NULL)
                 AND (x_grade IS NULL)
                )
            )
        AND ((tlinfo.s_grade_creation_method_type = x_s_grade_creation_method_type)
             OR ((tlinfo.s_grade_creation_method_type IS NULL)
                 AND (x_s_grade_creation_method_type IS NULL)
                )
            )
        AND ((tlinfo.finalised_outcome_ind = x_finalised_outcome_ind)
             OR ((tlinfo.finalised_outcome_ind IS NULL)
                 AND (x_finalised_outcome_ind IS NULL)
                )
            )
        AND ((tlinfo.mark = x_mark)
             OR ((tlinfo.mark IS NULL)
                 AND (x_mark IS NULL)
                )
            )
        AND ((tlinfo.number_times_keyed = x_number_times_keyed)
             OR ((tlinfo.number_times_keyed IS NULL)
                 AND (x_number_times_keyed IS NULL)
                )
            )
        AND ((tlinfo.translated_grading_schema_cd = x_translated_grading_schema_cd)
             OR ((tlinfo.translated_grading_schema_cd IS NULL)
                 AND (x_translated_grading_schema_cd IS NULL)
                )
            )
        AND ((tlinfo.translated_version_number = x_translated_version_number)
             OR ((tlinfo.translated_version_number IS NULL)
                 AND (x_translated_version_number IS NULL)
                )
            )
        AND ((tlinfo.translated_grade = x_translated_grade)
             OR ((tlinfo.translated_grade IS NULL)
                 AND (x_translated_grade IS NULL)
                )
            )
        AND ((tlinfo.translated_dt = x_translated_dt)
             OR ((tlinfo.translated_dt IS NULL)
                 AND (x_translated_dt IS NULL)
                )
            )
        AND ((tlinfo.mark_capped_flag = x_mark_capped_flag)
             OR ((tlinfo.mark_capped_flag IS NULL)
                 AND (x_mark_capped_flag IS NULL)
                )
            )
        AND ((tlinfo.show_on_academic_histry_flag = x_show_on_academic_histry_flag)
             OR ((tlinfo.show_on_academic_histry_flag IS NULL)
                 AND (x_show_on_academic_histry_flag IS NULL)
                )
            )
        AND ((tlinfo.release_date = x_release_date)
             OR ((tlinfo.release_date IS NULL)
                 AND (x_release_date IS NULL)
                )
            )
        AND ((tlinfo.manual_override_flag = x_manual_override_flag)
             OR ((tlinfo.manual_override_flag IS NULL)
                 AND (x_manual_override_flag IS NULL)
                )
            )
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name ('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    RETURN;
  END lock_row;

  PROCEDURE update_row (
    x_rowid                        IN     VARCHAR2,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_hist_start_dt                IN     DATE,
    x_hist_end_dt                  IN     DATE,
    x_hist_who                     IN     NUMBER,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_number_times_keyed           IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2 DEFAULT 'N',
    x_show_on_academic_histry_flag IN     VARCHAR2 DEFAULT 'Y',
    x_release_date                 IN     DATE DEFAULT NULL,
    x_manual_override_flag         IN     VARCHAR2 DEFAULT 'N'
  ) IS
    x_last_update_date  DATE;
    x_last_updated_by   NUMBER;
    x_last_update_login NUMBER;
  BEGIN
    x_last_update_date := SYSDATE;

    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;

      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;

      x_last_update_login := fnd_global.login_id;

      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;

    before_dml (
      p_action                       => 'UPDATE',
      x_rowid                        => x_rowid,
      x_cal_type                     => x_cal_type,
      x_ci_sequence_number           => x_ci_sequence_number,
      x_course_cd                    => x_course_cd,
      x_finalised_outcome_ind        => x_finalised_outcome_ind,
      x_grade                        => x_grade,
      x_grading_schema_cd            => x_grading_schema_cd,
      x_hist_end_dt                  => x_hist_end_dt,
      x_hist_start_dt                => x_hist_start_dt,
      x_hist_who                     => x_hist_who,
      x_mark                         => x_mark,
      x_number_times_keyed           => x_number_times_keyed,
      x_outcome_dt                   => x_outcome_dt,
      x_person_id                    => x_person_id,
      x_s_grade_creation_method_type => x_s_grade_creation_method_type,
      x_translated_dt                => x_translated_dt,
      x_translated_grade             => x_translated_grade,
      x_translated_grading_schema_cd => x_translated_grading_schema_cd,
      x_translated_version_number    => x_translated_version_number,
      x_unit_cd                      => x_unit_cd,
      x_version_number               => x_version_number,
      x_creation_date                => x_last_update_date,
      x_created_by                   => x_last_updated_by,
      x_last_update_date             => x_last_update_date,
      x_last_updated_by              => x_last_updated_by,
      x_last_update_login            => x_last_update_login,
      x_uoo_id                       => x_uoo_id,
      x_mark_capped_flag             => x_mark_capped_flag,
      x_show_on_academic_histry_flag => x_show_on_academic_histry_flag,
      x_release_date                 => x_release_date,
      x_manual_override_flag         => x_manual_override_flag
    );

    UPDATE igs_as_su_atmptout_h_all
       SET hist_end_dt = new_references.hist_end_dt,
           hist_who = new_references.hist_who,
           grading_schema_cd = new_references.grading_schema_cd,
           version_number = new_references.version_number,
           grade = new_references.grade,
           s_grade_creation_method_type = new_references.s_grade_creation_method_type,
           finalised_outcome_ind = new_references.finalised_outcome_ind,
           mark = new_references.mark,
           number_times_keyed = new_references.number_times_keyed,
           translated_grading_schema_cd = new_references.translated_grading_schema_cd,
           translated_version_number = new_references.translated_version_number,
           translated_grade = new_references.translated_grade,
           translated_dt = new_references.translated_dt,
           last_update_date = x_last_update_date,
           last_updated_by = x_last_updated_by,
           last_update_login = x_last_update_login,
           mark_capped_flag = x_mark_capped_flag,
           show_on_academic_histry_flag = x_show_on_academic_histry_flag,
           release_date = x_release_date,
           manual_override_flag = x_manual_override_flag
     WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END update_row;

  PROCEDURE add_row (
    x_rowid                        IN OUT NOCOPY VARCHAR2,
    x_org_id                       IN     NUMBER,
    x_person_id                    IN     NUMBER,
    x_course_cd                    IN     VARCHAR2,
    x_unit_cd                      IN     VARCHAR2,
    x_cal_type                     IN     VARCHAR2,
    x_ci_sequence_number           IN     NUMBER,
    x_outcome_dt                   IN     DATE,
    x_hist_start_dt                IN     DATE,
    x_hist_end_dt                  IN     DATE,
    x_hist_who                     IN     NUMBER,
    x_grading_schema_cd            IN     VARCHAR2,
    x_version_number               IN     NUMBER,
    x_grade                        IN     VARCHAR2,
    x_s_grade_creation_method_type IN     VARCHAR2,
    x_finalised_outcome_ind        IN     VARCHAR2,
    x_mark                         IN     NUMBER,
    x_number_times_keyed           IN     NUMBER,
    x_translated_grading_schema_cd IN     VARCHAR2,
    x_translated_version_number    IN     NUMBER,
    x_translated_grade             IN     VARCHAR2,
    x_translated_dt                IN     DATE,
    x_mode                         IN     VARCHAR2 DEFAULT 'R',
    x_uoo_id                       IN     NUMBER,
    x_mark_capped_flag             IN     VARCHAR2 DEFAULT 'N',
    x_show_on_academic_histry_flag IN     VARCHAR2 DEFAULT 'Y',
    x_release_date                 IN     DATE DEFAULT NULL,
    x_manual_override_flag         IN     VARCHAR2 DEFAULT 'N'
  ) IS
    CURSOR c1 IS
      SELECT ROWID
      FROM   igs_as_su_atmptout_h_all
      WHERE  person_id = x_person_id
      AND    course_cd = x_course_cd
      AND    uoo_id = x_uoo_id
      AND    outcome_dt = x_outcome_dt
      AND    hist_start_dt = x_hist_start_dt;
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;

    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_org_id,
        x_person_id,
        x_course_cd,
        x_unit_cd,
        x_cal_type,
        x_ci_sequence_number,
        x_outcome_dt,
        x_hist_start_dt,
        x_hist_end_dt,
        x_hist_who,
        x_grading_schema_cd,
        x_version_number,
        x_grade,
        x_s_grade_creation_method_type,
        x_finalised_outcome_ind,
        x_mark,
        x_number_times_keyed,
        x_translated_grading_schema_cd,
        x_translated_version_number,
        x_translated_grade,
        x_translated_dt,
        x_mode,
        x_uoo_id,
        x_mark_capped_flag,
        x_show_on_academic_histry_flag,
        x_release_date,
        x_manual_override_flag
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
      x_outcome_dt,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_grading_schema_cd,
      x_version_number,
      x_grade,
      x_s_grade_creation_method_type,
      x_finalised_outcome_ind,
      x_mark,
      x_number_times_keyed,
      x_translated_grading_schema_cd,
      x_translated_version_number,
      x_translated_grade,
      x_translated_dt,
      x_mode,
      x_uoo_id,
      x_mark_capped_flag,
      x_show_on_academic_histry_flag,
      x_release_date,
      x_manual_override_flag
    );
  END add_row;

  PROCEDURE delete_row (x_rowid IN VARCHAR2) IS
  BEGIN
    before_dml (p_action => 'DELETE', x_rowid => x_rowid);

    DELETE FROM igs_as_su_atmptout_h_all
          WHERE ROWID = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END delete_row;

  PROCEDURE check_constraints (column_name IN VARCHAR2 DEFAULT NULL, column_value IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
    IF column_name IS NULL THEN
      NULL;
    ELSIF UPPER (column_name) = 'FINALISED_OUTCOME_IND' THEN
      new_references.finalised_outcome_ind := column_value;
    ELSIF UPPER (column_name) = 'CAL_TYPE' THEN
      new_references.cal_type := column_value;
    ELSIF UPPER (column_name) = 'COURSE_CD' THEN
      new_references.course_cd := column_value;
    ELSIF UPPER (column_name) = 'FINALISED_OUTCOME_IND' THEN
      new_references.finalised_outcome_ind := column_value;
    ELSIF UPPER (column_name) = 'GRADE' THEN
      new_references.grade := column_value;
    ELSIF UPPER (column_name) = 'GRADING_SCHEMA_CD' THEN
      new_references.grading_schema_cd := column_value;
    ELSIF UPPER (column_name) = 'S_GRADE_CREATION_METHOD_TYPE' THEN
      new_references.s_grade_creation_method_type := column_value;
    ELSIF UPPER (column_name) = 'TRANSLATED_GRADE' THEN
      new_references.translated_grade := column_value;
    ELSIF UPPER (column_name) = 'TRANSLATED_GRADING_SCHEMA_CD' THEN
      new_references.translated_grading_schema_cd := column_value;
    ELSIF UPPER (column_name) = 'UNIT_CD' THEN
      new_references.unit_cd := column_value;
    ELSIF UPPER (column_name) = 'CI_SEQUENCE_NUMBER' THEN
      new_references.ci_sequence_number := igs_ge_number.to_num (column_value);
    END IF;

    IF UPPER (column_name) = 'FINALISED_OUTCOME_IND'
       OR column_name IS NULL THEN
      IF new_references.finalised_outcome_ind NOT IN ('Y', 'N') THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER (column_name) = 'CAL_TYPE'
       OR column_name IS NULL THEN
      IF new_references.cal_type <> UPPER (new_references.cal_type) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER (column_name) = 'COURSE_CD'
       OR column_name IS NULL THEN
      IF new_references.course_cd <> UPPER (new_references.course_cd) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER (column_name) = 'FINALISED_OUTCOME_IND'
       OR column_name IS NULL THEN
      IF new_references.finalised_outcome_ind <> UPPER (new_references.finalised_outcome_ind) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER (column_name) = 'GRADE'
       OR column_name IS NULL THEN
      IF new_references.grade <> UPPER (new_references.grade) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER (column_name) = 'GRADING_SCHEMA_CD'
       OR column_name IS NULL THEN
      IF new_references.grading_schema_cd <> UPPER (new_references.grading_schema_cd) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER (column_name) = 'S_GRADE_CREATION_METHOD_TYPE'
       OR column_name IS NULL THEN
      IF new_references.s_grade_creation_method_type <> UPPER (new_references.s_grade_creation_method_type) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER (column_name) = 'TRANSLATED_GRADING_SCHEMA_CD'
       OR column_name IS NULL THEN
      IF new_references.translated_grading_schema_cd <> UPPER (new_references.translated_grading_schema_cd) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER (column_name) = 'UNIT_CD'
       OR column_name IS NULL THEN
      IF new_references.unit_cd <> UPPER (new_references.unit_cd) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER (column_name) = 'TRANSLATED_GRADE'
       OR column_name IS NULL THEN
      IF new_references.translated_grade <> UPPER (new_references.translated_grade) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER (column_name) = 'CI_SEQUENCE_NUMBER'
       OR column_name IS NULL THEN
      IF new_references.ci_sequence_number < 1
         OR new_references.ci_sequence_number > 99999 THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
  END check_constraints;
END igs_as_su_atmptout_h_pkg;

/
