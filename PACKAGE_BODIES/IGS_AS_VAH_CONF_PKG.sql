--------------------------------------------------------
--  DDL for Package Body IGS_AS_VAH_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_VAH_CONF_PKG" AS
/* $Header: IGSDI77B.pls 115.2 2003/12/08 10:07:19 ijeddy noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_as_vah_conf%ROWTYPE;
  new_references igs_as_vah_conf%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_configuration_id                  IN     NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_display_order_flag                IN     VARCHAR2,
    x_start_note_flag                   IN     VARCHAR2,
    x_program_region_flag               IN     VARCHAR2,
    x_test_score_flag                   IN     VARCHAR2,
    x_sum_adv_stnd_flag                 IN     VARCHAR2,
    x_admission_note_flag               IN     VARCHAR2,
    x_term_region_flag                  IN     VARCHAR2,
    x_unit_details_flag                 IN     VARCHAR2,
    x_unit_note_flag                    IN     VARCHAR2,
    x_adv_stnd_unit_flag                IN     VARCHAR2,
    x_adv_stnd_unit_level_flag          IN     VARCHAR2,
    x_statistics_flag                   IN     VARCHAR2,
    x_class_rank_flag                   IN     VARCHAR2,
    x_intermission_flag                 IN     VARCHAR2,
    x_special_req_flag                  IN     VARCHAR2,
    x_period_note_flag                  IN     VARCHAR2,
    x_unit_set_flag                     IN     VARCHAR2,
    x_awards_flag                       IN     VARCHAR2,
    x_prog_completion_flag              IN     VARCHAR2,
    x_degree_note_flag                  IN     VARCHAR2,
    x_end_note_flag                     IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER ,
    x_unt_lvl_marks_flag                IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : rvangala@oracle.com
  ||  Created On : 18-SEP-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_as_vah_conf
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
    new_references.configuration_id                  := x_configuration_id;
    new_references.course_type                       := x_course_type;
    new_references.display_order_flag                := x_display_order_flag;
    new_references.start_note_flag                   := x_start_note_flag;
    new_references.program_region_flag               := x_program_region_flag;
    new_references.test_score_flag                   := x_test_score_flag;
    new_references.sum_adv_stnd_flag                 := x_sum_adv_stnd_flag;
    new_references.admission_note_flag               := x_admission_note_flag;
    new_references.term_region_flag                  := x_term_region_flag;
    new_references.unit_details_flag                 := x_unit_details_flag;
    new_references.unit_note_flag                    := x_unit_note_flag;
    new_references.adv_stnd_unit_flag                := x_adv_stnd_unit_flag;
    new_references.adv_stnd_unit_level_flag          := x_adv_stnd_unit_level_flag;
    new_references.statistics_flag                   := x_statistics_flag;
    new_references.class_rank_flag                   := x_class_rank_flag;
    new_references.intermission_flag                 := x_intermission_flag;
    new_references.special_req_flag                  := x_special_req_flag;
    new_references.period_note_flag                  := x_period_note_flag;
    new_references.unit_set_flag                     := x_unit_set_flag;
    new_references.awards_flag                       := x_awards_flag;
    new_references.prog_completion_flag              := x_prog_completion_flag;
    new_references.degree_note_flag                  := x_degree_note_flag;
    new_references.end_note_flag                     := x_end_note_flag;

    new_references.unt_lvl_marks_flag              := x_unt_lvl_marks_flag;

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
  ||  Created By : rvangala@oracle.com
  ||  Created On : 18-SEP-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF (get_uk_for_validation (
          new_references.course_type
        )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : rvangala@oracle.com
  ||  Created On : 18-SEP-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

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

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_configuration_id                  IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rvangala@oracle.com
  ||  Created On : 18-SEP-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_as_vah_conf
      WHERE    configuration_id = x_configuration_id
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
    x_course_type                       IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rvangala@oracle.com
  ||  Created On : 18-SEP-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_as_vah_conf
      WHERE    ((course_type = x_course_type) OR (course_type IS NULL AND x_course_type IS NULL))
      AND      ((l_rowid IS NULL) OR (ROWID <> l_rowid));
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
  END get_uk_for_validation;

  PROCEDURE get_fk_igs_ps_type (
    x_course_type                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rvangala@oracle.com
  ||  Created On : 18-SEP-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_vah_conf
      WHERE   ((course_type = x_course_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_type;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_configuration_id                  IN     NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_display_order_flag                IN     VARCHAR2,
    x_start_note_flag                   IN     VARCHAR2,
    x_program_region_flag               IN     VARCHAR2,
    x_test_score_flag                   IN     VARCHAR2,
    x_sum_adv_stnd_flag                 IN     VARCHAR2,
    x_admission_note_flag               IN     VARCHAR2,
    x_term_region_flag                  IN     VARCHAR2,
    x_unit_details_flag                 IN     VARCHAR2,
    x_unit_note_flag                    IN     VARCHAR2,
    x_adv_stnd_unit_flag                IN     VARCHAR2,
    x_adv_stnd_unit_level_flag          IN     VARCHAR2,
    x_statistics_flag                   IN     VARCHAR2,
    x_class_rank_flag                   IN     VARCHAR2,
    x_intermission_flag                 IN     VARCHAR2,
    x_special_req_flag                  IN     VARCHAR2,
    x_period_note_flag                  IN     VARCHAR2,
    x_unit_set_flag                     IN     VARCHAR2,
    x_awards_flag                       IN     VARCHAR2,
    x_prog_completion_flag              IN     VARCHAR2,
    x_degree_note_flag                  IN     VARCHAR2,
    x_end_note_flag                     IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER ,
    x_unt_lvl_marks_flag                IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : rvangala@oracle.com
  ||  Created On : 18-SEP-2003
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
      x_configuration_id,
      x_course_type,
      x_display_order_flag,
      x_start_note_flag,
      x_program_region_flag,
      x_test_score_flag,
      x_sum_adv_stnd_flag,
      x_admission_note_flag,
      x_term_region_flag,
      x_unit_details_flag,
      x_unit_note_flag,
      x_adv_stnd_unit_flag,
      x_adv_stnd_unit_level_flag,
      x_statistics_flag,
      x_class_rank_flag,
      x_intermission_flag,
      x_special_req_flag,
      x_period_note_flag,
      x_unit_set_flag,
      x_awards_flag,
      x_prog_completion_flag,
      x_degree_note_flag,
      x_end_note_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_unt_lvl_marks_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.configuration_id
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
             new_references.configuration_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
    END IF;

    IF (p_action IN ('VALIDATE_INSERT', 'VALIDATE_UPDATE', 'VALIDATE_DELETE')) THEN
      l_rowid := NULL;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_configuration_id                  IN OUT NOCOPY NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_display_order_flag                IN     VARCHAR2,
    x_start_note_flag                   IN     VARCHAR2,
    x_program_region_flag               IN     VARCHAR2,
    x_test_score_flag                   IN     VARCHAR2,
    x_sum_adv_stnd_flag                 IN     VARCHAR2,
    x_admission_note_flag               IN     VARCHAR2,
    x_term_region_flag                  IN     VARCHAR2,
    x_unit_details_flag                 IN     VARCHAR2,
    x_unit_note_flag                    IN     VARCHAR2,
    x_adv_stnd_unit_flag                IN     VARCHAR2,
    x_adv_stnd_unit_level_flag          IN     VARCHAR2,
    x_statistics_flag                   IN     VARCHAR2,
    x_class_rank_flag                   IN     VARCHAR2,
    x_intermission_flag                 IN     VARCHAR2,
    x_special_req_flag                  IN     VARCHAR2,
    x_period_note_flag                  IN     VARCHAR2,
    x_unit_set_flag                     IN     VARCHAR2,
    x_awards_flag                       IN     VARCHAR2,
    x_prog_completion_flag              IN     VARCHAR2,
    x_degree_note_flag                  IN     VARCHAR2,
    x_end_note_flag                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_unt_lvl_marks_flag                IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : rvangala@oracle.com
  ||  Created On : 18-SEP-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_AS_VAH_CONF_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_configuration_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_configuration_id                  => x_configuration_id,
      x_course_type                       => x_course_type,
      x_display_order_flag                => x_display_order_flag,
      x_start_note_flag                   => x_start_note_flag,
      x_program_region_flag               => x_program_region_flag,
      x_test_score_flag                   => x_test_score_flag,
      x_sum_adv_stnd_flag                 => x_sum_adv_stnd_flag,
      x_admission_note_flag               => x_admission_note_flag,
      x_term_region_flag                  => x_term_region_flag,
      x_unit_details_flag                 => x_unit_details_flag,
      x_unit_note_flag                    => x_unit_note_flag,
      x_adv_stnd_unit_flag                => x_adv_stnd_unit_flag,
      x_adv_stnd_unit_level_flag          => x_adv_stnd_unit_level_flag,
      x_statistics_flag                   => x_statistics_flag,
      x_class_rank_flag                   => x_class_rank_flag,
      x_intermission_flag                 => x_intermission_flag,
      x_special_req_flag                  => x_special_req_flag,
      x_period_note_flag                  => x_period_note_flag,
      x_unit_set_flag                     => x_unit_set_flag,
      x_awards_flag                       => x_awards_flag,
      x_prog_completion_flag              => x_prog_completion_flag,
      x_degree_note_flag                  => x_degree_note_flag,
      x_end_note_flag                     => x_end_note_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_unt_lvl_marks_flag                => x_unt_lvl_marks_flag
    );

    INSERT INTO igs_as_vah_conf (
      configuration_id,
      course_type,
      display_order_flag,
      start_note_flag,
      program_region_flag,
      test_score_flag,
      sum_adv_stnd_flag,
      admission_note_flag,
      term_region_flag,
      unit_details_flag,
      unit_note_flag,
      adv_stnd_unit_flag,
      adv_stnd_unit_level_flag,
      statistics_flag,
      class_rank_flag,
      intermission_flag,
      special_req_flag,
      period_note_flag,
      unit_set_flag,
      awards_flag,
      prog_completion_flag,
      degree_note_flag,
      end_note_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      unt_lvl_marks_flag
    ) VALUES (
      igs_as_vah_conf_s.NEXTVAL,
      new_references.course_type,
      new_references.display_order_flag,
      new_references.start_note_flag,
      new_references.program_region_flag,
      new_references.test_score_flag,
      new_references.sum_adv_stnd_flag,
      new_references.admission_note_flag,
      new_references.term_region_flag,
      new_references.unit_details_flag,
      new_references.unit_note_flag,
      new_references.adv_stnd_unit_flag,
      new_references.adv_stnd_unit_level_flag,
      new_references.statistics_flag,
      new_references.class_rank_flag,
      new_references.intermission_flag,
      new_references.special_req_flag,
      new_references.period_note_flag,
      new_references.unit_set_flag,
      new_references.awards_flag,
      new_references.prog_completion_flag,
      new_references.degree_note_flag,
      new_references.end_note_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_unt_lvl_marks_flag
    ) RETURNING ROWID, configuration_id INTO x_rowid, x_configuration_id;

    l_rowid := NULL;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_configuration_id                  IN     NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_display_order_flag                IN     VARCHAR2,
    x_start_note_flag                   IN     VARCHAR2,
    x_program_region_flag               IN     VARCHAR2,
    x_test_score_flag                   IN     VARCHAR2,
    x_sum_adv_stnd_flag                 IN     VARCHAR2,
    x_admission_note_flag               IN     VARCHAR2,
    x_term_region_flag                  IN     VARCHAR2,
    x_unit_details_flag                 IN     VARCHAR2,
    x_unit_note_flag                    IN     VARCHAR2,
    x_adv_stnd_unit_flag                IN     VARCHAR2,
    x_adv_stnd_unit_level_flag          IN     VARCHAR2,
    x_statistics_flag                   IN     VARCHAR2,
    x_class_rank_flag                   IN     VARCHAR2,
    x_intermission_flag                 IN     VARCHAR2,
    x_special_req_flag                  IN     VARCHAR2,
    x_period_note_flag                  IN     VARCHAR2,
    x_unit_set_flag                     IN     VARCHAR2,
    x_awards_flag                       IN     VARCHAR2,
    x_prog_completion_flag              IN     VARCHAR2,
    x_degree_note_flag                  IN     VARCHAR2,
    x_end_note_flag                     IN     VARCHAR2,
    x_unt_lvl_marks_flag                IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : rvangala@oracle.com
  ||  Created On : 18-SEP-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        course_type,
        display_order_flag,
        start_note_flag,
        program_region_flag,
        test_score_flag,
        sum_adv_stnd_flag,
        admission_note_flag,
        term_region_flag,
        unit_details_flag,
        unit_note_flag,
        adv_stnd_unit_flag,
        adv_stnd_unit_level_flag,
        statistics_flag,
        class_rank_flag,
        intermission_flag,
        special_req_flag,
        period_note_flag,
        unit_set_flag,
        awards_flag,
        prog_completion_flag,
        degree_note_flag,
        end_note_flag,
        unt_lvl_marks_flag
      FROM  igs_as_vah_conf
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
        ((tlinfo.course_type = x_course_type) OR ((tlinfo.course_type IS NULL) AND (X_course_type IS NULL)))
        AND (tlinfo.display_order_flag = x_display_order_flag)
        AND (tlinfo.start_note_flag = x_start_note_flag)
        AND (tlinfo.program_region_flag = x_program_region_flag)
        AND (tlinfo.test_score_flag = x_test_score_flag)
        AND (tlinfo.sum_adv_stnd_flag = x_sum_adv_stnd_flag)
        AND (tlinfo.admission_note_flag = x_admission_note_flag)
        AND (tlinfo.term_region_flag = x_term_region_flag)
        AND (tlinfo.unit_details_flag = x_unit_details_flag)
        AND (tlinfo.unit_note_flag = x_unit_note_flag)
        AND (tlinfo.adv_stnd_unit_flag = x_adv_stnd_unit_flag)
        AND (tlinfo.adv_stnd_unit_level_flag = x_adv_stnd_unit_level_flag)
        AND (tlinfo.statistics_flag = x_statistics_flag)
        AND (tlinfo.class_rank_flag = x_class_rank_flag)
        AND (tlinfo.intermission_flag = x_intermission_flag)
        AND (tlinfo.special_req_flag = x_special_req_flag)
        AND (tlinfo.period_note_flag = x_period_note_flag)
        AND (tlinfo.unit_set_flag = x_unit_set_flag)
        AND (tlinfo.awards_flag = x_awards_flag)
        AND (tlinfo.prog_completion_flag = x_prog_completion_flag)
        AND (tlinfo.degree_note_flag = x_degree_note_flag)
        AND (tlinfo.end_note_flag = x_end_note_flag)
        AND ((tlinfo.unt_lvl_marks_flag = x_unt_lvl_marks_flag) OR ((tlinfo.unt_lvl_marks_flag IS NULL) AND (X_unt_lvl_marks_flag IS NULL)))
      )
        THEN
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
    x_configuration_id                  IN     NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_display_order_flag                IN     VARCHAR2,
    x_start_note_flag                   IN     VARCHAR2,
    x_program_region_flag               IN     VARCHAR2,
    x_test_score_flag                   IN     VARCHAR2,
    x_sum_adv_stnd_flag                 IN     VARCHAR2,
    x_admission_note_flag               IN     VARCHAR2,
    x_term_region_flag                  IN     VARCHAR2,
    x_unit_details_flag                 IN     VARCHAR2,
    x_unit_note_flag                    IN     VARCHAR2,
    x_adv_stnd_unit_flag                IN     VARCHAR2,
    x_adv_stnd_unit_level_flag          IN     VARCHAR2,
    x_statistics_flag                   IN     VARCHAR2,
    x_class_rank_flag                   IN     VARCHAR2,
    x_intermission_flag                 IN     VARCHAR2,
    x_special_req_flag                  IN     VARCHAR2,
    x_period_note_flag                  IN     VARCHAR2,
    x_unit_set_flag                     IN     VARCHAR2,
    x_awards_flag                       IN     VARCHAR2,
    x_prog_completion_flag              IN     VARCHAR2,
    x_degree_note_flag                  IN     VARCHAR2,
    x_end_note_flag                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_unt_lvl_marks_flag                IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : rvangala@oracle.com
  ||  Created On : 18-SEP-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_AS_VAH_CONF_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_configuration_id                  => x_configuration_id,
      x_course_type                       => x_course_type,
      x_display_order_flag                => x_display_order_flag,
      x_start_note_flag                   => x_start_note_flag,
      x_program_region_flag               => x_program_region_flag,
      x_test_score_flag                   => x_test_score_flag,
      x_sum_adv_stnd_flag                 => x_sum_adv_stnd_flag,
      x_admission_note_flag               => x_admission_note_flag,
      x_term_region_flag                  => x_term_region_flag,
      x_unit_details_flag                 => x_unit_details_flag,
      x_unit_note_flag                    => x_unit_note_flag,
      x_adv_stnd_unit_flag                => x_adv_stnd_unit_flag,
      x_adv_stnd_unit_level_flag          => x_adv_stnd_unit_level_flag,
      x_statistics_flag                   => x_statistics_flag,
      x_class_rank_flag                   => x_class_rank_flag,
      x_intermission_flag                 => x_intermission_flag,
      x_special_req_flag                  => x_special_req_flag,
      x_period_note_flag                  => x_period_note_flag,
      x_unit_set_flag                     => x_unit_set_flag,
      x_awards_flag                       => x_awards_flag,
      x_prog_completion_flag              => x_prog_completion_flag,
      x_degree_note_flag                  => x_degree_note_flag,
      x_end_note_flag                     => x_end_note_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_unt_lvl_marks_flag                => x_unt_lvl_marks_flag
    );

    UPDATE igs_as_vah_conf
      SET
        course_type                       = new_references.course_type,
        display_order_flag                = new_references.display_order_flag,
        start_note_flag                   = new_references.start_note_flag,
        program_region_flag               = new_references.program_region_flag,
        test_score_flag                   = new_references.test_score_flag,
        sum_adv_stnd_flag                 = new_references.sum_adv_stnd_flag,
        admission_note_flag               = new_references.admission_note_flag,
        term_region_flag                  = new_references.term_region_flag,
        unit_details_flag                 = new_references.unit_details_flag,
        unit_note_flag                    = new_references.unit_note_flag,
        adv_stnd_unit_flag                = new_references.adv_stnd_unit_flag,
        adv_stnd_unit_level_flag          = new_references.adv_stnd_unit_level_flag,
        statistics_flag                   = new_references.statistics_flag,
        class_rank_flag                   = new_references.class_rank_flag,
        intermission_flag                 = new_references.intermission_flag,
        special_req_flag                  = new_references.special_req_flag,
        period_note_flag                  = new_references.period_note_flag,
        unit_set_flag                     = new_references.unit_set_flag,
        awards_flag                       = new_references.awards_flag,
        prog_completion_flag              = new_references.prog_completion_flag,
        degree_note_flag                  = new_references.degree_note_flag,
        end_note_flag                     = new_references.end_note_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        unt_lvl_marks_flag                = new_references.unt_lvl_marks_flag
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_configuration_id                  IN OUT NOCOPY NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_display_order_flag                IN     VARCHAR2,
    x_start_note_flag                   IN     VARCHAR2,
    x_program_region_flag               IN     VARCHAR2,
    x_test_score_flag                   IN     VARCHAR2,
    x_sum_adv_stnd_flag                 IN     VARCHAR2,
    x_admission_note_flag               IN     VARCHAR2,
    x_term_region_flag                  IN     VARCHAR2,
    x_unit_details_flag                 IN     VARCHAR2,
    x_unit_note_flag                    IN     VARCHAR2,
    x_adv_stnd_unit_flag                IN     VARCHAR2,
    x_adv_stnd_unit_level_flag          IN     VARCHAR2,
    x_statistics_flag                   IN     VARCHAR2,
    x_class_rank_flag                   IN     VARCHAR2,
    x_intermission_flag                 IN     VARCHAR2,
    x_special_req_flag                  IN     VARCHAR2,
    x_period_note_flag                  IN     VARCHAR2,
    x_unit_set_flag                     IN     VARCHAR2,
    x_awards_flag                       IN     VARCHAR2,
    x_prog_completion_flag              IN     VARCHAR2,
    x_degree_note_flag                  IN     VARCHAR2,
    x_end_note_flag                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_unt_lvl_marks_flag                IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : rvangala@oracle.com
  ||  Created On : 18-SEP-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_as_vah_conf
      WHERE    configuration_id                  = x_configuration_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_configuration_id,
        x_course_type,
        x_display_order_flag,
        x_start_note_flag,
        x_program_region_flag,
        x_test_score_flag,
        x_sum_adv_stnd_flag,
        x_admission_note_flag,
        x_term_region_flag,
        x_unit_details_flag,
        x_unit_note_flag,
        x_adv_stnd_unit_flag,
        x_adv_stnd_unit_level_flag,
        x_statistics_flag,
        x_class_rank_flag,
        x_intermission_flag,
        x_special_req_flag,
        x_period_note_flag,
        x_unit_set_flag,
        x_awards_flag,
        x_prog_completion_flag,
        x_degree_note_flag,
        x_end_note_flag,
        x_mode ,
        x_unt_lvl_marks_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_configuration_id,
      x_course_type,
      x_display_order_flag,
      x_start_note_flag,
      x_program_region_flag,
      x_test_score_flag,
      x_sum_adv_stnd_flag,
      x_admission_note_flag,
      x_term_region_flag,
      x_unit_details_flag,
      x_unit_note_flag,
      x_adv_stnd_unit_flag,
      x_adv_stnd_unit_level_flag,
      x_statistics_flag,
      x_class_rank_flag,
      x_intermission_flag,
      x_special_req_flag,
      x_period_note_flag,
      x_unit_set_flag,
      x_awards_flag,
      x_prog_completion_flag,
      x_degree_note_flag,
      x_end_note_flag,
      x_mode ,
      x_unt_lvl_marks_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rvangala@oracle.com
  ||  Created On : 18-SEP-2003
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

    DELETE FROM igs_as_vah_conf
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END delete_row;


END igs_as_vah_conf_pkg;

/
