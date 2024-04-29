--------------------------------------------------------
--  DDL for Package Body IGS_UC_COND_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_COND_DETAILS_PKG" AS
/* $Header: IGSXI13B.pls 115.7 2003/02/28 07:46:47 bayadav noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_cond_details%ROWTYPE;
  new_references igs_uc_cond_details%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_condition_category                IN     VARCHAR2    ,
    x_condition_name                    IN     VARCHAR2    ,
    x_condition_line                    IN     NUMBER      ,
    x_abbreviation                      IN     VARCHAR2    ,
    x_grade_mark                        IN     VARCHAR2    ,
    x_points                            IN     VARCHAR2    ,
    x_subject                           IN     VARCHAR2    ,
    x_condition_text                    IN     VARCHAR2,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_COND_DETAILS
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
    new_references.condition_category                := x_condition_category;
    new_references.condition_name                    := x_condition_name;
    new_references.condition_line                    := x_condition_line;
    new_references.abbreviation                      := x_abbreviation;
    new_references.grade_mark                        := x_grade_mark;
    new_references.points                            := x_points;
    new_references.subject                           := x_subject;
    new_references.condition_text                    := x_condition_text;


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
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.condition_category = new_references.condition_category) AND
         (old_references.condition_name = new_references.condition_name)) OR
        ((new_references.condition_category IS NULL) OR
         (new_references.condition_name IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_offer_conds_pkg.get_pk_for_validation (
                new_references.condition_category,
                new_references.condition_name
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.abbreviation = new_references.abbreviation)) OR
        ((new_references.abbreviation IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_ref_off_abrv_pkg.get_pk_for_validation (
                new_references.abbreviation
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_condition_line                    IN     NUMBER
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
      FROM     igs_uc_cond_details
      WHERE    condition_category = x_condition_category
      AND      condition_name = x_condition_name
      AND      condition_line = x_condition_line ;

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


  PROCEDURE get_fk_igs_uc_offer_conds (
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_cond_details
      WHERE   ((condition_category = x_condition_category) AND
               (condition_name = x_condition_name));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCOCDT_UCOC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_offer_conds;

  PROCEDURE get_fk_igs_uc_ref_off_abrv (
    x_abbreviation    IN   VARCHAR2
  ) AS
  /*
  ||  Created By : RBEZAWAD
  ||  Created On : 17-DEC-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_cond_details
      WHERE   ((abbreviation = x_abbreviation));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCCD_UROA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_ref_off_abrv;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_condition_category                IN     VARCHAR2    ,
    x_condition_name                    IN     VARCHAR2    ,
    x_condition_line                    IN     NUMBER      ,
    x_abbreviation                      IN     VARCHAR2    ,
    x_grade_mark                        IN     VARCHAR2    ,
    x_points                            IN     VARCHAR2    ,
    x_subject                           IN     VARCHAR2    ,
    x_condition_text                    IN     VARCHAR2,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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
      x_condition_category,
      x_condition_name,
      x_condition_line,
      x_abbreviation,
      x_grade_mark,
      x_points,
      x_subject,
      x_condition_text ,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.condition_category,
             new_references.condition_name,
             new_references.condition_line
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
             new_references.condition_category,
             new_references.condition_name,
             new_references.condition_line
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
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_condition_line                    IN     NUMBER,
    x_abbreviation                      IN     VARCHAR2,
    x_grade_mark                        IN     VARCHAR2,
    x_points                            IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_condition_text                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_cond_details
      WHERE    condition_category                = x_condition_category
      AND      condition_name                    = x_condition_name
      AND      condition_line                    = x_condition_line;

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
      x_condition_category                => x_condition_category,
      x_condition_name                    => x_condition_name,
      x_condition_line                    => x_condition_line,
      x_abbreviation                      => x_abbreviation,
      x_grade_mark                        => x_grade_mark,
      x_points                            => x_points,
      x_subject                           => x_subject,
      x_condition_text                    => x_condition_text,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_cond_details (
      condition_category,
      condition_name,
      condition_line,
      abbreviation,
      grade_mark,
      points,
      subject,
      condition_text ,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.condition_category,
      new_references.condition_name,
      new_references.condition_line,
      new_references.abbreviation,
      new_references.grade_mark,
      new_references.points,
      new_references.subject,
      new_references.condition_text ,
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
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_condition_line                    IN     NUMBER,
    x_abbreviation                      IN     VARCHAR2,
    x_grade_mark                        IN     VARCHAR2,
    x_points                            IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_condition_text                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        abbreviation,
        grade_mark,
        points,
        subject,
        condition_text
      FROM  igs_uc_cond_details
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
        ((tlinfo.abbreviation = x_abbreviation) OR ((tlinfo.abbreviation IS NULL) AND (X_abbreviation IS NULL)))
        AND ((tlinfo.grade_mark = x_grade_mark) OR ((tlinfo.grade_mark IS NULL) AND (X_grade_mark IS NULL)))
        AND ((tlinfo.points = x_points) OR ((tlinfo.points IS NULL) AND (X_points IS NULL)))
        AND ((tlinfo.subject = x_subject) OR ((tlinfo.subject IS NULL) AND (X_subject IS NULL)))
        AND ((tlinfo.condition_text = x_condition_text) OR ((tlinfo.condition_text IS NULL) AND (X_condition_text IS NULL)))
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
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_condition_line                    IN     NUMBER,
    x_abbreviation                      IN     VARCHAR2,
    x_grade_mark                        IN     VARCHAR2,
    x_points                            IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_condition_text                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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
      x_condition_category                => x_condition_category,
      x_condition_name                    => x_condition_name,
      x_condition_line                    => x_condition_line,
      x_abbreviation                      => x_abbreviation,
      x_grade_mark                        => x_grade_mark,
      x_points                            => x_points,
      x_subject                           => x_subject,
      x_condition_text                    => x_condition_text,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_cond_details
      SET
        abbreviation                      = new_references.abbreviation,
        grade_mark                        = new_references.grade_mark,
        points                            = new_references.points,
        subject                           = new_references.subject,
        condition_text                    = new_references.condition_text,
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
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_condition_line                    IN     NUMBER,
    x_abbreviation                      IN     VARCHAR2,
    x_grade_mark                        IN     VARCHAR2,
    x_points                            IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_condition_text                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_cond_details
      WHERE    condition_category                = x_condition_category
      AND      condition_name                    = x_condition_name
      AND      condition_line                    = x_condition_line;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_condition_category,
        x_condition_name,
        x_condition_line,
        x_abbreviation,
        x_grade_mark,
        x_points,
        x_subject,
        x_condition_text ,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_condition_category,
      x_condition_name,
      x_condition_line,
      x_abbreviation,
      x_grade_mark,
      x_points,
      x_subject,
      x_condition_text ,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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

    DELETE FROM igs_uc_cond_details
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_cond_details_pkg;

/
