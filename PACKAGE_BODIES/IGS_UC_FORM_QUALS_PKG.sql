--------------------------------------------------------
--  DDL for Package Body IGS_UC_FORM_QUALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_FORM_QUALS_PKG" AS
/* $Header: IGSXI51B.pls 120.1 2005/09/27 19:34:42 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_form_quals%ROWTYPE;
  new_references igs_uc_form_quals%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_qual_id                           IN     NUMBER,
    x_qual_type                         IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_grade                             IN     VARCHAR2,
    x_qual_date                         IN     DATE,
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
      FROM     igs_uc_form_quals
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
    new_references.qual_id                           := x_qual_id;
    new_references.qual_type                         := x_qual_type;
    new_references.award_body                        := x_award_body;
    new_references.title                             := x_title;
    new_references.grade                             := x_grade;
    new_references.qual_date                         := x_qual_date;

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
           new_references.app_no,
           new_references.qual_type,
           new_references.title
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
    x_app_no                            IN     NUMBER,
    x_qual_type                         IN     VARCHAR2,
    x_title                             IN     VARCHAR2
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
      FROM     igs_uc_form_quals
      WHERE    app_no = x_app_no
      AND      qual_type = x_qual_type
      AND      title = x_title
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
      FROM     igs_uc_form_quals
      WHERE   ((app_no = x_app_no));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UAFRQA_UCAP_FK');
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
    x_qual_id                           IN     NUMBER,
    x_qual_type                         IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_grade                             IN     VARCHAR2,
    x_qual_date                         IN     DATE,
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
      x_qual_id,
      x_qual_type,
      x_award_body,
      x_title,
      x_grade,
      x_qual_date,
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
    x_qual_id                           IN     NUMBER,
    x_qual_type                         IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_grade                             IN     VARCHAR2,
    x_qual_date                         IN     DATE,
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
      fnd_message.set_token ('ROUTINE', 'IGS_UC_FORM_QUALS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_app_no                            => x_app_no,
      x_qual_id                           => x_qual_id,
      x_qual_type                         => x_qual_type,
      x_award_body                        => x_award_body,
      x_title                             => x_title,
      x_grade                             => x_grade,
      x_qual_date                         => x_qual_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_form_quals (
      app_no,
      qual_id,
      qual_type,
      award_body,
      title,
      grade,
      qual_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.app_no,
      new_references.qual_id,
      new_references.qual_type,
      new_references.award_body,
      new_references.title,
      new_references.grade,
      new_references.qual_date,
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
    x_qual_id                           IN     NUMBER,
    x_qual_type                         IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_grade                             IN     VARCHAR2,
    x_qual_date                         IN     DATE
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
        qual_id,
        qual_type,
        award_body,
        title,
        grade,
        qual_date
      FROM  igs_uc_form_quals
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
        AND (tlinfo.qual_id = x_qual_id)
        AND ((tlinfo.qual_type = x_qual_type) OR ((tlinfo.qual_type IS NULL) AND (X_qual_type IS NULL)))
        AND ((tlinfo.award_body = x_award_body) OR ((tlinfo.award_body IS NULL) AND (X_award_body IS NULL)))
        AND ((tlinfo.title = x_title) OR ((tlinfo.title IS NULL) AND (X_title IS NULL)))
        AND ((tlinfo.grade = x_grade) OR ((tlinfo.grade IS NULL) AND (X_grade IS NULL)))
        AND ((tlinfo.qual_date = x_qual_date) OR ((tlinfo.qual_date IS NULL) AND (X_qual_date IS NULL)))
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
    x_qual_id                           IN     NUMBER,
    x_qual_type                         IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_grade                             IN     VARCHAR2,
    x_qual_date                         IN     DATE,
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
      fnd_message.set_token ('ROUTINE', 'IGS_UC_FORM_QUALS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_app_no                            => x_app_no,
      x_qual_id                           => x_qual_id,
      x_qual_type                         => x_qual_type,
      x_award_body                        => x_award_body,
      x_title                             => x_title,
      x_grade                             => x_grade,
      x_qual_date                         => x_qual_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_form_quals
      SET
        app_no                            = new_references.app_no,
        qual_id                           = new_references.qual_id,
        qual_type                         = new_references.qual_type,
        award_body                        = new_references.award_body,
        title                             = new_references.title,
        grade                             = new_references.grade,
        qual_date                         = new_references.qual_date,
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
    x_qual_id                           IN     NUMBER,
    x_qual_type                         IN     VARCHAR2,
    x_award_body                        IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_grade                             IN     VARCHAR2,
    x_qual_date                         IN     DATE,
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
      FROM     igs_uc_form_quals
      WHERE    app_no = x_app_no;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_app_no,
        x_qual_id,
        x_qual_type,
        x_award_body,
        x_title,
        x_grade,
        x_qual_date,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_app_no,
      x_qual_id,
      x_qual_type,
      x_award_body,
      x_title,
      x_grade,
      x_qual_date,
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

    DELETE FROM igs_uc_form_quals
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_form_quals_pkg;

/
