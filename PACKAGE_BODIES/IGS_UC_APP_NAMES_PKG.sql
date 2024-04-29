--------------------------------------------------------
--  DDL for Package Body IGS_UC_APP_NAMES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_APP_NAMES_PKG" AS
/* $Header: IGSXI49B.pls 120.0 2005/06/01 17:36:50 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_app_names%ROWTYPE;
  new_references igs_uc_app_names%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_fore_names                        IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_uc_app_names
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
    new_references.app_no                            := x_app_no;
    new_references.check_digit                       := x_check_digit;
    new_references.name_change_date                  := x_name_change_date;
    new_references.title                             := x_title;
    new_references.fore_names                        := x_fore_names;
    new_references.surname                           := x_surname;
    new_references.birth_date                        := x_birth_date;
    new_references.sex                               := x_sex;
    new_references.sent_to_oss_flag                  := x_sent_to_oss_flag;

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
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.app_no
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.app_no = new_references.app_no)) OR
        ((new_references.app_no IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_applicants_pkg.get_uk_For_validation (
                new_references.app_no
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_uk_for_validation (
    x_app_no                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_names
      WHERE    app_no = x_app_no
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


  PROCEDURE get_ufk_igs_uc_applicants (
    x_app_no                            IN     NUMBER
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_names
      WHERE   ((app_no = x_app_no));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UANAME_UCAP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_uc_applicants;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_fore_names                        IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
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
      x_app_no,
      x_check_digit,
      x_name_change_date,
      x_title,
      x_fore_names,
      x_surname,
      x_birth_date,
      x_sex,
      x_sent_to_oss_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_fore_names                        IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_UC_APP_NAMES_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_app_no                            => x_app_no,
      x_check_digit                       => x_check_digit,
      x_name_change_date                  => x_name_change_date,
      x_title                             => x_title,
      x_fore_names                        => x_fore_names,
      x_surname                           => x_surname,
      x_birth_date                        => x_birth_date,
      x_sex                               => x_sex,
      x_sent_to_oss_flag                  => x_sent_to_oss_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_app_names (
      app_no,
      check_digit,
      name_change_date,
      title,
      fore_names,
      surname,
      birth_date,
      sex,
      sent_to_oss_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.app_no,
      new_references.check_digit,
      new_references.name_change_date,
      new_references.title,
      new_references.fore_names,
      new_references.surname,
      new_references.birth_date,
      new_references.sex,
      new_references.sent_to_oss_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_fore_names                        IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        app_no,
        check_digit,
        name_change_date,
        title,
        fore_names,
        surname,
        birth_date,
        sex,
        sent_to_oss_flag
      FROM  igs_uc_app_names
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
        (tlinfo.app_no = x_app_no)
        AND (tlinfo.check_digit = x_check_digit)
        AND ((tlinfo.name_change_date = x_name_change_date) OR ((tlinfo.name_change_date IS NULL) AND (X_name_change_date IS NULL)))
        AND ((tlinfo.title = x_title) OR ((tlinfo.title IS NULL) AND (X_title IS NULL)))
        AND ((tlinfo.fore_names = x_fore_names) OR ((tlinfo.fore_names IS NULL) AND (X_fore_names IS NULL)))
        AND ((tlinfo.surname = x_surname) OR ((tlinfo.surname IS NULL) AND (X_surname IS NULL)))
        AND ((tlinfo.birth_date = x_birth_date) OR ((tlinfo.birth_date IS NULL) AND (X_birth_date IS NULL)))
        AND ((tlinfo.sex = x_sex) OR ((tlinfo.sex IS NULL) AND (X_sex IS NULL)))
        AND (tlinfo.sent_to_oss_flag = x_sent_to_oss_flag)
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
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_fore_names                        IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_UC_APP_NAMES_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_app_no                            => x_app_no,
      x_check_digit                       => x_check_digit,
      x_name_change_date                  => x_name_change_date,
      x_title                             => x_title,
      x_fore_names                        => x_fore_names,
      x_surname                           => x_surname,
      x_birth_date                        => x_birth_date,
      x_sex                               => x_sex,
      x_sent_to_oss_flag                  => x_sent_to_oss_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_app_names
      SET
        app_no                            = new_references.app_no,
        check_digit                       = new_references.check_digit,
        name_change_date                  = new_references.name_change_date,
        title                             = new_references.title,
        fore_names                        = new_references.fore_names,
        surname                           = new_references.surname,
        birth_date                        = new_references.birth_date,
        sex                               = new_references.sex,
        sent_to_oss_flag                  = new_references.sent_to_oss_flag,
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
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_fore_names                        IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_app_names
      WHERE    app_no = x_app_no;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_app_no,
        x_check_digit,
        x_name_change_date,
        x_title,
        x_fore_names,
        x_surname,
        x_birth_date,
        x_sex,
        x_sent_to_oss_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_app_no,
      x_check_digit,
      x_name_change_date,
      x_title,
      x_fore_names,
      x_surname,
      x_birth_date,
      x_sex,
      x_sent_to_oss_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 14-JUL-2003
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

    DELETE FROM igs_uc_app_names
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_app_names_pkg;

/
