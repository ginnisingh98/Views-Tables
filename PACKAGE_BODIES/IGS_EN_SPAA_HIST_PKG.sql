--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPAA_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPAA_HIST_PKG" AS
/* $Header: IGSEI72B.pls 115.0 2003/10/09 09:29:40 anilk noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_spaa_hist%ROWTYPE;
  new_references igs_en_spaa_hist%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_complete_flag                     IN     VARCHAR2,
    x_conferral_date                    IN     DATE,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : anilk@oracle.com
  ||  Created On : 29-SEP-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_en_spaa_hist
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
    new_references.award_cd                          := x_award_cd;
    new_references.start_date                        := x_start_date;
    new_references.end_date                          := x_end_date;
    new_references.complete_flag                     := x_complete_flag;
    new_references.conferral_date                    := x_conferral_date;
    new_references.award_mark                        := x_award_mark;
    new_references.award_grade                       := x_award_grade;
    new_references.grading_schema_cd                 := x_grading_schema_cd;
    new_references.gs_version_number                 := x_gs_version_number;

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
  ||  Created By : anilk@oracle.com
  ||  Created On : 29-SEP-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.award_cd = new_references.award_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL) OR
         (new_references.award_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_spa_awd_aim_pkg.get_pk_for_validation (
                x_person_id  =>	new_references.person_id,
                x_course_cd  =>	new_references.course_cd,
                x_award_cd   =>	new_references.award_cd
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.gs_version_number = new_references.gs_version_number)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.gs_version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_grd_schema_pkg.get_pk_for_validation (
                new_references.grading_schema_cd,
                new_references.gs_version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_creation_date                     IN     DATE
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : anilk@oracle.com
  ||  Created On : 29-SEP-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_spaa_hist
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      award_cd = x_award_cd
      AND      creation_date = x_creation_date
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

  PROCEDURE get_fk_igs_as_grd_schema (
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) AS
  /*
  ||  Created By : anilk@oracle.com
  ||  Created On : 29-SEP-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_spaa_hist
      WHERE   ((grading_schema_cd = x_grading_schema_cd) AND
               (gs_version_number = x_version_number));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GR_SPAAH_AGS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_as_grd_schema;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_complete_flag                     IN     VARCHAR2,
    x_conferral_date                    IN     DATE,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : anilk@oracle.com
  ||  Created On : 29-SEP-2003
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
      x_person_id,
      x_course_cd,
      x_award_cd,
      x_start_date,
      x_end_date,
      x_complete_flag,
      x_conferral_date,
      x_award_mark,
      x_award_grade,
      x_grading_schema_cd,
      x_gs_version_number,
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
             new_references.course_cd,
             new_references.award_cd,
             new_references.creation_date
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
             new_references.person_id,
             new_references.course_cd,
             new_references.award_cd,
             new_references.creation_date
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (p_action IN ('VALIDATE_INSERT', 'VALIDATE_UPDATE', 'VALIDATE_DELETE')) THEN
      l_rowid := NULL;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_complete_flag                     IN     VARCHAR2,
    x_conferral_date                    IN     DATE,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anilk@oracle.com
  ||  Created On : 29-SEP-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_EN_SPAA_HIST_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_award_cd                          => x_award_cd,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_complete_flag                     => x_complete_flag,
      x_conferral_date                    => x_conferral_date,
      x_award_mark                        => x_award_mark,
      x_award_grade                       => x_award_grade,
      x_grading_schema_cd                 => x_grading_schema_cd,
      x_gs_version_number                 => x_gs_version_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_spaa_hist (
      person_id,
      course_cd,
      award_cd,
      start_date,
      end_date,
      complete_flag,
      conferral_date,
      award_mark,
      award_grade,
      grading_schema_cd,
      gs_version_number,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.person_id,
      new_references.course_cd,
      new_references.award_cd,
      new_references.start_date,
      new_references.end_date,
      new_references.complete_flag,
      new_references.conferral_date,
      new_references.award_mark,
      new_references.award_grade,
      new_references.grading_schema_cd,
      new_references.gs_version_number,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

    l_rowid := NULL;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_complete_flag                     IN     VARCHAR2,
    x_conferral_date                    IN     DATE,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER
  ) AS
  /*
  ||  Created By : anilk@oracle.com
  ||  Created On : 29-SEP-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        start_date,
        end_date,
        complete_flag,
        conferral_date,
        award_mark,
        award_grade,
        grading_schema_cd,
        gs_version_number
      FROM  igs_en_spaa_hist
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
        (tlinfo.start_date = x_start_date)
        AND ((tlinfo.end_date = x_end_date) OR ((tlinfo.end_date IS NULL) AND (X_end_date IS NULL)))
        AND (tlinfo.complete_flag = x_complete_flag)
        AND ((tlinfo.conferral_date = x_conferral_date) OR ((tlinfo.conferral_date IS NULL) AND (X_conferral_date IS NULL)))
        AND ((tlinfo.award_mark = x_award_mark) OR ((tlinfo.award_mark IS NULL) AND (X_award_mark IS NULL)))
        AND ((tlinfo.award_grade = x_award_grade) OR ((tlinfo.award_grade IS NULL) AND (X_award_grade IS NULL)))
        AND ((tlinfo.grading_schema_cd = x_grading_schema_cd) OR ((tlinfo.grading_schema_cd IS NULL) AND (X_grading_schema_cd IS NULL)))
        AND ((tlinfo.gs_version_number = x_gs_version_number) OR ((tlinfo.gs_version_number IS NULL) AND (X_gs_version_number IS NULL)))
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
    x_award_cd                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_complete_flag                     IN     VARCHAR2,
    x_conferral_date                    IN     DATE,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anilk@oracle.com
  ||  Created On : 29-SEP-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_EN_SPAA_HIST_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_award_cd                          => x_award_cd,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_complete_flag                     => x_complete_flag,
      x_conferral_date                    => x_conferral_date,
      x_award_mark                        => x_award_mark,
      x_award_grade                       => x_award_grade,
      x_grading_schema_cd                 => x_grading_schema_cd,
      x_gs_version_number                 => x_gs_version_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_en_spaa_hist
      SET
        start_date                        = new_references.start_date,
        end_date                          = new_references.end_date,
        complete_flag                     = new_references.complete_flag,
        conferral_date                    = new_references.conferral_date,
        award_mark                        = new_references.award_mark,
        award_grade                       = new_references.award_grade,
        grading_schema_cd                 = new_references.grading_schema_cd,
        gs_version_number                 = new_references.gs_version_number,
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
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_complete_flag                     IN     VARCHAR2,
    x_conferral_date                    IN     DATE,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anilk@oracle.com
  ||  Created On : 29-SEP-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_spaa_hist
      WHERE    person_id                         = x_person_id
      AND      course_cd                         = x_course_cd
      AND      award_cd                          = x_award_cd
      AND      creation_date                     = x_creation_date;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_person_id,
        x_course_cd,
        x_award_cd,
        x_start_date,
        x_end_date,
        x_complete_flag,
        x_conferral_date,
        x_award_mark,
        x_award_grade,
        x_grading_schema_cd,
        x_gs_version_number,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_person_id,
      x_course_cd,
      x_award_cd,
      x_start_date,
      x_end_date,
      x_complete_flag,
      x_conferral_date,
      x_award_mark,
      x_award_grade,
      x_grading_schema_cd,
      x_gs_version_number,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : anilk@oracle.com
  ||  Created On : 29-SEP-2003
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

    DELETE FROM igs_en_spaa_hist
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END delete_row;


END igs_en_spaa_hist_pkg;

/
