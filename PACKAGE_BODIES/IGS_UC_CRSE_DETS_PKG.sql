--------------------------------------------------------
--  DDL for Package Body IGS_UC_CRSE_DETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_CRSE_DETS_PKG" AS
/* $Header: IGSXI14B.pls 115.12 2003/06/11 10:57:55 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_crse_dets%ROWTYPE;
  new_references igs_uc_crse_dets%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER  ,
    x_institute                         IN     VARCHAR2,
    x_uvcourse_updater                  IN     VARCHAR2,
    x_uvcrsevac_updater                 IN     VARCHAR2,
    x_short_title                       IN     VARCHAR2,
    x_long_title                        IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_total_no_of_seats                 IN     NUMBER  ,
    x_min_entry_points                  IN     NUMBER  ,
    x_max_entry_points                  IN     NUMBER  ,
    x_current_validity                  IN     VARCHAR2,
    x_deferred_validity                 IN     VARCHAR2,
    x_term_1_start                      IN     DATE    ,
    x_term_1_end                        IN     DATE    ,
    x_term_2_start                      IN     DATE    ,
    x_term_2_end                        IN     DATE    ,
    x_term_3_start                      IN     DATE    ,
    x_term_3_end                        IN     DATE    ,
    x_term_4_start                      IN     DATE    ,
    x_term_4_end                        IN     DATE    ,
    x_cl_updated                        IN     VARCHAR2,
    x_cl_date                           IN     DATE    ,
    x_vacancy_status                    IN     VARCHAR2,
    x_no_of_vacancy                     IN     VARCHAR2,
    x_score                             IN     NUMBER  ,
    x_rb_full                           IN     VARCHAR2,
    x_scot_vac                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_ucas_system_id                    IN     NUMBER  ,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_joint_admission_ind               IN     VARCHAR2,
    x_open_extra_ind                    IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_clearing_options                  IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_keywrds_changed                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali    10-jun-03    obsoleting timestamp columns for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_CRSE_DETS
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
    new_references.ucas_program_code                 := x_ucas_program_code;
    new_references.oss_program_code                  := x_oss_program_code;
    new_references.oss_program_version               := x_oss_program_version;
    new_references.institute                         := x_institute;
    new_references.uvcourse_updater                  := x_uvcourse_updater;
    new_references.uvcrsevac_updater                 := x_uvcrsevac_updater;
    new_references.short_title                       := x_short_title;
    new_references.long_title                        := x_long_title;
    new_references.ucas_campus                       := x_ucas_campus;
    new_references.oss_location                      := x_oss_location;
    new_references.faculty                           := x_faculty;
    new_references.total_no_of_seats                 := x_total_no_of_seats;
    new_references.min_entry_points                  := x_min_entry_points;
    new_references.max_entry_points                  := x_max_entry_points;
    new_references.current_validity                  := x_current_validity;
    new_references.deferred_validity                 := x_deferred_validity;
    new_references.term_1_start                      := x_term_1_start;
    new_references.term_1_end                        := x_term_1_end;
    new_references.term_2_start                      := x_term_2_start;
    new_references.term_2_end                        := x_term_2_end;
    new_references.term_3_start                      := x_term_3_start;
    new_references.term_3_end                        := x_term_3_end;
    new_references.term_4_start                      := x_term_4_start;
    new_references.term_4_end                        := x_term_4_end;
    new_references.cl_updated                        := x_cl_updated;
    new_references.cl_date                           := x_cl_date;
    new_references.vacancy_status                    := x_vacancy_status;
    new_references.no_of_vacancy                     := x_no_of_vacancy;
    new_references.score                             := x_score;
    new_references.rb_full                           := x_rb_full;
    new_references.scot_vac                          := x_scot_vac;
    new_references.sent_to_ucas                      := x_sent_to_ucas;
    new_references.ucas_system_id                    := x_ucas_system_id;
    new_references.oss_attendance_type               := x_oss_attendance_type;
    new_references.oss_attendance_mode               := x_oss_attendance_mode;
    new_references.joint_admission_ind               := x_joint_admission_ind;
    new_references.open_extra_ind                    := x_open_extra_ind;
    new_references.system_code                       := x_system_code;
    new_references.clearing_options                  := x_clearing_options;
    new_references.imported                          := x_imported;
    new_references.keywrds_changed                   := x_keywrds_changed;

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
  ||  Created By : Nalin.Kumar@oracle.com
  ||  Created On : 11-APR-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.system_code = new_references.system_code)) OR
        ((new_references.system_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_defaults_pkg.get_pk_for_validation (
                new_references.system_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2 ,
    x_system_code                       IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_crse_dets
      WHERE    ucas_program_code = x_ucas_program_code
      AND      institute = x_institute
      AND      ucas_campus = x_ucas_campus
      AND      system_code = x_system_code ;

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

  PROCEDURE get_fk_igs_uc_defaults (
    x_system_code                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sunitha maddali
  ||  Created On : 10-Jun-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_crse_dets
      WHERE   ((system_code = x_system_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCCSDE_UAS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_defaults;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER  ,
    x_institute                         IN     VARCHAR2,
    x_uvcourse_updater                  IN     VARCHAR2,
    x_uvcrsevac_updater                 IN     VARCHAR2,
    x_short_title                       IN     VARCHAR2,
    x_long_title                        IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_total_no_of_seats                 IN     NUMBER  ,
    x_min_entry_points                  IN     NUMBER  ,
    x_max_entry_points                  IN     NUMBER  ,
    x_current_validity                  IN     VARCHAR2,
    x_deferred_validity                 IN     VARCHAR2,
    x_term_1_start                      IN     DATE    ,
    x_term_1_end                        IN     DATE    ,
    x_term_2_start                      IN     DATE    ,
    x_term_2_end                        IN     DATE    ,
    x_term_3_start                      IN     DATE    ,
    x_term_3_end                        IN     DATE    ,
    x_term_4_start                      IN     DATE    ,
    x_term_4_end                        IN     DATE    ,
    x_cl_updated                        IN     VARCHAR2,
    x_cl_date                           IN     DATE    ,
    x_vacancy_status                    IN     VARCHAR2,
    x_no_of_vacancy                     IN     VARCHAR2,
    x_score                             IN     NUMBER  ,
    x_rb_full                           IN     VARCHAR2,
    x_scot_vac                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_ucas_system_id                    IN     NUMBER  ,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_joint_admission_ind               IN     VARCHAR2,
    x_open_extra_ind                    IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_clearing_options                  IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_keywrds_changed                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali    10-jun-03    obsoleting timestamp columns for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_ucas_program_code,
      x_oss_program_code,
      x_oss_program_version,
      x_institute,
      x_uvcourse_updater,
      x_uvcrsevac_updater,
      x_short_title,
      x_long_title,
      x_ucas_campus,
      x_oss_location,
      x_faculty,
      x_total_no_of_seats,
      x_min_entry_points,
      x_max_entry_points,
      x_current_validity,
      x_deferred_validity,
      x_term_1_start,
      x_term_1_end,
      x_term_2_start,
      x_term_2_end,
      x_term_3_start,
      x_term_3_end,
      x_term_4_start,
      x_term_4_end,
      x_cl_updated,
      x_cl_date,
      x_vacancy_status,
      x_no_of_vacancy,
      x_score,
      x_rb_full,
      x_scot_vac,
      x_sent_to_ucas,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_ucas_system_id,
      x_oss_attendance_type,
      x_oss_attendance_mode,
      x_joint_admission_ind,
      x_open_extra_ind  ,
      x_system_code ,
      x_clearing_options ,
      x_imported         ,
      x_keywrds_changed
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ucas_program_code,
             new_references.institute,
             new_references.ucas_campus,
             new_references.system_code           )
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
             new_references.ucas_program_code,
             new_references.institute,
             new_references.ucas_campus,
             new_references.system_code
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
    x_ucas_program_code                 IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_institute                         IN     VARCHAR2,
    x_uvcourse_updater                  IN     VARCHAR2,
    x_uvcrsevac_updater                 IN     VARCHAR2,
    x_short_title                       IN     VARCHAR2,
    x_long_title                        IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_total_no_of_seats                 IN     NUMBER,
    x_min_entry_points                  IN     NUMBER,
    x_max_entry_points                  IN     NUMBER,
    x_current_validity                  IN     VARCHAR2,
    x_deferred_validity                 IN     VARCHAR2,
    x_term_1_start                      IN     DATE,
    x_term_1_end                        IN     DATE,
    x_term_2_start                      IN     DATE,
    x_term_2_end                        IN     DATE,
    x_term_3_start                      IN     DATE,
    x_term_3_end                        IN     DATE,
    x_term_4_start                      IN     DATE,
    x_term_4_end                        IN     DATE,
    x_cl_updated                        IN     VARCHAR2,
    x_cl_date                           IN     DATE,
    x_vacancy_status                    IN     VARCHAR2,
    x_no_of_vacancy                     IN     VARCHAR2,
    x_score                             IN     NUMBER,
    x_rb_full                           IN     VARCHAR2,
    x_scot_vac                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_ucas_system_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_joint_admission_ind               IN     VARCHAR2,
    x_open_extra_ind                    IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_clearing_options                  IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_keywrds_changed                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali    10-jun-03    obsoleting timestamp columns for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_crse_dets
      WHERE    ucas_program_code                 = x_ucas_program_code
      AND      institute                         = x_institute
      AND      ucas_campus                       = x_ucas_campus;

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
      x_ucas_program_code                 => x_ucas_program_code,
      x_oss_program_code                  => x_oss_program_code,
      x_oss_program_version               => x_oss_program_version,
      x_institute                         => x_institute,
      x_uvcourse_updater                  => x_uvcourse_updater,
      x_uvcrsevac_updater                 => x_uvcrsevac_updater,
      x_short_title                       => x_short_title,
      x_long_title                        => x_long_title,
      x_ucas_campus                       => x_ucas_campus,
      x_oss_location                      => x_oss_location,
      x_faculty                           => x_faculty,
      x_total_no_of_seats                 => x_total_no_of_seats,
      x_min_entry_points                  => x_min_entry_points,
      x_max_entry_points                  => x_max_entry_points,
      x_current_validity                  => x_current_validity,
      x_deferred_validity                 => x_deferred_validity,
      x_term_1_start                      => x_term_1_start,
      x_term_1_end                        => x_term_1_end,
      x_term_2_start                      => x_term_2_start,
      x_term_2_end                        => x_term_2_end,
      x_term_3_start                      => x_term_3_start,
      x_term_3_end                        => x_term_3_end,
      x_term_4_start                      => x_term_4_start,
      x_term_4_end                        => x_term_4_end,
      x_cl_updated                        => x_cl_updated,
      x_cl_date                           => x_cl_date,
      x_vacancy_status                    => x_vacancy_status,
      x_no_of_vacancy                     => x_no_of_vacancy,
      x_score                             => x_score,
      x_rb_full                           => x_rb_full,
      x_scot_vac                          => x_scot_vac,
      x_sent_to_ucas                      => x_sent_to_ucas,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_ucas_system_id                    => x_ucas_system_id,
      x_oss_attendance_type               => x_oss_attendance_type,
      x_oss_attendance_mode               => x_oss_attendance_mode,
      x_joint_admission_ind               => x_joint_admission_ind,
      x_open_extra_ind                    => x_open_extra_ind     ,
      x_system_code                       => x_system_code,
      x_clearing_options                  => x_clearing_options,
      x_imported                          => x_imported,
      x_keywrds_changed                   => x_keywrds_changed
    );

    INSERT INTO igs_uc_crse_dets (
      ucas_program_code,
      oss_program_code,
      oss_program_version,
      institute,
      uvcourse_updater,
      uvcrsevac_updater,
      short_title,
      long_title,
      ucas_campus,
      oss_location,
      faculty,
      total_no_of_seats,
      min_entry_points,
      max_entry_points,
      current_validity,
      deferred_validity,
      term_1_start,
      term_1_end,
      term_2_start,
      term_2_end,
      term_3_start,
      term_3_end,
      term_4_start,
      term_4_end,
      cl_updated,
      cl_date,
      vacancy_status,
      no_of_vacancy,
      score,
      rb_full,
      scot_vac,
      sent_to_ucas,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      ucas_system_id,
      oss_attendance_type,
      oss_attendance_mode,
      joint_admission_ind,
      open_extra_ind ,
      clearing_options,
      imported,
      system_code,
      keywrds_changed
    ) VALUES (
      new_references.ucas_program_code,
      new_references.oss_program_code,
      new_references.oss_program_version,
      new_references.institute,
      new_references.uvcourse_updater,
      new_references.uvcrsevac_updater,
      new_references.short_title,
      new_references.long_title,
      new_references.ucas_campus,
      new_references.oss_location,
      new_references.faculty,
      new_references.total_no_of_seats,
      new_references.min_entry_points,
      new_references.max_entry_points,
      new_references.current_validity,
      new_references.deferred_validity,
      new_references.term_1_start,
      new_references.term_1_end,
      new_references.term_2_start,
      new_references.term_2_end,
      new_references.term_3_start,
      new_references.term_3_end,
      new_references.term_4_start,
      new_references.term_4_end,
      new_references.cl_updated,
      new_references.cl_date,
      new_references.vacancy_status,
      new_references.no_of_vacancy,
      new_references.score,
      new_references.rb_full,
      new_references.scot_vac,
      new_references.sent_to_ucas,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.ucas_system_id,
      new_references.oss_attendance_type,
      new_references.oss_attendance_mode,
      new_references.joint_admission_ind,
      new_references.open_extra_ind,
      new_references.clearing_options,
      new_references.imported,
      new_references.system_code ,
      new_references.keywrds_changed
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
    x_ucas_program_code                 IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_institute                         IN     VARCHAR2,
    x_uvcourse_updater                  IN     VARCHAR2,
    x_uvcrsevac_updater                 IN     VARCHAR2,
    x_short_title                       IN     VARCHAR2,
    x_long_title                        IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_total_no_of_seats                 IN     NUMBER,
    x_min_entry_points                  IN     NUMBER,
    x_max_entry_points                  IN     NUMBER,
    x_current_validity                  IN     VARCHAR2,
    x_deferred_validity                 IN     VARCHAR2,
    x_term_1_start                      IN     DATE,
    x_term_1_end                        IN     DATE,
    x_term_2_start                      IN     DATE,
    x_term_2_end                        IN     DATE,
    x_term_3_start                      IN     DATE,
    x_term_3_end                        IN     DATE,
    x_term_4_start                      IN     DATE,
    x_term_4_end                        IN     DATE,
    x_cl_updated                        IN     VARCHAR2,
    x_cl_date                           IN     DATE,
    x_vacancy_status                    IN     VARCHAR2,
    x_no_of_vacancy                     IN     VARCHAR2,
    x_score                             IN     NUMBER,
    x_rb_full                           IN     VARCHAR2,
    x_scot_vac                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_ucas_system_id                    IN     NUMBER,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_joint_admission_ind               IN     VARCHAR2,
    x_open_extra_ind                    IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_clearing_options                  IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_keywrds_changed                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali    10-jun-03    obsoleting timestamp columns for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        oss_program_code,
        oss_program_version,
        uvcourse_updater,
        uvcrsevac_updater,
        short_title,
        long_title,
        oss_location,
        faculty,
        total_no_of_seats,
        min_entry_points,
        max_entry_points,
        current_validity,
        deferred_validity,
        term_1_start,
        term_1_end,
        term_2_start,
        term_2_end,
        term_3_start,
        term_3_end,
        term_4_start,
        term_4_end,
        cl_updated,
        cl_date,
        vacancy_status,
        no_of_vacancy,
        score,
        rb_full,
        scot_vac,
        sent_to_ucas,
        ucas_system_id,
        oss_attendance_type,
        oss_attendance_mode,
        joint_admission_ind,
        open_extra_ind  ,
        system_code ,
        clearing_options,
        imported,
        keywrds_changed
      FROM  igs_uc_crse_dets
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
        ((tlinfo.oss_program_code = x_oss_program_code) OR ((tlinfo.oss_program_code IS NULL) AND (X_oss_program_code IS NULL)))
        AND ((tlinfo.oss_program_version = x_oss_program_version) OR ((tlinfo.oss_program_version IS NULL) AND (X_oss_program_version IS NULL)))
        AND (tlinfo.uvcourse_updater = x_uvcourse_updater)
        AND (tlinfo.uvcrsevac_updater = x_uvcrsevac_updater)
        AND ((tlinfo.short_title = x_short_title) OR ((tlinfo.short_title IS NULL) AND (X_short_title IS NULL)))
        AND ((tlinfo.long_title = x_long_title) OR ((tlinfo.long_title IS NULL) AND (X_long_title IS NULL)))
        AND ((tlinfo.oss_location = x_oss_location) OR ((tlinfo.oss_location IS NULL) AND (X_oss_location IS NULL)))
        AND ((tlinfo.faculty = x_faculty) OR ((tlinfo.faculty IS NULL) AND (X_faculty IS NULL)))
        AND ((tlinfo.total_no_of_seats = x_total_no_of_seats) OR ((tlinfo.total_no_of_seats IS NULL) AND (X_total_no_of_seats IS NULL)))
        AND ((tlinfo.min_entry_points = x_min_entry_points) OR ((tlinfo.min_entry_points IS NULL) AND (X_min_entry_points IS NULL)))
        AND ((tlinfo.max_entry_points = x_max_entry_points) OR ((tlinfo.max_entry_points IS NULL) AND (X_max_entry_points IS NULL)))
        AND ((tlinfo.current_validity = x_current_validity) OR ((tlinfo.current_validity IS NULL) AND (X_current_validity IS NULL)))
        AND ((tlinfo.deferred_validity = x_deferred_validity) OR ((tlinfo.deferred_validity IS NULL) AND (X_deferred_validity IS NULL)))
        AND ((tlinfo.term_1_start = x_term_1_start) OR ((tlinfo.term_1_start IS NULL) AND (X_term_1_start IS NULL)))
        AND ((tlinfo.term_1_end = x_term_1_end) OR ((tlinfo.term_1_end IS NULL) AND (X_term_1_end IS NULL)))
        AND ((tlinfo.term_2_start = x_term_2_start) OR ((tlinfo.term_2_start IS NULL) AND (X_term_2_start IS NULL)))
        AND ((tlinfo.term_2_end = x_term_2_end) OR ((tlinfo.term_2_end IS NULL) AND (X_term_2_end IS NULL)))
        AND ((tlinfo.term_3_start = x_term_3_start) OR ((tlinfo.term_3_start IS NULL) AND (X_term_3_start IS NULL)))
        AND ((tlinfo.term_3_end = x_term_3_end) OR ((tlinfo.term_3_end IS NULL) AND (X_term_3_end IS NULL)))
        AND ((tlinfo.term_4_start = x_term_4_start) OR ((tlinfo.term_4_start IS NULL) AND (X_term_4_start IS NULL)))
        AND ((tlinfo.term_4_end = x_term_4_end) OR ((tlinfo.term_4_end IS NULL) AND (X_term_4_end IS NULL)))
        AND ((tlinfo.cl_updated = x_cl_updated) OR ((tlinfo.cl_updated IS NULL) AND (X_cl_updated IS NULL)))
        AND ((tlinfo.cl_date = x_cl_date) OR ((tlinfo.cl_date IS NULL) AND (X_cl_date IS NULL)))
        AND ((tlinfo.vacancy_status = x_vacancy_status) OR ((tlinfo.vacancy_status IS NULL) AND (X_vacancy_status IS NULL)))
        AND ((tlinfo.no_of_vacancy = x_no_of_vacancy) OR ((tlinfo.no_of_vacancy IS NULL) AND (X_no_of_vacancy IS NULL)))
        AND ((tlinfo.score = x_score) OR ((tlinfo.score IS NULL) AND (X_score IS NULL)))
        AND ((tlinfo.rb_full = x_rb_full) OR ((tlinfo.rb_full IS NULL) AND (X_rb_full IS NULL)))
        AND ((tlinfo.scot_vac = x_scot_vac) OR ((tlinfo.scot_vac IS NULL) AND (X_scot_vac IS NULL)))
        AND (tlinfo.sent_to_ucas = x_sent_to_ucas)
        AND ((tlinfo.ucas_system_id = x_ucas_system_id) OR ((tlinfo.ucas_system_id IS NULL) AND (X_ucas_system_id IS NULL)))
        AND ((tlinfo.oss_attendance_type = x_oss_attendance_type) OR (( tlinfo.oss_attendance_type IS NULL) AND (x_oss_attendance_type IS NULL)))
        AND ((tlinfo.oss_attendance_mode = x_oss_attendance_mode) OR (( tlinfo.oss_attendance_mode IS NULL) AND (x_oss_attendance_mode IS NULL)))
        AND ((tlinfo.joint_admission_ind = x_joint_admission_ind) OR (( tlinfo.joint_admission_ind IS NULL) AND (x_joint_admission_ind IS NULL)))
        AND ((tlinfo.open_extra_ind = x_open_extra_ind) OR (( tlinfo.open_extra_ind IS NULL) AND (x_open_extra_ind IS NULL)))
        AND ((tlinfo.clearing_options = x_clearing_options) OR (( tlinfo.clearing_options IS NULL) AND (x_clearing_options IS NULL)))
        AND ((tlinfo.imported = x_imported) OR (( tlinfo.imported IS NULL) AND (x_imported IS NULL)))
        AND ((tlinfo.keywrds_changed = x_keywrds_changed) OR (( tlinfo.keywrds_changed IS NULL) AND (x_keywrds_changed IS NULL)))
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
    x_ucas_program_code                 IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_institute                         IN     VARCHAR2,
    x_uvcourse_updater                  IN     VARCHAR2,
    x_uvcrsevac_updater                 IN     VARCHAR2,
    x_short_title                       IN     VARCHAR2,
    x_long_title                        IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_total_no_of_seats                 IN     NUMBER,
    x_min_entry_points                  IN     NUMBER,
    x_max_entry_points                  IN     NUMBER,
    x_current_validity                  IN     VARCHAR2,
    x_deferred_validity                 IN     VARCHAR2,
    x_term_1_start                      IN     DATE,
    x_term_1_end                        IN     DATE,
    x_term_2_start                      IN     DATE,
    x_term_2_end                        IN     DATE,
    x_term_3_start                      IN     DATE,
    x_term_3_end                        IN     DATE,
    x_term_4_start                      IN     DATE,
    x_term_4_end                        IN     DATE,
    x_cl_updated                        IN     VARCHAR2,
    x_cl_date                           IN     DATE,
    x_vacancy_status                    IN     VARCHAR2,
    x_no_of_vacancy                     IN     VARCHAR2,
    x_score                             IN     NUMBER,
    x_rb_full                           IN     VARCHAR2,
    x_scot_vac                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_ucas_system_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_joint_admission_ind               IN     VARCHAR2,
    x_open_extra_ind                    IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_clearing_options                  IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_keywrds_changed                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali    10-jun-03    obsoleting timestamp columns for ucfd203 - multiple cycles build , bug#2669208
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
      x_ucas_program_code                 => x_ucas_program_code,
      x_oss_program_code                  => x_oss_program_code,
      x_oss_program_version               => x_oss_program_version,
      x_institute                         => x_institute,
      x_uvcourse_updater                  => x_uvcourse_updater,
      x_uvcrsevac_updater                 => x_uvcrsevac_updater,
      x_short_title                       => x_short_title,
      x_long_title                        => x_long_title,
      x_ucas_campus                       => x_ucas_campus,
      x_oss_location                      => x_oss_location,
      x_faculty                           => x_faculty,
      x_total_no_of_seats                 => x_total_no_of_seats,
      x_min_entry_points                  => x_min_entry_points,
      x_max_entry_points                  => x_max_entry_points,
      x_current_validity                  => x_current_validity,
      x_deferred_validity                 => x_deferred_validity,
      x_term_1_start                      => x_term_1_start,
      x_term_1_end                        => x_term_1_end,
      x_term_2_start                      => x_term_2_start,
      x_term_2_end                        => x_term_2_end,
      x_term_3_start                      => x_term_3_start,
      x_term_3_end                        => x_term_3_end,
      x_term_4_start                      => x_term_4_start,
      x_term_4_end                        => x_term_4_end,
      x_cl_updated                        => x_cl_updated,
      x_cl_date                           => x_cl_date,
      x_vacancy_status                    => x_vacancy_status,
      x_no_of_vacancy                     => x_no_of_vacancy,
      x_score                             => x_score,
      x_rb_full                           => x_rb_full,
      x_scot_vac                          => x_scot_vac,
      x_sent_to_ucas                      => x_sent_to_ucas,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_ucas_system_id                    => x_ucas_system_id,
      x_oss_attendance_type               => x_oss_attendance_type,
      x_oss_attendance_mode               => x_oss_attendance_mode,
      x_joint_admission_ind               => x_joint_admission_ind,
      x_open_extra_ind                    => x_open_extra_ind,
      x_system_code                       => x_system_code,
      x_clearing_options                  => x_clearing_options,
      x_imported                          => x_imported ,
      x_keywrds_changed                   => x_keywrds_changed
    );

    UPDATE igs_uc_crse_dets
      SET
        oss_program_code                  = new_references.oss_program_code,
        oss_program_version               = new_references.oss_program_version,
        uvcourse_updater                  = new_references.uvcourse_updater,
        uvcrsevac_updater                 = new_references.uvcrsevac_updater,
        short_title                       = new_references.short_title,
        long_title                        = new_references.long_title,
        oss_location                      = new_references.oss_location,
        faculty                           = new_references.faculty,
        total_no_of_seats                 = new_references.total_no_of_seats,
        min_entry_points                  = new_references.min_entry_points,
        max_entry_points                  = new_references.max_entry_points,
        current_validity                  = new_references.current_validity,
        deferred_validity                 = new_references.deferred_validity,
        term_1_start                      = new_references.term_1_start,
        term_1_end                        = new_references.term_1_end,
        term_2_start                      = new_references.term_2_start,
        term_2_end                        = new_references.term_2_end,
        term_3_start                      = new_references.term_3_start,
        term_3_end                        = new_references.term_3_end,
        term_4_start                      = new_references.term_4_start,
        term_4_end                        = new_references.term_4_end,
        cl_updated                        = new_references.cl_updated,
        cl_date                           = new_references.cl_date,
        vacancy_status                    = new_references.vacancy_status,
        no_of_vacancy                     = new_references.no_of_vacancy,
        score                             = new_references.score,
        rb_full                           = new_references.rb_full,
        scot_vac                          = new_references.scot_vac,
        sent_to_ucas                      = new_references.sent_to_ucas,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        ucas_system_id                    = new_references.ucas_system_id,
        oss_attendance_type               = new_references.oss_attendance_type,
        oss_attendance_mode               = new_references.oss_attendance_mode,
	joint_admission_ind               = new_references.joint_admission_ind,
        open_extra_ind                    = new_references.open_extra_ind,
        clearing_options                  = new_references.clearing_options,
        imported                          = new_references.imported ,
        keywrds_changed                   = new_references.keywrds_changed
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_institute                         IN     VARCHAR2,
    x_uvcourse_updater                  IN     VARCHAR2,
    x_uvcrsevac_updater                 IN     VARCHAR2,
    x_short_title                       IN     VARCHAR2,
    x_long_title                        IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_total_no_of_seats                 IN     NUMBER,
    x_min_entry_points                  IN     NUMBER,
    x_max_entry_points                  IN     NUMBER,
    x_current_validity                  IN     VARCHAR2,
    x_deferred_validity                 IN     VARCHAR2,
    x_term_1_start                      IN     DATE,
    x_term_1_end                        IN     DATE,
    x_term_2_start                      IN     DATE,
    x_term_2_end                        IN     DATE,
    x_term_3_start                      IN     DATE,
    x_term_3_end                        IN     DATE,
    x_term_4_start                      IN     DATE,
    x_term_4_end                        IN     DATE,
    x_cl_updated                        IN     VARCHAR2,
    x_cl_date                           IN     DATE,
    x_vacancy_status                    IN     VARCHAR2,
    x_no_of_vacancy                     IN     VARCHAR2,
    x_score                             IN     NUMBER,
    x_rb_full                           IN     VARCHAR2,
    x_scot_vac                          IN     VARCHAR2,
    x_sent_to_ucas                      IN     VARCHAR2,
    x_ucas_system_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_joint_admission_ind               IN     VARCHAR2,
    x_open_extra_ind                    IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_clearing_options                  IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_keywrds_changed                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali    10-jun-03    obsoleting timestamp columns for ucfd203 - multiple cycles build , bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_crse_dets
      WHERE    ucas_program_code                 = x_ucas_program_code
      AND      institute                         = x_institute
      AND      ucas_campus                       = x_ucas_campus;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ucas_program_code,
        x_oss_program_code,
        x_oss_program_version,
        x_institute,
        x_uvcourse_updater,
        x_uvcrsevac_updater,
        x_short_title,
        x_long_title,
        x_ucas_campus,
        x_oss_location,
        x_faculty,
        x_total_no_of_seats,
        x_min_entry_points,
        x_max_entry_points,
        x_current_validity,
        x_deferred_validity,
        x_term_1_start,
        x_term_1_end,
        x_term_2_start,
        x_term_2_end,
        x_term_3_start,
        x_term_3_end,
        x_term_4_start,
        x_term_4_end,
        x_cl_updated,
        x_cl_date,
        x_vacancy_status,
        x_no_of_vacancy,
        x_score,
        x_rb_full,
        x_scot_vac,
        x_sent_to_ucas,
        x_ucas_system_id,
        x_mode,
        x_oss_attendance_type,
        x_oss_attendance_mode,
        x_joint_admission_ind,
        x_open_extra_ind ,
        x_system_code         ,
        x_clearing_options  ,
        x_imported      ,
        x_keywrds_changed
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ucas_program_code,
      x_oss_program_code,
      x_oss_program_version,
      x_institute,
      x_uvcourse_updater,
      x_uvcrsevac_updater,
      x_short_title,
      x_long_title,
      x_ucas_campus,
      x_oss_location,
      x_faculty,
      x_total_no_of_seats,
      x_min_entry_points,
      x_max_entry_points,
      x_current_validity,
      x_deferred_validity,
      x_term_1_start,
      x_term_1_end,
      x_term_2_start,
      x_term_2_end,
      x_term_3_start,
      x_term_3_end,
      x_term_4_start,
      x_term_4_end,
      x_cl_updated,
      x_cl_date,
      x_vacancy_status,
      x_no_of_vacancy,
      x_score,
      x_rb_full,
      x_scot_vac,
      x_sent_to_ucas,
      x_ucas_system_id,
      x_mode,
      x_oss_attendance_type,
      x_oss_attendance_mode,
      x_joint_admission_ind,
      x_open_extra_ind ,
      x_system_code     ,
      x_clearing_options ,
      x_imported      ,
      x_keywrds_changed
    );

  END add_row;


END igs_uc_crse_dets_pkg;

/
