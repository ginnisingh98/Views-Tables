--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPLACEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPLACEMENTS_PKG" AS
/* $Header: IGSEI73B.pls 120.1 2006/07/11 10:36:54 ckasu noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_splacements%ROWTYPE;
  new_references igs_en_splacements%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_splacement_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_institution_code                  IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_category_code                     IN     VARCHAR2,
    x_placement_type_code               IN     VARCHAR2,
    x_specialty_code                    IN     VARCHAR2,
    x_compensation_flag                 IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_notes                             IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : annamalai.muthu@oracle.com
  ||  Created On : 16-NOV-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_en_splacements
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
    new_references.splacement_id                     := x_splacement_id;
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.uoo_id                            := x_uoo_id;
    new_references.start_date                        := x_start_date;
    new_references.end_date                          := x_end_date;
    new_references.institution_code                  := x_institution_code;
    new_references.title                             := x_title;
    new_references.description                       := x_description;
    new_references.category_code                     := x_category_code;
    new_references.placement_type_code               := x_placement_type_code;
    new_references.specialty_code                    := x_specialty_code;
    new_references.compensation_flag                 := x_compensation_flag;
    new_references.attendance_type                   := x_attendance_type;
    new_references.location                          := x_location;
    new_references.notes                             := x_notes;

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
  ||  Created By : annamalai.muthu@oracle.com
  ||  Created On : 16-NOV-2004
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  ckasu         11-JUL-2006      Modified as a part of bug #5378470
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.person_id,
           new_references.course_cd,
           new_references.uoo_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF ( get_uk2_for_validation (
           new_references.person_id,
           new_references.institution_code,
           new_references.title,
           new_references.start_date
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_EN_PLACMNT_DTLS_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  FUNCTION get_pk_for_validation (
    x_splacement_id                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : annamalai.muthu@oracle.com
  ||  Created On : 16-NOV-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_splacements
      WHERE    splacement_id = x_splacement_id
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
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : annamalai.muthu@oracle.com
  ||  Created On : 16-NOV-2004
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_splacements
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      uoo_id = x_uoo_id
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


  FUNCTION get_uk2_for_validation (
    x_person_id                         IN     NUMBER,
    x_institution_code                  IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_start_date                        IN     DATE
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : annamalai.muthu@oracle.com
  ||  Created On : 16-NOV-2004
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_splacements
      WHERE    person_id = x_person_id
      AND      institution_code = x_institution_code
      AND      title = x_title
      AND      start_date = x_start_date
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

  END get_uk2_for_validation ;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_splacement_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_institution_code                  IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_category_code                     IN     VARCHAR2,
    x_placement_type_code               IN     VARCHAR2,
    x_specialty_code                    IN     VARCHAR2,
    x_compensation_flag                 IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_notes                             IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : annamalai.muthu@oracle.com
  ||  Created On : 16-NOV-2004
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
      x_splacement_id,
      x_person_id,
      x_course_cd,
      x_uoo_id,
      x_start_date,
      x_end_date,
      x_institution_code,
      x_title,
      x_description,
      x_category_code,
      x_placement_type_code,
      x_specialty_code,
      x_compensation_flag,
      x_attendance_type,
      x_location,
      x_notes,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.splacement_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.splacement_id
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
    x_splacement_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_institution_code                  IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_category_code                     IN     VARCHAR2,
    x_placement_type_code               IN     VARCHAR2,
    x_specialty_code                    IN     VARCHAR2,
    x_compensation_flag                 IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_notes                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : annamalai.muthu@oracle.com
  ||  Created On : 16-NOV-2004
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
      fnd_message.set_token ('ROUTINE', 'IGS_EN_SPLACEMENTS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_splacement_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_splacement_id                     => x_splacement_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_uoo_id                            => x_uoo_id,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_institution_code                  => x_institution_code,
      x_title                             => x_title,
      x_description                       => x_description,
      x_category_code                     => x_category_code,
      x_placement_type_code               => x_placement_type_code,
      x_specialty_code                    => x_specialty_code,
      x_compensation_flag                 => x_compensation_flag,
      x_attendance_type                   => x_attendance_type,
      x_location                          => x_location,
      x_notes                             => x_notes,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_splacements (
      splacement_id,
      person_id,
      course_cd,
      uoo_id,
      start_date,
      end_date,
      institution_code,
      title,
      description,
      category_code,
      placement_type_code,
      specialty_code,
      compensation_flag,
      attendance_type,
      location,
      notes,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_en_splacements_s.NEXTVAL,
      new_references.person_id,
      new_references.course_cd,
      new_references.uoo_id,
      new_references.start_date,
      new_references.end_date,
      new_references.institution_code,
      new_references.title,
      new_references.description,
      new_references.category_code,
      new_references.placement_type_code,
      new_references.specialty_code,
      new_references.compensation_flag,
      new_references.attendance_type,
      new_references.location,
      new_references.notes,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, splacement_id INTO x_rowid, x_splacement_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_splacement_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_institution_code                  IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_category_code                     IN     VARCHAR2,
    x_placement_type_code               IN     VARCHAR2,
    x_specialty_code                    IN     VARCHAR2,
    x_compensation_flag                 IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_notes                             IN     VARCHAR2
  ) AS
  /*
  ||  Created By : annamalai.muthu@oracle.com
  ||  Created On : 16-NOV-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        course_cd,
        uoo_id,
        start_date,
        end_date,
        institution_code,
        title,
        description,
        category_code,
        placement_type_code,
        specialty_code,
        compensation_flag,
        attendance_type,
        location,
        notes
      FROM  igs_en_splacements
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
        (tlinfo.person_id = x_person_id)
        AND (tlinfo.course_cd = x_course_cd)
        AND (tlinfo.uoo_id = x_uoo_id)
        AND (tlinfo.start_date = x_start_date)
        AND (tlinfo.end_date = x_end_date)
        AND (tlinfo.institution_code = x_institution_code)
        AND (tlinfo.title = x_title)
        AND ((tlinfo.description = x_description) OR ((tlinfo.description IS NULL) AND (X_description IS NULL)))
        AND ((tlinfo.category_code = x_category_code) OR ((tlinfo.category_code IS NULL) AND (X_category_code IS NULL)))
        AND ((tlinfo.placement_type_code = x_placement_type_code) OR ((tlinfo.placement_type_code IS NULL) AND (X_placement_type_code IS NULL)))
        AND ((tlinfo.specialty_code = x_specialty_code) OR ((tlinfo.specialty_code IS NULL) AND (X_specialty_code IS NULL)))
        AND (tlinfo.compensation_flag = x_compensation_flag)
        AND ((tlinfo.attendance_type = x_attendance_type) OR ((tlinfo.attendance_type IS NULL) AND (X_attendance_type IS NULL)))
        AND ((tlinfo.location = x_location) OR ((tlinfo.location IS NULL) AND (X_location IS NULL)))
        AND ((tlinfo.notes = x_notes) OR ((tlinfo.notes IS NULL) AND (X_notes IS NULL)))
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
    x_splacement_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_institution_code                  IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_category_code                     IN     VARCHAR2,
    x_placement_type_code               IN     VARCHAR2,
    x_specialty_code                    IN     VARCHAR2,
    x_compensation_flag                 IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_notes                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : annamalai.muthu@oracle.com
  ||  Created On : 16-NOV-2004
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
      fnd_message.set_token ('ROUTINE', 'IGS_EN_SPLACEMENTS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_splacement_id                     => x_splacement_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_uoo_id                            => x_uoo_id,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_institution_code                  => x_institution_code,
      x_title                             => x_title,
      x_description                       => x_description,
      x_category_code                     => x_category_code,
      x_placement_type_code               => x_placement_type_code,
      x_specialty_code                    => x_specialty_code,
      x_compensation_flag                 => x_compensation_flag,
      x_attendance_type                   => x_attendance_type,
      x_location                          => x_location,
      x_notes                             => x_notes,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_en_splacements
      SET
        person_id                         = new_references.person_id,
        course_cd                         = new_references.course_cd,
        uoo_id                            = new_references.uoo_id,
        start_date                        = new_references.start_date,
        end_date                          = new_references.end_date,
        institution_code                  = new_references.institution_code,
        title                             = new_references.title,
        description                       = new_references.description,
        category_code                     = new_references.category_code,
        placement_type_code               = new_references.placement_type_code,
        specialty_code                    = new_references.specialty_code,
        compensation_flag                 = new_references.compensation_flag,
        attendance_type                   = new_references.attendance_type,
        location                          = new_references.location,
        notes                             = new_references.notes,
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
    x_splacement_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_institution_code                  IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_category_code                     IN     VARCHAR2,
    x_placement_type_code               IN     VARCHAR2,
    x_specialty_code                    IN     VARCHAR2,
    x_compensation_flag                 IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_notes                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : annamalai.muthu@oracle.com
  ||  Created On : 16-NOV-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_splacements
      WHERE    splacement_id                     = x_splacement_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_splacement_id,
        x_person_id,
        x_course_cd,
        x_uoo_id,
        x_start_date,
        x_end_date,
        x_institution_code,
        x_title,
        x_description,
        x_category_code,
        x_placement_type_code,
        x_specialty_code,
        x_compensation_flag,
        x_attendance_type,
        x_location,
        x_notes,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_splacement_id,
      x_person_id,
      x_course_cd,
      x_uoo_id,
      x_start_date,
      x_end_date,
      x_institution_code,
      x_title,
      x_description,
      x_category_code,
      x_placement_type_code,
      x_specialty_code,
      x_compensation_flag,
      x_attendance_type,
      x_location,
      x_notes,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : annamalai.muthu@oracle.com
  ||  Created On : 16-NOV-2004
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

    DELETE FROM igs_en_splacements
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_en_splacements_pkg;

/
